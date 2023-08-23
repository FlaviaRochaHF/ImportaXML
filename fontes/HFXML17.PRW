#INCLUDE "PROTHEUS.CH"
#include 'TOTVS.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  HFXML17 บAutor  ณHeverton Marcondes  บ Data ณ  12/12/22      บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ocorrencia XML                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ HF Consulting                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function HFXML17()   

	Local aTipos	:= {}
	Local cOpcao	:= ""

	Private aBrowse 	:= {}
	Private oBrowse		:= Nil

	Private xZBH  	  := GetNewPar("XM_TABTPO","ZBH")      
	Private xZBH_ 	  := iif(Substr(xZBH,1,1)=="S", Substr(xZBH,2,2), Substr(xZBH,1,3)) + "_" 
	Private oDlgTp
	Private aSize  := MsAdvSize()
	
	If !Empty((xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODOCO"))))
		If !msgYesNo("Ocorrencia do tipo "+;
			(xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPOCOR")))+;
			" com a descri็ใo "+;
			(xZBZ)->(FieldGet(FieldPos(xZBZ_+"DESOCO")))+;
			" jแ gravada anteriormente, deseja sobreescrever?";
		)
			Return
		EndIf	
	EndIF	

	aAdd( aTipos, "" 					)
	aAdd( aTipos, "1=Devolu็ใo" 		)
	aAdd( aTipos, "2=Beneficiamento"    )             
	aAdd( aTipos, "3=Transfer๊ncia"    	)

	RetXml17(cOpcao)

	oFont := TFont():New('Courier new',,-16,.T.)

    DEFINE DIALOG oDlgTp TITLE "Ocorrencia XML" FROM aSize[7],00 To aSize[6],aSize[5] PIXEL
 
   		//Primeiro Quadro
		If (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC"))) $ "D|B"
			oGroup1:= TGroup():New(002,002,080,300,'Dados Cliente',oDlgTp,,,.T.)

			cCodigo := Posicione("SA1",3,xFilial("SA1")+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))),"A1_COD")
			oSCod	:= TSay():New(010,007,{||'Codigo'},oGroup1,,oFont,,,,.T.,CLR_BLUE,CLR_WHITE,030,10)
			oGCod 	:= TGet():New(010,040,{||cCodigo},oGroup1,050,010,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,cCodigo,,,,)

			cLoja 	:= Posicione("SA1",3,xFilial("SA1")+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))),"A1_LOJA")
			oSLoja	:= TSay():New(010,100,{||'Loja'},oGroup1,,oFont,,,,.T.,CLR_BLUE,CLR_WHITE,030,10)
			oGLoja 	:= TGet():New(010,135,{||cLoja},oGroup1,020,010,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,cLoja,,,,)

			cCnpj	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ")))
			oSCnpj	:= TSay():New(010,180,{||'Cnpj'},oGroup1,,oFont,,,,.T.,CLR_BLUE,CLR_WHITE,030,10)
			oGCnpj	:= TGet():New(010,210,{||cCnpj},oGroup1,70,010,"@R 99.999.999/9999-99",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,cCnpj,,,,)

			cNome	:= Posicione("SA1",3,xFilial("SA1")+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))),"A1_NOME")		
			oSNome	:= TSay():New(030,007,{||'Nome'},oGroup1,,oFont,,,,.T.,CLR_BLUE,CLR_WHITE,030,10)
			oGNome	:= TGet():New(030,040,{||cNome},oGroup1,200,010,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,cNome,,,,)
		Else
			oGroup1:= TGroup():New(002,002,080,300,'Dados Fornecedor',oDlgTp,,,.T.)

			cCodigo := Posicione("SA2",3,xFilial("SA2")+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))),"A2_COD")
			oSCod	:= TSay():New(010,007,{||'Codigo'},oGroup1,,oFont,,,,.T.,CLR_BLUE,CLR_WHITE,030,10)
			oGCod 	:= TGet():New(010,040,{||cCodigo},oGroup1,050,010,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,cCodigo,,,,)

			cLoja 	:= Posicione("SA2",3,xFilial("SA2")+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))),"A2_LOJA")
			oSLoja	:= TSay():New(010,100,{||'Loja'},oGroup1,,oFont,,,,.T.,CLR_BLUE,CLR_WHITE,030,10)
			oGLoja 	:= TGet():New(010,135,{||cLoja},oGroup1,020,010,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,cLoja,,,,)

			cCnpj	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ")))
			oSCnpj	:= TSay():New(010,180,{||'Cnpj'},oGroup1,,oFont,,,,.T.,CLR_BLUE,CLR_WHITE,030,10)
			oGCnpj	:= TGet():New(010,210,{||cCnpj},oGroup1,70,010,"@R 99.999.999/9999-99",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,cCnpj,,,,)

			cNome	:= Posicione("SA2",3,xFilial("SA2")+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))),"A2_NOME")		
			oSNome	:= TSay():New(030,007,{||'Nome'},oGroup1,,oFont,,,,.T.,CLR_BLUE,CLR_WHITE,030,10)
			oGNome	:= TGet():New(030,040,{||cNome},oGroup1,200,010,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,cNome,,,,)
		EndIf	

   		//Segundo Quadro
		oGroup2:= TGroup():New(002,320,080,600,'Dados Xml',oDlgTp,,,.T.)

   		cChave	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE")))
		oSChave	:= TSay():New(010,327,{||'Chave'},oGroup2,,oFont,,,,.T.,CLR_BLUE,CLR_WHITE,030,10)
		oGChave := TGet():New(010,360,{||cChave},oGroup2,150,010,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,cChave,,,,)

   		cNum	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA")))
		oSNum	:= TSay():New(030,327,{||'Nฐ Documento'},oGroup2,,oFont,,,,.T.,CLR_BLUE,CLR_WHITE,060,10)
		oGNum 	:= TGet():New(030,400,{||cNum},oGroup2,050,010,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,cNum,,,,)

   		cEmissao	:= dtoc((xZBZ)->(FieldGet(FieldPos(xZBZ_+"DTNFE"))))
		oSEmissao	:= TSay():New(030,470,{||'Dt Emissใo'},oGroup2,,oFont,,,,.T.,CLR_BLUE,CLR_WHITE,050,10)
		oGEmissao 	:= TGet():New(030,530,{||cEmissao},oGroup2,050,010,"@D",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,cEmissao,,,,)


		//Terceiro Quadro
		oGroup3:= TGroup():New(090,002,200,300,'Dados Complementares',oDlgTp,,,.T.)
 
		cComplem	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"ICOMPL")))
  		oTMultiget1 := tMultiget():new( 100,010,{||cComplem},oGroup3,280,92,,,,,,.T.,,,,,,.T.)

        //Quarto Quadro
		oGroup4:= TGroup():New(090,320,200,600,'Ocorrencia',oDlgTp,,,.T.)

        oBrowse := TCBrowse():New( 100,330,262,92,, {'Codigo','Descri็ใo','Tipo'},{20,50,20}, oGroup4,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
        oBrowse:SetArray(aBrowse)
        oBrowse:bLine := {||{aBrowse[oBrowse:nAt,01],aBrowse[oBrowse:nAt,02],aBrowse[oBrowse:nAt,03]}}
 
		//Rodape
		oSNome	:= TSay():New(230,010,{||'Tipo'},oDlgTp,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,030,10)
        oCombo1 := TComboBox():New(230,050,{|u|if(PCount()>0,cOpcao:=u,cOpcao)},aTipos,100,013,oDlgTp,,{|| RetXml17(cOpcao),oBrowse:SetArray(aBrowse),oBrowse:bLine := {||{aBrowse[oBrowse:nAt,01],aBrowse[oBrowse:nAt,02],aBrowse[oBrowse:nAt,03]}},oBrowse:Refresh(),oDlgTp:Refresh()},,,,.T.,,,,,,,,,'cOpcao')	
        
		TButton():New( 230, 190, "Gravar", 		oDlgTp,{|| XML17Grv(aBrowse[oBrowse:nAt,01],aBrowse[oBrowse:nAt,02],aBrowse[oBrowse:nAt,03]),oDlgTp:End()  																	},50,20,,,.F.,.T.,.F.,,.F.,,,.F.)
        TButton():New( 230, 270, "Sair", 		oDlgTp,{|| oDlgTp:End() 																																					},50,20,,,.F.,.T.,.F.,,.F.,,,.F.)

    ACTIVATE DIALOG oDlgTp CENTERED

Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  HFXML17 บAutor  ณHeverton Marcondes  บ Data ณ  12/12/22      บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ocorrencia XML                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ HF Consulting                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function RetXml17(cTipo)

	Local cQuery 	:= ""
	Local cAliasZBH	:= GetNextAlias()

	aBrowse := {}

	cQuery := "Select "+xZBH_+"COD as CODIGO, "+xZBH_+"DESC as DESCRICAO, "+xZBH_+"TIPO as TIPO "
	cQuery += " From "+RetSqlName(xZBH)+" ZBZ "
	cQuery += " where ZBZ.D_E_L_E_T_ = ' ' "
	cQuery += " and "+xZBH_+"TIPO = '"+cTipo+"'
	cQuery += " and "+xZBH_+"ATIVO <> '2'

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasZBH)

	DbSelectARea( cAliasZBH )
	(cAliasZBH)->( dbGoTop() )

	If Empty(cTipo) .Or. (cAliasZBH)->(Eof())
		aAdd(aBrowse,{" "," "," "}) 
	Else
		While !(cAliasZBH)->(Eof())
			aAdd(aBrowse,{(cAliasZBH)->(CODIGO),(cAliasZBH)->(DESCRICAO),(cAliasZBH)->(TIPO)}) 
			(cAliasZBH)->(dbSkip())
		End	
	EndIf	

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  HFXML17 บAutor  ณHeverton Marcondes  บ Data ณ  12/12/22      บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ocorrencia XML                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ HF Consulting                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function XML17Grv(cCod,cDesc,cTipo)

	Reclock(xZBZ,.F.)
		( xZBZ )->(FieldPut(FieldPos(xZBZ_+"CODOCO")	, cCod ))
		( xZBZ )->(FieldPut(FieldPos(xZBZ_+"DESOCO")	, cDesc ))
		( xZBZ )->(FieldPut(FieldPos(xZBZ_+"TPOCOR")	, cTipo ))
	(xZBZ)->(MsUnlock())

	msgInfo("Ocorr๊ncia gravada com sucesso!")	

Return

