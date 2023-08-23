//http://localhost:8081/HFXMLMANIFESTO.apw?WSDL
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://localhost:8081/HFXMLMANIFESTO.apw?WSDL
Gerado em        01/26/18 11:05:22
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _TGTTAOF ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSHFXMLMANIFESTO
------------------------------------------------------------------------------- */

WSCLIENT WSHFXMLMANIFESTO

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD HFMANISFESTO
	WSMETHOD HFTSSVERSAO

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cCCURL                    AS string
	WSDATA   cCIDENT                   AS string
	WSDATA   cCLOTE                    AS string
	WSDATA   cCAMBIENTE                AS string
	WSDATA   cCVERSAODADOS             AS string
	WSDATA   cCCUF                     AS string
	WSDATA   cCHORAVERAO               AS string
	WSDATA   cCHORARIO                 AS string
	WSDATA   cCCNPJ                    AS string
	WSDATA   cCCHSTR                   AS string
	WSDATA   cCEVSTR                   AS string
	WSDATA   cCXJUST                   AS string
	WSDATA   cCDTHREVEN                AS string
	WSDATA   cHFMANISFESTORESULT       AS string
	WSDATA   cHFTSSVERSAORESULT        AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSHFXMLMANIFESTO
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20171123] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSHFXMLMANIFESTO
Return

WSMETHOD RESET WSCLIENT WSHFXMLMANIFESTO
	::cCCURL             := NIL 
	::cCIDENT            := NIL 
	::cCLOTE             := NIL 
	::cCAMBIENTE         := NIL 
	::cCVERSAODADOS      := NIL 
	::cCCUF              := NIL 
	::cCHORAVERAO        := NIL 
	::cCHORARIO          := NIL 
	::cCCNPJ             := NIL 
	::cCCHSTR            := NIL 
	::cCEVSTR            := NIL 
	::cCXJUST            := NIL 
	::cCDTHREVEN         := NIL 
	::cHFMANISFESTORESULT := NIL 
	::cHFTSSVERSAORESULT := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSHFXMLMANIFESTO
Local oClone := WSHFXMLMANIFESTO():New()
	oClone:_URL          := ::_URL 
	oClone:cCCURL        := ::cCCURL
	oClone:cCIDENT       := ::cCIDENT
	oClone:cCLOTE        := ::cCLOTE
	oClone:cCAMBIENTE    := ::cCAMBIENTE
	oClone:cCVERSAODADOS := ::cCVERSAODADOS
	oClone:cCCUF         := ::cCCUF
	oClone:cCHORAVERAO   := ::cCHORAVERAO
	oClone:cCHORARIO     := ::cCHORARIO
	oClone:cCCNPJ        := ::cCCNPJ
	oClone:cCCHSTR       := ::cCCHSTR
	oClone:cCEVSTR       := ::cCEVSTR
	oClone:cCXJUST       := ::cCXJUST
	oClone:cCDTHREVEN    := ::cCDTHREVEN
	oClone:cHFMANISFESTORESULT := ::cHFMANISFESTORESULT
	oClone:cHFTSSVERSAORESULT := ::cHFTSSVERSAORESULT
Return oClone

// WSDL Method HFMANISFESTO of Service WSHFXMLMANIFESTO

WSMETHOD HFMANISFESTO WSSEND cCCURL,cCIDENT,cCLOTE,cCAMBIENTE,cCVERSAODADOS,cCCUF,cCHORAVERAO,cCHORARIO,cCCNPJ,cCCHSTR,cCEVSTR,cCXJUST,cCDTHREVEN WSRECEIVE cHFMANISFESTORESULT WSCLIENT WSHFXMLMANIFESTO
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<HFMANISFESTO xmlns="'+::cCCURL+'">'
cSoap += WSSoapValue("CCURL", ::cCCURL, cCCURL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CIDENT", ::cCIDENT, cCIDENT , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CLOTE", ::cCLOTE, cCLOTE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CAMBIENTE", ::cCAMBIENTE, cCAMBIENTE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CVERSAODADOS", ::cCVERSAODADOS, cCVERSAODADOS , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CCUF", ::cCCUF, cCCUF , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CHORAVERAO", ::cCHORAVERAO, cCHORAVERAO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CHORARIO", ::cCHORARIO, cCHORARIO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CCNPJ", ::cCCNPJ, cCCNPJ , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CCHSTR", ::cCCHSTR, cCCHSTR , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CEVSTR", ::cCEVSTR, cCEVSTR , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CXJUST", ::cCXJUST, cCXJUST , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CDTHREVEN", ::cCDTHREVEN, cCDTHREVEN , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</HFMANISFESTO>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	::cCCURL+"HFMANISFESTO",; 
	"DOCUMENT",::cCCURL,,"1.031217",; 
	::cCCURL+"HFXMLMANIFESTO.apw")

::Init()
::cHFMANISFESTORESULT :=  WSAdvValue( oXmlRet,"_HFMANISFESTORESPONSE:_HFMANISFESTORESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method HFTSSVERSAO of Service WSHFXMLMANIFESTO

WSMETHOD HFTSSVERSAO WSSEND cCCURL WSRECEIVE cHFTSSVERSAORESULT WSCLIENT WSHFXMLMANIFESTO
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<HFTSSVERSAO xmlns="'+::cCCURL+'">'
cSoap += WSSoapValue("CCURL", ::cCCURL, cCCURL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</HFTSSVERSAO>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	::cCCURL+"HFTSSVERSAO",; 
	"DOCUMENT",::cCCURL,,"1.031217",; 
	::cCCURL+"HFXMLMANIFESTO.apw")

::Init()
::cHFTSSVERSAORESULT :=  WSAdvValue( oXmlRet,"_HFTSSVERSAORESPONSE:_HFTSSVERSAORESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.



