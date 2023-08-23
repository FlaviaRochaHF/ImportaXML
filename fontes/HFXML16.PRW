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

Static lInitSped := .F.
//Static lUnix     := IsSrvUnix()
//Static cBarra    := Iif(lUnix,"/","\")


/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Programa  ≥ HFXML16  ≥ Autor ≥ Eneovaldo Roveri Jr   ≥ Data ≥07/07/2019≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Rotina de Download de XMLs do Sefaz                        ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
User Function HFXML16()

Local aArea := GetArea()
Local nOpc  := 0
Local nChv  := 0
Local cEmp0 := cEmpAnt
Local cFil0 := cFilAnt
Local nReg0 := SM0->( recno() )
Local nVersao := Val(GetVersao(.F.))     // Indica a versao do Protheus
Local cArq
Local cCloud		:=	alltrim(GetNewPar("XM_CLOUD" ,"0"))         //aCombo (0=Desbilitado 1=Habilitado) 

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

Private cTmp_ZBS := "TMPZBS", cAli_ZBS, oTmp_ZBS
Private aEmpFils := U_XGetEmpF()

if U_HFX16Cer( NIL,.T.) == 9
	Return( NIL )
endif

if nVersao >= 12

	CriaTMP(@cArq)
	cAli_ZBS := oTmp_ZBS:GetAlias()
	
Else

	cAli_ZBS := CriaTMP(@cArq)
	
Endif

nOpc := U_MyAviso("OpÁ„o","1-Informar CNPJ ou "+CRLF+"2-Informar Chave"+CRLF+"3-Nenhuma Chave",{"1-CNPJ","2-Chave","3-Nenhum"},3)

if nOpc == 1

	if HFXML16Cnp()
		nChv++
	endif
	
ElseIf nOpc == 2

	//do while 
	HFXML16Chv(@nChv)
		//if nChv == 10
//			Exit
		//endif
	//enddo
	
EndIf

if nChv > 0 .or. nOpc == 3
	HFXML16Brw()
endif

if nVersao >= 12
	oTmp_ZBS:Delete()
Else
	(cAli_ZBS)->( dbCloseArea() )
	fErase( cArq+GetDBExtension() )
Endif

RestArea(aArea)

Return(NIL)


//Rogerio Lino - 18/12/2019
//Rotina de consulta xml sefaz 
User Function NFeConsProt( cChave, lShowMsg, cCodRet, xManif )

Local aArea        := GetArea()
Local lRet         := .T.
Local cURL         := ""
Local cMsg         := ""
Local oWsdl        := Nil
Local cMsgRet      := ""
Local cError       := ""
Local cWarning     := ""
//Local cUfAutor     := U_HFUFMAT( Alltrim(SM0->M0_CGC) )  // "35" //SuperGetMV("MV_X_BXUF",  .F., "35")  //pegar do sigamat
Local cTpAmb       := "" //GetNewPar("XM_AMBNFE", "1")   //È 1 mesmo
//Local cCNPJEmp     := Alltrim(SM0->M0_CGC)  
Local lContinua    := .T.
Local cRet         := ""
Local cNewRet      := ""
Local cModelo      := ""
Local cTipMod      := ""
Local cStatus      := ""
Local cDigVal      := ""
Local cProt        := ""
Local cMotivo      := ""
  
Local cCACertFile := GetNewPar("XM_CERTCA" ,"\certs\000001_ca.pem"  ,cFilAnt)
Local cCertFile   := GetNewPar("XM_CERTCER","\certs\000001_cert.pem",cFilAnt)
Local cKeyFile    := GetNewPar("XM_CERTKEY","\certs\000001_key.pem" ,cFilAnt)
Local cKeyPwd     := GetNewPar("XM_CERTPSW","coferly2020"           ,cFilAnt)
Local nVersion    := GetNewPar("XM_CERTPRO",0)
Local nTimeO      := GetNewPar("XM_CERTTIM",120)
Local cCloud	  := GetNewPar("XM_CLOUD" ,"0")         //aCombo (0=Desbilitado 1=Habilitado)

Private oXmlDocZip

Default lShowMsg := .F.
Default cCodRet  := ""
Default xManif   := "0"

If cCloud == "1" .and. cTipMod == "55"

	IF u_HFXSEMA()

		cUrl 	:= "https://cloud.importaxml.com.br"
		cCnpj 	:= Alltrim(FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , { "M0_CGC" } )[1][2])

		Aadd(aHeader, "Content-Type: application/json")                      
		Aadd(aHeader, "Connection: keep-alive")   

		oRest 	:= FWRest():New(cUrl)

		oRest:SetPath("/api/NFeConsultaSituacao?token="+cClToken+"&Chave="+cChave)  		

		oRest:Get(aHeader) 

		If oRest:GetResult() <> Nil 
		
			cXmlRet := oRest:GetResult()

			cXmlRet := strTran(cXmlRet,'"','')

			oXmlRet := XmlParser( cXmlRet ,"_",@cErro, @cWarning )

			If ( oXmlRet == NIL )

				oXmlRet := NIL								
				FreeObj(oXmlRet)
				MsgStop("Falha ao gerar Objeto XML : "+cError+" / "+cWarning)
				Return

			Endif

			//Se existir Warning, mostra no console.log
			If ! Empty(cWarning)
			
				ConOut( "[u_NFeConsProt] - Alerta cWarning: " + cWarning )
				
			EndIf
				
			//Se houve erro, n„o permitir· prosseguir
			If ! Empty(cError)
			
				ConOut("[u_NFeConsProt]- Erro: " + cError)
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

				cModelo := iif(cTipMod == "55", "NFe", "CTe")
				
				cRet := "Chave: " + cChave + CRLF 
				cRet += "Vers„o da mensagem: " + cVersao + CRLF 
				cRet += "Ambiente: " + iif(cTpAmb == "1","ProduÁ„o","HomologaÁ„o") + CRLF
				cRet += "Cod. Ret. " + cModelo + ": " + cStatus + CRLF
				cRet += "Msg. Ret. " + cModelo + ": " + cMotivo + CRLF
				cRet += cNewRet
				
				if lShowMsg 

					u_MyAviso("NFeConsProt - Consulta",cRet,{"OK"},3)

				endif

			endif

		Endif 

		U_HFXGRSEMA("NFeConsProt",cChave)

	endif

	oRest := NIL								
	FreeObj(oRest)

Else

	//Inst‚ncia a classe, setando as par‚metrizaÁıes necess·rias
	oWsdl := TWsdlManager():New()
	oWsdl:cSSLCACertFile := cCACertFile   //SuperGetMV("XM_X_BXCA",  .F., "\certs\000001_ca.pem")    //criar pasta dentro do protheus_data
	oWsdl:cSSLCertFile   := cCertFile     //SuperGetMV("XM_X_BXCER", .F., "\certs\000001_cert.pem")  //no caso aqui teria que ter o wizard de certificado que tanto falamos
	oWsdl:cSSLKeyFile    := cKeyFile      //SuperGetMV("XM_X_BXKEY", .F., "\certs\000001_key.pem")   //
	oWsdl:cSSLKeyPwd     := cKeyPwd       //SuperGetMV("XM_X_BXPSW", .F., "cofer1030")
	oWsdl:nSSLVersion    := nVersion      //SuperGetMV("XM_X_BXPRO", .F., "0")
	oWsdl:nTimeout       := nTimeO
	oWsdl:lSSLInsecure   := .T.

	cTpAmb := ( GetNewPar("XM_AMBNFE" ,"1",cFilAnt) )

	//Posicionar na tabela ZBS
	//DbSelectArea("ZBS")
	//DbSetOrder(3)
	//DbSeek( cChave )

	U_HFXML071(cChave)
		If !lConsReq
		lRet := .F.
	Return(lRet)
		EndIf
	cTipMod := Substr(cChave,21,2)  //ZBS->ZBS_MODELO

	if cTipMod $ "55,57"

		//Retorna a url de acordo com a UF
		cURL   := Alltrim( RETURLUF( Substr(cChave,1,2), cTipMod )) + "?WSDL"

	else

		if lShowMsg 

			u_MyAviso("NFeConsProt - Consulta","Tipo da nota n„o È compatÌvel para consultar sefaz",{"OK"},3)

		endif

		RestArea(aArea)

		Return(.F.)

	endif
	
	//Tenta fazer o Parse da URL
	lRet := oWsdl:ParseURL(cURL)

	If ! lRet 

		ConOut("[u_NFeConsProt] - Erro ParseURL: " + oWsdl:cError)
		lContinua := .F.
		cRet := "[u_NFeConsProt] - Erro ParseURL: " + oWsdl:cError
		
	EndIf
		
	//Se for continuar o processamento
	If lContinua
		
		//Tenta definir a operaÁ„o
		if cTipMod == "55"  //NFE
			lRet := oWsdl:SetOperation("nfeConsultaNF")
		else
			lRet := oWsdl:SetOperation("cteConsultaCT")  //cteconsultaprotocolo
		endif
		
		If ! lRet 
		
			ConOut("[u_NFeConsProt] - Erro SetOperation: " + oWsdl:cError)
			lContinua := .F.
			cRet := "[u_NFeConsProt] - Erro SetOperation: " + oWsdl:cError
			
		EndIf
		
	EndIf
		
	//Se for continuar
	If lContinua

		if cTipMod == "55"  //NFE
		
			//Monta a mensagem que ser· enviada                                                                                     
			cMsg := '<soap12:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap12="http://www.w3.org/2003/05/soap-envelope">' 
			cMsg += '<soap12:Header>' 
			cMsg += '<nfeCabecMsg xmlns="http://www.portalfiscal.inf.br/nfe/wsdl/NFeConsultaProtocolo4"/>' 
			cMsg += '</soap12:Header>' 
			cMsg += '<soap12:Body>' 
			cMsg += '<nfeDadosMsg xmlns="http://www.portalfiscal.inf.br/nfe/wsdl/NFeConsultaProtocolo4">' 
			cMsg += '<consSitNFe xmlns="http://www.portalfiscal.inf.br/nfe" versao="4.00">' 
			cMsg += '<tpAmb>' + cTpAmb + '</tpAmb>' 
			cMsg += '<xServ>CONSULTAR</xServ>' 
			cMsg += '<chNFe>' + alltrim( cChave ) + '</chNFe>' 
			cMsg += '</consSitNFe>' 
			cMsg += '</nfeDadosMsg>' 
			cMsg += '</soap12:Body>' 
			cMsg += '</soap12:Envelope> '
				
			//Envia uma mensagem SOAP personalizada ao servidor
			lRet := oWsdl:SendSoapMsg(cMsg)
			lRet := .T.
			
			If ! lRet 
			
				ConOut("[u_NFeConsProt] - Erro SendSoapMsg: " + oWsdl:cError)
				ConOut("[u_NFeConsProt] - Erro SendSoapMsg FaultCode: " + oWsdl:cFaultCode)
				
				lContinua := .F.
				
				cRet := "[u_NFeConsProt] - Erro SendSoapMsg: " + oWsdl:cError
				cRet += "[u_NFeConsProt] - Erro SendSoapMsg FaultCode: " + oWsdl:cFaultCode
				
			EndIf
					
		else

			//Monta a mensagem que ser· enviada                                                                                     
			cMsg := '<soap12:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap12="http://www.w3.org/2003/05/soap-envelope">' 
			cMsg += '<soap12:Header>' 
			cMsg += '<cteCabecMsg xmlns="http://www.portalfiscal.inf.br/cte/wsdl/CteConsulta">' 
			cMsg += '<cUF>' + Substr(cChave,1,2) + '</cUF>'
			cMsg += '<versaoDados>3.00</versaoDados>'
			cMsg += '</cteCabecMsg>'
			cMsg += '</soap12:Header>' 
			cMsg += '<soap12:Body>' 
			cMsg += '<cteDadosMsg xmlns="http://www.portalfiscal.inf.br/cte/wsdl/CteConsulta">' 
			cMsg += '<consSitCTe versao="3.00" xmlns="http://www.portalfiscal.inf.br/cte">' 
			cMsg += '<tpAmb>' + cTpAmb + '</tpAmb>' 
			cMsg += '<xServ>CONSULTAR</xServ>' 
			cMsg += '<chCTe>' + alltrim( cChave ) + '</chCTe>' 
			cMsg += '</consSitCTe>' 
			cMsg += '</cteDadosMsg>' 
			cMsg += '</soap12:Body>' 
			cMsg += '</soap12:Envelope>'
			
			//Envia uma mensagem SOAP personalizada ao servidor
			lRet := oWsdl:SendSoapMsg(cMsg)
			lRet := .T.
			
			If ! lRet 
			
				ConOut("[u_NFeConsProt] - Erro SendSoapMsg: " + oWsdl:cError)
				ConOut("[u_NFeConsProt] - Erro SendSoapMsg FaultCode: " + oWsdl:cFaultCode)
				
				lContinua := .F.
				
				cRet := "[u_NFeConsProt] - Erro SendSoapMsg: " + oWsdl:cError
				cRet += "[u_NFeConsProt] - Erro SendSoapMsg FaultCode: " + oWsdl:cFaultCode
				
			EndIf
		
		endif    
		
	EndIf

	//Se for continuar
	If lContinua

		//Pega a resposta do SOAP
		cMsgRet := oWsdl:GetSoapResponse()
		
		//Transforma a resposta em um objeto
		oXml := XmlParser(cMsgRet, "_", @cError, @cWarning)

		If ( oXml == NIL )

			oXml := NIL								
			FreeObj(oXml)
			MsgStop("Falha ao gerar Objeto XML : "+cError+" / "+cWarning)
			Return

		Endif
		
		//Se existir Warning, mostra no console.log
		If ! Empty(cWarning)
		
			ConOut( "[u_NFeConsProt] - Alerta cWarning: " + cWarning )
			
		EndIf
			
		//Se houve erro, n„o permitir· prosseguir
		If ! Empty(cError)
		
			ConOut("[u_NFeConsProt]- Erro: " + cError)
			lContinua := .F.
			
		EndIf

		lRet := .T.
									
		if Type("oxml:_soap_envelope:_soap_body:_nferesultmsg:_retconssitnfe:_protnfe") <> "U"
		
			cChave  := oxml:_soap_envelope:_soap_body:_nferesultmsg:_retconssitnfe:_protnfe:_infprot:_chnfe:text
			cVersao := oxml:_soap_envelope:_soap_body:_nferesultmsg:_retconssitnfe:_protnfe:_versao:text
			cStatus := oxml:_soap_envelope:_soap_body:_nferesultmsg:_retconssitnfe:_protnfe:_infprot:_cstat:text
			cTpAmb  := oxml:_soap_envelope:_soap_body:_nferesultmsg:_retconssitnfe:_protnfe:_infprot:_tpamb:text
			cMotivo := oxml:_soap_envelope:_soap_body:_nferesultmsg:_retconssitnfe:_protnfe:_infprot:_xmotivo:text
			cProt   := oxml:_soap_envelope:_soap_body:_nferesultmsg:_retconssitnfe:_protnfe:_infprot:_nprot:text
			cDigVal := oxml:_soap_envelope:_soap_body:_nferesultmsg:_retconssitnfe:_protnfe:_infprot:_digval:text
			
		else

			if Type("oxml:_soap_envelope:_soap_body:_cteconsultactresult:_retconssitcte:_protcte") <> "U"
		
				cChave  := oxml:_soap_envelope:_soap_body:_cteconsultactresult:_retconssitcte:_protcte:_infprot:_chcte:text
				cProt   := oxml:_soap_envelope:_soap_body:_cteconsultactresult:_retconssitcte:_protcte:_infprot:_nprot:text
				cDigVal := oxml:_soap_envelope:_soap_body:_cteconsultactresult:_retconssitcte:_protcte:_infprot:_digval:text

			endif

			if Type("oxml:_soap_envelope:_soap_body:_cteconsultactresult:_retconssitcte") <> "U"

				cTpAmb  := oxml:_soap_envelope:_soap_body:_cteconsultactresult:_retconssitcte:_tpamb:text
				cStatus := oxml:_soap_envelope:_soap_body:_cteconsultactresult:_retconssitcte:_cstat:text
				cVersao := oxml:_soap_envelope:_soap_body:_cteconsultactresult:_retconssitcte:_versao:text
				cMotivo := oxml:_soap_envelope:_soap_body:_cteconsultactresult:_retconssitcte:_xmotivo:text

			endif
		
		endif       

		cCodRet := cStatus 

		cNewRet := "Protocolo: " + cProt + CRLF
		cNewRet += "Digito: " + cDigVal + CRLF

		cModelo := iif(cTipMod == "55", "NFe", "CTe")
		
		cRet := "Chave: " + cChave + CRLF 
		cRet += "Vers„o da mensagem: " + cVersao + CRLF 
		cRet += "Ambiente: " + iif(cTpAmb == "1","ProduÁ„o","HomologaÁ„o") + CRLF
		cRet += "Cod. Ret. " + cModelo + ": " + cStatus + CRLF
		cRet += "Msg. Ret. " + cModelo + ": " + cMotivo + CRLF
		cRet += cNewRet
		
		if lShowMsg 

			u_MyAviso("NFeConsProt - Consulta",cRet,{"OK"},3)

		endif

	else

		lRet := .F.
		
	EndIf

	RestArea(aArea)
		
	Return(lRet) 

EndIf
//Rogerio Lino - 18/12/2019
//Retorna a url de consulta de acordo com a UF
Static Function RETURLUF( cUF, cModel )

Local aUf  := {}
Local cUrl := ""

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

nPos := aScan( aUf,{ |x| x[2] == cUF } )

if nPos > 0

	cRet := aUf[ nPos,1 ]
	
Endif

Do Case

	Case cRet == "AM"
	
		if cModel == "55"
	
			cUrl := "https://nfe.sefaz.am.gov.br/services2/services/NfeConsulta4.asmx"
			
		else
		
			cUrl := "https://cte.svrs.rs.gov.br/ws/cteconsulta/CteConsulta.asmx"
		
		endif
	
	Case cRet == "BA"
	
		if cModel == "55"
	
			cUrl := "https://nfe.sefaz.ba.gov.br/webservices/NFeConsultaProtocolo4/NFeConsultaProtocolo4.asmx"
			
		else
		
			cUrl := "https://cte.svrs.rs.gov.br/ws/cteconsulta/CteConsulta.asmx"
		
		endif
		
	Case cRet == "CE"
	
		if cModel == "55"
	
			cUrl := "https://nfe.sefaz.ce.gov.br/nfe4/services/NFeConsultaProtocolo4.asmx"
			
		else
		
			cUrl := "https://cte.svrs.rs.gov.br/ws/cteconsulta/CteConsulta.asmx"
		
		endif
		
	Case cRet == "GO"
	
		if cModel == "55"
	
			cUrl := "https://nfe.sefaz.go.gov.br/nfe/services/NFeConsultaProtocolo4.asmx"
			
		else
		
			cUrl := "https://cte.svrs.rs.gov.br/ws/cteconsulta/CteConsulta.asmx"
		
		endif
		
	Case cRet == "MG"
		
		if cModel == "55"
	
			cUrl := "https://nfe.fazenda.mg.gov.br/nfe2/services/NFeConsultaProtocolo4.asmx"
			
		else
		
			cUrl := "https://cte.fazenda.mg.gov.br/cte/services/CteConsulta"
		
		endif
		
	Case cRet == "MS"
	
		if cModel == "55"
	
			cUrl := "https://www.svc.fazenda.gov.br/NFeConsultaProtocolo4/NFeConsultaProtocolo4.asmx"
			
		else
		
			cUrl := "https://producao.cte.ms.gov.br/ws/CteConsulta"
		
		endif

	Case cRet == "MT"
			
		if cModel == "55"
	
			cUrl := "https://nfe.sefaz.mt.gov.br/nfews/v2/services/NfeConsulta4.asmx"
			
		else
		
			cUrl := "https://cte.sefaz.mt.gov.br/ctews/services/CteConsulta"
		
		endif
				
	Case cRet == "PE"
	
		if cModel == "55"
	
			cUrl := "https://nfe.sefaz.pe.gov.br/nfe-service/services/NFeConsultaProtocolo4.asmx"
			
		else
		
			cUrl := "https://nfe.fazenda.sp.gov.br/cteWEB/services/CteConsulta.asmx"
		
		endif
		
	Case cRet == "PR"
	
		if cModel == "55"
	
			cUrl := "https://nfe.sefa.pr.gov.br/nfe/NFeConsultaProtocolo4.asmx"
			
		else
		
			cUrl := "https://cte.fazenda.pr.gov.br/cte/CteConsulta.asmx"
		
		endif
		
	Case cRet == "RS"
	
		if cModel == "55"
	
			cUrl := "https://nfe.sefazrs.rs.gov.br/ws/NfeConsulta/NfeConsulta4.asmx"
			
		else
		
			cUrl := "https://cte.svrs.rs.gov.br/ws/cteconsulta/CteConsulta.asmx"
		
		endif
		
	Case cRet == "SP"
			
		if cModel == "55"
	
			cUrl := "https://nfe.fazenda.sp.gov.br/ws/nfeconsultaprotocolo4.asmx"
			
		else
		
			cUrl := "https://nfe.fazenda.sp.gov.br/cteWEB/services/cteConsulta.asmx"
		
		endif
	
	Otherwise
	
	if cModel == "55"
	
		if cRet $ "AC/AL/PB/RJ/RO/RR/SC/SE/TO/DF"

			cUrl := "https://www.sefazvirtual.fazenda.gov.br/NFeConsultaProtocolo4/NFeConsultaProtocolo4.asmx"
			
		endif
		
		if cRet $ "ES/MA/PI/PA/AP"
		
			cUrl := "https://nfe.svrs.rs.gov.br/ws/NfeConsulta/NfeConsulta4.asmx"
			
		endif
		
	else
	
		if cRet $ "AC/AL/AM/BA/CE/DF/ES/GO/MA/PA/PB/PI/RJ/RN/RO/SC/SE/TO"

			cUrl := "https://cte.svrs.rs.gov.br/ws/cteconsulta/CteConsulta.asmx"
			
		endif
		
		if cRet $ "AP/PE/RR"
		
			cUrl := "https://nfe.fazenda.sp.gov.br/cteWEB/services/CteConsulta.asmx"
			
		endif
		
	endif

EndCase

Return cUrl


Static Function CriaTMP(cArq)

Local aStru     := {}
Local nVersao   := Val(GetVersao(.F.))     // Indica a versao do Protheus
Local nTamCod   := TAMSXG("001")[1]
Local nTamLoja  := TAMSXG("002")[1]
Local aInd      := {}

default cArq := ""

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
aadd( aStru, { "DEMI"    ,"D",08,0 } )
aadd( aStru, { "VNF"     ,"C",15,0 } )
aadd( aStru, { "XNOME"   ,"C",60,0 } )
aadd( aStru, { "IE"      ,"C",14,0 } )
aadd( aStru, { "DIGVAL"  ,"C",28,0 } )
aadd( aStru, { "DHRECBTO","D",08,0 } )
aadd( aStru, { "CSITNFE" ,"C",01,0 } )
aadd( aStru, { "CSITCONF","C",01,0 } )
aadd( aStru, { "NSU"     ,"C",15,0 } )
aadd( aStru, { "Correcao","M",10,0 } )
aadd( aStru, { "IDENT"   ,"C",14,0 } )
aadd( aStru, { "XML"     ,"M",10,0 } )
aadd( aStru, { "XMLCANC" ,"M",10,0 } )
aadd( aStru, { "TOMA" 	 ,"C",14,0 } )

if nVersao >= 12

	oTmp_ZBS := FWTemporaryTable():New( cTmp_ZBS, aStru ) //-> Objeto FWTemporaryTable 
		
		aInd := {}
		aadd( aInd, "CHAVE" )
		
	oTmp_ZBS:AddIndex( cTmp_ZBS+"01", aInd )
		aInd := {}
		aadd( aInd, "SERIE" )
		aadd( aInd, "CNF" )
	oTmp_ZBS:AddIndex( cTmp_ZBS+"02", aInd )
		aInd := {} //SERIE+CNF+CNPJ_EMI
		aadd( aInd, "SERIE" )
		aadd( aInd, "CNF" )
		aadd( aInd, "CNPJ_EMI" )
	oTmp_ZBS:AddIndex( cTmp_ZBS+"03", aInd )
		aInd := {} //CNPJ_EMI
		aadd( aInd, "CNPJ_EMI" )
	oTmp_ZBS:AddIndex( cTmp_ZBS+"04", aInd )
		aInd := {}  //XNOME
		aadd( aInd, "XNOME" )
	oTmp_ZBS:AddIndex( cTmp_ZBS+"05", aInd )
		aInd := {}  //"CODFOR+LOJFOR"
		aadd( aInd, "CODFOR" )
		aadd( aInd, "LOJFOR" )
	oTmp_ZBS:AddIndex( cTmp_ZBS+"06", aInd )
		aInd := {}   //"ST+CHAVE"
		aadd( aInd, "ST" )
		aadd( aInd, "CHAVE" )
	oTmp_ZBS:AddIndex( cTmp_ZBS+"07", aInd )
		aInd := {}   //"DEMI"
		aadd( aInd, "DEMI" )
	oTmp_ZBS:AddIndex( cTmp_ZBS+"08", aInd )
		aInd := {}   //"DHRECBTO"
		aadd( aInd, "DHRECBTO" )
	oTmp_ZBS:AddIndex( cTmp_ZBS+"09", aInd )
	oTmp_ZBS:Create()
	
Else

	cArq := CriaTrab( aStru, .T. )
	dbUseArea(.T.,, cArq,cTmp_ZBS, .F., .F.) //exclusivo
	
	IndRegua(cTmp_ZBS,cArq+"01","CHAVE" ) 
	IndRegua(cTmp_ZBS,cArq+"02","SERIE+CNF" )
	IndRegua(cTmp_ZBS,cArq+"03","SERIE+CNF+CNPJ_EMI" )
	IndRegua(cTmp_ZBS,cArq+"04","CNPJ_EMI" )
	IndRegua(cTmp_ZBS,cArq+"05","XNOME" )
	IndRegua(cTmp_ZBS,cArq+"06","CODFOR+LOJFOR" )
	IndRegua(cTmp_ZBS,cArq+"07","ST+CHAVE" )
	IndRegua(cTmp_ZBS,cArq+"08","DEMI" )
	IndRegua(cTmp_ZBS,cArq+"09","DHRECBTO" )
	
	dbClearIndex()
	
	dbSetIndex( cArq+"01" + OrdBagExt() )//ordem 1
	dbSetIndex( cArq+"02" + OrdBagExt() )//ordem 2
	dbSetIndex( cArq+"03" + OrdBagExt() )//ordem 3
	dbSetIndex( cArq+"04" + OrdBagExt() )//ordem 4
	dbSetIndex( cArq+"05" + OrdBagExt() )//ordem 5
	dbSetIndex( cArq+"06" + OrdBagExt() )//ordem 6
	dbSetIndex( cArq+"07" + OrdBagExt() )//ordem 7
	dbSetIndex( cArq+"08" + OrdBagExt() )//ordem 8
	dbSetIndex( cArq+"09" + OrdBagExt() )//ordem 8
	dbSetOrder( 9 )
//IndRegua("TMP",cArq+"G","ST+DHRECBTO" )

EndIf

Return(cTmp_ZBS)


/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Programa  ≥HFXML06Brw≥ Autor ≥ Eneovaldo Roveri Jr   ≥ Data ≥03/10/2013≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ MarkBrowse das Chaves para Download                        ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Static Function HFXML16Brw()

//Declarar vari·veis locais
    //Local oColumn
    //Local aCampos	:= {}
    //Local aColumns	:= {}
    //Local cArqTrb
    //Local cIndice1, cIndice2, cIndice3,cIndice4 := ""
    //Local nX
    //Local lMarcar  	:= .F.
    Local aSeek   := {}
	//Local bKeyF12 := {|| }	//:= {||  U_MCFG006M(),oBrowse:SetInvert(.F.),oBrowse:Refresh(),oBrowse:GoTop(.T.) } //Programar a tecla F12
 
    Private oBrowse 	:= Nil
    Private cCadastro 	:= "Usu·rios do Sistema"
    Private aRotina	 	:= Menudef() //Se for criar menus via MenuDef

    aSeek := {}
    aAdd(aSeek,{"Chave"	    		,{{"","C",044,0,"Chave"	       ,""}} } )
    aAdd(aSeek,{"Serie+Nf"			,{{"","C",012,0,"Serie+Nf"	   ,""}} } )
    aAdd(aSeek,{"Serie+Nf+Cnpj"     ,{{"","C",100,0,"Serie+Nf+Cnpj",""}} } )
    aAdd(aSeek,{"Cnpj"	    		,{{"","C",014,0,"Cnpj"	       ,""}} } )
    aAdd(aSeek,{"Emitente"	   		,{{"","C",044,0,"Emitente"     ,""}} } )
    aAdd(aSeek,{"CodFor+Loj"		,{{"","C",010,0,"CodFor+Loj"   ,""}} } )
    aAdd(aSeek,{"St+Chave"	   		,{{"","C",050,0,"St+Chave"	   ,""}} } )
    aAdd(aSeek,{"DEMI"	    		,{{"","D",008,0,"Dt Emiss„o"   ,""}} } )
    aAdd(aSeek,{"DHRECBTO"	  		,{{"","D",008,0,"Dt Recbto"    ,""}} } )

    oBrowse:= FWMarkBrowse():New()
    oBrowse:SetDescription("Download XML do SEFAZ") //Titulo da Janela
    //oBrowse:SetParam(bKeyF12) // Seta tecla F12
    oBrowse:SetAlias(cTmp_ZBS) //Indica o alias da tabela que ser· utilizada no Browse
    oBrowse:SetFieldMark("OK") //Indica o campo que dever· ser atualizado com a marca no registro
    oBrowse:oBrowse:SetDBFFilter(.T.)
    oBrowse:oBrowse:SetUseFilter(.T.) //Habilita a utilizaÁ„o do filtro no Browse
    oBrowse:oBrowse:SetFixedBrowse(.T.)
    oBrowse:SetWalkThru(.F.) //Habilita a utilizaÁ„o da funcionalidade Walk-Thru no Browse
    oBrowse:SetAmbiente(.T.) //Habilita a utilizaÁ„o da funcionalidade Ambiente no Browse
    oBrowse:SetTemporary() //Indica que o Browse utiliza tabela tempor·ria
    oBrowse:oBrowse:SetSeek(.T.,aSeek) //Habilita a utilizaÁ„o da pesquisa de registros no Browse
    oBrowse:oBrowse:SetFilterDefault("") //Indica o filtro padr„o do Browse

    oBrowse:AddLegend("ST=='1'","GREEN" 	,"Download Efetuado")
    oBrowse:AddLegend("ST==' '","YELLOW"   	,"Aguardando SolicitaÁ„o")
    oBrowse:AddLegend("ST=='0'","RED"   	,"Erro no Download")
    oBrowse:AddLegend("ST=='2'","BLUE"   	,"ManifestaÁ„o do Destinat·rio")

    //cCampo,cTitulo,nArrData,cPicture,nAlign,nSize,nDecimal
    oBrowse:SetColumns(HFXML16TIT("CHAVE"	,"Chave"	 ,03,""  ,0,044,0))
    oBrowse:SetColumns(HFXML16TIT("ERRO"	,"Resp.Sefaz",04,""  ,1,040,0))
    oBrowse:SetColumns(HFXML16TIT("CSITCONF","Manif"	 ,05,""  ,1,001,0))
    oBrowse:SetColumns(HFXML16TIT("CNPJ_EMI","Emitente"	 ,06,""  ,1,014,0))
    oBrowse:SetColumns(HFXML16TIT("CODFOR"  ,"CodFor"	 ,07,""  ,1,006,0))
    oBrowse:SetColumns(HFXML16TIT("LOJFOR"  ,"Loja"   	 ,08,""  ,1,004,0))
    oBrowse:SetColumns(HFXML16TIT("DEMI"    ,"DT EMISSAO",09,"@D",1,008,0))
    oBrowse:SetColumns(HFXML16TIT("CNF"     ,"NT FISCAL" ,10,""  ,1,009,0))
    oBrowse:SetColumns(HFXML16TIT("SERIE"   ,"SERIE"     ,11,""  ,1,003,0))
    oBrowse:SetColumns(HFXML16TIT("VNF"	    ,"Valor"	 ,12,"@E9999999",2,15,0))
    oBrowse:SetColumns(HFXML16TIT("XNOME"   ,"Emitente"	 ,13,"@!",1,030,0))
    oBrowse:SetColumns(HFXML16TIT("IE"      ,"IE EMIT"	 ,14,"@!",1,010,0))
    oBrowse:SetColumns(HFXML16TIT("DIGVAL"  ,"DIGEST VAL",15,"@!",1,010,0))
    oBrowse:SetColumns(HFXML16TIT("DHRECBTO","DT RECBTO ",16,"@D",1,008,0))
    oBrowse:SetColumns(HFXML16TIT("CSITNFE" ,"SIT NFE"   ,17,"@!",1,002,0))
    oBrowse:SetColumns(HFXML16TIT("NSU"     ,"NSU"       ,18,"@!",1,015,0))
    oBrowse:SetColumns(HFXML16TIT("Correcao","CARTA DE CORRECAO",19,"@!",1,015,0))
    oBrowse:SetColumns(HFXML16TIT("MSG"     ,"MENSAGEM"  ,20,"@!",1,015,0))
    oBrowse:SetColumns(HFXML16TIT("XML"     ,"XML"       ,21,"@!",1,015,0))
    oBrowse:SetColumns(HFXML16TIT("XMLCANC" ,"XML Cancel",22,"@!",1,015,0))
    oBrowse:SetColumns(HFXML16TIT("TOMA"    ,"TOMADOR CNPJ",23,"@!",1,014,0))

    //aAdd(aButtons,{          ,{ || HFXML06Pes(@oMarkBw, "TMP") }, "Pesquisar Registro", "Pesquisar"})
    oBrowse:AddButton("Processar"					, { || U_HFX16Dow( oBrowse,.T.) },,,, .F., 2 )
    oBrowse:AddButton("Certificado"					, { || U_HFX16Cer( oBrowse,.T.) },,,, .F., 2 )
    oBrowse:AddButton("Visualizar Registro"			, { || HFXML16Vis()},,,, .F., 2 )
    oBrowse:AddButton("Digitar Chaves"				, { || HFXML16Chv(,@oBrowse)},,,, .F., 2 )
    oBrowse:AddButton("Digitar CNPJ"				, { || HFXML16Cnp()},,,, .F., 2 )
    
	if GetNewPar("XM_DFEMAN","0") == "0"
		//oBrowse:AddButton("ManifestaÁ„o Destinat·rio",{ || U_HFX06man(@oBrowse)},,,, .F., 2 )
		oBrowse:AddButton("ManifestaÁ„o Destinat·rio",{ || HFXML16man(,,@oBrowse)},,,, .F., 2 )
    else
    	oBrowse:AddButton("ManifestaÁ„o Destinat·rio",{ || HFXML16man(,,@oBrowse)},,,, .F., 2 )
    endif
    
    oBrowse:AddButton("Editar NSU/Amb./Vers„o (NFe)", { || HFXML16NSU()},,,, .F., 2 )
    oBrowse:AddButton("Editar NSU/Amb./Vers„o (CTe)", { || HFXML16NSC()},,,, .F., 2 )
    oBrowse:AddButton("Par‚metros Eventos"          , { || HFXML16PAR()},,,, .F., 2 )
    oBrowse:AddButton("Filtrar Registro"			, { || HFXML16Fil(@oBrowse, cTMP_ZBS) },,,, .F., 2 )
    oBrowse:AddButton("Legenda"						, { || HFXML16Leg()},,,, .F., 2 )
    oBrowse:AddButton("Inverter"                    , { || HFXML16Inv(oBrowse:Mark(),.F.,@oBrowse )},,,, .F., 2 )
    oBrowse:AddButton("Marc Todos"                  , { || HFXML16Inv(oBrowse:Mark(),.T.,@oBrowse )},,,, .F., 2 )

    oBrowse:bAllMark := { || HFXML16Inv(oBrowse:Mark(),.F. ), oBrowse:Refresh(.T.)  }

    oBrowse:Activate()
    
    oBrowse:oBrowse:Setfocus() //Seta o foco na grade
 

//oFolder	:= TFolder():New(10,2,{"Chaves"},{},oDlg01,,,,.T.,.F.,aPosObj[1][4],aPosObj[2][3],)  //-aPosObj[2][1]

Return( .T. )


//Caso crie os botıes por funÁ„o, abaixo seque um exemplo
Static Function MenuDef()

Local aRot := {}

ADD OPTION aRot TITLE "Processar"                   ACTION "MsgRun('Processamdo Download','Download',{|| U_HFX16Dow() })"  OPERATION 6 ACCESS 0
ADD OPTION aRot TITLE "Certificado"                 ACTION "MsgRun('Processamdo Download','Download',{|| U_HFX16CER() })"  OPERATION 6 ACCESS 0
//ADD OPTION aRot TITLE "Visualizar Registro"         ACTION "HFXML16Vis()"  OPERATION 6 ACCESS 0

Return(Aclone(aRot))


USer Function HFX16Cer( oBrowse, lMostra )

Local nRet := 0

if oBrowse = NIL

	MsgRun('Verificando Certificado Digital .PFX','Certificado',{|| nRet := U_HFXMLCER( "2" ) })
Else
	MsgRun('Configurando Certificado Digital .PFX','Certificado',{|| nRet := U_HFXMLCER( "1" ) })

endif

Return( nRet )


//FunÁ„o para criar as colunas do grid
Static Function HFXML16TIT(cCampo,cTitulo,nArrData,cPicture,nAlign,nSize,nDecimal)

Local aColumn
Local bData 	:= {||}
Default nAlign 	:= 1
Default nSize 	:= 20
Default nDecimal:= 0
Default nArrData:= 0  

If nArrData > 0  //&gt;
	corelha := "{||" + cCampo +"}"
    bData := &corelha //&amp;("{||oBrowse:DataArray[oBrowse:At(),"+STR(nArrData)+"]}")
EndIf

/* Array da coluna
[n][01] TÌtulo da coluna
[n][02] Code-Block de carga dos dados
[n][03] Tipo de dados
[n][04] M·scara
[n][05] Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
[n][06] Tamanho
[n][07] Decimal
[n][08] Indica se permite a ediÁ„o
[n][09] Code-Block de validaÁ„o da coluna apÛs a ediÁ„o
[n][10] Indica se exibe imagem
[n][11] Code-Block de execuÁ„o do duplo clique
[n][12] Vari·vel a ser utilizada na ediÁ„o (ReadVar)
[n][13] Code-Block de execuÁ„o do clique no header
[n][14] Indica se a coluna est· deletada
[n][15] Indica se a coluna ser· exibida nos detalhes do Browse
[n][16] OpÁıes de carga dos dados (Ex: 1=Sim, 2=N„o)
*/
aColumn := {cTitulo,bData,,cPicture,nAlign,nSize,nDecimal,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}}

Return {aColumn}


/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Programa  ≥HFXML16Inv≥ Autor ≥ Eneo                  ≥ Data ≥23/11/2013≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Locacao   ≥ Parceiros        ≥Contato ≥ adilson.gomes@advbrasil.com.br ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Esta rotina ira marcar ou desmarcar as chaves.             ≥±±
±±≥          ≥                                                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥                                                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥                                                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒ¬ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Analista Resp.≥  Data  ≥ Bops ≥ Manutencao Efetuada                    ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥              ≥        ≥      ≥                                        ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Static Function HFXML16Inv(cMarcaOK,lMarkAll,oMkBr)

Local aGetArea	:= GetArea()
Local lMarcSim	:= .F.
Local nReg      := 0

Default oMkBr := NIL

If lMarkAll
	lMarcSim := Aviso( "Marcar/Desmarcar todos", "Deseja marcar ou desmarcar todos os tÌtulos?", { "Marcar", "Desmarcar" } ) == 1
EndIf

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ While para marcar ou desmarcar os produtos ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
nReg := (cTmp_ZBS)->( recno() )
(cTmp_ZBS)->( dbGotop() )

Do while (cTmp_ZBS)->( !EOF() )

	If lMarkAll
	
		RecLock(cTmp_ZBS, .F.)
		(cTmp_ZBS)->OK	:= if((cTmp_ZBS)->ST == "1", "  ", If(lMarcSim, cMarcaOK, "  ") )
		(cTmp_ZBS)->( MsUnLock() )
		
	Else
	
		If  (cTmp_ZBS)->OK == cMarcaOK
			RecLock(cTmp_ZBS, .F.)
			(cTmp_ZBS)->OK	:= "  "
			(cTmp_ZBS)->( MsUnLock() )
		Else
			RecLock(cTmp_ZBS, .F.)
			(cTmp_ZBS)->OK	:= if((cTmp_ZBS)->ST == "1", "  ", cMarcaOK )
			(cTmp_ZBS)->( MsUnLock() )
		EndIf
		
	EndIf

	(cTmp_ZBS)->( dbSkip() )
	
EndDo

(cTmp_ZBS)->( dbGoto( nReg ) )

if oMkBr <> NIL
	oMkBr:Refresh( .T. )
endif

RestArea( aGetArea )

Return


/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥HFXML06Dow≥ Autor ≥Eneovaldo Roveri Junior≥ Data ≥ 03/10/13 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥ Download das Chaves                                        ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ HFXML06Dow()                                               ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
User Function HFX16Dow(oMarkBw,lMostra) //oProcess

Local oRegua
Local nord := (cTmp_ZBS)->( indexord() )
Local nReg := (cTmp_ZBS)->( recno() )

oRegua := MsNewProcess():New({|lEnd| HFXML16Dow(@oMarkBw,@lEnd,@oRegua,lMostra)}, "Baixar...","Baixando XML ...",.T.)
oRegua:Activate()

(cTmp_ZBS)->( dbSetOrder( nord ) )
(cTmp_ZBS)->( dbgoto( nReg ) )

oMarkBw:Refresh( .T. )

Return( NIL )


Static Function HFXML16Dow(oMarkBw,lEnd,oRegua,lMostra,cLogProc)

Local aArea  := GetArea()
Local nReg   := (cTmp_ZBS)->( recno() )
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
Local cIdEnt := ""//U_GetIdEnt()
Local cDir   := AllTrim(SuperGetMv("MV_X_PATHX"))
Local a137   := {}
Local n137   := 0
Local cXml   := ""

Default oMarkBw     :=  NIL
Default lEnd		:=	.F.
Default oRegua		:=	Nil
Default lMostra		:=	.F.
Default cLogProc    := ""

Private aChave := {}
Private aNSU   := {} //Fadigando
Private pReg := 0
Private nDow := 0  //Coisa de Louco
Private nErr := 0  //Coisa de Louco
Private nMan := 0  //Coisa de Louco

if lMostra
	oRegua:SetRegua1( (cTmp_ZBS)->( RecCount() ))
	oRegua:SetRegua2(0)
Endif

(cTmp_ZBS)->( dbsetorder( 1 ) )
(cTmp_ZBS)->( dbgotop() )

Do While .not. (cTmp_ZBS)->( Eof() )

	//IncProc("Processando "+(cTmp_ZBS)->CHAVE)
	if lEnd
		MsgStop("*** Cancelado pelo Operador ***","Fim")
		Exit
	endif
	
	if lMostra
		oRegua:IncRegua1("Processando Download das Chaves")
		oRegua:IncRegua2((cTmp_ZBS)->CHAVE)
	endif

	if .not. empty( (cTmp_ZBS)->OK ) .and. (cTmp_ZBS)->ST <> "1" // == cMarcaOK
	
		If pReg == 0
			pReg := (cTmp_ZBS)->( Recno() )
		EndIf
		
		cCnpj  := (cTmp_ZBS)->DEST
		cIdEnt := iif( .Not. Empty((cTmp_ZBS)->IDENT), AllTrim((cTmp_ZBS)->IDENT), cIdEnt )
		lTem   := .T.
		
		if Substr((cTmp_ZBS)->CHAVE,21,2) $ "57,67"
			cChv57 += (cTmp_ZBS)->CHAVE+";"
			cNsu57 := (cTmp_ZBS)->NSU
		Else
			cChave += (cTmp_ZBS)->CHAVE+";"
			cNsu55 := (cTmp_ZBS)->NSU
		Endif
		
		aadd( aChave, (cTmp_ZBS)->CHAVE )
		aadd( aNSU  , (cTmp_ZBS)->NSU   )
		nChv++
		
		//if cAmb <> "1"
		cAmb := (cTmp_ZBS)->AMB
		cXml := (cTmp_ZBS)->XML
		//endif
		
		RecLock( cTmp_ZBS, .F. )
		(cTmp_ZBS)->OK := "Pr"
		(cTmp_ZBS)->( MsUnLock() )
		
	endif
	
	If nChv >= 1 .Or. ( nChv >= 1 .and. (cTmp_ZBS)->( Eof() ) )  //Antes ia de 10 em 10, mas agora com o Distr, N„o Da. Tem que ser 1 em 1
	 
	 If ! Empty(cChave)

	 	if upper("<resNFe ") $ upper( cXml )

			nRet := HFXML16Bai("55",cCnpj,cChave,cAmb,cIdEnt,.T.,lMostra,@cLogProc)

		else

			nRet := HFXML16B55(cCnpj,cChave,cAmb,cIdEnt,cNsu55,@cLogProc,lMostra,.T.)

		endif
		
		If nRet == 3  //Refazer, mas no DFE da HF.
		
			Sleep(1500) //da 1 segundo e vai de novo
			
			nRet := HFXML16B55(cCnpj,cChave,cAmb,cIdEnt,cNsu55,@cLogProc,lMostra,.T.)
			
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
	 
		nRet := HFXML16B57(cCnpj,cChv57,cAmb,cIdEnt,@cLogProc)
		
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

	(cTmp_ZBS)->( dbskip() )
	
Enddo

if .Not. lTem

	RestArea(aArea)
	
	(cTmp_ZBS)->( dbgoto( nReg ) )
	
	if lMostra
		U_MyAviso("Msg","Nenhuma chave selecionada para download !!!!",{"OK"},3)
		oMarkBw:oBrowse:Refresh(.T.)
	endif
	
	return( nRet )
	
endif

if xRet == 1  //Tem Chaves para Manifestar

	if lMostra
	
		oMarkBw:oBrowse:Refresh(.T.)
		
		if U_MyAviso("Pergunta","Existem Chaves sem ManifestaÁ„o. Deseja Manifesta-las e tentar o Download Novamente?",{"SIM","NAO"},2) == 1
			
			oRegua:IncRegua1("Processando ManifestaÁ„o das Chaves")
			oRegua:IncRegua2(Space(44))
			
			Do While .Not. HFXML16Man( .T., @nEve )
				if lEnd
					MsgStop("*** Cancelado pelo Operador ***","Fim")
					Exit
				endif
			EndDo
			
			oMarkBw:oBrowse:Refresh(.T.)
			nMan := 0
			//nDow := 0
			//nErr := 0
	
			oRegua:SetRegua1( (cTmp_ZBS)->( RecCount() ))
			oRegua:SetRegua2(0)
			
			(cTmp_ZBS)->( dbgotop() )
			
			Do While .not. (cTmp_ZBS)->( Eof() )
			
				if lEnd
					MsgStop("*** Cancelado pelo Operador ***","Fim")
					Exit
				endif
				
	//			IncProc("Processando "+(cTmp_ZBS)->CHAVE)
				oRegua:IncRegua1("Processando Download das Chaves Novamente")
				oRegua:IncRegua2((cTmp_ZBS)->CHAVE)
				
				if .not. empty( (cTmp_ZBS)->OK ) // == cMarcaOK
				
					If pReg == 0
						pReg := (cTmp_ZBS)->( Recno() )
					EndIf
					
					cCnpj  := (cTmp_ZBS)->DEST
					cIdEnt := iif( .Not. Empty((cTmp_ZBS)->IDENT), AllTrim((cTmp_ZBS)->IDENT), cIdEnt )
					lTem   := .T.
					
					if Substr((cTmp_ZBS)->CHAVE,21,2) $ "57,67"
						//aqui n„o tem CTE sÛ NFE
					Else
						cChave += (cTmp_ZBS)->CHAVE+";"
						cNsu55 := (cTmp_ZBS)->NSU
					Endif
					
					nChv++
					
					if cAmb <> "1"
						cAmb := (cTmp_ZBS)->AMB
					endif
					
					RecLock( cTmp_ZBS, .F. )
					(cTmp_ZBS)->OK := "Pr"
					(cTmp_ZBS)->( MsUnLock() )
					
				endif
				
				(cTmp_ZBS)->( dbskip() )
				
				If nChv >= 1 .Or. ( nChv >= 1 .and. (cTmp_ZBS)->( Eof() ) )
				
					nRet := HFXML16Bai("55",cCnpj,cChave,cAmb,cIdEnt,.F.,lMostra,@cLogProc) 
					
					If nRet == 3 .or. nRet == 1  //Refazer
					
						Sleep(1500) //da 1 segundo e vai de novo
						
						nRet := HFXML16B55(cCnpj,cChave,cAmb,cIdEnt,cNsu55,@cLogProc,lMostra)
						
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
		
	endif
	
	nErr += nMan
	
endif

if Len(a137) > 0  .and. lMostra

	oMarkBw:oBrowse:Refresh(.T.)
	
	if U_MyAviso("Pergunta","Existem Chaves n„o encontradas (137) que podem existir na SEFAZ. Deseja fazer o Download, dessas chaves, Novamente?",{"SIM","NAO"},2) == 1
	
		DbSelectArea(cTmp_ZBS)
		(cTmp_ZBS)->(dbSetOrder(1))
		(cTmp_ZBS)->( dbgotop() )
//		ProcRegua( Len(a137) )

		oRegua:SetRegua1( Len(a137) )
		oRegua:SetRegua2(0)
		
		For n137 := 1 To Len(a137)
		
			//IncProc("Processando "+a137[n137])
			if lEnd
				MsgStop("*** Cancelado pelo Operador ***","Fim")
				Exit
			endif
			
			oRegua:IncRegua1("Processando Download das Chaves")
			oRegua:IncRegua2( a137[n137][1] )
			
			(cTmp_ZBS)->( DbSeek( a137[n137][1] ) )
			
			pReg   := (cTmp_ZBS)->( Recno() )
			cCnpj  := (cTmp_ZBS)->DEST
			cIdEnt := iif( .Not. Empty((cTmp_ZBS)->IDENT), AllTrim((cTmp_ZBS)->IDENT), cIdEnt )
			cAmb   := (cTmp_ZBS)->AMB
			cChave := a137[n137][1]
			cNsu55 := a137[n137][2]
			
			nRet   := HFXML16Bai("55",cCnpj,cChave,cAmb,cIdEnt,.F.,lMostra,@cLogProc)
			
			If nRet == 3 //Refazer
			
				Sleep(1500) //da 1 segundo e vai de novo

				nRet := HFXML16B55(cCnpj,cChave,cAmb,cIdEnt,cNsu55,@cLogProc,lMostra)   //HFXML06Bai(cCnpj,cChave,cAmb,cIdEnt)
				
			Endif
			
		Next n137
		
	Endif
	
Endif

if !lEnd

	if lMostra
	
		If yRet == 1  //Tem Chaves CTe n„o encontrada
		
			oMarkBw:oBrowse:Refresh(.T.)
			U_MyAviso("AtenÁ„o - CTE","Existem Chaves CTe n„o encontrada. Execute rotina de Download por CNPJ dos CTEs?", {"OK"},2)
		
		Endif
		
		If nDow == 0 .and. nErr > 0
		
			U_MyAviso("Msg","OperaÁ„o com erros, verifique as Mensagens.",{"OK"},3)
			
		Elseif nErr == 0
		
			U_MyAviso("Msg","OperaÁ„o concluida com exito, verifique as Mensagens e os arquivos baixados na pasta "+cDir+".",{"OK"},3)
		
		Else
		
			U_MyAviso("Msg","OperaÁ„o concluida com alguns erros, verifique as Mensagens e os arquivos baixados na pasta "+cDir+".",{"OK"},3)
		
		endif
		
	endif
	
Endif

RestArea( aArea )

(cTmp_ZBS)->( dbgoto( nReg ) )

if lMostra
	oMarkBw:oBrowse:Refresh(.T.)
endif

Return( NIL )

//Retorna 0 - OK
//Retorna 1 - Tem alguma manifestaÁıes para fazer
//Retorna 2 - SÛ Erro
//Renorna 3 - 137-NENHUM DOCUMENTO LOCALIZADO, sÛ para fazer duplamente, tem que mandar esse bixo como 1 tambÈm
Static Function HFXML16Bai(cMod,cCnpj,cChave,cAmb,cIdEnt,lMnf,lMostra,cLogProc)

Local nReg   := (cTMP_ZBS)->( recno() )
Local nRet   := 0
//Local cURL   := ""
//Local cDir   := AllTrim(SuperGetMv("MV_X_PATHX"))
//Local cXml   := ""
Local cInfo  := ""
//Local cLog   := ""
Local cMsg   := ""
Local l137   := .F.
Local cStt   := ""
//Local nHandle:= 0
//Local lOk    := .T.
//Local cVerLayEven := "1.00"
//Local cHrVerao    := "2"
//Local cHorario    := "2"
//Local nI := 0 //declaracao
Local lHF := .T.
Local cSt := "", xSt := ""
Local cSitConf  := ""
Local cChaveXml := ""
Local cNf       := ""
Local cSer      := ""
Local cCnpjXml  := ""
Local cRej      := ""
Local cExt      := ""
Local lManifestou := .F.
//Local aChv      := {}
//Local xMotMn    := ""

Default cLogProc  := ""
Default lMnf := .F.
Default lMostra := .F.

Private cMsgTag := ""

if lMnf

	If GetNewPar("XM_MANAUT","N") == "S"
	
		//if GetNewPar("XM_DFEMAN","0") == "0"
		
		nRet := U_HF2MFXml( Substr(cChave,1,44), "210210", @cRej, "", 4 )  //aqui ja tem as duas versıes
		
		if nRet == 0
			lManifestou := .T.
		endif
		
		//else
		//	aChv := {}
		//	aadd(aChv, {Substr(cChave,1,44), "" } )  //Chave e Justificativa (justifica para quando for 210240)
		//	cLog  := ""
		//	cInfo := ""
		//	xMotMn:= ""
		//	if U_HFXMLMAN( aChv, "210210", , , @cRej,@xMotMn,@cLog,@cInfo, ,.F. )  //cVerMn:= GetNewPar("XM_XVERMAN","4.00")
			   //HFXMLMAN(aChaves,cEveMn,cDesEven,cVerMn,cRetMn,xMotMn,cLog,cInfo,aRet,lMostra)
		//		lManifestou := .T.
		//	endif
		//	if !Empty(cLog)
		//		cLogProc += cLog 
		//	endif
		//endif
		//Alert( cRej )
		
	endif
	
endif

Private oWs,oWsrNfe,oWsdNfe,cErro,cWarning

if lHF

	cChaveXml := substr(cChave,1,44)
	cChaveArq := U_HFBxXML(cMod,"DC",cChaveXml,@cExt,@cMsg,@cInfo,@l137,lMostra,NIL)
	//alert(cChaveArq)
	//alert(cExt)
	//alert(cMsg)
	//alert(cInfo)

	//aqui a funÁ„o
	nRet   := 2
    nOrd   := (xZBZ)->( IndexOrd() )
    cSitConf  :=  iif( "RES" $ upper(cExt), "0", "4" ) //manifver(substr(cChaveXml,1,44),cURL,cIdEnt,cAmb)  //"4"
	cNf       := Substr( cChaveXml, 26, 9 )
	cSer      := Substr( cChaveXml, 23, 3 )
	cCnpjXml  := Substr( cChaveXml, 07, 14 )
	xSt := ""
	
	( xZBZ )->( DbSetOrder( 3 ) )
	
	If ( xZBZ )->(dbSeek( cChaveXml ) )
	
		cSt := "10"
		
		if "653" $ cMsg
			cSt := "11"
		endif
		
	Elseif l137
	
		nRet := 3
		cSt := "99"
		
	Elseif "653" $ cMsg
	
		cSt := "21"
		
	Else 
	
		cSt := "20"
		
	Endif
	
	( xZBZ )->( DbSetORder( nOrd ) )
	( xZBS )->( DbSetOrder( 3 ) )
	
	If ( xZBS )->(dbSeek( cChaveXml ) )
	
		if Empty( ( xZBS )->(FieldGet(FieldPos(xZBS_+"DEMI"))) ) .OR. ( xZBS )->(FieldGet(FieldPos(xZBS_+"DEMI"))) < (dDataBase - 90)
			if cSt == "99"  //N„o aparecer, È muito velho o Bixo
				cSt := ( xZBS )->(FieldGet(FieldPos(xZBS_+"ST")))
			endif
		Endif
		
		xSt := ( xZBS )->(FieldGet(FieldPos(xZBS_+"ST")))
		
	EndIf
	
	nHdl := 0
	
	If cSt <> xSt .And. U_HFTrvXml("TRAVA", "ZBS"+cChaveXml, @nHdl)
	
		( xZBS )->( DbSetOrder( 3 ) )
		
		If .Not. ( xZBS )->(dbSeek( cChaveXml ) )
		
			RecLock(xZBS, .T. )
			
			( xZBS )->(FieldPut(FieldPos(xZBS_+"FILIAL"), XFilial(xZBS) ))  
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
		
		if cSt $ "11,21" 
			( xZBS )->(FieldPut(FieldPos(xZBS_+"CSITNF"), "3" ))
		endif
		
		( xZBS )->(MsUnLock())
		
		//alert(cSt)
		U_HFTrvXml("SOLTA", "ZBS"+cChaveXml, nHdl) //SOLTAR
		
	Endif
	
	if ! Empty(cChaveArq)
	
		//cChaveArq := cDir + cChaveArq //alltrim( oDet[nI]:_CHNFE:TEXT ) + "-procNfe.xml"
		cTpDow := iif( "RES" $ upper(cExt), "R", "" )
		//alert(cTpDow)
		
		if ! slvxmlzbz(cChaveArq, .T.,.F.,NIL,@cLogProc,0, "2", Substr(cChave,1,44), @cInfo, cTpDow )  //2=Downlaod Sefaz
			
			cStt := "0"
			cMsg  := "Erro na ImportaÁ„o"
			
		else
		
			cStt := "1"
			
		endif
		
	elseif "653" $ cMsg
	
		//Baixar as Canceladas
		nRet := U_HFXMLCAN(cCnpj,cChave,cAmb,cIdEnt,"",@cLogProc,lMostra,@cInfo)
		
		if nRet > 0
		
			cStt := "0"
			
		else
		
			cStt := "1"
			cMsg  := "XML cancelado inserido com sucesso"
			
		endif
		
	else
	
		cStt := "0"
		
	endif
	
	nOrd := (cTMP_ZBS)->(indexord())
	
	(cTMP_ZBS)->( dbSetORder( 1 ) )	
	
	If (cTMP_ZBS)->(dbSeek( Substr(cChave,1,44) ) )
	
			if "633" $ alltrim(cMsg)  //Falta de ManifestaÁ„o
				nRet := 1
			endif
			
			if cStt <> "1" .and. nRet <> 1
				nRet := 2
			endif
			
			RecLock( cTMP_ZBS, .F. )
			
			if .NOT. ("633" $ alltrim(cMsg) )  //Deixa marcado
				(cTMP_ZBS)->OK    := "  "
			endif
			
			(cTMP_ZBS)->ST    := cStt
			(cTMP_ZBS)->MSG   := cMsg
			(cTMP_ZBS)->ERRO  := cInfo
			(cTMP_ZBS)->( MsUnLock() )
			
	endif
	
	(cTMP_ZBS)->( dbSetORder( nOrd ) )
	
	//DelClassIntf()
	
	if cStt == "1" 
	
		cLogProc += "Download Efetuado "+cChaveXml+CRLF
		nDow++  //Coisa de Louco
		
	else
	
		cLogProc += "Err:"+cChaveXml+" => "+AllTrim(cInfo)+" = "+AllTrim(cMsg)+CRLF
		nErr++  //Coisa de Louco
		
	endif

Else

Endif

(cTMP_ZBS)->( dbgoto( nReg ) ) //Volta ao Registro para dar continuidade

//DelClassIntf()

return( nRet )



//Tentar Baixar o 57
//Retorna 0 - OK
//Retorna 1 - N„o encontrou, tem que fazer o NFeDistr
//Retorna 2 - Encontrou na ZBS mas n„o conseguiu fazer o bixo
Static Function HFXML16B57(cCnpj,cChave,cAmb,cIdEnt,cLogProc)

Local nReg   := (cTMP_ZBS)->( recno() )
Local nOrd   := 0
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

Default cLogProc := ""

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
			cInfo := "Erro de GravaÁ„o XML no DiretÛrio "+cChaveArq
			
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

	cLogProc += "Download Efetuado "+cChave+CRLF
	nDow++
	
else

	cLogProc += "Err:"+cChave+" => "+AllTrim(cInfo)+" = "+AllTrim(cMsg)+CRLF
	nErr++
	
endif

nOrd := (cTMP_ZBS)->(indexOrd())

(cTMP_ZBS)->( dbSetORder(1) )

If (cTMP_ZBS)->(dbSeek( Substr(cChave,1,44) ) )

	if cStt <> "1" .and. nRet <> 1
		nRet := 2
	endif
	
	RecLock( cTMP_ZBS, .F. )
	
	(cTMP_ZBS)->ST    := cStt
	(cTMP_ZBS)->MSG   := cMsg
	(cTMP_ZBS)->ERRO  := cInfo
	(cTMP_ZBS)->( MsUnLock() )
		
endif

//DelClassIntf()

(xZBS)->(RestArea( aAreaZBS ))

(cTMP_ZBS)->( dbSetORder(nOrd) )
(cTMP_ZBS)->( dbgoto( nReg ) ) //Volta ao Registro para dar continuidade

//DelClassIntf()

return( nRet )




//Tentar Baixar o 55 da ZBS
//Retorna 0 - OK
//Retorna 1 - N„o encontrou ou sem ManifestaÁ„o, tem que fazer o NFeDistr
//Retorna 2 - Encontrou na ZBS mas n„o conseguiu fazer o bixo
Static Function HFXML16B55(cCnpj,cChave,cAmb,cIdEnt,cNsu,cLogProc,lMostra,lManif)

Local nReg   := (cTMP_ZBS)->( recno() )
Local nOrd   := 0
Local nRet   := 1
Local nChv   := 0
Local cDir   := AllTrim(SuperGetMv("MV_X_PATHX"))
Local cXml   := ""
Local cInfo  := ""
Local cMsg   := ""
Local cStt   := ""
Local nHandle:= 0
//Local lOk    := .T.
Local aAreaZBS := (xZBS)->( GetArea() )
Local cRej   := ""

Default cLogProc := ""
Default lMostra  := .F.
Default lManif   := .F.

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

							nRetManif := U_HF2MFXml( Substr(cChave,1,44), "210210", @cRej, "", 4 )

							Conout("Manifestacao realizada " + Substr(cChave,1,44))

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
		//Alert( "Vai por NSU "+cNsu )
		//U_HFDOWDFE( cCnpj,cChave,cAmb,cIdEnt,cNsu,@cLogProc )   //Pedir ao SEFAZ por NSU
		//Loop
	Endif
	
	Exit
	
EndDo

if nRet == 0 .or. nRet == 1  //.And. !Empty( cXml )

	if nRet == 1
		cChaveArq := cDir + Substr(cChave,1,44) + "-resuNFe.xml"
	else
		cChaveArq := cDir + Substr(cChave,1,44) + "-procNFe.xml"
	endif
	
	if Len(cXml) >= 65534
		oXML := U_PARSGDE( cXml, @cErro, @cWarning )
	Else
		oXml := XmlParser( cXml, "_", @cErro, @cWarning )
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
			cInfo := "Erro de GravaÁ„o XML no DiretÛrio "+cChaveArq
		else
			cStt  := "1"
			cMsg  := "Download Efetuado"
			cInfo := "Download Efetuado do XML "+Substr(cChave,1,44)
			Conout("Download Efetuado do XML "+Substr(cChave,1,44))
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

nOrd := (cTMP_ZBS)->( indexOrd() )

(cTMP_ZBS)->( dbSetOrder( 1 ) )

If (cTMP_ZBS)->(dbSeek( Substr(cChave,1,44) ) )

	if cStt <> "1" .and. nRet <> 1
		nRet := 2
	endif
	
	RecLock( cTMP_ZBS, .F. )
	
	(cTMP_ZBS)->ST    := cStt
	(cTMP_ZBS)->MSG   := cMsg
	(cTMP_ZBS)->ERRO  := cInfo
	(cTMP_ZBS)->( MsUnLock() )
		
endif

DelClassIntf()

(xZBS)->(RestArea( aAreaZBS ))

(cTMP_ZBS)->( dbSetOrder( nOrd ) )
(cTMP_ZBS)->( dbgoto( nReg ) ) //Volta ao Registro para dar continuidade

//DelClassIntf()

return( nRet )


/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥HFXML16Chv≥ Autor ≥Eneovaldo Roveri Junior≥ Data ≥ 07/07/19 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥ Download das Chaves                                        ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ HFXML16Chv()                                               ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function HFXML16Chv(nChv,oBrowse)

Local oDlgKey, oBtnOut, oBtnCon
//Local cIdEnt    := ""
Local cChaveXml := iif(nChv==NIL .or. nChv>0, space( len((cAli_ZBS)->CHAVE) ), Substr(AllTrim((xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))))+space(len((cAli_ZBS)->CHAVE)),1,len((cAli_ZBS)->CHAVE)) )
Local cModelo   := Substr(cChaveXml,21,2)  //modelo
//Local cProtocolo:= ""
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
Local xManif    := "" //GETESB2

Default nChv    := 0
Default oBrowse := NIL
Default lTela   := .T.

cURL    := AllTrim(GetNewPar("XM_URL",""))

If Empty(cURL)
	cURL  := AllTrim(SuperGetMv("MV_SPEDURL"))
EndIf

//Valida quantidade de requisiÁıes
U_HFXML071(cChaveXml)
	
If !lConsReq

	lRet := .F.
	Return(lRet)

EndIf

If cModelo == "55"

 	cPref   := "NF-e"                             
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

DEFINE MSDIALOG oDlgKey TITLE "Consulta "+cPref FROM 0,0 TO 150,305 PIXEL OF GetWndDefault()

@ 12,008 SAY "PrÛxima Chave de acesso do xml de "+cPref PIXEL OF oDlgKey
@ 20,008 MSGET cChaveXml SIZE 140,10 PIXEL OF oDlgKey

@ 46,035 BUTTON oBtnCon PROMPT "&Incluir" SIZE 38,11 PIXEL ACTION (lRet:=.T.,oDlgKey:End())
@ 46,077 BUTTON oBtnOut PROMPT "&Sair" SIZE 38,11 PIXEL ACTION (lRet:=.F.,oDlgKey:End())

ACTIVATE DIALOG oDlgKey CENTERED

If lRet

	if len( AllTrim( cChaveXml ) ) == len((cAli_ZBS)->CHAVE)
		
		//MsgRun("Aguarde. Consultando Chave Sefaz...","Consultando Chave Sefaz",{|| lValidado := U_XConsXml(cURL,cChaveXml,cModelo,cProtocolo,@cMensagem,@cCodRet,.F.,@xCnpj,@xIdEnt,,.F.) } )
		MsgRun("Aguarde. Consultando Chave Sefaz...","Consultando Chave Sefaz",{|| lValidado := u_NFeConsProt( cChaveXml, .T., @cCodRet, @xManif ) } )

	else
	
		cMensagem := "Chave deve conter 44 Characteres"
		cCodRet   := ""
		
	endif
	
EndIf

if cCodRet $ AllTrim(GetNewPar("XM_RETOK","526"))+",100,101"

	if .not. (cAli_ZBS)->( dbSeek( cChaveXml ) )
	
		if "HomologaÁ„o" $ cMensagem
			cAmb := "2"
		endif
		
		RecLock( (cAli_ZBS), .T. )
		
		(cAli_ZBS)->ST    := " "
		(cAli_ZBS)->CHAVE := cChaveXml
		(cAli_ZBS)->AMB   := cAmb
		(cAli_ZBS)->DEST  := iif( empty(xCnpj), SM0->M0_CGC, xCnpj ) //SM0->M0_CGC
		(cAli_ZBS)->CNF   := Substr(cChaveXml,26,9)
		(cAli_ZBS)->SERIE := Substr(cChaveXml,23,3)
		(cAli_ZBS)->IDENT := xIdEnt
		(cAli_ZBS)->( MsUnLock() )
		
		nChv++
		
		//U_MyAviso("Msg","Chave incluida com sucesso ",{"OK"},1)
	else
	
		U_MyAviso("AtenÁ„o","Chave J· IncluÌda",{"Continua"},1)
		
	endif
	
else

	if lRet
	
   		U_MyAviso("Erro",cMensagem+CRLF+;
			"Cod. Retorno "+cCodRet,{"Continua"},3)
			
	endif
	
endif

if oBrowse <> NIL
	oBrowse:Refresh(.T.)
endif

return( lRet )


/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥HFXML16X≥ Autor ≥Rogerio Lino≥ Data ≥ 16/12/2020 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥ Consulta Chave e atualiza o Status do XML dos Fornecedores                                   ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ HFXML16X()                                               ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
User Function HFXML16X( cAlias,nReg,nOpcX,lTela,lAuto )

Local aArea     := GetArea()
Local oDlgKey, oBtnOut, oBtnCon
//Local cIdEnt    := ""
Local cChaveXml := AllTrim( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))) )
Local cModelo   := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO")))
//Local cProtocolo:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"PROT")))
//Local dDtNfe    := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"DTNFE")))
Local cMensagem := ""
//Local lRet      := .T.
Local cPref     := "NF-e"                             
Local cTAG      := "NFE"
Local cCodRet   := ""
Local xManif    := "" //GETESB2

Default lTela   := .T.
Default lAuto   := .F.
Default cURL    := AllTrim(GetNewPar("XM_URL",""))

If Empty(cURL)

	cURL  := AllTrim(SuperGetMv("MV_SPEDURL"))
	
EndIf

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

If lTela

	DEFINE MSDIALOG oDlgKey TITLE "Consulta "+cPref FROM 0,0 TO 150,305 PIXEL OF GetWndDefault()
	
	@ 12,008 SAY "Informe a Chave de acesso do xml de "+cPref PIXEL OF oDlgKey
	@ 20,008 MSGET cChaveXml SIZE 140,10 PIXEL OF oDlgKey //READONLY
	
	@ 46,035 BUTTON oBtnCon PROMPT "&Consultar" SIZE 38,11 PIXEL ;
	ACTION (lValidado := u_NFeConsProt( cChaveXml, .T., @cCodRet, xManif ),oDlgKey:End())
	@ 46,077 BUTTON oBtnOut PROMPT "&Sair" SIZE 38,11 PIXEL ACTION oDlgKey:End()
	
	ACTIVATE DIALOG oDlgKey CENTERED

Else

	if lAuto

		lValidado := u_NFeConsProt( cChaveXml, .F., @cCodRet, @xManif )

	Else

		MsgRun("Aguarde. Consultando Chave Sefaz...","Consultando Chave Sefaz",{|| lValidado := u_NFeConsProt( cChaveXml, .F., @cCodRet, @xManif ) } )

	Endif

Endif

If !Empty(cCodRet)

	U_XMLSETCS(cModelo,cChaveXml,cCodRet,cMensagem,xManif) 

EndIf

If !lTela .And. !Empty(cMensagem)

	U_myAviso("Importa Xml",cMensagem,{"OK"},3)

Endif

RestArea( aArea )

Return



/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥HFXML16Cnp≥ Autor ≥Eneovaldo Roveri Junior≥ Data ≥ 23/05/14 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥ CNPJ para consulta                                         ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ HFXML16Cnp()                                               ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function HFXML16Cnp()

Local oDlgKey, oBtnOut, oBtnCon
Local lRet      := .T.
Local lValidado := .T.
Local cCnpj     := "" //SM0->M0_CGC
Local cKeyF3    := SetKEY( VK_F3 ,  Nil )
Local nOpc      := 0 //aquiiiii
Local nMod      := 0 //Escolher 55-Nfe ou 57-Cte
Local cMod      := ""
Local oProcess	:=	Nil
Local cBkpFil   := ""
Local cEmp0     := cEmpAnt
Local cFil0     := cFilAnt
Local nReg0     := SM0->( recno() )

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

	//Aqui mudado em 23/7 para escolher o Cte ou NFe
	nMod := U_MyAviso("Modelo","Qual Modelo?",{"1-NF-e","2-CT-e"},3)

    if nMod == 1 .or. nMod == 2
    
    	cMod := iif( nMod == 1, "55", iif( nMod == 2, "57", "  " ) )
    	cDMo := iif( nMod == 1, "NF-e", iif( nMod == 2, "CT-e", "  " ) )
	    nOpc := U_MyAviso("OpÁ„o","1-Todos a partir do ultimo NSU "+CRLF+"2-SÛ N√O importados a partir do ultimo NSU",{"1-Todos","2-N„o Importados"},3)
    	
    	if nOpc == 1 .or. nOpc == 2
    	
			oProcess := MsNewProcess():New({| lEnd | lValidado := U_HFXM16CD(cMod, cCnpj, .T., , nOpc, 0, @lEnd, oProcess)},"Aguarde. Consultando Cnpj ("+cDMo+") Sefaz...","Consultando Cnpj ("+cDMo+") Sefaz",.T.)
			oProcess:Activate()
			lRet := lValidado
			
		Endif
		
		oProcess := MsNewProcess():New({| lEnd | lValidado := U_HFXM16BS(cCnpj, .T., , nOpc, cMod, @lEnd, oProcess, .F.)},"Aguarde. Consultando XMLs a Sincronizar "+xZBS+"...","Consultando XMLs a Sincronizar",.T.)
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
			
endif

SetKEY( VK_F3 ,  cKeyF3 )

return( lRet )



/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥HFXML16Man≥ Autor ≥Eneovaldo Roveri Junior≥ Data ≥ 31/10/13 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥ ManifestaÁ„o do Destinatario                               ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ HFXML16Man()                                               ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function HFXML16Man( lBai, nEve, oBrowse )

Local nReg   := (cTMP_ZBS)->( recno() )
Local lRet   := .F.
//Local cChave := ""
//Local cEvent := ""
Local cEve   := "210200"
Local cJust  := Space(255)  //AQUIII
Local nChv   := 0
//Local cXml   := ""
Local cInfo  := ""
Local cMsg   := ""
Local cStt   := ""
Local lTodos := .F.
//Local lOk    := .T.
Local lTemPr := .F.
Local nAtraso := 0
Local lLoop   := .F.
Local aChave  := {}
Local aRet    := {}
Local nI      := 0 //declaracao
Local cRej    := ""
Local xMotMn  := ""
Local lRefr   := .F.

Private oDet //ZBEMANO

if oBrowse == NIL
	lRefr   := .F.
else
	lRefr   := .T.
endif

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

(cTMP_ZBS)->( dbgotop() )

Do While .not. (cTMP_ZBS)->( Eof() ) .and. nChv < 10

	if .not. empty( (cTMP_ZBS)->OK ) .And. (cTMP_ZBS)->OK <> "Pt" // == cMarcaOK
	
		cCnpj  := (cTMP_ZBS)->DEST
		cJust  := ""
		
		if cEve == "210240" //AQUIIII
		
			cJust := space(255)
			cJust := U_TelaJust( (cTMP_ZBS)->CHAVE, cJust )  //GETESB2
			
			if cJust == "-1"
				exit
			endif
			
		Else
		
			cJust := ""
			
		Endif
		
		aadd( aChave,{ (cTMP_ZBS)->CHAVE, cJust } )

		nChv++
		RecLock( cTMP_ZBS, .F. )
		
		(cTMP_ZBS)->OK := "Pt"
		(cTMP_ZBS)->( MsUnLock() )
		
	endif
	
	(cTMP_ZBS)->( dbskip() )
	
Enddo

if cJust == "-1" //AQUIIII

	if .not. lBai
	
		U_MyAviso("Msg","OperaÁ„o cancelada por falta de justificativa!!!!",{"OK"},3)
	endif
	
	(cTMP_ZBS)->( dbgoto( nReg ) )
	
	Return( lRet )
	
endif


if nChv <= 0

	if .not. lBai
	
		U_MyAviso("Msg","Nenhuma chave selecionada para Manifestar !!!!",{"OK"},3)
	
	endif
	
	(cTMP_ZBS)->( dbgoto( nReg ) )
	
	return( .T. )
	
endif

For nAtraso := 0 to 4

	cLog  := ""
	cInfo := ""
	cRej  := ""
	xMotMn:= ""
	aRet  := {}
	
	if U_HFXMLMAN( aChave, cEve, , , @cRej,@xMotMn,@cLog,@cInfo, @aRet, .F., nAtraso )  //cVerMn:= GetNewPar("XM_XVERMAN","4.00")
	  
	   //HFXMLMAN(aChaves,cEveMn,cDesEven,cVerMn,cRetMn,xMotMn,cLog,cInfo,aRet,lMostra, nAtraso)
		lTodos := .F.
		
	else
	
		If (cRej $ "578,579,703,000" .And. nAtraso < 4 )
			Loop
		EndIf
		
		cMsg   := "[SFZ]"+cRej
		lTodos := .T.
		
	endif
	
	if .NOT. lTodos
	
		For nI := 1 To Len( aRet )
		
			if aRet[nI][3] <> "135"
			
				if ( aRet[nI][3] $ "578,579,703,000"  .And. nAtraso < 4 )
					
					lLoop:= .T.
					Loop
					
				Else
				
					cMsg  := "[SFZ]"+aRet[nI][3]
					cInfo := aRet[nI][4]
					
					if ("573" $ aRet[nI][3])
					
						cStt  := "2"
						
					else 
					
						cStt  := "0"
						
					endif
					
				EndIF
				
			else
			
				cMsg  := "[SFZ]"+aRet[nI][3]
				cInfo := aRet[nI][4]
				cStt  := "1"
				
			Endif
			
			DbSelectArea( cTMP_ZBS )
			
			If (cTMP_ZBS)->(dbSeek( aRet[nI][1] ) )
			
				RecLock( cTMP_ZBS, .F. )
				
				if (cStt <> "2" .And. .not. ("573" $ aRet[nI][3]) ) .or. .not. lBai
					(cTMP_ZBS)->OK    := "  "
				endif
				
				(cTMP_ZBS)->ST    := cStt
				(cTMP_ZBS)->MSG   := cMsg
				(cTMP_ZBS)->ERRO  := cInfo
				(cTMP_ZBS)->( MsUnLock() )
				
			endif
			
		Next nI		
		
		if lLoop
		
			Loop
			
		Endif
		
	endif
	
	Exit
	
Next nAtraso

if lTodos

	DbSelectArea( cTMP_ZBS )
	
	(cTMP_ZBS)->( dbgotop() )
	
	Do While .not. (cTMP_ZBS)->( Eof() )
	
		if (cTMP_ZBS)->OK == "Pt" // == cMarcaOK
		
			RecLock( cTMP_ZBS, .F. )
			(cTMP_ZBS)->OK    := "  "
			(cTMP_ZBS)->ST    := "0"
			(cTMP_ZBS)->MSG   := cMsg
			(cTMP_ZBS)->ERRO  := cInfo
			(cTMP_ZBS)->( MsUnLock() )
			
		endif
		
		if (cTMP_ZBS)->OK == "Pr" // == cMarcaOK
		
			lTemPr := .T.
			
		endif
		
		(cTMP_ZBS)->( dbskip() )
		
	Enddo
	
else

	if .not. lBai
	
		U_MyAviso("Msg","OperaÁ„o concluida, verifique as Mensagens.",{"OK"},3)
		
	Else
	
		(cTMP_ZBS)->( dbgotop() )
		
		Do While .not. (cTMP_ZBS)->( Eof() )
		
			if (cTMP_ZBS)->OK == "Pr" // == cMarcaOK
				
				lTemPr := .T.
				
			endif
			
			(cTMP_ZBS)->( dbskip() )
			
		Enddo
		
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

(cTMP_ZBS)->( dbgoto( nReg ) )

if lRefr

	if oBrowse <> NIL
		oBrowse:Refresh(.T.)
	endif
	
endif

return( lRet )

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥NoAcento  ∫ Autor ≥ Roberto Souza      ∫ Data ≥  07/10/11   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Retira caracteres especiais.                               ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Importa Xml                                                ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Static Function NoAcento(cString)

Local cChar  := ""
Local nX     := 0 
Local nY     := 0
Local cVogal := "aeiouAEIOU"
Local cAgudo := "·ÈÌÛ˙"+"¡…Õ”⁄"
Local cCircu := "‚ÍÓÙ˚"+"¬ Œ‘€"
Local cTrema := "‰ÎÔˆ¸"+"ƒÀœ÷‹"
Local cCrase := "‡ËÏÚ˘"+"¿»Ã“Ÿ" 
Local cTio   := "„ı"
Local cCecid := "Á«"
//Local lChar  := .F.

For nX:= 1 To Len(cString)

	cChar := SubStr(cString, nX, 1)
	
	IF cChar $ cAgudo+cCircu+cTrema+cCecid+cTio+cCrase
	
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

For nX := 1 To Len(cString)

	cChar:=SubStr(cString, nX, 1)
	
	If Asc(cChar) < 32 .Or. Asc(cChar) > 123// .and. (cChar<> 10 .And. cChar<> 13)
		cString:=StrTran(cString,cChar,".")
	Endif
	
Next nX

Return cString




/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo    ≥HFXML16Leg≥ Autor ≥Eneovaldo Roveri Junior≥ Data ≥ 17/02/19 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÑo ≥ Legenda do Download e ManifestaÁ„o                         ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Sintaxe   ≥ HFXML16Leg()                                               ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function HFXML16Leg()

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
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥MyAviso   ∫Autor  ≥ Eneo               ∫ Data ≥             ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Interface/Dialog de Aviso.                                 ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Geral                                                      ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
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


//Gera Estrutura para arquivo Tempor·rio a Partir do SigaMat
Static Function Temporario(cAlias)

Local aStr  := {}
Local aStru := {}
Local cTit  := ""
Local nI := 0

DbSelectArea(cAlias)
aStr := dbStruct()

For ni := 1 to Len(aStr)
	If AllTrim( aStr[ni][1] ) $ "M0_CODIGO,M0_CODFIL,M0_FILIAL,M0_NOME,M0_CGC"
		aaDd(aStru,aStr[ni])
	EndIF
Next

aHeader := {}

For ni := 1 to Len(aStru)

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
		If U_HFXMLLIC(.F.)

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
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ HFXM16CD ∫Autor  ≥ Eneo               ∫ Data ≥             ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Consultar CNPJ do Destinat·rio via WS.                     ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Geral                                                      ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
User Function HFXM16CD(cMod, cCnpj, lMostra, cLogProc, nImp, nCount, lEnd, oRegua)

Local nHdl   := -1
Local lRet   := .F.
//Local cURL   := ""
Local cAmb   := "1"
Local cXml   := ""
Local cIdEnt := ""//U_GetIdEnt()
//Local cUF    := U_HFUFMAT( cCnpj )
Local oDet   := NIL
Local cVerLay:= "1.00"
Local cIndCon:= "1"
Local cSitConf  := ""
Local cChaveXml := Space(44)
Local cCnpjXml  := Space(14)
Local cCancNSU  := ""
//Local nVzNaoSinc:= 0
Local nOrd 		:= 0
Local cSt       := " "
Local cNf       := Space(9)
Local cSer      := Space(3)
Local cErro,cWarning
//Local nX := 0 //declaracao
Local l137      := .F.
Local cCnpjDest := ""
Local cNSU, cNSU2, cMaxNSU, cUltNSU
Local ni := 0

Default cLogProc := ""
Default nImp     := 2
Default nCount   := 0
Default lEnd     := .F.
Default oRegua   := NIL

//Private cTagNfe, cTagCan, cTagCce, oWs, oWsrNfe, oWsdNfe, aDocs, nX
Private aEnvNfe	:=	{}  //Criado para funÁ„o espi„o na data 11/12/2015
cInfo := ""
cMsg  := ""

DbSelectArea( xZBS )

//rstmvbuff()

// Tratamento da numeracao
if cMod == "55" 

	cNSU := ( GetNewPar("XM_NSUNFE","000000000000000",cFilAnt) )
	
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
	
Else

	cNSU := ( GetNewPar("XM_NSUCTE","000000000000001",cFilAnt) )
	
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
	
Endif

Do While cIndCon == "1"

	If lMostra
	
		If lEnd
		
			MsgStop("*** Cancelado pelo Operador ***","Fim")
			lRet := .F.
			Exit
			
		EndIf 
		
		oRegua:IncRegua1("Acessando Metodo NFeDistrDfe SEFAZ:"+cMod)
		oRegua:IncRegua2("(HF2) NFeDistrDfe SEFAZ" )
		
	EndIf

	oDet := {}
	cMaxNsu := U_HFBxXML(cMod,"CC",@cNSU,"",@cMsg,@cInfo,@l137,lMostra,@oDet)
	cUltNSU := cNSU
	cNSU2   := cNSU

	//if cRet := "oDet"
	For nI := 1 to len( oDet )  //Deixar assim para quando for mais de 1, mas agora tem que ser de 1 em 1.
		
		cStt  := ""
		//cMsg  := ""
		//cInfo := ""
		cChave:= ""
		cFileZip	:= Decode64( oDet[nI]:TEXT )
		nLenZip		:= Len( cFileZip )
		cFileUnZip  := ""
		cErro       := ""
		cWarning    := ""

		// Funcao de descompactacao de arquivos compactados no formato GZip
		lOk  := GzStrDecomp( cFileZip, nLenZip, @cFileUnZip )
		oXml := XmlParser( cFileUnZip, "_", @cErro, @cWarning )
		cXml := cFileUnZip

		If valtype(oXml) <> "O"
		
			cMsg	:=	"XXX"
			cInfo	:=	"N„o foi possÌvel Descompactar o XML."
			cStt	:=	"0"
			
			If lMostra
				U_MyAviso("XM16CD",cInfo,{"OK"},3)
			endif
			
		ElseIf UPPER(Substr(oDet[nI]:_SCHEMA:TEXT,1,7)) = UPPER("procNFe") .or. UPPER(Substr(oDet[nI]:_SCHEMA:TEXT,1,6)) = UPPER("resNFe")
			
			If UPPER(Substr(oDet[nI]:_SCHEMA:TEXT,1,7)) = UPPER("procNFe")
			
				cChave := alltrim( oXml:_NFEPROC:_PROTNFE:_INFPROT:_CHNFE:TEXT )
			    cSitConf  := "4"
			    
			Else //if UPPER(Substr(oDet[nI]:_SCHEMA:TEXT,1,13)) = UPPER("procEventoNFe")
			
				cChave := alltrim( oXml:_RESNFE:_CHNFE:TEXT )
			    cSitConf  := "0" //oXml:_RESNFE:_CSITNFE:TEXT
			    
			EndIF

			if lMostra
				oRegua:IncRegua2( cChave )
			endif

		    cChaveXml := cChave
			cCancNSU  := oDet[nI]:_NSU:TEXT //ver a bagaÁa
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
					
					cLogProc += cChaveXml+" Nova Chave Sincronizada NFeDistribuicaoDFe."+CRLF
					nCount++
					lRet := .T.
					
					RecLock(xZBS, .T. )
						( xZBS )->(FieldPut(FieldPos(xZBS_+"FILIAL"), XFilial(xZBS) ))  
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

				//rstmvbuff()
				
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
						
						( xZBS )->(FieldPut(FieldPos(xZBS_+"CNPJEM"), oXml:_NFPROC:_NFE:_INFNFE:_EMIT:_CPF:TEXT ))
				
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
					
					//If Type("oXml:_NFEPROC:_PROTNFE:_INFPROT:_DHRECBTO:TEXT") <> "U"
					if Empty(( xZBS )->(FieldGet(FieldPos(xZBS_+"DHRECB")))) 
					
						( xZBS )->(FieldPut(FieldPos(xZBS_+"DHRECB"), dDataBase ))   //VerData(oXml:_NFEPROC:_PROTNFE:_INFPROT:_DHRECBTO:TEXT)
					//ElseIf Type("oXml:_RESNFE:_DHRECBTO:TEXT") <> "U"
					//	( xZBS )->(FieldPut(FieldPos(xZBS_+"DHRECB"), VerData(oXml:_RESNFE:_DHRECBTO:TEXT) ))
					
					Endif
					
					If Type("oXml:_RESNFE:_CSITNFE:TEXT") <> "U"
						
						( xZBS )->(FieldPut(FieldPos(xZBS_+"CSITNF"), oXml:_RESNFE:_CSITNFE:TEXT ))
					
					Else
						
						( xZBS )->(FieldPut(FieldPos(xZBS_+"CSITNF"), "1" ))
					
					Endif
					
					If ValType( oDet[ nI ]:_NSU:TEXT ) <> "U"   //oWSdNfe:OWSRETORNARDOCUMENTORESULT:OWSDOCUMENTO:cNSU
					
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

					lRet := .T.  //tem al menos um
					
					//Gravar ultimo NSU
					
					cNSU := oDet[nI]:_NSU:TEXT
					
					If !PutMv("XM_NSUNFE",cNSU)
					
						SX6->(RecLock("SX6",.T.))
						SX6->X6_FIL     := cFilAnt //xFilial( "SX6" )
						SX6->X6_VAR     := "XM_NSUNFE"
						SX6->X6_TIPO    := "C"
						SX6->X6_DESCRIC := "NSU download NFE por CNPJ via HF"
						SX6->(MsUnLock())
						PutMv("XM_NSUNFE",cNSU)
						
					EndIf

				U_HFTrvXml("SOLTA", "ZBS"+cChaveXml, nHdl) //SOLTAR
				
			else
			
				If lMostra
				//			Alert(" Erro no travar ")
				endif
				
			Endif
			
		ElseIf UPPER(Substr(oDet[nI]:_SCHEMA:TEXT,1,9)) = UPPER("resEvento")
		
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
				
			endif
			
			if type( "oXml:_RESEVENTO:_TPEVENTO:TEXT" ) <> "U"
			
				cEvento := oXml:_RESEVENTO:_TPEVENTO:TEXT
				
			endif
			
			if type( "oXml:_RESEVENTO:_NSEQEVENTO:TEXT" ) <> "U"
			
				cSeqEve := oXml:_RESEVENTO:_NSEQEVENTO:TEXT
				
			endif
			
			if type( "oXml:_RESEVENTO:_DHEVENTO:TEXT" ) <> "U"
			
				dDhAut  := VerData(oXml:_RESEVENTO:_DHEVENTO:TEXT)
				
			endif
			
			if type( "oXml:_RESEVENTO:_DHRECBTO:TEXT" ) <> "U"
			
				dDhRec  := VerData(oXml:_RESEVENTO:_DHRECBTO:TEXT)
				
			endif
			
			if type( "oXml:_RESEVENTO:_NPROT:TEXT" ) <> "U"
			
				cProtC  := oXml:_RESEVENTO:_NPROT:TEXT
				
			endif
			
			if type( "oXml:_RESEVENTO:_XEVENTO:TEXT" ) <> "U"
			
				cXCorrecao  := oXml:_RESEVENTO:_XEVENTO:TEXT
				
			endif
			
			//Substr( cEvento,1,1 ) $ "12" .And. !Empty( cChave )
			if !Empty( cChave )
			
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
			
		ElseIf UPPER(Substr(oDet[nI]:_SCHEMA:TEXT,1,7)) = UPPER("procCTe") //.or. UPPER(Substr(oDet[nI]:_SCHEMA:TEXT,1,13)) = UPPER("procEventoCTe")
				
			If UPPER(Substr(oDet[nI]:_SCHEMA:TEXT,1,7)) = UPPER("procCTe")
			
				if Type("oXml:_CTEPROC:_PROTCTE:_INFPROT:_CHCTE:TEXT") <> "U"
				
					cChave := alltrim( oXml:_CTEPROC:_PROTCTE:_INFPROT:_CHCTE:TEXT )
				
				Else
				
					cChave := "nEnc"
				
				Endif
				
			Elseif UPPER(Substr(oDet[nI]:_SCHEMA:TEXT,1,13)) = UPPER("procEventoCTe")
				
				if Type("oXml:_CTEPROC:_PROTCTE:_INFPROT:_CHCTE:TEXT") <> "U"
				
					cChave := alltrim( oXml:_CTEPROC:_PROTCTE:_INFPROT:_CHCTE:TEXT )
				
				Else
					
					cChave := "nEnc"
				
				Endif
				
			EndIF

			if lMostra
			
				oRegua:IncRegua2( cChave )
				
			endif

			cSitConf  := "9"   //N„o tem manifestaÁ„o no CTE
			cChaveXml := cChave
	    	cCancNSU  := oDet[nI]:_NSU:TEXT //ver a bagaÁa
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
					
					cFilToma := u_GravaFil(cTomador, cIE)
					
					if empty(cFilToma)
					
						U_HFTrvXml("SOLTA", "ZBS"+cChaveXml, nHdl) //SOLTAR
						
						Loop
						
					endif

					( xZBZ )->( DbSetORder( nOrd ) )
				    ( xZBS )->( DbSetOrder( 3 ) )
				    
					If .Not. ( xZBS )->(dbSeek( cChaveXml ) )
					
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

					//rstmvbuff()
					
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
					
					if Empty(( xZBS )->(FieldGet(FieldPos(xZBS_+"DHRECB")))) 
							
						( xZBS )->(FieldPut(FieldPos(xZBS_+"DHRECB"), dDataBase ))   //VerData(oXml:_CTEPROC:_PROTCTE:_INFPROT:_DHRECBTO:TEXT)
					
					endif
					
					//If Type("oWSdNfe:OWSRETORNARDOCUMENTORESULT:OWSDOCUMENTO:cSITUACAO") <> "U"
					//	( xZBS )->(FieldPut(FieldPos(xZBS_+"CSITNF"), oWSdNfe:OWSRETORNARDOCUMENTORESULT:OWSDOCUMENTO:cSITUACAO ))
					//Endif
					
					If ValType( oDet[ nI ]:_NSU:TEXT ) <> "U"   //oWSdNfe:OWSRETORNARDOCUMENTORESULT:OWSDOCUMENTO:cNSU
						
						( xZBS )->(FieldPut(FieldPos(xZBS_+"NSU"), oDet[nI]:_NSU:TEXT ))
					
					Endif
					
					//If Type("oWSdNfe:OWSRETORNARDOCUMENTORESULT:OWSDOCUMENTO:OWSCCE:cCCEXMLRET") <> "U"  //cCORRECAO 21/7/17
					//	( xZBS )->(FieldPut(FieldPos(xZBS_+"CORREC"), oWSdNfe:OWSRETORNARDOCUMENTORESULT:OWSDOCUMENTO:OWSCCE:cCCEXMLRET ))
					//EndIf
					
					//21/7/17
					If Type("oXml") <> "U"
					
						( xZBS )->(FieldPut(FieldPos(xZBS_+"XML"), cXml ))
						
					else
					
						//Alert( "Niente" )
						
					EndIF
					
					( xZBS )->(FieldPut(FieldPos(xZBS_+"TOMA"), cTomador ))
					( xZBS )->(MsUnLock())

					lRet := .T.  //tem al menos um
					
					//Gravar ultimo NSU
					cNSU := oDet[nI]:_NSU:TEXT
					
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
            
		Else
		
//					alert(UPPER (oDet[nI]:_SCHEMA:TEXT) )

		Endif
		
	Next nI
	
	if cMod == "55"
	
		if cUltNsu <> "999999999999999" .and. cUltNsu > cNSU
		
			cNSU := cUltNsu
			
			if lMostra
			
				oRegua:IncRegua2( cNSU + " / " + cUltNsu )
				
			endif
			
			//alert(oWSrNfe:_RETDISTDFEINT:_ULTNSU:TEXT)
			
		endif
		
		if cMaxNsu > cNSU .and. cMaxNsu <> "999999999999999"
		
			cNSU := StrZero( val(cNSU)+1,len(cNSU),0 )
			cIndCon := "1"
			
		else
		
			cIndCon := "0"
			
		endif
		
		if lMostra
		
			oRegua:IncRegua2( cNSU + " / " + cMaxNsu )
			
		endif
		
		//rstmvbuff()
		
		If !PutMv("XM_NSUNFE",cNSU)
		
			SX6->(RecLock("SX6",.T.))
				SX6->X6_FIL     := cFilAnt //xFilial( "SX6" )
				SX6->X6_VAR     := "XM_NSUNFE"
				SX6->X6_TIPO    := "C"
				SX6->X6_DESCRIC := "NSU download NFE por CNPJ via HF"
				SX6->(MsUnLock())
				
			PutMv("XM_NSUNFE",cNSU)
			
		EndIf
		
		If lMostra
		//	Alert(cNSU + " / " + oWSrNfe:_RETDISTDFEINT:_MAXNSU:TEXT)
		endif
		
	else
	
		cNSU := cUltNsu
		
		If !PutMv("XM_NSUCTE",cNSU)
		
			SX6->(RecLock("SX6",.T.))
			SX6->X6_FIL     := cFilAnt //xFilial( "SX6" )
			SX6->X6_VAR     := "XM_NSUCTE"
			SX6->X6_TIPO    := "C"
			SX6->X6_DESCRIC := "NSU download CTE por CNPJ"
			SX6->(MsUnLock())
			PutMv("XM_NSUCTE",cNSU)
			
		EndIf
		
		if cMaxNsu > cNSU
		
			cIndCon := "1"
			
		else
		
			cIndCon := "0"
			
		endif

	endif
	
	DelClassIntf()
	
	oDet := NIL
	oWSrNfe := NIL
		
	If cIndCon == "1"
	
		Sleep(100) //Tempo para prÛxima execuÁ„o do mÈtodo SINCRONIZARDOCUMENTOS()
	
	Else
	
		Exit
		
	endif
	
EndDo

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

//DelClassIntf()  //aqui ja estava

Return( lRet )


Static Function Query15Dia(nQual)

Local aArea     := GetArea()
Local aRet      := {}
Local cAliasZBS := GetNextAlias()
Local cQuery    := ""
Local cDt       := dtos( dDataBase - nQual )
Local cChaveXml := ""

(xZBZ)->( dbSetOrder( 3 ) )

cQuery += "select R_E_C_N_O_ as REG, "+xZBS_+"CHAVE as CHAVE from "+RetSqlName(xZBS)+" ZBS "
cQuery += "where D_E_L_E_T_ = '' "
cQuery += "and "+xZBS_+"FILIAL = '"+cFilAnt+"' "
cQuery += "and "+xZBS_+"ESPIAO <> 'S' "
cQuery += "and "+xZBS_+"DEMI >= '"+cDt+"' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasZBS)

DbSelectARea( cAliasZBS )
(cAliasZBS)->( dbGoTop() )

Do While .NOT. (cAliasZBS)->( Eof() )

	cChaveXml := (cAliasZBS)->CHAVE
	
	If  .NOT. (xZBZ)->( dbSeek( cChaveXml ) )
	
           Aadd(aRet, { cChaveXml,  ( cAliasZBS )->REG } )
           
	endif

	DbSelectARea( cAliasZBS )
	
	(cAliasZBS)->( dbSkip() )

EndDo

(cAliasZBS)->( dbCloseArea() )

RestArea( aArea )

Return( aRet )


Static Function VerDigVal( cXml )

Local cErro:= "", cWarning:= ""
Local cRet := ""
Local nTamFile := 0

Private oWSrNfe

cXml := NoAcento(cXml)
cXml := EncodeUTF8(cXml)

if Len(cXml) >= 65534

	oWSrNfe := U_PARSGDE( cXml, @cErro, @cWarning )
	
Else

	oWSrNfe := XmlParser( cXml, "_", @cErro, @cWarning )
	
endif

If oWSrNfe <> NIL .And. Empty(cErro)

	if Type( "oWSrNfe:_RESNFE:_DIGVAL:TEXT" ) <> "U"
	
		cRet := oWSrNfe:_RESNFE:_DIGVAL:TEXT
		
	Endif
	
Endif

//DelClassIntf()

Return cRet



Static Function manifver(cChave,cURL,cIdEnt,cAmb)

Local cRet := "4"
Local oWs2
Local oWSrNfe
Local cXml := "",cErro:= "",cWarning:= ""

Return( cRet )


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ HFXM16BS ∫Autor  ≥ Eneo               ∫ Data ≥             ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Alimentar TMP com os ultimos 30 dias da Tabela ZBS         ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Geral                                                      ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
User Function HFXM16BS(cCnpj, lMostra, cLogProc, nImp, cModelo, lEnd, oRegua, lMarcado)

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
Local cModAtu   := ""
Local cAliasZBS := GetNextAlias()
Local cQuery    := ""

//alert(GetNewPAr("XM_QDIADWN", 90))
//alert(dAutor)

Default cLogProc := ""
Default nImp     := 2
Default cModelo  := ""
Default lEnd     := .F.
Default oRegua   := NIL
Default lMarcado := .F.

//rstmvbuff()

DbSelectArea( xZBZ )
nOrd := ( xZBZ )->( indexOrd() )
DbSetORder( 3 )
DbSelectArea( xZBS )
DbSetORder( 7 )

cQuery += " select R_E_C_N_O_ as REG, "+xZBS_+"CHAVE as CHAVE from "+RetSqlName(xZBS)+" ZBS "
cQuery += " where D_E_L_E_T_ = ' ' "
cQuery += " and "+xZBS_+"FILIAL = '"+xFilial( xZBS )+"' "

if cModelo == "55"

	cQuery += " and "+xZBS_+"MODELO in ('  ','55') "  //fadigando

elseif cModelo == "57"

	cQuery += " and "+xZBS_+"MODELO = '"+cModelo+"' "

endif

//se n„o enviar modelo, vai todos
cQuery += " and "+xZBS_+"DEMI >= '"+dtos(dAutor)+"' "  //Fadigando tambÈm

//cQuery += " and "+xZBS_+"CSITNF <> '3' "  //Cancelada

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasZBS)

if lMostra
	oRegua:SetRegua1((cAliasZBS)->( reccount() ))
	oRegua:SetRegua2(0)
endif

DbSelectARea( cAliasZBS )

(cAliasZBS)->( dbGoTop() )

Do While .NOT. (cAliasZBS)->( Eof() )

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
		
			if lMostra
				oRegua:IncRegua2("")
			endif
			
			if ( xZBZ )->( FieldGet( FieldPos( xZBZ_+"TPDOWL" ) ) ) <> "R"
				
				DbSelectARea( cAliasZBS )
				( cAliasZBS )->( dbskip() )
				nNao++
				
				LOOP
				
			endif
			
		EndIf
		
	EndIf

	if lMostra
	
		oRegua:IncRegua2(cChaveXml)
		
	endif

	DbSelectArea( cTMP_ZBS )
	dbSetOrder(1)
	
	If .Not. (cTMP_ZBS)->(dbSeek( cChaveXml ) )
	
		nSim++
		lRet := .T.

		cCodFor   := Space( 6 )
		cLojFor   := Space( 2 )
		
		if empty(cCodFor)
		
			cFilSek   := xFilial( "SA2" ) //iif(lSharedA2, xFilial( "SA2" ), ( xZBS )->( FieldGet( FieldPos( xZBS_+"FILIAL" ) ) ) )
			
			DbSelectArea("SA2")
			DbSetOrder(3)
			If DbSeek(cFilSek+( xZBS )->( FieldGet( FieldPos( xZBS_+"CNPJEM" ) ) )) 
			
				cCodFor := SA2->A2_COD
				cLojFor := SA2->A2_LOJA 
				
				Do While .not. SA2->( eof() ) .and. SA2->A2_FILIAL == cFilSek .and.;
						               SA2->A2_CGC == ( xZBS )->( FieldGet( FieldPos( xZBS_+"CNPJEM" ) ) )
					
					if SA2->A2_MSBLQL != "1"
					
						cCodFor := SA2->A2_COD
						cLojFor := SA2->A2_LOJA 
						
						exit
						
					endif
					
					SA2->( dbSkip() )
					
				EndDo
				
			EndIf
			
		EndIF
	
		if empty(cCodFor)
		
			cFilSek   := xFilial( "SA1" ) //iif(lSharedA1, xFilial( "SA1" ), ( xZBS )->( FieldGet( FieldPos( xZBS_+"FILIAL" ) ) ) )
			
			DbSelectArea("SA1")
			DbSetOrder(3)
			If DbSeek(cFilSek+( xZBS )->( FieldGet( FieldPos( xZBS_+"CNPJEM" ) ) )) 
			
				cCodFor := SA1->A1_COD
				cLojFor := SA1->A1_LOJA 
				
				Do While .not. SA1->( eof() ) .and. SA1->A1_FILIAL == cFilSek .and.;
						               SA1->A1_CGC == ( xZBS )->( FieldGet( FieldPos( xZBS_+"CNPJEM" ) ) )
					
					if SA1->A1_MSBLQL != "1"
					
						cCodFor := SA1->A1_COD
						cLojFor := SA1->A1_LOJA 
						
						exit
						
					endif
					
					SA1->( dbSkip() )
					
				EndDo
				
			EndIf
			
		EndIF

		DbSelectArea( cTMP_ZBS )
		RecLock( cTMP_ZBS, .T. )
		
		if lMarcado
		
			(cTMP_ZBS)->OK:= "Pr"
			
		endif
		
		(cTMP_ZBS)->ST    	 := " "
		(cTMP_ZBS)->CHAVE 	 := cChaveXml
		(cTMP_ZBS)->AMB   	 := ( xZBS )->( FieldGet( FieldPos( xZBS_+"AMB" ) ) )
		(cTMP_ZBS)->DEST  	 := ( xZBS )->( FieldGet( FieldPos( xZBS_+"DEST" ) ) )
		(cTMP_ZBS)->CNF      := ( xZBS )->( FieldGet( FieldPos(xZBS_+"CNF") ) )
		(cTMP_ZBS)->SERIE    := ( xZBS )->( FieldGet( FieldPos(xZBS_+"SERIE") ) )
		(cTMP_ZBS)->CNPJ_EMI := ( xZBS )->( FieldGet( FieldPos( xZBS_+"CNPJEM" ) ) )
		(cTMP_ZBS)->CODFOR   := cCodFor
		(cTMP_ZBS)->LOJFOR   := cLojFor
		(cTMP_ZBS)->DEMI     := ( xZBS )->( FieldGet( FieldPos( xZBS_+"DEMI" ) ) )
		(cTMP_ZBS)->VNF      := AllTrim( Str( ( xZBS )->( FieldGet( FieldPos( xZBS_+"VNF" ) ) ) ) )
		(cTMP_ZBS)->XNOME    := ( xZBS )->( FieldGet( FieldPos( xZBS_+"XNOME" ) ) )
		(cTMP_ZBS)->IE       := ( xZBS )->( FieldGet( FieldPos( xZBS_+"IE" ) ) )
		(cTMP_ZBS)->DIGVAL   := ( xZBS )->( FieldGet( FieldPos( xZBS_+"DIGVAL" ) ) )
		(cTMP_ZBS)->DHRECBTO := ( xZBS )->( FieldGet( FieldPos( xZBS_+"DHRECB" ) ) )
		(cTMP_ZBS)->CSITNFE  := ( xZBS )->( FieldGet( FieldPos( xZBS_+"CSITNF" ) ) )
		(cTMP_ZBS)->CSITCONF := ( xZBS )->( FieldGet( FieldPos( xZBS_+"CSITCO" ) ) )
		(cTMP_ZBS)->NSU      := ( xZBS )->( FieldGet( FieldPos( xZBS_+"NSU" ) ) )
		(cTMP_ZBS)->TOMA	 := ( xZBS )->( FieldGet( FieldPos( xZBS_+"TOMA" ) ) )
		
		(cTMP_ZBS)->( MsUnLock() )
		
	Else
	
		nRep++
		
	Endif

	DbSelectARea( cAliasZBS )
	
	(cAliasZBS)->( dbSkip() )

EndDo

(cAliasZBS)->( dbCloseArea() )

DbSelectArea( xZBZ )
DbSetORder( nOrd )
DbSelectArea( cTMP_ZBS )

RestArea( aArea )

Return( lRet )


/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Programa  ≥HFXML16Vis≥ Autor ≥ Eneo                  ≥ Data ≥08/07/2019≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Visualizar Registro, quando for consulta por CNPJ mostrar· ≥±±
±±≥          ≥ os dados adicionais                                        ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥                                                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥                                                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒ¬ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Analista Resp.≥  Data  ≥ Bops ≥ Manutencao Efetuada                    ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥              ≥        ≥      ≥                                        ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Static Function HFXML16Vis()

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
    
//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
@ 00.5,00.5 To 012,043 OF oPage:aDialogs[nPageGer]

@ 010,010 Say "Chave: " PIXEL OF oPage:aDialogs[nPageGer] COLOR CLR_BLUE FONT oFont01
@ 018,010 Get oObj VAR (cTMP_ZBS)->CHAVE SIZE 150,08 When .F. PIXEL OF oPage:aDialogs[nPageGer]                   

@ 040,010 Say "CNPJ Destinat·rio: "  PIXEL OF oPage:aDialogs[nPageGer] COLOR CLR_BLUE FONT oFont01
@ 048,010 Get oObj VAR (cTMP_ZBS)->DEST SIZE 150,08 When .F. PIXEL OF oPage:aDialogs[nPageGer] 

@ 070,010 Say "Mensagem Retorno WS: "  PIXEL OF oPage:aDialogs[nPageGer] COLOR CLR_BLUE FONT oFont01
@ 078,010 Get oObj VAR (cTMP_ZBS)->MSG SIZE 150,08 When .F. PIXEL OF oPage:aDialogs[nPageGer] 

@ 100,010 Say "Mensagem Erro WS: "  PIXEL OF oPage:aDialogs[nPageGer] COLOR CLR_BLUE FONT oFont01
@ 108,010 Get oObj VAR (cTMP_ZBS)->ERRO MULTILINE SIZE 300,50 When .F. PIXEL OF oPage:aDialogs[nPageGer] 

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
@ 00.5,00.5 To 012,043 OF oPage:aDialogs[nPageNfe]

@ 010,010 Say "ManifestaÁ„o do Destinat·rio: " PIXEL OF oPage:aDialogs[nPageNfe] COLOR CLR_BLUE FONT oFont01
@ 018,010 Get oObj VAR (cTMP_ZBS)->CSITCONF SIZE 10,08 When .F. PIXEL OF oPage:aDialogs[nPageNfe]                   
@ 018,030 Say "0=S/Manif.     1=Conf.Oper." PIXEL OF oPage:aDialogs[nPageNfe] COLOR CLR_BLUE FONT oFont03
@ 022,030 Say "2=Desconhecida 3=Oper.N„o Real. 4=CiÍncia" PIXEL OF oPage:aDialogs[nPageNfe] COLOR CLR_BLUE FONT oFont03

@ 010,170 Say "CNPJ Emitente: "  PIXEL OF oPage:aDialogs[nPageNfe] COLOR CLR_BLUE FONT oFont01
@ 018,170 Get oObj VAR (cTMP_ZBS)->CNPJ_EMI SIZE 150,08 When .F. PIXEL OF oPage:aDialogs[nPageNfe] 

@ 040,010 Say "Data Emiss„o: "  PIXEL OF oPage:aDialogs[nPageNfe] COLOR CLR_BLUE FONT oFont01
@ 048,010 SAY dtoc( (cTMP_ZBS)->DEMI ) SIZE 150,08  PIXEL OF oPage:aDialogs[nPageNfe] 

@ 040,170 Say "Emitente: "  PIXEL OF oPage:aDialogs[nPageNfe] COLOR CLR_BLUE FONT oFont01
@ 048,170 Get oObj VAR (cTMP_ZBS)->XNOME SIZE 150,08 When .F. PIXEL OF oPage:aDialogs[nPageNfe] 

@ 070,010 Say "Valor da NFe: "  PIXEL OF oPage:aDialogs[nPageNfe] COLOR CLR_BLUE FONT oFont01
@ 078,010 Get oObj VAR (cTMP_ZBS)->VNF SIZE 150,08 When .F. PIXEL OF oPage:aDialogs[nPageNfe] 

@ 070,170 Say "IE Emitente: "  PIXEL OF oPage:aDialogs[nPageNfe] COLOR CLR_BLUE FONT oFont01
@ 078,170 Get oObj VAR (cTMP_ZBS)->IE SIZE 150,08 When .F. PIXEL OF oPage:aDialogs[nPageNfe] 

@ 100,010 Say "ValidaÁ„o: "  PIXEL OF oPage:aDialogs[nPageNfe] COLOR CLR_BLUE FONT oFont01
@ 108,010 Get oObj VAR (cTMP_ZBS)->DIGVAL SIZE 150,08 When .F. PIXEL OF oPage:aDialogs[nPageNfe] 

@ 100,170 Say "Recbto: "  PIXEL OF oPage:aDialogs[nPageNfe] COLOR CLR_BLUE FONT oFont01
@ 108,170 SAY  dtoc( (cTMP_ZBS)->DHRECBTO ) SIZE  150,08  PIXEL OF oPage:aDialogs[nPageNfe] 

@ 130,010 Say "NSU: "  PIXEL OF oPage:aDialogs[nPageNfe] COLOR CLR_BLUE FONT oFont01
@ 138,010 Get oObj VAR (cTMP_ZBS)->NSU SIZE 150,08 When .F. PIXEL OF oPage:aDialogs[nPageNfe] 

@ 130,170 Say "SituaÁ„o NFe: "  PIXEL OF oPage:aDialogs[nPageNfe] COLOR CLR_BLUE FONT oFont01
@ 138,170 Get oObj VAR (cTMP_ZBS)->CSITNFE SIZE 10,08 When .F. PIXEL OF oPage:aDialogs[nPageNfe] 
@ 140,190 Say "1=Uso autorizado 2=Uso denegado 3=NF-e cancelada" PIXEL OF oPage:aDialogs[nPageNfe] COLOR CLR_BLUE FONT oFont03

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
@ 00.5,00.5 To 012,043 OF oPage:aDialogs[nPageCce]
@ 010,010 Say "Carta de CorreÁ„o: "  PIXEL OF oPage:aDialogs[nPageCce] COLOR CLR_BLUE FONT oFont01
@ 018,010 Get oObj VAR (cTMP_ZBS)->Correcao MULTILINE SIZE 310,140 When .F. PIXEL OF oPage:aDialogs[nPageCce] 

@ 012,355 Button "Sair" Size 040,015 PIXEL OF oDlg ACTION oDlg:End()

ACTIVATE MSDIALOG oDlg CENTERED ON INIT (nOpca := 0,.T.)

Return(NIL)

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Programa  ≥HFXML16Fil≥ Autor ≥ Mandela               ≥ Data ≥29/15/2018≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Filtrar por Coiso                                          ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥                                                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥                                                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒ¬ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Analista Resp.≥  Data  ≥ Bops ≥ Manutencao Efetuada                    ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥              ≥        ≥      ≥                                        ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Static Function HFXML16Fil(oMark, cAlias)

Local bCond := {|| (cTMP_ZBS)->ST = "0" }
Local cCond := 'ST="0"'
Local nOp   := 0

nOp := Filtros()

if nOp == 2

	bCond := {|| (cTMP_ZBS)->ST = " " }
	cCond := 'ST=" "'
	
elseif nOp == 3

	bCond := {|| (cTMP_ZBS)->ST = "0" }
	cCond := 'ST="0"'
	
elseif nOp == 4

	bCond := {|| (cTMP_ZBS)->ST = "2" }
	cCond := 'ST="2"'
	
elseif nOp == 5

	bCond := {|| (cTMP_ZBS)->ST = "1" }
	cCond := 'ST="1"'
	
endif

if nOp == 0

	(cTMP_ZBS)->( DBClearFilter())
	
Else

	(cTMP_ZBS)->( DBSetFilter( bCond, cCond ) )
	
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

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Programa  ≥ HFXML6JB ≥ Autor ≥ Eneo                  ≥ Data ≥30/05/2014≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Job autom·tico para Consultar e Baixar XML do SEFAZ.       ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒ¬ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Analista Resp.≥  Data  ≥ Bops ≥ Manutencao Efetuada                    ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥              ≥        ≥      ≥                                        ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
User Function HFXML16JB(lAuto,lEnd,oProcess,cLogProc,nCount,lMostra)

Local aArea   := GetArea()
Local nRegMat := SM0->( Recno() )
Local cEmpres := SM0->M0_CODIGO
Local cFilAtu := SM0->M0_CODFIL
Local cCnpj   := ""
Local cArq    := ""
Local nVersao := Val(GetVersao(.F.))     // Indica a versao do Protheus

Default cLogProc := ""
Default lAuto    := .F.
Default oProcess := Nil
Default lEnd     := .F.
Default nCount   := 0
Default lMostra  := .F.

cLogProc += "### Download XML no Sefaz Iniciada ###"+CRLF
cLogProc += dToC(date()) +"-"+ Substr(Time(),1,2) + "-" + Substr(Time(),4,2)+CRLF

conout( cLogProc )

Private cTmp_ZBS := "TMPZBS", cAli_ZBS, oTmp_ZBS
Private aEmpFils := U_XGetEmpF()

if nVersao >= 12

	CriaTMP(@cArq)
	cAli_ZBS := oTmp_ZBS:GetAlias()
	
Else

	cAli_ZBS := CriaTMP(@cArq)
	
Endif

cCnpj := SM0->M0_CGC
cFilAnt := SM0->M0_CODFIL

//If U_HFXML00X("HF000001","101",cCnpj,,.F.)
If U_HFXMLLIC(.F.)
	cLogProc += "Iniciado CNPJ "+cCnpj+CRLF
	dbSelectarea( cTmp_ZBS )
	
	If U_HFXM16CD("55", cCnpj, .F., @cLogProc, ,@nCount)
	
	Else
	
		cLogProc += "SEFAZ n„o disponibilizou novos XML modelo 55 pela NFeDistribuicaoDFe."+CRLF
	
	EndIf
	
	If U_HFXM16BS(cCnpj, .F., @cLogProc, 2, "55", , ,.T. ) //Alimenta TMP de 93 dias para tentar baixar.
		
		cLogProc += "Tentar baixar os ultimos 90 dias que estiverem na sincronizaÁ„o NFeDistribuicaoDFe."+CRLF
		JobBaixa(@cLogProc)
		
	EndIf
	
	dbSelectArea( cTmp_ZBS )
	
	Zap
	
	If U_HFXM16CD("57", cCnpj, .F., @cLogProc, ,@nCount)
	
	Else
	
		cLogProc += "SEFAZ n„o disponibilizou novos XML modelo 57 pela CTeDistribuicaoDFe."+CRLF
	
	EndIf
	
	If U_HFXM16BS(cCnpj, .F., @cLogProc, 2, "57", , , .T.) //Alimenta TMP de 93 dias para tentar baixar.
		
		cLogProc += "Tentar baixar os ultimos 90 dias que estiverem na sincronizaÁ„o CTeDistribuicaoDFe."+CRLF
		JobBaixa(@cLogProc)  //Vai baixar o que tiver ZBS.
		
	EndIf
	
	cLogProc += "Finalizado CNPJ "+cCnpj+CRLF
	
Else

	cLogProc += "Sem LicenÁa CNPJ "+cCnpj+CRLF
	
Endif

cLogProc += "### Download XML no Sefaz Finalizada ###"+CRLF
cLogProc += dToC(date()) +"-"+ Substr(Time(),1,2) + "-" + Substr(Time(),4,2)+CRLF

conout( cLogProc )

SM0->( dbgoto( nRegMat ) )
cFilAnt := cFilAtu

if nVersao >= 12

	oTmp_ZBS:Delete()
	
Else

	(cAli_ZBS)->( dbCloseArea() )
	fErase( cArq+GetDBExtension() )
	
Endif

RestArea( aArea )

Return NIL



Static Function JobBaixa(cLogProc)

Local lRet   := .T.

HFXML16Dow( NIL, .F., NIL, .F., @cLogProc)
		
DelClassIntf()

Return( lRet )



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
±±≥Programa  ≥HFXML16NSU≥ Autor ≥ Eneo                  ≥ Data ≥30/05/2015≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Tela para Editar Par‚metro NSU para rotina NFeDistribuicaoDFe.   ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒ¬ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Analista Resp.≥  Data  ≥ Bops ≥ Manutencao Efetuada                    ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥              ≥        ≥      ≥                                        ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Static Function HFXML16NSU()

Local lRet 			:= .T.
Local cNsu          := Space(11)
Local cAmb          := " "
Local cVrs          := "0.00"
//Local cIdEnt 		:= U_GetIdEnt()
Local nOpc 			:= 1
Local oWs,cURL,oDlg,oNsu,oAmb,oVrs
Local lDfeHf        := ( GetNewPar( "XM_DFE", "0" ) == "1" )

//rstmvbuff()

cNSU := ( GetNewPar("XM_NSUNFE" ,cNSU,cFilAnt) )
cVrs := ( GetNewPar("XM_VERLNFE",cVrs,cFilAnt) )
cAmb := ( GetNewPar("XM_AMBNFE" ,cAmb,cFilAnt) )

DEFINE MSDIALOG oDlg TITLE "Filial "+cFilAnt FROM 0,0 TO 155,450 OF oDlg PIXEL

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

	//rstmvbuff()
	
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

endif

//DelClassIntf()

Return( lRet )


/*
±±≥Programa  ≥HFXML16NSC≥ Autor ≥ Sebasti„o Macale¥     ≥ Data ≥29/07/2017≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Tela para Editar Par‚metro NSU para rotina CTeDistribuicaoDFe.≥±±
Utiliza de Par‚metros normales
*/
Static Function HFXML16NSC()

Local lRet 			:= .T.
Local cNsu          := "000000000000001"
Local cAmb          := "1"
Local cVrs          := "1.00"
//Local cIdEnt 		:= U_GetIdEnt()
Local nOpc 			:= 1
Local oWs,cURL,oDlg,oNsu,oAmb,oVrs

cNSU := ( GetNewPar("XM_NSUCTE" ,"000000000000001",cFilAnt) )
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

	//rstmvbuff()
	
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
±±≥Programa  ≥HFXML16PAR≥ Autor ≥ Sebasti„o Macale¥     ≥ Data ≥29/07/2019≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Par‚metro Horario e Hor·rio de Veron                      .≥±±
*/
Static Function HFXML16PAR()

Local lRet 			:= .T.
Local cHorario      := "1"
Local cHrVerao      := "2"
Local nOpc 			:= 1
Local oWs,cURL,oDlg,oNsu,oAmb,oVrs

cHorario := GetNewPar("XM_HORARIO","1",cFilAnt)
cHrVerao := GetNewPar("XM_HRVERAO","2",cFilAnt)

Private aCombo1 := {}, aCombo2 := {} 

aAdd( aCombo1, "1=Fernando de Noronha" )
aAdd( aCombo1, "2=Brasilia" )
aAdd( aCombo1, "3=Manuaus" )
aAdd( aCombo1, "4=Acre" )

aAdd( aCombo2, "S=Sim" )
aAdd( aCombo2, "N=N„o" )

DEFINE MSDIALOG oDlg TITLE "Filial "+cFilAnt FROM 0,0 TO 155,450 OF oDlg PIXEL

@ 003,006 Say "Par‚metros de Eventos para ManifestaÁ„o do Destinat·rio" PIXEL OF oDlg
@ 009,006 Say "Informar o Fuso Hor·rio da Filial."   PIXEL OF oDlg
@ 015,006 Say "Informar se esta em hor·rio de ver„o ou n„o"  PIXEL OF oDlg

@ 027,006 Say "Hor·rio: " PIXEL OF oDlg
@ 037,006 COMBOBOX oHorario VAR cHorario ITEMS aCombo1 SIZE 100,10 PIXEL OF oDlg

@ 050,006 Say "Hor·rio de Ver„o: " PIXEL OF oDlg
@ 060,006 COMBOBOX oHrVerao VAR cHrVerao ITEMS aCombo2 SIZE 100,10 PIXEL OF oDlg
 
@ 060,140 BUTTON "Cancelar" SIZE 35,12 PIXEL OF oDlg Action(nOpc:= 0,oDlg:End())
@ 060,180 BUTTON "Salvar"   SIZE 35,12 PIXEL OF oDlg Action(nOpc:= 1,oDlg:End())

ACTIVATE MSDIALOG oDlg CENTERED

if nOpc == 1

	rstmvbuff()
	
	If !PutMv("XM_HORARIO",cHorario)
	
		SX6->(RecLock("SX6",.T.))
		
			SX6->X6_FIL     := cFilAnt //xFilial( "SX6" )
			SX6->X6_VAR     := "XM_HORARIO"
			SX6->X6_TIPO    := "C"
			SX6->X6_DESCRIC := "Fuso Horario da Filial via HF"
			
			SX6->(MsUnLock())
			
		PutMv("XM_HORARIO",cHorario)
		
	EndIf

	If !PutMv("XM_HRVERAO",cHrVerao)
	
		SX6->(RecLock("SX6",.T.))
		
			SX6->X6_FIL     := cFilAnt //xFilial( "SX6" )
			SX6->X6_VAR     := "XM_HRVERAO"
			SX6->X6_TIPO    := "C"
			SX6->X6_DESCRIC := "Horario de Ver„o via HF 1=Sim 2=N„o"
			
			SX6->(MsUnLock())
			
		PutMv("XM_HRVERAO",cHrVerao)
		
	EndIf

endif

DelClassIntf()

Return( lRet )


/*===================================*/
//Rotina para baixar xml sem a utilizaÁ„o do TSS
User Function HFBxXML(cMod,cTp,cChaveNFe,cExt,cLog,cInfo,l137,lMostra,oDet)

Local aArea     := GetArea()
Local lRet      := .T.
Local cURL      := "https://www1.nfe.fazenda.gov.br/NFeDistribuicaoDFe/NFeDistribuicaoDFe.asmx?WSDL"
//Local cURL      := "https://www1.nfe.fazenda.gov.br/NFeDistribuicaoDFe/NFeDistribuicaoDFe.asmx"
Local cMsg      := ""
Local oWsdl     := NIL
Local cMsgRet   := ""
Local cError    := ""
Local cWarning  := ""
Local cXmlGZip  := ""
Local cArqXML   := ""
Local cUfAutor  := U_HFUFMAT( Alltrim(SM0->M0_CGC) )  // "35" //SuperGetMV("MV_X_BXUF",  .F., "35")  //pegar do sigamat
Local cTpAmb    := "" //GetNewPar("XM_AMBNFE", "1")   //È 1 mesmo
Local cCNPJEmp  := Alltrim(SM0->M0_CGC)                 //ihi
Local lContinua := .T.
Local cCACertFile := GetNewPar("XM_CERTCA" ,"\certs\000001_ca.pem"  ,cFilAnt)
Local cCertFile   := GetNewPar("XM_CERTCER","\certs\000001_cert.pem",cFilAnt)
Local cKeyFile    := GetNewPar("XM_CERTKEY","\certs\000001_key.pem" ,cFilAnt)
Local cKeyPwd     := GetNewPar("XM_CERTPSW","cofer1030"             ,cFilAnt)
Local nVersion    := GetNewPar("XM_CERTPRO",0)
Local nTimeO      := GetNewPar("XM_CERTTIM",120)
Local nTotTent    := GetNewPar("XM_TENTSEND", 5 )
Local nAtr := 0

Default cTp := "DC"
Default oDet := NIL

Private oXmlDocZip, oWSrNfe

if nTotTent <= 0
	nTotTent := 1
endif

if cMod $ "55,65"

	cVrs   := ( GetNewPar("XM_VERLNFE","1.00",cFilAnt) )
	cTpAmb := ( GetNewPar("XM_AMBNFE" ,"1",cFilAnt) )
	
	if cTpAmb == "1"
	
		cURL      := "https://www1.nfe.fazenda.gov.br/NFeDistribuicaoDFe/NFeDistribuicaoDFe.asmx?WSDL"
	
	else
	
		cURL      := "https://hom.nfe.fazenda.gov.br/NFeDistribuicaoDFe/NFeDistribuicaoDFe.asmx?WSDL"
		
	endif
	
elseif cMod $ "57,67"

	cVrs   := ( GetNewPar("XM_VERLCTE","1.00",cFilAnt) )
	cTpAmb := ( GetNewPar("XM_AMBNFE" ,"1",cFilAnt) )
	
	if cTpAmb == "1"
		cURL      := "https://www1.cte.fazenda.gov.br/CTeDistribuicaoDFe/CTeDistribuicaoDFe.asmx?WSDL"
	else
		cURL      := "https://hom1.cte.fazenda.gov.br/CTeDistribuicaoDFe/CTeDistribuicaoDFe.asmx?WSDL"
	endif
	
endif

cCACertFile := GetNewPar("XM_CERTCA" ,"\certs\000001_ca.pem"  ,cFilAnt)
cCertFile   := GetNewPar("XM_CERTCER","\certs\000001_cert.pem",cFilAnt)
cKeyFile    := GetNewPar("XM_CERTKEY","\certs\000001_key.pem" ,cFilAnt)
cKeyPwd     := GetNewPar("XM_CERTPSW",""			          ,cFilAnt)
nVersion    := GetNewPar("XM_CERTPRO",0)
nTimeO      := GetNewPar("XM_CERTTIM",120)
 
//Inst‚ncia a classe, setando as par‚metrizaÁıes necess·rias
oWsdl := TWsdlManager():New()
oWsdl:cSSLCACertFile := cCACertFile   //SuperGetMV("XM_X_BXCA",  .F., "\certs\000001_ca.pem")    //criar pasta dentro do protheus_data
oWsdl:cSSLCertFile   := cCertFile     //SuperGetMV("XM_X_BXCER", .F., "\certs\000001_cert.pem")  //no caso aqui teria que ter o wizard de certificado que tanto falamos
oWsdl:cSSLKeyFile    := cKeyFile      //SuperGetMV("XM_X_BXKEY", .F., "\certs\000001_key.pem")   //
oWsdl:cSSLKeyPwd     := cKeyPwd       //SuperGetMV("XM_X_BXPSW", .F., "cofer1030")
oWsdl:nSSLVersion    := nVersion      //SuperGetMV("XM_X_BXPRO", .F., "0")
oWsdl:nTimeout       := nTimeO
//Meus
oWsdl:lSSLInsecure   := .T.
//oWsdl:lProcResp      := .F.

//Tenta fazer o Parse da URL
For nAtr := 1 To nTotTent

	lRet := oWsdl:ParseURL(cURL)
	
   	if lRet
   		Exit
   	endif

	 Sleep(1500)  
   	
    ConOut("Tentativa XM_TENTSEND "+AllTrim(Str(nAtr))+" [HFBxXML] - Erro ParseURL: " + oWsdl:cError)
    
    Next
   
    If ! lRet 
    
        ConOut("[HFBxXML] - Erro ParseURL: " + oWsdl:cError)
		cLog := oWsdl:cError
		cInfo := oWsdl:cError

		if lMostra
		
			U_MyAviso("Erro ParseURL","[HFBxXML] - "+oWsdl:cError ,{"Ok"},3)
		    	
		endif
    
		lContinua := .F.
    
	EndIf
 
	//Se for continuar o processamento   
	If lContinua

	    //Tenta definir a operaÁ„o
	    For nAtr := 1 To nTotTent
	   
		    if cMod $ "57,67"
		    	lRet := oWsdl:SetOperation("cteDistDFeInteresse")
			else
				lRet := oWsdl:SetOperation("nfeDistDFeInteresse")
		    endif
		   
		   	if lRet
		   		Exit
		   	endif

			Sleep(1500)     
		    
		    ConOut("Tentativa XM_TENTSEND "+AllTrim(Str(nAtr))+" [HFBxXML] - Erro SetOperation: " + oWsdl:cError)
		  
	    Next
    
	    If ! lRet 
	    
	        ConOut("[HFBxXML] - Erro SetOperation: " + oWsdl:cError)
			cLog := oWsdl:cError
			cInfo := oWsdl:cError
	
			if lMostra
			
				U_MyAviso("Erro SetOperation","[HFBxXML] - "+oWsdl:cError ,{"Ok"},3)
				
			endif
			        
		lContinua := .F.
			        
		EndIf
			    
	EndIf
	 
	//Se for continuar
	If lContinua

		//Monta a mensagem que ser· enviada
		//cUfAutor := substr(cChaveNFe,1,2)
		if cMod $ "57,67"
		
			cMsg := '<soapenv:Envelope xmlns:soapenv="http://www.w3.org/2003/05/soap-envelope">'                       + CRLF
			cMsg += '    <soapenv:Header/>'                                                                            + CRLF
			cMsg += '    <soapenv:Body>'                                                                               + CRLF
			cMsg += '        <cteDistDFeInteresse xmlns="http://www.portalfiscal.inf.br/cte/wsdl/CTeDistribuicaoDFe">' + CRLF
			cMsg += '            <cteDadosMsg>'                                                                        + CRLF
			cMsg += '                 <distDFeInt xmlns="http://www.portalfiscal.inf.br/cte" versao="1.00">'       + CRLF
			cMsg += '                     <tpAmb>'+cTpAmb+'</tpAmb>'                                                   + CRLF
			cMsg += '                     <cUFAutor>'+cUfAutor+'</cUFAutor>'                                           + CRLF
			cMsg += '                     <CNPJ>'+cCNPJEmp+'</CNPJ>'                                                   + CRLF
   
			if cTp = "CC"
		    
			    cMsg += '                      <distNSU>'                                                              + CRLF
			    cMsg += '                           <ultNSU>'+alltrim(cChaveNFe)+'</ultNSU>'                           + CRLF
			    cMsg += '                      </distNSU>'                                                             + CRLF
		
			elseif cTp = "CN"
		    
			    cMsg += '                      <consNSU>'                                                              + CRLF
			    cMsg += '                           <NSU>'+alltrim(cChaveNFe)+'</NSU>'                                 + CRLF
			    cMsg += '                      </consNSU>'                                                             + CRLF
			   
		    else
		      
		        cMsg += '                      <consChNFe>'                                                            + CRLF
			    cMsg += '                           <chNFe>'+alltrim(cChaveNFe)+'</chNFe>'                             + CRLF
			    cMsg += '                      </consChNFe>'                                                           + CRLF
		  
		    endif
		    
		    cMsg += '                 </distDFeInt>'                                                                   + CRLF
			cMsg += '            </cteDadosMsg>'                                                                       + CRLF
			cMsg += '        </cteDistDFeInteresse>'                                                                   + CRLF
			cMsg += '    </soapenv:Body>'                                                                              + CRLF
			cMsg += '</soapenv:Envelope>'    		                                                                   + CRLF
			
		else
		
		    cMsg := '<soapenv:Envelope xmlns:soapenv="http://www.w3.org/2003/05/soap-envelope">'                       + CRLF
			cMsg += '    <soapenv:Header/>'                                                                            + CRLF
			cMsg += '    <soapenv:Body>'                                                                               + CRLF
			cMsg += '        <nfeDistDFeInteresse xmlns="http://www.portalfiscal.inf.br/nfe/wsdl/NFeDistribuicaoDFe">' + CRLF
			cMsg += '            <nfeDadosMsg>'                                                                        + CRLF
			cMsg += '                 <distDFeInt xmlns="http://www.portalfiscal.inf.br/nfe" versao="1.01">'       	   + CRLF
			cMsg += '                     <tpAmb>'+cTpAmb+'</tpAmb>'                                                   + CRLF
			cMsg += '                     <cUFAutor>'+cUfAutor+'</cUFAutor>'                                           + CRLF
			cMsg += '                     <CNPJ>'+cCNPJEmp+'</CNPJ>'                                                   + CRLF
		
		if cTp = "CC"
		  
		    cMsg += '                      <distNSU>'                                                              + CRLF
		    cMsg += '                           <ultNSU>'+alltrim(cChaveNFe)+'</ultNSU>'                           + CRLF
		    cMsg += '                      </distNSU>'                                                             + CRLF
		   
        elseif cTp = "CN"
		  
		    cMsg += '                      <consNSU>'                                                              + CRLF
		    cMsg += '                           <NSU>'+alltrim(cChaveNFe)+'</NSU>'                                 + CRLF
		    cMsg += '                      </consNSU>'                                                             + CRLF
		
		else
		   
		    cMsg += '                      <consChNFe>'                                                            + CRLF
		    cMsg += '                           <chNFe>'+alltrim(cChaveNFe)+'</chNFe>'                             + CRLF
		    cMsg += '                      </consChNFe>'                                                           + CRLF
		  
		endif
		   
	    cMsg += '                 </distDFeInt>'                                                                   + CRLF
		cMsg += '            </nfeDadosMsg>'                                                                       + CRLF
		cMsg += '        </nfeDistDFeInteresse>'                                                                   + CRLF
		cMsg += '    </soapenv:Body>'                                                                              + CRLF
		cMsg += '</soapenv:Envelope>'                                                                              + CRLF
    
	endif

	//Envia uma mensagem SOAP personalizada ao servidor
	For nAtr := 1 To nTotTent

		lRet := oWsdl:SendSoapMsg(cMsg)
		lRet := .T.
		
		if lRet
			Exit
		endif

		Sleep(1500)  
		
	    ConOut("Tentativa XM_TENTSEND "+AllTrim(Str(nAtr))+" [HFBxXML] - Erro SendSoapMsg: " + oWsdl:cError)
	    ConOut("Tentativa XM_TENTSEND "+AllTrim(Str(nAtr))+" [HFBxXML] - Erro SendSoapMsg FaultCode: " + oWsdl:cFaultCode)
	    //U_MyAviso("Erro SendSoapMsg","Tentativa "+AllTrim(Str(nAtr))+" [HFzBxXML] - Erro SendSoapMsg: " + oWsdl:cError,{"Ok"},3)
	   
    Next nAtr
    
    If ! lRet 
    
        ConOut("[HFBxXML] - Erro SendSoapMsg: " + oWsdl:cError)

        cLog := oWsdl:cError

		if lMostra
			U_MyAviso("Erro SendSoapMsg","[HFBxXML] - "+oWsdl:cError ,{"Ok"},3)
		endif

		ConOut("[HFBxXML] - Erro SendSoapMsg FaultCode: " + oWsdl:cFaultCode)
		cInfo := AllTrim(oWsdl:cError) + " " + oWsdl:cFaultCode

		if lMostra
			U_MyAviso("Erro SendSoapMsg FaultCode","[HFBxXML] - "+oWsdl:cFaultCode ,{"Ok"},3)
		endif
    
		lContinua := .F.
    
	EndIf

//    Alert( oWsdl:GetSoapResponse() )
        
EndIf
 
//Se for continuar
If lContinua

	//Pega a resposta do SOAP
	For nAtr := 1 To nTotTent
	
		cMsgRet := oWsdl:GetSoapResponse()

		cBkpXml := cMsgRet

		cMsgRet := EncodeUTF8(cMsgRet)
		cMsgRet := NoAcento(cMsgRet)

		//Executa rotina para retirar os caracteres especiais
		cMsgRet := u_zCarEspec( cMsgRet )
	                    
		//Transforma a resposta em um objeto
		cError := ""
		cWarning := ""
		oXmlDocZip := XmlParser(cMsgRet, "_", @cError, @cWarning)

		cMsgRet := cBkpXml
	
		if oXmlDocZip = NIL
			ConOut("Tentativa XM_TENTSEND "+AllTrim(Str(nAtr))+" [HFBxXML] - Erro cError: " + cError+" "+cWarning)
		Else
			Exit
		endif

		Sleep(1500)  
		
	Next nAtr
 
	//Se existir Warning, mostra no console.log
	If ! Empty(cWarning) 
	
	    ConOut("[HFBxXML] - Alerta cWarning: " + cWarning)
	    cInfo := cWarning
	
	    if lMostra .and. oXmlDocZip = NIL
	    	U_MyAviso("Alerta cWarning","[HFBxXML] - "+cWarning ,{"Ok"},3)
	    endif
	    
	EndIf
 
	//Se houve erro, n„o permitir· prosseguir
	If ! Empty(cError) .and. oXmlDocZip = NIL
	
	    ConOut("[HFBxXML] - Erro cError: " + cError)
	    cLog := cError
	
		if lMostra .and. oXmlDocZip = NIL
			
			U_MyAviso("Erro cError","[HFBxXML] - "+cError ,{"Ok"},3)
		
		endif
			        
		lContinua := .F.
	            
	EndIf
	        
EndIf
 
//Se for continuar
If lContinua

	//Se a tag DocZip existir (for diferente de Undefinied)
	if cMod $ "57,67"

		If cTp $ "DC,CN" .And. (Type("oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_CTEDISTDFEINTERESSERESPONSE:_CTEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP") != "U")
 
            //Pega tag que contÈm XML em zip
            cXmlGZip := oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_CTEDISTDFEINTERESSERESPONSE:_CTEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP:TEXT
            cExt := "-procCte.xml"
	
            //Gera arquivo XML
            cArqXML := fGeraXML(cXmlGZip, cChaveNFe+cExt, @cLog, @cInfo, lMostra)
    
            //alert(cArqXML)
    
         elseif  cTp $ "CC" .And. (Type("oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_CTEDISTDFEINTERESSERESPONSE:_CTEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP") != "U")
	
			 oWSrNfe := oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_CTEDISTDFEINTERESSERESPONSE:_CTEDISTDFEINTERESSERESULT
		     oDet := oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_CTEDISTDFEINTERESSERESPONSE:_CTEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP
		     oDet := iif( valtype(oDet)="O", { oDet }, oDet )
     
		     if Type("oWSrNfe:_RETDISTDFEINT:_MAXNSU:TEXT") <> "U"
		     
		     	cArqXML := oWSrNfe:_RETDISTDFEINT:_MAXNSU:TEXT
		     	
		     else
		     
		     	cArqXML := "999999999999999"
		     	
		 	 endif
 	 
		 	 if Type("oWSrNfe:_RETDISTDFEINT:_ULTNSU:TEXT") <> "U"
		 	 
		 	 	cChaveNFe := oWSrNfe:_RETDISTDFEINT:_ULTNSU:TEXT
		 	 	
		 	 endif
 	 
		 else
	
			oWSrNfe := oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_CTEDISTDFEINTERESSERESPONSE:_CTEDISTDFEINTERESSERESULT
			
			if oWSrNfe = NIL
			
		        conout("[HFzBxXML] - CTE _DOCZIP n„o retornado pelo SEFAZ. Ocorreu algum problema no momento de baixar o arquivo da sefaz!")
		        cLog := "_DOCZIP n„o retornado pelo SEFAZ"
				cInfo := "Sefaz N„o Retornou o XML."
				
		        if lMostra
		        	U_MyAviso("CTE Erro","[HFBxXML] - "+"_DOCZIP n„o retornado pelo SEFAZ." ,{"Ok"},3)
		        endif
		        
		    else
		    
				cLog   := oWSrNfe:_RETDISTDFEINT:_CSTAT:TEXT+" Retorno do Sefaz"
				cInfo  := oWSrNfe:_RETDISTDFEINT:_XMOTIVO:TEXT
				
				if oWSrNfe:_RETDISTDFEINT:_CSTAT:TEXT = "137"
				
					cInfo  := "DOCUMENTO N√O DISPONIVEL PARA DOWNLOAD VIA WEB SERVICE (DF-e)"
					l137   := .T.
					
				EndIf

				if oWSrNfe:_RETDISTDFEINT:_CSTAT:TEXT = "656"
				
					cInfo  := "CONSUMO INDEVIDO"
					
					if lMostra
		        		U_MyAviso("CTE Erro","[HFBxXML] CONSUMO INDEVIDO." ,{"Ok"},3)
		        	endif
					
				EndIf
				
		    endif
		    
		    if cTp $ "CC"
		    
		         if Type("oWSrNfe:_RETDISTDFEINT:_MAXNSU:TEXT") <> "U"
		         
		         	cArqXML := oWSrNfe:_RETDISTDFEINT:_MAXNSU:TEXT
		         	
		         else
		         
		         	cArqXML := "999999999999999"
		         	
		     	 endif
		     	 
		     	 if Type("oWSrNfe:_RETDISTDFEINT:_ULTNSU:TEXT") <> "U"
		     	 
		         	 cChaveNFe := oWSrNfe:_RETDISTDFEINT:_ULTNSU:TEXT
		         	 
		         endif
		         	 
		     endif
		     	
		endif
    
	else
		
		 If cTp $ "DC,CN" .And. (Type("oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP") != "U")
		    
		 	//Pega tag que contÈm XML em zip
		 	cXmlGZip := oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP:TEXT
		    
		 	if UPPER(Substr(oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP:_SCHEMA:TEXT,1,7)) = UPPER("procNFe")
			    	
			    cExt := "-procNfe.xml" 
			  
			elseif UPPER(Substr(oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP:_SCHEMA:TEXT,1,6)) = UPPER("ResNFe") 
			    	
				cExt := "-resuNFe.xml"
			    	
			else
			    
			    cExt := UPPER(Substr(oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP:_SCHEMA:TEXT,1,7)) + ".xml"
			   
			endif
			
		    //Gera arquivo XML
		    cArqXML := fGeraXML(cXmlGZip, cChaveNFe+cExt, @cLog, @cInfo, lMostra)
	    
		    if UPPER(Substr(oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP:_SCHEMA:TEXT,1,6)) = UPPER("ResNFe")
		    	
		    	cLog := "633 Falta Manif. "+AllTrim(ClOG)
		    	
		    endif
	    
		    //alert(cArqXML)
		    
		elseif  cTp $ "CC" .And. (Type("oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP") != "U")
			
			 oWSrNfe := oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT
		     oDet := cXmlGZip := oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP
		     oDet := iif( valtype(oDet)="O", { oDet }, oDet )
		     
		     if Type("oWSrNfe:_RETDISTDFEINT:_MAXNSU:TEXT") <> "U"
		     
		     	cArqXML := oWSrNfe:_RETDISTDFEINT:_MAXNSU:TEXT
		  
		     else
		     
		     	cArqXML := "999999999999999"
		     	
		 	 endif
		 	 
		     if Type("oWSrNfe:_RETDISTDFEINT:_ULTNSU:TEXT") <> "U"
		     
		      	cChaveNFe := oWSrNfe:_RETDISTDFEINT:_ULTNSU:TEXT
		      	
		     endif
		     
		else

			oWSrNfe := oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT
			
			if oWSrNfe = NIL
			
		        conout("[HFBxXML] - _DOCZIP n„o retornado pelo SEFAZ. Ocorreu algum problema no momento de baixar o arquivo da sefaz!")
		        cLog := "_DOCZIP n„o retornado pelo SEFAZ"
				cInfo := "Sefaz N„o Retornou o XML."
				l137   := .T.
				
		        if lMostra
		        	U_MyAviso("Erro","[HFBxXML] - "+"_DOCZIP n„o retornado pelo SEFAZ." ,{"Ok"},3)
		        endif
		        
		    else
    
				cLog   := oWSrNfe:_RETDISTDFEINT:_CSTAT:TEXT+" Retorno do Sefaz"
				cInfo  := oWSrNfe:_RETDISTDFEINT:_XMOTIVO:TEXT
				
				if oWSrNfe:_RETDISTDFEINT:_CSTAT:TEXT = "137"  //aqui pode ser falta de manifestaÁ„o tambÈm
					
					cInfo  := "NENHUM DOCUMENTO LOCALIZADO(137)"
					l137   := .T.
					
				EndIf

				if oWSrNfe:_RETDISTDFEINT:_CSTAT:TEXT = "656"
				
					cInfo  := "CONSUMO INDEVIDO"
					
					if lMostra
		        		U_MyAviso("Erro","[HFBxXML] CONSUMO INDEVIDO." ,{"Ok"},3)
		        	endif
					
				EndIf
		
			endif
    
		    if cTp $ "CC"
		    
		         if Type("oWSrNfe:_RETDISTDFEINT:_MAXNSU:TEXT") <> "U"
		         	
		         	cArqXML := oWSrNfe:_RETDISTDFEINT:_MAXNSU:TEXT
		         	
		         else
		         
		         	cArqXML := "999999999999999"
		         	
		     	 endif
		     	 
		         if Type("oWSrNfe:_RETDISTDFEINT:_ULTNSU:TEXT") <> "U"
		         	cChaveNFe := oWSrNfe:_RETDISTDFEINT:_ULTNSU:TEXT
				 endif
					         
			 endif
	         	
		endif
	        
    endif
        
EndIf
 
RestArea(aArea)
   
Return cArqXML


Static Function fGeraXML(cConteudo, cChave, cLog, cInfo, lMostra)

Local aArea        := getArea()
Local lRet         := .T. 
Local cArquivo     := cChave //+ ".xml"
Local cDiretorio   := AllTrim(SuperGetMv("MV_X_PATHX"))
Local nTamanho     := 0
Local cUnXML       := ""
Local cDecode64    := ""
Local cArqFull     := ""
Local lHouveErro   := .F.

Private xZBS  	   := GetNewPar("XM_TABSINC","ZBS")
Private xZBS_ 	   := iif(Substr(xZBS,1,1)=="S", Substr(xZBS,2,2), Substr(xZBS,1,3)) + "_"
 
//Se o ˙ltimo caracter do diretÛrio n„o for \, ser· barra \
If SubStr(cDiretorio, Len(cDiretorio), 1) != "\"
    cDiretorio += "\"
EndIf
 
//Define o caminho final do arquivo
cArqFull := cArquivo
 
//Pega o tamanho e descriptografa o conte˙do
nTamanho  := Len(cConteudo)
cDecode64 := Decode64(cConteudo)
lRet      := GzStrDecomp(cDecode64, nTamanho, @cUnXML)
  
//Se deu certo
If lRet
     
    //Se o diretÛrio n„o existir, cria
    If ! ExistDir(cDiretorio)
        MakeDir(cDiretorio)
    EndIf

	DbSelectArea(xZBS)
	DbSetOrder(3)
	if DbSeek(cChave)

		RecLock(xZBS, .F. )

		( xZBS )->(FieldPut(FieldPos(xZBS_+"XML"), cUnXML ))

		( xZBS )->(MsUnLock())

	endif

    //Cria o arquivo com o conte˙do
    //lRet := MemoWrite(cDiretorio+cArquivo, cUnXML)
    lRet := U_HFGFRead(cDiretorio+cArquivo,cUnXML)

    //Se houve falha, mostra mensagem no console.log
    If ! lRet
    
        ConOut("[fGeraXML] - N„o foi possivel criar o arquivo: " + cDiretorio + cArqFull)
        cLog  := "N„o foi possivel criar o arquivo: " + cDiretorio + cArqFull
        cInfo := "N„o foi possivel criar o arquivo: " + cDiretorio + cArqFull
        
        if lMostra
        	U_MyAviso("[fGeraXML]","[HFBxXML] - "+"N„o foi possivel criar o arquivo: " + cDiretorio + cArqFull ,{"Ok"},3)
        endif
        
        lHouveErro := .T.
        
    else
    
    	cLog := "Download Efetuado"
    	cInfo := "Download Efetuado com Sucesso"
        	
    EndIf
 
    //Se n„o deu certo, mostra mensagem no console.log
Else

    ConOut("[fGeraXML] - Houve algum erro na descompactaÁ„o do arquivo!")
    cLog := "Houve algum erro na descompactaÁ„o do arquivo!"
    cInfo := "Houve algum erro na descompactaÁ„o do arquivo!"
    
    if lMostra
    
       	U_MyAviso("[fGeraXML]","[HFBxXML] - "+"Houve algum erro na descompactaÁ„o do arquivo" ,{"Ok"},3)
        
        endif
        
        lHouveErro := .T.
        
    EndIf
 
    //Se houve erro, zera o nome do arquivo para retornar em branco
    If lHouveErro
    	cArqFull := ""
    EndIf
 
    RestArea(aArea)
    
Return cArqFull


Static Function slvxmlzbz(cNomArq, lAuto, lEnd, oProcess, cLogProc, nCount, cVem, cChv, cInfo, cTpDow)

Local lRet := .T.
Local aArea := GetArea()
Local nOrd  := (xZBZ)->( indexord() )

default cTpDow := ""

if cTpDow = "R"  //Grava SÛ Na ZBZ

	U_HFXMLRES(cNomArq, lAuto, lEnd, oProcess, cLogProc, nCount, cVem, cChv, cInfo, cTpDow )
	//U_HFSLVXML(cNomArq, lAuto, lEnd, oProcess, cLogProc, nCount, cVem, , , cTpDow )
	
Else

	//U_HFXMLRES(cNomArq, lAuto, lEnd, oProcess, cLogProc, nCount, cVem, cChv, cInfo, cTpDow )  //para testar
	//alert(cNomArq)
	U_HFSLVXML(cNomArq, lAuto, lEnd, oProcess, cLogProc, nCount, cVem, , , cTpDow )
	
Endif

DbSelectArea( xZBZ )
dbSetORder( 3 )

If ! (xZBZ)->( dbSeek( cChv ) )  //Arquivo Baixado mas n„o conseguiu importar
	//cInfo := "Download Efetuado, mas n„o foi possÌvel importar para a Base o XML "+Substr(cChv,1,44)
	cInfo := "Download Efetuado, Xml resumido " + Substr(cChv,1,44)
	lRet := .F.
EndIf

(xZBZ)->( dbSetORder( nOrd ) )

RestArea( aArea )

Return( lRet )



User Function HFGFRead(cFinalF,cFileToWrite) //28032016

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


//UF  U_HFUFMAT
User Function HFUFMAT( cCnpj )

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
		If U_HFXMLLIC(.F.)
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


//Tentar Baixar o 55 da ZBS
//Retorna 0 - OK
//Retorna 1 - N„o encontrou ou sem ManifestaÁ„o, tem que fazer o NFeDistr
//Retorna 2 - Encontrou na ZBS mas n„o conseguiu fazer o bixo
User Function HFXMLCAN(cCnpj,cChave,cAmb,cIdEnt,cNsu,cLogProc,lMostra,cInfo)

Local nOrd   := 0
Local nRet   := 0
Local nChv   := 0
Local cDir   := AllTrim(SuperGetMv("MV_X_PATHX"))
Local cXml   := ""
Local cMsg   := ""
Local cStt   := ""
Local nHandle:= 0
Local lOk    := .T.
Local cChaveArq:= ""

Local aAreaZBS := (xZBS)->( GetArea() )
Local aAreaZBZ := (xZBZ)->( GetArea() )

Default cLogProc := ""
Default lMostra  := .F.

Private oWs,oWsrNfe,oWsdNfe,cErro:="",cWarning:=""

(xZBS)->( dbSetOrder( 3 ) )

if (xZBS)->( dbSeek( Substr( cChave,1,44 ) ) )

	if (xZBS)->( FieldPos( xZBS_+"XML" ) ) > 0
	
		if ! Empty(( xZBS )->(FieldGet(FieldPos(xZBS_+"XML"))))
		
			cXml := ( xZBS )->(FieldGet(FieldPos(xZBS_+"XML")))
			
			if upper("<resNFe ") $ upper( cXml )
			
				nRet := 1
				
			elseif upper("<procNFe ") $ upper( cXml )
			
				nRet := 2
				
			else
			
				nRet := 3
				
			endif
			
		else
		
			nRet := 3  //Vai sem xml mesmo, sÛ registro,  aqui vem bastante
			
		endif
		
	else
	
		nRet := 3   //Vai sem xml mesmo, sÛ registro, Fadiga, aqui nunca cai
		
	endif
	
Else

	nRet := 0  //Vai sem xml mesmo
	
EndIF 

if nRet == 0 .or. nRet == 1 .or. nRet == 2 .or. nRet == 3

	if nRet == 0
	
		( xZBS )->( DbSetOrder( 3 ) )
		
		If .Not. ( xZBS )->(dbSeek( Substr( cChave,1,44 ) ) )
		
			RecLock(xZBS, .T. )
			
			( xZBS )->(FieldPut(FieldPos(xZBS_+"FILIAL"), XFilial(xZBS) ))  
			( xZBS )->(FieldPut(FieldPos(xZBS_+"CHAVE")	,  Substr( cChave,1,44 ) ))
			( xZBS )->(FieldPut(FieldPos(xZBS_+"AMB")	,  cAmb ))
			( xZBS )->(FieldPut(FieldPos(xZBS_+"DEST")	,  cCnpj ))
			( xZBS )->(FieldPut(FieldPos(xZBS_+"IDENT")	,  cIdEnt ))
			
			If ( xZBS )->( FieldPos(xZBS_+"MODELO") ) > 0
			
				( xZBS )->(FieldPut(FieldPos(xZBS_+"MODELO"), Substr(cChave,21,2) ))
				
			EndIF
			
			if (xZBS)->(FieldPos(xZBS_+"TPROT")) > 0 //Tipo de Rotina Job ou Manual
			
				if Empty(  (xZBS)->(FieldGet(FieldPos(xZBS_+"TPROT"))) )
				
					if Type("cTpRt") <> "U"
					
						(xZBS)->(FieldPut(FieldPos(xZBS_+"TPROT"), cTpRt ))
						
					endif
					
				endif
				
			endif
			
			( xZBS )->(FieldPut(FieldPos(xZBS_+"ST")	, "21" ))
			( xZBS )->(FieldPut(FieldPos(xZBS_+"CSITCO"), "4" ))
			( xZBS )->(FieldPut(FieldPos(xZBS_+"CNF")	, Substr( cChave, 26, 9 ) ))
			( xZBS )->(FieldPut(FieldPos(xZBS_+"SERIE")	, Substr( cChave, 23, 3 ) ))
			( xZBS )->(FieldPut(FieldPos(xZBS_+"CNPJEM"), Substr( cChave, 07, 14 ) ))
			( xZBS )->(FieldPut(FieldPos(xZBS_+"CSITNF"), "3" ))
			( xZBS )->(FieldPut(FieldPos(xZBS_+"DHRECB"), dDataBase ))
			( xZBS )->(MsUnLock())
			
		Endif
		
	Endif
	
	//Gravar de todo Jeito
	U_HFXMLRES("", .T., .F., NIL, @cLogProc, 0, "2", Substr(cChave,1,44), "", "C", cCnpj  )
	
endif

DelClassIntf()

DbSelectArea( xZBZ )

(xZBZ)->( dbSetOrder(3) )

If ! (xZBZ)->( dbSeek( Substr( cChave,1,44 ) ) )  //Arquivo Baixado mas n„o conseguiu importar
	
	nRet := 2
	
Else

	nRet := 0
	
endif

(xZBS)->(RestArea( aAreaZBS ))
(xZBZ)->(RestArea( aAreaZBZ ))

DelClassIntf()

return( nRet )


Static Function __Dummy(lRecursa) //warning W0010 Static Function <?> never called

lRecursa := .F.

IF (lRecursa)

    __Dummy(.F.)
    U_HFXML16D()
    U_HFXML16SM()
    U_HFXML16JB()
    U_HFXML16CD()
    U_HFXML16BS()
    
EndIF
	
Return(lRecursa)
