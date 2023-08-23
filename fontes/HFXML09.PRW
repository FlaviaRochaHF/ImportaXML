#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"                 
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "TBICONN.CH" 
#include "rwmake.ch"
#include "TOPCONN.CH"

Static __nConecta

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ HFXML09  º Autor ³ Eneovaldo Roveri Jrº Data ³  19/02/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Cadastro de Pedido Recorrente.                             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ IMPORTA XML                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//---------------------------------------------------------------------------//
//Alterações realizadas:
//FR - 28/05/2021 - #10718 - Cimentos Itambé - propriedade inválida _DEMI
//----------------------------------------------------------------------------//
//FR - 31/05/2021 - #10736 - Cimentos Itambé - propriedade inválida _NFCI
//----------------------------------------------------------------------------//
//FR - 14/06/2021 - #10789 - Cimentos Itambé - ponto entrada PEXMLPEITE
//----------------------------------------------------------------------------//
//FR - 17/06/2021 - #10789 - Cimentos Itambé - retorno da função XML09FOR
//----------------------------------------------------------------------------//
//FR - 29/07/2022 - SOLICITADO NÃO MAIS USAR ESSA VALIDAÇÃO - POR CLEUZELI
//if nQuant > nSaldo (comparando na ZBB não precisa, basta ver SC7)
//----------------------------------------------------------------------------//
User Function HFXML09()

Local lRet      := .T.
Local aArea     := GetArea()
Local cArq, cChaveF1, cKeyF3,cKeyF7
Private cMarcaOK:= GetMark()
Private x_ZBB_  := iif(Substr(x_ZBB,1,1)=="S", Substr(x_ZBB,2,2), Substr(x_ZBB,1,3)) + "_"

Static lUnix  := IsSrvUnix()
Static cBarra := Iif(lUnix,"/","\")

if empty(x_ZBB)
	U_MyAviso("ERRO","Tabela de Pedido Recorrente não Informada. Informe a Tabela no painel administrativo e rode o compatibilizador.",{"OK"},3)
	RestArea( aArea )
	Return( .F. )
endif
If (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO"))) <> "55"
	U_MyAviso("ATENÇÃO","Modelo de XML Diferente de 55 (NFe).",{"OK"},2)
	RestArea( aArea )
	Return( .F. )
EndIf
If Empty( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR"))) ) .Or. Empty((xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR"))) )
	U_MyAviso("ATENÇÃO","Este XML não possui fornecedor associado. Clique em Ações Relacionadas / Funções XML / Alterar e Associe o Fornecedor de Acordo com o CNPJ. Caso não Tenha Fornecedor Cadastrado com o CNPJ, faça-o no Cadastro de Fornecedor.",{"OK"},3)
	RestArea( aArea )
	Return( .F. )
EndIf
If (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC"))) <> "N"     //Notas Devolução e Beneficiamento sai na boa
	U_MyAviso("Pré-Nota Ped. Recorrente","Notas Devolução e Beneficiamento não gera pré-nota por pedido recorrente",{"OK"},2)
	RestArea( aArea )
	Return( .T. )
EndIf
if .Not. ChkFile(x_ZBB)
	U_MyAviso("ATENÇÃO","Tabela de Pedido Recorrente "+x_ZBB+" não existe. Verifique se está correta. Se estiver rode o compatibilizador, senão altere a tabela no painel administrativo.",{"OK"},3)
	RestArea( aArea )
	Return( .F. )
endif
//cChaveF1 := ZBZ->ZBZ_FILIAL + ZBZ->ZBZ_NOTA + ZBZ->ZBZ_SERIE + ZBZ->ZBZ_CODFOR + ZBZ->ZBZ_LOJFOR + ZBZ->ZBZ_TPDOC
cChaveF1 := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))) + (xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA"))) +;
            (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE")))  + (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR"))) +;
            (xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR"))) + (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC")))
//DbSelectArea("SF1")
//DbSetOrder(1)
//If DbSeek(cChaveF1)
//	U_MyAviso("Atenção","Esta NFE já foi lançada para a Base!"+CRLF +"Chave :"+cChaveF1,{"OK"},3)
//	RestArea( aArea )
//	Return( .F. )
//EndIf


cArq := CriaTMP()

If cArq == NIL .or. empty( cArq )
   U_MyAviso("Erro","Não foi possível criar o Arquivo Temporário."+CRLF+;
	"Verifique suas permissões e tente novamente.",{"OK"},1)
	RestArea(aArea)
	Return(.F.)
Endif

If Select("TMP") > 0
	TMP->( dbCloseArea() )
EndIf
dbUseArea(.T.,, cArq,"TMP", .F., .F.) //Exclusivo
IndRegua("TMP",cArq+"A",x_ZBB_+"PROD" )
IndRegua("TMP",cArq+"B",x_ZBB_+"PROD + "+x_ZBB_+"PEDIDO + "+x_ZBB_+"ITEM" )
dbClearIndex()
dbSetIndex( cArq+"A" + OrdBagExt() )
dbSetIndex( cArq+"B" + OrdBagExt() )
dbSetOrder( 1 )

cKeyF3    := SetKEY( VK_F3 ,  Nil )
cKeyF7    := SetKEY( VK_F7 ,  Nil )

if HFXML09Cnp()
	HFXML09Brw()
endif

SetKEY( VK_F3 ,  cKeyF3 )
SetKEY( VK_F7 ,  cKeyF7 )

TMP->( dbCloseArea() )
fErase( cArq+GetDBExtension() )
RestArea( aArea )
Return( lRet )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CriaTMP  º Autor ³ Eneovaldo Roveri Jrº Data ³  19/02/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Criar Arquivo Temporario para BROWSE.                      º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CriaTMP()
Local aStru := {}
Local cARQ 

dbSelectArea(x_ZBB)

Aadd( aStru, { "OK"      ,"C",02,0 } )
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek( x_ZBB )
While !Eof().And.( x3_arquivo == x_ZBB )
	If X3_BROWSE == "S" .and. AllTrim(x3_campo) <> x_ZBB_+"FILIAL" .And. AllTrim(x3_campo) <> x_ZBB_+"ATUAL" .And.;
	   AllTrim(x3_campo) <> x_ZBB_+"FORNEC" .And. AllTrim(x3_campo) <> x_ZBB_+"LOJA"
		Aadd( aStru, { AllTrim(x3_campo) ,x3_tipo,x3_tamanho,x3_decimal } )
	endif
	dbSkip()
End
Aadd( aStru, { "SALDO","N",15,2 } )

cArq := CriaTrab( aStru, .T. )

Return( cArq )



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HFXML09Cnpº Autor ³ Eneovaldo Roveri Jrº Data ³  19/02/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Popular a Tabela temporária                                º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function HFXML09Cnp()

Local lRet      := .T.
Local cProd     := ""
Local cDesc     := ""
Local nQuant    := 0
Local nVunit    := 0
Local nTotal    := 0
LOcal cUN       := ""
Local cPedido   := ""
Local cItPed    := ""
Local cCampo    := ""
Local nErrItens := 0
Local valoire
Local i := nI   := 0
Local lCampo    := .F.
Local lInc      := .F.
Local cError    := ""
Local cWarning  := ""
Local cParXMLExp := AllTrim(SM0->M0_CODIGO)+AllTrim(SM0->M0_CODFIL)+"HFXMLEXP"
Local aParam     := {Space(Len(SF2->F2_FILIAL)),Space(Len(SF2->F2_FILIAL)),Space(Len(SF2->F2_SERIE)),Space(Len(SF2->F2_DOC)),Space(Len(SF2->F2_DOC)),Space(60),CToD("01/01/2001"),dDataBase,Space(14),Space(14),CToD("01/01/2001"),dDataBase}
Local ni        := 0
Local i         := 0

Private oXml, oDet
Private cAmarra := GetNewPar("XM_DE_PARA","0")
Private aPerg   := {}
Private aCombo  := {}
Private aProdOk := {}
Private aProdNo := {}
Private cAux    := ""
Private cTipoCPro := ""

cXml := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML")))
//cXml := EncodeUTF8(cXml)

//Faz backup do xml sem retirar os caracteres especiais
//cBkpXml := cXml

//Executa rotina para retirar os caracteres especiais
//cXml := u_zCarEspec( cXml )

oXml := XmlParser(cXml, "_", @cError, @cWarning )

//retorna o backup do xml
//cXml := cBkpXml

If oXml == NIL .Or. !Empty(cError)

	cError := ""
	cWarning := ""

	cXml := NoAcento((xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML"))))
	cXml := EncodeUTF8(cXml)

	//Faz backup do xml sem retirar os caracteres especiais
	cBkpXml := cXml

	//Executa rotina para retirar os caracteres especiais
	cXml := u_zCarEspec( cXml )

	oXml := U_PARSGDE( cXml, @cError, @cWarning )

	//retorna o backup do xml
	cXml := cBkpXml

Endif

If oXml == NIL .Or. !Empty(cError)

	MsgSTOP("XML Invalido Refaça sua Importação.")
	Return( .F. )

EndIf

aAdd( aCombo, "1=Padrão(SA5/SA7)" )
aAdd( aCombo, "2=Customizada("+xZB5+")")
aAdd( aCombo, "3=Sem Amarração"   )
cAmarra := iif( cAmarra=="4", "0", cAmarra )

aadd(aPerg,{2,"Amarração Produto","",aCombo,120,".T.",.T.,".T."})
aParam[01] := ParamLoad(cParXMLExp,aPerg,1,aParam[01])
If cAmarra == "0" //.And. !cModelo $ "57"
	If !ParamBox(aPerg,"Importa XML - Amarração",@aParam,,,,,,,cParXMLExp,.T.,.T.)
		Return( .F. )
	Else 
   		cAmarra  := aParam[01]
	EndIf
EndIf

cTipoCPro := cAmarra

oDet := oXml:_NFEPROC:_NFE:_INFNFE:_DET
oDet := IIf(ValType(oDet)=="O",{oDet},oDet)

Do while nErrItens < 2
	DbSelectarea( "TMP" )
	ZAP
	nErrItens++
 	lRet     := .T.
 	aProdOk  := {}
 	aProdNo  := {}
	For i := 1 To len(oDet)
		cDesc   := oDet[i]:_Prod:_XPROD:TEXT
		cProd   := TrocaAspas( oDet[i]:_Prod:_CPROD:TEXT )
		if .NOT. HFXML09Prd(@cProd,@cDesc,cTipoCPro)
			Loop
		endif
		cUN     := oDet[i]:_Prod:_UCOM:TEXT
		nQuant  := VAL(oDet[i]:_Prod:_QCOM:TEXT)
		nVunit  := VAL(oDet[i]:_Prod:_VUNCOM:TEXT)
		nTotal  := VAL(oDet[i]:_Prod:_VPROD:TEXT)
		cPedido := " "
		cAux    := "oDet[i]:_PROD:_XPED:TEXT"
		if type( cAux ) <> "U"
			cPedido := &cAux
		endif
		cItPed  := " "
		cAux    := "oDet[i]:_PROD:_NITEMPED:TEXT"
		if type( cAux ) <> "U"
			cItPed  := &cAux
		endif
		RecLock( "TMP", .T. )
		TMP->OK    := " "
		For nI := 2 to TMP->( FCount() )
			cCampo := TMP->( FieldName( nI ) )
			lCampo := .T.
			if cCampo == x_ZBB_+"PROD"
				valoire := cProd
			elseif cCampo == x_ZBB_+"DESC"
				valoire := cDesc
			elseif cCampo == x_ZBB_+"QUANT"
				valoire := nQuant
			elseif cCampo == x_ZBB_+"VUNIT"
				valoire := nVunit
			elseif cCampo == x_ZBB_+"TOTAL"
				valoire := nTotal
			elseif cCampo == x_ZBB_+"UN"
				valoire := cUN
			elseif cCampo == x_ZBB_+"PEDIDO"
				valoire := cPedido
			elseif cCampo == x_ZBB_+"ITEM"
				valoire := cItPed 
			elseif cCampo == x_ZBB_+"AMARRA"
				valoire := cTipoCPro
			else
				lCampo := .F.
			endif
			if lCampo
				TMP->( FieldPut( nI, valoire ) ) 
			endif
		Next nI
		DbSelectArea( x_ZBB )
		DbSeek( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))) + (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR"))) +;
				 (xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR"))) + cProd, .T. )
		Do While .NOT. (x_ZBB)->( Eof() ) .AND. (xZBZ)->&(xZBZ_+"FILIAL") == (x_ZBB)->&(x_ZBB_+"FILIAL") .AND.;
		    (xZBZ)->&(xZBZ_+"CODFOR") == (x_ZBB)->&(x_ZBB_+"FORNEC") .AND. (xZBZ)->&(xZBZ_+"LOJFOR") == (x_ZBB)->&(x_ZBB_+"LOJA") .AND.;
		    cProd == (x_ZBB)->&(x_ZBB_+"PROD")
		    lInc := .T.
		    dbSelectArea( "TMP" )
		    dbSetOrder( 2 )
		    If DbSeek( (x_ZBB)->&(x_ZBB_+"PROD") + (x_ZBB)->&(x_ZBB_+"PEDIDO") + (x_ZBB)->&(x_ZBB_+"ITEM") )
		    	lInc := .F.
		    EndIf
			RecLock( "TMP", lInc )
			TMP->OK := iif( (x_ZBB)->&(x_ZBB_+"ATUAL") == "S", cMarcaOK, " " )
			For nI := 2 to TMP->( FCount() )
				cCampo := TMP->( FieldName( nI ) )
				If Empty(cCampo)
					lCampo := .F.
				Else
					lCampo := .T.
					If cCampo == "SALDO"
						valoire := 0
						SC7->( dbSetOrder( 1 ) )
						if SC7->( dbSeek( xFilial( "SC7" ) + (x_ZBB)->&(x_ZBB_+"PEDIDO") + (x_ZBB)->&(x_ZBB_+"ITEM") ) )
							valoire := SC7->C7_QUANT-SC7->C7_QUJE-SC7->C7_QTDACLA
	                    EndIF
					Else
						valoire := (x_ZBB)->&(cCampo)
					EndIf
				Endif
				if lCampo
					TMP->( FieldPut( nI, valoire ) ) 
				endif
			Next nI
			DbSelectArea( x_ZBB )
			(x_ZBB)->( DbSkip() )
		EndDo
	
		DbSelectArea( "TMP" )
		TMP->( MsUnLock() )
	    TMP->( dbSetOrder( 1 ) )
	Next i

	//Itens não encontrados
	if .not. ItNaoEnc( "PDRC", aProdOk, aProdNo, , @nErrItens )
	    lRet := .F.
		Loop
	endif
	Exit //só para o nErrItens checar o erro, caso ele inclua pelo DePara a 2a vez estará certo e ele continuará com o aitens preenchido
EndDo

Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HFXML09Brwº Autor ³ Eneovaldo Roveri Jrº Data ³  19/02/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Browse da Tabela Temporária                                º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function HFXML09Brw()
Local lRet      := .T.
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
Local aStruTT	:= TMP->( dbStruct() )
Local nPosGetLoja:= IIF(TamSX3("A2_COD")[1]< 10,(2.5*TamSX3("A2_COD")[1])+(110),(2.8*TamSX3("A2_COD")[1])+(100))
Local nCombo    := 1
Local bCabOk
Local oCodRet
Local oCombo

Private lSharedA2:= U_IsShared("SA2")
Private cCodRet	 := Space(Len(SE2->E2_CODRET))
Private cFormul  := "N"
Private cTipo    := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC")))
Private cNFiscal := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA")))
Private cSerie	 := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE")))
Private dDEmissao:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"DTNFE")))
Private cA100For := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR")))
Private cLoja    := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR")))
Private cEspecie := iif( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO"))) == "55", "SPED", "CTE" )
Private cUfOrig  := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"UF")))

aCpos := {}
Aadd( aCpos, {"OK"   ,,"" } )
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek( x_ZBB )
While !Eof().And.( x3_arquivo == x_ZBB )
	If aScan( aStruTT, { |x| AllTrim(x[1]) == AllTrim(x3_campo) } ) > 0
		Aadd( aCpos, {AllTrim(x3_campo),,TRIM(x3_titulo),x3_picture } )
	EndIf
	DbSkip()
End

aCores := {}
aAdd(aCores,{"TMP->SALDO > 0 .Or. Empty(TMP->"+x_ZBB_+"PEDIDO)","BR_VERDE"	})
aAdd(aCores,{"TMP->SALDO <= 0 .And. .NOT. Empty(TMP->"+x_ZBB_+"PEDIDO)","BR_VERMELHO"	})


SetKEY( VK_F7 , {|| U_HFXML09P()})
aAdd(aButtons,{'CHECKED',{ || U_HFXML09P() }, "Informar Pedido", "Pedido [F7]"})


dbSelectArea("TMP")
//COUNT TO nQtdReg
TMP->( dbGotop() )

aSizeAut := MsAdvSize(,.F.,400)
aObjects := {}
aadd( aObjects, { 0,    41, .T., .F. } )
aadd( aObjects, { 100, 100, .T., .T. } )
//aadd( aObjects, { 0,    75, .T., .F. } )
aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )
aPosGet := MsObjGetPos(aSizeAut[3]-aSizeAut[1],310,;
				{{8,35,75,100,194,220,260,280},;
				{8,35,75,100,nPosGetLoja,194,220,260,280},;
				{5,70,160,205,295},;
				{6,34,200,215},;
				{6,34,75,103,148,164,230,253},;
				{6,34,200,218,280},;
				{11,50,150,190},;
				{273,130,190,293,205}})

DEFINE MSDIALOG oDlg TITLE "PEDIDO RECORRENTE" From aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] PIXEL  //of oMainWnd

U_XmlCabDc(oDlg,{aPosGet[1],aPosGet[2],aPosObj[1]},@bCabOk,.F.,.F.,cUfOrig,,@nCombo,@oCombo,@cCodRet,@oCodRet,,,,)

oMarkBw:=MsSelect():New("TMP","OK","",aCpos,@lInverte,@cMarcaOK,{aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4]},,,,,aCores) //oFolder:aDialogs[1]

oMarkBw:oBrowse:Refresh()
oMarkBw:oBrowse:lhasMark    := .T.
oMarkBw:oBrowse:lCanAllmark := .T.
//oMarkBw:oBrowse:Align       := CONTROL_ALIGN_ALLCLIENT	//Usado no modelo FLAT


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Permite selecao se não for visualizacao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//oMarkBw:oBrowse:bAllMark    := { || HFXML09Inv(cMarcaOK,@oMarkBw) }
oMarkBw:oBrowse:bChange     := { || HFXML09Chg(@oMarkBw) }
oMarkBw:BMark               := { || HFXML09Dis(@oMarkBw,cMarcaOK) }
oMarkBw:oBrowse:ACOLUMNS[2]:LEDIT := .T.

ACTIVATE MSDIALOG oDlg CENTERED  ON INIT EnchoiceBar(oDlg,;
{|| processa({|| HFXML09Grv(@oMarkBw)}, "Baixar..."),iif( msgYesNo("Dados Atualizados. Deseja Sair?","Pegunta"),oDlg:End(),lOk := .F. ) },;
{|| iif( msgYesNo("Deseja Sair Sem Gravar?","Pegunta"),oDlg:End(),lOk := .F. )},,aButtons)

Return( lRet )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HFXML09Disº Autor ³ Eneovaldo Roveri Jrº Data ³  19/02/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Marcar Registro                                            º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function HFXML09Dis(oMarkBw, cMarcaOK)
Local aGetArea := GetArea()

If TMP->SALDO == 0
	RecLock("TMP", .F.)
	TMP->OK	:= "  "
	TMP->( MsUnLock() )
EndIf

oMarkBw:oBrowse:Refresh(.T.)

RestArea( aGetArea )
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HFXML09Chgº Autor ³ Eneovaldo Roveri Jrº Data ³  19/02/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Atualizar Registro Marcado/Desmarcado                      º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function HFXML09Chg(oMarkBw)
Local cRetFun		:= " "

oMarkBw:oBrowse:Refresh(.T.)

Return cRetFun


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HFXML09Grvº Autor ³ Eneovaldo Roveri Jrº Data ³  19/02/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Gravar Dados na Tabela de Pedido Recorrente                º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function HFXML09Grv(oMarkBw)
Local lRet := .T.
Local lInc := .F.
Local nI   := 0
Local xZBB_:= iif(Substr(x_ZBB,1,1)=="S", Substr(x_ZBB,2,2), Substr(x_ZBB,1,3)) + "_"
Local cChv := xZBB_+"PROD+"+xZBB_+"PEDIDO+"+xZBB_+"ITEM"
Local nRec := TMP->( RECNO() )
Local cCampo := ""

dbSelectArea( "TMP" )
TMP->( DbGoTop() )
Do While .NOT. TMP->( Eof() )
	IF empty( TMP->&(xZBB_+"PEDIDO") ) .or. Empty( TMP->&(xZBB_+"ITEM") ) .or. empty( TMP->&(xZBB_+"TES") )
		TMP->( DbSkip() )  //Não grava sem pedido nem TES.
		Loop
	EndIf
	If (x_ZBB)->( dbSeek( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))) + (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR"))) +;
	                      (xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR"))) + TMP->&(cChv) ) )
		lInc := .F.
	Else
		lInc := .T.
	EndIf
	dbSelectArea( x_ZBB )
	RecLock( x_ZBB, lInc )
	(x_ZBB)->&(x_ZBB_+"FILIAL") := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL")))
	(x_ZBB)->&(x_ZBB_+"FORNEC") := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR")))
	(x_ZBB)->&(x_ZBB_+"LOJA")   := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR")))
	(x_ZBB)->&(x_ZBB_+"ATUAL")  := iif( .Not. Empty( TMP->OK ), "S", " " )
	For nI := 2 to TMP->( FCount() )
		cCampo := TMP->( FieldName( nI ) )
		If (x_ZBB)->(FieldPos(cCampo)) > 0
	   		(x_ZBB)->(FieldPut( (x_ZBB)->(FieldPos(cCampo)), TMP->( FieldGet( nI ) ) ) )
		EndIf
	Next nI
	(x_ZBB)->( dbCommit() )
	(x_ZBB)->( MsUnLock() )
	dbSelectArea( "TMP" )
	TMP->( dbSkip() )
EndDo

TMP->( dbGoTo( nRec ) )
Return( .T. )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³U_XmlCabDcº Autor ³ Eneovaldo Roveri Jrº Data ³  19/02/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Mostrar Cabeçãlho do XML                                   º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function XmlCabDc(oDlg,aPosGet,bRefresh,lVisual,lFiscal,cUfOrig,lPreNota,nCombo,oCombo,cCodRet,oCodRet,lNfMedic,aCodR,cRecIss,cNatureza)
	
Local aObjetos   := Array(10)
Local aCombo1    := {	"Normal",;
						"Devolucao",;
						"Beneficiamento",;
						"Compl.  ICMS",;
						"Compl.  IPI",;
						"Compl. Preco/Frete"}

Local aCombo2    := {"Nao","Sim"}
Local aCombo2Lan := {"1","2","3"}
Local aAuxCombo1 := {"N","D","B","I","P","C"}
Local aAuxCombo2 := {"N","S","Y"}

Local c103SayForn:= RetTitle( xZBZ_+"CODFOR" )
Local c103Tipo	 := ""
Local c103Form	 := cFormul
Local cCar       := CHR(34)+CHR(39)        // Caracteres que não serão permitidos na digitação do campo: Nota e Série
Local nAux       := aScan(aAuxCombo1,cTipo)
Local lGspInUseM := If(Type('lGspInUse')=='L', lGspInUse, .F.)
Local nTamGetFor := 45          
Local nScreen    := GetScreenRes()[1]
Local nEspLoja   := 0 
Local nAltNFE    := 0

Local lUfOrig    := ( ValType( cUfOrig ) == "C" )
Local oNfMedic   := .F. 

cFormul := If( ValType( cFormul ) <> "C" .Or. Empty(cFormul) , "N", cFormul ) 

DEFAULT lPreNota 	:= .F.
Default aCodR	 	:= {}
Default cRecIss	 	:= "1"
Default cNatureza	:= ""

If lPreNota
	nEspLoja   := Iif(nScreen<1280 .And. !lVisual, 5,-3)
Else
	nEspLoja   := Iif(nScreen<1280 .And. !lVisual, 5,1)
EndIF					
nAltNFE    := Iif(lPreNota .And. ALTERA  ,15 ,0)   

aCombo1    := IIF(lPreNota,{"Normal","Devolucao","Beneficiamento"},{"Normal","Devolucao","Beneficiamento","Compl.  ICMS","Compl.  IPI","Compl. Preco/Frete"})
aAuxCombo1 := IIF(lPreNota,{"N","D","B"},{"N","D","B","I","P","C"})
nAux       := aScan(aAuxCombo1,cTipo)

If !Empty(cTipo) .And. nAux <> 0
	c103Tipo := aCombo1[nAux]
EndIf
nAux := aScan(aAuxCombo2,cFormul)
If !Empty(cFormul) .And. nAux <> 0
	c103Form := aCombo2Lan[nAux]
EndIf

If !lNfMedic
	If TamSX3("A2_COD")[1]< 9 
		nTamGetFor:=(6*TamSX3("A2_COD")[1])
	ElseIf TamSX3("A2_COD")[1]< 15
		nTamGetFor:=(4.8*TamSX3("A2_COD")[1])
	Else
		nTamGetFor:=(4*TamSX3("A2_COD")[1])
	EndIf
EndIf
@ aPosGet[3,1],aPosGet[3,2] TO aPosGet[3,3],aPosGet[3,4] LABEL "" OF oDlg PIXEL

@ aPosGet[3,1]+(2,6),aPosGet[1,1] SAY RetTitle( xZBZ_+"TPDOC" ) OF oDlg PIXEL SIZE 35,09
@ aPosGet[3,1]+(2,5),aPosGet[1,2] MSCOMBOBOX aObjetos[1] VAR c103Tipo ITEMS aCombo1 SIZE 50,90;
	WHEN !lVisual ;
	OF oDlg PIXEL

If !lGspInUseM
	@ aPosGet[3,1]+(2,6),aPosGet[1,3] SAY RetTitle("F1_FORMUL") Of oDlg PIXEL SIZE 52,09
	@ aPosGet[3,1]+(2,5),aPosGet[1,4] MSCOMBOBOX aObjetos[2] VAR c103Form ITEMS aCombo2 SIZE 25,50 ;
		WHEN !lVisual ;
		OF oDlg PIXEL                            
Endif

@ aPosGet[3,1]+(2,6),aPosGet[1,5] SAY RetTitle( xZBZ_+"NOTA" ) Of oDlg PIXEL SIZE 45,09
@ aPosGet[3,1]+(2,5),aPosGet[1,6] MSGET aObjetos[3] VAR cNFiscal PICTURE PesqPict("SF1","F1_DOC") ;
	WHEN !lVisual  ;
	OF oDlg PIXEL SIZE 34,09 
	
@ aPosGet[3,1]+(2,6),aPosGet[1,7] SAY RetTitle( xZBZ_+"SERIE" ) Of oDlg PIXEL SIZE 23,09
@ aPosGet[3,1]+(2,5),aPosGet[1,8] MSGET aObjetos[4] VAR cSerie  PICTURE PesqPict("SF1","F1_SERIE") ;
    WHEN !lVisual ;
	OF oDlg PIXEL SIZE 18,09
	
@ aPosGet[3,1]+25,aPosGet[2,1] SAY RetTitle( xZBZ_+"DTNFE" ) OF oDlg PIXEL SIZE 35,09
@ aPosGet[3,1]+24,aPosGet[2,2] MSGET aObjetos[5] VAR dDEmissao PICTURE PesqPict(xZBZ,xZBZ_+"DTNFE") ;
	WHEN !lVisual ;
	OF oDlg PIXEL SIZE 45 ,9 HASBUTTON

@ aPosGet[3,1]+25,aPosGet[2,3]-10 SAY aObjetos[6] VAR c103SayForn Of oDlg PIXEL SIZE 43,09
@ aPosGet[3,1]+24,aPosGet[2,4]-nAltNFE MSGET aObjetos[7] VAR cA100For  ;
	PICTURE PesqPict(xZBZ,xZBZ_+"CODFOR") F3 CpoRetF3(xZBZ_+"CODFOR");
	WHEN !lVisual ;
	OF oDlg PIXEL SIZE nTamGetFor,09 HASBUTTON 
		
@ aPosGet[3,1]+24,aPosGet[2,5]+nEspLoja MSGET aObjetos[8] VAR cLoja ;
	PICTURE PesqPict(xZBZ,xZBZ_+"LOJFOR") ;
	WHEN !lVisual ;
	OF oDlg PIXEL SIZE 15,09 HASBUTTON

If !lGspInUseM
	
	@ aPosGet[3,1]+25,aPosGet[2,6]+nAltNFE SAY RetTitle("F1_ESPECIE") Of oDlg PIXEL SIZE 63,09
	@ aPosGet[3,1]+24,aPosGet[2,7]+nAltNFE MSGET aObjetos[9] VAR cEspecie ;
		PICTURE PesqPict("SF1","F1_ESPECIE") ;
		WHEN !lVisual;
		OF oDlg PIXEL SIZE 30,09 HASBUTTON

	If lUfOrig
		@ aPosGet[3,1]+25,aPosGet[2,8]+nAltNFE SAY OemToAnsi("UF.Origem") Of oDlg PIXEL SIZE 63 ,9
		@ aPosGet[3,1]+24,aPosGet[2,9]+nAltNFE MSGET cUfOrig PICTURE "@!" F3 "12" ;
			When !lVisual ;
			OF oDlg PIXEL SIZE 20,9 HASBUTTON
	EndIf

Endif        

//bRefresh := {|| NfeCabOk(lVisual,aObjetos[1],aObjetos[3],aObjetos[5],aObjetos[7],aObjetos[8],lFiscal,cUfOrig)}
bRefresh := {|| .T.}
aObjetos[1]:SetFocus()

Return(.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³U_HFXML09Pº Autor ³ Eneovaldo Roveri Jrº Data ³  10/03/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Tela para informar os Pedidos Itens e TES                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PEDIDO RECORRENTE                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function HFXML09P()
Local aArea     := GetArea()
Local aButtons  := {}
Local nReg      := TMP->( recno() )
Local dMaiorEmi := ctod( " " )
Local aVetor    := {}
Local nQtdReg   := 0
Local nSaldo    := 0
Local oDlg09

PRIVATE oProd,oDesc,oPedido,oItem,oTes
PRIVATE cProd    := TMP->&(x_ZBB_+"PROD")
PRIVATE cDesc    := TMP->&(x_ZBB_+"DESC")
PRIVATE	cPedido	 := TMP->&(x_ZBB_+"PEDIDO")
PRIVATE	cItem    := TMP->&(x_ZBB_+"ITEM")
PRIVATE	cTES	 := TMP->&(x_ZBB_+"TES")
PRIVATE _lOk     := .F.
PRIVATE cConsulta:= ""

While .T.

   	PcoIniLan("000005")

	DEFINE MSDIALOG oDlg09 FROM	31,15 TO 380,480 TITLE "Informar Pedido"  PIXEL OF oMainWnd
	@ 030    , 007 SAY "Produto"	SIZE 40,09 OF oDlg09 PIXEL
	@ 028    , 050 MSGET oProd VAR cProd SIZE 60,09 OF oDlg09 PIXEL HASBUTTON
	oProd:lReadOnly := .T.
	@ 050    , 007 SAY "Descrição"	SIZE 40,09 OF oDlg09 PIXEL
	@ 048    , 050 MSGET oDesc VAR cDesc SIZE 100,09 OF oDlg09 PIXEL HASBUTTON
	oDesc:lReadOnly := .T.

	@ 070    , 007 SAY "Pedido"	SIZE 40,09 OF oDlg09 PIXEL
	@ 068    , 050 MSGET oPedido VAR cPedido SIZE 35,09 OF oDlg09 PIXEL HASBUTTON F3 "U_XML09PC()" Valid U_XML09VPC( "PEDIDO" )
	oPedido:SetFocus()
	@ 090    , 007 SAY "Item"  SIZE 40,09 OF oDlg09 PIXEL
	@ 088    , 050 MSGET oItem VAR cItem SIZE 35,09 OF oDlg09 PIXEL HASBUTTON Valid U_XML09VPC( "ITEM" )
	@ 110    , 007 SAY "TES"  SIZE 40,09 OF oDlg09 PIXEL
	@ 108    , 050 MSGET oTes VAR cTES SIZE 22,10 OF oDlg09 PIXEL HASBUTTON F3 "SF4" Valid U_XML09VPC( "TES" )

	ACTIVATE MSDIALOG oDlg09 ON INIT EnchoiceBar(oDlg09,{ ||_lOk:=.T., oDlg09:End() }, {||_lOk:=.F., iif( msgYesNo("Deseja Cancelar Alteração ?","Pegunta"),oDlg09:End(),_lOk := .T. ) } ) CENTERED

	if !_lOk
		Exit
	endif

	If .NOT. U_XML09VPC( "FINAL" )
		Loop
	EndIf

	nSaldo := 0
	SC7->( dbSetOrder( 1 ) )
	if SC7->( dbSeek( xFilial( "SC7" ) + cPedido + cItem ) )
		nSaldo := SC7->C7_QUANT-SC7->C7_QUJE-SC7->C7_QTDACLA
    EndIF

	DbSelectArea( "TMP" )
	RecLock( "TMP", .F. )
	TMP->&(x_ZBB_+"PEDIDO") := cPedido
	TMP->&(x_ZBB_+"ITEM")   := cItem
	TMP->&(x_ZBB_+"TES")    := cTES
	TMP->SALDO              := nSaldo
	TMP->( dbCommit() )
	TMP->( MsUnLock() )
	Exit
Enddo

RestArea( aArea )
TMP->( dbgoto( nReg ) )
Return(.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TrocaAspasº Autor ³ Eneovaldo Roveri Jrº Data ³  23/02/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ troca ' por " -> Isto serve para quando o código do produtoº±±
±±º          ³ vem com ', pois o SA5/SA7 é feito query a qual utiliza-se 'º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ IMPORTA XML                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TrocaAspas( cCod )
Local cRet := cCod

cRet := StrTran(cRet,"'",'"')  //troca ' por " -> Isto serve para quando o código do produto vem com ', pois o SA5/SA7 é feito query a qual utiliza-se de '

Return( cRet )



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HFXML09Prdº Autor ³ Eneovaldo Roveri Jrº Data ³  19/02/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Amarração do Itens para procurar código interno no pedido  º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function HFXML09Prd(cProdX,cDesc,cTipoCPro)
Local aGetArea := GetArea()
Local cProduto := ""
Local lRetorno := .F.
Private cCodEmit  := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR")))
Private cLojaEmit := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR")))

If cTipoCPro == "2" // Ararracao Customizada ZB5 Produto tem que estar Amarrados Tanto Cliente como Formecedor
	cProduto := ""
	If (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC"))) $ "D|B"
		DbSelectArea(xZB5)
		DbSetOrder(2)
		// Filial + CNPJ CLIENTE + Codigo do Produto do Fornecedor
		If DbSeek(xFilial(xZB5)+PADR((xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))),14)+cProdX)
			cProduto := (xZB5)->(FieldGet(FieldPos(xZB5_+"PRODFI"))) //ZB5->ZB5_PRODFI
			lRetorno := .T.
			aadd(aProdOk,{cProdX,cDesc} )
		Else
			aadd(aProdNo,{cProdX,cDesc} )
		EndIf
	Else
		DbSelectArea(xZB5)
		DbSetOrder(1)
		// Filial + CNPJ FORNECEDOR + Codigo do Produto do Fornecedor
		If DbSeek(xFilial(xZB5)+PADR((xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))),14)+cProdX)
			cProduto := (xZB5)->(FieldGet(FieldPos(xZB5_+"PRODFI")))
			cDesc    := (xZB5)->(FieldGet(FieldPos(xZB5_+"DESCPR")))
			lRetorno := .T.
			aadd(aProdOk,{cProdX,cDesc} )
		Else
			aadd(aProdNo,{cProdX,cDesc} )
		EndIf
	EndIF

ElseIf cTipoCPro == "1" // Amarracao Padrao SA5/SA7

	If (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC"))) $ "D|B" // dDevolução / Beneficiamento ( utiliza Cliente )

		cProduto  := ""
		if empty( cCodEmit )
			cCodEmit  := Posicione("SA1",3,xFilial("SA1")+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))),"A1_COD")
			cLojaEmit := Posicione("SA1",3,xFilial("SA1")+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))),"A1_LOJA")
		endif

		cAliasSA7 := GetNextAlias()

		cWhere := "%(SA7.A7_CODCLI IN ("
		cWhere += "'"+cProdX+"'"
		cWhere += ") )%"

		BeginSql Alias cAliasSA7

		SELECT	A7_FILIAL, A7_CLIENTE, A7_LOJA, A7_CODCLI, A7_PRODUTO, R_E_C_N_O_ 
				FROM %Table:SA7% SA7
				WHERE SA7.%notdel%
	    		AND A7_CLIENTE = %Exp:cCodEmit%
	    		AND A7_LOJA = %Exp:cLojaEmit%
	    		AND %Exp:cWhere%
	    		ORDER BY A7_FILIAL, A7_CLIENTE, A7_LOJA, A7_CODCLI
		EndSql

		DbSelectArea(cAliasSA7)            
		Dbgotop()
        lFound := .F.
        cKeySa7:= xFilial("SA7")+cCodEmit+cLojaEmit+cProdX
        While !(cAliasSA7)->(EOF())
			cKeyTMP := (cAliasSA7)->A7_FILIAL+(cAliasSA7)->A7_CLIENTE+(cAliasSA7)->A7_LOJA+(cAliasSA7)->A7_CODCLI
			If 	AllTrim(cKeySa7) == AllTrim(cKeyTMP)
        		lFound := .T.
        		Exit
        	Endif
        	(cAliasSA7)->(DbSkip())
        Enddo

		If lFound
			cProduto := (cAliasSA7)->A7_PRODUTO
			lRetorno := .T.
			aadd(aProdOk,{cProdX,cDesc} )
		Else
			aadd(aProdNo,{cProdX,cDesc} )
		EndIf

		(cAliasSA7)->(bCloseArea())

	Else
		cProduto  := ""
		if empty( cCodEmit )
			cCodEmit  := Posicione("SA2",3,xFilial("SA2")+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))),"A2_COD")
			cLojaEmit := Posicione("SA2",3,xFilial("SA2")+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))),"A2_LOJA")
		endif

		cAliasSA5 := GetNextAlias()

		cWhere := "%(SA5.A5_CODPRF IN ("				               
		cWhere += "'"+cProdX+"'"
		cWhere += ") )%"				               	

		BeginSql Alias cAliasSA5

		SELECT	A5_FILIAL, A5_FORNECE, A5_LOJA, A5_CODPRF, A5_PRODUTO, A5_NOMPROD, R_E_C_N_O_ 
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
        cKeySa5:= xFilial("SA5")+cCodEmit+cLojaEmit+cProdX
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
			cDesc    := (cAliasSA5)->A5_NOMPROD
			lRetorno := .T.
			aadd(aProdOk,{cProdX,cDesc} )
		Else         
			aadd(aProdNo,{cProdX,cDesc} )				
		EndIf

		(cAliasSA5)->( dbCloseArea() )
	EndIF          		

ElseIf cTipoCPro = "3" // Mesmo Codigo Nao requer amarracao SB1
	DbSelectArea("SB1")
	DbSetOrder(1)
	If DbSeek(xFilial("SB1")+cProdX)
		cProduto := Substr(cProdX,1,15)
		lRetorno := .T.
		cDesc    := SB1->B1_DESC
		aadd(aProdOk,{cProdX,cDesc} )
	Else
		aadd(aProdNo,{cProdX,cDesc} )
	EndIF
EndIf

cProdX := cProduto

RestArea( aGetArea )
Return( lRetorno )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ItNaoEnc º Autor ³ Eneovaldo Roveri Jrº Data ³  19/02/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Para Chamar Tela das divergencia das amarrações dos itens. º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//cTipoProc -> PDRC -> Pedido Recorrente
Static Function ItNaoEnc( cTipoProc, aProdOk, aProdNo, aProdVl, nErrItens, aProdZr )
Local lRet   := .T.

Default aProdOk := {}
Default aProdNo := {}
Default aProdVl := {}
Default aProdZr := {}

lRet := U_ItNEnc( cTipoProc, aProdOk, aProdNo, aProdVl, @nErrItens, aProdZr )

Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³U_XML09PC º Autor ³ Eneovaldo Roveri Jrº Data ³  19/02/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Tela de Consulta de Pedido de Compra.                      º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/*
PC => Pedido de Compra
*/
User Function XML09PC(aPedido,lNfMedic,lConsMedic,aHeadSDE,aColsSDE)
Local cSeek			:= ""
Local nOpca			:= 0
Local aArea			:= GetArea()
Local aAreaSA2		:= SA2->(GetArea())
Local aAreaSC7		:= SC7->(GetArea())
Local aAreaSB1		:= SB1->(GetArea())
Local aRateio       := {0,0,0}
Local aNew			:= {}
Local aTamCab		:= {}
Local lGspInUseM	:= If(Type('lGspInUse')=='L', lGspInUse, .F.)
Local aButtons		:= { {'PESQUISA',{||A103VisuPC(aArrSldo[oQual:nAt][2])},OemToAnsi("Visualiza Pedido"),OemToAnsi("Pedido")},; //"Visualiza Pedido"
	{'pesquisa',{||A103PesqP(aCab,aCampos,aArrayF4,oQual)},OemToAnsi("Pesquisar")} } //"Pesquisar"
Local aEstruSC7		:= SC7->( dbStruct() )
Local bSavSetKey	:= SetKey(VK_F4,Nil)
Local bSavKeyF5		:= SetKey(VK_F5,Nil)
Local bSavKeyF6		:= SetKey(VK_F6,Nil)
Local bSavKeyF7		:= SetKey(VK_F7,Nil)
Local bSavKeyF8		:= SetKey(VK_F8,Nil)
Local bSavKeyF9		:= SetKey(VK_F9,Nil)
Local bSavKeyF10	:= SetKey(VK_F10,Nil)
Local bSavKeyF11	:= SetKey(VK_F11,Nil)
Local nFreeQt		:= 0 
Local cVar			:= cProd
Local cQuery		:= ""
Local cAliasSC7		:= "_SC7"
Local cCpoObri		:= ""
Local nSavQual
Local nPed			:= 0
Local nX			:= 0
Local nAuxCNT		:= 0
Local lMt103Vpc		:= ExistBlock("MT103VPC")
Local lMt100C7D		:= ExistBlock("MT100C7D")
Local lMt100C7C		:= ExistBlock("MT100C7C")
Local lMt103Sel		:= ExistBlock("MT103SEL")
Local nMT103Sel     := 0
Local nSelOk        := 1
Local lRet103Vpc	:= .T.
Local lContinua		:= .T.
Local lQuery		:= .F.
Local oQual
Local oDlg
Local oPanel
Local aUsButtons  := {}
Local LCONSLOJA   := .T.

PRIVATE aCab	   := {}
PRIVATE aCampos	   := {}
PRIVATE aArrSldo   := {}
PRIVATE aArrayF4   := {}

DEFAULT aPedido	   := {}
DEFAULT lNfMedic   := .F.
DEFAULT lConsMedic := .F.
DEFAULT aHeadSDE   := {}
DEFAULT aColsSDE   := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impede de executar a rotina quando a tecla F3 estiver ativa		    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("InConPad") == "L"
	lContinua := !InConPad
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona botoes do usuario na EnchoiceBar                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "MTIPCBUT" )
	If ValType( aUsButtons := ExecBlock( "MTIPCBUT", .F., .F. ) ) == "A"
		AEval( aUsButtons, { |x| AAdd( aButtons, x ) } )
	EndIf
EndIf

If lContinua

	#IFDEF TOP
		DbSelectArea("SC7")
		If TcSrvType() <> "AS/400"

			If Empty(cVar)
				DbSetOrder(9)
			Else
				DbSetOrder(6)
			EndIf

			lQuery    := .T.
			cAliasSC7 := "QRYSC7"

			cQuery	  := "SELECT "
			For nAuxCNT := 1 To Len( aEstruSC7 )
				If nAuxCNT > 1
					cQuery += ", "
				EndIf
				cQuery += aEstruSC7[ nAuxCNT, 1 ]
			Next
			cQuery += ", R_E_C_N_O_ RECSC7 FROM"
			cQuery += RetSqlName("SC7") + " SC7 "
			cQuery += "WHERE "
			cQuery += "C7_FILENT = '"+xFilEnt(xFilial("SC7"))+"' AND "

			If HasTemplate( "DRO" ) .AND. FunName() == "MATA103" .AND. MV_PAR15 == 1
				cQuery += "C7_FORNECE IN ( " + T_DrogForn( cA100For ) + " ) AND "
			Else
				If Empty(cVar)
					If lConsLoja
						cQuery += "C7_FORNECE = '"+cA100For+"' AND "
						cQuery += "C7_LOJA = '"+cLoja+"' AND "
					Else
						cQuery += "C7_FORNECE = '"+cA100For+"' AND "
					Endif	
				Else
					If lConsLoja
						cQuery += "C7_FORNECE = '"+cA100For+"' AND "
						cQuery += "C7_LOJA = '"+cLoja+"' AND "
						cQuery += "C7_PRODUTO = '"+cVar+"' AND "
					Else
						cQuery += "C7_FORNECE = '"+cA100For+"' AND "
						cQuery += "C7_PRODUTO = '"+cVar+"' AND "
					Endif
				Endif
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Filtra os pedidos de compras de acordo com os contratos             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			If lConsMedic
				If lNfMedic
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Traz apenas os pedidos oriundos de medicoes                         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cQuery += "C7_CONTRA<>'"  + Space( Len( SC7->C7_CONTRA ) )  + "' AND "
					cQuery += "C7_MEDICAO<>'" + Space( Len( SC7->C7_MEDICAO ) ) + "' AND "		    		
				Else
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Traz apenas os pedidos que nao possuem medicoes                     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cQuery += "C7_CONTRA='"  + Space( Len( SC7->C7_CONTRA ) )  + "' AND "
					cQuery += "C7_MEDICAO='" + Space( Len( SC7->C7_MEDICAO ) ) + "' AND "		    		
				EndIf
			EndIf 					
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Filtra os Pedidos Bloqueados e Previstos.                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cQuery += "C7_TPOP <> 'P' AND "
			If SuperGetMV("MV_RESTNFE") == "S"
				cQuery += "C7_CONAPRO <> 'B' AND "
			EndIf					
			cQuery += "SC7.C7_ENCER='"+Space(Len(SC7->C7_ENCER))+"' AND "					
			cQuery += "SC7.C7_RESIDUO='"+Space(Len(SC7->C7_RESIDUO))+"' AND "					

			cQuery += "SC7.D_E_L_E_T_ = ' '"
			cQuery += "ORDER BY "+SqlOrder(SC7->(IndexKey()))	

			cQuery := ChangeQuery(cQuery)

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC7,.T.,.T.)
			For nX := 1 To Len(aEstruSC7)
				If aEstruSC7[nX,2]<>"C"
					TcSetField(cAliasSC7,aEstruSC7[nX,1],aEstruSC7[nX,2],aEstruSC7[nX,3],aEstruSC7[nX,4])
				EndIf
			Next nX										
		Else
	#ENDIF
			If Empty(cVar)
				DbSelectArea("SC7")
				DbSetOrder(9)
				If lConsLoja
					cCond := "C7_FILENT+C7_FORNECE+C7_LOJA"
					cSeek := cA100For+cLoja
					MsSeek(xFilEnt(xFilial("SC7"))+cSeek)
				Else
					cCond := "C7_FILENT+C7_FORNECE"
					cSeek := cA100For
					MsSeek(xFilEnt(xFilial("SC7"))+cSeek)
				EndIf
			Else
				DbSelectArea("SC7")
				DbSetOrder(6)
				If lConsLoja
					cCond := "C7_FILENT+C7_PRODUTO+C7_FORNECE+C7_LOJA"
					cSeek := cVar+cA100For+cLoja
					MsSeek(xFilEnt(xFilial("SC7"))+cSeek)
				Else
					cCond := "C7_FILENT+C7_PRODUTO+C7_FORNECE"
					cSeek := cVar+cA100For
					MsSeek(xFilEnt(xFilial("SC7"))+cSeek)
				EndIf
			EndIf
	#IFDEF TOP
		EndIf
	#ENDIF

	If Empty(cVar)
		cCpoObri := "C7_LOJA|C7_PRODUTO|C7_QUANT|C7_DESCRI|C7_TIPO|C7_LOCAL|C7_OBS"
	Else
		cCpoObri := "C7_LOJA|C7_QUANT|C7_DESCRI|C7_TIPO|C7_LOCAL|C7_OBS"
	Endif

	If (cAliasSC7)->(!Eof())

		DbSelectArea("SX3")
		DbSetOrder(2)

		If lNfMedic .And. lConsMedic

			MsSeek("C7_MEDICAO")

			AAdd(aCab,x3Titulo())
			Aadd(aCampos,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_CONTEXT,SX3->X3_PICTURE})
			aadd(aTamCab,CalcFieldSize(SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_PICTURE,X3Titulo()))

			MsSeek("C7_CONTRA")

			AAdd(aCab,x3Titulo())
			Aadd(aCampos,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_CONTEXT,SX3->X3_PICTURE})
			aadd(aTamCab,CalcFieldSize(SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_PICTURE,X3Titulo()))

			MsSeek("C7_PLANILH")

			AAdd(aCab,x3Titulo())
			Aadd(aCampos,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_CONTEXT,SX3->X3_PICTURE})
			aadd(aTamCab,CalcFieldSize(SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_PICTURE,X3Titulo()))

		EndIf 			

		MsSeek("C7_NUM")

		AAdd(aCab,x3Titulo())
		Aadd(aCampos,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_CONTEXT,SX3->X3_PICTURE})
		aadd(aTamCab,CalcFieldSize(SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_PICTURE,X3Titulo()))

		DbSelectArea("SX3")
		DbSetOrder(1)
		MsSeek("SC7")
		While !Eof() .And. SX3->X3_ARQUIVO == "SC7"
			IF ( SX3->X3_BROWSE=="S".And.X3Uso(SX3->X3_USADO).And. AllTrim(SX3->X3_CAMPO)<>"C7_PRODUTO" .And. AllTrim(SX3->X3_CAMPO)<>"C7_NUM" .And.;
					If( lConsMedic .And. lNfMedic, AllTrim(SX3->X3_CAMPO)<>"C7_MEDICAO" .And. AllTrim(SX3->X3_CAMPO)<>"C7_CONTRA" .And. AllTrim(SX3->X3_CAMPO)<>"C7_PLANILH", .T. )).Or.;
					(AllTrim(SX3->X3_CAMPO) $ cCpoObri)
				AAdd(aCab,x3Titulo())
				Aadd(aCampos,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_CONTEXT,SX3->X3_PICTURE})
				aadd(aTamCab,CalcFieldSize(SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_PICTURE,X3Titulo()))
			EndIf
			dbSkip()		
		Enddo					

		DbSelectArea(cAliasSC7)
		Do While If(lQuery, ;
				(cAliasSC7)->(!Eof()), ;
				(cAliasSC7)->(!Eof()) .And. xFilEnt(cFilial)+cSeek == &(cCond))

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Filtra os Pedidos Bloqueados, Previstos e Eliminados por residuo   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !lQuery
				If (SuperGetMV("MV_RESTNFE") == "S" .And. (cAliasSC7)->C7_CONAPRO == "B") .Or. ;
						(cAliasSC7)->C7_TPOP == "P" .Or. !Empty((cAliasSC7)->C7_RESIDUO)
					dbSkip()
					Loop
				EndIf
			Endif

			nFreeQT := 0

			nPed    := aScan(aPedido,{|x| x[1] = (cAliasSC7)->C7_NUM+(cAliasSC7)->C7_ITEM})

			nFreeQT -= If(nPed>0,aPedido[nPed,2],0)
			
			lRet103Vpc := .T.

			If lMt103Vpc
				If lQuery
					('SC7')->(dbGoto((cAliasSC7)->RECSC7))
				EndIf															
				lRet103Vpc := Execblock("MT103VPC",.F.,.F.)
			Endif

			If lRet103Vpc
				If ((nFreeQT := ((cAliasSC7)->C7_QUANT-(cAliasSC7)->C7_QUJE-(cAliasSC7)->C7_QTDACLA-nFreeQT)) > 0)
					Aadd(aArrayF4,Array(Len(aCampos)))							

					SB1->(DbSetOrder(1))
					SB1->(MsSeek(xFilial("SB1")+(cAliasSC7)->C7_PRODUTO))							
					For nX := 1 to Len(aCampos)

						If aCampos[nX][3] != "V"
							If aCampos[nX][2] == "N"
								If Alltrim(aCampos[nX][1]) == "C7_QUANT"
									aArrayF4[Len(aArrayF4)][nX] :=Transform(nFreeQt,PesqPict("SC7",aCampos[nX][1]))
								ElseIf Alltrim(aCampos[nX][1]) == "C7_QTSEGUM"
									aArrayF4[Len(aArrayF4)][nX] :=Transform(ConvUm(SB1->B1_COD,nFreeQt,nFreeQt,2),PesqPict("SC7",aCampos[nX][1]))
								Else
									aArrayF4[Len(aArrayF4)][nX] := Transform((cAliasSC7)->(FieldGet(FieldPos(aCampos[nX][1]))),PesqPict("SC7",aCampos[nX][1]))
								Endif											
							Else
								aArrayF4[Len(aArrayF4)][nX] := (cAliasSC7)->(FieldGet(FieldPos(aCampos[nX][1])))								
							Endif	
						Else
							aArrayF4[Len(aArrayF4)][nX] := CriaVar(aCampos[nX][1],.T.)
							If Alltrim(aCampos[nX][1]) == "C7_CODGRP"
								aArrayF4[Len(aArrayF4)][nX] := SB1->B1_GRUPO                            									
							EndIf
							If Alltrim(aCampos[nX][1]) == "C7_CODITE"
								aArrayF4[Len(aArrayF4)][nX] := SB1->B1_CODITE
							EndIf
						Endif

					Next

					aAdd(aArrSldo, {nFreeQT, IIF(lQuery,(cAliasSC7)->RECSC7,(cAliasSC7)->(RecNo()))})

					If lMT100C7D
						If lQuery
							('SC7')->(dbGoto((cAliasSC7)->RECSC7))
						EndIf									
						aNew := ExecBlock("MT100C7D", .f., .f., aArrayF4[Len(aArrayF4)])
						If ValType(aNew) = "A"
							aArrayF4[Len(aArrayF4)] := aNew
						EndIf
					EndIf
				EndIf
			Endif
			(cAliasSC7)->(dbSkip())
		EndDo

		If ExistBlock("MT100C7L")
			ExecBlock("MT100C7L", .F., .F., { aArrayF4, aArrSldo })
		EndIf

		If !Empty(aArrayF4)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta dinamicamente o bline do CodeBlock                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DEFINE MSDIALOG oDlg FROM 30,20  TO 265,521 TITLE OemToAnsi("Selecionar Pedido de Compra ( por item )") Of oMainWnd PIXEL //"Selecionar Pedido de Compra ( por item )"

			If lMT100C7C
				aNew := ExecBlock("MT100C7C", .f., .f., aCab)
				If ValType(aNew) == "A"
					aCab := aNew      
							    
					DbSelectArea("SX3")
	 				DbSetOrder(2)								
							
					For nX := 1 to Len(aCab)
				    	If aScan(aCampos,{|x| x[1]= aCab[nX]})==0
      						 If SX3->(MsSeek(aCab[nX]))				
      						 		Aadd(aCampos,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_CONTEXT,SX3->X3_PICTURE})
      						 EndIf
						EndIf
					Next nX
				EndIf
			EndIf

			@ 12,0 MSPANEL oPanel PROMPT "" SIZE 100,19 OF oDlg CENTERED LOWERED //"Botoes"
			oPanel:Align := CONTROL_ALIGN_TOP

			oQual := TWBrowse():New( 29,4,243,85,,aCab,aTamCab,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
			oQual:SetArray(aArrayF4)
			oQual:bLine := { || aArrayF4[oQual:nAT] }
			OQual:nFreeze := 1 

			oQual:Align := CONTROL_ALIGN_ALLCLIENT

			If !Empty(cVar)
				@ 6  ,4   SAY OemToAnsi("Produto") Of oPanel PIXEL SIZE 47 ,9 //"Produto"
				@ 4  ,30  MSGET cVar PICTURE PesqPict('SB1','B1_COD') When .F. Of oPanel PIXEL SIZE 80,9
			Else
				@ 6  ,4   SAY OemToAnsi("Selecione o Pedido de Compra") Of oPanel PIXEL SIZE 120 ,9 //"Selecione o Pedido de Compra"
			EndIf

			ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| nSavQual:=oQual:nAT,nOpca:=1,oDlg:End()},{||oDlg:End()},,) //aButtons

			If nOpca == 1
				DbSelectArea("SC7")
				MsGoto(aArrSldo[nSavQual][2])
		        // Verifica se o Produto existe Cadastrado na Filial de Entrada
			    DbSelectArea("SB1")
				DbSetOrder(1)
				MsSeek(xFilial("SB1")+SC7->C7_PRODUTO)
				If !Eof()
					cPedido := SC7->C7_NUM
					cItem   := SC7->C7_ITEM
					cTes    := SC7->C7_TES
					cConsulta := "F6"
					oPedido:Refresh()
					oItem:Refresh()
					oTes:Refresh()
				Else
					cConsulta := ""
					Aviso("XMLPCF6","O Produto selecionado do Pedido de compra, não possui cadastro na Filial de Entrada da Nota Fiscal. Favor efetuar cadastro !",{"Ok"})
				EndIf
			EndIf				
		Else
			U_MyAviso("ATENÇÃO","Não Existem pedidos para este item.",{"OK"},2)
		EndIf
	Else
		U_MyAviso("ATENÇÃO","Não Existem pedidos para este item.",{"OK"},2)
	EndIf

Endif

If lQuery

	//DbSelectArea(cAliasSC7)
	(cAliasSC7)->(DbCloseArea())
	//DbSelectArea("SC7")

Endif

SetKey(VK_F4,bSavSetKey)
SetKey(VK_F5,bSavKeyF5)
SetKey(VK_F6,bSavKeyF6)
SetKey(VK_F7,bSavKeyF7)
SetKey(VK_F8,bSavKeyF8)
SetKey(VK_F9,bSavKeyF9)
SetKey(VK_F10,bSavKeyF10)
SetKey(VK_F11,bSavKeyF11)

RestArea(aAreaSA2)
RestArea(aAreaSC7)
RestArea(aAreaSB1)
RestArea(aArea)

Return( .T. )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³U_XML09VPCº Autor ³ Eneovaldo Roveri Jrº Data ³  19/02/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Validação do pedido/item/tes informados.                   º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
USer Function XML09VPC( cQuar )
Local lRet  := .T.
Local cChv  := cPedido
Local aArea := GetArea()
Local aAreaSC7 := SC7->( GetArea() )
Local aAreaSF4 := SF4->( GetArea() )
Local nReg     := TMP->( Recno() )

cChv := cChv + ( iif(cQuar $ "FINAL,ITEM", cItem, "" ) )

If cQuar $ "FINAL,PEDIDO,ITEM"
	SC7->( DbSetORder( 1 ) )
	If SC7->( dbSeek( xFilial( "SC7" ) + cChv ) )
		if cConsulta <> "F6" .And. cQuar == "PEDIDO"
			SC7->( DbSetORder( 4 ) )
			If SC7->( dbSeek( xFilial( "SC7" ) + cProd + cPedido ) )
				cItem := SC7->C7_ITEM
				cTes  := SC7->C7_TES
				lRet := .T.
			Else
				U_MyAviso("ATENÇÃO","Pedido não tem o Produto "+cProd+" Cadastrado.",{"OK"},2)
				lRet := .F.
			EndIf
		elseif cConsulta <> "F6"
			if cProd == SC7->C7_PRODUTO
				lRet := .T.
			else
				U_MyAviso("ATENÇÃO","Pedido não tem o Produto "+cProd+" Cadastrado.",{"OK"},2)
				lRet := .F.
			endif
		endif
		cConsulta := ""
	Else
		if cQuar <> "FINAL"
			U_MyAviso("ATENÇÃO",cQuar+" Não Cadastrado.",{"OK"},2)
		else
			U_MyAviso("ATENÇÃO","PEDIDO/ITEM Não Cadastrado.",{"OK"},2)
		endif
		lRet := .F.
	EndIf
EndIf

If lRet .And. cQuar $ "FINAL,TES"
	SF4->( dbSetOrder( 1 ) )
	If .Not. SF4->( dbSeek( xFilial( "SF4" ) + cTes ) )
		U_MyAviso("ATENÇÃO","TES Não Cadastrada.",{"OK"},2)
		lRet := .F.
	EndIf
Endif

If lRet .And. cQuar $ "FINAL"
	TMP->( dbGoTop() )
	Do While .Not. TMP->( Eof() )
		If TMP->( Recno() ) <> nReg
			If TMP->&(x_ZBB_+"PROD") == cProd .AND. TMP->&(x_ZBB_+"PEDIDO") == cPedido .AND. TMP->&(x_ZBB_+"ITEM") == cItem
				U_MyAviso("ATENÇÃO","Pedido e Item Ja Cadastrado em outro Registro.",{"OK"},2)
				lRet := .F.
				Exit
			EndIf
		EndIf
		TMP->( dbSkip() )
	EndDo
	TMP->( dbGoTo(nReg) )
EndIf

RestArea(aAreaSF4)
RestArea(aAreaSC7)
RestArea(aArea)
Return( lRet )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³U_XML09PDRº Autor ³ Eneovaldo Roveri Jrº Data ³  11/03/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina para Gerar PréNota por Pedido Recorrente.           º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function XML09PDR( cLogProc, lShow )
Local lRet      := .T.
Local aArea     := GetArea()
Local cError    := ""
Local cWarning  := ""
Local lAchou    := .F.
Local cRet      := ""

default cLogProc := ""
default lShow    := .F.

Private x_ZBB_  := iif(Substr(x_ZBB,1,1)=="S", Substr(x_ZBB,2,2), Substr(x_ZBB,1,3)) + "_"
Private oXmlPrc
Private oDetPrc

If (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO"))) <> "55"   //CTE sai na boa
	if lShow
		U_MyAviso("Pré-Nota Ped. Recorrente","CTE não gera pré-nota por pedido recorrente",{"OK"},2)
	endif
	RestArea( aArea )
	Return( .T. )
EndIf

If (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC"))) <> "N"     //Notas Devolução e Beneficiamento sai na boa
	if lShow
		U_MyAviso("Pré-Nota Ped. Recorrente","Notas Devolução e Beneficiamento não gera pré-nota por pedido recorrente",{"OK"},2)
	endif
	RestArea( aArea )
	Return( .T. )
EndIf

If (xZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF"))) <> "B"     //Notas já geradas cai fora
	//ver um e-mail aqui para cancelados e etc.
	if lShow
		if (xZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF"))) $ "SNA"
			U_MyAviso("Pré-Nota Ped. Recorrente","Documento já lançado.",{"OK"},2)
		Else
			U_MyAviso("Pré-Nota Ped. Recorrente","Status "+;
			iif((xZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF"))) $ "X", "Cancelado",;
			iif((xZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF"))) $ "Z", "Xml Rejeitado",;
			iif((xZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF"))) $ "F", "Falha Estrutura XML" , (xZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF"))) )))+" não gera pré-nota por pedido recorrente",{"OK"},2)
		Endif
	endif
	RestArea( aArea )
	Return( .T. )
EndIf

if empty(x_ZBB)   //Definir Tabela de Pedido Recorrente
	cLogProc += "TABELA DE PEDIDO RECORRENTE NÃO DEFINIDA"+CRLF
	if lShow
		U_MyAviso("Pré-Nota Ped. Recorrente","TABELA DE PEDIDO RECORRENTE NÃO DEFINIDA",{"OK"},2)
	endif
	SendMailPRec((xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO"))),(xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))),;
	              "TABELA DE PEDIDO RECORRENTE NÃO DEFINIDA",AllTrim( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FORNEC"))) ),;
	              (xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA"))),(xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE"))) )
	RestArea( aArea )
	Return( .F. )
endif

if .Not. ChkFile(x_ZBB)
	cLogProc += "Tabela de Pedido Recorrente "+x_ZBB+" não existe. Verifique se está correta. Se estiver rode o compatibilizador, senão altere a tabela no painel administrativo."+CRLF
	if lShow
		U_MyAviso("Pré-Nota Ped. Recorrente","Tabela de Pedido Recorrente "+x_ZBB+" não existe. Verifique se está correta. Se estiver rode o compatibilizador, senão altere a tabela no painel administrativo.",{"OK"},3)
	endif
	SendMailPRec((xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO"))),(xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))),;
	              "Tabela de Pedido Recorrente "+x_ZBB+" não existe. Verifique se está correta. Se estiver rode o compatibilizador, senão altere a tabela no painel administrativo.",;
	              AllTrim( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FORNEC"))) ),(xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA"))),(xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE"))) )
	RestArea( aArea )
	Return( .F. )
endif

dbSelectArea( x_ZBB )
dbSetOrder( 1 )
If .NOT. ( x_ZBB )->( dbSeek( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))) + (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR"))) +;
                              (xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR"))) ) )  //se não tiver nenhum cai fora para não perder tempo
	if lShow
		U_MyAviso("Pré-Nota Ped. Recorrente","Fornecedor não gera pré-nota por pedido recorrente",{"OK"},2)
	endif
	dbSelectArea( xZBZ )
	RestArea( aArea )
	Return( .T. )
EndIf
dbSelectArea( xZBZ )

oXmlPrc := XmlParser((xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML"))), "_", @cError, @cWarning )

If oXmlPrc == NIL .Or. !Empty(cError) .Or. !Empty(cWarning)
	cLogProc += "XML Invalido Mal Formado Não foi gerado pré-nota por pedido recorrente."+CRLF
	if lShow
		U_MyAviso("Pré-Nota Ped. Recorrente","XML Invalido Mal Formado Não foi gerado pré-nota por pedido recorrente.",{"OK"},3)
	endif
	SendMailPRec((xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO"))),(xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))),;
	              "XML Invalido Mal Formado Não foi gerado pré-nota por pedido recorrente.",;
	              AllTrim( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FORNEC"))) ),(xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA"))),(xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE"))) )
	RestArea( aArea )
	Return( .F. )
EndIf


//StartJob("U_XML09FOR",GetEnvServer(),.F., cEmpAnt, (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))), (xZBZ)->( Recno() ), @cRet )
lRet := U_XML09FOR(cEmpAnt, (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))), (xZBZ)->( Recno() ), @cRet )

If .NOT. lRet
	if lShow
		U_MyAviso("Aviso",cRet,{"OK"},3)		//FR - 17/06/2021 - #10789 - Cimentos Itambé 		
	EndIf
	cLogProc += "Pré-Nota por Pedido Recorrente, não foi gerada, verifique e-mail responsável."+CRLF
Else
	cLogProc += "Gerado Pré-Nota Por Pedido Recorrente."+CRLF
EndIf

RestArea( aArea )
Return  //( lRet )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³U_XML09FORº Autor ³ Eneovaldo Roveri Jrº Data ³  11/03/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina para Gerar PréNota por Pedido Recorrente.           º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function XML09FOR( xEmp, xFil, nRegZbz, cRet )
Local lRetorno  := .F.
Local aLinha    := {}
Local nX        := 0
Local aProdOk   := {}
Local aProdNo   := {}
Local aProdVl   := {}
Local aPedOk    := {}
Local aPedNo    := {}
//Local aArea       := GetArea()
Local lXMLPE2UM   := .F. //ExistBlock( "XMLPE2UM" )
//Local lXMLPEITE   := .F. //ExistBlock( "XMLPEITE" )
Local nQuant      := 0
Local nVunit      := 0
Local nTotal      := 0
Local cUm         := "  "
Local nErrItens   := 0
Local nD1Item     := 0
Local oIcm
Local cKeyFe	  := SetKEY( VK_F3 ,  Nil )
Local nSaldo      := 0
Local lNenhumSeek := .T.
Local cFilAux     := ""
Local cDir        := "" //AllTrim(SuperGetMv("MV_X_PATHX"))
Local cDirLog     := "" //AllTrim(cDir+cBarra+"Log"+cBarra)
Local cArqLog     := "" //AllTrim( ZBZ->ZBZ_CHAVE )+".TXT"
Local cError      := ""
Local cWarning    := ""
Local i           := 0
Local lFora       := .F.		//FR - 17/06/2021 - #10789 - Cimentos Itambé
Local xlRet       := .F.		//FR - 17/06/2021 - #10789 - Cimentos Itambé
Local cBkpFil     := cfilant 

Private lXMLPEITE   := .F. //ExistBlock( "XMLPEITE" )
Private xZBZ  	  := GetNewPar("XM_TABXML" ,"ZBZ")
Private xZBZ_ 	  := iif(Substr(xZBZ,1,1)=="S", Substr(xZBZ,2,2), Substr(xZBZ,1,3)) + "_"


//IF .NOT. RpcSetEnv( xEmp, xFil,,,"COM",,{ "SF1","SF2","SD1","SD2","SF4","SB5","SF3","SB1","SA5","SA7","SC7","SA1","SA2" },.F.,.F.)
//	cRet := "[PED REC] " + "Filial ("+xEmp+" "+xFil+"): Não Foi Possível estabelecer conexão com a Empresa/Filial. [INVALIDO]"	//FR - 28/05/2021 - #10718 - CIMENTOS ITAMBÉ
	//RstMvBuff()
	//DelClassIntf()
	//RpcClearEnv()
	//RESET ENVIRONMENT
//	Return( .F. ) //Return( cRet )
//EndIf

//FR - 17/06/2021 - #10789 - Cimentos Itambé
/*If Select( 'SX2' ) == 0
  	RpcSetType(3)
  	PREPARE ENVIRONMENT EMPRESA xEmp FILIAL xFil
  	sleep( 5000 )
  	lFora := .T.
EndIf*/
//FR - 17/06/2021 - #10789 - Cimentos Itambé

Private xZBZ  	  := GetNewPar("XM_TABXML","ZBZ")      //ECOOOOOOOOOO
Private xZB5  	  := GetNewPar("XM_TABAMAR","ZB5")     //ECOOOOOOOOOO
Private xZBZ_ 	  := iif(Substr(xZBZ,1,1)=="S", Substr(xZBZ,2,2), Substr(xZBZ,1,3)) + "_"
Private xZB5_ 	  := iif(Substr(xZB5,1,1)=="S", Substr(xZB5,2,2), Substr(xZB5,1,3)) + "_"
Private x_ZBB     := GetNewPar("XM_TABREC","")
Private x_ZBB_    := iif(Substr(x_ZBB,1,1)=="S", Substr(x_ZBB,2,2), Substr(x_ZBB,1,3)) + "_"
Private xZBE      := GetNewPar("XM_TABEVEN","ZBE")
Private xZBE_     := iif(Substr(xZBE,1,1)=="S", Substr(xZBE,2,2), Substr(xZBE,1,3)) + "_"
Private xZBS  	  := GetNewPar("XM_TABSINC","ZBS")
Private xZBS_ 	  := iif(Substr(xZBS,1,1)=="S", Substr(xZBS,2,2), Substr(xZBS,1,3)) + "_"
Private aHfCloud  := {"0","0"," ","Token",{}}  //CRAUMDE - '0' Não integrar, na posição 1

cfilant := xFil

DbSelectArea( xZBZ )
DbGoTo( nRegZbz )
lXMLPE2UM   := ExistBlock( "XMLPE2UM" )
lXMLPEITE   := ExistBlock( "XMLPEITE" )
cDir        := AllTrim(SuperGetMv("MV_X_PATHX"))
cDirLog     := AllTrim(cDir+cBarra+"Log"+cBarra)
cArqLog 	:= AllTrim( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))) )+".TXT"

Private oFont01   := TFont():New("Arial",07,14,,.T.,,,,.T.,.F.)
Private oXml      := XmlParser((xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML"))), "_", @cError, @cWarning )
If oXml == NIL
	cError := ""
	cWarning := ""
	oXml := U_PARSGDE( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML"))), @cError, @cWarning )
Endif
Private oDet, oOri
Private lDetCte     := ( GetNewPar("XM_CTE_DET","N") == "S" )
Private lTagOri     := ( GetNewPar("XM_CTE_DET","N") == "S" )
Private cTagFci     := ""
Private cCodFci     := ""
Private lMsErroAuto	:= .F.
Private lMsHelpAuto	:= .T.
Private aCabec      := {}
Private aItens    := {}
Private cProduto  := "" //nTamProd
Private cCnpjEmi  := ""
Private cCodEmit  := ""
Private cLojaEmit := ""
Private nFormNfe  := Val(GetNewPar("XM_FORMNFE","6"))
Private nFormCTE  := Val(GetNewPar("XM_FORMCTE","6"))
Private nFormSer  := Val(GetNewPar("XM_FORMSER","0")) 
Private cEspecNfe := GetNewPar("XM_ESP_NFE","SPED")
Private cEspecCte := GetNewPar("XM_ESP_CTE","CTE")
Private cModelo   := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO")))
Private cTipoNf   := "N"
Private aItXml    := {}
Private cAmarra   := GetNewPar("XM_DE_PARA","0")
Private aPerg     := {}
Private aCombo    := {}
Private nAliqCTE  := 0, nBaseCTE := 0, nPedagio := 0, cModFrete := " ", lDetPed := .T.
Private cPCSol    := GetNewPar("XM_CSOL","A")
Private lNfOri    := ( GetNewPar("XM_NFORI","N") == "S" )
Private cCCusto   := ""
Private cTagAux   := ""
Private nValAux   := 0
Private lSerEmp   := .NOT. Empty( AllTrim(GetNewPar("XM_SEREMP","")) )
Private nAmarris  := 0
Private cPedidis  := ""
Private cTagTot   := ""
Private nTotXml   := 0
Private lTemFreXml:= .F., lTemDesXml := .F., lTemSegXml := .F.

DbSelectArea( x_ZBB )

DbSelectArea( xZBZ )

If oXml == NIL .Or. !Empty(cError) .Or. !Empty(cWarning)
	cRet := "XML Invalido Mal Formado Não foi gerado pré-nota por pedido recorrente. [INVALIDO]"		//FR - 28/05/2021 - #10718 - Cimentos Itambé
	Conout("[PED REC] "+cRet)
	SendMailPRec((xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO"))),(xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))),;
	"XML Invalido Mal Formado Não foi gerado pré-nota por pedido recorrente.",;
	AllTrim( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FORNEC"))) ),(xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA"))),(xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE"))) )
	//RstMvBuff()
	//DelClassIntf()
	//RpcClearEnv()
	//RESET ENVIRONMENT
	cfilant := cBkpFil     
	Return( .F. ) //Return( cRet )
EndIf

cDirLog := StrTran(cDirLog,cBarra+cBarra,cBarra)

If cModelo == "55"
	lDetCte  := .F.
	lTagOri  := .F.
 	cPref    := "NF-e"
	cTAG     := "NFE"
	nFormXML := nFormNfe
	cEspecXML:= cEspecNfe
EndIf

cPerg := "IMPXML"
//ValidPerg1(cPerg)

aParam   := {" "}
cParXMLExp := cNumEmp+"IMPXML"
cExt     := ".xml"
cNfes    := ""

cAmarra := iif( cAmarra=="4", "0", cAmarra )

lContImp:= .T.

cTagTpEmiss:= "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_TPEMIS:TEXT"
cTagTpAmb  := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_TPAMB:TEXT"
cTagCHId   := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_ID:TEXT"
cTagSign   := "oXml:_"+cTAG+"PROC:_"+cTAG+":_SIGNATURE"
cTagProt   := "oXml:_"+cTAG+"PROC:_PROT"+cTAG+":_INFPROT:_NPROT:TEXT"
cTagKey    := "oXml:_"+cTAG+"PROC:_PROT"+cTAG+":_INFPROT:_CH"+cTAG+":TEXT"
/* Inclusão da tag CPF empresa Bela Ischa - 20/09/2016 */
If Type("oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_EMIT:_CNPJ:TEXT") == "U"
	cTagDocEmit:= "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_EMIT:_CPF:TEXT"  
Else 
	cTagDocEmit:= "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_EMIT:_CNPJ:TEXT"
EndIf
/* Fim */

cTagDocXMl := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_N"+Left(cTAG,2)+":TEXT"
cTagSerXml := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_SERIE:TEXT"

If cModelo == "55"
		cTagDtEmit := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_DHEMI:TEXT"		//FR - 28/05/2021 - #10718 - CIMENTOS ITAMBÃ‰
		if type(cTagDtEmit) == "U"
			cTagDtEmit := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_DHEMI:TEXT"
		endif
		cTagDocDest:= "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_DEST:_CNPJ:TEXT"
		cTagTot    := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_TOTAL:_ICMSTOT:_VNF:TEXT"
		If Type(cTagTot)<> "U"
 			nTotXml   := Val(&(cTagTot))
 		Else
 			nTotXml   := 0
 		EndIf
 		cTagTipFre:= "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_TRANSP:_MODFRETE:TEXT"
		If Type(cTagTipFre)<> "U"
	   		cModFrete := &(cTagTipFre)
	   	EndIf
EndIf

cCodEmit  := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR")))
cLojaEmit := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR")))
cDocXMl   := Iif(nFormXML > 0,StrZero(Val(&(cTagDocXMl)),nFormXML),&(cTagDocXMl))
cSerXml   := &(cTagSerXml)

//Alterado para atender ao empresa ITAMBÉ - 16/10/2014
//Analista Alexandro de Oliveira
Do Case
Case ( GetNewPar("XM_SERXML","N") == "S" )

	if alltrim( cSerXml ) == '0' .or. alltrim( cSerXml ) == '00' .or. alltrim( cSerXml ) == '000'
		cSerXml := '   '
	EndIf

Case ( GetNewPar("XM_SERXML","N") == "Z" )

	If Empty(cSerXml)
		cSerXml := '0'
	Endif

Case ( GetNewPar("XM_SERXML","N") == "P" )

	cSerXml := Padl(alltrim(cSerXml),nFormSer,"0")   //Padl(alltrim(cSerXml),Tamsx3("D1_SERIE")[1],"0")

EndCase

if lSerEmp
	cSerXml := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE")))
endif

cChaveXml := &(cTagKey)
cDtEmit   := &(cTagDtEmit)
dDataEntr := StoD(substr(cDtEmit,1,4)+Substr(cDtEmit,6,2)+Substr(cDtEmit,9,2))

aadd(aCabec,{"F1_TIPO"   ,Iif(Empty( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC"))) ),"N",AllTrim( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC"))) ))})
aadd(aCabec,{"F1_FORMUL" ,"N"})
aadd(aCabec,{"F1_DOC"    ,cDocXMl})
aadd(aCabec,{"F1_SERIE"  ,cSerXml})
aadd(aCabec,{"F1_EMISSAO",dDataEntr})
aadd(aCabec,{"F1_FORNECE",cCodEmit})
aadd(aCabec,{"F1_LOJA"   ,cLojaEmit})
aadd(aCabec,{"F1_ESPECIE",cEspecXML})
aadd(aCabec,{"F1_CHVNFE" ,cChaveXml})
aadd(aCabec,{"F1_VALPEDG",nPedagio })
if cModFrete <> " "
	if cModFrete == "0"
		cModFrete := "C"
	elseif cModFrete == "1"
		cModFrete := "F"
	elseif cModFrete == "2"
		cModFrete := "T"
	else
		cModFrete := "S"
	endif
	//aadd(aCabec,{"F1_TPFRETE",cModFrete })
endif

cTagAux   := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_TOTAL:_ICMSTOT:_VFRETE:TEXT"
if Type(cTagAux) <> "U"
	nValAux := Val( &(cTagAux) )
	if nValAux > 0
		aadd(aCabec,{"F1_FRETE",nValAux })
		lTemFreXml := .T.
	endif
endif
cTagAux   := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_TOTAL:_ICMSTOT:_VOUTRO:TEXT"
if Type(cTagAux) <> "U"
	nValAux := Val( &(cTagAux) )
	if nValAux > 0
		aadd(aCabec,{"F1_DESPESA",nValAux })
		lTemDesXml := .T.
	endif
endif
cTagAux   := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_TOTAL:_ICMSTOT:_VSEG:TEXT"
if Type(cTagAux) <> "U" 
	nValAux := Val( &(cTagAux) )
	if nValAux > 0
		aadd(aCabec,{"F1_SEGURO",nValAux })
		lTemSegXml := .T.
	endif
endif

//aProdZr  := {} Só no Cte, então cai fora
aLinha   := {}
aProdOk  := {}
aProdNo  := {}
aProdVl  := {}
aPedNo   := {} //Pedidos sem saldo ou não cadastrados como atual na ZBB
aItXml   := {}
aItens   := {}
lNenhumSeek := .T.  //Se nenhum seek ocorrer é é porque o fornecedor não tem pedido recorrente, então sai de boa

oDet := oXml:_NFEPROC:_NFE:_INFNFE:_DET
oDet := IIf(ValType(oDet)=="O",{oDet},oDet)

If Type("oXml:_NFEPROC:_NFE:_INFNFE:_DET") == "A"
	aItem := oXml:_NFEPROC:_NFE:_INFNFE:_DET
Else
	aItem := {oXml:_NFEPROC:_NFE:_INFNFE:_DET}
EndIf

nD1Item := 1
For i := 1 To len(oDet)
	lRetorno  := .F.
	aPedOk    := {}
	cPed      := ""
	cITe      := ""
	cTes      := ""
	cTipoCPro := iif( cAmarra <> "0", cAmarra, "1")
	Do While .T.
        lFound := .F.
		If cTipoCPro == "2" // Ararracao Customizada ZB5 Produto tem que estar Amarrados Tanto Cliente como Formecedor
			cProduto := ""
			DbSelectArea(xZB5)
			DbSetOrder(1)
			// Filial + CNPJ FORNECEDOR + Codigo do Produto do Fornecedor
			cFilAux := iif(U_IsShared(xZB5), xFilial(xZB5), (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))) )
			If DbSeek(cFilAux+PADR((xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))),14)+oDet[i]:_Prod:_CPROD:TEXT)
				cProduto := (xZB5)->(FieldGet(FieldPos(xZB5_+"PRODFI"))) //ZB5->ZB5_PRODFI
		        lFound   := .T.
			EndIf

		//##################################################################
		ElseIf cTipoCPro == "1" // Amarracao Padrao SA5/SA7

				cProduto  := ""
				if empty( cCodEmit )
					cFilAux := iif(U_IsShared("SA2"), xFilial("SA2"), (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))) )
					cCodEmit  := Posicione("SA2",3,cFilAux+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))),"A2_COD")
					cLojaEmit := Posicione("SA2",3,cFilAux+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))),"A2_LOJA")
				endif

				cAliasSA5 := GetNextAlias()
				nVz := len(aItem)

				cWhere := "%(SA5.A5_CODPRF IN ("
				cWhere += "'"+TrocaAspas( AllTrim(oDet[i]:_Prod:_CPROD:TEXT) )+"'"
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
				cFilAux := iif(U_IsShared("SA5"), xFilial("SA5"), (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))) )
		        cKeySa5:= cFilAux+cCodEmit+cLojaEmit+TrocaAspas( oDet[i]:_Prod:_CPROD:TEXT )
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
				EndIf

				(cAliasSA5)->(DbCloseArea())

		//##################################################################
		ElseIf cTipoCPro = "3" // Mesmo Codigo Nao requer amarracao SB1
			DbSelectArea("SB1")
			DbSetOrder(1)
			cFilAux := iif(U_IsShared("SB1"), xFilial("SB1"), (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))) )
			If DbSeek(cFilAux+oDet[i]:_Prod:_CPROD:TEXT)
				cProduto := Substr(oDet[i]:_Prod:_CPROD:TEXT,1,nTamProd)
		        lFound   := .T.
			EndIF
		EndIf

        If lFound
			DbSelectArea( x_ZBB )
			If ( x_ZBB )->( dbSeek( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))) + cCodEmit + cLojaEmit + cProduto ) )
				lNenhumSeek := .F.
			EndIF

			Do While .NOT. ( x_ZBB )->( Eof() ) .And. (xZBZ)->&(xZBZ_+"FILIAL") == ( x_ZBB )->&(x_ZBB_+"FILIAL") .And.;
					cCodEmit == ( x_ZBB )->&(x_ZBB_+"FORNEC") .And. cLojaEmit == ( x_ZBB )->&(x_ZBB_+"LOJA") .And.;
					cProduto == ( x_ZBB )->&(x_ZBB_+"PROD")
				If ( x_ZBB )->&(x_ZBB_+"AMARRA") == cTipoCPro
					If ( x_ZBB )->&(x_ZBB_+"ATUAL") == "S"
						lRetorno := .T.
						aadd(aPedOk,{( x_ZBB )->&(x_ZBB_+"PEDIDO"), ( x_ZBB )->&(x_ZBB_+"ITEM"), ( x_ZBB )->&(x_ZBB_+"TES")} )
						cPed := ( x_ZBB )->&(x_ZBB_+"PEDIDO")
						cITe := ( x_ZBB )->&(x_ZBB_+"ITEM")
						cTes := ( x_ZBB )->&(x_ZBB_+"TES")
					EndIf
				EndIf
				( x_ZBB )->( dbSkip() )
			EndDo
        EndIf

		if lRetorno
			aadd(aProdOk,{oDet[i]:_Prod:_CPROD:TEXT,oDet[i]:_Prod:_XPROD:TEXT} )
			Exit
		endif

		cTipoCPro := iif( cTipoCPro == "1", "2", iif( cTipoCPro == "2", "3", "0" ) )
		If cTipoCPro == "0" .Or. cAmarra <> "0"
			aadd(aProdNo,{oDet[i]:_Prod:_CPROD:TEXT,oDet[i]:_Prod:_XPROD:TEXT} )
			Exit
		EndIf

    EndDo

	if .NOT. lRetorno
		Loop
	endif
	If Len( aPedOk ) > 1
		cPed := ""
		cITe := ""
		cTes := ""
		cPedido := " "
		cAux    := "oDet[i]:_PROD:_XPED:TEXT"
		if type( cAux ) <> "U"
			cPedido := &cAux
		endif
		cItPed  := " "
		cAux    := "oDet[i]:_PROD:_NITEMPED:TEXT"
		if type( cAux ) <> "U"
			cItPed := &cAux
		endif
		For nX := 1 To Len( aPedOk )
			if aPedOk[nX][1] == cPedido .And. aPedOk[nX][2] == cItPed
				cPed := aPedOk[nX][1]
				cITe := aPedOk[nX][2]
				cTes := aPedOk[nX][3]
				Exit
			endif
		Next nX
		if Empty( cPed ) .or. empty(cITe) .or. empty(cTes)
			aadd(aPedNo,{cProduto, "Erro (xPed) Cad. Recorrente Ped:"+cPedido+" It:"+cItPed} )
			Loop
		endif
	EndIf

	nSaldo := 0
	cCCusto := TAMSX3("D1_CC")[1]
	SC7->(dbSetOrder(1))
	cFilAux := iif(U_IsShared("SC7"), xFilial("SC7"), (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))) )
	if SC7->( dbSeek( cFilAux + cPed + cITe ) )
		nSaldo := SC7->C7_QUANT-SC7->C7_QUJE-SC7->C7_QTDACLA
		cCCusto := SC7->C7_CC
    EndIF

    /*
	cUm    := "  "
    cTagUM := ""        //FR - 01/06/2021
	
	cTagUM := "oDet[i]:_Prod:_UCOM:TEXT"
    cName  := ""
    oObj := oDet[i]
    xObj := Nil
    
    If XmlChildEx( "oDet[i]:_PROD" , "_UCOM" ) == Nil  //se for nil a 1a. checagem, faz a contagem de nÓS
        nConta := XmlChildCount(oObj:_PROD)  //TEM 15 NÓS
        If nConta >= 9
            xObj := XmlGetChild(oObj:_PROD, 6)	//tentar pegar o 6o. elemento pra checar se existe a tag	
            cName:= xObj:REALNAME
            If UPPER(cName) == "UCOM"        
            //If XmlChildEx( "oDet[i]:_PROD" , "_UCOM" ) <> NIL		//FR - 01/06/2021 - #10736 - CIMENTOS ITAMBÉ		
                cUM    := &cTagUM
            Endif
        Endif

    Else 
        cUM    := &cTagUM
    Endif
    */
    cUm    := "  "
    cTagUM := ""        //FR - 01/06/2021
	cTagUM := "oDet[i]:_Prod:_UCOM:TEXT"
	If Type("&cTagUM") <> "U"
        cUM    := &cTagUM
    Endif

	nQuant := VAL(oDet[i]:_Prod:_QCOM:TEXT)
    
	nQuant := VAL(oDet[i]:_Prod:_QCOM:TEXT)
	nVunit := VAL(oDet[i]:_Prod:_VUNCOM:TEXT)
	nTotal := VAL(oDet[i]:_Prod:_VPROD:TEXT)

    cCodFci:= ""
    cTagFci:= "oDet[i]:_PROD:_NFCI:TEXT"  //CONFIRMAR ESTA TAG
    If XmlChildEx( "oDet[i]:_PROD" , "_NFCI" ) <> NIL			//FR - 31/05/2021 - #10736 - CIMENTOS ITAMBÃ‰
		cCodFci:= &cTagFci
	EndIf

	If lXMLPE2UM   //PE para conversão da 2 unidade de medida
		oIcm := oDet[i]:_Imposto:_ICMS
		oIcm := IIf(ValType(oIcm)=="O",{oIcm},oIcm)
   		aRet :=	ExecBlock( "XMLPE2UM", .F., .F., { cProduto,cUm,nQuant,nVunit,oIcm } )
   		if aRet == NIL
			cUm    := "  "
			nQuant := 0
			nVunit := 0
		else
			cUm    := iif( len(aRet) >= 2, aRet[2], "  " )
			nQuant := iif( len(aRet) >= 3, aRet[3], 0 )
			nVunit := iif( len(aRet) >= 4, aRet[4], 0 )
   		endif
	 	if Round((nQuant * nVunit),2) != Round(nTotal, 2)  //no hfxml02 é assim -> NoRound((nQuant * nVunit),2) != NoRound(nTotal, 2)
			aadd(aProdVl,{oDet[i]:_Prod:_CPROD:TEXT, cUm, nQuant, nVunit, nTotal, (nQuant * nVunit) } )
	 	endif
 	EndIf

	//FR - 29/07/2022 - SOLICITADO NÃO MAIS USAR ESSA VALIDAÇÃO - POR CLEUZELI
	//if nQuant > nSaldo
	//	aadd(aPedNo,{cProduto, "Saldo Pedido:"+cPed+" It:"+cITe+" Insuficiente"} )
	//	Loop
	//endif
	//FR - 29/07/2022 - SOLICITADO NÃO MAIS USAR ESSA VALIDAÇÃO - POR CLEUZELI

	aadd(aLinha,{"D1_ITEM"  ,StrZero(nD1Item,4)              ,Nil})
	aadd(aLinha,{"D1_COD"   ,cProduto               		 ,Nil})
	aadd(aLinha,{"D1_PEDIDO",cPed               	   		 ,Nil})
	aadd(aLinha,{"D1_ITEMPC",cITe              		 		 ,Nil})
	aadd(aLinha,{"D1_QUANT" ,nQuant							 ,Nil})
	aadd(aLinha,{"D1_VUNIT" ,nVunit							 ,Nil})
	aadd(aLinha,{"D1_TOTAL" ,nTotal							 ,Nil})
	If .Not. Empty(cCodFci)
		aadd(aLinha,{"D1_FCICOD",cCodFci					 ,Nil})
	EndIf
	if cPCSol == "S"  //Centro de Custo do Pedido
		aadd(aLinha,{"D1_CC"    ,cCCusto  					 ,Nil})
	elseif cPCSol != "Z"   //=> Com o Z não preenche o D1_CC, senão ao caso utilizar um gatilho poderia sobrepor o gatilho
		if .not. empty( cProduto ) .And. SB1->( DbSeek(xFilial("SB1")+cProduto) )
			aadd(aLinha,{"D1_CC",SB1->B1_CC					 ,Nil})
		endif
	endif
	aadd(aLinha,{"D1_TES   ",cTes              			 ,Nil})

	If lXMLPEITE   //PE para incluir campos no aLinha SD1 -> para o aItens
		aRet :=	ExecBlock( "XMLPEITE", .F., .F., { cProduto,oDet,i } )
		If ValType(aRet) == "A"
			AEval(aRet,{|x| AAdd(aLinha,x)})
		EndIf
	endif

	if .not. empty( cProduto )
		cFilAux := iif(U_IsShared("SB1"), xFilial("SB1"), (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))) )
 		if SB1->( DbSeek(cFilAux+cProduto) )
			If SB1->( FieldGet(FieldPos("B1_MSBLQL")) ) == "1"
 				aadd(aProdNo,{cProduto,"Produto Bloqueado SB1->"+SB1->B1_DESC} )
			EndIf
 		ElseIf cTipoCPro != "3"
			aadd(aProdNo,{cProduto,"Não Cadastrado SB1->"+oDet[i]:_Prod:_XPROD:TEXT} )
		endif
	EndIf

	if nVunit > 0 //permitir valor unitário maior zero
 		aadd(aItens,aLinha)
 		nD1Item++
	 	aadd(aItXml,{StrZero(i,4),oDet[i]:_Prod:_CPROD:TEXT,oDet[i]:_Prod:_XPROD:TEXT})
 	endif
	aLinha := {}

Next i

IF lNenhumSeek  //Cai Fora de Boa, pois o fornecedor não tem nenhum item cadastrado como Pedido Recorrente.
	cRet := "Fornecedor não tem Pedidos Recorrentes para os ítens de XML. [INVALIDO]"		//FR - 28/05/2021 - #10718 - CIMENTOS ITAMBÉ
	Conout("[PED REC] "+cRet)
	//RstMvBuff()
	//DelClassIntf()
	//RpcClearEnv()
	//RESET ENVIRONMENT
	cfilant := cBkpFil  
	Return( .F. ) //Return( cRet )
EndIf

//Itens não encontrados  AQUI MANDAIRE EMAIL
if .not. InconsPRec( "PDRC", aProdOk, aProdNo, aProdVl, 1, , aPedNo, .F. )
    lRetorno := .F.
Else
	cChaveF1 := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))) + (xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA"))) +;
	            (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE")))  + (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR"))) +;
	            (xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR"))) + (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC")))
	//cChaveF1 := ZBZ->ZBZ_FILIAL + ZBZ->ZBZ_NOTA + ZBZ->ZBZ_SERIE + ZBZ->ZBZ_CODFOR + ZBZ->ZBZ_LOJFOR + ZBZ->ZBZ_TPDOC
	DbSelectArea("SF1")
	DbSetOrder(1)

	lSeekNF := DbSeek(cChaveF1)

	If lSeekNf
		cRet := "Esta NFE já foi importada para a Base!"+CRLF +"Chave :"+cChaveF1 + " [INVALIDO]" 	//FR - 28/05/2021 - #10718 - CIMENTOS ITAMBÉ
		lRetorno := .F.
	EndIf
endif

If lRetorno
	aCols    := {}
	aRetHead := {}
	aRetCol  := {}
	lSetPC := .F.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Inicio da Inclusao                                           |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lRetorno :=.T.   // U_VisNota(cModelo, ZBZ->ZBZ_CNPJ,oXml, aCols, @aCabec, @aItens )

	If lRetorno
		lmata140 := ( GetNewPar("XM_RECDOC","1") == "1" )
		lmata103 := ( GetNewPar("XM_RECDOC","1") == "2" )

		xRet140 := .F.
		xRet103 := .F.
		If lmata140
			//xRet140:= MSExecAuto({|x,y,z| U_Xmata140(x,y,z)},aCabec,aItens,3,,1)
			xRet140:= MSExecAuto({|x,y,z| MATA140(x,y,z)},aCabec,aItens,3)
		EndIf
		If lmata103
			If ExistBlock( "XMLPE001" )
		   		aCabec :=	ExecBlock( "XMLPE001", .F., .F., { aCabec,oXml } )
				If Empty(aCabec)
					Conout("[XMLPE001] "+dtos(ddatabase)+"-"+Time())
					cRet := "O cabeçalho da nota fiscal é inválido.Verifique o ponto de entrada 'XMLPE001'. [INVALIDO]"	//FR - 28/05/2021 - #10718 - CIMENTOS ITAMBÉ
					//RstMvBuff()
					//DelClassIntf()
					//RpcClearEnv()
					//RESET ENVIRONMENT
					cfilant := cBkpFil  
					Return( .F. )  //Return( cRet )
				EndIf
			EndIf
			xRet103 := MSExecAuto({|x,y,z,k| mata103(x,y,z,k)},aCabec,aItens,3,.T.)
		EndIf

		lEditStat := .F.

		If lMsErroAuto
			If xRet140 .Or. xRet103
				//If lShow
				//	MOSTRAERRO()
				//	MsgSTOP("O documento de entrada não foi gerado.")
				//Else
					MOSTRAERRO(cDirLog,cArqLog)
					SendMailPRec((xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO"))),(xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))),;
					"Erro ExecAuto: Verifique o Anexo (.TXT)",AllTrim((xZBZ)->(FieldGet(FieldPos(xZBZ_+"FORNEC")))),;
					(xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA"))),(xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE"))),cDirLog,cArqLog )
					FErase(cDirLog+cArqLog)
				//EndIf
			EndIf
			lRetorno := .F.
		Else                              
		    lMsHelpAuto:=.F.

			//If lShow
		    //	U_MyAviso("Aviso","Geração da Nota fiscal de entrada efetuada com Sucesso."+CRLF+" Utilize a opção :"+CRLF+;
			//				"Movimento -> Nota Fiscal de Entrada "+CRLF+" para Verificar a Integridade dos Dados.",{"OK"},3)
			//EndIf
			lEditStat := .T.
			If lEditStat
				Conout("[PED REC] Gravando "+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))))
				DbSelectArea(xZBZ)
				Reclock(xZBZ,.F.)
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PRENF") , Iif(Empty(SF1->F1_STATUS),'S','N') ))
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPDOC") , SF1->F1_TIPO ))
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CODFOR"), aCabec[6][2] ))
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"LOJFOR"), aCabec[7][2] ))
				/*if FieldPos(xZBZ_+"MANIF") > 0
					cOri := "1"
					if FieldPos(xZBZ_+"IMPORT") > 0
						if !Empty( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"IMPORT"))) )
							cOri := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"IMPORT")))
						Endif
					Endif
					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"MANIF"), U_MANIFXML( AllTrim( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))) ), .F., cOri ) )) //(xZBZ)->(FieldPut(FieldPos(xZBZ_+"MANIF"), U_MANIFXML( AllTrim( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))) ) ), .F., cOri ))
				endif
				MsUnlock()
				Conout( "[PED REC] GRAVADO "+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))) )*/
				//	LUCAS SAN -> 04/10/2022 RETIRA MANIFESTAÇÃO DE CONFIRMAÇÃO DA OPERAÇÃO.
			EndIf

			lRetorno := .T.
		EndIf
	EndIf
Endif

xlRet := lRetorno

If lFora   				//FR - 17/06/2021 - #10789 - Cimentos Itambé
	//RstMvBuff()
	//DelClassIntf()
	//RpcClearEnv()
	//RESET ENVIRONMENT 
Endif
//Return( cRet )
cfilant := cBkpFil  
Return(xlRet)


Static Function InconsPRec( cTipoProc, aProdOk, aProdNo, aProdVl, nErrItens, aProdZr, aPedNo, lShow )
Local lRet   := .T.
Local nI     := 0
Local cOcorr := ""

Default aProdOk := {}
Default aProdNo := {}
Default aProdVl := {}
Default aProdZr := {}
Default aPedNo  := {}

if lShow
	lRet := ItNaoEnc( cTipoProc, aProdOk, aProdNo, aProdVl, @nErrItens, aProdZr )
endif

If lRet .And. .NOT. Empty( aPedNo )
	//Acui bamo só enviaire e-mial
	cOcorr := "XML COM INCONSISTENCIA COM PEDIDO RECORRENTE"+CRLF
	For nI := 1 To Len( aPedNo )
		cOcorr += aPedNo[nI][1]+ " - "+aPedNo[nI][2]+CRLF
	Next nI
	If Len( aProdNo ) > 0
		cOcorr := "PRODUTOS NÃo ENCONTRADOS (DE/PARA)"+CRLF
		For nI := 1 To Len( aProdNo )
			cOcorr += aProdNo[nI][1]+ " - "+aProdNo[nI][2]+CRLF
		Next nI
	EndIf
	If Len( aProdVl ) > 0
		cOcorr := "ITENS COM PROBLEMAS DE VALORES (PE - U_XMLPE2UM)"+CRLF
		For nI := 1 To Len( aProdVl )
			cOcorr += aProdVl[nI][1]+ " - "+aProdVl[nI][2]+CRLF
		Next nI
	EndIf
	If Len( aProdZr ) > 0
		cOcorr := "ITENS COM PROBLEMAS DE VALORES UNITÁRIOS"+CRLF
		For nI := 1 To Len( aProdZr )
			cOcorr += aProdZr[nI][1]+ " - "+aProdZr[nI][2]+CRLF
		Next nI
	EndIf
	SendMailPRec("55",(xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))),cOcorr,AllTrim( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FORNEC"))) ),;
					(xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA"))),(xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE"))) )
	lRet := .F.
Endif

Return( lRet )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SendMailPRº Autor ³ Eneovaldo Roveri Jrº Data ³  11/03/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Envio de Notificação por Falha no Pedido Recorrente.       º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function SendMailPRec(cModelo,cFilename,cOcorr,cNome,cNota,cSerie,cDirLog,cArqLog)
Local cPref   := ""
Local cTAG    := ""
Local cAnexo  := ""
Local cMsgErr := ""
Local cError  := ""

Default cNome   := ""
Default cNota   := ""
Default cSerie  := ""
Default cDirLog := ""
Default cArqLog := ""

If cModelo == "55"
 	cPref   := "NF-e"
	cTAG    := "NFE"
ElseIf cModelo == "57"
 	cPref   := "CT-e"
	cTAG    := "CTE"
EndIf

	cAnexo    := cDirLog + cArqLog
	cEmailErr := AllTrim(SuperGetMv("XM_MAIL03")) // Conta de Email para Pedido Recorrente
	lMailErr  := !Empty(cEmailErr)

	If lMailErr
	    aTo := Separa(cEmailErr,";")
		cMsg:=""
		If !Empty(cOcorr)
			cMsg+= "OCORRENCIA : "
			cMsg+= cOcorr+CRLF
	    EndIF

	    cMsg+= "Chave XML: "+ cFilename+CRLF
	    cMsg+= "Fornecedor: "+ cNome+CRLF
	    cMsg+= "Nota: "+ cNota+CRLF
	    cMsg+= "Série: "+ cSerie

	    cAssunto:= "Aviso de Falha do Pedido Recorrente Xml/"+cPref+" de Entrada."
		cDirMail  := AllTrim(SuperGetMv("MV_X_PATHX")) + "\template\"+"xml_erro.html"
		Iif(lUnix,StrTran(cDirMail,"\","/"),cDirMail)
		If File(cDirMail)
			cTemplate := MemoRead(cDirMail)
		Else
			cTemplate := ''
		EndIf

		cBodyMail := ""

		While !Empty(cTemplate)
			nPosIni := At("<%=",cTemplate)
			nPosFim := At("%>" ,SubStr(cTemplate,nPosIni+3))
			If nPosIni <> 0 .And. nPosFim <> 0
				cBodyMail += SubStr(cTemplate,1,nPosIni-1)
				cMacro := ""
				lBreak := .F.
				bErro  := ErrorBlock({|e| lBreak := .T. })
				Begin Sequence
					cMacro := SubStr(cTemplate,nPosIni+3,nPosFim-1)
					cMacro := &(cMacro)
					If lBreak
						Break
					EndIf
				Recover
					cMacro := "Error"
				End Sequence
				ErrorBlock(bErro)
				cBodyMail += AllTrim(cMacro)
				cTemplate := SubStr(cTemplate,nPosIni+nPosFim+4)
			Else
				cBodyMail += cTemplate
				cTemplate := ""
		    EndIf
		EndDo
	    If  !Empty(cBodyMail)
	    	cMsg := cBodyMail
	    EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Envia E-mail.                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//U_HX_MAIL(aTo,cAssunto,cMsg,@cMsgErr,cAnexo,cAnexo,cEmailErr)
		U_MAILSEND(aTo,cAssunto,cMsg,@cError,cAnexo,"",cEmailErr,"","")
	EndIf

Return(cMsgErr)



Static Function __Dummy(lRecursa) //warning W0010 Static Function <?> never called
    lRecursa := .F.
    IF (lRecursa)
        __Dummy(.F.)
        U_HFXML09()
        U_XML09PDR()
        U_XML09CABDC()
        U_XML09VPC()
        U_HFXML09P()
        U_XML09PC()
	EndIF
Return(lRecursa)
