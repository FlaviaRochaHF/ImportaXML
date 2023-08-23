#Include "PROTHEUS.CH"
#include "Totvs.ch"
#INCLUDE "VKEY.CH"
#INCLUDE "TBICONN.CH"

//--------------------------------------------------------------
/*/{Protheus.doc} HFXML023
Description
                                                                
@param xParam Parameter Description                             
@return xRet Return Description                                 
@author  -
@since 22/04/2019                                                   
/*/ 
                                                            
//--------------------------------------------------------------//
//FR - 08/05/2020 - Alterações realizadas para adequar na rotina 
//                  Pré Auditoria Fiscal verificação de 
//                  divergências entre XML x NF 
//-------------------------------------------------------------//
//FR - 19/06/2020 - Alterações realizadas para adequar as  
//                  solicitações "TÓPICOS RAFAEL" 
//-------------------------------------------------------------//
//FR - 21/08/2020 - Novos Ajustes em conjunto com Renan 
//                  para adequar solicitações "TÓPICOS RAFAEL" 
//-------------------------------------------------------------//
//FR - 12/11/2020 - Adequar tela de amarração quando o produto
//                  possui 2a. unidade de medida
//                  Solicitado por Sintex - chamado 5680
//--------------------------------------------------------------//
//FR - 18/11/2020 - Chamado #5762 / #5759 Adar
//--------------------------------------------------------------//
//FR - 24/11/2020 - melhoria no posicionamento do array de itens
//                  que retornará para a função U_AMAPC
//--------------------------------------------------------------//
//FR - 06/07/2021 - Modificações Solicitadas por Rafael Lobitsky
//                  p/ flexibilizar amarração de pedido x XML
//--------------------------------------------------------------//
//FR - 28/07/2021 - Correções Solicitadas por Rafael Lobitsky
//                  pós primeira entrega 
//--------------------------------------------------------------//
//FR - 30/11/2021 - #11584 - ADAR - erro casas decimais
//--------------------------------------------------------------//
//FR - 09/05/2022 - #12682 - Brasmolde - erro ao associar PC 
//                  qdo tipo XML é CTE
//--------------------------------------------------------------//
//FR - 14/06/2022 - Brasmolde - PEDIDO DE COMPRA EM DÓLAR E NF EM REAIS
//					Validação item por item do pedido de compra para checar
//                  divergência de valor do PC x XML
//                  Converte o valor do item no xml, utilizando a taxa moeda 
//                  do pedido, porque a NF vem em REAIS
//--------------------------------------------------------------------------//
//FR - 29/08/2022 - ECO AUTOMAÇÃO - #13255 - Correção na associação do 
//                  PC x XML, campos valor unitário, total, valor ipi, ali ipi
//                  e correção dimensão da tela de marcação aleatória de itens
//                  do PC, a dimensão mudou no R.33	
//--------------------------------------------------------------------------//

User Function HFXML023(cModelo,xPosItem,aWBXML)

Local oButton1
Local oButton2                  
Local oSay1
Local oSay2
Local oSay3
Local oSay4
Local oSay5
Local oSay6
Local nOpc        := 0 
Local nCol        := 0
Local nX		:= 0
Local cPROMPT1	:= "Compare os itens da nota com os itens do pedido"
Local cPROMPT2	:= "Preencher o campo 'Item NF' <DuploClick> para realizar amarração"
Local aPos		:= {}
//Local lCompleta	:= .F.		//FR - 21/08/2020
Local   ii        := 0 
Local   xx        := 0
Private aWBrowse1 := {}
Private aWBrowse2 := {}    
Private aWBrowse  := {}                                 
Private aSizeAut  := {}  //MsAdvSize(,.F.,400)  //FR - 19/06/2020  //aSizeAut { 0, 30, 761, 347, 1522, 694, 0, 5 }
Private oArial12N := TFont():New("Arial",12,12,,.T.,,,,.T.,.F.)		//Negrito
Private oArial14N := TFont():New("Arial",14,14,,.T.,,,,.T.,.F.)		//Negrito
Private oDlg
Private oWBrowse1
Private oWBrowse2
Private nCoMeio   := 0

Private aCamposPC := {'Item','Item NF','Produto','Descrição','Pedido','Quant.','Qtd Vinculada','Entregue','Vl. Unit','Total','Vl. Ipi','Aliq.IPI','Segund.UM','Qt.SegUM','Prod.Fornec'}		//FR - 18/11/2020

Private xValTotXML := 0

Private lUnifica:= .F.  //FR - 06/07/2021 - solicitações de Rafael Lobitsky - flexibilizar tela de amarração XML x PC
Private lMarkIt := .F.  //FR - 06/07/2021 - solicitações de Rafael Lobitsky - flexibilizar tela de amarração XML x PC
Private oSaypc
Private oSayqt
//Static oDlg
Static aItensXML := {}

Default xPosItem := 0  //FR - 19/09/2022 - PROJETO PAPIRUS
Default aWBXML   := {}


U_fCALCTELA(@aSizeAut,@aPos)    //FR - 19/06/2020 - TÓPICOS RAFAEL - RESOLUÇÃO DA TELA
//aSizeAut   := {0,30,676,298,1352,596,0,5} //FR TESTE RESOLUCAO DEIXAR COMENTADO
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

nCoMeio    := ((aSizeAut[5] - aSizeAut[6]) /2)

Define MsDialog oDlg TITLE "Tela de amarração Pedido x Nota Fiscal"   From aSizeAut[7],0 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL STYLE DS_MODALFRAME

If cModelo == '55'
	fWBrowse1(oDlg,@aWBrowse1) //browse da NF
Elseif cModelo == '57'
	fWBrowse3(oDlg,@aWBrowse1) //browse da Cte
Elseif cModelo == 'RP'
	fWBrowse4(oDlg,@aWBrowse1) //browse da NFS-e
	aWBXML := aWBrowse1
Endif
fWBrowse2(oDlg,aWBrowse1,aCamposPC,xPosItem) //browse do PC, mas passa por parâmetro o aWBrowse1 que é o Browse do Xml, para procurar o item do browse1 no browse2 e associar o item automaticamente
						  //caso o produto seja exatamente igual ao do SB1.

//aSizeAut[1]=0;aSizeAut[2]=30;aSizeAut[3]=953;aSizeAut[4]=446;aSizeAut[5]=1906;aSizeAut[6]=892;aSizeAut[7]=0;aSizeAut[8]=5;

nCol := (aSizeAut[6] - Len(cPROMPT1)) / 2
@ aSizeAut[8]+6,nCol-100 SAY oSay3 PROMPT cPROMPT1 SIZE 331, 006 OF oDlg FONT oArial14N COLORS CLR_HRED, 16777215 PIXEL

nCol := (aSizeAut[6] - Len(cPROMPT2)) / 2
@ aSizeAut[8]+16,nCol-120 SAY oSay4 PROMPT cPROMPT2 SIZE 451, 006 OF oDlg FONT oArial14N COLORS CLR_HRED, 16777215 PIXEL   //21,nCol

@ aSizeAut[2]+4  ,aSizeAut[4]/2 SAY oSay1 PROMPT "Itens do XML / Nota" 			 								SIZE 375, 007 OF oDlg FONT oArial14N COLORS CLR_HBLUE, 16777215 PIXEL //FR 08/05/2020   //030,139
@ aSizeAut[2]+5  ,aSizeAut[6]-200 SAY oSay2 PROMPT "Itens do Pedido"     			 								SIZE 342, 007 OF oDlg FONT oArial14N COLORS CLR_HBLUE, 16777215 PIXEL                   //031,540

If cModelo == '55'
	@ aSizeAut[4]-080 ,aSizeAut[2]-10 SAY oSay5 PROMPT "Qtde. Total Itens XML / Nota => " + Alltrim(Str(Len(oDet))) SIZE 480, 007 OF oDlg FONT oArial14N COLORS CLR_HBLUE, 16777215 PIXEL                   //396,100
Elseif cModelo == '57'
	@ aSizeAut[4]-080 ,aSizeAut[2]-10 SAY oSay5 PROMPT "Qtde. Total Itens XML / Nota => " + Alltrim(Str(Len(aWBrowse1))) SIZE 480, 007 OF oDlg FONT oArial14N COLORS CLR_HBLUE, 16777215 PIXEL                   //396,100
Endif

//número / item pedido compra
//aWBrowse2[oWBrowse2:nAt,05],; pedido
//aWBrowse2[oWBrowse2:nAt,06],; qtde pc
//aWBrowse2[oWBrowse2:nAt,07],; qtde vinculada
@ aSizeAut[4]-120,nCoMeio-25    SAY oSaypc PROMPT "PC / Item posicionado => "     + Alltrim(aWBrowse2[oWBrowse2:nAt,05] + " / " + aWBrowse2[oWBrowse2:nAt,01]) SIZE 480, 007 OF oDlg FONT oArial14N COLORS CLR_HRED , 16777215 PIXEL                  

@ aSizeAut[4]-100,nCoMeio-25    SAY oSayqt PROMPT "Qtd PC / Qtd Vinculada => "     + Alltrim(cValToChar(aWBrowse2[oWBrowse2:nAt,06])) + " / " + cValToChar(aWBrowse2[oWBrowse2:nAt,07]) SIZE 480, 007 OF oDlg FONT oArial14N COLORS CLR_HMAGENTA , 16777215 PIXEL                  

@ aSizeAut[4]-080,nCoMeio-25    SAY oSay6  PROMPT "Qtde. Total Itens Pedido => "     + Alltrim(Str(Len(aWBrowse2))) SIZE 480, 007 OF oDlg FONT oArial14N COLORS CLR_HBLUE, 16777215 PIXEL                  //396,500

@ aSizeAut[4]-020,nCoMeio-90 BUTTON oButton1 PROMPT "Confirmar" SIZE 037, 012 OF oDlg PIXEL ACTION ( iif( validxml(cModelo,aWBrowse1,aWBrowse2,lMarkIt),nOpc := 1, nOpc := 0 ), iif(nOpc == 1, oDlg:End(), nOpc := 0 ) )  //426,580

@ aSizeAut[4]-020,nCoMeio-40    BUTTON oButton2 PROMPT "Cancelar"  SIZE 037, 012 OF oDlg PIXEL ACTION ( aWBrowse2 := {}, oDlg:End() )                                                                         //426,630

ACTIVATE MSDIALOG oDlg CENTERED
  
If nOpc == 1

	For nX := 1 to Len(aWBrowse2)   						//FR - 24/11/2020 - aWBrowse2 - array dos itens do pedido de compra (browse da direita)
		//FR - 08/03/2023 - aqui já filtra os itens que o usuário escolheu não utilizar!!!!
		If !Empty(aWBrowse2[nX,2]) .and. Alltrim(aWBrowse2[nX,2]) <> "N/A"
			aAdd(aWBrowse,aWBrowse2[nX])
		EndIf
	Next nX

	//aWBrowse	:= aSort(aWBrowse,,, {|x, y| x[2] < y[2]})  //FR - 24/11/2020 - aWBrowse - array de retorno para o HFXML020 já com os itens montados
	nItAtu		:= 0
	nSldIt		:= 0

	If !lMarkIt
		For nX := 1 to Len(aWBrowse)
			If Alltrim(aWBrowse[nX,2]) != "*" //FR - 02/03/2023 - VALIDAÇÃO COM COPAG SUGERIRAM IMPLEMENTAR ESSA OPÇÃO "NÃO SE APLICA" PARA ITENS QUE NÃO PRECISAREM SER SELECIONADOS				
				If aWBrowse[nX,7] > 0  
					//qdo há mais de um pedido selecionado, pode ser que selecione um item de um pedido e um item de outro para compor todos os itens do xml 
					//nesse caso, algumas posições do array ficarão com o campo 'qtde' = zero, porque não foi selecionado, ok
					nIt	:= aScan( aWBrowse1,	{|x| x[1] == aWBrowse[nX,2]} ) 	//FR - 24/11/2020 - aWBrowse1 - array dos itens do XML (browse da esquerda)
					If nIt <> nItAtu
						nItAtu	:= nIt
						nSldIt	:= VAL(aWBrowse1[nIt,6])
					EndIf
	
					//FR - 09/05/2022 - Alteração - #12682 - Brasmolde - erro ao associar xml tipo cte ao PC		
					If cModelo <> "57" .and. cModelo <> "RP"
						nQtqVai := aWBrowse[nX,7]  	//FR - 06/07/2021 					
					Else 
						nQtqVai := 1		
					Endif 
					//FR - 09/05/2022 - Alteração - #12682 - Brasmolde		
					
					//FR - 30/11/2021 - #11584 - ADAR - erro casas decimais - estava arredondando pra mais								 	
					If cModelo == "55"  //FR - 10/07/2023 - TRATATIVA BROWSE NF SERVIÇO
						nPrecuni:= Val(StrTran(StrTran(aWBrowse1[nIt,7],".",""),",",".")) //Val(aWBrowse1[nIt,7]) //preço unitário no XML (formato Caracter) 
					Elseif cModelo == "57"
						nPrecuni:= Val(aWBrowse1[nIt,7])
					Elseif cModelo == "RP"
						nPrecuni:= Val(aWBrowse1[nIt,5])	//FR - 10/07/2023 - TRATATIVA BROWSE NF SERVIÇO
					Endif 
					cPrecuni:= ""
				    //qdo é valor que começa com zero , ex: 0,4497 o val fica igual a zero, então monto o valor do preço:
				    //If nPrecuni == 0
				    			    
				    //	cPrecuni:= StrTran( aWBrowse1[nIt,7], ",", "." ) 
				    //	nPrecuni := Val(cPrecuni)  
				    	
				    //Endif
				    //FR - 30/11/2021 - #11584 - ADAR - erro casas decimais - estava arredondando pra mais								 	
				
					If GetNewPar("XM_USAUMB1" , "X") == "P" 	//Se estiver configurado para utilizar a UM principal do produto em caso de diferença com a UM do XML
						If aWBrowse[nX,13] == aWBrowse1[nIt,12] //se a segunda UM do pedido é igual a UM principal do XML, teremos que realizar a conversão da qtde
							SB1->(OrdSetFocus(1))
							If SB1->(Dbseek(xFilial("SB1") + aWBrowse[nX,3] ))
								If !Empty(SB1->B1_SEGUM)			//se tiver segunda unidade de medida, fará a conversão
									nFatConvert:= SB1->B1_CONV 		//fator de conversão 
					        		cTipConvert:= SB1->B1_TIPCONV   //tipo conversão (multiplica ou divide)
					        		
					        		If cTipConvert = "M"
					        			//se para transformar a 1a. UM para a 2a. UM tiver que multiplicar, então para passar a 2a. UM pra 1a.UM eu divido (faço o inverso)
					        			nQtConvert := aWBrowse[nX,7] / nFatConvert      //100 / 1000 = 0,1   			
					        		Elseif cTipConvert = "D"
					        			//se para transformar a 1a. UM para a 2a. UM tiver que dividir, então para passar a 2a. UM pra 1a.UM eu multiplico (faço o inverso)    			 			
					        			nQtConvert := aWBrowse[nX,7] * nFatConvert 
					        		Endif		        		
					        	
					        		nQtqVai         := nQtConvert 
									If cModelo <> "RP" //FR - 10/07/2023 - TRATATIVA BROWSE NF SERVIÇO
					        			nPrecuni        := VAL(aWBrowse1[nIt,8]) / nQtqVai				//pega o valor total e divide pela qtde convertida para obter o preço unitário
									Else 
										nPrecuni := aWBrowse[nIt,9] //FR - 10/07/2023 - TRATATIVA BROWSE NF SERVIÇO
									Endif 
									aWBrowse[nX,9]	:= nPrecuni	       			
					        		aWBrowse[nX,7]  := nQtqVai
					        		 
							    Else
							    	//FR - 12/11/2020 - Por precaução coloco aqui tb:
									If aWBrowse[nX,6] > nSldIt
										aWBrowse[nX,6]	:= nSldIt	
										nSldIt			:= 0
									Else
										nSldIt	-= aWBrowse[nX,6]	
									EndIf			    
							    Endif
								
							Else
							    //FR - 12/11/2020 - Por precaução coloco aqui tb:
								If aWBrowse[nX,6] > nSldIt
									aWBrowse[nX,6]	:= nSldIt	
									nSldIt			:= 0
								Else
									nSldIt	-= aWBrowse[nX,6]	
								EndIf			
							Endif
							
						Else
					    	//FR - se não tem fator de conversão, faz a atribuição normal como antes:		    
							If aWBrowse[nX,6] > nSldIt
								aWBrowse[nX,6]	:= nSldIt
								nQtqVai         := aWBrowse[nX,6]	
								nSldIt			:= 0
							Else
								nSldIt	-= aWBrowse[nX,6]	
							EndIf	
						Endif
					
					Else 	//se o parâmetro XM_USAUMB1 estiver desabilitado, segue normal
						If cModelo <> "RP" //FR - 10/07/2023 - TRATATIVA BROWSE NF SERVIÇO
							If aWBrowse[nX,7] > nSldIt
								aWBrowse[nX,7]	:= nSldIt
								//nQtqVai         := aWBrowse[nX,7]	
								
								//FR - 09/05/2022 - Alteração - #12682 - Brasmolde - erro ao associar xml tipo cte ao PC		
								If cModelo <> "57"
									nQtqVai := aWBrowse[nX,7]  	//FR - 06/07/2021 
								Else 
									nQtVai := 1		
								Endif 
								//FR - 09/05/2022 - Alteração - #12682 - Brasmolde
		
								nSldIt			:= 0
							Else	//FR - 10/07/2023 - TRATATIVA BROWSE NF SERVIÇO
								nSldIt	-= aWBrowse[nX,7]	//FR - 06/07/2021
							EndIf
						Else 
							nQtqVai := 1		
							nSldIt  := 0							
						Endif 		
					Endif
					//FR - 12/11/2020
				Endif

			//FR - 08/03/2023 - ESSA REDUNDÂNCIA AQUI É NECESSÁRIA	!!!	
			Elseif Alltrim(aWBrowse[nX,2]) == "*" 	 //se é * (SELEÇÃO DE TODOS OS ITENS DO XML Para UM ITEM do PC)  //FR - 06/07/2021
				nIt    := 1
				nItAtu := aWBrowse[nX,1] //0001 
				nSldIt := aWBrowse[nX,7]
				
				nQtqVai := aWBrowse[nX,7]  	//FR - 06/07/2021
				nPrecuni := Round(xValTotXML / nQtqVai,2)  //divide o valor total pela qtde para obter o preço unitário, já que foi unificado tudo com *
				
				If aWBrowse[nX,7] > nSldIt
					aWBrowse[nX,7]	:= nSldIt					
					//nQtqVai         := aWBrowse[nX,7]

					//FR - 09/05/2022 - Alteração - #12682 - Brasmolde - erro ao associar xml tipo cte ao PC		
					If cModelo <> "57"
						nQtqVai := aWBrowse[nX,7]  	//FR - 06/07/2021 
					Else 
						nQtqVai := 1		
					Endif 
					//FR - 09/05/2022 - Alteração - #12682 - Brasmolde		

					nSldIt			:= 0

				Else
					nSldIt	-= aWBrowse[nX,7]	//FR - 06/07/2021
				EndIf		
				
			Endif		//se é * (SELEÇÃO DE TODOS OS ITENS DO XML Para UM ITEM do PC)  //FR - 06/07/2021			
			
			If aWBrowse[nX,7] > 0 
				//qdo há mais de um pedido selecionado, pode ser que selecione um item de um pedido e um item de outro para compor todos os itens do xml 
				//nesse caso, algumas posições do array ficarão com o campo 'qtde' = zero, porque não foi selecionado, ok
				nValtot := 0
				If cModelo <> "57" .and. cModelo <> "RP"  //FR - 10/07/2023 - TRATATIVA BROWSE NF SERVIÇO
					aWBrowse[nX,9]  := nPrecuni
					aWBrowse[nX,10] := nQtqVai * nPrecuni	    				//FR 12/11/2020   //cálculo do valor total
					nIpi			:= Val(aWBrowse1[nIt,10])					//FR 12/11/2020
		        	nValipi			:= Round( nValtot * ( nIpi / 100) ,  TAMSX3("C7_VALIPI")[2] )				//FR 12/11/2020
		        	nValtot         := aWBrowse[nX,10]							//FR 12/11/2020
				Elseif cModelo == "RP"		//FR - 10/07/2023 - TRATATIVA BROWSE NF SERVIÇO		
					nPrecuni := Val(aWBrowse1[nIt,5])
					nIpi     := 0
					nValipi  := 0
					nValtot  := nQtqVai * nPrecuni
				Elseif cModelo == "57"
					nValtot  := nQtqVai * nPrecuni
					nIpi     := 0
					nValipi  := 0
				Endif		        
	        
				If nIt > 0
					//posição 13 - 2a. UM
					//posição 14 - Qt 2a. UM
					aAdd(aWBrowse[nX],Alltrim( Str(nQtqVai) )  )  		//16 - QTD   			
					If cModelo <> "57"
						aAdd(aWBrowse[nX],Alltrim( Str(nPrecuni))  )	//17 - UNIT
					Else 
						aAdd(aWBrowse[nX], aWBrowse1[nIt,07]  )	
					Endif 
					aAdd(aWBrowse[nX],Alltrim( Str(nValtot) )  )  	//18 - TOTAL					
					aAdd(aWBrowse[nX],Alltrim( Str(nValipi) )  )	//19 - VL IPI
					aAdd(aWBrowse[nX],Alltrim( Str(nIpi)    )  )	//20 - ALIQ IPI
					aAdd(aWBrowse[nX],Alltrim( aWBrowse1[nIt,2])  )	//21 - CODIGO PRODUTO NO XML
					aAdd(aWBrowse[nX],Alltrim( aWBrowse1[nIt,3])  )	//22 - DESCRIÇÃO PRODUTO NO XML						
				EndIf 
				
			Endif  //If aWBrowse[nX,7] > 0			
	
		Next nX
	
	Elseif lMarkIt 	
		//FR - 06/07/2021 - Solicitações Rafael Lobitsky - flexibilizar tela amarração XML x PC		
		ii      := 0
		_aItens := {} 
		nIt     := 0
		cIt     := ""
		nPrecuni:= 0
		nQtqVai := 0
		nSldIt  := 0
		nValtot := 0 
		nValipi := 0
		nIpi    := 0
		
		For nX := 1 to Len(aWBrowse)
			If aWBrowse[nX,7] > 0 
				//qdo há mais de um pedido selecionado, pode ser que selecione um item de um pedido e um item de outro para compor todos os itens do xml 
				//nesse caso, algumas posições do array ficarão com o campo 'qtde' = zero, porque não foi selecionado, ok
				cAux     := Alltrim(aWBrowse[nX,2]) 
				nPrecuni := 0
				nPretot  := 0
				nSldIt   := 0 
				_aItens  := {}
				
				//Devido no modo "markIt" os itens ficarem concatenados, apenas separados por , (vírgula), então primeiro preciso isolar os itens
				For ii := 1 to Len(cAux)
					//nPos1 := AT(";",aWBrowse[nX,2])     //Ex: '0001,0003,' - Retorna a posição da primeira ocorrência de uma substring em uma string. Para isso, a função pesquisa a string destino a partir da esquerda.
				
				    If Substr(cAux,ii,1) <> ","
				    	cIt += Substr(cAux,ii,1) //vai adicionando caracter por caracter, exceto vírgula
				    Else
				    	Aadd(_aItens,cIt)  					//se achar vírgula, é porque já tem o número do item inteiro, então adiciona no array
				    	cIt := ""
				    Endif
				
				Next
				
				//agora sim, looping de leitura de cada item
				For ii := 1 to Len(_aItens) 
					nIt	:= aScan( aWBrowse1,	{|x| x[1] == _aItens[ii] } ) 
								
					nSldIt	+= VAL(aWBrowse1[nIt,6])     //soma saldo dos itens concatenados/marcados
					nPretot += Round( Val(aWBrowse1[nIt,8]), TAMSX3("C7_TOTAL")[2] )      //soma o valor total e depois divide pela qtde total concatenada para obter o preço unitário	 	 //nPretot += Val(aWBrowse1[nIt,8])      //soma o valor total e depois divide pela qtde total concatenada para obter o preço unitário	 	
					//nPrecuni+= Val(aWBrowse1[nIt,7]) 	//soma preço unitário dos itens concatenados/marcados - preço unitário no XML (formato Caracter)
				Next
					
				nQtqVai := aWBrowse[nX,7] 
				nPrecuni:= nPretot / nQtqVai
							
				If aWBrowse[nX,6] > nSldIt
					aWBrowse[nX,6]	:= nSldIt
					nQtqVai         := aWBrowse[nX,6]
					nSldIt			:= 0
				Else
					nSldIt	-= aWBrowse[nX,6]
				EndIf					
					
				If aWBrowse[nX,7] > nSldIt			
					nSldIt			:= 0
				Else
					nSldIt	-= aWBrowse[nX,7]	//FR - 06/07/2021
				EndIf
			
				aWBrowse[nX,9]  := nPrecuni
				aWBrowse[nX,10]	:= nQtqVai * nPrecuni
				nValtot         := aWBrowse[nX,10]		
				nIpi			:= Val(aWBrowse1[nIt,10])
				nValipi			:= Round( nValtot * ( nIpi / 100)	, TAMSX3("C7_VALIPI")[2] )				//FR AGO/2022
			
				If nIt > 0					
					aAdd(aWBrowse[nX],Alltrim( Str(nQtqVai) )  )  	//16- QTD
					aAdd(aWBrowse[nX],Alltrim( Str(nPrecuni))  )	//17- UNIT
					aAdd(aWBrowse[nX],Alltrim( Str(nValtot) )  )  	//18- TOTAL					
					aAdd(aWBrowse[nX],Alltrim( Str(nValipi) )  )	//19- VL IPI
					aAdd(aWBrowse[nX],Alltrim( Str(nIpi)    )  )	//20- ALIQ IPI
					aAdd(aWBrowse[nX],Alltrim( aWBrowse1[nIt,2])  )	//21-CODIGO PRODUTO NO XML
					aAdd(aWBrowse[nX],Alltrim( aWBrowse1[nIt,3])  )	//22-DESCRIÇÃO PRODUTO NO XML
				EndIf
				
			Endif //if da qtde > 0
			
		Next nX	
	
	Endif
	//FR - 06/07/2021 - Solicitações Rafael Lobitsky - flexibilizar tela amarração XML x PC
	
EndIf 
xWBrowse := {} 
xx       := 0
nXX      := 0
//faz o transporte das informações para um array à parte para excluir os itens que não vão (N/A)
For nX := 1 to Len(aWBrowse)
	If aWBrowse[nX,7] > 0  .and. Alltrim(aWBrowse[nX,2]) <> "N/A" 
	
		Aadd(xWBrowse,Array(Len(aWBrowse[nX])))
		nXX++
		For xx := 1 to Len(aWBrowse[nX])
			xWBrowse[nXX,xx] := aWBrowse[nX,xx]
		Next
	Endif
Next 

aWBrowse := xWBrowse
aWBrowse	:= aSort(aWBrowse,,, {|x, y| x[2] < y[2]})  //FR - 08/03/2023 - ordena por item da nf , IMPORTANTE PARA SPED AMAZONAS
Return(aWBrowse)

//-----------------------------------------------//
//Browse da esquerda: Dados do Xml
//-----------------------------------------------//
Static Function fWBrowse1(oDlg,aWBrowse1)
Local   aPos1     := {}
Local   x         := 0 
Private cAuxTag

aPos1 := U_FRTela(oDlg,"UP")    

aPos1[1] := aPos1[1] + 44		//TOP       45 
aPos1[2] := aPos1[2] +10   		//LEFT      11    
aPos1[3] := aPos1[3] *2			//BOTTOM    462.5   
aPos1[4] := aPos1[4] - 506 		//RIGHT     452

          //TWBrowse(): New ( [ nRow], [ nCol], [ nWidth], [ nHeight], [ bLine], [ aHeaders], [ aColSizes],[ oDlg], [ cField], [ uValue1], [ uValue2], [ bChange], [ bLDblClick], [ bRClick], [ oFont], [ oCursor],[ nClrFore], [ nClrBack], [ cMsg], [ uParam20], [ cAlias], [ lPixel], [ bWhen], [ uParam24], [ bValid], [ lHScroll], [ lVScroll] ) --> oObjeto
//FR - 12/11/2020 - adicionada coluna 'Segund.UM'
oWBrowse1 := TWBrowse():New( aPos1[1],aPos1[2],aPos1[3],aSizeAut[4]/2,,{'Item','Produto','Descrição','Pedido','It.Ped.','Quant.','Vl. Unit','Total','Vl. Ipi','Aliq.IPI','Sld.a.Vinc.','Segund.UM'},{20,30,30},;                      
oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )


//oDet vem do HFXMLL02P que chama a função da amarração por pedido que esta no HFXML020

aItensXML := {}
Aadd(aItensXML, space(TAMSX3("D1_ITEM")[1]) )

For x := 1 to Len(oDet)

	// Insert items here 
	//Aadd(aWBrowse1,{StrZero(Val(oDet[x]:_NITEM:TEXT),TAMSX3("D1_ITEM")[1]), oDet[x]:_PROD:_CPROD:TEXT, oDet[x]:_PROD:_XPROD:TEXT, oDet[x]:_PROD:_XPED:TEXT,oDet[x]:_PROD:_NITEPED:TEXT, oDet[x]:_PROD:_QCOM:TEXT, oDet[x]:_PROD:_VUNCOM:TEXT, oDet[x]:_PROD:_VPROD:TEXT, oDet[x]:_IMPOSTO:_IPI:_IPITRIB:_VIPI:TEXT, oDet[x]:_IMPOSTO:_IPI:_IPITRIB:_PIPI:TEXT })
	//                                                                    1                           2                          3                         4                           5                   6                        7                          8                                9                         10
	//em 26/4 -> as vezes algumas TAGs não Vem, então vamos verifica-las antes. oraite!
	Aadd(aItensXML, StrZero(Val(oDet[x]:_NITEM:TEXT),TAMSX3("D1_ITEM")[1]) )
	
	//Aadd(aWBrowse1,{StrZero(Val(oDet[x]:_NITEM:TEXT),TAMSX3("D1_ITEM")[1]), "", "", "", "", "", "", "", "", "", ""})
	Aadd(aWBrowse1,{StrZero(Val(oDet[x]:_NITEM:TEXT),TAMSX3("D1_ITEM")[1]), "", "", "", "", "", "", "", "", "", "",""})	//FR 12/11/2020
	cAuxTag := "oDet["+AllTrim(str(x))+"]:_PROD:_CPROD:TEXT"
	if Type(cAuxTag) <> "U"
		aWBrowse1[len(aWBrowse1)][2] := oDet[x]:_PROD:_CPROD:TEXT
	endif
	cAuxTag := "oDet["+AllTrim(str(x))+"]:_PROD:_XPROD:TEXT"
	if Type(cAuxTag) <> "U"
		aWBrowse1[len(aWBrowse1)][3] := oDet[x]:_PROD:_XPROD:TEXT
	endif
	cAuxTag := "oDet["+AllTrim(str(x))+"]:_PROD:_XPED:TEXT"
	if Type(cAuxTag) <> "U"
		aWBrowse1[len(aWBrowse1)][4] := oDet[x]:_PROD:_XPED:TEXT
	endif
	cAuxTag := "oDet["+AllTrim(str(x))+"]:_PROD:_NITEMPED:TEXT"
	if Type(cAuxTag) <> "U"
		aWBrowse1[len(aWBrowse1)][5] := oDet[x]:_PROD:_NITEMPED:TEXT
	endif
	cAuxTag := "oDet["+AllTrim(str(x))+"]:_PROD:_QCOM:TEXT"
	if Type(cAuxTag) <> "U"
		aWBrowse1[len(aWBrowse1)][6]	:= oDet[x]:_PROD:_QCOM:TEXT
		aWBrowse1[len(aWBrowse1)][11]	:= oDet[x]:_PROD:_QCOM:TEXT
	endif
	cAuxTag := "oDet["+AllTrim(str(x))+"]:_PROD:_VUNCOM:TEXT"
	if Type(cAuxTag) <> "U"
		//aWBrowse1[len(aWBrowse1)][7] := oDet[x]:_PROD:_VUNCOM:TEXT   //TRANSFORM( 0 ,X3Picture("D1_QUANT"))
		aWBrowse1[len(aWBrowse1)][7] := Alltrim( TRANSFORM( Val(oDet[x]:_PROD:_VUNCOM:TEXT) ,X3Picture("C7_PRECO")) )     //FR - 28/07/2021 - Solicitações Rafael Lobitsky
	endif
	cAuxTag := "oDet["+AllTrim(str(x))+"]:_PROD:_VPROD:TEXT"
	if Type(cAuxTag) <> "U"
		aWBrowse1[len(aWBrowse1)][8] := oDet[x]:_PROD:_VPROD:TEXT
	endif
	cAuxTag := "oDet["+AllTrim(str(x))+"]:_IMPOSTO:_IPI:_IPITRIB:_VIPI:TEXT"
	if Type(cAuxTag) <> "U"
		aWBrowse1[len(aWBrowse1)][9] := oDet[x]:_IMPOSTO:_IPI:_IPITRIB:_VIPI:TEXT
	endif
	cAuxTag := "oDet["+AllTrim(str(x))+"]:_IMPOSTO:_IPI:_IPITRIB:_PIPI:TEXT"
	if Type(cAuxTag) <> "U"
		aWBrowse1[len(aWBrowse1)][10] := oDet[x]:_IMPOSTO:_IPI:_IPITRIB:_PIPI:TEXT
	endif
	cAuxTag := "oDet["+AllTrim(str(x))+"]:_PROD:_UCOM:TEXT"
	If Type(cAuxTag) <> "U"
		aWBrowse1[len(aWBrowse1)][12] := oDet[x]:_PROD:_UCOM:TEXT //FR 12/11/2020 pega a unidade de medida do xml para comparar se é igual a segunda unid. medida do pedido
	Endif
Next x

//FR - 06/07/2021 - Modificações para flexibilizar amarração de pedido x XML - Solicitado por Rafael Lobitsky
If GETNEWPAR("XM_ASTERXP" , "S") == "S"  //UTILIZA * PARA UNIFICAR VÁRIOS ITENS DA NOTA COM APENAS 1 DO PC
	Aadd(aItensXML, "*" )  				//FR - 08/05/2023 - Retirada esta opção por ter ficado obsoleta (em virtude da nova opção N/A)
Endif 
//Aadd(aItensXML, "[x]Seleciona" )		//FR - 08/05/2023 - Retirada esta opção por ter ficado obsoleta (em virtude da nova opção N/A)
//-------------------------------------------------------------------------------------------------------------------------------------//
//FR - 02/03/2023 - COPAG - qdo não for selecionar algum item, poder deixar em branco com esta inscrição "N/A" -> Não se Aplica
//desta maneira, não precisará desmarcar os itens que por automatização foram marcados, evitando retrabalho
//e evita ter que usar a opção [x], pois desperdiçaria os itens que já vem marcados de forma automatizada
//-------------------------------------------------------------------------------------------------------------------------------------//
Aadd(aItensXML, "N/A" )		

//@ 043, 015 LISTBOX oWBrowse1 SIZE 217, 155 OF oDlg PIXEL //ColSizes 50,50
oWBrowse1:SetArray(aWBrowse1)
oWBrowse1:bLine := {|| ;
					{	aWBrowse1[oWBrowse1:nAt,01],;
					 	aWBrowse1[oWBrowse1:nAt,02],;                      
						aWBrowse1[oWBrowse1:nAt,03],;
						aWBrowse1[oWBrowse1:nAt,04],;
						aWBrowse1[oWBrowse1:nAt,05],;
						aWBrowse1[oWBrowse1:nAt,06],;
						aWBrowse1[oWBrowse1:nAt,07],;
						aWBrowse1[oWBrowse1:nAt,08],;
						aWBrowse1[oWBrowse1:nAt,09],; 	//valor ipi
						aWBrowse1[oWBrowse1:nAt,10],;	//aliq ipi
						aWBrowse1[oWBrowse1:nAt,11],;
						aWBrowse1[oWBrowse1:nAt,12]		};       		//FR 12/11/2020  //segunda UM
					}

// DoubleClick event - apenas o segundo browse será editavel
// oWBrowse1:bLDblClick := {|| EditaTRB(aWBrowse1,oWBrowse1) } 


Return

//Browse da direita : pedido de compra 
Static Function fWBrowse2(oDlg,aWBrowse1,aCamposPC,xPosItem)
//Local oWBrowse2
Local aPos1 	:= {}
Local cItXm 	:= ""
Local nItXm 	:= 0
Local nSaldoV 	:= 0
Local x         := 0 
Local cCodFor   := ""  //FR - 29/08/2022 - ECO AUTOMAÇÃO - Código Produto do fornecedor, caso haja este campo C7_CODFOR adicina
Local fr        := 0
Local nQtVinc   := 0

aPos1 := U_FRTela(oDlg,"UP")     //1,1,181.75,766        //a função traz este cálculo

aPos1[1] := aPos1[1] + 44		//TOP       1->45 
aPos1[2] := aPos1[2] +10   		//LEFT      1->11    
aPos1[3] := (aPos1[3] *2)+20	//BOTTOM    157.25->334.50
aPos1[4] := aPos1[4] - 506 		//RIGHT     681->175

           //TWBrowse(): New ( [ nRow], [ nCol], [ nWidth], [ nHeight], [ bLine], [ aHeaders], [ aColSizes],[ oDlg], [ cField], [ uValue1], [ uValue2], [ bChange], [ bLDblClick], [ bRClick], [ oFont], [ oCursor],[ nClrFore], [ nClrBack], [ cMsg], [ uParam20], [ cAlias], [ lPixel], [ bWhen], [ uParam24], [ bValid], [ lHScroll], [ lVScroll] ) --> oObjeto
//oWBrowse2 := TWBrowse():New( aPos1[1] , aPos1[3], aPos1[3]-20, aSizeAut[4]/2,,{'Item','Item NF','Produto','Descrição','Pedido','Quant.','Entregue','Vl. Unit','Total','Vl. Ipi','Aliq.IPI'},{20,30,30},;                              
oWBrowse2 := TWBrowse():New( aPos1[1] , aPos1[3], aPos1[3]-20, aSizeAut[4]/2,,aCamposPC,{20,30,30},;                              
oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
For x := 1 to Len(aF4For)

	If aF4For[x,1]
	
		DbSelectArea("SC7")
		DbSetOrder(14)		//C7_FILENT + C7_NUM + C7_ITEM
		DbSeek( xFilEnt(xFilial("SC7")) + aF4For[x,3] )
		//daikin nf 000166869
		If xPosItem == 0
			While ( !SC7->(Eof()) .And. SC7->C7_FILENT + SC7->C7_NUM = xFilEnt(xFilial("SC7")) + aF4For[x,3] )
				
				nSldPed := SC7->C7_QUANT-SC7->C7_QUJE-SC7->C7_QTDACLA
				cCodFor := "" 

				If (nSldPed > 0 .And. Empty(SC7->C7_RESIDUO) )
				
					DbSelectArea("SB1")
					DbSetOrder(1)
					DbSeek( xFilial("SB1") + SC7->C7_PRODUTO )
					cItXm     := "    "
					nSaldoV   := 0
					nItXm     := 0
					nSaldoVX  := 0
					nQtVinc   := 0
					//FR - 29/08/2022 - ECO AUTOMAÇÃO
					If SC7->(FieldPos("C7_CODFOR")) > 0
						cCodFor  := SC7->C7_CODFOR
					Endif 

					
					//-------------------------------------------------------------------------------------//
					//1a. tentativa -> buscar o item número do pedido + item  = numero pedido + item no xml
					//-------------------------------------------------------------------------------------//
					For fr := 1 to Len(aWBrowse1)
						If AllTrim(SC7->C7_NUM + SC7->C7_ITEM) == Alltrim(Substr(aWBrowse1[fr,4],1,6) + aWBrowse1[fr,5]) 
							nItXm := fr
						Endif 
						If nItXm > 0     	//FR - se encontrar o item, já amarra (se por acaso, o código do fornecedor for o mesmo que o SB1)
							//cCodFor  := SC7->C7_CODFOR  //código do produto do fornecedor
							cItXm    := aWBrowse1[nItXm][1]
							//nSaldoV  := ( Val(aWBrowse1[nItXm][6]) - SC7->C7_QUANT) //FR - qtde do XML - Qt do pedido = Saldo a vincular							
							//nSaldoV  := Val(aWBrowse1[nItXm][6])  				//FR - qtde do xml							
							
							//FR - 07/03/2023 - CORREÇÃO DO CÁLCULO DA QTDE VINCULADA x SALDO DISPONÍVEL DO PC											
							If cModelo <> "RP" //FR - 10/07/2023 - TRATATIVA BROWSE NF SERVIÇO
								nSaldoV    := ( Val(aWBrowse1[nItXm][6]) - nSldPed )
								nQtVinc    := nSldPed

								If Val(aWBrowse1[nItXm][11]) > 0 .and. Val(aWBrowse1[nItXm][11]) >= nQtVinc
									nSaldoVX := Val(aWBrowse1[nItXm][11]) -  nQtVinc 	//calcula saldo a vincular do xml
										
								Elseif Val(aWBrowse1[nItXm][11]) > 0 .and. Val(aWBrowse1[nItXm][11]) >= nSldPed
									nSaldoVX := Val(aWBrowse1[nItXm][11]) -  nSldPed
								Elseif Val(aWBrowse1[nItxm][11]) > 0 .and. Val(aWBrowse1[nItxm][11]) < nQtVinc 
									nSaldoVX := Val(aWBrowse1[nItxm][11]) - Val(aWBrowse1[nItxm][11])
									nQtVinc  := Val(aWBrowse1[nItxm][11])
								Endif 
								//atualiza o campo saldo a vincular do browse do xml:
								//aWBrowse1[nItxm][11] := aWBrowse1[nItxm][11] - aWBrowse1[nItxm][6]
								If Val(aWBrowse1[nItXm][11]) >= nSaldoVX //debita do saldo eqto tiver saldo senão fica negativo
									aWBrowse1[nItXm][11] := cValToChar(nSaldoVX) //atualiza o acols do browse do xml
								Endif 
								Exit
								//FR - 07/03/2023 - CORREÇÃO DO CÁLCULO DA QTDE VINCULADA x SALDO DISPONÍVEL DO PC											
							Else //FR - 10/07/2023 - TRATATIVA BROWSE NF SERVIÇO
								nQtVinc    := nSldPed
								nSaldoV    := ( Val(aWBrowse1[nItXm][4]) - nSldPed )
								aWBrowse1[nItXm][9]:= cValToChar(nSaldoV)
								Exit							 
							Endif 
						Endif
					Next

					//----------------------------------------------------------------------------------//
					//2a. tentativa -> buscar o item pelo código produto = código produto fornecedor,
					//busca associação pelo código do produto, pois há casos em que a empresa utiliza 
					//o mesmo código interno = cód. fornecedor
					//----------------------------------------------------------------------------------//
					If nItXm == 0 
						nSaldoVX := 0 
						For fr := 1 to Len(aWBrowse1)
							If AllTrim(SC7->C7_PRODUTO) == Alltrim(aWBrowse1[fr,2]) 
								nItXm := fr
							Endif 
							If nItXm > 0     	//FR - se encontrar o item, já amarra (se por acaso, o código do fornecedor for o mesmo que o SB1)
								//cCodFor  := SC7->C7_CODFOR  //código do produto do fornecedor
								cItXm    := aWBrowse1[nItXm][1]
								//nSaldoV  := ( Val(aWBrowse1[nItXm][6]) - SC7->C7_QUANT) //FR - qtde do XML - Qt do pedido = Saldo a vincular
								//nSaldoV  := Val(aWBrowse1[nItXm][6])  				//FR - qtde do xml							

								//FR - 07/03/2023 - CORREÇÃO DO CÁLCULO DA QTDE VINCULADA x SALDO DISPONÍVEL DO PC											
								If cModelo <> "RP" //FR - 10/07/2023 - TRATATIVA BROWSE NNF SERVIÇO
									nSaldoV    := ( Val(aWBrowse1[nItXm][6]) - nSldPed )
									nQtVinc    := nSldPed

									If Val(aWBrowse1[nItXm][11]) > 0 .and. Val(aWBrowse1[nItXm][11]) >= nQtVinc
										nSaldoVX := Val(aWBrowse1[nItXm][11]) -  nQtVinc 	//calcula saldo a vincular do xml
										
									Elseif Val(aWBrowse1[nItXm][11]) > 0 .and. Val(aWBrowse1[nItXm][11]) >= nSldPed
										nSaldoVX := Val(aWBrowse1[nItXm][11]) -  nSldPed
									Elseif Val(aWBrowse1[nItxm][11]) > 0 .and. Val(aWBrowse1[nItxm][11]) < nQtVinc 
										nSaldoVX := Val(aWBrowse1[nItxm][11]) - Val(aWBrowse1[nItxm][11])
										nQtVinc  := Val(aWBrowse1[nItxm][11])
									Endif 
									//atualiza o campo saldo a vincular do browse do xml:
									//aWBrowse1[nItxm][11] := aWBrowse1[nItxm][11] - aWBrowse1[nItxm][6]
									If Val(aWBrowse1[nItXm][11]) >= nSaldoVX //debita do saldo eqto tiver saldo senão fica negativo
										aWBrowse1[nItXm][11] := cValToChar(nSaldoVX) //atualiza o acols do browse do xml
									Endif 
									Exit
									//FR - 07/03/2023 - CORREÇÃO DO CÁLCULO DA QTDE VINCULADA x SALDO DISPONÍVEL DO PC											
								Else //FR - 10/07/2023 - TRATATIVA BROWSE NF SERVIÇO
									nQtVinc            := nSldPed
									nSaldoV            := ( Val(aWBrowse1[nItXm][4]) - nSldPed )
									aWBrowse1[nItXm][9]:= cValToChar(nSaldoV)
									Exit
								Endif 								
							Endif
						Next
					Endif 

					//--------------------------------------------------------------------------------------------------------------//
					//3a. tentativa -> buscar o item pelo código do produto do fornecedor = campo C7_CODFOR caso exista este campo
					//se na 2a. tentativa não amarrou, tenta por outra chave -> C7_CODFOR (caso exista)
					//--------------------------------------------------------------------------------------------------------------//
					If nItXm == 0 
						nSaldoVX := 0 
						
						If SC7->(FieldPos("C7_CODFOR")) > 0
							//cCodFor  := SC7->C7_CODFOR
							For fr := 1 to Len(aWBrowse1)
								//nItXm := aScan(aWBrowse1,{|x| AllTrim(x[2]) = AllTrim(SC7->C7_CODFOR)  } )    //FR - 09/05/2020 - trazer associado (Adar)					
								If AllTrim(SC7->C7_CODFOR) == Alltrim(aWBrowse1[fr,2]) 
									nItXm := fr
								Endif 
								If nItXm > 0     	//FR - se encontrar o item, já amarra (se por acaso, o código do fornecedor for o mesmo que o SB1)
									cCodFor  := SC7->C7_CODFOR  //código do produto do fornecedor
									cItXm    := aWBrowse1[nItXm][1]
									//nSaldoV  := ( Val(aWBrowse1[nItXm][6]) - SC7->C7_QUANT) //FR - qtde do XML - Qt do pedido = Saldo a vincular
									//nSaldoV  := Val(aWBrowse1[nItXm][6])  				//FR - qtde do xml							

									If cModelo <> "RP" //FR - 10/07/2023 - TRATATIVA BROWSE NNF SERVIÇO
										//FR - 07/03/2023 - CORREÇÃO DO CÁLCULO DA QTDE VINCULADA x SALDO DISPONÍVEL DO PC											
										nSaldoV    := ( Val(aWBrowse1[nItXm][6]) - nSldPed )
										nQtVinc    := nSldPed

										If Val(aWBrowse1[nItXm][11]) > 0 .and. Val(aWBrowse1[nItXm][11]) >= nQtVinc
											nSaldoVX := Val(aWBrowse1[nItXm][11]) -  nQtVinc 	//calcula saldo a vincular do xml
										
										Elseif Val(aWBrowse1[nItXm][11]) > 0 .and. Val(aWBrowse1[nItXm][11]) >= nSldPed
											nSaldoVX := Val(aWBrowse1[nItXm][11]) -  nSldPed
										Elseif Val(aWBrowse1[nItxm][11]) > 0 .and. Val(aWBrowse1[nItxm][11]) < nQtVinc 
											nSaldoVX := Val(aWBrowse1[nItxm][11]) - Val(aWBrowse1[nItxm][11])
											nQtVinc  := Val(aWBrowse1[nItxm][11])
										Endif 
										//atualiza o campo saldo a vincular do browse do xml:
										//aWBrowse1[nItxm][11] := aWBrowse1[nItxm][11] - aWBrowse1[nItxm][6]
										If Val(aWBrowse1[nItXm][11]) >= nSaldoVX //debita do saldo eqto tiver saldo senão fica negativo
											aWBrowse1[nItXm][11] := cValToChar(nSaldoVX) //atualiza o acols do browse do xml
										Endif 
										Exit
										//FR - 07/03/2023 - CORREÇÃO DO CÁLCULO DA QTDE VINCULADA x SALDO DISPONÍVEL DO PC											
									Else 	//FR - 10/07/2023 - TRATATIVA BROWSE NF SERVIÇO
										nQtVinc            := nSldPed
										nSaldoV            := ( Val(aWBrowse1[nItXm][4]) - nSldPed )
										aWBrowse1[nItXm][9]:= cValToChar(nSaldoV)
										Exit
									Endif 
								Endif
							Next
							
						Endif 

					Endif 

					//--------------------------------------------------------------------------------------------------------------//
					//4a. tentativa -> buscar pelas amarrações SA5 ou ZB5
					//--------------------------------------------------------------------------------------------------------------//
					If nItXm == 0 
						//---------------------------------------------------------------------------//
						//pelo código do produto fornecedor, captura o código produto interno SB1:
						// Aadd(aRet, TRB->PRODFORNEC)
						//Aadd(aRet, TRB->PRODINTERNO)
						//--------------------------------------------------------------------------//				
						For fr := 1 to Len(aWBrowse1)
							aInfo    := {}
							cCodProd := ""
							cProdFor := ""
							nSaldoVX := 0
							aInfo    := FGETZB5( Alltrim(aWBrowse1[fr,2])  , SC7->C7_FORNECE, SC7->C7_LOJA, "F"  ) 
							If Len(aInfo) > 0
								cProdFor:= aInfo[1]    //produto fornecedor
								cCodProd:= aInfo[2]    //produto interno
							Endif 

							If Empty(cCodProd)
								aInfo := FGETSA5( Alltrim(aWBrowse1[fr,2])  , SC7->C7_FORNECE, SC7->C7_LOJA , "F"  ) 
								If Len(aInfo) > 0
									cProdFor:= aInfo[1]   //produto fornecedor
									cCodProd:= aInfo[2]   //produto interno
								Endif 
							Endif  

							If !Empty(cCodProd)
								If AllTrim(SC7->C7_PRODUTO) == Alltrim(cCodProd) 
									nItXm  := fr
									cCodFor:= cProdFor
								Endif 
								If nItXm > 0     	//FR - se encontrar o item, já amarra									
									cItXm    := aWBrowse1[nItXm][1]
									//nSaldoV  := ( Val(aWBrowse1[nItXm][6]) - SC7->C7_QUANT) //FR - qtde do XML - Qt do pedido = Saldo a vincular
									//nSaldoV  := Val(aWBrowse1[nItXm][6])  				//FR - qtde do xml

									If cModelo <> "RP" //FR - 10/07/2023 - TRATATIVA BROWSE NNF SERVIÇO
										//FR - 07/03/2023 - CORREÇÃO DO CÁLCULO DA QTDE VINCULADA x SALDO DISPONÍVEL DO PC											
										nSaldoV    := ( Val(aWBrowse1[nItXm][6]) - nSldPed )
										nQtVinc    := nSldPed
										
										If Val(aWBrowse1[nItXm][11]) > 0 .and. Val(aWBrowse1[nItXm][11]) >= nQtVinc
											nSaldoVX := Val(aWBrowse1[nItXm][11]) -  nQtVinc 	//calcula saldo a vincular do xml
										
										Elseif Val(aWBrowse1[nItXm][11]) > 0 .and. Val(aWBrowse1[nItXm][11]) >= nSldPed
											nSaldoVX := Val(aWBrowse1[nItXm][11]) -  nSldPed
										Elseif Val(aWBrowse1[nItxm][11]) > 0 .and. Val(aWBrowse1[nItxm][11]) < nQtVinc 
											nSaldoVX := Val(aWBrowse1[nItxm][11]) - Val(aWBrowse1[nItxm][11])
											nQtVinc  := Val(aWBrowse1[nItxm][11])
										Endif 
										//atualiza o campo saldo a vincular do browse do xml:
										//aWBrowse1[nItxm][11] := aWBrowse1[nItxm][11] - aWBrowse1[nItxm][6]
										If Val(aWBrowse1[nItXm][11]) >= nSaldoVX //debita do saldo eqto tiver saldo senão fica negativo
											aWBrowse1[nItXm][11] := cValToChar(nSaldoVX) //atualiza o acols do browse do xml
										Endif 
										Exit
										//FR - 07/03/2023 - CORREÇÃO DO CÁLCULO DA QTDE VINCULADA x SALDO DISPONÍVEL DO PC											
									Else 	//FR - 10/07/2023 - TRATATIVA BROWSE NF SERVIÇO
										nQtVinc            := nSldPed
										nSaldoV            := ( Val(aWBrowse1[nItXm][4]) - nSldPed )
										aWBrowse1[nItXm][9]:= cValToChar(nSaldoV)
										Exit
									Endif 
								Endif								
							Endif 					 
						Next
					Endif 

					// Insert items here			
					//aCamposPC := {'Item','Item NF','Produto','Descrição','Pedido','Quant.','Qtd Vinculada','Entregue','Vl. Unit','Total','Vl. Ipi','Aliq.IPI','Segund.UM','Qt.SegUM','Cod.Fornec'}		
						
					Aadd(aWBrowse2,{ SC7->C7_ITEM,;		//1
									cItXm,;				//2
									SC7->C7_PRODUTO,;	//3
									Alltrim(SB1->B1_DESC),;		//4
									SC7->C7_NUM,;		//5
									SC7->C7_QUANT,;		//6		//qtde do pedido
									nQtVinc		,;		//7     //qtde vinculada
									SC7->C7_QUJE,;		//8
									SC7->C7_PRECO,;		//9
									SC7->C7_TOTAL,;		//10
									SC7->C7_VALIPI,;	//11
									SC7->C7_IPI,; 		//12 
									SC7->C7_SEGUM,;		//13 	//FR - 12/11/2020
									SC7->C7_QTSEGUM,;	//14	//FR - 12/11/2020
									cCodFor;			//15    //FR - 29/08/2022
									})
				Endif		//If (nSldPed > 0 .And. Empty(SC7->C7_RESIDUO) )			

				DbSelectArea("SC7")
				SC7->( DbSkip() )		
			Enddo

		//FR - 19/09/2022 - PROJETO PAPIRUS
		//qdo a seleção é feita por item
		Else
			nSaldoV   := 0
			nItXm     := 0
			nSaldoVX  := 0
			nQtVinc   := 0
			//qdo há seleção de item, pega apenas o item selecionado			
			DbSeek( xFilEnt(xFilial("SC7")) + aF4For[x,3] + aF4For[x,xPosItem] )
			If Alltrim(SC7->C7_NUM + SC7->C7_ITEM) == Alltrim(aF4For[x,3] + aF4For[x,xPosItem])
				nSldPed := SC7->C7_QUANT-SC7->C7_QUJE-SC7->C7_QTDACLA
				cCodFor := "" 

				If (nSldPed > 0 .And. Empty(SC7->C7_RESIDUO) )
				
					DbSelectArea("SB1")
					DbSetOrder(1)
					DbSeek( xFilial("SB1") + SC7->C7_PRODUTO )
					cItXm     := "    "
					nSaldoV   := 0
					nItXm     := 0
					//FR - 29/08/2022 - ECO AUTOMAÇÃO
					If SC7->(FieldPos("C7_CODFOR")) > 0
						cCodFor  := SC7->C7_CODFOR
					Endif 
					
					//-------------------------------------------------------------------------------------//
					//1a. tentativa -> buscar o item número do pedido + item  = numero pedido + item no xml
					//-------------------------------------------------------------------------------------//
					For fr := 1 to Len(aWBrowse1)
						nSaldoVX := 0

						If AllTrim(SC7->C7_NUM + SC7->C7_ITEM) == Alltrim(Substr(aWBrowse1[fr,4],1,6) + aWBrowse1[fr,5]) 
							nItXm := fr
						Endif 
						If nItXm > 0     	//FR - se encontrar o item, já amarra (se por acaso, o código do fornecedor for o mesmo que o SB1)
							//cCodFor  := SC7->C7_CODFOR  //código do produto do fornecedor
							cItXm    := aWBrowse1[nItXm][1]
							//nSaldoV  := ( SC7->C7_QUANT - Val(aWBrowse1[nItXm][6])) //FR - qtde do XML - Qt do pedido = Saldo a vincular
							//nSaldoV  := Val(aWBrowse1[nItXm][6])  				//FR - qtde do xml							
							
							//FR - 07/03/2023 - CORREÇÃO DO CÁLCULO DA QTDE VINCULADA x SALDO DISPONÍVEL DO PC											
							nSaldoV    := ( Val(aWBrowse1[nItXm][6]) - nSldPed )
							nQtVinc    := nSldPed

							If Val(aWBrowse1[nItXm][11]) > 0 .and. Val(aWBrowse1[nItXm][11]) >= nQtVinc
								nSaldoVX := Val(aWBrowse1[nItXm][11]) -  nQtVinc 	//calcula saldo a vincular do xml
									
							Elseif Val(aWBrowse1[nItXm][11]) > 0 .and. Val(aWBrowse1[nItXm][11]) >= nSldPed
								nSaldoVX := Val(aWBrowse1[nItXm][11]) -  nSldPed
							Elseif Val(aWBrowse1[nItxm][11]) > 0 .and. Val(aWBrowse1[nItxm][11]) < nQtVinc 
								nSaldoVX := Val(aWBrowse1[nItxm][11]) - Val(aWBrowse1[nItxm][11])
								nQtVinc  := Val(aWBrowse1[nItxm][11])
							Endif 
							//atualiza o campo saldo a vincular do browse do xml:
							//aWBrowse1[nItxm][11] := aWBrowse1[nItxm][11] - aWBrowse1[nItxm][6]
							If Val(aWBrowse1[nItXm][11]) >= nSaldoVX //debita do saldo eqto tiver saldo senão fica negativo
								 aWBrowse1[nItXm][11] := cValToChar(nSaldoVX) //atualiza o acols do browse do xml
							Endif 
							Exit
							//FR - 07/03/2023 - CORREÇÃO DO CÁLCULO DA QTDE VINCULADA x SALDO DISPONÍVEL DO PC											
						Endif
					Next

					//----------------------------------------------------------------------------------//
					//2a. tentativa -> buscar o item pelo código produto = código produto fornecedor,
					//busca associação pelo código do produto, pois há casos em que a empresa utiliza 
					//o mesmo código interno = cód. fornecedor
					//----------------------------------------------------------------------------------//
					If nItXm == 0 
						nSaldoVX := 0

						For fr := 1 to Len(aWBrowse1)
							If AllTrim(SC7->C7_PRODUTO) == Alltrim(aWBrowse1[fr,2]) 
								nItXm := fr
							Endif 
							If nItXm > 0     	//FR - se encontrar o item, já amarra (se por acaso, o código do fornecedor for o mesmo que o SB1)
								//cCodFor  := SC7->C7_CODFOR  //código do produto do fornecedor
								cItXm    := aWBrowse1[nItXm][1]
								//nSaldoV  := ( SC7->C7_QUANT - Val(aWBrowse1[nItXm][6])) //FR - qtde do XML - Qt do pedido = Saldo a vincular
								//nSaldoV  := Val(aWBrowse1[nItXm][6])  				//FR - qtde do xml							
								
								//FR - 07/03/2023 - CORREÇÃO DO CÁLCULO DA QTDE VINCULADA x SALDO DISPONÍVEL DO PC											
								nSaldoV    := ( Val(aWBrowse1[nItXm][6]) - nSldPed )
								nQtVinc    := nSldPed

								If Val(aWBrowse1[nItXm][11]) > 0 .and. Val(aWBrowse1[nItXm][11]) >= nQtVinc
									nSaldoVX := Val(aWBrowse1[nItXm][11]) -  nQtVinc 	//calcula saldo a vincular do xml
									
								Elseif Val(aWBrowse1[nItXm][11]) > 0 .and. Val(aWBrowse1[nItXm][11]) >= nSldPed
									nSaldoVX := Val(aWBrowse1[nItXm][11]) -  nSldPed
								Elseif Val(aWBrowse1[nItxm][11]) > 0 .and. Val(aWBrowse1[nItxm][11]) < nQtVinc 
									nSaldoVX := Val(aWBrowse1[nItxm][11]) - Val(aWBrowse1[nItxm][11])
									nQtVinc  := Val(aWBrowse1[nItxm][11])
								Endif 
								//atualiza o campo saldo a vincular do browse do xml:
								//aWBrowse1[nItxm][11] := aWBrowse1[nItxm][11] - aWBrowse1[nItxm][6]
								If Val(aWBrowse1[nItXm][11]) >= nSaldoVX //debita do saldo eqto tiver saldo senão fica negativo
									 aWBrowse1[nItXm][11] := cValToChar(nSaldoVX) //atualiza o acols do browse do xml
								Endif 
								Exit
								//FR - 07/03/2023 - CORREÇÃO DO CÁLCULO DA QTDE VINCULADA x SALDO DISPONÍVEL DO PC											
							Endif
						Next
					Endif 

					//--------------------------------------------------------------------------------------------------------------//
					//3a. tentativa -> buscar o item pelo código do produto do fornecedor = campo C7_CODFOR caso exista este campo
					//se na 1a. tentativa não amarrou, tenta por outra chave -> C7_CODFOR (caso exista)
					//--------------------------------------------------------------------------------------------------------------//
					If nItXm == 0 
						nSaldoVX := 0 
						
						If SC7->(FieldPos("C7_CODFOR")) > 0
							//cCodFor  := SC7->C7_CODFOR
							For fr := 1 to Len(aWBrowse1)
								//nItXm := aScan(aWBrowse1,{|x| AllTrim(x[2]) = AllTrim(SC7->C7_CODFOR)  } )    //FR - 09/05/2020 - trazer associado (Adar)					
								If AllTrim(SC7->C7_CODFOR) == Alltrim(aWBrowse1[fr,2]) 
									nItXm := fr
								Endif 
								If nItXm > 0     	//FR - se encontrar o item, já amarra (se por acaso, o código do fornecedor for o mesmo que o SB1)
									cCodFor  := SC7->C7_CODFOR  //código do produto do fornecedor
									cItXm    := aWBrowse1[nItXm][1]
									//nSaldoV  := ( Val(aWBrowse1[nItXm][6]) - SC7->C7_QUANT) //FR - qtde do XML - Qt do pedido = Saldo a vincular
									//nSaldoV  := Val(aWBrowse1[nItXm][6])  				//FR - qtde do xml							
									
									//FR - 07/03/2023 - CORREÇÃO DO CÁLCULO DA QTDE VINCULADA x SALDO DISPONÍVEL DO PC											
									nSaldoV    := ( Val(aWBrowse1[nItXm][6]) - nSldPed )
									nQtVinc    := nSldPed

									If Val(aWBrowse1[nItXm][11]) > 0 .and. Val(aWBrowse1[nItXm][11]) >= nQtVinc
										nSaldoVX := Val(aWBrowse1[nItXm][11]) -  nQtVinc 	//calcula saldo a vincular do xml
									
									Elseif Val(aWBrowse1[nItXm][11]) > 0 .and. Val(aWBrowse1[nItXm][11]) >= nSldPed
										nSaldoVX := Val(aWBrowse1[nItXm][11]) -  nSldPed
									Elseif Val(aWBrowse1[nItxm][11]) > 0 .and. Val(aWBrowse1[nItxm][11]) < nQtVinc 
										nSaldoVX := Val(aWBrowse1[nItxm][11]) - Val(aWBrowse1[nItxm][11])
										nQtVinc  := Val(aWBrowse1[nItxm][11])
									Endif 
									//atualiza o campo saldo a vincular do browse do xml:
									//aWBrowse1[nItxm][11] := aWBrowse1[nItxm][11] - aWBrowse1[nItxm][6]
									If Val(aWBrowse1[nItXm][11]) >= nSaldoVX //debita do saldo eqto tiver saldo senão fica negativo
										 aWBrowse1[nItXm][11] := cValToChar(nSaldoVX) //atualiza o acols do browse do xml
									Endif 
									Exit
									//FR - 07/03/2023 - CORREÇÃO DO CÁLCULO DA QTDE VINCULADA x SALDO DISPONÍVEL DO PC											
								Endif
							Next
						
						Endif 

					Endif 

					//--------------------------------------------------------------------------------------------------------------//
					//4a. tentativa -> buscar pelas amarrações SA5 ou ZB5
					//--------------------------------------------------------------------------------------------------------------//
					If nItXm == 0 
						//---------------------------------------------------------------------------//
						//pelo código do produto fornecedor, captura o código produto interno SB1:
						// Aadd(aRet, TRB->PRODFORNEC)
						//Aadd(aRet, TRB->PRODINTERNO)
						//--------------------------------------------------------------------------//				
						For fr := 1 to Len(aWBrowse1)
							aInfo    := {}
							cCodProd := ""
							cProdFor := ""
							nSaldoVX := 0
							aInfo    := FGETZB5( Alltrim(aWBrowse1[fr,2])  , SC7->C7_FORNECE, SC7->C7_LOJA, "F"  ) 
							
							If Len(aInfo) > 0
								cProdFor:= aInfo[1]    //produto fornecedor
								cCodProd:= aInfo[2]    //produto interno
							Endif 

							If Empty(cCodProd)
								aInfo := FGETSA5( Alltrim(aWBrowse1[fr,2])  , SC7->C7_FORNECE, SC7->C7_LOJA , "F"  ) 
								If Len(aInfo) > 0
									cProdFor:= aInfo[1]   //produto fornecedor
									cCodProd:= aInfo[2]   //produto interno
								Endif 
							Endif           
						
							//loop para checar no array do xml, quem corresponde ao produto interno encontrado
							If !Empty(cCodProd)							
							
								If AllTrim(SC7->C7_PRODUTO) == Alltrim(cCodProd) 
									nItXm  := fr
									cCodFor:= cProdFor
								Endif 
								If nItXm > 0     	//FR - se encontrar o item, já amarra									
									cItXm    := aWBrowse1[nItXm][1]
									//nSaldoV  := ( Val(aWBrowse1[nItXm][6]) - SC7->C7_QUANT) //FR - qtde do XML - Qt do pedido = Saldo a vincular
									//nSaldoV  := Val(aWBrowse1[nItXm][6])  				//FR - qtde do xml							

									//FR - 07/03/2023 - CORREÇÃO DO CÁLCULO DA QTDE VINCULADA x SALDO DISPONÍVEL DO PC											
									nSaldoV    := ( Val(aWBrowse1[nItXm][6]) - nSldPed )
									nQtVinc    := nSldPed

									If Val(aWBrowse1[nItXm][11]) > 0 .and. Val(aWBrowse1[nItXm][11]) >= nQtVinc
										nSaldoVX := Val(aWBrowse1[nItXm][11]) -  nQtVinc 	//calcula saldo a vincular do xml
									
									Elseif Val(aWBrowse1[nItXm][11]) > 0 .and. Val(aWBrowse1[nItXm][11]) >= nSldPed
										nSaldoVX := Val(aWBrowse1[nItXm][11]) -  nSldPed
									Elseif Val(aWBrowse1[nItxm][11]) > 0 .and. Val(aWBrowse1[nItxm][11]) < nQtVinc 
										nSaldoVX := Val(aWBrowse1[nItxm][11]) - Val(aWBrowse1[nItxm][11])
										nQtVinc  := Val(aWBrowse1[nItxm][11])
									Endif 
									//atualiza o campo saldo a vincular do browse do xml:
									//aWBrowse1[nItxm][11] := aWBrowse1[nItxm][11] - aWBrowse1[nItxm][6]
									If Val(aWBrowse1[nItXm][11]) >= nSaldoVX //debita do saldo eqto tiver saldo senão fica negativo
										 aWBrowse1[nItXm][11] := cValToChar(nSaldoVX) //atualiza o acols do browse do xml
									Endif 
									Exit
									//FR - 07/03/2023 - CORREÇÃO DO CÁLCULO DA QTDE VINCULADA x SALDO DISPONÍVEL DO PC											
								Endif							
							Endif 
						Next
					Endif 

					// Insert items here			
					//aCamposPC := {'Item','Item NF','Produto','Descrição','Pedido','Quant.','Qtd Vinculada','Entregue','Vl. Unit','Total','Vl. Ipi','Aliq.IPI','Segund.UM','Qt.SegUM','Cod.Fornec'}		
						
					Aadd(aWBrowse2,{ SC7->C7_ITEM,;		//1
									cItXm,;				//2
									SC7->C7_PRODUTO,;	//3
									Alltrim(SB1->B1_DESC),;		//4
									SC7->C7_NUM,;		//5
									SC7->C7_QUANT,;		//6	 //qtde do pedido
									nQtVinc	,;			//7  //qtde vinculada
									SC7->C7_QUJE,;		//8
									SC7->C7_PRECO,;		//9
									SC7->C7_TOTAL,;		//10
									SC7->C7_VALIPI,;	//11
									SC7->C7_IPI,; 		//12 
									SC7->C7_SEGUM,;		//13 	//FR - 12/11/2020
									SC7->C7_QTSEGUM,;	//14	//FR - 12/11/2020
									cCodFor;			//15    //FR - 29/08/2022
									})

				Endif		//If (nSldPed > 0 .And. Empty(SC7->C7_RESIDUO) )
			Endif //If Alltrim(SC7->C7_NUM + SC7->C7_ITEM) == Alltrim(aF4For[x,3] + aF4For[x,xPosItem])				
		Endif	//qdo há seleção de item, pega apenas o item selecionado  	
	Endif

Next x
    
oWBrowse2:SetArray(aWBrowse2)
oWBrowse2:bLine := {|| {	aWBrowse2[oWBrowse2:nAt,01],;
							aWBrowse2[oWBrowse2:nAt,02],;                      
							aWBrowse2[oWBrowse2:nAt,03],;
							Alltrim(aWBrowse2[oWBrowse2:nAt,04]),;
							aWBrowse2[oWBrowse2:nAt,05],;
							aWBrowse2[oWBrowse2:nAt,06],;
							aWBrowse2[oWBrowse2:nAt,07],;
							aWBrowse2[oWBrowse2:nAt,08],;
							aWBrowse2[oWBrowse2:nAt,09],;
							aWBrowse2[oWBrowse2:nAt,10],;
							aWBrowse2[oWBrowse2:nAt,11],;
							aWBrowse2[oWBrowse2:nAt,12],;
							aWBrowse2[oWBrowse2:nAt,13],;
							aWBrowse2[oWBrowse2:nAt,14],; 	//FR 12/11/2020 //segunda UM
							aWBrowse2[oWBrowse2:nAt,15]; 	//FR 29/08/2022 - Código produto fornecedor
							};        		
						}

// DoubleClick event
 oWBrowse2:bLDblClick := { |nRow,nCol,nFlags| EditaTRB(@nRow,@nCol,@nFlags,aWBrowse2,oWBrowse2,oDlg) }
// oWBrowse2:bChange := { || oSaypc:Refresh()}
oWBrowse2:bChange     := { || HFXML23Chg(@oWBrowse2,@oSaypc,@oSayqt) }

Return()

//----------------------------------------------------------------//
//Função  : EditaTRB
//Objetivo: Editar o item do browse da direita (pedido de compra) 
//----------------------------------------------------------------//
Static Function EditaTRB(nRow,nCol,nFlags,aWBrowse,oWBrowse,oDlg) 
//Local nSaldoAv	:= 0      	//FR - 18/08/2020
Local AITEMS	:= aItensXML
Local aDim, oDlg2, oBtn
Local lAtiva	:= .F.

Default nRow := 0
Default nCol := 0

//If oWBrowse:ColPos() <> 2 
If oWBrowse:ColPos() <> 2 //.and. oWBrowse:ColPos() <> 7		//só pode editar as colunas de item xml ou saldo a vincular somente essas duas colunas
	Return
Endif

GetCellRect( @oWBrowse , @aDim )
        
   	DEFINE MSDIALOG oDlg2 FROM 0,0 TO 0,0 STYLE nOR(WS_VISIBLE, WS_POPUP) PIXEL WINDOW oWBrowse:oWnd 
      
		cCombo1:= aWBrowse[oWBrowse:nAt,02]  //aItems[1]
	    oCombo1 := TComboBox():New(0,0,{|u|if(PCount()>0,cCombo1:=u,cCombo1)},aItems,80,20,oDlg2,,,{|| verseja(aWBrowse,oWBrowse:nAt,cCombo1,oWBrowse,@lAtiva,oDlg,@lUnifica,@lMarkIt) },,,.T.,,,.T.,,.F.,,,,'cCombo1')
	    oCombo1:Move(-2,-2,((aDim[4]-aDim[2])+4), ((aDim[3]-aDim[1])+4) )
	    oDlg2:Move( aDim[1], aDim[2], (aDim[4]-aDim[2]), (aDim[3]-aDim[1]) )
	    @ 0,0 Button oBtn PROMPT "" Size 0,0 OF oDlg2
	    oBtn:bGotFocus := {|| oDlg2:nLastKey:=VK_RETURN, oDlg2:End(0) }  
   
	ACTIVATE DIALOG oDlg2 CENTERED ON INIT (oDlg2:Move( aDim[1], aDim[2], (aDim[4]-aDim[2]), (aDim[3]-aDim[1]) ))

	If lAtiva
		lAtiva := .F.
		fAjustaQtd(aWBrowse,oWBrowse:nAt)	
	EndIf
    
Return

//-------------------------------------------------------------------------//
//Função  : verseja 
//Objetivo: Verificar se o item do browse da direita (pedido compra) já foi 
//          amarrado com o item do browse da esquerda (xml)
//-------------------------------------------------------------------------//
Static Function verseja(aWBrowse,nAtu,cCombo1,oWBrowse,lAtiva,oDlg,lUnifica,lMarkIt)
Local lRet 			:= .T.
Local nIt  			:= 0
Local nX			:= 0
Local aRet	:= {}
Local nTotQX:= 0
//Local nTotPC:= 0
Local nIpi  := 0
Local _nIpi := 0
Local lDifIPI := .F. 

Local aVetSel := {} //Vetor que conterá os itens do XML a serem associados ao PC no caso de ser escolhida a opção "Selecionar"
Local xt      := 0
Local x       := 0
Local z       := 0 

Default nSaldoAv  := 0

//FR - 05/07/2021 - solicitações de Rafael Lobitsky - flexibilizar tela de amarração XML x PC
//FR - 06/07/2021 - a) incluir * no combo para amarrar todos itens xml -> item pc
If Alltrim(cCombo1) = "*"
	lUnifica := .T.
	      
	For nX := 1 to Len(aWBrowse1)		
		nTotQX += Val(aWBrowse1[nX,11])   //somar o campo qtde de cada item para obter a qtde total
		//armazena as alíquotas de ipi de cada item e compara se há diferença entre alíquotas ou se é a mesma para todos
		//para unificar todos os itens do XML em um único item de pedido de compra, é necessário que as alíquotas sejam as mesmas ou tudo zero
		//caso contrário, não permitirá esta unificação
		If nX == 1
			nIpi   := Val(aWBrowse1[nX,10])
			_nIpi  := nIpi
		Else
			nIpi   := Val(aWBrowse1[nX,10])
			If nIpi <> _nIpi
				lDifIPI := .T.
				_nIpi := nIpi
			Endif			
		Endif 
	Next
	
	If lDifIPI
		//lUnifica := .F.  	
		MsgAlert("Há Diferentes Alíquotas de IPI nos Itens!","Atenção") 
		//cCombo1 := ""  	
	Endif
	
	If lUnifica
		aRet	:= fQtdaVinc(nTotQX,aWBrowse[nAtu,6],nTotQX)
		//aRet := {.T.,nSldXml,nQtdPed,nQtdVinc,nQuant}
		If aRet[1]
			For xt := 1 to Len(aWBrowse1)
				//aWBrowse1[xt,11]	:= TRANSFORM( 0 ,X3Picture("D1_QUANT")) //TRANSFORM(aRet[2] + aRet[4] - aRet[5],X3Picture("D1_QUANT"))  
				aWBrowse1[xt,11]	:= Alltrim(TRANSFORM( aRet[2] - aRet[5] ,X3Picture("D1_QUANT"))) //TRANSFORM(aRet[2] + aRet[4] - aRet[5],X3Picture("D1_QUANT"))
			Next
			aWBrowse[nAtu,7]	:= aRet[5]
			aWBrowse[nAtu,2]	:= cCombo1
		Else
			cCombo1	:= aWBrowse[nAtu,2]	
		Endif
	Endif
	
Endif

//FR - 05/07/2021 - solicitações de Rafael Lobitsky - flexibilizar tela de amarração XML x PC
If Alltrim(cCombo1) = "[x]Seleciona"
	lMarkIt := .T.
	aVetSel := {}
	/*
		aVetRet[nCont,1] := aVetF3[fr,2] //item xml
		aVetRet[nCont,2] := aVetF3[fr,3] //produto
		aVetRet[nCont,3] := aVetF3[fr,5] //qtde
	*/
	
	aVetSel := fTelaMark(aWBrowse1,aWBrowse[nAtu,3],aWBrowse[nAtu,4], oDlg)  //(browse xml, produto, descrição, dialog)
	x      := 0
	xt     := 0
	nTotQx := 0
	If Len(aVetSel) > 0
		For x := 1 to Len(aVetSel)
			nTotQx += Val(aVetSel[x,3])		
		Next
	
		aRet     := fQtdaVinc(nTotQX,aWBrowse[nAtu,6],nTotQX) 
				
		If aRet[1] //se o retorno da vinculação de qtde foi .T.		
			
			//atualiza o browse da direita (pedido de compra) 
			aWBrowse[nAtu,7]	:= aRet[5]
			z					:= 0
			aWBrowse[nAtu,2]    := ""
			For x := 1 to Len(aVetSel)
				cCombo1             	:= aVetSel[x,1] + ","
				aWBrowse[nAtu,2]		+= Alltrim(cCombo1)   //coloca os itens selecionados na caixinha do item, como pode haver mais que um 1 item selecionado, separa por , (vírgula)
				//xPosZera	        	:= aScan( aWBrowse1,	{|x| x[1] == aVetSel[x,1] } )
				For z := 1 to Len(aWBrowse1) 
					If Alltrim(aWBrowse1[z,1]) == Alltrim(aVetSel[x,1])
						aWBrowse1[z,11]	:= Alltrim(TRANSFORM( aRet[2] - aRet[5] ,X3Picture("D1_QUANT"))) //TRANSFORM( 0 ,X3Picture("D1_QUANT")) 
					Endif						
				Next 				
			Next
			
		Else
			cCombo1	:= aWBrowse[nAtu,2]	
		Endif
		
	Else
		cCombo1	:= aWBrowse[nAtu,2]
	Endif
		
Endif

//FR - 05/07/2021 - solicitações de Rafael Lobitsky - flexibilizar tela de amarração XML x PC
//Aqui é a amarração normal, de 1 para 1
If !lUnifica .and. !lMarkIt
	If !Empty(cCombo1)
	
		nIt		:= aScan( aWBrowse,		{|x| x[2] == cCombo1 } )  //escaneia o array para procurar se o item já foi associado a outro produto  
		nIt1	:= aScan( aWBrowse1,	{|x| x[1] == cCombo1 } )
	
		If cCombo1 <> "N/A"
			If nIt > 0
				If aWBrowse[nAtu,2] == cCombo1
					lAtiva	:= .T. 
					lRet	:= .T.
				ElseIf	VAL(aWBrowse1[nIt1,11]) == 0
					U_MYAVISO("ITEM","ITEM XML JA AMARRADO A OUTRO ITEM DO PEDIDO "+aWBrowse[nIt][1],{"OK"},2)
					cCombo1 := "    "
					lRet	:= .T.
				Else
		
					aRet	:= fQtdaVinc(VAL(aWBrowse1[nIt1,11]),aWBrowse[nAtu,6],aWBrowse[nAtu,7])
					lAtiva	:= .F.
		
					If aRet[1]
						aWBrowse1[nIt1,11]	:= TRANSFORM(aRet[2] + aRet[4] - aRet[5],X3Picture("D1_QUANT"))
						aWBrowse[nAtu,7]	:= aRet[5]
						aWBrowse[nAtu,2]	:= cCombo1
					Else
					EndIf	
				EndIf
			Else		
				aRet	:= fQtdaVinc(VAL(aWBrowse1[nIt1,11]),aWBrowse[nAtu,6],aWBrowse[nAtu,7])
				lAtiva	:= .F.

				If aRet[1]
					//aWBrowse1[nIt1,11]	:= TRANSFORM(aRet[2] + aRet[4] - aRet[5],X3Picture("D1_QUANT"))
					XSALDOXML := Val(aWBrowse1[nIt1,11])
					aWBrowse1[nIt1,11]	:= TRANSFORM(XSALDOXML - aRet[5],X3Picture("D1_QUANT"))
					aWBrowse[nAtu,7]	:= aRet[5]
					aWBrowse[nAtu,2]	:= cCombo1
				Else
					cCombo1	:= aWBrowse[nAtu,2]
				EndIf		
			EndIf

		Else //se no combo, foi escolhida a opção "N/A" -> não se aplica, ou seja, este item não será associado por escolha do usuário
			//-------------------------------------------------------------------------------------------------------------------------------------//
			//FR - 02/03/2023 - COPAG - qdo não for selecionar algum item, poder deixar em branco com esta inscrição "N/A" -> Não se Aplica
			//desta maneira, não precisará desmarcar os itens que por automatização foram marcados, evitando retrabalho
			//e evita ter que usar a opção [x], pois desperdiçaria os itens que já vem marcados de forma automatizada
			//-------------------------------------------------------------------------------------------------------------------------------------//
			aWBrowse[nAtu,2]	:= cCombo1 //"N/A"
		Endif 
	Else
		lAtiva := .F.
	
		If !Empty(aWBrowse[nAtu,2])
			nIt1	:= aScan( aWBrowse1,	{|x| x[1] == aWBrowse[nAtu,2]} )
			aWBrowse1[nIt1,11]	:= aWBrowse1[nIt1,6]
			
			For nX := 1 to Len(aWBrowse)
				If nX == nAtu
					aWBrowse[nAtu,7]	:= 0
				Else
					If aWBrowse[nX,2] == aWBrowse[nAtu,2]
						aWBrowse1[nIt1,11]	:= TRANSFORM(VAL(aWBrowse1[nIt1,11]) - aWBrowse[nX,7],X3Picture("D1_QUANT"))
					EndIf
				EndIf
			Next nX
	
			aWBrowse[nAtu,2] := cCombo1
	
		EndIf
	EndIf
Endif

//If Alltrim(cCombo1) == "N/A"
//	lRet := .T.
//Endif 

oWBrowse1:Refresh()
oWBrowse2:Refresh()

Return(lRet)

*******************************************
Static Function fAjustaQtd(aWBrowse,nAtu)
*******************************************
Local aRet	:= {}
Local nIt1	:= aScan( aWBrowse1,	{|x| x[1] == aWBrowse[nAtu,2] } )

aRet	:= fQtdaVinc(VAL(aWBrowse1[nIt1,11]),aWBrowse[nAtu,6],aWBrowse[nAtu,7])

If aRet[1]
	aWBrowse1[nIt1,11]	:= TRANSFORM(aRet[2] + aRet[4] - aRet[5],X3Picture("D1_QUANT"))
	aWBrowse[nAtu,7]	:= aRet[5]
	oWBrowse1:Refresh()
	oWBrowse2:Refresh()
EndIf

Return

******************************************************************
Static Function fQtdaVinc(nSldXml,nQtdPed,nQtdVinc)
******************************************************************
Local nOpc      := 0
Local nQuant	:= 0
Local oDlgQtd
Local oOk
Local oGroup
Local oSay
//fQtdaVinc(VAL(aWBrowse1[nIt1,11]),aWBrowse[nAtu,6],aWBrowse[nAtu,7])
If nQtdVinc > 0
	nQuant := nQtdVinc
Elseif nSldXml > nQtdPed
	nQuant := nQtdPed
Else
	nQuant := nSldXml
EndIf

DEFINE MSDIALOG oDlgQtd TITLE "Quantidade a Vincular" FROM 000, 000  TO 110, 300 PIXEL

	@ 004, 004 GROUP oGroup TO 035, 144 OF oDlgQtd PIXEL
	@ 016, 012 SAY oSay PROMPT "Quantidade: " SIZE 050, 007 OF oDlgQtd PIXEL
	@ 014, 065 MSGET nQuant PICTURE X3Picture("D1_QUANT") SIZE 060, 010 OF oDlgQtd PIXEL
	@ 038, 107 BUTTON oOk PROMPT "OK" ACTION (nOpc := fVldQtd(nSldXml,nQtdPed,nQtdVinc,nQuant),iIf(nOpc==1,oDlgQtd:End(),.F.)) SIZE 037, 012 OF oDlgQtd PIXEL
	
ACTIVATE MSDIALOG oDlgQtd

If nOpc == 1
	aRet := {.T.,nSldXml,nQtdPed,nQtdVinc,nQuant}
Else
	aRet := {.F.}
EndIf

Return(aRet)

******************************************************************
Static Function fVldQtd(nSldXml,nQtdPed,nQtdVinc,nQuant)
******************************************************************
Local cMsg	:= ""
Local nOpc	:= 1

If nQuant > nQtdPed
	cMsg := "Quantidade maior do que a quantidade do pedido!!"
Else
	If nQtdVinc > 0
		nSldXml := nSldXml + nQtdVinc
	EndIf

	If nSldXml < nQuant
		cMsg := "Quantidade maior do que o saldo do XML!!"
	EndIf
EndIf

If !Empty(cMsg)
	U_MYAVISO("QUANTIDADE VINCULADA",cMsg,{"OK"},2)
	nOpc := 0
EndIf

Return(nOpc)
//----------------------------------------------------------------//
//Função  : validxml
//Objetivo: Ao clicar no botão "confirmar", valida todos os itens
//          da getdados se estão amarrados (pedido x xml )
//----------------------------------------------------------------//
Static Function validxml(cModelo,aWBrowse1,aWBrowse2,lMarkIt)

Local lRet   	:= .T.
Local nI     	:= 0
Local lValid 	:= .T.
Local xValLiqnf := 0
Local xValLiqpc := 0
Local cAviso    := ""
Local cValidaVal:= GetNewPar("XM_VLDXMNF", "N")	//FR - 17/01/2022 - indica se valida o valor do XML com o que foi amarrado nos itens do pedido comparando os totais do xml x pc

Local cTravPreNF := GetNewPar("XM_PED_GBR","N")   //FR - 14/06/2022 - parâmetro "Trava Pré-Nota" S-Sim (Trava), N-Não , P-Pergunta, incluir "E" de ESPECÍFICO para Brasmolde
Local nValMoedaX:= 0							//FR - 14/06/2022 - Brasmolde - armazena o valor em dólar do item do PC
Local nMoeda    := 0							//FR - 14/06/2022 - Brasmolde - armazena a moeda do pedido de compra
Local cPC       := "" 							//FR - 14/06/2022 - Brasmolde - armazena o número do pedido de compra
Local axPedMaior:= {} 							//FR - 14/06/2022 - Brasmolde - armazena os números dos pedidos com divergência a maior
Local axPedMenor:= {} 							//FR - 14/06/2022 - Brasmolde - armazena os números dos pedidos com divergência a menor

Local nY        := 0
Local nTXPC     := 0
//Local cMsgVlItem:= "" 
Local lDifMaior := .F. 						//FR - 14/06/2022 - Brasmolde - indica que há divergência a MAIOR entre o valor unit do xml e o vlr unitário do PC
Local lDifMenor := .F. 						//FR - 14/06/2022 - Brasmolde - indica que há divergência a MENOR entre o valor unit do xml e o vlr unitário do PC
Local cMsgMaior := ""                      	//FR - 14/06/2022 - Brasmolde - armazena msg que sinaliza divergência a maior 
Local cMsgMenor := ""						//FR - 14/06/2022 - Brasmolde - armazena msg que sinaliza divergência a menor

xValTotXML := 0 
//FR - 06/07/2021 - Modificações Solicitadas por Rafael Lobitsky
If !lMarkIt
	For nI := 1 To Len(aWBrowse1)		
		
		If VAL(aWBrowse1[nI,11]) > 0 
			lValid := .F.
		Endif
		//If cModelo <> "57"		//FR - 09/05/2022 - Alteração - #12682 - Brasmolde
			xValTotXML += Val(aWBrowse1[nI,8]) + Val(aWBrowse1[nI,9])  //vlr total + vlr ipi
		//Else 
		//	xValTotXML += Val(aWBrowse1[nI,8]) + aWBrowse1[nI,9]  //vlr total + vlr ipi
		//Endif		
	Next nI 

	//------------------------------------------------------------------------------------------------------------------------------------//
	//VALIDAÇÃO COPAG - ao não escolher amarrar um determinado item do PC, marca-lo como "N/A" para que seja ignorado mesmo e 
	//não precise alertar que não foi amarrado porque foi por escolha do próprio usuário não amarrar determinado item
	//FR - 02/03/2023 - busca se tem algum item marcado como "N/A" -> não se aplica, se sim, não faz essa validação de item não amarrado
	//------------------------------------------------------------------------------------------------------------------------------------//
	For nI := 1 to Len(aWBrowse2)
		If !Empty(aWBrowse2[nI,2]) .and. aWBrowse2[nI,2] == "N/A"
			lValid := .T.
		Endif
	Next

	
	If !lValid
		cAviso := "Há Item(ns) Não Amarrado(s)!"+CRLF + "Por Favor, Faça A Amarração Para Continuar "
	Endif
Endif

For nI := 1 to Len(aWBrowse1)
	xValLiqnf += Val(aWBrowse1[nI,8])
Next

For nI := 1 to Len(aWBrowse2)
	If !Empty(aWBrowse2[nI,2])
		xValLiqpc += aWBrowse2[nI,10]
	Endif
	
	//FR - 14/06/2022 - Brasmolde 
	If cTravPreNF <> "N"  
		
		cPC       := aWBrowse2[nI,5]  //pega o pedido ref. ao item lido
		cITAMARRA := aWBrowse2[nI,2]  //pega o item do XML, que foi amarrado no PC 
	
		nMoeda := Posicione("SC7",1,xFilial("SC7")+ cPC, "C7_MOEDA")  //pega a moeda registrada nesse pedido
		//If nMoeda <> 1
			nTXPC  := Posicione("SC7",1,xFilial("SC7")+ cPC, "C7_TXMOEDA")	
	        If nTXPC == 0
	        	nTXPC := 1
	        Endif 
			//faz o looping de leitura dos itens do XML pra encontrar o item do PC que foi amarrado e comparar os valores do item
		
			For nY := 1 To Len(aWBrowse1)
	
				If Alltrim(aWBrowse1[nY,1]) == Alltrim(cITAMARRA) 

					//calcula o valor do item na moeda do pedido de compra:										
					//FR - 08/08/2022 - Correção Brasmolde: o comando anterior não mantinha as casas decimais
					//converte o valor em dólar pela taxa do pedido de compra:
					//aWBrowse1 -> array do xml
					If cModelo <> "RP" //FR - 10/07/2023 - TRATATIVA BROWSE NNF SERVIÇO
						nValMoedaX:= Val(StrTran(StrTran(aWBrowse1[nY,7],".",""),",",".")) / nTXPC  
                    Else 
						nValMoedaX := Val(aWBrowse1[nY,5]) / nTXPC	//FR - 10/07/2023 - TRATATIVA BROWSE NF SERVIÇO
					Endif   
					//arredonda o valor unitario do xml:
					nValMoedaX     := Round(nValMoedaX,TamSx3("C7_TXMOEDA")[2])  			//arredonda para as mesmas casas decimais do campo C7_TXMOEDA
                    
					//arredonda o valor unitario do pedido de compra:
					//aWbrowse2 -> array do pedido compra
					aWBrowse2[nI,9]:= Round( aWBrowse2[nI,9], TamSx3("C7_TXMOEDA")[2] )  	//arredonda para as mesmas casas decimais do campo C7_TXMOEDA  
					
					//compara valor unitario do XML com o vlr unitario do PC:
					//conforme solicitado por Brunna da Brasmolde, se for maior, barra direto
					//se for menor, mostra pergunta se aceita divergência
					If nValMoedaX > aWBrowse2[nI,9]  
						//se for maior, o ponto entrada vai validar se barra ou não
						lDifMaior := .T. //valor unitário do XML MAIOR QUE vlr unitário do PC
						cMsgMaior += "O Item " + aWBrowse1[nY,1] + " do XML Possui Vlr. Unitário MAIOR que Vlr. Unitário do Pedido de Compra " + CRLF
						
						If Ascan(axPedMaior, cPC) == 0
							AADD(axPedMaior, cPC )
							AADD(axPedMaior, cMsgMaior)
						Endif

					Elseif nValMoedaX < aWBrowse2[nI,9]
						//se for menor, o pto entrada vai validar se barra ou não
						cMsgMenor += "O Item " + aWBrowse1[nY,1] + " do XML Possui Vlr. Unitário MENOR que Vlr. Unitário do Pedido de Compra " + CRLF
						lDifMenor := .T.  //valor unitário do XML MENOR que o vlr unitário do PC 
						
						If Ascan(axPedMenor, cPC) == 0
							AADD(axPedMenor, cPC )
							AADD(axPedMenor, cMsgMenor)
						Endif
						
					Else 
						//se for igual não faz nada
					Endif 
				
				Endif 
				
			Next 
				
	Endif 
	//FR - 14/06/2022 - Brasmolde 	
	
Next 

//FR - 17/01/2022 - validador do total da nota, para que ao selecionar os itens do PC, não seja menor que o valor total da nota
//divergências maiores serão tratadas em outras funções posteriores desta etapa
If cValidaVal == "S"
	If xValLiqpc < xValLiqnf
		lValid := .F.
		cAviso := "O Total do(s) Item(ns) Marcados: " + Transform(xValLiqpc, "@E 999,999,999.99") + "," + CRLF
	    cAviso += "Não Corresponde ao Total da NF: "+ Transform(xValLiqnf, "@E 999,999,999.99")   
	Endif
Endif	
	
//FR - 06/07/2021 - Modificações Solicitadas por Rafael Lobitsky

//FR - 14/06/2022 - Brasmolde
If cTravPreNF <>  "N" 
   
	If cTravPreNF == "E" //se o parâmetro "Trava Pré Nota" for diferente de "NÃO", é porque precisa validar a divergência//E-Específico -> trava tudo se for maior 

		If lDifMaior .or. lDifMenor  //se houver diferença a maior ou a menor	
		
			If ExistBlock("HFXMLVLPED")
			  	
			  	//cRet := U_HFXMLVLPED( axPedMaior, axPedMenor, cMsgMaior, lDifMaior, lDifMenor, cMsgMenor )	 //retornos do pto entrada: 1-Trava se Maior; 2-Trava se Menor; 3-Não Trava
				//aCabec := ExecBlock( "XMLPE001", .F., .F., { aCabec,oXml } ) 
				cRet := ExecBlock("HFXMLVLPED", .F., .F.,  {axPedMaior, axPedMenor, lDifMaior, lDifMenor} )
				If Alltrim(cRet) == "1" 	//trava a maior
					lValid := .F.        
				Elseif Alltrim(cRet) == "2" //trava a menor
					lValid := .F.
				Else 
					lValid := .T.
				Endif
				 
			EndIf
			 
		Endif
		
	Endif 
		
Endif
//FR - 14/06/2022 - Brasmolde
 
lRet := lValid
If !lValid
	//U_MYAVISO("XML","Há Item(ns) Não Amarrado(s)!"+CRLF + "Por Favor, Faça A Amarração Para Continuar ",{"VOLTAR"},2)
	If !Empty(cAviso)
		U_MYAVISO("VALIDADOR XML x PC",cAviso,{"VOLTAR"},2) 
	Endif 
	
Endif

If !Empty(cMsgMaior) .or. !Empty(cMsgMenor) 

    If !Empty(cMsgMaior)
		cAviso += CRLF + cMsgMaior
	Endif 
	
	If !Empty(cMsgMenor)
		cAviso += CRLF + cMsgMenor
	Endif 
	U_MYAVISO("VALIDADOR XML x PC",cAviso,{"FECHAR"},2)
Endif
//FR - 14/06/2022 - Brasmolde 


Return( lRet )

//----------------------------------------------------------------//
//Função  : fWBrowse3
//Objetivo: Monta browse para xml de CTE
//----------------------------------------------------------------//
Static Function fWBrowse3(oDlg,oXMLL)

Local   aPos1 := {}
Private cAuxTag
Private oDet

//FR - 19/06/2020 - TÓPICOS RAFAEL
aPos1 := U_FRTela(oDlg,"UP")     //1,1,181.75,766        //a função traz este cálculo

aPos1[1] := aPos1[1] + 44		//TOP       1 ->45
aPos1[2] := aPos1[2] +10   		//LEFT      1->11    
aPos1[3] := aPos1[3] *2			//BOTTOM    157.25->314.50   
aPos1[4] := aPos1[4] - 506 		//RIGHT     681->175

          //TWBrowse(): New ( [ nRow], [ nCol], [ nWidth], [ nHeight], [ bLine], [ aHeaders], [ aColSizes],[ oDlg], [ cField], [ uValue1], [ uValue2], [ bChange], [ bLDblClick], [ bRClick], [ oFont], [ oCursor],[ nClrFore], [ nClrBack], [ cMsg], [ uParam20], [ cAlias], [ lPixel], [ bWhen], [ uParam24], [ bValid], [ lHScroll], [ lVScroll] ) --> oObjeto
oWBrowse1 := TWBrowse():New( aPos1[1],aPos1[2],aPos1[3],aSizeAut[4]/2,,{'Item','Produto','Descrição','Pedido','It.Ped.','Quant.','Vl. Unit','Total','Vl. Ipi','Aliq.IPI','Sld.a.Vinc','Segund.UM'},{20,30,30},;                      
oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )                               
//FR - 19/06/2020 - TÓPICOS RAFAEL

//somente uma linha:                           // 1   2  3   4   5   6   7   8  9
Aadd(aItensXML, StrZero(1,TAMSX3("D1_ITEM")[1]) )   //Nomeia o 1o. item
Aadd(aWBrowse1,{StrZero(1,TAMSX3("D1_ITEM")[1]), "", "", "", "", "", "", "", 0, 0, 0, "" })   //FR - 09/05/2022 - #12682 - Brasmolde - erro ao associar PC qdo tipo XML é CTE
aWBrowse1[1][2] := "FRETE"

aWBrowse1[1][3] := oXML:_CTEPROC:_CTE:_INFCTE:_IDE:_NATOP:TEXT  
aWBrowse1[1][4] := "" //"PEDIDO" 	  //deixar em branco caso não haja pedido
aWBrowse1[1][5] := ""  //"IT.PEDIDO"  //deixar em branco caso não haja pedido
aWBrowse1[1][6] := cValToChar(Val(oXML:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ[1]:_CUNID:TEXT ))
aWBrowse1[1][7] := oXML:_CTEPROC:_CTE:_INFCTE:_VPREST:_VTPREST:TEXT   
aWBrowse1[1][8] := oXML:_CTEPROC:_CTE:_INFCTE:_VPREST:_VREC:TEXT  
//aWBrowse1[1][9] := 0  	//FR - 19/06/2020 - TÓPICOS RAFAEL - adicionadas esta posição para ficar alinhado com a mesma estrutura do array de NFE
//aWBrowse1[1][10]:= 0  	//FR - 19/06/2020 - TÓPICOS RAFAEL - adicionadas esta posição para ficar alinhado com a mesma estrutura do array de NFE
aWBrowse1[1][9] := "" 	//FR - 19/06/2020 - TÓPICOS RAFAEL - adicionadas esta posição para ficar alinhado com a mesma estrutura do array de NFE
aWBrowse1[1][10]:= "" 	//FR - 19/06/2020 - TÓPICOS RAFAEL - adicionadas esta posição para ficar alinhado com a mesma estrutura do array de NFE
aWBrowse1[1][11]:= cValToChar(Val(oXML:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ[1]:_CUNID:TEXT ))  //FR - 13/07/2023 - POSIÇÃO SALDO XML	//FR - 09/05/2022 - #12682 - Brasmolde - erro ao associar PC qdo tipo XML é CTE
aWBrowse1[1][12]:= ""  	//FR - 09/05/2022 - #12682 - Brasmolde - erro ao associar PC qdo tipo XML é CTE

oWBrowse1:SetArray(aWBrowse1)
oWBrowse1:bLine := {|| {aWBrowse1[oWBrowse1:nAt,01],aWBrowse1[oWBrowse1:nAt,02],;                      
aWBrowse1[oWBrowse1:nAt,03],aWBrowse1[oWBrowse1:nAt,04],aWBrowse1[oWBrowse1:nAt,05],;
aWBrowse1[oWBrowse1:nAt,06],aWBrowse1[oWBrowse1:nAt,07],aWBrowse1[oWBrowse1:nAt,08],aWBrowse1[oWBrowse1:nAt,09],aWBrowse1[oWBrowse1:nAt,10]}}


Return
//==================================================================================//
//Função  : fTelaMark  
//Autoria : Flávia Rocha
//Data    : 05/07/2021
//Objetivo: Dialog para marcar / desmarcar itens do XML para associar ao PC
//==================================================================================//
Static Function fTelaMark(aWBrowse1,xProd,xDesc,oDlg) 
//fTelaMark(aWBrowse1,aWBrowse[nAtu,2],aWBrowse[nAtu,3], oDlg)  //(browse xml, produto, descrição, dialog)
Local aPos1 := {}
Local aVetF3:= {}
Local oDlgM
Local nLiIni := 0
Local nCoIni := 0
Local nLiFim := 0
Local nCoFim := 0 
Local fr     := 0 
Local nCont  := 0

Local cAux   := ""
Local oOk  	 := LoadBitmap( GetResources(), "LBOK" )
Local oNo    := LoadBitmap( GetResources(), "LBNO" )
Local oLbxF3
Local bLineF3
Local oChk
Local oConf
Local lChk 		:= .F.
Local lValido   := .F.
Local aVetRet   := {} 
Local _nHeight  := 0
Local _nWidth   := 0 

Define FONT oBold    NAME "Arial" SIZE 0, -12 BOLD


cAux := "{IF(aVetF3[oLbxF3:nAt,1],oOk,oNo) "
cAux += ",aVetF3[oLbxF3:NAT,2]"
cAux += ",aVetF3[oLbxF3:nAt,3]"
cAux += ",aVetF3[oLbxF3:nAt,4]"
cAux += ",aVetF3[oLbxF3:nAt,5]"
//cAux += ",aVetF3[oLbxF3:nAt,6]"
//cAux += ",aVetF3[oLbxF3:nAt,7]"
//cAux += ",aVetF3[oLbxF3:nAt,8]"
cAux += "} 

bLineF3 := &("{ || "+ cAux +" }") 

For fr := 1 to Len(aWBrowse1) 
	nCont++
	Aadd(aVetF3,Array(5))	//adiciona uma linha nova  
	aVetF3[nCont,1] := .F.
	aVetF3[nCont,2] := aWBrowse1[fr,1] //item xml
	aVetF3[nCont,3] := aWBrowse1[fr,2] //produto
	aVetF3[nCont,4] := aWBrowse1[fr,3] //descrição
	//aVetF3[nCont,5] := aWBrowse1[fr,6] //qtde
	aVetF3[nCont,5] := aWBrowse1[fr,11]  //saldo
Next

aPos1 := U_FRTela(oDlg,"TOT")     //1,1,181.75,766        //a função traz este cálculo

//aPos1[1] := aPos1[1] 			//TOP       1 
//aPos1[2] := aPos1[2] +10   	//LEFT      1     ->11    
//aPos1[3] := aPos1[3] 			//BOTTOM    342.5
//aPos1[4] := aPos1[4] /2  		//RIGHT     762

nLiIni := aPos1[1] +5			//6
nCoIni := aPos1[2] + 10			//11
nLiFim := aPos1[3] /2			//171.25
nCoFim := aPos1[4] -30			//381.5

_nWidth:= nCoFim/2     			//366.5		 
	
_nHeight := nLiFim / 2			//85.62
//6-11 // 362,5-557
//Define MsDialog oDlgM TITLE "Marcação de Itens XML p/ Associar ao PC" From nLiIni,nCoIni To nLiFim,nCoFim  OF oDlg PIXEL //STYLE DS_MODALFRAME
Define MsDialog oDlgM TITLE "Marcação de Itens XML p/ Associar ao PC" From aPos1[1],aPos1[2] To aPos1[3],aPos1[4]  OF oDlg PIXEL //STYLE DS_MODALFRAME

	nLiIni += 5	
	@ nLiIni, nCoIni+5 SAY "Marque [x] Itens para Associar ao Produto: "  SIZE 180,20 PIXEL OF oDlgM FONT oBold COLOR CLR_HBLUE
	nLiIni += 10
	@nLiIni, nCoIni+5 SAY xProd + " - " + xDesc  SIZE 180,20 PIXEL OF oDlgM FONT oBold COLOR CLR_BLACK														 														
	
	nLiIni += 20
	oLbxF3:= TWBrowse():New( nLiIni, nCoIni, _nWidth, _nHeight ,,{"", "Item XML" , "Produto" , "Descrição", "Qtde XML" },,oDlgM,,,,,,,,,,,,.F.,,.T.,,.F.,,,)	
	oLbxF3:bLDblClick := { || fMarkCpo(aVetF3,oLbxF3) } 
	oLbxF3:SetArray(aVetF3)
	oLbxF3:bLine := bLineF3
	
	nLiIni  := _nHeight + 55 //85.625 + 50= 140.625
	//nCoFim1 := _nWidth -90 //-150 
	//nCoFim2 := _nWidth -70 //-130
	
	@ nLiIni,nCoIni+5 CHECKBOX oChk VAR lChk PROMPT "Inverte seleção" 	SIZE 70,7 	PIXEL OF oDlgM ON CLICK( aEval( aVetF3, {|x| x[1] := !x[1] } ), oLbxF3:Refresh() )
	@nLiIni, nCoIni+80 BUTTON oConf PROMPT "Confirmar" ACTION ( lValido := fRetorna(aVetF3,@aVetRet), iif(lValido, oDlgM:End(), .F.) ) SIZE 037,12 OF oDlgM PIXEL
	//nCoFim2 += 50
		
	@ nLiIni, nCoIni+160  BUTTON oCanc PROMPT "Sair" ACTION (oDlgM:End()) SIZE 037,12 OF oDlgM PIXEL

ACTIVATE MSDIALOG oDlgM CENTERED

//If lValido
	Return(aVetRet)
//Endif


//==================================================================================//
//Função  : fMarkCpo  
//Autoria : Flávia Rocha
//Data    : 05/07/2021
//Objetivo: Marca / Desmarca o(s) campo(s) do markbrowse
//==================================================================================//
Static Function fMarkCpo(aVetF3,oLbxF3)
Local nCol := 0
Local nRow := 0

nCol      := oLbxF3:ColPos() 
nRow    := oLbxF3:NAT 

//If nCol == 1
	aVetF3[oLbxF3:nAt][1] := !aVetF3[oLbxF3:nAt][1] 
//Endif

Return 

//==================================================================================//
//Função  : fRetorna  
//Autoria : Flávia Rocha
//Data    : 05/07/2021
//Objetivo: Povoa o vetor de retorno para a função principal de associação XML x PC
//==================================================================================//
Static Function fRetorna(aVetF3,aVetRet)
Local lRet := .F.
Local fr   := 0
Local nCont:= 0

For fr := 1 to Len(aVetF3)
	If aVetF3[fr,1] //se estiver marcado
		nCont++
		Aadd(aVetRet,Array(3))	//adiciona uma linha nova  
		aVetRet[nCont,1] := aVetF3[fr,2] //item xml
		aVetRet[nCont,2] := aVetF3[fr,3] //produto
		aVetRet[nCont,3] := aVetF3[fr,5] //qtde
		lRet    := .T.
	Endif
Next

Return(lRet)

//========================================================================//
//Função: fGetZB5(cProdFor,cCodFor,cLoja)
//Objetivo: Trazer o código do produto interno, via informação do 
//          código produto fornecedor, código fornecedor e loja
//========================================================================//
Static Function fGetZB5(cProd,cClieFor,cLoja,xTipoProd)

//Local cQuery := ""
Local aRet   := {}
Local cCNPJ  := ""
Private xZB5  	  := GetNewPar("XM_TABAMAR","ZB5")
Private xZB5_ 	  := iif(Substr(xZB5,1,1)=="S", Substr(xZB5,2,2), Substr(xZB5,1,3)) + "_"


//cQuery := " SELECT  " + CRLF
//cQuery += " " + xZB5_ + "PRODFI AS PRODINTERNO , "
//cQuery += " " + xZB5_ + "PRODFO AS PRODFORNEC ,  * "
//cQuery += " FROM " + RetSqlname(xZB5) + " ZB5 "
//cQuery += " WHERE "
//cQuery += " ZB5.D_E_L_E_T_ = ' ' "
SA2->(OrdSetFocus(1))
SA2->(Dbseek(xFilial("SA2") + cClieFor + cLoja))
cCNPJ := SA2->A2_CGC


If xTipoProd == "F"         //o tipo de produto informado no parâmetro é o produto do Fornecedor
   //cQuery += " AND RTRIM( " + xZB5_ + "PRODFO) = '" + Alltrim(cProd) + "' "
   	//ORDENA POR CNPJ + CÓDIGO PRODUTO DO FORNECEDOR
	(xZB5)->(OrdSetfocus(1))  //ZB5_FILIAL+ZB5_CGC+ZB5_PRODFO

Elseif xTipoProd == "I"     //o tipo de produto informado no parâmetro é o produto interno SB1	
    //cQuery += " AND RTRIM( " + xZB5_ + "PRODFI) = '" + Alltrim(cProd) + "' "
	//ORDENA POR CNPJ + CÓDIGO PRODUTO INTERNO
	(xZB5)->(OrdSetfocus(3))  //ZB5_FILIAL+ZB5_CGC+ZB5_PRODFI

Endif

//FAZ A BUSCA PELA ORDEM DEFINIDA ACIMA DE ACORDO COM O PARÂMETRO PASSADO NO CABEÇALHO
If (xZB5)->(Dbseek(xFilial(xZB5) + cCNPJ + Alltrim(cProd) ))
	Aadd(aRet, (xZB5)->(FieldGet(FieldPos(xZB5_+"PRODFO"))) )	//CÓD. PRODUTO FORNECEDOR
	Aadd(aRet, (xZB5)->(FieldGet(FieldPos(xZB5_+"PRODFI"))) )    //CÓD. PRODUTO INTERNO
Endif 
//cQuery += " AND RTRIM( " + xZB5_ + "FORNEC) = '" + Alltrim(cClieFor) + "' "
//cQuery += " AND RTRIM( " + xZB5_ + "LOJFOR) = '" + Alltrim(cLoja)    + "' "

//If Select("TRBFR") > 0
//	dbSelectArea("TRBFR")
//	dbCloseArea()
//Endif

//+-----------------------
//| Cria uma view no banco
//+-----------------------
//dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TRBFR", .T., .F. )
//dbSelectArea("TRBFR")

 //Contando os registros e voltando ao topo da tabela
//Count To nTotReg

//TRBFR->( dbGoTop() )
//If !TRBFR->(Eof())
//    Aadd(aRet, TRBFR->PRODFORNEC)
//    Aadd(aRet, TRBFR->PRODINTERNO)

//    dbSelectArea("TRBFR")
//	dbCloseArea()

//Endif 

Return(aRet)


//========================================================================//
//Função: fGetSA5(cCodProd, cClieFor,cLoja)
//Objetivo: Trazer o código do fornecedor, passando por parâmetro o código
//          interno, fornecedor e loja
//========================================================================//
Static Function fGetSA5(cCod,cClieFor,cLoja,xTipoProd)

//Local cQuery := ""
Local aRet   := {}

//cQuery := " SELECT A5_PRODUTO , A5_CODPRF , A5_FORNECE , A5_LOJA "
//cQuery += " FROM " + RetSqlname("SA5") + " SA5 "
//cQuery += " WHERE "
//cQuery += " SA5.D_E_L_E_T_ = ' ' "

If xTipoProd == "F"         //o tipo de produto informado no parâmetro é o produto do Fornecedor
   //cQuery += " AND RTRIM(A5_CODPRF) = '" + Alltrim(cCod) + "' "

   //ORDENA POR CODIGO+ LOJA FORNECEDOR + CÓDIGO PRODUTO DO FORNECEDOR
   SA5->(OrdSetfocus(14))	//A5_FILIAL+A5_FORNECE+A5_LOJA+A5_CODPRF
	If SA5->(Dbseek(xFilial("SA5") + Alltrim(cClieFor) + Alltrim(cLoja) + Alltrim(cCod) ))
		Aadd(aRet, SA5->A5_CODPRF)	
		Aadd(aRet, SA5->A5_PRODUTO)
	Endif
   
Elseif xTipoProd == "I"     //o tipo de produto informado no parâmetro é o produto interno SB1
    //cQuery += " AND RTRIM(A5_PRODUTO) = '" + Alltrim(cCod) + "' "
	
	//ORDENA POR CÓDIGO + LOJA FORNECEDOR + CÓDIGO PRODUTO INTERNO
	SA5->(OrdSetfocus(1))  //A5_FILIAL+A5_FORNECE+A5_LOJA+A5_PRODUTO+A5_FABR+A5_FALOJA+A5_REFGRD
	If SA5->(Dbseek(xFilial("SA5") + Alltrim(cClieFor) + Alltrim(cLoja) + Alltrim(cCod) ))
		Aadd(aRet, SA5->A5_CODPRF)   //CÓDIGO PROD. FORNECEDOR
		Aadd(aRet, SA5->A5_PRODUTO)  //CÓDIGO PROD. INTERNO
	Endif
    
Endif 

//cQuery += " AND A5_FORNECE        = '" + Alltrim(cClieFor) + "' "
//cQuery += " AND A5_LOJA           = '" + Alltrim(cLoja)    + "' "

//If Select("TRBFR") > 0
//	dbSelectArea("TRBFR")
//	dbCloseArea()
//Endif

//+-----------------------
//| Cria uma view no banco
//+-----------------------
//dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TRBFR", .T., .F. )
//dbSelectArea("TRBFR")

//TRBFR->( dbGoTop() )
//If !TRBFR->(Eof())
//    Aadd(aRet, TRBFR->A5_CODPRF)
//    Aadd(aRet, TRBFR->A5_PRODUTO)    

//    dbSelectArea("TRBFR")
//	dbCloseArea()
//Endif 

Return(aRet)

Static Function HFXML23Chg(oWBrowse2,oSaypc,oSayqt)

Local cRetFun := " "

//oMarkBw:oBrowse:Refresh(.T.)
oSaypc:Refresh()
oSayqt:Refresh()


Return cRetFun


//----------------------------------------------------------------//
//Função  : fWBrowse4
//Objetivo: Monta browse para xml de NFS-e
//User: Erick Gonçalves - Data: 05/06/2023
//----------------------------------------------------------------//
Static Function fWBrowse4(oDlg,aWBrowse1)
Local   aPos1     := {}
Private cAuxTag
Private xZBT  	  := GetNewPar("XM_TABITEM","ZBT")
Private xZBT_ 	  := iif(Substr(xZBT,1,1)=="S", Substr(xZBT,2,2), Substr(xZBT,1,3)) + "_"

aPos1 := U_FRTela(oDlg,"UP")    

aPos1[1] := aPos1[1] + 44		//TOP       45 
aPos1[2] := aPos1[2] +10   		//LEFT      11    
aPos1[3] := aPos1[3] *2			//BOTTOM    462.5   
aPos1[4] := aPos1[4] - 506 		//RIGHT     452

oWBrowse1 := TWBrowse():New( aPos1[1],aPos1[2],aPos1[3],aSizeAut[4]/2,,{'Item','Produto','Descrição','Quant.','Vl. Unit.','Total','Vl.ISS','Aliq.ISS','Sld.a.Vinc.','Segund.UM'},{20,30,30},;                      
oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

aItensXML := {}
Aadd(aItensXML, space(TAMSX3("D1_ITEM")[1]) )

If cModelo <> "RP" //FR - 10/07/2023 - TRATATIVA BROWSE NF SERVIÇO
	Aadd(aItensXML, StrZero(Val((xZBT)->(FieldGet(FieldPos(xZBT_+"ITEM")))),TAMSX3("D1_ITEM")[1]) )
Else 
	Aadd(aItensXML, "0001" )	//FR - 10/07/2023 - TRATATIVA BROWSE NF SERVIÇO
Endif 

//Adiciona item do xml
//Aadd(aWBrowse1,{StrZero(Val((xZBT)->(FieldGet(FieldPos(xZBT_+"ITEM")))),TAMSX3("D1_ITEM")[1]), "", "", "", "", "", "", "", "", "", "",""})	
//NF SERVIÇO NÃO TEM ZBT: 
Aadd(aWBrowse1,{"0001", "", "", "", "", "", "", "", "", "", "",""})	
	
	cAuxTag := "oDet:_PRODSRV:TEXT" // Código do produto
	if Type(cAuxTag) <> "U"
		aWBrowse1[len(aWBrowse1)][2] := oDet:_PRODSRV:TEXT
	endif

	cAuxTag := "oDet:_PRODSRV:TEXT" // Descrição do produto
	if Type(cAuxTag) <> "U"
		aWBrowse1[len(aWBrowse1)][3] := oDet:_DESSRV:TEXT 
	endif

	If Empty( aWBrowse1[len(aWBrowse1)][2] )
		aWBrowse1[len(aWBrowse1)][2] := "SERVICO"
	Endif

	If Empty( aWBrowse1[len(aWBrowse1)][3] ) 
		aWBrowse1[len(aWBrowse1)][3] := "SERVICO"
	Endif 

//Aadd(aWBrowse1,{(xZBT)->(FieldGet(FieldPos(xZBT_+"QUANT"))), "", "", "", "", "", "", "", "", "", "",""})	
	if Type(cAuxTag) <> "U"
		aWBrowse1[len(aWBrowse1)][4] := cValToChar((xZBT)->(FieldGet(FieldPos(xZBT_+"QUANT"))))
		aWBrowse1[len(aWBrowse1)][9] := cValToChar((xZBT)->(FieldGet(FieldPos(xZBT_+"QUANT"))))	
	EndIf

	If Empty( aWBrowse1[len(aWBrowse1)][4] ) 
		aWBrowse1[len(aWBrowse1)][4] := "1"
		aWBrowse1[len(aWBrowse1)][9] := "1"
	Endif 
	//aWBrowse1[len(aWBrowse1)][5] := cValToChar((xZBT)->(FieldGet(FieldPos(xZBT_+"VUNIT"))))
	
	cAuxTag := "oDet:_VRSERV:TEXT"
	if Type(cAuxTag) <> "U"
		aWBrowse1[len(aWBrowse1)][6] := oDet:_VRSERV:TEXT // Valor Total do Produto
		
		If Empty( aWBrowse1[len(aWBrowse1)][5] ) .or. Val( aWBrowse1[len(aWBrowse1)][5] ) == 0
			aWBrowse1[len(aWBrowse1)][5] := oDet:_VRSERV:TEXT
		Endif 
	endif

	cAuxTag := "oDet:_VRSERV:TEXT"
	if Type(cAuxTag) <> "U"
		aWBrowse1[len(aWBrowse1)][7] := oDet:_ALIQ:TEXT // Aliquota do ISS
	endif

	cAuxTag := "oDet:_VRSERV:TEXT"
	if Type(cAuxTag) <> "U"
		aWBrowse1[len(aWBrowse1)][8] := oDet:_VRISS:TEXT // Valor do ISS
	endif

//Aadd(aItensXML, "N/A" )		

oWBrowse1:SetArray(aWBrowse1)
oWBrowse1:bLine := {|| ;
					{	aWBrowse1[oWBrowse1:nAt,01],;
						aWBrowse1[oWBrowse1:nAt,02],;
						aWBrowse1[oWBrowse1:nAt,03],;
						aWBrowse1[oWBrowse1:nAt,04],;
						aWBrowse1[oWBrowse1:nAt,05],;
						aWBrowse1[oWBrowse1:nAt,06],;
						aWBrowse1[oWBrowse1:nAt,07],;
						aWBrowse1[oWBrowse1:nAt,08],;
						aWBrowse1[oWBrowse1:nAt,09]};						
					}

Return
