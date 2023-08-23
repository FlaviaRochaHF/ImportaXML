#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://localhost:8081/hfxmldowload.apw?WSDL
Gerado em        11/11/13 15:46:17
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _FRNTNXS ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSHFXMLDOWLOAD
------------------------------------------------------------------------------- */

WSCLIENT WSHFXMLDOWLOAD

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD HFBAIXAXML
	WSMETHOD HFTSSVERSAO

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cCCURL                    AS string
	WSDATA   cCIDENT                   AS string
	WSDATA   cCAMBIENTE                AS string
	WSDATA   cCVERSAODADOS             AS string
	WSDATA   cCCUF                     AS string
	WSDATA   cCCNPJ                    AS string
	WSDATA   cCCHSTR                   AS string
	WSDATA   cHFBAIXAXMLRESULT         AS string
	WSDATA   cHFTSSVERSAORESULT        AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSHFXMLDOWLOAD
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.121227P-20130604] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSHFXMLDOWLOAD
Return

WSMETHOD RESET WSCLIENT WSHFXMLDOWLOAD
	::cCCURL             := NIL 
	::cCIDENT            := NIL 
	::cCAMBIENTE         := NIL 
	::cCVERSAODADOS      := NIL 
	::cCCUF              := NIL 
	::cCCNPJ             := NIL 
	::cCCHSTR            := NIL 
	::cHFBAIXAXMLRESULT  := NIL 
	::cHFTSSVERSAORESULT := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSHFXMLDOWLOAD
Local oClone := WSHFXMLDOWLOAD():New()
	oClone:_URL          := ::_URL 
	oClone:cCCURL        := ::cCCURL
	oClone:cCIDENT       := ::cCIDENT
	oClone:cCAMBIENTE    := ::cCAMBIENTE
	oClone:cCVERSAODADOS := ::cCVERSAODADOS
	oClone:cCCUF         := ::cCCUF
	oClone:cCCNPJ        := ::cCCNPJ
	oClone:cCCHSTR       := ::cCCHSTR
	oClone:cHFBAIXAXMLRESULT := ::cHFBAIXAXMLRESULT
	oClone:cHFTSSVERSAORESULT := ::cHFTSSVERSAORESULT
Return oClone

// WSDL Method HFBAIXAXML of Service WSHFXMLDOWLOAD

WSMETHOD HFBAIXAXML WSSEND cCCURL,cCIDENT,cCAMBIENTE,cCVERSAODADOS,cCCUF,cCCNPJ,cCCHSTR WSRECEIVE cHFBAIXAXMLRESULT WSCLIENT WSHFXMLDOWLOAD
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<HFBAIXAXML xmlns="'+::cCCURL+'">'
cSoap += WSSoapValue("CCURL", ::cCCURL, cCCURL , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CIDENT", ::cCIDENT, cCIDENT , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CAMBIENTE", ::cCAMBIENTE, cCAMBIENTE , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CVERSAODADOS", ::cCVERSAODADOS, cCVERSAODADOS , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CCUF", ::cCCUF, cCCUF , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CCNPJ", ::cCCNPJ, cCCNPJ , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CCHSTR", ::cCCHSTR, cCCHSTR , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</HFBAIXAXML>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	::cCCURL+"HFBAIXAXML",; 
	"DOCUMENT",::cCCURL,,"1.031217",; 
	::cCCURL+"HFXMLDOWLOAD.apw")

::Init()
::cHFBAIXAXMLRESULT  :=  WSAdvValue( oXmlRet,"_HFBAIXAXMLRESPONSE:_HFBAIXAXMLRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method HFTSSVERSAO of Service WSHFXMLDOWLOAD

WSMETHOD HFTSSVERSAO WSSEND cCCURL WSRECEIVE cHFTSSVERSAORESULT WSCLIENT WSHFXMLDOWLOAD
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<HFTSSVERSAO xmlns="'+::cCCURL+'">'
cSoap += WSSoapValue("CCURL", ::cCCURL, cCCURL , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</HFTSSVERSAO>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	::cCCURL+"HFTSSVERSAO",; 
	"DOCUMENT",::cCCURL,,"1.031217",; 
	::cCCURL+"HFXMLDOWLOAD.apw")

::Init()
::cHFTSSVERSAORESULT :=  WSAdvValue( oXmlRet,"_HFTSSVERSAORESPONSE:_HFTSSVERSAORESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.


