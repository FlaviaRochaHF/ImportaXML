#include "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "Ap5Mail.ch"
#INCLUDE "FILEIO.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH" 
#INCLUDE "XMLXFUN.CH" 
#INCLUDE "mata140.ch"

#DEFINE	BARRA	'/'

Static lUnix  := IsSrvUnix()
Static cBarra := Iif(lUnix,"/","\")

//NFCE_02 07/03 Rotinas para importar NF Serviços Eletronica. A Começar Importar TXT de SP.
//{C; xTPREG; !}
User Function HFCONV()
Local ret
Local cTipo := &(AllTrim(PARAMIXB[1]))
Local cVar  := &(AllTrim(PARAMIXB[2]))
Local cPict := &(AllTrim(PARAMIXB[3]))
Local cAno  := ""
Local cMes  := ""
Local cDia  := ""
Local i := 0

if cTipo == "C"
	ret := Transform(cVar,cPict)
Elseif cTipo == "N"
	ret := Val( Transform(cVar,cPict) ) //ver o decimal aqui
Elseif cTipo == "D"
	cAno := ""
	cMes := ""
	cDia := ""
	For i := 1 To Len( cVar )
		if Substr( cPict, i, 1 ) == "A"
			cAno += Substr( cVar, i, 1 )
		elseif Substr( cPict, i, 1 ) == "M"
			cMes += Substr( cVar, i, 1 )
		elseif Substr( cPict, i, 1 ) == "D"
			cDia += Substr( cVar, i, 1 )
		endif
	Next i 
	ret := cToD( cDia+"/"+cMes+"/"+cAno )
Elseif cTipo == "L"
	ret := iif(cVar == "T" .or. cVar == "1" .or. cVar == ".T.", .T., .F. )
Else
	ret := cVar //evitando a Fadiga
Endif

Return( ret )


//{"E"; xTPDOCD; xCNPJD; "@!"}
User Function HFCVCNPJ
Local ret
Local cZero := &(AllTrim(PARAMIXB[1]))
Local cTpDc := &(AllTrim(PARAMIXB[2]))
Local cVar  := &(AllTrim(PARAMIXB[3]))
Local cPict := &(AllTrim(PARAMIXB[4]))

if cTpDc $ "1,3" //CPF
	if cZero == "E"
		ret := Transform(Substr(cVar,4,11),cPict)
	Else
		ret := Transform(Substr(cVar,1,11),cPict)
	EndIF
Else //CNPJ
	ret := Transform(cVar,cPict)
EndIF

Return( ret )


//{xCNPJD; "@!"}
User Function HFCVCNP2
Local ret
Local cVar  := &(AllTrim(PARAMIXB[3]))
Local cPict := &(AllTrim(PARAMIXB[4]))
Local nAux  := 0
Local cAux  := ""

nAux := Val( AllTrim(cVar) )
cAux := AllTrim( Str( nAux ) )

if Len( cAux ) == 14
	ret := Transform(cAux,cPict)
ElseIf Len( cAux ) == 11
	ret := Transform(cAux,cPict)
Else //Boi na linha
	ret := Substr(cAux + Replicate( "0", 14 ), 1, 14 )
Endif

Return( ret )



//{"C", xNFSE, xRPS, "999999999999"}
User Function HFRPS()
Local ret
Local cTipo := &(AllTrim(PARAMIXB[1]))
Local cNfse := &(AllTrim(PARAMIXB[2]))
Local cVar  := &(AllTrim(PARAMIXB[3]))
Local cPict := &(AllTrim(PARAMIXB[4]))

if cTipo == "C"
	ret := ""
	if Empty(cNfse)
		ret := Transform( val(cVar), cPict )
	endif
Elseif cTipo == "N"
	ret := 0
	If Empty(cNfse)
		ret := Val( cVar )
	EndIf
Elseif cTipo == "D"
	ret := ctod( "" )
	if Empty(cNfse)
	    aParam := {PARAMIXB[1], PARAMIXB[3], PARAMIXB[4]}
		ret := ExecBlock( "HFCONV", .F., .F., aParam )
	endif
Elseif cTipo == "L"
	ret := .F.
Else
	ret := "" //Evitando a Fadiga
EndIf

Return( ret )


//{"35";2;"50308";5;xCNPJ;14;iif(empty(xRPS),xNFSE,xNFSE);12;iif(empty(xRPS),xSERIE,xSERIE);5}
User Function HFCHVNFS()
Local cChave  := ""
Local cAux    := ""
Local aAux    := PARAMIXB
Local aCadeia := {}
Local aTamanh := {}
Local nI      := 0

For nI := 1 To Len( aAux )
	If Mod(nI,2) <> 0
		aadd(aCadeia, &(aAux[nI]) )
	Else
		aadd(aTamanh, &(aAux[nI]) )
	EndIf
Next nI

cChave := ""

For nI := 1 To Len( aCadeia )
	If Len( aTamanh ) >= nI
		cChave += PADL( AllTrim(aCadeia[nI]), aTamanh[nI], "0" )  //zeros a esquerda se for necessário
	Else
		cChave += aCadeia[nI]
	Endif
Next nI

Return( cChave )


//{xCNPJD,xIEDest}
User Function HFVLDXML()
Local lRet    := .T.
Local cDocDest:= iif( Len(PARAMIXB)>=1, &(AllTrim(PARAMIXB[1])), "" )
Local cIEDest := iif( Len(PARAMIXB)>=2, &(AllTrim(PARAMIXB[2])), "" )

//aFilsEmp => Esta bagaça vem private do importa
//aFilsLic => Esta também
nFilScan := aScan(aFilsEmp,{|x| x[2] == cDocDest .and. AllTrim(x[5]) == AllTrim( cIEDest ) })
If nFilScan == 0
    nFilScan := aScan(aFilsEmp,{|x| x[2] == cDocDest })
EndIf

lRet := (nFilScan > 0)

If ! lRet
	cError := "Este XML não pertence a Empresa/Filial ! Código "+AllTrim(SM0->M0_CODIGO)+" "  +CRLF
	cOcorr := "Documento emitido para CNPJ/CPF diferente da empresa cadastrada."
    If !Empty(AllTrim(cOcorr+cError))
		//U_SdMailEr(1,"RP",oXml,cChv,cOcorr,cError,"")
		Conout(;
			cChv+CRLF+;
			cOcorr+CRLF+;
			cError+CRLF;
		)
	EndIf
EndIf

Return( nFilScan )


//{xCNPJ,xVLSERV,xVLDEDZ,xALIQ,xVLISS}
User Function HFMONXML
Local cRetXml := ""
Local cCnpj   := iif( Len(PARAMIXB)>=1, &(AllTrim(PARAMIXB[1])), "" )
Local nVlServ := iif( Len(PARAMIXB)>=2, &(AllTrim(PARAMIXB[2])), 0 )
Local nVlDedz := iif( Len(PARAMIXB)>=3, &(AllTrim(PARAMIXB[3])), 0 )
Local nAliq   := iif( Len(PARAMIXB)>=4, &(AllTrim(PARAMIXB[4])), 0 )
Local nVlIss  := iif( Len(PARAMIXB)>=5, &(AllTrim(PARAMIXB[5])), 0 )
Local cError  := "", cWarning := ""

Private oXmlTeste

cRetXml:= '<?xml version="1.0" encoding="UTF-8"?>'
cRetXml+= '<NfseTxt versao="1.00">'
cRetXml+= '<InfProc>'
	cRetXml+= '<Cnpj>'+cCnpj+'</Cnpj>'
	cRetXml+= '<VrServ>'+AllTrim(Str(nVlServ,20,2))+'</VrServ>'
	cRetXml+= '<VrDedz>'+AllTrim(Str(nVlDedz,20,2))+'</VrDedz>'
	cRetXml+= '<Aliq>'+AllTrim(Str(nAliq,20,2))+'</Aliq>'
	cRetXml+= '<VRISS>'+AllTrim(Str(nVlIss,20,2))+'</VRISS>'
cRetXml+= '</InfProc>'
cRetXml+= '</NfseTxt>'

cRetXml := NoAcento(cRetXml)
cRetXml := EncodeUTF8(cRetXml)

oXmlTeste := XmlParser( cRetXml, "_", @cError, @cWarning )

if Type("oXmlTeste") == "U"
	cRetXml := ""
Endif

Return( cRetXml )


//Monta XML para SP e RJ, com código do produto e Descr Serviço
//{xCNPJ;xVLSERV;xVLDEDZ;xALIQ;xVLISS;xDesSrv;xRPS;xCDSERV}
User Function HFSPXML
Local cRetXml := ""
Local cCnpj   := iif( Len(PARAMIXB)>=1, &(AllTrim(PARAMIXB[1])), "" )
Local nVlServ := iif( Len(PARAMIXB)>=2, &(AllTrim(PARAMIXB[2])), 0 )
Local nVlDedz := iif( Len(PARAMIXB)>=3, &(AllTrim(PARAMIXB[3])), 0 )
Local nAliq   := iif( Len(PARAMIXB)>=4, &(AllTrim(PARAMIXB[4])), 0 )
Local nVlIss  := iif( Len(PARAMIXB)>=5, &(AllTrim(PARAMIXB[5])), 0 )
Local cDesSrv := iif( Len(PARAMIXB)>=6, &(AllTrim(PARAMIXB[6])), "" )
Local cRps    := iif( Len(PARAMIXB)>=7, &(AllTrim(PARAMIXB[7])), "" )
Local cProd   := iif( Len(PARAMIXB)>=8, &(AllTrim(PARAMIXB[8])), "" )
Local cError  := "", cWarning := ""

Private oXmlTeste

cRetXml:= '<?xml version="1.0" encoding="UTF-8"?>'
cRetXml+= '<NfseTxt versao="1.00">'
cRetXml+= '<InfProc>'
	cRetXml+= '<Cnpj>'+cCnpj+'</Cnpj>'
	cRetXml+= '<VrServ>'+AllTrim(Str(nVlServ,20,2))+'</VrServ>'
	cRetXml+= '<VrDedz>'+AllTrim(Str(nVlDedz,20,2))+'</VrDedz>'
	cRetXml+= '<Aliq>'+AllTrim(Str(nAliq,20,2))+'</Aliq>'
	cRetXml+= '<VRISS>'+AllTrim(Str(nVlIss,20,2))+'</VRISS>'
	cRetXml+= '<Rps>'+AllTrim(cRps)+'</Rps>'
	cRetXml+= '<DesSrv>'+AllTrim(cDesSrv)+'</DesSrv>'
	cRetXml+= '<ProdSrv>'+AllTrim(cProd)+'</ProdSrv>'
cRetXml+= '</InfProc>'
cRetXml+= '</NfseTxt>'

cRetXml := NoAcento(cRetXml)
cRetXml := EncodeUTF8(cRetXml)

oXmlTeste := XmlParser( cRetXml, "_", @cError, @cWarning )

if Type("oXmlTeste") == "U"
	cRetXml := ""
Endif

Return( cRetXml )



User Function HFTXTPDF( aTxt )
Local aRet := {}
Local aCpo := {}
Local aPos := {}
Local cAux := ""
Local cCpc := ""
Local cDad := ""
Local nX, nY, nPos, nPim

if aTxt == NIL .And. type("PARAMIXB") == "A"
	aTxt  := &(AllTrim(PARAMIXB[1]))
endif

Private nLY := 0, xNiv := ""

nPim := 1

For nX := 1 To Len( aCfPdf )
	cCpc := AllTrim( aCfPdf[nX][10] )
	nLY  := nX
	For nY := nPim To Len(aTxt)
		aCpo := {}
		nPim := nY
		If cCpc $ aTxt[nY]
			If len(aTxt) >= nY+aCfPdf[nX][3]
				cAux := aTxt[nY+aCfPdf[nX][3]]
			Else
				cAux := aTxt[nY]
			EndIf
			cAux := AllTrim( cAux )
			cVarMem := aCfPdf[nX][7]
			&cVarMem. := cAux
			if !Empty( aCfPdf[nX][8] )
				cAux   := aCfPdf[nX][9]
				cAux   := strtran(cAux,"{","")
				cAux   := strtran(cAux,"}","")
				aParam := StrTokArr(cAux,";")
				if Type( "aParam" ) != "A"
					aParam := {}
				endif
				aCpo := ExecBlock( aCfPdf[nX][8], .F., .F., aParam )
			EndIf
            If aCfPdf[nX][2] == "N"
				&cVarMem. := aCpo[1][2]
				xNiv      := aCpo[1][2]  //Evitando a Fadiga
            Else
				For nPos := 1 To Len( aCpo )
					If ! Empty( aCpo[nPos][1] )
						aPos := U_HfCampos( aCpo[nPos][2], aCpo[nPos][1] )
						aadd( aRet, { aPos[1], aPos[2], aPos[3] } )
					EndIf
				Next nPos
			EndIf
			Exit
		EndIf

    Next nY

Next nX

Return( aRet )


User Function HFRPDLNH()
Local aRet  := {}
Local cLin  := &(AllTrim(PARAMIXB[1]))
Local cVar  := AllTrim(PARAMIXB[2])
Local cDad  := &(AllTrim(PARAMIXB[2]))
Local cAux  := ""
Local cBuf  := ""

Private nLTam := aCfPdf[nLY][5]
Private nLDec := aCfPdf[nLY][6]

Do Case
	Case cLin == "NIVEL"
		cBuf := AllTrim( aCfPdf[nLY][10] )
		aadd(aRet, {cVar,cBuf } )
	Case "NIVFX" $ cLin  //Para Jandira, Mas acho que os novos podemos usar todos assim
		cAux := AllTrim( strTran( cLin, "NIVFX=", "" ) )
		If cAux == "1"
			cBuf := "PRESTADOR DE SERVICOS"
		Else
			cBuf := "TOMADOR DE SERVICOS"
		EndIF
		aadd(aRet, {cVar,cBuf})
	Case cLin == "CNPJ"
		cBuf := convCnpj( cDad, 14 )
		If "PRESTADOR" $ xNiv // "PRESTADOR DE SERVICOS"
			aadd(aRet, {"xTPDOC" ,iif( len( alltrim(cBuf) ) < 14, "1", "2") } )
		Else                  // "TOMADOR DE SERVICOS"
			aadd(aRet, {"xTPDOCD",iif( len( alltrim(cBuf) ) < 14, "1", "2") } )
			if GetNewPar("XM_HFTSTPD","") <> ""
				cBuf := GetNewPar("XM_HFTSTPD","")
			endif
		Endif
		aadd(aRet, {cVar,cBuf } )
	Case cLin == "NFSE"
		cBuf := convCnpj( cDad )
		aadd(aRet, {cVar,cBuf } )
	Case cLin == "NFSEA"
		cBuf := convNfseA( cDad )
		aadd(aRet, {cVar,cBuf } )
	Case cLin == "NFSEB"
		cBuf := convNfseB( cDad )
		aadd(aRet, {cVar,cBuf } )
	Case cLin == "DTNF"
		cBuf := convDat( cDad, "1" )
		aadd(aRet, {cVar,cBuf })
	Case cLin == "DTNF2"
		cBuf := convDat( cDad, "2" )
		aadd(aRet, {cVar,cBuf })
	Case cLin == "VALOR"
		cBuf := convVal( cDad )
		aadd(aRet, {cVar,cBuf})
	Case "VALORB" $ cLin
		cAux := AllTrim( strTran( cLin, "VALORB=", "" ) )
		cBuf := convValB( cDad, cAux )
		aadd(aRet, {cVar,cBuf})
	Case "FIXO" $ cLin
		cBuf := AllTrim( strTran( cLin, "FIXO=", "" ) )
		aadd(aRet, {cVar,cBuf})
EndCase

Return( aRet )


//Converter CNPJ e Numero de NF Simples, somente com números
Static Function convCnpj( cDad )
Local cRet := ""
Local nI   := 0
Local nX   := 0
Local cLtr := ""

cDad := AllTrim( cDad )

For nI := 1 To Len( cDad )
	cLtr := Substr(cDad,nI,1)
	If cLtr $ "0123456789"
		cRet += cLtr
		nX++
		If nX >= nLTam
			Exit
		Endif
	Endif
Next nI

cRet := Substr( cRet + Space(nLTam) , 1, nLTam )

Return( cRet )

//Converter Numero de NFSe. Vai arredondar de acordo com o numero do CFG, porque no texto pode ter mais com zero a esquerda
Static Function convNfseA( cDad )
Local cRet := ""
Local nI   := 0
Local nX   := 0
Local cLtr := ""

cDad := AllTrim( cDad )

For nI := 1 To Len( cDad )
	cLtr := Substr(cDad,nI,1)
	If cLtr $ "0123456789"
		cRet += cLtr
		nX++
		If nX >= nLTam
			if len(cRet) > nLTam
				cRet := Substr(cRet,2,nLTam)
			endif
			if ( nI+1 > Len( cDad ) )
				Exit
			elseif Substr(cDad,nI+1,1) = " "
				Exit
			endif
		Endif
	Endif
Next nI

cRet := Substr( cRet + Space(nLTam) , 1, nLTam )

Return( cRet )

//Converter Numero de NFSe quando começa com o ano e um numero, mas tem que ser com o tamanho 9, para funfar
Static Function convNfseB( cDad )
Local cRet := ""
Local nI   := 0
Local nX   := 0
Local cLtr := ""
Local cNum := ""
Local lAno := .T.

cDad := AllTrim( cDad )

For nI := 1 To Len( cDad )
	cLtr := Substr(cDad,nI,1)
	If cLtr $ "/"
		lAno := .F.
	ElseIf cLtr $ "0123456789"
		if lAno
			cRet += cLtr
		Else
			cNum += cLtr
		EndIf
		nX++
		If nX >= nLTam
			Exit
		Endif
	Endif
Next nI

if Len( cRet ) < nLTam
	cNum := PADL( cNum, nLTam-Len(cRet), "0" )
	cRet := cRet + cNum
Else
	cRet := Substr( cRet + Space(nLTam) , 1, nLTam )
EndIf

Return( cRet )



// retorno 1 ->	20130122000000 recebe 22/01/2013 11 
// retorno 2 ->	20130122000000 recebe TRANQUEIRAS 22/01/2013 TRANQUEIRAS
Static Function convDat( cDad, cTipo )
Local cRet := ""
Local cLtr := ""
Local cAux := ""
Local dDat := ctod("")
Local nI   := 0
Local xPosition	

If cTipo == "1"
	cDad := AllTrim(cDad)        
	xPosition := At(BARRA,cDad)-2  //Inclusao Rodrigo o foda 26/07/2017 - devido a necessidade do municipio de IPOJUCA
	//cDad := SubsTr( cDad, 1, 10 )	
	cDad	:= substr(cDad,xPosition,10)

	dDat := ctod(cDad)

	cRet := StrZero( year( dDat ), 4, 0) + StrZero( month( dDat ), 2, 0 ) + StrZero( day( dDat ), 2, 0 ) + "000000"
ElseIF cTipo == "2"

	cDad := AllTrim( cDad )

	For nI := 1 To Len( cDad )
		cLtr := Substr(cDad,nI,1)
		If cLtr $ "0123456789/"
			cAux += cLtr
		Endif
	Next nI

	if Substr(cAux,1,1) = "/"
		cAux := SubsTr( cAux, 2, len(cAux) )
	endif
	cAux := SubsTr( cAux, 1, 10 )

	dDat := ctod(cAux)
	
	cRet := StrZero( year( dDat ), 4, 0) + StrZero( month( dDat ), 2, 0 ) + StrZero( day( dDat ), 2, 0 ) + "000000"

EndIf

Return( cRet )


//Converter Valores Simples
Static Function convVal( cDad )
Local cRet := ""
Local nI   := 0
Local nX   := 0
Local nVal := 0
Local cLtr := ""

cDad := AllTrim( cDad )

For nI := 1 To Len( cDad )
	cLtr := Substr(cDad,nI,1)
	If cLtr $ "0123456789,"
		cRet += cLtr
		nX++
	Endif
Next nI

cRet := StrTran(cRet,",",".")
nVal := Val( cRet )

cRet := StrZero(nVal,(nLTam+1),nLDec)
cRet := StrTran(cRet,".","")

Return( cRet )



//Converter Valores quando na linha do TXT tem mais de um valor e é separado por R$, no caso na leitura do TXT fica sómente o R.
//cDad -> é a Linha TXT
//cPos -> a posição do numero, verificando o R
Static Function convValB( cDad, cPos )
Local cRet := ""
Local nI   := 0
Local nVal := 0
Local cLtr := ""
Local nPos := Val( cPos )
Local nR   := 0

cDad := AllTrim( cDad )

For nI := 1 To Len( cDad )
	cLtr := Substr(cDad,nI,1)
	if cLtr $ "R"
		nR++
	ElseIf cLtr $ "0123456789,"
		If nR == nPos
			cRet += cLtr
		EndIf
	Endif
Next nI

cRet := StrTran(cRet,",",".")
nVal := Val( cRet )

cRet := StrZero(nVal,(nLTam+1),nLDec)
cRet := StrTran(cRet,".","")

Return( cRet ) 


//{xCNPJD,xIMDest}
User Function HFVL2XML()
Local lRet    := .T.
Local aArea   := GetArea()
Local nRecFil
Local cDocDest:= iif( Len(PARAMIXB)>=1, &(AllTrim(PARAMIXB[1])), "" )
Local cIMDest := iif( Len(PARAMIXB)>=2, &(AllTrim(PARAMIXB[2])), "" )
Local cIEDest := ""

DbSelectArea("SM0")
nRecFil := SM0->( Recno() )
SM0->( DbGotop() )
While !SM0->( Eof() )
	IF cDocDest == SM0->M0_CGC .And. AllTrim(SM0->M0_INSCM) = AllTrim( cIMDest )
		If ! Empty(SM0->M0_INSC)
			cIEDest := SM0->M0_INSC
			Exit
		EndIF
	EndIF
	SM0->( DbSkip() )
EndDO
SM0->( dbgoto(nRecFil) )

//aFilsEmp => Esta bagaça vem private do importa
//aFilsLic => Esta também
nFilScan := aScan(aFilsEmp,{|x| x[2] == cDocDest .and. AllTrim(x[5]) == AllTrim( cIEDest ) })
If nFilScan == 0
    nFilScan := aScan(aFilsEmp,{|x| x[2] == cDocDest })
EndIf

lRet := (nFilScan > 0)

If ! lRet
	cError := "Este XML não pertence a Empresa/Filial ! Código "+AllTrim(SM0->M0_CODIGO)+" "  +CRLF
	cOcorr := "Documento emitido para CNPJ/CPF diferente da empresa cadastrada."
    If !Empty(AllTrim(cOcorr+cError))
		//U_SdMailEr(1,"RP",oXml,cChv,cOcorr,cError,"")
		Conout(;
			cChv+CRLF+;
			cOcorr+CRLF+;
			cError+CRLF;
		)
	EndIf
EndIf

RestArea( aArea )
Return( nFilScan )





Static Function NoAcento(cString)
Local cChar  := ""
Local nX     := 0 
Local nY     := 0
Local cVogal := "aeiouAEIOU"
Local cAgudo := "áéíóú"+"ÁÉÍÓÚ"
Local cCircu := "âêîôû"+"ÂÊÎÔÛ"
Local cTrema := "äëïöü"+"ÄËÏÖÜ"
Local cCrase := "àèìòù"+"ÀÈÌÒÙ" 
Local cTio   := "ãõ"
Local cCecid := "çÇ"
Local lChar  := .F.

For nX:= 1 To Len(cString)
	cChar:=SubStr(cString, nX, 1)
	IF cChar$cAgudo+cCircu+cTrema+cCecid+cTio+cCrase
		nY:= At(cChar,cAgudo)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cCircu)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cTrema)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cCrase)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf		
		nY:= At(cChar,cTio)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("ao",nY,1))
		EndIf		
		nY:= At(cChar,cCecid)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("cC",nY,1))
		EndIf
	Endif
Next
For nX:=1 To Len(cString)
	cChar:=SubStr(cString, nX, 1)
	If Asc(cChar) < 32 .Or. Asc(cChar) > 123// .and. (cChar<> 10 .And. cChar<> 13)
		cString:=StrTran(cString,cChar,".")
	Endif
Next nX
Return cString

Return(cString)
