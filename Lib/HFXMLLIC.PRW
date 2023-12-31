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

User Function HFXMLLIC(lMsg,dVencLic,cTipoLic)

	Local lLib 		:= .F.
	Local cUrl 		:= "https://cloud.importaxml.com.br"
	Local cClToken  :=	alltrim(GetNewPar("XM_CLTOKEN",Space(256)))
	Local cCnpj 	:= Alltrim(FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , { "M0_CGC" } )[1][2])
	Local aHeader 	:= {}
	Local oRest		:= Nil
	Local cLic		:= ""
	Local oLic		:= Nil
	Local dDataFim	:= stod("")
	Local cL		:= +CHR(13)+CHR(10)
	Local lVerifica	:= .T.

	Private oObjJson	:= Nil

	Aadd(aHeader, "Content-Type: application/json")
	Aadd(aHeader, "Connection: keep-alive")

	oRest 	:= FWRest():New(cUrl)
	oRest:SetPath("/api/LicencaProtheus?Token="+cClToken+"&cnpj="+cCnpj)

	If oRest:Get(aHeader)

		If !FWJsonDeserialize(oRest:GetResult(), @oObjJson)
			MsgStop("Ocorreu erro no processamento do Json")
			Return .F.
		EndIf

		If oObjJson:ATIVO //Se empresa est� ativa no Gest�o na Nuvem
  
			If Type( "oObjJson:CONTENT" ) <> "U"

				cLic := Decode64( oObjJson:CONTENT )
				If !FWJsonDeserialize(cLic, @oLic)
					MsgStop("Ocorreu erro no processamento do Json")
					Return .F.
				EndIf

				dDataFim := stod(substr(strtran(oLic:DATAFIM,"-",""),1,8))
				dVencLic := dDataFim

				If Date() > dDataFim //Se licen�a est� v�lida
					If lMsg
						msgAlert("Licen�a na nuvem vencida em "+Dtoc(dDataFim)+", Entre em contato com a HF - Consulting."+cL+"Tel: 11-5524-5124 ou Pelo E-mail comercial@hfbr.com.br."+cL+"O sistema ir� verificar a licen�a de conting�ncia")
					Endif
				Else
					cTipoLic := "Licen�a Cloud"
					dVencLic := dDataFim
					lLib := .T.
				EndIf	

			Else
				If lMsg
					msgAlert("Licen�a na nuvem n�o est� v�lida, entre em contato com a HF - Consulting."+cL+"Tel: 11-5524-5124 ou pelo E-mail comercial@hfbr.com.br."+cL+DecodeUTF8(oObjJson:MENSAGEM)+cL+"O sistema ir� verificar a licen�a de conting�ncia")				
				EndIf	
			EndIf

		Else
			lVerifica := .F.
			If lMsg
				msgAlert("Empresa "+cCnpj+" desativada na nuvem, Entre em contato com a HF - Consulting."+cL+"Tel: 11-5524-5124 ou pelo E-mail comercial@hfbr.com.br."+cL+"Sem acesso para utiliza��o do Gest�o XML Protheus")
			EndIf
		EndIf	

	Else

		If lMsg
			msgStop(oRest:getLastError(), "Erro")
		EndIf

	EndIf

	If !lLib .and. lVerifica
		lLib := U_HFXML00X("HF000001","101",SM0->M0_CGC,@dVencLic)  
		If lLib
			cTipoLic := "Licen�a em conting�ncia - Acione a equipe da HF Consulting para atualizar"
			If lMsg
				msgInfo("Licen�a em conting�ncia validada, significa que � um tipo de licen�a tempor�ria enquanto a licen�a na nuvem n�o � autenticada, a validade dessa licen�a � at� "+DToC(dVencLic))
			EndIf
		Else
			If lMsg
				msgAlert("Licen�a em conting�ncia n�o validada, significa que � um tipo de licen�a tempor�ria enquanto a licen�a na nuvem n�o � autenticada, entre em contato com a HF - Consulting."+cL+"Tel: 11-5524-5124 ou pelo E-mail comercial@hfbr.com.br.")
			EndIf
		EndIf
	EndIf

Return lLib
