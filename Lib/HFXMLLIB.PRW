#include "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "Ap5Mail.ch"
#INCLUDE "FILEIO.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "PRTOPDEF.CH"
#INCLUDE "FWMVCDEF.CH"
#include "Topconn.ch"

//#INCLUDE "INKEY.CH"

//-------------------------------------------------------------------------//
//Altera็๕es Realizadas:
//FR - 07/12/2021 - Projeto Kitchens - Solicitado por Rafael Lobitsky
//                  Inclusใo de rotina para gera็ใo de pedido compra
//                  Adaptar chamada tela amarra็ใo HFITNENC 
//                  para ser chamada do HFXML08PC
//-------------------------------------------------------------------------//
#DEFINE IMP_PDF 6


Static cCodigo := space( Len( SB1->B1_COD ) )


//cTipoProc -> AVRC -> Aviso Recebimento de Carga
//             PREN -> Pr้-Nota de Entrada
//             NFCF -> NT Conhecimento Frete
//             PDRC -> Pedido Recorrente
//cTipoCPro -> esta variแvel tem que vir como private
//aCabec    -> tem que vir como private
//nErrItens -> variแvel para controlar quantas vezes passou pelos ํtens, mostrar erros apenas uma vez, na segunda cai fora
//aProdZr   -> Produtos com valores unitแrios Zerado.
User Function HFITNENC( cTipoProc, aProdOk, aProdNo, aProdVl, nErrItens, aProdZr, cTipoCPro, lAmarrou )  //NFSE_03

Local lRet := .T.

Private oFont01   := TFont():New("Arial",07,14,,.T.,,,,.T.,.F.)

Default cTipoCPro := "1"
Default lAmarrou  := .F.

//FR - 16/12/2021 - Kitchens
lRet := ItNaoEnc( cTipoProc, aProdOk, aProdNo, aProdVl, nErrItens, aProdZr, cTipoCPro, @lAmarrou )

Return lRet


Static Function ItNaoEnc( cTipoProc, aProdOk, aProdNo, aProdVl, nErrItens, aProdZr, cTipocPro, lAmarrou )

Local lRet := .T.
Local cTit1 := ""
Local cTit2 := "" 
Local cAli  := iif(cTipoProc == "AVRC", "DB3", "SD1" )
Local cTips := "" //iif(cTipoProc $ "NFCF,PDRC", Iif(Empty( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC"))) ),"N", AllTrim( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC"))) ) ), aCabec[1][2] )
Local oDlg
Local Nx    := 0 

Private cInfo := ""

//FR - 16/12/2021 - Kitchens
Default cTipoCPro := "1"
Default lAmarrou  := .F.

//If cTipoProc $ "NFCF,PDRC"
	If Empty( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC"))) )
		cTips := "N"

	ElseIF !Empty((xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC"))) ) 
		cTips := AllTrim( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC"))) )
	
	Else 
		cTips := Alltrim(aCabec[1][2])
	Endif 
//Endif
//FR - 16/12/2021 - Kitchens 

if nErrItens == NIL

	nErrItens := 1
	
endif

cTit1 := iif( (cTipoProc == "AVRC"), "Avisos - Gera็ใo Av. Rec. Carga",;
         iif( (cTipoProc == "NFCF"), "Avisos - Gera็ใo Nt Conhec Frete",;
         iif( (cTipoProc == "PDRC"), "Avisos - Manuten็ใo Pedido Recorrente",;
                                     "Avisos - Gera็ใo Pr้-Nota" ) ) )
cTit2 := iif( (cTipoProc == "AVRC"), "Avisos - Av. Rec. Carga Interrompido",;
         iif( (cTipoProc == "NFCF"), "Avisos - Nt Conhec Frete Interrompido",;
         iif( (cTipoProc == "PDRC"), "Avisos - Manuten็ใo Pedido Recorrente",;
                                     "Avisos - Gera็ใo Pr้-Nota Interrompida" ) ) )

//Itens nใo encontrados
If !Empty(aProdNo)

	if nErrItens < 2  
	
		If Empty(aProdOk)                                                     
			
			aadd(aProdOk,{"- - -","- - - - - - -"} )		
		
		EndIf
		
		if cTipoProc == "AVRC"
		
			cInfo := "A Gera็ใo do Aviso Recebimento de Carga serแ Interrompido ... "+CRLF
		
		elseif cTipoProc == "NFCF"
		
			cInfo := "A Gera็ใo da Nt Conhec Frete serแ Interrompida ... "+CRLF
		
		elseif cTipoProc == "PDRC"
		
			cInfo := "A Manuten็ใo de Pedido Recorrente serแ Interrompida ... "+CRLF
		
		else
		
			cInfo := "A Gera็ใo da Pre-Nota serแ Interrompida ... "+CRLF
			
		endif
		
		cInfo += "Itens OK."+CRLF
		
		For Nx := 1 to Len(aProdOk)
		
			cInfo += aProdOk[Nx][1]+" - "+aProdOk[Nx][2]+CRLF
			
		Next

		cInfo += "Itens com problemas."+CRLF
		
		For Nx := 1 to Len(aProdNo)
		
			cInfo += aProdNo[Nx][1]+" - "+aProdNo[Nx][2]+CRLF
			
		Next

		DEFINE MSDIALOG oDlg TITLE cTit1 FROM 000,000 TO 500,500 PIXEL
	
		@ 010,010 Say "Produtos Encontrados:"     PIXEL OF oDlg COLOR CLR_BLUE FONT oFont01
		@ 020,010 LISTBOX oLbx1 FIELDS HEADER ;
		   "Produto", "Descri็ใo" ;
		   SIZE 230,095 OF oDlg PIXEL
			                                      
		oLbx1:SetArray( aProdOk )
		oLbx1:bLine := {|| {aProdOk[oLbx1:nAt,1],;
		     	            aProdOk[oLbx1:nAt,2]}}

		@ 125,010 Say "Produtos Nใo Encontrados:" PIXEL OF oDlg COLOR CLR_RED FONT oFont01
		@ 135,010 LISTBOX oLbx2 FIELDS HEADER ;
		   "Produto", "Descri็ใo" ;
		   SIZE 230,095 OF oDlg PIXEL ON DBLCLICK( PutDePara(oLbx1,oLbx2,cTips,cTipoCPro,;
		                                 (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))),(xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR"))),(xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR"))) , @lAmarrou )) //FR - 16/12/2021 - Kitchens

		oLbx2:SetArray( aProdNo )
		oLbx2:bLine := {|| {aProdNo[oLbx2:nAt,1],;
		     	            aProdNo[oLbx2:nAt,2]}}
	
		if cTipoCPro == "2"
			
			@ 023.2,005 BUTTON "Amarra Todos" SIZE 40,15 OF oDlg Action (PutDePara2(@oLbx1,@oLbx2,cTips,cTipoCPro,;
			                                                             (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))),(xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR"))),(xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR"))),;
			                                                             @aProdOk,@aProdNo) )
		
		endif
		
		@ 023.2,040 BUTTON "Cancela" SIZE 35,15 OF oDlg Action oDlg:End()
		@ 023.2,040 BUTTON "Detalhe" SIZE 35,15 OF oDlg Action (U_MyAviso("Aviso","Existem itens que nใo encontraram amarra็ใo."+CRLF+cInfo,{"OK"},3))
		@ 023.2,050 BUTTON "OK" SIZE 35,15 OF oDlg Action oDlg:End()
	  		
		ACTIVATE MSDIALOG oDlg CENTER
		
	EndIf
	
    lRet := .F.
    
Endif

if lRet //s๓ verificar isto, se o outro estiver Ok.
	
	//Produto com probela de valores, devido modifica็ใo pelo ponto de Entrada
	If !Empty(aProdVl)                                                     

		DEFINE MSDIALOG oDlg TITLE cTit2 FROM 000,000 TO 550,650 PIXEL

		@ 010,010 Say "Itens divergentes entre valor do item no xml e calculado da 2a Unidade de Medida (PE - U_XMLPE2UM):" PIXEL OF oDlg COLOR CLR_RED FONT oFont01
		@ 020,010 LISTBOX oLbx2 FIELDS HEADER ;
		   "Produto", "vPROD no XML", "UM", "Qtd", "Vr Unitario", "Vr Total" ;
		   SIZE 310,230 OF oDlg PIXEL

		oLbx2:SetArray( aProdVl )
		oLbx2:bLine := {|| {aProdVl[oLbx2:nAt,1],;
		     	            transform(aProdVl[oLbx2:nAt,5],PesqPict(cAli,iif(cTipoProc == "AVRC",'DB3_TOTAL','D1_TOTAL') )),;
		     	            aProdVl[oLbx2:nAt,2],;
		     	            transform(aProdVl[oLbx2:nAt,3],PesqPict(cAli,iif(cTipoProc == "AVRC",'DB3_QUANT','D1_QUANT') )),;
		     	            transform(aProdVl[oLbx2:nAt,4],PesqPict(cAli,iif(cTipoProc == "AVRC",'DB3_VUNIT','D1_VUNIT') )),;
		     	            transform(aProdVl[oLbx2:nAt,6],PesqPict(cAli,iif(cTipoProc == "AVRC",'DB3_TOTAL','D1_TOTAL') )) }}

		@ 025.2,040 BUTTON "SAIR" SIZE 35,15 OF oDlg Action ( lRet := .F., oDlg:End() )
		@ 025.2,059 BUTTON "CONTINUAR MESMO ASSIM" SIZE 85,15 OF oDlg Action ( lRet := .T., oDlg:End() )

		ACTIVATE MSDIALOG oDlg CENTER
		
	    //lRet := .F.
		nErrItens := 2
		
	EndIf
	
Endif

if lRet //s๓ verificar isto, se o outro estiver Ok.
	
	//Produto com probela de valores unitแrios
	If !Empty(aProdZr)                                                     
		
		DEFINE MSDIALOG oDlg TITLE cTit2 FROM 000,000 TO 550,650 PIXEL

		@ 010,010 Say "Itens sem valor unitแrio:" PIXEL OF oDlg COLOR CLR_RED FONT oFont01
		@ 020,010 LISTBOX oLbx2 FIELDS HEADER ;
		   "Item","Produto","Produto Interno", "Vr Unitario", "Descri็ใo" ;
		   SIZE 310,230 OF oDlg PIXEL

		oLbx2:SetArray( aProdZr )
		oLbx2:bLine := {|| {aProdZr[oLbx2:nAt,1],;
		     	            aProdZr[oLbx2:nAt,2],;
		     	            aProdZr[oLbx2:nAt,3],;
		     	            transform(aProdZr[oLbx2:nAt,4],PesqPict(cAli,iif(cTipoProc == "AVRC",'DB3_VUNIT','D1_VUNIT') )),;
		     	            aProdZr[oLbx2:nAt,5] }}

		@ 025.2,069 BUTTON "OK" SIZE 35,15 OF oDlg Action oDlg:End()

		ACTIVATE MSDIALOG oDlg CENTER
		
	    lRet := .F.
		nErrItens := 2
		
	EndIf
	
Endif

Return lRet


//Para Ajustar o F3 do bixo
Static Function verNcm(oDlg,loDlg)

Local cQuery := ""
Local aArea  := GetArea()
Local nNc    := 0
Local lRet   := .T.
Local cAliasSB1 := ""

Default loDlg := .T.

if loDlg

	oDlg:Refresh()
	
endif

if ! Empty(cNcm)

	cAliasSB1 := GetNextAlias()
	cQuery := "SELECT B1_COD  "
	cQuery += "FROM "+RetSqlName("SB1")+" SB1 "
	cQuery += "WHERE B1_FILIAL='"+xFilial("SB1")+"' "
	cQuery += " AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += " AND B1_POSIPI = '"+alltrim(cNcm)+"' "
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSB1)
	
	DbSelectARea( cAliasSB1 )
	
	Do While .Not. ( cAliasSB1 )->( Eof() )
	
		nNc++
		
		exit
		
		( cAliasSB1 )->( dbSkip() )
		
	EndDo
	
	if nNc == 0
	
		lRet := .F.
		
		if loDlg
		
			Alert( "Nใo Existe Cadastro de Produto com esse NCM..." )
	
		else
		
			cNcm := space( len( cNcm ) )
			
		endif
		
	endif
	
	DbCloseArea()
	
endif

RestArea( aArea )

Return( lRet )

/*/
`ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPutDePara บ Autor ณ Roberto Souza      บ Data ณ  25/01/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Inclui de/para de inclusao de pre-nota                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Geral                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function PutDePara(oLbx1,oLbx2,cTipoNF,cTipoAm,cCnpjEmi,cCodEmit,cLojaEmit, lAmarrou)

//Local oMsg
Local lRet    := .F.           
Local nOpc    := 0   
//Local aDados  := {}                                
Local nTamProd    := TAMSX3("B1_COD")[1]
Local nLinha  := oLbx2:NAT
//Local oItem   := oLbx2:AARRAY[nLinha]
Local cTblCad := Iif(cTipoNF $ "D|B","SA1","SA2")
Local cTblDP  := Iif(cTipoAm=="2",xZB5, Iif(cTipoNF $ "D|B", "SA7","SA5")  )
Local lGravou := .F.
Local lExiste := .F.
Local aArea   := GetArea()
Local cNomeEnt:= ""
Local cKeyFe  := SetKEY( VK_F3 ,  Nil )
Local cConsSB1:= GetNewPar("XM_PESSB1","N") //Parametro de pesquisa padrao SB1 ou customizada
Local cF3     := ""

Private oDlg

//FR - 16/12/2021 - Kitchens
Default lAmarrou := .F.

If cTipoAm == "3"

	U_MyAviso("Aviso","Relacionamento sem amarra็ใo. Deve ser cadastrado direto no Cadastro de Produto!",{"OK"},2)
	
	SetKEY( VK_F3 ,  cKeyFe )
	
	oLbx1:Refresh()
	oLbx2:Refresh()
	
	RestArea(aArea)
	
	Return(.F.)
	
EndIf

If cTblCad == "SA2"

	cNomEmit := Posicione("SA2",3,xFilial("SA2")+cCnpjEmi,"A2_NOME")
	cNomeEnt := "Fornecedor"
	
Else

	cNomEmit :=  Posicione("SA1",3,xFilial("SA1")+cCnpjEmi,"A1_NOME")
	cNomeEnt := "Cliente"
	
EndIf
	
cCodProd := oLbx2:AARRAY[nLinha][1]
cDescProd:= oLbx2:AARRAY[nLinha][2]

cCodProdP  := Space(nTamProd)
cDescProdP := Space(60)

Private cNcm := iif( Type("oxml:_nfeproc:_nfe:_infnfe:_det:_prod:_ncm:text") <> "U", oxml:_nfeproc:_nfe:_infnfe:_det:_prod:_ncm:text, Criavar("B1_POSIPI") )
Private oCdp

//alert(cNcm)

verNcm(,.F.)    //vamos fadigar

DEFINE MSDIALOG oDlg TITLE "Relacionamento De/Para : "+cTblDP FROM 0,0 TO 280,552 OF oDlg PIXEL

@ 06,06 TO 070,271 LABEL "Dados do " + cNomeEnt OF oDlg PIXEL

@ 15,015 SAY   "Codigo" SIZE 45,8 PIXEL OF oDlg       
@ 25,015 MSGET cCodEmit PICTURE "@!" SIZE 30,08 PIXEL OF oDlg WHEN .F.

@ 15,050 SAY "Loja"  SIZE 45,8 PIXEL OF oDlg
@ 25,050 MSGET cLojaEmit PICTURE "@!" SIZE 20,08 PIXEL OF oDlg WHEN .F.

@ 15,075 SAY "CNPJ"   SIZE 45,8 PIXEL OF oDlg
@ 25,075 MSGET cCnpjEmi PICTURE "@ 99.999.999/9999-99" SIZE 50,08 PIXEL OF oDlg WHEN .F.

@ 15,130 SAY   "Nome" SIZE 45,8 PIXEL OF oDlg       
@ 25,130 MSGET cNomEmit PICTURE "@!" SIZE 130,08 PIXEL OF oDlg WHEN .F.

@ 45,015 SAY   "Cod Produto" SIZE 45,8 PIXEL OF oDlg       
@ 55,015 MSGET cCodProd PICTURE "@!" SIZE 60,08 PIXEL OF oDlg WHEN .F.

@ 45,080 SAY   "Descri็ใo Produto" SIZE 45,8 PIXEL OF oDlg       
@ 55,080 MSGET cDescProd PICTURE "@!" SIZE 130,08 PIXEL OF oDlg WHEN .F.

@ 045,215 SAY   "NCM" SIZE 45,8 PIXEL OF oDlg       
@ 055,215 MSGET cNCM F3 "SYD" PICTURE "@R 9999.99.99"  SIZE 50,08 PIXEL OF oDlg Valid( verNcm(@oDlg) ) //WHEN iif(!Empty(cNCM), .F., .T.) 

//Verifica se a consulta SB1 serแ padrใo ou customizada
if cConsSB1 == "N"

	cF3 := "HFNCM"
	
else

	cF3 := "SB1"
	
endif

@ 76,06 TO 116,271 LABEL "Produto pr๓prio" OF oDlg PIXEL

@ 085,015 SAY   "Cod Produto" SIZE 45,8 PIXEL OF oDlg       
@ 095,015 MSGet oCdp VAR cCodProdP F3 cF3 PICTURE "@!" SIZE 70,08 PIXEL OF oDlg Valid( cDescProdP:=Posicione("SB1",1,xFilial("SB1")+cCodProdP,"B1_DESC") )

@ 085,090 SAY   "Descri็ใo Produto" SIZE 45,8 PIXEL OF oDlg       
@ 095,090 MSGET cDescProdP PICTURE "@!" SIZE 130,08 PIXEL OF oDlg WHEN .F. 
                                                 
@ 125,195 BUTTON "Cancelar" SIZE 35,12 PIXEL OF oDlg Action(nOpc:= 0,oDlg:End())
@ 125,235 BUTTON "Salvar" SIZE 35,12 PIXEL OF  oDlg Action(nOpc:= 1,iif(  _verSB1(cCodProdP),oDlg:End(),U_MyAviso("Aviso","Produto pr๓prio nใo cadastrado",{"OK"},1)) )


ACTIVATE MSDIALOG oDlg CENTERED


If nOpc == 1 .And. !Empty(cCodProdP)

	If cTblDP == xZB5
	
		If cTblCad == "SA2"
		
			RecLock(xZB5,.T.)
			
			(xZB5)->(FieldPut(FieldPos(xZB5_+"FILIAL"), xFilial(xZB5)))
			(xZB5)->(FieldPut(FieldPos(xZB5_+"FORNEC"), cCodEmit))
			(xZB5)->(FieldPut(FieldPos(xZB5_+"LOJFOR"), cLojaEmit))
			(xZB5)->(FieldPut(FieldPos(xZB5_+"CGC"),    cCnpjEmi))
			(xZB5)->(FieldPut(FieldPos(xZB5_+"NOME"),   cNomEmit))
			(xZB5)->(FieldPut(FieldPos(xZB5_+"PRODFO"), cCodProd))
			(xZB5)->(FieldPut(FieldPos(xZB5_+"PRODFI"), cCodProdP))
			(xZB5)->(FieldPut(FieldPos(xZB5_+"DESCPR"), cDescProdP))
			(xZB5)->(FieldPut(FieldPos(xZB5_+"CLIENT"), ""))
			(xZB5)->(FieldPut(FieldPos(xZB5_+"CGCC"),   ""))
			(xZB5)->(FieldPut(FieldPos(xZB5_+"NOMEC"),  ""))
			(xZB5)->(FieldPut(FieldPos(xZB5_+"LOJCLI"), ""))
												
			MsUnlock()
			
			lGravou := .T.
			
		ElseIf cTblCad == "SA1"
		
			RecLock(xZB5,.T.)
			
			(xZB5)->(FieldPut(FieldPos(xZB5_+"FILIAL"), xFilial(xZB5)))
			(xZB5)->(FieldPut(FieldPos(xZB5_+"FORNEC"), ""))
			(xZB5)->(FieldPut(FieldPos(xZB5_+"LOJFOR"), ""))
			(xZB5)->(FieldPut(FieldPos(xZB5_+"CGC"),    ""))
			(xZB5)->(FieldPut(FieldPos(xZB5_+"NOME"),   ""))
			(xZB5)->(FieldPut(FieldPos(xZB5_+"PRODFO"), cCodProd))
			(xZB5)->(FieldPut(FieldPos(xZB5_+"PRODFI"), cCodProdP))
			(xZB5)->(FieldPut(FieldPos(xZB5_+"DESCPR"), cDescProdP))
			(xZB5)->(FieldPut(FieldPos(xZB5_+"CLIENT"), cCodEmit))
			(xZB5)->(FieldPut(FieldPos(xZB5_+"LOJCLI"), cLojaEmit))									
			(xZB5)->(FieldPut(FieldPos(xZB5_+"CGCC"),   cCnpjEmi))
			(xZB5)->(FieldPut(FieldPos(xZB5_+"NOMEC"),  cNomEmit))
		
			MsUnlock()
			
			lGravou := .T.
			
		EndIf	

	ElseIf cTblDP =="SA5"
	
		If cTblCad == "SA2"
		
			DbSelectArea("SA5")		
			DbSetOrder(1)
			If DbSeek(xFilial("SA5")+cCodEmit+cLojaEmit+cCodProdP)
			
				if .not. empty( SA5->A5_CODPRF )
	            
		           	U_MyAviso("Aviso","Jแ existe um relacionamento cadastrado para o produto:"+CRLF+cCodProdP+" - "+;
		           	          cDescProdP+CRLF+SA5->A5_CODPRF,{"OK"},3)

		           	lExiste := .T.		//FR - 09/07/2022
		  		else
		  		
					RecLock("SA5",.F.)
					SA5->A5_CODPRF  := cCodProd
					MsUnlock()
					lGravou := .T.

		  		endif

			Else
			
				RecLock("SA5",.T.)
				SA5->A5_FILIAL  := xFilial("SA5")
				SA5->A5_FORNECE := cCodEmit
				SA5->A5_LOJA    := cLojaEmit
				SA5->A5_NOMEFOR := cNomEmit
				SA5->A5_PRODUTO := cCodProdP
				SA5->A5_NOMPROD := cDescProdP
				SA5->A5_CODPRF  := cCodProd
				MsUnlock()
				
				lGravou := .T.
				
			EndIf
			
		EndIf

	ElseIf cTblDP =="SA7"
	
		If cTblCad == "SA1"
		
			DbSelectArea("SA7")		
			DbSetOrder(1)
			If DbSeek(xFilial("SA7")+cCodEmit+cLojaEmit+cCodProdP)

				if .not. empty( SA7->A7_CODCLI )
	
		           	U_MyAviso("Aviso","Jแ existe um relacionamento cadastrado para o produto:"+CRLF+cCodProdP+" - "+;
		           	cDescProdP+CRLF+SA7->A7_CODCLI,{"OK"},3)
	
	           	else
	
					RecLock("SA7",.F.)
					SA7->A7_CODCLI  := cCodProd
					MsUnlock()
					lGravou := .T.

	           	endif

			Else
			
				RecLock("SA7",.T.)
				
				SA7->A7_FILIAL  := xFilial("SA7")
				SA7->A7_CLIENTE := cCodEmit
				SA7->A7_LOJA    := cLojaEmit
				SA7->A7_DESCCLI := cDescProdP //cNomEmit em 31/03/2014
				SA7->A7_PRODUTO := cCodProdP
//				SA7->A7_NOMPROD := cDescProdP
				SA7->A7_CODCLI  := cCodProd
				
				MsUnlock()
				
				lGravou := .T.
				
			EndIf
			
		EndIf
		
	EndIf

EndIf
                          
If lGravou 

	U_MyAviso("Aviso","Relacionamento cadastrado com sucesso!",{"OK"},2)
    //FR - 16/12/2021 - Kitchens
    lAmarrou := .T.

EndIf

//FR - 09/07/2022 - AJUSTE Reuniใo com Rog้rio Lino
If lExiste
	lGravou  := lExiste //para quando retornar a fun็ใo, retornar .T. como sucesso no relacionamento produto
	lAmarrou := lExiste
Endif 
SetKEY( VK_F3 ,  cKeyFe )

oLbx1:Refresh()
oLbx2:Refresh()

RestArea(aArea)

Return(lRet)


Static Function _verSB1(cCodProdP)

Local lRet := .F.

SB1->( dbsetorder( 1 ) )
if SB1->( dbseek( xFilial("SB1")+cCodProdP ) )
   
   lRet := .T.
   
else

   lRet := .F.
   
endif

Return lRet



/*/
`ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPutDePara2บ Autor ณ Eneo               บ Data ณ  14/11/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Inclui de/para de inclusao de pre-nota para todos com mesmoบฑฑ
ฑฑบ          ณ c๓digo interno SB1                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Geral                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function PutDePara2(oLbx1,oLbx2,cTipoNF,cTipoAm,cCnpjEmi,cCodEmit,cLojaEmit,aProdOk,aProdNo)

Local lRet    := .F.           
Local nOpc    := 0   
//Local aDados  := {}                                
Local nTamProd:= TAMSX3("B1_COD")[1]
Local nLinha  := oLbx2:NAT
//Local oItem   := oLbx2:AARRAY[nLinha]
Local cTblCad := Iif(cTipoNF $ "D|B","SA1","SA2")
Local cTblDP  := xZB5
Local lGravou := .F.
Local aArea   := GetArea()
Local cNomeEnt:= "" 
Local cKeyFe  := SetKEY( VK_F3 ,  Nil )
Local cConsSB1:= GetNewPar("XM_PESSB1","N") //Parametro de pesquisa padrao SB1 ou customizada
Local cF3     := ""

Private oDlg

If cTblCad == "SA2"

	cNomEmit := Posicione("SA2",3,xFilial("SA2")+cCnpjEmi,"A2_NOME")
	cNomeEnt := "Fornecedor"
	
Else

	cNomEmit :=  Posicione("SA1",3,xFilial("SA1")+cCnpjEmi,"A1_NOME")
	cNomeEnt := "Cliente"
	
EndIf

cCodProd := oLbx2:AARRAY[nLinha][1]
cDescProd:= oLbx2:AARRAY[nLinha][2]

cCodProdP  := Space(nTamProd)
cAsterisc  := "***"
cAstTodos  := "** TODOS **"
cDescProdP := Space(60)

Private cNcm := iif( Type("oxml:_nfeproc:_nfe:_infnfe:_det:_prod:_ncm:text") <> "U", oxml:_nfeproc:_nfe:_infnfe:_det:_prod:_ncm:text, Criavar("B1_POSIPI") )
Private oCdp

verNcm(,.F.)    //vamos fadigar

DEFINE MSDIALOG oDlg TITLE "Relacionamento De/Para : "+cTblDP FROM 0,0 TO 280,552 OF oDlg PIXEL

@ 06,06 TO 070,271 LABEL "Dados do "+cNomeEnt OF oDlg PIXEL

@ 15,015 SAY   "Codigo" SIZE 45,8 PIXEL OF oDlg       
@ 25,015 MSGET cCodEmit PICTURE "@!" SIZE 30,08 PIXEL OF oDlg WHEN .F.

@ 15,050 SAY "Loja"  SIZE 45,8 PIXEL OF oDlg
@ 25,050 MSGET cLojaEmit PICTURE "@!" SIZE 20,08 PIXEL OF oDlg WHEN .F.

@ 15,075 SAY "CNPJ"   SIZE 45,8 PIXEL OF oDlg
@ 25,075 MSGET cCnpjEmi PICTURE "@ 99.999.999/9999-99" SIZE 50,08 PIXEL OF oDlg WHEN .F.

@ 15,130 SAY   "Nome" SIZE 45,8 PIXEL OF oDlg       
@ 25,130 MSGET cNomEmit PICTURE "@!" SIZE 130,08 PIXEL OF oDlg WHEN .F.

@ 45,015 SAY   "Cod Produto" SIZE 45,8 PIXEL OF oDlg       
@ 55,015 MSGET cAsterisc PICTURE "@!" SIZE 50,08 PIXEL OF oDlg WHEN .F.

@ 45,080 SAY   "Descri็ใo Produto" SIZE 45,8 PIXEL OF oDlg       
@ 55,080 MSGET cAstTodos PICTURE "@!" SIZE 130,08 PIXEL OF oDlg WHEN .F.

@ 045,220 SAY   "NCM" SIZE 45,8 PIXEL OF oDlg       
@ 055,220 MSGET cNCM F3 "SYD" PICTURE "@R 9999.99.99"  SIZE 50,08 PIXEL OF oDlg Valid( verNcm(@oDlg) )//WHEN .F. 

//Verifica se a consulta SB1 serแ padrใo ou customizada
if cConsSB1 == "N"

	cF3 := "HFNCM"
	
else

	cF3 := "SB1"
	
endif

@ 76,06 TO 116,271 LABEL "Produto pr๓prio" OF oDlg PIXEL

@ 085,015 SAY   "Cod Produto" SIZE 45,8 PIXEL OF oDlg       
@ 095,015 MSGET cCodProdP F3 cF3 PICTURE "@!" SIZE 50,08 PIXEL OF oDlg Valid( cDescProdP:=Posicione("SB1",1,xFilial("SB1")+cCodProdP,"B1_DESC") )

//"HFNCM"

@ 085,080 SAY   "Descri็ใo Produto" SIZE 45,8 PIXEL OF oDlg       
@ 095,080 MSGET cDescProdP PICTURE "@!" SIZE 130,08 PIXEL OF oDlg WHEN .F. 
                                                 

@ 125,195 BUTTON "Cancelar" SIZE 35,12 PIXEL OF oDlg Action(nOpc:= 0,oDlg:End())
@ 125,235 BUTTON "Salvar" SIZE 35,12 PIXEL OF  oDlg Action(nOpc:= 1,iif(  _verSB1(cCodProdP),oDlg:End(),U_MyAviso("Aviso","Produto pr๓prio nใo cadastrado",{"OK"},1)) )

ACTIVATE MSDIALOG oDlg CENTERED

If nOpc == 1 .And. !Empty(cCodProdP)

	For nLinha := 1 To Len( oLbx2:AARRAY )
	
		cCodProd := oLbx2:AARRAY[nLinha][1]
		cDescProd:= oLbx2:AARRAY[nLinha][2]
		
		If cTblCad == "SA2"
				
			RecLock(xZB5,.T.)
			
			(xZB5)->(FieldPut(FieldPos(xZB5_+"FILIAL"), xFilial(xZB5)))
			(xZB5)->(FieldPut(FieldPos(xZB5_+"FORNEC"), cCodEmit))
			(xZB5)->(FieldPut(FieldPos(xZB5_+"LOJFOR"), cLojaEmit))
			(xZB5)->(FieldPut(FieldPos(xZB5_+"CGC"),    cCnpjEmi))
			(xZB5)->(FieldPut(FieldPos(xZB5_+"NOME"),   cNomEmit))
			(xZB5)->(FieldPut(FieldPos(xZB5_+"PRODFO"), cCodProd))
			(xZB5)->(FieldPut(FieldPos(xZB5_+"PRODFI"), cCodProdP))
			(xZB5)->(FieldPut(FieldPos(xZB5_+"DESCPR"), cDescProdP))
			(xZB5)->(FieldPut(FieldPos(xZB5_+"CLIENT"), ""))
			(xZB5)->(FieldPut(FieldPos(xZB5_+"CGCC"),   ""))
			(xZB5)->(FieldPut(FieldPos(xZB5_+"NOMEC"),  ""))
			(xZB5)->(FieldPut(FieldPos(xZB5_+"LOJCLI"), ""))		
										
			MsUnlock()
			
			lGravou := .T.
			
		ElseIf cTblCad == "SA1"
		
			RecLock(xZB5,.T.)
			
			(xZB5)->(FieldPut(FieldPos(xZB5_+"FILIAL"), xFilial(xZB5)))
			(xZB5)->(FieldPut(FieldPos(xZB5_+"FORNEC"), ""))
			(xZB5)->(FieldPut(FieldPos(xZB5_+"LOJFOR"), ""))
			(xZB5)->(FieldPut(FieldPos(xZB5_+"CGC"),    ""))
			(xZB5)->(FieldPut(FieldPos(xZB5_+"NOME"),   ""))
			(xZB5)->(FieldPut(FieldPos(xZB5_+"PRODFO"), cCodProd))
			(xZB5)->(FieldPut(FieldPos(xZB5_+"PRODFI"), cCodProdP))
			(xZB5)->(FieldPut(FieldPos(xZB5_+"DESCPR"), cDescProdP))
			(xZB5)->(FieldPut(FieldPos(xZB5_+"CLIENT"), cCodEmit))
			(xZB5)->(FieldPut(FieldPos(xZB5_+"LOJCLI"), cLojaEmit))									
			(xZB5)->(FieldPut(FieldPos(xZB5_+"CGCC"),   cCnpjEmi))
			(xZB5)->(FieldPut(FieldPos(xZB5_+"NOMEC"),  cNomEmit))
			
			MsUnlock()
			
			lGravou := .T.
			
		EndIf
		
		aadd( aProdOk, {cCodProd,cDescProd} )

	Next

EndIf

If lGravou

	aProdNo := {}
	
	aadd(aProdNo,{"- - -","- - - - - - -"} )
	
	oLbx1:SetArray( aProdOk )
	oLbx1:bLine := {|| {aProdOk[oLbx1:nAt,1],;
	     	            aProdOk[oLbx1:nAt,2]}}
	oLbx2:SetArray( aProdNo )
	oLbx2:bLine := {|| {aProdNo[oLbx2:nAt,1],;
	     	            aProdNo[oLbx2:nAt,2]}}
	     	            
	U_MyAviso("Aviso","Relacionamento(s) cadastrado(s) com sucesso!",{"OK"},2)
	
EndIf

SetKEY( VK_F3 ,  cKeyFe )

oLbx1:Refresh()
oLbx2:Refresh()

RestArea(aArea)

Return(lRet)



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณValidPerg1บ Autor ณ Roberto Souza      บ Data ณ  12/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ XML dos Fornecedores                                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Importa Xml                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/ //Evitar a Fadiga
User Function HFValPg1(cPerg)

ValidPerg1(cPerg)

Return


Static Function ValidPerg1(cPerg)

Local aHlpPor1 := {}
Local aHlpPor2 := {}

Aadd( aHlpPor1, "Informe o tipo de Nota fiscal que serใ")
Aadd( aHlpPor1, "gerada a partir do XML.               ")

Aadd( aHlpPor2, "Informe o tipo de amarracao que sera utilizada.")
Aadd( aHlpPor2, "N-Cod Protheus                                 ")
Aadd( aHlpPor2, "B-Amarracao SA5                                ")
Aadd( aHlpPor2, "C-Amarracao "+xZB5+"                                ")
Aadd( aHlpPor2, "D-Amarracao Pedido                             ")

DbSelectArea("SX1")
DbSetOrder(1)
DbGoTop()

cPerg := PADR(cPerg,6)

PutSx1(cPerg,"01","Informe Tipo da Nota ?"  ,"","","MV_CH1","N",1,0,1,"C","","","","","MV_PAR01","N-Normal","N-Normal","N-Normal","","B-Beneficiamento","B-Beneficiamento","B-Beneficiamento","D-Devolucao","D-Devolucao","D-Devolucao","","","","","","",aHlpPor1,aHlpPor1,aHlpPor1)
PutSx1(cPerg,"02","Cod. Produto a Utilizar?","","","MV_CH0","N",1,0,1,"C","","","","","MV_PAR02","N-Cod Protheus","N-Cod Protheus","N-Cod Protheus","","B-Amarracao SA5","B-Amarracao SA5","B-Amarracao SA5","C-Amarracao "+xZB5,"C-Amarracao "+xZB5,"C-Amarracao "+xZB5,"D-Pedido","D-Pedido","D-Pedido","","","",aHlpPor2,aHlpPor2,aHlpPor2)

Return



//Execuar Help On Line, da URL da HF.
User Function HFXMLHLP()

Local cExec		:= '' //'cmd /c "c:\exemplo\pdftotext.exe '+cDir+cArqPdf+'"' //c:\exemplo\000000040.pdf
Local cUrlHlp   := AllTrim( GetNewPar( "XM_URLHLP", "https://helponline.importaxml.com.br/" ) )

cExec    := 'cmd /c start '+cUrlHlp

// Executa o comando para chamar o Help On Line
nRet := WinExec( cExec )

If nRet <> 0

	U_MyAviso("Ajuda","Nใo foi possํvel acessar o Help On Line. Verifique conex๕es de internet",{"OK"},2)

Endif

Return(NIL)


User Function HFSITGFE( cChaveXml, cTip )

Local aArea  := GetArea()
Local cChave := Substr(AllTrim(cChaveXml),1,44)
Local cRet   := " "

Default cTip := "GFE"

if GetNewPar("XM_USAGFE","N") = "S"

	cRet := "1"  //Nใo Encontrado
	
	If cTip == "GFE"
	
		//if Select( "GW3" ) > 0
			DbSelectArea( "GW3" )
		
			if ! DBOrderNickname("CTE")
			
				DbSetOrder( 14 )
				
			endif
			
			if GW3->( dbSeek( cChave ) )
			
				if GW3->GW3_SIT <= "2"
					
					cRet := "2"
					
				else
				
					cRet := GW3_SIT   //era para ser s๓ o 3, mas pensando no futuro fica assim.
				
				endif
				
			endif
			
		//else
		//	Alert( "Select" )
		//endif
		
	Else //Por enquanto nใo tem, mas ja fica meio que pronto
		
		DbSelectArea( xZBZ )
		DbSetOrder( 3 )
		if (xZBZ)->( dbSeek( cChave ) )
		
			cRet := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SITGFE")))
			
		endif		
		
	EndIf
	
endif

RestArea( aArea )

Return( cRet )


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณConsulta Especifica de Produtos Filtrando por NCM - ZZY ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//U_HFPRONCM()
User Function HFPRONCM()   

Local bRet := .F. 

cCodigo := Alltrim(&(ReadVar())) 
 
bRet := FiltraNCM()

//oCdp:Refresh()

Return(bRet) 


//Faz parte da Consulta Filtrando por NCM
Static Function FiltraNCM()

Local cQuery
//Local cDB       := TcGetDB()
//Local oLstSB1 := nil
Local xPesq  := Space(40)
Local aItens := {'C๓digo','Descri็ใo'}
//Local cCombo := ""
Private oGet    := NIL 
Private oLstZZY := nil  
Private oDlgZZY := nil  
Private _bRet := .F.
Private aDadosZZY := {} 
Private nTamCod:= TAMSX3("B1_COD")[1]
Private nTamDes:= TAMSX3("B1_DESC")[1]

//Query Ncm
cQuery := " SELECT B1_FILIAL, B1_COD, B1_DESC, B1_POSIPI "
cQuery += " FROM "+RetSQLName("SB1") + " SB1  "
cQuery += " WHERE B1_FILIAL = '" + xFilial("SB1")+"'"

if !Empty(cNCM) 

	cQuery += " AND B1_POSIPI = '" + cNCM + "'"

endif

cQuery += " AND SB1.D_E_L_E_T_= ' ' "
cQuery += " ORDER BY B1_FILIAL, B1_DESC, B1_COD "

cAlias1:= CriaTrab(Nil,.F.)

DbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),cAlias1, .F., .T.)
     
(cAlias1)->(DbGoTop())     
If (cAlias1)->(Eof())

	DbCloseArea(cAlias1) 
	
	Aviso( "Cadastro de Produtos por Ncm", "Nใo existe dados a consultar", {"Ok"} )
	
	Return .F.

Endif

Do While (cAlias1)->(!Eof())  
   
	aAdd( aDadosZZY, { (cAlias1)->B1_FILIAL, (cAlias1)->B1_COD, (cAlias1)->B1_DESC, (cAlias1)->B1_POSIPI } )  
	
    (cAlias1)->(DbSkip())  
    
Enddo  

DbCloseArea(cAlias1)                                                        

nList := aScan(aDadosZZY, {|x| UPPER(alltrim(x[2])) == UPPER(alltrim(cCodigo)) }) 

iif(nList = 0,nList := 1,nList)

xPesq  := Space(nTamDes)

cCombo1:= aItens[1]

//--Montagem da Tela
Define MsDialog oDlgZZY Title "Busca de Produtos x NCM" From 0,0 To 380, 600 Of oMainWnd Pixel

@ 5,5 SAY OemToAnsi("Pesquisar por:") Of oDlgZZY PIXEL //Pesquisar por:
@ 18,5 SAY OemToAnsi("Localizar") Of oDlgZZY PIXEL //Localizar
oCombo1 := TComboBox():New(02,45,{|u|if(PCount()>0,cCombo1:=u,cCombo1)},;
        aItens,100,20,oDlgZZY,,;
        ,,,,.T.,,,,,,,,,'cCombo1')
//@ 5,45 MSCOMBOBOX oCombo VAR cCombo ITEMS aOrdem SIZE 60,44 OF oDlgZZY PIXEL VALID(HFLCOMB( cCombo, @xPesq ) ) 
//VALID((iif( cCombo = "1", xPesq := Space(nTamCod), xPesq := Space(nTamDes) ),.T. ) .and. IIf(oGet:Refresh()==Nil,.T.,.T.)  )
@ 18,45 GET oGet VAR xPesq Of oDlgZZY PIXEL VALID( HFLPESQ( cValToChar(oCombo1:nat), @xPesq ) )
@ 18,225 BUTTON "Ir"   SIZE 011,11 PIXEL OF oDlgZZY ACTION HFLPESQ( cValToChar(oCombo1:nat), @xPesq )
//VALID ((cAliasTRB)->(MsSeek(Iif(ValType(xPesq)=="C",AllTrim(xPesq),xPesq),.T.)),.T.).And.IIf(oGetDb:oBrowse:Refresh()==Nil,.T.,.T.)

@ 35,5 LISTBOX oLstZZY ;
          VAR lVarMat ;
	      Fields HEADER "Filial", "Cod. Produto", "Desci็ใo", "NCM" ;
          SIZE 295,130 On DblClick ( ConfZZY(oLstZZY:nAt, @aDadosZZY, @_bRet) ) ;
          OF oDlgZZY PIXEL         

oLstZZY:SetArray(aDadosZZY)  
aSort( aDadosZZY, , , { |x,y| UPPER( x[2] ) < UPPER( y[2] ) } ) //Ordena por Codigo
oLstZZY:nAt := nList
oLstZZY:bLine := { || {aDadosZZY[oLstZZY:nAt,1], aDadosZZY[oLstZZY:nAt,2], aDadosZZY[oLstZZY:nAt,3], aDadosZZY[oLstZZY:nAt,4]}}

DEFINE SBUTTON FROM 172,5 TYPE 1 ACTION ConfZZY(oLstZZY:nAt, @aDadosZZY, @_bRet) ENABLE OF oDlgZZY     
DEFINE SBUTTON FROM 172,40 TYPE 2 ACTION oDlgZZY:End() ENABLE OF oDlgZZY

Activate MSDialog oDlgZZY Centered

Return _bRet  


/*Static Function HFLCOMB( cCombo, xPesq )

Local lRet := .T.

if cCombo = "1"

	xPesq := Space(nTamCod)
	
Else

	xPesq := Space(nTamDes)
	
endif

oGet:Refresh()

Return( lRet )*/


//Faz parte da consulta por NCM
Static Function HFLPESQ( cCombo, xPesq )

Local nI := 0
Local nColu := iif(cCombo == "1", 2, 3)

aDadosZZY := aSort( aDadosZZY, , , { |x,y| UPPER( x[nColu] ) < UPPER( y[nColu] ) } ) //Ordena por Codigo
oLstZZY:Refresh()
oDlgZZY:Refresh()

For nI := 1 To Len(aDadosZZY)  //Len( alltrim(xPesq) )

	if UPPER( alltrim(xPesq) ) $ UPPER( AllTrim( aDadosZZY[nI][nColu] ) )
		
		oLstZZY:nAt := nI
		Exit
		
	else
	
		if UPPER(AllTrim(aDadosZZY[nI][nColu])) > UPPER( alltrim(xPesq) )
		
			oLstZZY:nAt := nI
			Exit
			
		elseif nI ==  Len(aDadosZZY)
		
			oLstZZY:nAt := nI
			
		endif
		
	endif
	
	//cPesq := Substr(xPesq,1,nI)
	//nList := aScan( aDadosZZY, {|x| UPPER(x[nColu]) = UPPER(cPesq) } )
	//if nList > 0
	//	oLstZZY:nAt := nList
	//Else
	//	Exit
	//endif
	
Next nI

oLstZZY:Refresh()
oDlgZZY:Refresh()

Return( .T. )


//Faz parte da consulta por NCM
Static Function ConfZZY(_nPos, aDadosZZY, _bRet)   

cCodigo := aDadosZZY[_nPos,2]   

cCodProdP := cCodigo    

aCpoRet := cCodigo    //Nใo esquecer de alimentar essa variแvel quando for f3 pois ela e o retorno e se estiver com valor diferente complica.

_bRet := .T.  

oDlgZZY:End() 
     
Return


User Function HFRETPNC()
Return( cCodigo )


Static Function __Dummy(lRecursa) //warning W0010 Static Function <?> never called
    
    lRecursa := .F.
    
    IF (lRecursa)
    
        __Dummy(.F.)
        U_HFITNENC()
        U_HFValPg1()
        U_HFXMLHLP()
        U_HFSITGFE()
        
	EndIF
	
Return(lRecursa)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHFXSEMA   บAutor  ณMicrosiga           บ Data ณ  02/08/22   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Controle de Quantidade de COnsultas por Chave/Cnpj         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Importa Xml                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function HFXSEMA()

	Local nQtdCons := 0
	Local lRetSem := .f.
	Local nTempo     := GetNewPar("XM_NHRSEF",60)
	Local nReqSefaz  := GetNewPar("XM_NCNPJSE", 20)
	//Local cEmpresa 		:= cEmpAnt
	//Local cFilial		:= cFilAnt
	//Local dData			:= SubStr(DTOS(dDataBase),7,2)+SubStr(DTOS(dDataBase),5,2)+SubStr(DTOS(dDataBase),1,4)
	Local cHora := cOldHr := Time()
	Local xZBF  	 := GetNewPar("XM_TABCON" ,"ZBF")
	Local xZBF_      := iif(Substr(xZBF,1,1)=="S", Substr(xZBF,2,2), Substr(xZBF,1,3)) + "_"
	Local cQUERY := ""

	//IncTime([<cTime>],<nIncHours>,<nIncMinuts>,<nIncSeconds> ) -> Somar
	//DecTime<cTime>],<nDecHours>,<nDecMinuts>,<nDecSeconds> ) -> Subtrair

	cOldHr := DecTime(cHora,0,nTempo,0 )

	/*
	//cQUERY := " SELECT TOP(1) ZBF."+xZBF_+"NUMCON,ZBF."+xZBF_+"DATA,ZBF."+xZBF_+"HORA"
	cQUERY := " SELECT ZBF."+xZBF_+"NUMCON,ZBF."+xZBF_+"DATA,ZBF."+xZBF_+"HORA"
	cQUERY += " FROM " + RetSqlName(xZBF)+ " ZBF "
	cQUERY += " WHERE ZBF.D_E_L_E_T_ <> '*' "
	cQuery += " AND ZBF."+xZBF_+"CHAVE   ='"+cChave+"' "
	cQUERY += " ORDER BY ZBF."+xZBF_+"NUMCON DESC "
	cQuery := ChangeQuery( cQuery )
	*/

	cQUERY := " SELECT COUNT(*) QTDEVENT "
	cQUERY += " FROM " + RetSqlName(xZBF)+ " ZBF "
	cQUERY += " WHERE ZBF.D_E_L_E_T_ <> '*' "
	cQUERY += " AND ZBF."+xZBF_+"HORA >='"+cOldHr+"' "
	cQUERY += " AND ZBF."+xZBF_+"DATA = '"+DTOS(dDataBase)+"' "

	cQuery := ChangeQuery( cQuery )

	If Select("QRYSEMA") > 0
		QRYSEMA->(dbCloseArea())
	EndIf
	TCQUERY cQUERY NEW ALIAS "QRYSEMA"

	dbSelectArea("QRYSEMA")
	QRYSEMA->(dbGoTop())

	if QRYSEMA->(!EOF())
		nQtdCons := QRYSEMA->QTDEVENT
	ELSE
		nQtdCons := 0
	ENDIF


	//TRATATIVAS DE MENSAGEM
	ConOut( "Quantidade de consultas realizadas: "+cValToChar(nQtdCons)+" em minutos: "+cValToChar(nTempo) )
	//MsgAlert( "Quantidade de consultas realizadas: "+cValToChar(nQtdCons)+" em minutos: "+cValToChar(nTempo) )
	If nQtdCons >= nReqSefaz

		lRetSem := .F.

		If !IsBlind()
			MsgInfo( "Nใo ้ possํvel realizar a consulta devido o limite de "+cValToChar(nReqSefaz)+" consultas no perํodo de "+cValToChar(nTempo)+" minutos.", "Controle de Requisi็ใo" )//+ cChave
		Else
			ConOut( "Nใo ้ possํvel realizar a consulta devido o limite de consultas no perํodo de "+cValToChar(nTempo)+" minutos.", "Controle de Requisi็ใo" )
		Endif

	ELSE

		lRetSem := .T.

	ENDIF


RETURN(lRetSem)


User Function HFXGRSEMA(cNomFun,cChaveXml)

	Local xZBF  := GetNewPar("XM_TABCON" ,"ZBF")
	Local xZBF_ := iif(Substr(xZBF,1,1)=="S", Substr(xZBF,2,2), Substr(xZBF,1,3)) + "_"
	Local cHora := Time()

	dbSelectArea(xZBF)
	dbSetOrder(1)

	//	If (xZBF)->( DbSeek(xFilial(xZBF)+cChaveCons+ cValToChar(nNumCon) ))

	Reclock(xZBF, .T.)
	(xZBF)->(FieldPut(FieldPos(xZBF_+"FILIAL") , XFILIAL(xZBF) ))
	(xZBF)->(FieldPut(FieldPos(xZBF_+"DATA") , dDataBase ))
	(xZBF)->(FieldPut(FieldPos(xZBF_+"HORA") , cHora ))
	(xZBF)->(FieldPut(FieldPos(xZBF_+"ROTINA") , cNomFun ))
	(xZBF)->(FieldPut(FieldPos(xZBF_+"CHAVE") , cChaveXml ))
	MsUnlock()
	//lAlt := .T.

	//	EndIf

RETURN
