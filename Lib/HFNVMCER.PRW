#INCLUDE "FILEIO.CH"
#INCLUDE "RPTDEF.CH"                                      
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "XMLXFUN.CH"

Static cBarra := Iif(IsSrvUnix(),"/","\")


User Function CertNVM(cToken)

Local cUrl 			:= ""
Local cPath 		:= ""
Local oRestClient 	:= Nil
Local aHeader 		:= {}
Local cMensagem		:= ""
Local lConectou		:= .F.
Local cCnpj 		:= Alltrim(FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , { "M0_CGC" } )[1][2])
Local oObjJson		:= Nil

cToken  			:= alltrim(cToken)

If U_TesteNVM(cToken)
	U_HFNVMCER(cToken,.F.)
Else
	If Empty(cToken)
		U_HFNVMCER(cToken,.T.)
	EndIf
EndIf

Return

User Function HFNVMCER(cToken,lNovo)

Local cGet1		:= Space(250) //"c:\totvs\tss\certs\coferly2020.pfx" //Arquivo
Local cGet2		:= Space(20) //"coferly2020" //Senha
Local oDlgSenha		:= Nil			
Local oGet1		:= Nil
Local oGet2		:= Nil
Local oButton1	:= Nil
Local oButton2	:= Nil
Local oButton3	:= Nil

DEFINE DIALOG oDlgSenha TITLE "Informe o certificado e a senha" FROM 180,180 TO 350,450 PIXEL

oGet1		:= TGet():New( 001,01,{ | u | If( PCount() == 0, cGet1, cGet1 := u ) },oDlgSenha,100,010,,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,'cGet1',,,, )
oGet2		:= TGet():New( 020,01,{ | u | If( PCount() == 0, cGet2, cGet2 := u ) },oDlgSenha,100,010,,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.T.,,'cGet2',,,, )

oButton1	:= TButton():New( 01, 110, "Buscar",oDlgSenha,{|| cGet1 := cGetFile( "PFX|*.PFX", "Escolha o certificado a ser enviado", 0, "/certs", .T.,0,.T.),oGet1:Refresh()}, 30,10,,,.F.,.T.,.F.,,.F.,,,.F. )   

oButton2	:= TButton():New( 040, 010, "Salvar",oDlgSenha,{|| U_HFNVMUP(cGet1,cGet2,cToken,lNovo), oDlgSenha:End() }, 30,20,,,.F.,.T.,.F.,,.F.,,,.F. )   
oButton3	:= TButton():New( 040, 050, "Cancelar",oDlgSenha,{|| oDlgSenha:End() }, 30,20,,,.F.,.T.,.F.,,.F.,,,.F. )

ACTIVATE DIALOG oDlgSenha CENTERED

Return

User Function HFNVMUP(cArquivo,cPsw,cToken,lNovo)

	Local cUrl  		:= ""
	Local aHeader		:= {}
	Local cPostParams	:= ""
	Local cResult		:= ""

	Private oObjJson	

	cPostParams := ""

	cUrl  := "https://cloud.importaxml.com.br"

	If lNovo
		cPath := "/api/CadastrarEmpresa?"
		cPath += "tokenConta=GQNLHVWA-E4IVRWC2-LGUAMU3X&"
		cPath += "cnpj="+alltrim(Alltrim(FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , { "M0_CGC" } )[1][2]))+"&"
		cPath += "inscricaoEstadual="+alltrim(Alltrim(FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , { "M0_INSC" } )[1][2]))+"&"
		cPath += "inscricaoMunicipal="+alltrim(Alltrim(FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , { "M0_INSCM" } )[1][2]))+"&"
		cPath += "responsavelNome="+alltrim(UsrFullName())+"&"
		cPath += "responsavelEmail="+alltrim(UsrRetMail())+"&"
		cPath += "responsavelRamal="+alltrim("000")+"&"
		cPath += "responsavelCelular="+alltrim(Alltrim(FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , { "M0_TEL" } )[1][2]))+"&"
		cPath += "responsavelCPF="+alltrim("00000000000")+"&"
		cPath += "responsavelEmail="+alltrim(UsrRetMail())+"&"
		cPath += "certificadoSenha="+alltrim(cPsw)

	Else

		cPath := "/api/AtualizarCertificado?
		cPath += "token="+alltrim(cToken)+"&"
		cPath += "certificadoSenha="+alltrim(cPsw)
		
	EndIf

	aadd(aHeader,'Content-Type: multipart/form-data ; boundary=----WebKitFormBoundaryFbmu0bODj7UvfQEV')
	
	cPostParams += CRLF
	cPostParams += CRLF
	cPostParams += 'Content-Disposition: form-data; name="certificado"; filename="'+cArquivo+'"' + CRLF      //Envio de Arquivo sem espeficar o Content-Type
 	cRetWs  := HttpPost(cUrl+cPath,"",cPostParams,60,aHeader,@cResult)

	If !Empty(cRetWs) 

		If !FWJsonDeserialize(cRetWs, @oObjJson)
			MsgStop("Ocorreu erro no processamento do Json")
			Return Nil
		Else
			If Type( "oObjJson:MESSAGE" ) <> "U"
				If alltrim(upper(oObjJson:MESSAGE)) == "SUCESSO"
					msgInfo( "Certificado instalado com sucesso" )
				Else
					If Type( "oObjJson:EXCEPTIONMESSAGE" ) <> "U"
						If "The specified network password is not correct" $ oObjJson:EXCEPTIONMESSAGE
							msgAlert("Senha Inválida")
						Else
							msgAlert(oObjJson:EXCEPTIONMESSAGE)
						EndIf
					Else
						msgAlert( "Ocorreu um erro na instalação" )
					EndIf	
				EndIf	
			Endif
		EndIf	

	EndIf	

Return
