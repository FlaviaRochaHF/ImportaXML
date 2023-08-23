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
Static cIdEnt := U_GetIdEnt()



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HFXML020  ºAutor  ³Eneovaldo Roveri Jr º Data ³    /  /     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotinas Complementares HFXML02                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ HFXML02                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//--------------------------------------------------------------//
//FR - 08/05/2020 - Alterações realizadas para adequar na rotina 
//                  Pré Auditoria Fiscal verificação de 
//                  divergências entre XML x NF 
//-------------------------------------------------------------//
//Heverton Marcondes
//   - 17/08/2020 - Alterações realizadas para adequar na rotina 
//                  de manifestação, retorno da Sefaz
//-------------------------------------------------------------//
//FR - 18/08/2020 - Projeto Kroma, alteraçõe relativas a
//                  Amarração Pedido Compra , quando vem no XML
//                  pela tag cXPed, capturar automático
//                  "Tópicos Rafael relativo ao Ped. Compra" 
//-------------------------------------------------------------//
//FR - 30/09/2020 - Criar sistemática para obter e mostrar em
//                  tela, o retorno da SEFAZ 
//                  (Gravar na ZBE os redownloads efetuados)
//-------------------------------------------------------------//
//FR - 25/10/2020 - Cliente: Grupo Ric:
//			     	Na tela de seleção do pedido de compra,
//                  incluir coluna "Total do pedido"
//--------------------------------------------------------------------------// 
//FR - 18/11/2020 - Chamados: #5762 , #5759 - ADAR
//                  Adequação na amarração de produtos
//                  Possibilitar ao cliente aglutinar ou não
//                  Produtos do XML que tenham um mesmo código
//                  na SB1 (via alinhamento com o parâmetro padrão
//                  MV_NGAGLPC 
//--------------------------------------------------------------//
//FR - 24/11/2020 - melhoria no posicionamento do array de itens
//                  depois que sai da função HFXML023
//--------------------------------------------------------------//
//FR - 28/12/2020 - #5922 - Chamado Razzo
//                  Tratativa para incluir informação do número
//                  da OS no item da NF (chamada do XMLPEITE)
//--------------------------------------------------------------//    
//FR - 23/02/2021 - #6226 - Chamado Mectronics
//                  Correção na amarração de mais de um pedido
//--------------------------------------------------------------//   
//FR - 31/03/2021 - Carregar número de lote do fornecedor na 
//                  geração da nota
//                  Solicitado por Rafael Lobitsky
//					Revisão do array de campos em todas
//                  amarrações
//-----------------------------------------------------------------------------//
//FR - 05/05/2021 - #10382 - Kroma - tratativa para chamada dentro do Schedule 
//-----------------------------------------------------------------------------// 
//FR - 07/06/2021 - Rollback das alterações da Kroma
//-----------------------------------------------------------------------------// 
//FR - 29/06/2021 - #10842 - Cimentos Itambé
//                  Mudança na mensagem de manifestação
//-----------------------------------------------------------------------------// 
//FR - 22/07/2021 - #10981 - Sideral - problema na manifestação na classificação
//                  da nota (rotina disparada do fonte HFXML12)
//-----------------------------------------------------------------------------//
//FR - 30/11/2021 - #11584 - ADAR - erro casas decimais
//-----------------------------------------------------------------------------//
//FR - 04/05/2022 - ALTERAÇÃO - #12673 - ICOMON - correção do erro variável 
//                  não é objeto, verificar antes se oDet é tipo array 
//                  ou tipo objeto, (EX: NF 000125218)
//-----------------------------------------------------------------------------//
//FR - 07/06/2022 - ALTERAÇÃO - #12850 - AGUAS DO BRASIL
//                  Restringir pedidos rejeitados pela alçada de compras
//                  na seleção de pedidos de compra 
//                  (não pode aparecer pedido rejeitado)
//-----------------------------------------------------------------------------//
//FR - 14/06/2022 - Brasmolde - PEDIDO DE COMPRA EM DÓLAR E NF EM REAIS
//					Validação item por item do pedido de compra para checar
//                  divergência de valor do PC x XML
//                  Converte o valor do item no xml, utilizando a taxa moeda 
//                  do pedido, porque a NF vem em REAIS
//--------------------------------------------------------------------------//
//FR - 29/08/2022 - ECOAUTOMAÇÃO - #13255 - Revisão referente a tela que seleciona 
//                  o pedido de compra, só pode associar automático item pc com item xml
//                  apenas se todos os itens possuirem saldo pelo SC7, caso não atenda, 
//                  será mostrada a tela PC x XML para que seja feita a associação
//                  manualmente
//------------------------------------------------------------------------------------//
//FR - 19/09/2022 - ALTERAÇÃO - Flávia Rocha - PROJETO PAPIRUS
//------------------------------------------------------------------------------------//
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ HFXMLPED ºAutor  ³Eneovaldo Roveri Jr º Data ³  06/11/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gerar aItens a partir do pedido e confrontar valores totaisº±±
±±º          ³ com o XML.                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ HFXML02                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function HFXMLPED(xCod,xLoj,xTip)

Local aArea   := GetArea()
//Local lRet    := .T.
Local aHeadSEV:= {}
Local aColsSEV:= {}
Private cA100For := xCod
Private cLoja    := xLoj
Private cTipo    := xTip
Private lConsLoja:= .T.
Private aCols    := {}
Private aHeader  := {}
Private N        := 1
PRIVATE lVldHead := GetNewPar( "MV_VLDHEAD",.F. )// O parametro MV_VLDHEAD e' usado para validar ou nao o aCols (uma linha ou todo), a partir das validacoes do aHeader -> VldHead()
Private lContinua:= .T.            	//FR - 18/08/2020 - qdo retorna da função AMAPC , está fazendo duas vezes, então colocando o lContinua barra essa 2a. rodada

aRet := U_AMAPC(,,,,,aHeadSEV,aColsSEV,@lContinua)

RestArea(aArea)

Return(aRet)


//+----------------------------------------------------------------------------------------//
//|Funcao....: AMAPC
//|Descricao.: Efetua a amarração do pedido de compra à NF a ser gerada
//|Observação: 
//+----------------------------------------------------------------------------------------//
User Function AMAPC(aGets,lNfMedic,lConsMedic,aHeadSDE,aColsSDE,aHeadSEV, aColsSEV,lContinua)

Local lRet       := .T.
Local nSldPed    := 0
Local nOpc       := 0
//Local nx         := 0
Local cQuery     := ""
Local cAliasSC7  := "SC7"
Local lQuery     := .F.
Local bSavSetKey := SetKey(VK_F4,Nil)
Local bSavKeyF5  := SetKey(VK_F5,Nil)
Local bSavKeyF6  := SetKey(VK_F6,Nil)
Local bSavKeyF7  := SetKey(VK_F7,Nil)
Local bSavKeyF8  := SetKey(VK_F8,Nil)
Local bSavKeyF9  := SetKey(VK_F9,Nil)
Local bSavKeyF10 := SetKey(VK_F10,Nil)
Local bSavKeyF11 := SetKey(VK_F11,Nil)
Local cChave     := ""
//Local cCadastro  := ""
Local aArea      := GetArea()
Local aAreaSA2   := SA2->(GetArea())
Local aAreaSC7   := {} //SC7->(GetArea()) //FR - 14/10/2019 - erro na saída do programa, não reconhece esta área
Local nF4For     := 0
Local oOk        := LoadBitMap(GetResources(), "LBOK")
Local oNo        := LoadBitMap(GetResources(), "LBNO")
Local lGspInUseM := If(Type('lGspInUse')=='L', lGspInUse, .F.)
Local aButtons   := { {'PESQUISA',{||U_H20VisuPC(aRecSC7[oListBox:nAt])},OemToAnsi("Visualiza Pedido")} } //"Visualiza Pedido"
Local oDlg,oListBox
Local cNomeFor   := ''
//Cabeçalho de amarração por Pedido -> CNPJ Fornecedor, Data Emissão, Chave do XML.
//20/09/2022 ->LUCAS SAN
Local cCNPJFor		:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ")))			  //Carrega CNPJ FORNECEDOR NO CABEÇALHO
Local dDataEmi	 	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"DTNFE")))			 //carrega dados data de emissão do xml no cabeçalho
Local cChaveXML		:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))) 			//carrega dados da chave do xml no cabeçalho
Local cInfoCompl 	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"ICOMPL")))		   //Carrega informações Complementares
Local cLojaFor 		:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR")))
Local cDocFiscal 	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA")))		   
Local cCodFor 		:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR")))
Local aTitCampos := {}
Local aConteudos := {}
Local aUsCont    := {}
Local aUsTitu    := {}
Local bLine      := { || .T. }
Local cLine      := ""
Local lMa103F4I  := ExistBlock( "MA103F4I" )
Local nLoop      := 0
Local lMt103Vpc  := ExistBlock("MT103VPC")
Local lRet103Vpc := .T.
//Local lContinua  := .T.
Local oPanel
Local nNumCampos := 0
//Local nPosCC     := 0 //aScan(aHeader,{|x| AllTrim(x[2])=="D1_CC"})         //HF
//Local nPosPRD	 := 0 //aScan(aHeader,{|x| Alltrim(x[2])=="D1_COD"})        //HF
Local aWBrowse   := {}
Local cVerLoja		:= SuperGetMv("XM_VERLOJA",.T.,"N") //Criado analista Alexandro e Rodrigo dia 30/06/2016, referente a amarrão por pedido.
Local cModelo 	 := "" //FR - 04/10/2019 - Criado por Flávia Rocha para obter qual o modelo que está sendo lido neste momento: XML ou CTe
//Local oXmLL  
Local aPedidos   := {}  	//FR - 11/05/2020
Local aPedAux    := {}		//FR - 11/09/2020
//Local nTem       := 0		//FR - 06/08/2020

local aSize   := MsAdvSize()
local aInfo   :={aSize[1], aSize[2], aSize[3], aSize[4], 3, 3}

nTopEnch      := 014
nBotEnch      := round((aInfo[4]/5)*2,0)
                                  
nTopGet       := (nBotEnch + 1)
nBotGet       := aInfo[4] // - nTopGet - 50

Local aPedXML    := {}  	//FR - 06/08/2020
Local cXml		 			//FR - 06/08/2020
Local aIteXML	  := {}  	//FR - 06/08/2020 
//Local cSeparadores:= ""		//FR - 18/08/2020
Local cPedXML	  := ""		//FR - 18/08/2020
Local cPedXMLAnt  := ""		//FR - 18/08/2020 - guarda a decisão anterior
Local nAviso      := 0 		//FR - 19/09/2022 - ALTERAÇÃO - Flávia Rocha - PROJETO PAPIRUS
Local cTitulo     := ""		//FR - 17/10/2022 - ALTERAÇÃO - Flávia Rocha - PROJETO PAPIRUS
Local cTravPreNF  := GetNewPar("XM_PED_GBR","N")

Local fr		  := 0
PRIVATE aF4For    := {}
PRIVATE aRecSC7   := {} 
PRIVATE lPCXMLAtend:= .F.		//FR - 06/08/2020  //indica se o pedido definido no XML encontrado no SC7 atende a NF (pois verificamos o saldo)

Private xZBZ  	  := GetNewPar("XM_TABXML","ZBZ")
Private xZBZ_ 	  := iif(Substr(xZBZ,1,1)=="S", Substr(xZBZ,2,2), Substr(xZBZ,1,3)) + "_"
Private xZB5  	  := GetNewPar("XM_TABAMAR","ZB5")
Private xZB5_ 	  := iif(Substr(xZB5,1,1)=="S", Substr(xZB5,2,2), Substr(xZB5,1,3)) + "_"
Private xZBS  	  := GetNewPar("XM_TABSINC","ZBS")
Private xZBS_ 	  := iif(Substr(xZBS,1,1)=="S", Substr(xZBS,2,2), Substr(xZBS,1,3)) + "_"
Private xZBE      := GetNewPar("XM_TABEVEN","ZBE")
Private xZBE_     := iif(Substr(xZBE,1,1)=="S", Substr(xZBE,2,2), Substr(xZBE,1,3)) + "_"
Private xZBT      := GetNewPar("XM_TABITEM","ZBT") 
Private xZBT_ 	  := iif(Substr(xZBT,1,1)=="S", Substr(xZBT,2,2), Substr(xZBT,1,3)) + "_"
Private xZBA  	  := GetNewPar("XM_TABAMA2","ZBA")
Private xZBA_ 	  := iif(Substr(xZBA,1,1)=="S", Substr(xZBA,2,2), Substr(xZBA,1,3)) + "_"
Private xZBC      := GetNewPar("XM_TABCAC","ZBC")
Private xZBC_     := iif(Substr(xZBC,1,1)=="S", Substr(xZBC,2,2), Substr(xZBC,1,3)) + "_"
Private xZBO      := GetNewPar("XM_TABOCOR","ZBO"), xRetSEF := ""
Private xZBO_     := iif(Substr(xZBO,1,1)=="S", Substr(xZBO,2,2), Substr(xZBO,1,3)) + "_"
Private xZBI      := GetNewPar("XM_TABIEXT","ZBI")
Private xZBI_     := iif(Substr(xZBI,1,1)=="S", Substr(xZBI,2,2), Substr(xZBI,1,3)) + "_"
Private oInfo
Private oLer
//POIS O ARRAY AF4FOR PODE VARIAR EM TAMANHO
Private xPosItem  := 0 
Private aSizeAut  := {}  
Private aPos      := {} 

DEFAULT aGets     := {}
DEFAULT lNfMedic  := .F.
DEFAULT lConsMedic:= .F.
DEFAULT aHeadSDE  := {}
DEFAULT aColsSDE  := {}

#DEFINE TOP

DbSelectArea("SC7")
Aadd(aAreaSC7, SC7->(GetArea()) )

If lContinua                    
	cTitulo := OemToAnsi("Selecionar Pedido de Compra - <F5> ")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o aCols esta vazio, se o Tipo da Nota e'     ³
		//³ normal e se a rotina foi disparada pelo campo correto    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cTipo == "N"
			DbSelectArea("SA2")
			DbSetOrder(1)
			MsSeek(xFilial("SA2")+cA100For+cLoja)
			cNomeFor	:= cA100For + "/" + cLoja + " - " + SA2->A2_NOME		//FR - 19/09/2022 - PROJETO PAPIRUS

			#IFDEF TOP
				DbSelectArea("SC7")				
				If TcSrvType() <> "AS/400"
					SC7->( DbSetOrder( 9 ) ) 				
					lQuery    := .T.
					cAliasSC7 := "QRYSC7"
					cQuery := "SELECT R_E_C_N_O_ RECSC7 "
					cQuery += " ,C7_NUM, C7_PRODUTO, C7_QUANT, C7_QUJE, C7_QTDACLA, "
					cQuery += " C7_DATPRF, "
					//----------------------------------------------------------------------------//
					//FR - 19/09/2022 - ALTERAÇÃO PROJETO PAPIRUS
					//OBJETIVO: propiciar tela de seleção de pedido de compra por item
					//REVISÃO DA QUERY PARA TRAZER O ITEM CASO A OPÇÃO NO PARÂMETRO 
					//ESTIVER CONFIGURADA = "3" (POR ITEM DE PEDIDO)
					//----------------------------------------------------------------------------//
					//FR - 25/10/2020 - traz o total do pedido pela soma dos itens do mesmo: 
					cQuery += " ( SELECT SUM(C7_TOTAL) FROM " + RetSqlName("SC7") + " SC7A " 
					cQuery += "                        WHERE SC7A.C7_FILIAL = SC7.C7_FILIAL "
					cQuery += "                        AND   SC7A.C7_NUM    = SC7.C7_NUM 
					cQuery += "                        AND   SC7A.D_E_L_E_T_ <> '*' ) TOTALPED, " 
					//FR - 25/10/2020
					
					//FR - 19/09/2022 - PROJETO PAPIRUS - TRAZ O DETALHE DE CADA ITEM
						cQuery += " C7_ITEM, " + CHR(13) + CHR(10)
						cQuery += " C7_PRODUTO, " + CHR(13) + CHR(10)
						cQuery += " C7_DESCRI, " + CHR(13) + CHR(10)
						cQuery += " C7_QUANT , " + CHR(13) + CHR(10)
						cQuery += " (C7_QUANT-C7_QUJE-C7_QTDACLA) AS SALDO, " + CHR(13) + CHR(10)
						cQuery += " C7_PRECO, " + CHR(13) + CHR(10)
						cQuery += " C7_TOTAL " + CHR(13) + CHR(10)
					//FR - 19/09/2022 - PROJETO PAPIRUS
					cQuery += " FROM " + RetSqlName("SC7") + " SC7 "
					cQuery += "WHERE "
					cQuery += "C7_FILENT = '"+xFilEnt(xFilial("SC7"))+"' AND "
					If HasTemplate( "DRO" ) .AND. FunName() == "MATA103" .AND. MV_PAR15 == 1
						cQuery += "C7_FORNECE IN ( " + T_DrogForn( cA100For ) + " ) AND "
					Else
					cQuery += "C7_FORNECE = '"+cA100For+"' AND "		    		
					EndIf
					cQuery += "(C7_QUANT-C7_QUJE-C7_QTDACLA)>0 AND "
					cQuery += "C7_RESIDUO=' ' AND "
					cQuery += "C7_TPOP<>'P' AND "

					If SuperGetMV("MV_RESTNFE")=="S"
						//cQuery += "C7_CONAPRO<>'B' AND "
						cQuery += " C7_CONAPRO NOT IN ('B','R' ) AND " //FR - 07/06/2022 - AGUAS DO BRASIL - RESTRINGIR PEDIDOS BLOQUEADOS/REJEITADOS PELA ALÇADA APROVAÇÃO
					EndIf 										
                    /*
					If ( lConsLoja )
						cQuery += "C7_LOJA = '"+cLoja+"' AND "		    							
					Endif
					*/
					IF AllTrim(cVerLoja)=="S" /*Criado analista Alexandro e Rodrigo dia 30/06/2016, referente a amarrão por pedido.*/
						cQuery += "C7_LOJA = '"+cLoja+"' AND "		    							
					EndIF			

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

					if nAmarris == 2
						if .not. empty( cPedidis )
							cQuery += "SC7.C7_NUM in ("+cPedidis+") AND "
						else
							cQuery += "SC7.C7_NUM = '"+cPedidis+"' AND "  //Alterei aqui
						endif
					endif
					cQuery += "SC7.D_E_L_E_T_ = ' '"
					cQuery += "ORDER BY " + SqlOrder( SC7->( IndexKey() ) )

                    MemoWrite("C:\TEMP\HFXML020_SC7.SQL",cQuery)
					cQuery := ChangeQuery(cQuery)

					If Select(cAliasSC7) > 0
						dbSelectArea(cAliasSC7)
						(cAliasSC7)->(dbCloseArea())
					EndIf
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC7,.T.,.T.)
				Else

			#ENDIF
				DbSelectArea("SC7")
				DbSetOrder(9)
				If ( lConsLoja )
					cChave := cA100For+CLOJA
				Else
					cChave := cA100For
				EndIf
				MsSeek(xFilEnt(xFilial("SC7"))+cChave,.T.)
				#IFDEF TOP
				Endif
				#ENDIF
			Do While If(lQuery, ;
					(cAliasSC7)->(!Eof()), ;
					(cAliasSC7)->(!Eof()) .And. xFilEnt(xFilial('SC7'))+cA100For==(cAliasSC7)->C7_FILENT+(cAliasSC7)->C7_FORNECE .And. If(lConsLoja, CLOJA==(cAliasSC7)->C7_LOJA, .T.))

				If lQuery
					('SC7')->(dbGoto((cAliasSC7)->RECSC7))
				EndIf

				lRet103Vpc := .T.

				If lMt103Vpc
					lRet103Vpc := Execblock("MT103VPC",.F.,.F.)
				Endif

				lProssegue := .F.

				If lRet103Vpc
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica o Saldo do Pedido de Compra                     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nSldPed := ('SC7')->C7_QUANT - ('SC7')->C7_QUJE - ('SC7')->C7_QTDACLA
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica se nao h  residuos, se possui saldo em abto e   ³
					//³ se esta liberado por alcadas se houver controle.         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					//If ( Empty(('SC7')->C7_RESIDUO) .And. nSldPed > 0 .And.;
							//If(SuperGetMV("MV_RESTNFE")=="S",('SC7')->C7_CONAPRO <> "B",.T.).And.;
							//('SC7')->C7_TPOP <> "P" )
						
					If ( Empty(('SC7')->C7_RESIDUO) .And. nSldPed > 0 .And. ('SC7')->C7_TPOP <> "P" )
						lProssegue := .T.
					Else 
						lProssegue := .F. 
					Endif
						 	
					If lProssegue 
						
						If(SuperGetMV("MV_RESTNFE")=="S")  
						//se restringe o uso de pedidos bloqueados (se não deixa utilizar pedido bloqueado ou rejeitado)
							
							If !('SC7')->C7_CONAPRO $ "B/R"
								lProssegue := .T.
							Else
								lProssegue := .F.
							Endif
							 
						Endif
							
					Endif 
						
					If lProssegue 
						//----------------------------------------------------------------//
						//Quando o parâmetro não for para selecionar por item de pedido, 
						//faz este Ascan (para não repetir pedido)
						//----------------------------------------------------------------//
						If GetNewPAr("XM_XPEDXML","1") <> "4"
							If lConsMedic .And. lNfMedic
								nF4For := aScan(aF4For,{|x|x[5]==('SC7')->C7_LOJA .And. x[6]==('SC7')->C7_NUM})							
							Else							
								nF4For := aScan(aF4For,{|x|x[2]==('SC7')->C7_LOJA .And. x[3]==('SC7')->C7_NUM})
							EndIf 
						Endif 							

						If ( nF4For == 0 )
							
							If lConsMedic .And. lNfMedic 
								//----------------------------------------------------------------------------//
								//FR - 19/09/2022 - ALTERAÇÃO PROJETO PAPIRUS
								//ADIÇÃO DE OUTROS CAMPOS NO ARRAY: C7_ITEM, C7_PRODUTO, C7_DESCRI, C7_PRECO 
								//OBJETIVO: propiciar tela de seleção de pedido de compra por item
								//----------------------------------------------------------------------------//
								If SC7->(FieldPos("C7_XPEDIDO")) > 0
									aConteudos := { iif(nAmarris == 2,.T.,.F.)	,;			//1
													('SC7')->C7_MEDICAO			,;      	//2
													('SC7')->C7_CONTRA			,;      	//3
													('SC7')->C7_PLANILHA		,;      	//4
													('SC7')->C7_LOJA			,;      	//5
													('SC7')->C7_NUM				,;      	//6
													DTOC(('SC7')->C7_EMISSAO)	,;      	//7
													If(('SC7')->C7_TIPO==2,'AE', 'PC'),; 	//8
													('SC7')->C7_XPEDIDO			,;			//9	//FR - campo customizado para pedido de compra da Kroma
													Transform((cAliasSC7)->TOTALPED,"@E 9,999,999,999.99")		,;			//10 - total do pedido												
													('SC7')->C7_ITEM,;						//11  //FR - 19/09/2022 - ALTERAÇÃO PROJETO PAPIRUS
													('SC7')->C7_PRODUTO,;					//12	
													('SC7')->C7_DESCRI,;					//13	
													('SC7')->C7_PRECO,;						//14
													('SC7')->C7_QUANT,;						//15
													nSldPed,;								//16													
													('SC7')->C7_TOTAL,;						//17
													DTOC( ('SC7')->C7_DATPRF);				//18 //FR - 14/07/2023 - FORCELINE SOLICITOU INCLUIR CPO PADRÃO DE PREV.ENTREGA
													 }
													 
									xPosItem := 11 		//FR - 19/09/2022 - PROJETO PAPIRUS
													 
								Else
									aConteudos := { iif(nAmarris == 2,.T.,.F.)	,;			//1
												('SC7')->C7_MEDICAO			,;      	//2
												('SC7')->C7_CONTRA			,;      	//3
												('SC7')->C7_PLANILHA		,;      	//4
												('SC7')->C7_LOJA			,;      	//5
												('SC7')->C7_NUM				,;      	//6
												DTOC(('SC7')->C7_EMISSAO)	,;      	//7
												If(('SC7')->C7_TIPO==2,'AE', 'PC'),; 	//8
												Transform((cAliasSC7)->TOTALPED,"@E 9,999,999,999.99"),;			//9 - total do pedido
												('SC7')->C7_ITEM,;						//10  //FR - 19/09/2022 - ALTERAÇÃO PROJETO PAPIRUS
												('SC7')->C7_PRODUTO,;					//11	
												('SC7')->C7_DESCRI,;					//12	
												('SC7')->C7_PRECO,;						//13
												('SC7')->C7_QUANT,;						//14
												nSldPed,;								//15
												('SC7')->C7_TOTAL,;						//16
												DTOC( ('SC7')->C7_DATPRF);				//17 //FR - 14/07/2023 - FORCELINE SOLICITOU INCLUIR CPO PADRÃO DE PREV.ENTREGA												
												 }

									xPosItem := 10 		//FR - 19/09/2022 - PROJETO PAPIRUS
								Endif
								
							Else
								If SC7->(FieldPos("C7_XPEDIDO")) > 0 		//FR - 18/08/2020 - Kroma
									aConteudos := { iif(nAmarris == 2,.T.,.F.)	,;			//1
													('SC7')->C7_LOJA			,;      	//2
													('SC7')->C7_NUM   			,;      	//3
													DTOC(('SC7')->C7_EMISSAO)	,;      	//4
													If(('SC7')->C7_TIPO==2,'AE', 'PC'),; 	//5
													('SC7')->C7_XPEDIDO			,;			//6 - campo customizado Kroma
													Transform((cAliasSC7)->TOTALPED,"@E 9,999,999,999.99"),;			//7 - total do pedido
													('SC7')->C7_ITEM,;						//08  //FR - 19/09/2022 - ALTERAÇÃO PROJETO PAPIRUS
													('SC7')->C7_PRODUTO,;					//09
													('SC7')->C7_DESCRI,;					//10	
													('SC7')->C7_PRECO,;						//11
													('SC7')->C7_QUANT,;						//12
													nSldPed,;								//13
													('SC7')->C7_TOTAL,;						//14
													DTOC( ('SC7')->C7_DATPRF);				//15 //FR - 14/07/2023 - FORCELINE SOLICITOU INCLUIR CPO PADRÃO DE PREV.ENTREGA											
													 } 

									xPosItem := 8 		//FR - 19/09/2022 - PROJETO PAPIRUS
								Else 
									aConteudos := { iif(nAmarris == 2,.T.,.F.)	,;			//1   //traz o item marcado [x]									
													('SC7')->C7_LOJA			,;      	//2
													('SC7')->C7_NUM   			,;      	//3
													DTOC(('SC7')->C7_EMISSAO)	,;      	//4
													If(('SC7')->C7_TIPO==2,'AE', 'PC'),; 	//5
													Transform((cAliasSC7)->TOTALPED,"@E 9,999,999,999.99"),;			//6 - total do pedido
													('SC7')->C7_ITEM,;						//07  //FR - 19/09/2022 - ALTERAÇÃO PROJETO PAPIRUS
													('SC7')->C7_PRODUTO,;					//08	
													('SC7')->C7_DESCRI,;					//09	
													('SC7')->C7_PRECO,;						//10
													('SC7')->C7_QUANT,;						//11
													nSldPed,;								//12
													('SC7')->C7_TOTAL,;						//13
													DTOC( ('SC7')->C7_DATPRF);				//14 //FR - 14/07/2023 - FORCELINE SOLICITOU INCLUIR CPO PADRÃO DE PREV.ENTREGA												
												  } 
									
									xPosItem := 7 		//FR - 19/09/2022 - PROJETO PAPIRUS
								Endif
							EndIf 															

							If lMa103F4I
								If ValType( aUsCont := ExecBlock( "MA103F4I", .F., .F. ) ) == "A"
									AEval( aUsCont, { |x| AAdd( aConteudos, x ) } )
								EndIf
							EndIf
							
	                        aAdd(aPedidos,('SC7')->C7_NUM)
							aAdd(aF4For , aConteudos )
							aAdd(aRecSC7, ('SC7')->(Recno()))
							
						EndIf		//If ( nF4For == 0 )							
						
					Endif		//If lProssegue 						
					
				Endif		//If lRet103Vpc
				
				(cAliasSC7)->(dbSkip())
			EndDo

			If ExistBlock("MA103F4L")
				ExecBlock("MA103F4L", .F., .F., { aF4For, aRecSC7 } )
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Exibe os dados na Tela                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ( !Empty(aF4For) )

			    //FR - 25/08/2020 - comentado para implementação de novo campo (qdo existir) no SC7 - C7_XPEDIDO
			    /*
				If lConsMedic .And. lNfMedic
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Exibe os campos de medicao do contrato                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					
					aTitCampos := {" ",RetTitle("C7_MEDICAO"),RetTitle("C7_CONTRA"),RetTitle("C7_PLANILH"),OemToAnsi("Loja"),OemToAnsi("Pedido"),OemToAnsi("Emissao"),OemToAnsi("Origem")} //"Medicao"###"Contrato"###"Planilha"###"Loja"###"Pedido"###"Emissao"###"Origem"
					cLine := "{If(aF4For[oListBox:nAt,1],oOk,oNo),aF4For[oListBox:nAT][2],aF4For[oListBox:nAT][3],aF4For[oListBox:nAT][4],aF4For[oListBox:nAT][5],aF4For[oListBox:nAT][6],aF4For[oListBox:nAT][7],aF4For[oListBox:nAT][8]"
                
                Else
                
                	aTitCampos := {" ",OemToAnsi("Loja"),OemToAnsi("Pedido"),OemToAnsi("Emissao"),OemToAnsi("Origem")} //"Loja"###"Pedido"###"Emissao"###"Origem"
					
					cLine := "{If(aF4For[oListBox:nAt,1],oOk,oNo),aF4For[oListBox:nAT][2],aF4For[oListBox:nAT][3],aF4For[oListBox:nAT][4],aF4For[oListBox:nAT][5]"
                
                Endif
                */ //FR - 25/08/2020
				//FR - 19/09/2022 - PROJETO PAPIRUS - REVISÃO DA QUERY PARA TRAZER O ITEM CASO A OPÇÃO NO PARÂMETRO 
				//ESTIVER CONFIGURADA = "4" (POR ITEM DE PEDIDO)
				If GetNewPAr("XM_XPEDXML","1") == "4"
					
					//============================//
					//SELECIONA PEDIDO POR ITEM
					//============================//
					If lConsMedic .And. lNfMedic

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Exibe os campos de medicao do contrato                   ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

						If SC7->(FieldPos("C7_XPEDIDO")) > 0		//FR - 18/08/2020 - Kroma, campo específico na SC7
							aTitCampos := {" "                           ,RetTitle("C7_MEDICAO") ,RetTitle("C7_CONTRA")  ,RetTitle("C7_PLANILH") ,OemToAnsi("Loja")      ,OemToAnsi("Pedido")    ,OemToAnsi("Item")       , OemToAnsi("Pedido Iosys"),OemToAnsi("Emissao")   ,OemToAnsi("Produto")    ,OemToAnsi("Quantidade") ,OemToAnsi("Prc Unitario"),OemToAnsi("Saldo")      , OemToAnsi("Desc.Detalhe") , OemToAnsi("Origem")    , OemToAnsi("Total Item") , OemtoAnsi("Dt.Prev.Entrega")} //"Medicao"###"Contrato"###"Planilha"###"Loja"###"Pedido"###"Pedido iosys"###"Emissao"###"Origem"
							cLine := "{If(aF4For[oListBox:nAt,1],oOk,oNo),aF4For[oListBox:nAT][2],aF4For[oListBox:nAT][3],aF4For[oListBox:nAT][4],aF4For[oListBox:nAT][5],aF4For[oListBox:nAT][6],aF4For[oListBox:nAT][11],aF4For[oListBox:nAT][9]   ,aF4For[oListBox:nAT][7],aF4For[oListBox:nAT][12],aF4For[oListBox:nAT][15],aF4For[oListBox:nAT][14] ,aF4For[oListBox:nAT][16],aF4For[oListBox:nAT][13]   ,aF4For[oListBox:nAT][8] , aF4For[oListBox:nAT][17], aF4For[oListBox:nAT][18]"														
						Else 
							aTitCampos := {" "                           ,RetTitle("C7_MEDICAO") ,RetTitle("C7_CONTRA")  ,RetTitle("C7_PLANILH") ,OemToAnsi("Loja")      ,OemToAnsi("Pedido")    ,OemToAnsi("Item")                                  ,OemToAnsi("Emissao")   ,OemToAnsi("Produto")    ,OemToAnsi("Quantidade") ,OemToAnsi("Prc Unitario"),OemToAnsi("Saldo")      ,OemToAnsi("Desc.Detalhe") ,OemToAnsi("Origem")     , OemToAnsi("Total Item")  , OemtoAnsi("Dt.Prev.Entrega")} //"Medicao"###"Contrato"###"Planilha"###"Loja"###"Pedido"###"Emissao"###"Origem"
							cLine := "{If(aF4For[oListBox:nAt,1],oOk,oNo),aF4For[oListBox:nAT][2],aF4For[oListBox:nAT][3],aF4For[oListBox:nAT][4],aF4For[oListBox:nAT][5],aF4For[oListBox:nAT][6],aF4For[oListBox:nAT][10]                           ,aF4For[oListBox:nAT][7],aF4For[oListBox:nAT][11],aF4For[oListBox:nAT][14],aF4For[oListBox:nAT][13] ,aF4For[oListBox:nAT][15],aF4For[oListBox:nAT][12]  ,aF4For[oListBox:nAT][8] , aF4For[oListBox:nAT][16] , aF4For[oListBox:nAT][17] "							
						Endif

					Else
						
						If SC7->(FieldPos("C7_XPEDIDO")) > 0		//FR - 18/08/2020 - Kroma, campo específico na SC7
							aTitCampos := {" "                           ,OemToAnsi("Loja")      ,OemToAnsi("Pedido")    ,OemToAnsi("Item")      ,OemToAnsi("Pedido iosys"),OemToAnsi("Produto")   ,OemToAnsi("Quantidade") ,OemToAnsi("Prc Unitario"),OemToAnsi("Saldo")      ,OemToAnsi("Desc.Detalhe"),OemToAnsi("Emissao")   ,OemToAnsi("Origem")    , OemToAnsi("Total Item") , OemtoAnsi("Dt.Prev.Entrega")} 
							cLine := "{If(aF4For[oListBox:nAt,1],oOk,oNo),aF4For[oListBox:nAT][2],aF4For[oListBox:nAT][3],aF4For[oListBox:nAT][8],aF4For[oListBox:nAT][6]  ,aF4For[oListBox:nAT][9],aF4For[oListBox:nAT][12],aF4For[oListBox:nAT][11] ,aF4For[oListBox:nAT][13],aF4For[oListBox:nAT][10] ,aF4For[oListBox:nAT][4],aF4For[oListBox:nAT][5], aF4For[oListBox:nAT][14], aF4For[oListbox:nAT[15]"							
						Else
							aTitCampos := {" "                           ,OemToAnsi("Loja")      ,OemToAnsi("Pedido")    ,OemToAnsi("Item")                                ,OemToAnsi("Produto")    ,OemToAnsi("Quantidade") ,OemToAnsi("Prc Unitario"),OemToAnsi("Saldo")      ,OemToAnsi("Desc.Detalhe"), OemToAnsi("Emissao")  ,OemToAnsi("Origem")    , OemToAnsi("Total Item")  , OemtoAnsi("Dt.Prev.Entrega")} 
							cLine := "{If(aF4For[oListBox:nAt,1],oOk,oNo),aF4For[oListBox:nAT][2],aF4For[oListBox:nAT][3],aF4For[oListBox:nAT][7]                          ,aF4For[oListBox:nAT][8] ,aF4For[oListBox:nAT][11],aF4For[oListBox:nAT][10] ,aF4For[oListBox:nAT][12],aF4For[oListBox:nAT][9]  ,aF4For[oListBox:nAT][4],aF4For[oListBox:nAT][5], aF4For[oListBox:nAT][13] , aF4For[oListbox:nAT[14]"							
						Endif
					EndIf
				Else
					xPosItem := 0  //indica q a seleção foi pelo pedido inteiro e não por item
				//=================================//
				//SELECIONA PEDIDO POR PEDIDO CHEIO
				//=================================//
					If lConsMedic .And. lNfMedic
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Exibe os campos de medicao do contrato                   ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ					
						
						If SC7->(FieldPos("C7_XPEDIDO")) > 0		//FR - 18/08/2020 - Kroma, campo específico na SC7
							aTitCampos := {" "                           ,RetTitle("C7_MEDICAO") ,RetTitle("C7_CONTRA")  ,RetTitle("C7_PLANILH") ,OemToAnsi("Loja")      ,OemToAnsi("Pedido")    ,OemToAnsi("Pedido Iosys"),OemToAnsi("Emissao")   ,OemToAnsi("Origem")    , OemToAnsi("Total Pedido")} //"Medicao"###"Contrato"###"Planilha"###"Loja"###"Pedido"###"Pedido iosys"###"Emissao"###"Origem"
							cLine := "{If(aF4For[oListBox:nAt,1],oOk,oNo),aF4For[oListBox:nAT][2],aF4For[oListBox:nAT][3],aF4For[oListBox:nAT][4],aF4For[oListBox:nAT][5],aF4For[oListBox:nAT][6],aF4For[oListBox:nAT][9]  ,aF4For[oListBox:nAT][7],aF4For[oListBox:nAT][8], aF4For[oListBox:nAT][10]"
						Else 
							aTitCampos := {" "                           ,RetTitle("C7_MEDICAO") ,RetTitle("C7_CONTRA")  ,RetTitle("C7_PLANILH") ,OemToAnsi("Loja")      ,OemToAnsi("Pedido")    ,OemToAnsi("Emissao")   ,OemToAnsi("Origem")    , OemToAnsi("Total Pedido")} //"Medicao"###"Contrato"###"Planilha"###"Loja"###"Pedido"###"Emissao"###"Origem"
							cLine := "{If(aF4For[oListBox:nAt,1],oOk,oNo),aF4For[oListBox:nAT][2],aF4For[oListBox:nAT][3],aF4For[oListBox:nAT][4],aF4For[oListBox:nAT][5],aF4For[oListBox:nAT][6],aF4For[oListBox:nAT][7],aF4For[oListBox:nAT][8], aF4For[oListBox:nAT][9]"
						Endif
						
					Else
						
						If SC7->(FieldPos("C7_XPEDIDO")) > 0		//FR - 18/08/2020 - Kroma, campo específico na SC7
							aTitCampos := {" "                           ,OemToAnsi("Loja")      ,OemToAnsi("Pedido")    ,OemToAnsi("Pedido iosys"),OemToAnsi("Emissao")   ,OemToAnsi("Origem")    , OemToAnsi("Total Pedido"), OemtoAnsi("Dt.Prev.Entrega")} 
							cLine := "{If(aF4For[oListBox:nAt,1],oOk,oNo),aF4For[oListBox:nAT][2],aF4For[oListBox:nAT][3],aF4For[oListBox:nAT][6]  ,aF4For[oListBox:nAT][4],aF4For[oListBox:nAT][5], aF4For[oListBox:nAT][7]  , aF4For[oListBox:nAT][15]"
						Else
							aTitCampos := {" "                           ,OemToAnsi("Loja")      ,OemToAnsi("Pedido")    ,OemToAnsi("Emissao")   ,OemToAnsi("Origem")     , OemToAnsi("Total Pedido"), OemtoAnsi("Dt.Prev.Entrega")} 
							cLine := "{If(aF4For[oListBox:nAt,1],oOk,oNo),aF4For[oListBox:nAT][2],aF4For[oListBox:nAT][3],aF4For[oListBox:nAT][4],aF4For[oListBox:nAT][5] , aF4For[oListBox:nAT][6]  , aF4For[oListBox:nAT][14]"
						Endif
					EndIf
				Endif 

				If ExistBlock( "MA103F4H" )
					If ValType( aUsTitu := ExecBlock( "MA103F4H", .F., .F. ) ) == "A"
						nNumCampos := Len(aTitCampos)
						For nLoop := 1 To Len( aUsTitu )
							AAdd( aTitCampos, aUsTitu[ nLoop ] )
							cLine += ",aF4For[oListBox:nAT][" + AllTrim( Str( nLoop + nNumCampos ) ) + "]"
						Next nLoop
					EndIf
				EndIf

				cLine += " } "

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Monta dinamicamente o bline do CodeBlock                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				bLine := &( "{ || " + cLine + " }" )

				//-------------------------------------------------------------------------------------//
				//FR - 06/08/2020 - Verifica se há pedido na tag cXPed no XML e Monta aPedXML, 
				//que será comparado com os pedidos encontrados na SC7
				//-------------------------------------------------------------------------------------//
				cModel := ""
				cCnpj  := ""
				aIteXML:= {}
				aPedXml:= {}			
				
				cXml   := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML")))
				cModel := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO")))
				cCnpj  := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))) 
				
				aIteXML := U_fIMPXMLFOR(cXml,cModel,cCnpj) 				
				cProdSB1:= ""				
				If Len(aIteXML) > 0
					For fr := 1 to Len(aIteXML)						
						
						//FR - 12/10/2022 - colocar o fachamarra aqui
						cProdSB1:= ""				
						//caso encontre amarração, na hora de gerar a pré nota carrega os itens comparando o item do pedido se é o mesmo do xml
						//assim evita que o usuário precise apagar o item na pré nota que não vai usar, só vai carregar do pedido de compra
						//o que está no xml (nota)
						//FR - 12/10/2022
						cProdSB1 := U_fAchamarra(Alltrim(aIteXML[fr][3]),cA100For,cLoja)
						Aadd(aPedXML , {; 
										Alltrim(aIteXML[fr][1]),; 	//1-numero pedido
										Alltrim(aIteXML[fr][2]),; 	//2-item pedido 
										Alltrim(aIteXML[fr][3]),;	//3-produto xml (código fornecedor)
										aIteXML[fr][25],;			//4-qtde pedido no xml
										cProdSB1;					//5-produto na sb1 (caso encontre a amarração)
										})
					Next
				Endif
				
				//------------------------------------------------------------------------------------------//
				//FR - 06/08/2020 - Verifica se o pedido constante no XML existe na SC7 e se o saldo atende
				//------------------------------------------------------------------------------------------//
				If GetNewPar("XM_PED_PRE","N") == "S"  //assume pedido compra na pré-nota:
                    If aPedXML <> NIL .and. Len(aPedXML) > 0
                        If !Empty(aPedXML[1,1])		//se o número do pedido não vier vazio
                            lPCXMLAtend := U_fPCAtende(aIteXML,aPedXML,@aF4For,cA100For,cLoja,lConsMedic,lNfMedic,,.F.)
                        Else
                            lPCXMLAtend := .F.						
                        Endif
                    Else
                        lPCXMLAtend := .F.
                    Endif
                Endif 

                //cPedido  := GetNewPar("XM_PED_PRE","N")
                /*
                @ 054,120 Say "Assume pedido na Pré-nota: "  PIXEL OF oPage:aDialogs[nPageGer] COLOR CLR_BLUE FONT oFont01
                @ 062,120 COMBOBOX oPedido VAR cPedido ITEMS aCombo2 SIZE 100,10 PIXEL OF oPage:aDialogs[nPageGer] 
                cTip := "Na consulta de pedido por item <F6> na geração de Pré-nota assume os valores de Pedido." +CRLF
                cTip += "Caso esteja como não mantém os valores do XML."
                oPedido:cToolTip := cTip
                */
                
				                
				//----------------------------------------------------------------------------//
				//FR - 19/09/2022 - ALTERAÇÃO PROJETO PAPIRUS
				//ADIÇÃO DE OUTROS CAMPOS NO ARRAY: C7_ITEM, C7_PRODUTO, C7_DESCRI, C7_PRECO 
				//OBJETIVO: propiciar tela de seleção de pedido de compra por item
				//----------------------------------------------------------------------------//

				//----------------------------------------------------------------------------//
				//FR - ordena porque qdo sai da função fPCAtende vem por outra ordem
				//----------------------------------------------------------------------------//
				If lConsMedic .And. lNfMedic
					If SC7->(FieldPos("C7_XPEDIDO")) > 0
						//por número pc + item
						ASORT( aF4For, , , { | x,y | x[6] + x[11] < y[6] + y[11] } ) 		
					Else 
						//por número pc + item
						ASORT( aF4For, , , { | x,y | x[6] + x[10] < y[6] + y[10] } ) 		
					Endif 
				Else 
					If SC7->(FieldPos("C7_XPEDIDO")) > 0
						//por número pc + item
						ASORT( aF4For, , , { | x,y | x[3] + x[8] < y[3] + y[8] } ) 
					Else
						//por número pc + item
						ASORT( aF4For, , , { | x,y | x[3] + x[7] < y[3] + y[7] } ) 		 
					Endif 
				Endif  
                //FR - 06/08/2020 - se o pedido do XML não existir na SC7 ou não atender por completo, aí sim mostra esta pergunta:
                nAviso := 0
				If !lPCXMLAtend
                    
                	//If .NOT. (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO"))) $ "55/57"		//FR - 04/10/2019 - incluído modelo 57 Cte
					//	cPedXML    := "1"
					//	cPedXMLAnt := "1"		//FR - 18/08/2020
					//Endif
			
					If Empty(cPedXML)
						cPedXML		:= GetNewPAr("XM_XPEDXML","1")
						cPedXMLAnt	:= cPedXML
						If cPedXML == "3"  
							//FR - 26/09/2022 - validação da Papirus: 
							//3-> Sempre Perguntar - Alex solicitou que se estiver setado = 4 , não mostrar pergunta, já ir direto para tela
							//FR - 19/09/2022 - ALTERAÇÃO - Flávia Rocha - PROJETO PAPIRUS
							If cTravPreNF <> "S"
								nAviso := U_MYAVISO("Pré-Nota","Deseja montar pré-nota pelo saldo Pedido ou pelo XML?",{"PEDIDO","XML"},2) 
							Else
								nAviso := 2
							EndIf	

							
							If nAviso == 1
								cPedXML    := "1"
								cPedXMLAnt := "1"		//FR - 18/08/2020
							Elseif nAviso == 2
								cPedXML    := "2"
								cPedXMLAnt := "2"		//FR - 18/08/2020
							Endif
							cTitulo := OemToAnsi("Selecionar Pedido de Compra - <F5> ")
							
						Elseif cPedXML == "4"
							//cPedXML    := "3"
							//cPedXMLAnt := "3"
							cTitulo    := OemToAnsi("Selecionar Item Pedido de Compra")								
						Endif
						//FR - 19/09/2022 - ALTERAÇÃO - Flávia Rocha - PROJETO PAPIRUS					
					Endif														
                	
                Endif                                
                //FR - 18/08/2020
                
				If nAmarris == 1 .and. !lPCXMLAtend
					//calcula a medida da tela para montar dialog	
					U_fCALCTELA(@aSizeAut,@aPos) 
					/* 
					//medidas da tela obtidas pela função U_fCalcTela
					aSizeAut[1]=0;     0
					aSizeAut[2]=30;    30
					aSizeAut[3]=953;   676
					aSizeAut[4]=446;   298
					aSizeAut[5]=1906;  1352
					aSizeAut[6]=892;   596
					aSizeAut[7]=0;     0
					aSizeAut[8]=5;     5
					*/   
					
				//FR - 06/08/2020 - só abre a tela para selecionar pedido caso não tenha conseguido linkar do xml com o SC7 ou o pedido especificado no Xml não atenda por completo
					DEFINE MSDIALOG oDlg FROM aSize[7],0 to aSize[6],aSize[5] TITLE OemToAnsi(cTitulo) Of oMainWnd PIXEL //"Selecionar Pedido de Compra"
					SetPrvt("oDlg")


					//@ 12,0 MSPANEL oPanel PROMPT "" SIZE 100,19 OF oDlg CENTERED LOWERED //"Botoes"
					@ 25,5 MSPANEL oPanel PROMPT "" SIZE 100,85 OF oDlg CENTERED LOWERED //"Botoes"
					oPanel:Align := CONTROL_ALIGN_TOP


					oListBox := TWBrowse():New( 47,4,243,86,,aTitCampos,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
					oListBox:SetArray(aF4For)
					oListBox:bLDblClick := { || aF4For[oListBox:nAt,1] := !aF4For[oListBox:nAt,1] }
					oListBox:bLine := bLine
					oListBox:Align := CONTROL_ALIGN_ALLCLIENT
					
					//LUCAS SAN e RAFAEL TAVARES -> 20/09/2022
					cInfoCompl := Alltrim(RetiraAcentos(cInfoCompl))

					oGroup:= TGroup():New(02,250,80,670,'INFORMAÇÕES COMPLEMENTARES:',oPanel, CLR_HBLUE, CLR_WHITE, .T., .F.)
					oInfo:= tMultiget():New( 10 , 255 , {| u | if( pCount() > 0,cInfoCompl:=u,cInfoCompl)},oPanel,410,65,,,,,,.T.,,,,,,.T. )
					oGroup2:= TGroup():New(02,02,80,240,'',oPanel, CLR_HBLUE, CLR_WHITE, .T., .F.)


					@ 10 ,10   SAY OemToAnsi("COD. FORNECEDOR:") Of oPanel PIXEL SIZE 80 ,9 //"Código do Fornecedor"

					oGet02 := TGet():New( 8, 70,bSETGET(cCodFor),oDlg,020,10,,,,/*10*/,,,,.T.,/*15*/,,,,,/*20*/,,)
					oGet02:SetCSS( getCSS('TGET'))	//COD. FORNECEDOR:
					oGet02:Disable()


					@ 10  ,105   SAY OemToAnsi("LOJA:") Of oPanel PIXEL SIZE 47 ,9 //"Loja Fornecedor"

					oGet02 := TGet():New( 8, 128,bSETGET(cLojaFor),oDlg,020,10,,,,/*10*/,,,,.T.,/*15*/,,,,,/*20*/,,)
					oGet02:SetCSS( getCSS('TGET'))	//LOJA
					oGet02:Disable()


					@ 10 ,155   SAY OemToAnsi("CNPJ:") Of oPanel PIXEL SIZE 80 ,9 //"CNPJ"

					oGet02 := TGet():New( 8, 175,bSETGET(cCNPJFor),oDlg,060,10,"@R 99.999.999/9999-99",,,/*10*/,,,,.T.,/*15*/,,,,,/*20*/,,)
					oGet02:SetCSS( getCSS('TGET'))	//CNPJ
					oGet02:Disable()


					@ 25 ,10   SAY OemToAnsi("FORNECEDOR:") Of oPanel PIXEL SIZE 47 ,9 //"Fornecedor"

					oGet02 := TGet():New( 23,56,bSETGET(cNomeFor),oDlg,180,10,,,,/*10*/,,,,.T.,/*15*/,,,,,/*20*/,,)
					oGet02:SetCSS( getCSS('TGET'))	//FORNECEDOR
					oGet02:Disable()


					@ 40 ,10   SAY OemToAnsi("CHAVE XML:") Of oPanel PIXEL SIZE 47 ,9 //"Chave XML"

					oGet02 := TGet():New( 38,56,bSETGET(cChaveXML),oDlg,180,10,,,,/*10*/,,,,.T.,/*15*/,,,,,/*20*/,,)
					oGet02:SetCSS( getCSS('TGET'))	//Serie
					oGet02:Disable()


					@ 55  ,10   SAY OemToAnsi("Nº DA NF:") Of oPanel PIXEL SIZE 47 ,9 //"Nº Nota"

					oGet02 := TGet():New( 53,56,bSETGET(cDocFiscal),oDlg,45,10,,,,/*10*/,,,,.T.,/*15*/,,,,,/*20*/,,)
					oGet02:SetCSS( getCSS('TGET'))	//Serie
					oGet02:Disable()


					@ 69  ,10  SAY OemToAnsi("DT. EMISSÃO:") Of oPanel PIXEL SIZE 47 ,9 //"Data emissão da nota"

					oGet02 := TGet():New( 67, 56,bSETGET(dDataEmi),oDlg,50,10,,,,/*10*/,,,,.T.,/*15*/,,,,,/*20*/,,)
					oGet02:SetCSS( getCSS('TGET'))	//Serie
					oGet02:Disable()

					ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,    {|| (nOpc := 1,nF4For := oListBox:nAt,oDlg:End() ) },{||(nOpc := 0,nF4For := oListBox:nAt,oDlg:End())},,aButtons)				
					//VALIDA o pedido marcado  //FR - não precisa, talvez numa outra oportunidade, deixo aqui só como comentário então
					//ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,    {|| If( U_fPCAtende(aIteXML,aPedXML,@aF4For,cA100For,cLoja,lConsMedic,lNfMedic,@lPCXMLAtend,.T.), (nOpc:=1, nF4For := oListBox:nAt,oDlg:End() ), nOpc:=0 ) }, {||(nOpc := 0, nF4For := oListBox:nAt,oDlg:End())},,aButtons)
				Else
					nOpc := 1
				Endif
				If nOpc == 1					
									
					//FR - 06/08/2020 - povoa o array aPedidos para o retorno no final desta função
					If Len(aPedAux) <= 0
						cPed := ""
						For fr := 1 to Len(aF4For)
							
							If aF4For[fr][1]	 //se estiver marcado [x]		           
				               	If lConsMedic .And. lNfMedic				               		
				               		cPed := Alltrim(aF4For[fr][6])
				               	Else				               	
				               		cPed := Alltrim(aF4For[fr][3])
				               	Endif
				               	
								nPos := Ascan(aPedAux, cPed)
								
								If nPos == 0 //se não tem, adiciona
									aAdd(aPedAux, cPed )
								Endif
							Endif
							
						Next
					Endif
									
					//lPCXMLAtend := .F. //FR - TESTE RETIRAR
					//cPedXML     := "2" //FR - TESTE RETIRAR
					
					If GetNewPAr("XM_XPEDXML","1") <> "1" .and. !lPCXMLAtend  
					//FR - 29/08/2022 - ECOAUTOMAÇÃO - só entra aqui se o saldo de pedido verificado não atende, então chama a tela xml x pc para procurar outro pedido que atenda
						
						If Len(aPedAux) >= 2 	//quando há mais de um pedido é necessário amarrar o saldo de cada item, pela tela amarração xml x pedido
							cPedXML := "2"   	//atribuido aqui para forçar a tela de amarração ped. x XML, 
											 	//nesse caso, aproveito a tela de amarração do xml, depois retorno novamente com o conteúdo da variável cPedXMLAnt
							cPedXMLAnt	:= cPedXML 	//FR - 23/02/2021 - #6226 - Mectronics
						Endif
						
					Endif
					//FR - 06/08/2020
					
					If cPedXML == "2"      //FR - 06/08/2020 - pelo XML

						If Empty(cLoja)
							cLoja := cLojaFor  //estava indo vazia a loja
						Endif 
						If nAmarris == 1
							//aWBrowse := U_HFXML023()  //Tela de amarração Pedido x NF
							cModelo:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO")))  //FR - 04/10/2019
							aWBXML := {}  //FR - 10/07/2023 - a função abaixo vai devolver o browse do XML para usar em caso de NF SERVIÇO
							//esse array do browse da NF serviço será usado para comparação na função HFXML070 que verifica as divergências
							//entre PC x XML
							aWBrowse := U_HFXML023(cModelo,xPosItem,@aWBXML)  //Tela de amarração Pedido x NF
							
							//If cPedXML == cPedXMLAnt		//FR - 18/08/2020							
								//If !Empty( aWBrowse )
							If !Empty(aWBrowse)
									
									Processa({|| lRet := U_aXMLprPC(aF4For,nOpc,cA100For,cLoja,@lRet103Vpc,@lMt103Vpc,@nSldPed,.F.,aGets,( lConsMedic .And. lNfMedic ),aHeadSDE,@aColsSDE,aHeadSEV, aColsSEV, aWBrowse, aPedXML, xPosItem, aWBXML )})																
									lPCXMLAtend := lRet
								//Else
								//	lRet := .F.
								//Endif
							
							Elseif cPedXMLAnt == "1"		//FR - 18/08/2020 - Se a escolha do usuário foi "Por Pedido", esta decisão foi guardada nesta variável e será executada
								//Processa({|| U_aXMLprPC(aF4For,nOpc,cA100For,cLoja,@lRet103Vpc,@lMt103Vpc,@nSldPed,.F.,aGets,( lConsMedic .And. lNfMedic ),aHeadSDE,@aColsSDE,aHeadSEV, aColsSEV,, aPedXML )})							
								Processa({|| lPCXMLAtend := U_aXMLprPC(aF4For,nOpc,cA100For,cLoja,@lRet103Vpc,@lMt103Vpc,@nSldPed,.F.,aGets,( lConsMedic .And. lNfMedic ),aHeadSDE,@aColsSDE,aHeadSEV, aColsSEV,, aPedXML, xPosItem )})														
							Endif
							
						Else
							lRet := .T.
						Endif

					Else				//FR - 06/08/2020 - pelo pedido de compra
					
						Processa({|| U_aXMLprPC(aF4For,nOpc,cA100For,cLoja,@lRet103Vpc,@lMt103Vpc,@nSldPed,.F.,aGets,( lConsMedic .And. lNfMedic ),aHeadSDE,@aColsSDE,aHeadSEV, aColsSEV,, aPedXML, xPosItem )})
						lRet        := .T.
						lPCXMLAtend := lRet
					Endif
					
				Else
					lRet := .F.
				EndIf
			Else
				//Help(" ",1,"A103F4")
				U_MYAVISO("A103F4","Não existe(m) Pedido(s) ou Saldo Suficiente relacionado(s) com Este Fornecedor",{"Ok"},2)
				lRet := .F.
			EndIf
		Else
			Help('   ',1,'A103TIPON')
		EndIf
		If Len(aPedAux) > 0
			aPedidos := aPedAux
		Endif
Endif

aRet      := {}
lContinua := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura a Integrida dos dados de Entrada                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(aPedidos) .or. Empty(aPedidos) //lQuery

	DbSelectArea(cAliasSC7)
	dbCloseArea()
	DbSelectArea("SC7") 
	Aadd(aRet, lRet)
	Aadd(aRet, aPedidos)

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
//RestArea(aAreaSC7)
RestArea(aArea)
//Return(lRet)
Return(aRet)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103ProcPC| Autor ³ Alex Lemes            ³ Data ³09/06/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Processa o carregamento do pedido de compras para a NFE    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array com os itens do pedido de compras            ³±±
±±³          ³ ExpN1 = Opcao valida                                       ³±±
±±³          ³ ExpC1 = Fornecedor                                         ³±±
±±³          ³ ExpC2 = loja fornecedor                                    ³±±
±±³          ³ ExpL1 = retorno do ponto de entrada                        ³±±
±±³          ³ ExpL2 = Uso do ponto de entrada                            ³±±
±±³          ³ ExpN2 = Saldo do pedido                                    ³±±
±±³          ³ ExpL3 = Usa funcao fiscal                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA103                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function aXMLprPC(aF4For,nOpc,cA100For,cLoja,lRet103Vpc,lMt103Vpc,nSldPed,lUsaFiscal,aGets,lNfMedic,aHeadSDE,aColsSDE,aHeadSEV, aColsSEV,aWBrowse,aPedXML,xPosItem,aWBXML)

Local lRet       := .T.
Local y          := 0
Local nx         := 0
Local cSeek      := ""
Local cFilialOri := ""
Local cItem	     := StrZero(1,Len(SD1->D1_ITEM))
Local lZeraCols  := .T.
Local aRateio    := {0,0,0} 
Local aMT103NPC  := {}
Local aColsBkp   := Aclone(Acols)
Local cPrdNCad   := ""
Local nSavNF  	 := 0 //MaFisSave()
Local aRatFin	 := {}
Local lPrjCni    := FindFunction("ValidaCNI") .And. ValidaCNI()
Local nPosIpi    := 0       //HF
Local lXMLPEITE  := ExistBlock( "XMLPEITE" )
Local lXMLPELOK  := ExistBlock( "XMLPELOK" )
Local lXMLPETOK  := ExistBlock( "XMLPETOK" )
Local lLOk 		 := .T.
Local lTOk 		 := .T.
Local lValid	 := .T.
Local cTravPreNF := GetNewPar("XM_PED_GBR","N")   //FR - 06/08/2020 - parâmetro "Trava Pré-Nota" S-Sim (Trava), N-Não , P-Pergunta
Local cAglutina  := GetNewPar("MV_NGAGLPC","2")   //FR - 18/11/2020 - 1=Sim Aglutina; 2=Não Aglutina
Local nTamProd   := TAMSX3("B1_COD")[1]
Local nVlrXml    := 0
Local nMoedaPC   := 0
Local lSelecITEM := .F. //FR - 19/09/2022 - PROJETO PAPIRUS - SELEÇÃO DE PEDIDO DE COMPRA POR ITEM
Local xf		 := 0 
Local lProssegue := .T. 
Local nTemNoXML  := 0
Local ntem       := 0
Local nL         := 1

Private l103Auto := .F.
Private cUsaLoteFor := GetNewPar("XM_LOTEFOR" , "N")	//FR - 19/10/2022 - MBIOLOG - ATIVA DESMEMBRAMENTO DE LOTE
Private cDesmembra  := GetNewPar("XM_DESLOTE" , "N")  	//FR - 19/10/2022 - MBIOLOG - ATIVA DESMEMBRAMENTO DE LOTE
Private lDesmembra  := .F.
Private lUSALOTE    := .F.

Public AREFALT    := {}
Public CSX6EMPANT := "01"
nSavNF  	 := MaFisSave()
DEFAULT lUsaFiscal := .F.
DEFAULT aGets      := {}
DEFAULT lNfMedic   := .F.
DEFAULT aHeadSDE   := {}
DEFAULT aColsSDE   := {}
DEFAULT aWBrowse   := {}
DEFAULT aWBXML     := {} //FR - 10/07/2023 - ARRAY DO BROWSE DA NF SERVIÇO PARA SER USADO A COMPARAÇÃO DE DIVERGÊNCIAS

If ( nOpc == 1 )
	If lPrjCni
   		U_COMA120(@aF4For,lNfMedic,lUsaFiscal)	   
	EndIf

	If !Empty( aWBrowse )	
		ASORT( aWBrowse, , , { | x,y | x[2] < y[2] } ) 
		
		//VERIFICA DIVERGENCIAS
		If cTravPreNF != "N"    			//FR 18/11/2020
			lValid :=  U_HFXML070(cChaveXML, aWBrowse, .F., cTravPreNF,aWBXML,cModelo)
        
			If !lValid
				Return(lValid)
			EndIf
		Endif
		//FR - 18/08/2020 - cria um array aglutinado
		//ASORT( aWBrowse, , , { | x,y | x[2] < y[2] } )
		ASORT( aWBrowse, , , { | x,y | x[3] < y[3] } )   	//FR - 06/08/2020 - ordena por código de produto para facilitar a aglutinação
		
		If lZeraCols
			aCols		:= {}
			lZeraCols	:= .F.
			MaFisClear()   //FR - 11/05/2020 OCORRE ERRO!
		EndIf
				
		//FR - 06/08/2020
		aWBrowx  := {}
		fr       := 1
		nValTot  := 0
		nValipi  := 0
		nIpi     := 0
		nLen     := 0
		
		/*  
		//referência:
		Aadd(aWBrowse2,{ SC7->C7_ITEM,;		//1
						cItXm,;				//2
		 				SC7->C7_PRODUTO,;	//3
		 				SB1->B1_DESC,;		//4
		 				SC7->C7_NUM,;		//5
		 				SC7->C7_QUANT,;		//6
		 				0			,;		//7  //saldo a vincular
		 				SC7->C7_QUJE,;		//8
		 				SC7->C7_PRECO,;		//9
		 				SC7->C7_TOTAL,;		//10
		 				SC7->C7_VALIPI,;	//11
		 				SC7->C7_IPI,; 		//12
		 				NIL;				//13     //indica se adiciona no final ou não esta linha
		 				aAdd(aWBrowse2[x],Alltrim(Str(nQt)  ) 	)  			//14 - QTD
						aAdd(aWBrowse2[x],Alltrim(Str(nVuni))	)  			//15 - UNIT
						aAdd(aWBrowse2[x],Alltrim(Str(nVtot)) 	)  			//16 - TOTAL
						aAdd(aWBrowse2[x],Alltrim(Str(nVipi)) 	)  			//17 - VL IPI
						aAdd(aWBrowse2[x],Alltrim(Str(nIpi) )	)  			//18 - ALIQ IPI
		*/
		
		//FR 18/11/2020
		If cAglutina ==	"1" //FR - 18/11/2020 - se o parâmetro padrão estiver configurado para aglutinar = Sim, aglutina    
			While fr <= Len(aWBrowse)
			
			    nValuni	:= 0
				nValTot	:= 0
				nValipi	:= 0
				nPosIt	:= AScan(aWBrowx,{ |x| Alltrim(x[3]) == Alltrim(aWBrowse[fr,3]) } )   //FR - 18/11/2020 - Ascan se já existe o código do produto no array aWBrowx para acumular as qtdes de produto igual
				nPosPed	:= AScan(aWBrowx,{ |x| Alltrim(x[5]) == Alltrim(aWBrowse[fr,5]) } ) 
				   
				If nPosIt == 0 .OR. nPosPed == 0
					//nValTot := (aWBrowse[fr,6] * Val(aWBrowse[fr,14]) ) 
					//nValTot := (aWBrowse[fr,7] * Val(aWBrowse[fr,14]) )
					nValuni := Val(aWBrowse[fr,17])
					nValTot := (aWBrowse[fr,7] * nValuni  )  //valor unitário está na 16 agora porque foram acrescentadas as posições da 'Seg. UM' e 'Qt. Seg.UM'
					//nIpi    := Val(aWBrowse[fr,16]) 
					nIpi    := Val(aWBrowse[fr,Len(aWBrowse[fr])-2]) 		//FR 12/11/2020  //Val(aWBrowse[fr,19]) 		//FR 12/11/2020
					nValipi := ( nValTot * (nIpi / 100) )
										
					Aadd(aWBrowx,{; 
						aWBrowse[fr,1],;													//1-item PC
						aWBrowse[fr,2],;		   											//2-item XML
						aWBrowse[fr,3],;													//3-codigo produto
						aWBrowse[fr,4],;													//4-descrição produto
						aWBrowse[fr,5],;													//5-número pedido compra 
						aWBrowse[fr,6],;													//6-qtde no pedido de compra
						aWBrowse[fr,7],;													//7-qtde vinculada
						aWBrowse[fr,8],;													//8-qtde já entregue
						nValuni,;			 												//9-preço unitário
						nValTot ,;															//10-valor total do item
						nValipi,; 															//11-valor ipi
						nIpi,;	  															//12-aliq ipi
						aWBrowse[fr,13],;													//13-2a. UM
						aWBrowse[fr,14],;													//14-Qt.2a.UM
						aWBrowse[fr,15],; 													//15-Codigo do produto
						aWBrowse[fr,16],;													//16-qtde no pedido compra (caracter)					
						aWBrowse[fr,17],; 													//17-preço unitário (caracter) //13-preço unitário (caracter) 
						Alltrim( Str(nValTot) ),;						 					//18-valor total do item (caracter) //14-valor total do item (caracter)
						Alltrim( Str(nValipi) ),;											//19-valor ipi (caracter) //15-valor ipi (caracter)
						aWBrowse[fr,20],; 													//20-aliq ipi (caracter) //16-aliq ipi (caracter)
						aWBrowse[fr,Len(aWBrowse[fr])-1],; 					 				//21-codigo produto do fornecedor
						aWBrowse[fr,Len(aWBrowse[fr])];  					 				//22-descrição produto do fornecedor
						} )	
				
				Else
					nValuni := Val(aWBrowse[fr,17])
					nValTot := (aWBrowse[fr,6] * nValuni) //Val(aWBrowse[fr,14]) )
					nIpi    := Val(aWBrowx[nPosIt,20]) 						
					nValipi := ( nValTot * (nIpi / 100) )
					
					aWBrowx[nPosIt,6] += aWBrowse[fr,6]											//6-qtde no pedido compra
					aWBrowx[nPosIt,7] += aWBrowse[fr,7]											//7-qtde vinculada 
					aWBrowx[nPosIt,8] += aWBrowse[fr,8]											//8-qtde já entregue
					aWBrowx[nPosIt,9] := nValuni				 //Val(aWBrowse[fr,14])			//9-preço unitário
					aWBrowx[nPosIt,10]+= nValTot   												//10valor total do item																			
					aWBrowx[nPosIt,11]:= (aWBrowx[nPosIt,10] * (nIpi / 100) )	  				//11-valor ipi 
					aWBrowx[nPosIt,12]:= nIpi                         							//12-aliq ipi
					//mantendo a referência da ordem do array									//13-2a.UM
				    //mantendo a referência da ordem do array									//14-Qt 2a. UM
					aWBrowx[nPosIt,15]:= aWBrowse[fr,15]										//15-Código interno produto						
					aWBrowx[nPosIt,16]:= Alltrim(Str(aWBrowx[nPosIt,6]))						//16-qtde no pedido compra (caracter) 																							
					aWBrowx[nPosIt,17]:= aWBrowse[fr,17]  										//17-preço unitário (caracter) //13-preço unitário (caracter)						
					aWBrowx[nPosIt,18]:= Alltrim(Str(aWBrowx[nPosIt,10]))	            		//18-valor total do item caracter //14-valor total do item caracter						
					aWBrowx[nPosIt,19]:= Alltrim(Str(aWBrowx[nPosIt,11]))						//19-valor ipi (caracter) //15-valor ipi (caracter)
					aWBrowx[nPosIt,20]:= Alltrim(Str(nIpi))										//20-aliq ipi
					aWBrowx[nposIt,21]:= Alltrim(aWBrowse[fr,21])								//21-código interno produto
					aWBrowx[nPosIt,22]:= Alltrim(aWBrowse[fr,22])								//22-descrição produto
					
				Endif
				   
				fr++
					
			Enddo	
		
			aWBrowse := aWBrowx 
			//FR - 18/08/2020 - Aqui copio o novo array já ordenado e com as qtdes acumuladas para o aWBrowse de volta		
		
		Endif		//se Aglutina faz o bloco acima
		
		ASORT( aWBrowse, , , { | x,y | x[2] < y[2] } )     //ordena por item do xml
		
	Endif
	
	
	//FR - aqui começa a montagem do array para os itens da nota
	//For nx	:= 1 to Len(aF4For)
	
	//	If aF4For[nx][1] // Verifica se o fornecedor foi selecionado
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona Fornecedor                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SA2")
			DbSetOrder(1)
			MsSeek(xFilial("SA2")+cA100For+cLoja)
            
   			If !Empty( aWBrowse )		//PELO XML
   			
				ASORT( aWBrowse, , , { | x,y | x[2] < y[2] } )     //ordena por item do xml
				
				For y := 1 To Len(aWBrowse)
					    
					//FR - 06/08/2020
					nQtProd := 0		
					nVunit  := 0
					nTotal  := 0
					nValipi := 0
					nIpi    := 0
					nPos    := 0
					
					nPos    := AScan(aF4For,{ |x| Alltrim(x[3]) == Alltrim(aWBrowse[y,5]) } )
					
					If !Empty(aWBrowse[y,2]) .And. aWBrowse[y,5] == iIf(lNfMedic,aF4For[nPos,6],aF4For[nPos,3])  .And. aWBrowse[y,2] <> StrZero(0,TAMSX3("C7_ITEM")[1])

						//-----------------------------------------------------------------------------------//
						//FR - 19/10/2022 -TRATATIVA DO NÚMERO DE LOTE QUANDO HÁ VÁRIOS LOTES NO MESMO ITEM
						//MBIOLOG
						//----------------------------------------------------------------------------------//
						oDet := {}
						i    := 0															
						i    := Val(cItem)
						If Type( "oXml:_NFEPROC:_NFE:_INFNFE:_DET" ) <> "U"
							oDet := oXml:_NFEPROC:_NFE:_INFNFE:_DET
							oDet := IIf(ValType(oDet)=="O",{oDet},oDet)
															
							If Type("oDet["+Str(i)+"]:_Prod") <> "U"																
								If XmlChildEx(oDet[i]:_Prod,"_RASTRO") <> nil   																		
									If Type("oDet["+Str(i)+"]:_Prod:_RASTRO") == "A"
										If Len(oDet[i]:_PROD:_RASTRO) > 1	//se o array de lote tiver mais que 1 lote, sugere desmembramento
											If cDesmembra == "S" 			//só faz o desmembramento se o parâmetro estiver ativado Sim					
												lDesmembra := .T.
											Endif
										Endif    
									Endif 
								Endif 
							Endif 
						Endif
						//-----------------------------------------------------------------------------------//
						//FR - 19/10/2022 -TRATATIVA DO NÚMERO DE LOTE QUANDO HÁ VÁRIOS LOTES NO MESMO ITEM
						//MBIOLOG
						//----------------------------------------------------------------------------------//
						// Verifica se o Produto existe Cadastrado na Filial de Entrada
						DbSelectArea("SB1")
						DbSetOrder(1)
						DbSeek( xFilial("SB1") + aWBrowse[y,3] )

						//--------------------------------------------------------------------------------------------//
						//FR - 13/04/2023 - MBIOLOG - CHECAGEM SE O PRODUTO REALMENTE USA LOTE, SE NÃO UTILIZAR, 
						//DESATIVA O DESMEMBRAMENTO SÓ NESTE LANÇAMENTO DA NOTA, 
						//O PARÂMETRO FICA INTACTO (XM_DESLOTE)
						//--------------------------------------------------------------------------------------------//
						//
						If lDesmembra 
							SB1->(OrdSetFocus(1))
							DbSeek( xFilial("SB1") + aWBrowse[y,3] )
							If SB1->B1_RASTRO == "N"  
							//se o produto não controla Lote, desativo o lDesmembra para não realizar desmembramento indevidamente
								lDesmembra := .F.
								lUSALOTE   := .F.
							Elseif SB1->B1_RASTRO == "L"
								lUSALOTE := .T.
							Endif
						Endif  
						//--------------------------------------------------------------------------------------------//
						//FR - 13/04/2023 - MBIOLOG - CHECAGEM SE O PRODUTO REALMENTE USA LOTE
						//--------------------------------------------------------------------------------------------//

						
						DbSelectArea("SC7")
						DbSetOrder(14)
						if lNfMedic
						
							cSeek := xFilEnt(xFilial("SC7")) + aF4For[nPos,6] 
						
						else
						
							cSeek := xFilEnt(xFilial("SC7")) + aWBrowse[y,5] + aWBrowse[y,1] //filial entrega+pedido+item
						
						endif

						//ATUALIZA SA5
						//U_FGRAVSA5(cCodEmit,cLojaEmit,cProdXml,cDescXml,_cCodProd)
						//U_FGRAVSA5(cA100For,cLoja,aWBrowse[y,20],aWBrowse[y,21],aWBrowse[y,3])
						U_FGRAVSA5(cA100For, cLoja, aWBrowse[y,Len(aWBrowse[y])-1], aWBrowse[y,Len(aWBrowse[y])], aWBrowse[y,3])
								
						
						//{iif(nAmarris == 2,.T.,.F.),('SC7')->C7_MEDICAO,('SC7')->C7_CONTRA,('SC7')->C7_PLANILHA,('SC7')->C7_LOJA,('SC7')->C7_NUM,DTOC(('SC7')->C7_EMISSAO),If(('SC7')->C7_TIPO==2,'AE', 'PC') }
						//alert( cSeek )
						lContinua := .T.
						If Alltrim(SC7->C7_NUM + SC7->C7_ITEM) <> Alltrim(aWBrowse[y,5] + aWBrowse[y,1])
						  //se posicionou em pedido diferente, verifica de novo
							SC7->(OrdSetFocus(1)) //C7_FILIAL + C7_NUM + C7_ITEM
							If SC7->(Dbseek(xFilial("SC7") + Alltrim(aWBrowse[y,5]) + Alltrim(aWBrowse[y,1]) ))
								lContinua := .T.
							Endif 
						Endif 

						If lContinua  //FR - 30/01/2023 - double check do pedido de compra
						lRet103Vpc := .T.
							
						If lMt103Vpc .And. lValid
							lRet103Vpc := Execblock("MT103VPC",.F.,.F.)
							//alert(lRet103Vpc)
							lRet103Vpc := .T.
						Endif
						
						If lRet103Vpc .And. lValid
						
							nSldPed := SC7->C7_QUANT-SC7->C7_QUJE-SC7->C7_QTDACLA
							
							If (nSldPed > 0 .And. Empty(SC7->C7_RESIDUO) )
							
								if nAmarris == 2
																	
									u_NfePC2Acol(SC7->(RecNo()),,nSlDPed,cItem,,@aRateio,aHeadSDE,@aColsSDE,,.T.)
									
									If SC7->C7_VALIPI > 0
										
										nPosIpi := aScan(aHeader,{|x| AllTrim(x[2])=="D1_VALIPI"})         //HF
										
										if nPosIpi > 0
											aCols[Len(aCols)][nPosIpi] := Val(aWBrowse[y,14])
										endif
										
									EndIf
									
								Else								
									
									nChecktot := 0 
									If !lDesmembra 
									//FR - 09/05/2022 - Alteração - #12682 - Brasmolde - erro ao associar xml tipo cte ao PC		 			
									If cModelo <> "57"
										nQtProd := aWBrowse[y,7] 	
									Else
										nQtProd := aWBrowse[y,6] 
									Endif 
									//FR - 09/05/2022 - Alteração - #12682 - Brasmolde - erro ao associar xml tipo cte ao PC		
									
									//FR - 30/11/2021 - #11584 - ADAR - erro casas decimais - estava arredondando pra mais
									/*
									nVunit  := Round(Val(aWBrowse[y,16]),TamSX3("D1_VUNIT")[2])  //Round(Val(aWBrowse[y,13]),TamSX3("D1_VUNIT")[2])
									nTotal  := Round(Val(aWBrowse[y,17]),TamSX3("D1_TOTAL")[2])  //Round(Val(aWBrowse[y,14]),TamSX3("D1_TOTAL")[2])
									nValipi := Round(Val(aWBrowse[y,18]),TamSX3("D1_VALIPI")[2]) //Round(Val(aWBrowse[y,15]),TamSX3("D1_VALIPI")[2])
									nIpi    := Round(Val(aWBrowse[y,19]),TamSX3("D1_IPI")[2])    //Round(Val(aWBrowse[y,16]),TamSX3("D1_IPI")[2]) 
								 	*/	
								 									 	
								 	//FR - 30/11/2021 - #11584 - ADAR - erro casas decimais - estava arredondando pra mais								 	
								 	//FR - 01/09/2022 - #13255 - ECOAUTOMAÇÃO - correção do posicionamento dos campos abaixo:
									nVunit  := NoRound(Val(aWBrowse[y,17]),TamSX3("D1_VUNIT")[2])  
									nTotal  := NoRound(Val(aWBrowse[y,18]),TamSX3("D1_TOTAL")[2])  
									nValipi := NoRound(Val(aWBrowse[y,19]),TamSX3("D1_VALIPI")[2]) 

									//nPosIpi := aScan(aWBrowse,{|x| AllTrim(x[2])=="D1_IPI"})         //HF

									//If nPosIpi > 0
									//	nIpi    := aWBrowse[y][nPosIpi] 
									//Endif

									nIpi    := NoRound(Val(aWBrowse[y,20]),TamSX3("D1_IPI")[2]) 

									nChecktot := nVunit * nQtProd 	//FR - 06/07/2021    
								 	
								 	If nTotal <> nChecktot		//FR - 06/07/2021
								 		nTotal := nChecktot
								 	Endif
									
									aLinha := {}
									
									aadd(aLinha,{"D1_ITEM"  ,cItem				,Nil})
									aadd(aLinha,{"D1_COD"   ,SC7->C7_PRODUTO	,Nil})
									aadd(aLinha,{"D1_PEDIDO",SC7->C7_NUM		,Nil}) //colocado no inicio Ocrim 19/01
									aadd(aLinha,{"D1_ITEMPC",SC7->C7_ITEM		,Nil}) //colocado no inicio//									
									aadd(aLinha,{"D1_QUANT" ,nQtProd			,Nil})  //validar nSlDPed									
									aadd(aLinha,{"D1_VUNIT" ,nVunit   			,Nil})  //validar SC7->C7_PRECO									
									aadd(aLinha,{"D1_TOTAL" ,nTotal				,Nil})  //(nSlDPed * SC7->C7_PRECO)
									aadd(aLinha,{"D1_VALIPI",nValipi			,Nil})  //SC7->C7_VALIPI					
									aadd(aLinha,{"D1_IPI"   ,nIpi				,Nil})  //SC7->C7_IPI
									
									//FR 10/3/2023 - COPAG
									//aadd(aLinha,{"D1_DESC"		,0				,Nil})  //% desconto
									//aadd(aLinha,{"D1_VALDESC"	,0				,Nil})  //Valor desconto
									//aadd(aLinha,{"D1_SEGURO"	,0				,Nil})  //Valor seguro
									//aadd(aLinha,{"D1_VALFRE"	,0				,Nil})  //Valor frete
									//aadd(aLinha,{"D1_DESPESA"	,0				,Nil})  //Valor despesa
									//FR 10/03/2023 - COPAG

									//FR - 31/03/2021 - Implementar a carga do número de lote do fornecedor para os xmls que possuam a tag "rastro"
									oDet     := {}
																		//For i := 1 To Len(oDet)
									i       := 0
													
									i       := Val(cItem)

									cLote    := ""
									cValLote := ""
									cAnoFab  := ""
									dValLote := Ctod("  /  /    ")
									cValFab  := ""
									dDatFab  := Ctod("  /  /    ")
												
									if Type( "oXml:_NFEPROC:_NFE:_INFNFE:_DET" ) <> "U"

										oDet := oXml:_NFEPROC:_NFE:_INFNFE:_DET
										oDet := IIf(ValType(oDet)=="O",{oDet},oDet)

										if Type("oDet["+Str(i)+"]:_Prod") <> "U"

											if XmlChildEx(oDet[i]:_Prod,"_Rastro") <> nil   //Complemento
										
												cLote   := oDet[i]:_Prod:_Rastro:_NLOTE:TEXT										
												cValLote:= oDet[i]:_Prod:_Rastro:_DVAL:TEXT		//vem assim: "2045-12-16" -> transformar para 16/12/2045
												dValLote:= CtoD( Substr(cValLote,9,2) + "/" + Substr(cValLote,6,2) + "/" + Substr(cValLote,1,4) )										
												cAnoFab := Substr(oDet[i]:_Prod:_Rastro:_DFAB:TEXT , 3,2)  	//vem assim: "2018-08-01" -> transformar para 18 o ano tem 2 dígitos apenas
												cValFab := oDet[i]:_Prod:_Rastro:_DFAB:TEXT
												dDatFab := CtoD( Substr(cValFab,9,2) + "/" + Substr(cValFab,6,2) + "/" + Substr(cValFab,1,4) )										

											endif

										endif

									ElseIf Type( "oXml:_CTEPROC:_CTE:_INFCTE:_VPREST" ) <> "U"  //Se Foire CTE

										oDet := oXml:_CTEPROC:_CTE:_INFCTE:_VPREST
										cProdCte := Padr(GetNewPar("XM_PRODCTE","FRETE"),nTamProd)
										cProdCte :=Iif(Empty(cProdCte),Padr("FRETE",nTamProd),cProdCte)

									ElseIf Type( "oXml:_CTEOSPROC:_CTEOS:_INFCTE:_VPREST" ) <> "U"  //Se Foire CTEOS

										oDet := oXml:_CTEOSPROC:_CTEOS:_INFCTE:_VPREST
										cProdCte := Padr(GetNewPar("XM_PRODCTE","FRETE"),nTamProd)
										cProdCte :=Iif(Empty(cProdCte),Padr("FRETE",nTamProd),cProdCte)

									ElseIf Type( "oXml:_NFSETXT:_INFPROC" )  <> "U" //Se for NFSe NFCE_03 16/05, usado cProdCte só para passar no msm parÂmetro
									
										oDet := oXml:_NFSETXT:_INFPROC
										cProdCte := Padr(GetNewPar("XM_PRODNFS","SERVICO"),nTamProd)
										cProdCte :=Iif(Empty(cProdNfse),Padr("SERVICO",nTamProd),cProdCte)

									Endif

									If lUSALOTE  //flag se o produto USA LOTE B1_RASTRO
										If !Empty(cLote)
											aadd(aLinha,{"D1_LOTEFOR"		,cLote				     ,Nil})		//tipo C , tamanho 18
											If cUsaLoteFor == "S"
												aadd(aLinha,{"D1_LOTECTL"	, Alltrim(Substr(cLote,1,TamSX3("D1_LOTECTL")[1]))    ,Nil})		
											Endif 
										Endif
													
										If !Empty(dValLote)
											aadd(aLinha,{"D1_DTVALID"		,dValLote			     ,Nil})		//tipo D , tamanho 8
										Endif
														
										If !Empty(cAnoFab)
											aadd(aLinha,{"D1_ANOFAB"		,cAnoFab			     ,Nil})		//tipo C , tamanho 2			
										Endif		

										If !Empty(dDatFab)
											aadd(aLinha,{"D1_DFABRIC"		,dDatFab			     ,Nil})		//tipo D , tamanho 8
										Endif
									Endif 								
									//Next
									//FR - 31/03/2021									
									If lXMLPEITE   //PE para incluir campos no aLinha SD1 -> para o aItens
										
										oDet := {}
										
										if Type( "oXml:_NFEPROC:_NFE:_INFNFE:_DET" ) <> "U"
											oDet := oXml:_NFEPROC:_NFE:_INFNFE:_DET
											oDet := IIf(ValType(oDet)=="O",{oDet},oDet)
										ElseIf Type( "oXml:_CTEPROC:_CTE:_INFCTE:_VPREST" ) <> "U"  //Se Foire CTE
											oDet := oXml:_CTEPROC:_CTE:_INFCTE:_VPREST
											cProdCte := Padr(GetNewPar("XM_PRODCTE","FRETE"),nTamProd)
											cProdCte :=Iif(Empty(cProdCte),Padr("FRETE",nTamProd),cProdCte)
										ElseIf Type( "oXml:_CTEOSPROC:_CTEOS:_INFCTE:_VPREST" ) <> "U"  //Se Foire CTEOS
											oDet := oXml:_CTEOSPROC:_CTEOS:_INFCTE:_VPREST
											cProdCte := Padr(GetNewPar("XM_PRODCTE","FRETE"),nTamProd)
											cProdCte :=Iif(Empty(cProdCte),Padr("FRETE",nTamProd),cProdCte)
										ElseIf Type( "oXml:_NFSETXT:_INFPROC" )  <> "U" //Se for NFSe NFCE_03 16/05, usado cProdCte só para passar no msm parÂmetro
											oDet := oXml:_NFSETXT:_INFPROC
											cProdCte := Padr(GetNewPar("XM_PRODNFS","SERVICO"),nTamProd)
											cProdCte :=Iif(Empty(cProdNfse),Padr("SERVICO",nTamProd),cProdCte)
										Endif
							   			
							   			//aRet :=	ExecBlock( "XMLPEITE", .F., .F., { SC7->C7_PRODUTO,oDet,Val(cItem) } )
							   			//FR - 28/12/2020 - #5922-RAZZO
							   			aRet :=	ExecBlock( "XMLPEITE", .F., .F., { SC7->C7_PRODUTO,oDet,Val(cItem) , SC7->C7_NUM, SC7->C7_ITEM } )  
										
										If ValType(aRet) == "A"
											AEval(aRet,{|x| AAdd(aLinha,x)})								
										EndIf
										
							 		EndIf

						 			If lXMLPELOK   //PE para validar os aItens

										oDet := {}

										if Type( "oXml:_NFEPROC:_NFE:_INFNFE:_DET" ) <> "U"
											oDet := oXml:_NFEPROC:_NFE:_INFNFE:_DET
											oDet := IIf(ValType(oDet)=="O",{oDet},oDet)
										ElseIf Type( "oXml:_CTEPROC:_CTE:_INFCTE:_VPREST" ) <> "U"  //Se Foire CTE
											oDet := oXml:_CTEPROC:_CTE:_INFCTE:_VPREST
											cProdCte := Padr(GetNewPar("XM_PRODCTE","FRETE"),nTamProd)
											cProdCte :=Iif(Empty(cProdCte),Padr("FRETE",nTamProd),cProdCte)
										ElseIf Type( "oXml:_CTEOSPROC:_CTEOS:_INFCTE:_VPREST" ) <> "U"  //Se Foire CTEOS
											oDet := oXml:_CTEOSPROC:_CTEOS:_INFCTE:_VPREST
											cProdCte := Padr(GetNewPar("XM_PRODCTE","FRETE"),nTamProd)
											cProdCte :=Iif(Empty(cProdCte),Padr("FRETE",nTamProd),cProdCte)
										ElseIf Type( "oXml:_NFSETXT:_INFPROC" )  <> "U" //Se for NFSe NFCE_03 16/05, usado cProdCte só para passar no msm parÂmetro
											oDet := oXml:_NFSETXT:_INFPROC
											cProdCte := Padr(GetNewPar("XM_PRODNFS","SERVICO"),nTamProd)
											cProdCte :=Iif(Empty(cProdNfse),Padr("SERVICO",nTamProd),cProdCte)
										Endif

					 					lLOk :=	ExecBlock( "XMLPELOK", .F., .F., { cModelo,SC7->C7_PRODUTO,oDet,Val(cItem) } )
						 				If ValType(lLOk) <> "L"
						 					Alert( "Ponto de entrada XMLPELOK deve Retornar .T. ou .F." )
						 					lLOk := .F.
						 				EndIf
	
						 				If !lLOk
						 					Exit
						 				Endif
						 			Endif
							 		
						 			aadd(aItens,aLinha)
						 			aLinha := {} //FR -01/11/2022 - MBIOLOG
						 			If Empty(cPedidis) .or. ! (SC7->C7_NUM $ cPedidis)
						 				cPedidis += iif(! Empty(cPedidis),",","" )+"'"+SC7->C7_NUM+"'"
						 			Endif

									//----------------------------------//
									//DESMEMBRA ITEMS POR QTDE DE LOTE
									//----------------------------------//
									Else
										
										nL       := 1
										nTotal   := 0
										cLote    := ""
										cValLote := ""
										cAnoFab  := ""
										dValLote := Ctod("  /  /    ")
										cValFab  := ""
										dDatFab  := Ctod("  /  /    ")
										nQuant   := 0

										While nL <= Len(oDet[i]:_PROD:_RASTRO) 

											//quantidade do produto										
											cTagAux := "oDet["+AllTrim(str(I))+"]:_PROD:_RASTRO[" + Alltrim(str(nL))+ "]:_QLOTE:TEXT"  
											If type( cTagAux ) <> "U"
												nQuant := VAL(&cTagAux)		
											Endif

											nVunit  := NoRound(Val(aWBrowse[y,17]),TamSX3("D1_VUNIT")[2]) 
											nTotal := nQuant * nVunit

											//If Len(aWBrowse[y])>=20
												//nIpi    := NoRound(Val(aWBrowse[y,20]),TamSX3("D1_IPI")[2]) 
												//nValipi := NoRound( (nIpi/100) * nTotal ,TamSX3("D1_VALIPI")[2])  //calcula o ipi pelo total do item desmembrado
											//Elseif Len(aWBrowse[y]) <= 19 
												nIpi    := NoRound(Val(aWBrowse[y,20]),TamSX3("D1_IPI")[2]) 												
											//Endif 
											nValipi := NoRound( (nIpi/100) * nTotal ,TamSX3("D1_VALIPI")[2])  //calcula o ipi pelo total do item desmembrado
											
											
											//MONTA ARRAY DE ITENS
											aLinha := {}
											aadd(aLinha,{"D1_ITEM"  ,StrZero(nL,4)		,Nil})
											aadd(aLinha,{"D1_COD"   ,SC7->C7_PRODUTO	,Nil})
											aadd(aLinha,{"D1_PEDIDO",SC7->C7_NUM		,Nil}) //colocado no inicio Ocrim 19/01
											aadd(aLinha,{"D1_ITEMPC",SC7->C7_ITEM		,Nil}) //colocado no inicio//									
											aadd(aLinha,{"D1_QUANT" ,nQuant				,Nil})  //validar nSlDPed									
											aadd(aLinha,{"D1_VUNIT" ,nVunit   			,Nil})  //validar SC7->C7_PRECO									
											aadd(aLinha,{"D1_TOTAL" ,nTotal				,Nil})  //(nSlDPed * SC7->C7_PRECO)
											aadd(aLinha,{"D1_VALIPI",nValipi			,Nil})  //SC7->C7_VALIPI					
											aadd(aLinha,{"D1_IPI"   ,nIpi				,Nil})  //SC7->C7_IPI

											//FR 10/3/2023 - COPAG
											//aadd(aLinha,{"D1_DESC"		,0				,Nil})  //% desconto
											//aadd(aLinha,{"D1_VALDESC"	,0				,Nil})  //Valor desconto
											//aadd(aLinha,{"D1_SEGURO"	,0				,Nil})  //Valor seguro
											//aadd(aLinha,{"D1_VALFRE"	,0				,Nil})  //Valor frete
											//aadd(aLinha,{"D1_DESPESA"	,0				,Nil})  //Valor despesa
											//FR 10/03/2023 - COPAG

											//campos relativos ao número de lote:
										 	IF Type( "oXml:_NFEPROC:_NFE:_INFNFE:_DET" ) <> "U"

												oDet := oXml:_NFEPROC:_NFE:_INFNFE:_DET
												oDet := IIf(ValType(oDet)=="O",{oDet},oDet)
												if Type("oDet["+Str(i)+"]:_Prod") <> "U"
															
													if XmlChildEx(oDet[i]:_Prod,"_RASTRO") <> nil  
																			
														If Type("oDet["+Str(i)+"]:_Prod:_RASTRO") <> "A"
																	
															cLote   := oDet[i]:_Prod:_Rastro:_NLOTE:TEXT										
															cValLote:= oDet[i]:_Prod:_Rastro:_DVAL:TEXT		//vem assim: "2045-12-16" -> transformar para 16/12/2045
															dValLote:= CtoD( Substr(cValLote,9,2) + "/" + Substr(cValLote,6,2) + "/" + Substr(cValLote,1,4) )										
															cAnoFab := Substr(oDet[i]:_Prod:_Rastro:_DFAB:TEXT , 3,2)  	//vem assim: "2018-08-01" -> transformar para 18 o ano tem 2 dígitos apenas
															cValFab := oDet[i]:_Prod:_Rastro:_DFAB:TEXT
															dDatFab := CtoD( Substr(cValFab,9,2) + "/" + Substr(cValFab,6,2) + "/" + Substr(cValFab,1,4) )										
																	
														Else  //oDet[1]:_PROD:_RASTRO[1]:
															cLote   := oDet[i]:_Prod:_Rastro[nL]:_NLOTE:TEXT										
															cValLote:= oDet[i]:_Prod:_Rastro[nL]:_DVAL:TEXT		//vem assim: "2045-12-16" -> transformar para 16/12/2045
															dValLote:= CtoD( Substr(cValLote,9,2) + "/" + Substr(cValLote,6,2) + "/" + Substr(cValLote,1,4) )										
															cAnoFab := Substr(oDet[i]:_Prod:_Rastro[nL]:_DFAB:TEXT , 3,2)  	//vem assim: "2018-08-01" -> transformar para 18 o ano tem 2 dígitos apenas
															cValFab := oDet[i]:_Prod:_Rastro[nL]:_DFAB:TEXT
															dDatFab := CtoD( Substr(cValFab,9,2) + "/" + Substr(cValFab,6,2) + "/" + Substr(cValFab,1,4) )
														Endif																			
													endif
												endif
											ENDIF  

											If !Empty(cLote)
												aadd(aLinha,{"D1_LOTEFOR"		,cLote				     ,Nil})		//tipo C , tamanho 18
												If cUsaLoteFor == "S"
													aadd(aLinha,{"D1_LOTECTL"	, Alltrim(Substr(cLote,1,TamSX3("D1_LOTECTL")[1]))    ,Nil})		
												Endif 
											Endif
														
											If !Empty(dValLote)
												aadd(aLinha,{"D1_DTVALID"		,dValLote			     ,Nil})		//tipo D , tamanho 8
											Endif
															
											If !Empty(cAnoFab)
												aadd(aLinha,{"D1_ANOFAB"		,cAnoFab			     ,Nil})		//tipo C , tamanho 2			
											Endif		

											If !Empty(dDatFab)
												aadd(aLinha,{"D1_DFABRIC"		,dDatFab			     ,Nil})		//tipo D , tamanho 8
											Endif								
											//MONTA ARRAY DE ITENS

											//VALIDAÇÕES ADICIONAIS PARA LINHA DE ITENS
											If lXMLPEITE   //PE para incluir campos no aLinha SD1 -> para o aItens
										
												oDet := {}
												
												if Type( "oXml:_NFEPROC:_NFE:_INFNFE:_DET" ) <> "U"
													oDet := oXml:_NFEPROC:_NFE:_INFNFE:_DET
													oDet := IIf(ValType(oDet)=="O",{oDet},oDet)
												ElseIf Type( "oXml:_CTEPROC:_CTE:_INFCTE:_VPREST" ) <> "U"  //Se Foire CTE
													oDet := oXml:_CTEPROC:_CTE:_INFCTE:_VPREST
													cProdCte := Padr(GetNewPar("XM_PRODCTE","FRETE"),nTamProd)
													cProdCte :=Iif(Empty(cProdCte),Padr("FRETE",nTamProd),cProdCte)
												ElseIf Type( "oXml:_CTEOSPROC:_CTEOS:_INFCTE:_VPREST" ) <> "U"  //Se Foire CTEOS
													oDet := oXml:_CTEOSPROC:_CTEOS:_INFCTE:_VPREST
													cProdCte := Padr(GetNewPar("XM_PRODCTE","FRETE"),nTamProd)
													cProdCte :=Iif(Empty(cProdCte),Padr("FRETE",nTamProd),cProdCte)
												ElseIf Type( "oXml:_NFSETXT:_INFPROC" )  <> "U" //Se for NFSe NFCE_03 16/05, usado cProdCte só para passar no msm parÂmetro
													oDet := oXml:_NFSETXT:_INFPROC
													cProdCte := Padr(GetNewPar("XM_PRODNFS","SERVICO"),nTamProd)
													cProdCte :=Iif(Empty(cProdNfse),Padr("SERVICO",nTamProd),cProdCte)
												Endif
							   			
							   					aRet :=	ExecBlock( "XMLPEITE", .F., .F., { SC7->C7_PRODUTO,oDet,Val(cItem) , SC7->C7_NUM, SC7->C7_ITEM } )  
												
												If ValType(aRet) == "A"
													AEval(aRet,{|x| AAdd(aLinha,x)})								
												EndIf
										
							 				EndIf

											If lXMLPELOK   //PE para validar os aItens

												oDet := {}

												if Type( "oXml:_NFEPROC:_NFE:_INFNFE:_DET" ) <> "U"
													oDet := oXml:_NFEPROC:_NFE:_INFNFE:_DET
													oDet := IIf(ValType(oDet)=="O",{oDet},oDet)
												ElseIf Type( "oXml:_CTEPROC:_CTE:_INFCTE:_VPREST" ) <> "U"  //Se Foire CTE
													oDet := oXml:_CTEPROC:_CTE:_INFCTE:_VPREST
													cProdCte := Padr(GetNewPar("XM_PRODCTE","FRETE"),nTamProd)
													cProdCte :=Iif(Empty(cProdCte),Padr("FRETE",nTamProd),cProdCte)
												ElseIf Type( "oXml:_CTEOSPROC:_CTEOS:_INFCTE:_VPREST" ) <> "U"  //Se Foire CTEOS
													oDet := oXml:_CTEOSPROC:_CTEOS:_INFCTE:_VPREST
													cProdCte := Padr(GetNewPar("XM_PRODCTE","FRETE"),nTamProd)
													cProdCte :=Iif(Empty(cProdCte),Padr("FRETE",nTamProd),cProdCte)
												ElseIf Type( "oXml:_NFSETXT:_INFPROC" )  <> "U" //Se for NFSe NFCE_03 16/05, usado cProdCte só para passar no msm parÂmetro
													oDet := oXml:_NFSETXT:_INFPROC
													cProdCte := Padr(GetNewPar("XM_PRODNFS","SERVICO"),nTamProd)
													cProdCte :=Iif(Empty(cProdNfse),Padr("SERVICO",nTamProd),cProdCte)
												Endif

												lLOk :=	ExecBlock( "XMLPELOK", .F., .F., { cModelo,SC7->C7_PRODUTO,oDet,Val(cItem) } )
												If ValType(lLOk) <> "L"
													Alert( "Ponto de entrada XMLPELOK deve Retornar .T. ou .F." )
													lLOk := .F.
												EndIf
			
												If !lLOk
													Exit
												Endif
											Endif
											//VALIDAÇÕES ADICIONAIS PARA LINHA DE ITENS

											aadd(aItens,aLinha)
						 					aLinha := {} 
											nL++
										Enddo

										If Empty(cPedidis) .or. ! (SC7->C7_NUM $ cPedidis)
											cPedidis += iif(! Empty(cPedidis),",","" )+"'"+SC7->C7_NUM+"'"
										Endif
										
						 			Endif //lDesmembra

						 		EndIf     //nAmarris == 2
							 		
								cItem := SomaIt(cItem)
							
							EndIf	//If (nSldPed > 0 .And. Empty(SC7->C7_RESIDUO) )
						EndIf
						Endif //If lContinua  //FR - 30/01/2023 - double check do pedido de compra
					EndIf				
				Next y
			
			Else

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Posiciona Pedido de Compra                               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If GetNewPAr("XM_XPEDXML","1") == "4"
					lSelecITEM := .T.
				Endif

				//If !lSelecITEM 
				For nx	:= 1 to Len(aF4For)
	
					If aF4For[nx][1] // Verifica se o fornecedor foi selecionado
						DbSelectArea("SC7")
						DbSetOrder(9)
						cSeek := ""
						cSeek += xFilEnt(xFilial("SC7"))+cA100For
						cSeek += If( lNfMedic, aF4For[nx,5]+aF4For[nx,6], aF4For[nx][2]+aF4For[nx][3] )
						MsSeek(cSeek)
						If lZeraCols
							aCols		:= {}
							lZeraCols	:= .F.
							MaFisClear()
						EndIf
		
						// Muda ordem para trazer ordenado por item
						If !Eof()
							cSeek      := xFilEnt(xFilial("SC7")) + If( lNfMedic, aF4For[nx,6], aF4For[nx][3] )  //C7_FILIAL + C7_NUM
							cFilialOri := C7_FILIAL
							DbSetOrder(14)   //C7_FILENT + C7_NUM + C7_ITEM					
							dbSeek(cSeek)
						EndIf

						//-----------------------------------//
						//FR - 19/09/2022 - PROJETO PAPIRUS
						//-----------------------------------//
						If lSelecITEM
							
							DbSetOrder(1)  //C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN							
							cSeek := xFilEnt(xFilial("SC7")) + aF4For[nx][3] + aF4For[nx][xPosItem]
							
							If SC7->(dbSeek(cSeek))
								
								//FR - 12/10/2022 - procurar se esse item do pedido corresponde ao que está no XML 
								//pois pode ser que o fornecedor mande parcial
								nTemNoXML := 0
								ntem      := 0							
								//FR - 12/10/2022
								//---------------------------------------------------------------------------------------------------//
								//FR - 12/10/2022 - Refinamento da carga de itens do pedido a pré-nota
								//carregar apenas os itens da SC7 que forem correspondentes aos itens do XML
								//desde que exista a amarração na SA5, caso contrário, carrega tudo e a pessoa q opera, deleta 
								//o que não for usar para gerar a pré-nota
								//nTemNoXML	:= AScan(aPedXML,{ |x| Alltrim(x[5]) == Alltrim(aWBrowse[fr,3]) } )
								//Verifica se no array aPedXML possui o código interno (SB1) , se sim, é porque encontrou amarração
									
								//essa busca abaixo, só é válida se o produto possui amarração na SA5 ou ZB5
								//caso contrário, segue normal adicionando todos os itens do pedido na pré-nota
								//aí caberá ao usuário deletar o que não vai usar
								//---------------------------------------------------------------------------------------------------//									
								For ntem := 1 to Len(aPedXML)
									If !Empty(Alltrim(aPedXML[ntem,5]))
										If Alltrim(aF4For[nx,8]) == Alltrim(aPedXML[ntem,5])
											nTemNoXML := ntem
											Exit	
										Endif
									Else 
										nTemNoXML := 1 //se estiver vazio, assume 1 e adiciona o item do pedido mesmo assim
									Endif  
								Next

								If nTemNoXML > 0  //Se o produto do pedido foi encontrado o XML , adiciona
								
									//----------------------------------------------------------------------------//
									//FR - 19/09/2022 - ALTERAÇÃO PROJETO PAPIRUS
									//OBJETIVO: propiciar tela de seleção de pedido de compra por item
									//Aqui refaz a verificação dentro do loop de leitura do SC7 para saber se o
									//item foi selecionado (evita que pedidos/itens não selecionados sejam lidos)
									//----------------------------------------------------------------------------//
									aLinha := {}
									nSldPed := SC7->C7_QUANT-SC7->C7_QUJE-SC7->C7_QTDACLA
									nVlrXml := SC7->C7_PRECO

									If SC7->C7_MOEDA == 1 //se a moeda for REAL, mantém desta forma
											
										aadd(aLinha,{"D1_ITEM"  ,cItem				             ,Nil})
										aadd(aLinha,{"D1_COD"   ,SC7->C7_PRODUTO           		 ,Nil})
										aadd(aLinha,{"D1_PEDIDO",SC7->C7_NUM					 ,Nil}) //colocado no inicio Ocrim 19/01
										aadd(aLinha,{"D1_ITEMPC",SC7->C7_ITEM					 ,Nil}) //colocado no inicio
										aadd(aLinha,{"D1_QUANT" ,nSlDPed						 ,Nil})
										aadd(aLinha,{"D1_VUNIT" ,nVlrXml						 ,Nil})
										aadd(aLinha,{"D1_TOTAL" ,(nSlDPed * nVlrXml)			 ,Nil})
										aadd(aLinha,{"D1_IPI"   ,SC7->C7_IPI					 ,Nil})
										aadd(aLinha,{"D1_VALIPI",SC7->C7_VALIPI					 ,Nil}) 
										aadd(aLinha,{"D1_VALDESC",SC7->C7_VLDESC				 ,Nil}) //Isto esta la no HFXMLFUN direto.
											
										cItem := SomaIt(cItem)
										aadd(aItens,aLinha)	
										aLinha := {} //FR - 01/11/2022 -MBIOLOG

									Else 
										//FR - 03/05/2023 - AJUSTES PARA VYDENCE POIS ELES NÃO ALIMENTAM NO PC, A TAXA MOEDA
										//ENTÃO PEGAREI DA SM2 (FUNÇÃO RECMOEDA)						
										nTXMOEDA := SC7->C7_TXMOEDA
										If nTXMOEDA <= 0 
											//SE FOR ZERO, PEGA DA SM2
											nTXMOEDA := RecMoeda(dDataBase,SC7->C7_MOEDA)
										Endif 
										//por precaução se não tiver a moeda cadastrada, assume 1
										If nTXMOEDA <= 0
											nTXMOEDA := 1 
										Endif 
										aadd(aLinha,{"D1_ITEM"  ,cItem				             			,Nil})
										aadd(aLinha,{"D1_COD"   ,SC7->C7_PRODUTO           		 			,Nil})
										aadd(aLinha,{"D1_PEDIDO",SC7->C7_NUM					 			,Nil}) //colocado no inicio Ocrim 19/01
										aadd(aLinha,{"D1_ITEMPC",SC7->C7_ITEM					 			,Nil}) //colocado no inicio
										aadd(aLinha,{"D1_QUANT" ,nSlDPed						 			,Nil})
										//aadd(aLinha,{"D1_VUNIT" ,(nVlrXml * SC7->C7_TXMOEDA)	 			,Nil})
										//aadd(aLinha,{"D1_TOTAL" ,(nSlDPed * (nVlrXml * SC7->C7_TXMOEDA))	,Nil})
										aadd(aLinha,{"D1_VUNIT" ,(nVlrXml * nTXMOEDA)	 					,Nil})
										aadd(aLinha,{"D1_TOTAL" ,(nSlDPed * (nVlrXml * nTXMOEDA))			,Nil})
										aadd(aLinha,{"D1_IPI"   ,SC7->C7_IPI 								,Nil})
										//aadd(aLinha,{"D1_VALIPI",(SC7->C7_VALIPI * SC7->C7_TXMOEDA) 		,Nil}) 
										//aadd(aLinha,{"D1_VALDESC",(SC7->C7_VLDESC * SC7->C7_TXMOEDA) 		,Nil}) //Isto esta la no HFXMLFUN direto.
										aadd(aLinha,{"D1_VALIPI",(SC7->C7_VALIPI * nTXMOEDA) 				,Nil}) 
										aadd(aLinha,{"D1_VALDESC",(SC7->C7_VLDESC * nTXMOEDA) 				,Nil}) //Isto esta la no HFXMLFUN direto.

										cItem := SomaIt(cItem)
										aadd(aItens,aLinha)	
										aLinha := {}  //FR - 01/11/2022 - MBIOLOB			
									Endif	//If SC7->C7_MOEDA == 1
								Endif		//If nTemNoXML > 0  
							Endif //dbseek
							//Endif //lProssegue 
 
						Else  //se não for por seleção de item, faz do jeito já existente
						
						//cSeek -> C7_FILIAL + C7_NUM
						While ( !Eof() .And. SC7->C7_FILENT+SC7->C7_NUM == cSeek )
							//FR - 12/10/2022 - procurar se esse item do pedido corresponde ao que está no XML 
							//pois pode ser que o fornecedor mande parcial
							nTemNoXML := 0
							ntem      := 0							
							//FR - 12/10/2022

							// Verifica se o fornecedor esta correto
							If C7_FILIAL+C7_FORNECE+C7_LOJA == cFilialOri+cA100For+ If( lNfMedic, aF4For[nx,5], aF4For[nx][2] )
								// Verifica se o Produto existe Cadastrado na Filial de Entrada
								DbSelectArea("SB1")
								DbSetOrder(1)

								//------------------------------------------------------//
								//FR - 13/04/2023 - CHECA ANTES O B1_RASTRO
								//------------------------------------------------------//
								lUSALOTE := .F.
								MsSeek(xFilial("SB1") + SC7->C7_PRODUTO)							
								If SB1->B1_RASTRO == "N"  
									//se o produto não controla Lote, desativo o lDesmembra para não realizar desmembramento indevidamente
									lDesmembra := .F.
									lUSALOTE   := .F.
								Elseif SB1->B1_RASTRO == "L"
									lUSALOTE := .T.
								Endif
								//---------------------------------------------------------//
								//FR - 13/04/2023 - CHECA ANTES O B1_RASTRO
								//--------------------------------------------------------//
								

								IF !Eof()
									//---------------------------------------------------------------------------------------------------//
									//FR - 12/10/2022 - Refinamento da carga de itens do pedido a pré-nota
									//carregar apenas os itens da SC7 que forem correspondentes aos itens do XML
									//desde que exista a amarração na SA5, caso contrário, carrega tudo e a pessoa q opera, deleta 
									//o que não for usar para gerar a pré-nota
									//nTemNoXML	:= AScan(aPedXML,{ |x| Alltrim(x[5]) == Alltrim(aWBrowse[fr,3]) } )
									//Verifica se no array aPedXML possui o código interno (SB1) , se sim, é porque encontrou amarração
									
									//essa busca abaixo, só é válida se o produto possui amarração na SA5 ou ZB5
									//caso contrário, segue normal adicionando todos os itens do pedido na pré-nota
									//aí caberá ao usuário deletar o que não vai usar
									//---------------------------------------------------------------------------------------------------//									
									If Len(aPedXml) > 0
										For ntem := 1 to Len(aPedXML)
											If !Empty(Alltrim(aPedXML[ntem,5]))
												If Alltrim(SC7->C7_PRODUTO) == Alltrim(aPedXML[ntem,5])
													nTemNoXML := ntem
													Exit	
												Endif
											Else 
												nTemNoXML := 1 //se estiver vazio, assume 1 e adiciona o item do pedido mesmo assim
											Endif  
										Next
									Else 
										nTemNoXML := 1
									Endif 

									If nTemNoXML > 0  //Se o produto do pedido foi encontrado o XML , adiciona
										DbSelectArea("SC7")
										lRet103Vpc := .T.
										If lMt103Vpc
											lRet103Vpc := Execblock("MT103VPC",.F.,.F.)
										Endif
										If lRet103Vpc
					
											nSldPed := SC7->C7_QUANT-SC7->C7_QUJE-SC7->C7_QTDACLA
					
											If (nSldPed > 0 .And. Empty(SC7->C7_RESIDUO) )
					
												If nAmarris == 2
					
													u_NfePC2Acol(SC7->(RecNo()),,nSlDPed,cItem,,@aRateio,aHeadSDE,@aColsSDE)
					
													If SC7->C7_VALIPI > 0
					
														nPosIpi := aScan(aHeader,{|x| AllTrim(x[2])=="D1_VALIPI"})         //HF
					
														If nPosIpi > 0
															aCols[Len(aCols)][nPosIpi] := SC7->C7_VALIPI
														Endif
					
													EndIf
					
												Else
					
													aLinha := {}

														//Se for NFSE trata as variaveis de valor e quantidade
													If (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO"))) == "RP"	

														if GetNewPar("XM_PED_GBR","N") $ "S/P"  //FR - 06/08/2020 - parâmetro "Trava Pré-Nota" S-Sim (Trava), N-Não , P-Pergunta

															//Verifica se a tag do nota veio preenchida
															cTagAux := "OXML:_NFSETXT:_INFPROC:_VRSERV:TEXT"   //Valor

															If Type( cTagAux ) <> "U"

																nVlrXml := Val(&cTagAux)

																if nVlrXml <> SC7->C7_PRECO

																	If MsgYesNo( 'Pedido = ' + cValtoChar(SC7->C7_PRECO) + ' e Xml =' + cValtoChar(nVlrXml) , 'Valor Divergente. Deseja continuar ?' )

																		if AllTrim(GetNewPar("XM_PED_PRE","N")) == "S" 

																			nVlrXml := SC7->C7_PRECO

																		endif

																	Else

																		Return(.F.)

																	Endif

																endif

															Endif

														else

															cTagAux := "OXML:_NFSETXT:_INFPROC:_VRSERV:TEXT" 

															If Type( cTagAux ) <> "U"

																nVlrXml := Val(&cTagAux)

															endif
																
														endif

													else
															
														nVlrXml := SC7->C7_PRECO
														//-----------------------------------------------------------------------------------//
														//FR - 19/10/2022 -TRATATIVA DO NÚMERO DE LOTE QUANDO HÁ VÁRIOS LOTES NO MESMO ITEM
														//MBIOLOG
														//----------------------------------------------------------------------------------//
														oDet := {}
														i    := 0															
														i    := Val(cItem)
														If Type( "oXml:_NFEPROC:_NFE:_INFNFE:_DET" ) <> "U"

															oDet := oXml:_NFEPROC:_NFE:_INFNFE:_DET
															oDet := IIf(ValType(oDet)=="O",{oDet},oDet)
															
															If Type("oDet["+Str(i)+"]:_Prod") <> "U"																
																If XmlChildEx(oDet[i]:_Prod,"_RASTRO") <> nil   																		
																	If Type("oDet["+Str(i)+"]:_Prod:_RASTRO") == "A"
																		If Len(oDet[i]:_PROD:_RASTRO) > 1	//se o array de lote tiver mais que 1 lote, sugere desmembramento
																			If cDesmembra == "S" 			//só faz o desmembramento se o parâmetro estiver ativado Sim					
																				lDesmembra := .T.
																			Endif
																		Endif    
																	Endif 
																Endif 
															Endif 
														Endif
														//-----------------------------------------------------------------------------------//
														//FR - 19/10/2022 -TRATATIVA DO NÚMERO DE LOTE QUANDO HÁ VÁRIOS LOTES NO MESMO ITEM
														//MBIOLOG
														//----------------------------------------------------------------------------------//													

													endif	//If (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO"))) == "RP"	
					

													//--------------------------------------------------------------------------//			
													//FR - 14/06/2022 - Brasmolde - PEDIDO DE COMPRA EM DÓLAR E NF EM REAIS
													//                  Converte o valor do item no xml, utilizando a taxa moeda 
													//                  do pedido, porque a NF vem em REAIS
													//--------------------------------------------------------------------------//
													//------------------------------------------------------//
													//FR - 13/04/2023 - CHECA ANTES O B1_RASTRO
													//------------------------------------------------------//
													lUSALOTE := .F.	
													cRastro  := ""												
													cRastro  := Posicione("SB1",1,xFilial("SB1")+SC7->C7_PRODUTO,"B1_RASTRO")
													If cRastro == "N"  
														//se o produto não controla Lote, desativo o lDesmembra para não realizar desmembramento indevidamente
														lDesmembra := .F.
														lUSALOTE   := .F.
													Elseif cRastro == "L"
														lUSALOTE := .T.
													Endif
													//---------------------------------------------------------//
													//FR - 13/04/2023 - CHECA ANTES O B1_RASTRO
													//--------------------------------------------------------//
													If !lDesmembra
														If SC7->C7_MOEDA == 1 //se a moeda for REAL, mantém desta forma
															
															aadd(aLinha,{"D1_ITEM"  ,cItem				             ,Nil})
															aadd(aLinha,{"D1_COD"   ,SC7->C7_PRODUTO           		 ,Nil})
															aadd(aLinha,{"D1_PEDIDO",SC7->C7_NUM					 ,Nil}) //colocado no inicio Ocrim 19/01
															aadd(aLinha,{"D1_ITEMPC",SC7->C7_ITEM					 ,Nil}) //colocado no inicio
															aadd(aLinha,{"D1_QUANT" ,nSlDPed						 ,Nil})
															aadd(aLinha,{"D1_VUNIT" ,nVlrXml						 ,Nil})
															aadd(aLinha,{"D1_TOTAL" ,(nSlDPed * nVlrXml)			 ,Nil})
															aadd(aLinha,{"D1_IPI"   ,SC7->C7_IPI					 ,Nil})
															aadd(aLinha,{"D1_VALIPI",SC7->C7_VALIPI					 ,Nil}) 
															aadd(aLinha,{"D1_VALDESC",SC7->C7_VLDESC				 ,Nil}) //Isto esta la no HFXMLFUN direto.
															
														Else 
															
															//FR - 03/05/2023 - AJUSTES PARA VYDENCE POIS ELES NÃO ALIMENTAM NO PC, A TAXA MOEDA
															//ENTÃO PEGAREI DA SM2 (FUNÇÃO RECMOEDA)						
															nTXMOEDA := SC7->C7_TXMOEDA
															If nTXMOEDA <= 0 
																//SE FOR ZERO, PEGA DA SM2
																nTXMOEDA := RecMoeda(dDataBase,SC7->C7_MOEDA)
															Endif 
															//por precaução se não tiver a moeda cadastrada, assume 1
															If nTXMOEDA <= 0
																nTXMOEDA := 1 
															Endif 
															aadd(aLinha,{"D1_ITEM"  ,cItem				             			,Nil})
															aadd(aLinha,{"D1_COD"   ,SC7->C7_PRODUTO           		 			,Nil})
															aadd(aLinha,{"D1_PEDIDO",SC7->C7_NUM					 			,Nil}) //colocado no inicio Ocrim 19/01
															aadd(aLinha,{"D1_ITEMPC",SC7->C7_ITEM					 			,Nil}) //colocado no inicio
															aadd(aLinha,{"D1_QUANT" ,nSlDPed						 			,Nil})
															aadd(aLinha,{"D1_VUNIT" ,(nVlrXml * nTXMOEDA)	 					,Nil})
															aadd(aLinha,{"D1_TOTAL" ,(nSlDPed * (nVlrXml * nTXMOEDA))			,Nil})
															aadd(aLinha,{"D1_IPI"   ,SC7->C7_IPI 								,Nil})
															aadd(aLinha,{"D1_VALIPI",(SC7->C7_VALIPI * nTXMOEDA) 				,Nil}) 
															aadd(aLinha,{"D1_VALDESC",(SC7->C7_VLDESC * nTXMOEDA) 				,Nil}) //Isto esta la no HFXMLFUN direto.
															
														Endif 
														//--------------------------------------------------------------------------//			
														//FR - 14/06/2022 - Brasmolde - PEDIDO DE COMPRA EM DÓLAR E NF EM REAIS
														//                  Converte o valor do item no xml, utilizando a taxa moeda 
														//                  do pedido, porque a NF vem em REAIS
														//--------------------------------------------------------------------------//
														If lXMLPEITE   //PE para incluir campos no aLinha SD1 -> para o aItens
						
															oDet := {}
						
															if Type( "oXml:_NFEPROC:_NFE:_INFNFE:_DET" ) <> "U"
																oDet := oXml:_NFEPROC:_NFE:_INFNFE:_DET
																oDet := IIf(ValType(oDet)=="O",{oDet},oDet)
															ElseIf Type( "oXml:_CTEPROC:_CTE:_INFCTE:_VPREST" ) <> "U"  //Se Foire CTE
																oDet := oXml:_CTEPROC:_CTE:_INFCTE:_VPREST
																cProdCte := Padr(GetNewPar("XM_PRODCTE","FRETE"),nTamProd)
																cProdCte :=Iif(Empty(cProdCte),Padr("FRETE",nTamProd),cProdCte)
															ElseIf Type( "oXml:_CTEOSPROC:_CTEOS:_INFCTE:_VPREST" ) <> "U"  //Se Foire CTEOS
																oDet := oXml:_CTEOSPROC:_CTEOS:_INFCTE:_VPREST
																cProdCte := Padr(GetNewPar("XM_PRODCTE","FRETE"),nTamProd)
																cProdCte :=Iif(Empty(cProdCte),Padr("FRETE",nTamProd),cProdCte)
															ElseIf Type( "oXml:_NFSETXT:_INFPROC" )  <> "U" //Se for NFSe NFCE_03 16/05, usado cProdCte só para passar no msm parÂmetro
																oDet := oXml:_NFSETXT:_INFPROC
																cProdCte := Padr(GetNewPar("XM_PRODNFS","SERVICO"),nTamProd)
																cProdCte :=Iif(Empty(cProdNfse),Padr("SERVICO",nTamProd),cProdCte)
															Endif
																		
															//aRet :=	ExecBlock( "XMLPEITE", .F., .F., { SC7->C7_PRODUTO,oDet,Val(cItem) } )
															//FR - 28/12/2020 - #5922-RAZZO
															aRet :=	ExecBlock( "XMLPEITE", .F., .F., { SC7->C7_PRODUTO,oDet,Val(cItem) , SC7->C7_NUM, SC7->C7_ITEM } )  
						
															If ValType(aRet) == "A"
																AEval(aRet,{|x| AAdd(aLinha,x)})
															EndIf
						
														EndIf
														If lXMLPELOK   //PE para validar os aItens
															oDet := {}
															if Type( "oXml:_NFEPROC:_NFE:_INFNFE:_DET" ) <> "U"
																oDet := oXml:_NFEPROC:_NFE:_INFNFE:_DET
																oDet := IIf(ValType(oDet)=="O",{oDet},oDet)
															ElseIf Type( "oXml:_CTEPROC:_CTE:_INFCTE:_VPREST" ) <> "U"  //Se Foire CTE
																oDet := oXml:_CTEPROC:_CTE:_INFCTE:_VPREST
																cProdCte := Padr(GetNewPar("XM_PRODCTE","FRETE"),nTamProd)
																cProdCte :=Iif(Empty(cProdCte),Padr("FRETE",nTamProd),cProdCte)
															ElseIf Type( "oXml:_CTEOSPROC:_CTEOS:_INFCTE:_VPREST" ) <> "U"  //Se Foire CTEOS
																oDet := oXml:_CTEOSPROC:_CTEOS:_INFCTE:_VPREST
																cProdCte := Padr(GetNewPar("XM_PRODCTE","FRETE"),nTamProd)
																cProdCte :=Iif(Empty(cProdCte),Padr("FRETE",nTamProd),cProdCte)
															ElseIf Type( "oXml:_NFSETXT:_INFPROC" )  <> "U" //Se for NFSe NFCE_03 16/05, usado cProdCte só para passar no msm parÂmetro
																oDet := oXml:_NFSETXT:_INFPROC
																cProdCte := Padr(GetNewPar("XM_PRODNFS","SERVICO"),nTamProd)
																cProdCte :=Iif(Empty(cProdNfse),Padr("SERVICO",nTamProd),cProdCte)
															Endif

															lLOk :=	ExecBlock( "XMLPELOK", .F., .F., { cModelo,SC7->C7_PRODUTO,oDet,Val(cItem) } )
															If ValType(lLOk) <> "L"
																Alert( "Ponto de entrada XMLPELOK deve Retornar .T. ou .F." )
																lLOk := .F.
															EndIf
															If ! lLOk
																Exit
															Endif
														Endif
														//FR - 31/03/2021 - Implementar a carga do número de lote do fornecedor para os xmls que possuam a tag "rastro"
														oDet     := {}
																					//For i := 1 To Len(oDet)
														i       := 0
																
														i       := Val(cItem)		

														cLote := ""
														cValLote := ""
														cAnoFab  := ""
														dValLote := Ctod("  /  /    ")
														cValFab  := ""
														dDatFab  := Ctod("  /  /    ")
															
														if Type( "oXml:_NFEPROC:_NFE:_INFNFE:_DET" ) <> "U"

															oDet := oXml:_NFEPROC:_NFE:_INFNFE:_DET
															oDet := IIf(ValType(oDet)=="O",{oDet},oDet)
															if Type("oDet["+Str(i)+"]:_Prod") <> "U"

																//FR - 04/05/2022 - ALTERAÇÃO - #12673 - ICOMON - correção do erro variável não é objeto
																//Verificar antes se oDet é tipo array ou tipo objeto, (EX: NF 000125218)
																IF lUSALOTE	
																if XmlChildEx(oDet[i]:_Prod,"_RASTRO") <> nil   //Complemento
																			
																	If Type("oDet["+Str(i)+"]:_Prod:_RASTRO") <> "A"
																	
																		cLote   := oDet[i]:_Prod:_Rastro:_NLOTE:TEXT										
																		cValLote:= oDet[i]:_Prod:_Rastro:_DVAL:TEXT		//vem assim: "2045-12-16" -> transformar para 16/12/2045
																		dValLote:= CtoD( Substr(cValLote,9,2) + "/" + Substr(cValLote,6,2) + "/" + Substr(cValLote,1,4) )										
																		cAnoFab := Substr(oDet[i]:_Prod:_Rastro:_DFAB:TEXT , 3,2)  	//vem assim: "2018-08-01" -> transformar para 18 o ano tem 2 dígitos apenas
																		cValFab := oDet[i]:_Prod:_Rastro:_DFAB:TEXT
																		dDatFab := CtoD( Substr(cValFab,9,2) + "/" + Substr(cValFab,6,2) + "/" + Substr(cValFab,1,4) )										
																	
																	Else  //oDet[1]:_PROD:_RASTRO[1]:
																		cLote   := oDet[i]:_Prod:_Rastro[nL]:_NLOTE:TEXT										
																		cValLote:= oDet[i]:_Prod:_Rastro[nL]:_DVAL:TEXT		//vem assim: "2045-12-16" -> transformar para 16/12/2045
																		dValLote:= CtoD( Substr(cValLote,9,2) + "/" + Substr(cValLote,6,2) + "/" + Substr(cValLote,1,4) )										
																		cAnoFab := Substr(oDet[i]:_Prod:_Rastro[nL]:_DFAB:TEXT , 3,2)  	//vem assim: "2018-08-01" -> transformar para 18 o ano tem 2 dígitos apenas
																		cValFab := oDet[i]:_Prod:_Rastro[nL]:_DFAB:TEXT
																		dDatFab := CtoD( Substr(cValFab,9,2) + "/" + Substr(cValFab,6,2) + "/" + Substr(cValFab,1,4) )
																			
																	Endif 
																			
																endif
																ENDIF //LUSALOTE
															endif

														ElseIf Type( "oXml:_CTEPROC:_CTE:_INFCTE:_VPREST" ) <> "U"  //Se Foire CTE

															oDet := oXml:_CTEPROC:_CTE:_INFCTE:_VPREST
															cProdCte := Padr(GetNewPar("XM_PRODCTE","FRETE"),nTamProd)
															cProdCte :=Iif(Empty(cProdCte),Padr("FRETE",nTamProd),cProdCte)
														ElseIf Type( "oXml:_CTEOSPROC:_CTEOS:_INFCTE:_VPREST" ) <> "U"  //Se Foire CTEOS

															oDet := oXml:_CTEOSPROC:_CTEOS:_INFCTE:_VPREST
															cProdCte := Padr(GetNewPar("XM_PRODCTE","FRETE"),nTamProd)
															cProdCte :=Iif(Empty(cProdCte),Padr("FRETE",nTamProd),cProdCte)

														ElseIf Type( "oXml:_NFSETXT:_INFPROC" )  <> "U" //Se for NFSe NFCE_03 16/05, usado cProdCte só para passar no msm parÂmetro
																	
															oDet := oXml:_NFSETXT:_INFPROC
															cProdCte := Padr(GetNewPar("XM_PRODNFS","SERVICO"),nTamProd)
															cProdCte :=Iif(Empty(cProdNfse),Padr("SERVICO",nTamProd),cProdCte)
														Endif																					

														//FR - 13/04/2023 - CHECA SE USA LOTE - B1_RASTRO
														If lUSALOTE
															If !Empty(cLote)
																aadd(aLinha,{"D1_LOTEFOR"		,cLote				     ,Nil})		//tipo C , tamanho 18
																If cUsaLoteFor == "S"
																	aadd(aLinha,{"D1_LOTECTL"	, Alltrim(Substr(cLote,1,TamSX3("D1_LOTECTL")[1]))    ,Nil})		
																Endif 
															Endif
																		
															If !Empty(dValLote)
																aadd(aLinha,{"D1_DTVALID"		,dValLote			     ,Nil})		//tipo D , tamanho 8
															Endif
																		
															If !Empty(cAnoFab)
																aadd(aLinha,{"D1_ANOFAB"		,cAnoFab			     ,Nil})		//tipo C , tamanho 2			
															Endif

															If !Empty(dDatFab)
																aadd(aLinha,{"D1_DFABRIC"		,dDatFab			     ,Nil})		//tipo D , tamanho 8			
															Endif
														Endif 
														//FR - 13/04/2023 - CHECA SE USA LOTE - B1_RASTRO

														//FR - 31/03/2021
														aadd(aItens,aLinha)
														aLinha := {} //FR - 01/11/2022-MBIOLOG
														cItem := SomaIt(cItem)
													
													//--------------------//
													//DESMEMBRA POR LOTE
													//--------------------//
													Else 
														
														//QDO RASTRO É OBJETO!!!
														If Type("oDet["+Str(i)+"]:_Prod:_RASTRO") <> "A"
																	
															cLote   := oDet[i]:_Prod:_Rastro:_NLOTE:TEXT										
															cValLote:= oDet[i]:_Prod:_Rastro:_DVAL:TEXT		//vem assim: "2045-12-16" -> transformar para 16/12/2045
															dValLote:= CtoD( Substr(cValLote,9,2) + "/" + Substr(cValLote,6,2) + "/" + Substr(cValLote,1,4) )										
															cAnoFab := Substr(oDet[i]:_Prod:_Rastro:_DFAB:TEXT , 3,2)  	//vem assim: "2018-08-01" -> transformar para 18 o ano tem 2 dígitos apenas
															cValFab := oDet[i]:_Prod:_Rastro:_DFAB:TEXT
															dDatFab := CtoD( Substr(cValFab,9,2) + "/" + Substr(cValFab,6,2) + "/" + Substr(cValFab,1,4) )										
															
															/////////COPIA E COLA O MESMO QUE ESTÁ NA TRATATIVA QDO É ARRAY	
															
															//quantidade do produto										//FR - 10/03/2020
															cTagAux := "oDet["+AllTrim(str(I))+"]:_PROD:_RASTRO:_QLOTE:TEXT"  
															If type( cTagAux ) <> "U"
																nQuant := VAL(&cTagAux)		
															Endif
																		
															nTotal := nQuant * nVlrXml

															If SC7->C7_MOEDA == 1 //se a moeda for REAL, mantém desta forma
														
																aadd(aLinha,{"D1_ITEM"  ,StrZero(nL,4)		             ,Nil})
																aadd(aLinha,{"D1_COD"   ,SC7->C7_PRODUTO           		 ,Nil})
																aadd(aLinha,{"D1_PEDIDO",SC7->C7_NUM					 ,Nil}) //colocado no inicio Ocrim 19/01
																aadd(aLinha,{"D1_ITEMPC",SC7->C7_ITEM					 ,Nil}) //colocado no inicio
																aadd(aLinha,{"D1_QUANT" ,nQuant							 ,Nil})
																aadd(aLinha,{"D1_VUNIT" ,nVlrXml						 ,Nil})
																aadd(aLinha,{"D1_TOTAL" ,nTotal							 ,Nil})
																aadd(aLinha,{"D1_IPI"   ,SC7->C7_IPI					 ,Nil})
																//aadd(aLinha,{"D1_VALIPI",SC7->C7_VALIPI					 ,Nil}) 
																aadd(aLinha,{"D1_VALIPI", (nTotal * (SC7->C7_IPI/100))	 ,Nil}) 
																aadd(aLinha,{"D1_VALDESC",SC7->C7_VLDESC				 ,Nil}) //Isto esta la no HFXMLFUN direto.
																
															Else 
																
																//FR - 03/05/2023 - AJUSTES PARA VYDENCE POIS ELES NÃO ALIMENTAM NO PC, A TAXA MOEDA
																//ENTÃO PEGAREI DA SM2 (FUNÇÃO RECMOEDA)						
																nTXMOEDA := SC7->C7_TXMOEDA
																If nTXMOEDA <= 0 
																	//SE FOR ZERO, PEGA DA SM2
																	nTXMOEDA := RecMoeda(dDataBase,SC7->C7_MOEDA)
																Endif 
																//por precaução se não tiver a moeda cadastrada, assume 1
																If nTXMOEDA <= 0
																	nTXMOEDA := 1 
																Endif 
																aadd(aLinha,{"D1_ITEM"  ,StrZero(nL,4)		             			,Nil})
																aadd(aLinha,{"D1_COD"   ,SC7->C7_PRODUTO           		 			,Nil})
																aadd(aLinha,{"D1_PEDIDO",SC7->C7_NUM					 			,Nil}) //colocado no inicio Ocrim 19/01
																aadd(aLinha,{"D1_ITEMPC",SC7->C7_ITEM					 			,Nil}) //colocado no inicio
																aadd(aLinha,{"D1_QUANT" ,nQuant						 				,Nil})
																aadd(aLinha,{"D1_VUNIT" ,(nVlrXml * nTXMOEDA)			 			,Nil})
																aadd(aLinha,{"D1_TOTAL" ,(nQuant * (nVlrXml * nTXMOEDA))			,Nil})
																aadd(aLinha,{"D1_IPI"   ,SC7->C7_IPI 								,Nil})
																//aadd(aLinha,{"D1_VALIPI",(SC7->C7_VALIPI * SC7->C7_TXMOEDA) 		,Nil}) 
																aadd(aLinha,{"D1_VALIPI",((nTotal * (SC7->C7_IPI/100)) * nTXMOEDA) 		,Nil}) 
																aadd(aLinha,{"D1_VALDESC",(SC7->C7_VLDESC * nTXMOEDA) 		,Nil}) //Isto esta la no HFXMLFUN direto.
																
															Endif 
															//--------------------------------------------------------------------------//			
															//FR - 14/06/2022 - Brasmolde - PEDIDO DE COMPRA EM DÓLAR E NF EM REAIS
															//                  Converte o valor do item no xml, utilizando a taxa moeda 
															//                  do pedido, porque a NF vem em REAIS
															//--------------------------------------------------------------------------//
															If lXMLPEITE   //PE para incluir campos no aLinha SD1 -> para o aItens
							
																oDet := {}
							
																if Type( "oXml:_NFEPROC:_NFE:_INFNFE:_DET" ) <> "U"
																	oDet := oXml:_NFEPROC:_NFE:_INFNFE:_DET
																	oDet := IIf(ValType(oDet)=="O",{oDet},oDet)
																ElseIf Type( "oXml:_CTEPROC:_CTE:_INFCTE:_VPREST" ) <> "U"  //Se Foire CTE
																	oDet := oXml:_CTEPROC:_CTE:_INFCTE:_VPREST
																	cProdCte := Padr(GetNewPar("XM_PRODCTE","FRETE"),nTamProd)
																	cProdCte :=Iif(Empty(cProdCte),Padr("FRETE",nTamProd),cProdCte)
																ElseIf Type( "oXml:_CTEOSPROC:_CTEOS:_INFCTE:_VPREST" ) <> "U"  //Se Foire CTEOS
																	oDet := oXml:_CTEOSPROC:_CTEOS:_INFCTE:_VPREST
																	cProdCte := Padr(GetNewPar("XM_PRODCTE","FRETE"),nTamProd)
																	cProdCte :=Iif(Empty(cProdCte),Padr("FRETE",nTamProd),cProdCte)
																ElseIf Type( "oXml:_NFSETXT:_INFPROC" )  <> "U" //Se for NFSe NFCE_03 16/05, usado cProdCte só para passar no msm parÂmetro
																	oDet := oXml:_NFSETXT:_INFPROC
																	cProdCte := Padr(GetNewPar("XM_PRODNFS","SERVICO"),nTamProd)
																	cProdCte :=Iif(Empty(cProdNfse),Padr("SERVICO",nTamProd),cProdCte)
																Endif
																			
																//aRet :=	ExecBlock( "XMLPEITE", .F., .F., { SC7->C7_PRODUTO,oDet,Val(cItem) } )
																//FR - 28/12/2020 - #5922-RAZZO
																aRet :=	ExecBlock( "XMLPEITE", .F., .F., { SC7->C7_PRODUTO,oDet,Val(cItem) , SC7->C7_NUM, SC7->C7_ITEM } )  
							
																If ValType(aRet) == "A"
																	AEval(aRet,{|x| AAdd(aLinha,x)})
																EndIf
							
															EndIf
															If lXMLPELOK   //PE para validar os aItens
																oDet := {}
																if Type( "oXml:_NFEPROC:_NFE:_INFNFE:_DET" ) <> "U"
																	oDet := oXml:_NFEPROC:_NFE:_INFNFE:_DET
																	oDet := IIf(ValType(oDet)=="O",{oDet},oDet)
																ElseIf Type( "oXml:_CTEPROC:_CTE:_INFCTE:_VPREST" ) <> "U"  //Se Foire CTE
																	oDet := oXml:_CTEPROC:_CTE:_INFCTE:_VPREST
																	cProdCte := Padr(GetNewPar("XM_PRODCTE","FRETE"),nTamProd)
																	cProdCte :=Iif(Empty(cProdCte),Padr("FRETE",nTamProd),cProdCte)
																ElseIf Type( "oXml:_CTEOSPROC:_CTEOS:_INFCTE:_VPREST" ) <> "U"  //Se Foire CTEOS
																	oDet := oXml:_CTEOSPROC:_CTEOS:_INFCTE:_VPREST
																	cProdCte := Padr(GetNewPar("XM_PRODCTE","FRETE"),nTamProd)
																	cProdCte :=Iif(Empty(cProdCte),Padr("FRETE",nTamProd),cProdCte)
																ElseIf Type( "oXml:_NFSETXT:_INFPROC" )  <> "U" //Se for NFSe NFCE_03 16/05, usado cProdCte só para passar no msm parÂmetro
																	oDet := oXml:_NFSETXT:_INFPROC
																	cProdCte := Padr(GetNewPar("XM_PRODNFS","SERVICO"),nTamProd)
																	cProdCte :=Iif(Empty(cProdNfse),Padr("SERVICO",nTamProd),cProdCte)
																Endif

																lLOk :=	ExecBlock( "XMLPELOK", .F., .F., { cModelo,SC7->C7_PRODUTO,oDet,Val(cItem) } )
																If ValType(lLOk) <> "L"
																	Alert( "Ponto de entrada XMLPELOK deve Retornar .T. ou .F." )
																	lLOk := .F.
																EndIf
																If ! lLOk
																	Exit
																Endif
															Endif
															//FR - 31/03/2021 - Implementar a carga do número de lote do fornecedor para os xmls que possuam a tag "rastro"
															oDet     := {}
																						//For i := 1 To Len(oDet)
															i       := 0
																	
															i       := Val(cItem)		

															cLote := ""
															cValLote := ""
															cAnoFab  := ""
															dValLote := Ctod("  /  /    ")
															cValFab  := ""
															dDatFab  := Ctod("  /  /    ")
																
															if Type( "oXml:_NFEPROC:_NFE:_INFNFE:_DET" ) <> "U"

																oDet := oXml:_NFEPROC:_NFE:_INFNFE:_DET
																oDet := IIf(ValType(oDet)=="O",{oDet},oDet)
																if Type("oDet["+Str(i)+"]:_Prod") <> "U"

																	//FR - 04/05/2022 - ALTERAÇÃO - #12673 - ICOMON - correção do erro variável não é objeto
																	//Verificar antes se oDet é tipo array ou tipo objeto, (EX: NF 000125218)
																		
																	if XmlChildEx(oDet[i]:_Prod,"_RASTRO") <> nil   //Complemento
																				
																		If Type("oDet["+Str(i)+"]:_Prod:_RASTRO") <> "A"
																		
																			cLote   := oDet[i]:_Prod:_Rastro:_NLOTE:TEXT										
																			cValLote:= oDet[i]:_Prod:_Rastro:_DVAL:TEXT		//vem assim: "2045-12-16" -> transformar para 16/12/2045
																			dValLote:= CtoD( Substr(cValLote,9,2) + "/" + Substr(cValLote,6,2) + "/" + Substr(cValLote,1,4) )										
																			cAnoFab := Substr(oDet[i]:_Prod:_Rastro:_DFAB:TEXT , 3,2)  	//vem assim: "2018-08-01" -> transformar para 18 o ano tem 2 dígitos apenas
																			cValFab := oDet[i]:_Prod:_Rastro:_DFAB:TEXT
																			dDatFab := CtoD( Substr(cValFab,9,2) + "/" + Substr(cValFab,6,2) + "/" + Substr(cValFab,1,4) )										
																		
																		//Else  //oDet[1]:_PROD:_RASTRO[1]:
																		//	cLote   := oDet[i]:_Prod:_Rastro[nL]:_NLOTE:TEXT										
																		//	cValLote:= oDet[i]:_Prod:_Rastro[nL]:_DVAL:TEXT		//vem assim: "2045-12-16" -> transformar para 16/12/2045
																		//	dValLote:= CtoD( Substr(cValLote,9,2) + "/" + Substr(cValLote,6,2) + "/" + Substr(cValLote,1,4) )										
																		//	cAnoFab := Substr(oDet[i]:_Prod:_Rastro[nL]:_DFAB:TEXT , 3,2)  	//vem assim: "2018-08-01" -> transformar para 18 o ano tem 2 dígitos apenas
																		//	cValFab := oDet[i]:_Prod:_Rastro[nL]:_DFAB:TEXT
																		//	dDatFab := CtoD( Substr(cValFab,9,2) + "/" + Substr(cValFab,6,2) + "/" + Substr(cValFab,1,4) )
																				
																		Endif 
																				
																	endif
																endif

															ElseIf Type( "oXml:_CTEPROC:_CTE:_INFCTE:_VPREST" ) <> "U"  //Se Foire CTE

																oDet := oXml:_CTEPROC:_CTE:_INFCTE:_VPREST
																cProdCte := Padr(GetNewPar("XM_PRODCTE","FRETE"),nTamProd)
																cProdCte :=Iif(Empty(cProdCte),Padr("FRETE",nTamProd),cProdCte)
															ElseIf Type( "oXml:_CTEOSPROC:_CTEOS:_INFCTE:_VPREST" ) <> "U"  //Se Foire CTEOS

																oDet := oXml:_CTEOSPROC:_CTEOS:_INFCTE:_VPREST
																cProdCte := Padr(GetNewPar("XM_PRODCTE","FRETE"),nTamProd)
																cProdCte :=Iif(Empty(cProdCte),Padr("FRETE",nTamProd),cProdCte)

															ElseIf Type( "oXml:_NFSETXT:_INFPROC" )  <> "U" //Se for NFSe NFCE_03 16/05, usado cProdCte só para passar no msm parÂmetro
																		
																oDet := oXml:_NFSETXT:_INFPROC
																cProdCte := Padr(GetNewPar("XM_PRODNFS","SERVICO"),nTamProd)
																cProdCte :=Iif(Empty(cProdNfse),Padr("SERVICO",nTamProd),cProdCte)
															Endif																					

															//FR - 13/04/2023 - CHECA SE O PRODUTO USA LOTE B1_RASTRO
															If lUSALOTE
																If !Empty(cLote)
																	aadd(aLinha,{"D1_LOTEFOR"		,cLote				     ,Nil})		//tipo C , tamanho 18
																	If cUsaLoteFor == "S"
																		aadd(aLinha,{"D1_LOTECTL"	, Alltrim(Substr(cLote,1,TamSX3("D1_LOTECTL")[1]))    ,Nil})		
																	Endif 
																Endif
																				
																If !Empty(dValLote)
																	aadd(aLinha,{"D1_DTVALID"		,dValLote			     ,Nil})		//tipo D , tamanho 8
																Endif
																				
																If !Empty(cAnoFab)
																	aadd(aLinha,{"D1_ANOFAB"		,cAnoFab			     ,Nil})		//tipo C , tamanho 2			
																Endif

																If !Empty(dDatFab)
																	aadd(aLinha,{"D1_DFABRIC"		,dDatFab			     ,Nil})		//tipo D , tamanho 8			
																Endif
																//fim monta itens do array com desmembramento por lote
															Endif 
															aadd(aItens,aLinha)
															//cItem := SomaIt(cItem)
															aLinha:= {}  //FR - 01/11/2022 - MBIOLOG
															///////COPIA E COLA O MESMO QUE ESTÁ NA TRATATIVA QDO É ARRAY
														
														Else
															//------------------------------------------------//
															//FR - 13/04/2023
															//entra no while se a tag RASTRO for um ARRAY
															//------------------------------------------------//
															nL := 1
															While nL <= Len(oDet[i]:_PROD:_RASTRO)
																//monta itens do array com desmembramento por lote
																
																//quantidade do produto										//FR - 10/03/2020
																cTagAux := "oDet["+AllTrim(str(I))+"]:_PROD:_RASTRO[" + Alltrim(str(nl))+ "]:_QLOTE:TEXT"  
																If type( cTagAux ) <> "U"
																	nQuant := VAL(&cTagAux)		
																Endif
																			
																nTotal := nQuant * nVlrXml

																If SC7->C7_MOEDA == 1 //se a moeda for REAL, mantém desta forma
															
																	aadd(aLinha,{"D1_ITEM"  ,StrZero(nL,4)		             ,Nil})
																	aadd(aLinha,{"D1_COD"   ,SC7->C7_PRODUTO           		 ,Nil})
																	aadd(aLinha,{"D1_PEDIDO",SC7->C7_NUM					 ,Nil}) //colocado no inicio Ocrim 19/01
																	aadd(aLinha,{"D1_ITEMPC",SC7->C7_ITEM					 ,Nil}) //colocado no inicio
																	aadd(aLinha,{"D1_QUANT" ,nQuant							 ,Nil})
																	aadd(aLinha,{"D1_VUNIT" ,nVlrXml						 ,Nil})
																	aadd(aLinha,{"D1_TOTAL" ,nTotal							 ,Nil})
																	aadd(aLinha,{"D1_IPI"   ,SC7->C7_IPI					 ,Nil})
																	//aadd(aLinha,{"D1_VALIPI",SC7->C7_VALIPI					 ,Nil}) 
																	aadd(aLinha,{"D1_VALIPI", (nTotal * (SC7->C7_IPI/100))	 ,Nil}) 
																	aadd(aLinha,{"D1_VALDESC",SC7->C7_VLDESC				 ,Nil}) //Isto esta la no HFXMLFUN direto.
																	
																Else 
																	//FR - 03/05/2023 - AJUSTES PARA VYDENCE POIS ELES NÃO ALIMENTAM NO PC, A TAXA MOEDA
																	//ENTÃO PEGAREI DA SM2 (FUNÇÃO RECMOEDA)						
																	nTXMOEDA := SC7->C7_TXMOEDA
																	If nTXMOEDA <= 0 
																		//SE FOR ZERO, PEGA DA SM2
																		nTXMOEDA := RecMoeda(dDataBase,SC7->C7_MOEDA)
																	Endif 
																	//por precaução se não tiver a moeda cadastrada, assume 1
																	If nTXMOEDA <= 0
																		nTXMOEDA := 1 
																	Endif 
																	
																	aadd(aLinha,{"D1_ITEM"  ,StrZero(nL,4)		             			,Nil})
																	aadd(aLinha,{"D1_COD"   ,SC7->C7_PRODUTO           		 			,Nil})
																	aadd(aLinha,{"D1_PEDIDO",SC7->C7_NUM					 			,Nil}) //colocado no inicio Ocrim 19/01
																	aadd(aLinha,{"D1_ITEMPC",SC7->C7_ITEM					 			,Nil}) //colocado no inicio
																	aadd(aLinha,{"D1_QUANT" ,nQuant						 				,Nil})
																	aadd(aLinha,{"D1_VUNIT" ,(nVlrXml * nTXMOEDA)	 					,Nil})
																	aadd(aLinha,{"D1_TOTAL" ,(nQuant * (nVlrXml * nTXMOEDA))			,Nil})
																	aadd(aLinha,{"D1_IPI"   ,SC7->C7_IPI 								,Nil})																	
																	aadd(aLinha,{"D1_VALIPI",((nTotal * (SC7->C7_IPI/100)) * nTXMOEDA) 	,Nil}) 
																	aadd(aLinha,{"D1_VALDESC",(SC7->C7_VLDESC * nTXMOEDA) 				,Nil}) //Isto esta la no HFXMLFUN direto.
																	
																Endif 
																//--------------------------------------------------------------------------//			
																//FR - 14/06/2022 - Brasmolde - PEDIDO DE COMPRA EM DÓLAR E NF EM REAIS
																//                  Converte o valor do item no xml, utilizando a taxa moeda 
																//                  do pedido, porque a NF vem em REAIS
																//--------------------------------------------------------------------------//
																If lXMLPEITE   //PE para incluir campos no aLinha SD1 -> para o aItens
								
																	oDet := {}
								
																	if Type( "oXml:_NFEPROC:_NFE:_INFNFE:_DET" ) <> "U"
																		oDet := oXml:_NFEPROC:_NFE:_INFNFE:_DET
																		oDet := IIf(ValType(oDet)=="O",{oDet},oDet)
																	ElseIf Type( "oXml:_CTEPROC:_CTE:_INFCTE:_VPREST" ) <> "U"  //Se Foire CTE
																		oDet := oXml:_CTEPROC:_CTE:_INFCTE:_VPREST
																		cProdCte := Padr(GetNewPar("XM_PRODCTE","FRETE"),nTamProd)
																		cProdCte :=Iif(Empty(cProdCte),Padr("FRETE",nTamProd),cProdCte)
																	ElseIf Type( "oXml:_CTEOSPROC:_CTEOS:_INFCTE:_VPREST" ) <> "U"  //Se Foire CTEOS
																		oDet := oXml:_CTEOSPROC:_CTEOS:_INFCTE:_VPREST
																		cProdCte := Padr(GetNewPar("XM_PRODCTE","FRETE"),nTamProd)
																		cProdCte :=Iif(Empty(cProdCte),Padr("FRETE",nTamProd),cProdCte)
																	ElseIf Type( "oXml:_NFSETXT:_INFPROC" )  <> "U" //Se for NFSe NFCE_03 16/05, usado cProdCte só para passar no msm parÂmetro
																		oDet := oXml:_NFSETXT:_INFPROC
																		cProdCte := Padr(GetNewPar("XM_PRODNFS","SERVICO"),nTamProd)
																		cProdCte :=Iif(Empty(cProdNfse),Padr("SERVICO",nTamProd),cProdCte)
																	Endif
																				
																	//aRet :=	ExecBlock( "XMLPEITE", .F., .F., { SC7->C7_PRODUTO,oDet,Val(cItem) } )
																	//FR - 28/12/2020 - #5922-RAZZO
																	aRet :=	ExecBlock( "XMLPEITE", .F., .F., { SC7->C7_PRODUTO,oDet,Val(cItem) , SC7->C7_NUM, SC7->C7_ITEM } )  
								
																	If ValType(aRet) == "A"
																		AEval(aRet,{|x| AAdd(aLinha,x)})
																	EndIf
								
																EndIf
																If lXMLPELOK   //PE para validar os aItens
																	oDet := {}
																	if Type( "oXml:_NFEPROC:_NFE:_INFNFE:_DET" ) <> "U"
																		oDet := oXml:_NFEPROC:_NFE:_INFNFE:_DET
																		oDet := IIf(ValType(oDet)=="O",{oDet},oDet)
																	ElseIf Type( "oXml:_CTEPROC:_CTE:_INFCTE:_VPREST" ) <> "U"  //Se Foire CTE
																		oDet := oXml:_CTEPROC:_CTE:_INFCTE:_VPREST
																		cProdCte := Padr(GetNewPar("XM_PRODCTE","FRETE"),nTamProd)
																		cProdCte :=Iif(Empty(cProdCte),Padr("FRETE",nTamProd),cProdCte)
																	ElseIf Type( "oXml:_CTEOSPROC:_CTEOS:_INFCTE:_VPREST" ) <> "U"  //Se Foire CTEOS
																		oDet := oXml:_CTEOSPROC:_CTEOS:_INFCTE:_VPREST
																		cProdCte := Padr(GetNewPar("XM_PRODCTE","FRETE"),nTamProd)
																		cProdCte :=Iif(Empty(cProdCte),Padr("FRETE",nTamProd),cProdCte)
																	ElseIf Type( "oXml:_NFSETXT:_INFPROC" )  <> "U" //Se for NFSe NFCE_03 16/05, usado cProdCte só para passar no msm parÂmetro
																		oDet := oXml:_NFSETXT:_INFPROC
																		cProdCte := Padr(GetNewPar("XM_PRODNFS","SERVICO"),nTamProd)
																		cProdCte :=Iif(Empty(cProdNfse),Padr("SERVICO",nTamProd),cProdCte)
																	Endif

																	lLOk :=	ExecBlock( "XMLPELOK", .F., .F., { cModelo,SC7->C7_PRODUTO,oDet,Val(cItem) } )
																	If ValType(lLOk) <> "L"
																		Alert( "Ponto de entrada XMLPELOK deve Retornar .T. ou .F." )
																		lLOk := .F.
																	EndIf
																	If ! lLOk
																		Exit
																	Endif
																Endif
																//FR - 31/03/2021 - Implementar a carga do número de lote do fornecedor para os xmls que possuam a tag "rastro"
																oDet     := {}
																							//For i := 1 To Len(oDet)
																i       := 0
																		
																i       := Val(cItem)		

																cLote := ""
																cValLote := ""
																cAnoFab  := ""
																dValLote := Ctod("  /  /    ")
																cValFab  := ""
																dDatFab  := Ctod("  /  /    ")
																	
																if Type( "oXml:_NFEPROC:_NFE:_INFNFE:_DET" ) <> "U"

																	oDet := oXml:_NFEPROC:_NFE:_INFNFE:_DET
																	oDet := IIf(ValType(oDet)=="O",{oDet},oDet)
																	if Type("oDet["+Str(i)+"]:_Prod") <> "U"

																		//FR - 04/05/2022 - ALTERAÇÃO - #12673 - ICOMON - correção do erro variável não é objeto
																		//Verificar antes se oDet é tipo array ou tipo objeto, (EX: NF 000125218)
																			
																		if XmlChildEx(oDet[i]:_Prod,"_RASTRO") <> nil   //Complemento
																					
																			If Type("oDet["+Str(i)+"]:_Prod:_RASTRO") <> "A"
																			
																				cLote   := oDet[i]:_Prod:_Rastro:_NLOTE:TEXT										
																				cValLote:= oDet[i]:_Prod:_Rastro:_DVAL:TEXT		//vem assim: "2045-12-16" -> transformar para 16/12/2045
																				dValLote:= CtoD( Substr(cValLote,9,2) + "/" + Substr(cValLote,6,2) + "/" + Substr(cValLote,1,4) )										
																				cAnoFab := Substr(oDet[i]:_Prod:_Rastro:_DFAB:TEXT , 3,2)  	//vem assim: "2018-08-01" -> transformar para 18 o ano tem 2 dígitos apenas
																				cValFab := oDet[i]:_Prod:_Rastro:_DFAB:TEXT
																				dDatFab := CtoD( Substr(cValFab,9,2) + "/" + Substr(cValFab,6,2) + "/" + Substr(cValFab,1,4) )										
																			
																			Else  //oDet[1]:_PROD:_RASTRO[1]:
																				cLote   := oDet[i]:_Prod:_Rastro[nL]:_NLOTE:TEXT										
																				cValLote:= oDet[i]:_Prod:_Rastro[nL]:_DVAL:TEXT		//vem assim: "2045-12-16" -> transformar para 16/12/2045
																				dValLote:= CtoD( Substr(cValLote,9,2) + "/" + Substr(cValLote,6,2) + "/" + Substr(cValLote,1,4) )										
																				cAnoFab := Substr(oDet[i]:_Prod:_Rastro[nL]:_DFAB:TEXT , 3,2)  	//vem assim: "2018-08-01" -> transformar para 18 o ano tem 2 dígitos apenas
																				cValFab := oDet[i]:_Prod:_Rastro[nL]:_DFAB:TEXT
																				dDatFab := CtoD( Substr(cValFab,9,2) + "/" + Substr(cValFab,6,2) + "/" + Substr(cValFab,1,4) )
																					
																			Endif 
																					
																		endif
																	endif

																ElseIf Type( "oXml:_CTEPROC:_CTE:_INFCTE:_VPREST" ) <> "U"  //Se Foire CTE

																	oDet := oXml:_CTEPROC:_CTE:_INFCTE:_VPREST
																	cProdCte := Padr(GetNewPar("XM_PRODCTE","FRETE"),nTamProd)
																	cProdCte :=Iif(Empty(cProdCte),Padr("FRETE",nTamProd),cProdCte)
																ElseIf Type( "oXml:_CTEOSPROC:_CTEOS:_INFCTE:_VPREST" ) <> "U"  //Se Foire CTEOS

																	oDet := oXml:_CTEOSPROC:_CTEOS:_INFCTE:_VPREST
																	cProdCte := Padr(GetNewPar("XM_PRODCTE","FRETE"),nTamProd)
																	cProdCte :=Iif(Empty(cProdCte),Padr("FRETE",nTamProd),cProdCte)

																ElseIf Type( "oXml:_NFSETXT:_INFPROC" )  <> "U" //Se for NFSe NFCE_03 16/05, usado cProdCte só para passar no msm parÂmetro
																			
																	oDet := oXml:_NFSETXT:_INFPROC
																	cProdCte := Padr(GetNewPar("XM_PRODNFS","SERVICO"),nTamProd)
																	cProdCte :=Iif(Empty(cProdNfse),Padr("SERVICO",nTamProd),cProdCte)
																Endif																					
																//FR - 13/04/2023 - CHECA SE USA LOTE B1_RASTR
																If lUSALOTE
																	If !Empty(cLote)
																		aadd(aLinha,{"D1_LOTEFOR"		,cLote				     ,Nil})		//tipo C , tamanho 18
																		If cUsaLoteFor == "S"
																			aadd(aLinha,{"D1_LOTECTL"	, Alltrim(Substr(cLote,1,TamSX3("D1_LOTECTL")[1]))    ,Nil})		
																		Endif 
																	Endif
																				
																	If !Empty(dValLote)
																		aadd(aLinha,{"D1_DTVALID"		,dValLote			     ,Nil})		//tipo D , tamanho 8
																	Endif
																				
																	If !Empty(cAnoFab)
																		aadd(aLinha,{"D1_ANOFAB"		,cAnoFab			     ,Nil})		//tipo C , tamanho 2			
																	Endif

																	If !Empty(dDatFab)
																		aadd(aLinha,{"D1_DFABRIC"		,dDatFab			     ,Nil})		//tipo D , tamanho 8			
																	Endif
																Endif 
																//FR - 13/04/2023 - CHECA SE USA LOTE B1_RASTR
																//fim monta itens do array com desmembramento por lote
																aadd(aItens,aLinha)
																//cItem := SomaIt(cItem)
																aLinha:= {}  //FR - 01/11/2022 - MBIOLOG
																nL++
															Enddo

														Endif //FR - 13/04/2023
														cItem := SomaIt(cItem)

													Endif 
													If Empty(cPedidis) .or. ! (SC7->C7_NUM $ cPedidis)
														cPedidis += iif(! Empty(cPedidis),",","" )+"'"+SC7->C7_NUM+"'"
													Endif
												Endif		//If nAmarris == 2
												//cItem := SomaIt(cItem)

											EndIf  	//If (nSldPed > 0 .And. Empty(SC7->C7_RESIDUO) )
										Endif		//If lRet103Vpc
									Endif       //nTemNoXML
								Else
									cPrdNCad += "Pedido"+": "+SC7->C7_NUM+"  "+"Produto"+": "+SC7->C7_PRODUTO+CHR(10)
								EndIf  //IF !Eof()
							EndIf    
							
							If lPrjCni       
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Controle do Rateio Financeiro                                           ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If SC7->C7_RATFIN == "1"
									cChaveRat := "SC7"+SC7->C7_FILIAL+SC7->C7_NUM
									F641TrfRat(cChaveRat,@aRatFin,SC7->C7_TOTAL)
								EndIf
							EndIf
							DbSelectArea("SC7")         
							dbSkip()						
						EndDo

				Endif //lSelecITEM //FR - 19/09/2022 - PROJETO PAPIRUS

					Endif	//If aF4For[nx][1]
					
				Next		//For aF4For				
				
			Endif	//If !Empty( aWBrowse ) PEGA DO SC7 
		
	//	EndIf 	   //If aF4For[nx][1]
		
//		If ! lLOk
//			Exit
//		Endif
	
	//Next   

	if ! lLOk
		aItens   := {}
		lRetorno := .F.
		cPedidis := ""  //Esvaziar Pedidos
		Return(.F.)
	Endif
	If lXMLPETOK   //PE para incluir campos no aLinha SD1 -> para o aItens
 		lTOk :=	ExecBlock( "XMLPETOK", .F., .F., { cModelo } )
 		If ValType(lTOk) <> "L"
 			Alert( "Ponto de entrada XMLPETOK deve Retornar .T. ou .F." )
 			lTOk := .F.
 		EndIf
 		if ! lTOk
 			aItens   := {}
 			lRetorno := .F.
 			cPedidis := ""  //Esvaziar Pedidos
 			Return(.F.)
 		Endif
	Endif


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exibe Lista dos Produtos não Cadastrados na Filial de Entrega |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if Len(cPrdNCad)>0 .And. !l103Auto
	   Aviso("A103ProcPC","Produtos não Cadastrados na Filial de Entrega"+CHR(10)+cPrdNCad,{"Ok"})
	EndIf

	If lPrjCni
		//Grava rateio financeiro
		If Len(aRatFin) > 0
			cChaveRat := "SF1"+xFilial("SF1")+cTipo+cNFiscal+cSerie+cA100For+cLoja
			F641GrvRat(cChaveRat,aRatFin)
			aRatFin := {}
		EndIf
	EndIf
         
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restaura o Acols caso o mesmo estiver vazio |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(Acols)=0
	    aCols:= aColsBKP
	    MaFisRestore(nSavNF)
	EndIf
         
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de entrada para manipular o array de multiplas naturezas por titulo no Pedido de Compras .  |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (ExistBlock("MT103NPC"))
		aMT103NPC := ExecBlock("MT103NPC",.F.,.F.,{aHeadSEV,aColsSEV})
	 	If (ValType(aMT103NPC) == "A")
	   		aColsSEV := aClone(aMT103NPC)
		EndIf
	EndIf
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impede que o item do PC seja deletado pela getdados da NFE na movimentacao das setas. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Type( "oGetDados" ) == "O" 	
		oGetDados:lNewLine:=.F.  
		oGetDados:oBrowse:Refresh()
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Rateio do valores de Frete/Seguro/Despesa do PC            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nAmarris == 2
		aGets[SEGURO] := aRateio[1]
		aGets[VALDESP]:= aRateio[2]
		aGets[FRETE]  := aRateio[3]
	EndIf

Endif  //nOpc = =1
ASORT( aItens, , , { | x,y | x[2] < y[2] } ) //FR - ordena por item

Return( lRet )

/*  //FR - 25/10/2020 - função sem uso
Static Function XML20LOK(aWBrowse,y,nSlDPed)

Local lRet := .T.
Local nTamQtdZbb:= TAMSX3("C7_QUANT")[1]
Local nDecQtdZbb:= TAMSX3("C7_QUANT")[2]
Local nPedTrun  := GetNewPar( "XM_PEDTRUN", 0  )
Local nQtdTrun  := 0 
Local nAux := 0
Local cAux := ""
Local nI := 0

if nPedTrun >= 0

	nAux := nSlDPed - Int( nSlDPed )
	cAux :=  AllTrim(str(nAux))
	nDecQtdZbb := 0

	For nI := 3 To Len( cAux )
		nDecQtdZbb++
	Next nI

	if nDecQtdZbb <= nPedTrun
		nDecQtdZbb := nPedTrun  //pelo menos 2 casas
	endif

endif

if lRet

	//FR - 15/10/19 os comentários com esta data, foram realizados porque o array aWBrowse estava desposicionado em alguns campos.
	if aWBrowse[y,6] > nSlDPed

		nQtdTrun  := NOROUND( aWBrowse[y,6] , nDecQtdZbb ) 	

		if nQtdTrun > nSlDPed 
			U_MYAVISO("Atenção","Pedido "+SC7->C7_NUM+" - ITEM: "+SC7->C7_ITEM+" Com Saldo: "+AllTrim(str(nSlDPed))+ CRLF+ "Menor que a Quantidade do Item do XML: "+ Alltrim(Transform( aWBrowse[y,11], "@E 999,999,999.9999999" )),{"CANCELAR"},3) 
			lRet := .F.
		else
			aWBrowse[y,6]  := AllTrim( Str(nQtdTrun,nTamQtdZbb,nDecQtdZbb) )
			aWBrowse[y,13] := AllTrim( Str(nQtdTrun*Val(aWBrowse[y,12]),20,2) )			
		endif

	endif

endif

if lRet
	if Val(aWBrowse[y,13]) <> SC7->C7_PRECO	
		if U_MYAVISO("Atenção","Pedido "+SC7->C7_NUM+" - ITEM: "+SC7->C7_ITEM+" Com Preço: "+ Transform(SC7->C7_PRECO,"@E 999,999,999.99999")+ CRLF+ "Diferente do Item do XML: "+ Transform( Val(aWBrowse[y,13]),"@E 999,999,999.99999"),{"CONTINUAR","CANCELAR"},3) = 2
			lRet := .F.
		endif
	endif
endif

if lRet
	if Val(aWBrowse[y,16]) <> SC7->C7_IPI	
		if U_MYAVISO("Atenção","Pedido "+SC7->C7_NUM+" - ITEM: "+SC7->C7_ITEM+" Com Aliquota do IPI: "+ Transform(SC7->C7_IPI,"@E 99.99")+ CRLF + "Diferente do Item do XML: "+ Transform( Val(aWBrowse[y,16]),"@E 99.99"),{"CONTINUAR","CANCELAR"},3) = 2
			lRet := .F.
		endif
	endif
endif

if lRet
	if Val(aWBrowse[y,15]) <> SC7->C7_VALIPI
		if U_MYAVISO("Atenção","Pedido "+SC7->C7_NUM+" - ITEM: "+SC7->C7_ITEM+" Com Valor do IPI: "+Transform(SC7->C7_VALIPI,"@E 999,999,999.99")+ CRLF + "Diferente do Item do XML: "+ Transform( Val(aWBrowse[y,15]),"@E 999,999,999.99"),{"CONTINUAR","CANCELAR"},3) = 2		
			lRet := .F.
		endif
	endif
endif

Return( lRet )
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³U_HFXMLCPS| Autor ³ Eneovaldo Roveri Jr.  ³ Data ³25/03/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina para Comparar XML recebido com a SEFAZ.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ HFXML02                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function HFXMLCPS(cFileCfg,cXml,cOcorr,lInvalid,cModelo )
Local nRet    := 0
Local aTag    := {}
Local aErr    := {}
//Local cTags   := ""
Local cChave  := ""
Local cXmlSef := ""
Private oXml, oXmlSef
Private cIdEnt:= U_GetIdEnt()


If nRet >= 0
	nRet := HFLerTags( cFileCfg, @aTag )
Endif

If nRet >= 0
	cChave := HFChaveXml( cXml )
	If EMpty( cChave )
		nRet := -2
	Endif
EndIf

//Baixar o XML da SEFAZ
If nRet >= 0
	nRet := HFBXXml( cChave, @cXmlSef )
	if nRet == -4
		nRet := HFMFXml( cChave, "210210" )
		if nRet >= 0
			nRet := HFBXXml( cChave, @cXmlSef )
		endif
	endif
Endif

//For em aTag para comparar as TAGs
If nRet >= 0
	nRet := HFCompTag( aTag, @aErr, cXml, cXmlSef )
	If nRet == 1 .or. nRet == 3
		cXml := cXmlSef
		cMsgTag := "["+cCHave+"] Assumido XML da SEFAZ. XML do fornecedor mau formado ou protocolo inválido."+CRLF
		if lInvalid
			lInvalid := .F.
		Endif
		if .Not. Empty( cOcorr )
			cOcorr := ""
		EndIf
	Endif
Endif

//Adicionar Mensagens e envio de e-mail
If nRet > 0
	HFTagEmail( aTag, aErr, cChave, nRet )
Endif

Return nRet


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ler Arquivo de TAGs e montar matriz aTag com as TAGs que deverão ser Comparadas ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function HFLerTags( cFileCfg, aTag )
Local nHandle  := 0
Local nRet     := 0
Local cBuf     := space(1200)
Local aBuf     := {}
Local nLin     := 0
Private cObj     := "oXml"
Private nObj     := 0

If .NOT. File(cFileCfg)  //isso não pode existir pois foi visto antes
	Return( -9 )
EndIf

nHandle := FT_FUse( cFileCfg )

if nHandle <= 0
	Return( -1 )
endif

FT_FGoTop()

While !FT_FEOF()   
   cBuf := FT_FReadLn() // Retorna a linha corrente
   cBuf := allTrim( cBuf )
   nLin++
   aBuf := Destrincha( cBuf, nLin )
   Aadd( aTag, aBuf )

   FT_FSKIP()
End

Return nRet


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Destrincha Linha do arquivo, com a TAG constante para adicionar em aTag.        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function Destrincha( cBuf, nLin )
Local aRet := {}
//Local nI   := 0
Local cTag := ""
Local nPos1:= 0
Local nPos2:= 0
Local cLin := upper(cBuf)
Local cAcao:= "COMPARAR"
Local lTag := .T.

If Substr(cLin,1,2) == "{}"
	if "/" $ cLin
		aadd( aRet, cObj )
		nObj := nObj - 1
		cObj := "oDet["+AllTrim(Str(nObj))+"]"
		if nObj == 0
			cObj := "oXml"
		endif
		cAcao:= "DESTRUIR"
	Else
		aadd( aRet, cObj )
		nObj := nObj + 1
		cObj := "oDet["+AllTrim(Str(nObj))+"]"
		cAcao:= "CRIAR"
	EndIf
	cLin := StrTran(cLin,"{}","")
	cLin := StrTran(cLin,"/","")
Else
	aadd( aRet, cObj )
	cAcao:= "COMPARAR"
EndIf

Do While .T.
	if len(cLin) <= 1
		Exit
	endif
	nPos1 := AT("<",cLin )+1
	nPos2 := AT(">",cLin )-1
	if nPos2 > nPos1
		if "<" $ SubsTR(cLin,nPos1,(nPos2-1))
			cTag := "Erro TAG Linha "+AllTrim( Str(nLin) )
			lTag := .F.
			Exit
		else
			cTag := cTag + ":_" +SubsTR(cLin,nPos1,(nPos2-1))
		endif
	else
		cTag := "Erro TAG Linha "+AllTrim( Str(nLin) )
		lTag := .F.
		Exit
	endif
	cLin := SubsTR(cLin,nPos2+2,len(cLin))
EndDo

If lTag .And. cAcao == "COMPARAR"
	cTag := cTag + ":TEXT"
EndIf

aadd( aRet, lTag )
aadd( aRet, cTag )
aadd( aRet, cAcao )
aadd( aRet, cBuf )

Return( aRet )


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna a CHAVE do XML para poder fazer o Download da SEFAZ.                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function HFChaveXml( cXml )
Local cError   := ""
Local cWarning := ""
Local nAt3     := 0
Local nAt4     := 0
Local cChaveXml:= ""
Private oXmlTeste, cTAG, cTagCHId, cTagKey

If "<CTE" $ Upper(cXml)
	cTAG := "CTE"
Else
	cTAG := "NFE"
EndIf

oXmlTeste := XmlParser( cXml, "_", @cError, @cWarning )
If oXmlTeste == NIL
	cError := ""
	cWarning := ""
	oXmlTeste := U_PARSGDE( cXml, @cError, @cWarning )
Endif
If Empty(cError) .And. Empty(cWarning) .And. oXmlTeste <> Nil

	cTagCHId  := "oXmlTeste:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_ID:TEXT"
	cTagKey   := "oXmlTeste:_"+cTAG+"PROC:_PROT"+cTAG+":_INFPROT:_CH"+cTAG+":TEXT"

	If Empty( cChaveXml ) .Or. Len(cChaveXml) != 44
		If type(cTagKey) <> "U"
			cChaveXml := &(cTagKey)
		EndIf
	EndIf

	If Empty( cChaveXml ) .Or. Len(cChaveXml) != 44
		If type(cTagCHId) <> "U"
			cChaveXml := Substr(&(cTagCHId),4,44)
		EndIf
	EndIf

EndIf

If Empty( cChaveXml ) .Or. Len(cChaveXml) != 44
	nAt3:= At(Upper('<ch'+cTAG),Upper(cXml)) + 7
	nAt4:= At(Upper('</ch'+cTAG+'>'),Upper(cXml))
	If nAt3 > 7 .And. nAt4 > nAt3
		cChaveXml := Substr(cXml,nAt3,nAt4-nAt3)
	EndIf
EndIf

If Empty( cChaveXml ) .Or. Len(cChaveXml) != 44
	nAt3:= At(Upper('<inf'+cTAG+' Id="'),Upper(cXml)) + 15
	If nAt3 > 15
		cChaveXml := Substr(cXml,nAt3,44)
	EndIf
EndIF

If Len(cChaveXml) != 44
	cChaveXml := ""
EndIf

Return( cChaveXml )


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Download da SEFAZ usando TSS - Por Chave                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function HFBXXml( cChave, cXmlSef, oXmlSef, cNsu )

Local nRet   := -1
Local nI     := 0
Local cURL   := ""
Local cAmb   := ""
Local cNfe   := ""
//Local cIdE   := U_GetIdEnt()
Local cInfo  := ""
Local cMsg   := ""
//Local nHandle:= 0
Local lOk    := .T.
//Local cVerLayEven := "1.00"
//Local cHrVerao    := "2"
//Local cHorario    := "2"
Local oWs,oWsrNfe,oWsdNfe,cErro:="",cWarning:=""
Local cXml        := ""
Local cBkpXml     := ""

Default oXmlSef := NIL

cURL := AllTrim(GetNewPar("XM_URL",""))

If Empty(cURL)

	cURL  := AllTrim(SuperGetMv("MV_SPEDURL"))
	
EndIf

//oWS:=WsSpedCfgNfe():New()
//oWS:cUSERTOKEN 	  	:= "TOTVS"
//oWS:cID_ENT    		:= cIdE
//oWS:nAMBIENTECCE	:= 0	// Atribuicao de '0', efetua a consulta do metodo
//oWS:cVERCCELAYOUT	:= ""
//oWS:cVERCCELAYEVEN	:= ""
//oWS:cVERCCEEVEN		:= ""
//oWS:cVERCCE			:= ""
//oWS:cHORAVERAOCCE	:= ""
//oWS:cHORARIOCCE		:= ""
//oWS:_URL       		:= AllTrim(cURL)+"/SpedCfgNfe.apw"
//lOk:=oWS:CfgCCe()

//If lOk
//	cVerLayEven	:= oWs:oWsCfgCCeResult:cVerCCeLayEven
//	cHrVerao 	:= Left(oWS:oWsCfgCCeResult:cHoraVeraoCCe,1)
//	cHorario 	:= Left(oWS:oWsCfgCCeResult:cHorarioCCe,1)
//EndIf

cCnpj  := SM0->M0_CGC
cAmb   := "1"

If Right( AllTrim(cURL), 1 ) != "/"

	cURL := AllTrim(cURL)+"/"
	
EndIf

//oWSdNfe:= WSHFXMLDOWLOAD():New()
//oWSdNfe:Init()
//oWSdNfe:cCIDENT       := cIdEnt
////oWSdNfe:_URL          := cURL
//oWSdNfe:cCCURL        := cURL
//oWSdNfe:cCAMBIENTE    := cAmb
//oWSdNfe:cCVERSAODADOS := cVerLayEven
//oWSdNfe:cCCUF         := "AN"
//oWSdNfe:cCCNPJ        := cCnpj
//oWSdNfe:cCCHSTR       := cChave

if !Empty( cNsu )

	oWSdNfe:= WSHFXMLNFEDISTRIBUICAODFE():New()
	oWSdNfe:Init()
	oWSdNfe:cCIDENT       := cIdEnt
	oWSdNfe:cCCURL        := cURL
	oWSdNfe:cCAMBIENTE    := cAmb
	oWSdNfe:cCVERSAODADOS := "1.01" //esse é a parada cVerLayEven
	oWSdNfe:cCCUF         := substr(cChave,1,2) //"AN"  //ver isso aqui, é o Estado, agora vem de 1 em 1
	oWSdNfe:cCCNPJ        := cCnpj
	oWSdNfe:cCNSU         := cNsu
	oWSdNfe:cCCHSTR       := ""

else

	oWSdNfe:= WSHFXMLNFEDISTRIBUICAODFE():New()
	oWSdNfe:Init()
	oWSdNfe:cCIDENT       := cIdEnt
	oWSdNfe:cCCURL        := cURL
	oWSdNfe:cCAMBIENTE    := cAmb
	oWSdNfe:cCVERSAODADOS := "1.01" //esse é a parada cVerLayEven
	oWSdNfe:cCCUF         := substr(cChave,1,2) //"AN"  //ver isso aqui, é o Estado, agora vem de 1 em 1
	oWSdNfe:cCCNPJ        := cCnpj
	oWSdNfe:cCNSU         := ""
	oWSdNfe:cCCHSTR       := cChave
	
endif

xRetSef               := "" 		//FR - 30/09/2020

if oWSdNfe:HFNFEDISTRDFE()

	xRetSef := ""

	Conout( "Resposta OK -> Chave: " + cChave )
	
	cXml := "<" + AllTrim(oWSdNfe:cHFNFEDISTRDFERESULT)
	
	nAt1:= At('<RETDISTDFEINT ',Upper(cXml))
	nAt2:= At('</RETDISTDFEINT>',Upper(cXml)) + 16
	
	//Corpo do XML
	If nAt1 <=0
		nAt1:= At('<RETDISTDFEINT>',Upper(cXml))
	EndIf 	
	
	If nAt1 > 0 .And. nAt2 > 16
	
		cNfe := Substr(cXml,nAt1,nAt2-nAt1)

		cXml:= '<?xml version="1.0" encoding="UTF-8"?>'
		cXml+= cNfe		

		//Faz backup do xml sem retirar os caracteres especiais
		cBkpXml := cXml

		cXml := EncodeUTF8(cXml)

		cXml := FwNoAccent(cXml)

		//Executa rotina para retirar os caracteres especiais
		cXml := u_zCarEspec( cXml )

		cErro:= ""
		cWarning:= ""
		
		if Len(cXml) >= 65534
			oWSrNfe := U_PARSGDE( cXml, @cErro, @cWarning )
		Else
			oWSrNfe := XmlParser( cXml ,"_",@cErro, @cWarning )
		endif

		//retorna o backup do xml
		cXml := cBkpXml
		
		xRetSEF := Alltrim(oWSrNfe:_RETDISTDFEINT:_CSTAT:TEXT)  + " - " + Alltrim(oWSrNfe:_RETDISTDFEINT:_XMOTIVO:TEXT)     //código do retorno + descrição, ex: 653 - Rejeicao: NF-e Cancelada, arquivo indisponivel para download 
		
		If oWSrNfe == NIL .Or. !Empty(cErro) .Or. !Empty(cWarning)
		
			cMsg   := "Erro Parser do XML de Resposta"
			cInfo  := cErro + " " + cWarning
			conout(cMsg+cInfo)
			nRet  := -3
			
		elseIf oWSrNfe:_RETDISTDFEINT:_CSTAT:TEXT <> "138" //"139"
		
			cMsg    := "Retorno do Sefaz " + oWSrNfe:_RETDISTDFEINT:_CSTAT:TEXT
			cInfo   := oWSrNfe:_RETDISTDFEINT:_XMOTIVO:TEXT
			xRetSEF := AllTrim(oWSrNfe:_RETDISTDFEINT:_CSTAT:TEXT) +"-"+ AllTrim(oWSrNfe:_RETDISTDFEINT:_XMOTIVO:TEXT)
			Conout(cMsg + " - " + cInfo)
			nRet  := -3
			
		Else
		
			conout("Tenta o Zip")
			
			oDet := oWSrNfe:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP
			oDet := iif( valtype(oDet)=="O", {oDet}, oDet )
			
			For nI := 1 to len( oDet )  //Deixar assim para quando for mais de 1, mas agora tem que ser de 1 em 1.
				
				cStt  := ""
				cMsg  := ""
				cInfo := ""

				cFileZip	:= Decode64( oDet[nI]:TEXT )
				nLenZip		:= Len( cFileZip )
				cFileUnZip  := ""

				// Funcao de descompactacao de arquivos compactados no formato GZip
				lOk  := GzStrDecomp( cFileZip, nLenZip, @cFileUnZip )
										
				if Len(cXml) >= 65534 .and. oXml = NIL
				
					oXml := U_PARSGDE( cFileUnZip, @cErro, @cWarning )
					
				else
				
					oXml := XmlParser( cFileUnZip, "_", @cErro, @cWarning )
					
				endif

				//Alteração em 13/04/2017, erro SalOnline
				If UPPER(Substr(oDet[nI]:_SCHEMA:TEXT,1,7)) <> UPPER("procNFe") //"139"
					
					nRet  := -4
					//xRetSEF:= "633 Falta Manifestação do Destinatário"
					xRetSEF := AllTrim(oWSrNfe:_RETDISTDFEINT:_CSTAT:TEXT) +"-"+ AllTrim(oWSrNfe:_RETDISTDFEINT:_XMOTIVO:TEXT)
					
				ElseIf valtype(oXml) <> "O"
				
					nRet  := -3
					cMsgTag += "(Download) "+"Não foi possível Descompactar o XML." + CRLF
					xRetSEF:= "999 Não foi possível Descompactar o XML"
					
				Else
				
					//cChaveArq := cDir + Substr(cChave,1,44) + "-procNfe.xml" //alltrim( oDet[nI]:_CHNFE:TEXT ) + "-procNfe.xml"
					SAVE oXml XMLSTRING cXML
					
					nAt1:= At('<NFE ',Upper(cXml))
					nAt2:= At('</NFE>',Upper(cXml))+ 6
					
					//Corpo da Nfe
					If nAt1 <= 0
					
						nAt1 := At('<NFE>',Upper(cXml))
						
					EndIf 	
					
					If nAt1 > 0 .And. nAt2 > 6
					
						cNfe := Substr(cXml,nAt1,nAt2-nAt1)
						
					Else
					
						nRet  := -3
						cMsgTag += "(Download) "+"XML "+cChave+" sem TAG <NFE>" + CRLF
						xRetSEF := "999 "+"XML "+cChave+" sem TAG <NFE>"
						
					EndIf	
					
					nAt3:= At('<PROTNFE ',Upper(cXml))
					nAt4:= At('</PROTNFE>',Upper(cXml))+ 10
					
					//Protocolo	
					If nAt3 > 0 .And. nAt4 > 10
					
						cProt := Substr(cXml,nAt3,nAt4-nAt3)
					
					Else
					
						nRet  := -3
						cMsgTag += "XML "+cChave+" sem Protocolo, falta TAG <PROTNFE>" + CRLF
						xRetSEF := "999 "+"XML "+cChave+" sem Protocolo, falta TAG <PROTNFE>"
					
					EndIf
					
					if empty( cMsg )
					
						//cXml:= '<?xml version="1.0"?>'
						cXml:= '<?xml version="1.0" encoding="UTF-8"?>'
						cXml+= '<nfeProc versao="2.00" xmlns="http://www.portalfiscal.inf.br/nfe">'
						cXml+= cNfe
						cXml+= cProt
						cXml+= '</nfeProc>'

						//Faz backup do xml sem retirar os caracteres especiais
						cBkpXml := cXml

						if Len(cXml) >= 65534
							
							oXML := U_PARSGDE( cXml, @cErro, @cWarning )
							
						Else
						
							oXml := XmlParser( cXml, "_", @cErro, @cWarning )
							
						endif

						If oXML == NIL
							//retorna o backup do xml
							cXml := cBkpXml
							cXml := EncodeUTF8(cXml)
							cXml := FwNoAccent(cXml)
							
							//Executa rotina para retirar os caracteres especiais
							cXml := u_zCarEspec( cXml )
							
							if Len(cXml) >= 65534
								
								oXML := U_PARSGDE( cXml, @cErro, @cWarning )
								
							Else
							
								oXml := XmlParser( cXml, "_", @cErro, @cWarning )
								
							endif
						EndIf

						if oXML == NIL .Or. !Empty(cErro) .Or. !Empty(cWarning)
						
							nRet  := -3
							cMsgTag += "(Download) Erro Parser do XML" + CRLF
							xRetSEF := "999 Erro Parser do XML"
							
						Else
						
							nRet  := 0
							oXmlSef := oXml
							cXmlSef := cXml
							
							//SAVE oXML XMLFILE cChaveArq
							//nHandle := FT_FUse( cChaveArq )
							//if nHandle == -1
							//	cStt  := "0"
							//	cMsg  := "Erro Gravação"
							//	cInfo := "Erro de Gravação XML no Diretório "+cChaveArq
							//else
							//	cStt  := "1"
							//	cMsg  := "Download Efetuado"
							//	cInfo := "Download Efetuado do XML "+Substr(cChave,1,44)
							//endif
							//FT_FUSE()
							
						EndIf
						
					Endif

				Endif
				
				DelClassIntf()
				
			Next nI
			
		Endif
		
	Else
	
		conout( "Erro AT "+cChave )
		nRet  := -3
		cMsgTag += "(Download) Erro de retorno do Sefaz. XML de retorno não contém a TAG <RETDISTR>" + CRLF
		xRetSEF:= "999 Erro de retorno do Sefaz. XML de retorno não contém a TAG <RETDISTR>"
		
	EndIf
	
else

	conout( "Problema de comunicação tSS "+cChave )
	nRet  := -3
	cMsgTag += "(Download) Erro TSS ou WS" + CRLF
	xRetSEF := "999 Erro TSS ou WS"
	
Endif

//DelClassIntf()
//nRet := 0
/*
cModelo := ""
cPref   := ""
cTAG    := ""

cModelo := Substr(cChave,21,2)
If cModelo == "55"

	cPref    := "NF-e"
	cTAG     := "NFE"

ElseIf cModelo == "65"

	cPref    := "NFC-e"
	cTAG     := "NFE"

ElseIf cModelo == "57"

	cPref    := "CT-e"
	cTAG     := "CTE"

EndIf
*/
//GRAVA ZBE 
//If nRet < 0         //Se ocorreu erro
	aEvt    := {}    
	cSeqEve := ""     
	aEvt    := U_HF20ZBE( nI, @cSeqEve, cXml )
	nPos    := 0
	nPos    := aScan(aEvt,{|x| AllTrim(x[1])== xZBE_+"DESC"}) 
	
	If nPos > 0
		If Empty(aEvt[nPos][2])
			If !Empty(xRetSEF)
				aEvt[nPos][2] := xRetSEF
				
				cEvent  := "HXL069"  //FR 04/09/2020 - do download em massa preciso saber se gravo este campo ou deixo vazio, por hora deixei a sigla do fonte que chama esta rotina
				cGrv    := ""
				cGrv    := U_HF2GrvEv( cChave, cEvent, cSeqEve, aEvt, .T. )  //U_HF2GrvEv( cKey, cEvent, cSeqEve, aEvt, .T. )		//FR - 04/09/2020
			Endif
		Endif
	Endif
//Endif        

Return( nRet )



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Manifesta como Ciencia da Operação para o Download da SEFAZ.                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//  nRet := U_HF2MFXml( cChave, "210210", cRej, " ", 2 )   //nRet := U_HF2MFXml( Substr(cChave,1,44), "210210", @cRej, "", 2 )
User Function HF2MFXml( cChave, cEve, cRej, cJus, nRep )
Local nRet

nRet := HFMFXml( cChave, cEve, @cRej, cJus, nRep )  //"210210"

Return(nRet)


//Rotina de complemento da manifestação
Static Function HFMFXml( cChave, cEve, cRej, cJus, nRep ) //GETESB2

Local nRet  := 0
Local cPar  := ""

cPar := GetNewPar("XM_DFEMAN","0")

If cPar  == "0"
	nRet := HFMFFad( cChave, cEve, @cRej, cJus, nRep )  //Super HFMFXML
Else
	nRet := HFMFFd2( cChave, cEve, @cRej, cJus, nRep )  //Super para novo modelo da Man
Endif

Return(nRet)


//Rotina de complemento da manifestação
Static Function HFMFFd2(cChave, cEve, cRej, cJus, nRep )

Local nRet    := 0
Local aChave  := {}
Local aRet    := {}
Local nAtraso := 0
Local lTodos  := .T.
Local cLog    := ""
Local cInfo   := ""
Local xMotMn  := ""
Local cMsg    := ""
Local nI      := 0
Local lLoop   := .T.
Local lTodos  := .T.
Local cMsgTag := ""

Default cRej := ""
Default cJus := " " //GETESB2
Default nRep := 4

aChave := {}
aadd(aChave, {Substr(cChave,1,44), cJus } )  //Chave e Justificativa (justifica para quando for 210240)
cLog  := ""
cInfo := ""

For nAtraso := 0 to nRep

	cLog  := ""
	cInfo := ""
	cRej  := ""
	xMotMn:= ""
	aRet  := {}
	
	//Chama rotina de manifestação
	if U_HFXMLMAN( aChave, cEve, , , @cRej,@xMotMn,@cLog,@cInfo, @aRet, .F., nAtraso )
		
		lTodos := .F.

	else

		If (cRej $ "578,579,703,000" .And. nAtraso < nRep )

			Sleep(1500) //da 1 segundo e vai de novo

			Loop

		EndIf

		cMsg   := "[SFZ]"+cRej
		lTodos := .T.
		nRet   := -4
		cMsgTag += cLog + CRLF

	endif

	if .NOT. lTodos

		lLoop:= .F.

		For nI := 1 To Len( aRet )

			if aRet[nI][3] <> "135"

				if ( aRet[nI][3] $ "578,703,000"  .And. nAtraso < nRep )

					Sleep(1500) //da 1 segundo e vai de novo
					
					lLoop:= .T.

					Loop

				Else

					cMsg  := "[SFZ]"+aRet[nI][3]
					cInfo := aRet[nI][4]

				EndIF

				nRet  := -4
				cMsgTag += cMsg + CRLF

			else

				cMsg  := "[SFZ]"+aRet[nI][3]
				cInfo := aRet[nI][4]
				nRet  := 0
				cMsgTag += cMsg + CRLF

			Endif

		Next nI		

		if lLoop

			Sleep(1500) //da 1 segundo e vai de novo

			Loop

		Endif

	endif

	Exit

Next nAtraso

//DelClassIntf()

Return(nRet)


//Rotina de manifestação 
Static Function HFMFFad( cChave, cEve, cRej, cJus, nRep ) //Fadiga Gera da Manifestação.

Local nI     := 0
Local nRet   := 0
Local cEvent := cEve
Local nLote  := 1
//Local nChv   := 0
Local cCnpj  := SM0->M0_CGC  //"61135471000100"
Local cURL   := ""
Local cXml   := ""
Local cNfe   := ""
Local cAmb   := "1"
//Local cIdE   := U_GetIdEnt()
Local cInfo  := ""
Local cMsg   := ""
//Local lTodos := .F.
//Local nHandle:= 0
Local lOk    := .T.
//Local lTemPr := .F.
Local cVerLayEven := "1.00"
Local cHrVerao    := "2"
Local cHorario    := "2"
Local nAtraso     := 0
Local lLoop       := .F.
Local oWS,oWsrMan,oWsdMan,cErro,cWarning
Local cSeqEve := ""  //ZBEMANO
Local aEvt := {}     //Atualizar a ZBEMANO
Local cGrv := ""     //Só Para Receber a Resposta
Local cKey    := ""  //ZBEMANO
Local cMsgTag := ""

Private oDet

Default cRej := ""
Default cJus := " " //GETESB2
Default nRep := 4

cURL    := AllTrim(GetNewPar("XM_URL",""))
If Empty(cURL)
	cURL  := AllTrim(SuperGetMv("MV_SPEDURL"))
EndIf

If Right( AllTrim(cURL), 1 ) != "/"
	cURL := AllTrim(cURL)+"/"
EndIf

//cURL := AllTrim(cURL)+"/"
//cURL := StrTran( cURL, "///", "/" )
//cURL := StrTran( cURL, "//", "/" )

oWS:=WsSpedCfgNfe():New()
oWS:cUSERTOKEN 	  	:= "TOTVS"
oWS:cID_ENT    		:= cIdEnt
oWS:nAMBIENTECCE	:= 0	// Atribuicao de '0', efetua a consulta do metodo
oWS:cVERCCELAYOUT	:= ""
oWS:cVERCCELAYEVEN	:= ""
oWS:cVERCCEEVEN		:= ""
oWS:cVERCCE			:= ""
oWS:cHORAVERAOCCE	:= ""
oWS:cHORARIOCCE		:= ""
oWS:_URL       		:= AllTrim(cURL)+"SpedCfgNfe.apw"   //Alterado tirado a barra 17/12/2015
lOk:=oWS:CfgCCe()

If lOk
	cVerLayEven	:= oWs:oWsCfgCCeResult:cVerCCeLayEven
	cHrVerao 	:= Left(oWS:oWsCfgCCeResult:cHoraVeraoCCe,1)
	cHorario 	:= Left(oWS:oWsCfgCCeResult:cHorarioCCe,1)
EndIf


For nAtraso := 0 to nRep

	// Tratamento da numeracao do lote
	rstmvbuff()

	nLote := ( GetNewPar("XM_LOTEMAN",0) + 1 )
	If !PutMv("XM_LOTEMAN",nLote)
		SX6->(RecLock("SX6",.T.))
		SX6->X6_FIL     := xFilial( "SX6" )
		SX6->X6_VAR     := "XM_LOTEMAN"
		SX6->X6_TIPO    := "N"
		SX6->X6_DESCRIC := "Lote do Evento de Manifestacao"
		SX6->(MsUnLock())
		PutMv("XM_LOTEMAN",nLote)
	EndIf

	oWsdMan:= WSHFXMLMANIFESTO():New()
	oWsdMan:Init()
	oWsdMan:cCIDENT       := cIdEnt
	oWsdMan:cCLOTE        := strzero(nLote,15,0)
	//oWSdNfe:_URL          := cURL
	oWsdMan:cCCURL        := cURL //"http://localhost:8091/ws/" //cURL   
	oWsdMan:cCAMBIENTE    := cAmb
	oWsdMan:cCVERSAODADOS := cVerLayEven
	oWsdMan:cCCUF         := "91"
	oWsdMan:cCHORAVERAO   := cHrVerao
	oWsdMan:cCHORARIO     := cHorario
	oWsdMan:cCCNPJ        := cCnpj
	oWsdMan:cCCHSTR       := cChave
	oWsdMan:cCEVSTR       := cEvent
	oWsdMan:cCXJUST       := cJus  //GETESB2
	oWsdMan:cCDTHREVEN    := U_HFDTTIME( cHrVerao, cHorario, nAtraso )

	if oWsdMan:HFMANISFESTO()

		cXml := oWsdMan:cHFMANISFESTORESULT
		nAt1:= At('<RETENVEVENTO ',Upper(cXml))
		nAt2:= At('</RETENVEVENTO>',Upper(cXml))+ 15

		//Corpo do XML
		If nAt1 <=0
			nAt1:= At('<RETENVEVENTO>',Upper(cXml))
		EndIf

		If nAt1 > 0 .And. nAt2 > 15

			cNfe := Substr(cXml,nAt1,nAt2-nAt1)
	
			cXml:= '<?xml version="1.0" encoding="UTF-8"?>'
			cXml+= cNfe
			cXml := NoAcento(cXml)
			cXml := EncodeUTF8(cXml)
			cErro:= ""
			cWarning:= ""
			oWsrMan := XmlParser( cXml, "_", @cErro, @cWarning )

			If oWsrMan == NIL //.Or. !Empty(cErro) .Or. !Empty(cWarning)

				nRet := -4
				cMsgTag += "(Manifestação) Erro Parser do XML" + CRLF

			elseIf oWsrMan:_RETENVEVENTO:_CSTAT:TEXT <> "128"

				If oWsrMan:_RETENVEVENTO:_CSTAT:TEXT $ "578,703,650" .And. nAtraso < 4

					Sleep(1500) //da 1 segundo e vai de novo

					Loop

				EndIf

				nRet := -4
				cMsgTag += oWsrMan:_RETENVEVENTO:_XMOTIVO:TEXT + "(" + oWsrMan:_RETENVEVENTO:_CSTAT:TEXT + ")" + CRLF
			
			Else

				lLoop:= .F.
				oDet := oWsrMan:_RETENVEVENTO:_RETEVENTO
				oDet := iif( valtype(oDet)=="O", {oDet}, oDet )

				For nI := 1 to len( oDet )

					if Type( "oDet["+AllTrim(Str(nI))+"]:_INFEVENTO:_CHNFE:TEXT" ) <> "U"

						cKey  := oDet[nI]:_INFEVENTO:_CHNFE:TEXT

					Else

						Sleep(1500) //da 1 segundo e vai de novo

						cKey  := ""
						Loop

					Endif

					cMsg  := ""
					cInfo := ""
					cRej  := oDet[nI]:_INFEVENTO:_CSTAT:TEXT

					If oDet[nI]:_INFEVENTO:_CSTAT:TEXT <> "135"

						if oDet[nI]:_INFEVENTO:_CSTAT:TEXT $ "578,703,650" .And. nAtraso < 4

							Sleep(1500) //da 1 segundo e vai de novo

							lLoop := .T.  

							Loop

						Else

							nRet := -4

							if Type( "oDet[nI]:_INFEVENTO:_XMOTIVO:TEXT" ) <> "U"
								cMsgTag += cChave + " " +oDet[nI]:_INFEVENTO:_XMOTIVO:TEXT //+ CRLF
							Else
								cMsgTag += cChave + " " //+""+ CRLF
							Endif

							if cRej == "573"  //aqui já foi manifestado com o mesmo evento

								aEvt    := {}     //ZBEMANO
	    		                cSeqEve := ""     //ZBEMANO 
								aEvt    := U_HF20ZBE( nI, @cSeqEve, cXml )
								cGrv    := U_HF2GrvEv( cKey, cEvent, cSeqEve, aEvt, .T. )

							endif

						EndIF

					Else

						nRet := 0
						aEvt    := {}     //ZBEMANO
	                    cSeqEve := ""     //ZBEMANO
						aEvt    := U_HF20ZBE( nI, @cSeqEve, cXml )
						cGrv    := U_HF2GrvEv( cKey, cEvent, cSeqEve, aEvt, .T. )
						cMsgTag += "Já manifestado anteriormente"
					
					Endif

				Next nI

				if lLoop

					Sleep(1500) //da 1 segundo e vai de novo

					Loop

				Endif

			Endif

		Else

			nRet := -4
			cMsgTag += "(Manifestação) Erro de retorno do Sefaz. XML de retorno não contém a TAG <RETENVEVENTO>"+ CRLF
		
		EndIf

	else

		//Erro TSS ou WS não instalado.
		nRet := -4
		cMsgTag += "(Manifestação) Erro TSS ou WS"+ CRLF

	endif

	if nRet = -4 .And. cRej <> "573"  //aqui já foi manifestado com o mesmo evento

		Sleep(1500) //da 1 segundo e vai de novo//Faz as 4 tentativas mesmo (Aguas do Brasil)

		Loop

	Endif

	Exit

Next 

//DelClassIntf()

Return( nRet )

///FLAVIA
//U_HFDGXML( cChave, .T. , .F. , NIL , "" , 0 , "2" ) > 0

//Retornar o aEvt para gravar ZBE quando da Manifestacione.
//Vir Private oDet.
//PARAMETER: nI -> posição do oDet; cSeqEve -> recebe como @referencia, será atribuido aqui; cXml -> xml para gravar.
User Function HF20ZBE( nI, cSeqEve, cXml ) //ZBEMANO
Local aEvt := {}
Local dDhAut := cTod( "" )
Local cProtC := ""
Local cxEvento := ""
Local cxMotivo	:= ""
Local cError	:= ""
Local cWarning	:= ""
Private cAux := ""
//tem q vir oDet private. Beleza?
//Quando vem do importa xml não tem oDet
cAux := "oDet"
If Type( cAux ) == "U"
	oDet := XmlParser( cXml, "_", @cError, @cWarning )

	cAux := "oDet:_SOAP_ENVELOPE:_SOAP_BODY:_NFERECEPCAOEVENTONFRESULT:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_NSEQEVENTO:TEXT"

	If Type( cAux ) <> "U"
		cSeqEve := oDet:_SOAP_ENVELOPE:_SOAP_BODY:_NFERECEPCAOEVENTONFRESULT:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_NSEQEVENTO:TEXT
	else
		cSeqEve := "01"
	EndIf

	If len(cSeqEve)<=len( (xZBE)->(FieldGet(FieldPos(xZBE_+"SEQEVE"))) )
		cSeqEve := StrZero( Val(cSeqEve), len( (xZBE)->(FieldGet(FieldPos(xZBE_+"SEQEVE"))) ), 0 )
	Endif

	cAux := "oDet:_SOAP_ENVELOPE:_SOAP_BODY:_NFERECEPCAOEVENTONFRESULT:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_DHREGEVENTO:TEXT"

	If Type( cAux ) <> "U"
		cDthRet := oDet:_SOAP_ENVELOPE:_SOAP_BODY:_NFERECEPCAOEVENTONFRESULT:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_DHREGEVENTO:TEXT
		dDhAut  := StoD(substr(cDthRet,1,4)+Substr(cDthRet,6,2)+Substr(cDthRet,9,2))
	EndIf

	cAux := "oDet:_SOAP_ENVELOPE:_SOAP_BODY:_NFERECEPCAOEVENTONFRESULT:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_NPROT:TEXT"

	If Type( cAux ) <> "U"
		cProtC := oDet:_SOAP_ENVELOPE:_SOAP_BODY:_NFERECEPCAOEVENTONFRESULT:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_NPROT:TEXT
	EndIf

	cAux := "oDet:_SOAP_ENVELOPE:_SOAP_BODY:_NFERECEPCAOEVENTONFRESULT:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_XEVENTO:TEXT"

	If Type( cAux ) <> "U"
		cxEvento := oDet:_SOAP_ENVELOPE:_SOAP_BODY:_NFERECEPCAOEVENTONFRESULT:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_XEVENTO:TEXT
	EndIf

	cAux := "oDet:_SOAP_ENVELOPE:_SOAP_BODY:_NFERECEPCAOEVENTONFRESULT:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_CSTAT:TEXT"

	If Type( cAux ) <> "U"
		cxMotivo := oDet:_SOAP_ENVELOPE:_SOAP_BODY:_NFERECEPCAOEVENTONFRESULT:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_CSTAT:TEXT
		cAux := "oDet:_SOAP_ENVELOPE:_SOAP_BODY:_NFERECEPCAOEVENTONFRESULT:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_XMOTIVO:TEXT"		
		If Type( cAux ) <> "U"
			cxMotivo += " - "+ oDet:_SOAP_ENVELOPE:_SOAP_BODY:_NFERECEPCAOEVENTONFRESULT:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_XMOTIVO:TEXT		
			If oDet:_SOAP_ENVELOPE:_SOAP_BODY:_NFERECEPCAOEVENTONFRESULT:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_CSTAT:TEXT == "573"
				cxMotivo += " - MANIFESTACAO EFETUADA ANTERIORMENTE"
			EndIf	
		EndIf
	EndIf
Else
	cAux := "oDet["+AllTrim(Str(nI))+"]:_INFEVENTO:_NSEQEVENTO"
	If Type( cAux ) <> "U"
		cSeqEve := oDet[nI]:_INFEVENTO:_NSEQEVENTO:TEXT
	Else
		cSeqEve := "01"
	EndIF

	If len(cSeqEve)<=len( (xZBE)->(FieldGet(FieldPos(xZBE_+"SEQEVE"))) )
		cSeqEve := StrZero( Val(cSeqEve), len( (xZBE)->(FieldGet(FieldPos(xZBE_+"SEQEVE"))) ), 0 )
	Endif

	cAux := "oDet["+AllTrim(Str(nI))+"]:_INFEVENTO:_DHREGEVENTO"
	If Type( cAux ) <> "U"
		cDthRet := oDet[nI]:_INFEVENTO:_DHREGEVENTO:TEXT
		dDhAut  := StoD(substr(cDthRet,1,4)+Substr(cDthRet,6,2)+Substr(cDthRet,9,2))
	Endif

	cAux := "oDet["+AllTrim(Str(nI))+"]:_INFEVENTO:_NPROT"
	If Type( cAux ) <> "U"
		cProtC := oDet[nI]:_INFEVENTO:_NPROT:TEXT
	Endif

	cAux := "oDet["+AllTrim(Str(nI))+"]:_INFEVENTO:_XEVENTO"
	If Type( cAux ) <> "U"
		cxEvento := oDet[nI]:_INFEVENTO:_XEVENTO:TEXT
	Endif

	cAux := "oDet["+AllTrim(Str(nI))+"]:_INFEVENTO:_CSTAT"
	If Type( cAux ) <> "U"
		cxMotivo := oDet[nI]:_INFEVENTO:_CSTAT:TEXT
		cAux := "oDet["+AllTrim(Str(nI))+"]:_INFEVENTO:_XMOTIVO"
		If Type( cAux ) <> "U"
			cxMotivo += " - " + oDet[nI]:_INFEVENTO:_XMOTIVO:TEXT
			If oDet[nI]:_INFEVENTO:_CSTAT:TEXT == "573"
				cxMotivo += " - MANIFESTACAO EFETUADA ANTERIORMENTE"
			EndIf
		Endif
	Endif

EndIf
aadd( aEvt, {xZBE_+"DHAUT" 	, dDhAut    } )
aadd( aEvt, {xZBE_+"DTRECB"	, dDataBase } )
aadd( aEvt, {xZBE_+"PROT"  	, cProtC    } )
aadd( aEvt, {xZBE_+"XML"   	, cXml      } )
aadd( aEvt, {xZBE_+"DESC"  	, cXMotivo 	} )
aadd( aEvt, {xZBE_+"EVENTO"	, cxEvento	} )
aadd( aEvt, {xZBE_+"STATUS"	, "1"  		} )

Return( aEvt )


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Manifesta como Ciencia da Operação para o Download da SEFAZ.                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function HFCompTag( aTag, aErr, cXml, xXmlSef )
Local nRet := 0
Local nI   := 0
Local nJ   := 0
Local nK   := 0
Local aDet := {}
Local cErro:= "", cWarning:=""

Private cTagAux1 := "", cValAux1 := ""
Private cTagAux2 := "", cValAux2 := ""
Private oDet     := {}, SefoDet  := {}, oDetAux, cTAG

If "<CTE" $ Upper(cXml)
	cTAG := "CTE"
Else
	cTAG := "NFE"
EndIf

oXml := XmlParser( cXml, "_", @cErro, @cWarning )
If oXml == NIL .or. .NOT. Empty(cErro)
	Aadd( aErr, {"oXml","XML Fornecedor Mau Formado","","" } )
	nRet := 1
Endif

if nRet == 0
	For nI := 1 to len( aTag )
		If aTag[nI][2]
			cTagAux1 := aTag[nI][1]+aTag[nI][3]
			cTagAux2 := iif(aTag[nI][1]=="oXml", "oXmlSef", "Sef"+aTag[nI][1] ) +aTag[nI][3]
			cValAux1 := "NULA"
			cValAux2 := "NULA"
			If aTag[nI][4] == "CRIAR"
				nJ++

				Do While Len( oDet ) < nJ
					aadd( oDet, NIL )
					aadd( SefoDet, NIL )
					aadd( aDet, .T. )
				EndDo

				If Type(cTagAux1) <> "U"
					oDetAux := &(cTagAux1)
					oDetAux := if(ValType(oDetAux)=="O",{oDetAux},oDetAux)
					oDet[nJ] := oDetAux
					cValAux1 := "DETALHE"
				Else
					aDet[nJ] := .F.
				EndIf

				If Type(cTagAux2) <> "U"
					oDetAux := &(cTagAux2)
					oDetAux := if(ValType(oDetAux)=="O",{oDetAux},oDetAux)
					SefoDet[nJ] := oDetAux
					cValAux2 := "DETALHE"
				Else
					aDet[nJ] := .F.
				EndIf
				If cValAux1 <> cValAux2
					Aadd( aErr, {aTag[nI][3],cValAux1,cValAux2,aTag[nI][5]} )
				EndIf

			ElseIf aTag[nI][4] == "DESTRUIR"
				oDet[nJ]    := NIL
				SefoDet[nJ] := NIL
				aDet[nJ]    := .T.
				nJ--

			ElseIf aTag[nI][4] == "COMPARAR"
				if nJ == 0
					if type(cTagAux1) <> "U"
						cValAux1 := &(cTagAux1)
					endif
					if type(cTagAux2) <> "U"
						cValAux2 := &(cTagAux2)
					endif

					If cValAux1 <> cValAux2
						Aadd( aErr, {aTag[nI][3],cValAux1,cValAux2,aTag[nI][5]} )
					EndIf
				ElseIf nJ > 0
					if aDet[nJ]
						For nK := 1 To Len(oDet[nJ])  //Ver Cada Tag de Todos os Itens
							cTagAux1 := aTag[nI][1]+"["+AllTrim(Str(nK))+"]"+aTag[nI][3]
							cTagAux2 := iif(aTag[nI][1]=="oXml", "oXmlSef", "Sef"+aTag[nI][1] )+"["+AllTrim(Str(nK))+"]"+aTag[nI][3]
							cValAux1 := "NULA"
							cValAux2 := "NULA"
							if type(cTagAux1) <> "U"
								cValAux1 := &(cTagAux1)
							endif
							if type(cTagAux2) <> "U"
								cValAux2 := &(cTagAux2)
							endif

							If cValAux1 <> cValAux2
								Aadd( aErr, {aTag[nI][3],cValAux1,cValAux2,"Item "+AllTrim(Str(nK))+"-"+aTag[nI][5]} )
							EndIf
						Next nK
					endif
				EndIF

			EndIf

		Else
			Aadd( aErr, {aTag[nI][3],cValAux1,cValAux2,aTag[nI][5]} )
		EndIf
	Next nI

	if Len( aErr ) > 0
		nRet := 2
	EndIf

	cTagAux1 := "oXml:_"   +cTAG+"PROC:_PROT"+cTAG+":_INFPROT:_NPROT:TEXT"
	cTagAux2 := "oXmlSef:_"+cTAG+"PROC:_PROT"+cTAG+":_INFPROT:_NPROT:TEXT"
	cValAux1 := "NULA"
	cValAux2 := "NULA"
	if type(cTagAux1) <> "U"
		cValAux1 := &(cTagAux1)
	endif
	if type(cTagAux2) <> "U"
		cValAux2 := &(cTagAux2)
	endif
	If cValAux1 <> cValAux2 .And. cValAux2 <> "NULA" .and. !Empty(cValAux2)
		Aadd( aErr, {cTagAux1,"Protocolo Invalido","Assumido XML baixado da SEFAZ","" } )
		nRet := 3 //Protocolo Diferente assume o Sefaz
	EndIf

EndIf

Return( nRet )


Static Function HFTagEmail( aTag, aErr, cChave, nAdMen )
Local cAnexo  := ""
Local cError  := ""
Local cMsg    := ""
Local cCap    := "DIVERGENCIA TAG XML FORNECEDOR x SEFAZ"
Local cHea    := ""
Local cInfo   := ""
Local nI      := 0
Local aTo     := {} 
Local cTag    := ""

cInfo += cChave + CRLF
if nAdMen == 3
	cInfo += "Protocolo XML Fornecedor Inválido. Assumido XML da SEFAZ." + CRLF
elseIf nAdMen == 1
	cInfo += "XML Fornecedor mal formado. Assumido XML da SEFAZ." + CRLF
endif

cMsg += '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
cMsg += '<html xmlns="http://www.w3.org/1999/xhtml">'
messagePadron( "",@cHea,"" )
cMsg += cHea
cMsg += '<body>'
cMsg += '<table style="background-color: rgb(240, 240, 240); width: 800px; text-align: left; margin-left: auto; margin-right: auto;" id="total" border="0" cellpadding="12">'
cMsg += '<caption>'+cCap+' EMPRESA '+cEmpAnt+' FILIAL '+cFilAnt+' '+'</caption>'
cMsg += '	<tr>'
cMsg += '		<td colspan="3">'
cMsg += '			<hr>'
cMsg += '				<p class="style1">'+cInfo + CRLF +'</p>'
cMsg += '			</hr>'
cMsg += '		</td>'
cMsg += '	</tr>'

cMsg += '	<tr>'
cMsg += '		<th id="col_tag">TAG</th>'
cMsg += '		<th id="col_for">XML Fornecedor</th>'
cMsg += '		<th id="col_sef">XML SEFAZ</th>'
cMsg += '	</tr>'

For nI := 1 To Len(aErr)
	cMsg += '	<tr>'
	cTag := aErr[nI][4]
	cTag := StrTran(cTag,"<","[")
	cTag := StrTran(cTag,">","]")
	cMsg += '		<td headers="col_tag">' + cTag + '</td>'
	if "ERRO" $ Upper( aErr[nI][1] )
		cMsg += '		<td headers="col_for">' + aErr[nI][1] + '</td>'
		cMsg += '		<td headers="col_sef">' + 'Verifique o Arquivo ..\CFG\TAGNFE.CFG' + '</td>'
	Else
		cMsg += '		<td headers="col_for">' + aErr[nI][2] + '</td>'
		cMsg += '		<td headers="col_sef">' + aErr[nI][3] + '</td>'
	Endif
	cMsg += '	</tr>'
Next nI
cMsg += '</table>'
cMsg += '</body>'
cMsg += '</html>'

cEmailErr := AllTrim(SuperGetMv("XM_MAIL01")) // Conta de Email cancelamento de XML, recebe a priori o comparativo

If !Empty(cEmailErr)
    cAssunto:= "Aviso IMP.XML. Divergência de TAGs."
	aTo 	:= Separa(cEmailErr,";")
	U_MAILSEND(aTo,cAssunto,cMsg,@cError,cAnexo,"",cEmailErr,"","")
EndIf

Return( NIL )



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Empresa   ³ HF Consulting                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ´±±
±±³Funcao    ³messagePad ³ Autor ³ Eneovaldo Roveri Jr                  ³ Data ³ 28/11/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao que retorno um mensagem padrão em html para envio no corpo do e-mail³±±
±±³          ³ utilizada pelo fsendmail e tambem pela fNotific.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Obs.      ³ Voce pode passar os parametros cHead e cBody como referencia para utiliza- ³±±
±±³          ³ los em seu programa, como eh feito no FNotific.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ messagePadron( cCc, cHead, cBody )                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCc   : Mensagem padrao para ir no corpo do e-mail                         ³±±
±±³          ³ cHead : Mandar como referencia para ele retornar o cabecalho padrao        ³±±
±±³          ³ cBody : Mandar como referencia para ele retornar o corpo do e-mail padrao  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³             ATUALIZACOES SOFRIDAS DESDE CONSTRUCAO                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Data      ³ Programador      ³ Manutencao efetuada                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  /  /    ³                  ³                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Comparação de TAGs XML                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function messagePadron( cCc, cHead, cBody )
Local cMsgCfg := ""

cHead := ""
cHead += '<head>'
cHead += '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />'
cHead += '<title>Integração ACPJ X Protheus</title>'
cHead += '  <style type="text/css"> '
cHead += '	<!-- '
cHead += '	body {background-color: rgb(37, 64, 97);} '
cHead += '	.style1 {font-family: Segoe UI,Verdana, Arial;font-size: 12pt;} '
cHead += '	.style2 {font-family: Segoe UI,Verdana, Arial;font-size: 12pt;color: rgb(255,0,0)} '
cHead += '	.style3 {font-family: Segoe UI,Verdana, Arial;font-size: 10pt;color: rgb(37,64,97)} '
cHead += '	.style4 {font-size: 8pt; color: rgb(37,64,97); font-family: Segoe UI,Verdana, Arial;} '
cHead += '	.style5 {font-size: 10pt} '
cHead += '	-->'
cHead += '  </style>'
cHead += '</head>'

cBody := ""
cBody += '<body>'
cBody += '<table style="background-color: rgb(240, 240, 240); width: 800px; text-align: left; margin-left: auto; margin-right: auto;" id="total" border="0" cellpadding="12">'
cBody += '  <tbody>'
cBody += '    <tr>'
cBody += '      <td colspan="2">'
cBody += '    	<Center>'
cBody += '      <img src="http://extranet.helpfacil.com.br/images/cabecalho.jpg">'
cBody += '      </Center><hr>'
cBody += '      <p class="style1">'+cCc+'</p>'
cBody += '      <hr></td>'
cBody += '    </tr>'
cBody += '  </tbody>'
cBody += '</table>'
cBody += '<p class="style1">&nbsp;</p>'
cBody += '</body>'

cMsgCfg := ""
cMsgCfg += '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
cMsgCfg += '<html xmlns="http://www.w3.org/1999/xhtml">'
cMsgCfg += cHead
cMsgCfg += cBody
cMsgCfg += '</html>'

Return cMsgCfg



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³U_HFXMLTAG| Autor ³ Eneovaldo Roveri Jr.  ³ Data ³24/03/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ TAGs padrões para arquivo de comparação XML com SEFAZ.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ HFXML02                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function HFXMLTAG()
Local cRet := ""

cRet += "<NfeProc><Nfe><InfNfe><Ide><cUF>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><Ide><cNF>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><Ide><natOp>"+CRLF
//cRet += "<NfeProc><Nfe><InfNfe><Ide><indPag>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><Ide><mod>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><Ide><serie>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><Ide><dhEmi>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><Ide><dhSaiEnt>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><Ide><tpNF>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><Ide><idDest>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><Ide><cMunFG>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><Ide><tpImp>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><Ide><tpEmis>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><Ide><cDV>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><Ide><tpAmb>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><Ide><finNFe>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><Ide><indFinal>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><Ide><indPres>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><Ide><procEmi>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><Ide><verProc>"+CRLF

cRet += "<NfeProc><Nfe><InfNfe><Emit><CNPJ>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><Emit><xNome>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><Emit><xFant>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><Emit><enderEmit><xLgr>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><Emit><enderEmit><nro>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><Emit><enderEmit><xCpl>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><Emit><enderEmit><xBairro>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><Emit><enderEmit><cMun>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><Emit><enderEmit><xMun>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><Emit><enderEmit><UF>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><Emit><enderEmit><CEP>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><Emit><enderEmit><cPais>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><Emit><enderEmit><xPais>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><Emit><enderEmit><fone>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><Emit><IE>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><Emit><email>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><Emit><CRT>"+CRLF


cRet += "<NfeProc><Nfe><InfNfe><dest><CNPJ>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><dest><xNome>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><dest><xFant>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><dest><enderDest><xLgr>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><dest><enderDest><nro>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><dest><enderDest><xCpl>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><dest><enderDest><xBairro>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><dest><enderDest><cMun>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><dest><enderDest><xMun>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><dest><enderDest><UF>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><dest><enderDest><CEP>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><dest><enderDest><cPais>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><dest><enderDest><xPais>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><dest><enderDest><fone>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><dest><IE>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><dest><email>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><dest><CRT>"+CRLF

cRet += "{}<NfeProc><Nfe><InfNfe><det>"+CRLF  //Inicio dos itens, por isso as TAGs não devem ser informados inteiras
	cRet += "<prod><cProd>"+CRLF
	cRet += "<prod><cEAN>"+CRLF
	cRet += "<prod><xProd>"+CRLF
	cRet += "<prod><NCM>"+CRLF
	cRet += "<prod><CFOP>"+CRLF
	cRet += "<prod><uCom>"+CRLF
	cRet += "<prod><qCom>"+CRLF
	cRet += "<prod><vUnCom>"+CRLF
	cRet += "<prod><vProd>"+CRLF
	cRet += "<prod><cEANTrib>"+CRLF
	cRet += "<prod><uTrib>"+CRLF
	cRet += "<prod><qTrib>"+CRLF
	cRet += "<prod><vUnTrib>"+CRLF
	cRet += "<prod><indTot>"+CRLF
	cRet += "<prod><nItemPed>"+CRLF

	cRet += "<imposto><ICMS><ICMS00><orig>"+CRLF
	cRet += "<imposto><ICMS><ICMS00><CST>"+CRLF
	cRet += "<imposto><ICMS><ICMS00><modBC>"+CRLF
	cRet += "<imposto><ICMS><ICMS00><vBC>"+CRLF
	cRet += "<imposto><ICMS><ICMS00><pICMS>"+CRLF
	cRet += "<imposto><ICMS><ICMS00><vICMS>"+CRLF

	cRet += "<imposto><ICMS><ICMS10><orig>"+CRLF
	cRet += "<imposto><ICMS><ICMS10><CST>"+CRLF
	cRet += "<imposto><ICMS><ICMS10><modBC>"+CRLF
	cRet += "<imposto><ICMS><ICMS10><vBC>"+CRLF
	cRet += "<imposto><ICMS><ICMS10><pICMS>"+CRLF
	cRet += "<imposto><ICMS><ICMS10><vICMS>"+CRLF
	cRet += "<imposto><ICMS><ICMS10><modBCST>"+CRLF
	cRet += "<imposto><ICMS><ICMS10><pMVAST>"+CRLF
	cRet += "<imposto><ICMS><ICMS10><pRedBCST>"+CRLF
	cRet += "<imposto><ICMS><ICMS10><vBCST>"+CRLF
	cRet += "<imposto><ICMS><ICMS10><pICMSST>"+CRLF
	cRet += "<imposto><ICMS><ICMS10><vICMSST>"+CRLF

	cRet += "<imposto><ICMS><ICMS20><orig>"+CRLF
	cRet += "<imposto><ICMS><ICMS20><CST>"+CRLF
	cRet += "<imposto><ICMS><ICMS20><modBC>"+CRLF
	cRet += "<imposto><ICMS><ICMS20><vBC>"+CRLF
	cRet += "<imposto><ICMS><ICMS20><pRedBC>"+CRLF
	cRet += "<imposto><ICMS><ICMS20><pICMS>"+CRLF
	cRet += "<imposto><ICMS><ICMS20><vICMS>"+CRLF

	cRet += "<imposto><ICMS><ICMS30><orig>"+CRLF
	cRet += "<imposto><ICMS><ICMS30><CST>"+CRLF
	cRet += "<imposto><ICMS><ICMS30><modBC>"+CRLF
	cRet += "<imposto><ICMS><ICMS30><vBC>"+CRLF
	cRet += "<imposto><ICMS><ICMS30><pRedBC>"+CRLF
	cRet += "<imposto><ICMS><ICMS30><pICMS>"+CRLF
	cRet += "<imposto><ICMS><ICMS30><vICMS>"+CRLF

	cRet += "<imposto><ICMS><ICMS40><orig>"+CRLF
	cRet += "<imposto><ICMS><ICMS40><CST>"+CRLF
	cRet += "<imposto><ICMS><ICMS40><vICMSDeson>"+CRLF
	cRet += "<imposto><ICMS><ICMS40><motDesICMS>"+CRLF

	cRet += "<imposto><ICMS><ICMS41><orig>"+CRLF
	cRet += "<imposto><ICMS><ICMS41><CST>"+CRLF
	cRet += "<imposto><ICMS><ICMS41><vICMSDeson>"+CRLF
	cRet += "<imposto><ICMS><ICMS41><motDesICMS>"+CRLF

	cRet += "<imposto><ICMS><ICMS50><orig>"+CRLF
	cRet += "<imposto><ICMS><ICMS50><CST>"+CRLF
	cRet += "<imposto><ICMS><ICMS50><vICMSDeson>"+CRLF
	cRet += "<imposto><ICMS><ICMS50><motDesICMS>"+CRLF

	cRet += "<imposto><ICMS><ICMS51><orig>"+CRLF
	cRet += "<imposto><ICMS><ICMS51><CST>"+CRLF
	cRet += "<imposto><ICMS><ICMS51><modBC>"+CRLF
	cRet += "<imposto><ICMS><ICMS51><pRedBC>"+CRLF
	cRet += "<imposto><ICMS><ICMS51><vBC>"+CRLF
	cRet += "<imposto><ICMS><ICMS51><pICMS>"+CRLF
	cRet += "<imposto><ICMS><ICMS51><vICMSOp>"+CRLF
	cRet += "<imposto><ICMS><ICMS51><pDif>"+CRLF
	cRet += "<imposto><ICMS><ICMS51><vlICMSDif>"+CRLF
	cRet += "<imposto><ICMS><ICMS51><vlICMS>"+CRLF

	cRet += "<imposto><ICMS><ICMS60><orig>"+CRLF
	cRet += "<imposto><ICMS><ICMS60><CST>"+CRLF
	cRet += "<imposto><ICMS><ICMS60><vBCSTRet>"+CRLF
	cRet += "<imposto><ICMS><ICMS60><vICMSSTRet>"+CRLF

	cRet += "<imposto><ICMS><ICMS70><orig>"+CRLF
	cRet += "<imposto><ICMS><ICMS70><CST>"+CRLF
	cRet += "<imposto><ICMS><ICMS70><modBC>"+CRLF
	cRet += "<imposto><ICMS><ICMS70><pRedBC>"+CRLF
	cRet += "<imposto><ICMS><ICMS70><vBC>"+CRLF
	cRet += "<imposto><ICMS><ICMS70><pICMS>"+CRLF
	cRet += "<imposto><ICMS><ICMS70><vICMS>"+CRLF
	cRet += "<imposto><ICMS><ICMS70><modBCST>"+CRLF
	cRet += "<imposto><ICMS><ICMS70><pMVAST>"+CRLF
	cRet += "<imposto><ICMS><ICMS70><pRedBCST>"+CRLF
	cRet += "<imposto><ICMS><ICMS70><vBCST>"+CRLF
	cRet += "<imposto><ICMS><ICMS70><pICMSST>"+CRLF
	cRet += "<imposto><ICMS><ICMS70><vICMSST>"+CRLF
	cRet += "<imposto><ICMS><ICMS70><vICMSDeson>"+CRLF
	cRet += "<imposto><ICMS><ICMS70><motDesICMS>"+CRLF

	cRet += "<imposto><ICMS><ICMS90><orig>"+CRLF
	cRet += "<imposto><ICMS><ICMS90><CST>"+CRLF
	cRet += "<imposto><ICMS><ICMS90><modBC>"+CRLF
	cRet += "<imposto><ICMS><ICMS90><vBC>"+CRLF
	cRet += "<imposto><ICMS><ICMS90><pRedBC>"+CRLF
	cRet += "<imposto><ICMS><ICMS90><pICMS>"+CRLF
	cRet += "<imposto><ICMS><ICMS90><vICMS>"+CRLF
	cRet += "<imposto><ICMS><ICMS90><modBCST>"+CRLF
	cRet += "<imposto><ICMS><ICMS90><pMVAST>"+CRLF
	cRet += "<imposto><ICMS><ICMS90><pRedBCST>"+CRLF
	cRet += "<imposto><ICMS><ICMS90><vBCST>"+CRLF
	cRet += "<imposto><ICMS><ICMS90><pICMSST>"+CRLF
	cRet += "<imposto><ICMS><ICMS90><vICMSST>"+CRLF
	cRet += "<imposto><ICMS><ICMS90><vICMSDeson>"+CRLF
	cRet += "<imposto><ICMS><ICMS90><motDesICMS>"+CRLF

	cRet += "<imposto><ICMS><ICMSPART><orig>"+CRLF
	cRet += "<imposto><ICMS><ICMSPART><CST>"+CRLF
	cRet += "<imposto><ICMS><ICMSPART><modBC>"+CRLF
	cRet += "<imposto><ICMS><ICMSPART><vBC>"+CRLF
	cRet += "<imposto><ICMS><ICMSPART><pRedBC>"+CRLF
	cRet += "<imposto><ICMS><ICMSPART><pICMS>"+CRLF
	cRet += "<imposto><ICMS><ICMSPART><vICMS>"+CRLF
	cRet += "<imposto><ICMS><ICMSPART><modBCST>"+CRLF
	cRet += "<imposto><ICMS><ICMSPART><pMVAST>"+CRLF
	cRet += "<imposto><ICMS><ICMSPART><pRedBCST>"+CRLF
	cRet += "<imposto><ICMS><ICMSPART><vBCST>"+CRLF
	cRet += "<imposto><ICMS><ICMSPART><pICMSST>"+CRLF
	cRet += "<imposto><ICMS><ICMSPART><vICMSST>"+CRLF
	cRet += "<imposto><ICMS><ICMSPART><pBCOp>"+CRLF
	cRet += "<imposto><ICMS><ICMSPART><UFST>"+CRLF

	cRet += "<imposto><ICMS><ICMSST><orig>"+CRLF
	cRet += "<imposto><ICMS><ICMSST><CST>"+CRLF
	cRet += "<imposto><ICMS><ICMSST><vBCSTRet>"+CRLF
	cRet += "<imposto><ICMS><ICMSST><vICMSSTRet>"+CRLF
	cRet += "<imposto><ICMS><ICMSST><vBCSTDest>"+CRLF
	cRet += "<imposto><ICMS><ICMSST><vICMSSTDest>"+CRLF

	cRet += "<imposto><ICMS><ICMSSN101><orig>"+CRLF
	cRet += "<imposto><ICMS><ICMSSN101><CSOSN>"+CRLF
	cRet += "<imposto><ICMS><ICMSSN101><pCredSN>"+CRLF
	cRet += "<imposto><ICMS><ICMSSN101><vCredICMSSN>"+CRLF

	cRet += "<imposto><ICMS><ICMSSN102><orig>"+CRLF
	cRet += "<imposto><ICMS><ICMSSN102><CSOSN>"+CRLF

	cRet += "<imposto><ICMS><ICMSSN201><orig>"+CRLF
	cRet += "<imposto><ICMS><ICMSSN201><CSOSN>"+CRLF
	cRet += "<imposto><ICMS><ICMSSN201><modBCST>"+CRLF
	cRet += "<imposto><ICMS><ICMSSN201><pMVAST>"+CRLF
	cRet += "<imposto><ICMS><ICMSSN201><pRedBCST>"+CRLF
	cRet += "<imposto><ICMS><ICMSSN201><vBCST>"+CRLF
	cRet += "<imposto><ICMS><ICMSSN201><pICMSST>"+CRLF
	cRet += "<imposto><ICMS><ICMSSN201><vICMSST>"+CRLF
	cRet += "<imposto><ICMS><ICMSSN201><pCredSN>"+CRLF
	cRet += "<imposto><ICMS><ICMSSN201><vCredICMSSN>"+CRLF

	cRet += "<imposto><ICMS><ICMSSN202><orig>"+CRLF
	cRet += "<imposto><ICMS><ICMSSN202><CSOSN>"+CRLF
	cRet += "<imposto><ICMS><ICMSSN202><modBCST>"+CRLF
	cRet += "<imposto><ICMS><ICMSSN202><pMVAST>"+CRLF
	cRet += "<imposto><ICMS><ICMSSN202><pRedBCST>"+CRLF
	cRet += "<imposto><ICMS><ICMSSN202><vBCST>"+CRLF
	cRet += "<imposto><ICMS><ICMSSN202><pICMSST>"+CRLF
	cRet += "<imposto><ICMS><ICMSSN202><vICMSST>"+CRLF

	cRet += "<imposto><ICMS><ICMSSN500><orig>"+CRLF
	cRet += "<imposto><ICMS><ICMSSN500><CSOSN>"+CRLF
	cRet += "<imposto><ICMS><ICMSSN500><vBCSTRet>"+CRLF
	cRet += "<imposto><ICMS><ICMSSN500><vICMSSTRet>"+CRLF

	cRet += "<imposto><ICMS><ICMSSN900><orig>"+CRLF
	cRet += "<imposto><ICMS><ICMSSN900><CSOSN>"+CRLF
	cRet += "<imposto><ICMS><ICMSSN900><modBC>"+CRLF
	cRet += "<imposto><ICMS><ICMSSN900><vBC>"+CRLF
	cRet += "<imposto><ICMS><ICMSSN900><pRedBC>"+CRLF
	cRet += "<imposto><ICMS><ICMSSN900><pICMS>"+CRLF
	cRet += "<imposto><ICMS><ICMSSN900><vICMS>"+CRLF
	cRet += "<imposto><ICMS><ICMSSN900><modBCST>"+CRLF
	cRet += "<imposto><ICMS><ICMSSN900><pMVAST>"+CRLF
	cRet += "<imposto><ICMS><ICMSSN900><pRedBCST>"+CRLF
	cRet += "<imposto><ICMS><ICMSSN900><vBCST>"+CRLF
	cRet += "<imposto><ICMS><ICMSSN900><pICMSST>"+CRLF
	cRet += "<imposto><ICMS><ICMSSN900><vICMSST>"+CRLF
	cRet += "<imposto><ICMS><ICMSSN900><pCredSN>"+CRLF
	cRet += "<imposto><ICMS><ICMSSN900><vCredICMSSN>"+CRLF

	cRet += "<imposto><IPI><clEnq>"+CRLF
	cRet += "<imposto><IPI><CNPJProd>"+CRLF
	cRet += "<imposto><IPI><cSelo>"+CRLF
	cRet += "<imposto><IPI><qSelo>"+CRLF
	cRet += "<imposto><IPI><cEnq>"+CRLF

	cRet += "<imposto><IPI><IPITrib><CST>"+CRLF
	cRet += "<imposto><IPI><IPITrib><vBC>"+CRLF
	cRet += "<imposto><IPI><IPITrib><pIPI>"+CRLF
	cRet += "<imposto><IPI><IPITrib><qUnid>"+CRLF
	cRet += "<imposto><IPI><IPITrib><vUnid>"+CRLF
	cRet += "<imposto><IPI><IPITrib><vIPI>"+CRLF

	cRet += "<imposto><IPI><IPINT><CST>"+CRLF

	cRet += "<imposto><PIS><PISAliq><CST>"+CRLF
	cRet += "<imposto><PIS><PISAliq><vBC>"+CRLF
	cRet += "<imposto><PIS><PISAliq><pPIS>"+CRLF
	cRet += "<imposto><PIS><PISAliq><vPIS>"+CRLF

	cRet += "<imposto><PIS><PISQtde><CST>"+CRLF
	cRet += "<imposto><PIS><PISQtde><qBCProd>"+CRLF
	cRet += "<imposto><PIS><PISQtde><vAliqProd>"+CRLF
	cRet += "<imposto><PIS><PISQtde><vPIS>"+CRLF

	cRet += "<imposto><PIS><PISNT><CST>"+CRLF

	cRet += "<imposto><PIS><PISOutr><CST>"+CRLF
	cRet += "<imposto><PIS><PISOutr><vBC>"+CRLF
	cRet += "<imposto><PIS><PISOutr><pPIS>"+CRLF
	cRet += "<imposto><PIS><PISOutr><qBCProd>"+CRLF
	cRet += "<imposto><PIS><PISOutr><vAliqProd>"+CRLF
	cRet += "<imposto><PIS><PISOutr><vPIS>"+CRLF

	cRet += "<imposto><PISST><vBC>"+CRLF
	cRet += "<imposto><PISST><pPIS>"+CRLF
	cRet += "<imposto><PISST><qBCProd>"+CRLF
	cRet += "<imposto><PISST><vAliqProd>"+CRLF
	cRet += "<imposto><PISST><vPIS>"+CRLF

	cRet += "<imposto><COFINS><COFINSAliq><CST>"+CRLF
	cRet += "<imposto><COFINS><COFINSAliq><vBC>"+CRLF
	cRet += "<imposto><COFINS><COFINSAliq><pCOFINS>"+CRLF
	cRet += "<imposto><COFINS><COFINSAliq><vCOFINS>"+CRLF

	cRet += "<imposto><COFINS><COFINSQtde><CST>"+CRLF
	cRet += "<imposto><COFINS><COFINSQtde><qBCProd>"+CRLF
	cRet += "<imposto><COFINS><COFINSQtde><vAliqProd>"+CRLF
	cRet += "<imposto><COFINS><COFINSQtde><vCOFINS>"+CRLF

	cRet += "<imposto><COFINS><COFINSNT><CST>"+CRLF

	cRet += "<imposto><COFINS><COFINSOutr><CST>"+CRLF
	cRet += "<imposto><COFINS><COFINSOutr><vBC>"+CRLF
	cRet += "<imposto><COFINS><COFINSOutr><pCOFINS>"+CRLF
	cRet += "<imposto><COFINS><COFINSOutr><qBCProd>"+CRLF
	cRet += "<imposto><COFINS><COFINSOutr><vAliqProd>"+CRLF
	cRet += "<imposto><COFINS><COFINSOutr><vCOFINS>"+CRLF

	cRet += "<imposto><COFINS><COFINSST><vBC>"+CRLF
	cRet += "<imposto><COFINS><COFINSST><pCOFINS>"+CRLF
	cRet += "<imposto><COFINS><COFINSST><qBCProd>"+CRLF
	cRet += "<imposto><COFINS><COFINSST><vAliqProd>"+CRLF
	cRet += "<imposto><COFINS><COFINSST><vCOFINS>"+CRLF

	cRet += "<imposto><COFINS><ISSQN><vBC>"+CRLF
	cRet += "<imposto><COFINS><ISSQN><vAliq>"+CRLF
	cRet += "<imposto><COFINS><ISSQN><vISSQN>"+CRLF
	cRet += "<imposto><COFINS><ISSQN><cMunFG>"+CRLF
	cRet += "<imposto><COFINS><ISSQN><cListServ>"+CRLF
	cRet += "<imposto><COFINS><ISSQN><vDeducao>"+CRLF
	cRet += "<imposto><COFINS><ISSQN><vOutro>"+CRLF
	cRet += "<imposto><COFINS><ISSQN><vDescIncond>"+CRLF
	cRet += "<imposto><COFINS><ISSQN><vDescCond>"+CRLF
	cRet += "<imposto><COFINS><ISSQN><vISSRet>"+CRLF
	cRet += "<imposto><COFINS><ISSQN><indISS>"+CRLF
	cRet += "<imposto><COFINS><ISSQN><cServico>"+CRLF
	cRet += "<imposto><COFINS><ISSQN><cMun>"+CRLF
	cRet += "<imposto><COFINS><ISSQN><cPais>"+CRLF
	cRet += "<imposto><COFINS><ISSQN><nProcesso>"+CRLF
	cRet += "<imposto><COFINS><ISSQN><indIncentivo>"+CRLF

	cRet += "<imposto><impostoDevol>"+CRLF
	cRet += "<imposto><pDevol>"+CRLF
	cRet += "<imposto><IPI>"+CRLF
	cRet += "<imposto><vIPIDevol>"+CRLF

	cRet += "<infAdProd>"+CRLF

cRet += "{}<NfeProc><Nfe><InfNfe></det>"+CRLF //Finais dos itens

cRet += "<NfeProc><Nfe><InfNfe><total><ICMSTot><vBC>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><total><ICMSTot><vICMS>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><total><ICMSTot><vICMSDeson>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><total><ICMSTot><vBCST>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><total><ICMSTot><vST>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><total><ICMSTot><vProd>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><total><ICMSTot><vFrete>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><total><ICMSTot><vSeg>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><total><ICMSTot><vDesc>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><total><ICMSTot><vII>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><total><ICMSTot><vIPI>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><total><ICMSTot><vPIS>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><total><ICMSTot><vCOFINS>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><total><ICMSTot><vOutro>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><total><ICMSTot><vNF>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><total><ICMSTot><vTotTrib>"+CRLF

cRet += "<NfeProc><Nfe><InfNfe><total><ISSQNtot><vServ>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><total><ISSQNtot><vBC>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><total><ISSQNtot><vISS>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><total><ISSQNtot><vPIS>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><total><ISSQNtot><vCOFINS>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><total><ISSQNtot><dCompet>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><total><ISSQNtot><vDeducao>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><total><ISSQNtot><vOutro>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><total><ISSQNtot><vDescIncond>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><total><ISSQNtot><vDescCond>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><total><ISSQNtot><vISSRet>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><total><ISSQNtot><cRegTrib>"+CRLF

cRet += "<NfeProc><Nfe><InfNfe><total><retTrib><vRetPIS>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><total><retTrib><vRetCOFINS>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><total><retTrib><vRetCSLL>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><total><retTrib><vBCIRRF>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><total><retTrib><vIRRF>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><total><retTrib><vBCRetPrev>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><total><retTrib><vRetPrev>"+CRLF

cRet += "<NfeProc><Nfe><InfNfe><transp><modFrete>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><transp><transporta><CNPJ>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><transp><transporta><CPF>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><transp><transporta><xNome>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><transp><transporta><IE>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><transp><transporta><xEnder>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><transp><transporta><xMun>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><transp><transporta><UF>"+CRLF

cRet += "<NfeProc><Nfe><InfNfe><transp><transporta><retTransp><vServ>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><transp><transporta><retTransp><vBCRet>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><transp><transporta><retTransp><pICMSRet>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><transp><transporta><retTransp><vICMSRet>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><transp><transporta><retTransp><CFOP>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><transp><transporta><retTransp><cMunFG>"+CRLF

cRet += "<NfeProc><Nfe><InfNfe><transp><transporta><veicTransp><placa>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><transp><transporta><veicTransp><UF>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><transp><transporta><veicTransp><RNTC>"+CRLF

cRet += "<NfeProc><Nfe><InfNfe><transp><transporta><reboque><placa>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><transp><transporta><reboque><UF>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><transp><transporta><reboque><RNTC>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><transp><transporta><reboque><vagao>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><transp><transporta><reboque><balsa>"+CRLF

cRet += "<NfeProc><Nfe><InfNfe><transp><transporta><vol>qVol>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><transp><transporta><vol><esp>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><transp><transporta><vol><marca>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><transp><transporta><vol><nVol>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><transp><transporta><vol><pesoL>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><transp><transporta><vol><pesoB>"+CRLF

cRet += "<NfeProc><Nfe><InfNfe><transp><transporta><lacres><nLacre>"+CRLF

cRet += "{}<NfeProc><Nfe><InfNfe><transp><vol>"+CRLF     //inicio itens de volume
	cRet += "<qVol>"+CRLF
	cRet += "<esp>"+CRLF
	cRet += "<marca>"+CRLF
	cRet += "<nVol>"+CRLF
	cRet += "<pesoL>"+CRLF
	cRet += "<pesoB>"+CRLF
cRet += "{}<NfeProc><Nfe><InfNfe><transp></vol>"+CRLF    //fim itens de volume

cRet += "{}<NfeProc><Nfe><InfNfe><transp><lacres>"+CRLF     //inicio itens de lacres
	cRet += "<nLacre>"+CRLF
cRet += "{}<NfeProc><Nfe><InfNfe><transp></lacres>"+CRLF    //fim itens de lacres

cRet += "<NfeProc><Nfe><InfNfe><cobr><fat><nFat>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><cobr><fat><vOrig>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><cobr><fat><vDesc>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><cobr><fat><vLiq>"+CRLF

cRet += "{}<NfeProc><Nfe><InfNfe><dup>"+CRLF     //inicio itens de Duplicatisw
	cRet += "<nDup>"+CRLF
	cRet += "<dVenc>"+CRLF
	cRet += "<vDup>"+CRLF
cRet += "{}<NfeProc><Nfe><InfNfe></dup>"+CRLF    //fim itens de Duplicatisw

cRet += "<NfeProc><Nfe><InfNfe><infAdic><infAdFisco>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><infAdic><infCpl>"+CRLF

cRet += "<NfeProc><Nfe><InfNfe><infAdic><obsCont><xCampo>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><infAdic><obsCont><xTexto>"+CRLF

cRet += "<NfeProc><Nfe><InfNfe><infAdic><obsFisco><xCampo>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><infAdic><obsFisco><xTexto>"+CRLF

cRet += "<NfeProc><Nfe><InfNfe><infAdic><procRef><nProc>"+CRLF
cRet += "<NfeProc><Nfe><InfNfe><infAdic><procRef><indProc>"+CRLF

Return(cRet)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Empresa   ³ HF Consulting                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ´±±
±±³Funcao    ³U_MANIFXML ³ Autor ³ Eneovaldo Roveri Jr                  ³ Data ³ 28/11/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Manifestação automática ao gerar a prénotis                                ³±±
±±³          ³ 																			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Obs.      ³ 																			  ³±±
±±³          ³ 																			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ U_MANIFXML( cChave, lShow, cOri )                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cChave: chave                                                              ³±±
±±³          ³ lShow : EWxiberi mensagens                                                 ³±±
±±³          ³ cOri  : Origem 1-email 2 download                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³             ATUALIZACOES SOFRIDAS DESDE CONSTRUCAO                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Data      ³ Programador      ³ Manutencao efetuada                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  /  /    ³                  ³                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Importa  XML                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function MANIFXML( cChave, lShow, cOri )

Local aArea    := GetArea()
Local cRet     := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MANIF")))
Local nRet     := 0
//Local cEve := ""
Local cRej     := ""
Local cManPre  := GetNewPar("XM_MANPRE","N")
Local cClToken :=	alltrim(GetNewPar("XM_CLTOKEN",Space(256)))
Local cCloud   :=	alltrim(GetNewPar("XM_CLOUD" ,"0"))         //aCombo (0=Desbilitado 1=Habilitado) 
Local aHeader  :=   {}
Local cUrl     := ""
Local cCnpj    := ""
Local cXmlRet  := ""
Local cError   := ""
Local cWarning := ""
Local cEve     := "210200"

Default lShow   := .T.

Private cMsgTag := ""
Private oXmlRet

//FR - 22/07/2021 - #10981 - Sideral
//o conteúdo do campo ZBZ_MANIF pode ser:
//0=Não;1=Conf.Oper.;2=Oper.Desconh.;3=Oper.Não Realiz.;4=Ciência;5=MCTe;W=Pend.Conf.;X=Pend.Desc.;Y=Pend.N.Realiz;Z=Pend.Ciência
//Porém, este campo foi descontinuado para a rotina de manifestação, o correto é utilizar a tabela de eventos (ZBE)
//FR - 22/07/2021 - #10981 - Sideral

//Faz a Manifestação pelo Gestão da Nuvem - Rogério Lino dia 20/05/2022
If cCloud == "1" .and. cModelo == "55"

	cUrl 	:= "https://cloud.importaxml.com.br"
	cCnpj 	:= Alltrim(FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , { "M0_CGC" } )[1][2])

	Aadd(aHeader, "Content-Type: application/xml")                      
	Aadd(aHeader, "Connection: keep-alive")   

	oRest 	:= FWRest():New(cUrl)

	oRest:SetPath("/api/NFeManifestar?token="+cClToken+"&Chave="+cChave+"&tpEvento="+cEve)  		

	oRest:Get(aHeader) 

	If oRest:GetResult() <> Nil 
	
		cXmlRet := oRest:GetResult()

		//Se nao for rejeição trata
		if At("Rejeicao: ",cXmlRet) == 0

			cXmlRet := strTran(cXmlRet,substr(cXmlRet,at("<infEvento",cXmlRet),77),'<infEvento>')

		endif

		cXmlRet := strTran(cXmlRet,'<retEnvEvento versao=\"1.00\" xmlns=\"http://www.portalfiscal.inf.br/nfe\">','<retEnvEvento>')
		cXmlRet := strTran(cXmlRet,'<retEvento versao=\"1.00\">','<retEvento>')
		cXmlRet := strTran(cXmlRet,'"','')

		oXmlRet := XmlParser( cXmlRet ,"_",@cError, @cWarning )

		If ( oXmlRet == NIL )

			oRest := NIL								
			FreeObj(oRest)
  			Conout("Falha ao gerar Objeto XML : "+cError+" / "+cWarning)
  			Return cRet

		Endif

		cChave  := oXmlRet:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_CHNFE:TEXT
		cEve    := oXmlRet:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_TPEVENTO:TEXT

		//VERIFICA SE EXISTE A NOTA BAIXADA PARA PODER AMARRAR O EVENTO
		DbSelectArea(xZBZ)
		( xZBZ )->( DbSetOrder( 3 ) )
		lAchou  := (xZBZ)->(DbSeek(alltrim(cChave)))

		if lAchou

			cChave := PadR(cChave,TamSX3(xZBE_+"CHAVE")[1],Nil)
			cEve := PadR(cEve,TamSX3("B2_COD")[1],Nil)

			DbSelectArea(xZBE)
			DbSetOrder(1)
			if !DbSeek(xFilial(xZBE)+cChave+alltrim(cEve))
								
				//cVersao := oXmlRet:_RETCONSSITNFE:_VERSAO:TEXT
				cStatus := U_getSitConf(cEve)  //oXmlRet:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_CSTAT:TEXT
				cTpAmb  := oXmlRet:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_TPAMB:TEXT
				cDes    := oXmlRet:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_XEVENTO:TEXT
				cxMotivo:= oXmlRet:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_XMOTIVO:TEXT

				cDes := ALLTRIM(cxMotivo) +" - " + ALLTRIM(CDes)

				cDTTime := U_FRDTHora(1,dDatabase, Time(),"")

				If Type( "oXmlRet:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_NPROT:TEXT" ) <> "U"
					cProtC := oXmlRet:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_NPROT:TEXT
				else
					cProtc := ""
				EndIF

				If Type( "oXmlRet:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_NSEQEVENTO:TEXT" ) <> "U"
					cSeqEve := oXmlRet:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_NSEQEVENTO:TEXT
				else
					cSeqEve := "01"
				EndIf

				If len(cSeqEve)<=len( (xZBE)->(FieldGet(FieldPos(xZBE_+"SEQEVE"))) )
					cSeqEve := StrZero( Val(cSeqEve), len( (xZBE)->(FieldGet(FieldPos(xZBE_+"SEQEVE"))) ), 0 )
				Endif

				dDhAut  := ctod( "" )

				If Type( "oXmlRet:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_DHREGEVENTO:TEXT" ) <> "U"
					cDthRet := oXmlRet:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_DHREGEVENTO:TEXT
					dDhAut  := StoD(substr(cDthRet,1,4)+Substr(cDthRet,6,2)+Substr(cDthRet,9,2))
				EndIf

				Reclock(xZBE,.T.)

				(xZBE)->(FieldPut(FieldPos(xZBE_+"CHAVE") , cChave     )) //cKey+cEvento+cSeqEve
				(xZBE)->(FieldPut(FieldPos(xZBE_+"FILIAL"), xFilial(xZBE)   ))
				//(xZBE)->(FieldPut(FieldPos(xZBE_+"XML") , cXml      )) //cKey+cEvento+cSeqEve
				(xZBE)->(FieldPut(FieldPos(xZBE_+"TPEVE") , cEve   ))
				(xZBE)->(FieldPut(FieldPos(xZBE_+"DESC") , CDes   ))
				(xZBE)->(FieldPut(FieldPos(xZBE_+"SEQEVE"), cSeqEve   ))
				(xZBE)->(FieldPut(FieldPos(xZBE_+"DTHRGR"), cDTTime   ))
				(xZBE)->(FieldPut(FieldPos(xZBE_+"PROT"), cProtc   ))
				(xZBE)->(FieldPut(FieldPos(xZBE_+"STATUS"), cStatus ))
				(xZBE)->(FieldPut(FieldPos(xZBE_+"DHAUT"), dDhAut ))
				(xZBE)->(FieldPut(FieldPos(xZBE_+"DTRECB"), ddatabase ))
				(xZBE)->(FieldPut(FieldPos(xZBE_+"EVENTO"), cXMotivo ))

				(xZBE)->(MsUnLock())

			endif

		endif

	Endif 

	oRest := NIL								
	FreeObj(oRest)

else
 
If cManPre <> "N" .and. (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO"))) == "55" //.and. empty( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MANIF"))) )
	
	if cManPre $ "1,3" //.And. !(xZBZ)->(FieldGet(FieldPos(xZBZ_+"MANIF"))) $ "1,3"
		//FR - 22/07/2021 - #10981 - Sideral - pesquisa se já existe o evento de confirmação da operação, se não existir, manifesta confirmação
		(xZBE)->(OrdSetFocus(1))
			If !(xZBE)->(Dbseek(xFilial(xZBE) + cChave + cEve ))
				nRet := HFMFXml( cChave, cEve , @cRej )
		Endif
		//FR - 22/07/2021 - #10981 - Sideral

	Elseif cManPre == "2" //.And. (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MANIF"))) <> "4"

		//FR - 22/07/2021 - #10981 - Sideral - pesquisa se já existe o evento de ciência da operação, se não existir, manifesta ciência
		(xZBE)->(OrdSetFocus(1))
		If !(xZBE)->(Dbseek(xFilial(xZBE) + cChave + "210210"))
			nRet := HFMFXml( cChave, "210210", @cRej )
		Endif 
		//FR - 22/07/2021 - #10981 - Sideral
		
	Else

		nRet := -9

	EndIf

	if nRet >= 0

		cRet := iif( cManPre == "2", "4", cManPre )

	elseif nRet <> -9 

		if cRej == "573"  //aqui já foi manifestado com o mesmo evento

			cRet := iif( cManPre == "2", "4", cManPre )

		Else

			if cManPre $ "1,3"

				cRet := "W"   //Erro na Manifestação, Aguardando Manifestação Conf.Oper.

			else

				cRet := "Z"   //Erro na Manifestação, Aguardando Manifestação Ciência

			endif

			If !IsInCallStack("U_HFXML022") //FR - 31/05/2022 - PETRA - se a chamada não vier do multiplos nfe / cte pode mostrar a msg senão fica mostrando a cada nota
				if lShow
	
			    	U_MyAviso("Aviso","Não foi possivel Manifestar."+CRLF+cMsgTag,{"OK"},3)
	
		 		endif
	 		Endif 

		endif

	endif

EndIf

endif

if cRej = "573" .And. !Empty(cRet) 

	//fica com o cRet que ja esta

Else

	//if Empty( cRet ) .Or. cRet == "0"  //Ver o que Tem na ZBS
	cRet := U_HFMANZBS( cChave, cRet, cOri )

Endif

RestArea(aArea)

Return( cRet )


User Function HFMANZBS( cChave, xMan, cOri )

Local aArea := GetArea()
Local cRet  := "0"
Local cManZBS := " "
Local cModel  := Substr(cChave,21,2)

Default xMan := "0"
Default cOri := "1"

if !Empty(xMan) .And. xMan <> "0"
	cRet := xMan
endif

(xZBE)->( dbSetOrder( 1 ) )
if (xZBE)->( dbSeek( xFilial(xZBE) + cChave ) )

	//0=Não;1=Conf.Oper.;2=Oper.Desconh.;3=Oper.Não Realiz.;4=Ciência;5=MCTe;W=Pend.Conf.;X=Pend.Desc.;Y=Pend.N.Realiz;Z=Pend.Ciência;6=Sim 
	Do While !(xZBE)->( Eof() ) .And. (xZBE)->(FieldGet(FieldPos(xZBE_+"FILIAL"))) == xFilial(xZBE) .And. (xZBE)->(FieldGet(FieldPos(xZBE_+"CHAVE"))) = cChave
			
			if (xZBE)->(FieldGet(FieldPos(xZBE_+"TPEVE"))) == "210200"   //210200 – Confirmada a Operação;

				if cRet <= "1" .or. cRet == "4"
					cRet := "1"
				endif

			ElseIF (xZBE)->(FieldGet(FieldPos(xZBE_+"TPEVE"))) == "210210"   //210210 – Ciência da Operação;

				if cRet <= "0"
					cRet := "4"
				Endif

			ElseIF (xZBE)->(FieldGet(FieldPos(xZBE_+"TPEVE"))) == "210220"    //210220 – Desconhecida;

				cRet := "2"

			ElseIF (xZBE)->(FieldGet(FieldPos(xZBE_+"TPEVE"))) == "210240"    //210240 – Operação não Realizada

				cRet := "3"

			Endif

			(xZBE)->( dbSkip() )

	EndDo

EndIf

(xZBS)->( dbSetOrder( 3 ) )  //Com o DFe esse campo não vem mais, Agora Laskou
if (xZBS)->( dbSeek( cChave ) )

	cManZBS := (xZBS)->(FieldGet(FieldPos(xZBS_+"CSITCO")))

	if ( Empty(cManZBS) .or. cManZBS == "0" ) .And. cModel = "55" //Se existe ZBS, pelo menos tem ciência.
		
		cManZBS := "4"

	endif

endif

If ! Empty( cManZBS )

	if cRet == "4" .And. cManZBS < "4" .And. cManZBS > "0"

		cRet := cManZBS

	Elseif cRet <= "0"

		cRet := cManZBS

	Elseif cManZBS != "4"

		if cManZBS > cRet

			cRet := cManZBS

		endif

	endif

EndIF

If cRet <= "0" .And. cOri == "2"

	if cModel = "55"  //Só vale para NF-e

		cRet := "4"

	Endif

Endif

IF cModel = "57"  //Cte não manifesta

	cRet := "0"

Endif

RestArea( aArea )

Return( cRet )





User Function H20VisuPC(nRecSC7)

Local aArea			:= GetArea()
Local aAreaSC7		:= SC7->(GetArea())
Local nSavNF		:= MaFisSave()
Local cSavCadastro	:= cCadastro
Local cFilBak		:= cFilAnt
Local nBack       	:= n
Local aCroneRot     := aClone(aRotina)
PRIVATE nTipoPed	:= 1
PRIVATE cCadastro	:= OemToAnsi("Consulta ao Pedido de Compra") //STR0066
PRIVATE l120Auto	:= .F.
PRIVATE l123Auto	:= .F.
PRIVATE aBackSC7	:= {}  //Sera utilizada na visualizacao do pedido - MATA120
Private aRotina     := {}
	aAdd(aRotina,{"Pesquisar","PesqBrw"   , 0, 1, 0, .F. }) //"Pesquisar"
	aAdd(aRotina,{"Visualizar","A120Pedido", 0, 2, 0, Nil }) //"Visualizar"
	aAdd(aRotina,{"Incluir","A120Pedido", 0, 3, 0, Nil }) //"Incluir"
	aAdd(aRotina,{"Alterar","A120Pedido", 0, 4, 6, Nil }) //"Alterar"
	aAdd(aRotina,{"Excluir","A120Pedido", 0, 5, 7, Nil }) //"Excluir"
	aAdd(aRotina,{"Copia","A120Copia" , 0, 4, 0, Nil }) //"Copia"
	aAdd(aRotina,{"Imprimir","A120Impri" , 0, 2, 0, Nil }) //"Imprimir"
	aAdd(aRotina,{"Legenda","A120Legend", 0, 1, 0, .F. }) //"Legenda"
	aAdd(aRotina,{"Conhecimento","MsDocument", 0, 4, 0, Nil }) //"Conhecimento"	

MaFisEnd()

DbSelectArea("SC7")
MsGoto(nRecSC7)

cFilAnt := IIf(!Empty(SC7->C7_FILIAL),SC7->C7_FILIAL,cFilAnt)

If SC7->C7_TIPO <> 3
	A120Pedido(Alias(),RecNo(),2)
Else
    nTipoPed := 3  
	A123Pedido(Alias(),RecNo(),2)
EndIf

cFilant := cFilBak

n := nBack
cCadastro	:= cSavCadastro
aRotina     := aClone(aCroneRot)
MaFisRestore(nSavNF)
RestArea(aAreaSC7)
RestArea(aArea)

Return .T.


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Empresa   ³ HF Consulting                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ´±±
±±³Funcao    ³ HFMANCHV  ³ Autor ³ Eneovaldo Roveri Jr                  ³ Data ³ 07/05/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Manifestação da chave.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Obs.      ³ Manifestação da chave pela tela principal, irá atualizar o campo ZBZ_MANIF ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ U_HFMANCHV()                                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³             ATUALIZACOES SOFRIDAS DESDE CONSTRUCAO                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Data      ³ Programador      ³ Manutencao efetuada                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  /  /    ³                  ³                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Importa XML                                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function HFMANCHV(cTab,nReg,nMod,nQual,cJust,nRep) //GETESB2

Local aArea  := GetArea()
Local cChave := AllTrim( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))) )
Local cModel := AllTrim( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO"))) )
Local nRet   := 0
Local nEve   := 0
Local cEve   := ""
Local cRej   := ""
//Local cJust  := " " Em 24/3
Local nTotTent:= GetNewPar("XM_TENTSEND", 5 )   //FR - 04/09/2020
Local nTent   := 0           
Local cClToken :=	alltrim(GetNewPar("XM_CLTOKEN",Space(256)))
Local cCloud   :=	alltrim(GetNewPar("XM_CLOUD" ,"0"))         //aCombo (0=Desbilitado 1=Habilitado) 
Local aHeader  :=   {}
Local cUrl     := ""
Local cCnpj    := ""
Local cXmlRet  := ""
Local cError   := ""
Local cWarning := ""
//FR - 03/06/2022 - TELETEX - ATUALIZAR NA ZBZ, ZBZ_MANIF O TIPO DA MANIFESTAÇÃO REALIZADA
Local aEventos := {}
Local xEventos := {}
Local xPos     := 0
Local xTipoManif := ""
//FR - 03/06/2022 - TELETEX - ATUALIZAR NA ZBZ, ZBZ_MANIF O TIPO DA MANIFESTAÇÃO REALIZADA

Default nQual := 0
Default cJust := " "
Default nRep  := 4

Private lShow := .T.
Private cMsgTag := ""
Private oXmlRet

//códigos de eventos
Aadd( aEventos , "110110" )   //0-carta correção
Aadd( aEventos , "210200" )   //1
Aadd( aEventos , "210220" )   //2
Aadd( aEventos , "210240" )   //3
Aadd( aEventos , "210210" )   //4
Aadd( aEventos , "110111" )   //5
Aadd( aEventos , "610110" )   //6

//codificação que grava no campo zbz_manif
Aadd( xEventos , "0"      )   //"110110"                                                        
Aadd( xEventos , "1"      )   //"210200"                                                        
Aadd( xEventos , "2"      )   //"210220"                                                         
Aadd( xEventos , "3"      )   //"210240"                                                        
Aadd( xEventos , "4"      )   //"210210"                                                        
Aadd( xEventos , "5"      )   //"110111"
Aadd( xEventos , "6"      )   //"610110" 
if nQual <> 0  //Para Manifestar com ciência automático conforme o parâmetro, o nQual vai vir 4 ou então ta zerado para seguir a rotina normal
	
	lShow := .F.
	nEve  := nQual

Else

	if cModel <> "55"
		U_MyAviso("Aviso","Modelo diferente de 55, não Manifesta."+cModel,{"OK"},3)
	Else
		nEve := U_TELMAN("Manifestação do Destinatário","Manifestação do Destinatário",{"Confirmação da operação","Desconhecimento da operação","Operação não Realizada","Ciência da operação"},3)
	Endif

Endif

if cModel <> "55"

	if (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MANIF"))) <> "0"
		DbSelectArea(xZBZ)
		Reclock(xZBZ,.F.)
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"MANIF"), "0" ))
		MsUnlock()
	endif

	RestArea(aArea)
	Return( NIL )

Endif

if nEve == 1
	cEve := "210200"
elseif nEve == 2
	cEve := "210220"
elseif nEve == 3
	cEve  := "210240"
	if Empty(cJust)
		cJust := space( 255 )
		cJust := U_TelaJust( cChave, cJust )  //GETESB2
		if cJust == "-1"
			Return( NIL )
		endif
		cJust := RetiraAcentos(AllTrim(cJust),.F.)  //+";"
	endif
elseif nEve == 4
	cEve := "210210"
else
	Return( NIL )
endif

//Faz a Manifestação pelo Gestão da Nuvem - Rogério Lino dia 20/05/2022
If cCloud == "1" .and. cModelo == "55"

	cUrl 	:= "https://cloud.importaxml.com.br"
	cCnpj 	:= Alltrim(FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , { "M0_CGC" } )[1][2])

	Aadd(aHeader, "Content-Type: application/xml")                      
	Aadd(aHeader, "Connection: keep-alive")   

	oRest 	:= FWRest():New(cUrl)

	oRest:SetPath("/api/NFeManifestar?token="+cClToken+"&Chave="+cChave+"&tpEvento="+cEve+"&Justificativa="+Escape(cJust))  		

	oRest:Get(aHeader) 

	If oRest:GetResult() <> Nil 
	
		cXmlRet := oRest:GetResult()

		//Se nao for rejeição trata
		if At("Rejeicao: ",cXmlRet) == 0

			cXmlRet := strTran(cXmlRet,substr(cXmlRet,at("<infEvento",cXmlRet),77),'<infEvento>')

		endif

		cXmlRet := strTran(cXmlRet,'<retEnvEvento versao=\"1.00\" xmlns=\"http://www.portalfiscal.inf.br/nfe\">','<retEnvEvento>')
		cXmlRet := strTran(cXmlRet,'<retEvento versao=\"1.00\">','<retEvento>')
		cXmlRet := strTran(cXmlRet,'"','')

		oXmlRet := XmlParser( cXmlRet ,"_",@cError, @cWarning )

		If ( oXmlRet == NIL )

			oRest := NIL								
			FreeObj(oRest)
  			MsgStop("Falha ao gerar Objeto XML : "+cError+" / "+cWarning)
  			Return

		Endif

		cChave  := oXmlRet:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_CHNFE:TEXT
		cEve    := oXmlRet:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_TPEVENTO:TEXT

		//VERIFICA SE EXISTE A NOTA BAIXADA PARA PODER AMARRAR O EVENTO
		DbSelectArea(xZBZ)
		( xZBZ )->( DbSetOrder( 3 ) )
		lAchou  := (xZBZ)->(DbSeek(alltrim(cChave)))

		if lAchou

			cChave := PadR(cChave,TamSX3(xZBE_+"CHAVE")[1],Nil)
			cEve := PadR(cEve,TamSX3("B2_COD")[1],Nil)

			DbSelectArea(xZBE)
			DbSetOrder(1)
			if !DbSeek(xFilial(xZBE)+cChave+alltrim(cEve))
								
				//cVersao := oXmlRet:_RETCONSSITNFE:_VERSAO:TEXT
				cStatus := U_getSitConf(cEve)  //oXmlRet:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_CSTAT:TEXT
				cTpAmb  := oXmlRet:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_TPAMB:TEXT
				cDes    := oXmlRet:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_XEVENTO:TEXT
				cxMotivo:= oXmlRet:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_XMOTIVO:TEXT

				cDes := ALLTRIM(cxMotivo) +" - " + ALLTRIM(CDes)

				cDTTime := U_FRDTHora(1,dDatabase, Time(),"")

				If Type( "oXmlRet:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_NPROT:TEXT" ) <> "U"
					cProtC := oXmlRet:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_NPROT:TEXT
				else
					cProtc := ""
				EndIF

				If Type( "oXmlRet:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_NSEQEVENTO:TEXT" ) <> "U"
					cSeqEve := oXmlRet:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_NSEQEVENTO:TEXT
				else
					cSeqEve := "01"
				EndIf

				If len(cSeqEve)<=len( (xZBE)->(FieldGet(FieldPos(xZBE_+"SEQEVE"))) )
					cSeqEve := StrZero( Val(cSeqEve), len( (xZBE)->(FieldGet(FieldPos(xZBE_+"SEQEVE"))) ), 0 )
				Endif

				dDhAut  := ctod( "" )

				If Type( "oXmlRet:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_DHREGEVENTO:TEXT" ) <> "U"
					cDthRet := oXmlRet:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_DHREGEVENTO:TEXT
					dDhAut  := StoD(substr(cDthRet,1,4)+Substr(cDthRet,6,2)+Substr(cDthRet,9,2))
				EndIf

				Reclock(xZBE,.T.)

				(xZBE)->(FieldPut(FieldPos(xZBE_+"CHAVE") , cChave     )) //cKey+cEvento+cSeqEve
				(xZBE)->(FieldPut(FieldPos(xZBE_+"FILIAL"), xFilial(xZBE)   ))
				(xZBE)->(FieldPut(FieldPos(xZBE_+"XML") , cXmlRet      )) //cKey+cEvento+cSeqEve
				(xZBE)->(FieldPut(FieldPos(xZBE_+"TPEVE") , cEve   ))
				(xZBE)->(FieldPut(FieldPos(xZBE_+"DESC") , CDes   ))
				(xZBE)->(FieldPut(FieldPos(xZBE_+"SEQEVE"), cSeqEve   ))
				(xZBE)->(FieldPut(FieldPos(xZBE_+"DTHRGR"), cDTTime   ))
				(xZBE)->(FieldPut(FieldPos(xZBE_+"PROT"), cProtc   ))
				(xZBE)->(FieldPut(FieldPos(xZBE_+"STATUS"), cStatus ))
				(xZBE)->(FieldPut(FieldPos(xZBE_+"DHAUT"), dDhAut ))
				(xZBE)->(FieldPut(FieldPos(xZBE_+"DTRECB"), ddatabase ))
				(xZBE)->(FieldPut(FieldPos(xZBE_+"EVENTO"), cXMotivo ))

				(xZBE)->(MsUnLock())

			endif

		endif

	Endif 

	oRest := NIL								
	FreeObj(oRest)

else

	//nRet := HFMFXml( cChave, cEve, @cRej, cJust, nRep )
	//HEVERTON - 10/09/2020
	While nRet <= 0 .And. nTent <= nTotTent

		nRet := HFMFXml( cChave, cEve, @cRej, cJust, nRep )

		nTent++

		Sleep(1500)

	End

endif

if nRet < 0

	if cRej == "573"  //aqui já foi manifestado com o mesmo evento
		nRet := 0
	else
		if nEve == 1
			cRej := "W"
		elseif nEve == 2
			cRej := "X"
		elseif nEve == 3
			cRej := "Y"
		elseif nEve == 4
			cRej := "Z"
		endif 
	endif

	if lShow  //Não mostar o aviso, apenas atualizar o bixo
		if nRet < 0
			//U_MyAviso("Aviso",cMsgTag,{"OK"},3)
			U_HFMntMon(cEve)
    	endif
	endif

Else

Endif

if nRet >= 0

	if lShow
    	//U_MyAviso("Aviso","Evento Realizado com Sucesso. "+cMsgTag,{"OK"},3)
		U_HFMntMon(cEve)
	endif

		DbSelectArea(xZBZ)
		/*Reclock(xZBZ,.F.)
			//(xZBZ)->(FieldPut(FieldPos(xZBZ_+"MANIF"), U_HFMANZBS( cChave, AllTrim(str(nEve)) ) ))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"MANIF"), "1" ))
		DbSelectArea(xZBZ)
		MsUnlock()*/
		//------------------------------------------------------------------------------------------------------//
		//FR - 03/06/2022 - TELETEX - MANIFESTAÇÃO REALIZADA - não é mais 1-Sim; 2-Não, as opçoes mudaram para: 
		//------------------------------------------------------------------------------------------------------//
		//0=Carta Correção;1=Conf. Op.;2=Desc.Op;3=Op.Não Realizada;4=Ciencia Op.;5=Cancelada;6=Desacordo                                  
		//------------------------------------------------------------------------------------------------------//                                              
		//grava o tipo do evento de acordo com cEve;
		//procura no array aEventos os eventos e pega a posição e associa com o array xEventos
		/*
		//códigos de eventos
		Aadd( aEventos , "110110" )   //0-carta correção
		Aadd( aEventos , "210200" )   //1-Confirmação operação
		Aadd( aEventos , "210220" )   //2-Desconhecimento da operação
		Aadd( aEventos , "210240" )   //3-Operação não realizada
		Aadd( aEventos , "210210" )   //4-Ciência da operação
		Aadd( aEventos , "110111" )   //5-Cancelada
		Aadd( aEventos , "610110" )   //6-Desacordo
		
		//codificação que grava no campo zbz_manif:  0,1,2,3,4,5,6
		Aadd( xEventos , "0"      )   //"110110"                                                        
		Aadd( xEventos , "1"      )   //"210200"                                                        
		Aadd( xEventos , "2"      )   //"210220"                                                         
		Aadd( xEventos , "3"      )   //"210240"                                                        
		Aadd( xEventos , "4"      )   //"210210"                                                        
		Aadd( xEventos , "5"      )   //"110111"
		Aadd( xEventos , "6"      )   //"610110" 
		*/
		xPos := Ascan(aEventos, cEve)
		If xPos > 0
			xTipoManif := xEventos[xPos]
		Else
			xTipoManif := "1"
		Endif 
		
		//se chegou aqui, é porque foi manifestado, então grava na ZBZ, Campo: ZBZ_MANIF
		(xZBZ)->(DbsetOrder(3))
		If (xZBZ)->(DbSeek(cChave))
			RecLock(xZBZ,.F.)
			//(xZBZ)->(FieldPut(FieldPos(xZBZ_+"MANIF"), "1" ))   
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"MANIF"), xTipoManif ))   
			(xZBZ)->(MsUnLock())
		EndIf
		//------------------------------------------------------------------------------------------------------//
		//FR - 03/06/2022 - TELETEX - MANIFESTAÇÃO REALIZADA - não é mais 1-Sim; 2-Não, as opçoes mudaram para:
		//0=Carta Correção;1=Conf. Op.;2=Desc.Op;3=Op.Não Realizada;4=Ciencia Op.;5=Cancelada;6=Desacordo                                  
		//------------------------------------------------------------------------------------------------------//
Else

	DbSelectArea(xZBZ)
	Reclock(xZBZ,.F.)
		(xZBZ)->(FieldPut(FieldPos(xZBZ_+"MANIF"), "1" ))
		if nEve == 3
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PDF"), cJust ))  //Usar Esse Campo por enquanto
		endif
	MsUnlock()

EndIf

RestArea(aArea)

Return( NIL )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MyAviso   ºAutor  ³ Eneo               º Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Interface/Dialog de Aviso.                                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Geral                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function TELMAN(cCaption,cMensagem,aBotoes,nSize,cCaption2, nRotAutDefault,cBitmap,lEdit,nTimer,nOpcPadrao,lAuto)
Local ny        := 0
Local nx        := 0
Local aSize  := {  {134,304,35,155,35,113,51},;  // Tamanho 1
				{134,450,35,155,35,185,51},; // Tamanho 2
				{227,450,35,210,65,185,99} } // Tamanho 3
Local nLinha    := 0
Local cMsgButton:= ""
Local oGet 
Local nPass := 0
Private oDlgAviso
Private nOpcAviso := 0

DEFAULT lEdit := .F.
If lEdit
	nSize := 3
EndIf

lMsHelpAuto := .F.

cCaption2 := Iif(cCaption2 == Nil, cCaption, cCaption2)
cMensagem := "1-Confirmação da operação: Operação conclusiva, o emissor não poderá cancelar o XML"+CRLF
cMensagem += "2-Desconhecimento da operação"+CRLF
cMensagem += "3-Operação não Realizada"+CRLF
cMensagem += "4-Ciência da operação: Deverá Confirmar operação posteriormente, o emissor não poderá cancelar o XML"+CRLF
//"Confirmação da operação","Desconhecimento da operação","Operação não Realizada","Ciência da operação"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Quando for rotina automatica, envia o aviso ao Log.          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type('lMsHelpAuto') == 'U'
	lMsHelpAuto := .F.
EndIf

If !lMsHelpAuto
	If nSize == Nil
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o numero de botoes Max. 5 e o tamanho da Msg.       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If  Len(aBotoes) > 3
			nSize := 3
		Else
			Do Case
				Case Len(cMensagem) > 170 .And. Len(cMensagem) < 250
					nSize := 2
				Case Len(cMensagem) >= 250
					nSize := 3
				OtherWise
					nSize := 1
			EndCase
		EndIf
	EndIf
	If nSize <= 3
		nLinha := nSize
	Else
		nLinha := 3
	EndIf
	DEFINE MSDIALOG oDlgAviso FROM 0,0 TO aSize[nLinha][1],aSize[nLinha][2] TITLE cCaption OF oDlgAviso PIXEL
	DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD
//	@ 0, 0 BITMAP RESNAME "LOGIN" oF oDlgAviso SIZE aSize[nSize][3],aSize[nSize][4] NOBORDER WHEN .F. PIXEL ADJUST .T.
	@ 11 ,35  TO 13 ,400 LABEL '' OF oDlgAviso PIXEL
	If cBitmap <> Nil
		@ 2, 37 BITMAP RESNAME cBitmap oF oDlgAviso SIZE 18,18 NOBORDER WHEN .F. PIXEL
		@ 3  ,50  SAY cCaption2 Of oDlgAviso PIXEL SIZE 130 ,9 FONT oBold
	Else
		@ 3  ,37  SAY cCaption2 Of oDlgAviso PIXEL SIZE 130 ,9 FONT oBold
	EndIf
	If nSize < 3
		@ 16 ,38  SAY cMensagem Of oDlgAviso PIXEL SIZE aSize[nLinha][6],aSize[nLinha][5]
	Else
		If !lEdit
			@ 16 ,38  GET oGet VAR cMensagem Of oDlgAviso PIXEL SIZE aSize[nLinha][6],aSize[nLinha][5] READONLY MEMO
		Else
			@ 16 ,38  GET oGet VAR cMensagem Of oDlgAviso PIXEL SIZE aSize[nLinha][6],aSize[nLinha][5] MEMO
		EndIf
	EndIf
	If Len(aBotoes) > 1 .Or. nTimer <> Nil
		TButton():New(1000,1000," ",oDlgAviso,{||Nil},82,10,,oDlgAviso:oFont,.F.,.T.,.F.,,.F.,,,.F.)
	EndIf
	ny := 38
	l1 := .T.
	For nx:=1 to Len(aBotoes)
		cAction:="{||nOpcAviso:="+Str(nx)+",oDlgAviso:End()}"
		bAction:=&(cAction)
		cMsgButton:= OemToAnsi(AllTrim(aBotoes[nx]))
		cMsgButton:= IF(  "&" $ Alltrim(cMsgButton), cMsgButton ,  "&"+cMsgButton )
		if l1
			TButton():New(aSize[nLinha][7]-15,ny,cMsgButton, oDlgAviso,bAction,82,10,,oDlgAviso:oFont,.F.,.T.,.F.,,.F.,,,.F.)
		Else
			TButton():New(aSize[nLinha][7]   ,ny,cMsgButton, oDlgAviso,bAction,82,10,,oDlgAviso:oFont,.F.,.T.,.F.,,.F.,,,.F.)
		Endif
		ny += 85
		if ny > 150
			ny := 38
			l1 := .F.
		endif
	Next nx
	If nTimer <> Nil
		oTimer := TTimer():New(nTimer,{|| nOpcAviso := nOpcPadrao,IIf(nPass==0,nPass++,oDlgAviso:End()) },oDlgAviso)
		oTimer:Activate()
		bAction:= {|| oTimer:DeActivate() }
		TButton():New(aSize[nLinha][7],ny,"Timer off", oDlgAviso,bAction,52,10,,oDlgAviso:oFont,.F.,.T.,.F.,,.F.,,,.F.)
	Endif
	ACTIVATE MSDIALOG oDlgAviso CENTERED
Else
	If ValType(nRotAutDefault) == "N" .And. nRotAutDefault <= Len(aBotoes)
		cMensagem += " " + aBotoes[nRotAutDefault]
		nOpcAviso := nRotAutDefault
	Endif
	ConOut(Repl("*",40))
	ConOut(cCaption)
	ConOut(cMensagem)
	ConOut(Repl("*",40))
	AutoGrLog(cCaption)
	AutoGrLog(cMensagem)
EndIf

Return (nOpcAviso)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ HFXMLVTL ºAutor  ³ Eneo               º Data ³ 28/10/2015  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Interface de Amarração Virtual a Pedido da Nordson         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Geral                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//nordsonAmarra
USer Function HFXMLVTL(xCod,xLoj,xTip)

Local aArea   := GetArea()
Local lRet    := .F.
Local aLinha  := {}
Local _aAux   := {}
Local nI      := 0
Local cNomeAx := ""
Local oDlg
Local lXMLPE2UM := ExistBlock( "XMLPE2UM" )
Local lXMLPEITE := ExistBlock( "XMLPEITE" )
Local aInfo		:= {}
Local aPosObj	:= {}
Local aObjects	:= {}
Local aSize		:= MsAdvSize()  			// Define e utilização de janela padrão Microsiga
Local nTamProd  := TAMSX3("D1_COD")[1]
Local cLinOk 	:= "AllwaysTrue"
Local cTudoOk 	:= "U_HFCOLAS()"
Local aProdOk   := {}
Local aProdNo   := {}
Local aProdVl   := {}
Local nErrItens := 0
Local aProdZr   := {}
Local nAuxFret  := 0

Private cA100For := xCod
Private cLoja    := xLoj
Private cTipo    := xTip
Private lConsLoja:= .T.
Private aCols    := {}
Private aHeader2 := {}
Private aPicture := {}
Private N        := 1

if nTamProd <= 2  //não pode existir codigos muito pequenos, vamos ver se é esse o pobrema da nordspon
	nTamProd := 15
endif

if (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC"))) == "N"
	DbSelectArea( "SA2" )
	If SA2->( dbSeek( xFilial( "SA2" ) + cA100For + cLoja ) )
		cNomeAx := SA2->A2_NREDUZ
	EndIf
Else
	DbSelectArea( "SA1" )
	If SA1->( dbSeek( xFilial( "SA1" ) + cA100For + cLoja ) )
		cNomeAx := SA1->A1_NREDUZ
	EndIf
EndIf

//RegToMemory("SD1",.T.)

DbSelectArea( "SB1" )


//Montar o aHeader
/*
Aadd(aHeader,{ "Prod Interno", "D1_COD", "@!",;
	    		     15, 0,"U_HFVLPR(.T.)",;
    	   			 "€€€€€€€€€€€€€€ ", "C", "SB1", "R" } )

1 Título
2 Campo
3 Picture
4 Tamanho
5 Decimal
6 Validação
7 Reservado
8 Tipo
9 Reservado
10 Reservado
*/
aHeader  := {}
Aadd(aHeader,{ "Seq", "MSEQ", "@!",;
	    		     4, 0,"AllwaysTrue()",;
    	   			 "", "C", "", "R" } )
Aadd(aHeader,{ "Prod XML", "MXML", "@!",;
	    		     15, 0,"AllwaysTrue()",;
    	   			 "", "C", "", "R" } )
Aadd(aHeader,{ "Prod Interno", "D1_COD", "@!",;
	    		     15, 0,"U_HFVLPR(.T.)",;
    	   			 "€€€€€€€€€€€€€€ ", "C", "SB1", "R" } )
Aadd(aHeader,{ "Descrição", "MDESC", "@!",;
	    		     45, 0,"AllwaysTrue()",;
    	   			 "", "C", "", "R" } )
Aadd(aHeader,{ "Unid", "MUND", "@!",;
	    		     2, 0,"AllwaysTrue()",;
    	   			 "", "C", "", "R" } )
Aadd(aHeader,{ "Quantidade", "MQTD", "@E 9999999999.999999",;
	    		     15, 0,"AllwaysTrue()",;
    	   			 "", "C", "", "R" } )
Aadd(aHeader,{ "Vr Unitário", "MQTD", "@E 9,999,999,999.999999",;
	    		     15, 0,"AllwaysTrue()",;
    	   			 "", "C", "", "R" } )
Aadd(aHeader,{ "Vr Total", "MQTD", "@E 99,999,999,999.99",;
	    		     15, 0,"AllwaysTrue()",;
    	   			 "", "C", "", "R" } )
//FR - 31/03/2021
Aadd(aHeader,{ "Lote Fornecedor", "D1_LOTEFOR", "@X",;
	    		     18, 0,"AllwaysTrue()",;
    	   			 "", "C", "", "R" } )

Aadd(aHeader,{ "Valid. Lote ", "D1_DTVALID", "@D",;
	    		     8, 0,"AllwaysTrue()",;
    	   			 "", "D", "", "R" } )
    	   			     	   			 
Aadd(aHeader,{ "Ano de Fabricação", "D1_ANOFAB", "@X",;
	    		     2, 0,"AllwaysTrue()",;
    	   			 "", "C", "", "R" } )    	 

Aadd(aHeader,{ "Data Fabric ", "D1_DFABRIC", "@D",;
	    		     8, 0,"AllwaysTrue()",;
    	   			 "", "D", "", "R" } )  			     	   			 
//FR - 31/03/2021    	   			 

aAdd( aObjects, { 100, 060, .T., .T. } )      //GetDados
aAdd( aObjects, { 100, 040, .T., .T. } )      //Folder
aInfo := { aSize[1], aSize[2], aSize[3], aSize[4], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects,.T. )

//Montar o aCols
aCols := {}
oDet  := {}

if Type( "oXml:_NFEPROC:_NFE:_INFNFE:_DET" ) <> "U"

	oDet := oXml:_NFEPROC:_NFE:_INFNFE:_DET
	oDet := IIf(ValType(oDet)=="O",{oDet},oDet)

	For nI := 1 To Len( oDet )

		_aAux := {}
		aadd(_aAux, StrZero( nI, 4, 0 ) )
		aadd(_aAux, Substr( oDet[nI]:_Prod:_CPROD:TEXT + space( nTamProd ), 1, nTamProd ) )
		aadd(_aAux, space( nTamProd ) )
		aadd(_aAux, oDet[nI]:_Prod:_XPROD:TEXT )
		aadd(_aAux, oDet[nI]:_Prod:_UCOM:TEXT )
		aadd(_aAux, VAL(oDet[ni]:_Prod:_QCOM:TEXT)   )
		aadd(_aAux, VAL(oDet[ni]:_Prod:_VUNCOM:TEXT) )
		aadd(_aAux, VAL(oDet[ni]:_Prod:_VPROD:TEXT)  )
		//FR - 31/03/2021
		cLote := ""
		cValLote := ""
		cAnoFab  := ""
		dValLote := Ctod("  /  /    ")
		cValFab  := ""
		dDatFab  := Ctod("  /  /    ")

		if Type("oDet["+Str(nI)+"]:_Prod") <> "U"

			if XmlChildEx(oDet[nI]:_Prod,"_RASTRO") <> nil   //Complemento

				If Valtype(oDet[nI]:_Prod:_Rastro) == "A" //SE FOR ARRAY
				
					cLote   := oDet[nI]:_Prod:_Rastro[1]:_NLOTE:TEXT
					cValLote:= oDet[nI]:_Prod:_Rastro[1]:_DVAL:TEXT		//vem assim: "2045-12-16" -> transformar para 16/12/2045
					dValLote:= CtoD( Substr(cValLote,9,2) + "/" + Substr(cValLote,6,2) + "/" + Substr(cValLote,1,4) ) 
					cAnoFab := Substr(oDet[nI]:_Prod:_Rastro[1]:_DFAB:TEXT , 3,2)  	//vem assim: "2018-08-01" -> transformar para 18 o ano tem 2 dígitos apenas
					cValFab := oDet[nI]:_Prod:_Rastro[1]:_DFAB:TEXT
					dDatFab := CtoD( Substr(cValFab,9,2) + "/" + Substr(cValFab,6,2) + "/" + Substr(cValFab,1,4) )	

				else
			
					cLote   := oDet[nI]:_Prod:_Rastro:_NLOTE:TEXT
					cValLote:= oDet[nI]:_Prod:_Rastro:_DVAL:TEXT		//vem assim: "2045-12-16" -> transformar para 16/12/2045
					dValLote:= CtoD( Substr(cValLote,9,2) + "/" + Substr(cValLote,6,2) + "/" + Substr(cValLote,1,4) ) 
					cAnoFab := Substr(oDet[nI]:_Prod:_Rastro:_DFAB:TEXT , 3,2)  	//vem assim: "2018-08-01" -> transformar para 18 o ano tem 2 dígitos apenas
					cValFab := oDet[nI]:_Prod:_Rastro:_DFAB:TEXT
					dDatFab := CtoD( Substr(cValFab,9,2) + "/" + Substr(cValFab,6,2) + "/" + Substr(cValFab,1,4) )	

				endif												

			endif

		endif

		//tipo C , tamanho 18
		aadd(_aAux, cLote  )	
		//tipo D , tamanho 8
		aadd(_aAux, dValLote  )
		//tipo C , tamanho 2
		aadd(_aAux, cAnoFab  )		
		aadd(_aAux, dDatFab  )										
		//FR - 31/03/2021
		aadd(_aAux, .F.  )
		aadd(_aAux, .F.  )
		aadd(aCols,_aAux)	
		
	Next nI 

ElseIf Type( "oXml:_CTEPROC:_CTE:_INFCTE:_VPREST" ) <> "U"  //Se Foire CTE

	oDet := oXml:_CTEPROC:_CTE:_INFCTE:_VPREST
	cProdCte := Padr(GetNewPar("XM_PRODCTE","FRETE"),nTamProd)
   	cProdCte :=Iif(Empty(cProdCte),Padr("FRETE",nTamProd),cProdCte)
	_aAux := {}
	aadd(_aAux, StrZero( 1, 4, 0 ) )
	aadd(_aAux, "FRETE" )
	aadd(_aAux, Substr( cProdCte + space( nTamProd ), 1, nTamProd ) )
	aadd(_aAux, "FRETE" )
	aadd(_aAux, "UN" )
	aadd(_aAux, 1   )
	aadd(_aAux, VAL(oDet:_VTPREST:TEXT) )
	aadd(_aAux, VAL(oDet:_VTPREST:TEXT) )
	//FR - 31/03/2021
	cLote := ""
	cValLote := ""
	cAnoFab  := ""
	dValLote := Ctod("  /  /    ")
	cValFab  := ""
	dDatFab  := Ctod("  /  /    ")
	
	aadd(_aAux, cLote  )
	aadd(_aAux, dValLote  )
	aadd(_aAux, cAnoFab  )
	aadd(_aAux, dDatFab  )	
	//FR - 31/03/2021
	aadd(_aAux, .F.  )
	aadd(_aAux, .F.  )
	aadd(aCols,_aAux)

ElseIf Type( "oXml:_NFSETXT:_INFPROC" )  <> "U" //Se for NFSe NFCE_03 16/05, usado cProdCte só para passar no msm parÂmetro

	oDet := oXml:_NFSETXT:_INFPROC
	cProdCte := Padr(GetNewPar("XM_PRODNFS","SERVICO"),nTamProd)
	cProdCte :=Iif(Empty(cProdNfse),Padr("SERVICO",nTamProd),cProdCte)

	_aAux := {}
	aadd(_aAux, StrZero( 1, 4, 0 ) )
	aadd(_aAux, "SERVICO" )
	aadd(_aAux, Substr( cProdCte + space( nTamProd ), 1, nTamProd ) )
	aadd(_aAux, "SERVICO" )
	aadd(_aAux, "SV" )
	aadd(_aAux, 1   )
	aadd(_aAux, VAL(oDet:_VRSERV:TEXT) )
	aadd(_aAux, VAL(oDet:_VRSERV:TEXT) )
	//FR - 31/03/2021
	cLote := ""
	cValLote := ""
	cAnoFab  := ""
	dValLote := Ctod("  /  /    ")
	cValFab  := ""
	dDatFab  := Ctod("  /  /    ")
	
	aadd(_aAux, cLote  )
	aadd(_aAux, dValLote  )
	aadd(_aAux, cAnoFab  )
	aadd(_aAux, dDatFab  )	
	//FR - 31/03/2021
	aadd(_aAux, .F.  )
	aadd(_aAux, .F.  )
	aadd(aCols,_aAux)
	
Endif

//Monta a Tela
//DEFINE MSDIALOG oDlg FROM  15,6 TO 500,930 TITLE ('Produtos do XML' ) PIXEL
DEFINE MSDIALOG oDlg From aSize[7],0 to aSize[6],aSize[5] TITLE ('Produtos do XML' ) PIXEL //of oMainWnd 

@ 014,002 TO 051,aPosObj[2,4]+2  LABEL '' OF oDlg 	PIXEL

@ 020,007 SAY "Fornecedor/Cliente" SIZE  51,7 OF oDlg PIXEL
@ 020,056 SAY cA100For             SIZE  49,8 OF oDlg PIXEL COLOR CLR_BLUE
@ 030,007 SAY "Nome"               SIZE  32,7 OF oDlg PIXEL
@ 030,056 SAY SA2->A2_NREDUZ       SIZE 140,8 OF oDlg PIXEL COLOR CLR_BLUE
@ 040,007 SAY "Loja"               SIZE  49,7 OF oDlg PIXEL
@ 040,056 SAY cLoja                SIZE  49,8 OF oDlg PIXEL COLOR CLR_BLUE

aHeader2 := {"Item",;
             "Prod. XML",;
             "Prod. Interno",;
             "Descrição",;
             "Unid",;
             "Qtd",;
             "Pr Unit",;
             "Total",;			
             "Lote Fornecedor",;	//FR - 31/03/2021 - Carregar número de lote do fornecedor na geração da nota
             "Dt.Validade Lote",;	//FR - 31/03/2021 - Carregar número de lote do fornecedor na geração da nota
             "Ano Fabricação",;		//FR - 31/03/2021 - Carregar número de lote do fornecedor na geração da nota
			 "Data Fabric.";
}
aPicture := {"@!",;
             "@!",;
             "@!",;
             "@!",;
             "@!",;
             "@E 999,999,999.9999",;
             "@E 999,999,999.9999",;
             "@E 999,999,999.99",;
             "@X",;					//FR - 31/03/2021 - Carregar número de lote do fornecedor na geração da nota
             "@D",;					//FR - 31/03/2021 - Carregar número de lote do fornecedor na geração da nota
             "@E 99",;				//FR - 31/03/2021 - Carregar número de lote do fornecedor na geração da nota
			 "@D";	
              }

//EnchoiceBar(oDlg,{||oDlg:End(),Nil},{||oDlg:End()},,)
aCpos:= {}
aadd( aCpos, "D1_COD" )
//oLstBox := RDListBox(4,.80,455,165, aCols, aHeader2,{15,20,20,50,15,30,30,30},aPicture)
//oGet :=  MSGetDados():New(60,2,aPosObj[2,3]+3,aPosObj[2,4]+2,1,,,,.F.,aCpos,1)
oGet := MsNewGetDados():New(60,2,aPosObj[2,3]+3,aPosObj[2,4]+2,GD_UPDATE,cLinOk,cTudoOk,,aCpos,,,,,,oDlg,aHeader,aCols) //
//oGet := MSGetDados():New(4,.80,455,165,1,"U_A030OK","U_A030OK",,.F.,aCpos,1)

//ACTIVATE MSDIALOG oDlg CENTERED                           
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||lRet := .T., iif( U_X020VLD( .T. ), oDlg:End(), Nil ) },{||lRet := .F., oDlg:End()},,)

if lRet

	aCols := oGet:aCols

	//Montar o aItens
	For nI := 1 To Len( aCols )

		aLinha := {}

		If lXMLPE2UM   //PE para conversão da 2 unidade de medida

			oIcm := oDet[nI]:_Imposto:_ICMS
			oIcm := IIf(ValType(oIcm)=="O",{oIcm},oIcm)
	   		aRet :=	ExecBlock( "XMLPE2UM", .F., .F., { aCols[nI][3],aCols[nI][5],aCols[nI][6],aCols[nI][7],oIcm } )
//	   		aRet :=	ExecBlock( "XMLPE2UM", .F., .F., { cProduto    ,cUm         ,nQuant      ,nVunit      ,oIcm } )

	   		if aRet == NIL

				aCols[nI][5] := "  "
				aCols[nI][6] := 0
				aCols[nI][7] := 0

			else

				aCols[nI][5] := iif( len(aRet) >= 2, aRet[2], "  " )
				aCols[nI][6] := iif( len(aRet) >= 3, aRet[3], 0 )
				aCols[nI][7] := iif( len(aRet) >= 4, aRet[4], 0 )

	   		endif

		 	if NoRound((aCols[nI][6] * aCols[nI][7]),2) != NoRound(aCols[nI][8], 2)

		 		if ABS( NoRound((aCols[nI][6] * aCols[nI][7]),2) - NoRound(aCols[nI][8], 2) ) >= 0.02
					aadd(aProdVl,{oDet[nI]:_Prod:_CPROD:TEXT, aCols[nI][5], aCols[nI][6], aCols[nI][7], aCols[nI][8], (aCols[nI][6] * aCols[nI][7]) } )
				else
					if aCols[nI][7] <> VAL(oDet[nI]:_Prod:_VUNCOM:TEXT) //por causa do problema de arredondar e truncar com valor unitário com 3 casas decimais (Itambé)
					 	if ABS( NoRound((aCols[nI][6] * aCols[nI][7]),2) - NoRound(aCols[nI][8], 2) ) > 0.01  //Coferly
							aadd(aProdVl,{oDet[nI]:_Prod:_CPROD:TEXT, aCols[nI][5], aCols[nI][6], aCols[nI][7], aCols[nI][8], (aCols[nI][6] * aCols[nI][7]) } )
						endif
					endif
				endif
		 	endif

	 	EndIf

		aadd(aLinha,{"D1_ITEM"  ,StrZero( nI, 4, 0 )             ,Nil})
		aadd(aLinha,{"D1_COD"   ,aCols[nI][3]	          		 ,Nil})
		aadd(aLinha,{"D1_QUANT" ,aCols[nI][6]					 ,Nil})
		aadd(aLinha,{"D1_VUNIT" ,aCols[nI][7]					 ,Nil})
		aadd(aLinha,{"D1_TOTAL" ,aCols[nI][8]					 ,Nil})

		if Type( "oDet["+cValtoChar(nI)+"]:_Prod:_VFRETE:text" )  <> "U"
			if Val(oDet[nI]:_Prod:_VFRETE:text) > 0
				nAuxFret := ( Val(oDet[1]:_Prod:_VFRETE:text) / Len(oDet))
				aadd(aLinha,{"D1_VALFRE" ,nAuxFret					 ,Nil})
			endif
		endif

		If lXMLPEITE   //PE para incluir campos no aLinha SD1 -> para o aItens
			aRet :=	ExecBlock( "XMLPEITE", .F., .F., { aCols[nI][3],oDet,nI } )
			If ValType(aRet) == "A"
				AEval(aRet,{|x| AAdd(aLinha,x)})
			EndIf
		EndIf

		//FR - 31/03/2021
		aadd(aLinha,{"D1_LOTEFOR"		,aCols[nI][9]			     ,Nil})		//tipo C , tamanho 18
		aadd(aLinha,{"D1_DTVALID"		,aCols[nI][10]			     ,Nil})		//tipo D , tamanho 8
		aadd(aLinha,{"D1_ANOFAB"		,aCols[nI][11]			     ,Nil})		//tipo C , tamanho 2	
		aadd(aLinha,{"D1_DFABRIC"		,aCols[nI][12]			     ,Nil})		//tipo D , tamanho 8									
		
		//FR - 31/03/2021
		aadd(aItens,aLinha)

	Next nI

	//Itens não encontrados
	if .not. U_HFITNENC( "PREN", aProdOk, aProdNo, aProdVl, @nErrItens, aProdZr )
	    lRet := .F.
	endif

EndIf

RestArea( aArea )

Return( lRet ) 


USer Function HFCOLAS()

aCols := aParCols

Return( .T. )


User Function HFVLPR( lShow )

Local lRet := .T. 

SB1->(OrdSetFocus(1))
SB1->(Dbgotop())
If SB1->( DbSeek( xFilial( "SB1" ) + M->D1_COD ) )
	If SB1->B1_MSBLQL == "1"
		lRet := .F.
		If lShow
	   		U_MyAviso("Aviso","Produto Bloqueado no Cadastro de Produtos !!!",{"OK"},3)
	   	EndIf
	Endif
Else
	lRet := .F.
	if lShow
   		U_MyAviso("Aviso","Produto Não Localizado No Cadastro de Produtos.",{"OK"},3)
   	EndIf
EndIf

Return(lRet )


User Function X020VLD( lShow )

Local lRet := .T.
Local nY := 0
Local aArea := GetArea()
Local cMsg  := ""
aCols := oGet:aCols
DbSelectArea( "SB1" )
dbSetORder(1)
For nY := 1 to len( aCols )
	if .NOT. SB1->( DbSeek( xFilial( "SB1" ) + aCols[nY][3] ) )
		lRet := .F.
		cMsg += aCols[nY][1]+" ["+iif( Empty(aCols[nY][3]), "Não Informado", AllTrim(aCols[nY][3]) )+"]"+CRLF
	Elseif SB1->B1_MSBLQL == "1"
		lRet := .F.
		cMsg += aCols[nY][1]+" ["+AllTrim(aCols[nY][3])+"] BLOQUEADO"+CRLF
	endif
Next nY

if .NOT. lRet .And. lShow
   	U_MyAviso("Aviso","Não foi encontrados Produto(s):"+CRLF+cMsg,{"OK"},3)
EndIf

RestArea( aArea )

Return( lRet )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ HFCKXML1 ºAutor  ³Eneovaldo Roveri Jr º Data ³  10/12/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ JOB da Piaozada                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ImportaXML                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//U_HFCKXML1()
//Default cLogProc := ""
//Default lAuto    := .T.
//Default oProcess := Nil
//Default lEnd     := .F.
//Default nCount   := 0
//Default lMostra  := .F.
User Function HFCKXML1(aArray) //lAuto,lEnd,oProcess,cLogProc,nCount,lMostra)
Local nX := 1
Local cEmp := ""
Local cFil := ""

Conout( "HFCKXML1 :" )

For nX := 1 To Len(aArray)
	Conout(alltrim(str(nx)) + " " + aArray[nX] )
Next NX

For nX := 1 To Len(aArray) step 4

	cEmp := iif(len(aArray)>=nX  , aArray[nX]  , "")
	cFil := iif(len(aArray)>=nX+1, aArray[nX+1], "")

	U_HFPRCXML( 1, cEmp, cFil )

Next nX

Return( NIL )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ HFCKXML2 ºAutor  ³Eneovaldo Roveri Jr º Data ³  10/12/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ JOB dos Gerentes                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ImportaXML                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//U_HFCKXML2()
User Function HFCKXML2(aArray) //lAuto,lEnd,oProcess,cLogProc,nCount,lMostra)

Local nX         := 0

Default cLogProc := ""
Default lAuto    := .T.
Default oProcess := Nil
Default lEnd     := .F.
Default nCount   := 0
Default lMostra  := .F.

Conout( "HFCKXML2 :" )

For nX := 1 To Len(aArray)
	Conout(alltrim(str(nx)) + " " + aArray[nX] )
Next NX

For nX := 1 To Len(aArray) step 4

	cEmp := iif(len(aArray)>=nX  , aArray[nX]  , "")
	cFil := iif(len(aArray)>=nX+1, aArray[nX+1], "")

	U_HFPRCXML( 2, cEmp, cFil )

Next nX

Return( NIL )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ HFPRCXML ºAutor  ³Eneovaldo Roveri Jr º Data ³  10/12/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina que verifica os XMLs das subpastas a partir da      º±±
±±º          ³ xmlsourece, se estão na ZBZ                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ImportaXML                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function HFPRCXML( nQual, cEmp, cFil )
Local aArea   := GetArea()
Local aArvDir := {}
Local aXmlNao := {}

RpcSetType(3)
RpcSetEnv(cEmp, cFil)   //SM0->M0_CODIGO, SM0->M0_CODFIL

Private xZBZ  	  := GetNewPar("XM_TABXML","ZBZ")      //ECOOOOOOOOOO
Private xZBZ_ 	  := iif(Substr(xZBZ,1,1)=="S", Substr(xZBZ,2,2), Substr(xZBZ,1,3)) + "_"
Private xZBE      := GetNewPar("XM_TABEVEN","ZBE")
Private xZBE_     := iif(Substr(xZBE,1,1)=="S", Substr(xZBE,2,2), Substr(xZBE,1,3)) + "_"
Private xZBC      := GetNewPar("XM_TABCAC","ZBC")
Private xZBC_     := iif(Substr(xZBC,1,1)=="S", Substr(xZBC,2,2), Substr(xZBC,1,3)) + "_"
Private xZBO      := GetNewPar("XM_TABOCOR","ZBO"), xRetSEF := ""
Private xZBO_     := iif(Substr(xZBO,1,1)=="S", Substr(xZBO,2,2), Substr(xZBO,1,3)) + "_"
Private xZBI      := GetNewPar("XM_TABIEXT","ZBI")
Private xZBI_     := iif(Substr(xZBI,1,1)=="S", Substr(xZBI,2,2), Substr(xZBI,1,3)) + "_"
Private aHfCloud  := {"0","0"," ","Token",{}}  //CRAUMDE - '0' Não integrar, na posição 1

dbSelectArea( xZBZ )
dbSetOrder( 3 )

aArvDir := ArvDir()

aXmlNao := VarreXML( aArvDir )

If ! Empty(aXmlNao)
	EnvMailChk( nQual, aXmlNao )
	//aqui vai o e-mail
EndIf

RestArea( aArea )

RstMvBuff()
DelClassIntf()
RpcClearEnv()

Return( NIL )


Static Function ArvDir()
Local aRet   := {}
Local cDir   := AllTrim(SuperGetMv("MV_X_PATHX"))
Local aFiles := {} // O array receberá os nomes dos arquivos e do diretório
Local nX, nY
Local nCount := 0
Private lChkImp   := ( GetNewPar("XM_ENVIMP","N") == "S" )

aFiles := Directory(cDir+"*.*","D")
For nX := 1 To Len( aFiles )
	if aFiles[nX][5] == "D" .And. aFiles[nX][1] <> "." .And. aFiles[nX][1] <> ".."
		if lChkImp .OR. UPPER(alltrim(aFiles[nX][1])) <> "IMPORTADOS"
			aadd( aRet, cDir+alltrim(aFiles[nX][1])+cBarra )
		Endif
	endif
Next nX

nCount := Len( aRet )
nY     := 1
Do While nY <= nCount
	aFiles := Directory(aRet[nY]+"*.*","D")
	For nX := 1 To Len( aFiles )
		if aFiles[nX][5] == "D" .And. aFiles[nX][1] <> "." .And. aFiles[nX][1] <> ".."
			aadd( aRet, aRet[nY]+alltrim(aFiles[nX][1])+cBarra )
		endif
	Next nX
	nCount := Len( aRet )
	nY++
EndDo

aSort( aRet,,,{|x,y| x < y } )

Return( aRet )


Static Function VarreXML( aArvDir )
Local aRet  := {}
Local aArea := GetArea()
Local nX := 0
Local nI, cDrive, cPath, cNewFile, cExt
Local cError := "", cWarning := ""
Private cTagKeyNfe := "oXml:_NFEPROC:_PROTNFE:_INFPROT:_CHNFE:TEXT"
Private cTagKeyCte := "oXml:_CTEPROC:_PROTCTE:_INFPROT:_CHCTE:TEXT"
Private oXml

( xZBZ )->( DbSetOrder( 3 ) )

For nX := 1 To Len( aArvDir )

	aFiles := Directory(aArvDir[nX]+"*.XML","D")
	aSort( aFiles,,,{|x,y| x[1]<y[1] } )

	For nI := 1 To Len(aFiles)
		SplitPath(aArvDir[nX]+AllTrim(aFiles[nI,1]),@cDrive,@cPath, @cNewFile,@cExt)

		cChaveXml := ""
		cError := ""
		cWarning := ""
		oXml := XmlParserFile( cPath+cNewFile+cExt, "_", @cError, @cWarning )
        
		If Type(cTagKeyNfe)<> "U"
			cChaveXml := &(cTagKeyNfe)
		ElseIf Type(cTagKeyCte)<> "U"
			cChaveXml := &(cTagKeyCte)
		Else
			cChaveXml := ""
		Endif

		If !Empty(cChaveXml)
			If .NOT. ( xZBZ )->(dbSeek( cChaveXml ) )
				aadd( aRet, {cChaveXml, aArvDir[nX]+AllTrim(aFiles[nI,1]) } )
			EndIF
		EndIf

	Next nI

Next nX

RestArea( aArea )
Return( aRet )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ HFENVMAILºAutor  ³ Eneo/Alexandro     º Data ³ 11/12/2015  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Envia Email				                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Geral                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function EnvMailChk(nQual, aXmlNao)
Local cAnexo  := ""
Local cError  := ""
Local cMsg    := ""
Local cHea    := ""
Local nI      := 0
Local aTo     := {}
Local lRet    := .F.
	Local cCap    := "NOTIFICAÇÃO DE XML NÃO IMPORTADOS - IMPORTAXML"
	Local cInfo   := "Notificações de XML que não foram importados na Base de Dados do Protheus"
	Default nQual := 0

	if nQual == 1
		cInfo += " (U_HFCKXML1) "
	ElseIf nQual == 2
		cInfo += " (U_HFCKXML2) "
	endif

	cMsg += '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
	cMsg += '<html xmlns="http://www.w3.org/1999/xhtml">'
	messagePadron( "",@cHea,"" )
	cMsg += cHea
	cMsg += '<body>'
	cMsg += '<table style="background-color: rgb(240, 240, 240); width: 800px; text-align: left; margin-left: auto; margin-right: auto;" id="total" border="0" cellpadding="12">'
	cMsg += '<caption>'+cCap+' EMPRESA '+cEmpAnt+' FILIAL '+cFilAnt+' '+'</caption>'
	cMsg += '            <tr>'
	cMsg += '                            <td colspan="5">'
	cMsg += '                                            <hr>'
	cMsg += '                                                           <p class="style1">'+cInfo + CRLF +'</p>'
	cMsg += '                                            </hr>'
	cMsg += '                            </td>'
	cMsg += '            </tr>'
	
	cMsg += '            <tr>'
	cMsg += '                            <th id="col_tag">Chave</th>'
	cMsg += '                            <th id="col_sef">Arquivo</th>'
	cMsg += '            </tr>'

	For nI := 1 To Len(aXmlNao)
	                cMsg += '            <tr>'
	                cMsg += '                            <td headers="col_tag">' + aXmlNao[nI][1]  + '</td>'
	                cMsg += '                            <td headers="col_sef">' + aXmlNao[nI][2] + '</td>'
	                cMsg += '            </tr>'
	Next nI
	cMsg += '</table>'
	cMsg += '</body>'
	cMsg += '</html>'

	if nQual == 1
		cEmailErr := AllTrim(SuperGetMv("XM_MAIL05")) // Conta de Email para envio da piãozada
	Else
		cEmailErr := AllTrim(SuperGetMv("XM_MAIL06")) // Conta de Email para envio da gerentada
	EndIf

	If !Empty(cEmailErr)
	    cAssunto:= "XMLs que não foram importados."
		aTo 	:= Separa(cEmailErr,";")
		nRet := U_MAILSEND(aTo,cAssunto,cMsg,@cError,cAnexo,"",cEmailErr,"","")
		If nRet == 0 .And. Empty(cError)
			lRet := .T.
		EndIf
	EndIf

Return( lRet )



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ HF20VCCE ºAutor  ³ Eneo               º Data ³ 28/05/2017  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Consulta Eventos e CCe da Chave (ZBE)                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Geral                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function HF20VCCE()
Local aArea := GetArea()
Local aProdZr:= {}
Local oDlg
Private oFont01   := TFont():New("Arial",07,14,,.T.,,,,.T.,.F.)

DbSelectArea( xZBE )
DbSetOrder(1)
DbSeek( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))) + Substr( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))),1,44), .T. )

If ! (xZBE)->( Eof() )
	//Alert( "Desenvolvendo...." )
	Do While ! (xZBE)->( Eof() ) .AND.;
		(xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL")))               == (xZBE)->(FieldGet(FieldPos(xZBE_+"FILIAL")))  .AND.;
		Substr( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))),1,44)  == Substr( (xZBE)->(FieldGet(FieldPos(xZBE_+"CHAVE"))), 1, 44 )

		aadd( aProdZr, { (xZBE)->(FieldGet(FieldPos(xZBE_+"TPEVE"))),;
		                 (xZBE)->(FieldGet(FieldPos(xZBE_+"SEQEVE"))),;
		                 (xZBE)->(FieldGet(FieldPos(xZBE_+"DHAUT"))),;
		                 (xZBE)->(FieldGet(FieldPos(xZBE_+"DESC"))) } )
		
 		(xZBE)->( dbSkip() )
	EndDo
	if len( aProdZr ) > 0

		DEFINE MSDIALOG oDlg TITLE "Eventos e Carta de Correcao" FROM 000,000 TO 550,650 PIXEL

		@ 010,010 Say "Chave "+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))) PIXEL OF oDlg COLOR CLR_RED FONT oFont01
		@ 020,010 LISTBOX oLbx2 FIELDS HEADER ;
		   "Evento","Seq.","Data", "Descrição" ;
		   SIZE 310,230 OF oDlg PIXEL

		oLbx2:SetArray( aProdZr )
		oLbx2:bLine := {|| {aProdZr[oLbx2:nAt,1],;
		     	            aProdZr[oLbx2:nAt,2],;
		     	            dtoc(aProdZr[oLbx2:nAt,3]),;
		     	            aProdZr[oLbx2:nAt,4] }}

		@ 025.2,069 BUTTON "OK" SIZE 35,15 OF oDlg Action oDlg:End()

		ACTIVATE MSDIALOG oDlg CENTER
    endIf
Else
	U_MYAviso("ATENÇÃO","Não existe Eventos importados para essa Chave "+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE")))+".",{"Ok"},3)
EndIf

DbSelectArea( xZBZ )

RestArea( aArea )
Return( NIL )





/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Empresa   ³ HF Consulting                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ´±±
±±³Funcao    ³ fLogLine  ³ Autor ³ Eneo / Welinton      ³ Data ³ 27/11/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Rotina de geracao de arquivo TXT contendo LOG de processa- ³±±
±±³          ³ mento.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Obs.      ³ Quando nao for passado os parametros da rotina sempre sera ³±±
±±³          ³ criado um novo arquivo de log.                             ³±±
±±³          ³ Caso seja passado os parametros sera incrementado o log.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fLogLine(cMsg,cArqLog)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cMsg    : Mensagem a ser gravada no arquivo de log (.TXT)  ³±±
±±³          ³ cDir    : Diretorio onde o arquivo sera gravado            ³±±
±±³          ³ cArqLog : Nome do arquivo a ser gravado                    ³±±
±±³          ³ nHdl    : Nome do Handle do arquivo                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³             ATUALIZACOES SOFRIDAS DESDE CONSTRUCAO                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Data      ³ Programador      ³ Manutencao efetuada                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  /  /    ³                  ³                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Capricornio S/A                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
//U_HfLogLin(cMsg,cDirLog,cArqLog,nHdl)
User Function HfLogLin(cMsg,cDirLog,cArqLog,nHdl)

Local cEOL	   := CHR(13)+CHR(10)
Local cDir     := AllTrim(SuperGetMv("MV_X_PATHX"))
Local cDirLog2 := AllTrim(cDir+cBarra+"Log"+cBarra)

Default cMsg	:=	""
Default cDirLog	:=	""
Default cArqLog	:=	""
Default nHdl 	:=	0

if Empty(cDirLog)
	cDirLog	:= cDirLog2
endif

If !ExistDir(cDirLog)
	Makedir(cDirLog)
EndIf

If Right(cDirLog,1) <> cBarra
	cDirLog := cDirLog+cBarra
EndIf

cDirLog := StrTran(cDirLog,cBarra+cBarra,cBarra)

If !ExistDir(cDirLog)
	MakeDir(cDirLog)
EndIf

If Empty(cArqLog)
	cArqLog	:= cDirLog+cBarra+"SEFAZ_"+StrTran(DtoS(Date())+Time(),":","")+".LOG"
EndIf

cArqLog := StrTran(cArqLog,cBarra+cBarra,cBarra)

If nHdl == 0
	If File(cArqLog)
		//Sleep( 500 )
		cArqLog	:= cDirLog+cBarra+"SEFAZ_"+StrTran(DtoS(Date())+Time(),":","")+".LOG"
		cArqLog := StrTran(cArqLog,cBarra+cBarra,cBarra)
	EndIf
	nHdl := fCreate(cArqLog)
	fClose(nHdl)
EndIf

If nHdl == -1
	nHdl := 0
	ConOut("Arquivo não pode ser criado: " + STR(FERROR()))	
	Return()
EndIf

cMsg := Time() + " " + cMsg
//PTInternal(1,cMsg)
Conout(cMsg)
cMsg += cEOL

nHdl := fOpen( cArqLog, 1)
fSeek(nHdl, 0, 2)
fWrite(nHdl, cMsg, Len(cMsg))

fClose(nHdl)
ConOut(cMsg)

Return(.T.)


//--------------------------------------------------------------------------//
//DOWNLOAD GERAL DE CHAVES
//--------------------------------------------------------------------------//
				//           .T.    .F.   NIL        ""         0     "2"
//          U_HFDGXML( cChv, lAuto, lEnd, oProcess, cLogProc, nCount, cVem )
//Rotina utilizada no job do gestao xml
User Function HFDGXML( cChv, lAuto, lEnd, oProcess, cLogProc, nCount, cVem, cNsu )

Local nRet    := 0
//Local aTag    := {}
//Local aErr    := {}
//Local cTags   := ""
Local cXmlSef := ""
Local cMod    := Substr(cChv,21,2)
Local cChave  := cChv
Local cDir    := ""	//FR - 05/05/2021 - #10382 - Kroma - tratativa para chamada dentro do Schedule 
Local cErro   := ""
Local cWarning:= ""
Local cNewKey := ""
Local cNewArq := ""
Local cChaveArq, cExt, cMsg, cInfo, l137
Local cMod    := Substr(cChv,21,2)
Local cChave  := cChv
Local cErro   := ""
Local cWarning:= ""
Local cNewKey := ""
Local cNewArq := ""
Local cChaveArq, cExt, cMsg, cInfo, l137


Private cMsgTag := ""
Private oXml, oXmlSef
Private cIdEnt  := U_GetIdEnt()
Private xZBS  	:= GetNewPar("XM_TABSINC","ZBS")
Private xZBS_ 	:= iif(Substr(xZBS,1,1)=="S", Substr(xZBS,2,2), Substr(xZBS,1,3)) + "_"
Private cMsgTag := ""
Private oXml, oXmlSef

cDir  := AllTrim(SuperGetMv("MV_X_PATHX"))
//cIdEnt:= U_GetIdEnt()
xZBS  := GetNewPar("XM_TABSINC","ZBS")	
xZBS_ := iif(Substr(xZBS,1,1)=="S", Substr(xZBS,2,2), Substr(xZBS,1,3)) + "_"	

//Baixar o XML da SEFAZ
If nRet >= 0

	if cMod == "55"
	
		if GetNewPar( "XM_DFE", "0" ) == "2"
		
			cChaveArq := ""
			cExt      := ""
			cMsg      := ""
			cInfo     := ""
			l137      := .F.
			
			cChaveArq := U_HFBxXML(cMod,"DC",Substr(cChave,1,44),@cExt,@cMsg,@cInfo,@l137,.F.,NIL)
			
			if Empty(cChaveArq)
			
				nRet := -4 
				
			else
			
				nRet :=	0 
				
			endif
			
		else
		
			nRet := HFBXXml( cChave, @cXmlSef, @oXmlSef, cNsu )
			
		endif
		
		if nRet == -4
		
			nRet := HFMFXml( cChave, "210210" )
			
			if nRet >= 0
			
				if GetNewPar( "XM_DFE", "0" ) == "2"
				
					cChaveArq := ""
					cExt      := ""
					cMsg      := ""
					cInfo     := ""
					l137      := .F.
					
					cChaveArq := U_HFBxXML(cMod,"DC",Substr(cChave,1,44),@cExt,@cMsg,@cInfo,@l137,.F.,NIL)
				
				else
				
					nRet := HFBXXml( cChave, @cXmlSef, @oXmlSef )
					
					if Empty(cChaveArq)
					
						nRet := -4 
						
					else
					
						nRet :=	0 
						
					endif
					
				endif
				
			endif
			
		endif
		
		if nRet < 0 .and. nRet <> -4 
			
			//U_HFDOWDFE( cCnpj,cChave,cAmb,cIdEnt,cNsu,@cLogProc )   //Pedir ao SEFAZ por NSU
		
		endif
		
		if nRet >= 0
		
			if GetNewPar( "XM_DFE", "0" ) == "2"
			
				//vai direto pra baixo
				
			else
			
				if Len(cXmlSef) >= 65534
				
					oXmlSef := U_PARSGDE( cXmlSef, @cErro, @cWarning )
					
				Else
				
					oXmlSef := XmlParser( cXmlSef, "_", @cErro, @cWarning )
					
				endif
				
			endif
			
		endif
		
	ElseIf cMod == "57"
	
		nRet := -1
		
		if GetNewPar( "XM_DFE", "0" ) == "2"
		
			cChaveArq := ""
			cExt      := ""
			cMsg      := ""
			cInfo     := ""
			l137      := .F.
			
			cChaveArq := U_HFBxXML(cMod,"DC",Substr(cChave,1,44),@cExt,@cMsg,@cInfo,@l137,.F.,NIL)
			
			if Empty(cChaveArq)
			
				nRet := -1 
				
			else
			
				nRet :=	0 
				
			endif
			
		endif
		
	Else
	
		nRet := -2
		//Alert( "Modelo Invalido" )
		
	Endif
	
Endif

if GetNewPar( "XM_DFE", "0" ) == "2"

	if nRet >= 0
	
		U_HFSLVXML(cChaveArq, lAuto, lEnd, oProcess, cLogProc, nCount, cVem, @cNewKey, @cNewArq, " " )
		          //            .T.   .F.   NIL        ""         0     "2"
	endif
	
Else

	If nRet >= 0 .And. oXmlSef <> NIL

		DbSelectArea(xZBS)
		DbSetOrder(3)
		if DbSeek(cChave)

			RecLock(xZBS, .F. )

			( xZBS )->(FieldPut(FieldPos(xZBS_+"XML"), cXmlSef ))

			( xZBS )->(MsUnLock())

		endif
	
		cChaveArq := cDir + Substr(cChave,1,44) + "-procNfe.xml"
		
		SAVE oXmlSef XMLFILE cChaveArq
		
		nHandle := FT_FUse( cChaveArq )
		
		if nHandle == -1
		
			cStt  := "0"
			nRet  := -1
			
		else
		
			cStt  := "1"
			
		endif
		
		FT_FUSE()
	
		If cStt == "1"
		
			cNewKey := ""
			cNewArq := ""
			
			U_HFSLVXML(Substr(cChave,1,44) + "-procNfe.xml", lAuto, lEnd, oProcess, cLogProc, nCount, cVem, @cNewKey, @cNewArq, " " )
			          //                                       .T.   .F.   NIL        ""         0     "2"
		EndIf
		
	Endif
	
endif


Return nRet




Static Function HFNFePC2Acol(nRecSC7,nItem,nSalPed,cItem,lPreNota,aRateio,aHeadSDE,aColsSDE,nPrUPreNf,lTColab)

Local aArea		  := GetArea()
Local aAreaSC7	  := SC7->(GetArea())
Local aAreaSF4	  := SF4->(GetArea())
Local aAreaSB1	  := SB1->(GetArea())
Local aAreaSC1    := SC1->(GetArea())
Local aAreaSTJ

Local aRefSC7     := MaFisSXRef("SC7")
Local nQuantPed   := 0
Local nX          := 0   
Local nCntFor     := 0 
Local nValUnit    := 0
Local nValFre     := 0
Local nValDesc    := 0
Local nValDesp    := 0
Local nValSeg     := 0
Local nPosQtd     := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_QUANT"})
Local nPosQtd2    := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_QTSEGUM"})
Local nPosTes     := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_TES"})
Local nPosVunit   := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_VUNIT"})
Local nPosBicm    := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_BASEICM"})
Local nPosPicm    := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_PICM"})
Local nPosVicm    := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_VALICM"})
Local nPosBipi    := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_BASEIPI"})
Local nPosIpi     := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_IPI"})
Local nPosVipi    := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_VALIPI"})
Local nPValFret	  := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_VALFRE"})
Local nPValDesc	  := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_VALDESC"})
Local nPValDesp	  := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_DESPESA"})
Local nPValSeg	  := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_SEGURO"})
Local lRateioPC   := SuperGetMv("MV_NFEDAPC")
Local lAllPC      := .T.
Local lAltImpPreNf:= .F.
Local cNGMNTNO	:= SuperGetMV("MV_NGMNTNO",.F.,"2")
Local lMaFisFound	:= .F. // MaFisFound()
Local nPMSIPC		:= GetNewPar("MV_PMSIPC",2)
Local lMT103IPC	:= ExistBlock( "MT103IPC",,.T. )
Local lMT103RCC	:= ExistBlock( "MT103RCC",,.T. )
Local lMT103IP2	:= ExistBlock( "MT103IP2",,.T. )
Local lRateioDE	:= .F.

DEFAULT aHeadSDE  := {}
DEFAULT aColsSDE  := {}

DEFAULT lPreNota := .F.
DEFAULT lTColab  := .F.
DEFAULT aRateio  := {0,0,0}


//³ Verifica a existencia do item do acols                       ³
If nItem == Nil .Or. nItem > Len(aCols)
	aadd(aCols,Array(Len(aHeader)+1))
	For nX := 1 to Len(aHeader)
		If IsHeadRec(aHeader[nX][2])
		    aCols[Len(aCols)][nX] := 0
		ElseIf IsHeadAlias(aHeader[nX][2])
		    aCols[Len(aCols)][nX] := "SD1"
		ElseIf Trim(aHeader[nX][2]) == "D1_ITEM"
			aCols[Len(aCols)][nX] 	:= IIF(cItem<>Nil,cItem,StrZero(1,Len(SD1->D1_ITEM)))
		Else
			aCols[Len(aCols)][nX] := CriaVar(aHeader[nX][2], (aHeader[nX][10] <> "V") )
		EndIf
		aCols[Len(aCols)][Len(aHeader)+1] := .F.
	Next nX
	nItem := Len(aCols)
EndIf

aCols[nItem][nPValDesc] := -1

Alert( aCols[nItem][nPValDesc]  )

//Posiciona registros
dbSelectArea("SC7")
SC7->(MsGoto(nRecSC7))

lAllPC := SC7->C7_QUANT == nSalPed .And. Empty(SC7->C7_REAJUST)

dbSelectArea("SB1")
SB1->(dbSetOrder(1))
SB1->(DbSeek(xFilial("SB1")+SC7->C7_PRODUTO))

//Considera quantidade e valor da nota importada via TOTVS Colaboracao
nValUnit := aCols[nItem][nPosVunit]
nSalPed  := aCols[nItem][nPosQtd]
nValFre	 := aCols[nItem][nPValFret]
nValDesc := aCols[nItem][nPValDesc]
nValDesp := IIF((nPValDesp > 0),aCols[nItem][nPValDesp],0)
nValSeg  := IIF((nPValSeg > 0),aCols[nItem][nPValSeg],0)

//Carrega os impostos do pedido de compra para o Doc.Entrada
If lMaFisFound
	//Obtem a condicao de pagamento do pedido de compra
	If (l103Class .and. Empty(cCondicao)) .Or. !l103Class
		cCondicao := SC7->C7_COND
	EndIf

	MaFisIniLoad(nItem)
	For nX := 1 To Len(aRefSc7)
		Do Case
		Case aRefSC7[nX][2] == "IT_QUANT"
			If !lPreNota
				MaFisLoad(aRefSc7[nX][2],nSalPed,nItem)
			EndIf
		Case aRefSc7[nX][2] == "IT_PRCUNI"
			If !lPreNota
				MaFisLoad(aRefSc7[nX][2],nValUnit,nItem)
			EndIf
		Case aRefSc7[nX][2] == "IT_VALMERC"
			If !lPreNota
				MaFisLoad(aRefSc7[nX][2],Round(nSalPed*Round(nValUnit,TamSX3('D1_VUNIT')[2]), TamSX3('D1_TOTAL')[2]),nItem)
			EndIf
		Case aRefSc7[nX][2] == "IT_DESCONTO"
			If !lPreNota
				MaFisLoad(aRefSc7[nX][2],xMoeda(((nValDesc/nQuantPed)* nSalPed),SC7->C7_MOEDA,1,M->dDEmissao,,SC7->C7_TXMOEDA,),nItem)
			EndIf
		Case aRefSc7[nX][2] == "IT_VALEMB"
			MaFisLoad(aRefSc7[nX][2],xMoeda(SC7->C7_VALEMB,SC7->C7_MOEDA,1,M->dDEmissao,,SC7->C7_TXMOEDA,),nItem)
		Case aRefSc7[nX][2] == "IT_SEGURO"
			If lRateioPC
				MaFisLoad(aRefSc7[nX][2],xMoeda(((nValSeg/nQuantPed)*nSalPed),SC7->C7_MOEDA,1,M->dDEmissao,,SC7->C7_TXMOEDA,),nItem)
			Else
				aRateio[1] += xMoeda(((nValSeg/nQuantPed)*nSalPed),SC7->C7_MOEDA,1,M->dDEmissao,,SC7->C7_TXMOEDA)
			EndIf
		Case aRefSc7[nX][2] == "IT_DESPESA"
			If lRateioPC
				MaFisLoad(aRefSc7[nX][2],xMoeda(((nValDesp/nQuantPed)*nSalPed),SC7->C7_MOEDA,1,M->dDEmissao,,SC7->C7_TXMOEDA,),nItem)
			Else
				aRateio[2] += xMoeda(((nValDesp/nQuantPed)*nSalPed),SC7->C7_MOEDA,1,M->dDEmissao,,SC7->C7_TXMOEDA)
			EndIf
		Case aRefSc7[nX][2] == "IT_FRETE"
			If lRateioPC	
				MaFisLoad(aRefSc7[nX][2],xMoeda(((nValFre/nQuantPed)*nSalPed),SC7->C7_MOEDA,1,M->dDEmissao,,SC7->C7_TXMOEDA,),nItem)
			Else
				aRateio[3] += xMoeda(((nValFre/nQuantPed)*nSalPed),SC7->C7_MOEDA,1,M->dDEmissao,,SC7->C7_TXMOEDA)
			EndIf
		Case aRefSc7[nX][2] == "IT_TES"
			If !Empty(SC7->C7_TES)
				dbSelectArea("SF4")
				SF4->(dbSetOrder(1))
				SF4->(DbSeek(xFilial("SF4")+SC7->C7_TES))				
				MaFisLoad("IT_CF",MaFisCFO(nItem,SF4->F4_CF),nItem)
			EndIf
		Case aRefSc7[nX][2] == "IT_BASEICM"
			nD1BaseIcm := SC7->(FieldGet(FieldPos(aRefSc7[nX][1])))
			If !lPreNota .Or. Empty(SD1->D1_BASEICM) .Or. SD1->D1_BASEICM == nD1BaseIcm
				If nD1BaseIcm <> 0
					MaFisLoad(aRefSc7[nX][2],nD1BaseIcm,nItem)
				Else
					lAltImpPreNf := .T.
				EndIf
			Else
				lAltImpPreNf := .T.
			EndIf
		Case aRefSc7[nX][2] == "IT_ALIQICM"
			nD1Picm := SC7->(FieldGet(FieldPos(aRefSc7[nX][1])))
			If !lPreNota .Or. Empty(SD1->D1_PICM) .Or. SD1->D1_PICM == nD1Picm
				If nD1Picm <> 0
					MaFisLoad(aRefSc7[nX][2],nD1Picm,nItem)
				Else
					lAltImpPreNf := .T.
				EndIf
			Else
				lAltImpPreNf := .T.
			EndIf
		Case aRefSc7[nX][2] == "IT_VALICM"
			nD1ValIcm	:= SC7->(FieldGet(FieldPos(aRefSc7[nX][1])))
			If !lPreNota .Or. Empty(SD1->D1_VALICM) .Or. SD1->D1_VALICM == nD1ValIcm
				If nD1ValIcm <> 0
					MaFisLoad(aRefSc7[nX][2],nD1ValIcm,nItem)
				Else
					lAltImpPreNf := .T.
				EndIf
			Else
				lAltImpPreNf := .T.
			EndIf			
		Case aRefSc7[nX][2] == "IT_BASEIPI"
			nD1BaseIpi	:= SC7->(FieldGet(FieldPos(aRefSc7[nX][1])))
			If !lPreNota .Or. Empty(SD1->D1_BASEIPI) .Or. SD1->D1_BASEIPI == nD1BaseIpi
				If nD1BaseIpi <> 0
					MaFisLoad(aRefSc7[nX][2],nD1BaseIpi,nItem)
				Else
					lAltImpPreNf := .T.
				EndIf				
			Else
				lAltImpPreNf := .T.
			EndIf
		Case aRefSc7[nX][2] == "IT_ALIQIPI"
			nD1AliqIpi := SC7->(FieldGet(FieldPos(aRefSc7[nX][1])))
			If !lPreNota .Or. Empty(SD1->D1_IPI) .Or. SD1->D1_IPI == nD1AliqIpi
				If nD1AliqIpi <> 0
					MaFisLoad(aRefSc7[nX][2],nD1AliqIpi,nItem)
				Else
					lAltImpPreNf := .T.
				EndIf				
			Else
				lAltImpPreNf := .T.
			EndIf
		Case aRefSc7[nX][2] == "IT_VALIPI"
			nD1ValIpi	:= SC7->(FieldGet(FieldPos(aRefSc7[nX][1])))	
			If !lPreNota .Or. Empty(SD1->D1_VALIPI) .Or. SD1->D1_VALIPI == nD1ValIpi
				If nD1ValIpi <> 0
					MaFisLoad(aRefSc7[nX][2],nD1ValIpi,nItem)
				Else
					lAltImpPreNf := .T.
				EndIf				
			Else
				lAltImpPreNf := .T.
			EndIf			
		OtherWise
			MaFisLoad(aRefSc7[nX][2],SC7->(FieldGet(FieldPos(aRefSc7[nX][1]))),nItem)
		EndCase
	Next nX
	MaFisEndLoad(nItem)
Else
	//Obtem a condicao de pagamento do pedido de compra
	cCondicao := SC7->C7_COND 
EndIf

//Atualiza o acols com base no pedido de compras
If !lPreNota
	For nCntFor := 1 To Len(aHeader)
		Do Case
		Case Trim(aHeader[nCntFor,2]) == "D1_COD"
			aCols[nItem,nCntFor] := SC7->C7_PRODUTO     
		Case Trim(aHeader[nCntFor,2]) == "D1_REVISAO"
			aCols[nItem,nCntFor] := SC7->C7_REVISAO
		Case Trim(aHeader[nCntFor,2]) == "D1_TOTAL"			
			aCols[nItem,nCntFor] := Round(nSalPed*Round(nValUnit,TamSX3('D1_VUNIT')[2]), TamSX3('D1_TOTAL')[2])
		Case Trim(aHeader[nCntFor,2]) == "D1_TES" .And. !Empty(SC7->C7_TES)
			aCols[nItem,nCntFor] := SC7->C7_TES
		Case Trim(aHeader[nCntFor,2]) == "D1_PEDIDO"
			aCols[nItem,nCntFor] := SC7->C7_NUM
		Case Trim(aHeader[nCntFor,2]) == "D1_QUANT" .Or. Trim(aHeader[nCntFor,2]) == "D1_SLDEXP"
			aCols[nItem,nCntFor] := nSalPed
		Case Trim(aHeader[nCntFor,2]) == "D1_VUNIT"
			aCols[nItem,nCntFor] := Round(nValUnit,TamSX3('D1_VUNIT')[2])
		Case Trim(aHeader[nCntFor,2]) == "D1_ITEMPC"
			aCols[nItem,nCntFor] := SC7->C7_ITEM
		Case Trim(aHeader[nCntFor,2]) == "D1_LOCAL"
			aCols[nItem,nCntFor] := SC7->C7_LOCAL
		Case Trim(aHeader[nCntFor,2]) == "D1_CC"
			aCols[nItem,nCntFor] := SC7->C7_CC     
		Case Trim(aHeader[nCntFor,2]) == "D1_OP"
			dbSelectArea("SC1")
			SC1->(dbSetOrder(1))
			SC1->(dbSeek(xFilial("SC1")+SC7->C7_NUMSC+SC7->C7_ITEMSC))
			If AllTrim(SC1->C1_ORIGEM) <> "MATA106"
				aCols[nItem,nCntFor] := SC7->C7_OP
			EndIf			
		Case Trim(aHeader[nCntFor,2]) == "D1_ITEMCTA"			// Item Contabil
			aCols[nItem,nCntFor] := Iif( Empty(SC7->C7_ITEMCTA), SB1->B1_ITEMCC, SC7->C7_ITEMCTA )
		Case Trim(aHeader[nCntFor,2]) == "D1_CONTA"				// Conta Contabil
			aCols[nItem,nCntFor] := Iif( Empty(SC7->C7_CONTA), SB1->B1_CONTA, SC7->C7_CONTA )
		Case Trim(aHeader[nCntFor,2]) == "D1_CLVL"				// Classe de Valor
			aCols[nItem,nCntFor] := Iif( Empty(SC7->C7_CLVL), SB1->B1_CLVL, SC7->C7_CLVL )
		Case Trim(aHeader[nCntFor,2]) == "D1_UM"
			aCols[nItem,nCntFor] := SC7->C7_UM
		Case Trim(aHeader[nCntFor,2]) == "D1_SEGUM"
			aCols[nItem,nCntFor] := SC7->C7_SEGUM
		Case Trim(aHeader[nCntFor,2]) == "D1_QTSEGUM"
			aCols[nItem,nCntFor] := IIF(SB1->B1_CONV <> 0 .And. aCols[nItem][nPosQtd] <> 0, ConvUm(SB1->B1_COD,aCols[nItem][nPosQtd],aCols[nItem][nPosQtd2],2),SC7->C7_QTSEGUM) 
		Case Trim(aHeader[nCntFor,2]) == "D1_DESC"
			aCols[nItem,nCntFor] := SC7->C7_DESC
		Case Trim(aHeader[nCntFor,2]) == "D1_VALDESC"
			aCols[nItem,nCntFor] := xMoeda(((SC7->C7_VLDESC/SC7->C7_QUANT)* nSalPed) , SC7->C7_MOEDA,1,M->dDEmissao,,SC7->C7_TXMOEDA)
		Case Trim(aHeader[nCntFor,2]) == "D1_RATEIO" 
			aCols[nItem,nCntFor] := SC7->C7_RATEIO
			If SC7->C7_RATEIO == "1"
				lRateioDE	:= .T.
			Endif
		Case Trim(aHeader[nCntFor,2]) == "D1_VALFRE"
			If nPValFret > 0
				aCols[nItem,nCntFor] := SC7->C7_VALFRE
			EndIf		
		Case Trim(aHeader[nCntFor,2]) == "D1_CODGRP"
			aCols[nItem,nCntFor] := SB1->B1_GRUPO
		Case Trim(aHeader[nCntFor,2]) == "D1_CODITE"
			aCols[nItem,nCntFor] := SB1->B1_CODITE  
		Case Trim(aHeader[nCntFor,2]) == "D1_CLASFIS"
			dbSelectArea("SF4")
			SF4->(dbSetOrder(1))
			SF4->(DbSeek(xFilial("SF4")+SC7->C7_TES))		
			aCols[nItem,nCntFor] := SubStr(SB1->B1_ORIGEM,1,1)+SF4->F4_SITTRIB
		Case Trim(aHeader[nCntFor,2]) == "D1_IPI"
			If !Empty(SC7->C7_IPI)
				aCols[nItem,nCntFor] := SC7->C7_IPI
			Else
				aCols[nItem,nCntFor] := SB1->B1_IPI
			EndIf
		Case Trim(aHeader[nCntFor,2]) == "D1_PICM"
			If !Empty(SC7->C7_PICM)
				aCols[nItem,nCntFor] := SC7->C7_PICM
			Else
				aCols[nItem,nCntFor] := SB1->B1_PICM
			EndIf 
		Case Trim(aHeader[nCntFor,2]) == "D1_ITEMMED"
			aCols[nItem,nCntFor] := If( !Empty( SC7->C7_CONTRA ) .And. !Empty( SC7->C7_MEDICAO ), "1", "2" )
		//Nota de empenho	
		Case Trim(aHeader[nCntFor,2]) == "D1_CODNE"
			aCols[nItem,nCntFor] := SC7->C7_CODNE
		Case Trim(aHeader[nCntFor,2]) == "D1_ITEMNE"
			aCols[nItem,nCntFor] := SC7->C7_ITEMNE
		Case Trim(aHeader[nCntFor,2]) == "D1_DTVALID"
			If Rastro(SC7->C7_PRODUTO) 
				aCols[nItem,nCntFor] := dDataBase + SB1->B1_PRVALID
			EndIf
		Case Trim(aHeader[nCntFor,2]) == "D1_ORDEM"
			If cNGMNTNO == "1"
			   aAreaSC1 := SC1->(GetArea())
			   aAreaSTJ := STJ->(GetArea())
			   
				If !Empty(SC7->C7_OP)
					dbSelectArea("STJ") 
					STJ->(dbSetOrder(1))
					
					cOPStj := SubStr(SC7->C7_OP,1,At("OS",SC7->C7_OP)-1)
					
					If STJ->(dbSeek(xFilial("STJ")+ cOPStj))
						aCols[nItem,nCntFor] := cOPStj			
					EndIf
				Else
					dbSelectArea("SC1")
					SC1->(dbSetOrder(1))
					If SC1->(dbSeek(xFilial("SC1")+SC7->C7_NUMSC+SC7->C7_ITEMSC))
						dbSelectArea("STJ")
						STJ->(dbSetOrder(1))
						
						cOPStj := if(!empty(SC1->C1_OS),SC1->C1_OS,SubStr(SC1->C1_OP,1,At("OS",SC1->C1_OP)-1))
						
						If STJ->(dbSeek(xFilial("STJ")+ cOPStj))
							aCols[nItem,nCntFor] := cOPStj
						Endif
					Endif
				EndIf
			   
	  		   RestArea(aAreaSTJ)
	  		   RestArea(aAreaSC1)
			Endif
		
		//Integração RM TOP x Protheus (Retenção/Dedução/Faturamento Direto)
		Case Type("lTOPDRFRM") <> "U" .And. lTOPDRFRM .And. Trim(aHeader[nCntFor,2]) == "D1_RETENCA" 
			aCols[nItem,nCntFor] := SC7->C7_RETENCA-SC7->C7_QUJERET
			
		Case Type("lTOPDRFRM") <> "U" .And. lTOPDRFRM .And. Trim(aHeader[nCntFor,2]) == "D1_DEDUCAO"
			aCols[nItem,nCntFor] := SC7->C7_DEDUCAO-SC7->C7_QUJEDED
			
		Case Type("lTOPDRFRM") <> "U" .And. lTOPDRFRM .And. Trim(aHeader[nCntFor,2]) == "D1_FATDIRE"
			aCols[nItem,nCntFor] := SC7->C7_FATDIRE-SC7->C7_QUJEFAT
			
		EndCase
	Next nCntFor
	FillCTBEnt("SC7",nItem)

	If !lMaFisFound
		aRateio[1] += xMoeda(SC7->C7_SEGURO ,SC7->C7_MOEDA,1,M->dDEmissao,,SC7->C7_TXMOEDA)
		aRateio[2] += xMoeda(SC7->C7_DESPESA,SC7->C7_MOEDA,1,M->dDEmissao,,SC7->C7_TXMOEDA)
		aRateio[3] += xMoeda(SC7->C7_VALFRE ,SC7->C7_MOEDA,1,M->dDEmissao,,SC7->C7_TXMOEDA)
	EndIf

	//Complementa o rateio da nota fiscal de saida com o rateio do pedido de compras
	If lRateioDE
		If Empty(aHeadSDE)
			dbSelectArea("SX3")
			SX3->(dbSetOrder(1))
			SX3->(DbSeek("SDE"))
			While SX3->(!EOF()) .And. SX3->X3_ARQUIVO == "SDE"
				IF X3Uso(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL .And. !"DE_CUSTO" $ SX3->X3_CAMPO
					AADD(aHeadSDE,{TRIM(x3Titulo()),;
						SX3->X3_CAMPO,;
						SX3->X3_PICTURE,;
						SX3->X3_TAMANHO,;
						SX3->X3_DECIMAL,;
						SX3->X3_VALID,;
						SX3->X3_USADO,;
						SX3->X3_TIPO,;
						SX3->X3_F3,;
						SX3->X3_CONTEXT } )
				EndIf
				SX3->(dbSkip())
			EndDo
			//Adiciona os campos de Alias e Recno ao aHeader para WalkThru
			ADHeadRec("SDE",aHeadSDE)	
		Endif

		cItemRat := IIF(cItem<>Nil,cItem,StrZero(nItem,Len(SD1->D1_ITEM)))
		RatPed2NF(aHeadSDE,@aColsSDE,cItemRat,nRecSC7)
	Endif

	// 1 - utilização a associação automática com o PMS
	// 2 - não utiliza a associação automática com o PMS
	// default: não utilizar a associação automática
	If IntePMS() .And. nPMSIPC == 1
		PMS103IPC(nItem)
	EndIf

	//Efetua a chamada dos pontos de entrada
	If ExistTemplate( "MT103IPC",,.T. ) .AND. HasTemplate("MT103IPC")  
		ExecTemplate( "MT103IPC", .F., .F.,{nItem})
	EndIf

	//Agroindustria
	If FindFunction("OGXUtlOrig") .And. OGXUtlOrig()  //Encontra a função
		If FindFunction("OGX205") //Encontra a função
			OGX205() // Executa a função
		EndIf
	EndIf

	If lMT103IPC
		ExecBlock( "MT103IPC", .F., .F.,{nItem})
	EndIf
	
	If lMT103RCC
		aColsSDE := ExecBlock( "MT103RCC", .F., .F.,{aHeadSDE,aColsSDE})
	EndIf
EndIf

//Quando ha TES no pedido de compra, deve-se recalcular os
//impostos carregados para verificar se nao ha novos impostos
//que devem ser calculados!
If lMaFisFound
	Do Case
	Case cA100For+cLoja <> SC7->C7_FORNECE+SC7->C7_LOJA
		MaFisLoad("IT_TES","",nItem)	
		MaFisAlt("IT_ALIQICM",0,nItem)
		MaFisAlt("IT_ALIQIPI",0,nItem)
		If Empty(SC7->C7_TES)
			MaFisAlt("IT_TES",RetFldProd(SB1->B1_COD,"B1_TE"),nItem)
		Else
			MaFisAlt("IT_TES",SC7->C7_TES,nItem)				
		EndIf
	Case Empty(SC7->C7_TES) .And. !Empty(RetFldProd(SB1->B1_COD,"B1_TE"))
		MaFisLoad("IT_TES","",nItem)
		MaFisAlt("IT_TES",RetFldProd(SB1->B1_COD,"B1_TE"),nItem)
	Case Empty(SC7->C7_TES) .And. Empty(RetFldProd(SB1->B1_COD,"B1_TE")) .And. nPosTes > 0
		MaFisLoad("IT_TES","",nItem)
		MaFisAlt("IT_TES",IF( aCols[nItem,nPosTes] == Nil,CriaVar("D1_TES"),aCols[nItem,nPosTes] ),nItem)
	Case !Empty(SC7->C7_TES)
		MaFisLoad("IT_TES","",nItem)
		MaFisAlt("IT_TES",SC7->C7_TES,nItem)
		If lAllPC .And. !lAltImpPreNf
			// Quando for Relacionar o Pedido a Nf ou preço unitário da Pré-Nf for igual ao Pedido, entra na Rotina
			// Caso Preço Unitário da Pré-Nf for divergente do pedido, prevalece o preço da Pré-Nf mesmo que a quantidade do pedido seja igual.
		    
		    If nPrUPreNf == Nil .Or. (nPrUPreNf-SC7->C7_PRECO) == 0  
				For nX := 1 To Len(aRefSc7)
					Do Case
					Case !("IT_BAS"$aRefSc7[nX][2] .Or. "IT_VAL"$aRefSc7[nX][2] .Or. "IT_ALIQ"$aRefSc7[nX][2])
						//Não fazer nada
					Case aRefSc7[nX][2] == "IT_VALIPI"
						MaFisAlt(aRefSc7[nX][2],xMoeda(SC7->C7_VALIPI,SC7->C7_MOEDA,1,M->dDEmissao,,SC7->C7_TXMOEDA,),nItem)
					Case aRefSc7[nX][2] == "IT_VALICM"
						MaFisAlt(aRefSc7[nX][2],xMoeda(SC7->C7_VALICM,SC7->C7_MOEDA,1,M->dDEmissao,,SC7->C7_TXMOEDA,),nItem)
					Case aRefSc7[nX][2] == "IT_VALMERC"
						MaFisAlt(aRefSc7[nX][2],xMoeda(SC7->C7_TOTAL,SC7->C7_MOEDA,1,M->dDEmissao,,SC7->C7_TXMOEDA,),nItem)
					Case aRefSc7[nX][2] == "IT_BASEICM"
						MaFisAlt(aRefSc7[nX][2],xMoeda(SC7->C7_BASEICM,SC7->C7_MOEDA,1,M->dDEmissao,,SC7->C7_TXMOEDA,),nItem)
					Case aRefSc7[nX][2] == "IT_BASEIPI"
						MaFisAlt(aRefSc7[nX][2],xMoeda(SC7->C7_BASEIPI,SC7->C7_MOEDA,1,M->dDEmissao,,SC7->C7_TXMOEDA,),nItem)
					OtherWise
						If !Empty(SC7->(FieldGet(FieldPos(aRefSc7[nX][1]))))
							MaFisAlt(aRefSc7[nX][2],SC7->(FieldGet(FieldPos(aRefSc7[nX][1]))),nItem)
						EndIf
					EndCase
				Next nX
			EndIf
		EndIf		
		If lTColab
			aCols[nItem,nPosBicm] := MaFisRet(nItem,"IT_BASEICM")
			aCols[nItem,nPosPicm] := MaFisRet(nItem,"IT_ALIQICM")
			aCols[nItem,nPosVicm] := MaFisRet(nItem,"IT_VALICM")
			aCols[nItem,nPosBipi] := MaFisRet(nItem,"IT_BASEIPI")
			aCols[nItem,nPosIpi]  := MaFisRet(nItem,"IT_ALIQIPI")
			aCols[nItem,nPosVipi] := MaFisRet(nItem,"IT_VALIPI")
		EndIf
	EndCase

	//Ponto de entrada para tratamentos diversos após o recalculo de
	//impostos carregados a partir da TES correspondente
	If lMT103IP2
		ExecBlock( "MT103IP2", .F., .F.,{nItem})
	EndIf
	
	MaFisToCols(aHeader,aCols,Len(aCols),"MT100")
	aColsD1 := acols //Atualização necessária para que, o Array do Lançamento da Apuração de ICMS tenha o mesmos itens do acols da Nota Fiscal de Entrada.
EndIf

RestArea(aAreaSB1)
RestArea(aAreaSF4)
RestArea(aAreaSC7)
RestArea(aArea)

Return .T.


//Static Function Debug

/*cCACertFile := GetNewPar("XM_CERTCA" ,"\certs\000001_ca.pem"  ,cFilAnt)
	cCertFile   := GetNewPar("XM_CERTCER","\certs\000001_cert.pem",cFilAnt)
	cKeyFile    := GetNewPar("XM_CERTKEY","\certs\000001_key.pem" ,cFilAnt)
	cKeyPwd     := GetNewPar("XM_CERTPSW",""		              ,cFilAnt)
	nVersion    := GetNewPar("XM_CERTPRO",0)
	nTimeO      := GetNewPar("XM_CERTTIM",120)
	nLote       := (GetNewPar("XM_LOTEMAN",0) + 1)
	cURL        := "http://localhost:8080/HFXMLMANIFESTO.apw?WSDL" 

	//Instância a classe, setando as parâmetrizações necessárias
	oWSdNfe := TWsdlManager():New()
	oWSdNfe:cSSLCACertFile := cCACertFile
	oWSdNfe:cSSLCertFile   := cCertFile
	oWSdNfe:cSSLKeyFile    := cKeyFile
	oWSdNfe:cSSLKeyPwd     := cKeyPwd
	oWSdNfe:nSSLVersion    := nVersion
	oWSdNfe:nTimeout       := nTimeO
	oWSdNfe:lSSLInsecure   := .T.

	aOps := {}
	aComplex := {}
	aSimple := {}

	xRet :=  oWSdNfe:ParseURL(cURL)

	if xRet== .F.
    	conOut("   realizando parse de url... erro: " + oWSdNfe:cError)
    	Return
  	else
    	conOut("   realizando parse de url... feito")
  	endif
  	conOut(chr(10) + chr(10))

	// LISTA AS OPERACÕES DISPONIVEIS
	conOut("   listando as operacões disponiveis...")
	aOps := oWSdNfe:ListOperations()
	if Len( aOps ) == 0
		conOut("   listando as operacões disponiveis... erro: " + oWSdNfe:cError)
		Return
	else
		varinfo( "aOps", aOps )
		conOut("   listando as operacões disponiveis... feito")
	endif
	conOut(chr(10) + chr(10))

	  // DEFINE UMA OPERACAO
	conOut("  setando operacao HFMANISFESTO...")
	xRet:= oWSdNfe:SetOperation( "HFMANISFESTO" )
	if xRet== .F.
		conOut("  setando operacao HFMANISFESTO... erro: " + oWSdNfe:cError)
		Return
	else
		conOut("  setando operacao HFMANISFESTO... feito")
	endif
	conOut(chr(10) + chr(10))
	
	// LISTA OS ELEMENTOS SIMPLES DA OPERACAO
	conOut("   listando elementos simples da operacao...")
	aSimple := oWSdNfe:SimpleInput()
	//varinfo( "aSimple", aSimple )
	conOut("   listando elementos simples da operacao... feito")
	conOut(chr(10) + chr(10))

	//curl
	nPos := aScan( aSimple, {|aVet| aVet[2] == "CCURL" })
	xRet := oWSdNfe:SetValue( aSimple[nPos][1], cURL )

	//cIdent
	nPos := aScan( aSimple, {|aVet| aVet[2] == "CIDENT" })
	xRet := oWSdNfe:SetValue( aSimple[nPos][1], cIdEnt )

	//cLote
	nPos := aScan( aSimple, {|aVet| aVet[2] == "CLOTE" })
	xRet := oWSdNfe:SetValue( aSimple[nPos][1], strzero(nLote,15,0) )

	//cAmbiente
	nPos := aScan( aSimple, {|aVet| aVet[2] == "CAMBIENTE" })
	xRet := oWSdNfe:SetValue( aSimple[nPos][1], cAmb)

	//cVersaodados
	nPos := aScan( aSimple, {|aVet| aVet[2] == "CVERSAODADOS" })
	xRet := oWSdNfe:SetValue( aSimple[nPos][1], cVerLayEven)

	//CCUF
	nPos := aScan( aSimple, {|aVet| aVet[2] == "CCUF" })
	xRet := oWSdNfe:SetValue( aSimple[nPos][1], "91")

	//CHORAVERAO
	nPos := aScan( aSimple, {|aVet| aVet[2] == "CHORAVERAO" })
	xRet := oWSdNfe:SetValue( aSimple[nPos][1], cHrVerao)

	//CHORARIO
	nPos := aScan( aSimple, {|aVet| aVet[2] == "CHORARIO" })
	xRet := oWSdNfe:SetValue( aSimple[nPos][1], cHorario)

	//CCNPJ  
	nPos := aScan( aSimple, {|aVet| aVet[2] == "CCNPJ" })
	xRet := oWSdNfe:SetValue( aSimple[nPos][1], cCnpj)

	//CCHSTR  
	nPos := aScan( aSimple, {|aVet| aVet[2] == "CCHSTR" })
	xRet := oWSdNfe:SetValue( aSimple[nPos][1], cChave)

	//CEVSTR  
	nPos := aScan( aSimple, {|aVet| aVet[2] == "CEVSTR" })
	xRet := oWSdNfe:SetValue( aSimple[nPos][1], cEvent)

	//CXJUST 
	nPos := aScan( aSimple, {|aVet| aVet[2] == "CXJUST" })
	xRet := oWSdNfe:SetValue( aSimple[nPos][1], cJus)

	//CDTHREVEN 
	nPos := aScan( aSimple, {|aVet| aVet[2] == "CDTHREVEN" })
	xRet := oWSdNfe:SetValue( aSimple[nPos][1], U_HFDTTIME( cHrVerao, cHorario, nAtraso ))

	// RECEBE E IMPRIME A MENSAGEM FORMATADA PARA ENVIO
	conOut("   pegando mensagem formatada para envio...")
	conout( oWSdNfe:GetSoapMsg() )
	conOut("   pegando mensagem formatada para envio... feito")
	conOut(chr(10) + chr(10))
	
	// ENVIA A MENSAGEM PARA O SERVIDOR
	/*conOut("   enviando mensagem para o servidor...")
	xRet:= oWSdNfe:SendSoapMsg()
	if xRet== .F.
		conOut("   enviando mensagem para o servidor... erro: " + oWSdNfe:cError )
		Return
	else
		conOut("   enviando mensagem para o servidor... feito")
	endif
	conOut(chr(10) + chr(10))
	
	// RECEBE A MENSAGEM DE RESPOSTA
	conOut("   pegando a mensagem de resposta do servidor...")
	conout( oWSdNfe:GetSoapResponse() )
	conOut("   pegando a mensagem de resposta do servidor... feito")
	conOut(chr(10) + chr(10))*/

//Return


Static Function __Dummy(lRecursa) //warning W0010 Static Function <?> never called
    lRecursa := .F.
    IF (lRecursa)
        __Dummy(.F.)
        U_AMAPC()
        U_H20VISUPC()
        U_HFXMLTAG()
        U_HFXMLPED()
        U_MANIFXML()
        U_HFXMLCPS()
        U_TELMAN()
        U_HFMANCHV()
        U_AXMLPRPC()
        U_HFXMLVTL()
        U_X020VLD()
        U_HFVLPR()
        U_HFCKXML1()
        U_HFCKXML2()
        U_HFPRCXML()
        U_HF20ZBE()
        U_HFDGXML()
        U_HfLogLin()
	EndIF
Return(lRecursa)
//-----------------------------------------------------------------------
/*/{Protheus.doc} MontaMonitor()
Montagem da Dialog 'Monitorar'

@author Natalia Sartori
@since 04.07.2012
@version 1.00

@param cAlias, nReg, nOpc, cMarca, lInverte
/*/
//----------------------------------------------------------------------- 
User Function HFMntMon(cEve)
//Local aPerg		:= {}	
Local aChaves	:= {}
Local aListBox 	:= {}
//Local aListChv	:= {}
//Local aParam	:={Space(3),Space(09),Space(09),Space(01)}
Local aSize		:= MsAdvSize()
Local aObjects	:= {}
Local aInfo		:= {}
Local aPosObj	:= {}
Local aArea		:= GetArea()
//Local cParManif := SM0->M0_CODIGO+SM0->M0_CODFIL+"MonitManif"
//Local cEventMon := ""
//Local cWhere	:= ""
//Local cAliasTemp:= GetNextAlias()
Local cChvIni	:= ""
Local cChvFin	:= ""
Local cCodEve	:= cEve
//Local nCombo	
//Local cChaves	:= ""
//Local nCont := 0         
//Local nTent		:= 0

//Local bBloco
//Local oWS
Local oDlg
Local oListBox
Local oBtn1
Local oBtn2
Local oBtn3
Local oBtn4
//Local lUsaColab := .F.

Private aCodEve	:= {}

aChaves := U_getChaves(@cCodEve)
RestArea(aArea)

aListBox := U_getEventos(cChvIni,cChvFin,cCodEve,aChaves)

If len(aListBox) > 0

	AAdd( aObjects, { 100, 100, .t., .t. } )
	AAdd( aObjects, { 100, 015, .t., .f. } )
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects )

	DEFINE FONT oBold BOLD	
	DEFINE MSDIALOG oDlg TITLE "Monitoramento da Manifestação" From aSize[7],0 to aSize[6],aSize[5] OF oMainWnd PIXEL
																								//607,365
	@aPosObj[1,1],aPosObj[1,2] LISTBOX oListBox 	FIELDS HEADER "","Protocolo","Chave","Tipo do Evento","Mensagem" ; 
		SIZE aPosObj[1,4]-aPosObj[1,2],aPosObj[1,3]-aPosObj[1,1] PIXEL	
			oListBox:SetArray(aListBox)
			oListBox:bLine:={||	{	aListBox[oListBox:nAt][01],;
									Alltrim(aListBox[oListBox:nAt][02]),;
									Alltrim(aListBox[oListBox:nAt][03]),;
									Alltrim(aListBox[oListBox:nAt][04]),;
									Alltrim(aListBox[oListBox:nAt][05])}}

	@ aPosObj[2,1],aPosObj[2,4]-080 BUTTON oBtn1 PROMPT "Refresh"	ACTION (aChaves := {}, aChaves := U_getChaves(@cCodEve), aListBox := U_getEventos(cChvIni,cChvFin,cCodEve,aChaves) ,oListBox:nAt := 1,IIF(Empty(aListBox),oDlg:End(),oListBox:Refresh())) OF oDlg PIXEL SIZE 035,011 //"Refresh"
	@ aPosObj[2,1],aPosObj[2,4]-040 BUTTON oBtn2 PROMPT "Sair"		ACTION oDlg:End() OF oDlg PIXEL SIZE 035,011 //Sair
	@ aPosObj[2,1],aPosObj[2,4]-120 BUTTON oBtn3 PROMPT "Legenda"	ACTION U_btLegMonit() OF oDlg PIXEL SIZE 035,011 
	@ aPosObj[2,1],aPosObj[2,4]-160 BUTTON oBtn4 PROMPT "Vis. XML"	ACTION U_btVisuXml() OF oDlg PIXEL SIZE 035,011 

	ACTIVATE MSDIALOG oDLg CENTERED
Else
	//msgInfo("Ainda não há dados na "+xZBE) //Mensagem para evitar error.log
	MsgInfo("Chave Não Manifestada, Tempo Limite Esgotado...Tente Novamente em 1h") //FR - 29/06/2021
EndIf	
	


Return 

User Function getChaves(cCodEve)
	local aChaves		:= {}
	local cAliasTemp	:= GetNextAlias()
	local cQuery		:= ""
		
	cQuery += "Select "+xZBZ+"_CHAVE AS CHAVE "
	cQuery += "From "+RetSqlName(xZBZ)+" "
	cQuery += "Where "+xZBZ+"_FILIAL = "+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL")))+" And "
	cQuery += xZBZ+"_NOTA = '"+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA")))+"' And " 
	cQuery += "( "+xZBZ+"_SERIE = '"+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE")))+"' Or  "+xZBZ+"_SERIE = '"+strzero(val((xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE")))),3)+"') And "
	cQuery += "D_E_L_E_T_ = ' ' " 

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTemp,.T.,.T.)

	(cAliasTemp)->(dbGotop())
	
	While (cAliasTemp)->(!EOF())
		aadd(aChaves, (cAliasTemp)->CHAVE )
		(cAliasTemp)->(DbSkip())
	endDo
	
	(cAliasTemp)->(dbCloseArea())
return aChaves

User function getEventos(cChvIni, cChvFin, cCodEve, aChaves)
		
	local nW		:= 0
	local nY		:= 0
	local cEventMon	:= "MonitEven"
	local aListChv	:= {}
	local aListBox	:= {}
	local cChaves	:= ""
	local nCont		:= 0

	cEventMon	:= "MonitEven"
	aListChv	:= {}
	aListBox	:= {}
	cChaves		:= ""
	nCont		:= 0

	For nW := 1 To Len( aChaves )
		++nCont
		cChaves += IIf(!Empty(cChaves),",","") + "'" + aChaves[nW] + "'" 				

		If nCont >= 50
			aListChv := U_MonitEven(cChvIni,cChvFin,cCodEve,,cChaves)

			For nY := 1 To Len( aListChv )
				AADD( aListBox, aListChv[nY] )
			Next

			nCont		:= 0
			cChaves		:= ""
			aListChv	:= {}						
		Endif
	Next nW

	If nCont > 0
		aListChv := U_MonitEven(cChvIni,cChvFin,cCodEve,,cChaves)
		
		For nY := 1 To Len( aListChv )
			AADD( aListBox, aListChv[nY] )
		Next
		
		cChaves := ""						
	Endif

return aListBox

/* Função do padrão que não vai existir por enquanto, somente quado houver manifestação em lote
User Function MonitEven(cChvIni,cChvFin,cCodEve,cModelo,cChaves)

Local aListBox  := {}
Local cIdEnt    := RetIdEnti()
Local cOpcUpd   := ""
Local cURL      := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local lOk       := .T.
Local nX        := 0
Local oNo       := LoadBitMap(GetResources(), "DISABLE")
Local oOk       := LoadBitMap(GetResources(), "ENABLE")
Private oDados
Private oWS     := Nil
Private oXmlCCe
Default cChaves := ""
Default cModelo := ""

// Executa o metodo NfeRetornaEvento()
oWS:= WSNFeSBRA():New()
oWS:cUSERTOKEN	:= "TOTVS"
oWS:cID_ENT		:= cIdEnt 
oWS:_URL		:= AllTrim(cURL)+"/NFeSBRA.apw"
oWS:cEVENTO		:= cCodEve
oWS:cCHVINICIAL	:= cChvIni
oWS:cCHVFINAL	:= cChvFin
oWS:cCHAVES		:= cChaves
lOk:=oWS:NFEMONITORLOTEEVENTO()

If lOk

	// Tratamento do retorno do evento
	If Type("oWS:oWsNfemonitorLoteEventoResult:OWSNfeMonitorEvento") <> "U" 
		
		If Valtype(oWS:oWsNfemonitorLoteEventoResult:OWSNfeMonitorEvento) <> "A"
			aMonitor := {oWS:oWsNfemonitorLoteEventoResult:OWSNfeMonitorEvento}
		Else
			aMonitor := oWS:oWsNfemonitorLoteEventoResult:OWSNfeMonitorEvento
		EndIF

		For nX:=1 To Len(aMonitor)                                          					
			AADD( aListBox, {	If(aMonitor[nX]:nStatus <> 6 .And. aMonitor[nX]:nStatus <> 7 ,oNo,oOk),;
								If(aMonitor[nX]:nProtocolo <> 0 ,Alltrim(Str(aMonitor[nX]:nProtocolo)),""),;
								aMonitor[nX]:cId_Evento,;
								Alltrim(Str(aMonitor[nX]:nAmbiente)),;	
								Alltrim(Str(aMonitor[nX]:nStatus)),;
								If(!Empty(aMonitor[nX]:cCMotEven),Alltrim(aMonitor[nX]:cCMotEven),Alltrim(aMonitor[nX]:cMensagem)),;
								"" }) //XML manter devido ao TOTVS Colaboração.
			//Atualizacao do Status do registro de saida
			cOpcUpd := "3"					
			
			If aListBox[nX][5]	== "3" .Or. aListBox[nX][5] == "5"					
				cOpcUpd :=	"4"  //Evento rejeitado +msg rejeiçao					
			ElseIf aListBox[nX][5] == "6"  
				cOpcUpd := "3"  //Evento vinculado com sucesso
			ElseIf aListBox[nX][5] == "1"
				cOpcUpd := "2"  //Envio de Evento realizado - Aguardando processamento
			EndIF

			cChave:= Substr(aMonitor[nX]:cId_Evento,9,44)
			
			U_AtuCodeEve( cChave, cOpcUpd, cCodEve, cModelo, aListBox[nX][4], cIdEnt, cUrl )
			
		Next       

	EndIF

EndIf

Return aListBox 
*/

User Function MonitEven(cChvIni,cChvFin,cCodEve,cModelo,cChaves)

	local cAliasTemp	:= GetNextAlias()
	local cQuery		:= ""
	Local aListBox  := {}
	Local oNo       := LoadBitMap(GetResources(), "DISABLE")
	Local oOk       := LoadBitMap(GetResources(), "ENABLE")
	Local cTpEve	:= ""
		
	cQuery += "Select "+xZBE+"_PROT as PROT, "+xZBE+"_TPEVE as TPEVE, "+xZBE+"_DESC as DESCRI "
	cQuery += "From "+RetSqlName(xZBE)+" "
	cQuery += "Where "+xZBE+"_FILIAL = "+xFilial(xZBE)+" And "
	cQuery += xZBE+"_CHAVE = '"+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE")))+"' And " 
	cQuery += "D_E_L_E_T_ = ' ' " 

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTemp,.T.,.T.)

	(cAliasTemp)->(dbGotop())
	

	While (cAliasTemp)->(!EOF())

		Do Case
			Case (cAliasTemp)->TPEVE = "210200"
				cTpEve := (cAliasTemp)->TPEVE+" - Confirmação da operação"					
			Case (cAliasTemp)->TPEVE = "210210"
				cTpEve := (cAliasTemp)->TPEVE+" - Ciência da operação"
			Case (cAliasTemp)->TPEVE = "210220"
				cTpEve := (cAliasTemp)->TPEVE+" - Desconhecimento da Operação"
			Case (cAliasTemp)->TPEVE = "210240"
				cTpEve := (cAliasTemp)->TPEVE+" - Operação Não Realizada"
		EndCase

					AADD( aListBox, {	If(Empty((cAliasTemp)->PROT),oNo,oOk),;
								(cAliasTemp)->PROT,;
								(xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))),;
								cTpEve,;
								(cAliasTemp)->DESCRI})
		
		(cAliasTemp)->(DbSkip())
   

	End

	(cAliasTemp)->(dbCloseArea())


Return aListBox 


User Function AtuCodeEve( cChave, cOpcUpd, cCodEve, cModelo, cAmbiente, cIdEnt, cUrl )

Local aArea	:= GetArea()

If cModelo <> '58' //MDFe

	U_HFMntMan({cChave}, cAmbiente, cIdEnt, cURL + "/MANIFESTACAODESTINATARIO.apw")

EndIf	

RestArea(aArea)

Return

User function getSitConf(cCodEvento)
	
	local cSitConf := "0"

	cCodEvento := alltrim(cCodEvento)
		
	do case
		case cCodEvento == "210200"
			cSitConf := "1"
		case cCodEvento == "210210"
			cSitConf := "4"
		case cCodEvento == "210220"
			cSitConf := "2"
		case cCodEvento == "210240"
			cSitConf := "3"									
	endCase	
	
return cSitConf

User Function HFMntMan(aChave,cAmbiente,cIdEnt,cUrl,lJob)

Local cChave		:= ""
Local cCNPJEmit	:= ""
Local cIeEmit		:= ""
Local cNomeEmit	:= ""
Local cSitConf	:= ""	
Local cSituacao	:= ""
Local cDesResp	:= ""
Local cDesCod		:= ""

Local dDtEmi		:= CTOD("  /  /  ")
Local dDtRec		:= CTOD("  /  /  ")

Local nValDoc		:= 0
Local nZ := 0
Local nY := 0

Local aMonDoc	:={}

Private oWS		:= Nil

Default lJob	:= .F.

oWs :=WSMANIFESTACAODESTINATARIO():New()
oWs:cUserToken   := "TOTVS"
oWs:cIDENT	     := cIdEnt
oWs:cAMBIENTE	 := cAmbiente     
oWs:OWSMONDADOS:OWSDOCUMENTOS  := MANIFESTACAODESTINATARIO_ARRAYOFMONDOCUMENTO():New()
For nY := 1 to Len(aChave)
	aadd(oWs:OWSMONDADOS:OWSDOCUMENTOS:OWSMONDOCUMENTO,MANIFESTACAODESTINATARIO_MONDOCUMENTO():New())
	oWs:OWSMONDADOS:OWSDOCUMENTOS:OWSMONDOCUMENTO[nY]:CCHAVE := aChave[nY]
Next
oWs:_URL         := AllTrim(cURL) //+"/MANIFESTACAODESTINATARIO.apw" 

If oWs:MONITORARDOCUMENTOS()
	If Type ("oWs:OWSMONITORARDOCUMENTOSRESULT:OWSDOCUMENTOS:OWSMONDOCUMENTORET") <> "U"
		If Type ("oWs:OWSMONITORARDOCUMENTOSRESULT:OWSDOCUMENTOS:OWSMONDOCUMENTORET") == "A"
			aMonDoc := oWs:OWSMONITORARDOCUMENTOSRESULT:OWSDOCUMENTOS:OWSMONDOCUMENTORET
		Else 
			aMonDoc := {oWs:OWSMONITORARDOCUMENTOSRESULT:OWSDOCUMENTOS:OWSMONDOCUMENTORET}
		EndIf
	EndIF
	For nZ :=1 to Len(aMonDoc)
		If Type(aMonDoc[nZ]:CCHAVE) <> "U"
			cChave := aMonDoc[nZ]:CCHAVE
			
			cCNPJEmit	:= Iif(!Empty(Alltrim(aMonDoc[nZ]:CEMITENTECNPJ)),Alltrim(aMonDoc[nZ]:CEMITENTECNPJ),Alltrim(aMonDoc[nZ]:CEMITENTECPF))
			cIeEmit	:= AllTrim(aMonDoc[nZ]:CEMITENTEIE)
			cNomeEmit	:= Alltrim(aMonDoc[nZ]:CEMITENTENOME)
			cSitConf	:= aMonDoc[nZ]:CSITUACAOCONFIRMACAO
			cSituacao	:= aMonDoc[nZ]:CSITUACAO
			cDesResp	:= Alltrim(aMonDoc[nZ]:CRESPOSTADESCRICAO)
			cDesCod	:= aMonDoc[nZ]:CRESPOSTASTATUS
			
			dDtEmi		:= StoD(StrTran(aMonDoc[nZ]:CDATAEMISSAO,"-",""))
			dDtRec		:= StoD(StrTran(aMonDoc[nZ]:CDATAAUTORIZACAO,"-",""))
			
			nValDoc		:= aMonDoc[nZ]:NVALORTOTAL
						
			U_MonAtuDados(cChave,cCNPJEmit,cIeEmit,cNomeEmit,cSitConf,cSituacao,cDesResp,cDesCod,dDtEmi,dDtRec,nValDoc)
							
		EndIf	
	Next
EndIf

oWs := Nil
DelClassIntf()	

Return 

User Function MonAtuDados(cChave,cCNPJEmit,cIeEmit,cNomeEmit,cSitConf,cSituacao,cDesResp,cDesCod,dDtEmi,dDtRec,nValDoc)
				
(xZBE)->(DbsetOrder(2))
If (xZBE)->(DbSeek(cChave))
	RecLock(xZBE,.F.)
	(xZBE)->(FieldPut(FieldPos(xZBE_+"STATUS"), cSitConf ))
	(xZBE)->(FieldPut(FieldPos(xZBE_+"TPEVE"), cDesCod ))
	(xZBE)->(FieldPut(FieldPos(xZBE_+"DHAUT"), dDtEmi ))
	(xZBE)->(FieldPut(FieldPos(xZBE_+"DTRECB"), dDtRec ))
	(xZBE)->(MsUnLock())
EndIf

//Inclusão para voltar a atualizar a manifestação na ZBZ - NA (14/12/2021)
(xZBZ)->(DbsetOrder(3))
If (xZBZ)->(DbSeek(cChave))
	RecLock(xZBZ,.F.)
	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"MANIF"), "1" ))
	(xZBZ)->(MsUnLock())
EndIf
return nil

User Function btLegMonit()

Local aLegenda:= {}

AADD(aLegenda, {"ENABLE"		,"Evento vinculado com sucesso"})//"Evento vinculado com sucesso"
AADD(aLegenda, {"DISABLE"		,"Evento não vinculado"})//"Evento não vinculado"

BrwLegenda(cCadastro,"Legenda",aLegenda) 

Return

User Function btVisuXml(cIdEvento,cXml)
	
	If Empty((xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML"))))
		Aviso("Xml Resumo",DecodeUtf8((xZBZ)->(FieldGet(FieldPos(xZBZ_+"XMLRES")))),{"OK"},3)
	Else
		Aviso("Xml Completo",DecodeUtf8((xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML")))),{"OK"},3)
	EndIf

Return 
//------------------------------------------------------------------------------------//
//FR - 06/08/2020 - Procura se existe amarração para o produto do XML - na SA5 ou ZB5
//------------------------------------------------------------------------------------//
*************************************************
User Function fAchamarra(cProdXML,cA100For,cLoja)
*************************************************
Local cQuery 	:= "" 
Local cProdRet 	:= ""

//1o. tenta na SA5
cQuery := " SELECT A5_FORNECE, A5_LOJA, A5_CODPRF, A5_PRODUTO, A5_NOMPROD, B1_COD, B1_DESC " 	+ CRLF

cQuery += " FROM " + RetSqlName("SA5") + " SA5 "		   										+ CRLF

cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 ON A5_PRODUTO = B1_COD "				 	+ CRLF
cQuery += " AND SB1.D_E_L_E_T_ <> '*' "															+ CRLF

cQuery += " WHERE A5_CODPRF = '" + Alltrim(cProdXML) + "' " + CRLF
cQuery += " AND   A5_FORNECE= '" + Alltrim(cA100For) + "' " + CRLF
cQuery += " AND   A5_LOJA   = '" + Alltrim(cLoja)    + "' " + CRLF
cQuery += " AND   SA5.D_E_L_E_T_ <> '*' "					+ CRLF

If Select("TMPAMR") > 0
	dbSelectArea("TMPAMR")
    TMPAMR->(dbCloseArea())
EndIf

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPAMR", .T., .F. )
DbSelectArea("TMPAMR")
DbGoTop()
If TMPAMR->(!Eof())

	cProdRet := Alltrim(TMPAMR->B1_COD)
		
Else		//se não encontrou dados, tenta na ZB5

	cQuery := " SELECT " + xZB5_+"FORNEC, "+ xZB5_+"LOJFOR, "+ xZB5_+"PRODFO, "+ xZB5_+"PRODFI, " + xZB5_+"DESCPR, B1_COD, B1_DESC " 	+ CRLF

	cQuery += " FROM " + RetSqlName(xZB5) + " ZB5 "													+ CRLF
	
	cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 ON " + xZB5_+"PRODFI = B1_COD "	 		+ CRLF   //ZB5_PRODFI -> nosso código de produto (SB1)
	cQuery += " AND SB1.D_E_L_E_T_ <> '*' "															+ CRLF
	
	cQuery += " WHERE " + xZB5_+"PRODFO = '" + Alltrim(cProdXML) + "' " 	+ CRLF      //ZB5_PRODFO -> Código produto do fornecedor
	cQuery += " AND   " + xZB5_+"FORNEC = '" + Alltrim(cA100For) + "' " 	+ CRLF
	cQuery += " AND   " + xZB5_+"LOJFOR = '" + Alltrim(cLoja)    + "' " 	+ CRLF
	cQuery += " AND   ZB5.D_E_L_E_T_ <> '*' "					   			+ CRLF
	
	If Select("TMPAMR") > 0
		dbSelectArea("TMPAMR")
	    TMPAMR->(dbCloseArea())
	EndIf

	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPAMR", .T., .F. )
	DbSelectArea("TMPAMR")
	DbGoTop()
	If TMPAMR->(!Eof())
		cProdRet := Alltrim(TMPAMR->B1_COD)
	Else         //se não encontrou, tenta na ZBC
	
		cQuery := " SELECT " + xZBC_+"CODFOR, "+ xZBC_+"LOJFOR, "+ xZBC_+"PROD ZBCPROD, " + xZBC_+"DESCPR " 	+ CRLF	
		cQuery += " FROM  " + RetSqlName(xZBC) + " ZBC "													+ CRLF
		cQuery += " WHERE " + xZBC_+"CODFOR = '" + Alltrim(cA100For) + "' " 	+ CRLF
		cQuery += " AND   " + xZBC_+"LOJFOR = '" + Alltrim(cLoja)    + "' " 	+ CRLF
		cQuery += " AND   ZBC.D_E_L_E_T_ <> '*' "					   			+ CRLF
		
		If Select("TMPAMR") > 0
			dbSelectArea("TMPAMR")
		    TMPAMR->(dbCloseArea())
		EndIf
	
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPAMR", .T., .F. )
		DbSelectArea("TMPAMR")
		DbGoTop()
		If TMPAMR->(!Eof())
			cProdRet := Alltrim(TMPAMR->ZBCPROD)
		Endif
		dbSelectArea("TMPAMR")
		TMPAMR->(dbCloseArea())
			
	Endif
	
Endif

If Empty(cProdRet)
	If !IsBlind()
		//MsgAlert("Amarração Para O Fornecedor Não Localizada. Por Favor, Cadastrar.")
	Endif
Endif

Return(cProdRet)		//retorna o código do produto da amarração encontrada (SA5 ou ZB5)

//--------------------------------------------------------------------------------------------------------------//
//FR - 06/08/2020 - verifica se o pedido selecionado pode atender por completo a pré-nf / nf
//--------------------------------------------------------------------------------------------------------------//
**************************************************************************************************************
User Function fPCAtende(aIteXML,aPedXML,aF4For,cA100For,cLoja,lConsMedic,lNfMedic,lPCXMLAtend,lValid)
**************************************************************************************************************
Local lAtende 		:= .F.
Local aPedidos 		:= {}
Local nPos     		:= 0
Local nSldped  		:= 0
Local fr       		:= 0
Local rf			:= 0
Local cProdXml 		:= ""
Local cProdSB1 		:= ""
Local cProdAnt    	:= ""
Local cPedX  		:= ""
Local cSeparadores	:= GetNewPAr("XM_SEPARAD","|,*,/,-")
Local y := 0
Local lContinua     := .F.
//Local nQuantosPC    := 0
							
If aPedXML <> NIL .and. Len(aPedXML) > 0      //VALIDA O PEDIDO QUE VEM NO XML - confronta com a base do cliente se este pedido é válido e tem saldo
	
	ASORT( aPedXML, , , { | x,y | x[3] + x[1] < y[3] + y[1] } ) //ordena por produto + pedido 
	If lConsMedic .And. lNfMedic
		ASORT( aF4For , , , { | x,y | x[6] < y[6] } )
	Else
		ASORT( aF4For , , , { | x,y | x[3] < y[3] } )
	Endif
					
	//FR - efetua a "marcação" [X] Automática no array aF4For
	aPedidos 	:= {}
	nPos     	:= 0
	nSldped  	:= 0
	fr       	:= 0
	lAtende		:= .T.
	cProdXml 	:= ""
	cProdSB1 	:= ""
	cProdAnt    := ""
	cSeparadores:= GetNewPAr("XM_SEPARAD","|,*,/,-")
 
	If !lValid

		//-----------------------------------------------------//				
		//caso a seleção por item de pedido esteja habilitada: 
		//-----------------------------------------------------//
		lAtende := .F.  //qdo encontrar o pedido e ver que o saldo atende, essa variável ficará .T.
		If GetNewPAr("XM_XPEDXML","1") == "4"
			lContinua := .F.		

			For rf := 1 to Len(aF4For)

				lContinua := .F.

				If lConsMedic .And. lNfMedic
					//verifica se o pedido que tá dentro do aF4For é válido (tem saldo que atenda a qtd do xml)
					For fr := 1 to Len(aPedXml)
						//nPos := AScan(aPedXml,{ |x| Alltrim(x[6]) == Alltrim(aPedXML[fr][1]) } )
						If !Empty(aPedXml[fr,1])

							If aF4For[rf,6] $ aPedXml[fr,1] //se o pedido trazido pela query tá contido no pedido do xml
								lContinua := .T.
								DbSelectArea("SC7")
								If SC7->(FieldPos("C7_XPEDIDO")) > 0
									If aPedXml[fr,4] <= aF4For[rf,16]  //se a qtde menor igual ao saldo do pedido, marca .T.
										//FR - 04/05/2023 - SOLICITADO POR VYDENCE NÃO TRAZER PC MARCADO
										If GetNewPar("XM_PCMARK" , "S") == "S"  //SE O PARÂMETRO TÁ ATIVADO PRA TRAZER OS PC's MARCADOS [X]
																				//esse parâmetro está na tela F12 "Traz PC Marcado"
											aF4For[rf,1] := .T.
										Endif 
									Endif 
								Else
									If aPedXml[fr,4] <= aF4For[rf,15]  //se a qtde menor igual ao saldo do pedido, marca .T.
										If GetNewPar("XM_PCMARK" , "S") == "S" //SE O PARÂMETRO TÁ ATIVADO PRA TRAZER OS PC's MARCADOS [X]
																				//esse parâmetro está na tela F12 "Traz PC Marcado"
											aF4For[rf,1] := .T.
										Endif 
									Endif 
								Endif

							Endif
						Else //se a tag do pedido estiver vazia, aí vai pelo pedido que puxou com saldo mesmo
							lContinua := .T.
						Endif 
					Next 
				Else
					//verifica se o pedido que tá dentro do aF4For é válido (tem saldo que atenda a qtd do xml)
					For fr := 1 to Len(aPedXml)
						//nPos := AScan(aPedXml,{ |x| Alltrim(x[6]) == Alltrim(aPedXML[fr][1]) } )
						If !Empty(aPedXml[fr,1])
							If aF4For[rf,3] $ aPedXml[fr,1]	//se o pedido trazido pela query tá contido no pedido do xml
								
								lContinua := .T.
								DbSelectArea("SC7")
								If SC7->(FieldPos("C7_XPEDIDO")) > 0						
									If aPedXml[fr,4] <= aF4For[rf,13]  //se a qtde menor igual ao saldo do pedido, marca .T.
										If GetNewPar("XM_PCMARK" , "S") == "S"
											aF4For[rf,1] := .T.
										Endif 
									Endif
								Else
									If aPedXml[fr,4] <= aF4For[rf,12]  //se a qtde menor igual ao saldo do pedido, marca .T.
										If GetNewPar("XM_PCMARK" , "S") == "S"
											aF4For[rf,1] := .T.
										Endif 
									Endif
								Endif

							Endif
						Else 	//se a tag do pedido estiver vazia, aí vai pelo pedido que puxou com saldo mesmo
							lContinua := .T.
						Endif 
					Next 
				Endif
				
				/*
				If lContinua

					DbSelectArea("SC7")

					//Verifica saldo do pedido
					
					If lConsMedic .And. lNfMedic
						If SC7->(FieldPos("C7_XPEDIDO")) > 0
							If aF4For[rf,15] <= aF4For[rf,16]  //se a qtde menor igual ao saldo do pedido, marca .T.
								aF4For[rf,1] := .T.
							Endif 
						Else
							If aF4For[rf,14] <= aF4For[rf,15]  //se a qtde menor igual ao saldo do pedido, marca .T.
								aF4For[rf,1] := .T.
							Endif 
						Endif
					Else
						If SC7->(FieldPos("C7_XPEDIDO")) > 0						
							If aF4For[rf,12] <= aF4For[rf,13]  //se a qtde menor igual ao saldo do pedido, marca .T.
								aF4For[rf,1] := .T.
							Endif
						Else
							If aF4For[rf,11] <= aF4For[rf,12]  //se a qtde menor igual ao saldo do pedido, marca .T.
								aF4For[rf,1] := .T.
							Endif
						Endif
					Endif
						
				Endif
				*/
			Next	//For rf := 1 to Len(aF4For)

		Else	//If GetNewPAr("XM_XPEDXML","1") == "4"
			//-----------------------------------------------------//				
			//caso a seleção é por pedido cheio e não por item 
			//-----------------------------------------------------//
			For fr := 1 to Len(aPedXML)						
				//FR - Acha Amarra
				cProdXml := aPedXML[fr][3]
				cProdSB1 := U_fAchamarra(cProdXML,cA100For,cLoja)
				nSldped	 := 0
				cPedX    := ""
				nTam     := 0
				y 		 := 0
					
				If !Empty(cProdSB1)
					//------------------------------------------------//
					//procura pelo número do pedido do XML no aF4For:
					//------------------------------------------------//
					If Len(Alltrim(aPedXML[fr][1])) <= 6     //se a tag do pedido no xml contem apenas um pedido					
						If lConsMedic .And. lNfMedic
							nPos := AScan(aF4For,{ |x| Alltrim(x[6]) == Alltrim(aPedXML[fr][1]) } )
						Else
							nPos := AScan(aF4For,{ |x| Alltrim(x[3]) == Alltrim(aPedXML[fr][1]) } )
						Endif
										
						If nPos > 0
							cPedX := Alltrim(aPedXML[fr][1])
						Endif							
					Else							//se a tag pedido no xml contém vários pedidos, ex: 020236/000027								
													//for pra encontrar a posição do aF4For que está contida a tag do ped. xml
						For y := 1 to Len(aF4For)								
							If !aF4For[y][1]
								If lConsMedic .And. lNfMedic								
									If Alltrim(aF4For[y][6]) $ Alltrim(aPedXML[fr][1])
										nPos := y
									Endif
								Else								
									If Alltrim(aF4For[y][3]) $ Alltrim(aPedXML[fr][1])
										nPos := y
									Endif
								Endif
							Endif		               		
						Next
										
						If nPos > 0							
							For rf := 1 to Len(aPedXML[fr][1]) 									
								If nTam < 6 .and. !Substr(aPedXML[fr][1],rf,1) $ cSeparadores
									cPedX += Substr(aPedXML[fr][1],rf,1)
									nTam++											
								Else
									cPedX += "','"		//insere separador
									nTam  := 0
								Endif										
							Next									
						Endif								
					Endif
									
					//---------------------------------------------------//
					//verifica saldo do pedido x produto
					//---------------------------------------------------//
					If nPos > 0  	//se encontrou o pedido do XML no SC7

						//Verifica saldo do pedido
						If cProdSB1 != cProdAnt								
							nSldped  := U_fVerSldC7( Substr(cPedX,1,6) , cProdSB1,cA100For,cLoja) 		//sendo um produto diferente do anterior, atribui o saldo novo
							cProdAnt := cProdSB1
						Else
							nSldped += U_fVerSldC7(cPedX,cProdSB1,cA100For,cLoja)    	//sendo o mesmo produto que o anterior, acumula o saldo
						Endif																
											
						If nSldped >= aPedXml[fr][4]  	//FR - se o saldo do pedido na SC7 atende a qtde pedida no XML?																
							lAtende := .T.									
						Else								
							lAtende := .F.			
							//FR - se o saldo não for suficiente, terá que abrir para selecionar pedidos (usuário selecionará)								
						Endif				
						
						If GetNewPar("XM_PCMARK" , "S") == "S"
							aF4For[nPos][1] := .T. 	//FR - marca como .T. no array aF4For						
						Endif 
										
					Else
						lAtende := .F.  				
						//FR - pedido do XML não encontrado no SC7
					Endif  //nPos > 0								
				Else		//!empty cProdSb1
					lAtende := .F.							
				Endif								
			Next

		Endif 	//If GetNewPAr("XM_XPEDXML","1") == "4"
	
	Else   //VALIDA a seleção do pedido via função do "F5" [x] marca pedido
		
		lAtende		:= .T.
		//não podemos fazer desta forma, pois exigiria que exista a amarração na SA5 ou ZB5, e se for a primeira compra, esta amarração não existe ainda
		/*
		For fr := 1 to Len(aPedXML)						
			//FR - Acha Amarra
			cProdXml := aPedXML[fr][3]
			cProdSB1 := U_fAchamarra(cProdXML,cA100For,cLoja)
			nSldped	 := 0
			cPedX    := ""
			nTam     := 0
			y 		 := 0
				
			If !Empty(cProdSB1)
			
				For y := 1 to Len(aF4For)
					If aF4For[y][1]     //se estiver marcado, verifica se atende
						If lConsMedic .And. lNfMedic
							cPedX := Alltrim(aF4For[y][6]) 					
						Else						
							cPedX := Alltrim(aF4For[y][3]) 					
						Endif
					
						If cProdSB1 != cProdAnt								
							nSldped  := U_fVerSldC7(cPedX,cProdSB1,cA100For,cLoja) 		//sendo um produto diferente do anterior, atribui o saldo novo
							cProdAnt := cProdSB1
						Else
							nSldped += U_fVerSldC7(cPedX,cProdSB1,cA100For,cLoja)    	//sendo o mesmo produto que o anterior, acumula o saldo
						Endif																
										
						If nSldped >= aPedXml[fr][4]  	//FR - se o saldo do pedido na SC7 atende a qtde pedida no XML?																
							lAtende := .T.										
						Endif
					Endif				
				Next							
			Endif
			
		Next
		*/	
	Endif		//lValid
					
Else		//If aPedXML <> NIL .and. Len(aPedXML) > 0
	lAtende := .F.
Endif		//If aPedXML <> NIL .and. Len(aPedXML) > 0

/*
If lValid  		//se valida pela tela de seleção do pedido [x]-markbrowse pedidos de compra
				//se valid = .T. , é para validar o saldo e avisar o usuário para ele poder marcar mais pedidos
	If !lAtende
		MsgAlert("O Saldo do Pedido Selecionado Não Atende Por Completo," + CRLF + "Por Favor, Selecione Mais Pedidos.")
	Else
		lPCXMLAtend := .T.
	Endif
Endif
*/
Return(lAtende)

//--------------------------------------------------------------------------------------------------------------//
//FR - 06/08/2020 - verifica o saldo do pedido de um determinado fornecedor
//--------------------------------------------------------------------------------------------------------------//
****************************************************
User Function fVerSldC7 (cPed,cProd,cA100For,cLoja)   
****************************************************
Local nSaldoped := 0
Local cQuery    := ""

cQuery := " SELECT C7_FILIAL, C7_NUM, C7_FORNECE, C7_LOJA, C7_ITEM, C7_PRODUTO, C7_QUANT, C7_QTDACLA, C7_QUJE " + CRLF

cQuery += " FROM " + RetSqlName("SC7") + " SC7 "																+ CRLF
cQuery += " WHERE SC7.C7_FILIAL  = '" + Alltrim(xFilial("SC7")) + "' " 		+ CRLF
cQuery += " AND   SC7.C7_FORNECE = '" + Alltrim(cA100For) + "' " 			+ CRLF
cQuery += " AND   SC7.C7_LOJA    = '" + Alltrim(cLoja)    + "' "			+ CRLF
cQuery += " AND   SC7.C7_PRODUTO = '" + Alltrim(cProd)    + "' " 			+ CRLF
cQuery += " AND   SC7.C7_NUM  IN ('"  + Alltrim(cPed)     + "') " 			+ CRLF
cQuery += " AND   SC7.D_E_L_E_T_ <> '*' "									+ CRLF
	
If Select("TMPSLD") > 0
	dbSelectArea("TMPSLD")
    TMPSLD->(dbCloseArea())
EndIf

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPSLD", .T., .F. )
DbSelectArea("TMPSLD")
DbGoTop()
If !TMPSLD->(Eof())
	While !TMPSLD->(Eof()) 
		nSaldoped +=  ( TMPSLD->C7_QUANT - TMPSLD->C7_QUJE - TMPSLD->C7_QTDACLA) 
		TMPSLD->(Dbskip())
	Enddo
Endif

Return(nSaldoped)



/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun??o    ³NfePC2Acol³ Autor ³ Edson Maricate        ³ Data ³27.01.2000 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Esta rotina atualiza o acols com base no item do pedido de   ³±±
±±³          ³compra                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 : Numero do registro do SC7                            ³±±
±±³          ³ExpN2 : Item da NF                                           ³±±
±±³          ³ExpN3 : Saldo do Pedido                                      ³±±
±±³          ³ExpC1 : Item a ser carregado no aCols ( D1_ITEM )            ³±±
±±³          ³ExpL1 : Indica se os dados da Pre-Nota devem ser preservados ³±±
±±³          ³ExpA1 : Valores das despesas acessorias do pedido de compras ³±±
±±³          ³ExpA2 : Cabecalho do rateio                                  ³±±
±±³          ³ExpA3 : Itens do rateio                                      ³±±
±±³          ³ExpN4 : Preco unitário na Pré-Nota						   ³±±
±±³          ³ExpL2 : Indica se nota foi importada pelo TOTVS Colaboracao  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Sempre .T.                                            ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³Esta rotina tem como objetivo atualizar a funcao fiscal com  ³±±
±±³          ³base no item do pedido de compra.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function NFePC2Acol(nRecSC7,nItem,nSalPed,cItem,lPreNota,aRateio,aHeadSDE,aColsSDE,nPrUPreNf,lTColab)

Local aArea		   := GetArea()
Local aAreaSC7	   := SC7->(GetArea())
Local aAreaSF4	   := SF4->(GetArea())
Local aAreaSB1	   := SB1->(GetArea())
Local aAreaSC1     := SC1->(GetArea())
Local aAreaSTJ
Local aRefSC7      := MaFisSXRef("SC7")

Local cNGMNTNO	   := SuperGetMV("MV_NGMNTNO",.F.,"2")
Local cMVARRPEDC   := SuperGetMV("MV_ARRPEDC", .F., "")

Local lRateioPC    := SuperGetMv("MV_NFEDAPC")
Local lAllPC       := .T.
Local lAltImpPreNf := .F.
Local lMaFisFound  := MaFisFound()
Local lMT103IPC	   := ExistBlock( "MT103IPC",,.T. )
Local lMT103RCC	   := ExistBlock( "MT103RCC",,.T. )
Local lMT103IP2	   := ExistBlock( "MT103IP2",,.T. )
Local lRateioDE	   := .F.
Local lTOPDRFRM    := FindFunction("A120RDFRM") .And. A120RDFRM("A103")

Local nQuantPed    := 0
Local nX           := 0   
Local nCntFor      := 0 
Local nValUnit     := 0
Local nValFre      := 0
Local nValDesc     := 0
Local nValDesp     := 0
Local nValSeg      := 0
Local nValTot      := 0
Local nPosQtd      := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_QUANT"})
Local nPosQtd2     := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_QTSEGUM"})
Local nPosTes      := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_TES"})
Local nPosVunit    := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_VUNIT"})
Local nPosBicm     := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_BASEICM"})
Local nPosPicm     := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_PICM"})
Local nPosVicm     := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_VALICM"})
Local nPosBipi     := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_BASEIPI"})
Local nPosIpi      := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_IPI"})
Local nPosVipi     := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_VALIPI"})
Local nPValFret	   := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_VALFRE"})
Local nPValDesc	   := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_VALDESC"})
Local nPValDesp	   := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_DESPESA"})
Local nPValSeg	   := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_SEGURO"})
Local nPosTotal    := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_TOTAL"})
Local nPVOrdem 	   := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_ORDEM"})
Local nPMSIPC	   := GetNewPar("MV_PMSIPC",2)

DEFAULT aHeadSDE  := {}
DEFAULT aColsSDE  := {}

DEFAULT lPreNota := .F.
DEFAULT lTColab  := .F.
DEFAULT aRateio  := {0,0,0}


//-- Verifica a existencia do item do acols
If nItem == Nil .Or. nItem > Len(aCols)
	aadd(aCols,Array(Len(aHeader)+1))
	For nX := 1 to Len(aHeader)
		If IsHeadRec(aHeader[nX][2])
		    aCols[Len(aCols)][nX] := 0
		ElseIf IsHeadAlias(aHeader[nX][2])
		    aCols[Len(aCols)][nX] := "SD1"
		ElseIf Trim(aHeader[nX][2]) == "D1_ITEM"
			aCols[Len(aCols)][nX] 	:= IIF(cItem<>Nil,cItem,StrZero(1,Len(SD1->D1_ITEM)))
		Else
			aCols[Len(aCols)][nX] := CriaVar(aHeader[nX][2], (aHeader[nX][10] <> "V") )
		EndIf
		aCols[Len(aCols)][Len(aHeader)+1] := .F.
	Next nX
	nItem := Len(aCols)
EndIf

//Posiciona registros
dbSelectArea("SC7")
SC7->(MsGoto(nRecSC7))

lAllPC := SC7->C7_QUANT == nSalPed .And. Empty(SC7->C7_REAJUST)

dbSelectArea("SB1")
SB1->(dbSetOrder(1))
SB1->(DbSeek(xFilial("SB1")+SC7->C7_PRODUTO))

//Considera quantidade e valor da nota importada via TOTVS Colaboracao
If !lTColab
	nQuantPed:= SC7->C7_QUANT
	nValFre  := SC7->C7_VALFRE
	nValDesc := SC7->C7_VLDESC 
	nValDesp := SC7->C7_DESPESA
	nValSeg  := SC7->C7_SEGURO
	If !Empty(cMVARRPEDC) .AND. AllTrim(Upper(cMVARRPEDC)) == "NOROUND"
		nValUnit := NoRound(NfePcReaj(SC7->C7_REAJUST,lReajuste),TamSX3('D1_VUNIT')[2])
		nValTot := NoRound(nSalPed*nValUnit,TamSX3('D1_TOTAL')[2])
	Else
		nValUnit := Round(NfePcReaj(SC7->C7_REAJUST,lReajuste),TamSX3('D1_VUNIT')[2])
		nValTot := Round(nSalPed*nValUnit,TamSX3('D1_TOTAL')[2])
	EndIf
Else
	nValUnit := aCols[nItem][nPosVunit]
	nSalPed  := aCols[nItem][nPosQtd]
	nValFre	 := aCols[nItem][nPValFret]
	nValDesc := aCols[nItem][nPValDesc]
	nValDesp := IIF((nPValDesp > 0),aCols[nItem][nPValDesp],0)
	nValSeg  := IIF((nPValSeg > 0),aCols[nItem][nPValSeg],0)
	If !Empty(cMVARRPEDC)
		If AllTrim(Upper(cMVARRPEDC)) == "ROUND"
			nValTot := Round(nSalPed*nValUnit, TamSX3('D1_TOTAL')[2])
		ElseIf AllTrim(Upper(cMVARRPEDC)) == "NOROUND"
			nValTot := NoRound(nSalPed*nValUnit,TamSX3('D1_TOTAL')[2])
		EndIf
	Else
		nValTot := Round(nSalPed*nValUnit,TamSX3('D1_TOTAL')[2])
	EndIf
EndIf

//Carrega os impostos do pedido de compra para o Doc.Entrada
If lMaFisFound
	//Obtem a condicao de pagamento do pedido de compra
	If (l103Class .and. Empty(cCondicao)) .Or. !l103Class  
		cCondicao := Iif(l103Auto .And. !Empty(cCondicao), cCondicao, SC7->C7_COND)
	EndIf

	MaFisIniLoad(nItem)
	For nX := 1 To Len(aRefSc7)
		Do Case
		Case aRefSC7[nX][2] == "IT_QUANT"
			If !lPreNota
				MaFisLoad(aRefSc7[nX][2],nSalPed,nItem)
			EndIf
		Case aRefSc7[nX][2] == "IT_PRCUNI"
			If !lPreNota
				MaFisLoad(aRefSc7[nX][2],nValUnit,nItem)
			EndIf
		Case aRefSc7[nX][2] == "IT_VALMERC"
			If !lPreNota
				MaFisLoad(aRefSc7[nX][2],nValTot,nItem)
			EndIf
		Case aRefSc7[nX][2] == "IT_DESCONTO"
			If !lPreNota
				MaFisLoad(aRefSc7[nX][2],xMoeda(((nValDesc/nQuantPed)* nSalPed),SC7->C7_MOEDA,1,M->dDEmissao,,SC7->C7_TXMOEDA,),nItem)
			EndIf
		Case aRefSc7[nX][2] == "IT_VALEMB"
			MaFisLoad(aRefSc7[nX][2],xMoeda(SC7->C7_VALEMB,SC7->C7_MOEDA,1,M->dDEmissao,,SC7->C7_TXMOEDA,),nItem)
		Case aRefSc7[nX][2] == "IT_SEGURO"
			If lRateioPC
				MaFisLoad(aRefSc7[nX][2],xMoeda(((nValSeg/nQuantPed)*nSalPed),SC7->C7_MOEDA,1,M->dDEmissao,,SC7->C7_TXMOEDA,),nItem)
			Else
				aRateio[1] += xMoeda(((nValSeg/nQuantPed)*nSalPed),SC7->C7_MOEDA,1,M->dDEmissao,,SC7->C7_TXMOEDA)
			EndIf
		Case aRefSc7[nX][2] == "IT_DESPESA"
			If lRateioPC
				MaFisLoad(aRefSc7[nX][2],xMoeda(((nValDesp/nQuantPed)*nSalPed),SC7->C7_MOEDA,1,M->dDEmissao,,SC7->C7_TXMOEDA,),nItem)
			Else
				aRateio[2] += xMoeda(((nValDesp/nQuantPed)*nSalPed),SC7->C7_MOEDA,1,M->dDEmissao,,SC7->C7_TXMOEDA)
			EndIf
		Case aRefSc7[nX][2] == "IT_FRETE"
			If lRateioPC	
				MaFisLoad(aRefSc7[nX][2],xMoeda(((nValFre/nQuantPed)*nSalPed),SC7->C7_MOEDA,1,M->dDEmissao,,SC7->C7_TXMOEDA,),nItem)
			Else
				aRateio[3] += xMoeda(((nValFre/nQuantPed)*nSalPed),SC7->C7_MOEDA,1,M->dDEmissao,,SC7->C7_TXMOEDA)
			EndIf
		Case aRefSc7[nX][2] == "IT_TES"
			If !Empty(SC7->C7_TES)
				dbSelectArea("SF4")
				SF4->(dbSetOrder(1))
				SF4->(DbSeek(xFilial("SF4")+SC7->C7_TES))				
				MaFisLoad("IT_CF",MaFisCFO(nItem,SF4->F4_CF),nItem)
			EndIf
		Case aRefSc7[nX][2] == "IT_BASEICM"
			nD1BaseIcm := SC7->(FieldGet(FieldPos(aRefSc7[nX][1])))
			If !lPreNota .Or. Empty(SD1->D1_BASEICM) .Or. SD1->D1_BASEICM == nD1BaseIcm
				If nD1BaseIcm <> 0
					MaFisLoad(aRefSc7[nX][2],nD1BaseIcm,nItem)
				Else
					lAltImpPreNf := .T.
				EndIf
			Else
				lAltImpPreNf := .T.
			EndIf
		Case aRefSc7[nX][2] == "IT_ALIQICM"
			nD1Picm := SC7->(FieldGet(FieldPos(aRefSc7[nX][1])))
			If !lPreNota .Or. Empty(SD1->D1_PICM) .Or. SD1->D1_PICM == nD1Picm
				If nD1Picm <> 0
					MaFisLoad(aRefSc7[nX][2],nD1Picm,nItem)
				Else
					lAltImpPreNf := .T.
				EndIf
			Else
				lAltImpPreNf := .T.
			EndIf
		Case aRefSc7[nX][2] == "IT_VALICM"
			nD1ValIcm	:= SC7->(FieldGet(FieldPos(aRefSc7[nX][1])))
			If !lPreNota .Or. Empty(SD1->D1_VALICM) .Or. SD1->D1_VALICM == nD1ValIcm
				If nD1ValIcm <> 0
					MaFisLoad(aRefSc7[nX][2],nD1ValIcm,nItem)
				Else
					lAltImpPreNf := .T.
				EndIf
			Else
				lAltImpPreNf := .T.
			EndIf			
		Case aRefSc7[nX][2] == "IT_BASEIPI"
			nD1BaseIpi	:= SC7->(FieldGet(FieldPos(aRefSc7[nX][1])))
			If !lPreNota .Or. Empty(SD1->D1_BASEIPI) .Or. SD1->D1_BASEIPI == nD1BaseIpi
				If nD1BaseIpi <> 0
					MaFisLoad(aRefSc7[nX][2],nD1BaseIpi,nItem)
				Else
					lAltImpPreNf := .T.
				EndIf				
			Else
				lAltImpPreNf := .T.
			EndIf
		Case aRefSc7[nX][2] == "IT_ALIQIPI"
			nD1AliqIpi := SC7->(FieldGet(FieldPos(aRefSc7[nX][1])))
			If !lPreNota .Or. Empty(SD1->D1_IPI) .Or. SD1->D1_IPI == nD1AliqIpi
				If nD1AliqIpi <> 0
					MaFisLoad(aRefSc7[nX][2],nD1AliqIpi,nItem)
				Else
					lAltImpPreNf := .T.
				EndIf				
			Else
				lAltImpPreNf := .T.
			EndIf
		Case aRefSc7[nX][2] == "IT_VALIPI"
			nD1ValIpi	:= SC7->(FieldGet(FieldPos(aRefSc7[nX][1])))	
			If !lPreNota .Or. Empty(SD1->D1_VALIPI) .Or. SD1->D1_VALIPI == nD1ValIpi
				If nD1ValIpi <> 0
					MaFisLoad(aRefSc7[nX][2],nD1ValIpi,nItem)
				Else
					lAltImpPreNf := .T.
				EndIf				
			Else
				lAltImpPreNf := .T.
			EndIf			
		OtherWise
			MaFisLoad(aRefSc7[nX][2],SC7->(FieldGet(FieldPos(aRefSc7[nX][1]))),nItem)
		EndCase
	Next nX
	MaFisEndLoad(nItem)
Else
	//Obtem a condicao de pagamento do pedido de compra
	cCondicao := SC7->C7_COND 
EndIf

//Atualiza o acols com base no pedido de compras
If !lPreNota
	For nCntFor := 1 To Len(aHeader)
		Do Case
		Case Trim(aHeader[nCntFor,2]) == "D1_COD"
			aCols[nItem,nCntFor] := SC7->C7_PRODUTO     
		Case Trim(aHeader[nCntFor,2]) == "D1_REVISAO"
			aCols[nItem,nCntFor] := SC7->C7_REVISAO
		Case Trim(aHeader[nCntFor,2]) == "D1_TOTAL"			
			aCols[nItem,nCntFor] := Round(nSalPed*Round(nValUnit,TamSX3('D1_VUNIT')[2]), TamSX3('D1_TOTAL')[2])
		Case Trim(aHeader[nCntFor,2]) == "D1_TES" .And. !Empty(SC7->C7_TES)
			aCols[nItem,nCntFor] := SC7->C7_TES
		Case Trim(aHeader[nCntFor,2]) == "D1_PEDIDO"
			aCols[nItem,nCntFor] := SC7->C7_NUM
		Case Trim(aHeader[nCntFor,2]) == "D1_QUANT" .Or. Trim(aHeader[nCntFor,2]) == "D1_SLDEXP"
			aCols[nItem,nCntFor] := nSalPed
		Case Trim(aHeader[nCntFor,2]) == "D1_VUNIT"
			aCols[nItem,nCntFor] := Round(nValUnit,TamSX3('D1_VUNIT')[2])
		Case Trim(aHeader[nCntFor,2]) == "D1_ITEMPC"
			aCols[nItem,nCntFor] := SC7->C7_ITEM
		Case Trim(aHeader[nCntFor,2]) == "D1_LOCAL"
			aCols[nItem,nCntFor] := SC7->C7_LOCAL
		Case Trim(aHeader[nCntFor,2]) == "D1_CC"
			aCols[nItem,nCntFor] := SC7->C7_CC     
		Case Trim(aHeader[nCntFor,2]) == "D1_OP"
			dbSelectArea("SC1")
			SC1->(dbSetOrder(1))
			SC1->(dbSeek(xFilial("SC1")+SC7->C7_NUMSC+SC7->C7_ITEMSC))
			If AllTrim(SC1->C1_ORIGEM) <> "MATA106" .And. (IIf(nPVOrdem > 0 ,Empty(aCols[nItem,nPVOrdem]) , .T.))
				aCols[nItem,nCntFor] := SC7->C7_OP
			EndIf			
		Case Trim(aHeader[nCntFor,2]) == "D1_ITEMCTA"			// Item Contabil
			aCols[nItem,nCntFor] := Iif( Empty(SC7->C7_ITEMCTA) .AND. SC7->C7_RATEIO !="1", SB1->B1_ITEMCC, SC7->C7_ITEMCTA )
		Case Trim(aHeader[nCntFor,2]) == "D1_CONTA"				// Conta Contabil
			aCols[nItem,nCntFor] := Iif( Empty(SC7->C7_CONTA) .AND. SC7->C7_RATEIO !="1", SB1->B1_CONTA, SC7->C7_CONTA )
		Case Trim(aHeader[nCntFor,2]) == "D1_CLVL"				// Classe de Valor
			aCols[nItem,nCntFor] := Iif( Empty(SC7->C7_CLVL) .AND. SC7->C7_RATEIO !="1", SB1->B1_CLVL, SC7->C7_CLVL )
		Case Trim(aHeader[nCntFor,2]) == "D1_UM"
			aCols[nItem,nCntFor] := SC7->C7_UM
		Case Trim(aHeader[nCntFor,2]) == "D1_SEGUM"
			aCols[nItem,nCntFor] := SC7->C7_SEGUM
		Case Trim(aHeader[nCntFor,2]) == "D1_QTSEGUM"
			aCols[nItem,nCntFor] := IIF(SB1->B1_CONV <> 0 .And. aCols[nItem][nPosQtd] <> 0, ConvUm(SB1->B1_COD,aCols[nItem][nPosQtd],aCols[nItem][nPosQtd2],2),SC7->C7_QTSEGUM) 
		Case Trim(aHeader[nCntFor,2]) == "D1_DESC"
			aCols[nItem,nCntFor] := SC7->C7_DESC
		Case Trim(aHeader[nCntFor,2]) == "D1_VALDESC"
			aCols[nItem,nCntFor] := xMoeda(((SC7->C7_VLDESC/SC7->C7_QUANT)* nSalPed) , SC7->C7_MOEDA,1,M->dDEmissao,,SC7->C7_TXMOEDA)
		Case Trim(aHeader[nCntFor,2]) == "D1_RATEIO" 
			aCols[nItem,nCntFor] := SC7->C7_RATEIO
			If SC7->C7_RATEIO == "1"
				lRateioDE	:= .T.
			Endif
		Case Trim(aHeader[nCntFor,2]) == "D1_VALFRE"
			If nPValFret > 0
				aCols[nItem,nCntFor] := SC7->C7_VALFRE
			EndIf
		Case Trim(aHeader[nCntFor,2]) == "D1_DESPESA"
			If nPValDesp > 0
				aCols[nItem,nCntFor] := SC7->C7_DESPESA
			Endif
		Case Trim(aHeader[nCntFor,2]) == "D1_CODGRP"
			aCols[nItem,nCntFor] := SB1->B1_GRUPO
		Case Trim(aHeader[nCntFor,2]) == "D1_CODITE"
			aCols[nItem,nCntFor] := SB1->B1_CODITE  
		Case Trim(aHeader[nCntFor,2]) == "D1_CLASFIS"
			dbSelectArea("SF4")
			SF4->(dbSetOrder(1))
			SF4->(DbSeek(xFilial("SF4")+SC7->C7_TES))		
			aCols[nItem,nCntFor] := SubStr(SB1->B1_ORIGEM,1,1)+SF4->F4_SITTRIB
		Case Trim(aHeader[nCntFor,2]) == "D1_IPI"
			If !Empty(SC7->C7_IPI)
				aCols[nItem,nCntFor] := SC7->C7_IPI
			Else
				aCols[nItem,nCntFor] := SB1->B1_IPI
			EndIf
		Case Trim(aHeader[nCntFor,2]) == "D1_PICM"
			If !Empty(SC7->C7_PICM)
				aCols[nItem,nCntFor] := SC7->C7_PICM
			Else
				aCols[nItem,nCntFor] := SB1->B1_PICM
			EndIf 
		Case Trim(aHeader[nCntFor,2]) == "D1_ITEMMED"
			aCols[nItem,nCntFor] := If( !Empty( SC7->C7_CONTRA ) .And. !Empty( SC7->C7_MEDICAO ), "1", "2" )
		//Nota de empenho	
		Case Trim(aHeader[nCntFor,2]) == "D1_CODNE"
			aCols[nItem,nCntFor] := SC7->C7_CODNE
		Case Trim(aHeader[nCntFor,2]) == "D1_ITEMNE"
			aCols[nItem,nCntFor] := SC7->C7_ITEMNE
		Case Trim(aHeader[nCntFor,2]) == "D1_DTVALID"
			If Rastro(SC7->C7_PRODUTO) 
				aCols[nItem,nCntFor] := dDatabase + SB1->B1_PRVALID
			Else
				aCols[nItem,nCntFor] := Ctod( '' )
			EndIf
		Case Trim(aHeader[nCntFor,2]) == "D1_ORDEM"
			aAreaSC1 := SC1->(GetArea())
			
			dbSelectArea("SC1")
			SC1->(dbSetOrder(1))
			SC1->(dbSeek(xFilial("SC1")+SC7->C7_NUMSC+SC7->C7_ITEMSC))
			If AllTrim(SC1->C1_ORIGEM) <> "MATA106"
				If cNGMNTNO == "1"
					aAreaSC1 := SC1->(GetArea())
					aAreaSTJ := STJ->(GetArea())
				
					If !Empty(SC7->C7_OP)
						dbSelectArea("STJ") 
						STJ->(dbSetOrder(1))
						
						cOPStj := SubStr(SC7->C7_OP,1,At("OS",SC7->C7_OP)-1)
						
						If !Empty(cOPStj) .And. STJ->(dbSeek(xFilial("STJ")+ cOPStj))
							aCols[nItem,nCntFor] := cOPStj			
						EndIf
					Else
						dbSelectArea("SC1")
						SC1->(dbSetOrder(1))
						If SC1->(dbSeek(xFilial("SC1")+SC7->C7_NUMSC+SC7->C7_ITEMSC))
							dbSelectArea("STJ")
							STJ->(dbSetOrder(1))
							
							cOPStj := if(!empty(SC1->C1_OS),SC1->C1_OS,SubStr(SC1->C1_OP,1,At("OS",SC1->C1_OP)-1))
							
							If !Empty(cOPStj) .And. STJ->(dbSeek(xFilial("STJ")+ cOPStj))
								aCols[nItem,nCntFor] := cOPStj
								NGSDCHKORDEM(cOPStj,nItem)
							Endif
						Endif
					EndIf
				
					RestArea(aAreaSTJ)
					RestArea(aAreaSC1)
				EndIf
			Endif
			RestArea(aAreaSC1)
		//Integração RM TOP x Protheus (Retenção/Dedução/Faturamento Direto)
		Case Type("lTOPDRFRM") <> "U" .And. lTOPDRFRM .And. Trim(aHeader[nCntFor,2]) == "D1_RETENCA" 
			aCols[nItem,nCntFor] := SC7->C7_RETENCA-SC7->C7_QUJERET
			
		Case Type("lTOPDRFRM") <> "U" .And. lTOPDRFRM .And. Trim(aHeader[nCntFor,2]) == "D1_DEDUCAO"
			aCols[nItem,nCntFor] := SC7->C7_DEDUCAO-SC7->C7_QUJEDED
			
		Case Type("lTOPDRFRM") <> "U" .And. lTOPDRFRM .And. Trim(aHeader[nCntFor,2]) == "D1_FATDIRE"
			aCols[nItem,nCntFor] := SC7->C7_FATDIRE-SC7->C7_QUJEFAT
			
		EndCase
	Next nCntFor
	FillCTBEnt("SC7",nItem)
	
	//Atualização de campos referente o modulo de Armazenagem - SIGAWMS	
	If IntWMS(SC7->C7_PRODUTO) 
		WmsAvalSD1("8","SD1",aCols,nItem,aHeader)
	EndIf

	If !lMaFisFound
		aRateio[1] += xMoeda(SC7->C7_SEGURO ,SC7->C7_MOEDA,1,M->dDEmissao,,SC7->C7_TXMOEDA)
		aRateio[2] += xMoeda(SC7->C7_DESPESA,SC7->C7_MOEDA,1,M->dDEmissao,,SC7->C7_TXMOEDA)
		aRateio[3] += xMoeda(SC7->C7_VALFRE ,SC7->C7_MOEDA,1,M->dDEmissao,,SC7->C7_TXMOEDA)
	EndIf

	//Complementa o rateio da nota fiscal de saida com o rateio do pedido de compras
	If lRateioDE
		If Empty(aHeadSDE)
			dbSelectArea("SX3")
			SX3->(dbSetOrder(1))
			SX3->(DbSeek("SDE"))
			While SX3->(!EOF()) .And. SX3->X3_ARQUIVO == "SDE"
				IF X3Uso(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL .And. !"DE_CUSTO" $ SX3->X3_CAMPO
					AADD(aHeadSDE,{TRIM(x3Titulo()),;
						SX3->X3_CAMPO,;
						SX3->X3_PICTURE,;
						SX3->X3_TAMANHO,;
						SX3->X3_DECIMAL,;
						SX3->X3_VALID,;
						SX3->X3_USADO,;
						SX3->X3_TIPO,;
						SX3->X3_F3,;
						SX3->X3_CONTEXT } )
				EndIf
				SX3->(dbSkip())
			EndDo
			//Adiciona os campos de Alias e Recno ao aHeader para WalkThru
			ADHeadRec("SDE",aHeadSDE)	
		Endif

		cItemRat := IIF(cItem<>Nil,cItem,StrZero(nItem,Len(SD1->D1_ITEM)))
		RatPed2NF(aHeadSDE,@aColsSDE,cItemRat,nRecSC7)
	Endif

	// 1 - utilização a associação automática com o PMS
	// 2 - não utiliza a associação automática com o PMS
	// default: não utilizar a associação automática
	If IntePMS() .And. nPMSIPC == 1
		PMS103IPC(nItem)
	EndIf

	//Efetua a chamada dos pontos de entrada
	If ExistTemplate( "MT103IPC",,.T. ) .AND. HasTemplate("MT103IPC")  
		ExecTemplate( "MT103IPC", .F., .F.,{nItem})
	EndIf

	//Agroindustria
	If FindFunction("OGXUtlOrig") .And. OGXUtlOrig()  //Encontra a função
		If FindFunction("OGX205") //Encontra a função
			OGX205() // Executa a função
		EndIf
	EndIf

	If lMT103IPC
		ExecBlock( "MT103IPC", .F., .F.,{nItem})
	EndIf
	
	If lMT103RCC
		aColsSDE := ExecBlock( "MT103RCC", .F., .F.,{aHeadSDE,aColsSDE})
	EndIf
EndIf

//Quando ha TES no pedido de compra, deve-se recalcular os
//impostos carregados para verificar se nao ha novos impostos
//que devem ser calculados!
If lMaFisFound
	Do Case
	Case cA100For+cLoja <> SC7->C7_FORNECE+SC7->C7_LOJA
		MaFisLoad("IT_TES","",nItem)	
		MaFisAlt("IT_ALIQICM",0,nItem)
		MaFisAlt("IT_ALIQIPI",0,nItem)
		If Empty(SC7->C7_TES)
			MaFisAlt("IT_TES",RetFldProd(SB1->B1_COD,"B1_TE"),nItem)
		Else
			MaFisAlt("IT_TES",SC7->C7_TES,nItem)				
		EndIf
	Case Empty(SC7->C7_TES) .And. !Empty(RetFldProd(SB1->B1_COD,"B1_TE"))
		MaFisLoad("IT_TES","",nItem)
		MaFisAlt("IT_TES",RetFldProd(SB1->B1_COD,"B1_TE"),nItem)
	Case Empty(SC7->C7_TES) .And. Empty(RetFldProd(SB1->B1_COD,"B1_TE")) .And. nPosTes > 0
		MaFisLoad("IT_TES","",nItem)
		MaFisAlt("IT_TES",IF( aCols[nItem,nPosTes] == Nil,CriaVar("D1_TES"),aCols[nItem,nPosTes] ),nItem)
	Case !Empty(SC7->C7_TES)
		MaFisLoad("IT_TES","",nItem)
		MaFisAlt("IT_TES",SC7->C7_TES,nItem)
		If lAllPC .And. !lAltImpPreNf
			// Quando for Relacionar o Pedido a Nf ou preço unitário da Pré-Nf for igual ao Pedido, entra na Rotina
			// Caso Preço Unitário da Pré-Nf for divergente do pedido, prevalece o preço da Pré-Nf mesmo que a quantidade do pedido seja igual.
		    
		    If nPrUPreNf == Nil .Or. (nPrUPreNf-SC7->C7_PRECO) == 0  
				For nX := 1 To Len(aRefSc7)
					Do Case
					Case !("IT_BAS"$aRefSc7[nX][2] .Or. "IT_VAL"$aRefSc7[nX][2] .Or. "IT_ALIQ"$aRefSc7[nX][2])
						//Não fazer nada
					case !Empty(SC7->(FieldGet(FieldPos(aRefSc7[nX][1]))))
						iF !(SUBSTR(aRefSc7[NX][2],4,3) $ 'BAS|VAL')
							MaFisAlt(aRefSc7[nX][2],SC7->(FieldGet(FieldPos(aRefSc7[nX][1]))),nItem)
						ELSE
							MaFisAlt(aRefSc7[nX][2],xMoeda(SC7->(FieldGet(FieldPos(aRefSc7[nX][1]))),SC7->C7_MOEDA,1,M->dDEmissao,,SC7->C7_TXMOEDA,),nItem)
						ENDif
					EndCase
				Next nX
			EndIf
		EndIf		
		If lTColab
			aCols[nItem,nPosBicm] := MaFisRet(nItem,"IT_BASEICM")
			aCols[nItem,nPosPicm] := MaFisRet(nItem,"IT_ALIQICM")
			aCols[nItem,nPosVicm] := MaFisRet(nItem,"IT_VALICM")
			aCols[nItem,nPosBipi] := MaFisRet(nItem,"IT_BASEIPI")
			aCols[nItem,nPosIpi]  := MaFisRet(nItem,"IT_ALIQIPI")
			aCols[nItem,nPosVipi] := MaFisRet(nItem,"IT_VALIPI")
		EndIf
	EndCase

	//Ponto de entrada para tratamentos diversos após o recalculo de
	//impostos carregados a partir da TES correspondente
	If lMT103IP2
		ExecBlock( "MT103IP2", .F., .F.,{nItem})
	EndIf
	
	MaFisToCols(aHeader,aCols,Len(aCols),"MT100")
	aColsD1 := acols //Atualização necessária para que, o Array do Lançamento da Apuração de ICMS tenha o mesmos itens do acols da Nota Fiscal de Entrada.
EndIf

RestArea(aAreaSB1)
RestArea(aAreaSF4)
RestArea(aAreaSC7)
RestArea(aArea)

Return .T.



//Bibliotecas
#Include "Protheus.ch"
 
/*/{Protheus.doc} zLimpaEsp
Função que limpa os caracteres especiais dentro de um campo
@type function
@author Atilio / Achoa
@since 25/04/2016
@version 1.0
@param lEndereco, Lógico, Define se o campo é endereço (caso sim, o traço e vírgula serão ignorados)
    @example
    u_zLimpaEsp()
/*/
 
Static Function RetiraAcentos(cTexto,lEndereco)

    Local aArea       := GetArea()
    //Local cCampo      := ReadVar()
    Local cConteudo   := cTexto
    Local nTamOrig    := Len(cConteudo)
    Default lEndereco := .F.
     
    //Retirando caracteres
    cConteudo := StrTran(cConteudo, "'", "")
    cConteudo := StrTran(cConteudo, "#", "")
    cConteudo := StrTran(cConteudo, "%", "")
    cConteudo := StrTran(cConteudo, "*", "")
    cConteudo := StrTran(cConteudo, "&", "E")
    cConteudo := StrTran(cConteudo, ">", "")
    cConteudo := StrTran(cConteudo, "<", "")
    cConteudo := StrTran(cConteudo, "!", "")
    cConteudo := StrTran(cConteudo, "@", "")
    cConteudo := StrTran(cConteudo, "$", "")
    cConteudo := StrTran(cConteudo, "(", "")
    cConteudo := StrTran(cConteudo, ")", "")
    cConteudo := StrTran(cConteudo, "_", "")
    cConteudo := StrTran(cConteudo, "=", "")
    cConteudo := StrTran(cConteudo, "+", "")
    cConteudo := StrTran(cConteudo, "{", "")
    cConteudo := StrTran(cConteudo, "}", "")
    cConteudo := StrTran(cConteudo, "[", "")
    cConteudo := StrTran(cConteudo, "]", "")
    cConteudo := StrTran(cConteudo, "/", "")
    cConteudo := StrTran(cConteudo, "?", "")
    cConteudo := StrTran(cConteudo, ".", "")
    cConteudo := StrTran(cConteudo, "\", "")
    cConteudo := StrTran(cConteudo, "|", "")
    cConteudo := StrTran(cConteudo, ":", "")
    cConteudo := StrTran(cConteudo, ";", "")
    cConteudo := StrTran(cConteudo, '"', '')
    cConteudo := StrTran(cConteudo, '°', '')
    cConteudo := StrTran(cConteudo, 'ª', '')
	cConteudo := FwNoAccent(cConteudo)
     
    //Se não for endereço, retira também o - e a ,
    If !lEndereco
        cConteudo := StrTran(cConteudo, ",", "")
        cConteudo := StrTran(cConteudo, "-", "")
    EndIf
     
    //Adicionando os espaços a direita
    cConteudo := Alltrim(cConteudo)
    cConteudo += Space(nTamOrig - Len(cConteudo))
     
    //Definindo o conteúdo do campo
    //&(cCampo+" := '"+cConteudo+"' ")
     
    RestArea(aArea)

Return cConteudo


Static Function getCSS( cClass )
  Local cCSS        := '' as character
  Default cClass    := ''
    cCSS   += "QPushButton { color: black }"
    cCSS   += "QPushButton { font-weight: bolder }"
    cCSS   += "QPushButton { border: 2px solid #CECECE }"
    cCSS   += "QPushButton { background-color: #e5e5e5 }"
    cCSS   += "QPushButton { border-radius: 8px }"
    cCSS   += "QPushButton:hover { background-color: #457432 } "
    cCSS   += "QPushButton:hover { border-style: solid } "
    cCSS   += "QPushButton:hover { border-width: 4px }"
    cCSS   += "QPushButton:pressed { background-color: #355926 }"
    cCSS   += "QPushButton:focus { background-color: #274c19 } "
    cCSS   += "QPushButton:focus { border-style: solid } "
    cCSS   += "QPushButton:focus { border-width: 8px }"
  
  
  If cClass == 'TGET'
    cCSS   += "QLineEdit { font-size: 12px }"
    cCSS   += "QLineEdit { border-radius: 8px }"
    cCSS   += "QLineEdit { border: 1px solid #CECECE } "
    cCSS   += "QLineEdit { background-color: #000000 } "
    cCSS   += "QLineEdit:disabled{ background-color: #D7E3F0 }"
  
  
  ElseIf cClass == 'TCOMBO'
    cCSS   := "QComboBox { font: bold } "
    cCSS   := "QComboBox { border-radius: 8px } "
    cCSS   += "QComboBox { border: 2px solid #CECECE } "
    cCSS   += "QComboBox { background-color: #D7E3F0 } "
    cCSS   += "QComboBox { color: black } "
    cCSS   += "QComboBox:hover { background-color: #6fcd4a } "
    cCSS   += "QComboBox:!editable:on { background-color: #52c923 }"
    cCSS   += "QComboBox QListView{ font: bold; color: black; background-color: #52c923; }"
    cCSS   += "QComboBox QAbstractItemView{  selection-background-color:red; }"
	cCSS   += "QComboBox:disabled{ background-color: #D7E3F0 }"

  ElseIf cClass == 'LABEL'
	cCSS += "QLabel { font-size: 10px }"

  Endif
Return( cCSS )

//---------------------------------------------------------------------------------//
//FUNÇÃO GERAL PARA GRAVAR NA SA5 QUANDO DA ENTRADA DE NOTA POR PEDIDO DE COMPRA
//---------------------------------------------------------------------------------//
USER FUNCTION FGRAVSA5(cCodEmit,cLojaEmit,cProdXml,cDescXml,_cCodProd)
Local cNomEmit := ""

//If cTblCad == "SA2"
SA2->(OrdSetFocus(1))				
SA2->(Dbseek(xFilial("SA2") + cCodEmit + cLojaEmit))
cNomEmit := Alltrim(SA2->A2_NOME)

	DbSelectArea("SA5")		
	DbSetOrder(1)		//A5_FILIAL+A5_FORNECE+A5_LOJA+A5_PRODUTO
	If DbSeek(xFilial("SA5")+cCodEmit+cLojaEmit+_cCodProd)
					
		if .not. empty( SA5->A5_CODPRF )
						
			Conout("Já existe um relacionamento cadastrado para o produto:"+CRLF+cProdXml+" - "+;
			cDescXml+CRLF+SA5->A5_CODPRF)
	
		else
						
			RecLock("SA5",.F.)
			SA5->A5_CODPRF  := cProdXml
			MsUnlock()
			//lGravou := .T.
	
		endif
	
	Else
					
		RecLock("SA5",.T.)
		SA5->A5_FILIAL  := xFilial("SA5")
		SA5->A5_FORNECE := cCodEmit
		SA5->A5_LOJA    := cLojaEmit
		SA5->A5_NOMEFOR := cNomEmit
		SA5->A5_PRODUTO := _cCodProd   //código produto interno (SB1)
		SA5->A5_NOMPROD := cDescXml
		SA5->A5_CODPRF  := cProdXml  //código produto fornecedor
		MsUnlock()
						
		//lGravou := .T.
						
	EndIf					

//Endif
	

RETURN
