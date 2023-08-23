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

		If oObjJson:ATIVO //Se empresa está ativa no Gestão na Nuvem
  
			If Type( "oObjJson:CONTENT" ) <> "U"

				cLic := Decode64( oObjJson:CONTENT )
				If !FWJsonDeserialize(cLic, @oLic)
					MsgStop("Ocorreu erro no processamento do Json")
					Return .F.
				EndIf

				dDataFim := stod(substr(strtran(oLic:DATAFIM,"-",""),1,8))
				dVencLic := dDataFim

				If Date() > dDataFim //Se licença está válida
					If lMsg
						msgAlert("Licença na nuvem vencida em "+Dtoc(dDataFim)+", Entre em contato com a HF - Consulting."+cL+"Tel: 11-5524-5124 ou Pelo E-mail comercial@hfbr.com.br."+cL+"O sistema irá verificar a licença de contingência")
					Endif
				Else
					cTipoLic := "Licença Cloud"
					dVencLic := dDataFim
					lLib := .T.
				EndIf	

			Else
				If lMsg
					msgAlert("Licença na nuvem não está válida, entre em contato com a HF - Consulting."+cL+"Tel: 11-5524-5124 ou pelo E-mail comercial@hfbr.com.br."+cL+DecodeUTF8(oObjJson:MENSAGEM)+cL+"O sistema irá verificar a licença de contingência")				
				EndIf	
			EndIf

		Else
			lVerifica := .F.
			If lMsg
				msgAlert("Empresa "+cCnpj+" desativada na nuvem, Entre em contato com a HF - Consulting."+cL+"Tel: 11-5524-5124 ou pelo E-mail comercial@hfbr.com.br."+cL+"Sem acesso para utilização do Gestão XML Protheus")
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
			cTipoLic := "Licença em contingência - Acione a equipe da HF Consulting para atualizar"
			If lMsg
				msgInfo("Licença em contingência validada, significa que é um tipo de licença temporária enquanto a licença na nuvem não é autenticada, a validade dessa licença é até "+DToC(dVencLic))
			EndIf
		Else
			If lMsg
				msgAlert("Licença em contingência não validada, significa que é um tipo de licença temporária enquanto a licença na nuvem não é autenticada, entre em contato com a HF - Consulting."+cL+"Tel: 11-5524-5124 ou pelo E-mail comercial@hfbr.com.br.")
			EndIf
		EndIf
	EndIf

Return lLib
