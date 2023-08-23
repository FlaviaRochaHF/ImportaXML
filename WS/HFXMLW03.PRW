//http://localhost:8081/HFXMLCONSULTADEST.apw?WSDL
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://localhost:8081/HFXMLCONSULTADEST.apw?WSDL
Gerado em        05/21/14 11:28:47
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _REYFZKO ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSHFXMLCONSULTADEST
------------------------------------------------------------------------------- */

WSCLIENT WSHFXMLCONSULTADEST

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD HFCONSULTADEST
	WSMETHOD HFTSSVERSAO

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cCCURL                    AS string
	WSDATA   cCIDENT                   AS string
	WSDATA   cCAMBIENTE                AS string
	WSDATA   cCVERSAODADOS             AS string
	WSDATA   cCCUF                     AS string
	WSDATA   cCSERVICO                 AS string
	WSDATA   cCCNPJ                    AS string
	WSDATA   cCINDNFE                  AS string
	WSDATA   cCINDEMISSOR              AS string
	WSDATA   cCULTNSU                  AS string
	WSDATA   cHFCONSULTADESTRESULT     AS string
	WSDATA   cHFTSSVERSAORESULT        AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSHFXMLCONSULTADEST
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.121227P-20131106] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSHFXMLCONSULTADEST
Return

WSMETHOD RESET WSCLIENT WSHFXMLCONSULTADEST
	::cCCURL             := NIL 
	::cCIDENT            := NIL 
	::cCAMBIENTE         := NIL 
	::cCVERSAODADOS      := NIL 
	::cCCUF              := NIL 
	::cCSERVICO          := NIL 
	::cCCNPJ             := NIL 
	::cCINDNFE           := NIL 
	::cCINDEMISSOR       := NIL 
	::cCULTNSU           := NIL 
	::cHFCONSULTADESTRESULT := NIL 
	::cHFTSSVERSAORESULT := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSHFXMLCONSULTADEST
Local oClone := WSHFXMLCONSULTADEST():New()
	oClone:_URL          := ::_URL 
	oClone:cCCURL        := ::cCCURL
	oClone:cCIDENT       := ::cCIDENT
	oClone:cCAMBIENTE    := ::cCAMBIENTE
	oClone:cCVERSAODADOS := ::cCVERSAODADOS
	oClone:cCCUF         := ::cCCUF
	oClone:cCSERVICO     := ::cCSERVICO
	oClone:cCCNPJ        := ::cCCNPJ
	oClone:cCINDNFE      := ::cCINDNFE
	oClone:cCINDEMISSOR  := ::cCINDEMISSOR
	oClone:cCULTNSU      := ::cCULTNSU
	oClone:cHFCONSULTADESTRESULT := ::cHFCONSULTADESTRESULT
	oClone:cHFTSSVERSAORESULT := ::cHFTSSVERSAORESULT
Return oClone

// WSDL Method HFCONSULTADEST of Service WSHFXMLCONSULTADEST

WSMETHOD HFCONSULTADEST WSSEND cCCURL,cCIDENT,cCAMBIENTE,cCVERSAODADOS,cCCUF,cCSERVICO,cCCNPJ,cCINDNFE,cCINDEMISSOR,cCULTNSU WSRECEIVE cHFCONSULTADESTRESULT WSCLIENT WSHFXMLCONSULTADEST
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<HFCONSULTADEST xmlns="'+::cCCURL+'">'
cSoap += WSSoapValue("CCURL", ::cCCURL, cCCURL , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CIDENT", ::cCIDENT, cCIDENT , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CAMBIENTE", ::cCAMBIENTE, cCAMBIENTE , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CVERSAODADOS", ::cCVERSAODADOS, cCVERSAODADOS , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CCUF", ::cCCUF, cCCUF , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CSERVICO", ::cCSERVICO, cCSERVICO , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CCNPJ", ::cCCNPJ, cCCNPJ , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CINDNFE", ::cCINDNFE, cCINDNFE , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CINDEMISSOR", ::cCINDEMISSOR, cCINDEMISSOR , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CULTNSU", ::cCULTNSU, cCULTNSU , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</HFCONSULTADEST>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	::cCCURL+"HFCONSULTADEST",; 
	"DOCUMENT",::cCCURL,,"1.031217",; 
	::cCCURL+"HFXMLCONSULTADEST.apw")

::Init()
::cHFCONSULTADESTRESULT :=  WSAdvValue( oXmlRet,"_HFCONSULTADESTRESPONSE:_HFCONSULTADESTRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method HFTSSVERSAO of Service WSHFXMLCONSULTADEST

WSMETHOD HFTSSVERSAO WSSEND cCCURL WSRECEIVE cHFTSSVERSAORESULT WSCLIENT WSHFXMLCONSULTADEST
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<HFTSSVERSAO xmlns="'+::cCCURL+'">'
cSoap += WSSoapValue("CCURL", ::cCCURL, cCCURL , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</HFTSSVERSAO>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	::cCCURL+"HFTSSVERSAO",; 
	"DOCUMENT",::cCCURL,,"1.031217",; 
	::cCCURL+"HFXMLCONSULTADEST.apw")

::Init()
::cHFTSSVERSAORESULT :=  WSAdvValue( oXmlRet,"_HFTSSVERSAORESPONSE:_HFTSSVERSAORESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.




