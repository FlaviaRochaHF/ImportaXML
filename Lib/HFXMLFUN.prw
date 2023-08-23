#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "Ap5Mail.ch"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "XMLXFUN.CH"
//#INCLUDE "mata140.ch"
#Include "RwMake.Ch"

#DEFINE VALMERC	 01	// Valor total do mercadoria
#DEFINE VALDESC	 02	// Valor total do desconto
#DEFINE TOTPED	 03	// Total do Pedido
#DEFINE FRETE    04	// Valor total do Frete
#DEFINE VALDESP  05	// Valor total da despesa
#DEFINE TOTF1	 06	// Total de Despesas Folder 1               
#DEFINE SEGURO	 07	// Valor total do seguro
#DEFINE TOTF3	 08	// Total utilizado no Folder 3	
#DEFINE VNAGREG	 09	// Valor total nao agregado ao total do documento
#DEFINE _CRLF	Chr(13) + Chr(10)

Static aPedC := {}

//--------------------------------------------------------------//
//FR - 08/05/2020 - Alterações realizadas para adequar na rotina 
//                  Pré Auditoria Fiscal verificação de 
//                  divergências entre XML x NF 
//-------------------------------------------------------------//
//FR - 12/06/2020 - Alterações realizadas para adequar a validação da licença 
//                  quando for licença Demonstração (Demo)
//                  Implementado de validação de período na query da função
//                  U_XmlInfoX, para NÃO permitir consultas
//                  no relatório de forma abrangente
//                  Demo = consulta é data de hoje - 30 apenas
//                  
//---------------------------------------------------------------------------//
//FR - 23/06/2020 - Alterações relativas à reunião de equipe com Rafael 
//                  A tela de divergência completa não será mostrada na pré-nota
//                  Somente campos divergentes relativos a:
//                  - Qtde
//                  - Preço unitário
//---------------------------------------------------------------------------//
//FR - 05/05/2021 - #10382 - Kroma - tratativa para chamada dentro do Schedule
//----------------------------------------------------------------------------//
//FR - 07/06/2021 - Rollback das alterações da Kroma
//----------------------------------------------------------------------------//      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MyAviso   ºAutor  ³Roberto Souza       º Data ³  01/01/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Interface/Dialog de Aviso.                                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Geral                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MyAviso(cCaption,cMensagem,aBotoes,nSize,cCaption2, nRotAutDefault,cBitmap,lEdit,nTimer,nOpcPadrao,lAuto)
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Quando for rotina automatica, envia o aviso ao Log.          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type('lMsHelpAuto') == 'U'
	lMsHelpAuto := .F.
EndIf

If !lMsHelpAuto
	If nSize == Nil
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o numero de botoes Max. 5 e o tamanho da Msg.       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If  Len(aBotoes) > 3
			If Len(cMensagem) > 286
				nSize := 3
			Else
				nSize := 2
			EndIf
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
//		@ 2, 37 BITMAP RESNAME cBitmap oF oDlgAviso SIZE 18,18 NOBORDER WHEN .F. PIXEL
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
		TButton():New(1000,1000," ",oDlgAviso,{||Nil},32,10,,oDlgAviso:oFont,.F.,.T.,.F.,,.F.,,,.F.)
	EndIf
	ny := (aSize[nLinha][2]/2)-36
	For nx:=1 to Len(aBotoes)
		cAction:="{||nOpcAviso:="+Str(Len(aBotoes)-nx+1)+",oDlgAviso:End()}"
		bAction:=&(cAction)
		cMsgButton:= OemToAnsi(AllTrim(aBotoes[Len(aBotoes)-nx+1]))
		cMsgButton:= IF(  "&" $ Alltrim(cMsgButton), cMsgButton ,  "&"+cMsgButton )
		TButton():New(aSize[nLinha][7],ny,cMsgButton, oDlgAviso,bAction,32,10,,oDlgAviso:oFont,.F.,.T.,.F.,,.F.,,,.F.)
		ny -= 35
	Next nx
	If nTimer <> Nil
		oTimer := TTimer():New(nTimer,{|| nOpcAviso := nOpcPadrao,IIf(nPass==0,nPass++,oDlgAviso:End()) },oDlgAviso)
		oTimer:Activate()       
		bAction:= {|| oTimer:DeActivate() }
		TButton():New(aSize[nLinha][7],ny,"Timer off", oDlgAviso,bAction,32,10,,oDlgAviso:oFont,.F.,.T.,.F.,,.F.,,,.F.)
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GetIdEnt  ºAutor  ³Roberto Souza       º Data ³  01/01/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna a ID da entidade do TSS correspondente a filial    º±±
±±º          ³ corrente.                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Geral                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function GetIdEnt()

Local aArea  := GetArea()
Local cIdEnt := ""
Local cURL   := ""
Local oWs
Local cCloud :=	GetNewPar("XM_CLOUD" ,"0")         //aCombo (0=Desbilitado 1=Habilitado)

if GetNewPar("XM_DFE","0") $ "0,1"

	if cCloud <> "1"
	
		//cIdEnt := U_GetIdEnt()

		cURL   := PadR(GetNewPar("XM_URL",""),250)

		If Empty(cURL)

			cURL := PadR(GetNewPar("MV_SPEDURL","http://"),250)

		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Obtem o codigo da entidade                                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oWS := WsSPEDAdm():New()
		oWS:cUSERTOKEN := "TOTVS"
			
		oWS:oWSEMPRESA:cCNPJ       := IIF(SM0->M0_TPINSC==2 .Or. Empty(SM0->M0_TPINSC),SM0->M0_CGC,"")	
		oWS:oWSEMPRESA:cCPF        := IIF(SM0->M0_TPINSC==3,SM0->M0_CGC,"")
		oWS:oWSEMPRESA:cIE         := SM0->M0_INSC
		oWS:oWSEMPRESA:cIM         := SM0->M0_INSCM		
		oWS:oWSEMPRESA:cNOME       := SM0->M0_NOMECOM
		oWS:oWSEMPRESA:cFANTASIA   := SM0->M0_NOME
		oWS:oWSEMPRESA:cENDERECO   := FisGetEnd(SM0->M0_ENDENT)[1]
		oWS:oWSEMPRESA:cNUM        := FisGetEnd(SM0->M0_ENDENT)[3]
		oWS:oWSEMPRESA:cCOMPL      := FisGetEnd(SM0->M0_ENDENT)[4]
		oWS:oWSEMPRESA:cUF         := SM0->M0_ESTENT
		oWS:oWSEMPRESA:cCEP        := SM0->M0_CEPENT
		oWS:oWSEMPRESA:cCOD_MUN    := SM0->M0_CODMUN
		oWS:oWSEMPRESA:cCOD_PAIS   := "1058"
		oWS:oWSEMPRESA:cBAIRRO     := SM0->M0_BAIRENT
		oWS:oWSEMPRESA:cMUN        := SM0->M0_CIDENT
		oWS:oWSEMPRESA:cCEP_CP     := Nil
		oWS:oWSEMPRESA:cCP         := Nil
		oWS:oWSEMPRESA:cDDD        := Str(FisGetTel(SM0->M0_TEL)[2],3)
		oWS:oWSEMPRESA:cFONE       := AllTrim(Str(FisGetTel(SM0->M0_TEL)[3],15))
		oWS:oWSEMPRESA:cFAX        := AllTrim(Str(FisGetTel(SM0->M0_FAX)[3],15))
		oWS:oWSEMPRESA:cEMAIL      := UsrRetMail(RetCodUsr())
		oWS:oWSEMPRESA:cNIRE       := SM0->M0_NIRE
		oWS:oWSEMPRESA:dDTRE       := SM0->M0_DTRE
		oWS:oWSEMPRESA:cNIT        := IIF(SM0->M0_TPINSC==1,SM0->M0_CGC,"")
		oWS:oWSEMPRESA:cINDSITESP  := ""
		oWS:oWSEMPRESA:cID_MATRIZ  := ""
		oWS:oWSOUTRASINSCRICOES:oWSInscricao := SPEDADM_ARRAYOFSPED_GENERICSTRUCT():New()
		oWS:_URL := AllTrim(cURL)+"/SPEDADM.apw"

		If oWs:ADMEMPRESAS()
			cIdEnt  := oWs:cADMEMPRESASRESULT
		Else
			cIdEnt  := "000001"
		EndIf

	else

		cIdEnt := ""
		
	endif

else
	
	cUrl := ""
	
endif

RestArea(aArea)

Return(cIdEnt)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HFSTATSEF ºAutor  ³Roberto Souza       º Data ³  01/01/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica o Status da Sefaz referente a Entidade informada. º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Geral                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function HFSTATSEF(lAuto,cIdEnt,cInfo,lMostra)

Local lRet := .F., antRet := .F., lPri := .T.           
Local oWS
Local oDlg
Local oGet
Local cURL       := ""
Local cStatus    := ""
Local cAuditoria := ""
Local aSize      := {}
Local aXML       := {}
Local nX         := 0
Local lUSANFE    := AllTrim(GetNewPar("XM_USANFE","S")) $ "S "
Local lUSACTE    := AllTrim(GetNewPar("XM_USACTE","S")) $ "S "
Local lCONTING   := AllTrim(GetNewPar("XM_CONTIG","N")) $ "S "
Local lUSANFC    := AllTrim(GetNewPar("XM_USANFCE","N")) $ "S "  //NFCE_01 - 01/02/2016 Nfc-e
Local cCloud	 :=	GetNewPar("XM_CLOUD" ,"0")         //aCombo (0=Desbilitado 1=Habilitado)

Default	lAuto  := .F.

if GetNewPar("XM_DFE","0") $ "0,1"

	if cCloud <> "1"

		cURL    := AllTrim(GetNewPar("XM_URL",""))
		If Empty(cURL)
			cURL  := AllTrim(SuperGetMv("MV_SPEDURL"))
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Caso nao informe o ID da entidade e utilizada a da filial corrente      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cIdEnt == Nil .Or. Empty(cIdEnt)
			cIdEnt := U_GetIdEnt()
		EndIf

		If !Empty(cIdEnt)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Instancia a classe                                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(cIdEnt)
				oWS:= WSNFeSBRA():New()
				oWS:cUSERTOKEN := "TOTVS"
				oWS:cID_ENT    := cIdEnt
				oWS:_URL       := AllTrim(cURL)+"/NFeSBRA.apw"
				If oWS:MONITORSEFAZMODELO()
					aSize := MsAdvSize()
					aXML := oWS:oWsMonitorSefazModeloResult:OWSMONITORSTATUSSEFAZMODELO
					lRet := .F.
					lPri := .T.
					For nX := 1 To Len(aXML)
						Do Case
							Case aXML[nX]:cModelo == "55"
								cStatus += "- NFe"+CRLF
							Case aXML[nX]:cModelo == "57"
								cStatus += "- CTe"+CRLF
							Case aXML[nX]:cModelo == "65"
								cStatus += "- NFCe"+CRLF	//NFCE_01 - 01/02/2016 Nfc-e
						EndCase
						cStatus += Space(6)+"Versão da mensagem: "+aXML[nX]:cVersaoMensagem+CRLF
						cStatus += Space(6)+"Código do Status: "+aXML[nX]:cStatusCodigo+"-"+aXML[nX]:cStatusMensagem+CRLF
						cStatus += Space(6)+"UF Origem: "+aXML[nX]:cUFOrigem+CRLF
						If !Empty(aXML[nX]:cUFResposta)
							cStatus += Space(6)+"UF Resposta: "+aXML[nX]:cUFResposta+CRLF
						EndIf
						If aXML[nX]:nTempoMedioSEF <> Nil
							cStatus += Space(6)+"Tempo de espera: "+Str(aXML[nX]:nTempoMedioSEF,6)+CRLF+CRLF
						EndIf
						If !Empty(aXML[nX]:cMotivo)
							cStatus += Space(6)+"Motivo"+": "+aXML[nX]:cMotivo+CRLF+CRLF
						EndIf
						If !Empty(aXML[nX]:cObservacao)
							cStatus += Space(6)+"Observação"+": "+aXML[nX]:cObservacao+CRLF+CRLF
						EndIf
						If !Empty(aXML[nX]:cSugestao)
							cStatus += Space(6)+"Sugestão"+": "+aXML[nX]:cSugestao+CRLF+CRLF
						EndIf
						If !Empty(aXML[nX]:cLogAuditoria)
							cAuditoria += aXML[nX]:cLogAuditoria
						EndIf
						if lCONTING
							cStatus += "(*** CONTINGENCIA DO IMPORTA XML HABILITADA - XM_CONTIG ***)"+CRLF+CRLF
						endif

						cInfo := cStatus
						if (aXML[nX]:cModelo == "55" .and. lUSANFE) .or. (aXML[nX]:cModelo == "57" .and. lUSACTE) .or.;
							(aXML[nX]:cModelo == "65" .and. lUSANFC) //NFCE_01 - 01/02/2016 Nfc-e
							antRet := AllTrim(aXML[nX]:cStatusCodigo)=="107"
							if lPri .or. !antRet
								lRet := antRet
								lPri := .F.
							endif
						endif
						if lCONTING .And. ! lRet
							lRet := .T.
						endif
					Next nX
					If !lAuto .And. lMostra						
						DEFINE MSDIALOG oDlg TITLE "SPED - NFe" From 017,000 to (aSize[6]/3),(aSize[5]/2) OF oMainWnd PIXEL
						@ 005,005 GET oGet VAR cStatus OF oDlg SIZE (aSize[3]/2)-005,(aSize[4]/3)-032 PIXEL MULTILINE
						oGet:lReadOnly := .T.
						@ (aSize[4]/3)-022,(aSize[3]/2)-040 BUTTON oBtn1 PROMPT "OK"   	  			ACTION oDlg:End() OF oDlg PIXEL SIZE 035,011
						@ (aSize[4]/3)-022,(aSize[3]/2)-080 BUTTON oBtn2 PROMPT "Detalhes"   		ACTION (Aviso("Detalhes",cAuditoria,{"OK"},3)) OF oDlg PIXEL SIZE 035,011 WHEN !Empty(cAuditoria)
						ACTIVATE MSDIALOG oDlg	CENTERED
					EndIf
				Else
					lRet := .F.
					cInfo := IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
					If !lAuto						
						U_MyAviso("SPED",cInfo,{"OK"},3)
					EndIf		
				EndIf	
			EndIf
		Else
			lRet := .F.
			cInfo := "Execute o módulo de configuração do TSS, antes de utilizar a consulta de Status da Sefaz!!!"
			If !lAuto						
				U_MyAviso("SPED",cInfo,{"OK"},3)
			EndIf		
			
		EndIf

	else
		
		lRet := .T.

	endif

else

	//Modelo sem TSS
	lRet := .T.

endif

Conout(cInfo)

Return(lRet)

            
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IsShared  ºAutor  ³Roberto Souza       º Data ³  24/01/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se a tabela é compartilhada ou exclusiva.         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Geral                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function IsShared(cTable)
Local lRet := .F.           

DbSelectArea("SX2")
DbSetOrder(1)

If DbSeek(cTable)
	lRet := SX2->X2_MODO == "C"
EndIf

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³XCfgMail  ºAutor  ³Roberto Souza       º Data ³  01/03/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Obtem os dados de configuração POP / IMAP.                 º±±
±±º          ³                                                            º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ XCfgMail(nTipo,nOpc,aInfo)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1: Array com os dados de configuração de e-mail.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nTipo: Tipo de Configuração                                 ³±±
±±³          ³       1-SMTP                                               ³±±
±±³          ³       2-POP                                                ³±±
±±³          ³nOpc : Operação                                             ³±±
±±³          ³       1-Visualização                                       ³±±
±±³          ³       2-Edição                                             ³±±
±±³          ³aInfo: Array contendo dados para Edição                     ³±±
±±³          ³                                                            ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Geral                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function XCfgMail(nTipo,nOpc,aInfo)

Local aRet   := {}           
Local cServer  := ""
Local cLogin   := ""
Local cConta   := ""
Local cPass    := ""
Local lAuth    := .F.
Local lSSL     := .F.
Local lTLS     := .F. //aquuiiii
Local cProtocol:= ""   
Local cPort    := ""

Default nOpc := 1
Default aInfo:= {}
Default nTipo:= 0

If nTipo == 1  // SMTP            

    If nOpc == 1 // Visualizar

		cServer  := Padr(GetNewPar("XM_SMTP",Space(50)),50)
		cLogin   := Padr(GetNewPar("XM_LOGIN",Space(50)),50)
		cConta   := Padr(GetNewPar("XM_ACCOUNT",Space(50)),50)
		cPass    := Padr(Decode64(GetNewPar("XM_PASS",Space(25))),25)
		lAuth    := GetNewPar("XM_AUT",Space(1))=="S"
		lSSL     := GetNewPar("XM_SSL",Space(1))=="S"
		lTLS     := GetNewPar("XM_TLS",Space(1))=="S"   //aquuiiii
		cProtocol:= GetNewPar("XM_PROTENV","1") 
		cPort    := Padr(GetNewPar("XM_ENVPORT",Space(6)),6)                                   

	ElseIf nOpc == 2 // Atualizar
         
		cServer  := aInfo[1]
		cLogin   := aInfo[2]
		cConta   := aInfo[3]
		cPass    := aInfo[4]
		lAuth    := aInfo[5]
		lSSL     := aInfo[6]
		cProtocol:= aInfo[7]
   		cPort    := aInfo[8]
		lTLS     := aInfo[9]  //aquuiiii
   		
		If !PutMv("XM_SMTP", cServer ) 
			RecLock("SX6",.T.)
			SX6->X6_FIL     := xFilial("SX6")
			SX6->X6_VAR     := "XM_SMTP"
			SX6->X6_TIPO    := "C"
			SX6->X6_DESCRIC := "SMTP de Envio de XML Fornecedor."
			MsUnLock()
			PutMv("XM_SMTP", cServer )
		EndIf
		/********************************/
		If !PutMv("XM_LOGIN", cLogin      )
			RecLock("SX6",.T.)
			SX6->X6_FIL     := xFilial("SX6")
			SX6->X6_VAR     := "XM_LOGIN"
			SX6->X6_TIPO    := "C"
			SX6->X6_DESCRIC := "Login de Email de Envio de XML Fornecedor."
			MsUnLock()
			PutMv("XM_LOGIN", cLogin      )
		EndIf
		/********************************/
		If !PutMv("XM_ACCOUNT", cConta  )
			RecLock("SX6",.T.)
			SX6->X6_FIL     := xFilial("SX6")
			SX6->X6_VAR     := "XM_ACCOUNT"
			SX6->X6_TIPO    := "C"
			SX6->X6_DESCRIC := "Conta de Email de Envio de XML Fornecedor."
			MsUnLock()
			PutMv("XM_ACCOUNT", cConta  )
		EndIf	
		/********************************/
		If !PutMv("XM_PASS", Encode64(AllTrim(cPass))  )
			RecLock("SX6",.T.)
			SX6->X6_FIL     := xFilial("SX6")
			SX6->X6_VAR     := "XM_PASS"
			SX6->X6_TIPO    := "C"
			SX6->X6_DESCRIC := "Senha da Conta de Envio de XML Fornecedor."
			MsUnLock()
			PutMv("XM_PASS", Encode64(AllTrim(cPass))  )
		EndIf
		/********************************/
		If !PutMv("XM_AUT", Iif(lAuth,"S","N")   )
			RecLock("SX6",.T.)
			SX6->X6_FIL     := xFilial("SX6")
			SX6->X6_VAR     := "XM_AUT"
			SX6->X6_TIPO    := "C"
			SX6->X6_DESCRIC := "Informa se e-mail utiliza autenticação."
			MsUnLock()
			PutMv("XM_AUT", Iif(lAuth,"S","N")   )
		EndIf
		/********************************/
		If !PutMv("XM_SSL", Iif(lSSL     ,"S","N")   )
			RecLock("SX6",.T.)
			SX6->X6_FIL     := xFilial("SX6")
			SX6->X6_VAR     := "XM_SSL"
			SX6->X6_TIPO    := "C"
			SX6->X6_DESCRIC := "Informa se e-mail utiliza conexao segura SSL."
			MsUnLock()
			PutMv("XM_SSL", Iif(lSSL     ,"S","N")   )
		EndIf
		/*******************************Aquuiiii*/
		If !PutMv("XM_TLS", Iif(lTLS     ,"S","N")   )
			RecLock("SX6",.T.)
			SX6->X6_FIL     := xFilial("SX6")
			SX6->X6_VAR     := "XM_TLS"
			SX6->X6_TIPO    := "C"
			SX6->X6_DESCRIC := "Informa se e-mail utiliza conexao segura TLS."
			MsUnLock()
			PutMv("XM_TLS", Iif(lTLS     ,"S","N")   )
		EndIf
		/********************************/
		If !PutMv("XM_PROTENV", cProtocol   )
			RecLock("SX6",.T.)
			SX6->X6_FIL     := xFilial("SX6")
			SX6->X6_VAR     := "XM_PROTENV"
			SX6->X6_TIPO    := "C"
			SX6->X6_DESCRIC := "Protocolo de envio de notificação de xml."
			MsUnLock()
			PutMv("XM_PROTENV", cProtocol   )
		EndIf
		/********************************/
		If !PutMv("XM_ENVPORT", cPort   )
			RecLock("SX6",.T.)
			SX6->X6_FIL     := xFilial("SX6")
			SX6->X6_VAR     := "XM_ENVPORT"
			SX6->X6_TIPO    := "C"
			SX6->X6_DESCRIC := "Porta de Envio."
			MsUnLock()
			PutMv("XM_ENVPORT", cPort   )
		EndIf
	EndIf


ElseIf nTipo == 2              

    If nOpc == 1 // Visualizar

		cServer  := Padr(GetNewPar("XM_POPIMAP",Space(50)),50)
		cLogin   := "" //Padr(GetNewPar("XM_LOGIN",Space(40)),40)
		cConta   := Padr(GetNewPar("XM_POPACC",Space(50)),50)
		cPass    := Padr(Decode64(GetNewPar("XM_POPPASS",Space(25))),25)
		lAuth    := GetNewPar("XM_POPAUT",Space(1))=="S"
		lSSL     := GetNewPar("XM_POPSSL",Space(1))=="S"                                                      
		lTLS     := GetNewPar("XM_POPTLS",Space(1))=="S"
		cProtocol:= GetNewPar("XM_PROTREC","1") 
		cPort    := Padr(GetNewPar("XM_RECPORT",Space(6)),6) 	
	
	ElseIf nOpc == 2 // Atualizar
         
		cServer  := aInfo[1]
		cLogin 	 := aInfo[2]
		cConta   := aInfo[3]
		cPass    := aInfo[4]
		lAuth    := aInfo[5]
		lSSL     := aInfo[6]
		cProtocol:= aInfo[7]
   		cPort    := aInfo[8]
		lTLS     := aInfo[9]  //aquuiiii

		If !PutMv("XM_POPIMAP", cServer ) 
			RecLock("SX6",.T.)
			SX6->X6_FIL     := xFilial("SX6")
			SX6->X6_VAR     := "XM_POPIMAP"
			SX6->X6_TIPO    := "C"
			SX6->X6_DESCRIC := "Endereço POP/IMAP de Recebimento de XML Fornecedor"
			MsUnLock()
			PutMv("XM_POPIMAP", cServer )
		EndIf
		/********************************
		If !PutMv("XM_LOGIN", cLogin      )
			RecLock("SX6",.T.)
			SX6->X6_FIL     := xFilial("SX6")
			SX6->X6_VAR     := "XM_LOGIN"
			SX6->X6_TIPO    := "C"
			SX6->X6_DESCRIC := "Conta de Email de Recebimento de XML Fornecedor."	
			MsUnLock()
			PutMv("XM_LOGIN", cLogin      )
		EndIf
		/********************************/
		If !PutMv("XM_POPACC", cConta  )
			RecLock("SX6",.T.)
			SX6->X6_FIL     := xFilial("SX6")
			SX6->X6_VAR     := "XM_POPACC"
			SX6->X6_TIPO    := "C"
			SX6->X6_DESCRIC := "Conta de Email de Recebimento de XML Fornecedor."	
			MsUnLock()
			PutMv("XM_POPACC", cConta  )
		EndIf	
		/********************************/
		If !PutMv("XM_POPPASS", Encode64(AllTrim(cPass))  )
			RecLock("SX6",.T.)
			SX6->X6_FIL     := xFilial("SX6")
			SX6->X6_VAR     := "XM_POPPASS"
			SX6->X6_TIPO    := "C"
			SX6->X6_DESCRIC := "Senha da Conta de Recebimento de XML Fornecedor."
			MsUnLock()
			PutMv("XM_POPPASS", Encode64(AllTrim(cPass))  )
		EndIf
		/********************************/
		If !PutMv("XM_POPAUT", Iif(lAuth,"S","N")   )
			RecLock("SX6",.T.)
			SX6->X6_FIL     := xFilial("SX6")
			SX6->X6_VAR     := "XM_POPAUT"
			SX6->X6_TIPO    := "C"
			SX6->X6_DESCRIC := "Informa se e-mail utiliza autenticação."
			MsUnLock()
			PutMv("XM_POPAUT", Iif(lAuth,"S","N")   )
		EndIf
		/********************************/
		If !PutMv("XM_POPSSL", Iif(lSSL     ,"S","N")   )
			RecLock("SX6",.T.)
			SX6->X6_FIL     := xFilial("SX6")
			SX6->X6_VAR     := "XM_POPSSL"
			SX6->X6_TIPO    := "C"
			SX6->X6_DESCRIC := "Informa se e-mail utiliza conexao segura."
			MsUnLock()
			PutMv("XM_POPSSL", Iif(lSSL     ,"S","N")   )
		EndIf
		/********************************/
		If !PutMv("XM_PROTREC", cProtocol   )
			RecLock("SX6",.T.)
			SX6->X6_FIL     := xFilial("SX6")
			SX6->X6_VAR     := "XM_PROTREC"
			SX6->X6_TIPO    := "C"
			SX6->X6_DESCRIC := "Protocolo de recebimento de xml.."
			MsUnLock()
			PutMv("XM_PROTREC", cProtocol   )
		EndIf 
		/********************************/
		If !PutMv("XM_RECPORT", cPort   )
			RecLock("SX6",.T.)
			SX6->X6_FIL     := xFilial("SX6")
			SX6->X6_VAR     := "XM_RECPORT"
			SX6->X6_TIPO    := "C"
			SX6->X6_DESCRIC := "Porta de Recebimento."
			MsUnLock()
			PutMv("XM_RECPORT", cPort   )
		EndIf		
		/*******************************Aquuiiii*/
		If !PutMv("XM_POPTLS", Iif(lTLS     ,"S","N")   )
			RecLock("SX6",.T.)
			SX6->X6_FIL     := xFilial("SX6")
			SX6->X6_VAR     := "XM_POPTLS"
			SX6->X6_TIPO    := "C"
			SX6->X6_DESCRIC := "Informa se e-mail utiliza conexao segura TLS p/ POP."
			MsUnLock()
			PutMv("XM_POPTLS", Iif(lTLS     ,"S","N")   )
		EndIf

	EndIf

ElseIf nTipo == 3              

    If nOpc == 1 // Visualizar

		cServer  := Padr(GetNewPar("XM_POPIMAP",Space(50)),50)
		cLogin   := "" //Padr(GetNewPar("XM_LOGIN",Space(40)),40)
		cConta   := Padr(GetNewPar("XM_POPACCS",Space(50)),50)
		cPass    := Padr(Decode64(GetNewPar("XM_POPSPAS",Space(25))),25)
		lAuth    := GetNewPar("XM_POPAUT",Space(1))=="S"
		lSSL     := GetNewPar("XM_POPSSL",Space(1))=="S"                                                      
		lTLS     := GetNewPar("XM_POPTLS",Space(1))=="S"
		cProtocol:= GetNewPar("XM_PROTREC","1") 
		cPort    := Padr(GetNewPar("XM_RECPORT",Space(6)),6) 	
	
	ElseIf nOpc == 2 // Atualizar
         
		cServer  := aInfo[1]
		cLogin 	 := aInfo[2]
		cConta   := aInfo[3]
		cPass    := aInfo[4]
		lAuth    := aInfo[5]
		lSSL     := aInfo[6]
		cProtocol:= aInfo[7]
   		cPort    := aInfo[8]
		lTLS     := aInfo[9]  //aquuiiii

		If !PutMv("XM_POPIMAP", cServer ) 
			RecLock("SX6",.T.)
			SX6->X6_FIL     := xFilial("SX6")
			SX6->X6_VAR     := "XM_POPIMAP"
			SX6->X6_TIPO    := "C"
			SX6->X6_DESCRIC := "Endereço POP/IMAP de Recebimento de XML Fornecedor"
			MsUnLock()
			PutMv("XM_POPIMAP", cServer )
		EndIf
		/********************************
		If !PutMv("XM_LOGIN", cLogin      )
			RecLock("SX6",.T.)
			SX6->X6_FIL     := xFilial("SX6")
			SX6->X6_VAR     := "XM_LOGIN"
			SX6->X6_TIPO    := "C"
			SX6->X6_DESCRIC := "Conta de Email de Recebimento de XML Fornecedor."	
			MsUnLock()
			PutMv("XM_LOGIN", cLogin      )
		EndIf
		/********************************/
		If !PutMv("XM_POPACCS", cConta  )
			RecLock("SX6",.T.)
			SX6->X6_FIL     := xFilial("SX6")
			SX6->X6_VAR     := "XM_POPACCS"
			SX6->X6_TIPO    := "C"
			SX6->X6_DESCRIC := "Conta de Email de Recebimento de XML Servico."	
			MsUnLock()
			PutMv("XM_POPACCS", cConta  )
		EndIf	
		/********************************/
		If !PutMv("XM_POPSPAS", Encode64(AllTrim(cPass))  )
			RecLock("SX6",.T.)
			SX6->X6_FIL     := xFilial("SX6")
			SX6->X6_VAR     := "XM_POPSPAS"
			SX6->X6_TIPO    := "C"
			SX6->X6_DESCRIC := "Senha da Conta de Recebimento de XML Servico."
			MsUnLock()
			PutMv("XM_POPSPAS", Encode64(AllTrim(cPass))  )
		EndIf
		/********************************/
		If !PutMv("XM_POPAUT", Iif(lAuth,"S","N")   )
			RecLock("SX6",.T.)
			SX6->X6_FIL     := xFilial("SX6")
			SX6->X6_VAR     := "XM_POPAUT"
			SX6->X6_TIPO    := "C"
			SX6->X6_DESCRIC := "Informa se e-mail utiliza autenticação."
			MsUnLock()
			PutMv("XM_POPAUT", Iif(lAuth,"S","N")   )
		EndIf
		/********************************/
		If !PutMv("XM_POPSSL", Iif(lSSL     ,"S","N")   )
			RecLock("SX6",.T.)
			SX6->X6_FIL     := xFilial("SX6")
			SX6->X6_VAR     := "XM_POPSSL"
			SX6->X6_TIPO    := "C"
			SX6->X6_DESCRIC := "Informa se e-mail utiliza conexao segura."
			MsUnLock()
			PutMv("XM_POPSSL", Iif(lSSL     ,"S","N")   )
		EndIf
		/********************************/
		If !PutMv("XM_PROTREC", cProtocol   )
			RecLock("SX6",.T.)
			SX6->X6_FIL     := xFilial("SX6")
			SX6->X6_VAR     := "XM_PROTREC"
			SX6->X6_TIPO    := "C"
			SX6->X6_DESCRIC := "Protocolo de recebimento de xml.."
			MsUnLock()
			PutMv("XM_PROTREC", cProtocol   )
		EndIf 
		/********************************/
		If !PutMv("XM_RECPORT", cPort   )
			RecLock("SX6",.T.)
			SX6->X6_FIL     := xFilial("SX6")
			SX6->X6_VAR     := "XM_RECPORT"
			SX6->X6_TIPO    := "C"
			SX6->X6_DESCRIC := "Porta de Recebimento."
			MsUnLock()
			PutMv("XM_RECPORT", cPort   )
		EndIf		
		/*******************************Aquuiiii*/
		If !PutMv("XM_POPTLS", Iif(lTLS     ,"S","N")   )
			RecLock("SX6",.T.)
			SX6->X6_FIL     := xFilial("SX6")
			SX6->X6_VAR     := "XM_POPTLS"
			SX6->X6_TIPO    := "C"
			SX6->X6_DESCRIC := "Informa se e-mail utiliza conexao segura TLS p/ POP."
			MsUnLock()
			PutMv("XM_POPTLS", Iif(lTLS     ,"S","N")   )
		EndIf

	EndIf
EndIf

Aadd(aRet,cServer  ) // 01
Aadd(aRet,cLogin   ) // 02
Aadd(aRet,cConta   ) // 03
Aadd(aRet,cPass    ) // 04
Aadd(aRet,lAuth    ) // 05
Aadd(aRet,lSSL     ) // 06
Aadd(aRet,cProtocol) // 07
Aadd(aRet,cPort    ) // 08
Aadd(aRet,lTLS     ) // 09

Return(aRet)

     

User Function XmlInfoX(cAliasXML,lEmpty,cTpret,lImpTudo,lDemo)

//Local cPerg   := "HFXMLR00" 
//Local lperg   := Pergunte(cPerg,.F.)
Local Nx      := 0
//Local nOrdem
Local cWhere  := ""
Local cTabela := ""
Local cOrder  := ""
//Local cLinCab := ""     
Local cFilDe  := MV_PAR01
Local cFilAte := MV_PAR02
Local cDtIni  := DTos(MV_PAR03)
Local cDtFim  := DTos(MV_PAR04)
Local cSerIni := MV_PAR05
Local cSerFim := MV_PAR06
Local cNFIni  := MV_PAR07
Local cNFFim  := MV_PAR08   
Local cEspecP := MV_PAR09//"('SPED','CTE')" 
Local cForIni := MV_PAR10
Local cForFim := MV_PAR11
Local cLojaIni:= MV_PAR12
Local cLojaFim:= MV_PAR13
Local nBaseNf := MV_PAR14
Local aEspecP := Separa(cEspecP,",",.F.)
Local cEmIni  := DTos(MV_PAR16)
Local cEmFim  := DTos(MV_PAR17)
Local aRet    := {}
Local nLimArray := 1000
Local nDNfXml := MV_PAR18
Local nRegSf1 := 0
Local nRegZbz := 0
Local nTotXml := 0
Local nTotSf1 := 0
Local nQtdXml := 0
Local nQtdSd1 := 0
Local cTips   := "" //ENEO includo F1_TIPO em 27/08/2015
Local cManif  := ""
Private xZBZ  	  := GetNewPar("XM_TABXML","ZBZ")
Private xZBZ_ 	  := iif(Substr(xZBZ,1,1)=="S", Substr(xZBZ,2,2), Substr(xZBZ,1,3)) + "_"
Private xZBA  	  := GetNewPar("XM_TABAMA2","ZBA")
Private xZBA_ 	  := iif(Substr(xZBA,1,1)=="S", Substr(xZBA,2,2), Substr(xZBA,1,3)) + "_"
Private xZBE      := GetNewPar("XM_TABEVEN","ZBE")
Private xZBE_     := iif(Substr(xZBE,1,1)=="S", Substr(xZBE,2,2), Substr(xZBE,1,3)) + "_"
Private xZBC      := GetNewPar("XM_TABCAC","ZBC")
Private xZBC_     := iif(Substr(xZBC,1,1)=="S", Substr(xZBC,2,2), Substr(xZBC,1,3)) + "_"
Private xZBO      := GetNewPar("XM_TABOCOR","ZBO"), xRetSEF := ""
Private xZBO_     := iif(Substr(xZBO,1,1)=="S", Substr(xZBO,2,2), Substr(xZBO,1,3)) + "_"
Private xZBI      := GetNewPar("XM_TABIEXT","ZBI")
Private xZBI_     := iif(Substr(xZBI,1,1)=="S", Substr(xZBI,2,2), Substr(xZBI,1,3)) + "_"
Private aHfCloud  := {"0","0"," ","Token",{}}  //CRAUMDE - '0' Não integrar, na posição 1
Private cSF1   := GetNextAlias() 
Private lSharedA1:= U_IsShared("SA1")
Private lSharedA2:= U_IsShared("SA2") 
Private nFormNfe  := Val(GetNewPar("XM_FORMNFE","6"))
Private nFormCTe  := Val(GetNewPar("XM_FORMCTE","6"))
Default cTpret    := "1"
Default lImpTudo  := .F.
If Len(aEspecP)>0
	nTamesp := Len(aEspecP)
	cEspecP := "("
	For Nx := 1 To nTamesp
    	cEspecP += "'"+AllTrim(aEspecP[Nx])+"'"	
		If Nx < nTamesp
			cEspecP += ","
		EndIf
	Next
	cEspecP += ")"
Else
	cEspecP := "('SPED','CTE')"
EndIf

If cTpret == "1" // Tabela Temporária

	aCampos := {}
	AADD(aCampos,{"F1_FILIAL"	,"C" ,	FWGETTAMFILIAL	,0 })// alterado pois a CIEE tem a filial de 4 posições, Analista Alexandro e Rodrigo data 04/07/2016
	AADD(aCampos,{"F1_TIPO"		,"C" ,	001	,0 })	
	AADD(aCampos,{"F1_FORNECE"	,"C" ,	006	,0 })
	AADD(aCampos,{"F1_LOJA"		,"C" ,	002	,0 })
	AADD(aCampos,{"F1_ESPECIE"	,"C" ,	005	,0 })
	AADD(aCampos,{"F1_SERIE"	,"C" ,	003	,0 })
	AADD(aCampos,{"F1_DOC"      ,"C" ,	009	,0 })
	AADD(aCampos,{"F1_EMISSAO"	,"D" ,	008	,0 })
	AADD(aCampos,{"F1_DTDIGIT"	,"D" ,	008	,0 })
	AADD(aCampos,{"F1_MANIF"	,"C" ,	001 ,0 })
	AADD(aCampos,{"F1_VALBRUT"	,"N" ,	017	,2 })
	AADD(aCampos,{"F1_CGC"		,"C" ,	014	,0 })
	AADD(aCampos,{"F1_NOME"		,"C" ,	030	,0 })
	AADD(aCampos,{"F1_FONE"		,"C" ,	020	,0 })
	AADD(aCampos,{"F1_EMAIL"	,"C" ,	030	,0 })
	AADD(aCampos,{"F1_STXML"	,"C" ,	001	,0 })
	AADD(aCampos,{"F1_CHVNFE"	,"C" ,	044	,0 })
	AADD(aCampos,{"F1_CFO"		,"C" ,	004	,0 })
	AADD(aCampos,{"XM_VALBRUT"	,"N" ,	017	,2 })
	AADD(aCampos,{"D1_QTITEM"	,"N" ,	017	,2 })
	AADD(aCampos,{"XM_QTITEM"	,"N" ,	017	,2 })

	cArqEmp	:=	CriaTrab(aCampos)
	
	dbUseArea(.T.,__LocalDrive,cArqEmp,cAliasXML,.T.,.F.)
	       
	DbSelectArea(cAliasXML)
	cIndEmp		:=CriaTrab (NIL, .F.)
	cChave      := "F1_FILIAL+F1_FORNECE+F1_LOJA+F1_TIPO+F1_DOC+F1_SERIE" //ENEO includo F1_TIPO em 27/08/2015
	cFiltroTmp	:= ""
  
	IndRegua(cAliasXML, cIndEmp, cChave,, cFiltroTmp)
	DbSetIndex(cIndEmp+OrdBagExt ())
	DbSetOrder(1)	
	DbGoTop()   
	
EndIf

//FR - 12/06/2020 - Tratativa para licença Demo:
If lDemo
	If ( (Stod(cDtFim) - Stod(cDtIni)) > 30 .or. ( StoD(cEmFim) - StoD(cEmIni) ) > 30 )
		MsgInfo("Esta é Uma Licença de Demonstração, o Período para Consulta Será Limitado a Até 30 (Trinta) Dias!")		
	Endif
Endif
   

if nBaseNf == 1

	cWhere := "% SF1.D_E_L_E_T_ <> '*' "
	If !lDemo
		cWhere += " AND  SF1.F1_DTDIGIT>='"+cDtIni+"' AND  SF1.F1_DTDIGIT<='"+cDtFim+"' AND SF1.F1_ESPECIE IN "+cEspecP 
	Else
		cWhere += " AND  SF1.F1_DTDIGIT>='"+Dtos(Date() -30)+"' AND  SF1.F1_DTDIGIT<='"+ Dtos(Date())+"' AND SF1.F1_ESPECIE IN "+cEspecP
	Endif
	 
	// Ignorar Devolução e Beneficiamento - Excluir quando implementar tratamento para devolução
	// cWhere += " AND SF1.F1_TIPO NOT IN ('D','B') "	
	//------------------
	If !lDemo
		cWhere += " AND  SF1.F1_EMISSAO>='"+cEmIni+"' AND SF1.F1_EMISSAO<='"+cEmFim+"'"
	Else
		cWhere += " AND  SF1.F1_EMISSAO>='"+ Dtos(Date() - 30)+"' AND SF1.F1_EMISSAO<='"+ Dtos(Date())+"'"
	Endif
	cWhere += " AND  SF1.F1_FORMUL <> 'S' "	
	cWhere += " AND  SF1.F1_FILIAL>='"+cFilDe+"' AND  SF1.F1_FILIAL<='"+cFilAte+"'"	
	cWhere += " AND  SF1.F1_DOC>='"+cNFIni+"' AND  SF1.F1_DOC<='"+cNFFim+"'"
	cWhere += " AND  SF1.F1_SERIE>='"+cSerIni+"' AND  SF1.F1_SERIE<='"+cSerFim+"'"						               
	cWhere += " AND  SF1.F1_FORNECE>='"+cForIni+"' AND  SF1.F1_FORNECE<='"+cForFim+"' "						               
	cWhere += " AND  SF1.F1_LOJA>='"+cLojaIni+"' AND  SF1.F1_LOJA<='"+cLojaFim+"' %"						               
    cOrder := "%( F1_FILIAL,F1_DTDIGIT,F1_DOC,F1_SERIE )%"

	BeginSql Alias cSF1
	
		SELECT	F1_FILIAL,F1_DOC,F1_SERIE,F1_FORNECE,F1_LOJA,F1_TIPO,F1_ESPECIE, ' ' as F1_STXML,
			F1_EMISSAO,	F1_DTDIGIT,F1_CHVNFE,F1_VALBRUT,R_E_C_N_O_, ' ' as F1_MANIF 
			FROM %Table:SF1% SF1
			WHERE %Exp:cWhere%  
    		ORDER BY F1_FILIAL,F1_FORNECE,F1_LOJA,F1_TIPO,F1_DOC,F1_SERIE,F1_DTDIGIT //ENEO includo F1_TIPO em 27/08/2015
	EndSql      
    		//SF1.%notdel%

Else

	cTabela:= "%"+RetSqlName(xZBZ)+"%"
	cCampos	:="%"+xZBZ_+"FILIAL as F1_FILIAL,  "+xZBZ_+"NOTA   as F1_DOC,     "+xZBZ_+"SERIE as F1_SERIE, "+;
	              xZBZ_+"CODFOR as F1_FORNECE, "+xZBZ_+"LOJFOR as F1_LOJA,    "+xZBZ_+"TPDOC as F1_TIPO, "+;
	              xZBZ_+"MODELO as F1_ESPECIE, "+xZBZ_+"PRENF  as F1_STXML,   "+xZBZ_+"PROTC, "+;
	              xZBZ_+"DTNFE  as F1_EMISSAO, "+xZBZ_+"DTRECB as F1_DTDIGIT, "+xZBZ_+"CHAVE as F1_CHVNFE, "+;
	              xZBZ_+"CFO  as F1_CFO, "+;
	              xZBZ_+"VLBRUT as F1_VALBRUT, R_E_C_N_O_, " + xZBZ_+"MANIF as F1_MANIF %"

	cWhere := "% ZBZ.D_E_L_E_T_ <> '*' "
	cWhere += " AND  ZBZ."+xZBZ_+"DTRECB>='"+cDtIni+"' AND  ZBZ."+xZBZ_+"DTRECB<='"+cDtFim+"' "
	// Ignorar Devolução e Beneficiamento - Excluir quando implementar tratamento para devolução
	// cWhere += " AND ZBZ."+xZBZ_+"TPDOC NOT IN ('D','B') "	
	//------------------
	if ! lImpTudo
		cWhere += " AND  ZBZ."+xZBZ_+"INDRUR<='0'"   //Ignorar Produrot Rular
	endif
	If !lDemo
		cWhere += " AND  ZBZ."+xZBZ_+"DTNFE>='"+cEmIni+   "' AND  ZBZ."+xZBZ_+"DTNFE<='"+cEmFim+"'"
	Else
		cWhere += " AND  ZBZ."+xZBZ_+"DTNFE>='"+ Dtos(Date()-30)+   "' AND  ZBZ."+xZBZ_+"DTNFE<='"+ Dtos(Date())+"'"
	Endif
	cWhere += " AND  ZBZ."+xZBZ_+"FILIAL>='"+cFilDe+  "' AND  ZBZ."+xZBZ_+"FILIAL<='"+cFilAte+"'"
	cWhere += " AND  ZBZ."+xZBZ_+"NOTA>='"+cNFIni+    "' AND  ZBZ."+xZBZ_+"NOTA<='"+cNFFim+"'"
	cWhere += " AND  ZBZ."+xZBZ_+"SERIE>='"+cSerIni+  "' AND  ZBZ."+xZBZ_+"SERIE<='"+cSerFim+"'"
	cWhere += " AND  ZBZ."+xZBZ_+"CODFOR>='"+cForIni+ "' AND  ZBZ."+xZBZ_+"CODFOR<='"+cForFim+"' "
	cWhere += " AND  ZBZ."+xZBZ_+"LOJFOR>='"+cLojaIni+"' AND  ZBZ."+xZBZ_+"LOJFOR<='"+cLojaFim+"' %"

    cOrder := "%( F1_FILIAL,F1_DTDIGIT,F1_DOC,F1_SERIE )%"

	BeginSql Alias cSF1
	
		SELECT %Exp:cCampos%
			FROM %Exp:cTabela% ZBZ
			WHERE %Exp:cWhere%   
    		ORDER BY F1_FILIAL,F1_FORNECE,F1_LOJA,F1_TIPO,F1_DOC,F1_SERIE,F1_DTDIGIT //ENEO includo F1_TIPO em 27/08/2015
	EndSql
	//ZBZ.%notdel%

Endif

DbSelectArea(xZBZ)
DbSetOrder(6) 

DbSelectArea(cSF1)

DbGoTop()

While (cSF1)->(!EOF())
	cFilProc := (cSF1)->F1_FILIAL
	While (cSF1)->F1_FILIAL == cFilProc .And. (cSF1)->(!EOF())

		if nBaseNf == 2
			cESP := iif(alltrim((cSF1)->F1_ESPECIE) == "55", "SPED" ,;
				    iif(alltrim((cSF1)->F1_ESPECIE) == "57", "CTE", ;
				    iif(alltrim((cSF1)->F1_ESPECIE) == "65", "NFS", (cSF1)->F1_ESPECIE )))
			If ! cESP $ cEspecP
			   (cSF1)->(DbSkip())
			   Loop
			EndIf
		Endif		
		lFirst := .F.
		If (cSF1)->F1_TIPO $ "D|B"
			DbSelectArea("SA1")
			dbsetorder(1)
			cFilSeek := Iif(lSharedA1,xFilial("SA1"),cFilProc)
			if DbSeek(cFilSeek+(cSF1)->F1_FORNECE+(cSF1)->F1_LOJA)
				cCnPjF   := SA1->A1_CGC
				cNome    := SA1->A1_NOME
				cTel     := SA1->A1_DDD + " " + SA1->A1_TEL
				cMail    := SA1->A1_EMAIL
			Else
				cCnPjF   := SA1->A1_CGC
				cNome    := SA1->A1_NOME
				cTel     := SA1->A1_DDD + " " + SA1->A1_TEL
				cMail    := SA1->A1_EMAIL
				pegardoXml( (cSF1)->F1_CHVNFE, @cCnPjF, @cNome, @cTel, @cMail )
			EndIf
		Else            
			DbSelectArea("SA2")
			dbsetorder(1)
			cFilSeek := Iif(lSharedA2,xFilial("SA2"),cFilProc)
			IF DbSeek(cFilSeek+(cSF1)->F1_FORNECE+(cSF1)->F1_LOJA)
				cCnPjF   := SA2->A2_CGC 
				cNome    := SA2->A2_NOME
				cTel     := SA2->A2_DDD + " " + SA2->A2_TEL
				cMail    := SA2->A2_EMAIL
			Else
				cCnPjF   := SA2->A2_CGC 
				cNome    := SA2->A2_NOME
				cTel     := SA2->A2_DDD + " " + SA2->A2_TEL
				cMail    := SA2->A2_EMAIL
				pegardoXml( (cSF1)->F1_CHVNFE, @cCnPjF, @cNome, @cTel, @cMail )
			Endif
			
		EndIf        
		       		
		cCodFor := (cSF1)->F1_FORNECE+(cSF1)->F1_LOJA       
		cTips   := (cSF1)->F1_TIPO //ENEO includo F1_TIPO em 27/08/2015       
	    While cTips == (cSF1)->F1_TIPO .And. (cSF1)->F1_FORNECE+(cSF1)->F1_LOJA == cCodFor .And. (cSF1)->F1_FILIAL == cFilProc .And. (cSF1)->(!EOF()) //ENEO includo F1_TIPO em 27/08/2015

			if nBaseNf == 2
				cESP := iif(alltrim((cSF1)->F1_ESPECIE) == "55", "SPED" ,;
					    iif(alltrim((cSF1)->F1_ESPECIE) == "57", "CTE", ;
					    iif(alltrim((cSF1)->F1_ESPECIE) == "65", "NFS", (cSF1)->F1_ESPECIE )))
				If ! cESP $ cEspecP
				   (cSF1)->(DbSkip())
				   Loop
				EndIf
			Endif		
			cStatXml:= " " 
			cManif  := ""
			if nBaseNf == 1
				nRegSf1 := (cSF1)->R_E_C_N_O_
				lSeekNf := BuscaXMl(cFilProc,@cStatXml,cCnPjF,1,@nRegZbz,@cManif)
				if Mv_Par20 == 2
					if cStatXml <> "X"
						lSeekNF := .F.
					endif
				elseif Mv_Par20 == 3
					if cStatXml == "X"
						lSeekNf := .F.
					endif
				endif
				
			else
			
				nRegZbz := (cSF1)->R_E_C_N_O_
				cManif := (cSF1)->F1_MANIF
				lSeekNf := BuscaNFE(cFilProc,@cStatXml,cCnPjF,1,@nRegSf1)
				if Mv_Par20 == 2
					if .not. Empty( (cSF1)->&(xZBZ_+"PROTC") )
						lSeekNf := .F.
					else
						cStatXml := (cSF1)->F1_STXML   //ZBZ_PRENF
					endif
					if cStatXml == "X"
						lSeekNf := .T.
					endif
				elseif Mv_Par20 == 3
					if .not. Empty( (cSF1)->&(xZBZ_+"PROTC") )
						lSeekNf := .F.
					else
						cStatXml := (cSF1)->F1_STXML   //ZBZ_PRENF
					endif
					if cStatXml == "X"
						lSeekNf := .F.
					else
						lSeekNf := .T.
					endif
				else
					if .not. Empty( (cSF1)->&(xZBZ_+"PROTC") )
						cStatXml := "X"
					else
						cStatXml := (cSF1)->F1_STXML   //ZBZ_PRENF
					endif
				endif
			endif
			
			if lImpTudo
				if lSeekNf
					cStatXml := "+"
				Else
					cStatXml := "-"
				Endif
				lSeekNf := .F.
			endif
			
			If !lSeekNf	//.or. ( lSeekNf .and. cStatXml $ "B" )
			    If cTpret == "1" // Retorna em tabela Temporária
					RecLock(cAliasXML,.T.)
					(cAliasXML)->F1_FILIAL	:= (cSF1)->F1_FILIAL
					(cAliasXML)->F1_FORNECE	:= (cSF1)->F1_FORNECE
					(cAliasXML)->F1_LOJA	:= (cSF1)->F1_LOJA
					(cAliasXML)->F1_TIPO    := (cSF1)->F1_TIPO    //ENEO includo F1_TIPO em 27/08/2015  
					(cAliasXML)->F1_ESPECIE	:= iif(alltrim((cSF1)->F1_ESPECIE) == "55", "SPED" ,;
					                           iif(alltrim((cSF1)->F1_ESPECIE) == "57", "CTE", (cSF1)->F1_ESPECIE ))
					(cAliasXML)->F1_SERIE	:= (cSF1)->F1_SERIE
					(cAliasXML)->F1_DOC		:= (cSF1)->F1_DOC
					(cAliasXML)->F1_EMISSAO := Stod((cSF1)->F1_EMISSAO)
					(cAliasXML)->F1_DTDIGIT := Stod((cSF1)->F1_DTDIGIT)
					if (cSF1)->F1_VALBRUT == 0 .And. nBaseNf == 2 .And. nRegZbz > 0
						(cAliasXML)->F1_VALBRUT := hfVerBrXml( nRegZbz )
					Else
						(cAliasXML)->F1_VALBRUT := (cSF1)->F1_VALBRUT
					EndIF
				 	(cAliasXML)->F1_CGC     := cCnPjF
					(cAliasXML)->F1_NOME    := cNome 
					(cAliasXML)->F1_FONE    := AllTrim(cTel)
					(cAliasXML)->F1_EMAIL   := AllTrim(cMail)
					(cAliasXML)->F1_STXML   := cStatXml
					(cAliasXML)->F1_CHVNFE  := (cSF1)->F1_CHVNFE
					(cAliasXML)->F1_MANIF   := cManif
				    MsUnlock()
													    
			    ElseIf cTpret == "2" // Retorna em Array
			    
				    AADD(aRet,{ (cSF1)->F1_FILIAL   ,;
				    			(cSF1)->F1_FORNECE  ,;
				    			(cSF1)->F1_LOJA     ,;
				    			cNome				,;
				    			cCnPjF				,;
				    			cTel				,;
				    			cMail				,;
				    			(cSF1)->F1_ESPECIE	,;
								(cSF1)->F1_SERIE	,;
				    			(cSF1)->F1_DOC		,;
				    			ConvDate(1 , (cSF1)->F1_EMISSAO),;
				    			ConvDate(1 , (cSF1)->F1_DTDIGIT),;
				    			Transform((cSF1)->F1_VALBRUT,"@E 99,999,999.99"),;
			                    }) 
		 			If Len(aRet) >= nLimArray		 
						Return(aRet)	
					EndIf
				EndIf			                    
			ElseIf cTpret == "1" .And. nDNfXml > 1
				if DifNfXml( nDNfXml, nRegSf1, nRegZbz, @nTotXml, @nTotSf1, @nQtdXml, @nQtdSd1 )
					if nTotXml <> nTotSf1 .And. nQtdXml <> nQtdSd1
						cStatXml := "4"
					Elseif nQtdXml <> nQtdSd1
						cStatXml := "3"
					Elseif nTotXml <> nTotSf1
						cStatXml := "2"
					Else
						cStatXml := "1"
					Endif
					RecLock(cAliasXML,.T.)
					(cAliasXML)->F1_FILIAL	:= (cSF1)->F1_FILIAL
					(cAliasXML)->F1_FORNECE	:= (cSF1)->F1_FORNECE
					(cAliasXML)->F1_LOJA	:= (cSF1)->F1_LOJA
					(cAliasXML)->F1_TIPO    := (cSF1)->F1_TIPO    //ENEO includo F1_TIPO em 27/08/2015  
					(cAliasXML)->F1_ESPECIE	:= iif(alltrim((cSF1)->F1_ESPECIE) == "55", "SPED" ,;
					                           iif(alltrim((cSF1)->F1_ESPECIE) == "57", "CTE", (cSF1)->F1_ESPECIE ))
					(cAliasXML)->F1_SERIE	:= (cSF1)->F1_SERIE
					(cAliasXML)->F1_DOC		:= (cSF1)->F1_DOC
					(cAliasXML)->F1_EMISSAO := Stod((cSF1)->F1_EMISSAO)
					(cAliasXML)->F1_DTDIGIT := Stod((cSF1)->F1_DTDIGIT)
					(cAliasXML)->F1_VALBRUT := (cSF1)->F1_VALBRUT
				 	(cAliasXML)->F1_CGC     := cCnPjF
					(cAliasXML)->F1_NOME    := cNome
					(cAliasXML)->F1_FONE    := AllTrim(cTel)
					(cAliasXML)->F1_EMAIL   := AllTrim(cMail)
					(cAliasXML)->F1_STXML   := cStatXml
					(cAliasXML)->XM_VALBRUT := nTotXml
					(cAliasXML)->D1_QTITEM  := nQtdSd1
					(cAliasXML)->XM_QTITEM  := nQtdXml
					(cAliasXML)->F1_CHVNFE  := (cSF1)->F1_CHVNFE
				    MsUnlock()
				EndIf
			EndIf
				
		   (cSF1)->(DbSkip())
		   if Empty( cCodFor )
		   		Exit
		   endif
		EndDo       
	EndDo 

EndDo  
(cSF1)->( dbCloseArea() )  //ENEO includo F1_TIPO em 27/08/2015
Return(aRet)


Static Function pegardoXml( cChave, cCnPjF, cNome, cTel, cMail )

Local aArea := GetArea()
Local cErro:= "", cWarning := ""
Local cXml := ""
Local cTGP := ""
Private oXmlNf, cTagAux

dbSelectArea( xZBZ )
DbSetorder(3) // ZBZ_CHAVE
If DbSeek( cChave )
	cXml   := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML")))
	cTGP   := iif( substr( cChave,21,2 ) = "57", "CTE", "NFE" )
	cTAG   := iif( substr( cChave,21,2 ) = "57", "CTE", "NFE" )

	if Len(cXml) >= 65534
		oXmlNf := U_PARSGDE( cXml, @cErro, @cWarning )
	Else
		oXmlNf := XmlParser( cXml, "_", @cErro, @cWarning )
	endif

	if oXmlNf <> NIL .And. Empty(cErro)
		If Type("oXmlNf:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_EMIT:_CNPJ:TEXT") == "U"
			cTagAux := "oXmlNf:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_EMIT:_CPF:TEXT"  
		Else 
			cTagAux := "oXmlNf:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_EMIT:_CNPJ:TEXT"
		EndIf
		If Type( cTagAux ) <> "U"
			cCnPjF  := &(cTagAux)
		EndIF

		cTagAux := "oXmlNf:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_EMIT:_XNOME:TEXT"  
		If Type( cTagAux ) <> "U"
			cNome  := &(cTagAux)
		Endif

		cTagAux := "oXmlNf:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_EMIT:_ENDEREMIT:_FONE:TEXT"  
		If Type( cTagAux ) <> "U"
			cTel  := &(cTagAux)
		Endif

		cTagAux := "oXmlNf:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_EMIT:_EMAIL:TEXT"  
		If Type( cTagAux ) <> "U"
			cMail  := &(cTagAux)
		Endif

	endif
	
	cCnPjF := Substr( cChave, 7, 14 )
Endif

If Empty( cCnPjF ) .And. Len( AllTrim( cChave ) ) = 44
	cCnPjF := Substr( cChave, 7, 14 )
Endif

oXmlNf := NIL
//DelClassIntf()

RestArea( aArea )
Return( NIL )


Static Function hfVerBrXml( nRegZbz )

Local nRet := 0
Local cXml := ""
Local aArea := GetArea()
Local cErro:= "", cWarning := ""
Private oXmlNf, cTagTot

dbSelectArea( xZBZ )
DbGoTo( nRegZbz )
cXml := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML")))

if Len(cXml) >= 65534
	oXmlNf := U_PARSGDE( cXml, @cErro, @cWarning )
Else
	oXmlNf := XmlParser( cXml, "_", @cErro, @cWarning )
endif

If oXmlNf == NIL .Or. .NOT. Empty( cErro )
	oXmlNf := NIL
	//DelClassIntf()
	RestArea( aArea )
	Return( nRet )
EndIf

cTagTot    := "oXmlNf:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VNF:TEXT"
If Type(cTagTot)<> "U"
	nRet := Val(&(cTagTot))
Else
	cTagTot    := "oXmlNf:_CTEPROC:_CTE:_INFCTE:_VPREST:_VTPREST:TEXT"
	If Type(cTagTot)<> "U"
		nRet   := Val(&(cTagTot))
	Else
		nRet   := 0
	EndIf
EndIf

oXmlNf := NIL
//DelClassIntf()
RestArea( aArea )
Return( nRet )
             

Static Function BuscaXml(cFilProc,cStatXml,cCnPjF,nModo,nReg,cManif)

Local lRet     := .F.
Local aArea    := GetArea()
Local lSeek    := .F. 
Local cModelo  := ""
//Local cNFSeek  := ""
Local cKeySeek := "" 
Local cNotaSeek:= ""
Local cSrSem0  := ""
Local cEspec55 := AllTrim(MV_PAR15) //"('SPED','NFE')" 
//Fadiga para os loucos da hocrin
if AllTrim(cEspec55) == "55"
//	cEspec55 := "('SPED','NFE')"
endif
Private cEspecNfse:= AllTrim(GetNewPar("XM_ESP_NFS","NFS")) // NFCE_03 16/05
Private nFormXML  := 6 
Private cModelo   := Iif( AllTrim((cSF1)->F1_ESPECIE) $ iif( empty(cEspec55), "SPED", cEspec55) ,"55",;
                     Iif( AllTrim((cSF1)->F1_ESPECIE) == "CTE","57",;
                     IIF( AllTrim((cSF1)->F1_ESPECIE) == cEspecNfse,"RP","65" ))) //NFCE_01 22/02
Default nModo     := 1

If cModelo == "55"  .or. cModelo == "65"  //NFCE_01 22/02
 	cPref    := "NF-e"
	cTAG     := "NFE"
	nFormXML := nFormNfe
ElseIf cModelo == "57"
 	cPref    := "CT-e"                             
	cTAG     := "CTE"
	nFormXML := nFormCte
ElseIf cModelo == "RP"
 	cPref    := "NFS-e"
	cTAG     := "NFSE"
	nFormXML := nFormNfe
EndIf

/*
If (cSF1)->F1_TIPO $ "D|B"
	cFilSeek := Iif(lSharedA1,"  ",cFilProc)
	cCnPjF   := Posicione("SA1",1,cFilSeek+(cSF1)->F1_FORNECE+(cSF1)->F1_LOJA,"A1_CGC")
Else
	cFilSeek := Iif(lSharedA2,"  ",cFilProc)
	cCnPjF   := Posicione("SA2",1,cFilSeek+(cSF1)->F1_FORNECE+(cSF1)->F1_LOJA,"A2_CGC")
EndIf        
*/       


If nModo == 1

	DbSelectArea(xZBZ) 
	DbSetorder(6) // "ZBZ_FILIAL+ZBZ_MODELO+ZBZ_NOTA+ZBZ_SERIE+ZBZ_CNPJ"

	Do While .T.
	
	    lSeek     := .F.
   		cNotaSeek := Iif(nFormXML > 0,StrZero(Val((cSF1)->F1_DOC),nFormXML),AllTrim(Str(Val((cSF1)->F1_DOC))))
		cKeySeek  := (cSF1)->F1_FILIAL+cModelo+cNotaSeek+(cSF1)->F1_SERIE+cCnPjF
		cSrSem0   := Substr( ALLTRIM( Str( Val( (cSF1)->F1_SERIE ) ) ) + space( 50 ), 1, len( (xZBZ)->&(xZBZ_+"SERIE") ) )
 
 		lSeek := (xZBZ)->(DbSeek(cKeySeek))
       
	    If !lSeek
			cNotaSeek := Padr(AllTrim(Str(Val((cSF1)->F1_DOC))),9)
			cKeySeek  := (cSF1)->F1_FILIAL+cModelo+cNotaSeek+(cSF1)->F1_SERIE+cCnPjF
	        lSeek := (xZBZ)->(DbSeek(cKeySeek))
	    EndIf

	    If !lSeek
	   		cNotaSeek :=  Padr(StrZero(Val((cSF1)->F1_DOC),6),9)
	    	cKeySeek  := (cSF1)->F1_FILIAL+cModelo+cNotaSeek+(cSF1)->F1_SERIE+cCnPjF
	        lSeek := (xZBZ)->(DbSeek(cKeySeek))
	    EndIf
 
	    If !lSeek
	   		cNotaSeek :=  Padr(StrZero(Val((cSF1)->F1_DOC),9),9)
	       	cKeySeek  := (cSF1)->F1_FILIAL+cModelo+cNotaSeek+(cSF1)->F1_SERIE+cCnPjF
	        lSeek := (xZBZ)->(DbSeek(cKeySeek))
	 	EndIf

	    IF !lSeek
	   		cNotaSeek := Iif(nFormXML > 0,StrZero(Val((cSF1)->F1_DOC),nFormXML),AllTrim(Str(Val((cSF1)->F1_DOC))))
			cKeySeek  := (cSF1)->F1_FILIAL+cModelo+cNotaSeek+cSrSem0+cCnPjF
			lSeek := (xZBZ)->(DbSeek(cKeySeek))
		ENDIF
       
	    IF !lSeek
			cNotaSeek := Padr(AllTrim(Str(Val((cSF1)->F1_DOC))),9)
			cKeySeek  := (cSF1)->F1_FILIAL+cModelo+cNotaSeek+cSrSem0+cCnPjF
	        lSeek := (xZBZ)->(DbSeek(cKeySeek))
	    ENDIF

	    IF !lSeek
	   		cNotaSeek :=  Padr(StrZero(Val((cSF1)->F1_DOC),6),9)
	    	cKeySeek  := (cSF1)->F1_FILIAL+cModelo+cNotaSeek+cSrSem0+cCnPjF
	        lSeek := (xZBZ)->(DbSeek(cKeySeek))
	    ENDIF
 
	    IF !lSeek
	   		cNotaSeek :=  Padr(StrZero(Val((cSF1)->F1_DOC),9),9)
	       	cKeySeek  := (cSF1)->F1_FILIAL+cModelo+cNotaSeek+cSrSem0+cCnPjF
	        lSeek := (xZBZ)->(DbSeek(cKeySeek))
	 	ENDIF
	 	
	 	if !lSeek  //Fadigar pela Chave
			DbSelectArea(xZBZ) 
			DbSetorder(9) // "ZBZ_FILIAL+ZBZ_CHAVE", poderia ser 3, mas se estiver em filial errada não pode aparecer.
	       	cKeySeek  := (cSF1)->F1_FILIAL+(cSF1)->F1_CHVNFE
	        lSeek := (xZBZ)->(DbSeek(cKeySeek))
			DbSelectArea(xZBZ) 
			DbSetorder(6) // "ZBZ_FILIAL+ZBZ_MODELO+ZBZ_NOTA+ZBZ_SERIE+ZBZ_CNPJ"
	 	endif
	 	
	 	if lSeek
	 		Exit //Se econtrou ja cai fora
	 	EndIf
	 	
	 	if cModelo $ "65,RP,57"
	 		Exit
	 	EndIf
	 	
	 	cModelo := "65"  //A especie SPED utiliza tanto para 55 como 65, então se não encontrou 55 procura o 65 para depois sair
	
	EndDO

	If lSeek 
		cStatXml := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF")))
		nReg     := (xZBZ)->( Recno() )
		lRet     := .T.
		cManif   := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MANIF")))
	EndIf
	
ElseIf nModo == 2

	lContinua := .T.
	cKeySeek  := (cSF1)->F1_FILIAL+cCnPjF
	DbSelectArea(xZBZ) 
	DbSetorder(1) // ZBZ_FILIAL+ZBZ_CNPJ+ZBZ_CHAVE+ZBZ_DTRECB
    If DbSeek(cKeySeek)
		While (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))) + (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))) == cKeySeek .And. lContinua .And. (xZBZ)->(!Eof())
		    If Val((cSF1)->F1_DOC) == Val((xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA")))) .And. Val((cSF1)->F1_SERIE) == Val((xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE")))) .And. (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE"))) <> "F"                            
				nReg := (xZBZ)->( Recno() )
				lRet := .T.
				lContinua := .F.
			EndIf	
			(xZBZ)->(DbSkip())
		EndDo
		    
    Else
    
    EndIf

EndIf
                       
RestArea(aArea)

Return(lRet)


Static Function BuscaNFE(cFilProc,cStatXml,cCnPjF,nModo,nReg)

Local lRet        := .F.
Local aArea       := GetArea()
Local lSeek       := .F. 
Local cModelo     := ""
//Local cNFSeek     := ""
Local cKeySeek    := "" 
Local cNotaSeek	  := ""
Private nFormXML  := 6 
Private cModelo   := AllTrim((cSF1)->F1_ESPECIE)
Default nModo     := 1     

If cModelo == "55" .or. cModelo == "65"  //NFCE_01 22/02
 	cPref    := "NF-e"                             
	cTAG     := "NFE"
	nFormXML := nFormNfe
ElseIf cModelo == "57"
 	cPref    := "CT-e"                             
	cTAG     := "CTE"
	nFormXML := nFormCte
EndIf

If nModo == 1

	DbSelectArea("SF1") 
	DbSetorder(1) // "F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO"
	
    lSeek := .F.
   	cNotaSeek := Iif(nFormXML > 0,StrZero(Val((cSF1)->F1_DOC),nFormXML),AllTrim(Str(Val((cSF1)->F1_DOC))))
	cKeySeek  := (cSF1)->F1_FILIAL+cNotaSeek+(cSF1)->F1_SERIE+(cSF1)->F1_FORNECE+(cSF1)->F1_LOJA+(cSF1)->F1_TIPO
 
	lSeek := SF1->(DbSeek(cKeySeek))
       
    If !lSeek
		cNotaSeek := Padr(AllTrim(Str(Val((cSF1)->F1_DOC))),9)
		cKeySeek  := (cSF1)->F1_FILIAL+cNotaSeek+(cSF1)->F1_SERIE+(cSF1)->F1_FORNECE+(cSF1)->F1_LOJA+(cSF1)->F1_TIPO
        lSeek := SF1->(DbSeek(cKeySeek))
    EndIf

    If !lSeek
   		cNotaSeek :=  Padr(StrZero(Val((cSF1)->F1_DOC),6),9)
    	cKeySeek  := (cSF1)->F1_FILIAL+cNotaSeek+(cSF1)->F1_SERIE+(cSF1)->F1_FORNECE+(cSF1)->F1_LOJA+(cSF1)->F1_TIPO
        lSeek := SF1->(DbSeek(cKeySeek))
    EndIf
 
    If !lSeek
   		cNotaSeek :=  Padr(StrZero(Val((cSF1)->F1_DOC),9),9)
       	cKeySeek  := (cSF1)->F1_FILIAL+cNotaSeek+(cSF1)->F1_SERIE+(cSF1)->F1_FORNECE+(cSF1)->F1_LOJA+(cSF1)->F1_TIPO
        lSeek := SF1->(DbSeek(cKeySeek))
 	EndIf

    IF !lSeek
   		cNotaSeek := Iif(nFormXML > 0,StrZero(Val((cSF1)->F1_DOC),nFormXML),AllTrim(Str(Val((cSF1)->F1_DOC))))
		cKeySeek  := (cSF1)->F1_FILIAL+cNotaSeek+ Str( Val( (cSF1)->F1_SERIE ), len( (cSF1)->F1_SERIE ) ) +(cSF1)->F1_FORNECE+(cSF1)->F1_LOJA+(cSF1)->F1_TIPO
		lSeek := SF1->(DbSeek(cKeySeek))
	ENDIF
       
    If !lSeek
		cNotaSeek := Padr(AllTrim(Str(Val((cSF1)->F1_DOC))),9)
		cKeySeek  := (cSF1)->F1_FILIAL+cNotaSeek+Str( Val( (cSF1)->F1_SERIE ), len( (cSF1)->F1_SERIE ) )+(cSF1)->F1_FORNECE+(cSF1)->F1_LOJA+(cSF1)->F1_TIPO
        lSeek := SF1->(DbSeek(cKeySeek))
    EndIf

    If !lSeek
   		cNotaSeek :=  Padr(StrZero(Val((cSF1)->F1_DOC),6),9)
    	cKeySeek  := (cSF1)->F1_FILIAL+cNotaSeek+Str( Val( (cSF1)->F1_SERIE ), len( (cSF1)->F1_SERIE ) )+(cSF1)->F1_FORNECE+(cSF1)->F1_LOJA+(cSF1)->F1_TIPO
        lSeek := SF1->(DbSeek(cKeySeek))
    EndIf
 
    If !lSeek
   		cNotaSeek :=  Padr(StrZero(Val((cSF1)->F1_DOC),9),9)
       	cKeySeek  := (cSF1)->F1_FILIAL+cNotaSeek+Str( Val( (cSF1)->F1_SERIE ), len( (cSF1)->F1_SERIE ) )+(cSF1)->F1_FORNECE+(cSF1)->F1_LOJA+(cSF1)->F1_TIPO
        lSeek := SF1->(DbSeek(cKeySeek))
 	EndIf

 	if !lSeek  //Fadigar pela Chave
		DbSelectArea("SF1") 
		DbSetorder(8) // "F1_FILIAL+F1_CHVNFE"
       	cKeySeek  := (cSF1)->F1_FILIAL+Substr((cSF1)->F1_CHVNFE,1,44)
        lSeek := SF1->(DbSeek(cKeySeek))
		DbSelectArea("SF1") 
		DbSetorder(1) // "F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO"
 	endif

	If lSeek 
		nReg := SF1->( Recno() )
		lRet := .T.
	EndIf		           
	                       	
ElseIf nModo == 2

	lContinua := .T.
	cKeySeek  := (cSF1)->F1_FILIAL+(cSF1)->F1_FORNECE+(cSF1)->F1_LOJA
	DbSelectArea("SF1") 
	DbSetorder(2) // F1_FILIAL+F1_FORNECE+F1_LOJA+F1_DOC
    If DbSeek(cKeySeek)
		While SF1->F1_FILIAL + SF1->F1_FORNECE + SF1->F1_LOJA == cKeySeek .And. lContinua .And. SF1->(!Eof())
		    If Val((cSF1)->F1_DOC) == Val(SF1->F1_DOC) .And. Val((cSF1)->F1_SERIE) == Val(SF1->F1_SERIE) //.And. ZBZ->ZBZ_SERIE <> "F"
				nReg := SF1->( Recno() )
				lRet := .T.
				lContinua := .F.
			EndIf	
			SF1->(DbSkip())
		EndDo
		    
    Else
    
    EndIf

EndIf
                       
RestArea(aArea)
Return(lRet)
 
 
Static Function DifNfXml( nDNfXml, nRegSf1, nRegZbz, nTotXml, nTotSf1, nQtdXml, nQtdSd1 )

Local lRet     := .F.
Local aArea    := GetArea()
Local cError   := ""
Local cWarning := ""
Local i        := 0
Local nQuant   := 0
Private oXmlNf, cTagTot, oDet

DbSelectArea( xZBZ )
DbGoTo( nRegZbz )

oXmlNf := XmlParser( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML"))), "_", @cError, @cWarning )

If oXmlNf == NIL .Or. .NOT. Empty( cError )
   RestArea(aArea)
   Return( lRet )
EndIf

cTagTot    := "oXmlNf:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VNF:TEXT"
If Type(cTagTot)<> "U"
	nTotXml := Val(&(cTagTot))
Else
	nTotXml := -1
EndIf

DbSelectArea( "SF1" )
DbGoTo( nRegSf1 )
nTotSf1 := SF1->F1_VALBRUT

if nDNfXml == 2 .Or. nDNfXml == 4
	If nTotSf1 <> nTotXml
		lRet := .T.
	EndIf
EndIf

if (nDNfXml == 3 .Or. nDNfXml == 4) .And. Type("oXmlNf:_NFEPROC:_NFE:_INFNFE:_DET") <> "U"
	oDet    := oXmlNf:_NFEPROC:_NFE:_INFNFE:_DET
	oDet    := IIf(ValType(oDet)=="O",{oDet},oDet)
	nQtdXml := 0
	For i := 1 To len(oDet)
		nQuant  := VAL(oDet[i]:_Prod:_QCOM:TEXT)
		nQtdXml += nQuant
	Next i

	nQtdSd1 := 0
	DbSelectArea( "SD1" )
	SD1->( DbSetOrder( 1 ) )
	SD1->( dbSeek( SF1->F1_FILIAL + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA ) )
	Do While .NOT. SD1->( Eof() ) .AND. SD1->D1_FILIAL == SF1->F1_FILIAL .AND. SD1->D1_DOC == SF1->F1_DOC .AND.;
		   SD1->D1_SERIE == SF1->F1_SERIE .AND. SD1->D1_FORNECE == SF1->F1_FORNECE .AND. SD1->D1_LOJA == SF1->F1_LOJA
		nQtdSd1 += SD1->D1_QUANT
		SD1->( dbSkip() )
	EndDo

	If nQtdSd1 <> nQtdXml
		lRet := .T.
	EndIf
EndIf

RestArea(aArea)
Return( lRet )

 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³XConsXml  ºAutor  ³Roberto Souza       º Data ³  19/10/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Consulta o XML junto a sefaz.                              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Geral                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/           
User Function XConsXml(cURL,cChaveXml,cModelo,cProtocolo,cMensagem,cCodRet,lShowMsg,xCnpj,xIdEnt,xManif,lMesAno) //GETESB2 

Local lRet      := .F.
Local lProt     := .T.
Local lConModal := ( AllTrim(GetNewPar("XM_GRBMOD","N")) == "S" )
Local cConLoc   := "2"  //AllTrim(GetNewPar("XM_ROT_CON","1"))              //1=WS Importa, 2=TSS
Local cRetOK    := AllTrim(GetNewPar("XM_RETOK","526,731"))+AllTrim(GetNewPar("XM_RETDEN","301,302,303"))
Local cMsgSm0   := ""
Local cAnoMes   := Substr( cChaveXml,3,4 )
Local nAno, nMes, xAnoMes
Local cPref     := ""
Local cTag      := ""
Local cClToken  :=	alltrim(GetNewPar("XM_CLTOKEN",Space(256)))
Local cCloud	:=	alltrim(GetNewPar("XM_CLOUD" ,"0"))         //aCombo (0=Desbilitado 1=Habilitado) 
Local aHeader	:= {}
Local cXmlRet   := ""

Private cError		:= ""
Private cWarning	:= ""
Private oXmlRet 

Default lShowMsg   := .T.
Default cProtocolo := Space(15)
Default cCodRet    := ""
Default cURL       := AllTrim(GetNewPar("XM_URL","")) 
Default xManif     := "0" //GETESB2
Default lMesAno    := .T.

If Empty(cURL)
	cURL  := AllTrim(SuperGetMv("MV_SPEDURL"))
EndIf 

/*±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Valida se pode continuar com a requisição ao SEFAZ        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±*/
If cCloud == "1" //.and. (cModelo == "55" .or. cModelo == "57") //Se não usa cloud ou for CTE

	If cModelo == "55"
		cPref   := "NF-e"
		cTAG    := "NFE"
	ElseIf cModelo == "65"      //NFCE_01 22/02
		cPref   := "NFC-e"
		cTAG    := "NFE"
	ElseIf cModelo == "57"
		cPref   := "CT-e"
		cTAG    := "CTE"
	ElseIf cModelo == "67"
		cPref   := "CT-eOS"
		cTAG    := "CTE"
		cConLoc := "2"
	ElseIf cModelo == "RP"
		lRet    := .T.
		cCodRet := "100"
		If lShowMsg
			U_MyAviso("Consulta "+"NFS-e TXT"+" ","NFS-e via arquivos Texto. Não contem consulta a SEFAZ.",{"OK"},3)
		EndIf
		Return( lRet )
		
	EndIf

	/*±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±º Erick Gonçalves 12/12/2022 - Condição para entrar na tabela ZBZ e setar a tag do xml consultado. º±±
	±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±*/
	dbSelectArea( xZBZ )
	DbSetorder(3)
		If DbSeek( cChaveXml )
			cTGP   := iif( substr( cChaveXml,21,2 ) = "57", "CTE", "NFE" )
			cTAG   := iif( substr( cChaveXml,21,2 ) = "57", "CTE", "NFE" )
			cPref   := iif( substr( cChaveXml,21,2 ) = "57", "CTE", "NFE" )
		Elseif !DbSeek( cChaveXml )
			cTGP   := iif( substr( cChaveXml,21,2 ) = "57", "CTE", "NFE" )
			cTAG   := iif( substr( cChaveXml,21,2 ) = "57", "CTE", "NFE" )
			cPref   := iif( substr( cChaveXml,21,2 ) = "57", "CTE", "NFE" )
		Endif
endif

//lRet := .T. //FR TESTE
//Em 5/9/19 dXml => data do XML maior que 6 meses
If ! Empty(cAnoMes) .and. Len(cAnoMes) == 4
	nAno := Year( date() )
	nMes := Month( date() )
	if nMes <= 6
		nAno := nAno - 1
		nMes := ( nMes - 6 ) + 12
	Else
		nMes := ( nMes - 6 )
	endif
	xAnoMes := Substr(StrZero( nAno, 4, 0 ),3,2) + StrZero(nMes,2,0) 
	If ( cAnoMes <= xAnoMes ) //Menor que 6 meses
		if lMesAno
			lRet    := .T.
			cCodRet := "100"
		else
			lRet    := .F.
			cCodRet := ""
		endif
		if cModelo $ "55,65,57"
			cMensagem := "Ano-Mes da Chave de Acesso com atraso superior a 6 meses em relacao ao Ano-Mes atual."
		Else
			cMensagem := "Consulta a uma Chave de Acesso muito antiga."
		Endif
		If lShowMsg
			U_MyAviso("Consulta "+"NF-e"+" ",cMensagem,{"OK"},3)
		EndIf
		Return( lRet )
	EndIf 
EndIf

/*/DEBUG
	PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" MODULO "FAT" TABLES "SF1","SF2","SD1","SD2","SF4","SB5","SF3","SB1"
	RpcSetType(3)
	cURL       := AllTrim(SuperGetMv("XM_URL"))
	cChaveXml  :="41121076881093000172550010000361941000361940" 
	cChaveXml  :="35121188317847003403570010000736791065736793"    // CT-e Cancelado
    cModelo    := "55"
	cPref      := "NF-e" 
	cProtocolo := "999999999999999"	                  
*/
//DEBUG

If cCloud == "1" .and. (cModelo == "55" .or. cModelo == "57")

	IF u_HFXSEMA()

		cUrl 	:= "https://cloud.importaxml.com.br"
		cCnpj 	:= Alltrim(FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , { "M0_CGC" } )[1][2])

		Aadd(aHeader, "Content-Type: application/json")                      
		Aadd(aHeader, "Connection: keep-alive")   

		oRest 	:= FWRest():New(cUrl)

		oRest:SetPath("/api/"+cTag+"ConsultaSituacao?token="+cClToken+"&Chave="+cChaveXml)  		

		oRest:Get(aHeader) 

		If oRest:GetResult() <> Nil 
		
			cXmlRet := oRest:GetResult()

			cXmlRet := strTran(cXmlRet,'"','')

			oXmlRet := XmlParser( cXmlRet ,"_",@cError, @cWarning )

			If ( oXmlRet == NIL )

				oXmlRet := NIL								
				FreeObj(oXmlRet)
				Conout("Falha ao gerar Objeto XML : "+cError+" / "+cWarning)
				Return

			Endif

			//Se existir Warning, mostra no console.log
			If ! Empty(cWarning)
			
				ConOut( "[u_XConsXml] - Alerta cWarning: " + cWarning )
				
			EndIf
				
			//Se houve erro, não permitirá prosseguir
			If ! Empty(cError)
			
				ConOut("[u_XConsXml]- Erro: " + cError)
				lContinua := .F.
				
			EndIf

			if Type("oXmlRet:_RETCONSSIT"+cTag+":_PROT"+cTag+":_INFPROT:_CH"+cTag+":TEXT") <> "U"

				lRet := .T.
										
				cChave  := &("oXmlRet:_RETCONSSIT"+cTag+":_PROT"+cTag+":_INFPROT:_CH"+cTag+":TEXT")
				cVersao := &("oXmlRet:_RETCONSSIT"+cTag+":_VERSAO:TEXT")
				cStatus := &("oXmlRet:_RETCONSSIT"+cTag+":_PROT"+cTag+":_INFPROT:_CSTAT:TEXT")
				cTpAmb  := &("oXmlRet:_RETCONSSIT"+cTag+":_PROT"+cTag+":_INFPROT:_TPAMB:TEXT")
				cMotivo := &("oXmlRet:_RETCONSSIT"+cTag+":_PROT"+cTag+":_INFPROT:_XMOTIVO:TEXT")
				cProt   := &("oXmlRet:_RETCONSSIT"+cTag+":_PROT"+cTag+":_INFPROT:_NPROT:TEXT")
				cDigVal := &("oXmlRet:_RETCONSSIT"+cTag+":_PROT"+cTag+":_INFPROT:_DIGVAL:TEXT")

				cCodRet := cStatus 

				cNewRet := "Protocolo: " + cProt + CRLF
				cNewRet += "Digito: " + cDigVal + CRLF
				
				cRet := "Chave: " + cChave + CRLF 
				cRet += "Versão da mensagem: " + cVersao + CRLF 
				cRet += "Ambiente: " + iif(cTpAmb == "1","Produção","Homologação") + CRLF
				cRet += "Cod. Ret. " + cModelo + ": " + cStatus + CRLF
				cRet += "Msg. Ret. " + cModelo + ": " + cMotivo + CRLF
				cRet += cNewRet
				
				if lShowMsg 

					u_MyAviso("Consulta por Chave",cRet,{"OK"},3)

				endif

			else

				if Type("oxmlret:_ERRO:Text") <> "U"
				
					MsgInfo(oxmlret:_ERRO:Text,"Retorno Consulta")

				endif

			Endif 

			oRest := NIL								
			FreeObj(oRest)

		endif

		U_HFXGRSEMA("XConsXml",cChaveXml)

	endif

Else

	if cConLoc == "1" //.or. ( (empty( xManif ) .or. xManif == "0") .And. cModelo == "55" )  //GETESB2
		oWs:= WSHFXMLCONSULTACHV():New()
		oWs:Init()
		oWs:cCCURL   := AllTrim(cURL)
		oWs:cCIDENT  := U_GetIdEnt()
		oWs:cCCHAVE  := AllTrim(cChaveXml)
		oWs:nNAMBIENTE   := 1
		oWs:nNMODALIDADE := 1

		if oWs:HFCONSULTACHV()
			cCodRet := oWs:oWSHFCONSULTACHVRESULT:cCCODSTA
			cMensagem := ""
			cMensagem += "Chave : "+cChaveXml+CRLF
			If !Empty(oWs:oWSHFCONSULTACHVRESULT:cCVERSAO)
				cMensagem += "Versão da mensagem : "+oWs:oWSHFCONSULTACHVRESULT:cCVERSAO+CRLF
			EndIf
			cMensagem += "Ambiente: "+IIf(oWs:oWSHFCONSULTACHVRESULT:cCAMBIENTE=="1","Produção","Homologação")+CRLF 
			cMensagem += "Cod.Ret."+cPref+": "+oWs:oWSHFCONSULTACHVRESULT:cCCODSTA+CRLF
			cMensagem += "Msg.Ret."+cPref+": "+oWs:oWSHFCONSULTACHVRESULT:cCMSGSTA+CRLF 
			If !Empty(oWs:oWSHFCONSULTACHVRESULT:cCPROTOCOLO)
				cMensagem += "Protocolo: "+oWs:oWSHFCONSULTACHVRESULT:cCPROTOCOLO+CRLF
				If !Empty(cProtocolo)
					If cProtocolo <> AllTrim(oWs:oWSHFCONSULTACHVRESULT:cCPROTOCOLO)
						cMensagem += "## Protocolo Difere do XML: "+cProtocolo+CRLF
						cMensagem += "             "
						lProt := .F.
					Else
						lProt := .T.
					EndIf
				EndIf	
			EndIf                                            
			cXml := oWs:oWSHFCONSULTACHVRESULT:cCRETXML
			nAt1:= At('<RETCONSSITNFE ',Upper(cXml))
			nAt2:= At('</RETCONSSITNFE>',Upper(cXml))+ 16
			//Corpo do XML
			If nAt1 <=0
				nAt1:= At('<RETCONSSITNFE>',Upper(cXml))
			EndIf 	
			If nAt1 > 0 .And. nAt2 > 16
				cNfe := Substr(cXml,nAt1,nAt2-nAt1)

				cXml:= '<?xml version="1.0" encoding="UTF-8"?>'
				cXml+= cNfe
				cXml := NoAcento(cXml)
				cXml := EncodeUTF8(cXml)
				cErro:= ""
				cWarning:= ""
				oWSrNfe := XmlParser( cXml, "_", @cErro, @cWarning )
				If oWSrNfe == NIL .Or. !Empty(cErro) .Or. !Empty(cWarning)
				elseIf .NOT. oWSrNfe:_RETCONSSITNFE:_CSTAT:TEXT $ cRetOK+",100"
				Else
					If !Empty(oWSrNfe:_RETCONSSITNFE:_PROTNFE:_INFPROT:_DIGVAL:TEXT)
						cMensagem += "Dígito"+": "+oWSrNfe:_RETCONSSITNFE:_PROTNFE:_INFPROT:_DIGVAL:TEXT+CRLF  
					EndIf
					xManif := verManifes(xManif,oWSrNfe)  //GETESB2
				Endif
			EndIf
			If lShowMsg .And. cCodRet $ cRetOK+",100,101"
				U_MyAviso("IMPXML - Consulta "+cPref+" ",cMensagem,{"OK"},3)
			EndIf
		EndIf
		If cCodRet $ cRetOK+",100"
			xCnpj  := SM0->M0_CGC
			xIdEnt := oWs:cCIDENT
	//		If lProt
				lRet := .T.	
	//		EndIf
		endif
	endif
			
	if (cConLoc <> "1" .and. Empty(cCodRet) ) .or. .NOT. cCodRet $ cRetOK+",100,101"

		oWs:= WsNFeSBra():New()
		oWs:cUserToken   := "TOTVS"
		oWs:cID_ENT      := U_GetIdEnt()
		ows:cCHVNFE		 := AllTrim(cChaveXml)
		oWs:_URL         := AllTrim(cURL)+"/NFeSBRA.apw"
	//   <USERTOKEN>STRING</USERTOKEN>
	//   <ID_ENT>STRING</ID_ENT>
	//   <CHVNFE>STRING</CHVNFE>
	//   <MODELO>STRING</MODELO>
	//   <ATUALIZA>INTEGER</ATUALIZA>

		If oWs:ConsultaChaveNFE()

			cMensagem := ""
			cMensagem += "Chave : "+cChaveXml+CRLF

			If !Empty(oWs:oWSCONSULTACHAVENFERESULT:cVERSAO)
				cMensagem += "Versão da mensagem : "+oWs:oWSCONSULTACHAVENFERESULT:cVERSAO+CRLF
			EndIf

			cMensagem += "Ambiente: "+IIf(oWs:oWSCONSULTACHAVENFERESULT:nAMBIENTE==1,"Produção","Homologação")+CRLF 
			If !Empty(oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE)
				cMensagem += "Cod.Ret."+cPref+": "+oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE+CRLF
			else
				cMensagem += "Tss ou dbacess com falhas. Por favor verifique"
			endif	
			If !Empty(oWs:oWSCONSULTACHAVENFERESULT:cMSGRETNFE)
				cMensagem += "Msg.Ret."+cPref+": "+oWs:oWSCONSULTACHAVENFERESULT:cMSGRETNFE+CRLF 
			endif
			If !Empty(oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO)

				cMensagem += "Protocolo: "+oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO+CRLF

				If !Empty(cProtocolo)

					If cProtocolo <> AllTrim(oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO)

						cMensagem += "## Protocolo Difere do XML: "+cProtocolo+CRLF
						cMensagem += "             "
						lProt := .F.

					Else

						lProt := .T.

					EndIf   

				EndIf

			EndIf   

			If !Empty(oWs:oWSCONSULTACHAVENFERESULT:cDIGVAL)
				cMensagem += "Dígito"+": "+oWs:oWSCONSULTACHAVENFERESULT:cDIGVAL+CRLF  
			EndIf

			If !Empty(oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE)
				cCodRet := oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE
			endif
			If cCodRet $ cRetOK+",100,101" .And. Type( "oWs:oWSCONSULTACHAVENFERESULT:cXML_RET" ) <> "U"
				
				cXml := oWs:oWSCONSULTACHAVENFERESULT:cXML_RET
				nAt1:= At('<RETCONSSITNFE ',Upper(cXml))
				nAt2:= At('</RETCONSSITNFE>',Upper(cXml))+ 16

				//Corpo do XML
				If nAt1 <=0
					nAt1:= At('<RETCONSSITNFE>',Upper(cXml))
				EndIf 	

				If nAt1 > 0 .And. nAt2 > 16

					cNfe := Substr(cXml,nAt1,nAt2-nAt1)
					cXml:= '<?xml version="1.0" encoding="UTF-8"?>'
					cXml+= cNfe
					cXml := EncodeUTF8(cXml)
					cXml := FwNoAccent(cXml)
					cErro:= ""
					cWarning:= ""
					oWSrNfe := XmlParser( cXml, "_", @cErro, @cWarning )
					xManif := verManifes(xManif,oWSrNfe)  //GETESB2

				Endif

			Endif

			If lShowMsg

				If cCodRet $ cRetOK+",100,101"

					U_MyAviso("TSS Consulta "+cPref+" ",cMensagem,{"OK"},3)

				endif

			EndIf

		Else

			cMensagem := ""
			cMensagem += "Erro de Webservice : "+CRLF
			cMensagem += IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
			If lShowMsg .and. .NOT. lConModal
				U_MyAviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"OK"},3)
			EndIf
			If "526" $ cMensagem .or. "Ano-Mes da Chave de Acesso com atraso superior a 6 meses em relacao ao Ano-Mes atual" $ cMensagem
				cCodRet := "526"
			EndIf
		EndIf

		If cCodRet $ cRetOK+",100"
			xCnpj  := SM0->M0_CGC
			xIdEnt := oWs:cID_ENT
	//		If lProt
				lRet := .T.	
	//		EndIf		
		EndIf
		oWs := Nil
	EndIf

	If .NOT. cCodRet $ cRetOK+",100,101" .AND. lConModal  //Antes da Modalidade vamos verificar nas outras entidades
		If lShowMsg .or. ProcName( 7 ) == "HFXML06CHV"
			oProcess := MsNewProcess():New({| lEnd | VerSM0(@lEnd,oProcess,cURL,AllTrim(cChaveXml),cModelo,@cMensagem,@cCodRet,@lProt,cProtocolo,@cMsgSm0,iif(ProcName( 7 ) == "HFXML06CHV",.T.,lShowMsg),@xCnpj,@xIdEnt)},"Consultando","Consultando Por Outras Entidades...",.T.)
			oProcess:Activate()
		else
			VerSM0(.F.,,cURL,AllTrim(cChaveXml),cModelo,@cMensagem,@cCodRet,@lProt,cProtocolo,@cMsgSm0,lShowMsg,@xCnpj,@xIdEnt)
		endif
		If cCodRet $ cRetOK+",100"
	//		If lProt
				lRet := .T.	
	//		EndIf
		endif
		If lShowMsg .and. cCodRet $ cRetOK+",100,101"
			U_MyAviso(cMsgSm0+" "+cPref+" ",cMensagem,{"OK"},3)
		EndIf
	EndIf

	if .NOT. cCodRet $ cRetOK+",100,101" .AND. .F. //lConModal
		If lShowMsg
			oProcess := MsNewProcess():New({| lEnd | VerModal(@lEnd,oProcess,cURL,AllTrim(cChaveXml),cModelo,@cMensagem,@cCodRet,@lProt,cProtocolo,lShowMsg,@xCnpj,@xIdEnt)},"Consultando","Consultando por Modalidade...",.T.)
			oProcess:Activate()
		elseif ProcName( 7 ) <> "HFXML06CHV" .And. ProcName( 7 ) <> "HFXML16CHV"
			VerModal(.F.,,cURL,AllTrim(cChaveXml),cModelo,@cMensagem,@cCodRet,@lProt,cProtocolo,lShowMsg,@xCnpj,@xIdEnt)
		endif
		If cCodRet $ cRetOK+",100"
	//		If lProt
				lRet := .T.	
	//		EndIf
		endif
		If lShowMsg
			U_MyAviso("MODTSS Consulta "+cPref+" ",cMensagem,{"OK"},3)
		EndIf
	ElseIf .NOT. cCodRet $ cRetOK+",100,101"
		If lShowMsg
			U_MyAviso(cMsgSm0+" "+cPref+" ",cMensagem,{"OK"},3)
		EndIf
	Endif

	if empty( xManif ) .or. xManif == "0"
	//	xManif := U_HFMANZBS( cChaveXml, xManif )
	endif

EndIf

Return(lRet)


Static Function VerSM0(lEnd,oRegua,cURL,cChaveXml,cModelo,cMensagem,cCodRet,lProt,cProtocolo,cMsgSm0,lShowMsg,xCnpj,xIdEnt)
Local aArea  := GetArea()
Local nReg   := SM0->( Recno() )
Local lRet   := .F.
Local cConLoc:= "2"   //AllTrim(GetNewPar("XM_ROT_CON","1"))              //1=WS Importa, 2=TSS
Local cRetOK := AllTrim(GetNewPar("XM_RETOK","526,731"))
Local oWs

if lShowMsg
	oRegua:SetRegua1( SM0->(LastRec()) )
	oRegua:SetRegua2(0)

	oRegua:IncRegua1("Outras Entidades: " )
	oRegua:IncRegua2(cChaveXml)
endif

SM0->( dbGoTop() )
Do While .NOT. SM0->( Eof() )
	if lShowMsg
		oRegua:IncRegua1("Outras Entidades: " + SM0->M0_FILIAL )
		oRegua:IncRegua2(cChaveXml)
		If lEnd
			MsgStop("*** Cancelado pelo Operador ***","Fim")
			Exit
		EndIf
	endif
	if SM0->M0_CODIGO <> cEmpAnt
		SM0->( dbSkip() )
		Loop
	endif

	oWs := NIL
	if cConLoc == "1"
		oWs:= WSHFXMLCONSULTACHV():New()
		oWs:Init()
		oWs:cCCURL   := AllTrim(cURL)
		oWs:cCIDENT  := U_GetIdEnt()
		oWs:cCCHAVE  := AllTrim(cChaveXml)
		oWs:nNAMBIENTE   := 1
		oWs:nNMODALIDADE := 1
	
		if oWs:HFCONSULTACHV()
			cCodRet := oWs:oWSHFCONSULTACHVRESULT:cCCODSTA
			cMensagem := ""
			cMensagem += "Chave : "+cChaveXml+CRLF
			If !Empty(oWs:oWSHFCONSULTACHVRESULT:cCVERSAO)
				cMensagem += "Versão da mensagem : "+oWs:oWSHFCONSULTACHVRESULT:cCVERSAO+CRLF
			EndIf
			cMensagem += "Ambiente: "+IIf(oWs:oWSHFCONSULTACHVRESULT:cCAMBIENTE=="1","Produção","Homologação")+CRLF 
			cMensagem += "Cod.Ret."+cPref+": "+oWs:oWSHFCONSULTACHVRESULT:cCCODSTA+CRLF
			cMensagem += "Msg.Ret."+cPref+": "+oWs:oWSHFCONSULTACHVRESULT:cCMSGSTA+CRLF 
			If !Empty(oWs:oWSHFCONSULTACHVRESULT:cCPROTOCOLO)
				cMensagem += "Protocolo: "+oWs:oWSHFCONSULTACHVRESULT:cCPROTOCOLO+CRLF
				If !Empty(cProtocolo)
					If cProtocolo <> AllTrim(oWs:oWSHFCONSULTACHVRESULT:cCPROTOCOLO)
						cMensagem += "## Protocolo Difere do XML: "+cProtocolo+CRLF
						cMensagem += "             "
						lProt := .F.
					Else
						lProt := .T.
					EndIf      
				EndIf	
			EndIf                                            
			cXml := oWs:oWSHFCONSULTACHVRESULT:cCRETXML
			nAt1:= At('<RETCONSSITNFE ',Upper(cXml))
			nAt2:= At('</RETCONSSITNFE>',Upper(cXml))+ 16
			//Corpo do XML
			If nAt1 <=0
				nAt1:= At('<RETCONSSITNFE>',Upper(cXml))
			EndIf 	
			If nAt1 > 0 .And. nAt2 > 16
				cNfe := Substr(cXml,nAt1,nAt2-nAt1)
	
				cXml:= '<?xml version="1.0" encoding="UTF-8"?>'
				cXml+= cNfe
				cXml := NoAcento(cXml)
				cXml := EncodeUTF8(cXml)
				cErro:= ""
				cWarning:= ""
				oWSrNfe := XmlParser( cXml, "_", @cErro, @cWarning )
				If oWSrNfe == NIL .Or. !Empty(cErro) .Or. !Empty(cWarning)
				elseIf .NOT. oWSrNfe:_RETCONSSITNFE:_CSTAT:TEXT $ cRetOK+",100"
				Else
					If !Empty(oWSrNfe:_RETCONSSITNFE:_PROTNFE:_INFPROT:_DIGVAL:TEXT)
						cMensagem += "Dígito"+": "+oWSrNfe:_RETCONSSITNFE:_PROTNFE:_INFPROT:_DIGVAL:TEXT+CRLF  
					EndIf
				Endif
	        EndIf
		EndIf
		If cCodRet $ cRetOK+",100"
			If lProt
		   		lRet := .T.	
			EndIf		
		EndIf
		If cCodRet $ cRetOK+",100,101"
			xCnpj   := SM0->M0_CGC
			xIdEnt  := oWs:cCIDENT
			cMsgSm0 := "IMPXML - Consulta - "+Alltrim(SM0->M0_FILIAL)
			Exit
		Endif
	endif
		    
	if cConLoc <> "1" .or. .NOT. cCodRet $ cRetOK+",100,101"
		oWs:= NIL
		oWs:= WsNFeSBra():New()
		oWs:cUserToken   := "TOTVS"
		oWs:cID_ENT      := U_GetIdEnt()
		ows:cCHVNFE		 := AllTrim(cChaveXml)
		oWs:_URL         := AllTrim(cURL)+"/NFeSBRA.apw"
	
		If oWs:ConsultaChaveNFE()
			cMensagem := ""
			cMensagem += "Chave : "+cChaveXml+CRLF
			If !Empty(oWs:oWSCONSULTACHAVENFERESULT:cVERSAO)
				cMensagem += "Versão da mensagem : "+oWs:oWSCONSULTACHAVENFERESULT:cVERSAO+CRLF
			EndIf
			cMensagem += "Ambiente: "+IIf(oWs:oWSCONSULTACHAVENFERESULT:nAMBIENTE==1,"Produção","Homologação")+CRLF 
			cMensagem += "Cod.Ret."+cPref+": "+oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE+CRLF
			cMensagem += "Msg.Ret."+cPref+": "+oWs:oWSCONSULTACHAVENFERESULT:cMSGRETNFE+CRLF 
			If !Empty(oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO)
				cMensagem += "Protocolo: "+oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO+CRLF
				If !Empty(cProtocolo)
					If cProtocolo <> AllTrim(oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO)
						cMensagem += "## Protocolo Difere do XML: "+cProtocolo+CRLF
						cMensagem += "             "
						lProt := .F.
					Else
						lProt := .T.
					EndIf      
				EndIf	
			EndIf                                            
			If !Empty(oWs:oWSCONSULTACHAVENFERESULT:cDIGVAL)
				cMensagem += "Dígito"+": "+oWs:oWSCONSULTACHAVENFERESULT:cDIGVAL+CRLF  
			EndIf
			cCodRet := oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE
		Else
			cMensagem := ""
			cMensagem += "Erro de Webservice : "+CRLF
			cMensagem += IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
		EndIf
		If cCodRet $ cRetOK+",100"
			If lProt
		   		lRet := .T.	
			EndIf		
		EndIf
		If cCodRet $ cRetOK+",100,101"
			xCnpj   := SM0->M0_CGC
			xIdEnt  := oWs:cID_ENT
			cMsgSm0 := "TSS Consulta "+Alltrim(SM0->M0_FILIAL)
			Exit
		Endif
	EndIf

	SM0->( dbSkip() )
EndDo

SM0->( dbGoTo( nReg ) )
RestArea(aArea)
Return( lRet )


Static Function VerModal(lEnd,oRegua,cURL,cChaveXml,cModelo,cMensagem,cCodRet,lProt,cProtocolo,lShowMsg,xCnpj,xIdEnt)
Local lRet   := .F.
Local nModal := 0
Local oWs
Local cRetOK := AllTrim(GetNewPar("XM_RETOK","526,731"))

if lShowMsg
	oRegua:SetRegua1(10)
	oRegua:SetRegua2(0)

	oRegua:IncRegua1("Modalidade: " + StrZero(0,1,0) )
	oRegua:IncRegua2(cChaveXml)
endif

oWs:= WSHFXMLCONSULTACHV():New()
oWs:Init()
oWs:cCCURL   := AllTrim(cURL)
oWs:cCIDENT  := U_GetIdEnt()
oWs:cCCHAVE  := AllTrim(cChaveXml)
oWs:cCMODELO := cModelo

For nModal := 1 To 9

	if lShowMsg
		oRegua:IncRegua1("Modalidade: " + StrZero(nModal,1,0) )
		oRegua:IncRegua2(cChaveXml)
		If lEnd
			MsgStop("*** Cancelado pelo Operador ***","Fim")
			Exit
		EndIf
	endif
	
	oWs:nNMODALIDADE := nModal

	if oWs:HFCONSCHVMODAL()
		cXml := oWs:cHFCONSCHVMODALRESULT
		if cModelo == "57"
			nAt1:= At('<RETCONSSITCTE ',Upper(cXml))
			nAt2:= At('</RETCONSSITCTE>',Upper(cXml))+ 16
			//Corpo do XML
			If nAt1 <=0
				nAt1:= At('<RETCONSSITCTE>',Upper(cXml))
			EndIf
			If nAt1 > 0 .And. nAt2 > 16
				cNfe := Substr(cXml,nAt1,nAt2-nAt1)

				cXml:= '<?xml version="1.0" encoding="UTF-8"?>'
				cXml+= cNfe
				cXml := NoAcento(cXml)
				cXml := EncodeUTF8(cXml)
				cErro:= ""
				cWarning:= ""
				oWSrNfe := XmlParser( cXml, "_", @cErro, @cWarning )
				If oWSrNfe == NIL .Or. !Empty(cErro) .Or. !Empty(cWarning)
				elseIf oWSrNfe:_RETCONSSITCTE:_CSTAT:TEXT $ cRetOK+",100"
					cMensagem := ""
					cMensagem += "Chave : "+cChaveXml+CRLF
					If !Empty(oWSrNfe:_RETCONSSITCTE:_VERSAO:TEXT)
						cMensagem += "Versão da mensagem : "+oWSrNfe:_RETCONSSITCTE:_VERSAO:TEXT+CRLF
					EndIf
					cMensagem += "Ambiente: "+IIf(oWSrNfe:_RETCONSSITCTE:_TPAMB:TEXT=="1","Produção","Homologação")+CRLF 
					cMensagem += "Cod.Ret."+cPref+": "+oWSrNfe:_RETCONSSITCTE:_CSTAT:TEXT+CRLF
					cMensagem += "Msg.Ret."+cPref+": "+oWSrNfe:_RETCONSSITCTE:_XMOTIVO:TEXT+CRLF 
					If !Empty(oWSrNfe:_RETCONSSITCTE:_PROTCTE:_INFPROT:_NPROT:TEXT)
						cMensagem += "Protocolo: "+oWSrNfe:_RETCONSSITCTE:_PROTCTE:_INFPROT:_NPROT:TEXT+CRLF
						If !Empty(cProtocolo)
							If cProtocolo <> AllTrim(oWSrNfe:_RETCONSSITCTE:_PROTCTE:_INFPROT:_NPROT:TEXT)
								cMensagem += "## Protocolo Difere do XML: "+cProtocolo+CRLF
								cMensagem += "             "
								lProt := .F.
							Else
								lProt := .T.
							EndIf      
						EndIf	
					EndIf                                            
					If !Empty(oWSrNfe:_RETCONSSITCTE:_PROTCTE:_INFPROT:_DIGVAL:TEXT)
						cMensagem += "Dígito"+": "+oWSrNfe:_RETCONSSITCTE:_PROTCTE:_INFPROT:_DIGVAL:TEXT+CRLF  
					EndIf
					cCodRet := oWSrNfe:_RETCONSSITCTE:_CSTAT:TEXT
					lRet := .T.
					Exit
				Endif
   	    	EndIf
		Else
			nAt1:= At('<RETCONSSITNFE ',Upper(cXml))
			nAt2:= At('</RETCONSSITNFE>',Upper(cXml))+ 16
			//Corpo do XML
			If nAt1 <=0
				nAt1:= At('<RETCONSSITNFE>',Upper(cXml))
			EndIf 	
			If nAt1 > 0 .And. nAt2 > 16
				cNfe := Substr(cXml,nAt1,nAt2-nAt1)

				cXml:= '<?xml version="1.0" encoding="UTF-8"?>'
				cXml+= cNfe
				cXml := NoAcento(cXml)
				cXml := EncodeUTF8(cXml)
				cErro:= ""
				cWarning:= ""
				oWSrNfe := XmlParser( cXml, "_", @cErro, @cWarning )
				If oWSrNfe == NIL .Or. !Empty(cErro) .Or. !Empty(cWarning)
				elseIf oWSrNfe:_RETCONSSITNFE:_CSTAT:TEXT $ cRetOK+",100"
					cMensagem := ""
					cMensagem += "Chave : "+cChaveXml+CRLF
					If !Empty(oWSrNfe:_RETCONSSITNFE:_VERSAO:TEXT)
						cMensagem += "Versão da mensagem : "+oWSrNfe:_RETCONSSITNFE:_VERSAO:TEXT+CRLF
					EndIf
					cMensagem += "Ambiente: "+IIf(oWSrNfe:_RETCONSSITNFE:_TPAMB:TEXT=="1","Produção","Homologação")+CRLF 
					cMensagem += "Cod.Ret."+cPref+": "+oWSrNfe:_RETCONSSITNFE:_CSTAT:TEXT+CRLF
					cMensagem += "Msg.Ret."+cPref+": "+oWSrNfe:_RETCONSSITNFE:_XMOTIVO:TEXT+CRLF 
					If !Empty(oWSrNfe:_RETCONSSITNFE:_PROTNFE:_INFPROT:_NPROT:TEXT)
						cMensagem += "Protocolo: "+oWSrNfe:_RETCONSSITNFE:_PROTNFE:_INFPROT:_NPROT:TEXT+CRLF
						If !Empty(cProtocolo)
							If cProtocolo <> AllTrim(oWSrNfe:_RETCONSSITNFE:_PROTNFE:_INFPROT:_NPROT:TEXT)
								cMensagem += "## Protocolo Difere do XML: "+cProtocolo+CRLF
								cMensagem += "             "
								lProt := .F.
							Else
								lProt := .T.
							EndIf      
						EndIf	
					EndIf                                            
					If !Empty(oWSrNfe:_RETCONSSITNFE:_PROTNFE:_INFPROT:_DIGVAL:TEXT)
						cMensagem += "Dígito"+": "+oWSrNfe:_RETCONSSITNFE:_PROTNFE:_INFPROT:_DIGVAL:TEXT+CRLF  
					EndIf
					cCodRet := oWSrNfe:_RETCONSSITNFE:_CSTAT:TEXT
					lRet := .T.
					Exit
				Endif
   	    	EndIf
		EndIf
	EndIf

Next nModal

if cCodRet $ cRetOK+",100"
	xCnpj  := SM0->M0_CGC
	xIdEnt := oWs:cCIDENT
endif

Return( lRet )


Static Function verManifes(xManif,oWSrNfe)  //GETESB2

Local cRet := xManif
Local cUlt := ""
Local cDth := ""
Local nI   := 0
Private oRet := oWSrNfe
Private oEve

if Type( "oWSrNfe:_RETCONSSITNFE:_PROCEVENTONFE" ) <> "U"

	oEve := oWSrNfe:_RETCONSSITNFE:_PROCEVENTONFE
	oEve := iif( ValType(oEve) == "O", {oEve}, oEve )

	For nI := 1 To Len( oEve )

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

Return( cRet )


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MAILSEND ³ Autor ³ Roberto Souza           ³ Data ³13/11/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina que envia e-mail utilizando classe tMailManager       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MAILSEND(aTo,cSubject,cMsg,cError,cAnexo,cAnexo2,cEmailDest) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±³          ³ ExpA1 = aTo                                                  ³±±
±±³          ³ ExpC2 = Subject                                              ³±±
±±³          ³ ExpC3 = Mensagem a ser enviada                               ³±±
±±³          ³ ExpC4 = Mensagem de erro retornada                    (OPC)  ³±±
±±³          ³ ExpC5 = Arquivo para anexar a mensagem                (OPC)  ³±±
±±³          ³ ExpC6 = Arquivo para anexar a mensagem                (OPC)  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function MAILSEND(aTo,cSubject,cMensagem,cError,cAnexo,cAnexo2,cEmailDest,cCCdest,cBCCdest)
Local aServer     := U_XCfgMail(1,1,{})
Local cMailServer := AllTrim(aServer[1])
Local cLogin      := AllTrim(aServer[2])
Local cMailConta  := AllTrim(aServer[3])
Local cMailSenha  := AllTrim(aServer[4])
Local lSMTPAuth   := aServer[5] 
Local lSSL        := aServer[6] 
Local cProtocolE  := aServer[7] 
Local cPort       := aServer[8]
Local lTLS        := aServer[9] 
Local lImap       := AllTrim(cProtocolE) == "2" .And. AllTrim(GetProfString ("MAIL", "PROTOCOL", "" )) ==  "IMAP"
//Local nX          := 0 
Local oServer
Local oMessage
Local nRet        := 0
Local nRetDisc    := 0
//Local nNumMsg 	  := 0
//Local nTam   	  := 0
//Local nI     	  := 0
//Local nModel      := Val(GetSrvProfString("HF_MODOMAIL","1"))

Default cSubject  := "Mensagem de Teste"
//Default cMensagem := "Este é um email enviado automaticamente pelo Gerenciador de Contas do Protheus durante o teste das configurações da sua conta SMTP/IMAP."
Default aTo       := {cMailConta}
Default cError    := ""
Default cEmailDest:= ""
Default cCCdest   := ""
Default cBCCdest  := ""  

cMsgCfg := ""
cMsgCfg += '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
cMsgCfg += '<html xmlns="http://www.w3.org/1999/xhtml">
cMsgCfg += '<head>
cMsgCfg += '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
cMsgCfg += '<title>Importa XML</title>
cMsgCfg += '  <style type="text/css"> 
cMsgCfg += '	<!-- 
cMsgCfg += '	body {background-color: rgb(37, 64, 97);} 
cMsgCfg += '	.style1 {font-family: Segoe UI,Verdana, Arial;font-size: 12pt;} 
cMsgCfg += '	.style2 {font-family: Segoe UI,Verdana, Arial;font-size: 12pt;color: rgb(255,0,0)} 
cMsgCfg += '	.style3 {font-family: Segoe UI,Verdana, Arial;font-size: 10pt;color: rgb(37,64,97)} 
cMsgCfg += '	.style4 {font-size: 8pt; color: rgb(37,64,97); font-family: Segoe UI,Verdana, Arial;} 
cMsgCfg += '	.style5 {font-size: 10pt} 
cMsgCfg += '	--> 
cMsgCfg += '  </style>
cMsgCfg += '</head>
cMsgCfg += '<body>
cMsgCfg += '<table style="background-color: rgb(240, 240, 240); width: 800px; text-align: left; margin-left: auto; margin-right: auto;" id="total" border="0" cellpadding="12">
cMsgCfg += '  <tbody>
cMsgCfg += '    <tr>
cMsgCfg += '      <td colspan="2">
cMsgCfg += '    <Center>
cMsgCfg += '      <img src="http://extranet.helpfacil.com.br/images/cabecalho.jpg">
cMsgCfg += '      </Center><hr>
cMsgCfg += '      <p class="style1">Este é um email enviado automaticamente pelo Gerenciador de Contas do Protheus durante o teste das configurações da sua conta  de envio de notificações do Importa XML.</p>
cMsgCfg += '      <hr></td>
cMsgCfg += '    </tr>
cMsgCfg += '  </tbody>
cMsgCfg += '</table>
cMsgCfg += '<p class="style1">&nbsp;</p>
cMsgCfg += '</body>
cMsgCfg += '</html>

Default cMensagem := cMsgCfg

If !Empty(cMailServer) .And. !Empty(cMailConta) .And. !Empty(cMailSenha) .And. !Empty(cLogin)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Cria o objeto d e e-mail                                                         |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oServer := TMailManager():New()  
	
	If !lImap
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| Inicia o objeto d e e-mail                                                       |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lSSL
			oServer:SetUseSSL(lSSL) 
		EndIf
		If lTLS                      //aquuiiiiii
			oServer:SetUseTLS(lTLS) 
		EndIf
	    nRet := oServer:Init( "" ,;
	    			 AllTrim(cMailServer), ;
	    			 AllTrim(cMailConta), ;
	    			 AllTrim(cMailSenha),;
	    			 Nil ,;
	    			 Iif(!Empty(cPort),Val(cPort),Nil) )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| Timeout de espera                                                                |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nRet := oServer:SetSmtpTimeOut( 30 )
		If nRet <> 0
			Return(nRet)
		EndIf
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| Conecta ao servidor de SMTP                                                      |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nRet := oServer:SmtpConnect()
		If nRet <> 0
			Return(nRet)
		EndIf

		If lSMTPAuth
	   		nRet := oServer:SMTPAuth(cLogin,cMailSenha )
			If nRet <> 0
				Return(nRet)
			EndIf
	    EndIf

    Else 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| Inicia o objeto d e e-mail                                                       |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lSSL
			oServer:SetUseSSL(lSSL) 
		EndIf
		If lTLS                      //aquuiiiiii
			oServer:SetUseTLS(lTLS) 
		EndIf
	    nRet := oServer:Init( cMailServer ,;
	    			 "", ;
	    			 AllTrim(cMailConta), ;
	    			 AllTrim(cMailSenha),;
	    			 Iif(!Empty(cPort),Val(cPort),) ,;
	    			 Nil )
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| Conecta ao servidor de IMAP                                                      |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nRet := oServer:IMAPConnect()
		If nRet != 0
			Return(nRet)
		EndIf	    
    
    EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Cria o Objeto da mensagem                                                        |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oMessage := TMailMessage():New()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Limpa o Objeto da mensagem                                                       |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oMessage:Clear()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Atribui o Objeto da mensagem                                                     |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oMessage:cFrom 		:= cMailConta
	oMessage:cTo 		:= cEmailDest
	oMessage:cCc 		:= cCCdest
	oMessage:cBcc 		:= cBCCdest
	oMessage:cSubject 	:= cSubject
	oMessage:cBody 		:= cMensagem

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Processa os anexos                                                               |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(cAnexo)
		nRet := oMessage:AttachFile(cAnexo)
		If nRet <> 0
			Return(nRet)
		Else
			oMessage:AddAtthTag( 'Content-Disposition: attachment; filename='+cAnexo)
		EndIf
	EndIf
	If !Empty(cAnexo2)
		nRet := oMessage:AttachFile(cAnexo2)
		If nRet <> 0
			Return(nRet)
		Else
			oMessage:AddAtthTag( 'Content-Disposition: attachment; filename='+cAnexo2)				
		EndIf
	EndIf
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Envia o E-mail                                                                   |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nRet := oMessage:Send( oServer )
//	ALert(oServer:GetErrorString(nRet))
	If nRet <> 0
		Return(nRet)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Envia o E-mail                                                                   |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lImap
		nRetDisc := oServer:SmtpDisconnect()
	Else     
		nRetDisc := oServer:IMAPDisconnect()					    
    EndIf
	
	If nRet != 0
		Return(nRet)
	EndIf

EndIf	

Return(nRet) 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VerTSS    ºAutor  ³Roberto Souza       º Data ³  14/11/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica a versão do TSS da empresa corrente.              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Geral                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function VerTSS(cUrl,cVerTSS,lHelp)

Local oWs
Local lRetorno := .F.     
Local cCloud   := GetNewPar("XM_CLOUD" ,"0")         //aCombo (0=Desbilitado 1=Habilitado)

Default cVerTss  := "0.00" 
Default cURL     := AllTrim(GetNewPar("XM_URL",""))

if GetNewPar("XM_DFE","0") $ "0,1"

	if cCloud <> "1"

		cURL   := PadR(GetNewPar("XM_URL",""),250)

		If Empty(cURL)

			cURL := PadR(GetNewPar("MV_SPEDURL","http://"),250)

		EndIf

		oWs := WsSpedCfgNFe():New()
		oWs:cUserToken := "TOTVS"
		oWS:_URL := AllTrim(cURL)+"/SPEDCFGNFe.apw"
		If oWs:CFGTSSVERSAO()
			lRetorno := .T. 
			cVerTSS := oWs:CCFGTSSVERSAORESULT
		Else
			If lHelp
				U_MyAviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"OK"},3)
			EndIf
		EndIf

	else

		cUrl := ""
		
	endif

else
	
	cUrl := ""
	
endif
                 
Return(lRetorno) 


  




/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MATA140  ³ Autor ³ Edson Maricate        ³ Data ³ 24.01.2000 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Digitacao das Notas Fiscais de Entrada sem os dados Fiscais  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Descri‡…o ³ PLANO DE MELHORIA CONTINUA        ³Programa     MATA140.PRW  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ITEM PMC  ³ Responsavel              ³ Data                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³      01  ³ Marcos V. Ferreira       ³ 11/04/2006 - Bops: 00000096840    ³±±
±±³      02  ³ Marcos V. Ferreira       ³ 19/12/2005					    ³±±
±±³      03  ³ Marcos V. Ferreira       ³ 11/04/2006 - Bops: 00000096840    ³±±
±±³      04  ³ Flavio Luiz Vicco        ³ 04/01/2006                        ³±±
±±³      05  ³ Nereu Humberto Junior    ³ 16/03/2006                        ³±±
±±³      06  ³ Nereu Humberto Junior    ³ 16/03/2006                        ³±±
±±³      07  ³ Flavio Luiz Vicco        ³ 04/01/2006                        ³±±
±±³      08  ³ Ricardo Berti            ³ 07/02/2006                        ³±±
±±³      09  ³ Ricardo Berti            ³ 07/02/2006                        ³±±
±±³      10  ³ Marcos V. Ferreira       ³ 19/12/2005					    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/	
//---------------------------------------------------------------------------//
//FR - 08/05/2020 - Alterações realizadas para adequar na rotina 
//                  Pré Auditoria Fiscal 
//---------------------------------------------------------------------------//	

User Function XMATA140(xAutoCab,xAutoItens,nOpcAuto,lSimulaca,nTelaAuto)

Local aRotADic  := {}
Local aCores    := {	{ 'Empty(F1_STATUS)','ENABLE' 		},;// NF Nao Classificada
						{ 'F1_STATUS=="B"'	,'BR_LARANJA'	},;// NF Bloqueada
						{ 'F1_TIPO=="N"'	,'DISABLE'		},;// NF Normal
						{ 'F1_TIPO=="P"'	,'BR_AZUL'		},;// NF de Compl. IPI
						{ 'F1_TIPO=="I"'	,'BR_MARROM'	},;// NF de Compl. ICMS
						{ 'F1_TIPO=="C"'	,'BR_PINK'		},;// NF de Compl. Preco/Frete
						{ 'F1_TIPO=="B"'	,'BR_CINZA'		},;// NF de Beneficiamento
						{ 'F1_TIPO=="D"'	,'BR_AMARELO'	} }// NF de Devolucao
						
Local cFiltraSf1      := ""
Local nX,nAutoPC	  := 0

PRIVATE aRotina 	  := MenuDef()
PRIVATE cCadastro	  := OemToAnsi("Pre-Documento de Entrada") //"Pre-Documento de Entrada"
PRIVATE l140Auto	  := ( ValType(xAutoCab) == "A"  .And. ValType(xAutoItens) == "A" )
PRIVATE aAutoCab	  := xAutoCab
PRIVATE aAutoItens	  := xAutoItens
PRIVATE aHeadSD1      := {}
PRIVATE l103Auto      := .F.//l140Auto
PRIVATE l103CLASS     := .F. 
PRIVATE lOnUpdate     := .T.
PRIVATE nMostraTela   := 1 // 0 - Nao mostra tela 1 - Mostra tela e valida tudo 2 - Mostra tela e valida so cabecalho
PRIVATE a140Total     := {0,0,0}
PRIVATE a140Desp      := {0,0,0,0,0,0,0,0} 
PRIVATE cUsaDvg       := GetNewPar("XM_USADVG","N")
PRIVATE lTevePCTES    := lPCTES      //FR 11/05/2020 lPCTES é public, indica se fez a tela de divergência para o pedido de compra, então não precisa fazer para a pré-nota.
PRIVATE aCabNFE       := {}         //FR 12/05/2020
PRIVATE aIteNFE       := {}         //FR 12/05/2020

DEFAULT nOpcAuto	:= 3
DEFAULT lSimulaca	:= .F.
DEFAULT nTelaAuto   := 1
DEFAULT lPCTES      := .F.    //FR - 19/06/2020 - TÓPICOS RAFAEL
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ajusta Help para criar novo help da rotina³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AjustaHelp()

If l140Auto   
	For nX:= 1 To Len(xAutoItens)
		If (nAutoPC := Ascan(xAutoItens[nx],{|x| x[1]== "D1_PEDIDO"})) > 0
		     If Empty(xAutoItens[nX][nAutoPC][3])
		     	xAutoItens[nX][nAutoPC][3]:= "vazio().or. A103PC()"
			 EndIf
		EndIf
	Next
EndIf    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se estiver usando conferencia fisica muda opcoes do mbrowse³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (SuperGetMV("MV_CONFFIS",.F.,"N") == "S")
	aCores    := {	{ '(F1_STATCON=="1" .OR. EMPTY(F1_STATCON)) .AND. Empty(F1_STATUS)'	, 'ENABLE' 		},;	// NF Nao Classificada
					{ '(F1_STATCON=="1" .OR. EMPTY(F1_STATCON)) .AND. F1_TIPO=="N"'	 	, 'DISABLE'		},;	// NF Normal
					{ 'F1_STATUS=="B"'													, 'BR_LARANJA'	},;	// NF Bloqueada
					{ '(F1_STATCON=="1" .OR. EMPTY(F1_STATCON)) .AND. F1_TIPO=="P"'	 	, 'BR_AZUL'		},;	// NF de Compl. IPI
					{ '(F1_STATCON=="1" .OR. EMPTY(F1_STATCON)) .AND. F1_TIPO=="I"'	 	, 'BR_MARROM'	},;	// NF de Compl. ICMS
					{ '(F1_STATCON=="1" .OR. EMPTY(F1_STATCON)) .AND. F1_TIPO=="C"'	 	, 'BR_PINK'		},;	// NF de Compl. Preco/Frete
					{ '(F1_STATCON=="1" .OR. EMPTY(F1_STATCON)) .AND. F1_TIPO=="B"'	 	, 'BR_CINZA'	},;	// NF de Beneficiamento
					{ '(F1_STATCON=="1" .OR. EMPTY(F1_STATCON)) .AND. F1_TIPO=="D"'    	, 'BR_AMARELO'	},;	// NF de Devolucao
					{ 'F1_STATCON<>"1" .AND. !EMPTY(F1_STATCON) .AND. Empty(F1_STATUS)'	, 'BR_PRETO'	}} 	// NF Bloq. para Conferencia
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Adiciona rotinas ao aRotina                                  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "MT140ROT" )
	aRotAdic := ExecBlock( "MT140ROT",.F.,.F.)
	If ValType( aRotAdic ) == "A"
		AEval( aRotAdic, { |x| aadd( aRotina, x ) } )
	EndIf
EndIf      

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Adiciona rotinas ao aRotina                                  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "MT140FIL" )
    cFiltraSF1 := ExecBlock("MT140FIL",.F.,.F.)
	If ( ValType(cFiltraSF1) <> "C" )
		cFiltraSF1 := ""
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a permissao do programa em relacao aos modulos      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If AMIIn(2,4,11,12,14,17,39,41,42,97,17,44,67,69,72) 
	Pergunte("MTA140",.F.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ativa tecla F12 para ativar parametros de lancamentos contab.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If l140Auto
		lOnUpdate  := !lSimulaca
		nMostraTela:= nTelaAuto
		aAutoCab   := xAutoCab
		aAutoItens := xAutoItens

		If nOpcAuto == 7
			aRotBack 	  := aClone(aRotina)
			aRotina[5][2] := aRotBack[7][2]
			nOpcAuto	  := 5
		EndIf
//		MBrowseAuto( nOpcAuto, AClone( aAutoCab ), "SF1" )

		SetKey(VK_F12,{||Pergunte("MTA140",.T.)})
        xRet := U_A140NFis("SF1",Recno(),nOpcAuto)                  
		SetKey(VK_F12,Nil) 

		If nOpcAuto == 5 .And. aRotina[5][2] == "A140EstCla" 
			aRotina:= aClone(aRotBack)
		EndIf

		xAutoCab   := aAutoCab
		xAutoItens := aAutoItens
	Else
		SetKey(VK_F12,{||Pergunte("MTA140",.T.)})
		
		#IFDEF TOP
    	    mBrowse(6,1,22,75,"SF1",,,,,,aCores,,,,,,,,cFiltraSF1) 
    	#Else
  			mBrowse(6,1,22,75,"SF1",,,,,,aCores)
	   	#ENDIF
	   	
		SetKey(VK_F12,Nil)
	EndIf
EndIf
Return(xRet)
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A140NFisca³ Autor ³ Eduardo Riera         ³ Data ³02.10.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Interface do pre-documento de entrada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpL1: Alias do arquivo                                      ³±±
±±³          ³ExpN2: Numero do Registro                                    ³±±
±±³          ³ExpN3: Opcao selecionada no arotina                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo controlar a interface de um    ³±±
±±³          ³pre-documento de entrada                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function A140NFis(cAlias,nReg,nOpcX)
//Local nAcho     := 0
Local aRecSD1   := {}
Local aObjects  := {}
Local aInfo 	:= {}
Local aPosGet	:= {}
Local aPosObj	:= {}
Local aStruSD1  := {}
Local aListBox  := {}
Local aCamposPE := {}
Local aNoFields := {}
Local aRecOrdSD1:= {}
Local aTitles   := {"Totais", OemToAnsi("Fornecedor/Cliente"), "Descontos/Frete/Despesas"} //"Fornecedor/Cliente" ### "Descontos/Frete/Despesas" //"Totais"
Local aFldCBAtu := Array(Len(aTitles))
Local aInfForn	:= {"","",CTOD("  /  /  "),CTOD("  /  /  "),"","","",""}
Local aSizeAut  := {}
Local aButtons	:= {}
Local aListCpo 	:= {	"D1_COD"	,;
						"D1_UM"		,;
						"D1_QUANT"	,;
						"D1_VUNIT"	,;
						"D1_TOTAL"	,;
						"D1_LOCAL"	,;
						"D1_PEDIDO"	,;
						"D1_ITEMPC"	,;
						"D1_SEGUM"	,;
						"D1_QTSEGUM",;
						"D1_CC"		,;
						"D1_CONTA"	,;
						"D1_ITEMCTA",;
						"D1_CLVL"	,;
						"D1_ITEM"	,;
						"D1_LOTECTL",;
						"D1_NUMLOTE",;
						"D1_DTVALID",;
						"D1_LOTEFOR",;
						"D1_DESC"	,;
						"D1_VALDESC",;
						"D1_OP"		,;
						"D1_CODGRP"	,;
						"D1_CODITE"	,;
						"D1_VALIPI"	,;
						"D1_VALICM"	,;
						"D1_CF"		,;
						"D1_IPI"	,;
						"D1_PICM"	,;
						"D1_PESO"	,;
						"D1_TP"		,;
						"D1_BASEICM",;
						"D1_BASEIPI",;
						"D1_TEC"	,;
						"D1_CONHEC"	,;
						"D1_TIPO_NF",;
						"D1_NFORI"	,;
						"D1_SERIORI",;
						"D1_ITEMORI",;
						"D1_BASEPIS",;
						"D1_BASECOF",;
						"D1_BASECSL",;
						"D1_VALIMP1",;
						"D1_VALIMP2",;
						"D1_VALIMP3",;
						"D1_VALIMP4",;
						"D1_VALIMP5",;
						"D1_VALIMP6",;
						"D1_BASIMP1",;
						"D1_BASIMP2",;
						"D1_BASIMP3",;
						"D1_BASIMP4",;
						"D1_BASIMP5",;
						"D1_BASIMP6",;
						"D1_ALQIMP1",;
						"D1_ALQIMP2",;
						"D1_ALQIMP3",;
						"D1_ALQIMP4",;
						"D1_ALQIMP5",;
						"D1_ALQIMP6",;
						"D1_VALFRE"	,;
						"D1_SEGURO"	,;
						"D1_DESPESA",;
						"D1_FORMUL"	,;
						"D1_CLASFIS",;
						"D1_II"		,;
						"D1_ICMSDIF",;
						"D1_FCICOD" ,;
						"D1_ITEMMED" } 
Local l140Inclui := .F.
Local l140Altera := .F.
Local l140Exclui := .F.
Local l140Visual := .F.
Local lContinua  := .T.
Local lQuery     := .F.
Local lItSD1Ord  := IIF(mv_par03==2,.T.,.F.)
Local lConsMedic := .F.
Local lExistMemo := .F. 
Local lIntACD	 := SuperGetMV("MV_INTACD",.F.,"0") == "1"
Local lShowTela  := .T.
Local cAliasSD1  := "SD1"
Local nX         := 0
//Local nY         := 0
//Local nPosPC	 := 0
Local nPosGetLoja:= IIF(TamSX3("A2_COD")[1]< 10,(2.5*TamSX3("A2_COD")[1])+(110),(2.8*TamSX3("A2_COD")[1])+(100))
Local nOpcA		 := 0
Local nQtdConf   := 0
Local bWhileSD1  := {||.T.}
Local bCabOk     := {||.T.}
Local oDlg
Local oFolder
Local oEnable    := LoadBitmap( GetResources(), "ENABLE" )
Local oDisable   := LoadBitmap( GetResources(), "DISABLE" )
Local oStatCon
Local oConf
Local oTimer
//Local aPosDel    := {}
Local dDataFec   := If(FindFunction("MVUlmes"),MVUlmes(),GetMV("MV_ULMES"))
Local nPosCC     := 0      //HF
Local nPosPRD	 := 0      //HF

Local aHeadSEV		:= {}  //Para Nt C. Frete
Local aColsSEV		:= {}  //Para Nt C. Frete
Local aColsSDE		:= {}  //Para Nt C. Frete
Local aHeadSDE      := {}  //Para Nt C. Frete
Local nIa           := 0
Private lRetorna := .T., lEditCol := .T. //Para corrigir erro a partir da LIB de 20/06/18

//Private bSavKeyF5	:= SetKey(VK_F5,Nil)
//Private bSavKeyF6	:= SetKey(VK_F6,Nil)
//Private bSavKeyF7	:= SetKey(VK_F7,Nil)
//Private bSavKeyF10	:= SetKey(VK_F10,Nil)

Private oGetDados
Private bGDRefresh	:= {|| IIf(oGetDados<>Nil,(oGetDados:oBrowse:Refresh()),.F.) }		// Efetua o Refresh da GetDados
Private	bRefresh    := {|nX,nY,nTotal,nValDesc| Ma140Total(a140Total,a140Desp,nTotal,nValDesc),NfeFldChg(,,oFolder,aFldCBAtu),IIf(oGetDados<>Nil,(oGetDados:oBrowse:Refresh()),.F.)}
Private l103Visual  := .T. //-- Nao permite alterar os campos de despesas/frete.
Private lNfMedic    := .F. 

DEFAULT aPedC	:= {}    

l140Auto := !(Type("l140Auto")=="U" .Or. !l140Auto)

// Zera os totais para que a chamada de inclusao apos uma gravacao nao traga os valores preenchidos 
a140Total := {0,0,0}
a140Desp  := {0,0,0,0,0,0,0,0}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inclui os campos referentes ao WMS na Pre-Nota               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If IntDL()
	aAdd(aListCpo, 'D1_SERVIC')
	aAdd(aListCpo, 'D1_STSERV')
	aAdd(aListCpo, 'D1_TPESTR')
	aAdd(aListCpo, 'D1_DESEST')
	aAdd(aListCpo, 'D1_REGWMS')
	aAdd(aListCpo, 'D1_ENDER' )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inclui os campos referentes ao EIC na Pre-Nota               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If l140Auto .And. SuperGetMV("MV_EASY",,"N") == "S"
	aAdd(aListCpo, 'D1_DATORI' )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chamada do ponto de entrada MT140CPO                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistTemplate("MT140CPO")
	aCamposPE := If(ValType(aCamposPE:=ExecTemplate('MT140CPO',.F.,.F.))=='A',aCamposPE,{})
	If Len(aCamposPE) > 0
		For nX := 1 to Len(aCamposPE)
			If (aScan(aListCpo, aCamposPE[nX])) == 0
				aadd(aListCpo, aCamposPE[nX])
			EndIf
		Next nX
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chamada do ponto de entrada MT140CPO                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("MT140CPO")
	aCamposPE := If(ValType(aCamposPE:=ExecBlock('MT140CPO',.F.,.F.))=='A',aCamposPE,{})
	If Len(aCamposPE) > 0
		For nX := 1 to Len(aCamposPE)
			If (aScan(aListCpo, aCamposPE[nX])) == 0
				aadd(aListCpo, aCamposPE[nX])
			EndIf
		Next nX
	EndIf
EndIf                                                           

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chamada do ponto de entrada MT140DCP 					   ³                                                |
//| Para não exibir os campos customizados no Acols, é necessário incluir o mesmo no aListBox e posteriormente  |
//| carregar o mesmo no array aNolFields para ser descconsiderado na FillGetDados 								|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aNoFields:= {}
If ExistBlock("MT140DCP")
	aNoFields := If(ValType(aNoFields:=ExecBlock('MT140DCP',.F.,.F.))=='A',aNoFields,{})
	If Len(aNoFields) > 0
		For nX := 1 to Len(aNoFields)
			If (aScan(aListCpo, aNoFields[nX])) == 0
				aadd(aListCpo, aNoFields[nX])
			EndIf
		Next nX
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a operacao a ser realizada                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
	Case aRotina[nOpcX][4] == 2
		l140Visual := .T.
	Case aRotina[nOpcX][4] == 3
		l140Inclui	:= .T.
	Case aRotina[nOpcX][4] == 4
		l140Altera	:= .T.
	Case aRotina[nOpcX][4] == 5
		l140Exclui	:= .T.
		l140Visual	:= .T.
EndCase

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Analisa data de fechamento somente quando o parametro MV_DATAHOM  |
//| estiver configurado com o conteudo igual a "2"                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If l140Inclui .And. SuperGetMv("MV_DATAHOM",.F.,"1")=="2"
	If dDataFec >= dDataBase
		Help( " ", 1, "FECHTO" )
		lContinua := .F.
    EndIf
EndIf

// Evita reacumulo do saldo em aPedc (ao cancelar alt./realterar/F6) BOPS 90013 07/02/06
If !l140Visual
	aPedC	:= {}	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa as variaveis da Modelo 2                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private bPMSDlgNF	:= {||PmsDlgNF(nOpcX,cNFiscal,cSerie,cA100For,cLoja,cTipo)} // Chamada da Dialog de Gerenc. Projetos
Private aRatAFN     := {}
Private	cTipo		:= If(l140Inclui,CriaVar("F1_TIPO")		,SF1->F1_TIPO)
Private	cTpCompl	:= If(l140Inclui,CriaVar("F1_TPCOMPL")	,SF1->F1_TPCOMPL)
Private aCompFutur  := {}  //ERRMATA103
Private cFormul		:= If(l140Inclui,CriaVar("F1_FORMUL")	,SF1->F1_FORMUL)
Private cNFiscal 	:= If(l140Inclui,CriaVar("F1_DOC")		,SF1->F1_DOC)
Private cSerie		:= If(l140Inclui,CriaVar("F1_SERIE")	,SF1->F1_SERIE)
Private dDEmissao	:= If(l140Inclui,CriaVar("F1_EMISSAO")	,SF1->F1_EMISSAO)
Private cA100For	:= If(l140Inclui,CriaVar("F1_FORNECE")	,SF1->F1_FORNECE)
Private cLoja		:= If(l140Inclui,CriaVar("F1_LOJA")		,SF1->F1_LOJA)
Private cEspecie	:= If(l140Inclui,CriaVar("F1_ESPECIE")	,SF1->F1_ESPECIE)
Private cUfOrigP	:= If(l140Inclui,CriaVar("F1_EST")		,SF1->F1_EST)
Private nPedagioCt  := If(l140Inclui,CriaVar("F1_VALPEDG")	,SF1->F1_VALPEDG)
Private cModFreCt   := If(l140Inclui,CriaVar("F1_TPFRETE")	,SF1->F1_TPFRETE)
Private n           := 1
Private aCols		:= {}
Private aHeader 	:= {}
Private lReajuste   := IIF(mv_par01==1,.T.,.F.)
Private lConsLoja   := SuperGetMv("XM_VERLOJA",.T.,"N") //IIF(mv_par02==1,.T.,.F.)
Private cForAntNFE  := ""
Private lMudouNum   := .F.
if ( xxx := AScan( aAutoCab, { |x| x[1] == "F1_EST" } ) ) > 0
	cUfOrigP := aAutoCab[xxx][2]
endif
//Alert(nPedagioCt)
/*	Trecho abaixo foi criado 
	para tratar uma alteração 
	que estava feita no programa e o 
	versionador não atribuio este fonte.*/

If Alltrim(lConsLoja)=="S"
	lConsLoja := .T.
Else
	lConsLoja := .F.
EndIf

/*****************FIM*******************/	


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Habilita as HotKeys e botoes da barra de ferramentas         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (!l140Auto .Or. (nMostraTela <> 0)) .And. (l140Inclui .Or. l140Altera)
    If !l140Altera
		aButtons	:= {{'PEDIDO',{||U_XMLPCF5(.F.,a140Desp, lNfMedic, lConsMedic),Eval(bRefresh)},"Pedidos de Compras","Pedido"},; //"Pedidos de Compras"
						{'SDUPROP',{||U_XMLPCF6(.F.,aPedC,oGetDados, lNfMedic, lConsMedic,,,a140Desp ),Eval(bRefresh)},"Pedidos de Compras(por item)","Item.Ped"} } //"PEDIDO"###"Pedidos de Compras(por item)"
		If lDetCte //HfFGVTN
			aAdd(aButtons, {'RECALC',{||U_XMLNFOF7()},OemToAnsi("Selecionar Documento Original - <F7> "),"Selecionar Documento Original ( CTE )"} )
		endif

		SetKey( VK_F5, { || U_XMLPCF5(.F.,a140Desp, lNfMedic, lConsMedic ),Eval(bRefresh) } )
		SetKey( VK_F6, { || U_XMLPCF6(.F.,aPedC,oGetDados, lNfMedic, lConsMedic,,,a140Desp ),Eval(bRefresh) } )
		If lDetCte //HfFGVTN
			SetKey( VK_F7, { || U_XMLNFOF7(),Eval(bRefresh) } )
		endif

    Else
    	aButtons	:= {{'SDUPROP',{||U_XMLPCF6(.F.,aPedC,oGetDados, lNfMedic, lConsMedic,,,a140Desp ),Eval(bRefresh)},"Pedidos de Compras(por item)","Item.Ped"}} //"PEDIDO"###"Pedidos de Compras(por item)"
		SetKey( VK_F6, { || U_XMLPCF6(.F.,aPedC,oGetDados, lNfMedic, lConsMedic,,,a140Desp ),Eval(bRefresh) } )
		If lDetCte //HfFGVTN
			aAdd(aButtons, {'RECALC',{||U_XMLNFOF7()},OemToAnsi("Selecionar Documento Original - <F7> "),"Selecionar Documento Original ( CTE )"} )
			SetKey( VK_F7, { || U_XMLNFOF7(),Eval(bRefresh) } )
		endif
    EndIf
	aAdd(aButtons, {'RECALC',{||A140NFORI()},("NF Origem","NF Origem")} ) //"Selecionar Documento Original ( Devolucao/Beneficiamento/Complemento )"} )  
EndIf

If (!l140Auto .Or. (nMostraTela <> 0)) .And. IntePms()
	aadd(aButtons, {'PROJETPMS',bPmsDlgNF,"Gerenciamento de Projetos","Projetos"}) //"Gerenciamento de Projetos"
	SetKey( VK_F10, { || Eval(bPmsDlgNF)} )
EndIf

lConsMedic := A103GCDisp()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Habilita o folder de conferencia fisica se necessario        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If l140Visual .And. (SuperGetMv("MV_CONFFIS",.F.,"N") == "S")
	aadd(aTitles,"Conferencia Fisica") //"Conferencia Fisica"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a NF possui NF de Conhec. e Desp. de Import.     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If l140Exclui
	SF8->(dbSetOrder(2))
	If SF8->(MsSeek(xFilial("SF8")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
		Help(" ", 1, "A103CAGREG")
		lContinua := .F.
	EndIf	
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para validar a alteracao de um pre-documento ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If l140Altera .And. ExistBlock("A140ALT")
	lContinua := If(ValType(lContinua:=ExecBlock("A140ALT",.F.,.F.))=='L',lContinua,.T.)
EndIf	

If !l140Inclui
	//-- Atualiza dados do folder de despesas
	a140Desp[VALDESP]:= SF1->F1_DESPESA
	a140Desp[FRETE]  := SF1->F1_FRETE
	a140Desp[SEGURO] := SF1->F1_SEGURO

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem do aCols                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !l140Visual
		If !SoftLock("SF1")
			lContinua := .F.
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Alteracao - Verifica Status da conferencia                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lContinua .And. !l140Visual
		If (SuperGetMV("MV_CONFFIS",.F.,"N") == "S") .And. SF1->F1_STATCON == "1"
			If Aviso(OemToAnsi("Atencao"),OemToAnsi("Documento já conferido. Deseja estornar a conferência?"),{"Sim","Nao"})==1 //Atencao##"Documento já conferido. Deseja estornar a conferência?"
				A140AtuCon(,,,,,,,,.T.)
			EndIf
		EndIf
	EndIf
	If lContinua
		dbSelectArea("SD1")
		dbSetOrder(1)
		#IFDEF TOP

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica a existencia de campo MEMO no SD1 para nao executar a Query.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SX3->(dbSetOrder(1))
			SX3->(MsSeek("SD1"))
			While !SX3->(Eof()) .And. SX3->X3_ARQUIVO == "SD1"
				If (IIf((!l140Auto .Or. (nMostraTela <> 0)),X3USO(SX3->X3_USADO),.T.) .And.;
				 Ascan(aListCpo,Trim(SX3->X3_CAMPO)) != 0 .And. cNivel >= SX3->X3_NIVEL) .Or.;
				(SX3->X3_PROPRI == "U" .And. cNivel >= SX3->X3_NIVEL)
					If SX3->X3_TIPO == "M"
                        lExistMemo := .T. 
						Exit
					EndIf
				EndIf
				SX3->(dbSkip())
			EndDo

			If !InTransact() .And. !lExistMemo
				aStruSD1 := SD1->(dbStruct())
				lQuery   := .T.

				cQuery := "SELECT SD1.R_E_C_N_O_ SD1RECNO,SD1.* "
				cQuery += "FROM "+RetSqlName("SD1")+" SD1 "
				cQuery += "WHERE SD1.D1_FILIAL='"+xFilial("SD1")+"' AND "
				cQuery += "SD1.D1_DOC = '"+SF1->F1_DOC+"' AND "
				cQuery += "SD1.D1_SERIE = '"+SF1->F1_SERIE+"' AND "
				cQuery += "SD1.D1_FORNECE = '"+SF1->F1_FORNECE+"' AND "
				cQuery += "SD1.D1_LOJA = '"+SF1->F1_LOJA+"' AND "
				cQuery += "SD1.D_E_L_E_T_=' ' "

				If lItSD1Ord .Or. ALTERA
					cQuery += "ORDER BY "+SqlOrder( "D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_ITEM+D1_COD" )
				Else
					cQuery += "ORDER BY "+SqlOrder(SD1->(IndexKey()))
				EndIf

				cQuery := ChangeQuery(cQuery)

				SD1->(dbCloseArea())

				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SD1")
				For nX := 1 To Len(aStruSD1)
					If aStruSD1[nX][2]<>"C"
						TcSetField("SD1",aStruSD1[nX][1],aStruSD1[nX][2],aStruSD1[nX][3],aStruSD1[nX][4])
					EndIf
				Next nX
			Else
		#ENDIF
			MsSeek(xFilial("SD1")+cNFiscal+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
		#IFDEF TOP
			EndIf
		#ENDIF

		bWhileSD1 := { || ( !Eof().And. lContinua .And. ;
				(cAliasSD1)->D1_FILIAL== xFilial("SD1") .And. ;
				(cAliasSD1)->D1_DOC == cNFiscal .And. ;
				(cAliasSD1)->D1_SERIE == SF1->F1_SERIE .And. ;
				(cAliasSD1)->D1_FORNECE == SF1->F1_FORNECE .And. ;
				(cAliasSD1)->D1_LOJA == SF1->F1_LOJA ) }

	EndIf
Else //HF alimentar esta matriz para valer os valores.
	//-- Atualiza dados do folder de despesas
	If ( nPos := AScan( aAutoCab, { |x| x[1] == "F1_DESPESA" } ) ) > 0
		a140Desp[VALDESP] := aAutoCab[nPos][2]
	Endif
	If ( nPos := AScan( aAutoCab, { |x| x[1] == "F1_FRETE" } ) ) > 0
		a140Desp[FRETE] := aAutoCab[nPos][2]
	Endif
	If ( nPos := AScan( aAutoCab, { |x| x[1] == "F1_SEGURO" } ) ) > 0
		a140Desp[SEGURO] := aAutoCab[nPos][2]
	Endif
EndIf 

If lContinua
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Sintaxe da FillGetDados(nOpcx,cAlias,nOrder,cSeekKey,bSeekWhile,uSeekFor,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry,bCriaVar,lUserFields) |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FillGetDados(nOpcX,"SD1",1,/*cSeek*/,/*{|| &cWhile }*/,{||.T.},aNoFields,aListCpo,/*lOnlyYes*/,/*cQuery*/,{|| MaCols140 (cAliasSD1,bWhileSD1,aRecOrdSD1,@aRecSD1,@aPedC,lItSD1Ord,lQuery,l140Inclui,l140Visual,@lContinua,l140Exclui) },l140Inclui,/*aHeaderAux*/,/*aColsAux*/,/*bAfterCols*/,/*bbeforeCols*/,/*bAfterHeader*/,/*cAliasQry*/,/*bCriaVar*/,.T.,IIF(!l140Auto .Or. nMostraTela <> 0,{},aListCpo))
	
	If lQuery
		dbSelectArea("SD1")
		dbCloseArea()
		ChkFile("SD1")
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de entrada que permite o preenchimento automático dos dados do cabeçalho da pre-nota e define se continua a rotina |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If l140Inclui
		If ExistBlock("MT140CAB")
			If !ExecBlock("MT140CAB",.F.,.F.)
				lContinua := .F.
			EndIf
		EndIf
	EndIf

	If lContinua
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calculo do total do pre-documento de entrada                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Ma140Total(a140Total,a140Desp)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Rotina automatica                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If l140Auto
			nOpcA := 1
			If !l140Exclui
				aValidGet := {}
				If l140Inclui
					PRIVATE aBlock := {	{|| NfeTipo(cTipo,@cA100For,@cLoja)},;
						{|| NfeFormul(cFormul,@cNFiscal,@cSerie)},;
						{|| NfeFornece(cTipo,@cA100For,@cLoja).And.CheckSX3("F1_DOC")},;
						{|| NfeFornece(cTipo,@cA100For,@cLoja).And.CheckSX3("F1_SERIE")},;
						{|| CheckSX3("F1_EMISSAO") .And. NfeEmissao(dDEmissao)},;
						{|| NfeFornece(cTipo,@cA100For,@cLoja).And.CheckSX3('F1_FORNECE',cA100For)},;
						{|| NfeFornece(cTipo,@cA100For,@cLoja).And.CheckSX3('F1_LOJA',cLoja)},;
						{|| CheckSX3("F1_ESPECIE",cEspecie)},;
						{|| CheckSX3("F1_EST",cUfOrigP) .And. CheckSX3("F1_EST",cUfOrigP)}}
					If (nX := aScan(aAutoCab,{|x| AllTrim(Upper(x[1]))=="F1_TIPO"}))<>0
						aadd(aValidGet,{"cTipo",aAutoCab[(nX),2],"Eval(aBlock[1])",.T.})
					Else
						cTipo := "N"
					EndIf
					If (nX := aScan(aAutoCab,{|x| AllTrim(Upper(x[1]))=="F1_FORMUL"}))<>0
						aadd(aValidGet,{"cFormul",aAutoCab[(nX),2],"Eval(aBlock[2])",.T.})
					Else
						cFormul := "N"
					EndIf
					nX := aScan(aAutoCab,{|x| AllTrim(Upper(x[1]))=="F1_DOC"})
					aadd(aValidGet,{"cNFiscal" ,aAutoCab[(nX),2],"Eval(aBlock[3])",.T.})
					nX := aScan(aAutoCab,{|x| AllTrim(Upper(x[1]))=="F1_SERIE"})
					aadd(aValidGet,{"cSerie",aAutoCab[(nX),2],"Eval(aBlock[4])",.T.})
					nX := aScan(aAutoCab,{|x| AllTrim(Upper(x[1]))=="F1_EMISSAO"})
					aadd(aValidGet,{"dDEmissao",aAutoCab[(nX),2],"Eval(aBlock[5])",.T.})
					nX := aScan(aAutoCab,{|x| AllTrim(Upper(x[1]))=="F1_FORNECE"})
					aadd(aValidGet,{"cA100For",aAutoCab[(nX),2],"Eval(aBlock[6])",.T.})
					nX := aScan(aAutoCab,{|x| AllTrim(Upper(x[1]))=="F1_LOJA"})
					aadd(aValidGet,{"cLoja",aAutoCab[(nX),2],"Eval(aBlock[7])",.T.})
					If (nX := aScan(aAutoCab,{|x| AllTrim(Upper(x[1]))=="F1_ESPECIE"}))<>0
						aadd(aValidGet,{"cEspecie",aAutoCab[(nX),2],"Eval(aBlock[8])",.T.})
					Else
						cEspecie := ""
					EndIf
					If (nX := aScan(aAutoCab,{|x| AllTrim(Upper(x[1]))=="F1_EST"}))<>0
						aadd(aValidGet,{"cUfOrigP",aAutoCab[(nX),2],"Eval(aBlock[9])",.T.})
					Else
						cUfOrigP := ""
					EndIf
					If ! SF1->(MsVldGAuto(aValidGet))
						nOpcA := 0
					EndIf
				EndIf
				If GetMV("MV_INTPMS",,"N") == "S" .And. GetMV("MV_PMSIPC",,2) == 1 //Se utiliza amarracao automatica dos itens da NFE com o Projeto
					l103Auto	:= .T.    //HF -> para solucionar o problema do acols.
					For nX := 1 To Len(aAutoItens)
						If nX == 1
							aAdd(aAutoItens[nX],{"D1_ITEM","000"+AllTrim(Str(nX)),NIL})
						Else
							aAdd(aAutoItens[nX],{"D1_ITEM",Soma1(aAutoItens[nX-1][Len(aAutoItens[nX-1])][2]),Nil})
						EndIf
						PMS140IPC(Val(aAutoItens[nX][aScan(aAutoItens[nX],{|x| AllTrim(x[1])=="D1_ITEM"})][2]))					
					Next nX
					l103Auto	:= .F.    //HF -> volta como estava
				EndIf
				If nOpcA <> 0 
					If !NfeCabOk(l140Visual,Nil,Nil,Nil,Nil,Nil,.F.)
						nOpcA := 0
					Else
						If nMostraTela <> 2
					  		//If !SD1->(U_XMsGet(aAutoItens,"U_Ma140LOk(.T.,2)",{|| U_MA140Tok()},aAutoCab,aRotina[nOpcX][4]))
					  	   	//If !SD1->(MsGetDAuto(aAutoItens,"U_Ma140LOk(.T.,2)",{|| U_MA140Tok()},aAutoCab,aRotina[nOpcX][4]))
					  		//	nOpcA := 0
					  		//EndIf
		        		EndIf
					EndIf
				EndIf
				If nMostraTela <> 0 .And. nOpca <> 0
					l140Auto := .F.
					nOpca    := 0
					HelpInDark(.F.)
				EndIf
				If lMsErroAuto   //AQUIIIIII ERRROOO
					//MOSTRAERRO()
					//lShowTela := .F.
				EndIf
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Interface com o Usuario                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !l140Auto .or. lShowTela 
			if nAmarris == 2
				U_AMAPC(a140Desp,lNfMedic,lConsMedic,aHeadSDE,aColsSDE,aHeadSEV, aColsSEV) //,aHeadSDE,aColsSDE,aHeadSEV, aColsSEV
				if cPCSol == "N" .And. Empty(_cCCusto)   //HF Pega Pelo Produto e não do Pedido de Compra
					nPosCC   := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_CC" })      //HF
					nPosPRD	 := aScan(aHeader,{|x| Alltrim(x[2]) == "D1_COD" })     //HF
					SB1->( dbSetOrder(1) )
					if nPosCC > 0 .and. nPosPRD
	   					For nIa := 1 To len( aCols )
	   						if SB1->( dbSeek( xFilial("SB1") + aCols[nIa][nPosPRD] ) )  //posiciona o bixo
								aCols[nIa][nPosCC] := SB1->B1_CC
							endif
						Next nIa
					endif
				endif
				nAmarris++
			endif
			
			aSizeAut := MsAdvSize(,.F.,400)
			aObjects := {}
			aadd( aObjects, { 0,    41, .T., .F. } )
			aadd( aObjects, { 100, 100, .T., .T. } )
			aadd( aObjects, { 0,    75, .T., .F. } )
			aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
			aPosObj := MsObjSize( aInfo, aObjects )
			aPosGet := MsObjGetPos(aSizeAut[3]-aSizeAut[1],310,;
				{{8,35,75,100,194,220,260,280},;
				If( l140Visual .Or. !lConsMedic,{8,35,75,100,nPosGetLoja,194,220,260,280},{8,35,75,108,145,160,190,220,244,265} ),;
				{5,70,160,205,295},;
				{6,34,200,215},;
				{6,34,75,103,148,164,230,253},;
				{6,34,200,218,280},;
				{11,50,150,190},;
				{273,130,190,293,205}})

			DEFINE MSDIALOG oDlg FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] TITLE cCadastro Of oMainWnd PIXEL

			//if cModelo == "57"
			U_HFNfeCab(oDlg,{aPosGet[1],aPosGet[2],aPosObj[1]},@bCabOk,l140Visual .Or. l140Altera,.F.,@cUfOrigP,,iif(cModelo == "57",.F.,.T.),nil,nil,nil,nil,@lNfMedic)
			//Else
			//	NfeCabDoc(oDlg,{aPosGet[1],aPosGet[2],aPosObj[1]},@bCabOk,l140Visual .Or. l140Altera,.F.,@cUfOrigP,,iif(cModelo == "57",.F.,.T.),nil,nil,nil,nil,@lNfMedic)
			//Endif

			oGetDados := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcX,"U_Ma140LOk(.F.,1)","U_MA140Tok","+D1_ITEM",!l140Visual,,,,999,,,,"Ma140DelIt")
			oGetDados:oBrowse:bGotFocus	:= bCabOk

			oFolder := TFolder():New(aPosObj[3,1],aPosObj[3,2],aTitles,{"HEADER"},oDlg,,,, .T., .F.,aPosObj[3,4]-aPosObj[3,2],aPosObj[3,3]-aPosObj[3,1],)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Folder dos Totalizadores                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oFolder:aDialogs[1]:oFont := oDlg:oFont
			NfeFldTot(oFolder:aDialogs[1],a140Total,aPosGet[3],@aFldCBAtu[1])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Folder dos Fornecedores                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oFolder:aDialogs[2]:oFont := oDlg:oFont
			oFolder:bSetOption := {|nDst| NfeFldChg(nDst,oFolder:nOption,oFolder,aFldCBAtu)}
			NfeFldFor(oFolder:aDialogs[2],aInfForn,{aPosGet[4],aPosGet[5],aPosGet[6]},@aFldCBAtu[2])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Folder das Despesas acessorias e descontos                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oFolder:aDialogs[3]:oFont := oDlg:oFont
			NfeFldDsp(oFolder:aDialogs[3],a140Desp,{aPosGet[7],aPosGet[8]},@aFldCBAtu[3])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Folder de conferencia para os coletores                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If l140Visual .And. (SuperGetMV("MV_CONFFIS",.F.,"N") == "S")
				oFolder:aDialogs[4]:oFont := oDlg:oFont
				Do Case
				Case SF1->F1_STATCON $ "1 "
					cStatCon := "NF conferida"
				Case SF1->F1_STATCON == "0"
					cStatCon := "NF nao conferida"
				Case SF1->F1_STATCON == "2"
					cStatCon := "NF com divergencia"
				Case SF1->F1_STATCON == "3"
					cStatCon := "NF em conferencia"
				EndCase
				nQtdConf := SF1->F1_QTDCONF
				@ 06 ,aPosGet[6,1] SAY "Status"      OF oFolder:aDialogs[4] PIXEL SIZE 49,09 //"Status"
				@ 05 ,aPosGet[6,2] MSGET oStatCon VAR Upper(cStatCon) COLOR CLR_RED OF oFolder:aDialogs[4] PIXEL SIZE 70,9 When .F.
				@ 25 ,aPosGet[6,1] SAY "Conferentes" OF oFolder:aDialogs[4] PIXEL SIZE 49,09 //"Conferentes"
				@ 24 ,aPosGet[6,2] MSGET oConf Var nQtdConf OF oFolder:aDialogs[4] PIXEL SIZE 70,09 When .F.
				@ 05 ,aPosGet[5,3] LISTBOX oList Fields HEADER "  ","Codigo","Quantidade Conferida" SIZE 170, 48 OF oFolder:aDialogs[4] PIXEL //"Codigo"###"Quantidade Conferida"
				oList:BLDblclick := {||A140DetCon(oList,aListBox)}

				DEFINE TIMER oTimer INTERVAL 3000 ACTION (A140AtuCon(oList,aListBox,oEnable,oDisable,oConf,@nQtdConf,oStatCon,@cStatCon,,oTimer)) OF oDlg
				oTimer:Activate()

				@ 30 ,aPosGet[5,3]+180 BUTTON "Recontagem" SIZE 40 ,11  FONT oDlg:oFont ACTION (A140AtuCon(oList,aListBox,oEnable,oDisable,oConf,@nQtdConf,oStatCon,@cStatCon,.T.,oTimer)) OF oFolder:aDialogs[4] PIXEL When SF1->F1_STATCON == '2' //"Recontagem"
				@ 42 ,aPosGet[5,3]+180 BUTTON "Detalhes" SIZE 40 ,11  FONT oDlg:oFont ACTION (A140DetCon(oList,aListBox)) OF oFolder:aDialogs[4] PIXEL //"Detalhes"

				A140AtuCon(oList,aListBox,oEnable,oDisable)
			EndIf
			Eval(bRefresh)
			ACTIVATE MSDIALOG oDlg ON INIT Ma140Bar(oDlg,{||If(oGetDados:TudoOk().And.NfeNextDoc(@cNFiscal,@cSerie,l140Inclui),(nOpcA:=1,oDlg:End()),nOpcA:=0)},{||oDlg:End()},aButtons)
		EndIf

		lMsErroAuto := .F.

		If nOpcA == 0

			//SetKey(VK_F5,bSavKeyF5)
			//SetKey(VK_F6,bSavKeyF6)
			//SetKey(VK_F7,bSavKeyF7)
			//SetKey(VK_F10,bSavKeyF10)

			Return(.F.) 

		EndIf

		//Verifica nota fiscal de origem quando for devolução
		If cTipo $ "D"

			nPosNfeOri := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_NFORI" })      //HF
			nPosSerOri := aScan(aHeader,{|x| Alltrim(x[2]) == "D1_SERIORI" })     //HF

			For nIa := 1 To Len( aCols )

	   			if Empty(aCols[nIa][nPosNfeOri]) .or. Empty(aCols[nIa][nPosSerOri])

					Alert( "Nota de Origem e Serie não foram informados." +CRLF+ "Por favor informar" )
					Return(.F.) 

				endif

			Next nIa

		endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Integracao com o ACD			  				  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If l140Exclui .And. lIntACD .And. FindFunction("CBA140EXC") 
			nOpcA := IIF(CBA140EXC(),nOpcA,0)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Template acionando Ponto de Entrada                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ElseIf l140Exclui .And. nOpcA == 1 .And. ExistTemplate("A140EXC")
			nOpcA := IIF(ExecTemplate("A140EXC",.F.,.F.),nOpcA,0)
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ponto de entrada para validar a exclusao de um pre-documento ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If l140Exclui .And. nOpcA == 1 .And. ExistBlock("A140EXC")
			nOpcA := IIF(ExecBlock("A140EXC",.F.,.F.),nOpcA,0)
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualizacao do pre-documento de entrada                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nOpcA == 1 .AND. ( l140Inclui .OR. l140Altera .OR. l140Exclui ) .AND. ( Type( "lOnUpDate" ) == "U" .OR. lOnUpdate ) 
			//----------------------------------------------------------------//
			//FR 12/05/2020 chamar aqui a TELA DE DIVERGÊNCIAS ANTES DE GRAVAR
			//----------------------------------------------------------------//
			//FR - 23/06/2020 - a Tela de Divergências completa não será mostrada na Pré-Nota conforme alinhado em reunião com RAfael em 23/06/2020
			/*
			If cUsaDvg == "S"   	//FR 19/05/2020
			
				If !lTevePCTES  	//FR - 19/06/2020 - caso não tenha havido pedido de compra com TES para checagem prévia de divergências, mostra a tela diverg. na pré-nota
				  					//FR - 19/06/2020 - pois pode ser que o usuário mude algum campo na pré nota (qtde, valor unitário ou total dá pra mudar)
					lOmitTela := Nil
					lOk       := U_HFXML063(cChaveXml,aCabNFE,aIteNFE, "PRÉ-NOTA FISCAL",,lOmitTela)	//FR tela divergências: caso haja divergência será dada opção ao usuário prosseguir ou abortar.
					If lOk
						U_Ma140Grv( l140Exclui, aRecSD1, a140Desp )
					Else
							Aviso(	"Pré-Documento de Entrada",;
						"A nota não poderá ser incluída, Motivo: Divergências" + CHR(13) + CHR(10) +;
						"Favor entrar em contato com o Administrador",;
						{"&Ok"},,;
						"XML x NF")
						nOpcA := 0    //o conteúdo desta variável indica o retorno: grava / não grava
					Endif
				Else
					U_Ma140Grv( l140Exclui, aRecSD1, a140Desp )
				Endif
			Else
				U_Ma140Grv( l140Exclui, aRecSD1, a140Desp )
			Endif
			*/
			
			U_Ma140Grv( l140Exclui, aRecSD1, a140Desp ) //FR - 23/06/2020 - GRAVA A PRÉ NOTA SEM MOSTRAR A TELA DE DIVERGÊNCIAS, CONFORME REUNIÃO COM RAFAEL
				
		ElseIf l140Auto
			If ( nPos := AScan( aAutoCab, { |x| x[1] == "F1_FILIAL" } ) ) > 0
				aAutoCab[nPos][2] := xFilial( "SF1" )
			Else
				AAdd( aAutoCab, { "F1_FILIAL", xFilial( "SF1" ), NIL } )
			Endif

			If ( nPos := AScan( aAutoCab, { |x| x[1] == "F1_DOC" } ) ) > 0
				aAutoCab[nPos][2] := cNFiscal
			Else
				AAdd( aAutoCab, { "F1_DOC", cNFiscal, NIL } )
			Endif
	
			If ( nPos := AScan( aAutoCab, { |x| x[1] == "F1_SERIE" } ) ) > 0
				aAutoCab[nPos][2] := cSerie
			Else
				AAdd( aAutoCab, { "F1_SERIE", cSerie, NIL } )
			Endif
	
			If ( nPos := AScan( aAutoCab, { |x| x[1] == "F1_FORNECE" } ) ) > 0
				aAutoCab[nPos][2] := cA100For
			Else
				AAdd( aAutoCab, { "F1_FORNECE", cA100For, NIL } )
			Endif
	
			If ( nPos := AScan( aAutoCab, { |x| x[1] == "F1_LOJA" } ) ) > 0
				aAutoCab[nPos][2] := cLoja
			Else
				AAdd( aAutoCab, { "F1_LOJA", cLoja, NIL } )
			Endif
	
			If ( nPos := AScan( aAutoCab, { |x| x[1] == "F1_EMISSAO" } ) ) > 0
				aAutoCab[nPos][2] := dDEmissao
			Else
				AAdd( aAutoCab, { "F1_EMISSAO", dDEmissao, NIL } )
			Endif
	
			If ( nPos := AScan( aAutoCab, { |x| x[1] == "F1_EST" } ) ) > 0
				aAutoCab[nPos][2] := IIF( cTipo $ "DB", SA1->A1_EST, SA2->A2_EST )
			Else
				AAdd( aAutoCab, { "F1_EST", IIF( cTipo $ "DB", SA1->A1_EST, SA2->A2_EST ), NIL } )
			Endif
	
			If ( nPos := AScan( aAutoCab, { |x| x[1] == "F1_TIPO" } ) ) > 0
				aAutoCab[nPos][2] := cTipo
			Else
				AAdd( aAutoCab, { "F1_TIPO", cTipo, NIL } )
			Endif
	
			If ( nPos := AScan( aAutoCab, { |x| x[1] == "F1_DTDIGIT" } ) ) > 0
				aAutoCab[nPos][2] := dDataBase
			Else
				AAdd( aAutoCab, { "F1_DTDIGIT", dDataBase, NIL } )
			Endif
	
			If ( nPos := AScan( aAutoCab, { |x| x[1] == "F1_RECBMTO" } ) ) > 0
				aAutoCab[nPos][2] := SF1->F1_DTDIGIT
			Else
				AAdd( aAutoCab, { "F1_RECBMTO", SF1->F1_DTDIGIT	, NIL } )
			Endif
	
			If ( nPos := AScan( aAutoCab, { |x| x[1] == "F1_FORMUL" } ) ) > 0
				aAutoCab[nPos][2] := IIF( cFormul == "S", "S", " " )
			Else
				AAdd( aAutoCab, { "F1_FORMUL", IIF( cFormul == "S", "S", " " ), NIL } )
			Endif
	
			If ( nPos := AScan( aAutoCab, { |x| x[1] == "F1_ESPECIE" } ) ) > 0
				aAutoCab[nPos][2] := cEspecie
			Else
				AAdd( aAutoCab, { "F1_ESPECIE", cEspecie, NIL } )
			Endif
	
			If ( nPos := AScan( aAutoCab, { |x| x[1] == "F1_DESPESA" } ) ) > 0
				aAutoCab[nPos][2] := a140Desp[VALDESP]
			Else
				AAdd( aAutoCab, { "F1_DESPESA", a140Desp[VALDESP], NIL } )
			Endif
	
			If ( nPos := AScan( aAutoCab, { |x| x[1] == "F1_FRETE" } ) ) > 0
				aAutoCab[nPos][2] := a140Desp[FRETE]
			Else
				AAdd( aAutoCab, { "F1_FRETE", a140Desp[FRETE], NIL } )
			Endif
	
			If ( nPos := AScan( aAutoCab, { |x| x[1] == "F1_SEGURO" } ) ) > 0
				aAutoCab[nPos][2] := a140Desp[SEGURO]
			Else
				AAdd( aAutoCab, { "F1_SEGURO", a140Desp[SEGURO]	, NIL } )
			Endif
	
			If ( nPos := AScan( aAutoCab, { |x| x[1] == "F1_VALMERC" } ) ) > 0
				aAutoCab[nPos][2] := a140Total[VALMERC]
			Else
				AAdd( aAutoCab, { "F1_VALMERC", a140Total[VALMERC], NIL } )
			Endif
	
			If ( nPos := AScan( aAutoCab, { |x| x[1] == "F1_DESCONT" } ) ) > 0
				aAutoCab[nPos][2] := a140Total[VALDESC]
			Else
				AAdd( aAutoCab, { "F1_DESCONT", a140Total[VALDESC], NIL } )
			Endif
	
			If ( nPos := AScan( aAutoCab, { |x| x[1] == "F1_VALBRUT" } ) ) > 0
				aAutoCab[nPos][2] := a140Total[TOTPED]
			Else
				AAdd( aAutoCab, { "F1_VALBRUT", a140Total[TOTPED], NIL } )
			Endif
	
			aAutoItens := MsAuto2Gd( aHeader, aCols )
		EndIf
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Destrava os registros na alteracao e exclusao                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsUnlockAll()
//SetKey(VK_F5,bSavKeyF5)
//SetKey(VK_F6,bSavKeyF6)
//SetKey(VK_F7,bSavKeyF7)
//SetKey(VK_F10,bSavKeyF10)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ O ponto de entrada e disparado apos o RestArea pois pode ser utilizado para posicionar o Browse ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "MT140SAI" )
	ExecBlock( "MT140SAI", .F., .F., { aRotina[ nOpcx, 4 ], cNFiscal, cSerie, cA100For, cLoja, cTipo, nOpcA } )
EndIf

Return((nOpcA<>0))


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun??o    ³NfeFormul ³Autor  ³ Eduardo Riera         ³ Data ³16.09.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de validacao do formulario proprio do documento de    ³±±
±±³          ³entrada                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Formulario proprio (S/N)                              ³±±
±±³          ³ExpC2: Numero do documento de entrada                        ³±±
±±³          ³ExpA3: Serie do documento de entrada                         ³±±
±±³          ³ExpO4: Objeto say para atualizar o texto                     ³±±
±±³          ³ExpO5: Objeto Get para atualizar o codigo do fornecedor      ³±±
±±³          ³ExpO6: Objeto Get para atualizar o codigo da loja            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Formulario valido                                     ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³Esta rotina tem como objetivo validar se o formulario eh pro-³±±
±±³          ³prio ( S/N )                                                 ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function NfeFormul(cFormul,cNota,cSerie,oNFiscal,oSerie)
Local cXEspecie:=""

If Type("cFunTipo") == "U"
	Static cFunTipo := ""
EndIf

If cFormul == "S"
	cNota		:= CriaVar("F1_DOC",.F.)
	cSerie  	:= SerieNfId("SF1",5,"F1_SERIE")
EndIf

//---------------------------//
//Ponto de Entrada: MT103ESP //
//---------------------------//
If ExistBlock("MT103ESP")     
	cXEspecie := ExecBlock("MT103ESP",.F.,.F.,{cFormul})    
	If (ValType(cXEspecie) == 'C' )
		cEspecie := Padr(cXEspecie,TamSX3("F1_ESPECIE")[1])
	EndIf
EndIf

If oNFiscal<>Nil
	oNFiscal:Refresh()
EndIf
If oSerie<>Nil
	oSerie:Refresh()
EndIf             
If oNFiscal<>Nil .And. Empty(cFunTipo)
	IF cFormul == "N"
		oNFiscal:Setfocus()
	EndIf
EndIf

cFunTipo:= ""

Return(.T.)    



User Function HFNfeCab(oDlg,aPosGet,bRefresh,lVisual,lFiscal,cUfOrig,lClassif,lPreNota,nCombo,oCombo,cCodRet,oCodRet,lNfMedic,aCodR,cRecIss,cNatureza,l140Altera)
Local aObjetos   := Array(11)
Local lTpCompl   := SF1->(ColumnPos("F1_TPCOMPL")) > 0 .And. Type("cTpCompl") == "C"
Local aCombo1    := {	"Normal",;	//"Normal"
						"Devolucao",;	//"Devolucao"
						"Beneficiamento",;	//"Beneficiamento"
						"Compl.  ICMS",;	//"Compl.  ICMS"
						"Compl.  IPI",;	//"Compl.  IPI"
						"Compl. Preco/Frete"} 	//"Compl. Preco/Frete"
Local aCombo2    := {"Nao","Sim"} //###
Local aCombo3    := {"","1=Preco","2=Quantidade","3=Frete"}
Local aCombo2Lan := {"Nao","Sim","Sim"} // Nao retirar, abrange language=English
Local aAuxCombo1 := {"N","D","B","I","P","C"}
Local aAuxCombo2 := {"N","S","Y"}
Local aAuxCombo3 := {"","1","2","3"}

Local c103SayForn:= IIf(cTipo$"DB",RetTitle("F2_CLIENTE"),RetTitle("F1_FORNECE"))
Local c103Tipo	 := ""
Local c103TpComp := ""  //novo
Local c103Form	 := cFormul
Local cCar       := CHR(34)+CHR(39)        // Caracteres que não serão permitidos na digitação do campo: Nota e Série
Local nAux       := aScan(aAuxCombo1,cTipo)
Local lGspInUseM := If(Type('lGspInUse')=='L', lGspInUse, .F.)
Local nTamGetFor := 45          
Local nScreen    := GetScreenRes()[1]
Local nEspLoja   := 0 
Local nAltNFE    := 0

Local lUfOrig    := ( ValType( cUfOrig ) == "C" )
Local lMt103CPS  := Existblock("MT103CPS")
Local oNfMedic   := .F. 
Local lUsaNewKey := TamSX3("F1_SERIE")[1] == 14 // Verifica se o novo formato de gravacao do Id nos campos _SERIE esta em uso

Local lIntGfe := SuperGetMV("MV_INTGFE",.F.,.F.)

lClassif:= If( ValType( lClassif ) == "L" , lClassif, .F.) 

cFormul := If( ValType( cFormul ) <> "C" .Or. Empty(cFormul) , "N", cFormul ) 

DEFAULT lPreNota 		:= .F.
DEFAULT l140Altera	:= .F.
Default aCodR	 		:= {}
Default cRecIss	 	:= "1"
Default cNatureza		:= ""

If lPreNota
	nEspLoja   := Iif(nScreen<1280 .And. !lVisual, 5,-3)
Else
	nEspLoja   := Iif(nScreen<1280 .And. !lVisual, 5,1)
EndIF					
nAltNFE    := Iif(lPreNota .And. ALTERA  ,15 ,0)   

//aCombo1    := IIF(lPreNota,{"Normal","Devolucao","Beneficiamento","Compl. Preco/Frete"},{"Normal","Devolucao","Compl.  ICMS","Compl.  ICMS","Compl.  IPI","Compl. Preco/Frete"}) //STR0001> STR0002> STR0003> STR0004> STR0005> STR0006>
//aAuxCombo1 := IIF(lPreNota,{"N","D","B","C"},{"N","D","B","I","P","C"})
nAux       := aScan(aAuxCombo1,cTipo)

If !Empty(cTipo) .And. nAux <> 0
	c103Tipo := aCombo1[nAux]
EndIf
nAux := aScan(aAuxCombo2,cFormul)
If !Empty(cFormul) .And. nAux <> 0
	c103Form := aCombo2Lan[nAux]
EndIf

If lTpCompl
	nAux := aScan(aAuxCombo3,cTpCompl)
	If !Empty(cTpCompl) .And. nAux <> 0
		c103TpComp := aCombo3[nAux]
	EndIf
EndIf

If !lNfMedic
	If TamSX3("A2_COD")[1]< 9 
		nTamGetFor:=(6*TamSX3("A2_COD")[1])
	ElseIf TamSX3("A2_COD")[1]< 15
		nTamGetFor:=(4.8*TamSX3("A2_COD")[1])
	Else
		nTamGetFor:=(4*TamSX3("A2_COD")[1])
	EndIf
EndIf
@ aPosGet[3,1],aPosGet[3,2] TO aPosGet[3,3],aPosGet[3,4] LABEL "" OF oDlg PIXEL

@ aPosGet[3,1]+(2,6),aPosGet[1,1] SAY RetTitle("F1_TIPO") OF oDlg PIXEL SIZE 35,09
@ aPosGet[3,1]+(2,5),aPosGet[1,2] MSCOMBOBOX aObjetos[1] VAR c103Tipo ITEMS aCombo1 SIZE 60,90;
	WHEN !lVisual .And. !IsInCallStack("U_YMATA116") .And. !IsInCallStack("U_XMATA116") .And. A103ChWhen("F1_TIPO",c103Tipo,lClassif) ;
	VALID NfeCombo(@cTipo,aCombo1,c103Tipo,aAuxCombo1).And.NfeTipo(cTipo,@cA100For,@cLoja,aObjetos[6],aObjetos[7],aObjetos[8],oDlg); 
	OF oDlg PIXEL

If lTpCompl
//Alert( IsInCallStack("U_YMATA116") )
	aObjetos[1]:bChange := {||A103TpComp(@aObjetos,c103Tipo,@c103TpComp)}

	//@ aPosGet[3,1]+(2,6),aPosGet[1,3]-15 SAY RetTitle("F1_TPCOMPL") SIZE 35,09 OF oDlg PIXEL 
	//@ aPosGet[3,1]+(2,5),aPosGet[1,4]-35 MSCOMBOBOX aObjetos[11] VAR cTpCompl ITEMS aCombo1x SIZE 50,90 OF oDlg PIXEL WHEN U_HFTPCTPL(c103Tipo,cTpCompl)
//    //WHEN !lVisual .And. !IsInCallStack("U_YMATA116") .And. !IsInCallStack("U_XMATA116") .And. c103Tipo == "Complemento";
	@ aPosGet[3,1]+(2,6),aPosGet[1,3] SAY RetTitle("F1_TPCOMPL") Of oDlg PIXEL SIZE 52,09
	@ aPosGet[3,1]+(2,5),aPosGet[1,4] MSCOMBOBOX aObjetos[11] VAR c103TpComp ITEMS aCombo3 SIZE 50,100 ;
		WHEN U_HFTPCTPL(c103Tipo,cTpCompl) .And. !IsInCallStack("U_YMATA116") .And. !IsInCallStack("U_XMATA116");
		VALID NfeCombo(@cTpCompl,aCombo3,c103TpComp,aAuxCombo3,"3") .And. NfeTipo(cTipo,@cA100For,@cLoja,aObjetos[6],aObjetos[7],aObjetos[8],,cTpCompl);
		OF oDlg PIXEL

	If !lGspInUseM
		@ aPosGet[3,1]+(2,6),aPosGet[1,3]+120 SAY RetTitle("F1_FORMUL") Of oDlg PIXEL SIZE 52,09
		@ aPosGet[3,1]+(2,5),aPosGet[1,4]+120 MSCOMBOBOX aObjetos[2] VAR c103Form ITEMS aCombo2 SIZE 25,50 ;
			WHEN !lVisual .And. A103ChWhen("F1_FORMUL",c103Form,lClassif) ;
			VALID NfeCombo(@cFormul,aCombo2Lan,c103Form,aAuxCombo2,"2").And.NfeFormul(cFormul,@cNFiscal,@cSerie,aObjetos[3],@aObjetos[4]) ;
			OF oDlg PIXEL                            
	EndIf

ElseIf !lGspInUseM
	@ aPosGet[3,1]+(2,6),aPosGet[1,3]+80 SAY RetTitle("F1_FORMUL") Of oDlg PIXEL SIZE 32,09
	@ aPosGet[3,1]+(2,5),aPosGet[1,4]+80 MSCOMBOBOX aObjetos[2] VAR c103Form ITEMS aCombo2 SIZE 25,50 ;
		WHEN !lVisual .And. A103ChWhen("F1_FORMUL",c103Form,lClassif) ;
		VALID NfeCombo(@cFormul,aCombo2Lan,c103Form,aAuxCombo2,"2").And.NfeFormul(cFormul,@cNFiscal,@cSerie,aObjetos[3],@aObjetos[4]) ;
		OF oDlg PIXEL
Endif

@ aPosGet[3,1]+(2,6),aPosGet[1,5] SAY RetTitle("F1_DOC") Of oDlg PIXEL SIZE 45,09
@ aPosGet[3,1]+(2,5),aPosGet[1,6] MSGET aObjetos[3] VAR cNFiscal PICTURE PesqPict("SF1","F1_DOC") ;
	WHEN !lVisual.And.VisualSX3("F1_DOC") .And.cFormul<>"S" .And. A103ChWhen("F1_DOC",cNFiscal,lClassif) ;
	VALID NfeFornece(cTipo,@cA100For,@cLoja,,@nCombo,@oCombo,@cCodRet,@oCodRet,@aCodR,@cRecIss,@cNatureza).And.CheckSX3("F1_DOC") .And. !A103VldCpo(cNfiscal,cCar);
	OF oDlg PIXEL SIZE 46,09 
	
@ aPosGet[3,1]+(2,6),aPosGet[1,7] SAY RetTitle("F1_SERIE") Of oDlg PIXEL SIZE 23,09
@ aPosGet[3,1]+(2,5),aPosGet[1,8] MSGET aObjetos[4] VAR cSerie  PICTURE PesqPict("SF1","F1_SERIE") ;
    F3 IIF( lMT103CPS,ExecBlock("MT103CPS",.F.,.F.),"");
    WHEN !lVisual.And.VisualSX3('F1_SERIE').And.cFormul<>"S" .And. A103ChWhen("F1_SERIE",cSerie,lClassif);
	VALID NfeFornece(cTipo,@cA100For,@cLoja,,@nCombo,@oCombo,@cCodRet,@oCodRet,@aCodR,@cRecIss,@cNatureza).And.CheckSX3("F1_SERIE") .And. !A103VldCpo(cSerie,cCar);
	OF oDlg PIXEL SIZE 18,09
	
If cPaisLoc == "PTG"
	@ aPosGet[3,1]+(2,6),aPosGet[1,9] SAY RetTitle("F1_DIACTB") Of oDlg PIXEL SIZE 30,09
	@ aPosGet[3,1]+(2,5),aPosGet[1,10] MSGET aObjetos[10] VAR cCodDiario PICTURE PesqPict("SF1","F1_DIACTB") WHEN !lVisual .And. VisualSX3("F1_DIACTB") F3 CpoRetF3("F1_DIACTB") ;
	    VALID CheckSX3("F1_DIACTB") OF oDlg PIXEL SIZE 30,09 HASBUTTON
EndIf
@ aPosGet[3,1]+25,aPosGet[2,1] SAY RetTitle("F1_EMISSAO") OF oDlg PIXEL SIZE 35,09
@ aPosGet[3,1]+24,aPosGet[2,2] MSGET aObjetos[5] VAR dDEmissao PICTURE PesqPict("SF1","F1_EMISSAO") ;
	WHEN (!lVisual .or. lClassif).And.VisualSX3("F1_EMISSAO").And. A103ChWhen("F1_EMISSAO",dDEmissao,lClassif) Valid CheckSX3("F1_EMISSAO") .And. NfeEmissao(dDEmissao) ;
	OF oDlg PIXEL SIZE 45 ,9 HASBUTTON

If Valtype( lNfMedic ) == "L" .And. !lVisual .And. A103GCDisp() // Indica se exibe CheckBox de carga das medicoes de contratos
	@ aPosGet[3,1]+25,aPosGet[2,3]-15 SAY aObjetos[6] VAR c103SayForn Of oDlg PIXEL SIZE 43,09
	@ aPosGet[3,1]+24,aPosGet[2,4]-35 MSGET aObjetos[7] VAR cA100For  ;
		PICTURE PesqPict("SF1","F1_FORNECE") F3 CpoRetF3("F1_FORNECE");
		WHEN !lVisual.And.VisualSX3("F1_FORNECE").And. A103ChWhen("F1_FORNECE",cA100For,lClassif) ;
		VALID NfeFornece(cTipo,@cA100For,@cLoja,@cUfOrig,@nCombo,@oCombo,@cCodRet,@oCodRet,@aCodR,@cRecIss,@cNatureza).And.CheckSX3("F1_FORNECE",cA100For).And.NfeVldRef("NF_CODCLIFOR",cA100For) ;
		OF oDlg PIXEL SIZE nTamGetFor,09 HASBUTTON
Else
	@ aPosGet[3,1]+25,aPosGet[2,3]-10 SAY aObjetos[6] VAR c103SayForn Of oDlg PIXEL SIZE 43,09
	@ aPosGet[3,1]+24,aPosGet[2,4]-nAltNFE MSGET aObjetos[7] VAR cA100For  ;
		PICTURE PesqPict("SF1","F1_FORNECE") F3 CpoRetF3("F1_FORNECE");
		WHEN !lVisual.And.VisualSX3("F1_FORNECE").And. A103ChWhen("F1_FORNECE",cA100For,lClassif) ;
		VALID NfeFornece(cTipo,@cA100For,@cLoja,@cUfOrig,@nCombo,@oCombo,@cCodRet,@oCodRet,@aCodR,@cRecIss,@cNatureza).And.CheckSX3("F1_FORNECE",cA100For).And.NfeVldRef("NF_CODCLIFOR",cA100For) ;
		OF oDlg PIXEL SIZE nTamGetFor,09 HASBUTTON 
		
		If IsInCallStack("MATA119")  
			NfeFornece(cTipo,@cA100For,@cLoja,@cUfOrig,@nCombo,@oCombo,@cCodRet,@oCodRet,@aCodR,@cRecIss,@cNatureza)
	    EndIf
EndIf
@ aPosGet[3,1]+24,aPosGet[2,5]+nEspLoja MSGET aObjetos[8] VAR cLoja ;
	PICTURE PesqPict("SF1","F1_LOJA") ;
	F3 CpoRetF3("F1_LOJA") ;
	WHEN !lVisual.And.VisualSX3("F1_LOJA") .And. A103ChWhen("F1_LOJA",cLoja,lClassif);
	VALID NfeFornece(cTipo,@cA100For,@cLoja,@cUfOrig,@nCombo,@oCombo,@cCodRet,@oCodRet,@aCodR,@cRecIss,@cNatureza).And.CheckSX3("F1_LOJA",cLoja).And.NfeVldRef("NF_LOJA",cLoja) ;	
	OF oDlg PIXEL SIZE 15,09 HASBUTTON

If !lGspInUseM
	
	@ aPosGet[3,1]+25,aPosGet[2,6]+nAltNFE SAY RetTitle("F1_ESPECIE") Of oDlg PIXEL SIZE 63,09
	@ aPosGet[3,1]+24,aPosGet[2,7]+nAltNFE MSGET aObjetos[9] VAR cEspecie ;
		PICTURE PesqPict("SF1","F1_ESPECIE") ;
		F3 CpoRetF3("F1_ESPECIE");
		WHEN (lClassif.Or.!lVisual).And.VisualSX3("F1_ESPECIE").And. A103ChWhen("F1_ESPECIE",cEspecie,lClassif);
		VALID CheckSX3("F1_ESPECIE",cEspecie) .And. Iif(lIntGfe,A103VldEsp(cEspecie),.T.)	.And. ;
        IIf( lUsaNewKey , NfeFornece(cTipo,@cA100For,@cLoja,@cUfOrig,@nCombo,@oCombo,@cCodRet,@oCodRet,@aCodR,@cRecIss,@cNatureza) , .T.) ;
		OF oDlg PIXEL SIZE 30,09 HASBUTTON

	If lUfOrig
		@ aPosGet[3,1]+25,aPosGet[2,8]+nAltNFE SAY OemToAnsi("UF.Origem") Of oDlg PIXEL SIZE 63 ,9 // UF.Origem
		@ aPosGet[3,1]+24,aPosGet[2,9]+nAltNFE MSGET cUfOrig PICTURE "@!" F3 "12" ;
			When !lVisual.And.VisualSX3('F1_EST').And. A103ChWhen("F1_EST",cUfOrig,lClassif) Valid CheckSX3('F1_EST',cUfOrig) .And. ;
			MaFisAlt( "NF_UFORIGEM", cUfOrig ) .And. Eval( bGdRefresh ) OF oDlg PIXEL SIZE 20,9 HASBUTTON
	EndIf

Endif        
                            
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Indica se exibe CheckBox de carga das medicoes de contratos         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Valtype( lNfMedic ) == "L" .And. (!lVisual .Or. l140Altera) .And. A103GCDisp()   
	@ aPosGet[3,1]+25,aPosGet[2,10] SAY "Filtra Medicao" Of oDlg PIXEL SIZE 63,09 // "Filtra Medicao"
	@ aPosGet[3,1]+24,aPosGet[2,10] + 44 CHECKBOX oNfMedic VAR lNfMedic PROMPT "" SIZE 008,010 ON CLICK( oNfMedic:Refresh() ) OF oDlg PIXEL
EndIf                                                                                         	

bRefresh := {|| NfeCabOk(lVisual,aObjetos[1],aObjetos[3],aObjetos[5],aObjetos[7],aObjetos[8],lFiscal,cUfOrig,,,aObjetos[9],.T.,aObjetos[11],c103TpComp)}

aObjetos[1]:SetFocus()

//Salva o cTipo
If Empty(cTipo)
	NfeCombo(@cTipo,aCombo1,c103Tipo,aAuxCombo1,"1")
Endif  


Return(.T.)

user function HFTPCTPL(cTp,cTpCompl) //ECOURBS
Local lRet := .T.

if cTp <> "Normal" .And. cTp <> "Devolucao" .And. cTp <>  "Beneficiamento"
	lRet := .T.
Else
	lRet := .F.
Endif

Return( lRet )


Static Function NfeCombo(cVariavel,aCombo,cCombo,aReferencia,cIdent)
Local nPos	:= aScan(aCombo,cCombo)
Local nPosq := aScan(aHeader,{|x| AllTrim(x[2])=="D1_QUANT"})         //HF
Local nPosProd := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_COD"} )
Local lRet  := (nPos>0)
Local nUd   := 0
//alert( cCombo )
If Type("cFunTipo") == "U"
//	Static cFunTipo := ""
EndIf
   //HF cModelo == "57" isso aqui é para a udison e deixar o complemento de IPI e ICMS liberado dessa mensagem
If cModelo == "57" .And. !Empty(cVariavel) .And. (nPos>0 .and. cVariavel <> aReferencia[nPos]) .And. ( Len(aReferencia) == 6 .Or. Len(aReferencia) == 4); // Verifica se o Combo editado e o Tipo da NFE (Len()=6) em detrimento ao do Formulario Proprio (Len()=2). 
	.And. (Len(aCols) > 1 .Or. !Empty(aCols[1][2])) //verifica se tem informação no aCols para excluir(no caso zerar)
	If MsgYesNo("Ao alterar o tipo da Nota os itens já digitados serão zerados. Deseja continuar?","ATENÇÃO") //STR0071
		//if Len(aCols) > 1 //If IsInCallStack("MATA140")  //TUDO ISSO SO PARA COMENTAR ESSA MERDA AQUI......
		//	A103LimpIT(cTipo,cA100For,cLoja)  //tirei os @ para permanecer o fornecedor
		//EndIf
		//if Len(aCols) == 1  modificardo para Udisão
		For nUd := 1 To Len( aCols )
			//zerar a qtd udison
			if nPosq > 0
				aCols[nUd][nPosq] := 0
				If bGdRefresh<>Nil
					Eval(bGDRefresh)
				EndIf
				If bRefresh<>Nil
					Eval(bRefresh)
				EndIf
			endif
		Next nUd
		If nPos > 0
			cVariavel := aReferencia[nPos]
		EndIf
    Else
        lRet := .F.
	EndIf
ElseIf cIdent == "3" //Tipo de Complemento
	If cVariavel <> aReferencia[nPos] .And. (Len(aCols) > 1 .Or. !Empty(aCols[1][nPosProd]))
		//If MsgYesNo("Ao alterar o tipo da Nota os itens ja digitados serao excluidos. Deseja continuar?","ATENÇÃO") //"Ao alterar o tipo da Nota os itens ja digitados serao excluidos. Deseja continuar?"
			If IsInCallStack("MATA140")
				//A103LimpIT(cTipo,@cA100For,@cLoja)
			EndIf
			If nPos > 1
				cVariavel := aReferencia[nPos]
			Else
				lRet := .F.
			EndIf
		//Else
	    //   	lRet := .F.
		//EndIf
	Else
		If nPos > 1
			cVariavel := aReferencia[nPos]
		EndIf
	EndIf
Else
	If nPos > 0
		cVariavel := aReferencia[nPos]
	EndIf
EndIf

If cIdent == "1" //Tipo
	c103Tp := cVariavel
Endif


Return (lRet)


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³U_Ma140LOk³ Autor ³ Eduardo Riera         ³ Data ³02.10.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Validacao da Getdados - LinhaOk                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto da getdados                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Indica se a linha digitada eh valida                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo validar um item do pre-documen-³±±
±±³          ³to de entrada                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function Ma140LOk(lInit,nModo) //User

Local aArea			:= GetArea()
Local lRetorno		:= .F.
Local nPosCod		:= aScan(aHeader,{|x|Alltrim(x[2])=="D1_COD"})
Local nPosLocal		:= aScan(aHeader,{|x|Alltrim(x[2])=="D1_LOCAL"})
Local nPosQuant		:= aScan(aHeader,{|x|Alltrim(x[2])=="D1_QUANT"})
Local nPosVUnit		:= aScan(aHeader,{|x|Alltrim(x[2])=="D1_VUNIT"})
Local nPosTotal		:= aScan(aHeader,{|x|Alltrim(x[2])=="D1_TOTAL"})
Local nPosPC		:= aScan(aHeader,{|x|Alltrim(x[2])=="D1_PEDIDO"})
Local nPosItemPC	:= aScan(aHeader,{|x|Alltrim(x[2])=="D1_ITEMPC"})
Local lPCNFE		:= GetNewPar( "MV_PCNFE", .F. ) //-- Nota Fiscal tem que ser amarrada a um Pedido de Compra ?
Local nPosServic	:= aScan(aHeader, {|x|Upper(Alltrim(x[2]))=='D1_SERVIC'})  
Local lMT140PC


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada para o tratamento do parâmetro MV_PCNFE (Nota Fiscal tem que ser amarrada a um Pedido de Compra ?)      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (ExistBlock("MT140PC"))  
	lMT140PC  := ExecBlock("MT140PC",.F.,.F.,{lPCNFE})    
	If ( ValType(lMT140PC ) == 'L' )
		lPCNFE := lMT140PC 
	EndIf
EndIf      

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica preenchimento dos campos da linha do acols      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If CheckCols(n,aCols)
	If !aCols[n][Len(aCols[n])]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Quando Informado Armazem em branco considerar o B1_LOCPAD   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty(aCols[n][nPosLocal])
			SB1->(dbSetOrder(1))
				If SB1->(MsSeek(xFilial("SB1")+aCols[n][nPosCod]))
				aCols[n][nPosLocal] := SB1->B1_LOCPAD
				If Type("l140Auto") <> "U" .And. !l140Auto
					If !lInit
						U_MyAviso(OemToAnsi("Atencao"),OemToAnsi("O Armazem informado e Invalido, o campo sera ajustando com o armazem padrão do cadastro de produtos"),{"Ok"}) //Atencao##O Armazem informado e Invalido, o campo sera ajustando com o armazem padrão do cadastro de produtos
					EndIf
				EndIf	
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o produto est  sendo inventariado.      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Do Case
		Case Empty(aCols[n][nPosCod]) .Or. ;
				(Empty(aCols[n][nPosQuant]).And.cTipo$"NDB").Or. ;
				Empty(aCols[n][nPosVUnit]) .Or. ;
				Empty(aCols[n][nPosTotal])
			Help("  ",1,"A140VZ")
			lRetorno := .F.			
		Case nPosPC > 0 .And. !Empty(aCols[n][nPosPc]) .And. Empty(aCols[n][nPosItemPC])
			Help("  ",1,"A140PC")
			lRetorno := .F.			
		Case cPaisLoc <> "BRA".AND.cTipo <> "C" .And.;
				Round(aCols[n][nPosVUnit]*aCols[n][nPosQuant],SuperGetMV("MV_RNDLOC",.F.,2)) <> Round(aCols[n][nPosTotal],SuperGetMV("MV_RNDLOC",.F.,2))
			HELP(" ",1,"A100Valor")
			lRetorno := .F.			
		Case cTipo$'NDB' .And. (aCols[n][nPosTotal]>(aCols[n][nPosVUnit]*aCols[n][nPosQuant]+0.49);
		                   .Or. aCols[n][nPosTotal]<(aCols[n][nPosVUnit]*aCols[n][nPosQuant]-0.49))
			Help("  ",1,'TOTAL')
			lRetorno := .F.			
		Case !A103Alert(Acols[n][nPosCod],aCols[n][nPosLocal],l140Auto)
			lRetorno := .F.
		Case cTipo = 'N' .And. lPCNFE	 .And. Empty(aCols[n,nPosPC])
  		    If l140Auto .And. (IsInCallStack("MATA310") .Or. nModo ==2)   // Quando for Rotina Automatica e Transf.Filiais, ignora parametro pedido de compras 
  		       lRetorno := .T.
  		    else 
			   lRetorno := .T.
	   		   If !lInit
	   		      //if U_MyAviso(OemToAnsi("Atencao"),OemToAnsi("MV_PCNFE ativo e No. do Pedido de Compras não preenchido."),{OemToAnsi("Continuar"),OemToAnsi("Voltar")}, 2 ) == 2 //-- "Atencao"###"Informe o No. do Pedido de Compras ou verifique o conteudo do parametro MV_PCNFE"###"Ok"
	   		      //		lRetorno := .F.
	   		      //endif
			   EndIf
		    EndIf
		OtherWise
			lRetorno := .T.
		EndCase
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Valida o preenchimento dos campos referentes ao WMS             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If	lRetorno .And. nPosServic > 0 .And. !Empty(aCols[n, nPosServic])
			lRetorno := A103WMSOk()
			//- Valida o Servico digitado na pre-nota, que deve ser de Conferencia.
			If	lRetorno
				//-- Valida o Servico digitado na pre-nota, que deve ser de Conferencia.
				If	!WmsVldSrv('5',aCols[n,nPosServic])
					Aviso(OemToAnsi("Atencao"), 'Somente Servicos WMS de Conferencia podem ser utilizados.', {'Ok'}) //'Somente Servicos WMS de Conferencia podem ser utilizados.'
					lRetorno := .F.
				EndIf
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se Produto x Fornecedor foi Bloquedo pela Qualidade.   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRetorno
			lRetorno := QieSitFornec(cA100For,cLoja,aCols[n][nPosCod],.T.)
		EndIf

	Else
		lRetorno := .T.
	EndIf
Else
	lRetorno := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Refresh do rodape do pre-documento de entrada            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Eval(bRefresh)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa os pontos de entrada da Linha Ok                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//If lRetorno .And. ExistTemplate("MT140LOK")
//	lRetorno := ExecTemplate("MT140LOK",.F.,.F.,{lRetorno,a140Total,a140Desp})
//EndIf

If lRetorno .And. ExistBlock("MT140LOK")
	lRetorno := ExecBlock("MT140LOK",.F.,.F.,{lRetorno,a140Total,a140Desp})
EndIf

RestArea(aArea)
Return lRetorno
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Ma140TudOk³ Autor ³ Eduardo Riera         ³ Data ³02.10.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Validacao da Getdados - TudoOk                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto da getdados                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Indica se todos os itens sao validos                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo validar todos os itens do pre- ³±±
±±³          ³-documento de entrada                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function MA140Tok() //User

Local lRetorno     := .T.
Local lTudoDel     := .T.
Local nX           := 0   
Local nPosMed      := GDFieldPos( "D1_ITEMMED" ) 
Local lItensMed    := .F. 
Local lItensNaoMed := .F.   
Local aMT140GCT    := {}
Local aAreaSA1     := SA1->( getArea() )	//Hf - Control
Local aAreaSA2     := SA2->( getArea() )	//Hf - Control
Local cCnpj        := ""					//Hf - Control
Local aAreaSF2     := SF2->( getArea() )	//Hf - FGVTN
Local aAreaSA4     := SA4->( getArea() )	//Hf - FGVTN
Local aDetCte      := {}					//Hf - FGVTN
Local cCnpjTransp  := ""					//Hf - FGVTN
Local nPosNfo      := GDFieldPos( "D1_NFORI" ) //Hf - FGVTN
Local nPosSro      := GDFieldPos( "D1_SERIORI" ) //Hf - FGVTN
Local nPosTeste    := 0							//Hf - FGVTN
Local cFilSeek     := "" //Iif(U_IsShared("SA2"),xFilial("SA2"),ZBZ->ZBZ_FILIAL) //Hf - Cimento Itambé
//Local bSavKeyF3  := SetKey(VK_F5,Nil)
//Local bSavKeyF5  := SetKey(VK_F5,Nil)
//Local bSavKeyF6  := SetKey(VK_F6,Nil)
//Local bSavKeyF7  := SetKey(VK_F7,Nil)
//Local bSavKeyF10 := SetKey(VK_F10,Nil)

Private cCnpjXML  := "" //&(cTagDocEmit)         	       //Hf - Control
Private xZBZ  	  := GetNewPar("XM_TABXML","ZBZ")      //ECOOOOOOOOOO
Private xZBZ_ 	  := iif(Substr(xZBZ,1,1)=="S", Substr(xZBZ,2,2), Substr(xZBZ,1,3)) + "_"
Private xZBE      := GetNewPar("XM_TABEVEN","ZBE")
Private xZBE_     := iif(Substr(xZBE,1,1)=="S", Substr(xZBE,2,2), Substr(xZBE,1,3)) + "_"
Private xZBC      := GetNewPar("XM_TABCAC","ZBC")
Private xZBC_     := iif(Substr(xZBC,1,1)=="S", Substr(xZBC,2,2), Substr(xZBC,1,3)) + "_"
Private xZBO      := GetNewPar("XM_TABOCOR","ZBO")
Private xZBO_     := iif(Substr(xZBO,1,1)=="S", Substr(xZBO,2,2), Substr(xZBO,1,3)) + "_"
Private xZBI      := GetNewPar("XM_TABIEXT","ZBI")
Private xZBI_     := iif(Substr(xZBI,1,1)=="S", Substr(xZBI,2,2), Substr(xZBI,1,3)) + "_"
PRIVATE cUsaDvg   := GetNewPar("XM_USADVG","N")
cFilSeek          := xFilial("SA2")  //Iif( U_IsShared("SA2"),xFilial("SA2"),(xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))) )

if Type( cTagDocEmit ) <> "U"
	if !Empty(cTagDocEmit)
		cCnpjXML   := &(cTagDocEmit)         	       //Hf - Control
	Endif
endif

SF3->( dbSetOrder(4) ) //Hf - FGVTN
SF2->( dbSetOrder(1) ) //Hf - FGVTN
SA4->( dbSetOrder(1) ) //Hf - FGVTN

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica preenchimento dos campos do cabecalho           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(ca100For) .Or. Empty(dDEmissao) .Or. Empty(cTipo) .Or. (Empty(cNFiscal).And.cFormul!="S")
	Help(" ",1,"A100FALTA")
	lRetorno := .F.
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existem itens a serem gravados               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//-------------------------------------------------------------//
//FR TRATATIVA PARA TELA DE DIVERGÊNCIAS
//-------------------------------------------------------------//
//FR 12/05/2020 - Variáveis para o array a ser lido na tela de divergências
cItem		:= ""
cProduto	:= ""
nQuant  	:= 0
cUM		:= ""
cTES		:= ""
cCF		:= ""
nPreco  	:= 0
nTotal  	:= 0
nTNF		:= 0
nTotal 		:= 0 
nBaseipi	:= 0 
nValipi		:= 0 
nBaseicm	:= 0 
nValicm		:= 0 
nBasepis 	:= 0 
nValpis		:= 0 
nPis		:= 0 
nBasecof	:= 0 
nValcof		:= 0 
nBaseir		:= 0 
nValir		:= 0
nValmerc	:= 0 
nTBaseipi 	:= 0
nTValipi 	:= 0
nTBaseicm 	:= 0
nTValicm 	:= 0
nTBasepis	:= 0
nTValpis	:= 0
nTBasecof	:= 0
nTValcof	:= 0
nTBaseir	:= 0
nTValir		:= 0
aIteNFE		:= {}
aCabNFE		:= {}
cNcm        := ""   //FR - 19/06/2020 - TÓPICOS RAFAEL								 
For nX :=1 to Len(aCols)
	If !aCols[nX][Len(aCols[nX])]
		lTudoDel := .F.
		If !Empty( nPosMed )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica a existencia de itens de medicao junto com itens sem medicao               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lItensMed    := lItensMed .Or. aCols[ nX, nPosMed ] == "1" 
			lItensNaoMed := lItensNaoMed .Or. aCols[ nX, nPosMed ] $ " |2"

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ponto de entrada permite incluir itens não-pertinentes ao gct ou não.               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (ExistBlock("MT140GCT"))
				aMT140GCT := ExecBlock("MT140GCT",.F.,.F.,{aCols,nX,nPosMed})

				If ValType(aMT140GCT) == "A"
					If Len(aMT140GCT) >= 1 .And. ValType(aMT140GCT[1]) == "L"
						lItensMed    := aMT140GCT[1]
					EndIf
					If Len(aMT140GCT) >= 2 .And. ValType(aMT140GCT[2]) == "L" 
						lItensNaoMed := aMT140GCT[2]
					EndIf	 
				EndIf  
			EndIf	           
			
			If lItensMed .And. lItensNaoMed
				Help( " ", 1, "A103MEDIC" ) 
				lRetorno := .F. 		
				Exit
			EndIf 
		EndIf

		//Hf - FGVTN
		if lDetCte .and. lNfOri  //HF Cimentos Itambé
			SA2->( dbSetOrder(3) ) //Hf - Itambé
			SA2->( DbSeek( cFilSeek + iif( len(aCnpRem)>=nX, aCnpRem[nX], cCnpRem ) ) )
			If .Not. SF3->( DbSeek( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))) + SA2->A2_COD + SA2->A2_LOJA + aCols[nX][nPosNfo] + aCols[nX][nPosSro] ) )
				If aCols[nX][nPosNfo] = "N/E" .And. Empty(aCols[nX][nPosSro])
					aadd(aDetCte,{aCols[nX][nPosNfo] + " / " + aCols[nX][nPosSro],"Chave XML não encontrou NF na Base de Dados (SF3)"} )
					aCols[nX][nPosNfo] := space( len(SF3->F3_NFISCAL ) )
				Else
					if lTagOri .Or. .Not. Empty(aCols[nX][nPosNfo]) .or. .Not. Empty(aCols[nX][nPosSro])
						aadd(aDetCte,{aCols[nX][nPosNfo] + " / " + aCols[nX][nPosSro],"NF/Série Não Encontrada (SF3)"} )
					endif
				Endif
			EndIf
			SA2->( dbSetOrder(1) ) //Hf - Itambé
		ElseIf lDetCte
			If .Not. SF2->( DbSeek( xFilial("SF2") + aCols[nX][nPosNfo] + aCols[nX][nPosSro] ) )
				If aCols[nX][nPosNfo] = "N/E" .And. Empty(aCols[nX][nPosSro])
					aadd(aDetCte,{aCols[nX][nPosNfo] + " / " + aCols[nX][nPosSro],"Chave XML não encontrou NF na Base de Dados"} )
					aCols[nX][nPosNfo] := space( len(SF2->F2_DOC ) )
				Else
					if lTagOri .Or. .Not. Empty(aCols[nX][nPosNfo]) .or. .Not. Empty(aCols[nX][nPosSro])
						aadd(aDetCte,{aCols[nX][nPosNfo] + " / " + aCols[nX][nPosSro],"NF/Série Não Encontrada"} )
					endif
				Endif
			Else
				cCnpjTransp := Posicione("SA4",1,xFilial("SA4")+SF2->F2_TRANSP, "A4_CGC")
				If cCnpjXML <> cCnpjTransp
					aadd(aDetCte,{aCols[nX][nPosNfo] + " / " + aCols[nX][nPosSro],"Cnpj Transportadora Difere. XML: "+Transform(cCnpjXML,"@R 99.999.999/9999-99")+" / NF: "+Transform(cCnpjTransp,"@R 99.999.999/9999-99")} )
				EndIf
				nPosTeste := aScan( aCols, {|x| x[nPosNfo] == aCols[nX][nPosNfo] .And. x[nPosSro] == aCols[nX][nPosSro] } )
				If nPosTeste > 0 .And. nPosTeste <> nX
					If !aCols[nPosTeste][Len(aCols[nPosTeste])]
						aadd(aDetCte,{aCols[nX][nPosNfo] + " / " + aCols[nX][nPosSro],"Existe Outro Item com esta NF/Série." } )
					EndIf
				EndIf
			EndIf
		EndIf
		//Hf - FGVTN    	
	Endif  //se não estiver deletada
	
	If cUsaDvg == "S"
		//-------------------------------------------------------------//
		//FR TRATATIVA PARA TELA DE DIVERGÊNCIAS
		//FR - montando o array que será lido na tela de divergências:
		//-------------------------------------------------------------//
		If !(aCols[nx,Len(aHeader)+1]) //se a linha do acols não estiver deletada
			cItem		:= aCols[nx][ aScan( aHeader, {|x| alltrim(x[2]) == "D1_ITEM" 	}) ]
			cProduto	:= aCols[nx][ aScan( aHeader, {|x| alltrim(x[2]) == "D1_COD" 	}) ]
			nQuant  	:= aCols[nx][ aScan( aHeader, {|x| alltrim(x[2]) == "D1_QUANT" 	}) ] 
			cUM			:= aCols[nx][ aScan( aHeader, {|x| alltrim(x[2]) == "D1_UM"	 	}) ] 
			cTES		:= ""
			If aScan( aHeader, {|x| alltrim(x[2]) == "D1_TES"	 	}) > 0
				cTES		:= aCols[x][ aScan( aHeader, {|x| alltrim(x[2]) == "D1_TES"	}) ] 
			Endif
			cCF			:= ""
			If aScan( aHeader, {|x| alltrim(x[2]) == "D1_CF"	 	}) > 0
				cCF			:= aCols[nx][ aScan( aHeader, {|x| alltrim(x[2]) == "D1_CF"	}) ] 
			Endif			
		    
			cNcm := ""		//FR - 19/06/2020 - TÓPICOS RAFAEL
			If aScan( aHeader, {|x| alltrim(x[2]) == "D1_TEC"	 	}) > 0   
				cNcm		:= aCols[nx][ aScan( aHeader, {|x| alltrim(x[2]) == "D1_TEC"}) ] 
			Endif			//FR - 19/06/2020 - TÓPICOS RAFAEL
					
			nPreco  	:= aCols[nx][ aScan( aHeader, {|x| alltrim(x[2]) == "D1_VUNIT" 	}) ]
			nTotal  	:= aCols[nx][ aScan( aHeader, {|x| alltrim(x[2]) == "D1_TOTAL" 	}) ]		
			nBaseipi	:= aCols[nx][ aScan( aHeader, {|x| alltrim(x[2]) == "D1_BASEIPI"}) ]		
			nValipi 	:= aCols[nx][ aScan( aHeader, {|x| alltrim(x[2]) == "D1_VALIPI" }) ]		
			nIpi    	:= aCols[nx][ aScan( aHeader, {|x| alltrim(x[2]) == "D1_IPI" 	}) ]
			nBaseicm	:= aCols[nx][ aScan( aHeader, {|x| alltrim(x[2]) == "D1_BASEICM"}) ]		
			nValicm 	:= aCols[nx][ aScan( aHeader, {|x| alltrim(x[2]) == "D1_VALICM" }) ]		
			nIcm		:= aCols[nx][ aScan( aHeader, {|x| alltrim(x[2]) == "D1_PICM" 	}) ]
		    nBasepis	:= 0
		    If aScan( aHeader, {|x| alltrim(x[2]) == "D1_BASEPIS"	}) > 0
		    	nBasepis	:= aCols[nx][ aScan( aHeader, {|x| alltrim(x[2]) == "D1_BASEPIS"}) ]	    
		    Endif
		    nValpis		:= 0
		    If aScan( aHeader, {|x| alltrim(x[2]) == "D1_VALPIS" 	}) > 0
		    	nValpis 	:= aCols[x][ aScan( aHeader, {|x| alltrim(x[2]) == "D1_VALPIS" 	}) ]  //FR estes campos não estão ativos na pré-nota	    
		    Endif
		    nPis		:= 0
		    If aScan( aHeader, {|x| alltrim(x[2]) == "D1_ALQPIS" 	}) > 0
		    	nPis   		:= aCols[x][ aScan( aHeader, {|x| alltrim(x[2]) == "D1_ALQPIS" 	}) ]
		    Endif
		    nBasecof	:= 0
		    If aScan( aHeader, {|x| alltrim(x[2]) == "D1_BASECOF"	}) > 0
		    	nBasecof	:= aCols[nx][ aScan( aHeader, {|x| alltrim(x[2]) == "D1_BASECOF"}) ]	    
		    Endif
		    nValcof		:= 0
		    If aScan( aHeader, {|x| alltrim(x[2]) == "D1_VALCOF" 	}) > 0
		    	nValcof 	:= aCols[x][ aScan( aHeader, {|x| alltrim(x[2]) == "D1_VALCOF" 	}) ]	    
		    Endif
		    nCof		:= 0
		    If aScan( aHeader, {|x| alltrim(x[2]) == "D1_ALQCOF" 	}) > 0
		    	nCof    	:= aCols[x][ aScan( aHeader, {|x| alltrim(x[2]) == "D1_ALQCOF" 	}) ]
		    Endif
		    nBaseir		:= 0 
		    If aScan( aHeader, {|x| alltrim(x[2]) == "D1_BASEIRR"	}) > 0
		    	nBaseir 	:= aCols[x][ aScan( aHeader, {|x| alltrim(x[2]) == "D1_BASEIRR"	}) ]	    
		    Endif
		    nValir		:= 0
		    If aScan( aHeader, {|x| alltrim(x[2]) == "D1_VALIRR"	}) > 0
		    	nValir  	:= aCols[x][ aScan( aHeader, {|x| alltrim(x[2]) == "D1_VALIRR"	}) ]	    
		    Endif
		    nIr			:= 0
		    If aScan( aHeader, {|x| alltrim(x[2]) == "D1_ALIQIRR"	}) > 0 
		    	nIr			:= aCols[x][ aScan( aHeader, {|x| alltrim(x[2]) == "D1_ALIQIRR"	}) ] 
		    Endif
			    
		    nValmerc	+= nTotal 
		    nTBaseipi 	+= nBaseipi
		    nTValipi 	+= nValipi
		    nTBaseicm 	+= nBaseicm
		    nTValicm 	+= nValicm
		    nTBasepis	+= nBasepis 
		    nTValpis	+= nValpis
		    nTBasecof	+= nBasecof
		    nTValcof	+= nValcof
		    nTBaseir	+= nBaseir
		    nTValir		+= nValir	
		   		    		    		  
			Aadd( aIteNFE, { cItem	,; 		//01
						 cProduto	,; 		//02
						 nQuant		,;   	//03
						 cUM		,;	 	//04
						 cTES		,; 	 	//05	
						 cCF 		,;		//06	
						 nPreco		,;  	//07	
						 nTotal  	,;  	//08
						 nBaseipi	,;  	//09
						 nValipi 	,;  	//10
						 nIpi    	,;  	//11
						 nBaseicm	,;	 	//12
						 nValicm 	,; 		//13	 
						 nIcm 	 	,;	   	//14	
						 nBasepis	,;	 	//15
						 nValpis 	,;	 	//16
						 nPis 		,;	 	//17
						 nBasecof	,;	 	//18
						 nValcof 	,;	 	//19
						 nCof   	,; 	 	//20
						 nBaseir 	,;	 	//21
						 nValir 	,; 	 	//22
						 nIr		,;		//23
						 cNcm       ;		//24  //FR - 19/06/2020 - TÓPICOS RAFAEL								  					 
						   } )   //Armazena no array de itens da NF, para comparar com o xml	 
			
		Endif  //FR se a linha não estiver deletada
	Endif  //FR se o parâmetro está ativado
	//FR
	
Next nX

If cUsaDvg == "S"  //FR 19/05/2020 se o parâmetro que ativa a verificação de divergências está ativado

	//---------------------------------------------------------//
	//FR TRATATIVA PARA TELA DE DIVERGÊNCIAS 
	//---------------------------------------------------------//
	nTNF := 0
	nTNF := nValmerc  //MaFisRet(,"NF_TOTAL")
	///dados da nf	
	Aadd( aCabNFE, {cNFiscal   		,;		//01-SF1->F1_DOC
					cSerie			,;		//02-SF1->F1_SERIE
					dDEmissao		,;		//03-SF1->F1_EMISSAO
					cA100For   		,;		//04-SF1->F1_FORNECE
					cLoja	   		,;		//05-SF1->F1_LOJA
					cEspecie   		,;		//06-SF1->F1_ESPECIE
					cTipo	   		,;		//07-SF1->F1_TIPO
					nValmerc		,; 		//a140Total[VALMERC]	,;	//08-SF1->F1_VALMERC
					nTNF	        ,;      //MaFisRet(,"NF_TOTAL")  //a140Total[TOTPED]	;		//09-SF1->F1_VALBRUT
					nTBaseicm		,;	//10-SF1->F1_BASEICM
					nTValicm		,;	//11-SF1->F1_VALICM
					nTBaseipi		,;	//12-SF1->F1_BASEIPI
					nTValipi		,;	//13-SF1->F1_VALIPI
					nTBasepis		,;	//14-SF1->F1_BASEPIS
					nTValpis	   	,;	//15-SF1->F1_VALPIS
					nTBasecof  		,;	//16-SF1->F1_BASCOFI
					nTValcof   		,;	//17-SF1->F1_VALCOFI
					nTBaseir		,;	//18-SF1->F1_(BASEIR) ?
					nTValir			;	//19-SF1->F1_VALIRF			
				})
Endif
///FR
If lTudoDel
	Help(" ",1,"A140TUDDEL")
	lRetorno := .F.
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Aqui a pedido da Control Service, checar Fornecedor com o XML. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRetorno
	If .Not. cTipo $ "DB"
		cCnpj := Posicione("SA2",1,xFilial("SA2")+ ca100For + cLoja, "A2_CGC")
	Else
		cCnpj := Posicione("SA1",1,xFilial("SA1")+ ca100For + cLoja, "A1_CGC")
	EndIf
	If !Empty(cCnpjXML) .And. cCnpj <> cCnpjXML
		Alert( "CNPJ do cadastro Difere do CNPJ do XML" )
		lRetorno := .F.
	EndIf
EndIf

If lRetorno
	if Val( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE"))) ) >= 890 .And. Val( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE"))) ) <= 899
	Else
		if Val( cNFiscal ) <> Val( cDocXMl )
			Alert( "Numero do Documento Difere do XML" )
			lRetorno := .F.
		EndIf
	EndIF
EndIf
If lRetorno
	if (nAmarris == 3 .or. nAmarris == 0) .AND. !l140Auto
		if nTotXml <> a140Total[TOTPED]
			lGraberPed := ( GetNewPar("XM_PED_GBR","N") == "S" )
			if lGraberPed
				if a140Total[TOTPED] > nTotXml
					U_MYAVISO("Atenção","Valor Total do XML, difere do valor Lançado."+CRLF+;
			   			"Valor do XML:  "+AllTrim(Transform(nTotXml,"@E 999,999,999,999.99"))+CRLF+;
			   			"Valor Lançado: "+AllTrim(Transform(a140Total[TOTPED],"@E 999,999,999,999.99"))+CRLF+;
			   			"",{"VOLTAR"},3)
			   			lRetorno := .F.
				endif
			elseif GetNewPar("XM_PED_GBR","N") == "P"  //se for P - Pergunta, senão passa lotado, para Jardel..
				if U_MYAVISO("Atenção","Valor Total do XML, difere do valor Lançado."+CRLF+;
			   		"Valor do XML:  "+AllTrim(Transform(nTotXml,"@E 999,999,999,999.99"))+CRLF+;
			   		"Valor Lançado: "+AllTrim(Transform(a140Total[TOTPED],"@E 999,999,999,999.99"))+CRLF+;
			   		"Deseja Continuar Assim Mesmo?",{"SIM","NÃO"},3) == 2
			   		lRetorno := .F.
				endif
			endif
		EndIf
	endif
EndIf
If lRetorno
	if Val( cSerXml ) > 0
		if Val( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE"))) ) >= 890 .And. Val( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE"))) ) <= 899
		Else
    		if Val( cSerXml ) <> Val( cSerie )
				Alert( "Serie do Documento Difere do XML" )
				lRetorno := .F.
    		EndIf
    	EndIf
    Endif
EndIf
if lDetCte  //Hf FGVTN
	If lRetorno
		If GetNewPar("XM_CTE_AVI","S") <> "N"  //Para Jardel, parametro para mostrar avisos do CTE...
			lRetorno := ErNfOri( aDetCte )
		Endif
	EndIf
EndIf  //Hf FGVTN
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chamada do Ponto de entrada para validacao da TudoOk     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRetorno .And. ExistBlock("MT140TOK")
	lRetorno := ExecBlock("MT140TOK",.F.,.F.,{lRetorno})
EndIf

SA4->( RestArea(aAreaSA4) )  //Hf - FGVTN
SF2->( RestArea(aAreaSF2) )  //Hf - FGVTN
SA1->( RestArea(aAreaSA1) )  //Hf - Control
SA2->( RestArea(aAreaSA2) )  //Hf - Control
//SetKey(VK_F5,bSavKeyF3)
//SetKey(VK_F5,bSavKeyF5)
//SetKey(VK_F6,bSavKeyF6)
//SetKey(VK_F7,bSavKeyF7)
//SetKey(VK_F10,bSavKeyF10)
Return lRetorno

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Ma140Bar  ³ Prog. ³ Sergio Silveira       ³Data  ³ 23/02/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Construcao da EnchoiceBar do pre-documento de entrada       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto dialog                                       ³±±
±±³          ³ ExpB2 = Code block de confirma                              ³±±
±±³          ³ ExpB3 = Code block de cancela                               ³±±
±±³          ³ ExpA4 = Array com botoes ja incluidos.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Devolve o retorno da enchoicebar                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo criar a barra de botoes denomi-³±±
±±³          ³nada EnchoiceBar                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ma140Bar(oDlg,bOk,bCancel,aButtonsAtu)

Local aUsButtons := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona botoes do usuario na EnchoiceBar                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "MA140BUT" )
	If ValType( aUsButtons := ExecBlock( "MA140BUT", .F., .F. ) ) == "A"
		AEval( aUsButtons, { |x| aadd( aButtonsAtu, x ) } )
	EndIf
EndIf

Return (EnchoiceBar(oDlg,bOK,bcancel,,aButtonsAtu))

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Ma140Total³ Prog. ³ Sergio Silveira       ³Data  ³ 23/02/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Calculo do total do pre-documento de entrada                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1: Array com os totais do pre-documento de entrada      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo calcular os totais do pre-docum³±±
±±³          ³ento de entrada                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ma140Total(aTotal,aDespesa, nTotal, nValDesc)

Local nUsado   := Len(aHeader)
Local nMaxFor  := Len(aCols)
Local lDeleted := .F.
Local nPTotal  := aScan(aHeader,{|x| AllTrim(x[2])=="D1_TOTAL"})
Local nPValDesc:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_VALDESC"})
Local nPValIpi := aScan(aHeader,{|x| AllTrim(x[2])=="D1_VALIPI"})
Local nX       := 0
Local nIpi     := 0

Default nTotal 		:= 0
Default nValDesc 	:= 0

If Len(aCols)> 0
	For nX := 1 To Len(aCols)
		If aCols[nX][Len(aCols[1])]
			lDeleted := .T.
			Exit
		EndIf
	Next nX
EndIf

aTotal := aFill(aTotal,0)
aDespesa[VALDESC] := 0
For nX := 1 To nMaxFor
	If !lDeleted .Or. !aCols[nX][nUsado+1]
		If (n==nX)
			aTotal[VALMERC] 	+= 	Iif (nTotal<>0, nTotal, aCols[nX][nPTotal])
			aTotal[VALDESC] 	+= 	Iif (nValDesc<>0, nValDesc, aCols[nX][nPValDesc])
			aTotal[TOTPED ] 	+= 	Iif (nTotal<>0, nTotal, aCols[nX][nPTotal]) - Iif (nValDesc<>0, nValDesc, aCols[nX][nPValDesc])
			aDespesa[VALDESC]	+=	Iif (nValDesc<>0, nValDesc, aCols[nX][nPValDesc])
			nIpi                +=  Iif (nPValIpi<>0, aCols[nX][nPValIpi], 0 )
						
		ElseIf ((nTotal==0) .Or. (n<>nX))
			aTotal[VALMERC] 	+= 	aCols[nX][nPTotal]			
			aTotal[VALDESC] 	+= 	aCols[nX][nPValDesc]
			aTotal[TOTPED ] 	+= 	aCols[nX][nPTotal] - aCols[nX][nPValDesc]
			aDespesa[VALDESC]	+=	aCols[nX][nPValDesc]
			nIpi                +=  Iif (nPValIpi<>0, aCols[nX][nPValIpi], 0 )
		EndIf
	EndIf
Next nX
aTotal[TOTPED ] += aDespesa[FRETE] + aDespesa[VALDESP] + aDespesa[SEGURO] + nIpi
Return(.T.)
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Ma140Grava³ Autor ³ Eduardo Riera         ³ Data ³03.10.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de atualizacao do pre-documento de entrada            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpL1: Indica se a operacao eh de exclusao                   ³±±
±±³          ³ExpA1: Array com os recnos do SD1                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Indica se houve atualizacao                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo atualizar um pre-documento de  ³±±
±±³          ³entrada e seus anexos                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function Ma140Grv(lExclui,aRecSD1,aDespesa)

Local aArea     := GetArea("SF1")
Local aPCMail   := {}
Local nX        := 0
Local nY        := 0
Local nMaxFor   := Len(aCols)
Local nUsado    := Len(aHeader)
Local nSaveSX8  := GetSX8Len()
Local lTravou   := .F.
Local lGrava    := .F.
Local cItem     := StrZero(0,Len(SD1->D1_ITEM))
Local cGrupo    := SuperGetMv("MV_NFAPROV")
Local lGeraBlq  := .F.
Local nI        := 0
Local nJ        := 0
Local nPosServic:= aScan(aHeader, {|x|Upper(Alltrim(x[2]))=='D1_SERVIC'})
//Local nPosRatHF := aScan(aHeader, {|x|Upper(Alltrim(x[2]))=='D1_RATEIO'})
Local nDecimalPC:= TamSX3("C7_PRECO")[2]
Local cCpoJaGrv := ""
//-- Variaveis utilizadas pela funcao wmsexedcf
Local nPosDCF	:= 0
Local cTipoNf   := SuperGetMv("MV_TPNRNFS")
Local nTamVol1  := TAMSX3("F1_VOLUME1")[1]
Local nMaxVol1  := 0

Private xZBZ  	:= GetNewPar("XM_TABXML","ZBZ")      //ECOOOOOOOOOO
Private xZBZ_ 	:= iif(Substr(xZBZ,1,1)=="S", Substr(xZBZ,2,2), Substr(xZBZ,1,3)) + "_" 
Private aLibSDB	:= {}
Private aWmsAviso:= {}
//--

l140Auto := !(Type("l140Auto")=="U" .Or. !l140Auto)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o grupo de aprovacao do Comprador.                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SAL")
dbSetOrder(3)
If MsSeek(xFilial("SAL")+RetCodUsr())
	cGrupo := If(!Empty(SY1->Y1_GRAPROV),SY1->Y1_GRAPROV,cGrupo)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para alterar o Grupo de Aprovacao.          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("MT140APV")
	cGrupo := ExecBlock("MT140APV",.F.,.F.,{cGrupo})
EndIf
//cGrupo:= If(Empty(SD1->D1_APROV),cGrupo,SD1->D1_APROV)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a operacao e de exclusao                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lExclui
	aEval(aCols,{|x| x[nUsado+1] := .T.})
Else
	aEval(aCols,{|x| lGrava := !x[nUsado+1] .Or. lGrava })
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona o arquivo de Cliente/Fornecedor                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cTipo$"DB"
	dbSelectArea("SA1")
	dbSetOrder(1)
	MsSeek(xFilial("SA1")+cA100For+cLoja)
Else
	dbSelectArea("SA2")
	dbSetOrder(1)
	MsSeek(xFilial("SA2")+cA100For+cLoja)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualizacao do pre-documento de entrada                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 To nMaxFor
	lTravou := .F.
	Begin Transaction
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualizacao do cabecalho do pre-documento de entrada         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nX == 1 .And. lGrava
			dbSelectArea("SF1")
			dbSetOrder(1)
			If MsSeek(xFilial("SF1")+cNFiscal+cSerie+cA100For+cLoja+cTipo)
				RecLock("SF1",.F.)
				MaAvalSF1(2)
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Obtem numero do documento quando utilizar ³
				//³ numeracao pelo SD9 (MV_TPNRNFS = 3)       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
				If cTipoNf == "3" .AND. cFormul == "S" .AND. cModulo <> "EIC"
					SX3->(DbSetOrder(1))
					If (SX3->(dbSeek("SD9")))
						// Se cNFiscal estiver vazio, busca numeracao no SD9, senao, respeita o novo numero
						// digitado pelo usuario.
						cNFiscal := MA461NumNf(.T.,cSerie,cNFiscal)
					EndIf			
				Endif 
				
				RecLock("SF1",.T.)
				//--Atualiza status da nota para em conferencia
				If (SuperGetMV("MV_CONFFIS",.F.,"N") == "S")
					SF1->F1_STATCON := "0"
				EndIf
			EndIf
			nPos := aScan(aAutoCab,{|x| AllTrim(Upper(x[1]))=="F1_VALPEDG"})
			if nPos > 0
				nPedagioCt := aAutoCab[nPos][2]
			Else
				nPedagioCt := 0
			EndIf
			nPos := aScan(aAutoCab,{|x| AllTrim(Upper(x[1]))=="F1_TPFRETE"})
			if nPos > 0
				cModFreCt := aAutoCab[nPos][2]
			Else
				cModFreCt := " "
			EndIf

			SF1->F1_FILIAL := xFilial("SF1")
			SF1->F1_DOC    := cNFiscal
			SF1->F1_SERIE  := cSerie
			SF1->F1_FORNECE:= cA100For
			SF1->F1_LOJA   := cLoja
			SF1->F1_EMISSAO:= dDEmissao
			SF1->F1_EST    := IIF(!Empty(cUfOrigP),cUfOrigP,IIf(cTipo$"DB",SA1->A1_EST,SA2->A2_EST))
			SF1->F1_TIPO   := cTipo
			if SF1->( FieldPos("F1_TPCOMPL") ) > 0 .And. cTpCompl <> ' ' .And. cTipo <> 'N' .And. cTipo <> 'D' .And. cTipo <> 'B'
				SF1->F1_TPCOMPL:= cTpCompl
			EndIF
			SF1->F1_DTDIGIT:= IIf(GetMv("MV_DATAHOM",NIL,"1") == "1".Or.Empty(SF1->F1_RECBMTO),dDataBase,SF1->F1_RECBMTO)
			//SF1->F1_RECBMTO:= SF1->F1_DTDIGIT
			SF1->F1_FORMUL := IIf(cFormul=="S","S"," ")
			SF1->F1_ESPECIE:= cEspecie
			SF1->F1_TPFRETE:= cModFreCt
			SF1->F1_DESPESA:= aDespesa[VALDESP]
			SF1->F1_FRETE  := aDespesa[FRETE]
			SF1->F1_SEGURO := aDespesa[SEGURO]
			if !Empty((xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO"))) ) //(xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO"))) <> "RP"  // NFCE_03 16/05
				SF1->F1_CHVNFE := alltrim((xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))))
			EndIf
			SF1->F1_VALPEDG:= nPedagioCt
			nPos := aScan(aAutoCab,{|x| AllTrim(Upper(x[1]))=="F1_VOLUME1"})
			if nPos > 0
				nMaxVol1 := Val( Replicate("9",nTamVol1 ) )
				If aAutoCab[nPos][2] > nMaxVol1
					SF1->F1_VOLUME1 := nMaxVol1
				Else
					SF1->F1_VOLUME1 := aAutoCab[nPos][2]
				EndIf
			EndIf
            
			// INCLUIR TRATAMENTO PARA DADOS DO XML
			

			MaAvalSF1(1)
			If cPaisLoc != "BRA" .And. l140Auto
				For nI := 1 To Len(aAutoCab)
					SF1->(FieldPut(FieldPos(aAutoCab[nI][1]),aAutoCab[nI][2]))
				Next nI
			Else
				cCpoJaGrv := "F1_FILIAL,F1_DOC,F1_SERIE,F1_FORNECE,F1_LOJA,F1_EMISSAO,F1_EST,F1_TIPO,F1_DTDIGIT,F1_FORMUL,F1_ESPECIE,F1_TPFRETE,F1_DESPESA,F1_FRETE,F1_SEGURO,F1_CHVNFE,F1_VALPEDG,F1_VOLUME1"  //,F1_VOLUME1
				For nI := 1 To Len(aAutoCab)
					If .NOT. AllTrim( aAutoCab[nI][1] ) $ cCpoJaGrv .And. FieldPos( aAutoCab[nI][1] ) > 0 
						SF1->(FieldPut(FieldPos(aAutoCab[nI][1]),aAutoCab[nI][2]))
					EndIf
				Next nI
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualizacao da conferencia fisica                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (SuperGetMV("MV_CONFFIS",.F.,"N") == "S")
				If ExistBlock("MT140ACD")
					ExecBlock("MT140ACD",.F.,.F.)
				EndIf
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Tratamento da gravacao do SF1 na Integridade Referencial            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SF1->(FkCommit())
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualizacao dos itens do pre-documento de entrada            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nX <= Len(aRecSD1)
			dbSelectArea("SD1")
			MsGoto(aRecSD1[nX])
			RecLock("SD1")
			If cPaisLoc=="BRA"
				MaAvalSD1(2,"SD1")
			ElseIf cPaisLoc == "ARG"
				If SD1->D1_TIPO_NF == "5"	//Factura Fob
					MaAvalSD1(2,"SD1")
				EndIf
			ElseIf cPaisLoc == "CHI"
				If SD1->D1_TIPO_NF == "9"	//Factura Aduana
					MaAvalSD1(2,"SD1")
				EndIf
			Endif
			lTravou := .T.
		Else
			If !aCols[nX][nUsado+1]	
				RecLock("SD1",.T.)
				lTravou := .T.
			EndIf
		EndIf
		If lTravou
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-Ä¿
			//³ Pontos de Entrada 											 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÙ
			If lExclui
				//If (ExistTemplate("SD1140E"))
				//	ExecTemplate("SD1140E",.F.,.F.)
				//EndIf
				If (ExistBlock("SD1140E"))
					ExecBlock("SD1140E",.F.,.F.)
				Endif
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Estorna o Servico do WMS (DCF)                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			if Findfunction("A103EstDCF")  //aquiiii
				A103EstDCF(.T.)
			else
				U_HFEstDCF(.T.)
			endif
			If aCols[nX][nUsado+1]
				If cPaisLoc=="BRA"
					MaAvalSD1(3,"SD1")
				ElseIf cPaisLoc == "ARG"
					If SD1->D1_TIPO_NF == "5"	//Factura Fob
						MaAvalSD1(3,"SD1")
					EndIf
				ElseIf cPaisLoc == "CHI"
					If SD1->D1_TIPO_NF == "9"	//Factura Aduana
						MaAvalSD1(3,"SD1")
					EndIf
				Endif
				SD1->(dbDelete())
			Else
				cItem := Soma1(cItem,Len(cItem))
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza os dados do acols                                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nY := 1 To nUsado
					If aHeader[nY][10] <> "V"
						SD1->(FieldPut(FieldPos(aHeader[nY][2]),aCols[nX][nY]))
					EndIf
				Next nY
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Posiciona registros                                          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SB1")
				dbSetOrder(1)
				MsSeek(xFilial("SB1")+SD1->D1_COD)

				SC7->(DbSetOrder(1))
				SC7->(MsSeek(xFilial("SC7")+SD1->D1_PEDIDO+SD1->D1_ITEMPC))

				dbSelectArea("SD1")
				SD1->D1_FILIAL	:= xFilial("SD1")
				SD1->D1_FORNECE	:= cA100For
				SD1->D1_LOJA	:= cLoja
				SD1->D1_DOC		:= cNFiscal
				SD1->D1_SERIE	:= cSerie
				SD1->D1_EMISSAO	:= dDEmissao
				SD1->D1_DTDIGIT	:= dDataBase
				SD1->D1_GRUPO	:= SB1->B1_GRUPO
				SD1->D1_TIPO	:= cTipo
				If IntDL() .And. Empty(SD1->D1_NUMSEQ)
					SD1->D1_NUMSEQ := ProxNum()
				EndIf
				SD1->D1_TP		:= SB1->B1_TIPO
				SD1->D1_FORMUL	:= IIf(cFormul=="S","S"," ")
				If Empty(SD1->D1_ITEM)
					SD1->D1_ITEM    := cItem
				EndIf
				SD1->D1_TIPODOC := SF1->F1_TIPODOC
				// Caso o campo exista, significa que tem ACDSTD implantado, sendo necessario iniciar a CONFERENCIA
				If SD1->(FieldPos("D1_QTDCONF")) > 0
					SD1->D1_QTDCONF := 0
				EndIf 
				SD1->D1_RATEIO	:= IIF(SC7->(FieldPos("C7_RATEIO"))>0,SC7->C7_RATEIO,"")
				If cPaisLoc != "BRA"
					SD1->D1_ESPECIE	:= cEspecie
					SD1->D1_FORMUL  := SF1->F1_FORMUL
					If l140Auto
						For nJ := 1 To Len(aAutoItens[nX])
							If Subs(aAutoItens[nX][nJ][1],4,6) $ "BASIMP|VALIMP|ALQIMP|TESDES"
								SD1->(FieldPut(FieldPos(aAutoItens[nX][nJ][1]),aAutoItens[nX][nJ][2]))
							EndIf
						Next nJ
					EndIf
					SD1->D1_TES	:= "   "
				EndIf
				//-- em 21/03/17 -> Incluido condição para que seja gravado na SDE o rateio da SCH do pedido que está vinculado a Pré-Nota. Por Zé Maranguape
				If AliasInDic("SCH")
					aAreaSD1 := GetArea("SD1")
					dbSelectArea("SCH")  
					dbSetOrder(1) // CH_FILIAL+CH_PEDIDO+CH_FORNECE+CH_LOJA+CH_ITEMPD+CH_ITEM
					If(SCH->(MsSeek(xFilial("SCH")+SD1->D1_PEDIDO+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_ITEMPC)))  //+SD1->D1_ITEM
						While SCH->(!EOF()) .And. ; 
						(SD1->D1_PEDIDO+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_ITEMPC == SCH->CH_PEDIDO+SCH->CH_FORNECE+SCH->CH_LOJA+SCH->CH_ITEMPD)
							dbSelectArea("SDE")  
							SDE->(dbSetOrder(1)) // DE_FILIAL+DE_DOC+DE_SERIE+DE_FORNECE+DE_LOJA+DE_ITEMNF+DE_ITEM
							If !(SDE->(MsSeek(xFilial("SDE")+SD1->D1_DOC+SD1->D1_SERIE+SCH->CH_FORNECE+SCH->CH_LOJA+SD1->D1_ITEMPC+SCH->CH_ITEM)))
								RecLock("SDE",.T.)
								SDE->DE_FILIAL 	:= SCH->CH_FILIAL
								SDE->DE_DOC 	:= SD1->D1_DOC
								SDE->DE_SERIE 	:= SD1->D1_SERIE
								SDE->DE_FORNECE := SCH->CH_FORNECE
								SDE->DE_LOJA 	:= SCH->CH_LOJA
								SDE->DE_ITEMNF 	:= SD1->D1_ITEM
								SDE->DE_ITEM 	:= SCH->CH_ITEM
								SDE->DE_PERC 	:= SCH->CH_PERC
								SDE->DE_CC 		:= SCH->CH_CC
								SDE->DE_CONTA 	:= SCH->CH_CONTA
								SDE->DE_ITEMCTA := SCH->CH_ITEMCTA
								SDE->DE_CLVL 	:= SCH->CH_CLVL
								SDE->DE_CUSTO1 	:= SCH->CH_CUSTO1
								SDE->DE_CUSTO2 	:= SCH->CH_CUSTO2
								SDE->DE_CUSTO3 	:= SCH->CH_CUSTO3
								SDE->DE_CUSTO4 	:= SCH->CH_CUSTO4
								SDE->DE_CUSTO5 	:= SCH->CH_CUSTO5					
								SDE->(MsUnLock())
							Endif
							SCH->(dbSkip())
						EndDo
					EndIf
					RestArea(aAreaSD1)
				EndIf

				//so eh necessario q. um item tenha bloqueio, pois o bloqueio eh da NF inteira
				If Empty(SD1->D1_TEC) .And. !lGeraBlq .And. !Empty(SD1->D1_PEDIDO+SD1->D1_ITEMPC) .And. !Empty(cGrupo)
					SC7->(DbSetOrder(1))
					SC7->(MsSeek(xFilial("SC7")+SD1->D1_PEDIDO+SD1->D1_ITEMPC))
					lGeraBlq := MaAvalToler(SD1->D1_FORNECE, SD1->D1_LOJA,SD1->D1_COD,SD1->D1_QUANT+SC7->C7_QUJE+SC7->C7_QTDACLA,SC7->C7_QUANT,SD1->D1_VUNIT,xMoeda(SC7->C7_PRECO,SC7->C7_MOEDA,,M->dDEmissao,nDecimalPC,SC7->C7_TXMOEDA,))[1]
				EndIf

				If cPaisLoc=="BRA"
					MaAvalSD1(1,"SD1")
				ElseIf cPaisLoc == "ARG"
					If SD1->D1_TIPO_NF == "5"	//Factura Fob
						MaAvalSD1(1,"SD1")
					EndIf
				ElseIf cPaisLoc == "CHI"
					If SD1->D1_TIPO_NF == "9"	//Factura Aduana
						MaAvalSD1(1,"SD1")
					EndIf
				Endif
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Ponto de Entrada na Inclusao.                                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (ExistBlock("SD1140I"))
					ExecBlock("SD1140I",.F.,.F.,{nx})
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza array com Pedidos utilizados                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty(SD1->D1_PEDIDO)
					If aScan(aPCMail,SD1->D1_PEDIDO+" - "+SD1->D1_ITEMPC) == 0
						Aadd(aPCMail,SD1->D1_PEDIDO+" - "+SD1->D1_ITEMPC)
					EndIf
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Gera os servicos de WMS na inclusao da Pre-Nota              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nPosServic > 0 .And. !Empty(aCols[nX, nPosServic])
					CriaDCF('SD1',,,,,@nPosDCF)
					If	!Empty(nPosDCF) .And. WmsVldSrv('4',aCols[nX, nPosServic])
						DCF->(MsGoTo(nPosDCF))
						WmsExeDCF('1',.F.)
					EndIf
				EndIf
				
			EndIf
			If lGeraBlq .And. nX == nMaxFor
				cGrupo:= If(Empty(SF1->F1_APROV),cGrupo,SF1->F1_APROV)
				If ALTERA .Or. lExclui // Estorna as liberacoes
					MaAlcDoc({SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA,"NF",SF1->F1_VALBRUT,,,cGrupo,,SF1->F1_MOEDA,SF1->F1_TXMOEDA,SF1->F1_EMISSAO},SF1->F1_EMISSAO,3)
				EndIf
				If !lExclui
					MaAlcDoc({SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA,"NF",0,,,cGrupo,,SF1->F1_MOEDA,SF1->F1_TXMOEDA,SF1->F1_EMISSAO},SF1->F1_EMISSAO,1)
				EndIf
				dbSelectArea("SF1")
				Reclock("SF1",.F.)
				SF1->F1_STATUS := "B"
				SF1->F1_APROV  := cGrupo
				MsUnlock()
			EndIf
		EndIf

		If nX == nMaxFor .And. !lGrava
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Tratamento da gravacao do SD1 na Integridade Referencial            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SD1->(FkCommit())

			dbSelectArea("SF1")
			dbSetOrder(1)
			If MsSeek(xFilial("SF1")+cNFiscal+cSerie+cA100For+cLoja+cTipo)
				RecLock("SF1",.F.)
				MaAvalSF1(2)
				MaAvalSF1(3)
				MaAlcDoc({SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA,"NF",SF1->F1_VALBRUT,,,cGrupo,,SF1->F1_MOEDA,SF1->F1_TXMOEDA,SF1->F1_EMISSAO},SF1->F1_EMISSAO,3)
				SF1->(dbDelete())
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Executa os gatilhos e a confirmacao do semaforo              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nX == nMaxFor
			EvalTrigger()
			While ( GetSX8Len() > nSaveSX8 )
				ConfirmSx8()
			EndDo
		EndIf
	End Transaction
Next nX

If !lExclui .And. lGrava
	//-- Integrado ao wms devera avaliar as regras para convocacao do servico e disponibilizar os 
	//-- registros do SDB para convocacao
	If	IntDL() .And. !Empty(aLibSDB)
		WmsExeDCF('2')
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a existencia de e-mails para o evento 005       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MEnviaMail("005",{SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA,If(cTipo$"DB",SA1->A1_NOME,SA2->A2_NOME),aPCMail})
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a necessidade da impressao de etiquetas         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SA2->(FieldPos("A2_IMPIP")) <> 0 .And. SuperGetMV("MV_INTACD",.F.,"0") == "1"
		If (SA2->A2_IMPIP == "2") .Or. (SA2->A2_IMPIP $ "03 " .And. SuperGetMv("MV_IMPIP",.F.,"3") == "2" ) // MV_IMPIP: ACD
			If (!l140Auto .Or. GetAutoPar("AUTIMPIP",aAutoCab,0) == 1) .And. SF1->F1_STATCON <> "1"
				If (FindFunction("ACDI010"))
					ACDI10NF(SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA,.T.,l140Auto)
				Else	
					T_ACDI10NF(SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA,.T.,l140Auto)
				EndIf
			EndIf
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Template Function apos atualizacao de todos os dados inclusao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//If (ExistTemplate("SF1140I"))
	//	ExecTemplate("SF1140I",.F.,.F.)
	//EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de Entrada apos atualizacao de todos os dados inclusao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (ExistBlock("SF1140I"))
		ExecBlock("SF1140I",.F.,.F.)
	EndIf

EndIf    

dbSelectArea("SC7")  
dbSetOrder(1)

RestArea(aArea)

Return(lGrava)

//-------------------------------------------------------------------
/*/{Protheus.doc} A140NFORI() 
Faz a chamada da Tela de Consulta a NF original
@author taniel.silva
@since 16/10/2014
@version P12
/*/
//-------------------------------------------------------------------
Static Function A140NFORI()

Local nPosCod	:= aScan(aHeader,{|x| AllTrim(x[2])=='D1_COD'})
Local nPLocal	:= aScan(aHeader,{|x| AllTrim(x[2])=='D1_LOCAL'})
Local lRet    := .T.

If !cTipo $ 'DC'
	lRet := .F.
	Help('   ',1,'A140NFORI')
EndIf

If lRet
	If Empty(Readvar())
		If cTipo == "D"
			lRet := F4NFORI(,,"M->D1_NFORI",cA100For,cLoja,aCols[n,nPosCod],"A100",aCols[n,nPLocal])			
		ElseIf cTipo == "C"
			lRet := F4COMPL(,,,cA100For,cLoja,aCols[n,nPosCod],"A100",,"M->D1_NFORI")
		EndIf
	Else
		Help('   ',1,'A103CAB')
	EndIf
EndIf

if !lRet
	MsgStop("Este documento nao possui nota de origem")
	lRet := .F.
endif

// Atualiza valores na tela
Eval(bRefresh)

If Type( "oGetDados" ) == "O" 	
	oGetDados:oBrowse:Refresh()	
EndIf 

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A140AtuCon³ Prog. ³ Fernando Alves        ³Data  ³15/03/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza folder de conferencia fisica                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A140ConfPr( ExpO1, ExpA1)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto do list box                                 ³±±
±±³          ³ ExpA2 = Array com o contudo da list box                    ³±±
±±³          ³ ExpO3 = Objeto para flag do list box                       ³±±
±±³          ³ ExpO4 = Objeto para flag do list box                       ³±±
±±³          ³ ExpO5 = Objeto com total de conferentes na nota            ³±±
±±³          ³ ExpN6 = Variavel de quantidade de conferentes              ³±±
±±³          ³ ExpN7 = Objeto com o status da nota                        ³±±
±±³          ³ ExpN8 = Variavel com a descricao do status da nota         ³±±
±±³          ³ ExpL9 = Habilita recontagem na conferencia (limpa o que foi³±±
±±³          ³         gravado)                                           ³±±
±±³          ³ ExpO10= Objeto timer                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MATA140                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A140AtuCon(oList,aListBox,oEnable,oDisable,oConf,nQtdConf,oStatCon,cStatCon,lReconta,oTimer)

Local aArea     := {}
Local cAliasOld := Alias()

If ValType(oTimer) == "O"
	oTimer:Deactivate()
EndIf
lReconta := If (lReconta == nil,.F.,lReconta)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Habilita recontagem³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lReconta .And. (Aviso("AVISO","Voce realmente quer fazer a recontagem?",{"Sim","Nao"}) == 1) //"AVISO"###"Voce realmente quer fazer a recontagem?"###"Sim"###"Nao"
	If Reclock("SF1",.F.)
		SF1->F1_STATCON := "0"
		SF1->(msUnlock())
	EndIf
	dbSelectArea("CBE")
	dbsetOrder(2)
	MsSeek(xFilial("CBE")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
	While !eof() .and. CBE->CBE_NOTA+CBE->CBE_SERIE == SF1->F1_DOC+SF1->F1_SERIE .and.;
			CBE->CBE_FORNEC+CBE->CBE_LOJA == SF1->F1_FORNECE+SF1->F1_LOJA
		If reclock("CBE",.F.)
			CBE->(dbDelete())
			CBE->(msUnlock())
		EndIf
		dbSelectArea("CBE")
		dbSkip()
	EndDo
Else
	lReconta := .F.
EndIf

aListBox := {}
dbSelectArea("SD1")
aArea := GetArea()

MsSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE)

While !EOF() .and. SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE == SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se for a opcao RECONTAGEM, zera tudo o que foi conferido³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lReconta
		Reclock("SD1",.F.)
		SD1->D1_QTDCONF := 0
		SD1->(msUnlock())
	EndIf
	aAdd(aListBox,{SD1->D1_COD,SD1->D1_QTDCONF,SD1->D1_QUANT})
	dbSkip()
End
If ValType(oList) == "O"
	oList:SetArray(aListBox)
	oList:bLine := { || {If (aListBox[oList:nAT,2] == aListBox[oList:nAT,3],oEnable,oDisable), aListBox[oList:nAT,1], aListBox[oList:nAT,2]} }
	oList:Refresh()
EndIf
RestArea(aArea)
dbSelectArea(cAliasOld)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza os Gets³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ValType(oConf) == "O"
	SF1->(dbSkip(-1))
	If !SF1->(BOF())
		SF1->(dbSkip())
	EndIf
	nQtdConf := SF1->F1_QTDCONF
	oConf:Refresh()
EndIf

If ValType(oStatCon) == "O"
	Do Case
	Case SF1->F1_STATCON == '1'
		cStatCon := "NF conferida"
	Case SF1->F1_STATCON == '0'
		cStatCon := "NF nao conferida"
	Case SF1->F1_STATCON == '2'
		cStatCon := "NF com divergencia"
	Case SF1->F1_STATCON == '3'
		cStatCon := "NF em conferencia"
	EndCase
	nQtdConf := SF1->F1_QTDCONF
	oStatCon:Refresh()
EndIf
If ValType(oTimer) == "O"
	oTimer:Activate()
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A140DetCon³ Prog. ³ Eduardo Motta         ³Data  ³19/04/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta listbox com dados da conferencia do produto          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A140DetCon(oList,aListBox)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto do list box                                 ³±±
±±³          ³ ExpA2 = Array com o contudo da list box                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MATA140                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A140DetCon(oList,aListBox)
Local cCodPro := aListBox[oList:nAt,1]
Local aListDet := {}
Local oListDet
Local oDlgDet
Local aArea := sGetArea()
Local oTimer
Local bBlock := {|cCampo|(SX3->(MsSeek(cCampo)),X3TITULO())}
Local oIndice
Local aIndice := {}
Local cIndice
Local aIndOrd := {}
Local cKeyCBE  := "CBE_FILIAL+CBE_NOTA+CBE_SERIE+CBE_FORNEC+CBE_LOJA+CBE_CODPRO"
Local aColunas := {}
Local aCpoCBE  := {}
Local nI


sGetArea(aArea,"CBE")
sGetArea(aArea,"SB1")
sGetArea(aArea,"SX3")
sGetArea(aArea,"SIX")

SIX->(DbSetOrder(1))
SIX->(MsSeek("CBE"))
While !SIX->(Eof()) .and. SIX->INDICE == "CBE"
	If SubStr(SIX->CHAVE,1,Len(cKeyCBE)) == cKeyCBE
		aadd(aIndice,SIX->(SixDescricao()))
		If IsDigit(SIX->ORDEM)     // se for numerico o conteudo do ORDEM assume ele mesmo, senao calcula o numero do indice (ex: "A" => 10, "B" => 11, "C" => 12, etc)
			aadd(aIndOrd,Val(SIX->ORDEM))
		Else
			aadd(aIndOrd,Asc(SIX->ORDEM)-55)
		EndIf
	EndIf
	SIX->(DbSkip())
EndDo

dbSelectArea("SX3")
dbSetOrder(1)
MsSeek("CBE")
While !EOF() .And. (x3_arquivo == "CBE")
	If ( x3uso(X3_USADO) .And. cNivel >= X3_NIVEL .and. !(AllTrim(X3_CAMPO) $ cKeyCBE))
		aadd(aCpoCBE,{X3_CAMPO,X3_CONTEXT})
	Endif
	dbSkip()
EndDo

SX3->(DbSetOrder(2))
SB1->(DbSetOrder(1))
SB1->(MsSeek(xFilial("SB1")+cCodPro))

cIndice := aIndice[1]

For nI := 1 to Len(aCpoCBE)
	aadd(aColunas,Eval(bBlock,aCpoCBE[nI,1]))
Next

CBE->(dbsetOrder(2))

DEFINE MSDIALOG oDlgDet TITLE OemToAnsi("Detalhes de Conferencia do Produto "+cCodPro+" "+SB1->B1_DESC) From 0, 0 To 25, 67 OF oMainWnd //"Detalhes de Conferencia do Produto "
oListDet := TWBrowse():New( 02, 2, (oDlgDet:nRight/2)-5, (oDlgDet:nBottom/2)-30,,aColunas,, oDlgDet,,,,,,,,,,,, .F.,, .T.,, .F.,,, )

A140AtuDet(cCodPro,oListDet,aListDet,,aCpoCBE)

@ (oDlgDet:nBottom/2)-25, 005 Say "Ordem " PIXEL OF oDlgDet //"Ordem "
@ (oDlgDet:nBottom/2)-25, 025 MSCOMBOBOX oIndice    VAR cIndice    ITEMS aIndice    SIZE 180,09 PIXEL OF oDlgDet
oIndice:bChange := {||CBE->(DbSetOrder(aIndOrd[oIndice:nAt])),A140AtuDet(cCodPro,oListDet,aListDet,oTimer,aCpoCBE)}
@  (oDlgDet:nBottom/2)-25, (oDlgDet:nRight/2)-50 BUTTON "&Retorna" SIZE 40,10 ACTION ( oDlgDet:End() ) Of oDlgDet PIXEL // //"&Retorna"

DEFINE TIMER oTimer INTERVAL 1000 ACTION (A140AtuDet(cCodPro,oListDet,aListDet,oTimer,aCpoCBE)) OF oDlgDet
oTimer:Activate()

ACTIVATE MSDIALOG oDlgDet CENTERED

sRestArea(aArea)
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A140AtuDet³ Prog. ³ Eduardo Motta         ³Data  ³19/04/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza array para listbox dos detalhes de conferencia    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A140AtuDet(cCodPro,oListDet,aListDet,oTimer)               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCodPro  - Codigo do produto a procurar no CBE             ³±±
±±³          ³ oListDet - Objeto listbox a atualizar                      ³±±
±±³          ³ aListDet - Array do listbox                                ³±±
±±³          ³ oTimer   - Objeto timer a desativar para o processo        ³±±
±±³          ³ aCpoCBE  - Campos do LISTBOX                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MATA140                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A140AtuDet(cCodPro,oListDet,aListDet,oTimer,aCpoCBE)
Local aLine := {},nI
Local uConteudo

If ValType(oTimer) == "O"
	oTimer:Deactivate()
EndIf

aListDet := {}

CBE->(MsSeek(xFilial("CBE")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+cCodPro))

While !CBE->(eof()) .and. CBE->CBE_NOTA+CBE->CBE_SERIE == SF1->F1_DOC+SF1->F1_SERIE .and.;
		CBE->CBE_FORNEC+CBE->CBE_LOJA == SF1->F1_FORNECE+SF1->F1_LOJA .and. CBE->CBE_CODPRO == cCodPro

	aLine := {}
	For nI := 1 to Len(aCpoCBE)
		If Empty(aCpoCBE[nI,2])
			uConteudo := CBE->&(aCpoCBE[nI,1])
		Else
			uConteudo := CriaVar(aCpoCBE[nI,1])
		EndIf
		aadd(aLine,uConteudo)
	Next
	aadd(aListDet,aLine)

	CBE->(DbSkip())
EndDo
If Empty(aListDet)
	aLine := {}
	For nI := 1 To Len(aCpoCBE)
		aadd(aLine,CriaVar(aCpoCBE[nI,1],.f.))
	Next
	aadd(aListDet,aLine)
EndIf

oListDet:SetArray( aListDet )
oListDet:bLine := { || RetDetLine(aListDet,oListDet:nAT)  }

oListDet:Refresh()

If ValType(oTimer) == "O"
	oTimer:Activate()
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³RetDetLine³ Prog. ³ Eduardo Motta         ³Data  ³20/04/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao para retornar campos para o bLine do listbox        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RetDetLine(aListDet,nAt)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aListDet - Array com dados do listbox                      ³±±
±±³          ³ nAt      - Linha do listbox                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ A140AtuDet                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RetDetLine( aListDet,nAt )
Local aRet := {}
Local nX:= 0
For nX:= 1 to len(aListDet[nAt])
	aadd(aRet,aListDet[nAt,nx])
Next nX
Return aRet


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A140Impri ³ Autor ³Alexandre Inacio Lemes³ Data ³22/03/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua a chamada do relatorio padrao ou do usuario         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpX1 := A140Impri( ExpC1, ExpN1, ExpN2 )                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 -> Alias do arquivo                                  ³±±
±±³          ³ ExpN1 -> Recno do registro                                 ³±±
±±³          ³ ExpN2 -> Opcao do Menu                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpX1 -> Retorno do relatorio                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR170                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

/*Static Function A140Impri( cAlias, nRecno, nOpc ) //User

Local xRet := a103Impri( cAlias, nRecno, nOpc )

Pergunte("MTA140",.F.)

Return( xRet )*/
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A140EstCla ³ Autor ³Patricia A. Salomao   ³ Data ³01/08/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Estorno da Classificacao da Nota Fiscal.                    ³±±
±±³          ³Executa a funcao de exclusao do MATA103;Porem, nao exclui o ³±±
±±³          ³SD1/SF1;Apenas limpa o conteudo os campos D1_TES e F1_STATUS³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpX1 := A140ExcCla( ExpC1, ExpN1, ExpN2 )                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 -> Alias do arquivo                                  ³±±
±±³          ³ ExpN1 -> Recno do registro                                 ³±±
±±³          ³ ExpN2 -> Opcao Selecionada                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA140                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
/*Static Function A140EstCla( cAlias, nRecno, nOpc ) //User

If SF1->F1_STATUS != "A"
    Help("",1,"A140ESTORN")
ElseIf SF1->F1_TIPO $ "NDB"
	A103NFiscal(cAlias,nRecno,5,,.T.)
Else
	Help("",1,"A140NCLASS")
EndIF

Return .T.*/

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³a140Desc   ³ Autor ³Gustavo G. Rueda      ³ Data ³30/03/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao para atualizar o valor do DESCONTO no rodapeh quando ³±±
±±³          ³ digitamos o campo D1_DESC ou D1_VALDESC.                   ³±±
±±³          ³Para atualizar de acordo com o campo:                       ³±±
±±³          ³ - D1_DESC eh necessario criar o seguinte gatilho junto com ³±±
±±³          ³   padroes do sistema.                                      ³±±
±±³          ³   X7_CAMPO = D1_DESC                                       ³±±
±±³          ³   X7_REGRA = M->D1_VALDESC := IIF(A140DESC(M->D1_VALDESC), ³±±
±±³          ³              M->D1_VALDESC, M-D1_VALDESC)				  ³±±
±±³          ³   X7_CDOMIN = D1_VALDESC                                   ³±±
±±³          ³ - D1_VALDESC eh necessario inserir a seguinte validacao no ³±±
±±³          ³   SX3: A140DESC(M->D1_VALDESC)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A140DESC(nValDesc)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nValDesc -> Valor do desconto do item                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA140                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
/*Static Function a140Desc (nValDesc) //User
	Eval (bRefresh,,,,nValDesc)
Return (.T.)*/
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Ma140DelIt ³ Autor ³Gustavo G. Rueda      ³ Data ³30/03/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao para atualizar o valor do DESCONTO e do TOTAL no     ³±±
±±³          ³ rodapeh quando marcamos como deletado determinado item.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ma140DelIt ()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA140                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
/*Static Function Ma140DelIt () //User
	Local	aTotal		:=	{0,0,0}
	Local	aDespesa	:=	{0,0,0,0,0,0,0,0}
	//
	Ma140Total(aTotal,aDespesa)
	Eval (bRefresh)
Return (.T.) */

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Fabio Alves Silva     ³ Data ³01/11/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³    1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function MenuDef()     
PRIVATE aRotina	:= {	{ "Pesquisar" 				,"AxPesqui"		, 0 , 1, 0, .F.},; //"Pesquisar"
						{ "Visualizar"				,"U_A140NFis"	, 0 , 2, 0, nil},; //"Visualizar"
						{ "Incluir"					,"U_A140NFis"	, 0 , 3, 0, nil},; //"Incluir"
						{ "Alterar"					,"U_A140NFis"	, 0 , 4, 0, nil},; //"Alterar"
						{ "Excluir"					,"U_A140NFis"	, 0 , 5, 0, nil},; //"Excluir"
						{ "Imprimir" 				,"A140Impri"  	, 0 , 4, 0, nil},; //"Imprimir"
						{ "Estorna Classificacao"	,"A140EstCla" 	, 0 , 5, 0, nil},; //"Estorna Classificacao"	
						{ "Legenda"					,"A103Legenda"	, 0 , 2, 0, .F.}} 	//"Legenda"	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada utilizado para inserir novas opcoes no array aRotina  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("MTA140MNU")
	ExecBlock("MTA140MNU",.F.,.F.)
EndIf
Return(aRotina) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MaCols140 ³ Autor ³ Liber De Esteban      ³ Data ³ 10/01/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Montagem do aCols para GetDados.                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³MaCols140()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros|-cAliasSD1 ->Alias do SD1.                                  ³±±
±±³          ³-aRecSD1 -> Array com registros do SD1.                     ³±±
±±³          ³-bWhileSD1 -> Bloco com condicao para While.                ³±±
±±³          ³-nCounterSD1 -> Contador de registros do SD1, para o caso de³±±
±±³          ³nao estar usando query.                                     ³±±
±±³          ³-lQuery -> Flag de identificacao se esta usando query.      ³±±
±±³          ³-l140Inclui -> Flag que identifica se operacao e inclusao.  ³±±
±±³          ³-l140Visual -> Flag que identifica se operacao e inclusao.  ³±±
±±³          ³-lContinua -> Flag que identifica se deve continuar proc.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MATA140                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function MaCols140(cAliasSD1,bWhileSD1,aRecOrdSD1,aRecSD1,aPedC,lItSD1Ord,lQuery,l140Inclui,l140Visual,lContinua,l140Exclui)
//Local nPos		:= 0
Local nPosPc	:= 0
//Local nX		:= 0
Local nY 		:= 0
Local nCountSD1	:= 1
Local lAntAlt   := ALTERA
Local lAntInc   := INCLUI

If !Empty(aHeadSD1)
	aHeader := aClone(aHeadSD1)
EndIf

If l140Inclui
	ALTERA := .F.
	INCLUI := .T.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz a montagem de uma linha em branco no aCols.              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aadd(aCols,Array(Len(aHeader)+1))
	For nY := 1 To Len(aHeader)
		If Trim(aHeader[nY][2]) == "D1_ITEM"
			aCols[1][nY] 	:= StrZero(1,Len((cAliasSD1)->D1_ITEM))
		Else
			If AllTrim(aHeader[nY,2]) == "D1_ALI_WT"
				aCOLS[Len(aCols)][nY] := "SD1"
			ElseIf AllTrim(aHeader[nY,2]) == "D1_REC_WT"
				aCOLS[Len(aCols)][nY] := 0
			Else
				aCols[1][nY] := CriaVar(aHeader[nY][2])
			EndIf
		EndIf
		aCols[1][Len(aHeader)+1] := .F.
	Next nY
    ALTERA := lAntAlt
    INCLUI := lAntInc
Else

	While Eval( bWhileSD1 )
	
		If !lQuery .And. (lItSD1Ord .Or. ALTERA)
		
			If nCountSD1 == 1
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Este procedimento eh necessario para fazer a montagem        ³
				//³ do acols na ordem ITEM + COD quando classificacao em CDX     ³
				//³ e o parametro MV_PAR03 estiver para ITEM                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aRecOrdSD1 := {}
				While ( !Eof().And. lContinua .And. ;
						(cAliasSD1)->D1_FILIAL== xFilial("SD1") .And. ;
						(cAliasSD1)->D1_DOC == cNFiscal .And. ;
						(cAliasSD1)->D1_SERIE == SF1->F1_SERIE .And. ;
						(cAliasSD1)->D1_FORNECE == SF1->F1_FORNECE .And. ;
						(cAliasSD1)->D1_LOJA == SF1->F1_LOJA )
	
					AAdd( aRecOrdSD1, { ( cAliasSD1 )->D1_ITEM + ( cAliasSD1 )->D1_COD, ( cAliasSD1 )->( Recno() ) } )
	
					( cAliasSD1 )->( dbSkip() )
	
				EndDo
	
				ASort( aRecOrdSD1, , , { |x,y| y[1] > x[1] } )
	
				bWhileSD1 := { || nCountSD1 <= Len( aRecOrdSD1 ) .And. lContinua  }
			EndIf
			
			If !lQuery .And. (lItSD1Ord .Or. ALTERA)
				SD1->( dbGoto( aRecOrdSD1[ nCountSD1, 2 ] ) )
			EndIf

		EndIf

		If (cAliasSD1)->D1_TIPO == SF1->F1_TIPO
			If Empty((cAliasSD1)->D1_TES)
				//-- Impede a alteracao/exclusao da PreNota com Servico de WMS jah executado
				If	IntDL() .And. (l140Exclui .Or. !l140Visual) .And. FindFunction("WmsChkDCF")
					If	WmsChkDCF("SD1",,,SD1->D1_SERVIC,'3',,SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA,SD1->D1_LOCAL,SD1->D1_COD,SD1->D1_LOTECTL,SD1->D1_NUMLOTE,SD1->D1_NUMSEQ,SD1->D1_ITEM)
						Aviso("SIGAWMS","Documento nao pode ser alterado/excluido porque possui servicos de WMS pendentes. Antes estorne estes servicos.",{'Ok'}) //"Documento nao pode ser alterado/excluido porque possui servicos de WMS pendentes. Antes estorne estes servicos."
						lContinua := .F.
						Loop
					EndIf
				EndIf
					If lQuery
					aadd(aRecSD1,(cAliasSD1)->SD1RECNO)
				Else
					aadd(aRecSD1,RecNo())
				EndIf

				If !l140Visual
					If !Empty((cAliasSD1)->D1_PEDIDO)
						nPosPC := aScan(aPedC,{|y| y[1] == (cAliasSD1)->D1_PEDIDO+(cAliasSD1)->D1_ITEMPC})
						If nPosPc > 0
							aPedC[nPosPc,2] += (cAliasSD1)->D1_QUANT
						Else
							aadd(aPedC,{(cAliasSD1)->D1_PEDIDO+(cAliasSD1)->D1_ITEMPC,(cAliasSD1)->D1_QUANT})
						EndIf
					EndIf
				EndIf
				aadd(aCols,Array(Len(aHeader)+1))
				For nY := 1 to Len(aHeader)
					If ( aHeader[nY][10] != "V")
						aCols[Len(aCols)][nY] := FieldGet(FieldPos(aHeader[nY][2]))
					Else
						If AllTrim(aHeader[nY,2]) == "D1_ALI_WT"
							aCOLS[Len(aCols)][nY] := "SD1"
						ElseIf AllTrim(aHeader[nY,2]) == "D1_REC_WT"
							aCOLS[Len(aCols)][nY] := If(lQuery,(cAliasSD1)->SD1RECNO,(cAliasSD1)->(RecNo()))
						Else
							aCols[Len(aCols)][nY] := CriaVar(aHeader[nY][2])
						EndIf
					EndIf
					aCols[Len(aCols)][Len(aHeader)+1] := .F.
				Next nY
			Else
				Help(" ",1,"A140CLASSI")
				lContinua := .F.
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Efetua skip na area SD1 ( regra geral ) ou incrementa o contador ³
		//³ quando ordem por ITEM + CODIGO DE PRODUTO                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lQuery .And. (lItSD1Ord .Or. ALTERA)
			nCountSD1++
		Else
			dbSelectArea(cAliasSD1)
			dbSkip()
		EndIf
	EndDo
EndIf

Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³AjustaHelp    ³ Autor ³Turibio Miranda       ³ Data ³23.02.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Ajusta os helps                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³AjustaHelp()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function AjustaHelp()
Local aArea 	:= GetArea()
Local aHelpPor	:= {}
Local aHelpEng	:= {}
Local aHelpSpa	:= {}

aHelpPor :=	{"Não é possível realizar o estorno de","classificação para esta nota."}
aHelpSpa :=	{"No es posible realizar la reversion de","clasificacion para esta factura."}
aHelpEng :=	{"Classification reversal is not","possible for this invoice."}
PutHelp("PA140ESTORN",aHelpPor,aHelpEng,aHelpSpa,.F.)    
 
aHelpPor :=	{"O estorno é possível somente para","notas fiscais já classificadas."}
aHelpSpa :=	{"Solo es posible la reversion para","facturas ya clasificadas."}
aHelpEng :=	{"Classification reversal is possible","only for already classified invoices."}
PutHelp("SA140ESTORN",aHelpPor,aHelpEng,aHelpSpa,.F.) 

Restarea(aArea)
Return    





/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³XMLPCF5   ³ Autor ³ Edson Maricate        ³ Data ³27.01.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Tela de importacao de Pedidos de Compra.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A103Pedido()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MATA103                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function XMLPCF5(lUsaFiscal,aGets,lNfMedic,lConsMedic,aHeadSDE,aColsSDE,aHeadSEV, aColsSEV)

Local nSldPed    := 0
Local nOpc       := 0
//Local nx         := 0
Local cQuery     := ""
Local cAliasSC7  := "SC7"
Local lQuery     := .F.
//Local bSavSetKey := SetKey(VK_F4,Nil)
//Local bSavKeyF5  := SetKey(VK_F5,Nil)
//Local bSavKeyF6  := SetKey(VK_F6,Nil)
//Local bSavKeyF7  := SetKey(VK_F7,Nil)
//Local bSavKeyF8  := SetKey(VK_F8,Nil)
//Local bSavKeyF9  := SetKey(VK_F9,Nil)
//Local bSavKeyF10 := SetKey(VK_F10,Nil)
//Local bSavKeyF11 := SetKey(VK_F11,Nil)
Local cChave     := ""
//Local cCadastro  := ""
Local aArea      := GetArea()
Local aAreaSA2   := SA2->(GetArea())
Local aAreaSC7   := SC7->(GetArea())
Local nF4For     := 0
Local oOk        := LoadBitMap(GetResources(), "LBOK")
Local oNo        := LoadBitMap(GetResources(), "LBNO")
//Local lGspInUseM := If(Type('lGspInUse')=='L', lGspInUse, .F.)
Local aButtons   := { {'PESQUISA',{||A103VisuPC(aRecSC7[oListBox:nAt])},OemToAnsi("Visualiza Pedido"),OemToAnsi("Pedido")} } //"Visualiza Pedido"
Local oDlg,oListBox
Local cNomeFor   := ''
Local aTitCampos := {}
Local aConteudos := {}
Local aUsCont    := {}
Local aUsTitu    := {}
Local bLine      := { || .T. }
Local cLine      := ""
Local lMa103F4I  := ExistBlock( "MA103F4I" )
Local nLoop      := 0
Local lMt103Vpc  := ExistBlock("MT103VPC")
Local lRet103Vpc := .T.
Local lContinua  := .T.
Local oPanel
Local nNumCampos := 0
Local nPosCC     := aScan(aHeader,{|x| AllTrim(x[2])=="D1_CC"})         //HF
Local nPosPRD	 := aScan(aHeader,{|x| Alltrim(x[2]) == "D1_COD" })     //HF
Local nIa        := 0

PRIVATE aF4For     := {}
PRIVATE aRecSC7    := {}

DEFAULT lUsaFiscal := .T.
DEFAULT aGets      := {}
DEFAULT lNfMedic   := .F.
DEFAULT lConsMedic := .F.
DEFAULT aHeadSDE   := {}
DEFAULT aColsSDE   := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impede de executar a rotina quando a tecla F3 estiver ativa		    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("InConPad") == "L"
	lContinua := !InConPad
EndIf

If lContinua

	If MaFisFound("NF") .Or. !lUsaFiscal
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o aCols esta vazio, se o Tipo da Nota e'     ³
		//³ normal e se a rotina foi disparada pelo campo correto    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cTipo == "N"
			DbSelectArea("SA2")
			DbSetOrder(1)
			MsSeek(xFilial("SA2")+cA100For+cLoja)
			cNomeFor	:= SA2->A2_NOME

			#IFDEF TOP
				DbSelectArea("SC7")
				If TcSrvType() <> "AS/400"
					SC7->( DbSetOrder( 9 ) ) 				
					lQuery    := .T.
					cAliasSC7 := "QRYSC7"

					cQuery := "SELECT R_E_C_N_O_ RECSC7 FROM "
					cQuery += RetSqlName("SC7") + " SC7 "
					cQuery += "WHERE "
					cQuery += "C7_FILENT = '"+xFilEnt(xFilial("SC7"))+"' AND "
					If HasTemplate( "DRO" ) .AND. FunName() == "MATA103" .AND. MV_PAR15 == 1
						cQuery += "C7_FORNECE IN ( " + T_DrogForn( cA100For ) + " ) AND "
					Else
					cQuery += "C7_FORNECE = '"+cA100For+"' AND "		    		
					EndIf
					cQuery += "(C7_QUANT-C7_QUJE-C7_QTDACLA)>0 AND "
					cQuery += "C7_RESIDUO=' ' AND "
					cQuery += "C7_TPOP<>'P' AND "

					If SuperGetMV("MV_RESTNFE")=="S"
						cQuery += "C7_CONAPRO<>'B' AND "
					EndIf 										

					If ( lConsLoja )		    		
						cQuery += "C7_LOJA = '"+cLoja+"' AND "		    							
					Endif		

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Filtra os pedidos de compras de acordo com os contratos             ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

					If lConsMedic

						If lNfMedic

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Traz apenas os pedidos oriundos de medicoes                         ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							cQuery += "C7_CONTRA<>'"  + Space( Len( SC7->C7_CONTRA ) )  + "' AND "
							cQuery += "C7_MEDICAO<>'" + Space( Len( SC7->C7_MEDICAO ) ) + "' AND "		    		

						Else
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Traz apenas os pedidos que nao possuem medicoes                     ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							cQuery += "C7_CONTRA='"  + Space( Len( SC7->C7_CONTRA ) )  + "' AND "
							cQuery += "C7_MEDICAO='" + Space( Len( SC7->C7_MEDICAO ) ) + "' AND "		    		

						EndIf

					EndIf 					

					cQuery += "SC7.D_E_L_E_T_ = ' '"
					cQuery += "ORDER BY " + SqlOrder( SC7->( IndexKey() ) )

					cQuery := ChangeQuery(cQuery)

					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC7,.T.,.T.)
				Else
			#ENDIF
				DbSelectArea("SC7")
				DbSetOrder(9)
				If ( lConsLoja )
					cChave := cA100For+CLOJA
				Else
					cChave := cA100For
				EndIf
				MsSeek(xFilEnt(xFilial("SC7"))+cChave,.T.)
				#IFDEF TOP
				Endif
				#ENDIF
			Do While If(lQuery, ;
					(cAliasSC7)->(!Eof()), ;
					(cAliasSC7)->(!Eof()) .And. xFilEnt(xFilial('SC7'))+cA100For==(cAliasSC7)->C7_FILENT+(cAliasSC7)->C7_FORNECE .And. If(lConsLoja, CLOJA==(cAliasSC7)->C7_LOJA, .T.))

				If lQuery
					('SC7')->(dbGoto((cAliasSC7)->RECSC7))
				EndIf

				lRet103Vpc := .T.

				If lMt103Vpc
					lRet103Vpc := Execblock("MT103VPC",.F.,.F.)
				Endif

				If lRet103Vpc
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica o Saldo do Pedido de Compra                     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nSldPed := ('SC7')->C7_QUANT-('SC7')->C7_QUJE-('SC7')->C7_QTDACLA
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica se nao h  residuos, se possui saldo em abto e   ³
					//³ se esta liberado por alcadas se houver controle.         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If ( Empty(('SC7')->C7_RESIDUO) .And. nSldPed > 0 .And.;
							If(SuperGetMV("MV_RESTNFE")=="S",('SC7')->C7_CONAPRO <> "B",.T.).And.;
							('SC7')->C7_TPOP <> "P" )

						If lConsMedic .And. lNfMedic
							nF4For := aScan(aF4For,{|x|x[5]==('SC7')->C7_LOJA .And. x[6]==('SC7')->C7_NUM})							
						Else							
							nF4For := aScan(aF4For,{|x|x[2]==('SC7')->C7_LOJA .And. x[3]==('SC7')->C7_NUM})
						EndIf 							

						If ( nF4For == 0 )

							If lConsMedic .And. lNfMedic
								aConteudos := {.F.,('SC7')->C7_MEDICAO,('SC7')->C7_CONTRA,('SC7')->C7_PLANILHA,('SC7')->C7_LOJA,('SC7')->C7_NUM,DTOC(('SC7')->C7_EMISSAO),If(('SC7')->C7_TIPO==2,'AE', 'PC') }
							Else
								aConteudos := {.F.,('SC7')->C7_LOJA,('SC7')->C7_NUM,DTOC(('SC7')->C7_EMISSAO),If(('SC7')->C7_TIPO==2,'AE', 'PC') }
							EndIf 															

							If lMa103F4I
								If ValType( aUsCont := ExecBlock( "MA103F4I", .F., .F. ) ) == "A"
									AEval( aUsCont, { |x| AAdd( aConteudos, x ) } )
								EndIf
							EndIf

							aAdd(aF4For , aConteudos )
							aAdd(aRecSC7, ('SC7')->(Recno()))
						EndIf
					EndIf
				Endif
				(cAliasSC7)->(dbSkip())
			EndDo

			If ExistBlock("MA103F4L")
				ExecBlock("MA103F4L", .F., .F., { aF4For, aRecSC7 } )
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Exibe os dados na Tela                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ( !Empty(aF4For) )

				If lConsMedic .And. lNfMedic
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Exibe os campos de medicao do contrato                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

					aTitCampos := {" ",RetTitle("C7_MEDICAO"),RetTitle("C7_CONTRA"),RetTitle("C7_PLANILH"),OemToAnsi("Loja"),OemToAnsi("Pedido"),OemToAnsi("Emissao"),OemToAnsi("Origem")} //"Medicao"###"Contrato"###"Planilha"###"Loja"###"Pedido"###"Emissao"###"Origem"
					cLine := "{If(aF4For[oListBox:nAt,1],oOk,oNo),aF4For[oListBox:nAT][2],aF4For[oListBox:nAT][3],aF4For[oListBox:nAT][4],aF4For[oListBox:nAT][5],aF4For[oListBox:nAT][6],aF4For[oListBox:nAT][7],aF4For[oListBox:nAT][8]"
				Else

					aTitCampos := {" ",OemToAnsi("Loja"),OemToAnsi("Pedido"),OemToAnsi("Emissao"),OemToAnsi("Origem")} //"Loja"###"Pedido"###"Emissao"###"Origem"

					cLine := "{If(aF4For[oListBox:nAt,1],oOk,oNo),aF4For[oListBox:nAT][2],aF4For[oListBox:nAT][3],aF4For[oListBox:nAT][4],aF4For[oListBox:nAT][5]"

				EndIf 					



				If ExistBlock( "MA103F4H" )
					If ValType( aUsTitu := ExecBlock( "MA103F4H", .F., .F. ) ) == "A"
						nNumCampos := Len(aTitCampos)
						For nLoop := 1 To Len( aUsTitu )
							AAdd( aTitCampos, aUsTitu[ nLoop ] )
							cLine += ",aF4For[oListBox:nAT][" + AllTrim( Str( nLoop + nNumCampos ) ) + "]"
						Next nLoop
					EndIf
				EndIf

				cLine += " } "

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Monta dinamicamente o bline do CodeBlock                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				bLine := &( "{ || " + cLine + " }" )


				DEFINE MSDIALOG oDlg FROM 50,40  TO 285,541 TITLE OemToAnsi("Selecionar Pedido de Compra - <F5> ") Of oMainWnd PIXEL //"Selecionar Pedido de Compra"

				@ 12,0 MSPANEL oPanel PROMPT "" SIZE 100,19 OF oDlg CENTERED LOWERED //"Botoes"
				oPanel:Align := CONTROL_ALIGN_TOP

				oListBox := TWBrowse():New( 27,4,243,86,,aTitCampos,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
				oListBox:SetArray(aF4For)
				oListBox:bLDblClick := { || aF4For[oListBox:nAt,1] := !aF4For[oListBox:nAt,1] }
				oListBox:bLine := bLine

				oListBox:Align := CONTROL_ALIGN_ALLCLIENT

				@ 6  ,4   SAY OemToAnsi("Fornecedor") Of oPanel PIXEL SIZE 47 ,9 //"Fornecedor"
				@ 4  ,35  MSGET cNomeFor PICTURE PesqPict('SA2','A2_NOME') When .F. Of oPanel PIXEL SIZE 120,9

				ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||(nOpc := 1,nF4For := oListBox:nAt,oDlg:End())},{||(nOpc := 0,nF4For := oListBox:nAt,oDlg:End())},,aButtons)

				Processa({|| a103procPC(aF4For,nOpc,cA100For,cLoja,@lRet103Vpc,@lMt103Vpc,@nSldPed,lUsaFiscal,aGets,( lConsMedic .And. lNfMedic ),aHeadSDE,@aColsSDE,aHeadSEV, aColsSEV)})
                //HF aquiiiiii ver se pega do pedido
				if cPCSol == "N" .and. nPosCC > 0 //HF Pega Pelo Produto e não do Pedido de Compra
					SB1->( dbSetOrder(1) )
	   				For nIa := 1 To len( aCols )
	   					if SB1->( dbSeek( xFilial("SB1") + aCols[nIa][nPosPRD] ) )  //posiciona o bixo
							aCols[nIa][nPosCC] := SB1->B1_CC
						endif
					Next nIa
				endif
			Else
				//Help(" ",1,"A103F4")
				U_MYAVISO("A103F4","Não existem registros relacionados com este item",{"Ok"},2)
			EndIf
		Else
			Help('   ',1,'A103TIPON')
		EndIf
	Else
		Help('   ',1,'A103CAB')
	EndIf

Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura a Integrida dos dados de Entrada                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lQuery
	DbSelectArea(cAliasSC7)
	dbCloseArea()
	DbSelectArea("SC7")
Endif
//SetKey(VK_F4,bSavSetKey)
//SetKey(VK_F5,bSavKeyF5)
//SetKey(VK_F6,bSavKeyF6)
//SetKey(VK_F7,bSavKeyF7)
//SetKey(VK_F8,bSavKeyF8)
//SetKey(VK_F9,bSavKeyF9)
//SetKey(VK_F10,bSavKeyF10)
//SetKey(VK_F11,bSavKeyF11)

RestArea(aAreaSA2)
RestArea(aAreaSC7)
RestArea(aArea)
Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³XMLPCF6   ³ Autor ³ Edson Maricate        ³ Data ³27.01.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Tela de importacao de Pedidos de Compra por Item.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A103ItemPC()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MATA103                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function XMLPCF6(lUsaFiscal,aPedido,oGetDAtu,lNfMedic,lConsMedic,aHeadSDE,aColsSDE,aGets)

Local cSeek			:= ""
Local nOpca			:= 0
Local aArea			:= GetArea()
Local aAreaSA2		:= SA2->(GetArea())
Local aAreaSC7		:= SC7->(GetArea())
Local aAreaSB1		:= SB1->(GetArea())
Local aRateio       := {0,0,0}
Local aNew			:= {}
Local aTamCab		:= {}
//Local lGspInUseM	:= If(Type('lGspInUse')=='L', lGspInUse, .F.)
Local aButtons		:= { {'PESQUISA',{||A103VisuPC(aArrSldo[oQual:nAt][2])},OemToAnsi("Visualiza Pedido"),OemToAnsi("Pedido")},; //"Visualiza Pedido"
	{'pesquisa',{||A103PesqP(aCab,aCampos,aArrayF4,oQual)},OemToAnsi("Pesquisar")} } //"Pesquisar"
Local aEstruSC7		:= SC7->( dbStruct() )
//Local bSavSetKey	:= SetKey(VK_F4,Nil)
//Local bSavKeyF5		:= SetKey(VK_F5,Nil)
//Local bSavKeyF6		:= SetKey(VK_F6,Nil)
//Local bSavKeyF7		:= SetKey(VK_F7,Nil)
//Local bSavKeyF8		:= SetKey(VK_F8,Nil)
//Local bSavKeyF9		:= SetKey(VK_F9,Nil)
//Local bSavKeyF10	:= SetKey(VK_F10,Nil)
//Local bSavKeyF11	:= SetKey(VK_F11,Nil)
Local nFreeQt		:= 0 
Local nPosPRD		:= aScan(aHeader,{|x| Alltrim(x[2]) == "D1_COD" })
Local nPosPDD		:= aScan(aHeader,{|x| Alltrim(x[2]) == "D1_PEDIDO" })
Local nPosITM		:= aScan(aHeader,{|x| Alltrim(x[2]) == "D1_ITEMPC" })
Local nPosQTD		:= aScan(aHeader,{|x| Alltrim(x[2]) == "D1_QUANT" })
Local nPosTes       := aScan(aHeader,{|x| AllTrim(x[2])=="D1_TES"})
Local nPosQtd2    := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_QTSEGUM"})  //HF
Local nPosValor   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_VUNIT"})      //HF
Local nPosTotal   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_TOTAL"})      //HF
Local nPosCC      := aScan(aHeader,{|x| AllTrim(x[2])=="D1_CC"})         //HF
Local lDivValor   := .F., nValQTD := 0, nValQtd2 := 0, nValValor := 0, nValTotal := 0   //HF
Local nLinACols     := N
Local cVar			:= aCols[n][nPosPrd]
Local cQuery		:= ""
Local cAliasSC7		:= "SC7"
Local cCpoObri		:= ""
Local nSavQual
Local nPed			:= 0
Local nX			:= 0
Local nAuxCNT		:= 0
Local lMt103Vpc		:= ExistBlock("MT103VPC")
Local lMt100C7D		:= ExistBlock("MT100C7D")
Local lMt100C7C		:= ExistBlock("MT100C7C")
Local lMt103Sel		:= ExistBlock("MT103SEL")
Local nMT103Sel     := 0
//Local nSelOk        := 1
Local lRet103Vpc	:= .T.
Local lContinua		:= .T.
Local lQuery		:= .F.
Local oQual
Local oDlg
Local oPanel
Local aUsButtons  := {}

PRIVATE aCab	   := {}
PRIVATE aCampos	   := {}
PRIVATE aArrSldo   := {}
PRIVATE aArrayF4   := {}

DEFAULT lUsaFiscal := .T.
DEFAULT aPedido	   := {}
DEFAULT lNfMedic   := .F.
DEFAULT lConsMedic := .F.
DEFAULT aHeadSDE   := {}
DEFAULT aColsSDE   := {}
DEFAULT aGets      := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impede de executar a rotina quando a tecla F3 estiver ativa		    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("InConPad") == "L"
	lContinua := !InConPad
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona botoes do usuario na EnchoiceBar                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "MTIPCBUT" )
	If ValType( aUsButtons := ExecBlock( "MTIPCBUT", .F., .F. ) ) == "A"
		AEval( aUsButtons, { |x| AAdd( aButtons, x ) } )
	EndIf
EndIf

If lContinua

	If MaFisFound('NF') .Or. !lUsaFiscal
		If cTipo == 'N'
			#IFDEF TOP
				DbSelectArea("SC7")
				If TcSrvType() <> "AS/400"

					If Empty(cVar)
						DbSetOrder(9)
					Else
						DbSetOrder(6)
					EndIf

					lQuery    := .T.
					cAliasSC7 := "QRYSC7"

					cQuery	  := "SELECT "
					For nAuxCNT := 1 To Len( aEstruSC7 )
						If nAuxCNT > 1
							cQuery += ", "
						EndIf
						cQuery += aEstruSC7[ nAuxCNT, 1 ]
					Next
					cQuery += ", R_E_C_N_O_ RECSC7 FROM"
					cQuery += RetSqlName("SC7") + " SC7 "
					cQuery += "WHERE "
					cQuery += "C7_FILENT = '"+xFilEnt(xFilial("SC7"))+"' AND "

					If HasTemplate( "DRO" ) .AND. FunName() == "MATA103" .AND. MV_PAR15 == 1
						cQuery += "C7_FORNECE IN ( " + T_DrogForn( cA100For ) + " ) AND "
					Else
					If Empty(cVar)
						If lConsLoja
							cQuery += "C7_FORNECE = '"+cA100For+"' AND "
							cQuery += "C7_LOJA = '"+cLoja+"' AND "
						Else
							cQuery += "C7_FORNECE = '"+cA100For+"' AND "
						Endif	
					Else
						If lConsLoja
							cQuery += "C7_FORNECE = '"+cA100For+"' AND "
							cQuery += "C7_LOJA = '"+cLoja+"' AND "
							cQuery += "C7_PRODUTO = '"+cVar+"' AND "
						Else
							cQuery += "C7_FORNECE = '"+cA100For+"' AND "
							cQuery += "C7_PRODUTO = '"+cVar+"' AND "
						Endif
					Endif
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Filtra os pedidos de compras de acordo com os contratos             ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

					If lConsMedic
						If lNfMedic
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Traz apenas os pedidos oriundos de medicoes                         ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							cQuery += "C7_CONTRA<>'"  + Space( Len( SC7->C7_CONTRA ) )  + "' AND "
							cQuery += "C7_MEDICAO<>'" + Space( Len( SC7->C7_MEDICAO ) ) + "' AND "		    		
						Else
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Traz apenas os pedidos que nao possuem medicoes                     ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							cQuery += "C7_CONTRA='"  + Space( Len( SC7->C7_CONTRA ) )  + "' AND "
							cQuery += "C7_MEDICAO='" + Space( Len( SC7->C7_MEDICAO ) ) + "' AND "		    		
						EndIf
					EndIf 					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Filtra os Pedidos Bloqueados e Previstos.                ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cQuery += "C7_TPOP <> 'P' AND "
					If SuperGetMV("MV_RESTNFE") == "S"
						cQuery += "C7_CONAPRO <> 'B' AND "
					EndIf					
					cQuery += "SC7.C7_ENCER='"+Space(Len(SC7->C7_ENCER))+"' AND "					
					cQuery += "SC7.C7_RESIDUO='"+Space(Len(SC7->C7_RESIDUO))+"' AND "					

					cQuery += "SC7.D_E_L_E_T_ = ' '"
					cQuery += "ORDER BY "+SqlOrder(SC7->(IndexKey()))	

					cQuery := ChangeQuery(cQuery)

					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC7,.T.,.T.)
					For nX := 1 To Len(aEstruSC7)
						If aEstruSC7[nX,2]<>"C"
							TcSetField(cAliasSC7,aEstruSC7[nX,1],aEstruSC7[nX,2],aEstruSC7[nX,3],aEstruSC7[nX,4])
						EndIf
					Next nX										
				Else
			#ENDIF			
				If Empty(cVar)
					DbSelectArea("SC7")
					DbSetOrder(9)
					If lConsLoja
						cCond := "C7_FILENT+C7_FORNECE+C7_LOJA"
						cSeek := cA100For+cLoja
						MsSeek(xFilEnt(xFilial("SC7"))+cSeek)
					Else
						cCond := "C7_FILENT+C7_FORNECE"
						cSeek := cA100For
						MsSeek(xFilEnt(xFilial("SC7"))+cSeek)
					EndIf
				Else
					DbSelectArea("SC7")
					DbSetOrder(6)
					If lConsLoja
						cCond := "C7_FILENT+C7_PRODUTO+C7_FORNECE+C7_LOJA"
						cSeek := cVar+cA100For+cLoja
						MsSeek(xFilEnt(xFilial("SC7"))+cSeek)
					Else
						cCond := "C7_FILENT+C7_PRODUTO+C7_FORNECE"
						cSeek := cVar+cA100For
						MsSeek(xFilEnt(xFilial("SC7"))+cSeek)
					EndIf
				EndIf
				#IFDEF TOP
				EndIf
				#ENDIF

			If Empty(cVar)
				cCpoObri := "C7_LOJA|C7_PRODUTO|C7_QUANT|C7_DESCRI|C7_TIPO|C7_LOCAL|C7_OBS"
			Else
				cCpoObri := "C7_LOJA|C7_QUANT|C7_DESCRI|C7_TIPO|C7_LOCAL|C7_OBS"
			Endif				

			If (cAliasSC7)->(!Eof())

				DbSelectArea("SX3")
				DbSetOrder(2)

				If lNfMedic .And. lConsMedic

					MsSeek("C7_MEDICAO")

					AAdd(aCab,x3Titulo())
					Aadd(aCampos,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_CONTEXT,SX3->X3_PICTURE})
					aadd(aTamCab,CalcFieldSize(SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_PICTURE,X3Titulo()))

					MsSeek("C7_CONTRA")

					AAdd(aCab,x3Titulo())
					Aadd(aCampos,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_CONTEXT,SX3->X3_PICTURE})
					aadd(aTamCab,CalcFieldSize(SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_PICTURE,X3Titulo()))

					MsSeek("C7_PLANILH")

					AAdd(aCab,x3Titulo())
					Aadd(aCampos,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_CONTEXT,SX3->X3_PICTURE})
					aadd(aTamCab,CalcFieldSize(SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_PICTURE,X3Titulo()))

				EndIf 			

				MsSeek("C7_NUM")

				AAdd(aCab,x3Titulo())
				Aadd(aCampos,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_CONTEXT,SX3->X3_PICTURE})
				aadd(aTamCab,CalcFieldSize(SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_PICTURE,X3Titulo()))

				DbSelectArea("SX3")
				DbSetOrder(1)
				MsSeek("SC7")
				While !Eof() .And. SX3->X3_ARQUIVO == "SC7"
					IF ( SX3->X3_BROWSE=="S".And.X3Uso(SX3->X3_USADO).And. AllTrim(SX3->X3_CAMPO)<>"C7_PRODUTO" .And. AllTrim(SX3->X3_CAMPO)<>"C7_NUM" .And.;
							If( lConsMedic .And. lNfMedic, AllTrim(SX3->X3_CAMPO)<>"C7_MEDICAO" .And. AllTrim(SX3->X3_CAMPO)<>"C7_CONTRA" .And. AllTrim(SX3->X3_CAMPO)<>"C7_PLANILH", .T. )).Or.;
							(AllTrim(SX3->X3_CAMPO) $ cCpoObri)
						AAdd(aCab,x3Titulo())
						Aadd(aCampos,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_CONTEXT,SX3->X3_PICTURE})
						aadd(aTamCab,CalcFieldSize(SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_PICTURE,X3Titulo()))
					EndIf
					dbSkip()		
				Enddo					

				DbSelectArea(cAliasSC7)
				Do While If(lQuery, ;
						(cAliasSC7)->(!Eof()), ;
						(cAliasSC7)->(!Eof()) .And. xFilEnt(cFilial)+cSeek == &(cCond))

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Filtra os Pedidos Bloqueados, Previstos e Eliminados por residuo   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !lQuery
						If (SuperGetMV("MV_RESTNFE") == "S" .And. (cAliasSC7)->C7_CONAPRO == "B") .Or. ;
								(cAliasSC7)->C7_TPOP == "P" .Or. !Empty((cAliasSC7)->C7_RESIDUO)
							dbSkip()
							Loop
						EndIf
					Endif

					nFreeQT := 0

					nPed    := aScan(aPedido,{|x| x[1] = (cAliasSC7)->C7_NUM+(cAliasSC7)->C7_ITEM})

					nFreeQT -= If(nPed>0,aPedido[nPed,2],0)

					For nAuxCNT := 1 To Len( aCols )
						If (nAuxCNT # n) .And. ;
							(aCols[ nAuxCNT,nPosPRD ] == (cAliasSC7)->C7_PRODUTO) .And. ;
							(aCols[ nAuxCNT,nPosPDD ] == (cAliasSC7)->C7_NUM) .And. ;
							(aCols[ nAuxCNT,nPosITM ] == (cAliasSC7)->C7_ITEM) .And. ;
							!ATail( aCols[ nAuxCNT ] )
							nFreeQT += aCols[ nAuxCNT,nPosQTD ]
						EndIf
					Next
					
					lRet103Vpc := .T.

					If lMt103Vpc
						If lQuery
							('SC7')->(dbGoto((cAliasSC7)->RECSC7))
						EndIf															
						lRet103Vpc := Execblock("MT103VPC",.F.,.F.)
					Endif

					If lRet103Vpc
						If ((nFreeQT := ((cAliasSC7)->C7_QUANT-(cAliasSC7)->C7_QUJE-(cAliasSC7)->C7_QTDACLA-nFreeQT)) > 0)
							Aadd(aArrayF4,Array(Len(aCampos)))							

							SB1->(DbSetOrder(1))
							SB1->(MsSeek(xFilial("SB1")+(cAliasSC7)->C7_PRODUTO))							
							For nX := 1 to Len(aCampos)

								If aCampos[nX][3] != "V"
									If aCampos[nX][2] == "N"
										If Alltrim(aCampos[nX][1]) == "C7_QUANT"
											aArrayF4[Len(aArrayF4)][nX] :=Transform(nFreeQt,PesqPict("SC7",aCampos[nX][1]))
										ElseIf Alltrim(aCampos[nX][1]) == "C7_QTSEGUM"
											aArrayF4[Len(aArrayF4)][nX] :=Transform(ConvUm(SB1->B1_COD,nFreeQt,nFreeQt,2),PesqPict("SC7",aCampos[nX][1]))
										Else
											aArrayF4[Len(aArrayF4)][nX] := Transform((cAliasSC7)->(FieldGet(FieldPos(aCampos[nX][1]))),PesqPict("SC7",aCampos[nX][1]))
										Endif											
									Else
										aArrayF4[Len(aArrayF4)][nX] := (cAliasSC7)->(FieldGet(FieldPos(aCampos[nX][1])))								
									Endif	
								Else
									aArrayF4[Len(aArrayF4)][nX] := CriaVar(aCampos[nX][1],.T.)
									If Alltrim(aCampos[nX][1]) == "C7_CODGRP"
										aArrayF4[Len(aArrayF4)][nX] := SB1->B1_GRUPO                            									
									EndIf
									If Alltrim(aCampos[nX][1]) == "C7_CODITE"
										aArrayF4[Len(aArrayF4)][nX] := SB1->B1_CODITE
									EndIf
								Endif

							Next

							aAdd(aArrSldo, {nFreeQT, IIF(lQuery,(cAliasSC7)->RECSC7,(cAliasSC7)->(RecNo()))})

							If lMT100C7D
								If lQuery
									('SC7')->(dbGoto((cAliasSC7)->RECSC7))
								EndIf									
								aNew := ExecBlock("MT100C7D", .f., .f., aArrayF4[Len(aArrayF4)])
								If ValType(aNew) = "A"
									aArrayF4[Len(aArrayF4)] := aNew
								EndIf
							EndIf
						EndIf
					Endif
					(cAliasSC7)->(dbSkip())
				EndDo

				If ExistBlock("MT100C7L")
					ExecBlock("MT100C7L", .F., .F., { aArrayF4, aArrSldo })
				EndIf

				If !Empty(aArrayF4)

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Monta dinamicamente o bline do CodeBlock                 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					DEFINE MSDIALOG oDlg FROM 30,20  TO 265,521 TITLE OemToAnsi("Selecionar Pedido de Compra ( por item ) - <F6> ") Of oMainWnd PIXEL //"Selecionar Pedido de Compra ( por item )"

					If lMT100C7C
						aNew := ExecBlock("MT100C7C", .f., .f., aCab)
						If ValType(aNew) == "A"
							aCab := aNew      
							    
							DbSelectArea("SX3")
			 				DbSetOrder(2)								
							
							For nX := 1 to Len(aCab)
						    	If aScan(aCampos,{|x| x[1]= aCab[nX]})==0
        						 If SX3->(MsSeek(aCab[nX]))				
        						 		Aadd(aCampos,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_CONTEXT,SX3->X3_PICTURE})
        						 EndIf
   								EndIf
							Next nX
							
							
						EndIf
					EndIf

					@ 12,0 MSPANEL oPanel PROMPT "" SIZE 100,19 OF oDlg CENTERED LOWERED //"Botoes"
					oPanel:Align := CONTROL_ALIGN_TOP

					oQual := TWBrowse():New( 29,4,243,85,,aCab,aTamCab,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
					oQual:SetArray(aArrayF4)
					oQual:bLine := { || aArrayF4[oQual:nAT] }
					OQual:nFreeze := 1 

					oQual:Align := CONTROL_ALIGN_ALLCLIENT

					If !Empty(cVar)
						@ 6  ,4   SAY OemToAnsi("Produto") Of oPanel PIXEL SIZE 47 ,9 //"Produto"
						@ 4  ,30  MSGET cVar PICTURE PesqPict('SB1','B1_COD') When .F. Of oPanel PIXEL SIZE 80,9
					Else
						@ 6  ,4   SAY OemToAnsi("Selecione o Pedido de Compra") Of oPanel PIXEL SIZE 120 ,9 //"Selecione o Pedido de Compra"
					EndIf

					ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| nSavQual:=oQual:nAT,nOpca:=1,oDlg:End()},{||oDlg:End()},,aButtons)
					
				  	If lMt103Sel .And. !Empty(nSavQual)		
				   		nOpca := If(ValType(nMT103Sel:=ExecBlock("MT103SEL",.F.,.F.,{aArrSldo[nSavQual][2]}))=='N',nMT103Sel,nOpca)
				   	Endif     
					If nOpca == 1
						DbSelectArea("SC7")
						MsGoto(aArrSldo[nSavQual][2])
						
   				        // Verifica se o Produto existe Cadastrado na Filial de Entrada
					    DbSelectArea("SB1")
						DbSetOrder(1)
						MsSeek(xFilial("SB1")+SC7->C7_PRODUTO)
						If !Eof()
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Qdo digitado o produto no aCols para buscar o PC via F6 e carregado uma TES vinda do  ³
							//³ SB1 se esta for igual a TES digitada no PC o recalculo dos impostos nao e acionado    ³
							//³ na matxfis,para forcar o recalculo o TES do aCols e limpa neste ponto.                ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If lUsaFiscal
								aCols[nLinACols][nPosTes] := CriaVar(aHeader[nPosTes][2]) 
								MaFisAlt("IT_TES",aCols[nLinACols][nPosTes],nLinACols)
                            EndIf
                            
							If	!ATail( aCols[ n ] )
								nValQTD := aCols[nLinACols][nPosQTD]     //HF
								nValQtd2 := aCols[nLinACols][nPosQtd2]   //HF
								nValValor := aCols[nLinACols][nPosValor] //HF
								nValTotal := aCols[nLinACols][nPosTotal] //HF

								u_NfePC2Acol(aArrSldo[nSavQual][2],n,aArrSldo[nSavQual][1],,,@aRateio,aHeadSDE,@aColsSDE)

								if cPCSol == "N"  //HF Pega Pelo Produto e não do Pedido de Compra
									aCols[nLinACols][nPosCC] := SB1->B1_CC  //HF já esta posicionado.
								endif
								if AllTrim(GetNewPar("XM_PED_PRE","N")) == "N" 
									if nValQTD <> aCols[nLinACols][nPosQTD] .And. nValQTD > 0 //HF
										aCols[nLinACols][nPosQTD] := nValQTD
									EndIf
									If nValQtd2 <> aCols[nLinACols][nPosQtd2] .And. nValQtd2 > 0 //HF
										aCols[nLinACols][nPosQtd2] := nValQtd2
									Endif
									if nValValor <> aCols[nLinACols][nPosValor] //HF
										lDivValor := .T.
											U_MYAVISO("Atenção","Valor Unitário não bate "+CRLF+;
										          "XML   "+Transform( nValValor, "99,999,999,999.99" )+CRLF+;
										          "Pedido"+Transform( aCols[nLinACols][nPosValor], "99,999,999,999.99" ), { "OK" },3)
										aCols[nLinACols][nPosValor] := nValValor
									EndIf
									if nValTotal <> aCols[nLinACols][nPosTotal] //HF
										aCols[nLinACols][nPosTotal] := nValTotal
									endif
								endif

	        				Else
								u_NfePC2Acol(aArrSldo[nSavQual][2],n+1,aArrSldo[nSavQual][1],,,@aRateio,aHeadSDE,@aColsSDE)
	        				EndIf
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Impede que o item do PC seja deletado pela getdados da NFE na movimentacao das setas. ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If ValType( oGetDAtu ) == "O"
								oGetDAtu:lNewLine := .F.
							Else
								If Type( "oGetDados" ) == "O"
									oGetDados:lNewLine:=.F.
								EndIf
							EndIf
						Else
  						   Aviso("XMLPCF6","O Produto selecionado do Pedido de compra, não possui cadastro na Filial de Entrada da Nota Fiscal. Favor efetuar cadastro !",{"Ok"})
						EndIf
					EndIf
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Rateio do valores de Frete/Seguro/Despesa do PC            ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lUsaFiscal
						Eval(bRefresh)
					Else
						if .Not. lTemSegXml
							aGets[SEGURO] += aRateio[1]
						endif
						if .Not. lTemDesXml
							aGets[VALDESP]+= aRateio[2]
						endif
						if .Not. lTemFreXml
							aGets[FRETE]  += aRateio[3]
						endif
					EndIf
				Else
					Help(" ",1,"A103F4")
				EndIf
			Else
				Help(" ",1,"A103F4")
			EndIf
		Else
			Help('   ',1,'A103TIPON')
		EndIf
	Else
		Help('   ',1,'A103CAB')
	EndIf

Endif

If lQuery
	DbSelectArea(cAliasSC7)
	dbCloseArea()
	DbSelectArea("SC7")
Endif	

//SetKey(VK_F4,bSavSetKey)
//SetKey(VK_F5,bSavKeyF5)
//SetKey(VK_F6,bSavKeyF6)
//SetKey(VK_F7,bSavKeyF7)
//SetKey(VK_F8,bSavKeyF8)
//SetKey(VK_F9,bSavKeyF9)
//SetKey(VK_F10,bSavKeyF10)
//SetKey(VK_F11,bSavKeyF11)
RestArea(aAreaSA2)
RestArea(aAreaSC7)
RestArea(aAreaSB1)
RestArea(aArea)   
Return


User FUnction XMLDEBUG()

	RpcSetType(3)
	PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" MODULO "COM" TABLES "SF1","SF2","SD1","SD2","SF4","SB5","SF3","SB1"

Private lRet     := .F.                     
Private ny       := 0                     
Private aFiles   := {}
Private cDir     := AllTrim(GetNewPar("MV_X_PATHX"," "))                     
Private lDirCnpj := AllTrim(GetNewPar("XM_DIRCNPJ","N")) == "S"                     
Private lDirFil  := AllTrim(GetNewPar("XM_DIRFIL" ,"N")) == "S" 
Private lDirMod  := AllTrim(GetNewPar("XM_DIRMOD" ,"N")) == "S"                     
Private cDirDest := AllTrim(cDir+"\Importados\")                     
Private cDirRej  := AllTrim(cDir+"\Rejeitados\")                     
Private cDrive   := "" 
Private cPath    := ""  
Private cNewFile := ""
Private cExt     := ""                        
Private lCopy    := .F.
Private nErase   := 0 
Private cFilXml  := ""
Private cKeyXml  := ""
Private lOnline  := .F.
Private cInfo    := ""
Private cErroR   := ""
Private cErroProc:= ""
Private cMsg     := ""
Private cOcorr   := ""
Private cPref    := ""  
Private aPref    := {"CTE","NFE"} 
Private oXml     := Nil  


	cXml := MemoRead("X:\TOTVS\P10\Protheus_data\xmlsource\42130460333267000122550010000275141002249733.xml")
	
	nTamFile := Len(cXml)
	
	If nTamFile > 65535
		Conout(nTamFile)
oXml:=XmlParserFile("\Protheus_data\xmlsource\42130460333267000122550010000275141002249733.xml","_", @cError, @cWarning )		
	Else
		Conout(nTamFile)
			
	EndIf

Return()


Static Function ErNfOri( aDetCte )
Local lRet := .T.
Local cTit1 := ""

Private cInfo := ""

cTit1 := "Avisos - NF e Série de Origem do CTE"

if lRet
	//Produto com probela de valores, devido modificação pelo ponto de Entrada
	If !Empty(aDetCte)

		DEFINE MSDIALOG oDlg TITLE cTit1 FROM 000,000 TO 550,650 PIXEL

		if lNfOri
			@ 010,010 Say "Itens com NF e SERIE de Origem divergentes (Volte e Utilize F7 para consultar Notas do Fornecedor):" PIXEL OF oDlg COLOR CLR_RED FONT oFont01
		else
			@ 010,010 Say "Itens com NF e SERIE de Origem divergentes (Volte e Utilize F7 para consultar Notas da Transportadora):" PIXEL OF oDlg COLOR CLR_RED FONT oFont01
		endif
		@ 020,010 LISTBOX oLbx2 FIELDS HEADER ;
		   "NF/Serie", "Divergencia" ;
		   SIZE 310,230 OF oDlg PIXEL

		oLbx2:SetArray( aDetCte )
		oLbx2:bLine := {|| {aDetCte[oLbx2:nAt,1],;
		     	            aDetCte[oLbx2:nAt,2] }}

		@ 025.2,040 BUTTON "VOLTAR E ALTERAR" SIZE 75,15 OF oDlg Action ( lRet := .F., oDlg:End() )
		@ 025.2,059 BUTTON "CONTINUAR ASSIM MESMO" SIZE 85,15 OF oDlg Action ( lRet := .T., oDlg:End() )

		ACTIVATE MSDIALOG oDlg CENTER
	EndIf
Endif

Return lRet



/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Sf3NfOri  ³ Autor ³ Orelha Seca           ³ Data ³07.02.2141 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Interface de visualizacao dos documentos de entrada/saida    ³±±
±±³          ³para devolucao                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Nome da rotina chamadora                              ³±±
±±³          ³ExpN2: Numero da linha da rotina chamadora              (OPC)³±±
±±³          ³ExpC4: Nome do campo GET em foco no momento             (OPC)³±±
±±³          ³ExpC5: Codigo do Cliente/Fornecedor                          ³±±
±±³          ³ExpC6: Loja do Cliente/Fornecedor                            ³±±
±±³          ³ExpC7: Codigo do Produto                                     ³±±
±±³          ³ExpC8: Local a ser considerado                               ³±±
±±³          ³ExpN9: Numero do recno do SD1/SD2                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo atualizar os eventos vinculados³±±
±±³          ³a uma solicitacao de compra:                                 ³±±
±±³          ³A) Atualizacao das tabelas complementares.                   ³±±
±±³          ³B) Atualizacao das informacoes complementares a SC           ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function Sf3NfOri(cReadVar,cFornec)

Local aArea     := GetArea()
Local aAreaSF3  := SF3->(GetArea())
Local aStruTRB  := {}
Local aStruSF3  := {}
Local aOrdem    := {AllTrim(RetTitle("F3_NFISCAL"))+"+"+AllTrim(RetTitle("F3_SERIE")),AllTrim(RetTitle("F3_EMISSAO"))}
Local aChave    := {}
Local aPesq     := {}
Local aNomInd   := {}
Local aObjects  := {}
Local aInfo     := {}
Local aPosObj   := {}
Local aSize     := MsAdvSize( .F. )
Local aHeadTRB  := {}
Local aSavHead  := aClone(aHeader)
Local cAliasSF3 := "SF3"
Local cAliasTRB := "CTENFORI"
Local cNomeTrb  := ""
Local cQuery    := ""
Local cCombo    := ""
Local cTexto1   := ""
Local cTexto2   := ""
Local lQuery    := .F.
Local lRetorno  := .F.
//Local lSkip     := .F.
Local nX        := 0
//Local nY        := 0
//Local nSldQtd   := 0
//Local nSldQtd2  := 0
//Local nSldLiq   := 0
//Local nSldBru   := 0
Local nHdl      := GetFocus()
Local nOpcA     := 0
Local nPNfOri   := 0
Local nPSerOri  := 0
//Local nPItemOri := 0
//Local nPLocal   := 0
//Local nPPrUnit  := 0
//Local nPPrcVen  := 0
//Local nPQuant   := 0
//Local nPQuant2UM:= 0
//Local nPLoteCtl := 0
//Local nPNumLote := 0
//Local nPDtValid := 0
//Local nPPotenc  := 0
//Local nPValor   := 0
//Local nPValDesc := 0
//Local nPDesc    := 0
//Local nPOrigem  := 0
//Local nPDespacho:= 0
//Local nPTES     := 0
//Local nPProvEnt := 0
Local xPesq     := ""
Local oDlg
Local oCombo
Local oGet
Local oGetDb
Local oPanel
//Local cFiltraQry:=""
//Local lFiltraQry:=.F.

DEFAULT cReadVar := ReadVar()

PRIVATE aRotina  := {}

For nX := 1 To 11	// Walk_Thru
	aAdd(aRotina,{"","",0,0})
Next

If "_NFORI"$cReadVar
			aChave    := {"F3_NFISCAL+F3_SERIE","F3_EMISSAO"}
			aPesq     := {{Space(Len(SF3->F3_NFISCAL+SF3->F3_SERIE)),"@!"},{Ctod(""),"@!"}}
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Montagem do arquivo temporario                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SX3")
			dbSetOrder(1)
			MsSeek("SF3")
			While !Eof() .And. SX3->X3_ARQUIVO == "SF3"
				If ( X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL .And.;
					SX3->X3_CONTEXT <> "V"  .And.;
					SX3->X3_TIPO<>"M" ) .Or.;
					Trim(SX3->X3_CAMPO) == "F3_NFISCAL" .Or.;
					Trim(SX3->X3_CAMPO) == "F3_SERIE"  .Or.;
					Trim(SX3->X3_CAMPO) == "F3_EMISSAO" .Or.;
					Trim(SX3->X3_CAMPO) == "F3_TIPO" .Or.;
					Trim(SX3->X3_CAMPO) == "F3_CLIEFOR" .Or. ;
					Trim(SX3->X3_CAMPO) == "F3_LOJA"
					Aadd(aHeadTrb,{ TRIM(X3Titulo()),;
						SX3->X3_CAMPO,;
						SX3->X3_PICTURE,;
						SX3->X3_TAMANHO,;
						SX3->X3_DECIMAL,;
						SX3->X3_VALID,;
						SX3->X3_USADO,;
						SX3->X3_TIPO,;
						SX3->X3_ARQUIVO,;
						SX3->X3_CONTEXT,;
						IIf(AllTrim(SX3->X3_CAMPO)$"F3_NFISCAL#F3_SERIE#F3_TIPO","00",SX3->X3_ORDEM) })
					aadd(aStruTRB,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,IIf(AllTrim(SX3->X3_CAMPO)$"F3_NFISCAL#F3_SERIE","00",SX3->X3_ORDEM)})
				EndIf
				dbSelectArea("SX3")
				dbSkip()
			EndDo
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Walk-Thru                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			ADHeadRec("SF3",aHeadTrb)
			aSize(aHeadTrb[Len(aHeadTrb)-1],11)
			aSize(aHeadTrb[Len(aHeadTrb)],11)
			aHeadTrb[Len(aHeadTrb)-1,11] := "ZX"
			aHeadTrb[Len(aHeadTrb),11]	 := "ZY"
			aadd(aStruTRB,{"F3_ALI_WT","C",3,0,"ZX"})
			aadd(aStruTRB,{"F3_REC_WT","N",18,0,"ZY"})

			aadd(aStruTRB,{"F3_TOTAL2","N",18,2,"ZZ"})
			aHeadTrb := aSort(aHeadTrb,,,{|x,y| x[11] < y[11]})
			aStruTrb := aSort(aStruTrb,,,{|x,y| x[05] < y[05]})
			cNomeTrb := CriaTrab(aStruTRB,.T.)
			dbUseArea(.T.,__LocalDrive,cNomeTrb,cAliasTRB,.F.,.F.)
			dbSelectArea(cAliasTRB)
			For nX := 1 To Len(aChave)
				aadd(aNomInd,SubStr(cNomeTrb,1,7)+chr(64+nX))
				IndRegua(cAliasTRB,aNomInd[nX],aChave[nX])
			Next nX
			dbClearIndex()
			For nX := 1 To Len(aNomInd)
				dbSetIndex(aNomInd[nX])
			Next nX
			dbSelectArea("SF3")
			dbSetOrder(2)
			#IFDEF TOP
				lQuery    := .T.
			    cAliasSF3 := "CTENFORI_SQL"
			    aStruSF3 := SF3->(dbStruct())
				cQuery := "SELECT SF3.F3_FILIAL"
				For nX := 1 To Len(aStruTRB)
					If !"F3_REC_WT"$aStruTRB[nX][1] .And. !"F3_ALI_WT"$aStruTRB[nX][1] .And. !"F3_TOTAL2"$aStruTRB[nX][1]
						cQuery += ","+aStruTRB[nX][1]
					EndIf
				Next nX
				cQuery += " FROM "+RetSqlName("SF3")+" SF3 "
				cQuery += "WHERE "
				cQuery += "SF3.F3_FILIAL = '"+xFilial("SF3")+"' AND "
				If .Not. Empty(cFornec)
					cQuery += "SF3.F3_CLIEFOR||SF3.F3_LOJA in ("+cFornec+") AND "   //AQUI ORACLE, VER o SQL
				Else
					//cQuery += "SF3.F3_CLIEFOR+SF3.F3_LOJA = '"+cFornec+"' AND "
				EndIF
				cQuery += "SF3.D_E_L_E_T_=' ' "
				cQuery += "ORDER BY F3_NFISCAL,F3_SERIE "//+SqlOrder(SF3->(IndexKey())) //Para não dar pobrema no rrefrexe

				cQuery := ChangeQuery(cQuery)

				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF3,.T.,.T.)

				For nX := 1 To Len(aStruSF3)
					If aStruSF3[nX][2] <> "C" .And. FieldPos(aStruSF3[nX][1])<>0
						TcSetField(cAliasSF3,aStruSF3[nX][1],aStruSF3[nX][2],aStruSF3[nX][3],aStruSF3[nX][4])
					EndIf
				Next nX
				(cAliasSF3)->(dbGoTop())
			#ELSE
				MsSeek(xFilial("SF3"),.F.)
			#ENDIF
			While !Eof() .And. (cAliasSF3)->F3_FILIAL = xFilial("SF3")
					RecLock(cAliasTRB,.T.)
					For nX := 1 To Len(aStruTRB)
						If (cAliasSF3)->(FieldPos(aStruTRB[nX][1]))<>0
							(cAliasTRB)->(FieldPut(nX,(cAliasSF3)->(FieldGet(FieldPos(aStruTRB[nX][1])))))
						EndIf
					Next nX
					(cAliasTRB)->F3_ALI_WT := "SF3"
					MsUnLock()
				dbSelectArea(cAliasSF3)
				dbSkip()
			EndDo
			If lQuery
				dbSelectArea(cAliasSF3)
				dbCloseArea()
				dbSelectArea("SF3")
			EndIf

	If (cAliasTRB)->(LastRec())<>0
		PRIVATE aHeader := aHeadTRB
		xPesq := aPesq[(cAliasTRB)->(IndexOrd())][1]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona registros                                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SA2")
		dbSetOrder(1)
		MsSeek(xFilial("SA2")+Substr(cFornec,2,8))

		dbSelectArea(cAliasTRB)
		dbGotop()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula as coordenadas da interface                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Interface com o usuario                                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DEFINE MSDIALOG oDlg TITLE OemToAnsi("Notas Fiscais Entrada de Origem") FROM aSize[7],000 TO aSize[6],aSize[5] OF oMainWnd PIXEL
		@ aPosObj[1,1],aPosObj[1,2] MSPANEL oPanel PROMPT "" SIZE aPosObj[1,3],aPosObj[1,4] OF oDlg CENTERED LOWERED
		cTexto1 := AllTrim(RetTitle("F3_CLIEFOR"))+": "+SA2->A2_COD+"-"+SA2->A2_LOJA+"  -  "+RetTitle("A2_NOME")+": "+SA2->A2_NOME
		@ 002,005 SAY cTexto1 SIZE aPosObj[1,3],008 OF oPanel PIXEL
		cTexto2 := ""
		@ 012,005 SAY cTexto2 SIZE aPosObj[1,3],008 OF oPanel PIXEL	

		@ aPosObj[3,1]+00,aPosObj[3,2]+00 SAY OemToAnsi("Pesquisar por:") PIXEL //Pesquisar por:
		@ aPosObj[3,1]+12,aPosObj[3,2]+00 SAY OemToAnsi("Localizar") PIXEL //Localizar
		@ aPosObj[3,1]+00,aPosObj[3,2]+40 MSCOMBOBOX oCombo VAR cCombo ITEMS aOrdem SIZE 100,044 OF oDlg PIXEL ;
		VALID ((cAliasTRB)->(dbSetOrder(oCombo:nAt)),(cAliasTRB)->(dbGotop()),xPesq := aPesq[(cAliasTRB)->(IndexOrd())][1],.T.)
	  	@ aPosObj[3,1]+12,aPosObj[3,2]+40 MSGET oGet VAR xPesq Of oDlg PICTURE aPesq[(cAliasTRB)->(IndexOrd())][2] PIXEL ;
	  	VALID ((cAliasTRB)->(MsSeek(Iif(ValType(xPesq)=="C",AllTrim(xPesq),xPesq),.T.)),.T.).And.IIf(oGetDb:oBrowse:Refresh()==Nil,.T.,.T.)

	  	oGetDb := MsGetDB():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],1,"Allwaystrue","allwaystrue","",.F., , ,.F., ,cAliasTRB)

		DEFINE SBUTTON FROM aPosObj[3,1]+000,aPosObj[3,4]-030 TYPE 1 ACTION (nOpcA := 1,oDlg:End()) ENABLE OF oDlg
		DEFINE SBUTTON FROM aPosObj[3,1]+012,aPosObj[3,4]-030 TYPE 2 ACTION (nOpcA := 0,oDlg:End()) ENABLE OF oDlg
		oGetDb:oBrowse:Refresh()
		ACTIVATE MSDIALOG oDlg CENTERED

		If nOpcA == 1
			lRetorno := .T.
			aHeader   := aClone(aSavHead)
 			nPNfOri   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_NFORI"})
 			nPSerOri  := aScan(aHeader,{|x| AllTrim(x[2])=="D1_SERIORI"})

 			If nPNfOri <> 0
 				aCols[N][nPNfOri] := (cAliasTRB)->F3_NFISCAL
 			EndIf
 			If nPSerOri <> 0
 				aCols[N][nPSerOri] := (cAliasTRB)->F3_SERIE
 			EndIf
 			if len(aCnpRem) >= N
 				aCnpRem[N] := SA2->A2_CGC
 			endif
			&(cReadVar) := (cAliasTRB)->F3_NFISCAL
		EndIf
	Else
		U_MyAviso("Atenção","Não existem Notas Emitidas com este Fornecedor!"+CRLF +"Fornecedor :"+cFornec,{"OK"},3)
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura a integridade da rotina                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea(cAliasTRB)
	dbCloseArea()
EndIf
dbSelectArea("SA2")

RestArea(aAreaSF3)
RestArea(aArea)
SetFocus(nHdl)
Return(lRetorno)




/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CteNfOri  ³ Autor ³ Orelha Seca           ³ Data ³07.02.2141 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Interface de visualizacao dos documentos de entrada/saida    ³±±
±±³          ³para devolucao                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Nome da rotina chamadora                              ³±±
±±³          ³ExpN2: Numero da linha da rotina chamadora              (OPC)³±±
±±³          ³ExpC4: Nome do campo GET em foco no momento             (OPC)³±±
±±³          ³ExpC5: Codigo do Cliente/Fornecedor                          ³±±
±±³          ³ExpC6: Loja do Cliente/Fornecedor                            ³±±
±±³          ³ExpC7: Codigo do Produto                                     ³±±
±±³          ³ExpC8: Local a ser considerado                               ³±±
±±³          ³ExpN9: Numero do recno do SD1/SD2                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo atualizar os eventos vinculados³±±
±±³          ³a uma solicitacao de compra:                                 ³±±
±±³          ³A) Atualizacao das tabelas complementares.                   ³±±
±±³          ³B) Atualizacao das informacoes complementares a SC           ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function CteNfOri(cReadVar,cTransp)

Local aArea     := GetArea()
Local aAreaSF1  := SF1->(GetArea())
Local aAreaSF2  := SF2->(GetArea())
Local aStruTRB  := {}
Local aStruSF2  := {}
Local aOrdem    := {AllTrim(RetTitle("F2_DOC"))+"+"+AllTrim(RetTitle("F2_SERIE")),AllTrim(RetTitle("F2_EMISSAO"))}
Local aChave    := {}
Local aPesq     := {}
Local aNomInd   := {}
Local aObjects  := {}
Local aInfo     := {}
Local aPosObj   := {}
Local aSize     := MsAdvSize( .F. )
Local aHeadTRB  := {}
Local aSavHead  := aClone(aHeader)
//Local cAliasSF1 := "SF1"
Local cAliasSF2 := "SF2"
Local cAliasTRB := "CTENFORI"
Local cNomeTrb  := ""
Local cQuery    := ""
Local cCombo    := ""
Local cTexto1   := ""
Local cTexto2   := ""
Local lQuery    := .F.
Local lRetorno  := .F.
//Local lSkip     := .F.
Local nX        := 0
//Local nY        := 0
//Local nSldQtd   := 0
//Local nSldQtd2  := 0
//Local nSldLiq   := 0
//Local nSldBru   := 0
Local nHdl      := GetFocus()
Local nOpcA     := 0
Local nPNfOri   := 0
Local nPSerOri  := 0
/*Local nPItemOri := 0
Local nPLocal   := 0
Local nPPrUnit  := 0
Local nPPrcVen  := 0
Local nPQuant   := 0
Local nPQuant2UM:= 0
Local nPLoteCtl := 0
Local nPNumLote := 0
Local nPDtValid := 0
Local nPPotenc  := 0
Local nPValor   := 0
Local nPValDesc := 0
Local nPDesc    := 0
Local nPOrigem  := 0
Local nPDespacho:= 0
Local nPTES     := 0
Local nPProvEnt := 0*/
Local xPesq     := ""
Local oDlg
Local oCombo
Local oGet
Local oGetDb
Local oPanel
//Local cFiltraQry:=""
//Local lFiltraQry:=.F.

DEFAULT cReadVar := ReadVar()

PRIVATE aRotina  := {}

For nX := 1 To 11	// Walk_Thru
	aAdd(aRotina,{"","",0,0})
Next

If "_NFORI"$cReadVar
			aChave    := {"F2_DOC+F2_SERIE","F2_EMISSAO"}
			aPesq     := {{Space(Len(SF2->F2_DOC+SF2->F2_SERIE)),"@!"},{Ctod(""),"@!"}}
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Montagem do arquivo temporario                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SX3")
			dbSetOrder(1)
			MsSeek("SF2")
			While !Eof() .And. SX3->X3_ARQUIVO == "SF2"
				If ( X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL .And.;
					SX3->X3_CONTEXT <> "V"  .And.;
					SX3->X3_TIPO<>"M" ) .Or.;
					Trim(SX3->X3_CAMPO) == "F2_DOC" .Or.;
					Trim(SX3->X3_CAMPO) == "F2_SERIE"  .Or.;
					Trim(SX3->X3_CAMPO) == "F2_EMISSAO" .Or.;
					Trim(SX3->X3_CAMPO) == "F2_TIPO" .Or.;
					Trim(SX3->X3_CAMPO) == "F2_TRANSP" .Or. ;
					Trim(SX3->X3_CAMPO) == "F2_CLIENTE" .Or. ;
					Trim(SX3->X3_CAMPO) == "F2_LOJA"
					Aadd(aHeadTrb,{ TRIM(X3Titulo()),;
						SX3->X3_CAMPO,;
						SX3->X3_PICTURE,;
						SX3->X3_TAMANHO,;
						SX3->X3_DECIMAL,;
						SX3->X3_VALID,;
						SX3->X3_USADO,;
						SX3->X3_TIPO,;
						SX3->X3_ARQUIVO,;
						SX3->X3_CONTEXT,;
						IIf(AllTrim(SX3->X3_CAMPO)$"F2_DOC#F2_SERIE#F2_TIPO","00",SX3->X3_ORDEM) })
					aadd(aStruTRB,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,IIf(AllTrim(SX3->X3_CAMPO)$"F2_DOC#F2_SERIE","00",SX3->X3_ORDEM)})
				EndIf
				dbSelectArea("SX3")
				dbSkip()
			EndDo
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Walk-Thru                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			ADHeadRec("SF2",aHeadTrb)
			aSize(aHeadTrb[Len(aHeadTrb)-1],11)
			aSize(aHeadTrb[Len(aHeadTrb)],11)
			aHeadTrb[Len(aHeadTrb)-1,11] := "ZX"
			aHeadTrb[Len(aHeadTrb),11]	 := "ZY"
			aadd(aStruTRB,{"F2_ALI_WT","C",3,0,"ZX"})
			aadd(aStruTRB,{"F2_REC_WT","N",18,0,"ZY"})

			aadd(aStruTRB,{"F2_TOTAL2","N",18,2,"ZZ"})
			aHeadTrb := aSort(aHeadTrb,,,{|x,y| x[11] < y[11]})
			aStruTrb := aSort(aStruTrb,,,{|x,y| x[05] < y[05]})
			cNomeTrb := CriaTrab(aStruTRB,.T.)
			dbUseArea(.T.,__LocalDrive,cNomeTrb,cAliasTRB,.F.,.F.)
			dbSelectArea(cAliasTRB)
			For nX := 1 To Len(aChave)
				aadd(aNomInd,SubStr(cNomeTrb,1,7)+chr(64+nX))
				IndRegua(cAliasTRB,aNomInd[nX],aChave[nX])
			Next nX
			dbClearIndex()
			For nX := 1 To Len(aNomInd)
				dbSetIndex(aNomInd[nX])
			Next nX
			dbSelectArea("SF2")
			dbSetOrder(2)
			#IFDEF TOP
				lQuery    := .T.
			    cAliasSF2 := "CTENFORI_SQL"
			    aStruSF2 := SF2->(dbStruct())
				cQuery := "SELECT SF2.F2_FILIAL"
				For nX := 1 To Len(aStruTRB)
					If !"F2_REC_WT"$aStruTRB[nX][1] .And. !"F2_ALI_WT"$aStruTRB[nX][1] .And. !"F2_TOTAL2"$aStruTRB[nX][1]
						cQuery += ","+aStruTRB[nX][1]
					EndIf
				Next nX
				cQuery += " FROM "+RetSqlName("SF2")+" SF2 "
				cQuery += "WHERE "
				cQuery += "SF2.F2_FILIAL = '"+xFilial("SF2")+"' AND "
				If .Not. Empty(cTransp)
					cQuery += "SF2.F2_TRANSP in ("+cTransp+") AND "
				Else
					//cQuery += "SF2.F2_TRANSP = '"+cTransp+"' AND "
				EndIF
				cQuery += "SF2.D_E_L_E_T_=' ' "
				cQuery += "ORDER BY "+SqlOrder(SF2->(IndexKey()))

				cQuery := ChangeQuery(cQuery)

				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF2,.T.,.T.)

				For nX := 1 To Len(aStruSF2)
					If aStruSF2[nX][2] <> "C" .And. FieldPos(aStruSF2[nX][1])<>0
						TcSetField(cAliasSF2,aStruSF2[nX][1],aStruSF2[nX][2],aStruSF2[nX][3],aStruSF2[nX][4])
					EndIf
				Next nX
			#ELSE
				MsSeek(xFilial("SF2")+cTransp,.F.)
			#ENDIF
			While !Eof() .And. (cAliasSF2)->F2_FILIAL = xFilial("SF2")
					RecLock(cAliasTRB,.T.)
					For nX := 1 To Len(aStruTRB)
						If (cAliasSF2)->(FieldPos(aStruTRB[nX][1]))<>0
							(cAliasTRB)->(FieldPut(nX,(cAliasSF2)->(FieldGet(FieldPos(aStruTRB[nX][1])))))
						EndIf
					Next nX
					(cAliasTRB)->F2_ALI_WT := "SF2"
					MsUnLock()
				dbSelectArea(cAliasSF2)
				dbSkip()
			EndDo
			If lQuery
				dbSelectArea(cAliasSF2)
				dbCloseArea()
				dbSelectArea("SF2")
			EndIf

	If (cAliasTRB)->(LastRec())<>0
		PRIVATE aHeader := aHeadTRB
		xPesq := aPesq[(cAliasTRB)->(IndexOrd())][1]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona registros                                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SA4")
		dbSetOrder(1)
		MsSeek(xFilial("SA4")+Substr(cTransp,2,6))

		dbSelectArea(cAliasTRB)
		dbGotop()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula as coordenadas da interface                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Interface com o usuario                                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DEFINE MSDIALOG oDlg TITLE OemToAnsi("Notas Fiscais de Origem") FROM aSize[7],000 TO aSize[6],aSize[5] OF oMainWnd PIXEL
		@ aPosObj[1,1],aPosObj[1,2] MSPANEL oPanel PROMPT "" SIZE aPosObj[1,3],aPosObj[1,4] OF oDlg CENTERED LOWERED
		cTexto1 := AllTrim(RetTitle("F2_TRANSP"))+": "+SA4->A4_COD+"  -  "+RetTitle("A4_NOME")+": "+SA4->A4_NOME
		@ 002,005 SAY cTexto1 SIZE aPosObj[1,3],008 OF oPanel PIXEL
		cTexto2 := ""
		@ 012,005 SAY cTexto2 SIZE aPosObj[1,3],008 OF oPanel PIXEL	
		
		@ aPosObj[3,1]+00,aPosObj[3,2]+00 SAY OemToAnsi("Pesquisar por:") PIXEL //Pesquisar por:
		@ aPosObj[3,1]+12,aPosObj[3,2]+00 SAY OemToAnsi("Localizar") PIXEL //Localizar
		@ aPosObj[3,1]+00,aPosObj[3,2]+40 MSCOMBOBOX oCombo VAR cCombo ITEMS aOrdem SIZE 100,044 OF oDlg PIXEL ;
		VALID ((cAliasTRB)->(dbSetOrder(oCombo:nAt)),(cAliasTRB)->(dbGotop()),xPesq := aPesq[(cAliasTRB)->(IndexOrd())][1],.T.)
	  	@ aPosObj[3,1]+12,aPosObj[3,2]+40 MSGET oGet VAR xPesq Of oDlg PICTURE aPesq[(cAliasTRB)->(IndexOrd())][2] PIXEL ;
	  	VALID ((cAliasTRB)->(MsSeek(Iif(ValType(xPesq)=="C",AllTrim(xPesq),xPesq),.T.)),.T.).And.IIf(oGetDb:oBrowse:Refresh()==Nil,.T.,.T.)

	  	oGetDb := MsGetDB():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],1,"Allwaystrue","allwaystrue","",.F., , ,.F., ,cAliasTRB)

		DEFINE SBUTTON FROM aPosObj[3,1]+000,aPosObj[3,4]-030 TYPE 1 ACTION (nOpcA := 1,oDlg:End()) ENABLE OF oDlg
		DEFINE SBUTTON FROM aPosObj[3,1]+012,aPosObj[3,4]-030 TYPE 2 ACTION (nOpcA := 0,oDlg:End()) ENABLE OF oDlg
		ACTIVATE MSDIALOG oDlg CENTERED

		If nOpcA == 1
			lRetorno := .T.
			aHeader   := aClone(aSavHead)
 			nPNfOri   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_NFORI"})
 			nPSerOri  := aScan(aHeader,{|x| AllTrim(x[2])=="D1_SERIORI"})

 			If nPNfOri <> 0
 				aCols[N][nPNfOri] := (cAliasTRB)->F2_DOC
 			EndIf
 			If nPSerOri <> 0
 				aCols[N][nPSerOri] := (cAliasTRB)->F2_SERIE
 			EndIf
			&(cReadVar) := (cAliasTRB)->F2_DOC
		EndIf
	Else
		U_MyAviso("Atenção","Não existes Notas Emitidas com esta Transportadora!"+CRLF +"Transportadora :"+cTransp,{"OK"},3)
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura a integridade da rotina                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea(cAliasTRB)
	dbCloseArea()
EndIf
dbSelectArea("SA1")

RestArea(aAreaSF2)
RestArea(aAreaSF1)
RestArea(aArea)
SetFocus(nHdl)
Return(lRetorno)



//F7 para CTE Notas Fiscais de Origem - Hf - FGVTN
//lNfOri -> vindo como private, se .T. pesquisar SF3, como .F. pesquisar na SF2.
User Function XMLNFOF7()
//Local bSavKeyF4 := SetKey(VK_F4,Nil)
//Local bSavKeyF5 := SetKey(VK_F5,Nil)
//Local bSavKeyF6 := SetKey(VK_F6,Nil)
//Local bSavKeyF7 := SetKey(VK_F7,Nil)
//Local bSavKeyF8 := SetKey(VK_F8,Nil)
//Local bSavKeyF9 := SetKey(VK_F9,Nil)
//Local bSavKeyF10:= SetKey(VK_F10,Nil)
//Local bSavKeyF11:= SetKey(VK_F11,Nil)
Local lContinua := .T.
Local cTransp   := ""  //para SQL in ('','')
Local aAreaSA4  := SA4->( GetArea() )
Local aAreaSA2  := SA2->( GetArea() )
Local cFilSeek  := "" //Iif(U_IsShared("SA2"),xFilial("SA2"),ZBZ->ZBZ_FILIAL) //para lNfOri
Local cFilSa4   := "" //Iif(U_IsShared("SA4"),xFilial("SA4"),ZBZ->ZBZ_FILIAL) //para .NOT. lNfOri
Local cCnpj     := Space(14)	//para lNfOri
Local oDlgKey					//para lNfOri
Private cCnpjTr := &(cTagDocEmit)         //Hf - FGVTN
Private xZBZ  	  := GetNewPar("XM_TABXML","ZBZ")      //ECOOOOOOOOOO
Private xZBZ_ 	  := iif(Substr(xZBZ,1,1)=="S", Substr(xZBZ,2,2), Substr(xZBZ,1,3)) + "_"
Private xZBE      := GetNewPar("XM_TABEVEN","ZBE")
Private xZBE_     := iif(Substr(xZBE,1,1)=="S", Substr(xZBE,2,2), Substr(xZBE,1,3)) + "_"
cFilSeek  := Iif(U_IsShared("SA2"),xFilial("SA2"),(xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))) ) //para lNfOri
cFilSa4   := Iif(U_IsShared("SA4"),xFilial("SA4"),(xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))) ) //para .NOT. lNfOri

if .Not. Empty( cCnpRem )
	cCnpj := cCnpRem
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impede de executar a rotina quando a tecla F3 estiver ativa		    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("InConPad") == "L"
	lContinua := !InConPad
EndIf

If lNfOri
	//Pede CNPJ do SA2
	DEFINE MSDIALOG oDlgKey TITLE "Consulta CNPJ" FROM 0,0 TO 150,305 PIXEL OF GetWndDefault()

	@ 12,008 SAY "CNPJ para Consultar [F3]-Pesquisa" PIXEL OF oDlgKey
	@ 20,008 MSGET cCnpj PICTURE PesqPict("SA2","A2_CGC") SIZE 140,10 F3 "SA2XCG" PIXEL OF oDlgKey

	@ 46,035 BUTTON oBtnCon PROMPT "&Ok" SIZE 38,11 PIXEL ACTION if(ChkCnpjSa2(cCnpj), (lContinua:=.T.,oDlgKey:End()), lContinua:=.F. )
	@ 46,077 BUTTON oBtnOut PROMPT "&Sair" SIZE 38,11 PIXEL ACTION (lContinua:=.F.,oDlgKey:End())

	ACTIVATE DIALOG oDlgKey CENTERED

	If lContinua
		dbSelectArea( "SA2" )
		dbsetorder( 3 )
		if SA2->( DbSeek( cFilSeek + cCnpj ) )
			Do While .Not. SA2->( Eof() ) .and. cFilSeek == SA2->A2_FILIAL .and. SA2->A2_CGC == cCnpj
				If .Not. Empty( cTransp )
					cTransp += ","
				endIf
				cTransp += "'"+SA2->A2_COD+SA2->A2_LOJA+"'"
				SA2->( dbSkip() )
			EndDo
			cCnpRem := cCnpj   //vindo como private, para fazer pesquisa despois. Itambé
		else
			lContinua := .F.
		endif
	EndIf
Else
	dbSelectArea( "SA4" )
	dbsetorder( 3 )
	If dbSeek( cFilSa4 + cCnpjTr )
		Do While .Not. SA4->( Eof() ) .and. cFilSa4 == SA4->A4_FILIAL .and. SA4->A4_CGC == cCnpjTr
			If .Not. Empty( cTransp )
				cTransp += ","
			endIf
			cTransp += "'"+SA4->A4_COD+"'"
			SA4->( dbSkip() )
		EndDo
	Else
		U_MyAviso("Atenção","Não Existem Transportadoras Cadastradas para o CNPJ "+Transform(cCnpjTr, "@R 99.999.999/9999-99"),{"OK"},3)
		lContinua := .F.
	EndIF
EndIf

If lContinua

	If lNfOri
		U_Sf3NfOri("M->D1_NFORI",cTransp)
	Else
		U_CteNfOri("M->D1_NFORI",cTransp)
	EndIf

Endif

//SetKey(VK_F4,bSavKeyF4)
//SetKey(VK_F5,bSavKeyF5)
//SetKey(VK_F6,bSavKeyF6)
//SetKey(VK_F7,bSavKeyF7)
//SetKey(VK_F8,bSavKeyF8)
//SetKey(VK_F9,bSavKeyF9)
//SetKey(VK_F10,bSavKeyF10)
//SetKey(VK_F11,bSavKeyF11)

// Atualiza valores na tela
Eval(bRefresh)
RestArea(aAreaSA4)
RestArea(aAreaSA2)
Return .T.



Static Function ChkCnpjSa2(cCnpj)
Local lRet      := .T.
Local aArea     := GetArea()
Local cFilSeek  := "" //Iif(U_IsShared("SA2"),xFilial("SA2"),ZBZ->ZBZ_FILIAL)
Private xZBZ  	  := GetNewPar("XM_TABXML","ZBZ")      //ECOOOOOOOOOO
Private xZBZ_ 	  := iif(Substr(xZBZ,1,1)=="S", Substr(xZBZ,2,2), Substr(xZBZ,1,3)) + "_"
Private xZBE      := GetNewPar("XM_TABEVEN","ZBE")
Private xZBE_     := iif(Substr(xZBE,1,1)=="S", Substr(xZBE,2,2), Substr(xZBE,1,3)) + "_"
cFilSeek  := Iif(U_IsShared("SA2"),xFilial("SA2"),(xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))))

SA2->( dbSetOrder( 3 ) )
If Empty(cCnpj) .Or. .Not. SA2->( DbSeek( cFilSeek + cCnpj ) )
	U_MyAviso("Atenção","CNPJ "+Transform(cCnpj, "@R 99.999.999/9999-99")+" não cadastrado.",{"OK"},3)
	lRet := .F.
EndIf

RestArea(aArea)
Return( lRet )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A103EstDCF³ Prog. ³Fernando Joly Siquini  ³Data  ³06.09.2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Efetua o estorno dos registros do DCF (Servico WMS).        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A103EstDCF()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MATA103                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function HFEstDCF(lEstorna)
Local aAreaAnt   := GetArea()
Local cSeekDCF   := ''
Local lRet       := .T.

Default lEstorna := .F.

If !Empty(SD1->D1_SERVIC) .And. (SuperGetMV('MV_INTDL')=='S')
	DbSelectArea('DCF')
	DbSetOrder(2) //-- FILIAL+SERVIC+DOCTO+SERIE+CLIFOR+LOJA+CODPRO
	If MsSeek(cSeekDCF:=xFilial('DCF')+SD1->D1_SERVIC+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_COD, .F.)
		Do While !Eof() .And. cSeekDCF==DCF_FILIAL+DCF_SERVIC+DCF_DOCTO+DCF_SERIE+DCF_CLIFOR+DCF_LOJA+DCF_CODPRO
			If DCF->DCF_NUMSEQ==SD1->D1_NUMSEQ
				If DCF_STSERV<>'1' .And. lEstorna
					DLA220Esto(.F.)
				EndIf
				If DCF_STSERV=='1'
					RecLock('DCF',.F.,.T.)
					dbDelete()
					MsUnlock()
				EndIf
			EndIf
			DCF->(dbSkip())
		EndDo
	EndIf
	RestArea(aAreaAnt)
EndIf

Return lRet



//NFCE_02 07/03 Rotinas feitas para importar NF Serviços Eletronica. A Começar Importar TXT de SP.
USer Function LerFRead( cFile )
Local cRet := ""
Local nHandle := 0
Local cBuf := space(1200)
//Local nPointer := 0
//Local nLido := 0
//Local nEof := 0
//Local cEol := Chr( 13 ) + Chr( 10 )


Handle := FT_FUse( cFile )

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

return cRet



Static Function __Dummy(lRecursa) //warning W0010 Static Function <?> never called
    lRecursa := .F.
    IF (lRecursa)
        __Dummy(.F.)
        U_ISSHARED()
        U_GETIDENT()
        U_XMLINFOX()
        U_XMLPCF5()
        U_HFSTATSEF()
        U_XMLDEBUG()
        U_XCONSXML()
        U_XCFGMAIL()
        U_TTT()
        U_SF3NFORI()
        U_MYAVISO()
        U_VERTSS()
        U_GETVERIX()
        U_MAILSEND()
        U_HFESTDCF()
        U_MA140LOK()
        U_MA140GRV()
        U_MA140TOK()
        U_XMATA140()
        U_XMLNFOF7()
        U_XMLPCF6()
        U_A140NFIS()
        U_CTENFORI()
	EndIF
Return(lRecursa)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Descri‡…o ³Cria uma pergunta usando rotina padrao                      ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//FR - 27/09/19 - inserido neste fonte de funções genéricas por Flávia Rocha
USer Function HFPutSx1(cGrupo,cOrdem,cPergunt,cPerSpa,cPerEng,cVar,;
	cTipo ,nTamanho,nDecimal,nPresel,cGSC,cValid,;
	cF3, cGrpSxg,cPyme,;
	cVar01,cDef01,cDefSpa1,cDefEng1,cCnt01,;
	cDef02,cDefSpa2,cDefEng2,;
	cDef03,cDefSpa3,cDefEng3,;
	cDef04,cDefSpa4,cDefEng4,;
	cDef05,cDefSpa5,cDefEng5,;
	aHelpPor,aHelpEng,aHelpSpa,cHelp)

LOCAL aArea := GetArea()
Local cKey
Local lPort := .f.
Local lSpa  := .f.
Local lIngl := .f. 
Local lTama := .f.

//If GetVersao(.F.) < "12"

	cKey  := "P." + AllTrim( cGrupo ) + AllTrim( cOrdem ) + "."
	
	cPyme    := Iif( cPyme 		== Nil, " ", cPyme		)
	cF3      := Iif( cF3 		== NIl, " ", cF3		)
	cGrpSxg  := Iif( cGrpSxg	== Nil, " ", cGrpSxg	)
	cCnt01   := Iif( cCnt01		== Nil, "" , cCnt01 	)
	cHelp	 := Iif( cHelp		== Nil, "" , cHelp		)
	
	dbSelectArea( "SX1" )
	dbSetOrder( 1 )
	
	// Ajusta o tamanho do grupo. Ajuste emergencial para validação dos fontes.
	// RFC - 15/03/2007
	cGrupo := PadR( cGrupo , Len( SX1->X1_GRUPO ) , " " )
	
	If !( DbSeek( cGrupo + cOrdem ))
	
	    cPergunt:= If(! "?" $ cPergunt .And. ! Empty(cPergunt),Alltrim(cPergunt)+" ?",cPergunt)
		cPerSpa	:= If(! "?" $ cPerSpa  .And. ! Empty(cPerSpa) ,Alltrim(cPerSpa) +" ?",cPerSpa)
		cPerEng	:= If(! "?" $ cPerEng  .And. ! Empty(cPerEng) ,Alltrim(cPerEng) +" ?",cPerEng)
	
		Reclock( "SX1" , .T. )
	
		Replace X1_GRUPO   With cGrupo
		Replace X1_ORDEM   With cOrdem
		Replace X1_PERGUNT With cPergunt
		Replace X1_PERSPA  With cPerSpa
		Replace X1_PERENG  With cPerEng
		Replace X1_VARIAVL With cVar
		Replace X1_TIPO    With cTipo
		Replace X1_TAMANHO With nTamanho
		Replace X1_DECIMAL With nDecimal
		Replace X1_PRESEL  With nPresel
		Replace X1_GSC     With cGSC
		Replace X1_VALID   With cValid
	
		Replace X1_VAR01   With cVar01
	
		Replace X1_F3      With cF3
		Replace X1_GRPSXG  With cGrpSxg
	
		If Fieldpos("X1_PYME") > 0
			If cPyme != Nil
				Replace X1_PYME With cPyme
			Endif
		Endif
	
		Replace X1_CNT01   With cCnt01
		If cGSC == "C"			// Mult Escolha
			Replace X1_DEF01   With cDef01
			Replace X1_DEFSPA1 With cDefSpa1
			Replace X1_DEFENG1 With cDefEng1
	
			Replace X1_DEF02   With cDef02
			Replace X1_DEFSPA2 With cDefSpa2
			Replace X1_DEFENG2 With cDefEng2
	
			Replace X1_DEF03   With cDef03
			Replace X1_DEFSPA3 With cDefSpa3
			Replace X1_DEFENG3 With cDefEng3
	
			Replace X1_DEF04   With cDef04
			Replace X1_DEFSPA4 With cDefSpa4
			Replace X1_DEFENG4 With cDefEng4
	
			Replace X1_DEF05   With cDef05
			Replace X1_DEFSPA5 With cDefSpa5
			Replace X1_DEFENG5 With cDefEng5
		Endif
	
		Replace X1_HELP  With cHelp
	
		HFSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)
	
		MsUnlock()
	Else
	
	   lPort := ! "?" $ X1_PERGUNT .And. ! Empty(SX1->X1_PERGUNT)
	   lSpa  := ! "?" $ X1_PERSPA  .And. ! Empty(SX1->X1_PERSPA)
	   lIngl := ! "?" $ X1_PERENG  .And. ! Empty(SX1->X1_PERENG)
	   lTama := (SX1->X1_TAMANHO <> nTamanho)

	   If lPort .Or. lSpa .Or. lIngl .Or. lTama
			RecLock("SX1",.F.)
			If lPort 
	         SX1->X1_PERGUNT:= Alltrim(SX1->X1_PERGUNT)+" ?"
			EndIf
			If lSpa 
				SX1->X1_PERSPA := Alltrim(SX1->X1_PERSPA) +" ?"
			EndIf
			If lIngl
				SX1->X1_PERENG := Alltrim(SX1->X1_PERENG) +" ?"
			EndIf
			if lTama
				SX1->X1_TAMANHO := nTamanho
			endif
			SX1->(MsUnLock())
		EndIf
	Endif
	
	RestArea( aArea )
//Endif	
Return


Static Function HFSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa,lUpdate,cStatus)
Local cFilePor := "SIGAHLP.HLP"
Local cFileEng := "SIGAHLE.HLE"
Local cFileSpa := "SIGAHLS.HLS"
Local nRet
Local nT
Local nI
Local cLast
Local cNewMemo
Local cAlterPath := ''
Local nPos	

If ( ExistBlock('HLPALTERPATH') )
	cAlterPath := Upper(AllTrim(ExecBlock('HLPALTERPATH', .F., .F.)))
	If ( ValType(cAlterPath) != 'C' )
        cAlterPath := ''
	ElseIf ( (nPos:=Rat('\', cAlterPath)) == 1 )
		cAlterPath += '\'
	ElseIf ( nPos == 0	)
		cAlterPath := '\' + cAlterPath + '\'
	EndIf
	
	cFilePor := cAlterPath + cFilePor
	cFileEng := cAlterPath + cFileEng
	cFileSpa := cAlterPath + cFileSpa
	
EndIf

Default aHelpPor := {}
Default aHelpEng := {}
Default aHelpSpa := {}
Default lUpdate  := .T.
Default cStatus  := ""

If Empty(cKey)
	Return
EndIf

If !(cStatus $ "USER|MODIFIED|TEMPLATE")
	cStatus := NIL
EndIf

cLast 	 := ""
cNewMemo := ""

nT := Len(aHelpPor)

For nI:= 1 to nT
   cLast := Padr(aHelpPor[nI],40)
   If nI == nT
      cLast := RTrim(cLast)
   EndIf
   cNewMemo+= cLast
Next

If !Empty(cNewMemo)
	nRet := SPF_SEEK( cFilePor, cKey, 1 )
	If nRet < 0
		SPF_INSERT( cFilePor, cKey, cStatus,, cNewMemo )
	Else
		If lUpdate
			SPF_UPDATE( cFilePor, nRet, cKey, cStatus,, cNewMemo )
		EndIf
	EndIf
EndIf

cLast 	 := ""
cNewMemo := ""

nT := Len(aHelpEng)

For nI:= 1 to nT
   cLast := Padr(aHelpEng[nI],40)
   If nI == nT
      cLast := RTrim(cLast)
   EndIf
   cNewMemo+= cLast
Next

If !Empty(cNewMemo)
	nRet := SPF_SEEK( cFileEng, cKey, 1 )
	If nRet < 0
		SPF_INSERT( cFileEng, cKey, cStatus,, cNewMemo )
	Else
		If lUpdate
			SPF_UPDATE( cFileEng, nRet, cKey, cStatus,, cNewMemo )
		EndIf
	EndIf
EndIf

cLast 	 := ""
cNewMemo := ""

nT := Len(aHelpSpa)

For nI:= 1 to nT
   cLast := Padr(aHelpSpa[nI],40)
   If nI == nT
      cLast := RTrim(cLast)
   EndIf
   cNewMemo+= cLast
Next

If !Empty(cNewMemo)
	nRet := SPF_SEEK( cFileSpa, cKey, 1 )
	If nRet < 0
		SPF_INSERT( cFileSpa, cKey, cStatus,, cNewMemo )
	Else
		If lUpdate
			SPF_UPDATE( cFileSpa, nRet, cKey, cStatus,, cNewMemo )
		EndIf
	EndIf
EndIf
Return

//FR - Incluída por Flávia Rocha - Função genérica para cálculo de Tela:
//+-----------------------------------------------------------------------------------//
//|Funcao....: U_FRTela(oBjet,cTipo)
//|Parametros: oBjet = Objeto a ser dimencionado
//|            cTipo = Tipo de posicionamento
//|            			"UP"   = Posiciona na parte de cima da Dialog
//|            			"DOWN" = Posiciona na parte de baixo da Dialog
//|            			"TOT"  = Posiciona em toda Dialog
//|
//|Autoria...: Flávia Rocha
//|Data......: 26/08/2015
//|Descricao.: Função para posicionar todo o objeto na Dialog
//|Observação: 
//+-----------------------------------------------------------------------------------//
*-----------------------------------------------------------*
User Function FRTela(oBjet,cTipo,xVerMDI)
*-----------------------------------------------------------* 

Local aPosicao := {}

Do Case
	Case cTipo = "TOT"
		aPosicao    := {1,1,(oBjet:nClientHeight-6)/2,(oBjet:nClientWidth-4)/2}
		If Empty(xVerMDI)
			aPosicao[3] -= Iif(SetMdiChild(),14,0)
		EndIf
		
	Case cTipo = "UP"
		aPosicao:= {1,1,(oBjet:nClientHeight-6)/4-1,(oBjet:nClientWidth-4)/2}
		//Versão MDI
		If Empty(xVerMDI)
			If SetMdiChild()
				aPosicao[3] += 4
				aPosicao[4] += 3
			EndIf
		EndIf
		
	Case cTipo = "DOWN"
		aPosicao:= {(oBjet:nClientHeight-6)/4+1,1,(oBjet:nClientHeight-6)/4-2,(oBjet:nClientWidth-4)/2}
		//Versão MDI
		If Empty(xVerMDI)
			aPosicao[3] -= Iif(SetMdiChild(),14,0)			
		EndIf

End Case

Return(aPosicao)
//-------------------------------------------------------------//
// TRATATIVA PARA TELA DE DIVERGÊNCIAS
// Monta os arrays a serem utilizados para checagem de
// Divergências, pode ser chamada de qq fonte, apenas passando
// por parâmetro os arrays abaixo
//-------------------------------------------------------------//
//FR - 14/05/2020
*****************************************
User Function fMontaArray(aCabec,aItens,aCabNFE,aIteNFE)
***************************************** 
//Local aRetorno := {}
Local nX       := 0
Local cItem		:= ""
Local cProduto	:= ""
Local nQuant  	:= 0
Local cUM		:= ""
Local cTES		:= ""
Local cCF		:= ""
Local nPreco  	:= 0
Local nTotal  	:= 0
Local nTNF		:= 0
Local nTotal 	:= 0 
Local nBaseipi	:= 0 
Local nValipi	:= 0 
Local nBaseicm	:= 0 
Local nValicm	:= 0 
Local nBasepis 	:= 0 
Local nValpis	:= 0 
Local nPis		:= 0 
Local nBasecof	:= 0 
Local nValcof	:= 0 
Local nBaseir	:= 0 
Local nValir	:= 0
Local nValmerc	:= 0 
Local nTBaseipi := 0
Local nTValipi 	:= 0
Local nTBaseicm := 0
Local nTValicm 	:= 0
Local nTBasepis	:= 0
Local nTValpis	:= 0
Local nTBasecof	:= 0
Local nTValcof	:= 0
Local nTBaseir	:= 0
Local nTValir	:= 0
Local aCposI    := {}
Local aCposC	:= {}
Local cNcm		:= "" //FR - 19/06/2020 - TÓPICOS RAFAEL
Local y         := 0

If Len(aCabec) > 0
	For y := 1 to Len(aItens)
		For nx := 1 to Len(aItens[y])
			Aadd( aCposI , aItens[y][nx][1] ) //1-D1_ITEM, 2-D1_COD, 3-D1_UM ... //Aadd( aIts , { aItens[y][nx][1] , aItens[y][nx][2]} )
		Next nx 
	Next y  
	
	For y := 1 to Len(aCabec)
		Aadd( aCposC , aCabec[y][1] ) 
	Next y

	For y := 1 to Len(aItens) 
		cItem		:= aItens[y][ aScan( aCposI, "D1_ITEM" )   ][2]   //aIts[nx][aScan( aIts, {|x| alltrim(x[1]) == "D1_ITEM" })+1]  //aItens[y][nx][ aScan( aItens[y][nx], "D1_ITEM" ) +1 ] //aItens[y][nx][ aScan( aItens, {|x| alltrim(x[1]) == "D1_ITEM"}) ]
		cProduto	:= aItens[y][ aScan( aCposI, "D1_COD" )    ][2]  //aIts[nx][aScan( aIts, {|x| alltrim(x[1]) == "D1_COD"  })+1] //aItens[y][nx]//aCols[nx][ aScan( aHeader, {|x| alltrim(x[2]) == "D1_COD" 	}) ]
		cUM			:= ""
		If aScan( aCposI, "D1_UM" )> 0 
			cUM      	:= aItens[y][ aScan( aCposI, "D1_UM" )     ][2]  //aIts[nx][aScan( aIts, {|x| alltrim(x[1]) == "D1_QUANT"})+1] //aCols[nx][ aScan( aHeader, {|x| alltrim(x[2]) == "D1_QUANT" 	}) ] 
		Endif
		nQuant     	:= aItens[y][ aScan( aCposI, "D1_QUANT" )  ][2] 
		cTES 		:= ""
		If aScan( aCposI, "D1_TES" )> 0 
			cTES	:= aItens[y][ aScan( aCposI, "D1_TES" )    ][2] 
		Endif
		
		cCF			:= "" 
		If aScan( aCposI, "D1_CF" )> 0 
			cCF		:= aItens[y][ aScan( aCposI, "D1_CF" )  ][2] 
		Endif
		
		cNcm		:= "" 	//FR - 19/06/2020 - TÓPICOS RAFAEL
		If aScan( aCposI, "D1_TEC" )> 0 
			cCF		:= aItens[y][ aScan( aCposI, "D1_TEC" )  ][2] 
		Endif				//FR - 19/06/2020 - TÓPICOS RAFAEL
		
		nPreco		:= aItens[y][ aScan( aCposI, "D1_VUNIT" )  ][2] 
		nTotal  	:= aItens[y][ aScan( aCposI, "D1_TOTAL" )  ][2]
		nBaseipi    := 0
		If aScan( aCposI, "D1_BASEIPI" )> 0  
			nBaseipi	:= aItens[y][ aScan( aCposI, "D1_BASEIPI" )][2]  
		Endif
		nValipi     := 0
		If aScan( aCposI, "D1_VALIPI" )> 0
			nValipi 	:= aItens[y][ aScan( aCposI, "D1_VALIPI" ) ][2]	
		Endif
		nIpi		:= 0
		If aScan( aCposI, "D1_IPI" )> 0
			nIpi    	:= aItens[y][ aScan( aCposI, "D1_IPI" )    ][2]  
		Endif
		nBaseicm	:= 0
		If aScan( aCposI, "D1_BASEICM" )> 0
			nBaseicm	:= aItens[y][ aScan( aCposI, "D1_BASEICM" )][2]  
		Endif
		nValicm		:= 0
		If aScan( aCposI, "D1_VALICM" )> 0
			nValicm 	:= aItens[y][ aScan( aCposI, "D1_VALICM" ) ][2]
		Endif
		nIcm		:= 0
		If aScan( aCposI, "D1_PICM" )> 0  
			nIcm		:= aItens[y][ aScan( aCposI, "D1_PICM" )   ][2] 
		Endif
		nBasepis    := 0
		If aScan( aCposI, "D1_BASEPIS" )>0 
			nBasepis	:= aItens[y][ aScan( aCposI, "D1_BASEPIS" )][2]  
		Endif
		nValpis     := 0
		If aScan( aCposI, "D1_VALPIS" ) > 0
			nValpis 	:= aItens[y][ aScan( aCposI, "D1_VALPIS" )][2]   
		Endif
		nPis        := 0
		If aScan( aCposI, "D1_ALQPIS" ) > 0
			nPis   		:= aItens[y][ aScan( aCposI, "D1_ALQPIS" )][2]  
		Endif
		nBasecof    := 0
		If aScan( aCposI, "D1_BASECOF" ) > 0
			nBasecof	:= aItens[y][ aScan( aCposI, "D1_BASECOF" )][2]  
		Endif
		nValcof     := 0
		If aScan( aCposI, "D1_VALCOF" ) > 0
			nValcof 	:= aItens[y][ aScan( aCposI, "D1_VALCOF" )][2]  
		Endif
		nCof        := 0
		If aScan( aCposI, "D1_ALQCOF" ) > 0
			nCof    	:= aItens[y][ aScan( aCposI, "D1_ALQCOF" )][2]  
		Endif
		nBaseir     := 0  
		If aScan( aCposI, "D1_BASEIRR" ) > 0
			nBaseir 	:= aItens[y][ aScan( aCposI, "D1_BASEIRR" )][2]   
		Endif
		nValir 		:= 0
		If aScan( aCposI, "D1_VALIRR" ) > 0
			nValir  	:= aItens[y][ aScan( aCposI, "D1_VALIRR" )][2]  
		Endif
		nIr			:= 0
		If aScan( aCposI, "D1_ALIQIRR" ) > 0
			nIr			:= aItens[y][ aScan( aCposI, "D1_ALIQIRR" )][2]
		Endif
		
	    nValmerc	+= nTotal 
	    nTBaseipi 	+= nBaseipi
	    nTValipi 	+= nValipi
	    nTBaseicm 	+= nBaseicm
	    nTValicm 	+= nValicm
	    nTBasepis	+= nBasepis 
	    nTValpis	+= nValpis
	    nTBasecof	+= nBasecof
	    nTValcof	+= nValcof
	    nTBaseir	+= nBaseir
	    nTValir		+= nValir	
		   		    		    		  
		Aadd( aIteNFE, { cItem	,; 		//01
					 cProduto	,; 		//02
					 nQuant		,;   	//03
					 cUM		,;	 	//04
					 cTES		,; 	 	//05	
					 cCF 		,;		//06	
					 nPreco		,;  	//07	
					 nTotal  	,;  	//08
					 nBaseipi	,;  	//09
					 nValipi 	,;  	//10
					 nIpi    	,;  	//11
					 nBaseicm	,;	 	//12
					 nValicm 	,; 		//13	 
					 nIcm 	 	,;	   	//14	
					 nBasepis	,;	 	//15
					 nValpis 	,;	 	//16
					 nPis 		,;	 	//17
					 nBasecof	,;	 	//18
					 nValcof 	,;	 	//19
					 nCof   	,; 	 	//20
					 nBaseir 	,;	 	//21
					 nValir 	,; 	 	//22
					 nIr		,;		//23
					 cNcm		;		//24 - ncm 	//FR - 19/06/2020 - TÓPICOS RAFAEL 					 
					   } )   //Armazena no array de itens da NF, para comparar com o xml
	Next
	//FR
	nTNF := 0
	//nTNF := U_UMaFisRet(,"NF_TOTAL") //nValmerc  //MaFisRet(,"NF_TOTAL")
	nTNF := nValmerc  
	///dados da nf	
	cNFiscal	:= aCabec[ aScan( aCposC, "F1_DOC" )   ][2]
	cSerie		:= aCabec[ aScan( aCposC, "F1_SERIE" ) ][2]
	dDEmissao	:= aCabec[ aScan( aCposC, "F1_EMISSAO")][2]
	cA100For 	:= aCabec[ aScan( aCposC, "F1_FORNECE")][2]
	cLoja	   	:= aCabec[ aScan( aCposC, "F1_LOJA")   ][2]
	cEspecie   	:= aCabec[ aScan( aCposC, "F1_ESPECIE")][2]
	cTipo	   	:= aCabec[ aScan( aCposC, "F1_TIPO")   ][2]
	//nValmerc	:= 
	//nTNF	        ,;      //MaFisRet(,"NF_TOTAL")  //a140Total[TOTPED]	;		//09-SF1->F1_VALBRUT
	//nTBaseicm		,;	//10-SF1->F1_BASEICM
	//nTValicm		,;	//11-SF1->F1_VALICM
	//nTBaseipi		,;	//12-SF1->F1_BASEIPI
	//nTValipi		,;	//13-SF1->F1_VALIPI
	//nTBasepis		,;	//14-SF1->F1_BASEPIS
	//nTValpis	   	,;	//15-SF1->F1_VALPIS
	//nTBasecof  		,;	//16-SF1->F1_BASCOFI
	//nTValcof   		,;	//17-SF1->F1_VALCOFI
	//nTBaseir		,;	//18-SF1->F1_(BASEIR) ?
	//nTValir			;	//19-SF1->F1_VALIRF			
	
	Aadd( aCabNFE, {cNFiscal   		,;		//01-SF1->F1_DOC
					cSerie			,;		//02-SF1->F1_SERIE
					dDEmissao		,;		//03-SF1->F1_EMISSAO
					cA100For   		,;		//04-SF1->F1_FORNECE
					cLoja	   		,;		//05-SF1->F1_LOJA
					cEspecie   		,;		//06-SF1->F1_ESPECIE
					cTipo	   		,;		//07-SF1->F1_TIPO
					nValmerc		,; 		//a140Total[VALMERC]	,;	//08-SF1->F1_VALMERC
					nTNF	        ,;      //MaFisRet(,"NF_TOTAL")  //a140Total[TOTPED]	;		//09-SF1->F1_VALBRUT
					nTBaseicm		,;	//10-SF1->F1_BASEICM
					nTValicm		,;	//11-SF1->F1_VALICM
					nTBaseipi		,;	//12-SF1->F1_BASEIPI
					nTValipi		,;	//13-SF1->F1_VALIPI
					nTBasepis		,;	//14-SF1->F1_BASEPIS
					nTValpis	   	,;	//15-SF1->F1_VALPIS
					nTBasecof  		,;	//16-SF1->F1_BASCOFI
					nTValcof   		,;	//17-SF1->F1_VALCOFI
					nTBaseir		,;	//18-SF1->F1_(BASEIR) ?
					nTValir			;	//19-SF1->F1_VALIRF			
				})
			
Endif //Len(aCabec) > 0
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ fCALCTELA  ºAutor  ³ Flávia Rocha     º Data ³  12/06/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Calcula as dimensões da tela de acordo com a resolução     º±±
±±º          ³ Para aplicar as medidas na dialog a ser construída         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function fCALCTELA(aSize,aPos)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Retorna area de trabalho e coordenadas para janela³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aSize := MsAdvSize(.T.) 
	
	// .T. se tera enchoicebar
	* Retorno:
	* 1 Linha inicial area trabalho.
	* 2 Coluna inicial area trabalho.
	* 3 Linha final area trabalho.
	* 4 Coluna final area trabalho.    
	* 5 Coluna final dialog (janela).
	* 6 Linha final dialog (janela).
	* 7 Linha inicial dialog (janela).
	                  
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Contera parametros utilizados para calculo de posicao usadas pelo objetos na tela³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aObjects := {}
	
	AAdd( aObjects, { 0, 95, .T., .F., .F. } ) // Coordenadas para o ENCHOICE
	// largura
	// altura
	// .t. permite alterar largura
	// .t. permite alterar altura
	// .t. retorno: linha, coluna, largura, altur
	//     OU
	// .f. retorno: linha, coluna, linha, coluna
	
	AAdd( aObjects, { 0, 0, .T., .T., .F. } ) // Coordenadas para o MSGETDADOS
	// largura
	// altura
	// .t. permite alterar largura
	// .f. NAO permite alterar altura ***
	// .t. retorno: linha, coluna, largura, altura
	//     OU
	// .f. retorno: linha, coluna, linha, coluna
	
	
	AAdd( aObjects, { 0, 60, .T., .F., .T. } ) // Coordenadas para o FOLDER
	// largura
	// altura
	// .t. permite alterar largura
	// .f. NAO permite alterar altura ***
	// .t. retorno: linha, coluna, largura, altura
	//     OU
	// .f. retorno: linha, coluna, linha, coluna
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Informacoes referente a janela que serao passadas ao MsObjSize³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aInfo := { aSize[1], aSize[2], aSize[3], aSize[4], 3, 3 } 
	// aSize[1] LI 
	// aSize[2] CI 
	// aSize[3] LF 
	// aSize[4] CF 
	// 3        separacao horizontal  
	// 3        separacao vertical
	
	aPos  := MsObjSize( aInfo, aObjects )
	               
	// {  {} , {} , {} } 
	
	// aPos - array bidimensional, cada elemento sera um array com as coordenadas 
	// para cada objeto
	//
	// 1 -> Linha inicial        aObjects[ N , 5 ] ==== .F. 
	// 2 -> Coluna inicial
	// 3 -> Linha final
	// 4 -> Coluna final
	// 
	// ou
	// 
	// 1 -> Linha inicial        aObjects[ N , 5 ] ==== .T. 
	// 2 -> Coluna inicial
	// 3 -> Largura X
	// 4 -> Altura Y

RETURN


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³NfeFldTot ³Autor  ³ Eduardo Riera         ³ Data ³12.09.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de atualizacao do folder de totais                    ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto da Janela que sera disponibilizado os Get      ³±±
±±³          ³ExpA2: Array com os gets de totais                           ³±±
±±³          ³ExpA3: Array com as posicoes dos gets de totais              ³±±
±±³          ³Expb4: Codeblock para atualizaco dos dados do Folder         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo atualizar o folder de totais   ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function NfeFldTot(oDlg,aGets,aPosGet,bRefresh)

Local aObjetos := Array(Len(aGets))

@ 06,aPosGet[1] SAY RetTitle("F1_VALMERC") Of oDlg PIXEL SIZE 55 ,9 //"Valor da Mercadoria"
@ 05,aPosGet[2] MSGET aObjetos[VALMERC] VAR aGets[VALMERC] PICTURE PesqPict('SD1','D1_TOTAL') OF oDlg PIXEL When .F. SIZE 80,09			
@ 06,aPosGet[3] SAY RetTitle("F1_DESCONT") Of oDlg PIXEL SIZE 49 ,9 //"Descontos"
@ 05,aPosGet[4] MSGET aObjetos[VALDESC] VAR aGets[VALDESC]  PICTURE PesqPict('SD1','D1_VALDESC') OF oDlg PIXEL When .F. SIZE 80,09			
If Len(aGets)>3
	@ 20,aPosGet[1] SAY RetTitle("F1_FRETE") Of oDlg PIXEL SIZE 45 ,9 //"Valor do Frete"
	@ 19,aPosGet[2] MSGET aObjetos[FRETE] VAR aGets[FRETE]  PICTURE PesqPict('SD1','D1_TOTAL') OF oDlg PIXEL When .F. SIZE 80,09
	@ 20,aPosGet[3] SAY RetTitle("F1_SEGURO") Of oDlg PIXEL SIZE 50 ,9 //"Vlr. do Seguro"
	@ 19,aPosGet[4] MSGET aObjetos[SEGURO] VAR aGets[SEGURO]  PICTURE PesqPict('SD1','D1_TOTAL') OF oDlg PIXEL When .F. SIZE 80,09	
	@ 34,aPosGet[3] SAY RetTitle("F1_DESPESA") Of oDlg PIXEL SIZE 50 ,9 //"Despesas"
	@ 33,aPosGet[4] MSGET aObjetos[VALDESP] VAR aGets[VALDESP]  PICTURE PesqPict('SD1','D1_TOTAL') OF oDlg PIXEL When .F.  SIZE 80,09
	If GetNewPar("MV_VNAGREG",.F.) .And. cPaisLoc == "BRA"
		If Len(aGets) < 9   
			Aadd(aGets,0)
			Aadd(aObjetos,0)
		Endif
		@ 51,aPosGet[1] SAY "Valor não Agregado" Of oDlg PIXEL SIZE 58 ,9 //"Valor não Agregado"
		@ 49,aPosGet[2] MSGET aObjetos[VNAGREG] VAR aGets[VNAGREG]  PICTURE PesqPict('SF1','F1_VNAGREG') OF oDlg PIXEL When .F. SIZE 80,09
	Endif
EndIf
@ 51,aPosGet[3] SAY RetTitle("F1_VALBRUT") Of oDlg PIXEL SIZE 58 ,9 //"Total do Doc."
@ 49,aPosGet[4] MSGET aObjetos[TOTPED] VAR aGets[TOTPED]  PICTURE PesqPict('SF1','F1_VALBRUT') OF oDlg PIXEL When .F. SIZE 80,09

@ 43,3 TO 46,aPosGet[5] LABEL '' OF oDlg PIXEL

bRefresh := {|| NfeRFldTot(aGets,aObjetos)}       

Return(.T.)
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³NfeRFldTot³Autor  ³ Eduardo Riera         ³ Data ³12.09.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de atualizacao do folder de totais                    ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1: Array com as variaveis dos get de totais              ³±±
±±³          ³ExpA2: Array com os objetos dos get de totais                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo atualizar o folder de totais   ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function NfeRFldTot(aGets,aObjetos)

Local nVlrAnterior := 0

nVlrAnterior := aGets[VALMERC]
aGets[VALMERC] := IIf(MaFisFound(),MaFisRet(,"NF_VALMERC"),aGets[VALMERC])
If nVlrAnterior <> aGets[VALMERC] .Or. !MaFisFound()
	aObjetos[VALMERC]:Refresh()
EndIf
nVlrAnterior := aGets[VALDESC]
aGets[VALDESC] := IIf(MaFisFound(),MaFisRet(,"NF_DESCONTO"),aGets[VALDESC])
If nVlrAnterior <> aGets[VALDESC] .Or. !MaFisFound()
	aObjetos[VALDESC]:Refresh()
EndIf
nVlrAnterior := aGets[TOTPED ]
aGets[TOTPED ] := IIF(MaFisFound(),MaFisRet(,"NF_TOTAL"),aGets[TOTPED ])
If nVlrAnterior <> aGets[TOTPED ] .Or. !MaFisFound()
	aObjetos[TOTPED ]:Refresh()
EndIf
If Len(aGets)>3
	nVlrAnterior := aGets[FRETE  ]
	aGets[FRETE  ] := IIF(MaFisFound(),MaFisRet(,"NF_FRETE"),aGets[FRETE  ])
	If nVlrAnterior <> aGets[FRETE  ] .Or. !MaFisFound()
		aObjetos[FRETE  ]:Refresh()
	EndIf
	nVlrAnterior := aGets[SEGURO ]
	aGets[SEGURO ] := IIF(MaFisFound(),MaFisRet(,"NF_SEGURO"),aGets[SEGURO ])
	If nVlrAnterior <> aGets[SEGURO ] .Or. !MaFisFound()
		aObjetos[SEGURO ]:Refresh()
	EndIf
	nVlrAnterior := aGets[VALDESP]
	aGets[VALDESP] := IIF(MaFisFound(),MaFisRet(,"NF_DESPESA"),aGets[VALDESP])
	If nVlrAnterior <> aGets[VALDESP] .Or. !MaFisFound()
		aObjetos[VALDESP]:Refresh()
	EndIf
	If GetNewPar("MV_VNAGREG",.F.)
		nVlrAnterior := aGets[VNAGREG ]
		aGets[VNAGREG ] := IIF(MaFisFound(),MaFisRet(,"NF_VNAGREG"),aGets[VNAGREG ])
		If nVlrAnterior <> aGets[VNAGREG ] .Or. !MaFisFound()
			aObjetos[VNAGREG ]:Refresh()
		EndIf
	Endif
EndIf
Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103ProcPC| Autor ³ Alex Lemes            ³ Data ³09/06/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Processa o carregamento do pedido de compras para a NFE    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array com os itens do pedido de compras            ³±±
±±³          ³ ExpN1 = Opcao valida                                       ³±±
±±³          ³ ExpC1 = Fornecedor                                         ³±±
±±³          ³ ExpC2 = loja fornecedor                                    ³±±
±±³          ³ ExpL1 = retorno do ponto de entrada                        ³±±
±±³          ³ ExpL2 = Uso do ponto de entrada                            ³±±
±±³          ³ ExpN2 = Saldo do pedido                                    ³±±
±±³          ³ ExpL3 = Usa funcao fiscal                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA103                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function a103procPC(aF4For,nOpc,cA100For,cLoja,lRet103Vpc,lMt103Vpc,nSldPed,lUsaFiscal,aGets,lNfMedic,aHeadSDE,aColsSDE,aHeadSEV, aColsSEV, lTxNeg, nTaxaMoeda)
Local nx         := 0
Local cSeek      := ""
Local cFilialOri :=""
Local cItem		 := StrZero(1,Len(SD1->D1_ITEM))
Local lZeraCols  := .T.
Local aRateio    := {0,0,0} 
Local aMT103NPC  := {}
Local aColsBkp   := Aclone(Acols)
Local cPrdNCad   := ""
Local nSavNF  	 := MaFisSave()
Local lPrjCni := If(FindFunction("ValidaCNI"),ValidaCNI(),.F.)
Local n103TXPC	 := 0
Local cSeekTXPC	 := ""
Local nPosPc	 := aScan(aHeader,{|x| AllTrim(x[2])=="D1_PEDIDO"})
Local nPosVlr	 := aScan(aHeader,{|x| AllTrim(x[2])=="D1_VUNIT"})
Local aMT103FRE  := {}
Local aCombo		:= {}
Local nPsTpFrt	:= 0
Local lvldFret := SuperGetMV("MV_VALFRET",.F.,.F.)
Local cFilSC7		:= xFilEnt(xFilial("SC7"),"SC7")
Local cRESTNFE	:= SuperGetMV("MV_RESTNFE")
Local lMT103NPC	:= ExistBlock("MT103NPC")
Local lMT103TXPC	:= ExistBlock("MT103TXPC")
Local lMT103FRE	:= ExistBlock("MT103FRE")
Local cPCNum		:= ""
Local aEstruSC7		:= SC7->( dbStruct() )
Local nPosC7Qtd		:= aScan(aEstruSC7, {|x| AllTrim(x[1]) == "C7_QUANT"})

DEFAULT lUsaFiscal := .T.
DEFAULT aGets      := {}
DEFAULT lNfMedic   := .F.
DEFAULT aHeadSDE   := {}
DEFAULT aColsSDE   := {}

If ( nOpc == 1 )
	
	If lPrjCni 
   		U_COMA120(@aF4For,lNfMedic,lUsaFiscal)
	EndIf
	
	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))
	
	DbSelectArea("SC7")
	SC7->(DbSetOrder(14))
	
	For nx	:= 1 to Len(aF4For)
		If aF4For[nx][1]
	        If lNfMedic
				cPCNum := aF4For[nx,6]
			Else
				cPCNum := aF4For[nx,3]
			Endif	
		
		 	If Select("ITPC") > 0
				ITPC->(DbCloseArea())
		 	Endif

			cQry := " SELECT R_E_C_N_O_ as RECNO"
			cQry += " ,      C7_NUM"
			cQry += " ,      C7_ITEM"
			cQry += " ,      C7_LOTPLS"
			cQry += " ,      C7_CODRDA"
			cQry += " ,      C7_PLOPELT"
			cQry += " ,      C7_PRODUTO"
			cQry += " ,      C7_TPFRETE"
			cQry += " ,      C7_MOEDA"
			cQry += " ,      C7_QUANT - C7_QUJE - C7_QTDACLA AS SLDPC"
			cQry += " FROM " + RetSqlName("SC7")
			cQry += " WHERE D_E_L_E_T_ = ''"
			cQry += " AND C7_NUM = '" + cPCNum + "'"
			cQry += " AND C7_FILENT = '" + cFilSC7 + "'"
			cQry += " AND C7_FORNECE = '" + cA100For + "'"
			
			If lNfMedic
				cQry += " AND C7_LOJA = '" + aF4For[nx,5] + "'"
			Else 
				cQry += " AND C7_LOJA = '" + aF4For[nx,2] + "'"
			EndIf

		If cRESTNFE == "S"
				cQry += " AND C7_CONAPRO <> 'B' AND C7_CONAPRO <> 'R'"
			Endif
			
			cQry += " AND C7_QUANT - C7_QUJE - C7_QTDACLA > 0"
			cQry += " AND C7_RESIDUO = ''"
			cQry += " ORDER BY C7_NUM"
			cQry += " ,        C7_ITEM"
			
			cQry := ChangeQuery(cQry)
			
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"ITPC",.T.,.T.)
			
			If Len(aEstruSC7) > 0 .And. nPosC7Qtd > 0
				TcSetField( "ITPC", "SLDPC", aEstruSC7[nPosC7Qtd,2], aEstruSC7[nPosC7Qtd,3], aEstruSC7[nPosC7Qtd,4] )
			EndIf
			
			DbSelectArea("ITPC")
			
			While ITPC->(!EOF())
				SC7->(DbGoTo(ITPC->RECNO))
				If lZeraCols
					aCols		:= {}
					lZeraCols	:= .F.	
					MaFisClear()
					
					If lVldFret .And. !Empty(ITPC->C7_TPFRETE) .And. MaFisFound("NF") .AND. Type("aNFEDanfe") == "A" .AND. Empty(aNfeDanfe[14])
						aCombo			:= CarregaTipoFrete()
						aNfeDanfe[14] := ITPC->C7_TPFRETE
						nPsTpFrt 		:= ascan(aCombo ,{|x| Substr(x,1,1) == Substr(aNFEDanfe[14],1,1)})
						If nPsTpFrt > 0
							oTpFrete:NAT := nPsTpFrt
							oTpFrete:refresh()
	                    EndIf
					EndIf
				EndIf 
         
				// Grava Lote do PLS e o codigo de RDA
				If cPaisLoc == "BRA" .And. Type("lUsouLtPLS") <> "U" .And. !lUsouLtPLS .And. !Empty(SC7->C7_LOTPLS) 
					lUsouLtPLS 	:= .T.
					cCodRDA		:= ITPC->C7_CODRDA
				Endif

				SB1->(DbSeek(xFilial("SB1") + ITPC->C7_PRODUTO))
				If SB1->(!Eof())
					If lMt103Vpc
						lRet103Vpc := .T.
						lRet103Vpc := Execblock("MT103VPC",.F.,.F.)
					EndIf
							
					If lRet103Vpc
						u_NfePC2Acol(ITPC->RECNO,,ITPC->SLDPC,cItem,,@aRateio,aHeadSDE,@aColsSDE)
						cItem := SomaIt(cItem)
				   	EndIf
			   	Else
			   		cPrdNCad += ITPC->C7_NUM+": "+ITPC->C7_PRODUTO+CHR(10)
				EndIf
	
				If ITPC->C7_MOEDA != 1
					cSeekTXPC := cFilSC7+cPCNum
				EndIf

				ITPC->(dbSkip())
			EndDo
						
			If Select("ITPC") > 0
				ITPC->(DbCloseArea())
			Endif
		EndIf
	Next nX
	
	//Exibe Lista dos Produtos não Cadastrados na Filial de Entrega
	If Len(cPrdNCad)>0 .And. !l103Auto
	   Aviso("A103ProcPC","Produtos não Cadastrados na Filial de Entrega"+CHR(10)+cPrdNCad,{"Ok"})
	EndIf

	//Restaura o Acols caso o mesmo estiver vazio
	If Len(Acols) == 0
	    aCols:= aColsBKP
	    MaFisRestore(nSavNF)
	Else
		//Ponto de entrada para manipular o array de multiplas naturezas por titulo no Pedido de Compras
		If lMT103NPC
			aMT103NPC := ExecBlock("MT103NPC",.F.,.F.,{aHeadSEV,aColsSEV})
		 	If (ValType(aMT103NPC) == "A")
		   		aColsSEV := aClone(aMT103NPC)
			EndIf
		EndIf

		//Ponto de entrada para alterar a moeda, taxa, e check box de taxa negociada de acordo com o Pedido de Compras
		If lMT103TXPC .And. !Empty(cSeekTXPC)
			If SC7->(DbSeek(cSeekTXPC))
				nPosItPc := aScan(aCols,{|x| AllTrim(x[nPosPc])==AllTrim(SC7->C7_NUM)})
				n103TXPC := ExecBlock("MT103TXPC",.F.,.F.)
				If ValType(n103TXPC) == "N"
					If n103TXPC > 0
						nTaxaMoeda := n103TXPC
					ElseIf nPosItPc > 0
						nTaxaMoeda := NoRound((aCols[nPosItPc][nPosVlr] / SC7->C7_PRECO),TamSx3("F1_TXMOEDA")[2])
					EndIf
					lTxNeg := .T.
					nMoedaCor := SC7->C7_MOEDA
				EndIf
			Endif
		EndIf

		//Impede que o item do PC seja deletado pela getdados da NFE na movimentacao das setas.
		If Type( "oGetDados" ) == "O"
			oGetDados:lNewLine:=.F.
			oGetDados:oBrowse:Refresh()
		EndIf

		//Ponto de entrada para manipular o array de Frete/Seguro/Despesa do Pedido de Compras
		If lMT103FRE
			aMT103FRE := ExecBlock("MT103FRE",.F.,.F.,aRateio)
			If (ValType(aMT103FRE) == "A")
				aRateio := aClone(aMT103FRE)
			EndIf
		EndIf
	
		//Rateio do valores de Frete/Seguro/Despesa do PC
		If lUsaFiscal
			Eval(bRefresh)
		Else
			aGets[SEGURO] := aRateio[1]
			aGets[VALDESP]:= aRateio[2]
			aGets[FRETE]  := aRateio[3]
		EndIf
	Endif
Endif

Return

/*_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fLoadSM0    ¦                           Data ¦ 05/05/2021  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Função para carregar os dados da empresa (do Sigamat)      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Quando a função é executada via job ou schedule            ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦          		                                                      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦  /  /    ¦      					                                  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
User Function fLoadSM0(aParams,cError,lDefault)
Local lRet       := .T.
Local cFileCfg   := "hfcfgxml001a.xml"
Local aDados     := {}
Local Nx := 0 //declaracao 
Private oXml

Default lDefault := .F.
                 
If File(cFileCfg)

	oXml := U_LoadCfgX(1,cFileCfg,)

	If oXml == Nil
	
		Return	
		
	EndIf
	
	cENABLE  := AllTrim(oXml:_MAIN:_WFXML01:_ENABLE:_XTEXT:TEXT)
	cENT     := AllTrim(oXml:_MAIN:_WFXML01:_ENT:_XTEXT:TEXT)
	nWFDELAY := Val(oXml:_MAIN:_WFXML01:_WFDELAY:_XTEXT:TEXT)
	cTHREADID:= AllTrim(oXml:_MAIN:_WFXML01:_THREADID:_XTEXT:TEXT)
	nSLEEP   := Val(oXml:_MAIN:_WFXML01:_SLEEP:_XTEXT:TEXT)
	cConsole := AllTrim(oXml:_MAIN:_WFXML01:_CONSOLE:_XTEXT:TEXT)

	If Type("oXml:_MAIN:_WFXML01:_JOBS:_JOB") == "U"
		
		aJobs    := {}
		
    ElseIf ValType(oXml:_MAIN:_WFXML01:_JOBS:_JOB) == "A"
    
		aJobs    := oXml:_MAIN:_WFXML01:_JOBS:_JOB  
		  
	Else
	
		aJobs    := {oXml:_MAIN:_WFXML01:_JOBS:_JOB}	
		
	EndIf

	cJOBS := ""
	
	For Nx := 1 To Len(aJobs)
	
		cJOBS += aJobs[Nx]:_XTEXT:TEXT
		
		If Nx < Len(aJobs)
		
			cJOBS    += ","
			
		EndIf		
				
	Next	
	
	Aadd(aDados,{"ENABLE"  ,cENABLE   		,"Servico Habilitado" 					}) 
	Aadd(aDados,{"ENT"     ,{cENT}  		,"Empresa/Filial principal do processo" }) 
	Aadd(aDados,{"WFDELAY" ,nWFDELAY   		,"Atraso apos a primeira execucao"   	}) 
	Aadd(aDados,{"THREADID",cTHREADID  		,"Identificador de Thread [Debug]"   	}) 
	Aadd(aDados,{"JOBS"    ,cJOBS   		,"Servico a ser processado" 			}) 
	Aadd(aDados,{"SLEEP"   ,nSLEEP    		,"Tempo de espera"   					}) 
	Aadd(aDados,{"CONSOLE" ,cConsole   		,"Informacoes dos processos no console" }) 

Else	

	Aadd(aDados,{"ENABLE"  ,"1"		   		,"Servico Habilitado" 					}) 
	Aadd(aDados,{"ENT"     ,{"99"}  		,"Empresa/Filial principal do processo" }) 
	Aadd(aDados,{"WFDELAY" ,10 		   		,"Atraso apos a primeira execucao"   	}) 
	Aadd(aDados,{"THREADID","1"		   		,"Identificador de Thread [Debug]"   	}) 
	Aadd(aDados,{"JOBS"    ,"X"		   		,"Servico a ser processado" 			}) 
	Aadd(aDados,{"SLEEP"   ,30000	 		,"Tempo de espera"   					}) 
	Aadd(aDados,{"CONSOLE" ,"1"		   		,"Informacoes dos processos no console" }) 

EndIf                      

aParams := aDados

Return(lRet)           


//Importa xml Antigo
User Function HFIMPANT()

Processa( {|| ImportaxmlAntigos() }, "Aguarde...", "Analisando xml´s importados...",.F.)

Return


Static Function ImportaxmlAntigos()

Local cPathx := AllTrim(GetNewPar("MV_X_PATHX",""))  //Diretorio xml
Local cDir   := cPathx + "Antigos\"  
Local cExtensao := "xml"
Local cError  := ""
Local cWarning := ""
Local oXml
Local x  := 0
Local cModelo   := ""
Local cChavexml := ""
Local cCodRet   := ""
Local cMensagem := ""
Local xManif    := ""
Local cxml      := ""
Local lExcluir  := .F.

if msgYesNo('Deseja importar os xml´s antigo da pasta \xmlsource\Antigos ?', 'Gestão Xml', 'YESNO')

	if !Existdir( cDir )
		MakeDir( cDir )
		Conout( "Diretorio criado com sucesso - HFIMPANT" )
	endif

	aFiles := Directory(cDir+"*."+cExtensao,"D")

	aSort( aFiles,,,{|x,y| x[1] < y[1] } )

	nTotLen := Len(aFiles)

	ProcRegua(nTotLen)

	For x := 1 To Len(aFiles)

		oXml := XmlParserFile( cDir + aFiles[x,1], "_", cError, cWarning )

		if oXml <> Nil

			SAVE oXml XMLSTRING cXML

			if upper("<PROCEVENTONFE ") $ upper( cXml )

				cModelo   := "55"
				cChavexml := oxml:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_CHNFE:TEXT
				cCodRet   := "101"
				cMensagem := oxml:_PROCEVENTONFE:_EVENTO:_INFEVENTO:_DETEVENTO:_DESCEVENTO:TEXT

				u_XMLSETCS(cModelo,cChaveXml,cCodRet,cMensagem,xManif)

				lExcluir := .T.

			else

				if upper("<CTEPROC ") $ upper( cXml )

					cModelo   := oxml:_CTEPROC:_CTE:_INFCTE:_IDE:_MOD:TEXT
					cChavexml := oxml:_CTEPROC:_PROTCTE:_INFPROT:_CHCTE:TEXT
					cCodRet   := oxml:_CTEPROC:_PROTCTE:_INFPROT:_CSTAT:TEXT
					cMensagem := oxml:_CTEPROC:_PROTCTE:_INFPROT:_XMOTIVO:TEXT

					u_XMLSETCS(cModelo,cChaveXml,cCodRet,cMensagem,xManif)

					lExcluir := .T.

				endif

			endif

			if lExcluir 
			
				if FERASE( cDir + aFiles[x,1] ) <> -1

					Conout("Arquivo deletado " + aFiles[x,1])

				else

					Conout("Erro no momento de deletar o arquivo " + Alltrim(Str( FERROR() )))

				endif

			endif

		endif

	Next x

	if lExcluir 

		MsgInfo("Xml atualizados com sucesso")

	Endif

endif

Return()

/*_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ NumNota    ¦                           Data ¦ 07/03/2023   ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Função para resolver bug do STRZERO                        ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Geral                                                      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦          		                                                      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦  /  /    ¦      					                                  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/

User Function NumNota(xNum,nTam)

	Local cRet := ""

	If valType(xNum) == "C"
		xNum := Val(xNum)
	EndIf	

	If nTam > 0
		cRet := strZero(xNum,nTam)
	Else
		cRet := strZero(xNum,len(alltrim(str(xNum))))
	EndIf

Return cRet


