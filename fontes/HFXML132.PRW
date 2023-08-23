#include "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "XMLXFUN.CH" 
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"

#DEFINE ST_SMACAO  "0"
#DEFINE ST_PENDEN  "1"
#DEFINE ST_CORRIG  "2"

Static lUnix  := IsSrvUnix()
Static cBarra := Iif(lUnix,"/","\")

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HFXML132  ºAutor  ³Eneovaldo Roveri Jr º Data ³    Hoje     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotinas Auditoria de arquivos da Ticket                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ HFXML132                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function HFXML132( cAlias, nReg, nModo, lAuto )
Local aArea   := GetArea()
Local cClAt   := "N"
Local lTem    := .F.
Local nVersao := Val(GetVersao(.F.))     // Indica a versao do Protheus

Default lAuto := .F.

RstMvBuff()

cClAt   := GetNewPar("XM_CLAT"   ,"N")

if ! cClAt $ "S"
	if ! lAuto
		U_MyAviso("Aviso","Classificação Automática Não esta Ativa!" ,{"Ok"},3)
	endif
	Return( NIL )
endif

Private cTmp_ZBZ := "TMPZBZ", cAli_ZBZ, oTmp_ZBZ
Private aEmpFils := U_XGetEmpF()

if nVersao >= 12
	CriaTMP()
	cAli_ZBZ := oTmp_ZBZ:GetAlias()
Else
	cAli_ZBZ := CriaTMP()
Endif

If Popular( lAuto )
	//aqui bai o vrowse
	If ! lAuto
		HFXML132Bw()
	Endif
Else
	if ! lAuto
		U_MyAviso("Aviso","Não existe registro pendende de auditoria!" ,{"Ok"},3)
	endif
Endif

if nVersao >= 12
	oTmp_ZBZ:Delete()
Else
	(cAli_ZBZ)->( dbCloseArea() )
Endif

RestArea(aArea)

Return( NIL )

//Criar temporário
Static Function CriaTMP()
Local aStru := {}
Local aInd  := {}
Local nVersao     := Val(GetVersao(.F.))     // Indica a versao do Protheus
Local cArq

aadd( aStru, { "OK"      ,"C",02,0 } )
aadd( aStru, { "ST"      ,"C",01,0 } )
aadd( aStru, { "NOTA"    ,"C",len( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA"))) )  ,0 } )
aadd( aStru, { "SERIE"   ,"C",len( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE"))) ) ,0 } )
aadd( aStru, { "DTNFE"   ,"D",08,0 } )
aadd( aStru, { "PRENF"   ,"C",len( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF"))) ) ,0 } )
aadd( aStru, { "CNPJ"    ,"C",len( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))) )  ,0 } )
aadd( aStru, { "FORNEC"  ,"C",len( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FORNEC"))) ),0 } )
aadd( aStru, { "CHAVE"   ,"C",len( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))) ) ,0 } )
aadd( aStru, { "TPDOC"   ,"C",len( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC"))) ) ,0 } )
aadd( aStru, { "CODFOR"  ,"C",len( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR"))) ),0 } )
aadd( aStru, { "LOJFOR"  ,"C",len( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR"))) ),0 } )
aadd( aStru, { "XMLNFE"  ,"M",10,0 } )
aadd( aStru, { "CNPJD"   ,"C",len( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJD"))) ) ,0 } )
aadd( aStru, { "M0COD"   ,"C",len( SM0->M0_CODIGO ) ,0 } )
aadd( aStru, { "M0FIL"   ,"C",len( SM0->M0_CODFIL ) ,0 } )
aadd( aStru, { "DESCR"   ,"C",len( (xZBO)->(FieldGet(FieldPos(xZBO_+"DESCR"))) ),0 } )
aadd( aStru, { "DTOCOR"  ,"D",08,0 } )
aadd( aStru, { "HROCOR"  ,"C",08,0 } )
aadd( aStru, { "ARQ"     ,"C",len( (xZBO)->(FieldGet(FieldPos(xZBO_+"ARQ"))) ),0 } )
aadd( aStru, { "FTP"     ,"C",len( (xZBO)->(FieldGet(FieldPos(xZBO_+"FTP"))) ),0 } )
aadd( aStru, { "REG"     ,"N",15,0 } )
aadd( aStru, { "REGZBO"  ,"N",15,0 } )


if nVersao >= 12
	oTmp_ZBZ := FWTemporaryTable():New( cTmp_ZBZ, aStru ) //-> Objeto FWTemporaryTable 
		aInd := {}
		aadd( aInd, "CHAVE" )
	oTmp_ZBZ:AddIndex( cTmp_ZBZ+"01", aInd )
		aInd := {}
		aadd( aInd, "SERIE" )
		aadd( aInd, "NOTA" )
	oTmp_ZBZ:AddIndex( cTmp_ZBZ+"02", aInd )
	oTmp_ZBZ:Create()
Else
	cArq := CriaTrab( aStru, .T. )
	dbUseArea(.T.,, cArq,cTmp_ZBZ, .F., .F.) //exclusivo
	IndRegua(cTmp_ZBZ,cArq+"01","CHAVE" ) 
	IndRegua(cTmp_ZBZ,cArq+"02","SERIE+NOTA" )
	dbClearIndex()
	dbSetIndex( cArq+"01" + OrdBagExt() )//ordem 1
	dbSetIndex( cArq+"02" + OrdBagExt() )//ordem 2
	dbSetOrder( 1 )
EndIf

Return(cTmp_ZBZ)


Static Function Popular( lAuto )
Local lRet  := .F.
Local aArea := GetArea()
Local cQry  := ""
Local xFili := ""
Local cPrNf := ""

DbSelectArea( xZBZ )
DbSetOrder(3)

DbSelectArea( xZBO )
DbSetOrder(5)
( xZBO )->( dbSeek( ST_PENDEN ) )

Do While .NOT. ( xZBO )->( Eof() ) .AND. ( xZBO )->( FieldGet( FieldPos(xZBO_+"ST") ) ) == ST_PENDEN
	If ( xZBO )->( FieldGet( FieldPos(xZBO_+"TPOCOR") ) ) <> "1"  //Tirar os diferentes de Classificação
		( xZBO )->( dbSkip() )
		Loop
	EndIf

	xFili := ( xZBO )->(FieldGet(FieldPos(xZBO_+"FILIAL" )))

	cPrNf := "*"
	If (xZBZ)->( DbSeek( ( xZBO )->( FieldGet( FieldPos(xZBO_+"CHAVE") ) ) ) )
		cPrNf := U_HFSTXMUN( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))),;
	               (xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA"))),;
	               (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE"))),;
	               (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR")))+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR"))) ,;
	               (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC"))),;
	               (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO"))),;
	               (xZBZ)->(FieldGet(FieldPos(xZBZ_+"DOCCTE"))),;
	               (xZBZ)->(Recno()),.T. )
		If AllTrim(cPrNf) $ "N"
			//Acertar o Bixo
			DbSelectArea( xZBO )
			RecLock( xZBO, .F. )
			(xZBO)->(FieldPut(FieldPos(xZBO_+"ST"), ST_CORRIG ))
			(xZBO)->( MsUnlock() )
			( xZBO )->( dbSeek( ST_PENDEN ) )
			Loop
		EndIF
	Endif
	RecLock( cTmp_ZBZ, .T. )
//		(cTmp_ZBZ)->OK"      ,"C",02,0 } )
	If cPrNf <> "*"
		(cTmp_ZBZ)->ST      := iif( cPrNf = "N", "2", iif( cPrNf = "S", "1", " ") )
		(cTmp_ZBZ)->NOTA	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA"  )))
		(cTmp_ZBZ)->SERIE	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE" )))
		(cTmp_ZBZ)->DTNFE	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"DTNFE" )))
		(cTmp_ZBZ)->PRENF	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF" )))
		(cTmp_ZBZ)->CNPJ	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"  )))
		(cTmp_ZBZ)->FORNEC	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FORNEC")))
		(cTmp_ZBZ)->CHAVE	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"	)))
		(cTmp_ZBZ)->TPDOC	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC"	)))
		(cTmp_ZBZ)->CODFOR	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR")))
		(cTmp_ZBZ)->LOJFOR	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR")))
		(cTmp_ZBZ)->XMLNFE	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML"	)))
		(cTmp_ZBZ)->CNPJD	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJD"	)))
		(cTmp_ZBZ)->M0FIL	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL")))    //len( SM0->M0_CODFIL )
		(cTmp_ZBZ)->REG		:= (xZBZ)->(Recno())
	Else  //Falta o Download ( Tentaire )
//		(cTmp_ZBZ)->OK"      ,"C",02,0 } )
		(cTmp_ZBZ)->ST      := " "
		(cTmp_ZBZ)->NOTA	:= Substr( (xZBO)->(FieldGet(FieldPos(xZBO_+"CHAVE"))), 26, 09 )
		(cTmp_ZBZ)->SERIE	:= Substr( (xZBO)->(FieldGet(FieldPos(xZBO_+"CHAVE"))), 23, 03 )
		(cTmp_ZBZ)->CNPJ	:= Substr( (xZBO)->(FieldGet(FieldPos(xZBO_+"CHAVE"))), 07, 14 )
		(cTmp_ZBZ)->CHAVE	:= (xZBO)->(FieldGet(FieldPos(xZBO_+"CHAVE")))
		(cTmp_ZBZ)->M0FIL	:= (xZBO)->(FieldGet(FieldPos(xZBO_+"FILIAL")))    //len( SM0->M0_CODFIL )
		(cTmp_ZBZ)->REG		:= 0
	EndIF
	(cTmp_ZBZ)->DESCR	:= (xZBO)->(FieldGet(FieldPos(xZBO_+"DESCR" )))
	(cTmp_ZBZ)->DTOCOR	:= (xZBO)->(FieldGet(FieldPos(xZBO_+"DTOCOR")))
	(cTmp_ZBZ)->HROCOR	:= (xZBO)->(FieldGet(FieldPos(xZBO_+"HROCOR")))
	(cTmp_ZBZ)->ARQ		:= (xZBO)->(FieldGet(FieldPos(xZBO_+"ARQ"   )))
	(cTmp_ZBZ)->FTP		:= (xZBO)->(FieldGet(FieldPos(xZBO_+"FTP"   )))
	(cTmp_ZBZ)->M0COD	:= (xZBO)->(FieldGet(FieldPos(xZBO_+"M0COD" )))
	(cTmp_ZBZ)->REGZBO  := (xZBO)->(Recno())
	(cTmp_ZBZ)->( MsUnLock() )

	lRet := .T.
	( xZBO )->( dbSkip() )
EndDo
//#DEFINE ST_CORRIG  "2"

RestArea( aArea )
Return( lRet )


Static Function HFXML132Bw()
Local aButtons	:= {}
Local aGetArea	:= GetArea()
Local aInfo		:= {}
Local aPosObj	:= {}
Local aObjects	:= {}
Local aSize		:= MsAdvSize()  			// Define e utilização de janela padrão Microsiga
Local cGetLOk  	:= "AllwaysTrue"	   		// Funcao executada para validar o contexto da linha atual do aCols
Local cGetTOk  	:= "AllwaysTrue"    		// Funcao executada para validar o contexto geral da MsNewGetDados
Local oFolder	:= Nil
Local oDlg01	:= Nil
Local oMarkBw	:= Nil
Local lInverte	:= .F.
Local lOk		:= .F.
Local cChvAtu	:= " "
Local cChvAnt	:= " "
Local oFont		:= Nil
Local aCpos     := {}
Local aCores    := {}

Private cMarcaOK := GetMark()

aCpos := {}
aadd( aCpos, {"OK"   	,,"" } )
aadd( aCpos, {"NOTA"    ,,"NOTA FISCAL","@!" } )
aadd( aCpos, {"SERIE"   ,,"SERIE","@!" } )
aadd( aCpos, {"DTOCOR"  ,,"DT.OCOR.","@D" } )
aadd( aCpos, {"HROCOR"  ,,"HR","@!" } )
aadd( aCpos, {"CHAVE"   ,,"CHAVE","@!" } )
aadd( aCpos, {"DESCR"   ,,"OCORRENCIA","@!" } )
aadd( aCpos, {"CNPJ"    ,,"CNPJ","@!" } )
aadd( aCpos, {"DTNFE"   ,,"DT EMISSAO","@D" } )
aadd( aCpos, {"FORNEC"  ,,"EMITENTE","@!" } )
aadd( aCpos, {"CODFOR"  ,,"FORNEC","@!" } )
aadd( aCpos, {"LOJFOR"  ,,"LOJA","@!" } )
aadd( aCpos, {"TPDOC"   ,,"TIPO","@!" } )
aadd( aCpos, {"ARQ"     ,,"Arquivo Protheus","@!" } )
aadd( aCpos, {"FTP"     ,,"Arquivo FTP","@!" } )

aCores := {}
aAdd(aCores,{cTmp_ZBZ+"->ST == '0'","BR_PRETO"		})  //Erro Na Reclassificação
aAdd(aCores,{cTmp_ZBZ+"->ST == '2'","BR_VERMELHO"	})  //Corrigida Classificada
aAdd(aCores,{cTmp_ZBZ+"->ST == '1'","BR_VERDE"	    })  //Apenas Pré-Nota
aAdd(aCores,{cTmp_ZBZ+"->ST == ' '","BR_AZUL"	    })  //Importado, esperando para classificar
aAdd(aCores,{cTmp_ZBZ+"->ST == '9'","BR_AMARELO"    })  //Pobrema Não Encontrado

dbSelectArea(cTmp_ZBZ)
//COUNT TO nQtdReg
(cTmp_ZBZ)->( dbGotop() )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apresenta botao se nao for visualizacao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aButtons,{'CHECKED' ,{ || MULTCTEInv(cMarcaOK,@oMarkBw)     }, "Inverter Marcação"      , "Inverter"	})
aAdd(aButtons,{'DESTINOS',{ || MULTCTEInv(cMarcaOK,@oMarkBw,.T.) }, "Marcar todos os títulos", "Marc Todos"	})
aAdd(aButtons,{          ,{ || HFXML13Leg() 					 }, "Legenda"				 , "Legenda"	})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define as posicoes da GetDados e Paineis ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//aAdd( aObjects, { 100, 060, .T., .T. } )      //GetDados
//aAdd( aObjects, { 100, 040, .T., .T. } )      //Folder
//aInfo := { aSize[1], aSize[2], aSize[3], aSize[4], 3, 3 }
//aPosObj := MsObjSize( aInfo, aObjects,.T. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao da tela ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    //aSize[7],0 TO aSize[6],aSize[5]
DEFINE MSDIALOG oDlg01 TITLE "Auditoria da Classificação de Combustíveis" FROM 000,000 TO 430,800 OF oMainWnd PIXEL

oDlg01:lMaximized := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria o objeto Mark para a selecao dos podrutos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oMarkBw:=MsSelect():New(cTmp_ZBZ,"OK","",aCpos,@lInverte,@cMarcaOK,{17,10,150,400},,,,,aCores) //oFolder:aDialogs[1]

oMarkBw:oBrowse:Refresh()
oMarkBw:oBrowse:lhasMark    := .T.
oMarkBw:oBrowse:lCanAllmark := .T.
oMarkBw:oBrowse:Align       := CONTROL_ALIGN_ALLCLIENT	//Usado no modelo FLAT


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Permite selecao se não for visualizacao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oMarkBw:oBrowse:bAllMark    := { || MULTCTEInv(cMarcaOK,@oMarkBw) }
oMarkBw:oBrowse:bChange     := { || MULTCTEChg(@oMarkBw) }
oMarkBw:BMark               := { || MULTCTEDis(@oMarkBw,cMarcaOK) }

ACTIVATE MSDIALOG oDlg01 CENTERED  ON INIT EnchoiceBar(oDlg01,;
{|| processa({|| Classifica(.T.,@oMarkBw)}, "Classificando Documentos...","Classificando Documentos ...") },;
{|| iif( msgYesNo("Sair Classificação Automática ?","Pegunta"),oDlg01:End(),lOk := .F. )},,aButtons)

Return( .T. )

Static Function MULTCTEInv(cMarcaOK,oMarkBw,lMarkAll)
Local aGetArea	:= GetArea()
Local lMarcSim	:= .F.

If lMarkAll
	lMarcSim := Aviso( "Marcar/Desmarcar todos", "Deseja marcar ou desmarcar todos os títulos?", { "Marcar", "Desmarcar" } ) == 1
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ While para marcar ou desmarcar os produtos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
(cTmp_ZBZ)->( dbGotop() )
Do while (cTmp_ZBZ)->( !EOF() )

	If lMarkAll
		RecLock(cTmp_ZBZ, .F.)
		(cTmp_ZBZ)->OK	:= if((cTmp_ZBZ)->ST $ "2,9", "  ", If(lMarcSim, cMarcaOK, "  ") )
		(cTmp_ZBZ)->( MsUnLock() )
	Else
		If  (cTmp_ZBZ)->OK == cMarcaOK
			RecLock(cTmp_ZBZ, .F.)
			(cTmp_ZBZ)->OK	:= "  "
			(cTmp_ZBZ)->( MsUnLock() )
		Else
			RecLock(cTmp_ZBZ, .F.)
			(cTmp_ZBZ)->OK	:= if((cTmp_ZBZ)->ST $ "2,9", "  ", cMarcaOK )
			(cTmp_ZBZ)->( MsUnLock() )
		EndIf
	EndIf

	(cTmp_ZBZ)->( dbSkip() )
EndDo

oMarkBw:oBrowse:Refresh(.T.)
RestArea( aGetArea )
Return


Static Function MULTCTEChg(oMarkBw)
Local cRetFun		:= " "

oMarkBw:oBrowse:Refresh(.T.)

Return cRetFun


Static Function MULTCTEDis(oMarkBw, cMarcaOK)
Local aGetArea := GetArea()

If (cTmp_ZBZ)->ST $ "2,9" //.OR. (cTmp_ZBZ)->OK == cMarcaOK
	RecLock(cTmp_ZBZ, .F.)
	(cTmp_ZBZ)->OK	:= "  "
	(cTmp_ZBZ)->( MsUnLock() )
Endif

oMarkBw:oBrowse:Refresh(.T.)

RestArea( aGetArea )
Return


//Legenda
Static Function HFXML13Leg()
Local aLegenda := {}

AADD(aLegenda,{"BR_AZUL"    ,"Aguardando Classificação" })
AADD(aLegenda,{"BR_VERDE" 	,"NF Pré-nota lançada" })
AADD(aLegenda,{"BR_VERMELHO","NF Classificada" })
AADD(aLegenda,{"BR_AMARELO" ,"XML não encontrado" })
AADD(aLegenda,{"BR_PRETO"   ,"Erro na Classificação" })

BrwLegenda("Download de XML", "Legenda", aLegenda)
Return Nil




//Classificar Via StattJob e Ver Amarra apenas da empresa atual.
Static Function Classifica(lMostra,oMarkBw)
Local lCrassifica := .F.
Local cChave := ""
Local nReg   := (cTmp_ZBZ)->( recno() )
Local nFadiga:= (cTmp_ZBZ)->( recno() )
Local aXEmpF := {}
Local nPosCn := 0
Local lRet   := .T.
Local lTem   := .F.
Local aRet   := {}
Local cRet   := ""
Local aReg   := {}
Private cArqTxt:= "" //(cTmp_ZBZ)->ARQ

if lMostra
	ProcRegua((cTmp_ZBZ)->( RecCount() ))
Endif
cMsg := "Classficando NFE(s):"+CRLF

(cTmp_ZBZ)->( dbgotop() )
Do While .not. (cTmp_ZBZ)->( Eof() )
	If lMostra
		IncProc("Processando "+(cTmp_ZBZ)->CHAVE)
	EndIf

	aXEmpF := {}
	nPosCn := 0
	if !Empty( (cTmp_ZBZ)->CNPJD )
		nPosCn := aScan( aEmpFils, {|x| x[4] == (cTmp_ZBZ)->CNPJD } )
	Endif
	if nPosCn = 0
		nPosCn := aScan( aEmpFils, {|x| x[2] = (cTmp_ZBZ)->M0COD .And. x[3] = (cTmp_ZBZ)->M0FIL } )
	endif
	If nPosCn > 0
		aadd( aXEmpF, iif(aEmpFils[nPosCn][1], 1, 2) )  //1 - Lic, 2 - Sem Lic
		aadd( aXEmpF, aEmpFils[nPosCn][2] )  //Empresa
		aadd( aXEmpF, aEmpFils[nPosCn][3] )  //Filial
		aadd( aXEmpF, aEmpFils[nPosCn][4]  )   //Cnpj
	Else
		aadd( aXEmpF, 0 )
		aadd( aXEmpF, cEmpAnt )
		aadd( aXEmpF, cFilAnt )
		aadd( aXEmpF, (cTmp_ZBZ)->CNPJD  )
	EndIf
	cChave := (cTmp_ZBZ)->CHAVE
	cArqTxt:= (cTmp_ZBZ)->ARQ

	If .NOT. Empty( (cTmp_ZBZ)->OK ) // == cMarcaOK
		//Primeiro ver se é download
		If (cTmp_ZBZ)->REG == 0  //é o caso
			lCrassifica := HF132Dow(aXEmpF,cChave)
		Else
			lCrassifica := .T.
		EndIf
		lTem := .T.
	EndIF

	If .NOT. Empty( (cTmp_ZBZ)->OK ) .AND. lCrassifica
		cRet   := ""
		aReg   := {}
		aadd( aReg, (cTmp_ZBZ)->NOTA   )  //01
		aadd( aReg, (cTmp_ZBZ)->SERIE  )  //02
		aadd( aReg, (cTmp_ZBZ)->DTNFE  )  //03
		aadd( aReg, (cTmp_ZBZ)->CHAVE  )  //04
		aadd( aReg, (cTmp_ZBZ)->CODFOR )  //05
		aadd( aReg, (cTmp_ZBZ)->LOJFOR )  //06
		aadd( aReg, (cTmp_ZBZ)->TPDOC  )  //07

		if AllTrim( (cTmp_ZBZ)->M0COD ) == AllTrim( cEmpAnt ) .And. AllTrim( (cTmp_ZBZ)->M0FIL ) == AllTrim( cFilAnt )
			aRet := U_HFzClass( (cTmp_ZBZ)->REG, aReg )
		Else
			aRet := StartJob("U_XML131CL",GetEnvServer(),.T., aXEmpF[1], (cTmp_ZBZ)->M0COD, (cTmp_ZBZ)->M0FIL, (cTmp_ZBZ)->REG, aReg, @cRet, @aRet, cArqTxt )
			if ValType( aRet ) != "A"
				aRet := {}
				aadd( aRet, "N" )
				aadd( aRet, "Erro Retorno da Rotina Classificação U_XML131CL" )
				aadd( aRet, "0" )
			Endif
		Endif
		if Len( aRet ) >= 2
			cMsg += aRet[2] +CRLF  //+(cTmp_ZBZ)->CHAVE
		Endif

		DbSelectArea( cTmp_ZBZ )
		If aRet[1] = "N" // oXml == NIL .Or. !Empty(cError) .Or. !Empty(cWarning)
			DbSelectArea( cTmp_ZBZ )
           	RecLock( cTmp_ZBZ, .F. )
           			(cTmp_ZBZ)->OK := "  "
           			(cTmp_ZBZ)->ST := aRet[3]
 	        (cTmp_ZBZ)->( MsUnLock() )
		Else
            RecLock( cTmp_ZBZ, .F. )
                	(cTmp_ZBZ)->OK := "  "
                	(cTmp_ZBZ)->ST := aRet[3]
            (cTmp_ZBZ)->( MsUnLock() )
		EndIf

		lTem := .T.
	Endif

	(cTmp_ZBZ)->( dbskip() )
Enddo

if .Not. lTem
	if lMostra
		U_MyAviso("Msg","Nenhuma NF-e selecionada !!!!",{"OK"},3)
	endif
Else
	if lMostra
		oMarkBw:oBrowse:Refresh(.T.)
		U_MyAviso("Msg",cMsg,{"OK"},3)
	endif
endif
(cTmp_ZBZ)->( dbgoto( nReg ) )

Return( lRet )


//A merda Feita. Redowloads
Static Function HF132Dow(aXEmpF,cChave)  
Local lRet := .F.
Local cRet := ""
Local aZbz := {}
Local aRet := {}
Local aArea := GetArea()
Local cPrNf := ""
Local nI    := 0
Local aCab  := {}, aIte := {}
Local aLin[19], aDet[15]

Private cIdEnt := U_GetIdEnt()

//Fazer o aCab,aIte,nX,
		aLin[01] := "" //Substr(cBuf,004,073) //Razao
		aLin[02] := "" //Substr(cBuf,074,103) //Enderco
		aLin[03] := "" //Substr(cBuf,104,005) //numero
		aLin[04] := "" //Substr(cBuf,109,035) //Bairro
		aLin[05] := "" //Substr(cBuf,144,035) //Mun
		aLin[06] := "" //Substr(cBuf,179,010) //CEP
		aLin[07] := "" //Substr(cBuf,189,002) //UF
		aLin[08] := Substr( cChave, 07, 14 )  //Substr(cBuf,191,014) //CNPJ_CPF
		aLin[09] := "" //Substr(cBuf,205,002) //BR
		aLin[10] := "" //Substr(cBuf,207,020) //Inscricao_Estadu
		aLin[11] := Substr( cChave, 26, 9 )   //Substr(cBuf,227,009) //Num_NF
		aLin[12] := Substr( cChave, 23, 3 )   //Substr(cBuf,236,003) //Serie
		aLin[13] := "" //Substr(cBuf,239,003) //SubSerie
		aLin[14] := "" //Substr(cBuf,242,008) //Dt_Lancamento
		aLin[15] := "" //Substr(cBuf,250,008) //Dt_Emissao
		aLin[16] := aXEmpF[4] //Substr(cBuf,258,014) //CNPJ_Destino
		aLin[17] := cChave //Substr(cBuf,272,044) //Chave
		aLin[18] := "" //Substr(cBuf,316,015) //Valor Total Nota  FAZER O VAL
		aLin[19] := "" //Substr(cBuf,331,015) //Valor Total Nota  FAZER O VAL

		aadd( aCab, aClone(aLin) )

		aDet[01] := cChave
		aDet[02] := "" //Substr(cBuf,001,007) //Id_Item
		aDet[03] := "" //Substr(cBuf,008,020) //Cod_Produto
		aDet[04] := "" //Substr(cBuf,028,040) //Descricao_Nota
		aDet[05] := "" //Substr(cBuf,068,013) //Quantidade 13,4 FAZER O VAL
		aDet[06] := "" //Substr(cBuf,081,003) //Unidade de medida
		aDet[07] := "" //Substr(cBuf,084,015) //Vlr_Unitario FAZER O VAL
		aDet[08] := "" //Substr(cBuf,099,010) //CFOP
		aDet[09] := "" //Substr(cBuf,109,015) //Base_Calculo_ICMS  FAZER O VAL
		aDet[10] := "" //Substr(cBuf,124,008) //Aliquota_ICMS  FAZER O VAL
		aDet[11] := "" //Substr(cBuf,132,015) //Vlr_Imposto_ICMS  FAZER O VAL
		aDet[12] := "" //Substr(cBuf,147,015) //Base_Calculo_IPI  FAZER O VAL
		aDet[13] := "" //Substr(cBuf,162,008) //Aliquota_IPI  FAZER O VAL
		aDet[14] := "" //Substr(cBuf,170,015) //Vlr_Imposto_IPI  FAZER O VAL
		aDet[15] := "" //Substr(cBuf,185,015) //Vlr_Desconto  FAZER O VAL

		aadd( aIte, aClone(aDet) )
//Fim Fazer o aCab

For nI := 1 To (cTmp_ZBZ)->(FCount())
	aadd( aZbz, { (cTmp_ZBZ)->( FieldName( nI ) ), (cTmp_ZBZ)->(FieldGet( nI ) ) } )
Next nI

If ( aXEmpF[2] == cEmpAnt .And. aXEmpF[3] == cFilAnt )
	aRet := U_HFzCHKCV( aCab, 1, aIte, cRet, aZbz, aXEmpF[2], aXEmpF[3] )
Else
	aRet := StartJob("U_XML131CH",GetEnvServer(),.T., aXEmpF[1], aXEmpF[2], aXEmpF[3], aCab, 1, aIte, @cRet, @aZbz, cArqTxt, cTpRt )
EndIf

if ValType( aRet ) = "A"
	cRet := aRet[1]
	aZbz := aRet[2]
Else
	cRet := "[F][ ][CLAS_AUT] Erro"
Endif

if Substr(cRet,1,3) = "[F]"  //Problema com Conexão
	DbSelectArea( cTmp_ZBZ )
		RecLock( cTmp_ZBZ, .F. )
		(cTmp_ZBZ)->ST     := "9"  //Não Encontrado na ZBZ Continua com problema
	(cTmp_ZBZ)->( MsUnLock() )
Else
	DbSelectArea( cTmp_ZBZ )
	RecLock( cTmp_ZBZ, .F. )
	For nI := 1 To Len(aZbz)
		(cTmp_ZBZ)->(FieldPut(FieldPos(aZbz[nI][1]), aZbz[nI][2] ))
	Next nI
	(cTmp_ZBZ)->( MsUnLock() )

Endif
dbSelectArea(xZBZ)
dbSetOrder( 3 )
If (xZBZ)->( dbSeek( cChave ) )
	lRet :=  .T.
Else
	lRet :=  .F.
Endif
DbSelectArea( cTmp_ZBZ )

RestArea( aArea )
Return( lRet )



Static Function __Dummy(lRecursa) //warning W0010 Static Function <?> never called
    lRecursa := .F.
    IF (lRecursa)
        __Dummy(.F.)
        U_HFXML132()
	EndIF
Return(lRecursa)