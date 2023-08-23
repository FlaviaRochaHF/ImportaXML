#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

//========================================================================//
//Programa  ³ HFXMLR18  ºAutor  ³ Flávia Rocha    º Data ³  18/01/2021    //
//========================================================================//
//Descricao ³ Relatório geral de xmls x Documento de Entrada              //
//          ³ Chamado dentro das funções HFXMLGR1 e HFXMLGR2              //
//            para exportar as informações da tela para planilha Excel    //
//========================================================================//
//Uso       ³ IMPORTA XML - Análise Gráfica                               //
//========================================================================//

User Function HFXMLR18(aParams,lQuery,lDiverg,lSohXML,nTipoGraf)        
Local nX 		:= 0
Local aTab		:= {}
Local aCampos	:= {}
Local aErros	:= {"",""}
Local aBase		:= {"1=NF",;
					"2=XML"}   

Local aDiver	:= {"1=Desconsiderar",;
					"2=Valores",;
					"3=Quantidade",;
					"4=Impostos",;
					"5=Todos"}  

Local aImpCanc	:= {"1=Todas",;
					"2=Ativas",;
					"3=Canceladas"}

Local aAmarrac	:= {"1=Sim",;
					"2=Não"}

Private xZBZ		:= GetNewPar("XM_TABXML","ZBZ")
Private xZBZ_		:= iif(Substr(xZBZ,1,1)=="S", Substr(xZBZ,2,2), Substr(xZBZ,1,3)) + "_"  
Private xZBT		:= GetNewPar("XM_TABITEM","ZBT")		//Tabela de itens do xml
Private xZBT_		:= iif(Substr(xZBT,1,1)=="S", Substr(xZBT,2,2), Substr(xZBT,1,3)) + "_"
Private xZB5		:= GetNewPar("XM_TABAMAR","ZB5")		//Tabela Amarração de Produtos                      
Private xZB5_		:= iif(Substr(xZB5,1,1)=="S", Substr(xZB5,2,2), Substr(xZB5,1,3)) + "_"
Private xZBA		:= GetNewPar("XM_TABAMA2","ZBA")
Private xZBA_		:= iif(Substr(xZBA,1,1)=="S", Substr(xZBA,2,2), Substr(xZBA,1,3)) + "_"
Private xZBE		:= GetNewPar("XM_TABEVEN","ZBE")
Private xZBE_		:= iif(Substr(xZBE,1,1)=="S", Substr(xZBE,2,2), Substr(xZBE,1,3)) + "_"
Private xZBC		:= GetNewPar("XM_TABCAC","ZBC")
Private xZBC_		:= iif(Substr(xZBC,1,1)=="S", Substr(xZBC,2,2), Substr(xZBC,1,3)) + "_"
Private xZBO		:= GetNewPar("XM_TABOCOR","ZBO"), xRetSEF := ""
Private xZBO_		:= iif(Substr(xZBO,1,1)=="S", Substr(xZBO,2,2), Substr(xZBO,1,3)) + "_"
Private xZBI		:= GetNewPar("XM_TABIEXT","ZBI")
Private xZBI_		:= iif(Substr(xZBI,1,1)=="S", Substr(xZBI,2,2), Substr(xZBI,1,3)) + "_"
Private LF      	:= CHR(13) + CHR(10)
Private aParamBox	:= {}
Private aParam		:= {}
Private aRet		:= {}
Private aManif		:= {}
Private aStatus		:= {}
Private lDemonstra  := .F.
Private nTotReg     := 0
Private lSohZBZ     := .F.
Private nQuebra     := 0   //indica o tipo de quebra que será realizada, de acordo com o tipo de gráfico acionado

Default nTipoGraf   := 0
Default lSohXML     := .T.  //.T. = imprime só a linha do XML, .F. = imprime as duas linhas, XML e NOTA , caso haja NF

nQuebra := nTipoGraf
lSohZBZ := lSohXML  		//Indica se imprimirá a linha do XML APENAS ou as duas linhas: XML , NOTA FISCAL (caso haja)

dVencLic := Stod(Space(8))
//lUsoOk := U_HFXML00X("HF000001","101",SM0->M0_CGC,@dVencLic)
lUsoOk	:= U_HFXMLLIC(.F.)
lDemonstra := lDemo
If !lUsoOk
	Return(Nil)
EndIf

// Verifica se o Excel está instalado na máquina
If !ApOleClient("MSExcel")
    MsgAlert("Microsoft Excel não instalado!")
    Return
EndIf            

aTab	:= {xZBZ,xZBT,xZB5,xZBA,xZBE,xZBC,xZBO,xZBI}

aAdd(aCampos,{xZB5, {xZB5_+"FORNEC", xZB5_+"LOJFOR", xZB5_+"CGC",    xZB5_+"PRODFO", xZB5_+"PRODFI", xZB5_+"DESCPR"}})
aAdd(aCampos,{xZBZ, {xZBZ_+"FILIAL", xZBZ_+"NOTA",   xZBZ_+"SERIE",  xZBZ_+"CNPJ",   xZBZ_+"DTNFE",  xZBZ_+"CODFOR",;
					 xZBZ_+"LOJFOR", xZBZ_+"TPDOC",	 xZBZ_+"MODELO", xZBZ_+"PRENF",  xZBZ_+"PROTC", xZBZ_+"MANIF",;
					 xZBZ_+"DTRECB", xZBZ_+"CHAVE",  xZBZ_+"VLLIQ",  xZBZ_+"VLBRUT"}})
aAdd(aCampos,{xZBT, {xZBT_+"FILIAL", xZBT_+"NOTA",   xZBT_+"SERIE",  xZBT_+"PRODUT", xZBT_+"DESCRI", xZBT_+"CHAVE",;
				 	 xZBT_+"QUANT",  xZBT_+"VUNIT",  xZBT_+"TOTAL",  xZBT_+"ITEM",;
					 xZBT_+"ICMCST", xZBT_+"ICMBAS", xZBT_+"ICMALQ", xZBT_+"ICMVAL",; 
					 xZBT_+"IPIENQ", xZBT_+"IPICST", xZBT_+"IPIBAS", xZBT_+"IPIALQ", xZBT_+"IPIVAL",;
					 xZBT_+"PISCST", xZBT_+"PISBAS", xZBT_+"PISALQ", xZBT_+"PISVAL",;
					 xZBT_+"COFCST", xZBT_+"COFBAS", xZBT_+"COFALQ", xZBT_+"COFVAL"}})

aErros	:= HF18Erro(aTab, aCampos)

If !Empty(aErros[1])
	MsgAlert("Tabelas utilizadas na rotina ("+aErros[1]+") não foram localizadas!"+LF+"Favor rodar o compatibilizador para atualizar os campos/tabelas!")
	Return
ElseIf !Empty(aErros[2])
	MsgAlert("Campos utilizadas na rotina"+LF+" ("+aErros[2]+") "+LF+" não foram localizadas!"+LF+"Favor rodar o compatibilizador para atualizar os campos/tabelas!")
	Return
EndIf

//Status - Manifesto
Aadd( aManif, {"0", "Não" } )
Aadd( aManif, {"1", "Conf.Oper" } )
Aadd( aManif, {"2", "Oper.Desconh" } )
Aadd( aManif, {"3", "Oper.Não Realiz" } )
Aadd( aManif, {"4", "Ciência" } )
Aadd( aManif, {"5", "MCTe" } )
Aadd( aManif, {"W", "Pend.Conf" } )
Aadd( aManif, {"X", "Pend.Desc" } )
Aadd( aManif, {"Y", "Pend.N.Realiz" } )
Aadd( aManif, {"Z", "Pend.Ciência" } )

//Status XML
Aadd(aStatus, {"  " , "                     " } )
Aadd(aStatus, {"A"  , "Recebimento Carga    " } )	//Case xPrenf == 'A' 
Aadd(aStatus, {"B"  , "Importado            " } ) 	//Case xPrenf == 'B' .AND.  Empty(xCombus + xTpDowl)
Aadd(aStatus, {"S"  , "Pre-NF a Classificar " } ) 	//Case xPrenf == 'S'
Aadd(aStatus, {"N"  , "Pre-NF Classificada  " } )  //Case xPrenf == 'N' .AND. Empty(xCombus)
Aadd(aStatus, {"X"  , "Xml Cancel.Emissor   " } )  //Case xPrenf == 'X' .AND. xProtc <> ''
Aadd(aStatus, {"D"  , "XML Denegado         " } ) 	//Case xPrenf == 'D' 
Aadd(aStatus, {"F"  , "Falha Importação     " } ) 	//Case xPrenf == 'F' 
Aadd(aStatus, {"BR" , "XML Imp. Capa        " } ) 	//Case xPrenf == 'B' .AND.  xTpDowl == 'R'
Aadd(aStatus, {"Z"  , "XML Rejeitado        " } )  //Case xPrenf == 'Z'
Aadd(aStatus, {"BS" , "XML Imp.Combustivel  " } ) 	//Case xPrenf == 'B' .AND.  xCombus == 'S'
Aadd(aStatus, {"BE" , "XML Imp.Energia      " } )  //Case xPrenf == 'B' .AND.  xCombus == 'E'
Aadd(aStatus, {"NS" , "Pré-NF Class. Comb.  " } ) 	//Case xPrenf == 'N' .AND. xCombus == 'S'	
Aadd(aStatus, {"NE" , "Pré-NF Class. Energia" } ) 	//Case xPrenf == 'N' .AND. xCombus == 'E'


/*01*/AAdd( aParamBox, { 1, "Filial de"		,		SPACE(TamSX3('B1_FILIAL')[01])			,	"",	"",	"SM0",	"",	50,	.F.}) 
/*02*/AAdd( aParamBox, { 1, "Filial ate"	,		Replicate('Z' , TamSX3('B1_FILIAL')[01]),	"",	"",	"SM0",	"",	50,	.T.}) 
/*03*/AAdd( aParamBox, { 1, "Entrada de"	,		CTOD('01/01/2000')						,	"",	"",	"",	"",	50,	.T.})
/*04*/AAdd( aParamBox, { 1, "Entrada ate"	,		CTOD('31/12/2099')						,	"",	"",	"",	"",	50,	.T.})
/*05*/AAdd( aParamBox, { 1, "Serie de"		,		SPACE(TamSX3('D1_SERIE')[01])			,	"",	"",	"",	"",	50,	.F.}) 
/*06*/AAdd( aParamBox, { 1, "Serie ate"		,		Replicate('Z',TamSX3('D1_SERIE')[01])	,	"",	"",	"",	"",	50,	.T.}) 
/*07*/AAdd( aParamBox, { 1, "Nota de"		,		SPACE(TamSX3('D1_DOC')[01])				,	"",	"",	"SF1",	"",	50,	.F.}) 
/*08*/AAdd( aParamBox, { 1, "Nota ate"		,		Replicate('Z' , TamSX3('D1_DOC')[01])	,	"",	"",	"SF1",	"",	50,	.T.}) 
/*09*/AAdd( aParamBox, { 9, "Especies que devem ser consideradas separadas por virgula.",200,7,.T.})
/*10*/AAdd( aParamBox, { 9, "Ex.: SPED,CTE" ,200,7,.T.})
/*11*/AAdd( aParamBox, { 1, "Considera Especie",	'SPED                   ' /*SPACE(100)*/,	"",	"",	"",	"",	50,	.F.}) 
/*12*/AAdd( aParamBox, { 1, "Emissor XML de",		SPACE(6)								,	"",	"",	"SA2",	"",	50,	.F.})
/*13*/AAdd( aParamBox, { 1, "Emissor XML ate",		Replicate('Z', TamSX3('A2_COD')[1])		,	"",	"",	"SA2",	"",	50,	.T.})
/*14*/AAdd( aParamBox, { 1, "Loja Emissor de",		SPACE(2)								,	"",	"",	"",	"",	50,	.F.})
/*15*/AAdd( aParamBox, { 1, "Loja Emissor ate",		Replicate('Z',TamSX3('A2_LOJA')[1])		,	"",	"",	"",	"",	50,	.T.})
/*16*/AAdd( aParamBox, { 9, "Espécies consideradas como modelo de XML 55-NFe. ",200,6,.T.})
/*17*/AAdd( aParamBox, { 9, "Separadas por virgula. Ex.:NFE,CTE - Somente Base NF",200,6,.T.})
/*18*/AAdd( aParamBox, { 1, "Especie que são Modelo 55", 'NFE' /*SPACE(100)*/				,	"",	"",	"",	"",	50,	.F.}) 
/*19*/AAdd( aParamBox, { 1, "Emissao de"			,CTOD('01/01/2000')						,	"",	"",	"",	"",	50,	.T.}) 
/*20*/AAdd( aParamBox, { 1, "Emissao ate"			,CTOD('31/12/2099')						,	"",	"",	"",	"",	50,	.T.})
/*21*/AAdd( aParamBox, { 2, "Mostrar Divergencia"	,1										,	aDiver,	100,	"AllwaysTrue()",	.T.})
/*22*/AAdd( aParamBox, { 1, "Grupo de"				,SPACE(4)								,	"",	"",	"SBM",	"",	50,	.F.}) 
/*23*/AAdd( aParamBox, { 1, "Grupo ate"				,'ZZZZ' /*SPACE(4)*/					,	"",	"",	"SBM",	"",	50,	.T.}) 
/*24*/AAdd( aParamBox, { 2, "Analise Base (NF ou XML)",1									,	aBase,	100,	"AllwaysTrue()",	.T.})
/*25*/AAdd( aParamBox, { 2, "Imprimir Notas Canceladas",1									,	aImpCanc,100,	"AllwaysTrue()",	.T.})
/*26*/AAdd( aParamBox, { 2, "NF / XML sem Amarração",	1									,	aAmarrac,100,	"AllwaysTrue()",	.T.})


lCentered := .T.	//FR - 14/01/2021 - centraliza a janela de parâmetros
lCanSave  := .T.
lUserSave := .T.

//----------------------------------------------------------------------------------------------------------//
//Parambox - sintaxe geral
//ParamBox( < aParametros >  , < cTitle > , < aRet > , < bOk >, < aButtons > ,< lCentered >, < nPosX >,< nPosY > ,;
//          < oDlgWizard >, < cLoad > ,< lCanSave >,< lUserSave >  ) 

    // 1 - < aParametros > - Vetor com as configurações
    // 2 - < cTitle >      - Título da janela
    // 3 - < aRet >        - Vetor passador por referencia que contém o retorno dos parâmetros
    // 4 - < bOk >         - Code block para validar o botão Ok
    // 5 - < aButtons >    - Vetor com mais botões além dos botões de Ok e Cancel
    // 6 - < lCentered >   - Centralizar a janela
    // 7 - < nPosX >       - Se não centralizar janela coordenada X para início
    // 8 - < nPosY >       - Se não centralizar janela coordenada Y para início
    // 9 - < oDlgWizard >  - Utiliza o objeto da janela ativa
    //10 - < cLoad >       - Nome do perfil se caso for carregar
    //11 - < lCanSave >    - Salvar os dados informados nos parâmetros por perfil
    //12 - < lUserSave >   - Configuração por usuário
//----------------------------------------------------------------------------------------------------------//     


If aParams == Nil     							
	If ParamBox(aParamBox, "Parâmetros", @aRet,,,lCentered,,,,,lCanSave,lUserSave)
	
		For nX := 1 to Len(aParamBox)
			If aParambox[nX,1] == 2
				If ValType(aRet[nX]) == "C"
					aRet[nX] := Val(aRet[nX])
				EndIf
	
				aAdd(aParam,aParambox[nX,4,aRet[nX]])
			Else
				aAdd(aParam,aRet[nX])
			EndIf
		Next nX
	
		HF18Dados(aCampos,,.T.,lDemonstra)

		DbSelectArea("TRB")
		TRB->(Dbgotop())

		If TRB->(!Eof())

			Processa({|| HF18Rel()}, "Aguarde...", "Analisando base de dados...",.F.)

		Else

			MsgAlert("Sem Dados para Gerar o Relatório.")

		EndIf

	EndIf

Else 	//FR qdo chamado pela tela de divergências, já passa por parâmetro o número da NF

    aRet := Array(26)
	aRet[01] := aParams[01]
	aRet[02] := aParams[02]
	aRet[03] := aParams[03]
	aRet[04] := aParams[04]
	aRet[05] := aParams[05]
	aRet[06] := aParams[06]
	aRet[07] := aParams[07]
	aRet[08] := aParams[08]
	aRet[09] := aParams[09]
	aRet[10] := aParams[10]
	aRet[11] := aParams[11]
	aRet[12] := aParams[12]
	aRet[13] := aParams[13]
	aRet[14] := aParams[14]
	aRet[15] := aParams[15]
	aRet[16] := aParams[16]
	aRet[17] := aParams[17]
	aRet[18] := aParams[18]
	aRet[19] := aParams[19]
	aRet[20] := aParams[20]
	aRet[21] := aParams[21]
	aRet[22] := aParams[22]
	aRet[23] := aParams[23]
	aRet[24] := aParams[24]
	aRet[25] := aParams[25]
	aRet[26] := aParams[26]
	
	For nX := 1 to Len(aParamBox)

		If aParambox[nX,1] == 2		
			aAdd(aParam,aParambox[nX,4,aRet[nX]])
		Else
			aAdd(aParam,aRet[nX])
		EndIf

	Next nX 
		
	HF18Dados(aCampos,aParams,lQuery,lDemonstra)

	DbSelectArea("TRB")
	TRB->(Dbgotop())

	If TRB->(!Eof())

		lDiverg := .T.
		Processa({|| HF18Rel()}, "Aguarde...", "Analisando base de dados...",.F.)
	
	Else

		MsgAlert("Sem Dados para Gerar o Relatório.")

	EndIf

Endif

Return

//========================================================================//
// Programa    HF18Rel   ºAutoria: Flávia Rocha      Data ³  18/01/2021   //
//========================================================================//
// Descricao :Gera o relatório de pre-auditoria de confronto de xml vs.   //
//            Documento de Entrada                                        //
//========================================================================//
// Uso       : IMPORTA XML - Análise Gráfica                              //
//========================================================================//
Static Function HF18Rel()

Local cStartPath:= GetSrvProfString("Startpath","")
Local cTitulo   := ""
Local cArquivo  := "HFXMLR18.XML"
Local cPath     := ""  
Local cPlan     := ""
Local cTabela   := ""
Local cNFiscal	:= ""
Local cSerie	:= ""
Local cNF		:= ""
Local cObs		:= ""
Local cManif	:= ""
Local cStatXml	:= ""
Local nSequen	:= 0
Local nBaseNf 	:= aRet[24]
Local nX		:= 0
Local oExcel    := Nil
Local oExcelApp := Nil
Local nAtual    := 0

cPath     := "C:\TEMP\EXCEL\" //FR - 14/01/2021 - caminho completo e com a "\" no final também, senão, não abre o arquivo automaticamente

If !ExistDir(cPath)
	MakeDir(cPath)
EndIf

cPlan   := "Parametros" 
//If nQuebra == 0 .or. nQuebra == 5
	//cPlan += " - Todas as NF's"
//Endif

If lSohZBZ
	cTabela := "Relatório XML's"	//Título interno da planilha
Else
	cTabela := "Relatório Notas"
Endif

If nQuebra == 1 .or. nQuebra == 7
	cTitulo   += "Qtde x Valor"
Elseif nQuebra == 2
	cTitulo   += "Qtde x Status"
Elseif nQuebra == 3 .or. nQuebra == 8
	cTitulo   += "Valores x Tipo x Mês"
Elseif nQuebra == 4
	cTitulo   += "Qtde x Eventos"
Elseif nQuebra == 5
	cTitulo   += "Valores x Impostos - Geral"
Elseif nQuebra == 6
	cTitulo   += "Valores Impostos - XML x NF Entrada" 
Elseif nQuebra == 7
	cTitulo   += "Cena 1"
Elseif nQuebra == 8
	cTitulo   += "Cena 2"
Endif

oExcel    := FWMSEXCEL():New()

//cTabela := cPlan + "-" + cTabela + "-" + cTitulo
cTabela := cTabela + " - " + cTitulo

//GERA ABA COM OS PARAMETROS
oExcel:AddworkSheet(cPlan)
oExcel:AddTable(cPlan,cTabela)
oExcel:AddColumn(cPlan,cTabela,"Parametro",1,1,.F.)
oExcel:AddColumn(cPlan,cTabela,"Descricao",1,1,.F.)
oExcel:AddColumn(cPlan,cTabela,"Conteudo",1,1,.F.)

For nX := 1 to Len(aParambox)
	 oExcel:AddRow(cPlan,cTabela,{	"MV_PAR"+STRZERO(nX,2),;
                                    Alltrim(aParambox[nX,2]),;
                                    aParam[nX]})
Next nX

ProcRegua( nTotReg )

dbSelectArea("TRB")
TRB->(dbGoTop())

If nQuebra == 0 .or. nQuebra == 5 .or. nQuebra == 6
	cPlan := "Todas as Notas"
	oExcel:AddworkSheet(cPlan)
	oExcel:AddTable(cPlan,cTabela)

	oExcel:AddColumn(cPlan,cTabela,"Tipo",1,1,.F.)  			//1
	oExcel:AddColumn(cPlan,cTabela,"Modelo",1,1,.F.)  			//2
	oExcel:AddColumn(cPlan,cTabela,"Nota",1,1,.F.)      		//3
	oExcel:AddColumn(cPlan,cTabela,"Serie",1,1,.F.) 			//4
	oExcel:AddColumn(cPlan,cTabela,"Fornecedor",1,1,.F.)  		//5
	oExcel:AddColumn(cPlan,cTabela,"Observacao",1,1,.F.)		//6
	oExcel:AddColumn(cPlan,cTabela,"Emissão",1,4,.F.)			//7
	oExcel:AddColumn(cPlan,cTabela,"Item",1,1,.F.)   			//8
	oExcel:AddColumn(cPlan,cTabela,"Codigo",1,1,.F.)			//9
	oExcel:AddColumn(cPlan,cTabela,"Produto",1,1,.F.) 			//10
	oExcel:AddColumn(cPlan,cTabela,"Quantidade",1,2,.F.)		//11
	oExcel:AddColumn(cPlan,cTabela,"Vlr Unit",1,3,.F.) 			//12
	oExcel:AddColumn(cPlan,cTabela,"Vlr Total",1,3,.F.) 		//13
	oExcel:AddColumn(cPlan,cTabela,"Base IPI",1,3,.F.) 			//14
	oExcel:AddColumn(cPlan,cTabela,"Aliq. IPI",1,2,.F.)  		//15
	oExcel:AddColumn(cPlan,cTabela,"Vlr IPI",1,3,.F.)  			//16
	oExcel:AddColumn(cPlan,cTabela,"Base ICMS",1,3,.F.)			//17
	oExcel:AddColumn(cPlan,cTabela,"Aliq. ICMS",1,2,.F.)		//18
	oExcel:AddColumn(cPlan,cTabela,"Vlr ICMS",1,3,.F.)   		//19
	oExcel:AddColumn(cPlan,cTabela,"Base PIS",1,3,.F.)         	//20
	oExcel:AddColumn(cPlan,cTabela,"Aliq. PIS",1,2,.F.)  		//21
	oExcel:AddColumn(cPlan,cTabela,"Vlr PIS",1,3,.F.) 			//22
	oExcel:AddColumn(cPlan,cTabela,"Base COF",1,3,.F.) 			//23
	oExcel:AddColumn(cPlan,cTabela,"Aliq. COF",1,2,.F.)  		//24
	oExcel:AddColumn(cPlan,cTabela,"Vlr COF",1,3,.F.) 			//25
	oExcel:AddColumn(cPlan,cTabela,"Chave",1,1,.F.)        		//26
	oExcel:AddColumn(cPlan,cTabela,"Manifesto",1,1,.F.)   		//27
	oExcel:AddColumn(cPlan,cTabela,"Status XML",1,1,.F.) 		//28
	oExcel:AddColumn(cPlan,cTabela,"Base CSLL",1,3,.F.)     	//29
	oExcel:AddColumn(cPlan,cTabela,"Aliq. CSLL",1,2,.F.) 		//30
	oExcel:AddColumn(cPlan,cTabela,"Vlr CSLL",1,3,.F.)   		//31
	oExcel:AddColumn(cPlan,cTabela,"Base IRRF",1,3,.F.)			//32
	oExcel:AddColumn(cPlan,cTabela,"Aliq. IRRF",1,2,.F.)		//33
	oExcel:AddColumn(cPlan,cTabela,"Vlr IRRF",1,3,.F.) 			//34
Endif

cModelo := ""
cStatus := ""
cNomeSt := ""
cEvento := ""
nSequen := 1
lMuda   := .F.

If nQuebra == 0
	cArquivo  := "HFXMLR18_Geral.XML"
Elseif nQuebra == 1
	cArquivo  := "Graf1_tpnf.XML"	
Elseif nQuebra == 2
	cArquivo  := "Graf2_stnf.XML" 
Elseif nQuebra == 3
	cArquivo  := "Graf3_vlmes.XML"
Elseif nQuebra == 4
	cArquivo  := "Graf4_evento.XML"
Elseif nQuebra == 5
	cArquivo  := "Graf5_vlimposto.XML"
Elseif nQuebra == 6
	cArquivo  := "Graf6_vlimp_x_nfe.XML"
Elseif nQuebra == 7
	cArquivo  := "Cena1.XML"
Elseif nQuebra == 8
	cArquivo  := "Cena2.XML"
Endif

cPrenf      := ""
cCombus     := ""
cTpdow      := ""
cDtnfe      := ""
dData       := Ctod("  /  /    ")
cMes        := ""
	
While TRB->(!Eof())

	//Incrementa a mensagem na régua
    nAtual++
        
	IncProc( "Processando dados " + cValToChar( nAtual ) + " de " + cValToChar( nTotReg ) )
	//se quiser uma aba para cada fornecedor, reativar este bloco
	/*
    If TRB->(CLIFOR+LOJA) <> cFornece .AND. TRB->&(xZBZ_+"CNPJ") <> cFornece
		
		nSequen += 1
		
		If !Empty(TRB->CLIFOR)

			cFornece    := TRB->(CLIFOR+LOJA)
			cPlan       := STRZERO(nSequen,4)+"_"+LEFT(TRB->(NREDUZ),15)
			cTabela 	:= cFornece +" - "+ AllTrim(TRB->NOME) +" - "+ AllTrim(TRB->(CNPJ))

		Else

			cFornece	:= TRB->&(xZBZ_+"CNPJ")
			//cPlan       := cFornece
			cPlan       := STRZERO(nSequen,4)+"_" + cFornece		
			cTabela		:= "Não Cadastrado - CNPJ: "+cFornece
			
		EndIf
	*/
	lVai := .F.
	
	If nQuebra == 4
		If Alltrim(TRB->TPEVE) <> ''  //neste caso fiz esta condição para que somente imprima as notas em que haja evento associado na ZBE
			lVai := .T.
		Endif
	Else
		lVai := .T.
	Endif
	
	If lVai
	
		lMuda       := .F.		//indica a mudança para criação de nova aba para o excel
		cManif		:= ""
		cStatXml	:= ""
		cNomeSt     := ""

		If aScan( aManif, {|x| x[1] = TRB->(&(xZBZ_+"MANIF")) } ) > 0
			cManif := aManif[aScan( aManif, {|x| x[1] = TRB->(&(xZBZ_+"MANIF")) } )][2]
		EndIf
		
		cStatXml := fGetStatus(TRB->PRENF , TRB->COMBUS, TRB->TPDOWL, TRB->PROTC)    //(xPrenf,xCombus,xTpDowl,xProtc)
		
		If nQuebra == 0
		//se for usar uma aba para cada fornecedor, reativar este bloco:
		/*
			oExcel:AddworkSheet(cPlan)
		    oExcel:AddTable(cPlan,cTabela)
			oExcel:AddColumn(cPlan,cTabela,"Tipo",1,1,.F.)   		//1
			oExcel:AddColumn(cPlan,cTabela,"Modelo",1,1,.F.) 		//2
			oExcel:AddColumn(cPlan,cTabela,"Nota",1,1,.F.)   		//3
			oExcel:AddColumn(cPlan,cTabela,"Serie",1,1,.F.)  		//4
			oExcel:AddColumn(cPlan,cTabela,"Fornecedor",1,1,.F.)  	//5
			oExcel:AddColumn(cPlan,cTabela,"Observacao",1,1,.F.) 	//6
			oExcel:AddColumn(cPlan,cTabela,"Emissão",1,4,.F.)  		//7
			oExcel:AddColumn(cPlan,cTabela,"Item",1,1,.F.) 			//8
			oExcel:AddColumn(cPlan,cTabela,"Codigo",1,1,.F.) 		//9
			oExcel:AddColumn(cPlan,cTabela,"Produto",1,1,.F.)		//10
			oExcel:AddColumn(cPlan,cTabela,"Quantidade",1,2,.F.) 	//11
			oExcel:AddColumn(cPlan,cTabela,"Vlr Unit",1,3,.F.)  	//12
			oExcel:AddColumn(cPlan,cTabela,"Vlr Total",1,3,.F.) 	//13
			oExcel:AddColumn(cPlan,cTabela,"Base IPI",1,3,.F.)      //14
			oExcel:AddColumn(cPlan,cTabela,"Aliq. IPI",1,2,.F.)     //15
			oExcel:AddColumn(cPlan,cTabela,"Vlr IPI",1,3,.F.)       //16
			oExcel:AddColumn(cPlan,cTabela,"Base ICMS",1,3,.F.)     //17
			oExcel:AddColumn(cPlan,cTabela,"Aliq. ICMS",1,2,.F.)    //18
			oExcel:AddColumn(cPlan,cTabela,"Vlr ICMS",1,3,.F.)      //19
			oExcel:AddColumn(cPlan,cTabela,"Base PIS",1,3,.F.)      //20
			oExcel:AddColumn(cPlan,cTabela,"Aliq. PIS",1,2,.F.)     //21
			oExcel:AddColumn(cPlan,cTabela,"Vlr PIS",1,3,.F.)       //22
			oExcel:AddColumn(cPlan,cTabela,"Base COF",1,3,.F.)      //23
			oExcel:AddColumn(cPlan,cTabela,"Aliq. COF",1,2,.F.)     //24
			oExcel:AddColumn(cPlan,cTabela,"Vlr COF",1,3,.F.)       //25
			oExcel:AddColumn(cPlan,cTabela,"Chave",1,1,.F.)         //26
			oExcel:AddColumn(cPlan,cTabela,"Manifesto",1,1,.F.) 	//27
			oExcel:AddColumn(cPlan,cTabela,"Status XML",1,1,.F.)	//28
			oExcel:AddColumn(cPlan,cTabela,"Base CSLL",1,3,.F.)     //29
			oExcel:AddColumn(cPlan,cTabela,"Aliq. CSLL",1,2,.F.)    //30
			oExcel:AddColumn(cPlan,cTabela,"Vlr CSLL",1,3,.F.)      //31
			oExcel:AddColumn(cPlan,cTabela,"Base IRRF",1,3,.F.)     //32
			oExcel:AddColumn(cPlan,cTabela,"Aliq. IRRF",1,2,.F.)    //33
			oExcel:AddColumn(cPlan,cTabela,"Vlr IRRF",1,3,.F.)      //34
		  */
		ElseIf nQuebra == 1 .or. nQuebra == 7 //por modelo, para o graf.1, (faz uma aba para cada modelo de xml (CTE, NFE), acompanhando o esquema do gráfico) //quebra == 7 vem da cena1
			If Alltrim(TRB->MODELO) <> Alltrim(cModelo)
				nSequen += 1
				cPlan   := STRZERO(nSequen,4) + "-" + TRB->MODELO
				cTabela := "Tipo NF: " + TRB->MODELO
				cModelo := TRB->MODELO
				lMuda   := .T.
			Endif
				
		Elseif nQuebra == 2	//qtde de nf por status, para o graf.2, (faz uma aba para cada status de xml, acompanhando o esquema do gráfico)
		
			If Alltrim(TRB->PRENF) != Alltrim(cPrenf) .or. Alltrim(TRB->COMBUS) != Alltrim(cCombus) .or. Alltrim(TRB->TPDOWL) != Alltrim(cTpdow)
				nSequen += 1	
				cNomeSt := fGetStatus(TRB->PRENF , TRB->COMBUS, TRB->TPDOWL, TRB->PROTC)    //(xPrenf,xCombus,xTpDowl,xProtc)
				cPlan   := STRZERO(nSequen,4) + "_" + cNomeSt  	//nome da aba
				cTabela := "Status: " + cNomeSt 				//título dentro da planilha
				cPrenf  := TRB->PRENF
				cCombus := TRB->COMBUS
				cTpdow  := TRB->TPDOWL
				lMuda   := .T.
			Endif				
		Elseif nQuebra == 3 .or. nQuebra == 8  	//valores de xml por mês e tipo xml, para o graf.3 (faz uma aba para cada mês, acompanhando o esquema do gráfico) //quebra == 8 vem da cena2
			If Alltrim(Substr(TRB->DTNFE,5,2)) <> Alltrim(Substr(cDtnfe,5,2))
				dData   := Stod( TRB->DTNFE )
				cMes    := MesExtenso(dData)  //transforma a data em mês por extenso, ex.: 21/01/2021 -> Janeiro
				nSequen += 1
				cPlan   := STRZERO(nSequen,4) + "-" + cMes
				cTabela := cMes
				cDtnfe  := TRB->DTNFE
				lMuda   := .T.
			Endif
			
		Elseif nQuebra == 4		//por eventos
			If Alltrim(TRB->TPEVE) <> Alltrim(cEvento)
				nSequen += 1
				cPlan   := STRZERO(nSequen,4) + "-" + TRB->EVENTO
				cTabela := "Evento: " + TRB->EVENTO
				cEvento := TRB->TPEVE
				lMuda   := .T.
			Endif
			
		Elseif nQuebra == 5
				//Neste não tem quebra, apresenta todas as notas em sequência	
		Endif	
		
		If lMuda	
		    oExcel:AddworkSheet(cPlan)
		    oExcel:AddTable(cPlan,cTabela)
			oExcel:AddColumn(cPlan,cTabela,"Tipo",1,1,.F.)   		//1
			oExcel:AddColumn(cPlan,cTabela,"Modelo",1,1,.F.) 		//2
			oExcel:AddColumn(cPlan,cTabela,"Status XML",1,1,.F.)	//3
			oExcel:AddColumn(cPlan,cTabela,"Nota",1,1,.F.)   		//4
			oExcel:AddColumn(cPlan,cTabela,"Serie",1,1,.F.)  		//5
			oExcel:AddColumn(cPlan,cTabela,"Fornecedor",1,1,.F.)  	//6
			oExcel:AddColumn(cPlan,cTabela,"Observacao",1,1,.F.) 	//7
			oExcel:AddColumn(cPlan,cTabela,"Emissão",1,4,.F.)  		//8
			oExcel:AddColumn(cPlan,cTabela,"Item",1,1,.F.) 			//9
			oExcel:AddColumn(cPlan,cTabela,"Codigo",1,1,.F.) 		//10
			oExcel:AddColumn(cPlan,cTabela,"Produto",1,1,.F.)		//11
			oExcel:AddColumn(cPlan,cTabela,"Quantidade",1,2,.F.) 	//12
			oExcel:AddColumn(cPlan,cTabela,"Vlr Unit",1,3,.F.)  	//13
			oExcel:AddColumn(cPlan,cTabela,"Vlr Total",1,3,.F.) 	//14
			/*
			oExcel:AddColumn(cPlan,cTabela,"Base IPI",1,3,.F.)
			oExcel:AddColumn(cPlan,cTabela,"Aliq. IPI",1,2,.F.)
			oExcel:AddColumn(cPlan,cTabela,"Vlr IPI",1,3,.F.)
			oExcel:AddColumn(cPlan,cTabela,"Base ICMS",1,3,.F.)
			oExcel:AddColumn(cPlan,cTabela,"Aliq. ICMS",1,2,.F.)
			oExcel:AddColumn(cPlan,cTabela,"Vlr ICMS",1,3,.F.)
			oExcel:AddColumn(cPlan,cTabela,"Base PIS",1,3,.F.)
			oExcel:AddColumn(cPlan,cTabela,"Aliq. PIS",1,2,.F.)
			oExcel:AddColumn(cPlan,cTabela,"Vlr PIS",1,3,.F.)
			oExcel:AddColumn(cPlan,cTabela,"Base COF",1,3,.F.)
			oExcel:AddColumn(cPlan,cTabela,"Aliq. COF",1,2,.F.)
			oExcel:AddColumn(cPlan,cTabela,"Vlr COF",1,3,.F.)
			oExcel:AddColumn(cPlan,cTabela,"Chave",1,1,.F.)
			*/
			oExcel:AddColumn(cPlan,cTabela,"Manifesto",1,1,.F.) 	//15		
				
			//oExcel:AddColumn(cPlan,cTabela,"Base CSLL",1,3,.F.)
			//oExcel:AddColumn(cPlan,cTabela,"Aliq. CSLL",1,2,.F.)
			//oExcel:AddColumn(cPlan,cTabela,"Vlr CSLL",1,3,.F.)
			//oExcel:AddColumn(cPlan,cTabela,"Base IRRF",1,3,.F.)
			//oExcel:AddColumn(cPlan,cTabela,"Aliq. IRRF",1,2,.F.)
			//oExcel:AddColumn(cPlan,cTabela,"Vlr IRRF",1,3,.F.)
		Endif //se mudou o modelo, nova aba		
    	
      
		//imprime linha em branco separando qdo troca a nota	
		If nBaseNf == 1
			If !Empty(cNF) .AND. cNF <> TRB->(NOTA+SERIE)
				If nQuebra == 0 .or. nQuebra == 5 .or. nQuebra == 6
					oExcel:AddRow(cPlan,cTabela,ARRAY(34))			
				Else 
					oExcel:AddRow(cPlan,cTabela,ARRAY(15))			
				Endif
			EndIf
	
			cNF := TRB->(NOTA+SERIE)
		Else
			If !Empty(cNF) .AND. Alltrim(cNF) <> Alltrim( TRB->(&(xZBZ_+"NOTA")+&(xZBZ_+"SERIE")) )
				If nQuebra == 0 .or. nQuebra == 5 .or. nQuebra == 6
					oExcel:AddRow(cPlan,cTabela,ARRAY(34))
				Else 
					oExcel:AddRow(cPlan,cTabela,ARRAY(15))			
				Endif
			EndIf
	
			cNF := TRB->(&(xZBZ_+"NOTA")+&(xZBZ_+"SERIE"))
		EndIf
		//fim linha em branco separando									
	
		If nBaseNf == 1
			cNFiscal	:= TRB->NOTA
			cSerie		:= TRB->SERIE
			If Empty(TRB->&(xZBZ_+"NOTA"))
				cObs	:= "XML NÃO CADASTRADO"	
			Else			
				cObs	:= ""
			EndIf
			
		Else		//Base XML
		
			cNFiscal	:= TRB->&(xZBZ_+"NOTA")
			cSerie		:= TRB->&(xZBZ_+"SERIE")
			If Empty(TRB->NOTA)
				cObs	:= "NOTA NÃO CADASTRADA"		
			Else
				cObs	:= ""
			EndIf
		EndIf
	
		//-----------------------//
		//obs para a linha da NF
		//-----------------------//		
	   	cTipoNf := Iif(Empty( TRB->&(xZBZ_+"TPDOC")),"N",TRB->&(xZBZ_+"TPDOC"))
		//Localiza se a NF existe na base, em virtude do XML estar cancelado
		If !Empty(TRB->CLIFOR)
			
			cForn    := TRB->(CLIFOR+LOJA)
			
			SF1->(OrdSetFocus(1))
			If SF1->(Dbseek(xFilial("SF1") + cNF + cForn)) 				
				If !Empty(SF1->F1_STATUS)
					cObs	:= "PRE-NOTA CLASSIFICADA"
				Endif
			Endif
		
		Else
			cForn	:= TRB->&(xZBZ_+"CNPJ")
			If cTipoNf == "N"
			
				SA2->(OrdSetFocus(3))   //A2_FILIAL + A2_CGC
				If SA2->(Dbseek(xFilial("SA2") + cForn ))
				
					SF1->(OrdSetFocus(1))
					If SF1->(Dbseek(xFilial("SF1") + cNF + SA2->A2_COD + SA2->A2_LOJA ))
						If !Empty(SF1->F1_STATUS)
							cObs	:= "PRE-NOTA CLASSIFICADA"
						Endif						
					Endif						
				Endif
				
			Else  //SE tipo da NF for D/B usa SA1
			
				SA1->(OrdSetFocus(3))
				If SA1->(Dbseek(xFilial("SA1") + cForn ))
				
					SF1->(OrdSetFocus(1))
					If SF1->(Dbseek(xFilial("SF1") + cNF + SA1->A1_COD + SA1->A1_LOJA))
						If !Empty(SF1->F1_STATUS)
							cObs	:= "PRE-NOTA CLASSIFICADA"
						Endif						
					Endif						
				Endif				
			Endif	//SE tipo da NF for D/B usa SA1				
		Endif		
	    
	    If !lSohZBZ  //se a impressão inclui tb a linha da NF , imprime esta linha:
			oExcel:AddRow(cPlan,cTabela,{   "NOTA",;
										TRB->MODELO,;
										cStatXml,; 
										cNFiscal,;
										cSerie,;
										TRB->CLIFOR + "/" + TRB->LOJA + "-" + TRB->NREDUZ,;
										cObs,;
										STOD(TRB->EMINF),;
										TRB->D1_ITEM,;
										TRB->D1_COD,;
										TRB->B1_DESC,;
										TRB->D1_QUANT,;
										TRB->D1_VUNIT,;
										TRB->D1_TOTAL,;
										TRB->D1_BASEIPI,;
										TRB->D1_IPI,;
										TRB->D1_VALIPI,;
										TRB->D1_BASEICM,;
										TRB->D1_PICM,;
										TRB->D1_VALICM,;
										TRB->D1_BASIMP6,;  	
										TRB->D1_ALQPIS,;
										TRB->D1_VALIMP6,; 	
										TRB->D1_BASIMP5,;	
										TRB->D1_ALQCOF,;
										TRB->D1_VALIMP5,;	
										TRB->F1_CHVNFE,;
										cManif,;										 
										TRB->D1_BASECSL,;
										TRB->D1_ALQCSL,;
										TRB->D1_VALCSL,;
										TRB->D1_BASEIRR,;
										TRB->D1_ALIQIRR,;
										TRB->D1_VALIRR	} )
		Endif
	
		//------------------------//
		//obs para a linha do XML
		//------------------------//
		//FR - se o XML estiver cancelado:	
		If TRB->&(xZBZ_+"PRENF") == "X"
			cObs := "XML CANCELADO"
		Endif
	
		If nQuebra == 0 .or. nQuebra == 5 .or. nQuebra == 6
			oExcel:AddRow(cPlan,cTabela,{   "XML",;
										TRB->MODELO,;
										cStatXml,; 
										cNFiscal,;
										cSerie,;
										TRB->NOMFOR,; //&(xZBZ_+"FORNEC"),;   //TRB->&(xZBZ_+"CNPJ"),;
										cObs,;
										STOD(TRB->&(xZBZ_+"DTNFE")),;
										TRB->&(xZBT_+"ITEM"),;
										TRB->&(xZBT_+"PRODUT"),;
										TRB->&(xZBT_+"DESCRI"),;
										TRB->&(xZBT_+"QUANT"),;
										TRB->&(xZBT_+"VUNIT"),;
										TRB->&(xZBT_+"TOTAL"),;
										TRB->&(xZBT_+"IPIBAS"),;
										TRB->&(xZBT_+"IPIALQ"),;
										TRB->&(xZBT_+"IPIVAL"),;
										TRB->&(xZBT_+"ICMBAS"),;
										TRB->&(xZBT_+"ICMALQ"),;
										TRB->&(xZBT_+"ICMVAL"),;
										TRB->&(xZBT_+"PISBAS"),;
										TRB->&(xZBT_+"PISALQ"),;
										TRB->&(xZBT_+"PISVAL"),;
										TRB->&(xZBT_+"COFBAS"),;
										TRB->&(xZBT_+"COFALQ"),;
										TRB->&(xZBT_+"COFVAL"),;
										TRB->&(xZBT_+"CHAVE"),;
										cManif,;									 
										0,;//BASECSL
										0,;//ALQCSL
										0,;//VALCSL
										0,;//BASEIRR
										0,;//ALIQIRR
										0 ; //VALIRR
										} )									
	    Else 
	    	oExcel:AddRow(cPlan,cTabela,{   "XML",;
										TRB->MODELO,;
										cStatXml,;
										cNFiscal,;
										cSerie,;
										TRB->NOMFOR,; //&(xZBZ_+"FORNEC"),;   //TRB->&(xZBZ_+"CNPJ"),;
										cObs,;
										STOD(TRB->&(xZBZ_+"DTNFE")),;
										TRB->&(xZBT_+"ITEM"),;
										TRB->&(xZBT_+"PRODUT"),;
										TRB->&(xZBT_+"DESCRI"),;
										TRB->&(xZBT_+"QUANT"),;
										TRB->&(xZBT_+"VUNIT"),;
										TRB->&(xZBT_+"TOTAL"),;								
										cManif } )   
										//0,;//BASECSL
										//0,;//ALQCSL
										//0,;//VALCSL
										//0,;//BASEIRR
										//0,;//ALIQIRR
										//0 ; //VALIRR
										//} )									
	    Endif
    Endif //lVai
    TRB->(dbSkip())
EndDo

oExcel:Activate()
oExcel:GetXMLFile( cArquivo )

CpyS2T( cStartPath + cArquivo, cPath )

oExcelApp := MsExcel():New()
oExcelApp:WorkBooks:Open( cPath + cArquivo ) // Abre a planilha 
oExcelApp:SetVisible(.T.)

MsgInfo("Arquivo Gravado na Pasta --> " + cPath + cArquivo )

Return

//========================================================================//
// Programa  ³ HF18Dados ºAutor  ³ Flávia Rocha    º Data ³  18/01/2021   //
//========================================================================//
// Descricao ³ Gera massa de dados para o relatorio                       //
//========================================================================//
// Uso       ³ IMPORTA XML                                                //
//========================================================================//
Static Function HF18Dados(aCampos,aParams,lQuery,lDemonstra)   

Local cQuery	:= ""
Local cQrAux	:= ""
Local nX      	:= 0
Local nY		:= 0
Local cFilDe  	:= aRet[1]
Local cFilAte 	:= aRet[2]
Local cDtIni  	:= DTos(aRet[3])
Local cDtFim  	:= DTos(aRet[4])
Local cSerIni 	:= aRet[5]
Local cSerFim 	:= aRet[6]
Local cNFIni  	:= aRet[7]
Local cNFFim  	:= aRet[8]   
Local cEspecie 	:= aRet[11]
Local aEspecie	:= {}
Local cForIni 	:= aRet[12]
Local cForFim 	:= aRet[13]
Local cLojaIni	:= aRet[14]
Local cLojaFim	:= aRet[15]
Local cModelo	:= aRet[18]
Local aModelo	:= {}
Local cEmIni  	:= DTos(aRet[19])
Local cEmFim  	:= DTos(aRet[20])
Local nDNfXml 	:= aRet[21] 
Local cGrupoIni	:= aRet[22]
Local cGrupoFim	:= aRet[23]
Local nBaseNf 	:= aRet[24]
Local nImpCanc	:= aRet[25]
Local nAmarrac	:= aRet[26]

Private cAliasXMl := GetNextAlias()

aEspecie := STRTOKARR(ALLTRIM(cEspecie),",")
If !Empty(aEspecie)
	cEspecie := ""
	For nX := 1 to Len(aEspecie)
		If !Empty(cEspecie)
			cEspecie += "','"
		EndIf 
		cEspecie += aEspecie[nX]
	Next nX
EndIf

aModelo := STRTOKARR(ALLTRIM(cModelo),",")
If !Empty(aModelo)
	cModelo := ""
	For nX := 1 to Len(aModelo)
		If aModelo[nX] $ 'NFE/CTE/NFSE'
			If !Empty(cModelo)
				cModelo += "','"
			EndIf
			
			If UPPER(aModelo[nX]) == 'NFE'
				cModelo += "55','65"
			ElseIf UPPER(aModelo[nX]) == 'CTE'
				cModelo += "57"
			ElseIf UPPER(aModelo[nX]) == 'NFSE'
				cModelo += "RP"
			EndIf
		EndIf
	Next nX
EndIf 

//FR - Tratativa para licença Demo:
If aParams == Nil
	If lDemonstra
		If ( (StoD(cDtFim) - StoD(cDtIni) > 30) .or. (StoD(cEmFim) - StoD(cEmIni) > 30) )
			MsgInfo("Foi Digitado o Período: " + DtoC(StoD(cDtIni)) + " A " + DtoC(StoD(cDtFim)) + "." + CRLF+;
			"Esta é Uma Licença de Demonstração, o Período para Consulta Será Limitado a Até 30 (Trinta) Dias Retroativos !")		
		Endif
	Endif
Endif

//-----------------------------------------------------------------------------------------------------------------------------------------//
//Caso o operador escolha a opção "base NF" e notas canceladas, a query abaixo não poderá ser executada (SF1) pois a nota estará cancelada, 
//irei direcionar para a query que a base é o XML.
//Acredito ser mais prudente assim, pois, mesmo que fizesse uma query pegando as notas deletadas, não seria seguro exibir isto ao usuário.
//-----------------------------------------------------------------------------------------------------------------------------------------//
//base somente NF e Notas não Canceladas
If nBaseNf == 1 .AND. nImpCanc <> 3

	cQuery := " SELECT	*, " + LF
	cQuery += "         A5_FORNECE, A5_LOJA, A5_PRODUTO, A5_NOMPROD, A5_CODPRF, " + LF + LF   //A5_CODPRF - código do produto do fornecedor
 	
	For nX := 1 to Len(aCampos)
		cQuery += "         "
		For nY := 1 to Len(aCampos[nX,2])
			cQuery += aCampos[nX,2,nY]+", "
		Next nY
		cQuery += LF +LF
	Next nX

	cQuery += "         ZBT.R_E_C_N_O_ ZBTRECNO, ZBZ.R_E_C_N_O_ ZBZRECNO, " +LF
	
	cQuery += " CASE " 										+ LF
	cQuery += "  WHEN "+xZBZ+"_MODELO = '55' "			   	+ LF
	cQuery += "    THEN 'NFE' "								+ LF
	cQuery += "  WHEN "+xZBZ+"_MODELO = '57' "				+ LF
	cQuery += "    THEN 'CTE' "								+ LF
	cQuery += "  WHEN "+xZBZ+"_MODELO = '65' "				+ LF
	cQuery += "    THEN 'NFCE' "							+ LF 
	cQuery += "  WHEN "+xZBZ+"_MODELO = '67' "				+ LF
	cQuery += "    THEN 'CTEOS' "							+ LF
	cQuery += "  WHEN "+xZBZ+"_MODELO = 'RP' "				+ LF
	cQuery += "    THEN 'NFSE' "					 		+ LF
	cQuery += "  END MODELO, "						   		+ LF
	
	cQuery += " " + xZBZ+"_FORNEC AS NOMFOR, "				+ LF	
	cQuery += " " + xZBZ+"_PRENF AS PRENF, " 				+ LF	
	cQuery += " " + xZBZ+"_COMBUS AS COMBUS, " 				+ LF	
	cQuery += " " + xZBZ+"_TPDOWL AS TPDOWL, " 				+ LF	
	cQuery += " " + xZBZ+"_PROTC AS PROTC, " 				+ LF   
	cQuery += " " + xZBZ+"_DTNFE AS DTNFE " 				+ LF   

	cQuery += "		FROM ( " +LF
	cQuery += "				SELECT "+LF
	//SF1
	cQuery += "						F1_FILIAL FILIAL, F1_DOC NOTA, F1_SERIE SERIE, (F1_FORNECE + F1_LOJA) AS ORDEM, F1_TIPO TIPONF, " + LF
 	cQuery += "						F1_ESPECIE ESPECIE, F1_EMISSAO EMINF, F1_DTDIGIT DTDIGIT, F1_CHVNFE, " + LF
 	cQuery += "						F1_VALBRUT VALBRUT, F1_VALMERC VALMERC, SF1.R_E_C_N_O_ F1RECNO, " + LF + LF	
 	//SD1
 	cQuery += "						D1_FILIAL, D1_DOC ITNOTA, D1_SERIE ITSERIE, D1_FORNECE, D1_LOJA, D1_ITEM ITEM, D1_COD, D1_QUANT, D1_VUNIT, D1_TOTAL, " + LF
 	cQuery += "						D1_EMISSAO, "+ LF
 	//IPI
 	cQuery += "						D1_BASEIPI, D1_VALIPI, D1_IPI, " + LF
 	//ICM
 	cQuery += "						D1_BASEICM, D1_VALICM, D1_PICM, " + LF
 	//IR
 	cQuery += "						D1_BASEIRR, D1_VALIRR, D1_ALIQIRR, " + LF
 	//ISS
 	cQuery += "						D1_BASEISS, D1_VALISS, D1_ALIQISS, " + LF
 	//INSS
 	cQuery += "						D1_BASEINS, D1_ALIQINS, D1_VALINS, " + LF
 	//PIS
 	cQuery += "						D1_BASIMP6, D1_VALIMP6, D1_BASEPIS, D1_VALPIS, D1_ALQPIS, " + LF		
 	//COFINS
 	cQuery += "						D1_BASIMP5, D1_VALIMP5, D1_BASECOF, D1_VALCOF, D1_ALQCOF, " + LF		
 	//CSLL
 	cQuery += "						D1_BASECSL, D1_VALCSL, D1_ALQCSL,  SD1.R_E_C_N_O_ D1RECNO, " + LF + LF
 	//SB1
 	cQuery += "						B1_COD, B1_DESC, B1_GRUPO,"  + LF + LF 
	//CLIFOR
	cQuery += "						CASE WHEN F1_TIPO IN ('D','B') THEN A1_COD ELSE A2_COD END CLIFOR, "+LF
    cQuery += "						CASE WHEN F1_TIPO IN ('D','B') THEN A1_LOJA ELSE A2_LOJA END LOJA, "+LF
    cQuery += "						CASE WHEN F1_TIPO IN ('D','B') THEN A1_NOME ELSE A2_NOME END NOME, "+LF
    cQuery += "						CASE WHEN F1_TIPO IN ('D','B') THEN A1_NREDUZ ELSE A2_NREDUZ END NREDUZ, "+LF
    cQuery += "						CASE WHEN F1_TIPO IN ('D','B') THEN A1_TEL ELSE A2_TEL END TEL, "+LF
    cQuery += "						CASE WHEN F1_TIPO IN ('D','B') THEN A1_CGC ELSE A2_CGC END CNPJ, "+LF
    cQuery += "						CASE WHEN F1_TIPO IN ('D','B') THEN A1_EMAIL ELSE A2_EMAIL END EMAIL "+LF

	cQuery += "					FROM "+RetSqlName("SF1")+" SF1 " + LF
	//SA1
	cQuery += "						LEFT JOIN "+RetSqlName("SA1")+" SA1 " + LF
	cQuery += "							ON A1_COD = F1_FORNECE " + LF
	cQuery += "							AND A1_LOJA = F1_LOJA  " + LF
	cQuery += "							AND SA1.D_E_L_E_T_ = ' ' " + LF
	//SA2
	cQuery += "						LEFT JOIN "+RetSqlName("SA2")+" SA2 " + LF
	cQuery += "							ON A2_COD = F1_FORNECE " + LF
	cQuery += "							AND A2_LOJA = F1_LOJA  " + LF
	cQuery += "							AND SA2.D_E_L_E_T_ = ' ' " + LF
	//SD1
	cQuery += "						INNER JOIN "+RetSqlName("SD1")+" SD1 " + LF
	cQuery += "							ON D1_FILIAL 	= F1_FILIAL " + LF
	cQuery += "							AND D1_DOC 		= F1_DOC " + LF
	cQuery += "							AND D1_SERIE 	= F1_SERIE " + LF
	cQuery += "							AND F1_TIPO 	= D1_TIPO " + LF
	cQuery += "							AND F1_FORNECE 	= D1_FORNECE " + LF
	cQuery += "							AND F1_LOJA 	= D1_LOJA " + LF
	cQuery += "							AND SD1.D_E_L_E_T_ = ' ' " + LF
	//SB1
	cQuery += "						INNER JOIN "+RetSqlName("SB1")+" SB1 " + LF
	cQuery += "							ON B1_COD = D1_COD " + LF
    cQuery += "							AND B1_GRUPO BETWEEN '" + cGrupoIni + "' AND '"+ cGrupoFim + "' " + LF
	cQuery += "							AND SB1.D_E_L_E_T_ = ' ' " + LF
	cQuery += "						WHERE SF1.D_E_L_E_T_ = ' ' " + LF

	If lQuery == Nil
		cQuery += "						AND SF1.F1_STATUS <> '' " + LF //somente notas classificadas 
	Endif
	
	If !lDemonstra		//FR - tratativa para licenças Demo
		cQuery += "						AND ( SF1.F1_DTDIGIT BETWEEN '"+ cDtIni  +"' AND '"+cDtFim+"' " + LF
		cQuery += "               				AND SF1.F1_EMISSAO BETWEEN '"+cEmIni+"' AND '"+cEmFim+"' )"+ LF
	Else
		cQuery += "						AND ( SF1.F1_DTDIGIT BETWEEN '"+ DtoS(Date()-30)  +"' AND '"+DtoS(Date())+"' " + LF
		cQuery += "								AND SF1.F1_EMISSAO BETWEEN '"+DtoS(Date()-30)+"' AND '"+ DtoS(Date())+"' )" + LF		
	EndIf   			//FR - tratativa para licenças Demo

	If !Empty(cEspecie)
		cQuery += "						AND SF1.F1_ESPECIE IN ('"+cEspecie+"') "+LF
	EndIf
	
	cQuery += "						AND SF1.F1_FILIAL	BETWEEN '"+cFilDe+"' AND '"+cFilAte+"' "+LF	
	cQuery += "						AND SF1.F1_DOC BETWEEN '"+cNFIni+"' AND '"+cNFFim+"' "+ LF
	cQuery += "						AND SF1.F1_SERIE BETWEEN '"+cSerIni+"' AND '"+cSerFim+"' "+LF						               
	cQuery += "						AND SF1.F1_FORNECE BETWEEN '"+cForIni+"' AND '"	+cForFim+"' "+LF					               
	cQuery += "						AND SF1.F1_LOJA	BETWEEN '"+cLojaIni+"' AND '"+cLojaFim+"' "+LF
	cQuery += "						AND SF1.F1_FORMUL <> 'S' "+LF
	cQuery += "				) TMP " +LF		               
    //SA5
	cQuery += "			LEFT JOIN "+RetSqlName("SA5")+" SA5 " + LF
	cQuery += "             ON A5_FORNECE = CLIFOR " + LF
    cQuery += "             AND A5_LOJA = LOJA " + LF
    cQuery += "             AND A5_PRODUTO = B1_COD " + LF
	cQuery += "             AND SA5.D_E_L_E_T_ = ' ' " + LF
	//ZBZ
	cQuery += "         LEFT JOIN " + RetSqlName(xZBZ) + " ZBZ " + LF
    cQuery += "             ON " + xZBZ_+"FILIAL = FILIAL " + LF
 	cQuery += "             AND " + xZBZ_+"CHAVE = F1_CHVNFE " + LF
 	cQuery += "             AND " + xZBZ_+"CNPJ  = CNPJ    " + LF
	cQuery += "             AND " + xZBZ_+"NOTA  = NOTA    " + LF
	cQuery += "             AND " + xZBZ_+"SERIE = SERIE  " + LF
	cQuery += "             AND " + xZBZ_+"TPDOC = TIPONF   " + LF
	If !Empty(cModelo)
		cQuery += "				AND " + xZBZ_+"MODELO IN ('"+cModelo+"') " +LF
	EndIf
	cQuery += "             AND ZBZ.D_E_L_E_T_ = ' ' " + LF

	//ZB5
	cQuery += "         LEFT JOIN " + RetSqlName(xZB5) + " ZB5 " + LF  
    cQuery += "             ON "+ xZB5_+"FILIAL = FILIAL " +LF        
	cQuery += "             AND "+ xZB5_+"CGC = CNPJ "+LF
	cQuery += "             AND "+ xZB5_+"PRODFI = D1_COD " +LF  //nosso código de amarração ser igual ao código da SD1
	cQuery += "             AND ZB5.D_E_L_E_T_ = ' ' " + LF

	//ZBT
	cQuery += "         LEFT JOIN " + RetSqlName(xZBT) + " ZBT " + LF
    cQuery += "             ON " + xZBT_+"FILIAL = " + xZBZ_+"FILIAL " + LF  
	cQuery += "             AND " + xZBT_+"CHAVE  = " + xZBZ_+"CHAVE " 	+ LF
	cQuery += "             AND ZBT_PRODUT = ZB5_PRODFO "				+ LF
	cQuery += "             AND ZBT.D_E_L_E_T_ = ' ' " + LF

	If lQuery
		If nAmarrac == 2
			cQuery += "			AND ZBT."+xZBT_+"VUNIT IS NOT NULL " + LF
		EndIf

		If nDNfXml <> 1
			cQuery += "         AND ("
			
			If nDNfXml == 2 .OR. nDNfXml == 5
				cQrAux += " D1_VUNIT <> ZBT."+xZBT_+"VUNIT " +LF 
				cQrAux += "             OR D1_TOTAL <> ZBT."+xZBT_+"TOTAL " +LF  		
			EndIf

			If nDNfXml == 3 .OR. nDNfXml == 5
				If !Empty(cQrAux)
					cQrAux += "             OR"
				EndIf
				cQrAux += " D1_QUANT <> ZBT."+xZBT_+"QUANT " +LF
			EndIf

			If nDNfXml == 4 .OR. nDNfXml == 5
				If !Empty(cQrAux)
					cQrAux += "             OR"
				EndIf
				cQrAux += " D1_BASEIPI <> ZBT."+xZBT_+"IPIBAS " + LF
				cQrAux += "             OR D1_VALIPI <> ZBT."+xZBT_+"IPIVAL " + LF
				cQrAux += "             OR D1_IPI <> ZBT."+xZBT_+"IPIALQ " + LF
				cQrAux += "             OR D1_BASEICM <> ZBT."+xZBT_+"ICMBAS " + LF
				cQrAux += "             OR D1_VALICM <> ZBT."+xZBT_+"ICMVAL " + LF
				cQrAux += "             OR D1_PICM <> ZBT."+xZBT_+"ICMALQ " + LF			
				cQrAux += "             OR D1_BASIMP6 <> ZBT."+xZBT_+"PISBAS " + LF					
				cQrAux += "             OR D1_VALIMP6 <> ZBT."+xZBT_+"PISVAL " + LF		
				cQrAux += "             OR D1_ALQPIS <> ZBT."+xZBT_+"PISALQ " + LF
				cQrAux += "             OR D1_BASIMP5 <> ZBT."+xZBT_+"COFBAS " + LF				
				cQrAux += "             OR D1_VALIMP5 <> ZBT."+xZBT_+"COFVAL " + LF	
				cQrAux += "             OR D1_ALQCOF <> ZBT."+xZBT_+"COFALQ " + LF
			EndIf

			If nAmarrac == 1
				cQrAux += "			 		OR ZBT."+xZBT_+"VUNIT IS NULL " + LF
			EndIf 

			cQuery += cQrAux

			cQuery += "				) " + LF
			
		EndIf
	EndIf
    
    If nQuebra == 0
		cQuery += " ORDER BY FILIAL, CLIFOR, LOJA, NOTA, SERIE, ITEM " +LF
	Elseif nQuebra == 1 .or. nQuebra == 7		//por modelo, ex.: NFE, CTE...
		cQuery += " ORDER BY FILIAL, MODELO, CLIFOR, LOJA, NOTA, SERIE, ITEM " + LF
	Elseif nQuebra == 2
		cQuery += " ORDER BY PRENF , COMBUS, TPDOWL, PROTC, FILIAL, CLIFOR, LOJA, NOTA, SERIE, ITEM "
	Elseif nQuebra == 3 .or. nQuebra == 8
		cQuery += " ORDER BY DTNFE, MODELO, FILIAL, CLIFOR, LOJA, NOTA, SERIE, ITEM "
	Endif

//Base Xml 
Else 

	cQuery := " SELECT	*, " + LF
	//SF1
	cQuery += "			F1_FILIAL FILIAL, F1_DOC NOTA, F1_SERIE SERIE, (F1_FORNECE + F1_LOJA) AS ORDEM, F1_TIPO TIPONF, " + LF
	cQuery += "			F1_ESPECIE ESPECIE, F1_EMISSAO EMINF, F1_DTDIGIT DTDIGIT, F1_CHVNFE, " + LF
	cQuery += "			F1_VALBRUT VALBRUT, F1_VALMERC VALMERC, SF1.R_E_C_N_O_ F1RECNO, " + LF + LF	
	//SD1
	cQuery += "			D1_FILIAL, D1_DOC ITNOTA, D1_SERIE ITSERIE, D1_FORNECE, D1_LOJA, D1_ITEM ITEM, D1_COD, D1_QUANT, D1_VUNIT, D1_TOTAL, " + LF
	cQuery += "			D1_EMISSAO, SD1.R_E_C_N_O_ D1RECNO, "+ LF
	//IPI
	cQuery += "			D1_BASEIPI, D1_VALIPI, D1_IPI, " + LF
	//ICM
	cQuery += "			D1_BASEICM, D1_VALICM, D1_PICM, " + LF
	//IR
	cQuery += "			D1_BASEIRR, D1_VALIRR, D1_ALIQIRR, " + LF
	//ISS
	cQuery += "			D1_BASEISS, D1_VALISS, D1_ALIQISS, " + LF
	//INSS
	cQuery += "			D1_BASEINS, D1_ALIQINS, D1_VALINS, " + LF
	//PIS
	cQuery += "			D1_BASIMP6, D1_VALIMP6, D1_BASEPIS, D1_VALPIS, D1_ALQPIS, " + LF	
	//COFINS
	cQuery += "			D1_BASIMP5, D1_VALIMP5, D1_BASECOF, D1_VALCOF, D1_ALQCOF, " + LF	
	//CSLL
	cQuery += "			D1_BASECSL, D1_VALCSL, D1_ALQCSL,  " + LF + LF
	//SA5
	cQuery += "         A5_FORNECE, A5_LOJA, A5_PRODUTO, A5_NOMPROD, A5_CODPRF " + LF + LF   //A5_CODPRF - código do produto do fornecedor
	
	cQuery += "		FROM ( " +LF
	cQuery += "				SELECT	" + LF
	//SB1
	cQuery += "						B1_COD, B1_DESC, B1_GRUPO,"  + LF + LF 
	For nX := 1 to Len(aCampos)
		cQuery += "						"
		For nY := 1 to Len(aCampos[nX,2])
			cQuery += aCampos[nX,2,nY]+", "
		Next nY
		cQuery += LF +LF
	Next nX

	cQuery += "		   ZBT.R_E_C_N_O_ ZBTRECNO, ZBZ.R_E_C_N_O_ ZBZRECNO, ZBZ.D_E_L_E_T_ ZBTDEL, "  +LF	
    //Para graf.1 - por tipo nf
	cQuery += " CASE " 										+ LF
	cQuery += "  WHEN "+xZBZ+"_MODELO = '55' "			   	+ LF
	cQuery += "    THEN 'NFE' "								+ LF
	cQuery += "  WHEN "+xZBZ+"_MODELO = '57' "				+ LF
	cQuery += "    THEN 'CTE' "								+ LF
	cQuery += "  WHEN "+xZBZ+"_MODELO = '65' "				+ LF
	cQuery += "    THEN 'NFCE' "							+ LF 
	cQuery += "  WHEN "+xZBZ+"_MODELO = '67' "				+ LF
	cQuery += "    THEN 'CTEOS' "							+ LF
	cQuery += "  WHEN "+xZBZ+"_MODELO = 'RP' "				+ LF
	cQuery += "    THEN 'NFSE' "					 		+ LF
	cQuery += "  END MODELO, "						   		+ LF
	//fim graf.1
	
	cQuery += " " + xZBZ+"_FORNEC AS NOMFOR, "				+ LF
	cQuery += " " + xZBZ+"_PRENF AS PRENF, " 				+ LF
	cQuery += " " + xZBZ+"_COMBUS AS COMBUS, " 				+ LF
	cQuery += " " + xZBZ+"_TPDOWL AS TPDOWL, " 				+ LF
	cQuery += " " + xZBZ+"_PROTC AS PROTC, " 				+ LF   
	cQuery += " " + xZBZ+"_DTNFE AS DTNFE, " 				+ LF
	
	//Para graf.4 - por evento
	cQuery += " ISNULL( " + xZBE+"_TPEVE,'') AS TPEVE, "   			+ LF
 	cQuery += " ISNULL( CASE "+xZBE+"_TPEVE "						+ LF
  	cQuery += "   WHEN '110110' THEN 'Carta de Correção' "    		+ LF
  	cQuery += "   WHEN '110111' THEN 'Cancelado'         "        	+ LF
	cQuery += "   WHEN '210200' THEN 'Confirmação da Operação' " 	+ LF
	cQuery += "   WHEN '210210' THEN 'Ciência da Operação'      " 	+ LF
	cQuery += "   WHEN '210220' THEN 'Desconhecimento da operação' "+ LF
	cQuery += "   WHEN '210240' THEN 'Operação não Realizada' "		+ LF
	cQuery += "   WHEN '610110' THEN 'Desacordo CTe' "				+ LF
   	cQuery += " END , '') EVENTO,    "								+ LF
    //fim graf.4
    
	//CLIFOR
	cQuery += "						CASE WHEN "+xZBZ_+"TPDOC IN ('D','B') THEN A1_COD ELSE A2_COD END CLIFOR, "+LF
    cQuery += "						CASE WHEN "+xZBZ_+"TPDOC IN ('D','B') THEN A1_LOJA ELSE A2_LOJA END LOJA, "+LF
    cQuery += "						CASE WHEN "+xZBZ_+"TPDOC IN ('D','B') THEN A1_NOME ELSE A2_NOME END NOME, "+LF
    cQuery += "						CASE WHEN "+xZBZ_+"TPDOC IN ('D','B') THEN A1_NREDUZ ELSE A2_NREDUZ END NREDUZ, "+LF
    cQuery += "						CASE WHEN "+xZBZ_+"TPDOC IN ('D','B') THEN A1_TEL ELSE A2_TEL END TEL, "+LF
    cQuery += "						CASE WHEN "+xZBZ_+"TPDOC IN ('D','B') THEN A1_CGC ELSE A2_CGC END CNPJ, "+LF
    cQuery += "						CASE WHEN "+xZBZ_+"TPDOC IN ('D','B') THEN A1_EMAIL ELSE A2_EMAIL END EMAIL "+LF

	cQuery += "					FROM " + RetSqlName(xZBZ) + " ZBZ " + LF
	//ZBT
	//cQuery += "						INNER JOIN " + RetSqlName(xZBT) + " ZBT " + LF
	cQuery += "						LEFT JOIN " + RetSqlName(xZBT) + " ZBT " + LF
	cQuery += "							ON " + xZBT_+"FILIAL = " + xZBZ_+"FILIAL " + LF  
	cQuery += "							AND " + xZBT_+"CHAVE  = " + xZBZ_+"CHAVE " 	+ LF
	cQuery += "							AND ZBT.D_E_L_E_T_ = ' ' " + LF
	//ZB5 
	cQuery += "						LEFT JOIN " + RetSqlName(xZB5) + " ZB5 "  + LF
	cQuery += "							ON  " + xZB5_+"CGC    = "+ xZBZ_+"CNPJ "  + LF
	cQuery += "							AND " + xZB5_+"PRODFO = "+ xZBT_+"PRODUT "+ LF
	cQuery += "							AND ZB5.D_E_L_E_T_ = ' ' " + LF
	//SB1
	cQuery += "						LEFT JOIN " + RetSqlName("SB1") + " SB1 " + LF
	cQuery += "							ON B1_COD = " + xZBT_+"PRODUT " + LF
	cQuery += "							AND SB1.D_E_L_E_T_ = ' ' " + LF
	//SA2
	cQuery += "						LEFT JOIN "+RetSqlName("SA2")+" SA2 " + LF
	cQuery += "							ON A2_CGC = "+xZBZ_+"CNPJ " + LF
	cQuery += "							AND SA2.D_E_L_E_T_ = ' ' " + LF
	//SA1
	cQuery += "						LEFT JOIN "+RetSqlName("SA1")+" SA1 " + LF
	cQuery += "							ON A1_CGC = "+xZBZ_+"CNPJ " + LF
	cQuery += "							AND SA1.D_E_L_E_T_ = ' ' " + LF
	
	//ZBE - eventos
	cQuery += "                    LEFT JOIN " +RetSqlName("ZBE")+ " ZBE " 		+ LF
	cQuery += "                        ON " + xZBZ+"_CHAVE = "+xZBE+"_CHAVE " 	+ LF
	cQuery += "                        AND "+ xZBE+"_TPEVE <> 'HXL069' "        + LF
	cQuery += "                        AND "+ xZBE+"_FILIAL = "+xZBZ+"_FILIAL " + LF
	cQuery += "                        AND ZBE.D_E_L_E_T_ <> '*'  
	//ZBZ
	cQuery += "						WHERE ZBZ.D_E_L_E_T_ = ' ' "+LF
	cQuery += "						AND ZBZ."+xZBZ_+"FILIAL BETWEEN '"+cFilDe+"' AND '"+cFilAte+"' " + LF
	
	If !lDemonstra		//FR - tratativa para licenças Demo
		cQuery += "						AND ZBZ."+xZBZ_+"DTNFE BETWEEN '"+cEmIni+"' AND '"+cEmFim+"' " + LF
	Else
		cQuery += "						AND ZBZ."+xZBZ_+"DTNFE BETWEEN '"+DtoS(Date()-30)+"' AND '"+DtoS(Date())+"' " + LF	
	Endif				//FR - tratativa para licenças Demo
	
	cQuery += "						AND ZBZ."+xZBZ_+"NOTA BETWEEN '"+cNFIni+"' AND '"+cNFFim+"' " + LF
	cQuery += "						AND ZBZ."+xZBZ_+"SERIE BETWEEN '"+cSerIni+"' AND '"+cSerFim+"' " + LF
	cQuery += "						AND ZBZ."+xZBZ_+"CODFOR BETWEEN '"+cForIni+"' AND '"+cForFim+"' " + LF
	cQuery += "						AND ZBZ."+xZBZ_+"LOJFOR BETWEEN '"+cLojaIni+"' AND '"+cLojaFim+"' " + LF
	
	If nImpCanc == 2		//"2 -> Imprime somente as notas não canceladas"
		cQuery += "						AND "+xZBZ_+"PRENF <> 'X' " + LF
	ElseIf nImpCanc == 3	//"3 -> Imprime somente as notas canceladas"
		cQuery += "						AND "+xZBZ_+"PRENF = 'X' " + LF 
	EndIf
	cQuery += "				) TMP " +LF
	//SA5
	cQuery += "			LEFT JOIN " + RetSqlName("SA5") + " SA5 " + LF
	cQuery += "				ON A5_FORNECE = CLIFOR " + LF
	cQuery += "				AND A5_LOJA = LOJA " + LF
	cQuery += "				AND A5_PRODUTO = B1_COD " + LF
	cQuery += "				AND SA5.D_E_L_E_T_ = ' ' " + LF
	//SD1
	cQuery += "			LEFT JOIN " + RetSqlName("SD1") + " SD1 " + LF
	cQuery += "				ON D1_FILIAL = "+ xZBZ_+"FILIAL " + LF
	cQuery += "				AND D1_DOC = "+ xZBZ_+"NOTA " + LF
	cQuery += "				AND D1_SERIE = "+ xZBZ_+"SERIE " + LF
	cQuery += "				AND D1_TIPO = "+ xZBZ_+"TPDOC " + LF
	cQuery += "				AND D1_ITEM = "+ xZBT_+"ITEM " + LF
	cQuery += "				AND D1_FORNECE = CLIFOR " + LF
	cQuery += "				AND D1_LOJA = LOJA " + LF
	cQuery += "				AND SD1.D_E_L_E_T_ = ' ' " + LF
	//SF1
	cQuery += "			LEFT JOIN " + RetSqlName("SF1") + " SF1 " + LF"
	cQuery += "				ON F1_FILIAL 	= D1_FILIAL " + LF
	cQuery += "				AND F1_DOC 		= D1_DOC " + LF
	cQuery += "				AND F1_SERIE 	= D1_SERIE " + LF
	cQuery += "				AND F1_TIPO 	= D1_TIPO " + LF
	cQuery += "				AND F1_FORNECE 	= D1_FORNECE " + LF
	cQuery += "				AND F1_LOJA 	= D1_LOJA " + LF
	
	If !Empty(cEspecie)
		cQuery += "				AND SF1.F1_ESPECIE IN ('"+cEspecie+"') "+LF
	EndIf

	cQuery += "             AND F1_CHVNFE = "+ xZBZ_+"CHAVE " + LF
	cQuery += "             AND SF1.D_E_L_E_T_ = ' ' " + LF

	cQuery += "			WHERE ZBTDEL = ' ' "+LF
	
	If lQuery
		If nAmarrac == 2
			cQuery += "			AND SD1.D1_VUNIT IS NOT NULL " + LF
		EndIf

		If nDNfXml <> 1
			cQuery += "			AND ("
			
			If nDNfXml == 2 .OR. nDNfXml == 5
				cQrAux += " SD1.D1_VUNIT <> "+xZBT_+"VUNIT " +LF 
				cQrAux += "				OR SD1.D1_TOTAL <> "+xZBT_+"TOTAL " +LF  		
			EndIf

			If nDNfXml == 3 .OR. nDNfXml == 5
				If !Empty(cQrAux)
					cQrAux += "				OR"
				EndIf
				cQrAux += " SD1.D1_QUANT <> "+xZBT_+"QUANT " +LF
			EndIf

			If nDNfXml == 4 .OR. nDNfXml == 5
				If !Empty(cQrAux)
					cQrAux += "				OR"
				EndIf
				cQrAux += " SD1.D1_BASEIPI <> "+xZBT_+"IPIBAS " + LF
				cQrAux += "				OR SD1.D1_VALIPI <> "+xZBT_+"IPIVAL " + LF
				cQrAux += "				OR SD1.D1_IPI <> "+xZBT_+"IPIALQ " + LF
				cQrAux += "				OR SD1.D1_BASEICM <> "+xZBT_+"ICMBAS " + LF
				cQrAux += "				OR SD1.D1_VALICM <> "+xZBT_+"ICMVAL " + LF
				cQrAux += "				OR SD1.D1_PICM <> "+xZBT_+"ICMALQ " + LF			
				cQrAux += "				OR SD1.D1_BASIMP6 <> "+xZBT_+"PISBAS " + LF			
				cQrAux += "				OR SD1.D1_VALIMP6 <> "+xZBT_+"PISVAL " + LF		
				cQrAux += "				OR SD1.D1_ALQPIS <> "+xZBT_+"PISALQ " + LF			
				cQrAux += "				OR SD1.D1_BASIMP5 <> "+xZBT_+"COFBAS " + LF			
				cQrAux += "				OR SD1.D1_VALIMP5 <> "+xZBT_+"COFVAL " + LF	
				cQrAux += "				OR SD1.D1_ALQCOF <> "+xZBT_+"COFALQ " + LF
			EndIf

			If nAmarrac == 1 						
				cQrAux += "				OR SD1.D1_VUNIT IS NULL " + LF	
			EndIf

			cQuery += cQrAux

			cQuery += "				) " + LF
		EndIf
	EndIf
    
	If nQuebra == 0
		cQuery += " ORDER BY " + xZBZ_+"FILIAL, "+ xZBZ_+"CNPJ, " + xZBZ_+"NOTA, " + xZBZ_+"SERIE, ZBTRECNO " + LF
	Elseif nQuebra == 1	.or. nQuebra == 7	//por modelo, ex.: NFE, CTE...
		cQuery += " ORDER BY MODELO, FILIAL , CLIFOR, LOJA, NOTA, SERIE, ITEM " + LF
	Elseif nQuebra == 2    //por status, ex: XML Importado, XML Cancelado...
		cQuery += " ORDER BY PRENF , COMBUS, TPDOWL, PROTC, FILIAL, CLIFOR, LOJA, NOTA, SERIE, ITEM "
	Elseif nQuebra == 3 .or. nQuebra == 8   //por valores x mês
		cQuery += " ORDER BY DTNFE, MODELO, FILIAL, CLIFOR, LOJA, NOTA, SERIE, ITEM "
	Elseif nQuebra == 4    //por eventos
		cQuery += " ORDER BY TPEVE, FILIAL, CLIFOR, LOJA, NOTA, SERIE, ITEM "
	Endif

EndIf

Memowrite("C:\TEMP\HFXMLR18.Sql", cQuery)

If Select("TRB") > 0
	dbSelectArea("TRB")
	dbCloseArea()
Endif

//+-----------------------
//| Cria uma view no banco
//+-----------------------
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TRB", .T., .F. )
dbSelectArea("TRB")

 //Contando os registros e voltando ao topo da tabela
Count To nTotReg

TRB->( dbGoTop() )

DbSelectArea(xZBZ)
DbSetOrder(6) 

//DbSelectArea("TRB") 

//DbGoTop() 

Return

//========================================================================//
// Programa  : HF18Erro   Autor  ³ Renan Oliveira  º Data ³  22/04/2020   //
//========================================================================//
// Descricao : Verifica tabelas ou campos do relatorio                    //
//========================================================================//
// Uso       : IMPORTA XML                                                //
//========================================================================//
Static Function HF18Erro(aTab,aCampos)

Local nX		:= 0
Local nY		:= 0
Local aErros	:= {"",""}

For nX := 1 to Len(aTab)
	If !ChkFile(aTab[nX])
		If Empty(aErros[1])
			aErros[1] := aTab[nX]
		Else
			aErros[1] += " / "+aTab[nX]
		EndIf
	Else
		dbSelectArea(aTab[nX])
	EndIf
Next nX

If Empty(aErros[1])
	For nX := 1 to Len(aCampos)
		dbSelectArea(aCampos[nX,1])
		For nY := 1 to Len(aCampos[nX,2])
			If FieldPos(aCampos[nX,2,nY]) == 0
				If Empty(aErros[2])
					aErros[2] := aCampos[nX,2,nY]
				Else
					aErros[2] += " / "+aCampos[nX,2,nY]
				EndIf
			EndIf
		Next nY
	Next nX
EndIf

Return(aErros)

//==============================================================//
//Função : fGetStatus
//Autoria: Flávia Rocha
//Data   : 20/01/2021
//Objetivo: Trazer o nome do status de acordo com o parâmetro 
//          passado pelo campo ZBZ_PRENF
//==============================================================//
Static Function fGetStatus(xPrenf,xCombus,xTpDowl,xProtc)
Local xStatus := ""

Do Case
	Case xPrenf == 'B' .AND. Empty(xCombus) .And. Empty(xTpDowl)			
		xStatus := 'XML Importado' 
		
	Case xPrenf == 'B' .AND. xCombus == 'S'			
		xStatus :='XML Imp.Combustivel' 
			
	Case xPrenf == 'B' .AND. xCombus == 'E'					
		xStatus :='XML Imp.Energia' 
	
	Case xPrenf == 'B' .AND.  xTpDowl == 'R'			
		xStatus :='XML Imp. Capa' 
			
	Case xPrenf == 'A' 		
		xStatus :='Aviso Recbto Carga' 
	
	Case xPrenf == 'S' 			
	    xStatus :='Pré-NF a Classificar' 
			    
	Case xPrenf == 'N' .AND. Empty(xCombus) 			
		xStatus :='Pré-NF Classificada' 
			 
	Case xPrenf == 'X' .AND. xProtc <> ''				
	    xStatus :='Xml Cancel.Emissor' 		
		    
	Case xPrenf == 'D' 										
		xStatus :='XML Denegado'
				
	Case xPrenf == 'F' 			
	    xStatus :='Falha Importação' 
						
	Case xPrenf == 'Z' 			
		xStatus :='XML Rejeitado' 	
			
	Case xPrenf == 'N' .AND. xCombus == 'S'		
		xStatus :='Pré-NF Class. Comb.' 
			
	Case xPrenf == 'N' .AND. xCombus == 'E'		   		
   		xStatus :='Pré-NF Class. Energia' 
 EndCase

Return(xStatus)
