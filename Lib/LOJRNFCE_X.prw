#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWPRINTSETUP.CH"
#INCLUDE "RPTDEF.CH"

//Modalidades de TEF dispon�veis no sistema
#DEFINE TEF_SEMCLIENT_DEDICADO  "2"         // Utiliza TEF Dedicado Troca de Arquivos                      
#DEFINE TEF_COMCLIENT_DEDICADO  "3"			// Utiliza TEF Dedicado com o Client
#DEFINE TEF_DISCADO             "4"			// Utiliza TEF Discado 
#DEFINE TEF_LOTE                "5"			// Utiliza TEF em Lote
#DEFINE TEF_CLISITEF			"6"			// Utiliza a DLL CLISITEF
#DEFINE TEF_CENTROPAG			"7"			// Utiliza a DLL tef mexico


// Possibilidades de uso do parametro MV_AUTOCOM
#DEFINE DLL_SIGALOJA			0			// Usa somente perif�ricos da SIGALOJA.DLL
#DEFINE DLL_SIGALOJA_AUTOCOM	1			// Usa perif�ricos da SIGALOJA.DLL e da AUTOCOM
#DEFINE DLL_AUTOCOM				2			// Usa somente perif�ricos da AUTOCOM

// Retornos da GetRemoteType()
#DEFINE REMOTE_JOB	 			-1			// N�o h� Remote, executando Job
#DEFINE REMOTE_DELPHI			0			// O Remote est� em Windows Delphi
#DEFINE REMOTE_QT				1			// O Remote est� em Windows QT
#DEFINE REMOTE_LINUX			2			// O Remote est� em Linux
#DEFINE REMOTE_HTML				5			// N�o h� Remote, executando HTML

// Tipos de equipamentos
#DEFINE EQUIP_IMPFISCAL			1
#DEFINE EQUIP_PINPAD			2
#DEFINE EQUIP_CMC7				3
#DEFINE EQUIP_GAVETA			4
#DEFINE EQUIP_IMPCUPOM			5
#DEFINE EQUIP_LEITOR			6
#DEFINE EQUIP_BALANCA			7
#DEFINE EQUIP_DISPLAY			8
#DEFINE EQUIP_IMPCHEQUE			9
#DEFINE EQUIP_IMPNAOFISCAL		10			

// Qual DLL o Equipamento esta utilizando
#DEFINE EQUIP_DLL_NENHUM		0			// O equipamento nao foi configurado 
#DEFINE EQUIP_DLL_AUTOCOM		1			// O equipamento foi configurado para utilizar a AUTOCOM
#DEFINE EQUIP_DLL_SIGALOJA		2			// O equipamento foi configurado para utilizar a SIGALOJA

//**************************************************************************************************//
//Tags para impress�o em Impressoras Fiscal e N�o-Fiscal
//
//	NOTAS:
//		- essas tags foram baseadas no modulo Daruma N�o-Fiscal
// 		- ao adicionar uma tag aqui inserir na fun��es da sigaloja, 
//		totvsapi e autocom para tratar as tags por modelo de ECF, 
//		nos fontes dos modelos e no LOJA1305 que trata da remo��o da tag nao utilizada
//**************************************************************************************************//
#DEFINE TAG_ESC			CHR(27)
#DEFINE TAG_NEGRITO_INI	 "<b>"	//Inicia Texto em Negrito
#DEFINE TAG_NEGRITO_FIM	"</b>" //finaliza texto em negrito
#DEFINE TAG_ITALICO_INI	"<i>"	//it�lico
#DEFINE TAG_ITALICO_FIM	"</i>" //it�lico
#DEFINE TAG_CENTER_INI	"<ce>"	//centralizado
#DEFINE TAG_CENTER_FIM	"</ce>"//centralizado
#DEFINE TAG_SUBLI_INI	 "<s>"	//sublinhado
#DEFINE TAG_SUBLI_FIM 	"</s>"	//sublinhado
#DEFINE TAG_EXPAN_INI 	"<e>"	//expandido
#DEFINE TAG_EXPAN_FIM	 "</e>"	//expandido
#DEFINE TAG_CONDEN_INI	"<c>"	//condensado
#DEFINE TAG_CONDEN_FIM	"</c>"	//condensado
#DEFINE TAG_NORMAL_INI	"<n>"	//normal 
#DEFINE TAG_NORMAL_FIM	"</n>"	//normal
#DEFINE TAG_PULALI_INI	"<l>"	//pula 1 linha
#DEFINE TAG_PULALI_FIM	"</l>"	//pula 1 linha
#DEFINE TAG_PULANL_INI	"<sl>"	//pula NN linhas
#DEFINE TAG_PULANL_FIM	"</sl>"//pula NN linha
#DEFINE TAG_RISCALN_INI	"<tc>"	//risca a linha caracter especifico
#DEFINE TAG_RISCALN_FIM	"</tc>"
#DEFINE TAG_TABS_INI		"<tb>"	//tabula��o
#DEFINE TAG_TABS_FIM		"</tb>"
#DEFINE TAG_DIREITA_INI	"<ad>" //alinhado a direita
#DEFINE TAG_DIREITA_FIM	"</ad>"
#DEFINE TAG_ELITE_INI	 "<fe>"	//habilita fonte elite
#DEFINE TAG_ELITE_FIM 	"</fe>"
#DEFINE TAG_TXTEXGG_INI	"<xl>"	//habilita texto extra grande
#DEFINE TAG_TXTEXGG_FIM	"</xl>"
#DEFINE TAG_GUIL_INI		"<gui>"//ativa guilhotina
#DEFINE TAG_GUIL_FIM		"</gui>"
#DEFINE TAG_EAN13_INI 	"<ean13>"	//codigo de barra ean13
#DEFINE TAG_EAN13_FIM	 "</ean13>"
#DEFINE TAG_EAN8_INI		"<ean8>"	//codigo de barra ean8
#DEFINE TAG_EAN8_FIM		"</ean8>"
#DEFINE TAG_UPCA_INI		"<upc-a>" //codigo de barras upc-a
#DEFINE TAG_UPCA_FIM		"</upc-a>"
#DEFINE TAG_CODE39_INI	"<code39>"//codigo de barras CODE39
#DEFINE TAG_CODE39_FIM	"</code39>"
#DEFINE TAG_CODE93_INI	"<code93>" //codigo de barras CODE93
#DEFINE TAG_CODE93_FIM	"</code93>"
#DEFINE TAG_CODABAR_INI	"<codabar>"//codigo de barras CODABAR
#DEFINE TAG_CODABAR_FIM	"</codabar>"
#DEFINE TAG_MSI_INI		"<msi>" //codigo de barras MSI
#DEFINE TAG_MSI_FIM		"</msi>"
#DEFINE TAG_CODE11_INI	"<code11>"//codigo de barras CODE11
#DEFINE TAG_CODE11_FIM	"</code11>"
#DEFINE TAG_PDF_INI		"<pdf>" //codigo de barras PDF
#DEFINE TAG_PDF_FIM		"</pdf>"
#DEFINE TAG_COD128_INI	"<code128>" //codigo de barras CODE128
#DEFINE TAG_COD128_FIM	"</code128>"
#DEFINE TAG_I2OF5_INI	 "<i2of5>" //codigo I2OF5
#DEFINE TAG_I2OF5_FIM 	"</i2of5>"
#DEFINE TAG_S2OF5_INI 	"<s2of5>" //codigo S2OF5
#DEFINE TAG_S2OF5_FIM	 "</s2of5>"
#DEFINE TAG_QRCODE_INI	"<qrcode>"	//codigo do tipo QRCODE
#DEFINE TAG_QRCODE_FIM	"</qrcode>"
#DEFINE TAG_BMP_INI		"<bmp>" //imprimi logotipo carregado
#DEFINE TAG_BMP_FIM		"</bmp>"
#DEFINE TAG_NIVELQRCD_INI "<correcao>" // nivel de corre��o do QRCode
#DEFINE TAG_NIVELQRCD_FIM "</correcao>"


#DEFINE MTAG_NEGRITO_INI	 TAG_ESC+"E"	//Inicia Texto em Negrito
#DEFINE MTAG_NEGRITO_FIM	 TAG_ESC+"F" //finaliza texto em negrito
#DEFINE MTAG_ITALICO_INI	TAG_ESC+"41"	//it�lico
#DEFINE MTAG_ITALICO_FIM TAG_ESC+"40" //it�lico
#DEFINE MTAG_CENTER_INI	TAG_ESC+"j1"	//centralizado
#DEFINE MTAG_CENTER_FIM	TAG_ESC+"j0"//centralizado
#DEFINE MTAG_SUBLI_INI	TAG_ESC+"-1"	//sublinhado
#DEFINE MTAG_SUBLI_FIM 	TAG_ESC+"-0"	//sublinhado
#DEFINE MTAG_EXPAN_INI 	TAG_ESC+"W1"	//expandido
#DEFINE MTAG_EXPAN_FIM	TAG_ESC+"W0"	//expandido
#DEFINE MTAG_CONDEN_INI	CHR(15)	//condensado
#DEFINE MTAG_CONDEN_FIM	CHR(18)	//condensado
#DEFINE MTAG_NORMAL_INI	CHR(20)	//normal 
#DEFINE MTAG_NORMAL_FIM	""	//normal
#DEFINE MTAG_PULALI_INI	CHR(10)	//pula 1 linha
#DEFINE MTAG_PULALI_FIM	""	//pula 1 linha
#DEFINE MTAG_PULANL_INI	TAG_ESC+"f1"	//pula NN linhas
#DEFINE MTAG_PULANL_FIM	""//pula NN linha
#DEFINE MTAG_RISCALN_INI	""	//risca a linha caracter especifico
#DEFINE MTAG_RISCALN_FIM	""
#DEFINE MTAG_TABS_INI		TAG_ESC+"B"	//tabula��o
#DEFINE MTAG_TABS_FIM		TAG_ESC+"B"
#DEFINE MTAG_DIREITA_INI	TAG_ESC+"j2" //alinhado a direita
#DEFINE MTAG_DIREITA_FIM	TAG_ESC+"j0"
#DEFINE MTAG_ELITE_INI	 TAG_ESC+"!01"	//habilita fonte elite
#DEFINE MTAG_ELITE_FIM 	TAG_ESC+"!00"	
#DEFINE MTAG_TXTEXGG_INI	TAG_ESC+"!41"		//habilita texto extra grande
#DEFINE MTAG_TXTEXGG_FIM	TAG_ESC+"!40"	
#DEFINE MTAG_EAN13_INI 	TAG_ESC+"b1"	//codigo de barra ean13
#DEFINE MTAG_EAN13_FIM	 ""
#DEFINE MTAG_EAN8_INI	TAG_ESC+"b2"	//codigo de barra ean8
#DEFINE MTAG_EAN8_FIM		""
#DEFINE MTAG_UPCA_INI		TAG_ESC+"b8" //codigo de barras upc-a
#DEFINE MTAG_UPCA_FIM		""
#DEFINE MTAG_CODE39_INI	TAG_ESC+"b6"//codigo de barras CODE39
#DEFINE MTAG_CODE39_FIM	""
#DEFINE MTAG_CODE93_INI	TAG_ESC+"b7" //codigo de barras CODE93
#DEFINE MTAG_CODE93_FIM	""
#DEFINE MTAG_CODABAR_INI	TAG_ESC+"b9"//codigo de barras CODABAR
#DEFINE MTAG_CODABAR_FIM	""
#DEFINE MTAG_MSI_INI		TAG_ESC+"b10" //codigo de barras MSI
#DEFINE MTAG_MSI_FIM		""
#DEFINE MTAG_CODE11_INI	TAG_ESC+"b11" //codigo de barras CODE11
#DEFINE MTAG_CODE11_FIM	""
#DEFINE MTAG_PDF_INI		TAG_ESC+CHR(128) //codigo de barras PDF
#DEFINE MTAG_PDF_FIM		""
#DEFINE MTAG_COD128_INI	TAG_ESC+"b5" //codigo de barras CODE128
#DEFINE MTAG_COD128_FIM	""
#DEFINE MTAG_I2OF5_INI	 TAG_ESC+"b4" //codigo I2OF5
#DEFINE MTAG_I2OF5_FIM 	""
#DEFINE MTAG_S2OF5_INI 	TAG_ESC+"b3" //codigo S2OF5
#DEFINE MTAG_S2OF5_FIM	 ""
#DEFINE MTAG_QRCODE_INI	TAG_ESC+Chr(129)	//codigo do tipo QRCODE
#DEFINE MTAG_QRCODE_FIM	""
#DEFINE MTAG_BMP_INI		CHR(22)+"8"//imprimi logotipo carregado
#DEFINE MTAG_BMP_FIM		CHR(22)+"9"
#DEFINE MTAG_NIVELQRCD_INI "" // nivel de corre��o do QRCode
#DEFINE MTAG_NIVELQRCD_FIM ""
#DEFINE MTAG_GUIL_INI	TAG_ESC+"m"//ativa guilhotina
#DEFINE MTAG_GUIL_FIM	""

//Tags disponibilizadas apenas para a bematech
#DEFINE TAG_ITF	 "<itf>"
#DEFINE TAG_ISBN	"<isbn>"
#DEFINE TAG_PLESSEY	 "<plessey>"

//Apenas para DARUMA - o valor dessa tag pode ser 3, 4, 5, 6 ou 7 
#DEFINE TAG_LMODULO_INI "<lmodulo>"
#DEFINE TAG_LMODULO_FIM "</lmodulo>"

//Informa��es de NFCe
#DEFINE _NFCE_AVISO_CONTINGENCIA 	"01" 
#DEFINE _NFCE_ENCONTRAR_IMPRESSORA 	"02" 
#DEFINE _NFCE_TIMEOUT_SERVICO 		"03"
#DEFINE _NFE_MARCA_IMPRESSORA 		"04" 
#DEFINE _NFCE_TIPO_AMBIENTE 		"05"
#DEFINE _NFCE_CODIGO_PARCEIRO 		"06" 
#DEFINE _NFCE_CODIGO_PDV 		"07" 
#DEFINE _NFCE_CODIGO_EMPRESA 		"08"
#DEFINE _NFCE_TOKEN_SEFAZ 		"09" 
#DEFINE _NFCE_AJUSTAR_PAGTO_TOTAL 	"10" 
#DEFINE _NFCE_NUMERACAO_AUTOMATICA 	"11" 
#DEFINE _NFCE_HABILITA_LEI_IMPOSTO 	"12" 
#DEFINE _NFCE_MENSAGEM_COMPLEMENTAR 	"13"
#DEFINE _NFCE_EMIENTE_CNPJ_CPF	 	"14" 
#DEFINE _NFCE_EMITENTE_NOME 		"15" 
#DEFINE _NFCE_EMITENTE_IE 		"16"
#DEFINE _NFCE_EMITENTE_IM 		"17" 
#DEFINE _NFCE_EMITENTE_CRT 		"18"
#DEFINE _NFCE_EMITENTE_CUF 		"19"  
#DEFINE _NFCE_EMTIENTE_CNUMFG 		"20" 
#DEFINE _NFCE_EMITENTE_ENDERECO_LOGR 	"21" 
#DEFINE _NFCE_EMITENTE_ENDERECO_NUMERO 	"22"
#DEFINE _NFCE_EMITENTE_ENDERECO_BAIRRO 	"23" 
#DEFINE _NFCE_EMITENTE_ENDERECO_CNUM	"24" 
#DEFINE _NFCE_EMITENTE_ENDERECO_XNUM 	"25" 
#DEFINE _NFCE_EMITENTE_ENDERECO_UF 	"26" 
#DEFINE _NFCE_EMITENTE_ENDERECO_CEP 	"27" 
#DEFINE _NFCE_CANC_INUTILIZA_AUTOMATICO	"28"
//
//User Function LOJRNFCe(	oNFCe		, oProt		, nDecimais	, aFormas	,;
//						cProtAuto	, lContigen	, cDtHoraAut, aEmitNfce	,; 
//						aDestNfce	, aIdNfce	, aPagNfce	, aItemNfce	,; 
//						aTotal		, cChvNFCe	)
//User Function DANFCe_X(lAuto,oNota,cIdEnt,,,oDanfe,oSetup,cFilePrint)
User Function DANFCe_X(lAuto,oNota,cIdEnt,cVal1,cVal2,oDanfe,oSetup,cFilePrint,lAutoDanfe,cDirDanfe)
	Local lPrinter 	:= .F.			
	Local cXml		:= ""
	Local cXmlProt	:= ""
	Local cPath 			:= "\spool\"		
	Local cSession			:= GetPrinterSession()	
	Local cStartPath		:= GetSrvProfString("StartPath","")	
	Local lAdjustToLegacy	:= .T.
    //Daqui pela chamada do padron, estava tudo no Default
	Local nDecimais 	:= 0
	Local aFormas 		:= {}
	Local cProtAuto		:= ""
	Local lContigen		:= .F.  //.T.
	Local cDtHoraAut	:= ""
	Local cChvNFCe		:= ""

	if oNota == NIL
		cError := ""
		cWarning := ""
		oNota := XmlParser((xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML"))), "_", @cError, @cWarning )
		if oNota == NIL
			cXml  := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML")))
			cError := ""
			cWarning := ""
			oNota := U_PARSGDE( cXml, @cError, @cWarning )
		endif
	Endif
	
	if oNota == NIL
		Aviso("DANFE","N�o foi possivel ler o XML, refa�a a importa��o",{"OK"},3)
		Return( .T. )
	endif

	Private cBmp 			:= cStartPath + "NfceLogo.bmp" 	//Logo
	Private oPrint			:= oDanfe
	Private oNF             := oNota
	Private oNFCe			:= NIL 
	Private oProt			:= NIL
	Private aEmitNfce 		:= {}
	Private aDestNfce 		:= {}
	Private aIdNfce 		:= {}
	Private aPagNfce 		:= {}
	Private aItemNfce 		:= {}
	Private aTotal 			:= {}

	If !File(cBmp)
		cBmp := GetSrvProfString("Startpath","") + "NfceLogo" + cEmpAnt + cFilAnt + ".BMP"
		If !File(cBmp)
			cBmp	:= GetSrvProfString("Startpath","") + "NfceLogo" + cEmpAnt + ".BMP"
			If !File(cBmp)
				cBmp := GetSrvProfString("Startpath","") + "DANFE" + cEmpAnt + cFilAnt + ".BMP"
			EndIf
		EndIf
	EndIf


	if TYpe( "oNF:_NFEPROC") <> "U"
		oNFCe := oNF:_NFEPROC
	Endif
	if TYpe( "oNF:_NFEPROC:_PROTNFE") <> "U"
		oProt := oNF:_NFEPROC //:_PROTNFE
	endif
	if TYpe( "oProt:_PROTNFE:_INFPROT:_NPROT:TEXT") <> "U"
		cProtAuto := AllTrim(oProt:_PROTNFE:_INFPROT:_NPROT:TEXT)
	endIf
	if TYpe( "oNFCe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT") <> "U"
		lContigen := oNFCe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT <> "1"
	EndIf
	if TYpe( "oProt:_PROTNFE:_INFPROT:_DHRECBTO:TEXT") <> "U"
		cDtHoraAut := oProt:_PROTNFE:_INFPROT:_DHRECBTO:TEXT
	EndIf
	if TYpe( "oNfce:_NFE:_INFNFE:_EMIT") <> "U"
		aEmitNfce := oNfce:_NFE:_INFNFE:_EMIT 		//Emitente
	EndIF
	if TYpe( "oNfce:_NFE:_INFNFE:_DEST") <> "U"
		aDestNfce := oNfce:_NFE:_INFNFE:_DEST 		//Destinat�rio
	EndIF
	if TYpe( "oNfce:_NFE:_INFNFE:_IDE") <> "U"
		aIdNfce	:= oNfce:_NFE:_INFNFE:_IDE			//Detalhe da NFC-e
	EndIf
	If Type("oNfce:_NFE:_INFNFE:_PAG[1]") == "O"
		aPagNfce := oNfce:_NFE:_INFNFE:_PAG
	ElseIf Type("oNfce:_NFE:_INFNFE:_PAG") == "O"
		aAdd(aPagNfce, oNfce:_NFE:_INFNFE:_PAG)
	EndIf
	If Type("oNfce:_NFE:_INFNFE:_DET[1]") == "O"
		aItemNfce := oNfce:_NFE:_INFNFE:_DET
	ElseIf Type("oNfce:_NFE:_INFNFE:_DET") == "O"
		aAdd( aItemNfce, oNfce:_NFE:_INFNFE:_DET )
	EndIf
	if TYpe( "oNfce:_NFE:_INFNFE:_TOTAL") <> "U"
		aTotal := oNfce:_NFE:_INFNFE:_TOTAL  //Total da NF
	EndIf
	if TYpe( "oProt:_PROTNFE:_INFPROT:_CHNFE:TEXT") <> "U"
		cChvNFCe := oProt:_PROTNFE:_INFPROT:_CHNFE:TEXT
	Else
		cChvNFCe := StrTran(oNFCe:_NFE:_INFNFE:_ID:TEXT, "NFe")	//Chave da NFC-e
	EndIf

	//oPrint := FWMsPrinter():New("Impress�o NFC-e", IMP_PDF, lAdjustToLegacy,cPath)
	
	If ValType(oNFCe) == "O"	
		oPrint:SetPortrait()
		oPrint:SetPaperSize(DMPAPER_A4)
		If lAutoDanfe <> Nil   
			If lAutoDanfe
				oPrint:CPATHPDF := cDirDanfe
			Endif 
		Endif 
		
		LJMsgRun("Iprimindo NFC-e",,{|| U_HFImpNFCE(oNFCe, oProt, nDecimais, aFormas, cProtAuto, lContigen, cDtHoraAut, ;
						aEmitNfce, aDestNfce, aIdNfce, aPagNfce, aItemNfce, aTotal, cChvNFCe,lAutoDanfe,cDirDanfe)})
		
		oPrint:Preview()
	Else
		MsgInfo("N�o h� dados para serem impressos!")	
	EndIf
	
Return Nil
//LjrImpNFCE
User Function HFImpNFCE(	oNFCe1		, oProt1	, nDecimais	, aFormas	,; 
							cProtAuto	, lContigen	, cDtHoraAut, aEmitNfce1	,; 
							aDestNfce1	, aIdNfce1	, aPagNfce1	, aItemNfce1	,;
							aTotal1		, cChvNFCe  , lAutoDanfe, cDirDanfe	)
	
	Local aItNfceAux	:= {}//Itens	
	Local nContItImp	:= 0
	Local nItemQtde		:= 0
	Local nItemUnit 	:= 0
	Local nItemTotal	:= 0
	Local nTotDesc 		:= 0
	Local nTotAcresc	:= 0 		
	Local nFtQrCode		:= 0.38 //Fator Conersao tamanho QrCode, referente a posi��o da linha 1
	Local nValFtr		:= 0 	//Valor Fatorado
	Local cTextoAux		:= ""
	Local nVlrTotal		:= 0
	Local aDtHrLocal	:= {}

	Local nX			:= 0 
	Local nY			:= 0 
	Local nAuxLn		:= 0
	
	Local nAlgL			:= 0
	Local nAlgR			:= 1
	Local nAlgC			:= 2
	
	Local cKeyQrCode	:= ""
	Local cAmbiente		:= ""
	Local cURLNFCE		:= ""	
	Local nDecVRUNIT	:= TamSX3("L2_VRUNIT")[2]	//quantidade de casas decimais a serem impressas no campo VlUnit do DANFE	
	Local nTotImpNCM	:= 0
	Local nTotVLRNCM	:= 0	
	Local nTamPgV		:= oPrint:nVertRes()//-170//Comprimento vertical da impressao
	Local oFont, oFont1, oFont2, oFont3, oFont4, oFont5

	oFont  := TFont():New("Courier New",,14,,.T. /*NEGRITO*/,,,,.T.,)	//85 caracteres por linha
	oFont1 := TFont():New("Courier New",,13,,.T. /*NEGRITO*/,,,,.T.,)	//99 caracteres por linha
	oFont2 := TFont():New("Courier New",,11,,.T. /*NEGRITO*/,,,,,)
	oFont3 := TFont():New("Courier New",,12,,.T. /*NEGRITO*/,,,,.T.,)
	oFont4 := TFont():New("Courier New",,18,,.T. /*NEGRITO*/,,,,.T.,)	//66 caracteres por linha
	oFont5 := TFont():New("Courier New",,15,,.T. /*NEGRITO*/,,,,.T.,)
	
	//obtem o Ambiente o qual foi emitido a NFC-e
	cAmbiente := oNFCe:_NFE:_INFNFE:_IDE:_TPAMB:TEXT 
	
	// Inicia a impressao da pagina
	oPrint:StartPage()

	/*
		Divisao I
	*/
	oPrint:SetFont(oFont)	//Times New Roman - 14 - Negrito (linha cheia 85 caracteres)
	nAuxLn := 80
	
	oPrint:SayBitmap( 0025, 0050, cBmp, 200, 200)														// Logotipo

	cTextoAux := AllTrim( "CNPJ: " + Transform(aEmitNfce:_CNPJ:TEXT, "@R 99.999.999/9999-99") ) + " "	//CNPJ
	cTextoAux += AllTrim(aEmitNfce:_XNOME:TEXT)															//Razao Social
	oPrint:Say( nAuxLn, 1, PadC(cTextoAux,85) )
	nAuxLn += 40

	cTextoAux := AllTrim(aEmitNfce:_ENDEREMIT:_XLGR:TEXT) + ", " 
	cTextoAux += AllTrim(aEmitNfce:_ENDEREMIT:_NRO:TEXT) + ", "
	cTextoAux += AllTrim(aEmitNfce:_ENDEREMIT:_XBAIRRO:TEXT) + ", " 
	cTextoAux += AllTrim(aEmitNfce:_ENDEREMIT:_XMUN:TEXT) + " - "
	cTextoAux += AllTrim(aEmitNfce:_ENDEREMIT:_UF:TEXT)
	oPrint:Say( nAuxLn, 1, PadC(cTextoAux,85) )
	nAuxLn += 40

	oPrint:Say( nAuxLn, 1, Replicate("-",85) )
	nAuxLn += 40

	oPrint:Say( nAuxLn, 1, PadC("DOCUMENTO AUXILIAR DA NOTA FISCAL DE CONSUMIDOR ELETR�NICA", 85) )
	
	/* todo aumentar a fonte*/ 
	If lContigen
		nAuxLn += 60
		oPrint:Say( nAuxLn,1, PadC("EMITIDA EM CONTING�NCIA", 66), oFont4 )
		nAuxLn += 40
		oPrint:Say( nAuxLn,1, PadC("Pendente de autoriza��o", 85), oFont )
	EndIf

	nAuxLn += 60	//quebra de linha entre as divisoes

	/*
		Divis�o II � Informa��es de Detalhe da Venda
		* a impressao dessa divis�o � opcional ou conforme definido por UF
	*/
	oPrint:Say( nAuxLn,0080, "Codigo           Descricao                  Qtd    UN      VlUnit.     VlTotal", oFont )

	For nX := 1 to Len(aItemNfce)

		nContItImp++ //Contador de itens a serem impressos

		nItemQtde	:= Val(aItemNfce[nX]:_PROD:_QCOM:TEXT)
		nItemUnit 	:= Val(aItemNfce[nX]:_PROD:_VUNCOM:TEXT)
		nItemTotal	:= Val(aItemNfce[nX]:_PROD:_VPROD:TEXT)

		nAuxLn += 40
		
		oPrint:Say( nAuxLn,0080,PADR(aItemNfce[nX]:_PROD:_CPROD:TEXT,15) + " "  ,oFont2 )	//Codigo de Produto
			
		//Se a Descricao for maior que 12 caracteres, imprimimos a descricao em uma linha soh e os outros 
		// campos na linha seguinte, caso contrario, todas as informacoes sao impressas em uma linha unica		
		If Len(aItemNfce[nX]:_PROD:_XPROD:TEXT) > 12			
			oPrint:Say( nAuxLn,0150,PADR(aItemNfce[nX]:_PROD:_XPROD:TEXT,44)	+ " "  ,oFont2 )					//Descricao de Produto
		Else
			oPrint:Say( nAuxLn,0150,PADR(aItemNfce[nX]:_PROD:_XPROD:TEXT,12)	+ " "  ,oFont2 )					//Descricao de Produto
		EndIf
		oPrint:Say( nAuxLn,360,PADL(AllTrim(Str(nItemQtde)),6) 								+ " "	,oFont2 )	//Qtde
		oPrint:Say( nAuxLn,415,PADR(aItemNfce[nX]:_PROD:_UCOM:TEXT,2)							+ " "   ,oFont2 )	//Unidade de Medida
		oPrint:Say( nAuxLn,470,PadL(AllTrim(Transform(nItemUnit , '@E 999,999,999,999.99')),8) + " "  	,oFont2 )	//Valor Unit.
		oPrint:Say( nAuxLn,545,PadL(AllTrim(Transform(nItemTotal, '@E 999,999,999,999.99')),9)			,oFont2 )	//Valor Total

		If nAuxLn > nTamPgV
			nAuxLn := 20
			oPrint:EndPage()
			oPrint:StartPage()
		EndIf
	Next nX
	
	nAuxLn += 60	//quebra de linha entre as divisoes	
	
	/*
		Divis�o III � Informa��es de Total do DANFE NFC-e
	*/
	oPrint:SetFont(oFont2) //Times New Roman - 13 - Negrito

	oPrint:Say( nAuxLn,0080,"QTD. TOTAL DE ITENS")	
	oPrint:Say( nAuxLn,360,PADR( AllTrim( Str(Len(aItemNfce)) ),38 ) )
	
	nAuxLn += 40
	//se existir ISSQN, o VALOR TOTAL � igual a soma da tag vProd + vServ
	If LjRTemNode(aTotal,"_ISSQNTOT")
		nVlrTotal := Val(aTotal:_ICMSTOT:_VPROD:TEXT) + Val(aTotal:_ISSQNTot:_VSERV:TEXT)
	Else
		nVlrTotal := Val(aTotal:_ICMSTOT:_VPROD:TEXT)
	EndIf
	oPrint:Say( nAuxLn,0080,"VALOR TOTAL R$")
	oPrint:Say( nAuxLn,360,PADR(AllTrim(Transform(nVlrTotal, '@E 999,999,999,999.99')),43))
        
    // Verifica se possui DESCONTO ou ACRESCIMO (vOutro)
    nTotDesc   := Val(aTotal:_ICMSTOT:_VDESC:TEXT )
    nTotAcresc := Val(aTotal:_ICMSTOT:_VOUTRO:TEXT)
    
	If (nTotDesc - nTotAcresc) <> 0
		nAuxLn += 40
		If nTotDesc > nTotAcresc
			cTextoAux := "DESCONTOS R$"
		Else
			cTextoAux := "ACRESCIMOS R$"
		EndIf
		oPrint:Say( nAuxLn,0080, cTextoAux)
		oPrint:Say( nAuxLn,360,PADR(AllTrim(Transform( Abs(nTotDesc-nTotAcresc), '@E 999,999,999,999,999.99')),39) )
		
		nAuxLn += 40
		oPrint:Say( nAuxLn,0080,"VALOR A PAGAR R$")
		oPrint:Say( nAuxLn,360,PADR( AllTrim(Transform(Val(aTotal:_ICMSTOT:_VNF:TEXT), '@E 999,999,999,999,999.99')),43) )	
	EndIf
	
	oPrint:SetFont(oFont2)

	nAuxLn += 40
	oPrint:Say( nAuxLn,0080,"FORMA PAGAMENTO")
	oPrint:Say( nAuxLn,0360,"VALOR PAGO R$")
	
	For nX := 1 to Len(aPagNFCe)
		nAuxLn += 40		
		If (nY := aScan(aFormas,{|x| Alltrim(x[2]) == Alltrim(aPagNfce[nX]:_TPAG:TEXT) })) > 0
		
			oPrint:Say( nAuxLn,0080,aFormas[nY][1])
			oPrint:Say( nAuxLn,0360, PadR( AllTrim( Transform(Val(aPagNfce[nX]:_VPAG:TEXT), '@E 999,999,999,999,999.99')), 40) )
			
		Else
			oPrint:Say( nAuxLn,0080,"Outros" )
			//oPrint:Say( nAuxLn,0360,PadR( AllTrim( Transform(Val(aPagNfce[nX]:_VPAG:TEXT), '@E 999,999,999,999,999.99')), 40) )
			if Type("aPagNfce["+cValtoChar(nX)+"]:_DETPAG:_VPAG:TEXT") <> "U"
				oPrint:Say( nAuxLn,0360,PadR( AllTrim( Transform(Val(aPagNfce[nX]:_DETPAG:_VPAG:TEXT), '@E 999,999,999,999,999.99')), 40) )  //FR - 31/03/2022 - PROJETO KITCHENS
			endif
		EndIf

		If nAuxLn > nTamPgV
			nAuxLn := 20
			oPrint:EndPage()
			oPrint:StartPage()
		EndIf
		
	Next nX
	
	nAuxLn += 60	//quebra de linha entre as divisoes

	/*
		DIVISAO IV � Informa��es da consulta via chave de acesso		
	*/
	oPrint:Say( nAuxLn, 1, PadC("Consulte pela chave de acesso em: ", 85), oFont )
	nAuxLn += 40
	
	//Link de consulta publica
	cURLNFCE := LjNFCeURL(cAmbiente,.T.)
	oPrint:Say( nAuxLn, 1, PadC(cURLNFCE,85), oFont )	  	
	nAuxLn += 40

	//1111 2222 3333 4444 5555 6666 7777 8888 9999 0000 1111	
	cTextoAux := ""
	For nX := 1 to 44 Step 4
		cTextoAux += SubStr(cChvNFCe, nX , 4) + " "
	Next	
	oPrint:Say( nAuxLn, 1, PadC(cTextoAux,85), oFont )
	
	nAuxLn += 60 	//quebra de linha entre as divisoes
	
	/*
		DIVISAO VI � Informa��es sobre o Consumidor
	*/	
	If Empty(aDestNfce)
		cTextoAux := "CONSUMIDOR N�O IDENTIFICADO"
		oPrint:Say( nAuxLn, 1, PadC(cTextoAux, 85), oFont )
	Else
		If LjRTemNode(aDestNfce,"_CPF")
			cTextoAux := "CONSUMIDOR - CPF: " + Transform(aDestNfce:_CPF:TEXT, "@R 999.999.999-99")				
		ElseIf LjRTemNode(aDestNfce,"_CNPJ")				
			cTextoAux := "CONSUMIDOR - CNPJ: " + Transform(aDestNfce:_CNPJ:TEXT, "@R 99.999.999/9999-99")
		ElseIf LjRTemNode(aDestNfce,"_IDESTRANGEIRO")
			cTextoAux := "CONSUMIDOR Id. Estrangeiro: " + aDestNfce:_IDESTRANGEIRO:TEXT
		EndIf

		/*
		OPCIONALMENTE poder� ser inclu�da nesta divis�o tamb�m o nome do consumidor e/ou seu endere�o.
		No caso de emiss�o de NFC-e com entrega em domic�lio � OBRIGAT�RIA a impress�o do nome do consumidor e do endere�o de entrega.
		*/
		If LjRTemNode(aDestNfce,"_XNOME")
			cTextoAux += " " + AllTrim(aDestNfce:_XNOME:TEXT) + ' '
		EndIf		
		oPrint:Say( nAuxLn, 1, PadC(cTextoAux, 85), oFont )
		
		//Verifica se possui endere�o
		If LjRTemNode(aDestNfce,"_ENDERDEST")
			nAuxLn += 40
			cTextoAux := aDestNfce:_ENDERDEST:_XLGR:TEXT + ', ' 
			cTextoAux += aDestNfce:_ENDERDEST:_NRO:TEXT + ', '
			cTextoAux += aDestNfce:_ENDERDEST:_XBAIRRO:TEXT + ', ' 
			cTextoAux += aDestNfce:_ENDERDEST:_XMUN:TEXT + '-'
			cTextoAux += aDestNfce:_ENDERDEST:_UF:TEXT
			
			oPrint:Say( nAuxLn, 1, PadC(cTextoAux, 85), oFont )
		EndIf		
	EndIf	

	nAuxLn += 60	//quebra de linha entre as divisoes
	
	/*
		DIVISAO VII � Informa��es de Identifica��o da NFC-e e do Protocolo de Autoriza��o
		N�mero S�rie Emiss�o DD/MM/AAAA hh:mm:ss
	*/
	aDtHrLocal := LjUTCtoLoc(aIdNfce:_DHEMI:TEXT)
	
	cTextoAux := "NFC-e n�" + aIdNfce:_NNF:TEXT + " "
	cTextoAux += "S�rie " + aIdNfce:_SERIE:TEXT + " "
	cTextoAux += PadL( Day(aDtHrLocal[1]),2,"0" ) + "/" 		//DD
	cTextoAux += PadL( Month(aDtHrLocal[1]),2,"0" ) + "/"		//MM
	cTextoAux += cValToChar( Year(aDtHrLocal[1]) ) + " "		//AAAA
	cTextoAux += aDtHrLocal[2]									//hh:mm:ssa

	oPrint:Say( nAuxLn, 1, PadC(cTextoAux,85), oFont )
	nAuxLn += 40

	If !lContigen

		aDtHrLocal := LjUTCtoLoc(cDtHoraAut)
		/* Protocolo de Autoriza��o  DD/MM/AAAA hh:mm:ss */
		cTextoAux := "Protocolo de Autoriza��o: " + cProtAuto + " "
		oPrint:Say( nAuxLn, 1, PadC(cTextoAux,85), oFont )
		nAuxLn += 40

		cTextoAux := "Data de Autoriza��o: "
		cTextoAux += PadL( Day(aDtHrLocal[1]),2,"0" ) + "/"			//DD
		cTextoAux += PadL( Month(aDtHrLocal[1]),2,"0" ) + "/"		//MM
		cTextoAux += cValToChar( Year(aDtHrLocal[1]) ) + " "		//AAAA
		cTextoAux += aDtHrLocal[2]									//hh:mm:ss
		oPrint:Say( nAuxLn, 1, PadC(cTextoAux,85), oFont )
	EndIf
	
	If nAuxLn > nTamPgV 
		nAuxLn := 20
		oPrint:EndPage()
		oPrint:StartPage()
	Else
		nAuxLn += 60	//quebra de linha entre as divisoes
	EndIf

	/*
		Divis�o VIII � �rea de Mensagem Fiscal
	*/	
	If Type("oNfce:_NFE:_INFNFE:_INFADIC") == "O" .AND. LjRTemNode(oNfce:_NFE:_INFNFE:_INFADIC, "_INFADFISCO")

		aInfCpl := StrToKArr(oNfce:_NFE:_INFNFE:_INFADIC:_INFADFISCO:TEXT, "|")
		nInfCpl := Len( aInfCpl )	//quantidade de quebra de linhas
		For nY := 1 to nInfCpl
			//se for a primeira linha, ja houve a quebra de linha da divisao
			If nY <> 1			
				nAuxLn += 40
			EndIf
			oPrint:Say( nAuxLn, 0080, aInfCpl[nY], oFont1 )
		Next
		nAuxLn += 60
	EndIf

	//Se Ambiente for Homologacao		
	If cAmbiente == "2"		
		oPrint:Say( nAuxLn, 1, PadC("EMITIDA EM AMBIENTE DE HOMOLOGA��O � SEM VALOR FISCAL",85), oFont )
		nAuxLn += 60
	EndIf

	If lContigen
		oPrint:Say( nAuxLn, 1, PadC("EMITIDA EM CONTING�NCIA",66), oFont4 )
		nAuxLn += 40
		oPrint:Say( nAuxLn, 1, PadC("Pendente de autoriza��o",85), oFont )
		nAuxLn += 60
	EndIf

	/*
		DIVISAO V � Informa��es da Consulta via QR Code
		A imagem do QR Code poder� ser CENTRALIZADA (conforme o rdmake) ou
		impressa � esquerda das informa��es exigidas nas Divis�es VI e VII
	*/
	// obtem o QR-Code
	cKeyQRCode := U_HFLjQrCo(oNFCe, cAmbiente)		
	
	/* Tratamento feito para controlar posi��o da impressao do QRCODE, pois o metodo
	do mesmo, nao esta respeitando a posi��o de impressao quando a Quebra de Pagina */
	If nAuxLn > nTamPgV-1000
		oPrint:EndPage()
		oPrint:StartPage()
		nAuxLn := 80
	EndIf  
	
	nAuxLn += 775
	
	//Impress�o do QrCode
	oPrint:QRCode( nAuxLn, 750, cKeyQRCode,5)

	/*		
		DIVISAO IX � Mensagem de Interesse do Contribuinte
	*/
	If Type("oNfce:_NFE:_INFNFE:_INFADIC") == "O" .AND. LjRTemNode(oNfce:_NFE:_INFNFE:_INFADIC, "_INFCPL")

		//para que haja a quebra de linha durante a impressao, separamos cada linha por |		
		aInfCpl := StrToKArr(oNfce:_NFE:_INFNFE:_INFADIC:_INFCPL:TEXT, "|")
		nInfCpl := Len( aInfCpl )	//quantidade de quebra de linhas			
		For nY := 1 to nInfCpl
			nAuxLn += 40
			oPrint:Say( nAuxLn, 1, PadC(aInfCpl[nY],99), oFont1 )

			If nAuxLn > nTamPgV
				nAuxLn := 20
				oPrint:EndPage()
				oPrint:StartPage()
			EndIf
		Next
	EndIf

	////////////////////
	//Fim da Impress�o/
	oPrint:EndPage()
	/////////////////

	LJGrvLog(Nil, "Fim da funcao LJRIMPNFCE")
Return

//--------------------------------------------------------
/*{Protheus.doc} LjRDnfNfce
Imprime Danfe(Vulgo: Danfinha)

@author  Varejo
@version P11.8
@since   27/01/2016
@return	 lRet - imprimiu 
*/
//--------------------------------------------------------
User Function HF_LjRDnfNFCe(cXML, cXMLProt, cChvNFCe, lDANFEPad)

Local nX			:= 0 
Local nY			:= 0 
Local aFormas		:= {}
Local aRet			:= {}
Local lRet			:= .T. //Retorna se conseguiu transmitir a Nota, n�o deve retornar erro caso ocorra problema de impressao
Local lImpComum		:= SuperGetMV("MV_LJSTPRT",,1) == 2
Local cTexto		:= ""  
Local cCrLf			:= Chr(10)
Local cImpressora	:= ""
Local cPorta		:= ""
Local cTextoAux 	:= ""
Local cFormaPgto	:= ""
Local cVlrFormPg	:= ""
Local lContigen 	:= .T. 								//Sinaliza emissao em modo de contingencia
Local cProtAuto		:= ""								//Chave de Autorizacao
Local cAmbiente		:= ""
Local cDtHoraAut	:= ""
Local nTotDesc		:= 0 
Local nTotAcresc	:= 0								//somatoria do acrescimo da venda (frete)
Local nVlrTotal		:= 0
Local aDtHrLocal	:= {}
Local aEmitNfce		:= {}								//dados do emitente
Local aIdNfce		:= {}								//dados de Identificacao da Nfc-e
Local aPagNfce		:= {}								//dados dos pagtos  
Local aTotal		:= {}								//Totais(NF,Desconto,ICMS...)
Local nSaltoLn		:= SuperGetMV("MV_FTTEFLI",, 1)		// Linha pula entre comprovante
Local lGuil			:= SuperGetMV("MV_FTTEFGU",, .T.)	// Ativa guilhotina
Local lLj7084		:= .T.								// retorno do PE LJ7084
Local nContItImp	:= 0								//Contador de itens a serem impressos
Local aInfCpl		:= {}								//vetor com as mensagens que possuem quebra de linha
Local nInfCpl		:= 0								//quantidade de quebra de linhas
Local nMVNFCEDES	:= SuperGetMV("MV_NFCEDES",, 0)		// Exibe ou n�o desconto por item na DANFE NFC-e
Local nRetImp 		:= -1
Local cL2ItemPic	:= ""	
Local nConteudo		:= 0
Local cConteudo		:= ""
Local lPOS 			:= FindFunction("STFIsPOS") .AND. STFIsPOS()
Local cModelo		:= AllTrim( IIF(lPOS, STFGetStation("IMPFISC"), LJGetStation("IMPFISC")) )
Local lCondensa		:= SuperGetMV("MV_LJCONDE",,.F.) .OR. IIf("EPSON" $ cModelo, .T., .F.)
Local cTagCondIni	:= Iif(lCondensa, TAG_CONDEN_INI , "")
Local cTagCondFim	:= IIf(lCondensa, TAG_CONDEN_FIM , "")

//variaveis de controle para impressao da coluna Descricao na DIVISAO III
Local cLinha		:= ""	//conteudo da linha que sera impressa na Divis�o III
Local nColunas		:= 48	//quantidade de caracteres de uma linha inteira
Local nIniDesc		:= 1	//indica a posi��o inicial da leitura da tag xProd (descri��o do produto)
Local nFimDesc		:= 0
Local nCodDesc		:= 0	//soma das colunas Codigo + " " + Descricao
Local lImpDesc		:= .T.	//variavel de controle que verifica se havera mais linhas para impressao da Descri��o
Local aColDiv2		:= {}	//largura das colunas da Divisao II

//Parametros enviados pela fun��o no fonte LOJNFCE
Default cXml 		:= ""
Default cXmlProt	:= ""
Default cChvNFCe	:= ""
Default lDanfePad	:= .F.

Private oNFCe				//retorno do XML da NFCe funcao convertido para objeto
Private oProt				//retorno do XML do protocolo de autorizacao convertido para objeto
Private aDestNFCe	:= {}	//dados do destinat�rio
Private aItemNFCe	:= {}	//dados dos itens

BEGIN SEQUENCE

	//-----------------------------------------------------
	// Conversao XML da NFC-e e do Protocolo de Autorizacao
	//-----------------------------------------------------
	aRet := LjXMLNFCe(cXML)
	If aRet[1]
		oNFCe := aRet[2]
	Else
		BREAK
	EndIf
	
	aRet := LjXMLNFCe(cXMLProt)
	If aRet[1]
		oProt := aRet[2]
	Else
		BREAK
	EndIf
	
	cChvNFCe := StrTran(oNFCe:_NFE:_INFNFE:_ID:TEXT, "NFe")	//Chave da NFC-e

	//------------------------
	// Ponto de Entrada LJ7084
	//------------------------
	// Permite definir o que ser� realizado com os dados do DANFE
	// ex: customizar a impressao, e-mail, sms ou nao imprimir
	// .T. - apos a execucao do ponto de entrada, realiza a impressao padrao do DANFE
	// .F. - apos a execucao do ponto de entrada, NAO realiza a impressao padrao do DANFE
	If ExistBlock("LJ7084")
		lLj7084 := ExecBlock( "LJ7084", .F., .F., {oNFCe, oProt} )
		If ValType(lLj7084) <> "L"
			lLj7084 = .T.
		EndIf
	EndIf

	//--------------------------
	// Impressao padrao do DANFE
	//--------------------------
	If lDanfePad .AND. lLJ7084

		//----------------------------------------
		// Comunicacao com a impressora nao fiscal
		//----------------------------------------
		If !lImpComum .AND. !lPos .AND. nHdlECF == -1		
			cImpressora	:= LJGetStation("IMPFISC")
			cPorta := "AUTO"

			If !IsBlind()
				LjMsgRun( "Aguarde. Abrindo a Impressora N�o Fiscal...",, { || nHdlECF := INFAbrir( cImpressora,cPorta ) } )
			Else
				conout("Aguarde. Abrindo a Impressora...")
				nHdlECF := INFAbrir( cImpressora,cPorta )
			EndIf

			//Verifica se houve comunicacao com a impressora
			If nHdlECF == -1
				If !IsBlind()
					MsgStop("NFC-e: N�o foi poss�vel estabelecer comunica��o com a Impressora:" + cImpressora)
				Else
					conout("NFC-e: N�o foi poss�vel estabelecer comunica��o com a Impressora:" + cImpressora)
					//nao ha necessidade de retornar erro quando houver erro de impressora
				EndIf				
				//aborta a impressao
				BREAK
			EndIf
		EndIf
		
		//Valida se existe nDecimais, variavel � Privete declarada no Loja701
		If Type("nDecimais") == "U"
			nDecimais := MsDecimais(1)				// Quantidade de casas decimais
		EndIf

		aFormas := LjDfRetFrm()

		lContigen := oNFCe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT <> "1"

		//Verifica se conseguiu montar o objeto do XML e sinaliza nao contingencia 
		If (oProt <> NIL) .And. LjRTemNode(oProt:_PROTNFE:_INFPROT,"_NPROT")

			cProtAuto := AllTrim(oProt:_PROTNFE:_INFPROT:_NPROT:TEXT)			

			If LjRTemNode(oProt:_PROTNFE:_INFPROT,"_DHRECBTO")
				cDtHoraAut := oProt:_PROTNFE:_INFPROT:_DHRECBTO:TEXT
			EndIf

		EndIf

		//------------------------------------------------------------
		//Separa objetos do XML para facilitar a manipulacao dos dados
		//------------------------------------------------------------
		aEmitNfce := oNfce:_NFE:_INFNFE:_EMIT 		//Emitente

		//Ambiente (Normal ou Homologa��o)
		cAmbiente := oNFCe:_NFE:_INFNFE:_IDE:_TPAMB:TEXT

		//Quando n�o informa CPF/CNPJ, n�o retorna o objeto _DEST		
		If LjRTemNode(oNfce:_NFE:_INFNFE,"_DEST")
			aDestNfce := oNfce:_NFE:_INFNFE:_DEST 	//Destinat�rio
		EndIf

		aIdNfce	:= oNfce:_NFE:_INFNFE:_IDE			//Detalhe da NFC-e
		
		//Quando possui apenas um item, n�o retorna um Array de _PAG e sim os detalhes da Forma de Pagto, caso contrario retorna Array
		If Type("oNfce:_NFE:_INFNFE:_PAG[1]") == "O"
			aPagNfce := oNfce:_NFE:_INFNFE:_PAG
		Else
			aAdd(aPagNfce, oNfce:_NFE:_INFNFE:_PAG)
		EndIf

		//Quando possui apenas um item, n�o retorna um Array de _DET e sim os detalhes do produto, caso contrario retorna Array	
		If Type("oNfce:_NFE:_INFNFE:_DET[1]") == "O"
			aItemNfce := oNfce:_NFE:_INFNFE:_DET
		Else
			aAdd( aItemNfce, oNfce:_NFE:_INFNFE:_DET )
		EndIf
		
		//Total da NF
		aTotal := oNfce:_NFE:_INFNFE:_TOTAL
		
		//Verifica compatibilidade de Impressao: 4-DANFE Detalhada e 5-DANFE Resumida
		If !aIdNfce:_TPIMP:TEXT $ "45"
			If !IsBlind()
				MsgStop("Nfc-e: Tipo de Impress�o incompat�vel: "+aIdNfce:_TPIMP:TEXT)
			Else
				Conout("Nfc-e: Tipo de Impress�o incompat�vel: "+aIdNfce:_TPIMP:TEXT)
			EndIf			
			//aborta a rotina de impressao
			BREAK
		EndIf

		/*
			DIVISAO I - Informa��es do Cabe�alho
		*/
		/* Logotipo da empresa - (utilizar a ferramenta da pr�pria fabricante) */
		cTexto += TAG_BMP_INI + TAG_BMP_FIM

		/* CNPJ: 99.999.999/9999-99 Raz�o social do Emitente */		
		cTextoAux := "CNPJ: " + Transform(aEmitNfce:_CNPJ:TEXT, "@R 99.999.999/9999-99") + " "
		cTextoAux += TAG_NEGRITO_INI + AllTrim(aEmitNfce:_XNOME:TEXT) + TAG_NEGRITO_FIM
		
		cTexto += TAG_CENTER_INI
		cTexto += cTagCondIni
		cTexto += cTextoAux
		cTexto += cTagCondFim
		cTexto += cCRLF

		/* Endere�o Completo, nro, bairro, Munic�pio - UF */
		cTextoAux := AllTrim(aEmitNfce:_ENDEREMIT:_XLGR:TEXT) 	+ ","
		cTextoAux += AllTrim(aEmitNfce:_ENDEREMIT:_NRO:TEXT)	+ ","
		cTextoAux += AllTrim(aEmitNfce:_ENDEREMIT:_XBAIRRO:TEXT)+ ","
		cTextoAux += AllTrim(aEmitNfce:_ENDEREMIT:_XMUN:TEXT)	+ ","
		cTextoAux += AllTrim(aEmitNfce:_ENDEREMIT:_UF:TEXT)

		cTexto += (cTagCondIni + cTextoAux + cTagCondFim) 
		cTexto += cCRLF
		
		cTextoAux := (cTagCondIni + "DOCUMENTO AUXILIAR DA")
		cTextoAux += cCRLF
		cTextoAux += ("NOTA FISCAL DE CONSUMIDOR ELETR�NICA" + cTagCondFim)

		cTexto += cTextoAux
		cTexto += TAG_CENTER_FIM
		cTexto += Replicate(cCRLF,2)

		If lContigen
			cTexto += TAG_CENTER_INI
			cTexto += (TAG_NEGRITO_INI + "EMITIDA EM CONTING�NCIA" + TAG_NEGRITO_FIM)
			cTexto += cCRLF
			cTexto += (cTagCondIni + "Pendente de autoriza��o" + cTagCondFim)
			cTexto += TAG_CENTER_FIM
			cTexto += Replicate(cCRLF,2)
		EndIf

		/*
			DIVISAO II � Informa��es de detalhes de produtos/servi�os
			A impressao dessa divis�o � opcional ou conforme definido por UF
		*/
		//
		// Cabecalho da Divisao II e aColDiv2
		// A soma de todas as colunas do cabecalho deve ser igual a variavel nColunas (padrao 48)
		// O array aColDiv2 possui a quantidade de caracteres de cada coluna, entao se alterar qualquer posicao do cabecalho
		// deve-se alterar a sua respectiva posicao. Os espacoes entre as colunas nao sao considerados, portanto a soma
		// das posicoes do array e a dos espacos (5) devem ser igual a variavel nColunas.		 
		//
		cTexto += (TAG_NEGRITO_INI + TAG_CENTER_INI + cTagCondIni)
		cTexto += "Codigo          Desc. Qtd UN Vlr Unit. Vlr Total"	//48 colunas
		cTexto +=  (cTagCondFim + TAG_CENTER_FIM + TAG_NEGRITO_FIM)
		cTexto += cCRLF
		
		// ATENCAO: se alterar algum valor do array, deve-se alterar o cabecalho acima tambem
		Aadd(aColDiv2, 15)	// Codigo
		Aadd(aColDiv2, 05)	// Descricao
		Aadd(aColDiv2, 03)	// Qtd
		Aadd(aColDiv2, 02)	// Un
		Aadd(aColDiv2, 09)	// VlUnit.
		Aadd(aColDiv2, 09)	// VlTotal
	
		// soma das colunas Codigo + " " + Descricao 
		nCodDesc := aColDiv2[1] + 1 + aColDiv2[2]
	
		//obtemos a Picture que sera utilizada para o valor unitario
		cL2ItemPic := "@E " + Right( "@E 999,999,999.99", aColDiv2[5] )
		
		For nX := 1 to Len(aItemNfce)

			nContItImp++

			// Codigo			
			cLinha := PadR( aItemNfce[nX]:_PROD:_CPROD:TEXT, aColDiv2[1] ) + " "

			// Descricao				
			cConteudo := aItemNfce[nX]:_PROD:_XPROD:TEXT
			nTamDesc := Len( cConteudo )

			//
			// variaveis de controle da impressao da Descricao
			//
			lImpDesc := .T.
			nIniDesc := 1
			nFimDesc := aColDiv2[2] + aColDiv2[3] + aColDiv2[4] + aColDiv2[5] + aColDiv2[6] + 4 //4 espa�os separadores

			While lImpDesc
		
				//agora a linha contem o Codigo e Descricao do produto
				cLinha += SubStr(cConteudo, nIniDesc, nFimDesc)
	
				//
				//	Se o tamanho do Codigo + Descricao do produto ultrapassar a coluna Descricao, 
				//	entao a impressao das informacoes do item continuara na proxima linha a partir da coluna Codigo
				//
				If Len(cLinha) > nCodDesc

					//texto a ser impresso
					cLinha := PadR(cLinha, nColunas)
					cTexto += (TAG_CENTER_INI + cTagCondIni + cLinha + cTagCondFim + TAG_CENTER_FIM)					
					cTexto += cCRLF

					//
					// Controle para a PROXIMA linha
					//
					cLinha := ""
				
					//subtraimos do tamanho da Descricao, o conteudo ja impresso
					nTamDesc -= nFimDesc
				
					//somamos a posicao inicial a ser lido da Descricao, o conteudo ja impresso
					nIniDesc += nFimDesc
	
					If nTamDesc < 1
						//toda a descricao foi impressa, entao podemos continuar a imprimir as outras informacoes
						nFimDesc := 0
					ElseIf nTamDesc > nCodDesc
						//a descricao restante ultrapassa a coluna Descricao, entao ela usara a linha toda
						nFimDesc := nColunas
					Else
						//a descricao restante somente utilizara as colunas Codigo e Descricao
						nFimDesc := nCodDesc
					EndIf
			
				Else
					//nao sera necessario adicionar uma linha para impressao das outras informacoes dos itens
					lImpDesc := .F.
					cLinha := PadR( cLinha, nCodDesc ) + " "
				EndIf

			EndDo
		
			// Qtd - quantidade
			nConteudo := Val( aItemNfce[nX]:_PROD:_QCOM:TEXT )
			cConteudo := cValToChar(nConteudo)
			cLinha += PadL(cConteudo, aColDiv2[3]) + " "

			// Un - unidade de medida
			cLinha += PadL(aItemNfce[nX]:_PROD:_UCOM:TEXT, aColDiv2[4]) + " "

			// VlUnit. - valor unitario
			nConteudo := Val( aItemNfce[nX]:_PROD:_VUNCOM:TEXT )
			cConteudo := Transform(nConteudo, cL2ItemPic) + " "
			cLinha += cConteudo

			// VlTotal - valor total
			nConteudo := Val( aItemNfce[nX]:_PROD:_VPROD:TEXT )
			cConteudo := Transform(nConteudo, '@E 99,999.99')
			cLinha += cConteudo
		
			cTexto += (TAG_CENTER_INI + cTagCondIni + cLinha + cTagCondFim + TAG_CENTER_FIM)
			cTexto += cCRLF

			If nMVNFCEDES == 1
				If Type("aItemNfce["+AllTrim(Str(nX))+"]:_PROD:_VDESC") == "O"
					nConteudo := Val(aItemNfce[nX]:_PROD:_CPROD:TEXT)
					cConteudo := Transform(nConteudo, '@E 99,999.99')	//retorna 9 caracteres

					//a string com o desconto deve ser igual a variavel nColunas (texto + valor = nColunas)
					cLinha := "Desconto no Item                     - " + cConteudo

					cTexto += (TAG_CENTER_INI + cTagCondIni + cLinha + cTagCondFim + TAG_CENTER_FIM)
					cTexto += cCRLF
				EndIf
			EndIf
			
			//Tratamento necess�rio pois dependendo tamanho das informa��es dos itens a serem impressos,
			//apos um determinado tamanho o texto n�o � impresso, gerenado o erro de DEBUG/TOTVSAPI na DLL.
			//para isso foi quebrada a impress�o em 50 itens.			
			If nContItImp == 30
				If !lPos
					If FindFunction("LjAskImp")
						//Tratamento paliativo para impressora Bematech, ate a solucao de problema de comunicacao ppor parte da BEMATECH
						nRetImp := 999						
						While nRetImp <> 0 .And. LjAskImp(nRetImp)
							LJGrvLog(Nil, "Envia o texto para a impressao intermediaria (INFTexto)")
							nRetImp := INFTexto(cTexto)  //Envia comando para a Impressora
						End
					Else
						LJGrvLog(Nil, "Envia o texto para a impressao intermediaria (INFTexto)")
						INFTexto(cTexto)  //Envia comando para a Impressora
					EndIf
				Else
					LJGrvLog(Nil, "Envia o texto para a impressao intermediaria (STWPrintTextNotFiscal)")
					STWPrintTextNotFiscal(cTexto)
				EndIf
				cTexto		:= ""
				nContItImp	:= 0
			EndIf

		Next

		/*
			DIVISAO III � Informa��es de Total do DANFE NFC-e
		*/
		//--------------------------------------------
		// "Qtd. Total de Itens"
		//--------------------------------------------		
		cTextoAux 	:= "QTD. TOTAL DE ITENS"
		cTextoAux 	:= cTextoAux + PadL( cValToChar(Len(aItemNfce)), nColunas - Len(cTextoAux) )

		cTexto 		+= (TAG_CENTER_INI + cTagCondIni + cTextoAux + cTagCondFim + TAG_CENTER_FIM)
		cTexto		+= cCRLF
		
		//--------------------------------------------
		// "Valor Total R$"
		//--------------------------------------------
		//se existir ISSQN, o VALOR TOTAL � igual a soma da tag vProd + vServ
		If LjRTemNode(aTotal,"_ISSQNTOT")
			nVlrTotal := Val(aTotal:_ICMSTOT:_VPROD:TEXT) + Val(aTotal:_ISSQNTot:_VSERV:TEXT)
		Else
			nVlrTotal := Val(aTotal:_ICMSTOT:_VPROD:TEXT)
		EndIf		

		cTextoAux 	:= "VALOR TOTAL R$"		
		cTextoAux 	:= cTextoAux + PadL( AllTrim(Transform(nVlrTotal, '@E 999,999,999,999.99')), nColunas-Len(cTextoAux) )
		
		cTexto			+= (TAG_CENTER_INI + cTagCondIni + cTextoAux + cTagCondFim + TAG_CENTER_FIM)
		cTexto			+= cCRLF
		
		// Verifica se possui DESCONTO ou ACRESCIMO (vOutro)
		nTotDesc	:= Val(aTotal:_ICMSTOT:_VDESC:TEXT )
		nTotAcresc	:= Val(aTotal:_ICMSTOT:_VOUTRO:TEXT)

		If (nTotDesc - nTotAcresc) <> 0								
			If nTotDesc > nTotAcresc
				cTextoAux := "DESCONTOS R$"
			Else
				cTextoAux := "ACRESCIMOS R$"
			EndIf
			cTextoAux := cTextoAux + PadL( AllTrim(Transform( Abs(nTotDesc-nTotAcresc), '@E 999,999,999,999,999.99')), nColunas-Len(cTextoAux) )	
			
			cTexto	+= (TAG_CENTER_INI + cTagCondIni + cTextoAux + cTagCondFim + TAG_CENTER_FIM)
			cTexto	+= cCRLF
			
			//--------------------------------------------
			// "VALOR A PAGAR R$"
			//--------------------------------------------		
			cTextoAux 	:= "VALOR A PAGAR R$"
			cTextoAux 	:= cTextoAux + PadL( AllTrim(Transform(Val(aTotal:_ICMSTOT:_VNF:TEXT), '@E 999,999,999,999,999.99')), nColunas-Len(cTextoAux) )
			cTextoAux	:= TAG_CENTER_INI + cTextoAux + TAG_CENTER_FIM

			cTexto		+= (TAG_NEGRITO_INI + cTagCondIni + cTextoAux + cTagCondFim + TAG_NEGRITO_FIM)
			cTexto		+= cCRLF
		EndIf
		
		//-----------------------------------------------------------
		// "FORMA PAGAMENTO                         VALOR A PAGAR R$"
		//-----------------------------------------------------------
		cTextoAux := "FORMA PAGAMENTO" + "VALOR A PAGAR R$"
		cTexto += (TAG_CENTER_INI + cTagCondIni)		
		cTexto += ("FORMA PAGAMENTO" + Space( nColunas-Len(cTextoAux) ) + "VALOR A PAGAR R$")
		cTexto += (cTagCondFim + TAG_CENTER_FIM)

		For nX := 1 to Len(aPagNFCe)
			cTexto += cCRLF

			nY := aScan( aFormas, {|x| Alltrim(x[2]) == Alltrim(aPagNfce[nX]:_TPAG:TEXT)} )
			If nY > 0
				cFormaPgto := aFormas[nY][1]
			Else
				cFormaPgto := "OUTROS"
			EndIf
			cVlrFormPg := AllTrim( Transform(Val(aPagNfce[nX]:_VPAG:TEXT), '@E 999,999,999,999,999.99') )

			cTexto += (TAG_CENTER_INI + cTagCondIni + cFormaPgto + PadL( cVlrFormPg, nColunas-Len(cFormaPgto) ) + cTagCondFim + TAG_CENTER_FIM)
		Next nX
		cTexto += Replicate(cCRLF,2)

		/*
			DIVISAO IV � Informa��es da consulta via chave de acesso
		*/
		cTexto += TAG_CENTER_INI
		cTexto += (cTagCondIni + TAG_NEGRITO_INI + "Consulte pela Chave de Acesso em" + TAG_NEGRITO_FIM + cTagCondFim)
		cTexto += cCRLF

		cTexto += TAG_CONDEN_INI
		//URL de Consulta Publica
		cTexto += LjNFCeURL(cAmbiente, .T.)		
		cTexto += cCRLF

		//1111 2222 3333 4444 5555 6666 7777 8888 9999 0000 1111
		For nX := 1 to 44 Step 4
			cTexto += SubStr(cChvNFCe, nX , 4) + " "
		Next
		cTexto += TAG_CONDEN_FIM
		cTexto += TAG_CENTER_FIM
		cTexto += Replicate(cCRLF,2)
		
		/*
			Divis�o VI � Informa��es sobre o Consumidor
		*/
		cTexto += TAG_CENTER_INI

		If Empty(aDestNfce)
			cTexto += (cTagCondIni + TAG_NEGRITO_INI + "CONSUMIDOR N�O IDENTIFICADO" + TAG_NEGRITO_FIM + cTagCondFim)			 
		Else
			cTexto += (cTagCondIni + TAG_NEGRITO_INI + "CONSUMIDOR -" + TAG_NEGRITO_FIM + cTagCondFim)
			
			cTexto += cTagCondIni + TAG_NEGRITO_INI
			If LjRTemNode(aDestNfce,"_CPF")
				cTexto += " CPF: " 
				cTexto += Transform(aDestNfce:_CPF:TEXT, "@R 999.999.999-99")
			ElseIf LjRTemNode(aDestNfce,"_CNPJ")
				cTexto += " CNPJ: " 
				cTexto += Transform(aDestNfce:_CNPJ:TEXT, "@R 99.999.999/9999-99")
			ElseIf LjRTemNode(aDestNfce,"_IDESTRANGEIRO")
				cTexto += " Id. Estrangeiro: "
				cTexto += aDestNfce:_IDESTRANGEIRO:TEXT
			EndIf
			cTexto += TAG_NEGRITO_FIM

			If LjRTemNode(aDestNfce,"_XNOME")
				cTexto += " " + AllTrim(aDestNfce:_XNOME:TEXT) + " "
			EndIf

			//
			//OPCIONALMENTE poder� ser inclu�da nesta divis�o tamb�m o nome do consumidor e/ou seu endere�o.
			//No caso de emiss�o de NFC-e com entrega em domic�lio � OBRIGAT�RIA a impress�o do nome do consumidor e do endere�o de entrega.
			//			
			If LjRTemNode(aDestNfce,"_ENDERDEST")
				cTexto += cCRLF
				cTexto += aDestNfce:_ENDERDEST:_XLGR:TEXT + ',' 
				cTexto += aDestNfce:_ENDERDEST:_NRO:TEXT + ','
				cTexto += aDestNfce:_ENDERDEST:_XBAIRRO:TEXT + ',' 
				cTexto += aDestNfce:_ENDERDEST:_XMUN:TEXT + '-'
				cTexto += aDestNfce:_ENDERDEST:_UF:TEXT				
			EndIf
			cTexto += cTagCondFim				
		EndIf
		
		cTexto += TAG_CENTER_FIM
		cTexto += Replicate(cCRLF,2)

		/*
			DIVISAO VI � Informa��es de Identifica��o da NFC-e e do Protocolo de Autoriza��o
			N�mero S�rie Emiss�o DD/MM/AAAA hh:mm:ss
		*/
		aDtHrLocal := LjUTCtoLoc(aIdNfce:_DHEMI:TEXT)

		cTextoAux := "NFC-e n " + aIdNfce:_NNF:TEXT + " " 		//N�mero da NFC-e
		cTextoAux += "S�rie " + aIdNfce:_SERIE:TEXT + " " 		//S�rie da NFC-e
		cTextoAux += PadL( Day(aDtHrLocal[1]),2,"0" ) + "/"		//DD
		cTextoAux += PadL( Month(aDtHrLocal[1]),2,"0" ) + "/"	//MM
		cTextoAux += cValToChar( Year(aDtHrLocal[1]) ) + " "	//AAAA
		cTextoAux += aDtHrLocal[2]								//hh:mm:ssa

		cTexto += (TAG_CENTER_INI + TAG_NEGRITO_INI + cTagCondIni)
		cTexto += cTextoAux
		cTexto += (cTagCondFim + TAG_NEGRITO_FIM + TAG_CENTER_FIM)
		cTexto += cCRLF

		// obtemos o Protocolo de Autorizacao do XML retornado do SEFAZ (se modalidade NORMAL)
		If !lContigen			
			aDtHrLocal := LjUTCtoLoc(cDtHoraAut)
			
			//Data de Autoriza��o: DD/MM/AAAA hh:mm:ss
			cTextoAux := (cTagCondIni + TAG_NEGRITO_INI + "Data de Autoriza��o: " + TAG_NEGRITO_FIM + cTagCondFim)
			cTextoAux += cTagCondIni
			cTextoAux += PadL( Day(aDtHrLocal[1]),2,"0" ) + "/"		//DD
			cTextoAux += PadL( Month(aDtHrLocal[1]),2,"0" ) + "/"	//MM
			cTextoAux += cValToChar( Year(aDtHrLocal[1]) ) + " "	//AAAA
			cTextoAux += aDtHrLocal[2]								//hh:mm:ss
			cTextoAux += cTagCondFim

			cTexto += TAG_CENTER_INI 
			cTexto += (cTagCondIni + TAG_NEGRITO_INI + "Protocolo de Autoriza��o: " + TAG_NEGRITO_FIM + cTagCondFim)
			cTexto += (cTagCondIni + cProtAuto + cTagCondFim)
			cTexto += cCRLF
			cTexto += cTextoAux 
			cTexto += TAG_CENTER_FIM
			cTexto += cCRLF
		EndIf		

		/*
			DIVISAO VIII � �rea de Mensagem Fiscal
		*/		
		If Type("oNfce:_NFE:_INFNFE:_INFADIC") == "O" .AND. LjRTemNode(oNfce:_NFE:_INFNFE:_INFADIC, "_INFADFISCO")

			//para que haja a quebra de linha durante a impressao, separamos cada linha por |
			aInfCpl := StrToKArr(oNfce:_NFE:_INFNFE:_INFADIC:INFADFISCO:TEXT, "|")
			nInfCpl := Len( aInfCpl )	//quantidade de quebra de linhas			

			cTextoAux := ""

			For nY := 1 to nInfCpl
				cTextoAux += aInfCpl[nY]
				If nY <> nInfCpl
					cTextoAux += cCRLF
				EndIf
			Next

			cTexto += TAG_CENTER_INI + cTagCondIni
			cTexto += cTextoAux
			cTexto += cTagCondFim + TAG_CENTER_FIM
			cTexto += cCRLF
		EndIf
		
		//Se Ambiente for Homologacao		
		If cAmbiente == "2"
			cTexto += cCRLF
			cTexto += (TAG_CENTER_INI + TAG_CONDEN_INI + "EMITIDA EM AMBIENTE DE HOMOLOGA��O � SEM VALOR FISCAL" + TAG_CONDEN_FIM + TAG_CENTER_FIM)
			cTexto += Replicate(cCRLF,2)
		EndIf

		If lContigen			
			cTexto += cCRLF
			cTexto += (TAG_CENTER_INI + TAG_NEGRITO_INI + "EMITIDA EM CONTING�NCIA" + TAG_NEGRITO_FIM + TAG_CENTER_FIM)
			cTexto += cCRLF
			cTexto += (TAG_CENTER_INI + cTagCondIni + "Pendente de autoriza��o" + cTagCondFim + TAG_CENTER_FIM)
			cTexto += Replicate(cCRLF,2)
		EndIf
		
		cTexto	+= TAG_CENTER_INI
		cTexto	+= LjRetQrCd( oNfce, cAmbiente,	cModelo	)
		cTexto	+= TAG_CENTER_FIM
		cTexto	+= cCRLF
		
		/*
			DIVISAO IX � Mensagem de Interesse do Contribuinte
		*/
		If Type("oNfce:_NFE:_INFNFE:_INFADIC") == "O" .AND. LjRTemNode(oNfce:_NFE:_INFNFE:_INFADIC, "_INFCPL")

			//para que haja a quebra de linha durante a impressao, separamos cada linha por |
			aInfCpl := StrToKArr(oNfce:_NFE:_INFNFE:_INFADIC:_INFCPL:TEXT, "|")
			nInfCpl := Len( aInfCpl )	//quantidade de quebra de linhas
			
			cTextoAux := ""

			For nY := 1 to nInfCpl
				cTextoAux += (cTagCondIni + aInfCpl[nY] + cTagCondFim)
				If nY <> nInfCpl					
					cTextoAux += cCRLF
				EndIf
			Next
			cTexto += (TAG_CENTER_INI + cTextoAux + TAG_CENTER_FIM)
			cTexto += cCRLF
		EndIf		

		//
		// Salta linha extra
		//
		For nX := 1 to nSaltoLn
			cTexto += cCRLF
		Next nX

		//----------------
		// Imprime o DANFE
		//----------------
		If lImpComum// Impressora Laser
			U_LOJRNFCe(	oNFCe		, oProt		, nDecimais	, aFormas	,;
						cProtAuto	, lContigen	, cDtHoraAut, aEmitNfce	,; 
						aDestNfce	, aIdNfce	, aPagNfce	, aItemNfce	,; 
						aTotal		, cChvNFCe	)
		Else //Imprime N�o Fiscal

			//
			//Inclui a TAG que Faz o corte do papel, apos a impressao da DANFE
			//
			If lGuil
				cTexto += (TAG_GUIL_INI+TAG_GUIL_FIM)	//aciona a guilhotina
			EndIf
			
			If lPos
				LJGrvLog(Nil, "Envia o texto para a impressao final (STWPrintTextNotFiscal)")
				STWPrintTextNotFiscal(cTexto)
			Else
				If FindFunction("LjAskImp")
					//Tratamento paliativo para impressora Bematech, ate a solucao de problema de comunicacao ppor parte da BEMATECH
					nRetImp := 999
					While nRetImp <> 0 .And. LjAskImp(nRetImp)
						LJGrvLog(Nil, "Envia o texto para a impressao final (INFTexto)")
						nRetImp := INFTexto(cTexto)  //Envia comando para a Impressora
					End
				Else
					LJGrvLog(Nil, "Envia o texto para a impressao final (INFTexto)")
					INFTexto(cTexto)	//Envia comando para a Impressora
				EndIf
			EndIf
		EndIf

	EndIf

RECOVER
	lRet := .F.

END SEQUENCE

If lRet .And. SuperGetMV("MV_NFCEIMP",, 1) == 2 //Impressao do comprovante de NFC-e da venda: 1=Opcional; 2=Obrigatorio;
	If nRetImp == 0 
		lRet := .T. //Sucesso
	Else
		lRet := .F. //Problema
	EndIf
EndIf

aRet := { lRet,cChvNFCe,nVlrTotal }

LJGrvLog(Nil, "Retorno da funcao LjRDNFNFCe", aRet)

Return  aRet

//--------------------------------------------------------
/*{Protheus.doc} LjRTemNode
Verifica se existe o n� no XML

@author  Varejo
@version P11.8
@since   02/02/2016
@return	 lRet - existe ? 
*/
//--------------------------------------------------------
Static Function LjRTemNode(oObjeto,cNode)
Local lRet := .F.

lRet := (XmlChildEx(oObjeto,cNode) <> NIL)

Return lRet


Static Function LjUTCtoLoc(cDataUTC)

Local dData			:= Nil
Local cHoraMin		:= ""
Local cSegundos		:= ""
Local cTZD			:= ""
Local nTZD			:= 0
Local dDataLocal	:= Nil
Local cHoraLocal	:= ""
Local nHoraLocal	:= 0
Local cTZDLocal		:= ""
Local nTZDLocal		:= 0
Local nHoraUTC		:= 0
Local cGMTByUF		:= ""

Local aRet			:= {}
Local aHoraLocal	:= {}

Default cDataUTC 	:= ""

dData 		:= CtoD( SubStr(cDataUTC,9,2) + "/" + SubStr(cDataUTC,6,2) + "/" + SubStr(cDataUTC,1,4) ) //ex: DD/MM/AAAA
cHoraMin	:= SubStr( cDataUTC, 12, 05 )	//ex: hora e minuto do horario ex: 00:00:xx
cSegundos	:= SubStr( cDataUTC, 18, 02 )	//ex: segundos do horario ex: xx:xx:00
cTZD		:= SubStr( cDataUTC, 20, 06 )	//ex: -03:00 
nTZD		:= Val( cTZD )					//ex: -3

/*
	Fuso horario zero (somamos o TZD para obter o fuso horario zero)
*/
nHoraUTC := Val( StrTran(cHoraMin, ":", ".") )
nHoraUTC := nHoraUTC + (nTZD*(-1))

/*
	Fuso horario local
*/
cGMTByUF := SubStr(FwGMTByUF(), 1, 6)
cTZDLocal := SuperGetMV("MV_NFCEUTC",,cGMTByUF)
nTZDLocal := Val(cTZDLocal)

nHoraLocal := nHoraUTC + nTZDLocal

If nHoraLocal >= 24
	nHoraLocal := nHoraLocal - 24
	dDataLocal := dData += 1
Else
	dDataLocal := dData
EndIf

// convertemos a hh:mm para o formato Caracter
cHoraLocal := cValToChar(nHoraLocal)

// tratamos as horas e minutos
aHoraLocal := StrToKArr(cHoraLocal, ".")

aHoraLocal[1] := PadL(aHoraLocal[1], 2, "0")		//acrescenta 0 no inicio da hora
If Len(aHoraLocal) > 1
	aHoraLocal[2] := PadR(aHoraLocal[2], 2, "0")	//acrescenta 0 no final dos minutos
Else //se for hora fechada (ex: 08:00), o array somente vai ter uma posi��o, sendo assim, adicionamos 00 aos Minutos
	Aadd(aHoraLocal, PadR(0, 2, "0"))				//acrescenta 0 no final dos minutos
EndIf

// transforma no formato hh:mm:ss
cHoraLocal := aHoraLocal[1] + ":" + aHoraLocal[2] + ":" + cSegundos

Aadd(aRet, dDataLocal)
Aadd(aRet, cHoraLocal)
Aadd(aRet, cTZDLocal)

Return aRet

//--------------------------------------------------------
/*{Protheus.doc} LjRetQrCd
Retorno do QrCode para impress�o

@author  Varejo
@version P11.8
@since   02/02/2016
@return	 cRet - qrCode para impress�o 
*/
//--------------------------------------------------------
Static Function LjRetQrCd(	oNfce,	cAmbiente, 	cModelo	)
Local cKeyQRCode := ""
Local cRet		 := ""

/*
	DIVISAO V � Informa��es da Consulta via QR Code
	A imagem do QR Code poder� ser CENTRALIZADA (conforme o rdmake) ou
	impressa � esquerda das informa��es exigidas nas Divis�es VI e VII
*/		
cKeyQRCode := U_HFLjQrCo(oNFCe, cAmbiente)
cRet := TAG_QRCODE_INI
cRet += cKeyQRCode
If "DARUMA" $ cModelo
	//define o tamanho do QR-Code
	cRet += (TAG_LMODULO_INI + '3' + TAG_LMODULO_FIM) 
EndIf			
cRet += TAG_QRCODE_FIM		

Return cRet



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LjNfceQrCo �Autor �Vendas Cliente      � Data �  16/04/13   ���
�������������������������������������������������������������������������͹��
���Desc.     � Gera link para consulta da NFC-e via QrCode			      ���
�������������������������������������������������������������������������͹��
���Retorno   �ExpC1 - Link/Chave formatada						 		  ���
�������������������������������������������������������������������������͹��
���Uso       � Venda Assistida                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
USER Function HFLjQrCo( oNFCe, cAmbiente ) //U_HFLjQrCo //LjNfceQrCo

	Local cChNFe 		:= "chNFe="							//oNfce:_NFE:_INFNFE:_ID:TEXT
	Local cnVersao		:= "&nVersao=" 						//Versao do QrCode
	Local cTpAmb		:= "&tpAmb=" 						//oNfce:_NFE:_INFNFE:_IDE:_TPAMB:TEXT
	Local cDest			:= ""								//oNfce:_NFE:_INFNFE:_DEST Documento de Identifica��o do Consumidor
	Local cDhEmi		:= "&dhEmi="						//oNfce:_NFE:_INFNFE:_IDE:_DHEMI:TEXT
	Local cvNF          := "&vNF="	   						//oNfce:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VNF:TEXT
	Local cvICMS        := "&vICMS="						//oNfce:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VICMS:TEXT
	Local cDigVal       := "&digVal="						//oNfce:_NFE:_SIGNATURE:_SIGNEDINFO:_REFERENCE:_DIGESTVALUE:TEXT
	Local cIdToken      := "&cIdToken="						//N�o definido qual ser� o padr�o
	Local cHashQrCode   := "&cHashQRCode="					//Hash da concatenacao dos campos
	Local cKeyQrCode	:= ""								//QrCode Formatado com URL
	Local cToken		:= SuperGetMv( "MV_NFCETOK",, "" )	//Token fornecido ao cliente(por CNPJ) pelo Sefaz (32 posicoes), quando ambiente de homologacao o Token e formado com base no Cnpj
	Local lTSSDemoOff := .F.//Parametro TSS demo (off-line)
	Local cMobNFCETSS := "0" //Tipo do TSS mobile

	Default oNFCe		:= Nil
	Default cAmbiente	:= ""
 
	PRIVATE aDestNfce	:= {}

	cMobNFCETSS			:= STFGetCfg("cMobNFCETSS", "0")
	lTSSDemoOff := IIF(ValType(cMobNFCETSS)="U", .F., cMobNFCETSS == "9")

	If Type("oNfce:_NFE:_INFNFE:_DEST") == "O"
		aDestNfce	:= oNfce:_NFE:_INFNFE:_DEST 		//Destinat�rio
	
		If Empty(aDestNfce)
			cDest := ""
		ElseIf Type("aDestNfce:_CNPJ") <> 'U'
			cDest := "&cDest=" + AllTrim(aDestNfce:_CNPJ:TEXT)
		ElseIf Type("aDestNfce:_CPF") <> 'U'
			cDest := "&cDest=" + AllTrim(aDestNfce:_CPF:TEXT)
		EndIf
	EndIf

	cChNFe 		+= SubStr(oNfce:_NFE:_INFNFE:_ID:TEXT,4,Len(oNfce:_NFE:_INFNFE:_ID:TEXT))
	cnVersao	+= "100" 	//Somente homologado na versao 100, se homologar outras versoes de QrCode sera necessario criar aram
	cTpAmb		+= cAmbiente
	cDhEmi		+= LjAsc2Hex(oNfce:_NFE:_INFNFE:_IDE:_DHEMI:TEXT)
	cvNF        += oNfce:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VNF:TEXT
	cvICMS      += oNfce:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VICMS:TEXT
	If !lTSSDemoOff
		cDigVal     += LjAsc2Hex(oNfce:_NFE:_SIGNATURE:_SIGNEDINFO:_REFERENCE:_DIGESTVALUE:TEXT)
	Else
		cDigVal     += LjAsc2Hex("5ea2fab8521fdb16eadd13ee59aac501")// Demo de TSS NFCE
	EndIf
	cIdToken    += SuperGetMv("MV_NFCEIDT" ,,"000001") //ID do token (CSC) disponibilizado pelo SEFAZ

//Concatena todas as informacoes e extrai Hash(SHA1)
	cHashQRCode += Upper( SHA1(cChNFe+cnVersao+cTpAmb+cDest+cDhEmi+cvNF+cvICMS+cDigVal+cIdToken+cToken) )

//Verifica (cEstCob) para qual Sefaz/URL deve apontar o QrCode 
	cKeyQRCode	:= LjNFCeURL(cAmbiente)

	cKeyQrCode	+= cChNFe
	cKeyQrCode	+= cnVersao
	cKeyQrCode	+= cTpAmb
	cKeyQrCode	+= cDest
	cKeyQrCode	+= cDhEmi
	cKeyQrCode	+= cvNF
	cKeyQrCode	+= cvICMS
	cKeyQrCode	+= cDigVal
	cKeyQrCode	+= cIdToken
	cKeyQrCode	+= cHashQRCode

	conout("QRCode: " + cKeyQRCode)

Return cKeyQrCode
