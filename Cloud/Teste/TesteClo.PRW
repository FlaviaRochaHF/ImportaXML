#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"                                                                                                                           



//==============================================   AKIIIII   ================================================================
USer Function TesteClo()  //U_TesteClo()  //AQUI ENVIA a ZBZ
Local oWs, oXmlRet
Local cAliasZBZ := GetNextAlias()
Local cXmlRet := ""
Local cErro := "", cWarning := ""
Local nCloId:= 0
Local cQuery := ""
Private xZBZ  	  := GetNewPar("XM_TABXML","ZBZ")      //ECOOOOOOOOOO
Private xZBZ_ 	  := iif(Substr(xZBZ,1,1)=="S", Substr(xZBZ,2,2), Substr(xZBZ,1,3)) + "_"


oWS:=WSERP():New() 

//Fazer uma ABA com parâmetros da conta. Informar o toquem, executar o WS e pegar os dados
//ver quais parâmetros criar
oWS:ctoken := "5060-DDD2-1719"
oWS:INIT()

If oWS:DadosDaConta()
	nCloId := oWS:oWSDadosDaContaResult:nID

	Alert(oWS:oWSDadosDaContaResult:cNome)

Else

	Alert( "Errou Jacaré" )
	Quit

Endif

oWS:ncontaID := nCloId

DbSelectArea( "ZBZ" )

cQuery += " select TOP 2 CONVERT(datetime, "+xZBZ_+"DTNFE, 103) AS DTCONV, CONVERT(datetime, "+xZBZ_+"DTRECB, 103) AS DTCONV2, ZBZ.D_E_L_E_T_ as DELET, ZBZ.R_E_C_N_O_ as RECN, ZBZ.* "
cQuery += " from "+RetSqlName(xZBZ)+" ZBZ "
cQuery += " order by R_E_C_N_O_ DESC "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasZBZ)

DbSelectARea( cAliasZBZ )
(cAliasZBZ)->( dbGoTop() )
dbskip()
Do While .NOT. (cAliasZBZ)->( Eof() )

	oWS:oWSzbz   := NIL
	oWS:oWSzbz   := ERP_ZBZ990():New()
	oWS:oWSzbz:nID          := 0
	oWS:oWSzbz:cZBZ_FILIAL  := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL")))
	oWS:oWSzbz:cZBZ_MODELO  := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO")))
	oWS:oWSzbz:cZBZ_UF      := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"UF")))
	oWS:oWSzbz:cZBZ_SERIE   := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE")))
	oWS:oWSzbz:cZBZ_NOTA    := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA")))
	oWS:oWSzbz:cZBZ_DTNFE   := (cAliasZBZ)->DTCONV //            AS dateTime  AQUIII ATENCAO, VER a DATA CONVERTIDA
	oWS:oWSzbz:cZBZ_PROT    := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"PROT")))
	oWS:oWSzbz:cZBZ_PRENF   := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF")))
	oWS:oWSzbz:cZBZ_CNPJ    := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ")))
	oWS:oWSzbz:cZBZ_FORNEC  := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"FORNEC")))
	oWS:oWSzbz:cZBZ_CNPJD   := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJD")))
	oWS:oWSzbz:cZBZ_CLIENT  := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"CLIENT")))
	oWS:oWSzbz:cZBZ_CHAVE   := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE")))
                    
					DbSelectArea( "ZBZ" )
					dbgoto( (cAliasZBZ)->RECN )
					cFileZip	:= Decode64( ZKZ->(FieldGet(FieldPos(xZBZ_+"XML"))) )
					nLenZip		:= Len( cFileZip )
					cFileUnZip  := ""

					// Funcao de descompactacao de arquivos compactados no formato GZip
					lOk  :=  GzStrDecomp( cFileZip, nLenZip, @cFileUnZip )

	oWS:oWSzbz:cZBZ_XML     := ZBZ->(FieldGet(FieldPos(xZBZ_+"XML"))) //cFileUnZip  //(cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"XML")))
	oWS:oWSzbz:cZBZ_DTRECB  := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"DTRECB")))   // (cAliasZBZ)->DTCONV2 //convDt( ZBZ->(FieldGet(FieldPos(xZBZ_+"DTRECB )  AQUIIIIII DATA CONVERTIDA
	oWS:oWSzbz:cZBZ_DTHRCS  := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"DTHRCS")))
	oWS:oWSzbz:cZBZ_DTHRUC  := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"DTHRUC")))
	oWS:oWSzbz:cZBZ_CODFOR  := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR")))
	oWS:oWSzbz:cZBZ_LOJFOR  := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR")))
	oWS:oWSzbz:cZBZ_STATUS  := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"STATUS")))
	oWS:oWSzbz:cZBZ_OBS     := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"OBS")))
	oWS:oWSzbz:cZBZ_TPEMIS  := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"TPEMIS")))
	oWS:oWSzbz:cZBZ_TPAMB   := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"TPAMB")))
	oWS:oWSzbz:cZBZ_TPDOC   := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC")))
	oWS:oWSzbz:cZBZ_FORPAG  := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"FORPAG")))
	oWS:oWSzbz:cZBZ_TOMA    := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"TOMA")))
	oWS:oWSzbz:cZBZ_DTHCAN  := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"DTHCAN")))
	oWS:oWSzbz:cZBZ_PROTC   := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"PROTC")))
	oWS:oWSzbz:cZBZ_XMLCAN  := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"XMLCAN")))
	oWS:oWSzbz:cZBZ_VERSAO  := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"VERSAO")))
	oWS:oWSzbz:cZBZ_MAIL    := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"MAIL")))
	oWS:oWSzbz:cZBZ_DTMAIL  := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"DTMAIL")))
	oWS:oWSzbz:cZBZ_SERORI  := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"SERORI")))
	oWS:oWSzbz:cZBZ_EXP     := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"EXP")))
	oWS:oWSzbz:cZBZ_MANIF   := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"MANIF")))
	oWS:oWSzbz:cZBZ_CONDPG  := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"CONDPG")))
	oWS:oWSzbz:cZBZ_TPCTE   := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"TPCTE")))
	oWS:oWSzbz:cZBZ_DOCCTE  := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"DOCCTE")))
	oWS:oWSzbz:nZBZ_VLLIQ   := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"VLLIQ")))
	oWS:oWSzbz:nZBZ_VLIMP   := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"VLIMP")))
	oWS:oWSzbz:nZBZ_VLDESC  := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"VLDESC")))
	oWS:oWSzbz:nZBZ_VLBRUT  := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"VLBRUT")))
	oWS:oWSzbz:cD_E_L_E_T_  := (cAliasZBZ)->DELET
	oWS:oWSzbz:nR_E_C_N_O_  := (cAliasZBZ)->RECN
	oWS:oWSzbz:nR_E_C_D_E_L_ := 0 //(cAliasZBZ)->R_E_C_D_E_L_
	oWS:oWSzbz:nEmpresaID   := 0
	oWS:oWSzbz:cDataEntradaWeb := (cAliasZBZ)->DTCONV //            AS dateTime  AQUIII ATENCAO, VER a DATA CONVERTIDA

	If oWS:ZBZ990Adciona()
		Alert( oWS:cZBZ990AdcionaResult	)
	Else
		cInfo   := IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
		Alert( cInfo )
	EndIf
	
	(cAliasZBZ)->( dbSkip() )

EndDo

Return()

//	if Len(cXmlRet) >= 65534
//		oXmlRet := U_PARSGDE( cXmlRet, @cErro, @cWarning )
//	Else
//		oXmlRet := XmlParser( cXmlRet ,"_",@cErro, @cWarning )
//	endif
//
//	Alert(oXmlRet)

Static Function convDt( ddt )
Local cRet := ""

cRet := strzero( year(ddt),4,0 )+"-"+strzero( month(ddt),2,0 )+"-"+strzero( day(ddt),2,0 ) //+ " " + "00:00:00.000"

Return( cRet )




//==============================================   AKIIIII   ================================================================
USer Function TesteZbe()  //U_TesteZbe()   //AQUIII ENVIA A ZBE
Local cAliasZBE := GetNextAlias()
Local cXmlRet := ""
Local cErro := "", cWarning := ""
Local cQuery := ""
Private xZBZ  	  := GetNewPar("XM_TABXML","ZBZ")      //ECOOOOOOOOOO
Private xZBZ_ 	  := iif(Substr(xZBZ,1,1)=="S", Substr(xZBZ,2,2), Substr(xZBZ,1,3)) + "_"
Private xZBE  	  := GetNewPar("XM_TABEVE","ZBE")      //ECOOOOOOOOOO
Private xZBE_ 	  := iif(Substr(xZBE,1,1)=="S", Substr(xZBE,2,2), Substr(xZBE,1,3)) + "_"
Private oWs, oXmlRet
Private nCloId:= 0


oWS:=WSERP():New() 

//Fazer uma ABA com parâmetros da conta. Informar o toquem, executar o WS e pegar os dados
//ver quais parâmetros criar
oWS:ctoken := "5060-DDD2-1719"
oWS:INIT()

If oWS:DadosDaConta()
	nCloId := oWS:oWSDadosDaContaResult:nID

	Alert(oWS:oWSDadosDaContaResult:cNome)

Else

	Alert( "Errrrrrrrrrrrrrrou Jacaré" )
	Quit

Endif

oWS:ncontaID := nCloId

DbSelectArea( xZBE )

cQuery += " select TOP 10 CONVERT(datetime, "+xZBE_+"DHAUT, 103) AS DTAUT, CONVERT(datetime, "+xZBE_+"DTRECB, 103) AS DTRECB, ZBE.D_E_L_E_T_ as DELET, ZBE.R_E_C_N_O_ as RECN, ZBE.* "
cQuery += " from "+RetSqlName(xZBE)+" ZBE "
cQuery += " order by R_E_C_N_O_ "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasZBE)

DbSelectARea( cAliasZBE )
(cAliasZBE)->( dbGoTop() )
Do While .NOT. (cAliasZBE)->( Eof() )

	If .NOT. MANDAZBZ( (cAliasZBE)->(FieldGet(FieldPos(xZBE_+"CHAVE"))) )
		(cAliasZBE)->( dbSkip() )
		Loop
	Endif

	DbSelectArea( xZBE )
	dbgoto( (cAliasZBE)->RECN )


	oWS:oWSzbe   := NIL
	oWS:oWSzbe   := ERP_ZBE990():New()
	oWS:oWSzbe:nID              := 0
	oWS:oWSzbe:cZBE_FILIAL      := (cAliasZBE)->(FieldGet(FieldPos(xZBE_+"FILIAL")))
	oWS:oWSzbe:cZBE_CHAVE       := (cAliasZBE)->(FieldGet(FieldPos(xZBE_+"CHAVE")))
	oWS:oWSzbe:cZBE_TPEVE       := (cAliasZBE)->(FieldGet(FieldPos(xZBE_+"TPEVE")))
	oWS:oWSzbe:cZBE_SEQEVE      := (cAliasZBE)->(FieldGet(FieldPos(xZBE_+"SEQEVE")))
	oWS:oWSzbe:cZBE_STATUS      := (cAliasZBE)->(FieldGet(FieldPos(xZBE_+"STATUS")))
	oWS:oWSzbe:cZBE_DHAUT       := (cAliasZBE)->(FieldGet(FieldPos(xZBE_+"DHAUT")))  //(cAliasZBE)->DTAUT
	oWS:oWSzbe:cZBE_PROT        := (cAliasZBE)->(FieldGet(FieldPos(xZBE_+"PROT")))
	oWS:oWSzbe:cZBE_DTRECB      := (cAliasZBE)->(FieldGet(FieldPos(xZBE_+"DTRECB")))  //(cAliasZBE)->DTRECB
	oWS:oWSzbe:cZBE_DESC        := (cAliasZBE)->(FieldGet(FieldPos(xZBE_+"DESC")))
	oWS:oWSzbe:cZBE_XML         := (xZBE)->(FieldGet(FieldPos(xZBE_+"XML")))
	oWS:oWSzbe:cZBE_EVENTO      := (xZBE)->(FieldGet(FieldPos(xZBE_+"EVENTO")))
	oWS:oWSzbe:cD_E_L_E_T_      := (cAliasZBE)->DELET
	oWS:oWSzbe:nR_E_C_N_O_      := (cAliasZBE)->RECN
	oWS:oWSzbe:nR_E_C_D_E_L_    := 0 //(cAliasZBE)->R_E_C_D_E_L_
	oWS:oWSzbe:nEmpresaID       := 0
	oWS:oWSzbe:cDataEntradaWeb  := (cAliasZBE)->DTAUT //            AS dateTime  AQUIII ATENCAO, VER a DATA CONVERTIDA

	If oWS:ZBE990Adciona()
		Alert( oWS:cZBE990AdcionaResult	)
	Else
		cInfo   := IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
		Alert( cInfo )
	EndIf
	
	(cAliasZBE)->( dbSkip() )

EndDo

Return()


Static Function MANDAZBZ( cChave )
LOcal aArea     := GetArea()
Local lRet      := .F.
Local cQuery    := ""
Local cAliasZBZ := GetNextAlias()

DbSelectArea( xZBZ )
cQuery += " select CONVERT(datetime, "+xZBZ_+"DTNFE, 103) AS DTCONV, CONVERT(datetime, "+xZBZ_+"DTRECB, 103) AS DTCONV2, ZBZ.D_E_L_E_T_ as DELET, ZBZ.R_E_C_N_O_ as RECN, ZBZ.* "
cQuery += " from "+RetSqlName(xZBZ)+" ZBZ "
cQuery += " where "+xZBZ_+"CHAVE = '"+cChave+"' "
cQuery += " AND ZBZ.D_E_L_E_T_ = ' '"


dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasZBZ)

DbSelectARea( cAliasZBZ )
(cAliasZBZ)->( dbGoTop() )
Do While .NOT. (cAliasZBZ)->( Eof() )

	oWS:oWSzbz   := NIL
	oWS:oWSzbz   := ERP_ZBZ990():New()
	oWS:oWSzbz:nID          := 0
	oWS:oWSzbz:cZBZ_FILIAL  := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL")))
	oWS:oWSzbz:cZBZ_MODELO  := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO")))
	oWS:oWSzbz:cZBZ_UF      := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"UF")))
	oWS:oWSzbz:cZBZ_SERIE   := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE")))
	oWS:oWSzbz:cZBZ_NOTA    := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA")))
	oWS:oWSzbz:cZBZ_DTNFE   := (cAliasZBZ)->DTCONV //            AS dateTime  AQUIII ATENCAO, VER a DATA CONVERTIDA
	oWS:oWSzbz:cZBZ_PROT    := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"PROT")))
	oWS:oWSzbz:cZBZ_PRENF   := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF")))
	oWS:oWSzbz:cZBZ_CNPJ    := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ")))
	oWS:oWSzbz:cZBZ_FORNEC  := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"FORNEC")))
	oWS:oWSzbz:cZBZ_CNPJD   := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJD")))
	oWS:oWSzbz:cZBZ_CLIENT  := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"CLIENT")))
	oWS:oWSzbz:cZBZ_CHAVE   := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE")))
                    
					DbSelectArea( xZBZ )
					dbgoto( (cAliasZBZ)->RECN )
					//cFileZip	:= Decode64( ZKZ->(FieldGet(FieldPos(xZBZ_+"XML"))) )
					//nLenZip		:= Len( cFileZip )
					//cFileUnZip  := ""

					// Funcao de descompactacao de arquivos compactados no formato GZip
					//lOk  :=  GzStrDecomp( cFileZip, nLenZip, @cFileUnZip )

	oWS:oWSzbz:cZBZ_XML     := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML"))) //cFileUnZip  //(cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"XML")))
	oWS:oWSzbz:cZBZ_DTRECB  := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"DTRECB")))   // (cAliasZBZ)->DTCONV2 //convDt( ZBZ->(FieldGet(FieldPos(xZBZ_+"DTRECB )  AQUIIIIII DATA CONVERTIDA
	oWS:oWSzbz:cZBZ_DTHRCS  := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"DTHRCS")))
	oWS:oWSzbz:cZBZ_DTHRUC  := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"DTHRUC")))
	oWS:oWSzbz:cZBZ_CODFOR  := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR")))
	oWS:oWSzbz:cZBZ_LOJFOR  := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR")))
	oWS:oWSzbz:cZBZ_STATUS  := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"STATUS")))
	oWS:oWSzbz:cZBZ_OBS     := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"OBS")))
	oWS:oWSzbz:cZBZ_TPEMIS  := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"TPEMIS")))
	oWS:oWSzbz:cZBZ_TPAMB   := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"TPAMB")))
	oWS:oWSzbz:cZBZ_TPDOC   := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC")))
	oWS:oWSzbz:cZBZ_FORPAG  := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"FORPAG")))
	oWS:oWSzbz:cZBZ_TOMA    := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"TOMA")))
	oWS:oWSzbz:cZBZ_DTHCAN  := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"DTHCAN")))
	oWS:oWSzbz:cZBZ_PROTC   := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"PROTC")))
	oWS:oWSzbz:cZBZ_XMLCAN  := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"XMLCAN")))
	oWS:oWSzbz:cZBZ_VERSAO  := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"VERSAO")))
	oWS:oWSzbz:cZBZ_MAIL    := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"MAIL")))
	oWS:oWSzbz:cZBZ_DTMAIL  := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"DTMAIL")))
	oWS:oWSzbz:cZBZ_SERORI  := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"SERORI")))
	oWS:oWSzbz:cZBZ_EXP     := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"EXP")))
	oWS:oWSzbz:cZBZ_MANIF   := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"MANIF")))
	oWS:oWSzbz:cZBZ_CONDPG  := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"CONDPG")))
	oWS:oWSzbz:cZBZ_TPCTE   := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"TPCTE")))
	oWS:oWSzbz:cZBZ_DOCCTE  := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"DOCCTE")))
	oWS:oWSzbz:nZBZ_VLLIQ   := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"VLLIQ")))
	oWS:oWSzbz:nZBZ_VLIMP   := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"VLIMP")))
	oWS:oWSzbz:nZBZ_VLDESC  := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"VLDESC")))
	oWS:oWSzbz:nZBZ_VLBRUT  := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"VLBRUT")))
	oWS:oWSzbz:cD_E_L_E_T_  := (cAliasZBZ)->DELET
	oWS:oWSzbz:nR_E_C_N_O_  := (cAliasZBZ)->RECN
	oWS:oWSzbz:nR_E_C_D_E_L_ := 0 //(cAliasZBZ)->R_E_C_D_E_L_
	oWS:oWSzbz:nEmpresaID   := 0
	oWS:oWSzbz:cDataEntradaWeb := (cAliasZBZ)->DTCONV //            AS dateTime  AQUIII ATENCAO, VER a DATA CONVERTIDA

	If oWS:ZBZ990Adciona()
		Alert( oWS:cZBZ990AdcionaResult	)
		lRet := .T.
	Else
		cInfo   := IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
		Alert( cInfo )
	EndIf
	
	(cAliasZBZ)->( dbSkip() )

EndDo

(cAliasZBZ)->( dbCloseArea() )

RestArea( aArea )
Return( lRet )



//==============================================   AKIIIII   ================================================================
USer Function TesteNFA()  //U_TesteNFA()      //TEST NFARRAY
Local cAliasZBE := GetNextAlias()
Local cXmlRet := ""
Local cErro := "", cWarning := ""
Local cQuery := ""
Private xZBZ  	  := GetNewPar("XM_TABXML","ZBZ")      //ECOOOOOOOOOO
Private xZBZ_ 	  := iif(Substr(xZBZ,1,1)=="S", Substr(xZBZ,2,2), Substr(xZBZ,1,3)) + "_"
Private xZBE  	  := GetNewPar("XM_TABEVE","ZBE")      //ECOOOOOOOOOO
Private xZBE_ 	  := iif(Substr(xZBE,1,1)=="S", Substr(xZBE,2,2), Substr(xZBE,1,3)) + "_"
Private oWs, oXmlRet
Private nCloId:= 0


oWS:=WSERP():New() 

//Fazer uma ABA com parâmetros da conta. Informar o toquem, executar o WS e pegar os dados
//ver quais parâmetros criar
oWS:ctoken := "5060-DDD2-1719"
oWS:INIT()

If oWS:DadosDaConta()
	nCloId := oWS:oWSDadosDaContaResult:nID

	Alert(oWS:oWSDadosDaContaResult:cNome)

Else

	Alert( "Errrrrrrrrrrrrrrou Jacaré" )
	Quit

Endif

oWS:ncontaID := nCloId
oWS:ccnpf    := "04866345000183"
oWS:cmodelo  := "55"

If OWS:NFARRAY()

	//Alert(oWS:oWSNfArrayResult:oWSZBZ990)
	oDet := oWS:oWSNfArrayResult:oWSZBZ990
	oDet := IIf(ValType(oDet)=="O",{oDet},oDet)
	//For nI := 1 To Len( oDet )
	//	Alert( oDet[nI]:cZBZ_CHAVE )
	    //WSDATA   cZBZ_CHAVE                AS string OPTIONAL
	//Next nI
Else
	cInfo   := IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
	Alert( cInfo )
EndIF

Return()

//==============================================   AKIIIII   ================================================================
USer Function TesteEVA()  //U_TesteEVA()      //TEST EventosArray
Local cAliasZBZ := GetNextAlias()
Local cXmlRet := ""
Local cErro := "", cWarning := ""
Local cQuery := ""
Private xZBZ  	  := GetNewPar("XM_TABXML","ZBZ")      //ECOOOOOOOOOO
Private xZBZ_ 	  := iif(Substr(xZBZ,1,1)=="S", Substr(xZBZ,2,2), Substr(xZBZ,1,3)) + "_"
Private xZBE  	  := GetNewPar("XM_TABEVE","ZBE")      //ECOOOOOOOOOO
Private xZBE_ 	  := iif(Substr(xZBE,1,1)=="S", Substr(xZBE,2,2), Substr(xZBE,1,3)) + "_"
Private oWs, oXmlRet
Private nCloId:= 0


oWS:=WSERP():New()

//Fazer uma ABA com parâmetros da conta. Informar o toquem, executar o WS e pegar os dados
//ver quais parâmetros criar
oWS:ctoken := "5060-DDD2-1719"
oWS:INIT()

If oWS:DadosDaConta()
	nCloId := oWS:oWSDadosDaContaResult:nID

	Alert(oWS:oWSDadosDaContaResult:cNome)

Else

	Alert( "Errou Jacaré" )
	Quit

Endif

//oWS:ncontaID := nCloId

DbSelectArea( xZBE )

cQuery += " select TOP 10 * "
cQuery += " from "+RetSqlName(xZBZ)+" ZBE "
cQuery += " order by R_E_C_N_O_ "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasZBZ)

DbSelectARea( cAliasZBZ )
(cAliasZBZ)->( dbGoTop() )
//dbskip()
Do While .NOT. (cAliasZBZ)->( Eof() )

	oWS:cchave   := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE")))

	If OWS:EventosArray()
		Alert(oWS:oWSEventosArrayResult:oWSZBE990:cZBE_TPEVE)
		Alert(oWS:oWSEventosArrayResult:oWSZBE990:cZBE_DESC)
	Else
		cInfo   := IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
		Alert( cInfo )
	EndIF
	(cAliasZBZ)->(dbskip())
EndDo

dbCloseArea( cAliasZBZ )

Return()



//Teste do SFTP U_TSTPUT()
User Function TSTPUT()
Local oSFtp
Local nErr

oSFtp := uSFTP():New()
//oSFtp:oParameters

//oSFtp:oParameters:Set(cSource,"/sftp.C14587/SAIDA/")

//oSFtp:cSource  := "/sftp.C14587/SAIDA/"
//oSFtp:cTarget  := "\xmlsource\"
//oSFtp:cURL     := "integracao.embratec.com.br"
//oSFtp:cUSR     := "sftp.C14587"
//oSFtp:cPWD     := "v_-w@D$1k!nncY_"
//oSFtp:cMode    := "G"
//oSFtp:lSrv     := .T.
//oSFtp:cPort    := "22"
//oSFtp:lForceClient := .T.
//oSFtp:nSWMode  := 1

nErr := oSFtp:Execute( "/sftp.C14587/SAIDA/*.*", "\xmlsource\fiscal\", "integracao.embratec.com.br", "sftp.C14587", "v_-w@D$1k!nncY_", "G", .T., "22", .F., 1  )

if nErr <> 0
		aMsgs := {}
        aAdd(aMsgs,{-1,"Impossivel Criar Diretorio"})
        aAdd(aMsgs,{-2,"Recurso de Transferencia SFTP nao Encontrado"})
        aAdd(aMsgs,{-3,"Problema na Execucao do Comando"})
	Alert( nErr )
Else
	Alert( "Foi" )
endif

oSFtp:FreeObj()

Return

Return
