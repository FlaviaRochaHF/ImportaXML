#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "Tbiconn.CH"
#INCLUDE "PRCONST.CH"

//====================================================================//
//Função: HFXMLGR2 - Análise Gráfica - Botão 'Mais gráficos'
//Autor : Henrique Tofanelli
//====================================================================//
//Alterações realizadas:
//FR - 10/12/2020 - Inclusão de novos campos na tela;
//                  Revisão geral das amarrações nas queries
//                  Alterada chamada da função HFXMLGR1
//                  para mostrar regua de processo antes de
//                  mostrar a tela dos gráficos.
//--------------------------------------------------------------------//
//FR - 14/01/2021 - Melhorias na estética da tela
//                  Solicitado por Rafael Lobitsky
//                  Alterada chamada da função HFXMLGR1
//--------------------------------------------------------------------//
//FR - 12/02/2021 - Revisões na estética da tela
//                  Solicitado por Rafael Lobitsky
//--------------------------------------------------------------------//
//FR - 19/02/2021 - Revisões nas queries que buscam os valores
//                  dos XMLs
//====================================================================//
User Function HFXMLGR2(_Dataini,_DataFim,xFornec,xLoj,xFilDe,xFilAte)
	Local oDlg   := Nil
	Local oExpl  := Nil
	//Local oPanel := Nil
	Local aPanels:= {}
	
	Local nLiIni := 0 			//FR - 14/01/2021
	Local nCoIni := 0        	//FR - 14/01/2021
	Local nLiFim := 0        	//FR - 14/01/2021
	Local nCoFim := 0        	//FR - 14/01/2021
	
	Private oDataDe,oDataAte,oDescUser,oFornec,oLoj,oFilDe,oFilAte
	Private oChart,oChart2
	Private dDataDe  := _Dataini 							//FR - 10/12/2020
	Private dDataAte := _DataFim 							//FR - 10/12/2020
	Private cFornec  := xFornec								//FR - 10/12/2020
	Private cLoj     := xLoj								//FR - 10/12/2020
	Private cFilDe   := xFilDe								//FR - 10/12/2020
	Private cFilAte  := xFilAte								//FR - 10/12/2020
	Private oGetDados     									//FR - 10/12/2020

	Private oGetDados11										//FR - 10/12/2020
	Private aHeader11:= {}									//FR - 10/12/2020
	Private noBrw11  := 0       							//FR - 10/12/2020

	Private oGetDados12										//FR - 10/12/2020
	Private aHeader12:= {}									//FR - 10/12/2020
	Private noBrw12  := 0       							//FR - 10/12/2020

	Private aSize   := {} 									//FR - 14/01/2021
	Private aInfo   := {}									//FR - 14/01/2021
	Private aPos    := {}									//FR - 14/01/2021

	//FR - 19/02/2021
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
	//FR - 19/02/2021
	Static cUserLog  :=  RetCodUsr()
	Static cDescUser := UsrFullName ( cUserLog )
	Static _NomeBotao:= ""
	Static c_Eol  := CHR(13)+CHR(10)

	_NomeBotao := "Analisar"+c_Eol+"Período"

	CALCTELA()

	/*
	Medidas do aSize:
	aSize[1] =     0
	aSize[2] =    30
	aSize[3] =   762,4
	aSize[4] =   356,8
	aSize[5] = 1.524,8
	aSize[6] =   713,6
	aSize[7] =     0
	aSize[8] =     5
	*/

	nLiIni := aInfo[1] + 10 //0+10=10 		//FR - 14/01/2021
	nCoIni := nLiIni		//10        	//FR - 14/01/2021
	nLiFim := aInfo[4]      //446		  	//FR - 14/01/2021
	nCoFim := aInfo[3]-200  //953-200=753	//FR - 14/01/2021

	//Instancia Objeto
	//oExpl := MsExplorer():New("Titulo da MSExplorer",10,10,400,700,oDlg,/*lToolBar*/,/*lAddressBar*/,/*lDefBar*/,/*oTreeFont*/,/*cBitmap*/,/*nBmpWidth*/,/*oParent*/)
	oExpl := MsExplorer():New("Titulo da MSExplorer",nLiIni,nCoIni,nLiFim,nCoFim,oDlg,/*lToolBar*/,/*lAddressBar*/,/*lDefBar*/,/*oTreeFont*/,/*cBitmap*/,/*nBmpWidth*/,/*oParent*/)

	//Cria EnchoiceButtons
	//oExpl(): DefaultBar ( )

	//oExpl:AddDefButton("CLIPS"	,"ToolTip 01"	,{|| msgInfo("Botao ZeroUm")}		,/*cDefaultAct*/	,/*bWhen*/,/*nWidth*/,"Botao Zero Um - 01")  //FR - 10/12/2020 - Não precisa deste botão
	//oExpl:AddDefButton("CLIENTE"	,"ToolTip 02"	,{|| msgInfo("Botao ZeroDois")}		,/*cDefaultAct*/	,/*bWhen*/,/*nWidth*/,"Botao Zero Um - 02")
	//oExpl:AddDefButton("CHAT"		,"ToolTip 03"	,{|| msgInfo("Botao ZeroTres")}		,/*cDefaultAct*/	,/*bWhen*/,/*nWidth*/,"Botao Zero Um - 03")
	//oExpl:AddDefButton("COMSOM"	,"ToolTip 04"	,{|| msgInfo("Botao ZeroQuatro")}	,/*cDefaultAct*/	,/*bWhen*/,/*nWidth*/,"Botao Zero Um - 04")
	//oExpl:AddDefButton("CARGA"	,"ToolTip 04"	,{|| FSBrwEnd()}	,/*cDefaultAct*/	,/*bWhen*/,/*nWidth*/,"Botao Zero Um - 05")//Cria um item da Arvore
	//oExpl:AddDefButton("FINAL"	,"ToolTip 04"	,{|| oExpl:DeActivate()}	,/*cDefaultAct*/	,/*bWhen*/,/*nWidth*/,"Botao Zero Um - 05")//Cria um item da Arvore
	oExpl:AddDefButton("FINAL"		,"Voltar"	,{|| oExpl:DeActivate()}	,/*cDefaultAct*/	,/*bWhen*/,/*nWidth*/,"Para Voltar à Janela Anterior")	//FR - 10/12/2020

	//FR - 10/12/2020
	//Árvore Gestão XML
	aAdd(aPanels,    oExpl:AddTree("Gestão XML","BR_LARANJA"	,"BR_VERDE","#1000",.T.))	//1-Gestão XML: item cabeça da árvore
	_fGera01(oExpl:GetPanel(aPanels[1]) , aInfo)  //mostra os campos de data inicial/final, fornecedor/loja, filial de/até, usuário logado //FR - 14/01/2021

	//Sub-itens da árvore GestãoXML:
	aAdd(aPanels,    oExpl:AddItem("Graf.1","BR_ROXO","#1100",.T.))           				//2-sub-item : Qtde x Valor (1 x 1000 ) x Tipos de Notas -> Mostra qtde de notas e valor
	_fGera02(oExpl:GetPanel(aPanels[2]) , aPos)  //mostra gráfico

	aAdd(aPanels,    oExpl:AddItem("Graf.2","BR_ROXO","#1200",.T.))							//3-sub-item : Qtde x Status XML -> Mostra a qtde de notas por status
	_fGera03(oExpl:GetPanel(aPanels[3]) , aPos)
	aAdd(aPanels,    oExpl:AddItem("Graf.3","BR_ROXO","#1300",.T.))				  			//4-sub-item : Valores por período (valores por meses)
	_fGera04(oExpl:GetPanel(aPanels[4]))

	//Sub-Árvore: Eventos
	aAdd(aPanels,    oExpl:AddTree("Eventos","BR_PRETO"	,"BR_BRANCO","#1400",.T.))      	//5-Eventos: item cabeça da árvore
	aAdd(aPanels,    oExpl:AddItem("Graf.4" ,"BR_ROXO","#1410",.T.))               			//6-sub-item Gráfico Qtde x Eventos
	oExpl:EndTree() //Fecha Sub-item

	//Sub-Árvore Impostos
	//renumerado os painéis devido a retirada do "Cancel.2"
	aAdd(aPanels,    oExpl:AddTree("Impostos","BR_LARANJA"	,"BR_MARROM","#2000",.T.))   //7 Impostos: item cabeça da árvore
	aAdd(aPanels,    oExpl:AddItem("Graf.5"  ,"BR_ROXO"     ,"#2100",.T.))     	   		//8 sub-item: Valor x Impostos XML
	aAdd(aPanels,    oExpl:AddItem("Graf.6"  ,"BR_ROXO"     ,"#2200",.T.))         		//9 sub-item: Valor de Impostos x XML x Entrada
	oExpl:EndTree() //Fecha Sub-Árvore

	//Sub-Árvore Tabelas
	aAdd(aPanels,    oExpl:AddTree("Tabelas","BR_AZUL"	,"BR_AMARELO","#3000",.T.))   	//10-Tabelas: item cabeça da árvore
	aAdd(aPanels,    oExpl:AddItem("Cena.1" ,"BR_ROXO","#3100",.T.))                 	//11-sub-item: Cena.1 sub-item novo pedido por Rafael - Xml x tipo x Qtd x Valores por mês
	aAdd(aPanels,    oExpl:AddItem("Cena.2" ,"BR_ROXO","#3200",.T.))               	   	//12-sub-item: Cena.2 sub-item novo pedido por Rafael - Xml x Qtd x Valores por mês
	oExpl:EndTree() //Fecha Sub-Árvore

	nLi := nLiIni + 40 //10+40=50
	@nLi,50 SAY "Opção: Eventos:"	PIXEL SIZE 150,25 OF oExpl:GetPanel(aPanels[5])

	nLi := nLi + 20  //50+20 = 70
	@nLi,50 SAY "Gráfico: Quantidade Notas Fiscais x Eventos"	PIXEL SIZE 150,25 OF oExpl:GetPanel(aPanels[5])
	_fGera06(oExpl:GetPanel(aPanels[6]))                      						//Gráfico Qtde x Eventos

	nLi := nLiIni + 40 //10+40=50
	@nLi,50 SAY "Opção: Impostos"	PIXEL SIZE 150,25 OF oExpl:GetPanel(aPanels[7])
	_fGera08(oExpl:GetPanel(aPanels[8]))             								//Valor x Impostos XML
	_fGera09(oExpl:GetPanel(aPanels[9]))                                        	//Valor de Impostos x XML x Entrada

	@nLi,50 SAY "Opção: Tabelas"	PIXEL SIZE 150,25 OF oExpl:GetPanel(aPanels[10])
	_fGera11(oExpl:GetPanel(aPanels[11]))   //chama a getdados
	_fGera12(oExpl:GetPanel(aPanels[12]))   //chama a getdados

	oExpl:EndTree() //Fecha árvore total    //FR - 10/12/2020 - coloquei aqui o fechamento geral da árvore "Gestão XML"
	//FR - 10/12/2020


	//Exibe a MsExplorer
	oExpl:Activate(.T.)
Return

//U_FSBrwEnd()   // fechar browse

//FR - 10/12/2020 - função comentada por não estar em uso
/*
***************************************************************
Static Function FSBrwEnd()
***************************************************************
	oExpl:DeActivate()

	//     Local oObjbrw := GetObjBrow()

	//    oExpl:oWnd:End()

	//  oObjbrw:End()                     // mudei aqui !!!

	Return Nil
*/

//***************************************************************
Static Function _fGera01(oPanel, aInfo)
	//***************************************************************
	//FR - 10/12/2020
	Local nLiIni:= 0
	Local nCo1  := 0
	Local nCo2  := 0
	Local nCo3  := 0
	Local nCo4  := 0
	Local nCo5  := 0
	Local nCo6  := 0
	Local nCo7  := 0
	Local nCo8  := 0

	/*
	Medidas do aSize:
	aSize[1] =     0
	aSize[2] =    30
	aSize[3] =   762,4
	aSize[4] =   356,8
	aSize[5] = 1.524,8
	aSize[6] =   713,6
	aSize[7] =     0
	aSize[8] =     5

	aInfo := { aSize[1], aSize[2], aSize[3], aSize[4], 3, 3 }
	// aSize[1] LI
	// aSize[2] CI
	// aSize[3] LF
	// aSize[4] CF
	// 3        separacao horizontal
	// 3        separacao vertical
	*/

	//FR - 14/01/2021
	nLiIni  := 0

	nCo1 := aInfo[1] + 5 //0+5=5
	nCo2 := aInfo[2] * 2 //30*2  = 60
	nCo3 := nCo2 + 60	 //60+60 =120
	nCo4 := nCo3 + 50	 //120+50=170
	nCo5 := nCo4 + 60    //170+60=230
	nCo6 := nCo5 + 30	 //230+30=260
	nCo7 := nCo6 + 30	 //260+30=290
	nCo8 := nCo7 + 30    //290+30=320

	nLiIni := aInfo[2]-10  		//30-10=20
	//FR - 14/01/2021

	//FR - 10/12/2020
	@nLiIni,50 SAY "Data Analytics GestãoXML - HF Consultoria"	PIXEL SIZE 250,50 OF oPanel

	nLiIni := nLiIni+20				//40		//FR - 14/01/2021

	@nLiIni,50 SAY "Opções de Filtros / Parâmetros"	PIXEL SIZE 150,25 OF oPanel 	//FR - 10/12/2020

	nLiIni := nLiIni +20 			//60   		//FR - 14/01/2021
	oDataDe   := TGet():New( nLiIni, nCo1,bSetGet(dDataDe) ,oPanel,050,010,'@D',{||  },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.   ,,dtos(dDataDe) ,,,,,,,"Data Inicial",1 )
	oDataAte  := TGet():New( nLiIni, nCo2,bSetGet(dDataAte),oPanel,050,010,'@D',{||  },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.   ,,dtos(dDataAte),,,,,,,"Data Final",1 )

	oFornec  := TGet():New( nLiIni, nCo3,bSetGet(cFornec) ,oPanel,050,010,'@X',{||  },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.   ,"SA2",cFornec ,,,,,,,"Fornecedor",1 )	//FR - 10/12/2020
	oLoj     := TGet():New( nLiIni, nCo4,bSetGet(cLoj)    ,oPanel,050,010,'@X',{||  },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.   ,     ,cLoj    ,,,,,,,"Loja",1 )		//FR - 10/12/2020

	oFilDe   := TGet():New( nLiIni, nCo5,bSetGet(cFilDe)  ,oPanel,050,010,'@X',{||  },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.   ,"SM0",cFilDe ,,,,,,,"Filial De",1 )	//FR - 10/12/2020
	oFilAte  := TGet():New( nLiIni, nCo7,bSetGet(cFilAte) ,oPanel,050,010,'@X',{||  },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.   ,"SM0",cFilAte,,,,,,,"Filial Até",1 )		//FR - 10/12/2020

	oDescUser := TGet():New( nLiIni, nCo8+30,{|u| if(PCount()>0,cDescUser:=u,cDescUser)}   ,oPanel,180, 010,Nil,{||  },0,,,.F.,,.T.,,.F.,{|| .F.},.F.,.F.,,.F.,.F.,"",cDescUser  ,,,,,,,"Usuário",1 )
	//FR - 10/12/2020

Return Nil

//==============================================================//
//Gráfico 1: Quantidade x Valor (1 x 1000) x Tipos de Notas
//==============================================================//
//***************************************************************
Static Function _fGera02(oPanel, aPos)
	//***************************************************************
	Local _QtdNFE   := 0
	Local _ValNFE   := 0
	Local _QtdCTE   := 0
	Local _ValCTE   := 0
	Local _QtdNFCE  := 0
	Local _ValNFCE  := 0
	Local _QtdNFSE  := 0
	Local _ValNFSE  := 0
	Local _QtdCTEOS := 0
	Local _ValCTEOS := 0

	//FR - 14/01/2021
	Local nLiIni    := 0
	Local nCoIni    := 0
	Local nLiFim    := 0
	Local nCoFim    := 0
	Local _oPanel
	Local lLowered  := .F.
	Local lRaised   := .F. //.T. mostra borda do painel
	//FR - 14/01/2021


	//FR - 10/12/2020

	cQuery := " Select DISTINCT "+xZBZ+"_MODELO AS MODELO, " 	+ CHR(13) + CHR(10)
	cQuery += " Count("+xZBZ+"_MODELO) AS QUANT, " 				+ CHR(13) + CHR(10)
	cQuery += " ROUND( (Sum("+xZBZ+"_VLBRUT)/1000),2) AS VALTOT "   		+ CHR(13) + CHR(10)	//Usar o valor bruto
	cQuery += " FROM " + RETSQLNAME(xZBZ) + " "+xZBZ+" "		+ CHR(13) + CHR(10)
	cQuery += " WHERE "+xZBZ+".D_E_L_E_T_ <> '*' " 				+ CHR(13) + CHR(10)
	cQuery += " AND "+xZBZ+"_MODELO <> '' " 					+ CHR(13) + CHR(10)
	//cQuery += " AND "+xZBZ+"_DTNFE BETWEEN '"+DTOS(dDataDe)+"' AND '"+DTOS(dDataAte)+"' "	+ CHR(13) + CHR(10)
	cQuery += " AND "+xZBZ+"_DTNFE BETWEEN '"+DTOS(dDataDe)+"' AND '"+DTOS(dDataAte)+"' "	+ CHR(13) + CHR(10)		//FR - 14/01/2021 - data emissão da nf

	If !Empty(cFornec) .and. !Empty(cLoj)
		cQuery += " AND "+xZBZ+"_CODFOR = '" + Alltrim(cFornec) + "' "	+ CHR(13) + CHR(10)
		cQuery += " AND "+xZBZ+"_LOJFOR = '" + Alltrim(cLoj) + "' "		+ CHR(13) + CHR(10)
	Endif

	If !Empty(cFilAte)
		cQuery += " AND "+xZBZ+"_FILIAL BETWEEN '" + Alltrim(cFilDe) + "' AND '"+ Alltrim(cFilAte) + "' "	+ CHR(13) + CHR(10)
	Endif
	cQuery += " GROUP BY "+xZBZ+"_MODELO "+ CHR(13) + CHR(10)
	cQuery += " ORDER BY "+xZBZ+"_MODELO "+ CHR(13) + CHR(10)

	/*
	//FR - 19/02/2021 - alterar query para não pegar o valor do ZBZ_VLBRUT , mas sim, direto de um parse do xml pois há registros na ZBZ em que o campo de valor está zerado
	cQuery := " Select "+xZBZ+"_MODELO AS MODELO, " 			+ CHR(13) + CHR(10)
	cQuery += " ZBZ.R_E_C_N_O_ AS RECZBZ " 						+ CHR(13) + CHR(10)
	cQuery += " FROM " + RETSQLNAME(xZBZ) + " ZBZ "				+ CHR(13) + CHR(10)
	cQuery += " WHERE "+xZBZ+".D_E_L_E_T_ <> '*' " 				+ CHR(13) + CHR(10)
	cQuery += " AND "+xZBZ+"_MODELO <> '' " 					+ CHR(13) + CHR(10)
	cQuery += " AND "+xZBZ+"_DTNFE BETWEEN '"+DTOS(dDataDe)+"' AND '"+DTOS(dDataAte)+"' "	+ CHR(13) + CHR(10)		//FR - 14/01/2021 - data emissão da nf

	If !Empty(cFornec) .and. !Empty(cLoj)
		cQuery += " AND "+xZBZ+"_CODFOR = '" + Alltrim(cFornec) + "' "	+ CHR(13) + CHR(10)
		cQuery += " AND "+xZBZ+"_LOJFOR = '" + Alltrim(cLoj)    + "' "		+ CHR(13) + CHR(10)
	Endif

	If !Empty(cFilAte)
		cQuery += " AND "+xZBZ+"_FILIAL BETWEEN '" + Alltrim(cFilDe) + "' AND '"+ Alltrim(cFilAte) + "' "	+ CHR(13) + CHR(10)
	Endif
	cQuery += " ORDER BY "+xZBZ+"_MODELO "+ CHR(13) + CHR(10)
	*/
	MemoWrite("C:\TEMP\_fGera02.sql" , cQuery )
	cQuery := ChangeQuery(cQuery)
	//FR - 10/12/2020

	If ( SELECT("TRBAC2") ) > 0
		dbSelectArea("TRBAC2")
		TRBAC2->(dbCloseArea())
	EndIf

	TcQuery cQuery Alias "TRBAC2" New

	TRBAC2->(dbGoTop())

	_QtdNFE := _QtdCTE := _QtdNFCE := _QtdNFSE := _QtdCTEOS := 0
	_ValNFE := _ValCTE := _ValNFCE := _ValNFSE := _ValCTEOS := 0

	While TRBAC2->( !EOF() )

		Do Case
			Case TRBAC2->MODELO == "55"
				_QtdNFE += TRBAC2->QUANT
				_ValNFE += Round(TRBAC2->VALTOT,2)

			Case TRBAC2->MODELO == "57"
				_QtdCTE += TRBAC2->QUANT
				_ValCTE += Round(TRBAC2->VALTOT,2)

			Case TRBAC2->MODELO == "65"
				_QtdNFCE += TRBAC2->QUANT
				_ValNFCE += Round(TRBAC2->VALTOT,2)

			Case TRBAC2->MODELO == "RP"
				_QtdNFSE += TRBAC2->QUANT
				_ValNFSE += Round(TRBAC2->VALTOT,2)

			Case TRBAC2->MODELO == "67"
				_QtdCTEOS += TRBAC2->QUANT
				_ValCTEOS += Round(TRBAC2->VALTOT,2)

		EndCase

		TRBAC2->(dbSkip())

	Enddo
	/*
	//FR - 19/02/2021 - mudança no laço de repetição para ler o xml
	While TRBAC2->( !EOF() )

		nValor := 0

		DbSelectArea(xZBZ)						//acessa a ZBZ
		(xZBZ)->( Dbgoto(TRBAC2->RECZBZ) )		//posiciona no registro
		cXml   := ""
		cXml   := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML")))	//para pegar o conteúdo do XML
		nValor := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"VLBRUT")))

		//se o campo da ZBZ estiver vazio, faz o parse no xml para obter o valor
		If nValor == 0
			nValor := U_fParseXML( TRBAC2->MODELO, cXml ) 		//função faz o parse e retorna o valor bruto do xml
		Endif

		Do Case
			Case TRBAC2->MODELO == "55"
			_QtdNFE++
			_ValNFE+= nValor

			Case TRBAC2->MODELO == "57"
			_QtdCTE++
			_ValCTE+= nValor

			Case TRBAC2->MODELO == "65"
			_QtdNFCE++
			_ValNFCE+= nValor

			Case TRBAC2->MODELO == "RP"
			_QtdNFSE++
			_ValNFSE+= nValor

			Case TRBAC2->MODELO == "67"
			_QtdCTEOS++
			_ValCTEOS+= nValor

		EndCase

		TRBAC2->(dbSkip())

	Enddo
	*/
	_ValNFE  := _ValNFE / 1000
	_ValCTE  := _ValCTE / 1000
	_ValNFCE := _ValNFCE/1000
	_ValNFSE := _ValNFSE/1000
	_ValCTEOS:= _ValCTEOS/1000

	//FR - 14/01/2021
	//---------------------------------------------------------//
	//painel a parte, para inserção do botão "exporta excel" :
	//---------------------------------------------------------//
	nLiIni := aPos[1][2]  	//3
	nCoIni := aPos[1][2]    //3
	_oPanel:= TPanel():New(nLiIni,nCoIni, , oPanel, , , , , , 0,50,lLowered,lRaised)
	_oPanel:Align := CONTROL_ALIGN_TOP
	TButton():New( nLiIni+10, nCoIni+10, "Exporta Excel",_oPanel,{|| Processa({|| fExpEXCL(.T.,1) }, "Aguarde...", "Exportando Graf.1...",.F.) },85,15,,,.F.,.T.,.F.,,.F.,,,.F. )   //nLiIni + 10 = 13, nCoIni + 10 = 13

	oChart03 := FWChartFactory():New() //New(0,0,50,50)    	//FR - 14/01/2021
	oChart03:SetOwner(oPanel)

	//oChart03:SetXAxis( {"NFE", "CTE", "NFCE", "NFSE", "CTEOS"} )  //FR - 10/12/2020
	oChart03:SetXAxis( {} )  //FR - 10/12/2020
	If _QtdNFE > 0
		Aadd(oChart03:AXAXIS, "NFE: " + Alltrim(Str(_QtdNFE)) + " / " + Transform(_ValNFE , "@E 9,999,999,999.99") )
	Endif

	If _QtdCTE > 0
		Aadd(oChart03:AXAXIS, "CTE: " + Alltrim(Str(_QtdCTE)) + " / " + Transform(_ValCTE , "@E 9,999,999,999.99"))
	Endif

	If _QtdNFCE > 0
		Aadd(oChart03:AXAXIS, "NFCE: " + Alltrim(Str(_QtdNFCE)) + " / " + Transform(_ValNFCE , "@E 9,999,999,999.99"))
	Endif

	If _QtdNFSE > 0
		Aadd(oChart03:AXAXIS, "NFSE: " + Alltrim(Str(_QtdNFSE)) + " / " + Transform(_ValNFSE , "@E 9,999,999,999.99"))
	Endif

	If _QtdCTEOS > 0
		Aadd(oChart03:AXAXIS, "CTEOS: " + Alltrim(Str(_QtdCTEOS)) + " / " + Transform(_ValCTEOS , "@E 9,999,999,999.99"))
	Endif

	oChart03:addSerie('Quant', {  _QtdNFE, _QtdCTE, _QtdNFCE, _QtdNFSE, _QtdCTEOS  } )     	//FR - 10/12/2020
	//----------------------------------------------
	//Picture
	//----------------------------------------------
	oChart03:setPicture("@E 999999999")

	oChart03:addSerie('Valor', {  _ValNFE, _ValCTE, _ValNFCE, _ValNFSE, _ValCTEOS  } )		//FR - 10/12/2020

	//----------------------------------------------
	//Picture
	//----------------------------------------------
	oChart03:setPicture("@E 999,999,999.99")
	//----------------------------------------------
	//Mascara
	//----------------------------------------------
	//oChart03:setMask("R$ *@*")
	//oChart03:addSerie('QtdxValor', {  {_QtdNFE,_ValNFE}, {_QtdCTE,_ValCTE}, {_QtdNFCE,_ValNFCE}, {_QtdNFSE,_ValNFSE}, {_QtdCTEOS,_ValCTEOS}  } )


	//Define as cores que serão utilizadas no gráfico

	//aAdd(aRand, {"084,120,164", "007,013,017"})
	//aAdd(aRand, {"171,225,108", "017,019,010"})
	//aAdd(aRand, {"207,136,077", "020,020,006"})
	//aAdd(aRand, {"166,085,082", "017,007,007"})
	//aAdd(aRand, {"130,130,130", "008,008,008"})

	//Seta as cores utilizadas
	//oChart:oFWChartColor:aRandom := aRand
	//oChart03:oFWChartColor:SetColor("Random")
	oChart03:SetLegend(CONTROL_ALIGN_LEFT)
	oChart03:SetTitle("Quantidade x Valor(1 x 1000) x Tipos de Notas", CONTROL_ALIGN_CENTER) //"Oportunidades por fase"
	//oChart:setLegend( CONTROL_ALIGN_LEFT )
	oChart03:SetAlignSerieLabel(CONTROL_ALIGN_RIGHT)

	oChart03:EnableMenu(.f.)

	//Define o tipo do gráfico
	oChart03:SetChartDefault(COLUMNCHART)
	//oChart03:SetChartDefault(NEWLINECHART)
	//-----------------------------------------
	// Opções disponiveis
	// RADARCHART
	// FUNNELCHART
	// COLUMNCHART
	// NEWPIECHART
	// NEWLINECHART
	//-----------------------------------------

	//FR - 14/01/2021
	nLiFim := oChart03:OOWNER:NBOTTOM  //853 - recebe o limite de linha final do gráfico
	nLiFim := nLiFim - 20           //703

	nCoFim := oChart03:OOWNER:NRIGHT   //1696
	nCoFim := nCoFim - 30              //1646

	oChart03:OOWNER:NBOTTOM := nLiFim  //703  - altura
	oChart03:OOWNER:NRIGHT  := nCoFim  //1646 - largura

	//nLiFim := oPanel:NBOTTOM

	oChart03:Activate()
	//FR - 14/01/2021


Return Nil

//==============================================================//
//Gráfico 2: Quantidade x Status XML
//==============================================================//
//***************************************************************
Static Function _fGera03(oPanel , aPos)
	//***************************************************************

	Local aOrdem := {}
	Local fr     := 0
	//FR - 14/01/2021
	Local nLiIni := 0
	Local nCoIni := 0
	Local nLiFim := 0
	Local nCoFim := 0
	Local _oPanel
	Local lLowered  := .F.
	Local lRaised   := .F. //.T. mostra borda do painel
	//FR - 14/01/2021

	nCoIni := aPos[1][2]   	//3 //FR - 14/01/2021

	//oChart02 := FWChartFactory():New(0,0,50,50)
	oChart02 := FWChartFactory():New()
	oChart02:SetOwner(oPanel)

	//Define o tipo do gráfico
	oChart02:SetChartDefault(COLUMNCHART)
	//-----------------------------------------
	// Opções disponiveis
	// RADARCHART
	// FUNNELCHART
	// COLUMNCHART
	// NEWPIECHART
	// NEWLINECHART
	//-----------------------------------------
	//FR - 10/12/2020
	cQuery := " Select Distinct "+xZBZ+"_PRENF AS PRENF , " 	+ CHR(13) + CHR(10)
	cQuery += " "+xZBZ+"_COMBUS AS COMBUS, "					+ CHR(13) + CHR(10)
	//cQuery += "" +xZBZ+"_TPDOWL AS TPDOWL, " 					+ CHR(13) + CHR(10)
	cQuery += " Case When " + xZBZ+"_TPDOWL <> '' AND "			+ CHR(13) + CHR(10)
	cQuery += "" + xZBZ+"_PRENF = 'X' THEN ' '    ELSE "		+ CHR(13) + CHR(10)
	cQuery += "" + xZBZ+"_TPDOWL END TPDOWL, "					+ CHR(13) + CHR(10)

	//cQuery += " "+xZBZ+"_PROTC  AS PROTC,  "					+ CHR(13) + CHR(10)    //FR - 14/01/2021
	cQuery += " COUNT(*) AS QUANT " 							+ CHR(13) + CHR(10)

	//FR - 14/01/2021 - Query para obter a qtde dos XMLs tipo "Capa"
	cQuery += " ,( Select COUNT(*) FROM " + RetSqlName(xZBZ)   + ""		+ CHR(13) + CHR(10)
	cQuery += "  ZBZR WHERE ZBZR."+xZBZ+"_TPDOWL = 'R' "        		+ CHR(13) + CHR(10)
	cQuery += "  AND ZBZR."+xZBZ+"_PRENF = 'B' "						+ CHR(13) + CHR(10)
	cQuery += "  AND ZBZR.D_E_L_E_T_ <> '*' "				   			+ CHR(13) + CHR(10)
	cQuery += "  AND ZBZR."+xZBZ+"_DTNFE BETWEEN '"					+ CHR(13) + CHR(10)
	cQuery += " "+DTOS(dDataDe)+"' AND '"+DTOS(dDataAte)+ "' "          + CHR(13) + CHR(10)

	If !Empty(cFornec) .and. !Empty(cLoj)
		cQuery += " AND ZBZR."+xZBZ+"_CODFOR = '" + Alltrim(cFornec) + "' "	+ CHR(13) + CHR(10)
		cQuery += " AND ZBZR."+xZBZ+"_LOJFOR = '" + Alltrim(cLoj) + "' "		+ CHR(13) + CHR(10)
	Endif

	If !Empty(cFilAte)
		cQuery += " AND ZBZR."+xZBZ+"_FILIAL BETWEEN '" + Alltrim(cFilDe) + "' AND '"+ Alltrim(cFilAte) + "' "	+ CHR(13) + CHR(10)
	Endif
	cQuery += " ) TPDOWLR " + CHR(13) + CHR(10)  //count específico para os XMLs importados Capa, pois se colocassemos na query principal, geraria duplicidade nos resultados
	//FR - 14/01/2021 - Fim Query para obter a qtde dos XMLs tipo "Capa"

	cQuery += " From " + RETSQLNAME(xZBZ) + " "+xZBZ+" "		+ CHR(13) + CHR(10)
	cQuery += " WHERE "+xZBZ+".D_E_L_E_T_ <> '*' "				+ CHR(13) + CHR(10)
	cQuery += " AND "+xZBZ+"_MODELO <> '' "						+ CHR(13) + CHR(10)
	cQuery += " AND "+xZBZ+"_DTNFE BETWEEN '"+DTOS(dDataDe)+"' AND '"+DTOS(dDataAte)+"' "+ CHR(13) + CHR(10) 	//FR - 14/01/2021 - data emissão da nf

	If !Empty(cFornec) .and. !Empty(cLoj)
		cQuery += " AND "+xZBZ+"_CODFOR = '" + Alltrim(cFornec) + "' "	+ CHR(13) + CHR(10)
		cQuery += " AND "+xZBZ+"_LOJFOR = '" + Alltrim(cLoj) + "' "		+ CHR(13) + CHR(10)
	Endif

	If !Empty(cFilAte)
		cQuery += " AND "+xZBZ+"_FILIAL BETWEEN '" + Alltrim(cFilDe) + "' AND '"+ Alltrim(cFilAte) + "' "	+ CHR(13) + CHR(10)
	Endif

	cQuery += " GROUP BY "+xZBZ+"_PRENF , "+xZBZ+"_COMBUS "  //, "+xZBZ+"_TPDOWL, "+xZBZ+"_PROTC "	+ CHR(13) + CHR(10)  //FR - 14/01/2021 - estava duplicando alguns resultados devido ao PROTC ter preenchimento em alguns casos e outros estar em branco
	cQuery += " ,Case When ZBZ_TPDOWL <> '' AND "+xZBZ+"_PRENF = 'X' THEN ' '    ELSE "+xZBZ+"_TPDOWL END " + CHR(13) + CHR(10)

	cQuery += " ORDER BY "+xZBZ+"_PRENF "

	MemoWrite("C:\TEMP\_fGera03.sql" , cQuery)
	cQuery := ChangeQuery(cQuery)
	//FR - 10/12/2020

	If ( SELECT("TRBAC2") ) > 0
		dbSelectArea("TRBAC2")
		TRBAC2->(dbCloseArea())
	EndIf

	TcQuery cQuery Alias "TRBAC2" New

	TRBAC2->(dbGoTop())

	//	oChart:addSerie( "NFE" , 0 )
	//	oChart:addSerie( "CTE" ,  0 )
	//	oChart:addSerie( "NFCE" , 0 )
	//	oChart:addSerie( "NFSE" , 0 )
	//	oChart:addSerie( "CTEOS" , 0 )

	nQuant := 0

	While TRBAC2->( !EOF() )

		//FR - 10/12/2020 - Rafael pediu para mudar a ordem:
		//Ordem: xml importado, depois  aviso de recebimento de carga, pre-nota ,  pre-nota classificada, xml cancelada, xml denegada, xml falha na importação
		//FR - 10/12/2020 - adiciono antes ao array "aOrdem" para garantir a ordem no gráfico
		nQuant := TRBAC2->QUANT

		Do Case
			Case TRBAC2->PRENF == 'B' .AND.  ( Empty(TRBAC2->COMBUS) .AND. TRBAC2->TPDOWLR == 0 )
				//Aadd(aOrdem , { 1 , 'XML Importado (' + Alltrim(Str(TRBAC2->QUANT)) + ')', TRBAC2->QUANT } )
				Aadd(aOrdem , { 1 , 'XML Importado (' + Alltrim(Str(nQuant)) + ')', nQuant } )

			Case TRBAC2->PRENF == 'A' //.AND. TRBAC2->PROTC == 0
				Aadd(aOrdem , { 2 , 'Aviso Recbto Carga (' + Alltrim(Str(nQuant)) + ')' , nQuant } )

			Case TRBAC2->PRENF == 'S'
				Aadd(aOrdem , { 3 , 'Pré-NF a Classificar (' + Alltrim(Str(nQuant)) + ')', nQuant } )

			Case TRBAC2->PRENF == 'N' .AND. empty(TRBAC2->COMBUS) //TRBAC2->PROTC == 0
				Aadd(aOrdem , { 4 , 'Pré-NF Classificada (' + Alltrim(Str(nQuant)) + ')', nQuant } )

			Case TRBAC2->PRENF == 'X' //.AND. TRBAC2->PROTC <> ''			//FR - 10/12/2020
				Aadd(aOrdem , { 5 , 'Xml Cancel.Emissor (' + Alltrim(Str(nQuant)) + ')', nQuant } )

			Case TRBAC2->PRENF == 'D' 								//FR - 10/12/2020
				Aadd(aOrdem , { 6 , 'XML Denegado (' + Alltrim(Str(nQuant)) + ')', nQuant } )

			Case TRBAC2->PRENF == 'F' //.AND. TRBAC2->PROTC == 0
				Aadd(aOrdem , { 7 , 'Falha Importação (' + Alltrim(Str(nQuant)) + ')', nQuant } )

			Case TRBAC2->PRENF == 'B' .AND.  ( Empty(TRBAC2->COMBUS) .AND.  TRBAC2->TPDOWLR > 0 ) //TRBAC2->TPDOWL == 'R'
				Aadd(aOrdem , { 8 , 'XML Imp. Capa (' + Alltrim(Str(nQuant)) + ')', nQuant } )

			Case TRBAC2->PRENF == 'Z' //.AND. TRBAC2->PROTC == 0
				Aadd(aOrdem , { 9 , 'XML Rejeitado (' + Alltrim(Str(nQuant)) + ')', nQuant } )

			Case TRBAC2->PRENF == 'B' .AND.  TRBAC2->COMBUS == 'S'
				Aadd(aOrdem , { 10 , 'XML Imp.Combustivel (' + Alltrim(Str(nQuant)) + ')', nQuant } )

			Case TRBAC2->PRENF == 'B' .AND.  TRBAC2->COMBUS == 'E'
				Aadd(aOrdem , { 11 , 'XML Imp.Energia (' + Alltrim(Str(nQuant)) + ')', nQuant } )

			Case TRBAC2->PRENF == 'N' .AND. TRBAC2->COMBUS == 'S'
				Aadd(aOrdem , { 12 , 'Pré-NF Class. Comb. (' + Alltrim(Str(nQuant)) + ')', nQuant } )

			Case TRBAC2->PRENF == 'N' .AND. TRBAC2->COMBUS == 'E'
				Aadd(aOrdem , { 13 , 'Pré-NF Class. Energia (' + Alltrim(Str(nQuant)) + ')', nQuant } )
				//FR - 10/12/2020

		EndCase

		TRBAC2->(dbSkip())

	Enddo

	//FR - 14/01/2021
	//---------------------------------------------------------//
	//painel a parte, para inserção do botão "exporta excel" :
	//---------------------------------------------------------//
	nLiIni := aPos[1][2]  	//3
	nCoIni := aPos[1][2]    //3
	_oPanel:= TPanel():New(nLiIni,nCoIni, , oPanel, , , , , , 0,50,lLowered,lRaised)
	_oPanel:Align := CONTROL_ALIGN_TOP
	TButton():New( nLiIni+10, nCoIni+10, "Exporta Excel",_oPanel,{|| Processa({|| fExpEXCL(.T.,2) }, "Aguarde...", "Exportando Graf.2...",.F.) },85,15,,,.F.,.T.,.F.,,.F.,,,.F. )
	//FR - 14/01/2021

	//FR - 10/12/2020 - ordena os itens para ficar na ordem que o RAfael pediu:
	If Len(aOrdem) > 0
		aSort(aOrdem, , , { |x, y| x[1] < y[1] })
		For fr := 1 to Len(aOrdem)
			oChart02:addSerie( aOrdem[fr,2], aOrdem[fr,3] )
		Next
	Endif

	//Define as cores que serão utilizadas no gráfico
	aAdd(aRand, {"084,120,164", "007,013,017"})
	aAdd(aRand, {"171,225,108", "017,019,010"})
	aAdd(aRand, {"207,136,077", "020,020,006"})
	aAdd(aRand, {"166,085,082", "017,007,007"})
	aAdd(aRand, {"130,130,130", "008,008,008"})

	//----------------------------------------------
	//Picture
	//----------------------------------------------
	oChart02:setPicture("@E 999999")

	//----------------------------------------------
	//Mascara
	//----------------------------------------------
	oChart02:setMask(" *@*")

	//Seta as cores utilizadas
	//oChart:oFWChartColor:aRandom := aRand
	//oChart:oFWChartColor:SetColor("Random")
	oChart02:SetLegend(CONTROL_ALIGN_LEFT)
	oChart02:setTitle("Quantidade x Status XML", CONTROL_ALIGN_CENTER)

	//oChart:setLegend( CONTROL_ALIGN_LEFT )  //esquerda
	oChart02:SetAlignSerieLabel(CONTROL_ALIGN_RIGHT)    //direita

	oChart02:EnableMenu(.T.)

	//Define o tipo do gráfico
	//oChart02:SetChartDefault(NEWPIECHART) //(BARCOMPCHART)
	oChart02:SetChartDefault(BARCOMPCHART) //FR - 10/12/2020
	//-----------------------------------------
	//oChart02:OOWNER:NBOTTOM =>853
	//oChart02:OOWNER:NCLIENTHEIGHT =>869
	//oChart02:OOWNER:NCLIENTWIDTH =>1710
	//oChart02:OOWNER:NHEIGHT => 853
	//oChart02:OOWNER:NRIGHT => 1696

	//FR - 14/01/2021
	nLiFim := oChart02:OOWNER:NBOTTOM  //853 - recebe o limite de linha final do gráfico
	nLiFim := nLiFim - 20            //703

	nCoFim := oChart02:OOWNER:NRIGHT   //1696
	nCoFim := nCoFim - 30              //1646

	oChart02:OOWNER:NBOTTOM := nLiFim  //703  - altura
	oChart02:OOWNER:NRIGHT  := nCoFim  //1646 - largura


	nLiFim := oPanel:NBOTTOM 	//703
	//FR - 14/01/2021

	oChart02:Activate()

Return Nil


//==============================================================//
//Gráfico 3: Valores x Tipo XML Mês
//==============================================================//
//***************************************************************
Static Function _fGera04(oPanel)
	//***************************************************************
	Local cQuery    := ""
	//FR - 14/01/2021
	Local nLiIni    := 0
	Local nCoIni    := 0
	Local nLiFim    := 0
	Local nCoFim    := 0
	Local _oPanel
	Local lLowered  := .F.
	Local lRaised   := .F. //.T. mostra borda do painel
	//FR - 14/01/2021


	//FR - 10/12/2020
	oChart04 := FWChartFactory():New()
	oChart04:SetOwner(oPanel)

	cQuery := " SELECT
	cQuery += " " + xZBZ+"_MODELO AS MODELO , "						+ CHR(13) + CHR(10)
	cQuery += "   Datepart ( MONTH,  "+xZBZ+"_DTNFE ) AS MES, "	+ CHR(13) + CHR(10)
	cQuery += "   CASE Datepart ( MONTH,  "+xZBZ+"_DTNFE ) "		+ CHR(13) + CHR(10)
	cQuery += "     WHEN 1  THEN 'JANEIRO' "						+ CHR(13) + CHR(10)
	cQuery += "     WHEN 2  THEN 'FEVEREIRO' "						+ CHR(13) + CHR(10)
	cQuery += "     WHEN 3  THEN 'MARCO' "							+ CHR(13) + CHR(10)
	cQuery += "     WHEN 4  THEN 'ABRIL' "							+ CHR(13) + CHR(10)
	cQuery += "     WHEN 5  THEN 'MAIO' "							+ CHR(13) + CHR(10)
	cQuery += "     WHEN 6  THEN 'JUNHO' "							+ CHR(13) + CHR(10)
	cQuery += "     WHEN 7  THEN 'JULHO' "							+ CHR(13) + CHR(10)
	cQuery += "     WHEN 8  THEN 'AGOSTO' "							+ CHR(13) + CHR(10)
	cQuery += "     WHEN 9  THEN 'SETEMBRO' "						+ CHR(13) + CHR(10)
	cQuery += "     WHEN 10 THEN 'OUTUBRO' "						+ CHR(13) + CHR(10)
	cQuery += "     WHEN 11 THEN 'NOVEMBRO' "						+ CHR(13) + CHR(10)
	cQuery += "     WHEN 12 THEN 'DEZEMBRO' "						+ CHR(13) + CHR(10)
	cQuery += "   END MESANO, "										+ CHR(13) + CHR(10)
	//cQuery += "   SUM("+xZBZ+"_VLBRUT) AS VALTOT "					+ CHR(13) + CHR(10)
	cQuery += "   "+xZBZ+"_VLBRUT AS VALTOT, "		   				+ CHR(13) + CHR(10)       	//FR - 19/02/2021 - Revisões nas queries que buscam os valores dos XMLs
	cQuery += " ZBZ.R_E_C_N_O_ AS RECZBZ " 			   				+ CHR(13) + CHR(10)			//FR - 19/02/2021 - Revisões nas queries que buscam os valores dos XMLs
	cQuery += " FROM " + RETSQLNAME(xZBZ) + " "+xZBZ+" "			+ CHR(13) + CHR(10)

	cQuery += " WHERE D_E_L_E_T_ <> '*' "							+ CHR(13) + CHR(10)

	//If Year(dDataDe) == Year(dDataAte)
	//	cQuery += " AND YEAR(" + xZBZ + "_DTNFE) = '" + Alltrim( Str( Year(dDataDe) ) ) + "' " + CHR(13) + CHR(10)
	//Else
	//	cQuery += " AND YEAR(" + xZBZ + "_DTNFE) = '" + Alltrim( Str( Year(dDataAte) ) ) + "' " + CHR(13) + CHR(10)
	//Endif
	cQuery += " AND "+xZBZ+"_DTNFE BETWEEN '"+DTOS(dDataDe)+"' AND '"+DTOS(dDataAte)+"' "+ CHR(13) + CHR(10) 	//FR - 14/01/2021 - data emissão da nf

	If !Empty(cFornec) .and. !Empty(cLoj)
		cQuery += " AND "+xZBZ+"_CODFOR = '" + Alltrim(cFornec) + "' "	+ CHR(13) + CHR(10)					//FR - 10/12/2020
		cQuery += " AND "+xZBZ+"_LOJFOR = '" + Alltrim(cLoj) + "' "		+ CHR(13) + CHR(10)					//FR - 10/12/2020
	Endif
	If !Empty(cFilAte)
		cQuery += " AND "+xZBZ+"_FILIAL BETWEEN '" + Alltrim(cFilDe) + "' AND '"+ Alltrim(cFilAte) + "' "	+ CHR(13) + CHR(10)
	Endif
	//cQuery += " GROUP BY "  + xZBZ+"_MODELO , datepart ( MONTH,  "+xZBZ+"_DTNFE ) " 						+ CHR(13) + CHR(10)
	cQuery += " ORDER BY MES , MODELO "

	MemoWrite("C:\TEMP\_fGera04.sql" , cQuery)

	If ( SELECT("TRB04") ) > 0
		DbSelectArea("TRB04")
		TRB04->(dbCloseArea())
	EndIf

	TcQuery cQuery Alias "TRB04" New

	If !TRB04->( Eof() )
		TRB04->(dbGoTop())

		cModelo := ""
		//cAno    := ""
		//If Year(dDataDe) == Year(dDataAte)
		//	cAno := Alltrim( Str( Year(dDataDe) ) )
		//Else
		//	cAno := Alltrim( Str( Year(dDataAte) ) )
		//Endif

		//oChart04:SetXAxis( {"Janeiro/"+cAno, "Fevereiro/"+cAno, "Março/"+cAno, "Abril/"+cAno, "Maio/"+cAno, "Junho/"+cAno, "Julho/"+cAno, "Agosto/"+cAno, "Setembro/"+cAno, "Outubro/"+cAno, "Novembro/"+cAno, "Dezembro/"+cAno } )
		oChart04:SetXAxis( {"Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho", "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro" } )

		//Cria a série com os espaços de cada mês vazios, para depois povoar, para já entrar na sequência de mês correta:
		oChart04:addSerie( 'NFE'  , {  0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0   } )
		oChart04:addSerie( 'CTE'  , {  0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0   } )
		oChart04:addSerie( 'NFCE' , {  0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0   } )
		oChart04:addSerie( 'CTEOS', {  0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0   } )
		oChart04:addSerie( 'RP'   , {  0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0   } )

		While TRB04->( !EOF() )

			xMes    	:= TRB04->MES
			nTotNFE 	:= 0
			nTotNFCE	:= 0
			nTotCTE 	:= 0
			nTotRP  	:= 0
			nTotCTEOS	:= 0
			nValor  	:= 0

			While xMes == TRB04->MES

				nValor := TRB04->VALTOT

				If nValor == 0

					DbSelectArea(xZBZ)						//acessa a ZBZ
					(xZBZ)->( Dbgoto(TRB04->RECZBZ) )		//posiciona no registro
					cXml   := ""
					cXml   := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML")))	//para pegar o conteúdo do XML

					//se o campo da ZBZ estiver vazio, faz o parse no xml para obter o valor
					nValor := U_fParseXML( TRB04->MODELO, cXml ) 		//função faz o parse e retorna o valor bruto do xml

				Endif

				Do Case
					Case TRB04->MODELO == '55'
						nTotNFE += nValor //TRB04->VALTOT

					Case TRB04->MODELO == '57'
						nTotCTE += nValor //TRB04->VALTOT

					Case TRB04->MODELO == '65'
						nTotNFCE += nValor //TRB04->VALTOT

					Case TRB04->MODELO == '67'
						nTotCTEOS += nValor //TRB04->VALTOT

					Case TRB04->MODELO == 'RP'
						nTotRP += nValor //TRB04->VALTOT
				EndCase

				TRB04->(dbSkip())
			Enddo

			/*
			oChart04:addSerie( 'NFE'  , {  0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0   } )  //1 - ASERIES[1][2][xMes]
			oChart04:addSerie( 'CTE'  , {  0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0   } )  //2 - ASERIES[2][2][xMes]
			oChart04:addSerie( 'NFCE' , {  0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0   } )  //3 - ASERIES[3][2][xMes]
			oChart04:addSerie( 'CTEOS', {  0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0   } )  //4 - ASERIES[4][2][xMes]
			oChart04:addSerie( 'RP'   , {  0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0   } )  //5 - ASERIES[5][2][xMes]
			*/

			//só povoa as posições já pre-determinadas porque é por mês (12 meses)
			If nTotNFE > 0
				//oChart04:ASERIES[1][2]
				// oChart04:ASERIES[1][2][1] -> aqui vai o valor
				oChart04:ASERIES[1][2][xMes] := nTotNFE
			Endif

			If nTotCTE > 0
				oChart04:ASERIES[2][2][xMes] := nTotCTE
			Endif

			If nTotNFCE > 0
				oChart04:ASERIES[3][2][xMes] := nTotNFCE
			Endif

			If nTotCTEOS > 0
				oChart04:ASERIES[4][2][xMes] := nTotCTEOS
			Endif

			If nTotRP > 0
				oChart04:ASERIES[5][2][xMes] := nTotRP
			Endif

		Enddo

		//FR - 14/01/2021
		//---------------------------------------------------------//
		//painel a parte, para inserção do botão "exporta excel" :
		//---------------------------------------------------------//
		nLiIni := aPos[1][2]  	//3
		nCoIni := aPos[1][2]    //3
		_oPanel:= TPanel():New(nLiIni,nCoIni, , oPanel, , , , , , 0,50,lLowered,lRaised)
		_oPanel:Align := CONTROL_ALIGN_TOP
		TButton():New( nLiIni+10, nCoIni+10, "Exporta Excel",_oPanel,{|| Processa({|| fExpEXCL(.T.,3) }, "Aguarde...", "Exportando Graf.3...",.F.) },85,15,,,.F.,.T.,.F.,,.F.,,,.F. )
		//FR - 14/01/2021

		//----------------------------------------------
		//Picture
		//----------------------------------------------
		oChart04:setPicture("@E 9,999,999,999.99")

		//----------------------------------------------
		//Mascara
		//----------------------------------------------
		oChart04:setMask("R$ *@*")

		//----------------------------------------------
		//Adiciona Legenda
		//opções de alinhamento da legenda:
		//CONTROL_ALIGN_RIGHT | CONTROL_ALIGN_LEFT |
		//CONTROL_ALIGN_TOP | CONTROL_ALIGN_BOTTOM
		//----------------------------------------------
		oChart04:SetLegend(CONTROL_ALIGN_LEFT)

		//----------------------------------------------
		//Titulo
		//opções de alinhamento do titulo:
		//CONTROL_ALIGN_RIGHT | CONTROL_ALIGN_LEFT | CONTROL_ALIGN_CENTER
		//----------------------------------------------
		oChart04:setTitle("Valores x Tipo XML Mês - De: " + Dtoc(dDataDe) + " A " +  Dtoc(dDataAte) , CONTROL_ALIGN_CENTER) //"Oportunidades por fase"

		//----------------------------------------------
		//Opções de alinhamento dos labels(disponível somente no gráfico de funil):
		//CONTROL_ALIGN_RIGHT | CONTROL_ALIGN_LEFT | CONTROL_ALIGN_CENTER
		//----------------------------------------------
		oChart04:SetAlignSerieLabel(CONTROL_ALIGN_RIGHT)

		//Desativa menu que permite troca do tipo de gráfico pelo usuário
		oChart04:EnableMenu(.T.)

		//Define o tipo do gráfico
		//oChart04:SetChartDefault(RADARCHART)
		oChart04:SetChartDefault(COLUMNCHART)
		//-----------------------------------------
		// Opções disponiveis
		// RADARCHART
		// FUNNELCHART
		// COLUMNCHART
		// NEWPIECHART
		// NEWLINECHART
		//-----------------------------------------

		//FR - 14/01/2021
		nLiFim := oChart04:OOWNER:NBOTTOM  //853 - recebe o limite de linha final do gráfico
		nLiFim := nLiFim - 20             //703

		nCoFim := oChart04:OOWNER:NRIGHT   //1696
		nCoFim := nCoFim - 30             //1646

		oChart04:OOWNER:NBOTTOM := nLiFim  //703  - altura
		oChart04:OOWNER:NRIGHT  := nCoFim  //1646 - largura

		nLiFim := oPanel:NBOTTOM  			//703
		//FR - 14/01/2021

		oChart04:Activate()

	Else
		//não há dados para o filtro informado
	Endif


Return Nil

//==============================================================//
//Gráfico 4: Quantidade x Eventos
//==============================================================//
//***************************************************************
Static Function _fGera06(oPanel)
	//***************************************************************
	//FR - 14/01/2021
	Local nLiIni    := 0
	Local nCoIni    := 0
	Local nLiFim    := 0
	Local nCoFim    := 0
	Local _oPanel
	Local lLowered  := .F.
	Local lRaised   := .F. //.T. mostra borda do painel
	//FR - 14/01/2021

	cQuery := " SELECT "+xZBE+"_TPEVE AS TPEVE, "			   		+ CHR(13) + CHR(10)
	cQuery += "  CASE "+xZBE+"_TPEVE " 						   		+ CHR(13) + CHR(10)
	cQuery += "  WHEN '110110' THEN 'Carta de Correção' " 	   		+ CHR(13) + CHR(10)
	cQuery += "  WHEN '110111' THEN 'Cancelado' "					+ CHR(13) + CHR(10)
	cQuery += "	 WHEN '210200' THEN 'Confirmação da Operação' " 	+ CHR(13) + CHR(10)
	cQuery += "	 WHEN '210210' THEN 'Ciência da Operação' " 		+ CHR(13) + CHR(10)
	cQuery += "	 WHEN '210220' THEN 'Desconhecimento da operação' " + CHR(13) + CHR(10)
	cQuery += "	 WHEN '210240' THEN 'Operação não Realizada' " 		+ CHR(13) + CHR(10)
	cQuery += "	 WHEN '610110' THEN 'Desacordo CTe' " 				+ CHR(13) + CHR(10)
	cQuery += "   END DESCEVEN, " 									+ CHR(13) + CHR(10)
	cQuery += "   COUNT(*) AS QUANT " + CHR(13) + CHR(10)
	cQuery += " FROM " + RETSQLNAME(xZBE) + " "+xZBE+" " 			+ CHR(13) + CHR(10)

	//join com ZBZ:
	cQuery += " INNER JOIN " + RetSqlName(xZBZ) + " ZBZ ON "+xZBZ+"_CHAVE = "+xZBE+"_CHAVE " 	+ CHR(13) + CHR(10)
	cQuery += " AND "+xZBZ+"_FILIAL = "+xZBE+"_FILIAL " 			+ CHR(13) + CHR(10)
	cQuery += " AND "+xZBE+"_TPEVE <> 'HXL069' " 					+ CHR(13) + CHR(10)
	cQuery += " AND ZBZ.D_E_L_E_T_ <> '*' "	+ CHR(13) + CHR(10)

	If !Empty(cFornec) .and. !Empty(cLoj)
		cQuery += " AND "+xZBZ+"_CODFOR = '" + Alltrim(cFornec) + "' "	+ CHR(13) + CHR(10)
		cQuery += " AND "+xZBZ+"_LOJFOR = '" + Alltrim(cLoj) + "' "		+ CHR(13) + CHR(10)
	Endif

	cQuery += " WHERE "+xZBE+".D_E_L_E_T_ <> '*' "						 + CHR(13) + CHR(10)

	If !Empty(cFilAte)
		cQuery += " AND "+xZBE+"_FILIAL BETWEEN '" + Alltrim(cFilDe) + "' AND '"+ Alltrim(cFilAte) + "' "	+ CHR(13) + CHR(10)
	Endif

	//cQuery += "   AND "+xZBE+"_DTRECB BETWEEN '"+DTOS(dDataDe)+"' AND '"+DTOS(dDataAte)+"' " 	 + CHR(13) + CHR(10)
	cQuery += "   GROUP BY "+xZBE+"_TPEVE "  	+ CHR(13) + CHR(10)
	cQuery += "   ORDER BY "+xZBE+"_TPEVE " 	+ CHR(13) + CHR(10)

	MemoWrite("C:\TEMP\_fGera06.sql" , cQuery )  	//FR - 10/12/2020
	cQuery := ChangeQuery(cQuery)               	//FR - 10/12/2020

	If ( SELECT("TRBAC6") ) > 0
		dbSelectArea("TRBAC6")
		TRBAC6->(dbCloseArea())
	EndIf

	TcQuery cQuery Alias "TRBAC6" New

	TRBAC6->(dbGoTop())

	aC6Even := {}
	aC6Qtd := {}

	_Qtd1 := _Qtd2 := _Qtd3 := _Qtd4 := _Qtd5 := _Qtd6 := _Qtd7 := 0

	If !TRBAC6->(EOF())				//FR - 19/02/2021
		While !TRBAC6->(EOF())

			Do Case
				Case TRBAC6->TPEVE == "110110"
					_Qtd1 := TRBAC6->QUANT
				Case TRBAC6->TPEVE == "110111"
					_Qtd2 := TRBAC6->QUANT
				Case TRBAC6->TPEVE == "210200"
					_Qtd3 := TRBAC6->QUANT
				Case TRBAC6->TPEVE == "210210"
					_Qtd4 := TRBAC6->QUANT
				Case TRBAC6->TPEVE == "210220"
					_Qtd5 := TRBAC6->QUANT
				Case TRBAC6->TPEVE == "210240"
					_Qtd6 := TRBAC6->QUANT
				Case TRBAC6->TPEVE == "610110"
					_Qtd7 := TRBAC6->QUANT

			EndCase

			TRBAC6->(dbSkip())

		Enddo

		//FR - 14/01/2021
		//---------------------------------------------------------//
		//painel a parte, para inserção do botão "exporta excel" :
		//---------------------------------------------------------//
		nLiIni := aPos[1][2]  	//3
		nCoIni := aPos[1][2]    //3
		_oPanel:= TPanel():New(nLiIni,nCoIni, , oPanel, , , , , , 0,50,lLowered,lRaised)
		_oPanel:Align := CONTROL_ALIGN_TOP
		TButton():New( nLiIni+10, nCoIni+10, "Exporta Excel",_oPanel,{|| Processa({|| fExpEXCL(.T.,4) }, "Aguarde...", "Exportando Graf.4...",.F.) },85,15,,,.F.,.T.,.F.,,.F.,,,.F. )
		//FR - 14/01/2021

		oChart06 := FWChartFactory():New()
		oChart06:SetOwner(oPanel)

		oChart06:SetXAxis( {"Correção ("+Alltrim(Str(_Qtd1))+")", "Cancelado ("+Alltrim(Str(_Qtd2))+")", "Confirmação ("+Alltrim(Str(_Qtd3))+")",;
			"Ciência ("+Alltrim(Str(_Qtd4))+")", "Desconhecimento ("+Alltrim(Str(_Qtd5))+")","Não Realizada ("+Alltrim(Str(_Qtd6))+")","Desacordo CTe ("+Alltrim(Str(_Qtd7))+")"} )

		oChart06:addSerie('Quant', {  _Qtd1 , _Qtd2 , _Qtd3 , _Qtd4 , _Qtd5 , _Qtd6 , _Qtd7 } )

		/*
		oChart04:addSerie('NFE', {  Randomize(1000,20000),Randomize(1000,20000),Randomize(1000,20000),Randomize(1000,2000), Randomize(1000,20000), Randomize(1000,20000) } )
		oChart04:addSerie('CTE', {  Randomize(1000,20000),Randomize(1000,20000),Randomize(1000,20000),Randomize(1000,2000), Randomize(1000,20000), Randomize(1000,20000) } )
		oChart04:addSerie('NFCE', {  Randomize(1000,20000),Randomize(1000,20000),Randomize(1000,20000),Randomize(1000,2000), Randomize(1000,20000), Randomize(1000,20000) } )
		oChart04:addSerie('NFSE', { Randomize(1000,20000),Randomize(1000,20000),Randomize(1000,20000),Randomize(1000,2000), Randomize(1000,20000), Randomize(1000,20000) } )
		oChart04:addSerie('CTEOS', { Randomize(1000,20000),Randomize(1000,20000),Randomize(1000,20000),Randomize(1000,2000), Randomize(1000,20000), Randomize(1000,20000) } )
		*/

		oChart06:SetLegend(CONTROL_ALIGN_LEFT)
		oChart06:setTitle("Quantidade x Eventos", CONTROL_ALIGN_CENTER) //"Oportunidades por fase"
		oChart06:SetAlignSerieLabel(CONTROL_ALIGN_RIGHT)

		oChart06:EnableMenu(.t.)

		//Define o tipo do gráfico
		oChart06:SetChartDefault(COLUMNCHART)

		//FR - 14/01/2021
		nLiFim := oChart06:OOWNER:NBOTTOM  //853 - recebe o limite de linha final do gráfico
		nLiFim := nLiFim - 20             //703

		nCoFim := oChart06:OOWNER:NRIGHT   //1696
		nCoFim := nCoFim - 30              //1646

		oChart06:OOWNER:NBOTTOM := nLiFim  //703  - altura
		oChart06:OOWNER:NRIGHT  := nCoFim  //1646 - largura

		nLiFim := oPanel:NBOTTOM          //703
		//FR - 14/01/2021

		oChart06:Activate()
	Else

		//FR - 19/02/2021
		//---------------------------------------------------------//
		//painel a parte, para inserção do botão "exporta excel" :
		//---------------------------------------------------------//
		nLiIni := aPos[1][2]  	//3
		nCoIni := aPos[1][2]    //3
		_oPanel:= TPanel():New(nLiIni,nCoIni, , oPanel, , , , , , 0,50,lLowered,lRaised)
		_oPanel:Align := CONTROL_ALIGN_TOP
		//TButton():New( nLiIni+10, nCoIni+10, "Exporta Excel",_oPanel,{|| Processa({|| fExpEXCL(.T.,4) }, "Aguarde...", "Exportando Graf.4...",.F.) },85,15,,,.F.,.T.,.F.,,.F.,,,.F. )
		@nLiIni,50 SAY "Sem Dados a Exibir"	PIXEL SIZE 150,25 OF _oPanel 	//FR - 19/02/2021
		//FR - 14/01/2021

	Endif		//If !TRBAC6->(EOF())

Return Nil

//FR - 10/12/2020 - função comentada por não estar em uso
/*
//***************************************************************
Static Function _fGera07(oPanel)
//***************************************************************

	//Local oChart07

	//oChart06 := FWChartLine():New()
	oChart06 := FWChartBarComp():New()
	oChart06:init( oPanel, .t. )
	oChart06:addSerie( "Votos PT", { {"Jan",50}, {"Fev",55}, {"Mar",60} })
	oChart06:addSerie( "Votos PMDB", { {"Jan",30}, {"Fev",35}, {"Mar",40} } )
	oChart06:addSerie( "Votos PV", { {"Jan",20}, {"Fev",10}, {"Mar",10} } )
	oChart06:setLegend( CONTROL_ALIGN_LEFT )
	oChart06:Build()

Return Nil
*/

//=============================================================//
//Gráfico 5: Valor x Impostos XML
//=============================================================//
//***************************************************************
Static Function _fGera08(oPanel)
	//***************************************************************
	//FR - 14/01/2021
	Local nLiIni    := 0
	Local nCoIni    := 0
	Local nLiFim    := 0
	Local nCoFim    := 0
	Local _oPanel
	Local lLowered  := .F.
	Local lRaised   := .F. //.T. mostra borda do painel
	//FR - 14/01/2021

	oChart08 := FWChartFactory():New(0,0,50,50)
	oChart08:SetOwner(oPanel)

//	IF (MsgNoYes("Deseja Atualizar a base ?","Atualiza Dados"))
//		U_HFATUBASE()
//	ENDIF
	/*
	cQuery := "  SELECT SUM("+xZBZ+"_ICMVAL) AS ICMS, "		+CHR(13) + CHR(10)
	cQuery += " 		SUM("+xZBZ+"_STVALO) AS ST, "		+CHR(13) + CHR(10)
	cQuery += " 		SUM("+xZBZ+"_IPIVAL) AS IPI, "		+CHR(13) + CHR(10)
	cQuery += " 		SUM("+xZBZ+"_PISVAL) AS PIS, "		+CHR(13) + CHR(10)
	cQuery += " 		SUM("+xZBZ+"_COFVAL) AS COFVAL, "	+CHR(13) + CHR(10)
	//cQuery += " 		SUM("+xZBZ+"_VLLIQ) AS VALTOT "		+CHR(13) + CHR(10)
	cQuery += " 		SUM("+xZBZ+"_VLBRUT) AS VALTOT "	+CHR(13) + CHR(10)

	cQuery += "  FROM " + RETSQLNAME(xZBZ) + " "+xZBZ+" "  	+CHR(13) + CHR(10)

	cQuery += " WHERE "+xZBZ+".D_E_L_E_T_ <> '*' "			+ CHR(13) + CHR(10)
	cQuery += " AND   "+xZBZ+"_MODELO <> '' " 				+ CHR(13) + CHR(10)
	cQuery += " AND "+xZBZ+"_DTNFE BETWEEN '"+DTOS(dDataDe)+"' AND '"+DTOS(dDataAte)+"' "	+CHR(13) + CHR(10)

	If !Empty(cFornec) .and. !Empty(cLoj)
		cQuery += " AND "+xZBZ+"_CODFOR = '" + Alltrim(cFornec) + "' "	+ CHR(13) + CHR(10)
		cQuery += " AND "+xZBZ+"_LOJFOR = '" + Alltrim(cLoj) + "' "		+ CHR(13) + CHR(10)
	Endif

	If !Empty(cFilAte)
		cQuery += " AND "+xZBZ+"_FILIAL BETWEEN '" + Alltrim(cFilDe) + "' AND '"+ Alltrim(cFilAte) + "' "	+ CHR(13) + CHR(10)
	Endif
	*/

	cQuery := "  SELECT "+xZBZ+"_ICMVAL AS ICMS, "		+CHR(13) + CHR(10)
	cQuery += " 		"+xZBZ+"_STVALO AS ST, "		+CHR(13) + CHR(10)
	cQuery += " 		"+xZBZ+"_IPIVAL AS IPI, "		+CHR(13) + CHR(10)
	cQuery += " 		"+xZBZ+"_PISVAL AS PIS, "		+CHR(13) + CHR(10)
	cQuery += " 		"+xZBZ+"_COFVAL AS COFVAL, "	+CHR(13) + CHR(10)
	cQuery += " 		"+xZBZ+"_VLBRUT AS VALTOT, "	+CHR(13) + CHR(10)
	cQuery += "         "+xZBZ+"_MODELO AS ZBZMODELO, " +CHR(13) + CHR(10)
	cQuery += " ZBZ.R_E_C_N_O_ AS RECZBZ " 				+CHR(13) + CHR(10)

	cQuery += "  FROM " + RETSQLNAME(xZBZ) + " "+xZBZ+" "  	+CHR(13) + CHR(10)

	cQuery += " WHERE "+xZBZ+".D_E_L_E_T_ <> '*' "			+ CHR(13) + CHR(10)
	cQuery += " AND   "+xZBZ+"_MODELO <> '' " 				+ CHR(13) + CHR(10)
	cQuery += " AND "+xZBZ+"_DTNFE BETWEEN '"+DTOS(dDataDe)+"' AND '"+DTOS(dDataAte)+"' "	+CHR(13) + CHR(10)

	If !Empty(cFornec) .and. !Empty(cLoj)
		cQuery += " AND "+xZBZ+"_CODFOR = '" + Alltrim(cFornec) + "' "	+ CHR(13) + CHR(10)
		cQuery += " AND "+xZBZ+"_LOJFOR = '" + Alltrim(cLoj) + "' "		+ CHR(13) + CHR(10)
	Endif

	If !Empty(cFilAte)
		cQuery += " AND "+xZBZ+"_FILIAL BETWEEN '" + Alltrim(cFilDe) + "' AND '"+ Alltrim(cFilAte) + "' "	+ CHR(13) + CHR(10)
	Endif

	//FR - 19/02/2021 - alterar query para não pegar o valor do ZBZ_VLBRUT , mas sim, direto de um parse do xml pois há registros na ZBZ em que o campo de valor está zerado

	MemoWrite("C:\TEMP\_fGera08.sql" , cQuery )    	//FR - 10/12/2020
	cQuery := ChangeQuery(cQuery)	               	//FR - 10/12/2020

	If ( SELECT("TRB09") ) > 0
		dbSelectArea("TRB09")
		TRB09->(dbCloseArea())
	EndIf

	TcQuery cQuery Alias "TRB09" New

	TRB09->(dbGoTop())

	//	oChart:addSerie( "NFE" , 0 )
	//	oChart:addSerie( "CTE" ,  0 )
	//	oChart:addSerie( "NFCE" , 0 )
	//	oChart:addSerie( "NFSE" , 0 )
	//	oChart:addSerie( "CTEOS" , 0 )

	_vICMS :=	_vST	:= _vIPI	:= _vPIS	:= _vCOFVAL := 	_vVALTOT := 0

	If TRB09->( !EOF() )

		_vICMS := TRB09->ICMS
		_vST	:= TRB09->ST
		_vIPI	:= TRB09->IPI
		_vPIS	:= TRB09->PIS
		_vCOFVAL := TRB09->COFVAL
		_vVALTOT := TRB09->VALTOT

		oChart08:addSerie('ICMS APURADO ( R$'  + Transform(_vICMS , "@E 9,999,999,999.99")+')', _vICMS   )
		oChart08:addSerie('ICMS RET  ( R$'   + Transform(_vST   , "@E 9,999,999,999.99")+')', _vST     )
		oChart08:addSerie('IPI ( R$'   + Transform(_vIPI  , "@E 9,999,999,999.99")+')', _vIPI    )
		oChart08:addSerie('PIS ( R$'   + Transform(_vPIS  , "@E 9,999,999,999.99")+')', _vPIS    )
		oChart08:addSerie('COFINS ( R$'+Transform(_vCOFVAL,"@E 9,999,999,999.99")+')', _vCOFVAL )
		//oChart02:addSerie('VALTOT', TRBAC2->QUANT )

	Endif
	*/

	If TRB09->( !EOF() )

		While TRB09->( !EOF() )

			xVICMS:= TRB09->ICMS
			xVST  := TRB09->ST
			xVIPI := TRB09->IPI
			xVPIS := TRB09->PIS
			xVCOF := TRB09->COFVAL
			nValor:= TRB09->VALTOT

			DbSelectArea(xZBZ)						//acessa a ZBZ
			(xZBZ)->( Dbgoto(TRB09->RECZBZ) )		//posiciona no registro
			cXml   := ""
			cXml   := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML")))	//para pegar o conteúdo do XML
			/*
			//se o campo da ZBZ estiver vazio, faz o parse no xml para obter o valor
			If nValor == 0
				nValor := U_fParseXML( TRB09->ZBZMODELO, cXml ) 		//função faz o parse e retorna o valor bruto do xml
			Endif

			If xVICMS == 0
				xVICMS := U_fParseXML( TRB09->ZBZMODELO, cXml, "ICM" )
			Endif

			If xVST == 0
				xVST := U_fParseXML( TRB09->ZBZMODELO, cXml, "ST")
			Endif

			If xVIPI == 0
				xVIPI := U_fParseXML( TRB09->ZBZMODELO, cXml, "IPI" )
			Endif

			If xVPIS == 0
				xVPIS := U_fParseXML( TRB09->ZBZMODELO, cXml, "PIS" )
			Endif

			If xVCOF == 0
				xVCOF := U_fParseXML( TRB09->ZBZMODELO, cXml, "COF")
			Endif

			RecLock((xZBZ), .F.)
			(xZBZ)->(FieldPut(FieldPos(xZBZ+"_ICMVAL"), xVICMS))
			(xZBZ)->(FieldPut(FieldPos(xZBZ+"_STVALO") , xVST ))
			(xZBZ)->(FieldPut(FieldPos(xZBZ+"_IPIVAL") , xVIPI ))
			(xZBZ)->(FieldPut(FieldPos(xZBZ+"_PISVAL") , xVPIS ))
			(xZBZ)->(FieldPut(FieldPos(xZBZ+"_COFVAL") , xVCOF ))
			(xZBZ)->(MsUnlock())
			*/

			_vICMS	+= xVICMS //ICMS RETIDO
			_vST	+= xVST   //ICMS APURADO
			_vIPI	+= xVIPI
			_vPIS	+= xVPIS
			_vCOFVAL+= xVCOF
			_vVALTOT+= nValor //TRB09->VALTOT

			TRB09->(Dbskip())

		Enddo

		oChart08:addSerie('ICMS APURADO ( R$'  + Transform(_vICMS , "@E 9,999,999,999.99")+')', _vICMS   )
		oChart08:addSerie('ICMS RET  ( R$'   + Transform(_vST   , "@E 9,999,999,999.99")+')', _vST     )
		oChart08:addSerie('IPI ( R$'   + Transform(_vIPI  , "@E 9,999,999,999.99")+')', _vIPI    )
		oChart08:addSerie('PIS ( R$'   + Transform(_vPIS  , "@E 9,999,999,999.99")+')', _vPIS    )
		oChart08:addSerie('COFINS ( R$'+Transform(_vCOFVAL,"@E 9,999,999,999.99")+')', _vCOFVAL )

	Endif


	//FR - 14/01/2021
	//---------------------------------------------------------//
	//painel a parte, para inserção do botão "exporta excel" :
	//---------------------------------------------------------//
	nLiIni := aPos[1][2]  	//3
	nCoIni := aPos[1][2]    //3
	_oPanel:= TPanel():New(nLiIni,nCoIni, , oPanel, , , , , , 0,50,lLowered,lRaised)
	_oPanel:Align := CONTROL_ALIGN_TOP
	TButton():New( nLiIni+10, nCoIni+10, "Exporta Excel",_oPanel,{|| Processa({|| fExpEXCL(.T.,5) }, "Aguarde...", "Exportando Graf.5...",.F.) },85,15,,,.F.,.T.,.F.,,.F.,,,.F. )
	//FR - 14/01/2021

	//Define as cores que serão utilizadas no gráfico
	aAdd(aRand, {"084,120,164", "007,013,017"})
	aAdd(aRand, {"171,225,108", "017,019,010"})
	aAdd(aRand, {"207,136,077", "020,020,006"})
	aAdd(aRand, {"166,085,082", "017,007,007"})
	aAdd(aRand, {"130,130,130", "008,008,008"})

	//----------------------------------------------
	//Picture
	//----------------------------------------------
	//oChart09:setPicture("@E 999999")
	oChart08:setPicture("@E 9,999,999,999.99")  	//FR - 10/12/2020

	//----------------------------------------------
	//Mascara
	//----------------------------------------------
	//oChart09:setMask(" *@*")
	oChart08:setMask("R$ *@*") 					//FR - 10/12/2020

	//Seta as cores utilizadas
	//oChart:oFWChartColor:aRandom := aRand
	//oChart:oFWChartColor:SetColor("Random")
	oChart08:SetLegend(CONTROL_ALIGN_LEFT)
	oChart08:setTitle("Valor x Impostos XML", CONTROL_ALIGN_CENTER)
	//oChart:setLegend( CONTROL_ALIGN_LEFT )   			//esquerda
	oChart08:SetAlignSerieLabel(CONTROL_ALIGN_RIGHT)    //direita

	oChart08:EnableMenu(.T.)

	//Define o tipo do gráfico
	//oChart08:SetChartDefault(BARCOMPCHART)
	oChart08:SetChartDefault(COLUMNCHART)
	//BARCOMPCHART
	//-----------------------------------------

	//FR - 14/01/2021
	nLiFim := oChart08:OOWNER:NBOTTOM  	//853 - recebe o limite de linha final do gráfico
	nLiFim := nLiFim - 20            	//703

	nCoFim := oChart08:OOWNER:NRIGHT   	//1696
	nCoFim := nCoFim - 30              	//1646

	oChart08:OOWNER:NBOTTOM := nLiFim  	//703  - altura
	oChart08:OOWNER:NRIGHT  := nCoFim  	//1646 - largura

	nLiFim := oPanel:NBOTTOM			//703
	//FR - 14/01/2021

	oChart08:Activate()

Return Nil

//==============================================================//
// Gráfico 6: Valor de Impostos - XML x Entrada
//==============================================================//
//***************************************************************
Static Function _fGera09(oPanel)
	//***************************************************************
	//FR - 14/01/2021
	Local nLiIni    := 0
	Local nCoIni    := 0
	Local nLiFim    := 0
	Local nCoFim    := 0
	Local _oPanel
	Local lLowered  := .F.
	Local lRaised   := .F. //.T. mostra borda do painel
	//FR - 14/01/2021

	oChart09 := FWChartFactory():New(0,0,50,50)
	oChart09:SetOwner(oPanel)

	cQuery := " SELECT 'XML' AS TIPO, " 					+ CHR(13) + CHR(10)
	cQuery += "  SUM("+xZBZ+"_ICMVAL) AS ICMS, "			+ CHR(13) + CHR(10)
	cQuery += "  SUM("+xZBZ+"_STVALO) AS ST, " 				+ CHR(13) + CHR(10)
	cQuery += "  SUM("+xZBZ+"_IPIVAL) AS IPI, "				+ CHR(13) + CHR(10)
	cQuery += "  SUM("+xZBZ+"_PISVAL) AS PIS, "				+ CHR(13) + CHR(10)
	cQuery += "  SUM("+xZBZ+"_COFVAL) AS COFINS, " 			+ CHR(13) + CHR(10)
	cQuery += "	 0 AS INSS, "								+ CHR(13) + CHR(10)
	cQuery += "	 0 AS ISS, "								+ CHR(13) + CHR(10)
	//cQuery += "  SUM("+xZBZ+"_VLLIQ) AS VALTOT "			+ CHR(13) + CHR(10)
	cQuery += "  SUM("+xZBZ+"_VLBRUT) AS VALTOT "			+ CHR(13) + CHR(10)

	cQuery += " FROM " + RETSQLNAME(xZBZ) + " "+xZBZ+" " 	+ CHR(13) + CHR(10)
	cQuery += " WHERE "+xZBZ+".D_E_L_E_T_ <> '*' "			+ CHR(13) + CHR(10)

	cQuery += " AND "+xZBZ+"_MODELO <> '' " 				+ CHR(13) + CHR(10)
	cQuery += " AND "+xZBZ+"_DTNFE BETWEEN '"+DTOS(dDataDe)+"' AND '"+DTOS(dDataAte)+"' "	+ CHR(13) + CHR(10)

	If !Empty(cFornec) .and. !Empty(cLoj)
		cQuery += " AND "+xZBZ+"_CODFOR = '" + Alltrim(cFornec) + "' "	+ CHR(13) + CHR(10)
		cQuery += " AND "+xZBZ+"_LOJFOR = '" + Alltrim(cLoj) + "' "		+ CHR(13) + CHR(10)
	Endif

	If !Empty(cFilAte)
		cQuery += " AND "+xZBZ+"_FILIAL BETWEEN '" + Alltrim(cFilDe) + "' AND '"+ Alltrim(cFilAte) + "' "	+ CHR(13) + CHR(10)
	Endif

	cQuery += " UNION "	+ CHR(13) + CHR(10)

	cQuery += "  SELECT 'ENTRADA' AS TIPO, "  		+ CHR(13) + CHR(10)
	cQuery += "  SUM(F1_VALICM) AS ICMS, " 	   		+ CHR(13) + CHR(10)
	cQuery += "		SUM(F1_ICMSRET) AS ST, "   		+ CHR(13) + CHR(10)
	cQuery += "		SUM(F1_VALIPI) AS IPI, "   		+ CHR(13) + CHR(10)
	cQuery += "		SUM(F1_VALIMP5) AS PIS, "  		+ CHR(13) + CHR(10)
	cQuery += "		SUM(F1_VALIMP6) AS COFINS, "	+ CHR(13) + CHR(10)
	cQuery += "		SUM(F1_INSS) AS INSS, "	   		+ CHR(13) + CHR(10)
	cQuery += "		SUM(F1_ISS) AS ISS, "  	   		+ CHR(13) + CHR(10)
	cQuery += "		SUM(F1_VALBRUT) AS VALTOT "		+ CHR(13) + CHR(10)
	cQuery += " FROM "+RetSqlName('SF1')+" SF1 "	+ CHR(13) + CHR(10)

	cQuery += " WHERE F1_DTDIGIT BETWEEN '"+DTOS(dDataDe)+"' AND '"+DTOS(dDataAte)+"' "	+ CHR(13) + CHR(10)
	cQuery += " AND  SF1.D_E_L_E_T_ <> '*' "		+ CHR(13) + CHR(10)
	//FR - 10/12/2020
	If !Empty(cFornec) .and. !Empty(cLoj)
		cQuery += " AND SF1.F1_FORNECE = '" + Alltrim(cFornec) + "' "	+ CHR(13) + CHR(10)
		cQuery += " AND SF1.F1_LOJA    = '" + Alltrim(cLoj) + "' "		+ CHR(13) + CHR(10)
	Endif

	If !Empty(cFilAte)
		cQuery += " AND SF1.F1_FILIAL BETWEEN '" + Alltrim(cFilDe) + "' AND '"+ Alltrim(cFilAte) + "' "	+ CHR(13) + CHR(10)
	Endif
	//FR - 10/12/2020
	cQuery += " ORDER BY TIPO DESC " 			+ CHR(13) + CHR(10)

	MemoWrite("C:\TEMP\_fGera09.sql" , cQuery )    	//FR - 10/12/2020
	cQuery := ChangeQuery(cQuery)	               	//FR - 10/12/2020

	If ( SELECT("TRB10") ) > 0
		dbSelectArea("TRB10")
		TRB10->(dbCloseArea())
	EndIf

	TcQuery cQuery Alias "TRB10" New

	TRB10->(dbGoTop())

	//oChart09:SetXAxis( {"ICMS", "ST", "IPI", "PIS", "COFINS", "INSS", "ISS"} )
	oChart09:SetXAxis( {"ICMS APURADO", "ICMS RET", "IPI", "PIS", "COFINS", "INSS", "ISS"} )     //FR - 10/12/2020

	If TRB10->( !EOF() )

		oChart09:addSerie(TRB10->TIPO, {  TRB10->ICMS, TRB10->ST, TRB10->IPI, TRB10->PIS, TRB10->COFINS, TRB10->INSS, TRB10->ISS  } )

		TRB10->(dbSkip())

		oChart09:addSerie(TRB10->TIPO, {  TRB10->ICMS, TRB10->ST, TRB10->IPI, TRB10->PIS, TRB10->COFINS, TRB10->INSS, TRB10->ISS  } )
		//oChart09:addSerie("SF1", {  200, 100, 50, 100, 30, 20, 10  } )
	Else

		oChart09:addSerie("XML", {  0, 0, 0, 0, 0, 0, 0  } )
		oChart09:addSerie("SF1", {  0, 0, 0, 0, 0, 0, 0  } )
	Endif

	//Define as cores que serão utilizadas no gráfico
	aAdd(aRand, {"084,120,164", "007,013,017"})
	aAdd(aRand, {"171,225,108", "017,019,010"})
	aAdd(aRand, {"207,136,077", "020,020,006"})
	aAdd(aRand, {"166,085,082", "017,007,007"})
	aAdd(aRand, {"130,130,130", "008,008,008"})

	//----------------------------------------------
	//Picture
	//----------------------------------------------
	//oChart09:setPicture("@E 999999")
	oChart09:setPicture("@E 9,999,999,999.99")  	//FR - 10/12/2020

	//----------------------------------------------
	//Mascara
	//----------------------------------------------
	//oChart09:setMask(" *@*")
	oChart09:setMask("R$ *@*") 					//FR - 10/12/2020


	//Seta as cores utilizadas
	//     oChart:oFWChartColor:aRandom := aRand
	//     oChart:oFWChartColor:SetColor("Random")
	oChart09:SetLegend(CONTROL_ALIGN_LEFT)
	oChart09:setTitle("Valor de Impostos - XML x Entrada", CONTROL_ALIGN_CENTER)
	//oChart:setLegend( CONTROL_ALIGN_LEFT )  			//esquerda
	oChart09:SetAlignSerieLabel(CONTROL_ALIGN_RIGHT)	//direita

	oChart09:EnableMenu(.T.)

	//Define o tipo do gráfico
	oChart09:SetChartDefault(NEWPIECHART) //(BARCOMPCHART)
	//-----------------------------------------

	//FR - 14/01/2021
	nLiFim := oChart09:OOWNER:NBOTTOM  	//853 - recebe o limite de linha final do gráfico
	nLiFim := nLiFim - 20            	//703

	nCoFim := oChart09:OOWNER:NRIGHT   	//1696
	nCoFim := nCoFim - 30              	//1646

	oChart09:OOWNER:NBOTTOM := nLiFim  	//703  - altura
	oChart09:OOWNER:NRIGHT  := nCoFim  //1646 - largura

	nLiFim := oPanel:NBOTTOM			//703

	//FR - 14/01/2021
	//---------------------------------------------------------//
	//painel a parte, para inserção do botão "exporta excel" :
	//---------------------------------------------------------//
	nLiIni := aPos[1][2]  	//3
	nCoIni := aPos[1][2]    //3
	_oPanel:= TPanel():New(nLiIni,nCoIni, , oPanel, , , , , , 0,50,lLowered,lRaised)
	_oPanel:Align := CONTROL_ALIGN_TOP
	TButton():New( nLiIni+10, nCoIni+10, "Exporta Excel",_oPanel,{|| Processa({|| fExpEXCL(.F.,6) }, "Aguarde...", "Exportando Graf.6...",.F.) },85,15,,,.F.,.T.,.F.,,.F.,,,.F. )
	//FR - 14/01/2021

	oChart09:Activate()

Return Nil

//FR - 10/12/2020 - função comentada por não estar em uso
/*
Static Function AtuDados()

	If empty(dDataDe) .or. empty(dDataAte) .or. dDataAte < dDataDe
		Alert("Datas Incorretas. Favor verificar")
		return()

	Else
//		_fColsBrw()
//		_fColsBrw04()
//		_fAtuGraf2()
//		_fAtuGraf5()
		//FPanel06( oLayer:GetWinPanel( "BOX06", "PANEL06", "LINE03" ) )
	EndIf
Return()
*/

//====================================================================//
//Função GetURLIMG(cUrl)
//Objetivo: obter a imagem da url fornecida
//====================================================================//
User Function GetUrlImg( cUrl )
	Local cHtml := ''
	Local cCaminho := ''
	Local cPath    := '\'

	Default cUrl := 'https://www.hfbr.com.br/logos/GEST%C3%83O-XML-1121-X-368.png'

	cHtml := HttpGet( cUrl )

	cCaminho := cPath + SubStr( cUrl, Rat("/",cUrl) + 01 )
	MemoWrite( cCaminho, cHtml )


Return( cCaminho )

//====================================================================//
//Função: _fGera11 - Tabela do Cena.1
//Autoria: Flávia Rocha
//Data   : 10/12/2020
//Objetivo: Gerar os dados em forma de tabela para apresentar em tela
//          na árvore "Tabelas -> Cena.1"
//====================================================================//
Static Function _fGera11( oPanel )

	Local nLiIni:= 0
	Local nLiFim:= 0
	Local nCo1  := 0
	Local nCo2  := 0
	Local nCo3  := 0
	Local nCo4  := 0
	Local nCo5  := 0
	Local nCo6  := 0
	Local nCo7  := 0
	Local nCo8  := 0
	//Local oTButton

	Local _oPanel
	Local lLowered  := .F.
	Local lRaised   := .F. //.T. mostra borda do painel

	Private oGetDados11
	Private aCols11  := {}

	/*
	Medidas do aSize:
	aSize[1] =     0
	aSize[2] =    30
	aSize[3] =   762,4
	aSize[4] =   356,8
	aSize[5] = 1.524,8
	aSize[6] =   713,6
	aSize[7] =     0
	aSize[8] =     5
	*/

	Private aObjects:= {}									//FR - 10/12/202
	Private aSize   := MsAdvSize(.T.)						//FR - 10/12/2020
	Private aInfo   := {}									//FR - 10/12/2020
	Private aPos    := {}									//FR - 10/12/2020

	nLiIni:= 0
	nCo1 := aSize[8]   		 	//5
	//nCo2 := aSize[2] * 2	 	//60
	nCo3 := aSize[2] * 4     	//120
	nCo4 := aSize[2] * 5 + 20   //150
	nCo5 := aSize[2] * 6     	//180
	nCo6 := aSize[2] * 7     	//210
	nCo7 := aSize[2] * 8     	//240
	nCo8 := aSize[2] * 9     	//270

	AAdd( aObjects, { 0, 95, .T., .F., .F. } )
	AAdd( aObjects, { 0, 0, .T., .T., .F. } )
	AAdd( aObjects, { 0, 60, .T., .F., .T. } )
	/*
    aSize[3] := aSize[3]*0.8
    aSize[4] := aSize[4]*0.8
    aSize[5] := aSize[3]*2
    aSize[6] := aSize[4]*2
	*/
	aInfo := { aSize[1], aSize[2], aSize[3], aSize[4], 3, 3 }
	aPos  := MsObjSize( aInfo, aObjects )

	//FR - 14/01/2021
	//---------------------------------------------------------//
	//painel a parte, para inserção do botão "exporta excel" :
	//---------------------------------------------------------//
	nLiIni := aPos[1][2]  	//3
	nCoIni := aPos[1][2]    //3
	_oPanel:= TPanel():New(nLiIni,nCoIni, , oPanel, , , , , , 0,50,lLowered,lRaised)
	_oPanel:Align := CONTROL_ALIGN_TOP
	TButton():New( nLiIni+10, nCoIni+10, "Exporta Dados Para Excel",_oPanel,{|| Processa({|| fExpEXCL(.T.,7) }, "Aguarde...", "Exportando Tabela Cena1...",.F.) },140,18,,,.F.,.T.,.F.,,.F.,,,.F. )
	//FR - 14/01/2021

	nLiIni += 50 //:= aSize[2] //30
	nLiFim := aSize[4] //356,8
	nCo2   := aSize[6] //713,6

	_fHeader(@aHeader11,@noBrw11,"11")		//monta array das colunas
	aCols11 := {}
	oGetDados11:= MsNewGetDados():New(nLiIni,nCo1,nLiFim,nCo2,0,{|| },"AllwaysTrue","",aAltera,,9999,"AllwaysTrue","","AllwaysTrue",oPanel,aHeader11,aCols11)
	_fColBrw11(oGetDados11, aCols11)		//cria massa de dados para a getdados
	oGetDados11:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT


Return
//====================================================================//
//Função: _fGera12 - Tabela do Cena.2
//Autoria: Flávia Rocha
//Data   : 10/12/2020
//Objetivo: Gerar os dados em forma de tabela para apresentar em tela
//          na árvore "Tabelas -> Cena.2"
//====================================================================//
Static Function _fGera12( oPanel )
	Local nLiIni:= 0
	Local nLiFim:= 0
	Local nCo1  := 0
	Local nCo2  := 0
	Local nCo3  := 0
	Local nCo4  := 0
	Local nCo5  := 0
	Local nCo6  := 0
	Local nCo7  := 0
	Local nCo8  := 0
	//Local oTButton

	Local _oPanel
	Local lLowered  := .F.
	Local lRaised   := .F. //.T. mostra borda do painel

	Private oGetDados12
	Private aCols12  := {}

	Private aObjects := {}
	Private aSize    := MsAdvSize(.T.)
	Private aInfo    := {}
	Private aPos     := {}

	nLiIni:= 0
	nCo1 := aSize[8]   		 	//5
	//nCo2 := aSize[2] * 2	 	//60
	nCo3 := aSize[2] * 4     	//120
	nCo4 := aSize[2] * 5 + 20   //150
	nCo5 := aSize[2] * 6     	//180
	nCo6 := aSize[2] * 7     	//210
	nCo7 := aSize[2] * 8     	//240
	nCo8 := aSize[2] * 9     	//270

	AAdd( aObjects, { 0, 95, .T., .F., .F. } )
	AAdd( aObjects, { 0, 0, .T., .T., .F. } )
	AAdd( aObjects, { 0, 60, .T., .F., .T. } )
	/*
    aSize[3] := aSize[3]*0.8
    aSize[4] := aSize[4]*0.8
    aSize[5] := aSize[3]*2
    aSize[6] := aSize[4]*2
	*/
	aInfo := { aSize[1], aSize[2], aSize[3], aSize[4], 3, 3 }
	aPos  := MsObjSize( aInfo, aObjects )

	//FR - 14/01/2021
	//---------------------------------------------------------//
	//painel a parte, para inserção do botão "exporta excel" :
	//---------------------------------------------------------//
	nLiIni := aPos[1][2]  	//3
	nCoIni := aPos[1][2]    //3
	_oPanel:= TPanel():New(nLiIni,nCoIni, , oPanel, , , , , , 0,50,lLowered,lRaised)
	_oPanel:Align := CONTROL_ALIGN_TOP
	TButton():New( nLiIni+10, nCoIni+10, "Exporta Dados Para Excel",_oPanel,{|| Processa({|| fExpEXCL(.T.,8) }, "Aguarde...", "Exportando Tabela Cena2...",.F.) },140,18,,,.F.,.T.,.F.,,.F.,,,.F. )
	//FR - 14/01/2021

	nLiIni += 50 //nLiIni := aSize[2] //30
	nLiFim := aSize[4] //356,8
	nCo2   := aSize[6] //713,6

	_fHeader(@aHeader12,@noBrw12,"12") 		//monta array das colunas
	aCols12 := {}
	oGetDados12:= MsNewGetDados():New(nLiIni,nCo1,nLiFim,nCo2,0,{|| },"AllwaysTrue","",aAltera,,9999,"AllwaysTrue","","AllwaysTrue",oPanel,aHeader12,aCols12) //30,5,356.80,713.60
	_fColBrw12(oGetDados12, aCols12)		//cria massa de dados para a getdados
	oGetDados12:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

Return

//===================================================================================//
// MONTA HEADER E ACOLS PARA A GRID DA CENA.1 e CENA.2 DA ÁRVORE TABELAS
//===================================================================================//
/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ _fHeader() - Monta aHeader da MsNewGetDados
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function _fHeader(aHeader,noBrw,cTipo)

	noBrw++
	Aadd(aHeader, {;
		"Ano",;			//X3Titulo()
		"ANO",;  		//X3_CAMPO
		"@!",;	   		//X3_PICTURE
		04,;			//X3_TAMANHO
		0,;				//X3_DECIMAL
		"",;			//X3_VALID
		"",;			//X3_USADO
		"C",;			//X3_TIPO
		"",; 			//X3_F3
		"R",;			//X3_CONTEXT
		"",;			//X3_CBOX
		"",;			//X3_RELACAO
		""})			//X3_WHEN

	noBrw++
	Aadd(aHeader, {;
		"Mês",;			//X3Titulo()
		"MES",;  		//X3_CAMPO
		"@!",;	   		//X3_PICTURE
		20,;			//X3_TAMANHO
		0,;				//X3_DECIMAL
		"",;			//X3_VALID
		"",;			//X3_USADO
		"C",;			//X3_TIPO
		"",; 			//X3_F3
		"R",;			//X3_CONTEXT
		"",;			//X3_CBOX
		"",;			//X3_RELACAO
		""})			//X3_WHEN

	If cTipo == "11"
		noBrw++
		Aadd(aHeader, {;
			"Tipo",;		//X3Titulo()
			"TIPO",;  		//X3_CAMPO
			"@!",;	   		//X3_PICTURE
			08,;			//X3_TAMANHO
			0,;				//X3_DECIMAL
			"",;			//X3_VALID
			"",;			//X3_USADO
			"C",;			//X3_TIPO
			"",; 			//X3_F3
			"R",;			//X3_CONTEXT
			"",;			//X3_CBOX
			"",;			//X3_RELACAO
			""})			//X3_WHEN
	Endif

	noBrw++
	Aadd(aHeader, {;
		"Qtd. Notas",;		//X3Titulo()
		"QUANTIDADE",;  	//X3_CAMPO
		"@E 999999 ",;		//X3_PICTURE
		6,;					//X3_TAMANHO
		0,;		   			//X3_DECIMAL
		"",;				//X3_VALID
		"",;		   		//X3_USADO
		"N",;				//X3_TIPO
		"",;				//X3_F3
		"R",;				//X3_CONTEXT
		"",;				//X3_CBOX
		"",;				//X3_RELACAO
		""})				//X3_WHEN

	noBrw++
	Aadd(aHeader, {;
		"Valor Total",;				//X3Titulo()
		"VALORTOTAL",;  			//X3_CAMPO
		"@E 999,999,999.99 ",;		//X3_PICTURE
		9,;							//X3_TAMANHO
		2,;							//X3_DECIMAL
		"",;						//X3_VALID
		"",;						//X3_USADO
		"N",;						//X3_TIPO
		"",;						//X3_F3
		"R",;						//X3_CONTEXT
		"",;						//X3_CBOX
		"",;						//X3_RELACAO
		""})		   				//X3_WHEN

Return



//====================================================================//
//Monta massa de dados para painel Cena.1
//====================================================================//
Static Function _fColBrw11(oGetDados11, aCols11)

	Local nCont  := 0
	Local cQuery1:= ""

	cQuery1 := " SELECT
	cQuery1 += "  YEAR("+xZBZ+"_DTNFE ) AS ANO,  "				+ CHR(13) + CHR(10)
	cQuery1 += "   CASE datepart ( MONTH,  "+xZBZ+"_DTNFE ) "	+ CHR(13) + CHR(10)
	cQuery1 += "     WHEN 1  THEN 'JANEIRO' "					+ CHR(13) + CHR(10)
	cQuery1 += "     WHEN 2  THEN 'FEVEREIRO' "					+ CHR(13) + CHR(10)
	cQuery1 += "     WHEN 3  THEN 'MARÇO' "						+ CHR(13) + CHR(10)
	cQuery1 += "     WHEN 4  THEN 'ABRIL' "						+ CHR(13) + CHR(10)
	cQuery1 += "     WHEN 5  THEN 'MAIO' "						+ CHR(13) + CHR(10)
	cQuery1 += "     WHEN 6  THEN 'JUNHO' "						+ CHR(13) + CHR(10)
	cQuery1 += "     WHEN 7  THEN 'JULHO' "						+ CHR(13) + CHR(10)
	cQuery1 += "     WHEN 8  THEN 'AGOSTO' "					+ CHR(13) + CHR(10)
	cQuery1 += "     WHEN 9  THEN 'SETEMBRO' "					+ CHR(13) + CHR(10)
	cQuery1 += "     WHEN 10 THEN 'OUTUBRO' "					+ CHR(13) + CHR(10)
	cQuery1 += "     WHEN 11 THEN 'NOVEMBRO' "					+ CHR(13) + CHR(10)
	cQuery1 += "     WHEN 12 THEN 'DEZEMBRO' "					+ CHR(13) + CHR(10)
	cQuery1 += "   END MES, "							   		+ CHR(13) + CHR(10)
	//cQuery1 += " "+xZBZ+"_MODELO AS MODELO, "					+ CHR(13) + CHR(10)
	cQuery1 += " CASE " 										+ CHR(13) + CHR(10)
	cQuery1 += "  WHEN "+xZBZ+"_MODELO = '55' "			   		+ CHR(13) + CHR(10)
	cQuery1 += "    THEN 'NFE' "								+ CHR(13) + CHR(10)
	cQuery1 += "  WHEN "+xZBZ+"_MODELO = '57' "					+ CHR(13) + CHR(10)
	cQuery1 += "    THEN 'CTE' "								+ CHR(13) + CHR(10)
	cQuery1 += "  WHEN "+xZBZ+"_MODELO = '65' "					+ CHR(13) + CHR(10)
	cQuery1 += "    THEN 'NFCE' "								+ CHR(13) + CHR(10)
	cQuery1 += "  WHEN "+xZBZ+"_MODELO = '67' "					+ CHR(13) + CHR(10)
	cQuery1 += "    THEN 'CTEOS' "								+ CHR(13) + CHR(10)
	cQuery1 += "  WHEN "+xZBZ+"_MODELO = 'RP' "					+ CHR(13) + CHR(10)
	cQuery1 += "    THEN 'NFSE' "					 			+ CHR(13) + CHR(10)
	cQuery1 += "  END MODELO, "						   			+ CHR(13) + CHR(10)

	cQuery1 += " COUNT(*) AS QUANT,  "							+ CHR(13) + CHR(10)
	cQuery1 += " SUM("+xZBZ+"_VLBRUT) AS VALTOT "				+ CHR(13) + CHR(10)

	cQuery1 += " FROM " + RETSQLNAME(xZBZ) + " "+xZBZ+" "		+ CHR(13) + CHR(10)

	cQuery1 += " WHERE D_E_L_E_T_ = '' "						+ CHR(13) + CHR(10)

	cQuery1 += " AND "+xZBZ+"_DTNFE BETWEEN '"+DTOS(dDataDe)+"' AND '"+DTOS(dDataAte)+"' "+ CHR(13) + CHR(10)
	If !Empty(cFornec) .and. !Empty(cLoj)
		cQuery1 += " AND "+xZBZ+"_CODFOR = '" + Alltrim(cFornec) + "' "	+ CHR(13) + CHR(10)
		cQuery1 += " AND "+xZBZ+"_LOJFOR = '" + Alltrim(cLoj) + "' "	+ CHR(13) + CHR(10)
	Endif
	If !Empty(cFilAte)
		cQuery1 += " AND "+xZBZ+"_FILIAL BETWEEN '" + Alltrim(cFilDe) + "' AND '"+ Alltrim(cFilAte) + "' "	+ CHR(13) + CHR(10)
	Endif
	cQuery1 += " GROUP BY datepart ( MONTH,  "+xZBZ+"_DTNFE ), datepart ( YEAR,  "+xZBZ+"_DTNFE ) , " + xZBZ+"_MODELO " + CHR(13) + CHR(10)
	cQuery1 += " ORDER BY datepart ( YEAR,  "+xZBZ+"_DTNFE ) , datepart ( MONTH,  "+xZBZ+"_DTNFE ), " + xZBZ+"_MODELO "
	*/

	//FR - 19/02/2021 - alterar query para não pegar o valor do ZBZ_VLBRUT , mas sim, direto de um parse do xml pois há registros na ZBZ em que o campo de valor está zerado
	cQuery1 := " SELECT
	cQuery1 += "  YEAR("+xZBZ+"_DTNFE ) AS ANO,  "				+ CHR(13) + CHR(10)
	cQuery1 += "   CASE datepart ( MONTH,  "+xZBZ+"_DTNFE ) "	+ CHR(13) + CHR(10)
	cQuery1 += "     WHEN 1  THEN 'JANEIRO' "					+ CHR(13) + CHR(10)
	cQuery1 += "     WHEN 2  THEN 'FEVEREIRO' "					+ CHR(13) + CHR(10)
	cQuery1 += "     WHEN 3  THEN 'MARÇO' "						+ CHR(13) + CHR(10)
	cQuery1 += "     WHEN 4  THEN 'ABRIL' "						+ CHR(13) + CHR(10)
	cQuery1 += "     WHEN 5  THEN 'MAIO' "						+ CHR(13) + CHR(10)
	cQuery1 += "     WHEN 6  THEN 'JUNHO' "						+ CHR(13) + CHR(10)
	cQuery1 += "     WHEN 7  THEN 'JULHO' "						+ CHR(13) + CHR(10)
	cQuery1 += "     WHEN 8  THEN 'AGOSTO' "					+ CHR(13) + CHR(10)
	cQuery1 += "     WHEN 9  THEN 'SETEMBRO' "					+ CHR(13) + CHR(10)
	cQuery1 += "     WHEN 10 THEN 'OUTUBRO' "					+ CHR(13) + CHR(10)
	cQuery1 += "     WHEN 11 THEN 'NOVEMBRO' "					+ CHR(13) + CHR(10)
	cQuery1 += "     WHEN 12 THEN 'DEZEMBRO' "					+ CHR(13) + CHR(10)
	cQuery1 += "   END MES, "							   		+ CHR(13) + CHR(10)
	cQuery1 += " "+xZBZ+"_MODELO  AS ZBZMODELO, " 				+ CHR(13) + CHR(10)
	cQuery1 += " CASE " 										+ CHR(13) + CHR(10)
	cQuery1 += "  WHEN "+xZBZ+"_MODELO = '55' "			   		+ CHR(13) + CHR(10)
	cQuery1 += "    THEN 'NFE' "								+ CHR(13) + CHR(10)
	cQuery1 += "  WHEN "+xZBZ+"_MODELO = '57' "					+ CHR(13) + CHR(10)
	cQuery1 += "    THEN 'CTE' "								+ CHR(13) + CHR(10)
	cQuery1 += "  WHEN "+xZBZ+"_MODELO = '65' "					+ CHR(13) + CHR(10)
	cQuery1 += "    THEN 'NFCE' "								+ CHR(13) + CHR(10)
	cQuery1 += "  WHEN "+xZBZ+"_MODELO = '67' "					+ CHR(13) + CHR(10)
	cQuery1 += "    THEN 'CTEOS' "								+ CHR(13) + CHR(10)
	cQuery1 += "  WHEN "+xZBZ+"_MODELO = 'RP' "					+ CHR(13) + CHR(10)
	cQuery1 += "    THEN 'NFSE' "					 			+ CHR(13) + CHR(10)
	cQuery1 += "  END MODELO, "						   			+ CHR(13) + CHR(10)
	cQuery1 += " ZBZ.R_E_C_N_O_ AS RECZBZ, " 					+ CHR(13) + CHR(10)
	cQuery1 += "  "+xZBZ+"_VLBRUT AS VALTOT "		  			+ CHR(13) + CHR(10)       	//FR - 19/02/2021 - Revisões nas queries que buscam os valores dos XMLs

	cQuery1 += " FROM " + RETSQLNAME(xZBZ) + " ZBZ "			+ CHR(13) + CHR(10)

	cQuery1 += " WHERE D_E_L_E_T_ = '' "						+ CHR(13) + CHR(10)

	cQuery1 += " AND "+xZBZ+"_DTNFE BETWEEN '"+DTOS(dDataDe)+"' AND '"+DTOS(dDataAte)+"' "+ CHR(13) + CHR(10)
	If !Empty(cFornec) .and. !Empty(cLoj)
		cQuery1 += " AND "+xZBZ+"_CODFOR = '" + Alltrim(cFornec) + "' "	+ CHR(13) + CHR(10)
		cQuery1 += " AND "+xZBZ+"_LOJFOR = '" + Alltrim(cLoj) + "' "	+ CHR(13) + CHR(10)
	Endif
	If !Empty(cFilAte)
		cQuery1 += " AND "+xZBZ+"_FILIAL BETWEEN '" + Alltrim(cFilDe) + "' AND '"+ Alltrim(cFilAte) + "' "	+ CHR(13) + CHR(10)
	Endif

	//cQuery1 += " AND ZBZ_MODELO = '65' " //FR - para testes

	cQuery1 += " ORDER BY datepart ( YEAR,  "+xZBZ+"_DTNFE ) , datepart ( MONTH,  "+xZBZ+"_DTNFE ), " + xZBZ+"_MODELO "


	MemoWrite("C:\TEMP\_fColsBrw11.sql", cQuery1)

	If ( SELECT("TRB11") ) > 0
		dbSelectArea("TRB11")
		TRB11->(dbCloseArea())
	EndIf

	TcQuery cQuery1 Alias "TRB11" New

	TRB11->(dbGoTop())

	aCols11 := {}

	If !TRB11->(EOF())
		/*
		Do While TRB11->( !EOF() )
			nCont++

			Aadd(aCols11,Array(noBrw11 + 1))

			aCols11[nCont][1] := TRB11->ANO
			aCols11[nCont][2] := TRB11->MES
			aCols11[nCont][3] := TRB11->MODELO //Tipo
			aCols11[nCont][4] := TRB11->QUANT
			aCols11[nCont][5] := TRB11->VALTOT

			aCols11[nCont][noBrw11 + 1] := .F.

			TRB11->(DbSkip())
		Enddo
		*/

		//FR - 19/02/2021 - alterar query para não pegar o valor do ZBZ_VLBRUT , mas sim, direto de um parse do xml pois há registros na ZBZ em que o campo de valor está zerado
		Do While TRB11->( !EOF() )

			xModelo := TRB11->ZBZMODELO
			xAno    := TRB11->ANO
			xMes    := TRB11->MES
			nValor  := 0
			nQtos   := 0
			nValtot := 0
			While Alltrim(TRB11->ZBZMODELO) == Alltrim(xModelo)

				nValor := TRB11->VALTOT

				DbSelectArea(xZBZ)						//acessa a ZBZ
				(xZBZ)->( Dbgoto(TRB11->RECZBZ) )		//posiciona no registro
				cXml   := ""
				cXml   := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML")))	//para pegar o conteúdo do XML

				//se o campo da ZBZ estiver vazio, faz o parse no xml para obter o valor
				If nValor == 0
					nValor := U_fParseXML( TRB11->ZBZMODELO, cXml ) 		//função faz o parse e retorna o valor bruto do xml
				Endif

				nQtos++				//contator das notas daquele mês
				nValtot += nValor  	//somatório do valor das notas daquele mês

				TRB11->(DbSkip())
			Enddo

			//adiciona no array da getdados por modelo, após contagem dos XMLs e apuração de valor total por modelo:
			nCont++

			Aadd(aCols11,Array(noBrw11 + 1))

			aCols11[nCont][1] := xAno 		//TRB11->ANO
			aCols11[nCont][2] := xMes 		//TRB11->MES
			aCols11[nCont][3] := xModelo 	//TRB11->MODELO
			aCols11[nCont][4] := nQtos  	//TRB11->QUANT
			aCols11[nCont][5] := nValtot   	//TRB11->VALTOT
			aCols11[nCont][noBrw11 + 1] := .F.

			//zera contadores e total
			nQtos   := 0  			//contator das notas daquele mês
			nValtot := 0           	//somatório do valor das notas daquele mês


		Enddo

	EndIf

	//Setar array do aCols do Objeto.
	oGetDados11:SetArray(aCols11,.T.)

	//Atualizo as informações no grid
	oGetDados11:Refresh()

Return Nil

//====================================================================//
//Monta massa de dados para painel Cena.2
//====================================================================//
Static Function _fColBrw12(oGetDados12, aCols12)

	Local nCont  := 0
	Local cQuery1:= ""

	/*
	cQuery1 := " SELECT
	cQuery1 += "  YEAR("+xZBZ+"_DTNFE ) AS ANO,  "				+ CHR(13) + CHR(10)
	cQuery1 += "   CASE datepart ( MONTH,  "+xZBZ+"_DTNFE ) "	+ CHR(13) + CHR(10)
	cQuery1 += "     WHEN 1  THEN 'JANEIRO' "					+ CHR(13) + CHR(10)
	cQuery1 += "     WHEN 2  THEN 'FEVEREIRO' "					+ CHR(13) + CHR(10)
	cQuery1 += "     WHEN 3  THEN 'MARÇO' "						+ CHR(13) + CHR(10)
	cQuery1 += "     WHEN 4  THEN 'ABRIL' "						+ CHR(13) + CHR(10)
	cQuery1 += "     WHEN 5  THEN 'MAIO' "						+ CHR(13) + CHR(10)
	cQuery1 += "     WHEN 6  THEN 'JUNHO' "						+ CHR(13) + CHR(10)
	cQuery1 += "     WHEN 7  THEN 'JULHO' "						+ CHR(13) + CHR(10)
	cQuery1 += "     WHEN 8  THEN 'AGOSTO' "					+ CHR(13) + CHR(10)
	cQuery1 += "     WHEN 9  THEN 'SETEMBRO' "					+ CHR(13) + CHR(10)
	cQuery1 += "     WHEN 10 THEN 'OUTUBRO' "					+ CHR(13) + CHR(10)
	cQuery1 += "     WHEN 11 THEN 'NOVEMBRO' "					+ CHR(13) + CHR(10)
	cQuery1 += "     WHEN 12 THEN 'DEZEMBRO' "					+ CHR(13) + CHR(10)
	cQuery1 += "   END MES, "							   		+ CHR(13) + CHR(10)
	cQuery1 += " COUNT(*) AS QUANT,  "							+ CHR(13) + CHR(10)
	cQuery1 += " SUM("+xZBZ+"_VLBRUT) AS VALTOT "				+ CHR(13) + CHR(10)

	cQuery1 += " FROM " + RETSQLNAME(xZBZ) + " "+xZBZ+" "		+ CHR(13) + CHR(10)

	cQuery1 += " WHERE D_E_L_E_T_ = '' "						+ CHR(13) + CHR(10)

	cQuery1 += " AND "+xZBZ+"_DTNFE BETWEEN '"+DTOS(dDataDe)+"' AND '"+DTOS(dDataAte)+"' "+ CHR(13) + CHR(10)
	If !Empty(cFornec) .and. !Empty(cLoj)
		cQuery1 += " AND "+xZBZ+"_CODFOR = '" + Alltrim(cFornec) + "' "	+ CHR(13) + CHR(10)
		cQuery1 += " AND "+xZBZ+"_LOJFOR = '" + Alltrim(cLoj) + "' "	+ CHR(13) + CHR(10)
	Endif
	If !Empty(cFilAte)
		cQuery1 += " AND "+xZBZ+"_FILIAL BETWEEN '" + Alltrim(cFilDe) + "' AND '"+ Alltrim(cFilAte) + "' "	+ CHR(13) + CHR(10)
	Endif
	cQuery1 += " GROUP BY datepart ( MONTH,  "+xZBZ+"_DTNFE ), datepart ( YEAR,  "+xZBZ+"_DTNFE )  " + CHR(13) + CHR(10)
	cQuery1 += " ORDER BY datepart ( YEAR,  "+xZBZ+"_DTNFE ) , datepart ( MONTH,  "+xZBZ+"_DTNFE ) "
	*/

	//FR - 19/02/2021 - alterar query para não pegar o valor do ZBZ_VLBRUT , mas sim, direto de um parse do xml pois há registros na ZBZ em que o campo de valor está zerado
	cQuery1 := " SELECT
	cQuery1 += "  YEAR("+xZBZ+"_DTNFE ) AS ANO,  "				+ CHR(13) + CHR(10)
	cQuery1 += "   CASE datepart ( MONTH,  "+xZBZ+"_DTNFE ) "	+ CHR(13) + CHR(10)
	cQuery1 += "     WHEN 1  THEN 'JANEIRO' "					+ CHR(13) + CHR(10)
	cQuery1 += "     WHEN 2  THEN 'FEVEREIRO' "					+ CHR(13) + CHR(10)
	cQuery1 += "     WHEN 3  THEN 'MARÇO' "						+ CHR(13) + CHR(10)
	cQuery1 += "     WHEN 4  THEN 'ABRIL' "						+ CHR(13) + CHR(10)
	cQuery1 += "     WHEN 5  THEN 'MAIO' "						+ CHR(13) + CHR(10)
	cQuery1 += "     WHEN 6  THEN 'JUNHO' "						+ CHR(13) + CHR(10)
	cQuery1 += "     WHEN 7  THEN 'JULHO' "						+ CHR(13) + CHR(10)
	cQuery1 += "     WHEN 8  THEN 'AGOSTO' "					+ CHR(13) + CHR(10)
	cQuery1 += "     WHEN 9  THEN 'SETEMBRO' "					+ CHR(13) + CHR(10)
	cQuery1 += "     WHEN 10 THEN 'OUTUBRO' "					+ CHR(13) + CHR(10)
	cQuery1 += "     WHEN 11 THEN 'NOVEMBRO' "					+ CHR(13) + CHR(10)
	cQuery1 += "     WHEN 12 THEN 'DEZEMBRO' "					+ CHR(13) + CHR(10)
	cQuery1 += "   END MES, "							   		+ CHR(13) + CHR(10)
	cQuery1 += " "+xZBZ+"_MODELO  AS ZBZMODELO, " 				+ CHR(13) + CHR(10)
	cQuery1 += " ZBZ.R_E_C_N_O_ AS RECZBZ " 					+ CHR(13) + CHR(10)

	cQuery1 += " FROM " + RETSQLNAME(xZBZ) + " "+xZBZ+" "		+ CHR(13) + CHR(10)

	cQuery1 += " WHERE D_E_L_E_T_ = '' "						+ CHR(13) + CHR(10)

	cQuery1 += " AND "+xZBZ+"_DTNFE BETWEEN '"+DTOS(dDataDe)+"' AND '"+DTOS(dDataAte)+"' "+ CHR(13) + CHR(10)
	If !Empty(cFornec) .and. !Empty(cLoj)
		cQuery1 += " AND "+xZBZ+"_CODFOR = '" + Alltrim(cFornec) + "' "	+ CHR(13) + CHR(10)
		cQuery1 += " AND "+xZBZ+"_LOJFOR = '" + Alltrim(cLoj) + "' "	+ CHR(13) + CHR(10)
	Endif
	If !Empty(cFilAte)
		cQuery1 += " AND "+xZBZ+"_FILIAL BETWEEN '" + Alltrim(cFilDe) + "' AND '"+ Alltrim(cFilAte) + "' "	+ CHR(13) + CHR(10)
	Endif

	cQuery1 += " ORDER BY datepart ( YEAR,  "+xZBZ+"_DTNFE ) , datepart ( MONTH,  "+xZBZ+"_DTNFE ) "

	MemoWrite("C:\TEMP\_fColsBrw12.sql", cQuery1)
	//FR - 10/12/2020

	If ( SELECT("TRB12") ) > 0
		dbSelectArea("TRB12")
		TRB12->(dbCloseArea())
	EndIf

	TcQuery cQuery1 Alias "TRB12" New

	TRB12->(dbGoTop())

	aCols12 := {}

	If !TRB12->(EOF())

		Do While TRB12->( !EOF() )

			xAno    := Str(TRB12->ANO)
			xMes    := TRB12->MES
			nValor  := 0
			nQtos   := 0
			nValtot := 0

			While Alltrim( Str(TRB12->ANO) + TRB12->MES) == Alltrim(xAno + xMes)

				DbSelectArea(xZBZ)						//acessa a ZBZ
				(xZBZ)->( Dbgoto(TRB12->RECZBZ) )		//posiciona no registro
				cXml   := ""
				cXml   := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML")))	//para pegar o conteúdo do XML
				nValor := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"VLBRUT")))

				//se o campo da ZBZ estiver vazio, faz o parse no xml para obter o valor
				If nValor == 0
					nValor := U_fParseXML( TRB12->ZBZMODELO, cXml ) 		//função faz o parse e retorna o valor bruto do xml
				Endif

				nQtos++					//contator das notas daquele mês
				nValtot += nValor		//somatório do valor das notas daquele mês

				TRB12->(DbSkip())
			Enddo


			nCont++

			Aadd(aCols12,Array(noBrw12 + 1))

			aCols12[nCont][1] := xAno 		//TRB12->ANO
			aCols12[nCont][2] := xMes 		//TRB12->MES
			aCols12[nCont][3] := nQtos 		//TRB12->QUANT
			aCols12[nCont][4] := nValtot 	//TRB12->VALTOT

			aCols12[nCont][noBrw12 + 1] := .F.

			//zera contadores e total
			nQtos   := 0  			//contator das notas daquele mês
			nValtot := 0           	//somatório do valor das notas daquele mês

		Enddo

	EndIf

	//Setar array do aCols do Objeto.
	oGetDados12:SetArray(aCols12,.T.)

	//Atualizo as informações no grid
	oGetDados12:Refresh()

Return Nil

//=====================================================================//
//Função  : fExpEXCL
//Autoria : Flávia Rocha
//Data    : 26/12/2020
//Objetivo: Prepara e Exporta os dados de tela para Excel
//=====================================================================//
Static Function fExpEXCL(lSohXML,nTipo)
	Local aParams   := {}
	Local aNFs      := {}

	Local cNotaDe   := ""
	Local cNotaTe   := "ZZZZZZZZZ"

	Local cSeriDe   := ""
	Local cSeriAte  := "ZZZ"

	Local cFornDe   := ""
	Local cFornAte  := ""

	Local cLojDe    := ""
	Local cLojAte   := ""

	If !Empty(cFornec)
		cFornDe := cFornec
		cFornAte:= cFornec
		cLojDe  := cLoj
		cLojAte := cLoj
	Else
		cFornDe := ""
		cFornAte:= "ZZZZZZ"
		cLojDe  := ""
		cLojAte := "ZZ"
	Endif

	Aadd(aNFs , { cNotaDe, cSeriDe , cFornDe , cLojDe  } )
	Aadd(aNFs , { cNotaTe, cSeriAte, cFornAte, cLojAte } )

	/*
nTipo é o Tipo do Gráfico, numerado conforme a árvore:
Graf.1 - Quantidade x Valor x Tipos de Notas
Graf.2 - Quantidade x Status XML
Graf.3 - Valores x Tipo XML Mês
Graf.4 - Quantidade x Eventos
Graf.5 - Valor x Impostos XML
Graf.6 - Valor de Impostos x XML x Entrada
	*/

	fPovoaPar(@aParams,aNFs)

	//lSohXML -> esta variável virá = .T. qdo os dados de origem (query) tiverem apenas registros da tabela ZBZ, quando os dados de origem tiver join com a tabela SF1/SD1, esta variável
	//virá = .F. , ou seja, não é só XML, tem tb NF
	U_HFXMLR18(aParams, , , lSohXML,nTipo)     //(aParams,lQuery,lDiverg,lSohXML,nTipoGraf)   //lSohXML se for .T. indica que será impresso apenas as linhas referentes ao XML, SEM a linha adicional relativa ao registro da SD1

Return
//=====================================================================//
//Função  : fPovoaPar
//Autoria : Flávia Rocha
//Objetivo: Montar o array para a rotina que chama o relatório em Excel
//Data    : 26/12/2020
//=====================================================================//
Static Function fPovoaPar(aParams,aNFs)		//povoa o array de parâmetros para o relatório
	Local xFiliXMLDe := ""
	Local xFiliXMLAte:= ""
	Local xEmissaoDe := Ctod("  /  /    ")
	Local xEmissaoAte:= Ctod("31/12/2099")
	Local xSerieDe   := ""
	Local xSerieAte  := ""
	Local xDoctoDe   := ""
	Local xDoctoAte  := ""
	Local xCodFornDe := ""
	Local xCodFornAte:= ""
	Local xLojFornDe := ""
	Local xLojFornAte:= ""

	If !Empty(cFilAte)
		xFiliXMLDe := cFilDe
		xFiliXMLAte:= cFilAte
	Else
		xFiliXMLDe := ""
		xFiliXMLAte:= "ZZ"
	Endif

	If !Empty(dDataAte)
		xEmissaoDe := dDataDe
		xEmissaoAte:= dDataAte
	Endif

	xSerieDe   := aNFs[1,2]
	xSerieAte  := aNFs[len(aNFs),2]

	xDoctoDe   := aNFs[1,1]
	xDoctoAte  := aNFs[len(aNFs),1]

	xCodFornDe := aNFs[1,3]
	xCodFornAte:= aNFs[len(aNFs),3]

	xLojFornDe := aNFs[1,4]
	xLojFornAte:= aNFs[len(aNFs),4]

	/*01*/Aadd(aParams , xFiliXMLDe  )
	/*02*/Aadd(aParams , xFiliXMLAte )
	/*03*/Aadd(aParams , xEmissaoDe  )
	/*04*/Aadd(aParams , xEmissaoAte )
	/*05*/Aadd(aParams , xSerieDe    )
	/*06*/Aadd(aParams , xSerieAte   )
	/*07*/Aadd(aParams , xDoctoDe    )
	/*08*/Aadd(aParams , xDoctoAte   )
	/*09*/Aadd(aParams , ''		     )
	/*10*/Aadd(aParams , ''		     )
	/*11*/Aadd(aParams , ''          )
	/*12*/Aadd(aParams , xCodFornDe  )
	/*13*/Aadd(aParams , xCodFornAte )
	/*14*/Aadd(aParams , xLojFornDe  )
	/*15*/Aadd(aParams , xLojFornAte )
	/*16*/Aadd(aParams , ''       )
	/*17*/Aadd(aParams , ''       )
	/*18*/Aadd(aParams , ''       )
	/*19*/Aadd(aParams , xEmissaoDe  )
	/*20*/Aadd(aParams , xEmissaoAte )
	/*21*/Aadd(aParams , 5        )
	/*22*/Aadd(aParams , ""       )
	/*23*/Aadd(aParams , "ZZZZ"   )
	/*24*/Aadd(aParams , 2        )
	/*25*/Aadd(aParams , 1        )
	/*26*/Aadd(aParams , 1        )
	

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ CALCTELA ³ Autor ³ Flávia Rocha          ³ Data ³30/03/2020³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Calcula o tamanho da tela de acordo com a resolução        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC FUNCTION CALCTELA()
	//-------------------------------------------------------//
	//Retorna area de trabalho e coordenadas para janela
	//-------------------------------------------------------//
	aSIZE := MsAdvSize(.T.)
	// .T. se tera enchoicebar
	* Retorno:
	* 1 Linha inicial area trabalho.
	* 2 Coluna inicial area trabalho.
	* 3 Linha final area trabalho.
	* 4 Coluna final area trabalho.
	* 5 Coluna final dialog (janela).
	* 6 Linha final dialog (janela).
	* 7 Linha inicial dialog (janela).

	//--------------------------------------------------------------------------------------//
	//Contera parametros utilizados para calculo de posicao usadas pelo objetos na tela
	//--------------------------------------------------------------------------------------//
	aObjects := {}

	AAdd( aObjects, { 0, 95, .T., .F., .F. } ) // Coordenadas para o ENCHOICE
	// largura
	// altura
	// .t. permite alterar largura
	// .t. permite alterar altura
	// .t. retorno: linha, coluna, largura, altur
	//     OU
	// .f. retorno: linha, coluna, linha, coluna

	AAdd( aObjects, { 0, 0, .T., .T., .F. } ) // Coordenadas para o MSGETDADOS
	// largura
	// altura
	// .t. permite alterar largura
	// .f. NAO permite alterar altura ***
	// .t. retorno: linha, coluna, largura, altura
	//     OU
	// .f. retorno: linha, coluna, linha, coluna


	AAdd( aObjects, { 0, 60, .T., .F., .T. } ) // Coordenadas para o FOLDER
	// largura
	// altura
	// .t. permite alterar largura
	// .f. NAO permite alterar altura ***
	// .t. retorno: linha, coluna, largura, altura
	//     OU
	// .f. retorno: linha, coluna, linha, coluna

	//-------------------------------------------------------------------//
	//Informacoes referente a janela que serao passadas ao MsObjSize
	//-------------------------------------------------------------------//
	aInfo := { aSize[1], aSize[2], aSize[3], aSize[4], 3, 3 }
	// aSize[1] LI
	// aSize[2] CI
	// aSize[3] LF
	// aSize[4] CF
	// 3        separacao horizontal
	// 3        separacao vertical

	aPos  := MsObjSize( aInfo, aObjects )

	// {  {} , {} , {} }

	// aPos - array bidimensional, cada elemento sera um array com as coordenadas
	// para cada objeto
	//
	// 1 -> Linha inicial        aObjects[ N , 5 ] ==== .F.
	// 2 -> Coluna inicial
	// 3 -> Linha final
	// 4 -> Coluna final
	//
	// ou
	//
	// 1 -> Linha inicial        aObjects[ N , 5 ] ==== .T.
	// 2 -> Coluna inicial
	// 3 -> Largura X
	// 4 -> Altura Y

RETURN
//=====================================================================//
//Função  : fParseXML
//Autoria : Flávia Rocha
//Objetivo: Faz o parse do xml e retorna o valor bruto correspondente
//          ao valor da nf
//Data    : 19/02/2021
//=====================================================================//
User Function fParseXML( xModelo, cXml, xImp )
	Local nRetorno := 0
	Local nVLLIQ   := 0
	Local nVLDESC  := 0
	Local nVLIMP   := 0
	Local nVLBRUT  := 0
	Local nVLIPI   := 0
	Local nVLICM   := 0
	Local nVLST    := 0
	Local nVLPIS   := 0
	Local nVLCOF   := 0
	Local oXml
	Local cError   := ""
	Local cWarning := ""
	Local nI := 1

	oXml := XmlParser( cXml, "_", @cError, @cWarning )

	If Empty(cError) .And. Empty(cWarning) .And. oXml <> Nil

		If xModelo $ "55/65"
			//----------------------------//
			//VALOR LÍQUIDO DA MERCADORIA
			//----------------------------//
			nVLLIQ  := 0
			cTagAux := "oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_vProd:TEXT"

			//If type(cTagAux) <> "U"
			nVLLIQ := noRound( Val( &(cTagAux) ), 2)
			//Endif

			nVLDESC := 0
			cTagAux := "oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_vDesc:TEXT"

			//If type(cTagAux) <> "U"
			nVLDESC := noRound( Val( &(cTagAux) ), 2)
			//Endif

			//----------------------------//
			//VALOR ICM
			//----------------------------//
			nVLICM := 0
			cTagAux := "oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_vICMS:TEXT"
			//If type(cTagAux) <> "U"
			nVLICM += noRound( Val( &(cTagAux) ), 2 )
			//Endif

			//----------------------------//
			//VALOR ICM ST
			//----------------------------//
			nVLST := 0
			cTagAux := "oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_vST:TEXT"
			//If type(cTagAux) <> "U"
			nVLST += noRound( Val( &(cTagAux) ), 2 )
			//Endif

			cTagAux := "oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_vII:TEXT"
			//If type(cTagAux) <> "U"
			nVLIMP += noRound( Val( &(cTagAux) ), 2 )
			//Endif

			//----------------------------//
			//VALOR IPI
			//----------------------------//
			cTagAux := "oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_vIPI:TEXT"
			//If type(cTagAux) <> "U"
			nVLIPI += noRound( Val( &(cTagAux) ), 2 )
			//Endif

			//----------------------------//
			//VALOR PIS
			//----------------------------//
			cTagAux := "oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VPIS:TEXT"
			//If type( cTagAux ) <> "U"
			nVLPIS += noRound( Val( &(cTagAux) ) ,2 )
			//Endif

			//----------------------------//
			//VALOR COFINS
			//----------------------------//
			cTagAux := "oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VCOFINS:TEXT"
			//If type( cTagAux ) <> "U"
			nVLCOF += noRound( Val( &(cTagAux) ) ,2 )
			//Endif

			//----------------------------//
			//VALOR BRUTO DA MERCADORIA
			//----------------------------//
			nVLBRUT  := 0
			cTagAux := "oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VNF:TEXT"
			//If type(cTagAux) <> "U"
			nVLBRUT += noRound( Val( &(cTagAux) ), 2)
			//Endif

		ElseIf xModelo == "57"

			nVLLIQ  := 0
			nVLDESC := 0
			nVLIMP  := 0
			nVlCarga:= 0

			cTagAux := "oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP"

			If type(cTagAux) <> "U"

				oDet := oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP
				oDet := iif( ValType(oDet) == "O", {oDet}, oDet )

				For nI := 1 to Len( oDet )

					If "DESC" $ AllTRim( oDet[nI]:_XNOME:TEXT ) .OR. "DESCONTO" $ AllTRim( oDet[nI]:_XNOME:TEXT )
						nVLDESC += noRound( Val(oDet[nI]:_VCOMP:TEXT), 2)
					ElseIf "IPI" $ AllTRim( oDet[nI]:_XNOME:TEXT ) .OR. "ICM" $ AllTRim( oDet[nI]:_XNOME:TEXT )
						nVLIMP += noRound( Val(oDet[nI]:_VCOMP:TEXT), 2)
					Else
						nVLLIQ += noRound( Val(oDet[nI]:_VCOMP:TEXT), 2)
					EndIf

				Next nI

			Endif

			nVLBRUT := 0
			cTagAux := "oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_VTPREST:TEXT"

			If type(cTagAux) <> "U"
				nVLBRUT := noRound( Val( &(cTagAux) ), 2)
			Endif

			//Melhoria da Belenzier pneu para incluir o campo de valor total da carga
			cTagVCarga := "oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_VCARGA:TEXT"

			If Type(cTagVCarga) <> "U"

				nVlCarga := noRound( Val( &(cTagVCarga) ), 2)

			Endif

		Elseif xModelo = "RP"

			nVLBRUT  := 0
			cTagAux := "oXml:_NFSETXT:_INFPROC:_VRSERV:TEXT"
			//If type(cTagAux) <> "U"
			nVLBRUT := noRound( Val( &(cTagAux) ), 2)
			//Endif

		Endif

	Endif		//If Empty(cError) .And. Empty(cWarning) .And. !lInvalid .And. oXml <> Nil

	If xImp == Nil
		nRetorno := nVLBRUT
	Elseif xImp == "ICM"
		nRetorno := nVLICM
	Elseif xImp == "IPI"
		nRetorno := nVLIPI
	Elseif xImp == "COF"
		nRetorno := nVLCOF
	Elseif xImp == "ST"
		nRetorno := nVLST
	Elseif xImp == "PIS"
		nRetorno := nVLPIS
	Endif

Return(nRetorno)
//====================================================================================================
// ATUALIZA BASE DE DADOS PARA CARREGAR NOS GRAFICOS
// FUTURA ROTINA PARA EQUALIZAÇÃO DE INFORMAÇÕES ENTRE CAMPOS X TAGS
//====================================================================================================

User Function HFATUBASE()

	Local aPergs   := {}
	Local aRet   := {}
	Local dDataIni := CtoD("  /  /    ")
	Local dDataFim := CtoD("  /  /    ")
	Local codFilDe := Space( TamSX3('A2_FILIAL')[01] )
	Local codFilAt := Space( TamSX3('A2_FILIAL')[01] )


	//PERGUNTA OS PARAMETROS PARA CORREÇÃO

	aAdd(aPergs, {1, "Emissão De",  dDataIni,  "", ".t.", "", ".T.", 80,  .t.})
	aAdd(aPergs, {1, "Emissão Até", dDataFim,  "", ".t.", "", ".T.", 80,  .t.})
	aAdd(aPergs, {1, "Filial De",  codFilDe,  "", ".t.", "SM0", ".T.", 40,  .f.})
	aAdd(aPergs, {1, "Filial Até", codFilAt,  "", "naovazio()", "SM0", ".T.", 40,  .t.})


	lRet := ParamBox( aPergs , "Atualiza Campos x Tags Impostos - Análise Gráfica" , @aRet , NIL , NIL , .T. )

	if lRet

		dDataIni := mv_par01
		dDataFim := mv_par02
		codFilDe := mv_par03
		codFilAt := mv_par04

		o2Process := MsNewProcess():New({|lEnd| HFPROCBD(dDataIni,dDataFim,codFilDe,codFilAt) },"Aguarde...","Atualizando Dados - Data Analytics",.T.)	//FR - 10/12/2020
		o2Process:Activate()

		//Processa( { || HFPROCBD(dDataIni,dDataFim,codFilDe,codFilAt) }, 'Atualizando Dados - Data Analytics...', 'Aguarde...')


	Else
		Return(lRet)
	Endif

RETURN


Static Function HFPROCBD(dDataIni,dDataFim,codFilDe,codFilAt)

	Local cQuery := ""
	Local 	xVICMS := xVST := xVIPI := xVPIS := xVCOF := nValor := 0
	Local nreg

	cQuery := "  SELECT "+xZBZ+"_ICMVAL AS ICMS, "		+CHR(13) + CHR(10)
	cQuery += " 		"+xZBZ+"_STVALO AS ST, "		+CHR(13) + CHR(10)
	cQuery += " 		"+xZBZ+"_IPIVAL AS IPI, "		+CHR(13) + CHR(10)
	cQuery += " 		"+xZBZ+"_PISVAL AS PIS, "		+CHR(13) + CHR(10)
	cQuery += " 		"+xZBZ+"_COFVAL AS COFVAL, "	+CHR(13) + CHR(10)
	cQuery += " 		"+xZBZ+"_VLBRUT AS VALTOT, "	+CHR(13) + CHR(10)
	cQuery += "         "+xZBZ+"_MODELO AS ZBZMODELO, " +CHR(13) + CHR(10)
	cQuery += " ZBZ.R_E_C_N_O_ AS RECZBZ " 				+CHR(13) + CHR(10)

	cQuery += "  FROM " + RETSQLNAME(xZBZ) + " "+xZBZ+" "  	+CHR(13) + CHR(10)

	cQuery += " WHERE "+xZBZ+".D_E_L_E_T_ <> '*' "			+ CHR(13) + CHR(10)
	cQuery += " AND   "+xZBZ+"_MODELO <> '' " 				+ CHR(13) + CHR(10)
	cQuery += " AND "+xZBZ+"_DTNFE BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' "	+CHR(13) + CHR(10)


	cQuery += " AND "+xZBZ+"_FILIAL BETWEEN '" + Alltrim(codFilDe) + "' AND '"+ Alltrim(codFilAt) + "' "	+ CHR(13) + CHR(10)

	MemoWrite("C:\TEMP\_fAtuBase.sql" , cQuery )
	cQuery := ChangeQuery(cQuery)

	If ( SELECT("TRBATU") ) > 0
		dbSelectArea("TRBATU")
		TRBATU->(dbCloseArea())
	EndIf

	TcQuery cQuery Alias "TRBATU" New

	TRBATU->(dbGoTop())


	/*
	If TRBATU->( !EOF() )

		_vICMS := TRBATU->ICMS
		_vST	:= TRBATU->ST
		_vIPI	:= TRBATU->IPI
		_vPIS	:= TRBATU->PIS
		_vCOFVAL := TRBATU->COFVAL
		_vVALTOT := TRBATU->VALTOT


	Endif
	*/

	If TRBATU->( !EOF() )

		//ProcRegua(TRBATU->(RECCOUNT()))
		o2Process:SetRegua1(TRBATU->(RECCOUNT()))
		o2Process:SetRegua2(TRBATU->(RECCOUNT()))

		While TRBATU->( !EOF() )

			o2Process:IncRegua1("Carregando XML...")
			o2Process:IncRegua2("Lendo regristo "+str(TRBATU->RECZBZ))

			xVICMS:= TRBATU->ICMS
			xVST  := TRBATU->ST
			xVIPI := TRBATU->IPI
			xVPIS := TRBATU->PIS
			xVCOF := TRBATU->COFVAL
			nValor:= TRBATU->VALTOT

			DbSelectArea(xZBZ)						//acessa a ZBZ
			(xZBZ)->( Dbgoto(TRBATU->RECZBZ) )		//posiciona no registro
			cXml   := ""
			cXml   := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML")))	//para pegar o conteúdo do XML

			//se o campo da ZBZ estiver vazio, faz o parse no xml para obter o valor
			If nValor == 0
				nValor := U_fParseXML( TRBATU->ZBZMODELO, cXml ) 		//função faz o parse e retorna o valor bruto do xml
			Endif

			If xVICMS == 0
				xVICMS := U_fParseXML( TRBATU->ZBZMODELO, cXml, "ICM" )
			Endif

			If xVST == 0
				xVST := U_fParseXML( TRBATU->ZBZMODELO, cXml, "ST")
			Endif

			If xVIPI == 0
				xVIPI := U_fParseXML( TRBATU->ZBZMODELO, cXml, "IPI" )
			Endif

			If xVPIS == 0
				xVPIS := U_fParseXML( TRBATU->ZBZMODELO, cXml, "PIS" )
			Endif

			If xVCOF == 0
				xVCOF := U_fParseXML( TRBATU->ZBZMODELO, cXml, "COF")
			Endif

			RecLock((xZBZ), .F.)
			(xZBZ)->(FieldPut(FieldPos(xZBZ+"_ICMVAL"), xVICMS))
			(xZBZ)->(FieldPut(FieldPos(xZBZ+"_STVALO") , xVST ))
			(xZBZ)->(FieldPut(FieldPos(xZBZ+"_IPIVAL") , xVIPI ))
			(xZBZ)->(FieldPut(FieldPos(xZBZ+"_PISVAL") , xVPIS ))
			(xZBZ)->(FieldPut(FieldPos(xZBZ+"_COFVAL") , xVCOF ))
			(xZBZ)->(FieldPut(FieldPos(xZBZ+"_VLBRUT") , nValor ))
			(xZBZ)->(MsUnlock())


			xVICMS := 0
			xVST := 0
			xVIPI := 0
			xVPIS := 0
			xVCOF := 0
			nValor := 0


			TRBATU->(Dbskip())

		Enddo

		MsgInfo("Atualização realizada com sucesso !!!","Finalizado")

	Else
		MsgInfo("Nenhum registro encontrado para o filtro","Alerta")
	Endif


RETURN
