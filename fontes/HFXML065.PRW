#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ HFXML065 ³ Autor ³ Renan Oliveira        ³ Data ³16/06/2020³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tratamento para a chamada da rotina de auditoria fiscal    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//--------------------------------------------------------------------------//
//Alterações Realizadas:
//--------------------------------------------------------------------------//
//FR - 25/11/2020 - Tratamento para quando clicar numa nf de Serviço
//--------------------------------------------------------------------------//
//FR - 30/11/2020 - Tratamento para comparar os impostos: PIS / COFINS
//--------------------------------------------------------------------------//
//FR - 23/02/2021 - Tratamento p/ trazer NCM do SB1 caso na SD1 estiver vazia
//                  Solicitado pelo coord.GestãoXML: Rogério Lino
//--------------------------------------------------------------------------//
//FR - 16/08/2021 - Modificações para nova tela de análise fiscal
//                  modelo árvore
//--------------------------------------------------------------------------//

User function HFXML065()

Local aArea		:= GetArea()
Local aAreaZBZ  := {}  //ZBZ->(GetArea())		//FR - 25/11/2020
Local aAreaSF1  := SF1->(GetArea())				//FR - 25/11/2020
Local cNFiscal  := ""  //ZBZ->ZBZ_NOTA			//FR - 25/11/2020
Local cSerie    := ""  //ZBZ->ZBZ_SERIE			//FR - 25/11/2020
Local cForn     := ""  //ZBZ->ZBZ_CODFOR		//FR - 25/11/2020
Local cLoja     := ""  //ZBZ->ZBZ_LOJFOR		//FR - 25/11/2020
Local cChave    := ""
Local nValmerc	:= 0
Local nTBaseipi	:= 0
Local nTValipi 	:= 0
Local nTBaseicm := 0
Local nTValicm 	:= 0
Local nTBasepis	:= 0 
Local nTValpis	:= 0
Local nTBasecof	:= 0
Local nTValcof	:= 0
Local nTBaseir	:= 0
Local nTValir	:= 0
Local nTValICMST:= 0 		//FR - 11/01/2022 - PETRA - INCLUIR CAMPO ICM ST
Local aCabNFE	:= {}
Local aIteNFE  	:= {}
Local lValid    := .F.
Local cNCM      := ""    //FR - 16/06/2020 - ECOURBIS
Local cModelo   := ""	 //FR - 25/11/2020
Local cAnaliNew := GetNewPar("XM_ANAFIS","S")		//FR - 16/08/2021 - se usa ou não nova tela de análise fiscal S=Sim -> USA
//FR - 11/01/2022 - PETRA - INCLUIR CAMPO ICM ST
Local nBasICMST   := 0
Local nValICMST   := 0
Local nAliqICMST  := 0  
//FR - 11/01/2022 - PETRA - INCLUIR CAMPO ICM ST
Local cPreNF   // Erick 22/08 -> Variável para filtrar o modelo da nota.
Local nINSVAL // Erick Gonça - 31/08/2022
Local nISSALQ // Erick Gonça - 12/09/2022
Local nISSVAL // Erick Gonça - 30/08/2022
Local nINSALQ // Erick Gonça - 05/09/2022
Local nCSLALQ // Erick Gonça - 05/09/2022
Local nCSLVAL // Erick Gonça - 05/09/2022
Local nAliqICM // Erick Gonça - 09/09/2022
Local nValICM // Erick Gonça - 09/09/2022

Private xZBZ  	  := GetNewPar("XM_TABXML","ZBZ")      //ECOOOOOOOOOO
Private xZB5  	  := GetNewPar("XM_TABAMAR","ZB5")
Private xZBS  	  := GetNewPar("XM_TABSINC","ZBS")
Private xZBE      := GetNewPar("XM_TABEVEN","ZBE")
Private xZBZ_ 	  := iif(Substr(xZBZ,1,1)=="S", Substr(xZBZ,2,2), Substr(xZBZ,1,3)) + "_"
Private xZB5_ 	  := iif(Substr(xZB5,1,1)=="S", Substr(xZB5,2,2), Substr(xZB5,1,3)) + "_"
Private xZBS_ 	  := iif(Substr(xZBS,1,1)=="S", Substr(xZBS,2,2), Substr(xZBS,1,3)) + "_"
Private xZBE_     := iif(Substr(xZBE,1,1)=="S", Substr(xZBE,2,2), Substr(xZBE,1,3)) + "_"
Private xZBC      := GetNewPar("XM_TABCAC","ZBC")
Private xZBC_     := iif(Substr(xZBC,1,1)=="S", Substr(xZBC,2,2), Substr(xZBC,1,3)) + "_"
Private xZBO      := GetNewPar("XM_TABOCOR","ZBO"), xRetSEF := ""
Private xZBO_     := iif(Substr(xZBO,1,1)=="S", Substr(xZBO,2,2), Substr(xZBO,1,3)) + "_"
Private xZBI      := GetNewPar("XM_TABIEXT","ZBI")
Private xZBI_     := iif(Substr(xZBI,1,1)=="S", Substr(xZBI,2,2), Substr(xZBI,1,3)) + "_"
Private xZBA  	  := GetNewPar("XM_TABAMA2","ZBA")
Private xZBA_ 	  := iif(Substr(xZBA,1,1)=="S", Substr(xZBA,2,2), Substr(xZBA,1,3)) + "_"

aAreaZBZ  := (xZBZ)->(GetArea())		//FR - 25/11/2020
cNFiscal  := ( xZBZ )->( FieldGet( FieldPos(xZBZ_+"NOTA"	) ) )					//FR - 25/11/2020
cSerie    := ( xZBZ )->( FieldGet( FieldPos(xZBZ_+"SERIE"	) ) )  					//FR - 25/11/2020
cForn     := ( xZBZ )->( FieldGet( FieldPos(xZBZ_+"CODFOR"	) ) )  					//FR - 25/11/2020
cLoja     := ( xZBZ )->( FieldGet( FieldPos(xZBZ_+"LOJFOR"	) ) )  					//FR - 25/11/2020
cModelo   := ( xZBZ )->( FieldGet( FieldPos(xZBZ_+"MODELO"	) ) )  					//FR - 25/11/2020
cPreNF    := ( xZBZ )->( FieldGet( FieldPos(xZBZ_+"PRENF"   ) ) )                   //Erick Gonça - 13/08/2022
cChave    := ( xZBZ )->( FieldGet( FieldPos(xZBZ_+"CHAVE"   ) ) )                   //FR - 14/04/2023- QUEIJOS IPANEMA

//----------------------------------------------------------------------------------------------------------------//
//Erick Gonça - 13/08/2022 - Modifiquei a validação da NF, alterei pra quando a ZBZ_PRENF não estiver como: "S ou N",;
//                           Não trazer a análise fiscal
//----------------------------------------------------------------------------------------------------------------//

If cPreNF $ "S/N"
///////
Elseif cPreNF == "B"
    Aviso("Aviso","Nota Fiscal nao localizada no sistema.")
    return

Elseif cPreNF == "X"
    Aviso("Cancelado","O XML está cancelado.",{"Ok"})
    return

Elseif cPreNF == "Z"
    Aviso("Rejeitado","O XML está rejeitado, efetue a baixa do xml corretamente.",{"Ok"})
    return

Elseif cPreNF == "F"
    Aviso("Falha","Houve uma falha na importação do XML, por favor efetue a baixa do xml corretamente")
    return

Elseif cPreNF == "D"
    Aviso("Denegado","O XML está denegado.")
    return

Elseif cPreNF == "A"
    Aviso("Aviso","O xml é um recebimento de carga.")
    return
Endif


If !Empty(cNFiscal) .AND. !Empty(cSerie) .AND. !Empty(cForn) .AND. !Empty(cLoja)
    dbSelectArea("SF1")
    SF1->(dbSetOrder(1))
Endif

If SF1->(dbSeek(xFilial("SF1")+cNFiscal+cSerie+cForn+cLoja))
        
    cChave     := SF1->F1_CHVNFE
    nBasICMST  := SF1->F1_BRICMS //FR - 11/01/2022 - PETRA - INCLUIR CAMPO ICM ST
	nTValICMST := SF1->F1_ICMSRET

Else 
    SF1->(dbSetOrder(8)) //F1_FILIAL + F1_CHVNFE
    If SF1->(dbSeek(xFilial("SF1")+ Alltrim(cChave) ))
        //cChave     := SF1->F1_CHVNFE
	    nBasICMST  := SF1->F1_BRICMS //FR - 11/01/2022 - PETRA - INCLUIR CAMPO ICM ST
	    nTValICMST := SF1->F1_ICMSRET
    Endif 
    
Endif

dbSelectArea("SD1")
SD1->(dbSetOrder(1))
If SD1->(dbSeek(xFilial("SD1")+cNFiscal+cSerie+cForn+cLoja))
    lValid     := .T.

ElseIf SD1->(dbSeek(xFilial("SD1")+cNFiscal+cForn+cLoja))
    lValid     := .T.

Endif

 If lValid
    nTNF       := 0
    nTNF       := SF1->F1_VALBRUT
    Do While SD1->(!Eof()) .AND. SD1->D1_FILIAL == xFilial("SD1") .AND. SD1->(D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == cNFiscal+cSerie+cForn+cLoja
                
        cItem      := SD1->D1_ITEM
		cProduto   := SD1->D1_COD
        nQuant     := SD1->D1_QUANT
        cUM        := SD1->D1_UM
        cTES       := SD1->D1_TES
        cCF        := SD1->D1_CF
        nPreco     := SD1->D1_VUNIT
        nTotal     := SD1->D1_TOTAL
        nBaseipi   := SD1->D1_BASEIPI
        nValipi    := SD1->D1_VALIPI
        nIpi       := SD1->D1_IPI
        nBaseicm   := SD1->D1_BASEICM
        nValicm    := SD1->D1_VALICM
        nIcm       := SD1->D1_PICM
        nBasepis   := SD1->D1_BASIMP6 //SD1->D1_BASEPIS //FR - 30/11/2020	    
        nValpis    := SD1->D1_VALIMP6 //SD1->D1_VALPIS  //FR - 30/11/2020	    
        nPis       := SD1->D1_ALQPIS
        nBasecof   := SD1->D1_BASIMP5 //SD1->D1_BASECOF //FR - 30/11/2020	    
        nValcof    := SD1->D1_VALIMP5 //SD1->D1_VALCOF	    
        nCof       := SD1->D1_ALQCOF
        nBaseir    := SD1->D1_BASEIRR
        nValir     := SD1->D1_VALIRR
        nIr        := SD1->D1_ALIQIRR
		cNCM       := SD1->D1_TEC //FR - 16/06/2020 - ECOURBIS

		//FR - 11/01/2022 - PETRA - INCLUIR CAMPO ICM ST
		nBasICMST  := SD1->D1_BRICMS
		nValICMST  := SD1->D1_ICMSRET
		nAliqICMST := SD1->D1_ALIQSOL
		//FR - 23/02/2021 - Tratamento p/ trazer NCM do SB1 caso na SD1 estiver vazia
        nISSALQ    := SD1->D1_ALIQISS
		nISSVAL    := SD1->D1_VALISS
        nINSALQ    := SD1->D1_ALIQINS
        nCSLALQ    := SD1->D1_ALQCSL
        nCSLVAL    := SD1->D1_VALCSL
        nAliqICM   := SD1->D1_PICM
        nValICM    := SD1->D1_VALICM
        If Empty(cNCM)
		  	cNCM       := Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_POSIPI")
		Endif
        nValmerc   += nTotal

        //ACUMULA PARA TOTAIS
        nTBaseipi  += nBaseipi
        nTValipi   += nValipi
        nTBaseicm  += nBaseicm
        nTValicm   += nValicm
        nTBasepis  += nBasepis
        nTValpis   += nValpis
        nTBasecof  += nBasecof
        nTValcof   += nValcof
        nTBaseir   += nBaseir
        nTValir    += nValir
                                            
        Aadd( aIteNFE,{ cItem ,; //01
                        cProduto ,; //02
                        nQuant ,; //03
                        cUM ,; //04
                        cTES ,; //05	
                        cCF ,; //06	
                        nPreco ,; //07	
                        nTotal ,; //08
                        nBaseipi ,; //09
                        nValipi ,; //10
                        nIpi ,; //11
                        nBaseicm ,; //12
                        nValicm ,; //13	 
                        nIcm ,; //14	
                        nBasepis ,; //15
                        nValpis ,; //16
                        nPis ,; //17
                        nBasecof ,; //18
                        nValcof ,; //19
                        nCof ,; //20
                        nBaseir ,; //21
                        nValir ,; //22
                        nIr ,; //23 	
				        cNcm ,; //24
				        nBasICMST ,; //25
				        nValICMST ,; //26
				        nAliqICMST,; //27
                        nISSALQ ,;  //28	
                        nISSVAL ,; //29	
                        nINSVAL ,; //30	   
                        nINSALQ ,; //31  
                        nCSLALQ ,; //32
                        nCSLVAL ,;  //33  
                        nAliqICM ,; //34
                        nValICM ; // 35         				 
                        } ) //Armazena no array de itens da NF, para comparar com o xml	 

        SD1->(dbSkip())
    EndDo
            
    nTNF       := 0
    nTNF       := SF1->F1_VALBRUT
    ///dados da nf	
    Aadd( aCabNFE, {cNFiscal ,; //01-SF1->F1_DOC
                    cSerie ,; //02-SF1->F1_SERIE
                    SF1->F1_EMISSAO ,; //03-SF1->F1_EMISSAO
                    cForn ,; //04-SF1->F1_FORNECE
                    cLoja ,; //05-SF1->F1_LOJA
                    SF1->F1_ESPECIE ,; //06-SF1->F1_ESPECIE
                    SF1->F1_TIPO ,; //07-SF1->F1_TIPO
                    nValmerc ,; //08-SF1->F1_VALMERC
                    nTNF ,; //09-SF1->F1_VALBRUT
                    nTBaseicm ,; //10-SF1->F1_BASEICM
                    nTValicm ,; //11-SF1->F1_VALICM
                    nTBaseipi ,; //12-SF1->F1_BASEIPI
                    nTValipi ,; //13-SF1->F1_VALIPI
                    nTBasepis ,; //14-SF1->F1_BASEPIS
                    nTValpis ,; //15-SF1->F1_VALPIS
                    nTBasecof ,; //16-SF1->F1_BASCOFI
                    nTValcof ,; //17-SF1->F1_VALCOFI
                    nTBaseir ,; //18-SF1->F1_(BASEIR) ?
                    nTValir ,; //19-SF1->F1_VALIRF
                    nBasICMST ,; //20-SF1->F1_BRICMS
                    nTValICMST,; //21-SF1->F1_ICMSRET
                    nISSALQ ,; //22-SF1->F1_ALIQISS	
                    nISSVAL	,; //23-SF1->F1_VALISS	
                    nINSVAL ,; //24-SF1->F1_VALINS
                    nINSALQ ,; //25-SF1->F1_ALIQINS
                    nCSLALQ ,; //26-SF1->F1_ALQCSL
                    nCSLVAL ,; //27-SF1->F1_CSLVAL
                    nAliqICM ,; //28-SF1->F1_PICM
                    nValICM ; //29-SF1->F1_VALICM
                    })
        
    //chama a funcao que verifica divergencias, e neste caso, apresenta tela ao usuario decidir se prossegue ou nao com a inclusao da NF:	
    If cAnaliNew <> "S"
       	U_HFXML063(cChave,aCabNFE,aIteNFE, "NOTA FISCAL",,,.T.,.T.)
    Else
      	U_HFXML63A()
    Endif
Else    
    Aviso("Aviso","Nota Fiscal Não Localizada (SF1/SD1)",{"Ok"})    
EndIf 


RestArea(aAreaSF1)
RestArea(aAreaZBZ)
RestArea(aArea)

Return
