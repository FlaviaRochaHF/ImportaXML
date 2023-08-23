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

Static lInitSped := .F.
Static lUnix     := IsSrvUnix()
Static cBarra    := Iif(lUnix,"/","\")

//---------------------------------------------------------------------------//
//AlteraÁıes realizadas:
//FR - 16/03/2020 - Projeto Politec - criaÁ„o dos campos: ZBT_ITEM, ZBT_NOTA, 
//                  ZBT_SERIE, ZBT_CLIFOR, ZBT_LOJA, ZBT_TIPOFO
//                  Para gravaÁ„o das notas de origem que compıem 
//                  o Cte por linha na ZBT e SD1.
//----------------------------------------------------------------------------//
//FR - 04/06/2020 - Projeto CCM: criaÁ„o de novo campo ZBZ_ORIPRT 
//                  Origem da prestaÁ„o de serviÁo: ir· armazenar:
//                  o municÌpio - UF. Ex.: JUNDIAI - SP
//----------------------------------------------------------------------------//
//FR - 16/06/2020 - ECOURBIS: tratativa para incluir campo NCM no array de 
//                  itens do XML - FunÁ„o U_fIMPXMLFOR
//----------------------------------------------------------------------------// 
//FR - 24/07/2020 - AGUAS BR: adiÁ„o de getArea para tabelas do Gest„o XML 
//----------------------------------------------------------------------------//  
//FR - 05/10/2020 - DeclaraÁ„o das vari·veis de macro substituiÁ„o das tabelas
//                  do Importa, pois no job, ocorria error log por erro de 
//                  n„o encontrar a tabela aberta: 
//                  (vari·vel n„o existe xZBZ , xZBT ...assim por diante)
//------------------------------------------------------------------------------------//  
//FR - 27/11/2020 - Solicitado por Rafael - incluir rotina para gravar ZBT
//                  (Item da ZBZ) 
//----------------------------------------------------------------------------//                  
//FR - 08/02/2021 - #6170 - MaxiRubber - tratativa para prevenir retorno nulo
//                  da funÁ„o EncodeUTF8
//---------------------------------------------------------------------------//
//FR - 15/02/2021 - #6166 - MaxiRubber - GRAVA«√O do novo campo 
//                  nos itens do xml (ZBT), chave da nf original: ZBT_CHAVEO
//---------------------------------------------------------------------------//
//FR - 17/02/2021 - #6210 - Cimentos ItambÈ - tratativa qdo o CTE È de nf 
//                  complemento
//---------------------------------------------------------------------------//
//FR - 24/02/2021 - chamado 6255 - ItambÈ - revis„o de caracteres na funÁ„o
//                  U_Zcarespec()
//---------------------------------------------------------------------------//
//FR - 15/04/2021 - GravaÁ„o dos novos campos: ZBT_UM , ZBT_NCM
//---------------------------------------------------------------------------//
//FR - 05/05/2021 - #10382 - Kroma - tratativa para chamada dentro do Schedule 
//---------------------------------------------------------------------------//
//FR - 07/06/2021 - Rollback das alteraÁıes da Kroma
//---------------------------------------------------------------------------//
//FR - 28/10/2021 - ImplementaÁ„o cadastro fornecedor (SA2) automatizado (Daikin)
//                  Par‚metro: "XM_SA2AUTO" Tipo Caracter, conte˙do : S-Sim; N=N„o
//------------------------------------------------------------------------------//
//FR - 21/12/2021 - Revis„o dos par‚metros de automatizaÁ„o do cadastro de 
//                  fornecedor:
//                  - XM_SA2AUTO - cadastra fornecedor na classif. nf
//                  - XM_SA2AUTD - cadastra fornecedor no download xml
//------------------------------------------------------------------------------//
//FR - 11/01/2022 - PETRA - 11840 - tela an·lise fiscal, incluir campo ICM ST
//------------------------------------------------------------------------------//
/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Programa  ≥ HFXML06D ≥ Autor ≥ Eneovaldo Roveri Jr   ≥ Data ≥03/10/2013≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒ›ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Rotina de Download de XMLs do Sefaz                        ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
//---------------------------------------------------------------------------//
//AlteraÁıes realizadas:  
//FR - 27/09/2022 - CIMENTOS ITAMB… GRAVA«√O DE IMPOSTOS PARA CTE
//----------------------------------------------------------------------------//
//FR - 30/12/2022 - KIM P√ES - CHAMADO #000014229 - GRAVAR O C”DIGO DO PRODUTO 
//                  INTERNO NO CAMPO ZBT_DEPARA, mediante Busca de amarraÁ„o 
//                  (caso haja)
//----------------------------------------------------------------------------//
User Function HFXML06D()

Local aArea := GetArea()
Local nOpc  := 0
Local nChv  := 0
Local cEmp0 := cEmpAnt
Local cFil0 := cFilAnt
Local nReg0 := SM0->( recno() )
Local lTMP  := .F.
Local cCloud		:=	alltrim(GetNewPar("XM_CLOUD" ,"0"))         //aCombo (0=Desbilitado 1=Habilitado) 
Local nQtdCons := 0
//Local cQuery:= ""

Private oTempTable
Private cGetAlias := "TMPSQL"

Private nTipoMod := 0

If cCloud == "1"
		//IF u_HFXSEMA()
		//	MsgInfo("Pode ser realizado a consulta","Teste de qtd de consultas")
		//ELSE
		//	MsgInfo("N„o ser realizado a consulta","Teste de qtd de consultas")
		//ENDIF

		//msgAlert("FunÁ„o desabilitada para NF-e devido estar habilitado integraÁ„o cloud, nesse caso utilize o bot„o baixar xml")
		//	lRet := .F.
		//	Return(lRet)
EndIf	

SM0->( dbSetOrder(1) )
If SM0->( dbSeek( cEmp0 + cFil0 ) )
	cCnpj := SM0->M0_CGC
Else
	SM0->( dbGoTo( nReg0 ) )
	cCnpj := SM0->M0_CGC
Endif

//-------------------
//CriaÁ„o do objeto
//-------------------
oTempTable := FWTemporaryTable():New( cGetAlias )

//Cria a tabela temporario dentro do banco de dados
lTMP := CriaTMP()

If !lTMP

	U_MyAviso("Erro","N„o foi possÌvel criar o Arquivo Tempor·rio."+CRLF+;
	"Verifique suas permissıes e tente novamente.",{"OK"},1)

	RestArea(aArea)

	Return(NIL)

Endif

	//	nOpc := U_MyAviso("OpÁ„o","1-Informar CNPJ ou "+CRLF+"2-Informar Chave"+CRLF+"3-Nenhuma Chave",{"1-CNPJ","2-Chave","3-Nenhum"},3)
	nOpc := U_MyAviso("OpÁ„o","1-Informar Chave"+CRLF+"2-Nenhuma Chave",{"1-Chave","2-Nenhum"},2)

	if nOpc == 0 //1

		if HFXML06Cnp(@nTipoMod)

		nChv++

	endif

	ElseIf nOpc == 1 //2

	do while HFXML06Chv(@nChv)

		if nChv == 10

			//			Exit

		endif

	enddo

EndIf

	if nChv > 0 .or. nOpc == 2 //3

	if nTipoMod == 2

		HFXML06Brw()

	endif

endif

//---------------------------------
//Exclui a tabela
//---------------------------------
oTempTable:Delete()

RestArea(aArea)

Return( NIL )


//Rotina que cria a tabela temporaria dentro do banco de dados
Static Function CriaTMP()

Local aStru := {}
Local nTamCod   := TAMSXG("001")[1]
Local nTamLoja  := TAMSXG("002")[1]

aadd( aStru, { "OK"      ,"C",02,0 } )
aadd( aStru, { "ST"      ,"C",01,0 } )
aadd( aStru, { "CHAVE"   ,"C",44,0 } )
aadd( aStru, { "AMB"     ,"C",01,0 } )
aadd( aStru, { "MSG"     ,"C",30,0 } )
aadd( aStru, { "ERRO"    ,"M",10,0 } )
aadd( aStru, { "CNF"     ,"C",09,0 } )
aadd( aStru, { "SERIE"   ,"C",03,0 } )
aadd( aStru, { "DEST"    ,"C",14,0 } )

//dados do xml para consulta
aadd( aStru, { "CNPJ_EMI","C",14,0 } )
aadd( aStru, { "CODFOR"  ,"C",nTamCod,0 } )
aadd( aStru, { "LOJFOR"  ,"C",nTamLoja,0 } )
aadd( aStru, { "DEMI"    ,"C",10,0 } )
aadd( aStru, { "VNF"     ,"C",15,0 } )
aadd( aStru, { "XNOME"   ,"C",60,0 } )
aadd( aStru, { "IE"      ,"C",14,0 } )
aadd( aStru, { "DIGVAL"  ,"C",28,0 } )
aadd( aStru, { "DHRECBTO","C",10,0 } )
aadd( aStru, { "CSITNFE" ,"C",01,0 } )
aadd( aStru, { "CSITCONF","C",01,0 } )
aadd( aStru, { "NSU"     ,"C",15,0 } )
aadd( aStru, { "Correcao","M",10,0 } )
aadd( aStru, { "IDENT"   ,"C",14,0 } )
aadd( aStru, { "XML"     ,"M",10,0 } )
aadd( aStru, { "XMLCANC" ,"M",10,0 } )
aadd( aStru, { "TOMA" 	 ,"C",14,0 } )

oTemptable:SetFields( aStru )

oTempTable:AddIndex( "01", { "CHAVE" } )
oTempTable:AddIndex( "02", { "SERIE","CNF" } )
oTempTable:AddIndex( "03", { "SERIE","CNF","CNPJ_EMI" } )
oTempTable:AddIndex( "04", { "CNPJ_EMI" } )
oTempTable:AddIndex( "05", { "XNOME" } )
oTempTable:AddIndex( "06", { "CODFOR","LOJFOR" } )
oTempTable:AddIndex( "07", { "ST","CHAVE" } )
oTempTable:AddIndex( "08", { "CNF","SERIE" } )

//------------------
//CriaÁ„o da tabela
//------------------
oTempTable:Create()

Return( .T. )

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Programa  ≥HFXML06Brw≥ Autor ≥ Eneovaldo Roveri Jr   ≥ Data ≥03/10/2013≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒ›ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ MarkBrowse das Chaves para Download                        ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒ›ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Static Function HFXML06Brw()

Local aButtons	:= {}
//Local aGetArea	:= GetArea()
//Local aInfo		:= {}
//Local aPosObj	:= {}
//Local aObjects	:= {}
//Local aSize		:= MsAdvSize()  			// Define e utilizaÁ„o de janela padr„o Microsiga
//Local cGetLOk  	:= "AllwaysTrue"	   		// Funcao executada para validar o contexto da linha atual do aCols
//Local cGetTOk  	:= "AllwaysTrue"    		// Funcao executada para validar o contexto geral da MsNewGetDados
//Local oFolder	:= Nil
Local oDlg01	:= Nil
Local oMarkBw	:= Nil
Local lInverte	:= .F.
Local lOk		:= .F.
//Local cChvAtu	:= " "
//Local cChvAnt	:= " "
//Local oFont		:= Nil
Local aCpos     := {}
Local aCores    := {}
//Local oProgress := NIL

Private cMarcaOK := GetMark()
Private cFiltro  := "NN"

aCpos := {}
aadd( aCpos, {"OK"   ,,"" } )
//aadd( aCpos, {"ST"   ,,"ST","@!" } )
aadd( aCpos, {"CHAVE",,"CHAVE","@!" } )
aadd( aCpos, {"ERRO" ,,"RESP SEFAZ","@!" } )
aadd( aCpos, {"CSITCONF",,"MANIFESTO","@!" } )
aadd( aCpos, {"CNPJ_EMI",,"EMITENTE","@!" } )
aadd( aCpos, {"CODFOR"  ,,"FORNEC","@!" } )
aadd( aCpos, {"LOJFOR"  ,,"LOJA","@!" } )
aadd( aCpos, {"DEMI"    ,,"DT EMISSAO","@!" } )
aadd( aCpos, {"CNF"     ,,"NOTA FISCAL","@!" } )
aadd( aCpos, {"SERIE"   ,,"SERIE","@!" } )
aadd( aCpos, {"VNF"     ,,"VALOR","@!" } )
aadd( aCpos, {"XNOME"   ,,"EMITENTE","@!" } )
aadd( aCpos, {"IE"      ,,"IE EMIT","@!" } )
aadd( aCpos, {"DIGVAL"  ,,"DIGEST VAL","@!" } )
aadd( aCpos, {"DHRECBTO",,"DT AUTORIZ","@!" } )
aadd( aCpos, {"CSITNFE" ,,"SIT NFE","@!" } )
aadd( aCpos, {"NSU"     ,,"NSU","@!" } )
aadd( aCpos, {"Correcao",,"CARTA DE CORRECAO","@!" } )
aadd( aCpos, {"MSG"  	,,"MENSAGEM","@!" } )
//aadd( aCpos, {"XML"     ,,"XML","@!" } )
aadd( aCpos, {"XMLCANC" ,,"XML Cancel","@!" } )
aadd( aCpos, {"TOMA"	,,"TOMADOR CNPJ","@!" } )

aCores := {}

aAdd(aCores,{"TMPSQL->ST == '1'","BR_VERDE"	})
aAdd(aCores,{"TMPSQL->ST == ' '","BR_AMARELO"	})
aAdd(aCores,{"TMPSQL->ST == '0'","BR_VERMELHO" })
aAdd(aCores,{"TMPSQL->ST == '2'","BR_AZUL" })

DbSelectArea("TMPSQL")
DbSetOrder(1)
TMPSQL->( dbGotop() )

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Apresenta botao se nao for visualizacao ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
aAdd(aButtons,{'CHECKED' ,{ || HFXML06Inv(cMarcaOK,@oMarkBw) }, "Inverter MarcaÁ„o", "Inverter"})
aAdd(aButtons,{'DESTINOS',{ || HFXML06Inv(cMarcaOK,@oMarkBw,.T.) }, "Marcar todos os tÌtulos", "Marc Todos"})
aAdd(aButtons,{          ,{ || HFXML06Chv() }, "Digitar Chaves", "Dig Chaves"})
aAdd(aButtons,{          ,{ || HFXML06Cnp(nTipoMod) }, "Digitar CNPJ", "Digitar CNPJ"})
aAdd(aButtons,{          ,{ || HFXML06man() }, "ManifestaÁ„o Destinat·rio", "ManifestaÁ„o Destinat·rio"})
aAdd(aButtons,{          ,{ || HFXML06NSU() }, "Editar NSU/MDAMB/MDVER (NFe) p/Download por CNPJ", "Editar NSU/MDAMB/MDVER (NFe)"})
aAdd(aButtons,{          ,{ || HFXML06NSC() }, "Editar NSU/AMB/VER (CTe) para Download por CNPJ", "Editar NSU/AMB/VER (CTe)"})
aAdd(aButtons,{          ,{ || HFXML06Leg() }, "Legenda", "Legenda"})
aAdd(aButtons,{          ,{ || HFXML06Vis() }, "Visualizar Registro", "Visualizar"})
aAdd(aButtons,{          ,{ || HFXML06Pes(@oMarkBw, "TMPSQL") }, "Pesquisar Registro", "Pesquisar"})
aAdd(aButtons,{          ,{ || HFXML06Fil(@oMarkBw, "TMPSQL") }, "Filtrar Registro", "Filtrar"})

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Define as posicoes da GetDados e Paineis ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
//aAdd( aObjects, { 100, 060, .T., .T. } )      //GetDados
//aAdd( aObjects, { 100, 040, .T., .T. } )      //Folder
//aInfo := { aSize[1], aSize[2], aSize[3], aSize[4], 3, 3 }
//aPosObj := MsObjSize( aInfo, aObjects,.T. )

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Definicao da tela ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ    //aSize[7],0 TO aSize[6],aSize[5]
DEFINE MSDIALOG oDlg01 TITLE "Download XML Sefaz" FROM 000,000 TO 430,800 OF oMainWnd PIXEL

oDlg01:lMaximized := .F.

//@ -15,270 Button "ZOCA" Size 010,011 PIXEL OF oMainWnd ACTION (cJobs:=U_GetJob(cJobs))
//@ -15,-15 BUTTON oBtn PROMPT "ZOCA" SIZE 10,50 PIXEL OF oDlg01

//DEFINE FONT oFont NAME "Arial" SIZE 10,12 BOLD

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Criacao do objeto Folder ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
//oFolder	:= TFolder():New(10,2,{"Chaves"},{},oDlg01,,,,.T.,.F.,aPosObj[1][4],aPosObj[2][3],)  //-aPosObj[2][1]

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Cria o objeto Mark para a selecao dos podrutos ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
oMarkBw := MsSelect():New("TMPSQL","OK","",aCpos,@lInverte,@cMarcaOK,{17,10,150,400},,,,,aCores) //oFolder:aDialogs[1]

oMarkBw:oBrowse:Refresh()
oMarkBw:oBrowse:lhasMark    := .T.
oMarkBw:oBrowse:lCanAllmark := .T.
oMarkBw:oBrowse:Align       := CONTROL_ALIGN_ALLCLIENT	//Usado no modelo FLAT

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Permite selecao se n„o for visualizacao ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
oMarkBw:oBrowse:bAllMark    := { || HFXML06Inv(cMarcaOK,@oMarkBw) }
oMarkBw:oBrowse:bChange     := { || HFXML06Chg(@oMarkBw) }
oMarkBw:BMark               := { || HFXML06Dis(@oMarkBw,cMarcaOK) }

ACTIVATE MSDIALOG oDlg01 CENTERED  ON INIT EnchoiceBar(oDlg01,;
{|lEnd| oProcess := MsNewProcess():New({|lEnd| HFXML06Dow(@oMarkBw,@lEnd,@oProcess)}, "Baixar...","Baixando XML ...",.T.),oProcess:Activate() },;
{|| iif( msgYesNo("Sair Download XML ?","Pegunta"),oDlg01:End(),lOk := .F. )},,aButtons)

Return( .T. )


/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Programa  ≥HFXML06Inv≥ Autor ≥ Eneo                  ≥ Data ≥23/11/2013≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒ›ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Locacao   ≥ Parceiros        ≥Contato ≥ adilson.gomes@advbrasil.com.br ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Esta rotina ira marcar ou desmarcar as chaves.             ≥±±
±±≥          ≥                                                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥                                                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥                                                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ›ƒƒƒ¬ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Analista Resp.≥  Data  ≥ Bops ≥ Manutencao Efetuada                    ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥              ≥        ≥      ≥                                        ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒ›ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Static Function HFXML06Inv(cMarcaOK,oMarkBw,lMarkAll)

Local aGetArea	:= GetArea()
Local lMarcSim	:= .F.

If lMarkAll

	lMarcSim := Aviso( "Marcar/Desmarcar todos", "Deseja marcar ou desmarcar todos os tÌtulos?", { "Marcar", "Desmarcar" } ) == 1

EndIf

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ While para marcar ou desmarcar os produtos ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
DbSelectArea("TMPSQL")
TMPSQL->( dbGotop() )

While TMPSQL->( !Eof() )

	If lMarkAll

		RecLock("TMPSQL", .F.)
		TMPSQL->OK	:= if(TMPSQL->ST == "1", "  ", If(lMarcSim, cMarcaOK, "  ") )
		TMPSQL->( MsUnLock() )

	Else

		If  TMPSQL->OK == cMarcaOK

			RecLock("TMPSQL", .F.)
			TMPSQL->OK	:= "  "
			TMPSQL->( MsUnLock() )

		Else

			RecLock("TMPSQL", .F.)
			TMPSQL->OK	:= if(TMPSQL->ST == "1", "  ", cMarcaOK )
			TMPSQL->( MsUnLock() )

		EndIf

	EndIf

	TMPSQL->( DbSkip() )

End

oMarkBw:oBrowse:Refresh( .T. )

RestArea( aGetArea )

Return


/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Programa  ≥HFXML06Dis≥ Autor ≥ Eneovaldo Roveri Jr   ≥ Data ≥19/01/2010≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒ›ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Locacao   ≥ Parceiros        ≥Contato ≥                                ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Rotina para execucao do filtro na tabela temporaria        ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥                                                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ›ƒƒƒ¬ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Analista Resp.≥  Data  ≥ Bops ≥ Manutencao Efetuada                    ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥              ≥        ≥      ≥                                        ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒ›ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Static Function HFXML06Dis(oMarkBw, cMarcaOK)

Local aGetArea := GetArea()

oMarkBw:oBrowse:Refresh(.T.)

RestArea( aGetArea )

Return

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Programa  ≥HFXML06Chg≥ Autor ≥                       ≥ Data ≥25/09/2008≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒ›ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Rotina para execucao do filtro na tabela temporaria        ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Analista Resp.≥  Data  ≥ Bops ≥ Manutencao Efetuada                    ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥              ≥        ≥      ≥                                        ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒ›ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Static Function HFXML06Chg(oMarkBw)

Local cRetFun := " "

oMarkBw:oBrowse:Refresh(.T.)

Return cRetFun


/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Fun??o    ≥HFXML06Dow≥ Autor ≥Eneovaldo Roveri Junior≥ Data ≥ 03/10/13 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒƒ›ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒ›ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descri??o ≥ Download das Chaves                                        ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ HFXML06Dow()                                               ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function HFXML06Dow(oMarkBw,lEnd,oRegua) //oProcess

Local aArea  := GetArea()
Local nReg   := TMPSQL->( recno() )
Local nRet   := 0
Local xRet   := -1
Local yRet   := -1
Local lTem   := .F.
Local nChv   := 0
Local nEve   := 0
Local cAmb   := ""
Local cChave := ""
Local cChv57 := ""  //Modelo 57, 67, evitando a Fadiga
Local cNsu55 := ""  //A partir de 10/09/18, para tentar resolver os problema de 137, tentar baixar pelo NSU caso tenha erro.
Local cNsu57 := ""  //Aqui pela Fadiga mesmo.
Local cCnpj  := SM0->M0_CGC  //"61135471000100"
Local cIdEnt := "" //U_GetIdEnt()
Local cDir   := AllTrim(SuperGetMv("MV_X_PATHX"))
Local a137   := {}
Local n137   := 0
Local nTotReg:= 0

Default lEnd		:=	.F.
Default oRegua		:=	Nil

Private aChave := {}
Private aNSU   := {} //Fadigando
Private pReg := 0
Private nDow := 0  //Coisa de Louco
Private nErr := 0  //Coisa de Louco
Private nMan := 0  //Coisa de Louco

if GetNewPar("XM_DFE","0") $ "0,1"

	cIdEnt := U_GetIdEnt()
	
endif

Count To nTotReg

oRegua:SetRegua1( nTotReg ) //TMPSQL->( RecCount() )
oRegua:SetRegua2(0)

TMPSQL->( DbSetOrder( 1 ) )
TMPSQL->( DbGotop() )

While .not. TMPSQL->( Eof() )

	//IncProc("Processando "+TMP->CHAVE)
	if lEnd

		MsgStop("*** Cancelado pelo Operador ***","Fim")

		Exit

	endif

	oRegua:IncRegua1("Processando Download das Chaves")
	oRegua:IncRegua2( TMPSQL->CHAVE )

	if .not. empty( TMPSQL->OK ) .and. TMPSQL->ST <> "1"  // == cMarcaOK

		If pReg == 0

			pReg := TMPSQL->( Recno() )

		EndIf

		cCnpj  := TMPSQL->DEST
		cIdEnt := iif( .Not. Empty(TMPSQL->IDENT), AllTrim(TMPSQL->IDENT), cIdEnt )
		lTem   := .T.

		if Substr(TMPSQL->CHAVE,21,2) $ "57,67"

			cChv57 += TMPSQL->CHAVE+";"
			cNsu57 := TMPSQL->NSU

		Else

			cChave += TMPSQL->CHAVE+";"
			cNsu55 := TMPSQL->NSU

		Endif

		aadd( aChave, TMPSQL->CHAVE )
		aadd( aNSU  , TMPSQL->NSU   )

		nChv++

		//if cAmb <> "1"
		cAmb := TMPSQL->AMB
		cXml := TMPSQL->XML
		//endif

		RecLock( "TMPSQL", .F. )

		TMPSQL->OK := "Pr"
		TMPSQL->( MsUnLock() )

	endif

	If nChv >= 1 .Or. ( nChv >= 1 .and. TMPSQL->( Eof() ) )  //Antes ia de 10 em 10, mas agora com o Distr, N„o Da. Tem que ser 1 em 1

		If ! Empty(cChave)

			if ! Empty(cChave) .or. upper("<resNFe ") $ upper( cXml )

				//Verifica se tem serviÁo paralisado - Rogerio Lino 10/03/2022
				//if cRej == "109"
					nRet := HFXML06B55(cCnpj,cChave,cAmb,cIdEnt,cNsu55,"",.T.)
				//else
					//nRet := HFXML06Bai(cCnpj,cChave,cAmb,cIdEnt,.T.)
				//endif

			else

				nRet := HFXML06B55(cCnpj,cChave,cAmb,cIdEnt,cNsu55,"",.T.)

			endif

			//nRet := U_HFDOWDFE( cCnpj,cChave,cAmb,cIdEnt,cNsu55,"" )  //Para Testa

			If nRet == 3  //Refazer, mas no DFE da HF.

				Sleep(1500) //da 1 segundo e vai de novo

				nRet := HFXML06B55(cCnpj,cChave,cAmb,cIdEnt,cNsu55,"",.T.)

				If nRet == 3

					aadd( a137, {cChave,cNsu55} )

					nRet := 2

				Endif

			Endif

			if xRet <> 1

				if nRet == 1

					xRet := nRet

				Else

					if xRet <> 0

						xRet := nRet

					endif

				Endif

			Endif

		EndIF

		If ! Empty(cChv57)

			nRet := HFXML06B57(cCnpj,cChv57,cAmb,cIdEnt)

			if yRet <> 1

				if nRet == 1

					yRet := nRet

				Else

					if xRet <> 0

						yRet := nRet

					endif

				Endif

			Endif

		EndIF

		nChv := 0
		pReg := 0
		cChave := ""
		cNsu55 := ""
		cChv57 := ""
		cNsu57 := ""
		aChave := {}
		aNSU   := {}

	EndIf

	TMPSQL->( DbSkip() )

End

if .Not. lTem

	RestArea(aArea)

	U_MyAviso("Msg","Nenhuma chave selecionada para download !!!!",{"OK"},3)

	TMPSQL->( DbGoto( nReg ) )

	oMarkBw:oBrowse:Refresh(.T.)

	return( nRet )

endif

if xRet == 1  //Tem Chaves para Manifestar

	oMarkBw:oBrowse:Refresh(.T.)

	if U_MyAviso("Pergunta","Existem Chaves sem ManifestaÁ„o. Deseja Manifesta-las e tentar o Download Novamente?",{"SIM","NAO"},2) == 1

		oRegua:IncRegua1("Processando ManifestaÁ„o das Chaves")
		oRegua:IncRegua2(Space(44))

		Do While .Not. HFXML06Man( .T., @nEve )

			if lEnd

				MsgStop("*** Cancelado pelo Operador ***","Fim")
				Exit

			endif

		EndDo

		oMarkBw:oBrowse:Refresh(.T.)

		nMan := 0

		oRegua:SetRegua1( nTotReg )
		oRegua:SetRegua2(0)

		TMPSQL->( DbGotop() )

		While .not. TMPSQL->( Eof() )

			if lEnd

				MsgStop("*** Cancelado pelo Operador ***","Fim")
				Exit

			endif

			//			IncProc("Processando "+TMP->CHAVE)
			oRegua:IncRegua1("Processando Download das Chaves Novamente")
			oRegua:IncRegua2(TMPSQL->CHAVE)

			if .not. empty( TMPSQL->OK ) .and. TMPSQL->ST <> "1"  // == cMarcaOK

				If pReg == 0

					pReg := TMPSQL->( Recno() )

				EndIf

				cCnpj  := TMPSQL->DEST

				cIdEnt := iif( .Not. Empty(TMPSQL->IDENT), AllTrim(TMPSQL->IDENT), cIdEnt )

				lTem   := .T.

				if Substr(TMPSQL->CHAVE,21,2) $ "57,67"

					//aqui n„o tem CTE sÛ NFE

				Else

					cChave += TMPSQL->CHAVE+";"
					cNsu55 := TMPSQL->NSU

				Endif

				nChv++

				if cAmb <> "1"

					cAmb := TMPSQL->AMB

				endif

				RecLock( "TMPSQL", .F. )
				TMPSQL->OK := "Pr"
				TMPSQL->( MsUnLock() )

			endif

			TMPSQL->( DbSkip() )

			If nChv >= 1 .Or. ( nChv >= 1 .and. TMPSQL->( Eof() ) )

				nRet := HFXML06Bai(cCnpj,cChave,cAmb,cIdEnt)
				//nRet := U_HFDOWDFE( cCnpj,cChave,cAmb,cIdEnt,cNsu55,"" )  //teste

				If nRet == 3 .or. nRet == 1  //Refazer

					Sleep(1500) //da 1 segundo e vai de novo

					nRet := HFXML06B55(cCnpj,cChave,cAmb,cIdEnt,cNsu55,"")   //HFXML06Bai(cCnpj,cChave,cAmb,cIdEnt)

					If nRet == 3

						aadd( a137, {cChave,cNsu55} )
						nRet := 2

					Endif

				Endif

				if xRet <> 1

					if nRet == 1

						xRet := nRet

					Else

						if xRet <> 0

							xRet := nRet

						endif

					Endif

				Endif

				nChv := 0
				pReg := 0
				cChave := ""

			EndIf

		Enddo

	endif

	nErr += nMan

endif

//Qtd de registros 137
nTotLen := Len(a137)

if nTotLen > 0

	oMarkBw:oBrowse:Refresh(.T.)

	if U_MyAviso("Pergunta","Existem Chaves n„o encontradas (137) que podem existir na SEFAZ. Deseja fazer o Download, dessas chaves, Novamente?",{"SIM","NAO"},2) == 1

		DbSelectArea( "TMPSQL" )
		TMPSQL->( DbSetOrder(1) )
		TMPSQL->( DbGotop() )

		//		ProcRegua( Len(a137) )
		oRegua:SetRegua1( nTotLen )
		oRegua:SetRegua2(0)

		For n137 := 1 To nTotLen

			//IncProc("Processando "+a137[n137])
			if lEnd

				MsgStop("*** Cancelado pelo Operador ***","Fim")
				Exit

			endif

			oRegua:IncRegua1("Processando Download das Chaves")
			oRegua:IncRegua2( a137[n137][1] )
			TMPSQL->( DbSeek( a137[n137][1] ) )

			pReg   := TMPSQL->( Recno() )
			cCnpj  := TMPSQL->DEST
			cIdEnt := iif( .Not. Empty(TMPSQL->IDENT), AllTrim(TMPSQL->IDENT), cIdEnt )
			cAmb   := TMPSQL->AMB
			cChave := a137[n137][1]
			cNsu55 := a137[n137][2]
			
			Sleep(1500) //da 1 segundo e vai de novo

			nRet   := HFXML06Bai(cCnpj,cChave,cAmb,cIdEnt)

			If nRet == 3 //Refazer

				Sleep(1500) //da 1 segundo e vai de novo

				nRet := HFXML06B55(cCnpj,cChave,cAmb,cIdEnt,cNsu55,"")   //HFXML06Bai(cCnpj,cChave,cAmb,cIdEnt)

			Endif

		Next n137

	Endif

Endif

if !lEnd

	If yRet == 1  //Tem Chaves CTe n„o encontrada

		oMarkBw:oBrowse:Refresh(.T.)
		U_MyAviso("AtenÁ„o - CTE","Existem Chaves CTe n„o encontrada. Execute rotina de Download por CNPJ dos CTEs?", {"OK"},2)

	Endif

	If nDow == 0

		U_MyAviso("Msg","OperaÁ„o com erros, verifique as Mensagens.",{"OK"},3)

	Elseif nErr == 0

		U_MyAviso("Msg","OperaÁ„o concluida com exito, verifique as Mensagens e os arquivos baixados na pasta "+cDir+".",{"OK"},3)

	Else

		U_MyAviso("Msg","OperaÁ„o concluida com alguns erros, verifique as Mensagens e os arquivos baixados na pasta "+cDir+".",{"OK"},3)

	endif

Endif

RestArea( aArea )

TMPSQL->( DbGoto( nReg ) )

oMarkBw:oBrowse:Refresh(.T.)

Return( NIL )


//Retorna 0 - OK
//Retorna 1 - Tem alguma manifestaÁıes para fazer
//Retorna 2 - SÛ Erro
//Renorna 3 - 137-NENHUM DOCUMENTO LOCALIZADO, sÛ para fazer duplamente, tem que mandar como 1 tambÈm
Static Function HFXML06Bai(cCnpj,cChave,cAmb,cIdEnt,lMnf)

Local nReg   := TMPSQL->( recno() )
Local nRet   := 0
Local nChv   := 0
Local cURL   := ""
Local cDir   := AllTrim(SuperGetMv("MV_X_PATHX"))
Local cXml   := ""
Local cNfe   := ""
Local cInfo  := ""
Local cMsg   := ""
Local cStt   := ""
Local lTodos := .F.
Local nHandle:= 0
Local lOk    := .T.
//Local cVerLayEven := "1.00"
//Local cHrVerao    := "2"
//Local cHorario    := "2"
Local nI        := 0 //declaracao
Local lHF       := .T.
Local cSt       := ""
Local cSitConf  := ""
Local cChaveXml := ""
Local cNf       := ""
Local cSer      := ""
Local cCnpjXml  := ""
Local cRej      := ""
Local lManifestou := .F.
Local cIE       := ""
Local _cFil     := ""

Default lMnf := .F.

Private cMsgTag  := ""
Private oWs,oWsrNfe,oWsdNfe
Private cErro    := ""
Private cWarning := ""

if lMnf

	If GetNewPar("XM_MANAUT","N") == "S"

		nRet := U_HF2MFXml( Substr(cChave,1,44), "210210", @cRej, "", 2 )

		if nRet == 0

			lManifestou := .T.

		endif

	endif

endif

cURL      := AllTrim(GetNewPar("XM_URL",""))

If Empty(cURL)

	cURL  := AllTrim(SuperGetMv("MV_SPEDURL"))

EndIf

If Right( AllTrim(cURL), 1 ) != "/"

	cURL := AllTrim(cURL)+"/"

EndIf

if lHF

	oWSdNfe:= WSHFXMLNFEDISTRIBUICAODFE():New()
	oWSdNfe:Init()
	oWSdNfe:cCIDENT       := cIdEnt
	oWSdNfe:cCCURL        := cURL
	oWSdNfe:cCAMBIENTE    := cAmb
	oWSdNfe:cCVERSAODADOS := "1.01" //esse È a parada cVerLayEven
	oWSdNfe:cCCUF         := substr(cChave,1,2) //"AN"  //ver isso aqui, È o Estado, agora vem de 1 em 1
	oWSdNfe:cCCNPJ        := cCnpj
	oWSdNfe:cCNSU         := ""
	oWSdNfe:cCCHSTR       := Substr(cChave,1,44)

	if oWSdNfe:HFNFEDISTRDFE()

		cXml := "<"+AllTrim(oWSdNfe:cHFNFEDISTRDFERESULT)
		nAt1 := At('<RETDISTDFEINT ',Upper(cXml))
		nAt2 := At('</RETDISTDFEINT>',Upper(cXml))+ 16

		//Corpo do XML
		If nAt1 <= 0

			nAt1 := At('<RETDISTDFEINT>',Upper(cXml))

		EndIf

		If nAt1 > 0 .And. nAt2 > 16

			cNfe := Substr(cXml,nAt1,nAt2-nAt1)

			cXml := '<?xml version="1.0" encoding="UTF-8"?>'
			cXml += cNfe

			cXml := EncodeUTF8(cXml)

			//Primeiro parse sem checagem de caracteres especiais
			if Len(cXml) >= 65534

				oWSrNfe := U_PARSGDE( cXml, @cErro, @cWarning )

			Else

				oWSrNfe := XmlParser( cXml, "_", @cErro, @cWarning )

			endif

			//Caso for nil faz a segunda checagem somente para aqueles xml¥s que tem caracteres especiais
			if oWSrNfe == NIL 

				//Faz backup do xml sem retirar os caracteres especiais
				cBkpXml := cXml

				cXml := fWNOAccent(cXml)  //NoAcento(cXml)
				cXml := EncodeUTF8(cXml)

				//Executa rotina para retirar os caracteres especiais
				cXml := u_zCarEspec( cXml )

				if Len(cXml) >= 65534

					oWSrNfe := U_PARSGDE( cXml, @cErro, @cWarning )

				Else

					oWSrNfe := XmlParser( cXml, "_", @cErro, @cWarning )

				endif

				//retorna o backup do xml
				cXml := cBkpXml

			endif

			If oWSrNfe == NIL .Or. !Empty(cErro) .Or. !Empty(cWarning)

				cMsg   := "Erro Parser do XML de Resposta"
				cInfo  := cErro + " " + cWarning
				lTodos := .T.
				nRet   := 2
				nOrd   := (xZBZ)->( IndexOrd() )
				cSitConf  := manifver(substr(cChave,1,44),cURL,cIdEnt,cAmb)  //"4"
				cChaveXml := substr(cChave,1,44)
				cNf       := Substr( cChaveXml, 26, 9 )
				cSer      := Substr( cChaveXml, 23, 3 )
				cCnpjXml  := Substr( cChaveXml, 07, 14 )
				cIE       := ""

				( xZBZ )->( DbSetOrder( 3 ) )

				If ( xZBZ )->(dbSeek( cChaveXml ) )

					cSt := "10"

				Else

					cSt := "99"

				Endif

				( xZBZ )->( DbSetORder( nOrd ) )

				nHdl := -1

				If U_HFTrvXml("TRAVA", "ZBS"+cChaveXml, @nHdl)

					( xZBS )->( DbSetOrder( 3 ) )

					If .Not. ( xZBS )->(dbSeek( cChaveXml ) )

						if !Empty( cIE )

							_cFil := u_Gravafil( cCnpj, cIE )

							if Empty( xFilial(xZBS) )  //Verifica se for compartilhado

								_cFil := xFilial( xZBS )

							endif

						else

							_cFil := xFilial( xZBS )

						endif

						RecLock(xZBS, .T. )

						( xZBS )->(FieldPut(FieldPos(xZBS_+"FILIAL"),  _cFil ))
						( xZBS )->(FieldPut(FieldPos(xZBS_+"CHAVE")	,  cChaveXml ))
						( xZBS )->(FieldPut(FieldPos(xZBS_+"AMB")	,  cAmb ))
						( xZBS )->(FieldPut(FieldPos(xZBS_+"DEST")	,  cCnpj ))
						( xZBS )->(FieldPut(FieldPos(xZBS_+"IDENT")	,  cIdEnt ))

						If ( xZBS )->( FieldPos(xZBS_+"MODELO") ) > 0

							( xZBS )->(FieldPut(FieldPos(xZBS_+"MODELO"), Substr(cChaveXml,21,2) ))

						EndIF

						if (xZBS)->(FieldPos(xZBS_+"TPROT")) > 0 //Tipo de Rotina Job ou Manual

							if Empty(  (xZBS)->(FieldGet(FieldPos(xZBS_+"TPROT"))) )

								if Type("cTpRt") <> "U"

									(xZBS)->(FieldPut(FieldPos(xZBS_+"TPROT"), cTpRt ))

								endif

							endif

						endif

					Else

						RecLock(xZBS, .F. )

						if ! Empty( ( xZBS )->(FieldGet(FieldPos(xZBS_+"DEMI"))) ) .And. ( xZBS )->(FieldGet(FieldPos(xZBS_+"DEMI"))) < (dDataBase - 90)

							if cSt == "99"  //N„o aparecer, È muito velho o Bixo

								cSt := ( xZBS )->(FieldGet(FieldPos(xZBS_+"ST")))

							endif

						Endif

					Endif

					if ! Empty( ( xZBS )->(FieldGet(FieldPos(xZBS_+"CSITCO"))) )

						if cSitConf == "4" .And. ( xZBS )->(FieldGet(FieldPos(xZBS_+"CSITCO"))) > "0"

							cSitConf := ( xZBS )->(FieldGet(FieldPos(xZBS_+"CSITCO")))

						Else

							if ( xZBS )->(FieldGet(FieldPos(xZBS_+"CSITCO"))) > cSitConf

								cSitConf := ( xZBS )->(FieldGet(FieldPos(xZBS_+"CSITCO")))

							Endif

						Endif

					Endif

					( xZBS )->(FieldPut(FieldPos(xZBS_+"ST")	, cSt ))
					( xZBS )->(FieldPut(FieldPos(xZBS_+"CSITCO"), cSitConf ))
					( xZBS )->(FieldPut(FieldPos(xZBS_+"CNF")	, cNf ))
					( xZBS )->(FieldPut(FieldPos(xZBS_+"SERIE")	, cSer ))
					( xZBS )->(FieldPut(FieldPos(xZBS_+"CNPJEM"), cCnpjXml ))
					( xZBS )->(MsUnLock())

					U_HFTrvXml("SOLTA", "ZBS"+cChaveXml, nHdl) //SOLTAR

				Endif

				//U_MyAviso("SPED",cInfo,{"OK"},3)

			elseIf oWSrNfe:_RETDISTDFEINT:_CSTAT:TEXT <> "138" //.And. oWSrNfe:_RETDISTDFEINT:_CSTAT:TEXT <> "137"//"139"

				cMsg   := "Retorno do Sefaz "+oWSrNfe:_RETDISTDFEINT:_CSTAT:TEXT
				cInfo  := oWSrNfe:_RETDISTDFEINT:_XMOTIVO:TEXT
				lTodos := .T.

				if oWSrNfe:_RETDISTDFEINT:_CSTAT:TEXT = "137"  //aqui pode ser falta de manifestaÁ„o tambÈm

					nRet  := 3   //volta o 3 para tentar por DFE em 10/09/18
					cInfo := Upper(cInfo+"("+oWSrNfe:_RETDISTDFEINT:_CSTAT:TEXT+")")  //"DOCUMENTO N√O DISPONIVEL PARA DOWNLOAD VIA WEB SERVICE (DF-e)"

				Else

					nRet := 2

				EndIf

				if oWSrNfe:_RETDISTDFEINT:_CSTAT:TEXT = "656"  //Consumo indevido

					nRet  := 3   //volta o 3 para tentar por DFE em 10/09/18
					cInfo := Upper(cInfo+"("+oWSrNfe:_RETDISTDFEINT:_CSTAT:TEXT+")")  //"Consumo Indevido"

					if !IsBlind()
						U_MyAviso("HFXML06Bai",cMsg+CRLF+cInfo,{"OK"},3)
					else
						Conout("HFXML06Bai"+CRLF+cMsg+CRLF+cInfo)
					endif

					Return(nRet)

				Else

					nRet := 2

				EndIf

				nOrd      := (xZBZ)->( IndexOrd() )
				cSitConf  := manifver(substr(cChave,1,44),cURL,cIdEnt,cAmb)  //"4"
				cChaveXml := substr(cChave,1,44)
				cNf       := Substr( cChaveXml, 26, 9 )
				cSer      := Substr( cChaveXml, 23, 3 )
				cCnpjXml  := Substr( cChaveXml, 07, 14 )
				cIE       := ""

				( xZBZ )->( DbSetOrder( 3 ) )
				If ( xZBZ )->(dbSeek( cChaveXml ) )

					cSt := "10"

				Elseif oWSrNfe:_RETDISTDFEINT:_CSTAT:TEXT = "653"

					cSt := "21"
				else

					cSt := "99"

				endif

				if oWSrNfe:_RETDISTDFEINT:_CSTAT:TEXT = "653"

					cSt := "21"					

				Endif

				( xZBZ )->( DbSetORder( nOrd ) )

				nHdl := -1

				If U_HFTrvXml("TRAVA", "ZBS"+cChaveXml, @nHdl)

					( xZBS )->( DbSetOrder( 3 ) )

					If .Not. ( xZBS )->(dbSeek( cChaveXml ) )

						if !Empty( cIE )

							_cFil := u_Gravafil( cCnpj, cIE )

							if Empty( xFilial(xZBS) )  //Verifica se for compartilhado

								_cFil := xFilial( xZBS )

							endif

						else

							_cFil := xFilial( xZBS )

						endif

						RecLock(xZBS, .T. )

						( xZBS )->(FieldPut(FieldPos(xZBS_+"FILIAL"),  _cFil ))
						( xZBS )->(FieldPut(FieldPos(xZBS_+"CHAVE")	,  cChaveXml ))
						( xZBS )->(FieldPut(FieldPos(xZBS_+"AMB")	,  cAmb ))
						( xZBS )->(FieldPut(FieldPos(xZBS_+"DEST")	,  cCnpj ))
						( xZBS )->(FieldPut(FieldPos(xZBS_+"IDENT")	,  cIdEnt ))

						If ( xZBS )->( FieldPos(xZBS_+"MODELO") ) > 0

							( xZBS )->(FieldPut(FieldPos(xZBS_+"MODELO"), Substr(cChaveXml,21,2) ))

						EndIF

						if (xZBS)->(FieldPos(xZBS_+"TPROT")) > 0 //Tipo de Rotina Job ou Manual

							if Empty(  (xZBS)->(FieldGet(FieldPos(xZBS_+"TPROT"))) )

								if Type("cTpRt") <> "U"

									(xZBS)->(FieldPut(FieldPos(xZBS_+"TPROT"), cTpRt ))

								endif

							endif

						endif

					Else

						RecLock(xZBS, .F. )

						if ! Empty( ( xZBS )->(FieldGet(FieldPos(xZBS_+"DEMI"))) ) .And. ( xZBS )->(FieldGet(FieldPos(xZBS_+"DEMI"))) < (dDataBase - 90)

							if cSt == "99"  //N„o aparecer, È muito velho o Bixo

								cSt := ( xZBS )->(FieldGet(FieldPos(xZBS_+"ST")))

							endif

						Endif

					Endif

					if ! Empty( ( xZBS )->(FieldGet(FieldPos(xZBS_+"CSITCO"))) )

						if cSitConf == "4" .And. ( xZBS )->(FieldGet(FieldPos(xZBS_+"CSITCO"))) > "0"

							cSitConf := ( xZBS )->(FieldGet(FieldPos(xZBS_+"CSITCO")))

						Else

							if ( xZBS )->(FieldGet(FieldPos(xZBS_+"CSITCO"))) > cSitConf

								cSitConf := ( xZBS )->(FieldGet(FieldPos(xZBS_+"CSITCO")))

							Endif

						Endif

					Endif

					( xZBS )->(FieldPut(FieldPos(xZBS_+"ST")	, cSt ))
					( xZBS )->(FieldPut(FieldPos(xZBS_+"CSITCO"), cSitConf ))
					( xZBS )->(FieldPut(FieldPos(xZBS_+"CNF")	, cNf ))
					( xZBS )->(FieldPut(FieldPos(xZBS_+"SERIE")	, cSer ))
					( xZBS )->(FieldPut(FieldPos(xZBS_+"CNPJEM"), cCnpjXml ))

					if oWSrNfe:_RETDISTDFEINT:_CSTAT:TEXT = "653"

						( xZBS )->(FieldPut(FieldPos(xZBS_+"CSITNF"), "3" ))

					endif

					( xZBS )->(FieldPut(FieldPos(xZBS_+"DHRECB"), dDataBase ))
					( xZBS )->(MsUnLock())

					U_HFTrvXml("SOLTA", "ZBS"+cChaveXml, nHdl) //SOLTAR

				Endif

				if oWSrNfe:_RETDISTDFEINT:_CSTAT:TEXT = "653"

					//Baixar as Canceladas
					nRet := U_HFXMLCAN(cCnpj,cChaveXml,cAmb,cIdEnt,"","",.F.,@cInfo)

					if nRet > 0

						cStt := "0"

					else

						cStt := "1"

						cMsg  := "XML cancelado inserido sucesso"

					endif

				endif

			Else

				oDet := oWSrNfe:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP

				oDet := iif( valtype(oDet)=="O", {oDet}, oDet )

				nTotLen := len( oDet )

				For nI := 1 to nTotLen  //Deixar assim para quando for mais de 1, mas agora tem que ser de 1 em 1.

					cStt  := ""
					cMsg  := ""
					cInfo := ""

					if Empty( oDet )

						if !IsBlind()
							U_MyAviso("HFXML06Bai","Objeto do sefaz vazio",{"OK"},3)
						else
							Conout("HFXML06Bai - Objeto do sefaz vazio")
						endif

						Exit

					endif

					cFileZip	:= Decode64( oDet[nI]:TEXT )
					nLenZip		:= Len( cFileZip )
					cFileUnZip  := ""

					// Funcao de descompactacao de arquivos compactados no formato GZip
					lOk  :=  GzStrDecomp( cFileZip, nLenZip, @cFileUnZip )
					oXml := XmlParser( cFileUnZip, "_", @cErro, @cWarning )

					//AlteraÁ„o em 13/04/2017, erro SalOnline
					If UPPER(Substr(oDet[nI]:_SCHEMA:TEXT,1,7)) <> UPPER("procNFe") //"139"

						if lManifestou

							cMsg	:=	"XXX"
							cInfo	:=	"XML encontrado È o Resumido."

						Else

							cMsg	:=	"633"
							cInfo	:=	"Falta ManifestaÁ„o do Destinat·rio."

						Endif

						cStt	:=	"0"

					ElseIf valtype(oXml) <> "O"

						cMsg	:=	"XXX"
						cInfo	:=	"N„o foi possÌvel Descompactar o XML."
						cStt	:=	"0"

					Else

						cChaveArq := cDir + Substr(cChave,1,44) + "-procNfe.xml" //alltrim( oDet[nI]:_CHNFE:TEXT ) + "-procNfe.xml"
						//SAVE oXML XMLFILE cChave

						SAVE oXml XMLSTRING cXML

						nAt1:= At('<NFE ',Upper(cXml))
						nAt2:= At('</NFE>',Upper(cXml))+ 6

						//Corpo da Nfe
						If nAt1 <=0

							nAt1:= At('<NFE>',Upper(cXml))

						EndIf

						If nAt1 > 0 .And. nAt2 > 6

							cNfe := Substr(cXml,nAt1,nAt2-nAt1)

						Else

							cStt  := "0"
							cMsg  := "Xml Retorno Inv·lido"
							cInfo := "XML "+cChave+" sem TAG <NFE>"

						EndIf

						nAt3:= At('<PROTNFE ',Upper(cXml))
						nAt4:= At('</PROTNFE>',Upper(cXml))+ 10

						//Protocolo
						If nAt3 > 0 .And. nAt4 > 10

							cProt := Substr(cXml,nAt3,nAt4-nAt3)

						Else

							cStt  := "0"
							cMsg  := "Xml Retorno Inv·lido"
							cInfo += "XML "+cChave+" sem Protocolo, falta TAG <PROTNFE>"

						EndIf

						if empty( cMsg )

							//cXml:= '<?xml version="1.0"?>'
							cXml := '<?xml version="1.0" encoding="UTF-8"?>'
							cXml += '<nfeProc versao="2.00" xmlns="http://www.portalfiscal.inf.br/nfe">'
							cXml += cNfe
							cXml += cProt
							cXml += '</nfeProc>'
							cXml := EncodeUTF8(cXml)
							cXml := FwNoAccent(cXml)

							//Faz backup do xml sem retirar os caracteres especiais
							cBkpXml := cXml

							//Executa rotina para retirar os caracteres especiais
							cXml := u_zCarEspec( cXml )

							if Len(cXml) >= 65534

								oXML := U_PARSGDE( cXml, @cErro, @cWarning )

							Else

								oXml := XmlParser( cXml, "_", @cErro, @cWarning )

								if oXML == NIL 

									oXml := XmlParser( cFileUnZip, "_", @cErro, @cWarning )

									cXml := cFileUnZip

								endif

							endif

							//retorna o backup do xml
							cXml := cBkpXml

							if oXML == NIL //.Or. !Empty(cErro) .Or. !Empty(cWarning)

								cStt  := "0"
								cMsg  := "Erro Parser do XML"
								cInfo := "Erro Parser: " + cErro + " " + cWarning

							Else

								SAVE oXML XMLFILE cChaveArq

								nHandle := FT_FUse( cChaveArq )

								if nHandle == -1

									cStt  := "0"
									cMsg  := "Erro GravaÁ„o"
									cInfo := "Erro de GravaÁ„o XML no DiretÛrio "+cChave

									if !IsBlind()

										U_MyAviso("HFXML06Bai",cMsg+" - "+cInfo,{"OK"},3)

									else

										Conout("HFXML06Bai",cMsg+" - "+cInfo)

									endif 

								else

									cStt  := "1"
									cMsg  := "Download Efetuado"
									cInfo := "Download Efetuado do XML "+Substr(cChave,1,44)

								endif

								FT_FUSE()

								if cStt == "1"

									if ! slvxmlzbz(Substr(cChave,1,44) + "-procNfe.xml", .T.,.F.,NIL,"",0, "2", Substr(cChave,1,44), @cInfo )  //2=Downlaod Sefaz

										cStt := "0"
										cMsg  := "Erro na ImportaÁ„o"

									endif

								Endif

							EndIf

						Endif

					Endif

					if cStt == "1"

						nDow++

					else

						if alltrim(cMsg) == "633" //Falta de ManifestaÁ„o

							nMan++

						Else

							nErr++

						EndIf

					endif

					If TMPSQL->(dbSeek( Substr(cChave,1,44) ) )

						if alltrim(cMsg) == "633" //Falta de ManifestaÁ„o

							nRet := 1

						endif

						if cStt <> "1" .and. nRet <> 1

							nRet := 2

						endif

						RecLock( "TMPSQL", .F. )

						if alltrim(cMsg) != "633" //Deixa marcado
							TMPSQL->OK    := "  "
						endif

						TMPSQL->ST    := cStt
						TMPSQL->MSG   := cMsg
						TMPSQL->ERRO  := cInfo
						TMPSQL->( MsUnLock() )

					endif

					DelClassIntf()

				Next nI

			Endif

		Else

			cMsg  := "Erro de retorno do Sefaz."
			cInfo := "Erro de retorno do Sefaz. XML de retorno n„o contÈm a TAG <RETDOWNLOADNFE>"
			//U_MyAviso("SPED",cInfo,{"OK"},3)
			lTodos := .T.
			nRet   := 2

		EndIf

	else

		//Erro TSS ou WS n„o instalado.
		//nRet  := 2
		//cInfo := IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
		//cMsg  := "Erro TSS ou WS"
		//U_MyAviso("SPED",cInfo,{"OK"},3)
		lTodos := .T.
		nOrd   := (xZBZ)->( IndexOrd() )
		cSitConf  := manifver(substr(cChave,1,44),cURL,cIdEnt,cAmb)  //"4"
		cChaveXml := substr(cChave,1,44)
		cNf       := Substr( cChaveXml, 26, 9 )
		cSer      := Substr( cChaveXml, 23, 3 )
		cCnpjXml  := Substr( cChaveXml, 07, 14 )
		cIE       := ""

		( xZBZ )->( DbSetOrder( 3 ) )
		If ( xZBZ )->(dbSeek( cChaveXml ) )

			cSt := "10"

		Else

			cSt := "99"

		Endif

		( xZBZ )->( DbSetORder( nOrd ) )

		nHdl := -1

		If U_HFTrvXml("TRAVA", "ZBS"+cChaveXml, @nHdl)

			( xZBS )->( DbSetOrder( 3 ) )

			If .Not. ( xZBS )->(dbSeek( cChaveXml ) )

				if !Empty( cIE )

					_cFil := u_Gravafil( cCnpj, cIE )

					if Empty( xFilial(xZBS) )  //Verifica se for compartilhado

						_cFil := xFilial( xZBS )

					endif

				else

					_cFil := xFilial( xZBS )

				endif

				RecLock(xZBS, .T. )

				( xZBS )->(FieldPut(FieldPos(xZBS_+"FILIAL"),  _cFil ))
				( xZBS )->(FieldPut(FieldPos(xZBS_+"CHAVE")	,  cChaveXml ))
				( xZBS )->(FieldPut(FieldPos(xZBS_+"AMB")	,  cAmb ))
				( xZBS )->(FieldPut(FieldPos(xZBS_+"DEST")	,  cCnpj ))
				( xZBS )->(FieldPut(FieldPos(xZBS_+"IDENT")	,  cIdEnt ))

				If ( xZBS )->( FieldPos(xZBS_+"MODELO") ) > 0

					( xZBS )->(FieldPut(FieldPos(xZBS_+"MODELO"), Substr(cChaveXml,21,2) ))

				EndIF

				if (xZBS)->(FieldPos(xZBS_+"TPROT")) > 0 //Tipo de Rotina Job ou Manual

					if Empty(  (xZBS)->(FieldGet(FieldPos(xZBS_+"TPROT"))) )

						if Type("cTpRt") <> "U"

							(xZBS)->(FieldPut(FieldPos(xZBS_+"TPROT"), cTpRt ))

						endif

					endif

				endif

			Else

				RecLock(xZBS, .F. )

				if ! Empty( ( xZBS )->(FieldGet(FieldPos(xZBS_+"DEMI"))) ) .And. ( xZBS )->(FieldGet(FieldPos(xZBS_+"DEMI"))) < (dDataBase - 90)

					if cSt == "99"  //N„o aparecer, È muito velho o Bixo

						cSt := ( xZBS )->(FieldGet(FieldPos(xZBS_+"ST")))

					endif

				Endif

			Endif

			if ! Empty( ( xZBS )->(FieldGet(FieldPos(xZBS_+"CSITCO"))) )

				if cSitConf == "4" .And. ( xZBS )->(FieldGet(FieldPos(xZBS_+"CSITCO"))) > "0"

					cSitConf := ( xZBS )->(FieldGet(FieldPos(xZBS_+"CSITCO")))

				Else

					if ( xZBS )->(FieldGet(FieldPos(xZBS_+"CSITCO"))) > cSitConf

						cSitConf := ( xZBS )->(FieldGet(FieldPos(xZBS_+"CSITCO")))

					Endif

				Endif

			Endif

			( xZBS )->(FieldPut(FieldPos(xZBS_+"ST")	, cSt ))
			( xZBS )->(FieldPut(FieldPos(xZBS_+"CSITCO"), cSitConf ))
			( xZBS )->(FieldPut(FieldPos(xZBS_+"CNF")	, cNf ))
			( xZBS )->(FieldPut(FieldPos(xZBS_+"SERIE")	, cSer ))
			( xZBS )->(FieldPut(FieldPos(xZBS_+"CNPJEM"), cCnpjXml ))

			( xZBS )->(MsUnLock())

			U_HFTrvXml("SOLTA", "ZBS"+cChaveXml, nHdl) //SOLTAR

		Endif

		nRet  := 2
		cInfo := IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
		cMsg  := cFilAnt + " Falha no momento de conectar com a url do sefaz"
		
		if GetNewPar("XM_VISFAL","") == "S"
			if !IsBlind()
				U_MyAviso("HFXML06Bai",cMsg+CRLF+cInfo,{"OK"},3)
			else
				Conout("HFXML06Bai"+CRLF+cMsg+CRLF+cInfo)
			endif
		else
			Conout("HFXML06Bai"+CRLF+cMsg+CRLF+cInfo)
		endif

	endif

Else

	//Futuramente direto do TSS
	oWSdNfe :=WSMANIFESTACAODESTINATARIO():New()
	oWSdNfe:cUserToken   := "TOTVS"
	oWSdNfe:cIDENT	     := cIdEnt
	oWSdNfe:cAMBIENTE	 := cAmb
	oWSdNfe:cINDNFE		 := "0"
	oWSdNfe:cINDEMI      := "0"
	oWSdNfe:_URL         := AllTrim(cURL)+"MANIFESTACAODESTINATARIO.apw"

	oWSdNfe:SINCRONIZARDOCUMENTOS()

	oWSdNfe:oWSDOCUMENTOS:oWSDOCUMENTO := MANIFESTACAODESTINATARIO_ARRAYOFBAIXARDOCUMENTO():New()

	nTotLen := aChave

	For nI := 1 To nTotLen

		aadd(oWSdNfe:oWSDOCUMENTOS:oWSDOCUMENTO:oWSBAIXARDOCUMENTO,MANIFESTACAODESTINATARIO_BAIXARDOCUMENTO():New())
		//cChave := Substr(cChave,1,44)
		oWSdNfe:oWSDOCUMENTOS:oWSDOCUMENTO:oWSBAIXARDOCUMENTO[nI]:CCHAVE := aChave[nI]

	Next nI

	if oWSdNfe:BAIXARXMLDOCUMENTOS()

		If Type("oWSdNfe:OWSBAIXARXMLDOCUMENTOSRESULT:OWSDOCUMENTORET:OWSBAIXARDOCUMENTORET") <> "U"

			If Type("oWSdNfe:OWSBAIXARXMLDOCUMENTOSRESULT:OWSDOCUMENTORET:OWSBAIXARDOCUMENTORET") == "A"

				oDet := oWSdNfe:OWSBAIXARXMLDOCUMENTOSRESULT:OWSDOCUMENTORET:OWSBAIXARDOCUMENTORET

			Else

				oDet := {oWSdNfe:OWSBAIXARXMLDOCUMENTOSRESULT:OWSDOCUMENTORET:OWSBAIXARDOCUMENTORET}

			Endif

			nTotLen := Len( oDet )

			For nI := 1 to nTotLen

				cXml := oDet[nI]:CNFEZIP

				If !Empty(cXml) .AND. !'<NFe' $ cXml

					cXml := Decode64(oDet[nI]:CNFEZIP)

				EndIf

				if oDet[nI]:CSTATUS <> "140"

					cMsg  := oDet[nI]:CSTATUS

					if !Empty(oDet[nI]:CCHVSTATUS)

						cInfo := oDet[nI]:CCHVSTATUS

					Else

						cInfo := "XML Retorno "+oDet[nI]:CCHAVE+" Vazio "

					EndIf

					cStt  := "0"

				ElseIf !Empty(cXml)

					cChave := cDir + alltrim( oDet[nI]:CCHAVE ) + "-procNfe.xml"

					nAt1:= At('<NFE ',Upper(cXml))
					nAt2:= At('</NFE>',Upper(cXml))+ 6

					//Corpo da Nfe
					If nAt1 <= 0

						nAt1:= At('<NFE>',Upper(cXml))

					EndIf

					If nAt1 > 0 .And. nAt2 > 6

						cNfe := Substr(cXml,nAt1,nAt2-nAt1)

					Else

						cStt  := "0"
						cMsg  := "Xml Retorno Inv·lido"
						cInfo := "XML "+oDet[nI]:CCHAVE+" sem TAG <NFE>"

					EndIf

					nAt3:= At('<PROTNFE ',Upper(cXml))
					nAt4:= At('</PROTNFE>',Upper(cXml))+ 10

					//Protocolo
					If nAt3 > 0 .And. nAt4 > 10

						cProt := Substr(cXml,nAt3,nAt4-nAt3)

					Else

						cStt  := "0"
						cMsg  := "Xml Retorno Inv·lido"
						cInfo += "XML "+oDet[nI]:CCHAVE+" sem Protocolo, falta TAG <PROTNFE>"

					EndIf

					if empty( cMsg )

						//cXml:= '<?xml version="1.0"?>'
						cXml := '<?xml version="1.0" encoding="UTF-8"?>'
						cXml += '<nfeProc versao="2.00" xmlns="http://www.portalfiscal.inf.br/nfe">'
						cXml += cNfe
						cXml += cProt
						cXml += '</nfeProc>'
						cXml := EncodeUTF8(cXml)
						cXml := FwNoAccent(cXml)
						
						//Faz backup do xml sem retirar os caracteres especiais
						cBkpXml := cXml

						//Executa rotina para retirar os caracteres especiais
						cXml := u_zCarEspec( cXml )

						oXml := XmlParser( cXml, "_", @cErro, @cWarning )

						//retorna o backup do xml
						cXml := cBkpXml

						if oXML == NIL //.Or. !Empty(cErro) .Or. !Empty(cWarning)

							cStt  := "0"
							cMsg  := "Erro Parser do XML"
							cInfo := cErro + " " + cWarning

						Else

							SAVE oXML XMLFILE cChave
							nHandle := FT_FUse( cChave )

							if nHandle == -1

								cStt  := "0"
								cMsg  := "Erro GravaÁ„o"
								cInfo := "Erro de GravaÁ„o XML no DiretÛrio "+cChave

								if !IsBlind()

									U_MyAviso("HFXML06Bai",cMsg+" - "+cInfo,{"OK"},3)

								else

									Conout("HFXML06Bai",cMsg+" - "+cInfo)

								endif 

							else

								cStt  := "1"
								cMsg  := "Download Efetuado"
								cInfo := "Download Efetuado do XML "+cChave

							endif

							FT_FUSE()

							if cStt == "1"

								if ! slvxmlzbz(cChave, .T.,.F.,NIL,"",0, "2", cChave, @cInfo )  //2=Downlaod Sefaz

									cStt  := "0"
									cMsg  := "Erro ImportaÁ„o"

								EndIf

							Endif

						EndIf

					Endif

				Else

					cStt  := "0"
					cMsg  := "Xml Retorno Vazio"
					cInfo += "XML Retorno "+oDet[nI]:CCHAVE+" Vazio "

				Endif

				If TMPSQL->(dbSeek( oDet[nI]:CCHAVE ) )

					if alltrim(cMsg) == "633" //Falta de ManifestaÁ„o

						nRet := 1

					endif

					if cStt <> "1" .and. nRet <> 1

						nRet := 2

					endif

					RecLock( "TMPSQL", .F. )

					if alltrim(cMsg) != "633" //Deixa marcado

						TMPSQL->OK    := "  "

					endif

					TMPSQL->ST    := cStt
					TMPSQL->MSG   := cMsg
						cInfo:= substr(cInfo,1,100)
					TMPSQL->ERRO  := cInfo
					TMPSQL->( MsUnLock() )

				endif

			Next nI

		Else

			cMsg := "Erro WS"

			cInfo   := IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))

			U_MyAviso("SPED",cInfo,{"OK"},3)

			lTodos := .T.

		EndIf

	Else

		cMsg := "Erro WS"

		cInfo   := IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))

		U_MyAviso("SPED",cInfo,{"OK"},3)

		lTodos := .T.

	EndIf

Endif

if lTodos

	TMPSQL->( DbGotop() )

	nChv := 0

	TMPSQL->( DbGoto( pReg ) )

	While .not. TMPSQL->( Eof() ) .And. nChv <= 1  //aqui antes era 10

		if TMPSQL->OK == "Pr" .and. TMPSQL->ST <> "1"  // == cMarcaOK

			RecLock( "TMPSQL", .F. )

			if nRet <> 1  //Deixa marcado

				TMPSQL->OK    := "  "

			Endif

			TMPSQL->ST    := cStt //"0"
			TMPSQL->MSG   := cMsg
				cInfo:= substr(cInfo,1,100)
			TMPSQL->ERRO  := cInfo

			TMPSQL->( MsUnLock() )

			nChv++

			if cStt == "1"

				nDow++

			else

				nErr++  //AQUIII

			endif

		endif

		TMPSQL->( dbskip() )

	End

endif

TMPSQL->( DbGoto( nReg ) ) //Volta ao Registro para dar continuidade

DelClassIntf()

Return( nRet )


//Tentar Baixar o 57
//Retorna 0 - OK
//Retorna 1 - N„o encontrou, tem que fazer o NFeDistr
//Retorna 2 - Encontrou na ZBS mas n„o conseguiu fazer o bixo
Static Function HFXML06B57(cCnpj,cChave,cAmb,cIdEnt)

Local nReg   := TMPSQL->( recno() )
Local nRet   := 1
//Local nChv   := 0
Local cDir   := AllTrim(SuperGetMv("MV_X_PATHX"))
Local cXml   := ""
Local cInfo  := ""
Local cMsg   := ""
Local cStt   := ""
Local nHandle:= 0
//Local lOk    := .T.
Local aAreaZBS := (xZBS)->( GetArea() )

Private oWs,oWsrNfe,oWsdNfe,cErro:="",cWarning:=""

(xZBS)->( dbSetOrder( 3 ) )

if (xZBS)->( dbSeek( Substr( cChave,1,44 ) ) )

	if (xZBS)->( FieldPos( xZBS_+"XML" ) ) > 0

		if ! Empty(( xZBS )->(FieldGet(FieldPos(xZBS_+"XML"))))

			cXml := ( xZBS )->(FieldGet(FieldPos(xZBS_+"XML")))

			nRet := 0

		endif

	endif

EndIF

if nRet == 0 //.And. !Empty( cXml )

	cChaveArq := cDir + Substr(cChave,1,44) + "-procCTe.xml"

	if Len(cXml) >= 65534
		oXML := U_PARSGDE( cXml, @cErro, @cWarning )
	Else
		oXml := XmlParser( cXml, "_", @cErro, @cWarning )
	endif

	if Empty(oXml)

		//Faz backup do xml sem retirar os caracteres especiais
		cBkpXml := cXml

		cXml := EncodeUTF8(cXml)
		cXml := FwNoAccent(cXml)

		//Executa rotina para retirar os caracteres especiais
		cXml := u_zCarEspec( cXml )

		if Len(cXml) >= 65534
			oXML := U_PARSGDE( cXml, @cErro, @cWarning )
		Else
			oXml := XmlParser( cXml, "_", @cErro, @cWarning )
		endif

		//retorna o backup do xml
		cXml := cBkpXml

	endif

	if oXML == NIL //.Or. !Empty(cErro) .Or. !Empty(cWarning)

		cStt  := "0"
		cMsg  := "Erro Parser do XML"
		cInfo := cErro + " " + cWarning

	Else

		SAVE oXML XMLFILE cChaveArq

		nHandle := FT_FUse( cChaveArq )

		if nHandle == -1

			cStt  := "0"
			cMsg  := "Erro GravaÁ„o"
			cInfo := "Erro de GravaÁ„o XML no DiretÛrio "+cChave

			if !IsBlind()

				U_MyAviso("HFXML06B57",cMsg+" - "+cInfo,{"OK"},3)

			else

				Conout("HFXML06B57",cMsg+" - "+cInfo)

			endif 

		else

			cStt  := "1"
			cMsg  := "Download Efetuado"
			cInfo := "Download Efetuado do XML "+Substr(cChave,1,44)

		endif

		FT_FUSE()

		if cStt == "1"

			if ! slvxmlzbz(Substr(cChave,1,44) + "-procCTe.xml", .T.,.F.,NIL,"",0, "2", Substr(cChave,1,44), @cInfo )  //2=Downlaod Sefaz

				cStt  := "0"

				cMsg  := "Erro ImportaÁ„o"

			EndIf

		Endif

	EndIf

Else

	nRet := 1
	cStt := "0"
	cMsg  := "XML N„o Encontrado"
	cInfo := "XML N„o Encontrado na Base. Executar rotina de consulta por CNPJ (CTe)."

Endif

if cStt == "1"

	nDow++

else

	nErr++

endif

If TMPSQL->(dbSeek( Substr(cChave,1,44) ) )

	if cStt <> "1" .and. nRet <> 1

		nRet := 2

	endif

	RecLock( "TMPSQL", .F. )

	TMPSQL->ST    := cStt
	TMPSQL->MSG   := cMsg
	cInfo:= SUBSTR(cinfo,1,100)
	TMPSQL->ERRO  := cInfo

	TMPSQL->( MsUnLock() )

endif

DelClassIntf()

(xZBS)->(RestArea( aAreaZBS ))

TMPSQL->( DbGoto( nReg ) ) //Volta ao Registro para dar continuidade

DelClassIntf()

Return( nRet )


//Tentar Baixar o 55 da ZBS
//Retorna 0 - OK
//Retorna 1 - N„o encontrou ou sem ManifestaÁ„o, tem que fazer o NFeDistr
//Retorna 2 - Encontrou na ZBS mas n„o conseguiu fazer
Static Function HFXML06B55(cCnpj,cChave,cAmb,cIdEnt,cNsu,cLogProc,lManif)

Local nReg   := TMPSQL->( recno() )
Local nRet   := 1
Local nChv   := 0
Local cDir   := AllTrim(SuperGetMv("MV_X_PATHX"))			// conte˙do: \xmlsource\
Local cXml   := ""
Local cInfo  := ""
Local cMsg   := ""
Local cStt   := ""
Local nHandle:= 0
//Local lOk    := .T.
Local aAreaZBS := (xZBS)->( GetArea() )
Local cRej   := ""

Default cLogProc := ""
Default lManif := .F.

Private oWs,oWsrNfe,oWsdNfe,cErro:="",cWarning:=""

Do While .T.

	(xZBS)->( dbSetOrder( 3 ) )

	if (xZBS)->( dbSeek( Substr( cChave,1,44 ) ) )

		if (xZBS)->( FieldPos( xZBS_+"XML" ) ) > 0

			if ! Empty(( xZBS )->(FieldGet(FieldPos(xZBS_+"XML"))))

				cXml := ( xZBS )->(FieldGet(FieldPos(xZBS_+"XML")))

				if upper("<resNFe ") $ upper( cXml )

					if ( xZBS )->(FieldGet(FieldPos(xZBS_+"DEST"))) <> cCnpj

						nRet := 2

					else

						nRet := 1  //Falta ManifestaÁ„o e depois tentar o NFe

					endif

					//					Alert( "Tem Sem Manif" )

				else

					nRet := 0

					if lManif

						If GetNewPar("XM_MANAUT","N") == "S"

							nRetManif := U_HF2MFXml( Substr(cChave,1,44), "210210", @cRej, "", 2 )

							if nRetManif == 0

								lManifestou := .T.

							endif

						endif

					endif

				endif

			endif

		endif

	EndIF

	nChv++

	if nRet <> 0 .And. nChv < 2

		//		Alert( "Vai por NSU "+cNsu )
		U_HFDOWDFE( cCnpj,cChave,cAmb,cIdEnt,cNsu,@cLogProc )   //Pedir ao SEFAZ por NSU

		Sleep(1500) //da 1 segundo e vai de novo

		Loop

	Endif

	Exit

EndDo

if nRet == 0 .or. nRet == 1  //.And. !Empty( cXml )

	if nRet == 1

		cChaveArq := cDir + Substr(cChave,1,44) + "-resuNFe.xml"

	else

		cChaveArq := cDir + Substr(cChave,1,44) + "-procNFe.xml"

	endif

	//Primeiro parse sem checagem de caracteres especiais
	if Len(cXml) >= 65534

		oXML := U_PARSGDE( cXml, @cErro, @cWarning )

	Else

		oXml := XmlParser( cXml, "_", @cErro, @cWarning )

	endif

	//Caso for nil faz a segunda checagem somente para aqueles xml¥s que tem caracteres especiais
	if oXML == NIL 

		//Faz backup do xml sem retirar os caracteres especiais
		cBkpXml := cXml

		cXml := fWNOAccent(cXml)  //NoAcento(cXml)
		cXml := EncodeUTF8(cXml)

		//Executa rotina para retirar os caracteres especiais
		cXml := u_zCarEspec( cXml )

		if Len(cXml) >= 65534

			oXML := U_PARSGDE( cXml, @cErro, @cWarning )

		Else

			oXml := XmlParser( cXml, "_", @cErro, @cWarning )

		endif

		//retorna o backup do xml
		cXml := cBkpXml

	endif

	if oXML == NIL //.Or. !Empty(cErro) .Or. !Empty(cWarning)

		cStt  := "0"
		cMsg  := "Erro Parser do XML"
		cInfo := "Falha ao gerar Objeto XML : " + cErro + " " + cWarning

	Else

		SAVE oXML XMLFILE cChaveArq

		nHandle := FT_FUse( cChaveArq )

		if nHandle == -1

			cStt  := "0"
			cMsg  := "Erro GravaÁ„o"
			cInfo := "Erro de GravaÁ„o XML no DiretÛrio "+cChave

			if !IsBlind()

				U_MyAviso("HFXML06B55",cMsg+" - "+cInfo,{"OK"},3)

			else

				Conout("HFXML06B55",cMsg+" - "+cInfo)

			endif 

		else

			cStt  := "1"
			cMsg  := "Download Efetuado"
			cInfo := "Download Efetuado do XML "+Substr(cChave,1,44)

		endif

		FT_FUSE()

		if cStt == "1"

			if nRet == 1

				if ! slvxmlzbz(Substr(cChave,1,44) + "-resuNFe.xml", .T.,.F.,NIL,"",0, "2", Substr(cChave,1,44), @cInfo, "R" )  //2=Downlaod Sefaz   R=Resumido

					cStt  := "0"
					cMsg  := "Erro ImportaÁ„o"

				else

					nRet := 0

				EndIf

			Else

				if ! slvxmlzbz(Substr(cChave,1,44) + "-procNFe.xml", .T.,.F.,NIL,"",0, "2", Substr(cChave,1,44), @cInfo, " " )  //2=Downlaod Sefaz

					cStt  := "0"
					cMsg  := "Erro ImportaÁ„o"

				EndIf

			Endif

		Endif

	EndIf

Else

	nRet := 1
	cStt := "0"
	cMsg  := "XML N„o Encontrado"
	//	cInfo := "XML N„o Encontrado na Base. Executar rotina de consulta por CNPJ (NFe)."

Endif

if cStt == "1"

	nDow++

else

	nErr++

endif

If TMPSQL->(dbSeek( Substr(cChave,1,44) ) )

	if cStt <> "1" .and. nRet <> 1
		nRet := 2
	endif

	RecLock( "TMPSQL", .F. )

	TMPSQL->ST    := cStt
	TMPSQL->MSG   := cMsg
		cInfo:= substr(cInfo,1,100)
	TMPSQL->ERRO  := cInfo

	TMPSQL->( MsUnLock() )

endif

DelClassIntf()

(xZBS)->(RestArea( aAreaZBS ))

TMPSQL->( DbGoto( nReg ) ) //Volta ao Registro para dar continuidade

Return( nRet )

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Fun??o    ≥HFXML06Chv≥ Autor ≥Eneovaldo Roveri Junior≥ Data ≥ 03/10/13 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒƒ›ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒ›ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descri??o ≥ Download das Chaves                                        ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ HFXML06Chv()                                               ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function HFXML06Chv(nChv)

Local oDlgKey, oBtnOut, oBtnCon
//Local cIdEnt    := ""
Local cChaveXml := AllTrim((xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))))  //iif(nChv == NIL .or. nChv > 0, space( Len(TMPSQL->CHAVE) ), Substr(AllTrim((xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE")))) + space(Len(TMPSQL->CHAVE)),1,Len(TMPSQL->CHAVE)) )
Local cModelo   := "55"
Local cProtocolo:= ""
Local cMensagem := ""
Local lRet      := .T.
Local cPref     := "NF-e"
Local cTAG      := "NFE"
Local cAmb      := "1"
Local cCodRet   := ""
Local lValidado := .F.
Local cURL      := ""
Local xCnpj     := ""
Local xIdEnt    := ""
Default nChv    := 0

cURL    := AllTrim(GetNewPar("XM_URL",""))

If Empty(cURL)

	cURL  := AllTrim(SuperGetMv("MV_SPEDURL"))

EndIf

If cModelo == "55"

	cPref   := "NF-e"
	cTAG    := "NFE"

ElseIf cModelo == "57"

	cPref   := "CT-e"
	cTAG    := "CTE"

EndIf

DEFINE MSDIALOG oDlgKey TITLE "Consulta "+cPref FROM 0,0 TO 150,305 PIXEL OF GetWndDefault()

@ 12,008 SAY "PrÛxima Chave de acesso do xml de "+cPref PIXEL OF oDlgKey
@ 20,008 MSGET cChaveXml SIZE 140,10 PIXEL OF oDlgKey

@ 46,035 BUTTON oBtnCon PROMPT "&Incluir" SIZE 38,11 PIXEL ACTION (lRet:=.T.,oDlgKey:End())
@ 46,077 BUTTON oBtnOut PROMPT "&Sair" SIZE 38,11 PIXEL ACTION (lRet:=.F.,oDlgKey:End())

ACTIVATE DIALOG oDlgKey CENTERED

If lRet

	if len( AllTrim( cChaveXml ) ) == 44 // Len( TMPSQL->CHAVE )

		IF u_HFXSEMA()

			//				MsgRun("Aguarde. Consultando Chave Sefaz...","Consultando Chave Sefaz",{|| lValidado := U_XConsXml(cURL,cChaveXml,cModelo,cProtocolo,@cMensagem,@cCodRet,.F.,@xCnpj,@xIdEnt,,.F.) } )
			MsgRun("Aguarde. Consultando Chave Sefaz...","Download Chave Sefaz",{|| lValidado := u_HFXNVMCHV(cChaveXml) } )

			//	HFXNVMCHV(_cChave)

			//U_HFXGRSEMA(alltrim(FUNNAME()),cChaveXml)
			U_HFXGRSEMA("HFXML06Chv",cChaveXml)

		ENDIF
		
	else

		cMensagem := "Chave deve conter 44 Characteres"
		cCodRet   := ""

	endif

EndIf

if cCodRet $ AllTrim(GetNewPar("XM_RETOK","526"))+",100,101,"+AllTrim(GetNewPar("XM_RETDEN","301,302,303")) 

	/*if .not. TMPSQL->( dbSeek( cChaveXml ) )

		if "HomologaÁ„o" $ cMensagem

			cAmb := "2"

		endif

		RecLock( "TMPSQL", .T. )

		TMPSQL->ST    := " "
		TMPSQL->CHAVE := cChaveXml
		TMPSQL->AMB   := cAmb
		TMPSQL->DEST  := iif( empty(xCnpj), SM0->M0_CGC, xCnpj ) //SM0->M0_CGC
		TMPSQL->CNF   := Substr(cChaveXml,26,9)
		TMPSQL->SERIE := Substr(cChaveXml,23,3)
		TMPSQL->IDENT := xIdEnt

		TMPSQL->( MsUnLock() )

		nChv++

		//U_MyAviso("Msg","Chave incluida com sucesso ",{"OK"},1)

	else

		U_MyAviso("AtenÁ„o","Chave J· IncluÌda",{"Continua"},1)

	endif*/

else

	if lRet .and. !Empty(cCodRet)

		U_MyAviso("Erro",cMensagem+CRLF+;
		"Cod. Retorno "+cCodRet,{"Continua"},3)

	endif

endif

Return( lRet )

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Fun??o    ≥HFXML06Cnp≥ Autor ≥Eneovaldo Roveri Junior≥ Data ≥ 23/05/14 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒƒ›ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒ›ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descri??o ≥ CNPJ para consulta                                         ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ HFXML06Cnp()                                               ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function HFXML06Cnp(nTipoMod)

Local oDlgKey, oBtnOut, oBtnCon
Local lRet      := .T.
Local lValidado := .T.
Local cCnpj     := "" //SM0->M0_CGC
Local cKeyF3    := SetKEY( VK_F3 ,  Nil )
Local nOpc      := 0 //aquiiiii
Local nMod      := 0 //Escolher 55-Nfe ou 57-Cte
Local oProcess	:=	Nil
Local cBkpFil   := ""
Local cEmp0     := cEmpAnt
Local cFil0     := cFilAnt
Local nReg0     := SM0->( recno() )

Default nTipoMod := 0

SM0->( dbSetOrder(1) )

If SM0->( dbSeek( cEmp0 + cFil0 ) )

	cCnpj := SM0->M0_CGC

Else

	SM0->( dbGoTo( nReg0 ) )

	cCnpj := SM0->M0_CGC

Endif

DEFINE MSDIALOG oDlgKey TITLE "Consulta CNPJ  [F3] Consulta" FROM 0,0 TO 150,305 PIXEL OF GetWndDefault()

SetKey( VK_F3, { || U_HFXML6SM(@cCnpj,@cEmp0,@cFil0) } )

@ 12,008 SAY "CNPJ para Consultar Chaves" PIXEL OF oDlgKey
@ 20,008 MSGET cCnpj Picture "@R 99.999.999/9999-99" SIZE 140,10 PIXEL OF oDlgKey //WHEN .F.

@ 46,035 BUTTON oBtnCon PROMPT "&Ok"   SIZE 38,11 PIXEL ACTION if(ChkCnpj(cCnpj,cEmp0,cFil0), (lRet:=.T.,oDlgKey:End()), lRet:=.F. )
@ 46,077 BUTTON oBtnOut PROMPT "&Sair" SIZE 38,11 PIXEL ACTION (lRet:=.F.,oDlgKey:End())

ACTIVATE DIALOG oDlgKey CENTERED

If lRet

	cBkpFil   := ""

	if cFil0 <> cFilAnt

		cBkpFil := cFilAnt

		cFilAnt := cFil0

	endif

/*Ã››››››››››ÿ››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››π±±
±±∫Uso       ≥ Valida se pode continuar com a requisiÁ„o ao SEFAZ        ∫±±
±±»›››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››º±±*/
U_HFXML072(cCnpj)
If !lConsCnpj
	lRet := .F.
		Return(lRet)
EndIf
	//Aqui mudado em 23/7 para escolher o Cte ou NFe
	nTipoMod := nMod := U_MyAviso("Modelo","Qual Modelo?",{"1-NF-e","2-CT-e"},3)

	if nMod == 1

		nOpc := U_MyAviso("OpÁ„o","1-Todos a partir do ultimo NSU "+CRLF+"2-SÛ N√O importados a partir do ultimo NSU",{"1-Todos","2-N„o Importados"},3)

		if nOpc == 1 .or. nOpc == 2

			//MsgRun("Aguarde. Consultando Cnpj (NF-e) Sefaz...","Consultando Cnpj (NF-e) Sefaz",{|| lValidado := U_HFXML6CD(cCnpj, .T., , nOpc, 0) } )
			oProcess := MsNewProcess():New({| lEnd | lValidado := U_HFXML6CD(cCnpj, .T., , nOpc, 0, @lEnd, oProcess)},"Aguarde. Consultando Cnpj (NF-e) Sefaz...","Consultando Cnpj (NF-e) Sefaz",.T.)

			oProcess:Activate()

			lRet := lValidado

		Endif

		//oProcess := MsNewProcess():New({| lEnd | lValidado := U_HFXML6BS(cCnpj, .T., , nOpc, "55", @lEnd, oProcess)},"Aguarde. Consultando XMLs a Sincronizar "+xZBS+"...","Consultando XMLs a Sincronizar",.T.)

		//oProcess:Activate()

		lRet := lValidado

	ElseIF nMod == 2

		nOpc := U_MyAviso("OpÁ„o","1-Todos a partir do ultimo NSU "+CRLF+"2-SÛ N√O importados a partir do ultimo NSU",{"1-Todos","2-N„o Importados"},3)

		if nOpc == 1 .or. nOpc == 2

			oProcess := MsNewProcess():New({| lEnd | lValidado := U_HFXML6DC(cCnpj, .T., , nOpc, 0, @lEnd, oProcess)},"Aguarde. Consultando Cnpj (CT-e) Sefaz...","Consultando Cnpj (CT-e) Sefaz",.T.)

			oProcess:Activate()

			lRet := lValidado

		Endif

		oProcess := MsNewProcess():New({| lEnd | lValidado := U_HFXML6BS(cCnpj, .T., , nOpc, "57", @lEnd, oProcess)},"Aguarde. Consultando XMLs a Sincronizar "+xZBS+"...","Consultando XMLs a Sincronizar",.T.)

		oProcess:Activate()

		lRet := lValidado

	EndIF

	if ! Empty( cBkpFil )

		cFilAnt := cBkpFil

	endif

EndIf

if .Not. lValidado

	U_MyAviso("Alerta","CNPJ n„o possui Chaves para Consultar"+CRLF+;
	"",{"Continua"},1)

else

	if nTipoMod == 1 .and. !Empty( oProcess )   //Tipo NFE
		
		U_MyAviso("Finalizado","Download finalizado com sucesso"+CRLF+;
		"",{"Fechar"},1)

	endif

endif

SetKEY( VK_F3 ,  cKeyF3 )

Return( lRet )


User Function HFX06man( oBrowse )

	HFXML06Man()

	if oBrowse <> NIL

		oBrowse:Refresh(.T.)

	endif

Return( NIL )

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Fun??o    ≥HFXML06Man≥ Autor ≥Eneovaldo Roveri Junior≥ Data ≥ 31/10/13 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒƒ›ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒ›ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descri??o ≥ ManifestaÁ„o do Destinatario                               ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ HFXML06Man()                                               ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function HFXML06Man( lBai, nEve )

Local nReg   := TMPSQL->( recno() )
Local lRet   := .F.
Local cChave := ""
Local cEvent := ""
Local cEve   := "210200"
Local cJust  := ""//Space(250)  //AQUIII
Local cxJst  := ""          //AQUIIII
Local nLote  := 1
Local nChv   := 0
Local cCnpj  := SM0->M0_CGC  //"61135471000100"
Local cURL   := ""
Local cXml   := ""
Local cNfe   := ""
Local cAmb   := ""
Local cIdEnt := U_GetIdEnt()
Local cInfo  := ""
Local cMsg   := ""
Local cStt   := ""
Local lTodos := .F.
//Local nHandle:= 0
Local lOk    := .T.
Local lTemPr := .F.
Local cVerLayEven := "1.00"
Local cHrVerao    := "2"
Local cHorario    := "2"
Local nAtraso     := 0
Local lLoop       := .F.
Local oWS,oWsrNfe,oWsdNfe,cErro:= "",cWarning:= ""
Local nI      := 0 //declaracao
Local cSeqEve := ""  //ZBEMANO
Local cKey    := ""  //ZBEMANO
Local aEvt    := {}  //Atualizar a ZBEMANO
Local cGrv    := ""  //SÛ Para Receber a Resposta

Private oDet //ZBEMANO

cURL    := AllTrim(GetNewPar("XM_URL",""))

If Empty(cURL)

	cURL  := AllTrim(SuperGetMv("MV_SPEDURL"))

EndIf

//DeNovo
If Right( AllTrim(cURL), 1 ) != "/"

	cURL := AllTrim(cURL)+"/"

EndIf

if lBai == NIL

	lBai := .F.

endif

if nEve == NIL

	nEve := 0

endif

If lBai

	if nEve <> 1 .and. nEve <> 2

		nEve := U_MyAviso("Pergunta","Deseja Manifestar como? "+CRLF+"1-Conf.OP->Confirmacao da Operacao ou "+CRLF+"2-Cien.Op->Ciencia da Operacao",{"1-Conf.OP","2-Cien.Op"},3)

	endif

	if nEve <> 1 .and. nEve <> 2

		nEve := 0

	endif

Else

	nEve := Manifesto("ManifestaÁ„o do Destinat·rio","ManifestaÁ„o do Destinat·rio",{"ConfirmaÁ„o da operaÁ„o","CiÍncia da operaÁ„o","Desconhecimento da operaÁ„o","OperaÁ„o n„o Realizada"},3)

EndIf

if nEve == 1

	cEve := "210200"

elseif nEve == 2

	cEve := "210210"

elseif nEve == 3

	cEve := "210220"

elseif nEve == 4

	cEve  := "210240"

else

	Return( lRet )

endif

TMPSQL->( DbGotop() )

While .not. TMPSQL->( Eof() ) .and. nChv < 10

	if .not. empty( TMPSQL->OK ) .And. TMPSQL->OK <> "Pt" // == cMarcaOK

		cCnpj  := TMPSQL->DEST
		cIdEnt := iif( .Not. Empty(TMPSQL->IDENT), AllTrim(TMPSQL->IDENT), cIdEnt )
		cChave += TMPSQL->CHAVE+";"
		cEvent += cEve+";"
		cJust  := space(250)

		if cEve == "210240"

			cJust := U_TelaJust( TMPSQL->CHAVE, cJust )  //GETESB2

			if cJust == "-1"

				exit

			endif

		endif

		cxJst += AllTrim(cJust)+";"

		nChv++

		if cAmb <> "1"

			cAmb := TMPSQL->AMB

		endif

		RecLock( "TMPSQL", .F. )

		TMPSQL->OK := "Pt"

		TMPSQL->( MsUnLock() )

	endif

	TMPSQL->( dbskip() )

End

if cJust == "-1"

	if .not. lBai

		U_MyAviso("Msg","OperaÁ„o cancelada por falta de justificativa!!!!",{"OK"},3)

	endif

	TMPSQL->( dbgoto( nReg ) )

	Return( lRet )

endif

if nChv <= 0

	if .not. lBai

		U_MyAviso("Msg","Nenhuma chave selecionada para Manifestar !!!!",{"OK"},3)

	endif

	TMPSQL->( dbgoto( nReg ) )

	return( .T. )

endif

oWS:=WsSpedCfgNfe():New()
oWS:cUSERTOKEN 	  	:= "TOTVS"
oWS:cID_ENT    		:= cIdEnt
oWS:nAMBIENTECCE	:= 0	// Atribuicao de '0', efetua a consulta do metodo
oWS:cVERCCELAYOUT	:= ""
oWS:cVERCCELAYEVEN	:= ""
oWS:cVERCCEEVEN		:= ""
oWS:cVERCCE			:= ""
oWS:cHORAVERAOCCE	:= ""
oWS:cHORARIOCCE		:= ""
oWS:_URL       		:= AllTrim(cURL)+"/SpedCfgNfe.apw"
lOk:=oWS:CfgCCe()

If lOk

	cVerLayEven	:= oWs:oWsCfgCCeResult:cVerCCeLayEven
	cHrVerao 	:= Left(oWS:oWsCfgCCeResult:cHoraVeraoCCe,1)
	cHorario 	:= Left(oWS:oWsCfgCCeResult:cHorarioCCe,1)

EndIf

If Right( AllTrim(cURL), 1 ) != "/"

	cURL := AllTrim(cURL)+"/"

EndIf

For nAtraso := 0 to 4

	// Tratamento da numeracao do lote
	rstmvbuff()

	nLote := ( GetNewPar("XM_LOTEMAN",0) + 1 )

	If !PutMv("XM_LOTEMAN",nLote)

		SX6->(RecLock("SX6",.T.))
		SX6->X6_FIL     := xFilial( "SX6" )
		SX6->X6_VAR     := "XM_LOTEMAN"
		SX6->X6_TIPO    := "N"
		SX6->X6_DESCRIC := "Lote do Evento de Manifestacao"
		SX6->(MsUnLock())

		PutMv("XM_LOTEMAN",nLote)

	EndIf

	oWSdNfe:= WSHFXMLMANIFESTO():New()
	oWSdNfe:Init()
	oWSdNfe:cCIDENT       := cIdEnt
	oWsdNfe:cCLOTE        := strzero(nLote,15,0)
	//oWSdNfe:_URL          := cURL
	oWSdNfe:cCCURL        := cURL
	oWSdNfe:cCAMBIENTE    := cAmb
	oWSdNfe:cCVERSAODADOS := cVerLayEven
	oWSdNfe:cCCUF         := "91"
	oWSdNfe:cCHORAVERAO   := cHrVerao
	oWSdNfe:cCHORARIO     := cHorario
	oWSdNfe:cCCNPJ        := cCnpj
	oWSdNfe:cCCHSTR       := cChave
	oWSdNfe:cCEVSTR       := cEvent
	oWSdNfe:cCXJUST       := cxJst  //AQUIIII
	oWSdNfe:cCDTHREVEN    := U_HFDTTIME( cHrVerao, cHorario, nAtraso )

	if oWSdNfe:HFMANISFESTO()

		cXml := oWSdNfe:cHFMANISFESTORESULT
		nAt1:= At('<RETENVEVENTO ',Upper(cXml))
		nAt2:= At('</RETENVEVENTO>',Upper(cXml))+ 15

		//Corpo do XML
		If nAt1 <=0

			nAt1:= At('<RETENVEVENTO>',Upper(cXml))

		EndIf

		If nAt1 > 0 .And. nAt2 > 15

			cNfe := Substr(cXml,nAt1,nAt2-nAt1)

			cXml := '<?xml version="1.0" encoding="UTF-8"?>'
			cXml += cNfe

			//Faz backup do xml sem retirar os caracteres especiais
			cBkpXml := cXml

			cXml := EncodeUTF8(cXml)
			cXml := FwNoAccent(cXml)

			//Executa rotina para retirar os caracteres especiais
			cXml := u_zCarEspec( cXml )

			cErro:= ""
			cWarning:= ""

			if Len(cXml) >= 65534

				oWSrNfe := U_PARSGDE( cXml, @cErro, @cWarning )

			Else

				oWSrNfe := XmlParser( cXml, "_", @cErro, @cWarning )

			endif

			//retorna o backup do xml
			cXml := cBkpXml

			If oWSrNfe == NIL //.Or. !Empty(cErro) .Or. !Empty(cWarning)

				cMsg   := "Erro Parser do XML de Resposta da ManifestaÁ„o"
				cInfo  := cErro + " " + cWarning
				lTodos := .T.

				if .not. lBai

					U_MyAviso("SPED",cInfo,{"OK"},3)

				endif

			elseIf oWSrNfe:_RETENVEVENTO:_CSTAT:TEXT <> "128"

				If (oWSrNfe:_RETENVEVENTO:_CSTAT:TEXT = "578" .or. oWSrNfe:_RETENVEVENTO:_CSTAT:TEXT = "703") .And. nAtraso < 4

					Sleep(1500) //da 1 segundo e vai de novo

					Loop

				EndIf

				cMsg   := "Retorno do Sefaz "+oWSrNfe:_RETENVEVENTO:_CSTAT:TEXT
				cInfo  := oWSrNfe:_RETENVEVENTO:_XMOTIVO:TEXT
				lTodos := .T.

				if .not. lBai

					U_MyAviso("SPED",cInfo,{"OK"},3)

				endif

			Else

				lLoop:= .F.

				oDet := oWSrNfe:_RETENVEVENTO:_RETEVENTO
				oDet := iif( valtype(oDet)=="O", {oDet}, oDet )

				nTotLen := Len( oDet )

				For nI := 1 to nTotLen

					if Type( "oDet["+AllTrim(Str(nI))+"]:_INFEVENTO:_CHNFE:TEXT" ) <> "U"

						cKey  := oDet[nI]:_INFEVENTO:_CHNFE:TEXT

					Else

						Sleep(1500) //da 1 segundo e vai de novo

						cKey  := ""

						Loop

					Endif

					cStt  := ""
					cMsg  := ""
					cInfo := ""

					if oDet[nI]:_INFEVENTO:_CSTAT:TEXT <> "135"

						if (oDet[nI]:_INFEVENTO:_CSTAT:TEXT = "578" .Or. oDet[nI]:_INFEVENTO:_CSTAT:TEXT = "703")  .And. nAtraso < 4

							Sleep(1500) //da 1 segundo e vai de novo

							lLoop:= .T.

							Loop

						Else

							cMsg  := oDet[nI]:_INFEVENTO:_CSTAT:TEXT
							cInfo := oDet[nI]:_INFEVENTO:_XMOTIVO:TEXT
							cStt  := "0"

						EndIF

					else

						cStt  := "2"
						cMsg  := "ManifestaÁ„o Efetuada"
						cInfo := "ManifestaÁ„o Efetuada do XML "+cKey

						lRet  := .T.  //se manifestou ao menos um vai .T. para refazer download
						aEvt    := {}     //ZBEMANO
						cSeqEve := ""     //ZBEMANO

						aEvt    := U_HF20ZBE( nI, @cSeqEve, cXml )
						cGrv    := U_HF2GrvEv( cKey, cEve, cSeqEve, aEvt, .T. )

					Endif

					If TMPSQL->(dbSeek( cKey ) )

						RecLock( "TMPSQL", .F. )

						if (cStt <> "2" .And. .not. ("573" $ cMsg) ) .or. .not. lBai
							TMPSQL->OK    := "  "
						endif

						TMPSQL->ST    := cStt
						TMPSQL->MSG   := cMsg
							cInfo:= substr(cInfo,1,100)
						TMPSQL->ERRO  := cInfo

						TMPSQL->( MsUnLock() )

					endif

				Next nI

				if lLoop

					Sleep(1500) //da 1 segundo e vai de novo

					Loop

				Endif

			Endif

		Else

			cMsg  := "Erro de retorno do Sefaz na ManifestaÁ„o."
			cInfo := "Erro de retorno do Sefaz. XML de retorno n„o contÈm a TAG <RETENVEVENTO>"

			if .not. lBai

				if GetNewPar("XM_VISFAL","") == "S"
					if !IsBlind()
						U_MyAviso("HFXML06Man",cMsg+CRLF+cInfo,{"OK"},3)
					else
						Conout("HFXML06Man"+CRLF+cMsg+CRLF+cInfo)
					endif
				else
					Conout("HFXML06Man"+CRLF+cMsg+CRLF+cInfo)
				endif

			endif

			lTodos := .T.

		EndIf

	else

		//Erro TSS ou WS n„o instalado.
		cInfo := IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
		cMsg  := cFilAnt + " Falha no momento de conectar com a url do sefaz"

		if .not. lBai
			
			if GetNewPar("XM_VISFAL","") == "S"
				if !IsBlind()
					U_MyAviso("HFXML06Man",cMsg+CRLF+cInfo,{"OK"},3)
				else
					Conout("HFXML06Man"+CRLF+cMsg+CRLF+cInfo)
				endif
			else
				Conout("HFXML06Man"+CRLF+cMsg+CRLF+cInfo)
			endif

		endif

		lTodos := .T.
		/*cInfo := IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
		cMsg  := "Erro TSS ou WS"
		if .not. lBai
			U_MyAviso("SPED",cInfo,{"OK"},3)
		endif
		lTodos := .T.*/

	endif

	Exit

Next

if lTodos

	TMPSQL->( DbGotop() )

	While .not. TMPSQL->( Eof() )

		if TMPSQL->OK == "Pt" // == cMarcaOK

			RecLock( "TMPSQL", .F. )

			TMPSQL->OK    := "  "
			TMPSQL->ST    := "0"
			TMPSQL->MSG   := cMsg
				cInfo:= substr(cInfo,1,100)
			TMPSQL->ERRO  := cInfo

			TMPSQL->( MsUnLock() )

		endif

		if TMPSQL->OK == "Pr" // == cMarcaOK

			lTemPr := .T.

		endif

		TMPSQL->( dbskip() )

	End

else

	if .not. lBai

		U_MyAviso("Msg","OperaÁ„o concluida, verifique as Mensagens.",{"OK"},3)

	Else

		TMPSQL->( DbGotop() )

		While .not. TMPSQL->( Eof() )

			if TMPSQL->OK == "Pr" // == cMarcaOK

				lTemPr := .T.

			endif

			TMPSQL->( dbskip() )

		End

	endif

endif

if lBai

	if lTemPr  //essa È a locucura, po tive que mudar tudo esta merda

		lRet := .F.

	else

		lRet := .T.

	endif

endif

DelClassIntf()

TMPSQL->( DbGoto( nReg ) )

Return( lRet )


/*/{Protheus.doc} zCarEspec
FunÁ„o que limpa os caracteres especiais dentro de um campo
@type function
@author Rogerio Lino / HF
@since 28/08/2020
@version 1.0
@param lEndereco, LÛgico, Define se o campo È endereÁo (caso sim, o traÁo e vÌrgula ser„o ignorados)
    @example
    u_zCarEspec()
/*/
 
User Function zCarEspec( cString )

Local cConteudo := cString

if !Empty(cConteudo)

	//Retirando caracteres
	//cConteudo := StrTran(cConteudo, "'", "")
	//cConteudo := StrTran(cConteudo, "#", "")
	//cConteudo := StrTran(cConteudo, "%", "")
	//cConteudo := StrTran(cConteudo, "*", "")
	cConteudo := StrTran(cConteudo, "&", "E")
	//cConteudo := StrTran(cConteudo, ">", "")
	//cConteudo := StrTran(cConteudo, "<", "")
	//cConteudo := StrTran(cConteudo, "!", "")
	//cConteudo := StrTran(cConteudo, "@", "")
	//cConteudo := StrTran(cConteudo, "$", "")
	//cConteudo := StrTran(cConteudo, "(", "")
	//cConteudo := StrTran(cConteudo, ")", "")
	//cConteudo := StrTran(cConteudo, "_", "")
	//cConteudo := StrTran(cConteudo, "=", "")
	//cConteudo := StrTran(cConteudo, "+", "")
	//cConteudo := StrTran(cConteudo, "{", "")
	//cConteudo := StrTran(cConteudo, "}", "")
	//cConteudo := StrTran(cConteudo, "[", "")
	//cConteudo := StrTran(cConteudo, "]", "")
	//cConteudo := StrTran(cConteudo, "/", "")
	//cConteudo := StrTran(cConteudo, "?", "")
	//cConteudo := StrTran(cConteudo, ".", "")
	//cConteudo := StrTran(cConteudo, "\", "")
	//cConteudo := StrTran(cConteudo, "|", "")
	//cConteudo := StrTran(cConteudo, ":", "")
	//cConteudo := StrTran(cConteudo, ";", "")
	//cConteudo := StrTran(cConteudo, '"', '')
	//FR - 08/02/2021 - #6170 - MaxiRubber - revis„o conforme documentaÁ„o:
	//https://tdn.totvs.com/display/tec/EncodeUTF8
	cConteudo := StrTran(cConteudo, '∞', '')
	cConteudo := StrTran(cConteudo, '™', '')
	cConteudo := StrTran(cConteudo, '¸', '')
	cConteudo := StrTran(cConteudo, 'Ï', '')
	cConteudo := StrTran(cConteudo, '≈', '')
	cConteudo := StrTran(cConteudo, '…', '')
	cConteudo := StrTran(cConteudo, '•', '')
	//cConteudo := StrTran(cConteudo, CHR(13)+CHR(10) , '') 	//FR - 24/02/2021 - chamado 6255 - ItambÈ
	//FR - 08/02/2021 - #6170 - MaxiRubber

endif

Return( cConteudo )


User Function RemoveAsc(cTexto)

Local cRet := cTexto 

cRet := (StrTran(cRet, CHAR(1),""))  // --  01  1 SOH ^A Start of Header - InÌcio do cabeÁalho 
cRet := (StrTran(cRet, CHAR(2),"")) 
cRet := (StrTran(cRet, CHAR(3),"")) 
cRet := (StrTran(cRet, CHAR(4),"")) 
cRet := (StrTran(cRet, CHAR(5),"")) 
cRet := (StrTran(cRet, CHAR(6),"")) 
cRet := (StrTran(cRet, CHAR(7),"")) 
cRet := (StrTran(cRet, CHAR(8),"")) 
cRet := (StrTran(cRet, CHAR(9),"")) 
cRet := (StrTran(cRet, CHAR(10),"")) 
cRet := (StrTran(cRet, CHAR(11),"")) 
cRet := (StrTran(cRet, CHAR(12),"")) 
cRet := (StrTran(cRet, CHAR(13),"")) 
cRet := (StrTran(cRet, CHAR(14),"")) 
cRet := (StrTran(cRet, CHAR(15),"")) 
cRet := (StrTran(cRet, CHAR(16),"")) 
cRet := (StrTran(cRet, CHAR(17),"")) 
cRet := (StrTran(cRet, CHAR(18),"")) 
cRet := (StrTran(cRet, CHAR(19),"")) 
cRet := (StrTran(cRet, CHAR(20),"")) 
cRet := (StrTran(cRet, CHAR(21),"")) 
cRet := (StrTran(cRet, CHAR(22),"")) 
cRet := (StrTran(cRet, CHAR(23),"")) 
cRet := (StrTran(cRet, CHAR(24),"")) 
cRet := (StrTran(cRet, CHAR(25),"")) 
cRet := (StrTran(cRet, CHAR(26),"")) 
cRet := (StrTran(cRet, CHAR(27),"")) 
cRet := (StrTran(cRet, CHAR(28),"")) 
cRet := (StrTran(cRet, CHAR(29),"")) 
cRet := (StrTran(cRet, CHAR(30),"")) 
cRet := (StrTran(cRet, CHAR(31),"")) 
cRet := (StrTran(cRet, CHAR(127),"")) 
 
Return(cRet)   

//Analisa o primeiro e o ultimo digito do xml
/*/{Protheus.doc} HFPRIULT
FunÁ„o que analisa o primeiro e o ultimo digito
@type function
@author Rogerio Lino / HF
@since 16/12/2020
@version 1.0
@param caracter
    @example
    u_HFPRIULT()
/*/
User Function HFPRIULT( cMens )

Local x := 0
Local cSub := ''

//Analisa primeiro digito
/*For x := 1 To Len(cMens)

	cSub := Substr(cMens,1,1)

	if cSub $ "<"

		Exit

	endif

	If cSub $ cMens

		cMens := Alltrim(StrTran(cMens,cSub,''))

	Endif

Next x

//Analisa o ultimo digito
For x := Len(cMens) To 0 STEP -1

	cSub := Substr(cMens,-1,1)

	if cSub $ ">"

		Exit

	endif

	If cSub $ cMens

		cMens := Alltrim(StrTran(cMens,cSub,''))

	Endif

Next x*/

//HMS 15/10/2021 - Nova rotina que verifica se o primeiro e o ultimo digito est„o corretos 

//Analisa primeiro digito
If Substr(cMens,1,1) <> "<"
	cMens := "<" + cMens
EndIf

//Analisa ultimo digito
If Substr(cMens,len(cMens),1) <> ">"
	cMens := cMens + ">"
EndIf

Return cMens


/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…››››››››››—››››››››››À›››››››—››››››››››››››››››››À››››››—›››››››››››››ª±±
±±∫Programa  ≥NoAcento  ∫ Autor ≥ Roberto Souza      ∫ Data ≥  07/10/11   ∫±±
±±Ã››››››››››ÿ›››››››››› ›››››››››››››››››››››››››››› ››››››››››››››››››››π±±
±±∫Descricao ≥ Retira caracteres especiais.                               ∫±±
±±∫          ≥                                                            ∫±±
±±Ã››››››››››ÿ››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››π±±
±±∫Uso       ≥ Importa Xml                                                ∫±±
±±»›››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Static Function NoAcento(cString)

Local cChar  := ""
Local nX     := 0
Local nY     := 0
Local cVogal := "aeiouAEIOU"
Local cAgudo := "·ÈÌÛ˙"+"›…›”⁄"
Local cCircu := "‚ÍÓÙ˚"+"¬ Œ‘€"
Local cTrema := "‰ÎÔˆ¸"+"ƒÀ›÷‹"
Local cCrase := "‡ËÏÚ˘"+"¿»Ã“Ÿ"
Local cTio   := "„ı"
Local cCecid := "Á«"
//Local lChar  := .F.

For nX:= 1 To Len(cString)

	cChar := SubStr(cString, nX, 1)

	IF cChar$cAgudo+cCircu+cTrema+cCecid+cTio+cCrase

		nY := At(cChar,cAgudo)

		If nY > 0

			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))

		EndIf

		nY := At(cChar,cCircu)

		If nY > 0

			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))

		EndIf

		nY := At(cChar,cTrema)

		If nY > 0

			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))

		EndIf

		nY := At(cChar,cCrase)

		If nY > 0

			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))

		EndIf

		nY := At(cChar,cTio)

		If nY > 0

			cString := StrTran(cString,cChar,SubStr("ao",nY,1))

		EndIf

		nY := At(cChar,cCecid)

		If nY > 0

			cString := StrTran(cString,cChar,SubStr("cC",nY,1))

		EndIf

	Endif

Next

nTotLen := Len(cString)

For nX := 1 To nTotLen

	cChar := SubStr(cString, nX, 1)

	If Asc(cChar) < 32 .Or. Asc(cChar) > 123// .and. (cChar<> 10 .And. cChar<> 13)

		cString := StrTran(cString,cChar,".")

	Endif

Next nX

Return( cString )

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Fun??o    ≥HFXML06Leg≥ Autor ≥Eneovaldo Roveri Junior≥ Data ≥ 17/02/14 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒƒ›ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒ›ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descri??o ≥ Legenda do Download e ManifestaÁ„o                         ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ HFXML06Leg()                                               ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function HFXML06Leg()

Local aLegenda := {}

AADD(aLegenda,{"BR_AMARELO" ,"Aguardando interaÁ„o para download/manif." })
AADD(aLegenda,{"BR_VERMELHO","Download e/ou manifestaÁ„o com erros." })
AADD(aLegenda,{"BR_AZUL"    ,"Manif. processada aguardando interaÁ„o p/download." })
AADD(aLegenda,{"BR_VERDE" 	,"Download Concluido com sucesso." })

BrwLegenda("Download de XML", "Legenda", aLegenda)

Return Nil

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…››››››››››—››››››››››À›››››››—››››››››››››››››››››À››››››—›››››››››››››ª±±
±±∫Programa  ≥MyAviso   ∫Autor  ≥ Eneo               ∫ Data ≥             ∫±±
±±Ã››››››››››ÿ›››››››››› ›››››››››››››››››››››››››››› ››››››››››››››››››››π±±
±±∫Desc.     ≥ Interface/Dialog de Aviso.                                 ∫±±
±±∫          ≥                                                            ∫±±
±±Ã››››››››››ÿ››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››π±±
±±∫Uso       ≥ Geral                                                      ∫±±
±±»›››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function Manifesto(cCaption,cMensagem,aBotoes,nSize,cCaption2, nRotAutDefault,cBitmap,lEdit,nTimer,nOpcPadrao,lAuto)

Local ny        := 0
Local nx        := 0
Local aSize  := {  {134,304,35,155,35,113,51},;  // Tamanho 1
{134,450,35,155,35,185,51},; // Tamanho 2
{227,450,35,210,65,185,99} } // Tamanho 3
Local nLinha    := 0
Local cMsgButton:= ""
Local oGet
Local nPass := 0

Private oDlgAviso
Private nOpcAviso := 0

DEFAULT lEdit := .F.

If lEdit

	nSize := 3

EndIf

lMsHelpAuto := .F.

cCaption2 := Iif(cCaption2 == Nil, cCaption, cCaption2)
cMensagem := "1-ConfirmaÁ„o da operaÁ„o: OperaÁ„o conclusiva, o emissor n„o poder· cancelar o XML"+CRLF
cMensagem += "2-CiÍncia da operaÁ„o: Dever· Confirmar operaÁ„o posteriormente, o emissor n„o poder· cancelar o XML"+CRLF
cMensagem += "3-Desconhecimento da operaÁ„o"+CRLF
cMensagem += "4-OperaÁ„o n„o Realizada"+CRLF
//"ConfirmaÁ„o da operaÁ„o","CiÍncia da operaÁ„o","Desconhecimento da operaÁ„o","OperaÁ„o n„o Realizada"

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Quando for rotina automatica, envia o aviso ao Log.          ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
If Type('lMsHelpAuto') == 'U'

	lMsHelpAuto := .F.

EndIf

If !lMsHelpAuto

	If nSize == Nil

		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ Verifica o numero de botoes Max. 5 e o tamanho da Msg.       ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		If  Len(aBotoes) > 3

			nSize := 3

		Else

			Do Case

				Case Len(cMensagem) > 170 .And. Len(cMensagem) < 250

				nSize := 2

				Case Len(cMensagem) >= 250

				nSize := 3

				OtherWise

				nSize := 1

			EndCase

		EndIf

	EndIf

	If nSize <= 3

		nLinha := nSize

	Else

		nLinha := 3

	EndIf

	DEFINE MSDIALOG oDlgAviso FROM 0,0 TO aSize[nLinha][1],aSize[nLinha][2] TITLE cCaption OF oDlgAviso PIXEL
	DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD
	//	@ 0, 0 BITMAP RESNAME "LOGIN" oF oDlgAviso SIZE aSize[nSize][3],aSize[nSize][4] NOBORDER WHEN .F. PIXEL ADJUST .T.
	@ 11 ,35  TO 13 ,400 LABEL '' OF oDlgAviso PIXEL

	If cBitmap <> Nil

		@ 2, 37 BITMAP RESNAME cBitmap oF oDlgAviso SIZE 18,18 NOBORDER WHEN .F. PIXEL
		@ 3  ,50  SAY cCaption2 Of oDlgAviso PIXEL SIZE 130 ,9 FONT oBold

	Else

		@ 3  ,37  SAY cCaption2 Of oDlgAviso PIXEL SIZE 130 ,9 FONT oBold

	EndIf

	If nSize < 3

		@ 16 ,38  SAY cMensagem Of oDlgAviso PIXEL SIZE aSize[nLinha][6],aSize[nLinha][5]

	Else

		If !lEdit

			@ 16 ,38  GET oGet VAR cMensagem Of oDlgAviso PIXEL SIZE aSize[nLinha][6],aSize[nLinha][5] READONLY MEMO

		Else

			@ 16 ,38  GET oGet VAR cMensagem Of oDlgAviso PIXEL SIZE aSize[nLinha][6],aSize[nLinha][5] MEMO

		EndIf

	EndIf

	If Len(aBotoes) > 1 .Or. nTimer <> Nil

		TButton():New(1000,1000," ",oDlgAviso,{||Nil},82,10,,oDlgAviso:oFont,.F.,.T.,.F.,,.F.,,,.F.)

	EndIf

	ny := 38

	l1 := .T.

	For nx := 1 to Len(aBotoes)

		cAction:="{||nOpcAviso:="+Str(nx)+",oDlgAviso:End()}"
		bAction:=&(cAction)
		cMsgButton:= OemToAnsi(AllTrim(aBotoes[nx]))
		cMsgButton:= IF(  "&" $ Alltrim(cMsgButton), cMsgButton ,  "&"+cMsgButton )

		if l1

			TButton():New(aSize[nLinha][7]-15,ny,cMsgButton, oDlgAviso,bAction,82,10,,oDlgAviso:oFont,.F.,.T.,.F.,,.F.,,,.F.)

		Else

			TButton():New(aSize[nLinha][7]   ,ny,cMsgButton, oDlgAviso,bAction,82,10,,oDlgAviso:oFont,.F.,.T.,.F.,,.F.,,,.F.)

		Endif

		ny += 85

		if ny > 150

			ny := 38
			l1 := .F.

		endif

	Next nx

	If nTimer <> Nil

		oTimer := TTimer():New(nTimer,{|| nOpcAviso := nOpcPadrao,IIf(nPass==0,nPass++,oDlgAviso:End()) },oDlgAviso)
		oTimer:Activate()
		bAction:= {|| oTimer:DeActivate() }
		TButton():New(aSize[nLinha][7],ny,"Timer off", oDlgAviso,bAction,52,10,,oDlgAviso:oFont,.F.,.T.,.F.,,.F.,,,.F.)

	Endif

	ACTIVATE MSDIALOG oDlgAviso CENTERED

Else

	If ValType(nRotAutDefault) == "N" .And. nRotAutDefault <= Len(aBotoes)

		cMensagem += " " + aBotoes[nRotAutDefault]

		nOpcAviso := nRotAutDefault

	Endif

	ConOut(Repl("*",40))
	ConOut(cCaption)
	ConOut(cMensagem)
	ConOut(Repl("*",40))
	AutoGrLog(cCaption)
	AutoGrLog(cMensagem)

EndIf

Return (nOpcAviso)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…››››››››››—››››››››››À›››››››—››››››››››››››››››››À››››››—›››››››››››››ª±±
±±∫Programa  ≥MyAviso   ∫Autor  ≥ Eneo               ∫ Data ≥             ∫±±
±±Ã››››››››››ÿ›››››››››› ›››››››››››››››››››››››››››› ››››››››››››››››››››π±±
±±∫Desc.     ≥ Interface/Dialog de Aviso.                                 ∫±±
±±∫          ≥                                                            ∫±±
±±Ã››››››››››ÿ››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››π±±
±±∫Uso       ≥ Geral                                                      ∫±±
±±»›››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
User Function TelaJust( cChv ,cJust ) //GETESB2

Local cRet := Substr( AllTrim(cJust) + Space(250) , 1, 250 )
Local oDlg, oJus, oChv
Local nOpc := 1

DEFINE MSDIALOG oDlg TITLE "Justificativa OperaÁ„o N„o Realizada" FROM 0,0 TO 185,680 OF oDlg PIXEL

@ 006,006 Say "Chave: " PIXEL OF oDlg
@ 016,006 GET oChv VAR cChv PICTURE "@!" SIZE 150,08 PIXEL OF oDlg WHEN .F.

@ 030,006 Say "Justificativa: " PIXEL OF oDlg
@ 040,006 GET oJus VAR cRet MULTILINE SIZE 290,30 PIXEL OF oDlg Valid( cccc(@cRet) )

@ 080,195 BUTTON "Cancelar" SIZE 35,12 PIXEL OF oDlg Action(nOpc:= 0,oDlg:End())
@ 080,235 BUTTON "Salvar" SIZE 35,12 PIXEL OF  oDlg Action(nOpc:= 1,oDlg:End())

ACTIVATE MSDIALOG oDlg CENTERED

if nOpc == 0 .or. empty(cRet)

	cRet := "-1"

endif

Return( cRet )


Static Function cccc(cRet)

Local lRet := .T.

if len( alltrim( cRet ) ) > 255

	U_MyAviso("Aviso","Limite de Caracteres 255",{"OK"},3)

	cRet := Substr(cRet,1,255)

endif

Return( lRet )

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…››››››››››—››››››››››À›››››››—››››››››››››››››››››À››››››—›››››››››››››ª±±
±±∫Programa  ≥MyAviso   ∫Autor  ≥ Eneo               ∫ Data ≥             ∫±±
±±Ã››››››››››ÿ›››››››››› ›››››››››››››››››››››››››››› ››››››››››››››››››››π±±
±±∫Desc.     ≥ F3 para escolher cnpj.                                     ∫±±
±±∫          ≥                                                            ∫±±
±±Ã››››››››››ÿ››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››π±±
±±∫Uso       ≥ Geral                                                      ∫±±
±±»›››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
/*User Function HFXML6SM( cCnpj,cEmp0,cFil0 )

Local lRet      := .F.
Local aArea     := GetArea()
Local aObjects  := {}
Local aInfo     := {}
Local aPosObj   := {}
Local aSize     := MsAdvSize( .F. )
Local aStru     := {}
//Local cArq, _cIndice, _dIndex := ""
Local nI        := 0 //declaracao
Local oTrbTable
Local cSM0Alias := "QRYMAT"
Local cQuery    := ""

PRIVATE aHeader := {}

//-------------------
//CriaÁ„o do objeto
//-------------------
oTrbTable := FWTemporaryTable():New( cSM0Alias )

aStru := Temporario("SM0")
//cArq  := CriaTrab(aStru, .T.)
oTrbtable:SetFields( aStru )

oTrbTable:AddIndex("01", {"M0_CODIGO","M0_CODFIL"} )

//------------------
//CriaÁ„o da tabela
//------------------
oTrbTable:Create()

//------------------------------------
//Executa query para leitura da tabela
//------------------------------------
cQuery := " SELECT * FROM " + oTrbTable:GetRealName()
MPSysOpenQuery( cQuery, "TMPMAT" )
DbSelectArea("TMPMAT")

DbSelectArea("SM0")
nReg := SM0->( recno() )
SM0->( dbGoTop() )

While .Not. SM0->( Eof() )

	DbSelectArea("TMPMAT")

	RecLock( "TMPMAT", .T. )

	FOR nI := 1 TO TMPMAT->( FCount() )

		nPos := SM0->( FieldPos( TMPMAT->( FieldName( nI ) ) ) )

		If nPos > 0

			TMPMAT->( FieldPut( nI, SM0->(FieldGet(nPos)) ) )

		EndIf

	NEXT nI

	TMPMAT->( MsUnLock() )   //dbUnLock()

	DbSelectArea("SM0")

	SM0->( dbSkip() )

End

SM0->( dbGoto(nReg) )
DbSelectArea("TMPMAT")

dbGoTop()

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Calcula as coordenadas da interface                                 ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
aSize[1] /= 1.5
aSize[2] /= 1.5
aSize[3] /= 1.5
aSize[4] /= 1.3
aSize[5] /= 1.5
aSize[6] /= 1.3
aSize[7] /= 1.5

AAdd( aObjects, { 100, 020,.T.,.F.,.T.} )
AAdd( aObjects, { 100, 060,.T.,.T.} )
AAdd( aObjects, { 100, 020,.T.,.F.} )

aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects,.T.)

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Interface com o usuario                                             ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
DEFINE MSDIALOG oDlg TITLE OemToAnsi("Empresas") FROM aSize[7],000 TO aSize[6],aSize[5] OF oMainWnd PIXEL

oGetDb := MsGetDB():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],1,"Allwaystrue","allwaystrue","",.F., , ,.F., ,"TMPMAT")

DEFINE SBUTTON FROM aPosObj[3,1]+000,aPosObj[3,4]-030 TYPE 1 ACTION (nOpcA := 1,oDlg:End()) ENABLE OF oDlg
DEFINE SBUTTON FROM aPosObj[3,1]+012,aPosObj[3,4]-030 TYPE 2 ACTION (nOpcA := 0,oDlg:End()) ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg CENTERED

If nOpcA == 1

	lRet := .T.
	cCnpj := TMPMAT->M0_CGC
	cEmp0 := TMPMAT->M0_CODIGO
	cFil0 := TMPMAT->M0_CODFIL

EndIf

DbSelectArea("TMPMAT")
dbclosearea()

//---------------------------------
//Exclui a tabela
//---------------------------------
oTrbTable:Delete()

RestArea( aArea )

Return( lRet )*/

User Function HFXML6SM(cCnpj,cEmp0,cFil0)
Local lRet      := .F.
Local aArea     := GetArea()
Local aObjects  := {}
Local aInfo     := {}
Local aPosObj   := {}
Local aSize     := MsAdvSize( .F. )
Local aStru     := {}
Local cArq, _cIndice, _dIndex := ""
Local nI := 0 //declaracao
PRIVATE aHeader := {}

aStru := Temporario("SM0")
cArq  := CriaTrab(aStru, .T.)
DBUseArea(.T., __LocalDriver, cArq, "MAT", .T., .F.)

DbSelectArea("MAT")
_cIndice := CriaTrab(nil,.F.)
_dIndex := "M0_CODIGO+M0_CODFIL"
IndRegua("MAT",_cIndice,_dIndex,,)

DbSelectArea("SM0")
nReg := SM0->( recno() )
SM0->( dbGoTop() )
Do While .Not. SM0->( Eof() )
		DbSelectArea("MAT")
   		RecLock( "MAT", .T. )
		FOR nI := 1 TO MAT->( FCount() )
			nPos := SM0->( FieldPos( MAT->( FieldName( nI ) ) ) )
			If nPos > 0
				MAT->( FieldPut( nI, SM0->(FieldGet(nPos)) ) )
			EndIf
		NEXT nI
		MAT->( dbUnLock() )
		DbSelectArea("SM0")
		SM0->( dbSkip() )
EndDo

SM0->( dbGoto(nReg) )
DbSelectArea("MAT") 
dbGoTop()

		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ Calcula as coordenadas da interface                                 ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		aSize[1] /= 1.5
		aSize[2] /= 1.5
		aSize[3] /= 1.5
		aSize[4] /= 1.3
		aSize[5] /= 1.5
		aSize[6] /= 1.3
		aSize[7] /= 1.5

		AAdd( aObjects, { 100, 020,.T.,.F.,.T.} )
		AAdd( aObjects, { 100, 060,.T.,.T.} )
		AAdd( aObjects, { 100, 020,.T.,.F.} )
		aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 } 
		aPosObj := MsObjSize( aInfo, aObjects,.T.)

		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ Interface com o usuario                                             ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		DEFINE MSDIALOG oDlg TITLE OemToAnsi("Empresas") FROM aSize[7],000 TO aSize[6],aSize[5] OF oMainWnd PIXEL

	  	oGetDb := MsGetDB():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],1,"Allwaystrue","allwaystrue","",.F., , ,.F., ,"MAT")

		DEFINE SBUTTON FROM aPosObj[3,1]+000,aPosObj[3,4]-030 TYPE 1 ACTION (nOpcA := 1,oDlg:End()) ENABLE OF oDlg
		DEFINE SBUTTON FROM aPosObj[3,1]+012,aPosObj[3,4]-030 TYPE 2 ACTION (nOpcA := 0,oDlg:End()) ENABLE OF oDlg
		ACTIVATE MSDIALOG oDlg CENTERED

		If nOpcA == 1
			lRet := .T.
			cCnpj := MAT->M0_CGC
			cEmp0 := MAT->M0_CODIGO
			cFil0 := MAT->M0_CODFIL
		EndIf

DbSelectArea("MAT")
dbclosearea()

Ferase(cArq+GetDBExtension())
Ferase(cArq+OrdBagExt())

RestArea( aArea )
Return( lRet )



//Gera Estrutura para arquivo Tempor·rio a Partir do SigaMat
Static Function Temporario(cAlias)

Local aStr  := {}
Local aStru := {}
Local cTit  := ""
Local nI := 0

DbSelectArea(cAlias)
aStr := dbStruct()

nTotLen := Len(aStr)

For ni := 1 to nTotLen

	If AllTrim( aStr[ni][1] ) $ "M0_CODIGO,M0_CODFIL,M0_FILIAL,M0_NOME,M0_CGC"

		aAdd(aStru,aStr[ni])

	EndIF

Next

aHeader := {}

nTotLen := Len(aStru)

For ni := 1 to nTotLen

	cTit := iif(alltrim(aStru[ni][1])=="M0_CODIGO", "Empresa",;
	iif(alltrim(aStru[ni][1])=="M0_CODFIL", "Cod.Fil.",;
	iif(alltrim(aStru[ni][1])=="M0_CGC"   , "CNPJ",;
	iif(alltrim(aStru[ni][1])=="M0_FILIAL", "Filial",;
	iif(alltrim(aStru[ni][1])=="M0_NOME"  , "Nome",;
	aStru[ni][1] )))))

	aAdd(aHeader,{ cTit, ;
	aStru[ni][1]   , ;
	iif(alltrim(aStru[ni][1])=="M0_CGC", "@R 99.999.999-9999-99", "@!"), ;
	aStru[ni][3] , ;
	aStru[ni][4] , ;
	, ;
	, ;
	, ;
	, ;
	} )
	
Next ni

Return( aStru )


//Checar se CNPJ esta no sigamat com licenÁa
Static Function ChkCnpj(cCnpj,cEmp0,cFil0)

Local lRet  := .F.
Local aArea := GetArea()
Local nRecFil

DbSelectArea("SM0")
nRecFil := Recno()
DbGotop()

While !Eof()

	If Alltrim(SM0->M0_CGC) == Alltrim(cCnpj) .And. Alltrim(SM0->M0_CODIGO) == Alltrim(cEmpAnt) .And. Alltrim(SM0->M0_CODFIL) == Alltrim(cFil0)  //A empresa n„o pode mudaire, por isso cEmpAnt

		//If U_HFXML00X("HF000001","101",SM0->M0_CGC,,.F.)
		If HFXMLLIC(.F.)

			lRet  := .T.

			Exit

		EndIF

	EndIf

	DbSkip()

EndDO

If .Not. lRet

	Alert( "CNPJ n„o encontrado ou sem LicenÁa Emp. "+cEmp0+" Filial "+cFil0+" !!!" )
	SM0->( dbGoto(nRecFil) )

EndIf

RestArea(aArea)

Return( lRet )


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…››››››››››—››››››››››À›››››››—››››››››››››››››››››À››››››—›››››››››››››ª±±
±±∫Programa  ≥ HFXML6CD ∫Autor  ≥ Eneo               ∫ Data ≥             ∫±±
±±Ã››››››››››ÿ›››››››››› ›››››››››››››››››››››››››››› ››››››››››››››››››››π±±
±±∫Desc.     ≥ Consultar CNPJ do Destinat·rio via WS.                     ∫±±
±±∫          ≥                                                            ∫±±
±±Ã››››››››››ÿ››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››π±±
±±∫Uso       ≥ Geral                                                      ∫±±
±±»›››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
User Function HFXML6CD(cCnpj, lMostra, cLogProc, nImp, nCount, lEnd, oRegua)

Local nHdl   := -1
Local lRet   := .F.
Local cURL   := ""
Local cAmb   := "1"
Local cXml   := ""
Local cIdEnt := U_GetIdEnt()
Local cUF    := VerUfMat( cCnpj )
Local cVerLay:= "1.00"
Local cIndCon:= "1"
Local cSitConf  := ""
Local cChaveXml := Space(44)
Local cCnpjXml  := Space(14)
Local cCancNSU  := ""
Local nVzNaoSinc:= 0
Local nOrd 		:= 0
Local cSt       := " "
Local cNf       := Space(9)
Local cSer      := Space(3)
Local cErro     := ""
Local cWarning  := ""
Local nX := 0 //declaracao
Local lDfeHf    := ( GetNewPar( "XM_DFE", "0" ) == "1" )
Local cNSUZero  := GetNewPar( "XM_NSUZERO", "N" )
Local cDayNSUzero := GetNewPar( "XM_DAYZERO", "S" )
Local cCnpjDest := ""
Local nErr := 0
//Local nI   := 0
Local _cFil := ""
Local cIE   := ""
Local nReg  := 0
Local oDoc 

Default cLogProc := ""
Default nImp     := 2
Default nCount   := 0
Default lEnd     := .F.
Default oRegua   := NIL

Private cTagNfe, cTagCan, cTagCce, oWs, oWsrNfe, oWsdNfe, aDocs
Private aEnvNfe	:=	{}  //Criado para funÁ„o espi„o na data 11/12/2015
//Private nReg    := 0
cInfo := ""
cMsg  := ""

cURL      := AllTrim(GetNewPar("XM_URL",""))

If Empty(cURL)

	cURL  := AllTrim(SuperGetMv("MV_SPEDURL"))

EndIf

If Right( AllTrim(cURL), 1 ) != "/"

	cURL := AllTrim(cURL)+"/"

EndIf

DbSelectArea( xZBS )

If .NOT. lDfeHf  //Via TSS igual era antes, no else vai para a queijos ipanema

	oWSdNfe := WSMANIFESTACAODESTINATARIO():New()
	oWSdNfe:cUserToken   := "TOTVS"
	oWSdNfe:cIDENT	     := cIdEnt
	oWSdNfe:cAMBIENTE	 := "1"
	oWSdNfe:cINDNFE		 := "0"
	oWSdNfe:cINDEMI      := "0"
	oWSdNfe:_URL         := AllTrim(cURL)+"MANIFESTACAODESTINATARIO.apw"

	While cIndCon == "1"

		If lMostra

			If lEnd

				MsgStop("*** Cancelado pelo Operador ***","Fim")
				lRet := .F.
				Exit

			EndIf

			oRegua:IncRegua1("Metodo SINCRONIZARDOCUMENTOS SEFAZ...")
			oRegua:IncRegua2("NFeDistrDfe SEFAZ" )

		EndIf

		If oWSdNfe:SINCRONIZARDOCUMENTOS()

			cIndCon := oWSdNfe:OWSSINCRONIZARDOCUMENTOSRESULT:cIndCont
			cAmb    := oWSdNfe:OWSSINCRONIZARDOCUMENTOSRESULT:cAMBIENTE

			If Type ("oWSdNfe:OWSSINCRONIZARDOCUMENTOSRESULT:OWSDOCUMENTOS:OWSSINCDOCUMENTOINFO") <> "U"

				nVzNaoSinc := 0

				If Type("oWSdNfe:OWSSINCRONIZARDOCUMENTOSRESULT:OWSDOCUMENTOS:OWSSINCDOCUMENTOINFO")=="A"

					aDocs := oWSdNfe:OWSSINCRONIZARDOCUMENTOSRESULT:OWSDOCUMENTOS:OWSSINCDOCUMENTOINFO

				Else

					aDocs := {oWSdNfe:OWSSINCRONIZARDOCUMENTOSRESULT:OWSDOCUMENTOS:OWSSINCDOCUMENTOINFO}

				EndIf

				nTotLen := Len(aDocs)

				For nX := 1 To nTotLen

					If Type(aDocs[nX]:CCHAVE) <> "U" .and. Type(aDocs[nX]:CSITCONF) <> "U"

						cSitConf  := aDocs[nX]:CSITCONF
						cChaveXml := aDocs[nX]:CCHAVE
						cCancNSU  := aDocs[nX]:CCANCNSU
						nOrd      := (xZBZ)->( IndexOrd() )
						cNf       := Substr( cChaveXml, 26, 9 )
						cSer      := Substr( cChaveXml, 23, 3 )
						cCnpjXml  := Substr( cChaveXml, 07, 14 )
						cCnpjDest := aDocs[nX]:CDESTCNPJ
						cSt       := "  "
						cIE       := ""

						( xZBZ )->( DbSetOrder( 3 ) )

						If ( xZBZ )->(dbSeek( cChaveXml ) )

							cSt := "10"

						Else

							if cSitConf <> "0"

								cSt := "20"

							Endif

						EndIF

						if lMostra

							oRegua:IncRegua2( cChaveXml )

						endif

						nHdl := -1

						If U_HFTrvXml("TRAVA", "ZBS"+cChaveXml, @nHdl)

							( xZBZ )->( DbSetORder( nOrd ) )
							( xZBS )->( DbSetOrder( 3 ) )

							If .Not. ( xZBS )->(dbSeek( cChaveXml ) )

								if cCnpjDest <> cCnpj

									U_HFTrvXml("SOLTA", "ZBS"+cChaveXml, nHdl) //SOLTAR

									Sleep(1500) //da 1 segundo e vai de novo

									cLogProc += cChaveXml+" CNPJ "+cCnpjDest+" N„o È CNPJ "+cCnpj+". Sincronizada NFeDistribuicaoDFe."+CRLF
									
									Loop

								endif

								cLogProc += cChaveXml+" Nova Chave Sincronizada NFeDistribuicaoDFe."+CRLF
								nCount++
								lRet := .T.

								if !Empty( cIE )

									_cFil := u_Gravafil( cCnpjDest, cIE )

									if Empty( xFilial(xZBS) )  //Verifica se for compartilhado

										_cFil := xFilial( xZBS )

									endif

								else

									_cFil := xFilial( xZBS )

								endif

								RecLock(xZBS, .T. )

								( xZBS )->(FieldPut(FieldPos(xZBS_+"FILIAL"),  _cFil ))
								( xZBS )->(FieldPut(FieldPos(xZBS_+"CHAVE")	,  cChaveXml ))
								( xZBS )->(FieldPut(FieldPos(xZBS_+"AMB")	,  cAmb ))
								( xZBS )->(FieldPut(FieldPos(xZBS_+"DEST")	,  cCnpjDest ))
								( xZBS )->(FieldPut(FieldPos(xZBS_+"IDENT")	,  cIdEnt ))

								//21/7/17
								If ( xZBS )->( FieldPos(xZBS_+"MODELO") ) > 0

									( xZBS )->(FieldPut(FieldPos(xZBS_+"MODELO"), Substr(cChaveXml,21,2) ))

								EndIF

								if (xZBS)->(FieldPos(xZBS_+"TPROT")) > 0 //Tipo de Rotina Job ou Manual

									if Empty(  (xZBS)->(FieldGet(FieldPos(xZBS_+"TPROT"))) )

										if Type("cTpRt") <> "U"

											(xZBS)->(FieldPut(FieldPos(xZBS_+"TPROT"), cTpRt ))

										endif

									endif

								endif

							Else

								cLogProc += cChaveXml+" Chave Ja esta na Sincronizacao NFeDistribuicaoDFe."+CRLF

								RecLock(xZBS, .F. )

								( xZBS )->(FieldPut(FieldPos(xZBS_+"DEST")	,  cCnpjDest ))

							Endif

							( xZBS )->(FieldPut(FieldPos(xZBS_+"ST")	, cSt ))
							( xZBS )->(FieldPut(FieldPos(xZBS_+"CSITCO"), cSitConf ))
							( xZBS )->(FieldPut(FieldPos(xZBS_+"CNF")	, cNf ))
							( xZBS )->(FieldPut(FieldPos(xZBS_+"SERIE")	, cSer ))

							If GetNewPar( "XM_ESPIAO", "N" ) == "S"

								U_HFESPIAO( cChaveXml )

							EndIf

							oWSdNfe:cAMBIENTE	 := cAmb
							oWSdNfe:cCHAVE		 := cChaveXml

							If oWSdNfe:RETORNARDOCUMENTO()

								if Type ("oWSdNfe:OWSRETORNARDOCUMENTORESULT:OWSDOCUMENTO") <> "U"

									If Type("oWSdNfe:OWSRETORNARDOCUMENTORESULT:OWSDOCUMENTO:OWSEMITENTE:cCNPJ") <> "U"

										if oWSdNfe:OWSRETORNARDOCUMENTORESULT:OWSDOCUMENTO:OWSEMITENTE:cCNPJ = Substr(cChaveXml,1,14)

										Else

											cCnpjXml := oWSdNfe:OWSRETORNARDOCUMENTORESULT:OWSDOCUMENTO:OWSEMITENTE:cCNPJ

										Endif

										( xZBS )->(FieldPut(FieldPos(xZBS_+"CNPJEM"), cCnpjXml ))

									Endif

									if Empty(( xZBS )->(FieldGet(FieldPos(xZBS_+"CNPJEM")))) .And. Type("oWSdNfe:OWSRETORNARDOCUMENTORESULT:OWSDOCUMENTO:OWSEMITENTE:cCPF") <> "U"

										( xZBS )->(FieldPut(FieldPos(xZBS_+"CNPJEM"), oWSdNfe:OWSRETORNARDOCUMENTORESULT:OWSDOCUMENTO:OWSEMITENTE:cCPF ))

									endif

									If Type("oWSdNfe:OWSRETORNARDOCUMENTORESULT:OWSDOCUMENTO:cDATAEMISSAO") <> "U"

										( xZBS )->(FieldPut(FieldPos(xZBS_+"DEMI"), VerData(oWSdNfe:OWSRETORNARDOCUMENTORESULT:OWSDOCUMENTO:cDATAEMISSAO) ))

									Endif

									If Type("oWSdNfe:OWSRETORNARDOCUMENTORESULT:OWSDOCUMENTO:nVALORTOTAL") <> "U"

										( xZBS )->(FieldPut(FieldPos(xZBS_+"VNF"), oWSdNfe:OWSRETORNARDOCUMENTORESULT:OWSDOCUMENTO:nVALORTOTAL ))

									Endif

									If Type("oWSdNfe:OWSRETORNARDOCUMENTORESULT:OWSDOCUMENTO:OWSEMITENTE:cNOME") <> "U"

										( xZBS )->(FieldPut(FieldPos(xZBS_+"XNOME"), oWSdNfe:OWSRETORNARDOCUMENTORESULT:OWSDOCUMENTO:OWSEMITENTE:cNOME ))

									Endif

									If Type("oWSdNfe:OWSRETORNARDOCUMENTORESULT:OWSDOCUMENTO:OWSEMITENTE:cIE") <> "U"

										( xZBS )->(FieldPut(FieldPos(xZBS_+"IE"),  oWSdNfe:OWSRETORNARDOCUMENTORESULT:OWSDOCUMENTO:OWSEMITENTE:cIE ))

									Endif

									If Type("oWSdNfe:OWSRETORNARDOCUMENTORESULT:OWSDOCUMENTO:cXMLSEFAZ") <> "U"

										( xZBS )->(FieldPut(FieldPos(xZBS_+"DIGVAL"), VerDigVal( oWSdNfe:OWSRETORNARDOCUMENTORESULT:OWSDOCUMENTO:cXMLSEFAZ ) ))

									EndIf

									If Type("oWSdNfe:OWSRETORNARDOCUMENTORESULT:OWSDOCUMENTO:cDATAAUTORIZACAO") <> "U"

										( xZBS )->(FieldPut(FieldPos(xZBS_+"DHRECB"), VerData(oWSdNfe:OWSRETORNARDOCUMENTORESULT:OWSDOCUMENTO:cDATAAUTORIZACAO) ))

									Endif

									if ! Empty(cCancNSU)

										( xZBS )->(FieldPut(FieldPos(xZBS_+"CSITNF"), "3" ))

									Else

										If Type("oWSdNfe:OWSRETORNARDOCUMENTORESULT:OWSDOCUMENTO:cSITUACAO") <> "U"

											( xZBS )->(FieldPut(FieldPos(xZBS_+"CSITNF"), oWSdNfe:OWSRETORNARDOCUMENTORESULT:OWSDOCUMENTO:cSITUACAO ))

										endif

									Endif

									If Type("oWSdNfe:OWSRETORNARDOCUMENTORESULT:OWSDOCUMENTO:cNSU") <> "U"

										( xZBS )->(FieldPut(FieldPos(xZBS_+"NSU"), oWSdNfe:OWSRETORNARDOCUMENTORESULT:OWSDOCUMENTO:cNSU ))

									Endif

									If Type("oWSdNfe:OWSRETORNARDOCUMENTORESULT:OWSDOCUMENTO:OWSCCE:cCCEXMLRET") <> "U"  //cCORRECAO 21/7/17

										( xZBS )->(FieldPut(FieldPos(xZBS_+"CORREC"), oWSdNfe:OWSRETORNARDOCUMENTORESULT:OWSDOCUMENTO:OWSCCE:cCCEXMLRET ))

									EndIf

									//21/7/17
									If Type("oWSdNfe:OWSRETORNARDOCUMENTORESULT:OWSDOCUMENTO:cXMLSEFAZ") <> "U"

										( xZBS )->(FieldPut(FieldPos(xZBS_+"XML"), oWSdNfe:OWSRETORNARDOCUMENTORESULT:OWSDOCUMENTO:cXMLSEFAZ ))

									EndIF

								Endif

							EndIf

							( xZBS )->( MsUnLock() )

							U_HFTrvXml("SOLTA", "ZBS"+cChaveXml, nHdl) //SOLTAR

						EndIF

					EndIf

				Next

			Else

				nVzNaoSinc++

				if nVzNaoSinc >= 3

					cIndCon := "0"
					cInfo   := "Metodo SINCRONIZARDOCUMENTOS() n„o retornou documentos em OWSSINCDOCUMENTOINFO."

					If lMostra

						U_MyAviso("SPED",cInfo,{"OK"},3)

					Endif

				endif

			EndIf

		Else

			cInfo   := IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))

			If "656" $ UPPER(cInfo) .And. "INDEVIDO" $ UPPER(cInfo)

				lRet := .T.      //Para Fazer com o que der
				nVzNaoSinc += 3  //Para Cair Fora
				cInfo := "Retorno da SEFAZ [656 - Consumo Indevido] "+CRLF
				cInfo += "As chaves que foram lidas atÈ o momento com emiss„o atÈ 30 dias e estiverem Manifestadas ser„o Baixadas."+CRLF
				cInfo += "Execute a Rotina Novamente apÛs 10 Minutos sem alterar o NSU para continuar."

			EndIf

			nVzNaoSinc++
			if nVzNaoSinc >= 3

				cIndCon := "0"

				If lMostra

					U_MyAviso("SPED",cInfo,{"OK"},3)

				Endif

			endif

		EndIf

		if .Not. Empty( cInfo )

			cLogProc += cInfo + CRLF

		endif

		if cIndCon == "1"

			Sleep(1500) //Tempo para prÛxima execuÁ„o do mÈtodo SINCRONIZARDOCUMENTOS()

		endif

	EndDo

ELSE  //DFE HF

	rstmvbuff()

	// Tratamento da numeracao
	Private cNSU, cNSU2
	
	//Tratamento criado para tratar o parametro de NSU, pois existem xml aparecendo de forma retroativa
	//Esse esquema de zerar NSU funciona apenas no Job e com o parametro XM_DFE = 1
	If Funname() == "RPC"
	
		if cNSUZero == "S"
		
			cNSU := "000000000000000"
			
		else

			//Se parametro estiver ativado todo dia ao menos uma vez ir· realizar a checagem
			if cDayNSUzero == "S" .and. ( Time() >= "18:00:00" .and. Time() <= "20:00:00" )

				cNSU := "000000000000000"

			else
		
				cNSU := ( GetNewPar("XM_NSUNFE","000000000000000",cFilAnt) )

			endif
		
		endif
		
	else

		//Traz todos
		if nImp == 1

			cNSU := "000000000000000"

		else
	
			cNSU := ( GetNewPar("XM_NSUNFE","000000000000000",cFilAnt) )

		endif
		
	endif
	
	cNSU2 := cNSU

	If !PutMv("XM_NSUNFE",cNSU)

		SX6->(RecLock("SX6",.T.))

		SX6->X6_FIL     := cFilAnt //xFilial( "SX6" )
		SX6->X6_VAR     := "XM_NSUNFE"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "NSU download NFE por CNPJ via HF"

		SX6->(MsUnLock())

		PutMv("XM_NSUNFE",cNSU)

	EndIf

	cVerLay := ( GetNewPar("XM_VERLNFE","1.00",cFilAnt) )

	If !PutMv("XM_VERLNFE",cVerLay)

		SX6->(RecLock("SX6",.T.))

		SX6->X6_FIL     := cFilAnt //xFilial( "SX6" )
		SX6->X6_VAR     := "XM_VERLNFE"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Vers„o Layout download NFE por CNPJ via HF"
		SX6->(MsUnLock())

		PutMv("XM_VERLNFE",cVerLay)

	EndIf

	cAmb := ( GetNewPar("XM_AMBNFE","1",cFilAnt) )

	If !PutMv("XM_AMBNFE",cAmb)

		SX6->(RecLock("SX6",.T.))

		SX6->X6_FIL     := cFilAnt //xFilial( "SX6" )
		SX6->X6_VAR     := "XM_AMBNFE"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Ambiente download NFE por CNPJ via HF"

		SX6->(MsUnLock())

		PutMv("XM_AMBNFE",cAmb)

	EndIf

	nErr := 0
	
	While cIndCon == "1"

		If lMostra

			If lEnd

				MsgStop("*** Cancelado pelo Operador ***","Fim")
				lRet := .F.
				Exit

			EndIf

			oRegua:IncRegua1("Acessando Metodo NFeDistrDfe SEFAZ UF:"+cUF)
			oRegua:IncRegua2("(HF)NFeDistrDfe SEFAZ" )

		EndIf

		oWSdNfe:= WSHFXMLNFEDISTRIBUICAODFE():New()
		oWSdNfe:Init()
		oWSdNfe:cCIDENT       := cIdEnt
		oWSdNfe:cCCURL        := cURL
		oWSdNfe:cCAMBIENTE    := cAmb
		oWSdNfe:cCVERSAODADOS := "1.01"    //cVerLay //Parametro exclosivis
		oWSdNfe:cCCUF         := cUF       //Parametro exclosivis //"91" //"35" //substr(cChave,1,2) //"AN"  //ver isso aqui, È o Estado, agora vem de 1 em 1
		oWSdNfe:cCCNPJ        := cCnpj
		oWSdNfe:cCNSU         := cNSU      //Parametro exclosivis
		oWSdNfe:cCCHSTR       := "ULTNSU"  //para executar a rotina pelo NSU e buscaire as chaves

		if oWSdNfe:HFNFEDISTRDFE()

			cXml := "<"+AllTrim(oWSdNfe:cHFNFEDISTRDFERESULT)

			//Gravar ultimo NSU
			cUltNSU := Substr(Upper(cXml),At('<ULTNSU',Upper(cXml))+8,15)

			If !PutMv("XM_NSUNFE",cUltNSU)

				SX6->(RecLock("SX6",.T.))

				SX6->X6_FIL     := cFilAnt //xFilial( "SX6" )
				SX6->X6_VAR     := "XM_NSUNFE"
				SX6->X6_TIPO    := "C"
				SX6->X6_DESCRIC := "NSU download NFE por CNPJ via HF"

				SX6->(MsUnLock())

				PutMv("XM_NSUNFE",cUltNSU)

			EndIf

			nAt1:= At('<RETDISTDFEINT ',Upper(cXml))
			nAt2:= At('</RETDISTDFEINT>',Upper(cXml)) + 16

			//Corpo do XML
			If nAt1 <=0
				nAt1:= At('<RETDISTDFEINT>',Upper(cXml))
			EndIf

			If nAt1 > 0 .And. nAt2 > 16

				cNfe := Substr(cXml,nAt1,nAt2-nAt1)

				cXml:= '<?xml version="1.0" encoding="UTF-8"?>'
				cXml+= cNfe

				cXml := EncodeUTF8(cXml)

				//Primeiro parse sem checagem de caracteres especiais
				if Len(cXml) >= 65534

					oWSrNfe := U_PARSGDE( cXml, @cErro, @cWarning )

				Else

					oWSrNfe := XmlParser( cXml, "_", @cErro, @cWarning )

				endif

				//Caso for nil faz a segunda checagem somente para aqueles xml¥s que tem caracteres especiais
				if oWSrNfe == NIL 

					//Faz backup do xml sem retirar os caracteres especiais
					cBkpXml := cXml

					cXml := EncodeUTF8(cXml)
					cXml := fWNOAccent(cXml)  //NoAcento(cXml)
					
					//Executa rotina para retirar os caracteres especiais
					cXml := u_zCarEspec( cXml )

					if Len(cXml) >= 65534

						oWSrNfe := U_PARSGDE( cXml, @cErro, @cWarning )

					Else

						oWSrNfe := XmlParser( cXml, "_", @cErro, @cWarning )

					endif

					//retorna o backup do xml
					cXml := cBkpXml

				endif

				If oWSrNfe == NIL //.Or. !Empty(cErro) .Or. !Empty(cWarning)

					cMsg   := "Erro Parser do XML de Resposta"
					cInfo  := cErro + " " + cWarning
					cIndCon:= "2"
					nRet   := 2

					If lMostra

						U_MyAviso("SPED",cInfo,{"OK"},3)

					else

						if nErr < 5

							if cNSU == cNSU2
								cNSU := StrZero( val(cNSU)+1,len(cNSU2),0 )
							endif

							cIndCon := "1"
							nErr++

						endif

					endif

				elseIf oWSrNfe:_RETDISTDFEINT:_CSTAT:TEXT <> "138" //"139"

					cMsg   := "Retorno do Sefaz "+oWSrNfe:_RETDISTDFEINT:_CSTAT:TEXT
					cInfo  := oWSrNfe:_RETDISTDFEINT:_XMOTIVO:TEXT
					cIndCon:= "2"
					nRet   := 2

					if oWSrNfe:_RETDISTDFEINT:_CSTAT:TEXT = "656"  //Consumo indevido

						nRet  := 3   //volta o 3 para tentar por DFE em 10/09/18
						cInfo := Upper(cInfo+"("+oWSrNfe:_RETDISTDFEINT:_CSTAT:TEXT+")")  //"Consumo Indevido"

						if !IsBlind()
							U_MyAviso("HFXML6CD",cMsg+CRLF+cInfo,{"OK"},3)
						else
							Conout("HFXML6CD"+CRLF+cMsg+CRLF+cInfo)
						endif

						Return(.F.)

					EndIf

					If !IsBlind()

						if GetNewPar("XM_VISFAL","") == "S"
							if !IsBlind()
								U_MyAviso("HFXML6CD",cMsg+" - "+cInfo,{"OK"},3)
							else
								Conout("HFXML6CD - "+CRLF+cMsg+CRLF+cInfo)
							endif
						else
							Conout("HFXML6CD - "+CRLF+cMsg+CRLF+cInfo)
						endif
						//Conout("HFXML6CD - " + Msg+" - "+cInfo)

					Else

						if nErr < 5

							if cNSU == cNSU2
								cNSU := StrZero( val(cNSU)+1,len(cNSU2),0 )
							endif

							cIndCon := "1"
							nErr++

						endif

					endif

				Else

					nErr := 0
					oDoc := oWSrNfe:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP
					oDoc := iif( valtype(oDoc)=="O", {oDoc}, oDoc )

					nTotArq := Len( oDoc )

					For nReg := 1 to nTotArq //Deixar assim para quando for mais de 1, mas agora tem que ser de 1 em 1.

						cStt  := ""
						cMsg  := ""
						cInfo := ""
						cChave:= ""

						if Empty( oDoc )

							if !IsBlind()
								U_MyAviso("HFXML06Bai","Objeto do sefaz vazio",{"OK"},3)
							else
								Conout("HFXML06Bai - Objeto do sefaz vazio")
							endif

							Exit

						endif

						cFileZip	:= Decode64( oDoc[nReg]:TEXT )
						nLenZip		:= Len( cFileZip )
						cFileUnZip  := ""

						// Funcao de descompactacao de arquivos compactados no formato GZip
						lOk  := GzStrDecomp( cFileZip, nLenZip, @cFileUnZip )
						oXml := XmlParser( cFileUnZip, "_", @cErro, @cWarning )
						cXml := cFileUnZip

						If valtype(oXml) <> "O"

							cMsg	:=	"XXX"
							cInfo	:=	"N„o foi possÌvel Descompactar o XML."
							cStt	:=	"0"

							If lMostra
								U_MyAviso("SPED",cInfo,{"OK"},3)
							endif

						ElseIf UPPER(Substr(oDoc[nReg]:_SCHEMA:TEXT,1,7)) = UPPER("procNFe") .or. UPPER(Substr(oDoc[nReg]:_SCHEMA:TEXT,1,6)) = UPPER("resNFe")

							If UPPER(Substr(oDoc[nReg]:_SCHEMA:TEXT,1,7)) = UPPER("procNFe")

								cChave := alltrim( oXml:_NFEPROC:_PROTNFE:_INFPROT:_CHNFE:TEXT )

								cTagIEDest := "oXml:_NFEPROC:_NFE:_INFNFE:_DEST:_IE:TEXT"

								if type(cTagIEDest) <> "U"
									cIE    := alltrim( oXml:_NFEPROC:_NFE:_INFNFE:_DEST:_IE:TEXT )
								else
									cIE    := ""
								endif

							Else //if UPPER(Substr(oDoc[nI]:_SCHEMA:TEXT,1,13)) = UPPER("procEventoNFe")

								cChave    := alltrim( oXml:_RESNFE:_CHNFE:TEXT )

								//Manifesta
								If GetNewPar("XM_MANAUT","N") == "S"
								
									U_HF2MFXml( Substr(cChave,1,44), "210210", "", "", 2 )

									Conout( "Manifestacao realizada Xml: " + cChave + " Nsu: " + oDoc[nReg]:_NSU:TEXT )

								endif

								cSitConf   := manifver(cChave,cURL,cIdEnt,cAmb)  //"4"

								//cSitConf  := "0" //oXml:_RESNFE:_CSITNFE:TEXT
								cIE       :=  ""

							EndIF

							if lMostra

								oRegua:IncRegua2( cChave )

							endif

							Conout( "Download do xml: " + cChave + " NSU: " + oDoc[nReg]:_NSU:TEXT )

							cChaveXml := cChave
							cCancNSU  := oDoc[nReg]:_NSU:TEXT //ver a bagaÁa
							nOrd      := (xZBZ)->( IndexOrd() )
							cNf       := Substr( cChaveXml, 26, 9 )
							cSer      := Substr( cChaveXml, 23, 3 )
							cCnpjXml  := Substr( cChaveXml, 07, 14 )
							cSt       := "  "

							nHdl := -1

							If U_HFTrvXml("TRAVA", "ZBS"+cChaveXml, @nHdl)

								( xZBZ )->( DbSetOrder( 3 ) )

								If ( xZBZ )->(dbSeek( cChaveXml ) )

									cSt := "10"

								Else

									if cSitConf <> "0"

										cSt := "20"

									Endif

								EndIF

								( xZBZ )->( DbSetORder( nOrd ) )
								( xZBS )->( DbSetOrder( 3 ) )

								If .Not. ( xZBS )->(dbSeek( cChaveXml ) )

									cLogProc += cChaveXml + " Nova Chave Sincronizada NFeDistribuicaoDFe." + CRLF
									nCount++
									lRet := .T.

									if !Empty( cIE )

										_cFil := u_Gravafil( cCnpj, cIE )

										if Empty( xFilial(xZBS) )  //Verifica se for compartilhado

											_cFil := xFilial( xZBS )

										endif

									else

										_cFil := xFilial( xZBS )

									endif

									RecLock(xZBS, .T. )

									( xZBS )->(FieldPut(FieldPos(xZBS_+"FILIAL"),  _cFil ))   //XFilial(xZBS)
									( xZBS )->(FieldPut(FieldPos(xZBS_+"CHAVE")	,  cChaveXml ))
									( xZBS )->(FieldPut(FieldPos(xZBS_+"AMB")	,  cAmb ))
									( xZBS )->(FieldPut(FieldPos(xZBS_+"DEST")	,  cCnpj ))
									( xZBS )->(FieldPut(FieldPos(xZBS_+"IDENT")	,  cIdEnt ))

									If ( xZBS )->( FieldPos(xZBS_+"MODELO") ) > 0
										( xZBS )->(FieldPut(FieldPos(xZBS_+"MODELO"), Substr(cChaveXml,21,2) ))
									EndIF

									if (xZBS)->(FieldPos(xZBS_+"TPROT")) > 0 //Tipo de Rotina Job ou Manual

										if Empty(  (xZBS)->(FieldGet(FieldPos(xZBS_+"TPROT"))) )

											if Type("cTpRt") <> "U"

												(xZBS)->(FieldPut(FieldPos(xZBS_+"TPROT"), cTpRt ))

											endif

										endif

									endif

								Else

									cLogProc += cChaveXml + " Chave Ja esta na Sincronizacao NFeDistribuicaoDFe." + CRLF
									RecLock(xZBS, .F. )

								Endif

								if ! Empty( ( xZBS )->(FieldGet(FieldPos(xZBS_+"CSITCO"))) )

									if cSitConf == "4" .And. ( xZBS )->(FieldGet(FieldPos(xZBS_+"CSITCO"))) > "0"

										cSitConf := ( xZBS )->(FieldGet(FieldPos(xZBS_+"CSITCO")))

									Else

										if ( xZBS )->(FieldGet(FieldPos(xZBS_+"CSITCO"))) > cSitConf

											cSitConf := ( xZBS )->(FieldGet(FieldPos(xZBS_+"CSITCO")))

										endif

									Endif

								Endif

								( xZBS )->(FieldPut(FieldPos(xZBS_+"ST")	, cSt ))
								( xZBS )->(FieldPut(FieldPos(xZBS_+"CSITCO"), cSitConf ))
								( xZBS )->(FieldPut(FieldPos(xZBS_+"CNF")	, cNf ))
								( xZBS )->(FieldPut(FieldPos(xZBS_+"SERIE")	, cSer ))

								rstmvbuff()

								If GetNewPar( "XM_ESPIAO", "N" ) == "S"

									U_HFESPIAO( cChaveXml )

								EndIf

								If Type("oXml:_NFEPROC:_NFE:_INFNF:_EMIT:_CNPJ:TEXT") <> "U"

									if oXml:_NFEPROC:_NFE:_INFCTE:_EMIT:_CNPJ:TEXT = Substr(cChaveXml,7,14)

									Else

										cCnpjXml := oXml:_NFEPROC:_NFE:_INFCTE:_EMIT:_CNPJ:TEXT

									Endif

									( xZBS )->(FieldPut(FieldPos(xZBS_+"CNPJEM"), cCnpjXml ))

								Elseif Type("oXml:_RESNFE:_CNPJ:TEXT") <> "U"

									if oXml:_RESNFE:_CNPJ:TEXT = Substr(cChaveXml,1,14)

									Else

										cCnpjXml := oXml:_RESNFE:_CNPJ:TEXT

									Endif

									( xZBS )->(FieldPut(FieldPos(xZBS_+"CNPJEM"), cCnpjXml ))

								Endif

								if Empty(( xZBS )->(FieldGet(FieldPos(xZBS_+"CNPJEM")))) .And. Type("oXml:_NFEPROC:_NFE:_INFNFE:_EMIT:_CPF:TEXT") <> "U"

									( xZBS )->(FieldPut(FieldPos(xZBS_+"CNPJEM"), oXml:_NFEPROC:_NFE:_INFNFE:_EMIT:_CPF:TEXT ))

								elseif Empty(( xZBS )->(FieldGet(FieldPos(xZBS_+"CNPJEM")))) .And. Type("oXml:_RESNFE:_CPF:TEXT") <> "U"

									( xZBS )->(FieldPut(FieldPos(xZBS_+"CNPJEM"), oXml:_RESNFE:_CPF:TEXT ))

								endif

								If Type("oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_DHEMI:TEXT") <> "U"

									( xZBS )->(FieldPut(FieldPos(xZBS_+"DEMI"), VerData(oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_DHEMI:TEXT) ))

								Elseif Type("oXml:_RESNFE:_DHEMI:TEXT") <> "U"

									( xZBS )->(FieldPut(FieldPos(xZBS_+"DEMI"), VerData(oXml:_RESNFE:_DHEMI:TEXT) ))

								Endif

								If Type("oXml:_NFEPROC:_NFE:_INFNFE:_VPREST:_VTPREST:TEXT") <> "U"

									( xZBS )->(FieldPut(FieldPos(xZBS_+"VNF"), Val(oXml:_NFEPROC:_NFE:_INFNFE:_VPREST:_VTPREST:TEXT) ))

								ElseIf Type("oXml:_RESNFE:_VNF:TEXT") <> "U"

									( xZBS )->(FieldPut(FieldPos(xZBS_+"VNF"), Val(oXml:_RESNFE:_VNF:TEXT) ))

								Endif

								If Type("oXml:_NFEPROC:_NFE:_INFNFE:_EMIT:_XNOME:TEXT") <> "U"

									( xZBS )->(FieldPut(FieldPos(xZBS_+"XNOME"), oXml:_NFEPROC:_NFE:_INFNFE:_EMIT:_XNOME:TEXT ))

								ElseIf Type("oXml:_RESNFE:_XNOME:TEXT") <> "U"

									( xZBS )->(FieldPut(FieldPos(xZBS_+"XNOME"), oXml:_RESNFE:_XNOME:TEXT ))

								Endif

								If Type("oXml:_NFEPROC:_NFE:_INFNFE:_EMIT:_IE:TEXT") <> "U"

									( xZBS )->(FieldPut(FieldPos(xZBS_+"IE"),  oXml:_NFEPROC:_NFE:_INFNFE:_EMIT:_IE:TEXT ))

								ElseIf Type("oXml:_RESNFE:_IE:TEXT") <> "U"

									( xZBS )->(FieldPut(FieldPos(xZBS_+"IE"),  oXml:_RESNFE:_IE:TEXT ))

								Endif

								If Type("oXml:_NFEPROC:_PROTNFE:_INFPROT:_DIGVAL:TEXT") <> "U"

									( xZBS )->(FieldPut(FieldPos(xZBS_+"DIGVAL"), oXml:_NFEPROC:_PROTNFE:_INFPROT:_DIGVAL:TEXT ))

								ElseIf Type("oXml:_RESNFE:_DIGVAL:TEXT") <> "U"

									( xZBS )->(FieldPut(FieldPos(xZBS_+"DIGVAL"), oXml:_RESNFE:_DIGVAL:TEXT ))

								EndIf

								If Type("oXml:_NFEPROC:_PROTNFE:_INFPROT:_DHRECBTO:TEXT") <> "U"

									( xZBS )->(FieldPut(FieldPos(xZBS_+"DHRECB"), VerData(oXml:_NFEPROC:_PROTNFE:_INFPROT:_DHRECBTO:TEXT) ))

								ElseIf Type("oXml:_RESNFE:_DHRECBTO:TEXT") <> "U"

									( xZBS )->(FieldPut(FieldPos(xZBS_+"DHRECB"), VerData(oXml:_RESNFE:_DHRECBTO:TEXT) ))

								Endif

								If Type("oXml:_RESNFE:_CSITNFE:TEXT") <> "U"

									( xZBS )->(FieldPut(FieldPos(xZBS_+"CSITNF"), oXml:_RESNFE:_CSITNFE:TEXT ))

								Else

									( xZBS )->(FieldPut(FieldPos(xZBS_+"CSITNF"), "1" ))

								Endif

								If Type("oDoc["+alltrim(str(nReg))+"]:_NSU:TEXT") <> "U"

									( xZBS )->(FieldPut(FieldPos(xZBS_+"NSU"), oDoc[nReg]:_NSU:TEXT ))

								Endif

								//21/7/17
								If Type("oXml") <> "U"

									( xZBS )->(FieldPut(FieldPos(xZBS_+"XML"), cXml ))

								EndIF

								( xZBS )->(MsUnLock())

								lRet := .T.  //tem al menos um

								//Gravar ultimo NSU
								/*If Type("oDoc["+alltrim(str(nReg))+"]:_NSU:TEXT") <> "U"

									cNSU := oDoc[nReg]:_NSU:TEXT

									If !PutMv("XM_NSUNFE",cNSU)

										SX6->(RecLock("SX6",.T.))

										SX6->X6_FIL     := cFilAnt //xFilial( "SX6" )
										SX6->X6_VAR     := "XM_NSUNFE"
										SX6->X6_TIPO    := "C"
										SX6->X6_DESCRIC := "NSU download NFE por CNPJ via HF"

										SX6->(MsUnLock())

										PutMv("XM_NSUNFE",cNSU)

									EndIf

								Endif*/

								//Grava dados
								if UPPER(Substr(oDoc[nReg]:_SCHEMA:TEXT,1,6)) = UPPER("resNFe")
								
									slvxmlzbz(Substr(cChaveXml,1,44) + "-resuNFe.xml", .T.,.F.,NIL,@cLogProc,0, "2", Substr(cChaveXml,1,44), @cInfo, "R" )  //2=Downlaod Sefaz

								else

									slvxmlzbz(Substr(cChaveXml,1,44) + "-procNFe.xml", .T.,.F.,NIL,@cLogProc,0, "2", Substr(cChaveXml,1,44), @cInfo, " " )  //2=Downlaod Sefaz
									
								endif
								
								U_HFTrvXml("SOLTA", "ZBS"+cChaveXml, nHdl) //SOLTAR

							else

								If lMostra

									//			Alert(" Erro no travar ")

								endif

							Endif

						ElseIf UPPER(Substr(oDoc[nReg]:_SCHEMA:TEXT,1,9)) = UPPER("resEvento") .OR. UPPER(Substr(oDoc[nReg]:_SCHEMA:TEXT,1,10)) = UPPER("procEvento")

							//Atualizar ZBE / ZBS

							cChave      := ""
							cEvento     := ""
							cSeqEve     := "1"
							dDhAut      := ctod( "" )
							dDhRec      := ddatabase
							cProtC      := ""
							cXCorrecao  := ""
							cStatReg    := "2"

							if type( "oXml:_RESEVENTO:_CHNFE:TEXT" ) <> "U"

								cChave := oXml:_RESEVENTO:_CHNFE:TEXT

							else 

								if XmlChildEx(oXml:_PROCEVENTONFE:_EVENTO:_INFEVENTO, '_CHNFE') <> Nil

									cChave := oXml:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_CHNFE:TEXT

								endif

							endif

							if type( "oXml:_RESEVENTO:_TPEVENTO:TEXT" ) <> "U"

								cEvento := oXml:_RESEVENTO:_TPEVENTO:TEXT

							else 

								if XmlChildEx(oXml:_PROCEVENTONFE:_EVENTO:_INFEVENTO, '_TPEVENTO') <> Nil

									cEvento := oXml:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_TPEVENTO:TEXT

								endif

							endif

							if type( "oXml:_RESEVENTO:_NSEQEVENTO:TEXT" ) <> "U"

								cSeqEve := oXml:_RESEVENTO:_NSEQEVENTO:TEXT

							else 

								if XmlChildEx(oXml:_PROCEVENTONFE:_EVENTO:_INFEVENTO, '_NSEQEVENTO') <> Nil

									cSeqEve := oXml:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_NSEQEVENTO:TEXT

								endif

							endif

							if type( "oXml:_RESEVENTO:_DHEVENTO:TEXT" ) <> "U"

								dDhAut  := VerData(oXml:_RESEVENTO:_DHEVENTO:TEXT)

							else 

								if XmlChildEx(oXml:_PROCEVENTONFE:_EVENTO:_INFEVENTO, '_DHEVENTO') <> Nil

									dDhAut := VerData(oXml:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_DHEVENTO:TEXT)

								endif

							endif

							if type( "oXml:_RESEVENTO:_DHRECBTO:TEXT" ) <> "U"

								dDhRec  := VerData(oXml:_RESEVENTO:_DHRECBTO:TEXT)

							endif

							if type( "oXml:_RESEVENTO:_NPROT:TEXT" ) <> "U"

								cProtC  := oXml:_RESEVENTO:_NPROT:TEXT

							endif

							if type( "oXml:_RESEVENTO:_XEVENTO:TEXT" ) <> "U"

								cXCorrecao  := oXml:_RESEVENTO:_XEVENTO:TEXT

							else 

								if XmlChildEx(oXml:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_DETEVENTO, '_DESCEVENTO') <> Nil

									cXCorrecao := oXml:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_DETEVENTO:_DESCEVENTO:TEXT

								endif

							endif

							if Substr( cEvento,1,1 ) $ "12" .And. !Empty( cChave )

								aEvt := {}

								aadd( aEvt, {xZBE_+"DHAUT" 	, dDhAut    } )
								aadd( aEvt, {xZBE_+"DTRECB"	, dDhRec    } )
								aadd( aEvt, {xZBE_+"PROT"  	, cProtC    } )
								aadd( aEvt, {xZBE_+"XML"   	, cXml      } )
								aadd( aEvt, {xZBE_+"DESC"  	, cXCorrecao} )
								aadd( aEvt, {xZBE_+"EVENTO"	, cXCorrecao} )
								aadd( aEvt, {xZBE_+"STATUS"	, cStatReg  } )

								cGrv := U_HF2GrvEv( cChave, cEvento, cSeqEve, aEvt, .T. )

							Endif

						Else

							//							alert(UPPER (oDoc[nI]:_SCHEMA:TEXT) )

						Endif

					Next nReg

					if ! Empty( oWSrNfe:_RETDISTDFEINT:_ULTNSU:TEXT )  //cNSU > oWSrNfe:_RETDISTDFEINT:_ULTNSU:TEXT

						cNSU := oWSrNfe:_RETDISTDFEINT:_ULTNSU:TEXT

						if lMostra

							oRegua:IncRegua2( cNSU + " / " + oWSrNfe:_RETDISTDFEINT:_MAXNSU:TEXT )

						endif

						//alert(oWSrNfe:_RETDISTDFEINT:_ULTNSU:TEXT)

					endif

					If !PutMv("XM_NSUNFE",cNSU)

						SX6->(RecLock("SX6",.T.))

						SX6->X6_FIL     := cFilAnt //xFilial( "SX6" )
						SX6->X6_VAR     := "XM_NSUNFE"
						SX6->X6_TIPO    := "C"
						SX6->X6_DESCRIC := "NSU download NFE por CNPJ via HF"

						SX6->(MsUnLock())

						PutMv("XM_NSUNFE",cNSU)

					EndIf

					if oWSrNfe:_RETDISTDFEINT:_MAXNSU:TEXT > cNSU

						if cNSU <= cNSU2

							cNSU := StrZero( val(cNSU)+1,len(cNSU2),0 )
							/*
							//-----------------------------------------------------------------//
							//FR - 07/01/2020
							//Ajuste do NSU baseado no NSU do Xml caso o nosso estiver defasado
							//-----------------------------------------------------------------//

							cNSUXML := ""
							nDifNSU := 0
							cNSUXML := oWSrNfe:_RETDISTDFEINT:_MAXNSU:TEXT			//n˙mero do NSU no xml - FR 07/01/2020

							If cNSUXML > cNSU
							nDifNSU := Val(cNSUXML) - Val(cNSU)					//diferenÁa entre o n˙mero NSU do xml e o NSU do nosso par‚metro FR 07/01/2020
							If nDifNSU > 0
							cNSU := StrZero( val(cNSUXML)+1,len(cNSU2),0 )	//atualiza o valor do nosso NSU baseado no NSU do xml
							Endif
							Endif

							//FR - 07/01/2020 - ATIVAR O BLOCO ACIMA QDO VALIDADO PELA EQUIPE interna HF
							*/
						endif

						cIndCon := "1"

					else

						if !Empty(oWSrNfe:_RETDISTDFEINT:_MAXNSU:TEXT)

							cIndCon := "0"

						else

							cIndCon := "1"

						endif

					endif

					if lMostra

						oRegua:IncRegua2( cNSU + " / " + oWSrNfe:_RETDISTDFEINT:_MAXNSU:TEXT )

					endif

					If lMostra

						//	Alert(cNSU + " / " + oWSrNfe:_RETDISTDFEINT:_MAXNSU:TEXT)

					endif

					DelClassIntf()

					oDoc := NIL

					oWSrNfe := NIL

				Endif

			Else

				nErr++

				if nErr > 2

					cMsg  := "Erro de retorno do Sefaz."
					cInfo := "Erro de retorno do Sefaz. XML de retorno n„o contÈm a TAG <RETDOWNLOADNFE>"

					If lMostra

						U_MyAviso("SPED",cInfo,{"OK"},3)
						
					else
					
						Conout(cInfo)

					endif

					cIndCon := "2"
					nRet    := 2

				endif

			EndIf

		else

			//Erro TSS ou WS n„o instalado.
			nErr++

			if nErr > 2

				//nRet  := 2
				//cInfo := IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
				//cMsg  := "Erro TSS ou WS"
				//If lMostra
				//	U_MyAviso("SPED",cInfo,{"OK"},3)
				//else
				//	Conout(cInfo)
				//endif
				//cIndCon := "2"
				nRet  := 2
				cInfo := IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
				cMsg  := cFilAnt + " Falha no momento de conectar com a url do sefaz"

				if GetNewPar("XM_VISFAL","") == "S"
					if !IsBlind()
						U_MyAviso("HFXML6CD",cMsg+CRLF+cInfo,{"OK"},3)
					else
						Conout("HFXML6CD - "+CRLF+cMsg+CRLF+cInfo)
					endif
				else
					Conout("HFXML6CD - "+CRLF+cMsg+CRLF+cInfo)
				endif

				cIndCon := "2"

			else

				//Vai fazer de novo

			endif

		endif

		If cIndCon == "1"

			Sleep(1500) //Tempo para prÛxima execuÁ„o do mÈtodo SINCRONIZARDOCUMENTOS()

		Else

			Exit

		endif

	EndDo

ENDIF

//Incluido a func„o de Gravar.
If len(aEnvNfe ) > 0

	If U_HFENVMAIL(0)   //Retorna .T. se conseguiu enviar, se enviou grava

		U_HFGRVDADOS()

	endif

endif

aEnvNfe := Query15Dia(15)

If len(aEnvNfe ) > 0

	If U_HFENVMAIL(15)   //Retorna .T. se conseguiu enviar, se enviou grava

		U_HFGRVDADOS()

	endif

endif

oWSdNfe := Nil

DelClassIntf()  //aqui ja estava

Return( lRet )


Static Function Query15Dia(nQual)

Local aArea     := GetArea()
Local aRet      := {}
Local cAliasZBS := GetNextAlias()
Local cQuery    := ""
Local cDt       := dtos( dDataBase - nQual )
Local cChaveXml := ""

(xZBZ)->( dbSetOrder( 3 ) )

cQuery += " SELECT R_E_C_N_O_ as REG, "+xZBS_+"CHAVE as CHAVE from "+RetSqlName(xZBS)+" ZBS "
cQuery += " WHERE D_E_L_E_T_ = '' "
cQuery += " AND "+xZBS_+"FILIAL = '"+cFilAnt+"' "
cQuery += " AND "+xZBS_+"ESPIAO <> 'S' "
cQuery += " AND "+xZBS_+"DEMI >= '"+cDt+"' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasZBS)

DbSelectARea( cAliasZBS )
(cAliasZBS)->( dbGoTop() )

While .NOT. (cAliasZBS)->( Eof() )

	cChaveXml := (cAliasZBS)->CHAVE

	If  .NOT. (xZBZ)->( dbSeek( cChaveXml ) )

		aAdd(aRet, { cChaveXml,  ( cAliasZBS )->REG } )

	endif

	DbSelectARea( cAliasZBS )
	(cAliasZBS)->( dbSkip() )

End

(cAliasZBS)->( dbCloseArea() )

RestArea( aArea )

Return( aRet )


Static Function VerDigVal( cXml )

Local cErro:= "", cWarning:= ""
Local cRet := ""
//Local nTamFile := 0
Private oWSrNfe

cXml := fWNOAccent(cXml)
cXml := EncodeUTF8(cXml)

//Faz backup do xml sem retirar os caracteres especiais
cBkpXml := cXml

//Executa rotina para retirar os caracteres especiais
cXml := u_zCarEspec( cXml )

if Len(cXml) >= 65534

	oWSrNfe := U_PARSGDE( cXml, @cErro, @cWarning )

Else

	oWSrNfe := XmlParser( cXml, "_", @cErro, @cWarning )

endif

//retorna o backup do xml
cXml := cBkpXml

If oWSrNfe <> NIL .And. Empty(cErro)

	if Type( "oWSrNfe:_RESNFE:_DIGVAL:TEXT" ) <> "U"

		cRet := oWSrNfe:_RESNFE:_DIGVAL:TEXT

	Endif

Endif

DelClassIntf()

Return cRet


Static Function manifver(cChave,cURL,cIdEnt,cAmb)

Local cRet := "4"
//Local oWs2
//Local oWSrNfe
//Local cXml := "",cErro:= "",cWarning:= ""

Return( cRet )


/*Static Function verManifes(xManif,oWSrNfe)  //GETESB2

Local cRet := xManif
Local cUlt := ""
Local cDth := ""
Local nI   := 0

Private oRet := oWSrNfe
Private oEve

if Type( "oWSrNfe:_RETCONSSITNFE:_PROCEVENTONFE" ) <> "U"

	oEve := oWSrNfe:_RETCONSSITNFE:_PROCEVENTONFE
	oEve := iif( ValType(oEve) == "O", {oEve}, oEve )

	nTotLen := Len( oEve )

	For nI := 1 To nTotLen

		if Type( "oEve["+Alltrim(str(nI))+"]:_RETEVENTO:_INFEVENTO:_TPEVENTO" ) <> "U" .And. Type( "oEve["+Alltrim(str(nI))+"]:_RETEVENTO:_INFEVENTO:_DHREGEVENTO" ) <> "U"

			if oEve[nI]:_RETEVENTO:_INFEVENTO:_TPEVENTO:TEXT $ "210200,210210,210220,210240"

				if oEve[nI]:_RETEVENTO:_INFEVENTO:_DHREGEVENTO:TEXT > cDth

					cDth := oEve[nI]:_RETEVENTO:_INFEVENTO:_DHREGEVENTO:TEXT

					cUlt := oEve[nI]:_RETEVENTO:_INFEVENTO:_TPEVENTO:TEXT

				endif

			EndIF

		endif

	Next nI

	if cUlt $ "210200,210210,210220,210240"

		if cUlt $ "210200"

			cRet := "1"

		elseif cUlt $ "210210"

			cRet := "4"

		elseif cUlt $ "210220"

			cRet := "2"

		elseif cUlt $ "210240"

			cRet := "3"

		endif

	endif

EndIf

Return( cRet )*/


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…››››››››››—››››››››››À›››››››—››››››››››››››››››››À››››››—›››››››››››››ª±±
±±∫Programa  ≥ HFXML6DC ∫Autor  ≥ Eneo               ∫ Data ≥             ∫±±
±±Ã››››››››››ÿ›››››››››› ›››››››››››››››››››››››››››› ››››››››››››››››››››π±±
±±∫Desc.     ≥ Consultar CNPJ do Destinat·rio via WS para CTe.            ∫±±
±±∫          ≥                                                            ∫±±
±±Ã››››››››››ÿ››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››π±±
±±∫Uso       ≥ Geral                                                      ∫±±
±±»›››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
User Function HFXML6DC(cCnpj, lMostra, cLogProc, nImp, nCount, lEnd, oRegua)  //Cte na veia.

Local lRet   := .F.
Local nHdl   := -1
Local cURL   := ""
Local cAmb   := "1"
Local cXml   := ""
Local cIdEnt := U_GetIdEnt()
Local cUF    := VerUfMat( cCnpj )
Local cVerLay:= "1.00"
Local cIndCon:= "1"
Local cSitConf  := ""
Local cDir   := AllTrim(SuperGetMv("MV_X_PATHX"))
Local cChaveXml := Space(44)
Local cCancNSU  := ""
//Local nVzNaoSinc:= 0
Local nOrd 		:= 0
Local cSt       := " "
Local cNf       := Space(9)
Local cSer      := Space(3)
Local cErro:="",cWarning:=""
//Local nX := 0 //declaracao
Local cChave := ""
Local cNSU   := "000000000000000"
Local cSitConf  := ""
Local cChaveXml := ""
Local cNf       := ""
Local cSer      := ""
//Local cCnpjXml  := ""
Local cCnpjDest := ""
Local nI := 0

Default cLogProc := ""
Default nImp     := 2
Default nCount   := 0
Default lEnd	 :=	.F.
Default oRegua	 :=	Nil

Private cTagNfe, cTagCan, cTagCce, oWs, oWsrNfe, oWsdNfe, aDocs
Private aEnvNfe	:=	{}  //Criado para funÁ„o espi„o na data 11/12/2015 veio do outro

cInfo := ""
cMsg  := ""

cURL      := AllTrim(GetNewPar("XM_URL",""))

If Empty(cURL)

	cURL  := AllTrim(SuperGetMv("MV_SPEDURL"))

EndIf

If Right( AllTrim(cURL), 1 ) != "/"

	cURL := AllTrim(cURL)+"/"

EndIf

DbSelectArea( xZBS )

rstmvbuff()

// Tratamento da numeracao
cNSU := ( GetNewPar("XM_NSUCTE","000000000000000",cFilAnt) )

If !PutMv("XM_NSUCTE",cNSU)

	SX6->(RecLock("SX6",.T.))

	SX6->X6_FIL     := cFilAnt //xFilial( "SX6" )
	SX6->X6_VAR     := "XM_NSUCTE"
	SX6->X6_TIPO    := "C"
	SX6->X6_DESCRIC := "NSU download CTE por CNPJ"

	SX6->(MsUnLock())

	PutMv("XM_NSUCTE",cNSU)

EndIf

cVerLay := ( GetNewPar("XM_VERLCTE","1.00",cFilAnt) )

If !PutMv("XM_VERLCTE",cVerLay)

	SX6->(RecLock("SX6",.T.))

	SX6->X6_FIL     := cFilAnt //xFilial( "SX6" )
	SX6->X6_VAR     := "XM_VERLCTE"
	SX6->X6_TIPO    := "C"
	SX6->X6_DESCRIC := "Vers„o Layout download CTE por CNPJ"
	SX6->(MsUnLock())

	PutMv("XM_VERLCTE",cVerLay)

EndIf

cAmb := ( GetNewPar("XM_AMBCTE","1",cFilAnt) )

If !PutMv("XM_AMBCTE",cAmb)

	SX6->(RecLock("SX6",.T.))

	SX6->X6_FIL     := cFilAnt //xFilial( "SX6" )
	SX6->X6_VAR     := "XM_AMBCTE"
	SX6->X6_TIPO    := "C"
	SX6->X6_DESCRIC := "Ambiente download CTE por CNPJ"
	SX6->(MsUnLock())

	PutMv("XM_AMBCTE",cAmb)

EndIf

While cIndCon == "1"

	If lMostra

		If lEnd

			MsgStop("*** Cancelado pelo Operador ***","Fim")
			lRet := .F.
			Exit

		EndIf

		oRegua:IncRegua1("Acessando Metodo CTeDistrDfe SEFAZ...")
		oRegua:IncRegua2("CTeDistrDfe SEFAZ" )

	EndIf

	oWSdNfe:= WSHFXMLCTEDISTRIBUICAODFE():New()
	oWSdNfe:Init()
	oWSdNfe:cCIDENT       := cIdEnt
	oWSdNfe:cCCURL        := cURL
	oWSdNfe:cCAMBIENTE    := cAmb
	oWSdNfe:cCVERSAODADOS := cVerLay //Parametro exclosivis
	oWSdNfe:cCCUF         := cUF     //Parametro exclosivis //"91" //"35" //substr(cChave,1,2) //"AN"  //ver isso aqui, È o Estado, agora vem de 1 em 1
	oWSdNfe:cCCNPJ        := cCnpj
	oWSdNfe:cCCHSTR       := cNSU    //Parametro exclosivis

	if oWSdNfe:HFCTEDISTRDFE()

		cXml := "<"+AllTrim(oWSdNfe:cHFCTEDISTRDFERESULT)
		nAt1:= At('<RETDISTDFEINT ',Upper(cXml))
		nAt2:= At('</RETDISTDFEINT>',Upper(cXml))+ 16

		//Corpo do XML
		If nAt1 <= 0

			nAt1:= At('<RETDISTDFEINT>',Upper(cXml))

		EndIf

		If nAt1 > 0 .And. nAt2 > 16

			cNfe := Substr(cXml,nAt1,nAt2-nAt1)

			cXml:= '<?xml version="1.0" encoding="UTF-8"?>'
			cXml+= cNfe
			//cXml := NoAcento(cXml)
			cXml := EncodeUTF8(cXml)

			//Primeiro parse sem checagem de caracteres especiais
			if Len(cXml) >= 65534

				oWSrNfe := U_PARSGDE( cXml, @cErro, @cWarning )

			Else

				oWSrNfe := XmlParser( cXml, "_", @cErro, @cWarning )

			endif

			//Caso for nil faz a segunda checagem somente para aqueles xml¥s que tem caracteres especiais
			if oWSrNfe == NIL 

				//Faz backup do xml sem retirar os caracteres especiais
				cBkpXml := cXml

				cXml := fWNOAccent(cXml)  //NoAcento(cXml)
				cXml := EncodeUTF8(cXml)

				//Executa rotina para retirar os caracteres especiais
				cXml := u_zCarEspec( cXml )

				if Len(cXml) >= 65534

					oWSrNfe := U_PARSGDE( cXml, @cErro, @cWarning )

				Else

					oWSrNfe := XmlParser( cXml, "_", @cErro, @cWarning )

				endif

				//retorna o backup do xml
				cXml := cBkpXml

			endif

			If oWSrNfe == NIL //.Or. !Empty(cErro) .Or. !Empty(cWarning)

				cMsg   := "Erro Parser do XML de Resposta"
				cInfo  := cErro + " " + cWarning
				cIndCon:= "2"
				nRet   := 2
				//U_MyAviso("SPED",cInfo,{"OK"},3)

			elseIf oWSrNfe:_RETDISTDFEINT:_CSTAT:TEXT <> "138" //"139"

				cMsg   := "Retorno do Sefaz "+oWSrNfe:_RETDISTDFEINT:_CSTAT:TEXT
				cInfo  := oWSrNfe:_RETDISTDFEINT:_XMOTIVO:TEXT

				if oWSrNfe:_RETDISTDFEINT:_CSTAT:TEXT = "656"  //Consumo indevido

					nRet  := 3   //volta o 3 para tentar por DFE em 10/09/18
					cInfo := Upper(cInfo+"("+oWSrNfe:_RETDISTDFEINT:_CSTAT:TEXT+")")  //"Consumo Indevido"

					if !IsBlind()
						U_MyAviso("HFXML6DC",cMsg+CRLF+cInfo,{"OK"},3)
					else
						Conout("HFXML6DC"+CRLF+cMsg+CRLF+cInfo)
					endif

					Return(.F.)

				EndIf

				IF oWSrNfe:_RETDISTDFEINT:_CSTAT:TEXT <> "137"

					cInfo  := "DOCUMENTO N√O DISPONIVEL PARA DOWNLOAD VIA WEB SERVICE (DF-e)"

				Endif

				cIndCon:= "2"

				nRet   := 2

			Else

				oDoc := oWSrNfe:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP
				oDoc := iif( valtype(oDoc)=="O", {oDoc}, oDoc )

				nTotLen := Len( oDoc )

				For nI := 1 to nTotLen  //Deixar assim para quando for mais de 1, mas agora tem que ser de 1 em 1.

					cStt  := ""
					cMsg  := ""
					cInfo := ""
					cChave:= ""

					if Empty( oDoc )

						if !IsBlind()
							U_MyAviso("HFXML06Bai","Objeto do sefaz vazio",{"OK"},3)
						else
							Conout("HFXML06Bai - Objeto do sefaz vazio")
						endif

						Exit

					endif

					cFileZip	:= Decode64( oDoc[nI]:TEXT )
					nLenZip		:= Len( cFileZip )
					cFileUnZip  := ""

					// Funcao de descompactacao de arquivos compactados no formato GZip
					lOk  :=  GzStrDecomp( cFileZip, nLenZip, @cFileUnZip )
					oXml := XmlParser( cFileUnZip, "_", @cErro, @cWarning )

					//AlteraÁ„o em 13/04/2017, erro SalOnline
					//If UPPER(Substr(oDoc[nI]:_SCHEMA:TEXT,1,7)) <> UPPER("procCTe") //"139"
					//	cMsg	:=	"633"
					//	cInfo	:=	"Falta ManifestaÁ„o do Destinat·rio."
					//	cStt	:=	"0"
					If valtype(oXml) <> "O"

						cMsg	:=	"XXX"
						cInfo	:=	"N„o foi possÌvel Descompactar o XML."
						cStt	:=	"0"

					ElseIf UPPER(Substr(oDoc[nI]:_SCHEMA:TEXT,1,7)) = UPPER("procCTe")

						If UPPER(Substr(oDoc[nI]:_SCHEMA:TEXT,1,7)) = UPPER("procCTe")

							if Type("oXml:_CTEPROC:_PROTCTE:_INFPROT:_CHCTE:TEXT") <> "U"

								cChave := alltrim( oXml:_CTEPROC:_PROTCTE:_INFPROT:_CHCTE:TEXT )

							Else

								cChave := "nEnc"

							Endif

							cChaveArq := cDir + cChave + "-procCte.xml" //alltrim( oDoc[nI]:_CHNFE:TEXT ) + "-procNfe.xml"

						Elseif UPPER(Substr(oDoc[nI]:_SCHEMA:TEXT,1,13)) = UPPER("procEventoCTe")

							if Type("oXml:_CTEPROC:_PROTCTE:_INFPROT:_CHCTE:TEXT") <> "U"

								cChave := alltrim( oXml:_CTEPROC:_PROTCTE:_INFPROT:_CHCTE:TEXT )

							Else

								cChave := "nEnc"

							Endif

							cChaveArq := cDir + cChave + "-procEventoCte.xml" //alltrim( oDoc[nI]:_CHNFE:TEXT ) + "-procNfe.xml"

						EndIF

						if lMostra

							oRegua:IncRegua2( cChave )

						endif

						SAVE oXml XMLSTRING cXML
						nAt1:= At('<CTE ',Upper(cXml))
						nAt2:= At('</CTE>',Upper(cXml))+ 6

						//Corpo da Nfe
						If nAt1 <= 0

							nAt1:= At('<CTE>',Upper(cXml))

						EndIf

						If nAt1 > 0 .And. nAt2 > 6

							cNfe := Substr(cXml,nAt1,nAt2-nAt1)

						Else

							cStt  := "0"
							cMsg  := "Xml Retorno Inv·lido"
							cInfo := "XML "+cChave+" sem TAG <CTE>"

						EndIf

						nAt3 := At('<PROTCTE ',Upper(cXml))
						nAt4 := At('</PROTCTE>',Upper(cXml))+ 10

						//Protocolo
						If nAt3 > 0 .And. nAt4 > 10

							cProt := Substr(cXml,nAt3,nAt4-nAt3)

						Else

							cStt  := "0"
							cMsg  := "Xml Retorno Inv·lido"
							cInfo += "XML "+cChave+" sem Protocolo, falta TAG <PROTCTE>"

						EndIf

						if empty( cMsg )

							//cXml:= '<?xml version="1.0"?>'
							cXml := '<?xml version="1.0" encoding="UTF-8"?>'
							cXml += '<cteProc versao="2.00" xmlns="http://www.portalfiscal.inf.br/cte">'
							cXml += cNfe
							cXml += cProt
							cXml += '</cteProc>'
							cXml := EncodeUTF8(cXml)
							cXml := FwNoAccent(cXml)							

							cSitConf  := "9"   //N„o tem manifestaÁ„o no CTE
							cChaveXml := cChave
							cCancNSU  := oDoc[nI]:_NSU:TEXT //ver a bagaÁa
							nOrd      := (xZBZ)->( IndexOrd() )
							cNf       := Substr( cChaveXml, 26, 9 )
							cSer      := Substr( cChaveXml, 23, 3 )
							cSt       := "  "
							cCnpjDest := ""

							If Type("oXml:_CTEPROC:_CTE:_INFCTE:_DEST:_CNPJ:TEXT") <> "U"

								cCnpjDest := oXml:_CTEPROC:_CTE:_INFCTE:_DEST:_CNPJ:TEXT

							Endif

							nHdl := -1

							If U_HFTrvXml("TRAVA", "ZBS"+cChaveXml, @nHdl)

								( xZBZ )->( DbSetOrder( 3 ) )

								If ( xZBZ )->(dbSeek( cChaveXml ) )

									cSt := "10"

								Else

									if cSitConf <> "0"

										cSt := "20"

									Endif

								EndIF

								//Tratar tag <TOMA3>
								cTomador := ""

								If Type("oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_TOMA03:_TOMA:TEXT") <> "U"

									cT3	:= 	oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_TOMA03:_TOMA:TEXT

								ElseIf Type("oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_TOMA3:_TOMA:TEXT")<> "U"

									cT3	:=	oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_TOMA3:_TOMA:TEXT

								ElseIf Type("oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_TOMA4:_TOMA:TEXT")<> "U"

									cT3	:= oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_TOMA4:_TOMA:TEXT

								Endif

								Do Case

									Case cT3	==	'0' .and. type("oXml:_CTEPROC:_CTE:_INFCTE:_REM:_CNPJ:TEXT") <> "U"

									cTomador :=  oXml:_CTEPROC:_CTE:_INFCTE:_REM:_CNPJ:TEXT

									Case cT3	==	'1' .and. type("oXml:_CTEPROC:_CTE:_INFCTE:_EXPED:_CNPJ:TEXT") <> "U"

									cTomador :=  oXml:_CTEPROC:_CTE:_INFCTE:_EXPED:_CNPJ:TEXT

									Case cT3	==	'2' .and. type("oXml:_CTEPROC:_CTE:_INFCTE:_RECEB:_CNPJ:TEXT") <> "U"

									cTomador :=  oXml:_CTEPROC:_CTE:_INFCTE:_RECEB:_CNPJ:TEXT

									Case cT3	==	'3' .and. type("oXml:_CTEPROC:_CTE:_INFCTE:_DEST:_CNPJ:TEXT") <> "U"

									cTomador :=  oXml:_CTEPROC:_CTE:_INFCTE:_DEST:_CNPJ:TEXT

									Case cT3	==	'4' .and. type("oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_TOMA4:_CNPJ:TEXT") <> "U"

									cTomador :=  oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_TOMA4:_CNPJ:TEXT

									OtherWise

									if  type("oXml:_CTEPROC:_CTE:_INFCTE:_REM:_CNPJ:TEXT") <> "U"

										cTomador :=  oXml:_CTEPROC:_CTE:_INFCTE:_REM:_CNPJ:TEXT

									else

										cTomador :=  " "

									endif

								EndCase

								if type("oXml:_CTEPROC:_CTE:_INFCTE:_DEST:_IE:TEXT") <> "U"
								
									cIE := oXml:_CTEPROC:_CTE:_INFCTE:_DEST:_IE:TEXT
									
								else
								
									cIE := ""  
									
								endif

								cFilToma := u_GravaFil(cTomador,cIE)

								if empty(cFilToma)

									U_HFTrvXml("SOLTA", "ZBS"+cChaveXml, nHdl) //SOLTAR

									Sleep(1500) //da 1 segundo e vai de novo

									Loop

								endif

								( xZBZ )->( DbSetORder( nOrd ) )
								( xZBZ )->( DbSetOrder( 3 ) )

								If .Not. ( xZBS )->(dbSeek( cChaveXml ) )

									//if cCnpjDest <> cCnpj
									//	cLogProc += cChaveXml+" CNPJ "+cCnpjDest+" Difere "+cCnpj+" na Sincronizada NFeDistribuicaoDFe."+CRLF
									//	U_HFTrvXml("SOLTA", "ZBS"+cChaveXml, nHdl) //SOLTAR
									//	Loop
									//endif
									//Conout("Download do CTE " + cChaveXml)
									cLogProc += cChaveXml+" Nova Chave Sincronizada NFeDistribuicaoDFe."+CRLF
									nCount++
									lRet := .T.

									RecLock(xZBS, .T. )

									( xZBS )->(FieldPut(FieldPos(xZBS_+"FILIAL"), cFilToma ))
									( xZBS )->(FieldPut(FieldPos(xZBS_+"CHAVE")	,  cChaveXml ))
									( xZBS )->(FieldPut(FieldPos(xZBS_+"AMB")	,  cAmb ))
									( xZBS )->(FieldPut(FieldPos(xZBS_+"DEST")	,  cCnpjDest ))
									( xZBS )->(FieldPut(FieldPos(xZBS_+"IDENT")	,  cIdEnt ))

									If ( xZBS )->( FieldPos(xZBS_+"MODELO") ) > 0

										( xZBS )->(FieldPut(FieldPos(xZBS_+"MODELO"), Substr(cChaveXml,21,2) ))

									EndIF

									if (xZBS)->(FieldPos(xZBS_+"TPROT")) > 0 //Tipo de Rotina Job ou Manual

										if Empty(  (xZBS)->(FieldGet(FieldPos(xZBS_+"TPROT"))) )

											if Type("cTpRt") <> "U"

												(xZBS)->(FieldPut(FieldPos(xZBS_+"TPROT"), cTpRt ))

											endif

										endif

									endif

								Else

									cLogProc += cChaveXml+" Chave Ja esta na Sincronizacao NFeDistribuicaoDFe."+CRLF

									RecLock(xZBS, .F. )

									( xZBS )->(FieldPut(FieldPos(xZBS_+"DEST")	,  cCnpjDest ))

								Endif

								( xZBS )->(FieldPut(FieldPos(xZBS_+"ST")	, cSt ))
								( xZBS )->(FieldPut(FieldPos(xZBS_+"CSITCO"), cSitConf ))
								( xZBS )->(FieldPut(FieldPos(xZBS_+"CNF")	, cNf ))
								( xZBS )->(FieldPut(FieldPos(xZBS_+"SERIE")	, cSer ))

								//Faz backup do xml sem retirar os caracteres especiais
								cBkpXml := cXml

								//Executa rotina para retirar os caracteres especiais
								cXml := u_zCarEspec( cXml )

								if Len(cXml) >= 65534

									oXML := U_PARSGDE( cXml, @cErro, @cWarning )

								Else

									oXml := XmlParser( cXml, "_", @cErro, @cWarning )

								endif

								//retorna o backup do xml
								cXml := cBkpXml

								rstmvbuff()

								If GetNewPar( "XM_ESPIAO", "N" ) == "S"

									U_HFESPIAO( cChaveXml )

								EndIf

								If Type("oXml:_CTEPROC:_CTE:_INFCTE:_EMIT:_CNPJ:TEXT") <> "U"

									( xZBS )->(FieldPut(FieldPos(xZBS_+"CNPJEM"), oXml:_CTEPROC:_CTE:_INFCTE:_EMIT:_CNPJ:TEXT ))

								Endif

								if Empty(( xZBS )->(FieldGet(FieldPos(xZBS_+"CNPJEM")))) .And. Type("oXml:_CTEPROC:_CTE:_INFCTE:_EMIT:_CPF:TEXT") <> "U"

									( xZBS )->(FieldPut(FieldPos(xZBS_+"CNPJEM"), oXml:_CTEPROC:_CTE:_INFCTE:_EMIT:_CPF:TEXT ))

								endif

								If Type("oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_DHEMI:TEXT") <> "U"

									( xZBS )->(FieldPut(FieldPos(xZBS_+"DEMI"), VerData(oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_DHEMI:TEXT) ))

								Endif

								If Type("oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_VTPREST:TEXT") <> "U"

									( xZBS )->(FieldPut(FieldPos(xZBS_+"VNF"), Val(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_VTPREST:TEXT) ))

								Endif

								If Type("oXml:_CTEPROC:_CTE:_INFCTE:_EMIT:_XNOME:TEXT") <> "U"

									( xZBS )->(FieldPut(FieldPos(xZBS_+"XNOME"), oXml:_CTEPROC:_CTE:_INFCTE:_EMIT:_XNOME:TEXT ))

								Endif

								If Type("oXml:_CTEPROC:_CTE:_INFCTE:_EMIT:_IE:TEXT") <> "U"

									( xZBS )->(FieldPut(FieldPos(xZBS_+"IE"),  oXml:_CTEPROC:_CTE:_INFCTE:_EMIT:_IE:TEXT ))

								Endif

								If Type("oXml:_CTEPROC:_PROTCTE:_INFPROT:_DIGVAL:TEXT") <> "U"

									( xZBS )->(FieldPut(FieldPos(xZBS_+"DIGVAL"), oXml:_CTEPROC:_PROTCTE:_INFPROT:_DIGVAL:TEXT ))

								EndIf

								If Type("oXml:_CTEPROC:_PROTCTE:_INFPROT:_DHRECBTO:TEXT") <> "U"

									( xZBS )->(FieldPut(FieldPos(xZBS_+"DHRECB"), VerData(oXml:_CTEPROC:_PROTCTE:_INFPROT:_DHRECBTO:TEXT) ))

								Endif

								//If Type("oWSdNfe:OWSRETORNARDOCUMENTORESULT:OWSDOCUMENTO:cSITUACAO") <> "U"
								//	( xZBS )->(FieldPut(FieldPos(xZBS_+"CSITNF"), oWSdNfe:OWSRETORNARDOCUMENTORESULT:OWSDOCUMENTO:cSITUACAO ))
								//Endif
								//If Type("oWSdNfe:OWSRETORNARDOCUMENTORESULT:OWSDOCUMENTO:cNSU") <> "U"

								( xZBS )->(FieldPut(FieldPos(xZBS_+"NSU"), oDoc[nI]:_NSU:TEXT ))

								//Endif
								//If Type("oWSdNfe:OWSRETORNARDOCUMENTORESULT:OWSDOCUMENTO:OWSCCE:cCCEXMLRET") <> "U"  //cCORRECAO 21/7/17
								//	( xZBS )->(FieldPut(FieldPos(xZBS_+"CORREC"), oWSdNfe:OWSRETORNARDOCUMENTORESULT:OWSDOCUMENTO:OWSCCE:cCCEXMLRET ))
								//EndIf

								//21/7/17
								If Type("oXml") <> "U"

									( xZBS )->(FieldPut(FieldPos(xZBS_+"XML"), cXml ))

								EndIF

								( xZBS )->(FieldPut(FieldPos(xZBS_+"TOMA"), cTomador ))
								( xZBS )->(MsUnLock())

								lRet := .T.  //tem al menos um
								//Gravar ultimo NSU
								cNSU := oDoc[nI]:_NSU:TEXT

								If !PutMv("XM_NSUCTE",cNSU)

									SX6->(RecLock("SX6",.T.))

									SX6->X6_FIL     := cFilAnt //xFilial( "SX6" )
									SX6->X6_VAR     := "XM_NSUCTE"
									SX6->X6_TIPO    := "C"
									SX6->X6_DESCRIC := "NSU download CTE por CNPJ"

									SX6->(MsUnLock())

									PutMv("XM_NSUCTE",cNSU)

								EndIf

								U_HFTrvXml("SOLTA", "ZBS"+cChaveXml, nHdl) //SOLTAR

							EndIF

						Endif

					Endif

				Next nI

				cNSU := oWSrNfe:_RETDISTDFEINT:_ULTNSU:TEXT

				If !PutMv("XM_NSUCTE",cNSU)

					SX6->(RecLock("SX6",.T.))

					SX6->X6_FIL     := cFilAnt //xFilial( "SX6" )
					SX6->X6_VAR     := "XM_NSUCTE"
					SX6->X6_TIPO    := "C"
					SX6->X6_DESCRIC := "NSU download CTE por CNPJ"
					SX6->(MsUnLock())

					PutMv("XM_NSUCTE",cNSU)

				EndIf

				if oWSrNfe:_RETDISTDFEINT:_MAXNSU:TEXT > cNSU

					cIndCon := "1"

				else

					cIndCon := "0"

				endif

				DelClassIntf()

				oDoc := NIL

				oWSrNfe := NIL

			Endif

		Else

			cMsg  := "Erro de retorno do Sefaz."
			cInfo := "Erro de retorno do Sefaz. XML de retorno n„o contÈm a TAG <RETDOWNLOADNFE>"
			//U_MyAviso("SPED",cInfo,{"OK"},3)
			cIndCon := "2"
			nRet    := 2

		EndIf

	else

		//Erro TSS ou WS n„o instalado.
		nRet  := 2
		cInfo := IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
		cMsg  := cFilAnt + " Falha no momento de conectar com a url do sefaz"

		if GetNewPar("XM_VISFAL","") == "S"
			if !IsBlind()
				U_MyAviso("HFXML6DC",cMsg+CRLF+cInfo,{"OK"},3)
			else
				Conout("HFXML6DC - "+CRLF+cMsg+CRLF+cInfo)
			endif
		else
			Conout("HFXML6DC- "+CRLF+cMsg+CRLF+cInfo)
		endif

		cIndCon := "2"

	endif

	If cIndCon == "1"

		Sleep(1500) //Tempo para prÛxima execuÁ„o do mÈtodo SINCRONIZARDOCUMENTOS()

	Else

		Exit

	endif

EndDo

//Incluido a func„o de Gravar.
If Len(aEnvNfe ) > 0

	If U_HFENVMAIL(0)   //Retorna .T. se conseguiu enviar, se enviou grava

		U_HFGRVDADOS()

	EndIf

EndIf

aEnvNfe := Query15Dia(15)

If len(aEnvNfe ) > 0

	If U_HFENVMAIL(15)   //Retorna .T. se conseguiu enviar, se enviou grava

		U_HFGRVDADOS()

	endif

endif

oWSdNfe := Nil

DelClassIntf()  //aqui ja estava

Return( lRet )


//Para Keijos Hipanema
User Function GravaFil( cTomador, cIE )

Local cRet := ""
Local aArea := Getarea()
Local nReg  := SM0->(recno())
Local cEmpProc:= AllTrim(SM0->M0_CODIGO)
//Local cFilProc:= AllTrim(SM0->M0_CODFIL)

SM0->( dbgotop() )

Do While !SM0->( Eof() )

	If Alltrim(SM0->M0_CODIGO) == cEmpProc .and. alltrim(SM0->M0_CGC) == cTomador .and.  alltrim(SM0->M0_INSC) == cIE    //Alltrim(SM0->M0_CODIGO) == cEmpProc .and. SM0->M0_CGC == cTomador

		cRet := SM0->M0_CODFIL
		Exit

	EndIf

	SM0->( dbskip() )

EndDo

if Empty( cRet )

	cRet := cFilAnt

endif

SM0->(dbgoto( nReg ))

RestArea( aArea )

Return Alltrim( cRet )

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…››››››››››—››››››››››À›››››››—››››››››››››››››››››À››››››—›››››››››››››ª±±
±±∫Programa  ≥ HFXML6BS ∫Autor  ≥ Eneo               ∫ Data ≥             ∫±±
±±Ã››››››››››ÿ›››››››››› ›››››››››››››››››››››››››››› ››››››››››››››››››››π±±
±±∫Desc.     ≥ Alimentar TMP com os ultimos 30 dias da Tabela ZBS         ∫±±
±±∫          ≥ Download por NSU. Funciona via job                         ∫±±
±±Ã››››››››››ÿ››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››π±±
±±∫Uso       ≥ Geral                                                      ∫±±
±±»›››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
User Function HFXML6BS(cCnpj, lMostra, cLogProc, nImp, cModelo, lEnd, oRegua)

Local lRet		:= .F.
Local aArea     := GetArea()
Local dAutor    := dDataBase - GetNewPAr("XM_QDIADWN", 90)  //Por no painel um dia que der tempo //evitar a fadiga
Local cChaveXml := Space(44)
Local cCodFor   := Space( 6 )
Local cLojFor   := Space( 2 )
Local cFilSek   := "  "
//Local lSharedA1 := U_IsShared("SA1")
//LOCAL lSharedA2 := U_IsShared("SA2")
Local nOrd 		:= 0, nSim := 0, nNao := 0, nRep := 0
//Local cModAtu   := ""
Local cAliasZBS := GetNextAlias()
Local cQuery    := ""
Local nTotReg   := 0

//alert(GetNewPAr("XM_QDIADWN", 90))
//alert(dAutor)

Default cLogProc := ""
Default nImp     := 2
Default cModelo  := ""
Default lEnd     := .F.
Default oRegua   := NIL

rstmvbuff()

DbSelectArea( xZBZ )
nOrd := ( xZBZ )->( indexOrd() )
DbSetORder( 3 )

DbSelectArea( xZBS )
DbSetORder( 7 )

cQuery += " SELECT R_E_C_N_O_ as REG, "+xZBS_+"CHAVE as CHAVE from "+RetSqlName(xZBS)+" ZBS "
cQuery += " WHERE D_E_L_E_T_ = ' ' "
cQuery += " AND "+xZBS_+"FILIAL = '"+xFilial( xZBS )+"' "

if cModelo == "55"

	cQuery += " and "+xZBS_+"MODELO in ('  ','55') "  //fadigando

elseif cModelo == "57"

	cQuery += " and "+xZBS_+"MODELO = '"+cModelo+"' "

endif

//se n„o enviar modelo, vai todos
cQuery += " and "+xZBS_+"DEMI >= '"+dtos(dAutor)+"' "  //Fadigando tambÈm

//cQuery += " and "+xZBS_+"CSITNF <> '3' "  //Cancelada

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasZBS)

Count To nTotReg

if lMostra

	oRegua:SetRegua1( nTotReg )
	oRegua:SetRegua2(0)

endif

DbSelectARea( cAliasZBS )
(cAliasZBS)->( dbGoTop() )

While .NOT. (cAliasZBS)->( Eof() )

	cChaveXml := (cAliasZBS)->CHAVE

	( xZBS )->( dbGoto( (cAliasZBS)->REG ) )

	if lMostra

		If lEnd

			MsgStop("*** Cancelado pelo Operador ***","Fim")
			Exit

		EndIf

		oRegua:IncRegua1("Sincronizando Chaves para Download...")

	endif

	//cChaveXml := ( xZBS )->( FieldGet( FieldPos( xZBS_+"CHAVE" ) ) )

	If nImp == 2

		DbSelectArea( xZBZ )

		If ( xZBZ )->( dbSeek( cChaveXml ) )

			DbSelectARea( cAliasZBS )

			( cAliasZBS )->( dbskip() )

			nNao++

			LOOP

		EndIf

	EndIf

	if lMostra

		oRegua:IncRegua2(cChaveXml)

	endif

	DbSelectArea( "TMPSQL" )
	TMPSQL->( DbSetOrder(1) )

	If .Not. TMPSQL->(dbSeek( cChaveXml ) )

		nSim++
		lRet := .T.

		cCodFor   := Space( 6 )
		cLojFor   := Space( 2 )

		if empty(cCodFor)

			cFilSek   := xFilial( "SA2" )   //iif(lSharedA2, xFilial( "SA2" ), ( xZBS )->( FieldGet( FieldPos( xZBS_+"FILIAL" ) ) ) )

			DbSelectArea("SA2")
			DbSetOrder(3)

			If DbSeek(cFilSek + ( xZBS )->( FieldGet( FieldPos( xZBS_+"CNPJEM" ) ) ))

				cCodFor := SA2->A2_COD
				cLojFor := SA2->A2_LOJA

				While .not. SA2->( eof() ) .and. SA2->A2_FILIAL == cFilSek .and.;
				SA2->A2_CGC == ( xZBS )->( FieldGet( FieldPos( xZBS_+"CNPJEM" ) ) )

					if SA2->A2_MSBLQL != "1"

						cCodFor := SA2->A2_COD
						cLojFor := SA2->A2_LOJA

						exit

					endif

					SA2->( dbSkip() )

				End

			EndIf

		EndIF

		if empty(cCodFor)

			cFilSek   := xFilial( "SA1" )   //iif(lSharedA1, xFilial( "SA1" ), ( xZBS )->( FieldGet( FieldPos( xZBS_+"FILIAL" ) ) ) )

			DbSelectArea("SA1")
			DbSetOrder(3)

			If DbSeek(cFilSek+( xZBS )->( FieldGet( FieldPos( xZBS_+"CNPJEM" ) ) ))

				cCodFor := SA1->A1_COD
				cLojFor := SA1->A1_LOJA

				While .not. SA1->( eof() ) .and. SA1->A1_FILIAL == cFilSek .and.;
				SA1->A1_CGC == ( xZBS )->( FieldGet( FieldPos( xZBS_+"CNPJEM" ) ) )

					if SA1->A1_MSBLQL != "1"

						cCodFor := SA1->A1_COD
						cLojFor := SA1->A1_LOJA

						exit

					endif

					SA1->( dbSkip() )

				End

			EndIf

		EndIF

		DbSelectArea( "TMPSQL" )
		RecLock( "TMPSQL", .T. )

		TMPSQL->ST       := " "
		TMPSQL->CHAVE    := cChaveXml
		TMPSQL->AMB      := ( xZBS )->( FieldGet( FieldPos( xZBS_+"AMB" ) ) )
		TMPSQL->DEST     := ( xZBS )->( FieldGet( FieldPos( xZBS_+"DEST" ) ) )
		TMPSQL->CNF      := ( xZBS )->( FieldGet( FieldPos(xZBS_+"CNF") ) )
		TMPSQL->SERIE    := ( xZBS )->( FieldGet( FieldPos(xZBS_+"SERIE") ) )
		TMPSQL->CNPJ_EMI := ( xZBS )->( FieldGet( FieldPos( xZBS_+"CNPJEM" ) ) )
		TMPSQL->CODFOR   := cCodFor
		TMPSQL->LOJFOR   := cLojFor
		TMPSQL->DEMI     := DTOC( ( xZBS )->( FieldGet( FieldPos( xZBS_+"DEMI" ) ) ) )
		TMPSQL->VNF      := AllTrim( Str( ( xZBS )->( FieldGet( FieldPos( xZBS_+"VNF" ) ) ) ) )
		TMPSQL->XNOME    := ( xZBS )->( FieldGet( FieldPos( xZBS_+"XNOME" ) ) )
		TMPSQL->IE       := ( xZBS )->( FieldGet( FieldPos( xZBS_+"IE" ) ) )
		TMPSQL->DIGVAL   := ( xZBS )->( FieldGet( FieldPos( xZBS_+"DIGVAL" ) ) )
		TMPSQL->DHRECBTO := DTOC( ( xZBS )->( FieldGet( FieldPos( xZBS_+"DHRECB" ) ) ) )
		TMPSQL->CSITNFE  := ( xZBS )->( FieldGet( FieldPos( xZBS_+"CSITNF" ) ) )
		TMPSQL->XML      := ( xZBS )->( FieldGet( FieldPos( xZBS_+"XML" ) ) )

		if lMostra

			TMPSQL->CSITCONF := ( xZBS )->( FieldGet( FieldPos( xZBS_+"CSITCO" ) ) )

		else

			TMPSQL->CSITCONF := "0"

		endif

		TMPSQL->NSU   := ( xZBS )->( FieldGet( FieldPos( xZBS_+"NSU" ) ) )
		TMPSQL->TOMA  := ( xZBS )->( FieldGet( FieldPos(xZBS_+"TOMA" ) ) )

		TMPSQL->( MsUnLock() )

	Else

		nRep++

	Endif

	DbSelectARea( cAliasZBS )
	(cAliasZBS)->( dbSkip() )

EndDo

(cAliasZBS)->( dbCloseArea() )

DbSelectArea( xZBZ )
DbSetORder( nOrd )
DbSelectArea( "TMPSQL" )

RestArea( aArea )

Return( lRet )


/*Static Function VerAmbiente(cAmb,cEntidade)

	Local aArea  := GetArea()
	Local cRet   := ""

	if Select( "SPED000" ) > 0

		cRet := SpedGetMV("MV_AMBIENT",cEntidade)

	Else

		InitSped()
		InitNfeSped()
		cRet := SpedGetMV("MV_AMBIENT",cEntidade)
		FinishNfeSped()
		FinishSped(.T.,.F.)

	EndIf

	If empty(cRet) .or. (cRet <> "1" .and. cRet <> "2")

		cRet := cAmb

	EndIf

	RestArea(aArea)

Return( cRet )*/



Static Function VerUfMat( cCnpj )

Local cRet := "91"
Local aArea := GetArea()
Local nRecFil
Local aUf := {}

aadd(aUf, {"AN","91"} )
aadd(aUf, {"RO","11"} )
aadd(aUf, {"AC","12"} )
aadd(aUf, {"AM","13"} )
aadd(aUf, {"RR","14"} )
aadd(aUf, {"PA","15"} )
aadd(aUf, {"AP","16"} )
aadd(aUf, {"TO","17"} )
aadd(aUf, {"MA","21"} )
aadd(aUf, {"PI","22"} )
aadd(aUf, {"CE","23"} )
aadd(aUf, {"RN","24"} )
aadd(aUf, {"PB","25"} )
aadd(aUf, {"PE","26"} )
aadd(aUf, {"AL","27"} )
aadd(aUf, {"SE","28"} )
aadd(aUf, {"BA","29"} )
aadd(aUf, {"MG","31"} )
aadd(aUf, {"ES","32"} )
aadd(aUf, {"RJ","33"} )
aadd(aUf, {"SP","35"} )
aadd(aUf, {"PR","41"} )
aadd(aUf, {"SC","42"} )
aadd(aUf, {"RS","43"} )
aadd(aUf, {"MS","50"} )
aadd(aUf, {"MT","51"} )
aadd(aUf, {"GO","52"} )
aadd(aUf, {"DF","53"} )

DbSelectArea("SM0")
nRecFil := Recno()
DbGotop()

While !Eof()

	If Alltrim(SM0->M0_CGC) == Alltrim(cCnpj)

		//If U_HFXML00X("HF000001","101",SM0->M0_CGC,,.F.)
		If HFXMLLIC(.F.)
			nPos := aScan( aUf,{ |x| x[1]==SM0->M0_ESTENT } )

			if nPos > 0

				cRet := aUf[nPos][2]
				Exit

			Endif

		Else

			nPos := aScan( aUf,{ |x| x[1]==SM0->M0_ESTENT } )

			if nPos > 0

				cRet := aUf[nPos][2]

			Endif

		EndIF

	EndIf

	DbSkip()

EndDO

SM0->( dbGoto(nRecFil) )
RestArea(aArea)

Return( cRet )

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Programa  ≥HFXML06Vis≥ Autor ≥ Eneo                  ≥ Data ≥28/05/2014≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒ›ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Visualizar Registro, quando for consulta por CNPJ mostrar· ≥±±
±±≥          ≥ os dados adicionais                                        ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥                                                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥                                                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ›ƒƒƒ¬ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Analista Resp.≥  Data  ≥ Bops ≥ Manutencao Efetuada                    ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥              ≥        ≥      ≥                                        ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒ›ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Static Function HFXML06Vis()

Local oDlg

Private oFont01:= TFont():New("Arial",07,14,,.T.,,,,.T.,.F.)
Private oFont02:= TFont():New("Lucida Console",07,14,,.T.,,,,.T.,.F.)
Private oFont03:= TFont():New("Arial",05,10,,.F.,,,,.f.,.F.)

Private aPages := {"Gerais","NF-e","Carta CorreÁ„o"}
Private nPageGer := aScan(aPages,{|x| x == "Gerais"})
Private nPageNfe := aScan(aPages,{|x| x == "NF-e"})
Private nPageCCe := aScan(aPages,{|x| x == "Carta CorreÁ„o"})

DEFINE MSDIALOG oDlg TITLE "VisualizaÁ„o Registro" FROM 000,000 TO 430,800 PIXEL STYLE DS_MODALFRAME STATUS

oPage := TFolder():New(002,002,aPages,{},oDlg,,,,.T.,.F.,350,210,)

@ 00.5,00.5 To 012,043 OF oPage:aDialogs[nPageGer]

@ 010,010 Say "Chave: " PIXEL OF oPage:aDialogs[nPageGer] COLOR CLR_BLUE FONT oFont01
@ 018,010 Get oObj VAR TMPSQL->CHAVE SIZE 150,08 When .F. PIXEL OF oPage:aDialogs[nPageGer]

@ 040,010 Say "CNPJ Destinat·rio: "  PIXEL OF oPage:aDialogs[nPageGer] COLOR CLR_BLUE FONT oFont01
@ 048,010 Get oObj VAR TMPSQL->DEST SIZE 150,08 When .F. PIXEL OF oPage:aDialogs[nPageGer]

@ 070,010 Say "Mensagem Retorno WS: "  PIXEL OF oPage:aDialogs[nPageGer] COLOR CLR_BLUE FONT oFont01
@ 078,010 Get oObj VAR TMPSQL->MSG SIZE 150,08 When .F. PIXEL OF oPage:aDialogs[nPageGer]

@ 100,010 Say "Mensagem Erro WS: "  PIXEL OF oPage:aDialogs[nPageGer] COLOR CLR_BLUE FONT oFont01
@ 108,010 Get oObj VAR TMPSQL->ERRO MULTILINE SIZE 300,50 When .F. PIXEL OF oPage:aDialogs[nPageGer]

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
@ 00.5,00.5 To 012,043 OF oPage:aDialogs[nPageNfe]

@ 010,010 Say "ManifestaÁ„o do Destinat·rio: " PIXEL OF oPage:aDialogs[nPageNfe] COLOR CLR_BLUE FONT oFont01
@ 018,010 Get oObj VAR TMPSQL->CSITCONF SIZE 10,08 When .F. PIXEL OF oPage:aDialogs[nPageNfe]
@ 018,030 Say "0=S/Manif.     1=Conf.Oper." PIXEL OF oPage:aDialogs[nPageNfe] COLOR CLR_BLUE FONT oFont03
@ 022,030 Say "2=Desconhecida 3=Oper.N„o Real. 4=CiÍncia" PIXEL OF oPage:aDialogs[nPageNfe] COLOR CLR_BLUE FONT oFont03

@ 010,170 Say "CNPJ Emitente: "  PIXEL OF oPage:aDialogs[nPageNfe] COLOR CLR_BLUE FONT oFont01
@ 018,170 Get oObj VAR TMPSQL->CNPJ_EMI SIZE 150,08 When .F. PIXEL OF oPage:aDialogs[nPageNfe]

@ 040,010 Say "Data Emiss„o: "  PIXEL OF oPage:aDialogs[nPageNfe] COLOR CLR_BLUE FONT oFont01
@ 048,010 Get oObj VAR TMPSQL->DEMI SIZE 150,08 When .F. PIXEL OF oPage:aDialogs[nPageNfe]

@ 040,170 Say "Emitente: "  PIXEL OF oPage:aDialogs[nPageNfe] COLOR CLR_BLUE FONT oFont01
@ 048,170 Get oObj VAR TMPSQL->XNOME SIZE 150,08 When .F. PIXEL OF oPage:aDialogs[nPageNfe]

@ 070,010 Say "Valor da NFe: "  PIXEL OF oPage:aDialogs[nPageNfe] COLOR CLR_BLUE FONT oFont01
@ 078,010 Get oObj VAR TMPSQL->VNF SIZE 150,08 When .F. PIXEL OF oPage:aDialogs[nPageNfe]

@ 070,170 Say "IE Emitente: "  PIXEL OF oPage:aDialogs[nPageNfe] COLOR CLR_BLUE FONT oFont01
@ 078,170 Get oObj VAR TMPSQL->IE SIZE 150,08 When .F. PIXEL OF oPage:aDialogs[nPageNfe]

@ 100,010 Say "ValidaÁ„o: "  PIXEL OF oPage:aDialogs[nPageNfe] COLOR CLR_BLUE FONT oFont01
@ 108,010 Get oObj VAR TMPSQL->DIGVAL SIZE 150,08 When .F. PIXEL OF oPage:aDialogs[nPageNfe]

@ 100,170 Say "AutorizaÁ„o: "  PIXEL OF oPage:aDialogs[nPageNfe] COLOR CLR_BLUE FONT oFont01
@ 108,170 Get oObj VAR TMPSQL->DHRECBTO SIZE 150,08 When .F. PIXEL OF oPage:aDialogs[nPageNfe]

@ 130,010 Say "NSU: "  PIXEL OF oPage:aDialogs[nPageNfe] COLOR CLR_BLUE FONT oFont01
@ 138,010 Get oObj VAR TMPSQL->NSU SIZE 150,08 When .F. PIXEL OF oPage:aDialogs[nPageNfe]

@ 130,170 Say "SituaÁ„o NFe: "  PIXEL OF oPage:aDialogs[nPageNfe] COLOR CLR_BLUE FONT oFont01
@ 138,170 Get oObj VAR TMPSQL->CSITNFE SIZE 10,08 When .F. PIXEL OF oPage:aDialogs[nPageNfe]
@ 140,190 Say "1=Uso autorizado 2=Uso denegado 3=NF-e cancelada" PIXEL OF oPage:aDialogs[nPageNfe] COLOR CLR_BLUE FONT oFont03

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
@ 00.5,00.5 To 012,043 OF oPage:aDialogs[nPageCce]
@ 010,010 Say "Carta de CorreÁ„o: "  PIXEL OF oPage:aDialogs[nPageCce] COLOR CLR_BLUE FONT oFont01
@ 018,010 Get oObj VAR TMPSQL->Correcao MULTILINE SIZE 310,140 When .F. PIXEL OF oPage:aDialogs[nPageCce]

@ 012,355 Button "Sair" Size 040,015 PIXEL OF oDlg ACTION oDlg:End()

ACTIVATE MSDIALOG oDlg CENTERED ON INIT (nOpca := 0,.T.)

Return( NIL )


/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Programa  ≥HFXML06Pes≥ Autor ≥ Alexandro / Eneo      ≥ Data ≥29/10/2015≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒ›ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Pesquisa no grid as notas a serem feitas o downloads       ≥±±
±±≥          ≥                                                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥                                                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥                                                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ›ƒƒƒ¬ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Analista Resp.≥  Data  ≥ Bops ≥ Manutencao Efetuada                    ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥              ≥        ≥      ≥                                        ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒ›ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Static Function HFXML06Pes(oMark, cAlias)

Local nRecno  	:= 0
Local nRecTrb 	:= 0
Local cSeek	  	:= ""
Local cCampos 	:= ""
Local aPesqui	:={}
Local nIndex	:= 1

dbSelectArea( cAlias )
nRecno  := Recno()
nIndex	:= IndexOrd()

aAdd(aPesqui,{"CHAVE"    			,1})
aAdd(aPesqui,{"SERIE+CNF" 			,2})
aAdd(aPesqui,{"SERIE+CNF+CNPJ_EMI"	,3})
aAdd(aPesqui,{"CNPJ_EMI"			,4})
aAdd(aPesqui,{"XNOME"				,5})
aAdd(aPesqui,{"CODFOR+LOJFOR"		,6})
aAdd(aPesqui,{"STATUS"				,7})

nRecTrb := (cAlias)->( RecNo() )
cCampos := (cAlias)->( IndexKey() )

cCampos := cAlias + "->(" + cCampos + ")"

WndxPesqui(,aPesqui,cSeek,.F.)
//WndxPesqui(oMark:oBrowse,aPesqui,xFilial("ZBZ"),.F.)

dbSelectArea( "TMPSQL" )
//Caso n„o tenha achado, volto para o registro de partida
IF TMPSQL->(EOF())

	MsgAlert("Registro n„o encontrado , favor digitar novamente.")

	TMPSQL->(dbSetOrder(nIndex))

	TMPSQL->(dbgoto(nRecno))

Endif

oMark:oBrowse:Refresh(.T.)

Return Nil

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Programa  ≥HFXML06Fil≥ Autor ≥ Mandela               ≥ Data ≥29/15/2018≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒ›ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Filtrar por Coiso                                          ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥                                                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥                                                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ›ƒƒƒ¬ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Analista Resp.≥  Data  ≥ Bops ≥ Manutencao Efetuada                    ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥              ≥        ≥      ≥                                        ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒ›ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Static Function HFXML06Fil(oMark, cAlias)

Local bCond := {|| TMPSQL->ST = "0" }
Local cCond := 'ST="0"'
Local nOp   := 0

nOp := Filtros()

if nOp == 2

	bCond := {|| TMPSQL->ST = " " }
	cCond := 'ST=" "'

elseif nOp == 3

	bCond := {|| TMPSQL->ST = "0" }
	cCond := 'ST="0"'

elseif nOp == 4

	bCond := {|| TMPSQL->ST = "2" }
	cCond := 'ST="2"'

elseif nOp == 5

	bCond := {|| TMPSQL->ST = "1" }
	cCond := 'ST="1"'

endif

if nOp == 0

	TMPSQL->( DBClearFilter())

Else

	TMPSQL->( DBSetFilter( bCond, cCond ) )

Endif

oMark:oBrowse:Refresh(.T.)

Return( NIL )


//;filtros
Static Function Filtros()

Local nRet := 0
Local nRadio := 1
Local aItems := {}
Local aCores := {}
Local oDlg

//aAdd(aCores,{"TMP->ST == '1'","BR_VERDE"	})
//aAdd(aCores,{"TMP->ST == ' '","BR_AMARELO"	})
//aAdd(aCores,{"TMP->ST == '0'","BR_VERMELHO" })
//aAdd(aCores,{"TMP->ST == '2'","BR_AZUL" })

AADD(aCores,{"BR_AMARELO" ,"Aguardando interaÁ„o para download/manif." })
AADD(aCores,{"BR_VERMELHO","Download e/ou manifestaÁ„o com erros." })
AADD(aCores,{"BR_AZUL"    ,"Manif. processada aguardando interaÁ„o p/download." })
AADD(aCores,{"BR_VERDE"   ,"Download Concluido com sucesso." })

DEFINE DIALOG oDlg TITLE "Filtrar por Status" FROM 180,180 TO 350,500 PIXEL

nRadio := 1
aItems := {'TODOS',' Aguardando interaÁ„o para download/manif.','Download e/ou manifestaÁ„o com erros.','Manif. processada aguardando interaÁ„o p/download.','Download Concluido com sucesso.'}
oRadio := TRadMenu():New (01,01,aItems,,oDlg,,,,,,,,200,12,,,,.T.)
oRadio:bSetGet := {|u|Iif (PCount()==0,nRadio,nRadio:=u)}
@ 50,77 BUTTON oBtnOut PROMPT "&OK" SIZE 38,11 PIXEL ACTION (oDlg:End())

ACTIVATE DIALOG oDlg CENTERE

if nRadio == 0 .or. nRadio == 1
	nRet := 0
Else
	nRet := nRadio
Endif

Return( nRet )


//Rotina que chama o job para consultar e baixar xml
User Function HFTTJB()

	Local lAuto := .T.
	Local lEnd  := .F.
	Local cLogProc := ""
	Local nCount := 0
	Local oProcess

	Alert( "Inicio" )

	rstmvbuff()

	Private xZBZ  	  := GetNewPar("XM_TABXML","ZBZ")
	Private xZB5  	  := GetNewPar("XM_TABAMAR","ZB5")
	Private xZBS  	  := GetNewPar("XM_TABSINC","ZBS")
	Private xZBE      := GetNewPar("XM_TABEVEN","ZBE")
	Private xZBA  	  := GetNewPar("XM_TABAMA2","ZBA")
	Private xZBO      := GetNewPar("XM_TABOCOR","ZBO")
	Private xZBC      := GetNewPar("XM_TABCAC" ,"ZBC")
	Private xZBI      := GetNewPar("XM_TABIEXT","ZBI")
	Private xZBT      := GetNewPar("XM_TABITEM","ZBT")
	Private xRetSEF   := ""
	Private xZBZ_ 	  := iif(Substr(xZBZ,1,1)=="S", Substr(xZBZ,2,2), Substr(xZBZ,1,3)) + "_"
	Private xZB5_ 	  := iif(Substr(xZB5,1,1)=="S", Substr(xZB5,2,2), Substr(xZB5,1,3)) + "_"
	Private xZBS_ 	  := iif(Substr(xZBS,1,1)=="S", Substr(xZBS,2,2), Substr(xZBS,1,3)) + "_"
	Private xZBE_     := iif(Substr(xZBE,1,1)=="S", Substr(xZBE,2,2), Substr(xZBE,1,3)) + "_"
	Private xZBA_ 	  := iif(Substr(xZBA,1,1)=="S", Substr(xZBA,2,2), Substr(xZBA,1,3)) + "_"
	Private xZBC_     := iif(Substr(xZBC,1,1)=="S", Substr(xZBC,2,2), Substr(xZBC,1,3)) + "_"
	Private xZBO_     := iif(Substr(xZBO,1,1)=="S", Substr(xZBO,2,2), Substr(xZBO,1,3)) + "_"
	Private xZBI_     := iif(Substr(xZBI,1,1)=="S", Substr(xZBI,2,2), Substr(xZBI,1,3)) + "_"
	Private xZBT_     := iif(Substr(xZBT,1,1)=="S", Substr(xZBT,2,2), Substr(xZBT,1,3)) + "_"
	Private x_Ped_Rec := GetNewPar("XM_PEDREC","N")
	Private x_ZBB     := GetNewPar("XM_TABREC","")
	Private aHfCloud  := {"0","0"," ","Token",{}}  //CRAUMDE - '0' N„o integrar, na posiÁ„o 1
	Private x_Tip_Pre := GetNewPar("XM_TIP_PRE","1")
	Private nFormNfe  := Val(GetNewPar("XM_FORMNFE","6"))
	Private nFormCte  := Val(GetNewPar("XM_FORMCTE","6"))
	Private cFilUsu   := GetNewPar("XM_FIL_USU","N")

	cIdEnt := U_GetIdEnt()

	//IF ExistBlock( "HFCLDINI" )

	//	aHfCloud := U_HFCLDINI(.F.,@cLogProc)

	//EndIF

	U_HFXML6JB(lAuto,@lEnd,oProcess,@cLogProc,@nCount,.F.)

	Alert( "Foi" )

	Alert( nCount )

	Alert( cLogProc )

Return()

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Programa  ≥ HFXML6JB ≥ Autor ≥ Eneo                  ≥ Data ≥30/05/2014≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒ›ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Job autom·tico para Consultar e Baixar XML do SEFAZ.       ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ›ƒƒƒ¬ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Analista Resp.≥  Data  ≥ Bops ≥ Manutencao Efetuada                    ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥              ≥        ≥      ≥                                        ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒ›ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
User Function HFXML6JB(lAuto,lEnd,oProcess,cLogProc,nCount,lMostra)

Local aArea   := GetArea()
Local nRegMat := SM0->( Recno() )
//Local cEmpres := SM0->M0_CODIGO
Local cFilAtu := SM0->M0_CODFIL
Local cCnpj   := ""
//Local cQuery  := ""

Private oTmpTable
Private cJobAlias := "TMPSQL"

Default cLogProc := ""
Default lAuto    := .F.
Default oProcess := Nil
Default lEnd     := .F.
Default nCount   := 0
Default lMostra  := .F.

cLogProc += "### Download XML no Sefaz Iniciada ###"+CRLF
cLogProc += dToC(date()) +"-"+ Substr(Time(),1,2) + ":" + Substr(Time(),4,2)+CRLF

Conout("### Download XML no Sefaz Iniciada ###")
Conout(dToC(date()) +"-"+ Substr(Time(),1,2) + ":" + Substr(Time(),4,2))

//-------------------
//CriaÁ„o do objeto
//-------------------
oTmpTable := FWTemporaryTable():New( cJobAlias )

lTMP := Cria1TMP()

If !lTMP

	cLogProc += "Erro ao criar arquivo Tempor·rio"+CRLF
	cLogProc += "### Download XML no Sefaz Finalizada ###"+CRLF
	
	Conout("Erro ao criar arquivo Tempor·rio")
	Conout("### Download XML no Sefaz Finalizada ###")

	RestArea(aArea)

	Return(NIL)

Endif

cCnpj := SM0->M0_CGC
cFilAnt := SM0->M0_CODFIL

//If U_HFXML00X("HF000001","101",cCnpj,,.F.)
If HFXMLLIC(.F.)
	cLogProc += "Iniciado CNPJ "+cCnpj+CRLF
	
	Conout("Iniciado CNPJ "+cCnpj)
	
	DbSelectarea( "TMPSQL" )

	Conout("Inicia download NFE - HFXML6CD")

	If U_HFXML6CD(cCnpj, .F., @cLogProc, ,@nCount)

	Else

		cLogProc += "SEFAZ n„o disponibilizou novos XML modelo 55 pela NFeDistribuicaoDFe."+CRLF
		Conout("SEFAZ n„o disponibilizou novos XML modelo 55 pela NFeDistribuicaoDFe.")

	EndIf

	/*Conout("Alimenta tabela temporaria NFE - HFXML6BS")

	If U_HFXML6BS(cCnpj, .F., @cLogProc, 2, "55" ) //Alimenta TMP de 93 dias para tentar baixar.

		cLogProc += "Tentar baixar os ultimos 90 dias que estiverem na sincronizaÁ„o NFeDistribuicaoDFe."+CRLF
		Conout("Tentar baixar os ultimos 90 dias que estiverem na sincronizaÁ„o NFeDistribuicaoDFe.")

		/*If GetNewPar("XM_MANAUT","N") == "S"

			Conout("Realizada Manifestacao - JobManif")
			Do While .Not. JobManif(@cLogProc)  //Manifestar como CiÍncia se o par‚metro disse que sim
			EndDo

		EndIf

		Conout("Grava Nfe baixado - JobBaixa")
		JobBaixa(@cLogProc)  //Ir· alimentar a tabela ZBS assim o cabra pode manifestala para baixar se quiser.  
		                          //porÈm se j· estiver manifestado vai baixar, acho difÌciel estar manifestada.
		

	EndIf

	dbSelectArea( "TMPSQL" )

	Zap*/

	Conout("Inicia download CTE - HFXML6DC")
	If U_HFXML6DC(cCnpj, .F., @cLogProc, ,@nCount)  //Download dos CTE por nsu

	Else

		cLogProc += "SEFAZ n„o disponibilizou novos XML modelo 57 pela CTeDistribuicaoDFe."+CRLF
		Conout("SEFAZ n„o disponibilizou novos XML modelo 57 pela CTeDistribuicaoDFe.")

	EndIf

	Conout("Alimenta tabela temporaria CTE - HFXML6BS")
	/*If U_HFXML6BS(cCnpj, .F., @cLogProc, 2, "57") //Alimenta TMP de 93 dias para tentar baixar.

		cLogProc += "Tentar baixar os ultimos 90 dias que estiverem na sincronizaÁ„o CTeDistribuicaoDFe."+CRLF
		Conout("Tentar baixar os ultimos 90 dias que estiverem na sincronizaÁ„o CTeDistribuicaoDFe.")
		
		Conout("Grava CTE baixado - JobBaixa")
		JobBai57(@cLogProc)  //Vai baixar o que tiver ZBS.

	EndIf*/

	cLogProc += "Finalizado CNPJ "+cCnpj+CRLF
	Conout("Finalizado CNPJ "+cCnpj)

Else

	cLogProc += "Sem LicenÁa CNPJ "+cCnpj+CRLF
	Conout("Sem LicenÁa CNPJ ")

Endif
//	dbSelectarea( "SM0" )  //Fazer somente da Filial Logada
//	SM0->( dbSkip() )
//EndDo

cLogProc += "### Download XML no Sefaz Finalizada ###" + CRLF
cLogProc += dToC(date()) +"-"+ Substr(Time(),1,2) + ":" + Substr(Time(),4,2)
Conout("### Download XML no Sefaz Finalizada ###")
Conout( dToC(date()) +"-"+ Substr(Time(),1,2) + ":" + Substr(Time(),4,2) )

SM0->( DbGoto( nRegMat ) )

cFilAnt := cFilAtu

//---------------------------------
//Exclui a tabela
//---------------------------------
oTmpTable:Delete()

RestArea( aArea )

Return NIL


//Rotina que cria a tabela temporaria dentro do banco de dados
Static Function Cria1TMP()

	Local aStru := {}
	Local nTamCod   := TAMSXG("001")[1]
	Local nTamLoja  := TAMSXG("002")[1]

	aadd( aStru, { "OK"      ,"C",02,0 } )
	aadd( aStru, { "ST"      ,"C",01,0 } )
	aadd( aStru, { "CHAVE"   ,"C",44,0 } )
	aadd( aStru, { "AMB"     ,"C",01,0 } )
	aadd( aStru, { "MSG"     ,"C",30,0 } )
	aadd( aStru, { "ERRO"    ,"M",10,0 } )
	aadd( aStru, { "CNF"     ,"C",09,0 } )
	aadd( aStru, { "SERIE"   ,"C",03,0 } )
	aadd( aStru, { "DEST"    ,"C",14,0 } )

	//dados do xml para consulta
	aadd( aStru, { "CNPJ_EMI","C",14,0 } )
	aadd( aStru, { "CODFOR"  ,"C",nTamCod,0 } )
	aadd( aStru, { "LOJFOR"  ,"C",nTamLoja,0 } )
	aadd( aStru, { "DEMI"    ,"C",10,0 } )
	aadd( aStru, { "VNF"     ,"C",15,0 } )
	aadd( aStru, { "XNOME"   ,"C",60,0 } )
	aadd( aStru, { "IE"      ,"C",14,0 } )
	aadd( aStru, { "DIGVAL"  ,"C",28,0 } )
	aadd( aStru, { "DHRECBTO","C",10,0 } )
	aadd( aStru, { "CSITNFE" ,"C",01,0 } )
	aadd( aStru, { "CSITCONF","C",01,0 } )
	aadd( aStru, { "NSU"     ,"C",15,0 } )
	aadd( aStru, { "Correcao","M",10,0 } )
	aadd( aStru, { "IDENT"   ,"C",14,0 } )
	aadd( aStru, { "XML"     ,"M",10,0 } )
	aadd( aStru, { "XMLCANC" ,"M",10,0 } )
	aadd( aStru, { "TOMA" 	 ,"C",14,0 } )

	oTmptable:SetFields( aStru )

	oTmpTable:AddIndex( "01", { "CHAVE" } )
	oTmpTable:AddIndex( "02", { "CNF","SERIE" } )
	oTmpTable:AddIndex( "03", { "DHRECBTO" } )

	//------------------
	//CriaÁ„o da tabela
	//------------------
	oTmpTable:Create()

Return( .T. )

Static Function JobManif(cLogProc)

	Local lRet   := .F.
	Local cChave := ""
	Local cEvent := ""
	Local cEve   := "210210"
	Local cxJst  := ""
	Local nLote  := 1
	Local nChv   := 0
	Local cCnpj  := SM0->M0_CGC  //"61135471000100"
	Local cURL   := ""
	Local cXml   := ""
	Local cNfe   := ""
	Local cAmb   := ""
	Local cIdEnt := U_GetIdEnt()
	Local cInfo  := ""
	Local cMsg   := ""
	Local cStt   := ""
	Local lTodos := .F.
	//Local nHandle:= 0
	Local lOk    := .T.
	//Local lTemPr := .F.
	Local cVerLayEven := "1.00"
	Local cHrVerao    := "2"
	Local cHorario    := "2"
	Local nAtraso     := 0
	Local lLoop       := .F.
	Local oWS,oWsrNfe,oWsdNfe,cErro:="",cWarning:=""
	Local nI := 0 //declaracao
	Local cSeqEve := ""  //ZBEMANO
	Local cKey    := ""  //ZBEMANO
	Local aEvt    := {}  //Atualizar a ZBEMANO
	Local cGrv    := ""  //SÛ Para Receber a Resposta
	Private oDet //ZBEMANO
	Private oDoc

	cURL    := AllTrim(GetNewPar("XM_URL",""))

	If Empty(cURL)

		cURL  := AllTrim(SuperGetMv("MV_SPEDURL"))

	EndIf

	cEve := "210210"

	oWS:=WsSpedCfgNfe():New()
	oWS:cUSERTOKEN 	  	:= "TOTVS"
	oWS:cID_ENT    		:= cIdEnt
	oWS:nAMBIENTECCE	:= 0	// Atribuicao de '0', efetua a consulta do metodo
	oWS:cVERCCELAYOUT	:= ""
	oWS:cVERCCELAYEVEN	:= ""
	oWS:cVERCCEEVEN		:= ""
	oWS:cVERCCE			:= ""
	oWS:cHORAVERAOCCE	:= ""
	oWS:cHORARIOCCE		:= ""
	oWS:_URL       		:= AllTrim(cURL)+"/SpedCfgNfe.apw"
	lOk:=oWS:CfgCCe()

	If lOk

		cVerLayEven	:= oWs:oWsCfgCCeResult:cVerCCeLayEven
		cHrVerao 	:= Left(oWS:oWsCfgCCeResult:cHoraVeraoCCe,1)
		cHorario 	:= Left(oWS:oWsCfgCCeResult:cHorarioCCe,1)

	EndIf

	TMPSQL->( DbGotop() )

	Do While .not. TMPSQL->( Eof() ) .and. nChv < 20

		if TMPSQL->CSITCONF == "0" //.And. VerData( TMP->DHRECBTO ) < (dDataBase - 1)

			//cCnpj  := TMP->DEST  CNPJ pega do SM0
			cChave += TMPSQL->CHAVE+";"
			cEvent += cEve+";"
			cxJst  += " ;"
			cLogProc += "Verificando ManifestaÁ„o " + TMPSQL->CHAVE + CRLF

			nChv++

			if cAmb <> "1"

				cAmb := TMPSQL->AMB

			endif

			RecLock( "TMPSQL", .F. )
			TMPSQL->CSITCONF := "1"
			TMPSQL->( MsUnLock() )

		endif

		TMPSQL->( dbskip() )

	Enddo

	if nChv <= 0

		return( .T. )

	ElseIf nChv < 20

		lRet := .T.

	endif

	// Tratamento da numeracao do lote
	
	rstmvbuff()

	nLote := ( GetNewPar("XM_LOTEMAN",0) + 1 )

	If !PutMv("XM_LOTEMAN",nLote)

		SX6->(RecLock("SX6",.T.))

		SX6->X6_FIL     := xFilial( "SX6" )
		SX6->X6_VAR     := "XM_LOTEMAN"
		SX6->X6_TIPO    := "N"
		SX6->X6_DESCRIC := "Lote do Evento de Manifestacao"
		SX6->(MsUnLock())

		PutMv("XM_LOTEMAN",nLote)

	EndIf

	If Right( AllTrim(cURL), 1 ) != "/"

		cURL := AllTrim(cURL)+"/"

	EndIf

	For nAtraso := 0 to 4

		oWSdNfe:= WSHFXMLMANIFESTO():New()
		oWSdNfe:Init()
		oWSdNfe:cCIDENT       := cIdEnt
		oWsdNfe:cCLOTE        := strzero(nLote,15,0)
		//oWSdNfe:_URL          := cURL
		oWSdNfe:cCCURL        := cURL
		oWSdNfe:cCAMBIENTE    := cAmb
		oWSdNfe:cCVERSAODADOS := cVerLayEven
		oWSdNfe:cCCUF         := "91"
		oWSdNfe:cCHORAVERAO   := cHrVerao
		oWSdNfe:cCHORARIO     := cHorario
		oWSdNfe:cCCNPJ        := cCnpj
		oWSdNfe:cCCHSTR       := cChave
		oWSdNfe:cCEVSTR       := cEvent
		oWSdNfe:cCXJUST       := cxJst  //AQUIIII
		oWSdNfe:cCDTHREVEN    := U_HFDTTIME( cHrVerao, cHorario, nAtraso )

		if oWSdNfe:HFMANISFESTO()

			cXml := oWSdNfe:cHFMANISFESTORESULT
			nAt1:= At('<RETENVEVENTO ',Upper(cXml))
			nAt2:= At('</RETENVEVENTO>',Upper(cXml))+ 15

			//Corpo do XML
			If nAt1 <= 0

				nAt1:= At('<RETENVEVENTO>',Upper(cXml))

			EndIf

			If nAt1 > 0 .And. nAt2 > 15

				cNfe := Substr(cXml,nAt1,nAt2-nAt1)

				cXml:= '<?xml version="1.0" encoding="UTF-8"?>'
				cXml+= cNfe

				//Faz backup do xml sem retirar os caracteres especiais
				cBkpXml := cXml

				cXml := EncodeUTF8(cXml)
				cXml := fWNOAccent(cXml)

				//Executa rotina para retirar os caracteres especiais
				cXml := u_zCarEspec( cXml )

				cErro:= ""
				cWarning:= ""

				//oWSrNfe := XmlParser( cXml, "_", @cErro, @cWarning )
				if Len(cXml) >= 65534

					oWSrNfe := U_PARSGDE( cXml, @cErro, @cWarning )

				Else

					oWSrNfe := XmlParser( cXml, "_", @cErro, @cWarning )

				endif

				//retorna o backup do xml
				cXml := cBkpXml

				If oWSrNfe == NIL //.Or. !Empty(cErro) .Or. !Empty(cWarning)

					cMsg   := "Erro Parser do XML de Resposta da ManifestaÁ„o"
					cInfo  := cErro + " " + cWarning
					cLogProc += cMsg + CRLF
					lTodos := .T.

				elseIf oWSrNfe:_RETENVEVENTO:_CSTAT:TEXT <> "128"

					If (oWSrNfe:_RETENVEVENTO:_CSTAT:TEXT = "578" .or. oWSrNfe:_RETENVEVENTO:_CSTAT:TEXT = "703") .And. nAtraso < 4

						Sleep(1500) //da 1 segundo e vai de novo

						Loop

					EndIf

					cMsg   := "Retorno do Sefaz "+oWSrNfe:_RETENVEVENTO:_CSTAT:TEXT
					cInfo  := oWSrNfe:_RETENVEVENTO:_XMOTIVO:TEXT
					lTodos := .T.
					cLogProc += cMsg + CRLF

				Else

					lLoop:= .F.
					oDet := oWSrNfe:_RETENVEVENTO:_RETEVENTO
					oDet := iif( valtype(oDet)=="O", {oDet}, oDet )

					nTotLen := Len( oDet )

					For nI := 1 to nTotLen

						cKey  := oDet[nI]:_INFEVENTO:_CHNFE:TEXT
						cStt  := ""
						cMsg  := ""
						cInfo := ""

						if oDet[nI]:_INFEVENTO:_CSTAT:TEXT <> "135"

							if (oDet[nI]:_INFEVENTO:_CSTAT:TEXT = "578" .Or. oDet[nI]:_INFEVENTO:_CSTAT:TEXT = "703")  .And. nAtraso < 4

								Sleep(1500) //da 1 segundo e vai de novo
								lLoop:= .T.

							Else

								cMsg  := oDet[nI]:_INFEVENTO:_CSTAT:TEXT
								cInfo := cChave + " " +oDet[nI]:_INFEVENTO:_XMOTIVO:TEXT
								cStt  := "0"

							EndIf

						else

							cStt  := "2"
							cMsg  := "ManifestaÁ„o Efetuada"
							cInfo := cChave + " " +"ManifestaÁ„o Efetuada do XML "
							Conout("Manifestacao realizada com sucesso")
							aEvt    := {}     //ZBEMANO
							cSeqEve := ""     //ZBEMANO
							aEvt    := U_HF20ZBE( nI, @cSeqEve, cXml )
							cGrv    := U_HF2GrvEv( cKey, cEve, cSeqEve, aEvt, .T. )

						Endif

						cLogProc += cInfo + CRLF

					Next nI

					if lLoop

						Sleep(1500) //da 1 segundo e vai de novo

						Loop

					endif

				Endif

			Else

				cMsg  := "Erro de retorno do Sefaz na ManifestaÁ„o."
				cInfo := "Erro de retorno do Sefaz. XML de retorno n„o contÈm a TAG <RETENVEVENTO>"
				cLogProc += cInfo + CRLF

			EndIf

		else

			//Erro TSS ou WS n„o instalado.
			cInfo := IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
			cMsg  := cFilAnt + " Falha no momento de conectar com a url do sefaz"

			cLogProc += cInfo + CRLF
				
			if !IsBlind()
				U_MyAviso("JobManif",cMsg+CRLF+cInfo,{"OK"},3)
			else
				Conout("JobManif"+CRLF+cMsg+CRLF+cInfo)
			endif

			//cInfo := IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
			//cMsg  := "Erro TSS ou WS"
			//cLogProc += cInfo + CRLF

		endif

		Exit

	Next nAtraso

	DelClassIntf()

Return( lRet )

//Rotina do job
//Faz donwload por chave depois que tentaram fazer por nsu
Static Function JobBaixa(cLogProc)

	Local lRet   := .F.
	Local nChv   := 0
	Local cURL   := ""
	Local cDir   := AllTrim(SuperGetMv("MV_X_PATHX"))
	Local cXml   := ""
	Local cChave := ""
	Local cAmb   := ""
	Local cNfe   := ""
	Local cIdEnt := U_GetIdEnt()
	Local cInfo  := ""
	Local cMsg   := ""
	Local cStt   := ""
	Local nHandle:= 0
	Local lOk    := .T.
	Local cNsu55 := ""
	Local cNsu   := ""
	//Local cVerLayEven := "1.00"
	//Local cHrVerao    := "2"
	//Local cHorario    := "2"
	Local ni := 0 //declaracao
	Local lHF := .T.
	Local cSt       := ""
	Local cSitConf  := ""
	Local cChaveXml := ""
	Local cNf       := ""
	Local cSer      := ""
	Local cCnpjXml  := ""
	Local lResumo   := .T.
	Local cIE       := ""
	Local _cFil     := ""

	Private oWs,oWsrNfe,oWsdNfe,cErro:="",cWarning:=""
	Private nDow := 0  //Coisa de Louco
	Private nErr := 0  //Coisa de Louco
	Private nMan := 0  //Coisa de Louco

	cURL      := AllTrim(GetNewPar("XM_URL",""))

	If Empty(cURL)

		cURL  := AllTrim(SuperGetMv("MV_SPEDURL"))

	EndIf

	cQuery := "select min(NSU) AS NSU from " + oTMPtable:GetrealName()
	Tcquery cQuery New Alias "TCQ"

	cNsu := TCQ->NSU

	TCQ->( DBCLOSEAREA() )

	TMPSQL->( dbgotop() )

	Do While .not. TMPSQL->( Eof() ) .and. nChv < 1 // 10

		if TMPSQL->OK <> "Pr"

			cCnpj  := TMPSQL->DEST
			cChave += TMPSQL->CHAVE+";"
			cNsu55 := TMPSQL->NSU
			//cLogProc += "Verificando Disponibilidade Baixa " + TMP->CHAVE + CRLF

			nChv++
			cAmb := TMPSQL->AMB

			RecLock( "TMPSQL", .F. )
			TMPSQL->OK := "Pr"
			TMPSQL->( MsUnLock() )

		endif

		TMPSQL->( dbskip() )

	Enddo

	if nChv <= 0

		return( .T. )

	ElseIf nChv < 1 // 10

		lRet := .T.

	endif

	If Right( AllTrim(cURL), 1 ) != "/"

		cURL := AllTrim(cURL)+"/"

	EndIf

	//oWSdNfe:= WSHFXMLDOWLOAD():New()
	//oWSdNfe:Init()
	//oWSdNfe:cCIDENT       := cIdEnt
	//oWSdNfe:_URL          := cURL
	//oWSdNfe:cCCURL        := cURL
	//oWSdNfe:cCAMBIENTE    := cAmb
	//oWSdNfe:cCVERSAODADOS := cVerLayEven
	//oWSdNfe:cCCUF         := "AN"
	//oWSdNfe:cCCNPJ        := cCnpj
	//oWSdNfe:cCCHSTR       := cChave

	if lHF

		//Job por chave
		/*oWSdNfe:= WSHFXMLNFEDISTRIBUICAODFE():New()
		oWSdNfe:Init()
		oWSdNfe:cCIDENT       := cIdEnt
		oWSdNfe:cCCURL        := cURL
		oWSdNfe:cCAMBIENTE    := cAmb
		oWSdNfe:cCVERSAODADOS := "1.01" //esse È a parada cVerLayEven
		oWSdNfe:cCCUF         := substr(cChave,1,2) //"AN"  //ver isso aqui, È o Estado, agora vem de 1 em 1
		oWSdNfe:cCCNPJ        := cCnpj
		oWSdNfe:cCNSU         := ""
		oWSdNfe:cCCHSTR       := cChave*/

		//Job por nsu
		oWSdNfe:= WSHFXMLNFEDISTRIBUICAODFE():New()
		oWSdNfe:Init()
		oWSdNfe:cCIDENT       := cIdEnt
		oWSdNfe:cCCURL        := cURL
		oWSdNfe:cCAMBIENTE    := cAmb
		oWSdNfe:cCVERSAODADOS := "1.01" //esse È a parada cVerLayEven
		oWSdNfe:cCCUF         := substr(cChave,1,2) //"AN"  //ver isso aqui, È o Estado, agora vem de 1 em 1
		oWSdNfe:cCCNPJ        := cCnpj
		oWSdNfe:cCNSU         := cNsu
		oWSdNfe:cCCHSTR       := ""

		if oWSdNfe:HFNFEDISTRDFE()

			cXml := "<"+AllTrim(oWSdNfe:cHFNFEDISTRDFERESULT)
			nAt1:= At('<RETDISTDFEINT ',Upper(cXml))
			nAt2:= At('</RETDISTDFEINT>',Upper(cXml))+ 16

			//Corpo do XML
			If nAt1 <= 0

				nAt1 := At('<RETDISTDFEINT>',Upper(cXml))

			EndIf

			If nAt1 > 0 .And. nAt2 > 16

				cNfe := Substr(cXml,nAt1,nAt2-nAt1)

				cXml:= '<?xml version="1.0" encoding="UTF-8"?>'
				cXml+= cNfe

				cXml := EncodeUTF8(cXml)

				//Primeiro parse sem checagem de caracteres especiais
				if Len(cXml) >= 65534

					oWSrNfe := U_PARSGDE( cXml, @cErro, @cWarning )

				Else

					oWSrNfe := XmlParser( cXml, "_", @cErro, @cWarning )

				endif

				//Caso for nil faz a segunda checagem somente para aqueles xml¥s que tem caracteres especiais
				if oWSrNfe == NIL 

					//Faz backup do xml sem retirar os caracteres especiais
					cBkpXml := cXml

					cXml := fWNOAccent(cXml)  //NoAcento(cXml)
					cXml := EncodeUTF8(cXml)

					//Executa rotina para retirar os caracteres especiais
					cXml := u_zCarEspec( cXml )

					if Len(cXml) >= 65534

						oWSrNfe := U_PARSGDE( cXml, @cErro, @cWarning )

					Else

						oWSrNfe := XmlParser( cXml, "_", @cErro, @cWarning )

					endif

					//retorna o backup do xml
					cXml := cBkpXml

				endif

				If oWSrNfe == NIL //.Or. !Empty(cErro) .Or. !Empty(cWarning)

					cMsg   := "Erro Parser do XML de Resposta"
					cInfo  := cErro + " " + cWarning

				ElseIf oWSrNfe:_RETDISTDFEINT:_CSTAT:TEXT <> "138" //"139"

					cMsg   := "Retorno do Sefaz "+oWSrNfe:_RETDISTDFEINT:_CSTAT:TEXT
					cInfo  := oWSrNfe:_RETDISTDFEINT:_XMOTIVO:TEXT
					nOrd   := (xZBZ)->( IndexOrd() )

					if oWSrNfe:_RETDISTDFEINT:_CSTAT:TEXT = "656"  //Consumo indevido

						nRet  := 3   //volta o 3 para tentar por DFE em 10/09/18
						cInfo := Upper(cInfo+"("+oWSrNfe:_RETDISTDFEINT:_CSTAT:TEXT+")")  //"Consumo Indevido"

						if !IsBlind()
							U_MyAviso("JobBaixa",cMsg+CRLF+cInfo,{"OK"},3)
						else
							Conout("JobBaixa"+CRLF+cMsg+CRLF+cInfo)
						endif

						Return(.F.)

					endif

					cSitConf  := manifver(substr(cChave,1,44),cURL,cIdEnt,cAmb)  //"4"

					cChaveXml := substr(cChave,1,44)
					cNf       := Substr( cChaveXml, 26, 9 )
					cSer      := Substr( cChaveXml, 23, 3 )
					cCnpjXml  := Substr( cChaveXml, 07, 14 )
					cIE       := ""

					( xZBZ )->( DbSetOrder( 3 ) )

					If ( xZBZ )->(dbSeek( cChaveXml ) )

						cSt := "10"

					Else

						cSt := "99"

					Endif

					( xZBZ )->( DbSetORder( nOrd ) )

					nHdl := -1

					If U_HFTrvXml("TRAVA", "ZBS"+cChaveXml, @nHdl)

						lResumo   := .F.

						( xZBS )->( DbSetOrder( 3 ) )

						If .Not. ( xZBS )->(dbSeek( cChaveXml ) )

							cLogProc += cChaveXml+" Nova Chave Sincronizada NFeDistribuicaoDFe."+CRLF
							
							if !Empty( cIE )

								_cFil := u_Gravafil( cCnpj, cIE )

								if Empty( xFilial(xZBS) )  //Verifica se for compartilhado

									_cFil := xFilial( xZBS )

								endif

							else

								_cFil := xFilial( xZBS )

							endif

							RecLock(xZBS, .T. )

							( xZBS )->(FieldPut(FieldPos(xZBS_+"FILIAL"),  _cFil ))
							( xZBS )->(FieldPut(FieldPos(xZBS_+"CHAVE")	,  cChaveXml ))
							( xZBS )->(FieldPut(FieldPos(xZBS_+"AMB")	,  cAmb ))
							( xZBS )->(FieldPut(FieldPos(xZBS_+"DEST")	,  cCnpj ))
							( xZBS )->(FieldPut(FieldPos(xZBS_+"IDENT")	,  cIdEnt ))

							If ( xZBS )->( FieldPos(xZBS_+"MODELO") ) > 0

								( xZBS )->(FieldPut(FieldPos(xZBS_+"MODELO"), Substr(cChaveXml,21,2) ))

							EndIF

							if (xZBS)->(FieldPos(xZBS_+"TPROT")) > 0 //Tipo de Rotina Job ou Manual

								if Empty(  (xZBS)->(FieldGet(FieldPos(xZBS_+"TPROT"))) )

									if Type("cTpRt") <> "U"

										(xZBS)->(FieldPut(FieldPos(xZBS_+"TPROT"), cTpRt ))

									endif

								endif

							endif

						Else

							cLogProc += cChaveXml+" Chave Ja esta na Sincronizacao NFeDistribuicaoDFe."+CRLF
							RecLock(xZBS, .F. )

							if ! Empty( ( xZBS )->(FieldGet(FieldPos(xZBS_+"DEMI"))) ) .And. ( xZBS )->(FieldGet(FieldPos(xZBS_+"DEMI"))) < (dDataBase - 90)

								if cSt == "99"  //N„o aparecer, È muito velho o Bixo

									cSt := ( xZBS )->(FieldGet(FieldPos(xZBS_+"ST")))

								endif

							Endif

							lResumo   := .T.

						Endif

						if ! Empty( ( xZBS )->(FieldGet(FieldPos(xZBS_+"CSITCO"))) )

							if cSitConf == "4" .And. ( xZBS )->(FieldGet(FieldPos(xZBS_+"CSITCO"))) > "0"

								cSitConf := ( xZBS )->(FieldGet(FieldPos(xZBS_+"CSITCO")))

							Else

								if ( xZBS )->(FieldGet(FieldPos(xZBS_+"CSITCO"))) > cSitConf

									cSitConf := ( xZBS )->(FieldGet(FieldPos(xZBS_+"CSITCO")))

								Endif

							Endif

						Endif

						( xZBS )->(FieldPut(FieldPos(xZBS_+"ST")	, cSt ))
						( xZBS )->(FieldPut(FieldPos(xZBS_+"CSITCO"), cSitConf ))
						( xZBS )->(FieldPut(FieldPos(xZBS_+"CNF")	, cNf ))
						( xZBS )->(FieldPut(FieldPos(xZBS_+"SERIE")	, cSer ))
						( xZBS )->(FieldPut(FieldPos(xZBS_+"CNPJEM"), cCnpjXml ))
						( xZBS )->(MsUnLock())

						U_HFTrvXml("SOLTA", "ZBS"+cChaveXml, nHdl) //SOLTAR

					Endif

				Else

					oDet := oWSrNfe:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP
					oDet := iif( valtype(oDet)=="O", {oDet}, oDet )

					nTotLen := Len( oDet )

					For nI := 1 to nTotLen  //Deixar assim para quando for mais de 1, mas agora tem que ser de 1 em 1.

						cStt  := ""
						cMsg  := ""
						cInfo := ""

						if Empty( oDet )

							if !IsBlind()
								U_MyAviso("HFXML06Bai","Objeto do sefaz vazio",{"OK"},3)
							else
								Conout("HFXML06Bai - Objeto do sefaz vazio")
							endif

							Exit

						endif

						cFileZip	:= Decode64( oDet[nI]:TEXT )
						nLenZip		:= Len( cFileZip )
						cFileUnZip  := ""

						// Funcao de descompactacao de arquivos compactados no formato GZip
						lOk  :=  GzStrDecomp( cFileZip, nLenZip, @cFileUnZip )
						oXml := XmlParser( cFileUnZip, "_", @cErro, @cWarning )

						//AlteraÁ„o em 13/04/2017, erro SalOnline
						//If UPPER(Substr(oDet[nI]:_SCHEMA:TEXT,1,7)) <> UPPER("procNFe") //"139"
						//	cMsg	:=	"633"
						//	cInfo	:=	"Falta ManifestaÁ„o do Destinat·rio."
						//		cStt	:=	"0"

						If valtype(oXml) <> "O"

							cMsg	:=	"XXX"
							cInfo	:=	"N„o foi possÌvel Descompactar o XML."
							cStt	:=	"0"

						Else

							If UPPER(Substr(oDet[nI]:_SCHEMA:TEXT,1,7)) <> UPPER("procNFe")

								cChaveArq := cDir + Substr(cChave,1,44) + "-resuNfe.xml" //alltrim( oDet[nI]:_CHNFE:TEXT ) + "-procNfe.xml"

							else

								cChaveArq := cDir + Substr(cChave,1,44) + "-procNfe.xml" //alltrim( oDet[nI]:_CHNFE:TEXT ) + "-procNfe.xml"

							endif

							SAVE oXml XMLSTRING cXML

							If UPPER(Substr(oDet[nI]:_SCHEMA:TEXT,1,7)) <> UPPER("procNFe")

								nAt1:= At('<NFE ',Upper(cXml))
								nAt2:= At('</NFE>',Upper(cXml))+ 6

								//Corpo da Nfe
								If nAt1 <= 0

									nAt1:= At('<NFE>',Upper(cXml))

								EndIf

								If nAt1 > 0 .And. nAt2 > 6

									cNfe := Substr(cXml,nAt1,nAt2-nAt1)

								Else

									cStt  := "0"
									cMsg  := "Xml Retorno Inv·lido"
									cInfo := "XML "+cChave+" sem TAG <NFE>"

								EndIf

								nAt3:= At('<PROTNFE ',Upper(cXml))
								nAt4:= At('</PROTNFE>',Upper(cXml))+ 10

								//Protocolo
								If nAt3 > 0 .And. nAt4 > 10

									cProt := Substr(cXml,nAt3,nAt4-nAt3)

								Else

									cStt  := "0"
									cMsg  := "Xml Retorno Inv·lido"
									cInfo += "XML "+cChave+" sem Protocolo, falta TAG <PROTNFE>"

								EndIf

								if empty( cMsg )

									//cXml:= '<?xml version="1.0"?>'
									cXml := '<?xml version="1.0" encoding="UTF-8"?>'
									cXml += '<nfeProc versao="2.00" xmlns="http://www.portalfiscal.inf.br/nfe">'
									cXml += cNfe
									cXml += cProt
									cXml += '</nfeProc>'
									
									//Faz backup do xml sem retirar os caracteres especiais
									cBkpXml := cXml

									cXml := EncodeUTF8(cXml)
									cXml := FwNoAccent(cXml)

									//Executa rotina para retirar os caracteres especiais
									cXml := u_zCarEspec( cXml )

									if Len(cXml) >= 65534

										oXML := U_PARSGDE( cXml, @cErro, @cWarning )

									Else

										oXml := XmlParser( cXml, "_", @cErro, @cWarning )

									endif

									//retorna o backup do xml
									cXml := cBkpXml

									if oXML == NIL //.Or. !Empty(cErro) .Or. !Empty(cWarning)

										cStt  := "0"
										cMsg  := "Erro Parser do XML"
										cInfo := cErro + " " + cWarning

									endif

								endif

							Endif

							if Empty( cMsg )

								if oXML == NIL .Or. !Empty(cErro) .Or. !Empty(cWarning)

									cStt  := "0"
									cMsg  := "Erro Parser do XML"
									cInfo := cErro + " " + cWarning

								Else

									SAVE oXML XMLFILE cChaveArq

									nHandle := FT_FUse( cChaveArq )

									if nHandle == -1

										cStt  := "0"
										cMsg  := "Erro GravaÁ„o"
										cInfo := "Erro de GravaÁ„o XML no DiretÛrio "+cChaveArq

										if !IsBlind()

											U_MyAviso("JobBaixa",cMsg+" - "+cInfo,{"OK"},3)

										else

											Conout("JobBaixa",cMsg+" - "+cInfo)

										endif 

									else

										cStt  := "1"
										cMsg  := "Download Efetuado"
										cInfo := "Download Efetuado do XML "+Substr(cChave,1,44)
										Conout("Download Efetuado do XML "+Substr(cChave,1,44))

									endif

									FT_FUSE()

									if cStt == "1"

										If UPPER(Substr(oDet[nI]:_SCHEMA:TEXT,1,7)) <> UPPER("procNFe")

											if ! slvxmlzbz(Substr(cChave,1,44) + "-resuNFe.xml", .T.,.F.,NIL,@cLogProc,0, "2", Substr(cChave,1,44), @cInfo, "R" )  //2=Downlaod Sefaz  R=Resumo Nfe

												cStt  := "0"
												cMsg  := "Erro ImportaÁ„o"

											EndIf

										Else

											if ! slvxmlzbz(Substr(cChave,1,44) + "-procNFe.xml", .T.,.F.,NIL,@cLogProc,0, "2", Substr(cChave,1,44), @cInfo, " " )  //2=Downlaod Sefaz

												cStt  := "0"
												cMsg  := "Erro ImportaÁ„o"

											EndIf

										Endif

									Endif

								EndIf

							Endif

						Endif

						cLogProc += cInfo + CRLF
						DelClassIntf()

					Next nI

				Endif

			Else

				cInfo := "FALTA TAG RETDISTR"
				cMsg  := "Erro TSS ou WS"
				cLogProc += cInfo + CRLF
				//sem TAG RET e Tal

			EndIf

		else

			cInfo := IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
			cMsg  := cFilAnt + " Falha no momento de conectar com a url do sefaz"

			cLogProc += cInfo + CRLF

			if GetNewPar("XM_VISFAL","") == "S"
				if !IsBlind()
					U_MyAviso("JobBaixa",cMsg+CRLF+cInfo,{"OK"},3)
				else
					Conout("JobBaixa"+CRLF+cMsg+CRLF+cInfo)
				endif
			else
				Conout("JobBaixa"+CRLF+cMsg+CRLF+cInfo)
			endif

		endif

	Else


	Endif

	If lResumo  //Para baixar o XML Resumidis

		nRet := HFXML06B55(cCnpj,cChave,cAmb,cIdEnt,cNsu55,@cLogProc)

	EndIf

Return( lRet )


Static Function JobBai57(cLogProc)

	Local nReg   := TMPSQL->( recno() )
	Local aArea  := GetArea()
	Local cDir   := AllTrim(SuperGetMv("MV_X_PATHX"))
	Local cXml   := ""
	Local cInfo  := ""
	Local cMsg   := ""
	Local cStt   := ""
	Local nHandle:= 0
	Local aAreaZBS := (xZBS)->( GetArea() )
	Private oWs,oWsrNfe,oWsdNfe,cErro:="",cWarning:=""

	DbSelectArea( "TMPSQL" )

	TMPSQL->( dbgotop() )

	While .not. TMPSQL->( Eof() )

		cChave := TMPSQL->CHAVE

		DbSelectArea( xZBZ )
		(xZBZ)->( dbSetOrder( 3 ) )

		if (xZBZ)->( dbSeek( Substr( cChave,1,44 ) ) )

			DbSelectArea( "TMPSQL" )

			TMPSQL->( dbSkip() )

			Loop

		endif

		DbSelectArea( xZBS )

		(xZBS)->( dbSetOrder( 3 ) )

		if (xZBS)->( dbSeek( Substr( cChave,1,44 ) ) )

			if (xZBS)->( FieldPos( xZBS_+"XML" ) ) > 0

				if ! Empty(( xZBS )->(FieldGet(FieldPos(xZBS_+"XML"))))

					cXml := ( xZBS )->(FieldGet(FieldPos(xZBS_+"XML")))

					cChaveArq := cDir + Substr(cChave,1,44) + "-procCTe.xml"

					//Faz backup do xml sem retirar os caracteres especiais
					cBkpXml := cXml

					cXml := EncodeUTF8(cXml)
					cXml := FwNoAccent(cXml)

					//Executa rotina para retirar os caracteres especiais
					cXml := u_zCarEspec( cXml )

					If Len(cXml) >= 65534

						oXML := U_PARSGDE( cXml, @cErro, @cWarning )

					Else

						oXml := XmlParser( cXml, "_", @cErro, @cWarning )

					Endif

					//retorna o backup do xml
					cXml := cBkpXml

					if oXML == NIL //.Or. !Empty(cErro) .Or. !Empty(cWarning)

						cStt  := "0"
						cMsg  := "Erro Parser do XML"
						cInfo := cErro + " " + cWarning
						cLogProc += cChave + " " + cInfo + CRLF

					Else

						SAVE oXML XMLFILE cChaveArq

						nHandle := FT_FUse( cChaveArq )

						if nHandle == -1

							cStt  := "0"
							cMsg  := "Erro GravaÁ„o"
							cInfo := "Erro de GravaÁ„o XML no DiretÛrio "+cChaveArq
							cLogProc += cInfo + CRLF
								
							if !IsBlind()

								U_MyAviso("JobBai57",cMsg+CRLF+cLogProc,{"OK"},3)

							else

								Conout("JobBai57 - "+cMsg+CRLF+cLogProc)

							endif 

						else

							cStt  := "1"
							cInfo := "Download Efetuado do XML "+Substr(cChave,1,44)
							cLogProc += cInfo + CRLF

						endif

						FT_FUSE()

						if cStt == "1"

							if ! slvxmlzbz(Substr(cChave,1,44) + "-procCTe.xml", .T.,.F.,NIL,@cLogProc,0, "2", Substr(cChave,1,44), @cInfo )  //2=Downlaod Sefaz

								cStt  := "0"
								cMsg  := "Erro ImportaÁ„o"

							EndIf

							Conout("CTE " + TMPSQL->CNF + " Serie " + TMPSQL->SERIE + " importado com sucesso")

						Endif

					EndIf

				Else

					cInfo := "Registro XML Vazio Chave "+Substr(cChave,1,44)
					cLogProc += cInfo + CRLF

				Endif

			Else

				cInfo := "Erro UPDIF001 Chave "+Substr(cChave,1,44)
				cLogProc += cInfo + CRLF

			Endif

		Else

			cInfo := "N„o Encontrado Chave "+Substr(cChave,1,44)
			cLogProc += cInfo + CRLF

		EndIF

		DbSelectArea( "TMPSQL" )

		RecLock( "TMPSQL", .F. )

		TMPSQL->OK := "Pr"

		TMPSQL->( MsUnLock() )

		TMPSQL->( dbskip() )

	End

	DelClassIntf()

	//(xZBS)->(RestArea( aAreaZBS ))

	RestArea( aArea )

	RestArea( aAreaZBS )

	TMPSQL->( DbGoto( nReg ) ) //Volta ao Registro para dar continuidade

	//DelClassIntf()

return( .T. )


//Rotina para converter a data 
Static Function VerData( cDatRec )

	Local dDat := ctod( "" )
	Local cDat := ""

	cDat := Substr( cDatRec,9,2 ) + "/" + Substr( cDatRec,6,2 ) + "/" + Substr( cDatRec,1,4 )

	dDat := ctod( cDat )

Return(dDat)

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Programa  ≥HFXML06NSU≥ Autor ≥ Eneo                  ≥ Data ≥30/05/2015≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒ›ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Tela para Editar Par‚metro NSU para rotina NFeDistribuicaoDFe.   ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ›ƒƒƒ¬ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Analista Resp.≥  Data  ≥ Bops ≥ Manutencao Efetuada                    ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥              ≥        ≥      ≥                                        ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒ›ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Static Function HFXML06NSU()

	Local lRet 			:= .T.
	Local cNsu          := Space(11)
	Local cAmb          := " "
	Local cVrs         := "0.00"
	Local cIdEnt 		:= "" //U_GetIdEnt()
	Local nOpc 			:= 1
	Local oWs,cURL,oDlg,oNsu,oAmb,oVrs
	Local lDfeHf        := ( GetNewPar( "XM_DFE", "0" ) == "1" )

	rstmvbuff()

	if GetNewPar("XM_DFE","0") $ "0,1"

		cIdEnt := U_GetIdEnt()

		cURL   := AllTrim(GetNewPar("XM_URL",""))
	
		If Empty(cURL)

			cURL  := AllTrim(SuperGetMv("MV_SPEDURL"))

		EndIf

		If Right( AllTrim(cURL), 1 ) != "/"

			cURL := AllTrim(cURL)+"/"

		EndIf

	else
			
		cUrl := ""
		cIdent := ""
	
	endif

	oWs:= WSHFXMLCFG():New()
	oWs:Init()
	oWs:cCIDENT := cIdEnt
	oWs:cCCURL  := cURL

	if oWs:HFGETNSU()

		cNsu := oWs:cHFGETNSURESULT

		if Len( cNsu ) < 15

			cNsu := Substr(cNsu+Space(15),1,15)

		endif

	else

		cNsu := Space(15)

	endif

	if oWs:HFGETMDAMB()

		cAmb := oWs:cHFGETMDAMBRESULT

		if Len( cAmb ) < 1

			cAmb := " "

		endif

	else

		cAmb := " "

	endif

	if oWs:HFGETMDVER()

		cVrs := oWs:cHFGETMDVERRESULT

		if Len( cVrs ) < 4

			cVrs := Substr(cVrs+Space(4),1,4)

		endif

	else

		cVrs := "0.00"

	endif

	if lDfeHf

		cNSU := ( GetNewPar("XM_NSUNFE" ,cNSU,cFilAnt) )
		cVrs := ( GetNewPar("XM_VERLNFE",cVrs,cFilAnt) )
		cAmb := ( GetNewPar("XM_AMBNFE" ,cAmb,cFilAnt) )

	Endif

	DEFINE MSDIALOG oDlg TITLE "Par‚metro MV_MDNSU / MV_MDAMB / MV_MDVER" FROM 0,0 TO 155,450 OF oDlg PIXEL

	@ 003,006 Say "Digitar n˙mero do NSU inicial para Consultar os XML emitidos contra o CNPJ e" PIXEL OF oDlg
	@ 009,006 Say "posterior Download do XML. Deixando 0 ou Branco o WS ir· consultar XML dos"   PIXEL OF oDlg
	@ 015,006 Say "˙ltimos 15 dias para Vers„o 1.01 ou 3 meses para Vers„o 1.00." 	 			 PIXEL OF oDlg
	@ 021,006 Say "TambÈm o Ambiente para o WS NFeDistribuicaoDFe 1 - ProduÁ„o 2 - HomologaÁ„o " PIXEL OF oDlg

	@ 027,006 Say "NSU: " PIXEL OF oDlg
	@ 037,006 GET oNsu VAR cNsu Picture "@!" SIZE 100,10 PIXEL OF oDlg
	@ 027,140 Say "Vers„o: " PIXEL OF oDlg
	@ 037,140 GET oVrs VAR cVrs Picture "@!" SIZE 10,10	 PIXEL OF oDlg
	@ 050,006 Say "Ambiente: " PIXEL OF oDlg
	@ 060,006 GET oAmb VAR cAmb Picture "@!" SIZE 10,10	 PIXEL OF oDlg

	@ 060,140 BUTTON "Cancelar" SIZE 35,12 PIXEL OF oDlg Action(nOpc:= 0,oDlg:End())
	@ 060,180 BUTTON "Salvar" SIZE 35,12 PIXEL OF  oDlg Action(nOpc:= 1,oDlg:End())

	ACTIVATE MSDIALOG oDlg CENTERED

	if nOpc == 1

		rstmvbuff()

		If Len( alltrim(cNSU) ) < 15

			cNSU := StrZero(Val(cNSU),15,0)

		EndIf

		If !PutMv("XM_NSUNFE",cNSU)

			SX6->(RecLock("SX6",.T.))

			SX6->X6_FIL     := cFilAnt //xFilial( "SX6" )
			SX6->X6_VAR     := "XM_NSUNFE"
			SX6->X6_TIPO    := "C"
			SX6->X6_DESCRIC := "NSU download NFE por CNPJ via HF"

			SX6->(MsUnLock())

			PutMv("XM_NSUNFE",cNSU)

		EndIf

		If !PutMv("XM_VERLNFE",cVrs)

			SX6->(RecLock("SX6",.T.))

			SX6->X6_FIL     := cFilAnt //xFilial( "SX6" )
			SX6->X6_VAR     := "XM_VERLNFE"
			SX6->X6_TIPO    := "C"
			SX6->X6_DESCRIC := "Vers„o Layout download NFE por CNPJ via HF"
			SX6->(MsUnLock())

			PutMv("XM_VERLNFE",cVrs)

		EndIf

		If !PutMv("XM_AMBNFE",cAmb)

			SX6->(RecLock("SX6",.T.))

			SX6->X6_FIL     := cFilAnt //xFilial( "SX6" )
			SX6->X6_VAR     := "XM_AMBNFE"
			SX6->X6_TIPO    := "C"
			SX6->X6_DESCRIC := "Ambiente download NFE por CNPJ via HF"
			SX6->(MsUnLock())

			PutMv("XM_AMBNFE",cAmb)

		EndIf

		oWs:cCIDENT := cIdEnt
		oWs:cCCURL  := cURL
		oWs:cCNSU   := cNsu

		if oWs:HFSETNSU()

			cNsu := oWs:cHFSETNSURESULT

			if cNsu == "NAO GRAVOU"

				Alert( "N„o Foi PossÌvel Gravar o Par‚metro MV_MDNSU...." )
				lRet := .F.

			Endif

		Else

			Alert( IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)) )

		endif

		oWs:cCIDENT := cIdEnt
		oWs:cCCURL  := cURL
		oWs:cCMDAMB := cAmb

		if oWs:HFSETMDAMB()

			cAmb := oWs:cHFSETMDAMBRESULT

			if cAmb == "NAO GRAVOU"

				Alert( "N„o Foi PossÌvel Gravar o Par‚metro MV_MDAMB...." )
				lRet := .F.

			Endif

		Else

			Alert( IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)) )

		endif

		oWs:cCIDENT := cIdEnt
		oWs:cCCURL  := cURL
		oWs:cCMDVER := cVrs

		if oWs:HFSETMDVER()

			cVrs := oWs:cHFSETMDAMBRESULT

			if cVrs == "NAO GRAVOU"

				Alert( "N„o Foi PossÌvel Gravar o Par‚metro MV_MDVER...." )

				lRet := .F.

			Endif

		Else

			Alert( IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)) )

		endif

	endif

	DelClassIntf()

Return( lRet )


/*===========================================================================//
±±≥Programa  ≥HFXML06NSC≥ Autor ≥ Sebasti„o Macale¥     ≥ Data ≥29/07/2017≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒ›ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Tela para Editar Par‚metro NSU para rotina CTeDistribuicaoDFe.≥±±
// Utiliza de Par‚metros normais
//=============================================================================*/
Static Function HFXML06NSC()

	Local lRet 			:= .T.
	Local cNsu          := "000000000000000"
	Local cAmb          := "1"
	Local cVrs          := "1.00"
	//Local cIdEnt 		:= U_GetIdEnt()
	Local nOpc 			:= 1
	Local oDlg,oNsu,oAmb,oVrs

	cNSU := ( GetNewPar("XM_NSUCTE" ,"000000000000000",cFilAnt) )
	cVrs := ( GetNewPar("XM_VERLCTE","1.00"           ,cFilAnt) )
	cAmb := ( GetNewPar("XM_AMBCTE" ,"1"              ,cFilAnt) )

	DEFINE MSDIALOG oDlg TITLE "Filial "+cFilAnt FROM 0,0 TO 155,450 OF oDlg PIXEL

	@ 003,006 Say "Digitar n˙mero do NSU inicial para Consultar os CTE emitidos contra o CNPJ e" PIXEL OF oDlg
	@ 009,006 Say "posterior Download do XML. Deixando 0 ou Branco o WS ir· consultar XML dos"   PIXEL OF oDlg
	@ 015,006 Say "˙ltimos 3 meses para Vers„o 1.00." 	 										 PIXEL OF oDlg
	@ 021,006 Say "TambÈm o Ambiente para o WS CTeDistribuicaoDFe 1 - ProduÁ„o 2 - HomologaÁ„o " PIXEL OF oDlg

	@ 027,006 Say "NSU: " PIXEL OF oDlg
	@ 037,006 GET oNsu VAR cNsu Picture "@!" SIZE 100,10 PIXEL OF oDlg
	@ 027,140 Say "Vers„o: " PIXEL OF oDlg
	@ 037,140 GET oVrs VAR cVrs Picture "@!" SIZE 10,10	 PIXEL OF oDlg
	@ 050,006 Say "Ambiente: " PIXEL OF oDlg
	@ 060,006 GET oAmb VAR cAmb Picture "@!" SIZE 10,10	 PIXEL OF oDlg

	@ 060,140 BUTTON "Cancelar" SIZE 35,12 PIXEL OF oDlg Action(nOpc:= 0,oDlg:End())
	@ 060,180 BUTTON "Salvar"   SIZE 35,12 PIXEL OF oDlg Action(nOpc:= 1,oDlg:End())

	ACTIVATE MSDIALOG oDlg CENTERED

	if nOpc == 1

		rstmvbuff()

		If Len( alltrim(cNSU) ) < 15

			cNSU := StrZero(Val(cNSU),15,0)

		EndIf

		If !PutMv("XM_NSUCTE",cNSU)

			SX6->(RecLock("SX6",.T.))

			SX6->X6_FIL     := cFilAnt //xFilial( "SX6" )
			SX6->X6_VAR     := "XM_NSUCTE"
			SX6->X6_TIPO    := "C"
			SX6->X6_DESCRIC := "NSU download CTE por CNPJ"
			SX6->(MsUnLock())

			PutMv("XM_NSUCTE",cNSU)

		EndIf

		If !PutMv("XM_VERLCTE",cVrs)

			SX6->(RecLock("SX6",.T.))

			SX6->X6_FIL     := cFilAnt //xFilial( "SX6" )
			SX6->X6_VAR     := "XM_VERLCTE"
			SX6->X6_TIPO    := "C"
			SX6->X6_DESCRIC := "Vers„o Layout download CTE por CNPJ"
			SX6->(MsUnLock())

			PutMv("XM_VERLCTE",cVrs)

		EndIf

		If !PutMv("XM_AMBCTE",cAmb)

			SX6->(RecLock("SX6",.T.))

			SX6->X6_FIL     := cFilAnt //xFilial( "SX6" )
			SX6->X6_VAR     := "XM_AMBCTE"
			SX6->X6_TIPO    := "C"
			SX6->X6_DESCRIC := "Ambiente download CTE por CNPJ"
			SX6->(MsUnLock())

			PutMv("XM_AMBCTE",cAmb)

		EndIf

	endif

	DelClassIntf()

Return( lRet )

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…››››››››››—››››››››››À›››››››—››››››››››››››››››››À››››››—›››››››››››››ª±±
±±∫Programa  ≥ HFESPIAO ∫Autor  ≥ Eneo/Alexandro     ∫ Data ≥ 10/12/2015  ∫±±
±±Ã››››››››››ÿ›››››››››› ›››››››››››››››››››››››››››› ››››››››››››››››››››π±±
±±∫Desc.     ≥ Valida a chave.			                                  ∫±±
±±∫          ≥                                                            ∫±±
±±Ã››››››››››ÿ››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››π±±
±±∫Uso       ≥ Geral                                                      ∫±±
±±»›››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
User Function HFESPIAO(cChaveXml)

	If  .NOT. ( xZBZ )->( dbSeek( cChaveXml ) )

		If ( xZBS )->(FieldGet(FieldPos(xZBS_+"ESPIAO"))) <> "S"

			Aadd(aEnvNfe, { cChaveXml,  ( xZBS )->( recno() ) } )

		endif

	endif

Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…››››››››››—››››››››››À›››››››—››››››››››››››››››››À››››››—›››››››››››››ª±±
±±∫Programa  ≥HFGRVDADOS∫Autor  ≥ Eneo/Alexandro     ∫ Data ≥ 11/12/2015  ∫±±
±±Ã››››››››››ÿ›››››››››› ›››››››››››››››››››››››››››› ››››››››››››››››››››π±±
±±∫Desc.     ≥ Grava dados na tabela                                      ∫±±
±±∫          ≥                                                            ∫±±
±±Ã››››››››››ÿ››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››π±±
±±∫Uso       ≥ Geral                                                      ∫±±
±±»›››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
User Function HFGRVDADOS()

	Local nI := 0 //declaracao

	nTotLen := Len( aEnvNfe )

	For nI := 1 To nTotLen

		( xZBS )->( dbGoto(aEnvNfe[nI][2] ) )  //posiÁionar a ZBS para gravar o ZBs_ESPIAO

		RecLock(xZBS, .F. )
		//( xZBS )->(FieldPut(FieldPos(xZBS_+" ESPIAO ")              , "S" ))
		//13/01/2016 aqui tem que tirar esses espaÁos, porque sen„o ele n„o encontra o campo ZBS_ESPIAO
		( xZBS )->(FieldPut(FieldPos(xZBS_+"ESPIAO")              , "S" ))

		( xZBS )->( MsUnLock() )

	Next nI

Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…››››››››››—››››››››››À›››››››—››››››››››››››››››››À››››››—›››››››››››››ª±±
±±∫Programa  ≥ HFENVMAIL∫Autor  ≥ Eneo/Alexandro     ∫ Data ≥ 11/12/2015  ∫±±
±±Ã››››››››››ÿ›››››››››› ›››››››››››››››››››››››››››› ››››››››››››››››››››π±±
±±∫Desc.     ≥ Envia Email				                                  ∫±±
±±∫          ≥                                                            ∫±±
±±Ã››››››››››ÿ››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››π±±
±±∫Uso       ≥ Geral                                                      ∫±±
±±»›››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
User Function HFENVMAIL(nQual)

	Local cAnexo  := ""
	Local cError  := ""
	Local cMsg    := ""
	Local cHea    := ""
	Local nI      := 0
	Local aTo     := {}
	Local lRet    := .F.
	Local cCap    := "NOTIFICA«√O DO ESPI√O"
	Local cInfo   := "FORAM EMITIDAS NOTAS FISCAIS CONTRA O CNPJ"
	Default nQual := 0

	if nQual > 0

		cInfo += " Ultimos "+AllTrim(Str(nQual))+" dias e n„o constam como importados"

	endif

	cMsg += '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
	cMsg += '<html xmlns="http://www.w3.org/1999/xhtml">'

	messagePadron( "",@cHea,"" )  //13/01/2016 Faltava essa funÁ„o estatica, sÛ copiei do HFXML020.

	cMsg += cHea
	cMsg += '<body>'
	cMsg += '<table style="background-color: rgb(240, 240, 240); width: 800px; text-align: left; margin-left: auto; margin-right: auto;" id="total" border="0" cellpadding="12">'
	cMsg += '<caption>'+cCap+' EMPRESA '+cEmpAnt+' FILIAL '+cFilAnt+' '+'</caption>'
	cMsg += '            <tr>'
	cMsg += '                            <td colspan="5">'
	cMsg += '                                            <hr>'
	cMsg += '                                                           <p class="style1">'+cInfo + CRLF +'</p>'
	cMsg += '                                            </hr>'
	cMsg += '                            </td>'
	cMsg += '            </tr>'

	cMsg += '            <tr>'
	cMsg += '                            <th id="col_tag">Chave</th>'
	cMsg += '                            <th id="col_for">CNPJ</th>'
	cMsg += '                            <th id="col_sef">Nome Fornecedor</th>'
	cMsg += '                            <th id="col_sef">Data Emiss„o</th>'
	cMsg += '                            <th id="col_sef">Valor</th>'

	//aqui vocÍ pode por quais colunas quiser, aqui È o cabeÁalho da tabela do e-mail

	cMsg += '            </tr>'

	nTotLen := Len(aEnvNfe)

	For nI := 1 To nTotLen

		cMsg += '            <tr>'
		//( xZBX )->( dbGoto(aEnvNfe[nI][2] ) )  //posiÁionar
		//13/01/2016 aqui È a xZBS
		( xZBS )->( dbGoto(aEnvNfe[nI][2] ) )  //posiÁionar
		cMsg += '                            <td headers="col_tag">' + ( xZBS )->(FieldGet(FieldPos(xZBS_+"CHAVE")))  + '</td>'
		cMsg += '                            <td headers="col_for">' + ( xZBS )->(FieldGet(FieldPos(xZBS_+"CNPJEM"))) + '</td>'
		cMsg += '                            <td headers="col_sef">' + ( xZBS )->(FieldGet(FieldPos(xZBS_+"XNOME" ))) + '</td>'
		cMsg += '                            <td headers="col_sef">' + DTOC( ( xZBS )->( FieldGet( FieldPos( xZBS_+"DEMI" ) ) ) )   + '</td>'
		cMsg += '                            <td headers="col_sef">' + AllTrim( Str( ( xZBS )->( FieldGet( FieldPos( xZBS_+"VNF" ) ) ) ) )    + '</td>'
		//aqui vocÍ pode por quais colunas quiser, sÛ que aqui È o campo,
		cMsg += '            </tr>'

	Next nI

	cMsg += '</table>'
	cMsg += '</body>'
	cMsg += '</html>'

	cEmailErr := AllTrim(SuperGetMv("XM_MAIL04")) // Conta de Email para envio do Espi„o

	If !Empty(cEmailErr)

		cAssunto:= "Espi„o do IMP.XML."

		aTo 	:= Separa(cEmailErr,";")

		nRet := U_MAILSEND(aTo,cAssunto,cMsg,@cError,cAnexo,"",cEmailErr,"","")

		If nRet == 0 .And. Empty(cError) //13/01/2016 retorno

			lRet := .T.

		EndIf

	EndIf

Return( lRet )

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø±±
±±≥Empresa   ≥ HF Consulting                                                              ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Funcao    ≥messagePad ≥ Autor ≥ Eneovaldo Roveri Jr                  ≥ Data ≥ 28/11/13 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒƒ›ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒ›ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Funcao que retorno um mensagem padr„o em html para envio no corpo do e-mail≥±±
±±≥          ≥ utilizada pelo fsendmail e tambem pela fNotific.                           ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Obs.      ≥ Voce pode passar os parametros cHead e cBody como referencia para utiliza- ≥±±
±±≥          ≥ los em seu programa, como eh feito no FNotific.                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ messagePadron( cCc, cHead, cBody )                                         ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ cCc   : Mensagem padrao para ir no corpo do e-mail                         ≥±±
±±≥          ≥ cHead : Mandar como referencia para ele retornar o cabecalho padrao        ≥±±
±±≥          ≥ cBody : Mandar como referencia para ele retornar o corpo do e-mail padrao  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥             ATUALIZACOES SOFRIDAS DESDE CONSTRUCAO                                    ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Data      ≥ Programador      ≥ Manutencao efetuada                                     ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥  /  /    ≥                  ≥                                                         ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥ ComparaÁ„o de TAGs XML                                                     ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function messagePadron( cCc, cHead, cBody )

	Local cMsgCfg := ""

	cHead := ""
	cHead += '<head>'
	cHead += '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />'
	cHead += '<title>IntegraÁ„o ACPJ X Protheus</title>'
	cHead += '  <style type="text/css"> '
	cHead += '	<!-- '
	cHead += '	body {background-color: rgb(37, 64, 97);} '
	cHead += '	.style1 {font-family: Segoe UI,Verdana, Arial;font-size: 12pt;} '
	cHead += '	.style2 {font-family: Segoe UI,Verdana, Arial;font-size: 12pt;color: rgb(255,0,0)} '
	cHead += '	.style3 {font-family: Segoe UI,Verdana, Arial;font-size: 10pt;color: rgb(37,64,97)} '
	cHead += '	.style4 {font-size: 8pt; color: rgb(37,64,97); font-family: Segoe UI,Verdana, Arial;} '
	cHead += '	.style5 {font-size: 10pt} '
	cHead += '	-->'
	cHead += '  </style>'
	cHead += '</head>'

	cBody := ""
	cBody += '<body>'
	cBody += '<table style="background-color: rgb(240, 240, 240); width: 800px; text-align: left; margin-left: auto; margin-right: auto;" id="total" border="0" cellpadding="12">'
	cBody += '  <tbody>'
	cBody += '    <tr>'
	cBody += '      <td colspan="2">'
	cBody += '    	<Center>'
	cBody += '      <img src="http://extranet.helpfacil.com.br/images/cabecalho.jpg">'
	cBody += '      </Center><hr>'
	cBody += '      <p class="style1">'+cCc+'</p>'
	cBody += '      <hr></td>'
	cBody += '    </tr>'
	cBody += '  </tbody>'
	cBody += '</table>'
	cBody += '<p class="style1">&nbsp;</p>'
	cBody += '</body>'

	cMsgCfg := ""
	cMsgCfg += '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
	cMsgCfg += '<html xmlns="http://www.w3.org/1999/xhtml">'
	cMsgCfg += cHead
	cMsgCfg += cBody
	cMsgCfg += '</html>'

Return cMsgCfg


//Rotina para dar um parse no arquivo xml quando for maior que ou igual 65534 caracteres.
User Function PARSGDE( cXml, cErro, cWarning )

Local oRet  := NIL
Local cDir  := AllTrim(SuperGetMv("MV_X_PATHX"))
Local cFile := cDir + Criatrab(,.f.)+"parse.xml"
Private oParse := NIL

if GravarComFRead(cFile,cXml)  //gravar um arquivo na pasta para poder dar o parserfile.

	oParse := XmlParserFile( cFile, "_", @cErro, @cWarning )

	If Empty(cErro) .And. Empty(cWarning) .And. oParse <> Nil

		oRet :=  oParse

	EndIf

	FERASE(cFile)  //apagaire

EndIf

Return( oRet )


//Rotina para gravar em arquivo
Static Function GravarComFRead(cFinalF,cFileToWrite) //28032016

	Local nHandle := 0
	Local nTentai := 0
	Local lRet    := .T.

	nHandle := FCreate(cFinalF)

	If nHandle <= 0

		Return( .F. )

	Else

		While FWrite(nHandle, cFileToWrite) <= 0

			nTentai++

			if nTentai > 3

				lRet := .F.

				Exit

			endif

		End

		FClose(nHandle)

	EndIf

Return( lRet )


//Hora e Time, por conta de divergencia de estados, principalmente quando em horario de ver„o.
User Function HFDTTIME( cHrVerao, cHorario, nAtraso )

	Local cRet := ""
	Local cUtc := ""
	Local nAtr := nAtraso
	Local dDt  := Date()
	Local cHr  := Time()

	If cHrVerao == "1"			//1-Sim ### 2-Nao

		If cHorario == "1"		//Fernando de Noronha

			cUtc := "01:00"

		ElseIf cHorario == "2"	//Brasilia

			cUtc := "02:00"

		Else

			cUtc := "03:00"		//Manaus

		Endif

	Else

		If cHorario == "1"		//Fernando de Noronha

			cUtc := "02:00"

		ElseIf cHorario == "2"	//Brasilia

			cUtc := "03:00"

		Else

			cUtc := "04:00"		//Manaus

		Endif

	Endif

	cHr := HfTime( @dDt, cHr, nAtr, 5 )  //a data pode voltar um dia, por isso mando como ref.
	//nAtr È o atraso em horas
	//5 s„o mais 5 minutos

	cRet := Transform(dTos( dDt ), "@R 9999-99-99")+"T"+cHr+"-"+cUtc

Return cRet


//Converte a FunÁ„o TIME() em valor n˙merico - Analista Eneo Roveri Jr.
Static Function  HfTime( dDt, cHr, nAtr, nSub )

	Local cRet  := ""
	Local cHora := cHr
	Local nMin  := Val( Substr( cHora,4,2 ) )
	Local nHor  := Val( Substr( cHora,1,2 ) )
	Local nnn   := 0

	For nnn := 1 To nAtr

		nHor--

		if nHor < 0

			dDt  := dDt - 1  //Volta um dia
			nHor := 23       //as 23 horas

		endif

	Next

	//aqui È os 5 minutos, nesse caso se for meia noite e menos de 5 minutos, nem volta o dia, sÛ poe para meia-noite redondo
	if nMin >= nSub

		nMin := nMin - nSub

	Else

		If nHor > 0

			nMin := 55
			nHor --

		Else

			nMin := 0
			nHor := 0

		Endif

	endif

	cRet := StrZero(nHor,2,0) + ":" + StrZero(nMin,2,0) + Substr( cHora,6,3 )

Return( cRet )


//Rotina de complemento de download
Static Function SLVXMLZBZ(cNomArq, lAuto, lEnd, oProcess, cLogProc, nCount, cVem, cChv, cInfo, cTpDow)

	Local lRet := .T.
	Local aArea := GetArea()
	Local nOrd  := (xZBZ)->( indexord() )
	Local cMsgRet := ""

	default cTpDow := ""

	if cTpDow = "R"  //Grava SÛ Na ZBZ

		U_HFXMLRES(cNomArq, lAuto, lEnd, oProcess, cLogProc, nCount, cVem, cChv, cInfo, cTpDow )

	Else

		U_HFSLVXML(cNomArq, lAuto, lEnd, oProcess, cLogProc, nCount, cVem, , , cTpDow )

	Endif

	DbSelectArea( xZBZ )
	dbSetORder( 3 )

	If ! (xZBZ)->( dbSeek( cChv ) )  //Arquivo Baixado mas n„o conseguiu importar

		DbSelectArea(xZBS)
		DbSetOrder(3)
		if DbSeek( cChv )

			cMsgRet := (xZBS)->(FieldGet(FieldPos(xZBS_+"ERRO")))

			cInfo := cMsgRet + " " + Substr(cChv,1,44)

			lRet := .T.

		endif

		//cInfo := "Download Efetuado, mas n„o foi possÌvel importar para a Base o XML "+Substr(cChv,1,44)
		//cInfo := "Download Efetuado, Xml resumido " + Substr(cChv,1,44)
		if Empty(cMsgRet)
			cInfo := "Xml resumido" + Substr(cChv,1,44)
			lRet := .F.
		endif

	EndIf

	(xZBZ)->( dbSetORder( nOrd ) )

	RestArea( aArea )

Return( lRet )


//Rotina de Download Sefaz por numero de nsu
//Grava na ZBS
User Function HFDOWDFE( cCnpj,cChv,cAmb,cIdEnt,cNsu,cLogProc )

Local nI   := 0
Local nRet := 0
Local cURL   := ""
Local cInfo  := ""
Local cMsg   := ""
Local cStt   := ""
Local nOrd   := 0
Local nHdl   := -1
Local cSitConf:= "0"
Local cVerLay := "1.00"
Local cUF     := ""
Local cNf     := ""
Local cSer    := ""
Local cCnpjXml:= ""
Local cIE     := ""
Local _cFil   := ""

Default cLogProc := ""

//Private aEnvNfe := {}

cUF := substr(cChv,1,2)

cURL      := AllTrim(GetNewPar("XM_URL",""))

If Empty(cURL)

	cURL  := AllTrim(SuperGetMv("MV_SPEDURL"))

EndIf

If Right( AllTrim(cURL), 1 ) != "/"

	cURL := AllTrim(cURL)+"/"

EndIf

Private oWSdNfe

cVerLay := ( GetNewPar("XM_VERLNFE","1.00",cFilAnt) )

If !PutMv("XM_VERLNFE",cVerLay)

	SX6->(RecLock("SX6",.T.))
	SX6->X6_FIL     := cFilAnt //xFilial( "SX6" )
	SX6->X6_VAR     := "XM_VERLNFE"
	SX6->X6_TIPO    := "C"
	SX6->X6_DESCRIC := "Vers„o Layout download NFE por CNPJ via HF"
	SX6->(MsUnLock())

	PutMv("XM_VERLNFE",cVerLay)

EndIf

/*Ã››››››››››ÿ››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››π±±
±±∫Uso       ≥ Valida se pode continuar com a requisiÁ„o ao SEFAZ        ∫±±
±±»›››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››º±±*/
U_HFXML072(SM0->M0_CGC)

If !lConsCnpj

	lRet := .F.
			
	Return(lRet)

EndIf

	//alert( cVerLay+" "+cNSU )
	oWSdNfe:= WSHFXMLNFEDISTRIBUICAODFE():New()
	oWSdNfe:Init()
	oWSdNfe:cCIDENT       := cIdEnt
	oWSdNfe:cCCURL        := cURL
	oWSdNfe:cCAMBIENTE    := cAmb
	oWSdNfe:cCVERSAODADOS := "1.01"  //cVerLay //Parametro exclosivis
	oWSdNfe:cCCUF         := cUF     //Parametro exclosivis //"91" //"35" //substr(cChave,1,2) //"AN"  //ver isso aqui, È o Estado, agora vem de 1 em 1
	oWSdNfe:cCCNPJ        := cCnpj
	oWSdNfe:cCNSU         := cNSU    //Parametro exclosivis
	oWSdNfe:cCCHSTR       := ""      //para executar a rotina pelo NSU apenas

	if oWSdNfe:HFNFEDISTRDFE()

		cXml := "<"+AllTrim(oWSdNfe:cHFNFEDISTRDFERESULT)
		nAt1:= At('<RETDISTDFEINT ',Upper(cXml))
		nAt2:= At('</RETDISTDFEINT>',Upper(cXml))+ 16

		//Corpo do XML
		If nAt1 <= 0

			nAt1:= At('<RETDISTDFEINT>',Upper(cXml))

		EndIf

		If nAt1 > 0 .And. nAt2 > 16

			cNfe := Substr(cXml,nAt1,nAt2-nAt1)

			cXml := '<?xml version="1.0" encoding="UTF-8"?>'
			cXml += cNfe

			cXml := EncodeUTF8(cXml)
			
			//Primeiro parse sem checagem de caracteres especiais
			if Len(cXml) >= 65534

				oWSrNfe := U_PARSGDE( cXml, @cErro, @cWarning )

			Else

				oWSrNfe := XmlParser( cXml, "_", @cErro, @cWarning )

			endif

			//Caso for nil faz a segunda checagem somente para aqueles xml¥s que tem caracteres especiais
			if oWSrNfe == NIL 

				//Faz backup do xml sem retirar os caracteres especiais
				cBkpXml := cXml

				cXml := fWNOAccent(cXml)  //NoAcento(cXml)
				cXml := EncodeUTF8(cXml)

				//Executa rotina para retirar os caracteres especiais
				cXml := u_zCarEspec( cXml )

				if Len(cXml) >= 65534

					oWSrNfe := U_PARSGDE( cXml, @cErro, @cWarning )

				Else

					oWSrNfe := XmlParser( cXml, "_", @cErro, @cWarning )

				endif

				//retorna o backup do xml
				cXml := cBkpXml

			endif

			If oWSrNfe == NIL //.Or. !Empty(cErro) .Or. !Empty(cWarning)
				cMsg   := "Erro Parser do XML de Resposta"
				cInfo  := cErro + " " + cWarning
				nRet   := 2
				//U_MyAviso("SPED",cInfo,{"OK"},3)

			elseIf oWSrNfe:_RETDISTDFEINT:_CSTAT:TEXT <> "138" //"139"

				cMsg   := "Retorno do Sefaz "+oWSrNfe:_RETDISTDFEINT:_CSTAT:TEXT
				cInfo  := oWSrNfe:_RETDISTDFEINT:_XMOTIVO:TEXT

				if oWSrNfe:_RETDISTDFEINT:_CSTAT:TEXT = "656"  //Consumo indevido

					nRet  := 3   //volta o 3 para tentar por DFE em 10/09/18
					cInfo := Upper(cInfo+"("+oWSrNfe:_RETDISTDFEINT:_CSTAT:TEXT+")")  //"Consumo Indevido"

					if !IsBlind()
						U_MyAviso("HFDOWDFE",cMsg+CRLF+cInfo,{"OK"},3)
					else
						Conout("HFDOWDFE"+CRLF+cMsg+CRLF+cInfo)
					endif

					Return( 3 )

				endif

				if oWSrNfe:_RETDISTDFEINT:_CSTAT:TEXT = "137"

					nRet   := 3

				Else

					nRet   := 2

				Endif

				nOrd   := (xZBZ)->( IndexOrd() )
				cSitConf  := manifver(substr(cChv,1,44),cURL,cIdEnt,cAmb)  //"4"
				cChaveXml := substr(cChv,1,44)
				cNf       := Substr( cChaveXml, 26, 9 )
				cSer      := Substr( cChaveXml, 23, 3 )
				cCnpjXml  := Substr( cChaveXml, 07, 14 )
				cIE       := ""

				( xZBZ )->( DbSetOrder( 3 ) )

				If ( xZBZ )->(dbSeek( cChaveXml ) )

					cSt := "10"

				Else

					cSt := "99"

				Endif

				( xZBZ )->( DbSetORder( nOrd ) )

				nHdl := -1

				If U_HFTrvXml("TRAVA", "ZBS"+cChaveXml, @nHdl)

					( xZBS )->( DbSetOrder( 3 ) )

					If .Not. ( xZBS )->(dbSeek( cChaveXml ) )

						cLogProc += cChaveXml+" Nova Chave Sincronizada NFeDistribuicaoDFe."+CRLF

						lRet := .T.
					
						if !Empty( cIE )

							_cFil := u_Gravafil( cCnpj, cIE )

							if Empty( xFilial(xZBS) )  //Verifica se for compartilhado

								_cFil := xFilial( xZBS )

							endif

						else

							_cFil := xFilial( xZBS )

						endif

						//=========================//
						// Grava ZBS               //
						//=========================//
						RecLock(xZBS, .T. )
						( xZBS )->(FieldPut(FieldPos(xZBS_+"FILIAL"),  _cFil ))
						( xZBS )->(FieldPut(FieldPos(xZBS_+"CHAVE")	,  cChaveXml ))
						( xZBS )->(FieldPut(FieldPos(xZBS_+"AMB")	,  cAmb ))
						( xZBS )->(FieldPut(FieldPos(xZBS_+"DEST")	,  cCnpj ))
						( xZBS )->(FieldPut(FieldPos(xZBS_+"IDENT")	,  cIdEnt ))

						If ( xZBS )->( FieldPos(xZBS_+"MODELO") ) > 0

							( xZBS )->(FieldPut(FieldPos(xZBS_+"MODELO"), Substr(cChaveXml,21,2) ))

						EndIF

						if (xZBS)->(FieldPos(xZBS_+"TPROT")) > 0 //Tipo de Rotina Job ou Manual

							if Empty(  (xZBS)->(FieldGet(FieldPos(xZBS_+"TPROT"))) )

								if Type("cTpRt") <> "U"

									(xZBS)->(FieldPut(FieldPos(xZBS_+"TPROT"), cTpRt ))

								endif

							endif

						endif

					Else

						cLogProc += cChaveXml+" Chave Ja esta na Sincronizacao NFeDistribuicaoDFe."+CRLF

						RecLock(xZBS, .F. )

						if ! Empty( ( xZBS )->(FieldGet(FieldPos(xZBS_+"DEMI"))) ) .And. ( xZBS )->(FieldGet(FieldPos(xZBS_+"DEMI"))) < (dDataBase - 90)

							if cSt == "99"  //N„o aparecer, È muito velho o Bixo

								cSt := ( xZBS )->(FieldGet(FieldPos(xZBS_+"ST")))

							endif

						Endif

					Endif

					if ! Empty( ( xZBS )->(FieldGet(FieldPos(xZBS_+"CSITCO"))) )

						if cSitConf == "4" .And. ( xZBS )->(FieldGet(FieldPos(xZBS_+"CSITCO"))) > "0"

							cSitConf := ( xZBS )->(FieldGet(FieldPos(xZBS_+"CSITCO")))

						Else

							if ( xZBS )->(FieldGet(FieldPos(xZBS_+"CSITCO"))) > cSitConf

								cSitConf := ( xZBS )->(FieldGet(FieldPos(xZBS_+"CSITCO")))

							Endif

						Endif

					Endif

					( xZBS )->(FieldPut(FieldPos(xZBS_+"ST")	, cSt ))
					( xZBS )->(FieldPut(FieldPos(xZBS_+"CSITCO"), cSitConf ))
					( xZBS )->(FieldPut(FieldPos(xZBS_+"CNF")	, cNf ))
					( xZBS )->(FieldPut(FieldPos(xZBS_+"SERIE")	, cSer ))
					( xZBS )->(FieldPut(FieldPos(xZBS_+"CNPJEM"), cCnpjXml ))
					( xZBS )->(MsUnLock())

					U_HFTrvXml("SOLTA", "ZBS"+cChaveXml, nHdl) //SOLTAR

				Endif

			Else

				oDet := oWSrNfe:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP
				oDet := iif( valtype(oDet)=="O", {oDet}, oDet )

				nTotLen := Len( oDet )

				For nI := 1 to len( oDet )  //Deixar assim para quando for mais de 1, mas agora tem que ser de 1 em 1.

					cStt  := ""
					cMsg  := ""
					cInfo := ""
					cChave:= ""

					if Empty( oDet )

						if !IsBlind()
							U_MyAviso("HFXML06Bai","Objeto do sefaz vazio",{"OK"},3)
						else
							Conout("HFXML06Bai - Objeto do sefaz vazio")
						endif

						Exit

					endif

					cFileZip	:= Decode64( oDet[nI]:TEXT )
					nLenZip		:= Len( cFileZip )
					cFileUnZip  := ""

					// Funcao de descompactacao de arquivos compactados no formato GZip
					lOk  :=  GzStrDecomp( cFileZip, nLenZip, @cFileUnZip )
					oXml := XmlParser( cFileUnZip, "_", @cErro, @cWarning )
					cXml := cFileUnZip

					//AlteraÁ„o em 13/04/2017, erro SalOnline
					//If UPPER(Substr(oDet[nI]:_SCHEMA:TEXT,1,7)) <> UPPER("procCTe") //"139"
					//	cMsg	:=	"633"
					//	cInfo	:=	"Falta ManifestaÁ„o do Destinat·rio."
					//	cStt	:=	"0"

					If valtype(oXml) <> "O"

						cMsg	:=	"XXX"
						cInfo	:=	"N„o foi possÌvel Descompactar o XML."
						cStt	:=	"0"

					ElseIf UPPER(Substr(oDet[nI]:_SCHEMA:TEXT,1,7)) = UPPER("procNFe") .or. UPPER(Substr(oDet[nI]:_SCHEMA:TEXT,1,6)) = UPPER("resNFe")

						If UPPER(Substr(oDet[nI]:_SCHEMA:TEXT,1,7)) = UPPER("procNFe")

							If Type( "oXml:_NFEPROC:_PROTNFE:_INFPROT:_CHNFE:TEXT" ) <> "U"

								cChave := alltrim( oXml:_NFEPROC:_PROTNFE:_INFPROT:_CHNFE:TEXT )

							Else

								cChave := substr(cChv,1,44)

							Endif

							cSitConf  := manifver(cChave,cURL,cIdEnt,cAmb)  //"4"

						Else //if UPPER(Substr(oDet[nI]:_SCHEMA:TEXT,1,13)) = UPPER("procEventoNFe")

							If Type( "oXml:_RESNFE:_CHNFE:TEXT" ) <> "U"

								cChave := alltrim( oXml:_RESNFE:_CHNFE:TEXT )

							Else

								cChave := substr(cChv,1,44)

							Endif

							cSitConf := "0"

						EndIF

						cChaveXml := cChave
						nOrd      := (xZBZ)->( IndexOrd() )
						cNf       := Substr( cChaveXml, 26, 9 )
						cSer      := Substr( cChaveXml, 23, 3 )
						cCnpjXml  := Substr( cChaveXml, 07, 14 )
						cSt       := "  "
						cIE       := ""

						nHdl := -1

						If U_HFTrvXml("TRAVA", "ZBS"+cChaveXml, @nHdl)

							( xZBZ )->( DbSetOrder( 3 ) )

							If ( xZBZ )->(dbSeek( cChaveXml ) )

								cSt := "10"

							Else

								if cSitConf <> "0"

									cSt := "20"

								Endif

							EndIF

							( xZBZ )->( DbSetOrder( nOrd ) )
							( xZBS )->( DbSetOrder( 3 ) )

							If .Not. ( xZBS )->(dbSeek( cChaveXml ) )

								cLogProc += cChaveXml+" Nova Chave Sincronizada NFeDistribuicaoDFe."+CRLF

								lRet := .T.

								if !Empty( cIE )

									_cFil := u_Gravafil( cCnpj, cIE )

									if Empty( xFilial(xZBS) )  //Verifica se for compartilhado

										_cFil := xFilial( xZBS )

									endif

								else

									_cFil := xFilial( xZBS )

								endif

								//=====================//
								// Grava ZBS           //
								//=====================//
								RecLock(xZBS, .T. )
								( xZBS )->(FieldPut(FieldPos(xZBS_+"FILIAL"),  _cFil ))
								( xZBS )->(FieldPut(FieldPos(xZBS_+"CHAVE")	,  cChaveXml ))
								( xZBS )->(FieldPut(FieldPos(xZBS_+"AMB")	,  cAmb ))
								( xZBS )->(FieldPut(FieldPos(xZBS_+"DEST")	,  cCnpj ))
								( xZBS )->(FieldPut(FieldPos(xZBS_+"IDENT")	,  cIdEnt ))

								If ( xZBS )->( FieldPos(xZBS_+"MODELO") ) > 0

									( xZBS )->(FieldPut(FieldPos(xZBS_+"MODELO"), Substr(cChaveXml,21,2) ))

								EndIF

								if (xZBS)->(FieldPos(xZBS_+"TPROT")) > 0 //Tipo de Rotina Job ou Manual

									if Empty(  (xZBS)->(FieldGet(FieldPos(xZBS_+"TPROT"))) )

										if Type("cTpRt") <> "U"

											(xZBS)->(FieldPut(FieldPos(xZBS_+"TPROT"), cTpRt ))

										endif

									endif

								endif

							Else

								cLogProc += cChaveXml+" Chave Ja esta na Sincronizacao NFeDistribuicaoDFe."+CRLF
								RecLock(xZBS, .F. )

							Endif

							if ! Empty( ( xZBS )->(FieldGet(FieldPos(xZBS_+"CSITCO"))) )

								if cSitConf == "4" .And. ( xZBS )->(FieldGet(FieldPos(xZBS_+"CSITCO"))) > "0"

									cSitConf := ( xZBS )->(FieldGet(FieldPos(xZBS_+"CSITCO")))

								Else

									if ( xZBS )->(FieldGet(FieldPos(xZBS_+"CSITCO"))) > cSitConf

										cSitConf := ( xZBS )->(FieldGet(FieldPos(xZBS_+"CSITCO")))

									endif

								Endif

							Endif

							( xZBS )->(FieldPut(FieldPos(xZBS_+"ST")	, cSt ))
							( xZBS )->(FieldPut(FieldPos(xZBS_+"CSITCO"), cSitConf ))
							( xZBS )->(FieldPut(FieldPos(xZBS_+"CNF")	, cNf ))
							( xZBS )->(FieldPut(FieldPos(xZBS_+"SERIE")	, cSer ))

							//						If GetNewPar( "XM_ESPIAO", "N" ) == "S"
							//		    				U_HFESPIAO( cChaveXml )
							//						EndIf

							If Type("oXml:_NFEPROC:_NFE:_INFNF:_EMIT:_CNPJ:TEXT") <> "U"

								if oXml:_NFEPROC:_NFE:_INFCTE:_EMIT:_CNPJ:TEXT = Substr(cChaveXml,7,14)

								Else

									cCnpjXml := oXml:_NFEPROC:_NFE:_INFCTE:_EMIT:_CNPJ:TEXT

								Endif

								( xZBS )->(FieldPut(FieldPos(xZBS_+"CNPJEM"), cCnpjXml ))

							Elseif Type("oXml:_RESNFE:_CNPJ:TEXT") <> "U"

								if oXml:_RESNFE:_CNPJ:TEXT = Substr(cChaveXml,1,14)

								Else

									cCnpjXml := oXml:_RESNFE:_CNPJ:TEXT

								Endif

								( xZBS )->(FieldPut(FieldPos(xZBS_+"CNPJEM"), cCnpjXml ))

							Endif

							if Empty(( xZBS )->(FieldGet(FieldPos(xZBS_+"CNPJEM")))) .And. Type("oXml:_NFEPROC:_NFE:_INFNFE:_EMIT:_CPF:TEXT") <> "U"

								( xZBS )->(FieldPut(FieldPos(xZBS_+"CNPJEM"), oXml:_NFEPROC:_NFE:_INFNFE:_EMIT:_CPF:TEXT ))

							elseif Empty(( xZBS )->(FieldGet(FieldPos(xZBS_+"CNPJEM")))) .And. Type("oXml:_RESNFE:_CPF:TEXT") <> "U"

								( xZBS )->(FieldPut(FieldPos(xZBS_+"CNPJEM"), oXml:_RESNFE:_CPF:TEXT ))

							endif

							If Type("oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_DHEMI:TEXT") <> "U"

								( xZBS )->(FieldPut(FieldPos(xZBS_+"DEMI"), VerData(oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_DHEMI:TEXT) ))

							Elseif Type("oXml:_RESNFE:_DHEMI:TEXT") <> "U"

								( xZBS )->(FieldPut(FieldPos(xZBS_+"DEMI"), VerData(oXml:_RESNFE:_DHEMI:TEXT) ))

							Endif

							If Type("oXml:_NFEPROC:_NFE:_INFNFE:_VPREST:_VTPREST:TEXT") <> "U"

								( xZBS )->(FieldPut(FieldPos(xZBS_+"VNF"), Val(oXml:_NFEPROC:_NFE:_INFNFE:_VPREST:_VTPREST:TEXT) ))

							ElseIf Type("oXml:_RESNFE:_VNF:TEXT") <> "U"

								( xZBS )->(FieldPut(FieldPos(xZBS_+"VNF"), Val(oXml:_RESNFE:_VNF:TEXT) ))

							Endif

							If Type("oXml:_NFEPROC:_NFE:_INFNFE:_EMIT:_XNOME:TEXT") <> "U"

								( xZBS )->(FieldPut(FieldPos(xZBS_+"XNOME"), oXml:_NFEPROC:_NFE:_INFNFE:_EMIT:_XNOME:TEXT ))

							ElseIf Type("oXml:_RESNFE:_XNOME:TEXT") <> "U"

								( xZBS )->(FieldPut(FieldPos(xZBS_+"XNOME"), oXml:_RESNFE:_XNOME:TEXT ))

							Endif

							If Type("oXml:_NFEPROC:_NFE:_INFNFE:_EMIT:_IE:TEXT") <> "U"

								( xZBS )->(FieldPut(FieldPos(xZBS_+"IE"),  oXml:_NFEPROC:_NFE:_INFNFE:_EMIT:_IE:TEXT ))

							ElseIf Type("oXml:_RESNFE:_IE:TEXT") <> "U"

								( xZBS )->(FieldPut(FieldPos(xZBS_+"IE"),  oXml:_RESNFE:_IE:TEXT ))

							Endif

							If Type("oXml:_NFEPROC:_PROTNFE:_INFPROT:_DIGVAL:TEXT") <> "U"

								( xZBS )->(FieldPut(FieldPos(xZBS_+"DIGVAL"), oXml:_NFEPROC:_PROTNFE:_INFPROT:_DIGVAL:TEXT ))

							ElseIf Type("oXml:_RESNFE:_DIGVAL:TEXT") <> "U"

								( xZBS )->(FieldPut(FieldPos(xZBS_+"DIGVAL"), oXml:_RESNFE:_DIGVAL:TEXT ))

							EndIf

							If Type("oXml:_NFEPROC:_PROTNFE:_INFPROT:_DHRECBTO:TEXT") <> "U"

								( xZBS )->(FieldPut(FieldPos(xZBS_+"DHRECB"), VerData(oXml:_NFEPROC:_PROTNFE:_INFPROT:_DHRECBTO:TEXT) ))

							ElseIf Type("oXml:_RESNFE:_DHRECBTO:TEXT") <> "U"

								( xZBS )->(FieldPut(FieldPos(xZBS_+"DHRECB"), VerData(oXml:_RESNFE:_DHRECBTO:TEXT) ))

							Endif

							If Type("oXml:_RESNFE:_CSITNFE:TEXT") <> "U"

								( xZBS )->(FieldPut(FieldPos(xZBS_+"CSITNF"), oXml:_RESNFE:_CSITNFE:TEXT ))

							Else

								( xZBS )->(FieldPut(FieldPos(xZBS_+"CSITNF"), "1" ))

							Endif

							If Type("oDet["+alltrim(str(nI))+"]:_NSU:TEXT") <> "U"

								( xZBS )->(FieldPut(FieldPos(xZBS_+"NSU"), oDet[nI]:_NSU:TEXT ))

							Endif

							//If Type("oWSdNfe:OWSRETORNARDOCUMENTORESULT:OWSDOCUMENTO:OWSCCE:cCCEXMLRET") <> "U"  //cCORRECAO 21/7/17
							//	( xZBS )->(FieldPut(FieldPos(xZBS_+"CORREC"), oWSdNfe:OWSRETORNARDOCUMENTORESULT:OWSDOCUMENTO:OWSCCE:cCCEXMLRET ))
							//EndIf

							//21/7/17
							If Type("oXml") <> "U"

								( xZBS )->(FieldPut(FieldPos(xZBS_+"XML"), cXml ))

							EndIF

							( xZBS )->(MsUnLock())

							U_HFTrvXml("SOLTA", "ZBS"+cChaveXml, nHdl) //SOLTAR

						Endif

					Endif

				Next

			EndIF

		EndIF

	EndIF

Return( nRet )


//Rotina para gravar ZBZ,ZBT
//Funciona via job do gestao xml
User Function HFXMLRES( cNomArq, lAuto, lEnd, oProcess, cLogProc, nCount, cVem, cNewKey, cNewArq, cTpDow, cDocDest )

	Local aArea    := GetArea()
	Local lRet     := .T.
	Local nOrd     := (xZBZ)->( indexord() )
	Local cSerXMl  := ""
	Local cCodEmit := ""
	Local cIndRur  := ""
	Local cLojaEmit:= ""
	Local cFilSek  := ""
	Local cNomFil  := SM0->M0_NOMECOM
	Local cXml     := ""
	//LOCAL lSharedA2:= U_IsShared("SA2")
	Local cDir     := "\"+AllTrim(GetNewPar("MV_X_PATHX",""))+"\"
	Local lDirCnpj := AllTrim(GetNewPar("XM_DIRCNPJ","N")) == "S"
	Local lDirFil  := AllTrim(GetNewPar("XM_DIRFIL" ,"N")) == "S"
//Local lDirMod  := AllTrim(GetNewPar("XM_DIRMOD" ,"N")) == "S"
	Local cDirDest := AllTrim(cDir+"Importados\")
	Local cDirRej  := AllTrim(cDir+"Rejeitados\")
	Local cDirCfg  := AllTrim(cDir+"Cfg\") 
	Local lGravSA2 := .F.							//FR - 28/10/2021 - indica se gravou automaticamente SA2  
	//Local cAutoSA2 := GetNewPar("XM_SA2AUTO","N")   //FR - 28/10/2021 - indica se automatiza o cadastro do fornecedor na SA2 Sim ou N„o
	
	Local cAutoSA2 := GetNewPar("XM_SA2AUTO","N")   //FR - 28/10/2021 - indica se automatiza o cadastro do fornecedor na SA2 Sim ou N„o na classificaÁao da nf
	Local cAutoSA2D:= GetNewPar("XM_SA2AUTD","N")   //FR - 21/12/2021 - habilita cadastro autom·tico do fornecedor no download do xml

	Default cTpDow   := "R" 
	Default cDocDest := SM0->M0_CGC

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

	If !ExistDir(cDirDest)

		Makedir(cDirDest)

	EndIf

	cFilSek := xFilial( "SA2" )  //iif(lSharedA2, xFilial( "SA2" ), ( xZBS )->( FieldGet( FieldPos( xZBS_+"FILIAL" ) ) ) )

	DbSelectArea("SA2")
	DbSetOrder(3)

	if ! Empty( ( xZBS )->( FieldGet( FieldPos( xZBS_+"CNPJEM" ) ) ) )

		If DbSeek(cFilSek+( xZBS )->( FieldGet( FieldPos( xZBS_+"CNPJEM" ) ) ))

			cCodEmit := SA2->A2_COD
			cLojaEmit := SA2->A2_LOJA

			Do While .not. SA2->( eof() ) .and. SA2->A2_FILIAL == cFilSek .and.;
			SA2->A2_CGC == ( xZBS )->( FieldGet( FieldPos( xZBS_+"CNPJEM" ) ) )

				if SA2->A2_MSBLQL != "1"

					cCodEmit  := SA2->A2_COD
					cLojaEmit := SA2->A2_LOJA
					cIndRur   := SA2->A2_INDRUR

					Exit

				endif

				SA2->( dbSkip() )

			EndDo

		EndIf

	EndIF

	//FR - Insere registro na ZBZ:
	cNumNF := ""
	cSerXMl:= ""
	DbSelectArea(xZBS)

	( xZBS )->( DbSetOrder( 3 ) )

	If ( xZBS )->(dbSeek( cNewKey ) )

		DbSelectArea( xZBZ )
		(xZBZ)->( dbSetOrder(3) )

		If ! (xZBZ)->( dbSeek( cNewKey ) )  //Arquivo Baixado mas n„o conseguiu importar

			cNumNF := (xZBS)->(FieldGet(FieldPos(xZBS_+"CNF")))
			cSerXMl := AllTrim( Str( Val( (xZBS)->(FieldGet(FieldPos(xZBS_+"SERIE"))) ) ) )
			cSeriNF := U_vSerie( cSerXMl, cFilAnt, .F. )
			cCNPJEmi:= (xZBS)->(FieldGet(FieldPos(xZBS_+"CNPJEM")))

			//==================//
			// Grava ZBZ        //
			//==================//

			Reclock(xZBZ,.T.)
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CHAVE"), cNewKey))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"FILIAL"), (xZBS)->(FieldGet(FieldPos(xZBS_+"FILIAL"))) ))
			MsUnLock()

			Reclock(xZBZ,.F.)
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CNPJ"), (xZBS)->(FieldGet(FieldPos(xZBS_+"CNPJEM"))) ))  //
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CNPJD"), cDocDest))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CLIENT"), cNomFil))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"SERIE"), U_vSerie( cSerXMl, cFilAnt, .F. ) ))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"NOTA"), U_NumNota((xZBS)->(FieldGet(FieldPos(xZBS_+"CNF"))),nFormNfe)  ))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"FORNEC"), (xZBS)->(FieldGet(FieldPos(xZBS_+"XNOME")))  ))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"DTRECB"), dDataBase))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"DTNFE"), (xZBS)->(FieldGet(FieldPos(xZBS_+"DEMI"))) ))
			//(xZBZ)->(FieldPut(FieldPos(xZBZ_+"OBS"), cMensagem+CRLF+cError+CRLF+cWarning+CRLF+cOcorr))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"MODELO"), Substr(cNewKey,21,2)))  //FR - 04/06/2020 - estava chumbado "55" 
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CODFOR"), cCodEmit))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"INDRUR"), cIndRur))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"LOJFOR"), cLojaEmit))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPDOC"), "N"))
			//(xZBZ)->(FieldPut(FieldPos(xZBZ_+"UF"), cUfDest))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"SERORI"), cSerXMl  ))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"MANIF"), "0" ))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"IMPORT"), "2" ))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPDOWL"), cTpDow ))

			if cTpDow = "R"

				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PRENF"), VerStat( cFilAnt, (xZBS)->(FieldGet(FieldPos(xZBS_+"CNF"))), U_vSerie( cSerXMl, cFilAnt, .F. ), cCodEmit+cLojaEmit, "N", cNewKey )  ))
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"STATUS"), "1"))
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"XMLRES"), (xZBS)->(FieldGet(FieldPos(xZBS_+"XML"))) ))
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"VERSAO"), "4.00"))
				cLogProc += "[XML] Resumido "+cNewKey+" importado com sucesso."+CRLF

			else

				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PRENF"), "X"  ))
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"STATUS"), "1"))

				cXml := ( xZBS )->(FieldGet(FieldPos(xZBS_+"XML")))

				//FR - 28/04/2021 - NOVA TELA GEST√OXML - GRAVAR NOVO CAMPO ZBZ_ICOMPL - informaÁıes complementares
				xInfoCompl := ""
				xModelo    := Substr(cNewKey,21,2)
				xInfoCompl := U_fInfoCompl(xModelo,cXml)
				If xInfoCompl <> Nil  		
					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"ICOMPL"), xInfoCompl ))
				Endif
				if upper("<resNFe ") $ upper( cXml )

					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"XMLRES"), (xZBS)->(FieldGet(FieldPos(xZBS_+"XML"))) ))
					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"OBS"), "Chave XML Cancelada, XML Resumido"))
					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"VERSAO"), "4.00"))
					cLogProc += "[XML] Cancelado/Resumido "+cNewKey+" importado com sucesso."+CRLF

				elseif upper("<procNFe ") $ upper( cXml )

					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"XML"), (xZBS)->(FieldGet(FieldPos(xZBS_+"XML"))) ))
					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"OBS"), "Chave XML Cancelada, XML Completo"))
					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"VERSAO"), "4.00"))
					cLogProc += "[XML] Cancelado "+cNewKey+" importado com sucesso."+CRLF

				Else

					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"OBS"), "Chave XML Cancelada, N„o foi possÌvel baixar o XML"))
					cLogProc += "[XML] Cancelado "+cNewKey+" inserido com sucesso."+CRLF

				endif

			endif

			if (xZBZ)->(FieldPos(xZBZ_+"TPROT")) > 0 //Tipo de Rotina Job ou Manual

				if Empty(  (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPROT"))) )

					if Type("cTpRt") <> "U"

						(xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPROT"), cTpRt ))

					endif

				endif

			endif

			if (xZBZ)->(FieldPos(xZBZ_+"VLBRUT")) > 0

				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"VLBRUT"), (xZBS)->(FieldGet(FieldPos(xZBS_+"VNF"))) ))

			endif

			DbSelectArea(xZBZ)
			MsUnLock()

			//FR - 13/11/19
			//===================//
			// Grava ZBT:        //
			//===================//
			cModelo := ""
			cModelo := Substr(cNewKey,21,2)

			U_fGravaZBT(cXml,cModelo,cNewKey,cNumNF,cSeriNF,cCNPJEmi,cDocDest)
			//fim grava ZBT

			//----------------------------------------------------------//
			//FR - 28/10/2021 - DAIKIN - CADASTRO AUTOM›TICO FORNECEDOR 
			//----------------------------------------------------------//
			//If cAutoSA2 == "S"
			If cAutoSA2D == "S" //FR - 21/12/2021 - se cadastra autom·tico no download do xml		
			
				//Aqui chama a funÁ„o de cadastro autom·tico de fornecedor
				If (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC"))) <> "D" .and. (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC"))) <> "B"
					 
					//sÛ cadastra autom·tico se n„o for tipo Beneficiamento ou DevoluÁ„o (porque nesse caso È Cliente)
					U_fCADSA2(cCNPJEmi,(xZBZ)->(RECNO()) )				
				
				Endif
				
			Endif  			
			//----------------------------------------------------------//
			//FR - 28/10/2021 - DAIKIN - CADASTRO AUTOM›TICO FORNECEDOR 
			//----------------------------------------------------------//
		else

			//Verifica se xml esta cancelado
			if (xZBS)->(FieldGet(FieldPos(xZBS_+"CSITNF"))) == "3"

				cModelo := Substr(cNewKey,21,2)

				cXml := ( xZBS )->(FieldGet(FieldPos(xZBS_+"XML")))

				cOcorr := "Tipo de xml: " + cModelo +CRLF
				cOcorr += "Chave      : " + cNewKey +CRLF
				cOcorr += "ObservaÁ„o : " + "Cancelamento do Xml de "+cModelo+ " autorizado." +CRLF
				cOcorr += "Aviso      : " + "Cancele o documento de "+cModelo+ " manualmente." +CRLF

				cOcorr:= U_GetInfoErro("3",cOcorr,cModelo)

				Reclock(xZBZ,.F.)

				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"STATUS"), "1"))
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PROTC") , "" ))
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PRENF") , "X" ))

				if (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MAIL"))) <> "4"
					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"MAIL")  , "3" ))
				endif

				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"DTMAIL"), cOcorr ))

				if upper("<resNFe ") $ upper( cXml )

					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"XMLRES"), (xZBS)->(FieldGet(FieldPos(xZBS_+"XML"))) ))
					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"OBS"), "Chave XML Cancelada, XML Resumido"))
					cLogProc += "[XML] Cancelado/Resumido "+cNewKey+" importado com sucesso."+CRLF

				elseif upper("<procNFe ") $ upper( cXml )

					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"XML"), (xZBS)->(FieldGet(FieldPos(xZBS_+"XML"))) ))
					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"OBS"), "Chave XML Cancelada, XML Completo"))
					cLogProc += "[XML] Cancelado "+cNewKey+" importado com sucesso."+CRLF

				Else

					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"OBS"), "Chave XML Cancelada, N„o foi possÌvel baixar o XML"))
					cLogProc += "[XML] Cancelado "+cNewKey+" inserido com sucesso."+CRLF

				endif

				(xZBZ)->( MsUnLock() )		

			endif
			
		EndIf

	EndIf

	(xZBZ)->( dbSetORder( nOrd ) )

	_cDirDest:= _cDirDest + "NFERES" + cBarra

	If !ExistDir(_cDirDest)

		Makedir(_cDirDest)

	EndIf

	If lDirFil

		_cDirDest:= _cDirDest + cFilAnt+cBarra

		If !ExistDir(_cDirDest)

			Makedir(_cDirDest)

		EndIf

	EndIf

	If lDirCnpj

		cCnpjEmit := Substr(cNewKey,7,14)

		_cDirDest:= _cDirDest + cCnpjEmit+cBarra

		If !ExistDir(_cDirDest)

			Makedir(_cDirDest)

		EndIf

	EndIf

	if File( cDir+cNomArq )

		cFinalF:= _cDirDest+cNomArq

		__CopyFile( cDir+cNomArq, cFinalF )

		FErase(cDir+cNomArq)

	endif

	RestArea( aArea )

Return(lRet)


Static Function VerStat( cFilXml, cDocXMl, cSerie, cCodFor, cTipoDoc, cChaveXml )  //"B"

	Local cRet := "B"
	Local aArea := GetArea()
	Local lSeek := .F.
	Local cNotaSeek := ""

	Private nFormNfe := Val(GetNewPar("XM_FORMNFE","6"))
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


//Rotina para gerar o xml resumido
//Rotina utilizada no job do gestao xml
User Function HFXML06R(lAuto,lEnd,oProcess,cLogProc,nCount,lMostra)      //U_HFXML06R(.T.,.F.,,,0,.F.)

Local aArea     := GetArea()
//Local nRegMat := SM0->( Recno() )
//Local cEmpres := SM0->M0_CODIGO
//Local cFilAtu := SM0->M0_CODFIL
Local cChave    := ""
Local cNsu      := ""
Local cQuery    := ""

Local cAliasZBZ := GetNextAlias()
Local dAutor    := dDataBase - GetNewPAr("XM_QDIADWN", 90) 
//FR - 05/10/2020
Private xZBZ  	  := GetNewPar("XM_TABXML","ZBZ")      
Private xZB5  	  := GetNewPar("XM_TABAMAR","ZB5")
Private xZBS  	  := GetNewPar("XM_TABSINC","ZBS")
Private xZBE      := GetNewPar("XM_TABEVEN","ZBE")
Private xZBZ_ 	  := iif(Substr(xZBZ,1,1)=="S", Substr(xZBZ,2,2), Substr(xZBZ,1,3)) + "_"
Private xZB5_ 	  := iif(Substr(xZB5,1,1)=="S", Substr(xZB5,2,2), Substr(xZB5,1,3)) + "_"
Private xZBS_ 	  := iif(Substr(xZBS,1,1)=="S", Substr(xZBS,2,2), Substr(xZBS,1,3)) + "_"
Private xZBE_     := iif(Substr(xZBE,1,1)=="S", Substr(xZBE,2,2), Substr(xZBE,1,3)) + "_"
Private xZBC      := GetNewPar("XM_TABCAC","ZBC")
Private xZBC_     := iif(Substr(xZBC,1,1)=="S", Substr(xZBC,2,2), Substr(xZBC,1,3)) + "_"
Private xZBO      := GetNewPar("XM_TABOCOR","ZBO"), xRetSEF := ""
Private xZBO_     := iif(Substr(xZBO,1,1)=="S", Substr(xZBO,2,2), Substr(xZBO,1,3)) + "_"
Private xZBI      := GetNewPar("XM_TABIEXT","ZBI")
Private xZBI_     := iif(Substr(xZBI,1,1)=="S", Substr(xZBI,2,2), Substr(xZBI,1,3)) + "_"
Private xZBA  	  := GetNewPar("XM_TABAMA2","ZBA")
Private xZBA_ 	  := iif(Substr(xZBA,1,1)=="S", Substr(xZBA,2,2), Substr(xZBA,1,3)) + "_"
//FR - 05/10/2020

Default cLogProc := ""
Default lAuto    := .F.
Default oProcess := Nil
Default lEnd     := .F.
Default nCount   := 0
Default lMostra  := .F. 

If lMostra .And. !lAuto .Or. oProcess <> Nil
		oProcess:IncRegua1("Verificando XMLs Resumidos ...")
		oProcess:IncRegua2("Aguarde...")
	EndIf

cQuery := " SELECT " + xZBZ_ + "CHAVE, ZBZ.R_E_C_N_O_ "
cQuery += " FROM "+ RetSqlName(xZBZ) + " ZBZ "
cQuery += " WHERE ZBZ.D_E_L_E_T_ = '' "

if lAuto
	cQuery += " AND ZBZ."+ xZBZ_ +"FILIAL = '" + cFilAnt + "' "
Endif

cQuery += " AND ZBZ." + xZBZ_ + "TPDOWL = 'R' AND ZBZ." + xZBZ_ + "PRENF <> 'X' "		//voltar
cQuery += " AND "+xZBZ_+"DTNFE >= '"+dtos(dAutor)+"' " 									//voltar
cQuery += " ORDER BY "+xZBZ_+"CHAVE "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasZBZ,.T.,.T.)

DbSelectArea(cAliasZBZ)
(cAliasZBZ)->( dbGoTop() )

While !(cAliasZBZ)->(Eof())

		If lEnd
			MsgStop("*** Cancelado pelo Operador ***","Fim")
			Exit
		EndIf

	DbSelectArea( xZBZ )
	(xZBZ)->( dbGoto( (cAliasZBZ)->R_E_C_N_O_ ) )

	cChave := Substr( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))),1, 44 )
    
	If lMostra .And. !lAuto .Or. oProcess <> Nil

			oProcess:IncRegua1("Verificando XMLs Resumidos ...")
			oProcess:IncRegua2(cChave)
			
	EndIf

	DbSelectArea(xZBS)
	DbSetOrder(3)
	if DbSeek( cChave )

		cNsu := (xZBS)->(FieldGet(FieldPos(xZBS_+"NSU")))

	endif

	If U_HFDGXML( cChave, .T. , .F. ,  NIL    ,cLogProc, nCount, "2", cNsu  ) >= 0
		//xRet := U_HFDOWCHV( cCnpj,cChave,cAmb,cIdEnt,@cLogProc )   //Pedir Pela Chave
		cLogProc += "Download Completo "+cChave+CRLF

		Conout("Download Completo do xml resumido "+cChave)

		(xZBZ)->( dbGoto( (cAliasZBZ)->R_E_C_N_O_ ) )

		dbSelectArea( xZBZ )
		RecLock(xZBZ, .F. )
			( xZBZ )->(FieldPut(FieldPos(xZBZ_+"TPDOWL"), " " ))
		MsUnLock()
	Else
		cLogProc += "N„o Fez Download Completo "+cChave+CRLF
	Endif

	DbSelectArea(cAliasZBZ)
	(cAliasZBZ)->(dbSkip())
End

DbSelectArea( xZBZ )

RestArea(aArea) 


Return(.T.)

/*
Static function getAmbMde()

Local cAmbiente := ""
Local cURL		:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local oWs
Local lUsacolab := .F. //UsaColaboracao("4")

If !lUsacolab //.and. ReadyTSS()
	oWs := WSMANIFESTACAODESTINATARIO():New()
	oWs:cUserToken   := "TOTVS"
	oWs:cIDENT	     := retIdEnti(lUsacolab)
	oWs:cAMBIENTE	 := ""
	oWs:cVERSAO      := ""
	oWs:_URL         := AllTrim(cURL)+"/MANIFESTACAODESTINATARIO.apw"
	oWs:CONFIGURARPARAMETROS()
	cAmbiente		 := oWs:OWSCONFIGURARPARAMETROSRESULT:CAMBIENTE

	freeObj(oWs)

	oWs := nil
EndIf

Return cAmbiente
*/

Static Function __Dummy(lRecursa) //warning W0010 Static Function <?> never called

lRecursa := .F.

If (lRecursa)
	__Dummy(.F.)
	U_HFXML06D()
	U_HFXML6SM()
	U_HFXML6JB()
	U_HFXML6CD()
	U_HFXML6BS()
	U_TELAJUST()
	U_PARSGDE()
	U_HFDTTIME()
	U_HFXMLRES()
EndIF

Return(lRecursa)

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…››››››››››—››››››››››À›››››››—››››››››››››››››››››À››››››—›››››››››››››ª±±
±±∫Programa  ≥IMPXMLFOR ∫ Autor ≥ Roberto Souza      ∫ Data ≥  11/04/12   ∫±±
±±Ã››››››››››ÿ›››››››››› ›››››››››››››››››››››››››››› ››››››››››››››››››››π±±
±±∫Descricao ≥ LÍ o XML dos Fornecedores                                  ∫±±
±±∫          ≥                                                            ∫±±
±±Ã››››››››››ÿ››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››π±±
±±∫Uso       ≥ Importa XML                                                ∫±±
±±»›››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››››º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
User Function fIMPXMLFOR(cXml,cModelo,cCnpjEmi,cChaveXML)

	Local   nTamIte     := TAMSX3("C7_ITEM")[1]
	Local	x			:= 0
	Local	i			:= 0
	Local   cNF         := ""
	Local   cSeriNF     := ""
	Local   cTAG     	:= ""
	Local   cTGP     	:= ""
	Local   cError      := ""
	Local   cWarning    := ""
	Local   aCST        := {}
	Local   Fr          := 0
	//FR -19/10/2022 - MBIOLOG - usa LOTE DESMEMBRADO 1 PRODUTO -> 'N' QTDES DE LOTES, 
	/*Estrutura exemplo:
	1 item de produto com qtde = 100 , porÈm repartido em 4 lotes conforme abaixo:
	A idÈia È gravar na ZBT uma linha para cada lote informado, respeitando a qtde por cada lote
	<detalhe item>
		<prod> --> item 1
			<cÛdigo produto> PLACA
			<qtde>           100
		<rastro>
			<rastro[1]> 
				<numero Lote> 	LOTE001
				<qtde lote> 	24
			<rastro[2]> 
				<numero Lote> 	LOTE002
				<qtde lote> 	30
			<rastro[3]> 
				<numero Lote> 	LOTE003
				<qtde lote> 	24
			<rastro[4]> 
				<numero Lote> 	LOTE004
				<qtde lote> 	2
		</det>
	*/
	Local   cDesmembra  := GetNewPar("XM_DESLOTE" , "N")  //FR - 19/10/2022 - MBIOLOG - ATIVA DESMEMBRAMENTO DE LOTE
	Local   lDesmembra  := .F.
	Local   nl 			:= 0 
	Local cCFOP         := ""	//FR - 16/05/2023 - #14880 - ELECON - CRIAR CAMPO ZBT_CFOP NO ITEM XML

	Private oXml
	Private oDet        := {}
	Private cTipoNf     := "N"
	Private aItXml      := {}
	Private cXped       := Space(6)
	Private cXItemPed   := ""
	Private cXItemCST   := ""
	Private cNcm        := ""

	//====================================//
	// LÍ o XML contido no campo ZBZ_XML  //
	//====================================//
	//Faz backup do xml sem retirar os caracteres especiais
	cBkpXml := cXml

	//Executa rotina para retirar os caracteres especiais
	cXml := u_zCarEspec( cXml )

	oXml := XmlParser(cXml, "_", @cError, @cWarning )

	//retorna o backup do xml
	cXml := cBkpXml

/*
If oXml == NIL .Or. !Empty(cError) .Or. !Empty(cWarning)
	MsgSTOP("XML Invalido ou N„o Encontrado, a ImportaÁ„o N„o foi Efetuada.")
	Return
EndIf 
*/

	cNFOri    := ""
	cSROri    := ""
	cChaveOri := ""		//FR - 15/02/2021 - #6166 - MaxiRubber - NOVO CAMPO, chave da nf original (CTE)	
	cCliFor   := ""
	cLoja     := ""
	cTipoFor  := ""
	nValNFOri := 0
	aItXml    := {}
	cCFOP     := ""

	If oXml <> NIL .Or. Empty(cError) .Or. Empty(cWarning)

		//FR - 14/11/19
		/*
		- produto
		- descriÁ„o produto
		- pedido
		- item pedido
		*/
		If cModelo $ "55,65"

			cTAG     := "NFE"
			cTGP     := "NFE"

		ElseIf cModelo == "57"

			cTAG     	:= "CTE"
			cTGP        := "CTE"

		ElseIf cModelo == "67"

			cTAG     	:= "CTE"
			cTGP        := "CTEOS"

		EndIf

		cTagAux := "oXml:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_IDE:_SERIE:TEXT"               //sÈrie

		If type( cTagAux ) <> "U"

			cSeriNF := &cTagAux

		Endif

		cTagAux := "oXml:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_IDE:_N"+Left(cTAG,2)+":TEXT"   //documento nf

		If type( cTagAux ) <> "U"

			cNF := &cTagAux

		Endif

		//FR - 15/02/2021 - Checagens para montar o array oDet (detalhes/itens do XML)
		If cModelo $ "55,65"

			if Type( "oXml:_NFEPROC:_NFE:_INFNFE:_DET" ) != "U"

				oDet := oXml:_NFEPROC:_NFE:_INFNFE:_DET
				oDet := IIf(ValType(oDet)=="O",{oDet},oDet)

			else

				oDet := {}

			endif

		Elseif cModelo $ "57"

			If Type( "oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP" ) != "U"

				oDet := oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP
				oDet := iif( ValType(oDet) == "O", {oDet}, oDet )

			else

				oDet := {}

			EndIf

		Else

			If Type( "oXml:_CTEOSPROC:_CTEOS:_INFCTE:_VPREST:_COMP" ) != "U"

				oDet := oXml:_CTEOSPROC:_CTEOS:_INFCTE:_VPREST:_COMP
				oDet := iif( ValType(oDet) == "O", {oDet}, oDet )

			else

				oDet := {}

			EndIf

		Endif
        //FR - 15/02/2021 - fim das checagens para montar oDet
        
		cItem    := ""

		cProduto := ""
		cDescProd:= ""
		cXped    := Space(6)
		cXItemPed:= ""
		cXItemCST:= ""
		//CAMPOS NOVOS ZBT
		cUM      := ""		//FR - 15/04/2021
		cNCM     := ""		//FR - 15/04/2021
		cNFCI    := ""		//FR - 28/04/2021
		nVLDESC  := 0		//FR - 28/04/2021
		cLOTE    := ""		//FR - 28/04/2021
		cValLote := ""		//FR - 28/04/2021
		dValLote := CtoD("  /  /    ") 	//FR - 28/04/2021
		cAnoFab := ""

		//FR - 11/01/2022 - Petra - incluir campo ICMST
		_ICMSTBas:=0		
		_ICMSTAlq:= 0
		_ICMSTVal:= 0
		//FR - 11/01/2022 - Petra - incluir campo ICMST	

		//------------------------------------------------------------------------------------//
		//FR - 13/02/2023 - TRATATIVA PARA TRAZER O N⁄MERO DA NF ORIGINAL DO CABE«ALHO DO XML
		aNFOri := {}   
		cChaveOri := ""
		cNFORI    := ""
		cSRORI    := ""
		//FR - 13/02/2023 - TRATATIVA PARA TRAZER O N⁄MERO DA NF ORIGINAL DO CABE«ALHO DO XML
		//------------------------------------------------------------------------------------//

		cCFOP := "" //FR - 16/05/2023 - #14880 - ELECON - GRAVAR NO NOVO CAMPO ZBT_CFOP (CFOP NO ITEM XML)

		If cModelo $ "55,65"     //obtenÁ„o dos itens do XML, qdo modelo for 55 ou 65

			nTotLen := Len(oDet)
			nl      := 0  //para limitar o tamanho do array RASTRO
	
			For i := 1 To nTotLen
				//FR -19/10/2022 - MBIOLOG - usa LOTE DESMEMBRADO 1 PRODUTO -> 'N' QTDES DE LOTES, 
				//EX: o item tem 100 PE«AS -> 50 DE UM LOTE; 50 DE OUTRO LOTE 
				lDesmembra := .F.
				cProduto := ""
				cDescProd:= ""
				nQuant   := 0
				nVunit	 := 0 
				nTotal   := 0 
				cXped    := Space(6)
				cXItemPed:= ""
				cXItemCST:= ""
				cChaveOri:= ""	//FR - 15/02/2021 - #6166 - MaxiRubber
				cUM      := ""		//FR - 15/04/2021
				cNCM     := ""		//FR - 15/04/2021
				cNFCI    := ""		//FR - 28/04/2021
				nVLDESC  := 0		//FR - 28/04/2021
				cLOTE    := ""		//FR - 28/04/2021
				cValLote := ""		//FR - 28/04/2021
				dValLote := CtoD("  /  /    ") 	//FR - 28/04/2021
				cAnoFab  := ""
				//------------------------------------------------------------//                                                           
				//FR - 16/05/2023 - CHAMADO ELECON #14880
				//     Criar campo CFOP no item do XML
				//------------------------------------------------------------//
				cCFOP    := ""

				cTagNFORI := "oXml:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_IDE:_NFREF"   //documento ORIGINAL
				
				If Type(cTagNFORI) <> "U"
				
					aNFOri := U_FTRAZNFORI(cTagNFORI) //FR - 13/02/2023 - CAPTAR NUMERO DA NF ORIGEM VINDO DO CABE«ALHO DO XML
				
				EndIf

				//-----------------------//
				//retorno da funÁ„o:  
				//Aadd(aRef, cChvReg)
				//Aadd(aRef, _NfOri)
				//Aadd(aRef, _SrOri )
				//-----------------------//
				If Len(aNFOri) > 0
					cChaveOri := aNFOri[1]
					cNFORI    := aNFOri[2]
					cSRORI    := aNFOri[3]
				Endif

				//item
				cTagAux    := "oDet["+AllTrim(str(I))+"]:_NITEM:TEXT"  //odet[1]:_NITEM:TEXT
				If type( cTagAux ) <> "U"
					cItem := Strzero(VAL(&cTagAux),4)
				Endif
				
				//cÛdigo produto
				cTagAux    := "oDet["+AllTrim(str(I))+"]:_PROD:_CPROD:TEXT"
				If type( cTagAux ) <> "U"
					cProduto := UPPER(&cTagAux)
				Endif

				//NCM do produto
				cTagAux := "oDet["+AllTrim(str(I))+"]:_PROD:_NCM:TEXT"
				//iif( Type("oxml:_nfeproc:_nfe:_infnfe:_det:_prod:_ncm:text") <> "U", oxml:_nfeproc:_nfe:_infnfe:_det:_prod:_ncm:text, Criavar("B1_POSIPI") )
				If type( cTagAux ) <> "U"
					cNcm := (&cTagAux)
				Endif

				//descriÁ„o produto
				cTagAux    := "oDet["+AllTrim(str(I))+"]:_PROD:_XPROD:TEXT"
				If type( cTagAux ) <> "U"
					cDescProd := UPPER(&cTagAux)
				Endif

				//quantidade do produto										//FR - 10/03/2020
				cTagAux := "oDet["+AllTrim(str(I))+"]:_PROD:_QCOM:TEXT"  
				If type( cTagAux ) <> "U"
					nQuant := VAL(&cTagAux)		//VAL(oDet[i]:_Prod:_QCOM:TEXT)
				Endif
				
				//valor unitario  											//FR - 10/03/2020
				cTagAux := "oDet["+AllTrim(str(I))+"]:_PROD:_VUNCOM:TEXT"  
				If type( cTagAux ) <> "U"
					nVunit := VAL(&cTagAux)		//VAL(oDet[i]:_Prod:_VUNCOM:TEXT)
				Endif
				
				//valor total do produto									//FR - 10/03/2020 
				cTagAux := "oDet["+AllTrim(str(I))+"]:_PROD:_VPROD:TEXT"  
				If type( cTagAux ) <> "U"
					nTotal := VAL(&cTagAux)		//VAL(oDet[i]:_Prod:_VPROD:TEXT)
				Endif

				//pedido de compra
				cTagAux    := "oDet["+AllTrim(str(I))+"]:_PROD:_XPED:TEXT"
				If type( cTagAux ) <> "U"
					cXped := UPPER(&cTagAux)
				Endif

				//FR - caso a estrutura da tag do pedido de compra seja diferente, faÁo nova checagem:
				If Empty(cXped)
					cTagAux    := "_NFEPROC:_NFE:_INFNFE:_COMPRA:_XPED:TEXT"   //oDet["+AllTrim(str(I))+"]:_PROD:_XPED:TEXT"
					If type( cTagAux ) <> "U"
						cXped := &cTagAux
					Endif
				Endif

				//Item do pedido de compra
				cTagAux    := "oDet["+AllTrim(str(I))+"]:_PROD:_NITEMPED:TEXT"
				If type( cTagAux ) <> "U"
					cXItemPed  := StrZero( Val( &cTagAux ), nTamIte )
				Endif

				//UM do produto                  								//FR - 15/04/2021
				cTagAux    := "oDet["+AllTrim(str(I))+"]:_PROD:_UCOM:TEXT"
				If type( cTagAux ) <> "U"
					cUM  := Alltrim(&cTagAux)
				Endif
				//NFCI do produto				
			  	If XmlChildEx(oDet[i]:_Prod,"_NFCI") <> nil
		        	cTagAux:= "oDet["+AllTrim(Str(i))+"]:_PROD:_NFCI:TEXT" 		
					cNFCI  := &cTagAux
				EndIf
				
				//VLDESC
				If XmlChildEx(oDet[i]:_Prod,"_VDESC") <> nil 
					cTagAux   := "oDet["+Alltrim(STR(i))+"]:_PROD:_VDESC:TEXT"
					nVLDESC := Val(&cTagAux) 
				Endif	

				//LOTE				
				If XmlChildEx(oDet[i]:_PROD,"_RASTRO") <> nil //se o objeto existe n„o È nulo
					If ValType(oDet[i]:_PROD:_RASTRO) <> "A" //se a tag rastro n„o È um array, sÛ tem um lote
						cTagAux   := "oDet["+Alltrim(STR(i))+"]:_PROD:_RASTRO:_NLOTE:TEXT"
						cLOTE     := &cTagAux //oDet[i]:_Prod:_Rastro:_NLOTE:TEXT
						
						cTagAux   := "oDet["+Alltrim(STR(i))+"]:_PROD:_RASTRO:_DVAL:TEXT"
						cValLote  := &cTagAux //oDet[i]:_Prod:_Rastro:_DVAL:TEXT		//vem assim: "2045-12-16" -> transformar para 16/12/2045
						dValLote  := CtoD( Substr(cValLote,9,2) + "/" + Substr(cValLote,6,2) + "/" + Substr(cValLote,1,4) ) 
						
						cTagAux   := "oDet["+Alltrim(STR(i))+"]:_PROD:_RASTRO:_DFAB:TEXT"
						cAnoFab   := &cTagAux //Substr(oDet[i]:_Prod:_Rastro:_DFAB:TEXT , 3,2)  	//vem assim: "2018-08-01" -> transformar para 18 o ano tem 2 dÌgitos apenas					
						//-----------------------------------------------------------------------------------//
						//FR - 19/10/2022 -TRATATIVA DO N⁄MERO DE LOTE QUANDO H› V›RIOS LOTES NO MESMO ITEM
						//MBIOLOG
						//----------------------------------------------------------------------------------//
					
					Else //se È array
						//If ValType(oDet[i]:_PROD:_RASTRO) == "A" //se for um array de v·rios lotes
						If cDesmembra == "S" //sÛ faz o desmembramento se o par‚metro estiver ativado Sim
							If Len(oDet[i]:_PROD:_RASTRO) > 1
								lDesmembra := .T.
							Endif 
						Endif
					Endif  
				Endif	//If XmlChildEx(oDet[i]:_PROD,"_RASTRO") <> nil 
				
				//CFOP DO ITEM
				//------------------------------------------------------------//                                                           
				//FR - 16/05/2023 - CHAMADO ELECON #14880
				//     Criar campo CFOP no item do XML
				//------------------------------------------------------------//
				//CFOP				
				 cCFOP := AllTrim(oDet[i]:_Prod:_CFOP:TEXT)
				 //FR - 16/05-2023 - CHAMADO ELECON #14880
				 //-----------------------------------------------------------//
				
			/*
			IPI - TAG: imposto:IPI:
			- ZBT_IPIENQ - cEnq
			- ZBT_IPICST - IPITrib:CST
			- ZBT_IPIBAS - IPITrib:vBC
			- ZBT_IPIALQ - IPITrib:pIPI
			- ZBT_IPIVAL - IPITrib:vIPI
			PIS - PISALIQ - TAG: imposto:PIS:PISAliq
			- ZBT_PISCST - CST
			- ZBT_PISBAS - vBC
			- ZBT_PISALQ - pPIS
			- ZBT_PISVAL - vPIS
			COFINS - TAG: imposto:COFINS:COFINSAliq
			- ZBT_COFCST - CST
			- ZBT_COFBAS - vBC
			- ZBT_COFALQ - pCOFINS
			- ZBT_COFVAL - vCOFINS
			ICMS - TAG: imposto:ICMS:ICMS00
			- ZBT_ICMCST - CST
			- ZBT_ICMBAS - vBC
			- ZBT_ICMALQ - pICMS
			- ZBT_ICMVAL - vICMS
			*/

			_IPIEnq := ""
			_IPICst := ""
			_PISCst := ""
			_COFCst := ""
			_ICMCst := ""
			_TAGPIS := ""
			_TAGCofins := ""
			_IPIBas := 0
			_IPIAlq := 0
			_IPIVal := 0
			_PISBas := 0
			_PISAlq := 0
			_PISVal := 0
			_COFBas := 0
			_COFAlq := 0
			_COFVal := 0
			_ICMBas := 0
			_ICMAlq := 0
			_ICMVal := 0

			//FR - 11/01/2022 - Petra - incluir campo ICMST
			_ICMSTBas:=0		
			_ICMSTAlq:= 0
			_ICMSTVal:= 0
			//FR - 11/01/2022 - Petra - incluir campo ICMST	
			//****************
			//***** IPI ******
			//****************

			//IPI ENQUADRAMENTO - Produto
			cTagAux    := "oDet["+AllTrim(str(I))+"]:_IMPOSTO:_IPI:_CENQ:TEXT"
			If Type( cTagAux ) <> "U"
				_IPIEnq := ALLTRIM(&cTagAux)
			EndIf

			//IPI CST - Produto
			cTagAux    := "oDet["+AllTrim(str(I))+"]:_IMPOSTO:_IPI:_IPITRIB:_CST:TEXT"
			If Type( cTagAux ) <> "U"
				_IPICst := ALLTRIM(&cTagAux)
			EndIf

			//IPI VALOR BASE - Produto
			cTagAux    := "oDet["+AllTrim(str(I))+"]:_IMPOSTO:_IPI:_IPITRIB:_VBC:TEXT"
			If Type( cTagAux ) <> "U"
				_IPIBas := VAL(ALLTRIM(&cTagAux))
			EndIf

			//IPI ALIQUOTA - Produto
			cTagAux    := "oDet["+AllTrim(str(I))+"]:_IMPOSTO:_IPI:_IPITRIB:_PIPI:TEXT"
			If Type( cTagAux ) <> "U"
				_IPIAlq := VAL(ALLTRIM(&cTagAux))
			EndIf

			//IPI VALOR - Produto
			cTagAux    := "oDet["+AllTrim(str(I))+"]:_IMPOSTO:__IPI:_IPITRIB:_VIPI:TEXT"
			If Type( cTagAux ) <> "U"
				_IPIVal := VAL(ALLTRIM(&cTagAux))
			EndIf

			//****************
			//***** PIS ******
			//****************

			//PIS ALIQ - Produto
			cTagAux    := "oDet["+AllTrim(str(I))+"]:_IMPOSTO:_PIS:_PISALIQ:_CST:TEXT"
			If Type( cTagAux ) <> "U"
				_PISCST := ALLTRIM(&cTagAux)
				_TAGPis := "_PISALIQ"
			EndIf

			//PIS OUTR - Produto
			cTagAux    := "oDet["+AllTrim(str(I))+"]:_IMPOSTO:_PIS:_PISOUTR:_CST:TEXT"
			If Type( cTagAux ) <> "U"
				_PISCST := ALLTRIM(&cTagAux)
				_TAGPis := "_PISOUTR"
			EndIf

			//PIS NT - Produto
			cTagAux    := "oDet["+AllTrim(str(I))+"]:_IMPOSTO:_PIS:_PISNT:_CST:TEXT"
			If Type( cTagAux ) <> "U"
				_PISCST := ALLTRIM(&cTagAux)
				_TAGPis := "_PISNT"
			EndIf
			
			//PIS QTDE - Produto
			cTagAux    := "oDet["+AllTrim(str(I))+"]:_IMPOSTO:_PIS:_PISQTDE:_CST:TEXT"
			If Type( cTagAux ) <> "U"
				_PISCST := ALLTRIM(&cTagAux)
				_TAGPis := "_PISQTDE"
			EndIf
			
			//PIS ST - Produto
			cTagAux    := "oDet["+AllTrim(str(I))+"]:_IMPOSTO:_PIS:_PISST:_VBC:TEXT"
			If Type( cTagAux ) <> "U"
				_PISCST := ALLTRIM(&cTagAux)
				_TAGPis := "_PISST"
			EndIf

			/*
			If !Empty(_PISCST) //Caso esteja vazio pula e pega a tag PIS Outros
				_TAGPis := "_PISALIQ"
			Else
				_TAGPis := "_PISOUTR"
			EndIf
			
			//PIS CST - Produto
			cTagAux    := "oDet["+AllTrim(str(I))+"]:_IMPOSTO:_PIS:"+_TAGPis+":_CST:TEXT"
			If Type( cTagAux ) <> "U"
				_PISCST := ALLTRIM(&cTagAux)
			EndIf
			*/

			//PIS VALOR BASE - Produto
			cTagAux    := "oDet["+AllTrim(str(I))+"]:_IMPOSTO:_PIS:"+_TAGPis+":_VBC:TEXT"
			If Type( cTagAux ) <> "U"
				_PISBAS := VAL(ALLTRIM(&cTagAux))
			EndIf

			//PIS ALIQUOTA - Produto
			cTagAux    := "oDet["+AllTrim(str(I))+"]:_IMPOSTO:_PIS:"+_TAGPis+":_PPIS:TEXT"
			If Type( cTagAux ) <> "U"
				_PISALQ := VAL(ALLTRIM(&cTagAux))
			EndIf

			//PIS VALOR - Produto
			cTagAux    := "oDet["+AllTrim(str(I))+"]:_IMPOSTO:_PIS:"+_TAGPis+":_VPIS:TEXT"
			If Type( cTagAux ) <> "U"
				_PISVAL := VAL(ALLTRIM(&cTagAux))
			EndIf

			//****************
			//**** COFINS ****
			//****************

			//COFINS ALIQ - Produto
			cTagAux    := "oDet["+AllTrim(str(I))+"]:_IMPOSTO:_COFINS:_COFINSALIQ:_CST:TEXT"
			If Type( cTagAux ) <> "U"
				_COFCST := ALLTRIM(&cTagAux)
				_TAGCofins := "_COFINSALIQ"
			EndIf

			//COFINS OUTR - Produto
			cTagAux    := "oDet["+AllTrim(str(I))+"]:_IMPOSTO:_COFINS:_COFINSOUTR:_CST:TEXT"
			If Type( cTagAux ) <> "U"
				_COFCST := ALLTRIM(&cTagAux)
				_TAGCofins := "_COFINSOUTR"
			EndIf
			
			//COFINS NT - Produto
			cTagAux    := "oDet["+AllTrim(str(I))+"]:_IMPOSTO:_COFINS:_COFINSNT:_CST:TEXT"
			If Type( cTagAux ) <> "U"
				_COFCST := ALLTRIM(&cTagAux)
				_TAGCofins := "_COFINSNT"
			EndIf

			//COFINS QTDE - Produto
			cTagAux    := "oDet["+AllTrim(str(I))+"]:_IMPOSTO:_COFINS:_COFINSQTDE:_CST:TEXT"
			If Type( cTagAux ) <> "U"
				_COFCST := ALLTRIM(&cTagAux)
				_TAGCofins := "_COFINSQTDE"
			EndIf
			
			//COFINS ST - Produto
			cTagAux    := "oDet["+AllTrim(str(I))+"]:_IMPOSTO:_COFINS:_COFINSST:_VBC:TEXT"
			If Type( cTagAux ) <> "U"
				//_COFCST := ALLTRIM(&cTagAux)
				_TAGCofins := "_COFINSST"
			EndIf
			
			/*
			If !Empty(_COFCST) //Caso esteja vazio pula e pega a tag Cofins Outros
				_TAGCofins := "_COFINSALIQ"
			Else
				_TAGCofins := "_COFINSOUTR"
			EndIf
			
			//COFINS CST - Produto
			cTagAux    := "oDet["+AllTrim(str(I))+"]:_IMPOSTO:_COFINS:"+_TAGCofins+":_CST:TEXT"
			If Type( cTagAux ) <> "U"
				_COFCST := ALLTRIM(&cTagAux)
			EndIf
			*/
			
			//COFINS VALOR BASE - Produto
			cTagAux    := "oDet["+AllTrim(str(I))+"]:_IMPOSTO:_COFINS:"+_TAGCofins+":_VBC:TEXT"
			If Type( cTagAux ) <> "U"
				_COFBAS := VAL(ALLTRIM(&cTagAux))
			EndIf
			
			//COFINS ALIQUOTA - Produto
			cTagAux    := "oDet["+AllTrim(str(I))+"]:_IMPOSTO:_COFINS:"+_TAGCofins+":_PCOFINS:TEXT"
			If Type( cTagAux ) <> "U"
				_COFALQ := VAL(ALLTRIM(&cTagAux))
			EndIf
			
			//COFINS VALOR - Produto
			cTagAux    := "oDet["+AllTrim(str(I))+"]:_IMPOSTO:_COFINS:"+_TAGCofins+":_VCOFINS:TEXT"
			If Type( cTagAux ) <> "U"
				_COFVAL := VAL(ALLTRIM(&cTagAux))
			EndIf
			
			//FR - 11/01/2022 - Petra - incluir campo ICMST
			//****************
			//*** ICM ST *****
			//****************
			
			//caso n„o esteja gravado na ZBT, pega do xml e coloca no array abaixo aDetXml
			//FR - 03/03/2022 - AlteraÁ„o mediante error log reportado pela Teletex (o xml deles n„o tem a tag ICMS, ent„o, checar antes)
			If XmlChildEx(oDet[i]:_IMPOSTO,"_ICMS") <> nil
			
				If XmlChildEx(oDet[i]:_IMPOSTO:_ICMS,"_ICMS60") <> nil
					cTagAux    := "oDet["+AllTrim(str(I))+"]:_IMPOSTO:_ICMS:_ICMS60:_VBCSTRET:TEXT"
					If Type( cTagAux ) <> "U"
						_ICMSTBas := VAL(ALLTRIM(&cTagAux))
					EndIf 
					
					cTagAux    := "oDet["+AllTrim(str(I))+"]:_IMPOSTO:_ICMS:_ICMS60:_PST:TEXT"
					If Type( cTagAux ) <> "U"
						_ICMSTAlq := VAL(ALLTRIM(&cTagAux))
					EndIf
					
					cTagAux    := "oDet["+AllTrim(str(I))+"]:_IMPOSTO:_ICMS:_ICMS60:_VICMSSTRET:TEXT"
					If Type( cTagAux ) <> "U"
						_ICMSTVal := VAL(ALLTRIM(&cTagAux))
					EndIf
					
				ElseIf XmlChildEx(oDet[i]:_IMPOSTO:_ICMS,"_ICMS30") <> nil
				
					cTagAux    := "oDet["+AllTrim(str(I))+"]:_IMPOSTO:_ICMS:_ICMS30:_VBCST:TEXT"
					If Type( cTagAux ) <> "U"
						_ICMSTBas := VAL(ALLTRIM(&cTagAux))
					EndIf 
					
					cTagAux    := "oDet["+AllTrim(str(I))+"]:_IMPOSTO:_ICMS:_ICMS30:_PICMSST:TEXT"
					If Type( cTagAux ) <> "U"
						_ICMSTAlq := VAL(ALLTRIM(&cTagAux))
					EndIf
					
					cTagAux    := "oDet["+AllTrim(str(I))+"]:_IMPOSTO:_ICMS:_ICMS30:_VICMSST:TEXT"
					If Type( cTagAux ) <> "U"
						_ICMSTVal := VAL(ALLTRIM(&cTagAux))
					EndIf
							 
				Endif
			Endif  
			//FR - 11/01/2022 - PETRA - INCLIR CAMPO ICM ST			
			//CST de origem
			aCST := FWGetSX5( "S2" ) //Tabela de CST no SX5

			nTotLen := Len(aCST)

			For x := 1 to nTotLen

				If Empty( cXItemCST )
					cTagAux := "oDet["+AllTrim(str(I))+"]:_IMPOSTO:_ICMS:_ICMS" + Alltrim(aCST[x,3]) + ":_ORIG:TEXT"
					If Type( cTagAux ) <> "U"
						cXItemCST  := &cTagAux

						//***************
						//**** ICMS *****
						//***************
						
						//ICMS CST - Produto
						cTagAux    := "oDet["+AllTrim(str(I))+"]:_IMPOSTO:_ICMS:_ICMS" + Alltrim(aCST[x,3]) + ":_CST:TEXT"
						If Type( cTagAux ) <> "U"
							_ICMCst := ALLTRIM(&cTagAux)
						EndIf

						//ICMS VALOR BASE - Produto
						cTagAux    := "oDet["+AllTrim(str(I))+"]:_IMPOSTO:_ICMS:_ICMS" + Alltrim(aCST[x,3]) + ":_VBC:TEXT"
						If Type( cTagAux ) <> "U"
							_ICMBas := VAL(ALLTRIM(&cTagAux))
						EndIf

						//ICMS ALIQUOTA - Produto
						cTagAux    := "oDet["+AllTrim(str(I))+"]:_IMPOSTO:_ICMS:_ICMS" + Alltrim(aCST[x,3]) + ":_PICMS:TEXT"
						If Type( cTagAux ) <> "U"
							_ICMAlq := VAL(ALLTRIM(&cTagAux))
						EndIf

						//ICMS VALOR - Produto
						cTagAux    := "oDet["+AllTrim(str(I))+"]:_IMPOSTO:_ICMS:_ICMS" + Alltrim(aCST[x,3]) + ":_VICMS:TEXT"
						If Type( cTagAux ) <> "U"
							_ICMVal := VAL(ALLTRIM(&cTagAux))
						EndIf
					Endif
				EndIf	
			Next x

			//
			//==========================================================================//
			//Adiciona os dados colhidos no array de detalhes ao array de Itens do xml: //
			//==========================================================================//

				SA2->(OrdSetFocus(3))		//A2_FILIAL + A2_CGC    //se for uma nota de entrada normal, de um fornecedor
				If SA2->(Dbseek(xFilial("SA2") + cCnpjEmi))
					cTipoFor:= "F"
					cCliFor := SA2->A2_COD
					cLoja   := SA2->A2_LOJA
				Else				
					SA1->(OrdSetFocus(3))		//A2_FILIAL + A2_CGC    //se for uma nota de entrada de devoluÁ„o de venda por exemplo, precisa buscar no cadastro de cliente
					If SA1->(Dbseek(xFilial("SA1") + cCnpjEmi))
						cTipoFor:= "C"
						cCliFor := SA1->A1_COD
						cLoja   := SA1->A1_LOJA
					Endif
				Endif
	
				If !lDesmembra
					Aadd( aItXml, { cXPed,;			//1-N˙mero pedido
								cXItemPed,;		//2-Item Pedido
								cProduto,; 		//3-CÛdigo Produto
								cDescProd,;		//4-DescriÁ„o Produto
								cNF,;	   		//5-N˙mero da NF
								cSeriNF,;  		//6-SÈrie NF
								cXitemCST,;		//7-CST
								_ICMCst,;		//8-ICM CST
								_ICMBas,;		//9-Base ICM
								_ICMAlq,;		//10-Aliq ICM
								_ICMVal,;		//11-Valor ICM
								_PISCST,;		//12-PIS CST
								_PISBAS,;		//13-Base PIS
								_PISALQ,;		//14-Aliq PIS
								_PISVAL,;		//15-Valor PIS
								_COFCST,;     	//16-COFINS CST
								_COFBAS,;     	//17-Base COFINS
								_COFALQ,;     	//18-Aliq COFINS
								_COFVAL,;     	//19-Valor COFINS
								_IPIEnq,;    	//20-Enq IPI
								_IPICst,;    	//21-IPI CST
								_IPIBas,;    	//22-Base IPI
								_IPIAlq,;   	//23-Aliq IPI
								_IPIVal,;   	//24-Valor IPI
								nQuant,;   		//25-Qtde do produto
								nVunit,;   		//26-Valor unit·rio produto
								nTotal,;		//27-Valor total produto
								cTipoFor,;		//28-Tipo emitente do Xml se È fornecedor ou cliente
								cCliFor,;		//29-CÛdigo de cliente/fornecedor do xml
								cLoja,;			//30-CÛdigo da loja do cliente ou fornecedor do xml
								cItem,;			//31-Item do xml 
								cNcm,;			//32-NCM do produto no xml
								cChaveOri,;		//33-Chave da nf original (caso haja) //FR - 15/02/2021 - #6166 - MaxiRubber - NOVO CAMPO, chave da nf original (CTE)	
								cUM,;      		//34-Unidade de medida do produto     //FR - 15/04/2021 
								cNFCI,;			//35-FCI
								nVLDESC,;		//36-VLDESC
								cLOTE,;			//37-Num LOTE
								dValLote,;		//38-Validade Lote
								cAnoFab,;		//39-Ano de fabricaÁ„o (com dois digitos)
								_ICMSTBas,;		//40-Base ICM ST
								_ICMSTAlq,;		//41-Aliq ICM ST
								_ICMSTVal,;		//42-Valor ICM ST							
								cCFOP;			//43-CFOP
								} )

				Else 
					If Len(oDet[i]:_PROD:_RASTRO) > 0
						//For nl := 1 to Len(oDet[i]:_PROD:_RASTRO) > 0
						nl := 1
						While nl <= Len(oDet[i]:_PROD:_RASTRO)
							//quantidade do produto										//FR - 10/03/2020
							cTagAux := "oDet["+AllTrim(str(I))+"]:_PROD:_RASTRO[" + Alltrim(str(nl))+ "]:_QLOTE:TEXT"  
							If type( cTagAux ) <> "U"
								nQuant := VAL(&cTagAux)		
							Endif
							
							nTotal := nQuant * nVunit

							//numero lote
							cTagAux := "oDet["+AllTrim(str(I))+"]:_PROD:_RASTRO[" + Alltrim(str(nl))+ "]:_NLOTE:TEXT"  
							If type( cTagAux ) <> "U"
								cLOTE := (&cTagAux)		
							Endif

							//Validade lote
							cTagAux := "oDet["+AllTrim(str(I))+"]:_PROD:_RASTRO[" + Alltrim(str(nl))+ "]:_DVAL:TEXT"  
							cValLote  := &cTagAux 	//vem assim: "2024-06-30" -> transformar para 30/06/2024
							dValLote  := CtoD( Substr(cValLote,9,2) + "/" + Substr(cValLote,6,2) + "/" + Substr(cValLote,1,4) ) 

							//ano fabricaÁ„o do lote
							cTagAux   := "oDet["+AllTrim(str(I))+"]:_PROD:_RASTRO[" + Alltrim(str(nl))+ "]:_DFAB:TEXT"  
							cAnoFab   := &cTagAux 	//vem assim: "2022-06-30" -> transformar para 22 o ano tem 2 dÌgitos apenas	

							//cria o array por item de lote j· com todas as vari·veis povoadas
							Aadd( aItXml, { cXPed,;			//1-N˙mero pedido
								cXItemPed,;		//2-Item Pedido
								cProduto,; 		//3-CÛdigo Produto
								cDescProd,;		//4-DescriÁ„o Produto
								cNF,;	   		//5-N˙mero da NF
								cSeriNF,;  		//6-SÈrie NF
								cXitemCST,;		//7-CST
								_ICMCst,;		//8-ICM CST
								_ICMBas,;		//9-Base ICM
								_ICMAlq,;		//10-Aliq ICM
								_ICMVal,;		//11-Valor ICM
								_PISCST,;		//12-PIS CST
								_PISBAS,;		//13-Base PIS
								_PISALQ,;		//14-Aliq PIS
								_PISVAL,;		//15-Valor PIS
								_COFCST,;     	//16-COFINS CST
								_COFBAS,;     	//17-Base COFINS
								_COFALQ,;     	//18-Aliq COFINS
								_COFVAL,;     	//19-Valor COFINS
								_IPIEnq,;    	//20-Enq IPI
								_IPICst,;    	//21-IPI CST
								_IPIBas,;    	//22-Base IPI
								_IPIAlq,;   	//23-Aliq IPI
								_IPIVal,;   	//24-Valor IPI
								nQuant,;   		//25-Qtde do produto
								nVunit,;   		//26-Valor unit·rio produto
								nTotal,;		//27-Valor total produto
								cTipoFor,;		//28-Tipo emitente do Xml se È fornecedor ou cliente
								cCliFor,;		//29-CÛdigo de cliente/fornecedor do xml
								cLoja,;			//30-CÛdigo da loja do cliente ou fornecedor do xml
								cItem,;			//31-Item do xml 
								cNcm,;			//32-NCM do produto no xml
								cChaveOri,;		//33-Chave da nf original (caso haja) //FR - 15/02/2021 - #6166 - MaxiRubber - NOVO CAMPO, chave da nf original (CTE)	
								cUM,;      		//34-Unidade de medida do produto     //FR - 15/04/2021 
								cNFCI,;			//35-FCI
								nVLDESC,;		//36-VLDESC
								cLOTE,;			//37-Num LOTE
								dValLote,;		//38-Validade Lote
								cAnoFab,;		//39-Ano de fabricaÁ„o (com dois digitos)
								_ICMSTBas,;		//40-Base ICM ST
								_ICMSTAlq,;		//41-Aliq ICM ST
								_ICMSTVal,;		//42-Valor ICM ST							
								cCFOP;			//43-CFOP
								} )				
						//Next nl
							nl++
						Enddo

					Endif	//len do Rastro			 
				Endif //lDesmembra
			Next i

        Elseif cModelo == "57" //Quando for CTE

        	nNFORI   := ""
        	cSROri   := ""
			cChaveOri:= ""		//FR - 15/02/2021 - #6166 - MaxiRubber - NOVO CAMPO, chave da nf original (CTE)

			//FR - 27/09/2022 - CIMENTOS ITAMB… GRAVA«√O DE IMPOSTOS PARA CTE
			nBASCAL  := 0		//9-Base ICM
			nICMALIQ := 0		//10-Aliq ICM
			nICMVAL  := 0		//11-Valor ICM
			//FR - 27/09/2022 - CIMENTOS ITAMB… GRAVA«√O DE IMPOSTOS PARA CTE

			//------------------------------------------------------------//                                                           
			//FR - 16/05/2023 - CHAMADO ELECON #14880
			//     Criar campo CFOP no item do XML
			//------------------------------------------------------------//
			cCFOP    := ""

			//Tratamento para CT-e			
			cTagAux := "oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_CFOP:TEXT"

			if type( cTagAux ) <> "U"
				cCFOP := AllTrim(oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_CFOP:TEXT)
			endif				
			//FR - 16/05/2023 - CHAMADO ELECON
			//--------------------------------------------------------------//

        	If Type( "oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE" ) != "U"			//CTE Normal

        		oDet := oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE				
				oDet := iif( ValType(oDet) == "O", {oDet}, oDet )			
			
			Else  //If Type("oDet") == "U"

				oDet := {}

			EndIf

			//FR - 27/09/2022 - CIMENTOS ITAMB… GRAVA«√O DE IMPOSTOS PARA CTE
			cTagAux := "oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_VBC:TEXT"
			If type( cTagAux ) <> "U"
				nBASCAL := val(&cTagAux) //BASE C›LCULO ICM
			Endif
			
			cTagAux := "oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_VICMS:TEXT"
			If type( cTagAux ) <> "U"
				nICMVAL := val(&cTagAux) //VALOR ICM
			Endif

			cTagAux := "oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS00:_PICMS:TEXT"
			If type( cTagAux ) <> "U"
				nICMALIQ := val(&cTagAux) //ALIQ ICM
			Endif
			//FR - 27/09/2022 - CIMENTOS ITAMB… GRAVA«√O DE IMPOSTOS PARA CTE			
			
			If Len(oDet) > 0		//FR - 15/02/2021 - #6166 - MaxiRubber - Aqui somente haver· dados em caso de CTE normal, complemento n„o
				For fr := 1 to Len(oDet) 

					//aqui lÍ o array de detalhe do Cte, onde guarda as notas que compıem o Cte
					//cada nota lida, vira um item na ZBT
					//GRAVAR:
					//ZBT_NOTA 		//pesquisar na SF2 se for nota de saÌda e trazer o valor, se for nota de entrada, pegar do prÛprio xml (?)
					//ZBT_SERIE
					//ZBT_CLIFOR
					//ZBT_LOJA
					//ZBT_TIPOFOR - gravar com C-Cliente ou F-Fornecedor
					//ZBT_ITEM    - item do xml
					//ZBT_CHAVEO  - Chave da nf original (caso haja) //FR - 15/02/2021 - #6166 - MaxiRubber - NOVO CAMPO, chave da nf original (CTE)	
										
					cTagAux    := "oDet["+AllTrim(str(fr))+"]:_CHAVE:TEXT"    //n˙mero da nf //cTagAux    := "oDet["+AllTrim(str(fr))+"]:_INFNFE:_CHAVE:TEXT"    //n˙mero da nf
					
					If type( cTagAux ) <> "U"

						cNFOri    := UPPER( Substr( &cTagAux,26,9) )
						cSROri    := UPPER( Substr( &cTagAux,23,3) )
						cChaveOri := &cTagAux		//FR - 15/02/2021 - #6166 - MaxiRubber
					
					Endif
					
					If !Empty(cNFOri) .AND. !Empty(cSROri)

						//PESQUISAR O CNPJ DO EMITENTE DA NOTA ORIGINAL:
						SF2->(OrdSetFocus(1))  //F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA
						If SF2->(Dbseek(xFilial("SF2") + cNFOri + cSROri ))

							nValNFOri := SF2->F2_VALBRUT
							cCliFor   := SF2->F2_CLIENTE
							cLoja     := SF2->F2_LOJA

							If SF2->F2_TIPO = "N"
								cTipoFor := "C" //Cliente
							Else
								cTipoFor := "F"
							Endif

						Endif
					
					//cTipoFor := "" //Gravar C-Cliente ou F-Fornecedor

					
					Aadd( aItXml, { "",;			//1-N˙mero pedido
									"",;	   		//2-Item Pedido
									"FRETE",; 		//3-CÛdigo Produto
									"FRETE",;		//4-DescriÁ„o Produto
									cNFOri,;	   	//5-N˙mero da NF
									cSROri,;  		//6-SÈrie NF
									"",;	   		//7-CST
									"",;			//8-ICM CST
									nBASCAL,;		//9-Base ICM
									nICMALIQ,;		//10-Aliq ICM
									nICMVAL,;		//11-Valor ICM
									"",;   			//12-PIS CST
									0,;	   			//13-Base PIS
									0,;	   			//14-Aliq PIS
									0,;	   			//15-Valor PIS
									"",;        	//16-COFINS CST
									0,;        		//17-Base COFINS
									0,;        		//18-Aliq COFINS
									0,;        		//19-Valor COFINS
									"",;    		//20-Enq IPI
									"",;    		//21-IPI CST
									0,;    			//22-Base IPI
									0,;   			//23-Aliq IPI
									0,;    	   		//24-Valor IPI
									1,;   	 		//25-Qtde do produto
									nValNFOri,; 	//26-Valor unit·rio produto
									nValNFOri,;		//27-Valor total produto
									cTipoFor,;		//28-Tipo emitente do Xml se È fornecedor ou cliente
									cCliFor,;		//29-CÛdigo de cliente/fornecedor do xml
									cLoja,;         //30-CÛdigo da loja do cliente ou fornecedor do xml
									cItem,;			//31-Item do xml (no caso do CTe vir· vazio, ent„o no momento de gravar na ZBT, pego pela posiÁ„o de linha do array)
									cNcm,;			//32-NCM do produto no xml
									cChaveOri,;		//33-Chave da nf original (caso haja) //FR - 15/02/2021 - #6166 - MaxiRubber - NOVO CAMPO, chave da nf original (CTE)	
									cUM,;      		//34-Unidade de medida do produto     //FR - 15/04/2021
									cNFCI,;			//35-FCI
									nVLDESC,;		//36-VLDESC	
									cLOTE,;			//37-LOTE
									dValLote,;		//38-Validade Lote
									cAnoFab,;		//39-Ano de fabricaÁ„o (com dois digitos)
									_ICMSTBas,;		//40-Base ICM ST
									_ICMSTAlq,;		//41-Aliq ICM ST
									_ICMSTVal,;		//42-Valor ICM ST
									cCFOP;			//43-CFOP							
									} )		
					EndIf	//if !Empty(cNFOri) .AND. !Empty(cSROri)

				Next
			
			//FR - 15/02/2021 - #6166 - MaxiRubber - CTE Complemento
			Else		//se Len(oDet) == 0, 
						//È nota de complemento e n„o h· itens de cte, pegarei a informaÁ„o de documento original de outra tag
				
				//FR - 15/02/2021 - #6166 - MaxiRubber				
				If Type("oXml:_CTEPROC:_CTE:_INFCTE:_INFCTECOMP:_CHCTE:TEXT") <> "U"	//tag que contem o n˙mero da nf origem, em caso de cte de complemento				
					cTagAux := "oXml:_CTEPROC:_CTE:_INFCTE:_INFCTECOMP:_CHCTE:TEXT" 
					cNFOri    := UPPER( Substr( &cTagAux,26,9) )
					cSROri    := UPPER( Substr( &cTagAux,23,3) )
					cChaveOri := &cTagAux	
				Endif

				//FR - 15/02/2021 - MaxiRubber - se n„o encontrar as informaÁıes na tag acima (pode ser que a tag n„o exista), ent„o procura na tag abaixo:
				//neste caso, a nota original tem a mesma numeraÁ„o do CTe.
				If Empty(cNFOri) .OR. Empty(cChaveOri)
					If Type("oXml:_CTEPROC:_PROTCTE:_INFPROT:_CHCTE:TEXT") <> "U"					
						cTagAux   := "oXml:_CTEPROC:_PROTCTE:_INFPROT:_CHCTE:TEXT"		//FR - 17/02/2021 - #6210 - Cimentos ItambÈ
						cNFOri    := UPPER( Substr( &cTagAux,26,9) )
						cSROri    := UPPER( Substr( &cTagAux,23,3) )
						cChaveOri := &cTagAux	//FR - 15/02/2021 - #6166 - MaxiRubber
					EndIf
				Endif

				//------------------------------------------------------------//                                                           
				//FR - 16/05/2023 - CHAMADO ELECON #14880
				//     Criar campo CFOP no item do XML
				//------------------------------------------------------------//
				/*  //VER DEPOIS ESTE CASO COMO GRAVAR
				cCFOP    := ""

				//Tratamento para CT-e			
				cTagAux := "oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_CFOP:TEXT"

				if type( cTagAux ) <> "U"
					cCFOP := AllTrim(oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_CFOP:TEXT)
				endif
				*/				
				//FR - 16/05/2023 - CHAMADO ELECON
				//--------------------------------------------------------------//

				//gera array de retorno para cte complemento:
				If !Empty(cNFOri) .AND. !Empty(cSROri)

					//PESQUISAR O CNPJ DO EMITENTE DA NOTA ORIGINAL:
					SF2->(OrdSetFocus(1))  //F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA
					If SF2->(Dbseek(xFilial("SF2") + cNFOri + cSROri ))

						nValNFOri := SF2->F2_VALBRUT
						cCliFor   := SF2->F2_CLIENTE
						cLoja     := SF2->F2_LOJA

						If SF2->F2_TIPO = "N"
							cTipoFor := "C" //Cliente
						Else
							cTipoFor := "F"
						Endif

					Endif
					
				//cTipoFor := "" //Gravar C-Cliente ou F-Fornecedor

					Aadd( aItXml, { "",;			//1-N˙mero pedido
								"",;	   		//2-Item Pedido
								"FRETE",; 		//3-CÛdigo Produto
								"FRETE",;		//4-DescriÁ„o Produto
								cNFOri,;	   	//5-N˙mero da NF
								cSROri,;  		//6-SÈrie NF
								"",;	   		//7-CST
								"",;			//8-ICM CST
								0,;				//9-Base ICM
								0,;	   			//10-Aliq ICM
								0,;	   			//11-Valor ICM
								"",;   			//12-PIS CST
								0,;	   			//13-Base PIS
								0,;	   			//14-Aliq PIS
								0,;	   			//15-Valor PIS
								"",;        	//16-COFINS CST
								0,;        		//17-Base COFINS
								0,;        		//18-Aliq COFINS
								0,;        		//19-Valor COFINS
								"",;    		//20-Enq IPI
								"",;    		//21-IPI CST
								0,;    			//22-Base IPI
								0,;   			//23-Aliq IPI
								0,;    	   		//24-Valor IPI
								1,;   	 		//25-Qtde do produto
								nValNFOri,; 	//26-Valor unit·rio produto
								nValNFOri,;		//27-Valor total produto
								cTipoFor,;		//28-Tipo emitente do Xml se È fornecedor ou cliente
								cCliFor,;		//29-CÛdigo de cliente/fornecedor do xml
								cLoja,;         //30-CÛdigo da loja do cliente ou fornecedor do xml
								cItem,;			//31-Item do xml (no caso do CTe vir· vazio, ent„o no momento de gravar na ZBT, pego pela posiÁ„o de linha do array)
								cNcm,;			//32-NCM do produto no xml
								cChaveOri,;		//33-Chave da nf original (caso haja) //FR - 15/02/2021 - #6166 - MaxiRubber - NOVO CAMPO, chave da nf original (CTE)	
								cUM,;      		//34-Unidade de medida do produto   //FR - 15/04/2021 
								cNFCI,;			//35-FCI
								nVLDESC,;		//36-VLDESC
								cLOTE,;			//37-LOTE
								dValLote,;		//38-Validade Lote
								cAnoFab,;		//39-Ano de fabricaÁ„o (com dois digitos)
								_ICMSTBas,;		//40-Base ICM ST
								_ICMSTAlq,;		//41-Aliq ICM ST
								_ICMSTVal,;		//42-Valor ICM ST
								cCFOP;			//43-CFOP
								} )		
				EndIf	//if !Empty(cNFOri) .AND. !Empty(cSROri)
				//fim array retorno

			Endif //se len(oDet) > 0

        Elseif cModelo == "RP"		//FR - 27/11/2020 - qdo for NF ServiÁo
        
        	If cChaveXML <> Nil
        		cNF      := ""
        		cSeriNF  := "" 
        		cItem    := "0001"
        		nVunit   := 0
        		nTotal   := 0
        		cTipoFor := ""
	        	cCliFor  := "" 
	        	cLoja    := ""	        	
	        	cNcm     := ""
	        	
        		(xZBZ)->(OrdSetfocus(3))
        		(xZBZ)->(Dbseek(cChaveXML))
        		
        		SA2->(OrdSetFocus(3))		//A2_FILIAL + A2_CGC    //se for uma nota de entrada normal, de um fornecedor
				If SA2->(Dbseek(xFilial("SA2") + cCnpjEmi))
					cTipoFor:= "F"
					cCliFor := SA2->A2_COD
					cLoja   := SA2->A2_LOJA
				Else				
					SA1->(OrdSetFocus(3))		//A2_FILIAL + A2_CGC    //se for uma nota de entrada de devoluÁ„o de venda por exemplo, precisa buscar no cadastro de cliente
					If SA1->(Dbseek(xFilial("SA1") + cCnpjEmi))
						cTipoFor:= "C"
						cCliFor := SA1->A1_COD
						cLoja   := SA1->A1_LOJA
					Endif
				Endif
        		 
    			cNF      := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA")))
        		cSeriNF  := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE")))
	        	nVunit   := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"VLBRUT")))
	        	nTotal   := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"VLBRUT")))
	        	
        	
        		Aadd( aItXml, { "",;				//1-N˙mero pedido
								"",;	   		//2-Item Pedido
								"SERVICO",; 	//3-CÛdigo Produto
								"SERVICO",;		//4-DescriÁ„o Produto
								cNF,;	   		//5-N˙mero da NF
								cSeriNF,;  		//6-SÈrie NF
								"",;	   		//7-CST
								"",;			//8-ICM CST
								0,;				//9-Base ICM
								0,;	   			//10-Aliq ICM
								0,;	   			//11-Valor ICM
								"",;   			//12-PIS CST
								0,;	   			//13-Base PIS
								0,;	   			//14-Aliq PIS
								0,;	   			//15-Valor PIS
								"",;        	//16-COFINS CST
								0,;        		//17-Base COFINS
								0,;        		//18-Aliq COFINS
								0,;        		//19-Valor COFINS
								"",;    		//20-Enq IPI
								"",;    		//21-IPI CST
								0,;    			//22-Base IPI
								0,;   			//23-Aliq IPI
								0,;    	   		//24-Valor IPI
								1,;   	 		//25-Qtde do produto
								nVunit,;   		//26-Valor unit·rio produto
								nTotal,;		//27-Valor total produto
								cTipoFor,;		//28-Tipo emitente do Xml se È fornecedor ou cliente
								cCliFor,;		//29-CÛdigo de cliente/fornecedor do xml
								cLoja,;         //30-CÛdigo da loja do cliente ou fornecedor do xml
								cItem,;			//31-Item do xml (no caso do CTe vir· vazio, ent„o no momento de gravar na ZBT, pego pela posiÁ„o de linha do array)
								cNcm,;			//32-NCM do produto no xml
								cChaveOri,;		//33-Chave da nf original (caso haja) //FR - 15/02/2021 - #6166 - MaxiRubber - NOVO CAMPO, chave da nf original (CTE)	
								cUM,;      		//34-Unidade de medida do produto	  //FR - 15/04/2021
								cNFCI,;			//35-FCI
								nVLDESC,;		//36-VLDESC
								cLOTE,;			//37-LOTE
								dValLote,;		//38-Validade Lote
								cAnoFab,;		//39-Ano de fabricaÁ„o (com dois digitos)
								_ICMSTBas,;		//40-Base ICM ST
								_ICMSTAlq,;		//41-Aliq ICM ST
								_ICMSTVal,;		//42-Valor ICM ST
								cCFOP;			//43-CFOP
								} )	
			Endif	
        Endif //FR - 16/03/2020 - este bloco sÛ ser· executado caso o modelo seja NFE
	
	endif

Return(aItXml)


//Rotina para gravar os itens do importa xml
**********************************************************************
User Function fGravaZBT(cXml,cModelo,cChaveXml,cNF,cSeriNF,cCnpjEmi,cDocDest)
**********************************************************************
Local aItXML   := {}
Local cModel   := ""
Local cPedido  := ""
Local cItemPc  := ""
Local cCodProd := ""
Local cDescProd:= ""
Local cZBTNF   := ""
Local cZBTSR   := ""
Local fr       := 0
Local aArea    := GetArea()
Local nCSTOrig := 0
Local lInclui  := .T.
Local cChaveOri:= ""		//FR - 15/02/2021 - #6166 - MaxiRubber - NOVO CAMPO, chave da nf original (CTE)	
Local cCFOP    := ""		//FR - 16/05/2023 - #14880 - ELECON - CRIAR CAMPO ZBT_CFOP

Private xZBZ  	  := GetNewPar("XM_TABXML","ZBZ")
Private xZBZ_ 	  := iif(Substr(xZBZ,1,1)=="S", Substr(xZBZ,2,2), Substr(xZBZ,1,3)) + "_"
Private xZB5  	  := GetNewPar("XM_TABAMAR","ZB5")
Private xZB5_ 	  := iif(Substr(xZB5,1,1)=="S", Substr(xZB5,2,2), Substr(xZB5,1,3)) + "_"
Private xZBS  	  := GetNewPar("XM_TABSINC","ZBS")
Private xZBS_ 	  := iif(Substr(xZBS,1,1)=="S", Substr(xZBS,2,2), Substr(xZBS,1,3)) + "_"
Private xZBE      := GetNewPar("XM_TABEVEN","ZBE")
Private xZBE_     := iif(Substr(xZBE,1,1)=="S", Substr(xZBE,2,2), Substr(xZBE,1,3)) + "_"
Private xZBT      := GetNewPar("XM_TABITEM","ZBT") 
Private xZBT_ 	  := iif(Substr(xZBT,1,1)=="S", Substr(xZBT,2,2), Substr(xZBT,1,3)) + "_"
Private xZBA  	  := GetNewPar("XM_TABAMA2","ZBA")
Private xZBA_ 	  := iif(Substr(xZBA,1,1)=="S", Substr(xZBA,2,2), Substr(xZBA,1,3)) + "_"
Private xZBC      := GetNewPar("XM_TABCAC","ZBC")
Private xZBC_     := iif(Substr(xZBC,1,1)=="S", Substr(xZBC,2,2), Substr(xZBC,1,3)) + "_"
Private xZBO      := GetNewPar("XM_TABOCOR","ZBO"), xRetSEF := ""
Private xZBO_     := iif(Substr(xZBO,1,1)=="S", Substr(xZBO,2,2), Substr(xZBO,1,3)) + "_"
Private xZBI      := GetNewPar("XM_TABIEXT","ZBI")
Private xZBI_     := iif(Substr(xZBI,1,1)=="S", Substr(xZBI,2,2), Substr(xZBI,1,3)) + "_"

DbSelectArea(xZBI)
Aadd(aArea, (xZBI)->(GetArea()) )

DbSelectArea(xZBO)
Aadd(aArea, (xZBO)->(GetArea()) )

DbSelectArea(xZBZ)
Aadd(aArea, (xZBZ)->(GetArea()) )

DbSelectArea(xZBT)
Aadd(aArea, (xZBT)->(GetArea()) )

DbSelectArea(xZB5)
Aadd(aArea, (xZB5)->(GetArea()) )

DbSelectArea(xZBE)
Aadd(aArea, (xZBE)->(GetArea()) )

DbSelectArea(xZBS)
Aadd(aArea, (xZBS)->(GetArea()) ) 
 
DbSelectArea(xZBA)
Aadd(aArea, (xZBA)->(GetArea()) ) 

DbSelectArea(xZBC)
Aadd(aArea, (xZBC)->(GetArea()) )
cModel := cModelo 		//Substr(cNewKey,21,2)

If cModel $ '55/65/57/67/RP'  //por eqto os itens est„o apenas nos modelos 55(Nfe) e 57 (Cte)

	aItXML := U_fIMPXMLFOR(cXml,cModel,cCnpjEmi,cChaveXml)  	//FR - 27/11/2020

Endif	

/*
1-Pedido       2-Item     3-Produto    4-DescriÁ„o     5-nf        6-sÈrie
Aadd( aItXml, { cXPed     , cXItemPed, cProduto,	cDescProd,   cTagDocXMl, cTagSerXml } )
*/
If aItXML <> NIL

	If Len(aItXML) > 0

		DbSelectArea( xZBT )
		(xZBT)->( dbSetOrder(2) )		//FR - 27/11/19 - ZBT_CHAVE (Ìndice sem filial)
		If !(xZBT)->( dbSeek( cChaveXml ) )
			lInclui	:= .T.
		Else
			lInclui := .F.
		EndIf

		//cSerXMl := AllTrim( Str( Val( (xZBS)->(FieldGet(FieldPos(xZBS_+"SERIE"))) ) ) )
		nTotLen := Len(aItXML)

		For fr := 1 to nTotLen

			lAchou	 := .F.
			cPedido  := aItXml[fr,1]
			cItemPc  := aItXml[fr,2]
			cCodProd := aItXml[fr,3]
			cDescProd:= aItXml[fr,4]
			
			//----------------------------------------------------------------------------------//
			//FR - 13/02/2023 - TRATATIVA PARA CAPTAR A CHAVE DA NF ORIGEM DO CABE«ALHO DO XML
			//cZBTNF   := iif(cModelo $ "55/65" , cNF , aItXml[fr,5])
			//cZBTSR   := aItXml[fr,6]			
			//----------------------------------------------------------------------------------//
			
			nCSTOrig := Val( aItXml[fr,7])
			//ICMS
			cICMCst  := aItXml[fr,8]
			nICMBas  := aItXml[fr,9]
			nICMAlq  := aItXml[fr,10]
			nICMVal  := aItXml[fr,11]
			//PIS
			cPISCST  := aItXml[fr,12]
			cPISBAS  := aItXml[fr,13]
			nPISALQ  := aItXml[fr,14]
			nPISVAL  := aItXml[fr,15]
			//COFINS
			cCOFCST  := aItXml[fr,16]
			cCOFBAS  := aItXml[fr,17]
			nCOFALQ  := aItXml[fr,18]
			nCOFVAL  := aItXml[fr,19]
			//IPI
			cIPIEnq  := aItXml[fr,20]
			cIPICst  := aItXml[fr,21]
			nIPIBas  := aItXml[fr,22]
			nIPIAlq  := aItXml[fr,23]
			nIPIVal  := aItXml[fr,24]
			//FR - Melhoria no Gest„o XML - Novos campos para serem impressos no relatÛrio HFXMLR16 
			nQuant   := aItXml[fr,25]	//FR - 10/03/2020
			nVunit   := aItXml[fr,26]	//FR - 10/03/2020
			nTotal   := aItXml[fr,27]	//FR - 10/03/2020
			//FR - Projeto Politec - Novos campos para armazenar cÛdigo de cliente ou fornecedor das notas que compıem o Cte 
			cTipoFor := aItXml[fr,28]		//FR - 17/03/2020 - PROJETO POLITEC, gravar n˙meros das notas que compoem o Cte
			cCliFor  := aItXml[fr,29]		//FR - 17/03/2020 - PROJETO POLITEC, gravar n˙meros das notas que compoem o Cte
			cLoja    := aItXml[fr,30]		//FR - 17/03/2020 - PROJETO POLITEC, gravar n˙meros das notas que compoem o Cte
			cItem    := aItXml[fr,31]
			cNCM     := aItxML[fr,32]		//FR - 15/04/2021
						
			cChaveOri:= aItXml[fr,33]		//FR - 15/02/2021 - #6166 - MaxiRubber - NOVO CAMPO, chave da nf original (CTE)	  
			//----------------------------------------------------------------------------------//
			//FR - 13/02/2023 - TRATATIVA PARA CAPTAR A CHAVE DA NF ORIGEM DO CABE«ALHO DO XML
			//cZBTNF   := iif(cModelo $ "55/65" , cNF , aItXml[fr,5])
			//cZBTSR   := aItXml[fr,6]
			
			If Empty(cChaveOri)
				cZBTNF := iif(cModelo $ "55/65" , cNF , aItXml[fr,5])
				cZBTSR   := aItXml[fr,6]
			Else 
				//_NfOri   := Substr(cChvReg,26,9)
				//_SrOri   := Substr(cChvReg,23,3)  //esta com 3 zeros	
				cZBTNF := Substr(cChaveOri,26,9)
				cZBTSR := Substr(cChaveOri,23,3)  //esta com 3 zeros	
			Endif 
			//FR - 13/02/2023 - TRATATIVA PARA CAPTAR A CHAVE DA NF ORIGEM DO CABE«ALHO DO XML
			//----------------------------------------------------------------------------------//
			cUM      := aItXml[fr,34]		//FR - 15/04/2021
			cNFCI    := aItXml[fr,35]		//FR - 28/04/2021
			nVLDESC  := aItXml[fr,36]		//FR - 28/04/2021
			cLOTE    := aItXml[fr,37]		//FR - 28/04/2021
			dVLOTE   := aItXml[fr,38]		//FR - 28/04/2021
			cANOFAB  := aItXml[fr,39]		//FR - 28/04/2021
			
			//FR - 11/01/2022 - Petra - incluir campo ICMST
			nICMSTBas:= aItXml[fr,40]		//40-Base ICM
			nICMSTAlq:= aItXml[fr,41]		//41-Aliq ICM
			nICMSTVal:= aItXml[fr,42]		//42-Valor ICM
			//FR - 11/01/2022 - Petra - incluir campo ICMST	

			//--------------------------------------------------------------------------------//
			//FR - 16/05/2023 - #14880 - ELECON - TRATATIVA PARA GRAVAR CFOP NO ITEM ZBT_CFOP
			//--------------------------------------------------------------------------------//
			cCFOP    := aItXml[fr,43]		//43-CFOP DO ITEM

			If Empty(cItem)
				cItem    := StrZero(fr,4)	//FR - 19/03/2020 - itemizador para os registros da ZBT
			Endif
	
			If !lInclui

				DbSelectArea( xZBT )
				(xZBT)->(dbSetOrder(2))		//FR - 27/11/19 - ZBT_CHAVE (Ìndice sem filial)
				(xZBT)->(dbSeek(cChaveXml))

				While (xZBT)->(!Eof()) .AND. AllTrim(&(xZBT_+"CHAVE")) == AllTrim(cChaveXml)

					If &(xZBT_+"ITEM") == cItem
						lAchou := .T.
						Exit
					EndIf

					(xZBT)->(dbSkip())

				EndDo
			
				If !lAchou
					lInclui := .T.
				EndIf
			EndIf

			//----------------------------------------------------------------------------//
			//KIM P√ES - CHAMADO #000014229 - GRAVAR O C”DIGO DO PRODUTO INTERNO NO 
			//CAMPO ZBT_DEPARA, mediante Busca de amarraÁ„o (caso haja)
			//---------------------------------------------------------------------------//
            //pelo cÛdigo do produto fornecedor, captura o cÛdigo produto interno SB1:
            // Aadd(aRet, TRB->PRODFORNEC)
            //Aadd(aRet, TRB->PRODINTERNO)
            //--------------------------------------------------------------------------//
            aInfo        := {}   
			cProdInterno := ""
			cClieFor     := Posicione("SA2",3,xFilial("SA2")+ cCnpjEmi ,"A2_COD")
			cLoja        := Posicione("SA2",3,xFilial("SA2")+ cCnpjEmi ,"A2_LOJA")
			
			If !Empty(cCliefor) .and. !Empty(cLoja)
				
				aInfo := U_FGETZB5( cCodProd , cClieFor, cLoja, "F"  ) 	//aqui cCodProd È o cÛdigo do produto do fornecedor
				
				If Len(aInfo) > 0
					//cProdFor    := aInfo[1]	//produto do fornecedor
					cProdInterno:= Alltrim(aInfo[2])
				Endif 

				If Empty(cProdInterno)  //se n„o encontrou nada na ZB5, tenta na SA5
					
					aInfo := U_FGETSA5( cCodProd , cClieFor, cLoja , "F"  ) //aqui cCodProd È o cÛdigo do produto do fornecedor
					If Len(aInfo) > 0
						//cProdFor    := aInfo[1]	//produto do fornecedor
						cProdInterno:= Alltrim(aInfo[2])
					Endif 
				Endif 
			Endif          

			Reclock(xZBT,lInclui)

				(xZBT)->(FieldPut(FieldPos(xZBT_+"CHAVE")  , cChaveXml	))
				(xZBT)->(FieldPut(FieldPos(xZBT_+"FILIAL") , cFilAnt 	))
				(xZBT)->(FieldPut(FieldPos(xZBT_+"PEDIDO") , cPedido	))
				(xZBT)->(FieldPut(FieldPos(xZBT_+"ITEM")   , cItem  	))
				(xZBT)->(FieldPut(FieldPos(xZBT_+"ITEMPC") , cItemPc	))
				(xZBT)->(FieldPut(FieldPos(xZBT_+"PRODUT") , cCodProd	))

				//FR - 30/12/2022 - KIM P√ES
				//If !Empty(cProdInterno)				
				If cProdInterno == Nil 
					cProdInterno := ""
				Endif 
				(xZBT)->(FieldPut(FieldPos(xZBT_+"DEPARA") , Alltrim(cProdInterno) ))		//FR - 30/12/2022 - KIM P√ES					
				
				//FR - 30/12/2022 - KIM P√ES

				(xZBT)->(FieldPut(FieldPos(xZBT_+"DESCRI") , cDescProd	))
				(xZBT)->(FieldPut(FieldPos(xZBT_+"QUANT")  , nQuant		))  //FR - 10/03/2020
				(xZBT)->(FieldPut(FieldPos(xZBT_+"VUNIT")  , nVunit 	))	//FR - 10/03/2020 
				(xZBT)->(FieldPut(FieldPos(xZBT_+"TOTAL")  , nTotal 	))	//FR - 10/03/2020
				(xZBT)->(FieldPut(FieldPos(xZBT_+"NOTA")   , cZBTNF    	))
				(xZBT)->(FieldPut(FieldPos(xZBT_+"SERIE")  , cZBTSR  	))
				//(xZBT)->(FieldPut(FieldPos(xZBT_+"DEPARA") , Space(20)  ))  //o problema estava aqui, zerava o que eu havia gravado :-(
				(xZBT)->(FieldPut(FieldPos(xZBT_+"CSTORI") , nCSTOrig   ))
				//ICMS
				(xZBT)->(FieldPut(FieldPos(xZBT_+"ICMCST") , cICMCst   	))
				(xZBT)->(FieldPut(FieldPos(xZBT_+"ICMBAS") , nICMBas	))
				(xZBT)->(FieldPut(FieldPos(xZBT_+"ICMALQ") , nICMAlq    ))
				(xZBT)->(FieldPut(FieldPos(xZBT_+"ICMVAL") , nICMVal    ))
				//IPI
				(xZBT)->(FieldPut(FieldPos(xZBT_+"IPIENQ") , cIPIEnq	))
				(xZBT)->(FieldPut(FieldPos(xZBT_+"IPICST") , cIPICst   	))
				(xZBT)->(FieldPut(FieldPos(xZBT_+"IPIBAS") , nIPIBas	))
				(xZBT)->(FieldPut(FieldPos(xZBT_+"IPIALQ") , nIPIAlq    ))
				(xZBT)->(FieldPut(FieldPos(xZBT_+"IPIVAL") , nIPIVal    ))
				//PIS
				(xZBT)->(FieldPut(FieldPos(xZBT_+"PISCST") , cPISCST	))
				(xZBT)->(FieldPut(FieldPos(xZBT_+"PISBAS") , cPISBAS   	))
				(xZBT)->(FieldPut(FieldPos(xZBT_+"PISALQ") , nPISALQ	))
				(xZBT)->(FieldPut(FieldPos(xZBT_+"PISVAL") , nPISVAL    ))
				//COFINS
				(xZBT)->(FieldPut(FieldPos(xZBT_+"COFCST") , cCOFCST	))
				(xZBT)->(FieldPut(FieldPos(xZBT_+"COFBAS") , cCOFBAS   	))
				(xZBT)->(FieldPut(FieldPos(xZBT_+"COFALQ") , nCOFALQ	))
				(xZBT)->(FieldPut(FieldPos(xZBT_+"COFVAL") , nCOFVAL    ))
				//CÛdigo cliente ou fornecedor xml				
				(xZBT)->(FieldPut(FieldPos(xZBT_+"CLIFOR") , cCliFor    ))  //FR - 17/03/2020 - PROJETO POLITEC, gravar n˙meros das notas que compoem o Cte
				(xZBT)->(FieldPut(FieldPos(xZBT_+"LOJA")   , cLoja      )) 	//FR - 17/03/2020 - PROJETO POLITEC, gravar n˙meros das notas que compoem o Cte
				(xZBT)->(FieldPut(FieldPos(xZBT_+"TIPOFO") , cTipoFor   ))	//FR - 17/03/2020 - PROJETO POLITEC, gravar n˙meros das notas que compoem o Cte
		
				(xZBT)->(FieldPut(FieldPos(xZBT_+"CHAVEO")  , cChaveOri ))	//FR - 15/02/2021 - #6166 - MaxiRubber - NOVO CAMPO, chave da nf original (CTE)
				(xZBT)->(FieldPut(FieldPos(xZBT_+"NCM")     , cNCM      ))	//FR - 15/04/2021 - novo campo NCM
				(xZBT)->(FieldPut(FieldPos(xZBT_+"UM")      , cUM       ))	//FR - 15/04/2021 - novo campo UM - unidade medida
				(xZBT)->(FieldPut(FieldPos(xZBT_+"NFCI")    , cNFCI     ))	//FR - 28/04/2021
				(xZBT)->(FieldPut(FieldPos(xZBT_+"VLDESC")  , nVLDESC   ))	//FR - 28/04/2021
				(xZBT)->(FieldPut(FieldPos(xZBT_+"LOTE")    , cLOTE     ))	//FR - 28/04/2021
				(xZBT)->(FieldPut(FieldPos(xZBT_+"DVLOTE")  , dVLOTE    ))	//FR - 28/04/2021
				(xZBT)->(FieldPut(FieldPos(xZBT_+"ANOFAB")  , cANOFAB   ))	//FR - 28/04/2021
				//FR - 11/01/2022 - Petra - incluir campo ICMST
				(xZBT)->(FieldPut(FieldPos(xZBT_+"STBASE")  , nICMSTBas   ))
				(xZBT)->(FieldPut(FieldPos(xZBT_+"STALIQ")  , nICMSTAlq   ))
				(xZBT)->(FieldPut(FieldPos(xZBT_+"STVALO")  , nICMSTVal   ))				
				//FR - 11/01/2022 - Petra - incluir campo ICMST

				//--------------------------------------------------------------------------------//
				//FR - 16/05/2023 - #14880 - ELECON - TRATATIVA PARA GRAVAR CFOP NO ITEM ZBT_CFOP
				//--------------------------------------------------------------------------------//
				(xZBT)->(FieldPut(FieldPos(xZBT_+"CFOP")  , cCFOP   ))				

			DbSelectArea(xZBT)
			MsUnLock()

		Next fr

		//loop leitura na ZBT para gravar ZBT_DEPARA
		//----------------------------------------------------------------------------//
		//KIM P√ES - CHAMADO #000014229 - GRAVAR O C”DIGO DO PRODUTO INTERNO NO 
		//CAMPO ZBT_DEPARA, mediante Busca de amarraÁ„o (caso haja)
		//---------------------------------------------------------------------------//
        //pelo cÛdigo do produto fornecedor, captura o cÛdigo produto interno SB1:
        // Aadd(aRet, TRB->PRODFORNEC)
        //Aadd(aRet, TRB->PRODINTERNO)
        //--------------------------------------------------------------------------//
        /*
		//aInfo        := {}   
		//cProdInterno := ""
		//cClieFor     := Posicione("SA2",3,xFilial("SA2")+ cCnpjEmi ,"A2_COD")
		//cLoja        := Posicione("SA2",3,xFilial("SA2")+ cCnpjEmi ,"A2_LOJA")
			
		//If !Empty(cCliefor) .and. !Empty(cLoja)

		//	DbSelectArea( xZBT )
		//	(xZBT)->(dbSetOrder(2))		//FR - 27/11/19 - ZBT_CHAVE (Ìndice sem filial)
		//	(xZBT)->(dbSeek(cChaveXml))

				//While (xZBT)->(!Eof()) .AND. AllTrim(&(xZBT_+"CHAVE")) == AllTrim(cChaveXml)
		//		While (xZBT)->(!Eof()) .AND. AllTrim( (xZBT)->(FieldGet(FieldPos(xZBT_+"CHAVE"))) ) == AllTrim(cChaveXml)
		//			aInfo        := {}   
		//			cProdInterno := ""

					//Tenta buscar amarraÁ„o na ZB5
		//			aInfo := U_FGETZB5( (xZBT)->(FieldGet(FieldPos(xZBT_+"PRODUT"))) , cClieFor, cLoja, "F"  ) 	//aqui cCodProd È o cÛdigo do produto do fornecedor
				
		//			If Len(aInfo) > 0
						//cProdFor    := aInfo[1]	//produto do fornecedor
		//				cProdInterno:= Alltrim(aInfo[2])
		//			Endif

					//Se n„o encontrou na ZB5, tenta na SA5
		//			If Empty(cProdInterno) 
						
		//				aInfo := U_FGETSA5( (xZBT)->(FieldGet(FieldPos(xZBT_+"PRODUT"))) , cClieFor, cLoja , "F"  ) //aqui cCodProd È o cÛdigo do produto do fornecedor
		//				If Len(aInfo) > 0
							//cProdFor    := aInfo[1]	//produto do fornecedor
		//					cProdInterno:= Alltrim(aInfo[2])
		//				Endif

		//			Endif 

		//			If !Empty(cProdInterno)

		//				Reclock(xZBT,.F.)
		//					(xZBT)->(FieldPut(FieldPos(xZBT_+"DEPARA") , Alltrim(cProdInterno) ))
		//				DbSelectArea(xZBT)
		//				MsUnLock()

		//			Endif
		//			(xZBT)->(dbSkip())

		//		EndDo
			
		//Endif   
		*/         
		//loop leitura na ZBT para gravar ZBT_DEPARA - n„o precisa mais

	EndIf

EndIf
//fim grava ZBT

Restarea( aArea )

Return
//----------------------------------------------------------------------------------//
//FunÁ„o : fInfoCompl
//Autoria: Fl·via Rocha
//Data   : 28/04/2021
//Objetivo: //FunÁ„o para trazer o conte˙do da tag de InformaÁıes Complementares
//----------------------------------------------------------------------------------//
User Function fInfoCompl(xModelo,xXml)

Local cTGP   		:= ""
Local cTAG   		:= ""
Local xInfos 		:= "" 
Local cTagInfoCompl	:= ""
Local cError    	:= ""
Local cWarning		:= ""

Private cTagTXT := ""
Private oXml

//xXml := EncodeUTF8(xXml)

if !Empty( xXml )

	//Primeiro parse sem checagem de caracteres especiais
	if Len(xXml) >= 65534

		oXml := U_PARSGDE( xXml, @cError, @cWarning )

	Else

		oXml  := XmlParser( xXml, "_", @cError, @cWarning ) 

	endif

	//Caso for nil faz a segunda checagem somente para aqueles xml¥s que tem caracteres especiais
	if oXml == NIL 

			//Faz backup do xml sem retirar os caracteres especiais
			cBkpXml := xXml

			//			xXml := fWNOAccent( xXml )  //NoAcento(cXml)
			//			xXml := EncodeUTF8( xXml )

			//Executa rotina para retirar os caracteres especiais
			//			xXml := u_zCarEspec( xXml )

			//			if Len(xXml) >= 65534

			//				oXml := U_PARSGDE( xXml, @cError, @cWarning )

			//			Else

			oXml  := XmlParser( xXml, "_", @cError, @cWarning )

			//			endif


			if Empty( oXml )

				xXml := U_HFAjuXML(xXml)

				oXmlRet := XmlParser( xXml ,"_",@cError, @cWarning )

			endif

		//retorna o backup do xml
		xXml := cBkpXml

	endif

	if oXml <> Nil

		If xModelo == "55" 
			cTGP     := "NFE"
			cTAG     := "NFE"

		ElseIf xModelo == "57" 
			cTGP     := "CTE"
			cTAG     := "CTE"

		ElseIf xModelo == "65"
			cTGP     := "NFE"
			cTAG     := "NFE"

		ElseIf xModelo == "67"
			cTGP     := "CTEOS"
			cTAG     := "CTE"

		ElseIf xModelo == "RP"
			cTGP     := "NFSE"
			cTAG     := "NFSE"
		EndIf

		oObjInfoC     := "oXml:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_INFADIC" 
		cTagInfoCompl := ""
		xInfos        := ""

			If xModelo $ '55/65'

				oObjInfoC     := "oXml:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_INFADIC"

				cTagTXT := "oXml:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_INFADIC:_INFCPL:TEXT"

				if type(cTagTXT) <> "U"

					//if Type("oXml:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_INFADIC:_INFCPL:TEXT") <> "U" //.or. Type(oObjInfoC) <> "U"

					If (XmlChildEx( &(oObjInfoC) , "_INFCPL")) <> NIL     //checagem se existe o nÛ
						cTagInfoCompl := "oXml:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_INFADIC:_INFCPL:TEXT"    //oXml:_NFEPROC:_NFE:_INFNFE:_INFADIC:_INFCPL:TEXT
						xInfos  := Alltrim( &(cTagInfoCompl) ) //"TESTE DE INFORMA«’ES COMPLEMENTARES"
					Endif

				endif
			
		Elseif xModelo $ '57/67'
			
			//XmlChildEx(oXml:_PROCEVENTONFE:_EVENTO:_INFEVENTO, '_CHNFE') <> Nil
			If XmlChildEx( "oXml:_CTEPROC:_CTE:_INFCTE" , "_COMPL") <> NIL
			
				oObjInfoC     := "oXml:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_COMPL"

				//if Type("oXml:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_COMPL:_XOBS:TEXT") <> "U" //.or. Type(oObjInfoC) <> "U"

				If XmlChildEx( &(oObjInfoC) , "_XOBS") <> NIL     //checagem se existe o nÛ
					cTagInfoCompl := "oXml:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_COMPL:_XOBS:TEXT"    	//oXml:_CTEPROC:_CTE:_INFCTE:_COMPL:_XOBS:TEXT
					xInfos  := Alltrim( &(cTagInfoCompl) ) //"TESTE DE INFORMA«’ES COMPLEMENTARES"
				Endif

				//endif
			Endif 
			
		Elseif xModelo $ 'RP'

			xEspDoc := 'NFSE'
			
		Endif

	endif

endif

Return(xInfos) 

//==================================================================================//
//FunÁ„o  : fCADSA2(cCNPJEmi)  
//Autoria : Fl·via Rocha
//Data    : 28/10/2021
//Objetivo: FunÁ„o para checar se j· existe CNPJ no cadastro de fornecedor
//==================================================================================//
User Function fCADSA2(cCNPJEmi,xRECZBZ)
Local lGravSA2	:= .F. 
Local lBascnpj	:= .F.
Local cAux1    	:= ""
Local cAux2	 	:= ""
Local aTemSA2 	:= {} 
Local cCodSa2   := ""
Local cLojSa2   := ""
Local nLj		:= 0
Local aRet		:= {}
Local lXMLPEFORN:= ExistBlock( "XMLPEFORN" )

			
//verifica se o fornecedor existe ou n„o na base (cnpj inteiro):
aTemSA2 := U_fVerSA2( Alltrim(cCNPJEmi),1) 
			
If Len(aTemSA2) > 0
			
	If !aTemSA2[1] 
		lGravSA2 := .T.										
	
	Else								
		//verifica se o a base do cnpj j· existe, ent„o È nova filial
		cAux := ""
		cAux := Substr(cCNPJEmi,1,8)
		aTemSA2 := U_fVerSA2( Alltrim(cAux),2) 	
			
		If Len(aTemSA2) > 0									
			cAux1 := ""
			cAux2 := ""		
			If aTemSA2[1] 
									
				cAux1:= Alltrim( cCNPJEmi    )
				cAux2:= Alltrim( aTemSA2[2] )							
				If Substr(cAux1,1,8) == Substr(cAux2,1,8) .and.  Substr(cAux1,9,6) <> Substr(cAux2,9,6)
					lBascnpj := .T. 
				Endif
				//aqui j· trata se È filial, nesse caso ser· loja 02, 03 , assim por diante
				If lBascnpj
					cCodSa2   := aTemSA2[3] 
					nLj		  := Val(aTemSA2[4])
					nLj++
					cLojSa2   := Alltrim(Strzero(nLj,2))				
				Endif
			Else
				lGravSA2 := .T.																			 
			Endif						
		Endif					
	Endif
									
Else
	lGravSA2 := .T.				
Endif
			
If lGravSA2

	//Monta cÛdigo + loja fornecedor, obtÈm o cÛdigo do fornecedor ou padr„o ou via pto entrada
	If Empty(cCodSa2) .and. Empty(cLojSa2)
	
		If lXMLPEFORN //ExistBlock("XMLPEFORN")		//reativar qdo pto entrada estiver pronto
			//faz personalizado via pto entrada que ser· chamado na funÁ„o HFXML08D		
			cCodSA2 := "" 
			cLojSA2 := "" 
		Else
			//faz pelo padr„o
			cCodSA2   := U_fProxSa2()  //GetSxENum("SA2","A2_COD")  //FR TESTE 
			cLojSA2   := "01"
			While SA2->( DbSeek( xFilial( "SA2" ) + cCodSA2  ) )
			   ConfirmSX8()
			   cCodSA2 := GetSxeNum("SA2","A2_COD")
			Enddo
			
		Endif 
	Endif
	
	If xRECZBZ <> Nil	
		lGravSA2 := U_HFXML08D(.T.,cCodSa2,cLojSa2,cCnpjEmi,xRECZBZ)
	Else
		lGravSA2 := U_HFXML08D(.T.,cCodSa2,cLojSa2,cCnpjEmi)
	Endif 
	
Endif

Return 

//==================================================================================//
//FunÁ„o  : fVerSA2  
//Autoria : Fl·via Rocha
//Data    : 28/10/2021
//Objetivo: FunÁ„o para checar se j· existe CNPJ no cadastro de fornecedor
//==================================================================================//
User Function fVerSA2(_cCNPJ, nTipo)
Local aRetSA2 := {}
Local cCod    := ""
Local nLj     := 0

cQuery := "SELECT A2_COD, A2_LOJA, A2_CGC FROM "
cQuery += ""+ RetSqlName("SA2") + " SA2 "
cQuery += " WHERE "                    

If nTipo == 1
	//cnpj inteiro	
	cQuery += " A2_CGC = '" + Alltrim(_cCNPJ) + "' " 
	
Elseif nTipo == 2 .or. nTipo == 3
	//parte raiz do cnpj
	cQuery += " SUBSTRING(A2_CGC,1,8) = '" + Alltrim(_cCNPJ) + "' "
Endif

cQuery += " AND SA2.D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY A2_FILIAL, A2_COD, A2_LOJA "

MemoWrite("D:\QUERY\VERSA2.SQL" , cQuery )

cQuery := ChangeQuery(cQuery)

Iif(Select("XF3TAB") # 0,XF3TAB->(dbCloseArea()),.T.)
	
TcQuery cQuery New Alias "XF3TAB"

XF3TAB->(dbSelectArea("XF3TAB"))
XF3TAB->(dbGoTop())
			
If !XF3TAB->(EOF()) 

	//If nTipo == 1 .or. nTipo == 2 //devolve se tem na Sa2, e o cnpj para posterior comparaÁ„o
		Aadd( aRetSa2 , .T.		       )
		Aadd( aRetSa2 , XF3TAB->A2_CGC )
		Aadd( aRetSa2 , XF3TAB->A2_COD )
		Aadd( aRetSa2 , XF3TAB->A2_LOJA)
		//array de retorno se caso existir o cnpj, poder· comparar com o novo que est· se tentando cadastrar, 
		//pois a base pode ser igual mas o final diferente, nesse caso pode cadastrar pois È outra filial da mesma empresa		
	//Endif
	
Else
	Aadd( aRetSa2 , .F.		)
	Aadd( aRetSa2 , _cCNPJ 	)
	Aadd( aRetSa2 , "" 		)
	Aadd( aRetSa2 , ""		)

Endif

XF3TAB->(dbSelectArea("XF3TAB"))
DbCloseArea()

Return(aRetSa2) 

//==================================================================================//
//FunÁ„o  : fProxSa2  
//Autoria : Fl·via Rocha
//Data    : 28/10/2021
//Objetivo: FunÁ„o para trazer o prÛximo cÛdigo livre para fornecedor
//==================================================================================//
User Function fProxSa2(cRazao)
Local cQuery := ""
Local cCodRet:= ""

/*
SELECT MAX(A2_COD) FROM SA2990 SA2
WHERE SA2.D_E_L_E_T_=' ' 
AND A2_COD LIKE 'FR%' 		
GROUP BY A2_COD 
ORDER BY A2_COD DESC 
*/

cQuery := " SELECT MAX(A2_COD) CODIGO
cQuery += " FROM " + RetSqlname("SA2") + " SA2 "
cQuery += " WHERE SA2.D_E_L_E_T_=' '  "

If cRazao <> Nil .and. !Empty(cRazao)
	cQuery += " AND A2_COD LIKE '" + cRazao + "%' "		//se vier assim por exemplo FR, vai procurar todo cÛdigo que possui FR no inÌcio, ex: FR0001
Endif
 
//cQuery += " GROUP BY A2_COD "
//cQuery += " ORDER BY A2_COD DESC "

MemoWrite("D:\QUERY\PROXSA2.SQL" , cQuery )

cQuery := ChangeQuery(cQuery)

Iif(Select("XF3TAB") # 0,XF3TAB->(dbCloseArea()),.T.)
	
TcQuery cQuery New Alias "XF3TAB"

XF3TAB->(dbSelectArea("XF3TAB"))
XF3TAB->(dbGoTop())
			
If !XF3TAB->(EOF())	
	
	cCodRet := XF3TAB->CODIGO
	cCodRet := SOMA1(cCodRet)
	
Endif

If Empty(cCodRet)
	If cRazao <> Nil .and. !Empty(cRazao)  
		cCodRet := cRazao + "0001"
	Else
		cCodRet := "000001 
	Endif 
Endif 

SA2->(OrdSetFocus(1))
While SA2->( DbSeek( xFilial( "SA2" ) + cCodRet ) )
   ConfirmSX8()   
   cCodRet := SOMA1(cCodRet)
Enddo

XF3TAB->(dbSelectArea("XF3TAB"))
DbCloseArea()

Return(cCodRet)


/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Fun??o    ≥HFXNVMCHV≥ Autor ≥Henrique Tofanelli ≥      Data ≥ 12/08/13 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒƒ›ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒ›ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descri??o ≥ Download do XML por Chaves                                 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ HFXNVMCHV()                                                ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ›ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
User Function HFXNVMCHV(_cChave)

	Local lRet      := .F.
	Local lProt     := .T.
	//	Local lConModal := ( AllTrim(GetNewPar("XM_GRBMOD","N")) == "S" )
	//	Local cConLoc   := "2"  //AllTrim(GetNewPar("XM_ROT_CON","1"))              //1=WS Importa, 2=TSS
	//	Local cRetOK    := AllTrim(GetNewPar("XM_RETOK","526,731"))+AllTrim(GetNewPar("XM_RETDEN","301,302,303"))
	//	Local cMsgSm0   := ""
	//	Local nAno, nMes, xAnoMes
	//	Local cPref     := ""
	Local cTag      := ""
	Local cClToken  :=	alltrim(GetNewPar("XM_CLTOKEN",Space(256)))
	Local cCloud	:=	alltrim(GetNewPar("XM_CLOUD" ,"0"))         //aCombo (0=Desbilitado 1=Habilitado)
	Local lBaxResu  :=	GetNewPar("XM_BXRESUM","N")
	Local aHeader	:= {}
	Local cXmlRet   := ""
	Local cInicio   := "" 
	Local cFim      := ""
	Local aRetApi   := {}
	Local lAppend   := .F.
	Local cNota     := ""
	Local lResumo   := .F.
	Local lXmlChv   := .F.

	Private _cFil       := ""
	Private cError		:= ""
	Private cWarning	:= ""
	Private oXmlRet
	Private oObjJson  

	_cChave := alltrim(_cChave)
	cModelo := SubStr(_cChave,21,2)

	IF cModelo == "55"
		cTag := "NFe"
	elseif cModelo == "57"
		cTag := "CTe"
	ENDIF


	If cCloud == "1" //.and. cModelo == "55"

		cUrl 	:= "https://cloud.importaxml.com.br"
		cCnpj 	:= Alltrim(FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , { "M0_CGC" } )[1][2])

		Aadd(aHeader, "Content-Type: application/json")
		Aadd(aHeader, "Connection: keep-alive")

		oRest 	:= FWRest():New(cUrl)

		oRest:SetPath("/api/"+cTag+"?token="+cClToken+"&Inicio="+cInicio+"&Fim="+cFim+"&Chave="+_cChave)

		If oRest:Get(aHeader)

			If !FWJsonDeserialize(oRest:GetResult(), @oObjJson)
				MsgStop("Ocorreu erro no processamento do Json /api/"+cTag)
				Return Nil
			EndIf

		else

			msgStop(oRest:getLastError(), "Erro")

		EndIf


		If oObjJson <> Nil

			IF Type("oObjJson[1]:ERRO") <> "U"  //RETORNOU ERRO

				MsgInfo("Nenhuma informaÁ„o encontrada para esta Chave", "Chave n„o encontrada")
				cMensagem := "XML n„o encontrada para a Chave" + CRLF
				cCodRet := ""
				RETURN

			ENDIF

			cXmlRet := oObjJson[1]:XML

			if Upper("<resNFe ") $ Upper( cXmlRet )

				cModelo := iif(oObjJson[1]:TIPO == "NFe","55","57")
				cNota   := Substr(oObjJson[1]:CHAVE,26,9)
				lResumo := .T.

			else
			
				cModelo := oObjJson[1]:MODELO
				cNota   := oObjJson[1]:NOTA

			endif

			DbSelectArea(xZBZ)
			( xZBZ )->( DbSetOrder( 3 ) )
			lAppend := !(xZBZ)->(DbSeek(alltrim(oObjJson[1]:CHAVE)))
			dDataNF :=  (xZBZ)->(FieldGet(FieldPos(xZBZ_+"DTNFE")))

			// Erick GonÁalves e Lucas Santana -> 10/03/2023 - (ValidaÁ„o para efetuar o download por chave.)
			if oObjJson[1]:STATUS <> Nil .and. !DbSeek( &(xZBZ+"->"+xZBZ_+"CHAVE")) .Or. (xZBZ)->&(xZBZ_+"TPDOWL") == "R"
				
				If lXmlChv := !DbSeek( &(xZBZ+"->"+xZBZ_+"CHAVE")) .and. Alltrim(oObjJson[1]:STATUS) == "100" // Verifica se a chave n„o existe na ZBZ e se o xml est· completo no cloud

					u_HFXCTRGRV(cXmlRet,cModelo,ALLTRIM(oObjJson[1]:CNPJ),cNota,oObjJson[1]:CHAVE,@_cFil,lAppend,oObjJson[1]:STATUS,lResumo)
					MsgInfo("Xml baixado com sucesso","Download por Chave")

				Elseif !DbSeek( &(xZBZ+"->"+xZBZ_+"CHAVE")) .and. Alltrim(oObjJson[1]:STATUS) == "1"  // Verfica se a chave n„o existe na ZBZ e se o xml È resumido no cloud

					If lBaxResu == "S" // Vari·vel do par‚metro de Baixar Xml Resumido

						If MsgYesNo("O XML consta como resumido na Sefaz, deseja baixar mesmo assim?")
							u_HFXCTRGRV(cXmlRet,cModelo,ALLTRIM(oObjJson[1]:CNPJ),cNota,oObjJson[1]:CHAVE,@_cFil,lAppend,oObjJson[1]:STATUS,lResumo)
							MsgInfo("Xml resumido baixado com sucesso","Download por Chave")
						Else
							return
						EndIf

					Else
						MsgAlert("Seu ambiente n„o permite gravar xml resumido." + CRLF + CRLF + "Para efetuar a baixa, por favor ative o par‚metro (XM_BXRESUM) para realizar a baixa.","Aviso")
					EndIf

				Elseif DbSeek( &(xZBZ+"->"+xZBZ_+"CHAVE")) .and. (xZBZ)->&(xZBZ_+"TPDOWL") == "R" // Verifica se o xml existe na ZBZ e como est· baixado: Completo, Resumido ou IndisponÌvel.

					If MsgYesNo("O XML encontra-se resumido em sua Base de Dados, deseja realizar o download completo?")

						If Alltrim(oObjJson[1]:STATUS) == "100" // SÛ entra no if se o xml estiver completo no cloud
							u_HFXCTRGRV(cXmlRet,cModelo,ALLTRIM(oObjJson[1]:CNPJ),cNota,oObjJson[1]:CHAVE,@_cFil,lAppend,oObjJson[1]:STATUS,lResumo)					
							MsgInfo("Download do xml completo realizado com sucesso.","Download por Chave")
						Else
							MsgInfo("O WebService da Sefaz ainda n„o liberou o xml completo para download." + CRLF + "Por favor, aguarde uma hora e tente novamente." ,"AtenÁ„o")
						EndIf
					Else
						return
					EndIf

				Elseif !DbSeek( &(xZBZ+"->"+xZBZ_+"CHAVE")) .and. Alltrim(oObjJson[1]:STATUS) == "101" // Status de Cancelado no Cloud

					u_HFXCTRGRV(cXmlRet,cModelo,ALLTRIM(oObjJson[1]:CNPJ),cNota,oObjJson[1]:CHAVE,@_cFil,lAppend,oObjJson[1]:STATUS,lResumo)
					MsgInfo("Xml baixado com sucesso","Download por Chave")

				EndIf

			else

				MsgInfo("A chave informada j· consta no base de Dados. ","Chave encontrada")
			
			endif

			//if (xZBZ)->&(xZBZ_+"TPDOWL") <> "R"  .and. alltrim(oObjJson[1]:STATUS) == "100"    //Significa que j· foi realizado o Download e que n„o teve mudanÁa de Status - Nao precisa reimportar
				//MsgInfo("A chave informada j· consta no base de Dados. ","Chave encontrada")
			//else
				//u_HFXCTRGRV(cXmlRet,cModelo,ALLTRIM(oObjJson[1]:CNPJ),cNota,oObjJson[1]:CHAVE,@_cFil,lAppend,oObjJson[1]:STATUS,lResumo)
			//endif

		else

			if !Empty( oRest:GetResult() )

				msgStop("Falha no retorno da api",oRest:GetResult())

				oRest := NIL
				FreeObj(oRest)
				Return

			endif

		EndIf

		RETURN

		If oRest:GetResult() <> Nil

			aRetApi := oRest:GetResult()

			cXmlRet := strTran(cXmlRet,'"','')

			oXmlRet := XmlParser( cXmlRet ,"_",@cError, @cWarning )

			If ( oXmlRet == NIL )

				oXmlRet := NIL
				FreeObj(oXmlRet)
				MsgStop("Falha ao gerar Objeto XML : "+cError+" / "+cWarning)
				Return

			Endif

			//Se existir Warning, mostra no console.log
			If ! Empty(cWarning)

				ConOut( "[u_XConsXml] - Alerta cWarning: " + cWarning )

			EndIf

			//Se houve erro, n„o permitir· prosseguir
			If ! Empty(cError)

				ConOut("[u_XConsXml]- Erro: " + cError)
				lContinua := .F.

			EndIf

			if Type("oXmlRet:_RETCONSSITNFE:_PROTNFE:_INFPROT:_CHNFE:TEXT") <> "U"

				lRet := .T.

				cChave  := oXmlRet:_RETCONSSITNFE:_PROTNFE:_INFPROT:_CHNFE:TEXT
				cVersao := oXmlRet:_RETCONSSITNFE:_VERSAO:TEXT
				cStatus := oXmlRet:_RETCONSSITNFE:_PROTNFE:_INFPROT:_CSTAT:TEXT
				cTpAmb  := oXmlRet:_RETCONSSITNFE:_PROTNFE:_INFPROT:_TPAMB:TEXT
				cMotivo := oXmlRet:_RETCONSSITNFE:_PROTNFE:_INFPROT:_XMOTIVO:TEXT
				cProt   := oXmlRet:_RETCONSSITNFE:_PROTNFE:_INFPROT:_NPROT:TEXT
				cDigVal := oXmlRet:_RETCONSSITNFE:_PROTNFE:_INFPROT:_DIGVAL:TEXT

				cCodRet := cStatus

				cNewRet := "Protocolo: " + cProt + CRLF
				cNewRet += "Digito: " + cDigVal + CRLF

				cModelo := "55"

				cRet := "Chave: " + cChave + CRLF
				cRet += "Vers„o da mensagem: " + cVersao + CRLF
				cRet += "Ambiente: " + iif(cTpAmb == "1","ProduÁ„o","HomologaÁ„o") + CRLF
				cRet += "Cod. Ret. " + cModelo + ": " + cStatus + CRLF
				cRet += "Msg. Ret. " + cModelo + ": " + cMotivo + CRLF
				cRet += cNewRet

				if lShowMsg

					u_MyAviso("u_XConsXml - Consulta",cRet,{"OK"},3)

				endif

			Endif

		endif

		oRest := NIL
		FreeObj(oRest)

	Endif

RETURN


//========================================================================//
//FunÁ„o: fGetZB5(cProdFor,cCodFor,cLoja)
//Objetivo: Trazer o cÛdigo do produto interno, via informaÁ„o do 
//          cÛdigo produto fornecedor, cÛdigo fornecedor e loja
//========================================================================//
User Function fGetZB5(cProd,cClieFor,cLoja,xTipoProd)

Local cQuery := ""
Local aRet   := {}

cQuery := " SELECT  " + CRLF
cQuery += " " + xZB5_ + "PRODFI AS PRODINTERNO , "
//cQuery += " " + xZB5_ + "PRODFO AS PRODFORNEC ,  * "
cQuery += " " + xZB5_ + "PRODFO AS PRODFORNEC ,  " + xZB5 + ".* "
cQuery += " FROM " + RetSqlname(xZB5) + " ZB5 "
cQuery += " WHERE "
cQuery += " ZB5.D_E_L_E_T_ = ' ' "

If xTipoProd == "F"        //o tipo de produto informado no par‚metro È o produto do Fornecedor
   cQuery += " AND RTRIM( " + xZB5_ + "PRODFO) = '" + Alltrim(cProd) + "' "
Elseif xTipoProd == "I"    //o tipo de produto informado no par‚metro È o produto interno SB1
    cQuery += " AND RTRIM( " + xZB5_ + "PRODFI) = '" + Alltrim(cProd) + "' "
Endif 
 
cQuery += " AND RTRIM( " + xZB5_ + "FORNEC) = '" + Alltrim(cClieFor) + "' "
cQuery += " AND RTRIM( " + xZB5_ + "LOJFOR) = '" + Alltrim(cLoja)    + "' "

If Select("TRB") > 0
	dbSelectArea("TRB")
	dbCloseArea()
Endif

//+-----------------------
//| Cria uma view no banco
//+-----------------------
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TRB", .T., .F. )
dbSelectArea("TRB")

 //Contando os registros e voltando ao topo da tabela
//Count To nTotReg

TRB->( dbGoTop() )
If !TRB->(Eof())
    Aadd(aRet, TRB->PRODFORNEC)
    Aadd(aRet, TRB->PRODINTERNO)
Endif 

Return(aRet)


//========================================================================//
//FunÁ„o: fGetSA5(cCodProd, cClieFor,cLoja)
//Objetivo: Trazer o cÛdigo do fornecedor, passando por par‚metro o cÛdigo
//          interno, fornecedor e loja
//========================================================================//
User Function fGetSA5(cCodProd,cClieFor,cLoja,xTipo)

Local cQuery := ""
Local aRet   := {}

cQuery := " SELECT A5_PRODUTO , A5_CODPRF , A5_FORNECE , A5_LOJA "
cQuery += " FROM " + RetSqlname("SA5") + " SA5 "
cQuery += " WHERE "
cQuery += " SA5.D_E_L_E_T_ = ' ' "

If xTipo == "F"         //o tipo de produto informado no par‚metro È o produto do Fornecedor
   cQuery += " AND RTRIM(A5_CODPRF) = '" + Alltrim(cCodProd) + "' "
Elseif xTipo == "I"     //o tipo de produto informado no par‚metro È o produto interno SB1
   cQuery += " AND RTRIM(A5_PRODUTO) = '" + Alltrim(cCodProd) + "' "
Endif 
cQuery += " AND A5_FORNECE        = '" + Alltrim(cClieFor) + "' "
cQuery += " AND A5_LOJA           = '" + Alltrim(cLoja)    + "' "

If Select("TRB") > 0
	dbSelectArea("TRB")
	dbCloseArea()
Endif

//+-----------------------
//| Cria uma view no banco
//+-----------------------
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TRB", .T., .F. )
dbSelectArea("TRB")

 //Contando os registros e voltando ao topo da tabela
//Count To nTotReg

TRB->( dbGoTop() )
If !TRB->(Eof())
   Aadd(aRet, TRB->A5_CODPRF)
   Aadd(aRet, TRB->A5_PRODUTO) 
Endif 

Return(aRet)


//--------------------------------------------------------------//
//FUN«√O PARA TRAZER O N⁄MERO DA NF ORIGEM DO CABE«ALHO DO XML
//--------------------------------------------------------------//
USER FUNCTION FTRAZNFORI(cTagNFORI)
//cTagNFORI := "oXml:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_IDE:_NFREF"   //conte˙do que vem da chamada



//cTagNFORI := "oXml:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_IDE:_NREF:_REF"+ cTAG+":TEXT"   //documento ORIGINAL
//cChaveOri := U_FTRAZNFORI(cTagNFORI) //FR - 13/02/2023 - CAPTAR NUMERO DA NF ORIGEM VINDO DO CABE«ALHO DO XML

Local cTagRefNfe := ""
Local lSubstring := .F.
Local _NfOri     := Space(9)
Local _SrOri	 := Space(3)
//Local _xNOr      := Space(9)
//Local _xSOr      := Space(3)
Local cChvReg    := ""
Local aRef       := {}
Local aAreaZBZ	 := GetArea(xZBZ)
Local nFormSer	 := Nil

//FR - 02/03/2021 - #6272 - Mectronics - trazer automaticamente o n˙mero / sÈrie da nf original em cada item da nf
//cTagRefNfe := cTagNFORI  //"oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_NFREF"  //:_REFNFE:TEXT"
cChvReg := ""
 	
//FR - 30/03/2021 - #10372 - Mectronics - prever quando a estrutura do XML n„o possuir a informaÁ„o do documento original        
cTagRefNfe := ""
lSubstring := .F.
_NfOri     := ""
_SrOri	   := ""
    
If XmlChildEx(oXml:_NFEPROC:_NFE:_INFNFE:_IDE, '_NFREF') <> Nil  //verifica se a tag NFREF existe
	If type(cTagNFORI) <> "A"   //TIPO CARACTER   
   		Do Case
			Case XmlChildEx(oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_NFREF,'_REFNFE') <> Nil		
				cTagRefNfe := "oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_NFREF:_REFNFE:TEXT" 
				cChvReg := Alltrim(&(cTagRefNfe))  
			Case XmlChildEx(oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_NFREF,'_REFECF') <> Nil		
				Conout("Origem do XML Cupom fiscal MOD:"+;
					oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_NFREF:_REFECF:_MOD:TEXT+;
					" NCOO:"+;
					oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_NFREF:_REFECF:_NCOO:TEXT+;
					" NECF:"+;
					oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_NFREF:_REFECF:_NECF:TEXT;
				)	
				cChvReg := ""
			OtherWise
				Conout("Origem do XML Sem Tratativa")
		EndCase		
	Else
   		Do Case
			Case XmlChildEx(oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_NFREF[1],'_REFNFE') <> Nil		
				cTagRefNfe := "oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_NFREF[1]:_REFNFE:TEXT" 
				cChvReg := Alltrim(&(cTagRefNfe))  
			Case XmlChildEx(oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_NFREF[1],'_REFECF') <> Nil		
				Conout("Origem do XML Cupom fiscal MOD:"+;
					oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_NFREF[1]:_REFECF:_MOD:TEXT+;
					" NCOO:"+;
					oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_NFREF[1]:_REFECF:_NCOO:TEXT+;
					" NECF:"+;
					oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_NFREF[1]:_REFECF:_NECF:TEXT;
				)	
				cChvReg := ""
			OtherWise
				Conout("Origem do XML Sem Tratativa")
		EndCase		
	Endif		

EndIF

If !Empty(cChvReg)
	_NfOri   := Substr(cChvReg,26,9)
	_SrOri   := Substr(cChvReg,23,3)  //esta com 3 zeros		
		
	If nFormSer = 2
		If Val(_SrOri) <= 99
			_SrOri := StrZero(Val(_SrOri),2,0)+" "
		Endif
	Elseif nFormSer = 3
		_SrOri := StrZero( Val(_SrOri),3,0)	  
	Endif

Endif 

Aadd(aRef, cChvReg)
Aadd(aRef, _NfOri)
Aadd(aRef, _SrOri )
	
(xZBZ)->(RestArea(aAreaZBZ))

Return(aRef)
