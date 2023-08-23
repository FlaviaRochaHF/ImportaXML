//http://localhost:8081/HFXMLCONSULTACHV.apw?WSDL
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://localhost:8081/HFXMLCONSULTACHV.apw?WSDL
Gerado em        12/22/14 15:27:00
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _LOKWKKV ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSHFXMLCONSULTACHV
------------------------------------------------------------------------------- */

WSCLIENT WSHFXMLCONSULTACHV

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD HFCONSCHVMODAL
	WSMETHOD HFCONSULTACHV
	WSMETHOD HFTSSVERSAO

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cCCURL                    AS string
	WSDATA   cCIDENT                   AS string
	WSDATA   cCCHAVE                   AS string
	WSDATA   cCMODELO                  AS string
	WSDATA   nNMODALIDADE              AS integer
	WSDATA   cHFCONSCHVMODALRESULT     AS string
	WSDATA   nNAMBIENTE                AS integer
	WSDATA   oWSHFCONSULTACHVRESULT    AS HFXMLCONSULTACHV_RETORNO_XML_CONSULTA
	WSDATA   cHFTSSVERSAORESULT        AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSHFXMLCONSULTACHV
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.121227P-20131106] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSHFXMLCONSULTACHV
	::oWSHFCONSULTACHVRESULT := HFXMLCONSULTACHV_RETORNO_XML_CONSULTA():New()
Return

WSMETHOD RESET WSCLIENT WSHFXMLCONSULTACHV
	::cCCURL             := NIL 
	::cCIDENT            := NIL 
	::cCCHAVE            := NIL 
	::cCMODELO           := NIL 
	::nNMODALIDADE       := NIL 
	::cHFCONSCHVMODALRESULT := NIL 
	::nNAMBIENTE         := NIL 
	::oWSHFCONSULTACHVRESULT := NIL 
	::cHFTSSVERSAORESULT := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSHFXMLCONSULTACHV
Local oClone := WSHFXMLCONSULTACHV():New()
	oClone:_URL          := ::_URL 
	oClone:cCCURL        := ::cCCURL
	oClone:cCIDENT       := ::cCIDENT
	oClone:cCCHAVE       := ::cCCHAVE
	oClone:cCMODELO      := ::cCMODELO
	oClone:nNMODALIDADE  := ::nNMODALIDADE
	oClone:cHFCONSCHVMODALRESULT := ::cHFCONSCHVMODALRESULT
	oClone:nNAMBIENTE    := ::nNAMBIENTE
	oClone:oWSHFCONSULTACHVRESULT :=  IIF(::oWSHFCONSULTACHVRESULT = NIL , NIL ,::oWSHFCONSULTACHVRESULT:Clone() )
	oClone:cHFTSSVERSAORESULT := ::cHFTSSVERSAORESULT
Return oClone

// WSDL Method HFCONSCHVMODAL of Service WSHFXMLCONSULTACHV

WSMETHOD HFCONSCHVMODAL WSSEND cCCURL,cCIDENT,cCCHAVE,cCMODELO,nNMODALIDADE WSRECEIVE cHFCONSCHVMODALRESULT WSCLIENT WSHFXMLCONSULTACHV
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<HFCONSCHVMODAL xmlns="'+::cCCURL+'">'
cSoap += WSSoapValue("CCURL", ::cCCURL, cCCURL , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CIDENT", ::cCIDENT, cCIDENT , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CCHAVE", ::cCCHAVE, cCCHAVE , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CMODELO", ::cCMODELO, cCMODELO , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("NMODALIDADE", ::nNMODALIDADE, nNMODALIDADE , "integer", .T. , .F., 0 , NIL, .F.) 
cSoap += "</HFCONSCHVMODAL>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	::cCCURL+"HFCONSCHVMODAL",; 
	"DOCUMENT",::cCCURL,,"1.031217",; 
	::cCCURL+"HFXMLCONSULTACHV.apw")

::Init()
::cHFCONSCHVMODALRESULT :=  WSAdvValue( oXmlRet,"_HFCONSCHVMODALRESPONSE:_HFCONSCHVMODALRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method HFCONSULTACHV of Service WSHFXMLCONSULTACHV

WSMETHOD HFCONSULTACHV WSSEND cCCURL,cCIDENT,cCCHAVE,nNAMBIENTE,nNMODALIDADE WSRECEIVE oWSHFCONSULTACHVRESULT WSCLIENT WSHFXMLCONSULTACHV
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<HFCONSULTACHV xmlns="'+::cCCURL+'">'
cSoap += WSSoapValue("CCURL", ::cCCURL, cCCURL , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CIDENT", ::cCIDENT, cCIDENT , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CCHAVE", ::cCCHAVE, cCCHAVE , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("NAMBIENTE", ::nNAMBIENTE, nNAMBIENTE , "integer", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("NMODALIDADE", ::nNMODALIDADE, nNMODALIDADE , "integer", .T. , .F., 0 , NIL, .F.) 
cSoap += "</HFCONSULTACHV>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	::cCCURL+"HFCONSULTACHV",; 
	"DOCUMENT",::cCCURL,,"1.031217",; 
	::cCCURL+"HFXMLCONSULTACHV.apw")

::Init()
::oWSHFCONSULTACHVRESULT:SoapRecv( WSAdvValue( oXmlRet,"_HFCONSULTACHVRESPONSE:_HFCONSULTACHVRESULT","RETORNO_XML_CONSULTA",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method HFTSSVERSAO of Service WSHFXMLCONSULTACHV

WSMETHOD HFTSSVERSAO WSSEND cCCURL WSRECEIVE cHFTSSVERSAORESULT WSCLIENT WSHFXMLCONSULTACHV
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<HFTSSVERSAO xmlns="'+::cCCURL+'">'
cSoap += WSSoapValue("CCURL", ::cCCURL, cCCURL , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</HFTSSVERSAO>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	::cCCURL+"HFTSSVERSAO",; 
	"DOCUMENT",::cCCURL,,"1.031217",; 
	::cCCURL+"HFXMLCONSULTACHV.apw")

::Init()
::cHFTSSVERSAORESULT :=  WSAdvValue( oXmlRet,"_HFTSSVERSAORESPONSE:_HFTSSVERSAORESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure RETORNO_XML_CONSULTA

WSSTRUCT HFXMLCONSULTACHV_RETORNO_XML_CONSULTA
	WSDATA   cCAMBIENTE                AS string
	WSDATA   cCCODSTA                  AS string
	WSDATA   cCMODELO                  AS string
	WSDATA   cCMSGSTA                  AS string
	WSDATA   cCPROTOCOLO               AS string
	WSDATA   cCRETXML                  AS string
	WSDATA   cCUF                      AS string
	WSDATA   cCVERSAO                  AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT HFXMLCONSULTACHV_RETORNO_XML_CONSULTA
	::Init()
Return Self

WSMETHOD INIT WSCLIENT HFXMLCONSULTACHV_RETORNO_XML_CONSULTA
Return

WSMETHOD CLONE WSCLIENT HFXMLCONSULTACHV_RETORNO_XML_CONSULTA
	Local oClone := HFXMLCONSULTACHV_RETORNO_XML_CONSULTA():NEW()
	oClone:cCAMBIENTE           := ::cCAMBIENTE
	oClone:cCCODSTA             := ::cCCODSTA
	oClone:cCMODELO             := ::cCMODELO
	oClone:cCMSGSTA             := ::cCMSGSTA
	oClone:cCPROTOCOLO          := ::cCPROTOCOLO
	oClone:cCRETXML             := ::cCRETXML
	oClone:cCUF                 := ::cCUF
	oClone:cCVERSAO             := ::cCVERSAO
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT HFXMLCONSULTACHV_RETORNO_XML_CONSULTA
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCAMBIENTE         :=  WSAdvValue( oResponse,"_CAMBIENTE","string",NIL,"Property cCAMBIENTE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCCODSTA           :=  WSAdvValue( oResponse,"_CCODSTA","string",NIL,"Property cCCODSTA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCMODELO           :=  WSAdvValue( oResponse,"_CMODELO","string",NIL,"Property cCMODELO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCMSGSTA           :=  WSAdvValue( oResponse,"_CMSGSTA","string",NIL,"Property cCMSGSTA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCPROTOCOLO        :=  WSAdvValue( oResponse,"_CPROTOCOLO","string",NIL,"Property cCPROTOCOLO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCRETXML           :=  WSAdvValue( oResponse,"_CRETXML","string",NIL,"Property cCRETXML as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCUF               :=  WSAdvValue( oResponse,"_CUF","string",NIL,"Property cCUF as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCVERSAO           :=  WSAdvValue( oResponse,"_CVERSAO","string",NIL,"Property cCVERSAO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return


