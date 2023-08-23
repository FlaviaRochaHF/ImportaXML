#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://localhost:8081/HFXMLNFEDISTRIBUICAODFE.apw?WSDL
Gerado em        09/02/17 21:02:47
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _OROQVPY ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSHFXMLNFEDISTRIBUICAODFE
------------------------------------------------------------------------------- */

WSCLIENT WSHFXMLNFEDISTRIBUICAODFE

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD HFNFEDISTRDFE
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
	WSDATA   cCNSU                     AS string
	WSDATA   cHFNFEDISTRDFERESULT      AS string
	WSDATA   cHFTSSVERSAORESULT        AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSHFXMLNFEDISTRIBUICAODFE
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20170322] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSHFXMLNFEDISTRIBUICAODFE
Return

WSMETHOD RESET WSCLIENT WSHFXMLNFEDISTRIBUICAODFE
	::cCCURL             := NIL 
	::cCIDENT            := NIL 
	::cCAMBIENTE         := NIL 
	::cCVERSAODADOS      := NIL 
	::cCCUF              := NIL 
	::cCCNPJ             := NIL 
	::cCCHSTR            := NIL 
	::cCNSU              := NIL 
	::cHFNFEDISTRDFERESULT := NIL 
	::cHFTSSVERSAORESULT := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSHFXMLNFEDISTRIBUICAODFE
Local oClone := WSHFXMLNFEDISTRIBUICAODFE():New()
	oClone:_URL          := ::_URL 
	oClone:cCCURL        := ::cCCURL
	oClone:cCIDENT       := ::cCIDENT
	oClone:cCAMBIENTE    := ::cCAMBIENTE
	oClone:cCVERSAODADOS := ::cCVERSAODADOS
	oClone:cCCUF         := ::cCCUF
	oClone:cCCNPJ        := ::cCCNPJ
	oClone:cCCHSTR       := ::cCCHSTR
	oClone:cCNSU         := ::cCNSU
	oClone:cHFNFEDISTRDFERESULT := ::cHFNFEDISTRDFERESULT
	oClone:cHFTSSVERSAORESULT := ::cHFTSSVERSAORESULT
Return oClone

// WSDL Method HFNFEDISTRDFE of Service WSHFXMLNFEDISTRIBUICAODFE

WSMETHOD HFNFEDISTRDFE WSSEND cCCURL,cCIDENT,cCAMBIENTE,cCVERSAODADOS,cCCUF,cCCNPJ,cCCHSTR,cCNSU WSRECEIVE cHFNFEDISTRDFERESULT WSCLIENT WSHFXMLNFEDISTRIBUICAODFE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<HFNFEDISTRDFE xmlns="'+::cCCURL+'">'
cSoap += WSSoapValue("CCURL", ::cCCURL, cCCURL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CIDENT", ::cCIDENT, cCIDENT , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CAMBIENTE", ::cCAMBIENTE, cCAMBIENTE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CVERSAODADOS", ::cCVERSAODADOS, cCVERSAODADOS , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CCUF", ::cCCUF, cCCUF , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CCNPJ", ::cCCNPJ, cCCNPJ , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CCHSTR", ::cCCHSTR, cCCHSTR , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CNSU", ::cCNSU, cCNSU , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</HFNFEDISTRDFE>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	::cCCURL+"HFNFEDISTRDFE",; 
	"DOCUMENT",::cCCURL,,"1.031217",; 
	::cCCURL+"HFXMLNFEDISTRIBUICAODFE.apw")

::Init()
::cHFNFEDISTRDFERESULT :=  WSAdvValue( oXmlRet,"_HFNFEDISTRDFERESPONSE:_HFNFEDISTRDFERESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method HFTSSVERSAO of Service WSHFXMLNFEDISTRIBUICAODFE

WSMETHOD HFTSSVERSAO WSSEND cCCURL WSRECEIVE cHFTSSVERSAORESULT WSCLIENT WSHFXMLNFEDISTRIBUICAODFE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<HFTSSVERSAO xmlns="'+::cCCURL+'">'
cSoap += WSSoapValue("CCURL", ::cCCURL, cCCURL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</HFTSSVERSAO>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	::cCCURL+"HFTSSVERSAO",; 
	"DOCUMENT",::cCCURL,,"1.031217",; 
	::cCCURL+"HFXMLNFEDISTRIBUICAODFE.apw")

::Init()
::cHFTSSVERSAORESULT :=  WSAdvValue( oXmlRet,"_HFTSSVERSAORESPONSE:_HFTSSVERSAORESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.



