#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE 'TOPCONN.CH'
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ HFXML063 ³ Autora ³ Flávia Rocha         ³ Data ³30/03/2020³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tela de Divergências entre XML x Nota Fiscal Entrada       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//--------------------------------------------------------------------------//
//Renan - 15/06/2020 - Alterações realizadas para adequar resolução de tela 
//--------------------------------------------------------------------------//
//FR - 16/06/2020 - ECOURBIS: tratativa para incluir campo NCM na tela de  
//                  divergencias
//--------------------------------------------------------------------------// 
//FR - 22/06/2020 - Tratativa para quando o array de itens NFE tiver linhas  
//                 deletadas (seleção por pedido e o usuario escolhe apenas
//                 alguns itens).
//--------------------------------------------------------------------------//  
//FR - 30/11/2020 - Correções solicitadas por RL: qto exibição de totais e NCM 
//                  - Correção da cor exibida em caso de divergência para NCM
//                  Apresentava "vermelho" mesmo quando a NCM era igual
//                  - Zerava os totais de cabeçalho qdo trocava de item
//
//                  Correção de caracteres "estranhos" na tela
//--------------------------------------------------------------------------//
//FR - 06/03/2021 - Detalhamento da mensagem sobre divergência nf
//--------------------------------------------------------------------------//
//FR - 17/03/2021 - Projeto MaxiRubber - Criação de novo filtro para a tela
//                  Multiplos Cte, trazer também xmls que já tem pré-nota
//--------------------------------------------------------------------------//
//FR - 06/07/2021 - Tarefas RAfael - mudanças para apresentar ao prospect     
//--------------------------------------------------------------------------//
//FR - 16/07/2021 - Erro via consulta ponto de entrada MT100TOK 
//                  na visualização da NF -> Auditoria Fiscal, 
//                  qdo o modelo era Cte o retorno falso era tipo inválido
//--------------------------------------------------------------------------//
//FR - 16/08/2021 - Modificações para nova tela de análise fiscal
//                  modelo árvore
//--------------------------------------------------------------------------//
//FR - 09/02/2022 - alteração - Petra - correção qdo acessada opção 
//                  "análise fiscal" dentro de "classificar nf"
//--------------------------------------------------------------------------//
User Function HFXML063(cChave,aCabNFE,aIteNFE,cTipoDoc,aPedidos,lOmiTTela,lDiverg,lVisual) 
Local   lGera			:= .T. 
Default lDiverg			:= .F.
Default lVisual			:= .F.
Private aSIZE			:= {} 
Private aPOS			:= {}
Private aInfo			:= {}
Private aObjects		:= {}
Private aESTRUT 		:= {}
Private cARQTMP			:= ""
Private xARQTMP			:= ""
Private nOpGera			:= 0 
//variaveis do Xml
Private xFiliXML   := Space(2)
Private xDocto     := Space(9)
Private xSerie     := Space(3)
Private xCodForn   := Space(6)
Private xLojForn   := Space(2)
Private xNomeForn  := Space(30) 
Private xTipoNF    := Space(15)
Private xEspeciNF  := Space(10) 
Private xModelo    := ""
Private xXml       := ""
Private xCnpjXml   := ""
Private xEmissao   := Ctod("  /  /    ")

//variáveis dos totais do xml
Private xValmerc   := 0
Private xValbrut   := 0
Private xBasCof    := 0
Private xBaseICM   := 0
Private xBaseIPI   := 0
Private xBasePIS   := 0
Private xBasIR     := 0
Private xValCOF    := 0
Private xValICM    := 0 
Private xVALIPI    := 0
Private xValIR     := 0
Private xValPIS    := 0 
Private xValICMST  := 0		//FR - 11/01/2022 - Petra - inclusão do ICMST na tela


//variaveis dos itens do xml
Private xValICMi   := 0
Private xVALIPIi   := 0
Private xValPISi   := 0   
Private xValCOFi   := 0
Private xValIRi    := 0
Private xAliqCof   := 0
Private xAliqICM   := 0
Private xAliqIPI   := 0
Private xAliqIR    := 0
Private xAliqpis   := 0

Private xBasICMST  := 0		//FR - 11/01/2022 - Petra - inclusão do ICMST na tela
Private xAliqICMST := 0		//FR - 11/01/2022 - Petra - inclusão do ICMST na tela
Private xValICMiS  := 0		//FR - 11/01/2022 - Petra - inclusão do ICMST na tela

Private xNCM 	   := ""   	//FR - 16/06/2020 - ECOURBIS
Private xQuant     := 0	   	//FR - 19/06/2020 - TOPICOS RAFAEL
Private xINSVAL				//Erick Gonça - 31/08
Private xISSVAL				//Erick Gonça - 30/08 
Private xISSALQ				//Erick Gonça - 02/09/2022
Private xINSALQ				//Erick Gonça - 02/09/2022
Private xCSLVAL				//Erick Gonça - 02/09/2022
Private xCSLALQ				//Erick Gonça - 02/09/2022

//variaveis da nf
Private cDocto     := Space(9)
Private cSerie     := Space(3)
Private cCodForn   := Space(6)
Private cLojForn   := Space(2)
Private cNomeForn  := Space(30) 
Private cTipoNF    := Space(15)
Private cEspeciNF  := Space(10)
Private dEmissao   := Ctod("  /  /    ")

//variáveis dos totais da nf
Private nValmerc   := 0
Private nValbrut   := 0
Private nBasCof    := 0
Private nBaseICM   := 0
Private nBaseIPI   := 0
Private nBasePIS   := 0
Private nBasIR     := 0
Private nValCOF    := 0
Private nValICM    := 0 
Private nVALIPI    := 0
Private nValIR     := 0
Private nValPIS    := 0
Private nValICMST  := 0		//FR - 11/01/2022 - Petra - inclusão do ICMST na tela


//variáveis dos itens da nf
Private nAliqCof   := 0
Private nAliqICM   := 0
Private nAliqIPI   := 0
Private nAliqIR    := 0
Private nAliqpis   := 0
Private nValICMi   := 0  
Private nVALIPIi   := 0
Private nValPISi   := 0
Private nValCOFi   := 0
Private nValIRi    := 0

Private nBasICMST  := 0		//FR - 11/01/2022 - Petra - inclusão do ICMST na tela
Private nAliqICMST := 0		//FR - 11/01/2022 - Petra - inclusão do ICMST na tela
Private nValICMiS  := 0		//FR - 11/01/2022 - Petra - inclusão do ICMST na tela

Private cNCM 	   := ""   //FR - 16/06/2020 - ECOURBIS
Private nQuant     := 0	   //FR - 19/06/2020 - ToPICOS RAFAEL
Private nISSVAL	   := 0    //EGS - 05/09/2022 - Variável valor do ISS
Private nISSALQ    := 0    //EGS - 05/09/2022 - Variável aliquota do ISS
Private nINSALQ	   := 0    //EGS - 05/09/2022 - Variável aliquota do INSS
Private nINSVAL    := 0    //EGS - 05/09/2022 - Variável valor do INSS
Private nCSLALQ    := 0    //EGS - 05/09/2022 - Variável aliquota do CSLL
Private nCSLVAL    := 0    //EGS - 05/09/2022 - Variável valor do CSLL
Private xZBZ  	  := GetNewPar("XM_TABXML","ZBZ")
Private xZBZ_ 	  := iif(Substr(xZBZ,1,1)=="S", Substr(xZBZ,2,2), Substr(xZBZ,1,3)) + "_"  
Private xZBT  	  := GetNewPar("XM_TABITEM","ZBT")		//Tabela de itens do xml
Private xZBT_ 	  := iif(Substr(xZBT,1,1)=="S", Substr(xZBT,2,2), Substr(xZBT,1,3)) + "_" 
//Função para checar se os campos novos existem na base de dados:
lExistCpo := U_fCheckCpos()
If !lExistCpo         //se não existirem na base de dados os novos campos, não impedirá a geração da NF, somente avisará ao usuário
	Return(lGera)
Endif

//Monta a estrutura do arquivo que será apresentado na msSelect
aESTRUT := {;		    
 { "ITEM"	,  "C", 004 ,	0 },;
 { "CODIGO" ,  "C", 015	,	0 },;
 { "DESCRI" ,  "C", 030 ,   0 },;
 { "NCM"    ,  "C", 015 ,   0 },;
 { "QUANT"  ,  "N", 011	,	2 },;
 { "UM"     ,  "C", 002	,	0 },;
 { "VUNIT"  ,  "N", 016 ,	4 },;
 { "VTOTAL" ,  "N", 014 ,	2 },;
 { "ALQICM" ,  "N", 005 ,	2 },;
 { "BASICM" ,  "N", 014 ,	2 },;
 { "VALICM" ,  "N", 014 ,	2 },;
 { "ALQIPI" ,  "N", 005 ,	2 },;
 { "BASIPI" ,  "N", 014 ,	2 },;
 { "VALIPI" ,  "N", 014	,	2 },;
 { "ALQPIS" ,  "N", 005 ,	2 },;
 { "BASPIS" ,  "N", 014 ,	2 },;
 { "VALPIS" ,  "N", 014 ,	2 },;
 { "ALQCOF" ,  "N", 005	,	2 },;
 { "BASCOF" ,  "N", 014	,	2 },;
 { "VALCOF" ,  "N", 014	,	2 },;
 { "ALQIR"	,  "N", 005	,	2 },;
 { "BASIR" 	,  "N", 014	,	2 },;
 { "VALIR" 	,  "N", 014	,	2 },;  			    
 { "STBASE"	,  "N", 014	,	2 },;	//FR - 17/0/2022 - PETRA - Implementar campo ICM ST	    
 { "STVALO"	,  "N", 014	,	2 },;	//FR - 17/0/2022 - PETRA - Implementar campo ICM ST	 
 { "STALIQ"	,  "N", 005	,	2 },;	//FR - 17/0/2022 - PETRA - Implementar campo ICM ST	
 { "ALIQISS",  "N", 005 ,   2 },;	//EGS - 15/09/2022 - Inclusão campo Aliq.ISS      
 { "VALISS"	,  "N", 005	,	2 },;   //EGS - 15/09/2022 - Inclusão campo Vlr.ISS
 { "ALIQINS",  "N", 005 ,   2 },;   //EGS - 15/09/2022 - Inclusão campo Aliq.INSS
 { "VALINS" ,  "N", 005 ,   2 },;   //EGS - 15/09/2022 - Inclusão campo Vlr.INSS
 { "ALQCSL" ,  "N", 005 ,   2 },;   //EGS - 15/09/2022 - Inclusão campo Aliq.CSLL
 { "CSLVAL" ,  "N", 005 ,   2 };    //EGS - 15/09/2022 - Inclusão campo Vlr.CSLL
 }  
If lOmiTTela == Nil         	    //FR - MOSTRA TELA
	nOpgera := fTelaDiv(cChave,aESTRUT,aCabNFE,aIteNFE,cTipoDoc,@lDiverg,aPedidos,,lVisual) 
	If nOpgera == 0
		lGera := .F.
	Elseif nOpgera == 1
		lGera := .T.
	Endif		
	Return(lGera)    	//FR - retorna se prossegue com a geraÃ§Ã£o da NF Entrada sim ou nÃ£o (independente das divergÃªncias)
Else      				//FR - NÃO MOSTRA TELA, SÓ CHECA DIVERGENCIA
	lDiverg := fTelaDiv(cChave,aESTRUT,aCabNFE,aIteNFE,cTipoDoc,@lDiverg,aPedidos,lOmiTTela,lVisual)  //verifica divergencia tanto cabeçalho qto itens
	Return(lDiverg)  //retorna se tem divergencia 
Endif
Return()

//--------------------------------------------------------------------------//
//Função: fTelaDiv - Função responsável por criar a Dialog que confronta 
//                   XML x NF
//Autoria: Flávia Rocha
//Data   : 30/03/2020
//--------------------------------------------------------------------------//
******************************************************************
Static Function fTelaDiv(cChave,aESTRUT,aCabNFE,aIteNFE,cTipoDoc,lDiverg,aPedidos,lOmiTTela,lVisual) 
******************************************************************
Local	fr			:= 0
Local   aCores      := {}
Local   aIteXML     := {}
Local  nLiMeio      := 0

Private xCorFo1     := 0
Private xCorFo2     := 0
Private xCorFo3     := 0
Private xCorFo4     := 0
Private xCorFo5     := 0
Private xCorFo6     := 0
Private xCorFo7     := 0
Private xCorFo8     := 0
Private xCorFo9     := 0
Private xCorFo10    := 0
Private xCorFo11    := 0
Private xCorFo12    := 0
Private xCorFo13    := 0
Private xCorFo14    := 0
Private xCorFo15    := 0
Private xCorFo16    := 0
Private xCorFo17    := 0
Private xCorFo18    := 0
Private xCorFo19    := 0
Private xCorFo20    := 0
Private xCorFo21    := 0
Private xCorFo22    := 0
Private xCorFo23    := 0
Private xCorFo24    := 0
Private xCorFo25    := 0
Private xCorFo26    := 0
Private xCorFo27    := 0

Private xCorFu1     := 0
Private xCorFu2     := 0
Private xCorFu3     := 0
Private xCorFu4     := 0
Private xCorFu5     := 0
Private xCorFu6     := 0
Private xCorFu7     := 0
Private xCorFu8     := 0
Private xCorFu9     := 0
Private xCorFu10    := 0
Private xCorFu11    := 0
Private xCorFu12    := 0
Private xCorFu13    := 0
Private xCorFu14    := 0
Private xCorFu15    := 0
Private xCorFu16    := 0
Private xCorFu17    := 0
Private xCorFu18    := 0
Private xCorFu19    := 0
Private xCorFu20    := 0
Private xCorFu21    := 0
Private xCorFu22    := 0
Private xCorFu23    := 0
Private xCorFu24    := 0
Private xCorFu25    := 0
Private xCorFu26    := 0
Private xCorFu27    := 0

Private cItem       := "" //FR - 22/06/2020
  
Private oArial09   := TFont():New("Arial",09,09,,.F.,,,,.T.,.F.)		//Normal     
Private oArial09N  := TFont():New("Arial",09,09,,.T.,,,,.T.,.F.)		//Negrito     
Private oArial08N  := TFont():New("Arial",08,08,,.T.,,,,.T.,.F.)		//Negrito
Private oArial10N  := TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)		//Negrito
Private oArial12N  := TFont():New("Arial",12,12,,.T.,,,,.T.,.F.)		//Negrito
Private oArial14N  := TFont():New("Arial",14,14,,.T.,,,,.T.,.F.)		//Negrito

//-------------------------------------------------//
//Declaração de Variaveis Private dos Objetos                            
//-------------------------------------------------//
SetPrvt("oBtn1","oBtn2","oBtn3")
SetPrvt("oBrw1","oBrw2","oBrw3","oBrw4")
SetPrvt("oDlg1")
SetPrvt("oGrp1","oGrp2","oGrp3","oGrp4","oGrp5","oGrp6","oGrp7","oGrp8")
SetPrvt("oSay1","oSay2","oSay3","oSay4","oSay5","oSay6","oSay7","oSay8","oSay9","oSay10")

SetPrvt("oSay11","oSay12","oSay13","oSay14","oSay15","oSay16","oSay17","oSay18","oSay19","oSay20")
SetPrvt("oSay21","oSay22","oSay23","oSay24","oSay25","oSay26","oSay27","oSay28","oSay29","oSay30")
SetPrvt("oSay31","oSay32","oSay33","oSay34","oSay35","oSay36","oSay37","oSay38","oSay39","oSay40")
SetPrvt("oSay41","oSay42","oSay43","oSay44","oSay45","oSay46","oSay47","oSay48","oSay49","oSay50")
SetPrvt("oSay51","oSay52","oSay53","oSay54","oSay55","oSay56","oSay57","oSay58","oSay59","oSay60")
SetPrvt("oSay61","oSay62","oSay63","oSay64","oSay65","oSay66","oSay67","oSay68","oSay69","oSay70")
SetPrvt("oSay71","oSay72","oSay73","oSay74","oSay75","oSay76","oSay77","oSay78","oSay79","oSay80")
SetPrvt("oSay81","oSay82","oSay83","oSay84","oSay85","oSay86","oSay87","oSay88","oSay89","oSay90") //FR - 11/01/2022
SetPrvt("oSay91","oSay92","oSay93","oSay94","oSay95","oSay96","oSay97","oSay98","oSay99","oSay100")
SetPrvt("oSay101","oSay102","oSay103","oSay104","oSay105","oSay106","oSay107")


SetPrvt("oGet1","oGet2","oGet3","oGet4","oGet5","oGet6","oGet7","oGet8","oGet9","oGet10",)
SetPrvt("oGet11","oGet12","oGet13","oGet14","oGet15","oGet16","oGet17","oGet18","oGet19","oGet20")
SetPrvt("oGet21","oGet22","oGet23","oGet24","oGet25","oGet26","oGet27","oGet28","oGet29","oGet30") //FR - 11/01/2022
SetPrvt("oGet31","oGet32","oGet33","oGet34","oGet35","oGet36","oGet37","oGet38","oGet39","oGet40")
SetPrvt("oGet41","oGet42","oGet43","oGet44","oGet45","oGet46","oGet47","oGet48","oGet49","oGet50")	
SetPrvt("oGet51","oGet52","oGet53","oGet54","oGet55","oGet56","oGet57","oGet58","oGet59","oGet60") // Rafael Tavares - 13/09/2022
SetPrvt("oGet61","oGet62","oGet63","oGet64","oGet65","oGet66","oGet67","oGet68","oGet69","oGet70") // Erick Gonçalves - 31/08/2022	
SetPrvt("oGet91","oGet92","oGet93","oGet94","oGet95","oGet96","oGet97","oGet98","oGet99","oGet90") // ISS,INSS,CSLL 
SetPrvt("oGet100","oGet101","oGet102","oGet103","oGet104", "oGet105")
//------------------------------------------//
//Monta as informações do cabeçalho do Xml: 
//------------------------------------------//
xValmerc  := 0
xValbrut  := 0
xBasicm	  := 0
xValicm	  := 0	
xBasipi	  := 0	
xValipi	  := 0	
xBaspis	  := 0	
xValpis   := 0		
xBascofi  := 0
xValcofi  := 0
xINSVAL   := 0
xISSVAL   := 0
xISSALQ   := 0
xINSALQ   := 0
xCSLVAL   := 0
xCSLALQ   := 0
xNCM      := 0
(xZBZ)->(OrdSetFocus(3)) //ZBT ordem 2 - CHAVE SEM FILIAL
If (xZBZ)->(Dbseek(cChave) )
	//Monta informações do cabeçalho XML:
	xFiliXML    := (xZBZ)->&(xZBZ_+"FILIAL")  
	xDocto 		:= (xZBZ)->&(xZBZ_+"NOTA")  
	xSerie 		:= (xZBZ)->&(xZBZ_+"SERIE")
	xEmissao   	:= (xZBZ)->&(xZBZ_+"DTNFE")
	xCnpjXml    := (xZBZ)->&(xZBZ_+"CNPJ")
	xModelo     := (xZBZ)->&(xZBZ_+"MODELO")
	xEspeciNF   := (xZBZ)->&(xZBZ_+"MODELO") 	
	xXml        := (xZBZ)->&(xZBZ_+"XML")
	
	//---------------------------------------------------------------------------------------------------//
	//FR - 12/04/2023 - QUEIJOS IPANEMA relatou problema qdo a nf é de beneficamento ou devolução: 
	//Na tela de analise fiscal  ,quando comparado com documento de devolução, 
	//esta exibindo dados do fornecedor em vez do cliente. Nota devolução 
	//---------------------------------------------------------------------------------------------------//
	//SA2->(OrdSetFocus(3))
	//SA2->(Dbseek(xFilial("SA2") + xCnpjXml )) //Fornecedor
	//xCodForn := SA2->A2_COD
	//xLojForn := SA2->A2_LOJA
	//xNomeForn:= (xZBZ)->&(xZBZ_+"FORNEC") 
	
	If (xZBZ)->&(xZBZ_+"TPDOC") == "N"
		xTipoNF := "Normal"
		SA2->(OrdSetFocus(3))
		SA2->(Dbseek(xFilial("SA2") + xCnpjXml )) //Fornecedor
		xCodForn := SA2->A2_COD
		xLojForn := SA2->A2_LOJA
		xNomeForn:= (xZBZ)->&(xZBZ_+"FORNEC") 
		
	Elseif (xZBZ)->&(xZBZ_+"TPDOC") == "D"
		xTipoNF := "Devolução"	
		SA1->(OrdSetFocus(3))
		SA1->(Dbseek(xFilial("SA1") + xCnpjXml )) //Fornecedor
		xCodForn := SA1->A1_COD
		xLojForn := SA1->A1_LOJA
		xNomeForn:= SA1->A1_NOME
						//FR - 30/11/2020
	Elseif (xZBZ)->&(xZBZ_+"TPDOC") == "B"
		xTipoNF := "Beneficiamento"
		SA1->(OrdSetFocus(3))
		SA1->(Dbseek(xFilial("SA1") + xCnpjXml )) //Fornecedor
		xCodForn := SA1->A1_COD
		xLojForn := SA1->A1_LOJA
		xNomeForn:= SA1->A1_NOME
	Else
		xTipoNF := "---"
	Endif
	//---------------------------------------------------------------------------------------------------//
	//FR - 12/04/2023 - QUEIJOS IPANEMA relatou problema qdo a nf é de beneficamento ou devolução: 
	//Na tela de analise fiscal  ,quando comparado com documento de devolução, 
	//esta exibindo dados do fornecedor em vez do cliente. Nota devolução 
	//---------------------------------------------------------------------------------------------------//
		
	xValmerc  := (xZBZ)->&(xZBZ_+"VLLIQ") 
	xValbrut  := (xZBZ)->&(xZBZ_+"VLBRUT")
	xBasicm	  := (xZBZ)->&(xZBZ_+"BASCAL") 	
	xValicm	  := (xZBZ)->&(xZBZ_+"ICMVAL") 		
	xBasipi	  := (xZBZ)->&(xZBZ_+"BASCAL") 		
	xValipi	  := (xZBZ)->&(xZBZ_+"IPIVAL") 			
	xBaspis	  := (xZBZ)->&(xZBZ_+"BASCAL") 			
	xValPisi  := (xZBT)->&(xZBT_+"PISVAL") 					
	xBascof   := (xZBZ)->&(xZBZ_+"BASCAL") 	
	xValcof   := (xZBZ)->&(xZBZ_+"COFVAL") 	
	xBasIR    := 0
	xAliqIR   := (xZBT)->&(xZBT_+"IRRALQ")		//Erick Gonça - 08/09/2022 - Melhoria
	xValIRi   := (xZBT)->&(xZBT_+"IRRVAL")		//Erick Gonça - 08/09/2022 - Melhoria
	xBasICMST := (xZBZ)->&(xZBZ_+"STBASE") 		//FR - 11/01/2022 - Petra - inclusão do ICMST na tela	 
	xValICMST := (xZBZ)->&(xZBZ_+"STVALO") 		//FR - 11/01/2022 - Petra - inclusão do ICMST na tela	 
	xISSALQ   := (xZBT)->&(xZBT_+"ISSALQ")		//Erick Gonça - 02/09/2022 - Melhoria - Inclusão do ISS na tela
	xISSVAL   := (xZBT)->&(xZBT_+"ISSVAL")		//Erick Gonça - 30/08/2022 - Melhoria - Inclusão do ISS na tela
	xINSALQ   := (xZBT)->&(xZBT_+"INSALQ")		//Erick Gonça - 02/09/2022 - Melhoria - Inclusão do INSS na tela
	xINSVAL   := (xZBT)->&(xZBT_+"INSVAL")		//Erick Gonça - 31/08/2022 - Melhoria - Inclusão do INSS na tela
	xCSLALQ   := (xZBT)->&(xZBT_+"CSLALQ")		//Erick Gonça - 02/09/2022 - Melhoria - Inclusão do CSLL na tela
	xCSLVAL   := (xZBT)->&(xZBT_+"CSLVAL")		//Erick Gonça - 02/09/2022 - Melhoria - Inclusão do CSLL na tela
	xNCM      := (xZBT)->&(xZBT_+"NCM")			//Erick Gonça - 12/09/2022 - Melhoria - Inclusão do NCM na ZBT
	
	If xModelo == "RP"
		If xValmerc <= 0
			xValmerc := xValbrut  //na nota de serviço pode ser q este campo ZBZ_VLLIQ esteja vazio, aí pega do ZBZ_VLBRUT
		Endif 
	Endif 

	If !(xModelo $ "55,57,65,67,RP")
	 	//FR - 17/03/2021 - Projeto MaxiRubber - necessário comentar esse msginfo porque na rotina Multiplos Cte aparecia a cada nota gerada
		//MsgInfo("A verificação de Divergências está disponível apenas para Xml Modelos: 55 ou 65 -> NFE")	//FR - 06/03/2021 - detalhamento do aviso para saber que é sobre a divergência
		//If lOmiTTela == Nil
			nOpgera := 0    	//FR - 16/07/2021
			Return(nOpgera)
		//Endif
	endif
	  
	//Obtem os itens do xml:				
	aIteXML := U_fIMPXMLFOR(xXml,xModelo,xCnpjXml)
	
Endif
	
//-----------------------------------//
//Monta informações do cabeçalho NF:			
cDocto 		:= aCabNFE[1,1]
cSerie 		:= aCabNFE[1,2] 
dEmissao   	:= aCabNFE[1,3]
cCodForn   	:= aCabNFE[1,4]	
cLojForn   	:= aCabNFE[1,5]
cEspeciNF	:= aCabNFE[1,6]
cNomeForn  	:= Posicione("SA2",1,xFilial("SA2")+ cCodForn + cLojForn,"A2_NOME") //Fornecedor
If aCabNFE[1,7] == "N"
	cTipoNF := "Normal"
Elseif aCabNFE[1,7] == "D"
	cTipoNF := "Devolução"

	SA1->(OrdSetFocus(1))
	SA1->(Dbseek(xFilial("SA1") + cCodForn +cLojForn )) //Cliente
	cNomeForn  	:= SA1->A1_NOME 
	

Elseif aCabNFE[1,7] == "B"
	cTipoNF := "Beneficiamento"

	SA1->(OrdSetFocus(1))
	SA1->(Dbseek(xFilial("SA1") + cCodForn +cLojForn )) //Cliente
	cNomeForn  	:= SA1->A1_NOME 
Else
	cTipoNF := "---"
Endif
nValmerc   	:= aCabNFE[1,8]
nValbrut   	:= aCabNFE[1,9]
nBasCof    	:= aCabNFE[1,16]
nBaseICM   	:= aCabNFE[1,10]
nBaseIPI   	:= aCabNFE[1,12]
nBasePIS   	:= aCabNFE[1,14]
nBasIR     	:= aCabNFE[1,18]
nValCOF    	:= aCabNFE[1,17]
nValICM    	:= aCabNFE[1,11]
nVALIPI    	:= aCabNFE[1,13]
nValIR     	:= aCabNFE[1,19]	
nValPISi   	:= aCabNFE[1,15]
//FR - 09/02/2022 - alteração - Petra - correção qdo acessada opção "análise fiscal" dentro de "classificar nf"
If Len(aCabNFE[1]) >= 22
	nISSALQ     := aCabNFE[1,22]
	nISSVAL 	:= aCabNFE[1,23]
	nINSVAL     := aCabNFE[1,24]
	nINSALQ     := aCabNFE[1,25]
	nCSLALQ     := aCabNFE[1,26]
	nCSLVAL     := aCabNFE[1,27]
	nAliqICM    := aCabNFE[1,28]
	nValICM     := aCabNFE[1,29]
Endif 
If Len(aCabNFE[1]) >= 20
	nBasICMST   := aCabNFE[1,20]
	nValICMST   := aCabNFE[1,21]
	nAliqICMST  := Round((nValICMST / nBasICMST) * 100,2)		//FR - 11/01/2022 - PETRA - INCLUIR CAMPO ICM ST
Endif 

//---------------------------------------------------------//
//definição das cores dos gets, segundo divergencia ou nao;
//---------------------------------------------------------//
//VALOR MERCADORIA 
aCores := U_fVerDivCab(xValmerc,aCabNFE,1,8,@lDiverg) 
xCorFo1  := aCores[1] 	//CLR_HBLUE
xCorFu1 := aCores[2]  //CLR_YELLOW  	//se quiser usar cor de fundo na divergencia, amarelo
//VALOR BRUTO
aCores := U_fVerDivCab(xValbrut,aCabNFE,1,9,@lDiverg) 
xCorFo2 := aCores[1] 
xCorFu2:= aCores[2] 	  
//ICM
//base icm
//aCores := U_fVerDivCab(xBasicm,aCabNFE,1,10) 
//xCorFo3 := aCores[1]
//xCorFu3:= aCores[2]  	
//vlr icm
aCores := U_fVerDivCab(xValicm,aCabNFE,1,11,@lDiverg) 
xCorFo4 := aCores[1]
xCorFu4:= aCores[2]  	
//IPI
//base ipi
//aCores := U_fVerDivCab(xBasipi,aCabNFE,1,12) 
//xCorFo5 := aCores[1]
//xCorFu5 := aCores[2]  
//vlr ipi
aCores := U_fVerDivCab(xValipi,aCabNFE,1,13,@lDiverg) 
xCorFo6 := aCores[1]
xCorFu6:= aCores[2]  
//PIS
//base pis
//aCores   := U_fVerDivCab(xBaspis,aCabNFE,1,14) 
//xCorFo7  := aCores[1]
//xCorFu7 := aCores[2]  
//vlr pis
aCores := U_fVerDivCab(xValpis,aCabNFE,1,15,@lDiverg) 
xCorFo8 := aCores[1]
xCorFu8:= aCores[2]  
//COFINS
//base cofins 
//aCores   := U_fVerDivCab(xBascofi,aCabNFE,1,16) 
//xCorFo9  := aCores[1]
//xCorFu9 := aCores[2]  
//vlr cofins
aCores := U_fVerDivCab(xValcof,aCabNFE,1,17,@lDiverg) 
xCorFo10  := aCores[1]
xCorFu10 := aCores[2]  
//IR
//base IR
//aCores := U_fVerDivCab(xBaseir,aCabNFE,1,18) 
//xCorFo11  := aCores[1]
//xCorFu11 := aCores[2] 
//vlr IR
aCores := U_fVerDivCab(xValir,aCabNFE,1,19,@lDiverg) 
xCorFo12  := aCores[1]
xCorFu12 := aCores[2]  
//Ncm
//aCores := U_fVerDivCab(xNCM,aIteNFE,1,24,@lDiverg) 
//xCorFo12  := aCores[1]
//xCorFu12 := aCores[2]  
//fim verificação de divergencias para definição de cores
//gera massa de dados a ser exibida no listbox de cada quadrante (xml e nf):

//vlr ICM ST
If Len(aCabNFE[1]) >= 20
	aCores   := U_fVerDivCab(xValICMST,aCabNFE,1,21,@lDiverg) 
	xCorFo27 := aCores[1]
	xCorFu27 := aCores[2] 
Endif  

GerArqNFE(cARQTMP,aESTRUT,aIteNFE)		//FR - 06/07/2021 - Rafael pediu para mostrar os itens da nf e não do xml
GerarqXML(xARQTMP,aESTRUT,aIteXML) 		//FR - 06/07/2021 - Rafael pediu para mostrar os itens da nf e não do xml

//FR
//Verifica divergencia entre os itens:
//somente para chamada de fora via execauto:
If lOmiTTela
	DbSelectArea("XEXP")
	XEXP->(DbGoTop())
	If XEXP->(!Eof())
		While XEXP->(!Eof())
			fMostraVlr(XEXP->ITEM,xEspeciNF,cChave,@xBaseICM,@xAliqICM,@xValICMi,;
					 @xBaseIPI,@xAliqIPI,@xVALIPIi,;
					 @xBasePIS,@xAliqpis,@xValPISi,@xValPIS,;
					 @xBasCof,@xAliqCof,@xValCOFi,;
					 @xBasIR ,@xAliqIR ,@xValIRi,;
					 @xBasICMST,@xAliqICMST,@xValICMiS,@xAliqICM,@xValICM,;
					 aIteNFE,;
					 @nBaseICM,@nAliqICM,@nValICMi,;
					 @nBaseIPI,@nAliqIPI,@nVALIPIi,;
					 @nBasePIS,@nAliqpis,@nValPISi,;
			  		 @nBasCof,@nAliqCof,@nValCOFi,;
			  		 @nBasIR ,@nAliqIR ,@nValIRi,;
			  		 @nBasICMST,@nAliqICMST,@nValICMiS,@nValICM,;
			  		 lOmiTTela,@lDiverg,xXml,@xNCM,@cNCM,@xISSVAL,@nISSVAL,@xINSVAL,@nINSVAL,@cItem,@xISSALQ,@xINSALQ,@xCSLALQ,@xCSLVAL;
			)
			XEXP->(Dbskip())
		Enddo
	Endif
Endif

//FR
//----------------------------------------------------//
//Definicao do Dialog e todos os seus componentes.  
//----------------------------------------------------//
If lOmiTTela == Nil .and. lDiverg //mostra a tela se lOmiTTela == NIL e tiver divergencia

	CALCTELA() // advsize() 
	
	cTITULO := "DIVERGÊNCIAS XML x " + cTipoDoc		//NOTA FISCAL ou PEDIDO DE COMPRA
	If aPedidos <> Nil  
		cTITULO += " -> "
		For fr := 1 to Len(aPedidos)
			If fr < Len(aPedidos)
				cTITULO += aPedidos[fr] + "/"
			Else
				cTITULO += aPedidos[fr]
			Endif
		Next
	Endif
	
	//aSIZE   := {0,30,676,298,1352,596,0,5} //TESTE RESOLUCAO
	//medidas para dialog
	nCoLimite := aSIZE[5]-(aSIZE[5]*0.15) 
	nLiLimite := aSIZE[6]      
	
	//medidas para objetos tela
	nLiini	:= 1       
	nCoMeio	:= aSize[3]
	nLiMeio	:= aSize[4]
	nCoini	:= aSIZE[8]	

	/////////////////////////
	// MONTAGEM DA DIALOG: //
	/////////////////////////

	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//														 OBSERVAÇÃO															//
	//																															//
	//	Definir MsDialog oDlg1 TITLE cTITULO STYLE DS_MODALFRAME From aSize[7],0 To aSize[6],nCoLimite-3 OF oMainWnd PIXEL		//
	//  Se não utilizar o MsAdvSize, pode-se utilizar a propriedade lMaximized igual a T para maximizar a janela				//
	//  oDialog:lMaximized := .T. //Maximiza a janela																			//
	// 	Usando o estilo STYLE DS_MODALFRAME, remove o botão X																	//
	// 																															//
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


	
	Define MsDialog oDlg1 TITLE cTITULO STYLE DS_MODALFRAME From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL
	
	// Divisão do tamanho dos grids para modelos específicos - Erick G. - 25/11/2022
	If xModelo == "55"
		oGrp1 := TGroup():New(nLiini+1      , nCoini         , (nLiMeio*0.78), (nCoMeio*0.5)-1, " CABEÇALHO DO XML: "        , oDlg1, CLR_HBLUE, CLR_WHITE, .T., .F.) //001,005 Liini,Coini / 223,376 Lifim,Cofim
		oGrp5 := TGroup():New(nLiini+1      , (nCoMeio*0.5)+1, (nLiMeio*0.78), nCoMeio-nCoIni , " CABEÇALHO DA NOTA FISCAL: ", oDlg1, CLR_HBLUE, CLR_WHITE, .T., .F.) //001,381 ; 223,746
		oGrp4 := TGroup():New((nLiMeio*0.79), nCoini         , (nLiMeio*0.96), nCoMeio-nCoIni , " ITENS DA NOTA "            , oDlg1, CLR_HBLUE, CLR_WHITE, .T., .F.) //228,5 ; 423,376	//FR - 06/07/2021
	Else
		oGrp1 := TGroup():New(nLiini+1      , nCoini         , (nLiMeio*0.73), (nCoMeio*0.5)-1, " CABEÇALHO DO XML: "        , oDlg1, CLR_HBLUE, CLR_WHITE, .T., .F.) //001,005 Liini,Coini / 223,376 Lifim,Cofim
		oGrp5 := TGroup():New(nLiini+1      , (nCoMeio*0.5)+1, (nLiMeio*0.73), nCoMeio-nCoIni , " CABEÇALHO DA NOTA FISCAL: ", oDlg1, CLR_HBLUE, CLR_WHITE, .T., .F.) //001,381 ; 223,746
		oGrp4 := TGroup():New((nLiMeio*0.73), nCoini         , (nLiMeio*0.95), nCoMeio-nCoIni , " ITENS DA NOTA "            , oDlg1, CLR_HBLUE, CLR_WHITE, .T., .F.) //228,5 ; 423,376	//FR - 06/07/2021
	EndIf
	
	If lVisual
		oBtn2 := TButton():New((nLiMeio*0.96), (nCoMeio*0.5)-15, "Fechar"             , oDlg1, {|| (oDlg1:End(),nOpgera := 0)}                                             , 037, 012, , , , .T., , "", , , , .F.)
	Else
		oBtn1 := TButton():New((nLiMeio*0.96), (nCoMeio*0.5)-85, "Aceita Divergências", oDlg1, {|| (oDlg1:End(),nOpgera := 1)}                                             , 057, 012, , , , .T., , "", , , , .F.)
		oBtn2 := TButton():New((nLiMeio*0.96), (nCoMeio*0.5)-15, "Cancela"            , oDlg1, {|| (oDlg1:End(),nOpgera := 0), MsgInfo("Cancelado Pelo Operador.","Aviso")}, 037, 012, , , , .T., , "", , , , .F.)
	EndIf


	oBtn3      := TButton():New( (nLiMeio*0.96) ,(nCoMeio*0.5)+35,"Exporta Excel"		,oDlg1,{|| (nOpgera := 0), U_fExpEXCL(xDocto,xSerie,xCodForn,xLojForn) },037,012,,,,.T.,,"",,,,.F. )   
	
	
	nLin := 15
	oSay1      := TSay():New( nLin,010,{||"Documento:"} 		,oGrp1,,,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,032,008)
	oSay2      := TSay():New( nLin,113,{||"Série:"}	   			,oGrp1,,,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,017,008)
	oSay20     := TSay():New( nLin,162,{||"Emissão:"}			,oGrp1,,,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,023,008)
	oGet1      := TGet():New( nLin-1,047,{|u| If(PCount()>0,xDocto:=u,xDocto)}		,oGrp1,060,008,'@!',,CLR_BLACK,CLR_WHITE,,,,.T.		,"",,,.F.,.F.,,.T.,.F.,"","xDocto",,)
	oGet2      := TGet():New( nLin-1,130,{|u| If(PCount()>0,xSerie:=u,xSerie)}		,oGrp1,020,008,'@!',,CLR_BLACK,CLR_WHITE,,,,.T.		,"",,,.F.,.F.,,.T.,.F.,"","xSerie",,)
	oGet16     := TGet():New( nLin-1,191,{|u| If(PCount()>0,xEmissao:=u,xEmissao)}	,oGrp1,060,008,'@D',,CLR_BLACK,CLR_WHITE,,,,.T.		,"",,,.F.,.F.,,.T.,.F.,"","xEmissao",,)
	
	
	nLin += 15
	If UPPER(xTipoNF) <> "DEVOLUÇÃO" .and. UPPER(xTipoNF) <> "BENEFICIAMENTO"
		oSay3      := TSay():New( nLin,010,{||"Fornecedor:"}		,oGrp1,,,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,031,008) 
	Else 
		oSay3      := TSay():New( nLin,010,{||"Cliente:"}		,oGrp1,,,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,031,008) 
	Endif 
	oSay4      := TSay():New( nLin,113,{||"Loja:"}	   			,oGrp1,,,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,014,008)
	oSay5      := TSay():New( nLin,162,{||"Nome:"}				,oGrp1,,,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,019,008)
	oGet3      := TGet():New( nLin-1,047,{|u| If(PCount()>0,xCodForn:=u,xCodForn)}	,oGrp1,047,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.		,"",,,.F.,.F.,,.T.,.F.,"","xCodForn",,)
	oGet4      := TGet():New( nLin-1,130,{|u| If(PCount()>0,xLojForn:=u,xLojForn)}	,oGrp1,018,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.		,"",,,.F.,.F.,,.T.,.F.,"","xLojForn",,)
	oGet5      := TGet():New( nLin-1,191,{|u| If(PCount()>0,xNomeForn:=u,xNomeForn)}	,oGrp1,135,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.		,"",,,.F.,.F.,,.T.,.F.,"","xNomeForn",,)
	

	nLin += 15
	oSay3t     := TSay():New( nLin,010,{||"Tipo:"}				,oGrp1,,,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,031,008) 
	oSay4e     := TSay():New( nLin,162,{||"Espécie"}   			,oGrp1,,,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,023,008)
	oGet3t     := TGet():New( nLin-1,047,{|u| If(PCount()>0,xTipoNF:=u,xTipoNF)} 		,oGrp1,047,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.		,"",,,.F.,.F.,,.T.,.F.,"","xTipoNF",,)
	oGet4e     := TGet():New( nLin-1,191,{|u| If(PCount()>0,xEspeciNF:=u,xEspeciNF)} 	,oGrp1,047,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.		,"",,,.F.,.F.,,.T.,.F.,"","xEspeciNF",,)
	


	//Recalcula com base no tamanho do grid (27%)
	nLinAux := (nLiMeio*0.73) * 0.276 
	nLin := nLinAux


	 //linha separadora      
	oGrp2      := TGroup():New( nLin,nCoini+5,nLin+10,(nCoMeio*0.5)-nCoini,"",oGrp1,CLR_BLACK,CLR_WHITE,.T.,.F. )  
	oSay19     := TSay():New( nLin+2,125,{||"TOTAIS DO XML"},oGrp2,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,115,022)
	
	nLin += 15
	oSay8      := TSay():New( nLin,030,{||"VLR TOTAL:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,055,008)
	oSay9      := TSay():New( nLin,135,{||"VLR BRUTO:"}		,oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,045,008)
	oGet6      := TGet():New( nLin-1,065,{|u| If(PCount()>0,xValmerc:=u,xValmerc)},oGrp1,060,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","xValmerc",,)
	oGet7      := TGet():New( nLin-1,170,{|u| If(PCount()>0,xValbrut:=u,xValbrut)},oGrp1,060,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","xValbrut",,)
	

	//FR - 11/01/2022 - Petra - incluir campo ICMST
	oSay80     := TSay():New( nLin-1,235,{||"Vlr ICM ST:"},oGrp1,,,.F.,.F.,.F.,.T.,xCorFo27,xCorFu27,053,048)   //FR - 11/01/2022
	oGet62     := TGet():New( nLin-1,268,{|u| If(PCount()>0,nValICMST:=u,nValICMST)},oGrp1,060,008,'@E 999,999,999.99',,xCorFo27,xCorFu27,,,,.T.	,"",,,.F.,.F.,,.F.,.F.,"","nValICMST",,)
	

	//TOTAIS:
	nLin += 13
	oSay11     := TSay():New( nLin  ,010,{||"Valor ICMS:"}	,oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,053,048) 
	oSay12     := TSay():New( nLin	,075,{||"Valor IPI:"}	,oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,053,048)
	oSay13     := TSay():New( nLin  ,140,{||"Valor PIS:"}	,oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,053,048)
	oSay14     := TSay():New( nLin  ,205,{||"Valor COFINS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,053,048)
	oSay21     := TSay():New( nLin  ,270,{||"Valor IR:"}	,oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,053,048)   //CLR_HBLUE
	

	nLin += 8
	oGet8      := TGet():New( nLin	,010,{|u| If(PCount()>0,xValICM:=u,xValICM)},oGrp1,060,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","xValICM",,)
	oGet9      := TGet():New( nLin	,075,{|u| If(PCount()>0,xVALIPI:=u,xVALIPI)},oGrp1,060,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","xVALIPI",,)
	oGet10     := TGet():New( nLin	,140,{|u| If(PCount()>0,xValPIS:=u,xValPIS)},oGrp1,060,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","xValPIS",,)
	oGet11     := TGet():New( nLin	,205,{|u| If(PCount()>0,xValCOF:=u,xValCOF)},oGrp1,060,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","xValCOF",,)
	oGet17     := TGet():New( nLin	,270,{|u| If(PCount()>0,xValIR:=u,xValIR)}  ,oGrp1,060,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.	,"",,,.F.,.F.,,.F.,.F.,"","xValIR",,)
	//FR - 11/01/2022 - Petra - incluir campo ICMST
	
	

	//Recalcula com base no tamanho do grid (51%)
	nLinAux := (nLiMeio*0.73) * 0.51 
	nLin := nLinAux


	//Linha separadora  
	oGrp3      := TGroup():New( nLin,nCoini+5,nLin+10,(nCoMeio*0.5)-nCoini,"",oGrp1,CLR_BLACK,CLR_WHITE,.T.,.F. )        
	oSay19     := TSay():New( nLin+2,125,{||"ITENS DO XML"},oGrp3,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,115,022) 

	// Erick G. - Itens do Xml para cada tipo de nota. - 25/11/2022
	If xModelo == "55" // NFE

		nLin += 13
		oSay93     := TSay():New( nLin,070,{||"Aliq ISS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay91     := TSay():New( nLin,125,{||"Valor ISS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay43     := TSay():New( nLin,225,{||"Aliq PIS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay56     := TSay():New( nLin,275,{||"Valor PIS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)

		nLin += 7
		oSay94     := TSay():New( nLin,010,{||"ISS  "}	,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		oGet93     := TGet():New( nLin,070,{|u| If(PCount()>0,xISSALQ :=u,xISSALQ)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","xISSALQ",,) 
		oGet90     := TGet():New( nLin,125,{|u| If(PCount()>0,xISSVAL :=u,xISSVAL)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","xISSVAL",,) 

		oSay67     := TSay():New( nLin,180,{||"PIS   "}	,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		oGet39     := TGet():New( nLin,225,{|u| If(PCount()>0,xAliqpis:=u,xAliqpis)},oGrp1,045,008,'@E 999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","xAliqpis",,)
		oGet50     := TGet():New( nLin,275,{|u| If(PCount()>0,xValPISi:=u,xValPISi)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","xValPISi",,)
		
		nLin += 13
		oSay44     := TSay():New( nLin,070,{||"Aliq. COFINS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay57     := TSay():New( nLin,125,{||"Valor COFINS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,053,008) 
		oSay102    := TSay():New( nLin,225,{||"Aliq INSS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008) 
		oSay104    := TSay():New( nLin,275,{||"Valor INSS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,053,008)

		nLin += 10
		oSay68     := TSay():New( nLin,010,{||"COFINS	"}	  ,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		oGet40     := TGet():New( nLin,070,{|u| If(PCount()>0,xAliqCof:=u,xAliqCof)},oGrp1,045,008,'@E 99.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","xAliqCof",,)
		oGet51     := TGet():New( nLin,125,{|u| If(PCount()>0,xValCOFi:=u,xValCOFi)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","xValCOFi",,)

		oSay95     := TSay():New( nLin,180,{||"INSS   "} ,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		oGet96     := TGet():New( nLin,225,{|u| If(PCount()>0,xINSALQ :=u,xINSALQ)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","xINSALQ",,) 
		oGet92     := TGet():New( nLin,275,{|u| If(PCount()>0,xINSVAL :=u,xINSVAL)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","xINSVAL",,) 
		
		nLin += 12
		oSay50     := TSay():New( nLin,070,{||"Aliq. IR:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay58     := TSay():New( nLin,125,{||"Valor IR:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,053,048) 
		oSay98     := TSay():New( nLin,225,{||"Aliq. CSLL:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay99     := TSay():New( nLin,275,{||"Valor CSLL:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)

		nLin += 10
		oSay69     := TSay():New( nLin,010,{||"IR    "} ,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		oGet41     := TGet():New( nLin,070,{|u| If(PCount()>0,xAliqIR:=u,xAliqIR)},oGrp1,045,008,'@E 99.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","xAliqIR",,)
		oGet52     := TGet():New( nLin,125,{|u| If(PCount()>0,xValIRi:=u,xValIRi)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.	,"",,,.F.,.F.,,.F.,.F.,"","xValIRi",,)

		oSay97     := TSay():New( nLin,180,{||"CSLL   "} 	,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		oGet98     := TGet():New( nLin,225,{|u| If(PCount()>0,xCSLALQ:=u,xCSLVAL)},oGrp1,045,008,'@E 99.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","xCSLALQ",,)
		oGet104    := TGet():New( nLin,275,{|u| If(PCount()>0,xCSLVAL:=u,xCSLVAL)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","xCSLVAL",,) 

		nLin += 13
		//oSay15     := TSay():New( nLin,070,{||"Base ICMS:"},oGrp5,,,.F.,.F.,.F.,.T.,xCorFo3,xCorFu3,032,008)
		oSay41     := TSay():New( nLin,070,{||"Aliq. ICMS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay52     := TSay():New( nLin,125,{||"Valor ICMS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay54     := TSay():New( nLin,225,{||"Aliq. IPI:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay55     := TSay():New( nLin,275,{||"Valor IPI:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,053,008)
	
		nLin += 8
		oSay61     := TSay():New( nLin,010,{||"ICMS"} ,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		//oGet46     := TGet():New( nLin,070,{|u| If(PCount()>0,xBaseICM:=u,xBaseICM)},oGrp1,040,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","xBaseICM",,) 
		oGet47     := TGet():New( nLin,70,{|u| If(PCount()>0,xAliqICM:=u,xAliqICM)},oGrp1,045,008,'@E 99.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","xAliqICM",,)
		oGet48     := TGet():New( nLin,125,{|u| If(PCount()>0,xValICM:=u,xValICM)},oGrp1,045,008,'@E 99.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","xValICM",,)
	
		oSay66     := TSay():New( nLin,180,{||"IPI"} ,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		oGet38     := TGet():New( nLin,225,{|u| If(PCount()>0,xAliqIPI:=u,xAliqIPI)},oGrp1,045,008,'@E 99.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","xAliqIPI",,)
		oGet49     := TGet():New( nLin,275,{|u| If(PCount()>0,xValIPIi:=u,xValIPIi)},oGrp1,045,008,'@E 99.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","xValIPIi",,)

		nLin += 12
		oSay75     := TSay():New( nLin,070,{||"Class. Fiscal:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)

		nLin += 9
		// Nomenclatura e Get do NCM
		oSay75     := TSay():New( nLin,010,{||"NCM    "} ,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		oGet59     := TGet():New( nLin,070,{|u| If(PCount()>0,xNCM:=u,xNCM)},oGrp1,045,008,'@E 99999999999',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","xNCM",,)

	Elseif xModelo == "57" // CTE

		nLin += 13
		oSay93     := TSay():New( nLin,070,{||"Aliq ISS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay91     := TSay():New( nLin,125,{||"Valor ISS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay43     := TSay():New( nLin,230,{||"Aliq PIS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay56     := TSay():New( nLin,280,{||"Valor PIS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,053,008)


		nLin += 7
		oSay94     := TSay():New( nLin,010,{||"ISS"},oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		oGet93     := TGet():New( nLin,070,{|u| If(PCount()>0,xISSALQ :=u,xISSALQ)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","xISSALQ",,) 
		oGet90     := TGet():New( nLin,125,{|u| If(PCount()>0,xISSVAL :=u,xISSVAL)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","xISSVAL",,) 


		oSay67     := TSay():New( nLin,175,{||"PIS"}	,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		oGet39     := TGet():New( nLin,230,{|u| If(PCount()>0,xAliqpis:=u,xAliqpis)},oGrp1,045,008,'@E 999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","xAliqPIS",,)
		oGet50     := TGet():New( nLin,280,{|u| If(PCount()>0,xValPISi:=u,xValPISi)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","xValPIS",,)	

		nLin += 13
		oSay44     := TSay():New( nLin,070,{||"Aliq. COFINS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay57     := TSay():New( nLin,125,{||"Valor COFINS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,053,008)
		oSay102    := TSay():New( nLin,230,{||"Aliq INSS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay104    := TSay():New( nLin,280,{||"Valor INSS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,053,008)


		nLin += 7
		oSay68     := TSay():New( nLin,010,{||"COFINS"}	  ,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		oGet40     := TGet():New( nLin,070,{|u| If(PCount()>0,xAliqCof:=u,xAliqCof)},oGrp1,045,008,'@E 99.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","xAliqCof",,)
		oGet51     := TGet():New( nLin,125,{|u| If(PCount()>0,xValCOFi:=u,xValCOFi)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","xValCOFi",,)


		oSay95     := TSay():New( nLin,175,{||"INSS"} ,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		oGet96     := TGet():New( nLin,230,{|u| If(PCount()>0,xINSALQ :=u,xINSALQ)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","xINSALQ",,) 
		oGet92     := TGet():New( nLin,280,{|u| If(PCount()>0,xINSVAL :=u,xINSVAL)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","xINSVAL",,) 
	

		nLin += 13
		oSay50     := TSay():New( nLin,070,{||"Aliq. IR:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay58     := TSay():New( nLin,125,{||"Valor IR:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay98     := TSay():New( nLin,230,{||"Aliq CSLL:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay99     := TSay():New( nLin,280,{||"Valor CSLL:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,053,008)


		nLin += 7
		oSay69     := TSay():New( nLin,010,{||"IR"} ,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		oGet41     := TGet():New( nLin,070,{|u| If(PCount()>0,xAliqIR:=u,xAliqIR)},oGrp1,045,008,'@E 99.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","xAliqIR",,)
		oGet52     := TGet():New( nLin,125,{|u| If(PCount()>0,xValIRi:=u,xValIRi)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.	,"",,,.F.,.F.,,.F.,.F.,"","xValIRi",,)

		oSay97     := TSay():New( nLin,175,{||"CSLL"} ,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		oGet98     := TGet():New( nLin,230,{|u| If(PCount()>0,xCSLALQ:=u,xCSLALQ)},oGrp1,045,008,'@E 99.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","xCSLALQ",,)
		oGet104    := TGet():New( nLin,280,{|u| If(PCount()>0,xCSLVAL :=u,xCSLVAL)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","xCSLVAL",,) 


		nLin += 13
		oSay41     := TSay():New( nLin,070,{||"Aliq. ICMS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay52     := TSay():New( nLin,125,{||"Valor ICMS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		//oSay54     := TSay():New( nLin,230,{||"Aliq IPI:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		//oSay55     := TSay():New( nLin,280,{||"Valor IPI:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,053,008)

		nLin += 7
		oSay65     := TSay():New( nLin,010,{||"ICMS"} ,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		oGet47     := TGet():New( nLin,070,{|u| If(PCount()>0,xAliqICM:=u,xAliqICM)},oGrp1,045,008,'@E 99.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","xAliqICM",,)
		oGet48     := TGet():New( nLin,125,{|u| If(PCount()>0,xValICM:=u,xValICM)},oGrp1,045,008,'@E 99.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","xValICM",,)

		// Foi solicitado a exclusão do campo de imposto no Cte
		// oSay66     := TSay():New( nLin,175,{||"IPI"} ,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		// oGet38     := TGet():New( nLin,230,{|u| If(PCount()>0,xAliqIPI:=u,xAliqIPI)},oGrp1,045,008,'@E 99.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","xAliqIPI",,)
		// oGet49     := TGet():New( nLin,280,{|u| If(PCount()>0,xValIPIi:=u,xValIPIi)},oGrp1,045,008,'@E 99.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","xValIPIi",,)
	
	Elseif xModelo == "65" // NFCe

		nLin += 13
		oSay41     := TSay():New( nLin,070,{||"Aliq ICMS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay52     := TSay():New( nLin,125,{||"Valor ICMS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay43     := TSay():New( nLin,225,{||"Aliq PIS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay56     := TSay():New( nLin,275,{||"Valor PIS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)


		nLin += 7
		oSay61     := TSay():New( nLin,010,{||"ICMS  "}	,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		oGet47     := TGet():New( nLin,070,{|u| If(PCount()>0,xAliqICM :=u,xAliqICM)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","xAliqICM",,) 
		oGet48     := TGet():New( nLin,125,{|u| If(PCount()>0,xValICM :=u,xValICM)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","xValICM",,) 

		oSay67     := TSay():New( nLin,180,{||"PIS"} ,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		oGet39     := TGet():New( nLin,225,{|u| If(PCount()>0,xAliqpis:=u,xAliqpis)},oGrp1,045,008,'@E 99.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","xAliqpis",,)
		oGet50     := TGet():New( nLin,275,{|u| If(PCount()>0,xValPISi:=u,xValPISi)},oGrp1,045,008,'@E 99.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","xValPISi",,)

		nLin += 13
		oSay44     := TSay():New( nLin,070,{||"Aliq. COFINS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay57     := TSay():New( nLin,125,{||"Valor COFINS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,053,008) 
		oSay50    := TSay():New( nLin,225,{||"Aliq IRPJ:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008) 
		oSay58    := TSay():New( nLin,275,{||"Valor IRPJ:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,053,008)

		nLin += 10
		oSay68     := TSay():New( nLin,010,{||"COFINS	"}	  ,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		oGet40     := TGet():New( nLin,070,{|u| If(PCount()>0,xAliqCof:=u,xAliqCof)},oGrp1,045,008,'@E 99.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","xAliqCof",,)
		oGet51     := TGet():New( nLin,125,{|u| If(PCount()>0,xValCOFi:=u,xValCOFi)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","xValCOFi",,)

		oSay69     := TSay():New( nLin,180,{||"IRPJ   "} ,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		oGet41     := TGet():New( nLin,225,{|u| If(PCount()>0,xAliqIR :=u,xAliqIR)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","xAliqIR",,) 
		oGet52     := TGet():New( nLin,275,{|u| If(PCount()>0,xValIRi :=u,xValIRi)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","xValIRi",,) 
	
		nLin += 12
		oSay98     := TSay():New( nLin,070,{||"Aliq. CSLL:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay99     := TSay():New( nLin,125,{||"Valor CSLL:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,053,048) 
		//oSay98     := TSay():New( nLin,225,{||"Aliq. CPP:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		//oSay99     := TSay():New( nLin,275,{||"Valor CPP:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)

		nLin += 10
		oSay97     := TSay():New( nLin,010,{||"CSLL    "} ,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		oGet98     := TGet():New( nLin,070,{|u| If(PCount()>0,xCSLALQ:=u,xCSLALQ)},oGrp1,045,008,'@E 99.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","xCSLALQ",,)
		oGet104     := TGet():New( nLin,125,{|u| If(PCount()>0,xCSLVAL:=u,xCSLVAL)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.	,"",,,.F.,.F.,,.F.,.F.,"","xCSLVAL",,)

		//oSay97     := TSay():New( nLin,180,{||"CPP   "} 	,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		//oGet98     := TGet():New( nLin,225,{|u| If(PCount()>0,xCSLALQ:=u,xCSLVAL)},oGrp1,045,008,'@E 99.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","xCSLALQ",,)
		//oGet104    := TGet():New( nLin,275,{|u| If(PCount()>0,xCSLVAL:=u,xCSLVAL)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","xCSLVAL",,) 

	Elseif xModelo == "67" // CTE-OS

		nLin += 13
		oSay41     := TSay():New( nLin,070,{||"Aliq ICMS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay52     := TSay():New( nLin,125,{||"Valor ICMS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay43     := TSay():New( nLin,225,{||"Aliq PIS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay56     := TSay():New( nLin,275,{||"Valor PIS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)


		nLin += 7
		oSay61     := TSay():New( nLin,010,{||"ICMS  "}	,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		oGet47     := TGet():New( nLin,070,{|u| If(PCount()>0,xAliqICM :=u,xAliqICM)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","xAliqICM",,) 
		oGet48     := TGet():New( nLin,125,{|u| If(PCount()>0,xValICM :=u,xValICM)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","xValICM",,) 

		oSay67     := TSay():New( nLin,180,{||"PIS"} ,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		oGet39     := TGet():New( nLin,225,{|u| If(PCount()>0,xAliqpis:=u,xAliqpis)},oGrp1,045,008,'@E 99.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","xAliqpis",,)
		oGet50     := TGet():New( nLin,275,{|u| If(PCount()>0,xValPISi:=u,xValPISi)},oGrp1,045,008,'@E 99.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","xValPISi",,)

		nLin += 13
		oSay44     := TSay():New( nLin,070,{||"Aliq. COFINS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay57     := TSay():New( nLin,125,{||"Valor COFINS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,053,008) 
		oSay50    := TSay():New( nLin,225,{||"Aliq IPI:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008) 
		oSay58    := TSay():New( nLin,275,{||"Valor IPI:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,053,008)

		nLin += 10
		oSay68     := TSay():New( nLin,010,{||"COFINS	"}	  ,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		oGet40     := TGet():New( nLin,070,{|u| If(PCount()>0,xAliqCof:=u,xAliqCof)},oGrp1,045,008,'@E 99.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","xAliqCof",,)
		oGet51     := TGet():New( nLin,125,{|u| If(PCount()>0,xValCOFi:=u,xValCOFi)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","xValCOFi",,)

		oSay69     := TSay():New( nLin,180,{||"IPI   "} ,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		oGet41     := TGet():New( nLin,225,{|u| If(PCount()>0,xAliqIPI :=u,xAliqIPI)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","xAliqIPI",,) 
		oGet52     := TGet():New( nLin,275,{|u| If(PCount()>0,xVALIPIi :=u,xVALIPIi)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","xVALIPIi",,) 
	
		nLin += 13
		oSay75     := TSay():New( nLin,070,{||"Class. Fiscal:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		//oSay98     := TSay():New( nLin,225,{||"Aliq. CPP:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		//oSay99     := TSay():New( nLin,275,{||"Valor CPP:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)

		nLin += 10
		oSay75     := TSay():New( nLin,010,{||"NCM    "} ,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		oGet59     := TGet():New( nLin,070,{|u| If(PCount()>0,xNCM:=u,xNCM)},oGrp1,045,008,'@E 99999999999',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","xNCM",,)

		//oSay97     := TSay():New( nLin,180,{||"CPP   "} 	,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		//oGet98     := TGet():New( nLin,225,{|u| If(PCount()>0,xCSLALQ:=u,xCSLVAL)},oGrp1,045,008,'@E 99.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","xCSLALQ",,)
		//oGet104    := TGet():New( nLin,275,{|u| If(PCount()>0,xCSLVAL:=u,xCSLVAL)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","xCSLVAL",,) 

	Elseif xModelo == "RP" // NFS-e

		nLin += 13
		oSay93     := TSay():New( nLin,070,{||"Aliq ISS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay91     := TSay():New( nLin,125,{||"Valor ISS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay43     := TSay():New( nLin,225,{||"Aliq PIS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay56     := TSay():New( nLin,275,{||"Valor PIS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)


		nLin += 7
		oSay94     := TSay():New( nLin,010,{||"ISS  "}	,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		oGet93     := TGet():New( nLin,070,{|u| If(PCount()>0,xISSALQ :=u,xISSALQ)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","xISSALQ",,) 
		oGet90     := TGet():New( nLin,125,{|u| If(PCount()>0,xISSVAL :=u,xISSVAL)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","xISSVAL",,) 


		oSay67     := TSay():New( nLin,180,{||"PIS   "}	,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		oGet39     := TGet():New( nLin,225,{|u| If(PCount()>0,xAliqpis:=u,xAliqpis)},oGrp1,045,008,'@E 999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","xAliqpis",,)
		oGet50     := TGet():New( nLin,275,{|u| If(PCount()>0,xValPIS:=u,xValPIS)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","xValPIS",,)
		

		nLin += 13
		oSay44     := TSay():New( nLin,070,{||"Aliq. COFINS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay57     := TSay():New( nLin,125,{||"Valor COFINS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,053,008) 
		oSay102    := TSay():New( nLin,225,{||"Aliq INSS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008) 
		oSay104    := TSay():New( nLin,275,{||"Valor INSS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,053,008)


		nLin += 10
		oSay68     := TSay():New( nLin,010,{||"COFINS	"}	  ,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		oGet40     := TGet():New( nLin,070,{|u| If(PCount()>0,xAliqCof:=u,xAliqCof)},oGrp1,045,008,'@E 99.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","xAliqCof",,)
		oGet51     := TGet():New( nLin,125,{|u| If(PCount()>0,xValCOFi:=u,xValCOFi)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","xValCOFi",,)


		oSay95     := TSay():New( nLin,180,{||"INSS   "} ,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		oGet96     := TGet():New( nLin,225,{|u| If(PCount()>0,xINSALQ :=u,xINSALQ)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","xINSALQ",,) 
		oGet92     := TGet():New( nLin,275,{|u| If(PCount()>0,xINSVAL :=u,xINSVAL)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","xINSVAL",,) 
		

		nLin += 12
		oSay45     := TSay():New( nLin,070,{||"Aliq. IR:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay58     := TSay():New( nLin,125,{||"Valor IR:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,053,048) 
		oSay98     := TSay():New( nLin,225,{||"Aliq. CSLL:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay99     := TSay():New( nLin,275,{||"Valor CSLL:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)


		nLin += 10
		oSay69     := TSay():New( nLin,010,{||"IR    "} ,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		oGet41     := TGet():New( nLin,070,{|u| If(PCount()>0,xAliqIR:=u,xAliqIR)},oGrp1,045,008,'@E 99.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","xAliqIR",,)
		oGet52     := TGet():New( nLin,125,{|u| If(PCount()>0,xValIRi:=u,xValIRi)},oGrp1,045,008,'@E 99.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","xValIRi",,)


		oSay97     := TSay():New( nLin,180,{||"CSLL   "} ,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		oGet98     := TGet():New( nLin,225,{|u| If(PCount()>0,xCSLALQ:=u,xCSLALQ)},oGrp1,045,008,'@E 99.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","xCSLALQ",,)
		oGet90     := TGet():New( nLin,275,{|u| If(PCount()>0,xCSLVAL :=u,xCSLVAL)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","xCSLVAL",,) 

	Endif  //if do modelo xml

//Endif  //esse endif tá errado aqui

	//Erick Gonçalves -> Incluindo as colunas do MsSelect para cada tipo de nota.
	If xModelo == "55"

		DbSelectArea("EXP")
		EXP->(DbGoTop())
		
		 oBrw1   := MsSelect():New( "EXP",,,;
		{{ "ITEM"	,  "", "Item"      	,		         "" },;
		 { "CODIGO" ,  "", "Produto"   	,		         "" },;
		 { "DESCRI" ,  "", "Descrição" 	,		         "" },;
		 { "QUANT"  ,  "", "Quantidade"	,	             "" },;
		 { "UM"     ,  "", "UM"        	,	             "" },;
		 { "VUNIT"  ,  "", "Vlr.Unit"  	,	             "" },;
		 { "VTOTAL" ,  "", "Vlr.Total" 	,	             "" },;
		 { "ALIQISS",  "", "Aliq.ISS"	,				 "" },;
		 { "VALISS" ,  "", "Vlr.ISS"	,			 	 "" },;
		 { "ALQPIS" ,  "", "Aliq.PIS"	,				 "" },;
		 { "VALPIS" ,  "", "Vlr.PIS"	,				 "" },;
		 { "ALQCOF" ,  "", "Aliq.COFINS",				 "" },;
		 { "VALCOF" ,  "", "Vlr.COFINS" ,				 "" },;
		 { "ALIQINS",  "", "Aliq.INSS"  ,				 "" },;
		 { "VALINS" ,  "", "Vlr.INSS"	,				 "" },;
		 { "ALQIR"  ,  "", "Aliq.IR"	,				 "" },;
		 { "VALIR"  ,  "", "Vlr.IR"		,				 "" },;
		 { "ALQCSL" ,  "", "Aliq.CSLL"  ,				 "" },;
		 { "CSLVAL" ,  "", "Vlr.CSLL"	,				 "" },;
		 { "ALQICM" ,  "", "Aliq.ICMS" 	,	             "" },;
		 { "BASICM" ,  "", "Base ICMS" 	,	             "" },;
		 { "VALICM" ,  "", "Vlr.ICMS" 	,	             "" },;
		 { "NCM"	,  "", "NCM"		,				 "" }; 
		  },.F.,,{(nLiMeio*0.79)+8, nCoini+2, (nLiMeio*0.95)-2, (nCoMeio-nCoIni)-2},,, oGrp4 )

	Elseif xModelo == "57" // CTE

	 	oBrw1   := MsSelect():New( "EXP",,,;
		{{ "ITEM"	,  "", "Item"      	,		         "" },;
		 { "CODIGO" ,  "", "Produto"   	,		         "" },;
		 { "DESCRI" ,  "", "Descrição" 	,		         "" },;
		 { "QUANT"  ,  "", "Quantidade"	,	             "" },;
		 { "UM"     ,  "", "UM"        	,	             "" },;
		 { "VUNIT"  ,  "", "Vlr.Unit"  	,	             "" },;
		 { "VTOTAL" ,  "", "Vlr.Total" 	,	             "" },;
		 { "ALIQISS",  "", "Aliq.ISS"	,				 "" },;
		 { "VALISS" ,  "", "Vlr.ISS"	,			 	 "" },;
		 { "ALQPIS" ,  "", "Aliq.PIS"	,				 "" },;
		 { "VALPIS" ,  "", "Vlr.PIS"	,				 "" },;
		 { "ALQCOF" ,  "", "Aliq.COFINS",				 "" },;
		 { "VALCOF" ,  "", "Vlr.COFINS" ,				 "" },;
		 { "ALIQINS",  "", "Aliq.INSS"  ,				 "" },;
		 { "VALINS" ,  "", "Vlr.INSS"	,				 "" },;
		 { "ALQIR"  ,  "", "Aliq.IR"	,				 "" },;
		 { "VALIR"  ,  "", "Vlr.IR"		,				 "" },;
		 { "ALQCSL" ,  "", "Aliq.CSLL"  ,				 "" },;
		 { "CSLVAL" ,  "", "Vlr.CSLL"	,				 "" },;
		 { "ALQICM" ,  "", "Aliq.ICMS" 	,	             "" },;
		 { "VALICM" ,  "", "Vlr.ICMS" 	,	             "" },;
		 { "ALQIPI" ,  "", "Aliq. IPI"   ,				 "" },;
		 { "VALIPI" ,  "", "Vlr.IPI"	,				 "" };
		},.F.,,{(nLiMeio*0.73)+8, nCoini+2, (nLiMeio*0.95)-2, (nCoMeio-nCoIni)-2},,, oGrp4 )

	Elseif xModelo == "65" // NFCe
		 oBrw1   := MsSelect():New( "EXP",,,;
		{{ "ITEM"	,  "", "Item"      	,		         "" },;
		 { "CODIGO" ,  "", "Produto"   	,		         "" },;
		 { "DESCRI" ,  "", "Descrição" 	,		         "" },;
		 { "QUANT"  ,  "", "Quantidade"	,	             "" },;
		 { "UM"     ,  "", "UM"        	,	             "" },;
		 { "VUNIT"  ,  "", "Vlr.Unit"  	,	             "" },;
		 { "VTOTAL" ,  "", "Vlr.Total" 	,	             "" },;
		 { "ALQICM" ,  "", "Aliq.ICMS" 	,	             "" },;
		 { "VALICM" ,  "", "Vlr.ICMS" 	,	             "" },;
		 { "ALQPIS" ,  "", "Aliq.PIS"	,				 "" },;
		 { "VALPIS" ,  "", "Vlr.PIS"	,				 "" },;
		 { "ALQCOF" ,  "", "Aliq.COFINS",				 "" },;
		 { "VALCOF" ,  "", "Vlr.COFINS" ,				 "" },;
		 { "ALQIR"  ,  "", "Aliq.IRPJ"	,				 "" },;
		 { "VALIR"  ,  "", "Vlr.IRPJ"		,				 "" },;
		 { "ALQCSL" ,  "", "Aliq.CSLL"  ,				 "" },;
		 { "CSLVAL" ,  "", "Vlr.CSLL"	,				 "" }; 
		  },.F.,,{(nLiMeio*0.73)+8, nCoini+2, (nLiMeio*0.95)-2, (nCoMeio-nCoIni)-2},,, oGrp4 )

	Elseif xModelo == "67" // CTE-OS
		 oBrw1   := MsSelect():New( "EXP",,,;
		{{ "ITEM"	,  "", "Item"      	,		         "" },;
		 { "CODIGO" ,  "", "Produto"   	,		         "" },;
		 { "DESCRI" ,  "", "Descrição" 	,		         "" },;
		 { "QUANT"  ,  "", "Quantidade"	,	             "" },;
		 { "UM"     ,  "", "UM"        	,	             "" },;
		 { "VUNIT"  ,  "", "Vlr.Unit"  	,	             "" },;
		 { "VTOTAL" ,  "", "Vlr.Total" 	,	             "" },;
		 { "ALQICM" ,  "", "Aliq.ICMS" 	,	             "" },;
		 { "VALICM" ,  "", "Vlr.ICMS" 	,	             "" },;
		 { "ALQPIS" ,  "", "Aliq.PIS"	,				 "" },;
		 { "VALPIS" ,  "", "Vlr.PIS"	,				 "" },;
		 { "ALQCOF" ,  "", "Aliq.COFINS",				 "" },;
		 { "VALCOF" ,  "", "Vlr.COFINS" ,				 "" },;
		 { "ALQIPI" ,  "", "Aliq. IPI"  ,				 "" },;
		 { "VALIPI" ,  "", "Vlr.IPI"	,				 "" },;
		 { "NCM"	,  "", "NCM"		,				 "" }; 
		  },.F.,,{(nLiMeio*0.73)+8, nCoini+2, (nLiMeio*0.95)-2, (nCoMeio-nCoIni)-2},,, oGrp4 )

	Elseif xModelo == "RP" // NFS-e
		 oBrw1   := MsSelect():New( "EXP",,,;
		{{ "ITEM"	,  "", "Item"      	,		         "" },;
		 { "CODIGO" ,  "", "Produto"   	,		         "" },;
		 { "DESCRI" ,  "", "Descrição" 	,		         "" },;
		 { "QUANT"  ,  "", "Quantidade"	,	             "" },;
		 { "UM"     ,  "", "UM"        	,	             "" },;
		 { "VUNIT"  ,  "", "Vlr.Unit"  	,	             "" },;
		 { "VTOTAL" ,  "", "Vlr.Total" 	,	             "" },;
 		 { "ALIQISS",  "", "Aliq.ISS"	,				 "" },;
		 { "VALISS" ,  "", "Vlr.ISS"	,			 	 "" },;
		 { "ALQPIS" ,  "", "Aliq.PIS"	,				 "" },;
		 { "VALPIS" ,  "", "Vlr.PIS"	,				 "" },;
		 { "ALQCOF" ,  "", "Aliq.COFINS",				 "" },;
		 { "VALCOF" ,  "", "Vlr.COFINS" ,				 "" },;
		 { "ALIQINS",  "", "Aliq.INSS"  ,				 "" },;
		 { "VALINS" ,  "", "Vlr.INSS"	,				 "" },;
		 { "ALQIR"  ,  "", "Aliq.IR"	,				 "" },;
		 { "VALIR"  ,  "", "Vlr.IR"		,				 "" },;
		 { "ALQCSL" ,  "", "Aliq.CSLL"  ,				 "" },;
		 { "CSLVAL" ,  "", "Vlr.CSLL"	,				 "" }; 
		  },.F.,,{(nLiMeio*0.73)+8, nCoini+2, (nLiMeio*0.95)-2, (nCoMeio-nCoIni)-2},,, oGrp4 )
	Endif
		  
		  oBrw1:oBrowse:bChange := { || fMostraVlr(EXP->ITEM,xEspeciNF,cChave,@xBaseICM,@xAliqICM,@xValICMi,;
		  															 @xBaseIPI,@xAliqIPI,@xVALIPIi,;
		  															 @xBasePIS,@xAliqpis,@xValPISi,@xValPIS,;
		  															 @xBasCof,@xAliqCof,@xValCOFi,;
		  															 @xBasIR ,@xAliqIR ,@xValIRi,;
		  															 @xBasICMST,@xAliqICMST,@xValICMiS,@xAliqICM,@xValICM,;
		  															 aIteNFE,;
		  															 @nBaseICM,@nAliqICM,@nValICMi,;
		  															 @nBaseIPI,@nAliqIPI,@nVALIPIi,;
		  															 @nBasePIS,@nAliqpis,@nValPISi,;
		  															 @nBasCof,@nAliqCof,@nValCOFi,;
		  															 @nBasIR ,@nAliqIR ,@nValIRi,;
		  															 @nBasICMST,@nAliqICMST,@nValICMiS,@nValICM,;
		  															 ,lDiverg,xXml,@xNCM,@cNCM,@xISSVAL,@nISSVAL,@xINSVAL,@nINSVAL,@cItem,@xISSALQ,@xINSALQ,@xCSLALQ,@xCSLVAL;
		  															 ) }
	// Calculo inicial do tamanho do grid
	nCol := (nCoMeio*0.5)-5
	nLin := 15
	oSay7      := TSay():New( nLin,nCol+010	,{||"Documento:"}	,oGrp5,,,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,032,008)
	oSay10     := TSay():New( nLin,nCol+113	,{||"Série:"}		,oGrp5,,,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,017,008)
	oSay38     := TSay():New( nLin,nCol+162	,{||"Emissão:"}		,oGrp5,,,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,023,008)
	oGet19     := TGet():New( nLin-1,nCol+047,{|u| If(PCount()>0,cDocto:=u	,cDocto)}	,oGrp5,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.	,"",,,.F.,.F.,,.T.,.F.,"","cDocto",,)
	oGet20     := TGet():New( nLin-1,nCol+130,{|u| If(PCount()>0,cSerie:=u	,cSerie)}	,oGrp5,020,008,'@!',,CLR_BLACK,CLR_WHITE,,,,.T.	,"",,,.F.,.F.,,.T.,.F.,"","cSerie",,)
	oGet34     := TGet():New( nLin-1,nCol+191,{|u| If(PCount()>0,dEmissao:=u,dEmissao)}	,oGrp5,060,008,'@D',,CLR_BLACK,CLR_WHITE,,,,.T.	,"",,,.F.,.F.,,.T.,.F.,"","dEmissao",,)
	nLin += 15
	If UPPER(cTipoNF) <> "DEVOLUÇÃO" .and. UPPER(cTipoNF) <> "BENEFICIAMENTO"
		oSay23     := TSay():New( nLin,nCol+010	,{||"Fornecedor:"}	,oGrp5,,,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,031,008)
	Else 
		oSay23     := TSay():New( nLin,nCol+010	,{||"Cliente:"}	,oGrp5,,,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,031,008)
	Endif 
	oSay24     := TSay():New( nLin,nCol+113	,{||"Loja:"}		,oGrp5,,,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,014,008)
	oSay25     := TSay():New( nLin,nCol+162	,{||"Nome:"}		,oGrp5,,,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,019,008) 
	oGet21     := TGet():New( nLin-1,nCol+047,{|u| If(PCount()>0,cCodForn:=u,cCodForn)},oGrp5,047,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.	,"",,,.F.,.F.,,.T.,.F.,"","cCodForn",,)
	oGet22     := TGet():New( nLin-1,nCol+130,{|u| If(PCount()>0,cLojForn:=u,cLojForn)},oGrp5,018,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.	,"",,,.F.,.F.,,.T.,.F.,"","cLojForn",,)
	oGet23     := TGet():New( nLin-1,nCol+191,{|u| If(PCount()>0,cNomeForn:=u,cNomeForn)}	,oGrp5,135,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.	,"",,,.F.,.F.,,.T.,.F.,"","cNomeForn",,)
	
	nLin += 15
	oSay59     := TSay():New( nLin,nCol+10 	,{||"Tipo:"}		,oGrp5,,,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,031,008) 
	oSay60     := TSay():New( nLin,nCol+162	,{||"Espécie:"}		,oGrp5,,,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,023,008)
	oGet21t    := TGet():New( nLin-1,nCol+047,{|u| If(PCount()>0,cTipoNF:=u,cTipoNF)}	,oGrp5,047,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.	,"",,,.F.,.F.,,.T.,.F.,"","cTipoNF",,)
	oGet23e    := TGet():New( nLin-1,nCol+191,{|u| If(PCount()>0,cEspeciNF:=u,cEspeciNF)}	,oGrp5,047,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.	,"",,,.F.,.F.,,.T.,.F.,"","cEspeciNF",,)
	
	// Recalcula com base no tamanho do grid (27%)
	nLinAux := (nLiMeio*0.73) * 0.276 
	nLin := nLinAux
	
	//Linha separadora
	oGrp6      := TGroup():New( nLin,(nCoMeio*0.5)+5,nLin+10,nCoMeio-nCoIni-5,"",oGrp5,CLR_BLACK,CLR_WHITE,.T.,.F. )    
	oSay51     := TSay():New( nLin+2,nCol+125,{||"TOTAIS DA NF"}	  ,oGrp6,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,095,012) 

	nLin += 15
	oSay27     := TSay():New( nLin,nCol+030,{||"VLR TOTAL:"},oGrp5,,,.F.,.F.,.F.,.T.,xCorFo1,xCorFu1,065,018)
	oSay28     := TSay():New( nLin,nCol+135,{||"VLR BRUTO:"}	  ,oGrp5,,,.F.,.F.,.F.,.T.,xCorFo2,xCorFu2,044,008)
	oGet24     := TGet():New( nLin-1,nCol+065,{|u| If(PCount()>0,nValmerc:=u,nValmerc)},oGrp5,060,008,'@E 999,999,999.99',,xCorFo1,xCorFu1,,,,.T.	,"",,,.F.,.F.,,.T.,.F.,"","nValmerc",,)
	oGet25     := TGet():New( nLin-1,nCol+170,{|u| If(PCount()>0,nValbrut:=u,nValbrut)},oGrp5,060,008,'@E 999,999,999.99',,xCorFo2,xCorFu2,,,,.T.	,"",,,.F.,.F.,,.T.,.F.,"","nValbrut",,)
	
	//FR - 11/01/2022 - Petra - incluir campo ICMST
	oSay80     := TSay():New( nLin  ,nCol+235,{||"Vlr ICM ST:"},oGrp5,,,.F.,.F.,.F.,.T.,xCorFo27,xCorFu27,053,048)   //FR - 11/01/2022
	oGet62     := TGet():New( nLin	,nCol+268,{|u| If(PCount()>0,nValICMST:=u,nValICMST)},oGrp5,060,008,'@E 999,999,999.99',,xCorFo27,xCorFu27,,,,.T.	,"",,,.F.,.F.,,.F.,.F.,"","nValICMST",,)
	
	//TOTAIS:
	nLin += 13
	oSay29     := TSay():New( nLin  ,nCol+010,{||"Valor ICMS:"}		,oGrp5,,,.F.,.F.,.F.,.T.,xCorFo4,xCorFu4,043,008)
	oSay30     := TSay():New( nLin  ,nCol+075,{||"Valor IPI:"}		,oGrp5,,,.F.,.F.,.F.,.T.,xCorFo6,xCorFu6,043,008)
	oSay31     := TSay():New( nLin	,nCol+140,{||"Valor PIS:"}		,oGrp5,,,.F.,.F.,.F.,.T.,xCorFo8,xCorFu8,043,008)
	oSay32     := TSay():New( nLin	,nCol+205,{||"Valor COFINS:"}	,oGrp5,,,.F.,.F.,.F.,.T.,xCorFo10,xCorFu10,043,008)
	oSay39     := TSay():New( nLin	,nCol+270,{||"Valor IR:"}		,oGrp5,,,.F.,.F.,.F.,.T.,xCorFo12,xCorFu12,032,008)
	

	nLin += 8
	oGet26     := TGet():New( nLin,nCol+010,{|u| If(PCount()>0,nValICM:=u	,nValICM)}	,oGrp5,060,008,'@E 999,999,999.99',,xCorFo4,xCorFu4,,,,.T.	,"",,,.F.,.F.,,.T.,.F.,"","nValICM",,)
	oGet27     := TGet():New( nLin,nCol+075,{|u| If(PCount()>0,nVALIPI:=u	,nVALIPI)}	,oGrp5,060,008,'@E 999,999,999.99',,xCorFo6,xCorFu6,,,,.T.	,"",,,.F.,.F.,,.T.,.F.,"","nVALIPI",,)
	oGet28     := TGet():New( nLin,nCol+140,{|u| If(PCount()>0,nValPIS:=u	,nValPIS)}	,oGrp5,060,008,'@E 999,999,999.99',,xCorFo8,xCorFu8,,,,.T.	,"",,,.F.,.F.,,.T.,.F.,"","nValPIS",,)
	oGet29     := TGet():New( nLin,nCol+205,{|u| If(PCount()>0,nValCOF:=u	,nValCOF)}	,oGrp5,060,008,'@E 999,999,999.99',,xCorFo10,xCorFu10,,,,.T.	,"",,,.F.,.F.,,.T.,.F.,"","nValCOF",,)
	oGet35     := TGet():New( nLin,nCol+270,{|u| If(PCount()>0,nValIR:=u	,nValIR)}	,oGrp5,060,008,'@E 999,999,999.99',,xCorFo12,xCorFu12,,,,.T.	,"",,,.F.,.F.,,.T.,.F.,"","nValIR",,)

	//Recalcula com base no tamanho do grid (51%)
	nLinAux := (nLiMeio*0.73) * 0.51 
	nLin := nLinAux

	//Linha separadora
	//FR - 22/06/2020 - ver se Ã© possÃ­vel mostrar o item em tempo real
	oGrp6      := TGroup():New( nLin,(nCoMeio*0.5)+5,nLin+10,nCoMeio-nCoIni-5,"",oGrp5,CLR_BLACK,CLR_WHITE,.T.,.F. )    
	oSay51     := TSay():New( nLin+2,nCol+125,{||"ITENS DA NF"},oGrp6,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,200,012) 
	
	If xModelo == "55" // RTF - Impostos equivalentes a NFe.

		nLin += 13
		oSay68     := TSay():New( nLin  ,nCol+065,{||"Aliq ISS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay92     := TSay():New( nLin  ,nCol+120,{||"Valor ISS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay81     := TSay():New( nLin	,nCol+230,{||"Aliq PIS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay56     := TSay():New( nLin	,nCol+285,{||"Valor PIS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)

		nLin += 7
		oSay106    := TSay():New( nLin,nCol+010,{||"ISS"}	,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		oGet66     := TGet():New( nLin,nCol+065,{|u| If(PCount()>0,nISSALQ :=u,nISSALQ)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nISSALQ",,) 
		oGet90     := TGet():New( nLin,nCol+120,{|u| If(PCount()>0,nISSVAL :=u,nISSVAL)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nISSVAL",,) 
		
		oSay67     := TSay():New( nLin,nCol+175,{||"PIS"}	,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		oGet93     := TGet():New( nLin,nCol+230,{|u| If(PCount()>0,nAliqPIS :=u,nAliqPIS)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nAliqPIS",,) 
		oGet90     := TGet():New( nLin,nCol+285,{|u| If(PCount()>0,nValPISi :=u,nValPISi)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nValPISi",,) 
		
		nLin += 13
		oSay49     := TSay():New( nLin  ,nCol+065,{||"Aliq COFINS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay73     := TSay():New( nLin  ,nCol+120,{||"Valor COFINS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,053,008)
		oSay103    := TSay():New( nLin	,nCol+230,{||"Aliq INSS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay104    := TSay():New( nLin	,nCol+285,{||"Valor INSS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)

		nLin += 10
		oSay64     := TSay():New( nLin,nCol+010,{||"COFINS"}	,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		oGet93     := TGet():New( nLin,nCol+065,{|u| If(PCount()>0,nAliqCof :=u,nAliqCof)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nAliqCof",,) 
		oGet90     := TGet():New( nLin,nCol+120,{|u| If(PCount()>0,nValCof :=u,nValCof)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nValCof",,) 
		
		oSay107    := TSay():New( nLin,nCol+175,{||"INSS"}	,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		oGet93     := TGet():New( nLin,nCol+230,{|u| If(PCount()>0,nINSALQ :=u,nINSALQ)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nINSALQ",,) 
		oGet90     := TGet():New( nLin,nCol+285,{|u| If(PCount()>0,nINSVAL :=u,nINSVAL)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nINSVAL",,) 

		nLin += 12
		oSay50     := TSay():New( nLin  ,nCol+065,{||"Aliq IR:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay74     := TSay():New( nLin  ,nCol+120,{||"Valor IR:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay101    := TSay():New( nLin	,nCol+230,{||"Aliq CSLL:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay100    := TSay():New( nLin	,nCol+285,{||"Valor CSLL:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)

		nLin += 10
		oSay65     := TSay():New( nLin,nCol+010,{||"IR"}	,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		oGet58     := TGet():New( nLin,nCol+065,{|u| If(PCount()>0,nAliqIR :=u,nAliqIR)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nAliqIR",,) 
		oGet57     := TGet():New( nLin,nCol+120,{|u| If(PCount()>0,nValIR :=u,nValIR)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nValIR",,) 
		
		oSay67     := TSay():New( nLin,nCol+175,{||"CSLL"}	,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		oGet93     := TGet():New( nLin,nCol+230,{|u| If(PCount()>0,nCSLALQ :=u,nCSLALQ)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nCSLALQ",,) 
		oGet90     := TGet():New( nLin,nCol+285,{|u| If(PCount()>0,nCSLVAL :=u,nCSLVAL)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nCSLVAL",,) 

		nLin += 13
		//oSay50     := TSay():New( nLin,nCol+065,{||"Base ICMS:"},oGrp5,,,.F.,.F.,.F.,.T.,xCorFo3,xCorFu3,032,008)
		oSay46     := TSay():New( nLin,nCol+065,{||"Aliq. ICMS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay70     := TSay():New( nLin,nCol+120,{||"Valor ICMS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay54     := TSay():New( nLin,nCol+230,{||"Aliq. IPI:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay55     := TSay():New( nLin,nCol+285,{||"Valor IPI:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)

		//oSay78     := TSay():New( nLin,nCol+285,{||"Class. Fiscal"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)

		nLin += 8
		oSay61     := TSay():New( nLin,nCol+010,{||"ICMS"} ,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		//oGet30     := TGet():New( nLin,nCol+065,{|u| If(PCount()>0,nBaseICM:=u,nBaseICM)},oGrp6,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nBaseICM",,) 
		oGet42     := TGet():New( nLin,nCol+065,{|u| If(PCount()>0,nAliqICM:=u,nAliqICM)},oGrp6,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nAliqICM",,) 
		oGet53     := TGet():New( nLin,nCol+120,{|u| If(PCount()>0,nValICMi:=u,nValICMi)},oGrp6,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nValICMi",,) 

		oSay62     := TSay():New( nLin,nCol+175,{||"IPI"}	,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		oGet43     := TGet():New( nLin,nCol+230,{|u| If(PCount()>0,nAliqIPI :=u,nAliqIPI)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nAliqIPI",,) 
		oGet54     := TGet():New( nLin,nCol+285,{|u| If(PCount()>0,nVALIPIi :=u,nVALIPIi)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nVALIPIi",,) 

		nLin += 12
		oSay78     := TSay():New( nLin,nCol+065,{||"Class. Fiscal:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)

		nLin += 9
		// Nomenclatura e Get do NCM
		oSay77     := TSay():New( nLin,nCol+010,{||"NCM"}	,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		oGet60     := TGet():New( nLin,nCol+065,{|u| If(PCount()>0,cNCM :=u,cNCM)},oGrp1,045,008,'@E 99999999999',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cNCM",,) 

	Elseif xModelo == "57" // RTF - Impostos equivalentes a CTe.

		nLin += 13
		oSay96     := TSay():New( nLin  ,nCol+065,{||"Aliq ISS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay92     := TSay():New( nLin  ,nCol+120,{||"Valor ISS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay48     := TSay():New( nLin	,nCol+230,{||"Aliq PIS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay72     := TSay():New( nLin	,nCol+285,{||"Valor PIS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)

		nLin += 8
		oSay106    := TSay():New( nLin,nCol+010,{||"ISS"}	,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		oGet93     := TGet():New( nLin,nCol+065,{|u| If(PCount()>0,nISSALQ :=u,nISSALQ)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nISSALQ",,) 
		oGet90     := TGet():New( nLin,nCol+120,{|u| If(PCount()>0,nISSVAL :=u,nISSVAL)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nISSVAL",,) 
		
		oSay63     := TSay():New( nLin,nCol+175,{||"PIS"}	,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		oGet44     := TGet():New( nLin,nCol+230,{|u| If(PCount()>0,nAliqPIS :=u,nAliqPIS)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nAliqPIS",,) 
		oGet55     := TGet():New( nLin,nCol+285,{|u| If(PCount()>0,nValPISi :=u,nValPISi)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nValPISi",,) 

		nLin += 13
		oSay49     := TSay():New( nLin  ,nCol+065,{||"Aliq COFINS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay73     := TSay():New( nLin  ,nCol+120,{||"Valor COFINS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,053,008)
		oSay103     := TSay():New( nLin	,nCol+230,{||"Aliq INSS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay105     := TSay():New( nLin	,nCol+285,{||"Valor INSS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)

		nLin += 8
		oSay64     := TSay():New( nLin,nCol+010,{||"COFINS"}	,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		oGet45     := TGet():New( nLin,nCol+065,{|u| If(PCount()>0,nAliqCof :=u,nAliqCof)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nAliqCof",,) 
		oGet56     := TGet():New( nLin,nCol+120,{|u| If(PCount()>0,nValCof :=u,nValCof)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nValCof",,) 
		
		oSay107     := TSay():New( nLin,nCol+175,{||"INSS"}	,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		oGet93     := TGet():New( nLin,nCol+230,{|u| If(PCount()>0,nINSALQ :=u,nINSALQ)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nINSALQ",,) 
		oGet90     := TGet():New( nLin,nCol+285,{|u| If(PCount()>0,nINSVAL :=u,nINSVAL)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nINSVAL",,) 

		nLin += 13
		oSay45     := TSay():New( nLin  ,nCol+065,{||"Aliq IR:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay58     := TSay():New( nLin  ,nCol+120,{||"Valor IR:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay101    := TSay():New( nLin	,nCol+230,{||"Aliq CSLL:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay100    := TSay():New( nLin	,nCol+285,{||"Valor CSLL:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)

		nLin += 8
		oSay65     := TSay():New( nLin,nCol+010,{||"IR"}	,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		oGet58     := TGet():New( nLin,nCol+065,{|u| If(PCount()>0,nAliqIR :=u,nAliqIR)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nAliqIR",,) 
		oGet100     := TGet():New( nLin,nCol+120,{|u| If(PCount()>0,nVALIRi :=u,nVALIRi)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nVALIRi",,) 
		
		oSay67     := TSay():New( nLin,nCol+175,{||"CSLL"}	,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		oGet93     := TGet():New( nLin,nCol+230,{|u| If(PCount()>0,nCSLALQ :=u,nCSLALQ)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nCSLALQ",,) 
		oGet90     := TGet():New( nLin,nCol+285,{|u| If(PCount()>0,nCSLVAL :=u,nCSLVAL)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nCSLVAL",,) 


		nLin += 13
		oSay46     := TSay():New( nLin  ,nCol+065,{||"Aliq ICMS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay70     := TSay():New( nLin  ,nCol+120,{||"Valor ICMS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		//oSay47     := TSay():New( nLin	,nCol+230,{||"Aliq IPI:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		//oSay71     := TSay():New( nLin	,nCol+285,{||"Valor IPI:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)


		nLin += 8
		oSay61     := TSay():New( nLin,nCol+010,{||"ICMS"}	,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		oGet42     := TGet():New( nLin,nCol+065,{|u| If(PCount()>0,nAliqICM :=u,nAliqICM)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nAliqICM",,) 
		oGet53     := TGet():New( nLin,nCol+120,{|u| If(PCount()>0,nValICM :=u,nValICM)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nValICM",,) 

		// Foi solicitado a exclusão do campo de imposto no Cte
		// oSay62     := TSay():New( nLin,nCol+175,{||"IPI"}	,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		// oGet43     := TGet():New( nLin,nCol+230,{|u| If(PCount()>0,nAliqIPI :=u,nAliqIPI)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nAliqIPI",,) 
		// oGet54     := TGet():New( nLin,nCol+285,{|u| If(PCount()>0,nVALIPIi :=u,nVALIPIi)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nVALIPIi",,) 

	Elseif xModelo == "65" // EGS - Impostos equivalentes a NFCe

		nLin += 13
		oSay46     := TSay():New( nLin  ,nCol+065,{||"Aliq. ICMS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay70     := TSay():New( nLin  ,nCol+120,{||"Valor ICMS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay81     := TSay():New( nLin	,nCol+230,{||"Aliq PIS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay56     := TSay():New( nLin	,nCol+285,{||"Valor PIS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)

		nLin += 7
		oSay61     := TSay():New( nLin,nCol+010,{||"ICMS"} ,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		//oGet30     := TGet():New( nLin,nCol+065,{|u| If(PCount()>0,nBaseICM:=u,nBaseICM)},oGrp6,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nBaseICM",,) 
		oGet42     := TGet():New( nLin,nCol+065,{|u| If(PCount()>0,nAliqICM:=u,nAliqICM)},oGrp6,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nAliqICM",,) 
		oGet53     := TGet():New( nLin,nCol+120,{|u| If(PCount()>0,nValICMi:=u,nValICMi)},oGrp6,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nValICMi",,) 

		oSay67     := TSay():New( nLin,nCol+175,{||"PIS"}	,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		oGet93     := TGet():New( nLin,nCol+230,{|u| If(PCount()>0,nAliqPIS :=u,nAliqPIS)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nAliqPIS",,) 
		oGet90     := TGet():New( nLin,nCol+285,{|u| If(PCount()>0,nValPISi :=u,nValPISi)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nValPISi",,) 
	
		nLin += 13
		oSay49     := TSay():New( nLin  ,nCol+065,{||"Aliq COFINS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay73     := TSay():New( nLin  ,nCol+120,{||"Valor COFINS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,053,008)
		oSay50    := TSay():New( nLin	,nCol+230,{||"Aliq IRPJ:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay74    := TSay():New( nLin	,nCol+285,{||"Valor IRPJ:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)

		nLin += 10
		oSay64     := TSay():New( nLin,nCol+010,{||"COFINS"}	,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		oGet93     := TGet():New( nLin,nCol+065,{|u| If(PCount()>0,nAliqCof :=u,nAliqCof)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nAliqCof",,) 
		oGet90     := TGet():New( nLin,nCol+120,{|u| If(PCount()>0,nValCof :=u,nValCof)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nValCof",,) 
	
		oSay65    := TSay():New( nLin,nCol+175,{||"IRPJ"}	,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		oGet58     := TGet():New( nLin,nCol+230,{|u| If(PCount()>0,nAliqIR :=u,nAliqIR)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nAliqIR",,) 
		oGet57     := TGet():New( nLin,nCol+285,{|u| If(PCount()>0,nValIR :=u,nValIR)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nValIR",,) 

		nLin += 12
		oSay50     := TSay():New( nLin  ,nCol+065,{||"Aliq CSLL:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay74     := TSay():New( nLin  ,nCol+120,{||"Valor CSLL:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		//oSay101    := TSay():New( nLin	,nCol+230,{||"Aliq CPP:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		//oSay100    := TSay():New( nLin	,nCol+285,{||"Valor CPP:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)

		nLin += 10
		oSay67     := TSay():New( nLin,nCol+010,{||"CSLL"}	,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		oGet93     := TGet():New( nLin,nCol+065,{|u| If(PCount()>0,nCSLALQ :=u,nCSLALQ)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nCSLALQ",,) 
		oGet90     := TGet():New( nLin,nCol+120,{|u| If(PCount()>0,nCSLVAL :=u,nCSLVAL)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nCSLVAL",,) 
		
		//oSay67     := TSay():New( nLin,nCol+175,{||"CPP"}	,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		//oGet93     := TGet():New( nLin,nCol+230,{|u| If(PCount()>0,nCSLALQ :=u,nCSLALQ)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nCSLALQ",,) 
		//oGet90     := TGet():New( nLin,nCol+285,{|u| If(PCount()>0,nCSLVAL :=u,nCSLVAL)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nCSLVAL",,) 
		
	Elseif xModelo == "67" // EGS - Impostos equivalentes a CTE-OS

		nLin += 13
		oSay46     := TSay():New( nLin  ,nCol+065,{||"Aliq. ICMS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay70     := TSay():New( nLin  ,nCol+120,{||"Valor ICMS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay81     := TSay():New( nLin	,nCol+230,{||"Aliq PIS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay56     := TSay():New( nLin	,nCol+285,{||"Valor PIS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)

		nLin += 7
		oSay61     := TSay():New( nLin,nCol+010,{||"ICMS"} ,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		oGet42     := TGet():New( nLin,nCol+065,{|u| If(PCount()>0,nAliqICM:=u,nAliqICM)},oGrp6,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nAliqICM",,) 
		oGet53     := TGet():New( nLin,nCol+120,{|u| If(PCount()>0,nValICMi:=u,nValICMi)},oGrp6,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nValICMi",,) 

		oSay67     := TSay():New( nLin,nCol+175,{||"PIS"}	,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		oGet93     := TGet():New( nLin,nCol+230,{|u| If(PCount()>0,nAliqPIS :=u,nAliqPIS)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nAliqPIS",,) 
		oGet90     := TGet():New( nLin,nCol+285,{|u| If(PCount()>0,nValPISi :=u,nValPISi)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nValPISi",,) 
	
		nLin += 13
		oSay49     := TSay():New( nLin  ,nCol+065,{||"Aliq COFINS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay73     := TSay():New( nLin  ,nCol+120,{||"Valor COFINS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,053,008)
		oSay54     := TSay():New( nLin	,nCol+230,{||"Aliq IPI:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay55     := TSay():New( nLin	,nCol+285,{||"Valor IPI:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)

		nLin += 8
		oSay64     := TSay():New( nLin,nCol+010,{||"COFINS"}	,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		oGet93     := TGet():New( nLin,nCol+065,{|u| If(PCount()>0,nAliqCof :=u,nAliqCof)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nAliqCof",,) 
		oGet90     := TGet():New( nLin,nCol+120,{|u| If(PCount()>0,nValCof :=u,nValCof)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nValCof",,) 
	
		oSay62     := TSay():New( nLin,nCol+175,{||"IPI"}	,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		oGet43     := TGet():New( nLin,nCol+230,{|u| If(PCount()>0,nAliqIPI :=u,nAliqIPI)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nAliqIPI",,) 
		oGet54     := TGet():New( nLin,nCol+285,{|u| If(PCount()>0,nVALIPIi :=u,nVALIPIi)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nVALIPIi",,) 

		nLin += 12
		oSay78     := TSay():New( nLin  ,nCol+065,{||"Class. Fiscal:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)

		nLin += 9
		oSay77     := TSay():New( nLin,nCol+010,{||"NCM"}	,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		oGet60     := TGet():New( nLin,nCol+065,{|u| If(PCount()>0,cNCM :=u,cNCM)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cNCM",,) 
		
		//oSay67     := TSay():New( nLin,nCol+175,{||"CPP"}	,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		//oGet93     := TGet():New( nLin,nCol+230,{|u| If(PCount()>0,nCSLALQ :=u,nCSLALQ)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nCSLALQ",,) 
		//oGet90     := TGet():New( nLin,nCol+285,{|u| If(PCount()>0,nCSLVAL :=u,nCSLVAL)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nCSLVAL",,) 

	Elseif xModelo == "RP" // EGS - Impostos equivalentes a NFSe.

		nLin += 13
		oSay96     := TSay():New( nLin  ,nCol+065,{||"Aliq ISS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay92     := TSay():New( nLin  ,nCol+120,{||"Valor ISS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay48     := TSay():New( nLin	,nCol+230,{||"Aliq PIS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay72     := TSay():New( nLin	,nCol+285,{||"Valor PIS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)


		nLin += 8
		oSay106    := TSay():New( nLin,nCol+010,{||"ISS"}	,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		oGet93     := TGet():New( nLin,nCol+065,{|u| If(PCount()>0,nISSALQ :=u,nISSALQ)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nISSALQ",,) 
		oGet90     := TGet():New( nLin,nCol+120,{|u| If(PCount()>0,nISSVAL :=u,nISSVAL)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nISSVAL",,) 
		
		oSay63     := TSay():New( nLin,nCol+175,{||"PIS"}	,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		oGet44     := TGet():New( nLin,nCol+230,{|u| If(PCount()>0,nAliqPIS :=u,nAliqPIS)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nAliqPIS",,) 
		oGet55     := TGet():New( nLin,nCol+285,{|u| If(PCount()>0,nValPISi :=u,nValPISi)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nValPISi",,) 
		
		nLin += 13
		oSay49     := TSay():New( nLin  ,nCol+065,{||"Aliq COFINS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay73     := TSay():New( nLin  ,nCol+120,{||"Valor COFINS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,053,008)
		oSay103    := TSay():New( nLin	,nCol+230,{||"Aliq INSS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay105    := TSay():New( nLin	,nCol+285,{||"Valor INSS:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)

		nLin += 8
		oSay64     := TSay():New( nLin,nCol+010,{||"COFINS"},oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		oGet33     := TGet():New( nLin,nCol+065,{|u| If(PCount()>0,nAliqCof :=u,nAliqCof)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nAliqCof",,) 
		oGet56     := TGet():New( nLin,nCol+120,{|u| If(PCount()>0,nValCof :=u,nValCof)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nValCof",,) 
		
		oSay107    := TSay():New( nLin,nCol+175,{||"INSS"}	,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		oGet93     := TGet():New( nLin,nCol+230,{|u| If(PCount()>0,nINSALQ :=u,nINSALQ)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nINSALQ",,) 
		oGet90     := TGet():New( nLin,nCol+285,{|u| If(PCount()>0,nINSVAL :=u,nINSVAL)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nINSVAL",,) 

		nLin += 13
		oSay45     := TSay():New( nLin  ,nCol+065,{||"Aliq IR:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay58     := TSay():New( nLin  ,nCol+120,{||"Valor IR:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay101    := TSay():New( nLin	,nCol+230,{||"Aliq CSLL:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay100    := TSay():New( nLin	,nCol+285,{||"Valor CSLL:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)

		nLin += 8
		oSay69     := TSay():New( nLin,nCol+010,{||"IR"}	,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		oGet41     := TGet():New( nLin,nCol+065,{|u| If(PCount()>0,nAliqIR :=u,nAliqIR)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nAliqIR",,) 
		oGet52     := TGet():New( nLin,nCol+120,{|u| If(PCount()>0,nVALIRi :=u,nVALIRi)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nVALIRi",,) 
		
		oSay67     := TSay():New( nLin,nCol+175,{||"CSLL"}	,oGrp1,,oArial14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
		oGet93     := TGet():New( nLin,nCol+230,{|u| If(PCount()>0,nCSLALQ :=u,nCSLALQ)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nCSLALQ",,) 
		oGet90     := TGet():New( nLin,nCol+285,{|u| If(PCount()>0,nCSLVAL :=u,nCSLVAL)},oGrp1,045,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nCSLVAL",,) 
	Endif //if do modelo xml	
	oDlg1:Activate(,,,.T.)
	DbselectArea("EXP")
	DbCloseArea()
	DbselectArea("XEXP")
	DbCloseArea()

	If lOmiTTela == NIl
		If !lDiverg
			nOpGera := 1
		Endif
		
		Return(nOpgera)
	Else
		Return(nOpgera) //Return(lDiverg)
	Endif
Else 
	If !IsInCallStack("U_FCLASSAUT")
		MsgInfo("Não Há Divergência a Apresentar")
	Endif
	nOpgera := 1
Endif  //se tem divergência e lOmitTela == Nil



Return()
//--------------------------------------------------------------------------//
//Função: fMostraVlr - Função responsável para atualizar os valores em tela, 
//                     a cada troca de item no grid de itens do XML
//                     Faz a query na ZBT (itens xml) e compara com o array
//                     aIteNFE itens da NF 
//                     aIteNFE (que foi carregado na função HFXML065)
//Autoria: Flávia Rocha
//Data   : 30/03/2020
//--------------------------------------------------------------------------//
**********************************
Static Function fMostraVlr(xItem,cModelo,cChave,xBaseICM,xAliqICM,xValICMi,;
									    xBaseIPI,xAliqIPI,xVALIPIi,;
										xBasePIS,xAliqpis,xValPISi,xValPIS,;
	  									xBasCof ,xAliqCof,xValCOFi,;
	  								    xBasIR  ,xAliqIR ,xValIRi,;
	  								    xBasICMST,xAliqICMST,xValICMiS,xAliqICM,xValICM,;
	  								    aIteNFE,;
	  								    nBaseICM,nAliqICM,nValICMi,;
	  									nBaseIPI,nAliqIPI,nVALIPIi,;
	  									nBasePIS,nAliqpis,nValPISi,;
	  									nBasCof ,nAliqCof,nValCOFi,;
	  									nBasIR  ,nAliqIR ,nValIRi,;
	  									nBasICMST,nAliqICMST,nValICMiS,nValICM,;
	  									lOmiTTela,lDiverg,xXml,xNCM,cNCM,xISSVAL,nISSVAL,xINSVAL,nINSVAL,cItem,xISSALQ,xINSALQ,xCSLALQ,xCSLVAL;
	  									)
	  									/*  									
										oGet46,;	//base icm
										oGet47,; 	//aliq icm
										oGet48,; 	//valor icm	
										oGet13,; 	//base ipi
										oGet38,; 	//aliq ipi
										oGet49,; 	//valor ipi 
										oGet14,;	//base pis
										oGet39,;	//aliq pis
										oGet50,;	//valor pis	
										oGet15,;	//base cofins
										oGet40,;	//aliq cofins
										oGet51,;	//valor cofins	
										oGet18,;	//base ir
										oGet41,;	//aliq ir
										oGet52;		//valor ir	  									
	  								    ) 
	  								    */
**********************************
Local cQuery := ""
Local nPos   := 0
Local aCores := {}
Local oXml   			//FR - 16/06/2020 - ECOURBIS
Local cError   := ""	//FR - 16/06/2020 - ECOURBIS
Local cWarning := "" 	//FR - 16/06/2020 - ECOURBIS
Local cTAG     := ""	//FR - 16/06/2020 - ECOURBIS
Local cTGP     := ""	//FR - 16/06/2020 - ECOURBIS 
Local cTagAux  := ""	//FR - 16/06/2020 - ECOURBIS
Local aDetXml  := {}
Local i		   := 0 
Local oDet
Local cRetXml := ""
cQuery := " SELECT " + CRLF
cQuery += xZBT_+"PRODUT PRODUT , "+ CRLF
cQuery += xZBT_+"ICMBAS ICMBAS , "+ CRLF
cQuery += xZBT_+"QUANT  QUANT  , "+ CRLF
cQuery += xZBT_+"ICMALQ ICMALQ , "+ CRLF
cQuery += xZBT_+"ICMVAL ICMVAL , "+ CRLF
cQuery += xZBT_+"IPIBAS IPIBAS , "+ CRLF
cQuery += xZBT_+"IPIALQ IPIALQ , "+ CRLF
cQuery += xZBT_+"IPIVAL IPIVAL , "+ CRLF
cQuery += xZBT_+"PISBAS PISBAS , "+ CRLF
cQuery += xZBT_+"PISALQ PISALQ , "+ CRLF
cQuery += xZBT_+"PISVAL PISVAL , "+ CRLF
cQuery += xZBT_+"COFBAS COFBAS , "+ CRLF
cQuery += xZBT_+"COFALQ COFALQ , "+ CRLF
cQuery += xZBT_+"COFVAL COFVAL , "+ CRLF
cQuery += xZBT_+"IRRALQ IRRALQ , "+ CRLF
cQuery += xZBT_+"IRRVAL IRRVAL , "+ CRLF
cQuery += xZBT_+"ISSALQ ISSALQ , "+ CRLF
cQuery += xZBT_+"ISSVAL ISSVAL , "+ CRLF
cQuery += xZBT_+"INSVAL INSVAL , "+ CRLF
cQuery += xZBT_+"INSALQ INSALQ , "+ CRLF
cQuery += xZBT_+"CSLALQ CSLALQ , "+ CRLF
cQuery += xZBT_+"CSLVAL CSLVAL , "+ CRLF
cQuery += xZBT_+"NCM NCM        " + CRLF

//FR - 11/01/2022 - PETRA - INCLIR CAMPO ICM ST

//cQuery += xZBZ_+"STVALO STVALO, "   + CRLF
//cQuery += xZBZ_+"STBASE STBASE "    + CRLF

If (xZBT)->(FieldPos(xZBT_+"STVALO")) > 0
	cQuery += ", " + xZBT_+"STVALO STVALO "   + CRLF
Endif 

If (xZBT)->(FieldPos(xZBT_+"STBASE")) > 0
	cQuery += ", " + xZBT_+"STBASE STBASE "    + CRLF
Endif 

If (xZBT)->(FieldPos(xZBT_+"STALIQ")) > 0	
	cQuery += ", " + xZBT_+"STALIQ STALIQ  "    + CRLF
Endif 
//FR - 11/01/2022 - PETRA - INCLIR CAMPO ICM ST


cQuery += " FROM " + RetSqlName(xZBT) + " ZBT " + CRLF

//FR - 11/01/2022 - PETRA - INCLIR CAMPO ICM ST
//cQuery += " INNER JOIN " + RetSqlName(xZBZ) + " ZBZ ON " + xZBZ_+"CHAVE = "+ xZBT_+"CHAVE AND ZBZ.D_E_L_E_T_ <> '*' " 
//FR - 11/01/2022 - PETRA - INCLIR CAMPO ICM ST
cQuery += " WHERE " + xZBT_+"CHAVE = '" + cChave + "' "  + CRLF
cQuery += " AND   " + xZBT_+"ITEM  = '" + xItem  + "' "  + CRLF
cQuery += " AND ZBT.D_E_L_E_T_ <> '*' "

MemoWrite("C:\TEMP\FMOSTRAVLR.SQL" , cQuery)
If Select("TRB") > 0
	dbSelectArea("TRB")
	dbCloseArea()
Endif
//====================================//
// LÊ o XML contido no campo ZBZ_XML  //
//====================================//
oXml := XmlParser(xXml, "_", @cError, @cWarning ) 
If oXml <> NIL .Or. Empty(cError) .Or. Empty(cWarning)
 
	If cModelo $ "55,65"
		cTAG     := "NFE"
		cTGP     := "NFE"
	ElseIf cModelo == "57"
		cTAG     	:= "CTE"
		cTGP        := "CTE"
	ElseIf cModelo == "67"
		cTAG     	:= "CTE"
		cTGP        := "CTEOS"
	ElseIf cModelo == "RP" // Erick 22/08 - Vinculei o modelo RP (NFSE).
		cTAG		:= "NFSE"
		cTGP		:= "NFSETXT"
	EndIf

	If cModelo $ "55,65"
		If XmlChildEx(oXml:_NFEPROC:_NFE:_INFNFE, '_DET') <> NIL
			oDet := oXml:_NFEPROC:_NFE:_INFNFE:_DET
			oDet := IIf(ValType(oDet)=="O",{oDet},oDet)
		Endif 
		
	Elseif cModelo $ "57"

		If XmlChildEx(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST, '_COMP') <> NIL
			oDet := oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP
			oDet := iif( ValType(oDet) == "O", {oDet}, oDet )
		Endif 
		
	Elseif cModelo $ "67"
	
		If XmlChildEx(oXml:_CTEOSPROC:_CTEOS:_INFCTE:_VPREST, '_COMP') <> NIL
			oDet := oXml:_CTEOSPROC:_CTEOS:_INFCTE:_VPREST:_COMP
			oDet := iif( ValType(oDet) == "O", {oDet}, oDet )
		Endif 

	Elseif cModelo $ "RP" // Erick 22/08 - Vinculei o modelo RP (NFSE).

		oDet := oXml:_NFSETXT:_INFPROC
		oDet := iif( ValType(oDet) == "O", {oDet}, oDet )
		
	Endif
Endif

_ICMSTBas:=0		
_ICMSTAlq:= 0
_ICMSTVal:= 0

If oDet <> NIL
If Len(oDet) > 0
	For i := 1 To Len(oDet)

		If cModelo $ "55,65"  
		
			//FR - 11/01/2022 - PETRA - INCLIR CAMPO ICM ST
			_ICMSTBas:=0		
			_ICMSTAlq:= 0
			_ICMSTVal:= 0
			//FR - 11/01/2022 - PETRA - INCLIR CAMPO ICM ST
				
			//codigo produto
			cTagAux    := "oDet["+AllTrim(str(I))+"]:_PROD:_CPROD:TEXT"
			cProduto := UPPER(&cTagAux)
			
			//NCM do produto
			cTagAux := "oDet["+AllTrim(str(I))+"]:_PROD:_NCM:TEXT"
			cNcm := (&cTagAux)
			
			//FR - 11/01/2022 - PETRA - INCLIR CAMPO ICM ST
			//caso não esteja gravado na ZBT, pega do xml e coloca no array abaixo aDetXml
			If XmlChildEx(oDet[i]:_IMPOSTO:_ICMS,"_ICMS60") <> nil
				If XmlChildEx(oDet[i]:_IMPOSTO:_ICMS:_ICMS60,"_VBCSTRET") <> nil
					cTagAux    := "oDet["+AllTrim(str(I))+"]:_IMPOSTO:_ICMS:_ICMS60:_VBCSTRET:TEXT"
				//If Type( cTagAux ) <> "U"
					_ICMSTBas := VAL(ALLTRIM(&cTagAux))
				EndIf 
				
				If XmlChildEx(oDet[i]:_IMPOSTO:_ICMS:_ICMS60,"_PST") <> nil
					cTagAux    := "oDet["+AllTrim(str(I))+"]:_IMPOSTO:_ICMS:_ICMS60:_PST:TEXT"
				//If Type( cTagAux ) <> "U"
					_ICMSTAlq := VAL(ALLTRIM(&cTagAux))
				EndIf
				
				If XmlChildEx(oDet[i]:_IMPOSTO:_ICMS:_ICMS60,"_VICMSSTRET") <> nil
					cTagAux    := "oDet["+AllTrim(str(I))+"]:_IMPOSTO:_ICMS:_ICMS60:_VICMSSTRET:TEXT"
				//If Type( cTagAux ) <> "U"
					_ICMSTVal := VAL(ALLTRIM(&cTagAux))
				EndIf
				
			ElseIf XmlChildEx(oDet[i]:_IMPOSTO:_ICMS,"_ICMS30") <> nil
			
				If XmlChildEx(oDet[i]:_IMPOSTO:_ICMS:_ICMS30,"_VBCST") <> nil
					cTagAux    := "oDet["+AllTrim(str(I))+"]:_IMPOSTO:_ICMS:_ICMS30:_VBCST:TEXT"
				//If Type( cTagAux ) <> "U"
					_ICMSTBas := VAL(ALLTRIM(&cTagAux))
				EndIf 
				
				If XmlChildEx(oDet[i]:_IMPOSTO:_ICMS:_ICMS30,"_PICMSST") <> nil
					cTagAux    := "oDet["+AllTrim(str(I))+"]:_IMPOSTO:_ICMS:_ICMS30:_PICMSST:TEXT"
				//If Type( cTagAux ) <> "U"
					_ICMSTAlq := VAL(ALLTRIM(&cTagAux))
				EndIf
				
				If XmlChildEx(oDet[i]:_IMPOSTO:_ICMS:_ICMS30,"_VICMSST") <> nil
					cTagAux    := "oDet["+AllTrim(str(I))+"]:_IMPOSTO:_ICMS:_ICMS30:_VICMSST:TEXT"
				//If Type( cTagAux ) <> "U"
					_ICMSTVal := VAL(ALLTRIM(&cTagAux))
				EndIf
						
			Endif 
			//FR - 11/01/2022 - PETRA - INCLIR CAMPO ICM ST
			
			Aadd(aDetXml, {cProduto , cNcm , _ICMSTBas, _ICMSTAlq, _ICMSTVal   } )
			
		endif
	Next i
Endif 
Endif 
//+-----------------------
//| Cria uma view no banco
//+-----------------------
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TRB", .T., .F. )
dbSelectArea("TRB")
dbGoTop()
If TRB->(!Eof())

    /*
	xBaseICM := TRB->&(xZBT_+"ICMBAS")
	xAliqICM := TRB->&(xZBT_+"ICMALQ")
	xValICMi := TRB->&(xZBT_+"ICMVAL")
	xBaseIPI := TRB->&(xZBT_+"IPIBAS")
	xAliqIPI := TRB->&(xZBT_+"IPIALQ")
	xVALIPIi := TRB->&(xZBT_+"IPIVAL")
	xBasePIS := TRB->&(xZBT_+"PISBAS")
	xAliqpis := TRB->&(xZBT_+"PISALQ")
	xValPISi := TRB->&(xZBT_+"PISVAL")
	xBasCof  := TRB->&(xZBT_+"COFBAS")
	xAliqCof := TRB->&(xZBT_+"COFALQ")
	xValCOFi := TRB->&(xZBT_+"COFVAL")
	*/
	
	xBaseICM := TRB->ICMBAS
	xAliqICM := TRB->ICMALQ
	xValICMi := TRB->ICMVAL
	xBaseIPI := TRB->IPIBAS
	xAliqIPI := TRB->IPIALQ
	xVALIPIi := TRB->IPIVAL
	xBasePIS := TRB->PISBAS
	xAliqpis := TRB->PISALQ
	xValPISi := TRB->PISVAL
	xBasCof  := TRB->COFBAS
	xAliqCof := TRB->COFALQ
	xValCOFi := TRB->COFVAL
	
	xBasICMST := TRB->STBASE
	xAliqICMST:= TRB->STALIQ //(TRB->STVALO/TRB->STBASE) * 100
	xValICMiS := TRB->STVALO
	xISSVAL   := TRB->ISSVAL
	xINSVAL   := TRB->INSVAL
	xISSALQ   := TRB->ISSALQ
	xINSALQ   := TRB->INSALQ
	xCSLALQ   := TRB->CSLALQ
	xCSLVAL   := TRB->CSLVAL
	xAliqIR   := TRB->IRRALQ
	xValIRi   := TRB->IRRVAL
	xNCM      := TRB->NCM
	
	xBasIR   := 0		//ainda não há campos para IR na ZBT
	//xAliqIR  := 0
	//xValIRi  := 0
	
	nPos     := aScan( aDetXml,{ |x| Alltrim( x[1] ) == AllTrim(TRB->PRODUT) } )
	
	If nPos == 0 	//FR - 06/07/2021 - Tarefas RAfael - mudanças para apresentar ao prospect     
		nPos     := aScan( aDetXml,{ |x| Substr(x[1],1,15) == AllTrim(TRB->PRODUT) } )
	Endif
	
	If nPos > 0
		xNCM     := aDetXml[nPos,2]  
		//se do arquivo não tiver dados, tenta do xml:
		If Empty(xBasICMST) .or. Empty(xAliqICMST) .or. Empty(xValICMiS)
			xBasICMST := aDetXml[nPos,3]		
			xAliqICMST:= aDetXml[nPos,4]
			xValICMiS := aDetXml[nPos,5] 
		Endif 
		
	Endif
	
    //xQuant   := TRB->&(xZBT_+"QUANT")  	//FR - 19/06/2020 - TÓPICOS RAFAEL
    xQuant   := TRB->QUANT
      	
	
Endif
If Len(aIteNFE) > 0
	/* 
Aadd( aIteNFE,{ cItem	    ,; 		//01
cProduto	,; 		//02
nQuant		,;   	//03
cUM		    ,;	 	//04
cTES		,; 	 	//05
cCF 		,;		//06
nPreco		,;  	//07
nTotal  	,;  	//08
nBaseipi	,;  	//09
nValipi 	,;  	//10
nIpi    	,;  	//11
nBaseicm	,;	 	//12
nValicm 	,; 		//13
nIcm 	 	,;	   	//14
nBasepis	,;	 	//15
nValpis 	,;	 	//16
nPis 		,;	 	//17
nBasecof	,;	 	//18
nValcof 	,;	 	//19
nCof   	    ,; 	 	//20
nBaseir 	,;	 	//21
nValir 	    ,; 	 	//22
nIr		    ,;		//23
cNcm		,;      //24
nBasICMST	,;		//25
nValICMST   ,;		//26
nAliqICMST   ;		//27
                                } )   //Armazena no array de itens da NF, para comparar com o xml	 

*/
	//FR - 22/06/2020
	/*
    cItem    := ""
   	If lOmiTTela == Nil
		oSay51:NCLRTEXT := CLR_HBLUE		
		oSay51:Refresh
	Endif
	//FR - 22/06/2020 
		 
	cItem    := " - " + xItem               //FR - 22/06/2020  - verificar depois se Ã© possÃ­vel mudar o item no label da tela, em tempo real
	If lOmiTTela == Nil
		oSay51:NCLRTEXT := CLR_HBLUE		
		oSay51:Refresh
	Endif
	*/
	nPos     := aScan( aIteNFE,{ |x| x[1]== xItem } ) 
		
	If nPos > 0
		nBaseICM := aIteNFE[nPos,12]
		nAliqICM := aIteNFE[nPos,14]
		nValICMi := aIteNFE[nPos,13]
		nBaseIPI := aIteNFE[nPos,09]
		nAliqIPI := aIteNFE[nPos,11]
		nVALIPIi := aIteNFE[nPos,10]
		nBasePIS := aIteNFE[nPos,15]
		nAliqpis := aIteNFE[nPos,17]
		nValPISi := aIteNFE[nPos,16]
		nBasCof  := aIteNFE[nPos,18]
		nAliqCof := aIteNFE[nPos,20]
		nValCOFi := aIteNFE[nPos,19]
		nBasIR   := aIteNFE[nPos,21]
		nAliqIR  := aIteNFE[nPos,23]
		nValIRi  := aIteNFE[nPos,22]
		cNcm     := aIteNFE[nPos,24]
		nQuant   := aIteNFE[nPos,03]	//FR - 19/06/2020 - TÓPICOS RAFAEL 
		
		//FR - 11/01/2022 - PETRA - INCLUIR CAMPO ICM ST
		If Len(aIteNFE[nPos]) >= 25
			nBasICMST:= aIteNFE[nPos,25]
			nValICMiS:= aIteNFE[nPos,26]
			nAliqICMST:= aIteNFE[nPos,27] //Round((nValICMiS / nBasICMST) * 100,2)
		Endif 
		//FR - 11/01/2022 - PETRA - INCLUIR CAMPO ICM ST
		If lOmiTTela == Nil
			oSay51:NCLRTEXT := CLR_HBLUE		
			oSay51:Refresh()
		Endif
		//base icm
		aCores  := U_fVerDivIT(xBaseICM,nBaseICM,@lDiverg)  //fVerDivIT(xValor,xValorNF) 
If xModelo == "55"

			//aliquota do ISS
			aCores           := U_fVerDivIT(xISSALQ,nISSALQ,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay68:NCLRTEXT  := xCorFo23
				oGet66:NCLRTEXT  := xCorFo23
				oGet66:Refresh()
			endif

			//valor do ISS
			aCores           := U_fVerDivIT(xISSVAL,nISSVAL,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay92:NCLRTEXT  := xCorFo23
				oGet90:NCLRTEXT  := xCorFo23
				oGet90:Refresh()
			endif

			//aliquota do PIS
			aCores           := U_fVerDivIT(xAliqPIS,nAliqPIS,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay81:NCLRTEXT  := xCorFo23
				oGet93:NCLRTEXT  := xCorFo23
				oGet93:Refresh()
			endif

			//valor do PIS
			aCores           := U_fVerDivIT(xValPISi,nValPISi,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay56:NCLRTEXT  := xCorFo23
				oGet90:NCLRTEXT  := xCorFo23
				oGet90:Refresh()
			endif

			//aliquota do COFINS
			aCores           := U_fVerDivIT(xAliqCof,nAliqCof,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay49:NCLRTEXT  := xCorFo23
				oGet93:NCLRTEXT  := xCorFo23
				oGet93:Refresh()
			endif

			//valor do COFINS
			aCores           := U_fVerDivIT(xValCof,nValCof,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay73:NCLRTEXT  := xCorFo23
				oGet90:NCLRTEXT  := xCorFo23
				oGet90:Refresh()
			endif

			//aliquota do INSS
			aCores           := U_fVerDivIT(xINSALQ,nINSALQ,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay103:NCLRTEXT := xCorFo23
				oGet93:NCLRTEXT  := xCorFo23
				oGet93:Refresh()
			endif

			//valor do INSS
			aCores           := U_fVerDivIT(xINSVAL,nINSVAL,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay104:NCLRTEXT := xCorFo23
				oGet90:NCLRTEXT  := xCorFo23
				oGet90:Refresh()
			endif

			//aliquota do IR
			aCores           := U_fVerDivIT(xAliqIR,nAliqIR,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay50:NCLRTEXT  := xCorFo23
				oGet58:NCLRTEXT  := xCorFo23
				oGet58:Refresh()
			endif

			//aliquota do IR
			aCores           := U_fVerDivIT(xValIR,nValIR,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay74:NCLRTEXT  := xCorFo23
				oGet57:NCLRTEXT  := xCorFo23
				oGet57:Refresh()
			endif

			//aliquota do CSLL
			aCores           := U_fVerDivIT(xCSLALQ,nCSLALQ,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay101:NCLRTEXT := xCorFo23
				oGet93:NCLRTEXT := xCorFo23
				oGet93:Refresh()
			endif

			//valor do CSLL 
			aCores           := U_fVerDivIT(xCSLVAL,nCSLVAL,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay100:NCLRTEXT := xCorFo23
				oGet90:NCLRTEXT  := xCorFo23
				oGet90:Refresh()
			endif

			/* Base do ICMS
			aCores           := U_fVerDivIT(xBaseICM,nBaseICM,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay50:NCLRTEXT  := xCorFo23
				oGet30:NCLRTEXT  := xCorFo23
				oGet30:Refresh()
			endif
			*/

			//aliquota do ICMS
			aCores           := U_fVerDivIT(xAliqICM,nAliqICM,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay46:NCLRTEXT  := xCorFo23
				oGet42:NCLRTEXT  := xCorFo23
				oGet42:Refresh()
			endif

			//valor do ICMS
			aCores           := U_fVerDivIT(xValICMi,nValICMi,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay70:NCLRTEXT  := xCorFo23
				oGet53:NCLRTEXT  := xCorFo23
				oGet53:Refresh()
			endif

			//aliquota do IPI
			aCores           := U_fVerDivIT(xAliqIPI,nAliqIPI,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay54:NCLRTEXT  := xCorFo23
				oGet43:NCLRTEXT  := xCorFo23
				oGet43:Refresh()
			endif

			//valor do IPI
			aCores           := U_fVerDivIT(xValIPIi,nVALIPIi,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay55:NCLRTEXT  := xCorFo23
				oGet54:NCLRTEXT  := xCorFo23
				oGet54:Refresh()
			endif
			// NCM
			aCores           := U_fVerDivIT(xNCM,cNCM,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23 := aCores[2]
				oSay78:NCLRTEXT  := xCorFo23
				oGet60:NCLRTEXT  := xCorFo23
				oGet60:Refresh()
			endif

Elseif xModelo == "57"

			//aliquota do ISS
			aCores           := U_fVerDivIT(xISSALQ,nISSALQ,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay96:NCLRTEXT  := xCorFo23
				oGet93:NCLRTEXT  := xCorFo23
				oGet93:Refresh()
			endif

			//Valor do ISS
			aCores           := U_fVerDivIT(xISSVAL,nISSVAL,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay92:NCLRTEXT  := xCorFo23
				oGet90:NCLRTEXT  := xCorFo23
				oGet90:Refresh()
			endif

			//aliquota do PIS
			aCores           := U_fVerDivIT(xAliqpis,nAliqPIS,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay48:NCLRTEXT  := xCorFo23
				oGet44:NCLRTEXT  := xCorFo23
				oGet44:Refresh()
			endif

			//Valor do PIS
			aCores           := U_fVerDivIT(xValPISi,nValPISi,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay72:NCLRTEXT  := xCorFo23
				oGet90:NCLRTEXT  := xCorFo23
				oGet90:Refresh()
			endif

			//aliquota do COFINS
			aCores           := U_fVerDivIT(xAliqCof,nAliqCof,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay49:NCLRTEXT  := xCorFo23
				oGet93:NCLRTEXT  := xCorFo23
				oGet93:Refresh()
			endif

			//Vslor do COFINS
			aCores           := U_fVerDivIT(xValCOFi,nValCof,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay73:NCLRTEXT  := xCorFo23
				oGet56:NCLRTEXT  := xCorFo23
				oGet56:Refresh()
			endif

			//aliquota do INSS
			aCores           := U_fVerDivIT(xINSALQ,nINSALQ,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay103:NCLRTEXT := xCorFo23
				oGet93:NCLRTEXT  := xCorFo23
				oGet93:Refresh()
			endif

			//Valor do INSS
			aCores           := U_fVerDivIT(xINSVAL,nINSVAL,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay105:NCLRTEXT := xCorFo23
				oGet90:NCLRTEXT  := xCorFo23
				oGet90:Refresh()
			endif

			//aliquota do IR
			aCores           := U_fVerDivIT(xAliqIR,nAliqIR,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay45:NCLRTEXT  := xCorFo23
				oGet58:NCLRTEXT  := xCorFo23
				oGet58:Refresh()
			endif

			//Valor do IR
			aCores           := U_fVerDivIT(xAliqIR,nVALIRi,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay58:NCLRTEXT  := xCorFo23
				oGet100:NCLRTEXT  := xCorFo23
				oGet100:Refresh()
			endif

			//aliquota do CSLL
			aCores           := U_fVerDivIT(xCSLALQ,nCSLALQ,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay101:NCLRTEXT := xCorFo23
				oGet93:NCLRTEXT  := xCorFo23
				oGet93:Refresh()
			endif

			//Valor do CSLL
			aCores           := U_fVerDivIT(nCSLVAL,xCSLVAL,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay100:NCLRTEXT := xCorFo23
				oGet90:NCLRTEXT  := xCorFo23
				oGet90:Refresh()
			endif

			//aliquota do ICMS
			aCores           := U_fVerDivIT(xAliqICM,nAliqICM,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay46:NCLRTEXT  := xCorFo23
				oGet42:NCLRTEXT  := xCorFo23
				oGet42:Refresh()
			endif

			//Valor do ICMS
			aCores           := U_fVerDivIT(xValICM,nAliqICM,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay70:NCLRTEXT  := xCorFo23
				oGet53:NCLRTEXT  := xCorFo23
				oGet53:Refresh()
			endif

			/*

			//aliquota do IPI
			aCores           := U_fVerDivIT(xAliqIPI,nAliqIPI,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay47:NCLRTEXT  := xCorFo23
				oGet43:NCLRTEXT  := xCorFo23
				oGet43:Refresh()
			endif

			//valor do IPI
			aCores           := U_fVerDivIT(xValIPIi,nVALIPIi,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay71:NCLRTEXT  := xCorFo23
				oGet54:NCLRTEXT  := xCorFo23
				oGet54:Refresh()
			endif

			*/

		Elseif xModelo == "65"

			//aliquota do ICMS
			aCores           := U_fVerDivIT(xAliqICM,nAliqICM,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay46:NCLRTEXT  := xCorFo23
				oGet42:NCLRTEXT  := xCorFo23
				oGet42:Refresh()
			endif

			//valor do ICMS
			aCores           := U_fVerDivIT(xValICMi,nValICMi,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay70:NCLRTEXT  := xCorFo23
				oGet53:NCLRTEXT  := xCorFo23
				oGet53:Refresh()
			endif

			//aliquota do PIS
			aCores           := U_fVerDivIT(xAliqPIS,nAliqPIS,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay81:NCLRTEXT  := xCorFo23
				oGet93:NCLRTEXT  := xCorFo23
				oGet93:Refresh()
			endif

			//valor do PIS
			aCores           := U_fVerDivIT(xValPISi,nValPISi,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay56:NCLRTEXT  := xCorFo23
				oGet90:NCLRTEXT  := xCorFo23
				oGet90:Refresh()
			endif

			//aliquota do COFINS
			aCores           := U_fVerDivIT(xAliqCof,nAliqCof,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay49:NCLRTEXT  := xCorFo23
				oGet93:NCLRTEXT  := xCorFo23
				oGet93:Refresh()
			endif

			//valor do COFINS
			aCores           := U_fVerDivIT(xValCof,nValCof,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay73:NCLRTEXT  := xCorFo23
				oGet90:NCLRTEXT  := xCorFo23
				oGet90:Refresh()
			endif

			//aliquota do IRPJ
			aCores           := U_fVerDivIT(xAliqIR,nAliqIR,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay50:NCLRTEXT  := xCorFo23
				oGet58:NCLRTEXT  := xCorFo23
				oGet58:Refresh()
			endif

			//valor do IRPJ
			aCores           := U_fVerDivIT(xValIR,nValIR,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay74:NCLRTEXT  := xCorFo23
				oGet57:NCLRTEXT  := xCorFo23
				oGet57:Refresh()
			endif				

			//aliquota do CSLL
			aCores           := U_fVerDivIT(xCSLALQ,nCSLALQ,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay50:NCLRTEXT := xCorFo23
				oGet93:NCLRTEXT := xCorFo23
				oGet93:Refresh()
			endif

			//valor do CSLL 
			aCores           := U_fVerDivIT(xCSLVAL,nCSLVAL,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay74:NCLRTEXT := xCorFo23
				oGet90:NCLRTEXT  := xCorFo23
				oGet90:Refresh()
			endif

		Elseif xModelo == "67"

			// aliquota do ICMS
			aCores           := U_fVerDivIT(xAliqICM,nAliqICM,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay46:NCLRTEXT  := xCorFo23
				oGet42:NCLRTEXT  := xCorFo23
				oGet42:Refresh()
			endif

			// valor do ICMS
			aCores           := U_fVerDivIT(xValICMi,nValICMi,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay70:NCLRTEXT  := xCorFo23
				oGet53:NCLRTEXT  := xCorFo23
				oGet53:Refresh()
			endif

			// aliquota do PIS
			aCores           := U_fVerDivIT(xAliqPIS,nAliqPIS,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay81:NCLRTEXT  := xCorFo23
				oGet93:NCLRTEXT  := xCorFo23
				oGet93:Refresh()
			endif

			// valor do PIS
			aCores           := U_fVerDivIT(xValPISi,nValPISi,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay56:NCLRTEXT  := xCorFo23
				oGet90:NCLRTEXT  := xCorFo23
				oGet90:Refresh()
			endif

			// aliquota do COFINS
			aCores           := U_fVerDivIT(xAliqCof,nAliqCof,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay49:NCLRTEXT  := xCorFo23
				oGet93:NCLRTEXT  := xCorFo23
				oGet93:Refresh()
			endif

			//valor do COFINS
			aCores           := U_fVerDivIT(xValCof,nValCof,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay73:NCLRTEXT  := xCorFo23
				oGet90:NCLRTEXT  := xCorFo23
				oGet90:Refresh()
			endif

			// aliquota do IPI
			aCores           := U_fVerDivIT(xAliqIPI,nAliqIPI,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay54:NCLRTEXT  := xCorFo23
				oGet43:NCLRTEXT  := xCorFo23
				oGet43:Refresh()
			endif

			// valor do IPI
			aCores           := U_fVerDivIT(xVALIPIi,nVALIPIi,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay55:NCLRTEXT  := xCorFo23
				oGet54:NCLRTEXT  := xCorFo23
				oGet54:Refresh()
			endif				

			// NCM
			aCores           := U_fVerDivIT(xNCM,cNCM,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay78:NCLRTEXT := xCorFo23
				oGet60:NCLRTEXT := xCorFo23
				oGet60:Refresh()
			endif

		Elseif xModelo == "RP"

			//aliquota do ISS
			aCores           := U_fVerDivIT(xISSALQ,nISSALQ,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay96:NCLRTEXT  := xCorFo23
				oGet93:NCLRTEXT  := xCorFo23
				oGet93:Refresh()
			endif

			//valor do ISS
			aCores           := U_fVerDivIT(xISSVAL,nISSVAL,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay92:NCLRTEXT  := xCorFo23
				oGet90:NCLRTEXT  := xCorFo23
				oGet90:Refresh()
			endif

			//aliquota do PIS
			aCores           := U_fVerDivIT(xAliqpis,nAliqPIS,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay48:NCLRTEXT  := xCorFo23
				oGet44:NCLRTEXT  := xCorFo23
				oGet44:Refresh()
			endif

			//valor do PIS
			aCores           := U_fVerDivIT(xValPISi,nValPISi,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay72:NCLRTEXT  := xCorFo23
				oGet55:NCLRTEXT  := xCorFo23
				oGet55:Refresh()
			endif

			//aliquota do COFINS
			aCores           := U_fVerDivIT(xAliqCof,nAliqCof,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay49:NCLRTEXT  := xCorFo23
				oGet33:NCLRTEXT  := xCorFo23
				oGet33:Refresh()
			endif

			//valor do COFINS
			aCores           := U_fVerDivIT(xValCof,nValCof,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay73:NCLRTEXT  := xCorFo23
				oGet56:NCLRTEXT  := xCorFo23
				oGet56:Refresh()
			endif

			//aliquota do INSS
			aCores           := U_fVerDivIT(xINSALQ,nINSALQ,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay103:NCLRTEXT := xCorFo23
				oGet93:NCLRTEXT  := xCorFo23
				oGet93:Refresh()
			endif

			//valor do INSS
			aCores           := U_fVerDivIT(xINSVAL,nINSVAL,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay105:NCLRTEXT := xCorFo23
				oGet90:NCLRTEXT  := xCorFo23
				oGet90:Refresh()
			endif

			//aliquota do IR
			aCores           := U_fVerDivIT(xAliqIR,nAliqIR,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay45:NCLRTEXT  := xCorFo23
				oGet41:NCLRTEXT  := xCorFo23
				oGet41:Refresh()
			endif

			//valor do IR
			aCores           := U_fVerDivIT(xValIRi,nValIR,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay58:NCLRTEXT  := xCorFo23
				oGet52:NCLRTEXT  := xCorFo23
				oGet52:Refresh()
			endif

			//aliquota do CSLL
			aCores           := U_fVerDivIT(xCSLALQ,nCSLALQ,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay101:NCLRTEXT := xCorFo23
				oGet93:NCLRTEXT  := xCorFo23
				oGet93:Refresh()
			endif

			//Valor do CSLL
			aCores           := U_fVerDivIT(xCSLVAL,nCSLVAL,@lDiverg)
			If lOmiTTela == Nil
				xCorFo23         := aCores[1]
				xCorFu23         := aCores[2]
				oSay100:NCLRTEXT := xCorFo23
				oGet90:NCLRTEXT  := xCorFo23
				oGet90:Refresh()
			endif
		endif
	Endif //if nPos > 0		
Endif  //FR - Endif do If Len(aIteNFE) > 0
DbSelectArea("TRB") 
DbCloseArea()
Return
//--------------------------------------------------------------------------//
//Função: fCheckCpos - Função responsável por checar se existem os campos  
//        da tabela xZBT (ZBT), Sem estes campos, não é possível gerar a 
//        tela de divergência
//Autoria: Flávia Rocha
//Data   : 30/03/2020
//--------------------------------------------------------------------------//
****************************************************
User Function fCheckCpos()
****************************************************
Local cMsgCpo   := ""
Local fr        := 0
Local cCpo      := ""
Local lExistCpo := .T.
Local aNovosZBZ := {}
Local aNovosZBT := {}
//verificacão se os campos relativos a impostos existem na tabela ZBT:
Aadd(aNovosZBZ,{"BASCAL" ,;
				"ICMVAL",;
				"ICMDES",;
				"STBASE",;
				"STVALO",;
				"IPIVAL",;
				"IPIDEV",;
				"PISVAL",;
				"COFVAL",;
				"OUTVAL",;
				"DTFIS";
				})
				
Aadd(aNovosZBT, {"ICMCST",;
				 "ICMBAS",;
				 "ICMALQ",;
				 "ICMVAL",;
				 "PISCST",;
				 "PISBAS",;
				 "PISALQ",;
				 "PISVAL",;
				 "COFCST",;
				 "COFBAS",;
				 "COFALQ",;
				 "COFVAL",;
				 "IPIENQ",;
				 "IPICST",;
				 "IPIBAS",;
				 "IPIALQ",;
				 "IPIVAL";				 
				})
For fr := 1 to Len(aNovosZBZ[1])
	cCpo := (xZBZ_+aNovosZBZ[1,fr])		//ex: &(ZBZ_"BASCAL" )
	If !(xZBZ)->(FieldPos(cCpo)) > 0
		lExistCpo := .F.
		cMsgCpo += cCpo + "/ "
	Endif
Next
For fr := 1 to Len(aNovosZBT[1])
	cCpo := (xZBT_+aNovosZBT[1,fr])		//ex: &(ZBT_"IPIVAL" )
	If !(xZBT)->(FieldPos(cCpo)) > 0
		lExistCpo := .F.
		cMsgCpo += cCpo + "/ "
	Endif
Next
If !lExistCpo
		Aviso(	"Auditoria Fiscal",;       //String que vai no topo da janela
			"Os Seguintes Campos Não Constam na Base de Dados: " + CHR(13) + CHR(10) + CHR(13) + CHR(10) +;
			cMsgCpo + CHR(13) + CHR(10)+ CHR(13) + CHR(10)+;
			"É Necessário Executar o Compatibilizador U_UPDIF001.",;
			{"&Ok"},,;
			"Compatibilizador de Dicionário")     //String que fica abaixo da 1a.
		//Return(lGera) //deixa gerar a NF normalmente sem realizar a auditoria	
Endif
Return(lExistCpo) 
//--------------------------------------------------------------------------//
//Função: GerArqNFE - Gera arquivo temporário responsável pelas informações 
//        a serem exibidas do lado direito da tela de divergências:
//        informações da Nota Fiscal
//Autoria: Flávia Rocha
//Data   : 30/03/2020
//--------------------------------------------------------------------------//
****************************************************
Static Function GerArqNFE(cARQTMP,aESTRUT,aIteNFE)
***************************************************	
Local fr := 0
//CRIA ARQUIVO TEMPORARIO COM A ESTRUTURA ACIMA
cARQTMP := CriaTrab( aESTRUT, .T. )
If Select("EXP") > 0
	DbSelectArea("EXP")
	DbcloseArea()
Endif 
DbUseArea( .T.,, cARQTMP, "EXP", .F., .F. )
For fr := 1 to Len(aIteNFE) 
	RecLock("EXP",.T.) 
	EXP->ITEM   := aIteNFE[fr,1]
	EXP->CODIGO := aIteNFE[fr,2] 
	EXP->DESCRI := Posicione("SB1",1,xFilial("SB1")+ aIteNFE[fr,2] ,"B1_DESC") 
	EXP->NCM    := aIteNFE[fr,24]	//FR - 16/06/2020 - ECOURBIS
	EXP->QUANT  := aIteNFE[fr,3]
	EXP->UM     := aIteNFE[fr,4]
	EXP->VUNIT  := aIteNFE[fr,7]
	EXP->VTOTAL := aIteNFE[fr,8]
	EXP->ALQICM := aIteNFE[fr,14]
	EXP->BASICM := aIteNFE[fr,12]
	EXP->VALICM := aIteNFE[fr,13]
	EXP->ALQIPI := aIteNFE[fr,11]
	EXP->BASIPI := aIteNFE[fr,9]
	EXP->VALIPI := aIteNFE[fr,10]
	EXP->ALQPIS := aIteNFE[fr,17]
	EXP->BASPIS := aIteNFE[fr,15]
	EXP->VALPIS := aIteNFE[fr,16]
	EXP->ALQCOF := aIteNFE[fr,20]
	EXP->BASCOF := aIteNFE[fr,18]
	EXP->VALCOF := aIteNFE[fr,19]
	EXP->ALQIR  := aIteNFE[fr,23]
	EXP->BASIR  := aIteNFE[fr,21]
	EXP->VALIR  := aIteNFE[fr,22]
	EXP->NCM    := aIteNFE[fr,24]
	If Len(aIteNFE[fr]) >= 25
		EXP->STBASE := aIteNFE[fr,25]
		EXP->STVALO := aIteNFE[fr,26]
		EXP->STALIQ := aIteNFE[fr,27]  
	Endif 

	If Len(aIteNFE[fr]) >= 28
		EXP->ALIQISS := aIteNFE[fr,28]
		EXP->VALISS  := aIteNFE[fr,29]
		EXP->VALINS  := aIteNFE[fr,30]
		EXP->ALIQINS := aIteNFE[fr,31]
		EXP->ALQCSL  := aIteNFE[fr,32]
		EXP->CSLVAL  := aIteNFE[fr,33]
	Endif 
	EXP->(MsUnlock())
Next  
Return     
//--------------------------------------------------------------------------//
//Função: GerArqXML - Gera arquivo temporário responsável pelas informações 
//        a serem exibidas do lado esquerdo da tela de divergências:
//        informações do XML
//Autoria: Flávia Rocha
//Data   : 30/03/2020
//--------------------------------------------------------------------------//     
****************************************************
Static Function GerarqXML(xARQTMP,aESTRUT,aIteXML)  
****************************************************
Local fr := 0
//CRIA ARQUIVO TEMPORARIO COM A ESTRUTURA ACIMA
xARQTMP := CriaTrab( aESTRUT, .T. )
DbUseArea( .T.,, xARQTMP, "XEXP", .F., .F. )
For fr := 1 to Len(aIteXML) 
	RecLock("XEXP",.T.) 
	XEXP->ITEM   := aIteXML[fr,31]
	XEXP->CODIGO := aIteXML[fr,3]
	XEXP->DESCRI := aIteXML[fr,4]
	XEXP->QUANT  := aIteXML[fr,25]
	XEXP->UM     := Posicione("SB1",1,xFilial("SB1")+ aIteXML[fr,3],"B1_UM") //Fornecedor  //aIteXML[fr,4]
	XEXP->VUNIT  := aIteXML[fr,26]
	XEXP->VTOTAL := aIteXML[fr,27]
	
	XEXP->ALQICM := aIteXML[fr,10]
	XEXP->BASICM := aIteXML[fr,9]
	XEXP->VALICM := aIteXML[fr,11]
	
	XEXP->ALQIPI := aIteXML[fr,23]
	XEXP->BASIPI := aIteXML[fr,22]
	XEXP->VALIPI := aIteXML[fr,24]
	
	XEXP->ALQPIS := aIteXML[fr,14]
	XEXP->BASPIS := aIteXML[fr,13]
	XEXP->VALPIS := aIteXML[fr,15]
	
	XEXP->ALQCOF := aIteXML[fr,18]
	XEXP->BASCOF := aIteXML[fr,17]
	XEXP->VALCOF := aIteXML[fr,19]
	
	XEXP->ALQIR  := 0  //aIteXML[fr,23]
	XEXP->BASIR  := 0  //aIteXML[fr,21]
	XEXP->VALIR  := 0  //aIteXML[fr,22]
	XEXP->NCM    := aIteXML[fr,32]
	
	/*
	cChaveOri,;		//33-Chave da nf original (caso haja) //FR - 15/02/2021 - #6166 - MaxiRubber - NOVO CAMPO, chave da nf original (CTE)	
	cUM,;      		//34-Unidade de medida do produto	  //FR - 15/04/2021
	cNFCI,;			//35-FCI
	nVLDESC,;		//36-VLDESC
	cLOTE,;			//37-LOTE
	dValLote,;		//38-Validade Lote
	cAnoFab,;		//39-Ano de fabricação (com dois digitos)
	_ICMSTBas,;		//40-Base ICM ST
	_ICMSTAlq,;		//41-Aliq ICM ST
	_ICMSTVal;		//42-Valor ICM ST
	*/
	If Len(aIteXML) >= 33
		XEXP->STBASE   := aIteXML[fr,40] 
		XEXP->STALIQ   := aIteXML[fr,41] 
		XEXP->STVALO   := aIteXML[fr,42] 
	Endif 
	
	XEXP->(MsUnlock())
Next      
Return

//--------------------------------------------------------------------------//
//Função: fVerDivCab - Efetua comparativos campo a campo 
//        para checar se há divergências no cabeçalho XML x NF
//Autoria: Flávia Rocha
//Data   : 30/03/2020
//--------------------------------------------------------------------------//
****************************************************
User Function fVerDivCab(xValor,aCabNFE,nLin,nPos,lDiverg) 
****************************************************
Local aCores   := {}
Local xCorFora := 0
Local xCorFundo:= 0
//Compara informações dos cabeçalhos:
If xValor <> aCabNFE[nLin,nPos]  //vlr merc
	xCorFora  := CLR_HRED 	//CLR_HBLUE
	//xCorFundo := CLR_YELLOW  	//se quiser usar cor de fundo na divergÃªncia, amarelo
	xCorFundo := CLR_WHITE
	lDiverg   := .T.
Else
	xCorFora  := CLR_BLACK
	xCorFundo := CLR_WHITE
Endif
Aadd(aCores, xCorFora)
Aadd(aCores, xCorFundo)
Return(aCores)

//--------------------------------------------------------------------------//
//Função: fVerDivIT - Efetua comparativos campo a campo 
//        para checar se há divergências nos itens: XML x NF
//Autoria: Flávia Rocha
//Data   : 30/03/2020
//--------------------------------------------------------------------------//
****************************************************
User Function fVerDivIT(xValor,xValorNF,lDiverg) 
****************************************************
Local aCores   := {}
Local xCorFora := 0
Local xCorFundo:= 0

xCorFora  := CLR_BLACK
xCorFundo := CLR_WHITE

//FR - 30/11/2020 - qdo o comparativo é para NCM, precisa checar se é caracter e adicionar Alltrim
//Solicitado por RL: ao mudar de um item para outro, mesmo com NCM igual, mantém a cor vermelha indicando divergência - corrigido OK
If ValType(xValor) == "C" .and. Valtype(xValorNF) == "C" 

	If Alltrim(xValor) <> Alltrim(xValorNF)
		xCorFora  := CLR_HRED 
		xCorFundo := CLR_WHITE
		lDiverg   := .T.
	Else
		xCorFora  := CLR_BLACK
		xCorFundo := CLR_WHITE
	Endif

Elseif ValType(xValor) <> "C" .and. Valtype(xValorNF) <> "C" 
	If xValor <> xValorNF 
		xCorFora  := CLR_HRED 
		xCorFundo := CLR_WHITE
		lDiverg   := .T.
	Else
		xCorFora  := CLR_BLACK
		xCorFundo := CLR_WHITE
	Endif
	
Endif

Aadd(aCores, xCorFora)
Aadd(aCores, xCorFundo)

Return(aCores)
//--------------------------------------------------------------------------//
//Função: fExpEXCL - Exporta para uma planilha em Excel as informações 
//        contidas na tela de divergências.
//Autoria: Flávia Rocha
//Data   : 30/03/2020
//--------------------------------------------------------------------------//
*************************
User Function fExpEXCL(cNota,cSerie,cFornece,cLojfor)
*************************
Local aParams   := {}
Local aNFDiverg := {}
Aadd(aNFDiverg , {cNota, cSerie, cFornece, cLojfor} )			
U_fPovoaPar(@aParams,aNFDiverg)
U_HFXMLR16(aParams)     //chama o relatorio ja passando por parametro a NF/XML a ser verificado

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
//====================================================================//
//Função  : HFXML63A - Análise Fiscal
//Autoria : Flávia Rocha
//====================================================================//
User Function HFXML63A()
	Local oDlg   := Nil
	Local oExpl  := Nil
	
	Local aPanels:= {}
	
	Local nLiIni := 0 			
	Local nCoIni := 0        	
	Local nLiFim := 0        	
	Local nCoFim := 0
	Local nIt    := 0        	
	
	Private oDataDe
	Private oDataAte
	Private oDescUser
	Private oFornec
	Private oLoj
	Private oFilDe
	Private oFilAte
	Private oNF
	Private oSerie
	Private oChart,oChart2
		
	Private oGetDados11										
	Private aHeader11:= {}									
	Private noBrw11  := 0 
	
	Private oGetDados12										
	Private aHeader12:= {}									
	Private noBrw12  := 0
	
	Private oGetDadosf1										
	Private aHeaderf1:= {}									
	Private noBrwf1  := 0 
	
	Private oGetDadosd1										
	Private aHeaderd1:= {}									
	Private noBrwd1  := 0 
	 
	Private oGetDadosQX
	Private aHeaderQX := {}
	Private aColsQX   := {}
    Private noBrwQX   := 0          							
	
	Private aSize   := {} 								
	Private aInfo   := {}								
	Private aPos    := {}			

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
	
	Private dDataDe  := FirstDay(dDatabase) //_Dataini 							
	Private dDataAte := LastDay(dDatabase)  //_DataFim 
	Private cFili    := (xZBZ)->&(xZBZ_+"FILIAL") 										
	Private cFornec  := (xZBZ)->&(xZBZ_+"CODFOR") //xFornec		
	Private cLoj     := (xZBZ)->&(xZBZ_+"LOJFOR")  //xLoj
	Private cNF      := (xZBZ)->&(xZBZ_+"NOTA") 		
	Private cSerie   := (xZBZ)->&(xZBZ_+"SERIE") 
	Private xTpNF    := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC")))	
	Private _cTblCad := Iif(xTpNF $ "D|B","SA1","SA2")			
	Private cFilDe   := ' ' //xFilDe							
	Private cFilAte  := 'ZZ '//xFilAte							
	Private oGetDados 
	Private aAltera  := {}
	Private aCposZBZ := {}    									
	Private aCposZBT := {}
	Private aCposSF1 := {}
	Private aCposSD1 := {} 
	Private aCposQX  := {}
    
	Private oBold     := TFont():New("Arial",14,14,,.T.,,,,.T.,.F.)
	Private oBold1    := TFont():New("Arial",12,12,,.T.,,,,.T.,.F.)
	//Local oFont08   := TFont():New("Times New Roman",08,08,,.F.,,,,.T.,.F.)
	//Local oFont08N  := TFont():New("Times New Roman",08,08,,.T.,,,,.T.,.F.)
	
	Static cUserLog  :=  RetCodUsr()
	Static cDescUser := UsrFullName ( cUserLog )
	Static _NomeBotao:= ""
	Static c_Eol  := CHR(13)+CHR(10) 
	
	//Define FONT oBold    NAME "Arial" SIZE 0, -12 BOLD
	
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

	nLiIni := aInfo[1] + 10 //0+10=10 		
	nCoIni := nLiIni		//10        	
	nLiFim := aInfo[4]      //446		  	
	nCoFim := aInfo[3]-200  //953-200=753	
	
	//Instancia Objeto
	oExpl := MsExplorer():New("Titulo da MSExplorer",nLiIni,nCoIni,nLiFim,nCoFim,oDlg,/*lToolBar*/,/*lAddressBar*/,/*lDefBar*/,/*oTreeFont*/,/*cBitmap*/,/*nBmpWidth*/,/*oParent*/)
	
	//Cria EnchoiceButtons
	//oExpl(): DefaultBar ( )

	//oExpl:AddDefButton("CLIPS"	,"ToolTip 01"	,{|| msgInfo("Botao ZeroUm")}		,/*cDefaultAct*/	,/*bWhen*/,/*nWidth*/,"Botao Zero Um - 01")  
	//oExpl:AddDefButton("CLIENTE"	,"ToolTip 02"	,{|| msgInfo("Botao ZeroDois")}		,/*cDefaultAct*/	,/*bWhen*/,/*nWidth*/,"Botao Zero Um - 02")
	//oExpl:AddDefButton("CHAT"		,"ToolTip 03"	,{|| msgInfo("Botao ZeroTres")}		,/*cDefaultAct*/	,/*bWhen*/,/*nWidth*/,"Botao Zero Um - 03")
	//oExpl:AddDefButton("COMSOM"	,"ToolTip 04"	,{|| msgInfo("Botao ZeroQuatro")}	,/*cDefaultAct*/	,/*bWhen*/,/*nWidth*/,"Botao Zero Um - 04")
	//oExpl:AddDefButton("CARGA"	,"ToolTip 04"	,{|| FSBrwEnd()}	,/*cDefaultAct*/	,/*bWhen*/,/*nWidth*/,"Botao Zero Um - 05")//Cria um item da Arvore
	//oExpl:AddDefButton("FINAL"	,"ToolTip 04"	,{|| oExpl:DeActivate()}	,/*cDefaultAct*/	,/*bWhen*/,/*nWidth*/,"Botao Zero Um - 05")//Cria um item da Arvore
	oExpl:AddDefButton("FINAL"		,"Voltar"	,{|| oExpl:DeActivate()}	,/*cDefaultAct*/	,/*bWhen*/,/*nWidth*/,"Para Voltar à Janela Anterior")	

   	//Árvore
   	nIt := 1     //Incrementar para cada novo nó da árvore
   	 
   	//aAdd(aPanels,    oExpl:AddTree("Info Geral","BR_LARANJA"	,"BR_VERDE","#1000",.T.))	//1-Info Geral: item cabeça da árvore  
   	aAdd(aPanels,    oExpl:AddTree(cNF + "/" + cSerie,"BR_LARANJA"	,"BR_VERDE","#1000",.T.))	//1-Numero NF / Serie: item cabeça da árvore  
   	
   		_fGera01(oExpl:GetPanel(aPanels[nIt]) , aInfo)  //mostra os campos de data inicial/final, fornecedor/loja, filial de/até, usuário logado 
	    
		//Sub-itens 
		nIt++
		aAdd(aPanels,    oExpl:AddItem("INFO GERAL","BR_ROXO","#1100",.T.)) 			
			_fGeraD( oExpl:GetPanel(aPanels[nIt])) 		
		
		//nIt++
		//aAdd(aPanels,    oExpl:AddItem("Graf.2","BR_ROXO","#1200",.T.))							
		//	_fGera03(oExpl:GetPanel(aPanels[nIt]) , aPos) 	
		//nIt++
		//aAdd(aPanels,    oExpl:AddItem("Graf.3","BR_ROXO","#1300",.T.))				  			
		//	_fGera04(oExpl:GetPanel(aPanels[nIt]))    
	
		//Sub-Árvore		
		aAdd(aPanels,    oExpl:AddTree("COMPARA VLR"	,"BR_PRETO"	,"BR_BRANCO","#1400",.T.))      	//cabeça da árvore
		aAdd(aPanels,    oExpl:AddItem("Totais"   		,"BR_ROXO","#1410",.T.))   
		aAdd(aPanels,    oExpl:AddItem("Unitario" 		,"BR_ROXO","#1412",.T.))               		            			              		            			
		//aAdd(aPanels,    oExpl:AddItem("Qtde"       ,"BR_ROXO","#1411",.T.)) 
		
			nLi := nLiIni + 40 //10+40=50
			nIt++
			@nLi,50 SAY "Opção: Comparativos Valores:"	PIXEL SIZE 350,30 FONT oBold COLOR CLR_MAGENTA OF oExpl:GetPanel(aPanels[nIt]) 
			
			nLi := nLi + 20  //50+20 = 70		
			@nLi,50 SAY "Exibe os Comparativos Dos Valores entre XML x Nota Fiscal"	PIXEL SIZE 450,30 FONT oBold COLOR CLR_HBLUE OF oExpl:GetPanel(aPanels[nIt]) 
			
			//comparativo dos valores totais 
			nIt++		                    						
			_fCompT( oExpl:GetPanel(aPanels[nIt]) )    	//compara totais
			
			//comparativos dos valores unitários
			nIt++ 
			_fCompV( oExpl:GetPanel(aPanels[nIt]) )  	//compara vlr unitários                     					
		
		oExpl:EndTree() //Fecha Sub-item	
        
		//Sub-Árvore Quantidades
		aAdd(aPanels,    oExpl:AddTree("COMPARA QTD"	,"BR_PRETO"	,"BR_BRANCO","#1500",.T.))      	//cabeça da árvore
		aAdd(aPanels,    oExpl:AddItem("Qtde"       	,"BR_ROXO","#1510",.T.))   
		
			nLi := nLiIni + 40 
			nIt++
			@nLi,50 SAY "Opção: Comparativos Quantidades:"	PIXEL SIZE 350,30 FONT oBold COLOR CLR_MAGENTA OF oExpl:GetPanel(aPanels[nIt]) 
			
			nLi := nLi + 20  		
			@nLi,50 SAY "Exibe os Comparativos Das Quantidades entre XML x Nota Fiscal"	PIXEL SIZE 450,30 FONT oBold COLOR CLR_HBLUE OF oExpl:GetPanel(aPanels[nIt]) 
			
			//comparativos das qtdes dos itens
			nIt++ 
			_fCompQ( oExpl:GetPanel(aPanels[nIt]) ) 	//compara qtdes 
		
		oExpl:EndTree() //Fecha Sub-item	 
		
		//Sub-Árvore Impostos Totais	
		aAdd(aPanels,    oExpl:AddTree("IMPOSTO TOTAL"		,"BR_LARANJA"	,"BR_MARROM","#2000",.T.))   //7 Impostos: item cabeça da árvore			 
		aAdd(aPanels,    oExpl:AddItem("Totais ICMS"		,"BR_ROXO"     	,"#2100",.T.))     	   		
		aAdd(aPanels,    oExpl:AddItem("Tot ICM ST"  		,"BR_ROXO" 		,"#2200",.T.))         		
		aAdd(aPanels,    oExpl:AddItem("Totais IPI"  		,"BR_ROXO" 		,"#2300",.T.))         		
		aAdd(aPanels,    oExpl:AddItem("Totais PIS"  		,"BR_ROXO" 		,"#2400",.T.))
		aAdd(aPanels,    oExpl:AddItem("Tot COFINS"  		,"BR_ROXO" 		,"#2500",.T.))
		aAdd(aPanels,    oExpl:AddItem("Tot INSS"  	   		,"BR_ROXO" 		,"#2600",.T.)) 
		aAdd(aPanels,    oExpl:AddItem("Tot ISS"  	 		,"BR_ROXO" 		,"#2700",.T.))
		aAdd(aPanels,    oExpl:AddItem("Tot IR" 	 		,"BR_ROXO" 		,"#2800",.T.)) 
		aAdd(aPanels,    oExpl:AddItem("Tot CSLL"  	   		,"BR_ROXO" 		,"#2900",.T.))        
		
			nLi := nLiIni + 40 //10+40=50
			nIt++
			@nLi   ,50 	SAY "Opção: Impostos - Totais"							PIXEL SIZE 350,30 FONT oBold COLOR CLR_MAGENTA OF oExpl:GetPanel(aPanels[nIt]) 
			@nLi+10,50 	SAY "Efetua Comparação Entre os Totais dos Impostos - XML x NOTA FISCAL:"	PIXEL SIZE 500,30 FONT oBold COLOR CLR_HBLUE OF oExpl:GetPanel(aPanels[nIt]) 
			@nLi+20,50 	SAY "- ICMS"											PIXEL SIZE 250,30 FONT oBold COLOR CLR_BLUE OF oExpl:GetPanel(aPanels[nIt]) 
			@nLi+30,50 	SAY "- ICM ST"											PIXEL SIZE 250,30 FONT oBold COLOR CLR_BLUE OF oExpl:GetPanel(aPanels[nIt]) 
			@nLi+40,50 	SAY "- IPI"												PIXEL SIZE 250,30 FONT oBold COLOR CLR_BLUE OF oExpl:GetPanel(aPanels[nIt])  
			@nLi+50,50 	SAY "- PIS"												PIXEL SIZE 250,30 FONT oBold COLOR CLR_BLUE OF oExpl:GetPanel(aPanels[nIt]) 
			@nLi+60,50 	SAY "- COFINS"											PIXEL SIZE 250,30 FONT oBold COLOR CLR_BLUE OF oExpl:GetPanel(aPanels[nIt]) 
			@nLi+70,50 	SAY "- INSS"											PIXEL SIZE 250,30 FONT oBold COLOR CLR_BLUE OF oExpl:GetPanel(aPanels[nIt]) 
			@nLi+80,50 	SAY "- ISS"												PIXEL SIZE 250,30 FONT oBold COLOR CLR_BLUE OF oExpl:GetPanel(aPanels[nIt]) 
			@nLi+90,50 	SAY "- IR"												PIXEL SIZE 250,30 FONT oBold COLOR CLR_BLUE OF oExpl:GetPanel(aPanels[nIt]) 
			@nLi+100,50 SAY "- CSLL"											PIXEL SIZE 250,30 FONT oBold COLOR CLR_BLUE OF oExpl:GetPanel(aPanels[nIt]) 
		    
			//comparativo icms
			nIt++
			_fCompI(oExpl:GetPanel(aPanels[nIt]))                                        	//Compara ICM total  x XML x Entrada 
			
			//comparatico icm st
			nIt++
			_fCompI2(oExpl:GetPanel(aPanels[nIt]))                                        	//Compara ICM ST total  x XML x Entrada 
			
			//comparativo ipi
			nIt++
			_fCompIP(oExpl:GetPanel(aPanels[nIt]))                                        	//Compara IPI total  x XML x Entrada
			
			//comparativo pis
			nIt++
			_fCompPI(oExpl:GetPanel(aPanels[nIt]))                                        	//Compara PIS total  x XML x Entrada
			
			//comparativo cofins
			nIt++
			_fCompCO(oExpl:GetPanel(aPanels[nIt]))                                        	//Compara COFINS total  x XML x Entrada 
			
			//comparativo inss
			nIt++
			_fCompIN(oExpl:GetPanel(aPanels[nIt]))                                        	//Compara INSS total  x XML x Entrada 								 								 																
			
			//comparativo iss
			nIt++
			_fCompIS(oExpl:GetPanel(aPanels[nIt]))                                        	//Compara ISS total  x XML x Entrada
			
			//comparativo ir
			nIt++
			_fCompIR(oExpl:GetPanel(aPanels[nIt]))                                        	//Compara IR total  x XML x Entrada
			
			//comparativo csll
			nIt++
			_fCompCS(oExpl:GetPanel(aPanels[nIt]))                                        	//Compara CSLL total  x XML x Entrada 								 								 																 								 								 																 								 								 																
		       		         		
		oExpl:EndTree() //Fecha Sub-Árvore
	
		//Sub-Árvore Impostos por item
		aAdd(aPanels,    oExpl:AddTree("IMPOSTO ITEM","BR_AZUL"	,"BR_AMARELO","#3000",.T.))   	//10-IMPOSTOS ITEM
		aAdd(aPanels,    oExpl:AddItem("ICMS It" ,"BR_ROXO","#3100",.T.))                 	
		//aAdd(aPanels,    oExpl:AddItem("ST It"   ,"BR_ROXO","#3200",.T.))               	   	
		aAdd(aPanels,    oExpl:AddItem("IPI It"   ,"BR_ROXO","#3200",.T.))               	   	
		aAdd(aPanels,    oExpl:AddItem("PIS It"   ,"BR_ROXO","#3300",.T.))               	   	
		aAdd(aPanels,    oExpl:AddItem("COF It"   ,"BR_ROXO","#3400",.T.))               	   	
		aAdd(aPanels,    oExpl:AddItem("INSS It"   ,"BR_ROXO","#3500",.T.))               	   	
		aAdd(aPanels,    oExpl:AddItem("ISS It"   ,"BR_ROXO","#3600",.T.)) 
		aAdd(aPanels,    oExpl:AddItem("IR It"   ,"BR_ROXO","#3700",.T.))
		aAdd(aPanels,    oExpl:AddItem("CSLL It"   ,"BR_ROXO","#3800",.T.))               	   	               	   	              	   	
		//oExpl:EndTree() //Fecha Sub-Árvore		
				
			nIt++
			@nLi,50 SAY "Opção: Impostos por Item:"	PIXEL SIZE 350,30 FONT oBold COLOR CLR_MAGENTA OF oExpl:GetPanel(aPanels[nIt]) 
				
			nLi := nLi + 20  		
			@nLi+10,50 SAY "Efetua Comparação Entre os Valores dos Impostos Por Item - XML x NOTA FISCAL:"	PIXEL SIZE 500,30 FONT oBold COLOR CLR_HBLUE OF oExpl:GetPanel(aPanels[nIt]) 
			@nLi+20,50 SAY "- ICMS"												PIXEL SIZE 250,30 FONT oBold COLOR CLR_BLUE OF oExpl:GetPanel(aPanels[nIt]) 
			//@nLi+30,50 SAY "- ICM ST"											PIXEL SIZE 250,30 FONT oBold COLOR CLR_BLUE OF oExpl:GetPanel(aPanels[nIt]) 
			@nLi+30,50 SAY "- IPI"												PIXEL SIZE 250,30 FONT oBold COLOR CLR_BLUE OF oExpl:GetPanel(aPanels[nIt])  
			@nLi+40,50 SAY "- PIS"												PIXEL SIZE 250,30 FONT oBold COLOR CLR_BLUE OF oExpl:GetPanel(aPanels[nIt]) 
			@nLi+50,50 SAY "- COFINS"											PIXEL SIZE 250,30 FONT oBold COLOR CLR_BLUE OF oExpl:GetPanel(aPanels[nIt]) 
			@nLi+60,50 SAY "- INSS"												PIXEL SIZE 250,30 FONT oBold COLOR CLR_BLUE OF oExpl:GetPanel(aPanels[nIt]) 
			@nLi+70,50 SAY "- ISS"												PIXEL SIZE 250,30 FONT oBold COLOR CLR_BLUE OF oExpl:GetPanel(aPanels[nIt]) 
			@nLi+80,50 SAY "- IR"												PIXEL SIZE 250,30 FONT oBold COLOR CLR_BLUE OF oExpl:GetPanel(aPanels[nIt]) 
			@nLi+90,50 SAY "- CSLL"												PIXEL SIZE 250,30 FONT oBold COLOR CLR_BLUE OF oExpl:GetPanel(aPanels[nIt]) 
			
			//comparativo icms
			nIt++
			_fCompIi(oExpl:GetPanel(aPanels[nIt]))                                        	//Compara ICM x XML x Entrada (por item)
			
			//comparativo icm st
			//nIt++
			//_fCompI2i(oExpl:GetPanel(aPanels[nIt]))                                        	//Compara ICM ST total  x XML x Entrada (por item) 
			
			//comparativo ipi
			nIt++
			_fCompIPi(oExpl:GetPanel(aPanels[nIt]))                                        	//Compara IPI total  x XML x Entrada (por item) 
			
			//comparativo pis
			nIt++
			_fCompPIi(oExpl:GetPanel(aPanels[nIt]))                                        	//Compara PIS total  x XML x Entrada (por item)
			
			//comparativo cofins
			nIt++
			_fCompCOi(oExpl:GetPanel(aPanels[nIt]))                                        	//Compara COFINS total  x XML x Entrada (por item)  
			
			//comparativo inss
			nIt++
			_fCompINi(oExpl:GetPanel(aPanels[nIt]))                                        	//Compara INSS total  x XML x Entrada (por item)  
			
			//comparativo iss
			nIt++
			_fCompISi(oExpl:GetPanel(aPanels[nIt]))                                        	//Compara ISS total  x XML x Entrada (por item)
			
			//comparativo ir
			nIt++
			_fCompIRi(oExpl:GetPanel(aPanels[nIt]))                                        	//Compara IR total  x XML x Entrada (por item) 
			
			//comparativo csll
			nIt++
			_fCompCSi(oExpl:GetPanel(aPanels[nIt]))                                        	//Compara CSLL total  x XML x Entrada (por item)
		
		oExpl:EndTree() //Fecha Sub-Árvore		
	    
	oExpl:EndTree() //Fecha árvore total    //aqui o fechamento geral da árvore
                                            
	//Exibe a MsExplorer
	oExpl:Activate(.T.)
	Return
	
	
///NOVO
//1o. PAINEL
//***************************************************************
Static Function _fGera01(oPanel, aInfo)
//***************************************************************
	
	Local nLiIni:= 0
	Local nCo1  := 0	
	Local nCo2  := 0
	Local nCo3  := 0
	Local nCo4  := 0 
	Local nCo5  := 0    
	Local nCo6  := 0
	Local nCo7  := 0
	Local nCo8  := 0
	
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
       
   	@nLiIni,50 SAY "Data Analytics GestãoXML - HF Consultoria"	PIXEL SIZE 350,50 FONT oBold COLOR CLR_MAGENTA OF oPanel 
    
    nLiIni := nLiIni+20				//40		
	
    
    nLiIni := nLiIni +20 			//60   		
 	oNF   := TGet():New( nLiIni, nCo1,bSetGet(cNF) ,oPanel,050,010,'@X'  ,{||  },CLR_BLUE,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.   ,,cNF ,,,,,,,"Numero NF",1 )
	oSerie:= TGet():New( nLiIni, nCo2,bSetGet(cSerie),oPanel,050,010,'@X',{||  },CLR_BLUE,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.   ,,cSerie,,,,,,,"Série",1 )
	
	oFornec  := TGet():New( nLiIni, nCo3,bSetGet(cFornec) ,oPanel,050,010,'@X',{||  },CLR_BLUE,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.   ,"SA2",cFornec ,,,,,,,"Fornecedor",1 )	
	oLoj     := TGet():New( nLiIni, nCo4,bSetGet(cLoj)    ,oPanel,050,010,'@X',{||  },CLR_BLUE,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.   ,     ,cLoj    ,,,,,,,"Loja",1 )		
	
	oFilDe   := TGet():New( nLiIni, nCo5 ,{|u| if(PCount()>0,cFili:=u,cFili)},oPanel,050, 010,Nil,{||  },0,,,.F.,,.T.,,.F.,{|| .F.},.F.,.F.,,.F.,.F.,"",cFili  ,,,,,,,"Filial",1 )
		
	oDescUser := TGet():New( nLiIni, nCo8+30,{|u| if(PCount()>0,cDescUser:=u,cDescUser)},oPanel,180, 010,Nil,{||  },0,,,.F.,,.T.,,.F.,{|| .F.},.F.,.F.,,.F.,.F.,"",cDescUser  ,,,,,,,"Usuário",1 )


Return Nil


//------------------------------------------------------------------//
//PAINEL MOSTRA ITENS XML / ITENS NF
//capta dados do XML e da NF para gerar grids de cabeçalho e itens 
//------------------------------------------------------------------//
Static Function _fGeraD( oPanel )
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
	Local _oPanelC 
	Local _oPanelT
	Local _oPanelIT

	Local _oPanN
	Local _oPanCN 
	Local _oPanTN
	Local _oPanITN
		
	Local lLowered  := .F.
	Local lRaised   := .T. //.T. mostra borda do painel  
	Local lCentered := .T. //.T. mostra o texto do objeto no centro painel
	
	Private aObjects:= {}								
	Private aSize   := MsAdvSize(.T.)						
	Private aInfo   := {}								
	Private aPos    := {}								
		
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
      
    aInfo := { aSize[1], aSize[2], aSize[3], aSize[4], 3, 3 }
    aPos  := MsObjSize( aInfo, aObjects ) 
    
    lLowered  := .F.
	lRaised   := .T. //.T. mostra borda do painel  
	lCentered := .F. //.T. mostra o texto do objeto no centro painel
    
	//---------------------------------------------------------//
	//painel a parte, para inserção do botão "exporta excel" :	
	//---------------------------------------------------------//
	nLiIni := aPos[1][2]  	//3
	nCoIni := aPos[1][2]    //3
	
	//---------------------//
	//XML 
	//---------------------//
	//só título      
	_oPanelC:= TPanel():New(nLiIni,nCoIni, "Cabeçalho XML", oPanel,oBold,lCentered, ,CLR_HBLUE, , 0,20,lLowered,lRaised)
    _oPanelC:Align := CONTROL_ALIGN_TOP
    
    nLiIni := _oPanelC:NBOTTOM + 50
    
    //dados cabeçalho
	_oPanel:= TPanel():New(nLiIni,nCoIni,"", oPanel, , lCentered, , , , 0,45,lLowered,lRaised)  //50 é a largura
    _oPanel:Align := CONTROL_ALIGN_TOP
    	    
	//monta acols e massa de dados do cabeçalho 
	aHeader11 := {}  //zera antes de gerar
	noBrw11   := 0       
	_fHeaderD(@aHeader11,@noBrw11,xZBZ)		//monta array das colunas
	
	aCols11 := {}
	oGetDados11:= MsNewGetDados():New(nLiIni,nCo1,nLiFim,nCo2,0,{|| },"AllwaysTrue","",aAltera,,9999,"AllwaysTrue","","AllwaysTrue",_oPanel,aHeader11,aCols11)    
	_fColBrwXM(oGetDados11, aCols11, noBrw11)		//cria massa de dados para a getdados
	oGetDados11:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
    
    nLiIni := _oPanel:NBOTTOM + 10
    
    //só titulo
    _oPanelT:= TPanel():New(nLiIni,nCoIni,"Itens XML", oPanel,oBold,lCentered, ,CLR_HBLUE , , 0,20,lLowered,lRaised)
    _oPanelT:Align := CONTROL_ALIGN_TOP
            
	//dados itens
	_oPanelIT:= TPanel():New(nLiIni,nCoIni,"", oPanel, ,lCentered , , , , 0,80,lLowered,lRaised)
	_oPanelIT:Align := CONTROL_ALIGN_TOP 
    
	//monta acols e massa de dados dos itens
	aHeader12 := {}  //zera antes de gerar
	noBrw12   := 0    
	_fHeaderD(@aHeader12,@noBrw12,xZBT)		//monta array das colunas
	
	aCols12 := {}
	oGetDados12:= MsNewGetDados():New(nLiIni,nCo1,nLiFim,nCo2,0,{|| },"AllwaysTrue","",aAltera,,9999,"AllwaysTrue","","AllwaysTrue",_oPanelIT,aHeader12,aCols12)
	_fColBrwit(oGetDados12, aCols12 , noBrw12)		//cria massa de dados para a getdados
	oGetDados12:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	//--------------------//	
	//NOTA FISCAL
	//--------------------//
	//só título
	_oPanN:= TPanel():New(nLiIni,nCoIni, "Cabeçalho NF", oPanel,oBold,lCentered, ,CLR_GREEN, , 0,20,lLowered,lRaised)
    _oPanN:Align := CONTROL_ALIGN_TOP
    
    nLiIni := _oPanN:NBOTTOM + 50
    
    //dados cabeçalho
	_oPanCN:= TPanel():New(nLiIni,nCoIni,"", oPanel, , lCentered, , , , 0,45,lLowered,lRaised)  //50 é a largura
    _oPanCN:Align := CONTROL_ALIGN_TOP
    
    aHeaderf1 := {}
    noBrwf1   := 0   
	_fHeaderD(@aHeaderf1,@noBrwf1,"SF1")		//monta array das colunas
	
	aColsf1 := {}
	oGetDadosf1:= MsNewGetDados():New(nLiIni,nCo1,nLiFim,nCo2,0,{|| },"AllwaysTrue","",aAltera,,9999,"AllwaysTrue","","AllwaysTrue",_oPanCN,aHeaderf1,aColsf1)    
	_fColBrwf1(oGetDadosf1, aColsf1, noBrwf1)		//cria massa de dados para a getdados
	oGetDadosf1:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	//só titulo
    _oPanTN:= TPanel():New(nLiIni,nCoIni,"Itens NF", oPanel,oBold,lCentered, ,CLR_GREEN, , 0,20,lLowered,lRaised)
    _oPanTN:Align := CONTROL_ALIGN_TOP
            
	//dados itens
	_oPanITN:= TPanel():New(nLiIni,nCoIni,"", oPanel, ,lCentered , , , , 0,80,lLowered,lRaised)
	_oPanITN:Align := CONTROL_ALIGN_TOP 
    
	//monta acols e massa de dados dos itens
	aHeaderd1 := {}
	noBrwd1   := 0	
	_fHeaderD(@aHeaderd1,@noBrwd1,"SD1")		//monta array das colunas
	
	aColsd1 := {}
	oGetDadosd1:= MsNewGetDados():New(nLiIni,nCo1,nLiFim,nCo2,0,{|| },"AllwaysTrue","",aAltera,,9999,"AllwaysTrue","","AllwaysTrue",_oPanITN,aHeaderd1,aColsd1)
	_fColBrwd1(oGetDadosd1, aColsd1, noBrwd1)		//cria massa de dados para a getdados
	oGetDadosd1:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

Return

//-----------------------------------------------------//
//PAINEL DOS TOTAIS para comparação: XML x NF 
//-----------------------------------------------------//
Static Function _fCompT( oPanel )
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
	
	Local _oPanel
	Local _oPanelC 
	//Local _oPanelT
	//Local _oPanelIT

	Local _oPanN
	Local _oPanCN 
	Local _oPanTN
	Local _oPanIT1
	Local _oPanIT2
	
	Local cMsgDiv1:= ""
	Local cMsgDiv2:= ""
	Local xCor1   
	Local xCor2
	
	Local lLowered  := .F.
	Local lRaised   := .F. //.T. mostra borda do painel  
	Local lCentered := .F. //.T. mostra o texto do objeto no centro painel
	
	Local nDiv1     := 0
	Local nDiv2     := 0
		
	Private aObjects:= {}								
	Private aSize   := MsAdvSize(.T.)					
	Private aInfo   := {}								
	Private aPos    := {}										
		
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
       
    aInfo := { aSize[1], aSize[2], aSize[3], aSize[4], 3, 3 }
    aPos  := MsObjSize( aInfo, aObjects ) 
    
    lLowered  := .F.
	lRaised   := .T. //.T. mostra borda do painel  
	lCentered := .F. //.T. mostra o texto do objeto no centro painel
    
	//---------------------------------------------------------//
	//painel a parte, para inserção do botão "exporta excel" :	
	//---------------------------------------------------------//
	nLiIni := aPos[1][2]  	//3
	nCoIni := aPos[1][2]    //3
		
	//---------------------//
	//XML 
	//---------------------//
	//só título
	_oPanelC:= TPanel():New(nLiIni,nCoIni, "Totais XML", oPanel,oBold,lCentered, ,CLR_HBLUE, , 0,20,lLowered,lRaised)
    _oPanelC:Align := CONTROL_ALIGN_TOP
    
    nLiIni := _oPanelC:NBOTTOM + 50
    
    //dados cabeçalho
	_oPanel:= TPanel():New(nLiIni,nCoIni,"", oPanel, , lCentered, , , , 0,45,lLowered,lRaised)  //50 é a largura
    _oPanel:Align := CONTROL_ALIGN_TOP
    	    
	//monta acols e massa de dados do cabeçalho 
	noBrw11   := 0
	aHeader11 := {}       
	_fHeaderC(@aHeader11,@noBrw11,xZBZ)		//monta array das colunas
	
	aCols11 := {}	
	oGetDados11:= MsNewGetDados():New(nLiIni,nCo1,nLiFim,nCo2,0,{|| },"AllwaysTrue","",aAltera,,9999,"AllwaysTrue","","AllwaysTrue",_oPanel,aHeader11,aCols11)    
	_fColBrwXM(oGetDados11, aCols11, noBrw11)		//cria massa de dados para a getdados 
	//aCols11[1,1] := Round(aCols11[1,1],2) 
	//aCols11[1,2] := Round(aCols11[1,2],2)
	oGetDados11:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
    
	//--------------------//	
	//NOTA FISCAL
	//--------------------//
	//só título
	_oPanN:= TPanel():New(nLiIni,nCoIni, "Totais NF", oPanel,oBold,lCentered, ,CLR_GREEN, , 0,20,lLowered,lRaised)
    _oPanN:Align := CONTROL_ALIGN_TOP
    
    nLiIni := _oPanN:NBOTTOM + 50
    
    //dados cabeçalho
	_oPanCN:= TPanel():New(nLiIni,nCoIni,"", oPanel, , lCentered, , , , 0,45,lLowered,lRaised)  //50 é a largura
    _oPanCN:Align := CONTROL_ALIGN_TOP
    
    aHeaderf1 := {}
    noBrwf1   := 0   
	_fHeaderC(@aHeaderf1,@noBrwf1,"SF1")		//monta array das colunas
	
	aColsf1 := {}
	oGetDadosf1:= MsNewGetDados():New(nLiIni,nCo1,nLiFim,nCo2,0,{|| },"AllwaysTrue","",aAltera,,9999,"AllwaysTrue","","AllwaysTrue",_oPanCN,aHeaderf1,aColsf1)    
	_fColBrwf1(oGetDadosf1, aColsf1, noBrwf1)		//cria massa de dados para a getdados
	oGetDadosf1:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	nLiIni := _oPanCN:NBOTTOM + 20
	
	If aCols11[1,1] <> aColsf1[1,1]     	
    	nDiv1     := Iif(aCols11[1,1] > aColsf1[1,1], aCols11[1,1] - aColsf1[1,1], aColsf1[1,1] - aCols11[1,1])
    	cMsgDiv1 += "TOTAIS BRUTOS:"+ CRLF + "DIVERGÊNCIA ENCONTRADA ==> R$" + Alltrim(Str(nDiv1))
    	xCor1    := CLR_HRED 
    Else
    	//@nLiIni+20,nCoIni SAY "Divergência Inexistente"			PIXEL SIZE 150,25 OF _oPanTN 
    	cMsgDiv1 += "TOTAIS BRUTOS: SEM DIVERGÊNCIA"  
    	xCor1    := CLR_HBLUE
    Endif 
    
    If aCols11[1,2] <> aColsf1[1,2]     	
    	nDiv2     := Iif(aCols11[1,2] > aColsf1[1,2], aCols11[1,2] - aColsf1[1,2], aColsf1[1,2] - aCols11[1,2])
    	cMsgDiv2 += "TOTAIS LÍQUIDOS:"+ CRLF + "DIVERGÊNCIA ENCONTRADA ==> R$"  + Alltrim(Str(nDiv2))
    	xCor2    := CLR_HRED  
    Else
    	//@nLiIni+40,nCoIni SAY "Divergência Inexistente"				PIXEL SIZE 150,25 OF _oPanTN
    	cMsgDiv2 := "TOTAIS LÍQUIDOS:"+ CRLF + "SEM DIVERGÊNCIA"  
    	xCor2    := CLR_HBLUE 
    Endif
    
    /*
	Local lLowered  := .F.
	Local lRaised   := .F. //.T. mostra borda do painel  
	Local lCentered := .F. //.T. mostra o texto do objeto no centro painel
	*/
    lLowered  := .T.
    lRaised   := .F.
    lCentered := .F.
    
	//só titulo
	_oPanTN:= TPanel():New(nLiIni,nCoIni,"Conclusão:", oPanel,oBold,lCentered, ,CLR_MAGENTA, , 0,20,lLowered,lRaised)         
    _oPanTN:Align := CONTROL_ALIGN_TOP    
    
    lLowered  := .T.
    lRaised   := .T.
    lCentered := .F.
    
    nLiIni := _oPanTN:NBOTTOM + 20
    _oPanIT1:= TPanel():New(nLiIni,nCoIni,cMsgDiv1, oPanel,oBold1,lCentered , ,xCor1, , 0,20,lLowered,lRaised)
	_oPanIT1:Align := CONTROL_ALIGN_TOP 
	
	nLiIni := _oPanIT1:NBOTTOM + 20
    _oPanIT2:= TPanel():New(nLiIni,nCoIni,cMsgDiv2, oPanel,oBold1,lCentered , ,xCor2, , 0,20,lLowered,lRaised)
	_oPanIT2:Align := CONTROL_ALIGN_TOP    		
    
   
Return

//------------------------------------------------------------------//
//PAINEL DAS QUANTIDADES dos ITENS - comparar XML x NF
//------------------------------------------------------------------//
Static Function _fCompQ( oPanel )
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

	//Local _oPanel
	//Local _oPanelC 
	Local _oPanelT
	Local _oPanelIT

	Local _oPanN
	//Local _oPanCN 
	Local _oPanTN
	Local _oPanITN
	
	Local _oPnConclu
	Local _oPnMsg
	
	Local lLowered  := .F.
	Local lRaised   := .T. //.T. mostra borda do painel  
	Local lCentered := .T. //.T. mostra o texto do objeto no centro painel
	
	Local x 		:= 0 
	Local cMsgDiv1	:= ""
	Local lTemDiv   := .F.
	
	Private aObjects:= {}									
	Private aSize   := MsAdvSize(.T.)						
	Private aInfo   := {}									
	Private aPos    := {}									
		
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
      
    aInfo := { aSize[1], aSize[2], aSize[3], aSize[4], 3, 3 }
    aPos  := MsObjSize( aInfo, aObjects ) 
    
    lLowered  := .F.
	lRaised   := .T. //.T. mostra borda do painel  
	lCentered := .F. //.T. mostra o texto do objeto no centro painel
    
	
	//---------------------------------------------------------//
	//painel a parte, para inserção do botão "exporta excel" :	
	//---------------------------------------------------------//
	nLiIni := aPos[1][2]  	//3
	nCoIni := aPos[1][2]    //3
	
	//---------------------//
	//XML 
	//---------------------//	
    //só titulo
    _oPanelT:= TPanel():New(nLiIni,nCoIni,"Qtdes XML", oPanel,oBold,lCentered, ,CLR_HBLUE , , 0,20,lLowered,lRaised)
    _oPanelT:Align := CONTROL_ALIGN_TOP
            
	//dados itens
	_oPanelIT:= TPanel():New(nLiIni,nCoIni,"", oPanel, ,lCentered , , , , 0,80,lLowered,lRaised)
	_oPanelIT:Align := CONTROL_ALIGN_TOP 
    
	//monta acols e massa de dados dos itens
	aHeader12 := {}  //zera antes de gerar
	noBrw12   := 0    
	_fHeaderQ(@aHeader12,@noBrw12,xZBT)		//monta array das colunas
	
	aCols12 := {}
	oGetDados12:= MsNewGetDados():New(nLiIni,nCo1,nLiFim,nCo2,0,{|| },"AllwaysTrue","",aAltera,,9999,"AllwaysTrue","","AllwaysTrue",_oPanelIT,aHeader12,aCols12)
	_fColBrwit(oGetDados12, aCols12 , noBrw12)		//cria massa de dados para a getdados
	oGetDados12:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	nLiIni := _oPanelIT:NBOTTOM + 20
	
	//--------------------//	
	//NOTA FISCAL
	//--------------------//
	//só titulo
    _oPanTN:= TPanel():New(nLiIni,nCoIni,"Qtdes NF", oPanel,oBold,lCentered, ,CLR_GREEN, , 0,20,lLowered,lRaised)
    _oPanTN:Align := CONTROL_ALIGN_TOP
            
	//dados itens
	_oPanITN:= TPanel():New(nLiIni,nCoIni,"", oPanel, ,lCentered , , , , 0,80,lLowered,lRaised)
	_oPanITN:Align := CONTROL_ALIGN_TOP 
    
	//monta acols e massa de dados dos itens
	aHeaderd1 := {}
	noBrwd1   := 0	
	_fHeaderQ(@aHeaderd1,@noBrwd1,"SD1")		//monta array das colunas
	
	aColsd1 := {}
	oGetDadosd1:= MsNewGetDados():New(nLiIni,nCo1,nLiFim,nCo2,0,{|| },"AllwaysTrue","",aAltera,,9999,"AllwaysTrue","","AllwaysTrue",_oPanITN,aHeaderd1,aColsd1)
	_fColBrwd1(oGetDadosd1, aColsd1, noBrwd1)		//cria massa de dados para a getdados
	oGetDadosd1:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	//só título
	_oPanN:= TPanel():New(nLiIni,nCoIni, "Comparativo" + CRLF+ "                            XML                                         x                                       NF", oPanel,oBold,lCentered, ,CLR_MAGENTA, , 0,20,lLowered,lRaised) 
	//@nLiIni+5,nCoIni+30 SAY "XML                                                   NF"	PIXEL SIZE 350,30 FONT oBold COLOR CLR_MAGENTA OF _oPanN
    _oPanN:Align := CONTROL_ALIGN_TOP
    
    //verifica os tamanhos dos arrays (xml e nf)
    If Len(aCols12) <> Len(aColsd1)
    	lTemDiv := .T.
    Endif 
    
    nLiIni := _oPanN:NBOTTOM + 50
    
    //dados item xml + item nf mesclados para comparar
	_oPanCN:= TPanel():New(nLiIni,nCoIni,"", oPanel, , lCentered, , , , 0,80,lLowered,lRaised)  //50 é a largura
    _oPanCN:Align := CONTROL_ALIGN_TOP
    
    aHeaderQX := {}
    noBrwQX   := 0   
	_fHeaderQ(@aHeaderQX,@noBrwQX,"")		//monta array das colunas
	
	aColsQX := {}
	oGetDadosQX:= MsNewGetDados():New(nLiIni,nCo1,nLiFim,nCo2,0,{|| },"AllwaysTrue","",aAltera,,9999,"AllwaysTrue","","AllwaysTrue",_oPanCN,aHeaderQX,aColsQX)    
	//_fColBrwf1(oGetDadosf1, aColsf1)		//cria massa de dados para a getdados
	_fColBrwit(oGetDadosQX, aColsQX, noBrwQX, "ZBT","Q",lTemDiv)
	oGetDadosQX:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	xCor1    := CLR_HBLUE  
	
	lTemDiv  := .F.
	lTemRepli:= .F.    //indica se houve desmembramento ou replicação
	For x := 1 to Len(aColsQX)
	   
	    If Empty(aColsQX[x,1])
			lTemRepli := .T.
			cMsgDiv1 += "HOUVE DESMEMBRAMENTO / REPLICAÇÃO - ITEM NF: " + aColsQX[x,7]+ CRLF
  		Endif
  		  
  	Next 
	
	If !lTemRepli
		For x := 1 to Len(aColsQX)
		    If aColsQX[x,4] <> aColsQX[x,6] 		    		
		    	cMsgDiv1 += "QTDE DIVERGENTE - ITEM NF: " + aColsQX[x,7] + CRLF //TOTAIS BRUTOS:"+ CRLF + "DIVERGÊNCIA ENCONTRADA ==> R$" + Alltrim(Str(nDiv1))
		    	xCor1    := CLR_HRED 
		    	lTemDiv  := .T.		    		  	
	  		Endif  
	  	Next
  	Endif
  	
    If !lTemDiv    
    	cMsgDiv1 += "SEM DIVERGÊNCIA"  
    	xCor1    := CLR_HBLUE
    Endif
     
    lLowered  := .T.
    lRaised   := .F.
    lCentered := .F.
    
	//só titulo
	_oPnConclu:= TPanel():New(nLiIni,nCoIni,"Conclusão:", oPanel,oBold,lCentered, ,CLR_MAGENTA, , 0,20,lLowered,lRaised)         
    _oPnConclu:Align := CONTROL_ALIGN_TOP   
    
    lLowered  := .T.
    lRaised   := .T.
    lCentered := .F.
    
    nLiIni := _oPnConclu:NBOTTOM + 20
    _oPnMsg:= TPanel():New(nLiIni,nCoIni,cMsgDiv1, oPanel,oBold1,lCentered , ,xCor1, , 0,20,lLowered,lRaised)
	_oPnMsg:Align := CONTROL_ALIGN_ALLCLIENT 

    
Return 


//------------------------------------------------------------------//
//PAINEL DOS VALORES UNITÁRIOS dos ITENS - comparar XML x NF
//------------------------------------------------------------------//
Static Function _fCompV( oPanel )
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

	//Local _oPanel
	//Local _oPanelC 
	Local _oPanelT
	Local _oPanelIT

	Local _oPanN
	//Local _oPanCN 
	Local _oPanTN
	Local _oPanITN
	
	Local cMsgDiv1	:= ""
	Local _oPnConclu
	Local _oPnMsg
	Local x 		:= 0 
	Local lTemDiv   := .F.	

	
	Local lLowered  := .F.
	Local lRaised   := .T. //.T. mostra borda do painel  
	Local lCentered := .T. //.T. mostra o texto do objeto no centro painel
	
	Private aObjects:= {}									
	Private aSize   := MsAdvSize(.T.)						
	Private aInfo   := {}									
	Private aPos    := {}									
		
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
      
    aInfo := { aSize[1], aSize[2], aSize[3], aSize[4], 3, 3 }
    aPos  := MsObjSize( aInfo, aObjects ) 
    
    lLowered  := .F.
	lRaised   := .T. //.T. mostra borda do painel  
	lCentered := .F. //.T. mostra o texto do objeto no centro painel
    
	//---------------------------------------------------------//
	//painel a parte, para inserção do botão "exporta excel" :	
	//---------------------------------------------------------//
	nLiIni := aPos[1][2]  	//3
	nCoIni := aPos[1][2]    //3
	
	//---------------------//
	//XML 
	//---------------------//	
    //só titulo
    _oPanelT:= TPanel():New(nLiIni,nCoIni,"Valores Unitários XML", oPanel,oBold,lCentered, ,CLR_HBLUE , , 0,20,lLowered,lRaised)
    _oPanelT:Align := CONTROL_ALIGN_TOP
            
	//dados itens
	_oPanelIT:= TPanel():New(nLiIni,nCoIni,"", oPanel, ,lCentered , , , , 0,80,lLowered,lRaised)
	_oPanelIT:Align := CONTROL_ALIGN_TOP 
    
	//monta acols e massa de dados dos itens
	aHeader12 := {}  //zera antes de gerar
	noBrw12   := 0    
	_fHeaderV(@aHeader12,@noBrw12,xZBT)		//monta array das colunas
	
	aCols12 := {}
	oGetDados12:= MsNewGetDados():New(nLiIni,nCo1,nLiFim,nCo2,0,{|| },"AllwaysTrue","",aAltera,,9999,"AllwaysTrue","","AllwaysTrue",_oPanelIT,aHeader12,aCols12)
	_fColBrwit(oGetDados12, aCols12 , noBrw12)		//cria massa de dados para a getdados
	oGetDados12:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	//--------------------//	
	//NOTA FISCAL
	//--------------------//
	//só titulo
    _oPanTN:= TPanel():New(nLiIni,nCoIni,"Valores Unitários NF", oPanel,oBold,lCentered, ,CLR_GREEN, , 0,20,lLowered,lRaised)
    _oPanTN:Align := CONTROL_ALIGN_TOP
            
	//dados itens
	_oPanITN:= TPanel():New(nLiIni,nCoIni,"", oPanel, ,lCentered , , , , 0,80,lLowered,lRaised)
	_oPanITN:Align := CONTROL_ALIGN_TOP 
    
	//monta acols e massa de dados dos itens
	aHeaderd1 := {}
	noBrwd1   := 0	
	_fHeaderV(@aHeaderd1,@noBrwd1,"SD1")		//monta array das colunas
	
	aColsd1 := {}
	oGetDadosd1:= MsNewGetDados():New(nLiIni,nCo1,nLiFim,nCo2,0,{|| },"AllwaysTrue","",aAltera,,9999,"AllwaysTrue","","AllwaysTrue",_oPanITN,aHeaderd1,aColsd1)
	_fColBrwd1(oGetDadosd1, aColsd1, noBrwd1)		//cria massa de dados para a getdados
	oGetDadosd1:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	//só título
	//_oPanN:= TPanel():New(nLiIni,nCoIni, "Comparativo XML x NF", oPanel,oBold,lCentered, ,CLR_MAGENTA, , 0,20,lLowered,lRaised)
	_oPanN:= TPanel():New(nLiIni,nCoIni, "Comparativo" + CRLF+ "                            XML                                           x                                       NF", oPanel,oBold,lCentered, ,CLR_MAGENTA, , 0,20,lLowered,lRaised) 
    _oPanN:Align := CONTROL_ALIGN_TOP
    
    nLiIni := _oPanN:NBOTTOM + 50
    
    //verifica os tamanhos dos arrays (xml e nf) se os tamanhos forem iguais, é 1 para 1, senão, tratar como divergência
    If Len(aCols12) <> Len(aColsd1)
    	lTemDiv := .T.
    Endif 
        
    //dados item xml + item nf mesclados para comparar
	_oPanCN:= TPanel():New(nLiIni,nCoIni,"", oPanel, , lCentered, , , , 0,80,lLowered,lRaised)  //50 é a largura
    _oPanCN:Align := CONTROL_ALIGN_TOP
    
    aHeaderQX := {}
    noBrwQX   := 0   
	_fHeaderV(@aHeaderQX,@noBrwQX,"")		//monta array das colunas
	
	aColsQX := {}
	oGetDadosQX:= MsNewGetDados():New(nLiIni,nCo1,nLiFim,nCo2,0,{|| },"AllwaysTrue","",aAltera,,9999,"AllwaysTrue","","AllwaysTrue",_oPanCN,aHeaderQX,aColsQX)    
	//_fColBrwf1(oGetDadosf1, aColsf1)		//cria massa de dados para a getdados
	_fColBrwit(oGetDadosQX, aColsQX, noBrwQX, "ZBT","V",lTemDiv)
	oGetDadosQX:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	nLiIni := _oPanCN:NBOTTOM + 50
	
	xCor1    := CLR_HBLUE 
	
	lTemDiv  := .F. 
	lTemRepli:= .F.    //indica se houve desmembramento ou replicação
	For x := 1 to Len(aColsQX)
	   
	    If Empty(aColsQX[x,1])
			lTemRepli := .T.
			cMsgDiv1 += "HOUVE DESMEMBRAMENTO / REPLICAÇÃO - ITEM NF: " + aColsQX[x,7]+ CRLF
  		Endif
  		  
  	Next 
	
	If !lTemRepli
		For x := 1 to Len(aColsQX)
		    If aColsQX[x,4] <> aColsQX[x,6] 		    		
		    	cMsgDiv1 += "VLR UNITARIO DIVERGENTE - ITEM NF: " + aColsQX[x,7] + CRLF //TOTAIS BRUTOS:"+ CRLF + "DIVERGÊNCIA ENCONTRADA ==> R$" + Alltrim(Str(nDiv1))
		    	xCor1    := CLR_HRED 
		    	lTemDiv  := .T.		    		  	
	  		Endif  
	  	Next
  	Endif  
  	
    If !lTemDiv    
    	cMsgDiv1 += "SEM DIVERGÊNCIA"  
    	xCor1    := CLR_HBLUE
    Endif    
     
    lLowered  := .T.
    lRaised   := .F.
    lCentered := .F.
    
	//só titulo
	_oPnConclu:= TPanel():New(nLiIni,nCoIni,"Conclusão:", oPanel,oBold,lCentered, ,CLR_MAGENTA, , 0,20,lLowered,lRaised)         
    _oPnConclu:Align := CONTROL_ALIGN_TOP   
    
    lLowered  := .T.
    lRaised   := .T.
    lCentered := .F.
    
    nLiIni := _oPnConclu:NBOTTOM + 20
    _oPnMsg:= TPanel():New(nLiIni,nCoIni,cMsgDiv1, oPanel,oBold1,lCentered , ,xCor1, , 0,20,lLowered,lRaised)
	_oPnMsg:Align := CONTROL_ALIGN_ALLCLIENT 

Return

//------------------------------------------------------------------//
//PAINEL DOS IMPOSTOS dos ITENS - comparar ICMS - XML x NF
//------------------------------------------------------------------//
Static Function _fCompIi( oPanel )
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

	//Local _oPanel
	//Local _oPanelC 
	Local _oPanelT
	Local _oPanelIT

	Local _oPanN
	//Local _oPanCN 
	Local _oPanTN
	Local _oPanITN
	
	Local cMsgDiv1	:= ""
	Local _oPnConclu
	Local _oPnMsg
	Local x 		:= 0 
	Local lTemDiv   := .F.	

	
	Local lLowered  := .F.
	Local lRaised   := .T. //.T. mostra borda do painel  
	Local lCentered := .T. //.T. mostra o texto do objeto no centro painel
	
	Private aObjects:= {}									
	Private aSize   := MsAdvSize(.T.)						
	Private aInfo   := {}									
	Private aPos    := {}									
		
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
      
    aInfo := { aSize[1], aSize[2], aSize[3], aSize[4], 3, 3 }
    aPos  := MsObjSize( aInfo, aObjects ) 
    
    lLowered  := .F.
	lRaised   := .T. //.T. mostra borda do painel  
	lCentered := .F. //.T. mostra o texto do objeto no centro painel
    
	//---------------------------------------------------------//
	//painel a parte, para inserção do botão "exporta excel" :	
	//---------------------------------------------------------//
	nLiIni := aPos[1][2]  	//3
	nCoIni := aPos[1][2]    //3
	
	//---------------------//
	//XML 
	//---------------------//	
    //só titulo
    _oPanelT:= TPanel():New(nLiIni,nCoIni,"ICMS Por Item XML", oPanel,oBold,lCentered, ,CLR_HBLUE , , 0,20,lLowered,lRaised)
    _oPanelT:Align := CONTROL_ALIGN_TOP
            
	//dados itens
	_oPanelIT:= TPanel():New(nLiIni,nCoIni,"", oPanel, ,lCentered , , , , 0,80,lLowered,lRaised)
	_oPanelIT:Align := CONTROL_ALIGN_TOP 
    
	//monta acols e massa de dados dos itens
	aHeader12 := {}  //zera antes de gerar
	noBrw12   := 0    
	_fHeaderV(@aHeader12,@noBrw12,xZBT,"ICM")		//monta array das colunas
	
	aCols12 := {}
	oGetDados12:= MsNewGetDados():New(nLiIni,nCo1,nLiFim,nCo2,0,{|| },"AllwaysTrue","",aAltera,,9999,"AllwaysTrue","","AllwaysTrue",_oPanelIT,aHeader12,aCols12)
	_fColBrwit(oGetDados12, aCols12 , noBrw12)		//cria massa de dados para a getdados
	oGetDados12:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	//--------------------//	
	//NOTA FISCAL
	//--------------------//
	//só titulo
    _oPanTN:= TPanel():New(nLiIni,nCoIni,"ICMS Por Item NF", oPanel,oBold,lCentered, ,CLR_GREEN, , 0,20,lLowered,lRaised)
    _oPanTN:Align := CONTROL_ALIGN_TOP
            
	//dados itens
	_oPanITN:= TPanel():New(nLiIni,nCoIni,"", oPanel, ,lCentered , , , , 0,80,lLowered,lRaised)
	_oPanITN:Align := CONTROL_ALIGN_TOP 
    
	//monta acols e massa de dados dos itens
	aHeaderd1 := {}
	noBrwd1   := 0	
	_fHeaderV(@aHeaderd1,@noBrwd1,"SD1","ICM")		//monta array das colunas
	
	aColsd1 := {}
	oGetDadosd1:= MsNewGetDados():New(nLiIni,nCo1,nLiFim,nCo2,0,{|| },"AllwaysTrue","",aAltera,,9999,"AllwaysTrue","","AllwaysTrue",_oPanITN,aHeaderd1,aColsd1)
	_fColBrwd1(oGetDadosd1, aColsd1, noBrwd1)		//cria massa de dados para a getdados
	oGetDadosd1:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	//só título
	//_oPanN:= TPanel():New(nLiIni,nCoIni, "Comparativo XML x NF", oPanel,oBold,lCentered, ,CLR_MAGENTA, , 0,20,lLowered,lRaised)
	_oPanN:= TPanel():New(nLiIni,nCoIni, "Comparativo" + CRLF+ "                            XML                                         x                                       NF", oPanel,oBold,lCentered, ,CLR_MAGENTA, , 0,20,lLowered,lRaised) 
    _oPanN:Align := CONTROL_ALIGN_TOP
    
    nLiIni := _oPanN:NBOTTOM + 50
    
    //verifica os tamanhos dos arrays (xml e nf) se os tamanhos forem iguais, é 1 para 1, senão, tratar como divergência
    If Len(aCols12) <> Len(aColsd1)
    	lTemDiv := .T.
    Endif 
    
    //dados item xml + item nf mesclados para comparar
	_oPanCN:= TPanel():New(nLiIni,nCoIni,"", oPanel, , lCentered, , , , 0,80,lLowered,lRaised)  //50 é a largura
    _oPanCN:Align := CONTROL_ALIGN_TOP
    
    aHeaderQX := {}
    noBrwQX   := 0   
	_fHeaderV(@aHeaderQX,@noBrwQX,"","ICM")		//monta array das colunas
	
	aColsQX := {}
	oGetDadosQX:= MsNewGetDados():New(nLiIni,nCo1,nLiFim,nCo2,0,{|| },"AllwaysTrue","",aAltera,,9999,"AllwaysTrue","","AllwaysTrue",_oPanCN,aHeaderQX,aColsQX)    
	//_fColBrwf1(oGetDadosf1, aColsf1)		//cria massa de dados para a getdados
	_fColBrwit(oGetDadosQX, aColsQX, noBrwQX, "ZBT","ICM",lTemDiv)
	oGetDadosQX:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	nLiIni := _oPanCN:NBOTTOM + 50  
	
	xCor1    := CLR_HBLUE
	
	lTemDiv  := .F.
	lTemRepli:= .F.    //indica se houve desmembramento ou replicação
	For x := 1 to Len(aColsQX)
	   
	    If Empty(aColsQX[x,1])
			lTemRepli := .T.
			cMsgDiv1 += "HOUVE DESMEMBRAMENTO / REPLICAÇÃO - ITEM NF: " + aColsQX[x,7]+ CRLF
  		Endif
  		  
  	Next 
	
	If !lTemRepli
		For x := 1 to Len(aColsQX)
		    If aColsQX[x,4] <> aColsQX[x,6] 		    		
		    	cMsgDiv1 += "ICMS DIVERGENTE - ITEM NF: " + aColsQX[x,7] + CRLF //TOTAIS BRUTOS:"+ CRLF + "DIVERGÊNCIA ENCONTRADA ==> R$" + Alltrim(Str(nDiv1))
		    	xCor1    := CLR_HRED 
		    	lTemDiv  := .T.		    		  	
	  		Endif  
	  	Next
  	Endif
  	
    If !lTemDiv    
    	cMsgDiv1 += "SEM DIVERGÊNCIA"  
    	xCor1    := CLR_HBLUE
    Endif    
     
    lLowered  := .T.
    lRaised   := .F.
    lCentered := .F.
    
	//só titulo
	_oPnConclu:= TPanel():New(nLiIni,nCoIni,"Conclusão:", oPanel,oBold,lCentered, ,CLR_MAGENTA, , 0,20,lLowered,lRaised)         
    _oPnConclu:Align := CONTROL_ALIGN_TOP   
    
    lLowered  := .T.
    lRaised   := .T.
    lCentered := .F.
    
    nLiIni := _oPnConclu:NBOTTOM + 20
    _oPnMsg:= TPanel():New(nLiIni,nCoIni,cMsgDiv1, oPanel,oBold1,lCentered , ,xCor1, , 0,20,lLowered,lRaised)
	_oPnMsg:Align := CONTROL_ALIGN_ALLCLIENT 
	

Return 


//------------------------------------------------------------------//
//PAINEL DOS IMPOSTOS dos ITENS - comparar ICM ST XML x NF
//------------------------------------------------------------------//
/*
Static Function _fCompI2i( oPanel )
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

	//Local _oPanel
	//Local _oPanelC 
	Local _oPanelT
	Local _oPanelIT

	Local _oPanN
	//Local _oPanCN 
	Local _oPanTN
	Local _oPanITN
	
	Local cMsgDiv1	:= ""
	Local _oPnConclu
	Local _oPnMsg
	Local x 		:= 0 
	Local lTemDiv   := .F.	
	
	Local lLowered  := .F.
	Local lRaised   := .T. //.T. mostra borda do painel  
	Local lCentered := .T. //.T. mostra o texto do objeto no centro painel
	
	Private aObjects:= {}									
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
      
    aInfo := { aSize[1], aSize[2], aSize[3], aSize[4], 3, 3 }
    aPos  := MsObjSize( aInfo, aObjects ) 
    
    lLowered  := .F.
	lRaised   := .T. //.T. mostra borda do painel  
	lCentered := .F. //.T. mostra o texto do objeto no centro painel

	//---------------------------------------------------------//
	//painel a parte, para inserção do botão "exporta excel" :	
	//---------------------------------------------------------//
	nLiIni := aPos[1][2]  	//3
	nCoIni := aPos[1][2]    //3
	
	//---------------------//
	//XML 
	//---------------------//	
    //só titulo
    _oPanelT:= TPanel():New(nLiIni,nCoIni,"ICM ST Por Item XML", oPanel,oBold,lCentered, ,CLR_HBLUE , , 0,20,lLowered,lRaised)
    _oPanelT:Align := CONTROL_ALIGN_TOP
            
	//dados itens
	_oPanelIT:= TPanel():New(nLiIni,nCoIni,"", oPanel, ,lCentered , , , , 0,80,lLowered,lRaised)
	_oPanelIT:Align := CONTROL_ALIGN_TOP 
    
	//monta acols e massa de dados dos itens
	aHeader12 := {}  //zera antes de gerar
	noBrw12   := 0    
	_fHeaderV(@aHeader12,@noBrw12,xZBT,"ST")		//monta array das colunas
	
	aCols12 := {}
	oGetDados12:= MsNewGetDados():New(nLiIni,nCo1,nLiFim,nCo2,0,{|| },"AllwaysTrue","",aAltera,,9999,"AllwaysTrue","","AllwaysTrue",_oPanelIT,aHeader12,aCols12)
	_fColBrwit(oGetDados12, aCols12 , noBrw12)		//cria massa de dados para a getdados
	oGetDados12:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	//--------------------//	
	//NOTA FISCAL
	//--------------------//
	//só titulo
    _oPanTN:= TPanel():New(nLiIni,nCoIni,"ICM ST Por Item NF", oPanel,oBold,lCentered, ,CLR_GREEN, , 0,20,lLowered,lRaised)
    _oPanTN:Align := CONTROL_ALIGN_TOP
            
	//dados itens
	_oPanITN:= TPanel():New(nLiIni,nCoIni,"", oPanel, ,lCentered , , , , 0,80,lLowered,lRaised)
	_oPanITN:Align := CONTROL_ALIGN_TOP 
    
	//monta acols e massa de dados dos itens
	aHeaderd1 := {}
	noBrwd1   := 0	
	_fHeaderV(@aHeaderd1,@noBrwd1,"SD1","ST")		//monta array das colunas
	
	aColsd1 := {}
	oGetDadosd1:= MsNewGetDados():New(nLiIni,nCo1,nLiFim,nCo2,0,{|| },"AllwaysTrue","",aAltera,,9999,"AllwaysTrue","","AllwaysTrue",_oPanITN,aHeaderd1,aColsd1)
	_fColBrwd1(oGetDadosd1, aColsd1, noBrwd1)		//cria massa de dados para a getdados
	oGetDadosd1:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	//só título
	_oPanN:= TPanel():New(nLiIni,nCoIni, "Comparativo XML x NF", oPanel,oBold,lCentered, ,CLR_MAGENTA, , 0,20,lLowered,lRaised)
    _oPanN:Align := CONTROL_ALIGN_TOP
    
    nLiIni := _oPanN:NBOTTOM + 50
    
    //dados item xml + item nf mesclados para comparar
	_oPanCN:= TPanel():New(nLiIni,nCoIni,"", oPanel, , lCentered, , , , 0,80,lLowered,lRaised)  //50 é a largura
    _oPanCN:Align := CONTROL_ALIGN_TOP
    
    aHeaderQX := {}
    noBrwQX   := 0   
	_fHeaderV(@aHeaderQX,@noBrwQX,"","ST")		//monta array das colunas
	
	aColsQX := {}
	oGetDadosQX:= MsNewGetDados():New(nLiIni,nCo1,nLiFim,nCo2,0,{|| },"AllwaysTrue","",aAltera,,9999,"AllwaysTrue","","AllwaysTrue",_oPanCN,aHeaderQX,aColsQX)    
	//_fColBrwf1(oGetDadosf1, aColsf1)		//cria massa de dados para a getdados
	_fColBrwit(oGetDadosQX, aColsQX, noBrwQX, "ZBT","ST")
	oGetDadosQX:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	nLiIni := _oPanCN:NBOTTOM + 50 
	
	For x := 1 to Len(aColsQX)
	
		If aColsQX[x,4] <> aColsQX[x,5]     	
    		//nDiv1     := Iif(aCols11[1,1] > aColsf1[1,1], aCols11[1,1] - aColsf1[1,1], aColsf1[1,1] - aCols11[1,1])
    		cMsgDiv1 += "ICM ST DIVERGENTE - ITEM: " + aColsQX[x,1] + CRLF //TOTAIS BRUTOS:"+ CRLF + "DIVERGÊNCIA ENCONTRADA ==> R$" + Alltrim(Str(nDiv1))
    		xCor1    := CLR_HRED 
    		lTemDiv  := .T. 
  		Endif 
  	Next 
  	
    If !lTemDiv    
    	cMsgDiv1 += "SEM DIVERGÊNCIA"  
    	xCor1    := CLR_HBLUE
    Endif    
     
    lLowered  := .T.
    lRaised   := .F.
    lCentered := .F.
    
	//só titulo
	_oPnConclu:= TPanel():New(nLiIni,nCoIni,"Conclusão:", oPanel,oBold,lCentered, ,CLR_MAGENTA, , 0,20,lLowered,lRaised)         
    _oPnConclu:Align := CONTROL_ALIGN_TOP   
    
    lLowered  := .T.
    lRaised   := .T.
    lCentered := .F.
    
    nLiIni := _oPnConclu:NBOTTOM + 20
    _oPnMsg:= TPanel():New(nLiIni,nCoIni,cMsgDiv1, oPanel,oBold1,lCentered , ,xCor1, , 0,20,lLowered,lRaised)
	_oPnMsg:Align := CONTROL_ALIGN_ALLCLIENT 
	

Return 
*/

//------------------------------------------------------------------//
//PAINEL DOS IMPOSTOS dos ITENS - comparar IPI - XML x NF
//------------------------------------------------------------------//
Static Function _fCompIPi( oPanel )
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

	//Local _oPanel
	//Local _oPanelC 
	Local _oPanelT
	Local _oPanelIT

	Local _oPanN
	//Local _oPanCN 
	Local _oPanTN
	Local _oPanITN
	
	Local cMsgDiv1	:= ""
	Local _oPnConclu
	Local _oPnMsg
	Local x 		:= 0 
	Local lTemDiv   := .F.	

	
	Local lLowered  := .F.
	Local lRaised   := .T. //.T. mostra borda do painel  
	Local lCentered := .T. //.T. mostra o texto do objeto no centro painel
	
	Private aObjects:= {}									
	Private aSize   := MsAdvSize(.T.)						
	Private aInfo   := {}									
	Private aPos    := {}									
		
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
      
    aInfo := { aSize[1], aSize[2], aSize[3], aSize[4], 3, 3 }
    aPos  := MsObjSize( aInfo, aObjects ) 
    
    lLowered  := .F.
	lRaised   := .T. //.T. mostra borda do painel  
	lCentered := .F. //.T. mostra o texto do objeto no centro painel
    
	//---------------------------------------------------------//
	//painel a parte, para inserção do botão "exporta excel" :	
	//---------------------------------------------------------//
	nLiIni := aPos[1][2]  	//3
	nCoIni := aPos[1][2]    //3
	
	//---------------------//
	//XML 
	//---------------------//	
    //só titulo
    _oPanelT:= TPanel():New(nLiIni,nCoIni,"IPI Por Item XML", oPanel,oBold,lCentered, ,CLR_HBLUE , , 0,20,lLowered,lRaised)
    _oPanelT:Align := CONTROL_ALIGN_TOP
            
	//dados itens
	_oPanelIT:= TPanel():New(nLiIni,nCoIni,"", oPanel, ,lCentered , , , , 0,80,lLowered,lRaised)
	_oPanelIT:Align := CONTROL_ALIGN_TOP 
    
	//monta acols e massa de dados dos itens
	aHeader12 := {}  //zera antes de gerar
	noBrw12   := 0    
	_fHeaderV(@aHeader12,@noBrw12,xZBT,"IPI")		//monta array das colunas
	
	aCols12 := {}
	oGetDados12:= MsNewGetDados():New(nLiIni,nCo1,nLiFim,nCo2,0,{|| },"AllwaysTrue","",aAltera,,9999,"AllwaysTrue","","AllwaysTrue",_oPanelIT,aHeader12,aCols12)
	_fColBrwit(oGetDados12, aCols12 , noBrw12)		//cria massa de dados para a getdados
	oGetDados12:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	//--------------------//	
	//NOTA FISCAL
	//--------------------//
	//só titulo
    _oPanTN:= TPanel():New(nLiIni,nCoIni,"IPI Por Item NF", oPanel,oBold,lCentered, ,CLR_GREEN, , 0,20,lLowered,lRaised)
    _oPanTN:Align := CONTROL_ALIGN_TOP
            
	//dados itens
	_oPanITN:= TPanel():New(nLiIni,nCoIni,"", oPanel, ,lCentered , , , , 0,80,lLowered,lRaised)
	_oPanITN:Align := CONTROL_ALIGN_TOP 
    
	//monta acols e massa de dados dos itens
	aHeaderd1 := {}
	noBrwd1   := 0	
	_fHeaderV(@aHeaderd1,@noBrwd1,"SD1","IPI")		//monta array das colunas
	
	aColsd1 := {}
	oGetDadosd1:= MsNewGetDados():New(nLiIni,nCo1,nLiFim,nCo2,0,{|| },"AllwaysTrue","",aAltera,,9999,"AllwaysTrue","","AllwaysTrue",_oPanITN,aHeaderd1,aColsd1)
	_fColBrwd1(oGetDadosd1, aColsd1, noBrwd1)		//cria massa de dados para a getdados
	oGetDadosd1:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	//só título
	//_oPanN:= TPanel():New(nLiIni,nCoIni, "Comparativo XML x NF", oPanel,oBold,lCentered, ,CLR_MAGENTA, , 0,20,lLowered,lRaised)
	_oPanN:= TPanel():New(nLiIni,nCoIni, "Comparativo" + CRLF+ "                            XML                                         x                                       NF", oPanel,oBold,lCentered, ,CLR_MAGENTA, , 0,20,lLowered,lRaised) 
    _oPanN:Align := CONTROL_ALIGN_TOP
    
    nLiIni := _oPanN:NBOTTOM + 50 
    
    //verifica os tamanhos dos arrays (xml e nf) se os tamanhos forem iguais, é 1 para 1, senão, tratar como divergência
    If Len(aCols12) <> Len(aColsd1)
    	lTemDiv := .T.
    Endif 
    
    //dados item xml + item nf mesclados para comparar
	_oPanCN:= TPanel():New(nLiIni,nCoIni,"", oPanel, , lCentered, , , , 0,80,lLowered,lRaised)  //50 é a largura
    _oPanCN:Align := CONTROL_ALIGN_TOP
    
    aHeaderQX := {}
    noBrwQX   := 0   
	_fHeaderV(@aHeaderQX,@noBrwQX,"","IPI")		//monta array das colunas
	
	aColsQX := {}
	oGetDadosQX:= MsNewGetDados():New(nLiIni,nCo1,nLiFim,nCo2,0,{|| },"AllwaysTrue","",aAltera,,9999,"AllwaysTrue","","AllwaysTrue",_oPanCN,aHeaderQX,aColsQX)    
	//_fColBrwf1(oGetDadosf1, aColsf1)		//cria massa de dados para a getdados
	_fColBrwit(oGetDadosQX, aColsQX, noBrwQX, "ZBT","IPI",lTemDiv)
	oGetDadosQX:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	nLiIni := _oPanCN:NBOTTOM + 50
	
	xCor1    := CLR_HBLUE
	
	lTemDiv  := .F.
	lTemRepli:= .F.    //indica se houve desmembramento ou replicação
	
	For x := 1 to Len(aColsQX)
	   
	    If Empty(aColsQX[x,1])
			lTemRepli := .T.
			cMsgDiv1 += "HOUVE DESMEMBRAMENTO / REPLICAÇÃO - ITEM NF: " + aColsQX[x,7]+ CRLF
  		Endif
  		  
  	Next 
	
	If !lTemRepli
		For x := 1 to Len(aColsQX)
		    If aColsQX[x,4] <> aColsQX[x,6] 		    		
		    	cMsgDiv1 += "IPI DIVERGENTE - ITEM NF: " + aColsQX[x,7] + CRLF //TOTAIS BRUTOS:"+ CRLF + "DIVERGÊNCIA ENCONTRADA ==> R$" + Alltrim(Str(nDiv1))
		    	xCor1    := CLR_HRED 
		    	lTemDiv  := .T.		    		  	
	  		Endif  
	  	Next
  	Endif
  	
    If !lTemDiv    
    	cMsgDiv1 += "SEM DIVERGÊNCIA"  
    	xCor1    := CLR_HBLUE
    Endif    
     
    lLowered  := .T.
    lRaised   := .F.
    lCentered := .F.
    
	//só titulo
	_oPnConclu:= TPanel():New(nLiIni,nCoIni,"Conclusão:", oPanel,oBold,lCentered, ,CLR_MAGENTA, , 0,20,lLowered,lRaised)         
    _oPnConclu:Align := CONTROL_ALIGN_TOP   
    
    lLowered  := .T.
    lRaised   := .T.
    lCentered := .F.
    
    nLiIni := _oPnConclu:NBOTTOM + 20
    _oPnMsg:= TPanel():New(nLiIni,nCoIni,cMsgDiv1, oPanel,oBold1,lCentered , ,xCor1, , 0,20,lLowered,lRaised)
	_oPnMsg:Align := CONTROL_ALIGN_ALLCLIENT 
    
	

Return 


//------------------------------------------------------------------//
//PAINEL DOS IMPOSTOS dos ITENS - comparar PIS - XML x NF
//------------------------------------------------------------------//
Static Function _fCompPIi( oPanel )
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

	//Local _oPanel
	//Local _oPanelC 
	Local _oPanelT
	Local _oPanelIT

	Local _oPanN
	//Local _oPanCN 
	Local _oPanTN
	Local _oPanITN
	
	Local cMsgDiv1	:= ""
	Local _oPnConclu
	Local _oPnMsg
	Local x 		:= 0 
	Local lTemDiv   := .F.	

	
	Local lLowered  := .F.
	Local lRaised   := .T. //.T. mostra borda do painel  
	Local lCentered := .T. //.T. mostra o texto do objeto no centro painel
	
	Private aObjects:= {}									
	Private aSize   := MsAdvSize(.T.)						
	Private aInfo   := {}									
	Private aPos    := {}									
		
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
      
    aInfo := { aSize[1], aSize[2], aSize[3], aSize[4], 3, 3 }
    aPos  := MsObjSize( aInfo, aObjects ) 
    
    lLowered  := .F.
	lRaised   := .T. //.T. mostra borda do painel  
	lCentered := .F. //.T. mostra o texto do objeto no centro painel
    
	//---------------------------------------------------------//
	//painel a parte, para inserção do botão "exporta excel" :	
	//---------------------------------------------------------//
	nLiIni := aPos[1][2]  	//3
	nCoIni := aPos[1][2]    //3
	
	//---------------------//
	//XML 
	//---------------------//	
    //só titulo
    _oPanelT:= TPanel():New(nLiIni,nCoIni,"PIS Por Item XML", oPanel,oBold,lCentered, ,CLR_HBLUE , , 0,20,lLowered,lRaised)
    _oPanelT:Align := CONTROL_ALIGN_TOP
            
	//dados itens
	_oPanelIT:= TPanel():New(nLiIni,nCoIni,"", oPanel, ,lCentered , , , , 0,80,lLowered,lRaised)
	_oPanelIT:Align := CONTROL_ALIGN_TOP 
    
	//monta acols e massa de dados dos itens
	aHeader12 := {}  //zera antes de gerar
	noBrw12   := 0    
	_fHeaderV(@aHeader12,@noBrw12,xZBT,"PIS")		//monta array das colunas
	
	aCols12 := {}
	oGetDados12:= MsNewGetDados():New(nLiIni,nCo1,nLiFim,nCo2,0,{|| },"AllwaysTrue","",aAltera,,9999,"AllwaysTrue","","AllwaysTrue",_oPanelIT,aHeader12,aCols12)
	_fColBrwit(oGetDados12, aCols12 , noBrw12)		//cria massa de dados para a getdados
	oGetDados12:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	//--------------------//	
	//NOTA FISCAL
	//--------------------//
	//só titulo
    _oPanTN:= TPanel():New(nLiIni,nCoIni,"PIS Por Item NF", oPanel,oBold,lCentered, ,CLR_GREEN, , 0,20,lLowered,lRaised)
    _oPanTN:Align := CONTROL_ALIGN_TOP
            
	//dados itens
	_oPanITN:= TPanel():New(nLiIni,nCoIni,"", oPanel, ,lCentered , , , , 0,80,lLowered,lRaised)
	_oPanITN:Align := CONTROL_ALIGN_TOP 
    
	//monta acols e massa de dados dos itens
	aHeaderd1 := {}
	noBrwd1   := 0	
	_fHeaderV(@aHeaderd1,@noBrwd1,"SD1","PIS")		//monta array das colunas
	
	aColsd1 := {}
	oGetDadosd1:= MsNewGetDados():New(nLiIni,nCo1,nLiFim,nCo2,0,{|| },"AllwaysTrue","",aAltera,,9999,"AllwaysTrue","","AllwaysTrue",_oPanITN,aHeaderd1,aColsd1)
	_fColBrwd1(oGetDadosd1, aColsd1, noBrwd1)		//cria massa de dados para a getdados
	oGetDadosd1:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	//só título
	//_oPanN:= TPanel():New(nLiIni,nCoIni, "Comparativo XML x NF", oPanel,oBold,lCentered, ,CLR_MAGENTA, , 0,20,lLowered,lRaised) 
	_oPanN:= TPanel():New(nLiIni,nCoIni, "Comparativo" + CRLF+ "                            XML                                         x                                       NF", oPanel,oBold,lCentered, ,CLR_MAGENTA, , 0,20,lLowered,lRaised) 
    _oPanN:Align := CONTROL_ALIGN_TOP
    
    nLiIni := _oPanN:NBOTTOM + 50
    
    //verifica os tamanhos dos arrays (xml e nf) se os tamanhos forem iguais, é 1 para 1, senão, tratar como divergência
    If Len(aCols12) <> Len(aColsd1)
    	lTemDiv := .T.
    Endif 
    
    //dados item xml + item nf mesclados para comparar
	_oPanCN:= TPanel():New(nLiIni,nCoIni,"", oPanel, , lCentered, , , , 0,80,lLowered,lRaised)  //50 é a largura
    _oPanCN:Align := CONTROL_ALIGN_TOP
    
    aHeaderQX := {}
    noBrwQX   := 0   
	_fHeaderV(@aHeaderQX,@noBrwQX,"","PIS")		//monta array das colunas
	
	aColsQX := {}
	oGetDadosQX:= MsNewGetDados():New(nLiIni,nCo1,nLiFim,nCo2,0,{|| },"AllwaysTrue","",aAltera,,9999,"AllwaysTrue","","AllwaysTrue",_oPanCN,aHeaderQX,aColsQX)    
	//_fColBrwf1(oGetDadosf1, aColsf1)		//cria massa de dados para a getdados
	_fColBrwit(oGetDadosQX, aColsQX, noBrwQX, "ZBT","PIS",lTemDiv)
	oGetDadosQX:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	nLiIni := _oPanCN:NBOTTOM + 50 
	
	xCor1    := CLR_HBLUE
	
	lTemDiv  := .F. 
	lTemRepli:= .F.    //indica se houve desmembramento ou replicação 
	
	For x := 1 to Len(aColsQX)
	   
	    If Empty(aColsQX[x,1])
			lTemRepli := .T.
			cMsgDiv1 += "HOUVE DESMEMBRAMENTO / REPLICAÇÃO - ITEM NF: " + aColsQX[x,7]+ CRLF
  		Endif
  		  
  	Next 
	
	If !lTemRepli
		For x := 1 to Len(aColsQX)
		    If aColsQX[x,4] <> aColsQX[x,6] 		    		
		    	cMsgDiv1 += "PIS DIVERGENTE - ITEM NF: " + aColsQX[x,7] + CRLF //TOTAIS BRUTOS:"+ CRLF + "DIVERGÊNCIA ENCONTRADA ==> R$" + Alltrim(Str(nDiv1))
		    	xCor1    := CLR_HRED 
		    	lTemDiv  := .T.		    		  	
	  		Endif  
	  	Next
  	Endif
  	
    If !lTemDiv    
    	cMsgDiv1 += "SEM DIVERGÊNCIA"  
    	xCor1    := CLR_HBLUE
    Endif    
     
    lLowered  := .T.
    lRaised   := .F.
    lCentered := .F.
    
	//só titulo
	_oPnConclu:= TPanel():New(nLiIni,nCoIni,"Conclusão:", oPanel,oBold,lCentered, ,CLR_MAGENTA, , 0,20,lLowered,lRaised)         
    _oPnConclu:Align := CONTROL_ALIGN_TOP   
    
    lLowered  := .T.
    lRaised   := .T.
    lCentered := .F.
    
    nLiIni := _oPnConclu:NBOTTOM + 20
    _oPnMsg:= TPanel():New(nLiIni,nCoIni,cMsgDiv1, oPanel,oBold1,lCentered , ,xCor1, , 0,20,lLowered,lRaised)
	_oPnMsg:Align := CONTROL_ALIGN_ALLCLIENT 
    
	

Return

//------------------------------------------------------------------//
//PAINEL DOS IMPOSTOS dos ITENS - comparar COFINS - XML x NF
//------------------------------------------------------------------//
Static Function _fCompCOi( oPanel )
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

	//Local _oPanel
	//Local _oPanelC 
	Local _oPanelT
	Local _oPanelIT

	Local _oPanN
	//Local _oPanCN 
	Local _oPanTN
	Local _oPanITN
	
	Local cMsgDiv1	:= ""
	Local _oPnConclu
	Local _oPnMsg
	Local x 		:= 0 
	Local lTemDiv   := .F.	

	
	Local lLowered  := .F.
	Local lRaised   := .T. //.T. mostra borda do painel  
	Local lCentered := .T. //.T. mostra o texto do objeto no centro painel
	
	Private aObjects:= {}									
	Private aSize   := MsAdvSize(.T.)						
	Private aInfo   := {}									
	Private aPos    := {}									
		
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
      
    aInfo := { aSize[1], aSize[2], aSize[3], aSize[4], 3, 3 }
    aPos  := MsObjSize( aInfo, aObjects ) 
    
    lLowered  := .F.
	lRaised   := .T. //.T. mostra borda do painel  
	lCentered := .F. //.T. mostra o texto do objeto no centro painel
    
	//---------------------------------------------------------//
	//painel a parte, para inserção do botão "exporta excel" :	
	//---------------------------------------------------------//
	nLiIni := aPos[1][2]  	//3
	nCoIni := aPos[1][2]    //3
	
	//---------------------//
	//XML 
	//---------------------//	
    //só titulo
    _oPanelT:= TPanel():New(nLiIni,nCoIni,"COFINS Por Item XML", oPanel,oBold,lCentered, ,CLR_HBLUE , , 0,20,lLowered,lRaised)
    _oPanelT:Align := CONTROL_ALIGN_TOP
            
	//dados itens
	_oPanelIT:= TPanel():New(nLiIni,nCoIni,"", oPanel, ,lCentered , , , , 0,80,lLowered,lRaised)
	_oPanelIT:Align := CONTROL_ALIGN_TOP 
    
	//monta acols e massa de dados dos itens
	aHeader12 := {}  //zera antes de gerar
	noBrw12   := 0    
	_fHeaderV(@aHeader12,@noBrw12,xZBT,"COF")		//monta array das colunas
	
	aCols12 := {}
	oGetDados12:= MsNewGetDados():New(nLiIni,nCo1,nLiFim,nCo2,0,{|| },"AllwaysTrue","",aAltera,,9999,"AllwaysTrue","","AllwaysTrue",_oPanelIT,aHeader12,aCols12)
	_fColBrwit(oGetDados12, aCols12 , noBrw12)		//cria massa de dados para a getdados
	oGetDados12:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	//--------------------//	
	//NOTA FISCAL
	//--------------------//
	//só titulo
    _oPanTN:= TPanel():New(nLiIni,nCoIni,"COFINS Por Item NF", oPanel,oBold,lCentered, ,CLR_GREEN, , 0,20,lLowered,lRaised)
    _oPanTN:Align := CONTROL_ALIGN_TOP
            
	//dados itens
	_oPanITN:= TPanel():New(nLiIni,nCoIni,"", oPanel, ,lCentered , , , , 0,80,lLowered,lRaised)
	_oPanITN:Align := CONTROL_ALIGN_TOP 
    
	//monta acols e massa de dados dos itens
	aHeaderd1 := {}
	noBrwd1   := 0	
	_fHeaderV(@aHeaderd1,@noBrwd1,"SD1","COF")		//monta array das colunas
	
	aColsd1 := {}
	oGetDadosd1:= MsNewGetDados():New(nLiIni,nCo1,nLiFim,nCo2,0,{|| },"AllwaysTrue","",aAltera,,9999,"AllwaysTrue","","AllwaysTrue",_oPanITN,aHeaderd1,aColsd1)
	_fColBrwd1(oGetDadosd1, aColsd1, noBrwd1)		//cria massa de dados para a getdados
	oGetDadosd1:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	//só título
	//_oPanN:= TPanel():New(nLiIni,nCoIni, "Comparativo XML x NF", oPanel,oBold,lCentered, ,CLR_MAGENTA, , 0,20,lLowered,lRaised)
	_oPanN:= TPanel():New(nLiIni,nCoIni, "Comparativo" + CRLF+ "                            XML                                         x                                         NF", oPanel,oBold,lCentered, ,CLR_MAGENTA, , 0,20,lLowered,lRaised) 
    _oPanN:Align := CONTROL_ALIGN_TOP
    
    nLiIni := _oPanN:NBOTTOM + 50
    
    //verifica os tamanhos dos arrays (xml e nf) se os tamanhos forem iguais, é 1 para 1, senão, tratar como divergência
    If Len(aCols12) <> Len(aColsd1)
    	lTemDiv := .T.
    Endif 
    
    //dados item xml + item nf mesclados para comparar
	_oPanCN:= TPanel():New(nLiIni,nCoIni,"", oPanel, , lCentered, , , , 0,80,lLowered,lRaised)  //50 é a largura
    _oPanCN:Align := CONTROL_ALIGN_TOP
    
    aHeaderQX := {}
    noBrwQX   := 0   
	_fHeaderV(@aHeaderQX,@noBrwQX,"","COF")		//monta array das colunas
	
	aColsQX := {}
	oGetDadosQX:= MsNewGetDados():New(nLiIni,nCo1,nLiFim,nCo2,0,{|| },"AllwaysTrue","",aAltera,,9999,"AllwaysTrue","","AllwaysTrue",_oPanCN,aHeaderQX,aColsQX)    
	//_fColBrwf1(oGetDadosf1, aColsf1)		//cria massa de dados para a getdados
	_fColBrwit(oGetDadosQX, aColsQX, noBrwQX, "ZBT","COF",lTemDiv)
	oGetDadosQX:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	nLiIni := _oPanCN:NBOTTOM + 50    
	
	xCor1    := CLR_HBLUE
	
	lTemDiv  := .F.
	lTemRepli:= .F.    //indica se houve desmembramento ou replicação
	For x := 1 to Len(aColsQX)
	   
	    If Empty(aColsQX[x,1])
			lTemRepli := .T.
			cMsgDiv1 += "HOUVE DESMEMBRAMENTO / REPLICAÇÃO - ITEM NF: " + aColsQX[x,7]+ CRLF
  		Endif
  		  
  	Next 
	
	If !lTemRepli
		For x := 1 to Len(aColsQX)
		    If aColsQX[x,4] <> aColsQX[x,6] 		    		
		    	cMsgDiv1 += "COFINS DIVERGENTE - ITEM NF: " + aColsQX[x,7] + CRLF //TOTAIS BRUTOS:"+ CRLF + "DIVERGÊNCIA ENCONTRADA ==> R$" + Alltrim(Str(nDiv1))
		    	xCor1    := CLR_HRED 
		    	lTemDiv  := .T.		    		  	
	  		Endif  
	  	Next
  	Endif
  	
    If !lTemDiv    
    	cMsgDiv1 += "SEM DIVERGÊNCIA"  
    	xCor1    := CLR_HBLUE
    Endif    
     
    lLowered  := .T.
    lRaised   := .F.
    lCentered := .F.
    
	//só titulo
	_oPnConclu:= TPanel():New(nLiIni,nCoIni,"Conclusão:", oPanel,oBold,lCentered, ,CLR_MAGENTA, , 0,20,lLowered,lRaised)         
    _oPnConclu:Align := CONTROL_ALIGN_TOP   
    
    lLowered  := .T.
    lRaised   := .T.
    lCentered := .F.
    
    nLiIni := _oPnConclu:NBOTTOM + 20
    _oPnMsg:= TPanel():New(nLiIni,nCoIni,cMsgDiv1, oPanel,oBold1,lCentered , ,xCor1, , 0,20,lLowered,lRaised)
	_oPnMsg:Align := CONTROL_ALIGN_ALLCLIENT 
 
Return  


//------------------------------------------------------------------//
//PAINEL DOS IMPOSTOS dos ITENS - comparar INSS - XML x NF
//------------------------------------------------------------------//
Static Function _fCompINi( oPanel )
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

	//Local _oPanel
	//Local _oPanelC 
	Local _oPanelT
	Local _oPanelIT

	Local _oPanN
	//Local _oPanCN 
	Local _oPanTN
	Local _oPanITN
	
	Local cMsgDiv1	:= ""
	Local _oPnConclu
	Local _oPnMsg
	Local x 		:= 0 
	Local lTemDiv   := .F.	

	
	Local lLowered  := .F.
	Local lRaised   := .T. //.T. mostra borda do painel  
	Local lCentered := .T. //.T. mostra o texto do objeto no centro painel
	
	Private aObjects:= {}									
	Private aSize   := MsAdvSize(.T.)						
	Private aInfo   := {}									
	Private aPos    := {}									
		
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
      
    aInfo := { aSize[1], aSize[2], aSize[3], aSize[4], 3, 3 }
    aPos  := MsObjSize( aInfo, aObjects ) 
    
    lLowered  := .F.
	lRaised   := .T. //.T. mostra borda do painel  
	lCentered := .F. //.T. mostra o texto do objeto no centro painel
    
	//---------------------------------------------------------//
	//painel a parte, para inserção do botão "exporta excel" :	
	//---------------------------------------------------------//
	nLiIni := aPos[1][2]  	//3
	nCoIni := aPos[1][2]    //3
	
	//---------------------//
	//XML 
	//---------------------//	
    //só titulo
    _oPanelT:= TPanel():New(nLiIni,nCoIni,"INSS Por Item XML", oPanel,oBold,lCentered, ,CLR_HBLUE , , 0,20,lLowered,lRaised)
    _oPanelT:Align := CONTROL_ALIGN_TOP
            
	//dados itens
	_oPanelIT:= TPanel():New(nLiIni,nCoIni,"", oPanel, ,lCentered , , , , 0,80,lLowered,lRaised)
	_oPanelIT:Align := CONTROL_ALIGN_TOP 
    
	//monta acols e massa de dados dos itens
	aHeader12 := {}  //zera antes de gerar
	noBrw12   := 0    
	_fHeaderV(@aHeader12,@noBrw12,xZBT,"IN")		//monta array das colunas
	
	aCols12 := {}
	oGetDados12:= MsNewGetDados():New(nLiIni,nCo1,nLiFim,nCo2,0,{|| },"AllwaysTrue","",aAltera,,9999,"AllwaysTrue","","AllwaysTrue",_oPanelIT,aHeader12,aCols12)
	_fColBrwit(oGetDados12, aCols12 , noBrw12)		//cria massa de dados para a getdados
	oGetDados12:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	//--------------------//	
	//NOTA FISCAL
	//--------------------//
	//só titulo
    _oPanTN:= TPanel():New(nLiIni,nCoIni,"INSS Por Item NF", oPanel,oBold,lCentered, ,CLR_GREEN, , 0,20,lLowered,lRaised)
    _oPanTN:Align := CONTROL_ALIGN_TOP
            
	//dados itens
	_oPanITN:= TPanel():New(nLiIni,nCoIni,"", oPanel, ,lCentered , , , , 0,80,lLowered,lRaised)
	_oPanITN:Align := CONTROL_ALIGN_TOP 
    
	//monta acols e massa de dados dos itens
	aHeaderd1 := {}
	noBrwd1   := 0	
	_fHeaderV(@aHeaderd1,@noBrwd1,"SD1","IN")		//monta array das colunas
	
	aColsd1 := {}
	oGetDadosd1:= MsNewGetDados():New(nLiIni,nCo1,nLiFim,nCo2,0,{|| },"AllwaysTrue","",aAltera,,9999,"AllwaysTrue","","AllwaysTrue",_oPanITN,aHeaderd1,aColsd1)
	_fColBrwd1(oGetDadosd1, aColsd1, noBrwd1)		//cria massa de dados para a getdados
	oGetDadosd1:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	//só título
	//_oPanN:= TPanel():New(nLiIni,nCoIni, "Comparativo XML x NF", oPanel,oBold,lCentered, ,CLR_MAGENTA, , 0,20,lLowered,lRaised)
	_oPanN:= TPanel():New(nLiIni,nCoIni, "Comparativo" + CRLF+ "                            XML                                         x                                         NF", oPanel,oBold,lCentered, ,CLR_MAGENTA, , 0,20,lLowered,lRaised) 
    _oPanN:Align := CONTROL_ALIGN_TOP
    
    nLiIni := _oPanN:NBOTTOM + 50
    
    //verifica os tamanhos dos arrays (xml e nf) se os tamanhos forem iguais, é 1 para 1, senão, tratar como divergência
    If Len(aCols12) <> Len(aColsd1)
    	lTemDiv := .T.
    Endif 
    
    //dados item xml + item nf mesclados para comparar
	_oPanCN:= TPanel():New(nLiIni,nCoIni,"", oPanel, , lCentered, , , , 0,80,lLowered,lRaised)  //50 é a largura
    _oPanCN:Align := CONTROL_ALIGN_TOP
    
    aHeaderQX := {}
    noBrwQX   := 0   
	_fHeaderV(@aHeaderQX,@noBrwQX,"","IN")		//monta array das colunas
	
	aColsQX := {}
	oGetDadosQX:= MsNewGetDados():New(nLiIni,nCo1,nLiFim,nCo2,0,{|| },"AllwaysTrue","",aAltera,,9999,"AllwaysTrue","","AllwaysTrue",_oPanCN,aHeaderQX,aColsQX)    
	//_fColBrwf1(oGetDadosf1, aColsf1)		//cria massa de dados para a getdados
	_fColBrwit(oGetDadosQX, aColsQX, noBrwQX, "ZBT","IN",lTemDiv)
	oGetDadosQX:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	nLiIni := _oPanCN:NBOTTOM + 50    
	
	xCor1    := CLR_HBLUE
	
	lTemDiv  := .F.
	lTemRepli:= .F.    //indica se houve desmembramento ou replicação
	For x := 1 to Len(aColsQX)
	   
	    If Empty(aColsQX[x,1])
			lTemRepli := .T.
			cMsgDiv1 += "HOUVE DESMEMBRAMENTO / REPLICAÇÃO - ITEM NF: " + aColsQX[x,7]+ CRLF
  		Endif
  		  
  	Next 
	
	If !lTemRepli
		For x := 1 to Len(aColsQX)
		    If aColsQX[x,4] <> aColsQX[x,6] 		    		
		    	cMsgDiv1 += "COFINS DIVERGENTE - ITEM NF: " + aColsQX[x,7] + CRLF //TOTAIS BRUTOS:"+ CRLF + "DIVERGÊNCIA ENCONTRADA ==> R$" + Alltrim(Str(nDiv1))
		    	xCor1    := CLR_HRED 
		    	lTemDiv  := .T.		    		  	
	  		Endif  
	  	Next
  	Endif
  	
    If !lTemDiv    
    	cMsgDiv1 += "SEM DIVERGÊNCIA"  
    	xCor1    := CLR_HBLUE
    Endif    
     
    lLowered  := .T.
    lRaised   := .F.
    lCentered := .F.
    
	//só titulo
	_oPnConclu:= TPanel():New(nLiIni,nCoIni,"Conclusão:", oPanel,oBold,lCentered, ,CLR_MAGENTA, , 0,20,lLowered,lRaised)         
    _oPnConclu:Align := CONTROL_ALIGN_TOP   
    
    lLowered  := .T.
    lRaised   := .T.
    lCentered := .F.
    
    nLiIni := _oPnConclu:NBOTTOM + 20
    _oPnMsg:= TPanel():New(nLiIni,nCoIni,cMsgDiv1, oPanel,oBold1,lCentered , ,xCor1, , 0,20,lLowered,lRaised)
	_oPnMsg:Align := CONTROL_ALIGN_ALLCLIENT 
 
Return 


//------------------------------------------------------------------//
//PAINEL DOS IMPOSTOS dos ITENS - comparar ISS - XML x NF
//------------------------------------------------------------------//
Static Function _fCompISi( oPanel )
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

	//Local _oPanel
	//Local _oPanelC 
	Local _oPanelT
	Local _oPanelIT

	Local _oPanN
	//Local _oPanCN 
	Local _oPanTN
	Local _oPanITN
	
	Local cMsgDiv1	:= ""
	Local _oPnConclu
	Local _oPnMsg
	Local x 		:= 0 
	Local lTemDiv   := .F.	

	
	Local lLowered  := .F.
	Local lRaised   := .T. //.T. mostra borda do painel  
	Local lCentered := .T. //.T. mostra o texto do objeto no centro painel
	
	Private aObjects:= {}									
	Private aSize   := MsAdvSize(.T.)						
	Private aInfo   := {}									
	Private aPos    := {}									
		
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
      
    aInfo := { aSize[1], aSize[2], aSize[3], aSize[4], 3, 3 }
    aPos  := MsObjSize( aInfo, aObjects ) 
    
    lLowered  := .F.
	lRaised   := .T. //.T. mostra borda do painel  
	lCentered := .F. //.T. mostra o texto do objeto no centro painel
    
	//---------------------------------------------------------//
	//painel a parte, para inserção do botão "exporta excel" :	
	//---------------------------------------------------------//
	nLiIni := aPos[1][2]  	//3
	nCoIni := aPos[1][2]    //3
	
	//---------------------//
	//XML 
	//---------------------//	
    //só titulo
    _oPanelT:= TPanel():New(nLiIni,nCoIni,"ISS Por Item XML", oPanel,oBold,lCentered, ,CLR_HBLUE , , 0,20,lLowered,lRaised)
    _oPanelT:Align := CONTROL_ALIGN_TOP
            
	//dados itens
	_oPanelIT:= TPanel():New(nLiIni,nCoIni,"", oPanel, ,lCentered , , , , 0,80,lLowered,lRaised)
	_oPanelIT:Align := CONTROL_ALIGN_TOP 
    
	//monta acols e massa de dados dos itens
	aHeader12 := {}  //zera antes de gerar
	noBrw12   := 0    
	_fHeaderV(@aHeader12,@noBrw12,xZBT,"IS")		//monta array das colunas
	
	aCols12 := {}
	oGetDados12:= MsNewGetDados():New(nLiIni,nCo1,nLiFim,nCo2,0,{|| },"AllwaysTrue","",aAltera,,9999,"AllwaysTrue","","AllwaysTrue",_oPanelIT,aHeader12,aCols12)
	_fColBrwit(oGetDados12, aCols12 , noBrw12)		//cria massa de dados para a getdados
	oGetDados12:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	//--------------------//	
	//NOTA FISCAL
	//--------------------//
	//só titulo
    _oPanTN:= TPanel():New(nLiIni,nCoIni,"ISS Por Item NF", oPanel,oBold,lCentered, ,CLR_GREEN, , 0,20,lLowered,lRaised)
    _oPanTN:Align := CONTROL_ALIGN_TOP
            
	//dados itens
	_oPanITN:= TPanel():New(nLiIni,nCoIni,"", oPanel, ,lCentered , , , , 0,80,lLowered,lRaised)
	_oPanITN:Align := CONTROL_ALIGN_TOP 
    
	//monta acols e massa de dados dos itens
	aHeaderd1 := {}
	noBrwd1   := 0	
	_fHeaderV(@aHeaderd1,@noBrwd1,"SD1","IS")		//monta array das colunas
	
	aColsd1 := {}
	oGetDadosd1:= MsNewGetDados():New(nLiIni,nCo1,nLiFim,nCo2,0,{|| },"AllwaysTrue","",aAltera,,9999,"AllwaysTrue","","AllwaysTrue",_oPanITN,aHeaderd1,aColsd1)
	_fColBrwd1(oGetDadosd1, aColsd1, noBrwd1)		//cria massa de dados para a getdados
	oGetDadosd1:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	//só título
	//_oPanN:= TPanel():New(nLiIni,nCoIni, "Comparativo XML x NF", oPanel,oBold,lCentered, ,CLR_MAGENTA, , 0,20,lLowered,lRaised)
	_oPanN:= TPanel():New(nLiIni,nCoIni, "Comparativo" + CRLF+ "                            XML                                         x                                         NF", oPanel,oBold,lCentered, ,CLR_MAGENTA, , 0,20,lLowered,lRaised) 
    _oPanN:Align := CONTROL_ALIGN_TOP
    
    nLiIni := _oPanN:NBOTTOM + 50
    
    //verifica os tamanhos dos arrays (xml e nf) se os tamanhos forem iguais, é 1 para 1, senão, tratar como divergência
    If Len(aCols12) <> Len(aColsd1)
    	lTemDiv := .T.
    Endif 
    
    //dados item xml + item nf mesclados para comparar
	_oPanCN:= TPanel():New(nLiIni,nCoIni,"", oPanel, , lCentered, , , , 0,80,lLowered,lRaised)  //50 é a largura
    _oPanCN:Align := CONTROL_ALIGN_TOP
    
    aHeaderQX := {}
    noBrwQX   := 0   
	_fHeaderV(@aHeaderQX,@noBrwQX,"","IS")		//monta array das colunas
	
	aColsQX := {}
	oGetDadosQX:= MsNewGetDados():New(nLiIni,nCo1,nLiFim,nCo2,0,{|| },"AllwaysTrue","",aAltera,,9999,"AllwaysTrue","","AllwaysTrue",_oPanCN,aHeaderQX,aColsQX)    
	//_fColBrwf1(oGetDadosf1, aColsf1)		//cria massa de dados para a getdados
	_fColBrwit(oGetDadosQX, aColsQX, noBrwQX, "ZBT","IS",lTemDiv)
	oGetDadosQX:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	nLiIni := _oPanCN:NBOTTOM + 50    
	
	xCor1    := CLR_HBLUE
	
	lTemDiv  := .F.
	lTemRepli:= .F.    //indica se houve desmembramento ou replicação
	For x := 1 to Len(aColsQX)
	   
	    If Empty(aColsQX[x,1])
			lTemRepli := .T.
			cMsgDiv1 += "HOUVE DESMEMBRAMENTO / REPLICAÇÃO - ITEM NF: " + aColsQX[x,7]+ CRLF
  		Endif
  		  
  	Next 
	
	If !lTemRepli
		For x := 1 to Len(aColsQX)
		    If aColsQX[x,4] <> aColsQX[x,6] 		    		
		    	cMsgDiv1 += "COFINS DIVERGENTE - ITEM NF: " + aColsQX[x,7] + CRLF //TOTAIS BRUTOS:"+ CRLF + "DIVERGÊNCIA ENCONTRADA ==> R$" + Alltrim(Str(nDiv1))
		    	xCor1    := CLR_HRED 
		    	lTemDiv  := .T.		    		  	
	  		Endif  
	  	Next
  	Endif
  	
    If !lTemDiv    
    	cMsgDiv1 += "SEM DIVERGÊNCIA"  
    	xCor1    := CLR_HBLUE
    Endif    
     
    lLowered  := .T.
    lRaised   := .F.
    lCentered := .F.
    
	//só titulo
	_oPnConclu:= TPanel():New(nLiIni,nCoIni,"Conclusão:", oPanel,oBold,lCentered, ,CLR_MAGENTA, , 0,20,lLowered,lRaised)         
    _oPnConclu:Align := CONTROL_ALIGN_TOP   
    
    lLowered  := .T.
    lRaised   := .T.
    lCentered := .F.
    
    nLiIni := _oPnConclu:NBOTTOM + 20
    _oPnMsg:= TPanel():New(nLiIni,nCoIni,cMsgDiv1, oPanel,oBold1,lCentered , ,xCor1, , 0,20,lLowered,lRaised)
	_oPnMsg:Align := CONTROL_ALIGN_ALLCLIENT 
 
Return 


//------------------------------------------------------------------//
//PAINEL DOS IMPOSTOS dos ITENS - comparar IR - XML x NF
//------------------------------------------------------------------//
Static Function _fCompIRi( oPanel )
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

	//Local _oPanel
	//Local _oPanelC 
	Local _oPanelT
	Local _oPanelIT

	Local _oPanN
	//Local _oPanCN 
	Local _oPanTN
	Local _oPanITN
	
	Local cMsgDiv1	:= ""
	Local _oPnConclu
	Local _oPnMsg
	Local x 		:= 0 
	Local lTemDiv   := .F.	

	
	Local lLowered  := .F.
	Local lRaised   := .T. //.T. mostra borda do painel  
	Local lCentered := .T. //.T. mostra o texto do objeto no centro painel
	
	Private aObjects:= {}									
	Private aSize   := MsAdvSize(.T.)						
	Private aInfo   := {}									
	Private aPos    := {}									
		
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
      
    aInfo := { aSize[1], aSize[2], aSize[3], aSize[4], 3, 3 }
    aPos  := MsObjSize( aInfo, aObjects ) 
    
    lLowered  := .F.
	lRaised   := .T. //.T. mostra borda do painel  
	lCentered := .F. //.T. mostra o texto do objeto no centro painel
    
	//---------------------------------------------------------//
	//painel a parte, para inserção do botão "exporta excel" :	
	//---------------------------------------------------------//
	nLiIni := aPos[1][2]  	//3
	nCoIni := aPos[1][2]    //3
	
	//---------------------//
	//XML 
	//---------------------//	
    //só titulo
    _oPanelT:= TPanel():New(nLiIni,nCoIni,"IR Por Item XML", oPanel,oBold,lCentered, ,CLR_HBLUE , , 0,20,lLowered,lRaised)
    _oPanelT:Align := CONTROL_ALIGN_TOP
            
	//dados itens
	_oPanelIT:= TPanel():New(nLiIni,nCoIni,"", oPanel, ,lCentered , , , , 0,80,lLowered,lRaised)
	_oPanelIT:Align := CONTROL_ALIGN_TOP 
    
	//monta acols e massa de dados dos itens
	aHeader12 := {}  //zera antes de gerar
	noBrw12   := 0    
	_fHeaderV(@aHeader12,@noBrw12,xZBT,"IR")		//monta array das colunas
	
	aCols12 := {}
	oGetDados12:= MsNewGetDados():New(nLiIni,nCo1,nLiFim,nCo2,0,{|| },"AllwaysTrue","",aAltera,,9999,"AllwaysTrue","","AllwaysTrue",_oPanelIT,aHeader12,aCols12)
	_fColBrwit(oGetDados12, aCols12 , noBrw12)		//cria massa de dados para a getdados
	oGetDados12:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	//--------------------//	
	//NOTA FISCAL
	//--------------------//
	//só titulo
    _oPanTN:= TPanel():New(nLiIni,nCoIni,"IR Por Item NF", oPanel,oBold,lCentered, ,CLR_GREEN, , 0,20,lLowered,lRaised)
    _oPanTN:Align := CONTROL_ALIGN_TOP
            
	//dados itens
	_oPanITN:= TPanel():New(nLiIni,nCoIni,"", oPanel, ,lCentered , , , , 0,80,lLowered,lRaised)
	_oPanITN:Align := CONTROL_ALIGN_TOP 
    
	//monta acols e massa de dados dos itens
	aHeaderd1 := {}
	noBrwd1   := 0	
	_fHeaderV(@aHeaderd1,@noBrwd1,"SD1","IR")		//monta array das colunas
	
	aColsd1 := {}
	oGetDadosd1:= MsNewGetDados():New(nLiIni,nCo1,nLiFim,nCo2,0,{|| },"AllwaysTrue","",aAltera,,9999,"AllwaysTrue","","AllwaysTrue",_oPanITN,aHeaderd1,aColsd1)
	_fColBrwd1(oGetDadosd1, aColsd1, noBrwd1)		//cria massa de dados para a getdados
	oGetDadosd1:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	//só título
	//_oPanN:= TPanel():New(nLiIni,nCoIni, "Comparativo XML x NF", oPanel,oBold,lCentered, ,CLR_MAGENTA, , 0,20,lLowered,lRaised)
	_oPanN:= TPanel():New(nLiIni,nCoIni, "Comparativo" + CRLF+ "                            XML                                         x                                         NF", oPanel,oBold,lCentered, ,CLR_MAGENTA, , 0,20,lLowered,lRaised) 
    _oPanN:Align := CONTROL_ALIGN_TOP
    
    nLiIni := _oPanN:NBOTTOM + 50
    
    //verifica os tamanhos dos arrays (xml e nf) se os tamanhos forem iguais, é 1 para 1, senão, tratar como divergência
    If Len(aCols12) <> Len(aColsd1)
    	lTemDiv := .T.
    Endif 
    
    //dados item xml + item nf mesclados para comparar
	_oPanCN:= TPanel():New(nLiIni,nCoIni,"", oPanel, , lCentered, , , , 0,80,lLowered,lRaised)  //50 é a largura
    _oPanCN:Align := CONTROL_ALIGN_TOP
    
    aHeaderQX := {}
    noBrwQX   := 0   
	_fHeaderV(@aHeaderQX,@noBrwQX,"","IR")		//monta array das colunas
	
	aColsQX := {}
	oGetDadosQX:= MsNewGetDados():New(nLiIni,nCo1,nLiFim,nCo2,0,{|| },"AllwaysTrue","",aAltera,,9999,"AllwaysTrue","","AllwaysTrue",_oPanCN,aHeaderQX,aColsQX)    
	//_fColBrwf1(oGetDadosf1, aColsf1)		//cria massa de dados para a getdados
	_fColBrwit(oGetDadosQX, aColsQX, noBrwQX, "ZBT","IR",lTemDiv)
	oGetDadosQX:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	nLiIni := _oPanCN:NBOTTOM + 50    
	
	xCor1    := CLR_HBLUE
	
	lTemDiv  := .F.
	lTemRepli:= .F.    //indica se houve desmembramento ou replicação
	For x := 1 to Len(aColsQX)
	   
	    If Empty(aColsQX[x,1])
			lTemRepli := .T.
			cMsgDiv1 += "HOUVE DESMEMBRAMENTO / REPLICAÇÃO - ITEM NF: " + aColsQX[x,7]+ CRLF
  		Endif
  		  
  	Next 
	
	If !lTemRepli
		For x := 1 to Len(aColsQX)
		    If aColsQX[x,4] <> aColsQX[x,6] 		    		
		    	cMsgDiv1 += "COFINS DIVERGENTE - ITEM NF: " + aColsQX[x,7] + CRLF //TOTAIS BRUTOS:"+ CRLF + "DIVERGÊNCIA ENCONTRADA ==> R$" + Alltrim(Str(nDiv1))
		    	xCor1    := CLR_HRED 
		    	lTemDiv  := .T.		    		  	
	  		Endif  
	  	Next
  	Endif
  	
    If !lTemDiv    
    	cMsgDiv1 += "SEM DIVERGÊNCIA"  
    	xCor1    := CLR_HBLUE
    Endif    
     
    lLowered  := .T.
    lRaised   := .F.
    lCentered := .F.
    
	//só titulo
	_oPnConclu:= TPanel():New(nLiIni,nCoIni,"Conclusão:", oPanel,oBold,lCentered, ,CLR_MAGENTA, , 0,20,lLowered,lRaised)         
    _oPnConclu:Align := CONTROL_ALIGN_TOP   
    
    lLowered  := .T.
    lRaised   := .T.
    lCentered := .F.
    
    nLiIni := _oPnConclu:NBOTTOM + 20
    _oPnMsg:= TPanel():New(nLiIni,nCoIni,cMsgDiv1, oPanel,oBold1,lCentered , ,xCor1, , 0,20,lLowered,lRaised)
	_oPnMsg:Align := CONTROL_ALIGN_ALLCLIENT 
 
Return


//------------------------------------------------------------------//
//PAINEL DOS IMPOSTOS dos ITENS - comparar CSLL - XML x NF
//------------------------------------------------------------------//
Static Function _fCompCSi( oPanel )
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

	//Local _oPanel
	//Local _oPanelC 
	Local _oPanelT
	Local _oPanelIT

	Local _oPanN
	//Local _oPanCN 
	Local _oPanTN
	Local _oPanITN
	
	Local cMsgDiv1	:= ""
	Local _oPnConclu
	Local _oPnMsg
	Local x 		:= 0 
	Local lTemDiv   := .F.	

	
	Local lLowered  := .F.
	Local lRaised   := .T. //.T. mostra borda do painel  
	Local lCentered := .T. //.T. mostra o texto do objeto no centro painel
	
	Private aObjects:= {}									
	Private aSize   := MsAdvSize(.T.)						
	Private aInfo   := {}									
	Private aPos    := {}									
		
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
      
    aInfo := { aSize[1], aSize[2], aSize[3], aSize[4], 3, 3 }
    aPos  := MsObjSize( aInfo, aObjects ) 
    
    lLowered  := .F.
	lRaised   := .T. //.T. mostra borda do painel  
	lCentered := .F. //.T. mostra o texto do objeto no centro painel
    
	//---------------------------------------------------------//
	//painel a parte, para inserção do botão "exporta excel" :	
	//---------------------------------------------------------//
	nLiIni := aPos[1][2]  	//3
	nCoIni := aPos[1][2]    //3
	
	//---------------------//
	//XML 
	//---------------------//	
    //só titulo
    _oPanelT:= TPanel():New(nLiIni,nCoIni,"CSLL Por Item XML", oPanel,oBold,lCentered, ,CLR_HBLUE , , 0,20,lLowered,lRaised)
    _oPanelT:Align := CONTROL_ALIGN_TOP
            
	//dados itens
	_oPanelIT:= TPanel():New(nLiIni,nCoIni,"", oPanel, ,lCentered , , , , 0,80,lLowered,lRaised)
	_oPanelIT:Align := CONTROL_ALIGN_TOP 
    
	//monta acols e massa de dados dos itens
	aHeader12 := {}  //zera antes de gerar
	noBrw12   := 0    
	_fHeaderV(@aHeader12,@noBrw12,xZBT,"CS")		//monta array das colunas
	
	aCols12 := {}
	oGetDados12:= MsNewGetDados():New(nLiIni,nCo1,nLiFim,nCo2,0,{|| },"AllwaysTrue","",aAltera,,9999,"AllwaysTrue","","AllwaysTrue",_oPanelIT,aHeader12,aCols12)
	_fColBrwit(oGetDados12, aCols12 , noBrw12)		//cria massa de dados para a getdados
	oGetDados12:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	//--------------------//	
	//NOTA FISCAL
	//--------------------//
	//só titulo
    _oPanTN:= TPanel():New(nLiIni,nCoIni,"CSLL Por Item NF", oPanel,oBold,lCentered, ,CLR_GREEN, , 0,20,lLowered,lRaised)
    _oPanTN:Align := CONTROL_ALIGN_TOP
            
	//dados itens
	_oPanITN:= TPanel():New(nLiIni,nCoIni,"", oPanel, ,lCentered , , , , 0,80,lLowered,lRaised)
	_oPanITN:Align := CONTROL_ALIGN_TOP 
    
	//monta acols e massa de dados dos itens
	aHeaderd1 := {}
	noBrwd1   := 0	
	_fHeaderV(@aHeaderd1,@noBrwd1,"SD1","CS")		//monta array das colunas
	
	aColsd1 := {}
	oGetDadosd1:= MsNewGetDados():New(nLiIni,nCo1,nLiFim,nCo2,0,{|| },"AllwaysTrue","",aAltera,,9999,"AllwaysTrue","","AllwaysTrue",_oPanITN,aHeaderd1,aColsd1)
	_fColBrwd1(oGetDadosd1, aColsd1, noBrwd1)		//cria massa de dados para a getdados
	oGetDadosd1:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	//só título
	//_oPanN:= TPanel():New(nLiIni,nCoIni, "Comparativo XML x NF", oPanel,oBold,lCentered, ,CLR_MAGENTA, , 0,20,lLowered,lRaised)
	_oPanN:= TPanel():New(nLiIni,nCoIni, "Comparativo" + CRLF+ "                            XML                                         x                                         NF", oPanel,oBold,lCentered, ,CLR_MAGENTA, , 0,20,lLowered,lRaised) 
    _oPanN:Align := CONTROL_ALIGN_TOP
    
    nLiIni := _oPanN:NBOTTOM + 50
    
    //verifica os tamanhos dos arrays (xml e nf) se os tamanhos forem iguais, é 1 para 1, senão, tratar como divergência
    If Len(aCols12) <> Len(aColsd1)
    	lTemDiv := .T.
    Endif 
    
    //dados item xml + item nf mesclados para comparar
	_oPanCN:= TPanel():New(nLiIni,nCoIni,"", oPanel, , lCentered, , , , 0,80,lLowered,lRaised)  //50 é a largura
    _oPanCN:Align := CONTROL_ALIGN_TOP
    
    aHeaderQX := {}
    noBrwQX   := 0   
	_fHeaderV(@aHeaderQX,@noBrwQX,"","CS")		//monta array das colunas
	
	aColsQX := {}
	oGetDadosQX:= MsNewGetDados():New(nLiIni,nCo1,nLiFim,nCo2,0,{|| },"AllwaysTrue","",aAltera,,9999,"AllwaysTrue","","AllwaysTrue",_oPanCN,aHeaderQX,aColsQX)    
	//_fColBrwf1(oGetDadosf1, aColsf1)		//cria massa de dados para a getdados
	_fColBrwit(oGetDadosQX, aColsQX, noBrwQX, "ZBT","CS",lTemDiv)
	oGetDadosQX:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	nLiIni := _oPanCN:NBOTTOM + 50    
	
	xCor1    := CLR_HBLUE
	
	lTemDiv  := .F.
	lTemRepli:= .F.    //indica se houve desmembramento ou replicação
	For x := 1 to Len(aColsQX)
	   
	    If Empty(aColsQX[x,1])
			lTemRepli := .T.
			cMsgDiv1 += "HOUVE DESMEMBRAMENTO / REPLICAÇÃO - ITEM NF: " + aColsQX[x,7]+ CRLF
  		Endif
  		  
  	Next 
	
	If !lTemRepli
		For x := 1 to Len(aColsQX)
		    If aColsQX[x,4] <> aColsQX[x,6] 		    		
		    	cMsgDiv1 += "COFINS DIVERGENTE - ITEM NF: " + aColsQX[x,7] + CRLF //TOTAIS BRUTOS:"+ CRLF + "DIVERGÊNCIA ENCONTRADA ==> R$" + Alltrim(Str(nDiv1))
		    	xCor1    := CLR_HRED 
		    	lTemDiv  := .T.		    		  	
	  		Endif  
	  	Next
  	Endif
  	
    If !lTemDiv    
    	cMsgDiv1 += "SEM DIVERGÊNCIA"  
    	xCor1    := CLR_HBLUE
    Endif    
     
    lLowered  := .T.
    lRaised   := .F.
    lCentered := .F.
    
	//só titulo
	_oPnConclu:= TPanel():New(nLiIni,nCoIni,"Conclusão:", oPanel,oBold,lCentered, ,CLR_MAGENTA, , 0,20,lLowered,lRaised)         
    _oPnConclu:Align := CONTROL_ALIGN_TOP   
    
    lLowered  := .T.
    lRaised   := .T.
    lCentered := .F.
    
    nLiIni := _oPnConclu:NBOTTOM + 20
    _oPnMsg:= TPanel():New(nLiIni,nCoIni,cMsgDiv1, oPanel,oBold1,lCentered , ,xCor1, , 0,20,lLowered,lRaised)
	_oPnMsg:Align := CONTROL_ALIGN_ALLCLIENT 
 
Return
//---------------------------------------------------//
//FIM IMPOSTOS POR ITEM 
//---------------------------------------------------//

//--------------------------------------------------//
//MONTAGEM DE CABEÇALHOS 
//--------------------------------------------------//
Static Function _fHeaderD(aHeader,noBrw,cTab)

Local cCposNao := ""
Local aPriCpos := {}
Local fr	   := 0 

aCposZBZ := {}
aCposZBT := {}
aCposSF1 := {}
aCposSD1 := {}

If cTab == xZBZ
	cCposNao +=  "'" 
	cCposNao += xZBZ_+ "FILIAL"
	cCposNao += "/" + xZBZ_+ "XML"
	cCposNao += "/" + xZBZ_+ "OBS" 
	cCposNao += "/" + xZBZ_+ "DTMAIL"
	cCposNao += "/" + xZBZ_+ "PDF"
	cCposNao += "/" + xZBZ_+ "XMLCAN"
	cCposNao += "/" + xZBZ_+ "XMLRES"
	cCposNao += "/" + xZBZ_+ "CONDPG"
	cCposNao += "/" + xZBZ_+ "OBSDES"
	cCposNao += "/" + xZBZ_+ "ICOMPL"
	cCposNao += "'" 
	
	Aadd(aPriCpos , { 1  , xZBZ_+"NOTA"  } )
	Aadd(aPriCpos , { 2  , xZBZ_+"SERIE"} )
	Aadd(aPriCpos , { 3  , xZBZ_+"CODFOR"} ) 
	Aadd(aPriCpos , { 4  , xZBZ_+"LOJFOR"} )
	Aadd(aPriCpos , { 5  , xZBZ_+"FORNEC"  } )
	Aadd(aPriCpos , { 6  , xZBZ_+"VLLIQ"  } )
	Aadd(aPriCpos , { 7  , xZBZ_+"VLBRUT"  } )

Elseif cTab == xZBT 

	cCposNao +=  "'" 	
	cCposNao += xZBT_+ "FILIAL"
	cCposNao += "'" 
	
	Aadd(aPriCpos , { 1  , xZBT_+"ITEM"  } )
	Aadd(aPriCpos , { 2  , xZBT_+"PRODUT"  } )
	Aadd(aPriCpos , { 3  , xZBT_+"DESCRI"} )
	Aadd(aPriCpos , { 4  , xZBT_+"QUANT"} ) 
	Aadd(aPriCpos , { 5  , xZBT_+"VUNIT"} )
	Aadd(aPriCpos , { 6  , xZBT_+"TOTAL"  } )
	Aadd(aPriCpos , { 7  , xZBT_+"NOTA"  } )
	Aadd(aPriCpos , { 8  , xZBT_+"SERIE"  } )
	Aadd(aPriCpos , { 9  , xZBT_+"CLIFOR"  } )
	Aadd(aPriCpos , { 10 , xZBT_+"LOJA"  } )
	Aadd(aPriCpos , { 11 , xZBT_+"TIPOFO"  } )


Elseif cTab == "SF1"

	cCposNao +=  "'" 	
	cCposNao += "F1_FILIAL"
	cCposNao += "/F1_HISTRET"
	cCposNao += "'"
	
Elseif cTab == "SD1"

	cCposNao +=  "'" 	
	cCposNao += "D1_FILIAL"
	//cCposNao += "/F1_HISTRET"
	cCposNao += "'" 
	
Endif

For fr := 1 to Len(aPriCpos)
	cCpo := aPriCpos[fr,2]
	
	DbSelectArea("SX3")
	DbSetOrder(2)
	If DbSeek(cCpo)
	
		If SX3->X3_CAMPO <> FieldGet(FieldPos(cTab+ "_FILIAL" )) .AND. SX3->X3_CONTEXT <> "V"
			noBrw++
					Aadd( aHeader, {SX3->X3_TITULO,;
					 				Alltrim(SX3->X3_CAMPO),;
					 				SX3->X3_PICTURE,;
					 				SX3->X3_TAMANHO,;
					 				SX3->X3_DECIMAL,;
					 				SX3->X3_VALID,;
					 				SX3->X3_USADO,;
					 				SX3->X3_TIPO,;
					 				SX3->X3_F3,;
					 				SX3->X3_CONTEXT,;
					 				SX3->X3_CBOX,;
					 				SX3->X3_RELACAO,;
					 				SX3->X3_WHEN,;
					 				SX3->X3_VISUAL;
					 				} )
			If cTab == xZBZ				
				Aadd(aCposZBZ, Alltrim(SX3->X3_CAMPO))
			Elseif cTab == xZBT                      
			 	Aadd(aCposZBT, Alltrim(SX3->X3_CAMPO))
			Elseif cTab == "SF1" 
				IF !(Alltrim(SX3->X3_TIPO)=="M")                      
			 		Aadd(aCposSF1, Alltrim(SX3->X3_CAMPO)) 
				ENDIF
			Elseif cTab == "SD1"                      
		 		Aadd(aCposSD1, Alltrim(SX3->X3_CAMPO))
			Endif
					 				
		Endif
	Endif
Next


DbSelectArea("SX3")
DbSetOrder(1)
//MsSeek(xZBZ)
MsSeek(cTab)
//While !Eof() .And. Alltrim(SX3->X3_ARQUIVO) == Alltrim(xZBZ)
While !Eof() .And. Alltrim(SX3->X3_ARQUIVO) == Alltrim(cTab)
	If SX3->X3_CONTEXT <> "V"
	
		If !Alltrim(SX3->X3_CAMPO) $ cCposNao
		
			nPos := aScan(aHeader,{|x| Alltrim(x[2]) == Alltrim(SX3->X3_CAMPO) })	
			If nPos == 0
					noBrw++
					Aadd( aHeader, {SX3->X3_TITULO,;
					 				Alltrim(SX3->X3_CAMPO),;
					 				SX3->X3_PICTURE,;
					 				SX3->X3_TAMANHO,;
					 				SX3->X3_DECIMAL,;
					 				SX3->X3_VALID,;
					 				SX3->X3_USADO,;
					 				SX3->X3_TIPO,;
					 				SX3->X3_F3,;
					 				SX3->X3_CONTEXT,;
					 				SX3->X3_CBOX,;
					 				SX3->X3_RELACAO,;
					 				SX3->X3_WHEN,;
					 				SX3->X3_VISUAL;
					 				} )
					 				
			 	If cTab == xZBZ				
					Aadd(aCposZBZ, Alltrim(SX3->X3_CAMPO))
				Elseif cTab == xZBT                      
				 	Aadd(aCposZBT, Alltrim(SX3->X3_CAMPO))
				Elseif cTab == "SF1" 
					IF !(Alltrim(SX3->X3_TIPO)=="M")                      
				 		Aadd(aCposSF1, Alltrim(SX3->X3_CAMPO)) 
					ENDIF
				Elseif cTab == "SD1"                      
			 		Aadd(aCposSD1, Alltrim(SX3->X3_CAMPO))
				Endif					
					
			Endif //nPos == 0				
		Endif
	Endif
	dbSkip()
Enddo


Return

//--------------------------------------------------//
//Monta o cabeçalho das colunas getdados dos totais
//--------------------------------------------------//
Static Function _fHeaderC(aHeader,noBrw,cTab)

Local cCposNao := ""
Local aPriCpos := {}
Local fr	   := 0

aCposZBZ := {}
aCposZBT := {}
aCposSF1 := {}
aCposSD1 := {}

If cTab == xZBZ
	cCposNao +=  "'" 
	cCposNao += xZBZ_+ "FILIAL"
	cCposNao += "/" + xZBZ_+ "XML"
	cCposNao += "/" + xZBZ_+ "OBS" 
	cCposNao += "/" + xZBZ_+ "DTMAIL"
	cCposNao += "/" + xZBZ_+ "PDF"
	cCposNao += "/" + xZBZ_+ "XMLCAN"
	cCposNao += "/" + xZBZ_+ "XMLRES"
	cCposNao += "/" + xZBZ_+ "CONDPG"
	cCposNao += "/" + xZBZ_+ "OBSDES"
	cCposNao += "/" + xZBZ_+ "ICOMPL"
	cCposNao += "'" 	
	
	Aadd(aPriCpos , { 1  , xZBZ_+"VLBRUT"  } )
	Aadd(aPriCpos , { 2  , xZBZ_+"VLLIQ"  } )
	

Elseif cTab == xZBT 

	cCposNao +=  "'" 	
	cCposNao += xZBT_+ "FILIAL"
	cCposNao += "'" 
	
	Aadd(aPriCpos , { 1  , xZBT_+"ITEM"  } )
	Aadd(aPriCpos , { 2  , xZBT_+"PRODUT"  } )
	Aadd(aPriCpos , { 3  , xZBT_+"DESCRI"} )
	Aadd(aPriCpos , { 4  , xZBT_+"QUANT"} ) 
	Aadd(aPriCpos , { 5  , xZBT_+"VUNIT"} )
	Aadd(aPriCpos , { 6  , xZBT_+"TOTAL"  } )
	Aadd(aPriCpos , { 7  , xZBT_+"NOTA"  } )
	Aadd(aPriCpos , { 8  , xZBT_+"SERIE"  } )
	Aadd(aPriCpos , { 9  , xZBT_+"CLIFOR"  } )
	Aadd(aPriCpos , { 10 , xZBT_+"LOJA"  } )
	Aadd(aPriCpos , { 11 , xZBT_+"TIPOFO"  } )
	Aadd(aPriCpos , { 12 , xZBT_+"DEPARA"  } )


Elseif cTab == "SF1"

	cCposNao +=  "'" 	
	cCposNao += "F1_FILIAL"
	cCposNao += "/F1_HISTRET"
	cCposNao += "'"
	
	Aadd(aPriCpos , { 1  , "F1_VALBRUT"  } )
	Aadd(aPriCpos , { 2  , "F1_VALMERC"  } )
	
Elseif cTab == "SD1"

	cCposNao +=  "'" 	
	cCposNao += "D1_FILIAL"
	//cCposNao += "/F1_HISTRET"
	cCposNao += "'" 
	
Endif

For fr := 1 to Len(aPriCpos)
	cCpo := aPriCpos[fr,2]
	
	DbSelectArea("SX3")
	DbSetOrder(2)
	If DbSeek(cCpo)
	
		If SX3->X3_CAMPO <> FieldGet(FieldPos(cTab+ "_FILIAL" )) .AND. SX3->X3_CONTEXT <> "V"
			noBrw++
					Aadd( aHeader, {SX3->X3_TITULO,;
					 				Alltrim(SX3->X3_CAMPO),;
					 				SX3->X3_PICTURE,;
					 				SX3->X3_TAMANHO,;
					 				SX3->X3_DECIMAL,;
					 				SX3->X3_VALID,;
					 				SX3->X3_USADO,;
					 				SX3->X3_TIPO,;
					 				SX3->X3_F3,;
					 				SX3->X3_CONTEXT,;
					 				SX3->X3_CBOX,;
					 				SX3->X3_RELACAO,;
					 				SX3->X3_WHEN,;
					 				SX3->X3_VISUAL;
					 				} )
			If cTab == xZBZ				
				Aadd(aCposZBZ, Alltrim(SX3->X3_CAMPO))
			Elseif cTab == xZBT                      
			 	Aadd(aCposZBT, Alltrim(SX3->X3_CAMPO))
			Elseif cTab == "SF1" 
				IF !(Alltrim(SX3->X3_TIPO)=="M")                      
			 		Aadd(aCposSF1, Alltrim(SX3->X3_CAMPO))
				ENDIF	  
			Elseif cTab == "SD1"                      
		 		Aadd(aCposSD1, Alltrim(SX3->X3_CAMPO))
			Endif
					 				
		Endif
	Endif
Next

Return 

//-------------------------------------------------------//
//Monta o cabeçalho das colunas getdados - itens e qtdes 
//-------------------------------------------------------//
Static Function _fHeaderQ(aHeader,noBrw,cTab)

Local cCposNao := "" 
Local cCpo     := ""
Local aPriCpos := {}
Local fr	   := 0

aCposZBZ := {}
aCposZBT := {}
aCposSF1 := {}
aCposSD1 := {} 
aCposQX  := {}

If cTab == xZBT 

	cCposNao +=  "'" 	
	cCposNao += xZBT_+ "FILIAL"
	cCposNao += "'" 
	
	Aadd(aPriCpos , { 1  , xZBT_+"ITEM"  } )
	Aadd(aPriCpos , { 2  , xZBT_+"PRODUT"  } )
	Aadd(aPriCpos , { 3  , xZBT_+"DESCRI"} )
	Aadd(aPriCpos , { 4  , xZBT_+"QUANT"} ) 
	//Aadd(aPriCpos , { 5  , xZBT_+"DEPARA"} ) 


Elseif cTab == "SD1"

	cCposNao +=  "'" 	
	cCposNao += "D1_FILIAL"
	//cCposNao += "/F1_HISTRET"
	cCposNao += "'"
	
	Aadd(aPriCpos , { 1  , "D1_ITEM"  	} ) 
	Aadd(aPriCpos , { 2  , "D1_COD"   	} )
	Aadd(aPriCpos , { 3  , "B1_DESC"  	} )
	Aadd(aPriCpos , { 4  , "D1_QUANT" 	} )  
	Aadd(aPriCpos , { 5  , "D1_PEDIDO" 	} )  
	Aadd(aPriCpos , { 6  , "D1_ITEMPC" 	} )  
	
Elseif Empty(cTab)

	Aadd(aPriCpos , { 1  , xZBT_+"ITEM"  			} )
	Aadd(aPriCpos , { 2  , xZBT_+"PRODUT"  			} )
	Aadd(aPriCpos , { 3  , xZBT_+"DESCRI"			} )
	Aadd(aPriCpos , { 4  , xZBT_+"QUANT"			} ) 
	Aadd(aPriCpos , { 5  , "SEPARADOR"  , ""                , "@X"              , 4 , 0 , "C"	} ) 
	Aadd(aPriCpos , { 6  , "_D1QUANT"	, "Qtde NF"			, "@E 999,999.9999" , 13, 4 , "N" 	} )  	
	Aadd(aPriCpos , { 7  , "_D1ITEM"	, "Item NF"     	, "@X" 				, 4 , 0 , "C"	} ) 
	Aadd(aPriCpos , { 8  , "_D1COD" 	, "Produto NF"  	, "@!" 				, 15, 0 , "C"  	} )
	Aadd(aPriCpos , { 9  , "_B1DESC"	, "Desc. Prod NF" 	, "@!" 				, 30, 0 , "C" 	} )
	Aadd(aPriCpos , { 10  , xZBT_+"DEPARA"													} ) 
	

Endif

For fr := 1 to Len(aPriCpos)
	cCpo     := aPriCpos[fr,2]
		
	DbSelectArea("SX3")
	DbSetOrder(2)
	If DbSeek(cCpo)
	
		If SX3->X3_CAMPO <> FieldGet(FieldPos(cTab+ "_FILIAL" )) .AND. SX3->X3_CONTEXT <> "V"
			noBrw++
					Aadd( aHeader, {SX3->X3_TITULO,;
					 				Alltrim(SX3->X3_CAMPO),;
					 				SX3->X3_PICTURE,;
					 				SX3->X3_TAMANHO,;
					 				SX3->X3_DECIMAL,;
					 				SX3->X3_VALID,;
					 				SX3->X3_USADO,;
					 				SX3->X3_TIPO,;
					 				SX3->X3_F3,;
					 				SX3->X3_CONTEXT,;
					 				SX3->X3_CBOX,;
					 				SX3->X3_RELACAO,;
					 				SX3->X3_WHEN,;
					 				SX3->X3_VISUAL;
					 				} )
			If cTab == xZBZ				
				Aadd(aCposZBZ, Alltrim(SX3->X3_CAMPO))
			Elseif cTab == xZBT                      
			 	Aadd(aCposZBT, Alltrim(SX3->X3_CAMPO))
			Elseif cTab == "SF1"  
				IF !(Alltrim(SX3->X3_TIPO)=="M")                     
			 		Aadd(aCposSF1, Alltrim(SX3->X3_CAMPO))
				ENDIF	  
			Elseif cTab == "SD1"                      
		 		Aadd(aCposSD1, Alltrim(SX3->X3_CAMPO))
			Elseif Empty(cTab) 		
				Aadd(aCposQX, Alltrim(SX3->X3_CAMPO))			
			Endif
					 				
		Endif 
		
	Elseif !DbSeek(cCpo) .and. Empty(cTab) //se não achou o campo 
	
		noBrw++ 
			/*
			Aadd(aPriCpos , { 5  , "D1ITEM"  } ) 
			Aadd(aPriCpos , { 6  , "D1COD"   } )
			Aadd(aPriCpos , { 7  , "B1DESC"  } )
			Aadd(aPriCpos , { 8  , "D1QUANT" } )  
			*/
			

		Aadd(aHeader, {;
		aPriCpos[fr,3],;		//X3Titulo()
		cCpo,;  				//X3_CAMPO
		aPriCpos[fr,4],;		//X3_PICTURE
		aPriCpos[fr,5],;		//X3_TAMANHO
		aPriCpos[fr,6],;		//X3_DECIMAL
		"",;			   		//X3_VALID
		"",;		   			//X3_USADO
		aPriCpos[fr,7],;		//X3_TIPO
		"",;					//X3_F3
		"R",;					//X3_CONTEXT
		"",;					//X3_CBOX
		"",;					//X3_RELACAO
		""})					//X3_WHEN 
		
		Aadd(aCposQX, Alltrim(cCpo))	
	
	
	Endif
Next

Return 


//-------------------------------------------------------//
//Monta o cabeçalho das colunas getdados - itens e qtdes 
//-------------------------------------------------------//
Static Function _fHeaderV(aHeader,noBrw,cTab,cImp)

Local cCposNao := "" 
Local cCpo     := ""
Local aPriCpos := {}
Local fr	   := 0

aCposZBZ := {}
aCposZBT := {}
aCposSF1 := {}
aCposSD1 := {} 
aCposQX  := {}

If cTab == xZBT 

	cCposNao +=  "'" 	
	cCposNao += xZBT_+ "FILIAL"
	cCposNao += "'" 
	
	Aadd(aPriCpos , { 1  , xZBT_+"ITEM"  	} )
	Aadd(aPriCpos , { 2  , xZBT_+"PRODUT"  	} )
	Aadd(aPriCpos , { 3  , xZBT_+"DESCRI"	} )
	//Aadd(aPriCpos , { 4  , xZBT_+"VUNIT"} ) 
	//Aadd(aPriCpos , { 5  , xZBT_+"QUANT"} ) 
	
	If cImp <> Nil
		If cImp == "ICM"
			Aadd(aPriCpos , { 4  , xZBT_+"ICMVAL"} )
		Endif
		
		If cImp == "ST"
			Aadd(aPriCpos , { 4  , xZBT_+"STVALO"} ) //NÃO TEM CAMPO ICM ST POR ITEM SÓ NO CABEÇALHO
		Endif
		
		If cImp == "IPI"
			Aadd(aPriCpos , { 4  , xZBT_+"IPIVAL"} )
		Endif
		
		If cImp == "PIS"
			Aadd(aPriCpos , { 4  , xZBT_+"PISVAL"} )
		Endif
		
		If cImp == "COF"
			Aadd(aPriCpos , { 4  , xZBT_+"COFVAL"} )
		Endif 
		
		If cImp == "IN"    //inss
			Aadd(aPriCpos , { 4  , xZBT_+"INSVAL"} )
		Endif
		
		If cImp == "IS"    //iss
			Aadd(aPriCpos , { 4  , xZBT_+"ISSVAL"} )
		Endif	
		
		If cImp == "IR"    //ir
			Aadd(aPriCpos , { 4  , xZBT_+"IRRVAL"} )
		Endif
		
		If cImp == "CS"    //inss
			Aadd(aPriCpos , { 4  , xZBT_+"CSLVAL"} )
		Endif
		                  
	Else
		Aadd(aPriCpos , { 4  , xZBT_+"VUNIT"} ) 
		
	Endif 


Elseif cTab == "SD1"

	cCposNao +=  "'" 	
	cCposNao += "D1_FILIAL"
	cCposNao += "'"
	
	Aadd(aPriCpos , { 1  , "D1_ITEM"  } ) 
	Aadd(aPriCpos , { 2  , "D1_COD"   } )
	Aadd(aPriCpos , { 3  , "B1_DESC"  } )
	
	If cImp <> Nil
		If cImp == "ICM"			
			Aadd(aPriCpos , { 4  , "D1_VALICM"	} )
		Endif
		
		If cImp == "ST"			
			Aadd(aPriCpos , { 4  , "D1_ICMSRET"	} )
		Endi
		
		If cImp == "IPI"
			Aadd(aPriCpos , { 4  , "D1_VALIPI"	} )
		Endif
		
		If cImp == "PIS"
			Aadd(aPriCpos , { 4  , "D1_VALPIS"	} )
		Endif
		
		If cImp == "COF"
			Aadd(aPriCpos , { 4  , "D1_VALCOF"	} )
		Endif
		
		If cImp == "IN"    //inss
			Aadd(aPriCpos , { 4  , "D1_VALINS"} )
		Endif
		
		If cImp == "IS"    //iss
			Aadd(aPriCpos , { 4  , "D1_VALISS"} )
		Endif
		
		If cImp == "IR"    //inss
			Aadd(aPriCpos , { 4  , "D1_VALIRR"} )
		Endif	
		
		If cImp == "CS"    //inss
			Aadd(aPriCpos , { 4  , "D1_VALCSL"} )
		Endif
		                  
	Else
		Aadd(aPriCpos , { 4  , "D1_VUNIT" 		} ) 
	Endif
	
	Aadd(aPriCpos , { 5  , "D1_PEDIDO" 			} )  
	Aadd(aPriCpos , { 6  , "D1_ITEMPC" 			} )   
 
	
Elseif Empty(cTab)

	Aadd(aPriCpos , { 1  , xZBT_+"ITEM"  			} )
	Aadd(aPriCpos , { 2  , xZBT_+"PRODUT"  			} )
	Aadd(aPriCpos , { 3  , xZBT_+"DESCRI"			} )
			
	If cImp <> Nil
	
		If cImp == "ICM"
			Aadd(aPriCpos , { 4  , xZBT_+"ICMVAL"														} ) 
			Aadd(aPriCpos , { 5  , "SEPARADOR"  , ""                , "@X"              , 4 , 0 , "C"	} ) 
			Aadd(aPriCpos , { 6  , "_D1VALICM" , "Valor ICM NF" , "@E 999,999.9999"	, 13, 4 , "N" 		} )
		Endif
		
		If cImp == "ST"
			Aadd(aPriCpos , { 4  , xZBT_+"STVALO"														} )  
			Aadd(aPriCpos , { 5  , "SEPARADOR"  , ""                , "@X"              , 4 , 0 , "C"	} ) 
			Aadd(aPriCpos , { 6  , "_D1ICMST" , "Valor ICM ST NF" , "@E 999,999.9999"	, 13, 4 , "N" 	} )
		Endif
		
		If cImp == "IPI"
			Aadd(aPriCpos , { 4  , xZBT_+"IPIVAL"														} )
			Aadd(aPriCpos , { 5  , "SEPARADOR"  , ""                , "@X"              , 4 , 0 , "C"	} )  
			Aadd(aPriCpos , { 6  , "_D1VALIPI",  "Valor IPI NF", "@E 999,999.9999" 	, 13, 4 , "N" 		} )
		Endif
		
		If cImp == "PIS"
			Aadd(aPriCpos , { 4  , xZBT_+"PISVAL"												   		} ) 
			Aadd(aPriCpos , { 5  , "SEPARADOR"  , ""                , "@X"              , 4 , 0 , "C"	} ) 
			Aadd(aPriCpos , { 6  , "_D1VALPIS", "Valor PIS NF" , "@E 999,999.9999" 	, 13, 4 , "N" 		} )
		Endif
		
		If cImp == "COF" 
			Aadd(aPriCpos , { 4  , xZBT_+"COFVAL"		   												} ) 
			Aadd(aPriCpos , { 5  , "SEPARADOR"  , ""                , "@X"              , 4 , 0 , "C"	} ) 
			Aadd(aPriCpos , { 6  , "_D1VALCOF", "Valor COFINS NF" , "@E 999,999.9999" 	, 13, 4 , "N"	} )
		Endif 
		
		If cImp == "IN" 
			Aadd(aPriCpos , { 4  , xZBT_+"INSVAL"		   													} ) 
			Aadd(aPriCpos , { 5  , "SEPARADOR"  , ""                , "@X"              	, 4 , 0 , "C"	} ) 
			Aadd(aPriCpos , { 6  , "_D1VALINS", "Valor INSS NF" 	, "@E 999,999.9999" 	, 13, 4 , "N"	} )
		Endif
		
		If cImp == "IS" 
			Aadd(aPriCpos , { 4  , xZBT_+"ISSVAL"		   													} ) 
			Aadd(aPriCpos , { 5  , "SEPARADOR"  , ""                , "@X"              	, 4 , 0 , "C"	} ) 
			Aadd(aPriCpos , { 6  , "_D1VALISS", "Valor ISS NF" 		, "@E 999,999.9999" 	, 13, 4 , "N"	} )
		Endif
		
		If cImp == "CS" 
			Aadd(aPriCpos , { 4  , xZBT_+"CSLVAL"		   													} ) 
			Aadd(aPriCpos , { 5  , "SEPARADOR"  , ""                , "@X"              	, 4 , 0 , "C"	} ) 
			Aadd(aPriCpos , { 6  , "_D1VALCSL", "Valor CSLLS NF" 	, "@E 999,999.9999" 	, 13, 4 , "N"	} )
		Endif 
		
		If cImp == "IR" 
			Aadd(aPriCpos , { 4  , xZBT_+"IRRVAL"		   													} ) 
			Aadd(aPriCpos , { 5  , "SEPARADOR"  , ""                , "@X"              	, 4 , 0 , "C"	} ) 
			Aadd(aPriCpos , { 6  , "_D1VALIR"	, "Valor IR NF" 	, "@E 999,999.9999" 	, 13, 4 , "N"	} )
		Endif
	
	Else
		Aadd(aPriCpos , { 4  , xZBT_+"VUNIT"														} ) 
		Aadd(aPriCpos , { 5  , "SEPARADOR"  , ""                , "@X"              , 4 , 0 , "C"	} ) 	
		Aadd(aPriCpos , { 6  , "_D1VUNIT"   , "Vlr.Unit NF"	, "@E 999,999.9999" , 13, 4 , "N" 		} )  	
	
	Endif 
	
	Aadd(aPriCpos , { 7  , "_D1ITEM"	, "Item NF"     , "@X" 				, 4 , 0 , "C"	} ) 
	Aadd(aPriCpos , { 8  , "_D1COD" 	, "Produto NF"  , "@!" 				, 15, 0 , "C"  	} )
	Aadd(aPriCpos , { 9  , "_B1DESC"	, "DescProd NF" , "@!" 				, 30, 0 , "C" 	} ) 
	Aadd(aPriCpos , { 10  , xZBT_+"DEPARA"													} ) 	

Endif

For fr := 1 to Len(aPriCpos)
	cCpo     := aPriCpos[fr,2]
		
	DbSelectArea("SX3")
	DbSetOrder(2)
	If DbSeek(cCpo)
	
		If SX3->X3_CAMPO <> FieldGet(FieldPos(cTab+ "_FILIAL" )) .AND. SX3->X3_CONTEXT <> "V"
			noBrw++
					Aadd( aHeader, {SX3->X3_TITULO,;
					 				Alltrim(SX3->X3_CAMPO),;
					 				SX3->X3_PICTURE,;
					 				SX3->X3_TAMANHO,;
					 				SX3->X3_DECIMAL,;
					 				SX3->X3_VALID,;
					 				SX3->X3_USADO,;
					 				SX3->X3_TIPO,;
					 				SX3->X3_F3,;
					 				SX3->X3_CONTEXT,;
					 				SX3->X3_CBOX,;
					 				SX3->X3_RELACAO,;
					 				SX3->X3_WHEN,;
					 				SX3->X3_VISUAL;
					 				} )
			If cTab == xZBZ				
				Aadd(aCposZBZ, Alltrim(SX3->X3_CAMPO))
			Elseif cTab == xZBT                      
			 	Aadd(aCposZBT, Alltrim(SX3->X3_CAMPO))
			Elseif cTab == "SF1" 
				IF !(Alltrim(SX3->X3_TIPO)=="M")                     
			 		Aadd(aCposSF1, Alltrim(SX3->X3_CAMPO)) 
				ENDIF
			Elseif cTab == "SD1"                      
		 		Aadd(aCposSD1, Alltrim(SX3->X3_CAMPO))
			Elseif Empty(cTab) 		
				Aadd(aCposQX, Alltrim(SX3->X3_CAMPO))			
			Endif
					 				
		Endif 
		
	Elseif !DbSeek(cCpo) .and. Empty(cTab) //se não achou o campo 
	
		noBrw++ 					

		Aadd(aHeader, {;
		aPriCpos[fr,3],;		//X3Titulo()
		cCpo,;  				//X3_CAMPO
		aPriCpos[fr,4],;		//X3_PICTURE
		aPriCpos[fr,5],;		//X3_TAMANHO
		aPriCpos[fr,6],;		//X3_DECIMAL
		"",;			   		//X3_VALID
		"",;		   			//X3_USADO
		aPriCpos[fr,7],;		//X3_TIPO
		"",;					//X3_F3
		"R",;					//X3_CONTEXT
		"",;					//X3_CBOX
		"",;					//X3_RELACAO
		""})					//X3_WHEN 
		
		Aadd(aCposQX, Alltrim(cCpo))	
	
	
	Endif
Next

Return 

//MONTAGEM DE CABEÇALHOS 

//---------------------------//
//GERAÇÃO DE MASSA DE DADOS
//---------------------------//

//====================================================================//
//Monta massa de dados para painel CABEÇALHO XML
//====================================================================//
Static Function _fColBrwXM(oGetDados11, aCols11, noBrw11)

	Local nCont  := 0
	Local cQuery:= ""
	Local i		 := 0
    
	cQuery := " SELECT " + CRLF

	cQuery += " R_E_C_N_O_ AS RECZBZ "		+ CRLF
	For i := 1 to Len(aCposZBZ)		
		cQuery += ","+ aCposZBZ[i] + "" + CRLF	
	Next
	
	cQuery += " FROM " + RETSQLNAME(xZBZ) + " "+xZBZ+" "			+ CHR(13) + CHR(10)	 
	
	cQuery += " WHERE ZBZ.D_E_L_E_T_ = '' "							+ CHR(13) + CHR(10)
	
	cQuery += " AND "+xZBZ+"_FILIAL = '" + Alltrim(cFili) + "' "	+ CHR(13) + CHR(10)			
	cQuery += " AND "+xZBZ+"_CODFOR = '" + Alltrim(cFornec) + "' "	+ CHR(13) + CHR(10)		
	cQuery += " AND "+xZBZ+"_LOJFOR = '" + Alltrim(cLoj) + "' "		+ CHR(13) + CHR(10)
		
	cQuery += " AND "+xZBZ+"_NOTA = '" + Alltrim(cNF) + "' "		+ CHR(13) + CHR(10)		
	cQuery += " AND "+xZBZ+"_SERIE = '" + Alltrim(cSerie) + "' "	+ CHR(13) + CHR(10) 
			
	MemoWrite("C:\TEMP\_fColsBrwNF.sql", cQuery)
	
	cQuery := ChangeQuery(cQuery)
	
	If ( SELECT("TRB11") ) > 0
		dbSelectArea("TRB11")
		TRB11->(dbCloseArea())
	EndIf

	TcQuery cQuery Alias "TRB11" New

	TRB11->(dbGoTop())

		aCols11 := {}

	If !TRB11->(EOF())
        
		Do While TRB11->( !EOF() )
			nCont++
			
			Aadd(aCols11,Array(noBrw11 + 1))	
		
			For i := 1 to Len(aCposZBZ)
				If "VLBRUT" $ aCposZBZ[i] .or. "VLLIQ" $ aCposZBZ[i]
					aCols11[nCont][i] := Round( TRB11->&(aCposZBZ[i]) , 2 ) 
				Else
					aCols11[nCont][i] := STRESTH1( aCposZBZ[i],TRB11->&(aCposZBZ[i]) )
					//aCols11[nCont][i] := TRB11->&(aCposZBZ[i]) 
				Endif			
			Next

			aCols11[nCont][noBrw11 + 1] := .F.
			
			TRB11->(DbSkip())
		Enddo     
	   
		
	EndIf

	//Setar array do aCols do Objeto.
	oGetDados11:SetArray(aCols11,.T.)

	//Atualizo as informações no grid
	oGetDados11:Refresh()

Return Nil

//====================================================================//
//Monta massa de dados para painel CABEÇALHO NF
//====================================================================//
Static Function _fColBrwf1(oGetDadosf1, aColsf1, noBrwf1)

	Local nCont  := 0
	Local cQuery:= ""
	Local i		 := 0
    
	cQuery := " SELECT " + CRLF

	cQuery += " R_E_C_N_O_ AS RECSF1 "					+ CRLF
	For i := 1 to Len(aCposSF1)
		cQuery += ","+ aCposSF1[i] + "" //ZBZ_NOTA
	Next
	
	cQuery += " FROM " + RETSQLNAME("SF1") + " SF1 "			+ CHR(13) + CHR(10)	 
	
	cQuery += " WHERE SF1.D_E_L_E_T_ = '' "						+ CHR(13) + CHR(10)
	
	cQuery += " AND F1_FILIAL = '" + Alltrim(cFili) + "' "		+ CHR(13) + CHR(10)			
	cQuery += " AND F1_FORNECE = '" + Alltrim(cFornec) + "' "	+ CHR(13) + CHR(10)		
	cQuery += " AND F1_LOJA = '" + Alltrim(cLoj) + "' "			+ CHR(13) + CHR(10)
		
	cQuery += " AND F1_DOC = '" + Alltrim(cNF) + "' "			+ CHR(13) + CHR(10)		
	cQuery += " AND F1_SERIE = '" + Alltrim(cSerie) + "' "		+ CHR(13) + CHR(10)
			
	MemoWrite("C:\TEMP\_fColsBrwF1.sql", cQuery)
	
	cQuery := ChangeQuery(cQuery)
	
	If ( SELECT("TRB11") ) > 0
		dbSelectArea("TRB11")
		TRB11->(dbCloseArea())
	EndIf

	TcQuery cQuery Alias "TRB11" New

	TRB11->(dbGoTop())

		aColsf1 := {}

	If !TRB11->(EOF())
        
		Do While TRB11->( !EOF() )
			nCont++
			
			Aadd(aColsf1,Array(noBrwf1 + 1))	
		
			For i := 1 to Len(aCposSF1)
				aColsf1[nCont][i] := STRESTH1( aCposSF1[i],TRB11->&(aCposSF1[i]) )		
			Next

			aColsf1[nCont][noBrwf1 + 1] := .F.
			
			TRB11->(DbSkip())
		Enddo     
	   
		
	EndIf

	//Setar array do aCols do Objeto.
	oGetDadosf1:SetArray(aColsf1,.T.)

	//Atualizo as informações no grid
	oGetDadosf1:Refresh()

Return Nil


//====================================================================//
//Monta massa de dados para painel ITENS XML
//====================================================================//
Static Function _fColBrwit(oGetDados12, aCols12, noBrw, cTab, cTip, lTemDiv) //_fColBrwit(oGetDadosQX, aColsQX, noBrwQX, "ZBT","Q",lTemDiv)

	Local nCont  	:= 0
	Local cQuery 	:= ""
	//Local xDesc		:= ""
	Local xProd  	:= ""
	Local xItem		:= ""
	Local i		 	:= 0 	
	Local xQtX		:= 0
	Local xVlX		:= 0

	Local aProdint 	:= {}   
	
    If cTab == Nil
		cQuery := " SELECT " + CRLF
	
		cQuery += " R_E_C_N_O_ AS RECZBT "					+ CRLF
		
		For i := 1 to Len(aCposZBT)
			cQuery += ","+ aCposZBT[i] + "" //ZBZ_NOTA
		Next
		
		cQuery += " FROM " + RETSQLNAME(xZBT) + " "+xZBT+" "			+ CHR(13) + CHR(10)	 
		
		cQuery += " WHERE ZBT.D_E_L_E_T_ = '' "							+ CHR(13) + CHR(10) 
		cQuery += " AND "+xZBT+"_FILIAL = '" + Alltrim(cFili) + "' "	+ CHR(13) + CHR(10)			
		cQuery += " AND "+xZBT+"_NOTA = '" + Alltrim(cNF) + "' "		+ CHR(13) + CHR(10)		
		cQuery += " AND "+xZBT+"_SERIE = '" + Alltrim(cSerie) + "' "	+ CHR(13) + CHR(10) 
		cQuery += " ORDER BY " + xZBT + "_ITEM " 
		
		MemoWrite("C:\TEMP\_fColsBrwIT.sql", cQuery)
		
	Else 
		
		cQuery := " SELECT " + CRLF
	
		cQuery += " R_E_C_N_O_ AS RECZBT "					+ CRLF
		
		For i := 1 to Len(aCposQX)
			If !"_D1" $ aCposQX[i] .and. !"_B1" $ aCposQX[i] .and. !"SEPARADOR" $ aCposQX[i]
				cQuery += ","+ aCposQX[i] + "" //ZBZ_NOTA
			Else
				cQuery += ", '' AS " + aCposQX[i] //seleciona vazio para povoar depois
			Endif 
		Next
		
		cQuery += " FROM " + RETSQLNAME(xZBT) + " "+xZBT+" "			+ CHR(13) + CHR(10)	 
		
		cQuery += " WHERE ZBT.D_E_L_E_T_ = '' "							+ CHR(13) + CHR(10) 
		cQuery += " AND "+xZBT+"_FILIAL = '" + Alltrim(cFili) + "' "	+ CHR(13) + CHR(10)			
		cQuery += " AND "+xZBT+"_NOTA = '" + Alltrim(cNF) + "' "		+ CHR(13) + CHR(10)		
		cQuery += " AND "+xZBT+"_SERIE = '" + Alltrim(cSerie) + "' "	+ CHR(13) + CHR(10) 
		cQuery += " ORDER BY " + xZBT + "_ITEM " 
		
		MemoWrite("C:\TEMP\_fColsBrwCOMPx.sql", cQuery)
	
	Endif		
	
	
	If ( SELECT("TRB11") ) > 0
		dbSelectArea("TRB11")
		TRB11->(dbCloseArea())
	EndIf
	
	cQuery := ChangeQuery(cQuery)

	TcQuery cQuery Alias "TRB11" New

	TRB11->(dbGoTop())

		aCols12 := {}

	If !TRB11->(EOF())
        If cTab == Nil
			Do While TRB11->( !EOF() )
				nCont++
				
				Aadd(aCols12,Array(noBrw + 1))	
			
				For i := 1 to Len(aCposZBT)
					//aCols12[nCont][i] := TRB11->&(aCposZBT[i])
					aCols12[nCont][i] := STRESTH1( aCposZBT[i],TRB11->&(aCposZBT[i]) )			
				Next
	
				aCols12[nCont][noBrw + 1] := .F.
				
				TRB11->(DbSkip())
			Enddo
			
			//Setar array do aCols do Objeto.
			oGetDados12:SetArray(aCols12,.T.)
		
			//Atualizo as informações no grid
			oGetDados12:Refresh()
				
		Else
		    nCont := 0
			Do While TRB11->( !EOF() )
				nCont++
				
				Aadd(aColsQX,Array(noBrw + 1))	
			
				For i := 1 to Len(aCposQX)
					aColsQX[nCont][i] := TRB11->&(aCposQX[i])
					//aCols12[nCont][i] := STRESTH1( aCposQX[i],TRB11->&(aCposQX[i]) )			
				Next
				
				xProd			:= aColsQX[nCont,Ascan(aCposQX,xZBT+"_PRODUT")]
				cProdinterno    := ""
				//If lTemDiv
					//tirei a amarração porque qdo desmembra não traz correto, melhor pegar pelo item da nf
					cProdinterno    := aColsQX[nCont,Ascan(aCposQX,xZBT+"_DEPARA")]  
					If Empty(cProdinterno)
						aProdInt        := fTemAmarr(cFornec,cLoj,xProd,"I")
						cProdinterno    := aProdInt[1] 
					Endif                                       
					
				//se não tem divergência, pode amarrar pelo item
				//Else
					xItem			:= aColsQX[nCont,Ascan(aCposQX,xZBT+"_ITEM")]
				
				//Endif  
				//xDesc           := Posicione("SB1",1,xFilial("SB1") + Alltrim(cProdinterno),"B1_DESC")
				
				//amarra direto pelo item
				If !lTemDiv
					
					cQuery := " SELECT D1_ITEM, D1_COD, D1_QUANT, D1_VUNIT, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_VALICM, D1_ICMSRET, D1_VALIPI, D1_VALPIS, D1_VALCOF, D1_VALINS, D1_VALISS, D1_VALCSL, D1_VALIRR " + CRLF
					cQuery += " FROM " + Retsqlname("SD1") + " SD1 "		   			+ CRLF
			    	cQuery += " WHERE SD1.D_E_L_E_T_ = '' "							+ CRLF 
					cQuery += " AND D1_FILIAL  = '" 	+ Alltrim(cFili) 	+ "' "		+ CRLF			
					cQuery += " AND D1_DOC     = '" 	+ Alltrim(cNF) 		+ "' "		+ CRLF
					cQuery += " AND D1_SERIE   = '" 	+ Alltrim(cSerie) 	+ "' "		+ CRLF
					cQuery += " AND D1_FORNECE = '" 	+ Alltrim(cFornec) 	+ "' "		+ CRLF
					cQuery += " AND D1_LOJA    = '" 	+ Alltrim(cLoj) 	+ "' "		+ CRLF
					cQuery += " AND D1_ITEM    = '"  	+ Alltrim(xItem) + "' "  + CRLF
					cQuery += " ORDER BY D1_COD, D1_DOC " 
					
					MemoWrite("C:\TEMP\_fColsBrwCOMPQ1.sql", cQuery)
				
				Else
				
					cQuery := " SELECT " + CRLF
					cQuery += " D1_ITEM  , D1_COD, D1_ITEM, D1_QUANT, D1_VUNIT, D1_VALICM , D1_VALIPI, D1_VALPIS, D1_VALCOF, D1_ICMSRET, D1_VALINS, D1_VALISS, D1_VALCSL, D1_VALIRR " + CRLF
					cQuery += "  ,ISNULL( (SELECT TOP 1 " + xZBT_+"ITEM   FROM " + RetSqlName(xZBT) + "  ZBT WHERE " + xZBT_+"ITEM = D1_ITEM  AND ZBT.D_E_L_E_T_ <> '*' ),'') ZBT_ITEM " + CRLF
					cQuery += "  ,ISNULL( (SELECT TOP 1 " + xZBT_+"PRODUT FROM " + RetSqlName(xZBT) + "  ZBT WHERE ("+ xZBT_+"ITEM = D1_ITEM OR " + xZBT_+"DEPARA = D1_COD)  AND ZBT.D_E_L_E_T_ <> '*' ),'') ZBT_PRODUT " + CRLF
					cQuery += "  ,ISNULL( (SELECT "       + xZBT_+"DEPARA FROM " + RetSqlName(xZBT) + "  ZBT WHERE " + xZBT_+"DEPARA = D1_COD AND ZBT.D_E_L_E_T_ <> '*' ),'') ZBT_DEPARA " + CRLF
					
					cQuery += " FROM " + RetSqlName("SD1") + " SD1  " 	+ CRLF
					cQuery += " WHERE SD1.D_E_L_E_T_ = ''  " 			+ CRLF
					cQuery += "  AND D1_FILIAL = '" + Alltrim(cFili) + "' " + CRLF
					cQuery += "  AND D1_DOC    = '" + Alltrim(cNF)   + "' " + CRLF
					cQuery += "  AND D1_SERIE  = '" + Alltrim(cSerie)+ "' " + CRLF
					cQuery += "  ORDER BY 1    " + CRLF 
					
					MemoWrite("C:\TEMP\_fColsBrwCOMPQ2.sql", cQuery)
				
				Endif 
					           		
	   			If ( SELECT("TRBD1") ) > 0
					dbSelectArea("TRBD1")
					TRBD1->(dbCloseArea())
				EndIf
				
				cQuery := ChangeQuery(cQuery)
			
				TcQuery cQuery Alias "TRBD1" New
			
				TRBD1->(dbGoTop())
                If !TRBD1->(EOF())
                	While !TRBD1->(EOF())
						//guarda os valores
					    xItX   := aColsQX[nCont,Ascan(aCposQX,xZBT+"_ITEM")]
					    xProdX := aColsQX[nCont,Ascan(aCposQX,xZBT+"_PRODUT")]
					    xDescX := aColsQX[nCont,Ascan(aCposQX,xZBT+"_DESCRI")]
				    
					    If cTip == "Q"
					    	xQtX   := aColsQX[nCont,Ascan(aCposQX,xZBT+"_QUANT")]
					    Elseif cTip == "V"
					    	xVlX   := aColsQX[nCont,Ascan(aCposQX,xZBT+"_VUNIT")] 
					    Elseif cTip == "ICM"
					    	xVlX   := aColsQX[nCont,Ascan(aCposQX,xZBT+"_ICMVAL")] 
					    Endif
					    
					    
					    //povoa o acols "COMPARATIVO"
						If !lTemDiv
							If !Empty(aColsQX[nCont,Ascan(aCposQX,"_D1ITEM")]) 
								Aadd(aColsQX,Array(noBrw + 1))   //se a posição foi preenchida mas tem mais itens, adiciona nova linha 
								nCont++  
							Endif
					
						
							//se quiser preencher as colunas que ficarão em branco relativo aos dados do xml:
							//If Empty(aColsQX[nCont,Ascan(aCposQX,xZBT+"_ITEM")]) //se abriu nova linha aqui vai tá vazio , então preencho de novo com os valores guardados
								//aColsQX[nCont,Ascan(aCposQX,xZBT+"_ITEM")] 	   := xItX
						     	//aColsQX[nCont,Ascan(aCposQX,xZBT+"_PRODUT")]   := xProdX
						    	//aColsQX[nCont,Ascan(aCposQX,xZBT+"_DESCRI")]   := xDescX
						    	//aColsQX[nCont,Ascan(aCposQX,xZBT+"_QUANT")]    := xQtX
						    	aColsQX[nCont,Ascan(aCposQX,xZBT+"_DEPARA")]   := TRBD1->D1_COD
						  	//Endif
							
							aColsQX[nCont,Ascan(aCposQX,"_D1ITEM")] := TRBD1->D1_ITEM //SD1->D1_ITEM
							aColsQX[nCont,Ascan(aCposQX,"_D1COD")]  := TRBD1->D1_COD  //SD1->D1_COD
							aColsQX[nCont,Ascan(aCposQX,"_B1DESC")] := Posicione("SB1",1,xFilial("SB1") + TRBD1->D1_COD,"B1_DESC") 
							aColsQX[nCont,Ascan(aCposQX,"SEPARADOR")]:= ""
							
							If cTip == "Q"
								aColsQX[nCont,Ascan(aCposQX,"_D1QUANT")]:= TRBD1->D1_QUANT //SD1->D1_QUANT
							Elseif cTip == "V"
								aColsQX[nCont,Ascan(aCposQX,"_D1VUNIT")]:= TRBD1->D1_VUNIT //SD1->D1_VUNIT
							Elseif cTip == "ICM"
								aColsQX[nCont,Ascan(aCposQX,"_D1VALICM")]:= TRBD1->D1_VALICM
							Elseif cTip == "ST"
								aColsQX[nCont,Ascan(aCposQX,"_D1ICMST")]:= TRBD1->D1_ICMSRET
							Elseif cTip == "IPI"
								aColsQX[nCont,Ascan(aCposQX,"_D1VALIPI")]:= TRBD1->D1_VALIPI
							Elseif cTip == "PIS"
								aColsQX[nCont,Ascan(aCposQX,"_D1VALPIS")]:= TRBD1->D1_VALPIS
							Elseif cTip == "COF"
								aColsQX[nCont,Ascan(aCposQX,"_D1VALCOF")]:= TRBD1->D1_VALCOF
							Elseif cTip == "IN"
								aColsQX[nCont,Ascan(aCposQX,"_D1VALINS")]:= TRBD1->D1_VALINS  //inss
							Elseif cTip == "IS"
								aColsQX[nCont,Ascan(aCposQX,"_D1VALISS")]:= TRBD1->D1_VALISS  //iss
							Elseif cTip == "CS"
								aColsQX[nCont,Ascan(aCposQX,"_D1VALCSL")]:= TRBD1->D1_VALCSL  //csll
							Elseif cTip == "IR"
								aColsQX[nCont,Ascan(aCposQX,"_D1VALIR")]:= TRBD1->D1_VALIRR   //ir
							Endif
							
							aColsQX[nCont][noBrw + 1] := .F.
						
						Else
						
							If TRBD1->ZBT_PRODUT == xProd
							
								If !Empty(aColsQX[nCont,Ascan(aCposQX,"_D1ITEM")]) 
									Aadd(aColsQX,Array(noBrw + 1))   //se a posição foi preenchida mas tem mais itens, adiciona nova linha 
									nCont++  
								Endif
									
						    	aColsQX[nCont,Ascan(aCposQX,xZBT+"_DEPARA")]   := TRBD1->D1_COD
							
								aColsQX[nCont,Ascan(aCposQX,"_D1ITEM")] := TRBD1->D1_ITEM //SD1->D1_ITEM
								aColsQX[nCont,Ascan(aCposQX,"_D1COD")]  := TRBD1->D1_COD  //SD1->D1_COD
								aColsQX[nCont,Ascan(aCposQX,"_B1DESC")] := Posicione("SB1",1,xFilial("SB1") + TRBD1->D1_COD,"B1_DESC") 
								
								If cTip == "Q"
									aColsQX[nCont,Ascan(aCposQX,"_D1QUANT")]:= TRBD1->D1_QUANT //SD1->D1_QUANT
								Elseif cTip == "V"
									aColsQX[nCont,Ascan(aCposQX,"_D1VUNIT")]:= TRBD1->D1_VUNIT //SD1->D1_VUNIT
								Elseif cTip == "ICM"
									aColsQX[nCont,Ascan(aCposQX,"_D1VALICM")]:= TRBD1->D1_VALICM
								Elseif cTip == "ST"
									aColsQX[nCont,Ascan(aCposQX,"_D1ICMST")]:= TRBD1->D1_ICMSRET
								Elseif cTip == "IPI"
									aColsQX[nCont,Ascan(aCposQX,"_D1VALIPI")]:= TRBD1->D1_VALIPI
								Elseif cTip == "PIS"
									aColsQX[nCont,Ascan(aCposQX,"_D1VALPIS")]:= TRBD1->D1_VALPIS
								Elseif cTip == "COF"
									aColsQX[nCont,Ascan(aCposQX,"_D1VALCOF")]:= TRBD1->D1_VALCOF
								Elseif cTip == "IN"
									aColsQX[nCont,Ascan(aCposQX,"_D1VALINS")]:= TRBD1->D1_VALINS  //inss
								Elseif cTip == "IS"
									aColsQX[nCont,Ascan(aCposQX,"_D1VALISS")]:= TRBD1->D1_VALISS  //iss
								Elseif cTip == "CS"
									aColsQX[nCont,Ascan(aCposQX,"_D1VALCSL")]:= TRBD1->D1_VALCSL  //csll
								Elseif cTip == "IR"
									aColsQX[nCont,Ascan(aCposQX,"_D1VALIR")]:= TRBD1->D1_VALIRR   //ir
								Endif
								
								aColsQX[nCont,Ascan(aCposQX,"SEPARADOR")]:= ""
								
								aColsQX[nCont][noBrw + 1] := .F.
							
							Endif 
							
						Endif 
						
						TRBD1->(Dbskip())
					 
					Enddo
	
					aColsQX[nCont][noBrw + 1] := .F.
				
				Endif
				TRB11->(DbSkip())
				
			Enddo
			
					
			//Setar array do aCols do Objeto.
			oGetDadosQX:SetArray(aColsQX,.T.)
		
			//Atualizo as informações no grid
			oGetDadosQX:Refresh()		
		
		Endif   
		
	EndIf

	

Return Nil


//====================================================================//
//Monta massa de dados para painel ITENS NF
//====================================================================//
Static Function _fColBrwd1(oGetDadosd1, aColsd1, noBrwd1)

	Local nCont    := 0
	Local cQuery   := ""
	Local i		   := 0 
	Local lInnerB1 := .F.
    
   	cQuery := " SELECT " + CRLF
	
	cQuery += " SD1.R_E_C_N_O_ AS RECSD1 "					+ CRLF
	For i := 1 to Len(aCposSD1)
		cQuery += ","+ aCposSD1[i] + "" 
		 
		If "B1_" $ aCposSD1[i]
			lInnerB1 := .T.		
		Endif
	Next
	
	cQuery += " FROM " + RETSQLNAME("SD1") + " SD1 "			+ CHR(13) + CHR(10)
	If lInnerB1
		cQuery += " INNER JOIN " + RetSqlname("SB1") + " SB1 ON B1_COD = D1_COD AND SB1.D_E_L_E_T_ <> '*' " + CRLF
	Endif	 
	
	cQuery += " WHERE SD1.D_E_L_E_T_ = '' "						+ CHR(13) + CHR(10)
	
	cQuery += " AND D1_FILIAL = '" + Alltrim(cFili) + "' "		+ CHR(13) + CHR(10)			
	cQuery += " AND D1_FORNECE = '" + Alltrim(cFornec) + "' "	+ CHR(13) + CHR(10)		
	cQuery += " AND D1_LOJA = '" + Alltrim(cLoj) + "' "			+ CHR(13) + CHR(10)
		
	cQuery += " AND D1_DOC = '" + Alltrim(cNF) + "' "			+ CHR(13) + CHR(10)		
	cQuery += " AND D1_SERIE = '" + Alltrim(cSerie) + "' "		+ CHR(13) + CHR(10) 
	cQuery += " ORDER BY D1_ITEM "
				
	MemoWrite("C:\TEMP\_fColsBrwD1.sql", cQuery)
		
	cQuery := ChangeQuery(cQuery)
	
	If ( SELECT("TRB11") ) > 0
		dbSelectArea("TRB11")
		TRB11->(dbCloseArea())
	EndIf

	TcQuery cQuery Alias "TRB11" New

	TRB11->(dbGoTop())

		aColsd1 := {}

	If !TRB11->(EOF())
        
		Do While TRB11->( !EOF() )
			nCont++
			
			Aadd(aColsd1,Array(noBrwd1 + 1))	
		
			For i := 1 to Len(aCposSD1)
				aColsd1[nCont][i] := STRESTH1( aCposSD1[i],TRB11->&(aCposSD1[i]) )		
			Next

			aColsd1[nCont][noBrwd1 + 1] := .F.
			
			TRB11->(DbSkip())
		Enddo 	   
		
	EndIf

	//Setar array do aCols do Objeto.
	oGetDadosd1:SetArray(aColsd1,.T.)

	//Atualizo as informações no grid
	oGetDadosd1:Refresh()

Return Nil


//==============================================================//
// GRÁFICOS COMPARATIVOS TOTAIS XML x Entrada
//==============================================================//

//==============================================================//
// Gráfico: Valor de ICMS - XML x Entrada
//==============================================================//
Static Function _fCompI(oPanel) 
	Local nLiIni    := 0
	Local nCoIni    := 0
	Local nLiFim    := 0
	Local nCoFim    := 0
	
	Local nTotIX    := 0
	Local nTotIN	:= 0
	Local nDif		:= 0
	Local cMsgDiv	:= ""
	Local xCor1   
		
	Local _oPanel
	 
	Local lLowered  := .T.
	Local lRaised   := .T. //.T. mostra borda do painel  
	Local lCentered := .F. //.T. mostra o texto do objeto no centro painel
		
	Local aRand		:= {}
	
	oChart09 := FWChartFactory():New(0,0,50,50)
	oChart09:SetOwner(oPanel)

	cQuery := " SELECT 'XML' AS TIPO, " 					+ CHR(13) + CHR(10)
	cQuery += "  SUM("+xZBZ+"_ICMVAL) AS ICMS, "			+ CHR(13) + CHR(10)
	//cQuery += "  SUM("+xZBZ+"_STVALO) AS ST, " 				+ CHR(13) + CHR(10)
	//cQuery += "  SUM("+xZBZ+"_IPIVAL) AS IPI, "				+ CHR(13) + CHR(10)
	//cQuery += "  SUM("+xZBZ+"_PISVAL) AS PIS, "				+ CHR(13) + CHR(10)
	//cQuery += "  SUM("+xZBZ+"_COFVAL) AS COFINS, " 			+ CHR(13) + CHR(10)
	//cQuery += "	 0 AS INSS, "								+ CHR(13) + CHR(10)
	//cQuery += "	 0 AS ISS, "								+ CHR(13) + CHR(10)
	
	cQuery += "  SUM("+xZBZ+"_VLBRUT) AS VALTOT "			+ CHR(13) + CHR(10)
		
	cQuery += " FROM " + RETSQLNAME(xZBZ) + " "+xZBZ+" " 	+ CHR(13) + CHR(10) 
	cQuery += " WHERE "+xZBZ+".D_E_L_E_T_ <> '*' "			+ CHR(13) + CHR(10) 
	
	cQuery += " AND "+xZBZ+"_FILIAL = '" + Alltrim(cFili) + "' "	+ CHR(13) + CHR(10)			
	cQuery += " AND "+xZBZ+"_CODFOR = '" + Alltrim(cFornec) + "' "	+ CHR(13) + CHR(10)		
	cQuery += " AND "+xZBZ+"_LOJFOR = '" + Alltrim(cLoj) + "' "		+ CHR(13) + CHR(10) 
	cQuery += " AND "+xZBZ+"_NOTA = '" + Alltrim(cNF) + "' "		+ CHR(13) + CHR(10)		
	cQuery += " AND "+xZBZ+"_SERIE = '" + Alltrim(cSerie) + "' "	+ CHR(13) + CHR(10) 
 
	cQuery += " UNION "	+ CHR(13) + CHR(10)

	cQuery += "  SELECT 'NF' AS TIPO, "  		+ CHR(13) + CHR(10)
	cQuery += "  SUM(F1_VALICM) AS ICMS, " 	   		+ CHR(13) + CHR(10)
	//cQuery += "		SUM(F1_ICMSRET) AS ST, "   		+ CHR(13) + CHR(10)
	//cQuery += "		SUM(F1_VALIPI) AS IPI, "   		+ CHR(13) + CHR(10)
	//cQuery += "		SUM(F1_VALIMP5) AS PIS, "  		+ CHR(13) + CHR(10)
	//cQuery += "		SUM(F1_VALIMP6) AS COFINS, "	+ CHR(13) + CHR(10)
	//cQuery += "		SUM(F1_INSS) AS INSS, "	   		+ CHR(13) + CHR(10)
	//cQuery += "		SUM(F1_ISS) AS ISS, "  	   		+ CHR(13) + CHR(10)
	cQuery += "		SUM(F1_VALBRUT) AS VALTOT "		+ CHR(13) + CHR(10)
	cQuery += " FROM "+RetSqlName('SF1')+" SF1 "	+ CHR(13) + CHR(10)
	
	cQuery += " WHERE " + CRLF
	cQuery += " SF1.F1_FILIAL 		= '" + Alltrim(cFili) 	+ "' " + CRLF
	cQuery += " AND SF1.F1_DOC 		= '" + Alltrim(cNF) 	+ "' " + CRLF
	cQuery += " AND SF1.F1_SERIE 	= '" + Alltrim(cSerie) 	+ "' " + CRLF
	cQuery += " AND  SF1.D_E_L_E_T_ <> '*' "		+ CHR(13) + CHR(10)

	cQuery += " AND SF1.F1_FORNECE = '" + Alltrim(cFornec) + "' "	+ CHR(13) + CHR(10)		
	cQuery += " AND SF1.F1_LOJA    = '" + Alltrim(cLoj) + "' "		+ CHR(13) + CHR(10)
    
    cQuery += " ORDER BY TIPO DESC " 			+ CHR(13) + CHR(10)
    
    MemoWrite("C:\TEMP\_fCompI.sql" , cQuery )    	
	cQuery := ChangeQuery(cQuery)	               	
    
	If ( SELECT("TRB10") ) > 0
		dbSelectArea("TRB10")
		TRB10->(dbCloseArea())
	EndIf

	TcQuery cQuery Alias "TRB10" New

	TRB10->(dbGoTop())

	oChart09:SetXAxis( { "ICMS" } )        

	If TRB10->( !EOF() )

		oChart09:addSerie(TRB10->TIPO + "-" + Transform(TRB10->ICMS , "@E 999,999,999.99"), {  TRB10->ICMS   } )
		nTotIN	:= TRB10->ICMS   //Total icms da nf
			
		TRB10->(dbSkip())
		
		oChart09:addSerie(TRB10->TIPO + "-" + Transform(TRB10->ICMS , "@E 999,999,999.99"), {  TRB10->ICMS  } )
		nTotIX    := TRB10->ICMS 	//Total icms do xml
			
	Else

		oChart09:addSerie("XML", {  0, 0  } )
		oChart09:addSerie("SF1", {  0, 0  } )				
	Endif
	
	oChart09:SetXAxis( { "ICMS" } )     

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
	oChart09:setPicture("@E 9,999,999,999.99")  

	//----------------------------------------------
	//Mascara
	//----------------------------------------------
	//oChart09:setMask(" *@*")  
	oChart09:setMask("R$ *@*") 					
	
	
	//Seta as cores utilizadas
	//     oChart:oFWChartColor:aRandom := aRand
	//     oChart:oFWChartColor:SetColor("Random")
	oChart09:SetLegend(CONTROL_ALIGN_LEFT)
	oChart09:setTitle("Valor Total de ICMS - XML x NF Entrada", CONTROL_ALIGN_CENTER) 
	//oChart:setLegend( CONTROL_ALIGN_LEFT )  			//esquerda
	oChart09:SetAlignSerieLabel(CONTROL_ALIGN_RIGHT)	//direita

	oChart09:EnableMenu(.T.)

	//Define o tipo do gráfico
	oChart09:SetChartDefault(NEWPIECHART) //(BARCOMPCHART)
	//-----------------------------------------		
	
	oChart09:OOWNER:NRIGHT := oChart09:OOWNER:NRIGHT - 150
	oChart09:OOWNER:NLEFT  := oChart09:OOWNER:NLEFT - 150
    oChart09:OOWNER:NBOTTOM := oChart09:OOWNER:NBOTTOM - 100 
    
    
	nLiFim := oChart09:OOWNER:NBOTTOM  	//853 - recebe o limite de linha final do gráfico  
	//nLiFim := nLiFim - 20            	//703
		
	nCoFim := oChart09:OOWNER:NRIGHT   	//1696
	//nCoFim := nCoFim - 30              	//1646
		
	oChart09:OOWNER:NBOTTOM := nLiFim  	//703  - altura
	oChart09:OOWNER:NRIGHT  := nCoFim  //1646 - largura
		
	nLiFim := oPanel:NBOTTOM			//703
	
	//---------------------------------------------------------//
	//painel a parte, para inserção da msg divergência	
	//---------------------------------------------------------//
	
	nLiIni := aPos[1][2]  	//3
	nCoIni := aPos[1][2]    //3
	
    If nTotIN <> nTotIX
    	nDif := Iif(nTotIN > nTotIX, nTotIN - nTotIX, nTotIX - nTotIN) 
    	cMsgDiv := "DIVERGÊNCIA ENCONTRADA: R$" + Alltrim(Transform(nDif , "@E 999,999,999.99"))
    	xCor1    := CLR_HRED 
    Else
    	cMsgDiv  := "NÃO HÁ DIVERGÊNCIAS" 
    	xCor1    := CLR_HBLUE       
    Endif     
    
	//_oPanel:= TPanel():New(nLiIni,nCoIni, , oPanel, , , , , , 0,50,lLowered,lRaised) 
	_oPanel:= TPanel():New(nLiFim+5,nCoIni,cMsgDiv, oPanel,oBold,lCentered , ,xCor1, , 0,40,lLowered,lRaised)
    _oPanel:Align := CONTROL_ALIGN_BOTTOM    
    
	oChart09:Activate()

Return Nil


//==============================================================//
// Gráfico: Valor de ICM ST - XML x Entrada
//==============================================================//
//***************************************************************
Static Function _fCompI2(oPanel) 
//***************************************************************
	Local nLiIni    := 0
	Local nCoIni    := 0
	Local nLiFim    := 0
	Local nCoFim    := 0
	Local _oPanel 
	
	Local lLowered  := .T.
	Local lRaised   := .T. //.T. mostra borda do painel  
	Local lCentered := .F.
	Local aRand		:= {} 
	
	Local nTotIX    := 0
	Local nTotIN	:= 0
	Local nDif		:= 0
	Local cMsgDiv	:= ""
	Local xCor1   
	
	oChart09 := FWChartFactory():New(0,0,50,50)
	oChart09:SetOwner(oPanel)

	cQuery := " SELECT 'XML' AS TIPO, " 					+ CHR(13) + CHR(10)
	//cQuery += "  SUM("+xZBZ+"_ICMVAL) AS ICMS, "			+ CHR(13) + CHR(10)
	cQuery += "  SUM("+xZBZ+"_STVALO) AS ST, " 				+ CHR(13) + CHR(10)
	//cQuery += "  SUM("+xZBZ+"_IPIVAL) AS IPI, "				+ CHR(13) + CHR(10)
	//cQuery += "  SUM("+xZBZ+"_PISVAL) AS PIS, "				+ CHR(13) + CHR(10)
	//cQuery += "  SUM("+xZBZ+"_COFVAL) AS COFINS, " 			+ CHR(13) + CHR(10)
	//cQuery += "	 0 AS INSS, "								+ CHR(13) + CHR(10)
	//cQuery += "	 0 AS ISS, "								+ CHR(13) + CHR(10)
	
	cQuery += "  SUM("+xZBZ+"_VLBRUT) AS VALTOT "			+ CHR(13) + CHR(10)
		
	cQuery += " FROM " + RETSQLNAME(xZBZ) + " "+xZBZ+" " 	+ CHR(13) + CHR(10) 
	cQuery += " WHERE "+xZBZ+".D_E_L_E_T_ <> '*' "			+ CHR(13) + CHR(10) 
	
	cQuery += " AND "+xZBZ+"_FILIAL = '" + Alltrim(cFili) + "' "	+ CHR(13) + CHR(10)			
	cQuery += " AND "+xZBZ+"_CODFOR = '" + Alltrim(cFornec) + "' "	+ CHR(13) + CHR(10)		
	cQuery += " AND "+xZBZ+"_LOJFOR = '" + Alltrim(cLoj) + "' "		+ CHR(13) + CHR(10) 
	cQuery += " AND "+xZBZ+"_NOTA = '" + Alltrim(cNF) + "' "		+ CHR(13) + CHR(10)		
	cQuery += " AND "+xZBZ+"_SERIE = '" + Alltrim(cSerie) + "' "	+ CHR(13) + CHR(10) 
 
	cQuery += " UNION "	+ CHR(13) + CHR(10)

	cQuery += "  SELECT 'NF' AS TIPO, "  		+ CHR(13) + CHR(10)
	//cQuery += "  SUM(F1_VALICM) AS ICMS, " 	   		+ CHR(13) + CHR(10)
	cQuery += "		SUM(F1_ICMSRET) AS ST, "   		+ CHR(13) + CHR(10)
	//cQuery += "		SUM(F1_VALIPI) AS IPI, "   		+ CHR(13) + CHR(10)
	//cQuery += "		SUM(F1_VALIMP5) AS PIS, "  		+ CHR(13) + CHR(10)
	//cQuery += "		SUM(F1_VALIMP6) AS COFINS, "	+ CHR(13) + CHR(10)
	//cQuery += "		SUM(F1_INSS) AS INSS, "	   		+ CHR(13) + CHR(10)
	//cQuery += "		SUM(F1_ISS) AS ISS, "  	   		+ CHR(13) + CHR(10)
	cQuery += "		SUM(F1_VALBRUT) AS VALTOT "		+ CHR(13) + CHR(10)
	cQuery += " FROM "+RetSqlName('SF1')+" SF1 "	+ CHR(13) + CHR(10)
	
	cQuery += " WHERE " + CRLF
	cQuery += " SF1.F1_FILIAL 		= '" + Alltrim(cFili) 	+ "' " + CRLF
	cQuery += " AND SF1.F1_DOC 		= '" + Alltrim(cNF) 	+ "' " + CRLF
	cQuery += " AND SF1.F1_SERIE 	= '" + Alltrim(cSerie) 	+ "' " + CRLF
	cQuery += " AND  SF1.D_E_L_E_T_ <> '*' "		+ CHR(13) + CHR(10)

	cQuery += " AND SF1.F1_FORNECE = '" + Alltrim(cFornec) + "' "	+ CHR(13) + CHR(10)		
	cQuery += " AND SF1.F1_LOJA    = '" + Alltrim(cLoj) + "' "		+ CHR(13) + CHR(10)
    
    cQuery += " ORDER BY TIPO DESC " 			+ CHR(13) + CHR(10)
    
    MemoWrite("C:\TEMP\_fCompI2.sql" , cQuery )    	
	cQuery := ChangeQuery(cQuery)	               	
    
	If ( SELECT("TRB10") ) > 0
		dbSelectArea("TRB10")
		TRB10->(dbCloseArea())
	EndIf

	TcQuery cQuery Alias "TRB10" New

	TRB10->(dbGoTop())

	oChart09:SetXAxis( { "ICMS" } )        

	If TRB10->( !EOF() )

		oChart09:addSerie(TRB10->TIPO + "-" + Transform(TRB10->ST , "@E 999,999,999.99"), {  TRB10->ST   } )
		nTotIN	:= TRB10->ST   //Total icms da nf
					
		TRB10->(dbSkip())
		
		oChart09:addSerie(TRB10->TIPO + "-" + Transform(TRB10->ST , "@E 999,999,999.99"), {  TRB10->ST  } ) 
		nTotIX    := TRB10->ST 	//Total icms do xml
					
		TRB10->(dbSkip())		
			
	Else

		oChart09:addSerie("XML", {  0, 0  } )
		oChart09:addSerie("SF1", {  0, 0  } )				
	Endif
	
	//oChart09:SetXAxis( { "ICMS APURADO ", "ICMS RET" } )     
	oChart09:SetXAxis( { "ICM ST" } )     

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
	oChart09:setPicture("@E 9,999,999,999.99")  

	//----------------------------------------------
	//Mascara
	//----------------------------------------------
	//oChart09:setMask(" *@*")  
	oChart09:setMask("R$ *@*") 					
	
	
	//Seta as cores utilizadas
	//     oChart:oFWChartColor:aRandom := aRand
	//     oChart:oFWChartColor:SetColor("Random")
	oChart09:SetLegend(CONTROL_ALIGN_LEFT)
	oChart09:setTitle("Valor Total de ICM ST - XML x NF Entrada", CONTROL_ALIGN_CENTER) 
	//oChart:setLegend( CONTROL_ALIGN_LEFT )  			//esquerda
	oChart09:SetAlignSerieLabel(CONTROL_ALIGN_RIGHT)	//direita

	oChart09:EnableMenu(.T.)

	//Define o tipo do gráfico
	oChart09:SetChartDefault(NEWPIECHART) //(BARCOMPCHART)
	//-----------------------------------------		
		
	oChart09:OOWNER:NRIGHT := oChart09:OOWNER:NRIGHT - 150
	oChart09:OOWNER:NLEFT  := oChart09:OOWNER:NLEFT - 150
    oChart09:OOWNER:NBOTTOM := oChart09:OOWNER:NBOTTOM - 100

	nLiFim := oChart09:OOWNER:NBOTTOM  	//853 - recebe o limite de linha final do gráfico  
	nLiFim := nLiFim - 20            	//703
		
	nCoFim := oChart09:OOWNER:NRIGHT   	//1696
	nCoFim := nCoFim - 30              	//1646
		
	oChart09:OOWNER:NBOTTOM := nLiFim  	//703  - altura
	oChart09:OOWNER:NRIGHT  := nCoFim  //1646 - largura
		
	nLiFim := oPanel:NBOTTOM			//

	//---------------------------------------------------------//
	//painel a parte, para inserção da msg divergência	
	//---------------------------------------------------------//
	
	nLiIni := aPos[1][2]  	//3
	nCoIni := aPos[1][2]    //3
	
    If nTotIN <> nTotIX
    	nDif := Iif(nTotIN > nTotIX, nTotIN - nTotIX, nTotIX - nTotIN) 
    	cMsgDiv := "DIVERGÊNCIA ENCONTRADA: R$" + Alltrim(Transform(nDif , "@E 999,999,999.99"))
    	xCor1    := CLR_HRED 
    Else
    	cMsgDiv  := "NÃO HÁ DIVERGÊNCIAS" 
    	xCor1    := CLR_HBLUE       
    Endif     
    
	//_oPanel:= TPanel():New(nLiIni,nCoIni, , oPanel, , , , , , 0,50,lLowered,lRaised) 
	_oPanel:= TPanel():New(nLiFim+5,nCoIni,cMsgDiv, oPanel,oBold ,lCentered , ,xCor1, , 0,40,lLowered,lRaised)
    _oPanel:Align := CONTROL_ALIGN_BOTTOM    	

	oChart09:Activate()

Return Nil

//==============================================================//
// Gráfico: Valor de IPI - XML x Entrada
//==============================================================//
//***************************************************************
Static Function _fCompIP(oPanel) 
//***************************************************************
	Local nLiIni    := 0
	Local nCoIni    := 0
	Local nLiFim    := 0
	Local nCoFim    := 0
	Local _oPanel
	
	Local lCentered := .F.
	Local lLowered  := .T.
	Local lRaised   := .T. //.T. mostra borda do painel  
	Local aRand		:= {} 
	
	Local nTotIX    := 0
	Local nTotIN	:= 0
	Local nDif		:= 0
	Local cMsgDiv	:= ""
	Local xCor1   
	
	oChart09 := FWChartFactory():New(0,0,50,50)
	oChart09:SetOwner(oPanel)

	cQuery := " SELECT 'XML' AS TIPO, " 					+ CHR(13) + CHR(10)
	//cQuery += "  SUM("+xZBZ+"_ICMVAL) AS ICMS, "			+ CHR(13) + CHR(10)
	//cQuery += "  SUM("+xZBZ+"_STVALO) AS ST, " 				+ CHR(13) + CHR(10)
	cQuery += "  SUM("+xZBZ+"_IPIVAL) AS IPI, "				+ CHR(13) + CHR(10)
	//cQuery += "  SUM("+xZBZ+"_PISVAL) AS PIS, "				+ CHR(13) + CHR(10)
	//cQuery += "  SUM("+xZBZ+"_COFVAL) AS COFINS, " 			+ CHR(13) + CHR(10)
	//cQuery += "	 0 AS INSS, "								+ CHR(13) + CHR(10)
	//cQuery += "	 0 AS ISS, "								+ CHR(13) + CHR(10)
	
	cQuery += "  SUM("+xZBZ+"_VLBRUT) AS VALTOT "			+ CHR(13) + CHR(10)
		
	cQuery += " FROM " + RETSQLNAME(xZBZ) + " "+xZBZ+" " 	+ CHR(13) + CHR(10) 
	cQuery += " WHERE "+xZBZ+".D_E_L_E_T_ <> '*' "			+ CHR(13) + CHR(10) 
	cQuery += " AND "+xZBZ+"_FILIAL = '" + Alltrim(cFili) + "' "	+ CHR(13) + CHR(10)			
	cQuery += " AND "+xZBZ+"_CODFOR = '" + Alltrim(cFornec) + "' "	+ CHR(13) + CHR(10)		
	cQuery += " AND "+xZBZ+"_LOJFOR = '" + Alltrim(cLoj) + "' "		+ CHR(13) + CHR(10) 
	cQuery += " AND "+xZBZ+"_NOTA = '" + Alltrim(cNF) + "' "		+ CHR(13) + CHR(10)		
	cQuery += " AND "+xZBZ+"_SERIE = '" + Alltrim(cSerie) + "' "	+ CHR(13) + CHR(10) 
	
	cQuery += " UNION "	+ CHR(13) + CHR(10)

	cQuery += "  SELECT 'NF' AS TIPO, "  		+ CHR(13) + CHR(10)
	//cQuery += "  SUM(F1_VALICM) AS ICMS, " 	   		+ CHR(13) + CHR(10)
	//cQuery += "		SUM(F1_ICMSRET) AS ST, "   		+ CHR(13) + CHR(10)
	cQuery += "		SUM(F1_VALIPI) AS IPI, "   		+ CHR(13) + CHR(10)
	//cQuery += "		SUM(F1_VALIMP5) AS PIS, "  		+ CHR(13) + CHR(10)
	//cQuery += "		SUM(F1_VALIMP6) AS COFINS, "	+ CHR(13) + CHR(10)
	//cQuery += "		SUM(F1_INSS) AS INSS, "	   		+ CHR(13) + CHR(10)
	//cQuery += "		SUM(F1_ISS) AS ISS, "  	   		+ CHR(13) + CHR(10)
	cQuery += "		SUM(F1_VALBRUT) AS VALTOT "		+ CHR(13) + CHR(10)
	cQuery += " FROM "+RetSqlName('SF1')+" SF1 "	+ CHR(13) + CHR(10)
	
	cQuery += " WHERE " + CRLF
	cQuery += " SF1.F1_FILIAL 		= '" + Alltrim(cFili) 	+ "' " + CRLF
	cQuery += " AND SF1.F1_DOC 		= '" + Alltrim(cNF) 	+ "' " + CRLF
	cQuery += " AND SF1.F1_SERIE 	= '" + Alltrim(cSerie) 	+ "' " + CRLF
	cQuery += " AND  SF1.D_E_L_E_T_ <> '*' "		+ CHR(13) + CHR(10)

	cQuery += " AND SF1.F1_FORNECE = '" + Alltrim(cFornec) + "' "	+ CHR(13) + CHR(10)		
	cQuery += " AND SF1.F1_LOJA    = '" + Alltrim(cLoj) + "' "		+ CHR(13) + CHR(10)
	
    cQuery += " ORDER BY TIPO DESC " 			+ CHR(13) + CHR(10)
    
    MemoWrite("C:\TEMP\_fCompI2.sql" , cQuery )    	
	cQuery := ChangeQuery(cQuery)	               	
    
	If ( SELECT("TRB10") ) > 0
		dbSelectArea("TRB10")
		TRB10->(dbCloseArea())
	EndIf

	TcQuery cQuery Alias "TRB10" New

	TRB10->(dbGoTop())

	oChart09:SetXAxis( { "IPI" } )        

	If TRB10->( !EOF() )

		oChart09:addSerie(TRB10->TIPO + "-" + Transform(TRB10->IPI , "@E 999,999,999.99"), {  TRB10->IPI   } )
		nTotIN	:= TRB10->IPI   //Total ipi da nf
			
		TRB10->(dbSkip())
		
		oChart09:addSerie(TRB10->TIPO + "-" + Transform(TRB10->IPI , "@E 999,999,999.99"), {  TRB10->IPI  } )  
		nTotIX	:= TRB10->IPI   //Total ipi do xml
			
	Else
	oChart09:addSerie("XML", {  0, 0  } )
		oChart09:addSerie("SF1", {  0, 0  } )				
	Endif
	
	oChart09:SetXAxis( { "IPI" } )     

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
	oChart09:setPicture("@E 9,999,999,999.99")  

	//----------------------------------------------
	//Mascara
	//----------------------------------------------
	//oChart09:setMask(" *@*")  
	oChart09:setMask("R$ *@*") 					
	
	
	//Seta as cores utilizadas
	//     oChart:oFWChartColor:aRandom := aRand
	//     oChart:oFWChartColor:SetColor("Random")
	oChart09:SetLegend(CONTROL_ALIGN_LEFT)
	oChart09:setTitle("Valor Total de IPI - XML x NF Entrada", CONTROL_ALIGN_CENTER) 
	//oChart:setLegend( CONTROL_ALIGN_LEFT )  			//esquerda
	oChart09:SetAlignSerieLabel(CONTROL_ALIGN_RIGHT)	//direita

	oChart09:EnableMenu(.T.)

	//Define o tipo do gráfico
	oChart09:SetChartDefault(NEWPIECHART) //(BARCOMPCHART)
	//-----------------------------------------	
		
	oChart09:OOWNER:NRIGHT := oChart09:OOWNER:NRIGHT - 150
	oChart09:OOWNER:NLEFT  := oChart09:OOWNER:NLEFT - 150
    oChart09:OOWNER:NBOTTOM := oChart09:OOWNER:NBOTTOM - 100

	nLiFim := oChart09:OOWNER:NBOTTOM  	//853 - recebe o limite de linha final do gráfico  
	nLiFim := nLiFim - 20            	//703
		
	nCoFim := oChart09:OOWNER:NRIGHT   	//1696
	nCoFim := nCoFim - 30              	//1646
		
	oChart09:OOWNER:NBOTTOM := nLiFim  	//703  - altura
	oChart09:OOWNER:NRIGHT  := nCoFim  //1646 - largura
		
	nLiFim := oPanel:NBOTTOM			//703
	
	//---------------------------------------------------------//
	//painel a parte, para inserção da msg divergência	
	//---------------------------------------------------------//
	
	nLiIni := aPos[1][2]  	//3
	nCoIni := aPos[1][2]    //3
	
    If nTotIN <> nTotIX
    	nDif := Iif(nTotIN > nTotIX, nTotIN - nTotIX, nTotIX - nTotIN) 
    	cMsgDiv := "DIVERGÊNCIA ENCONTRADA: R$" + Alltrim(Transform(nDif , "@E 999,999,999.99"))
    	xCor1    := CLR_HRED 
    Else
    	cMsgDiv  := "NÃO HÁ DIVERGÊNCIAS" 
    	xCor1    := CLR_HBLUE       
    Endif     
    
	//_oPanel:= TPanel():New(nLiIni,nCoIni, , oPanel, , , , , , 0,50,lLowered,lRaised) 
	_oPanel:= TPanel():New(nLiFim+5,nCoIni,cMsgDiv, oPanel,oBold ,lCentered , ,xCor1, , 0,40,lLowered,lRaised)
    _oPanel:Align := CONTROL_ALIGN_BOTTOM    	
	
	oChart09:Activate()

Return Nil  

//==============================================================//
// Gráfico: Valor de PIS - XML x Entrada
//==============================================================//
//***************************************************************
Static Function _fCompPI(oPanel) 
//***************************************************************
	Local nLiIni    := 0
	Local nCoIni    := 0
	Local nLiFim    := 0
	Local nCoFim    := 0
	Local _oPanel
	
	Local lCentered := .F. 
	Local lLowered  := .T.
	Local lRaised   := .T. //.T. mostra borda do painel  
	Local aRand		:= {} 
	
	Local nTotIX    := 0
	Local nTotIN	:= 0
	Local nDif		:= 0
	Local cMsgDiv	:= ""
	Local xCor1   
	
	oChart09 := FWChartFactory():New(0,0,50,50)
	oChart09:SetOwner(oPanel)

	cQuery := " SELECT 'XML' AS TIPO, " 					+ CHR(13) + CHR(10)
	//cQuery += "  SUM("+xZBZ+"_ICMVAL) AS ICMS, "			+ CHR(13) + CHR(10)
	//cQuery += "  SUM("+xZBZ+"_STVALO) AS ST, " 				+ CHR(13) + CHR(10)
	//cQuery += "  SUM("+xZBZ+"_IPIVAL) AS IPI, "				+ CHR(13) + CHR(10)
	cQuery += "  SUM("+xZBZ+"_PISVAL) AS PIS, "				+ CHR(13) + CHR(10)
	//cQuery += "  SUM("+xZBZ+"_COFVAL) AS COFINS, " 			+ CHR(13) + CHR(10)
	//cQuery += "	 0 AS INSS, "								+ CHR(13) + CHR(10)
	//cQuery += "	 0 AS ISS, "								+ CHR(13) + CHR(10)
	
	cQuery += "  SUM("+xZBZ+"_VLBRUT) AS VALTOT "			+ CHR(13) + CHR(10)
		
	cQuery += " FROM " + RETSQLNAME(xZBZ) + " "+xZBZ+" " 	+ CHR(13) + CHR(10) 
	cQuery += " WHERE "+xZBZ+".D_E_L_E_T_ <> '*' "			+ CHR(13) + CHR(10) 
	
	cQuery += " AND "+xZBZ+"_FILIAL = '" + Alltrim(cFili) + "' "	+ CHR(13) + CHR(10)			
	cQuery += " AND "+xZBZ+"_CODFOR = '" + Alltrim(cFornec) + "' "	+ CHR(13) + CHR(10)		
	cQuery += " AND "+xZBZ+"_LOJFOR = '" + Alltrim(cLoj) + "' "		+ CHR(13) + CHR(10) 
	cQuery += " AND "+xZBZ+"_NOTA = '" + Alltrim(cNF) + "' "		+ CHR(13) + CHR(10)		
	cQuery += " AND "+xZBZ+"_SERIE = '" + Alltrim(cSerie) + "' "	+ CHR(13) + CHR(10) 
 
	cQuery += " UNION "	+ CHR(13) + CHR(10)

	cQuery += "  SELECT 'NF' AS TIPO, "  		+ CHR(13) + CHR(10)
	//cQuery += "  SUM(F1_VALICM) AS ICMS, " 	   		+ CHR(13) + CHR(10)
	//cQuery += "		SUM(F1_ICMSRET) AS ST, "   		+ CHR(13) + CHR(10)
	//cQuery += "		SUM(F1_VALIPI) AS IPI, "   		+ CHR(13) + CHR(10)
	cQuery += "		SUM(F1_VALIMP5) AS PIS, "  		+ CHR(13) + CHR(10)
	//cQuery += "		SUM(F1_VALIMP6) AS COFINS, "	+ CHR(13) + CHR(10)
	//cQuery += "		SUM(F1_INSS) AS INSS, "	   		+ CHR(13) + CHR(10)
	//cQuery += "		SUM(F1_ISS) AS ISS, "  	   		+ CHR(13) + CHR(10)
	cQuery += "		SUM(F1_VALBRUT) AS VALTOT "		+ CHR(13) + CHR(10)
	cQuery += " FROM "+RetSqlName('SF1')+" SF1 "	+ CHR(13) + CHR(10)
	
	cQuery += " WHERE " + CRLF
	cQuery += " SF1.F1_FILIAL 		= '" + Alltrim(cFili) 	+ "' " + CRLF
	cQuery += " AND SF1.F1_DOC 		= '" + Alltrim(cNF) 	+ "' " + CRLF
	cQuery += " AND SF1.F1_SERIE 	= '" + Alltrim(cSerie) 	+ "' " + CRLF
	cQuery += " AND  SF1.D_E_L_E_T_ <> '*' "		+ CHR(13) + CHR(10)

	cQuery += " AND SF1.F1_FORNECE = '" + Alltrim(cFornec) + "' "	+ CHR(13) + CHR(10)		
	cQuery += " AND SF1.F1_LOJA    = '" + Alltrim(cLoj) + "' "		+ CHR(13) + CHR(10)
    
    cQuery += " ORDER BY TIPO DESC " 			+ CHR(13) + CHR(10)
    
    MemoWrite("C:\TEMP\_fCompI2.sql" , cQuery )    	
	cQuery := ChangeQuery(cQuery)	               	
    
	If ( SELECT("TRB10") ) > 0
		dbSelectArea("TRB10")
		TRB10->(dbCloseArea())
	EndIf

	TcQuery cQuery Alias "TRB10" New

	TRB10->(dbGoTop())

	oChart09:SetXAxis( { "PIS" } )        

	If TRB10->( !EOF() )

		oChart09:addSerie(TRB10->TIPO + "-" + Transform(TRB10->PIS , "@E 999,999,999.99"), {  TRB10->PIS   } )
		nTotIN	:= TRB10->PIS   //Total pis da nf
			
		TRB10->(dbSkip())
		
		oChart09:addSerie(TRB10->TIPO + "-" + Transform(TRB10->PIS , "@E 999,999,999.99"), {  TRB10->PIS  } )
		nTotIX	:= TRB10->PIS   //Total pis do xml
			
	Else

		oChart09:addSerie("XML", {  0, 0  } )
		oChart09:addSerie("SF1", {  0, 0  } )				
	Endif
	
	oChart09:SetXAxis( { "PIS" } )     

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
	oChart09:setPicture("@E 9,999,999,999.99")  

	//----------------------------------------------
	//Mascara
	//----------------------------------------------
	//oChart09:setMask(" *@*")  
	oChart09:setMask("R$ *@*") 					
	
	
	//Seta as cores utilizadas
	//     oChart:oFWChartColor:aRandom := aRand
	//     oChart:oFWChartColor:SetColor("Random")
	oChart09:SetLegend(CONTROL_ALIGN_LEFT)
	oChart09:setTitle("Valor Total de PIS - XML x NF Entrada", CONTROL_ALIGN_CENTER) 
	//oChart:setLegend( CONTROL_ALIGN_LEFT )  			//esquerda
	oChart09:SetAlignSerieLabel(CONTROL_ALIGN_RIGHT)	//direita

	oChart09:EnableMenu(.T.)

	//Define o tipo do gráfico
	oChart09:SetChartDefault(NEWPIECHART) //(BARCOMPCHART)
	//-----------------------------------------	
	
		
	oChart09:OOWNER:NRIGHT := oChart09:OOWNER:NRIGHT - 150
	oChart09:OOWNER:NLEFT  := oChart09:OOWNER:NLEFT - 150
    oChart09:OOWNER:NBOTTOM := oChart09:OOWNER:NBOTTOM - 100
    
    nLiFim := oChart09:OOWNER:NBOTTOM  	//853 - recebe o limite de linha final do gráfico  
	nLiFim := nLiFim - 20            	//703
		
	nCoFim := oChart09:OOWNER:NRIGHT   	//1696
	nCoFim := nCoFim - 30              	//1646
		
	oChart09:OOWNER:NBOTTOM := nLiFim  	//703  - altura
	oChart09:OOWNER:NRIGHT  := nCoFim  //1646 - largura
		
	nLiFim := oPanel:NBOTTOM			//703
	
	//---------------------------------------------------------//
	//painel a parte, para inserção da msg divergência	
	//---------------------------------------------------------//
	
	nLiIni := aPos[1][2]  	//3
	nCoIni := aPos[1][2]    //3
	
    If nTotIN <> nTotIX
    	nDif := Iif(nTotIN > nTotIX, nTotIN - nTotIX, nTotIX - nTotIN) 
    	cMsgDiv := "DIVERGÊNCIA ENCONTRADA: R$" + Alltrim(Transform(nDif , "@E 999,999,999.99"))
    	xCor1    := CLR_HRED 
    Else
    	cMsgDiv  := "NÃO HÁ DIVERGÊNCIAS" 
    	xCor1    := CLR_HBLUE       
    Endif     
    
	//_oPanel:= TPanel():New(nLiIni,nCoIni, , oPanel, , , , , , 0,50,lLowered,lRaised) 
	_oPanel:= TPanel():New(nLiFim+5,nCoIni,cMsgDiv, oPanel,oBold ,lCentered , ,xCor1, , 0,40,lLowered,lRaised)
    _oPanel:Align := CONTROL_ALIGN_BOTTOM    	
	
	oChart09:Activate()

Return Nil

//==============================================================//
// Gráfico: Valor de COFINS - XML x Entrada
//==============================================================//
//***************************************************************
Static Function _fCompCO(oPanel) 
//***************************************************************
	Local nLiIni    := 0
	Local nCoIni    := 0
	Local nLiFim    := 0
	Local nCoFim    := 0
	Local _oPanel
	
	Local lCentered := .F. 
	Local lLowered  := .T.
	Local lRaised   := .T. //.T. mostra borda do painel  
	Local aRand		:= {} 
	
	Local nTotIX    := 0
	Local nTotIN	:= 0
	Local nDif		:= 0
	Local cMsgDiv	:= ""
	Local xCor1   
	
	oChart09 := FWChartFactory():New(0,0,50,50)
	oChart09:SetOwner(oPanel)

	cQuery := " SELECT 'XML' AS TIPO, " 					+ CHR(13) + CHR(10)
	//cQuery += "  SUM("+xZBZ+"_ICMVAL) AS ICMS, "			+ CHR(13) + CHR(10)
	//cQuery += "  SUM("+xZBZ+"_STVALO) AS ST, " 				+ CHR(13) + CHR(10)
	//cQuery += "  SUM("+xZBZ+"_IPIVAL) AS IPI, "				+ CHR(13) + CHR(10)
	//cQuery += "  SUM("+xZBZ+"_PISVAL) AS PIS, "				+ CHR(13) + CHR(10)
	cQuery += "  SUM("+xZBZ+"_COFVAL) AS COFINS, " 			+ CHR(13) + CHR(10)
	//cQuery += "	 0 AS INSS, "								+ CHR(13) + CHR(10)
	//cQuery += "	 0 AS ISS, "								+ CHR(13) + CHR(10)
	
	cQuery += "  SUM("+xZBZ+"_VLBRUT) AS VALTOT "			+ CHR(13) + CHR(10)
		
	cQuery += " FROM " + RETSQLNAME(xZBZ) + " "+xZBZ+" " 	+ CHR(13) + CHR(10) 
	cQuery += " WHERE "+xZBZ+".D_E_L_E_T_ <> '*' "			+ CHR(13) + CHR(10) 
	
	cQuery += " AND "+xZBZ+"_FILIAL = '" + Alltrim(cFili) + "' "	+ CHR(13) + CHR(10)			
	cQuery += " AND "+xZBZ+"_CODFOR = '" + Alltrim(cFornec) + "' "	+ CHR(13) + CHR(10)		
	cQuery += " AND "+xZBZ+"_LOJFOR = '" + Alltrim(cLoj) + "' "		+ CHR(13) + CHR(10) 
	cQuery += " AND "+xZBZ+"_NOTA = '" + Alltrim(cNF) + "' "		+ CHR(13) + CHR(10)		
	cQuery += " AND "+xZBZ+"_SERIE = '" + Alltrim(cSerie) + "' "	+ CHR(13) + CHR(10) 
 
	cQuery += " UNION "	+ CHR(13) + CHR(10)

	cQuery += "  SELECT 'NF' AS TIPO, "  		+ CHR(13) + CHR(10)
	//cQuery += "  SUM(F1_VALICM) AS ICMS, " 	   		+ CHR(13) + CHR(10)
	//cQuery += "		SUM(F1_ICMSRET) AS ST, "   		+ CHR(13) + CHR(10)
	//cQuery += "		SUM(F1_VALIPI) AS IPI, "   		+ CHR(13) + CHR(10)
	//cQuery += "		SUM(F1_VALIMP5) AS PIS, "  		+ CHR(13) + CHR(10)
	cQuery += "		SUM(F1_VALIMP6) AS COFINS, "	+ CHR(13) + CHR(10)
	//cQuery += "		SUM(F1_INSS) AS INSS, "	   		+ CHR(13) + CHR(10)
	//cQuery += "		SUM(F1_ISS) AS ISS, "  	   		+ CHR(13) + CHR(10)
	cQuery += "		SUM(F1_VALBRUT) AS VALTOT "		+ CHR(13) + CHR(10)
	cQuery += " FROM "+RetSqlName('SF1')+" SF1 "	+ CHR(13) + CHR(10)
	
	cQuery += " WHERE " + CRLF
	cQuery += " SF1.F1_FILIAL 		= '" + Alltrim(cFili) 	+ "' " + CRLF
	cQuery += " AND SF1.F1_DOC 		= '" + Alltrim(cNF) 	+ "' " + CRLF
	cQuery += " AND SF1.F1_SERIE 	= '" + Alltrim(cSerie) 	+ "' " + CRLF
	cQuery += " AND  SF1.D_E_L_E_T_ <> '*' "		+ CHR(13) + CHR(10)

	cQuery += " AND SF1.F1_FORNECE = '" + Alltrim(cFornec) + "' "	+ CHR(13) + CHR(10)		
	cQuery += " AND SF1.F1_LOJA    = '" + Alltrim(cLoj) + "' "		+ CHR(13) + CHR(10)
    
    cQuery += " ORDER BY TIPO DESC " 			+ CHR(13) + CHR(10)
    
    MemoWrite("C:\TEMP\_fCompI2.sql" , cQuery )    	
	cQuery := ChangeQuery(cQuery)	               	
    
	If ( SELECT("TRB10") ) > 0
		dbSelectArea("TRB10")
		TRB10->(dbCloseArea())
	EndIf

	TcQuery cQuery Alias "TRB10" New

	TRB10->(dbGoTop())

	oChart09:SetXAxis( { "COFINS" } )        

	If TRB10->( !EOF() )

		oChart09:addSerie(TRB10->TIPO + "-" + Transform(TRB10->COFINS , "@E 999,999,999.99"), {  TRB10->COFINS   } )
		nTotIN	:= TRB10->COFINS   //Total cofins da nf
			
		TRB10->(dbSkip())
		
		oChart09:addSerie(TRB10->TIPO + "-" + Transform(TRB10->COFINS , "@E 999,999,999.99"), {  TRB10->COFINS  } )
		nTotIX	:= TRB10->COFINS   //Total cofins do xml
			
	Else

		oChart09:addSerie("XML", {  0, 0  } )
		oChart09:addSerie("SF1", {  0, 0  } )				
	Endif
	
	//oChart09:SetXAxis( { "ICMS APURADO ", "ICMS RET" } )     
	oChart09:SetXAxis( { "COFINS" } )     

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
	oChart09:setPicture("@E 9,999,999,999.99")  

	//----------------------------------------------
	//Mascara
	//----------------------------------------------
	//oChart09:setMask(" *@*")  
	oChart09:setMask("R$ *@*") 					
	
	
	//Seta as cores utilizadas
	//     oChart:oFWChartColor:aRandom := aRand
	//     oChart:oFWChartColor:SetColor("Random")
	oChart09:SetLegend(CONTROL_ALIGN_LEFT)
	oChart09:setTitle("Valor Total de COFINS - XML x NF Entrada", CONTROL_ALIGN_CENTER) 
	//oChart:setLegend( CONTROL_ALIGN_LEFT )  			//esquerda
	oChart09:SetAlignSerieLabel(CONTROL_ALIGN_RIGHT)	//direita

	oChart09:EnableMenu(.T.)

	//Define o tipo do gráfico
	oChart09:SetChartDefault(NEWPIECHART) //(BARCOMPCHART)
	//-----------------------------------------	
	
	oChart09:OOWNER:NRIGHT := oChart09:OOWNER:NRIGHT - 150
	oChart09:OOWNER:NLEFT  := oChart09:OOWNER:NLEFT - 150
    oChart09:OOWNER:NBOTTOM := oChart09:OOWNER:NBOTTOM - 100
    
	
	nLiFim := oChart09:OOWNER:NBOTTOM  	//853 - recebe o limite de linha final do gráfico  
	//nLiFim := nLiFim - 20            	//703
		
	nCoFim := oChart09:OOWNER:NRIGHT   	//1696
	nCoFim := nCoFim - 30              	//1646
		
	oChart09:OOWNER:NBOTTOM := nLiFim  	//703  - altura
	oChart09:OOWNER:NRIGHT  := nCoFim  //1646 - largura
		
	nLiFim := oPanel:NBOTTOM			//703 
	
	//---------------------------------------------------------//
	//painel a parte, para inserção da msg divergência	
	//---------------------------------------------------------//
	
	nLiIni := aPos[1][2]  	//3
	nCoIni := aPos[1][2]    //3
	
    If nTotIN <> nTotIX
    	nDif := Iif(nTotIN > nTotIX, nTotIN - nTotIX, nTotIX - nTotIN) 
    	cMsgDiv := "DIVERGÊNCIA ENCONTRADA: R$" + Alltrim(Transform(nDif , "@E 999,999,999.99"))
    	xCor1    := CLR_HRED 
    Else
    	cMsgDiv  := "NÃO HÁ DIVERGÊNCIAS" 
    	xCor1    := CLR_HBLUE       
    Endif     
    
	//_oPanel:= TPanel():New(nLiIni,nCoIni, , oPanel, , , , , , 0,50,lLowered,lRaised) 
	_oPanel:= TPanel():New(nLiFim+5,nCoIni,cMsgDiv, oPanel,oBold ,lCentered , ,xCor1, , 0,40,lLowered,lRaised)
    _oPanel:Align := CONTROL_ALIGN_BOTTOM    	
	
	oChart09:Activate()

Return Nil


//==============================================================//
// Gráfico: Valor de INSS - XML x Entrada
//==============================================================//
Static Function _fCompIN(oPanel) 
	Local nLiIni    := 0
	Local nCoIni    := 0
	Local nLiFim    := 0
	Local nCoFim    := 0
	
	Local nTotIX    := 0
	Local nTotIN	:= 0
	Local nDif		:= 0
	Local cMsgDiv	:= ""
	Local xCor1   
		
	Local _oPanel
	 
	Local lLowered  := .T.
	Local lRaised   := .T. //.T. mostra borda do painel  
	Local lCentered := .F. //.T. mostra o texto do objeto no centro painel
		
	Local aRand		:= {}
	
	oChart09 := FWChartFactory():New(0,0,50,50)
	oChart09:SetOwner(oPanel)

	cQuery := " SELECT 'XML' AS TIPO, " 					+ CHR(13) + CHR(10)
	//cQuery += "  SUM("+xZBZ+"_ICMVAL) AS ICMS, "			+ CHR(13) + CHR(10)
	//cQuery += "  SUM("+xZBZ+"_STVALO) AS ST, " 				+ CHR(13) + CHR(10)
	//cQuery += "  SUM("+xZBZ+"_IPIVAL) AS IPI, "				+ CHR(13) + CHR(10)
	//cQuery += "  SUM("+xZBZ+"_PISVAL) AS PIS, "				+ CHR(13) + CHR(10)
	//cQuery += "  SUM("+xZBZ+"_COFVAL) AS COFINS, " 			+ CHR(13) + CHR(10)
	cQuery += "  SUM("+xZBT+"_INSVAL)	 AS INSS, "				+ CHR(13) + CHR(10)
	//cQuery += "	 0 AS ISS, "								+ CHR(13) + CHR(10)
	
	cQuery += "  SUM("+xZBZ+"_VLBRUT) AS VALTOT "			+ CHR(13) + CHR(10)
		
	cQuery += " FROM " + RETSQLNAME(xZBZ) + " "+xZBZ+" " 	+ CHR(13) + CHR(10)  
	
	cQuery += " INNER JOIN " + RETSQLNAME(xZBT) + " " + xZBT + " ON " + CHR(13) + CHR(10) 
	cQuery += " " + xZBT+"_FILIAL = " + xZBZ+"_FILIAL AND "			  + CHR(13) + CHR(10) 
	cQuery += " " + xZBT+"_NOTA   = " + xZBZ+"_NOTA   AND "			  + CHR(13) + CHR(10)
	cQuery += " " + xZBT+"_SERIE  = " + xZBZ+"_SERIE  AND "			  + CHR(13) + CHR(10)
	cQuery += " " + xZBT+"_CHAVE  = " + xZBZ+"_CHAVE  "				  + CHR(13) + CHR(10)
	
	cQuery += " WHERE "+xZBZ+".D_E_L_E_T_ <> '*' "			+ CHR(13) + CHR(10) 	
	cQuery += " AND "+xZBZ+"_FILIAL = '" + Alltrim(cFili) + "' "	+ CHR(13) + CHR(10)			
	cQuery += " AND "+xZBZ+"_CODFOR = '" + Alltrim(cFornec) + "' "	+ CHR(13) + CHR(10)		
	cQuery += " AND "+xZBZ+"_LOJFOR = '" + Alltrim(cLoj) + "' "		+ CHR(13) + CHR(10) 
	cQuery += " AND "+xZBZ+"_NOTA = '" + Alltrim(cNF) + "' "		+ CHR(13) + CHR(10)		
	cQuery += " AND "+xZBZ+"_SERIE = '" + Alltrim(cSerie) + "' "	+ CHR(13) + CHR(10) 
 
	cQuery += " UNION "	+ CHR(13) + CHR(10)

	cQuery += "  SELECT 'NF' AS TIPO, "  		+ CHR(13) + CHR(10)
	//cQuery += "  SUM(F1_VALICM) AS ICMS, " 	   		+ CHR(13) + CHR(10)
	//cQuery += "		SUM(F1_ICMSRET) AS ST, "   		+ CHR(13) + CHR(10)
	//cQuery += "		SUM(F1_VALIPI) AS IPI, "   		+ CHR(13) + CHR(10)
	//cQuery += "		SUM(F1_VALIMP5) AS PIS, "  		+ CHR(13) + CHR(10)
	//cQuery += "		SUM(F1_VALIMP6) AS COFINS, "	+ CHR(13) + CHR(10)
	cQuery += "		SUM(F1_INSS) AS INSS, "	   		+ CHR(13) + CHR(10)
	//cQuery += "		SUM(F1_ISS) AS ISS, "  	   		+ CHR(13) + CHR(10)
	cQuery += "		SUM(F1_VALBRUT) AS VALTOT "		+ CHR(13) + CHR(10)
	cQuery += " FROM "+RetSqlName('SF1')+" SF1 "	+ CHR(13) + CHR(10)
	
	cQuery += " WHERE " + CRLF
	cQuery += " SF1.F1_FILIAL 		= '" + Alltrim(cFili) 	+ "' " + CRLF
	cQuery += " AND SF1.F1_DOC 		= '" + Alltrim(cNF) 	+ "' " + CRLF
	cQuery += " AND SF1.F1_SERIE 	= '" + Alltrim(cSerie) 	+ "' " + CRLF
	cQuery += " AND  SF1.D_E_L_E_T_ <> '*' "		+ CHR(13) + CHR(10)

	cQuery += " AND SF1.F1_FORNECE = '" + Alltrim(cFornec) + "' "	+ CHR(13) + CHR(10)		
	cQuery += " AND SF1.F1_LOJA    = '" + Alltrim(cLoj) + "' "		+ CHR(13) + CHR(10)
    
    cQuery += " ORDER BY TIPO DESC " 			+ CHR(13) + CHR(10)
    
    MemoWrite("C:\TEMP\_fCompIN.sql" , cQuery )    	
	cQuery := ChangeQuery(cQuery)	               	
    
	If ( SELECT("TRB10") ) > 0
		dbSelectArea("TRB10")
		TRB10->(dbCloseArea())
	EndIf

	TcQuery cQuery Alias "TRB10" New

	TRB10->(dbGoTop())

	oChart09:SetXAxis( { "INSS" } )        

	If TRB10->( !EOF() )

		oChart09:addSerie(TRB10->TIPO + "-" + Transform(TRB10->INSS , "@E 999,999,999.99"), {  TRB10->INSS   } )
		nTotIN	:= TRB10->INSS   //Total icms da nf
			
		TRB10->(dbSkip())
		
		oChart09:addSerie(TRB10->TIPO + "-" + Transform(TRB10->INSS , "@E 999,999,999.99"), {  TRB10->INSS  } )
		nTotIX    := TRB10->INSS	//Total icms do xml
			
	Else

		oChart09:addSerie("XML", {  0, 0  } )
		oChart09:addSerie("SF1", {  0, 0  } )				
	Endif
	
	oChart09:SetXAxis( { "INSS" } )     

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
	oChart09:setPicture("@E 9,999,999,999.99")  

	//----------------------------------------------
	//Mascara
	//----------------------------------------------
	//oChart09:setMask(" *@*")  
	oChart09:setMask("R$ *@*") 					
	
	
	//Seta as cores utilizadas
	//     oChart:oFWChartColor:aRandom := aRand
	//     oChart:oFWChartColor:SetColor("Random")
	oChart09:SetLegend(CONTROL_ALIGN_LEFT)
	oChart09:setTitle("Valor Total de INSS - XML x NF Entrada", CONTROL_ALIGN_CENTER) 
	//oChart:setLegend( CONTROL_ALIGN_LEFT )  			//esquerda
	oChart09:SetAlignSerieLabel(CONTROL_ALIGN_RIGHT)	//direita

	oChart09:EnableMenu(.T.)

	//Define o tipo do gráfico
	oChart09:SetChartDefault(NEWPIECHART) //(BARCOMPCHART)
	//-----------------------------------------		
	
	oChart09:OOWNER:NRIGHT := oChart09:OOWNER:NRIGHT - 150
	oChart09:OOWNER:NLEFT  := oChart09:OOWNER:NLEFT - 150
    oChart09:OOWNER:NBOTTOM := oChart09:OOWNER:NBOTTOM - 100 
    
    
	nLiFim := oChart09:OOWNER:NBOTTOM  	//853 - recebe o limite de linha final do gráfico  
	//nLiFim := nLiFim - 20            	//703
		
	nCoFim := oChart09:OOWNER:NRIGHT   	//1696
	//nCoFim := nCoFim - 30              	//1646
		
	oChart09:OOWNER:NBOTTOM := nLiFim  	//703  - altura
	oChart09:OOWNER:NRIGHT  := nCoFim  //1646 - largura
		
	nLiFim := oPanel:NBOTTOM			//703
	
	//---------------------------------------------------------//
	//painel a parte, para inserção da msg divergência	
	//---------------------------------------------------------//
	
	nLiIni := aPos[1][2]  	//3
	nCoIni := aPos[1][2]    //3
	
    If nTotIN <> nTotIX
    	nDif := Iif(nTotIN > nTotIX, nTotIN - nTotIX, nTotIX - nTotIN) 
    	cMsgDiv := "DIVERGÊNCIA ENCONTRADA: R$" + Alltrim(Transform(nDif , "@E 999,999,999.99"))
    	xCor1    := CLR_HRED 
    Else
    	cMsgDiv  := "NÃO HÁ DIVERGÊNCIAS" 
    	xCor1    := CLR_HBLUE       
    Endif     
    
	//_oPanel:= TPanel():New(nLiIni,nCoIni, , oPanel, , , , , , 0,50,lLowered,lRaised) 
	_oPanel:= TPanel():New(nLiFim+5,nCoIni,cMsgDiv, oPanel,oBold,lCentered , ,xCor1, , 0,40,lLowered,lRaised)
    _oPanel:Align := CONTROL_ALIGN_BOTTOM    
    
	oChart09:Activate()

Return Nil


//==============================================================//
// Gráfico: Valor de ISS - XML x Entrada
//==============================================================//
Static Function _fCompIS(oPanel) 
	Local nLiIni    := 0
	Local nCoIni    := 0
	Local nLiFim    := 0
	Local nCoFim    := 0
	
	Local nTotIX    := 0
	Local nTotIN	:= 0
	Local nDif		:= 0
	Local cMsgDiv	:= ""
	Local xCor1   
		
	Local _oPanel
	 
	Local lLowered  := .T.
	Local lRaised   := .T. //.T. mostra borda do painel  
	Local lCentered := .F. //.T. mostra o texto do objeto no centro painel
		
	Local aRand		:= {}
	
	oChart09 := FWChartFactory():New(0,0,50,50)
	oChart09:SetOwner(oPanel)

	cQuery := " SELECT 'XML' AS TIPO, " 					+ CHR(13) + CHR(10)
	//cQuery += "  SUM("+xZBZ+"_ICMVAL) AS ICMS, "			+ CHR(13) + CHR(10)
	//cQuery += "  SUM("+xZBZ+"_STVALO) AS ST, " 				+ CHR(13) + CHR(10)
	//cQuery += "  SUM("+xZBZ+"_IPIVAL) AS IPI, "				+ CHR(13) + CHR(10)
	//cQuery += "  SUM("+xZBZ+"_PISVAL) AS PIS, "				+ CHR(13) + CHR(10)
	//cQuery += "  SUM("+xZBZ+"_COFVAL) AS COFINS, " 			+ CHR(13) + CHR(10)
	//cQuery += "  SUM("+xZBT+"_INSVAL)	 AS INSS, "				+ CHR(13) + CHR(10)
	cQuery += "  SUM("+xZBT+"_ISSVAL)	 AS ISS, "				+ CHR(13) + CHR(10)
	//cQuery += "	 0 AS ISS, "								+ CHR(13) + CHR(10)
	
	cQuery += "  SUM("+xZBZ+"_VLBRUT) AS VALTOT "			+ CHR(13) + CHR(10)
		
	cQuery += " FROM " + RETSQLNAME(xZBZ) + " "+xZBZ+" " 	+ CHR(13) + CHR(10)  
	
	cQuery += " INNER JOIN " + RETSQLNAME(xZBT) + " " + xZBT + " ON " + CHR(13) + CHR(10) 
	cQuery += " " + xZBT+"_FILIAL = " + xZBZ+"_FILIAL AND "			  + CHR(13) + CHR(10) 
	cQuery += " " + xZBT+"_NOTA   = " + xZBZ+"_NOTA   AND "			  + CHR(13) + CHR(10)
	cQuery += " " + xZBT+"_SERIE  = " + xZBZ+"_SERIE  AND "			  + CHR(13) + CHR(10)
	cQuery += " " + xZBT+"_CHAVE  = " + xZBZ+"_CHAVE  "				  + CHR(13) + CHR(10)
	
	cQuery += " WHERE "+xZBZ+".D_E_L_E_T_ <> '*' "			+ CHR(13) + CHR(10) 	
	cQuery += " AND "+xZBZ+"_FILIAL = '" + Alltrim(cFili) + "' "	+ CHR(13) + CHR(10)			
	cQuery += " AND "+xZBZ+"_CODFOR = '" + Alltrim(cFornec) + "' "	+ CHR(13) + CHR(10)		
	cQuery += " AND "+xZBZ+"_LOJFOR = '" + Alltrim(cLoj) + "' "		+ CHR(13) + CHR(10) 
	cQuery += " AND "+xZBZ+"_NOTA = '" + Alltrim(cNF) + "' "		+ CHR(13) + CHR(10)		
	cQuery += " AND "+xZBZ+"_SERIE = '" + Alltrim(cSerie) + "' "	+ CHR(13) + CHR(10) 
 
	cQuery += " UNION "	+ CHR(13) + CHR(10)

	cQuery += "  SELECT 'NF' AS TIPO, "  		+ CHR(13) + CHR(10)
	//cQuery += "  SUM(F1_VALICM) AS ICMS, " 	   		+ CHR(13) + CHR(10)
	//cQuery += "		SUM(F1_ICMSRET) AS ST, "   		+ CHR(13) + CHR(10)
	//cQuery += "		SUM(F1_VALIPI) AS IPI, "   		+ CHR(13) + CHR(10)
	//cQuery += "		SUM(F1_VALIMP5) AS PIS, "  		+ CHR(13) + CHR(10)
	//cQuery += "		SUM(F1_VALIMP6) AS COFINS, "	+ CHR(13) + CHR(10)
	//cQuery += "		SUM(F1_INSS) AS INSS, "	   		+ CHR(13) + CHR(10)
	cQuery += "		SUM(F1_ISS) AS ISS, "  	   		+ CHR(13) + CHR(10)
	cQuery += "		SUM(F1_VALBRUT) AS VALTOT "		+ CHR(13) + CHR(10)
	cQuery += " FROM "+RetSqlName('SF1')+" SF1 "	+ CHR(13) + CHR(10)
	
	cQuery += " WHERE " + CRLF
	cQuery += " SF1.F1_FILIAL 		= '" + Alltrim(cFili) 	+ "' " + CRLF
	cQuery += " AND SF1.F1_DOC 		= '" + Alltrim(cNF) 	+ "' " + CRLF
	cQuery += " AND SF1.F1_SERIE 	= '" + Alltrim(cSerie) 	+ "' " + CRLF
	cQuery += " AND  SF1.D_E_L_E_T_ <> '*' "		+ CHR(13) + CHR(10)

	cQuery += " AND SF1.F1_FORNECE = '" + Alltrim(cFornec) + "' "	+ CHR(13) + CHR(10)		
	cQuery += " AND SF1.F1_LOJA    = '" + Alltrim(cLoj) + "' "		+ CHR(13) + CHR(10)
    
    cQuery += " ORDER BY TIPO DESC " 			+ CHR(13) + CHR(10)
    
    MemoWrite("C:\TEMP\_fCompIS.sql" , cQuery )    	
	cQuery := ChangeQuery(cQuery)	               	
    
	If ( SELECT("TRB10") ) > 0
		dbSelectArea("TRB10")
		TRB10->(dbCloseArea())
	EndIf

	TcQuery cQuery Alias "TRB10" New

	TRB10->(dbGoTop())

	oChart09:SetXAxis( { "ISS" } )        

	If TRB10->( !EOF() )

		oChart09:addSerie(TRB10->TIPO + "-" + Transform(TRB10->ISS , "@E 999,999,999.99"), {  TRB10->ISS   } )
		nTotIN	:= TRB10->ISS   //Total icms da nf
			
		TRB10->(dbSkip())
		
		oChart09:addSerie(TRB10->TIPO + "-" + Transform(TRB10->ISS , "@E 999,999,999.99"), {  TRB10->ISS  } )
		nTotIX    := TRB10->ISS	//Total icms do xml
			
	Else

		oChart09:addSerie("XML", {  0, 0  } )
		oChart09:addSerie("SF1", {  0, 0  } )				
	Endif
	
	oChart09:SetXAxis( { "ISS" } )     

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
	oChart09:setPicture("@E 9,999,999,999.99")  

	//----------------------------------------------
	//Mascara
	//----------------------------------------------
	//oChart09:setMask(" *@*")  
	oChart09:setMask("R$ *@*") 					
	
	
	//Seta as cores utilizadas
	//     oChart:oFWChartColor:aRandom := aRand
	//     oChart:oFWChartColor:SetColor("Random")
	oChart09:SetLegend(CONTROL_ALIGN_LEFT)
	oChart09:setTitle("Valor Total de ISS - XML x NF Entrada", CONTROL_ALIGN_CENTER) 
	//oChart:setLegend( CONTROL_ALIGN_LEFT )  			//esquerda
	oChart09:SetAlignSerieLabel(CONTROL_ALIGN_RIGHT)	//direita

	oChart09:EnableMenu(.T.)

	//Define o tipo do gráfico
	oChart09:SetChartDefault(NEWPIECHART) //(BARCOMPCHART)
	//-----------------------------------------		
	
	oChart09:OOWNER:NRIGHT := oChart09:OOWNER:NRIGHT - 150
	oChart09:OOWNER:NLEFT  := oChart09:OOWNER:NLEFT - 150
    oChart09:OOWNER:NBOTTOM := oChart09:OOWNER:NBOTTOM - 100 
    
    
	nLiFim := oChart09:OOWNER:NBOTTOM  	//853 - recebe o limite de linha final do gráfico  
	//nLiFim := nLiFim - 20            	//703
		
	nCoFim := oChart09:OOWNER:NRIGHT   	//1696
	//nCoFim := nCoFim - 30              	//1646
		
	oChart09:OOWNER:NBOTTOM := nLiFim  	//703  - altura
	oChart09:OOWNER:NRIGHT  := nCoFim  //1646 - largura
		
	nLiFim := oPanel:NBOTTOM			//703
	
	//---------------------------------------------------------//
	//painel a parte, para inserção da msg divergência	
	//---------------------------------------------------------//
	
	nLiIni := aPos[1][2]  	//3
	nCoIni := aPos[1][2]    //3
	
    If nTotIN <> nTotIX
    	nDif := Iif(nTotIN > nTotIX, nTotIN - nTotIX, nTotIX - nTotIN) 
    	cMsgDiv := "DIVERGÊNCIA ENCONTRADA: R$" + Alltrim(Transform(nDif , "@E 999,999,999.99"))
    	xCor1    := CLR_HRED 
    Else
    	cMsgDiv  := "NÃO HÁ DIVERGÊNCIAS" 
    	xCor1    := CLR_HBLUE       
    Endif     
    
	//_oPanel:= TPanel():New(nLiIni,nCoIni, , oPanel, , , , , , 0,50,lLowered,lRaised) 
	_oPanel:= TPanel():New(nLiFim+5,nCoIni,cMsgDiv, oPanel,oBold,lCentered , ,xCor1, , 0,40,lLowered,lRaised)
    _oPanel:Align := CONTROL_ALIGN_BOTTOM    
    
	oChart09:Activate()

Return Nil 

//==============================================================//
// Gráfico: Valor de IR - XML x Entrada
//==============================================================//
Static Function _fCompIR(oPanel) 
	Local nLiIni    := 0
	Local nCoIni    := 0
	Local nLiFim    := 0
	Local nCoFim    := 0
	
	Local nTotIX    := 0
	Local nTotIN	:= 0
	Local nDif		:= 0
	Local cMsgDiv	:= ""
	Local xCor1   
		
	Local _oPanel
	 
	Local lLowered  := .T.
	Local lRaised   := .T. //.T. mostra borda do painel  
	Local lCentered := .F. //.T. mostra o texto do objeto no centro painel
		
	Local aRand		:= {}
	
	oChart09 := FWChartFactory():New(0,0,50,50)
	oChart09:SetOwner(oPanel)

	cQuery := " SELECT 'XML' AS TIPO, " 					+ CHR(13) + CHR(10)
	//cQuery += "  SUM("+xZBZ+"_ICMVAL) AS ICMS, "			+ CHR(13) + CHR(10)
	//cQuery += "  SUM("+xZBZ+"_STVALO) AS ST, " 				+ CHR(13) + CHR(10)
	//cQuery += "  SUM("+xZBZ+"_IPIVAL) AS IPI, "				+ CHR(13) + CHR(10)
	//cQuery += "  SUM("+xZBZ+"_PISVAL) AS PIS, "				+ CHR(13) + CHR(10)
	//cQuery += "  SUM("+xZBZ+"_COFVAL) AS COFINS, " 			+ CHR(13) + CHR(10)
	//cQuery += "  SUM("+xZBT+"_INSVAL)	 AS INSS, "				+ CHR(13) + CHR(10)
	//cQuery += "  SUM("+xZBT+"_ISSVAL)	 AS ISS, "				+ CHR(13) + CHR(10)
	cQuery += "  SUM("+xZBT+"_IRRVAL)	 AS IR, "				+ CHR(13) + CHR(10)
	
	cQuery += "  SUM("+xZBZ+"_VLBRUT) AS VALTOT "			+ CHR(13) + CHR(10)
		
	cQuery += " FROM " + RETSQLNAME(xZBZ) + " "+xZBZ+" " 	+ CHR(13) + CHR(10)  
	
	cQuery += " INNER JOIN " + RETSQLNAME(xZBT) + " " + xZBT + " ON " + CHR(13) + CHR(10) 
	cQuery += " " + xZBT+"_FILIAL = " + xZBZ+"_FILIAL AND "			  + CHR(13) + CHR(10) 
	cQuery += " " + xZBT+"_NOTA   = " + xZBZ+"_NOTA   AND "			  + CHR(13) + CHR(10)
	cQuery += " " + xZBT+"_SERIE  = " + xZBZ+"_SERIE  AND "			  + CHR(13) + CHR(10)
	cQuery += " " + xZBT+"_CHAVE  = " + xZBZ+"_CHAVE  "				  + CHR(13) + CHR(10)
	
	cQuery += " WHERE "+xZBZ+".D_E_L_E_T_ <> '*' "			+ CHR(13) + CHR(10) 	
	cQuery += " AND "+xZBZ+"_FILIAL = '" + Alltrim(cFili) + "' "	+ CHR(13) + CHR(10)			
	cQuery += " AND "+xZBZ+"_CODFOR = '" + Alltrim(cFornec) + "' "	+ CHR(13) + CHR(10)		
	cQuery += " AND "+xZBZ+"_LOJFOR = '" + Alltrim(cLoj) + "' "		+ CHR(13) + CHR(10) 
	cQuery += " AND "+xZBZ+"_NOTA = '" + Alltrim(cNF) + "' "		+ CHR(13) + CHR(10)		
	cQuery += " AND "+xZBZ+"_SERIE = '" + Alltrim(cSerie) + "' "	+ CHR(13) + CHR(10) 
 
	cQuery += " UNION "	+ CHR(13) + CHR(10)

	cQuery += "  SELECT 'NF' AS TIPO, "  		+ CHR(13) + CHR(10)
	//cQuery += "  SUM(F1_VALICM) AS ICMS, " 	   		+ CHR(13) + CHR(10)
	//cQuery += "		SUM(F1_ICMSRET) AS ST, "   		+ CHR(13) + CHR(10)
	//cQuery += "		SUM(F1_VALIPI) AS IPI, "   		+ CHR(13) + CHR(10)
	//cQuery += "		SUM(F1_VALIMP5) AS PIS, "  		+ CHR(13) + CHR(10)
	//cQuery += "		SUM(F1_VALIMP6) AS COFINS, "	+ CHR(13) + CHR(10)
	//cQuery += "		SUM(F1_INSS) AS INSS, "	   		+ CHR(13) + CHR(10)
	//cQuery += "		SUM(F1_ISS) AS ISS, "  	   		+ CHR(13) + CHR(10)
	//cQuery += "		SUM(F1_ISS) AS ISS, "  	   		+ CHR(13) + CHR(10)
	cQuery += "		SUM(F1_IRRF) AS IR, "  	   		+ CHR(13) + CHR(10)
	cQuery += "		SUM(F1_VALBRUT) AS VALTOT "		+ CHR(13) + CHR(10)
	cQuery += " FROM "+RetSqlName('SF1')+" SF1 "	+ CHR(13) + CHR(10)
	
	cQuery += " WHERE " + CRLF
	cQuery += " SF1.F1_FILIAL 		= '" + Alltrim(cFili) 	+ "' " + CRLF
	cQuery += " AND SF1.F1_DOC 		= '" + Alltrim(cNF) 	+ "' " + CRLF
	cQuery += " AND SF1.F1_SERIE 	= '" + Alltrim(cSerie) 	+ "' " + CRLF
	cQuery += " AND  SF1.D_E_L_E_T_ <> '*' "		+ CHR(13) + CHR(10)

	cQuery += " AND SF1.F1_FORNECE = '" + Alltrim(cFornec) + "' "	+ CHR(13) + CHR(10)		
	cQuery += " AND SF1.F1_LOJA    = '" + Alltrim(cLoj) + "' "		+ CHR(13) + CHR(10)
    
    cQuery += " ORDER BY TIPO DESC " 			+ CHR(13) + CHR(10)
    
    MemoWrite("C:\TEMP\_fCompIR.sql" , cQuery )    	
	cQuery := ChangeQuery(cQuery)	               	
    
	If ( SELECT("TRB10") ) > 0
		dbSelectArea("TRB10")
		TRB10->(dbCloseArea())
	EndIf

	TcQuery cQuery Alias "TRB10" New

	TRB10->(dbGoTop())

	oChart09:SetXAxis( { "IR" } )        

	If TRB10->( !EOF() )

		oChart09:addSerie(TRB10->TIPO + "-" + Transform(TRB10->IR , "@E 999,999,999.99"), {  TRB10->IR   } )
		nTotIN	:= TRB10->IR   //Total icms da nf
			
		TRB10->(dbSkip())
		
		oChart09:addSerie(TRB10->TIPO + "-" + Transform(TRB10->IR , "@E 999,999,999.99"), {  TRB10->IR  } )
		nTotIX    := TRB10->IR	//Total icms do xml
			
	Else

		oChart09:addSerie("XML", {  0, 0  } )
		oChart09:addSerie("SF1", {  0, 0  } )				
	Endif
	
	oChart09:SetXAxis( { "IR" } )     

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
	oChart09:setPicture("@E 9,999,999,999.99")  

	//----------------------------------------------
	//Mascara
	//----------------------------------------------
	//oChart09:setMask(" *@*")  
	oChart09:setMask("R$ *@*") 					
	
	
	//Seta as cores utilizadas
	//     oChart:oFWChartColor:aRandom := aRand
	//     oChart:oFWChartColor:SetColor("Random")
	oChart09:SetLegend(CONTROL_ALIGN_LEFT)
	oChart09:setTitle("Valor Total de IR - XML x NF Entrada", CONTROL_ALIGN_CENTER) 
	//oChart:setLegend( CONTROL_ALIGN_LEFT )  			//esquerda
	oChart09:SetAlignSerieLabel(CONTROL_ALIGN_RIGHT)	//direita

	oChart09:EnableMenu(.T.)

	//Define o tipo do gráfico
	oChart09:SetChartDefault(NEWPIECHART) //(BARCOMPCHART)
	//-----------------------------------------		
	
	oChart09:OOWNER:NRIGHT := oChart09:OOWNER:NRIGHT - 150
	oChart09:OOWNER:NLEFT  := oChart09:OOWNER:NLEFT - 150
    oChart09:OOWNER:NBOTTOM := oChart09:OOWNER:NBOTTOM - 100 
    
    
	nLiFim := oChart09:OOWNER:NBOTTOM  	//853 - recebe o limite de linha final do gráfico  
	//nLiFim := nLiFim - 20            	//703
		
	nCoFim := oChart09:OOWNER:NRIGHT   	//1696
	//nCoFim := nCoFim - 30              	//1646
		
	oChart09:OOWNER:NBOTTOM := nLiFim  	//703  - altura
	oChart09:OOWNER:NRIGHT  := nCoFim  //1646 - largura
		
	nLiFim := oPanel:NBOTTOM			//703
	
	//---------------------------------------------------------//
	//painel a parte, para inserção da msg divergência	
	//---------------------------------------------------------//
	
	nLiIni := aPos[1][2]  	//3
	nCoIni := aPos[1][2]    //3
	
    If nTotIN <> nTotIX
    	nDif := Iif(nTotIN > nTotIX, nTotIN - nTotIX, nTotIX - nTotIN) 
    	cMsgDiv := "DIVERGÊNCIA ENCONTRADA: R$" + Alltrim(Transform(nDif , "@E 999,999,999.99"))
    	xCor1    := CLR_HRED 
    Else
    	cMsgDiv  := "NÃO HÁ DIVERGÊNCIAS" 
    	xCor1    := CLR_HBLUE       
    Endif     
    
	//_oPanel:= TPanel():New(nLiIni,nCoIni, , oPanel, , , , , , 0,50,lLowered,lRaised) 
	_oPanel:= TPanel():New(nLiFim+5,nCoIni,cMsgDiv, oPanel,oBold,lCentered , ,xCor1, , 0,40,lLowered,lRaised)
    _oPanel:Align := CONTROL_ALIGN_BOTTOM    
    
	oChart09:Activate()

Return Nil


//==============================================================//
// Gráfico: Valor de CSLL - XML x Entrada
//==============================================================//
Static Function _fCompCS(oPanel) 
	Local nLiIni    := 0
	Local nCoIni    := 0
	Local nLiFim    := 0
	Local nCoFim    := 0
	
	Local nTotIX    := 0
	Local nTotIN	:= 0
	Local nDif		:= 0
	Local cMsgDiv	:= ""
	Local xCor1   
		
	Local _oPanel
	 
	Local lLowered  := .T.
	Local lRaised   := .T. //.T. mostra borda do painel  
	Local lCentered := .F. //.T. mostra o texto do objeto no centro painel
		
	Local aRand		:= {}
	
	oChart09 := FWChartFactory():New(0,0,50,50)
	oChart09:SetOwner(oPanel)

	cQuery := " SELECT 'XML' AS TIPO, " 					+ CHR(13) + CHR(10)
	//cQuery += "  SUM("+xZBZ+"_ICMVAL) AS ICMS, "			+ CHR(13) + CHR(10)
	//cQuery += "  SUM("+xZBZ+"_STVALO) AS ST, " 				+ CHR(13) + CHR(10)
	//cQuery += "  SUM("+xZBZ+"_IPIVAL) AS IPI, "				+ CHR(13) + CHR(10)
	//cQuery += "  SUM("+xZBZ+"_PISVAL) AS PIS, "				+ CHR(13) + CHR(10)
	//cQuery += "  SUM("+xZBZ+"_COFVAL) AS COFINS, " 			+ CHR(13) + CHR(10)
	//cQuery += "  SUM("+xZBT+"_INSVAL)	 AS INSS, "				+ CHR(13) + CHR(10)
	//cQuery += "  SUM("+xZBT+"_ISSVAL)	 AS ISS, "				+ CHR(13) + CHR(10)
	//cQuery += "  SUM("+xZBT+"_IRRVAL)	 AS IR, "				+ CHR(13) + CHR(10)
	cQuery += "  SUM("+xZBT+"_CSLVAL)  AS CSLL, "				+ CHR(13) + CHR(10)
	
	cQuery += "  SUM("+xZBZ+"_VLBRUT) AS VALTOT "			+ CHR(13) + CHR(10)
		
	cQuery += " FROM " + RETSQLNAME(xZBZ) + " "+xZBZ+" " 	+ CHR(13) + CHR(10)  
	
	cQuery += " INNER JOIN " + RETSQLNAME(xZBT) + " " + xZBT + " ON " + CHR(13) + CHR(10) 
	cQuery += " " + xZBT+"_FILIAL = " + xZBZ+"_FILIAL AND "			  + CHR(13) + CHR(10) 
	cQuery += " " + xZBT+"_NOTA   = " + xZBZ+"_NOTA   AND "			  + CHR(13) + CHR(10)
	cQuery += " " + xZBT+"_SERIE  = " + xZBZ+"_SERIE  AND "			  + CHR(13) + CHR(10)
	cQuery += " " + xZBT+"_CHAVE  = " + xZBZ+"_CHAVE  "				  + CHR(13) + CHR(10)
	
	cQuery += " WHERE "+xZBZ+".D_E_L_E_T_ <> '*' "			+ CHR(13) + CHR(10) 	
	cQuery += " AND "+xZBZ+"_FILIAL = '" + Alltrim(cFili) + "' "	+ CHR(13) + CHR(10)			
	cQuery += " AND "+xZBZ+"_CODFOR = '" + Alltrim(cFornec) + "' "	+ CHR(13) + CHR(10)		
	cQuery += " AND "+xZBZ+"_LOJFOR = '" + Alltrim(cLoj) + "' "		+ CHR(13) + CHR(10) 
	cQuery += " AND "+xZBZ+"_NOTA = '" + Alltrim(cNF) + "' "		+ CHR(13) + CHR(10)		
	cQuery += " AND "+xZBZ+"_SERIE = '" + Alltrim(cSerie) + "' "	+ CHR(13) + CHR(10) 
 
	cQuery += " UNION "	+ CHR(13) + CHR(10)

	cQuery += "  SELECT 'NF' AS TIPO, "  		+ CHR(13) + CHR(10)
	//cQuery += "  SUM(F1_VALICM) AS ICMS, " 	   		+ CHR(13) + CHR(10)
	//cQuery += "		SUM(F1_ICMSRET) AS ST, "   		+ CHR(13) + CHR(10)
	//cQuery += "		SUM(F1_VALIPI) AS IPI, "   		+ CHR(13) + CHR(10)
	//cQuery += "		SUM(F1_VALIMP5) AS PIS, "  		+ CHR(13) + CHR(10)
	//cQuery += "		SUM(F1_VALIMP6) AS COFINS, "	+ CHR(13) + CHR(10)
	//cQuery += "		SUM(F1_INSS) AS INSS, "	   		+ CHR(13) + CHR(10)
	//cQuery += "		SUM(F1_ISS) AS ISS, "  	   		+ CHR(13) + CHR(10)
	//cQuery += "		SUM(F1_ISS) AS ISS, "  	   		+ CHR(13) + CHR(10)
	//cQuery += "		SUM(F1_IRRF) AS IR, "  	   		+ CHR(13) + CHR(10)
	cQuery += "		SUM(F1_VALCSLL) AS CSLL, "     		+ CHR(13) + CHR(10)
	
	cQuery += "		SUM(F1_VALBRUT) AS VALTOT "		+ CHR(13) + CHR(10)
	cQuery += " FROM "+RetSqlName('SF1')+" SF1 "	+ CHR(13) + CHR(10)
	
	cQuery += " WHERE " + CRLF
	cQuery += " SF1.F1_FILIAL 		= '" + Alltrim(cFili) 	+ "' " + CRLF
	cQuery += " AND SF1.F1_DOC 		= '" + Alltrim(cNF) 	+ "' " + CRLF
	cQuery += " AND SF1.F1_SERIE 	= '" + Alltrim(cSerie) 	+ "' " + CRLF
	cQuery += " AND  SF1.D_E_L_E_T_ <> '*' "		+ CHR(13) + CHR(10)

	cQuery += " AND SF1.F1_FORNECE = '" + Alltrim(cFornec) + "' "	+ CHR(13) + CHR(10)		
	cQuery += " AND SF1.F1_LOJA    = '" + Alltrim(cLoj) + "' "		+ CHR(13) + CHR(10)
    
    cQuery += " ORDER BY TIPO DESC " 			+ CHR(13) + CHR(10)
    
    MemoWrite("C:\TEMP\_fCompCS.sql" , cQuery )    	
	cQuery := ChangeQuery(cQuery)	               	
    
	If ( SELECT("TRB10") ) > 0
		dbSelectArea("TRB10")
		TRB10->(dbCloseArea())
	EndIf

	TcQuery cQuery Alias "TRB10" New

	TRB10->(dbGoTop())

	oChart09:SetXAxis( { "CSLL" } )        

	If TRB10->( !EOF() )

		oChart09:addSerie(TRB10->TIPO + "-" + Transform(TRB10->CSLL , "@E 999,999,999.99"), {  TRB10->CSLL   } )
		nTotIN	:= TRB10->CSLL   //Total icms da nf
			
		TRB10->(dbSkip())
		
		oChart09:addSerie(TRB10->TIPO + "-" + Transform(TRB10->CSLL , "@E 999,999,999.99"), {  TRB10->CSLL  } )
		nTotIX    := TRB10->CSLL	//Total icms do xml
			
	Else

		oChart09:addSerie("XML", {  0, 0  } )
		oChart09:addSerie("SF1", {  0, 0  } )				
	Endif
	
	oChart09:SetXAxis( { "CSLL" } )     

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
	oChart09:setPicture("@E 9,999,999,999.99")  

	//----------------------------------------------
	//Mascara
	//----------------------------------------------
	//oChart09:setMask(" *@*")  
	oChart09:setMask("R$ *@*") 					
	
	
	//Seta as cores utilizadas
	//     oChart:oFWChartColor:aRandom := aRand
	//     oChart:oFWChartColor:SetColor("Random")
	oChart09:SetLegend(CONTROL_ALIGN_LEFT)
	oChart09:setTitle("Valor Total de CSLL - XML x NF Entrada", CONTROL_ALIGN_CENTER) 
	//oChart:setLegend( CONTROL_ALIGN_LEFT )  			//esquerda
	oChart09:SetAlignSerieLabel(CONTROL_ALIGN_RIGHT)	//direita

	oChart09:EnableMenu(.T.)

	//Define o tipo do gráfico
	oChart09:SetChartDefault(NEWPIECHART) //(BARCOMPCHART)
	//-----------------------------------------		
	
	oChart09:OOWNER:NRIGHT := oChart09:OOWNER:NRIGHT - 150
	oChart09:OOWNER:NLEFT  := oChart09:OOWNER:NLEFT - 150
    oChart09:OOWNER:NBOTTOM := oChart09:OOWNER:NBOTTOM - 100 
    
    
	nLiFim := oChart09:OOWNER:NBOTTOM  	//853 - recebe o limite de linha final do gráfico  
	//nLiFim := nLiFim - 20            	//703
		
	nCoFim := oChart09:OOWNER:NRIGHT   	//1696
	//nCoFim := nCoFim - 30              	//1646
		
	oChart09:OOWNER:NBOTTOM := nLiFim  	//703  - altura
	oChart09:OOWNER:NRIGHT  := nCoFim  //1646 - largura
		
	nLiFim := oPanel:NBOTTOM			//703
	
	//---------------------------------------------------------//
	//painel a parte, para inserção da msg divergência	
	//---------------------------------------------------------//
	
	nLiIni := aPos[1][2]  	//3
	nCoIni := aPos[1][2]    //3
	
    If nTotIN <> nTotIX
    	nDif := Iif(nTotIN > nTotIX, nTotIN - nTotIX, nTotIX - nTotIN) 
    	cMsgDiv := "DIVERGÊNCIA ENCONTRADA: R$" + Alltrim(Transform(nDif , "@E 999,999,999.99"))
    	xCor1    := CLR_HRED 
    Else
    	cMsgDiv  := "NÃO HÁ DIVERGÊNCIAS" 
    	xCor1    := CLR_HBLUE       
    Endif     
    
	//_oPanel:= TPanel():New(nLiIni,nCoIni, , oPanel, , , , , , 0,50,lLowered,lRaised) 
	_oPanel:= TPanel():New(nLiFim+5,nCoIni,cMsgDiv, oPanel,oBold,lCentered , ,xCor1, , 0,40,lLowered,lRaised)
    _oPanel:Align := CONTROL_ALIGN_BOTTOM    
    
	oChart09:Activate()

Return Nil



//==============================================================//
// FIM GRÁFICOS COMPARATIVOS TOTAIS XML x Entrada
//==============================================================//


//FIM GERAÇÃO DE MASSA DE DADOS

//LOCALIZA AMARRAÇÃO
//----------------------------------------------------------------------------------//
//Função : fTemAmarr
//Autoria: Flávia Rocha
//Data   : 30/03/2021
//Objetivo: Função para verificar se tem amarração na SA5 ou ZB5 e retorna o
//          código interno, mediante código/loja e produto do fornecedor passados
//          por parâmetros.
//----------------------------------------------------------------------------------//
Static Function fTemAmarr(cCodEmit,cLojaEmit,cProd,cTiprod,cTipomarra)
Local cQuery 		:= ""
Local LF     		:= CHR(13) + CHR(10)
Local lTemSA5		:= .F.
Local cProdInterno 	:= "" 
Local cProdForn     := ""
Local lSoZB5        := .F. 
Local aRetProd      := {} 
Local cAmarr        := ""

Private xZB5  	  := GetNewPar("XM_TABAMAR","ZB5")
Private xZB5_ 	  := iif(Substr(xZB5,1,1)=="S", Substr(xZB5,2,2), Substr(xZB5,1,3)) + "_"

If cTipomarra <> Nil
	If cTipomarra == '2'   //ZB5
		lSoZB5 := .T.
	Endif
Endif

If !lSoZB5

	If _cTblCad == "SA2"
	
		cQuery := " SELECT " + LF
		cQuery += " A5_FORNECE FORNECE , " + LF
		cQuery += " A5_LOJA LOJA       , " + LF
		cQuery += " A5_CODPRF PRODFO   , " + LF  	//código produto do fornecedor
		cQuery += " A5_PRODUTO PRODFI  "   + LF	//código produto interno
		cQuery += ",* " + LF	
		cQuery += " FROM "       + RetSqlName("SA5") + " SA5 "	+ LF
		cQuery += " WHERE "								        + LF
		cQuery += " SA5.D_E_L_E_T_ <> '*' "				        + LF
		cQuery += " AND A5_FILIAL= '" + Alltrim(xFilial("SA5")) +  "' " + LF
		cQuery += " AND A5_FORNECE ='" + Alltrim(cCodEmit) + "' "      + LF
		cQuery += " AND A5_LOJA ='" + Alltrim(cLojaEmit) + "' "        + LF
			
		If cTiprod == "I"    //I=traz o código do produto interno (SB1) - Se é para trazer o código interno, informa o produto do fornecedor
			cQuery += " AND A5_CODPRF ='" + Alltrim(cProd) + "' "      + LF
		Elseif cTiprod == "F" //F=traz o código do produto do fornecedor - Se é para trazer o código do fornecedor, informa o código interno 
			cQuery += " AND A5_PRODUTO ='" + Alltrim(cProd) + "' "      + LF
		Endif
		cQuery += " ORDER BY A5_FILIAL, A5_FORNECE, A5_LOJA, A5_PRODUTO "
	
	Elseif _cTblCad == "SA1"
	
		cQuery := " SELECT " + LF 
		cQuery += " A7_FILIAL FILIAL, "  + LF
		cQuery += " A7_CLIENTE CLIENT, " + LF     //Código cliente
		cQuery += " A7_LOJA LOJA, "      + LF     //Loja cliente
		cQuery += " A7_CODCLI PRODFO , " + LF     //Código produto vindo do cliente
		cQuery += " A7_PRODUTO PRODFI  " + LF     //Código produto nosso 
		cQuery += " FROM " + RetSqlName("SA7") + " SA7 "+ LF
		cQuery += " WHERE "								+ LF
		If cTiprod == "I"    //I=traz o código do produto interno (SB1) - Se é para trazer o código interno, informa o produto do fornecedor
			cQuery += " A7_CODCLI = '" + Alltrim(cProd) + "' " 		+ LF
		Elseif cTiprod == "F" //F=traz o código do produto do fornecedor - Se é para trazer o código do fornecedor, informa o código interno 
			cQuery += " AND A7_PRODUTO ='" + Alltrim(cProd) + "' "  + LF
		Endif 
		cQuery += " ORDER BY A7_FILIAL, A7_CLIENTE, A7_LOJA, A7_CODCLI "
	
	Endif
	
		
	MemoWrite("C:\TEMP\1fBuscaSA5_SA7.sql" , cQuery)
	
	cQuery := ChangeQuery( cQuery )		
	If Select("TMPSA57") > 0
		dbSelectArea("TMPSA57")
		TMPSA5->(dbCloseArea())
	EndIf
	
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPSA57", .T., .F. )
	DbSelectArea("TMPSA57")
	DbGoTop() 
		
	If TMPSA57->(!Eof())
		cProdInterno := TMPSA57->PRODFI 
		cProdForn    := TMPSA57->PRODFO
		lTemSA5      := .T.
		cAmarr       := "SA5"
	Endif
	dbSelectArea("TMPSA57")
	TMPSA57->(dbCloseArea())
	
Endif //!lSoZB5 - só faz a consulta acima se não estiver fechado que a consulta é pela ZB5

If !lTemSA5  .or. lSoZB5 .or. Empty(cProdInterno) 	//Se não encontrou a amarração na SA5, ou se a consulta está parametrizada para ser feita apenas pela ZB5, ou se não encontrou nada em nenhuma consulta

	cQuery := " SELECT " + LF
	cQuery += ""+xZB5_+"FORNEC FORNEC, " + LF
	cQuery += ""+xZB5_+"LOJFOR LOJFOR, " + LF
	cQuery += ""+xZB5_+"CLIENT CLIENT, " + LF
	cQuery += ""+xZB5_+"LOJCLI LOJCLI, " + LF
	cQuery += ""+xZB5_+"PRODFO PRODFO, " + LF
	cQuery += ""+xZB5_+"PRODFI PRODFI "  + LF
	cQuery += ",* " + LF	
	cQuery += " FROM "       + RetSqlName(xZB5) + " ZB5 "			+ LF
	cQuery += " WHERE "								+ LF
	cQuery += " ZB5.D_E_L_E_T_ <> '*' "				+ LF
	cQuery += " AND "+ xZB5_+"FILIAL= '" + Alltrim(xFilial(xZB5)) +  "' " + LF
	If _cTblCad == "SA2"
	
		cQuery += " AND "+ xZB5_+"FORNEC ='" + Alltrim(cCodEmit) + "' " + LF
		cQuery += " AND "+ xZB5_+"LOJFOR ='" + Alltrim(cLojaEmit) + "' " + LF	
	Elseif _cTblCad == "SA1" 
	
		cQuery += " AND "+ xZB5_+"CLIENT ='" + Alltrim(cCodEmit) + "' " + LF
		cQuery += " AND "+ xZB5_+"LOJCLI ='" + Alltrim(cLojaEmit) + "' " + LF
	Endif
	
	If cTiprod == "I"    //Se é para trazer o código interno, informa o produto do fornecedor
		cQuery += " AND "+ xZB5_+"PRODFO ='" + Alltrim(cProd) + "' " + LF
	Elseif cTiprod == "F" //Se é para trazer o código do fornecedor, informa o código interno
		cQuery += " AND "+ xZB5_+"PRODFI ='" + Alltrim(cProd) + "' " + LF
	Endif
	cQuery += " ORDER BY " + xZB5_+"FILIAL, " + xZB5_+"FORNEC, " + xZB5_+"LOJFOR, " + xZB5_+"PRODFI "

	MemoWrite("C:\TEMP\1fBuscaZB5.sql" , cQuery)
	
	cQuery := ChangeQuery( cQuery )		
	If Select("TMPZB5") > 0
		dbSelectArea("TMPZB5")
		TMPZB5->(dbCloseArea())
	EndIf
	
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPZB5", .T., .F. )
	DbSelectArea("TMPZB5")
	DbGoTop() 

	If TMPZB5->(!Eof())	
		cProdInterno := TMPZB5->PRODFI
		cProdForn    := TMPZB5->PRODFO 
		cAmarr       := "ZB5"
	Endif

	dbSelectArea("TMPZB5")
	TMPZB5->(dbCloseArea())

Endif

If cTiprod == "I" //Retorna o produto interno 
	Aadd(aRetProd, cProdInterno)
	Aadd(aRetProd, cAmarr      )
	//Return(cProdInterno) 	
Elseif cTiprod == "F" //Retorna o produto fornecedor
	Aadd(aRetProd, cProdForn)
	Aadd(aRetProd, cAmarr   )
	//Return(cProdForn)
Endif

Return(aRetProd)

//LOCALIZA AMARRAÇÃO


///NOVO



/*====================================================================================\
|Programa  | STRESTH1        |							         | Data | 02/09/2020  |
|=====================================================================================|
|Descrição | RETORNA VARIAVEL CONVERTIDA			                                  |
\====================================================================================*/
Static Function STRESTH1(_cCampo,_cVal)

	Local _aAreaSX3 := SX3->(GetArea())
	Local _xVal 	:= ""

	DbSelectArea("SX3")
	SX3->(DbGoTop())
	SX3->(DbSetOrder(2))

	If SX3->(DbSeek(_cCampo))

		If SX3->X3_TIPO == 'C' .Or. SX3->X3_TIPO == 'M'
			_xVal := _cVal
		ElseIf SX3->X3_TIPO == 'D'
			//_xVal := CtoD(_cVal)
			_xVal := StoD(_cVal)
		ElseIf SX3->X3_TIPO == 'N'
			//_xVal := Val(_cVal)
			_xVal := Round(_cVal,2)
		Else
			If _cVal == ".T."
				_xVal := .T.
			Else
				_xVal := .F.
			Endif
		EndIf

	EndIf

	RestArea(_aAreaSX3)

Return(_xVal)
