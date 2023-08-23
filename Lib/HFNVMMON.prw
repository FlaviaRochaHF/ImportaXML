#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "Ap5Mail.ch"
#INCLUDE "FILEIO.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE 'APWEBSRV.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE "PRTOPDEF.CH"
#INCLUDE "HTTPCLASS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "parmtype.ch"
#INCLUDE "PRCONST.CH"

// Carrega monitoramento do WebServices para Acompanhamento em Tela

User Function HFNVMMON()

MsAguarde({|| U_HFMON001()}, "Aguarde...")

RETURN

User Function HFMON001()

  local oDlgPrinc as object
  local oFWLayerLeft as object
  local oFWLayerRight as object
  local oPanelLeft as object
  local oPanelRight as object
  local oQuant as object
  local oMonitor as object
  local o2Entidade as object
  local oStatus as object
  local oConsultas as object
  local oCadastros as object
  local aCoors as array
  local nWidthDlg as numeric
  Local aInfo := {}

  Static c_Eol  := CHR(13)+CHR(10)
  Static nTotSuc := 0
  Static nTotErr := 0
  Static nTotCon := 0

  //Variável não declarada, criei com valores simples para manter o POC e não gerar error.log
  aCoors := {0, 0, 800, 1300}

  //Removi o define, tenho TOC =)
  oDlgPrinc = MsDialog():new(aCoors[1], aCoors[2], aCoors[3], aCoors[4], "Monitor de Integracao - Gestao XML",,, .F.,,,,,, .T.,,, .F. )

  //Pego o tamanho da dialog - Largura da dialog principal
  nWidthDlg := oDlgPrinc:nRight / 2

  //22% da largura da Dialog, porém aqui reduzimos um pouco, por conta do espaço que existe entre as janelas que a FWLayer cria
  oPanelLeft := TPanel():new(/*nRow*/, /*nCol*/, /*cText*/, oDlgPrinc, /*oFont*/, /*lCentered*/, /*uParam7*/, /*nClrText*/, /*nClrBack*/, (nWidthDlg * 0.15) - 3)
  oPanelLeft:align := CONTROL_ALIGN_LEFT

  //78% da largura da Dialog
  oPanelRight := TPanel():new(/*nRow*/, /*nCol*/, /*cText*/, oDlgPrinc, /*oFont*/, /*lCentered*/, /*uParam7*/, /*nClrText*/, /*nClrBack*/, (nWidthDlg * 0.85))
  oPanelRight:align := CONTROL_ALIGN_RIGHT

  oFWLayerLeft := FWLayer():new()

  oFWLayerLeft:init(oPanelLeft)

  oFWLayerLeft:addCollumn("Col01", 100, .T. )
  oFWLayerLeft:addWindow("Col01", "Win01", "Quantidades", 90.9, .F., .T., {|| },,)

  oFWLayerRight := FWLayer():new()

  oFWLayerRight:init(oPanelRight)

  oFWLayerRight:addLine("Lin01", 050, .F. )  //45
  oFWLayerRight:addLine("Lin02", 050, .F. )
  //oFWLayerRight:addLine("Lin03", 032, .F. )

  oFWLayerRight:addCollumn("Col01Lin01", 100, .F., "Lin01")
  //oFWLayerRight:addCollumn("Col02Lin01", 033, .T., "Lin01")
  //oFWLayerRight:addCollumn("Col03Lin01", 033, .T., "Lin01")

  //Somente o grupo está pegando 100 da linha
  oFWLayerRight:addCollumn("Col01Lin02", 100, .F., "Lin02")

  //Se desejar que Cadastros pegue a linha por completo, basta colocar o percentual em 100
  //oFWLayerRight:addCollumn("Col01Lin03", 034, .F., "Lin03")

  oFWLayerRight:addWindow("Col01Lin01", "Win02", "Monitor", 100, .T., .T., {||}, "Lin01",) //"Detalhes"
  //oFWLayerRight:addWindow("Col02Lin01", "Win05", "Entidade", 100, .F., .T., {|| }, "Lin01",) //"Entidade"
  //oFWLayerRight:addWindow("Col03Lin01", "Win06", "Status", 100, .F., .T., {|| }, "Lin01",) //"Status"

  oFWLayerRight:addWindow("Col01Lin02", "Win03", "Erros", 100, .T., .F., {||}, "Lin02",) //"Grupos"
  //oFWLayerRight:addWindow("Col01Lin03", "Win04", "Cadastros", 100, .F., .F.,{||}, "Lin03",) //"Cadastros"

  oQuant := oFWLayerLeft:getWinPanel("Col01", "Win01")
  oMonitor := oFWLayerRight:getWinPanel("Col01Lin01", "Win02", "Lin01")
  //o2Entidade := oFWLayerRight:getWinPanel("Col02Lin01", "Win05", "Lin01")
  //oStatus := oFWLayerRight:getWinPanel("Col03Lin01", "Win06", "Lin01")
  oConsultas := oFWLayerRight:getWinPanel("Col01Lin02", "Win03", "Lin02")
  //oCadastros := oFWLayerRight:getWinPanel("Col01Lin03", "Win04", "Lin03")

  //ShowMonit( oFWLayerRight:GetWinPanel( "Col01Lin01", "Win02", "Lin01" ) , aInfo )
  CargaAPI()

  ShowQtd(oQuant, aInfo )

  ShowMonit( oMonitor , aInfo )

  ShowErro(oConsultas, aInfo )


  /*
	oLayer:AddWindow( "BOX02", "PANEL02", "(2) Resumo por Produto"     , nLarg7+20, .t.,,, "LINE02" ) 		//100 - Largura FR - 14/01/2021
	oLayer:AddWindow( "BOX03", "PANEL03", "(3) Resumo por Pedido"  , nLarg7+20, .t.,,, "LINE02" )		//100 - Largura FR - 14/01/2021

	//Chama as funções para cada painel:
	//(1) Resumo Cabeçalho
	FPanelCab( oDlg, oLayer:GetWinPanel( "BOX01", "PANEL01", "LINE01" ) , aInfo ) //Estou passando para a função o método que retorna o objeto do painel da Janela //FR - 10/12/2020

	//(2) PRODUTO
	FPanelPRO( oLayer:GetWinPanel( "BOX02", "PANEL02", "LINE02" ) , aObjects )

  */

  oDlgPrinc:activate( ,,,.T.,,,,, )

return



//============================================
//Faz consulta na API e Carrega Variáveis
//============================================
Static Function CargaAPI()

  //Local oDlg2
  Local nLiIni := 0
  Local nCoIni := 0
  Local nLiFim := 0
  Local nCoFim := 0
  Local lHtml := .T.
  Local cText1Html := ""
  Local cText2Html := ""

  Local nX := 1
  Local aHeader 		:= {}
  Local oRest 	:= Nil
  Local oObjJson  := Nil
  Local cClToken  :=	alltrim(GetNewPar("XM_CLTOKEN",Space(256)))

  Private cUrl 		:= "https://cloud.importaxml.com.br"

  Static nHandle
  Static lUnix  := IsSrvUnix()
  Static cBarra := Iif(lUnix,"/","\")

  Static nDias := GETNEWPAR("XM_DIASMON", 15)
  Static _DataFim := dtoc(ddatabase)
  Static _DataIni := dtoc(ddatabase-nDias)

  Static aSucesso := {}
  Static aErros := {}
  Static aConsulta := {}

  Aadd(aHeader, "Content-Type: application/json")
  Aadd(aHeader, "Accept-Charset: UTF-8")


  nLiIni := 2 //aInfo[1] + 1
  nCoIni := nLiIni
  nLiFim := nLiIni + 50	//0+50=50
  nCoFim := nLiFim		//50
  //FR - 14/01/2021

  //oFont := TFont():New('Courier new',,-18,.T.)
  oFont := TFont():New('Courier new',,-12,.T.)


  // Cria objeto Scroll
  //oScroll := TScrollArea():New(oPanel,01,01,100,100)
  //oScroll := TScrollArea():New(oPanel)
  //oScroll:Align := CONTROL_ALIGN_ALLCLIENT

  // Cria painel
  //@ 000,000 MSPANEL oPanel OF oScroll SIZE 1000,1000 COLOR CLR_HRED

  // Define objeto painel como filho do scroll
  //oScroll:SetFrame( oPanel )

  // Insere objetos no painel apenas para visualização
  // TButton():New( 10,010,"Botão Teste",oPanel,{||},40,010,,,.F.,.T.,.F.,,.F.,,,.F.)
  //TButton():New( 10,230,"Botão Teste",oPanel,{||},40,010,,,.F.,.T.,.F.,,.F.,,,.F.)



  // Faz consulta na API
  /*
{
  "sucessos": [],
  "erros": [],
  "consultaPorChave": []
}
  */
  ConOut("Consulta Monitoramento NFE-Nuvem no Período de: "+_DataIni+" ate "+_DataFim)
  oRest 	:= FWRest():New(cUrl)

  //oRest:SetPath("/api/NFe?token="+cClToken+"&Inicio="+cData30+"&Fim="+cData)
  //cClToken := "YK4CT61V-P0123BXW-XX7YVORE"
  //cClToken := "UUP4FDWF-DNZH7DU5-9K7LSCJ0"
  oRest:SetPath("/api/DadosMonitoramento?Token="+cClToken+"&Inicio="+_DataIni+"&Fim="+_DataFim)

  If oRest:Get(aHeader)

    If !FWJsonDeserialize(oRest:GetResult(), @oObjJson)
      MsgStop("Ocorreu erro no processamento do Json Monitoramento")
      Return Nil
    EndIf

  else

    msgStop(oRest:getLastError(), "Erro")

  EndIf

  If oObjJson <> Nil

    aSucesso := oObjJson:SUCESSOS
    aErros := oObjJson:ERROS
    aConsulta := oObjJson:CONSULTAPORCHAVE

    nTotSuc := cValToChar(len(aSucesso))
    nTotErr := cValToChar(len(aErros))
    nTotCon := cValToChar(len(aConsulta))

    //MsgInfo("Quantidades de Sucesso: "+ cValToChar(len(aSucesso))+" Erros: "+ cValToChar(len(aErros))+" Consultas: "+ cValToChar(len(aConsulta)))

    //1 = Sucesso ; 2 = Erros
    HFMONHTM(1)

    If len(aSucesso) > 0
      For nX := 1 to len(aSucesso)  //oObjJson:NOTAS[1]:XML

        //If IsBlind()
        //	Conout("Baixando XML Cte na Nuvem ("+cValtoChar(nLoteCte)+")...")
        //	Conout("Baixando..." + cValtoChar(nX) +" de "+ cValtoChar(Len(aNotas)))
        //Else
        //		oProcess:IncRegua1("Baixando XML Cte na nuvem ("+cValtoChar(nLoteCte)+")...")
        //oProcess:IncRegua2("Aguarde...")
        //		oProcess:IncRegua2("Baixando..." + cValtoChar(nX) +" de "+ cValtoChar(Len(aNotas)))
        //Endif

        cID  := cValtoChar(aSucesso[nX]:RoboLogID)
        cTipo := aSucesso[nX]:Tipo
        cDataHora := aSucesso[nX]:DataHora
        cNumNotas := alltrim(cValtoChar(aSucesso[nX]:NumNotas))
        cNumEvent := alltrim(cValtoChar(aSucesso[nX]:NumEventos))
        cManual := aSucesso[nX]:Manual

        StrTran(cNumNotas,"","0")
        StrTran(cNumEvent,"","0")

        if empty(cNumEvent)
          cNumEvent := "0"
        endif


        cDataHora := (SubStr(cDataHora,9,2))+"/"+(SubStr(cDataHora,6,2))+"/"+(SubStr(cDataHora,1,4)) +" - "+ (SubStr(cDataHora,12,8))


        /*
      "RoboLogID": 661528,
      "Tipo": "CTe",
      "DataHora": "2022-07-05T06:21:14.513",
      "NumNotas": 0,
      "NumEventos": 2,
      "Manual": 0,
      "IBGE": "",
      "UF": "",
      "Cidade": ""
        */

        FWrite(nHandle, ' <tr style="height: 18px;">' + c_Eol, 200)
        FWrite(nHandle, ' <td style="height: 18px; width: 106.312px;font-family:verdana,geneva,sans-serif;font-size:11px">'+cID+'</td>' + c_Eol, 200)
        FWrite(nHandle, ' <td style="height: 18px; width: 217.641px;font-family:verdana,geneva,sans-serif;font-size:11px">'+cDataHora+'</td>' + c_Eol, 200)
        FWrite(nHandle, ' <td style="height: 18px; width: 132.391px;font-family:verdana,geneva,sans-serif;font-size:11px">'+cTipo+'</td>' + c_Eol, 200)
        FWrite(nHandle, ' <td style="height: 18px; width: 92.2812px;font-family:verdana,geneva,sans-serif;font-size:11px">'+cNumNotas+'</td>' + c_Eol, 200)
        FWrite(nHandle, ' <td style="height: 18px; width: 115.375px;font-family:verdana,geneva,sans-serif;font-size:11px">'+cNumEvent+'</td>' + c_Eol, 200)
        FWrite(nHandle, ' </tr>' + c_Eol, 200)


      Next nX


    Else

      FWrite(nHandle, '<tr>'+ c_Eol, 200)
      FWrite(nHandle, '<td style="height: 18px; width: 320.156px;"><span style="font-family: verdana,geneva,sans-serif;font-size:11px">Nenhuma informação encontrada</span></td>'+ c_Eol, 200)
      FWrite(nHandle, '</tr>'+ c_Eol, 200)

    Endif

    FWrite(nHandle, ' </tbody>' + c_Eol, 200)
    FWrite(nHandle, ' </table>' + c_Eol, 200)
    FWrite(nHandle, ' <p><a title="Help Gest&atilde;oXML" href="https://helponline.importaxml.com.br/home"><img src="https://helponline.importaxml.com.br/wp-content/uploads/2021/08/imagem-rodape-Help-Redimensionada.png" alt="" /></a></p>' + c_Eol, 200)

    FWrite(nHandle, ' </div>' + c_Eol, 200)
    FWrite(nHandle, ' </div>' + c_Eol, 200)

    fclose(nHandle)
    Fclose(cFile)

    ft_fuse()
    /*
    cText1Html += '<tr style="height: 18px;">'
    cText1Html += '<td style="height: 18px; width: 252.125px;">campo2</td>'
    cText1Html += '<td style="height: 18px; width: 331.812px;"><span style="color: green; font-size: 13px;">campo21</span></td>'
    cText1Html += '<td style="height: 18px; width: 81.0625px;"><span style="color: green; font-size: 13px;">campo22</span></td>'
    cText1Html += '</tr>'
    cText1Html += '</tbody>'
    cText1Html += '</table>'

    cText1Html += '<hr size="1">'
    //  cText1Html += '<br/>'
    cText1Html += '<center><font size="6" color="blue"><b>Qtd: '+cTotXML+'</b></font><br/></center>'		//FR - 10/12/2020
    //cText1Html += '<center><font size="3" color="blue"><b>R$ '+cTotVlXML+'</b></font><br/></center>'
    cText1Html += '<center><font size="3" color="blue"><b>R$ '+cTotVlXML+'</b></font></center>'
    cText1Html += '<center><font size="2" color="red">Ult.Download: '+cDatUlt+'</font><br/><center>'
    cText1Html += '</table>'
    */
  EndIf


  HFMONHTM(2)

  if len(aErros) > 0
    For nX := 1 to len(aErros)


      /*
      "LogRoboErroID": 11118,
      "Tipo": "NFe",
      "DataHora": "2022-05-10T14:15:55.063",
      "IBGE": "",
      "UF": "",
      "Cidade": "",
      "Erro": "Rejeicao: Consumo Indevido (Deve ser utilizado o ultNSU nas solicitacoes subsequentes. Tente apos 1 hora)",
      "TipoErro": 1,
      "Visto": true

    <td style="height: 18px; width: 131.312px;"><span style="font-family: verdana, geneva, sans-serif; background-color: #ff0000;">'+cID+'</span></td>
<td style="width: 128.297px;"><span style="font-family: verdana, geneva, sans-serif; background-color: #339966;">'+Tipo+'</span></td>

      */

      cID  := cValtoChar(aErros[nX]:LogRoboErroID)
      cTipo := aErros[nX]:Tipo
      cDataHora := aErros[nX]:DataHora
      cErro := alltrim(aErros[nX]:Erro)
      cTipoLog := cValtoChar(aErros[nX]:TipoErro)
      lVisto := aErros[nX]:TipoErro
      _corBack := "#F8F8FF"
      _txtLog := "Info"

      cDataHora := (SubStr(cDataHora,9,2))+"/"+(SubStr(cDataHora,6,2))+"/"+(SubStr(cDataHora,1,4)) +" - "+ (SubStr(cDataHora,12,8))

      if cTipoLog == "1" //Erro
        _corBack := "#FFA07A" //"#FF6347" //"#ff0000"
        _txtLog := "Erro"
      elseif cTipoLog == "2" //Alerta
        _corBack := "#FFFF00" //"##339966"
        _txtLog := "Alerta"
      ENDIF
      //<span style="color: green


      FWrite(nHandle, '<tr>'+ c_Eol, 200)
      FWrite(nHandle, '<td style="height: 18px; width: 120.156px;"><span style="font-family: verdana,geneva,sans-serif;font-size:11px">'+cID+'</span></td>'+ c_Eol, 200)
      FWrite(nHandle, '<td style="height: 18px; width: 190.219px;"><span style="font-family: verdana,geneva,sans-serif;font-size:11px">'+cDataHora+'</span></td>'+ c_Eol, 200)
      FWrite(nHandle, '<td style="width: 120.141px;"><span style="font-family: verdana,geneva,sans-serif;font-size:11px">'+cTipo+'</span></td>'+ c_Eol, 200)
      FWrite(nHandle, '<td style="width: 120.141px;"><span style="font-family: verdana,geneva,sans-serif;font-size:11px;background-color: '+_corBack+'">'+_txtLog+'</span></td>'+ c_Eol, 200)
      FWrite(nHandle, '<td style="height: 18px; width: 426.484px;"><span style="font-family: verdana,geneva,sans-serif;font-size:11px">'+cErro+'</span></td>'+ c_Eol, 200)
      FWrite(nHandle, '</tr>'+ c_Eol, 200)

    Next nX

  else

    FWrite(nHandle, '<tr>'+ c_Eol, 200)
    FWrite(nHandle, '<td style="height: 18px; width: 320.156px;"><span style="font-family: verdana,geneva,sans-serif;font-size:11px">Nenhuma informação encontrada</span></td>'+ c_Eol, 200)
    FWrite(nHandle, '</tr>'+ c_Eol, 200)

  Endif
  FWrite(nHandle, '</tbody>'+ c_Eol, 200)
  FWrite(nHandle, '</table>'+ c_Eol, 200)
  FWrite(nHandle, '<p><span style="font-family: verdana,geneva,sans-serif;"><img src="https://helponline.importaxml.com.br/wp-content/uploads/2021/08/imagem-rodape-Help-Redimensionada.png" alt="" /></span></p>'+ c_Eol, 200)
  FWrite(nHandle, '</div>'+ c_Eol, 200)
  FWrite(nHandle, '</div>'+ c_Eol, 200)

  fclose(nHandle)
  Fclose(cFile)

  ft_fuse()

Return

Static Function ShowQtd(oPanel , aInfo )

  Local cText1Html := ""
  Local lHtml := .t.

  cText1Html += '<div>'
  cText1Html += '			<p>&nbsp;</p>'
  cText1Html += '<table border="0" style="border-collapse:collapse; height:134px; width:30.1136%">'
  cText1Html += '	<tbody>'
  cText1Html += '		<tr>'
  cText1Html += '			<td style="text-align:center; width:33.3333%">'
  cText1Html += '			<h1 style="text-align:center"><span style="font-family:verdana,geneva,sans-serif"><span style="color:#0000ff"><strong>Resumo</strong></span></span></h1>'
  cText1Html += '			</td>'
  cText1Html += '		</tr>'
  cText1Html += '		<tr>'
  cText1Html += '			<td style="height:44px; text-align:center; width:33.3333%">'
  cText1Html += '			<h1>&nbsp;</h1>'

  cText1Html += '			<h1><strong><span style="font-family:verdana,geneva,sans-serif">Consultas</span></strong></h1>'

  cText1Html += '			<h2><span style="font-family:verdana,geneva,sans-serif">'+nTotSuc+'</span></h2>'
  cText1Html += '<hr />'
  cText1Html += '			<p>&nbsp;</p>'
  cText1Html += '			</td>'
  cText1Html += '		</tr>'
  cText1Html += '		<tr>'
  cText1Html += '			<td style="height:12px; text-align:center; width:33.3333%">'
  cText1Html += '			<h1>&nbsp;</h1>'

  cText1Html += '			<h1><strong><span style="font-family:verdana,geneva,sans-serif">Erros</span></strong></h1>'

  cText1Html += '			<h2><span style="font-family:verdana,geneva,sans-serif"><strong><span style="color:#ff0000">'+nTotErr+'</span></strong></span></h2>'
  cText1Html += '<hr />'
  /*
  cText1Html += '			<p>&nbsp;</p>'
  cText1Html += '			</td>'
  cText1Html += '		</tr>'
  cText1Html += '		<tr>'
  cText1Html += '			<td style="height:78px; width:33.3333%">'
  cText1Html += '			<h1 style="text-align:center">&nbsp;</h1>'

  cText1Html += '			<h1 style="text-align:center"><strong><span style="font-family:verdana,geneva,sans-serif">Consultas</span></strong></h1>'

  cText1Html += '			<h2 style="text-align:center"><span style="font-family:verdana,geneva,sans-serif">'+nTotCon+'</span></h2>'
  cText1Html += '<hr />'
  cText1Html += '			<p>&nbsp;</p>'
  cText1Html += '			</td>'

  cText1Html += '		</tr>'
  */
  cText1Html += '	</tbody>'
  cText1Html += '</table>'
  cText1Html += '</div>'

  //oSay1 := TSay():New(01,01,{||cText1Html},oPanel,,oFont,,,,.T.,,,120,90,,,,,,lHtml)

  oSay1 := TSay():New(01,01,{||cText1Html},oPanel,,oFont,,,,.T.,,,90,590,,,,,,lHtml)

Return

//============================================
//Carrega Painel de Monitor de Sucessos
//============================================
Static Function ShowMonit( oPanel , aInfo )

  Local oWebEngine
  Local nPort       := 0
  Local cUrl2       := _ArqSuces
  Local cHtml       := _ArqSuces
  Local aCoors
  Local mainHTML
  Private oWebChannel //:= TWebChannel():New()


  //Prepara o conector
  //  nPort := oWebChannel::connect()

  //  oWebEngine := TWebEngine():New(oPanel, 0, 0, 100, 100,/*cUrl*/, nPort)
  //  oWebEngine:SetHtml( MemoRead(_ArqSuces) )
  //  oWebEngine:Align := CONTROL_ALIGN_ALLCLIENT


  aCoors            := FWGetDialogSize(oPanel)


  oWebChannel := TWebChannel():New()
  oWebChannel:bJsToAdvpl := {|self,key,value| jsToAdvpl(self,key,value) }
  oWebChannel:connect()

  // WebEngine (chromium embedded)
  oWebEngine := TWebEngine():New(oPanel,aCoors[1], aCoors[2] , (aCoors[3]) - aCoors[1] -200, (aCoors[4]) - aCoors[2]-200,/*cUrl*/,oWebChannel:nPort)
  oWebEngine:Align := CONTROL_ALIGN_ALLCLIENT

  // WebComponent de teste
  tmp := GetTempPath()
  mainHTML := cHtml //tmp + lower("arquivo") + ".html"

  //    oWebEngine:navigate(;
  //        iif(getOS()=="UNIX", "file://", "")+;
  //        mainHTML)

  oWebEngine:navigate(mainHTML)

  // bLoadFinished sera disparado ao fim da carga da pagina
  // instanciando o bloco de codigo do componente, e tambem um customizado
  //    oWebEngine:bLoadFinished := {|webengine, url| OnInit(webengine, url),;
  //       myLoadFinish(webengine, url) }

  oWebEngine:bLoadFinished := {|webengine,cUrl2| conout("Fim do carregamento da pagina " + mainHTML) }

RETURN


//============================================
//Carrega Painel de Monitor de Sucessos
//============================================
Static Function ShowErro( oPanel , aInfo )

  Local oWebEngine
  Local nPort       := 0
  Local cUrl2       := _ArqErros
  Local cHtml       := _ArqErros
  Local aCoors
  Local mainHTML
  Private oWebErros// := TWebChannel():New()


  aCoors            := FWGetDialogSize(oPanel)


  oWebErros := TWebChannel():New()
  oWebErros:bJsToAdvpl := {|self,key,value| jsToAdvpl(self,key,value) }
  nPort := oWebErros:connect()

  // WebEngine (chromium embedded)
  oWebErros := TWebEngine():New(oPanel,aCoors[1], aCoors[2] , (aCoors[3]) - aCoors[1] -200, (aCoors[4]) - aCoors[2]-200,/*cUrl*/,nPort)
  oWebErros:Align := CONTROL_ALIGN_ALLCLIENT

  // WebComponent de teste
  tmp := GetTempPath()
  mainHTML := cHtml //tmp + lower("arquivo") + ".html"

  //    oWebEngine:navigate(;
  //        iif(getOS()=="UNIX", "file://", "")+;
  //        mainHTML)

  oWebErros:navigate(mainHTML)

  // bLoadFinished sera disparado ao fim da carga da pagina
  // instanciando o bloco de codigo do componente, e tambem um customizado
  //    oWebEngine:bLoadFinished := {|webengine, url| OnInit(webengine, url),;
  //       myLoadFinish(webengine, url) }

 // oWebErros:bLoadFinished := {|webengine,cUrl2| conout("Fim do carregamento da pagina " + mainHTML) }

RETURN

//============================================
//Cria arquivo HTML de Monitor de Sucessos
//============================================
Static Function HFMONHTM(_nTipo)

  Local _lGerou := .t.
  //Local cLogUser := Alltrim(UsrFullName(RetCodUsr()))
  Local cDirArq     :=  GetTempPath() //"\"+AllTrim(GetNewPar("MV_X_PATHX",""))+"\"
  Static _ArqSuces := ""
  Static _ArqErros := ""

  cDirArq     := Iif(lUnix,StrTran(cDirArq,"\","/"),cDirArq)
  cDirArq     := StrTran(cDirArq,cBarra+cBarra,cBarra)

  If _nTipo ==  1 //Arquivo Sucesso

    _ArqSuces := cDirArq+"hfxmlmonitor_"+Alltrim(UsrFullName(RetCodUsr()))+".html"

    If FILE(_ArqSuces)
      FERASE(_ArqSuces)
    EndIf


    nHandle := FCREATE(_ArqSuces)

    If nHandle == -1
      //MsgStop('Erro de abertura : FERROR '+str(ferror(),4))
      Conout('Erro de abertura : FERROR '+str(ferror(),4))
      _lGerou := .f.
    Else

      FSeek(nHandle, 0, FS_END)         // Posiciona no fim do arquivo

      //<h2><span style="font-family: verdana,geneva,sans-serif;"><span style="color: #0000ff;"><strong><img src="https://www.importaxml.com.br/wp-content/uploads/2020/04/logo.png" alt="" width="318" height="102" /></strong></span></span></h2>

      //      FWrite(nHandle, '<img src="https://helponline.importaxml.com.br/wp-content/uploads/2021/08/banner.png" alt="GestaoXML" width="702" height="222" />' + c_Eol, 200)
      FWrite(nHandle, '<img src="https://www.importaxml.com.br/wp-content/uploads/2020/04/logo.png" alt="GestaoXML" width="318" height="102" />' + c_Eol, 200)
      FWrite(nHandle,'<hr />' + c_Eol, 200)
      FWrite(nHandle, ' <h2><span style="color: #0000ff;font-family:verdana,geneva,sans-serif"><strong>Monitor de Eventos ('+_DataIni+' a '+_DataFim+')</strong></span></h2>' + c_Eol, 200)
      FWrite(nHandle, ' <p><span style="color: #0000ff;font-family:verdana,geneva,sans-serif"><strong>Gerado em: '+dtoc(dDatabase)+" "+Time()+'</strong></span></p>' + c_Eol, 200)
      /*
      FWrite(nHandle, ' <table style="height: 10px; width: 698px; border-style: inset; background-color: #c0c0c0;" border="0"' + c_Eol, 200)
      FWrite(nHandle, ' <tbody>' + c_Eol, 200)
      FWrite(nHandle, ' <tr style="height: 44px; text-align: center">' + c_Eol, 200)
      FWrite(nHandle, ' <td style="width: 33.3333%; height: 44px;">' + c_Eol, 200)
      FWrite(nHandle, ' <h2>Sucessos</h2>' + c_Eol, 200)
      FWrite(nHandle, ' </td>' + c_Eol, 200)
      FWrite(nHandle, ' <td style="width: 33.3333%; height: 44px; text-align: center">' + c_Eol, 200)
      FWrite(nHandle, ' <h2>Erros</h2>' + c_Eol, 200)
      FWrite(nHandle, '  </td>' + c_Eol, 200)
      FWrite(nHandle, ' <td style="width: 34.1128%; height: 44px; text-align: center">' + c_Eol, 200)
      FWrite(nHandle, ' <h2>Consultas</h2>' + c_Eol, 200)
      FWrite(nHandle, ' </td>' + c_Eol, 200)
      FWrite(nHandle, ' </tr>' + c_Eol, 200)
      FWrite(nHandle, ' <tr style="height: 18px;">' + c_Eol, 200)
      FWrite(nHandle, ' <td style="width: 33.3333%; height: 18px; text-align: center"><span style="font-family:verdana,geneva,sans-serif"><strong>'+nTotSuc+'</strong></span></td>' + c_Eol, 200)
      FWrite(nHandle, ' <td style="width: 33.3333%; height: 18px; text-align: center"><span style="font-family:verdana,geneva,sans-serif"><strong><span style="color: #ff0000;">'+nTotErr+'</span></strong></td>' + c_Eol, 200)
      FWrite(nHandle, ' <td style="width: 34.1128%; height: 18px; text-align: center"><span style="font-family:verdana,geneva,sans-serif"><strong>'+nTotCon+'</strong></span></td>' + c_Eol, 200)

      FWrite(nHandle, ' </tr>' + c_Eol, 200)
      FWrite(nHandle, '</tbody>' + c_Eol, 200)
      FWrite(nHandle, ' </table>' + c_Eol, 200)
      */
      FWrite(nHandle, ' <p>&nbsp;</p>' + c_Eol, 200)
      FWrite(nHandle, ' <table style="height: 10px; width: 698px; border-style: inset; background-color: #87ceeb;" border="0">' + c_Eol, 200)
      FWrite(nHandle, ' <thead>' + c_Eol, 200)
      FWrite(nHandle, ' <tr style="height: 18px;">' + c_Eol, 200)
      FWrite(nHandle, ' <td style="height: 10px; width: 106.312px;"><span style="color: #0000ff;font-family:verdana,geneva,sans-serif"><strong>ID</strong></span></td>' + c_Eol, 200)

      FWrite(nHandle, ' <td style="height: 10px; width: 217.641px;"><span style="color: #0000ff;font-family:verdana,geneva,sans-serif"><strong>Data</strong></span></td>' + c_Eol, 200)
      FWrite(nHandle, ' <td style="height: 10px; width: 132.391px;"><span style="color: #0000ff;font-family:verdana,geneva,sans-serif"><strong>Tipo</strong></span></td>' + c_Eol, 200)
      FWrite(nHandle, ' <td style="height: 10px; width: 92.2812px;"><span style="color: #0000ff;font-family:verdana,geneva,sans-serif"><strong>Qtd.Notas</strong></span></td>' + c_Eol, 200)
      FWrite(nHandle, ' <td style="height: 10px; width: 115.375px;"><span style="color: #0000ff;font-family:verdana,geneva,sans-serif"><strong>Qtd.Eventos</strong></span></td>' + c_Eol, 200)
      FWrite(nHandle, ' </tr>' + c_Eol, 200)
      FWrite(nHandle, ' </thead>' + c_Eol, 200)
      FWrite(nHandle, '</table>' + c_Eol, 200)
      FWrite(nHandle, ' <div>' + c_Eol, 200)
      FWrite(nHandle, ' <div>' + c_Eol, 200)
      FWrite(nHandle, ' <table style="height: 36px; border-style: inset; width: 698px;" border="0">' + c_Eol, 200)
      FWrite(nHandle, ' <tbody>' + c_Eol, 200)

    ENDIF

  Elseif _nTipo == 2 //Arquivo Erros


    _ArqErros := cDirArq+"hfxmlError_"+Alltrim(UsrFullName(RetCodUsr()))+".html"

    If FILE(_ArqErros)
      FERASE(_ArqErros)
    EndIf


    nHandle := FCREATE(_ArqErros)

    If nHandle == -1
      //MsgStop('Erro de abertura : FERROR '+str(ferror(),4))
      Conout('Erro de abertura : FERROR '+str(ferror(),4))
      _lGerou := .f.
    Else

      FSeek(nHandle, 0, FS_END)         // Posiciona no fim do arquivo

      FWrite(nHandle, '<h2><span style="font-family: verdana,geneva,sans-serif;"><span style="color: #0000ff;"><strong>Erros de Consulta</strong></span></span></h2>'+ c_Eol, 200)
      // FWrite(nHandle, '<p>&nbsp;</p>'+ c_Eol, 200)
      FWrite(nHandle, '<table style="background-color: #87ceeb; border-style: inset; height: 10px; width: 879px;" border="0">'+ c_Eol, 200)
      FWrite(nHandle, '<thead>'+ c_Eol, 200)
      FWrite(nHandle, '<tr>'+ c_Eol, 200)
      FWrite(nHandle, '<td style="height: 10px; width: 120.156px;"><span style="font-family: verdana,geneva,sans-serif;text-align: left;"><span style="color: #0000ff;"><strong>ID</strong></span></span></td>'+ c_Eol, 200)
      FWrite(nHandle, '<td style="height: 10px; width: 190.219px;"><span style="font-family: verdana,geneva,sans-serif;text-align: left;"><span style="color: #0000ff;"><strong>Data</strong></span></span></td>'+ c_Eol, 200)
      FWrite(nHandle, '<td style="width: 120.141px;"><span style="font-family: verdana,geneva,sans-serif;"><span style="color: #0000ff;text-align: left;"><strong>Tipo</strong></span></span></td>'+ c_Eol, 200)
      FWrite(nHandle, '<td style="width: 120.141px;"><span style="font-family: verdana,geneva,sans-serif;"><span style="color: #0000ff;text-align: left;"><strong>Log</strong></span></span></td>'+ c_Eol, 200)
      FWrite(nHandle, '<td style="height: 10px; width: 426.484px;"><span style="font-family: verdana,geneva,sans-serif;"><span style="color: #0000ff;text-align: left;"><strong>Erro</strong></span></span></td>'+ c_Eol, 200)

      FWrite(nHandle, '</tr>'+ c_Eol, 200)
      FWrite(nHandle, '</thead>'+ c_Eol, 200)
      FWrite(nHandle, '</table>'+ c_Eol, 200)
      FWrite(nHandle, '<div>'+ c_Eol, 200)
      FWrite(nHandle, '<div>'+ c_Eol, 200)
      FWrite(nHandle, '<table style="border-style: inset; height: 36px; width: 873px;" border="0">'+ c_Eol, 200)
      FWrite(nHandle, '<tbody>'+ c_Eol, 200)
      /*
      FWrite(nHandle, '<tr>'+ c_Eol, 200)
      FWrite(nHandle, '<td style="height: 18px; width: 131.312px;"><span style="font-family: verdana,geneva,sans-serif;">'+cID+'</span></td>'+ c_Eol, 200)
      FWrite(nHandle, '<td style="width: 128.297px;"><span style="font-family: verdana,geneva,sans-serif;">'+Tipo+'</span></td>'+ c_Eol, 200)
      FWrite(nHandle, '<td style="height: 18px; width: 192.453px;"><span style="font-family: verdana,geneva,sans-serif;">'+cDataHora+'</span></td>'+ c_Eol, 200)
      FWrite(nHandle, '<td style="height: 18px; width: 392.938px;"><span style="font-family: verdana,geneva,sans-serif;">'+cTipo+'</span></td>'+ c_Eol, 200)
      FWrite(nHandle, '</tr>'+ c_Eol, 200)
      FWrite(nHandle, '</tbody>'+ c_Eol, 200)
      FWrite(nHandle, '</table>'+ c_Eol, 200)
      FWrite(nHandle, '<p><span style="font-family: verdana,geneva,sans-serif;"><img src="https://helponline.importaxml.com.br/wp-content/uploads/2021/08/imagem-rodape-Help-Redimensionada.png" alt="" /></span></p>'+ c_Eol, 200)
      FWrite(nHandle, '</div>'+ c_Eol, 200)
      FWrite(nHandle, '</div>'+ c_Eol, 200)
      */

    ENDIF

  Endif


return(_lGerou)

/*

Static Function HTML()
  Local aSize       := MsAdvSize()
  Local nPort       := 0
  Local cPasta      := "\x_web\"
  Local cHtml       := _ArqSuces //cPasta + "AppletWeb.html"
  Local cUrl2       := _ArqSuces
  Local oModal
  Local oWebEngine

  Local aCoors        //    := FWGetDialogSize(oModal)

  Private oWebChannel := TWebChannel():New()

  //Se a pasta não existir, cria a pasta
  If ! ExistDir(cPasta)
    MakeDir(cPasta)
  EndIf

  //Se o arquivo não existir, cria um vazio
  If ! File(cHtml)
    MemoWrite(cHtml, "<h1>Arquivo não encontrado!</h1>")
  EndIf

  //Cria a dialog
*/
 // oModal := MSDialog():New(aSize[7],0,aSize[6],aSize[5], "Página Local",,,,,,,,,.T./*lPixel*/)

//  aCoors            := FWGetDialogSize(oModal)

  //Prepara o conector
  //       nPort := oWebChannel::connect()

  //Cria o componente que irá carregar o arquivo local
  //       oWebEngine := TWebEngine():New(oModal, 0, 0, 100, 100,/*cUrl*/, nPort)
  //       oWebEngine:SetHtml( MemoRead(cHtml) )

  //  oWebEngine:bLoadFinished := {|self,url| conout("Termino da carga do pagina: " + cHtml) }

  //     oWebEngine:bLoadFinished := {|self,cUrl2| conout("Fim do carregamento da pagina " + cUrl2) }
  //8   oWebEngine:navigate(cUrl2)
  //   oWebEngine:Align := CONTROL_ALIGN_ALLCLIENT



//  oWebChannel := TWebChannel():New()
//  oWebChannel:bJsToAdvpl := {|self,key,value| jsToAdvpl(self,key,value) }
//  oWebChannel:connect()

  // WebEngine (chromium embedded)
//  oWebEngine := TWebEngine():New(oModal,aCoors[1], aCoors[2] , (aCoors[3]) - aCoors[1] -200, (aCoors[4]) - aCoors[2]-200,/*cUrl*/,oWebChannel:nPort)
//  oWebEngine:Align := CONTROL_ALIGN_ALLCLIENT

  // WebComponent de teste
//  tmp := GetTempPath()
//  mainHTML := cHtml //tmp + lower("arquivo") + ".html"

  //    oWebEngine:navigate(;
  //        iif(getOS()=="UNIX", "file://", "")+;
  //        mainHTML)

//  oWebEngine:navigate(mainHTML)

  // bLoadFinished sera disparado ao fim da carga da pagina
  // instanciando o bloco de codigo do componente, e tambem um customizado
  //    oWebEngine:bLoadFinished := {|webengine, url| OnInit(webengine, url),;
  //       myLoadFinish(webengine, url) }

//  oWebEngine:bLoadFinished := {|webengine,cUrl2| conout("Fim do carregamento da pagina " + mainHTML) }


//  oModal:Activate()
//Return


//-------------------------------------
/*
User Function DbTree()

  DEFINE DIALOG oDlg TITLE "Exemplo de DBTree" FROM 180,180 TO 550,700 PIXEL

  // Cria a Tree
  oTree := DbTree():New(0,0,160,260,oDlg,,,.T.)

  // Insere itens
  oTree:AddItem("Primeiro nível da DBTree","001", "FOLDER5" ,,,,1)
  If oTree:TreeSeek("001")
    oTree:AddItem("Segundo nível da DBTree","002", "FOLDER10",,,,2)
    If oTree:TreeSeek("002")
      oTree:AddItem("Subnível 01","003", "FOLDER6",,,,2)
      oTree:AddItem("Subnível 02","004", "FOLDER6",,,,2)
      oTree:AddItem("Subnível 03","005", "FOLDER6",,,,2)
    endif
  endif
  oTree:TreeSeek("001") // Retorna ao primeiro nível

  // Cria botões com métodos básicos

  TButton():New( 160, 002, "Seek Item 4", oDlg,{|| oTree:TreeSeek("004")};
    ,40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
  TButton():New( 160, 052, "Enable"	, oDlg,{|| oTree:SetEnable() };
    ,40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
  TButton():New( 160, 102, "Disable"	, oDlg,{|| oTree:SetDisable() };
    ,40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
  TButton():New( 160, 152, "Novo Item", oDlg,{|| TreeNewIt() };
    ,40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
  TButton():New( 172,02,"Dados do item", oDlg,{|| ;
    Alert("Cargo: "+oTree:GetCargo()+chr(13)+"Texto: "+oTree:GetPrompt(.T.)) },;
    40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
  TButton():New( 172, 052, "Muda Texto", oDlg,{|| ;
    oTree:ChangePrompt("Novo Texto Item 001","001") },;
    40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
  TButton():New( 172, 102, "Muda Imagem", oDlg,{||;
    oTree:ChangeBmp("LBNO","LBTIK",,,"001") },;
    40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
  TButton():New( 172, 152, "Apaga Item", oDlg,{|| ;
    if(oTree:TreeSeek("006"),oTree:DelItem(),) },;
    40,010,,,.F.,.T.,.F.,,.F.,,,.F. )
  // Indica o término da contrução da Tree
  oTree:EndTree()

  ACTIVATE DIALOG oDlg CENTERED

Return
//----------------------------------------
// Função auxiliar para inserção de item
//----------------------------------------
Static Function TreeNewIt()

  // Cria novo item na Tree
  oTree:AddTreeItem("Novo Item","FOLDER7",,"006")
  if oTree:TreeSeek("006")
    oTree:AddItem("Sub-nivel 01","007", "FOLDER6",,,,2)
    oTree:AddItem("Sub-nivel 02","008", "FOLDER6",,,,2)
  endif

Return
*/
