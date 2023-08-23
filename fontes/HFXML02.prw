#include "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "Ap5Mail.ch"
#INCLUDE "FILEIO.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "PRTOPDEF.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "XMLXFUN.CH"
//#INCLUDE "INKEY.CH"
#DEFINE IMP_PDF 6

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HFXML02   º Autor ³ Roberto Souza      º Data ³  12/09/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Chamada para rotina principal de importação de arquivos    º±±
±±º          ³ XML de Fornecedores.                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ IMPORTA XML                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
//---------------------------------------------------------------------------//
//Alterações realizadas:
//FR - 16/03/2020 - Projeto Politec - criação dos campos: ZBT_ITEM, ZBT_NOTA, 
//                  ZBT_SERIE, ZBT_CLIFOR, ZBT_LOJA, ZBT_TIPOFO
//                  Para gravação das notas de origem que compõem 
//                  o Cte por linha na ZBT e SD1.
//----------------------------------------------------------------------------//
//FR - 04/06/2020 - Projeto CCM: criação de novo campo ZBZ_ORIPRT 
//                  Origem da prestação de serviço: irá armazenar:
//                  o município - UF. Ex.: JUNDIAI - SP
//----------------------------------------------------------------------------//
//FR - 27/07/2020 - Projeto CCM: revisão novo campo ZBZ_ORIPRT
//----------------------------------------------------------------------------//
//FR - 18/08/2020 - Projeto Kroma Energia: criação de Legendas
//----------------------------------------------------------------------------//
//FR - 22/09/2020 - Adequação do uso do novo parâmetro XM_CLATPNF 
//                  Tipos de NF a serem contempladas na classficação automática
//                  C-Combustiveis; E-Energia; T-Todos; N-Nenhum
//----------------------------------------------------------------------------//
//FR - 30/09/2020 - Uso da regua de processo
//----------------------------------------------------------------------------//
//FR - 01/12/2020 - #Chamado 5808 - Forceline 
//                  Incluir duas novas perguntas:
//                  CNPJ De / CNPJ Até 
//                  Adequar pasta de impressão \system\pdf estava criando com
//                  duas \\ (barras)
//--------------------------------------------------------------------------//
//FR - 22/12/2020 - #Chamado 5831 - Cimentos Itambé
//                  Ajuste na função RetUFiDe() que retorna a UF, quando 
//                  vinha já em forma de sigla o array não encontrava
//                  porque era esperado o código da UF (ex.: BA = 29)
//--------------------------------------------------------------------------//
//FR - 08/02/2021 - #6170 - MaxiRubber - correção para gravar no campo ZBZ_XML 
//                  a string relativa ao encode utf8, caso não haja esta string
//                  no início do XML
//                  '<?xml version="1.0" encoding="UTF-8"?>' -> precisa ter
//                  logo no início da string do XML.
//--------------------------------------------------------------------------//
//FR - 15/02/2021 - #6212 - MaxiRubber - incluir nas perguntas da função 
//                  "Exportar XML" , filtro por modelo (Cte, Nfe, Nfse..etc)
//--------------------------------------------------------------------------//
//FR - 23/03/2021 - #10344 - Cimentos Itambé - validar a propriedade INFPROT 
//                  no XML , prevenindo contra error.log por propriedade
//                  inválida.
//--------------------------------------------------------------------------//
//FR - 05/05/2021 - #10382 - Kroma - tratativa para chamada dentro do Schedule 
//---------------------------------------------------------------------------// 
//FR - 07/06/2021 - Rollback das alterações da Kroma
//---------------------------------------------------------------------------// 
//FR - 28/10/2021 - Implementação cadastro fornecedor (SA2) automatizado (Daikin)
//                  Parâmetro: "XM_SA2AUTO" Tipo Caracter, conteúdo : S-Sim; N=Não
//---------------------------------------------------------------------------------//
//FR - 04/11/2021 - #11460 - ADAR - ao visualizar nf via ImportaXML, mostra
//                  uma outra nota de mesmo número e fornecedor, porém emissao
//                  diferente, e a chave estava em branco no F1_CHVNFE         
//                  correção para validar com a emissão do XML x NF
//-----------------------------------------------------------------------------------//
//FR - 19/11/2021 - Band Agro - Inclusão de opção de menu para chamar a
//                  rotina Banco de Conhecimento MsDocument
//-----------------------------------------------------------------------------------//
//FR - 21/12/2021 - Revisão dos parâmetros de automatização do cadastro de 
//                  fornecedor:
//                  - XM_SA2AUTO - cadastra fornecedor na classif. nf
//                  - XM_SA2AUTD - cadastra fornecedor no download xml
//-----------------------------------------------------------------------------------//
//FR - 17/02/2022 - correção da tag, devido erro reportado pela Cimentos Itambé, 
//                  variable is not an object  on VALIDAXMLALL(HFXML02.PRW) 
//                  28/01/2022 17:06:40 line : 1065
//-----------------------------------------------------------------------------------//
//FR - 31/03/2022 - PROJETO KITCHENS - IMPRESSÃO DANFE PDF para anexar ao pedido compra
//-----------------------------------------------------------------------------------//
//FR - 19/05/2022 - TELETEX #12479 - MUDANÇA NA LEGENDA
//-----------------------------------------------------------------------------------//
//FR - 17/08/2022 - TELETEX #13427 - REVISÃO NA QUERY QUE CAPTA A ÚLTIMA MANIFESTAÇÃO
//                  ALTERADA ORDER BY PARA RECNO AO INVÉS DO CAMPO ZBE_DHAUT
//-----------------------------------------------------------------------------------//
//FR - 17/08/2022 - TÓPICOS RAFAEL DE VALIDAÇÃO DA PATCH GERAL - 
//                  TÓPICO 31 - TRATATIVA DO BANCO DE CONHECIMENTO   
//-----------------------------------------------------------------------------------//
//FR - 27/09/2022 - CIMENTOS ITAMBÉ GRAVAÇÃO DE IMPOSTOS PARA CTE
//-----------------------------------------------------------------------------------//
//FR - 21/12/2022 - BRASMOLDE - DESENVOLVIMENTO DE NOTIFICAÇÕES POR EMAIL
//                  QUANDO DO DOWNLOAD DE XML;
//                  QUANDO GERAR A PRÉ-NOTA;
//                  QUANDO CLASSIFICAR A NOTA
//                  A NOTIFICAÇÃO SERÁ ENVIADA QDO OS PARÂMETROS:  
//                  XM_MAIL10, XM_MAIL11, XM_MAIL12 ESTIVEREM PREENCHIDOS
//-----------------------------------------------------------------------------------//
//FR - 30/12/2022 - KIM PÃES - CHAMADO #000014229 - TRATAR GRAVAÇÃO DO CAMPO 
//                  ZBT_DEPARA (CÓDIGO INTERNO PRODUTO SB1) QDO DO DOWNLOAD DO XML
//                  NO MOMENTO DA GRAVAÇÃO DOS ITENS DO XML NA TABELA ZBT
//-----------------------------------------------------------------------------------//
/*/

User Function HFXML02(cCodeOne,lOk)

Local aArea     := GetArea()
Local lRetorno  := .T.
Local nVezes    := 0
Local cCloud	:=	GetNewPar("XM_CLOUD" ,"0")         //aCombo (0=Desbilitado 1=Habilitado)

Private lBtnFiltro:= .F.

Default cCodeOne := ""
Default lOk := .F.

Static USANFE := AllTrim(GetNewPar("XM_USANFE","S")) $ "S "
Static USACTE := AllTrim(GetNewPar("XM_USACTE","S")) $ "S "
Static USANFCE:= AllTrim(GetNewPar("XM_USANFCE","S")) $ "S "
Static lUnix  := IsSrvUnix()
Static cBarra := Iif(lUnix,"/","\")
Static cIdEnt := ""
Static cURL   := PadR(GetNewPar("XM_URL",""),250)

if GetNewPar("XM_DFE","0") $ "0,1"

	if cCloud <> "1"
	
		cIdEnt := U_GetIdEnt()

		cURL   := PadR(GetNewPar("XM_URL",""),250)

		If Empty(cURL)

			cURL := PadR(GetNewPar("MV_SPEDURL","http://"),250)

		EndIf

	else

		cIdEnt := ""
		
	endif

else
	
	cUrl := ""
	
endif

If cCodeOne <> "HF351058875875878XSSD7XVXVUETVEIIIQPQNZZ6574883AJJANI00983881FFDHSEJJSNW" .Or. !lOk
	
	Aviso("Aviso", "Uso incorreto da rotina."+CRLF+"Entrar em contato com a HFConsulting.",{"OK"},3)
	
	Return(Nil)
	
EndIf

While lRetorno

	lBtnFiltro:= .F.
	lRetorno := HFXML02A(nVezes==0)
	nVezes++
	
	If !lBtnFiltro
	
		Exit
		
	EndIf
	
EndDo

RestArea(aArea)

Return(Nil)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HFXML02A  º Autor ³ Roberto Souza      º Data ³  12/09/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Montagem do browse principal de importação de arquivos     º±±
±±º          ³ XML de Fornecedores.                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ IMPORTA XML                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function HFXML02A(lInit,cAlias)

//Local aPerg     := {}
Local lRetorno  := .T.
//Local aIndArq   := {}
//Local aFilPar   := {}
Local cExprFilTop
Local cHFTopFun
Local cHFBotFun
Local aCoors  		:= FWGetDialogSize( oMainWnd )
Local cIdBrowse
Local cIdGridDwn
Local oPanelUp
Local oTela
Local cIdGridMid
Local oPanelDown
Local oPanelMid											//FR - 12/11/2019 - painel midrmserdle => posicionado entre os dois painéis existentes
Local nDpClk := 4, aAuxRot := U_HFMENU()
Local lEnergia    := .F.								//FR - 18/08/2020 - Verifica se há XML de Energia
Local cClatTipos  := ""									//FR - 22/09/2020
Local oProcess	  :=	Nil								//FR - 30/09/2020
Local cCloud	  :=	GetNewPar("XM_CLOUD" ,"0")         //aCombo (0=Desbilitado 1=Habilitado)

Private oDlgPrinc
Private oBrowseUp
Private oBrowseMid										//FR - 12/11/2019 - Browse middle => posicionado entre os dois browses existentes
Private oBrowseDwn
Private nFormNfe  := Val(GetNewPar("XM_FORMNFE","9"))
Private nFormCte  := Val(GetNewPar("XM_FORMCTE","9"))
Private nFormSer  := Val(GetNewPar("XM_FORMSER","0"))   ///Incluido 19/01/2016
Private cCondicao := ""
Private bFiltraBrw
Private aFilBrw   := {}
Private cCadastro := iif(GetNewPar("XM_DFE","0") $ "0,1",iif(cCloud <> "1","GESTAO XML - Entidade : "+cIdEnt,"GESTAO XML"),"GESTAO XML")	  
Private cString   := xZBZ
Private cAtuManif := GetNewPar("XM_ATUMANF" , "N")

SetKEY( VK_F3 , {|| U_HFXML02V()})
SetKEY( VK_F1 , {|| U_HFXMLHLP()})

//---------------------------------------------------------------//
//FR - 22/09/2020 - verificar se há configuração para NF Energia
//---------------------------------------------------------------//
cClatTipos := GetNewPar("XM_CLATPNF","N")

If cClatTipos $ "E/T"		//Se definido que o tipo é Energia ou Todos
	lEnergia := .T.
Elseif cClatTipos $ "C/N"
	lEnergia := .F.
Endif

If lEnergia
	lEnergia := U_fVerXMLEnerg( , , ,.T.,oProcess)  //U_fVerXMLEnerg(lTemPC,aCab,aIte,lSoCheck)  //FR - 18/08/2020 - Aqui a verificação é para saber se há XMLs de Energia, finalidade: montar legenda
Endif

//FR - 22/09/2020
If cTipBrw == "1"  //Antigo, Apenas um Browse, somente do XML NFe.

	if cFilUsu == "S"
	
		HfFiltra( @cExprFilTop, @cHFTopFun, @cHFBotFun )
		
	endif

	if lSetParam
	
		SetKEY( VK_F12 , {|| U_HFXML04()})
		
	endif

	//aRotina := U_HFMENU()  // foi la pro HFXML01   MenuDef()

	nDpClk := aScan( aRotina, {|x| AllTrim(x[2]) == "U_HFVISU" } )
	
	if nDpClk <= 0
	
		nDpClk := 4
		
	endif

	MBrowse( 6,1,22,75,cString,,,,,nDpClk,aCores,      ,         ,/*nFreeze*/,/*bParBloco*/,/*lNoTopFilter*/,.F.,iif(cFilUsu == "S",.F.,.T.), , ,  )  // 5, {|| U_HFFRESH() }

	if lSetParam
	
		SetKEY( VK_F12 , Nil )
		
	EndIf

Else

	//==========================//
	//NOVO, Três Browses:       //
	// XML NFe;                 //
	// Itens da NFe;            //
	// Eventos CCe.             //
	//==========================//

	nDpClk := aScan( aAuxRot, {|x| AllTrim(x[2]) == "U_HFVISU" } )
	
	if nDpClk <= 0
	
		nDpClk := 4
		
	endif

	Define MsDialog oDlgPrinc Title OemToAnsi(cCadastro) From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] OF oMainWnd Pixel

	// Cria o conteiner onde serão colocados os paineis
	oTela     := FWFormContainer():New( oDlgPrinc )

	If cTipBrw = "2"			//dois browses
	
		cIdBrowse := oTela:CreateHorizontalBox( 60 )    //browse superior do xml importado (ZBZ)  	//FR 12/11/19
		cIdGridDwn:= oTela:CreateHorizontalBox( 35 )    //browse inferior carta de correção e eventos (ZBE)	//FR - 12/11/19

	Elseif cTipBrw = "3"		//três browses
	
		//FR - 12/11/19 - incluído mais um browse, relacionando com os itens da NF, totalizando 3 browses na tela dialog
		//a soma abaixo precisa ser menor igual a 95:
		cIdBrowse := oTela:CreateHorizontalBox( 35 )    //browse superior do xml importado (ZBZ)  	//FR 12/11/19
		cIdGridMid:= oTela:CreateHorizontalBox( 35 )	//browse meio, itens da NF (ZBT)			//FR - 12/11/2019 - grid dos itens do pedido
		cIdGridDwn:= oTela:CreateHorizontalBox( 25 )    //browse inferior carta de correção e eventos (ZBE)	//FR - 12/11/19
	
	Endif

	oTela:Activate( oDlgPrinc, .F. )

	//Cria os paineis onde serao colocados os browses
	oPanelUp  	:= oTela:GeTPanel( cIdBrowse  )

	If cTipBrw = "3"
	
		oPanelMid   := oTela:GetPanel( cIdGridMid )
		
	Endif
	
	oPanelDown  := oTela:GeTPanel( cIdGridDwn )

	//=========================//
	// FWmBrowse Superior: XML //
	//=========================//
	oBrowseUp:= FWmBrowse():New()
	oBrowseUp:SetOwner( oPanelUp )
	oBrowseUp:SetDescription( OemToAnsi("GESTAO XML") )
	oBrowseUp:SetAlias( xZBZ )
	oBrowseUp:SetMenuDef( 'HFXML01' )
	oBrowseUp:ForceQuitButton()					//sempre que existem dois menudefs na tela, deve-se indicar em qual browse vai ficar o botao 'Sair'
	oBrowseUp:DisableDetails()
	oBrowseUp:SetProfileID( '1' )
	oBrowseUp:SetCacheView (.F.)
	
	If cFilUsu == "S"
	
		oBrowseUp:ExecuteFilter(.T.)
		oBrowseUp:SetChgAll(.F.)
		oBrowseUp:SetSeeAll(.F.)
		//oBrowseUp:SetFilterDefault(cExprFilTop)
		
	Endif
	
	oBrowseUp:SetExecuteDef( nDpClk )

	//Adicionando a primeira legenda
	oBrowseUp:AddLegend( xZBZ+"->"+xZBZ_+"INDRUR > '0' .AND. "+xZBZ+"->"+xZBZ_+"PROTC == Space(15)"									, 'HGREEN'  	, OemToAnsi("Produtor Rural") 					,'1' )
	oBrowseUp:AddLegend( xZBZ+"->"+xZBZ_+"PRENF == 'N' .AND. "+xZBZ+"->"+xZBZ_+"PROTC == Space(15) .AND.  Empty("+xZBZ_+"COMBUS"+")", 'RED'			, OemToAnsi("Pré-Nota Classificada")			,'1' )
	oBrowseUp:AddLegend( xZBZ+"->"+xZBZ_+"PRENF == 'B' .AND. "+xZBZ+"->"+xZBZ_+"PROTC == Space(15) .AND. !Empty("+xZBZ_+"COMBUS"+")", 'GRAY'		, OemToAnsi("XML Especial Importado") 			,'1' )
	oBrowseUp:AddLegend( xZBZ+"->"+xZBZ_+"PRENF == 'N' .AND. "+xZBZ+"->"+xZBZ_+"PROTC == Space(15) .AND. !Empty("+xZBZ_+"COMBUS"+")", 'PINK'		, OemToAnsi("Pré-Nota Especial Classificada")	,'1' )
	oBrowseUp:AddLegend( xZBZ+"->"+xZBZ_+"PRENF == 'B' .AND. "+xZBZ+"->"+xZBZ_+"PROTC == Space(15) .AND. "+xZBZ_+"TPDOWL == 'R'"	, 'BROWN'		, OemToAnsi("XML Importado Resumido")			,'1' )
	oBrowseUp:AddLegend( xZBZ+"->"+xZBZ_+"PRENF == 'B' .AND. "+xZBZ+"->"+xZBZ_+"PROTC == Space(15)"									, 'BLUE'		, OemToAnsi("XML Importado")					,'1' )
	oBrowseUp:AddLegend( xZBZ+"->"+xZBZ_+"PRENF == 'Z' .AND. "+xZBZ+"->"+xZBZ_+"PROTC == Space(15)"									, 'YELLOW'		, OemToAnsi("Xml Rejeitado")					,'1' )
	oBrowseUp:AddLegend( xZBZ+"->"+xZBZ_+"PRENF == 'A' .AND. "+xZBZ+"->"+xZBZ_+"PROTC == Space(15)"									, 'ORANGE' 		, OemToAnsi("Aviso Recbto Carga")				,'1' )
	oBrowseUp:AddLegend( xZBZ+"->"+xZBZ_+"PRENF == 'S' .AND. "+xZBZ+"->"+xZBZ_+"PROTC == Space(15)"									, 'GREEN'  		, OemToAnsi("Pré-Nota a Classificar")			,'1' )
	oBrowseUp:AddLegend( xZBZ+"->"+xZBZ_+"PRENF == 'F' .AND. "+xZBZ+"->"+xZBZ_+"PROTC == Space(15)"									, 'BLACK'		, OemToAnsi("Falha de Importação")				,'1' )
	oBrowseUp:AddLegend( xZBZ+"->"+xZBZ_+"PRENF == 'X' .OR. "+xZBZ+"->"+xZBZ_+"PROTC <> ''"       									, 'WHITE'		, OemToAnsi("Xml Cancelado pelo Emissor")		,'1' )
	oBrowseUp:AddLegend( xZBZ+"->"+xZBZ_+"PRENF == 'D' .AND. "+xZBZ+"->"+xZBZ_+"PROTC == Space(15)"									, 'F12_MARR'	, OemToAnsi("Xml Denegado")						,'1' )

	If GetNewPar("XM_USASTAT" ,"N") == "S"
    	//Adicionando a segunda legenda
		oBrowseUp:AddLegend( xZBZ+"->"+xZBZ_+"MANIF=='0'"		, 'WHITE'		, OemToAnsi('Não Manifestado') 	  			,'2')
		oBrowseUp:AddLegend( xZBZ+"->"+xZBZ_+"MANIF=='1'"		, 'HGREEN'		, OemToAnsi('Confirmação da Operção')   	,'2')
		oBrowseUp:AddLegend( xZBZ+"->"+xZBZ_+"MANIF=='2'"		, 'RED'			, OemToAnsi('Operação Desconhecida') 		,'2')
		oBrowseUp:AddLegend( xZBZ+"->"+xZBZ_+"MANIF=='3'"		, 'YELLOW'		, OemToAnsi('Operação Não Realizada')  	 	,'2')
		oBrowseUp:AddLegend( xZBZ+"->"+xZBZ_+"MANIF=='4'"		, 'BLUE'		, OemToAnsi('Ciência da Operação') 			,'2')
		oBrowseUp:AddLegend( xZBZ+"->"+xZBZ_+"MANIF=='5'"		, 'GRAY'		, OemToAnsi('Manifestação CTe') 			,'2')
		oBrowseUp:AddLegend( xZBZ+"->"+xZBZ_+"MANIF=='W'"		, 'F12_MARR'	, OemToAnsi('Pendente Conf.Operação') 		,'2')
		oBrowseUp:AddLegend( xZBZ+"->"+xZBZ_+"MANIF=='X'"		, 'BROWN'		, OemToAnsi('Pendente Oper.Desconhecida') 	,'2')
		oBrowseUp:AddLegend( xZBZ+"->"+xZBZ_+"MANIF=='Y'"		, 'PINK'		, OemToAnsi('Pendente Oper.Não Realizada') 	,'2')
		oBrowseUp:AddLegend( xZBZ+"->"+xZBZ_+"MANIF=='Z'"		, 'ORANGE'		, OemToAnsi('Pendente Ciência da Operação') ,'2')	
		oBrowseUp:AddLegend( xZBZ+"->"+xZBZ_+"MANIF==' '"		, 'BLACK'		, OemToAnsi('Outros') 						,'2')	
   	EndIf


	//oBrowseUp:SetTimer( {|| U_HFFRESH( @oBrowseUp ) }, 5) VER DEPOIS

	if lSetParam
	
		oBrowseUp:SetParam( {|| U_HFXML04()} )
		
	Else
	
		oBrowseUp:SetParam( {|| } )
		
	Endif
	//Heverton ->20/10/2022
	//LUCAS SAN->21/10/2022 -> Ativar o autosize para o tamanho ficar correto.
	//GpLegMVC(@oBrowseUp)
	oBrowseUp:aColumns[1]:cTitle 		:= "Xml"
	oBrowseUp:aColumns[1]:lAutoSize		:= .T.
	//oBrowseUp:aColumns[1]:nSize			:= 20
	//oBrowseUp:aColumns[1]:nWidth		:= 20	
	oBrowseUp:aColumns[1]:blDblClick	:= {||}

	If GetNewPar("XM_USASTAT" ,"N") == "S"
		oBrowseUp:aColumns[2]:cTitle 	:= "Evento"
		oBrowseUp:aColumns[2]:lAutoSize	:= .T.
		//oBrowseUp:aColumns[2]:nSize		:= 7
		//oBrowseUp:aColumns[2]:nWidth	:= 20
		oBrowseUp:aColumns[2]:blDblClick	:= {||}
	EndIf

	oBrowseUp:Activate()

	//FR - 12/11/19:
	If cTipBrw = "3"

		//=========================//
		//Browse itens do pedido   //
		//=========================//

		oBrowseMid:= FWMBrowse():New()
		oBrowseMid:SetOwner( oPanelMid )
		oBrowseMid:SetDescription( OemToAnsi("Itens da NF") )
		oBrowseMid:SetMenuDef( 'HFXML02' )
		oBrowseMid:DisableDetails()
		oBrowseMid:SetAlias( xZBT )
		oBrowseMid:SetProfileID( '2' )
		oBrowseMid:SetCacheView (.F.)
		//oBrowseDwn:ExecuteFilter(.T.)
		//oBrowseDwn:SetParam( {|| } )

		// Relacionamento entre os Paineis
		oRelacZBT:= FWBrwRelation():New()
		oRelacZBT:AddRelation( oBrowseUp  , oBrowseMid , { { xZBT+"->"+xZBT_+"CHAVE" , xZBZ+"->"+xZBZ_+"CHAVE"  } } )		
		oRelacZBT:Activate()		
		oBrowseMid:Activate()
		oBrowseMid:Refresh()

	Endif

	//----------------------------------------//
	// FWmBrowse Inferior: Eventos CCE        //
	//----------------------------------------//
	oBrowseDwn:= FWMBrowse():New()
	oBrowseDwn:SetOwner( oPanelDown )
	oBrowseDwn:SetDescription( OemToAnsi("Carta de Correções e Eventos") )
	oBrowseDwn:SetMenuDef( 'HFXML02' )
	oBrowseDwn:DisableDetails()
	oBrowseDwn:SetAlias( xZBE )
	//oBrowseDwn:SetProfileID( '2' )
	oBrowseDwn:SetProfileID( '3' )
	oBrowseDwn:SetCacheView (.F.)	
	oBrowseDwn:AddFilter('Eventos' /*cTitle*/ ,"xZBE+'->'+ Alltrim(xZBE_+'TPEVE) != 'HXL069'" /*xCondition*/)
	oBrowseDwn:ExecuteFilter(.T.)	//FR - 22/09/2020
	//oBrowseDwn:SetParam( {|| } ) 
	
	oBrowseDwn:CSETFILTER := .T.      
	oBrowseDwn:CESPFILTER := "xZBE+'->'+ Alltrim(xZBE_+'TPEVE) != 'HXL069'"
	oBrowseDwn:ExecuteFilter(.T.)
	oBrowseDwn:LSETFILTER := .T.
	/*
	oBrowseDwn:AddLegend( xZBE+"->"+xZBE_+"TPEVE=='110110'"		, 'GREEN'	, OemToAnsi('Carta de Correção') )
	oBrowseDwn:AddLegend( xZBE+"->"+xZBE_+"TPEVE=='110111'"		, 'WHITE'	, OemToAnsi('Cancelado') )
	oBrowseDwn:AddLegend( xZBE+"->"+xZBE_+"TPEVE=='210200'"		, 'ORANGE'	, OemToAnsi('Confirmação da Operção') )
	oBrowseDwn:AddLegend( xZBE+"->"+xZBE_+"TPEVE=='210210'"		, 'YELLOW'	, OemToAnsi('Ciência da Operação') )
	oBrowseDwn:AddLegend( xZBE+"->"+xZBE_+"TPEVE=='210220'"		, 'BLACK'	, OemToAnsi('Desconhecimento da operação') )
	oBrowseDwn:AddLegend( xZBE+"->"+xZBE_+"TPEVE=='210240'"		, 'RED'		, OemToAnsi('Operação não Realizada') )
	oBrowseDwn:AddLegend( xZBE+"->"+xZBE_+"TPEVE=='610110'"		, 'BLUE'	, OemToAnsi('Desacordo CTe') )
	oBrowseDwn:AddLegend( xZBE+"->"+xZBE_+"TPEVE=='HXL069'"		, 'BR_PRETO_0'	, OemToAnsi('ReDownload') )
	*/
	// Relacionamento entre os Paineis
	oRelacZBE:= FWBrwRelation():New()
	oRelacZBE:AddRelation( oBrowseUp  , oBrowseDwn , { { xZBE+"->"+xZBE_+"FILIAL", xZBZ+"->"+xZBZ_+"FILIAL" }, { xZBE+"->"+xZBE_+"CHAVE" , xZBZ+"->"+xZBZ_+"CHAVE"  } } )
	oRelacZBE:Activate()

	oBrowseDwn:Activate()

	oBrowseUp:Refresh()

	If cTipBrw = "3"
	
		oBrowseMid:Refresh()		//FR - 12/11/2019
		
	Endif

	oBrowseDwn:Refresh()

	//FR - 24/05/2022 - se o parâmetro estiver .T. , atualiza geral as manifestações para alinhar o ultimo registro da ZBE com o cabeçalho ZBZ_MANIF
	//If cAtuManif == "S"
		//U_FATUMANIF()
		//Processa( {|| U_FATUMANIF()}, "Aguarde...", "Atualizando Cabeçalho XML - Manifestações ...",.F.)
	//Endif
	//FR - 24/05/2022 - se o parâmetro estiver .T. , atualiza geral as manifestações para alinhar o ultimo registro da ZBE com o cabeçalho ZBZ_MANIF 

	Activate MsDialog oDlgPrinc Center

EndIf

SetKEY( VK_F3 ,  Nil )
SetKEY( VK_F1 ,  Nil )

lRetorno := .F.

Return(lRetorno)

//Usado para carregar a cor na Legenda 2 (ZBE na grade superior)
//Feito para criar 2 legendas na mesma grade
Static Function PosicLegend()
Local _codEven := (xZBE)->&(xZBE_+"TPEVE")

		DbSelectArea(xZBE)
		DbSetOrder(1)
		If DbSeek( &(xZBZ+"->"+xZBZ_+"FILIAL") + &(xZBZ+"->"+xZBZ_+"CHAVE")  )
	
			_codEven := (xZBE)->&(xZBE_+"TPEVE") 

		ENDIF

RETURN(_codEven)


User Function HFFRESH( oFresh )

if oFresh == NIL

	oFresh := GetObjBrow() //Obtém o ultimo Objeto Browse
	
endif

oFresh:Refresh()

Return(NIL)


//se filiais for sequencial utilizar cHFTopFun, cHFBotFun
//senão usar cExprFilTop
Static Function HfFiltra( cExprFilTop, cHFTopFun, cHFBotFun )

Local nTamEmp  := len(SM0->M0_CODIGO) + 1 //soma um para pegar a próxima posição no aUserData[2][6][nI]
Local cFiliais := ""
Local aFiliais := {}
Local aGrupos  := {}
Local aGrpData := {}
Local nFilial  := 0
Local cFil001  := ""
Local cFil002  := ""
Local lPulou := .F.
Local nI := 0
Local nX := 0

If U_IsShared(xZBZ)   //se a ZZB for compartilhada não se aplica filtro.
	Return NIL
EndIf

//ver Filiais do Usuário
If Len(aUserData) >= 2
	If len(aUserData[2]) >= 6

		If aScan( aUserData[2][6], "@@@@" ) > 0  //Todas as Filiais, não se aplica filtro
			Return NIL
		EndIf

		For nI := 1 to Len(aUserData[2][6])
			cFiliais := Substr( aUserData[2][6][nI], nTamEmp, Len(aUserData[2][6][nI]) )
			If Empty( aFiliais ) .or. aScan( aFiliais, cFiliais ) == 0
				aadd( aFiliais, cFiliais )
			EndIf
		Next nI
	EndIf

EndIf

//ver Filiais dos Grupos
If Len(aUserData) >= 1
	aGrupos := {}
	If Len(aUserData[1]) >= 10
		aGrupos := aUserData[1][10]
	EndIf

	For nX := 1 To Len( aGrupos )
		PswOrder(1)
		If PswSeek( aGrupos[nX], .F. )
			aGrpData := PswRet()
			If Len(aGrpData) >= 2
				If Len(aGrpData[2]) >= 6

					If aScan( aGrpData[2][6], "@@@@" ) > 0  //Todas as Filiais, não se aplica filtro
						Return NIL
					EndIf

					For nI := 1 to Len(aGrpData[2][6])
						cFiliais := Substr( aGrpData[2][6][nI], nTamEmp, Len(aGrpData[2][6][nI]) )
						If Empty( aFiliais ) .or. aScan( aFiliais, cFiliais ) == 0
							aadd( aFiliais, cFiliais )
						EndIf
					Next nI
				EndIf
			EndIf

		Endif
	Next

EndIf

cFiliais := ""
If .Not. Empty( aFiliais )
	aSort( aFiliais,,, {|x,y| x < y } )
	cFil001  := aFiliais[1]
	cFiliais := "'"+aFiliais[1]+"'"
	lPulou   := .F.
	For nI := 1 To Len(aFiliais)
		If nI > 1
			If (Val(aFiliais[nI]) - nFilial) > 1
				lPulou := .T.
			EndIf
			cFiliais += ",'"+aFiliais[nI]+"'"
		EndIf
		cFil002 := aFiliais[nI]
		nFilial := Val(aFiliais[nI])
	Next nI

EndIf

If lPulou  //Se tiver buraco na sequencia de Filiais utiliza cExprFilTop
	cExprFilTop := xZBZ_+"FILIAL in ("+cFiliais+")"
Else
	cTopFun   := cFil001
	cBotFun   := cFil002
	cHFTopFun := "U_HFTOPFUN"
	cHFBotFun := "U_HFBOTFUN"
EndIf

Return NIL


************************
User Function HFTopFun()
************************
Return( cTopFun )
	

************************
User Function HFBotFun()
************************

Return( cBotFun )


*************************
Static Function MenuDef()
************************

Local aMenu := {}

aadd(aMenu, {"Legenda"            ,"U_HFXML2LC"  ,0,2,0,Nil} )

Return(aMenu)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ValidaXmlAll  º Autor ³ Roberto Souza      º Data ³  12/01/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ XML dos Fornecedores referente a NF-e, CT-e                    º±±
±±º          ³                                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Importa XML                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ValidaXmlAll(cModelo,cXml,cFilename,oMessage,nInd,nOpc,lInvalid,cLogProc,cFilXml,cKeyXml,cOcorr,aFilsEmp,oXmlOk)

Local   cError    := ""
Local   cWarning  := ""
//Local   cOcorr    := ""
Local   lGrava    := .T.
Local   lAppend   := .T.
Local   lXmlCanc  := .F.
Local   cMensagem := ""
Local   cCodRet   := ""
Local   lValidado := .T.
Local   lConsulta := .T.
//Local   nModoMail := 1
//Local   cAnexo    := ""
Local   cChaveXml := ""
Local   cTipoDoc  := "N"  // Validar Tipo de DOcumento
Local   cCfopDoc  := Space(15)
Local   lContinua := .T.
Local   nHdl      := -1
//Local   xManif    := ""   //GETESB2
Local   cCodEmit  := ""   //Norsal SA2->A2_COD
Local   cLojaEmit := ""   //Norsal SA2->A2_LOJA
Local   cRazao    := ""   //Norsal SA2->A2_NOME
Local   cIndRur   := ""
Local   nVLLIQ    := 0 //campos que eram só da Nuvem
Local   nVLDESC   := 0 //campos que eram só da Nuvem
Local   nVLIMP    := 0 //campos que eram só da Nuvem
Local   nVLBRUT   := 0 //campos que eram só da Nuvem
//Local   aItXml    := {}
Local   _cFil     := ""
//Local   i         := 0
Local   lTransp   := .F.
Local   cStatus   := ""
Local   cNomFil   := ""
Local   cCloud	  :=	GetNewPar("XM_CLOUD" ,"0")         //aCombo (0=Desbilitado 1=Habilitado)
Local   cCfopC    := GetNewPar("XM_CFCOMPL","")
Local 	cOriNF	  := "" //Lucas San e Erick Gonçalves

Local cMail10 := GetNewPar("XM_MAIL10",Space(256))  //FR - 21/12/2022 - Flávia Rocha - EMAIL AVISANDO SOBRE NOVO XML GRAVADO NA BASE
Local cMail11 := GetNewPar("XM_MAIL11",Space(256))  //FR - 21/12/2022 - Flávia Rocha - EMAIL AVISANDO SOBRE NOVA PRE-NOTA

Private oXml      := NIL
//Private lSharedA1 := U_IsShared("SA1")
//Private lSharedA2 := U_IsShared("SA2")
Private nFormNfe  := Val(GetNewPar("XM_FORMNFE","6"))
Private nFormCTe  := Val(GetNewPar("XM_FORMCTE","6"))
Private nFormSer  := Val(GetNewPar("XM_FORMSER","0")) ///Incluido 19/01/2016
Private nFormXML  := 6
Private lForceT3  := AllTrim(GetNewPar("XM_FORCET3","N")) <> "N"
Private cT3       := AllTrim(GetNewPar("XM_FORCET3","N"))
Private cPref     := ""
Private cTag      := ""
Private cTgP      := ""
Private cTagTpEmiss:= ""
Private cTagTpAmb  := ""
Private cTagCHId   := ""
Private cTagSign   := ""
Private cTagProt   := ""
Private cTagKey    := ""
Private cTagDocEmit:= ""
Private cTagDocXMl := ""
Private cTagSerXml := ""
Private cTagDtEmit := ""
Private cTagDocDest:= "", cTagTpPag := ""  //GETESB
Private cTagIEDest := ""
Private cTagFinNfe := "" //Adar
Private cTagVerXml := ""
Private cTagVCarga := ""
Private cTipoToma  := ""
Private cDtHrCOns  := ""
Private cVerXml    := ""
Private cVerNFE    := "2.00|2.01|3.10|4.00"
Private cVerCTE    := "1.03|1.04|1.05|2.00|3.00|4.00" /*Incremento 3.00 , para CT-e 3.00 - data 06/02/2017*/ /*Incremento versão 4.00 HMS 06/07/2023*/
Private cMsgCanc   := ""
Private cMsgErr    := ""
Private lConsErr   := .F.
Private cTagUfDest 	:= ""
Private cTagTpCte	:= "" //acrecentando tag <tpCTE>, pois no protheus o campo esta obrigatório. Alexandro 23/12/2016.
Private cUfDest   	:= ""
Private cTpCte		:= "" //acrecentando variavel para receber TagTpCte,campo esta obrigatório. Alexandro 26/12/2016.
Private lTransf		:= .F.//Incluso melhoria ECOURBIS - Analista Alexandro
Private cFinalidad	:= ""
Private nVlCarga    := 0  //Acrescentado variavel para melhoria Belenzier pneus valor total da carga 
Private xMunIni     := ""	//FR - 04/06/2020 - Projeto CCM - Tratativa para Cte para gravar campo origem prestação de serviço (Município - UF)
Private xUFIni		:= ""	//FR - 04/06/2020 - Projeto CCM - Tratativa para Cte para gravar campo origem prestação de serviço (Município - UF)
Private cTagDocToma := ""
Private cDocToma    := ""
//Private xZBZ  	    := GetNewPar("XM_TABXML","ZBZ")      //ECOOOOOOOOOO
//Private xZBZ_ 	    := iif(Substr(xZBZ,1,1)=="S", Substr(xZBZ,2,2), Substr(xZBZ,1,3)) + "_" 

Private lGravSA2 := .F.								//FR - 28/10/2021 - indica se gravou automaticamente SA2  
Private cAutoSA2 := GetNewPar("XM_SA2AUTO","N")   //FR - 28/10/2021 - indica se automatiza o cadastro do fornecedor na SA2 Sim ou Não na classificaçao da nf
Private cAutoSA2D:= GetNewPar("XM_SA2AUTD","N")   //FR - 21/12/2021 - habilita cadastro automático do fornecedor no download do xml
Private xChave   := ""								//FR - 29/12/2022 - BRASMOLDE - NOTIFICAÇÕES POR EMAIL
Default nOpc    := 1
Default lInvalid:= .F.
Default cLogProc:= ""
Default cURL    := AllTrim(GetNewPar("XM_URL",""))
Default cOcorr  := ""

if GetNewPar("XM_DFE","0") $ "0,1"

	if cCloud <> "1"
	
		cIdEnt := U_GetIdEnt()

		cURL   := PadR(GetNewPar("XM_URL",""),250)

		If Empty(cURL)

			cURL := PadR(GetNewPar("MV_SPEDURL","http://"),250)

		EndIf

	else

		cIdEnt := ""
		cUrl := ""
		
	endif

else
	
	cUrl := ""
	
endif

If cModelo $ "55,65"

	If cModelo == "55"
		cPref    := "NF-e"
	Else
		cPref    := "NFC-e"
	EndIf

	cTAG     := "NFE"
	cTGP     := "NFE"
	nFormXML := nFormNfe
	cVerOk   := cVerNFE

	cTagUfDest := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_CUF:TEXT" //"oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_DEST:_ENDERDEST:_UF:TEXT"
 
	if type(cTagUfDest) != "U" 
		cTagUfDest := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_EMIT:_ENDEREMIT:_UF:TEXT"  //Como aqui pode não ter dest pegar Emit
	EndIf

	if type(cTagUfDest) == "U" .And. cModelo == "65"
		cTagUfDest := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_EMIT:_ENDEREMIT:_UF:TEXT"  //Como aqui pode não ter dest pegar Emit
	EndIf

	If cModelo $ "55"
		cTagFinNfe := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_FINNFE:TEXT"
	endif

ElseIf cModelo == "57"

	cPref    	:= "CT-e"
	cTAG     	:= "CTE"
	cTGP        := "CTE"
	nFormXML 	:= nFormCte
	cVerOk   	:= cVerCTE
	cTagUfDest 	:= 	"oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_CUF:TEXT"  //"oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_DEST:_ENDERDEST:_UF:TEXT"
	cTagTpCte	:=	"oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_TP"+cTAG+":TEXT" //Criando a Tag <tpCTE> obrigatorio Alexandro - 23/12/2016

ElseIf cModelo == "67"

	cPref    	:= "CT-eOS"
	cTAG     	:= "CTE"
	cTGP        := "CTEOS"
	nFormXML 	:= nFormCte
	cVerOk   	:= cVerCTE
	cTagUfDest 	:= 	"oXml:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_IDE:_CUF:TEXT"//"oXml:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_TOMA:_ENDERTOMA:_UF:TEXT"
	cTagTpCte	:=	"oXml:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_IDE:_TP"+cTAG+":TEXT" //Criando a Tag <tpCTE> obrigatorio Alexandro - 23/12/2016

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Validação da estrutura do XML.       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ValidXml(@cXml,@cOcorr,@lInvalid,@cModelo)
If oXmlOk <> nil

	oXml  := oXmlOk

Else

	oXml := XmlParser( cXml, "_", @cError, @cWarning )

	if Empty( oXml )

		//Faz backup do xml sem retirar os caracteres especiais
		cBkpXml := cXml

		cXml := EncodeUTF8(cXml)
		cXml := FwNoAccent(cXml)

		//Executa rotina para retirar os caracteres especiais
		cXml := u_zCarEspec( cXml )

		oXml := XmlParser( cXml, "_", @cError, @cWarning )

		//retorna o backup do xml
		cXml := cBkpXml

	endif

EndIf

If Empty(cError) .And. Empty(cWarning) .And. !lInvalid .And. oXml <> Nil

	cTagTpEmiss:= "oXml:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_IDE:_TPEMIS:TEXT"
	cTagTpAmb  := "oXml:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_IDE:_TPAMB:TEXT"
	cTagCHId   := "oXml:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_ID:TEXT"		
	cTagSign   := "oXml:_"+cTGP+"PROC:_"+cTGP+":_SIGNATURE"
	cTagProt   := "oXml:_"+cTGP+"PROC:_PROT"+cTAG+":_INFPROT:_NPROT:TEXT"
	cTagKey    := "oXml:_"+cTGP+"PROC:_PROT"+cTAG+":_INFPROT:_CH"+cTAG+":TEXT"
	cTagStatus := "oXml:_"+cTGP+"PROC:_PROT"+cTAG+":_INFPROT:_CSTAT:TEXT"

	/* Inclusão da tag CPF empresa Bela Ischa 20/09/2016 */
	If Type("oXml:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_EMIT:_CNPJ:TEXT") == "U"
		cTagDocEmit:= "oXml:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_EMIT:_CPF:TEXT"
	Else
		cTagDocEmit:= "oXml:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_EMIT:_CNPJ:TEXT"
	EndIf
	/* Fim */

	If Type("oXml:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_IDE:_N"+Left(cTAG,2)+":TEXT") <> "U"
		cTagDocXMl := "oXml:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_IDE:_N"+Left(cTAG,2)+":TEXT"
	else
		cTagDocXMl := ""
	endif

	If Type("oXml:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_IDE:_SERIE:TEXT") <> "U"
		cTagSerXml := "oXml:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_IDE:_SERIE:TEXT"
	else
		cTagSerXml := ""
	endif

	cFinalidad := ""

	if Type( cTagFinNfe ) <> "U" 

		If !Empty(cTagFinNfe) //.and. Type("cTagFinNfe") <> "U"   //Adar
			cFinalidad := &(cTagFinNfe)  //Finalidade 2-Complemento
		Endif

	endif

	cTagVerXml := "oXml:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_VERSAO:TEXT"

	If Type(cTagVerXml) <> "U"

		cVerXml := &(cTagVerXml)

		If !cVerXml $ cVerOk

			cError += "Versão de XML não suportada : "+cVerXml+" ."+CRLF
			cError += "Arquivo : "+cFilename+" "
			cLogProc += "Arquivo : "+cFilename+" "+"Versão de XML não suportada : "+cVerXml+" ."+CRLF
			lInvalid := .T.
			lContinua := .F.
			lGrava := .F.

			If Type(cTagProt)== "U" .Or. Empty(&(cTagProt))

				cProtocolo := ""
				cChaveXml  := Substr(&(cTagCHId),4,44)

			Else

				cProtocolo := &(cTagProt)
				cChaveXml  := &(cTagKey)
				cStatus    := &(cTagStatus)

			EndIf

		EndIf

	Else

		cError += "Estrutura XML não suportado."+CRLF
		cError += "Arquivo : "+cFilename+" "
		cLogProc += "Arquivo : "+cFilename+" "+"Estrutura XML não suportado."+CRLF
		lInvalid  := .T.
		lContinua := .F.
		lGrava := .F.

		If Type(cTagProt)== "U" .Or. Empty(&(cTagProt))

			cProtocolo := ""
			cChaveXml  := ""

		Else

			cProtocolo := &(cTagProt)
			cChaveXml  := ""

		EndIf

	EndIf

	If lContinua

		if type(cTagUfDest) != "U"
			cUfDest := RetUFide( &(cTagUfDest) ) //&(cTagUfDest)	
		endif

		/* acrecentando tag <tpCTE>, pois no protheus o campo esta obrigatório. Alexandro 26/12/2016. */
		if type(cTagTpCte) != "U"
			cTpCte := &(cTagTpCte)
		endif
		/* Fim desta inclusão */

		//TRATAMENTO IMPOSTOS - AUDITORIA
		nBASCAL := nICMVAL := nICMDES := nSTBASE := nSTVALO := nIPIVAL := nIPIDEV := 0
		nPISVAL := nCOFVAL := nOUTVAL := 0
		cTagAux := ""

		If cModelo $ "55,65"

			cTagDtEmit := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_DEMI:TEXT"

			if type(cTagDtEmit) == "U"
				cTagDtEmit := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_DHEMI:TEXT"
			endif

			cTagDocDest:= "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_DEST:_CNPJ:TEXT"

			if type(cTagDocDest) == "U" .And. cModelo == "65"   // NFCE pode ser um CPF, mas a empresa normalmente é CNPJ, mas vai que..
				cTagDocDest:= "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_DEST:_CPF:TEXT"
			endif

			cTagIEDest := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_DEST:_IE:TEXT"


			cTagAux := ("oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_TOTAL:_ICMSTOT:_VBC:TEXT")
			If type( cTagAux ) <> "U"
				nBASCAL := val(&cTagAux)
			Endif
			
			cTagAux := ("oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_TOTAL:_ICMSTOT:_VICMS:TEXT")
			If type( cTagAux ) <> "U"
				nICMVAL := val(&cTagAux)
			Endif
			
			cTagAux := ("oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_TOTAL:_ICMSTOT:_VICMSDESON:TEXT")
			If type( cTagAux ) <> "U"
				nICMDES := val(&cTagAux)
			Endif

			cTagAux := ("oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_TOTAL:_ICMSTOT:_VBCST:TEXT")
			If type( cTagAux ) <> "U"
				nSTBASE := val(&cTagAux)
			Endif
			
			cTagAux := ("oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_TOTAL:_ICMSTOT:_VST:TEXT")
			If type( cTagAux ) <> "U"
				nSTVALO := val(&cTagAux)
			Endif

			cTagAux := ("oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_TOTAL:_ICMSTOT:_VIPI:TEXT")
			If type( cTagAux ) <> "U"
				nIPIVAL := val(&cTagAux)
			Endif

			cTagAux := ("oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_TOTAL:_ICMSTOT:_VIPIDEVOL:TEXT")
			If type( cTagAux ) <> "U"
				nIPIDEV := val(&cTagAux)
			Endif
			 
			cTagAux := ("oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_TOTAL:_ICMSTOT:_VPIS:TEXT")
			If type( cTagAux ) <> "U"
				nPISVAL := val(&cTagAux)
			Endif

			cTagAux := ("oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_TOTAL:_ICMSTOT:_VCOFINS:TEXT")
			If type( cTagAux ) <> "U"
				nCOFVAL := val(&cTagAux)
			Endif
		
			cTagAux := ("oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_TOTAL:_ICMSTOT:_VOUTRO:TEXT")
			If type( cTagAux ) <> "U"
				nOUTVAL := val(&cTagAux)
			Endif
/*
				nBASCAL := val("oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_TOTAL:_ICMSTOT:_VBC:TEXT")
				nICMVAL := val("oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_TOTAL:_ICMSTOT:_VICMS:TEXT")
				nICMDES := val("oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_TOTAL:_ICMSTOT:_VICMSDESON:TEXT")
				nSTBASE := val("oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_TOTAL:_ICMSTOT:_VBCST:TEXT")
				nSTVALO := val("oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_TOTAL:_ICMSTOT:_VST:TEXT")
				nIPIVAL := val("oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_TOTAL:_ICMSTOT:_VIPI:TEXT")
				nIPIDEV := val("oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_TOTAL:_ICMSTOT:_VIPIDEVOL:TEXT")
				nPISVAL := val("oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_TOTAL:_ICMSTOT:_VPIS:TEXT")
				nCOFVAL := val("oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_TOTAL:_ICMSTOT:_VCOFINS:TEXT")
				nOUTVAL := val("oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_TOTAL:_ICMSTOT:_VOUTRO:TEXT")
*/


			//-------------------------------------------------------------
		ElSeIf cModelo == "57"
			/*
			0-Remetente;
			1-Expedidor;
			2-Recebedor;
			3-Destinatário
			*/
			cTagDtEmit := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_DHEMI:TEXT"
			cTagTpPag  := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_FORPAG:TEXT"

			If Type("oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_TOMA03:_TOMA:TEXT") <> "U"
				cTagToma := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_TOMA03:_TOMA:TEXT"
			ElseIf Type("oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_TOMA4:_TOMA:TEXT") <> "U"
				cTagToma := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_TOMA4:_TOMA:TEXT"
			ElseIf Type("oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_TOMA3:_TOMA:TEXT") <> "U"  /*Incluindo este else, pois a tag esta vindo toma3, implementando versao CT-e 3.00 - data 06/02/2017*/
				cTagToma := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_TOMA3:_TOMA:TEXT"
			EndIf

			If cT3 $ "0123"
				cTipoToma  := cT3
			Else
				cTipoToma  := &(cTagToma)
			EndIf

			Do Case

				Case cTipoToma == "0"
					cTagDocDest := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_REM:_CNPJ:TEXT"
					cTagIEDest  := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_REM:_IE:TEXT"
				Case cTipoToma == "1"
					cTagDocDest := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_EXPED:_CNPJ:TEXT"
					cTagIEDest  := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_EXPED:_IE:TEXT"
				Case cTipoToma == "2"
					cTagDocDest := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_RECEB:_CNPJ:TEXT"
					cTagIEDest  := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_RECEB:_IE:TEXT"
				Case cTipoToma == "3"
					cTagDocDest := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_DEST:_CNPJ:TEXT"
					cTagIEDest  := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_DEST:_IE:TEXT"
				Case cTipoToma == "4"
					cTagDocDest := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_TOMA4:_CNPJ:TEXT"
					if type(cTagDocDest) == "U"
						cTagDocDest:= "oXml:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_TOMA4:_CPF:TEXT"
					endif
					cTagIEDest  := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_TOMA4:_IE:TEXT"
				OtherWise
					cTagDocDest := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_REM:_CNPJ:TEXT"
					cTagIEDest  := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_REM:_IE:TEXT"
			EndCase

			//Adiciona a Tag Tomador - 19/11/2020 - Rogerio Lino
			cTagDocToma := cTagDocDest

			If Type(cTagDocToma)<>"U"
				cDocToma := &(cTagDocToma)
			Endif

			//FR - 27/09/2022 - CIMENTOS ITAMBÉ GRAVAÇÃO DE IMPOSTOS PARA CTE
			cTagAux := ("oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IMP:_ICMS:_ICMS00:_VBC:TEXT")
			If type( cTagAux ) <> "U" //FR - 13/10/2022 - alguns CTes não estavam gravando o imposto - CIMENTOS ITAMBÉ
				nBASCAL := val(&cTagAux) //BASE CÁLCULO ICM
			Endif
			
			cTagAux := ("oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IMP:_ICMS:_ICMS00:_VICMS:TEXT")
			If type( cTagAux ) <> "U"	//FR - 13/10/2022 - alguns CTes não estavam gravando o imposto - CIMENTOS ITAMBÉ
				nICMVAL := val(&cTagAux) //VALOR ICM
			Endif
			//FR - 27/09/2022 - CIMENTOS ITAMBÉ GRAVAÇÃO DE IMPOSTOS PARA CTE
		ElseIf cModelo == "67"

			cTagTpPag  := "oXml:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_IDE:_FORPAG:TEXT"
			cTagDtEmit := "oXml:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_IDE:_DEMI:TEXT"

			if type(cTagDtEmit) == "U"
				cTagDtEmit := "oXml:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_IDE:_DHEMI:TEXT"
			endif

			cTagDocDest:= "oXml:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_TOMA:_CNPJ:TEXT"

			if type(cTagDocDest) == "U"
				cTagDocDest:= "oXml:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_TOMA:_CPF:TEXT"
			endif

			cTagIEDest := "oXml:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_TOMA:_IE:TEXT"

		Else

			cTagDtEmit := ""
			cTagDocDest:= ""
			cTagIEDest := ""

		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Validação Assinatura Digital.        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Type(cTagSign)== "U"

			cError += "O XML "+cFilename+" não possui Assinatura Digital."
			lContinua := .F.

			If !lXmlCanc
				lGrava := .T.
			EndIf

		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Validação Protocolo.                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Type(cTagProt)== "U" .Or. Empty(&(cTagProt))

			cError += "O XML "+cFilename+" não possui Protocolo de Autorização."
			lContinua := .T.
			lGrava := .T.
			cProtocolo := ""
			If cTGP == "NFE" .or. cTAG == "NFE"  					//FR - 17/02/2022 - no xml fornecido pela Cimentos Itambé, esta tag era formato array, por isso ocorria erro log
				If ValType(oXml:_NFEPROC:_NFE:_INFNFE:_ID) == "A"   //Verificação se o objeto é array
					cChaveXml := Substr(oXml:_NFEPROC:_NFE:_INFNFE:_ID[1]:TEXT,4,44) 
				Else
					cChaveXml  := Substr(&(cTagCHId),4,44)
				Endif 
			
			Else
				cChaveXml  := Substr(&(cTagCHId),4,44)
			Endif

		Else

			cProtocolo := &(cTagProt)
			cChaveXml  := &(cTagKey)
			cStatus    := &(cTagStatus)

			If Empty(cChaveXml)
				cChaveXml  := Substr(&(cTagCHId),4,44)
			EndIf

		EndIf

		//Incluido pelo Analista Alexandro, pois a variavel esta vazia.
		If Empty(cChaveXml)

			cError += "Este XML não possui a chave favor verificar com Fornecedor. A importação será Cancelada."+CRLF
			cLogProc += "[XML] não possui a chave favor verificar com Fornecedor. " +cFilename +CRLF
			lGrava := .F.
			lContinua := .F.

		Else

			DbSelectArea(xZBZ)
			DbSetOrder(3)
			If DbSeek(alltrim(cChaveXml))

				If (xZBZ)->&(xZBZ_+"STATUS") == "1" .And. (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOWL")))<>"R" .and. cStatus <> "101"

					//cError += "Este XML já esta na Base de Dados. A importação será Cancelada."+CRLF  //para não ficar lotando a caixa.
					cLogProc += "[XML] XML já consta na Base de Dados. " +cFilename +CRLF
					lGrava := .F.
					lContinua := .F.

				Else

					lGrava := .T.
					lAppend:= .F.

				EndIf

			EndIf

		EndIf

		lTransf  := .F.  //Incluso melhoria ECOURBIS - Analista Alexandro / Eneo
		cTipoDoc := U_RetTpNf(cModelo, oXml, @lTransf, cFinalidad, @cCfopDoc) //Incluso melhoria ECOURBIS - Analista Alexandro / Eneo

		S_XML := cXml

		cDocXMl := Iif(nFormXML > 0,StrZero(Val(&(cTagDocXMl)),nFormXML),&(cTagDocXMl))

		if !Empty(cTagSerXml)
			cSerXml := &(cTagSerXml)
		else
			cSerXml := ""
		endif

		//Alteração para ITAMBÉ 15/10/2014 - Alexandro de Oliveira
		Do Case
		Case ( GetNewPar("XM_SERXML","N") == "S" )

			if alltrim( cSerXml ) == '0' .or. alltrim( cSerXml ) == '00' .or. alltrim( cSerXml ) == '000'
				cSerXml := '   '
			EndIf

		Case ( GetNewPar("XM_SERXML","N") == "Z" )

			If Empty(cSerXml)
				cSerXml := '0'
			Endif

		Case ( GetNewPar("XM_SERXML","N") == "P" )

			cSerXml := Padl(cSerXml,nFormSer,"0")   //Padl(cSerXml,Tamsx3("D1_SERIE")[1],"0")

		EndCase

		cCnpjEmi  := &(cTagDocEmit)
		cDtEmit   := &(cTagDtEmit)
		dDataEntr := StoD(substr(cDtEmit,1,4)+Substr(cDtEmit,6,2)+Substr(cDtEmit,9,2))

		cFilXMLAtu := cFilAnt
		cFilNova   := ""
		cDocDest   := ""
		cIEDest    := ""

		if cModelo <> "65"

			If Type(cTagDocDest)<>"U"
				cDocDest := &(cTagDocDest)
			Else
				lGrava := .F.
				lInvalid := .T.
				cOcorr := "Documento emitido sem CNPJ/CPF de destinatário."
			EndIf

		endif

		If Type(cTagIEDest)<>"U"
			cIEDest := &(cTagIEDest)
		EndIf

		nFilScan := aScan(aFilsEmp,{|x| x[2] == cDocDest .and. AllTrim(x[5]) == AllTrim( cIEDest ) })

		If nFilScan == 0
			//nFilScan := aScan(aFilsEmp,{|x| x[2] == cDocDest })    
			nFilScan := aScan(aFilsEmp,{|x| Alltrim(x[2]) == Alltrim(cDocDest)  }) //FR - 29/10/2020
		EndIf

		If nFilScan == 0
			If aScan(aFilsLic,{|x| x[2] == cDocDest }) > 0
				lXmlsLic := .T.
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Tratamento para consistencia na tag TOMA3.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nFilScan == 0 .And. cModelo == "57" .And. lForceT3

			lCont := .T.

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Busca no Toma 4 Primeiro, depois verifica os outros.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nFilScan == 0

				cTagDocDest:= "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_TOMA4:_CNPJ:TEXT"
				cTagIEDest := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_TOMA4:_IE:TEXT"

				If Type(cTagIEDest)<>"U"
					cIEDest := &(cTagIEDest)
				Else
					cIEDest := ""
				EndIf

				If Type(cTagDocDest)<>"U"

					cDocDest := &(cTagDocDest)
					nFilScan := aScan(aFilsEmp,{|x| x[2] == cDocDest .and. AllTrim(x[5]) == AllTrim( cIEDest ) })

					if nFilScan == 0
						nFilScan := aScan(aFilsEmp,{|x| x[2] == cDocDest })
					endIf

					If nFilScan == 0
						If aScan(aFilsLic,{|x| x[2] == cDocDest }) > 0
							lXmlsLic := .T.
						EndIf
					EndIf

				Else

					cDocDest := ""

				EndIf

			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Busca no REMETENTE.                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nFilScan == 0

				cTagDocDest:= "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_REM:_CNPJ:TEXT"
				cTagIEDest := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_REM:_IE:TEXT"

				If Type(cTagIEDest)<>"U"
					cIEDest := &(cTagIEDest)
				Else
					cIEDest := ""
				EndIf

				If Type(cTagDocDest)<>"U"

					cDocDest := &(cTagDocDest)
					nFilScan := aScan(aFilsEmp,{|x| x[2] == cDocDest .and. AllTrim(x[5]) == AllTrim( cIEDest ) })

					if nFilScan == 0
						nFilScan := aScan(aFilsEmp,{|x| x[2] == cDocDest })
					endIf

					If nFilScan == 0
						If aScan(aFilsLic,{|x| x[2] == cDocDest }) > 0
							lXmlsLic := .T.
						EndIf
					EndIf

				Else

					cDocDest := ""

				EndIf

			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Busca no EXPEDIDOR.                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nFilScan == 0

				cTagDocDest:= "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_EXPED:_CNPJ:TEXT"
				cTagIEDest := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_EXPED:_IE:TEXT"

				If Type(cTagIEDest)<>"U"
					cIEDest := &(cTagIEDest)
				Else
					cIEDest := ""
				EndIf

				If Type(cTagDocDest)<>"U"

					cDocDest := &(cTagDocDest)
					nFilScan := aScan(aFilsEmp,{|x| x[2] == cDocDest .and. AllTrim(x[5]) == AllTrim( cIEDest ) })

					if nFilScan == 0
						nFilScan := aScan(aFilsEmp,{|x| x[2] == cDocDest })
					endIf

					If nFilScan == 0
						If aScan(aFilsLic,{|x| x[2] == cDocDest }) > 0
							lXmlsLic := .T.
						EndIf
					EndIf

				Else

					cDocDest := ""

				EndIf

			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Busca no RECEBEDOR.                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nFilScan == 0

				cTagDocDest:= "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_RECEB:_CNPJ:TEXT"
				cTagIEDest := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_RECEB:_IE:TEXT"

				If Type(cTagIEDest)<>"U"
					cIEDest := &(cTagIEDest)
				Else
					cIEDest := ""
				EndIf

				If Type(cTagDocDest)<>"U"

					cDocDest := &(cTagDocDest)
					nFilScan := aScan(aFilsEmp,{|x| x[2] == cDocDest .and. AllTrim(x[5]) == AllTrim( cIEDest ) })

					if nFilScan == 0
						nFilScan := aScan(aFilsEmp,{|x| x[2] == cDocDest })
					endIf

					If nFilScan == 0

						If aScan(aFilsLic,{|x| x[2] == cDocDest }) > 0
							lXmlsLic := .T.
						EndIf

					EndIf

				Else

					cDocDest := ""

				EndIf

			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Busca no DESTINATARIO.                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nFilScan == 0

				cTagDocDest:= "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_DEST:_CNPJ:TEXT"
				cTagIEDest := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_DEST:_IE:TEXT"

				If Type(cTagIEDest)<>"U"
					cIEDest := &(cTagIEDest)
				Else
					cIEDest := ""
				EndIf

				If Type(cTagDocDest)<>"U"

					cDocDest := &(cTagDocDest)
					nFilScan := aScan(aFilsEmp,{|x| x[2] == cDocDest .and. AllTrim(x[5]) == AllTrim( cIEDest ) })

					if nFilScan == 0
						nFilScan := aScan(aFilsEmp,{|x| x[2] == cDocDest })
					endIf

					If nFilScan == 0
						If aScan(aFilsLic,{|x| x[2] == cDocDest }) > 0
							lXmlsLic := .T.
						EndIf
					EndIf

				Else

					cDocDest := ""

				EndIf

			EndIf

		EndIf

		If nFilScan > 0

			cFilAnt   := aFilsEmp[nFilScan][1]
			cFilNova  := aFilsEmp[nFilScan][1]
			cNomFil   := aFilsEmp[nFilScan][3]
			cFilXML   := cFilAnt

			If cTipoDoc $ "D|B"

				DbSelectArea("SA1")
				DbSetOrder(3)

				cFilSeek := xFilial("SA1") //Iif(lSharedA1,xFilial("SA1"),cFilNova)

				If .Not. Empty(cCnpjEmi) .And. DbSeek(cFilSeek+cCnpjEmi)

					cCodEmit  := SA1->A1_COD
					cLojaEmit := SA1->A1_LOJA
					cRazao    := SA1->A1_NOME
					cIndRur   := ""

					Do While .not. SA1->( eof() ) .and. SA1->A1_FILIAL == cFilSeek .and.;
					SA1->A1_CGC == cCnpjEmi

						if SA1->A1_MSBLQL != "1"
							cCodEmit  := SA1->A1_COD
							cLojaEmit := SA1->A1_LOJA
							cRazao    := SA1->A1_NOME
							exit
						endif

						SA1->( dbSkip() )

					EndDo

				Else

					cCodEmit  := ""
					cLojaEmit := ""
					cRazao    := ""
					cIndRur   := ""

				EndIf

			Else

				DbSelectArea("SA2")
				DbSetOrder(3)
				cFilSeek := xFilial("SA2") //Iif(lSharedA2,xFilial("SA2"),cFilNova)

				If .Not. Empty(cCnpjEmi) .And. DbSeek(cFilSeek+cCnpjEmi)

					if !Empty(SA2->A2_CGC)

						cCodEmit  := SA2->A2_COD
						cLojaEmit := SA2->A2_LOJA
						cRazao    := SA2->A2_NOME
						cIndRur   := SA2->A2_INDRUR

					endif

					Do While .not. SA2->( eof() ) .and. SA2->A2_FILIAL == cFilSeek .and.;
					SA2->A2_CGC == cCnpjEmi

						if SA2->A2_MSBLQL != "1" .And. !Empty(SA2->A2_CGC)

							cCodEmit  := SA2->A2_COD
							cLojaEmit := SA2->A2_LOJA
							cRazao    := SA2->A2_NOME
							cIndRur   := SA2->A2_INDRUR
							exit

						endif

						SA2->( dbSkip() )

					EndDo

				Else

					cCodEmit  := ""
					cLojaEmit := ""
					cRazao    := ""
					cIndRur   := ""

					//----------------------------------------------------------//
					//FR - 28/10/2021 - DAIKIN - CADASTRO AUTOMÁTICO FORNECEDOR 
					//----------------------------------------------------------//
					If cAutoSA2D == "S" //FR - 21/12/2021 - se cadastra automático no download do xml
					
						//Aqui chama a função de cadastro automático de fornecedor
						//If (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC"))) <> "D" .and. (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC"))) <> "B"
							
							//só cadastra automático se não for tipo Beneficiamento ou Devolução (porque nesse caso é Cliente)
							U_fCADSA2(cCNPJEmi)			//fCADSA2(cCNPJEmi,xRECZBZ) //aqui ainda não tem o Recno da ZBZ porque ainda não gravou
							
							DbSelectArea("SA2")
							DbSetOrder(3)
							cFilSeek := xFilial("SA2") //Iif(lSharedA2,xFilial("SA2"),cFilNova)
			
							If DbSeek(cFilSeek+cCnpjEmi)
			
								cCodEmit  := SA2->A2_COD
								cLojaEmit := SA2->A2_LOJA
								cRazao    := SA2->A2_NOME
								cIndRur   := SA2->A2_INDRUR
							Endif 			
						
						//Endif
						
					Endif  			
					//----------------------------------------------------------//
					//FR - 28/10/2021 - DAIKIN - CADASTRO AUTOMÁTICO FORNECEDOR 
					//----------------------------------------------------------//
				EndIf

			EndIf

		Else

			if cModelo == "55" 

				cTransCNPJ := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_TRANSP:_TRANSPORTA:_CNPJ:TEXT"
				cTransIE := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_TRANSP:_TRANSPORTA:_IE:TEXT"

				If Type(cTransCNPJ) <> "U"

					cTransCNPJ := &(cTransCNPJ)

				else
					
					cTransCNPJ := ""

				endif

				if alltrim(SM0->M0_CGC) == alltrim(cTransCNPJ)

					cFilAnt   := cFilXMLAtu
					lGrava    := .F.
					lInvalid  := .T.
					cFilXML   := "XX"
					lConsulta := .F.
					lTransp   := .T.

					//Grava erro na zbs para facilitar a indentificação da falha
					DbSelectArea(xZBS)
					DbSetOrder(3)
					if DbSeek( cChaveXml )

						Reclock(xZBS,.F.)

						(xZBS)->(FieldPut(FieldPos(xZBS_+"ERRO"), "CNPJ como transportador nao a necessidade de baixar esse xml" ))

						(xZBS)->( MsUnlock() )

					endif

				else

					if nFilScan == 0

						If lXmlsLic

							cError += "Este XML não pertence a Empresa/Filial Licenciada! Código "+AllTrim(SM0->M0_CODIGO)+" " +CRLF
							cOcorr := "Documento emitido para CNPJ/CPF Não Licenciada."

						Else

							cError += "Este XML não pertence a Empresa/Filial ! Código "+AllTrim(SM0->M0_CODIGO)+" "  +CRLF
							cOcorr := "Documento emitido para CNPJ/CPF diferente da empresa cadastrada."

						EndIf

						cFilAnt   := cFilXMLAtu
						lGrava    := .F.
						lInvalid  := .T.
						cFilXML   := "XX"
						lConsulta := .F.

					endif

				endif

			else

				if cModelo <> "65"

					If lXmlsLic

						cError += "Este XML não pertence a Empresa/Filial Licenciada! Código "+AllTrim(SM0->M0_CODIGO)+" " +CRLF
						cOcorr := "Documento emitido para CNPJ/CPF Não Licenciada."

					Else

						cError += "Este XML não pertence a Empresa/Filial ! Código "+AllTrim(SM0->M0_CODIGO)+" "  +CRLF
						cOcorr := "Documento emitido para CNPJ/CPF diferente da empresa cadastrada."

					EndIf

					cFilAnt   := cFilXMLAtu
					lGrava    := .F.
					lInvalid  := .T.
					cFilXML   := "XX"
					lConsulta := .F.

				endif

			endif

		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Consulta o Xml na Sefaz.                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lConsulta .and. cOrigem <> "2"

			//Consulta comentada por conta da restrição do sefaz de 20 chaves por hora.
			//Rogerio Lino - 04/05/2022
			if GetNewPar( "XM_DFE", "0" ) == "2"

				lValidado := .T. //u_NFeConsProt( cChaveXml, .F., @cCodRet, @xManif )

				//lValidado := U_XConsXml(cURL,cChaveXml,cModelo,cProtocolo,@cMensagem,@cCodRet,AllTrim(SuperGetMv("MV_MOSTRAA")) == "S",,,@xManif) //GETESB2
	
			else

				lValidado := .T. //U_XConsXml(cURL,cChaveXml,cModelo,cProtocolo,@cMensagem,@cCodRet,AllTrim(SuperGetMv("MV_MOSTRAA")) == "S",,,@xManif) //GETESB2
			
			endif 

			cDtHrCOns := HfPutdt(1,dDatabase, Time(),"")

			If cCodRet == "101" .or. cStatus == "101"

				lXmlCanc := .T.
				cOcorr   := cMensagem
				cMsgCanc := "Tipo de xml: " + cPref +CRLF
				cMsgCanc += "Chave      : " + cChaveXml +CRLF
				cMsgCanc += "Observação : " + "Cancelamento do Xml de "+cPref+ " autorizado." +CRLF
				cMsgCanc += "Aviso      : " + "Cancele o documento de "+cPref+ " manualmente." +CRLF
				//					SendMailCanc(1,cModelo,cChaveXml,cFilename,cMsgCanc,"","")

			ElseIf .NOT. cCodRet $ AllTrim(GetNewPar("XM_RETOK","526,731"))+",100" .and. !Empty(cCodRet)

				lConsErr := .T.
				cOcorr   := cMensagem
				cMsgErr := "Tipo de xml: " + cPref +CRLF
				cMsgErr += "Chave      : " + cChaveXml +CRLF
				cMsgErr += "Observação : " + "Erro na consulta do Xml de "+cPref+ "." +CRLF
				cMsgErr += "Aviso      : " + "Consulte o Xml manualmente pela rotina padrão ou aguarde até a proxima consulta automática." +CRLF

			EndIf

		EndIf

	EndIf

	If !Empty(AllTrim(cOcorr+cError)) .And. !lXmlCanc .and. lTransp == .F.

		If cOcorr == "Documento emitido para CNPJ/CPF diferente da empresa cadastrada."
			Conout(;
				cMensagem+CRLF+;
				cModelo+CRLF+;
				cFilename+CRLF+;
				cOcorr+CRLF+;
				cError+CRLF+;
				cWarning;
			)
		Else 
			SendMailError(1,cModelo,oXml,cFilename,cOcorr,cError,cWarning,lXmlCanc)
		EndIf

	EndIf

Else

	lGrava := .F.

	If !lXmlCanc

		SendMailError(1,cModelo,oXml,cFilename,cOcorr,cError,cWarning,lXmlCanc)

	endif

EndIf

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º                               Status                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºE-Mail    ³ 0-Xml Ok (Não envia)                                       º±±
±±º          ³ 1-Xml com erro (Pendente)                                  º±±
±±º          ³ 2-Xml com erro (Enviado)                                   º±±
±±º          ³ 3-Xml cancelado (Pendente)                                 º±±
±±º          ³ 4-Xml cancelado (Enviado)                                  º±±
±±º          ³ X-Falha ao enviar o e-mail (Erro)                          º±±
±±º          ³ Y-Falha ao enviar o e-mail (Cancelamento)                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ IMPORTA XML                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//FR - A partir daqui, GRAVA ZBZ
If lGrava

	cStatusXml := ""
	cStatReg   := ""
	cInfoErro  := ""

	Do Case

		Case lXmlCanc

			cStatusXml := "X"
			cStatReg   := "2"
			cStatMail  := "3"
			cInfoErro  := U_GetInfoErro(cStatMail,cMsgCanc,cModelo)

		Case Empty(cError) .And. Empty(cWarning) .And. Empty(cOcorr) .And. lValidado

			cStatusXml := VerStat( cFilAnt, cDocXMl, verSerie( cSerXMl, cFilAnt, lTransf ), cCodEmit+cLojaEmit, cTipoDoc, cChaveXml )  //"B"
			cStatReg   := "1"
			cStatMail  := "0"
			cInfoErro  := ""

		Case lConsErr

			cStatusXml := "Z"
			cStatReg   := "2"
			cStatMail  := "0"
			cInfoErro  := ""

		OtherWise

			cStatusXml := "F"
			cStatReg   := "2"
			cStatMail  := "1"
			cInfoErro  := U_GetInfoErro(cStatMail,(cMensagem+CRLF+cError+CRLF+cWarning+CRLF+cOcorr),cModelo)

	EndCase

	//campos que eram só da Nuvem - AGUAS DO BRASIL 08/01/19
	CamposNuv( oXml, cModelo, @nVLLIQ, @nVLDESC, @nVLIMP, @nVLBRUT, @nVlCarga,@xMunIni,@xUFIni )
	//campos que eram só da Nuvem - AGUAS DO BRASIL

	nHdl    := -1
	cSeriNF := ""

	If TravaXml("TRAVA", cChaveXml, @nHdl) //Travar AQUI

		DbSelectArea(xZBZ)
		DbSetOrder(3)

		If !DbSeek(alltrim(cChaveXml)) .Or. (!lAppend) .Or. ( DbSeek(alltrim(cChaveXml)) .And. (xZBZ)->(FieldGet(FieldPos(xZBZ_+"STATUS"))) = "2") .Or.;
		(DbSeek(alltrim(cChaveXml)) .And. (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOWL"))) = "R")

			if DbSeek(alltrim(cChaveXml)) .And. (xZBZ)->(FieldGet(FieldPos(xZBZ_+"STATUS")))="2"  .Or.;
			(DbSeek(alltrim(cChaveXml)) .And. (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOWL")))="R")
				lAppend := .F.
			endif

			if !Empty( cIEDest )

				_cFil := u_Gravafil( cDocDest, cIEDest )

				if Empty( xFilial(xZBZ) )  //Verifica se for compartilhado

					_cFil := xFilial( xZBZ )

				endif

			else

				_cFil := xFilial( xZBZ )

			endif
			//------------------------------------------------//
            //GRAVA ZBZ 
            //------------------------------------------------//
			//FR - 04/10/2022 - criação de função separada para gravação da ZBZ
			xChave   := cChaveXml    

			aVars := {}			
			Aadd( aVars , { lAppend,;
			_cFil,;
			cSerXMl,;
			cChaveXml,;
			lTransf,;
			cCnpjEmi,;
			cDocDest,;
			cNomFil,;
			cDocXMl,;
			cRazao,;
			nBASCAL,;
			nICMVAL,;
			nICMDES,;
			nSTBASE,;
			nSTVALO,;
			nIPIVAL,;
			nIPIDEV,;
			nPISVAL,;
			nCOFVAL,;
			nOUTVAL,;
			dDataEntr,;
			S_XML,;
			cStatusXml,;
			cModelo,;
			cCodEmit,;
			cLojaEmit,;
			cIndRur,;
			cUfDest,;
			cError,;
			cOcorr,;
			cWarning,;
			cTipoDoc,;
			cCfopDoc,;
			nVLLIQ,;
			nVLDESC,;
			nVLIMP,;
			nVLBRUT,;
			nVlCarga,;
			xMunIni,;
			xUFIni,;
			cMensagem,;
			cOriNF;
			})	
			/*
			U_FGRVZBZ(lAppend,_cFil,cSerXMl,cChaveXml,lTransf,cCnpjEmi,cDocDest,cNomFil,cDocXMl,cRazao,nBASCAL,nICMVAL,nICMDES,nSTBASE,;
			nSTVALO,nIPIVAL,nIPIDEV,nPISVAL,nCOFVAL,nOUTVAL,dDataEntr,S_XML,cStatusXml,cModelo,cCodEmit,cLojaEmit,cIndRur,cUfDest,cError,;
			cOcorr,cWarning,cTipoDoc,cCfopDoc,nVLLIQ,nVLDESC,nVLIMP,nVLBRUT,nVlCarga,xMunIni,xUFIni)
			*/
			U_FGRVZBZ(aVars)
			//=====================================================================//
			//FR - 04/10/2022 - criação de função separada para gravação da ZBZ
			//=====================================================================//
			/*	//BLOCO COMENTADO POIS FOI PRA FUNÇÃO ESPECÍFICA DE GRAVAR ZBZ
			Reclock(xZBZ,lAppend)

			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CHAVE"), cChaveXml))  //Colocado no ínicio como prioridade de gravação
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"FILIAL"), _cFil))

			MsUnLock()

			cSeriNF := verSerie( cSerXMl, cFilAnt, lTransf )

			Reclock(xZBZ,.F.)

			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CNPJ"), cCnpjEmi))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CNPJD"), cDocDest))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CLIENT"), cNomFil))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"SERIE"), verSerie( cSerXMl, cFilAnt, lTransf ) ))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"NOTA"), cDocXMl))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"FORNEC"), cRazao))

			//TRATAMENTO IMPOSTOS - AUDITORIA
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"BASCAL"), nBASCAL))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"ICMVAL"), nICMVAL))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"ICMDES"), nICMDES))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"STBASE"), nSTBASE))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"STVALO"), nSTVALO))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"IPIVAL"), nIPIVAL))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"IPIDEV"), nIPIDEV))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PISVAL"), nPISVAL))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"COFVAL"), nCOFVAL))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"OUTVAL"), nOUTVAL))
			
			if Empty(  (xZBZ)->(FieldGet(FieldPos(xZBZ_+"DTRECB")))  )   //Gravar só se Tiver Vazio
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"DTRECB"), dDataBase))
			endif

			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"DTNFE"), dDataEntr))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"XML"), S_XML))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PRENF"), cStatusXml))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"STATUS"), cStatReg))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"OBS"), cMensagem+CRLF+cError+CRLF+cWarning+CRLF+cOcorr))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"MODELO"), cModelo))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CODFOR"), cCodEmit))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"INDRUR"), cIndRur))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"LOJFOR"), cLojaEmit))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPDOC"), cTipoDoc))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"UF"), cUfDest))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"SERORI"), cSerXMl))

			//FR - 28/04/2021 - NOVA TELA GESTÃOXML - GRAVAR NOVO CAMPO ZBZ_ICOMPL - informações complementares
			xInfoCompl := ""
			xInfoCompl := U_fInfoCompl(cModelo,S_XML)
			If xInfoCompl <> Nil  		
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"ICOMPL"), xInfoCompl ))
			Endif
			If (xZBZ)->(FieldPos(xZBZ_+"FORPAG"))>0    //GETESB

				if Type( cTagTpPag ) <> "U"
					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"FORPAG"), &(cTagTpPag) ))
				else
					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"FORPAG"), "1" ))
				endif

			Endif

			If (xZBZ)->(FieldPos(xZBZ_+"CONDPG"))>0    //GETESB
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CONDPG"), U_HF02CPG() ))
			EndIf

			If (xZBZ)->(FieldPos(xZBZ_+"TPEMIS"))>0 .And. (xZBZ)->(FieldPos(xZBZ_+"TPAMB")) > 0

				if Type( cTagTpEmiss ) <> "U" .And. !Empty(cTagTpEmiss)
					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPEMIS"), &(cTagTpEmiss) ))
				Endif

				if Type( cTagTpAmb ) <> "U" .And. !Empty(cTagTpAmb)
					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPAMB"), &(cTagTpAmb) ))
				EndIF

			EndIf

			If (xZBZ)->(FieldPos(xZBZ_+"TOMA")) > 0 .And. (xZBZ)->(FieldPos(xZBZ_+"DTHRCS")) > 0

				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"TOMA"), cTipoToma))
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"DTHRCS"), cDtHrCOns))

			EndIf

			If (xZBZ)->(FieldPos(xZBZ_+"CNPJT")) > 0 

				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CNPJT"), cDocToma))

			EndIf

			If (xZBZ)->(FieldPos(xZBZ_+"PROT")) > 0
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PROT"), cProtocolo))
			EndIf

			If (xZBZ)->(FieldPos(xZBZ_+"VERSAO")) > 0
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"VERSAO"), cVerXml))
			EndIf

			If (xZBZ)->(FieldPos(xZBZ_+"MAIL")) > 0
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"MAIL"), cStatMail))
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"DTMAIL"), cInfoErro))
			EndIf

			if (xZBZ)->(FieldPos(xZBZ_+"MANIF")) > 0   // .And. ! Empty(xManif) //GETESB2

				cRet := U_HFMANZBS( AllTrim( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))) ), "", cOrigem )

				if !Empty( cRet )

					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"MANIF"), cRet ))

				endif

			endif

			if (xZBZ)->(FieldPos(xZBZ_+"IMPORT")) > 0
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"IMPORT"), cOrigem ))
			endif

			if (xZBZ)->(FieldPos(xZBZ_+"TPDOWL")) > 0
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPDOWL"), cTipoDow ))
			endif

			if (xZBZ)->(FieldPos(xZBZ_+"TPROT")) > 0 //Tipo de Rotina Job ou Manual

				if Empty(  (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPROT"))) )

					if Type("cTpRt") <> "U"
						(xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPROT"), cTpRt ))
					endif

				endif

			endif

			if (xZBZ)->(FieldPos(xZBZ_+"CFOP")) > 0
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CFOP"), cCfopDoc ))
			endif

			//Criar campo na ZBZ, referente ao Tipo Ct-e - 26/12/2016
			If (xZBZ)->(FieldPos(xZBZ_+"TPCTE")) > 0

				If Type( cTagTpCte ) <> "U"

					Do Case
						Case &( cTagTpCte ) == "0"
						(xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPCTE"), "N"))
						Case &( cTagTpCte ) == "1"
						(xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPCTE"), "C"))
						Case &( cTagTpCte ) == "2"
						(xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPCTE"), "A"))
						Case &( cTagTpCte ) == "3"
						(xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPCTE"), "S"))
					EndCase
					//	else
					//		(xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPCTE"), "N" ))
				EndIf

			EndIf

			// Fim da alteração 
			if GetNewPar("XM_USAGFE","N") = "S"

				if cModelo = "57"

					If (xZBZ)->(FieldPos(xZBZ_+"SITGFE")) > 0
						(xZBZ)->(FieldPut(FieldPos(xZBZ_+"SITGFE"), U_HFSITGFE( cChaveXml, "GFE" ) ))
					Endif

				endif

			Endif

			//CamposNuv( oXml, cModelo, @nVLLIQ, @nVLDESC, @nVLIMP, @nVLBRUT )
			if (xZBZ)->(FieldPos(xZBZ_+"VLLIQ")) > 0
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"VLLIQ"), nVLLIQ ))
			endif

			if (xZBZ)->(FieldPos(xZBZ_+"VLDESC")) > 0
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"VLDESC"), nVLDESC ))
			endif

			if (xZBZ)->(FieldPos(xZBZ_+"VLIMP")) > 0
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"VLIMP"), nVLIMP ))
			endif

			if (xZBZ)->(FieldPos(xZBZ_+"VLBRUT")) > 0
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"VLBRUT"), nVLBRUT ))
			endif

			if (xZBZ)->(FieldPos(xZBZ_+"VCARGA")) > 0
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"VCARGA"), nVlCarga ))
			endif
			DbSelectArea(xZBZ)
			MsUnLock()
		    //--------------------------------------------------------------------------------//
			//FR - 04/06/2020 - Projeto CCM - Tratativa para gravação no novo campo ZBZ_ORIPRT
			//                - origem prestação de Serviço (Município - UF)  
			//--------------------------------------------------------------------------------//
			If cModelo == "57"	
				DbSelectArea(xZBZ)
				Reclock(xZBZ,.F.)
				If (xZBZ)->(FieldPos(xZBZ_+"ORIPRT")) > 0
					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"ORIPRT"), (xMunIni + "-" + xUFIni) ))
				Endif
				If Empty(xMunIni) .or. Empty(xUFIni)
					//CONOUT("<GESTAOXML> GRAVACAO -> xMunIni ou xUFIni Vazios !" )
				Else
					//CONOUT("<GESTAOXML> GRAVACAO -> xMunIni / xUFIni OK ")
				Endif
				DbSelectArea(xZBZ)
				MsUnLock()
			
			Endif
			
			//--------------------------------------------------------------------------------//
			//FR - 27/07/2020 - Projeto CCM - Tratativa para gravação no novo campo ZBZ_ORIPRT
			//                - origem prestação de Serviço (Município - UF)  
			//--------------------------------------------------------------------------------//
			cError   := ""
			cWarning := ""
			
			If cModelo == "57"

				oXml := XmlParser( S_XML, "_", @cError, @cWarning )

				if Empty( oXml )

					S_XML := EncodeUTF8(S_XML)
					S_XML := FwNoAccent(S_XML)
					
					//Faz backup do xml sem retirar os caracteres especiais
					cBkpXml := S_XML

					//Executa rotina para retirar os caracteres especiais
					S_XML := u_zCarEspec( S_XML)

					oXml := XmlParser( S_XML, "_", @cError, @cWarning )

					//retorna o backup do xml
					S_XML := cBkpXml

				endif
						
				//-------------------------------------------------------------------------------//	
				//FR - 27/07/2020 - Projeto CCM - novo campo origem prestação serviço ZBZ_ORIPRT 
				//-------------------------------------------------------------------------------//
				If Empty(cError) .And. Empty(cWarning) .And. oXml <> Nil 
				
					xMunIni := ""
					cTagAux := "oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_XMUNINI:TEXT"
				
					xMunIni := &(cTagAux)

					xUFIni := ""
					cTagAux := "oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_UFINI:TEXT"
				
					xUFIni := &(cTagAux)
				    
				    DbSelectArea(xZBZ)
				    Reclock(xZBZ,.F.)
				    									
					If (xZBZ)->(FieldPos(xZBZ_+"ORIPRT")) > 0
					
						If Empty( (xZBZ)->(FieldPos(xZBZ_+"ORIPRT")) )
					    	//CONOUT("<GESTAOXML> => _ORIPRT Vazio <=" )					    	
					    Endif
					    
					    If Empty(xMunIni) .or. Empty(xUFIni)
							//CONOUT("<GESTAOXML> REGRAVACAO => xMunIni ou xUFIni Vazios !" )
						Else
							//CONOUT("<GESTAOXML> REGRAVACAO => xMunIni / xUFIni OK ")
						Endif
				    
						(xZBZ)->(FieldPut(FieldPos(xZBZ_+"ORIPRT"), (xMunIni + "-" + xUFIni) ))
						
						
					Endif
					
					DbSelectArea(xZBZ)
					MsUnLock()					
					
			    Endif
			    
	  		Endif

			DbSelectArea(xZBZ)
			MsUnLock()

	  		//----------------------------------------------------------------//
	  		//FR - 18/08/2020 - Kroma - XML Energia - Definido pelo NCM e CFOP 
	  		//----------------------------------------------------------------//
	  		cError       := ""
			cWarning     := ""
			oDet         := NIL
			cTagAux      := ""
			cCFOPEnergia := GetNewPar("XM_CFOENERG","5251,6251,5123,6123,5922,6922")		//deixar aqui mesmo porque é algo que não mudará
			cCFOP        := ""
			lEnergia     := .F.

			oXml := XmlParser( S_XML, "_", @cError, @cWarning )

			if Empty( oXml )
			
				S_XML := EncodeUTF8(S_XML)
				S_XML := FwNoAccent(S_XML)
				
				//Faz backup do xml sem retirar os caracteres especiais
				cBkpXml := S_XML

				//Executa rotina para retirar os caracteres especiais
				S_XML := u_zCarEspec( S_XML)

				oXml := XmlParser( S_XML, "_", @cError, @cWarning )

				//retorna o backup do xml
				S_XML := cBkpXml

			endif
			 
			If cModelo $ "55,65"
			
				If Type( "oXml:_NFEPROC:_NFE:_INFNFE:_DET" ) != "U"	
					oDet := oXml:_NFEPROC:_NFE:_INFNFE:_DET
					oDet := IIf(ValType(oDet)=="O",{oDet},oDet)	
				Else	
					oDet := {}	
				Endif
				
				If Len(oDet) > 0
					For i := 1 To Len(oDet)
											
						//CFOP do produto						
						cTagAux := "oDet["+AllTrim(str(I))+"]:_PROD:_CFOP:TEXT"						
						If type( cTagAux ) <> "U"
							cCFOP := (&cTagAux)
							If cCFOP $ cCFOPEnergia
								lEnergia := .T.
								Exit
							Endif 
						Endif		
		            Next
		            
	            Endif
           
			Endif
			
			If lEnergia 
				DbSelectArea(xZBZ)
				Reclock(xZBZ,.F.)
				
				If (xZBZ)->(FieldPos(xZBZ_+"COMBUS")) > 0
					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"COMBUS"), "E" ))
				Endif
				
				DbSelectArea(xZBZ)
				MsUnLock()
			Endif
            //FR - 18/08/2020 - Fim tratativa para Kroma Energia
			*/		//BLOCO COMENTADO POIS FOI PRA FUNÇÃO ESPECÍFICA DE GRAVAR ZBZ
			//=====================================================================//
			//FR - 04/10/2022 - criação de função separada para gravação da ZBZ
			//=====================================================================//
			//FR - 13/11/19
			//===================//
			// Grava ZBT:        //
			//===================//
			cModel    := ""
			cModel    := cModelo //Substr(cNewKey,21,2)
				
			U_fGravaZBT(S_XML,cModelo,cChaveXml,cDocXMl,cSeriNF,cCnpjEmi)  

			//FIM Grava ZBT

			cLogProc += "[XML] "+cChaveXml+" importado com sucesso."+CRLF

			if cOrigem == "1" .And. cModelo == "55"  //e-mail ou direto na Pasta e Modelo Nfe

				If GetNewPar("XM_MANAUT","N") == "S"  //Manifesta Ciência da Operação Automático, serve para JOB e aqui também!
					U_HFMANCHV(,,,4)  //4-> Ciência da Operation
				Endif

			EndIf

			//AQUI ZBS
			DbSelectArea(xZBS)
			( xZBS )->( DbSetOrder( 3 ) )

			If ( xZBS )->(dbSeek( cChaveXml ) )
				if ( xZBS )->(FieldGet(FieldPos(xZBS_+"ST"))) <> "10"
					Reclock(xZBS,.F.)
					( xZBS )->(FieldPut(FieldPos(xZBS_+"ST")	, "10" ))
					MsUnLock()
				Endif
			EndIf

			DbSelectArea(xZBZ)
			//ATE AQUI ZBS

		EndIf

		cKeyXml := cChaveXml
		//		cFilXml := cFilAnt
		cFilAnt := cFilXMLAtu

		/*if aHfCloud[1] == "1"
			//aGrvZBZ := {}
			//aGrvZBZ := GrvZbz( cChaveXml, cMensagem, cError, cWarning, cOcorr, cTipoDoc, xManif )
			U_HFCLDEnv(,,,"1")
			//U_HFCLDZBZ( aGrvZBZ )   //AQUI
		EndIF*/

		TravaXml("SOLTA", cChaveXml, nHdl)   //SOLTAR AQUI

		//PEDIDO RECORRENTE
		If x_Ped_Rec == "S"

			U_XML09PDR( @cLogProc, .F. )  //log, exibir

		EndIf

		//----------------------------------------------------------------------------------------------------//
        //FR - 22/12/2022 - PROJETO BRASMOLDE - NOTIFICAÇÕES POR EMAIL QDO BAIXA XML
        //Depois de Gravar ZBZ e ZBT aciona rotina que dispara email caso esteja parametrizado para receber
        //----------------------------------------------------------------------------------------------------//
        cMail10 := GetNewPar("XM_MAIL10",Space(256))  //FR - 21/12/2022 - Flávia Rocha - EMAIL AVISANDO SOBRE NOVO XML GRAVADO NA BASE
		cCfBenef:= Padr(GetNewPar("XM_CFBENEF",Space(256)),256)	
		cCfDevol:= Padr(GetNewPar("XM_CFDEVOL",Space(256)),256)
		
        If !Empty(cMail10) //emails que receberão notificação qdo gravar xml na base
            
            cFornec  := ""
            cLojFor  := ""
            cNomeFor := ""
            nFormNfe := Val(GetNewPar("XM_FORMNFE","9"))

            //cAssunto := "Nota Fiscal Não Importada Com Sucesso"
            cAssunto := "Importação NFe: " + StrZero(Val(cDocXMl),nFormNfe) + "/" + cSerXMl
            cTipo    := "1"  //download ok

            aMsg     := {}	

            If cCfopDoc $ cCfBenef  //se o CFOP do XML está contido em CFOPs de beneficiamento, pega do cad. cliente:
				cFornec  := Posicione("SA1",3,xFilial("SA1")+ cCnpjEmi,"A1_COD")
            	cLojFor  := Posicione("SA1",3,xFilial("SA1")+ cCnpjEmi,"A1_LOJA")
            	cNomeFor := Posicione("SA1",1,xFilial("SA1")+ cFornec + cLojFor,"A1_NOME")
				cTpCliFor:= "Cliente"
			
			Elseif cCfopDoc $ cCfDevol  //se o CFOP do XML está contido em CFOPs de devolução, pega do cad. cliente:
                cFornec  := Posicione("SA1",3,xFilial("SA1")+ cCnpjEmi,"A1_COD")
            	cLojFor  := Posicione("SA1",3,xFilial("SA1")+ cCnpjEmi,"A1_LOJA")
				cNomeFor := Posicione("SA1",1,xFilial("SA1")+ cFornec + cLojFor,"A1_NOME")
                cTpCliFor:= "Cliente"
			Else
				cFornec  := Posicione("SA2",3,xFilial("SA2")+ cCnpjEmi,"A2_COD")
            	cLojFor  := Posicione("SA2",3,xFilial("SA2")+ cCnpjEmi,"A2_LOJA")
            	cNomeFor := Posicione("SA2",1,xFilial("SA2")+ cFornec + cLojFor,"A2_NOME")
				cTpCliFor:= "Fornecedor"
			Endif

			If Empty(cNomeFor)
				cNomeFor := cRazao 
			Endif 
            cAssunto += " - Forn: " + cFornec + "/" + cLojFor + "-" + cNomeFor + " - PENDENTE"
            
			If Empty(cCodRet)
				If cStatusXml == "B"
					cMotivo := "100"
				Else 
					cMotivo := ""
				Endif 
			Else
				cMotivo := cCodRet 
			Endif 

			If Empty(cTAG)
				If cModelo $ "55/RP"
					cTAG := "NFe"
				Elseif cModelo == "57"
					cTAG := "Cte"
				Endif 
			Endif 
            U_FNOTIFICA(cMail10,cTipo,cFornec,cLojfor,cNomeFor,cRazao,cCnpjEmi,Val(cDocXMl),cSerXMl,nFormNfe,dDataEntr,cMotivo,cTAG,xChave,cTpCliFor)
                
            /*
            //MODELO
            Assunto  - Nota Fiscal não importada com sucesso 
            Conteúdo 
            Fornecedor......: 000996 - TE CONNECTIVITY BRASIL IN
            Nota Fiscal.....: 000196943/1 - Emissão: 19/04/2021
            Chave da NFe....: 35210400907845001560550010001969431286545563
            Situação SEFAZ..: 100 - Autorizado o uso da NF-e
            */ 
        Endif 
            //FR - 22/12/2022 - PROJETO BRASMOLDE - NOTIFICAÇÕES POR EMAIL QDO BAIXA XML

	Else

		TravaXml("SOLTA", cChaveXml, nHdl)  
		cLogProc += "[XML] em processamento por outra estação "+cChaveXml +"."+CRLF
		lGrava := .F.
		lContinua := .F.
		lInvalid := .T.

	Endif

EndIf

//cFilXml := cFilAnt
cKeyXml := cChaveXml
cOcorr  := cError

Return(.T.)
	

******************************************************************************
Static Function CamposNuv( _oXml, _cModelo, nVLLIQ, nVLDESC, nVLIMP, nVLBRUT, nVlCarga,xMunIni,xUFIni )
******************************************************************************
	
//Local i       := 0
Local nI      := 0
Private cTagAux := ""
Private oDet

//oXml vindo private. Utilizar esse por conta do Type().
if _cModelo == "55"

	nVLLIQ  := 0
	cTagAux := "oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_vProd:TEXT"

	if type(cTagAux) <> "U"
		nVLLIQ := noRound( Val( &(cTagAux) ), 2)
	endif

	nVLDESC := 0
	cTagAux := "oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_vDesc:TEXT"

	if type(cTagAux) <> "U"
		nVLDESC := noRound( Val( &(cTagAux) ), 2)
	endif

	nVLIMP := 0
	cTagAux := "oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_vST:TEXT"
	if type(cTagAux) <> "U"
		nVLIMP += noRound( Val( &(cTagAux) ), 2 )
	endif

	cTagAux := "oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_vII:TEXT"
	if type(cTagAux) <> "U"
		nVLIMP += noRound( Val( &(cTagAux) ), 2 )
	endif

	cTagAux := "oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_vIPI:TEXT"
	if type(cTagAux) <> "U"
		nVLIMP += noRound( Val( &(cTagAux) ), 2 )
	endif

	nVLBRUT  := 0
	cTagAux := "oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VNF:TEXT"
	if type(cTagAux) <> "U"
		nVLBRUT := noRound( Val( &(cTagAux) ), 2)
	endif

ElseIf _cModelo == "57"

	nVLLIQ  := 0
	nVLDESC := 0
	nVLIMP  := 0
	nVlCarga:= 0

	cTagAux := "oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP"

	if type(cTagAux) <> "U"

		oDet := oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP
		oDet := iif( ValType(oDet) == "O", {oDet}, oDet )

		For nI := 1 to Len( oDet )

			If "DESC" $ AllTRim( oDet[nI]:_XNOME:TEXT ) .OR. "DESCONTO" $ AllTRim( oDet[nI]:_XNOME:TEXT )
				nVLDESC += noRound( Val(oDet[nI]:_VCOMP:TEXT), 2)
			ElseIf "IPI" $ AllTRim( oDet[nI]:_XNOME:TEXT ) .OR. "ICM" $ AllTRim( oDet[nI]:_XNOME:TEXT )
				nVLIMP += noRound( Val(oDet[nI]:_VCOMP:TEXT), 2)
			Else
				nVLLIQ += noRound( Val(oDet[nI]:_VCOMP:TEXT), 2)
			EndIf

		Next nI

	Endif

	nVLBRUT := 0
	cTagAux := "oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_VTPREST:TEXT"

	if type(cTagAux) <> "U"
		nVLBRUT := noRound( Val( &(cTagAux) ), 2)
	endif

	//Melhoria da Belenzier pneu para incluir o campo de valor total da carga
	cTagVCarga := "oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_VCARGA:TEXT"

	if Type(cTagVCarga) <> "U"

		nVlCarga := noRound( Val( &(cTagVCarga) ), 2)

	endif
	//-------------------------------------------------------------------------------//	
	//FR - 04/06/2020 - Projeto CCM - novo campo origem prestação serviço ZBZ_ORIPRT 
	//-------------------------------------------------------------------------------//
	xMunIni := ""
	cTagAux := "oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_XMUNINI:TEXT"

	if type(cTagAux) <> "U"
		xMunIni := &(cTagAux)
	endif
	
	xUFIni := ""
	cTagAux := "oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_UFINI:TEXT"

	if type(cTagAux) <> "U"
		xUFIni := &(cTagAux)
	endif
    //FR fim - 04/06/2020
Endif

Return( NIL )
	

*******************************************************************************************
/*Static Function GrvZbz( cChaveXml, cMensagem, cError, cWarning, cOcorr, cTipoDoc, xManif )
*******************************************************************************************
	
Local aRet := {}

aadd( aRet, {xZBZ_,"CHAVE"	, cChaveXml } )
aadd( aRet, {xZBZ_,"FILIAL"	, cFilAnt	} )
aadd( aRet, {xZBZ_,"CNPJ"	, cCnpjEmi 	} )
aadd( aRet, {xZBZ_,"CNPJD"	, cDocDest 	} )
aadd( aRet, {xZBZ_,"CLIENT"	, cNomFil 	} )
aadd( aRet, {xZBZ_,"SERIE"	, cSerXMl	} )
aadd( aRet, {xZBZ_,"NOTA"	, cDocXMl 	} )
aadd( aRet, {xZBZ_,"FORNEC"	, cRazao 	} )
aadd( aRet, {xZBZ_,"DTRECB"	, dDataBase } )
aadd( aRet, {xZBZ_,"DTNFE"	, dDataEntr } )
aadd( aRet, {xZBZ_,"XML"	, S_XML 	} )
aadd( aRet, {xZBZ_,"PRENF"	, cStatusXml } )
aadd( aRet, {xZBZ_,"STATUS"	, cStatReg } )
aadd( aRet, {xZBZ_,"OBS"	, cMensagem+CRLF+cError+CRLF+cWarning+CRLF+cOcorr } )
aadd( aRet, {xZBZ_,"MODELO"	, cModelo } )
aadd( aRet, {xZBZ_,"CODFOR"	, cCodEmit } )
aadd( aRet, {xZBZ_,"LOJFOR"	, cLojaEmit } )
aadd( aRet, {xZBZ_,"TPDOC"	, cTipoDoc } )
aadd( aRet, {xZBZ_,"UF"  	, cUfDest } )
aadd( aRet, {xZBZ_,"SERORI"	, cSerXMl } )

if Type( cTagTpPag ) <> "U"
	aadd( aRet, {xZBZ_,"FORPAG", &(cTagTpPag)  } )
else
	aadd( aRet, {xZBZ_,"FORPAG", "1"  } )
endif

aadd( aRet, {xZBZ_,"CONDPG"	, U_HF02CPG()  } )
aadd( aRet, {xZBZ_,"TPEMIS"	, &(cTagTpEmiss)  } )
aadd( aRet, {xZBZ_,"TPAMB"	, &(cTagTpAmb)  } )
aadd( aRet, {xZBZ_,"TOMA"	, cTipoToma } )
aadd( aRet, {xZBZ_,"DTHRCS"	, cDtHrCOns } )
aadd( aRet, {xZBZ_,"PROT"	, cProtocolo } )
aadd( aRet, {xZBZ_,"VERSAO"	, cVerXml } )
aadd( aRet, {xZBZ_,"MAIL"	, cStatMail } )
aadd( aRet, {xZBZ_,"DTMAIL"	, cInfoErro } )
aadd( aRet, {xZBZ_,"MANIF"	, xManif  } )

If Type( cTagTpCte ) <> "U"

	Do Case
		Case &( cTagTpCte ) == "0"
		aadd( aRet, {xZBZ_,"TPCTE", "N" } )
		Case &( cTagTpCte ) == "1"
		aadd( aRet, {xZBZ_,"TPCTE", "C" } )
		Case &( cTagTpCte ) == "2"
		aadd( aRet, {xZBZ_,"TPCTE", "A" } )
		Case &( cTagTpCte ) == "3"
		aadd( aRet, {xZBZ_,"TPCTE", "S" } )
	EndCase

Else

	aadd( aRet, {xZBZ_,"TPCTE", " " } )

EndIf

Return( aRet )*/
	

//================================================//
//para chamar de outras fontes
//If U_HFTrvXml("TRAVA", cChaveXml, @nHdl) Travar
//U_HFTrvXml("SOLTA", cChaveXml, nHdl) SOLTAR
//===============================================//
**********************************************
User Function HFTrvXml(xTip, xChaveXml, nHdl)
**********************************************

Local lRet := .T.

lRet := TravaXml(xTip, xChaveXml, @nHdl)

Return( lRet )
	

***********************************************
Static Function TravaXml(xTip, xChaveXml, nHdl)
***********************************************

Local lRet := .T.

/*
Local cArq := ""
Local cDir := cBarra+AllTrim(GetNewPar("MV_X_PATHX",""))+cBarra
Local nConta := 0

If Empty(xChaveXml)
	return( .T. )
endIf

cDir := Iif(lUnix,StrTran(cDir,"\","/"),cDir)
cDir := StrTran(cDir,cBarra+cBarra,cBarra)
cArq := cDir + xChaveXml + ".Trv"

If xTip == "TRAVA"

	nConta := 0

	Do While File( cArq )

		Sleep( 50 )
		nConta++

		if nConta > 10
			lRet := .F.
			Exit
		endif

	EndDo

	if lRet

		nConta := 0
		nHdl := -1

		Do While nHdl < 0

			if nConta > 0
				Sleep( 50 )
			endif

			nHdl := fCreate(cArq)
			nConta++

			if nConta > 10
				lRet := .F.
				Exit
			endif

		EndDo

	endif

Else

	if File( cArq )

		if nHdl > 0
			fClose(nHdl)
		endif

		nHdl := -1

		nConta := 0

		Do While nHdl < 0

			if nConta > 0
				Sleep( 50 )
			endif

			nHdl := FErase(cArq)
			nConta++

			if nConta > 10
				Exit
			endif

		EndDo

	EndIf

Endif
*/

Return( lRet )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³              º Autor ³ Eneovaldo Roveri Jrº Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Retorna o Série de acordo com a GRABER.                        º±±
±±º          ³                                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Importa XML                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function verSerie( cSerXMl, cFilAnt, lTransf )

Local cRet := cSerXMl
Local cSrr := AllTrim(GetNewPar("XM_SEREMP",""))
Local aSrr := Separa(cSrr,";")
Local nI   := 0
Local cAux := ""
Local cContem	:= SuperGetMv("XM_FORMSER",.T.,"0")    // Incluido dia 17/05/2016

If .Not. empty( cSrr )

	if ";" $ cSrr .or. "," $ cSrr

		For nI := 1 To len( aSrr )

			if cFilAnt $ aSrr[nI]

				cAux := Substr( aSrr[nI], 1, AT("=",aSrr[nI] )-1 )
				cAux := AllTRim( cAux )

				if len( cAux ) >= 1 .and. len( cAux ) <= 3
					cRet := cAux
					Exit
				endif

			endif

		Next nI

	Else

		cRet := cSrr

	Endif

Else

	If lTransf .or. cContem <> "0"  //Incluso melhoria ECOURBIS - Analista Alexandro / Eneo

		If AllTrim(cContem)=="0"//(Val(SuperGetMV('XM_FORMSER','0'))==0), Alterado

			cRet 	:= cSerXML

		ElseIf AllTrim(cContem)=="2"//(Val(SuperGetMV('XM_FORMSER','0'))==2), Alterado

			If len( Alltrim(cSerXML) ) <= 2
				cRet	:= cValToChar(StrZero( Val(cSerXML),2))
			EndIf

		ElseIf AllTrim(cContem)=="3"//(Val(SuperGetMV('XM_FORMSER','0'))==3), Alterado

			If len( Alltrim(cSerXML) ) <= 3
				cRet	:= cValToChar(StrZero(Val( cSerXML ),3))
			EndIf

		EndIf

	EndIf

EndIf

Return( cRet )
	

*************************************************
User Function vSerie( cSerXMl, cFilAnt, lTransf )
*************************************************

Local cRet := ""
cRet := verSerie( cSerXMl, cFilAnt, lTransf )

Return( cRet )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CCeXmlAll    º Autor ³ Eneo               º Data ³  09/05/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ CCe e Eventos dos XML dos Fornecedores referente a NF-e, CT-e  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Importa XML                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CCeXmlAll(cModelo,cXml,cFilename,lInvalid,cLogProc,cFilXml,cKeyXml,cSeqCce,cOcorr,aFilsEmp,oXmloK)

Local cError    := ""
Local cWarning  := ""
//Local cOcorr    := ""
//Local lGrava    := .T.
//Local lAppend   := .T.
//Local cMensagem := ""
//Local lValidado := .T.
//Local lConsulta := .T.
Local lContinua := .T.
Local cEvento   := ""
Local cStatReg  := ""
Local aEvt := {}
Local cGrv := ""

Private cTagEvento := ""
Private cSeqEve    := ""
Private cTagSeq    := ""
Private cXEvento   := ""
Private cXCorrecao := ""
Private cPref      := ""
Private cTag       := ""
Private cTagSign   := ""
Private cTagProt   := ""
Private cKey       := ""
Private cTagId     := ""
Private cTagRet    := ""
Private oXml, oRetId, oRetC, cAuxTag

Default lInvalid:= .F.
Default cLogProc:= ""
Default cURL    := AllTrim(GetNewPar("XM_URL",""))
Default cOcorr  := ""

If Empty(cURL)
	cURL  := AllTrim(SuperGetMv("MV_SPEDURL"))
EndIf

If cModelo == "55"

	cPref    := "NF-e"
	cTAG     := "NFE"

ElseIf cModelo == "65"

	cPref    := "NFC-e"
	cTAG     := "NFE"

ElseIf cModelo == "57"

	cPref    := "CT-e"
	cTAG     := "CTE"

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Validação da estrutura do XML.       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oXml := XmlParser( cXml, "_", @cError, @cWarning )

if Empty( oXml )

	cXml := NoAcento(cXml)
	cXml := EncodeUTF8(cXml)

	//Faz backup do xml sem retirar os caracteres especiais
	cBkpXml := cXml

	//Executa rotina para retirar os caracteres especiais
	cXml := u_zCarEspec( cXml )

	oXml := XmlParser( cXml, "_", @cError, @cWarning )

	//retorna o backup do xml
	cXml := cBkpXml

endif

If Empty(cError) .And. Empty(cWarning) .And. !lInvalid

	cTagId := "oXml:_PROCEVENTO"+cTAG+":_EVENTO"+":_INFEVENTO"
	cTagRet:= "oXml:_PROCEVENTO"+cTAG+":_RETEVENTO"+":_INFEVENTO"

	If Type(cTagId)== "U"

		cError += CRLF+"O XML "+cFilename+" não possui as informações de CCe."
		cLogProc += "O XML "+cFilename+" não possui as informações de CCe."+CRLF
		lContinua := .F.

	else

		cTagEvento := "oXml:_PROCEVENTO"+cTAG+":_EVENTO"+":_INFEVENTO:_TPEVENTO:TEXT"

		If Type(cTagId)== "U"

			cError += CRLF+"O XML "+cFilename+" não possui evento de CCe."
			cLogProc += "O XML "+cFilename+" não possui evento de CCe."+CRLF
			lContinua := .F.

		else

			cEvento := &(cTagEvento)

		endif

	Endif

	//Retorno do evento de CCe
	If Type(cTagRet)== "U"

		cError += CRLF+"O XML "+cFilename+" não possui retorno do evento."
		cLogProc += "O XML "+cFilename+" não possui retorno do evento."+CRLF
		lContinua := .F.

	EndIf

	cStatReg  := "1"  //quando da consulta pode mudaire

	If lContinua

		oRetId := &("oXml:_PROCEVENTO"+cTAG+":_EVENTO"+":_INFEVENTO")
		oRetC  := &("oXml:_PROCEVENTO"+cTAG+":_RETEVENTO"+":_INFEVENTO")

		cKey    := &("oRetId:_CH"+cTAG+":TEXT")
		cAuxTag := "oRetC:_NPROT:TEXT"
		cProtC  := ""

		IF Type( cAuxTag ) <> "U"
			cProtC  := oRetC:_NPROT:TEXT
		ENDIF

		cAuxTag := "oRetC:_DHREGEVENTO:TEXT"
		cDthRet := ""
		dDhAut  := ctod( "" )

		IF Type( cAuxTag ) <> "U"
			cDthRet := oRetC:_DHREGEVENTO:TEXT
			dDhAut  := StoD(substr(cDthRet,1,4)+Substr(cDthRet,6,2)+Substr(cDthRet,9,2))
		Endif

		cSeqEve := ""
		cAuxTag := "oRetC:_NSEQEVENTO:TEXT"

		IF Type( cAuxTag ) <> "U"
			cSeqEve := oRetC:_NSEQEVENTO:TEXT
		Endif

		cXEvento:= iif(cEvento=="110110","Carta de Correcao registrada","")
		cAuxTag := "oRetC:_XEVENTO:TEXT"

		IF Type( cAuxTag ) <> "U"
			cXEvento:= iif(cEvento=="110110","Carta de Correcao registrada",oRetC:_XEVENTO:TEXT)
		Endif

		cXCorrecao:= ""
		cAuxTag := "oRetId:_DETEVENTO:_XCORRECAO:TEXT"

		IF Type( cAuxTag ) <> "U"

			cXCorrecao:= oRetId:_DETEVENTO:_XCORRECAO:TEXT

		ENDIF

		if len(cSeqEve)<=len( (xZBE)->(FieldGet(FieldPos(xZBE_+"SEQEVE"))) )

			cSeqEve := StrZero( Val(cSeqEve), len( (xZBE)->(FieldGet(FieldPos(xZBE_+"SEQEVE"))) ), 0 )

		endif

		aEvt := {}

		aadd( aEvt, {xZBE_+"DHAUT" 	, dDhAut    } )
		aadd( aEvt, {xZBE_+"DTRECB"	, dDataBase } )
		aadd( aEvt, {xZBE_+"PROT"  	, cProtC    } )
		aadd( aEvt, {xZBE_+"XML"   	, cXml      } )
		aadd( aEvt, {xZBE_+"DESC"  	, cXCorrecao} )
		aadd( aEvt, {xZBE_+"EVENTO"	, cXCorrecao} )
		aadd( aEvt, {xZBE_+"STATUS"	, cStatReg  } )

		cGrv := U_HF2GrvEv( cKey, cEvento, cSeqEve, aEvt, .T. )

		if cGrv == "-2"

			cError += "Este XML de Evento (CCE) já esta na Base de Dados. A importação será Cancelada."+CRLF
			cLogProc += "[XML] XML de Evento (CCE) já consta na Base de Dados. " +cFilename +CRLF
			lContinua := .F.

		ElseIf cGrv == "1" .Or. cGrv == "0"

			cOcorr += "Evento de xml: "+cPref +CRLF
			cOcorr += "Chave :" + cKey 	 +CRLF
			cOcorr += "Aviso        : " + "Faça Manutenção no documento de "+cPref+ " manualmente." +CRLF
			cLogProc += "[XML] XML Evento (CCE) importado com sucesso. " +cFilename +CRLF

		ElseIf cGrv == "-1"

			cOcorr += "Evento ou Carta de Correção de xml: "+cPref +CRLF
			cOcorr += "Chave :" + iif(Empty(cKey),"Vazia","") + cKey 	 +CRLF
			cOcorr += "Obs.  :" + "Não foi encontrado o Xml Importado de "+cPref+ "." +CRLF

		EndIf

		if cGrv == "-1" .or. cGrv == "-2"

			SendMailError(1,cModelo,oXml,cFilename,cOcorr,cError,cWarning,.F.)

		endif

	Else

		SendMailError(1,cModelo,oXml,cFilename,cOcorr,cError,cWarning,.F.)

	EndIf

Else

	SendMailError(1,cModelo,oXml,cFilename,cOcorr,cError,cWarning,.F.)

EndIf

cFilXml := cFilAnt
cKeyXml := cKey
cOcorr  += cError
oXmloK  := oXml
cSeqCce := AllTrim(cEvento)+"-"+AllTrim(cSeqEve)

Return(.T.)
	
//----------------------//	
//GRAVA ZBE - EVENTOS
//----------------------//
*******************************************************************
User Function HF2GrvEv( cKey, cEvento, cSeqEve, aEvt, lForcaSem )
*******************************************************************

Local cRet      := " "
Local nY        := 0
Local aArea     := GetArea()
Local lAppend   := .T.
Local lGrava    := .T.
Local cFilXml   := ""
Local cDTTime   := ""	//FR - 08/09/2020
Default lForcaSem := .F.

cKey := Substr( cKey+space( len( (xZBE)->(FieldGet(FieldPos(xZBE_+"CHAVE"))) ) ), 1, len( (xZBE)->(FieldGet(FieldPos(xZBE_+"CHAVE"))) ) )

DbSelectArea(xZBZ)
DbSetOrder(3)

If !Empty(cKey) .And. ( DbSeek(alltrim(cKey)) .or. lForcaSem )

	if (xZBZ)->( Found() )
		cFilXml := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL")))
	else
		cFilXml := xFilial(xZBE)
	endif

	If cEvento <> 'HXL069'  //FR - 22/09/2020 - eventos de erro para redownload

		DbSelectArea(xZBE)
		DbSetOrder(3)
		If DbSeek( cFilXml+cEvento+cKey+cSeqEve )
	
			If (xZBE)->&(xZBE_+"STATUS") == "1"
	
				cRet := "-2"  //Evento já Cadastrado ZBE
				lGrava := .F.
	
			Else
	
				cRet := "1"  //Atualizar, já existe o evento
				lGrava  := .T.
				lAppend := .F.
	
			EndIf
	
		Else
	
			cRet := "0"  //Novo Evento Incluido
			lGrava  := .T.
			lAppend := .T.
	
		EndIF

    Else

    	//FR - 22/09/2020 - qdo for evento de erro, sempre gravar um novo, porque a query que apresenta em tela, pegará sempre o último 
    	cRet := "0"
   		lGrava  := .T.
		lAppend := .T.
    	
    Endif

	If lGrava

        cDTTime := U_FRDTHora(1,dDatabase, Time(),"")   //U_FRDTHora(nTipo,dData, cTime, cData)
		Reclock(xZBE,lAppend)
		(xZBE)->(FieldPut(FieldPos(xZBE_+"CHAVE") , cKey      )) //cKey+cEvento+cSeqEve
		(xZBE)->(FieldPut(FieldPos(xZBE_+"FILIAL"), cFilXml   ))
		(xZBE)->(FieldPut(FieldPos(xZBE_+"TPEVE") , cEvento   ))
		(xZBE)->(FieldPut(FieldPos(xZBE_+"SEQEVE"), cSeqEve   ))
        (xZBE)->(FieldPut(FieldPos(xZBE_+"DTHRGR"), cDTTime   ))

		For nY := 1 To Len( aEvt )
			(xZBE)->(FieldPut(FieldPos(aEvt[nY][1]), aEvt[nY][2] ))
		Next nY

		(xZBE)->(MsUnLock())
		//				(xZBE)->(FieldPut(FieldPos(xZBZ_+"PRENF") , "X" ))
		//				(xZBE)->(FieldPut(FieldPos(xZBZ_+"MAIL")  , "3" ))
		//				(xZBE)->(FieldPut(FieldPos(xZBZ_+"DTMAIL"), cOcorr ))

		if (xZBZ)->( Found() )  //Atualizar Manif

			if cEvento $ "210200,210210,210220,210240,610110"

				/*cMan := " "

				if cEvento == "210200"

					cMan := "1"

				ElseIF cEvento == "210210"

					cMan := "4"

				ElseIF cEvento == "210220"

					cMan := "2"

				ElseIF cEvento == "210240"

					cMan := "3"

				ElseIF cEvento == "610110"

					cMan := "5"

				Endif*/

				cMan := "1"

				IF !Empty(cMan)

					dbSelectArea( xZBZ )

					Reclock(xZBZ,.F.)
					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"MANIF"), cMan ))
					MsUnlock()

					dbSelectArea( xZBE )

				EndIF

			Endif

		Endif

		/*if aHfCloud[1] == "1"
			U_HFCLDEnv(,,,"2")  //AQUIIIII
		EndIF*/

	EndIf

Else

	cRet := "-1"  //Chave não encontrada na ZBZ

EndIf

RestArea( aArea )

Return( cRet )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CancXmlAll    º Autor ³ Roberto Souza      º Data ³  23/04/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ XML dos Fornecedores referente a NF-e, CT-e                    º±±
±±º          ³                                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Importa XML                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CancXmlAll(cModelo,cXml,cFilename,oMessage,nInd,nOpc,lInvalid,cLogProc,cFilXml,cKeyXml,cOcorr,aFilsEmp,oXmloK)

Local cError    := ""
Local cWarning  := ""
//Local cOcorr    := ""
//Local lGrava    := .T.
//Local lAppend   := .T.
//Local lXmlCanc  := .F.
//Local cMensagem := ""
//Local lValidado := .T.
//Local lConsulta := .T.
//Local nModoMail := 1
//Local cAnexo    := ""
//Local cChaveXml := ""
//Local cTipoDoc  := "N"  // Validar Tipo de DOcumento
Local lContinua := .T.
Local lEvento   := .F.
Local cEvento   := ""
Local cStatReg  := "1"
Local cSeqEve   := ""
Local dDhAut    := ctod( "" )
Local aEvt      := {}
Local cGrv      := ""

Private cTagEvento:= ""
Private cPref     := ""
Private cTag      := ""
Private cTagTpEmiss:= ""
Private cTagTpAmb  := ""
Private cTagCHId   := ""
Private cTagSign   := ""
Private cTagProt   := ""
Private cKey       := ""
Private cTagDocEmit:= ""
Private cTagDocXMl := ""
Private cTagSerXml := ""
Private cTagDtEmit := ""
Private cTagDocDest:= ""
Private cTipoToma  := ""
Private cDtHrCOns  := ""
Private cTagId     := ""
Private cTagRet    := ""
Private oXml

Default nOpc    := 1
Default lInvalid:= .F.
Default cLogProc:= ""
Default cURL    := AllTrim(GetNewPar("XM_URL",""))
Default cOcorr  := ""

If Empty(cURL)
	cURL  := AllTrim(SuperGetMv("MV_SPEDURL"))
EndIf

If cModelo == "55"

	cPref    := "NF-e"
	cTAG     := "NFE"

ElseIf cModelo == "65"

	cPref    := "NFC-e"
	cTAG     := "NFE"

ElseIf cModelo == "57"

	cPref    := "CT-e"
	cTAG     := "CTE"

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Validação da estrutura do XML.       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oXml := XmlParser( cXml, "_", @cError, @cWarning )

if Empty( oXml )

	cXml := NoAcento(cXml)
	cXml := EncodeUTF8(cXml)

	//Faz backup do xml sem retirar os caracteres especiais
	cBkpXml := cXml

	//Executa rotina para retirar os caracteres especiais
	cXml := u_zCarEspec( cXml )

	oXml := XmlParser( cXml, "_", @cError, @cWarning )

	//retorna o backup do xml
	cXml := cBkpXml

endif

If Empty(cError) .And. Empty(cWarning) .And. !lInvalid

	cTagId := "oXml:_PROCCANC"+cTAG+":_CANC"+cTAG+":_INFCANC"
	cTagRet:= "oXml:_PROCCANC"+cTAG+":_RETCANC"+cTAG+":_INFCANC"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Validação Info do cancelamento       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Type(cTagId)== "U"

		cTagId := "oXml:_PROCEVENTO"+cTAG+":_EVENTO"+":_INFEVENTO"

		if Type("oXml:_PROCEVENTO"+cTAG+":_RETENVEVENTO"+":_RETEVENTO"+":_INFEVENTO") <> "U"
		
			cTagRet := "oXml:_PROCEVENTO"+cTAG+":_RETENVEVENTO"+":_RETEVENTO"+":_INFEVENTO"

		else

			cTagRet := "oXml:_PROCEVENTO"+cTAG+":_RETEVENTO"+":_INFEVENTO"

		endif

		If Type(cTagId)== "U"

			cError += CRLF+"O XML "+cFilename+" não possui as informações de cancelamento."
			lContinua := .F.

		else

			lEvento := .T.
			cTagEvento := "oXml:_PROCEVENTO"+cTAG+":_EVENTO"+":_INFEVENTO:_TPEVENTO:TEXT"

			If Type(cTagId)== "U"

				cError += CRLF+"O XML "+cFilename+" não possui evento de cancelamento."
				lContinua := .F.

			else

				cEvento := &(cTagEvento)

				if cEvento <> "110111"

					cError += CRLF+"O XML "+cFilename+" possui o evento diferente de cancelamento "+cEvento
					lContinua := .F.

				endif

			endif

		Endif

	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Validação Retorno do cancelamento    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Type(cTagRet) == "U"

		cError += CRLF+"O XML "+cFilename+" não possui retorno de cancelamento."
		lContinua := .F.

	EndIf

	If lContinua

		if lEvento

			if Type("oXml:_PROCEVENTO"+cTAG+":_EVENTO"+":_INFEVENTO") <> "U"

				oRetId := &("oXml:_PROCEVENTO"+cTAG+":_EVENTO"+":_INFEVENTO")

			endif

			if Type("oXml:_PROCEVENTO"+cTAG+":_RETENVEVENTO"+":_RETEVENTO"+":_INFEVENTO") <> "U"
			
				oRetC  := &("oXml:_PROCEVENTO"+cTAG+":_RETENVEVENTO"+":_RETEVENTO"+":_INFEVENTO")

			else
				
				if Type("oXml:_PROCEVENTO"+cTAG+":_RETEVENTO"+":_INFEVENTO") <> "U"

					oRetC := &("oXml:_PROCEVENTO"+cTAG+":_RETEVENTO"+":_INFEVENTO")

				else
					
					oRetC := ""

				endif

			endif

			cProt   := oRetId:_DETEVENTO:_NPROT:TEXT
			cKey    := &("oRetId:_CH"+cTAG+":TEXT")
			cJust   := oRetId:_DETEVENTO:_XJUST:TEXT

			cSeqEve := oRetC:_NSEQEVENTO:TEXT
			cProtC  := oRetC:_NPROT:TEXT
			cDthRet := oRetC:_DHREGEVENTO:TEXT
			cRetStat:= oRetC:_CSTAT:TEXT
			cMotX   := oRetC:_XMOTIVO:TEXT

		Else

			oRetId := &("oXml:_PROCCANC"+cTAG+":_CANC"+cTAG+":_INFCANC")
			oRetC  := &("oXml:_PROCCANC"+cTAG+":_RETCANC"+cTAG+":_INFCANC")

			cProt   := oRetId:_NPROT:TEXT
			cKey    := &("oRetId:_CH"+cTAG+":TEXT")
			cJust   := oRetId:_XJUST:TEXT

			cSeqEve := "01"
			cProtC  := oRetC:_NPROT:TEXT
			cDthRet := oRetC:_DHRECBTO:TEXT
			cRetStat:= oRetC:_CSTAT:TEXT
			cMotX   := oRetC:_XMOTIVO:TEXT

		Endif

		if len(cSeqEve)<=len( (xZBE)->(FieldGet(FieldPos(xZBE_+"SEQEVE"))) )
			cSeqEve := StrZero( Val(cSeqEve), len( (xZBE)->(FieldGet(FieldPos(xZBE_+"SEQEVE"))) ), 0 )
		endif

		DbSelectArea(xZBZ)
		DbSetOrder(3)
		If DbSeek(alltrim(cKey))

			If (xZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF"))) == "X"

				cOcorr += "Cancelamento de xml: "+cPref +CRLF
				cOcorr += "Chave :" + cKey 	 +CRLF
				cOcorr += "Obs.  :" + "Xml de "+cPref+ " já está cancelado na base de dados." +CRLF

				Reclock(xZBZ,.F.)     //Faltava isto, gravar o xml de cancelamento. (QUATROK).

				if empty( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"DTHCAN"))) )
					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"DTHCAN"), cDthRet ))
				endif

				if empty((xZBZ)->(FieldGet(FieldPos(xZBZ_+"XMLCAN"))) )
					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"XMLCAN"), cXml ))
				endif

				if empty((xZBZ)->(FieldGet(FieldPos(xZBZ_+"PROTC"))) )
					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PROTC") , cProtC ))
				endif

				MsUnLock()

			Else

				cOcorr += "Tipo de xml: " + cPref +CRLF
				cOcorr += "Chave      : " + cKey +CRLF
				cOcorr += "Observação : " + "Cancelamento do Xml de "+cPref+ " autorizado." +CRLF
				cOcorr += "Aviso      : " + "Cancele o documento de "+cPref+ " manualmente." +CRLF

				cOcorr:= U_GetInfoErro("3",cOcorr,cModelo)

				Reclock(xZBZ,.F.)

				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"DTHCAN"), cDthRet ))
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"XMLCAN"), cXml ))
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PROTC") , cProtC ))
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PRENF") , "X" ))

				if (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MAIL"))) <> "4"
					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"MAIL")  , "3" ))
				endif

				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"DTMAIL"), cOcorr ))
				MsUnLock()

			EndIf

			aEvt := {}
			dDhAut  := StoD(substr(cDthRet,1,4)+Substr(cDthRet,6,2)+Substr(cDthRet,9,2))

			aadd( aEvt, {xZBE_+"DHAUT" 	, dDhAut    })
			aadd( aEvt, {xZBE_+"DTRECB"	, dDataBase })
			aadd( aEvt, {xZBE_+"PROT"  	, cProtC    })
			aadd( aEvt, {xZBE_+"XML"   	, cXml      })
			aadd( aEvt, {xZBE_+"DESC"  	, cJust     })
			aadd( aEvt, {xZBE_+"EVENTO"	, cJust     })
			aadd( aEvt, {xZBE_+"STATUS"	, cStatReg  })

			cGrv := U_HF2GrvEv( cKey, cEvento, cSeqEve, aEvt, .T. )

			if cGrv == "-2"

				cError += "Este XML Evento de Cancelamento já esta na Base de Dados. A importação será Cancelada."+CRLF
				cLogProc += "[XML] Evento de Cancelamento já consta na Base de Dados. " +cFilename +CRLF

			ElseIf cGrv == "1" .Or. cGrv == "0"

				cOcorr += "Evento de xml: "+cPref +CRLF
				cOcorr += "Chave :" + cKey 	 +CRLF
				cOcorr += "Aviso        : " + "Faça Manutenção no documento de "+cPref+ " manualmente." +CRLF
				cLogProc += "[XML] Evento de Cancelamento importado com sucesso. " +cFilename +CRLF

			ElseIf cGrv == "-1"

				cOcorr += "Evento de Cancelamento de xml: "+cPref +CRLF
				cOcorr += "Chave :" + iif(Empty(cKey),"Vazia","") + cKey 	 +CRLF
				cOcorr += "Obs.  :" + "Não foi encontrado o Xml Importado de "+cPref+ "." +CRLF

			EndIf

		Else

			cOcorr += "Cancelamento de xml: "+cPref +CRLF
			cOcorr += "Chave :" + cKey 	 +CRLF
			cOcorr += "Obs.  :" + "Não foi encontrado o Xml de "+cPref+ "." +CRLF

		EndIf

		//		SendMailCanc(1,cModelo,cKey,cFilename,cOcorr,cError,cWarning)
	Else
		//		SendMailError(1,cModelo,oXml,cFilename,cOcorr,cError,cWarning,.T.)
	EndIf
Else

	//	SendMailError(1,cModelo,oXml,cFilename,cOcorr,cError,cWarning,.T.)

EndIf

cFilXml := cFilAnt
cKeyXml := cKey
cOcorr  += cError
oXmloK  := oXml

Return(.T.)

******************************************************************************************
Static Function	SendMailError(nTipo,cModelo,oXml,cFilename,cOcorr,cError,cWarning,lCanc)
******************************************************************************************

Local cPref   := ""
Local cTAG    := ""
Local cAnexo  := ""
Local cMsgErr := ""
Local nNotifica := Val(GetSrvProfString("HF_NOTIFICA","0"))
Default lCanc := .F.

if lCanc == NIL
	lCanc := .F.
endif

If cModelo == "55"
	cPref   := "NF-e"
	cTAG    := "NFE"
ElseIf cModelo == "65"
	cPref   := "NFC-e"
	cTAG    := "NFE"
ElseIf cModelo == "57"
	cPref   := "CT-e"
	cTAG    := "CTE"
EndIf

if lCanc
	cEmailErr := AllTrim(SuperGetMv("XM_MAIL01")) // Conta de Email para Cancelamentos
Else
	cEmailErr := AllTrim(SuperGetMv("XM_MAIL02")) // Conta de Email para erros
Endif
lMailErr := !Empty(cEmailErr)

If lMailErr

	aTo := Separa(cEmailErr,";")
	cMsg:=""

	If !Empty(cError)

		cMsg+= "ERROS : "
		cMsg+= cOcorr+CRLF+cError +CRLF

	EndIF

	If !Empty(cWarning)

		cMsg+= "AVISOS : "
		cMsg+= cOcorr+CRLF+cError +CRLF+ cWarning+CRLF

	EndIF

	cTagKey := "oXml:_"+cTAG+"PROC:_PROT"+cTAG+":_INFPROT:_CH"+cTAG+":TEXT"

	cMsg+= "XML Invalido: "+ cFilename

	If Type(cTagKey)<> "U"
		cMsg+= CRLF+"Chave :"+&(cTagKey)
	EndIf

	cAssunto:= "Aviso de Falha Xml/"+cPref+" de Entrada."
	cDirMail  := AllTrim(SuperGetMv("MV_X_PATHX")) + "\template\"+"xml_erro.html"
	cDirMail  := Iif(lUnix,StrTran(cDirMail,"\","/"),cDirMail)

	If File(cDirMail)
		cTemplate := MemoRead(cDirMail)
	Else
		cTemplate := ''
	EndIf

	cBodyMail := ""

	While !Empty(cTemplate)

		nPosIni := At("<%=",cTemplate)
		nPosFim := At("%>" ,SubStr(cTemplate,nPosIni+3))

		If nPosIni <> 0 .And. nPosFim <> 0

			cBodyMail += SubStr(cTemplate,1,nPosIni-1)
			cMacro := ""
			lBreak := .F.
			bErro  := ErrorBlock({|e| lBreak := .T. })

			Begin Sequence

				cMacro := SubStr(cTemplate,nPosIni+3,nPosFim-1)
				cMacro := &(cMacro)

				If lBreak
					Break
				EndIf

				Recover
				cMacro := "Error"
			End Sequence

			ErrorBlock(bErro)
			cBodyMail += AllTrim(cMacro)
			cTemplate := SubStr(cTemplate,nPosIni+nPosFim+4)

		Else

			cBodyMail += cTemplate
			cTemplate := ""

		EndIf

	EndDo

	If  !Empty(cBodyMail)
		cMsg := cBodyMail
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia E-mail.                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nNotifica == 2

		U_HfSetMail(aTo,cAssunto,cMsg,@cMsgErr,cAnexo,cAnexo,cEmailErr)

	Else

		//U_HX_MAIL(aTo,cAssunto,cMsg,@cMsgErr,cAnexo,cAnexo,cEmailErr)
		U_MAILSEND(aTo,cAssunto,cMsg,@cError,cAnexo,cAnexo,cEmailErr,"","")

	EndIf

EndIf

Return(cMsgErr)

***************************************************************************
User Function SdMailEr(nTipo,cModelo,oXml,cFilename,cOcorr,cError,cWarning)
***************************************************************************

SendMailError(nTipo,cModelo,oXml,cFilename,cOcorr,cError,cWarning)

Return( NIL )
	

**********************************************************************************
/*Static Function	SendMailCanc(nTipo,cModelo,cKey,cFilename,cOcorr,cError,cWarning)
**********************************************************************************

Local cPref     := ""
Local cTAG      := ""
Local cAnexo    := ""

Local nNotifica := Val(GetSrvProfString("HF_NOTIFICA","0"))

If cModelo == "55"

	cPref   := "NF-e"
	cTAG    := "NFE"

ElseIf cModelo == "65"

	cPref   := "NFC-e"
	cTAG    := "NFE"

ElseIf cModelo == "57"

	cPref   := "CT-e"
	cTAG    := "CTE"

ElseIf cModelo == "67"

	cPref   := "CT-eOS"
	cTAG    := "CTEOS"

EndIf

cEmailErr := AllTrim(SuperGetMv("XM_MAIL01")) // Conta de Email para cancelamentos
lMailErr := !Empty(cEmailErr)

If lMailErr

	aTo := Separa(cEmailErr,";")
	cMsg:= cOcorr

	If !Empty(cError)

		cMsg+= CRLF+"ERROS : "
		cMsg+= cError

	EndIF

	If !Empty(cWarning)

		cMsg+= CRLF+"AVISOS : "
		cMsg+= cOcorr+CRLF+cError +CRLF+ cWarning+CRLF

	EndIF

	cTagKey := "oXml:_"+cTAG+"PROC:_PROT"+cTAG+":_INFPROT:_CH"+cTAG+":TEXT"

	//		cMsg+= CRLF+"Chave :"+cKey
	cAssunto:= "Aviso de Cancelamento Xml/"+cPref+" de Entrada."
	cDirMail  := AllTrim(SuperGetMv("MV_X_PATHX")) + "\template\"+"xml_erro.html"
	cDirMail  := Iif(lUnix,StrTran(cDirMail,"\","/"),cDirMail)

	If File(cDirMail)

		cTemplate := MemoRead(cDirMail)

	Else

		cTemplate := ''

	EndIf

	cBodyMail := ""

	While !Empty(cTemplate)

		nPosIni := At("<%=",cTemplate)
		nPosFim := At("%>" ,SubStr(cTemplate,nPosIni+3))

		If nPosIni <> 0 .And. nPosFim <> 0

			cBodyMail += SubStr(cTemplate,1,nPosIni-1)
			cMacro := ""
			lBreak := .F.
			bErro  := ErrorBlock({|e| lBreak := .T. })

			Begin Sequence

				cMacro := SubStr(cTemplate,nPosIni+3,nPosFim-1)
				cMacro := &(cMacro)
				If lBreak
					Break
				EndIf

				Recover
				cMacro := "Error"

			End Sequence

			ErrorBlock(bErro)
			cBodyMail += AllTrim(cMacro)
			cTemplate := SubStr(cTemplate,nPosIni+nPosFim+4)

		Else

			cBodyMail += cTemplate
			cTemplate := ""

		EndIf

	EndDo

	If  !Empty(cBodyMail)

		cMsg := cBodyMail

	Else

		cMsgCfg := ""
		cMsgCfg += '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
		cMsgCfg += '<html xmlns="http://www.w3.org/1999/xhtml">'
		cMsgCfg += '<head>'
		cMsgCfg += '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />'
		cMsgCfg += '<title>Importa XML</title>'
		cMsgCfg += '  <style type="text/css"> '
		cMsgCfg += '	<!-- '
		cMsgCfg += '	body {background-color: rgb(37, 64, 97);}'
		cMsgCfg += '	.style1 {font-family: Hyperfont,Verdana, Arial;font-size: 12pt;} '
		cMsgCfg += '	.style2 {font-family: Segoe UI,Verdana, Arial;font-size: 12pt;color: rgb(255,0,0)} '
		cMsgCfg += '	.style3 {font-family: Segoe UI,Verdana, Arial;font-size: 10pt;color: rgb(37,64,97)}'
		cMsgCfg += '	.style4 {font-size: 8pt; color: rgb(37,64,97); font-family: Segoe UI,Verdana, Arial;} '
		cMsgCfg += '	.style5 {font-size: 10pt} '
		cMsgCfg += '	--> '
		cMsgCfg += '  </style>'
		cMsgCfg += '</head>'
		cMsgCfg += '<body>'
		cMsgCfg += '<table style="background-color: rgb(240, 240, 240); width: 800px; text-align: left; margin-left: auto; margin-right: auto;" id="total" border="0" cellpadding="12">'
		cMsgCfg += '  <tbody>'
		cMsgCfg += '    <tr>'
		cMsgCfg += '      <td colspan="2">'
		cMsgCfg += '    <Center>'
		//			cMsgCfg += '      <img src="http://extranet.helpfacil.com.br/images/cabecalho.jpg">
		cMsgCfg += '      <H2>CANCELAMENTO</H2>'
		cMsgCfg += '      </Center>'
		cMsgCfg += '      <hr>'
		cMsgCfg += '      <p class="style1">'+cMsg+'</p>'
		cMsgCfg += '      <hr>	'
		cMsgCfg += '      </td>'
		cMsgCfg += '    </tr>'
		cMsgCfg += '  </tbody>'
		cMsgCfg += '</table>'
		cMsgCfg += '<p class="style1">&nbsp;</p>'
		cMsgCfg += '</body>'
		cMsgCfg += '</html>'
		cMsg    := cMsgCfg

	endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia E-mail.                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nNotifica == 2
		U_HfSetMail(aTo,cAssunto,cMsg,@cError,cAnexo,cAnexo,cEmailErr)
	Else
		U_HX_MAIL(aTo,cAssunto,cMsg,@cError,cAnexo,cAnexo,cEmailErr)
	EndIf

EndIf

Return*/
	

*******************************************
User Function XGetFilS(cCnpjRoot,aFilsLic)
*******************************************

Local aRet    := {}
Local aArea   := GetArea()
Local cEmpProc:= AllTrim(SM0->M0_CODIGO)
//Local cFilProc:= AllTrim(SM0->M0_CODFIL)
Local lSizeSm := .F.   //Se for gestão de empresas verificar todas empresas, não só filiais
Local nRecFil := 1

DbSelectArea("SM0")

IF FCount("M0_SIZEFIL") > 0 .AND. SM0->M0_SIZEFIL > 2
	lSizeSm := .T.
EndIf

nRecFil := Recno()
DbGotop()

While !Eof()

	//12.310.876/0001-90
	If Alltrim(SM0->M0_CODIGO) == cEmpProc .OR. lSizeSm  //.And. Alltrim(Substr(SM0->M0_CGC,1,8))== Alltrim(Substr(cCnpjRoot,1,8))

		// a Partir 10/04/14 vai verificar cada filial exclusivamente, então verificar se tem licença cada CNPJ.
		//If U_HFXML00X("HF000001","101",SM0->M0_CGC,,.F.)

		If U_HFXMLLIC(.F.)

			Aadd(aRet,{SM0->M0_CODFIL,SM0->M0_CGC,SM0->M0_FILIAL,SM0->M0_NOMECOM,SM0->M0_INSC})

		Else

			//Filiais sem licença
			Aadd(aFilsLic,{SM0->M0_CODFIL,SM0->M0_CGC,SM0->M0_FILIAL,SM0->M0_NOMECOM,SM0->M0_INSC})

		EndIF

	EndIf

	DbSkip()

EndDO

dbgoto(nRecFil)
RestArea(aArea)

Return(aRet)


**************************************************
Static Function HfPutdt(nTipo,dData, cTime, cData)
**************************************************
Local xRet := Nil

If nTipo == 1

	xRet := dTos(dData)
	XRet := Substr(xRet,1,4)+"-"+Substr(xRet,5,2)+"-"+Substr(xRet,7,2)+"T"+cTime
	
EndIf

Return(xRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HFXML02E  º Autor ³ Roberto Souza      º Data ³  12/09/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ XML dos Fornecedores                                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Importa Xml                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function HFXML02E()

Local aArea := GetArea()

Processa( {|| ExpNFEFOR() }, "Aguarde...", "Exportando XML ...",.F.)

RestArea(aArea)

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ExpNFEFOR º Autor ³ Roberto Souza      º Data ³  12/09/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ XML dos Fornecedores                                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Importa Xml                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ExpNFEFOR()

Local cAliasZBZ:= GetNextAlias()
Local aPerg    := {}
Local cWhere   := ""
Local cTabela  := ""
Local aParam   := {Space(Len(SF2->F2_FILIAL)),Space(Len(SF2->F2_FILIAL)),Space(Len(SF2->F2_SERIE)),Space(Len(SF2->F2_DOC)),Space(Len(SF2->F2_DOC)),Space(60),CToD("01/01/2001"),dDataBase,Space(14),Space(14),CToD("01/01/2001"),dDataBase}
Local cParXMLExp := AllTrim(SM0->M0_CODIGO)+AllTrim(SM0->M0_CODFIL)+"HFXMLEXP"
Local cExt     := ".xml"
Local cNfes    := ""
Local _cLoad   := ""
Local cVersao  := "20140214"
Local cArqVer  := cBarra+"profile"+cBarra+__cUserID+"_"+cParXMLExp+".Exp"
Local cLidVer  := ""
Local nHandle  := 0
Local cProfile := ""
Local nLinha   := 0
Local aCombo   := {}
Local cTAG     := ""
Local aModel   := {} 		//15/02/2021 - #6212 - MaxiRubber

If .NOT. File( cArqVer )

	cLidVer := ""

Else

	cLidVer := LerComFRead( cArqVer )

EndIf

If cLidVer != cVersao

	//Foi mudado Algo nos parametros. Apagar o tal arquivo para criar novamente.
	if File( cBarra+"profile"+cBarra+__cUserID+"_"+cParXMLExp+".PRB" )

		nErase := FErase( cBarra+"profile"+cBarra+__cUserID+"_"+cParXMLExp+".PRB" )
		If nErase < 0

			U_MYAviso("ERRO","Não foi possivel recriar o arquivo "+__cUserID+"_"+cParXMLExp+".PRB. Verifique permissões de gravação na Pasta \profile\.",{"Ok"},3)
			Return( NIL )

		EndIf

	EndIf

	nHandle := FCreate(cArqVer)

	If nHandle <= 0

		U_MYAviso("ERRO","Não foi possivel criar o arquivo "+cArqVer+". Verifique permissões de gravação na Pasta \profile\.",{"Ok"},3)
		Return( NIL )

	Else

		FWrite(nHandle, cVersao)
		FClose(nHandle)

	EndIf

EndIf

If ParamLoad(cParXMLExp,aParam,0,"1")== "2"

	_cLoad := ""

Else

	_cLoad := __cUserID+"_"

Endif

if valtype(aParam[07]) <> "D"

	aParam[07] := ctod("01/01/2001")

endif

if valtype(aParam[08]) <> "D"

	aParam[08] := dDataBase

endif

aCombo := {}

aAdd( aCombo, "T=Todos" )
aAdd( aCombo, "B=Importado" )
aAdd( aCombo, "A=Aviso Recbto Carga"   )
aAdd( aCombo, "S=Pre-Nota a Classificar"   )
aAdd( aCombo, "N=Pre-Nota Classificada"   )
aAdd( aCombo, "F=Falha de Importacao"   )
aAdd( aCombo, "X=Xml Cancelado"   )
aAdd( aCombo, "Z=Xml Rejeitado"   )
//FR - 15/02/2021 - #6212 - MaxiRubber
aModel := {}
aAdd( aModel, "1=NFE" )
aAdd( aModel, "2=CTE" )
aAdd( aModel, "3=NFCE" )
aAdd( aModel, "4=NFSE" )
aAdd( aModel, "5=Todos" )
//FR - 15/02/2021 - #6212 - MaxiRubber

aadd(aPerg,{1,"Filial Inicial"       ,aParam[01],"",".T.","",".T.",30,.F.}) //"Filial Inicial"
aadd(aPerg,{1,"Filial final"         ,aParam[02],"",".T.","",".T.",30,.F.}) //"Filial final"
aadd(aPerg,{1,"Serie da Nota Fiscal" ,aParam[03],"",".T.","",".T.",30,.F.}) //"Serie da Nota Fiscal"
aadd(aPerg,{1,"Nota fiscal inicial"  ,aParam[04],"",".T.","",".T.",30,.T.}) //"Nota fiscal inicial"
aadd(aPerg,{1,"Nota fiscal final"    ,aParam[05],"",".T.","",".T.",30,.T.}) //"Nota fiscal final"
aadd(aPerg,{6,"Diretório de destino" ,aParam[06],"",".T.","!Empty(mv_par06)",80,.T.," |*.","c:\",GETF_RETDIRECTORY+GETF_LOCALHARD}) //"Diretório de destino"
aadd(aPerg,{1,"Data Inicial"         ,aParam[07],"",".T.","",".T.",50,.T.}) //"Data Inicial"
aadd(aPerg,{1,"Data Final"           ,aParam[08],"",".T.","",".T.",50,.T.}) //"Data Final"
aadd(aPerg,{1,"CNPJ Inicial"         ,aParam[09],"",".T.","",".T.",50,.F.}) //"CNPJ Inicial"
aadd(aPerg,{1,"CNPJ final"           ,aParam[10],"",".T.","",".T.",50,.F.}) //"CNPJ final"
aadd(aPerg,{1,"Dt.Rec.XML Inicial"   ,aParam[11],"",".T.","",".T.",50,.T.}) //"Dt.Rec.XML Inicial"
aadd(aPerg,{1,"Dt.Rec.XML Final"     ,aParam[12],"",".T.","",".T.",50,.T.}) //"Dt.Rec.XML Final"
aadd(aPerg,{2,"Flag XML"             ,""    ,aCombo,100,".T.",.T.,".T."}) //"Flag XML" -> aCombo
//aadd(aPerg,{2,"Flag XML"             ,aParam[13],aCombo,100,".T.",.T.,".T."}) //"Flag XML" -> aCombo
aadd(aPerg,{2,"Modelo"               ,""    ,aModel,100,".T.",.T.,".T."}) //"Modelos XML" -> aModel		//15/02/2021 - #6212 - MaxiRubber

if AllTrim( ParamLoad(_cLoad+cParXMLExp,aPerg, 9,"NADA") ) == "NADA" .and.;
AllTrim( ParamLoad(_cLoad+cParXMLExp,aPerg,10,"NADA") ) == "NADA"

	ParamSave(_cLoad+cParXMLExp,aPerg,"1")

endif

If cLidVer != cVersao

	nHandle := FT_FUse( cBarra+"profile"+cBarra+__cUserID+"_"+cParXMLExp+".PRB" )

	if nHandle != -1

		FT_FGoTop()
		nLinha := 0

		While !FT_FEOF()

			cBuf := FT_FReadLn() // Retorna a linha corrente
			nLinha++

			if nLinha == 8 .or. nLinha == 9

				If Substr(cBuf,1,1) <> "D"
					cBuf := "D"+Substr(cBuf,2,len(cBuf))
				EndIf

			endif

			cProfile := cProfile + cBuf + ( Chr( 13 ) + Chr( 10 ) )
			FT_FSKIP()

		End

		FT_FUSE()

		MemoWrite(cBarra+"profile"+cBarra+__cUserID+"_"+cParXMLExp+".PRB",cProfile)

	EndIf

EndIf

If ParamBox(aPerg,"Importa XML - Exportar",@aParam,,,,,,,cParXMLExp,.T.,.T.)

	cTabela:= "%"+RetSqlName(xZBZ)+"%"
	cWhere := "%("
	cWhere += "ZBZ."+xZBZ_+"FILIAL >='"+aParam[01]+"' AND ZBZ."+xZBZ_+"FILIAL <='"+aParam[02]+"'"
	cWhere += "AND ZBZ."+xZBZ_+"NOTA >='"+aParam[04]+"' AND ZBZ."+xZBZ_+"NOTA <='"+aParam[05]+"'"

	If !Empty(aParam[03])
		cWhere += "	AND ZBZ."+xZBZ_+"SERIE ='"+aParam[03]+"'"
	EndIf

	cWhere += "	AND ZBZ."+xZBZ_+"DTNFE >='"+DTos(aParam[07])+"' AND ZBZ."+xZBZ_+"DTNFE <='"+DTos(aParam[08])+"'"

	If .not. Empty( aParam[12] )
		cWhere += "	AND ZBZ."+xZBZ_+"DTRECB >='"+DTos(aParam[11])+"' AND ZBZ."+xZBZ_+"DTRECB <='"+DTos(aParam[12])+"'"
	EndIf

	If ( .not. Empty( aParam[10] ) ) .Or. ( .not. Empty(aParam[09] ) )
		cWhere += "	AND ZBZ."+xZBZ_+"CNPJ >='"+aParam[09]+"' AND ZBZ."+xZBZ_+"CNPJ <='"+aParam[10]+"'"
	endif

	if .Not. Empty( aParam[13] ) .And. aParam[13] <> "T"
		cWhere += "	AND ZBZ."+xZBZ_+"PRENF ='"+aParam[13]+"'"
	endif

	//FR - 15/02/2021 - #6212 - MaxiRubber
	If .Not. Empty( aParam[14] ) .AND. aParam[14] <> "5"
		/*
		aAdd( aModel, "1=NFE" )
		aAdd( aModel, "2=CTE" )
		aAdd( aModel, "3=NFCE" )
		aAdd( aModel, "4=NFSE" )
		aAdd( aModel, "5=Todos" )
		*/
		If aParam[14] == '1'		//NFE
			cWhere += "	AND ZBZ."+xZBZ_+"MODELO  = '55' "
		Elseif aParam[14] == '2'	//CTE
			cWhere += "	AND ZBZ."+xZBZ_+"MODELO  IN ('57','67') "
		Elseif aParam[14] == '3'	//NFCE
			cWhere += "	AND ZBZ."+xZBZ_+"MODELO = '65' "
		Elseif aParam[14] == '4'	//NFSE
			cWhere += "	AND ZBZ."+xZBZ_+"MODELO = 'RP' "
		Endif
	Endif
	//15/02/2021 - #6212 - MaxiRubber
	cWhere += " )%"

	BeginSql Alias cAliasZBZ

		SELECT	ZBZ.R_E_C_N_O_
		FROM %Exp:cTabela% ZBZ
		WHERE ZBZ.%notdel%
		AND %Exp:cWhere%
	EndSql

	DbSelectArea(cAliasZBZ)

	While !(cAliasZBZ)->(Eof())

		DbSelectArea(xZBZ)
		DbGoTo((cAliasZBZ)->R_E_C_N_O_)

		If (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO"))) == "55" 

			cTAG := "NFE"

		ElseIf (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO"))) == "57"
 	
			cTAG := "CTE"

		ElseIf (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO"))) == "65"

			cTAG := "NFCE"
	
		ElseIf (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO"))) == "67"

			cTAG := "CTEOS"

		ElseIf (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO"))) == "RP"
	
			cTAG := "NFSE"

		EndIf

		cNomeXML   := AllTrim(aParam[06])+alltrim((xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE")))) + "-"+cTAG+cExt
		cXMLExp    := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML")))

		MemoWrite(cNomeXML,cXMLExp)
		cNfes+= cNomeXML + CRLF

		(cAliasZBZ)->(DbSkip())

	EndDo

	If !Empty(cNfes)

		If U_MYAviso("Importa XML", "Visualiza detalhes",{"Sim","Não"}) == 1	//"Solicitação processada com sucesso."
			U_MYAviso("Detalhes","XML's Exportados para"+" "+Upper(AllTrim(aParam[06]))+CRLF+CRLF+cNFes,{"Ok"},3)
		EndIf

	EndIf

EndIF

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³COMP0005  ºAutor  ³Microsiga           º Data ³  09/13/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
USer Function HFXML2LC()

Local aLegenda := {}

AADD(aLegenda,{"BR_VERDE" 	,"Carta de Correção" })
AADD(aLegenda,{"BR_BRANCO"  ,"Xml Cancelado pelo Emissor" })
AADD(aLegenda,{"BR_LARANJA"	,"Confirmação da Operação" })
AADD(aLegenda,{"BR_AMARELO" ,"Ciência da Operação" })
AADD(aLegenda,{"BR_PRETO"	,"Desconhecimento da Operação" })
AADD(aLegenda,{"BR_VERMELHO","Operação não Realizada" })
AADD(aLegenda,{"BR_PRETO_0" ,"Redownload" 					})

BrwLegenda("Eventos e Carta de Correção", "Legenda", aLegenda)

Return Nil

	************************
User Function HFXML02L()
	************************
Local aLegenda := {}
Local aCabBrw 	:= {"Legenda","Descrição"}
Local aLeg1 	:= {}
Local aLeg2		:= {}
Local oDlg
Local oTwBrw1
Local oTwBrw2
Local oAmar 	:= LoadBitmap(GetResources(),'br_amarelo')
Local oAzul		:= LoadBitmap(GetResources(),'br_azul')
Local oBran		:= LoadBitmap(GetResources(),'br_branco') 
Local oCinz		:= LoadBitmap(GetResources(),'br_branco')
Local oLara		:= LoadBitmap(GetResources(),'br_laranja')
Local oMarr		:= LoadBitmap(GetResources(),'br_marrom')
Local oRosa 	:= LoadBitmap(GetResources(),'br_pink')
Local oPret		:= LoadBitmap(GetResources(),'br_preto') 
Local oVerd 	:= LoadBitmap(GetResources(),'br_verde')
Local oVerm 	:= LoadBitmap(GetResources(),'br_vermelho')
Local oViol		:= LoadBitmap(GetResources(),'br_violeta')
Local oVeEs		:= LoadBitmap(GetResources(),'br_verde_escuro')
Local oFont
Local oSay1
Local oSay2

If GetNewPar("XM_USASTAT" ,"N") == "S" 

	AADD(aLeg1,{oAzul,"XML Importado" 					})
	AADD(aLeg1,{oMarr,"XML Importado Resumido" 			})
	AADD(aLeg1,{oCinz,"XML Especial Importado"	 		})
	AADD(aLeg1,{oPret,"Falha de Importação" 			})
	AADD(aLeg1,{oLara,"Aviso Recbto Carga" 				})
	AADD(aLeg1,{oBran,"XML Cancelado pelo Emissor" 		})
	AADD(aLeg1,{oAmar,"XML Rejeitado" 					})
	AADD(aLeg1,{oVeEs,"XML de Produtor Rural" 			})
	AADD(aLeg1,{oViol,"XML Denegado" 					})
	AADD(aLeg1,{oVerd,"Pré-Nota a Classificar" 			})
	AADD(aLeg1,{oVerm,"Pré-Nota Classificada" 			})
	AADD(aLeg1,{oRosa,"Pré-Nota Especial Classificada"	})

	AADD(aLeg2,{oBran,"Não Manifestado" 				})
	AADD(aLeg2,{oVerd,"Confirmação da Operção" 			})
	AADD(aLeg2,{oVerm,"Operação Desconhecida" 			})
	AADD(aLeg2,{oAmar,"Operação Não Realizada" 			})
	AADD(aLeg2,{oAzul,"Ciência da Operação" 			})
	AADD(aLeg2,{oCinz,"Manifestação CTe" 				})
	AADD(aLeg2,{oMarr,"Pendente Conf.Operação" 			})
	AADD(aLeg2,{oViol,"Pendente Oper.Desconhecida" 		})
	AADD(aLeg2,{oRosa,"Pendente Oper.Não Realizada"		})
	AADD(aLeg2,{oLara,"Pendente Ciência da Operação"	})
	AADD(aLeg2,{oPret,"Outros"			 				})

			
	DEFINE MSDIALOG oDlg FROM 0,0 TO 500,1000 PIXEL TITLE "Legendas Gestão XML"

	 	oFont := TFont():New('Courier new',,-18,.T.)
  
 		oSay1:= TSay():New(001,100,{||'Status XML'}		,oDlg,,oFont,,,,.T.,CLR_BLUE,CLR_WHITE,200,20)
 		oSay2:= TSay():New(001,350,{||'Status Evento'}	,oDlg,,oFont,,,,.T.,CLR_BLUE,CLR_WHITE,200,20)

		oTwBrw1:=TWBrowse():New(12,0,250,210,,aCabBrw,{50,100},oDlg, ,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
		oTwBrw1:SetArray(aLeg1)  
		oTwBrw1:bLine := {||{ aLeg1[oTwBrw1:nAt,1],aLeg1[oTwBrw1:nAt,2]}}             

		oTwBrw2:=TWBrowse():New(12,250,250,210,,aCabBrw,{50,100},oDlg, ,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
		oTwBrw2:SetArray(aLeg2)  
		oTwBrw2:bLine := {||{ aLeg2[oTwBrw2:nAt,1],aLeg2[oTwBrw2:nAt,2]}}  

		TButton():New(225,220,'Fechar'		,oDlg,{|| oDlg:End()									},50,20,,,,.T.)

	ACTIVATE MSDIALOG oDlg CENTERED  
													
Else
	AADD(aLegenda,{"BR_AZUL"    	,"XML Importado" 					})
	AADD(aLegenda,{"BR_MARROM"  	,"XML Importado Resumido" 			})
	AADD(aLegenda,{"BR_CINZA"   	,"XML Especial Importado"	 		})	//FR - 31/08/2020 - Rafael solicitou mediante projeto Kroma 
	AADD(aLegenda,{"BR_PRETO"		,"Falha de Importação" 				})
	AADD(aLegenda,{"BR_LARANJA"		,"Aviso Recbto Carga" 				})
	AADD(aLegenda,{"BR_BRANCO"  	,"XML Cancelado pelo Emissor" 		})
	AADD(aLegenda,{"BR_AMARELO" 	,"XML Rejeitado" 					})
	AADD(aLegenda,{"BR_VERDE_ESCURO","XML de Produtor Rural" 			})
	AADD(aLegenda,{"BR_VIOLETA" 	,"XML Denegado" 					})
	AADD(aLegenda,{"BR_VERDE" 		,"Pré-Nota a Classificar" 			})
	AADD(aLegenda,{"BR_VERMELHO"	,"Pré-Nota Classificada" 			})
	AADD(aLegenda,{"BR_PINK"    	,"Pré-Nota Especial Classificada"	}) //FR - 31/08/2020 - Rafael solicitou mediante projeto Kroma

	BrwLegenda("GESTAO XML", "Legenda", aLegenda)

EndIf


Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ValidXml  º Autor ³ Roberto Souza      º Data ³  07/10/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Coloca o XML em uma estrutura padrão para leitura.         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Importa Xml                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ValidXml(cXml,cOcorr,lInvalid,cModelo,lCanc,lCCe)

Local lRet := .T.
Local nAt1 := nAt2 := nAt3 := nAt4 := 0
Local cNfe := ""
Local cProt:= ""
//Local cInfo:= ""
Local cError:=""
Local cWarning:=""
Local cVerXml := ""

//If "<NFE" $ Upper(cXml) .And. ('VERSAO="1.10"' $ Upper(cXml) .Or. "VERSAO='1.10'" $ Upper(cXml))
//	cModelo := "00"
//	lInvalid := .T.
//	lRet := .F.
//	cOcorr := "Modelo Inválido ou não homologado."
//	Return(lRet)
//EndIf

If "<NFE" $ Upper(cXml)

	nAt3:= At('SP_NFE_PL_008I2',Upper(cXml))  //<verAplic>SP_NFE_PL_008i2</verAplic>

	if nAt3 > 0                                //Inylbra 05/04/2018
		//	cXml := StrTran(cXml,"<verAplic>SP_NFE_PL_008i2</verAplic>","<verAplic>12.1.017 | 3.0</verAplic>")
	EndIf

	nAt3:= 0

	oXmlTeste := XmlParser( cXml, "_", @cError, @cWarning )

	if Empty( oXmlTeste )

		//Faz backup do xml sem retirar os caracteres especiais
		cBkpXml := cXml

		cXml := u_HFPRIULT( cXml ) //Analisa o primeiro e o ultimo digito do xml

		cXml := EncodeUTF8(cXml)
		cXml := FwNoAccent(cXml)

		//Executa rotina para retirar os caracteres especiais
		cXml := u_zCarEspec( cXml )

		oXmlTeste := XmlParser( cXml, "_", @cError, @cWarning )

		//retorna o backup do xml
		cXml := cBkpXml

	endif

	cTagVerXml := "oXmlTeste:_NFEPROC:_NFE:_INFNFE:_VERSAO:TEXT"

	If Type(cTagVerXml) <> "U"   //se não tiver a versão provavelmente é Prestação de Serviço, é outro modelo.

		cTagAux := "oXmlTeste:_NFEPROC:_NFE:_INFNFE:_IDE:_MOD:TEXT"

		If Type(cTagAux)<>"U"

			if &(cTagAux) == "65"

				cModelo := "65"

			Else

				cModelo := "55"

			Endif

		Else

			cModelo := "55"

		EndIf

	Else

		cTagAux := "oXmlTeste:_NFEPROC:_NFE:_INFNFE:_IDE:_MOD:TEXT"

		If Type(cTagAux)<>"U"

			cModelo := "55"  //por causa da Ynilbra

		else

			cModelo := "00"  //aqui pode dar problema na YnYlbra
			lInvalid := .T.
			lRet := .F.
			cOcorr := "Falha na estrutura ou caracter especial mal inserido"
			Return(lRet)

		endif

		//		if oXmlTeste == NIL
		//			lInvalid := .T.
		//			lRet := .F.
		//			cOcorr := AllTrim(cError)+AllTrim(cWarning)
		//			Return(lRet)
		//		Endif

	Endif

elseif "<RESNFE" $ Upper(cXml) 

	cModelo := "55"

ElseIf "<PROCCANCNFE" $ Upper(cXml) .or. ("<PROCEVENTONFE" $ Upper(cXml) .and. "<TPEVENTO>110111" $ Upper(cXml) )

	oXmlTeste := XmlParser( cXml, "_", @cError, @cWarning )

	if Empty( oXmlTeste )

		//Faz backup do xml sem retirar os caracteres especiais
		cBkpXml := cXml

		cXml := u_HFPRIULT( cXml ) //Analisa o primeiro e o ultimo digito do xml

		cXml := EncodeUTF8(cXml)
		cXml := FwNoAccent(cXml)

		//Executa rotina para retirar os caracteres especiais
		cXml := u_zCarEspec( cXml )

		oXmlTeste := XmlParser( cXml, "_", @cError, @cWarning )

		//retorna o backup do xml
		cXml := cBkpXml

	endif

	cTagAux := "oXmlTeste:_PROCEVENTONFE:_RETENVEVENTO:_RETEVENTO:_INFEVENTO_CHNFE:TEXT"

	if Type(cTagAux) == "U" 

		cTagAux := "oXmlTeste:_PROCEVENTONFE:_RETEVENTO:_INFEVENTO:_CHNFE:TEXT"

	endif

	If Type(cTagAux) <> "U"   //se não tiver a versão provavelmente é Prestação de Serviço, é outro modelo.

		cChvAux := &(cTagAux)

		If Substr(cChvAux,21,2) == "65"
			cModelo := "65"
		Else
			cModelo := "55"
		EndIf

	Else

		cModelo := "55"

	EndIf

ElseIf "<CTEOS" $ Upper(cXml) .Or. "<PROCCANCCTEOS" $ Upper(cXml)

	cModelo := "67"

ElseIf "<CTE" $ Upper(cXml) .Or. "<PROCCANCCTE" $ Upper(cXml)

	cModelo := "57"

ElseIf "<TPEVENTO>110110" $ Upper(cXml)  //CCE

	oXmlTeste := XmlParser( cXml, "_", @cError, @cWarning )

	if Empty( oXmlTeste )

		//Faz backup do xml sem retirar os caracteres especiais
		cBkpXml := cXml

		cXml := u_HFPRIULT( cXml ) //Analisa o primeiro e o ultimo digito do xml

		cXml := EncodeUTF8(cXml)
		cXml := FwNoAccent(cXml)

		//Executa rotina para retirar os caracteres especiais
		cXml := u_zCarEspec( cXml )

		oXmlTeste := XmlParser( cXml, "_", @cError, @cWarning )

		//retorna o backup do xml
		cXml := cBkpXml

	endif

	cTagAux := "oXmlTeste:_PROCEVENTONFE:_RETEVENTO:_INFEVENTO:_CHNFE:TEXT"

	If Type(cTagAux)=="U"
		cTagAux := "oXmlTeste:_PROCEVENTOCTE:_RETEVENTO:_INFEVENTO:_CHNFE:TEXT"
	EndIF

	If Type(cTagAux)=="U"
		cTagAux := "oXmlTeste:_PROCEVENTOCTEOS:_RETEVENTO:_INFEVENTO:_CHNFE:TEXT"
	EndIF

	If Type(cTagAux)<>"U"   //se não tiver a versão provavelmente é Prestação de Serviço, é outro modelo.

		cChvAux := &(cTagAux)

		If Substr(cChvAux,21,2) == "65"

			cModelo := "65"

		ElseIf Substr(cChvAux,21,2) == "57"

			cModelo := "57"

		ElseIf Substr(cChvAux,21,2) == "67"

			cModelo := "67"

		Else

			cModelo := "55"

		EndIf

	Else

		cModelo := "55"

	EndIf

Else

	cModelo := "00"
	lInvalid := .T.
	lRet := .F.
	cOcorr := "XML não é uma NFe."

	Return(lRet)

EndIf

If cModelo $ "55,65"

	if ( 'VERSAO="3.10"' $ Upper(cXml) )

		cVerXml := "3.10"

	Else

		cVerXml := "4.00"

	endif

	If !"PROCCANCNFE" $ Upper(cXml) .and. !( "<PROCEVENTONFE" $ Upper(cXml) .and. "<TPEVENTO>110111" $ Upper(cXml) ) .and. !"<TPEVENTO>110110" $ Upper(cXml)

		nAt1:= At('<NFE ',Upper(cXml))
		nAt2:= At('</NFE>',Upper(cXml))+ 6

		//Corpo da Nfe
		If nAt1 <=0

			nAt1:= At('<NFE>',Upper(cXml))

		EndIf

		If nAt1 > 0 .And. nAt2 > 6

			cNfe := Substr(cXml,nAt1,nAt2-nAt1)

		Else

			cOcorr := "Nf-e inconsistente."
			lret := .F.
			lInvalid := .T.

		EndIf

		nAt3:= At('<PROTNFE ',Upper(cXml))
		nAt4:= At('</PROTNFE>',Upper(cXml))+ 10

		//Protocolo
		If nAt3 > 0 .And. nAt4 > 10

			cProt := Substr(cXml,nAt3,nAt4-nAt3)

		Else

			lret := .F.
			lInvalid := .F.

		EndIf

		cXml:= '<?xml version="1.0" encoding="UTF-8"?>'
		cXml+= '<nfeProc versao="'+AllTrim(cVerXml)+'" xmlns="http://www.portalfiscal.inf.br/nfe">'
		cXml+= cNfe
		cXml+= cProt
		cXml+= '</nfeProc>'

	ElseIf "PROCCANCNFE" $ Upper(cXml)

		nAt1:= At('<CANCNFE ',Upper(cXml))
		nAt2:= At('</CANCNFE>',Upper(cXml)) + 10

		//Corpo da Nfe
		If nAt1 <=0

			nAt1:= At('<CANCNFE>',Upper(cXml))

		EndIf

		If nAt1 > 0 .And. nAt2 > 10

			cNfe := Substr(cXml,nAt1,nAt2-nAt1)

		Else

			cOcorr := "Nf-e inconsistente."
			lret := .F.
			lInvalid := .T.

		EndIf

		nAt3:= At('<RETCANCNFE ',Upper(cXml))
		nAt4:= At('</RETCANCNFE>',Upper(cXml)) + 13

		//Protocolo
		If nAt3 > 0 .And. nAt4 > 13

			cProt := Substr(cXml,nAt3,nAt4-nAt3)

		Else

			lret := .F.
			lInvalid := .F.

		EndIf

		cXml:= '<?xml version="1.0" encoding="UTF-8"?>'
		cXml+= '<procCancNfe versao="'+AllTrim(cVerXml)+'" xmlns="http://www.portalfiscal.inf.br/nfe">'
		cXml+= cNfe
		cXml+= cProt
		cXml+= '</procCancNfe>'

		lCanc := .T.

	Elseif ("<PROCEVENTONFE" $ Upper(cXml) .and. "<TPEVENTO>110111" $ Upper(cXml) )

		nAt1:= At('<EVENTO ',Upper(cXml))
		nAt2:= At('</EVENTO>',Upper(cXml)) + 9

		//Corpo da Nfe
		If nAt1 <=0

			nAt1:= At('<EVENTO>',Upper(cXml))

		EndIf

		If nAt1 > 0 .And. nAt2 > 10

			cNfe := Substr(cXml,nAt1,nAt2-nAt1)

		Else

			cOcorr := "Nf-e Evento inconsistente."
			lret := .F.
			lInvalid := .T.

		EndIf

		if At('<RETENVEVENTO ',Upper(cXml)) > 0

			nAt3:= At('<RETENVEVENTO ',Upper(cXml))
			nAt4:= At('</RETENVEVENTO>',Upper(cXml)) + 15

		else

			nAt3:= At('<RETEVENTO ',Upper(cXml))
			nAt4:= At('</RETEVENTO>',Upper(cXml)) + 12

		endif

		//Protocolo
		If nAt3 > 0 .And. nAt4 > 15

			cProt := Substr(cXml,nAt3,nAt4-nAt3)

		Else

			lret := .F.
			lInvalid := .F.

		EndIf

		cXml:= '<?xml version="1.0" encoding="UTF-8"?>'
		cXml+= '<procEventoNfe versao="1.00" xmlns="http://www.portalfiscal.inf.br/nfe">'
		cXml+= cNfe
		cXml+= cProt
		cXml+= '</procEventoNfe>'

		lCanc := .T.

	Elseif "<TPEVENTO>110110" $ Upper(cXml)  //CCE

		nAt1:= At('<EVENTO ',Upper(cXml))
		nAt2:= At('</EVENTO>',Upper(cXml)) + 9

		//Corpo da Nfe
		If nAt1 <=0

			nAt1:= At('<EVENTO>',Upper(cXml))

		EndIf

		If nAt1 > 0 .And. nAt2 > 10

			cNfe := Substr(cXml,nAt1,nAt2-nAt1)

		Else

			cOcorr := "Nf-e Evento inconsistente."
			lret := .F.
			lInvalid := .T.

		EndIf

		nAt3:= At('<RETEVENTO ',Upper(cXml))
		nAt4:= At('</RETEVENTO>',Upper(cXml)) + 12

		//Protocolo
		If nAt3 > 0 .And. nAt4 > 15

			cProt := Substr(cXml,nAt3,nAt4-nAt3)

		Else

			lret := .F.
			lInvalid := .F.

		EndIf

		cXml:= '<?xml version="1.0" encoding="UTF-8"?>'
		cXml+= '<procEventoNfe versao="1.00" xmlns="http://www.portalfiscal.inf.br/nfe">'
		cXml+= cNfe
		cXml+= cProt
		cXml+= '</procEventoNfe>'

		lCCe := .T.

	EndIf

ElseIf cModelo == "57"

	If !"PROCCANCCTE" $ Upper(cXml)

		nAt1:= At('<CTE ',Upper(cXml))
		nAt2:= At('</CTE>',Upper(cXml)) + 6

		//Corpo da Nfe
		If nAt1 <=0

			nAt1:= At('<CTE>',Upper(cXml))

		EndIf

		If nAt1 > 0 .And. nAt2 > 6

			cNfe := Substr(cXml,nAt1,nAt2-nAt1)

		Else

			cOcorr := "CT-e inconsistente."
			lret := .F.
			lInvalid := .T.

		EndIf

		nAt3:= At('<PROTCTE ',Upper(cXml))
		nAt4:= At('</PROTCTE>',Upper(cXml)) + 10

		If nAt3 <=0

			nAt3:= At('<PROTCTE>',Upper(cXml))

		EndIf

		//Protocolo

		If nAt3 > 0 .And. nAt4 > 10

			cProt := Substr(cXml,nAt3,nAt4-nAt3)

		Else

			lret := .F.
			lInvalid := .F.

		EndIf

		cXml:= '<?xml version="1.0" encoding="UTF-8"?>'
		cXml+= '<cteProc versao="3.00" xmlns="http://www.portalfiscal.inf.br/cte">'
		cXml+= cNfe
		cXml+= cProt
		cXml+= '</cteProc>'

		//Verifica se xml esta cancelado
		/*if AT("<cStat>101</cStat>", cXml) > 0 

			lCanc := .T.

		endif*/

	ElseiF "PROCCANCCTE" $ Upper(cXml)

		nAt1:= At('<CANCCTE ',Upper(cXml))
		nAt2:= At('</CANCCTE>',Upper(cXml)) + 10

		//Corpo da Nfe
		If nAt1 <=0

			nAt1:= At('<CANCCTE>',Upper(cXml))

		EndIf

		If nAt1 > 0 .And. nAt2 > 10

			cNfe := Substr(cXml,nAt1,nAt2-nAt1)

		Else

			cOcorr := "Nf-e inconsistente."
			lret := .F.
			lInvalid := .T.

		EndIf

		nAt3:= At('<RETCANCCTE ',Upper(cXml))
		nAt4:= At('</RETCANCCTE>',Upper(cXml)) + 13

		If nAt3 <=0

			nAt3:= At('<RETCANCCTE>',Upper(cXml))

		EndIf


		//Protocolo
		If nAt3 > 0 .And. nAt4 > 13

			cProt := Substr(cXml,nAt3,nAt4-nAt3)

		Else

			lret := .F.
			lInvalid := .F.

		EndIf

		cXml:= '<?xml version="1.0" encoding="UTF-8"?>'
		cXml+= '<procCancCTe versao="3.00" xmlns="http://www.portalfiscal.inf.br/cte">'
		cXml+= cNfe
		cXml+= cProt
		cXml+= '</procCancCTe>'

		lCanc := .T.

	Elseif "<TPEVENTO>110110" $ Upper(cXml)  //CCE

		nAt1:= At('<EVENTO ',Upper(cXml))
		nAt2:= At('</EVENTO>',Upper(cXml)) + 9

		//Corpo da Nfe
		If nAt1 <=0

			nAt1:= At('<EVENTO>',Upper(cXml))

		EndIf

		If nAt1 > 0 .And. nAt2 > 10

			cNfe := Substr(cXml,nAt1,nAt2-nAt1)

		Else

			cOcorr := "Ct-e Evento inconsistente."
			lret := .F.
			lInvalid := .T.

		EndIf

		nAt3:= At('<RETENVEVENTO ',Upper(cXml))
		nAt4:= At('</RETENVEVENTO>',Upper(cXml)) + 15

		If nAt3 <=0

			nAt3:= At('<RETENVEVENTO>',Upper(cXml))

		EndIf


		//Protocolo
		If nAt3 > 0 .And. nAt4 > 15

			cProt := Substr(cXml,nAt3,nAt4-nAt3)

		Else

			lret := .F.
			lInvalid := .F.

		EndIf

		cXml:= '<?xml version="1.0" encoding="UTF-8"?>'
		cXml+= '<procEventoCte versao="1.00" xmlns="http://www.portalfiscal.inf.br/nfe">'
		cXml+= cNfe
		cXml+= cProt
		cXml+= '</procEventoCte>'

		lCCe := .T.

	EndIf

ElseIf cModelo == "67"

	If !"PROCCANCCTEOS" $ Upper(cXml)

		nAt1:= At('<CTEOS ',Upper(cXml))
		nAt2:= At('</CTEOS>',Upper(cXml)) + 8

		//Corpo da Nfe
		If nAt1 <=0

			nAt1:= At('<CTEOS>',Upper(cXml))

		EndIf

		If nAt1 > 0 .And. nAt2 > 8

			cNfe := Substr(cXml,nAt1,nAt2-nAt1)

		Else

			cOcorr := "CT-eOs inconsistente."
			lret := .F.
			lInvalid := .T.

		EndIf

		nAt3:= At('<PROTCTE ',Upper(cXml))
		nAt4:= At('</PROTCTE>',Upper(cXml)) + 10

		//Protocolo
		If nAt3 > 0 .And. nAt4 > 10

			cProt := Substr(cXml,nAt3,nAt4-nAt3)

		Else

			lret := .F.
			lInvalid := .F.

		EndIf

		cXml:= '<?xml version="1.0" encoding="UTF-8"?>'
		cXml+= '<cteOSProc versao="3.00" xmlns="http://www.portalfiscal.inf.br/cte">'
		cXml+= cNfe
		cXml+= cProt
		cXml+= '</cteOSProc>'

	ElseiF "PROCCANCCTEOS" $ Upper(cXml)

		nAt1:= At('<CANCCTEOS ',Upper(cXml))
		nAt2:= At('</CANCCTEOS>',Upper(cXml)) + 12

		//Corpo da Nfe
		If nAt1 <=0

			nAt1:= At('<CANCCTEOS>',Upper(cXml))

		EndIf

		If nAt1 > 0 .And. nAt2 > 12

			cNfe := Substr(cXml,nAt1,nAt2-nAt1)

		Else

			cOcorr := "Ct-eOS inconsistente."
			lret := .F.
			lInvalid := .T.

		EndIf

		nAt3:= At('<RETCANCCTEOS ',Upper(cXml))
		nAt4:= At('</RETCANCCTEOS>',Upper(cXml)) + 15

		//Protocolo

		If nAt3 > 0 .And. nAt4 > 15

			cProt := Substr(cXml,nAt3,nAt4-nAt3)

		Else

			lret := .F.
			lInvalid := .F.

		EndIf

		cXml:= '<?xml version="1.0" encoding="UTF-8"?>'
		cXml+= '<procCancCTeOS versao="3.00" xmlns="http://www.portalfiscal.inf.br/cte">'
		cXml+= cNfe
		cXml+= cProt
		cXml+= '</procCancCTeOS>'

		lCanc := .T.

	Elseif "<TPEVENTO>110110" $ Upper(cXml)  //CCE

		nAt1:= At('<EVENTO ',Upper(cXml))
		nAt2:= At('</EVENTO>',Upper(cXml)) + 9

		//Corpo da Nfe
		If nAt1 <=0

			nAt1:= At('<EVENTO>',Upper(cXml))

		EndIf

		If nAt1 > 0 .And. nAt2 > 10

			cNfe := Substr(cXml,nAt1,nAt2-nAt1)

		Else

			cOcorr := "Ct-eOS Evento inconsistente."
			lret := .F.
			lInvalid := .T.

		EndIf

		nAt3:= At('<RETENVEVENTO ',Upper(cXml))
		nAt4:= At('</RETENVEVENTO>',Upper(cXml)) + 15

		//Protocolo
		If nAt3 > 0 .And. nAt4 > 15

			cProt := Substr(cXml,nAt3,nAt4-nAt3)

		Else

			lret := .F.
			lInvalid := .F.

		EndIf

		cXml:= '<?xml version="1.0" encoding="UTF-8"?>'
		cXml+= '<procEventoCteOS versao="1.00" xmlns="http://www.portalfiscal.inf.br/nfe">'
		cXml+= cNfe
		cXml+= cProt
		cXml+= '</procEventoCteOS>'

		lCCe := .T.

	EndIf

EndIf

oXmlTeste := XmlParser( cXml, "_", @cError, @cWarning )

if Empty( oXmlTeste )

	cXml := EncodeUTF8(cXml)
	cXml := FwNoAccent(cXml)

	oXmlTeste := NIL

	//Faz backup do xml sem retirar os caracteres especiais
	cBkpXml := cXml

	//Executa rotina para retirar os caracteres especiais
	cXml := u_zCarEspec( cXml )

	oXmlTeste := XmlParser( cXml, "_", @cError, @cWarning )

	//retorna o backup do xml
	cXml := cBkpXml

endif

if oXmlTeste == NIL

	lInvalid := .T.
	lRet := .F.

	if empty(cOcorr)

		cOcorr := AllTrim(cError)+AllTrim(cWarning)

	Else

		cOcorr += AllTrim(cError)+AllTrim(cWarning)

	EndIF

Endif

oXmlTeste := NIL

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³NoAcento  º Autor ³ Roberto Souza      º Data ³  07/10/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Retira caracteres especiais.                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Importa Xml                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function NoAcento(cString)

Local cChar  := ""
Local nX     := 0
Local nY     := 0
Local cVogal := "aeiouAEIOU"
Local cAgudo := "áéíóú"+"ÁÉÍÓÚ"
Local cCircu := "âêîôû"+"ÂÊÎÔÛ"
Local cTrema := "äëïöü"+"ÄËÏÖÜ"
Local cCrase := "àèìòù"+"ÀÈÌÒÙ"
Local cTio   := "ãõ"
Local cCecid := "çÇ"
//Local lChar  := .F.

For nX:= 1 To Len(cString)

	cChar:=SubStr(cString, nX, 1)

	IF cChar$cAgudo+cCircu+cTrema+cCecid+cTio+cCrase

		nY:= At(cChar,cAgudo)

		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf

		nY:= At(cChar,cCircu)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf

		nY:= At(cChar,cTrema)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf

		nY:= At(cChar,cCrase)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf

		nY:= At(cChar,cTio)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("ao",nY,1))
		EndIf

		nY:= At(cChar,cCecid)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("cC",nY,1))
		EndIf

	Endif

Next

For nX := 1 To Len(cString)

	cChar:=SubStr(cString, nX, 1)

	If Asc(cChar) < 32 .Or. Asc(cChar) > 123// .and. (cChar<> 10 .And. cChar<> 13)

		cString:=StrTran(cString,cChar,".")

	Endif

Next nX

Return(cString)


//Rotina para gravar xml
**********************************************************************************************************
User Function HFSLVXML( cNomArq, lAuto, lEnd, oProcess, cLogProc, nCount, cVem, cNewKey, cNewArq, cTpDow )
**********************************************************************************************************

Local aArea1   := GetArea()
//Local lRet     := .F.
//Local ny       := 0
//Local aFiles   := {}
//Local aFilTr   := {}
Local cDir     := "\"+AllTrim(GetNewPar("MV_X_PATHX",""))+"\"
Local lDirCnpj := AllTrim(GetNewPar("XM_DIRCNPJ","N")) == "S"
Local lDirFil  := AllTrim(GetNewPar("XM_DIRFIL" ,"N")) == "S"
Local lDirMod  := AllTrim(GetNewPar("XM_DIRMOD" ,"N")) == "S"
Local cDirDest := AllTrim(cDir+"Importados\")
Local cDirRej  := AllTrim(cDir+"Rejeitados\")
Local cDirCfg  := AllTrim(cDir+"Cfg\")
Local cDrive   := ""
Local cPath    := ""
Local cNewFile := ""
Local cExt     := ""
//Local lCopy    := .F.
Local nErase   := 0
Local cFilXml  := ""
Local cSeqCce  := ""
Local cKeyXml  := ""
//Local lOnline  := .F.
//Local cInfo    := ""
//Local cErroR   := ""
Local cErroProc:= ""
//Local cMsg     := ""
Local cOcorr   := ""
Local cPref    := ""
//Local aPref    := {"CTE","NFE","NFCE"}
//Local lNewVer  := AllTrim(GetSrvProfString("HF_DEBUGKEY","0"))=="1"
Local nTag     := 0
//Local lArq     := .F.

Default cVem := " "
Default cNewKey := " "
Default cNewArq := " "
Default cTpDow  := " "

Private oXml     := Nil
Private lOver    := .F.
Private lCanc    := .F., lCCe := .F.
Private cMsgTag  := ""
Private cOrigem  := cVem
Private cTipoDow := cTpDow
Private xZBS  	 := GetNewPar("XM_TABSINC","ZBS")
Private xZBS_ 	 := iif(Substr(xZBS,1,1)=="S", Substr(xZBS,2,2), Substr(xZBS,1,3)) + "_"
//Conout(cVem + " " + cOrigem)

//Aqui estava antes disso, direto no procxml. La ficou só o FOR e aqui é um a um.
DbSelectArea("SM0")
nRecFil := Recno()

Private xcXml2   := ""
Private aFilsLic := {}
Private lXmlsLic := .F.
Private aFilsEmp := U_XGetFilS(SM0->M0_CGC,@aFilsLic)
//Retorno da função acima -> Aadd(aRet,{SM0->M0_CODFIL,SM0->M0_CGC,SM0->M0_FILIAL,SM0->M0_NOMECOM,SM0->M0_INSC})
DbSelectArea("SM0")
DbGoTo(nRecFil)

Default oProcess:= Nil

//inicio aqui para linux
cDir     := Iif(lUnix,StrTran(cDir,"\","/"),cDir)
cDirDest := Iif(lUnix,StrTran(cDirDest,"\","/"),cDirDest)
cDirRej  := Iif(lUnix,StrTran(cDirRej,"\","/"),cDirRej)
cDirCfg  := Iif(lUnix,StrTran(cDirCfg,"\","/"),cDirCfg)
//fim aqui para linux

cDir           := StrTran(cDir,cBarra+cBarra,cBarra)
cDirDest       := StrTran(cDirDest,cBarra+cBarra,cBarra)
cDirRej        := StrTran(cDirRej,cBarra+cBarra,cBarra)
cDirCfg        := StrTran(cDirCfg,cBarra+cBarra,cBarra)

cDir           := StrTran(cDir,cBarra+cBarra,cBarra)
cDirDest       := StrTran(cDirDest,cBarra+cBarra,cBarra)
cDirRej        := StrTran(cDirRej,cBarra+cBarra,cBarra)
cDirCfg        := StrTran(cDirCfg,cBarra+cBarra,cBarra)
_cDirDest      := cDirDest
_cDirRej       := cDirRej

If !ExistDir(cDirDest)

	Makedir(cDirDest)

EndIf

If !ExistDir(cDirRej)

	Makedir(cDirRej)

EndIf

lInvalid  := .F.

SplitPath(cDir+AllTrim(cNomArq),@cDrive,@cPath, @cNewFile,@cExt)		// Exemplo: ("\xmlsource\" + "NF_24444.XML" , "" , "" , "" , "")

cModelo   := ""
cOcorr    := ""
cErroProc := ""
cPref     := "XXX"
cFilXml   := "XX"
cSeqCce   := ""
lCanc     := .F.
lCCe      := .F.
lXmlsLic  := .F.

DbSelectArea(xZBS)
DbSetOrder(3)
if DbSeek(Substr(cnewfile,1,44))

	cXml := (xZBS)->(FieldGet(FieldPos(xZBS_+"XML")))

	if Empty( cXml )

		//Verifica o tamanho do arquivo se maior que 5mb é descartado o arquivo
		nTamFile := u_HFLenStr(cPath+cNewFile+cExt)  //Len(cXml)

		Do Case

		Case nTamFile <= 65534

			lOver := .F.
			
			cXml := MemoRead( cPath+cNewFile+cExt )

		Case nTamfile <= 524288

			lOver := .T.

			cXml := LerComFRead( cPath+cNewFile+cExt )

		Case nTamfile > 524288

			//Arquivo muito grande gera erro na rotina LerComFRead e XmlParserFile
			cLogProc += "Tamanho do arquivo nao suportado " + cNewFile+cExt 

			nErase := FErase(cPath+cNewFile+cExt)

			cLogProc += "Arquivo " + cNewFile+cExt + " deletado."

			RestArea(aArea1)

			Return(.T.)

		EndCase

	endif 

else

	//Verifica o tamanho do arquivo se maior que 5mb é descartado o arquivo
	nTamFile := u_HFLenStr(cPath+cNewFile+cExt)  //Len(cXml)

	Do Case

	Case nTamFile <= 65534

		lOver := .F.
		
		cXml := MemoRead( cPath+cNewFile+cExt )

	Case nTamfile <= 524288

		lOver := .T.

		cXml := LerComFRead( cPath+cNewFile+cExt )

	Case nTamfile > 524288

		//Arquivo muito grande gera erro na rotina LerComFRead e XmlParserFile
		cLogProc += "Tamanho do arquivo nao suportado " + cNewFile+cExt 

		nErase := FErase(cPath+cNewFile+cExt)

		cLogProc += "Arquivo " + cNewFile+cExt + " deletado."

		RestArea(aArea1)

		Return(.T.)

	EndCase

endif

oXml := Nil

If lOver .and. cOrigem <> "2"

	VldXmlOK(2,cPath+cNewFile+cExt,@cXml,@cOcorr,@lInvalid,@cModelo,@lCanc,@oXml,@lCCe)

Else

	ValidXml(@cXml,@cOcorr,@lInvalid,@cModelo,@lCanc,@lCCe)

EndIf

//FR - 08/02/2021 - #6170 - MaxiRubber - para gravar no campo ZBZ_XML o cabeçalho do encode utf8, caso não haja esta string, insiro aqui:
cAux := ""
cAux := '<?xml version="1.0" encoding="UTF-8"?>'
If Upper(Alltrim(cAux)) $ Upper(Alltrim(cXml))		//FR - 08/02/2021 - se estiver contido, mantém do jeito que está
	xcXml2 := cXml 
Else
	xcXml2 := cAux + cXml				//FR - 08/02/2021 - se não estiver contido, adiciona
Endif
//FR - 08/02/2021 - #6170 - MaxiRubber

if AllTrim(GetNewPar("XM_XMLSEF" ,"N")) == "S"

	If !ExistDir(cDirCfg)

		Makedir(cDirCfg)

	EndIf

	If .Not. ChkTagNfe(cDirCfg+"TagNfe.Cfg")

		cLogProc += "(ARQTAG) Nao foi possivel criar o arquivo ["+cDirCfg+"TagNfe.Cfg"+"]"+CRLF

	Else

		If ! lCanc .And. ! lCCe .And. cModelo <> "57" //For While

			cLogProc += cNewFile+cExt+" (Verificando TAGs)"+CRLF
			cMsgTag  := ""

			nTag := U_HFXMLCPS(cDirCfg+"TagNfe.Cfg",@cXml,@cOcorr,@lInvalid,@cModelo )

			If nTag == -1
				cLogProc += "(ARQTAG) Nao foi possível abrir o arquivo ["+cDirCfg+"TagNfe.Cfg"+"]"+CRLF
			ElseIf nTag == -2
				cLogProc += "Nao foi possível obter chave para Baixar XML da sefaz."+CRLF
			ElseIf nTag == -3 .Or. nTag == -4
				cLogProc += AllTrim(cMsgTag) //+CRLF
			ElseIf nTag == -9
				cLogProc += "(ARQTAG) Nao foi possível criar o arquivo ["+cDirCfg+"TagNfe.Cfg"+"]"+CRLF
			ElseIf nTag > 0
				cLogProc += AllTrim(cMsgTag) //+CRLF
			EndIf

		EndIf

	EndIf

EndIf

If !lInvalid .And. Empty(cOcorr)

	If cModelo $ "55,65"

		cPref := iif( cModelo == "55", "NFE", "NFCE" )

		If (USANFE .And. cModelo == "55") .Or. (USANFCE .And. cModelo == "65")

			//ValidaXmlNfe(cXml,cPath+cNewFile+cExt,,,1,@lInvalid,@cLogProc,@cFilXml,@cKeyXml,@cOcorr)

			If lCanc

				CancXmlAll(cModelo,cXml,cPath+cNewFile+cExt,,,1,@lInvalid,@cLogProc,@cFilXml,@cKeyXml,@cOcorr,aFilsEmp,oXml)

			Elseif lCCe

				CCeXmlAll(cModelo,cXml,cPath+cNewFile+cExt,@lInvalid,@cLogProc,@cFilXml,@cKeyXml,@cSeqCce,@cOcorr,aFilsEmp,oXml)

			Else

				ValidaXmlAll(cModelo,cXml,cPath+cNewFile+cExt,,,1,@lInvalid,@cLogProc,@cFilXml,@cKeyXml,@cOcorr,aFilsEmp,oXml)

			EndIf

		Else

			lInvalid  := .T.
			cErroProc := "Processamento de NF-e desabibilado. Verifique parâmetro XM_USANFE/XM_USANFCE."

		EndIf

	ElseIf cModelo $ "57,67"

		If USACTE

			cPref := iif( cModelo == "57", "CTE", "CTEOS" )

			If lCanc

				CancXmlAll(cModelo,cXml,cPath+cNewFile+cExt,,,1,@lInvalid,@cLogProc,@cFilXml,@cKeyXml,@cOcorr,aFilsEmp,oXml)

			Elseif lCCe

				CCeXmlAll(cModelo,cXml,cPath+cNewFile+cExt,@lInvalid,@cLogProc,@cFilXml,@cKeyXml,@cSeqCce,@cOcorr,aFilsEmp,oXml)

			Else

				ValidaXmlAll(cModelo,cXml,cPath+cNewFile+cExt,,,1,@lInvalid,@cLogProc,@cFilXml,@cKeyXml,@cOcorr,aFilsEmp,oXml)

			EndIf

		Else

			lInvalid  := .T.
			cErroProc := "Processamento de CT-e desabibilado. Verifique parâmetro XM_USACTE."

		EndIf

	EndIf

Else

	cLogProc += cOcorr+" ["+cNewFile+cExt+"]"+CRLF

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pasta XMLSOURCE, Se não integra com núvem GRAVA; Se integra e for Tipo <P> que Grava Arquivo na Pasta XMLSOURCE ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

IF aHfCloud[1] == "0" .or. aHfCloud[3] == "P"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Arvore de diretórios³
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	_cDirRej := cDirRej
	_cDirDest:= cDirDest

	If lXmlsLic

		_cDirLic := _cDirRej + "CNPJ_SEM_LICENCA" + cBarra

		If !ExistDir(_cDirLic)
			Makedir(_cDirLic)
		EndIf

	EndIf

	If lDirMod

		_cDirRej := _cDirRej + cPref + iif(lCCe,"CCe","") +cBarra
		_cDirDest:= _cDirDest + cPref + iif(lCCe,"CCe","") +cBarra

		If !ExistDir(_cDirDest)
			Makedir(_cDirDest)
		EndIf

		If !ExistDir(_cDirRej)
			Makedir(_cDirRej)
		EndIf

	EndIf

	If lDirFil

		_cDirRej := _cDirRej + cFilXml+cBarra
		_cDirDest:= _cDirDest + cFilXml+cBarra

		If !ExistDir(_cDirDest)
			Makedir(_cDirDest)
		EndIf

		If !ExistDir(_cDirRej)
			Makedir(_cDirRej)
		EndIf

	EndIf

	If lDirCnpj

		cCnpjEmit := Substr(cKeyXml,7,14)
		_cDirRej := _cDirRej + cCnpjEmit+cBarra
		_cDirDest:= _cDirDest + cCnpjEmit+cBarra

		If !ExistDir(_cDirDest)
			Makedir(_cDirDest)
		EndIf

		If !ExistDir(_cDirRej)
			Makedir(_cDirRej)
		EndIf

	EndIf

	If !lAuto .Or. oProcess <> Nil

		oProcess:IncRegua1("Processando Xml...")
		oProcess:IncRegua2("Arquivo ..."+Right(cNewFile+cExt,20))

	EndIf

	If lInvalid

		if File( cDir+cNewFile+cExt )

			if lOver

				cFileToWrite := xcXml2 //LerComFRead(cDir+cNewFile+cExt)

			else

				cFileToWrite := xcXml2 //MemoRead(cDir+cNewFile+cExt)

			endif

			if lXmlsLic

				cFinalF:= _cDirLic+cKeyXml+"-"+(IIf(lCanc,"ProcCanc",iif(lCce,cSeqCce+"CCe-","")))+cPref+cExt

			Else

				cFinalF:= _cDirRej+cKeyXml+"-"+(IIf(lCanc,"ProcCanc",iif(lCce,cSeqCce+"CCe-","")))+cPref+cExt

			EndIF

			//if lOver //28032016
			if ! GravarComFRead(cFinalF,cFileToWrite)

				MemoWrite(cFinalF,cFileToWrite)

			EndIF

			//Else
			//	MemoWrite(cFinalF,cFileToWrite)
			//EndIF

			nErase := FErase(cDir+cNewFile+cExt)

			If nErase < 0
				cLogProc += "(EM USO) Nao foi possivel remover o arquivo ["+cDir+cNewFile+cExt+"]"+CRLF
			EndIf

		Else

			if lXmlsLic

				cFinalF:= _cDirLic+cKeyXml+"-"+(IIf(lCanc,"ProcCanc",iif(lCce,cSeqCce+"CCe-","")))+cPref+cExt

			Else

				cFinalF:= _cDirRej+cKeyXml+"-"+(IIf(lCanc,"ProcCanc",iif(lCce,cSeqCce+"CCe-","")))+cPref+cExt

			EndIF

		EndIf

		MemoWrite(cFinalF+"_log.txt",cOcorr)

	Else

		if lOver

			cFileToWrite := xcXml2 //LerComFRead(cDir+cNewFile+cExt)

		else

			cFileToWrite := xcXml2 //MemoRead(cDir+cNewFile+cExt)

		endif

		cFinalF := _cDirDest+cKeyXml+"-"+(IIf(lCanc,"ProcCanc",iif(lCce,cSeqCce+"CCe-","")))+cPref+cExt

		//if lOver //28032016

		if ! GravarComFRead(cFinalF,cFileToWrite)
			MemoWrite(cFinalF,cFileToWrite)
		EndIF

		//Else
		//	MemoWrite(cFinalF,cFileToWrite)
		//EndIF

		nErase := FErase(cDir+cNewFile+cExt)

		//If nErase <> -1
		//	cLogProc += "(EM USO) Nao foi possivel remover o arquivo ["+cDir+cNewFile+cExt+"]"+CRLF
		//EndIf

	EndIf

Else //Mas tem que Excluir o arquivo

	nErase := FErase(cDir+cNewFile+cExt)

	//If nErase <> -1
	//	cLogProc += "(EM USO) Nao foi possivel remover o arquivo ["+cDir+cNewFile+cExt+"]"+CRLF
	//EndIf

ENDIF  //FIM DO IF DA NUVEM

IF !lAuto

	If cTipBrw == "1"  //Antigo, Apenas um Browse, somente do XML NFe.

		//oZe := GetObjBrow()
		//oZe:Refresh()

	Else

		oBrowseUp:Refresh()
		oBrowseDwn:Refresh()

	endif

ENDIF

//A Chave do XML e o Nome do Arquivo Renomeado, para quando precisar
//A priori estamos usando nos múltiplos CTe, Em 29/03/2019
cNewKey := cKeyXml
cNewArq := cNewFile+cExt

RestArea( aArea1 )

Return( .T. )


***********************************************************
User Function COMP0012(lAuto,lEnd,oProcess,cLogProc,nCount)
***********************************************************

Local aArea     := GetArea()
//Local cQry      := ""
Local cWhere    := ""
Local cTabela   := ""
Local cAliasZBZ := GetNextAlias()
Local lSeekFor  := (xZBZ)->(FieldPos(xZBZ_+"CODFOR"))>0 .And. (xZBZ)->(FieldPos(xZBZ_+"LOJFOR"))>0
//Local lSeekFor
Local nOk       := 0
Local nNo       := 0

Private lSharedA1:= U_IsShared("SA1")
Private lSharedA2:= U_IsShared("SA2")
Private nFormNfe := Val(GetNewPar("XM_FORMNFE","9"))
Private dDtProc  := dDatabase - Val(GetNewPar("XM_D_STATUS","180"))


Default cLogProc:= ""
Default lAuto   := .F.
Default oProcess:= Nil
Default lEnd    := .F.
Default nCount  := 0

If !lAuto .Or. oProcess <> Nil

	oProcess:IncRegua1("Atualizando Status Xml...")
	oProcess:IncRegua2("Aguarde...")

EndIf

cLogProc +="### Atualizando Status Xml. ###"+CRLF

//	cWhere := "%( (ZBZ.ZBZ_PRENF NOT IN ('F')) )%"
cTabela:= "%"+RetSqlName(xZBZ)+"%"
cWhere := "%( (ZBZ."+xZBZ_+"PRENF NOT IN ('F') AND ZBZ."+xZBZ_+"DTRECB >='" +Dtos(dDtProc)+"') )%"
cCampos	:="%"+xZBZ_+"FILIAL, "+xZBZ_+"NOTA, "+xZBZ_+"SERIE, "+xZBZ_+"DTNFE, "+xZBZ_+"PRENF, "+xZBZ_+"CNPJ, "+xZBZ_+"MODELO, "+xZBZ_+"DOCCTE, "+;
xZBZ_+"FORNEC, "+xZBZ_+"CNPJD, "+xZBZ_+"CLIENT,"+xZBZ_+"CHAVE,"+xZBZ_+"TPDOC, ZBZ.R_E_C_N_O_"

If lSeekFor

	cCampos	+=	" ,"+xZBZ_+"CODFOR,"+xZBZ_+"LOJFOR%"

Else

	cCampos	+=	"%"

EndIf

BeginSql Alias cAliasZBZ

	SELECT	%Exp:cCampos%
	FROM %Exp:cTabela% ZBZ
	WHERE ZBZ.%notdel%
	AND %Exp:cWhere%
EndSql

DbSelectArea("SF1")
DbSetOrder(1)
DbGoTop()
DbSelectArea(cAliasZBZ)

While !(cAliasZBZ)->(Eof())

	//O certo aqui era fazer todo esse processo em uma outra função, mas tem que ter tempo para acertar essas coisas.
	//tem o HFSTXMUN que dar para usar depois
	cTipoNf := Iif(Empty((cAliasZBZ)->&(xZBZ_+"TPDOC")),"N",(cAliasZBZ)->&(xZBZ_+"TPDOC"))
	cCodFor := (cAliasZBZ)->&(xZBZ_+"CODFOR")+(cAliasZBZ)->&(xZBZ_+"LOJFOR")

	if empty( cCodFor )

		If cTipoNf $ "D|B"

			cFilSeek := xFilial("SA1")   //Iif(lSharedA1,xFilial("SA1"),(cAliasZBZ)->&(xZBZ_+"FILIAL") )
			DbSelectArea("SA1")
			DbSetOrder(3)

			If .not. Empty((cAliasZBZ)->&(xZBZ_+"CNPJ")) .And. DbSeek(cFilSeek+(cAliasZBZ)->&(xZBZ_+"CNPJ"))
				cCodFor := SA1->A1_COD+SA1->A1_LOJA

				Do While .not. SA1->( eof() ) .and. SA1->A1_FILIAL == cFilSeek .and.;
				SA1->A1_CGC == (cAliasZBZ)->&(xZBZ_+"CNPJ")
					if SA1->A1_MSBLQL != "1"

						cCodFor := SA1->A1_COD+SA1->A1_LOJA
						exit

					endif

					SA1->( dbSkip() )

				EndDo

			EndIf

		Else

			cFilSeek :=xFilial("SA2")   //Iif(lSharedA2,xFilial("SA2"),(cAliasZBZ)->&(xZBZ_+"FILIAL") )
			DbSelectArea("SA2")
			DbSetOrder(3)

			If .not. Empty((cAliasZBZ)->&(xZBZ_+"CNPJ")) .And. DbSeek(cFilSeek+(cAliasZBZ)->&(xZBZ_+"CNPJ"))

				cCodFor := SA2->A2_COD+SA2->A2_LOJA

				Do While .not. SA2->( eof() ) .and. SA2->A2_FILIAL == cFilSeek .and.;
				SA2->A2_CGC == (cAliasZBZ)->&(xZBZ_+"CNPJ")

					if SA2->A2_MSBLQL != "1"
						cCodFor := SA2->A2_COD+SA2->A2_LOJA
						exit
					endif

					SA2->( dbSkip() )

				EndDo

			EndIf

		EndIf

	EndIf

	DbSelectArea("SF1")

	lSeek := .F.
	cNotaSeek :=  Iif(nFormNfe > 0,StrZero(Val((cAliasZBZ)->&(xZBZ_+"NOTA")),nFormNfe),AllTrim(Str(Val((cAliasZBZ)->&(xZBZ_+"NOTA")))))
	lSeek := DbSeek((cAliasZBZ)->&(xZBZ_+"FILIAL")+Padr(cNotaSeek,9)+(cAliasZBZ)->&(xZBZ_+"SERIE")+cCodFor+cTipoNf)

	If !lSeek
		cNotaSeek := AllTrim(Str(Val((cAliasZBZ)->&(xZBZ_+"NOTA"))))
		lSeek := DbSeek((cAliasZBZ)->&(xZBZ_+"FILIAL")+Padr(cNotaSeek,9)+(cAliasZBZ)->&(xZBZ_+"SERIE")+cCodFor+cTipoNf)
	EndIf

	If !lSeek
		cNotaSeek :=  StrZero(Val((cAliasZBZ)->&(xZBZ_+"NOTA")),6)
		lSeek := DbSeek((cAliasZBZ)->&(xZBZ_+"FILIAL")+Padr(cNotaSeek,9)+(cAliasZBZ)->&(xZBZ_+"SERIE")+cCodFor+cTipoNf)
	EndIf

	If !lSeek
		cNotaSeek :=  StrZero(Val((cAliasZBZ)->&(xZBZ_+"NOTA")),9)
		lSeek := DbSeek((cAliasZBZ)->&(xZBZ_+"FILIAL")+Padr(cNotaSeek,9)+(cAliasZBZ)->&(xZBZ_+"SERIE")+cCodFor+cTipoNf)
	EndIf

	//aquiii Multiplos CTE
	If !lSeek .And. (cAliasZBZ)->&(xZBZ_+"MODELO") == "57" .AND. ! Empty( (cAliasZBZ)->&(xZBZ_+"DOCCTE") )
		cNotaSeek :=  Iif(nFormNfe > 0,StrZero(Val((cAliasZBZ)->&(xZBZ_+"DOCCTE")),nFormNfe),AllTrim(Str(Val((cAliasZBZ)->&(xZBZ_+"DOCCTE") ))))
		lSeek := DbSeek((cAliasZBZ)->&(xZBZ_+"FILIAL")+Padr(cNotaSeek,9)+(cAliasZBZ)->&(xZBZ_+"SERIE")+cCodFor+cTipoNf)
	EndIF

	If !lSeek .And. cTipoNf == "N" .and. (cAliasZBZ)->&(xZBZ_+"MODELO") == "57"

		cTipoNf := "C" //->Checar se é C
		cNotaSeek :=  Iif(nFormNfe > 0,StrZero(Val((cAliasZBZ)->&(xZBZ_+"NOTA")),nFormNfe),AllTrim(Str(Val((cAliasZBZ)->&(xZBZ_+"NOTA")))))
		lSeek := DbSeek((cAliasZBZ)->&(xZBZ_+"FILIAL")+Padr(cNotaSeek,9)+(cAliasZBZ)->&(xZBZ_+"SERIE")+cCodFor+cTipoNf)

		If !lSeek
			cNotaSeek := AllTrim(Str(Val((cAliasZBZ)->&(xZBZ_+"NOTA"))))
			lSeek := DbSeek((cAliasZBZ)->&(xZBZ_+"FILIAL")+Padr(cNotaSeek,9)+(cAliasZBZ)->&(xZBZ_+"SERIE")+cCodFor+cTipoNf)
		EndIf

		If !lSeek
			cNotaSeek :=  StrZero(Val((cAliasZBZ)->&(xZBZ_+"NOTA")),6)
			lSeek := DbSeek((cAliasZBZ)->&(xZBZ_+"FILIAL")+Padr(cNotaSeek,9)+(cAliasZBZ)->&(xZBZ_+"SERIE")+cCodFor+cTipoNf)
		EndIf

		If !lSeek
			cNotaSeek :=  StrZero(Val((cAliasZBZ)->&(xZBZ_+"NOTA")),9)
			lSeek := DbSeek((cAliasZBZ)->&(xZBZ_+"FILIAL")+Padr(cNotaSeek,9)+(cAliasZBZ)->&(xZBZ_+"SERIE")+cCodFor+cTipoNf)
		EndIf

		//aquiii Multiplos CTE
		If !lSeek
			cNotaSeek :=  Iif(nFormNfe > 0,StrZero(Val((cAliasZBZ)->&(xZBZ_+"DOCCTE")),nFormNfe),AllTrim(Str(Val((cAliasZBZ)->&(xZBZ_+"DOCCTE") ))))
			lSeek := DbSeek((cAliasZBZ)->&(xZBZ_+"FILIAL")+Padr(cNotaSeek,9)+(cAliasZBZ)->&(xZBZ_+"SERIE")+cCodFor+cTipoNf)
		EndIF

	Endif

	If !lSeek   //Serve para todos, NFE e CTE e dai acerta o Tipo

		DbSelectArea( "SF1" )
		DbSetORder( 8 )
		lSeek := DbSeek((cAliasZBZ)->&(xZBZ_+"FILIAL")+(cAliasZBZ)->&(xZBZ_+"CHAVE"))
		DbSetORder( 1 )

		if lSeek
			cTipoNf := SF1->F1_TIPO
		Endif

	Endif

	If lSeek

		nOk++

		//			If !Empty(SF1->F1_STATUS)
		DbSelectArea(xZBZ)
		DbGoTo((cAliasZBZ)->R_E_C_N_O_)

		RecLock(xZBZ,.F.)

		(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PRENF"), Iif(Empty(SF1->F1_STATUS),'S','N') ))

		if cTipoNf <> (xZBZ)->&(xZBZ_+"TPDOC")  //cTipoNf == "C" .and. (xZBZ)->&(xZBZ_+"TPDOC") == "N" .And. (xZBZ)->&(xZBZ_+"MODELO") == "57"
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPDOC"), cTipoNf ))
		endif

		MsUnlock()
		//			EndIf
	ElseiF (cAliasZBZ)->&(xZBZ_+"PRENF") $ "A|S|N"

		If (cAliasZBZ)->&(xZBZ_+"PRENF") == "A"
			nNo++
		Endif

		DbSelectArea("DB2")
		DbSetorder(1)
		lSeek := .F.
		cNotaSeek :=  Iif(nFormNfe > 0,StrZero(Val((cAliasZBZ)->&(xZBZ_+"NOTA")),nFormNfe),AllTrim(Str(Val((cAliasZBZ)->&(xZBZ_+"NOTA") ))))
		lSeek := DbSeek((cAliasZBZ)->&(xZBZ_+"FILIAL")+Padr(cNotaSeek,9)+(cAliasZBZ)->&(xZBZ_+"SERIE")+cCodFor)

		DbSelectArea(xZBZ)
		DbGoTo((cAliasZBZ)->R_E_C_N_O_)

		RecLock(xZBZ,.F.)

		(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PRENF"), iif(lSeek, 'A', 'B') ))
		(xZBZ)->(FieldPut(FieldPos(xZBZ_+"DOCCTE"), space(9) ))

		(xZBZ)->( MsUnlock() )

	Else

		nNo++

	EndIf

	/*
	If !lAuto .Or. oProcess<>Nil
	oProcess:IncRegua2("Serie/Nota : "+(cAliasZBZ)->ZBZ_SERIE+"/"+(cAliasZBZ)->ZBZ_NOTA)
	EndIf
	*/
	(cAliasZBZ)->(DbSkip())

EndDo

cLogProc += StrZero(nOk,6)+" Pré-Nota(s) encontrada(s)."+CRLF
cLogProc += StrZero(nNo,6)+" Pré-Nota(s) não encontrada(s)."+CRLF

DbSelectArea(cAliasZBZ)
DbCloseArea()

RestArea(aArea)



Return


//Realiza atualização do status dos xml´s que estao baixados com base nas notas de entrada.
//Atualizado por Rogério Lino - 27/02/2020
User Function UPStatXML(lAuto,lEnd,oProcess,cLogProc,nCount,cChave)

Local aArea      := GetArea()
//Local cQry       := ""
Local cWhere     := ""
Local cTabela    := ""
Local cAliasZBZ  := GetNextAlias()
Local lSeekFor   := (xZBZ)->(FieldPos(xZBZ_+"CODFOR"))>0 .And. (xZBZ)->(FieldPos(xZBZ_+"LOJFOR"))>0
Local nOk        := 0
Local nNo        := 0
Local nTotReg    := 0
Local cAnd       := ""
Local dEmiXML    := Ctod("  /  /    ") 	//FR - 04/11/2021 - #11460 - ADAR
Local aDocOri    := {"1",; // (Gestão XML)     -> Erick Silva - 16/02/2023
					 "2"}  // (Protheus Padrão)
Local cOriNF     := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"ORIGEM")))  // Erick e Lucas San -> 16/02/2023

Private lSharedA1:= U_IsShared("SA1")
Private lSharedA2:= U_IsShared("SA2")
Private nFormNfe := Val(GetNewPar("XM_FORMNFE","9"))
Private dDtProc  := dDatabase - Val(GetNewPar("XM_D_STATUS","180"))

Default cLogProc := ""
Default lAuto    := .F.
Default oProcess := Nil
Default lEnd     := .F.
Default nCount   := 0
Default cChave   := ""

cLogProc += "### Atualizando Status Xml. ###"+CRLF

//	cWhere := "%( (ZBZ.ZBZ_PRENF NOT IN ('F')) )%"
cTabela := "%"+RetSqlName(xZBZ)+"%"
if !Empty( cChave )

	cAnd := " AND ZBZ."+xZBZ_+"CHAVE ='" + cChave +"' "

endif
cWhere  := "%( (ZBZ."+xZBZ_+"PRENF NOT IN ('F') AND ZBZ."+xZBZ_+"DTRECB >='" +Dtos(dDtProc)+"') "+ cAnd +" )%"
cCampos	:= "%"+xZBZ_+"FILIAL, "+xZBZ_+"NOTA, "+xZBZ_+"SERIE, "+xZBZ_+"DTNFE, "+xZBZ_+"PRENF, "+xZBZ_+"CNPJ, "+xZBZ_+"MODELO, "+xZBZ_+"DOCCTE, "+;
xZBZ_+"FORNEC, "+xZBZ_+"CNPJD, "+xZBZ_+"CLIENT,"+xZBZ_+"CHAVE,"+xZBZ_+"TPDOC, ZBZ.R_E_C_N_O_"

If lSeekFor

	cCampos	+=	","+xZBZ_+"CODFOR,"+xZBZ_+"LOJFOR%"
	
Else

	cCampos	+=	"%"
	
EndIf

BeginSql Alias cAliasZBZ

	SELECT	%Exp:cCampos%
	FROM %Exp:cTabela% ZBZ
	WHERE ZBZ.%notdel%
	AND %Exp:cWhere%
EndSql

Count To nTotReg

ProcRegua( nTotReg )

DbSelectArea(cAliasZBZ)

(cAliasZBZ)->( DbGotop() )

While !(cAliasZBZ)->(Eof())

	cTipoNf := Iif(Empty((cAliasZBZ)->&(xZBZ_+"TPDOC")),"N",(cAliasZBZ)->&(xZBZ_+"TPDOC"))
	cCodFor := (cAliasZBZ)->&(xZBZ_+"CODFOR")+(cAliasZBZ)->&(xZBZ_+"LOJFOR")
	dEmiXML := Stod((cAliasZBZ)->&(xZBZ_+"DTNFE"))  	//FR - 04/11/2021 - #11460 - ADAR

	if empty( cCodFor )

		If cTipoNf $ "D|B"

			cFilSeek := xFilial("SA1")   //Iif(lSharedA1,xFilial("SA1"),(cAliasZBZ)->&(xZBZ_+"FILIAL") )
			
			DbSelectArea("SA1")
			DbSetOrder(3)

			If DbSeek(cFilSeek+(cAliasZBZ)->&(xZBZ_+"CNPJ"))

				cCodFor := SA1->A1_COD+SA1->A1_LOJA

				Do While .not. SA1->( eof() ) .and. SA1->A1_FILIAL == cFilSeek .and.;
				SA1->A1_CGC == (cAliasZBZ)->&(xZBZ_+"CNPJ")

					if SA1->A1_MSBLQL != "1"
					
						cCodFor := SA1->A1_COD+SA1->A1_LOJA
						exit
						
					endif

					SA1->( dbSkip() )

				EndDo

			EndIf

		Else

			cFilSeek := xFilial("SA2")  //Iif(lSharedA2,xFilial("SA2"),(cAliasZBZ)->&(xZBZ_+"FILIAL") )
			DbSelectArea("SA2")
			DbSetOrder(3)

			If DbSeek(cFilSeek+(cAliasZBZ)->&(xZBZ_+"CNPJ"))

				cCodFor := SA2->A2_COD+SA2->A2_LOJA

				Do While .not. SA2->( eof() ) .and. SA2->A2_FILIAL == cFilSeek .and.;
				SA2->A2_CGC == (cAliasZBZ)->&(xZBZ_+"CNPJ")

					if SA2->A2_MSBLQL != "1"
						cCodFor := SA2->A2_COD+SA2->A2_LOJA
						exit
					endif

					SA2->( dbSkip() )

				EndDo

			EndIf

		EndIf

	Endif

	DbSelectArea("SF1")

	lSeek := .F.
	cNotaSeek :=  Iif(nFormNfe > 0,StrZero(Val((cAliasZBZ)->&(xZBZ_+"NOTA")),nFormNfe),AllTrim(Str(Val((cAliasZBZ)->&(xZBZ_+"NOTA") ))))
	lSeek := DbSeek((cAliasZBZ)->&(xZBZ_+"FILIAL")+Padr(cNotaSeek,9)+(cAliasZBZ)->&(xZBZ_+"SERIE")+cCodFor+cTipoNf)

	If !lSeek
		cNotaSeek := AllTrim(Str(Val((cAliasZBZ)->&(xZBZ_+"NOTA"))))
		lSeek := DbSeek((cAliasZBZ)->&(xZBZ_+"FILIAL")+Padr(cNotaSeek,9)+(cAliasZBZ)->&(xZBZ_+"SERIE")+cCodFor+cTipoNf)
	EndIf

	If !lSeek

		cNotaSeek :=  StrZero(Val((cAliasZBZ)->&(xZBZ_+"NOTA")),6)
		lSeek := DbSeek((cAliasZBZ)->&(xZBZ_+"FILIAL")+Padr(cNotaSeek,9)+(cAliasZBZ)->&(xZBZ_+"SERIE")+cCodFor+cTipoNf)

	EndIf

	If !lSeek

		cNotaSeek :=  StrZero(Val((cAliasZBZ)->&(xZBZ_+"NOTA")),9)
		lSeek := DbSeek((cAliasZBZ)->&(xZBZ_+"FILIAL")+Padr(cNotaSeek,9)+(cAliasZBZ)->&(xZBZ_+"SERIE")+cCodFor+cTipoNf)

	EndIf

	//aquiii Multiplos CTE
	If !lSeek .And. (cAliasZBZ)->&(xZBZ_+"MODELO") == "57" .And. !Empty( (cAliasZBZ)->&(xZBZ_+"DOCCTE") )

		cNotaSeek :=  Iif(nFormNfe > 0,StrZero(Val((cAliasZBZ)->&(xZBZ_+"DOCCTE")),nFormNfe),AllTrim(Str(Val((cAliasZBZ)->&(xZBZ_+"DOCCTE") ))))
		lSeek := DbSeek((cAliasZBZ)->&(xZBZ_+"FILIAL")+Padr(cNotaSeek,9)+(cAliasZBZ)->&(xZBZ_+"SERIE")+cCodFor+cTipoNf)

	EndIF

	If !lSeek

		SF1->( DbSetORder(8) )  //F1_FILIAL + F1_CHNFE
		lSeek := DbSeek( (cAliasZBZ)->&(xZBZ_+"FILIAL")+Trim((cAliasZBZ)->&(xZBZ_+"CHAVE")) )  
		
		//FR - 04/11/2021 - #11460 - ADAR
		If lSeek
			If Empty(SF1->F1_CHVNFE)  //se a chave estiver vazia, comparar com data emissão para validar se o seek é .T. 
				If dEmiXml <> SF1->F1_EMISSAO  //se a emissão for diferente, o seek é .F.
					lSeek := .F.
					
					DbSelectArea(xZBZ)
					DbGoTo((cAliasZBZ)->R_E_C_N_O_)
				
					RecLock(xZBZ,.F.)
					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PRENF"), 'B' ))
					(xZBZ)->( MsUnlock() )
					
				Endif 
			Endif 
		Endif
		//FR - 04/11/2021 - #11460 - ADAR 
		SF1->( DbSetORder(1) )

	EndIF

	//NFS-e
	If !lSeek	
		If (cAliasZBZ)->&(xZBZ_+"MODELO") == "RP"
			cNotaSeek :=  Iif(nFormNfe > 0,StrZero(Val((cAliasZBZ)->&(xZBZ_+"NOTA")),nFormNfe),AllTrim(Str(Val((cAliasZBZ)->&(xZBZ_+"NOTA") ))))
			lSeek := DbSeek((cAliasZBZ)->&(xZBZ_+"FILIAL")+Padr(cNotaSeek,9)+(cAliasZBZ)->&(xZBZ_+"SERIE")+cCodFor+cTipoNf)
			If !lSeek
				lSeek := DbSeek((cAliasZBZ)->&(xZBZ_+"FILIAL")+Padr(cNotaSeek,9)+Padr(GetNewPar("XM_SER_NFS",""),3)+cCodFor+cTipoNf)
			EndiF	
		EndIf
	EndIf

	//FR - 04/11/2021 - #11460 - ADAR
	If lSeek
		If dEmiXml <> SF1->F1_EMISSAO  //se a emissão for diferente, o seek é .F.
			lSeek := .F.
				
			DbSelectArea(xZBZ)
			DbGoTo((cAliasZBZ)->R_E_C_N_O_)
			
			RecLock(xZBZ,.F.)
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PRENF"), 'B' ))
			(xZBZ)->( MsUnlock() )
				
		Endif 		 
	Endif
	//FR - 04/11/2021 - #11460 - ADAR	
	If lSeek

		nOk++
		//			If !Empty(SF1->F1_STATUS)
		DbSelectArea(xZBZ)
		DbGoTo((cAliasZBZ)->R_E_C_N_O_)
		
		RecLock(xZBZ,.F.)
		(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PRENF"), Iif(Empty(SF1->F1_STATUS),'S','N') ))
				
		//Lucas San e Erick Gonçalves - 16/02/2023
		cSF1   := SF1->F1_STATUS
		cOriNF := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"ORIGEM") ))

		If (cAliasZBZ)->&(xZBZ_+"PRENF") == "N" .and. Empty(cOriNF)
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"ORIGEM"),aDocOri[1]) )

		Elseif (cAliasZBZ)->&(xZBZ_+"PRENF") <> "N" .and. (cSF1) == "A"
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"ORIGEM"),aDocOri[2]) )
		
		Endif

		(xZBZ)->( MsUnlock() )
		//			EndIf

	ElseiF (cAliasZBZ)->&(xZBZ_+"PRENF") $ "S|N"

		DbSelectArea(xZBZ)
		DbGoTo((cAliasZBZ)->R_E_C_N_O_)

		RecLock(xZBZ,.F.)
		(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PRENF"), 'B' ))
		(xZBZ)->( MsUnlock() )

	Else

		nNo++

	EndIf

	IncProc("Processando "+(cAliasZBZ)->&(xZBZ_+"SERIE")+"/"+Padr(cNotaSeek,9))

	(cAliasZBZ)->(DbSkip())

EndDo

cLogProc += StrZero(nOk,6)+" Pré-Nota(s) encontrada(s)."+CRLF
cLogProc += StrZero(nNo,6)+" Pré-Nota(s) não encontrada(s)."+CRLF

DbSelectArea(cAliasZBZ)
DbCloseArea()

if Empty( cChave )

	Aviso("Aviso", cLogProc,{"OK"},3)

endif

RestArea(aArea)

Return


Static Function VerStat( cFilXml, cDocXMl, cSerie, cCodFor, cTipoDoc, cChaveXml )  //"B"

Local cRet := "B"
Local aArea := GetArea()
Local lSeek := .F.
Local cNotaSeek := ""

Private nFormNfe := Val(GetNewPar("XM_FORMNFE","9"))
Private cTipoNf := Iif( Empty(cTipoDoc), "N", cTipoDoc )

cSerie := Padr( cSerie, len(SF1->F1_SERIE) )

lSeek := .F.
DbSelectArea("SF1")
DbSetOrder(1)

cNotaSeek :=  Iif(nFormNfe > 0,StrZero(Val(cDocXMl),nFormNfe),AllTrim(Str(Val(cDocXMl))))
lSeek := DbSeek(cFilXml+Padr(cNotaSeek,9)+cSerie+cCodFor+cTipoNf)

If !lSeek

	cNotaSeek := AllTrim(Str(Val(cDocXMl)))
	lSeek := DbSeek(cFilXml+Padr(cNotaSeek,9)+cSerie+cCodFor+cTipoNf)

EndIf

If !lSeek

	cNotaSeek :=  StrZero(Val(cDocXMl),6)
	lSeek := DbSeek(cFilXml+Padr(cNotaSeek,9)+cSerie+cCodFor+cTipoNf)

EndIf

If !lSeek

	cNotaSeek :=  StrZero(Val(cDocXMl),9)
	lSeek := DbSeek(cFilXml+Padr(cNotaSeek,9)+cSerie+cCodFor+cTipoNf)

EndIf

If !lSeek  //mudar a serie para zeros a esquerda

	cSerie := StrZero( Val( cSerie ), 3 )
	cNotaSeek :=  Iif(nFormNfe > 0,StrZero(Val(cDocXMl),nFormNfe),AllTrim(Str(Val(cDocXMl))))
	lSeek := DbSeek(cFilXml+Padr(cNotaSeek,9)+cSerie+cCodFor+cTipoNf)

	If !lSeek
		cNotaSeek := AllTrim(Str(Val(cDocXMl)))
		lSeek := DbSeek(cFilXml+Padr(cNotaSeek,9)+cSerie+cCodFor+cTipoNf)
	EndIf

	If !lSeek
		cNotaSeek :=  StrZero(Val(cDocXMl),6)
		lSeek := DbSeek(cFilXml+Padr(cNotaSeek,9)+cSerie+cCodFor+cTipoNf)
	EndIf

	If !lSeek
		cNotaSeek :=  StrZero(Val(cDocXMl),9)
		lSeek := DbSeek(cFilXml+Padr(cNotaSeek,9)+cSerie+cCodFor+cTipoNf)
	EndIf

endif

If !lSeek

	DbSelectArea("SF1")
	DbSetOrder(8)
	lSeek := DbSeek(cFilXml+cChaveXml)
	DbSetOrder(1)

EndIf

If lSeek
	//   	if empty(SF1->F1_CHVNFE) .Or. alltrim(cChaveXml) = alltrein(SF1->F1_CHVNFE)
	cRet := Iif(Empty(SF1->F1_STATUS),"S","N")
	//   	endif
Endif

RestArea(aArea)

Return( cRet )


//Realiza atualização dos xml´s que estao baixados sem os fornecedores preenchidos.
//Atualizado por Rogério Lino - 27/02/2020
User Function UPForXML(lAuto,lEnd,oProcess,cLogProc,nCount,lMostra)

Local aArea     := GetArea()
Local cQuery    := ""
Local cWhere    := ""
Local cAliasZBZ := GetNextAlias()
Local nOk       := 0
Local nNo       := 0
Local cTabela   := ""
Local cCampos   := ""
Local cIndRur	:= ""
Local nTotReg   := 0
Local xZBZ  	:= GetNewPar("XM_TABXML","ZBZ")      
Local xZBZ_     := iif(Substr(xZBZ,1,1)=="S", Substr(xZBZ,2,2), Substr(xZBZ,1,3)) + "_"

Private lSharedA1:= U_IsShared("SA1")
Private lSharedA2:= U_IsShared("SA2")

Default cLogProc:= ""
Default lAuto   := .F.
Default oProcess:= Nil
Default lEnd    := .F.
Default nCount  := 0
Default lMostra := .T.

cLogProc +="### Atualizando Fornecedores Xml. ###"+CRLF

cTabela := "%"+RetSqlName(xZBZ)+"%"
cCampos := "%"+xZBZ_+"FILIAL, "+xZBZ_+"NOTA, "+xZBZ_+"SERIE, "+xZBZ_+"DTNFE, "+xZBZ_+"PRENF, "+xZBZ_+"CNPJ, "+;
xZBZ_+"FORNEC, "+xZBZ_+"CNPJD, "+xZBZ_+"CLIENT,"+xZBZ_+"CHAVE, "+xZBZ_+"CODFOR, "+xZBZ_+"INDRUR, "+;
xZBZ_+"LOJFOR, "+xZBZ_+"TPDOC, ZBZ.R_E_C_N_O_%"
cWhere := "%( ZBZ."+xZBZ_+"CODFOR='' OR ZBZ."+xZBZ_+"LOJFOR='' OR ZBZ."+xZBZ_+"FORNEC='' )%"

BeginSql Alias cAliasZBZ

	SELECT	%Exp:cCampos%
	FROM %Exp:cTabela% ZBZ
	WHERE ZBZ.%notdel%
	AND %Exp:cWhere%
EndSql

Count to nTotReg

ProcRegua( nTotReg )

DbSelectArea(cAliasZBZ)

(cAliasZBZ)->( DbGotop() )

While !(cAliasZBZ)->(Eof())

	cTipoNf := Iif(Empty((cAliasZBZ)->&(xZBZ_+"TPDOC")),"N",(cAliasZBZ)->&(xZBZ_+"TPDOC"))
	cCodFor := (cAliasZBZ)->&(xZBZ_+"CODFOR")+(cAliasZBZ)->&(xZBZ_+"LOJFOR")
	cIndRur	:= ""   //AQUUII Faltava inicializar a variavel a cada registro

	If cTipoNf $ "D|B"

		cFilSeek := xFilial("SA1")     //Iif(lSharedA1,xFilial("SA1"),(cAliasZBZ)->&(xZBZ_+"FILIAL") )
		
		DbSelectArea("SA1")
		DbSetOrder(3)

		If .not. Empty((cAliasZBZ)->&(xZBZ_+"CNPJ")) .And. DbSeek(cFilSeek+(cAliasZBZ)->&(xZBZ_+"CNPJ"))

			cCodEmit  := SA1->A1_COD
			cLojaEmit := SA1->A1_LOJA
			cRazao    := SA1->A1_NOME

			Do While .not. SA1->( eof() ) .and. SA1->A1_CGC == (cAliasZBZ)->&(xZBZ_+"CNPJ")      //SA1->A1_FILIAL == cFilSeek 

				if SA1->A1_MSBLQL != "1"

					cCodEmit  := SA1->A1_COD
					cLojaEmit := SA1->A1_LOJA
					cRazao    := SA1->A1_NOME
					exit

				endif

				SA1->( dbSkip() )

			EndDo

			DbSelectArea(xZBZ)
			DbGoTo((cAliasZBZ)->R_E_C_N_O_)

			RecLock(xZBZ,.F.)
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CODFOR"), cCodEmit))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"LOJFOR"), cLojaEmit))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"FORNEC"), cRazao))
			//					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"INDRUR"), cIndRur))  // AQUI SA1 não precisa
			(xZBZ)->( MsUnlock() )

			nOk++

		Else

			cCodEmit  := ""
			cLojaEmit := ""
			cRazao    := ""
			nNo++

		EndIf

	Else
	
		/*cAliasSA2 := GetNextAlias()
	
		cQuery := " SELECT SA2.A2_COD, SA2.A2_LOJA, SA2.A2_NOME, SA2.A2_INDRUR, ZBZ.R_E_C_N_O_ AS RECNO "
		cQuery += " FROM "+RetSqlName(xZBZ)+" ZBZ inner join "+RetSqlName("SA2")+" SA2 ON "+xZBZ_+"CNPJ = A2_CGC "
		cQuery += " WHERE ZBZ.D_E_L_E_T_ = '' "
		cQuery += " AND SA2.D_E_L_E_T_ = '' "
		cQuery += " AND ZBZ."+xZBZ_+"CNPJ = '" + (cAliasZBZ)->&(xZBZ_+"CNPJ") + "' "
		cQuery += " AND ZBZ."+xZBZ_+"CODFOR = '' "
		cQuery += " ORDER BY SA2.A2_CGC "

		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSA2,.T.,.T.)
		
		Count To nTotReg
	
		ProcRegua( nTotReg )
		
		(cAliasSA2)->( DbGotop() )
	
		While (cAliasSA2)->( !Eof() )
	
			IncProc("")
			
			nOk++
	
			DbSelectArea(xZBZ)
			DbGoTo( (cAliasSA2)->RECNO )

			RecLock(xZBZ,.F.)

			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CODFOR"), (cAliasSA2)->A2_COD))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"LOJFOR"), (cAliasSA2)->A2_LOJA))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"FORNEC"), (cAliasSA2)->A2_NOME))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"INDRUR"), (cAliasSA2)->A2_INDRUR))
			
			(xZBZ)->( MsUnlock() )
	
			(cAliasSA2)->( DbSkip() )
	
		EndDo
		
		(cAliasSA2)->( DbCloseArea() )*/

		cFilSeek := xFilial("SA2")   //Iif(lSharedA2,xFilial("SA2"),(cAliasZBZ)->&(xZBZ_+"FILIAL") )
		
		DbSelectArea("SA2")
		DbSetOrder(3)

		If .not. Empty((cAliasZBZ)->&(xZBZ_+"CNPJ")) .And. DbSeek(cFilSeek+(cAliasZBZ)->&(xZBZ_+"CNPJ"))

			if !Empty(SA2->A2_CGC)
			
				cCodEmit  := SA2->A2_COD
				cLojaEmit := SA2->A2_LOJA
				cRazao    := SA2->A2_NOME
				
			endif

			Do While .not. SA2->( eof() ) .and. SA2->A2_CGC == (cAliasZBZ)->&(xZBZ_+"CNPJ")        //SA2->A2_FILIAL == cFilSeek .and.
			
				if SA2->A2_MSBLQL != "1" .and. !Empty(SA2->A2_CGC)

					cCodEmit  := SA2->A2_COD
					cLojaEmit := SA2->A2_LOJA
					cRazao    := SA2->A2_NOME
					cIndRur	  := SA2->A2_INDRUR   //AQUUII Faltava  preencher a variavel com o valor do INDRUR do SA2
					exit

				endif

				SA2->( dbSkip() )

			EndDo

			DbSelectArea(xZBZ)
			DbGoTo((cAliasZBZ)->R_E_C_N_O_)

			RecLock(xZBZ,.F.)

			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CODFOR"), cCodEmit))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"LOJFOR"), cLojaEmit))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"FORNEC"), cRazao))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"INDRUR"), cIndRur))
			
			(xZBZ)->( MsUnlock() )

			nOk++

		Else

			cCodEmit  := ""
			cLojaEmit := ""
			cRazao    := ""
			nNo++

		EndIf

	EndIf

	IncProc("Processando "+(cAliasZBZ)->&(xZBZ_+"CNPJ"))

	(cAliasZBZ)->(DbSkip())

EndDo

cLogProc += StrZero(nOk,6)+" Fornecedor(es) encontrado(s)."+CRLF
cLogProc += StrZero(nNo,6)+" Fornecedor(es) não encontrado(s)."+CRLF

DbSelectArea(cAliasZBZ)
DbCloseArea()

DbSelectArea( "SA2" )

if SA2->(FieldPos("A2_INDRUR")) > 0

	cLogProc +="### Atualizando Fornecedores Rural Xml. ###"+CRLF

	cAliasZBZ := GetNextAlias()

	nOk := 0

	cQuery := "SELECT "+xZBZ_+"CHAVE, ZBZ."+xZBZ_+"CODFOR, "+xZBZ_+"LOJFOR, ZBZ."+xZBZ_+"INDRUR, SA2.A2_INDRUR, ZBZ.R_E_C_N_O_ "
	cQuery += "FROM "+RetSqlName(xZBZ)+" ZBZ inner join "+RetSqlName("SA2")+" SA2 ON "+xZBZ_+"CODFOR = A2_COD and "+xZBZ_+"LOJFOR = A2_LOJA "
	cQuery += "WHERE ZBZ.D_E_L_E_T_ = '' "
	cQuery += "AND SA2.D_E_L_E_T_ = '' "
	cQuery += "AND ZBZ."+xZBZ_+"CODFOR <> '' "
	cQuery += "AND (( ZBZ."+xZBZ_+"INDRUR in (' ','0') "
	cQuery += "AND SA2.A2_INDRUR > '0' ) "
	cQuery += "OR ( ZBZ."+xZBZ_+"INDRUR > '0' "
	cQuery += "AND SA2.A2_INDRUR <= '0' )) "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasZBZ,.T.,.T.)
	
	Count To nTotReg
	
	ProcRegua( nTotReg )

	DbSelectArea(cAliasZBZ)
	
	(cAliasZBZ)->( DbGotop() )

	While !(cAliasZBZ)->(Eof())

		IncProc("Processando "+(cAliasZBZ)->&(xZBZ_+"CHAVE"))
		
		cIndRur := (cAliasZBZ)->(FieldGet(FieldPos("A2_INDRUR")))
		
		nOk++

		DbSelectArea(xZBZ)
		DbGoTo((cAliasZBZ)->R_E_C_N_O_)

		RecLock(xZBZ,.F.)
		
		(xZBZ)->(FieldPut(FieldPos(xZBZ_+"INDRUR"), cIndRur))
		
		(xZBZ)->( MsUnlock() )

		DbSelectArea(cAliasZBZ)

		(cAliasZBZ)->(DbSkip())

	EndDo

	cLogProc += StrZero(nOk,6)+" XMLs alterados para Fornecedor Rural."+CRLF

	DbSelectArea(cAliasZBZ)
	
	DbCloseArea()

EndIf

if GetNewPar("XM_USAGFE","N") = "S" .And. (xZBZ)->(FieldPos(xZBZ_+"SITGFE")) > 0  //O GFE esta ativo

	if lMostra
		ProcRegua(0)
	endif

	cLogProc +="### Atualizando Situação do GFE. ###"+CRLF

	//	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"SITGFE"), U_HFSITGFE( cChaveXml, "GFE" ) ))
	cAliasZBZ := GetNextAlias()

	nOk := 0

	cQuery := " SELECT "+xZBZ_+"PRENF AS STATUS_IMPORTA, ZBZ.R_E_C_N_O_,  "
	cQuery += " GW3_SIT AS STATUS_GFE, "
	cQuery += " (CASE WHEN GW3_CTE IS NULL THEN "+xZBZ_+"CHAVE ELSE GW3_CTE END) as CHAVE, "
	cQuery += " "+xZBZ_+"CODFOR AS FORNECEDOR, "+xZBZ_+"LOJFOR AS LOJA,"
	cQuery += " (CASE WHEN "+xZBZ_+"DTNFE IS NULL THEN GW3_DTEMIS ELSE "+xZBZ_+"DTNFE END) as DATA, "
	cQuery += " (CASE WHEN "+xZBZ_+"VLBRUT IS NULL THEN GW3_FRVAL ELSE "+xZBZ_+"VLBRUT END) as VALOR FROM "+ RetSqlName(xZBZ) + " ZBZ "
	cQuery += " FULL OUTER JOIN "+ RetSqlName("GW3") + " GW3 ON GW3_CTE = "+xZBZ_+"CHAVE AND GW3.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE ZBZ.D_E_L_E_T_ = ' ' AND "
	cQuery += " "+xZBZ_+"MODELO = '57' AND "
	cQuery += " (("+xZBZ_+"SITGFE > '1' AND GW3_SIT IS NULL) OR "
	cQuery += "  ("+xZBZ_+"SITGFE in (' ','1') AND GW3_SIT > '0' ) OR "
	cQuery += "  ("+xZBZ_+"SITGFE = '2' AND GW3_SIT > '2' ) OR "
	cQuery += "  ("+xZBZ_+"SITGFE in ('3','4') AND GW3_SIT <> "+xZBZ_+"SITGFE ) ) "
	cQuery += " ORDER BY "+xZBZ_+"DTNFE "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasZBZ,.T.,.T.)
	
	Count to nTotReg
	
	ProcRegua( nTotReg)

	DbSelectArea(cAliasZBZ)
	
	(cAliasZBZ)->( DbGotop() )

	While !(cAliasZBZ)->(Eof())

		if lMostra

			IncProc("Atualizando Situação GFE "+(cAliasZBZ)->CHAVE)

		endif

		nOk++
		DbSelectArea(xZBZ)
		DbGoTo((cAliasZBZ)->R_E_C_N_O_)

		RecLock(xZBZ,.F.)
		(xZBZ)->(FieldPut(FieldPos(xZBZ_+"SITGFE"), U_HFSITGFE( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))), "GFE" )))
		(xZBZ)->( MsUnlock() )

		DbSelectArea(cAliasZBZ)

		(cAliasZBZ)->(DbSkip())

	EndDo

	cLogProc += StrZero(nOk,6)+" XMLs sincronizados com Situação GFE."+CRLF

	DbSelectArea(cAliasZBZ)
	DbCloseArea()

EndIf

RestArea(aArea)

If lMostra

	Aviso("Aviso", cLogProc,{"OK"},3)

EndIf

Return


//Realiza atualização dos xml´s baixados no gestao xml
//Atualizado por Rogério Lino - 27/02/2020
User Function UPConsXML(lAuto,lEnd,oProcess,cLogProc,nCount,cUrl)

Local aArea      := GetArea()
//Local cQry       := ""
Local cWhere     := ""
Local cTabela    := ""
Local cAliasZBZ  := GetNextAlias()
Local nOk        := 0
Local nNo        := 0
Local cMensagem  := ""
Local xManif     := "" //GETESB2
Local cMsg	     := ""  //ECOURBIS
Local cDir       := AllTrim(SuperGetMv("MV_X_PATHX"))
Local cDirLog    := AllTrim(cDir+cBarra+"Log"+cBarra+"Job4"+cBarra)
Local cArqLog    := cDirLog+"\SEFAZ_"+StrTran(DtoS(Date())+Time(),":","")+"_F"+cFilAnt+".LOG"
Local nHdl       := 0
Local nVezes     := 0
Local nTotReg    := 0
Local dDtNfe     := dDatabase - 180

Private dDtProc  := dDatabase - Val(GetNewPar("XM_D_CANCEL","90"))

Default cLogProc := ""
Default lAuto    := .F.
Default oProcess := Nil
Default lEnd     := .F.
Default nCount   := 0
Default cURL     := AllTrim(GetNewPar("XM_URL",""))

If Empty(cURL)
	cURL  := AllTrim(SuperGetMv("MV_SPEDURL"))
EndIf

cMsg	   := ""  //ECOURBIS
nHdl       := 0
cDir       := AllTrim(SuperGetMv("MV_X_PATHX"))
cDirLog    := AllTrim(cDir+cBarra+"Log"+cBarra+"Job4"+cBarra)
cDirLog    := StrTran(cDirLog,cBarra+cBarra,cBarra)
cArqLog    := cDirLog+cBarra+"SEFAZ_"+StrTran(DtoS(Date())+Time(),":","")+"_F"+cFilAnt+".LOG"
cArqLog    := StrTran(cArqLog,cBarra+cBarra,cBarra)

U_HfLogLin("[INICIO] Consultando Xml's.",cDirLog,cArqLog,@nHdl)

cLogProc +="### Consultando Xml's. ###"+CRLF

cTabela := RetSqlName(xZBZ)

If lAuto
	cWhere := "( (ZBZ."+xZBZ_+"PRENF NOT IN ('F') AND ZBZ."+xZBZ_+"MAIL NOT IN ('4') AND ZBZ."+xZBZ_+"DTRECB >='" +Dtos(dDtProc)+"' AND ZBZ."+xZBZ_+"DTNFE >='" +Dtos(dDtNFE)+"') AND ZBZ."+xZBZ_+"FILIAL ='" +xFilial( xZBZ )+"')"  //AND ZBZ."+xZBZ_+"MAIL NOT IN ('4')
Else
	cWhere := "( (ZBZ."+xZBZ_+"PRENF NOT IN ('F') AND ZBZ."+xZBZ_+"MAIL NOT IN ('4') AND ZBZ."+xZBZ_+"DTRECB >='" +Dtos(dDtProc)+"' AND ZBZ."+xZBZ_+"DTNFE >='" +Dtos(dDtNFE)+"') AND ZBZ."+xZBZ_+"FILIAL ='" +xFilial( xZBZ )+"')"
EndIf

cCampos := xZBZ_+"FILIAL, "+xZBZ_+"NOTA, "+xZBZ_+"SERIE, "+xZBZ_+"DTNFE, "+xZBZ_+"PRENF, "+xZBZ_+"CNPJ, "+;
xZBZ_+"FORNEC, "+xZBZ_+"CNPJD, "+xZBZ_+"CLIENT,"+xZBZ_+"CHAVE,"+xZBZ_+"TPDOC, "+xZBZ_+"MODELO, "+xZBZ_+"MANIF, ZBZ.R_E_C_N_O_ "  //GETESB2

If (xZBZ)->(FieldPos(xZBZ_+"PROT")) > 0

	cCampos	+=	","+xZBZ_+"PROT"

Else

	cCampos	+=	""

EndIf

U_HfLogLin("[WHERE] "+cWhere,cDirLog,cArqLog,@nHdl)

cQuery := " SELECT " + cCampos
cQuery += " FROM "+cTabela+" ZBZ "
cQuery += " WHERE ZBZ.D_E_L_E_T_ = '' AND "+cWhere+" 
cQuery += " ORDER BY "+xZBZ_+"CNPJ

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasZBZ,.T.,.T.)

/*BeginSql Alias cAliasZBZ

	SELECT	%Exp:cCampos%
	FROM %Exp:cTabela% ZBZ
	WHERE ZBZ.%notdel%
	AND %Exp:cWhere%
	
EndSql*/

Count to nTotReg

ProcRegua( nTotReg )

Conout("Total de xmls a consultar " + cValToChar( nTotReg ))

DbSelectArea(cAliasZBZ)

(cAliasZBZ)->( DbGotop() )

While !(cAliasZBZ)->(Eof())

	If AllTrim((cAliasZBZ)->&(xZBZ_+"MODELO")) == "55"

		cPref    := "NF-e"
		cTAG     := "NFE"

	ElseIf AllTrim((cAliasZBZ)->&(xZBZ_+"MODELO")) == "65"

		cPref    := "NFC-e"
		cTAG     := "NFE"

	ElseIf AllTrim((cAliasZBZ)->&(xZBZ_+"MODELO")) == "57"

		cPref    := "CT-e"
		cTAG     := "CTE"

	EndIf

	cMensagem := ""
	cCodRet   := ""
	xManif    := (cAliasZBZ)->&(xZBZ_+"MANIF") //GETESB2
	nVezes    := 0

	Do While nVezes <= ( GetNewPar("XM_QCONERR",4) + 1 )

		cMensagem := ""
		cCodRet   := ""
		xManif    := (cAliasZBZ)->&(xZBZ_+"MANIF") //GETESB2

		if GetNewPar( "XM_DFE", "0" ) == "2"

			lRet := u_NFeConsProt( Alltrim((cAliasZBZ)->&(xZBZ_+"CHAVE")), .F., @cCodRet, @xManif )

			//lValidado := U_XConsXml(cURL,cChaveXml,cModelo,cProtocolo,@cMensagem,@cCodRet,AllTrim(SuperGetMv("MV_MOSTRAA")) == "S",,,@xManif) //GETESB2

		else

			//lRet := U_XConsXml(cURL,cChaveXml,cModelo,cProtocolo,@cMensagem,@cCodRet,AllTrim(SuperGetMv("MV_MOSTRAA")) == "S",,,@xManif) //GETESB2
			lRet := U_XConsXml(cURL,Alltrim((cAliasZBZ)->&(xZBZ_+"CHAVE")),(cAliasZBZ)->&(xZBZ_+"MODELO"),(cAliasZBZ)->&(xZBZ_+"PROT"),@cMensagem,@cCodRet,.F.,,,@xManif)      //GETESB2

		endif 

		if lRet .or. !Empty(cCodRet)
			Exit
		Endif

		Sleep(1000)

		nVezes++

	EndDo

	cDtHrCOns := HfPutdt(1,dDatabase, Time(),"")
	cKey := (cAliasZBZ)->&(xZBZ_+"CHAVE")

	if cCodRet <> "100" .And. cCodRet <> "101"

		cMsg := cKey+" # Retorno "+cCodRet+" # Registro "+AllTrim(Str((cAliasZBZ)->R_E_C_N_O_))+cMensagem
		U_HfLogLin("[CHV ] "+cMsg,cDirLog,cArqLog,@nHdl)

	EndIF

	//U_XMLSETCS((cAliasZBZ)->ZBZ_MODELO,cKey,cCodRet,cMensagem)
	//podemos infiar isto aqui ao invés deste processamento abaixo.
	If lRet

		cMsg := cKey+"# .T. "

		If cCodRet == "101"

			lXmlCanc := .T.
			cOcorr   := cMensagem
			DbSelectArea(xZBZ)
			DbGoTo( (cAliasZBZ)->R_E_C_N_O_ )

			cMsg += "# ANT => PRENF "+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF")))+" => STATUS "+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"STATUS")))

			Reclock(xZBZ,.F.)

			cOcorr += "Tipo de xml: " + cPref +CRLF
			cOcorr += "Chave      : " + cKey +CRLF
			cOcorr += "Observação : " + "Cancelamento do Xml de "+cPref+ " autorizado." +CRLF
			cOcorr += "Aviso      : " + "Cancele o documento de "+cPref+ " manualmente." +CRLF

			cOcorr:= U_GetInfoErro("3",cOcorr,(xZBZ)->&(xZBZ_+"MODELO"))

			If (xZBZ)->&(xZBZ_+"PRENF") != "X"
				cLogProc += AllTrim(cKey)+" XML Cancelado. Cancele o documento de "+cPref+ " manualmente."+CRLF
				cMsg += " CANCELAR DOC ENTRADA "
			EndIf

			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PRENF")  , "X" ))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"STATUS") , "2" ))

			if (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MAIL"))) <> "4"
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"MAIL")   , "3" ))
			endif

			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"DTMAIL") , cOcorr ))

			Conout("Cancelamento realizado com sucesso " + cMensagem )

			cOri := "1"

			if FieldPos(xZBZ_+"IMPORT") > 0

				if !Empty( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"IMPORT"))) )
					cOri := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"IMPORT")))
				Endif

			Endif

			//(xZBZ)->(FieldPut(FieldPos(xZBZ_+"MANIF")  , U_HFMANZBS( AllTrim( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))) ), (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MANIF"))), cOri ) )) //GETESB2
			
			if (xZBZ)->(FieldPos(xZBZ_+"MANIF")) > 0   // .And. ! Empty(xManif) //GETESB2

				cRet := U_HFMANZBS( AllTrim( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))) ), (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MANIF"))), cOri )
				
				if !Empty( cRet )

					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"MANIF"), cRet ))

				endif

			endif

			DbSelectArea(xZBZ)
			MsUnLock()
			
			nNo++
			
			DbSelectArea(cAliasZBZ)

			if cCodRet <> "100" .And. cCodRet <> "101"

				cMsg += "# ATUAL => PRENF "+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF")))+" => STATUS "+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"STATUS")))
				U_HfLogLin("[CANC] "+cMsg,cDirLog,cArqLog,@nHdl)

			Endif

		Else

			DbSelectArea(xZBZ)
			DbGoTo((cAliasZBZ)->R_E_C_N_O_)

			cMsg += "# ANT => PRENF "+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF")))+" => STATUS "+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"STATUS")))

			Reclock(xZBZ,.F.)

			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"DTHRCS"), cDtHrCOns ))
			
			If cCodRet $ AllTrim(GetNewPar("XM_RETDEN","301,302,303"))  // Denegado

				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PRENF") ,  "D" ))
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"STATUS"),  "1" ))
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"OBS")   ,  cMensagem ))
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"MAIL")  ,  "0" ))
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"DTMAIL"),  ""  ))

			else

				If (xZBZ)->&(xZBZ_+"PRENF") == "Z" .and. cCodRet $ AllTrim(GetNewPar("XM_RETOK","526,731"))+",100"
	
					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PRENF") ,  "B" ))
					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"STATUS"),  "1" ))
					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"OBS")   ,  cMensagem ))
					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"MAIL")  ,  "0" ))
					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"DTMAIL"),  ""  ))
	
					cOri := "1"
	
					if FieldPos(xZBZ_+"IMPORT") > 0
	
						if !Empty( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"IMPORT"))) )
							cOri := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"IMPORT")))
						Endif
	
					Endif
	
					//(xZBZ)->(FieldPut(FieldPos(xZBZ_+"MANIF")  , U_HFMANZBS( AllTrim( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))) ), (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MANIF"))), cOri ) )) //GETESB2
	
					if (xZBZ)->(FieldPos(xZBZ_+"MANIF")) > 0   // .And. ! Empty(xManif) //GETESB2

						cRet := U_HFMANZBS( AllTrim( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))) ), (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MANIF"))), cOri )


						if !Empty( cRet )

							(xZBZ)->(FieldPut(FieldPos(xZBZ_+"MANIF"), cRet ))

						endif

					endif

				EndIf
				
			endif

			DbSelectArea(xZBZ)
			MsUnLock()
			DbSelectArea(cAliasZBZ)

			nOk++

			if cCodRet <> "100" .And. cCodRet <> "101"

				cMsg += "# ATUAL => PRENF "+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF")))+" => STATUS "+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"STATUS")))
				U_HfLogLin("[OK  ] "+cMsg,cDirLog,cArqLog,@nHdl)

			endif

		EndIf

	Else

		cMsg := cKey+"# .F. "

		If cCodRet == "101"

			lXmlCanc := .T.
			cOcorr   := cMensagem

			DbSelectArea(xZBZ)
			DbGoTo((cAliasZBZ)->R_E_C_N_O_)

			cMsg += "# ANT => PRENF "+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF")))+" => STATUS "+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"STATUS")))

			//Reclock(xZBZ,.F.)

			cOcorr += "Tipo de xml: " + cPref +CRLF
			cOcorr += "Chave      : " + cKey +CRLF
			cOcorr += "Observação : " + "Cancelamento do Xml de "+cPref+ " autorizado." +CRLF
			cOcorr += "Aviso      : " + "Cancele o documento de "+cPref+ " manualmente." +CRLF

			cOcorr:= U_GetInfoErro("3",cOcorr,(xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO"))))

			If (xZBZ)->&(xZBZ_+"PRENF") != "X"
				cLogProc += AllTrim(cKey)+" XML Cancelado. Cancele o documento de "+cPref+ " manualmente."+CRLF
				cMsg += " CANCELAR DOC ENTRADA "
			EndIf

			Reclock(xZBZ,.F.)
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PRENF")   , "X" ))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"STATUS")  , "2" ))

			if (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MAIL"))) <> "4"
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"MAIL")    , "3" ))
			endif

			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"DTMAIL")  , cOcorr ))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"DTHRCS")  , cDtHrCOns ))

			cOri := "1"

			Conout("Cancelamento realizado com sucesso " + cMensagem )

			if FieldPos(xZBZ_+"IMPORT") > 0

				if !Empty( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"IMPORT"))) )
					cOri := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"IMPORT")))
				Endif

			Endif

			//(xZBZ)->(FieldPut(FieldPos(xZBZ_+"MANIF")  , U_HFMANZBS( AllTrim( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))) ), (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MANIF"))), cOri ) )) //GETESB2
			
			if (xZBZ)->(FieldPos(xZBZ_+"MANIF")) > 0   // .And. ! Empty(xManif) //GETESB2

				cRet := U_HFMANZBS( AllTrim( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))) ), (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MANIF"))), cOri )

				if !Empty( cRet )

					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"MANIF"), cRet ))

				endif

			endif
			
			DbSelectArea(xZBZ)
			MsUnLock()
			nNo++
			DbSelectArea(cAliasZBZ)

			if cCodRet <> "100" .And. cCodRet <> "101"

				cMsg += "# ATUAL => PRENF "+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF")))+" => STATUS "+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"STATUS")))
				U_HfLogLin("[CANC] "+cMsg,cDirLog,cArqLog,@nHdl)

			endif

		Else

			DbSelectArea(xZBZ)
			DbGoTo((cAliasZBZ)->R_E_C_N_O_)

			cMsg += "# ANT => PRENF "+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF")))+"=> STATUS "+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"STATUS")))

			Reclock(xZBZ,.F.)

			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"DTHRCS"), cDtHrCOns ))
			
			if cCodRet $ AllTrim(GetNewPar("XM_RETDEN","301,302,303"))  // Denegado

				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PRENF") ,  "D" ))
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"STATUS"),  "1" ))
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"OBS")   ,  cMensagem ))
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"MAIL")  ,  "0" ))
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"DTMAIL"),  ""  ))

			else
			
				If (xZBZ)->&(xZBZ_+"PRENF") == "Z" .and. cCodRet $ AllTrim(GetNewPar("XM_RETOK","526,731"))+",100"
					
					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PRENF")  , "B" ))
					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"STATUS") , "1" ))
					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"OBS")    ,cMensagem ))
					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"MAIL")   , "0" ))
					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"DTMAIL") , "" ))
					
					cOri := "1"

					if FieldPos(xZBZ_+"IMPORT") > 0
		
						if !Empty( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"IMPORT"))) )
							cOri := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"IMPORT")))
						Endif
		
					Endif
		
					//(xZBZ)->(FieldPut(FieldPos(xZBZ_+"MANIF")  , U_HFMANZBS( AllTrim( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))) ), (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MANIF"))), cOri ) )) //GETESB2

					if (xZBZ)->(FieldPos(xZBZ_+"MANIF")) > 0   // .And. ! Empty(xManif) //GETESB2

						cRet := U_HFMANZBS( AllTrim( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))) ), (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MANIF"))), cOri )


						if !Empty( cRet )

							(xZBZ)->(FieldPut(FieldPos(xZBZ_+"MANIF"), cRet ))

						endif

					endif

				EndIf
				
			endif

			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"OBS"), (xZBZ)->&(xZBZ_+"OBS")+CRLF+cMensagem ))

			DbSelectArea(xZBZ)
			MsUnLock()

			DbSelectArea(cAliasZBZ)

			If cCodRet $ AllTrim(GetNewPar("XM_RETOK","526,731"))+",100"

				nOk++

			Else

				nNo++

			Endif

			if cCodRet <> "100" .And. cCodRet <> "101"

				cMsg += "# ATUAL => PRENF "+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF")))+"=> STATUS "+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"STATUS")))
				U_HfLogLin("[OK  ] "+cMsg,cDirLog,cArqLog,@nHdl)

			Endif

		EndIf

	EndIf

	if !lAuto
		IncProc("Processando "+(cAliasZBZ)->&(xZBZ_+"SERIE")+"/"+(cAliasZBZ)->&(xZBZ_+"NOTA"))
	endif

	(cAliasZBZ)->(DbSkip())

EndDo

cLogProc += StrZero(nOk,6)+" Pré-Nota(s) autorizada(s)."+CRLF
cLogProc += StrZero(nNo,6)+" Pré-Nota(s) não autorizada(s)."+CRLF

DbSelectArea(cAliasZBZ)
DbCloseArea()
RestArea(aArea)

U_HfLogLin("[FIM] Consultando Xml's.",cDirLog,cArqLog,@nHdl)

if .not. lAuto

	U_MyAviso("Aviso", cLogProc,{"OK"},3)

endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³XMLPRTdoc º Autor ³ HF                 º Data ³  01/01/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Direciona a impressao de documentos                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Importa Xml                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//FR - 31/03/2022 - Alteração realizada - criação variável lAutoDanfe
//Para indicar quando a chamada veio de rotina automática para gravar Danfe
//direto na pasta para depois anexar ao pedido de compra (KITCHENS)
//===========================================================================//
User Function XMLPRTdoc(lAutoDanf,xDirDanf,xArqDanfe)

	Local lOk        := .T.
	Local lAuto      := .F.
	Local cError     := ""
	Local cWarning   := ""
	Local cXml       := ""
	//Local cIdEnt := ""
	//Local aIndArq   := {}
	Local oDanfe
	//Local nHRes  := 0
	//Local nVRes  := 0
	//Local nDevice
	Local cFilePrint := "DANFE_"+cIdEnt+Dtos(MSDate())+StrTran(Time(),":","")
	Local oSetup
	Local aDevice  := {}
	Local cSession     := GetPrinterSession()	
	Local cDestFile    := GetSrvProfString("STARTPATH","")       		//FR - 01/12/2020  
		
	Local lAutoDanfe := .F.  			//FR - 31/03/2022 - PROJETO KITCHENS 
	Local cDirDanfe  := ""				//FR - 31/03/2022 - PROJETO KITCHENS
	Local xModelo    := "" 				//FR - 29/04/2022 - PROJETO KITCHENS		
	
	cDestFile += "pdf\"

	Makedir(cDestFile)
	
	If Valtype(lAutoDanf) <> "C"
		cFilePrint := xArqDanfe 
		lAutoDanfe := .T. 
		cDirDanfe  := xDirDanf
	Endif 

	Private oNota

	If (xZBZ)->(FieldPos(xZBZ_+"STATUS"))>0

		If (xZBZ)->(FieldGet(FieldPos(xZBZ_+"STATUS"))) <> "1" .Or. (xZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF"))) == "X"

			lOk:= .F.
			//MsgStop("Esta rotina não pode ser executada em um registro com erros na importação.")
			MsgStop("Esta NF foi Cancelada, Impressão Não Permitida.")
			//FR - 15/07/2022 - TÓPICOS PLANILHA RAFAEL "VALIDAÇÃO PATCH GERAL"
		EndIf

	EndIf

	//If ZBZ->ZBZ_MODELO == "57"
	//	MsgStop("Impressão de documento de CT-e não disponível.")
	//	lOk:= .F.
	//EndIf
	IF lOk

		cXml  := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML")))

		if upper("<resNFe ") $ upper( cXml )

			MsgStop("Esta rotina não pode ser executada em um registro de XML Resumido.")
			lOk := .F.

		endif

	Endif

	If lOk

		oNota := XmlParser( cXml, "_", @cError, @cWarning )

		if Empty( oNota )
		
			cXml := NoAcento((xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML"))))
			cXml := EncodeUTF8(cXml)

			//Faz backup do xml sem retirar os caracteres especiais
			cBkpXml := cXml

			//Executa rotina para retirar os caracteres especiais
			cXml := u_zCarEspec( cXml )

			oNota := XmlParser( cXml, "_", @cError, @cWarning )

			//retorna o backup do xml
			cXml := cBkpXml

		endif

		ce1 := ""
		cW1 := ""

		if oNota == NIL

			ce1 := cError
			cW1 := cWarning
			cXml  := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML")))
			cError := ""
			cWarning := ""

			cXml := NoAcento( cXml )
			cXml := EncodeUTF8( cXml )

			//Faz backup do xml sem retirar os caracteres especiais
			cBkpXml := cXml

			//Executa rotina para retirar os caracteres especiais
			cXml := u_zCarEspec( cXml )

			oNota := U_PARSGDE( cXml, @cError, @cWarning )

			//retorna o backup do xml
			cXml := cBkpXml

			if oNota == NIL

				alert( cError )
				Aviso("DANFE","Não foi possivel ler o XML, refaça a importação",{"OK"},3)
				Return NIL

			endif

		endif

		//If findfunction("U_DANFE_V")
		//	nRet := U_Danfe_v()
		//EndIf

		AADD(aDevice,"DISCO") // 1
		AADD(aDevice,"SPOOL") // 2
		AADD(aDevice,"EMAIL") // 3
		AADD(aDevice,"EXCEL") // 4
		AADD(aDevice,"HTML" ) // 5
		AADD(aDevice,"PDF"  ) // 6		

		nLocal       	:= If(GetProfString(cSession,"LOCAL","SERVER",.T.)=="SERVER",1,2 )
		nOrientation 	:= If(GetProfString(cSession,"ORIENTATION","PORTRAIT",.T.)=="PORTRAIT",1,2)
		cDevice     	:= GetProfString(cSession,"PRINTTYPE","SPOOL",.T.)
		nPrintType      := aScan(aDevice,{|x| x == cDevice })

		lAdjustToLegacy := .F. // Inibe legado de resolução com a TMSPrinter
		oDanfe := FWMSPrinter():New(cFilePrint, IMP_PDF, lAdjustToLegacy, cDestFile, .T.)     //cDestFile --> \system\pdf\
        //oDanfe:CPATHPDF
		// ----------------------------------------------
		// Cria e exibe tela de Setup Customizavel
		// OBS: Utilizar include "FWPrintSetup.ch"
		// ----------------------------------------------
		//nFlags := PD_ISTOTVSPRINTER+ PD_DISABLEORIENTATION + PD_DISABLEPAPERSIZE + PD_DISABLEPREVIEW + PD_DISABLEMARGIN
		nFlags := PD_ISTOTVSPRINTER + PD_DISABLEPAPERSIZE + PD_DISABLEPREVIEW + PD_DISABLEMARGIN

		If ( !oDanfe:lInJob )

			oSetup := FWPrintSetup():New(nFlags, "DANFE")
			// ----------------------------------------------
			// Define saida
			// ----------------------------------------------
			oSetup:SetPropert(PD_PRINTTYPE   , nPrintType)
			oSetup:SetPropert(PD_ORIENTATION , nOrientation)
			oSetup:SetPropert(PD_DESTINATION , nLocal)
			oSetup:SetPropert(PD_MARGIN      , {60,60,60,60})
			oSetup:SetPropert(PD_PAPERSIZE   , DMPAPER_A4)
			//		oSetup:AOPTIONS[6]:= "X:\spool\"

		EndIf

		
		//FR - 31/03/2022 - Impressão Danfe para anexar ao pedido compra - PROJETO KITCHENS FASE 2 - ANEXAR DANFE NO BANCO DE CONHECIMENTO
		lProssegue := .F.	
			
		// ----------------------------------------------
		// Pressionado botão OK na tela de Setup
		// ----------------------------------------------
		If oSetup:Activate() == PD_OK // PD_OK =1    //FR - 31/03/2022 - KITCHENS - tela setup deixei para mostrar somente quando a chamada não vier de fora, for direto da opção "Danfe/Dacte"		
			lProssegue := .T.
			If lAutoDanfe              				//FR - 12/07/2022
				oSetup:AOPTIONS[6]:= cDirDanfe
			Endif 
   		Endif    
       
             
        If lProssegue
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Salva os Parametros no Profile             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			WriteProfString( cSession, "LOCAL"      , If(oSetup:GetProperty(PD_DESTINATION)==1 ,"SERVER"    ,"CLIENT"    ), .T. )
			WriteProfString( cSession, "PRINTTYPE"  , If(oSetup:GetProperty(PD_PRINTTYPE)==1   ,"SPOOL"     ,"PDF"       ), .T. )
			WriteProfString( cSession, "ORIENTATION", If(oSetup:GetProperty(PD_ORIENTATION)==1 ,"PORTRAIT"  ,"LANDSCAPE" ), .T. )

			if oNota == NIL

				cError := ""
				cWarning := ""

				cXml := NoAcento((xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML"))))
				cXml := EncodeUTF8(cXml)

				//Faz backup do xml sem retirar os caracteres especiais
				cBkpXml := cXml

				//Executa rotina para retirar os caracteres especiais
				cXml := u_zCarEspec( cXml )

				oNota := XmlParser( cXml , "_", @cError, @cWarning ) 

				//retorna o backup do xml
				cXml := cBkpXml

				if oNota == NIL

					cXml  := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML")))
					cError := ""
					cWarning := ""
					
					cXml := NoAcento(cXml)
					cXml := EncodeUTF8(cXml)

					//Faz backup do xml sem retirar os caracteres especiais
					cBkpXml := cXml

					//Executa rotina para retirar os caracteres especiais
					cXml := u_zCarEspec( cXml )

					oNota := U_PARSGDE( cXml, @cError, @cWarning )

					//retorna o backup do xml
					cXml := cBkpXml

				endif

				//			Aviso("DANFE","A variavel já mudou",{"OK"},3)

			Endif

			If oSetup:GetProperty(PD_ORIENTATION) == 1

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Danfe Retrato DANFEII.PRW                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO"))) == "57"

					U_Dacte_X(lAuto,oNota,cIdEnt,,,oDanfe,oSetup,cFilePrint,lAutoDanfe)       //FR - 31/03/2022 - PROJETO KITCHENS 

				ElseIf (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO"))) == "55"

					if Empty((xZBZ)->(FieldGet(FieldPos(xZBZ_+"VERSAO")))) .or. (xZBZ)->(FieldGet(FieldPos(xZBZ_+"VERSAO"))) >= "4.00"
						U_Danfe_X4(lAuto,oNota,cIdEnt,,,oDanfe,oSetup,cFilePrint,lAutoDanfe)
					Else
						U_Danfe_X(lAuto,oNota,cIdEnt,,,oDanfe,oSetup,cFilePrint)
					Endif

				ElseIf (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO"))) $ "65"

					U_Danfce_X(lAuto,oNota,cIdEnt,,,oDanfe,oSetup,cFilePrint,lAutoDanfe,cDirDanfe)

				Else
	                xModelo := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO")))
					MsgInfo("LayOut Deste Modelo: " +  xModelo + " Não Homologado.")
					Return

				Endif

			Else

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Danfe Paisagem DANFEIII.PRW                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO"))) == "57"

					U_Dacte_X(lAuto,oNota,cIdEnt,,,oDanfe,oSetup,cFilePrint)

				ElseIf (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO"))) == "55"

					U_DANFE_XIII(lAuto,oNota,cIdEnt,,,oDanfe,oSetup,cFilePrint)
					//U_Danfe_X(lAuto,oNota,cIdEnt,,,oDanfe,oSetup,cFilePrint)

				ElseIf (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO"))) == "65"

					MsgInfo("LayOut Deste Modelo Apenas em Retrato.")
					Return

				Else

					MsgInfo("LayOut Deste Modelo Não Homologado.")
					Return

				EndIf

			EndIf

		Else

			MsgInfo("Relatório cancelado pelo usuário.")
			Return

		Endif		//If oSetup:Activate() == PD_OK		

		oDanfe := Nil
		oSetup := Nil 	

	EndIf

	Return

	******************************************************************
User Function RetTpNf(cModelo,oXml,lTransf,cFinalidad,cCfopDoc)
	******************************************************************

	Local cRet    := "N"
	Local Nx      := 0
	Local cCfopD  := GetNewPar("XM_CFDEVOL","") // "5916"
	Local cCfopB  := GetNewPar("XM_CFBENEF","")
	Local cCfopT  := SuperGetMv("XM_CFTRANSF",.T.,"5557;5552")//GetNewPar("XM_CFTRANSF","") // 1557
	Local cCfopC  := GetNewPar("XM_CFCOMPL","")
	Local lDevol  := .F.
	Local lBenef  := .F.
	Local lCompl  := .F. // Erick Gonça - 21/09/2022
	Local lNormal := .F.
	Local nLenProd:= 0

	Private oDet,cTagAux

	If cModelo $ "55,65"

		oDet     := oXml:_NFEPROC:_NFE:_INFNFE:_DET
		oDet     := IIf(ValType(oDet)=="O",{oDet},oDet)
		nLenProd := Len(oDet)

		For Nx := 1 To nLenProd

			cCfopIt := AllTrim(oDet[nx]:_Prod:_CFOP:TEXT)

			If Empty(cCfopDoc)

				cCfopDoc := cCfopIt

			ElseIf .NOT. (cCfopIt $ cCfopDoc)

				cCfopDoc += "/"+cCfopIt

			EndIf

			If cCfopIt $ cCfopD

				lDevol := .T.

			ElseIf cCfopIt $ cCfopB

				lBenef := .T.

			ElseIf cCfopIt $ cCfopT

				lTransf := .T.

			ElseIf cCfopIt $ cCfopC
				lCompl := .T.
			Else

				lNormal := .T.

			EndIf

		Next

		If lNormal .or. lTransf

			if cFinalidad = "2"  //Nota de Complemento (Adar)

				cRet := U_VERIPIICM(oXml)

			else

				cRet := "N"

			endif

		ElseIf lDevol

			cRet := "D"

		ElseIf lBenef

			cRet := "B"

		ElseIf lCompl
			cRet := "C"

		EndIf

	ElseIf cModelo=="57"

		//Tratamento para CT-e
		cRet    := "N"
		cTagAux := "oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_CFOP:TEXT"

		if type( cTagAux ) <> "U"
			cCfopDoc := AllTrim(oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_CFOP:TEXT)
		endif

	EndIf

	IF ExistBlock("HFXMLTP1")  //Colocado aqui abajo e incloi cRet 5/4/19.
		cRet := ExecBlock("HFXMLTP1",.F.,.F.,{cModelo,oXml,cRet})
	Endif

Return(cRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HFXML02V  º Autor ³ Roberto Souza      º Data ³  16/04/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Visualiza o Documento fiscal, caso haja.                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Importa XML                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//----------------------------------------------------------------------------//
//FR - 04/11/2021 - #11460 - ADAR - ao visualizar nf via ImportaXML, mostra
//                  uma outra nota de mesmo número e fornecedor, porém emissao
//                  diferente, e a chave estava em branco no F1_CHVNFE         
//                  correção para validar com a emissão do XML x NF
//---------------------------------------------------------------------------// 
User Function HFXML02V()
Local dEmiXML := Ctod("  /  /    ") 	//FR - 04/11/2021 - #11460 - ADAR

	//Local oDlgKey, oBtnOut, oBtnCon
	//Local cIdEnt    := ""
	Local cChaveXml := AllTrim( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))) )
	Local cModelo   := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO")))
	//Local cProtocolo:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"PROT")))
	//Local cMensagem := ""
	Local aArea     := GetArea()
	//Local lRet      := .T.
	Local cPref     := "NF-e"
	Local cTAG      := "NFE"
	Local lSeek     := .F.

	If cModelo == "55"

		cPref   := "NF-e"
		cTAG    := "NFE"

	ElseIf cModelo == "65"

		cPref   := "NFC-e"
		cTAG    := "NFE"

	ElseIf cModelo == "57"

		cPref   := "CT-e"
		cTAG    := "CTE"

	EndIf

	DbSelectArea("SF1")
	DbSetOrder(8)
	lSeek := DbSeek(xFilial("SF1")+cChaveXml)

	if !lSeek

		dEmiXML := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"DTNFE"))) 	//FR - 04/11/2021 - #11460 - ADAR
		DbSetOrder(1)
		lSeek := DbSeek( xFilial("SF1")+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA")))+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE")))+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR")))+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR")))  )
		//FR - 04/11/2021 - #11460 - ADAR
		If lSeek
			If Empty(SF1->F1_CHVNFE)  //se a chave estiver vazia, comparar com data emissão para validar se o seek é .T. 
				If dEmiXml <> SF1->F1_EMISSAO  //se a emissão for diferente, o seek é .F.
					lSeek := .F.
				Endif 
			Endif 
		Endif
		//FR - 04/11/2021 - #11460 - ADAR 				

	endif

	If lSeek

		nReg := SF1->(Recno())
		cCadastro:= "Visualizar Documento Entrada"
		//A103NFiscal("SF1",nReg,2,.F.,.F.)
		Mata103(, , 2 , )  //o A103NFiscal esta vindo vazio, então troquei a maneira de consultar, só q o SF1 tem q estar positionado. e, 29/06/18

	Else

		U_MyAviso("Atenção","Documento de Entrada não localizado.",{"OK"},2)

	EndIf

	RestArea(aArea)

	Return()

	********************************************************************
User Function XMLSETCS(cModelo,cChaveXml,cCodRet,cMensagem,xManif)
	********************************************************************

	//Local lRet := .T.
	Local cPref:= ""
	Local aArea := GetArea()

	Default xManif := ""

	If cModelo == "55"

		cPref   := "NF-e"
		cTAG    := "NFE"

	ElseIf cModelo == "57"

		cPref   := "CT-e"
		cTAG    := "CTE"

	EndIf

	DbSelectArea(xZBZ)
	DbSetOrder(3)   // Foi incluso Filial Alexandro p/ Aguas do Brasil - 13/07/2017
	If ( DbSeek(FWxFilial(xZBZ)+alltrim(cChaveXml)) .And. !(xZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF"))) $ "X|F" ) .OR.;
	(DbSeek(alltrim(cChaveXml)) .And. !(xZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF"))) $ "X|F" ) //Fadigando por causa dessa filial 27/01/18

		cDtHrCOns := HfPutdt(1,dDatabase, Time(),"")

		RecLock(xZBZ,.F.)

		If (xZBZ)->(FieldPos(xZBZ_+"DTHRUC")) > 0
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"DTHRUC"),cDtHrCOns))
		Else
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"DTHRCS"),cDtHrCOns))
		EndIf

		if FieldPos(xZBZ_+"MANIF") > 0   //  .And. .Not. Empty(xManif) //GETESB2

			cOri := "1"

			if FieldPos(xZBZ_+"IMPORT") > 0

				if !Empty( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"IMPORT"))) )

					cOri := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"IMPORT")))

				Endif

			Endif

			//(xZBZ)->(FieldPut(FieldPos(xZBZ_+"MANIF")  , U_HFMANZBS( AllTrim( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))) ), (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MANIF"))), cOri ) )) //GETESB2

			if (xZBZ)->(FieldPos(xZBZ_+"MANIF")) > 0   // .And. ! Empty(xManif) //GETESB2

				cRet := U_HFMANZBS( AllTrim( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))) ), (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MANIF"))), cOri )

				if !Empty( cRet )

					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"MANIF"), cRet ))

				endif

			endif

		endif

		If cCodRet == "101" // Cancelado

			cOcorr   := cMensagem
			cMsgCanc := "Tipo de xml: " + cPref +CRLF
			cMsgCanc += "Chave      : " + cChaveXml +CRLF
			cMsgCanc += "Observação : " + "Cancelamento do Xml de "+cPref+ " autorizado." +CRLF
			cMsgCanc += "Aviso      : " + "Cancele o documento de "+cPref+ " manualmente." +CRLF

			cStatusXml := "X"
			cStatReg   := "2"

			If (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MAIL"))) <> "4"   //se ja foi o e-mail não vai mais...

				cStatMail  := "3"

			Else

				cStatMail  := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MAIL")))

			EndIf

			cInfoErro  := U_GetInfoErro(cStatMail,cMsgCanc,cModelo)

		ElseIf cCodRet $ AllTrim(GetNewPar("XM_RETDEN","301,302,303"))  // Denegado

			cOcorr   := cMensagem

			cStatusXml := "D"
			cStatReg   := "1"
			cStatMail  := "0"
			cInfoErro  := ""		

		ElseIf cCodRet $ AllTrim(GetNewPar("XM_RETOK","526,731"))+",100"  // Autorizado

			If (xZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF"))) == "Z"

				cStatusXml := "B"
				cStatReg   := "1"
				cStatMail  := "0"
				cInfoErro  := ""

			Else

				cStatusXml := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF")))
				cStatReg   := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"STATUS")))
				cStatMail  := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MAIL")))
				cInfoErro  := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"DTMAIL")))

			EndIf

		Else

			lConsErr := .T.
			cOcorr   := cMensagem
			cMsgErr := "Tipo de xml: " + cPref +CRLF
			cMsgErr += "Chave      : " + cChaveXml +CRLF
			cMsgErr += "Observação : " + "Erro na consulta do Xml de "+cPref+ "." +CRLF
			cMsgErr += "Aviso      : " + "Consulte o Xml manualmente pela rotina padrão ou aguarde até a proxima consulta automática." +CRLF

			cStatusXml := "Z"
			cStatReg   := "2"
			cStatMail  := "0"
			cInfoErro  := cMsgErr

		EndIf

		(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PRENF") , cStatusXml))
		(xZBZ)->(FieldPut(FieldPos(xZBZ_+"STATUS"), cStatReg  ))
		(xZBZ)->(FieldPut(FieldPos(xZBZ_+"OBS")   , cMensagem ))
		(xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPDOWL"), ""        ))
		(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PROTC"),  ""        ))
		(xZBZ)->(FieldPut(FieldPos(xZBZ_+"MAIL")  , cStatMail ))
		(xZBZ)->(FieldPut(FieldPos(xZBZ_+"DTMAIL"), cInfoErro ))
		//(xZBZ)->(FieldPut(FieldPos(xZBZ_+"ORIGEM"), cOriNF	  ))

		DbSelectArea(xZBZ)
		(xZBZ)->(MsUnlock())

	EndIf

	RestArea( aArea )

	Return

	****************************************
/*Static Function ConsNFeChave(cChaveNFe)
	****************************************
	Local cMensagem:= ""
	Local oWS

	Default cURL    := AllTrim(GetNewPar("XM_URL",""))

	If Empty(cURL)
		cURL  := AllTrim(SuperGetMv("MV_SPEDURL"))
	EndIf

	lValidado := U_XConsXml(cURL,cChaveXml,cModelo,cProtocolo,@cMensagem,@cCodRet,AllTrim(SuperGetMv("MV_MOSTRAA")) == "S")

	oWs:= WsNFeSBra():New()
	oWs:cUserToken   := "TOTVS"
	oWs:cID_ENT      := cIdEnt
	ows:cCHVNFE		 := AllTrim(cChaveNFe)
	oWs:_URL         := AllTrim(cURL)+"/NFeSBRA.apw"

	If oWs:ConsultaChaveNFE()

		cMensagem := ""

		If !Empty(oWs:oWSCONSULTACHAVENFERESULT:cVERSAO)
			cMensagem += "Versão"+": "+oWs:oWSCONSULTACHAVENFERESULT:cVERSAO+CRLF
		EndIf

		cMensagem += "Ambiente"+": "+IIf(oWs:oWSCONSULTACHAVENFERESULT:nAMBIENTE==1,"Produção","Homologação")+CRLF //###
		cMensagem += "Cod Ret"+": "+oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE+CRLF
		cMensagem += "Mensagem"+": "+oWs:oWSCONSULTACHAVENFERESULT:cMSGRETNFE+CRLF

		If !Empty(oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO)
			cMensagem += "Protocolo"+": "+oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO+CRLF
		EndIf

		If !Empty(oWs:oWSCONSULTACHAVENFERESULT:cDIGVAL)
			cMensagem += "Dígito"+": "+oWs:oWSCONSULTACHAVENFERESULT:cDIGVAL+CRLF
		EndIf

		Aviso("Importa XMl",cMensagem,{"OK"},3)

	Else

		Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"OK"},3)

	EndIf

Return*/

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VldXmlOK  º Autor ³ Roberto Souza      º Data ³  11/10/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Coloca o XML em uma estrutura padrão para leitura.         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Importa Xml                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function VldXmlOK(nModo,cFile,cXml,cOcorr,lInvalid,cModelo,lCanc,oXml,lCCe)

	Local lRet   := .T.
	Local nAt1   := nAt2 := nAt3 := nAt4 := 0
	Local cNfe   := ""
	Local cProt  := ""
	//Local cInfo  := ""
	Local cError := ""
	Local cWarning := ""
	Local fr    := 0

	Private oParse := Nil

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processa verificação no modo clássico                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nModo== 1

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Identifica o modelo do XML                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If "<NFE" $ Upper(cXml) .Or. "<PROCCANCNFE" $ Upper(cXml)

			cModelo := "55"

		ElseIf "<CTE" $ Upper(cXml) .Or. "<PROCCANCCTE" $ Upper(cXml)

			cModelo := "57"

		Else

			cModelo := "00"
			lInvalid := .T.
			lRet := .F.
			cOcorr := "Modelo Inválido ou não homologado."

			Return(lRet)

		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica de acordo com o modelo                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cModelo == "55"

			If !"PROCCANCNFE" $ Upper(cXml)

				nAt1:= At('<NFE ',Upper(cXml))
				nAt2:= At('</NFE>',Upper(cXml)) + 6

				//Corpo da Nfe
				If nAt1 <=0
					nAt1:= At('<NFE>',Upper(cXml))
				EndIf

				If nAt1 > 0 .And. nAt2 > 6

					cNfe := Substr(cXml,nAt1,nAt2-nAt1)

				Else

					cOcorr := "Nf-e inconsistente."
					lret := .F.
					lInvalid := .T.

				EndIf

				nAt3:= At('<PROTNFE ',Upper(cXml))
				nAt4:= At('</PROTNFE>',Upper(cXml)) + 10

				//Protocolo
				If nAt3 > 0 .And. nAt4 > 10

					cProt := Substr(cXml,nAt3,nAt4-nAt3)

				Else

					lret := .F.
					lInvalid := .F.

				EndIf

				cXml:= '<?xml version="1.0" encoding="UTF-8"?>'
				cXml+= '<nfeProc versao="2.00" xmlns="http://www.portalfiscal.inf.br/nfe">'
				cXml+= cNfe
				cXml+= cProt
				cXml+= '</nfeProc>'

			ElseIf "PROCCANCNFE" $ Upper(cXml)

				nAt1:= At('<CANCNFE ',Upper(cXml))
				nAt2:= At('</CANCNFE>',Upper(cXml)) + 10

				//Corpo da Nfe
				If nAt1 <=0

					nAt1:= At('<CANCNFE>',Upper(cXml))

				EndIf

				If nAt1 > 0 .And. nAt2 > 10

					cNfe := Substr(cXml,nAt1,nAt2-nAt1)

				Else

					cOcorr := "Nf-e inconsistente."
					lret := .F.
					lInvalid := .T.

				EndIf

				nAt3:= At('<RETCANCNFE ',Upper(cXml))
				nAt4:= At('</RETCANCNFE>',Upper(cXml)) + 13

				//Protocolo
				If nAt3 > 0 .And. nAt4 > 13

					cProt := Substr(cXml,nAt3,nAt4-nAt3)

				Else

					lret := .F.
					lInvalid := .F.

				EndIf

				cXml:= '<?xml version="1.0" encoding="UTF-8"?>'
				cXml+= '<procCancNfe versao="2.00" xmlns="http://www.portalfiscal.inf.br/nfe">'
				cXml+= cNfe
				cXml+= cProt
				cXml+= '</procCancNfe>'

				lCanc := .T.

			EndIf

		ElseIf cModelo == "57"

			If !"PROCCANCCTE" $ Upper(cXml)

				nAt1:= At('<CTE ',Upper(cXml))
				nAt2:= At('</CTE>',Upper(cXml)) + 6

				//Corpo da Nfe
				If nAt1 <=0

					nAt1:= At('<CTE>',Upper(cXml))

				EndIf

				If nAt1 > 0 .And. nAt2 > 6

					cNfe := Substr(cXml,nAt1,nAt2-nAt1)

				Else

					cOcorr := "CT-e inconsistente."
					lret := .F.
					lInvalid := .T.

				EndIf

				nAt3:= At('<PROTCTE ',Upper(cXml))
				nAt4:= At('</PROTCTE>',Upper(cXml)) + 10

				//Protocolo
				If nAt3 > 0 .And. nAt4 > 10

					cProt := Substr(cXml,nAt3,nAt4-nAt3)

				Else

					lret := .F.
					lInvalid := .F.

				EndIf

				cXml:= '<?xml version="1.0" encoding="UTF-8"?>'
				cXml+= '<cteProc versao="1.03" xmlns="http://www.portalfiscal.inf.br/cte">'
				cXml+= cNfe
				cXml+= cProt
				cXml+= '</cteProc>'

			ElseiF "PROCCANCCTE" $ Upper(cXml)

				nAt1:= At('<CANCCTE ',Upper(cXml))
				nAt2:= At('</CANCCTE>',Upper(cXml)) + 10

				//Corpo da Nfe
				If nAt1 <=0

					nAt1:= At('<CANCCTE>',Upper(cXml))

				EndIf

				If nAt1 > 0 .And. nAt2 > 10

					cNfe := Substr(cXml,nAt1,nAt2-nAt1)

				Else

					cOcorr := "Nf-e inconsistente."
					lret := .F.
					lInvalid := .T.

				EndIf

				nAt3:= At('<RETCANCCTE ',Upper(cXml))
				nAt4:= At('</RETCANCCTE>',Upper(cXml)) + 13

				//Protocolo
				If nAt3 > 0 .And. nAt4 > 13

					cProt := Substr(cXml,nAt3,nAt4-nAt3)

				Else

					lret := .F.
					lInvalid := .F.

				EndIf

				cXml:= '<?xml version="1.0" encoding="UTF-8"?>'
				cXml+= '<procCancCTe versao="2.00" xmlns="http://www.portalfiscal.inf.br/cte">'
				cXml+= cNfe
				cXml+= cProt
				cXml+= '</procCancCTe>'

				lCanc := .T.

			EndIf

		EndIf

		cXml := EncodeUTF8(cXml)
		cXml := FwNoAccent(cXml)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica no modo novo com uso de parse                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf nModo == 2

		oParse := XmlParserFile( cFile, "_", @cError, @cWarning )

		if oParse == Nil

			//Executa rotina para retirar os caracteres especiais
			oParse := u_zCarEspec( cFile )

			oParse := XmlParserFile( cFile, "_", @cError, @cWarning )

		endif

		If Empty(cError) .And. Empty(cWarning) .And. !lInvalid .And. oParse <> Nil

			oXml :=  oParse

			If Type("oParse:_NFEPROC")<>"U" .And. Type("oParse:_NFEPROC:_NFE:_INFNFE:_VERSAO") <> "U" .And. oParse:_NFEPROC:_NFE:_INFNFE:_VERSAO:TEXT == "1.10"

				cModelo := "00"
				lInvalid := .T.
				lRet := .F.
				cOcorr := "Modelo 1.00 Inválido ou não homologado."

				Return(lRet)

			EndIf

			If Type("oParse:_NFEPROC")<>"U" .Or. Type("oParse:_PROCCANCNFE")<>"U"

				If Type("oParse:_NFEPROC:_NFE:_INFNFE:_IDE:_MOD:TEXT")<>"U"

					if oParse:_NFEPROC:_NFE:_INFNFE:_IDE:_MOD:TEXT == "65"
						cModelo := "65"
					Else
						cModelo := "55"
					Endif

				Else

					cModelo := "55"

				EndIF

			ElseIf Type("oParse:_CTEPROC")<>"U" .Or. Type("oParse:_PROCCANCCTE")<>"U"

				cModelo := "57"

			Elseif Type("oParse:_PROCEVENTONFE:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_CHNFE")<>"U"

				cTagAux := "oParse:_PROCEVENTONFE:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_CHNFE:TEXT"

				If Type(cTagAux)<>"U"   //se não tiver a versão provavelmente é Prestação de Serviço, é outro modelo.

					cChvAux := &(cTagAux)

					If Substr(cChvAux,21,2) == "65"
						cModelo := "65"
					ElseIf Substr(cChvAux,21,2) == "57"
						cModelo := "57"
					Else
						cModelo := "55"
					EndIf

				Else
					cModelo := "55"
				EndIf

			Elseif Type("oParse:_PROCEVENTONFE:_RETEVENTO:_INFEVENTO:_CHNFE")<>"U"

				cTagAux := "oParse:_PROCEVENTONFE:_RETEVENTO:_INFEVENTO:_CHNFE:TEXT"

				If Type(cTagAux)<>"U"   //se não tiver a versão provavelmente é Prestação de Serviço, é outro modelo.

					cChvAux := &(cTagAux)

					If Substr(cChvAux,21,2) == "65"
						cModelo := "65"
					ElseIf Substr(cChvAux,21,2) == "57"
						cModelo := "57"
					Else
						cModelo := "55"
					EndIf

				Else
					cModelo := "55"
				EndIf

			Elseif Type("oParse:_PROCEVENTOCTE:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_CHNFE")<>"U"

				cTagAux := "oParse:_PROCEVENTOCTE:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_CHNFE:TEXT"

				If Type(cTagAux)<>"U"

					cChvAux := &(cTagAux)

					If Substr(cChvAux,21,2) == "65"
						cModelo := "65"
					ElseIf Substr(cChvAux,21,2) == "55"
						cModelo := "55"
					Else
						cModelo := "57"
					EndIf

				Else

					cModelo := "57"

				EndIf

			Else

				cModelo := "00"
				lInvalid := .T.
				lRet := .F.
				cOcorr := "Modelo Inválido ou não homologado (NFeProc)."

				Return(lRet)

			EndIf

            //-------------------------------------------//
            //FR - 23/03/2021 - #10344 - Cimentos Itambé
            //-------------------------------------------//
			oObj   := Nil
			nConta  := 0
			lObjOK  := .F.
			oObjx   := Nil
			cNomeObj:= ""
			If cModelo $ "55,65"

				If Type("oParse:_PROCCANCNFE")=="U"

					//Protocolo
					If Type("oParse:_NFEPROC:_PROTNFE") <>"U"
						oObj  := oParse:_NFEPROC
						//------------------------------------------------------------------------------------------//
						//FR - 23/03/2021 - #10344 - Cimentos Itambé
						//Help de comandos: 						 		
						//1-coloco neste objeto a raiz dos nós, pra poder validar os "nós" existentes
						//  	oObj  := oParse:_NFEPROC
						//2-conta quantos nós tem dentro do objeto (cada nó é representado por [+] )
						//      nContObj := XmlChildCount(oObj)  
						//3-Obtém determinado nó pelo número após a vírgula, exemplo, de 1 até n qtos forem os nós
						//      oObj1 := XmlGetChild(oObj, 1)  
						//      oObj2 := XmlGetChild(oObj, 2)
						//      oObj3 := XmlGetChild(oObj, 3) 
						//      oObj4 := XmlGetChild(oObj, 4) 
						//      e assim por diante, no caso aqui, farei um "For/Next"
						//4-Após varrer todos os nós, validar se existe o nó "INFPROT" pela variável lObjOk
						//  desta forma, não ocorrerá error log na hora que "bater" no objeto e não encontrar a 
						//  propriedade INFPROT
						//  Esta sistemática pode ser aplicada em várias outras atribuições de objetos, 
						//  basta substituir pela propriedade a ser verificada.
						//------------------------------------------------------------------------------------------//
						nConta := XmlChildCount(oObj)  
						lObjOK := .F.
						
						For fr := 1 to nConta  
							oObjx := XmlGetChild(oObj, fr)    	//captura o objeto do nó posicionado
							cNomeObj:= oObjx:REALNAME 			//obtém o nome do objeto oObj1:REALNAME
							If UPPER(cNomeObj) == "INFPROT"         //verifica se existe algum nó com nome de objeto = INFPROT, se sim, valida a lObjOK
								lObjOK := .T.
							Endif
						Next
						
						If lObjOK
							cProt := oParse:_NFEPROC:_PROTNFE:_INFPROT:_NPROT:TEXT						
						Else //se não encontrar o nó "INFPROT" é carta de correção:
						
							If Type("oParse:_PROCEVENTONFE:_RETEVENTO:_INFEVENTO:_NPROT") <> "U"
								cProt := oParse:_PROCEVENTONFE:_RETEVENTO:_INFEVENTO:_NPROT:TEXT
								lCCe := .T.
							Endif
						Endif
						//-------------------------------------------//
			            //FR - 23/03/2021 - #10344 - Cimentos Itambé
			            //-------------------------------------------//

					Else

						if Type("oParse:_PROCEVENTONFE:_RETEVENTO:_INFEVENTO:_NPROT") <> "U"

							cProt := oParse:_PROCEVENTONFE:_RETEVENTO:_INFEVENTO:_NPROT:TEXT

							lCCe := .T.

						elseif Type("oParse:_PROCEVENTONFE:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_CHNFE") <> "U"

							cProt := oParse:_PROCEVENTONFE:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_NPROT:TEXT

							lCanc := .T.

						else

							lret := .F.
							lInvalid := .F.

						endif

					EndIf

				ElseIf Type("oParse:_PROCCANCNFE")<>"U"

					oRetId := &("oParse:_PROCCANC"+cTAG+":_CANC"+cTAG+":_INFCANC")
					oRetC  := &("oParse:_PROCCANC"+cTAG+":_RETCANC"+cTAG+":_INFCANC")

					cProt   := oRetId:_NPROT:TEXT
					cKey    := &("oRetId:_CH"+cTAG+":TEXT")
					cJust   := oRetId:_XJUST:TEXT

					cProtC  := oRetC:_NPROT:TEXT
					cDthRet := oRetC:_DHRECBTO:TEXT
					cRetStat:= oRetC:_CSTAT:TEXT
					cMotX   := oRetC:_XMOTIVO:TEXT

					If Type("oRetC:_NPROT")<>"U"

						cProt := oRetC:_NPROT:TEXT

					Else

						lret := .F.
						lInvalid := .F.

					EndIf

					lCanc := .T.

				Elseif Type("oParse:_PROCEVENTONFE:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_TPEVENTO") <> "U"

					lCCe := .T.

				EndIf

			ElseIf cModelo == "57"

				If !"PROCCANCCTE" $ Upper(cXml)

					nAt1:= At('<CTE ',Upper(cXml))
					nAt2:= At('</CTE>',Upper(cXml)) + 6

					//Corpo da Nfe
					If nAt1 <=0

						nAt1:= At('<CTE>',Upper(cXml))

					EndIf

					If nAt1 > 0 .And. nAt2 > 6

						cNfe := Substr(cXml,nAt1,nAt2-nAt1)

					Else

						cOcorr := "CT-e inconsistente."
						lret := .F.
						lInvalid := .T.

					EndIf

					nAt3:= At('<PROTCTE ',Upper(cXml))
					nAt4:= At('</PROTCTE>',Upper(cXml)) + 10

					//Protocolo
					If nAt3 > 0 .And. nAt4 > 10

						cProt := Substr(cXml,nAt3,nAt4-nAt3)

					Else

						lret := .F.
						lInvalid := .F.

					EndIf

					cXml:= '<?xml version="1.0" encoding="UTF-8"?>'
					cXml+= '<cteProc versao="1.03" xmlns="http://www.portalfiscal.inf.br/cte">'
					cXml+= cNfe
					cXml+= cProt
					cXml+= '</cteProc>'

				ElseiF "PROCCANCCTE" $ Upper(cXml)

					nAt1:= At('<CANCCTE ',Upper(cXml))
					nAt2:= At('</CANCCTE>',Upper(cXml)) + 10

					//Corpo da Nfe
					If nAt1 <=0

						nAt1:= At('<CANCCTE>',Upper(cXml))

					EndIf
					If nAt1 > 0 .And. nAt2 > 10

						cNfe := Substr(cXml,nAt1,nAt2-nAt1)

					Else

						cOcorr := "Nf-e inconsistente."
						lret := .F.
						lInvalid := .T.

					EndIf

					nAt3:= At('<RETCANCCTE ',Upper(cXml))
					nAt4:= At('</RETCANCCTE>',Upper(cXml)) + 13

					//Protocolo
					If nAt3 > 0 .And. nAt4 > 13

						cProt := Substr(cXml,nAt3,nAt4-nAt3)

					Else

						lret := .F.
						lInvalid := .F.

					EndIf

					cXml:= '<?xml version="1.0" encoding="UTF-8"?>'
					cXml+= '<procCancCTe versao="2.00" xmlns="http://www.portalfiscal.inf.br/cte">'
					cXml+= cNfe
					cXml+= cProt
					cXml+= '</procCancCTe>'

					lCanc := .T.

				Elseif Type("oParse:_PROCEVENTOCTE:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_TPEVENTO") <> "U"

					lCCe := .T.

				Else

					cModelo := "00"
					lInvalid := .T.
					lRet := .F.
					cOcorr := "Modelo Inválido ou não homologado (NFeProc)."

					Return(lRet)

				EndIf

			EndIf

			//		cXml := NoAcento(cXml)
			//		cXml := EncodeUTF8(cXml)

		Else

			cOcorr := "Xml inconsistente."+CRLF+cError+CRLF+cWarning
			lInvalid := .T.

		EndIf

	Else

		lInvalid := .T.

	EndIf

	Return(lRet)

	**********************************
/*Static Function GetFullTxt(cFile)
	**********************************
	Local cRet

	Private oParse
	Private cError  := ""
	Private cWarning:= ""

	oParse:=XmlParserFile(cFile,"_", @cError, @cWarning )

	cRet :=  MemoRead(cFile)

	Return(cRet)*/

	//Abre o arquivonHandle := FT_FUse("c:\garbage\test.txt")// Se houver erro de abertura abandona processamentoif nHandle = -1  returnendif// Posiciona na primeira linhaFT_FGoTop()// Retorna o número de linhas do arquivonLast := FT_FLastRec()MsgAlert( nLast )While !FT_FEOF()   cLine  := FT_FReadLn() // Retorna a linha corrente  nRecno := FT_FRecno()  // Retorna o recno da linha  MsgAlert( "Linha: " + cLine + " - Recno: " + StrZero(nRecno,3) )    // Pula para próxima linha  FT_FSKIP()End// Fecha o arquivoFT_FUSE()
	************************************
Static Function LerComFRead( cFile )
	************************************

	Local cRet := ""
	Local nHandle := 0
	Local cBuf := space(1200)
	//Local nPointer := 0
	//Local nLido := 0
	//Local nEof := 0
	//Local cEol := Chr( 13 ) + Chr( 10 )

	nHandle := FT_FUse( cFile )

	if nHandle = -1
		return( "" )
	endif

	FT_FGoTop()
	//nLast := FT_FLastRec()

	While !FT_FEOF()

		cBuf := FT_FReadLn() // Retorna a linha corrente
		cRet := cRet + cBuf

		FT_FSKIP()
	End

	FT_FUSE()

	Return cRet

	******************************************************
Static Function GravarComFRead(cFinalF,cFileToWrite) //28032016
	******************************************************

	Local nHandle := 0
	Local nTentai := 0
	Local lRet    := .T.
	nHandle := FCreate(cFinalF)

	If nHandle <= 0

		Return( .F. )

	Else

		do while FWrite(nHandle, cFileToWrite) <= 0

			nTentai++

			if nTentai > 3

				lRet := .F.
				Exit

			endif

		enddo

		FClose(nHandle)

	EndIf

	Return( lRet )

	**********************************
User Function RancaBarras( cFile )
	**********************************
	Local cRet := cFile

	cRet := StrTran(cRet,"\","")
	cRet := StrTran(cRet,"/","")

	Return( cRet )

	********************************
User Function TrocaAspas( cCod )
	********************************
	Local cRet := cCod

	cRet := StrTran(cRet,"'",'"')  //troca ' por " -> Isto serve para quando o código do produto vem com ', pois o SA5/SA7 é feito query a qual utiliza-se de '

	Return( cRet )

	***********************************************************************************
User Function ItNEnc( cTipoProc, aProdOk, aProdNo, aProdVl, nErrItens, aProdZr )
	***********************************************************************************

	Local lRetorno := .T.
	Private oFont01   := TFont():New("Arial",07,14,,.T.,,,,.T.,.F.)

	lRetorno := U_ItNaoEnc( cTipoProc, aProdOk, aProdNo, aProdVl, @nErrItens, aProdZr )

	Return( lRetorno )

	**************************************
Static Function ChkTagNfe( cFileCfg )
	**************************************

	Local nHandle := 0
	Local cTags   := ""

	If File(cFileCfg)
		Return( .T. )
	EndIf

	nHandle := FCreate(cFileCfg)

	If nHandle <= 0

		Return( .F. )

	Else

		cTags := U_HFXMLTAG()
		FWrite(nHandle, cTags)
		FClose(nHandle)

	EndIf

	Return( .T. )

	***********************
User Function HF02CPG()  //GETESB
	***********************

	Local cRet := ""
	Local nI   := 0
	Private oDup

	IF Type("oXml:_NFEPROC:_NFE:_INFNFE:_COBR:_FAT") <> "U"

		oDup := oXml:_NFEPROC:_NFE:_INFNFE:_COBR:_FAT
		oDup := IIf(ValType(oDup)=="O",{oDup},oDup)
		cRet += "FATURA" + CRLF

		For nI := 1 To Len(oDup)

			If Type( "oDup["+AllTrim(Str(nI))+"]:_nFat" ) <> "U"
				cRet += "FAT: " + oDup[nI]:_nFat:TEXT + " - "
			EndIf

			If Type( "oDup["+AllTrim(Str(nI))+"]:_vOrig" ) <> "U"
				cRet += "VR ORIG: "+oDup[nI]:_vOrig:TEXT + " - "
			EndIf

			If Type( "oDup["+AllTrim(Str(nI))+"]:_vDesc" ) <> "U"
				cRet += "DESC: "+oDup[nI]:_vDesc:TEXT + ""
			EndIf

			If Type( "oDup["+AllTrim(Str(nI))+"]:_vLiq" ) <> "U"
				cRet += "VR LIQ: "+oDup[nI]:_vLiq:TEXT + ""
			EndIf

			cRet += CRLF

		Next nI

		cRet += CRLF

	EndIf

	IF Type("oXml:_NFEPROC:_NFE:_INFNFE:_COBR:_DUP") <> "U"

		oDup := oXml:_NFEPROC:_NFE:_INFNFE:_COBR:_DUP
		oDup := IIf(ValType(oDup)=="O",{oDup},oDup)
		cRet += "DUPLICATAS" + CRLF

		For nI := 1 To Len(oDup)

			If Type( "oDup["+AllTrim(Str(nI))+"]:_nDup" ) <> "U"
				cRet += "DUP: " + oDup[nI]:_nDup:TEXT + " - "
			EndIf

			If Type( "oDup["+AllTrim(Str(nI))+"]:_dVenc" ) <> "U"
				cRet += "VENC: "+oDup[nI]:_dVenc:TEXT + " - "
			EndIf

			If Type( "oDup["+AllTrim(Str(nI))+"]:_vDup" ) <> "U"
				cRet += "VR: "+oDup[nI]:_vDup:TEXT + ""
			EndIf

			cRet += CRLF

		Next nI

	ElseIF Type("oXml:_NFEPROC:_NFE:_INFNFE:_PAG:_DETPAG") <> "U"

		aTpg := {}

		aadd(aTpg, {"01","Dinheiro"})
		aadd(aTpg, {"02","Cheque"})
		aadd(aTpg, {"03","Cartão de Crédito"})
		aadd(aTpg, {"04","Cartão de Débito"})
		aadd(aTpg, {"05","Crédito Loja"})
		aadd(aTpg, {"10","Vale Alimentação"})
		aadd(aTpg, {"11","Vale Refeição"})
		aadd(aTpg, {"12","Vale Presente"})
		aadd(aTpg, {"13","Vale Combustível"})
		aadd(aTpg, {"14","Duplicata Mercantil"})
		aadd(aTpg, {"99","Outros"})

		oDup := oXml:_NFEPROC:_NFE:_INFNFE:_PAG:_DETPAG
		oDup := IIf(ValType(oDup)=="O",{oDup},oDup)
		cRet += "INFORMAÇOES DE PGTO:" + CRLF

		For nI := 1 To Len(oDup)

			If Type( "oDup["+AllTrim(Str(nI))+"]:_tPag" ) <> "U"

				nTpg := aScan( aTpg, {|x| x[1] == oDup[nI]:_tPag:TEXT } )
				cRet += "FORMA: " + oDup[nI]:_tPag:TEXT + "-" + iif(nTpg>0,aTpg[nTpg][2],"N/A") + " - "

			EndIf

			If Type( "oDup["+AllTrim(Str(nI))+"]:_vPag" ) <> "U"

				cRet += "VR: "+oDup[nI]:_vPag:TEXT + ""

			EndIf

			cRet += CRLF

		Next nI

	EndIf

	Return cRet


Static Function RetUFide( cUF )

Local cRet := ""
Local aUF  := {}
Local nPos := 0
Default cUF := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Preenchimento do Array de UF                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aadd(aUF,{"RO","11"})
aadd(aUF,{"AC","12"})
aadd(aUF,{"AM","13"})
aadd(aUF,{"RR","14"})
aadd(aUF,{"PA","15"})
aadd(aUF,{"AP","16"})
aadd(aUF,{"TO","17"})
aadd(aUF,{"MA","21"})
aadd(aUF,{"PI","22"})
aadd(aUF,{"CE","23"})
aadd(aUF,{"RN","24"})
aadd(aUF,{"PB","25"})
aadd(aUF,{"PE","26"})
aadd(aUF,{"AL","27"})
aadd(aUF,{"MG","31"})
aadd(aUF,{"ES","32"})
aadd(aUF,{"RJ","33"})
aadd(aUF,{"SP","35"})
aadd(aUF,{"PR","41"})
aadd(aUF,{"SC","42"})
aadd(aUF,{"RS","43"})
aadd(aUF,{"MS","50"})
aadd(aUF,{"MT","51"})
aadd(aUF,{"GO","52"})
aadd(aUF,{"DF","53"})
aadd(aUF,{"SE","28"})
aadd(aUF,{"BA","29"})
aadd(aUF,{"EX","99"})

if !Empty( cUF )

	//cRet := aUF[aScan(aUF,{|x| x[2] == cUF })][01]	//FR - 22/12/2020
	
	//FR - 22/12/2020
	nPos := aScan( aUF, {|x| AllTrim(x[2]) == cUF } )  //aqui tenta localizar o código numérico da UF, exemplo: PR é 41, BA é 29...cfe array acima
	
	If nPos > 0
		
		cRet := aUF[nPos][01]
	Else  //se não encontrou, para modelos 65, a UF vem em sigla (Ex.: SP) e não em numérico (35)
		nPos := aScan( aUF, {|x| AllTrim(x[1]) == cUF } )
		If nPos > 0
			cRet := aUF[nPos][01]		//FR - 22/12/2020
		Else
			cRet := "" //para evitar o error log
		Endif
	Endif
	//FR - 22/12/2020

endif

Return( cRet )

	**********************************
Static Function __Dummy(lRecursa) //warning W0010 Static Function <?> never called
	**********************************
	lRecursa := .F.

	IF (lRecursa)

		__Dummy(.F.)

		U_UPSTATXML()
		U_HF02CPG()
		U_HFXML02E()
		U_HFBOTFUN()
		U_COMP0012()
		U_HFXML02()
		U_HFXML02V()
		U_HFXML02L()
		U_HFTOPFUN()
		U_XMLPRTDOC()
		U_XGETFILS()
		U_UPFORXML()
		U_ITNENC()
		U_UPCONSXML()

	EndIF

Return(lRecursa)


**************************************************
User Function FRDTHora(nTipo,dData, cTime, cData)
**************************************************
Local xRet := Nil

If nTipo == 1

	xRet := dTos(dData)
	XRet := Substr(xRet,1,4)+"-"+Substr(xRet,5,2)+"-"+Substr(xRet,7,2)+"T"+cTime
	
EndIf

Return(xRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} u_HFLenStr
Função de exemplo do funcionamento do MemoRead e Len em comparação
a leitura do arquivo, byte a byte

@author Rogério Lino
@since 21/07/2020
@version 1.0
/*/
//-------------------------------------------------------------------
User Function HFLenStr(cFile)

Local cData   := ""
Local nLength := 0
Local nHandle := 0

//cData := MemoRead(cPDF)

nHandle := FOpen(cFile)
nLength := FSeek(nHandle, 0, FS_END)

FClose(nHandle)

//Veja que a diferença pode ser bem grande, o teste foi feito com um PDF de cerca de 580Kb
//ConOut("Tamanho lento a string: " + cValToChar(Len(cData)))
//ConOut("Tamanho lento o arquivo: " + cValToChar(nLength))

Return(nLength)
//==================================================================================//
//Função  : HFXML02BC  
//Autoria : Flávia Rocha
//Data    : 19/11/2021
//Objetivo: Bandeirantes Agro - adição de função que traz o banco de conhecimento da nf
//==================================================================================//
User Function HFXML02BC()
	
	Local cChaveXml := AllTrim( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))) )
	Local cModelo   := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO")))	
	Local aArea     := GetArea()
	
	Local cPref     := "NF-e"
	Local cTAG      := "NFE"
	Local lSeek     := .F.
	Local nReg      := 0
	Local nOpc      := 0
	Local nOper     := 0
	Local lExcelConnect
	Local xPC		:= ""
	Local xFili		:= ""
	Local lAchou	:= .F.
	//Local nReg      := 0 
	Local nRegSA2   := 0
	Local cCodFor   := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR")))	
	Local cLojFor   := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR")))	

	nReg := (xZBZ)->(Recno())

	//Pega o Recno da SA2, do fornecedor do XML:  
	//para o caso de se não encontrar SF1, nem SC7, abre banco conhecimento associado ao cad. do fornecedor
	SA2->(OrdSetFocus(1))
	If SA2->(Dbseek(xFilial("SA2") + cCodFor + cLojFor))
		nRegSA2 := SA2->(Recno())
	Endif 

	If cModelo == "55"

		cPref   := "NF-e"
		cTAG    := "NFE"

	ElseIf cModelo == "65"

		cPref   := "NFC-e"
		cTAG    := "NFE"

	ElseIf cModelo == "57"

		cPref   := "CT-e"
		cTAG    := "CTE"

	EndIf

	DbSelectArea("SF1")
	DbSetOrder(8)
	lSeek := DbSeek(xFilial("SF1")+cChaveXml)

	if !lSeek

		DbSetOrder(1)
		lSeek := DbSeek( xFilial("SF1")+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA")))+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE")))+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR")))+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR")))  )

	endif

	If lSeek

		nReg := SF1->(Recno())
		nOpc := 4
		nOper:= 4
		lExcelConnect := .T.
		cCadastro:= "Banco de Conhecimento - Documento Entrada"
		//aadd(aButtons,{'Conhecimento', {||MsDocument("SF1", SF1->( Recno() ), 1)},'Banco de Conhecimento'})
		//MsDocument("SF1", SF1->( Recno() ), 1)  //opção 1 deixa apenas visual
		MsDocument("SF1", SF1->( Recno() ), 2)  //precisa ser opção 2 para deixar inserir documento
		//LUCAS SAN -> 21/10/2022 -> Adequação para passar dois parâmetros ao MPDOCUMENT.
	//Else
		//U_MyAviso("Atenção","Documento de Entrada não localizado.",{"OK"},2) 
	Endif 
	
	If !lSeek
		//FR - 16/08/2022 - TÓPICOS RAFAEL DE VALIDAÇÃO DA PATCH GERAL - TÓPICO 31 - TRATATIVA DO BANCO DE CONHECIMENTO
		//PROCURA POR PEDIDO COMPRA CASO HAJA GRAVADO NO CAMPO ZBT_PEDIDO:
		(xZBT)->(OrdSetFocus(2))  //ZBT_CHAVE
		If (xZBT)->(Dbseek(cChaveXml)) 
			While (xZBT)->(!Eof()) .and. Alltrim((xZBT)->(FieldGet(FieldPos(xZBT_+"CHAVE")))) == Alltrim(cChaveXml)
			    
				If !lAchou
					//Pega o pedido gravado na ZBT e teta localizar na SC7
					xFili 	:= (xZBT)->(FieldGet(FieldPos(xZBT_+"FILIAL")))								
					xPC 	:= (xZBT)->(FieldGet(FieldPos(xZBT_+"PEDIDO")))	 
					
					SC7->(OrdSetFocus(1))
					If SC7->(Dbseek(xFili + Alltrim(xPC) ))
						lAchou := .T.
						nReg := SC7->(RECNO())
					Endif 
				Endif											
				(xZBT)->(Dbskip())
	
			Enddo
			
			If lAchou 
				lSeek := .T.
				
				cCadastro:= "Banco de Conhecimento - Pedido de Compra"
				MsDocument("SC7", nReg, 2)  //precisa ser opção 4 para deixar inserir documento 				
				//LUCAS SAN -> 21/10/2022 -> Adequação para passar dois parâmetros ao MPDOCUMENT.
			Endif 

		Endif 

	EndIf


	//PELA ZBZ não consegue porque não é tabela padrão
	
	If !lSeek
		Alert("O XML Não Possui Banco de Conhecimento: Nem de Nota Fiscal e nem Pedido de Compras")
		/*
		//Verifica se já tem a entidade ZBZ na AC9
		DbSelectArea("AC9")
		AC9->(OrdSetFocus(2))		//AC9_FILIAL+AC9_ENTIDA+AC9_FILENT+AC9_CODENT+AC9_CODOBJ 
		cCodent := 	cFilant + cChaveXml

		If !AC9->(Dbseek(xFilial("AC9") + xZBZ ))
			RecLock("AC9" , .T.)			
	
			AC9->AC9_FILIAL := xFilial("AC9")
			AC9->AC9_FILENT := cFilAnt
			AC9->AC9_ENTIDA := xZBZ
			AC9->AC9_CODENT := cCodent
			//AC9->AC9_CODOBJ := cProxObj
	
			AC9->(MsUnlock())

		Endif  

		U_FCADSX9()       //aqui cadastra relacionamento só ZBZ com ZBT
		U_FCADSX9("SF1")  //aqui cadastra relacionamento ZBZ com SF1
		U_FCADSX9("SA2")  //aqui cadastra relacionamento ZBZ com SA2	
		
		
		//SE NÃO ENCONTRAR POR PEDIDO DE COMPRA, FAZ POR XML (ZBZ) 
		cCadastro:= "Banco de Conhecimento - XML"		
		//aAdd(aRotina, {"Conhecimento", "MsDocument('"+ xZBZ + "', "+ xZBZ + "->(RecNo()), 4)", 0, 4, 0, Nil})
		MsDocument( xZBZ, nReg, 4)  //precisa ser opção 4 para deixar inserir documento 							
		//MsDocument( "SA2", nRegSA2, 4)  //precisa ser opção 4 para deixar inserir documento
		*/
	Endif

	RestArea(aArea)

Return()


//-----------------------------------------------//
//ATUALIZA ZBZ_MANIF COM ULTIMA MANIFESTAÇÃO
//Função: FATUMANIF
//Autoria: Flávia Rocha - 24/05/2022
//----------------------------------------------//
User Function FATUMANIF()
Local cQuery  := ""
Local _cAlias := ""
Local xManif  := ""
Local aEventos:= {}
Local xEventos:= {}  

Local cDB 			:= TcGetDB()  //FR - 05/10/2021 - captura o banco de dados que está conectado

Private cAtuManif   := GetNewPar("XM_ATUMANF" , "N")

_cAlias := GetNextAlias() 

If Alltrim(cAtuManif) <> "S"
	Alert("O Parâmetro XM_ATUMANF Está Desabilitado, " + CRLF + "Para Utilizar a Rotina, Defina como 'S' ")
	Return
Endif 


//0=Não;1=Conf. Op.;2=Desc.Op;3=Não Realizada;4=Ciencia Op.;5=Cancelada;6=Desacordo  
/*
110110=Carta Correção;  --> 0 
110111=Cancelada;		--> 5      
210200=Conf.Oper.;  	--> 1
210210=Ciência Op.; 	--> 4
210220=Descon.Op;   	--> 2
210240=Oper.N.Real.; 	--> 3
610110=Desacord 		--> 6  
*/   

//códigos de eventos
Aadd( aEventos , "110110" )   //0-carta correção
Aadd( aEventos , "210200" )   //1
Aadd( aEventos , "210220" )   //2
Aadd( aEventos , "210240" )   //3
Aadd( aEventos , "210210" )   //4
Aadd( aEventos , "110111" )   //5
Aadd( aEventos , "610110" )   //6

//codificação que grava no campo zbz_manif
Aadd( xEventos , "0"      )   //"110110" - CARTA CORREÇÃO                                                        
Aadd( xEventos , "1"      )   //"210200" - CONFIRMAÇÃO OPERAÇÃO                                                      
Aadd( xEventos , "2"      )   //"210220" - DESCONHECIMENTO OPERAÇÃO                                                       
Aadd( xEventos , "3"      )   //"210240" - OPERAÇÃO NÃO REALIZADA                                                        
Aadd( xEventos , "4"      )   //"210210" - CIÊNCIA DA OPERAÇÃO                                                       
Aadd( xEventos , "5"      )   //"110111" - CANCELADA
Aadd( xEventos , "6"      )   //"610110" - DESACORDO

//0=Carta Correção;1=Conf. Op.;2=Desc.Op;3=Op.Não Realizada;4=Ciencia Op.;5=Cancelada;6=Desacordo                                 
If Alltrim(cDB) <> 'ORACLE'                                                                                                                 

	cQuery := " SELECT DISTINCT " + CRLF
	cQuery += " ZBZ."        + xZBZ+ "_CHAVE , "+CRLF
	cQuery += " ZBZ."        + xZBZ+ "_NOTA,  "+CRLF
	cQuery += " ZBZ."        + xZBZ+ "_SERIE,  "+CRLF
	cQuery += " ZBZ."        + xZBZ+ "_MANIF ZBZMANIF,  "+CRLF	
	cQuery += " ZBZ.R_E_C_N_O_ AS RECZBZ "  +CRLF
	
	cQuery += " ,( Select TOP 1 ZBE." + xZBE+"_TPEVE FROM " + RetSqlName(xZBE) + " ZBE  "+CRLF
	cQuery += " INNER JOIN " + RetSqlName(xZBZ) + " ZBZ1 ON RTRIM(ZBZ."+ xZBZ + "_CHAVE) = RTRIM(ZBE."+ xZBE+"_CHAVE) AND ZBZ1.D_E_L_E_T_ = '' "+CRLF
	cQuery += " WHERE ZBE." + xZBE + "_TPEVE <> 'HXL069' AND ZBE.D_E_L_E_T_ ='' "+CRLF	
	//cQuery += " ORDER BY ZBE." + xZBE+"_DTRECB DESC) EVEMANIF "+CRLF + CRLF
	cQuery += " ORDER BY ZBE.R_E_C_N_O_ DESC) EVEMANIF "+CRLF + CRLF  //FR - 17/08/2022 - ALTERADO ORDER BY PARA RECNO, CHAMADO TELETEX
	
	/*
	cQuery += " ( Select TOP 1 " + xZBE+"_DESC FROM " + RetSqlName(xZBE) + " ZBE  "+CRLF
	cQuery += " INNER JOIN " + RetSqlName(xZBZ) + " ZBZ1 ON RTRIM(ZBZ."+ xZBZ+ "_CHAVE) = RTRIM(ZBE."+ xZBE+"_CHAVE AND ZBZ.D_E_L_E_T_ = '' "+CRLF
	cQuery += " WHERE " +xZBE + "_TPEVE <> 'HXL069' "+CRLF
	cQuery += " AND ZBE.D_E_L_E_T_ ='' "+CRLF	
	cQuery += " ORDER BY " + xZBE+"_DTRECB DESC) DESCMANIF "+CRLF + CRLF
	*/
	
	cQuery += " , CASE WHEN ( Select TOP 1 ZBE1." + xZBE+"_TPEVE FROM " + RetSqlName("ZBE") + "  ZBE1 "+CRLF  
	cQuery += "  INNER JOIN " + RetSqlname("ZBZ") + " ZBZ2 ON RTRIM(ZBZ." + xZBZ+ "_CHAVE) = RTRIM(ZBE1." + xZBE+"_CHAVE) AND ZBZ2.D_E_L_E_T_ = '' "+CRLF
	cQuery += "  WHERE ZBE1." + xZBE+ "_TPEVE <> 'HXL069' AND ZBE1.D_E_L_E_T_ ='' "+CRLF	
	//cQuery += " ORDER BY ZBE1." + xZBE+"_DTRECB DESC) = '110110' THEN '0' "+CRLF + CRLF
	cQuery += " ORDER BY ZBE1.R_E_C_N_O_ DESC) = '110110' THEN '0' "+CRLF + CRLF  		//FR - 17/08/2022 - ALTERADO ORDER BY PARA RECNO, CHAMADO TELETEX
	
	cQuery += " ELSE " + CRLF + CRLF
	
	cQuery += " CASE WHEN ( Select TOP 1 ZBE2." + xZBE+ "_TPEVE FROM " + RetSqlName("ZBE") + " ZBE2 "+CRLF  
	cQuery += "  INNER JOIN " + RetSqlname("ZBZ") + " ZBZ3 ON RTRIM(ZBZ." + xZBZ+ "_CHAVE) = RTRIM(ZBE2." + xZBE+"_CHAVE) AND ZBZ3.D_E_L_E_T_ = '' "+CRLF
	cQuery += "  WHERE ZBE2." + xZBE+ "_TPEVE <> 'HXL069' AND ZBE2.D_E_L_E_T_ ='' "+CRLF	
	//cQuery += " ORDER BY ZBE2." + xZBE+"_DTRECB DESC) = '210200' THEN '1' "+CRLF + CRLF  
	cQuery += " ORDER BY ZBE2.R_E_C_N_O_ DESC) = '210200' THEN '1' "+CRLF + CRLF  		//FR - 17/08/2022 - ALTERADO ORDER BY PARA RECNO, CHAMADO TELETEX
	
	cQuery += " ELSE " + CRLF + CRLF
	
	cQuery += " CASE WHEN ( Select TOP 1 ZBE3." + xZBE+ "_TPEVE FROM " + RetSqlName("ZBE") + " ZBE3 "+CRLF  
	cQuery += "  INNER JOIN " + RetSqlname("ZBZ") + " ZBZ4 ON RTRIM(ZBZ." + xZBZ+ "_CHAVE) = RTRIM(ZBE3." + xZBE+"_CHAVE) AND ZBZ4.D_E_L_E_T_ = '' "+CRLF
	cQuery += "  WHERE ZBE3." + xZBE+ "_TPEVE <> 'HXL069' AND ZBE3.D_E_L_E_T_ ='' "+CRLF	
	//cQuery += " ORDER BY ZBE3." + xZBE+"_DTRECB DESC) = '210220' THEN '2' "+CRLF + CRLF
	cQuery += " ORDER BY ZBE3.R_E_C_N_O_ DESC) = '210220' THEN '2' "+CRLF + CRLF			//FR - 17/08/2022 - ALTERADO ORDER BY PARA RECNO, CHAMADO TELETEX
	
	cQuery += " ELSE " + CRLF + CRLF
	
	cQuery += " CASE WHEN ( Select TOP 1 ZBE4." + xZBE + "_TPEVE FROM " + RetSqlName("ZBE") + " ZBE4 "+CRLF  
	cQuery += "  INNER JOIN " + RetSqlname("ZBZ") + " ZBZ5 ON RTRIM(ZBZ." + xZBZ+ "_CHAVE) = RTRIM(ZBE4." + xZBE+"_CHAVE) AND ZBZ5.D_E_L_E_T_ = '' "+CRLF
	cQuery += "  WHERE ZBE4." + xZBE+ "_TPEVE <> 'HXL069' AND ZBE4.D_E_L_E_T_ ='' "+CRLF	
	//cQuery += " ORDER BY ZBE4." + xZBE+"_DTRECB DESC) = '210240' THEN '3' "+CRLF + CRLF 
	cQuery += " ORDER BY ZBE4.R_E_C_N_O_ DESC) = '210240' THEN '3' "+CRLF + CRLF 			//FR - 17/08/2022 - ALTERADO ORDER BY PARA RECNO, CHAMADO TELETEX
	
	cQuery += " ELSE " + CRLF + CRLF
	
	cQuery += " CASE WHEN ( Select TOP 1 ZBE5." + xZBE+ "_TPEVE FROM " + RetSqlName("ZBE") + " ZBE5 "+CRLF  
	cQuery += "  INNER JOIN " + RetSqlname("ZBZ") + " ZBZ6 ON RTRIM(ZBZ." + xZBZ+ "_CHAVE) = RTRIM(ZBE5." + xZBE+"_CHAVE) AND ZBZ6.D_E_L_E_T_ = '' "+CRLF
	cQuery += "  WHERE ZBE5." + xZBE+ "_TPEVE <> 'HXL069' AND ZBE5.D_E_L_E_T_ ='' "+CRLF	
	//cQuery += " ORDER BY ZBE5." + xZBE+"_DTRECB DESC) = '210210' THEN '4' "+CRLF + CRLF
	cQuery += " ORDER BY ZBE5.R_E_C_N_O_ DESC) = '210210' THEN '4' "+CRLF + CRLF			//FR - 17/08/2022 - ALTERADO ORDER BY PARA RECNO, CHAMADO TELETEX
	
	cQuery += " ELSE " + CRLF + CRLF
	
	cQuery += " CASE WHEN ( Select TOP 1 ZBE6." + xZBE+ "_TPEVE FROM " + RetSqlName("ZBE") + " ZBE6 "+CRLF  
	cQuery += "  INNER JOIN " + RetSqlname("ZBZ") + " ZBZ7 ON RTRIM(ZBZ." + xZBZ+ "_CHAVE) = RTRIM(ZBE6." + xZBE+"_CHAVE) AND ZBZ7.D_E_L_E_T_ = '' "+CRLF
	cQuery += "  WHERE ZBE6." + xZBE+ "_TPEVE <> 'HXL069' AND ZBE6.D_E_L_E_T_ ='' "+CRLF	
	//cQuery += " ORDER BY ZBE6." + xZBE+"_DTRECB DESC) = '110111' THEN '5' "+CRLF + CRLF
	cQuery += " ORDER BY ZBE6.R_E_C_N_O_ DESC) = '110111' THEN '5' "+CRLF + CRLF			//FR - 17/08/2022 - ALTERADO ORDER BY PARA RECNO, CHAMADO TELETEX
	
	cQuery += " ELSE " + CRLF + CRLF
	
	cQuery += " CASE WHEN ( Select TOP 1 ZBE7." + xZBE+ "_TPEVE FROM " + RetSqlName("ZBE") + " ZBE7 "+CRLF  
	cQuery += "  INNER JOIN " + RetSqlname("ZBZ") + " ZBZ8 ON RTRIM(ZBZ." + xZBZ+ "_CHAVE) = RTRIM(ZBE7." + xZBE+"_CHAVE) AND ZBZ8.D_E_L_E_T_ = '' "+CRLF
	cQuery += "  WHERE ZBE7." + xZBE+ "_TPEVE <> 'HXL069' AND ZBE7.D_E_L_E_T_ ='' "+CRLF	
	//cQuery += " ORDER BY ZBE7." + xZBE+"_DTRECB DESC) = '610110' THEN '6' "+CRLF + CRLF
	cQuery += " ORDER BY ZBE7.R_E_C_N_O_ DESC) = '610110' THEN '6' "+CRLF + CRLF		//FR - 17/08/2022 - ALTERADO ORDER BY PARA RECNO, CHAMADO TELETEX
	
	cQuery += " END END END END END END END AS PROJMANIF "+CRLF + CRLF
	
	cQuery += " FROM " + RetSqlName(xZBZ) + " ZBZ "+CRLF
	//cQuery += " INNER JOIN " + RetSqlName(xZBE) + " ZBEX ON RTRIM(ZBEX." + xZBE+"_CHAVE) = RTRIM(ZBZ." + xZBZ+"_CHAVE) AND ZBEX.D_E_L_E_T_ = '' "+CRLF
	cQuery += " WHERE ZBZ.D_E_L_E_T_ = '' "+CRLF
	//cQuery += " GROUP BY " + xZBZ+"_CHAVE, " + xZBZ+"_MANIF, " + xZBZ+"_NOTA, ZBZ.R_E_C_N_O_ "+CRLF 
	cQuery += " ORDER BY ZBZ." + xZBZ+"_NOTA "+CRLF
	
	
Else 

	cQuery := " SELECT DISTINCT " + CRLF
	cQuery += " ZBZ."        + xZBZ+ "_CHAVE , "+CRLF
	cQuery += " ZBZ."        + xZBZ+ "_NOTA,  "+CRLF 
	cQuery += " ZBZ."        + xZBZ+ "_SERIE,  "+CRLF
	cQuery += " ZBZ."        + xZBZ+ "_MANIF AS ZBZMANIF,  "+CRLF
	
	cQuery += " ZBZ.R_E_C_N_O_ AS RECZBZ "  +CRLF
	
	/*
	cQuery += " ( SELECT * FROM ( Select " + xZBE+"_DESC FROM " + RetSqlName(xZBE) + " ZBE  "+CRLF
	cQuery += " INNER JOIN " + RetSqlName(xZBZ) + " ZBZ ON "+ xZBZ+ "_CHAVE = "+ xZBE+"_CHAVE AND ZBZ.D_E_L_E_T_ = ' ' "+CRLF
	cQuery += " AND " +xZBE + "_TPEVE <> 'HXL069' "+CRLF
	cQuery += " AND ZBE.D_E_L_E_T_ =' ' "+CRLF	
	cQuery += " ORDER BY " + xZBE+"_DTRECB DESC) WHERE ROWNUM = 1 ) AS DESCMANIF "+CRLF + CRLF
	*/
	
	cQuery += " ,(SELECT * FROM ( Select ZBE." + xZBE+"_TPEVE FROM " + RetSqlName(xZBE) + " ZBE  "+CRLF
	cQuery += " INNER JOIN " + RetSqlName(xZBZ) + " ZBZ1 ON RTRIM(ZBZ1."+ xZBZ + "_CHAVE) = RTRIM(ZBE."+ xZBE+"_CHAVE) AND ZBZ1.D_E_L_E_T_ = ' ' "+CRLF
	cQuery += " AND ZBE." + xZBE + "_TPEVE <> 'HXL069' AND ZBE.D_E_L_E_T_ = ' ' AND ROWNUM = 1 "+CRLF	
	cQuery += " ORDER BY ZBE." + xZBE+"_DTRECB DESC) ) AS EVEMANIF "+CRLF + CRLF
	
	cQuery += " , CASE WHEN (SELECT * FROM ( Select ZBE1." + xZBE+"_TPEVE FROM " + RetSqlName("ZBE") + "  ZBE1 "+CRLF  
	cQuery += "  INNER JOIN " + RetSqlname("ZBZ") + " ZBZ2 ON RTRIM(ZBZ2." + xZBZ+ "_CHAVE) = RTRIM(ZBE1." + xZBE+"_CHAVE) AND ZBZ2.D_E_L_E_T_ = ' ' "+CRLF
	cQuery += "  AND ZBE1." + xZBE+ "_TPEVE <> 'HXL069' AND ZBE1.D_E_L_E_T_ = ' ' AND ROWNUM = 1 "+CRLF	
	cQuery += "  ORDER BY ZBE1." + xZBE+"_DTRECB DESC) ) = '110110' THEN '0' "+CRLF + CRLF
	
	cQuery += " ELSE " + CRLF + CRLF
	
	cQuery += " CASE WHEN (SELECT * FROM ( Select ZBE2." + xZBE+ "_TPEVE FROM " + RetSqlName("ZBE") + " ZBE2 "+CRLF  
	cQuery += "  INNER JOIN " + RetSqlname("ZBZ") + " ZBZ3 ON RTRIM(ZBZ3." + xZBZ+ "_CHAVE) = RTRIM(ZBE2." + xZBE+"_CHAVE) AND ZBZ3.D_E_L_E_T_ = ' ' "+CRLF
	cQuery += "  AND ZBE2." + xZBE+ "_TPEVE <> 'HXL069'  AND ZBE2.D_E_L_E_T_ = ' ' AND ROWNUM = 1 "+CRLF	
	cQuery += " ORDER BY ZBE2." + xZBE+"_DTRECB DESC) ) = '210200' THEN '1' "+CRLF + CRLF  
	
	cQuery += " ELSE " + CRLF + CRLF
	
	cQuery += " CASE WHEN ( SELECT * FROM ( Select ZBE3." + xZBE+ "_TPEVE FROM " + RetSqlName("ZBE") + " ZBE3 "+CRLF  
	cQuery += "  INNER JOIN " + RetSqlname("ZBZ") + " ZBZ4 ON RTRIM(ZBZ4." + xZBZ+ "_CHAVE) = RTRIM(ZBE3." + xZBE+"_CHAVE) AND ZBZ4.D_E_L_E_T_ = ' ' "+CRLF
	cQuery += "  AND ZBE3." + xZBE+ "_TPEVE <> 'HXL069' AND ZBE3.D_E_L_E_T_ = ' ' AND ROWNUM = 1 "+CRLF	
	cQuery += " ORDER BY ZBE3." + xZBE+"_DTRECB DESC) ) = '210220' THEN '2' "+CRLF + CRLF
	
	cQuery += " ELSE " + CRLF + CRLF
	
	cQuery += " CASE WHEN ( SELECT * FROM ( Select ZBE4." + xZBE + "_TPEVE FROM " + RetSqlName("ZBE") + " ZBE4 "+CRLF  
	cQuery += "  INNER JOIN " + RetSqlname("ZBZ") + " ZBZ5 ON RTRIM(ZBZ5." + xZBZ+ "_CHAVE) = RTRIM(ZBE4." + xZBE+"_CHAVE) AND ZBZ5.D_E_L_E_T_ = ' ' "+CRLF
	cQuery += "  AND ZBE4." + xZBE+ "_TPEVE <> 'HXL069' AND ZBE4.D_E_L_E_T_ = ' ' AND ROWNUM = 1 "+CRLF	
	cQuery += " ORDER BY ZBE4." + xZBE+"_DTRECB DESC) ) = '210240' THEN '3' "+CRLF + CRLF 
	
	cQuery += " ELSE " + CRLF + CRLF
	
	cQuery += " CASE WHEN ( SELECT * FROM ( Select ZBE5." + xZBE+ "_TPEVE FROM " + RetSqlName("ZBE") + " ZBE5 "+CRLF  
	cQuery += "  INNER JOIN " + RetSqlname("ZBZ") + " ZBZ6 ON RTRIM(ZBZ6." + xZBZ+ "_CHAVE) = RTRIM(ZBE5." + xZBE+"_CHAVE) AND ZBZ6.D_E_L_E_T_ = ' ' "+CRLF
	cQuery += "  AND ZBE5." + xZBE+ "_TPEVE <> 'HXL069' AND ZBE5.D_E_L_E_T_ ='' AND ROWNUM = 1 "+CRLF	
	cQuery += " ORDER BY ZBE5." + xZBE+"_DTRECB DESC) ) = '210210' THEN '4' "+CRLF + CRLF
	
	cQuery += " ELSE " + CRLF + CRLF
	
	cQuery += " CASE WHEN (SELECT * FROM ( Select ZBE6." + xZBE+ "_TPEVE FROM " + RetSqlName("ZBE") + " ZBE6 "+CRLF  
	cQuery += "  INNER JOIN " + RetSqlname("ZBZ") + " ZBZ7 ON RTRIM(ZBZ7." + xZBZ+ "_CHAVE) = RTRIM(ZBE6." + xZBE+"_CHAVE) AND ZBZ7.D_E_L_E_T_ = ' ' "+CRLF
	cQuery += "  AND ZBE6." + xZBE+ "_TPEVE <> 'HXL069' AND ZBE6.D_E_L_E_T_ = ' ' AND ROWNUM = 1 "+CRLF	
	cQuery += " ORDER BY ZBE6." + xZBE+"_DTRECB DESC) ) = '110111' THEN '5' "+CRLF + CRLF
	
	cQuery += " ELSE " + CRLF + CRLF
	
	cQuery += " CASE WHEN (SELECT * FROM ( Select ZBE7." + xZBE+ "_TPEVE FROM " + RetSqlName("ZBE") + " ZBE7 "+CRLF  
	cQuery += "  INNER JOIN " + RetSqlname("ZBZ") + " ZBZ8 ON RTRIM(ZBZ8." + xZBZ+ "_CHAVE) = RTRIM(ZBE7." + xZBE+"_CHAVE) AND ZBZ8.D_E_L_E_T_ = ' ' "+CRLF
	cQuery += "  AND ZBE7." + xZBE+ "_TPEVE <> 'HXL069' AND ZBE7.D_E_L_E_T_ = ' ' AND ROWNUM = 1 "+CRLF	
	cQuery += " ORDER BY ZBE7." + xZBE+"_DTRECB DESC) ) = '610110' THEN '6' "+CRLF + CRLF
	
	cQuery += " END END END END END END END AS PROJMANIF "+CRLF + CRLF
	
	cQuery += " FROM " + RetSqlName(xZBZ) + " ZBZ "+CRLF
	//cQuery += " INNER JOIN " + RetSqlName(xZBE) + " ZBEX ON RTRIM(ZBEX." + xZBE+"_CHAVE) = RTRIM(ZBZ." + xZBZ+"_CHAVE) AND ZBEX.D_E_L_E_T_ = '' "+CRLF
	cQuery += " WHERE ZBZ.D_E_L_E_T_ = ' ' "+CRLF
	//cQuery += " GROUP BY " + xZBZ+"_CHAVE, " + xZBZ+"_MANIF, " + xZBZ+"_NOTA, ZBZ.R_E_C_N_O_ "+CRLF 
	cQuery += " ORDER BY ZBZ." + xZBZ+"_NOTA "+CRLF
	

Endif //if do bco de dados	
	
	MemoWrite("C:\TEMP\FQrymanif.TXT" , cQuery)
	cQuery := ChangeQuery(cQuery)
	
	If !Empty(Select(_cAlias))
		DbSelectArea(_cAlias)
		(_cAlias)->(dbCloseArea())
	Endif
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),_cAlias,.T.,.T.)
	dbSelectArea(_cAlias)
	(_cAlias)->(dbGoTop())
	
	If (_cAlias)->(!Eof())
	
		While (_cAlias)->(!Eof())
		    
			If (_cAlias)->ZBZMANIF <>  (_cAlias)->PROJMANIF //se o q tá na ZBZ_MANIF for diferente do que for projetado (que no caso é o último, atualiza) 
				
				xManif := (_cAlias)->PROJMANIF
				
				DbSelectArea(xZBZ)
				Dbgoto( (_cAlias)->RECZBZ )
					Reclock(xZBZ, .F.)
					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"MANIF"), xManif ))
				DbSelectArea(xZBZ)
				MsUnLock()
				
			Endif 
			
			dbSelectArea(_cAlias)
			(_cAlias)->(Dbskip()) 		
			
		Enddo
	Endif 
	
//Endif //if do banco de dados

DbSelectArea(_cAlias)
(_cAlias)->(dbCloseArea())

Return
//----------------------------------------------------------------------------//
//Função  : Cadastra SX9 - Relacionamento entre tabelas
//Autoria : FR - Flávia Rocha
//Objetivo: Criar relacionamento entre:
//          -> ZBZ com ZBT
//          -> ZBZ com SF1
//          -> ZBZ com SA2
//Data    : 19/08/2022
//----------------------------------------------------------------------------//
USER FUNCTION FCADSX9(xAlias)

Local lTemCDOM := .F. 
Local cIdent   := "" 
Local aIdent   := {} 

Default xAlias := ""

//primeiro procura se existe o relacionamento da ZBZ na SX9
DbSelectArea("SX9")
SX9->(OrdSetFocus(1))
If !SX9->(Dbseek(xZBZ))  //X9_DOM
			
	/*
	X9_DOM – Tabela de Origem
	X9_CDOM – Tabela de Destino
	X9_EXPDOM – Campo(s) da tabela de Origem
	X9_EXPCDOM – Campo(s) da tabela de Destino
	X9_LIGDOM – 1 ou N no relacionamento da tabela de Origem
	X9_LIGCDOM – 1 ou N no relacionamento da tabela de Destino
	*/

	//RELACIONA COM ZBT
	RecLock("SX9", .T.)
		SX9->X9_DOM 	:= xZBZ 
		SX9->X9_IDENT   := "001"
		SX9->X9_CDOM	:= xZBT 
		SX9->X9_EXPDOM 	:= xZBZ_+"CHAVE"
		SX9->X9_EXPCDOM	:= xZBT_+"CHAVE"
		SX9->X9_LIGDOM  := "1"
		SX9->X9_LIGCDOM := "N"
		SX9->X9_PROPRI  := "U"
		SX9->X9_ENABLE  := "S"
		//SX9->X9_USEFIL  := "S"
		
	SX9->(MsUnlock())

Endif 

If xAlias <> Nil

	If !Empty(xAlias)

		//verifica se já tem cadastro na SX9 com o alias ZBZ:
		If SX9->(Dbseek(xZBZ))  //X9_DOM
			While Alltrim(SX9->X9_DOM) == xZBZ
				
				If Alltrim(SX9->X9_CDOM) == Alltrim(xAlias)
					lTemCDOM := .T.
				Endif

				cIdent := SX9->X9_IDENT
				//coloca num array porque este arquivo não está com o IDENT em ordem
				IF ASCAN(aIdent,cIdent) == 0
					Aadd(aIdent, cIdent)
				ENDIF 

				SX9->(Dbskip())
			Enddo 

			//se não tiver o alias no X9_CDOM, para X9_DOM = "ZBZ" , aí sim, cria
			If !lTemCDOM 

				aSort(aIdent)
				cIdent := Soma1( aIdent[Len(aIdent)] ) //soma1 no ident maior

				RecLock("SX9", .T.)
					SX9->X9_DOM 	:= xZBZ 
					SX9->X9_IDENT   := cIdent
					SX9->X9_CDOM	:= xAlias

					If Alltrim(xAlias) == "SF1"  		//cabeçalho nf entrada

						SX9->X9_EXPDOM 	:= xZBZ_+"CHAVE"
						SX9->X9_EXPCDOM	:= "F1_CHVNFE"

					Elseif Alltrim(xAlias) == "SA2"		//cadastro fornecedor
						SX9->X9_EXPDOM 	:= xZBZ_+"CODFOR+" + xZBZ_+"LOJFOR"		//ZBZ_CODFOR+ZBZ_LOJFOR
						SX9->X9_EXPCDOM	:= "A2_COD+A2_LOJA"
					Endif 

					SX9->X9_LIGDOM  := "1"
					SX9->X9_LIGCDOM := "1"
					SX9->X9_PROPRI  := "U"
					SX9->X9_ENABLE  := "S"
				SX9->(MsUnlock())			

			Endif 
		Endif 

	Endif //!Empty xAlias

Endif     //xAlias <> Nil


Return
//FR - 04/10/2022 - criação de função separada para gravação da ZBZ
//==================================================================//
//Função  : U_FGRVZBZ 
//Objetivo: CETRALIZAR NUMA SÓ FUNÇÃO a tarefa de 
//          Gravar a tabela ZBZ cabeçalho do XML
//Autoria : Flávia Rocha
//Data    : 04/10/2022
//==================================================================//
USER FUNCTION FGRVZBZ(aVars)
//(lAppend,_cFil,cSerXMl,cChaveXml,lTransf,cCnpjEmi,cDocDest,cNomFil,cDocXMl,cRazao,nBASCAL,nICMVAL,nICMDES,nSTBASE,;
//nSTVALO,nIPIVAL,nIPIDEV,nPISVAL,nCOFVAL,nOUTVAL,dDataEntr,S_XML,cStatusXml,cModelo,cCodEmit,cLojaEmit,cIndRur,cUfDest,cMensagem,cError,cOcorr,cWarning,cTipoDoc,cCfopDoc,nVLLIQ,nVLDESC,nVLIMP,nVLBRUT,nVlCarga,xMunIni,xUFIni)
/*
U_FGRVZBZ(lAppend,_cFil,cSerXMl,cChaveXml,lTransf,cCnpjEmi,cDocDest,cNomFil,cDocXMl,cRazao,nBASCAL,nICMVAL,nICMDES,nSTBASE,;
nSTVALO,nIPIVAL,nIPIDEV,nPISVAL,nCOFVAL,nOUTVAL,dDataEntr,S_XML,cStatusXml,cModelo,cCodEmit,cLojaEmit,cIndRur,cUfDest,cError,;
cOcorr,cWarning,cTipoDoc,cCfopDoc,nVLLIQ,nVLDESC,nVLIMP,nVLBRUT,nVlCarga,xMunIni,xUFIni)
*/

Local i    := 0
Local cObs := ""
/*
Default cWarning := ""
Default cError   := ""
Default cOcorr   := ""
Default cTipoDoc := "N"
Default cCfopDoc := ""
*/

Local lAppend
Local _cFil
Local cSerXMl
Local cChaveXml
Local lTransf
Local cCnpjEmi
Local cDocDest
Local cNomFil
Local cDocXMl
Local cRazao
Local nBASCAL
Local nICMVAL
Local nICMDES
Local nSTBASE
Local nSTVALO
Local nIPIVAL
Local nIPIDEV
Local nPISVAL
Local nCOFVAL
Local nOUTVAL
Local dDataEntr
Local S_XML
Local cStatusXml
Local cModelo
Local cCodEmit
Local cLojaEmit
Local cIndRur
Local cUfDest
Local cError
Local cOcorr
Local cWarning
Local cTipoDoc
Local cCfopDoc
Local nVLLIQ
Local nVLDESC
Local nVLIMP
Local nVLBRUT
Local nVlCarga
Local xMunIni
Local xUFIni
Local cMensagem 		
Local cOriNF
Local aDocOri   := {"1",; // (Gestão XML)     -> Erick Silva - 16/02/2023
					"2"}  // (Protheus Padrão) 

 lAppend 	:= aVars[1,1]
 _cFil 		:= aVars[1,2]
 cSerXMl 	:= aVars[1,3]
 cChaveXml 	:= aVars[1,4]
 lTransf 	:= aVars[1,5]
 cCnpjEmi 	:= aVars[1,6]
 cDocDest 	:= aVars[1,7]
 cNomFil 	:= aVars[1,8]
 cDocXMl 	:= aVars[1,9]
 cRazao 	:= aVars[1,10]
 nBASCAL 	:= aVars[1,11]
 nICMVAL 	:= aVars[1,12]
 nICMDES 	:= aVars[1,13]
 nSTBASE 	:= aVars[1,14]
 nSTVALO 	:= aVars[1,15]
 nIPIVAL	:= aVars[1,16]
 nIPIDEV 	:= aVars[1,17]
 nPISVAL 	:= aVars[1,18]
 nCOFVAL	:= aVars[1,19]
 nOUTVAL 	:= aVars[1,20]
 dDataEntr 	:= aVars[1,21]
 S_XML 		:= aVars[1,22]
 cStatusXml := aVars[1,23]
 cModelo 	:= aVars[1,24]
 cCodEmit 	:= aVars[1,25]
 cLojaEmit 	:= aVars[1,26]
 cIndRur 	:= aVars[1,27]
 cUfDest 	:= aVars[1,28]
 cError 	:= aVars[1,29]
 cOcorr 	:= aVars[1,30]
 cWarning 	:= aVars[1,31]
 cTipoDoc 	:= aVars[1,32]
 cCfopDoc 	:= aVars[1,33]
 nVLLIQ 	:= aVars[1,34]
 nVLDESC 	:= aVars[1,35]
 nVLIMP 	:= aVars[1,36]
 nVLBRUT 	:= aVars[1,37]
 nVlCarga 	:= aVars[1,38]
 xMunIni 	:= aVars[1,39]
 xUFIni		:= aVars[1,40]
 cMensagem  := aVars[1,41]
 cOriNF     := aVars[1,42]

Reclock(xZBZ,lAppend)

(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CHAVE"), cChaveXml))  //Colocado no ínicio como prioridade de gravação
(xZBZ)->(FieldPut(FieldPos(xZBZ_+"FILIAL"), _cFil))

MsUnLock()

cSeriNF := verSerie( cSerXMl, cFilAnt, lTransf )

Reclock(xZBZ,.F.)

(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CNPJ"), cCnpjEmi))
(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CNPJD"), cDocDest))
(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CLIENT"), cNomFil))
(xZBZ)->(FieldPut(FieldPos(xZBZ_+"SERIE"), verSerie( cSerXMl, cFilAnt, lTransf ) ))

If cModelo == "55"
	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"NOTA"), U_NumNota(cDocXMl,nFormNfe) ))
ElseIf cModelo == "57"
	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"NOTA"), U_NumNota(cDocXMl,nFormCte) ))
Else
	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"NOTA"), U_NumNota(cDocXMl,0) ))
EndIf

(xZBZ)->(FieldPut(FieldPos(xZBZ_+"FORNEC"), cRazao))
//TRATAMENTO IMPOSTOS - AUDITORIA
(xZBZ)->(FieldPut(FieldPos(xZBZ_+"BASCAL"), nBASCAL))
(xZBZ)->(FieldPut(FieldPos(xZBZ_+"ICMVAL"), nICMVAL))
(xZBZ)->(FieldPut(FieldPos(xZBZ_+"ICMDES"), nICMDES))
(xZBZ)->(FieldPut(FieldPos(xZBZ_+"STBASE"), nSTBASE))
(xZBZ)->(FieldPut(FieldPos(xZBZ_+"STVALO"), nSTVALO))
(xZBZ)->(FieldPut(FieldPos(xZBZ_+"IPIVAL"), nIPIVAL))
(xZBZ)->(FieldPut(FieldPos(xZBZ_+"IPIDEV"), nIPIDEV))
(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PISVAL"), nPISVAL))
(xZBZ)->(FieldPut(FieldPos(xZBZ_+"COFVAL"), nCOFVAL))
(xZBZ)->(FieldPut(FieldPos(xZBZ_+"OUTVAL"), nOUTVAL))

if Empty(  (xZBZ)->(FieldGet(FieldPos(xZBZ_+"DTRECB")))  )   //Gravar só se Tiver Vazio
	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"DTRECB"), dDataBase))
endif
(xZBZ)->(FieldPut(FieldPos(xZBZ_+"DTNFE"), dDataEntr))
(xZBZ)->(FieldPut(FieldPos(xZBZ_+"XML"), S_XML))
(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PRENF"), cStatusXml))
(xZBZ)->(FieldPut(FieldPos(xZBZ_+"STATUS"), cStatReg))

cObs := cMensagem + CRLF + cError + CRLF + cWarning + CRLF + cOcorr
(xZBZ)->(FieldPut(FieldPos(xZBZ_+"OBS"), cObs)) 

(xZBZ)->(FieldPut(FieldPos(xZBZ_+"MODELO"), cModelo))
(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CODFOR"), cCodEmit))
(xZBZ)->(FieldPut(FieldPos(xZBZ_+"INDRUR"), cIndRur))
(xZBZ)->(FieldPut(FieldPos(xZBZ_+"LOJFOR"), cLojaEmit))
(xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPDOC"), cTipoDoc))
(xZBZ)->(FieldPut(FieldPos(xZBZ_+"UF"), cUfDest))
(xZBZ)->(FieldPut(FieldPos(xZBZ_+"SERORI"), cSerXMl))
//FR - 28/04/2021 - NOVA TELA GESTÃOXML - GRAVAR NOVO CAMPO ZBZ_ICOMPL - informações complementares
xInfoCompl := ""
xInfoCompl := U_fInfoCompl(cModelo,S_XML)
If xInfoCompl <> Nil  		
	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"ICOMPL"), xInfoCompl ))
Endif
If (xZBZ)->(FieldPos(xZBZ_+"FORPAG"))>0    //GETESB
	if Type( cTagTpPag ) <> "U"
		(xZBZ)->(FieldPut(FieldPos(xZBZ_+"FORPAG"), &(cTagTpPag) ))
	else
		(xZBZ)->(FieldPut(FieldPos(xZBZ_+"FORPAG"), "1" ))
	endif

Endif

If (xZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF"))) == "N"
	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"ORIGEM"), aDocOri[2]))
EndIf

If (xZBZ)->(FieldPos(xZBZ_+"CONDPG"))>0    //GETESB
	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CONDPG"), U_HF02CPG() ))
EndIf

If (xZBZ)->(FieldPos(xZBZ_+"TPEMIS"))>0 .And. (xZBZ)->(FieldPos(xZBZ_+"TPAMB")) > 0

	if Type( cTagTpEmiss ) <> "U" .And. !Empty(cTagTpEmiss)
		(xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPEMIS"), &(cTagTpEmiss) ))
	Endif

	if Type( cTagTpAmb ) <> "U" .And. !Empty(cTagTpAmb)
		(xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPAMB"), &(cTagTpAmb) ))
	EndIF

EndIf

If (xZBZ)->(FieldPos(xZBZ_+"TOMA")) > 0 .And. (xZBZ)->(FieldPos(xZBZ_+"DTHRCS")) > 0
	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"TOMA"), cTipoToma))
	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"DTHRCS"), cDtHrCOns))
EndIf

If (xZBZ)->(FieldPos(xZBZ_+"CNPJT")) > 0 
	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CNPJT"), cDocToma))
EndIf

If (xZBZ)->(FieldPos(xZBZ_+"PROT")) > 0
	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PROT"), cProtocolo))
EndIf
If (xZBZ)->(FieldPos(xZBZ_+"VERSAO")) > 0
	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"VERSAO"), cVerXml))
EndIf

If (xZBZ)->(FieldPos(xZBZ_+"MAIL")) > 0
	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"MAIL"), cStatMail))
	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"DTMAIL"), cInfoErro))
EndIf

if (xZBZ)->(FieldPos(xZBZ_+"MANIF")) > 0   // .And. ! Empty(xManif) //GETESB2
	cRet := U_HFMANZBS( AllTrim( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))) ), "", cOrigem )
	if !Empty( cRet )
		(xZBZ)->(FieldPut(FieldPos(xZBZ_+"MANIF"), cRet ))
	endif
endif

if (xZBZ)->(FieldPos(xZBZ_+"IMPORT")) > 0
	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"IMPORT"), cOrigem ))
endif

if (xZBZ)->(FieldPos(xZBZ_+"TPDOWL")) > 0
	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPDOWL"), cTipoDow ))
endif

if (xZBZ)->(FieldPos(xZBZ_+"TPROT")) > 0 //Tipo de Rotina Job ou Manual

	if Empty(  (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPROT"))) )

		if Type("cTpRt") <> "U"
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPROT"), cTpRt ))
		endif

	endif

endif

if (xZBZ)->(FieldPos(xZBZ_+"CFOP")) > 0
	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CFOP"), cCfopDoc ))
endif

//Criar campo na ZBZ, referente ao Tipo Ct-e - 26/12/2016 
If (xZBZ)->(FieldPos(xZBZ_+"TPCTE")) > 0

	If Type( cTagTpCte ) <> "U"

		Do Case
			Case &( cTagTpCte ) == "0"
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPCTE"), "N"))
			Case &( cTagTpCte ) == "1"
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPCTE"), "C"))
			Case &( cTagTpCte ) == "2"
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPCTE"), "A"))
			Case &( cTagTpCte ) == "3"
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPCTE"), "S"))
			EndCase
					//	else
					//		(xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPCTE"), "N" ))
	EndIf

EndIf

//Fim da alteração //

if GetNewPar("XM_USAGFE","N") = "S"

	if cModelo = "57"

		If (xZBZ)->(FieldPos(xZBZ_+"SITGFE")) > 0
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"SITGFE"), U_HFSITGFE( cChaveXml, "GFE" ) ))
		Endif

	endif

Endif

//CamposNuv( oXml, cModelo, @nVLLIQ, @nVLDESC, @nVLIMP, @nVLBRUT )
if (xZBZ)->(FieldPos(xZBZ_+"VLLIQ")) > 0
	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"VLLIQ"), nVLLIQ ))
endif

if (xZBZ)->(FieldPos(xZBZ_+"VLDESC")) > 0
	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"VLDESC"), nVLDESC ))
endif

if (xZBZ)->(FieldPos(xZBZ_+"VLIMP")) > 0
	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"VLIMP"), nVLIMP ))
endif

if (xZBZ)->(FieldPos(xZBZ_+"VLBRUT")) > 0
	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"VLBRUT"), nVLBRUT ))
endif

if (xZBZ)->(FieldPos(xZBZ_+"VCARGA")) > 0
	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"VCARGA"), nVlCarga ))
endif
DbSelectArea(xZBZ)
MsUnLock()
//--------------------------------------------------------------------------------//
//FR - 04/06/2020 - Projeto CCM - Tratativa para gravação no novo campo ZBZ_ORIPRT
//                - origem prestação de Serviço (Município - UF)  
//--------------------------------------------------------------------------------//
If cModelo == "57"	
	DbSelectArea(xZBZ)
	Reclock(xZBZ,.F.)
	If (xZBZ)->(FieldPos(xZBZ_+"ORIPRT")) > 0
		(xZBZ)->(FieldPut(FieldPos(xZBZ_+"ORIPRT"), (xMunIni + "-" + xUFIni) ))
	Endif
	If Empty(xMunIni) .or. Empty(xUFIni)
		//CONOUT("<GESTAOXML> GRAVACAO -> xMunIni ou xUFIni Vazios !" )
	Else
		//CONOUT("<GESTAOXML> GRAVACAO -> xMunIni / xUFIni OK ")
	Endif
	DbSelectArea(xZBZ)
	MsUnLock()
			
Endif
			
//--------------------------------------------------------------------------------//
//FR - 27/07/2020 - Projeto CCM - Tratativa para gravação no novo campo ZBZ_ORIPRT
//                - origem prestação de Serviço (Município - UF)  
//--------------------------------------------------------------------------------//
cError   := ""
cWarning := ""
			
If cModelo == "57"

	oXml := XmlParser( S_XML, "_", @cError, @cWarning )

	if Empty( oXml )

		S_XML := EncodeUTF8(S_XML)
		S_XML := FwNoAccent(S_XML)
					
		//Faz backup do xml sem retirar os caracteres especiais
		cBkpXml := S_XML

		//Executa rotina para retirar os caracteres especiais
		S_XML := u_zCarEspec( S_XML)

		oXml := XmlParser( S_XML, "_", @cError, @cWarning )

		//retorna o backup do xml
		S_XML := cBkpXml

	endif
						
	//-------------------------------------------------------------------------------//	
	//FR - 27/07/2020 - Projeto CCM - novo campo origem prestação serviço ZBZ_ORIPRT 
	//-------------------------------------------------------------------------------//
	If Empty(cError) .And. Empty(cWarning) .And. oXml <> Nil 
				
		xMunIni := ""
		cTagAux := "oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_XMUNINI:TEXT"
				
		xMunIni := &(cTagAux)
		xUFIni := ""
		cTagAux := "oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_UFINI:TEXT"
				
		xUFIni := &(cTagAux)
				    
	    DbSelectArea(xZBZ)
	    Reclock(xZBZ,.F.)
				    									
		If (xZBZ)->(FieldPos(xZBZ_+"ORIPRT")) > 0
					
			If Empty( (xZBZ)->(FieldPos(xZBZ_+"ORIPRT")) )
		    	//CONOUT("<GESTAOXML> => _ORIPRT Vazio <=" )					    	
		    Endif
					    
		    If Empty(xMunIni) .or. Empty(xUFIni)
				//CONOUT("<GESTAOXML> REGRAVACAO => xMunIni ou xUFIni Vazios !" )
			Else
				//CONOUT("<GESTAOXML> REGRAVACAO => xMunIni / xUFIni OK ")
			Endif
				    
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"ORIPRT"), (xMunIni + "-" + xUFIni) ))
						
		Endif
					
		DbSelectArea(xZBZ)
		MsUnLock()					
					
    Endif
			    
Endif
DbSelectArea(xZBZ)
MsUnLock()

//----------------------------------------------------------------//
//FR - 18/08/2020 - Kroma - XML Energia - Definido pelo NCM e CFOP 
//----------------------------------------------------------------//
cError       := ""
cWarning     := ""
oDet         := NIL
cTagAux      := ""
cCFOPEnergia := GetNewPar("XM_CFOENERG","5251,6251,5123,6123,5922,6922")		//deixar aqui mesmo porque é algo que não mudará
cCFOP        := ""
lEnergia     := .F.

oXml := XmlParser( S_XML, "_", @cError, @cWarning )

if Empty( oXml )
			
	S_XML := EncodeUTF8(S_XML)
	S_XML := FwNoAccent(S_XML)
				
	//Faz backup do xml sem retirar os caracteres especiais
	cBkpXml := S_XML
	//Executa rotina para retirar os caracteres especiais
	S_XML := u_zCarEspec( S_XML)

	oXml := XmlParser( S_XML, "_", @cError, @cWarning )

	//retorna o backup do xml
	S_XML := cBkpXml

endif
			 
If cModelo $ "55,65"
			
	If Type( "oXml:_NFEPROC:_NFE:_INFNFE:_DET" ) != "U"	
		oDet := oXml:_NFEPROC:_NFE:_INFNFE:_DET
		oDet := IIf(ValType(oDet)=="O",{oDet},oDet)	
	Else	
		oDet := {}	
	Endif
				
	If Len(oDet) > 0
		For i := 1 To Len(oDet)
										
			//CFOP do produto						
			cTagAux := "oDet["+AllTrim(str(I))+"]:_PROD:_CFOP:TEXT"						
			If type( cTagAux ) <> "U"
				cCFOP := (&cTagAux)
				If cCFOP $ cCFOPEnergia
					lEnergia := .T.
					Exit
				Endif 
			Endif		
        Next		            
    Endif
           
Endif
			
If lEnergia 
	DbSelectArea(xZBZ)
	Reclock(xZBZ,.F.)
				
	If (xZBZ)->(FieldPos(xZBZ_+"COMBUS")) > 0
		(xZBZ)->(FieldPut(FieldPos(xZBZ_+"COMBUS"), "E" ))
	Endif
				
	DbSelectArea(xZBZ)
	MsUnLock()
Endif
//FR - 18/08/2020 - Fim tratativa para Kroma Energia

RETURN			
