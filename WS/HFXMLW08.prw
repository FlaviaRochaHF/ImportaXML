#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    https://www.nfe.fazenda.gov.br/NFeRecepcaoEvento4/NFeRecepcaoEvento4.asmx?WSDL
Gerado em        07/23/20 16:24:17
Observa��es      C�digo-Fonte gerado por ADVPL WSDL Client 1.120703
                 Altera��es neste arquivo podem causar funcionamento incorreto
                 e ser�o perdidas caso o c�digo-fonte seja gerado novamente.
=============================================================================== */

User Function _MQSMKKB ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSNFeRecepcaoEvento4
------------------------------------------------------------------------------- */

WSCLIENT WSNFeRecepcaoEvento4

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD nfeRecepcaoEventoNF

	WSDATA   _URL                      AS String
	WSDATA   _CERT                     AS String
	WSDATA   _PRIVKEY                  AS String
	WSDATA   _PASSPHRASE               AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   oWS                       AS SCHEMA

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSNFeRecepcaoEvento4

::Init()

If !FindFunction("XMLCHILDEX")
	UserException("O C�digo-Fonte Client atual requer os execut�veis do Protheus Build [7.00.170117A-20200331] ou superior. Atualize o Protheus ou gere o C�digo-Fonte novamente utilizando o Build atual.")
EndIf

Return Self

WSMETHOD INIT WSCLIENT WSNFeRecepcaoEvento4
	::oWS                := NIL 
Return

WSMETHOD RESET WSCLIENT WSNFeRecepcaoEvento4
	::oWS                := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSNFeRecepcaoEvento4

Local oClone := WSNFeRecepcaoEvento4():New()

	oClone:_URL          := ::_URL 
	oClone:_CERT         := ::_CERT 
	oClone:_PRIVKEY      := ::_PRIVKEY 
	oClone:_PASSPHRASE   := ::_PASSPHRASE 

Return oClone

// WSDL Method nfeRecepcaoEventoNF of Service WSNFeRecepcaoEvento4

WSMETHOD nfeRecepcaoEventoNF WSSEND BYREF oWS WSRECEIVE NULLPARAM WSCLIENT WSNFeRecepcaoEvento4

Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<nfeDadosMsg xmlns="http://www.portalfiscal.inf.br/nfe/wsdl/NFeRecepcaoEvento4">'
cSoap += WSSoapValue("", ::oWS, oWS , "SCHEMA", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</nfeDadosMsg>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://www.portalfiscal.inf.br/nfe/wsdl/NFeRecepcaoEvento4/nfeRecepcaoEventoNF",; 
	"DOCUMENT","http://www.portalfiscal.inf.br/nfe/wsdl/NFeRecepcaoEvento4",,,; 
	"https://www.nfe.fazenda.gov.br/NFeRecepcaoEvento4/NFeRecepcaoEvento4.asmx")

::Init()
::oWS                :=  WSAdvValue( oXmlRet,"_NFERECEPCAOEVENTONFRESULT","SCHEMA",NIL,NIL,NIL,"O",@oWS,NIL) 

END WSMETHOD

oXmlRet := NIL

Return .T.



