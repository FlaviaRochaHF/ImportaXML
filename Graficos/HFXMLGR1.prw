#include "TbiConn.ch"
#include "Protheus.ch"
#include "rwmake.ch"
#include "fileio.ch"
#Include "TOPCONN.CH"
#INCLUDE "PRCONST.CH"

//-------------------------------------------------------------//
//Função: HFXMLGR1 - Análise Gráfica
//Autor : Henrique Tofanelli
//-------------------------------------------------------------//
//Alterações realizadas:
//FR - 10/12/2020 - Inclusão de novos campos na tela;
//                  Revisão geral das amarrações nas queries
//                  Alterada chamada da função HFXMLGR1
//                  para mostrar regua de processo antes de 
//                  mostrar a tela dos gráficos.        
//-------------------------------------------------------------//
//FR - 14/01/2021 - Melhorias na estética da tela
//                  Solicitado por Rafael Lobitsky
//                  Alterada chamada da função HFXMLGR1
//-------------------------------------------------------------//
//FR - 12/02/2021 - Revisões na estética da tela
//                  Solicitado por Rafael Lobitsky
//-------------------------------------------------------------//
//FR - 19/02/2021 - Revisões nas queries que buscam os valores
//                  dos XMLs
//-------------------------------------------------------------//
//FR - 04/08/2021 - Chamado 11081 - MATILAT
//-------------------------------------------------------------//
User Function HFXMLGR1()

	MsAguarde({|| U_HFXMLGraf()}, "Aguarde...")

Return

//=============================================================//
//HFXMLGraf() - Função Principal geradora da tela dialog que
//              contém os gráficos
//=============================================================//
User Function HFXMLGraf()
	//FR - 10/12/2020
	Local nLiIni := 0
	Local nCoIni := 0
	Local nLiFim := 0
	Local nCoFim := 0
	//FR - 10/12/2020
	
	Private oLayer
	//Declare as variáveis como Private para que elas possam ser utilizadas fora da função principal
	Private oNrOP,oDescProd,oDataDe,oDataAte,oChart,oChart2,oDescUser,oQtdOP,oQtdPro,oQtdPalet,oCodProd,oQtdLanc,oFornec,oLoj,oFilDe,oFilAte
	Private oPainel06
	Private dDataDe := CtoD("  /  /    ")	//FR - 10/12/2020 
	Private dDataAte := LastDate(ddatabase) 
	Private aHeader:= {}
	Private aCols  := {}
	Private aHeader04:= {}
	Private aCols04  := {}
	Private aRand  := {}
	Private aAltera := {oNrOP}
	Private aBotoes := {} //"Fechar Pallet"
	//Private aBotoes := { {"Excluir",{|| _fExcLanc() },"Excluir Apontamento"} }
	Private noBrw1   := 0
	Private noBrw104   := 0

	Private oDlg
	Private oGetDados
	Private oGetDados04

	Private cTotXML:="0"
	Private cTotVlXML := "0.00"
	Private cDatUlt := '00/00/0000'
	Private oSay1
	Private cFornec := Space( TamSX3('A2_COD')[01] )		//FR - 10/12/2020
	Private cFilDe  := Space( TamSX3('A2_FILIAL')[01] )		//FR - 10/12/2020
	Private cFilAte := Space( TamSX3('A2_FILIAL')[01] )		//FR - 10/12/2020
	Private cLoj    := Space( TamSX3('A2_LOJA')[01] )		//FR - 10/12/2020
	Private aObjects:= {}									//FR - 10/12/2020
	Private aSize   := {} //MsAdvSize(.T.)					//FR - 14/01/2021
	Private aInfo   := {}									//FR - 10/12/2020
	Private aPos    := {}									//FR - 10/12/2020

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
	//SetPrvt("oDlg","oGetDados")
	//Private cDescUser := UsrRetName(RetCodUsr()) //LogUserName()
	Static cUserLog :=  RetCodUsr()
	Static cDescUser := UsrFullName ( cUserLog )

	Static nTotCCE   := 0
	//Static c_Eol  := CHR(13)+CHR(10)
	
	CALCTELA() 		//FR - 14/01/2021
	
	//FR - 10/12/2020
	dDataDe := Ctod( "01/01/" + Str(Year(dDatabase)) )

//	dDataDe := Ctod( "01/07/" + Str(Year(dDatabase)) )
    
    //aSIZE   := {0,30,676,298,1352,596,0,5} //FR - TESTE RESOLUCAO
    
    //FR - 14/01/2021 - diminui um pouco a dimensão da dialog:
    /*
    aSize[3] := aSize[3]*0.8
    aSize[4] := aSize[4]*0.8
    aSize[5] := aSize[3]*2
    aSize[6] := aSize[4]*2
    */  //FR - para testar
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
    
 	_NomeBotao := "Atualizar"		
 	//FR - 10/12/2020
    
	//========================================//
	//GERA A DIALOG PRINCIPAL                   
	//========================================//
	nLiIni := aSize[7]
	nCoIni := 0
	nLiFim := aSize[6] + 100
	nCoFim := aSize[5]
	nAlt1 := 0
	nAlt2 := 0
	nAlt3 := 0

	nLarg1 := 0
	nLarg2 := 0
	nLarg3 := 0
	nLarg4 := 0
	nLarg5 := 0
	nLarg6 := 0
	
	//aSIZE   := {0,30,676,298,1352,596,0,5} //FR - TESTE RESOLUCAO
	
	nAlt1 := aSize[2]-10	//30-10=20
	nAlt2 := aSize[2]+15   	//30+15=45
	nAlt3 := aSize[2]-5		//30-5=25  //total de altura: 20+45+25=90
	
	nLarg1 := aSize[2]/2		//30/2=15
	nLarg2 := aSize[2]			//30
	nLarg3 := aSize[2]+10		//30+10 = 40
	nLarg4 := aSize[2]+20		//30+20 = 50
	nLarg5 := aSize[2]+30      	//30+30 = 60
	nLarg6 := aSize[2]+40      	//30+40 = 70
	nLarg7 := aSize[2]+50      	//30+50 = 80
	
	//DEFINE MSDIALOG oDlg FROM 000,000 TO 500,500 PIXEL TITLE "FWLayer"
	//DEFINE MSDIALOG oDlg TITLE "Data Analytics - GestaoXML" FROM 000,000 TO 610,1300 COLORS 0, 16777215 PIXEL	
	Define MsDialog oDlg TITLE "Data Analytics - GestaoXML" STYLE DS_MODALFRAME From nLiIni,nCoIni To nLiFim,nCoFim OF oMainWnd PIXEL      //FR - 10/12/2020
	
	oLayer := FWLayer():New()
	//oLayer:Init( oDlg, .F. )
	oLayer:init( oDlg,.T.)
	
	oLayer:AddLine( "LINE01", nAlt1, .t. )		//20 Altura da linha
	oLayer:AddLine( "LINE02", nAlt2, .t. )		//45 Altura da linha	
	oLayer:AddLine( "LINE03", nAlt3, .t. )		//22 Altura da linha		
	
	//Coloca o botão de split na colunao
	//oLayer:setColSplit('LINE03',CONTROL_ALIGN_RIGHT,,{|| Alert("Split Col01!") })
	
	//(1) Filtros do Período
	oLayer:AddCollumn( "BOX01", nLarg7+19.5,.t., "LINE01" )  	//99.5 - Largura
    
	//(2) Tipos de Notas
	//oLayer:AddCollumn( "BOX02", nLarg5,.t., "LINE02" )			//60 - Largura
	oLayer:AddCollumn( "BOX02", nLarg4-0.5,.t., "LINE02" )			//49.5 - Largura
		
	//(3) Quantidade - Mês
	oLayer:AddCollumn( "BOX03", (nLarg4 - 0.2),.t., "LINE02" ) 		//49.8 - Largura
    
	//(4) Valores - Mês
	oLayer:AddCollumn( "BOX04", nLarg2+4,.t., "LINE03" )			//34 - Largura  33,16
	
	//(5) Top 10 - Entidades
	oLayer:AddCollumn( "BOX05", nLarg2+4,.t., "LINE03" )				//34 - Largura  33,16
	
	//(6) Total XML's
	oLayer:AddCollumn( "BOX06", (nLarg2 +1.5),.t., "LINE03" )  		//31.5 - Largura 31.5	
	
	//informações de cabeçalho:
	oLayer:AddWindow( "BOX01", "PANEL01", "(1) Filtros do Período" , nLarg7+20, .F.,,, "LINE01" )    	//100 - Largura FR - 14/01/2021
	
	//gráficos
	oLayer:AddWindow( "BOX02", "PANEL02", "(2) Tipos de Notas"     , nLarg7+20, .t.,,, "LINE02" ) 		//100 - Largura FR - 14/01/2021
	oLayer:AddWindow( "BOX03", "PANEL03", "(3) Quantidades - Mês"  , nLarg7+20, .t.,,, "LINE02" )		//100 - Largura FR - 14/01/2021
	
	//getdados
	oLayer:AddWindow( "BOX04", "PANEL04", "(4) Valores - Mês"      , nLarg7+20, .t.,,, "LINE03" )		//100 - Largura FR - 14/01/2021
	oLayer:AddWindow( "BOX05", "PANEL05", "(5) Top 10 - Entidades"  , nLarg7+20, .t.,,, "LINE03" )		//100 - Largura FR - 14/01/2021
	
	//box final info:
	oLayer:AddWindow( "BOX06", "PANEL06", "(6) Total XML´s "       , nLarg7+20, .t.,,, "LINE03" ) 		//100 - Largura FR - 14/01/2021

	//Chama as funções para cada painel:
	//(1) Filtros do período
	FPanelCab( oDlg, oLayer:GetWinPanel( "BOX01", "PANEL01", "LINE01" ) , aInfo ) //Estou passando para a função o método que retorna o objeto do painel da Janela //FR - 10/12/2020

	//(2) Tipos de Notas
	FPanelTPNF( oLayer:GetWinPanel( "BOX02", "PANEL02", "LINE02" ) , aInfo )  		//FR - 14/01/2021
		
	//(3) Quantidades - Mês
	FPanelQTM( oLayer:GetWinPanel( "BOX03", "PANEL03", "LINE02" ) )

	//(4) Valores - Mês 
	FPanelVLM( oLayer:GetWinPanel( "BOX04", "PANEL04", "LINE03" ) , aObjects )		//FR - 14/01/2021

	//(5) Top 10 - Entidades
	FPanelTPE( oLayer:GetWinPanel( "BOX05", "PANEL05", "LINE03" ) , aObjects ) 		//FR - 14/01/2021
	
	ValiDados(aInfo)  																//FR - 14/01/2021	

	//(6) Total XML´s
	FPanelInfo( oLayer:GetWinPanel( "BOX06", "PANEL06", "LINE03" ) , aInfo )
	oPainel06 := oLayer:GetWinPanel( "BOX06", "PANEL06", "LINE03" )
	
	ACTIVATE MSDIALOG oDlg CENTERED
	
Return
           
//===================================================//
//Painel Filtros do Período
//Campos: Data Inicial / Final , Fornecedor/Loja
//===================================================//
Static Function FPanelCab( oDlg, oPanel, aInfo ) //A função recebe o objeto da janela

	//FR - 10/12/2020
	Local nLiIni  := 0
	Local nCo1 := aInfo[1] +6 	//0+6=6							//aSize[8]   		//5	   //FR - 14/01/2021
	Local nCo2 := aInfo[2] * 2 	//30 * 2 = 60					//aSize[2] * 2		//60   //FR - 14/01/2021
	Local nCo3 := nCo2 + 60 	//60 +60=120 					//aSize[6] - 598.6  //115  //FR - 14/01/2021
	Local nCo4 := nCo3 + 60 	//120+60=180 					//aSize[6] - 558.6  //155  //FR - 14/01/2021
	Local nCo5 := nCo4 + 60 	//180+60=240					//aSize[6] - 513.6  //200  //FR - 14/01/2021   
	Local nCo6 := nCo5 + 60 	//240+60=300					//aSize[6] - 403.6  //310  //FR - 14/01/2021
	Local nCo7 := nCo6 + 60 	//300+60=360					//aSize[6] - 333.6  //380  //FR - 14/01/2021
	Local nCo8 := nCo7 + 60 	//360+60=420					//aSize[6] - 113.6  //600  //FR - 14/01/2021
	Local nCo9 := nCo8 + 60		//420+60=480
	//-------------------------------------------------------------------//
	//Informacoes referente a janela que serao passadas ao MsObjSize
	//-------------------------------------------------------------------//
	//aInfo := { aSize[1], aSize[2], aSize[3], aSize[4], 3, 3 } 	
	// aSize[1] LI    //0
	// aSize[2] CI    //30
	// aSize[3] LF    //953
	// aSize[4] CF    //446 
	// 3        separacao horizontal  
	// 3        separacao vertical
	
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

	oDataDe  := TGet():New( nLiIni, nCo1,bSetGet(dDataDe) ,oPanel,050,010,'@D',{||  },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.   ,,dtos(dDataDe) ,,,,,,,"Data Inicial",1 )
	oDataAte := TGet():New( nLiIni, nCo2,bSetGet(dDataAte),oPanel,050,010,'@D',{||  },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.   ,,dtos(dDataAte),,,,,,,"Data Final",1 )
	
	oFornec  := TGet():New( nLiIni, nCo3,bSetGet(cFornec) ,oPanel,050,010,'@X',{||  },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.   ,"SA2",cFornec ,,,,,,,"Fornecedor",1 )		//FR - 10/12/2020
	oLoj     := TGet():New( nLiIni, nCo4-10,bSetGet(cLoj)    ,oPanel,030,010,'@X',{||  },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.   ,     ,cLoj    ,,,,,,,"Loja",1 )		//FR - 10/12/2020
	
	oFilDe   := TGet():New( nLiIni, nCo5-20,bSetGet(cFilDe) ,oPanel,050,010,'@X',{||  },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.   ,"SM0",cFornec ,,,,,,,"Filial De",1 )	//FR - 10/12/2020
	oFilAte  := TGet():New( nLiIni, nCo6-25,bSetGet(cFilAte),oPanel,050,010,'@X',{||  },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.   ,"SM0",cLoj    ,,,,,,,"Filial Até",1 )	//FR - 10/12/2020
		
	//Botões	
	oTButton := TButton():New( nLiIni, nCo7-20, _NomeBotao,oPanel,{||Processa({|| ValiDados(aInfo)}, "Analisando Período...")}, 40,18,,,.F.,.T.,.F.,,.F.,,,.F. )	//FR - 14/01/2021
	oTButton := TButton():New( nLiIni, nCo8-20, "Mais Graficos",oPanel,{||MaisGraf()}, 40,18,,,.F.,.T.,.F.,,.F.,,,.F. ) 										//FR - 10/12/2020
	oDescUser:= TGet():New(    nLiIni, nCo9-20,{|u| if(PCount()>0,cDescUser:=u,cDescUser)}   ,oPanel,140, 010,Nil,{||  },0,,,.F.,,.T.,,.F.,{|| .F.},.F.,.F.,,.F.,.F.,"",cDescUser  ,,,,,,,"Usuário",1 )	//FR - 10/12/2020

Return

//================================================//
//Monta o painel (2): Quantidade x Tipos de Notas   
//================================================//
Static Function FPanelTPNF( oPanel, aInfo )
	Local nLiIni := 0
	Local nCoIni := 0
	Local nLiFim := 0
	Local nCoFim := 0
	
	//-------------------------------------------------------------------//
	//Informacoes referente a janela que serao passadas ao MsObjSize
	//-------------------------------------------------------------------//
	//aInfo := { aSize[1], aSize[2], aSize[3], aSize[4], 3, 3 } 	
	// aSize[1] LI    //0
	// aSize[2] CI    //30
	// aSize[3] LF    //953
	// aSize[4] CF    //446 
	// 3        separacao horizontal  
	// 3        separacao vertical
	
	nLiIni := aInfo[1] 		//0
	nCoIni := nLiIni        //0
	nLiFim := nLiIni + 50	//0+50=50
	nCoFim := nLiFim		//50
	

	//oChart := FWChartFactory():New(0,0,50,50)
	oChart := FWChartFactory():New(nLiIni,nCoIni,nLiFim,nCoFim)	//FR - 14/01/2021

	oChart:SetOwner(oPanel)

	//Define o tipo do gráfico
	oChart:SetChartDefault(COLUMNCHART)
	//-----------------------------------------
	// Opções disponiveis
	// RADARCHART
	// FUNNELCHART
	// COLUMNCHART
	// NEWPIECHART
	// NEWLINECHART
	//-----------------------------------------
	
	oChart:addSerie( "NFE"  , 0 )
	oChart:addSerie( "CTE"  , 0 )
	oChart:addSerie( "NFCE" , 0 )
	oChart:addSerie( "NFSE" , 0 )
	oChart:addSerie( "CTEOS", 0 )
	oChart:addSerie( "CCE", 0 )       //FR - 10/12/2020

	//Define as cores que serão utilizadas no gráfico
	aAdd(aRand, {"084,120,164", "007,013,017"})
	aAdd(aRand, {"171,225,108", "017,019,010"})
	aAdd(aRand, {"207,136,077", "020,020,006"})
	aAdd(aRand, {"166,085,082", "017,007,007"})
	aAdd(aRand, {"130,130,130", "008,008,008"})

	//Seta as cores utilizadas
	//     oChart:oFWChartColor:aRandom := aRand
	//     oChart:oFWChartColor:SetColor("Random")
	oChart:SetLegend(CONTROL_ALIGN_LEFT)
	oChart:setTitle("Quantidade x Tipos de Notas", CONTROL_ALIGN_CENTER) //"Oportunidades por fase"
	//oChart:setLegend( CONTROL_ALIGN_LEFT )
	oChart:SetAlignSerieLabel(CONTROL_ALIGN_RIGHT)
	//oChart:Build()
	oChart:Activate()

Return

//=================================//
//Gráfico do painel 03
//=================================//
Static Function FPanelQTM( oPanel )

	oChart2 := FWChartFactory():New(0,0,50,50)
	oChart2:SetOwner(oPanel)

	//Define o tipo do gráfico
	oChart2:SetChartDefault(NEWLINECHART)
	//-----------------------------------------
	// Opções disponiveis
	// RADARCHART
	// FUNNELCHART
	// COLUMNCHART
	// NEWPIECHART
	// NEWLINECHART
	//-----------------------------------------

	//Para graficos multi serie, definir a descricao pelo SetxAxis e passar array no addSerie
	oChart2:SetXAxis( {"Domingo", "Segunda", "Terça", "Quarta", "Quinta", "Sexta", "Sábado"} )

	oChart2:addSerie('Dias', {  0, 0, 0, 0, 0, 0, 0  } )

	/*
	//Define as cores que serão utilizadas no gráfico
	aAdd(aRand, {"084,120,164", "007,013,017"})
	aAdd(aRand, {"171,225,108", "017,019,010"})
	aAdd(aRand, {"207,136,077", "020,020,006"})
	aAdd(aRand, {"166,085,082", "017,007,007"})
	aAdd(aRand, {"130,130,130", "008,008,008"})
	aAdd(aRand, {"207,136,077", "020,020,006"})
	aAdd(aRand, {"130,130,130", "008,008,008"})
	*/
	//Seta as cores utilizadas
	//     oChart:oFWChartColor:aRandom := aRand
	//     oChart:oFWChartColor:SetColor("Random")
	oChart2:SetLegend(CONTROL_ALIGN_LEFT)
	//oChart2:setTitle("Quantidade x Dias da Semana", CONTROL_ALIGN_CENTER) //"Oportunidades por fase"
	oChart2:setTitle("Quantidade x Mês", CONTROL_ALIGN_CENTER) //FR - 10/12/2020
	//oChart:addSerie( "Votos PV", { {"Jan",20}, {"Fev",10}, {"Mar",10} } )
	//oChart:setLegend( CONTROL_ALIGN_LEFT )
	oChart2:SetAlignSerieLabel(CONTROL_ALIGN_RIGHT)
	oChart2:EnableMenu(.f.)
	//oChart:Build()
	oChart2:Activate()

Return

//=================================//
//Getdados do painel 04
//=================================//
Static Function FPanelVLM( oPanel, aObjects ) 
	//FR - 14/01/2021
	Local nLiIni := 0
	Local nCoIni := 0
	Local nLiFim := 0
	Local nCoFim := 0
		
	nLiIni := aObjects[2][1]	//0
	nCoIni := nLiIni			//0
	nLiFim := nLiIni 			//0
	nCoFim := nLiFim			//0 
	//FR - 14/01/2021

	_fHeader04()
	aCols04 := {}
	oGetDados04:= MsNewGetDados():New(nLiIni,nCoIni,nLiFim,nCoFim,0,{|| },"AllwaysTrue","",aAltera,,9999,"AllwaysTrue","","AllwaysTrue",oPanel,aHeader04,aCols04)	//FR - 14/01/2021

	oGetDados04:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

Return


//=================================//
//Getdados do painel 05
//=================================//
Static Function FPanelTPE( oPanel, aObjects ) 
	//FR - 14/01/2021
	Local nLiIni := 0
	Local nCoIni := 0
	Local nLiFim := 0
	Local nCoFim := 0
		
	nLiIni := aObjects[2][1]	//0
	nCoIni := nLiIni			//0
	nLiFim := nLiIni 			//0
	nCoFim := nLiFim			//0
    //FR - 14/01/2021
    
	_fHeader()
	aCols := {}
	oGetDados:= MsNewGetDados():New(nLiIni,nCoIni,nLiFim,nCoFim,0,{|| },"AllwaysTrue","",aAltera,,9999,"AllwaysTrue","","AllwaysTrue",oPanel,aHeader,aCols) //FR - 14/01/2021
	oGetDados:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

Return
//==========================================================//
//Monta painel 06 - Qtde total, Valor e Dt. Último Download
//==========================================================//
Static Function FPanelInfo( oPanel , aInfo )
//Local oDlg2
Local lHtml := .T.
Local cTextHtml := ""
//Local oBtn1, oSay1

//FR - 14/01/2021
Local nLiIni := 0
Local nCoIni := 0
Local nLiFim := 0
Local nCoFim := 0
	
//-------------------------------------------------------------------//
//Informacoes referente a janela que serao passadas ao MsObjSize
//-------------------------------------------------------------------//
//aInfo := { aSize[1], aSize[2], aSize[3], aSize[4], 3, 3 } 	
// aSize[1] LI    //0
// aSize[2] CI    //30
// aSize[3] LF    //953
// aSize[4] CF    //446 
// 3        separacao horizontal  
// 3        separacao vertical

nLiIni := aInfo[1] + 1
nCoIni := nLiIni
nLiFim := nLiIni + 50	//0+50=50
nCoFim := nLiFim		//50
//FR - 14/01/2021	

  //oFont := TFont():New('Courier new',,-18,.T.)
  oFont := TFont():New('Courier new',,-12,.T.)

  cTextHtml := '<hr size="1">'
//  cTextHtml += '<br/>'
  cTextHtml += '<center><font size="6" color="blue"><b>Qtd: '+cTotXML+'</b></font><br/></center>'		//FR - 10/12/2020
  //cTextHtml += '<center><font size="3" color="blue"><b>R$ '+cTotVlXML+'</b></font><br/></center>'
  cTextHtml += '<center><font size="3" color="blue"><b>R$ '+cTotVlXML+'</b></font></center>'
  cTextHtml += '<center><font size="2" color="red">Ult.Download: '+cDatUlt+'</font><br/><center>'
  cTextHtml += '</table>' 
 
//oDlg2 = TDialog():New( 0, 0, 150, 300, "Exemplo" ,oPanel,,,, CLR_BLACK,CLR_WHITE ,,, .T. )
//oSay1 := TSay():New( 25, 05, {|| "1.000"} ,oPanel,,,,,,.T.,,, 60, 20 )
//oSay1 := TSay():New(01,01,{||cTextHtml},oPanel,,oFont,,,,.T.,,,120,90,,,,,,lHtml)
oSay1 := TSay():New(nLiIni,nCoIni,{||cTextHtml},oPanel,,oFont,,,,.T.,,,180,90,,,,,,lHtml)	//FR - 14/01/2021
 
//oBtn1 := TButton():New( 50, 05, "Sair", oDlg2,{|| oDlg2:End() }, 40, 013,,,,.T. )
//oDlg:Activate( , , , .T. )

//GET oGet2 
//VAR cGet2 SIZE 100,10 OF oDlg PIXEL @ 50,10


Return

Static Function ValidaLinG()
	msgInfo("Chamada Grade OK")
Return 

//-------------------------------------------------
// validações de campos
//-------------------------------------------------
Static Function ValiDados(aInfo)

	If empty(dDataDe) .or. empty(dDataAte) .or. dDataAte < dDataDe
		Alert("Datas Incorretas. Favor verificar")
		return()

	Else
		
		_fAtuGraf2()	//(2) Monta legenda do gráfico Quantidade x Tipos de Notas
		_fColsBrw04()	//(3) Gráfico Quantidade Notas x Mês
		_fAtuGraf5()	//(4) Ranking Valores x Mês		
		_fColsBrw()		//(5) Ranking Top 10	
		oDlg.forcerefresh
		oPainel06.oSay1.refresh
		oSay1.forcerefresh	
		FPanelInfo( oLayer:GetWinPanel( "BOX06", "PANEL06", "LINE03" ) , aInfo) //(6) Total XML's	
	EndIf
Return()

//===========================================================================//
//Função  : _fAtuGraf2()
//Autoria : Henrique Tofanelli
//Objetivo: Monta massa de dados para o gráfico por modelo de NFe
//         (2) - (Quantidade x Tipos de Notas)
//===========================================================================// 
Static Function _fAtuGraf2()

	//Alert("Entrou rotina AtuGraf")

	//Uma consulta bem Simples  
	//FR - 10/12/2020
	cQuery := " Select DISTINCT "+xZBZ+"_MODELO AS ZBZ_MODELO, " 	+ CHR(13) + CHR(10)
	cQuery += " Count("+xZBZ+"_MODELO) AS QUANT " 					+ CHR(13) + CHR(10)
	cQuery += " FROM " + RETSQLNAME(xZBZ) + " "+xZBZ+" "			+ CHR(13) + CHR(10)
	cQuery += " WHERE "+xZBZ+".D_E_L_E_T_ <> '*' "					+ CHR(13) + CHR(10)
	cQuery += " AND "+xZBZ+"_MODELO <> '' "   						+ CHR(13) + CHR(10)
	cQuery += " AND "+xZBZ+"_DTNFE BETWEEN '"+DTOS(dDataDe)+"' AND '"+DTOS(dDataAte)+"' "+ CHR(13) + CHR(10) 

	If !Empty(cFornec) .and. !Empty(cLoj)
		cQuery += " AND "+xZBZ+"_CODFOR = '" + Alltrim(cFornec) + "' "	+ CHR(13) + CHR(10)		
		cQuery += " AND "+xZBZ+"_LOJFOR = '" + Alltrim(cLoj) + "' "		+ CHR(13) + CHR(10)
	Endif
	
	If !Empty(cFilAte)  
		cQuery += " AND "+xZBZ+"_FILIAL BETWEEN '" + Alltrim(cFilDe) + "' AND '"+ Alltrim(cFilAte) + "' "	+ CHR(13) + CHR(10)		
	Endif
	cQuery += " GROUP BY "+xZBZ+"_MODELO "	+ CHR(13) + CHR(10)
	cQuery += " ORDER BY "+xZBZ+"_MODELO " 					
	
	MemoWrite("C:\TEMP\fatugraf2.sql" , cQuery)
	//FR - 10/12/2020
	
	cQuery := ChangeQuery(cQuery)				//FR - 04/08/2021 - MATILAT
	If ( SELECT("TRBACD") ) > 0
		dbSelectArea("TRBACD")
		TRBACD->(dbCloseArea())
	EndIf

	TcQuery cQuery Alias "TRBACD" New

	TRBACD->(dbGoTop())

	oChart:DeActivate()

	IF !TRBACD->(EOF()) 
		//FR - 10/12/2020
		nQTCCE_55 := 0	
		nQTCCE_65 := 0	
		nQTCCE_57 := 0	
		nQTCCE_67 := 0
		nQTCCE_RP := 0
		nTotCCE   := 0
				
		cQuery := " SELECT COUNT("+xZBE+"_TPEVE) QTCCE , "	+ CHR(13) + CHR(10)
		cQuery += ""+xZBZ+"_MODELO  AS ZBZMODELO "			+ CHR(13) + CHR(10)
		cQuery += " FROM       " + RetSqlName(xZBE) + " ZBE "	+ CHR(13) + CHR(10)
		
		cQuery += " INNER JOIN " + RetSqlName(xZBZ) + " ZBZ ON "+xZBZ+"_CHAVE = "+xZBE+"_CHAVE AND ZBZ.D_E_L_E_T_ <> '*' "	+ CHR(13) + CHR(10)
		If !Empty(cFornec) .and. !Empty(cLoj)
			cQuery += " AND "+xZBZ+"_CODFOR = '" + Alltrim(cFornec) + "' "	+ CHR(13) + CHR(10)		
			cQuery += " AND "+xZBZ+"_LOJFOR = '" + Alltrim(cLoj) + "' "		+ CHR(13) + CHR(10)
		Endif
		
		cQuery += " WHERE ZBE."+xZBE+"_CHAVE = ZBZ."+xZBZ+"_CHAVE " + CHR(13) + CHR(10)
		cQuery += " AND       "+xZBE+"_TPEVE <> 'HXL069' " 			+ CHR(13) + CHR(10)
		cQuery += " AND       "+xZBE+"_DTRECB BETWEEN '"+DTOS(dDataDe)+"' AND '"+DTOS(dDataAte)+"' "+ CHR(13) + CHR(10)
		
		If !Empty(cFilAte)  
			cQuery += " AND "+xZBE+"_FILIAL BETWEEN '" + Alltrim(cFilDe) + "' AND '"+ Alltrim(cFilAte) + "' "	+ CHR(13) + CHR(10)		
		Endif
		cQuery += " GROUP BY "+xZBZ+"_MODELO "
		
		MemoWrite("C:\TEMP\CCE.sql" , cQuery)	
	
		If ( SELECT("TRBCCE") ) > 0
			dbSelectArea("TRBCCE")
			TRBCCE->(dbCloseArea())
		EndIf

		cQuery := ChangeQuery(cQuery)				//FR - 04/08/2021 - MATILAT
		TcQuery cQuery Alias "TRBCCE" New
		If !TRBCCE->(EOF()) 
			TRBCCE->(Dbgotop())
			While TRBCCE->( !EOF() )
				Do Case 
					//deixei separado, vai que um dia precisam extratificar por modelo x CCE
					Case TRBCCE->ZBZMODELO == '55' 
						nQTCCE_55 := TRBCCE->QTCCE
						 
					Case TRBCCE->ZBZMODELO == '65' 
						nQTCCE_65 := TRBCCE->QTCCE
						
					Case TRBCCE->ZBZMODELO == '57' 
						nQTCCE_57 := TRBCCE->QTCCE
						
					Case TRBCCE->ZBZMODELO == '67'
						nQTCCE_67 := TRBCCE->QTCCE
						
					Case TRBCCE->ZBZMODELO == 'RP' 
						nQTCCE_RP := TRBCCE->QTCCE
						
					Otherwise
				Endcase
				
				TRBCCE->(dbSkip())			
			Enddo
			nTotCCE := nQTCCE_55 + nQTCCE_65 + nQTCCE_57 + nQTCCE_67 + nQTCCE_RP
		Endif		
	
		DbselectArea("TRBACD")
		TRBACD->(Dbgotop())            //FR - 10/12/2020
            
		While TRBACD->( !EOF() )			
                
			Do Case
				Case TRBACD->ZBZ_MODELO == "55"
					oChart:addSerie( "NFE - "+alltrim(str(TRBACD->QUANT)) , TRBACD->QUANT ) 
					
				Case TRBACD->ZBZ_MODELO == "57"
					oChart:addSerie( "CTE - "+alltrim(str(TRBACD->QUANT)) ,  TRBACD->QUANT )
					
				Case TRBACD->ZBZ_MODELO == "65"
					oChart:addSerie( "NFCE - "+alltrim(str(TRBACD->QUANT)) , TRBACD->QUANT )
					
				Case TRBACD->ZBZ_MODELO == "RP"
					oChart:addSerie( "NFSE - "+alltrim(str(TRBACD->QUANT)) , TRBACD->QUANT )
					
				Case TRBACD->ZBZ_MODELO == "67"
					oChart:addSerie( "CTEOS - "+alltrim(str(TRBACD->QUANT)) , TRBACD->QUANT )
					
				//Otherwise
				//	oChart:addSerie( "CCE - "  +alltrim(str(nTotCCE))         , nTotCCE )
			EndCase
			TRBACD->(dbSkip())
		End 
		//FR - 10/12/2020 - total de CCE:
		If nTotCCE > 0 
			oChart:addSerie( "CCE - "  +alltrim(str(nTotCCE))         , nTotCCE ) 
		Endif
		//FR - 10/12/2020
		oChart:Activate()
	
	Else
		//msgInfo("Nenhuma informação encontrada !!")
	Endif

Return()


/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ _fAtuGraf5() - Atualiza Dados do Grafico da Box03 conforme a Consulta 03 
Gráfico: (3) "Quantidade - Meses" (antes era "Quantidade - Dias da Semana")
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function _fAtuGraf5()

Local _nTotNotas := 0
Local _nValNotas := 0 
	
	//FR - 10/12/2020
	/*
	cQuery := " SELECT
	cQuery += "   datepart ( weekday,  "+xZBZ+"_DTNFE ) AS DIA, "
	cQuery += "   CASE datepart ( weekday,  "+xZBZ+"_DTNFE ) "
	cQuery += "     WHEN 1 THEN 'DOMINGO' "
	cQuery += "     WHEN 2 THEN 'SEGUNDA' "
	cQuery += "     WHEN 3 THEN 'TERCA' "
	cQuery += "     WHEN 4 THEN 'QUARTA' "
	cQuery += "     WHEN 5 THEN 'QUINTA' "
	cQuery += "     WHEN 6 THEN 'SEXTA' "
	cQuery += "     WHEN 7 THEN 'SABADO' "
	cQuery += "   END DIASEMANA, "
	cQuery += "   COUNT(*) AS QUANT, " 
	cQuery += "   SUM("+xZBZ+"_VLBRUT) AS VALTOT, "
	cQuery += "   (SELECT MAX("+xZBZ+"_DTNFE) FROM " + RETSQLNAME(xZBZ) + " WHERE D_E_L_E_T_ = '' ) AS MAXDATE "
	cQuery += " FROM " + RETSQLNAME(xZBZ) + " "+xZBZ+" "
	cQuery += " WHERE D_E_L_E_T_ <> '*' "
	cQuery += " AND "+xZBZ+"_DTNFE BETWEEN '"+DTOS(dDataDe)+"' AND '"+DTOS(dDataAte)+"' "
	If !Empty(cFornec) .and. !Empty(cLoj)
		cQuery += " AND "+xZBZ+"_CODFOR = '" + Alltrim(cFornec) + "' "			//FR - 10/12/2020
		cQuery += " AND "+xZBZ+"_LOJFOR = '" + Alltrim(cLoj) + "' "				//FR - 10/12/2020
	Endif
	cQuery += " GROUP BY datepart ( weekday,  "+xZBZ+"_DTNFE ), datepart ( weekday,  "+xZBZ+"_DTNFE ) "
	*/	
	//FR - 10/12/2020
	
	cQuery := " SELECT
	cQuery += "   Datepart ( MONTH,  "+xZBZ+"_DTNFE ) AS MES, "	+ CHR(13) + CHR(10)		
	cQuery += "   CASE Datepart ( MONTH,  "+xZBZ+"_DTNFE) "		+ CHR(13) + CHR(10)		
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
	cQuery += "   COUNT(*) AS QUANT, " 								+ CHR(13) + CHR(10)		
	cQuery += "   SUM("+xZBZ+"_VLBRUT) AS VALTOT, "					+ CHR(13) + CHR(10)
			
	cQuery += "   (SELECT MAX("+xZBZ+"_DTNFE) FROM " + RETSQLNAME(xZBZ) + " WHERE D_E_L_E_T_ = '' ) AS MAXDATE "+ CHR(13) + CHR(10)		
	cQuery += " FROM " + RETSQLNAME(xZBZ) + " "+xZBZ+" "			+ CHR(13) + CHR(10)
			
	cQuery += " WHERE D_E_L_E_T_ <> '*' "							+ CHR(13) + CHR(10)
			
	cQuery += " AND "+xZBZ+"_DTNFE BETWEEN '"+DTOS(dDataDe)+"' AND '"+DTOS(dDataAte)+"' "+ CHR(13) + CHR(10)		
	If !Empty(cFornec) .and. !Empty(cLoj)
		cQuery += " AND "+xZBZ+"_CODFOR = '" + Alltrim(cFornec) + "' "	+ CHR(13) + CHR(10)					//FR - 10/12/2020
		cQuery += " AND "+xZBZ+"_LOJFOR = '" + Alltrim(cLoj) + "' "		+ CHR(13) + CHR(10)					//FR - 10/12/2020
	Endif 
	If !Empty(cFilAte)  
		cQuery += " AND "+xZBZ+"_FILIAL BETWEEN '" + Alltrim(cFilDe) + "' AND '"+ Alltrim(cFilAte) + "' "	+ CHR(13) + CHR(10)		
	Endif
	cQuery += " GROUP BY datepart ( MONTH,  "+xZBZ+"_DTNFE ), datepart ( MONTH,  "+xZBZ+"_DTNFE ) "		+ CHR(13) + CHR(10)		
	cQuery += " ORDER BY MES "
	
	MemoWrite("C:\TEMP\GRAF_MES_SEMANA.SQL" , cQuery)
	//FR - 10/12/2020
	
	cQuery := ChangeQuery(cQuery)				//FR - 04/08/2021 - MATILAT
	If ( SELECT("TRB05") ) > 0
		dbSelectArea("TRB05")
		TRB05->(dbCloseArea())
	EndIf

	TcQuery cQuery Alias "TRB05" New

	TRB05->(dbGoTop())

	oChart2:DeActivate()
	cTotXML:="0"
	cTotVlXML := "0.00"
	cDatUlt := '00/00/0000'

	If !TRB05->(EOF())
			
		_nDom := 0
		_nSeg := 0
		_nTer := 0
		_nQua := 0
		_nQui := 0
		_nSex := 0
		_nSab := 0
		
		//FR - 10/12/2020
		_nJan := 0
		_nFev := 0
		_nMar := 0
		_nAbr := 0
		_nMai := 0
		_nJun := 0
		_nJul := 0
		_nAgo := 0
		_nSet := 0
		_nOut := 0
		_nNov := 0
		_nDez := 0 
		//FR - 10/12/2020
		
		While TRB05->( !EOF() )
            //FR - 10/12/2020            
			Do Case
				Case TRB05->MES == 1
					_nJan := TRB05->QUANT
				Case TRB05->MES == 2
					_nFev := TRB05->QUANT
				Case TRB05->MES == 3
					_nMar := TRB05->QUANT
				Case TRB05->MES == 4
					_nAbr := TRB05->QUANT
				Case TRB05->MES == 5
					_nMai := TRB05->QUANT
				Case TRB05->MES == 6
			   		_nJun := TRB05->QUANT
				Case TRB05->MES == 7
					_nJul := TRB05->QUANT 
				Case TRB05->MES == 8
					_nAgo := TRB05->QUANT
				Case TRB05->MES == 9
					_nSet := TRB05->QUANT
				Case TRB05->MES == 10
			   		_nOut := TRB05->QUANT
				Case TRB05->MES == 11
			   		_nNov := TRB05->QUANT
				Case TRB05->MES == 12
					_nDez := TRB05->QUANT
			EndCase
		    //FR - 10/12/2020
		    
			_nTotNotas += TRB05->QUANT
			_nValNotas += TRB05->VALTOT
			cDatUlt := TRB05->MAXDATE 
			
			TRB05->(dbSkip())
			
		Enddo
		//FR - 10/12/2020 - se o período escolhido couber dentro de no máximo 1 mês, exibe resultados por semana mostrando os dias da semana
					
		oChart2:SetXAxis( {"Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho", "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro" } )
		oChart2:addSerie('Qtde', {  _nJan, _nFev, _nMar, _nAbr, _nMai, _nJun, _nJul, _nAgo, _nSet, _nOut, _nNov, _nDez  } )		
		//FR - 10/12/2020	
		oChart2:Activate()
			
		// Atualiza valor dos Totais de XML
		cTotXML := alltrim(strzero((_nTotNotas+nTotCCE),6))
		//cTotVlXML := alltrim(cValToChar(_nValNotas))
		cTotVlXML := TRANSFORM(_nValNotas, "@E 999,999,999.99")
		cDatUlt := DTOC(Stod(cDatUlt))
		//Alert("Contagem das Notas: "+ alltrim((_nTotNotas)))
		//Alert("Total da Variavel cTotXML: "+cTotXML)
				 
	
	Else
		//msgInfo("Nenhuma informação encontrada !!")
	Endif

Return()


//================================================================================//
//Function  ³ _fColsBrw() - Monta aCols da MsNewGetDados para a Consulta (3) Top 10
//================================================================================//
Static Function _fColsBrw()

	Local nCont  := 0

	//BUSCA DADOS
	cQuery1 := " Select TOP 10 "+xZBZ+"_CNPJ AS ZBZ_CNPJ, "	+ CHR(13) + CHR(10)
	cQuery1 += " CASE "+xZBZ+"_FORNEC  WHEN '' THEN 'CADASTRO PENDENTE' ELSE "+xZBZ+"_FORNEC END AS ZBZ_FORNEC, "	+ CHR(13) + CHR(10)
	cQuery1 += " Count("+xZBZ+"_CNPJ) AS QUANT "			+ CHR(13) + CHR(10)
	cQuery1 += " FROM " + RETSQLNAME(xZBZ) + " "+xZBZ+" "	+ CHR(13) + CHR(10)
	cQuery1 += " WHERE "+xZBZ+".D_E_L_E_T_ = '' AND "+xZBZ+"_MODELO <> '' "	+ CHR(13) + CHR(10)
	cQuery1 += " AND "+xZBZ+"_DTNFE BETWEEN '"+DTOS(dDataDe)+"' AND '"+DTOS(dDataAte)+"' "	+ CHR(13) + CHR(10)
	
	If !Empty(cFornec) .and. !Empty(cLoj)
		cQuery1 += " AND " +xZBZ+"_CODFOR = '" + Alltrim(cFornec) + "' " 	+ CHR(13) + CHR(10)		//FR - 10/12/2020
		cQuery1 += " AND " +xZBZ+"_LOJFOR = '" + Alltrim(cLoj) + "' "  		+ CHR(13) + CHR(10)			//FR - 10/12/2020
	Endif
	If !Empty(cFilAte)  
		cQuery1 += " AND "+xZBZ+"_FILIAL BETWEEN '" + Alltrim(cFilDe) + "' AND '"+ Alltrim(cFilAte) + "' "	+ CHR(13) + CHR(10)		
	Endif
	cQuery1 += " GROUP BY "+xZBZ+"_CNPJ, "+xZBZ+"_FORNEC "	+ CHR(13) + CHR(10)
	cQuery1 += " ORDER BY QUANT DESC "

	MemoWrite("C:\TEMP\RANK_TOP_10.SQL", cQuery1)
	
	If ( SELECT("TRBACL") ) > 0
		dbSelectArea("TRBACL")
		TRBACL->(dbCloseArea())
	EndIf

	cQuery1 := ChangeQuery(cQuery1)				//FR - 04/08/2021 - MATILAT
	TcQuery cQuery1 Alias "TRBACL" New

	TRBACL->(dbGoTop())

	aCols := {}

	If !TRBACL->(EOF())

		Do While TRBACL->( !EOF() )
			nCont++

			//alert("Qtd noBrw1 : "+str(noBrw1))
			Aadd(aCols,Array(noBrw1+1))

			//			If ZBZ->ZBZ_STATUS=='N'
			//				aCols[nCont][1]	:= oBlack
			//			ElseIf ZBZ->ZBZ_STATUS=='A'
			//				aCols[nCont][1]	:= oGreen
			//			Else
			//				aCols[nCont][1]	:= oRed
			//			Endif

			aCols[nCont][1] := STRZERO(nCont,2)
			aCols[nCont][2] := TRBACL->QUANT
			aCols[nCont][3] := TRBACL->ZBZ_CNPJ
			aCols[nCont][4] := TRBACL->ZBZ_FORNEC

			aCols[nCont][noBrw1+1] := .F.
			TRBACL->(DbSkip())
		Enddo

		//if nTotLanc > 1
		//	_fAtuGraf2()
		//EndIf
	EndIf
	//MsNewGetDados():ForceRefresh()

	//Setar array do aCols do Objeto.
	oGetDados:SetArray(aCols,.T.)

	//Atualizo as informações no grid
	oGetDados:Refresh()

	//	Endif
	//oGetDados:oBrowse:Refresh()
	//oGetDados:Refresh()
	//oGetDados:oBrowse:Refresh()
	//oBrw1:oBrowse:Refresh()
Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ MCoBrw1() - Monta aCols da MsNewGetDados para o Alias: SZ2
//Gráfico: (4) Valores x Meses (antes era Valores x Dias da Semana)
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function _fColsBrw04()

	Local nCont  := 0

	//BUSCA DADOS 
	//FR - 10/12/2020
	/*
	cQuery1 := " SELECT
	cQuery1 += "   CASE datepart ( weekday,  "+xZBZ+"_DTNFE ) "
	cQuery1 += "     WHEN 1 THEN 'DOMINGO' "
	cQuery1 += "     WHEN 2 THEN 'SEGUNDA' "
	cQuery1 += "     WHEN 3 THEN 'TERCA' "
	cQuery1 += "     WHEN 4 THEN 'QUARTA' "
	cQuery1 += "     WHEN 5 THEN 'QUINTA' "
	cQuery1 += "     WHEN 6 THEN 'SEXTA' "
	cQuery1 += "     WHEN 7 THEN 'SABADO' "
	cQuery1 += "   END DIASEMANA, "
	cQuery1 += "   COUNT(*) AS QUANT, SUM("+xZBZ+"_VLBRUT) AS VALTOT "
	cQuery1 += " FROM " + RETSQLNAME(xZBZ) + " "+xZBZ+" "
	cQuery1 += " WHERE D_E_L_E_T_ = '' "
	cQuery1 += " AND "+xZBZ+"_DTNFE BETWEEN '"+DTOS(dDataDe)+"' AND '"+DTOS(dDataAte)+"' "
	cQuery1 += " GROUP BY datepart ( weekday,  "+xZBZ+"_DTNFE ) "
    */    
    //FR - 10/12/2020
    
	cQuery1 := " SELECT
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
	cQuery1 += "   END MES, "									+ CHR(13) + CHR(10)	
	//cQuery1 += "   COUNT(*) AS QUANT, SUM("+xZBZ+"_VLBRUT) AS VALTOT "+ CHR(13) + CHR(10)		//FR - 19/02/2021 - Revisões nas queries que buscam os valores dos XMLs
	
//RETIRADO EM 14/07/22 - PARA NAO FAZER PARSE DEVIDO LENTIDAO
/*
	cQuery1 += "   "+xZBZ+"_MODELO  AS ZBZMODELO, " 			+ CHR(13) + CHR(10)
	cQuery1 += "   "+xZBZ+"_VLBRUT AS VALTOT, "					+ CHR(13) + CHR(10)				//FR - 19/02/2021 -Revisões nas queries que buscam os valores dos XMLs
	cQuery1 += "   ZBZ.R_E_C_N_O_ AS RECZBZ " 	   				+ CHR(13) + CHR(10)				//FR - 19/02/2021 - Revisões nas queries que buscam os valores dos XMLs
*/	

	cQuery1 += "   COUNT(*) AS QUANT, " 							+ CHR(13) + CHR(10)
	cQuery1 += "   SUM("+xZBZ+"_VLBRUT) AS VALTOT "				+ CHR(13) + CHR(10)				//FR - 19/02/2021 -Revisões nas queries que buscam os valores dos XMLs

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
	
	//cQuery1 += " GROUP BY datepart ( MONTH,  "+xZBZ+"_DTNFE ) " + CHR(13) + CHR(10) 			//FR - 19/02/2021 - Revisões nas queries que buscam os valores dos XMLs	
	cQuery1 += " GROUP BY datepart ( MONTH,  "+xZBZ+"_DTNFE ) "
	cQuery1 += " ORDER BY datepart ( MONTH,  "+xZBZ+"_DTNFE ) "	
	
	MemoWrite("C:\TEMP\_fColsBrw04.sql", cQuery1)
	//FR - 10/12/2020
	
	cQuery1 := ChangeQuery(cQuery1)				//FR - 04/08/2021 - MATILAT
	If ( SELECT("TRB04") ) > 0
		dbSelectArea("TRB04")
		TRB04->(dbCloseArea())
	EndIf

	TcQuery cQuery1 Alias "TRB04" New

	TRB04->(dbGoTop())

		aCols04 := {}

	If !TRB04->(EOF())

		Do While TRB04->( !EOF() )
			
			xMes    := TRB04->MES
		    nValor  := 0
		    nQtos   := TRB04->QUANT //0
 		    nValtot := TRB04->VALTOT //0
 		    cXml    := ""
 		    
 		   /* RETIRADO EM 14/07/22 - LENTIDAO
 		    While Alltrim(TRB04->MES) == Alltrim(xMes)
				nValor  := TRB04->VALTOT
				
				DbSelectArea(xZBZ)						//acessa a ZBZ
				(xZBZ)->( Dbgoto(TRB04->RECZBZ) )		//posiciona no registro
				cXml   := ""
				cXml   := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML")))	//para pegar o conteúdo do XML
							
				//se o campo da ZBZ estiver vazio, faz o parse no xml para obter o valor
				If nValor == 0
					nValor := U_fParseXML( TRB04->ZBZMODELO, cXml ) 		//função faz o parse e retorna o valor bruto do xml
				Endif
				nQtos++        			//contator das notas daquele mês
				nValtot += nValor    	//somatório do valor das notas daquele mês
				
				TRB04->(DbSkip())
			Enddo
 		    */
			nCont++
			
			Aadd(aCols04,Array(noBrw104+1))		

			aCols04[nCont][1] := xMes 		//TRB04->MESANO		//FR - 19/02/2021
			aCols04[nCont][2] := nQtos 		//TRB04->QUANT		//FR - 19/02/2021
			aCols04[nCont][3] := nValtot 	//TRB04->VALTOT		//FR - 19/02/2021
		
			aCols04[nCont][noBrw104+1] := .F.
			
			//zera contadores e total
			nQtos   := 0  			//contator das notas daquele mês
			nValtot := 0           	//somatório do valor das notas daquele mês
			
			TRB04->(DbSkip())
		Enddo
	
	EndIf
	//MsNewGetDados():ForceRefresh()

	//Setar array do aCols do Objeto.
	oGetDados04:SetArray(aCols04,.T.)

	//Atualizo as informações no grid
	oGetDados04:Refresh()

	//oGetDados:oBrowse:Refresh()
	//oGetDados:Refresh()
	//oGetDados:oBrowse:Refresh()
	//oBrw1:oBrowse:Refresh()
Return


//############################ MONTAGEM DE HEADER E ACOLS DAS GRADES ###########################################

//===================================================================================
// MONTA HEADER E ACOLS PARA A GRID DO BOX02 - RANKING FORNECEDORES
//===================================================================================

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ MHoBrw1() - Monta aHeader da MsNewGetDados para o Alias: ZBZ
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function _fHeader()

	noBrw1++
	Aadd(aHeader, {;
	"Item",;	//X3Titulo()
	"ITEM",;  	//X3_CAMPO
	"@!",;		//X3_PICTURE
	2,;			//X3_TAMANHO
	0,;			//X3_DECIMAL
	"",;		//X3_VALID
	"",;		//X3_USADO
	"C",;		//X3_TIPO
	"",; 		//X3_F3
	"R",;		//X3_CONTEXT
	"",;		//X3_CBOX
	"",;		//X3_RELACAO
	""})		//X3_WHEN

	noBrw1++
	Aadd(aHeader, {;
	"Qtd. Notas",;	//X3Titulo()
	"QUANTIDADE",;  //X3_CAMPO
	"@E 999999 ",;	//X3_PICTURE
	6,;				//X3_TAMANHO
	0,;				//X3_DECIMAL
	"",;			//X3_VALID
	"",;			//X3_USADO
	"N",;			//X3_TIPO
	"",;			//X3_F3
	"R",;			//X3_CONTEXT
	"",;			//X3_CBOX
	"",;			//X3_RELACAO
	""})			//X3_WHEN

	noBrw1++
	Aadd(aHeader, {;
	"CNPJ Emit.  ",;	//X3Titulo()
	"CNPJ",;  			//X3_CAMPO
	"@!",;				//X3_PICTURE
	14,;				//X3_TAMANHO
	0,;					//X3_DECIMAL
	"",;				//X3_VALID
	"",;				//X3_USADO
	"C",;				//X3_TIPO
	"",;				//X3_F3
	"R",;				//X3_CONTEXT
	"",;				//X3_CBOX
	"",;				//X3_RELACAO
	""})				//X3_WHEN

	noBrw1++
	Aadd(aHeader, {;
	"Descricao",;	//X3Titulo()
	"DESCRICAO",;  	//X3_CAMPO
	"@!",;			//X3_PICTURE
	60,;			//X3_TAMANHO
	0,;				//X3_DECIMAL
	"",;			//X3_VALID
	"",;			//X3_USADO
	"C",;			//X3_TIPO
	"",;			//X3_F3
	"R",;			//X3_CONTEXT
	"",;			//X3_CBOX
	"",;			//X3_RELACAO
	""})			//X3_WHEN

Return


//===================================================================================
// MONTA HEADER E ACOLS PARA A GRID DO BOX04 - VALORES / MÊS
//===================================================================================

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ MHoBrw1() - Monta aHeader da MsNewGetDados para o Alias: ZBZ
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function _fHeader04()

	noBrw104++
	Aadd(aHeader04, {;
	"Mês",;			//"Dia",;//X3Titulo()
	"MES",;  		//X3_CAMPO
	"@!",;			//X3_PICTURE
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

	noBrw104++
	Aadd(aHeader04, {;
	"Qtd. Notas",;		//X3Titulo()
	"QUANTIDADE",;  	//X3_CAMPO
	"@E 999999 ",;		//X3_PICTURE
	6,;					//X3_TAMANHO
	0,;					//X3_DECIMAL
	"",;				//X3_VALID
	"",;				//X3_USADO
	"N",;				//X3_TIPO
	"",;				//X3_F3
	"R",;				//X3_CONTEXT
	"",;				//X3_CBOX
	"",;				//X3_RELACAO
	""})				//X3_WHEN

	noBrw104++
	Aadd(aHeader04, {;
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
	""})						//X3_WHEN

Return


//################################### FIM HEADER E ACOLS ###############################################

// Chama nova Tela Mais Graficos Como Novo Processo
// Para não dar problema com variaveis iguais
Static Function MaisGraf()

oProcess := MsNewProcess():New({|lEnd| u_HFXMLGR2(dDataDe,dDataAte,cFornec,cLoj,cFilDe,cFilAte) },"Aguarde...","Carregando Cenários - Data Analytics",.T.)	//FR - 10/12/2020
oProcess:Activate()

Return


//#include "protheus.ch"

User Function Layer()
	Local oDlg
	Local oLayer := FWLayer():new()

	DEFINE MSDIALOG oDlg FROM 000,000 TO 500,500 PIXEL TITLE "FWLayer"
	//Inicializa o FWLayer com a janela que ele pertencera e se sera exibido o botão de fechar
	oLayer:init(oDlg,.T.)
	//Cria as colunas do Layero
	oLayer:addCollumn('Col01',60,.F.)
	oLayer:addCollumn('Col02',40,.F.)

	//Adiciona Janelas as colunaso
	oLayer:addWindow('Col01','C1_Win01','Janela 01',60,.T.,.F.,{|| Alert("Clique janela 01!") },,{|| Alert("Janela 01 recebeu foco!") })
	oLayer:addWindow('Col01','C1_Win02','Janela 02',40,.T.,.T.,{|| Alert("Clique janela 02!") },,{|| Alert("Janela 02 recebeu foco!") })
	oLayer:addWindow('Col02','C2_Win01','Janela 01',60,.T.,.F.,{|| Alert("Clique janela 01 Coluna 2!") },,{|| Alert("Janela 01 recebeu foco Coluna 2!") })
	oLayer:getWinPanel('Col02','C2_Win01')

	//Coloca o botão de split na coluna
	oLayer:setColSplit('Col01',CONTROL_ALIGN_RIGHT,,{|| Alert("Split Col01!") })
	ACTIVATE MSDIALOG oDlg CENTERED

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
