#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'

/*______________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ HFXML064     ¦ Autora ¦ FLÁVIA ROCHA  ¦ Data ¦ 28/05/2020  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Ponto de entrada na confirmação da NF Entrada              ¦¦¦
¦¦¦          ¦                                                            ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Gestão XML / Auditoria Fiscal                              ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Cliente   ¦ HF                                                         ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦FR - Função chamada dentro do ponto de entrada MT100TOK                ¦¦¦
¦¦¦                                                                       ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦  /  /    ¦      					                                  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
//--------------------------------------------------------------------------//
//Alterações realizadas:
//--------------------------------------------------------------------------//
//FR - 16/06/2020 - ECOURBIS: tratativa para incluir campo NCM na tela de  
//                  divergências
//--------------------------------------------------------------------------//
//FR - 09/02/2022 - alteração - Petra - correção qdo acessada opção 
//                  "análise fiscal" dentro de "classificar nf"
//--------------------------------------------------------------------------// 

***********************************************************************************************
User Function HFXML064(cChave,cNFiscal,cSerie,dDEmissao,cA100For,cLoja,cEspecie,cTipo,lVisual)
***********************************************************************************************
Local aArea		:= GetArea()
Local lOk		:= .T.
Local aCabNFE	:= {}
Local aIteNFE  	:= {}
Local cItem		:= ""
Local cProduto	:= ""
Local nQuant  	:= ""
Local cUM		:= ""
Local cTES 		:= ""
Local cCF		:= ""
Local cNCM      := ""    //FR - 16/06/2020 - ECOURBIS
Local nPreco  	:= 0
Local nTotal  	:= 0
Local nBaseipi	:= 0
Local nValipi 	:= 0
Local nIpi    	:= 0
Local nBaseicm	:= 0
Local nValicm 	:= 0
Local nIcm 		:= 0
Local nBasepis	:= 0
Local nValpis 	:= 0
Local nPis 		:= 0
Local nBasecof	:= 0
Local nValcof 	:= 0
Local nCof    	:= 0
Local nBaseir 	:= 0
Local nValir  	:= 0
Local nIr		:= 0 
Local nReg		:= 0 
Local nValmerc  := 0
//totais gerais da nf
Local nTBaseicm := 0
Local nTValicm  := 0
Local nTBaseipi := 0
Local nTValipi  := 0
Local nTBasepis := 0
Local nTValpis  := 0
Local nTBasecof := 0
Local nTValcof  := 0
Local nTBaseir  := 0
Local nTValir   := 0
Local cUsaDvg   := GetNewPar("XM_USADVG","N") 

//FR - 11/01/2022 - PETRA - ALTERAÇÃO - INCLUIR CAMPO ICM ST
Local nBasICMST := 0
Local nValICMST := 0
Local nAliqICMST:= 0 
Local nTBasICMST:= 0 
Local nTValICMST:= 0
//FR - 11/01/2022 - PETRA - ALTERAÇÃO - INCLUIR CAMPO ICM ST

Local x := 0
Local lDiverg   := .F.
Default lVisual := .T.

	For x:= 1 to Len(aCols)

		//varre os itens da nota e armazena no array aIteNFE para depois comparar com os itens do XML:    	
		If !(aCols[x,Len(aHeader)+1]) //se a linha do acols não estiver deletada

			cItem		:= aCols[x][ aScan( aHeader, {|x| alltrim(x[2]) == "D1_ITEM" 	}) ]
			cProduto	:= aCols[x][ aScan( aHeader, {|x| alltrim(x[2]) == "D1_COD" 	}) ]
			nQuant  	:= aCols[x][ aScan( aHeader, {|x| alltrim(x[2]) == "D1_QUANT" 	}) ] 
			cUM			:= aCols[x][ aScan( aHeader, {|x| alltrim(x[2]) == "D1_UM"	 	}) ] 
			cTES		:= aCols[x][ aScan( aHeader, {|x| alltrim(x[2]) == "D1_TES"	 	}) ] 
			cCF			:= aCols[x][ aScan( aHeader, {|x| alltrim(x[2]) == "D1_CF"	 	}) ] 
			nPreco  	:= aCols[x][ aScan( aHeader, {|x| alltrim(x[2]) == "D1_VUNIT" 	}) ]
			nTotal  	:= aCols[x][ aScan( aHeader, {|x| alltrim(x[2]) == "D1_TOTAL" 	}) ]		
			nBaseipi	:= aCols[x][ aScan( aHeader, {|x| alltrim(x[2]) == "D1_BASEIPI"	}) ]		
			nValipi 	:= aCols[x][ aScan( aHeader, {|x| alltrim(x[2]) == "D1_VALIPI" 	}) ]

			if nValipi > 0		
				nIpi    := aCols[x][ aScan( aHeader, {|x| alltrim(x[2]) == "D1_IPI" 	}) ]
			else
				nIpi    := 0
			endif
			nBaseicm	:= aCols[x][ aScan( aHeader, {|x| alltrim(x[2]) == "D1_BASEICM"	}) ]		
			nValicm 	:= aCols[x][ aScan( aHeader, {|x| alltrim(x[2]) == "D1_VALICM" 	}) ]

			if nValicm		
				nIcm	:= aCols[x][ aScan( aHeader, {|x| alltrim(x[2]) == "D1_PICM" 	}) ]
		    else
				nIcm    := 0 
			endif

			nBasepis	:= aCols[x][ aScan( aHeader, {|x| alltrim(x[2]) == "D1_BASEPIS"	}) ]
			nValpis 	:= aCols[x][ aScan( aHeader, {|x| alltrim(x[2]) == "D1_VALPIS" 	}) ]	    

			if nValpis > 0 	    
		    	nPis   	:= aCols[x][ aScan( aHeader, {|x| alltrim(x[2]) == "D1_ALQPIS" 	}) ]
		    else
				nPis    := 0
			endif
			
		    nBasecof	:= aCols[x][ aScan( aHeader, {|x| alltrim(x[2]) == "D1_BASECOF"	}) ]	    
		    nValcof 	:= aCols[x][ aScan( aHeader, {|x| alltrim(x[2]) == "D1_VALCOF" 	}) ]	 

			if nValcof > 0
				nCof    := aCols[x][ aScan( aHeader, {|x| alltrim(x[2]) == "D1_ALQCOF" 	}) ]
			else
				nCof    := 0
			endif

			if aScan( aHeader, {|x| alltrim(x[2]) == "D1_BASEIRR"	})  > 0
		    	nBaseir 	:= aCols[x][ aScan( aHeader, {|x| alltrim(x[2]) == "D1_BASEIRR"	}) ]	
			endif    

			if aScan( aHeader, {|x| alltrim(x[2]) == "D1_VALIRR"	}) > 0
		    	nValir  	:= aCols[x][ aScan( aHeader, {|x| alltrim(x[2]) == "D1_VALIRR"	}) ]
			endif

			if nValir > 0
				if aScan( aHeader, {|x| alltrim(x[2]) == "D1_ALIQIRR"	}) > 0
		    		nIr		:= aCols[x][ aScan( aHeader, {|x| alltrim(x[2]) == "D1_ALIQIRR"	}) ] 
				endif
			else
				nIr     := 0
			endif

			cNCM        := aCols[x][ aScan( aHeader, {|x| alltrim(x[2]) == "D1_TEC"  	}) ] 	//FR - 16/06/2020 - ECOURBIS
			
			if Empty( cNCM )

				cNCM  := Posicione("SB1",1,xFilial("SB1")+ aCols[x][ aScan( aHeader, {|x| alltrim(x[2]) == "D1_COD" }) ] ,"B1_POSIPI") 

			endif
		    
			//FR - 11/01/2022 - PETRA - INCLUIR CAMPO ICM ST
		    nBasICMST   := aCols[x][ aScan( aHeader, {|x| alltrim(x[2]) == "D1_BRICMS"	}) ]	     	//SD1->D1_BRICMS
		    nValICMST   := aCols[x][ aScan( aHeader, {|x| alltrim(x[2]) == "D1_ICMSRET"	}) ] 			//SD1->D1_ICMSRET
		    nAliqICMST  := aCols[x][ aScan( aHeader, {|x| alltrim(x[2]) == "D1_ALIQSOL"	}) ]			//SD1->D1_ALIQSOL

		    
		    nValmerc	+= nTotal 
		    nTBaseipi 	+= nBaseipi
		    nTValipi 	+= nValipi
		    nTBaseicm 	+= nBaseicm
		    nTValicm 	+= nValicm
		    nTBasepis	+= nBasepis 
		    nTValpis	+= nValpis
		    nTBasecof	+= nBasecof
		    nTValcof	+= nValcof
		    nTBaseir	+= nBaseir
		    nTValir		+= nValir	
		   	nTBasICMST  += nBasICMST 
		   	nTValICMST  += nValICMST
		   		    		    		  
			Aadd( aIteNFE, { cItem	,; 		//01
						 cProduto	,; 		//02
						 nQuant		,;   	//03
						 cUM		,;	 	//04
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
						 nCof   	,; 	 	//20
						 nBaseir 	,;	 	//21
						 nValir 	,; 	 	//22
						 nIr		,;		//23 					 
					 	 cNCM		,;		//24	//FR - 16/06/2020 - ECOURBIS  
					 	 nBasICMST	,;		//25    //FR - 11/01/2022 - PETRA - INCLUIR CAMPO ICM ST
						 nValICMST  ,;		//26
						 nAliqICMST ;		//27					 
						   } )   //Armazena no array de itens da NF, para comparar com o xml	 
			
		Endif

	Next	

	nTNF := 0
	nTNF := MaFisRet(,"NF_TOTAL")

	///dados da nf	
	Aadd( aCabNFE, {cNFiscal   		,;	//01-SF1->F1_DOC
					cSerie			,;	//02-SF1->F1_SERIE
					dDEmissao		,;	//03-SF1->F1_EMISSAO
					cA100For   		,;	//04-SF1->F1_FORNECE
					cLoja	   		,;	//05-SF1->F1_LOJA
					cEspecie   		,;	//06-SF1->F1_ESPECIE
					cTipo	   		,;	//07-SF1->F1_TIPO
					nValmerc		,; 	//08-SF1->F1_VALMERC
					nTNF	        ,;  //09-SF1->F1_VALBRUT
					nTBaseicm		,;	//10-SF1->F1_BASEICM
					nTValicm		,;	//11-SF1->F1_VALICM
					nTBaseipi		,;	//12-SF1->F1_BASEIPI
					nTValipi		,;	//13-SF1->F1_VALIPI
					nTBasepis		,;	//14-SF1->F1_BASEPIS
					nTValpis	   	,;	//15-SF1->F1_VALPIS
					nTBasecof  		,;	//16-SF1->F1_BASCOFI
					nTValcof   		,;	//17-SF1->F1_VALCOFI
					nTBaseir		,;	//18-SF1->F1_(BASEIR) ?
					nTValir			,;	//19-SF1->F1_VALIRF
					nTBasICMST  	,;  //20-Base ICM ST
				   	nTValICMST  	;	//21-Valor ICM ST		
				})

	//chama a função que verifica divergências, e neste caso, apresenta tela ao usuário decidir se prossegue ou não com a inclusão da NF:	
lOk := U_HFXML063(cChave,aCabNFE,aIteNFE, "NOTA FISCAL",        ,         ,@lDiverg ,lVisual)  
//       HFXML063(cChave,aCabNFE,aIteNFE, cTipoDoc     ,aPedidos,lOmiTTela,lDiverg  ,lVisual) 
//lVisual indica se a tela é somente visual ou se vai ter o botão "Aceita Divergênncias" (lVisual = .F.)

If !lOk .and. (lVisual == Nil .or. !lVisual)

	Aviso(	"Documento de Entrada",;
			"A nota não poderá ser incluída, Motivo: Divergências Entre XML x NF." + CHR(13) + CHR(10) +;
			"Favor entrar em contato com o Administrador",;
			{"&Ok"},,;
			"XML x NF")			
Endif	

RestArea(aArea)

Return(lOk)
