#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://localhost:8081/HFXMLCFG.apw?WSDL
Gerado em        05/27/16 13:04:51
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _JKLQERG ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSHFXMLCFG
------------------------------------------------------------------------------- */

WSCLIENT WSHFXMLCFG

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD HFGETMDAMB
	WSMETHOD HFGETMDVER
	WSMETHOD HFGETNSU
	WSMETHOD HFSETMDAMB
	WSMETHOD HFSETMDVER
	WSMETHOD HFSETNSU
	WSMETHOD HFTSSVERSAO

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cCCURL                    AS string
	WSDATA   cCIDENT                   AS string
	WSDATA   cHFGETMDAMBRESULT         AS string
	WSDATA   cHFGETMDVERRESULT         AS string
	WSDATA   cHFGETNSURESULT           AS string
	WSDATA   cCMDAMB                   AS string
	WSDATA   cHFSETMDAMBRESULT         AS string
	WSDATA   cCMDVER                   AS string
	WSDATA   cHFSETMDVERRESULT         AS string
	WSDATA   cCNSU                     AS string
	WSDATA   cHFSETNSURESULT           AS string
	WSDATA   cHFTSSVERSAORESULT        AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSHFXMLCFG
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20141125] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSHFXMLCFG
Return

WSMETHOD RESET WSCLIENT WSHFXMLCFG
	::cCCURL             := NIL 
	::cCIDENT            := NIL 
	::cHFGETMDAMBRESULT  := NIL 
	::cHFGETMDVERRESULT  := NIL 
	::cHFGETNSURESULT    := NIL 
	::cCMDAMB            := NIL 
	::cHFSETMDAMBRESULT  := NIL 
	::cCMDVER            := NIL 
	::cHFSETMDVERRESULT  := NIL 
	::cCNSU              := NIL 
	::cHFSETNSURESULT    := NIL 
	::cHFTSSVERSAORESULT := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSHFXMLCFG
Local oClone := WSHFXMLCFG():New()
	oClone:_URL          := ::_URL 
	oClone:cCCURL        := ::cCCURL
	oClone:cCIDENT       := ::cCIDENT
	oClone:cHFGETMDAMBRESULT := ::cHFGETMDAMBRESULT
	oClone:cHFGETMDVERRESULT := ::cHFGETMDVERRESULT
	oClone:cHFGETNSURESULT := ::cHFGETNSURESULT
	oClone:cCMDAMB       := ::cCMDAMB
	oClone:cHFSETMDAMBRESULT := ::cHFSETMDAMBRESULT
	oClone:cCMDVER       := ::cCMDVER
	oClone:cHFSETMDVERRESULT := ::cHFSETMDVERRESULT
	oClone:cCNSU         := ::cCNSU
	oClone:cHFSETNSURESULT := ::cHFSETNSURESULT
	oClone:cHFTSSVERSAORESULT := ::cHFTSSVERSAORESULT
Return oClone

// WSDL Method HFGETMDAMB of Service WSHFXMLCFG

WSMETHOD HFGETMDAMB WSSEND cCCURL,cCIDENT WSRECEIVE cHFGETMDAMBRESULT WSCLIENT WSHFXMLCFG
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<HFGETMDAMB xmlns="'+::cCCURL+'">'
cSoap += WSSoapValue("CCURL", ::cCCURL, cCCURL , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CIDENT", ::cCIDENT, cCIDENT , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</HFGETMDAMB>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	::cCCURL+"HFGETMDAMB",; 
	"DOCUMENT",::cCCURL,,"1.031217",; 
	::cCCURL+"HFXMLCFG.apw")

::Init()
::cHFGETMDAMBRESULT  :=  WSAdvValue( oXmlRet,"_HFGETMDAMBRESPONSE:_HFGETMDAMBRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method HFGETMDVER of Service WSHFXMLCFG

WSMETHOD HFGETMDVER WSSEND cCCURL,cCIDENT WSRECEIVE cHFGETMDVERRESULT WSCLIENT WSHFXMLCFG
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<HFGETMDVER xmlns="'+::cCCURL+'">'
cSoap += WSSoapValue("CCURL", ::cCCURL, cCCURL , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CIDENT", ::cCIDENT, cCIDENT , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</HFGETMDVER>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	::cCCURL+"HFGETMDVER",; 
	"DOCUMENT",::cCCURL,,"1.031217",; 
	::cCCURL+"HFXMLCFG.apw")

::Init()
::cHFGETMDVERRESULT  :=  WSAdvValue( oXmlRet,"_HFGETMDVERRESPONSE:_HFGETMDVERRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method HFGETNSU of Service WSHFXMLCFG

WSMETHOD HFGETNSU WSSEND cCCURL,cCIDENT WSRECEIVE cHFGETNSURESULT WSCLIENT WSHFXMLCFG
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<HFGETNSU xmlns="'+::cCCURL+'">'
cSoap += WSSoapValue("CCURL", ::cCCURL, cCCURL , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CIDENT", ::cCIDENT, cCIDENT , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</HFGETNSU>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	::cCCURL+"HFGETNSU",; 
	"DOCUMENT",::cCCURL,,"1.031217",; 
	::cCCURL+"HFXMLCFG.apw")

::Init()
::cHFGETNSURESULT    :=  WSAdvValue( oXmlRet,"_HFGETNSURESPONSE:_HFGETNSURESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method HFSETMDAMB of Service WSHFXMLCFG

WSMETHOD HFSETMDAMB WSSEND cCCURL,cCIDENT,cCMDAMB WSRECEIVE cHFSETMDAMBRESULT WSCLIENT WSHFXMLCFG
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<HFSETMDAMB xmlns="'+::cCCURL+'">'
cSoap += WSSoapValue("CCURL", ::cCCURL, cCCURL , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CIDENT", ::cCIDENT, cCIDENT , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CMDAMB", ::cCMDAMB, cCMDAMB , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</HFSETMDAMB>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	::cCCURL+"HFSETMDAMB",; 
	"DOCUMENT",::cCCURL,,"1.031217",; 
	::cCCURL+"HFXMLCFG.apw")

::Init()
::cHFSETMDAMBRESULT  :=  WSAdvValue( oXmlRet,"_HFSETMDAMBRESPONSE:_HFSETMDAMBRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method HFSETMDVER of Service WSHFXMLCFG

WSMETHOD HFSETMDVER WSSEND cCCURL,cCIDENT,cCMDVER WSRECEIVE cHFSETMDVERRESULT WSCLIENT WSHFXMLCFG
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<HFSETMDVER xmlns="'+::cCCURL+'">'
cSoap += WSSoapValue("CCURL", ::cCCURL, cCCURL , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CIDENT", ::cCIDENT, cCIDENT , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CMDVER", ::cCMDVER, cCMDVER , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</HFSETMDVER>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	::cCCURL+"HFSETMDVER",; 
	"DOCUMENT",::cCCURL,,"1.031217",; 
	::cCCURL+"HFXMLCFG.apw")

::Init()
::cHFSETMDVERRESULT  :=  WSAdvValue( oXmlRet,"_HFSETMDVERRESPONSE:_HFSETMDVERRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method HFSETNSU of Service WSHFXMLCFG

WSMETHOD HFSETNSU WSSEND cCCURL,cCIDENT,cCNSU WSRECEIVE cHFSETNSURESULT WSCLIENT WSHFXMLCFG
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<HFSETNSU xmlns="'+::cCCURL+'">'
cSoap += WSSoapValue("CCURL", ::cCCURL, cCCURL , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CIDENT", ::cCIDENT, cCIDENT , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CNSU", ::cCNSU, cCNSU , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</HFSETNSU>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	::cCCURL+"HFSETNSU",; 
	"DOCUMENT",::cCCURL,,"1.031217",; 
	::cCCURL+"HFXMLCFG.apw")

::Init()
::cHFSETNSURESULT    :=  WSAdvValue( oXmlRet,"_HFSETNSURESPONSE:_HFSETNSURESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method HFTSSVERSAO of Service WSHFXMLCFG

WSMETHOD HFTSSVERSAO WSSEND cCCURL WSRECEIVE cHFTSSVERSAORESULT WSCLIENT WSHFXMLCFG
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<HFTSSVERSAO xmlns="'+::cCCURL+'">'
cSoap += WSSoapValue("CCURL", ::cCCURL, cCCURL , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</HFTSSVERSAO>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	::cCCURL+"HFTSSVERSAO",; 
	"DOCUMENT",::cCCURL,,"1.031217",; 
	::cCCURL+"HFXMLCFG.apw")

::Init()
::cHFTSSVERSAORESULT :=  WSAdvValue( oXmlRet,"_HFTSSVERSAORESPONSE:_HFTSSVERSAORESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.



