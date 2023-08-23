#INCLUDE "PROTHEUS.CH"


Static cURL      := PadR(GetNewPar("XM_URL",""),250)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HFXML02X  º Autor ³ Roberto Souza      º Data ³  22/02/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Consulta Chave e atualiza o Status do XML dos Fornecedores º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Importa XML                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function HFXML02X( cAlias,nReg,nOpcX,lTela,lAuto )

Local oDlgKey, oBtnOut, oBtnCon
//Local cIdEnt    := ""
Local cChaveXml := AllTrim( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))) )
Local cModelo   := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO")))
Local cProtocolo:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"PROT")))
//Local dDtNfe    := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"DTNFE")))
Local cMensagem := ""
//Local aArea     := GetArea()
//Local lRet      := .T.
Local cPref     := "NF-e"                             
Local cTAG      := "NFE"
Local cCodRet   := ""
Local xManif    := "" //GETESB2
Local cCloud	:=	alltrim(GetNewPar("XM_CLOUD" ,"0"))         //aCombo (0=Desbilitado 1=Habilitado) 

Default lTela   := .T.
Default lAuto   := .F.
Default cURL    := AllTrim(GetNewPar("XM_URL",""))

if GetNewPar("XM_DFE","0") $ "0,1"

	if cCloud <> "1"
	
		cIdEnt := U_GetIdEnt()

		cURL   := PadR(GetNewPar("XM_URL",""),250)

		If Empty(cURL)

			cURL := PadR(GetNewPar("MV_SPEDURL","http://"),250)

		EndIf

	else

		cIdEnt := ""
		cUrl   := ""
		
	endif

else
	
	cUrl := ""
	
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
/*
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01" MODULO "FAT" TABLES "SF1","SF2","SD1","SD2","SF4","SB5","SF3","SB1"
	RpcSetType(3)
	DbSelectArea("ZBZ")
	DbGoTo(256)
*/

If lTela

	DEFINE MSDIALOG oDlgKey TITLE "Consulta "+cPref FROM 0,0 TO 150,305 PIXEL OF GetWndDefault()
	
	@ 12,008 SAY "Informe a Chave de acesso do xml de "+cPref PIXEL OF oDlgKey
	@ 20,008 MSGET cChaveXml SIZE 140,10 PIXEL OF oDlgKey //READONLY
	
	@ 46,035 BUTTON oBtnCon PROMPT "&Consultar" SIZE 38,11 PIXEL ;
	ACTION (lValidado := U_XConsXml(cURL,cChaveXml,cModelo,cProtocolo,@cMensagem,@cCodRet,.T.,,,@xManif),;
		,oDlgKey:End())
	@ 46,077 BUTTON oBtnOut PROMPT "&Sair" SIZE 38,11 PIXEL ACTION oDlgKey:End()
	
	ACTIVATE DIALOG oDlgKey CENTERED

Else

	if lAuto

		lValidado := U_XConsXml(cURL,cChaveXml,cModelo,cProtocolo,@cMensagem,@cCodRet,.F.,,,@xManif)

	Else

		MsgRun("Aguarde. Consultando Chave Sefaz...","Consultando Chave Sefaz",{|| lValidado := U_XConsXml(cURL,cChaveXml,cModelo,cProtocolo,@cMensagem,@cCodRet,.F.,,,@xManif) } )

	Endif

Endif

If !Empty(cCodRet) //.AND. lConsReq

	U_XMLSETCS(cModelo,cChaveXml,cCodRet,cMensagem,xManif) 

EndIf

If !lTela .And. !Empty(cMensagem)   //.And. lConsReq

	U_myAviso("Importa XMl",cMensagem,{"OK"},3)

Endif

Return
