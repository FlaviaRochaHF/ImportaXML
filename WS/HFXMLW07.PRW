#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://localhost:8081/HFXMLCTEDISTRIBUICAODFE.apw?WSDL
Gerado em        07/13/17 13:01:09
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _YSMEGVR ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSHFXMLCTEDISTRIBUICAODFE
------------------------------------------------------------------------------- */

WSCLIENT WSHFXMLCTEDISTRIBUICAODFE

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD HFCTEDISTRDFE
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
	WSDATA   cHFCTEDISTRDFERESULT      AS string
	WSDATA   cHFTSSVERSAORESULT        AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSHFXMLCTEDISTRIBUICAODFE
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20170322] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSHFXMLCTEDISTRIBUICAODFE
Return

WSMETHOD RESET WSCLIENT WSHFXMLCTEDISTRIBUICAODFE
	::cCCURL             := NIL 
	::cCIDENT            := NIL 
	::cCAMBIENTE         := NIL 
	::cCVERSAODADOS      := NIL 
	::cCCUF              := NIL 
	::cCCNPJ             := NIL 
	::cCCHSTR            := NIL 
	::cHFCTEDISTRDFERESULT := NIL 
	::cHFTSSVERSAORESULT := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSHFXMLCTEDISTRIBUICAODFE
Local oClone := WSHFXMLCTEDISTRIBUICAODFE():New()
	oClone:_URL          := ::_URL 
	oClone:cCCURL        := ::cCCURL
	oClone:cCIDENT       := ::cCIDENT
	oClone:cCAMBIENTE    := ::cCAMBIENTE
	oClone:cCVERSAODADOS := ::cCVERSAODADOS
	oClone:cCCUF         := ::cCCUF
	oClone:cCCNPJ        := ::cCCNPJ
	oClone:cCCHSTR       := ::cCCHSTR
	oClone:cHFCTEDISTRDFERESULT := ::cHFCTEDISTRDFERESULT
	oClone:cHFTSSVERSAORESULT := ::cHFTSSVERSAORESULT
Return oClone

// WSDL Method HFCTEDISTRDFE of Service WSHFXMLCTEDISTRIBUICAODFE

WSMETHOD HFCTEDISTRDFE WSSEND cCCURL,cCIDENT,cCAMBIENTE,cCVERSAODADOS,cCCUF,cCCNPJ,cCCHSTR WSRECEIVE cHFCTEDISTRDFERESULT WSCLIENT WSHFXMLCTEDISTRIBUICAODFE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<HFCTEDISTRDFE xmlns="'+::cCCURL+'">'
cSoap += WSSoapValue("CCURL", ::cCCURL, cCCURL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CIDENT", ::cCIDENT, cCIDENT , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CAMBIENTE", ::cCAMBIENTE, cCAMBIENTE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CVERSAODADOS", ::cCVERSAODADOS, cCVERSAODADOS , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CCUF", ::cCCUF, cCCUF , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CCNPJ", ::cCCNPJ, cCCNPJ , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CCHSTR", ::cCCHSTR, cCCHSTR , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</HFCTEDISTRDFE>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	::cCCURL+"HFCTEDISTRDFE",; 
	"DOCUMENT",::cCCURL,,"1.031217",; 
	::cCCURL+"HFXMLCTEDISTRIBUICAODFE.apw")

::Init()
::cHFCTEDISTRDFERESULT :=  WSAdvValue( oXmlRet,"_HFCTEDISTRDFERESPONSE:_HFCTEDISTRDFERESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method HFTSSVERSAO of Service WSHFXMLCTEDISTRIBUICAODFE

WSMETHOD HFTSSVERSAO WSSEND cCCURL WSRECEIVE cHFTSSVERSAORESULT WSCLIENT WSHFXMLCTEDISTRIBUICAODFE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<HFTSSVERSAO xmlns="'+::cCCURL+'/">'
cSoap += WSSoapValue("CCURL", ::cCCURL, cCCURL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</HFTSSVERSAO>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	::cCCURL+"HFTSSVERSAO",; 
	"DOCUMENT",::cCCURL,,"1.031217",; 
	::cCCURL+"HFXMLCTEDISTRIBUICAODFE.apw")

::Init()
::cHFTSSVERSAORESULT :=  WSAdvValue( oXmlRet,"_HFTSSVERSAORESPONSE:_HFTSSVERSAORESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.



