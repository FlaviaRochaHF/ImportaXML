#Include "TOTVS.ch"
#Include "Protheus.ch"
#Include "ApWebSrv.ch"
#Include "TopConn.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "COLORS.CH"
#INCLUDE 'RWMAKE.CH'
#INCLUDE "PRTOPDEF.CH"
#INCLUDE "HTTPCLASS.CH"
#INCLUDE "FWMVCDEF.CH"


Static lUnix     := IsSrvUnix()
Static cBarra    := Iif(lUnix,"/","\")

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ HFXMLMAN ³ Autor ³ Eneovaldo Roveri Jr   ³ Data ³18/07/2019³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Rotina de Manifestação do Destinatário                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/*{Protheus.doc} zBxXML
@olhe Abaixo os links usados como referência para montagem da função
        Link 01 - http://tdn.totvs.com/display/tec/Classe+TWsdlManager
        Link 02 - http://tdn.totvs.com/display/tec/SOAP+1.1+e+SOAP+1.2
        Link 03 - http://tdn.totvs.com/display/tec/XmlParser                
        Link 04 - http://www.nfe.fazenda.gov.br/portal/exibirArquivo.aspx?conteudo=iGDFY8YBs28=
    Dúvidas quanto a Parse:
        Link 01 - https://centraldeatendimento.totvs.com/hc/pt-br/articles/360022658731-MP-ADVPL-Peer-certificate-cannot-be-authenticated-with-given-CA-certificates
        Link 02 - http://tdn.totvs.com/display/tec/Acesso+a+Web+Services+que+exigem+certificados+de+CA
/*/

USer Function HFXMLMAN(aChaves,cEveMn,cDesEven,cVerMn,cRetMn,xMotMn,cLog,cInfo,aRet,lMostra,nAtraso)

Local lRet := .T.
Local nI   := 0

Default cEveMn   := ""
Default cDesEven := ""
Default cVerMn   := ""
Default cRetMn   := ""
Default xMotMn   := ""
Default cLog     := ""
Default cInfo    := ""
Default aRet     := {}
Default lMostra  := .F.
Default nAtraso  := 0

if empty(cVerMn)
	cVerMn  := GetNewPar("XM_XVERMAN","4.00")
endif

if len( aChaves ) < 1

	lRet   := .F.
	cRetMn := "XXX"
	xMotMn := "(HF)Nenhuma Chave Informada"
	
elseif Len(aChaves) > 20

	lRet   := .F.
	cRetMn := "XXX"
	xMotMn := "(HF)Numero de Chaves Informadas é maior que 20"
	
else

	if empty(cEveMn)
		//Pedir Evento
		if lMostra
		endif
	endif
	
	if empty(cDesEven)
		cDesEven:= iif(cEveMn=="210200","Confirmacao da Operacao",;
			  iif(cEveMn=="210210","Ciencia da Operacao",;
			  iif(cEveMn=="210220","Desconhecimento da Operacao",;
			  iif(cEveMn=="210240","Operacao nao Realizada", "" ))))
	endif
	
	if cEveMn = "210240"
		//Verificar Justificativas
		if lMostra
		endif
	endif
	
	if empty(cEveMn)
	
		lRet   := .F.
		cRetMn := "XXX"
		xMotMn := "(HF)Evento Não Informado"
		
	else
	
		lRet := U_HFMANNFE(aChaves,cEveMn,cDesEven,cVerMn,@cRetMn,@xMotMn,@cLog,@cInfo,@aRet,lMostra,nAtraso)
	
	endif
	
	if lRet
	
		U_HFGRVZBE( aRet, cEveMn )
		
	endif
	
endif

Return(lRet)
 
 
User Function HFMANNFE(aChaves,cEveMn,cDesEven,cVerMn,cRetMn,xMotMn,cLog,cInfo,aRet,lMostra,nAtraso)

Local aArea     := GetArea()
Local lRet      := .T.
Local cURL      := ""
Local cMsg      := ""
Local oWsdl     := Nil
Local cMsgRet   := ""
Local cError    := ""
Local cWarning  := ""
Local cXmlGZip  := ""
Local cArqXML   := ""
Local cUfAutor  := "91" //SuperGetMV("MV_X_BXUF",  .F., "35")  //pegar do sigamat
Local cTpAmb    := ""
Local cCNPJEmp  := Alltrim(SM0->M0_CGC)                 //ihi
Local nLote       := 0
Local cCACertFile := ""
Local cCertFile   := ""
Local cKeyFile    := ""
Local cKeyPwd     := ""
Local nVersion    := ""
Local nTimeO      := ""
Local lContinua   := .T.
Local cIdEnt 	  := ""  //U_GetIdEnt()
Local cChaveNFe   := ""
Local cJustEv     := ""
Local nI          := 0
Local nTotTent    := GetNewPar("XM_TENTSEND", 5 )
Local nAtr := 0
Local cChaves     := ""
Local cHrVerao    := "2"
Local cHorario    := "2"

Default nAtraso   := 0
Default cLog      := ""

Private oXmlDocZip, oDet

if len(aChaves) > 0

	cChaves     := iif( len(aChaves) == 1, aChaves[1][1], aChaves[1][1]+" Até "+aChaves[len(aChaves)][1] )

else

	cChaves     := "NOCHAVE"
    endif

    if nTotTent <= 0
    	nTotTent := 1
    endif
 
	//cHrVerao := Left(oWS:oWsCfgCCeResult:cHoraVeraoCCe,1)
cHrVerao := GetNewPar("XM_HRVERAO","2",cFilAnt)

If !PutMv("XM_HRVERAO",cHrVerao)
	SX6->(RecLock("SX6",.T.))
		SX6->X6_FIL     := cFilAnt //xFilial( "SX6" )
		SX6->X6_VAR     := "XM_HRVERAO"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Horario de Verão via HF 1=Sim 2=Não"
		SX6->(MsUnLock())
	PutMv("XM_HRVERAO",cHrVerao)
	
EndIf

cHorario := GetNewPar("XM_HORARIO","1",cFilAnt)

If !PutMv("XM_HORARIO",cHorario)

	SX6->(RecLock("SX6",.T.))
		SX6->X6_FIL     := cFilAnt //xFilial( "SX6" )
		SX6->X6_VAR     := "XM_HORARIO"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Fuso Horario da Filial via HF"
		SX6->(MsUnLock())
	PutMv("XM_HORARIO",cHorario)
	
EndIf

cTpAmb := ( GetNewPar("XM_AMBNFE","1",cFilAnt) )

If !PutMv("XM_AMBNFE",cTpAmb)

	SX6->(RecLock("SX6",.T.))
		SX6->X6_FIL     := cFilAnt //xFilial( "SX6" )
		SX6->X6_VAR     := "XM_AMBNFE"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Ambiente download NFE por CNPJ via HF"
		SX6->(MsUnLock())
	PutMv("XM_AMBNFE",cTpAmb)
	
EndIf
 
cCACertFile := GetNewPar("XM_CERTCA" ,"\certs\000001_ca.pem"  ,cFilAnt)
cCertFile   := GetNewPar("XM_CERTCER","\certs\000001_cert.pem",cFilAnt)
cKeyFile    := GetNewPar("XM_CERTKEY","\certs\000001_key.pem" ,cFilAnt)
cKeyPwd     := GetNewPar("XM_CERTPSW",""		              ,cFilAnt)
nVersion    := GetNewPar("XM_CERTPRO",0)
nTimeO      := GetNewPar("XM_CERTTIM",120)
nLote       := (GetNewPar("XM_LOTEMAN",0) + 1)
 
if cVerMn == "4.00"

	cURL := "https://www.nfe.fazenda.gov.br/NFeRecepcaoEvento4/NFeRecepcaoEvento4.asmx?WSDL"

else

	if cTpAmb == "1"
	
		cURL := "https://www.nfe.fazenda.gov.br/RecepcaoEvento/RecepcaoEvento.asmx?WSDL"
	
	else
	
		cURL := "https://hom.nfe.fazenda.gov.br/RecepcaoEvento/RecepcaoEvento.asmx?WSDL"
    	
    endif
    
endif
 
//Instância a classe, setando as parâmetrizações necessárias
oWsdl := TWsdlManager():New()
oWsdl:cSSLCACertFile := cCACertFile
oWsdl:cSSLCertFile   := cCertFile
oWsdl:cSSLKeyFile    := cKeyFile
oWsdl:cSSLKeyPwd     := cKeyPwd
oWsdl:nSSLVersion    := nVersion
oWsdl:nTimeout       := nTimeO
oWsdl:lSSLInsecure   := .T.

//Tenta fazer o Parse da URL
For nAtr := 1 To nTotTent

	lRet := oWsdl:ParseURL(cURL)
	
   	if lRet
   		Exit
   	endif

	 Sleep(1500)  
   	
    ConOut("Tentativa XM_TENTSEND "+AllTrim(Str(nAtr))+" [HFXMLMAN] - Erro ParseURL: " + oWsdl:cError)

Next

If ! lRet 

    ConOut("[HFXMLMAN] - Erro ParseURL: " + oWsdl:cError)
    cLog := oWsdl:cError
    cInfo := oWsdl:cError
    
    if lMostra
    	U_MyAviso("Erro ParseURL","[MAN01]"+oWsdl:cError ,{"Ok"},3)
    endif
    
    lContinua := .F.
    
EndIf
 
//Se for continuar o processamento
If lContinua 

    //Tenta definir a operação
    For nAtr := 1 To nTotTent
    
        if cVerMn == "4.00"
        	lRet := oWsdl:SetOperation("nfeRecepcaoEventoNF")  //nfeRecepcaoEventoNF
        else
        	lRet := oWsdl:SetOperation("nfeRecepcaoEvento")  //nfeRecepcaoEventoNF
        endif
        
       	if lRet
       		Exit
       	endif
       	
        ConOut("Tentativa XM_TENTSEND "+AllTrim(Str(nAtr))+" [HFXMLMAN] - Erro SetOperation: " + oWsdl:cError)
    
    Next
    
    If ! lRet 
    
        ConOut("[HFXMLMAN] - Erro SetOperation: " + oWsdl:cError)
        cLog := oWsdl:cError
        cInfo := oWsdl:cError
        
        if lMostra
        	U_MyAviso("Erro ParseURL","[MAN02]"+oWsdl:cError ,{"Ok"},3)
        endif
        
        lContinua := .F.
        
    EndIf
    
EndIf
 
//Se for continuar
If lContinua

    //Monta a mensagem que será enviada
    //cMsg := '<?xml version="1.0" encoding="utf-8"?>'+ CRLF
    if cVerMn == "4.00"
        
        cMsg := '<soap12:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap12="http://www.w3.org/2003/05/soap-envelope">' + CRLF
        cMsg += 	'<soap12:Body>'                                                                                    + CRLF
        cMsg += 	'<nfeDadosMsg xmlns="http://www.portalfiscal.inf.br/nfe/wsdl/NFeRecepcaoEvento4">'                 + CRLF
		cMsg += 		'<envEvento xmlns="http://www.portalfiscal.inf.br/nfe" versao="1.00">'                         + CRLF
		cMsg += 		'<idLote>'+strzero(nLote+1,15,0)+'</idLote>'         									       + CRLF
		
		For nI := 1 to Len(aChaves)
		
			if nI > 20
				Exit
			endif
			
			cChaveNFe := aChaves[nI][1]
			cXmlEnv := ""
	        cXmlEnv += 			'<evento xmlns="http://www.portalfiscal.inf.br/nfe" versao="1.00">' 			  + CRLF
	        cXmlEnv += 				'<infEvento Id="ID'+cEveMn+alltrim(cChaveNFe)+Alltrim(StrZero(1,2,0))+'">'    + CRLF
	        cXmlEnv += 					'<cOrgao>'+cUfAutor+'</cOrgao>'      								      + CRLF
	        cXmlEnv += 					'<tpAmb>'+cTpAmb+'</tpAmb>'                                               + CRLF
	        cXmlEnv += 					'<CNPJ>'+cCNPJEmp+'</CNPJ>'                                               + CRLF
	        cXmlEnv += 					'<chNFe>'+alltrim(cChaveNFe)+'</chNFe>'                                   + CRLF
	        cXmlEnv += 					'<dhEvento>'+U_HFDTTIME( cHrVerao, cHorario, nAtraso )+'</dhEvento>'      + CRLF
	        cXmlEnv += 					'<tpEvento>'+cEveMn+'</tpEvento>'                                         + CRLF
	        cXmlEnv += 					'<nSeqEvento>'+'1'+'</nSeqEvento>'                                        + CRLF
	        cXmlEnv += 					'<verEvento>1.00</verEvento>'                                             + CRLF
	        cXmlEnv += 					'<detEvento versao="1.00">'                                               + CRLF
	        cXmlEnv += 						'<descEvento>'+cDesEven+'</descEvento>'                               + CRLF
			if cEveMn == "210240"
				cJustEv := aChaves[nI][2]
				cXmlEnv += 					'<xJust>'+cJustEv+'</xJust>'                                          + CRLF
			endif
			
	        cXmlEnv += '				</detEvento>'				                                              + CRLF
	        cXmlEnv += '			</infEvento>'                                                                 + CRLF
	        cXmlEnv += '		</evento>'                                                                        + CRLF
			cXmlEnv := NoAcento(cXmlEnv)
			cXmlEnv := EncodeUTF8(cXmlEnv)
			cXmlEnv := MeuSignXml(cXmlEnv,"infEvento","Id",cIdEnt,cEveMn,alltrim(cChaveNFe))
			cMsg += cXmlEnv
			
		Next nI
		
        cMsg += '		</envEvento>'                															  + CRLF
		cMsg += '	</nfeDadosMsg>'                                                                               + CRLF
        cMsg += '	</soap12:Body>'                                                                               + CRLF
        cMsg += '</soap12:Envelope>'                                                                              + CRLF
    else
    
        cMsg := '<soap12:Envelope xmlns:soap12="http://www.w3.org/2003/05/soap-envelope" xmlns:rec="http://www.portalfiscal.inf.br/nfe/wsdl/RecepcaoEvento">' + CRLF
        cMsg += 	'<soap12:Header>'                                                                        + CRLF
        cMsg += 		'<rec:nfeCabecMsg>'                                                                  + CRLF
        cMsg += 			'<rec:versaoDados>1.00</rec:versaoDados>'										 + CRLF
        cMsg += 			'<rec:cUF>'+cUfAutor+'</rec:cUF>'												 + CRLF
        cMsg += 		'</rec:nfeCabecMsg>'                                     							 + CRLF
        cMsg += 	'</soap12:Header>'                                                                       + CRLF
        cMsg += 	'<soap12:Body>'                                                                          + CRLF
        cMsg += 	'<rec:nfeDadosMsg>'                                                                      + CRLF
		cMsg += 	'<envEvento xmlns="http://www.portalfiscal.inf.br/nfe" versao="1.00">'                   + CRLF
		cMsg += 		'<idLote>'+strzero(nLote+1,15,0)+'</idLote>' + CRLF
		
		For nI := 1 to Len(aChaves)
		
			if nI > 20
				Exit
			endif
			
			cChaveNFe := aChaves[nI][1]
			cXmlEnv := ""
	        cXmlEnv += 		'<evento xmlns="http://www.portalfiscal.inf.br/nfe" versao="1.00">' 				 + CRLF
	        cXmlEnv += 			'<infEvento Id="ID'+cEveMn+alltrim(cChaveNFe)+Alltrim(StrZero(1,2,0))+'">'       + CRLF
	        cXmlEnv += 				'<cOrgao>'+cUfAutor+'</cOrgao>'      									     + CRLF
	        cXmlEnv += 				'<tpAmb>'+cTpAmb+'</tpAmb>'                                            	     + CRLF
	        cXmlEnv += 				'<CNPJ>'+cCNPJEmp+'</CNPJ>'                                                  + CRLF
	        cXmlEnv += 				'<chNFe>'+alltrim(cChaveNFe)+'</chNFe>'                                      + CRLF
	        cXmlEnv += 				'<dhEvento>'+U_HFDTTIME( cHrVerao, cHorario, nAtraso )+'</dhEvento>'                         + CRLF
	        cXmlEnv += 				'<tpEvento>'+cEveMn+'</tpEvento>'                                            + CRLF
	        cXmlEnv += 				'<nSeqEvento>'+'1'+'</nSeqEvento>'                                           + CRLF
	        cXmlEnv += 				'<verEvento>1.00</verEvento>'                                                + CRLF
	        cXmlEnv += 				'<detEvento versao="1.00">'                                                  + CRLF
	        cXmlEnv += 					'<descEvento>'+cDesEven+'</descEvento>'                                  + CRLF
			
			if cEveMn == "210240"
				cJustEv := aChaves[nI][2]
				cXmlEnv += 				'<xJust>'+cJustEv+'</xJust>'                                             + CRLF
			endif
			
	        cXmlEnv += 				'</detEvento>'				                                                 + CRLF
	        cXmlEnv += 			'</infEvento>'                                                                   + CRLF
	        cXmlEnv += 		'</evento>'                                                                          + CRLF
			cXmlEnv := NoAcento(cXmlEnv)
			cXmlEnv := EncodeUTF8(cXmlEnv)
			cXmlEnv := MeuSignXml(cXmlEnv,"infEvento","Id",cIdEnt,cEveMn,alltrim(cChaveNFe))
			cMsg += cXmlEnv
			
		Next nI
		
        cMsg += 	'</envEvento>'                															   + CRLF
		cMsg += 	'</rec:nfeDadosMsg>'                                                                       + CRLF
        cMsg += 	'</soap12:Body>'                                                                           + CRLF
        cMsg += '</soap12:Envelope>'                                                                           + CRLF
        
    endif
    
    //alert( cMsg )
     
    //Envia uma mensagem SOAP personalizada ao servidor
    For nAtr := 1 To nTotTent
    
    	lRet := oWsdl:SendSoapMsg(cMsg)
		lRet := .T.
    	
    	if lRet
    		Exit
    	endif
    	
        ConOut("Tentativa XM_TENTSEND "+AllTrim(Str(nAtr))+" [HFXMLMAN] - Erro SendSoapMsg: " + oWsdl:cError)
        ConOut("Tentativa XM_TENTSEND "+AllTrim(Str(nAtr))+" [HFXMLMAN] - Erro SendSoapMsg FaultCode: " + oWsdl:cFaultCode)
    	//U_MyAviso("Erro SendSoapMsg","Tentativa "+AllTrim(Str(nAtr))+" [HFzBxXML] - Erro SendSoapMsg: " + oWsdl:cError,{"Ok"},3)
    
    Next nAtr

    If ! lRet 
    
        ConOut("[HFXMLMAN] - Erro SendSoapMsg: " + oWsdl:cError)
        cLog := oWsdl:cError
        
        if lMostra
        	U_MyAviso("Erro SendSoapMsg","[MAN03]"+oWsdl:cError ,{"Ok"},3)
        endif
        
        ConOut("[HFXMLMAN] - Erro SendSoapMsg FaultCode: " + oWsdl:cFaultCode)
        cInfo := AllTrim(oWsdl:cError) + " " + oWsdl:cFaultCode
        
        if lMostra
        	U_MyAviso("Erro SendSoapMsg FaultCode","[MAN04]"+oWsdl:cFaultCode ,{"Ok"},3)
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
                        
    	//Transforma a resposta em um objeto
    	cError := ""
    	cWarning := ""
    	oXmlDocZip := XmlParser(cMsgRet, "_", @cError, @cWarning)
    	
    	if oXmlDocZip = NIL
    		
    		ConOut("Tentativa XM_TENTSEND "+AllTrim(Str(nAtr))+" [HFXMLMAN] - Erro cError: " + cError+" "+cWarning)
    	
    	Else
    	
    		Exit
    		
    	endif
    	
    Next nAtr

    //Se existir Warning, mostra no console.log
    If ! Empty(cWarning)
    
        ConOut("[HFXMLMAN] - Alerta cWarning: " + cWarning)
        cInfo := cWarning
        
        if lMostra .and. oXmlDocZip = NIL
        	U_MyAviso("Alerta cWarning","[MAN05]"+cWarning ,{"Ok"},3)
        endif
        
    EndIf
     
    //Se houve erro, não permitirá prosseguir
    If ! Empty(cError)
    
        ConOut("[HFXMLMAN] - Erro cError: " + cError)
    	cLog := cError
    	
        if lMostra .and. oXmlDocZip = NIL
        	
        	U_MyAviso("Erro cError","[MAN06]"+cError ,{"Ok"},3)
        	
	    endif
	    
        lContinua := .F.
             
    EndIf
    
EndIf
 
//Se for continuar
If lContinua

    //Se a tag DocZip existir (for diferente de Undefinied)
    //IF oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFERECEPCAOEVENTORESULT:_RETENVEVENTO:_XMOTIVO:TEXT
    If Type("oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFERECEPCAOEVENTONFRESULT:_RETENVEVENTO") != "U"
    	
    	//Motivo do retorno
    	cRetMn := oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFERECEPCAOEVENTONFRESULT:_RETENVEVENTO:_CSTAT:TEXT
    	xMotMn := "[SFZ]"+oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFERECEPCAOEVENTONFRESULT:_RETENVEVENTO:_XMOTIVO:TEXT
    	
    	if (Type("oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFERECEPCAOEVENTONFRESULT:_RETENVEVENTO:_RETEVENTO") != "U")
    		
    		oDet := oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFERECEPCAOEVENTONFRESULT:_RETENVEVENTO:_RETEVENTO
    		oDet := iif( valtype(oDet)=="O", {oDet}, oDet )
    		cLog  := "[HFXMLMAN] "
    		
    		For nI := 1 To Len( oDet )
    		
    			if Len( oDet ) == 1
        			cRetMn := oDet[nI]:_INFEVENTO:_CSTAT:TEXT
					xMotMn := "[SFZ]"+oDet[nI]:_INFEVENTO:_XMOTIVO:TEXT
				Endif

				aEve := {}
				
				if Type( "oDet["+alltrim(Str(nI))+"]:_INFEVENTO:_CHNFE:TEXT" ) <> "U"
					
					aadd( aEve, oDet[nI]:_INFEVENTO:_CHNFE:TEXT )
					cLog  += "Ch " + oDet[nI]:_INFEVENTO:_CHNFE:TEXT
					
				Else
				
					aadd( aEve, aChaves[nI,1] )
					cLog  += "Ch " + aChaves[nI,1]
					
				endif
				
				if Type( "oDet["+alltrim(Str(nI))+"]:_INFEVENTO:_TPEVENTO:TEXT" ) <> "U"
					
					aadd( aEve, oDet[nI]:_INFEVENTO:_TPEVENTO:TEXT )
					cLog  += "Ev " + oDet[nI]:_INFEVENTO:_TPEVENTO:TEXT
					
				Else
				
					aadd( aEve, cEveMn )
					cLog  += "Ev " + cEveMn
					
				endif
				
				if Type( "oDet["+alltrim(Str(nI))+"]:_INFEVENTO:_CSTAT:TEXT" ) <> "U"
					
					aadd( aEve, oDet[nI]:_INFEVENTO:_CSTAT:TEXT )
					cLog  += "RetSef " + oDet[nI]:_INFEVENTO:_CSTAT:TEXT
					
				Else
				
					aadd( aEve, "[SFZ]" )
					cLog  += "RetSef Vazio "
					
				endif
				
				if Type( "oDet["+alltrim(Str(nI))+"]:_INFEVENTO:_XMOTIVO:TEXT" ) <> "U"
					
					aadd( aEve, "[SFZ]"+oDet[nI]:_INFEVENTO:_XMOTIVO:TEXT )
					cLog  += "Motivo " + oDet[nI]:_INFEVENTO:_XMOTIVO:TEXT
					
				Else
				
					aadd( aEve, "[SFZ]" )
					cLog  += "Motivo Vazio "+ CRLF
					
				endif
				
				if Type( "oDet["+alltrim(Str(nI))+"]:_INFEVENTO:_NSEQEVENTO:TEXT" ) <> "U"
					
					aadd( aEve, oDet[nI]:_INFEVENTO:_NSEQEVENTO:TEXT )
					
				Else
				
					aadd( aEve, "01" )
					
				endif
				
				aadd( aEve, cMsgRet )
				aadd( aRet, aEve )
				
    		Next nI
    		
			//conout("[HFXMLMAN] - "+cLog)
			
		else
		
			cLog  := "[SFZ]"+cRetMn
			cInfo := xMotMn
			
    	endif
    	
    else
    
    	lRet := .F.
        conout("[HFXMLMAN] - Ocorreu algum problema no momento de receber o retorno da sefaz! "+cChaves)
        cInfo := "[HFXMLMAN] - Ocorreu algum problema no momento de receber o retorno da sefaz!"+cChaves
        cLog  := "[HFXMLMAN] - Sefaz não retornou _SOAP_ENVELOPE:_SOAP_BODY:_NFERECEPCAOEVENTORESULT:_RETENVEVENTO"+cChaves
        xMotMn := "[HF] - Sefaz não retornou _SOAP_ENVELOPE:_SOAP_BODY:_NFERECEPCAOEVENTORESULT:_RETENVEVENTO"+cChaves
        cRetMn := "000"
    endif
        
EndIf
 
RestArea(aArea)
    
Return( lRet )
 

Static Function MeuSignXml(cXML,cTag,cAttID,cIdEnt,cEv,Chv)

Local cXmlSig := ""
Local cXmlToSign  := ""
Local cURI        := ""
Local cDir        := AllTrim(SuperGetMv("MV_X_PATHX")) + IIf(IsSrvUnix(),"certs/", "certs\")
Local cRootPath   := StrTran(GetSrvProfString("RootPath","")+IIf(!IsSrvUnix(),"\","/"),IIf(!IsSrvUnix(),"\\","//"),IIf(!IsSrvUnix(),"\","/"))
Local cStartPath  := StrTran(cRootPath+IIf(!IsSrvUnix(),"\","/")+GetSrvProfString("StartPath","")+IIf(!IsSrvUnix(),"\","/"),IIf(!IsSrvUnix(),"\\","//"),IIf(!IsSrvUnix(),"\","/"))
Local cArqXML     := Lower(CriaTrab(,.F.))
Local cMacro      := ""
Local cError      := ""
Local cWarning    := ""
Local cDigest     := ""
Local cSignature  := ""
Local cSignInfo   := ""
Local cIniXml     := ""
Local cFimXml     := ""
Local cNameSpace  := ""
Local cNewTag     := ""
Local cThreadID	  := "0" //GetSrvProfString("SPED_THREADID","0")
Local nAt         := 0
Local nAtVer  	  := 0
Local cCACertFile := GetNewPar("XM_CERTCA" ,"\certs\000001_ca.pem"  ,cFilAnt)
Local cCertFile   := GetNewPar("XM_CERTCER","\certs\000001_cert.pem",cFilAnt)
Local cKeyFile    := GetNewPar("XM_CERTKEY","\certs\000001_key.pem" ,cFilAnt)
Local cKeyPwd     := GetNewPar("XM_CERTPSW",""		                ,cFilAnt)


cRootPath  := StrTran(cRootPath,IIf(!IsSrvUnix(),"\\","//"),IIf(!IsSrvUnix(),"\","/"))
cStartPath := StrTran(cStartPath,IIf(!IsSrvUnix(),"\\","//"),IIf(!IsSrvUnix(),"\","/"))
cStartPath := StrTran(cStartPath,IIf(!IsSrvUnix(),"\\","//"),IIf(!IsSrvUnix(),"\","/"))

//dbSelectArea("SPED001")
//dbSetOrder(1)
//MsSeek(cIdEnt)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Obtenho a URI                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//cUri := SpedNfeId(cXML,cAttId)
//cUri := "ID21021035190704866345000426550070000352491008113272"
//cUri := Upper(cAttID)+cEv+Chv
cUri := HFIdSPED(cXML,cAttId)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Assina a NFe                                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case

	Case  FindFunction("EVPPrivSign") 
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Canoniza o XML                                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cXmlToSign := XmlC14N(cXml, "", @cError, @cWarning)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento para troca de caracter referente ao xml da ANFAVEA³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cXmlToSign := (StrTran(cXmlToSign,"&lt;/","</"))
		cXmlToSign = (StrTran(cXmlToSign,"/&gt;","/>"))  
		cXmlToSign = (StrTran(cXmlToSign,"&lt;","<"))  
		cXmlToSign = (StrTran(cXmlToSign,"&gt;",">"))  
		cXmlToSign = (StrTran(cXmlToSign,"<![CDATA[[ ","<![CDATA["))  
//		varinfo("cXmlToSign : ",cXmlToSign)
		//cXmlToSign := NoAcento(cXmlToSign)     //aquiiiiii GRABER RJ
		//cXmlToSign := EncodeUTF8(cXmlToSign)   //aquiiiiii GRABER RJ

		If Empty(cError) .And. Empty(cWarning)
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Retira a Tag anterior a tag de assinatura                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nAt := At("<"+cTag,cXmlToSign)
			cIniXML    := SubStr(cXmlToSign,1,nAt-1)
			cXmlToSign := SubStr(cXmlToSign,nAt)
			nAt := At("</"+cTag+">",cXmltoSign)
			cFimXML    := SubStr(cXmltoSign,nAt+Len(cTag)+3)
			cXmlToSign := SubStr(cXmlToSign,1,nAt+Len(cTag)+2)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Descobre o namespace complementar da tag de assinatura                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cNewTag := AllTrim(cIniXml)
			cNewTag := SubStr(cIniXml,2,At(" ",cIniXml)-2)
			cNameSpace := StrTran(cIniXml,"<"+cNewTag,"")
			cNameSpace := AllTrim(StrTran(cNameSpace,">",""))
			nAtver := At("versao",cNameSpace) // Pode ter um atributo versao Ex. ( xmlns="http://" versao="1.01")
			
			If nAtver > 0
				cNameSpace := SubStr(cNameSpace, 1, nAtver-1) // -2 por causa do espaco
				cNameSpace := RTrim(cNameSpace)
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Calcula o DigestValue da assinatura                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			 cDigest := StrTran(cXmlToSign,"<"+cTag+" ","<"+cTag +" "+cNameSpace+" ")
	         cDigest := XmlC14N(cDigest, "", @cError, @cWarning) 
	         cMacro  := "EVPDigest"
	         cDigest := Encode64(&cMacro.( cDigest , 3 ))
	         
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Calcula o SignedInfo  da assinatura                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cSignInfo := NfeSignedInfo(cUri,cDigest)
			cSignInfo := XmlC14N(cSignInfo, "", @cError, @cWarning) 
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Assina o XML                                                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cMacro   := "EVPPrivSign"
			//cSignature := &cMacro.(IIf(IsSrvUnix(),"/", "\")+cDir+cIdEnt+"_key.pem" , cSignInfo , 3 ,  "cofer1030", @cError)  //Decode64(AllTrim(SPED001->PASSCERT))
			//cSignature := EVPPrivSign( cKeyFile, cSignInfo, 3, cKeyPwd, @cError )
			cSignature := &cMacro.(cKeyFile , cSignInfo , 3 , cKeyPwd, @cError)  //Decode64(AllTrim(cKeyPwd))
			cSignature := Encode64(cSignature)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Envelopa a assinatura                                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cCert := GetCertificate(cCertFile,.F.,cIdEnt)
			
			If !Empty(cCert)
			
				cXmlToSign += '<Signature xmlns="http://www.w3.org/2000/09/xmldsig#">'
				cXmltoSign += cSignInfo
				cXmlToSign += '<SignatureValue>'+cSignature+'</SignatureValue>'
				cXmltoSign += '<KeyInfo>'
				cXmltoSign += '<X509Data>'			
				cXmltoSign += '<X509Certificate>'+cCert+'</X509Certificate>'
				cXmltoSign += '</X509Data>'
				cXmltoSign += '</KeyInfo>'
				cXmltoSign += '</Signature>'
				cXmlToSign := cIniXML+cXmlToSign+cFimXML
				//cXmlToSign := NoAcento(cXmlToSign)     //aquiiiiii GRABER RJ
				//cXmlToSign := EncodeUTF8(cXmlToSign)   //aquiiiiii GRABER RJ
				
			Else
			
				cXmlToSign:= ""	
							
			EndIf
			
		Else
		
			cXmlToSign := cXml
			ConOut(IIF(cThreadID=="1",'ThreadID='+AllTrim(Str(ThreadID(),15)),"")+" - Sign Error thread: "+cError+"/"+cWarning)
		EndIf
		
EndCase

Return(cXmlToSign)


// clone da funcao SPEDNFEID -- SPED_FW02.PRX (TSS)
Static Function HFIdSPED(cXML,cAttId)

Local nAt  := 0
Local cURI := ""
Local nSoma:= Len(cAttId)+2

nAt := At(cAttId+'=',cXml)
cURI:= SubStr(cXml,nAt+nSoma)
nAt := At('"',cURI)

If nAt == 0
	nAt := At("'",cURI)
EndIf

cURI:= SubStr(cURI,1,nAt-1)

Return(cUri)



Static Function NfeSignedInfo(cUri,cDigest)

Local cSignedInfo := ""

cSignedInfo += '<SignedInfo xmlns="http://www.w3.org/2000/09/xmldsig#">'
cSignedInfo += '<CanonicalizationMethod Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"></CanonicalizationMethod>'
cSignedInfo += '<SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1"></SignatureMethod>'
cSignedInfo += '<Reference URI="#'+ cUri +'">'
cSignedInfo += '<Transforms>'
cSignedInfo += '<Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"></Transform>'
cSignedInfo += '<Transform Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"></Transform>'
cSignedInfo += '</Transforms>'
cSignedInfo += '<DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1"></DigestMethod>'
cSignedInfo += '<DigestValue>' + cDigest + '</DigestValue></Reference></SignedInfo>' 

Return( cSignedInfo )


Static Function GetCertificate(cFile,lHSM,cIdEnt)

Local cCertificado := ""
Local nAT          := 0
Local nRAT         := 0
Local nHandle      := 0
Local nBuffer      := 0
Local cNewFunc     := ""
Local lExistCert   := .T.	 

If lHSM

	cNewFunc := "HSMGETCERTFILE"
	&cNewFunc.("slot_"+SuperGetMV("MV_HSMSLOT",.f.,cIdEnt)+"-label_"+SuperGetMV("MV_HSMLABE",.f.,cIdEnt),cFile)	

EndIf

nHandle      := FOpen( cFile, 0 )
nBuffer      := FSEEK(nHandle,0,FS_END)

FSeek( nHandle, 0 )

If nHandle > 0

	FRead( nHandle , cCertificado , nBuffer ) 
	FClose( nHandle )
	 
Else

	Conout("Certificado nao encontrado no diretorio Certs - Realizar a configuracao do certificado para entidade "+cIdEnt+" !")
	lExistCert := .F.
	
EndIf

If lExistCert

	nAt := AT("BEGIN CERTIFICATE", cCertificado)

	If (nAt > 0)
	
		nAt := nAt + 22
		cCertificado := substr(cCertificado, nAt)
		
	EndIf

	nRat := AT("END CERTIFICATE", cCertificado)

	If (nRAt > 0)
	
		nRat := nRat - 6
		cCertificado := substr(cCertificado, 1, nRat)
		
	EndIf

	cCertificado := StrTran(cCertificado, Chr(13),"")
	cCertificado := StrTran(cCertificado, Chr(10),"")
	cCertificado := StrTran(cCertificado, Chr(13)+Chr(10),"") 

EndIf	

Return(cCertificado)


User Function HFGRVZBE( aChv, cEveMn )

Local aArea   := GetArea()
Local aAreaZBZ:= (xZBZ)->(GetArea())
Local aAreaZBS:= (xZBS)->(GetArea())
Local aAreaZBE:= (xZBE)->(GetArea())
Local nI      := 0
Local cSeqEve := ""
Local cKey    := ""
Local aEvt    := {}
Local cGrv    := ""
Local cXml    := ""
Local cSitConf:= " "
Local cOri := ""

For nI := 1 To Len( aChv )

	//Alert( aChv[nI][1]+aChv[nI][2]+aChv[nI][3]+aChv[nI][4]  )

	if aChv[nI][3] $ "135"  //Manifestoire
	
		cXml    := aChv[nI][6]
		aEvt    := {}
        cSeqEve := aChv[nI][5]
		aEvt    := U_HF20ZBE( nI, cSeqEve, cXml )
		
		if aChv[nI][5] > "00"
		
			cSeqEve := aChv[nI][5]
			
		endif
		
		cGrv := U_HF2GrvEv( aChv[nI][1], aChv[nI][2], cSeqEve, aEvt, .T. )
		
		cSitConf:= iif(aChv[nI][2]=="210200","1",;
			  iif(aChv[nI][2]=="210210","4",;
			  iif(aChv[nI][2]=="210220","2",;
			  iif(aChv[nI][2]=="210240","3", "0" ))))

	    dbSelectArea( xZBS )
	    ( xZBS )->( DbSetOrder( 3 ) )
	    
		If ( xZBS )->(dbSeek( aChv[nI][1] ) )
		
			if ! Empty( ( xZBS )->(FieldGet(FieldPos(xZBS_+"CSITCO"))) )
			
				if cSitConf == "4" .And. ( xZBS )->(FieldGet(FieldPos(xZBS_+"CSITCO"))) $ "123" //.And. ( xZBS )->(FieldGet(FieldPos(xZBS_+"CSITCO"))) < "4"
					
					cSitConf := ( xZBS )->(FieldGet(FieldPos(xZBS_+"CSITCO")))
					
				Else
				
					if ( xZBS )->(FieldGet(FieldPos(xZBS_+"CSITCO"))) > cSitConf
					
						cSitConf := ( xZBS )->(FieldGet(FieldPos(xZBS_+"CSITCO")))
						
					endif
					
				Endif
				
			Endif
			
			if ( xZBS )->(FieldGet(FieldPos(xZBS_+"CSITCO"))) <> cSitConf
			
				RecLock(xZBS, .F. )
				( xZBS )->(FieldPut(FieldPos(xZBS_+"CSITCO"), cSitConf ))
				( xZBS )->( msunlock() )
				
			endif
			
		endif

	    dbSelectArea( xZBZ )
	    ( xZBZ )->( DbSetOrder( 3 ) )
	    
		If ( xZBZ )->(dbSeek( aChv[nI][1] ) )
		
			cOri := "1"
			
			if !Empty( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"IMPORT"))) )
				cOri := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"IMPORT")))
			Endif
			
			//cGrv := U_HFMANZBS( aChv[nI][1], (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MANIF"))), cOri )

			if (xZBZ)->(FieldPos(xZBZ_+"MANIF")) > 0   // .And. ! Empty(xManif) //GETESB2

				cRet := U_HFMANZBS( AllTrim( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))) ), "", cOri )

				if !Empty( cRet )

					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"MANIF"), cRet ))

				endif

			endif
			
			/*if (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MANIF"))) <> cGrv
			
				RecLock(xZBZ, .F. )
				( xZBZ )->( FieldPut( FieldPos(xZBZ_+"MANIF"), cGrv ))
				( xZBZ )->( msunlock() )
				
			endif*/
			
		endif
	else
		cXml    := aChv[nI][6]
		aEvt    := {}
        cSeqEve := aChv[nI][5]
		aEvt    := U_HF20ZBE( nI, cSeqEve, cXml )
		
		if aChv[nI][5] > "00"
		
			cSeqEve := aChv[nI][5]
			
		endif
		
		cGrv := U_HF2GrvEv( aChv[nI][1], aChv[nI][2], cSeqEve, aEvt, .T. )
		
	endif
	
Next  nI

RestArea( aAreaZBE )
RestArea( aAreaZBS )
RestArea( aAreaZBZ )
RestArea( aArea )

Return( NIL )
