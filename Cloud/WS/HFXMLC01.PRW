#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    https://cloud.importaxml.com.br/WS/ERP.asmx?wsdl
Gerado em        05/17/18 15:06:39
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _NPRCKJR ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSERP
------------------------------------------------------------------------------- */

WSCLIENT WSERP

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD DadosDaConta
	WSMETHOD NfArray
	WSMETHOD CartaCorrecaoArray
	WSMETHOD EventosArray
	WSMETHOD ZBZ990Adciona
	WSMETHOD ZBE990Adciona

	WSDATA   _URL                      AS String
	WSDATA   _CERT                     AS String
	WSDATA   _PRIVKEY                  AS String
	WSDATA   _PASSPHRASE               AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   ctoken                    AS string
	WSDATA   oWSDadosDaContaResult     AS ERP_Conta
	WSDATA   ncontaID                  AS int
	WSDATA   ccnpf                     AS string
	WSDATA   cmodelo                   AS string
	WSDATA   oWSNfArrayResult          AS ERP_ArrayOfZBZ990
	WSDATA   oWSCartaCorrecaoArrayResult AS ERP_ArrayOfZBE990
	WSDATA   cchave                    AS string
	WSDATA   oWSEventosArrayResult     AS ERP_ArrayOfZBE990
	WSDATA   oWSzbz                    AS ERP_ZBZ990
	WSDATA   cZBZ990AdcionaResult      AS string
	WSDATA   oWSzbe                    AS ERP_ZBE990
	WSDATA   cZBE990AdcionaResult      AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSERP
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20180425 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSERP
	::oWSDadosDaContaResult := ERP_CONTA():New()
	::oWSNfArrayResult   := ERP_ARRAYOFZBZ990():New()
	::oWSCartaCorrecaoArrayResult := ERP_ARRAYOFZBE990():New()
	::oWSEventosArrayResult := ERP_ARRAYOFZBE990():New()
	::oWSzbz             := ERP_ZBZ990():New()
	::oWSzbe             := ERP_ZBE990():New()
Return

WSMETHOD RESET WSCLIENT WSERP
	::ctoken             := NIL 
	::oWSDadosDaContaResult := NIL 
	::ncontaID           := NIL 
	::ccnpf              := NIL 
	::cmodelo            := NIL 
	::oWSNfArrayResult   := NIL 
	::oWSCartaCorrecaoArrayResult := NIL 
	::cchave             := NIL 
	::oWSEventosArrayResult := NIL 
	::oWSzbz             := NIL 
	::cZBZ990AdcionaResult := NIL 
	::oWSzbe             := NIL 
	::cZBE990AdcionaResult := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSERP
Local oClone := WSERP():New()
	oClone:_URL          := ::_URL 
	oClone:_CERT         := ::_CERT 
	oClone:_PRIVKEY      := ::_PRIVKEY 
	oClone:_PASSPHRASE   := ::_PASSPHRASE 
	oClone:ctoken        := ::ctoken
	oClone:oWSDadosDaContaResult :=  IIF(::oWSDadosDaContaResult = NIL , NIL ,::oWSDadosDaContaResult:Clone() )
	oClone:ncontaID      := ::ncontaID
	oClone:ccnpf         := ::ccnpf
	oClone:cmodelo       := ::cmodelo
	oClone:oWSNfArrayResult :=  IIF(::oWSNfArrayResult = NIL , NIL ,::oWSNfArrayResult:Clone() )
	oClone:oWSCartaCorrecaoArrayResult :=  IIF(::oWSCartaCorrecaoArrayResult = NIL , NIL ,::oWSCartaCorrecaoArrayResult:Clone() )
	oClone:cchave        := ::cchave
	oClone:oWSEventosArrayResult :=  IIF(::oWSEventosArrayResult = NIL , NIL ,::oWSEventosArrayResult:Clone() )
	oClone:oWSzbz        :=  IIF(::oWSzbz = NIL , NIL ,::oWSzbz:Clone() )
	oClone:cZBZ990AdcionaResult := ::cZBZ990AdcionaResult
	oClone:oWSzbe        :=  IIF(::oWSzbe = NIL , NIL ,::oWSzbe:Clone() )
	oClone:cZBE990AdcionaResult := ::cZBE990AdcionaResult
Return oClone

// WSDL Method DadosDaConta of Service WSERP

WSMETHOD DadosDaConta WSSEND ctoken WSRECEIVE oWSDadosDaContaResult WSCLIENT WSERP
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<DadosDaConta xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("token", ::ctoken, ctoken , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</DadosDaConta>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://tempuri.org/DadosDaConta",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"https://cloud.importaxml.com.br/WS/ERP.asmx")

::Init()
::oWSDadosDaContaResult:SoapRecv( WSAdvValue( oXmlRet,"_DADOSDACONTARESPONSE:_DADOSDACONTARESULT","Conta",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method NfArray of Service WSERP

WSMETHOD NfArray WSSEND ncontaID,ccnpf,cmodelo WSRECEIVE oWSNfArrayResult WSCLIENT WSERP
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<NfArray xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("contaID", ::ncontaID, ncontaID , "int", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("cnpf", ::ccnpf, ccnpf , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("modelo", ::cmodelo, cmodelo , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</NfArray>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://tempuri.org/NfArray",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"https://cloud.importaxml.com.br/WS/ERP.asmx")

::Init()
::oWSNfArrayResult:SoapRecv( WSAdvValue( oXmlRet,"_NFARRAYRESPONSE:_NFARRAYRESULT","ArrayOfZBZ990",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method CartaCorrecaoArray of Service WSERP

WSMETHOD CartaCorrecaoArray WSSEND ncontaID,ccnpf WSRECEIVE oWSCartaCorrecaoArrayResult WSCLIENT WSERP
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CartaCorrecaoArray xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("contaID", ::ncontaID, ncontaID , "int", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("cnpf", ::ccnpf, ccnpf , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</CartaCorrecaoArray>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://tempuri.org/CartaCorrecaoArray",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"https://cloud.importaxml.com.br/WS/ERP.asmx")

::Init()
::oWSCartaCorrecaoArrayResult:SoapRecv( WSAdvValue( oXmlRet,"_CARTACORRECAOARRAYRESPONSE:_CARTACORRECAOARRAYRESULT","ArrayOfZBE990",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method EventosArray of Service WSERP

WSMETHOD EventosArray WSSEND cchave WSRECEIVE oWSEventosArrayResult WSCLIENT WSERP
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<EventosArray xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("chave", ::cchave, cchave , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</EventosArray>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://tempuri.org/EventosArray",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"https://cloud.importaxml.com.br/WS/ERP.asmx")

::Init()
::oWSEventosArrayResult:SoapRecv( WSAdvValue( oXmlRet,"_EVENTOSARRAYRESPONSE:_EVENTOSARRAYRESULT","ArrayOfZBE990",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ZBZ990Adciona of Service WSERP

WSMETHOD ZBZ990Adciona WSSEND oWSzbz,ncontaID WSRECEIVE cZBZ990AdcionaResult WSCLIENT WSERP
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ZBZ990Adciona xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("zbz", ::oWSzbz, oWSzbz , "ZBZ990", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("contaID", ::ncontaID, ncontaID , "int", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ZBZ990Adciona>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://tempuri.org/ZBZ990Adciona",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"https://cloud.importaxml.com.br/WS/ERP.asmx")

::Init()
::cZBZ990AdcionaResult :=  WSAdvValue( oXmlRet,"_ZBZ990ADCIONARESPONSE:_ZBZ990ADCIONARESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ZBE990Adciona of Service WSERP

WSMETHOD ZBE990Adciona WSSEND oWSzbe,ncontaID WSRECEIVE cZBE990AdcionaResult WSCLIENT WSERP
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ZBE990Adciona xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("zbe", ::oWSzbe, oWSzbe , "ZBE990", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("contaID", ::ncontaID, ncontaID , "int", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ZBE990Adciona>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://tempuri.org/ZBE990Adciona",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"https://cloud.importaxml.com.br/WS/ERP.asmx")

::Init()
::cZBE990AdcionaResult :=  WSAdvValue( oXmlRet,"_ZBE990ADCIONARESPONSE:_ZBE990ADCIONARESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure Conta

WSSTRUCT ERP_Conta
	WSDATA   nID                       AS int
	WSDATA   cNome                     AS string OPTIONAL
	WSDATA   cArea                     AS string OPTIONAL
	WSDATA   cDataCadastro             AS dateTime
	WSDATA   nStatusID                 AS int
	WSDATA   cMemo                     AS string OPTIONAL
	WSDATA   cTelefoneFixo             AS string OPTIONAL
	WSDATA   cRamal                    AS string OPTIONAL
	WSDATA   cTelefoneMovel            AS string OPTIONAL
	WSDATA   cEmail                    AS string OPTIONAL
	WSDATA   cSenha                    AS string OPTIONAL
	WSDATA   cToken                    AS string OPTIONAL
	WSDATA   cFoto                     AS string OPTIONAL
	WSDATA   nFormaPagamentoID         AS int
	WSDATA   nPlanoID                  AS int
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ERP_Conta
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ERP_Conta
Return

WSMETHOD CLONE WSCLIENT ERP_Conta
	Local oClone := ERP_Conta():NEW()
	oClone:nID                  := ::nID
	oClone:cNome                := ::cNome
	oClone:cArea                := ::cArea
	oClone:cDataCadastro        := ::cDataCadastro
	oClone:nStatusID            := ::nStatusID
	oClone:cMemo                := ::cMemo
	oClone:cTelefoneFixo        := ::cTelefoneFixo
	oClone:cRamal               := ::cRamal
	oClone:cTelefoneMovel       := ::cTelefoneMovel
	oClone:cEmail               := ::cEmail
	oClone:cSenha               := ::cSenha
	oClone:cToken               := ::cToken
	oClone:cFoto                := ::cFoto
	oClone:nFormaPagamentoID    := ::nFormaPagamentoID
	oClone:nPlanoID             := ::nPlanoID
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ERP_Conta
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nID                :=  WSAdvValue( oResponse,"_ID","int",NIL,"Property nID as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cNome              :=  WSAdvValue( oResponse,"_NOME","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cArea              :=  WSAdvValue( oResponse,"_AREA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDataCadastro      :=  WSAdvValue( oResponse,"_DATACADASTRO","dateTime",NIL,"Property cDataCadastro as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nStatusID          :=  WSAdvValue( oResponse,"_STATUSID","int",NIL,"Property nStatusID as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cMemo              :=  WSAdvValue( oResponse,"_MEMO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cTelefoneFixo      :=  WSAdvValue( oResponse,"_TELEFONEFIXO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cRamal             :=  WSAdvValue( oResponse,"_RAMAL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cTelefoneMovel     :=  WSAdvValue( oResponse,"_TELEFONEMOVEL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cEmail             :=  WSAdvValue( oResponse,"_EMAIL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cSenha             :=  WSAdvValue( oResponse,"_SENHA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cToken             :=  WSAdvValue( oResponse,"_TOKEN","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cFoto              :=  WSAdvValue( oResponse,"_FOTO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nFormaPagamentoID  :=  WSAdvValue( oResponse,"_FORMAPAGAMENTOID","int",NIL,"Property nFormaPagamentoID as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nPlanoID           :=  WSAdvValue( oResponse,"_PLANOID","int",NIL,"Property nPlanoID as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure ArrayOfZBZ990

WSSTRUCT ERP_ArrayOfZBZ990
	WSDATA   oWSZBZ990                 AS ERP_ZBZ990 OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ERP_ArrayOfZBZ990
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ERP_ArrayOfZBZ990
	::oWSZBZ990            := {} // Array Of  ERP_ZBZ990():New()
Return

WSMETHOD CLONE WSCLIENT ERP_ArrayOfZBZ990
	Local oClone := ERP_ArrayOfZBZ990():NEW()
	oClone:oWSZBZ990 := NIL
	If ::oWSZBZ990 <> NIL 
		oClone:oWSZBZ990 := {}
		aEval( ::oWSZBZ990 , { |x| aadd( oClone:oWSZBZ990 , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ERP_ArrayOfZBZ990
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ZBZ990","ZBZ990",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSZBZ990 , ERP_ZBZ990():New() )
			::oWSZBZ990[len(::oWSZBZ990)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ArrayOfZBE990

WSSTRUCT ERP_ArrayOfZBE990
	WSDATA   oWSZBE990                 AS ERP_ZBE990 OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ERP_ArrayOfZBE990
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ERP_ArrayOfZBE990
	::oWSZBE990            := {} // Array Of  ERP_ZBE990():New()
Return

WSMETHOD CLONE WSCLIENT ERP_ArrayOfZBE990
	Local oClone := ERP_ArrayOfZBE990():NEW()
	oClone:oWSZBE990 := NIL
	If ::oWSZBE990 <> NIL 
		oClone:oWSZBE990 := {}
		aEval( ::oWSZBE990 , { |x| aadd( oClone:oWSZBE990 , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ERP_ArrayOfZBE990
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ZBE990","ZBE990",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSZBE990 , ERP_ZBE990():New() )
			::oWSZBE990[len(::oWSZBE990)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ZBZ990

WSSTRUCT ERP_ZBZ990
	WSDATA   nID                       AS int
	WSDATA   cZBZ_FILIAL               AS string OPTIONAL
	WSDATA   cZBZ_MODELO               AS string OPTIONAL
	WSDATA   cZBZ_UF                   AS string OPTIONAL
	WSDATA   cZBZ_SERIE                AS string OPTIONAL
	WSDATA   cZBZ_NOTA                 AS string OPTIONAL
	WSDATA   cZBZ_DTNFE                AS dateTime
	WSDATA   cZBZ_PROT                 AS string OPTIONAL
	WSDATA   cZBZ_PRENF                AS string OPTIONAL
	WSDATA   cZBZ_CNPJ                 AS string OPTIONAL
	WSDATA   cZBZ_FORNEC               AS string OPTIONAL
	WSDATA   cZBZ_CNPJD                AS string OPTIONAL
	WSDATA   cZBZ_CLIENT               AS string OPTIONAL
	WSDATA   cZBZ_CHAVE                AS string OPTIONAL
	WSDATA   cZBZ_XML                  AS base64Binary OPTIONAL
	WSDATA   cZBZ_DTRECB               AS string OPTIONAL
	WSDATA   cZBZ_DTHRCS               AS string OPTIONAL
	WSDATA   cZBZ_DTHRUC               AS string OPTIONAL
	WSDATA   cZBZ_CODFOR               AS string OPTIONAL
	WSDATA   cZBZ_LOJFOR               AS string OPTIONAL
	WSDATA   cZBZ_STATUS               AS string OPTIONAL
	WSDATA   cZBZ_STATUSSAFAZ          AS string OPTIONAL
	WSDATA   cZBZ_STATUSSEFAZ_DESCRICAO AS string OPTIONAL
	WSDATA   cZBZ_OBS                  AS base64Binary OPTIONAL
	WSDATA   cZBZ_TPEMIS               AS string OPTIONAL
	WSDATA   cZBZ_TPAMB                AS string OPTIONAL
	WSDATA   cZBZ_TPDOC                AS string OPTIONAL
	WSDATA   cZBZ_FORPAG               AS string OPTIONAL
	WSDATA   cZBZ_TOMA                 AS string OPTIONAL
	WSDATA   cZBZ_DTHCAN               AS string OPTIONAL
	WSDATA   cZBZ_PROTC                AS string OPTIONAL
	WSDATA   cZBZ_XMLCAN               AS base64Binary OPTIONAL
	WSDATA   cZBZ_VERSAO               AS string OPTIONAL
	WSDATA   cZBZ_MAIL                 AS string OPTIONAL
	WSDATA   cZBZ_DTMAIL               AS base64Binary OPTIONAL
	WSDATA   cZBZ_SERORI               AS string OPTIONAL
	WSDATA   cZBZ_EXP                  AS string OPTIONAL
	WSDATA   cZBZ_MANIF                AS string OPTIONAL
	WSDATA   cZBZ_CONDPG               AS base64Binary OPTIONAL
	WSDATA   cZBZ_TPCTE                AS string OPTIONAL
	WSDATA   cZBZ_DOCCTE               AS string OPTIONAL
	WSDATA   nZBZ_VLLIQ                AS double OPTIONAL
	WSDATA   nZBZ_VLIMP                AS double OPTIONAL
	WSDATA   nZBZ_VLDESC               AS double OPTIONAL
	WSDATA   nZBZ_VLBRUT               AS double OPTIONAL
	WSDATA   cD_E_L_E_T_               AS string OPTIONAL
	WSDATA   nR_E_C_N_O_               AS int
	WSDATA   nR_E_C_D_E_L_             AS int
	WSDATA   nEmpresaID                AS int
	WSDATA   cDataEntradaWeb           AS dateTime
	WSDATA   cZBZ_DESCRICAO            AS string OPTIONAL
	WSDATA   cZBZ_PDF                  AS base64Binary OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ERP_ZBZ990
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ERP_ZBZ990
Return

WSMETHOD CLONE WSCLIENT ERP_ZBZ990
	Local oClone := ERP_ZBZ990():NEW()
	oClone:nID                  := ::nID
	oClone:cZBZ_FILIAL          := ::cZBZ_FILIAL
	oClone:cZBZ_MODELO          := ::cZBZ_MODELO
	oClone:cZBZ_UF              := ::cZBZ_UF
	oClone:cZBZ_SERIE           := ::cZBZ_SERIE
	oClone:cZBZ_NOTA            := ::cZBZ_NOTA
	oClone:cZBZ_DTNFE           := ::cZBZ_DTNFE
	oClone:cZBZ_PROT            := ::cZBZ_PROT
	oClone:cZBZ_PRENF           := ::cZBZ_PRENF
	oClone:cZBZ_CNPJ            := ::cZBZ_CNPJ
	oClone:cZBZ_FORNEC          := ::cZBZ_FORNEC
	oClone:cZBZ_CNPJD           := ::cZBZ_CNPJD
	oClone:cZBZ_CLIENT          := ::cZBZ_CLIENT
	oClone:cZBZ_CHAVE           := ::cZBZ_CHAVE
	oClone:cZBZ_XML             := ::cZBZ_XML
	oClone:cZBZ_DTRECB          := ::cZBZ_DTRECB
	oClone:cZBZ_DTHRCS          := ::cZBZ_DTHRCS
	oClone:cZBZ_DTHRUC          := ::cZBZ_DTHRUC
	oClone:cZBZ_CODFOR          := ::cZBZ_CODFOR
	oClone:cZBZ_LOJFOR          := ::cZBZ_LOJFOR
	oClone:cZBZ_STATUS          := ::cZBZ_STATUS
	oClone:cZBZ_STATUSSAFAZ     := ::cZBZ_STATUSSAFAZ
	oClone:cZBZ_STATUSSEFAZ_DESCRICAO := ::cZBZ_STATUSSEFAZ_DESCRICAO
	oClone:cZBZ_OBS             := ::cZBZ_OBS
	oClone:cZBZ_TPEMIS          := ::cZBZ_TPEMIS
	oClone:cZBZ_TPAMB           := ::cZBZ_TPAMB
	oClone:cZBZ_TPDOC           := ::cZBZ_TPDOC
	oClone:cZBZ_FORPAG          := ::cZBZ_FORPAG
	oClone:cZBZ_TOMA            := ::cZBZ_TOMA
	oClone:cZBZ_DTHCAN          := ::cZBZ_DTHCAN
	oClone:cZBZ_PROTC           := ::cZBZ_PROTC
	oClone:cZBZ_XMLCAN          := ::cZBZ_XMLCAN
	oClone:cZBZ_VERSAO          := ::cZBZ_VERSAO
	oClone:cZBZ_MAIL            := ::cZBZ_MAIL
	oClone:cZBZ_DTMAIL          := ::cZBZ_DTMAIL
	oClone:cZBZ_SERORI          := ::cZBZ_SERORI
	oClone:cZBZ_EXP             := ::cZBZ_EXP
	oClone:cZBZ_MANIF           := ::cZBZ_MANIF
	oClone:cZBZ_CONDPG          := ::cZBZ_CONDPG
	oClone:cZBZ_TPCTE           := ::cZBZ_TPCTE
	oClone:cZBZ_DOCCTE          := ::cZBZ_DOCCTE
	oClone:nZBZ_VLLIQ           := ::nZBZ_VLLIQ
	oClone:nZBZ_VLIMP           := ::nZBZ_VLIMP
	oClone:nZBZ_VLDESC          := ::nZBZ_VLDESC
	oClone:nZBZ_VLBRUT          := ::nZBZ_VLBRUT
	oClone:cD_E_L_E_T_          := ::cD_E_L_E_T_
	oClone:nR_E_C_N_O_          := ::nR_E_C_N_O_
	oClone:nR_E_C_D_E_L_        := ::nR_E_C_D_E_L_
	oClone:nEmpresaID           := ::nEmpresaID
	oClone:cDataEntradaWeb      := ::cDataEntradaWeb
	oClone:cZBZ_DESCRICAO       := ::cZBZ_DESCRICAO
	oClone:cZBZ_PDF             := ::cZBZ_PDF
Return oClone

WSMETHOD SOAPSEND WSCLIENT ERP_ZBZ990
	Local cSoap := ""
	cSoap += WSSoapValue("ID", ::nID, ::nID , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ZBZ_FILIAL", ::cZBZ_FILIAL, ::cZBZ_FILIAL , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ZBZ_MODELO", ::cZBZ_MODELO, ::cZBZ_MODELO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ZBZ_UF", ::cZBZ_UF, ::cZBZ_UF , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ZBZ_SERIE", ::cZBZ_SERIE, ::cZBZ_SERIE , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ZBZ_NOTA", ::cZBZ_NOTA, ::cZBZ_NOTA , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ZBZ_DTNFE", ::cZBZ_DTNFE, ::cZBZ_DTNFE , "dateTime", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ZBZ_PROT", ::cZBZ_PROT, ::cZBZ_PROT , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ZBZ_PRENF", ::cZBZ_PRENF, ::cZBZ_PRENF , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ZBZ_CNPJ", ::cZBZ_CNPJ, ::cZBZ_CNPJ , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ZBZ_FORNEC", ::cZBZ_FORNEC, ::cZBZ_FORNEC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ZBZ_CNPJD", ::cZBZ_CNPJD, ::cZBZ_CNPJD , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ZBZ_CLIENT", ::cZBZ_CLIENT, ::cZBZ_CLIENT , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ZBZ_CHAVE", ::cZBZ_CHAVE, ::cZBZ_CHAVE , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ZBZ_XML", ::cZBZ_XML, ::cZBZ_XML , "base64Binary", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ZBZ_DTRECB", ::cZBZ_DTRECB, ::cZBZ_DTRECB , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ZBZ_DTHRCS", ::cZBZ_DTHRCS, ::cZBZ_DTHRCS , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ZBZ_DTHRUC", ::cZBZ_DTHRUC, ::cZBZ_DTHRUC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ZBZ_CODFOR", ::cZBZ_CODFOR, ::cZBZ_CODFOR , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ZBZ_LOJFOR", ::cZBZ_LOJFOR, ::cZBZ_LOJFOR , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ZBZ_STATUS", ::cZBZ_STATUS, ::cZBZ_STATUS , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ZBZ_STATUSSAFAZ", ::cZBZ_STATUSSAFAZ, ::cZBZ_STATUSSAFAZ , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ZBZ_STATUSSEFAZ_DESCRICAO", ::cZBZ_STATUSSEFAZ_DESCRICAO, ::cZBZ_STATUSSEFAZ_DESCRICAO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ZBZ_OBS", ::cZBZ_OBS, ::cZBZ_OBS , "base64Binary", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ZBZ_TPEMIS", ::cZBZ_TPEMIS, ::cZBZ_TPEMIS , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ZBZ_TPAMB", ::cZBZ_TPAMB, ::cZBZ_TPAMB , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ZBZ_TPDOC", ::cZBZ_TPDOC, ::cZBZ_TPDOC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ZBZ_FORPAG", ::cZBZ_FORPAG, ::cZBZ_FORPAG , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ZBZ_TOMA", ::cZBZ_TOMA, ::cZBZ_TOMA , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ZBZ_DTHCAN", ::cZBZ_DTHCAN, ::cZBZ_DTHCAN , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ZBZ_PROTC", ::cZBZ_PROTC, ::cZBZ_PROTC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ZBZ_XMLCAN", ::cZBZ_XMLCAN, ::cZBZ_XMLCAN , "base64Binary", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ZBZ_VERSAO", ::cZBZ_VERSAO, ::cZBZ_VERSAO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ZBZ_MAIL", ::cZBZ_MAIL, ::cZBZ_MAIL , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ZBZ_DTMAIL", ::cZBZ_DTMAIL, ::cZBZ_DTMAIL , "base64Binary", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ZBZ_SERORI", ::cZBZ_SERORI, ::cZBZ_SERORI , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ZBZ_EXP", ::cZBZ_EXP, ::cZBZ_EXP , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ZBZ_MANIF", ::cZBZ_MANIF, ::cZBZ_MANIF , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ZBZ_CONDPG", ::cZBZ_CONDPG, ::cZBZ_CONDPG , "base64Binary", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ZBZ_TPCTE", ::cZBZ_TPCTE, ::cZBZ_TPCTE , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ZBZ_DOCCTE", ::cZBZ_DOCCTE, ::cZBZ_DOCCTE , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ZBZ_VLLIQ", ::nZBZ_VLLIQ, ::nZBZ_VLLIQ , "double", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ZBZ_VLIMP", ::nZBZ_VLIMP, ::nZBZ_VLIMP , "double", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ZBZ_VLDESC", ::nZBZ_VLDESC, ::nZBZ_VLDESC , "double", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ZBZ_VLBRUT", ::nZBZ_VLBRUT, ::nZBZ_VLBRUT , "double", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("D_E_L_E_T_", ::cD_E_L_E_T_, ::cD_E_L_E_T_ , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("R_E_C_N_O_", ::nR_E_C_N_O_, ::nR_E_C_N_O_ , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("R_E_C_D_E_L_", ::nR_E_C_D_E_L_, ::nR_E_C_D_E_L_ , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("EmpresaID", ::nEmpresaID, ::nEmpresaID , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DataEntradaWeb", ::cDataEntradaWeb, ::cDataEntradaWeb , "dateTime", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ZBZ_DESCRICAO", ::cZBZ_DESCRICAO, ::cZBZ_DESCRICAO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ZBZ_PDF", ::cZBZ_PDF, ::cZBZ_PDF , "base64Binary", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ERP_ZBZ990
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nID                :=  WSAdvValue( oResponse,"_ID","int",NIL,"Property nID as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cZBZ_FILIAL        :=  WSAdvValue( oResponse,"_ZBZ_FILIAL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cZBZ_MODELO        :=  WSAdvValue( oResponse,"_ZBZ_MODELO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cZBZ_UF            :=  WSAdvValue( oResponse,"_ZBZ_UF","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cZBZ_SERIE         :=  WSAdvValue( oResponse,"_ZBZ_SERIE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cZBZ_NOTA          :=  WSAdvValue( oResponse,"_ZBZ_NOTA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cZBZ_DTNFE         :=  WSAdvValue( oResponse,"_ZBZ_DTNFE","dateTime",NIL,"Property cZBZ_DTNFE as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cZBZ_PROT          :=  WSAdvValue( oResponse,"_ZBZ_PROT","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cZBZ_PRENF         :=  WSAdvValue( oResponse,"_ZBZ_PRENF","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cZBZ_CNPJ          :=  WSAdvValue( oResponse,"_ZBZ_CNPJ","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cZBZ_FORNEC        :=  WSAdvValue( oResponse,"_ZBZ_FORNEC","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cZBZ_CNPJD         :=  WSAdvValue( oResponse,"_ZBZ_CNPJD","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cZBZ_CLIENT        :=  WSAdvValue( oResponse,"_ZBZ_CLIENT","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cZBZ_CHAVE         :=  WSAdvValue( oResponse,"_ZBZ_CHAVE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cZBZ_XML           :=  WSAdvValue( oResponse,"_ZBZ_XML","base64Binary",NIL,NIL,NIL,"SB",NIL,NIL) 
	::cZBZ_DTRECB        :=  WSAdvValue( oResponse,"_ZBZ_DTRECB","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cZBZ_DTHRCS        :=  WSAdvValue( oResponse,"_ZBZ_DTHRCS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cZBZ_DTHRUC        :=  WSAdvValue( oResponse,"_ZBZ_DTHRUC","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cZBZ_CODFOR        :=  WSAdvValue( oResponse,"_ZBZ_CODFOR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cZBZ_LOJFOR        :=  WSAdvValue( oResponse,"_ZBZ_LOJFOR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cZBZ_STATUS        :=  WSAdvValue( oResponse,"_ZBZ_STATUS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cZBZ_STATUSSAFAZ   :=  WSAdvValue( oResponse,"_ZBZ_STATUSSAFAZ","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cZBZ_STATUSSEFAZ_DESCRICAO :=  WSAdvValue( oResponse,"_ZBZ_STATUSSEFAZ_DESCRICAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cZBZ_OBS           :=  WSAdvValue( oResponse,"_ZBZ_OBS","base64Binary",NIL,NIL,NIL,"SB",NIL,NIL) 
	::cZBZ_TPEMIS        :=  WSAdvValue( oResponse,"_ZBZ_TPEMIS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cZBZ_TPAMB         :=  WSAdvValue( oResponse,"_ZBZ_TPAMB","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cZBZ_TPDOC         :=  WSAdvValue( oResponse,"_ZBZ_TPDOC","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cZBZ_FORPAG        :=  WSAdvValue( oResponse,"_ZBZ_FORPAG","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cZBZ_TOMA          :=  WSAdvValue( oResponse,"_ZBZ_TOMA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cZBZ_DTHCAN        :=  WSAdvValue( oResponse,"_ZBZ_DTHCAN","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cZBZ_PROTC         :=  WSAdvValue( oResponse,"_ZBZ_PROTC","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cZBZ_XMLCAN        :=  WSAdvValue( oResponse,"_ZBZ_XMLCAN","base64Binary",NIL,NIL,NIL,"SB",NIL,NIL) 
	::cZBZ_VERSAO        :=  WSAdvValue( oResponse,"_ZBZ_VERSAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cZBZ_MAIL          :=  WSAdvValue( oResponse,"_ZBZ_MAIL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cZBZ_DTMAIL        :=  WSAdvValue( oResponse,"_ZBZ_DTMAIL","base64Binary",NIL,NIL,NIL,"SB",NIL,NIL) 
	::cZBZ_SERORI        :=  WSAdvValue( oResponse,"_ZBZ_SERORI","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cZBZ_EXP           :=  WSAdvValue( oResponse,"_ZBZ_EXP","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cZBZ_MANIF         :=  WSAdvValue( oResponse,"_ZBZ_MANIF","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cZBZ_CONDPG        :=  WSAdvValue( oResponse,"_ZBZ_CONDPG","base64Binary",NIL,NIL,NIL,"SB",NIL,NIL) 
	::cZBZ_TPCTE         :=  WSAdvValue( oResponse,"_ZBZ_TPCTE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cZBZ_DOCCTE        :=  WSAdvValue( oResponse,"_ZBZ_DOCCTE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nZBZ_VLLIQ         :=  WSAdvValue( oResponse,"_ZBZ_VLLIQ","double",NIL,NIL,NIL,"N",NIL,NIL) 
	::nZBZ_VLIMP         :=  WSAdvValue( oResponse,"_ZBZ_VLIMP","double",NIL,NIL,NIL,"N",NIL,NIL) 
	::nZBZ_VLDESC        :=  WSAdvValue( oResponse,"_ZBZ_VLDESC","double",NIL,NIL,NIL,"N",NIL,NIL) 
	::nZBZ_VLBRUT        :=  WSAdvValue( oResponse,"_ZBZ_VLBRUT","double",NIL,NIL,NIL,"N",NIL,NIL) 
	::cD_E_L_E_T_        :=  WSAdvValue( oResponse,"_D_E_L_E_T_","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nR_E_C_N_O_        :=  WSAdvValue( oResponse,"_R_E_C_N_O_","int",NIL,"Property nR_E_C_N_O_ as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nR_E_C_D_E_L_      :=  WSAdvValue( oResponse,"_R_E_C_D_E_L_","int",NIL,"Property nR_E_C_D_E_L_ as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nEmpresaID         :=  WSAdvValue( oResponse,"_EMPRESAID","int",NIL,"Property nEmpresaID as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cDataEntradaWeb    :=  WSAdvValue( oResponse,"_DATAENTRADAWEB","dateTime",NIL,"Property cDataEntradaWeb as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cZBZ_DESCRICAO     :=  WSAdvValue( oResponse,"_ZBZ_DESCRICAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cZBZ_PDF           :=  WSAdvValue( oResponse,"_ZBZ_PDF","base64Binary",NIL,NIL,NIL,"SB",NIL,NIL) 
Return

// WSDL Data Structure ZBE990

WSSTRUCT ERP_ZBE990
	WSDATA   nID                       AS int
	WSDATA   cZBE_FILIAL               AS string OPTIONAL
	WSDATA   cZBE_CHAVE                AS string OPTIONAL
	WSDATA   cZBE_TPEVE                AS string OPTIONAL
	WSDATA   cZBE_SEQEVE               AS string OPTIONAL
	WSDATA   cZBE_STATUS               AS string OPTIONAL
	WSDATA   cZBE_DHAUT                AS string OPTIONAL
	WSDATA   cZBE_PROT                 AS string OPTIONAL
	WSDATA   cZBE_DTRECB               AS string OPTIONAL
	WSDATA   cZBE_DESC                 AS string OPTIONAL
	WSDATA   cZBE_XML                  AS base64Binary OPTIONAL
	WSDATA   cZBE_EVENTO               AS base64Binary OPTIONAL
	WSDATA   cD_E_L_E_T_               AS string OPTIONAL
	WSDATA   nR_E_C_N_O_               AS int
	WSDATA   nR_E_C_D_E_L_             AS int
	WSDATA   nEmpresaID                AS int
	WSDATA   cDataEntradaWeb           AS dateTime
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ERP_ZBE990
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ERP_ZBE990
Return

WSMETHOD CLONE WSCLIENT ERP_ZBE990
	Local oClone := ERP_ZBE990():NEW()
	oClone:nID                  := ::nID
	oClone:cZBE_FILIAL          := ::cZBE_FILIAL
	oClone:cZBE_CHAVE           := ::cZBE_CHAVE
	oClone:cZBE_TPEVE           := ::cZBE_TPEVE
	oClone:cZBE_SEQEVE          := ::cZBE_SEQEVE
	oClone:cZBE_STATUS          := ::cZBE_STATUS
	oClone:cZBE_DHAUT           := ::cZBE_DHAUT
	oClone:cZBE_PROT            := ::cZBE_PROT
	oClone:cZBE_DTRECB          := ::cZBE_DTRECB
	oClone:cZBE_DESC            := ::cZBE_DESC
	oClone:cZBE_XML             := ::cZBE_XML
	oClone:cZBE_EVENTO          := ::cZBE_EVENTO
	oClone:cD_E_L_E_T_          := ::cD_E_L_E_T_
	oClone:nR_E_C_N_O_          := ::nR_E_C_N_O_
	oClone:nR_E_C_D_E_L_        := ::nR_E_C_D_E_L_
	oClone:nEmpresaID           := ::nEmpresaID
	oClone:cDataEntradaWeb      := ::cDataEntradaWeb
Return oClone

WSMETHOD SOAPSEND WSCLIENT ERP_ZBE990
	Local cSoap := ""
	cSoap += WSSoapValue("ID", ::nID, ::nID , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ZBE_FILIAL", ::cZBE_FILIAL, ::cZBE_FILIAL , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ZBE_CHAVE", ::cZBE_CHAVE, ::cZBE_CHAVE , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ZBE_TPEVE", ::cZBE_TPEVE, ::cZBE_TPEVE , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ZBE_SEQEVE", ::cZBE_SEQEVE, ::cZBE_SEQEVE , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ZBE_STATUS", ::cZBE_STATUS, ::cZBE_STATUS , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ZBE_DHAUT", ::cZBE_DHAUT, ::cZBE_DHAUT , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ZBE_PROT", ::cZBE_PROT, ::cZBE_PROT , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ZBE_DTRECB", ::cZBE_DTRECB, ::cZBE_DTRECB , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ZBE_DESC", ::cZBE_DESC, ::cZBE_DESC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ZBE_XML", ::cZBE_XML, ::cZBE_XML , "base64Binary", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ZBE_EVENTO", ::cZBE_EVENTO, ::cZBE_EVENTO , "base64Binary", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("D_E_L_E_T_", ::cD_E_L_E_T_, ::cD_E_L_E_T_ , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("R_E_C_N_O_", ::nR_E_C_N_O_, ::nR_E_C_N_O_ , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("R_E_C_D_E_L_", ::nR_E_C_D_E_L_, ::nR_E_C_D_E_L_ , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("EmpresaID", ::nEmpresaID, ::nEmpresaID , "int", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DataEntradaWeb", ::cDataEntradaWeb, ::cDataEntradaWeb , "dateTime", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT ERP_ZBE990
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nID                :=  WSAdvValue( oResponse,"_ID","int",NIL,"Property nID as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cZBE_FILIAL        :=  WSAdvValue( oResponse,"_ZBE_FILIAL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cZBE_CHAVE         :=  WSAdvValue( oResponse,"_ZBE_CHAVE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cZBE_TPEVE         :=  WSAdvValue( oResponse,"_ZBE_TPEVE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cZBE_SEQEVE        :=  WSAdvValue( oResponse,"_ZBE_SEQEVE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cZBE_STATUS        :=  WSAdvValue( oResponse,"_ZBE_STATUS","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cZBE_DHAUT         :=  WSAdvValue( oResponse,"_ZBE_DHAUT","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cZBE_PROT          :=  WSAdvValue( oResponse,"_ZBE_PROT","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cZBE_DTRECB        :=  WSAdvValue( oResponse,"_ZBE_DTRECB","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cZBE_DESC          :=  WSAdvValue( oResponse,"_ZBE_DESC","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cZBE_XML           :=  WSAdvValue( oResponse,"_ZBE_XML","base64Binary",NIL,NIL,NIL,"SB",NIL,NIL) 
	::cZBE_EVENTO        :=  WSAdvValue( oResponse,"_ZBE_EVENTO","base64Binary",NIL,NIL,NIL,"SB",NIL,NIL) 
	::cD_E_L_E_T_        :=  WSAdvValue( oResponse,"_D_E_L_E_T_","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nR_E_C_N_O_        :=  WSAdvValue( oResponse,"_R_E_C_N_O_","int",NIL,"Property nR_E_C_N_O_ as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nR_E_C_D_E_L_      :=  WSAdvValue( oResponse,"_R_E_C_D_E_L_","int",NIL,"Property nR_E_C_D_E_L_ as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nEmpresaID         :=  WSAdvValue( oResponse,"_EMPRESAID","int",NIL,"Property nEmpresaID as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cDataEntradaWeb    :=  WSAdvValue( oResponse,"_DATAENTRADAWEB","dateTime",NIL,"Property cDataEntradaWeb as s:dateTime on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return


