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

#DEFINE IMP_PDF 6
#DEFINE VALMERC	 01	// Valor total do mercadoria
#DEFINE VALDESC	 02	// Valor total do desconto
#DEFINE TOTPED	 03	// Total do Pedido
#DEFINE FRETE    04	// Valor total do Frete
#DEFINE VALDESP  05	// Valor total da despesa
#DEFINE SEGURO	 07	// Valor total do seguro

Static lUnix  := IsSrvUnix()
Static cBarra := Iif(lUnix,"/","\")


//NFCE_02 07/03 Rotinas para importar NF Servi็os Eletronica. A Come็ar Importar TXT de SP.
//NFCE_03 16/05 Pr้-Nota.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HFTXTCSV บAutor  ณ Eneo               บ Data ณ 07/03/2016  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Importa็ใo de TXT de NFSe - Notas Fiscais de Servi็os      บฑฑ
ฑฑบ          ณ Eletr๔nicas dos municํpios.                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Importa XML                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
/*User Function HFTXTCSV(lAuto,lEnd,oProcess,cLogProc,nCount)
Local lRet     := .T.
Local aArea    := GetArea()
Local aExt     := {}
Local aAux     := {}
Local cExt     := AllTrim(GetNewPar("XM_ARQ_NFS","NFSE"))
Local nM       := 0
Local nE       := 0

Private aMun     := {}
Private aRefMun  := {}
Private cDir     := "\"+AllTrim(GetNewPar("MV_X_PATHX",""))+"\"
Private lDirCnpj := AllTrim(GetNewPar("XM_DIRCNPJ","N")) == "S"
Private lDirFil  := AllTrim(GetNewPar("XM_DIRFIL" ,"N")) == "S"
Private lDirMod  := AllTrim(GetNewPar("XM_DIRMOD" ,"N")) == "S"
Private cDirDest := AllTrim(cDir+"Importados\")
Private cDirRej  := AllTrim(cDir+"Rejeitados\")
Private cIdEnt := U_GetIdEnt()

//Inicio aqui para linuxxx
	cDir     := Iif(lUnix,StrTran(cDir,"\","/"),cDir)
	cDirDest := Iif(lUnix,StrTran(cDirDest,"\","/"),cDirDest)
	cDirRej  := Iif(lUnix,StrTran(cDirRej,"\","/"),cDirRej)
//Fim aqui para linux

cDir           := StrTran(cDir,cBarra+cBarra,cBarra)
cDirDest       := StrTran(cDirDest,cBarra+cBarra,cBarra)
cDirRej        := StrTran(cDirRej,cBarra+cBarra,cBarra)

If !ExistDir(cDirDest)
	Makedir(cDirDest)
EndIf
If !ExistDir(cDirRej)
	Makedir(cDirRej)
EndIf             


//No futuro vamo bota isso configuradis, por arquivo, parโmetro ou sei la oque
aAux := LayCid()
if Empty( aAux )
	if lAuto
		Conout( "Arquivos de configura็๕es das notas de servi็o nใo encontrado (pasta cfg)" )
	Else
		U_MyAviso("Aten็ใo","Arquivos de configura็๕es das notas de servi็o nใo encontrado (pasta cfg)",{"OK"},3)
	Endif
	Return( lRet )
endif

aRefMun := aAux[1]
aMun    := aAux[2]

aExt := Separa(cExt,";")
aadd( aExt, "PDF" )
For nE := 1 To Len( aExt )
	IF AllTrim(GetNewPar("XM_USANFSE","N")) == "H" .And. UPPER( aExt[nE] ) $ "PDF"
		Loop //Farแ na outra rotina
	endif
	U_HFNFSESP(lAuto,@lEnd,oProcess,@cLogProc,@nCount,aExt[nE])  //NFCE_02 07/03. Para Evitar a Fadiga. Importar TXT/CSV de NF de Servi็os. A priori NF de SP.
Next nE

RestArea( aArea )
Return( lRet )*/


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ  LayCid  บAutor  ณ Eneo               บ Data ณ 30/08/2016  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna vetor com os LayOuts Disponํveis                   บฑฑ
ฑฑบ          ณ Eletr๔nicas dos municํpios.                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Importa XML                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LayCid()
Local aRet := {}
Local aLin := {}
Local aM01 := {}
Local aM02 := {}
Local nHandle := 0
Local cLay    := ""
Local nI      := 0
Local cLin    := ""

cLay := cDir+"cfg\nfse\LAYMUNIC.CFG"   //Parametrizar
if ! File( cLay )
	return( aRet )
endif

nHandle := FT_FUse( cLay )
if nHandle = -1
	return( aRet )
endif
FT_FGoTop()
While !FT_FEOF()
	cBuf := FT_FReadLn() // Retorna a linha corrente
	If Substr(cBuf,1,1) == "?"
		//comentแrio
	ElseIf Substr(cBuf,1,4) == "[M01"
		cLin := "P"
	ElseIf Substr(cBuf,1,4) == "[M02"
		cLin := "A"
	Else
		if cLin == "A"
			aLin := StrTokArr(cBuf,"|")
			For nI := 1 To Len( aLin )
				if nI == 3 .or. nI == 4 .or. nI == 6 .or. nI == 7
					aLin[nI] := Val( AllTrim(aLin[nI]) )
				Else
					aLin[nI] := AllTrim(aLin[nI])
				EndIf
			Next nI
			aadd( aM02, aLin )
		ElseIf cLin == "P"
			aLin := StrTokArr(cBuf,"|")
			For nI := 1 To Len( aLin )
				aadd( aM01, AllTrim(aLin[nI]) )
			Next nI
		EndIf
	EndIF

	FT_FSKIP()
End
FT_FUSE()

aRet := {}
aadd( aRet, aM01 )
aadd( aRet, aM02 )

Return( aRet )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HFTXTCSV บAutor  ณ Eneo               บ Data ณ 07/03/2016  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Importa็ใo de TXT de NFSe - Notas Fiscais de Servi็os      บฑฑ
ฑฑบ          ณ Eletr๔nicas dos municํpios.                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Importa XML                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function HFNFSESP(lAuto,lEnd,oProcess,cLogProc,nCount,cExtensao)
Local aArea    := GetArea()
Local nI       := 0
//Local cDir     := AllTrim(SuperGetMv("MV_X_PATHX"))
Local aFiles   := {}
Local aTxt     := {}
Local cOcorr   := ""
//Local aPref    := {"NFSE"} // Notas de Servic็ios em TXT
Local cArq     := "", cArq2 := ""
Local cFile    := ""
Local cRta     := ""
Local cDrive,cPath,cNewFile,cExt
Local cLin := ""
Local lRet := .T.
Local cError := "", cWarning := ""
Local ny   := 0

Private cAtu := ""  //arquivo de configuracione
Private cReg := "2", cRegi := "2"
Private aCfg := {} , aCfgT := {}, aParam := {}, aVar := {}  //Cfg NFS, Cfg NFTS, Parametros, Variaveis a declarar
Private aChv := {}, cChv
Private aVld := {}, lVld
Private aGrv := {}
Private aXml := {}
Private aRtPdf := {}
Private aCfPdf := {}
Private S_XML:= "" //Montar um XML aqui
Private S_PDF:= "" //Quando PDF, gravar o Bixo Aqui
Private nY   := 0
Private cNomFil := "" //aFilsEmp[nFilScan][3]
Private cVarMem, cVarZbz  
Private cCnpjEmit := ""
Private cBuf, cFileToWrite
Private nFilScan := 0  //essa baga็a tem preecher
Private lEhPdf := ( UPPER(AllTrim(cExtensao)) == "PDF" )
Private cPdf   := ""
Private lTemPre:= .F.

Default oProcess:= Nil

If !lAuto .Or. oProcess<>Nil
	oProcess:IncRegua1("Processando "+cExtensao+"...")
	oProcess:IncRegua2("Entidade : "+cIdEnt+" - Status Sefaz Ok...")

	aFiles	:=	Directory(cDir+"*."+cExtensao,"D")

	oProcess:SetRegua1(0)
	oProcess:SetRegua2(Len(aFiles))
Else
	aFiles	:=	Directory(cDir+"*."+cExtensao,"D")
EndIf
aSort( aFiles,,,{|x,y| x[1]<y[1] } )

For nI := 1 To Len(aFiles)
		cAtu := ""  //arquivo de configuracione
		cReg := ""
		aTxt := {}

		If lEhPdf
			cPdf  := AllTrim( aFiles[nI,1] )
			cPdf  := VerEspacos( cPdf )
			cArq2 := U_HFLEPDF( cPdf )
			cArq  := cDir+cArq2
			If Empty( cArq2 )
				cAtu  := ""
				cArq  := cPdf
			Else
				lTemPre:= .F.
				cAtu  := Descobrir( cAtu, cArq, "1", @aTxt )
			EndIf
		Else
			SplitPath(cDir+AllTrim(aFiles[nI,1]),@cDrive,@cPath, @cNewFile,@cExt)
			cArq    := cPath+cNewFile+cExt
			cAtu  := Descobrir( cAtu, cArq, "2" )
		EndIf
		If Empty( cAtu )
			If Empty( cArq2 )
				cLogProc += "O arquivo ["+aFiles[nI,1]+"] esta borrado nใo foi possํvel ler."+CRLF
			Else
				If lTemPre
					cLogProc += "O arquivo ["+aFiles[nI,1]+"] nใo pertence a nenhum municํpio homologado."+CRLF
				Else
					cLogProc += "O arquivo ["+aFiles[nI,1]+"] esta borrado ou nใo pertence a nenhum municํpio homologado."+CRLF
				EndIf
			Endif
			nErase := FErase(cArq)
			If nErase < 0
				cLogProc += "(EM USO) Nao foi possivel remover o arquivo ["+cArq+"]"+CRLF
			EndIf
			If lEhPdf
				nErase := FErase(cDir+cPdf)
				If nErase < 0
					cLogProc += "(EM USO) Nao foi possivel remover o arquivo ["+cPdf+"]"+CRLF
				EndIf
			EndIf
			Loop
		Endif

		cRta := carregaCfg( @cAtu )

		If cRta == "1"
			For nY := 1 To Len( aVar )
				//cVarMem   := aCfg[nY][8]
				cVarMem   := aVar[nY][1]
				if aVar[nY][2] == "C"
					Private &cVarMem. := ""
				Elseif aVar[nY][2] == "D"
					Private &cVarMem. := cTod( "" )
				EndIf
			Next nY
		Else
			cLogProc += "Nใo foi possํvel abrir arquivo CFG de layout de NFS-e ["+cAtu+"]"+CRLF
			Loop
		Endif

		If lEhPdf
			cPdf  := cDir+VerEspacos( AllTrim( aFiles[nI,1] ) )
			cFile := U_CONVTXTS( cArq2, aTxt )
		Else
			cPdf  := ""
			cFile := aFiles[nI,1]
		EndIf

		SplitPath(cDir+AllTrim(cFile),@cDrive,@cPath, @cNewFile,@cExt)
		cPref     := "XXX"
		cFilXml   := "XX"
		lCanc     := .F.
		lXmlsLic  := .F.

		cArq    := cPath+cNewFile+cExt

		//nHandle := FT_FUse( cArq )
		nHandle := fOpen(cArq ,48)  //0

		If nHandle = -1
			cLogProc += "Nใo foi possํvel abrir arquivo de NFS-e ["+cArq+"]"+CRLF
			Loop
		EndIf

		//FT_FGoTop()
		fSeek(nHandle,0,FS_SET)
		//While !FT_FEOF()
		While .T.
			//cBuf := FT_FReadLn() // Retorna a linha corrente
			cBuf 		:= U_HFLerLin(nHandle)[1]  //aLinha[1]
			if Empty( cBuf )  //FT_FEOF()
				Exit
			Endif
		 	if Substr(cBuf,1,len(cReg)) == cReg //"2" //Detalhe da NF
				For nY := 1 To Len( aCfg )
					cAux := Substr(cBuf,aCfg[nY][2],aCfg[nY][5]) 
					cVarMem   := aCfg[nY][8]
					&cVarMem. := cAux
					if !Empty( aCfg[nY][9] )
						cAux   := aCfg[nY][10]
						cAux   := strtran(cAux,"{","")
						cAux   := strtran(cAux,"}","")
						aParam := StrTokArr(cAux,";")
						if Type( "aParam" ) != "A"
							aParam := {}
						endif
						&cVarMem. := ExecBlock( aCfg[nY][9], .F., .F., aParam )
					endif
				Next nY

				if len(aChv) >= 1
					cAux   := aChv[02]
					cAux   := strtran(cAux,"{","")
					cAux   := strtran(cAux,"}","")
					aParam := StrTokArr(cAux,";")
					if Type( "aParam" ) != "A"
						aParam := {}
					endif
					cChv := ExecBlock( aChv[01], .F., .F., aParam )
				Else
					cChv := ""
				endif

				if len(aXml) >= 1
					cAux   := aXml[02]
					cAux   := strtran(cAux,"{","")
					cAux   := strtran(cAux,"}","")
					aParam := StrTokArr(cAux,";")
					if Type( "aParam" ) != "A"
						aParam := {}
					endif
					S_XML := ExecBlock( aXml[01], .F., .F., aParam )
				Else
					S_XML := ""
				endif
				if ! Empty(S_XML)
					oXml := XmlParser( S_XML, "_", @cError, @cWarning )
				else
					oXml := ""
				endif

				If Len( aVld ) > 0
					cAux   := aVld[02]
					cAux   := strtran(cAux,"{","")
					cAux   := strtran(cAux,"}","")
					aParam := StrTokArr(cAux,";")
					if Type( "aParam" ) != "A"
						aParam := {}
					endif
					nFilScan := ExecBlock( aVld[01], .F., .F., aParam )
				Else
					nFilScan := 0
					//msg aqui.
				EndIf
				If nFilScan > 0
					lVld := .T.
 				Else
					lVld := .F.
					If lEhPdf
						cLogProc += "Este PDF nใo pertence a Empresa/Filial ! C๓digo "+AllTrim(SM0->M0_CODIGO)+" ["+cPdf+"]"+CRLF
					EndIF
				EndIf
				if lEhPdf
					S_PDF := Ler_O_PDF( cPdf )
				Endif

				if .Not. Empty(cChv) .AND. lVld
					GraZbzNfs(@cLogProc)
					cCnpjEmit := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ")))
				else
//					cCnpjEmit := cChv
				endIf

				If Len( aGrv ) > 0
					cFileToWrite := cBuf
					cAux   := aGrv[02]
					cAux   := strtran(cAux,"{","")
					cAux   := strtran(cAux,"}","")
					aParam := StrTokArr(cAux,";")
					if Type( "aParam" ) != "A"
						aParam := {}
					endif
					ExecBlock( aGrv[01], .F., .F., aParam )
				EndIf

			endif
			//cRet := cRet + cBuf
			//FT_FSKIP()
		End

		//FT_FUSE()
		FClose(nHandle)
		nErase := FErase(cArq)
		If nErase < 0
			cLogProc += "(EM USO) Nao foi possivel remover o arquivo ["+cArq+"]"+CRLF
		EndIf
		If lEhPdf
			nErase := FErase(cPdf)
			If nErase < 0
				cLogProc += "(EM USO) Nao foi possivel remover o arquivo ["+cPdf+"]"+CRLF
			EndIf
		EndIf

Next nI

RestArea( aArea )
Return( lRet )


Static Function VerEspacos( cPdf )
Local cRet := cPdf
cRet := StrTran( cRet, "   ", "")
cRet := StrTran( cRet, "  ", "")
cRet := StrTran( cRet, " ", "")

If cRet <> cPdf .And. File(cDir+cPdf)
	__CopyFile( cDir+cPdf, cDir+cRet ) //Copia o Pdf para o smartclient
	FErase(cDir+cPdf)
EndIf

Return( cRet )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GraZbzNfsบAutor  ณ Eneo               บ Data ณ 20/04/2016  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gravar na Tabela ZBZ o arquivo como se fosse um XML.       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Importa XML                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GraZbzNfs(cLogProc)
Local cChaveXml := cChv
Local nI        := 1
Local lAppend   := .T.
Local cCpo      := ""
Local cDad      := ""
Local cNomFil   := ""
Local cCodEmit  := ""
Local cLojaEmit := ""
Local cRazao    := ""

Private nFormNfe := Val(GetNewPar("XM_FORMNFE","6"))
Private cFilNova := xFilial()
//aFilsEmp => Esta baga็a vem private do importa
//aFilsLic => Esta tamb้m
//nFilScan := aScan(aFilsEmp,{|x| x[2] == cDocDest .and. AllTrim(x[5]) == AllTrim( cIEDest ) })
cFilXMLAtu := cFilAnt
If nFilScan > 0
   	cFilAnt   := aFilsEmp[nFilScan][1]
    cFilNova  := aFilsEmp[nFilScan][1]
    cNomFil   := aFilsEmp[nFilScan][3]
	cFilXML   := cFilAnt			
EndIF

	DbSelectArea( xZBZ )
	dbSetORder(3)
	If !DbSeek(alltrim(cChaveXml)) .Or. (!lAppend) .Or. (DbSeek(alltrim(cChaveXml)) .And. (xZBZ)->(FieldGet(FieldPos(xZBZ_+"STATUS")))="2")                           
			Reclock(xZBZ,lAppend)
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CHAVE"), cChaveXml))  //Colocado no ํnicio para evitar a Fadiga
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"FILIAL"), cFilAnt))
			For nI := 1 To Len( aCfg )
				if Empty( aCfg[nI][7] )
					Loop
				EndIF
				cVarMem := AllTrim( aCfg[nI][8] )
				cCpo    := xZBZ_ + AllTrim(Substr(aCfg[nI][7],5,6))
				if AllTrim(Substr(aCfg[nI][7],5,6)) == "NOTA" .And. nFormNfe > 0 .And. nFormNfe >= Len( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA"))) )
					cDad    := &(cVarMem)
					if ! Empty(cDad)
						cDad    := StrZero(Val(&(cVarMem)),nFormNfe)
					endif
				ELse
					cDad    := &(cVarMem)
				EndIF
				if .NOT. Empty( cDad ) //pa num fude o campo Numero da NF quando for RPS sem estar em branco o numero da nota
					(xZBZ)->(FieldPut(FieldPos(cCpo), cDad))
				endif
			Next nI
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"MODELO"), "RP" ))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"STATUS"), "1"))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PRENF"), "B" ))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"SERORI"), (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE"))) ))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"SERIE"), U_vSerie( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE"))), cFilAnt, .F. ) ))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"DTRECB"), dDataBase))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CLIENT"), cNomFil))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"XML"), S_XML))

			VerFor((xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))),@cCodEmit,@cLojaEmit,@cRazao)

			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"FORNEC"), cRazao))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CODFOR"), cCodEmit))		
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"LOJFOR"), cLojaEmit))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPDOC"), "N" ))
			If (xZBZ)->(FieldPos(xZBZ_+"FORPAG"))>0    //GETESB
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"FORPAG"), "1" ))
			EndIF
	 		If (xZBZ)->(FieldPos(xZBZ_+"MAIL"))>0
		   		(xZBZ)->(FieldPut(FieldPos(xZBZ_+"MAIL"), "0"))
//		   		(xZBZ)->(FieldPut(FieldPos(xZBZ_+"DTMAIL"), cInfoErro))	   		
			EndIf
			if lEhPdf .And. type("S_PDF") = "C"
				if (xZBZ)->(FieldPos(xZBZ_+"PDF"))>0 
					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PDF"), S_PDF))
				endif
			endif

/*
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"OBS"), cMensagem+CRLF+cError+CRLF+cWarning+CRLF+cOcorr))
				if Type( cTagTpPag ) <> "U"
					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"FORPAG"), &(cTagTpPag) ))
				else
				endif
			Endif
			If (xZBZ)->(FieldPos(xZBZ_+"CONDPG"))>0    //GETESB
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CONDPG"), U_HF02CPG() ))
			EndIf
			If (xZBZ)->(FieldPos(xZBZ_+"TPEMIS"))>0 .And. (xZBZ)->(FieldPos(xZBZ_+"TPAMB"))>0 
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPEMIS"), &(cTagTpEmiss) )) 
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPAMB"), &(cTagTpAmb) ))
			EndIf
			If (xZBZ)->(FieldPos(xZBZ_+"TOMA"))>0 .And. (xZBZ)->(FieldPos(xZBZ_+"DTHRCS"))>0
		   		(xZBZ)->(FieldPut(FieldPos(xZBZ_+"TOMA"), cTipoToma))
		   		(xZBZ)->(FieldPut(FieldPos(xZBZ_+"DTHRCS"), cDtHrCOns))
			EndIf
			If (xZBZ)->(FieldPos(xZBZ_+"PROT"))>0 
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PROT"), cProtocolo))
			EndIf				
	 		If (xZBZ)->(FieldPos(xZBZ_+"VERSAO"))>0
		   		(xZBZ)->(FieldPut(FieldPos(xZBZ_+"VERSAO"), cVerXml))
			EndIf				        
			if (xZBZ)->(FieldPos(xZBZ_+"MANIF")) > 0 //GETESB2
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"MANIF"), xManif ))
			endif
*/
			MsUnLock()
			cLogProc += "[XML] "+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))) +" importado com sucesso."+CRLF
			DbSelectArea(xZBZ)
			/*if aHfCloud[1] == "1"
				U_HFCLDEnv(,,,"1")
			EndIF*/
	EndIf

	cKeyXml := cChaveXml
	cFilAnt := cFilXMLAtu

Return( NIL )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HFGRVTXT บAutor  ณ Eneo               บ Data ณ 02/05/2016  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gravar TXT na Pasta xmlsource.                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Importa XML                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function HFGRVTXT
Local cNewFile := AllTrim(cChv)
Local cCnpjEmit:= &(AllTrim(PARAMIXB[1]))
Local _cDirRej := cDirRej
Local _cDirDest:= cDirDest


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Pasta XMLSOURCE, Se nใo integra com n๚vem GRAVA; Se integra e for Tipo <P> que Grava Arquivo na Pasta XMLSOURCE ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
IF aHfCloud[1] == "0" .or. aHfCloud[3] == "P"   //CRAUNDE, VEM LA DO INICIO DO BRAUZE

	If lDirMod
		_cDirRej := _cDirRej + "NFSE" + cBarra
		_cDirDest:= _cDirDest + "NFSE" + cBarra
		If !ExistDir(_cDirDest)
			Makedir(_cDirDest)
		EndIf
		If !ExistDir(_cDirRej)
			Makedir(_cDirRej)
		EndIf
	EndIf

	If lDirFil
		_cDirRej := _cDirRej + cFilXml+cBarra
		_cDirDest:= _cDirDest + cFilXml+cBarra
		If !ExistDir(_cDirDest)
			Makedir(_cDirDest)
		EndIf
		If !ExistDir(_cDirRej)
			Makedir(_cDirRej)
		EndIf
	EndIf

	If lDirCnpj
		_cDirRej := _cDirRej + cCnpjEmit + cBarra
		_cDirDest:= _cDirDest + cCnpjEmit + cBarra
		If !ExistDir(_cDirDest)
			Makedir(_cDirDest)
		EndIf
		If !ExistDir(_cDirRej)
			Makedir(_cDirRej)
		EndIf	
	EndIf

	If .NOT. lVld
		cFinalF:= _cDirRej+cNewFile+"-"+"NFSE.TXT"
	Else
		cFinalF:= _cDirDest+cNewFile+"-"+"NFSE.TXT"
	EndIf
	//if ! GravarComFRead(cFinalF,cFileToWrite)
		MemoWrite(cFinalF,cFileToWrite)
	//EndIF
	If .NOT. Empty(S_XML)
		cFinalF:= _cDirDest+cNewFile+"-"+"NFSE.XML"
		MemoWrite(cFinalF,S_XML)
	EndIf
	If lEhPdf  //esse cabra aqui tem dar um UPLOAD para a NฺVI
		cFinalF:= _cDirDest+cNewFile+"-"+"NFSE.PDF"
		__CopyFile( cPdf, cFinalF )  //__CopyFile( cDir+cPdf, cFinalF )
	EndIf
ENDIF

Return( NIl )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ  VerFor  บAutor  ณ Eneo               บ Data ณ 02/05/2016  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verificar c๓digo do fornecedor.                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Importa XML                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VerFor(cCnpjEmi,cCodEmit,cLojaEmit,cRazao)
Local aArea     := GetArea()
Local cFilSeek  := ""
Local lSharedA2 := U_IsShared("SA2")

DbSelectArea("SA2")
DbSetOrder(3)
cFilSeek := Iif(lSharedA2,xFilial("SA2"),cFilNova)
					If DbSeek(cFilSeek+cCnpjEmi)
						cCodEmit  := SA2->A2_COD
						cLojaEmit := SA2->A2_LOJA
					    cRazao    := SA2->A2_NOME
						Do While .not. SA2->( eof() ) .and. SA2->A2_FILIAL == cFilSeek .and.;
						               SA2->A2_CGC == cCnpjEmi
							if SA2->A2_MSBLQL != "1"
								cCodEmit  := SA2->A2_COD
								cLojaEmit := SA2->A2_LOJA
							    cRazao    := SA2->A2_NOME
								exit
							endif
							SA2->( dbSkip() )
						EndDo
		    		Else
						cCodEmit  := ""
						cLojaEmit := ""
					    cRazao    := ""		    		
		    		EndIf

RestArea( aArea )
Return( .T. )


Static Function Ler_O_PDF( cPdf )
Local nHandle := 0
Local cRet    := ""
Local cBuf    := "" 
Local cEncode64 := ""

//nHandle := fOpen(cPdf ,48)  //0
nHandle := FT_FUse( cPdf )

If nHandle = -1
	cRet := "NใoFoiPossivelAbrirPDF_"+AllTrim(cPdf)+"."
	Return( cRet )
EndIf

FT_FGoTop()
//fSeek(nHandle,0,FS_SET)
While !FT_FEOF()
//While .T.
	cBuf := FT_FReadLn() // Retorna a linha corrente
	//cBuf 		:= U_HFLerLin(nHandle)[1]  //aLinha[1]
	//if FT_FEOF()  //Empty( cBuf )  //FT_FEOF()
	//	Exit
	//Endif
	cRet := cRet + cBuf
	FT_FSKIP()
End
FT_FUSE()
//FClose(nHandle)
If Empty(cRet)
	cRet := "PDF_Vazio_"+AllTrim(cPdf)+"."
Else
	//cRet := Encode64(cRet)
	cRet := EncodeUTF8(cRet)
EndIf

Return( cRet )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HFPRNNFS บAutor  ณ Eneo               บ Data ณ 16/05/2016  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Montagem do aItens da NF de Servi็o modelo RP (TXT)        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Importa XML                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function HFPRNNFS(nErrItens)
Local lRetorno   := .T.
Local lXMLPEAMA  := ExistBlock( "XMLPEAMA" ), aPEAma, lAmaPe := .F. //nordsonAmarraCof
Local lXMLPEITE  := ExistBlock( "XMLPEITE" )
Local lXMLPELOK  := .F. //ExistBlock( "XMLPELOK" )
Local lXMLPETOK  := .F. //ExistBlock( "XMLPETOK" )
Local lLOk 		 := .F.
Local lTOk 		 := .F.
Local nTamProd   := TAMSX3("B1_COD")[1]
Local cNfeElet   := ""
Local aProdOk   := {}
Local aProdNo   := {}
Local aProdVl   := {}
Local aProdZr   := {}
Local nCC  := TAMSX3("D1_CC")[1]

Private cTagPrd := ""

	oDet := oXml:_NFSETXT:_INFPROC
	//oDet := IIf(ValType(oDet)=="O",{oDet},oDet)
	cTagPrd   := "oXml:_NFSETXT:_INFPROC:_PRODSRV:TEXT"
	if Type( cTagPrd ) <> "U"
		cProdNfse := &cTagPrd.
	Else
		cProdNfse := ""
	EndIf

	If Empty( cProdNfse )
		cProdNfse := Padr(GetNewPar("XM_PRODNFS","SERVICO"),nTamProd)
    	cProdNfse :=Iif(Empty(cProdNfse),Padr("SERVICO",nTamProd),cProdNfse)
	EndIF

	If Type( "oDet:_RPS:TEXT" ) <> "U"
		cNfeElet := oDet:_RPS:TEXT
	EndIf
	If aScan( aCabec, {|x| x[1] == "F1_NFELETR" } ) == 0
		aadd(aCabec,{"F1_NFELETR",cNfeElet })
	Endif

	If lXMLPEAMA   //PE para Amarra็ใo de podrutos //nordsonAmarraCof
			aPEAma := ExecBlock( "XMLPEAMA", .F., .F., { oDet,1,cProdNfse,cModelo,cTipoCPro } )
			if aPEAma == NIL .or. ValType(aPEAma) <> "A"
				cProduto := ""
				lAmaPe := .F.
			Else
				if len(aPEAma) >= 1
					cProduto := aPEAma[1]
				Else
					cProduto := ""
				endif
				if len(aPEAma) >= 2
					if .NOT. Empty(cProduto)
						aadd( aProdOk, aPEAma[2] )
					Else
						aadd( aProdNo, aPEAma[2] )
					Endif
				else
					if .NOT. Empty(cProduto)
						aadd( aProdOk, {cProdNfse,"SERVICO "+oDet[i]:_CNPJ:TEXT} )
					Else
						aadd( aProdNo, {cProdNfse,"SERVICO "+oDet[i]:_CNPJ:TEXT} )
					Endif
				endif
				lAmaPe := .T.
			endif
	Else
			lAmaPe := .F.
	EndIf


	If cTipoCPro == "2" .And. ! lAmaPe // Ararracao Customizada ZB5 Produto tem que estar Amarrados Tanto Cliente como Formecedor
		cProduto := ""

		DbSelectArea(xZB5)
		DbSetOrder(1)
		// Filial + CNPJ FORNECEDOR + Codigo do Produto do Fornecedor
		If DbSeek(xFilial(xZB5)+PADR((xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))),14)+cProdNfse)
			cProduto := (xZB5)->(FieldGet(FieldPos(xZB5_+"PRODFI"))) //ZB5->ZB5_PRODFI
			lRetorno := .T.
			aadd(aProdOk,{cProdNfse,"PRESTACAO DE SERVICO - SERVICO"} )
		Else
			aadd(aProdNo,{cProdNfse,"PRESTACAO DE SERVICO - SERVICO"} )
		EndIf

	//##################################################################
	ElseIf cTipoCPro == "1"  .And. ! lAmaPe  //nordsonAmarraCof// Amarracao Padrao SA5/SA7

		cProduto  := ""
		if empty( cCodEmit )
			cCodEmit  := Posicione("SA2",3,xFilial("SA2")+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))),"A2_COD")
			cLojaEmit := Posicione("SA2",3,xFilial("SA2")+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))),"A2_LOJA")
		endif

		cAliasSA5 := GetNextAlias()

		cWhere := "%(SA5.A5_CODPRF IN ("
		cWhere += "'"+AllTrim(cProdNfse)+"'"
		cWhere += ") )%"

		BeginSql Alias cAliasSA5

		SELECT	A5_FILIAL, A5_FORNECE, A5_LOJA, A5_CODPRF, A5_PRODUTO, R_E_C_N_O_ 
				FROM %Table:SA5% SA5
				WHERE SA5.%notdel%
	    		AND A5_FORNECE = %Exp:cCodEmit%
	    		AND A5_LOJA = %Exp:cLojaEmit%
	    		AND %Exp:cWhere%
	    		ORDER BY A5_FILIAL, A5_FORNECE, A5_LOJA, A5_CODPRF
		EndSql

		DbSelectArea(cAliasSA5)
		Dbgotop()
        lFound := .F.
        cKeySa5:= xFilial("SA5")+cCodEmit+cLojaEmit+cProdNfse
        While !(cAliasSA5)->(EOF())
			cKeyTMP := (cAliasSA5)->A5_FILIAL+(cAliasSA5)->A5_FORNECE+(cAliasSA5)->A5_LOJA+(cAliasSA5)->A5_CODPRF
			If 	AllTrim(cKeySa5) == AllTrim(cKeyTMP)
        		lFound := .T.
        		Exit
        	Endif
        	(cAliasSA5)->(DbSkip())
        Enddo


		If lFound
			cProduto := (cAliasSA5)->A5_PRODUTO

			lRetorno := .T.
			aadd(aProdOk,{cProduto,"PRESTACAO DE SERVICO - SERVICO"} )
		Else
			//cProduto := cProdNfse
			aadd(aProdNo,{cProdNfse,"PRESTACAO DE SERVICO - SERVICO"} )
		EndIf

		DbCloseArea()


	//##################################################################
	ElseIf cTipoCPro = "3" // Mesmo Codigo Nao requer amarracao SB1
		DbSelectArea("SB1")
		DbSetOrder(1)
		If DbSeek(xFilial("SB1")+cProdNfse)
			cProduto := Substr(cProdNfse,1,nTamProd)
			lRetorno := .T.
			aadd(aProdOk,{cProdNfse,"PRESTACAO DE SERVICO - SERVICO"} )
		Else
			aadd(aProdNo,{cProdNfse,"PRESTACAO DE SERVICO - SERVICO"} )
		EndIF
	EndIf

		aLinha := {}
		aadd(aLinha,{"D1_ITEM" ,"0001"                  ,Nil})
		aadd(aLinha,{"D1_COD"  ,cProduto                ,Nil})
		aadd(aLinha,{"D1_QUANT",1                       ,Nil})
		aadd(aLinha,{"D1_VUNIT",VAL(ConvNum(oDet:_VRSERV:TEXT)) ,Nil})
		aadd(aLinha,{"D1_TOTAL",VAL(ConvNum(oDet:_VRSERV:TEXT)) ,Nil})
		if cPCSol == "S"  //Centro de Custo do Pedido, entใo manda vazio para pegar do pedido ao relacionar o pedido F5 ou F6
			aadd(aLinha,{"D1_CC"    ,nCC 					 ,Nil})
		else
			if .not. empty( cProduto ) .And. SB1->( DbSeek(xFilial("SB1")+cProduto) )
				aadd(aLinha,{"D1_CC",SB1->B1_CC					 ,Nil})
			endif
		endif

		If lXMLPEITE   //PE para incluir campos no aLinha SD1 -> para o aItens
			aRet :=	ExecBlock( "XMLPEITE", .F., .F., { cProduto,oDet,1 } )
			If ValType(aRet) == "A"
				AEval(aRet,{|x| AAdd(aLinha,x)})
			EndIf
		endif

		aadd(aItens,aLinha)

	If .not. empty( cProduto )
		SB1->( dbSetORder( 1 ) )
		if SB1->( DbSeek(xFilial("SB1")+cProduto) )
			If SB1->( FieldGet(FieldPos("B1_MSBLQL")) ) == "1"
				aadd(aProdNo,{cProduto,"Produto Bloqueado SB1->"+SB1->B1_DESC} )
			EndIf
		ElseIf cTipoCPro != "3"
			aadd(aProdNo,{cProduto,"Nใo Cadastrado SB1->"+"PRESTACAO DE SERVICO - SERVICO"} )
		EndIf
	EndIf

	if VAL(ConvNum(oDet:_VRSERV:TEXT)) <= 0
		aadd(aProdZr, { "0001", cProdCte, cProduto, VAL(ConvNum(oDet:_VRSERV:TEXT)), "PRESTACAO DE SERVICO - SERVICO" } )
	endif


	aLinha := {}

	if .not. U_HFITNENC( "PREN", aProdOk, aProdNo, aProdVl, @nErrItens, aProdZr )
	    lRetorno := .F.
	    Return( lRetorno )
	endif

	cChaveF1 := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))) + (xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA"))) +;
	            (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE")))  + (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR"))) +;
	            (xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR"))) + (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC")))

	//cChaveF1 := ZBZ->ZBZ_FILIAL + ZBZ->ZBZ_NOTA + ZBZ->ZBZ_SERIE + ZBZ->ZBZ_CODFOR + ZBZ->ZBZ_LOJFOR + ZBZ->ZBZ_TPDOC

	DbSelectArea("SF1")
	DbSetOrder(1)

	lSeekNF := DbSeek(cChaveF1)

	If !lSeekNF 

		SF1->( DbSetORder(8) )  //F1_FILIAL + F1_CHNFE
		lSeekNF := DbSeek( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL")))+Trim((xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE")))) )
		SF1->( DbSetORder(1) )

	EndIF

	If !lSeekNf
		If (xZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF"))) $ "N|S"
			lOkGo := MsgYesNo("Pr้-nota gerada previamente mas foi excluida.Deseja prosseguir gerando novamente?","Aviso")
			If !lOkGo
				lRetorno := .F.
			EndIf
		EndIf
	Else
		U_MyAviso("Aten็ใo","Esta XML jแ possui nota!"+CRLF +"Chave :"+cChaveF1,{"OK"},3)
		lRetorno := .F.
	EndIf

Return( lRetorno )



Static Function carregaCfg( cCfg )
Local cArqCfg := ""
Local nCfg := 0
Local cVrX := ""
Local cTpX := ""
Local aLin := {}
Local nI := 0

aChv   := {}  //Private la de Riba
aVld   := {}  //Private la de Riba
aGrv   := {}  //Private la de Riba
aXml   := {}  //Private la de Riba
aCfg   := {}  //Private la de Riba NFS
aCfgT  := {}  //Private la de Riba NFTS
aVar   := {}  //Private la de Riba Variaveis a Declarar, de acordo com aCfg e aCfgT
aRtPdf := {}  //Private la de Riba
aCfPdf := {}  //Private la de Riba

cArqCfg    := cDir+"cfg\nfse\"+cCfg   //Parametrizar
nCfg       := FT_FUse( cArqCfg )
if nCfg = -1
	return( "-1" )
endif
FT_FGoTop()
While !FT_FEOF()
	cBuf := FT_FReadLn() // Retorna a linha corrente
	if Substr(cBuf,1,1) == "?"
		cLin := "C"
	elseif Substr(cBuf,1,4) == "[R02"
		cLin := "D"
	elseif Substr(cBuf,1,4) == "[R04"
		cLin := "T"
	elseif Substr(cBuf,1,4) == "[C01"
		cLin := "Y"
	elseif Substr(cBuf,1,4) == "[V01"
		cLin := "V"
	elseif Substr(cBuf,1,4) == "[G01"
		cLin := "G"
	elseif Substr(cBuf,1,4) == "[X01"
		cLin := "X"
	elseif Substr(cBuf,1,4) == "[P01"
		cLin := "P1"
	elseif Substr(cBuf,1,4) == "[P02"
		cLin := "P2"
	Else
		if cLin == "Y"
			aChv := {}
			aadd( aChv, AllTrim(Substr(cBuf,01,8)) )
			aadd( aChv, AllTrim(Substr(cBuf,10,len(cBuf))) )
		elseif cLin == "V"
			aVld := {}
			aadd( aVld, AllTrim(Substr(cBuf,01,8)) )
			aadd( aVld, AllTrim(Substr(cBuf,10,len(cBuf))) )
		elseif cLin == "G"
			aGrv := {}
			aadd( aGrv, AllTrim(Substr(cBuf,01,8)) )
			aadd( aGrv, AllTrim(Substr(cBuf,10,len(cBuf))) )
		elseif cLin == "X"
			aXml := {}
			aadd( aXml, AllTrim(Substr(cBuf,01,8)) )
			aadd( aXml, AllTrim(Substr(cBuf,10,len(cBuf))) )
		elseif cLin == "D"
			aLin := {}
			aadd( aLin, Val(Substr(cBuf, 1,03)) )
			aadd( aLin, Val(Substr(cBuf, 5,04)) )
			aadd( aLin, Val(Substr(cBuf,10,04)) )
			aadd( aLin, Substr(cBuf,15,01) )
			aadd( aLin, Val(Substr(cBuf,17,03)) )
			aadd( aLin, Val(Substr(cBuf,21,01)) )
			aadd( aLin, AllTrim(Substr(cBuf,23,10)) )
			aadd( aLin, AllTrim(Substr(cBuf,34,10)) )
			aadd( aLin, AllTrim(Substr(cBuf,45,8)) )
			aadd( aLin, AllTrim(Substr(cBuf,54,len(cBuf))) )

			aadd( aCfg, aLin )
			cVrX := AllTrim(Substr(cBuf,34,10))
			cTpX := Substr(cBuf,15,01)
			if !Empty(cVrX) .And. ( Empty( aVar ) .Or. aScan( aVar, {|x| x[1] = cVrX } ) == 0 )
				aadd( aVar, {cVrX, cTpX } )
			Endif
			cRegi := AllTrim(Str(Val(Substr(cBuf, 3,02))))
		elseif cLin == "T"
			aLin := {}
			aadd( aLin, Val(Substr(cBuf, 1,03)) )
			aadd( aLin, Val(Substr(cBuf, 5,04)) )
			aadd( aLin, Val(Substr(cBuf,10,04)) )
			aadd( aLin, Substr(cBuf,15,01) )
			aadd( aLin, Val(Substr(cBuf,17,03)) )
			aadd( aLin, Val(Substr(cBuf,21,01)) )
			aadd( aLin, AllTrim(Substr(cBuf,23,10)) )
			aadd( aLin, AllTrim(Substr(cBuf,34,10)) )
			aadd( aLin, AllTrim(Substr(cBuf,45,8)) )
			aadd( aLin, AllTrim(Substr(cBuf,54,len(cBuf))) )

			aadd( aCfgT, aLin )
			cVrX := AllTrim(Substr(cBuf,34,10))
			cTpX := Substr(cBuf,15,01)
			if !Empty(cVrX) .And. ( Empty( aVar ) .Or. aScan( aVar, {|x| x[1] = cVrX } ) == 0 )
				aadd( aVar, {cVrX, cTpX } )
			Endif
//			cRegi := AllTrim(Str(Val(Substr(cBuf, 3,02))))
		elseif cLin == "P1"
			aRtPdf := {}
			aadd( aRtPdf, AllTrim(Substr(cBuf,01,8)) )
			aadd( aRtPdf, AllTrim(Substr(cBuf,10,len(cBuf))) )
		elseif cLin == "P2"
			aLin := {}
			aLin := StrTokArr(cBuf,"|")
			For nI := 1 To Len( aLin )
				if nI == 3 .or. nI == 5 .or. nI == 6
					aLin[nI] := Val( AllTrim(aLin[nI]) )
				Else
					aLin[nI] := AllTrim(aLin[nI])
				EndIf
			Next nI
			//aLin := {}
			//aadd( aLin, Val(Substr(cBuf, 1,03)) )
			//aadd( aLin, Val(Substr(cBuf, 5,04)) )
			//aadd( aLin, Val(Substr(cBuf,10,04)) )
			//aadd( aLin, Substr(cBuf,15,01) )
			//aadd( aLin, Val(Substr(cBuf,17,03)) )
			//aadd( aLin, Val(Substr(cBuf,21,01)) )
			//aadd( aLin, AllTrim(Substr(cBuf,23,10)) )
			//aadd( aLin, AllTrim(Substr(cBuf,34,8)) )
			//aadd( aLin, AllTrim(Substr(cBuf,43,len(cBuf))) )

			aadd( aCfPdf, aLin )
		endif
	endif
	FT_FSKIP()
End

FT_FUSE()

Return( "1" )


Static Function Descobrir( cCfg, cArq, cTipo, aTxt )
Local cRet := "" //cCfg
Local nI   := 0
Local cUf  := ""
Local cMun := ""
Local lEnc := .F.
Local nTam := 0
Local cEOL := CHR(13)+CHR(10)
Local nHandle,nLength

Default aTxt := {}

If cTipo == "1"  //PDF
	nHandle := FT_FUse( cArq )
	If nHandle = -1
		Return( "" )
	EndIf

	FT_FGoTop()

	While !FT_FEOF()
		cBuf := FT_FReadLn() // Retorna a linha corrente
		cVal := fRAcento(cBuf)
		aadd( aTxt, AllTrim(Upper(cVal)) )

   		FT_FSKIP()
	End

	FT_FUSE()

	//Descobriire o Municํpio
	cRet := HFDESCMUN( aTxt ) //retorna o arquivinho
	
Else
	nHandle := fOpen(cArq ,0)  //48

	If nHandle = -1
		Return( "" )
	EndIf

	For nI := 1 To Len( aMun )
		lEnc := .F.
		fSeek(nHandle,0,FS_SET)
		While .T.
			//aLinha		:= U_HFLerLin(nHandle)
			cBuf 		:= U_HFLerLin(nHandle)[1]  //aLinha[1]
			if Empty( cBuf )  //EOF
				Exit
			Endif
			//nLidosBco 	:= aLinha[2]
			//nLeitura++
	 		if Empty(aMun[nI][2]) .OR. Substr(cBuf,1,len(aMun[nI][2])) == aMun[nI][2] //Detalhe da NF
				cUf  := Upper( AllTrim( Substr(cBuf,aMun[nI][3],aMun[nI][4]) ) )
				cMun := Upper( AllTrim( Substr(cBuf,aMun[nI][6],aMun[nI][7]) ) )
	 			If cUf == Upper( AllTrim(aMun[nI][5]) ) .AND. cMun $ Upper( AllTrim(aMun[nI][9]) )
	 				lEnc := .T.
	 				Exit
	 			ElseIf Substr(cBuf,1,len(aMun[nI][2])) == aMun[nI][2]
	 				Exit //Sair p/pegar pr๓ximo aMun. Agora se o aMun[nI][2] for vazio verificar o arquivo todo.
	 			EndIf
	 		EndIf
	 		//FT_SKIP()
		End
		If lEnc
			cRet := aMun[nI][1]
			cReg := aMun[nI][2]
			Exit
		EndIf
	Next nI

	Fclose(nHandle)
EndIF

Return cRet


Static Function HFDESCMUN( aTxt )
Local cRet := ""
Local aRet := {}
Local aMumia := {}
Local nI, nZ
Local nX, nY

For nI := 1 To Len( aTxt )

	For nZ := 1 To Len( aRefMun )  //private aRefMun do lay cid
		//If "PREFEITURA" $ Upper( aTxt[nI] ) .or. "ESTANCIA TURISTICA" $ Upper( aTxt[nI] )
		If aRefMun[nZ] $ Upper( aTxt[nI] )
			lTemPre := .T. //Vinda como private
			For nX := 1 To Len( aMun )  //private aMun do lay cid
				aMumia := StrTokArr(aMun[nX][9],";")
				For nY := 1 To Len( aMumia )
					If aMumia[nY] $ aTxt[nI]
						//cRet := aMun[nX][1] //+ " " + aMumia[nY]
						aadd( aRet, {aMun[nX][1],aMun[nX][9]} )
						//Exit  Ver Todos
					EndIf 
				Next nY
				//If !Empty( cRet )
				//	Exit
				//Endif
			Next nX
			If !Empty( aRet )
				Exit
			Endif
		Endif
	Next nZ
	If !Empty( aRet )
		Exit
	Endif

Next nI

//vai ver se ้ tomador ou normaire
For nI := 1 To Len( aTxt )
	For nZ := 1 To Len(aRet)
		if AllTrim( Upper( aRet[nZ][2] ) ) $ Upper( aTxt[nI] )
			cRet := aRet[nZ][1]
			Exit
		Endif
	Next nZ
	if !Empty( cRet )
		Exit
	EndIf
Next nI

if Empty(cRet) .And. Len( aRet ) > 0
	cRet := aRet[1][1]  //Porque s๓ tem s๓ um e ta com a TAG NFS ou NFTS em branco
Else

Endif


Return( cRet )



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
DIVISOR DE AGUAS
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HFLEPDF บ Autor  ณ Eneo               บ Data ณ 15/07/2016  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ler PDF e converter em TXT para Notas Fiscaso de Servi็o   บฑฑ
ฑฑบ          ณ Eletr๔nicas dos municํpios.                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Importa XML                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function HFLEPDF( cArqPdf )
Local cRet := ""
Local cArqTxt := ""

//Aqui entra a rotina do rodriguis
cArqTxt := U_HFPdf2Tx( cArqPdf ) //arquivo convertido Pdf pa Txt
//ACERTOOOO Fazer algumas valida็๕es para ver se conseguiu a conversใo
If .NOT. Empty( cArqTxt )
	cRet := cArqTxt
EndIf

Return( cRet )



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ CONVTXTS บ Autor ณ Eneo               บ Data ณ 28/07/2016  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Pega arquivo texto convertido do PDF e converter em TXT no บฑฑ
ฑฑบ          ณ layout da NFS-e da cidade.                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Importa XML                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function CONVTXTS( cArqTxt, aTxt )
Local cRet := "pdf_"+cArqTxt
Local nI   := 0
Local cLin := ""
Local nLin := 0
Local aLha := {}
Local cCpo := ""
Local aCpo := {}
Local cNom := ""
Local aPos := {}
Local nPos := 0
Local cAux := ""

Private xBuf, xLin, xTxt //Para parametriza็๕es do .CFG

xTxt := aClone( aTxt )

If Len(aRtPdf) >= 1
	cAux   := aRtPdf[02]
	cAux   := strtran(cAux,"{","")
	cAux   := strtran(cAux,"}","")
	aParam := StrTokArr(cAux,";")
	If Type( "aParam" ) != "A"
		aParam := {}
	EndIf
	aLha := ExecBlock( aRtPdf[01], .F., .F., aParam )
Else
	aLha := U_HFTXTPDF( xTxt ) //nesse caso ้ o mesmo, ้ mais para quando nใo vier a baga็a
EndIf

aLha := aSort( aLha,,,{|x,y| x[1] < y[1] } )
cLin := cReg  //2 cReg - contem a baga็a
nPos := 1

For nLin := 1 To Len( aLha )

	if aLha[nLin][1] <= 0
		Loop
	endif

	if aLha[nLin][1] - Len( cLin ) > 1
		cLin += Space( (aLha[nLin][1] - Len( cLin )) - 1 )
	endif

	cLin += Substr( aLha[nLin][3] + space(aLha[nLin][2]), 1, aLha[nLin][2] )

Next nLin

cLin += chr(13)+chr(10)

MemoWrite(cDir+cRet,cLin)
nErase := FErase(cDir+cArqTxt)

Return( cRet )



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HfCampos บ Autor ณ Eneo               บ Data ณ 11/10/2016  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorno Campos de acordo com o layout do arquivo exporta็aoบฑฑ
ฑฑบ          ณ txt.                                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Importa XML                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function HfCampos( cBuf, cCpo )
Local aRet := {}
Local nPos := 0
Local cAux := ""

nPos := aScan( aCfg, {|x| AllTrim(x[8]) == AllTRim(cCpo) } )
If nPos > 0
	cAux   := cBuf
	&cCpo. := cBuf
	aRet := {aCfg[nPos][2], aCfg[nPos][5], cAux }
Else
	aRet := {0, 0, cBuf }
Endif

Return( aRet )





/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HFLerLin บ Autor ณ Eneo               บ Data ณ agosto2016  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna linha do arquivo texto exportado conforme seu      บฑฑ
ฑฑบ          ณ devido layout                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Importa XML                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function HFLerLin(nHandle)
Local cAnt := "" , cChar := " "
Local cString := "" , nLidos := 0, nTotLidos :=0
While .T.
	cChar:=" "	// Ler de 1 em 1 caracteres...
	nLidos := Fread(nHandle,@cChar,1)
	nTotLidos += nLidos
	If cAnt+cChar==chr(13)+chr(10) .or. nLidos<1
		cString := Substr(cString,1,len(cString)-1)
		EXIT
	EndIf
	cString += cChar
	cAnt := cChar
End
Return {cString,nTotLidos}



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HFPdf2Tx บ Autor ณ Copiado do Rodrigo บ Data ณ 11/10/2016  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Faz a bendida conver็ใo de PDF para TXT utilizando path do บฑฑ
ฑฑบ          ณ esmartecriente.                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Importa XML                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function HFPdf2Tx( cArqPdf )

	Local cExec		:= '' //'cmd /c "c:\exemplo\pdftotext.exe '+cDir+cArqPdf+'"' //c:\exemplo\000000040.pdf
	Local cRet		:= ''
	Local cRmtPath
	Local cArqTxt   := strtran(UPPER(cArqPdf),".PDF",".TXT")

	// Identifica o PAth do SmartClient na maquina remota
	// a partir do path do arquivo de configura็ใo ( smartclient.ini ) 
	cRmtPath := GETREMOTEININAME()
	cRmtPath := left(cRmtPath,rat(cBarra,cRmtPath))
	
	__CopyFile( cDir+cArqPdf, cRmtPath+cArqPdf ) //Copia o Pdf para o smartclient
	
	if .Not. File(cRmtPath+'pdf2text.exe')
		__CopyFile( cDir+cBarra+"cfg"+cBarra+"nfse"+cBarra+"pdf2text.exe", cRmtPath+'pdf2text.exe' ) //Copia o pdf2text.exe para o smartclient
	Endif
	if .Not. File(cRmtPath+'httpclass.dll')
		__CopyFile( cDir+cBarra+"cfg"+cBarra+"nfse"+cBarra+"httpclass.dll", cRmtPath+'httpclass.dll' ) //Copia o httpclass.dll para o smartclient
	Endif

	cExec    := 'cmd /c "'+cRmtPath+'pdf2text.exe '+cArqPdf+' '+cArqTxt+'"'

	// Executa o comando para chamar o pdf2txt e gerar o arquivo "pdf2txt.txt"
	nRet := WaitRun(cExec,0)

	ferase(cRmtPath+cArqPdf)  //Apaga o PDF do esmartecrainte

	IF File(cRmtPath+cArqTxt)
		__CopyFile( cRmtPath+cArqTxt, cDir+cArqTxt ) //Copia o TXT gerado para o xmlsource
		if GetNewPar("XM_HFTSTPD","") <> ""  //copiar para inicio de desenvolvimento de CFGs.
			__CopyFile( cRmtPath+cArqTxt, cDir+"CFG\TESTANDO.TXT" )
			cTestando := ""
			nHandle := FT_FUse( cDir+"CFG\TESTANDO.TXT" )
			If nHandle <> -1
				FT_FGoTop()

				While !FT_FEOF()
					cBuf := FT_FReadLn() // Retorna a linha corrente
					cVal := fRAcento(cBuf)
					cTestando := cTestando + AllTrim(Upper(cVal)) + CRLF 
			
			   		FT_FSKIP()
				End

				FT_FUSE()
				
				MemoWrite( cDir+"CFG\TESTE.TXT", cTestando )

			EndIf
		endif
		cRet := cArqTxt
		ferase(cRmtPath+cArqTxt) //apaga o TXT gerado do smartclient
	EndIF

Return( cRet )



Static Function fRAcento(cString)

Local cRet := ""

cRet := FWNoAccent(cString)

cRet := StrTran(cRet,"&","E")
cRet := StrTran(cRet,"'"," ")
cRet := StrTran(cRet,">"," ")
cRet := StrTran(cRet,"<"," ")
cRet := StrTran(cRet,'"'," ")
cRet := StrTran(cRet,"'"," ")
cRet := StrTran(cRet,"$"," ")
cRet := StrTran(cRet,"บ"," ")
cRet := StrTran(cRet,"ช"," ")
cRet := StrTran(cRet,"ข"," ")
cRet := StrTran(cRet,"จ"," ")
cRet := StrTran(cRet,"ฌ"," ")
cRet := StrTran(cRet,"๑"," ")
cRet := StrTran(cRet,"ั"," ")
cRet := StrTran(cRet,"ฃ"," ")
cRet := StrTran(cRet,"น","1")
cRet := StrTran(cRet,"ฒ","2")
cRet := StrTran(cRet,"ณ","3")

cRet := AllTrim(cRet)

Return(cRet)





Static Function __Dummy(lRecursa) //warning W0010 Static Function <?> never called
    lRecursa := .F.
    IF (lRecursa)
        __Dummy(.F.)
        U_HFTXTCSV()
        U_HFNFSESP()
        U_HFPRNNFS()
        U_HFLEPDF()
        U_CONVTXTS()
        U_HFLerLin()
        U_HFPdf2Tx()
	EndIF
Return(lRecursa)


/*
User Function CONVTXTS( cArqTxt, aTxt )
Local cRet := "pdf_"+cArqTxt
Local cLin := ""
Local nLin := 0
Local aLha := {}
Local nHdl := 0
Local cBuf := ""
Local cCpo := ""
Local aCpo := {}
Local cNom := ""
Local aPos := {}
Local nPos := 0
Local cAux := ""

Private xBuf, xLin //Para parametriza็๕es do .CFG

nHdl    := FT_FUse( cDir+cArqTxt )
if nHdl = -1
	return( "" )
endif

FT_FGoTop()
While !FT_FEOF()
	cBuf := FT_FReadLn() // Retorna a linha corrente
	nLin++
	xBuf := cBuf  //Para Evitar a Fadiga
	xLin := nLin  //Evitando a Fadiga

	If Len(aRtPdf) >= 1
		cAux   := aRtPdf[02]
		cAux   := strtran(cAux,"{","")
		cAux   := strtran(cAux,"}","")
		aParam := StrTokArr(cAux,";")
		If Type( "aParam" ) != "A"
			aParam := {}
		EndIf
		aCpo := ExecBlock( aRtPdf[01], .F., .F., aParam )
	Else
		aCpo := U_HFTXTPDF( nLin, cBuf ) //nesse caso ้ o mesmo, ้ mais para quando nใo vier a baga็a
	EndIf


	
	For nPos := 1 To Len( aCpo )
		If ! Empty( aCpo[nPos][1] )
			aPos := U_HfCampos( aCpo[nPos][2], aCpo[nPos][1], nLin )
			aadd( aLha, { aPos[1], aPos[2], aPos[3] } )
		EndIf
	Next nPos

	FT_FSKIP()
End

FT_FUSE()

aLha := aSort( aLha,,,{|x,y| x[1] < y[1] } )
cLin := cReg  //2 cReg - contem a baga็a
nPos := 1

For nLin := 1 To Len( aLha )

	if aLha[nLin][1] <= 0
		Loop
	endif

	if aLha[nLin][1] - Len( cLin ) > 1
		cLin += Space( (aLha[nLin][1] - Len( cLin )) - 1 )
	endif

	cLin += Substr( aLha[nLin][3] + space(aLha[nLin][2]), 1, aLha[nLin][2] )

Next nLin

MemoWrite(cDir+cRet,cLin)
nErase := FErase(cDir+cArqTxt)

Return( cRet )
*/

//Rogerio Lino - 08/04/2021
//Converte string alphanumerica em numero
Static Function ConvNum( cVal )

Local cAux 		:= "0123456789.," 
Local cRet 		:= ""
Local i    		:= 0
Local lTemVirg	:= .F.

For i := 1 to Len(cAux)

	if substring(cVal,i,1) $ cAux

		If substring(cVal,i,1) == ","
			lTemVirg := .T.
		EndIf

		cRet += substring(cVal,i,1) //STRTRAN(cVal,substring(cAux,i,1),'')

	endif

Next i 

If lTemVirg

	cRet := StrTran(cRet,".",'')

	cRet := StrTran(cRet,",",'.')

EndIf

Return( cRet )
