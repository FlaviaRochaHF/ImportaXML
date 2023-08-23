#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TOPCONN.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HFXML070   บAutor  ณ Renan Oliveira   บ Data ณ  13/07/20   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina para verificar divergencia Pedido de Compra x XML   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestใo XML                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
//--------------------------------------------------------------------------//
//FR - 10/12/2020 - Corre็ใo para exibi็ใo do campo Quantidade de 2 casas 
//                  decimais para 4 -   Chamado #5860 - ADAR
//--------------------------------------------------------------------------//
//FR - 06/07/2021 - Solicitado por Rafael revisใo nas telas p/ contemplar 
//                  unifica็ใo de XML x PC
//--------------------------------------------------------------------------//
//FR - 20/04/2022 - Altera็ใo para valida็ใo da quantidade, atrelar เ 
//                  escolha do "aceita diverg๊ncia sim/nao" pois estava 
//                  travando geral nใo dando escolha ao cliente
//--------------------------------------------------------------------------//
//FR - 14/06/2022 - Brasmolde - PEDIDO DE COMPRA EM DำLAR E NF EM REAIS
//					Valida็ใo item por item do pedido de compra para checar
//                  diverg๊ncia de valor do PC x XML
//                  Converte o valor do item no xml, utilizando a taxa moeda 
//                  do pedido, porque a NF vem em REAIS
//--------------------------------------------------------------------------//
User Function HFXML070(cChave, aWBrowse, lVisual, cTravPreNF,aWBXML,cModelo)

Local   cTitulo     := "DIVERGสNCIAS XML x PEDIDO DE COMPRA"
Local   cPedido     := ""
Local   dEmiss      := ""
Local   cCod        := ""
Local   cDescr      := ""
Local   xDocto      := ""
Local   xSerie      := ""
Local   xEmiss      := ""
Local   xCnpjXml    := ""
Local   xCodFor     := ""
Local   xLojFor     := ""
Local   xNomFor     := ""
Local   xCod        := ""
Local   xDescr      := ""
Local   xVlUnit     := 0
Local   xQuant      := 0
Local   xTot        := 0
Local   nVlUnit     := 0
Local   nQuant      := 0
Local   nDVlUnit    := 0   //valor unitแrio na moeda "x" sem ser REal
Local   nDTot       := 0   //valor total na moeda "x" sem se Real
Local   nTot        := 0
Local   nLin        := 0
Local   nX          := 0
Local   aAreaZBZ    := {} //ZBZ->(GetArea())
Local   aAreaSA2    := SA2->(GetArea())
Local   aDados      := {}
Local   aDadosXML   := {}
Local   aDadosPed   := {}
Local   lDiverg     := .F.
Local   fr          := 0 

Default lVisual     := .F.
Default cTravPreNF  := "S"

Private cArqTMP		:= ""
Private cFiltro     := ""
Private cMsg1       := ""
Private cMsg2       := ""
Private xColP05     := 0
Private xColP06     := 0
Private xColP07     := 0 
Private xColP11     := 0
Private xColP12     := 0
Private xColP13     := 0
Private aObjects    := {}
Private aInfo       := {}
Private aPos        := {}
Private aSize       := MsAdvSize(.T.)
Private xZBZ        := GetNewPar("XM_TABXML","ZBZ")
Private xZBZ_       := iif(Substr(xZBZ,1,1)=="S", Substr(xZBZ,2,2), Substr(xZBZ,1,3)) + "_"  
Private xZBT        := GetNewPar("XM_TABITEM","ZBT")
Private xZBT_       := iif(Substr(xZBT,1,1)=="S", Substr(xZBT,2,2), Substr(xZBT,1,3)) + "_" 
Private oFont14N    := TFont():New("Verdana",14,14,,.T.,,,,.T.,.F.) 
Private oFont12N    := TFont():New("Verdana",12,12,,.T.,,,,.T.,.F.) 

Private lMarkIt		:= .F.

Private xMoeda        := ""
Private xNomemoeda    := "" 
Private cMoeda        := ""
Private lSohReal      := .T.

Default aWBXML        := {} 
Default cModelo       := ""

//Declara็ใo de Variaveis Private dos Objetos
SetPrvt("oDlg")
SetPrvt("oBrwX1","oBrwP1")
SetPrvt("oOk","oFechar")
SetPrvt("oGrpX1","oGrpX2","oGrpX3","oGrpP1","oGrpP2","oGrpP3","oGrpP4","oGrpG1","oGrpG2")
SetPrvt("oSayG01")
SetPrvt("oSayX01","oSayX02","oSayX03","oSayX04","oSayX05","oSayX06","oSayX07","oSayX08")
SetPrvt("oSayXT01","oSayXT02","oSayXT03")
SetPrvt("oGetX01","oGetX02","oGetX03","oGetX04","oGetX05","oGetX06","oGetX07","oGetX08")
SetPrvt("oSayP01","oSayP02","oSayP03","oSayP04","oSayP05","oSayP06","oSayP07","oSayP08","oSayP09","oSayP10")
SetPrvt("oSayPT01","oSayPT02")
SetPrvt("oGetP01","oGetP02","oGetP03","oGetP04","oGetP05","oGetP06","oGetP07","oGetP08","oGetP09","oGetP10","oGetP11")
/*
aEstrutXML := { { "ITEM"    ,"C"    ,TamSX3('D1_ITEM')[01]      ,0  },;       //FR - 06/07/2021
                { "CODIGO"  ,"C"    ,TamSX3('D1_COD')[01]       ,0  },;
                { "DESCRI"  ,"C"    ,TamSX3('B1_DESC')[01]      ,0  }}
*/

aEstrutXML := { { "ITEM"    ,"C"    ,TamSX3('D1_ITEM')[01]      ,0  },;
                { "CODIGO"  ,"C"    ,TamSX3('D1_COD')[01]       ,0  },;
                { "DESCRI"  ,"C"    ,TamSX3('B1_DESC')[01]      ,0  },;
                { "QTDX"    ,"N"    ,TamSX3(xZBT_+'QUANT')[01]  ,TamSX3(xZBT_+'QUANT')[02]  },;
                { "VUNIX"   ,"N"    ,TamSX3(xZBT_+'VUNIT')[01]  ,TamSX3(xZBT_+'VUNIT')[02]  },;
                { "TOTX"    ,"N"    ,TamSX3(xZBT_+'TOTAL')[01]  ,TamSX3(xZBT_+'TOTAL')[02]  } }


aEstrutPed := { { "ITEMXML" ,"C"    ,TamSX3('D1_ITEM')[01]      ,0  },;
                { "ITEM"    ,"C"    ,TamSX3('D1_ITEM')[01]      ,0  },;
                { "PEDIDO"  ,"C"    ,TamSX3('D1_PEDIDO')[01]    ,0  },;
                { "ITEMPED" ,"C"    ,TamSX3('D1_ITEMPC')[01]    ,0  },;
                { "CODIGO"  ,"C"    ,TamSX3('D1_COD')[01]       ,0  },;
                { "DESCRI"  ,"C"    ,TamSX3('B1_DESC')[01]      ,0  }}
                  
aAreaZBZ    := (xZBZ)->(GetArea())

dbSelectArea(xZBZ)
(xZBZ)->(dbSetOrder(3))

If (xZBZ)->(dbSeek(cChave))
    xDocto 		:= (xZBZ)->&(xZBZ_+"NOTA")  
	xSerie 		:= (xZBZ)->&(xZBZ_+"SERIE")
	xEmiss   	:= (xZBZ)->&(xZBZ_+"DTNFE")
    xCnpjXml    := (xZBZ)->&(xZBZ_+"CNPJ")
	xModelo     := (xZBZ)->&(xZBZ_+"MODELO")
	xXml        := (xZBZ)->&(xZBZ_+"XML")

    dbSelectArea("SA2")
    SA2->(dbSetOrder(3))
	If SA2->(dbSeek(xFilial("SA2")+xCnpjXml )) 
	    xCodFor := SA2->A2_COD
	    xLojFor := SA2->A2_LOJA
	    xNomFor := (xZBZ)->&(xZBZ_+"FORNEC")
    EndIf
EndIf

For nX := 1 to Len(aWBrowse) 
	If "," $ aWBrowse[nX,2]   //se tiver vํrgula dentro do item, ้ porque houve marca็ใo de vแrios itens do xml para 1 item de pedido
		lMarkIt := .T.
	Endif   
Next nX

If lMarkIt
	//alert("Houve marca็ใo de itens aleat๓rios, tela diverg๊ncia nใo compatํvel")     //FR TESTE
	//Return
Endif

For nX := 1 to Len(aWBrowse)
    nPosItem := 0
    If !Empty(aWBrowse[nX,2])
        If aWBrowse[nX,2] <> "0000" 

            aDadosPed := {  "",;                // 01 - CONTROLE DE ITEM DO GRID
                            aWBrowse[nX,5],;    // 02 - PEDIDO
                            aWBrowse[nX,1],;    // 03 - ITEM PEDIDO
                            aWBrowse[nX,3],;    // 04 - PRODUTO PEDIDO
                            aWBrowse[nX,4],;    // 05 - DESCRICAO PRODUTO PEDIDO
                            "",;                // 06 - EMISSAO PEDIDO
                            0,;                 // 07 - QUANTIDADE PEDIDO
                            0,;                 // 08 - VALOR UNITARIO PEDIDO
                            0,;                 // 09 - TOTAL PEDIDO
                            0,;                 // 10 - SALDO PEDIDO
                            0,;                 // 11 - TOTAL
                            0,;                 // 12 - COR DIF. VALOR UNIT 
                            "",;                // 13 - MSG 2
                            0,;					// 14 - VALOR UNITARIO MOEDA X
                            0,;					// 15 - TOTAL PEDIDO MOEDA X
                            0,;                 // 16 - COR DIF. VALOR UNIT MOEDA X
                            "";					// 17 - MOEDA DO PEDIDO DE COMPRA 
                            }           

            If aWBrowse[nX,2] <> "*"  //FR - 14/07/2021 - Solicita็๕es Rafael Lobitsky
            
            	nPosItem := aScan( aDadosXML ,{ |x| x[1] == aWBrowse[nX,2] } )
            
	            If cModelo <> "RP"
                    If nPosItem > 0
                        aAdd(aDadosXML[nPosItem,8], aDadosPed)
                    Else
                        aAdd(aDadosXML, {   aWBrowse[nX,2],;    // 1 - ITEM XML
                                            "",;                // 2 - PRODUTO XML
                                            "",;                // 3 - DESCRICAO PRODUTO XML
                                            0,;                 // 4 - QUANTIDADE XML
                                            0,;                 // 5 - VALOR UNITARIO XML
                                            0,;                 // 6 - TOTAL XML
                                            0,;                 // 7 - COR DIF. SALDO
                                            {}})                // 8 - ARRAY PEDIDO
        
                        aAdd(aDadosXML[Len(aDadosXML),8],   aDadosPed)
                    EndIf
                
                Else //FR - 10/07/2023 - TRATATIVA PARA BROWSE NF SERVIวO
                    For fr := 1 to Len(aWBXML) 
                        aAdd(aDadosXML , {aWBXML[fr,1] ,;       // 1 - ITEM XML
                                        aWBXML[fr,2],;          // 2 - PRODUTO XML
                                        aWBXML[fr,3],;          // 3 - DESCRICAO PRODUTO XML
                                        Val(aWBXML[fr,4]),;     // 4 - QUANTIDADE XML
                                        Val(aWBXML[fr,5]),;     // 5 - VALOR UNITARIO XML
                                        Val(aWBXML[fr,6]),;     // 6 - TOTAL XML
                                        0,;                     // 7 - COR DIF. SALDO
                                        {} ;                    // 8 - ARRAY PEDIDO
                                        } )

                    Next

                Endif 
	            
	        Else  	//FR - 14/07/2021 - Solicitado por Rafael revisใo nas telas para contemplar unifica็ใo de XML x PC
	        
	        	aDadosPed := {  "",;                // 01 - CONTROLE DE ITEM DO GRID
                            aWBrowse[nX,5],;    // 02 - PEDIDO
                            aWBrowse[nX,1],;    // 03 - ITEM PEDIDO
                            aWBrowse[nX,3],;    // 04 - PRODUTO PEDIDO
                            aWBrowse[nX,4],;    // 05 - DESCRICAO PRODUTO PEDIDO
                            "",;                // 06 - EMISSAO PEDIDO
                            0,;                 // 07 - QUANTIDADE PEDIDO
                            0,;                 // 08 - VALOR UNITARIO PEDIDO
                            0,;                 // 09 - TOTAL PEDIDO
                            0,;                 // 10 - SALDO PEDIDO
                            0,;                 // 11 - TOTAL
                            0,;                 // 12 - COR DIF. VALOR UNIT 
                            "",;                // 13 - MSG 2
                            0,;					// 14 - VALOR UNITARIO MOEDA X
                            0,;					// 15 - TOTAL PEDIDO MOEDA X 
                            0,;                 // 16 - COR DIF. VALOR UNIT MOEDA X
                            "";					// 17 - MOEDA DO PEDIDO DE COMPRA 
                            }           
	        	
	        	If cModelo <> "RP"
                    (xZBT)->(OrdSetFocus(2)) 
                    (xZBT)->(Dbseek( cChave ))
                    While (xZBT)->(!Eof()) .AND. Alltrim( (xZBT)->&(xZBT_+"CHAVE") ) == Alltrim(cChave)
                    
                        aAdd(aDadosXML, {   (xZBT)->&(xZBT_+"ITEM"),;    				// 1 - ITEM XML
                                            (xZBT)->&(xZBT_+"PRODUT"),;                	// 2 - PRODUTO XML
                                            (xZBT)->&(xZBT_+"DESCRI"),;                	// 3 - DESCRICAO PRODUTO XML
                                            (xZBT)->&(xZBT_+"QUANT"),;                 	// 4 - QUANTIDADE XML
                                            (xZBT)->&(xZBT_+"VUNIT"),;                 	// 5 - VALOR UNITARIO XML
                                            (xZBT)->&(xZBT_+"TOTAL"),;                 	// 6 - TOTAL XML
                                            0,;                 						// 7 - COR DIF. SALDO
                                            {} })                				// 8 - ARRAY PEDIDO  
                                            
                        (xZBT)->(Dbskip()) 
                        
                        aAdd(aDadosXML[Len(aDadosXML),8],   aDadosPed)
                    Enddo
                //Else
                                   
                Endif 
	        
	        Endif         
	        
        EndIf
    EndIf
Next nX

For nX := 1 to Len(aDadosXML) 
    aDadosAux := fMontaArr(aDadosXML[nX], cChave, @cMsg1, @cMsg2, @lDiverg,lMarkIt,aDadosPed)
    aAdd(aDados,aDadosAux)
Next nX

If lDiverg
    //PARAMETRO TRAVA PRE-NOTA
    //S = Exibe a tela caso haja divergencia sem qualquer tipo de pergunta
    //N - Nใo Exibe a tela mesmo que tenha divergencia
    //P - Pergunta ao usuario
    If cTravPreNF == "P"
        If !(MsgNoYes("Hแ divergencias entre o pedido e o XML deseja verificar?","DIVERXMLPED"))
            lDiverg := .F.
        EndIf
    ElseIf cTravPreNF == "N"
        lDiverg := .F.
    EndIf
EndIf

If lDiverg
    //Busca Dados do Grid do XML
    fGridXML(cArqTMP,aEstrutXML,aDados,cChave)

    //Busca Dados do Grid do Pedido
    fGridPed(cArqTMP,aEstrutPed,aDados)

    dbSelectArea("TMPXML")
    TMPXML->(DbGoTop())
    If TMPXML->(!Eof()) 
    	
    	//FR - 06/07/2021
    	/*
        fAtuGridX( aDados[1,1], "0001", aDados, @xCod, @xDescr, @xVlUnit, @xQuant, @xTot,; 
                    @cPedido, @dEmiss, @cCod, @cDescr, @nVlUnit, @nQuant, @nTot,;
                    @xColP05, @xColP06, @xColP07, @cMsg2, @cFiltro, .F.  )	
                    
        fAtuGridX(xItemXML, xItemPed, aDados, xCod, xDescr, xVlUnit, xQuant, xTot, cPedido, dEmiss,;
                             cCod, cDescr, nVlUnit, nQuant, nTot, xColP05, xColP06, xColP07, cMsg2, cFiltro, lAtualiza)
        */
        
        fr := 0
        If !lMarkIt							//FR - 06/07/2021 - Solicitado por Rafael revisใo nas telas para contemplar unifica็ใo de XML x PC
	        For fr := 1 to Len(aDados)
	        	fAtuGridX( Alltrim(aDados[fr,1]), "0001", aDados, @xCod, @xDescr, @xVlUnit, @xQuant, @xTot,; 
	                    @cPedido, @dEmiss, @cCod, @cDescr, @nVlUnit, @nQuant, @nTot,;
	                    @xColP05, @xColP06, @xColP07, @cMsg2, @cFiltro, .F. ,;
	                    @xColP11, @xColP12, @xColP13, @nDVlUnit , @nDTot, @cMoeda )	  
	        Next
        Else
        	For fr := 1 to Len(aDados)
	        	fAtuGridX( Alltrim(aDados[fr,1]), Alltrim(aDados[fr,8,1,3]), aDados, @xCod, @xDescr, @xVlUnit, @xQuant, @xTot,; 
	                    @cPedido, @dEmiss, @cCod, @cDescr, @nVlUnit, @nQuant, @nTot,;
	                    @xColP05, @xColP06, @xColP07, @cMsg2, @cFiltro, .F. ,;
	                    @xColP11, @xColP12, @xColP13, @nDVlUnit , @nDTot, @cMoeda )	  
	        Next
        Endif
              	
        	
    EndIf

    AAdd( aObjects, { 0, 95, .T., .F., .F. } )
    AAdd( aObjects, { 0, 0, .T., .T., .F. } )
    AAdd( aObjects, { 0, 60, .T., .F., .T. } )

    aSize[3] := aSize[3]*0.8
    aSize[4] := aSize[4]*0.8
    aSize[5] := aSize[3]*2
    aSize[6] := aSize[4]*2

    aInfo := { aSize[1], aSize[2], aSize[3], aSize[4], 3, 3 } 
    aPos  := MsObjSize( aInfo, aObjects )
        
    //medidas para dialog
    nCoLimite := aSize[5]-(aSize[5]*0.15) 
    nLiLimite := aSize[6]
    
    //medidas para objetos tela
    nLiini	:= 1       
    nCoMeio	:= aSize[3]
    nLiMeio	:= aSize[4]
    nCoini	:= aSize[8]	
    nTamG1  := nLiini+1
    nTamG2  := (nLiMeio*0.09)
    nTamG3  := (nLiMeio*0.19)
    nTamG3M := (nLiMeio*0.42)
    nTamG4  := (nLiMeio*0.60)
    nTamG4M  := (nLiMeio*0.58)

    //MONTAGEM DA DIALOG:
    Define MsDialog oDlg TITLE cTitulo STYLE DS_MODALFRAME From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL

        oGrpG1  := TGroup():New( nTamG1,nCoini,nTamG2,nCoMeio-nCoIni," Fornecedor ",oDlg,CLR_HBLUE,CLR_WHITE,.T.,.F. )
        oGrpX1  := TGroup():New( nTamG2,nCoini,nTamG3,(nCoMeio*0.5)-1," Cabe็alho do XML ",oDlg,CLR_HBLUE,CLR_WHITE,.T.,.F. )
        oGrpX2  := TGroup():New( nTamG3,nCoini,nTamG4,(nCoMeio*0.5)-1," Itens do XML ",oDlg,CLR_HBLUE,CLR_WHITE,.T.,.F. )
        oGrpX3  := TGroup():New( nTamG4,nCoini,(nLiMeio*0.90),(nCoMeio*0.5)-1," XML ",oDlg,CLR_HBLUE,CLR_WHITE,.T.,.F. )
        oGrpP1  := TGroup():New( nTamG2,(nCoMeio*0.5)+1,nTamG3,nCoMeio-nCoIni," Cabe็alho do Pedido ",oDlg,CLR_HBLUE,CLR_WHITE,.T.,.F. )
        oGrpP2  := TGroup():New( nTamG3,(nCoMeio*0.5)+1,nTamG4,nCoMeio-nCoIni," Itens do Pedido ",oDlg,CLR_HBLUE,CLR_WHITE,.T.,.F. )
        oGrpP3  := TGroup():New( nTamG4,(nCoMeio*0.5)+1,(nLiMeio*0.90),nCoMeio-nCoIni," Pedido ",oDlg,CLR_HBLUE,CLR_WHITE,.T.,.F. )
        oGrpP4  := TGroup():New( nTamG3M,(nCoMeio*0.5)+20,nTamG4M,(nCoMeio-nCoIni)-20,"",oDlg,CLR_HBLUE,CLR_WHITE,.T.,.F. )
        
        oFechar   := TButton():New( (nLiMeio*0.92) ,nCoMeio-nCoIni-60,"Fechar"				,oDlg,{|| (oDlg:End(),nOpgera := 0) },060,012,,,,.T.,,"",,,,.F. )
        
        If !lVisual
            oOk  := TButton():New( (nLiMeio*0.92) ,nCoMeio-nCoIni-135,"Aceita Diverg๊ncias"	,oDlg,{|| iIf(fValidDiv(cMsg1),(oDlg:End(),nOpgera := 1),nOpgera := 0)},060,012,,,,.T.,,"",,,,.F. )
        EndIf

        nLin := nTamG1 + 09
        oSayG01      := TSay():New( nLin,020,{||xCodFor+"-"+xLojFor+"   -   "+xNomFor}	,oGrpG1,,oFont14N,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,400,008) 
        
        nLin := nTamG2 + 11
        oSayX01   := TSay():New( nLin,010,{||"Documento:"} 		,oGrpX1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
        oSayX02   := TSay():New( nLin,113,{||"S้rie:"}	   		,oGrpX1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,017,008)
        oSayX03   := TSay():New( nLin,162,{||"Emissใo:"}		,oGrpX1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,023,008)
        oGetX01   := TGet():New( nLin-1,047,{|u| If(PCount()>0,xDocto:=u,xDocto)}	,oGrpX1,060,008,'@!',,CLR_BLACK,CLR_WHITE,,,,.T.	,"",,,.F.,.F.,,.T.,.F.,"","xDocto",,)
        oGetX02   := TGet():New( nLin-1,130,{|u| If(PCount()>0,xSerie:=u,xSerie)}	,oGrpX1,020,008,'@!',,CLR_BLACK,CLR_WHITE,,,,.T.	,"",,,.F.,.F.,,.T.,.F.,"","xSerie",,)
        oGetX03   := TGet():New( nLin-1,191,{|u| If(PCount()>0,xEmiss:=u,xEmiss)}	,oGrpX1,060,008,'@D',,CLR_BLACK,CLR_WHITE,,,,.T.        ,"",,,.F.,.F.,,.T.,.F.,"","xEmiss",,)
        
        nLin := nTamG3 + 13
        oSayX04     := TSay():New( nLin,070,{||"Codigo:"}       ,oGrpX2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
        oSayX05     := TSay():New( nLin,125,{||"Descricao:"}    ,oGrpX2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
        
        nLin += 7
        oGetX04     := TGet():New( nLin,070,{|u| If(PCount()>0,xCod:=u,xCod)}       ,oGrpX2,040,008,,,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","xCod",,) 
        oGetX05     := TGet():New( nLin,125,{|u| If(PCount()>0,xDescr:=u,xDescr)}   ,oGrpX2,130,008,,,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","xDescr",,) 

        nLin += 2	
        oSayXT01     := TSay():New( nLin,010,{||"Produto  "}	,oGrpX2,,oFont14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
        
        nLin += 11
        oSayX06     := TSay():New( nLin,070,{||"Valor Unit:"}   ,oGrpX2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
        oSayX07     := TSay():New( nLin,125,{||"Quantidade:"}   ,oGrpX2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
        oSayX08     := TSay():New( nLin,180,{||"Total:"}        ,oGrpX2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,053,048)

        nLin += 7
        oGetX06     := TGet():New( nLin,070,{|u| If(PCount()>0,xVlUnit:=u,xVlUnit)} ,oGrpX2,040,008,'@E 999,999,999.9999',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","xVlUnit",,) 
        oGetX07     := TGet():New( nLin,125,{|u| If(PCount()>0,xQuant:=u,xQuant)}   ,oGrpX2,040,008,'@E 999,999,999.9999',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","xQuant",,)   //FR - 09/12/2020
        oGetX08     := TGet():New( nLin,180,{|u| If(PCount()>0,xTot:=u,xTot)}       ,oGrpX2,040,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","xTot",,) 
        
        nLin += 2
        oSayXT02     := TSay():New( nLin,010,{||"Valores"}	,oGrpX2,,oFont12N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022) 
               
        nCol := (nCoMeio*0.5)-5
        nLin := nTamG2 + 11
        oSayP01     := TSay():New( nLin,nCol+010,{||"Pedido:"}	,oGrpP1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
        oSayP02     := TSay():New( nLin,nCol+162,{||"Emissใo:"}	,oGrpP1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,023,008)
        oGetP01     := TGet():New( nLin-1,nCol+047,{|u| If(PCount()>0,cPedido:=u,cPedido)}  ,oGrpP1,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.	,"",,,.F.,.F.,,.T.,.F.,"","cPedido",,)
        oGetP02     := TGet():New( nLin-1,nCol+191,{|u| If(PCount()>0,dEmiss:=u,dEmiss)}	,oGrpP1,060,008,'@D',,CLR_BLACK,CLR_WHITE,,,,.T.	,"",,,.F.,.F.,,.T.,.F.,"","dEmiss",,)
        
        nLin +=11
		oSayP10     := TSay():New( nLin,nCol+010  ,{||"Moeda:"}									,oGrpP1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008) 
		oGetP08     := TGet():New( nLin-1,nCol+047,{|u| If(PCount()>0,cMoeda:=u,cMoeda)}       	,oGrpP1,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.	,"",,,.F.,.F.,,.T.,.F.,"","cMoeda",,)
		
        nLin := nTamG3 + 13
        oSayP03     := TSay():New( nLin,nCol+070,{||"Codigo:"}      ,oGrpP2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
        oSayP04     := TSay():New( nLin,nCol+125,{||"Descricao:"}   ,oGrpP2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)

        nLin += 7
        oGetP03     := TGet():New( nLin,nCol+070,{|u| If(PCount()>0,cCod:=u,cCod)}      ,oGrpP2,040,008,,,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cCod",,) 
        oGetP04     := TGet():New( nLin,nCol+125,{|u| If(PCount()>0,cDescr:=u,cDescr)}  ,oGrpP2,130,008,,,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cDescr",,) 
        
        nLin += 2
        oSayPT01     := TSay():New( nLin,nCol+010,{||"Produto  "}	,oGrpP2,,oFont14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)  
        
        //nLin += 2
	    oSayXP02     := TSay():New( nLin+20,nCol+010,{||"Valores"}	,oGrpP2,,oFont14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)   
	    
	    //nLin += 2
      	//oSayXP03     := TSay():New( nLin+40,nCol+010,{||"Valores"},oGrpP2,,oFont14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)            
        
        nLin += 11
        oSayP05     := TSay():New( nLin,nCol+070,{||"Valor Unit:"}  ,oGrpP2,,,.F.,.F.,.F.,.T.,xColP05,CLR_WHITE,032,008)
        oSayP06     := TSay():New( nLin,nCol+125,{||"Quantidade:"}  ,oGrpP2,,,.F.,.F.,.F.,.T.,xColP06,CLR_WHITE,032,008)
        oSayP07     := TSay():New( nLin,nCol+180,{||"Total:"}       ,oGrpP2,,,.F.,.F.,.F.,.T.,xColP07,CLR_WHITE,053,048)  
        
        nLin += 7
        oGetP05     := TGet():New( nLin,nCol+070,{|u| If(PCount()>0,nVlUnit:=u,nVlUnit)},oGrpP2,040,008,'@E 999,999,999.9999',,xColP05,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nVlUnit",,) 
        oGetP06     := TGet():New( nLin,nCol+125,{|u| If(PCount()>0,nQuant:=u,nQuant)}  ,oGrpP2,040,008,'@E 999,999,999.9999',,xColP06,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nQuant",,)   //FR - 09/12/2020
        oGetP07     := TGet():New( nLin,nCol+180,{|u| If(PCount()>0,nTot:=u,nTot)}      ,oGrpP2,040,008,'@E 999,999,999.99',,xColP07,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nTot",,) 

        If !lSohReal  //se em algum pedido selecionado, a moeda NรO ษ O REAL, MOSTRA ESSES CAMPOS ADICIONAIS PARA COMPARATIVO
        	
        	oSayXP04     := TSay():New( nLin+02,nCol+230,{||"US$"},oGrpP2,,oFont14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022) 
        	oSayXP05     := TSay():New( nLin+21,nCol+230,{||"R$"} ,oGrpP2,,oFont14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022) 
        	           
        	nLin += 11
        	oSayP11     := TSay():New( nLin,nCol+070,{||"Valor Unit:"}  ,oGrpP2,,,.F.,.F.,.F.,.T.,xColP11,CLR_WHITE,032,008)
        	oSayP12     := TSay():New( nLin,nCol+125,{||"Quantidade:"}  ,oGrpP2,,,.F.,.F.,.F.,.T.,xColP12,CLR_WHITE,032,008)
        	oSayP13     := TSay():New( nLin,nCol+180,{||"Total:"}       ,oGrpP2,,,.F.,.F.,.F.,.T.,xColP13,CLR_WHITE,053,048)  
        	       
        	//nLin += 2
	        //oSayXP02     := TSay():New( nLin,nCol+010,{||"Valores  "}	,oGrpP2,,oFont14N,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,053,022)
	        
        	nLin += 7
        	oGetP11     := TGet():New( nLin,nCol+070,{|u| If(PCount()>0,nDVlUnit:=u,nDVlUnit)}	,oGrpP2,040,008,'@E 999,999,999.9999'	,,xColP11,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nDVlUnit",,) 
        	oGetP12     := TGet():New( nLin,nCol+125,{|u| If(PCount()>0,nQuant:=u,nQuant)}  	,oGrpP2,040,008,'@E 999,999,999.9999'  	,,xColP12,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nQuant",,)   
        	oGetP13     := TGet():New( nLin,nCol+180,{|u| If(PCount()>0,nDTot:=u,nDTot)}      	,oGrpP2,040,008,'@E 999,999,999.99'  	,,xColP13,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nDTot",,) 
            
		Endif
        
        nLin := nTamG3M + 5
        oSayP08     := TSay():New( nLin,nCol+030,{||cMsg1}  ,oGrpP4,,,.F.,.F.,.F.,.T.,CLR_HRED,CLR_WHITE,200,008)
        nLin += 10
        oSayP09     := TSay():New( nLin,nCol+030,{||cMsg2}  ,oGrpP4,,,.F.,.F.,.F.,.T.,CLR_HRED,CLR_WHITE,200,008)
        
        //itens XML
        DbSelectArea("TMPXML")
        TMPXML->(DbGoTop())
        If !lMarkIt
        	oBrwX1   := MsSelect():New( "TMPXML",,,;
                                            {   { "ITEM"       ,"" ,"Item"      ,"" },;
                                                { "CODIGO"     ,"" ,"Produto"   ,"" },;
                                                { "DESCRI"     ,"" ,"Descri็ใo" ,"" };
                                                },.F.,,{nTamG4+8,nCoini+2,(nLiMeio*0.90)-2,(nCoMeio*0.5)-2},,, oGrpX3 )   
                                                oBrwX1:oBrowse:bChange := { || fAtuGridX( TMPXML->ITEM, "0001", aDados, @xCod, @xDescr, @xVlUnit, @xQuant, @xTot,; 
                                                                                            @cPedido, @dEmiss, @cCod, @cDescr, @nVlUnit, @nQuant, @nTot,;
                                                                                            @xColP05, @xColP06, @xColP07, @cMsg2, @cFiltro, .T. ,;
                                                                                            @xColP11, @xColP12, @xColP13, @nDVlUnit , @nDTot, @cMoeda )	 } 
        
        Else
        	//xItemPed
        	oBrwX1   := MsSelect():New( "TMPXML",,,;
                                            {   { "ITEM"       ,"" ,"Item"      ,"" },;
                                                { "CODIGO"     ,"" ,"Produto"   ,"" },;
                                                { "DESCRI"     ,"" ,"Descri็ใo" ,"" };
                                                },.F.,,{nTamG4+8,nCoini+2,(nLiMeio*0.90)-2,(nCoMeio*0.5)-2},,, oGrpX3 )   
                                                oBrwX1:oBrowse:bChange := { || fAtuGridX( TMPXML->ITEM, TMPXML->ITEM, aDados, @xCod, @xDescr, @xVlUnit, @xQuant, @xTot,; 
                                                                                            @cPedido, @dEmiss, @cCod, @cDescr, @nVlUnit, @nQuant, @nTot,;
                                                                                            @xColP05, @xColP06, @xColP07, @cMsg2, @cFiltro, .T. ,;
                                                                                            @xColP11, @xColP12, @xColP13, @nDVlUnit , @nDTot, @cMoeda )	 } 
        Endif
        
        
        //itens Pedido
        DbSelectArea("TMPPED")
        TMPPED->(DbGoTop())
        oBrwP1   := MsSelect():New( "TMPPED",,,;
                                            {   { "PEDIDO"  ,"" ,"Pedido"       ,"" },;
                                                { "ITEMPED" ,"" ,"Item Ped."    ,"" },;
                                                { "CODIGO"  ,"" ,"Produto"      ,"" },;
                                                { "DESCRI"  ,"" ,"Descri็ใo"    ,"" };
                                                },.F.,,{nTamG4+8,(nCoMeio*0.5)+2,(nLiMeio*0.90)-2,(nCoMeio-nCoIni)-2},,, oGrpP3 )   
                                                oBrwP1:oBrowse:bChange := { || fAtuGridP( TMPPED->ITEMXML, TMPPED->ITEM, aDados, @xCod, @xDescr, @xVlUnit, @xQuant, @xTot,; 
                                                                                            @cPedido, @dEmiss, @cCod, @cDescr, @nVlUnit, @nQuant, @nTot,;
                                                                                            @xColP05, @xColP06, @xColP07, @cMsg2    , @cFiltro, .T.,;
                                                                                            @xColP11, @xColP12, @xColP13, @nDVlUnit , @nDTot, @cMoeda )	 } 
         

    oDlg:Activate(,,,.T.)

    If Select("TMPXML") > 0
        dbSelectArea("TMPXML")
        TMPXML->(dbCloseArea())
    EndIf

    If Select("TMPPED") > 0
        dbSelectArea("TMPPED")
        TMPPED->(dbCloseArea())
    EndIf

    If lVisual
        Return(.F.)
    Else
        If nOpgera == 0
            Return(.F.)
        ElseIf nOpGera == 1
            Return(.T.)
        EndIf
    EndIf
EndIf

RestArea(aAreaSA2)
RestArea(aAreaZBZ)

Return(.T.)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fMontaArr  บAutor  ณ Renan Oliveira   บ Data ณ  14/07/20   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Busca e monta array com dados de compara็ใo                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestใo XML                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function fMontaArr(aDadosAux, cChave, cMsg1, cMsg2, lDiverg,lMarkIt,aDadosPed)

Local cQuery    := ""
Local cCount    := "0000"
Local cMsgDiv   := "Hแ diferen็a entre valores (XML x Pedido)"
Local nX        := 0
Local nSalTot   := 0
Local aAreaZBT  := {}  //ZBT->(GetArea())
Local aAreaSC7  := SC7->(GetArea())
Local aAreaSB1  := SB1->(GetArea())
Local cMontaIn  := "" 
Local xMoeda    := ""
Local xNomemoeda:= "" 
Local lReal     := .T.

Private xZBZ  	  := GetNewPar("XM_TABXML","ZBZ")      
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
Private x_Ped_Rec := GetNewPar("XM_PEDREC","N")
Private x_ZBB     := GetNewPar("XM_TABREC","")
Private aHfCloud  := {"0","0"," ","Token",{}}  //CRAUMDE - '0' Nใo integrar, na posi็ใo 1
Private x_Tip_Pre := GetNewPar("XM_TIP_PRE","1")
Private nFormNfe  := Val(GetNewPar("XM_FORMNFE","6")) 
Private nFormCte  := Val(GetNewPar("XM_FORMCTE","6"))
Private cFilUsu   := GetNewPar("XM_FIL_USU","N")
Private cTpRt  	  := "J"

aAreaZBT  := (xZBT)->(GetArea())

cQuery := " SELECT * "  + CRLF
cQuery += "     FROM "+RetSqlName(xZBT)+" ZBT " + CRLF
cQuery += "         WHERE "+xZBT_+"CHAVE = '"+cChave+"' "  + CRLF
If !lMarkIt
	cQuery += "         AND   "+xZBT_+"ITEM  = '" + aDadosAux[1] + "' "  + CRLF
Else
	cMontaIn := fMontaIN(Alltrim(aDadosAux[1])) 
	cQuery += "         AND   "+xZBT_+"ITEM  IN (" + cMontaIn + ") "  + CRLF
Endif
cQuery += "         AND ZBT.D_E_L_E_T_ = ' ' "

If Select("TRB") > 0
	dbSelectArea("TRB")
	dbCloseArea()
EndIf

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TRB", .T., .F. )
dbSelectArea("TRB")
TRB->(dbGoTop())
If TRB->(!Eof()) 
    aDadosAux[2] := TRB->&(xZBT_+"PRODUT")  // 2 - PRODUTO XML
    aDadosAux[3] := TRB->&(xZBT_+"DESCRI")  // 3 - DESCRICAO PRODUTO XML            
    aDadosAux[4] := TRB->&(xZBT_+"QUANT")   // 4 - QUANTIDADE XML
	aDadosAux[5] := TRB->&(xZBT_+"VUNIT")   // 5 - VALOR UNITARIO XML
	aDadosAux[6] := TRB->&(xZBT_+"TOTAL")   // 6 - TOTAL XML
EndIf
If cModelo <> "RP"
    For nX := 1 to Len(aDadosAux[8])
        
        cCount := SOMA1(cCount)

        aDadosAux[8,nX,1]   := cCount       // 01 - CONTROLE DE ITEM DO GRID

        dbSelectArea("SC7")
        SC7->(dbSetOrder(1))         //C7_FILIAL + C7_NUM + C7_ITEM
        If SC7->(dbSeek(xFilial("SC7")+aDadosAux[8,nX,2]+aDadosAux[8,nX,3]))
            aDadosAux[8,nX,4]   := SC7->C7_PRODUTO      // 04 - PRODUTO PEDIDO
            aDadosAux[8,nX,6]   := SC7->C7_EMISSAO      // 06 - EMISSAO PEDIDO  

            dbSelectArea("SB1")
            SB1->(dbSetOrder(1))
            If SB1->(dbSeek(xFilial("SB1")+SC7->C7_PRODUTO))
                aDadosAux[8,nX,5]   := SB1->B1_DESC     // 05 - DESCRICAO PRODUTO PEDIDO
            EndIf

            aDadosAux[8,nX,7]   := SC7->C7_QUANT        // 07 - QUANTIDADE PEDIDO
            
            //FR - 14/06/2022 - Brasmolde - Converte o valor do item no xml para d๓lar para comparar com o item do SC7
            //aDadosAux[8,nX,8]   := SC7->C7_PRECO        // 08 - VALOR UNITARIO PEDIDO
            //aDadosAux[8,nX,9]   := SC7->C7_TOTAL        // 09 - TOTAL PEDIDO
            If SC7->C7_MOEDA <> 1
                    
                lReal    := .F. 
                lSohReal := .F.
                //aqui povoa na moeda original do pedido (no caso aqui diferente de real)
                aDadosAux[8,nX,8]   := SC7->C7_PRECO 					      				// 08 - VALOR UNITARIO PEDIDO
                aDadosAux[8,nX,9]   := SC7->C7_TOTAL 				         				// 09 - TOTAL PEDIDO
                aDadosAux[8,nX,10]  := SC7->(C7_QUANT-C7_QUJE-C7_QTDACLA)                   // 10 - SALDO PEDIDO        
                aDadosAux[8,nX,11]  := (SC7->(C7_QUANT-C7_QUJE-C7_QTDACLA)) * SC7->C7_PRECO // 11 - TOTAL
                
                //aqui como a moeda nใo ้ o REAL; povoa as outras posi็๕es referente a valores em outras moedas, para comparativo na tela:
                aDadosAux[8,nX,14]   := SC7->C7_PRECO * SC7->C7_TXMOEDA       	// 08 - VALOR UNITARIO PEDIDO
                aDadosAux[8,nX,15]   := SC7->C7_TOTAL * SC7->C7_TXMOEDA         // 09 - TOTAL 
                
            Else
            
                aDadosAux[8,nX,8]   := SC7->C7_PRECO        								// 08 - VALOR UNITARIO PEDIDO
                aDadosAux[8,nX,9]   := SC7->C7_TOTAL        								// 09 - TOTAL PEDIDO
                aDadosAux[8,nX,10]  := SC7->(C7_QUANT-C7_QUJE-C7_QTDACLA)                   // 10 - SALDO PEDIDO        
                aDadosAux[8,nX,11]  := (SC7->(C7_QUANT-C7_QUJE-C7_QTDACLA)) * SC7->C7_PRECO // 11 - TOTAL
            
            Endif
            
            xMoeda  := SC7->C7_MOEDA 
            xNomemoeda := "MV_MOEDA" + cValToChar(xMoeda)  //MV_MOEDA2
            cMoeda  := GetMv(xNomemoeda) 
            aDadosAux[8,nX,17]:= cMoeda	 
                        
            //FR - 14/06/2022 - Brasmolde - Converte o valor do item no xml para d๓lar para comparar com o item do SC7         
            
            nSalTot += aDadosAux[8,nX,10]  
            
        EndIf

        //Verifica Cor para o Campo Valor Unitario / Total
        If cMoeda <> "REAL"
            If aDadosAux[5] == aDadosAux[8,nX,14]
                aDadosAux[8,nX,12]  := CLR_BLACK    // 12 - COR DIF. VALOR UNIT 
            Else
                aDadosAux[8,nX,16]  := CLR_HRED     // 12 - COR DIF. VALOR UNIT 
                aDadosAux[8,nX,13]  := cMsgDiv      // 13 - MSG 2       
                lDiverg := .T.
            EndIf
        
        Else
            
            If aDadosAux[5] == aDadosAux[8,nX,8]
                aDadosAux[8,nX,12]  := CLR_BLACK    // 12 - COR DIF. VALOR UNIT 
            Else
                aDadosAux[8,nX,12]  := CLR_HRED     // 12 - COR DIF. VALOR UNIT 
                aDadosAux[8,nX,13]  := cMsgDiv      // 13 - MSG 2       
                lDiverg := .T.
            EndIf
        Endif 

    Next nX

Else //FR - 11/07/2023 - TRATATIVA PARA NF SERVIวO
    /*  //PARA REFERสNCIA DAS POSIวีES DO ARRAY
     aDadosPed := {  "",;                // 01 - CONTROLE DE ITEM DO GRID
                            aWBrowse[nX,5],;    // 02 - PEDIDO
                            aWBrowse[nX,1],;    // 03 - ITEM PEDIDO
                            aWBrowse[nX,3],;    // 04 - PRODUTO PEDIDO
                            aWBrowse[nX,4],;    // 05 - DESCRICAO PRODUTO PEDIDO
                            "",;                // 06 - EMISSAO PEDIDO
                            0,;                 // 07 - QUANTIDADE PEDIDO
                            0,;                 // 08 - VALOR UNITARIO PEDIDO
                            0,;                 // 09 - TOTAL PEDIDO
                            0,;                 // 10 - SALDO PEDIDO
                            0,;                 // 11 - TOTAL
                            0,;                 // 12 - COR DIF. VALOR UNIT 
                            "",;                // 13 - MSG 2
                            0,;					// 14 - VALOR UNITARIO MOEDA X
                            0,;					// 15 - TOTAL PEDIDO MOEDA X
                            0,;                 // 16 - COR DIF. VALOR UNIT MOEDA X
                            "";					// 17 - MOEDA DO PEDIDO DE COMPRA 
                            }           

    */
    //For nX := 1 to Len(aDadosPed)
        nX := 1
        cCount := SOMA1(cCount)
        Aadd(aDadosAux[8] , Array(20) )
        aDadosAux[8,nX,1]   := cCount       // 01 - CONTROLE DE ITEM DO GRID
        aDadosAux[8,nX,2]   := aDadosPed[2]  //nro pedido compra
        aDadosAux[8,nX,3]   := aDadosPed[3]  //item pedido compra

        dbSelectArea("SC7")
        SC7->(dbSetOrder(1))         //C7_FILIAL + C7_NUM + C7_ITEM
        If SC7->(dbSeek(xFilial("SC7")+aDadosPed[2]+aDadosPed[3]))
            aDadosAux[8,nX,4]   := SC7->C7_PRODUTO      // 04 - PRODUTO PEDIDO
            aDadosAux[8,nX,6]   := SC7->C7_EMISSAO      // 06 - EMISSAO PEDIDO  

            dbSelectArea("SB1")
            SB1->(dbSetOrder(1))
            If SB1->(dbSeek(xFilial("SB1")+SC7->C7_PRODUTO))
                aDadosAux[8,nX,5]   := SB1->B1_DESC     // 05 - DESCRICAO PRODUTO PEDIDO
            EndIf

            aDadosAux[8,nX,7]   := SC7->C7_QUANT        // 07 - QUANTIDADE PEDIDO
            
            //FR - 14/06/2022 - Brasmolde - Converte o valor do item no xml para d๓lar para comparar com o item do SC7
            //aDadosAux[8,nX,8]   := SC7->C7_PRECO        // 08 - VALOR UNITARIO PEDIDO
            //aDadosAux[8,nX,9]   := SC7->C7_TOTAL        // 09 - TOTAL PEDIDO
            If SC7->C7_MOEDA <> 1
                    
                lReal    := .F. 
                lSohReal := .F.
                //aqui povoa na moeda original do pedido (no caso aqui diferente de real)
                aDadosAux[8,nX,8]   := SC7->C7_PRECO 					      				// 08 - VALOR UNITARIO PEDIDO
                aDadosAux[8,nX,9]   := SC7->C7_TOTAL 				         				// 09 - TOTAL PEDIDO
                aDadosAux[8,nX,10]  := SC7->(C7_QUANT-C7_QUJE-C7_QTDACLA)                   // 10 - SALDO PEDIDO        
                aDadosAux[8,nX,11]  := (SC7->(C7_QUANT-C7_QUJE-C7_QTDACLA)) * SC7->C7_PRECO // 11 - TOTAL
                
                //aqui como a moeda nใo ้ o REAL; povoa as outras posi็๕es referente a valores em outras moedas, para comparativo na tela:
                aDadosAux[8,nX,14]   := SC7->C7_PRECO * SC7->C7_TXMOEDA       	// 08 - VALOR UNITARIO PEDIDO
                aDadosAux[8,nX,15]   := SC7->C7_TOTAL * SC7->C7_TXMOEDA         // 09 - TOTAL 
                
            Else
            
                aDadosAux[8,nX,8]   := SC7->C7_PRECO        								// 08 - VALOR UNITARIO PEDIDO
                aDadosAux[8,nX,9]   := SC7->C7_TOTAL        								// 09 - TOTAL PEDIDO
                aDadosAux[8,nX,10]  := SC7->(C7_QUANT-C7_QUJE-C7_QTDACLA)                   // 10 - SALDO PEDIDO        
                aDadosAux[8,nX,11]  := (SC7->(C7_QUANT-C7_QUJE-C7_QTDACLA)) * SC7->C7_PRECO // 11 - TOTAL
                aDadosAux[8,nX,14]   := SC7->C7_PRECO                                   	// 14 - VALOR UNITARIO PEDIDO
                aDadosAux[8,nX,15]   := SC7->C7_TOTAL                                       // 15 - TOTAL 
            
            Endif
            
            xMoeda  := SC7->C7_MOEDA 
            xNomemoeda := "MV_MOEDA" + cValToChar(xMoeda)  //MV_MOEDA2
            cMoeda  := GetMv(xNomemoeda) 
            aDadosAux[8,nX,17]:= cMoeda	 
                        
            //FR - 14/06/2022 - Brasmolde - Converte o valor do item no xml para d๓lar para comparar com o item do SC7         
            
            nSalTot += aDadosAux[8,nX,10]  
            
        EndIf

        //Verifica Cor para o Campo Valor Unitario / Total
        If cMoeda <> "REAL"
            If aDadosAux[5] == aDadosAux[8,nX,14]
                aDadosAux[8,nX,12]  := CLR_BLACK    // 12 - COR DIF. VALOR UNIT 
            Else
                aDadosAux[8,nX,16]  := CLR_HRED     // 12 - COR DIF. VALOR UNIT 
                aDadosAux[8,nX,13]  := cMsgDiv      // 13 - MSG 2       
                lDiverg := .T.
            EndIf
        
        Else
            
            If aDadosAux[5] == aDadosAux[8,nX,8]
                aDadosAux[8,nX,12]  := CLR_BLACK    // 12 - COR DIF. VALOR UNIT 
            Else
                aDadosAux[8,nX,12]  := CLR_HRED     // 12 - COR DIF. VALOR UNIT 
                aDadosAux[8,nX,13]  := cMsgDiv      // 13 - MSG 2       
                lDiverg := .T.
            EndIf
        Endif
    //Next 

Endif 
//Verifica Cor para o Campo Quantidade
If aDadosAux[4] == nSalTot
    aDadosAux[7]   := CLR_BLACK     // 7 - COR DIF. SALDO
ElseIf aDadosAux[4] > nSalTot
    aDadosAux[7]   := CLR_HRED      // 7 - COR DIF. SALDO
    cMsg1           := "Nใo ้ possivel seguir com a inclusใo, "
    cMsg1           += "hแ itens com saldo inferior ao solicitado!"
    lDiverg         := .T.
Else
    aDadosAux[7]  := CLR_HBLUE      // 7 - COR DIF. SALDO
EndIf

RestArea(aAreaSB1)
RestArea(aAreaSC7)
RestArea(aAreaZBT)

Return(aDadosAux)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fGridXML  บAutor  ณ Renan Oliveira   บ Data ณ  13/07/20   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Busca Dados para o Grid do XML                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestใo XML                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function fGridXML(cArqTMP,aEstrutXML,aDados,cChave)

Local nX    := 0 
//Local cCount:= "0000"

//CRIA ARQUIVO TEMPORมRIO COM A ESTRUTURA ACIMA
cArqTMP := CriaTrab( aEstrutXML, .T. )
DbUseArea( .T.,, cArqTMP, "TMPXML", .F., .F. )

If !lMarkIt
	
	For nX := 1 to Len(aDados)
	    RecLock("TMPXML",.T.) 	   
	       	TMPXML->ITEM      := iif(aDados[nX,1] == "*" , "0001", aDados[nX,1])	    
	        TMPXML->CODIGO    := aDados[nX,2]
	        TMPXML->DESCRI    := aDados[nX,3]	            
	    TMPXML->(MsUnlock())
	Next nX
	
Else     //se houve marca็ใo aleat๓ria de itens, precisaremos captar direto da ZBT , porque no aDAdos nใo terใo todos os itens

	cQuery := " SELECT * "  + CRLF
	cQuery += "     FROM "+RetSqlName(xZBT)+" ZBT " + CRLF
	cQuery += "         WHERE "+xZBT_+"CHAVE = '"+cChave+"' "  + CRLF
	cQuery += "         AND ZBT.D_E_L_E_T_ = ' ' "
	
	If Select("TMPX") > 0
		dbSelectArea("TMPX")
		dbCloseArea()
	EndIf
	
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPX", .T., .F. )
	dbSelectArea("TMPX")
	TMPX->(dbGoTop())
	
	If TMPX->(!Eof()) 
		While TMPX->(!Eof())
		 
			DbSelectArea("TMPXML")
			RecLock("TMPXML",.T.) 
	       	TMPXML->ITEM		:= TMPX->&(xZBT_+"ITEM")	       
	        TMPXML->CODIGO    	:= TMPX->&(xZBT_+"PRODUT")
	        TMPXML->DESCRI    	:= TMPX->&(xZBT_+"DESCRI")
	        TMPXML->QTDX 		:= TMPX->&(xZBT_+"QUANT")		
	        TMPXML->VUNIX		:= TMPX->&(xZBT_+"VUNIT")
	        TMPXML->TOTX		:= TMPX->&(xZBT_+"TOTAL")

	       	TMPXML->(MsUnlock())
	       	
	       	DbSelectArea("TMPX")
			TMPX->(Dbskip())
		Enddo 
		
		dbSelectArea("TMPX")
		DbCloseArea()
	Endif

Endif

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fGridPed  บAutor  ณ Renan Oliveira   บ Data ณ  13/07/20   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Busca Dados para o Grid do Pedido                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestใo XML                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function fGridPed(cArqTMP,aEstrutPed,aDados)

Local nX    := 0
Local nY    := 0
Local cCount:= "0000"
//CRIA ARQUIVO TEMPORมRIO COM A ESTRUTURA ACIMA
cArqTMP := CriaTrab( aEstrutPed, .T. )
DbUseArea( .T.,, cArqTMP, "TMPPED", .F., .F. )

For nX := 1 to Len(aDados)
    For nY := 1 to Len(aDados[nX,8])
    	cCount := SOMA1(cCount)
        RecLock("TMPPED",.T.)
        	If !lMarkIt 
            	TMPPED->ITEMXML := iif(aDados[nX,1] == "*" , "0001" , aDados[nX,1] )
            Else
            	TMPPED->ITEMXML := cCount  //item do XML qdo o item estiver assim: ex.: 0001,002 (concatena็ใo pelo markbrowse de sele็ใo)
            Endif
            TMPPED->ITEM    := aDados[nX,8,nY,1]
            TMPPED->PEDIDO  := aDados[nX,8,nY,2]
            TMPPED->ITEMPED := aDados[nX,8,nY,3]
            TMPPED->CODIGO  := aDados[nX,8,nY,4]
            TMPPED->DESCRI  := aDados[nX,8,nY,5]
        TMPPED->(MsUnlock())
    Next nY
Next nX

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fAtuGridX บAutor ณ Renan Oliveira   บ Data ณ  14/07/20   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Busca e atualiza itens do Grid                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestใo XML                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function fAtuGridX(xItemXML, xItemPed, aDados, xCod, xDescr, xVlUnit, xQuant, xTot, cPedido, dEmiss,;
                             cCod, cDescr, nVlUnit, nQuant, nTot, xColP05, xColP06, xColP07, cMsg2, cFiltro, lAtualiza,;
                             xColP11, xColP12, xColP13, nDVlUnit, nDTot, cMoeda)

Local nPosXML       := 0
Local nPosPed       := 0
Local xTX           := 0
Local lReal 		:= .T.
Local ii            := 0
Default lAtualiza   := .T.
Default lMarkIt     := .F.

//nPosXml := aScan( aDados,{ |x| x[1] == xItemXML } )   //FR - 06/07/2021

If !lMarkIt
	nPosXml := aScan( aDados,{ |x| x[1] == xItemXML } )
	nPosPed := aScan( aDados[nPosXml,8],{ |x| x[1] == xItemPed } ) 
	cFiltro := "ITEMXML = '"+xItemXML+"' "
Else

	aIts := {}
	ii   := 0
	cIt  := ""
	If !Empty(xItemXML)
		//monta o array dos itens concatenados
		//montagem do array aIts para separar os itens selecionados os quais ficaram concatenados por "," entใo separo cada um e coloco num array
		For ii := 1 to Len(xItemXML)
		    If Substr(xItemXML,ii,1) <> ","
		    	cIt += Substr(xItemXML,ii,1) //vai adicionando caracter por caracter, exceto vํrgula
		    Else
		    	Aadd(aIts,cIt)  			//se achar vํrgula, ้ porque jแ tem o n๚mero do item inteiro, entใo adiciona no array
		    	cIt := ""
		    Endif
		Next
		nPosPed := 0 
		nPosXml := 0
		i       := 1
		ii      := 1
		cItPed    := ""
		
		//checagem do array aIts:
		If Len(aIts) > 0
		
			//mediante o array de itens, monta a expressใo de filtro:
			cFiltro := "ITEMXML = "
			lAchou  := .F.
			While ii <= Len(aDados)
						
				If !lAchou
					If i <= Len(aIts)
						_cIt := aIts[i] 
						
						If _cIt $ Alltrim(aDados[ii,1])
							nPosXml := ii						
							cItPed  := aDados[ii,8,1,3]
							nPosPed := aScan( aDados[nPosXml,8],{ |x| x[1] == cItPed } ) 
							If nPosPed == 0
								nPosPed := ii
							Endif
							cFiltro += "'" + Alltrim(_cIt) + "'"
							lAchou  := .T.
							
							cPedido := aDados[nPosXML,8,1,2]
							dEmiss  := aDados[nPosXML,8,1,6]
							cCod    := aDados[nPosXML,8,1,4]
							cDescr  := aDados[nPosXML,8,1,5]
							nQuant  := aDados[nPosXML,8,1,7]
							nVlUnit := aDados[nPosXML,8,1,8]
							nTot    := aDados[nPosXML,8,1,8] * aDados[nPosXML,8,1,7]
							xColP05 := aDados[nPosXML,8,1,12]
							xColP07 := aDados[nPosXML,8,1,12] 
							//xTX     := Posicione("SC7",1,xFilial("SC7")+ cPedido, "C7_TXMOEDA") 
							nDVlUnit:= aDados[nPosXML,8,1,14] //nVlUnit / xTX
							nDTot   := aDados[nPosXML,8,1,15]  //nDVlUnit * nQuant
							xColP11	:= aDados[nPosXML,8,1,16]
							cMoeda  := aDados[nPosXML,8,1,17]
							If cMoeda <> "REAL"
								lReal := .F.
							Endif 
						Endif
					Endif
				Endif
				ii++
				i++					
			Enddo
			
		Else
			//cCod    := TMPXML->CODIGO     //atualiza o c๓digo do produto no painel da direita (PEDIDO)  //NรO PRECISA NESTE CASO
			//cDescr  := TMPXML->DESCRI			
		Endif	
	Endif
Endif

If nPosXML > 0
	dbSelectArea("TMPPED") 
	If !lMarkIt
		SET FILTER TO &cFiltro
	Endif
	dbSelectArea("TMPPED")
	TMPPED->(DbGoTop())
	
	xCod    := aDados[nPosXml,2]	//atualiza o c๓digo do produto no painel da esquerda (XML)
	xDescr  := aDados[nPosXml,3]
	xQuant  := aDados[nPosXml,4]
	xVlUnit := aDados[nPosXml,5]
	xTot    := aDados[nPosXml,6]
	xColP06 := aDados[nPosXml,7]
	If Len(aDados[nPosXML,8]) > 0
		cPedido := aDados[nPosXML,8,nPosPed,2]
		dEmiss  := aDados[nPosXML,8,nPosPed,6]
		cCod    := aDados[nPosXML,8,nPosPed,4]
		cDescr  := aDados[nPosXML,8,nPosPed,5]
		nQuant  := aDados[nPosXML,8,nPosPed,7]
		nVlUnit := aDados[nPosXML,8,nPosPed,8]
		nTot    := aDados[nPosXML,8,nPosPed,8] * aDados[nPosXML,8,nPosPed,7]
		xColP05 := aDados[nPosXML,8,nPosPed,12]
		xColP07 := aDados[nPosXML,8,nPosPed,12] 
		cMsg2   := aDados[nPosXML,8,nPosPed,13] 
		//xTX     := Posicione("SC7",1,xFilial("SC7")+ cPedido, "C7_TXMOEDA") 
		nDVlUnit:= aDados[nPosXML,8,nPosPed,14]  //nVlUnit / xTX
		nDTot   := aDados[nPosXML,8,nPosPed,15]   //nDVlUnit * nQuant
		xColP11 := aDados[nPosXML,8,nPosPed,16] 
		cMoeda  := aDados[nPosXML,8,nPosPed,17] 							
	Endif

Else
	xCod    := TMPXML->CODIGO	//atualiza o c๓digo do produto no painel da esquerda (XML) 
	xDescr  := TMPXML->DESCRI
	xQuant  := TMPXML->QTDX 			
   	xVlUnit := TMPXML->VUNIX
    xTot    := TMPXML->TOTX
    xColP05 := 255	
    xColP06 := 16711680  //aDados[nPosXml,7]
    cMsg2   := "Hแ diferen็a entre valores (XML x Pedido)" //aDados[nPosXML,8,nPosPed,13]
Endif


If lAtualiza
    oSayP05:NCLRTEXT := xColP05
    oGetP05:NCLRTEXT := xColP05
    oSayP06:NCLRTEXT := xColP06
    oGetP06:NCLRTEXT := xColP06
    oSayP07:NCLRTEXT := xColP07
    oGetP07:NCLRTEXT := xColP07 
    
	//valores na moeda do pedido
    oGetX04:Refresh()   //Produto XML
    oGetX05:Refresh()   //Nome Produto XML
    oGetX06:Refresh()   //Valor Unitario XML
    oGetX07:Refresh()   //Quantidade XML
    oGetX08:Refresh()   //Total XML
    oGetP01:Refresh()   //Pedido
    oGetP02:Refresh()   //Emissใo Pedido
    oGetP03:Refresh()   //Produto Pedido
    oGetP04:Refresh()   //Nome Produto Pedido
    oGetP05:Refresh()   //Valor Unitario Pedido
    oGetP06:Refresh()   //Quantidade Pedido
    oGetP07:Refresh()   //Total Pedido   
    
    If !lSohReal
	    //valores em reais quando o pedido ้ feito em d๓lar, abre mais 3 campos para mostrar os valores em R$ 
	    oSayP11:NCLRTEXT := xColP11
    	oGetP11:NCLRTEXT := xColP11 
    
    	oSayP13:NCLRTEXT := xColP13
    	oGetP13:NCLRTEXT := xColP13
    
	    oGetP11:Refresh()   //Valor Unitario Pedido
	    oGetP12:Refresh()   //Quantidade Pedido
	    oGetP13:Refresh()   //Total do pedido
    Endif
     
    oGetP08:Refresh()   //Moeda
    
    oBrwP1:oBrowse:Refresh() 
    
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fAtuGridP บAutor ณ Renan Oliveira   บ Data ณ  02/08/20   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Busca e atualiza itens do Grid do Pedido                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestใo XML                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function fAtuGridP(xItemXML, xItemPed, aDados, xCod, xDescr, xVlUnit, xQuant, xTot, cPedido, dEmiss,;
                             cCod, cDescr, nVlUnit, nQuant, nTot, xColP05, xColP06, xColP07, cMsg2, cFiltro, lAtualiza,;
                             xColP11, xColP12, xColP13, nDVlUnit , nDTot, cMoeda)

Local lReal         := .T.
Default lAtualiza   := .T.

If !Empty(xItemXML)
	If !lMarkIt
		nPosXml := aScan( aDados,{ |x| x[1] == xItemXML } ) 
		//nPosPed := aScan( aDados[nPosXml,8],{ |x| x[1] == xItemPed } )     //FR - 06/07/2021 
    Else
    	nPosXml := Val(xItemXML)
    Endif
    
    nPosPed := aScan( aDados[nPosXml,8],{ |x| x[1] == xItemPed } ) 
	xColP06 := aDados[nPosXml,7] 

	If Len(aDados[nPosXML,8]) > 0
		nPosPed := aScan( aDados[nPosXml,8],{ |x| x[1] == xItemPed } ) 
		cPedido := aDados[nPosXML,8,nPosPed,2]
		dEmiss  := aDados[nPosXML,8,nPosPed,6]
		cCod    := aDados[nPosXML,8,nPosPed,4]
		cDescr  := aDados[nPosXML,8,nPosPed,5]
		nQuant  := aDados[nPosXML,8,nPosPed,7]
		nVlUnit := aDados[nPosXML,8,nPosPed,8]
		nTot    := aDados[nPosXML,8,nPosPed,8] * aDados[nPosXML,8,nPosPed,7]
		xColP05 := aDados[nPosXML,8,nPosPed,12]
		xColP07 := aDados[nPosXML,8,nPosPed,12]  
		cMsg2   := aDados[nPosXML,8,nPosPed,13]  
		
		xMoeda  := Posicione("SC7",1,xFilial("SC7")+ cPedido, "C7_MOEDA") 
		xNomemoeda := "MV_MOEDA" + cValToChar(xMoeda)  //MV_MOEDA2
		cMoeda  := GetMv(xNomemoeda)
		nDVlUnit:= aDados[nPosXML,8,nPosPed,14]
		nDTot   := aDados[nPosXML,8,nPosPed,15]
		xColP11 := aDados[nPosXML,8,nPosPed,16] 
		cMoeda  := aDados[nPosXML,8,nPosPed,17]
		If cMoeda <> "REAL"
			lReal := .F.
		Endif 
	
	Endif 
Endif

If lAtualiza
    oSayP05:NCLRTEXT := xColP05
    oGetP05:NCLRTEXT := xColP05
    oSayP06:NCLRTEXT := xColP06
    oGetP06:NCLRTEXT := xColP06
    oSayP07:NCLRTEXT := xColP07
    oGetP07:NCLRTEXT := xColP07

    If !lSohReal
	    oSayP11:NCLRTEXT := xColP11
	    oGetP11:NCLRTEXT := xColP11
	    oSayP12:NCLRTEXT := xColP12
	    oGetP12:NCLRTEXT := xColP12
	    oSayP13:NCLRTEXT := xColP13
	    oGetP13:NCLRTEXT := xColP13
    Endif

    oGetP01:Refresh()   //Pedido
    oGetP02:Refresh()   //Emissใo Pedido
    oGetP03:Refresh()   //Produto Pedido
    oGetP04:Refresh()   //Nome Produto Pedido
    oGetP05:Refresh()   //Valor Unitario Pedido
    oGetP06:Refresh()   //Quantidade Pedido
    oGetP07:Refresh()   //Total Pedido
    oGetP08:Refresh()   //Moeda Pedido 
    
    If !lSohReal
    	oGetP11:Refresh()
    	oGetP12:Refresh()
    	oGetP13:Refresh()
    Endif
        
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fValidDiv  บAutor  ณ Renan Oliveira   บ Data ณ  24/07/20   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida็ใo do botao aceita divergencia                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestใo XML                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function fValidDiv(cMsg1)

Local lRet := .F.
/*
If !Empty(cMsg1)
    Aviso("Aviso","Nใo ้ possivel seguir com a inclusใo,"+CRLF+;
             "hแ itens com saldo inferior ao solicitado",{"OK"})
Else
    If MsgYesNo("Deseja aceitar as divergencias e prosseguir com a inclusใo?",;
                 "Pedido com divergencias" )
        lRet := .T.
    EndIf

EndIf
*/

/*
//-----------------------------------------------------------------------//
//FR - 20/04/2022 - Altera็ใo para valida็ใo da quantidade, atrelar เ 
//                  escolha do "aceita diverg๊ncia sim/nao" pois estava 
//                  travando geral nใo dando escolha ao cliente
//-----------------------------------------------------------------------//
*/
If !Empty(cMsg1)
    If MsgYesNo("Hแ itens com saldo inferior ao solicitado,"+CRLF+;
             	"Deseja aceitar as divergencias e prosseguir com a inclusใo?")
             	lRet := .T.
    Endif
Else
	If MsgYesNo("Deseja aceitar as divergencias e prosseguir com a inclusใo?",;
                 "Pedido com divergencias" )
        lRet := .T.
    EndIf

Endif  

Return(lRet)  
//----------------------------------------------------------------------------------//
//Fun็ใo : fMontaIN
//Autoria: Flแvia Rocha
//Data   : 14/12/2020
//Objetivo: fun็ใo que recebe uma cadeia de caracteres e monta a expressใo "IN" para
//          ser inserida na clแusula WHERE <campo> IN ...com as aspas e vํrgulas em
//          seus devidos lugares.
//----------------------------------------------------------------------------------//
Static Function fMontaIN(cTexto) 

	Local cAux := ""
	Local fr   := 0
	
	For fr := 1 to Len(cTexto)
		If fr = 1	 
			cAux += "'" + Substr(cTexto,fr,1)
		Endif
		
		If fr > 1
			If Substr(cTexto,fr,1) != ","	 
				cAux += Substr(cTexto,fr,1)
			Else
				cAux += "'" + ",'"  //encerra com aspa o argumento e coloca vํrgula preparando para o pr๓ximo argumento
			Endif
		Endif
		
	Next
	
	If Substr(cAux,Len(cAux)-1,2) = ",'"
		cAux := Substr(cAux,1,Len(cAux)-2) //retira a vํrgula do ๚ltimo argumento
	Endif
	
Return(cAux)
