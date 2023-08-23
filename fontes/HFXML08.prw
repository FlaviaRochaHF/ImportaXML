#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"                 
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "TOPCONN.CH"


//Static Function MenuDef()
//Return StaticCall(MATXATU,MENUDEF)

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ HFXML08  ∫ Autor ≥ Eneovaldo Roveri Jr∫ Data ≥  12/11/14   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Cadastro de Fornecedor Carregando Campos do XML.           ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ IMPORTA XML                                                ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
//------------------------------------------------------------------------------//
//FR - 28/10/2021 - ImplementaÁ„o cadastro fornecedor (SA2) automatizado (Daikin)
//                  Par‚metro: "XM_SA2AUTO" Tipo Caracter, conte˙do : S-Sim; N=N„o
/*
//Escopo passado por Rafael Lobitsky - 28/10/2021:
Criar um par‚metro chamado : Fornecedor auto S=sim;N=n„o - "XM_SA2AUTO"
-> Help ì Informa se ao baixar o xml e n„o encontrar o fornecedor cadastrado , 
   efetua o cadastro do mesmo de forma robÛtica ì
   
-> Incluir este par‚metro em nossa aba de cadastros gerais ou gerais2

-> Incluir este par‚metro no programa de instalador do GEST√O XML para ao rodar 
   o compatibilizador ser· criado autom·tico 
   
-> Utilizar nosso ponto de entrada do gest„o XML para colocar a regra de criaÁ„o 
   de cÛdigo do fornecedor padr„o Daikin no momento de ser criado de forma robotica
   (se usa montagem de de A2_COD modelo Daikin ou padr„o SXENUM )
*/
//------------------------------------------------------------------------------//
//FR - 07/12/2021 - Projeto Kitchens - Solicitado por Rafael Lobitsky
//                  Inclus„o de rotina para geraÁ„o de pedido compra
//-------------------------------------------------------------------------//
//FR - 10/01/2022 - PETRA - para trazer o campo A2_CGC aberto somente modo inclus„o
//------------------------------------------------------------------------------//
//FR - 10/02/2022 - RAFAEL LOBITSKY - TÛpicos solicitados:
//                  Quando acionada a api que traz as informaÁıes do fornecedor:
//					Gravar no campo memo (ZBZ_OBS):
//                  - a url da Sefaz;
//                  - a situaÁ„o do fornecedor (ATIVA OU INATIVA)
//------------------------------------------------------------------------------//
//FR - 15/03 - ALTERA«√O - adequaÁ„o da carga de informaÁıes quando È NF serviÁo
//------------------------------------------------------------------------------//
//FR - 25/04/2022 - AlteraÁ„o - Grupo Tribuna #12599 - passar pelo 
//pto entrada U_MA020TOK
//------------------------------------------------------------------------------//
User Function HFXML08()

Local lRet     := .T.
Local aArea    := GetArea()
Local cError   := ""
Local cWarning := ""
Local cFilSeek := ""

//Private lSharedA2:= U_IsShared("SA2")
Private oXml, cTag, cCpo, xTag

If GetNewPar("XM_USACFOR","S") == "N"  //Para Capricornio
	U_MyAviso("ATEN«√O","Cadastro Fornecedor N„o Habilitado, Verifique Par‚metro XM_USACFOR",{"OK"},3)
	RestArea( aArea )
	Return( .F. )
EndIf

If (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC"))) $ "D|B"
	U_MyAviso("TIPO "+iif((xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC")))=="D","DEVOLU«¬O","BENEFICIAMENTO"),"Tipo do Documento utiliza Cliente",{"OK"},3)
	RestArea( aArea )
	Return( .F. )
EndIF
/*
If (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO"))) $ "RP"
	U_MyAviso("NFSE","Modelo de NFSe, n„o contÈm dados do fornecedor. Favor fazer o cadastro manualmente.",{"OK"},3)
	RestArea( aArea )
	Return( .F. )
EndIF
*/

cFilSeek := xFilial("SA2")   // Iif(lSharedA2,xFilial("SA2"),(xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))) )

DbSelectArea("SA2")
DbSetOrder(3)

If DbSeek( cFilSeek+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))) )

	Do While .not. SA2->( eof() ) .and. SA2->A2_FILIAL == cFilSeek .and.;
	               SA2->A2_CGC == (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ")))
	               
		if SA2->A2_MSBLQL != "1"
			lRet := .F.
			exit
		endif
		
		SA2->( dbSkip() )
		
	EndDo
	
EndIf	

DbSelectArea( xZBZ )

if .Not. lRet

	if ((xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR"))) <> SA2->A2_COD .or.;
	    (xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR"))) <> SA2->A2_LOJA ) .And. (xZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF"))) == "B"
		
		RecLock(xZBZ,.F.)
		
		(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CODFOR"), SA2->A2_COD ))
		(xZBZ)->(FieldPut(FieldPos(xZBZ_+"LOJFOR"), SA2->A2_LOJA))
		(xZBZ)->(FieldPut(FieldPos(xZBZ_+"FORNEC"), SA2->A2_NOME))
		(xZBZ)->(FieldPut(FieldPos(xZBZ_+"INDRUR"), SA2->A2_INDRUR))
		(xZBZ)->(DbCommit())
		(xZBZ)->(MsUnlock())
		
	EndIf
	
	U_MyAviso("ATEN«√O","Fornecedor J· Cadastrado",{"OK"},3)
	
	RestArea( aArea )
	
	Return( .F. )
	
EndIf

cXml := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML")))
//cXml := EncodeUTF8(cXml)

//Faz backup do xml sem retirar os caracteres especiais
//cBkpXml := cXml

//Executa rotina para retirar os caracteres especiais
//cXml := u_zCarEspec( cXml )

oXml := XmlParser( cXml, "_", @cError, @cWarning )

//retorna o backup do xml
//cXml := cBkpXml

If oXml == NIL .Or. !Empty(cError) //.Or. !Empty(cWarning)

	cError := ""
	cWarning := ""

	cXml := NoAcento((xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML"))))
	cXml := EncodeUTF8(cXml)

	//Faz backup do xml sem retirar os caracteres especiais
	cBkpXml := cXml

	//Executa rotina para retirar os caracteres especiais
	cXml := u_zCarEspec( cXml )

	oXml := U_PARSGDE( cXml, @cError, @cWarning )

	//retorna o backup do xml
	cXml := cBkpXml

Endif

If oXml == NIL .Or. !Empty(cError) //.Or. !Empty(cWarning)

	if empty(cError)
		cError := "XML Importado com erro. Verifique os dados importados e refaÁa a importaÁ„o."
	endif

	U_MyAviso("Xml com caracter n„o suportado",cError,{"OK"},3)

	RestArea( aArea )

	Return( .F. )

EndIf

lRet := U_HFXML08I()

RestArea( aArea )

Return( lRet )


/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ HFXML08I ∫ Autor ≥ Eneovaldo Roveri Jr∫ Data ≥  12/11/14   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ FunÁ„o de Inclus„o de Fornecedor.                          ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ IMPORTA XML                                                ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
User Function HFXML08I(aRotAuto,nOpcAuto)

Local nOpcA     := 0
Local aParam    := {{|| .T.},{|| .T.},{|| .T.},{|| .T.}}
Local cQuery    := ""
Local cAliasZBZ := GetNextAlias() 
Local xOpc      := Nil		//FR - 10/01/2022 - PETRA

Private lIntLox    := GetMV("MV_QALOGIX") == "1" 

INCLUI			   := .T.

//nOpcA := AxInclui("SA2",1,Nil,/*aAcho*/,"U_HFXML08D",/*aCpos*/,"A020TudoOk()",.T.,/*cTransact*/,/*aButtons*/,;
//		          aParam,/*aAuto*/,/*lVirtual*/,/*lMaximized*/,/*cTela*/,/*lPanelFin*/,/*oFather*/,/*aDim*/,/*uArea*/)

//FR - 10/01/2022 - PETRA - para trazer o campo A2_CGC aberto somente modo inclus„o
nOpcA := 0

//FR - 25/04/2022 - AlteraÁ„o - Grupo Tribuna #12599 - passar pelo pto entrada U_MA020TOK
//Se n„o houver o pto entrada MA020TOK:
If !ExistBlock( "MA020TOK" )
	nOpcA := AxInclui("SA2",1,xOpc,/*aAcho*/,"U_HFXML08D",/*aCpos*/,"A020TudoOk()",.T.,/*cTransact*/,/*aButtons*/,;
		          aParam,/*aAuto*/,/*lVirtual*/,/*lMaximized*/,/*cTela*/,/*lPanelFin*/,/*oFather*/,/*aDim*/,/*uArea*/)
		          //NO SX3 - X3_WHEN DO CAMPO A2_CGC NA PETRA TEM Q FICAR ASSIM =>  INCLUI .and. ISINCALLSTACK("U_HFXML08I")

//se houver o pto entrada MA020TOK:  
Else	
	nOpcA := AxInclui("SA2",1,xOpc,/*aAcho*/,"U_HFXML08D",/*aCpos*/,"A020TudoOk() .AND. U_MA020TOK()",.T.,/*cTransact*/,/*aButtons*/,;
		          aParam,/*aAuto*/,/*lVirtual*/,/*lMaximized*/,/*cTela*/,/*lPanelFin*/,/*oFather*/,/*aDim*/,/*uArea*/)
                  		         		          
Endif 
//FR - 25/04/2022 - AlteraÁ„o - Grupo Tribuna #12599 - passar pelo pto entrada U_MA020TOK

If nOpcA == 1
   
	If ExistBlock("M020INC")
		ExecBlock("M020INC",.F.,.F.)
	EndIf	

	cQuery := " SELECT ZBZ.R_E_C_N_O_ AS RECNO FROM " + RETSQLNAME( xZBZ_) + " ZBZ "
	cQuery += " WHERE " + xZBZ_+"CNPJ = '" + SA2->A2_CGC + "' AND " + xZBZ_+"CODFOR = '' "
	cQuery += " ORDER BY RECNO "
	
	cQuery := ChangeQuery( cQuery ) 
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasZBZ,.T.,.T.)
	
	While (cAliasZBZ)->( ! Eof() )
	
		if nOpcA == 1
		
			DbGoto( ( cAliasZBZ )->RECNO )
		
			RecLock(xZBZ,.F.)
			
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CODFOR"), SA2->A2_COD ))
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"LOJFOR"), SA2->A2_LOJA))
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"FORNEC"), SA2->A2_NOME))
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"INDRUR"), SA2->A2_INDRUR))
			
			(xZBZ)->(MsUnlock())
			
		EndIf
		
		(cAliasZBZ)->( DbSkip() )
		
	End
	
	(cAliasZBZ)->( DbCloseArea() )
	
	//=========================================================================//
	//AVISO DE NOVO CADASTRO ROB”TICO - SA2
	//Autoria: Fl·via Rocha - Solicitado por Rafael Lobitsky para Kitchens
	//=========================================================================//
	//chama a rotina que envia o email para o XM_MAIL09 - quem recebe notificaÁ„o de novo cadastro
	U_FNEWCAD("SA2", SA2->A2_COD + "/" + SA2->A2_LOJA + " - " + SA2->A2_NOME)
	
Endif

Return(nOpcA)
	






/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ HFXML08D ∫ Autor ≥ Eneovaldo Roveri Jr∫ Data ≥  12/11/14   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Carregar vari·veis com campos das TAGs do XML <Emitente>   ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ IMPORTA XML                                                ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
User Function HFXML08D(lAuto,cCodSa2,cLojSa2,cCnpjEmi,xRECZBZ)		

Local cCpoLoja	    := ""
Local lBELLKEY      := AllTrim(GetSrvProfString("BELLKEY","0"))=="1"
Local lXml          := .F.

// variaveis da api
Local cUrl			:= 'http://www.receitaws.com.br/v1/cnpj/'
Local cGetParams	:= ''
Local nTimeOut		:= 240
Local aHeaderStr	:= {'Content-Type: application/json'}
Local cHeaderGet	:= ''
Local cReturn		:= ''
Local oObjJson		:= nil
Local cCnpj			:= ""     
//Local cXMLExp       := ""
//Local cPNfCpl       := GetNewPar("XM_PNFCPL","1")
//Local oXmlMod
Local cError        := ""
Local cWarning      := ""
Local cInscr		:= ""
Local cCnae			:= ""
Local cInscrm		:= ""
Local cA2nrend		:= ""
Local cRazao		:= ""
Local cNReduz		:= ""
Local cLogr			:= ""
Local cCep			:= ""
Local cMunicip		:= ""
Local cUF			:= ""
Local cFone			:= ""
Local cBairro		:= ""
Local cCompl		:= ""
Local cDDD			:= ""
Local cCodMunic		:= ""
Local cEmail		:= ""

Local lContinua		:= .F.							//FR - 28/10/2021
Local lXMLPEFORN    := ExistBlock( "XMLPEFORN" )  	//FR - 28/10/2021
Local aRet			:= {}
Local cCondSA2      := ""
Local oXml						//FR - 15/12/2021
Local cZBZObs		:= ""		//FR - 10/02/2022 - grava a observaÁ„o ZBZ_OBS - SolicitaÁıes de Rafael Lobitsky relativas a consulta fornecedor via api da Sefaz
Local cSituacao     := ""		//FR - 10/02/2022 - capta a situaÁ„o do fornecedor no objeto Json vindo da api - SolicitaÁıes de Rafael Lobitsky relativas a consulta fornecedor via api da Sefaz
//Local aExecAuto     := {}		//FR - 13/04/2022 - KITCHENS cad. autom·tico fornecedor
//Local lSA2			:= .F.		//FR - 18/04/2022 - KITCHENS cad. autom·tico fornecedor
Local lXMLPECPOSA2  := ExistBlock("XMLPECPOSA2")  //FR - 25/04/2022 - PTO entrada para adicionar campos na lista de inclus„o de fornecedor
Local aCposCli      := {}       //FR - 25/04/2022 - receber· o array de campos do cliente que deseja que grave no cad. autom·tico de fornecedor
Local x             := 0

Default lAuto		:= .F.		//FR - 28/10/2021

If !lAuto
	//FR - 10/02/2022 - alteraÁ„o - inserido aqui a chamada que captura o cnpj do XML:
	cCnpj			:= allTrim((xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ")))) // o campo tambÈm tem que ser dinamico (xZBZ)->ZBZ_CNPJ
	//FR - 10/02/2022 - alteraÁ„o - inserido aqui a chamada que captura o cnpj do XML:

	//If MsgYesNo('Carregar informaÁıes de forma automatica?','API-CNPJ '+iiF((xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO")))=="RP",'[NFS-e]','[CT-eOS]'))
	If MsgYesNo('Carregar informaÁıes de forma automatica?','API-CNPJ '+iiF((xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO")))=="RP",'[NFS-e]','[CT-eOS]'))
		lContinua := .T.
	Endif
	
	xRECZBZ := (xZBZ)->(Recno())	//FR - 28/10/2021
	
	oXml := XmlParser((xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML"))), "_", @cError, @cWarning )
	
Else
	lContinua := .T.
	cCnpj     := cCnpjEmi
	cCondSA2  := GetNewPar("XM_ZBCCOND" , Space(3))	
Endif 
//FR - 28/10/2021

If lContinua
	
	cUrl	:= AllTrim(cUrl)+cCnpj		//ex.: http://www.receitaws.com.br/v1/cnpj/00611522000120
	cReturn	:= HttpGet( cUrl , cGetParams , nTimeOut , aHeaderStr, @cHeaderGet )
	
	If .not. FWJsonDeserialize(cReturn,@oObjJson)
		//FR - 15/03 - ALTERA«√O - adequaÁ„o da carga de informaÁıes quando È NF serviÁo
		// chamada da api para notas de servico
		//If (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO"))) $ "RP,67"
				//If !lAuto		
				//	MsgStop('Ops...Ocorreu erro na consulta') //retirada esta mensagem estava indevida
				//Endif
				//return ( .F. )
		
		//Else 
		//FR - 15/03 - ALTERA«√O - adequaÁ„o da carga de informaÁıes quando È NF serviÁo
		//qdo ocorre erro na api, ir· pegar ent„o do objeto XML (ZBZ_XML):
			lXml := .T.
			oXml := XmlParser((xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML"))), "_", @cError, @cWarning )
			//oObjJson:SITUACAO (conte˙do: "ATIVA"), oObjJson:DATA_SITUACAO (conte˙do: vazio, tipo caracter) , oObjJson:MOTIVO_SITUACAO , oObjJson:NATUREZA_JURIDICA
	Endif
	
	if ! lXml
	
		if oObjJson:STATUS = "ERROR"
			If (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO"))) $ "RP,67"
				MsgStop(oObjJson:MESSAGE)
				return( .F. )
			Else
				lXml := .T.
				oXml := XmlParser((xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML"))), "_", @cError, @cWarning )
			Endif
		endif
			
	Endif
	
	If (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO"))) == "57"
		xTag := "CTE"
	Else
		xTag := "NFE"
	EndIf
	
	//FR - 15/03 - ALTERA«√O - adequaÁ„o da carga de informaÁıes quando È NF serviÁo
	If (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO"))) <> "RP"
	
		oXml := XmlParser((xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML"))), "_", @cError, @cWarning )
		
		cTag := "oXml:_"+xTAG+"PROC:_"+xTAG+":_INF"+xTAG+":_EMIT:_IE:TEXT" 
		
		If oXml <> Nil
			if Type(cTag) <> "U" 
				cCpo := &cTag
				M->A2_INSCR := cCpo
				cInscr      := cCpo
			endif
		
			
			cTag := "oXml:_"+xTAG+"PROC:_"+xTAG+":_INF"+xTAG+":_EMIT:_CNAE:TEXT"
			//if Type(cTag) <> "U" 
			//if ValType(cTag) <> "U"
			//If Valtype(XmlChildEx(oObject:_CTEPROC:_CTE:_INFCTE,"_INFCTECOMP")) <> "U"    //Complemento
			//If Valtype( &(cTag)) <> "U"    //Complemento
			//If XmlChildEx(oDet[i]:_Prod,"_Rastro") <> nil   //Complemento
			If XmlChildEx( &("oXml:_"+xTAG+"PROC:_"+xTAG+":_INF"+xTAG+":_EMIT") , "_CNAE" ) <> NIL
				cCpo := &cTag
				M->A2_CNAE := cCpo
				cCnae      := cCpo
			endif
			
			cTag := "oXml:_"+xTAG+"PROC:_"+xTAG+":_INF"+xTAG+":_EMIT:_IM:TEXT"
			//if Type(cTag) <> "U" 
			If XmlChildEx( &("oXml:_"+xTAG+"PROC:_"+xTAG+":_INF"+xTAG+":_EMIT") , "_IM" ) <> NIL
				cCpo := &cTag
				M->A2_INSCRM := cCpo
				cInscrm      := cCpo
			endif
			
			cTag := "oXml:_"+xTAG+"PROC:_"+xTAG+":_INF"+xTAG+":_EMIT:_ENDEREMIT:_NRO:TEXT"
			//if Type(cTag) <> "U" 
			If XmlChildEx( &("oXml:_"+xTAG+"PROC:_"+xTAG+":_INF"+xTAG+":_EMIT:_ENDEREMIT") , "_NRO" ) <> NIL
				cCpo := &cTag
				M->A2_NR_END := cCpo 
				cA2nrend     := cCpo
			endif
			
			//FR - DAIKIN - 28/10/2021
			//CNPJ
			/*
			cTag := "oXml:_"+xTAG+"PROC:_"+xTAG+":_INF"+xTAG+":_EMIT:_CNPJ:TEXT"
			if Type(cTag) <> "U"
				cCpo := &cTag		
				cCnpj:= cCpo
			endif 
			*/
			
			//RAZAO SOCIAL
			cTag := "oXml:_"+xTAG+"PROC:_"+xTAG+":_INF"+xTAG+":_EMIT:_XNOME:TEXT"
			//if Type(cTag) <> "U" 
			If XmlChildEx( &("oXml:_"+xTAG+"PROC:_"+xTAG+":_INF"+xTAG+":_EMIT") , "_XNOME" ) <> NIL
				cCpo := &cTag		
				cRazao:= cCpo
			endif
			
			//NOME FANTASIA
			cTag := "oXml:_"+xTAG+"PROC:_"+xTAG+":_INF"+xTAG+":_EMIT:_XFANT:TEXT"
			//if Type(cTag) <> "U" 
			If XmlChildEx( &("oXml:_"+xTAG+"PROC:_"+xTAG+":_INF"+xTAG+":_EMIT") , "_XFANT" ) <> NIL
				cCpo := &cTag		
				cNReduz:= cCpo
			endif  
			 
			//ENDERE«O (RUA)
			cTag := "oXml:_"+xTAG+"PROC:_"+xTAG+":_INF"+xTAG+":_EMIT:_ENDEREMIT:_XLGR:TEXT"
			//if Type(cTag) <> "U" 
			If XmlChildEx( &("oXml:_"+xTAG+"PROC:_"+xTAG+":_INF"+xTAG+":_EMIT:_ENDEREMIT") , "_XLGR" ) <> NIL
				cCpo := &cTag	 
				cLogr:= cCpo + "," + cA2nrend
			endif   
			
			//CEP
			cTag := "oXml:_"+xTAG+"PROC:_"+xTAG+":_INF"+xTAG+":_EMIT:_ENDEREMIT:_CEP:TEXT"
			//if Type(cTag) <> "U" 
			If XmlChildEx( &("oXml:_"+xTAG+"PROC:_"+xTAG+":_INF"+xTAG+":_EMIT:_ENDEREMIT") , "_CEP" ) <> NIL
				cCpo := &cTag	
				cCep := cCpo
			endif 
			
			//BAIRRO
			cTag := "oXml:_"+xTAG+"PROC:_"+xTAG+":_INF"+xTAG+":_EMIT:_ENDEREMIT:_XBAIRRO:TEXT"
			//if Type(cTag) <> "U" 
			If XmlChildEx( &("oXml:_"+xTAG+"PROC:_"+xTAG+":_INF"+xTAG+":_EMIT:_ENDEREMIT") , "_XBAIRRO" ) <> NIL
				cCpo    := &cTag	
				cBairro := cCpo
			endif   
			
			//COMPLEMENTO
			cTag := "oXml:_"+xTAG+"PROC:_"+xTAG+":_INF"+xTAG+":_EMIT:_ENDEREMIT:_XCPL:TEXT"
			//if Type(cTag) <> "U" 
			If XmlChildEx( &("oXml:_"+xTAG+"PROC:_"+xTAG+":_INF"+xTAG+":_EMIT:_ENDEREMIT") , "_XCPL" ) <> NIL
				cCpo    := &cTag	
				cCompl  := cCpo
			endif
			
			//MUNICÕPIO
			cTag := "oXml:_"+xTAG+"PROC:_"+xTAG+":_INF"+xTAG+":_EMIT:_ENDEREMIT:_XMUN:TEXT"
			//if Type(cTag) <> "U" 
			If XmlChildEx( &("oXml:_"+xTAG+"PROC:_"+xTAG+":_INF"+xTAG+":_EMIT:_ENDEREMIT") , "_XMUN" ) <> NIL
				cCpo     := &cTag	
				cMunicip := cCpo
			endif 
			
			//CODIGO MUNICÕPIO
			cTag := "oXml:_"+xTAG+"PROC:_"+xTAG+":_INF"+xTAG+":_EMIT:_ENDEREMIT:_CMUN:TEXT"
			//if Type(cTag) <> "U" 
			If XmlChildEx( &("oXml:_"+xTAG+"PROC:_"+xTAG+":_INF"+xTAG+":_EMIT:_ENDEREMIT") , "_CMUN" ) <> NIL
				cCpo     := &cTag	
				cCodMunic:= Substr(cCpo,3,5)
			endif 	  
			
			//UF
			cTag := "oXml:_"+xTAG+"PROC:_"+xTAG+":_INF"+xTAG+":_EMIT:_ENDEREMIT:_UF:TEXT"
			if ValType(cTag) <> "U" 
				cCpo := &cTag	
				cUF := cCpo
			endif
			
			//TELEFONE
			cTag := "oXml:_"+xTAG+"PROC:_"+xTAG+":_INF"+xTAG+":_EMIT:_ENDEREMIT:_FONE:TEXT"
			//if Type(cTag) <> "U" 
			If XmlChildEx( &("oXml:_"+xTAG+"PROC:_"+xTAG+":_INF"+xTAG+":_EMIT:_ENDEREMIT") , "_FONE" ) <> NIL
				cCpo := &cTag	
				cFone:= cCpo
				cDDD := substr(cFone+space(2),1,2)
			endif
			
		Endif  //oXml <> Nil
		
	Endif 
	//FR - 15/03 - ALTERA«√O - adequaÁ„o da carga de informaÁıes quando È NF serviÁo
	
	cEmail := ""
	
	//FR - DAIKIN - 28/10/2021
	
	if ! lXml
	
		If lXMLPEFORN
			//cCnpjEmi:= allTrim((xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ")))) // o campo tambÈm tem que ser dinamico (xZBZ)->ZBZ_CNPJ
			cRazao  := ""
			cCodSA2 := ""
			cLojSA2 := ""
			aRet    := ExecBlock( "XMLPEFORN", .F., .F., { cCnpj,cRazao,cCodSA2,cLojSA2 } )
			cCodSA2 := aRet[3]
			cLojSA2 := aRet[4]				 
			M->A2_COD		:= cCodSA2
			M->A2_LOJA		:= cLojSA2
		Endif
		M->A2_NOME		:= oObjJson:nome		
		M->A2_NREDUZ	:= oObjJson:nome		
		M->A2_EST		:= oObjJson:uf		
		M->A2_END		:= oObjJson:logradouro+','+space(1)+oObjJson:numero		
		M->A2_MUN		:= oObjJson:municipio		
		M->A2_TIPO		:= 'J'						
		M->A2_CGC		:= cCnpj		
		xCep			:= Strtran(oObjJson:cep,',','')
		xCep			:= Strtran(oObjJson:cep,'.','')
		xCep			:= Strtran(xCep,'-','') 		
		M->A2_CEP		:= xCep		
		M->A2_BAIRRO	:= oObjJson:bairro  		
		M->A2_ENDCOMP	:= oObjJson:complemento
				
		xTelefone		:= Strtran(oObjJson:telefone,'(','')
		xTelefone		:= Strtran(xTelefone,')','')
		xTelefone		:= Strtran(xTelefone,'-','')
		xTelefone		:= allTrim(xTelefone)		
		M->A2_DDD		:= substr(xTelefone+space(2),1,2)		
		M->A2_TEL		:= substr(xTelefone+space(8),3,9)
		
		//pega o cÛdigo do municÌpio pela ordem 4 : CC2_FILIAL + CC2_EST + CC2_MUN 
		//pois pode haver duas cidades com mesmo nome em estados diferentes
		M->A2_COD_MUN	:= posicione('CC2',4,FWxFilial('CC2')+ Alltrim(oObjJson:uf) + allTrim(oObjJson:municipio),'CC2_CODMUN')	
					
		if !Empty(oObjJson:email)
			M->A2_EMAIL := oObjJson:email
		else
			M->A2_EMAIL := Criavar("A2_EMAIL")    
		endif
			
		M->A2_PAIS		:= '105'		
		M->A2_CODPAIS	:= '01058' 
				
		//FR - DAIKIN
		cRazao       := oObjJson:nome
		cNReduz      := oObjJson:nome	
		cLogr        := oObjJson:logradouro+','+space(1)+oObjJson:numero 
		cMunicip     := oObjJson:municipio
		cTipo        := "J"
		cCep         := xCep 
		cBairro      := oObjJson:bairro  
		cCompl       := oObjJson:complemento
		cDDD         := substr(xTelefone+space(2),1,2) 
		cCodMunic  	 := posicione('CC2',4,FWxFilial('CC2')+ Alltrim(oObjJson:uf) + allTrim(oObjJson:municipio),'CC2_CODMUN')						
		cEmail	     := oObjJson:email
		//FR - DAIKIN
		 
			
	endif
	
	
	If !lAuto
		
		If ExistBlock("UNIFORN")
			ExecBlock("UNIFORN",.F.,.F.)
		EndIf
			
	//FR- 28/10/2021	
	Else  //lAuto = .T. È qdo chamada autom·tica ou pela rotina de download XML, ou pela rotina de classificaÁ„o nf combustÌveis (Daikin) ou pela rotina Gera pedido compra (Kitchens)
			
		//verifica se foi passado o cÛdigo/loja do fornecedor ou vai montar agora
		If Empty(cCodSA2) .and. Empty(cLojSA2 )
			
			If lXMLPEFORN
				aRet := ExecBlock( "XMLPEFORN", .F., .F., { cCnpjEmi,cRazao,cCodSA2,cLojSA2 } )
				cCodSA2 := aRet[3]
				cLojSA2 := aRet[4]				 
			Endif
				 
		Endif
		
		If lXMLPECPOSA2
			aCposCli := ExecBlock( "XMLPECPOSA2" )
			//aadd( _aRet , { _cCpo   , Alltrim(SX3->X3_TITULO) , SX3->X3_TIPO, Alltrim(SX3->X3_RELACAO) } )		
		Endif 		
			 
			
		//GRAVA FORNECEDOR:
		DbSelectArea("SA2")
		RecLock("SA2" , .T.)
		SA2->A2_COD		:= cCodSA2
		SA2->A2_LOJA	:= cLojSA2 
		
		cAux := ""		
		If Len(aCposCli)
			For x := 1 to Len(aCposCli) 
				cAux := "SA2->" + aCposCli[x,1]
				&cAux:= aCposCli[x,2] 		//aadd( _aRet , { SX3->X3_ARQUIVO + "->"+ _cCpo   , xConteudo } )  //EX.: { SA2->A2_B2B , "2" }
			Next 
		Endif 
		
		/*
		If ExistIni(ìB1_CODî)

		// Chama o inicializador:
		
		cCod := CriaVar(ìB1_CODî)
		
		Endif
		*/ 
			
		If oObjJson <> Nil
			
			SA2->A2_NOME	:= oObjJson:nome
			SA2->A2_NREDUZ	:= oObjJson:nome
			SA2->A2_EST		:= oObjJson:uf
			SA2->A2_END		:= oObjJson:logradouro+','+space(1)+oObjJson:numero
			SA2->A2_MUN		:= oObjJson:municipio
			SA2->A2_TIPO	:= 'J'		
			SA2->A2_CGC		:= cCnpj
			SA2->A2_CEP		:= xCep
			SA2->A2_BAIRRO	:= oObjJson:bairro
			SA2->A2_ENDCOMP	:= oObjJson:complemento
			SA2->A2_DDD		:= substr(xTelefone+space(2),1,2)
			SA2->A2_TEL		:= substr(xTelefone+space(8),3,9)
			SA2->A2_COD_MUN	:= posicione('CC2',4,FWxFilial('CC2')+ Alltrim(oObjJson:uf) + allTrim(oObjJson:municipio),'CC2_CODMUN')	
			If !Empty(cCondSA2)
				SA2->A2_COND    := cCondSA2
			Endif
				
			If !Empty(oObjJson:email)
				SA2->A2_EMAIL := cEmail //oObjJson:email		  
			Endif 
				
		Else 
			 
			SA2->A2_NOME	:= cRazao
			SA2->A2_NREDUZ	:= cNReduz
			SA2->A2_EST		:= cUF
			SA2->A2_END		:= cLogr
			SA2->A2_MUN		:= cMunicip
			SA2->A2_TIPO	:= 'J'		
			SA2->A2_CGC		:= cCnpj
			SA2->A2_CEP		:= cCep
			SA2->A2_BAIRRO	:= cBairro
			SA2->A2_ENDCOMP	:= cCompl
			SA2->A2_DDD		:= cDDD
			SA2->A2_TEL		:= cFone
			SA2->A2_COD_MUN	:= cCodMunic //posicione('CC2',2,FWxFilial('CC2')+allTrim(cCodMunic),'CC2_CODMUN') 
			If !Empty(cCondSA2)
				SA2->A2_COND    := cCondSA2
			Endif 
			
		Endif 		
			
		SA2->A2_PAIS	:= '105'
		SA2->A2_CODPAIS	:= '01058'
					
		SA2->(MsUnlock())
			
		//ATUALIZA ZBZ
		If xRECZBZ <> Nil
			(xZBZ)->(DBGoto(xRECZBZ))
			If Empty( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR"))) )
				
				RecLock(xZBZ,.F.)
				
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CODFOR"), SA2->A2_COD ))
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"LOJFOR"), SA2->A2_LOJA))
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"FORNEC"), SA2->A2_NOME))
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"INDRUR"), SA2->A2_INDRUR))
					
				(xZBZ)->(DbCommit())
				(xZBZ)->(MsUnlock())
						
			Endif
		Endif	 	
			
	Endif //Se n„o È lAuto
		
	//FR - 10/02/2022 - atualiza ZBZ - apenas com as informaÁıes da consulta ao fornecedor
	//ATUALIZA ZBZ
	If xRECZBZ <> Nil
		(xZBZ)->(DBGoto(xRECZBZ))
							
			//FR - 10/02/2022 - SolicitaÁıes de Rafael Lobitsky relativas a consulta fornecedor via api da Sefaz
			cZBZObs := Alltrim( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"OBS"))) ) //FR - 10/02/2022 - Gravar no campo memo, a informaÁ„o da url consulta fornecedor
			//oObjJson:SITUACAO (conte˙do: "ATIVA"), oObjJson:DATA_SITUACAO (conte˙do: vazio, tipo caracter) , oObjJson:MOTIVO_SITUACAO , oObjJson:NATUREZA_JURIDICA
			cZBZObs += "Consulta Sefaz: " + Alltrim(cUrl) + CRLF
			
			If (oObjJson) <> nil
				// CondiÁ„o para caso seja apresentado erro na consulta, normalmente pela tag do xml ser pra fornecedor de CPF.
				// Chamado de erro da Portal Solar - ID: 0014713.
				If oObjJson:STATUS == "ERROR"	
					ConOut("Gest„o XML - Cadastro de Fornecedor por CPF")
				Else
					cSituacao := oObjJson:SITUACAO 			 
				EndIf		 

				cZBZObs += "SituaÁ„o: " + Alltrim(cSituacao) + CRLF
				dDataCons:= Date()
				cHrCons  := Time()
				cZBZObs += CRLF + "Data: " + Dtoc(dDataCons) + " - Hora: " + cHrCons
						
				RecLock(xZBZ,.F.)
					
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"OBS")   , cZBZObs))
						
				(xZBZ)->(DbCommit())
				(xZBZ)->(MsUnlock()) 
			Endif 
					
		Endif
	Endif 
	//ATUALIZA ZBZ   
    

//FR - 15/03 - ALTERA«√O - adequaÁ„o da carga de informaÁıes quando È NF serviÁo
If (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO"))) <> "RP"
	if lXml
	
		If (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO"))) == "57"
			xTag := "CTE"
		Else
			xTag := "NFE"
		EndIf
		
		cTag := "oXml:_"+xTAG+"PROC:_"+xTAG+":_INF"+xTAG+":_EMIT:_CNPJ:TEXT"
		if Type(cTag) <> "U"
			cCpo := &cTag
			M->A2_CGC  := cCpo
			M->A2_TIPO := iif(len(AllTrim(cCpo))==14,"J","F")
		Else
			cTag := "oXml:_"+xTAG+"PROC:_"+xTAG+":_INF"+xTAG+":_EMIT:_CPF:TEXT"
			if Type(cTag) <> "U"
			//cCpo := &cTag
			//if Type(cTag) <> "U"
				M->A2_CGC  := cCpo
				M->A2_TIPO := iif(len(AllTrim(cCpo))==14,"J","F")
			Endif
		Endif 
		
		//Inclus„o de um gatilho exclusivo para Bellenzier 23/08/2016
		If lBELLKEY
		   
			cCpo	:=	Substr(M->A2_CGC,1,6)
			cCpoLoja:=	Substr(M->A2_CGC,11,2)
			
			M->A2_COD	:=	AllTrim(cCpo)
			M->A2_LOJA	:=	Alltrim(cCpoLoja)
					
		EndIf
		
		cTag := "oXml:_"+xTAG+"PROC:_"+xTAG+":_INF"+xTAG+":_EMIT:_IE:TEXT"
		if Type(cTag) <> "U"
			cCpo := &cTag
			M->A2_INSCR := cCpo
		endif
		
		cTag := "oXml:_"+xTAG+"PROC:_"+xTAG+":_INF"+xTAG+":_EMIT:_CNAE:TEXT"
		if Type(cTag) <> "U"
			cCpo := &cTag
			M->A2_CNAE := cCpo
		endif
		
		cTag := "oXml:_"+xTAG+"PROC:_"+xTAG+":_INF"+xTAG+":_EMIT:_IM:TEXT"
		if Type(cTag) <> "U"
			cCpo := &cTag
			M->A2_INSCRM := cCpo
		endif
		
		cTag := "oXml:_"+xTAG+"PROC:_"+xTAG+":_INF"+xTAG+":_EMIT:_ENDEREMIT:_NRO:TEXT"
		if Type(cTag) <> "U"
			cCpo := &cTag
			M->A2_NR_END := cCpo
		endif
		 	
		cTag := "oXml:_"+xTAG+"PROC:_"+xTAG+":_INF"+xTAG+":_EMIT:_XNOME:TEXT"
		if Type(cTag) <> "U"
			cCpo := &cTag
			M->A2_NOME := cCpo
			M->A2_NREDUZ := cCpo
		endif
		
		cTag := "oXml:_"+xTAG+"PROC:_"+xTAG+":_INF"+xTAG+":_EMIT:_XFANT:TEXT"
		if Type(cTag) <> "U"
			cCpo := &cTag
			M->A2_NREDUZ := cCpo
		endif
		
		cTag := "oXml:_"+xTAG+"PROC:_"+xTAG+":_INF"+xTAG+":_EMIT:_ENDEREMIT:_XLGR:TEXT"
		if Type(cTag) <> "U"
			cCpo := &cTag
			M->A2_END := cCpo
		endif
		
		cTag := "oXml:_"+xTAG+"PROC:_"+xTAG+":_INF"+xTAG+":_EMIT:_ENDEREMIT:_XCPL:TEXT"
		if Type(cTag) <> "U"
			cCpo := &cTag
			M->A2_ENDCOMP := cCpo
		endif
		
		cTag := "oXml:_"+xTAG+"PROC:_"+xTAG+":_INF"+xTAG+":_EMIT:_ENDEREMIT:_XBAIRRO:TEXT"
		if Type(cTag) <> "U"
			cCpo := &cTag
			M->A2_BAIRRO := cCpo
		endif
		
		cTag := "oXml:_"+xTAG+"PROC:_"+xTAG+":_INF"+xTAG+":_EMIT:_ENDEREMIT:_UF:TEXT"
		if Type(cTag) <> "U"
			cCpo := &cTag
			M->A2_EST := cCpo
		endif
		
		cTag := "oXml:_"+xTAG+"PROC:_"+xTAG+":_INF"+xTAG+":_EMIT:_ENDEREMIT:_CMUN:TEXT"
		if Type(cTag) <> "U"
			cCpo := &cTag
			M->A2_COD_MUN := Substr(cCpo,3,5)
		endif
		
		cTag := "oXml:_"+xTAG+"PROC:_"+xTAG+":_INF"+xTAG+":_EMIT:_ENDEREMIT:_XMUN:TEXT"
		if Type(cTag) <> "U"
			cCpo := &cTag
			M->A2_MUN := cCpo
		endif
		
		cTag := "oXml:_"+xTAG+"PROC:_"+xTAG+":_INF"+xTAG+":_EMIT:_ENDEREMIT:_CEP:TEXT"
		if Type(cTag) <> "U"
			cCpo := &cTag
			M->A2_CEP := cCpo
		endif
		
		cTag := "oXml:_"+xTAG+"PROC:_"+xTAG+":_INF"+xTAG+":_EMIT:_ENDEREMIT:_CPAIS:TEXT"
		if Type(cTag) <> "U"
			cCpo := &cTag
			M->A2_PAIS := cCpo
		endif
		
		cTag := "oXml:_"+xTAG+"PROC:_"+xTAG+":_INF"+xTAG+":_EMIT:_ENDEREMIT:_FONE:TEXT"
		if Type(cTag) <> "U"
			cCpo := &cTag
			if len(cCpo) > 9
				M->A2_DDD := Substr(cCpo,1,2)
				M->A2_TEL := Substr(cCpo,2,len(cCpo))
			else
				M->A2_TEL := cCpo
			endif
		endif
	
	endif
Endif	
//FR - 15/03 - ALTERA«√O - adequaÁ„o da carga de informaÁıes quando È NF serviÁo

Return( .T. )



Static Function __Dummy(lRecursa) //warning W0010 Static Function <?> never called

    lRecursa := .F.
    
    IF (lRecursa)
    
        __Dummy(.F.)
        U_HFXML08()
        U_HFXML08D()
        U_HFXML08I()
        
	EndIF
	
Return(lRecursa)

//==================================================================================//
//FunÁ„o  : HFXML8PC  
//Autoria : Fl·via Rocha
//Data    : 08/12/2021
//Objetivo: Kitchens - Bot„o gerar pedido de compra
//==================================================================================//
User Function HFXML8PC() //(xOpc) 

	fHFXML8PC()	
	
Return

Static Function fHFXML8PC()
Local i		  	:= 0
Local oDet	
Local aItem		:= {}
Local cModel    := AllTrim( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO"))) )
//Local cNaturez  := Space(TAMSX3("A2_NATUREZ")[1])  //TAMSX3("B1_COD")[1]
Local cCondPg   := Space(TAMSX3("A2_COND")[1])	
Local cCusto    := Space(TAMSX3("CTT_CUSTO")[1])
Local cSolici   := Space(50)
Local dVenc     := Ctod("  /  /    ")
Local cObs      := Space(200)
Local nOpGera   := 0 
Local aCabec    := {}
Local aItens    := {} 
Local cTitulo   := "Campos p/ Pedido de Compra"
Local oXml      
Local cError    := ""
Local cWarning  := ""
Local nOpc      := 0
Local aZBT      := {}
Local cChave    := ""
Local cPC       := ""
Local nQuant	:= 0
Local nVunit	:= 0
Local nTotal	:= 0 
//Local nReg		:= 0
//Local cPreNF    := ""
Local lSeekNF   := .F.
Local cDoc      := ""
Local cSerie    := ""  
Local cFili 	:= ""
Local lPCPreNF  := .F. 
Local nRecZBZ   := 0
Local cChaveF1  := ""
Local cProdXml  := ""
Local cDescrProd:= ""
Local aArea     := GetArea()
Local nLin      := 0
Local cNUMPC    := ""

Local oDlgClas
Local oGrpClas  
Local oSayCond  
Local oGetCond
Local oSayCC
Local oGetCC  
Local oSayObs
Local oSayObs1
Local oGetObs
Local oSayVENC
Local oGetVENC
Local oSaySOL
Local oGetSOL
Local oSayAnex

Local nErrItens := 0
Local aProdNo   := {}
Local aProdOk	:= {}
Local aProdVl	:= {}
Local aProdZr	:= {}
Local cMsgProd  := "" 
Local cCNPJEmi  := ""
Local xRECZBZ   := 0

Local lProssegue := .T.
Local x          := 0
Local lAchou     := .T.
Local cUsaVenc   := GetNewPar("XM_KITVENC" , "N") //habilita o uso do campo Dt. Vencimento na tela gera pedido compra  
Local cItContab  := Space(10)   
Local lXMLPEFORN := ExistBlock( "XMLPEFORN" ) 
Local lProd      := .F. 
Local lSYD       := .T.
Local cFilePrint := ""		//FR - 31/03/2022 - PROJETO KITCHENS - arquivo para imprimir o Danfe para anexar ao bco conhecimento
Local lGerouDanfe:= .F.   													//FR - 31/03/2022 - PROJETO KITCHENS - arquivo para imprimir o Danfe para anexar ao bco conhecimento
Local cDirDanfe  := ""
Local cArqDanfe  := ""
Local aLISTA     := {} 
Local nPos		 := 0
Local lGerouSC7  := .F. 
Local cModelos   := GetNewPar("XM_KITMODE","55/RP" )  //FR - PROJETO KITCHENS - modelos v·lidos para permitir geraÁ„o de pedido compra autom·tico  
Local nTamProd   := TAMSX3("B1_COD")[1]   
Local cChaveZBZ  := ""
Local fr         := 0

Private xZBZ	:= GetNewPar("XM_TABXML","ZBZ")
Private xZB5  	:= GetNewPar("XM_TABAMAR","ZB5")
Private xZBS  	:= GetNewPar("XM_TABSINC","ZBS")
Private xZBE    := GetNewPar("XM_TABEVEN","ZBE")
Private xZBZ_ 	:= iif(Substr(xZBZ,1,1)=="S", Substr(xZBZ,2,2), Substr(xZBZ,1,3)) + "_"
Private xZB5_ 	:= iif(Substr(xZB5,1,1)=="S", Substr(xZB5,2,2), Substr(xZB5,1,3)) + "_"
Private xZBS_ 	:= iif(Substr(xZBS,1,1)=="S", Substr(xZBS,2,2), Substr(xZBS,1,3)) + "_"
Private xZBE_   := iif(Substr(xZBE,1,1)=="S", Substr(xZBE,2,2), Substr(xZBE,1,3)) + "_"
Private xZBA  	:= GetNewPar("XM_TABAMA2","ZBA")
Private xZBA_ 	:= iif(Substr(xZBA,1,1)=="S", Substr(xZBA,2,2), Substr(xZBA,1,3)) + "_"
Private xZBC    := GetNewPar("XM_TABCAC","ZBC")
Private xZBC_   := iif(Substr(xZBC,1,1)=="S", Substr(xZBC,2,2), Substr(xZBC,1,3)) + "_"
Private xZBO    := GetNewPar("XM_TABOCOR","ZBO"), xRetSEF := ""
Private xZBO_   := iif(Substr(xZBO,1,1)=="S", Substr(xZBO,2,2), Substr(xZBO,1,3)) + "_"
Private xZBI    := GetNewPar("XM_TABIEXT","ZBI")
Private xZBI_   := iif(Substr(xZBI,1,1)=="S", Substr(xZBI,2,2), Substr(xZBI,1,3)) + "_"
Private lMsErroAuto := .F.
Private aCabec  := { }
Private lAmarrou:= .F.

Private lITObrig   := .F.  //se o centro de custo aceita item cont·bil
Private aCadProd   := {} 
Private cNcm	   := ""
Private cUM        := ""
Private cTipoNF    := ""
Private cProdXml   := ""
Private cProduto   := ""
Private cDescprod  := ""
 
//Private cDir       := AllTrim( GetNewPar("XM_DIRANEX" , "\anexos\") ) 
Private cArqOri    := Space(200)  
Private cDirAN1    := "\dirdoc" //Pasta do banco de conhecimento	//"\ANEXOS\SC1\"    //D:\PROTHEUS12\Protheus_R25\protheus_data\dirdoc\co99 o arquivo precisa estar nesta pasta para gravar na AC8 e ACB
Private cDirAN2    := "\co" 	//Pasta do banco de conhecimento	//"\ANEXOS\SC1\"    //D:\PROTHEUS12\Protheus_R25\protheus_data\dirdoc\co99 o arquivo precisa estar nesta pasta para gravar na AC8 e ACB
Private cDirAN3    := "\shared\" 
Private cDir	   := ""
Private cArq	   := "" 
Private lCopiou    := .F. 	//indica se copiou o anexo da maq local para a pasta no servidor
Private lCopiouD   := .F. 	//indica se copiou o danfe pdf gerado na maq local para a pasta no servidor 

Private aUserData := {"",""} 
Private cTopFun   := ""
Private cBotFun   := "ZZZZ"
Private cFilUsu   := GetNewPar("XM_FIL_USU","N")
Private x_Ped_Rec := GetNewPar("XM_PEDREC","N")
Private x_Tip_Pre := GetNewPar("XM_TIP_PRE","1")
Private cDelFunc  := ".F." // Validacao para a exclusao. Pode-se utilizar ExecBlock
Private lSetParam := .F.
Public  cMsgRet    := "" //msg que retorna da tentativa do cadastro robÛtico de produto (caso haja msg) 
Public lSB1BLOQ   := .F. 
Public aBloqSB1   := {}

cDocNF 		 := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA"))) 
cSerie       := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE"))) 

PswOrder(2)
cUserName := Substr(cUsuario,7,15)
If PswSeek( cUserName, .T. )
	aUserData := PswRet()
	If aUserData[1][1]== "000000" .or. ( Ascan(aUserData[1][10],'000000') <> 0 ) //.or. aScan( aUserData[2][6], "@@@@" ) > 0
		lSetParam := .T.
	EndIf
Else
	PswOrder(1)
	cCodUsr := RetCodUsr()
	If PswSeek( cCodUsr, .T. )
		aUserData := PswRet()
		If aUserData[1][1]== "000000" .or. ( Ascan(aUserData[1][10],'000000') <> 0 ) //.or. aScan( aUserData[2][6], "@@@@" ) > 0
			lSetParam := .T.
		EndIf
	Else
		aUserData:={{"",""}}
		cFilUsu := "N"
	Endif
EndIf
//Fim verifica user admin
//msg sobre par‚metros:
If lSetParam
	If !MsgYesNo("AtenÁ„o: Verifique a ConfiguraÁ„o dos Par‚metros Antes de Continuar:" + CRLF + CRLF+;
				"XM_PESQNCM ;" + CRLF + ;
				"XM_SB1AUTO ;" + CRLF + ;
				"XM_KITVENC ;" + CRLF + ;
				"XM_KITMODE ;" + CRLF + ;
				"XM_MAIL09  ;" + CRLF + ;
				"XM_KIPCZBT ," + CRLF + CRLF + "Caso N„o Existam, Execute o COMPATIBILIZADOR U_UPDIF001"+ CRLF + CRLF+;
				" Se J· Verificou, Continua ?")
		
		MsgInfo("OperaÁ„o Cancelada Pelo Usu·rio")
		Return
		
	Endif
Endif 

cCNPJEmi     := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))) 

If Empty(cCNPJEmi)
	U_MyAviso("Aviso","CNPJ Emitente Est· Vazio, " + CRLF + "Por Favor Reveja o XML, " + CRLF + "n„o Permitido Gerar PC." ,{"OK"},3) 
	Return
Endif  

//ver se a prÈ-nf ou nota classificada j· foi gerada:
If (xZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF"))) <> "B"
	U_MyAviso("Aviso","XML J· Gerou PRE-NF ou NF Classificada, n„o Permitido Gerar PC." ,{"OK"},3) 
	Return
Endif

//ver se o xml est· resumido
If (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOWL"))) = "R"
	
	U_MyAviso("Aviso","Este XML … Resumido, " + CRLF + "Por Favor: Efetue Download Via 'Outras AÁıes -> Download Completo XML Resumo'" ,{"OK"},3) 
	Return

Endif 

nRecZBZ   := (xZBZ)->(RECNO())  

//ver se o pedido gravado na ZBT existe na SC7:
(xZBZ)->(Dbgoto(nRecZBZ))
cDocNF   := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA")))
cSerieNF := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE"))) 
cChave   := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE")))  
lTemPC   := .F.
aPeds    := {}

(xZBT)->(OrdSetFocus(2))  //ZBT_CHAVE
If (xZBT)->(Dbseek(cChave))
	While (xZBT)->(!Eof()) .and. Alltrim((xZBT)->(FieldGet(FieldPos(xZBT_+"CHAVE")))) == Alltrim(cChave)
		
		If !Empty( Alltrim((xZBT)->(FieldGet(FieldPos(xZBT_+"PEDIDO"))) )  )
			cPC := Alltrim((xZBT)->(FieldGet(FieldPos(xZBT_+"PEDIDO"))) )
		
			Aadd(aPeds, { cPC , (xZBT)->(FieldGet(FieldPos(xZBT_+"FILIAL"))) } )  //FR - 23/06/2022
		Endif 
		(xZBT)->(Dbskip())
	Enddo
Endif
	
If Len(aPeds) > 0
	For fr := 1 to Len(aPeds)

		lTemPC := fTemC7(aPeds[fr,1] , aPeds[fr,2])

		If lTemPC
			MsgInfo("Pedido de Compra J· Gerado -> " + aPeds[fr,1] ) 
			lProssegue := .F. 
			Exit
		//Else
		//	MsgInfo("Pedido N„o Existe ou Cancelado")
		Endif 
	Next
	
	If !lTemPC
		MsgInfo("Pedido N„o Existe ou Cancelado")
	Endif 
Endif



If lProssegue

	//If !cModel $ "55/57/RP" 
	If !cModel $ cModelos   //FR - configuraÁ„o dos modelos v·lidos por par‚metro

		U_MyAviso("Aviso","Modelo Diferente de " + cModelos + ", n„o Permitido Gerar PC." ,{"OK"},3) 
		Return
	Endif

	If !MsgYesNo("Confirma a GeraÁ„o do Pedido de Compra Autom·tico ?")
		MsgInfo("OperaÁ„o Cancelada Pelo Usu·rio")
		Return
	Endif 

	//CRIA PASTA PARA GUARDAR OS ANEXOS ANTES DE COPIAR PARA SERVIDOR:
	cDirAN2 += Alltrim(cEmpant)  //"co99"  99 eh a empresa

	If !lIsDir(cDirAN1)

		nMDir := MakeDir( cDirAN1 )      //"\protheus_data\dirdoc\co99\
		if nMDir <> 0
			alert("nao foi possivel criar Dir: "+ cDirAN1 + ", result -> " + Alltrim(Str(nMDir)))
		endif	
	endif

	If !lIsDir( cDirAN1 + cDirAN2)
		nMDir := MakeDir( cDirAN1 + cDirAN2 )
		if nMDir <> 0
			alert("nao foi possivel criar Dir: "+ cDirAN1 + cDirAN2 + ", result -> " + Alltrim(Str(nMDir)))
		endif
		
	endif

	If !lIsDir( cDirAN1 + cDirAN2 + cDirAN3)
		nMDir := MakeDir( cDirAN1 + cDirAN2 + cDirAN3 )
		if nMDir <> 0
			alert("nao foi possivel criar Dir: "+ cDirAN1 + cDirAN2 + cDirAN3 + ", result -> " + Alltrim(Str(nMDir)))	
		endif
		
	endif    

	cDir := cDirAN1 + cDirAN2 + cDirAN3  //  "\dirdoc\co99\shared\"

	//gerar danfe separado
	cDirDanfe  := "C:\DANFE\"      //nf 000058701
	If !lIsDir( cDirDanfe)
		nMDir := MakeDir( cDirDanfe )
		if nMDir <> 0
			alert("nao foi possivel criar Dir: "+ cDirDanfe + ", result -> " + Alltrim(Str(nMDir)))	
		endif	
	endif 
	
	xHora      := Time()
	cArqDanfe  := "DANFE_"+ cModel + "_" + cDocNF + "_" + Dtos(MSDate()) + "_" + Substr(xHora,1,2) + Substr(xHora,4,2)+ "H.PDF"  //DANFE_modelo_numeroNF_data_hora.pdf -> ex.: danfe_55_000058701_20220501_1527h.pdf

	If cModel <> "RP"
		Processa( {|| 	lGerouDanfe := U_XMLPRTdoc(.T.,cDirDanfe,cArqDanfe) }, "Aguarde...", "Gerando Danfe PDF Para Anexar...",.F.) 
	Else
		//Danfe PDF de nf serviÁo em adequaÁ„o
		//MsgInfo("Danfe PDF para anexar -> Em desenvolvimento")
		Processa( {|| 	lGerouDanfe := U_DanfseSP(.T.,cDirDanfe,cArqDanfe)  }, "Aguarde...", "Gerando Danfe PDF Para Anexar...",.F.) 
	Endif 

	If File(cDirDanfe + cArqDanfe)
		//SE encontrou o arquivo, verifica o tamanho: 
		aLISTA := DIRECTORY( cDirDanfe + "*.PDF",  ,  , .T. )
		nTAM   := 0
		nPOS   := ASCAN(aLISTA,{|X| ALLTRIM(X[1])==cArqDanfe })
		IF nPOS > 0
		nTAM := aLISTA[nPOS,2]
		ENDIF
			
		If nTAM <= 0
			lGerouDanfe := .F.
			//MsgAlert("PDF n„o gravou na pasta") 
			lGerouDanfe := .F.
		Else
			lGerouDanfe := .T.
			//MsgInfo("DANFE PDF OK")
		Endif
			
	Else 
		lGerouDanfe := .F.
	Endif


	If !lGerouDanfe 
		If !MsgYesNo("Danfe PDF N„o PÙde Ser Gerado, " + CRLF + "Deseja Continuar a Gerar o  Pedido de Compra ?")
			MsgInfo("OperaÁ„o Cancelada Pelo Usu·rio")
			Return
		Endif 
	Else
		//copia o arquivo pdf Danfe para o servidor
		If !Empty(cArqDanfe)
			xPathArq := Alltrim(cDirDanfe) + Alltrim(cArqDanfe)
			lCopiouD := CpyT2S( xPathArq , cDir , .F. )   // cDirDanfe: "C:\DANFE\" ; cArqDanfe: "DANFE_20220429.PDF" ;  cDir: "\dirdoc\co99\shared\"
		Endif
	Endif 
	//gerar danfe separado 



	aadd(aCabec, {" ", " "})    
	aCabec[1][2] := "N"    

	aCabec[1][2] := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC"))) 
	cTipoNF      := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC"))) 
	cCodEmit     := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR")))
	cLojaEmit    := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR")))
	cFili        := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL")))
	cCNPJEmi     := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))) 
	cChaveZBZ    := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))) 

	xRECZBZ      := (xZBZ)->(Recno())

	cChaveF1     := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))) + (xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA"))) +;
				(xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE")))  + (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR"))) +;
				(xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR"))) + (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC")))
		
	DbSelectArea("SF1")
	DbSetOrder(1)

	lSeekNF := DbSeek(cChaveF1) 


	If !lSeekNF
		SF1->( DbSetORder(8) )  //F1_FILIAL + F1_CHNFE
		lSeekNF := DbSeek( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL")))+Trim((xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE")))) )
	Endif 

	If lSeekNF  //se localizou a nota, verifica se j· classificou
	//N - prÈ nota classificada 'vermelho'
	//S - prÈ nota a classificar 'verde' 
		
		cDocNF := SF1->F1_DOC
		cSerie := SF1->F1_SERIE
		
		
		If !Empty(SF1->F1_STATUS)  //J· classificou
			U_MyAviso("Aviso","XML de Nota J· Classificada, n„o Permitido Gerar PC." ,{"OK"},3) 
			Return
		
		//SÛ tem pre-nf
		Else
			SD1->(OrdSetFocus(1)) 
			//ORDEM 1 - D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
			If SD1->(Dbseek( cFili + cDocNF + cSerie + cCodEmit + cLojaEmit ))
				While SD1->(!Eof()) .and. SD1->D1_FILIAL == cFili .and. SD1->D1_DOC == cDocNF .and. SD1->D1_SERIE == cSerie .and. SD1->D1_FORNECE == cCodEmit .and. SD1->D1_LOJA == cLojaEmit
					If !Empty(SD1->D1_PEDIDO)
						lPCPreNF := .T. 
						cPC      := SD1->D1_PEDIDO
					Endif 
					SD1->(Dbskip())
				Enddo
			Endif 	
		
		Endif
		
		//Se encontrou pedido vinculado na prÈ-nota, avisa e n„o deixa gerar pedido
		If lPCPreNF
			U_MyAviso("Aviso","Existe PrÈ-Nota com Pedido Vinculado: " + cPC + ", N„o Permitido Gerar PC." ,{"OK"},3) 
			Return
		Endif  

	Endif 

		
	If lProssegue

		(xZBZ)->(Dbgoto(nRecZBZ)) 
		
		oXml := XmlParser((xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML"))), "_", @cError, @cWarning )  
		
		If Empty( oXml )
			U_MyAviso("Aviso","N„o Foi Possivel Gerar o Pedido de Compra do XML, Motivo: Status = Resumido.",{"OK"},3) 	
			Return	
		Endif 
		
		//FR - 07/01/2022
		If oXml == NIL .Or. !Empty(cError) .Or. !Empty(cWarning)

			If empty(cError)
				cError := "XML Importado com erro. Verifique os dados importados e refaÁa a importaÁ„o."
			Endif
		
			U_MyAviso("Xml com caracter n„o suportado",cError,{"OK"},3)
		
			RestArea( aArea )
		
			Return( .F. )
		
		EndIf
		cCodEmit  := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR")))
		cLojaEmit := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR")))
			
		If Empty( cCodEmit )
				
			//pesquisa o CNPJ
			SA2->(OrdSetFocus(3))
			If SA2->(DbSeek(xFilial("SA2") + cCNPJEmi ))  
				DbSelectArea(xZBZ)
				RecLock(xZBZ,.F.)
		
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CODFOR"), SA2->A2_COD ))
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"LOJFOR"), SA2->A2_LOJA))
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"FORNEC"), SA2->A2_NOME))
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"INDRUR"), SA2->A2_INDRUR))
				(xZBZ)->(DbCommit())
				(xZBZ)->(MsUnlock())

			Else   
				
				//Cadastra o fornecedor automaticamente
				Processa( {|| 	U_fCADSA2(cCNPJEmi,xRECZBZ) }, "Aguarde...", "Fornecedor (SA2) - Processando Cadastro Autom·tico. ...",.F.)
			
			Endif 

		Else 		//If Empty( cCodEmit )
					//aqui cCodEmit / cLojaEmit est„o preenchidos, validar se existe na SA2
			SA2->(OrdSetFocus(3))
			If SA2->(DbSeek(xFilial("SA2") + cCNPJEmi ))  
				
				DbSelectArea(xZBZ)
				RecLock(xZBZ,.F.)
		
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CODFOR"), SA2->A2_COD ))
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"LOJFOR"), SA2->A2_LOJA))
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"FORNEC"), SA2->A2_NOME))
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"INDRUR"), SA2->A2_INDRUR))
				(xZBZ)->(DbCommit())
				(xZBZ)->(MsUnlock())

			Else 
				SA2->(OrdSetFocus(1))
				If !SA2->(DbSeek(xFilial("SA2") + cCodEmit + cLojaEmit ))  
				
					//Cadastra o fornecedor automaticamente	
					Processa( {|| 	U_fCADSA2(cCNPJEmi,xRECZBZ) }, "Aguarde...", "Fornecedor (SA2) - Processando Cadastro Autom·tico. ...",.F.)		   	
				Endif
			Endif  
		
		Endif 
		
		//quando chega aqui se houve cadastramento do fornecedor, pego novamente o cÛdigo:
		cCodEmit  := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR")))
		cLojaEmit := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR")))
		
		//VALIDA PRODUTOS ANTES DA TELA
		If cModel <> "RP"
			
			If cModel <> "57"
				oDet := oXml:_NFEPROC:_NFE:_INFNFE:_DET
				oDet := IIf(ValType(oDet)=="O",{oDet},oDet)			
						
				If Type("oXml:_NFEPROC:_NFE:_INFNFE:_DET") == "A"		
					aItem := oXml:_NFEPROC:_NFE:_INFNFE:_DET			
				Else		
					aItem := {oXml:_NFEPROC:_NFE:_INFNFE:_DET}			
				EndIf 
						
				For i := 1 To Len(oDet)	
					
					cProduto  := ""
					cDescProd := ""				
					cNcm	  := Alltrim(oDet[i]:_Prod:_NCM:TEXT) 
					cProdXml  := Alltrim(oDet[i]:_Prod:_CPROD:TEXT) 
					
					If cModel $ "55,65"	
						cUM    := oDet[i]:_Prod:_UCOM:TEXT
					Endif 
					
					If GetNewPar("XM_PESQNCM" , "1") == "1" //1-localiza a NCM e traz qualquer cÛdigo que encontrar com a NCM; 2-Localiza B1_COD = B1_POSIPI
						//Procura na SB1 , algum produto com a ncm, o primeiro produto que localizar com a NCM, assume
						cProduto  := U_fVerSB1N(cNcm)      //QUERY NA SB1 considerando NCM , traz qualquer B1_COD com a NCM informada
					Else
						//Procura na SB1 um produto cujo cÛdigo B1_COD = NCM , isso mesmo, B1_COD = NCM a Kitchens cadastra o cÛdigo do produto igual a NCM
						cProduto := U_fVerB1_NCM(cNcm)    //QUERY NA SB1 considerando B1_COD = NCM informada
					Endif 
										
					If Empty(cProduto) 					//se n„o encontrar de nenhum jeito, vai cadastrar automaticamente se o par‚metro abaixo estiver = "S"
					                                    //nesse caso o cÛdigo de produto ser· a prÛpria NCM
						If GetNewPar("XM_SB1AUTO", "N") == "S"  //cadastra produto automaticamente
							aCadProd := U_fCADB1Auto(cNcm)  
							//U_FCADB1AUTO -> caso n„o encontre o produto na SB1, pesquisa na SYD a NCM 
							//e assume o este cÛdigo como cÛdigo de produto para cadastrar como novo produto
								/*
								Retorno da funÁ„o acima:
								aADD(aRetorno , cProd  )
								aADD(aRetorno , cDesc  )
								aADD(aRetorno , nIpi  )
								*/
								cDescProd := aCadProd[2]
							//aqui chama a funÁ„o de cadastrar automaticamente
							If Len(aCadProd) > 0
								//lProd := u_HFPRDSB1( aCadProd[1] ,1,cProdXml,cDescProd,cModel,cUM,cNcm,aCadProd[3])  //u_HFPRDSB1( _cCodProd,i,xProd,xDescri,xModelo,xUM,xNCM,nIpi )
								//Processa( {|| 	lProd := u_HFPRDSB1( aCadProd[1] ,1,cProdXml,cDescProd,cModel,cUM,cNcm,aCadProd[3]) }, "Aguarde...", "Produto (SB1) - Processando Cadastro Autom·tico. ...",.F.)		   	
								If !Empty(aCadProd[1]) //se retornou um produto conforme ncm: processa o cadastro
									
									//ver se o produto t· bloqueado antes de processar o cadastro (vai que alguÈm cadastrou um cÛdigo igual e j· bloqueou, parece loucura mas a Kitchens fez um teste assim)
									DbselectArea("SB1")
									SB1->(OrdSetFocus(1))
									If DbSeek(xFilial("SB1") + aCadProd[1])										
										
										If FieldPos("B1_MSBLQL") > 0
											If SB1->B1_MSBLQL == "1"
												cMsgRet    += CRLF + aCadProd[1] + " -> Produto J· Cadastrado"
												cMsgRet    += CRLF + aCadProd[1] + " -> Produto Bloqueado no Cadastro"
												lSB1Bloq   := .T.																							
												lProssegue := .F. 
												If Ascan(aBloqSB1,aCadProd[1]) == 0
													Aadd(aBloqSB1, aCadProd[1])  
												Endif 
												
											Endif
										Endif 
										 
									Endif 
									
									Processa( {|| 	lProd := U_FCADSB1( aCadProd[1] ,1,cProdXml,cDescProd,cModel,cUM,cNcm,aCadProd[3]),@cMsgRet,@lSB1Bloq,@aBloqSB1}, "Aguarde...", "Produto (SB1) - Processando Cadastro Autom·tico. ...",.F.)		   	
								Else
									//FR - 07/07/2022 - MELHORIA NA MSG DE RETORNO
									If GetNewPar("XM_PESQNCM" , "1") == "1" //qq cÛdigo com a NCM
										cMsgProd :=  "NCM N„o Localizada na SB1 para Efetuar AmarraÁ„o..."
									Else 
										cMsgProd :=  "NCM N„o Localizada na SYD para Efetuar AmarraÁ„o..."+CRLF+"Solicitar Cadastro"
										lSYD     := .F.
									Endif
									//FR - 07/07/2022 - MELHORIA NA MSG DE RETORNO

								Endif 
							Endif 
						Endif 
						
						If !lProd .and. lSYD  //se n„o conseguiu cadastrar, mas tem NCM, abre tela para amarraÁ„o: 
							
							//se vazio È porque n„o encontrou no SB1:
							//cMsgProd := "NCM N„o Localizada no SB1 para Efetuar AmarraÁ„o..."
							
							aadd( aProdNo, {oDet[i]:_Prod:_CPROD:TEXT,oDet[i]:_Prod:_XPROD:TEXT} )
							lAchou := .F.		//FR - 07/01/2022	- esta vari·vel estando falsa, permite abrir a tela de amarraÁ„o			
						
						Elseif !lSYD 
							lProssegue := .F. //se n„o tem NCM n„o tem como cadastrar o produto
						Endif

					Else 
					
						DbSelectArea("SB1")
						SB1->(OrdSetFocus(1))
						SB1->(Dbseek(xFilial("SB1") + cProduto))  
														
						If FieldPos("B1_MSBLQL") > 0
							If SB1->B1_MSBLQL == "1"
								//produto bloqueado
								lProssegue := .F. 
								lSB1BLOQ   := .T. 
								If Ascan(aBloqSB1,cProduto) == 0
									Aadd(aBloqSB1, cProduto)  
								Endif 
							Endif 
						Endif
						 			
						aadd( aProdOk, {oDet[i]:_Prod:_CPROD:TEXT,oDet[i]:_Prod:_XPROD:TEXT} )  
						
					Endif
				Next
						
			Else  //modelo 57 - CTE
			
				//if type("oXml:_CTEPROC:_CTE:_INFCTE:_VPREST") <> "U"
				//	oDet := oXml:_CTEPROC:_CTE:_INFCTE:_VPREST
				//endif
			
				cProdCte := Padr(GetNewPar("XM_PRODCTE","FRETE"),nTamProd)
				cProdCte :=Iif(Empty(cProdCte),Padr("FRETE",nTamProd),cProdCte) 
				//cProduto := cProdCte
				
				//para cte, procura amarraÁ„o na SA5:
				cProduto   := U_fVerSA5(cProdCte,cCodEmit,cLojaEmit) 
				cDescrProd := "PRESTACAO DE SERVICO - FRETE"
				
				If Empty(cProduto)
					cMsgProd := "Produto: " + cProdCte + ", N„o Localizado no Cadastro de AmarraÁ„o Padr„o (SA5) !!!"					 
					aadd( aProdNo, {cProdCte,cDescrProd} )
					lAchou := .F.		//FR - 07/01/2022	- esta vari·vel estando falsa, permite abrir a tela de amarraÁ„o			
				Else
					aadd( aProdOk, {cProdCte,cDescrProd} )
				Endif
					
			Endif
			
		Else		//modelo serviÁo
		
		
			cProduto  := ""
			If XmlChildEx(oXml:_NFSETXT:_INFPROC,"_PRODSRV") <> NIL			//(oDet[i]:_Prod,"_Rastro") <> nil 		
				cProdXml  := oXml:_NFSETXT:_INFPROC:_PRODSRV:TEXT  //Alltrim(oDet[i]:_Prod:_CPROD:TEXT) 
				cDescrProd:= oXml:_NFSETXT:_INFPROC:_DESSRV:TEXT
			//Else
			//	MsgAlert("XML Inv·lido !!!")
			//	Return
					
			Else
				cProdXml   := "SERVICO"
				cDescrProd := "SERVICO"
			Endif 	
			//para nf serviÁo, procura amarraÁ„o na SA5:
			cProduto  := U_fVerSA5(cProdXml,cCodEmit,cLojaEmit)
				
			If Empty(cProduto)
				cMsgProd := "Produto N„o Localizado no Cadastro de AmarraÁ„o Padr„o (SA5) !!!"					 
				aadd( aProdNo, {cProdXml,cDescrProd} )
				lAchou := .F.		//FR - 07/01/2022	- esta vari·vel estando falsa, permite abrir a tela de amarraÁ„o			
			Else
				aadd( aProdOk, {cProdXml,cDescrProd} )
			Endif		
		
		Endif  //if dos modelos xml
		
		//aqui È geral:
		If lProssegue 
			//chama tela cadastro - aproveitamento da funÁ„o existente de amarraÁ„o
			If !lAchou  //abre a tela para amarrar  //FR - 07/01/2022
				U_ItNaoEnc( "PREN", aProdOk, aProdNo, aProdVl, @nErrItens, aProdZr,"1",@lAmarrou )
			Endif	
			//AT… AQUI, VALIDA PRODUTOS ANTES DA TELA 
			
			If !lAchou
			
				If !lAmarrou
					
					If !Empty(cMsgProd) .or. !Empty(cMsgRet)
						MsgAlert(cMsgProd + CRLF + cMsgRet)						
					Endif
					lProssegue := .F.  //se n„o amarrar, n„o deixa prosseguir
					//Return 
					
				Else
				    //se amarrou, mas o produto t· bloqueado, n„o vai deixar prosseguir
					If lSB1BLOQ					
						lProssegue := .F. 
					Endif

				Endif  //lAmarrou
				
			Endif  //lAchou
		
		Else
		    //se h· produto(s) bloqueado(s):
			If lSB1BLOQ
				//cPrdBloq := ""

				//For x := 1 to Len(aBloqSB1)
				//	cPrdBloq += CRLF + aBloqSB1[x] 
				//Next 

				//MsgAlert("Existe(m) Produto(s) Bloqueado(s) No Cadastro de Produto SB1:" + CRLF + cPrdbloq)  
				lProssegue := .F. 
				
			Endif  
			
			//If !Empty(cMsgProd) .or. !Empty(cMsgRet)
			//	MsgAlert(cMsgProd + CRLF + cMsgRet)
			//Endif 
	   
		Endif
		
		//se h· produto(s) bloqueado(s):
		If lSB1BLOQ
			cPrdBloq := ""

			For x := 1 to Len(aBloqSB1)
				cPrdBloq += CRLF + aBloqSB1[x] + ";" //cria string da msg de produtos bloqueados
			Next 

			MsgAlert("Existe(m) Produto(s) Bloqueado(s) No Cadastro de Produto SB1:" + CRLF + cPrdbloq + CRLF + CRLF + "OperaÁ„o N„o Poder· Prosseguir.")  
			lProssegue := .F. 
			Return
		Endif  

		If !lSYD
			If !Empty(cMsgProd) .or. !Empty(cMsgRet)
				MsgAlert(cMsgProd + CRLF + cMsgRet)
			Endif 
		Endif 		
		
		If lProssegue
			//-------------------------//
			//TELA:	
			//-------------------------//
			//oDlgClas := MSDialog():New( 174,431,500,815,cTitulo,,,.F.,,,,,,.T.,,,.T. )  
			oDlgClas := MSDialog():New( 174,431,600,815,cTitulo,,,.F.,,,,,,.T.,,,.T. )  
			//oGrpClas := TGroup():New( 004,004,108,190,"",oDlgClas,CLR_BLACK,CLR_WHITE,.T.,.F. ) 
			oGrpClas := TGroup():New( 004,004,148,190,"",oDlgClas,CLR_BLACK,CLR_WHITE,.T.,.F. ) 
								
			//+20
			nLin := 12
			oSayCond := TSay():New( nLin,008,{||"* Cond.Pagto:"},oGrpClas,,,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,044,008) 
			oGetCond := TGet():New( nLin,060,{|u| If(PCount()>0,cCondPg:=u,cCondPg)},oGrpClas,076,008,'',{|| fValCond(cCondPg)} /*bvalid*/,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"HFSE4","cCondPg",,)      
			//@ nLin,008 Get cCondPg SIZE 076,008 Picture "@X" Valid fValCond(cCondPg)  F3 "HFSE4" When .T.	of oGrpClas PIXEL
			//@ nLin,008 MSGet oGetCond VAR cCondPg F3 "HFSE4" SIZE 076,008 OF oGrpClas F3 "SM0" PIXEL		
			//@ nLin,060 MSGET cCondPg PICTURE PesqPict("SE4","E4_CODIGO") SIZE 076,008 Valid fValCond(cCondPg) F3 "HFSE4" PIXEL OF oGrpClas
					
			//+20    //nf 000235863
			If cUsaVenc == "S"    		//GetNewPar("XM_KITVENC" , "S") //habilita o uso do campo Dt. Vencimento na tela gera pedido compra
				DbSelectArea("SC7")
				If FieldPos("C7_XDVENC") > 0 //FR - PROJETO KITCHENS Fase 2 - se Existir o campo na base
					nLin += 20  //= 32
					oSayVENC := TSay():New( nLin,008,{||"* Data 1o. Vencto:"},oGrpClas,,,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,044,008) 
					oGetVENC := TGet():New( nLin,060,{|u| If(PCount()>0,dVenc:=u,dVenc)},oGrpClas,076,008,'',{|| fValdVenc(dVenc)} /*bvalid*/,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","dVenc",,)
				Endif
			Endif  
			
			//+20
			nLin += 20  
			oSayCC := TSay():New( nLin,008,{||"* Centro Custo:"},oGrpClas,,,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,044,008) 
			oGetCC := TGet():New( nLin,060,{|u| If(PCount()>0,cCusto:=u,cCusto)},oGrpClas,076,008,'',{|| fValCC(cCusto)} /*bvalid*/,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"CTT","cCusto",,)      
			
			nLin += 20  
			oSayCC := TSay():New( nLin,008,{||"* Item Cont·bil:"},oGrpClas,,,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,044,008) 
			oGetCC := TGet():New( nLin,060,{|u| If(PCount()>0,cItContab:=u,cItContab)},oGrpClas,076,008,'',{|| fValITC(cCusto,cItContab)} /*bvalid*/,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"CTD","cItContab",,)      

			
			//+20
			nLin += 20      //a consulta SAI foi feita no configurador apontando para a tabela padr„o de usu·rios, o retorno È nome
			oSaySOL := TSay():New( nLin,008,{||"* Solicitante:"},oGrpClas,,,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,044,008) 
			oGetSOL := TGet():New( nLin,060,{|u| If(PCount()>0,cSolici:=u,cSolici)},oGrpClas,076,008,'',{|| fValSolici(cSolici)} /*bvalid*/,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"HFSAI","cSolici",,)      

			nLin += 20  //= 52 ou 72 se houver o campo C7_XDVENC
			oSayObs  := TSay():New( nLin,008,{||"ObservaÁ„o:"},oGrpClas,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,044,008) 
			@ nLin,060 GET cObs MEMO SIZE 115,030 /*300,105*/ OF oGrpClas PIXEL //HSCROLL
			
			cTipo	:= "Arquivo Texto (*.txt) | *.txt  | "                     // + GETF_NOCHANGEDIR
			cTipo	+= "Todos Arquivos        | *.*    | "

			nLin += 45
			oSayAnex := TSay():New( nLin,007,{||"* ANEXAR DOCUMENTO..."},oGrpClas,,,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,074,008) 
			oSayAnex := TSay():New( nLin+10,007,{||"(NF Anexada automaticamente)"},oGrpClas,,,.F.,.F.,.F.,.T.,CLR_HRED,CLR_WHITE,080,008) 

			oGetAnex := TGet():New( nLin,075,{|u| If(PCount()>0,cArqOri:=u,cArqOri)},oGrpClas,086,008,'',{|| } /*bvalid*/,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cArqOri",,)      
			@ nLin,165 Button "?" SIZE 005,012 PIXEL ACTION ABREARQ()     // cArqOri := \ANEXOS\TELA_21-03-2022.JPG
			
			nLin += 40	
			//oSBtnCla1          := TButton():New( nLin,066,"Confirma",oDlgClas,,037,012,,,,.T.,,"",,,,.F. )
			oSBtnCla1          := TButton():New( nLin,110,"Confirma",oDlgClas,,037,012,,,,.T.,,"",,,,.F. )
			oSBtnCla1:bAction  := {|| ( iif(fValTudo(cArqOri,dVenc,cCondPg,cCusto,cSolici,cItContab) , (nOpGera := 1,oDlgClas:End())  , nOpGera := 0)  ) } 
			
			//oSBtnCla2          := TButton():New( nLin,110,"Cancela",oDlgClas,,037,012,,,,.T.,,"",,,,.F. )   //RETIRADO, PARA CANCELAR BASTA CLICAR NO 'X' da JANELA
			//oSBtnCla2:bAction  := {|| ( nOpGera:= 99, oDlgClas:End()) } 
								
			oDlgClas:Activate(,,,.T.)
			
			lProssegue := .F. 
		
			If nOpGera = 1  //confirma da tela, se confirmar, prossegue com o processo
			
				If MsgYesNo("Confirma a GeraÁ„o do Pedido de Compra ?")
					lProssegue := .T.
				Endif		
				
			Endif  
			
			If lProssegue  //geral da tela, se for falso, n„o prossegue
			
				//copia o arquivo que o usu·rio selecionou da maq dele para o servidor
				If !Empty(cArqOri)
					lCopiou := CpyT2S( cArqOri, cDir , .F. )   //TESTE
					nPos    := RAT("\", cArqOri)
					cArq    := Substr(cArqOri,nPos+1,Len(cArqOri)-nPos)
				Endif
				
				
				If lProssegue //chegando aqui gera de fato o pedido de compra

					//aqui continua com a reuni„o dos dados para geraÁ„o do pedido compra:	 
					If cModel <> "RP"
						
						If cModel <> "57"
							oDet := oXml:_NFEPROC:_NFE:_INFNFE:_DET
							oDet := IIf(ValType(oDet)=="O",{oDet},oDet)					
							
							If Type("oXml:_NFEPROC:_NFE:_INFNFE:_DET") == "A"		
								aItem := oXml:_NFEPROC:_NFE:_INFNFE:_DET			
							Else		
								aItem := {oXml:_NFEPROC:_NFE:_INFNFE:_DET}			
							EndIf 
						
						Else
							
							//If type("oXml:_CTEPROC:_CTE:_INFCTE:_VPREST") <> "U"
								oDet := oXml:_CTEPROC:_CTE:_INFCTE:_VPREST
							//Endif
							
							nPrest := 0
							If valtype(oDet:_VTPREST:TEXT) <> "U"
								nPrest := ( VAL(oDet:_VTPREST:TEXT) )  //Valor da PrestaÁ„o do SeviÁo que  ira ser rateado pelos DOCs que compıe o CTE
							Endif 
						
						Endif 
						
						cNcm := "" 

						If cModel <> "57"
							For i := 1 To Len(oDet)	
								
								
								cNcm	  := Alltrim(oDet[i]:_Prod:_NCM:TEXT)							
								cProdXml  := Alltrim(oDet[i]:_Prod:_CPROD:TEXT)
								
								If GetNewPar("XM_PESQNCM" , "1") == "1" //1-localiza a NCM e traz qualquer cÛdigo que encontrar com a NCM; 2-Localiza B1_COD = B1_POSIPI
									//Procura na SB1 , algum produto com a ncm, o primeiro produto que localizar com a NCM, assume
									cProduto  := U_fVerSB1N(cNcm) 
								Else
									//Procura na SB1 um produto cujo cÛdigo B1_COD = NCM , isso mesmo, B1_COD = NCM a Kitchens cadastra o cÛdigo do produto igual a NCM
									cProduto := U_fVerB1_NCM(cNcm)
								Endif 				
								
								//FR - 25/03/2022 - ALTERA«√O - KITCHENS - j· incluso acima a tratativa para cadastrar produto caso n„o exista na SB1 ent„o quando chega aqui j· tem o cÛdigo
								
								If !Empty(cProduto) 
								
								    DbSelectArea("SB1")
									SB1->(OrdSetFocus(1))
									SB1->(Dbseek(xFilial("SB1") + cProduto))  
										cDescProd := SB1->B1_DESC
									
									If FieldPos("B1_MSBLQL") > 0
										If SB1->B1_MSBLQL == "1"
											//produto bloqueado
											lProssegue := .F. 
											lSB1BLOQ   := .T. 
											Aadd(aBloqSB1, cProduto)
										Endif 
									Endif 									 
									
									nQuant := VAL(oDet[i]:_Prod:_QCOM:TEXT)
									nVunit := VAL(oDet[i]:_Prod:_VUNCOM:TEXT)
									nTotal := VAL(oDet[i]:_Prod:_VPROD:TEXT) 
									
									aLinha := {}
									aadd(aLinha,{"C7_PRODUTO" 	,cProduto	,Nil})
									aadd(aLinha,{"C7_QUANT" 	,nQuant 	,Nil})
									aadd(aLinha,{"C7_PRECO" 	,nVunit 	,Nil})
									aadd(aLinha,{"C7_TOTAL" 	,nTotal		,Nil})
									//aadd(aLinha,{"C7_OBS"       ,cObs       ,Nil})
									aadd(aLinha,{"C7_OBSM"       ,cObs       ,Nil})		//DEU CERTO AQUI O CPO MEMO
									aadd(aLinha,{"C7_CC"        ,cCusto     ,Nil})
									
									//FR - 25/03/2022 - ALTERA«√O - KITCHENS
									//Gravar Item cont·bil
									If !Empty(cItContab)
										aadd(aLinha,{"C7_ITEMCTA"        ,cItContab     ,Nil})
									Endif
									
									DbSelectArea("SC7")
									//Gravar Solicitante
									If FieldPos("C7_XSOLICI") > 0
										aadd(aLinha,{"C7_XSOLICI"        ,cSolici     ,Nil})
									Endif 
									
									//Gravar Data Vencimento
									If FieldPos("C7_XDVENC") > 0
										aadd(aLinha,{"C7_XDVENC"        ,dVenc     ,Nil})
									Endif   
									//FR - 25/03/2022 - ALTERA«√O - KITCHENS 
									
									aadd(aItens,aLinha) 
									
									Aadd(aZBT , { cProdXml, Strzero(i,4),"",cProduto, "" } )   //produto fornecedor, item, reservado para num pc, produto interno
									
								Else 
									MsgAlert(cProduto + " -> Produto N„o Localizado no Cadastro ou Produto Bloqueado !!!")
									Return
								Endif 
							
							Next i
						
						Else //modelo 57 - CTE
							
							cProduto := cProdCte
							nQuant   := 1
							nVunit   := nPrest
							nTotal   := nPrest * nQuant
							i        := 1  //numero do item
							
							SB1->(OrdSetFocus(1))
							SB1->(Dbseek(xFilial("SB1") + cProduto))  
							cDescProd := SB1->B1_DESC

							If FieldPos("B1_MSBLQL") > 0
								If SB1->B1_MSBLQL == "1"
									//produto bloqueado
									lProssegue := .F. 
									lSB1BLOQ   := .T. 
									Aadd(aBloqSB1, cProduto)
								Endif 
							Endif 
							aLinha := {}
							aadd(aLinha,{"C7_PRODUTO" 	,cProduto	,Nil})
							aadd(aLinha,{"C7_QUANT" 	,nQuant 	,Nil})
							aadd(aLinha,{"C7_PRECO" 	,nVunit 	,Nil})
							aadd(aLinha,{"C7_TOTAL" 	,nTotal		,Nil})
							aadd(aLinha,{"C7_OBSM"       ,cObs       ,Nil})		//DEU CERTO AQUI O CPO MEMO
							aadd(aLinha,{"C7_CC"        ,cCusto     ,Nil})
									
							//FR - 25/03/2022 - ALTERA«√O - KITCHENS
							//Gravar Item cont·bil
							If !Empty(cItContab)
								aadd(aLinha,{"C7_ITEMCTA"        ,cItContab     ,Nil})
							Endif
									
							DbSelectArea("SC7")
							//Gravar Solicitante
							If FieldPos("C7_XSOLICI") > 0
								aadd(aLinha,{"C7_XSOLICI"        ,cSolici     ,Nil})
							Endif 
									
							//Gravar Data Vencimento
							If FieldPos("C7_XDVENC") > 0
								aadd(aLinha,{"C7_XDVENC"        ,dVenc     ,Nil})
							Endif   
							//FR - 25/03/2022 - ALTERA«√O - KITCHENS 
									
							aadd(aItens,aLinha) 
									
							Aadd(aZBT , { cProdCte, Strzero(i,4),"",cProduto,cChaveZBZ } )   //produto fornecedor, item, reservado para num pc, produto interno, chave zbz						  
							
						Endif 
					Else
						
						cProduto  := ""
						If XmlChildEx(oXml:_NFSETXT:_INFPROC,"_PRODSRV") <> NIL			//Checagem se tem a tag (oDet[i]:_Prod,"_Rastro") <> nil 				
							cProdXml  := oXml:_NFSETXT:_INFPROC:_PRODSRV:TEXT  //Alltrim(oDet[i]:_Prod:_CPROD:TEXT) 
						Else  		//se n„o tiver a tag, cria um paliativo, porque È nf serviÁo mesmo
							cProdXml   := "SERVICO"
							cDescrProd := "SERVICO"
						Endif 				
						
						cProduto  := U_fVerSA5(cProdXml,cCodEmit,cLojaEmit)
						nQuant    := 1
						nVunit    := Val(oXml:_NFSETXT:_INFPROC:_VRSERV:TEXT)
						nTotal    := nVunit
						
						//procurar amarraÁ„o na SA5
						//cProduto := oXml:_NFSETXT:_INFPROC:_PRODSRV:TEXT
						
						If !Empty(cProduto)
							SB1->(OrdSetFocus(1))
							SB1->(Dbseek(xFilial("SB1") + cProduto))  
							cDescProd := SB1->B1_DESC

							If FieldPos("B1_MSBLQL") > 0
								If SB1->B1_MSBLQL == "1"
									//produto bloqueado
									lProssegue := .F. 
									lSB1BLOQ   := .T. 
									Aadd(aBloqSB1, cProduto)
								Endif 
							Endif 
							aLinha := {}
							aadd(aLinha,{"C7_PRODUTO" 	,cProduto			,Nil})
							aadd(aLinha,{"C7_QUANT" 	,nQuant 			,Nil})
							aadd(aLinha,{"C7_PRECO" 	,nVunit 			,Nil})
							aadd(aLinha,{"C7_TOTAL" 	,nTotal				,Nil})
							//aadd(aLinha,{"C7_OBS"       ,Alltrim(cObs)     	,Nil})
							aadd(aLinha,{"C7_OBSM"       ,Alltrim(cObs)     	,Nil})   //DEU CERTO AQUI O CPO MEMO
							aadd(aLinha,{"C7_CC"        ,cCusto     		,Nil}) 
							
							//FR - 25/03/2022 - ALTERA«√O - KITCHENS
							//Gravar Item cont·bil
							If !Empty(cItContab)
								aadd(aLinha,{"C7_ITEMCTA"        ,cItContab     ,Nil})
							Endif
								
							//Gravar Solicitante 
							DbSelectArea("SC7")
							If FieldPos("C7_XSOLICI") > 0
								aadd(aLinha,{"C7_XSOLICI"        ,cSolici     ,Nil})
							Endif 
								
							//Gravar Data Vencimento
							If FieldPos("C7_XDVENC") > 0
								aadd(aLinha,{"C7_XDVENC"        ,dVenc     ,Nil})
							Endif   
							//FR - 25/03/2022 - ALTERA«√O - KITCHENS 
							
							aadd(aItens,aLinha) 
							
							Aadd(aZBT , { cProdXml, "0001","",cProduto, "" } )   //produto fornecedor, item, reservado para num pc , produto interno, chave zbz
							
						Else
							MsgAlert("Produto N„o Localizado no Cadastro de AmarraÁ„o Padr„o (SA5) !!!")
							Return			 
						
						Endif 
						
					Endif		
					
					//aqui segue normal tanto pra nfe qto nfse:
					If Len(aItens) > 0
						//Teste de Inclus„o
						cNUMPC := GetSXENum("SC7","C7_NUM")
						
						SC7->(dbSetOrder(1))
						While SC7->(dbSeek(xFilial("SC7")+cNUMPC))
							ConfirmSX8()
							cNUMPC := GetSXENum("SC7","C7_NUM")
						EndDo
						
						aadd(aCabec,{"C7_NUM" ,cNUMPC})
						aadd(aCabec,{"C7_EMISSAO" ,dDataBase})
						aadd(aCabec,{"C7_FORNECE" ,cCodEmit})
						aadd(aCabec,{"C7_LOJA" ,cLojaEmit})
						aadd(aCabec,{"C7_COND" ,cCondPg})
						aadd(aCabec,{"C7_CONTATO" ,"AUTO"})
						aadd(aCabec,{"C7_FILENT" ,cFilAnt})		
				
						aRatCC := {}
						aRatPrj:= {}
						nOpc   := 3 
						
						If lProssegue 
							Processa( {|| MSExecAuto({|a,b,c,d,e,f,g| MATA120(a,b,c,d,e,f,,g)},1,aCabec,aItens,nOpc,.F.,aRatCC,aRatPrj) }, "Aguarde...", "Processamento PC...",.F.) 
							
							If !lMsErroAuto

								For i := 1 to Len(aZBT)  
									aZBT[i,3] := cNUMPC
								Next
								
								//Limpa da ZBT o pedido anterior (caso haja)
								DbSelectArea(xZBT)
								(xZBT)->(OrdSetFocus(2))  //ZBT_CHAVE
								If (xZBT)->(Dbseek(cChave))
									While (xZBT)->(!Eof()) .and. Alltrim((xZBT)->(FieldGet(FieldPos(xZBT_+"CHAVE")))) == Alltrim(cChave)
										
										If !Empty( Alltrim((xZBT)->(FieldGet(FieldPos(xZBT_+"PEDIDO"))) )  )
											RecLock((xZBT),.F.)	

											(xZBT)->(FieldPut(FieldPos(xZBT_+"PEDIDO"), "" ))		
											(xZBT)->(FieldPut(FieldPos(xZBT_+"ITEMPC"), "" ))		 
											(xZBT)->(FieldPut(FieldPos(xZBT_+"DEPARA"), "" ))

											DbSelectArea(xZBT)
											MsUnLock()
											
										Endif 
										(xZBT)->(Dbskip())
									Enddo
									
								Endif

								//Grava ZBT numero pedido
								aSort( aZBT,,, { |x,y| x[2] < y[2] } )  //ordena pelo item

								DbSelectArea(xZBT)
								(xZBT)->(OrdSetFocus(2))  //ZBT_CHAVE
								If (xZBT)->(Dbseek(cChave))
									While (xZBT)->(!Eof()) .and. Alltrim((xZBT)->(FieldGet(FieldPos(xZBT_+"CHAVE")))) == Alltrim(cChave)
										
										For i := 1 to Len(aZBT) 
											If Alltrim( (xZBT)->(FieldGet(FieldPos(xZBT_+"PRODUT"))) ) == Alltrim(aZBT[i,1]);
											.and. Alltrim((xZBT)->(FieldGet(FieldPos(xZBT_+"ITEM"))) ) == Alltrim(aZBT[i,2])
										
												RecLock((xZBT),.F.)	

												(xZBT)->(FieldPut(FieldPos(xZBT_+"PEDIDO"), aZBT[i,3] ))		
												(xZBT)->(FieldPut(FieldPos(xZBT_+"ITEMPC"), aZBT[i,2] ))		 
												(xZBT)->(FieldPut(FieldPos(xZBT_+"DEPARA"), aZBT[i,4] ))
												
												DbSelectArea(xZBT)
												MsUnLock()
											Endif
										Next i 

										(xZBT)->(Dbskip())

									Enddo
									
								Endif						
								
								DbSelectArea("SC7")
								SC7->(OrdSetFocus(1))
								If SC7->(Dbseek(xFilial("SC7") + cNUMPC ))
									While SC7->(!Eof()) .and. SC7->C7_FILIAL == xFilial("SC7") .and. SC7->C7_NUM == cNUMPC
										RecLock("SC7",.F.)
										SC7->C7_OBS := Alltrim(cObs) 
										//MSMM(,,,cObs,1,,,'SC7','C7_OBSM')   //para gravar
										SC7->(MsUnlock())
										
										SC7->(Dbskip())	
									Enddo				
								Endif

								lGerouSC7 := .T. //gerou o PC

								//MsgINfo("Incluido PC: " + cNUMPC) 
								
								/*
								cMemo := MSMM (cChave,nTam,nLin,cString,nOpc,nTabSize,lWrap,cAlias,cCpochave)onde:
								cMemo......: Conteudo retornado, quando leitura. Se o campo chave nao existir, retorna " ".
								cChave.....: Chave de acesso ao SYP. Deve ser informada na alteracao e exclusao.
								nTam.......: 'Largura' do campo memo.
								nLin.......: Linha do SYP (YP_SEQ) a ser retornada na leitura. Se nao informado, retorna todas.
								cString....: Conteudo a ser gravado na inclusao ou alteracao.
								nOpc.......: 1=gravar (inc/alt); 2=excluir; 3=leitura (default).
								nTabSize...: Nao usado.
								lWrap......: Nao usado.
								cAlias.....: Alias do arquivo onde encontra-se o campo chave. Deve ser informado na inclusao e alteracao.
								cCpoChave..: Campo pertencente `a tabela cAlias e que vai conter a chave de acesso ao SYP.
								*/

							Else
								ConOut("Erro na inclusao!")
								MostraErro()
							EndIf

						Else  //lProssegue = .F. n„o continua 
							//ver se houve bloqueio de SB1
							If lSB1BLOQ
								cPrdBloq := ""

								For x := 1 to Len(aBloqSB1)
									cPrdBloq += CRLF + aBloqSB1[x] 
								Next 

								MsgAlert("Existe(m) Produto(s) Bloqueado(s) No Cadastro de Produto SB1:" + CRLF + cPrdbloq)
							Endif 
						Endif //lProssegue

					Endif
					
					If lProssegue 
						If lCopiou //o anexo que foi inserido na tela				
							//grava informaÁıes no bco conhecimento
							fAnexaBco(cArq      ,cNUMPC )					
						Endif
								
						If lCopiouD  //o anexo da nf - danfe  
							//grava informaÁıes no bco conhecimento
							fAnexaBco(cArqDanfe , cNUMPC)  
						Endif
						
						If lGerouSC7
							MsgINfo("Incluido PC: " + cNUMPC) 
						Endif
					Endif  
											
					
				Else
					MsgAlert("OperaÁ„o Cancelada Pelo Usu·rio")
				Endif //lProssegue
				
			Else 
				MsgAlert("OperaÁ„o Cancelada Pelo Usu·rio")
			Endif		//lProssegue
		Endif  //lProssegue
	Endif
Endif //lProssegue
RestArea(aArea) 

Return

//chama Danfe
//---------------------------------------------------------------//
//chama rotina de impress„o DANFE 
//---------------------------------------------------------------//
Static Function fGerDanfe(cDirDanfe,cArqDanfe)
Local lGerouDanfe := .F. 
Local nTam        := 0 
Local aLISTA      := {}
Local nErase	  := 0
Local nTentativas := 0
Local oSetup
Local oDanfe
Local cIdent     := ""
Local lAutoDanfe := .T.
Local cFilePrint := ""
Local lAuto      := .F.
Local nFlags     := 0
Local aDevice  := {}
Local cSession     := GetPrinterSession()

nErase     := 0
nTentativas:= 0

			
U_XMLPRTdoc(.T.,cDirDanfe,cArqDanfe) //User Function XMLPRTdoc(lAutoDanfe) 
				
//checagem se gerou o pdf na pasta local (maquina usu·rio):
If File(cDirDanfe + cArqDanfe)
				
	//SE encontrou o arquivo, verifica o tamanho: aLISTA := DIRECTORY( cDirDanfe + "*.PDF", <ATRIBUTOS> , <COMPATIB>/ , .T. <MAIUSCULO> )
	nTAM   := 0
	aLISTA := DIRECTORY( cDirDanfe + "*.PDF")
	nPOS   := ASCAN(aLISTA,{|X| ALLTRIM(X[1])==cArqDanfe })
	IF nPOS > 0
	   nTAM := aLISTA[nPOS,2]
	ENDIF
				
	If nTAM <= 0
					
		lGerouDanfe := .F.
		//MsgAlert("DANFE PDF n„o gravou na pasta") 
		nErase := FErase(cDirDanfe + cArqDanfe)
		If nErase < 0
			//cLogProc += "(EM USO) Nao foi possivel remover o arquivo ["+cArq+"]"+CRLF
			conout("<GESTAOXML> HFXML08 - NAO FOI POSSIVEL REMOVER O ARQUIVO -> " + cDirDanfe + cArqDanfe)
		EndIf
		
	Else
		lGerouDanfe := .T.
		//MsgInfo("PDF OK")
	Endif		
			
Else 
	//MsgAlert("PDF n„o gravou na pasta") 
	lGerouDanfe := .F.			
Endif
	
		
Return(lGerouDanfe)
//fim chama Danfe

//-------------------------------------------------------------------------------//
//FunÁ„o para selecionar um arquivo para anexar ao processo do pedido de compra
//-------------------------------------------------------------------------------//
Static Function AbreArq()
Local aArea := GetArea() 
Local cTipo      := ""
//Local cDir     := AllTrim(SuperGetMv("MV_X_PATHX"))
//Local cDirFis  := ""
//Local cDirCbs  := ""

//cTipo	:= "Arquivo Texto (*.txt) | *.txt  | "                     // + GETF_NOCHANGEDIR
cTipo	+= "Todos Arquivos        | *.*    | "

//cArqOri := UPPER(cGetFile(cTipo,"Selecione o arquivo para classificaÁ„o(*.*)",,cDir,.T.,GETF_LOCALHARD,.F.)) //GETF_NETWORKDRIVE 
cArqOri := UPPER(cGetFile(cTipo,"Selecione o arquivo para classificaÁ„o(*.*)",,"C:\",.T.,GETF_LOCALHARD,.F.)) //GETF_NETWORKDRIVE 
//               cGetFile(cTipo,"Selecione o arquivo"                        ,,"C:\",,GETF_NETWORKDRIVE+GETF_LOCALHARD,.F. )

RestArea(aArea)

Return()

//--------------------------------------------------------------//
//FunÁ„o  : fAnexaBco
//Objetivo: Cria registros nas tabelas do banco de conhecimento
//Autoria : Fl·via Rocha
//Data    : 31/03/2022
//--------------------------------------------------------------//
Static Function fAnexaBco(cArq,cNUMPC)        //cArq = nome do arquivo.extens„o , cNUMPC = Numero do pedido de compra + item (0001)
Local cProxObj := ""
Local cCodent  := ""
Local lAnexou  := .F.
Local aArea := GetArea() 

/*
//CRIANDO BANCO DE CONHECIMENTO MANUALMENTE:
ACB - 
ACB_CODOBJ - 0000000001
ACB_OBJETO - FARMACIABOLETO.PDF
ACB_DESCRI - TESTE 000110657 - FR
				
PARA CRIAR OS REGISTROS, COPIAR TAMB…M PARA A SEGUINTE PASTA:
OS ARQUIVOS FISICOS PRECISAM EXISTIR AQUI:
D:\PROTHEUS12\Protheus_R25\protheus_data\dirdoc\co99\shared
				
				
AC9 - 
AC9_FILIAL - VAZIO
AC9_FILENT - 01
AC9_ENTIDA - SC7 (alias da tabela a qual queremos criar o registro no bco conhecimento, SC7 se for no pedido compra, SF1 se for na nota entrada)
AC9_CODENT - NUMERO NF + SERIE + COD FORNECEDOR+ LOJA
AC9_CODOBJ - 0000000001 (10 CARACTERES)
*/
				
//grava ACB - Cadastro de objetos
//Verifica se o objeto j· existe na ACB, sen„o, cria:
cProxObj := ""

DbSelectArea("ACB") 
ACB->(OrdSetFocus(2))
If !ACB->(Dbseek(xFilial("ACB") + Alltrim(cArq) )) 
	cProxObj := fProxACB()
	RecLock("ACB",.T.) 
	
	ACB->ACB_FILIAL := xFilial("ACB")
	ACB->ACB_CODOBJ := cProxObj
	ACB->ACB_OBJETO := cArq
	ACB->ACB_DESCRI := cArq
	
	ACB->(MsUnlock())
Else
	cProxObj := ACB->ACB_CODOBJ  //se encontrou, pega o cÛdigo do objeto		
Endif					
					
cCodent := 	cFilant + cNUMPC + "0001" //numero pc + item 
				
//grava AC9
DbSelectArea("AC9")
AC9->(OrdSetFocus(1)) //AC9_FILIAL+AC9_CODOBJ+AC9_ENTIDA+AC9_FILENT+AC9_CODENT
If !AC9->(Dbseek(xFilial("AC9") + cProxObj + "SC7" + cFilAnt + cCodent)) 
	RecLock("AC9",.T.) 
	
	AC9->AC9_FILIAL := xFilial("AC9")
	AC9->AC9_FILENT := cFilAnt
	AC9->AC9_ENTIDA := "SC7"
	AC9->AC9_CODENT := cCodent
	AC9->AC9_CODOBJ := cProxObj
	
	AC9->(MsUnlock())
	lAnexou := .T.
	
Endif 

RestArea(aArea)

Return(lAnexou)


//GRAVA«’ES ADICIONAIS:
//--------------------------------------------------------------//
//FunÁ„o  : fGravZBTPC
//Objetivo:Grava numero do pedido e item do pedido na ZBT
//Autoria : Fl·via Rocha
//Data    : 08/12/2021
//--------------------------------------------------------------//
Static Function fGravZBTPC(cProdForn,cIt,cPC,cProdInt,cChaveZBZ)
Local cQuery := ""
Local i      := 0
Local nRec   := 0 
Local aArea  := GetArea()

If Empty(cChaveZBZ)
	cQuery += " SELECT " 
	cQuery += " " + xZBT_+"PRODUT , " 
	cQuery += " " + xZBT_+"ITEM   , " 
	cQuery += " R_E_C_N_O_ AS RECZBT FROM " + RetSqlname(xZBT) + " ZBT "
	cQuery += " WHERE RTRIM(" + xZBT+"_PRODUT) = '" + Alltrim(cProdForn) + "' "
	cQuery += " AND   RTRIM(" + xZBT+"_ITEM  ) = '" + Alltrim(cIt) + "' "
	cQuery += " AND ZBT.D_E_L_E_T_ <> '*' "
Else
	cQuery += " SELECT " 
	cQuery += " " + xZBT_+"PRODUT , " 
	cQuery += " " + xZBT_+"ITEM   , " 
	cQuery += " R_E_C_N_O_ AS RECZBT FROM " + RetSqlname(xZBT) + " ZBT "
	cQuery += " WHERE RTRIM(" + xZBT+"_CHAVE) = '" + Alltrim(cChaveZBZ) + "' "
	cQuery += " AND ZBT.D_E_L_E_T_ <> '*' "
Endif 

MemoWrite("C:\TEMP\fVerZBT.sql" , cQuery)
	
cQuery := ChangeQuery( cQuery )		
	
If Select("TMPXXX") > 0
	dbSelectArea("TMPXXX")
	TMPXXX->(dbCloseArea())
EndIf
	
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPXXX", .T., .F. )
DbSelectArea("TMPXXX")
DbGoTop() 

If TMPXXX->(!Eof()) 
	If Empty(cChaveZBZ) //se nao foi informada chave , sÛ grava o pedido/item no item respectivo na ZBT
		
		nRec := TMPXXX->RECZBT		
			
		DbSelectArea(xZBT)
		(xZBT)->(Dbgoto(nRec))	//ZBT_FILIAL+ZBT_PRODUT+ZBT_PEDIDO+ZBT_ITEMPC
		RecLock(xZBT,.F.)
		(xZBT)->(FieldPut(FieldPos(xZBT_+"PEDIDO"), cPc ))		
		(xZBT)->(FieldPut(FieldPos(xZBT_+"ITEMPC"), cIt ))		 
		(xZBT)->(FieldPut(FieldPos(xZBT_+"DEPARA"), cProdInt ))
		(xZBT)->( MsUnlock() )    
		
		
	Else    //se foi informada chave, È porque È CTe e nesse caso o que linka ZBZ e ZBT È a chave da nota, ent„o grava para qtos registros existirem na ZBT
	
		While TMPXXX->(!Eof())
		
			nRec := TMPXXX->RECZBT		
			
			DbSelectArea(xZBT)
			(xZBT)->(Dbgoto(nRec))	//ZBT_FILIAL+ZBT_PRODUT+ZBT_PEDIDO+ZBT_ITEMPC
			RecLock(xZBT,.F.)
			(xZBT)->(FieldPut(FieldPos(xZBT_+"PEDIDO"), cPc ))		
			(xZBT)->(FieldPut(FieldPos(xZBT_+"ITEMPC"), cIt ))		 
			(xZBT)->(FieldPut(FieldPos(xZBT_+"DEPARA"), cProdInt ))
			(xZBT)->( MsUnlock() ) 
		    
			DbSelectArea("TMPXXX")
			TMPXXX->(Dbskip())
		Enddo
		
	Endif 
	
Endif 

RestArea(aArea) 

Return

//GRAVA«’ES ADICIONAIS: 

//----------------------//
//VALIDA«’ES DA TELA:
//----------------------//

//--------------------------------------------------------------//
//Valida campo Solicitante da tela de geraÁ„o autom·tica PC
//Autoria: Fl·via Rocha
//Data   : 19/03/2022
//--------------------------------------------------------------//
Static Function fValSolici(cSolici)
Local lOK   := .F.
Local aArea := GetArea() 
Local cUserName := ""  
local cUserCod  := ""
Local aUserData := {}

//If Empty(cSolici)  
//	Alert("Por favor, Preencha Solicitante") 
//	lOK := .F.
//Endif 

If !Empty(cSolici)
		
		DbSelectArea("SAI")	
		SAI->(Ordsetfocus(2))   //AI_FILIAL + AI_USER
		//If SAI->(Dbseek(xFilial("SAI") + cUserCod))
		If SAI->(Dbseek(xFilial("SAI") + cSolici))
				lOK := .T.				
		Else 
			Alert("Solicitante N„o Localizado!")	
		Endif
	 
Else 
	Alert("Por Favor, Preencha o Solicitante")
	lOK := .F.
Endif 

RestArea(aArea)

Return(lOK) 


//--------------------------------------------------------------//
//Valida campo Centro Custo da tela de geraÁ„o autom·tica PC
//Autoria: Fl·via Rocha
//Data   : 09/12/2021
//--------------------------------------------------------------//
Static Function fValCC(xCusto)
Local lOK   := .T. 
Local aArea := GetArea()

DbSelectArea("CTT")

If !Empty(xCusto)
	CTT->(Ordsetfocus(1))
	If CTT->(Dbseek(xFilial("CTT") + xCusto)) 
		If FieldPos("CTT_BLOQ") > 0		
			If CTT->CTT_BLOQ = "1"  //bloqueado sim
				lOK := .F.
				Alert("Centro Custo Bloqueado no Cadastro")
			Endif
		Else
			//If CTT->CTT_ACITEM == "1" //se o centro de custo aceitar item
			//If CTT->CTT_ITOBRG == "1"   //se o centro de custo obrigar o uso do item -> Item Obrigat, 
				//lITObrig := .T.	
			//Endif 
		Endif	
	Else
		MsgAlert("Centro Custo N„o Cadastrado")
		lOK := .F.
	Endif
Else 
	MsgAlert("Necess·rio Preencher Centro de Custo")
	lOK := .F.
Endif


RestArea(aArea)

Return(lOK)

//--------------------------------------------------------------//
//Valida campo Centro Custo da tela de geraÁ„o autom·tica PC
//Autoria: Fl·via Rocha
//Data   : 09/12/2021
//--------------------------------------------------------------//
Static Function fValITC(xCusto,cItContab)
Local lOK   := .T. 
Local aArea := GetArea()
Local lITObrig := .F.


DbselectArea("CTD")
CTD->(OrdSetFocus(1)) 		//CTD_FILIAL+CTD_ITEM 

If !Empty(cItContab)			
	If CTD->(Dbseek(xFilial("CTD") + cItContab )) 
		If CTD->CTD_BLOQ == "1"  //1=Bloqueado;2=No Bloqueado 
			lOK := .F.
			Alert("Item Cont·bil Bloqueado no Cadastro")
		Endif 
	Else
		lOK := .F.
		Alert("Item Cont·bil N„o Localizado") 
	Endif
Endif 

DbSelectArea("CTT")

If !Empty(xCusto)
	CTT->(Ordsetfocus(1))
	If CTT->(Dbseek(xFilial("CTT") + xCusto)) 
		If FieldPos("CTT_BLOQ") > 0		
			If CTT->CTT_BLOQ = "1"  //bloqueado sim
				lOK := .F.
				Alert("Centro Custo Bloqueado no Cadastro")
			Else 
				If CTT->CTT_ITOBRG == "1"   //se o centro de custo obrigar o uso do item -> Item Obrigat, 
					lITObrig := .T.	
				Endif
			Endif
		Else
			//If CTT->CTT_ACITEM == "1" //se o centro de custo aceitar item
			If CTT->CTT_ITOBRG == "1"   //se o centro de custo obrigar o uso do item -> Item Obrigat, 
				lITObrig := .T.	
			Endif 
		Endif	
	Else
		MsgAlert("Centro Custo N„o Localizado")
		lOK := .F.
	Endif
//Else 
//	MsgAlert("Necess·rio Preencher Centro de Custo")
//	lOK := .F.
Endif

If lITObrig  //se item cont·bil for obrigatÛrio

	If Empty(cItContab)
		Alert("Item Cont·bil ObrigatÛrio para o Centro de Custo")  
		lOK := .F.
	Else 
		DbselectArea("CTD")
		CTD->(OrdSetFocus(1)) 		//CTD_FILIAL+CTD_ITEM 
				
		If CTD->(Dbseek(xFilial("CTD") + cItContab )) 
			If CTD->CTD_BLOQ == "1"  //1=Bloqueado;2=No Bloqueado 
				lOK := .F.
				Alert("Item Cont·bil Bloqueado no Cadastro")
			Endif 
		Else
			lOK := .F.
			Alert("Item Cont·bil N„o Localizado") 
		Endif

	Endif 
Endif 


RestArea(aArea)

Return(lOK)



//--------------------------------------------------------------//
//Valida campo CondiÁ„o Pagto da tela de geraÁ„o autom·tica PC
//Autoria: Fl·via Rocha
//Data   : 28/06/2021
//--------------------------------------------------------------//
Static Function fValCond(xCond)
Local lOK   := .T.
Local aArea := GetArea() 


DbSelectArea("SE4")

If !Empty(xCond)
	SE4->(Ordsetfocus(1))
	If SE4->(Dbseek(xFilial("SE4") + xCond)) 
		If FieldPos("E4_MSBLQL") > 0		
			If SE4->E4_MSBLQL = "1"  //bloqueado sim
				lOK := .F.
				Alert("CondiÁ„o Pagto bloqueada no cadastro")
			Endif
		Endif	
	Else
		MsgAlert("CondiÁ„o Pagto N„o Cadastrada!")
		lOK := .F.
	Endif
Else

	MsgAlert("Necess·rio Preencher Cond.Pagto")
	lOK := .F.
Endif

RestArea(aArea)

Return(lOK) 

//--------------------------------------------------------------//
//Valida a data vencimento digitada
//Autoria: Fl·via Rocha
//Data   : 15/03/2022
//--------------------------------------------------------------//
Static Function fValdVenc(dVenc)
Local lOK   := .T. 
Local aArea := GetArea()

If !Empty(dVenc)

	If dVenc < dDatabase
		lOK := .F.
		Alert("Data Digitada Menor que Database")
	Endif
	
Else 
	MsgAlert("Necess·rio Preencher Dt.Vencimento")
	lOK := .F.
Endif

RestArea(aArea)

Return(lOK)    


//--------------------------------------------------------------//
//Valida campo Arquivo Anexo 
//Autoria: Fl·via Rocha
//Data   : 31/03/2022
//--------------------------------------------------------------//
Static Function fValTudo(cArqOri,dVenc,xCond,xCusto,cSolici,cItContab)
Local lOK   := .T.
Local cMsgAlert := ""
Local cUsaVenc   := GetNewPar("XM_KITVENC" , "N") //habilita o uso do campo Dt. Vencimento na tela gera pedido compra  

If lOk 
	If Empty(xCond)  
		//Alert("Por favor, Preencha CondiÁ„o Pagto")   
		cMsgAlert += CRLF + "Por favor, Preencha CondiÁ„o Pagto"
		lOK := .F.
	Else 
		lOK := fValCond(xCond)
	Endif
Endif

If cUsaVenc   == "S"
	If Empty(dVenc)  
		//Alert("Por favor, Preencha Data Vencimento")  
	   	cMsgAlert += CRLF + "Por favor, Preencha Data Vencimento"
		lOK := .F.
	Else 
		lOK := fValdVenc(dVenc)
	Endif
Endif 

If lOK
	If Empty(xCusto)  
		//Alert("Por favor, Preencha Centro de Custo") 
		cMsgAlert += CRLF + "Por favor, Preencha Centro de Custo"
		lOK := .F.
	Else 
		lOK := fValCC(xCusto)
	Endif
Endif 

If lOk 
	lOK := fValITC(xCusto,cItContab)
Endif

If lOK 

	If Empty(cSolici)  
		//Alert("Por favor, Preencha Solicitante") 
		cMsgAlert += CRLF + "Por favor, Preencha Solicitante"
		lOK := .F.
	Else
		lOK := fValSolici(cSolici)
	Endif 

Endif 

//se n„o tiver sido anexado nenhum arquivo, pergunta se quer continuar mesmo assim
//por default j· È anexado o danfe, mas o usu·rio pode querer anexar algum documento a mais
If lOK
	If Empty(cArqOri)
		If MsgYesNo("Nenhum documento anexado alÈm da NF," + CRLF + "Deseja continuar?") // (Se SIM, salvar o documento, N„o retornar para a tela anterior) 
			lOK := .T.
		Else
			lOK := .F.
		Endif
	Else 
		lOK := .T.
	Endif 

Else
	If !Empty(cMsgAlert) 
		U_MyAviso("ATEN«√O",cMsgAlert,{"OK"},3)
	Endif 
Endif 

Return(lOK) 

//--------------------------------------------------------------//
//Valida campo Natureza da tela de geraÁ„o autom·tica PC
//Autoria: Fl·via Rocha
//Data   : 28/06/2021
//--------------------------------------------------------------//
Static Function fValNAT(xNAT)
Local lOK   := .T.
Local aArea := GetArea()

DbSelectArea("SED")

If !Empty(xNAT)
	SED->(Ordsetfocus(1))
	If SED->(Dbseek(xFilial("SED") + xNAT))
		If FieldPos("ED_MSBLQL") > 0	
			If SED->ED_MSBLQL = "1"  //bloqueado sim
				lOK := .F.
				Alert("Natureza bloqueada no cadastro")
			Endif
		Endif	
	Else
		MsgAlert("Natureza N„o Cadastrada!")
		lOK := .F.
	Endif
Endif

RestArea(aArea)

Return(lOK) 

//----------------------//
//FIM VALIDA«’ES DA TELA:
//----------------------//


//------------------------------------------------------------------//
//FunÁ„o  : fVerTemC7
//Objetivo: Verificar se o pedido que est· na ZBT_PEDIDO existe na SC7
//Autoria : Fl·via Rocha
//Data    : 10/05/2022
//------------------------------------------------------------------//
Static Function fTemC7(cPC,cFili)
Local cQuery := ""
Local aArea  := GetArea()
Local lTemC7 := .F.

cQuery += " SELECT " 
cQuery += " C7_FILIAL, C7_NUM, C7_PRODUTO, C7_ITEM  " 
cQuery += " FROM " + RetSqlname("SC7") + " SC7 "
cQuery += " WHERE SC7.D_E_L_E_T_ <> '*' "
cQuery += " AND SC7.C7_NUM = '" + Alltrim(cPC) + "' "
cQuery += " AND SC7.C7_FILIAL = '" + Alltrim(cFili) + "' "

MemoWrite("C:\TEMP\fVerSC7.sql" , cQuery)
	
cQuery := ChangeQuery( cQuery )		
	
If Select("TMPXXX") > 0
	dbSelectArea("TMPXXX")
	TMPXXX->(dbCloseArea())
EndIf
	
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPXXX", .T., .F. )
DbSelectArea("TMPXXX")
DbGoTop() 

If TMPXXX->(!Eof()) 
	lTemC7 := .T.		
Endif 

RestArea(aArea) 

Return(lTemC7)


//A5_FILIAL+A5_CODPRF+A5_PRODUTO+A5_FABR+A5_FORNECE                                                                                                               
//----------------------------------------------------------------------------------//
//FunÁ„o : fVerSA5
//Autoria: Fl·via Rocha
//Data   : 09/12/2021
//Objetivo: funÁ„o que recebe o produto fornecedor e verifica correspondente na SA5
//          retornando o cÛdigo interno (SB1)
//----------------------------------------------------------------------------------//
User Function fVerSA5(cProdF,cForn,cLoj) 
Local cQuery    := ""
Local cCodProd  := ""
Local aArea     := GetArea()

cQuery += " SELECT A5_FORNECE, A5_LOJA, A5_NOMEFOR, A5_PRODUTO, A5_CODPRF FROM " + RetSqlname("SA5") + " SA5 "
cQuery += " WHERE RTRIM(A5_CODPRF) = '" + Alltrim(cProdF) + "' "
cQuery += " AND A5_FORNECE = '" + Alltrim(cForn) + "' "
cQuery += " AND A5_LOJA    = '" + Alltrim(cLoj)  + "' "
cQuery += " AND SA5.D_E_L_E_T_ <> '*' "

MemoWrite("C:\TEMP\fVerSA5.sql" , cQuery)

cQuery := ChangeQuery( cQuery )		

If Select("TMPXXX") > 0
	dbSelectArea("TMPXXX")
	TMPXXX->(dbCloseArea())
EndIf

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPXXX", .T., .F. )
DbSelectArea("TMPXXX")
DbGoTop() 

If TMPXXX->(!Eof())

	cCodProd := Alltrim(TMPXXX->A5_PRODUTO)

	dbSelectArea("TMPXXX")
	TMPXXX->(dbCloseArea())

Endif

RestArea(aArea) 

Return(cCodProd) 

//==================================================================================//
//FunÁ„o  : fProxACB 
//Autoria : Fl·via Rocha
//Data    : 30/03/2022
//Objetivo: FunÁ„o para trazer o prÛximo cÛdigo livre da tabela ACB
//==================================================================================//
Static Function fProxACB() 
Local aArea := GetArea() 
Local cQuery := ""
Local cCodACB:= ""
//Local aRet   := {}

cQuery := " SELECT MAX(ACB_CODOBJ) CODIGO "
cQuery += " FROM " + RetSqlname("ACB") + " ACB "
cQuery += " WHERE ACB.D_E_L_E_T_ <> '*' "
cQuery += " GROUP BY ACB_CODOBJ "
cQuery += " ORDER BY ACB_CODOBJ DESC "

MemoWrite("C:\TEMP\PROXACB.SQL" , cQuery )

cQuery := ChangeQuery(cQuery)

Iif(Select("XF3TAB") # 0,XF3TAB->(dbCloseArea()),.T.)
	
TcQuery cQuery New Alias "XF3TAB"

XF3TAB->(dbSelectArea("XF3TAB"))
XF3TAB->(dbGoTop())
			
If !XF3TAB->(EOF())	
	cCodACB := XF3TAB->CODIGO
	cCodACB := SOMA1(cCodACB)
Endif


If Empty(cCodACB)

	cCodACB := "0000000001"
	ACB->(OrdSetFocus(1))
	While ACB->( DbSeek( xFilial( "ACB" ) + cCodACB ) )
		ConfirmSX8()   
		cCodACB := SOMA1(cCodACB)
	Enddo

Endif

XF3TAB->(dbSelectArea("XF3TAB"))
DbCloseArea() 

RestArea(aArea)

Return(cCodACB)






//OUTRA ROTINA:
//CONSULTA A SITUA«√O DE FORNECEDOR (JUNTO A RECEITA)

/*/
=====================================================================
Programa  ≥ HFXML08F ∫ Autoria: Fl·via Rocha  Data: 17/02/2022   
Descricao ≥ Utilizar a api de cadastro de fornecedor para consultar 
            a situaÁ„o do fornecedor e grava-la no campo Memo 
            ZBZ_OBS e se estiver parametrizado = S, gravar na tabela
            de log de consultas. 
======================================================================                                     
/*/
User Function HFXML08F()		

Local lBELLKEY      := AllTrim(GetSrvProfString("BELLKEY","0"))=="1"
Local lXml          := .F.

// variaveis da api
Local cUrl			:= 'http://www.receitaws.com.br/v1/cnpj/'
Local cGetParams	:= ''
Local nTimeOut		:= 240
Local aHeaderStr	:= {'Content-Type: application/json'}
Local cHeaderGet	:= ''
Local cReturn		:= ''
Local oObjJson		:= nil
Local cCnpj			:= ""     
Local cError        := ""
Local cWarning      := ""
Local oXml						
Local cZBZObs		:= ""		//FR - 10/02/2022 - grava a observaÁ„o ZBZ_OBS - SolicitaÁıes de Rafael Lobitsky relativas a consulta fornecedor via api da Sefaz
Local cSituacao     := ""		//FR - 10/02/2022 - capta a situaÁ„o do fornecedor no objeto Json vindo da api - SolicitaÁıes de Rafael Lobitsky relativas a consulta fornecedor via api da Sefaz
Local cGravaLOG     := ""       //FR - 10/02/2022 - habilita a gravaÁ„o de log 
Local cNomeFor      := ""
Local cChave        := "" 
Local dDataCons     := Ctod("  /  /    ")
Local cHrCons       := ""

Private xZBG  	  := GetNewPar("XM_TABLOG" ,"ZBG")
Private xZBG_     := iif(Substr(xZBG,1,1)=="S", Substr(xZBG,2,2), Substr(xZBG,1,3)) + "_"

Private xZBZ		:= GetNewPar("XM_TABXML","ZBZ")
Private xZBT		:= GetNewPar("XM_TABITEM","ZBT")   //FR - 11/11/19
Private xZB5		:= GetNewPar("XM_TABAMAR","ZB5")
Private xZBS		:= GetNewPar("XM_TABSINC","ZBS")
Private xZBE        := GetNewPar("XM_TABEVEN","ZBE")
Private xZBA  	    := GetNewPar("XM_TABAMA2","ZBA")
Private xZBC        := GetNewPar("XM_TABCAC","ZBC")
Private xZBO        := GetNewPar("XM_TABOCOR","ZBO") 
Private xZBI        := GetNewPar("XM_TABIEXT","ZBI")

Private xZBZ_		:= iif(Substr(xZBZ,1,1)=="S", Substr(xZBZ,2,2), Substr(xZBZ,1,3)) + "_"
Private xZBT_		:= iif(Substr(xZBT,1,1)=="S", Substr(xZBT,2,2), Substr(xZBT,1,3)) + "_"  //FR - 11/11/19
Private xZB5_		:= iif(Substr(xZB5,1,1)=="S", Substr(xZB5,2,2), Substr(xZB5,1,3)) + "_"
Private xZBS_		:= iif(Substr(xZBS,1,1)=="S", Substr(xZBS,2,2), Substr(xZBS,1,3)) + "_"
Private xZBE_       := iif(Substr(xZBE,1,1)=="S", Substr(xZBE,2,2), Substr(xZBE,1,3)) + "_"
Private xZBA_     	:= iif(Substr(xZBA,1,1)=="S", Substr(xZBA,2,2), Substr(xZBA,1,3)) + "_"
Private xZBC_       := iif(Substr(xZBC,1,1)=="S", Substr(xZBC,2,2), Substr(xZBC,1,3)) + "_"
Private xZBO_       := iif(Substr(xZBO,1,1)=="S", Substr(xZBO,2,2), Substr(xZBO,1,3)) + "_"
Private xZBI_       := iif(Substr(xZBI,1,1)=="S", Substr(xZBI,2,2), Substr(xZBI,1,3)) + "_"
cGravaLOG := GetNewPar("XM_LOGFORN" , "N")

cCnpj   := allTrim((xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ")))) // o campo tambÈm tem que ser dinamico (xZBZ)->ZBZ_CNPJ
xRECZBZ := (xZBZ)->(Recno())	//FR - 28/10/2021
	
oXml := XmlParser((xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML"))), "_", @cError, @cWarning )
	
cUrl	:= AllTrim(cUrl)+cCnpj
cReturn	:= HttpGet( cUrl , cGetParams , nTimeOut , aHeaderStr, @cHeaderGet )
	
If .not. FWJsonDeserialize(cReturn,@oObjJson)
	
	// chamada da api para notas de servico
		If (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO"))) $ "RP,67"
			//MsgStop('Ocorreu erro na consulta')
			MsgInfo("Consulta IndisponÌvel para os Modelos: RP e 67 -> Nf ServiÁo e CTE ")
			return ( .F. )
		Else
			lXml := .T.
			oXml := XmlParser((xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML"))), "_", @cError, @cWarning )
			//oObjJson:SITUACAO (conte˙do: "ATIVA"), oObjJson:DATA_SITUACAO (conte˙do: vazio, tipo caracter) , oObjJson:MOTIVO_SITUACAO , oObjJson:NATUREZA_JURIDICA
		Endif
		
Endif
	
If ! lXml
	
	If oObjJson:STATUS = "ERROR"
		If (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO"))) $ "RP,67"
			MsgStop(oObjJson:MESSAGE)
			return( .F. )
		Else
			lXml := .T.
			oXml := XmlParser((xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML"))), "_", @cError, @cWarning )
		Endif
	Endif
			

	
	If (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO"))) == "57"
		xTag := "CTE"
	Else
		xTag := "NFE"
	EndIf
	
	
	oXml := XmlParser((xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML"))), "_", @cError, @cWarning )

	cTag := "oXml:_"+xTAG+"PROC:_"+xTAG+":_INF"+xTAG+":_EMIT:_IE:TEXT" 
	
	//ATUALIZA ZBZ
	//FR - 10/02/2022 - atualiza ZBZ - apenas com as informaÁıes da consulta ao fornecedor
	//ATUALIZA ZBZ
	If xRECZBZ <> Nil
		(xZBZ)->(DBGoto(xRECZBZ))
		//FR - 10/02/2022 - SolicitaÁıes de Rafael Lobitsky relativas a consulta fornecedor via api da Sefaz
		//oObjJson:SITUACAO (conte˙do: "ATIVA"), oObjJson:DATA_SITUACAO (conte˙do: vazio, tipo caracter) , oObjJson:MOTIVO_SITUACAO , oObjJson:NATUREZA_JURIDICA
		cZBZObs := Alltrim( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"OBS"))) ) //FR - 10/02/2022 - Gravar no campo memo, a informaÁ„o da url consulta fornecedor
		cZBZObs += CHR(13) + CHR(10) + "Consulta Sefaz: " + Alltrim(cUrl)
		//If XmlChildEx(oObjJson,"SITUACAO") <> nil   //Complemento
		If oObjJson:STATUS == "ERROR"	
			ConOut("Gest„o XML - Cadastro de Fornecedor por CPF")
		Else
			cSituacao := oObjJson:SITUACAO 			 
		EndIf			//Endif 
				
		cZBZObs += CHR(13) + CHR(10) + Alltrim(cSituacao)
		dDataCons:= Date()
		cHrCons  := Time()
		cZBZObs += CHR(13) + CHR(10) + "Data: " + Dtoc(dDataCons) + " - Hora: " + cHrCons
						
		RecLock(xZBZ,.F.)
			
		(xZBZ)->(FieldPut(FieldPos(xZBZ_+"OBS")   , cZBZObs))
					
		(xZBZ)->(DbCommit())
		(xZBZ)->(MsUnlock())
		
		If cGravaLOG == "S"
			cNomeFor := oObjJson:nome
			cChave   := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE")))
			
			U_GrvZBG(cNomeFor,cSituacao,cUrl,xFilial(xZBG),cChave,dDataCons,cHrCons,cCnpj)
			MsgInfo("Consulta Finalizada...Visualize o Log Outras AÁıes -> Log SituaÁ„o Fornecedor")
		Else 
			MsgInfo("Consulta Finalizada...Visualize o Registro por Favor em Outras AÁıes -> Vis.Registro -> Campo: OBS")
		Endif  
					
	Endif 
	
	//MsgInfo("Consulta Finalizada...Visualize o Registro por Favor em Outras AÁıes -> Vis.Registro -> Campo: OBS")
Endif 
//ATUALIZA ZBZ
 	
	

Return( .T. )

/*/
=====================================================================
Programa  ≥ HFXML08LF ∫ Autoria: Fl·via Rocha  Data: 17/02/2022   
Descricao ≥ Consulta o log da situaÁ„o fornecedor 
======================================================================                                     
/*/
User Function HFXML08LF() 


Private cCadastro := "LOG de Consultas ‡ SituaÁ„o de Fornecedores"
Private xZBG  	  := GetNewPar("XM_TABLOG" ,"ZBG")
Private xZBG_     := iif(Substr(xZBG,1,1)=="S", Substr(xZBG,2,2), Substr(xZBG,1,3)) + "_"

Private aRotina := { {"Pesquisar","AxPesqui",0,1} ,;
             		{"Visualizar","AxVisual",0,2} }

Private cDelFunc := ".F." // Validacao para a exclusao. Pode-se utilizar ExecBlock
Private xZBG  	 := GetNewPar("XM_TABLOG" ,"ZBG")											//FR - 17/02/2022 - LOG Consulta Fornecedores
Private xZBG_ 	 := iif(Substr(xZBG,1,1)=="S", Substr(xZBG,2,2), Substr(xZBG,1,3)) + "_"	//FR - 17/02/2022 - LOG Consulta Fornecedores

Private cString := ""

cString := xZBG

dbSelectArea(cString) //("ZBG")
dbSetOrder(1)

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Executa a funcao MBROWSE. Sintaxe:                                  ≥
//≥                                                                     ≥
//≥ mBrowse(<nLin1,nCol1,nLin2,nCol2,Alias,aCampos,cCampo)              ≥
//≥ Onde: nLin1,...nCol2 - Coordenadas dos cantos aonde o browse sera   ≥
//≥                        exibido. Para seguir o padrao da AXCADASTRO  ≥
//≥                        use sempre 6,1,22,75 (o que nao impede de    ≥
//≥                        criar o browse no lugar desejado da tela).   ≥
//≥                        Obs.: Na versao Windows, o browse sera exibi-≥
//≥                        do sempre na janela ativa. Caso nenhuma este-≥
//≥                        ja ativa no momento, o browse sera exibido na≥
//≥                        janela do proprio SIGAADV.                   ≥
//≥ Alias                - Alias do arquivo a ser "Browseado".          ≥
//≥ aCampos              - Array multidimensional com os campos a serem ≥
//≥                        exibidos no browse. Se nao informado, os cam-≥
//≥                        pos serao obtidos do dicionario de dados.    ≥
//≥                        E util para o uso com arquivos de trabalho.  ≥
//≥                        Segue o padrao:                              ≥
//≥                        aCampos := { {<CAMPO>,<DESCRICAO>},;         ≥
//≥                                     {<CAMPO>,<DESCRICAO>},;         ≥
//≥                                     . . .                           ≥
//≥                                     {<CAMPO>,<DESCRICAO>} }         ≥
//≥                        Como por exemplo:                            ≥
//≥                        aCampos := { {"TRB_DATA","Data  "},;         ≥
//≥                                     {"TRB_COD" ,"Codigo"} }         ≥
//≥ cCampo               - Nome de um campo (entre aspas) que sera usado≥
//≥                        como "flag". Se o campo estiver vazio, o re- ≥
//≥                        gistro ficara de uma cor no browse, senao fi-≥
//≥                        cara de outra cor.                           ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ

dbSelectArea(cString)
mBrowse( 6,1,22,75,cString)


Return


/*/
=====================================================================
Programa  ≥ GrvZBG ∫ Autoria: Fl·via Rocha  Data: 17/02/2022   
Descricao ≥ Grava o log da consulta a situaÁ„o fornecedor 
======================================================================                                     
/*/
User Function GrvZBG(cNomeFor,cSituacao,cUrl,cxFilial,cChave,dDataCons,cHrCons,cCnpj)
Local aArea := GetArea() 

Private xZBG  	  := GetNewPar("XM_TABLOG" ,"ZBG")
Private xZBG_     := iif(Substr(xZBG,1,1)=="S", Substr(xZBG,2,2), Substr(xZBG,1,3)) + "_"


DbSelectArea(xZBG)
RecLock(xZBG,.T.)
			
(xZBG)->(FieldPut(FieldPos(xZBG_+"FORNEC")   , cNomeFor		))
(xZBG)->(FieldPut(FieldPos(xZBG_+"SITUAC")   , cSituacao	))
(xZBG)->(FieldPut(FieldPos(xZBG_+"URL")      , cUrl    		))
(xZBG)->(FieldPut(FieldPos(xZBG_+"FILIAL")   , cxFilial		))
(xZBG)->(FieldPut(FieldPos(xZBG_+"CHAVE")    , cChave		))
(xZBG)->(FieldPut(FieldPos(xZBG_+"DTCONS")   , dDataCons	))
(xZBG)->(FieldPut(FieldPos(xZBG_+"HRCONS")   , cHrCons 		))
(xZBG)->(FieldPut(FieldPos(xZBG_+"CNPJ")     , cCnpj		))
					
(xZBG)->(DbCommit())
(xZBG)->(MsUnlock())   

RestArea(aArea) 

Return   



//CADASTRA SB1 AUTOM¡TICO 
User Function FCADSB1( _cCodProd, i,xProd,xDescri,xModelo,xUM,xNCM,nIpi,cMsgRet,lSB1Bloq,aBloqSB1 ) 
Local oModel
Local lRet       := .F.
Local cTblCad    := Iif(cTipoNF $ "D|B","SA1","SA2")
Local cTblDP     := Iif(GetNewPar("XM_GRVZB5","S") == "S",xZB5, Iif(cTipoNF $ "D|B", "SA7","SA5")  )
Local lGravou    := .F.
Local cUn        := ""
Local cNcm       := ""
Local _cTipo     := ""
Local cNomEmit   := ""
Local cLojaEmit  := ""
Local cCodEmit   := ""
Local cB1Desc    := ""
Local lProssegue := .T. 

Private lMsErroAuto := .F.

Default cProdXml := xProd
Default cDescXml := xDescri
Default cModelo  := xModelo
Default aBloqSB1 := {} 

If xModelo == Nil
	If cModelo $ "55,65"
	
		cUn    := oDet[i]:_Prod:_UCOM:TEXT
	
		//Consulta unidade de medida
		DbSelectArea("SAH")
		DbSetOrder(1)
		if !DbSeek(xFilial("SAH") + cUn)
	
			cUn := "UN"
	
		endif
	
		cNCM   := oDet[i]:_Prod:_NCM:TEXT
		_cTipo := "MC"
	
	ElseIf cModelo $ "57,67"
	
		cUn    := "HR"
		cNCM   := ""
		_cTipo := "SV"
	
	EndIf
	
Else
	If xModelo $ "55,65"
		cUn    := xUM
		cNcm   := xNcm
		_cTipo := "MC"
		
	Elseif xModelo $ "57,67"
		cUn    := "HR"
		cNCM   := ""
		_cTipo := "SV"
	Endif

Endif

//FR - 25/03/2022 - AlteraÁ„o - Kitchens - Cadastro autom·tico de produtos 
//Caso a unidade do XML n„o exista no cadastro de unidade de medidas, assume o cÛdigo "UN"-"UNIDADE"
SAH->(OrdSetFocus(1))
If !SAH->(Dbseek(xFilial("SAH") + cUn)) 
	cUn := "UN"
Endif

If xDescri == Nil											
	cB1Desc := Substr(cDescXml,1,30)
Else  
	cB1Desc := Alltrim(Substr(xDescri,1,TAMSX3("B1_DESC")[1]) ) 
Endif

//Antes de fazer o execauto, faz um dbseek sÛ por desencargo
DbselectArea("SB1")
SB1->(OrdSetFocus(1))
If DbSeek(xFilial("SB1") + _cCodProd)
	cMsg := _cCodProd + " -> Produto J· Cadastrado" + CRLF
	If FieldPos("B1_MSBLQL") > 0
		If SB1->B1_MSBLQL == "1"
			cMsg += _cCodProd + " -> Produto Bloqueado no Cadastro" + CRLF
			lSB1Bloq := .T.
			Aadd(aBloqSB1, _cCodProd)
		Endif
	Endif 
	lProssegue := .F. 
Endif 

If lProssegue

	aVetor:= { {"B1_COD" 		,_cCodProd 	,NIL},;
	 			{"B1_DESC" 		,cB1Desc 	,NIL},;
				{"B1_TIPO" 		,_cTipo	 	,Nil},;
	 			{"B1_UM" 		,cUn 		,Nil},;
	 			{"B1_LOCPAD" 	,"01" 		,Nil},;
	 			{"B1_IPI" 		,nIpi 		,Nil},;
			 	{"B1_POSIPI" 	,cNcm		,Nil}}
	  
	MSExecAuto({|x,y| Mata010(x,y)},aVetor,3)
 
  
	If lMsErroAuto
		MostraErro()	
	Else
		
		//Alert("Ok")
		
		lRet := .T.
		cCnpjEmi := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ")))
	
		//Grava amarraÁ„o produto x fornecedor 
		If !Empty(_cCodProd)
	
			If cTblCad == "SA2"
	
				cNomEmit := Posicione("SA2",3,xFilial("SA2")+cCnpjEmi,"A2_NOME")
				cCodEmit := SA2->A2_COD
				cLojaEmit:= SA2->A2_LOJA
				
			Else
	
				cNomEmit :=  Posicione("SA1",3,xFilial("SA1")+cCnpjEmi,"A1_NOME")
				cCodEmit := SA1->A1_COD
				cLojaEmit:= SA1->A1_LOJA
				
			EndIf
	
			If cTblDP == xZB5
			
				If cTblCad == "SA2"			
					
					DbSelectArea(xZB5)		
					DbSetOrder(1)    	//ZB5_FILIAL+ZB5_CGC+ZB5_PRODFO	- CGC/CPF+Prod. do For
					If !DbSeek(xFilial(xZB5) + cCnpjEmi + cProdXml)
						RecLock(xZB5,.T.)
						
						(xZB5)->(FieldPut(FieldPos(xZB5_+"FILIAL"), xFilial(xZB5)))
						(xZB5)->(FieldPut(FieldPos(xZB5_+"FORNEC"), cCodEmit))
						(xZB5)->(FieldPut(FieldPos(xZB5_+"LOJFOR"), cLojaEmit))
						(xZB5)->(FieldPut(FieldPos(xZB5_+"CGC"),    cCnpjEmi))
						(xZB5)->(FieldPut(FieldPos(xZB5_+"NOME"),   cNomEmit))
						(xZB5)->(FieldPut(FieldPos(xZB5_+"PRODFO"), cProdXml))
						(xZB5)->(FieldPut(FieldPos(xZB5_+"PRODFI"), _cCodProd))
						(xZB5)->(FieldPut(FieldPos(xZB5_+"DESCPR"), cDescXml))
						(xZB5)->(FieldPut(FieldPos(xZB5_+"CLIENT"), ""))
						(xZB5)->(FieldPut(FieldPos(xZB5_+"CGCC"),   ""))
						(xZB5)->(FieldPut(FieldPos(xZB5_+"NOMEC"),  ""))
						(xZB5)->(FieldPut(FieldPos(xZB5_+"LOJCLI"), ""))
															
						MsUnlock()
						
						lGravou := .T.
						
					Endif 
					
				ElseIf cTblCad == "SA1" 
				
					DbSelectArea(xZB5)		
					DbSetOrder(2)				//ZB5_FILIAL+ZB5_CGCC+ZB5_PRODFO - CGC/CPF+Prod. do Cli
					If !DbSeek(xFilial(xZB5) + cCnpjEmi + cProdXml)
						RecLock(xZB5,.T.)
						
						(xZB5)->(FieldPut(FieldPos(xZB5_+"FILIAL"), xFilial(xZB5)))
						(xZB5)->(FieldPut(FieldPos(xZB5_+"FORNEC"), ""))
						(xZB5)->(FieldPut(FieldPos(xZB5_+"LOJFOR"), ""))
						(xZB5)->(FieldPut(FieldPos(xZB5_+"CGC"),    ""))
						(xZB5)->(FieldPut(FieldPos(xZB5_+"NOME"),   ""))
						(xZB5)->(FieldPut(FieldPos(xZB5_+"PRODFO"), cProdXml))
						(xZB5)->(FieldPut(FieldPos(xZB5_+"PRODFI"), _cCodProd))
						(xZB5)->(FieldPut(FieldPos(xZB5_+"DESCPR"), cDescXml))
						(xZB5)->(FieldPut(FieldPos(xZB5_+"CLIENT"), cCodEmit))
						(xZB5)->(FieldPut(FieldPos(xZB5_+"LOJCLI"), cLojaEmit))									
						(xZB5)->(FieldPut(FieldPos(xZB5_+"CGCC"),   cCnpjEmi))
						(xZB5)->(FieldPut(FieldPos(xZB5_+"NOMEC"),  cNomEmit))
					
						MsUnlock()
						
						lGravou := .T.
					Endif 
					
				EndIf	
	
			ElseIf cTblDP =="SA5"
			
				If cTblCad == "SA2"
				
					DbSelectArea("SA5")		
					DbSetOrder(1)
					If DbSeek(xFilial("SA5")+cCodEmit+cLojaEmit+cProdXml)
					
						if .not. empty( SA5->A5_CODPRF )
						
							Conout("J· existe um relacionamento cadastrado para o produto:"+CRLF+cProdXml+" - "+;
									cDescXml+CRLF+SA5->A5_CODPRF)
	
						else
						
							RecLock("SA5",.F.)
							SA5->A5_CODPRF  := _cCodProd
							MsUnlock()
							lGravou := .T.
	
						endif
	
					Else
					
						RecLock("SA5",.T.)
						SA5->A5_FILIAL  := xFilial("SA5")
						SA5->A5_FORNECE := cCodEmit
						SA5->A5_LOJA    := cLojaEmit
						SA5->A5_NOMEFOR := cNomEmit
						SA5->A5_PRODUTO := cProdXml
						SA5->A5_NOMPROD := cDescXml
						SA5->A5_CODPRF  := _cCodProd
						MsUnlock()
						
						lGravou := .T.
						
					EndIf
					
				EndIf
	
			ElseIf cTblDP =="SA7"
			
				If cTblCad == "SA1"
				
					DbSelectArea("SA7")		
					DbSetOrder(1)
					If DbSeek(xFilial("SA7")+cCodEmit+cLojaEmit+cProdXml)
	
						if .not. empty( SA7->A7_CODCLI )
			
							Conout( "J· existe um relacionamento cadastrado para o produto:"+CRLF+cProdXml+" - "+;
							cDescXml+CRLF+SA7->A7_CODCLI )
			
						else
			
							RecLock("SA7",.F.)
							SA7->A7_CODCLI  := _cCodProd
							MsUnlock()
							lGravou := .T.
	
						endif
	
					Else
					
						RecLock("SA7",.T.)
						
						SA7->A7_FILIAL  := xFilial("SA7")
						SA7->A7_CLIENTE := cCodEmit
						SA7->A7_LOJA    := cLojaEmit
						SA7->A7_DESCCLI := cDescXml 
						SA7->A7_PRODUTO := cProdXml
						SA7->A7_CODCLI  := _cCodProd
						
						MsUnlock()
						
						lGravou := .T.
						
					EndIf
					
				EndIf
				
			EndIf 	//tab cTblDP
	
		EndIf      //codprod vazio
								
		If lGravou 
			//U_MyAviso("Aviso","Relacionamento cadastrado com sucesso!",{"OK"},2)
			Conout("<<<GESTAOXML - Relacionamento cadastrado com sucesso! - FCADSB1 >>>")
	
		EndIf
		
	Endif  //If lMsErroAuto
	
Endif //lProssegue

If !lRet
	//U_MyAviso("Aviso","Falha no Cadastro Autom·tico de Produto: " + CRLF + "Motivo(s): " + CRLF + CRLF + cMsg,{"OK"},2)	
	cMsgRet := cMsg
Endif 
  
Return(lRet)
//Esta funÁ„o deve ser colocada no ini padr„o do campo A2_COD se quiser que gere o A2_COD seguindo o ponto entrada XMLPEFORN
User Function TRAZCODA2()
Local lXMLPEFORN    := ExistBlock( "XMLPEFORN" )
Local aRet			:= {}
Local cCodSA2       := ""
Local cLojSA2		:= ""

If lXMLPEFORN
	aRet := ExecBlock( "XMLPEFORN", .F., .F., { cCnpjEmi,cRazao,cCodSA2,cLojSA2 } )
	cCodSA2 := aRet[3]
	cLojSA2 := aRet[4]

Endif 

Return()

//=========================================================================//
//AVISO DE NOVO CADASTRO ROB”TICO - SA2
//Autoria: Fl·via Rocha - Solicitado por Rafael Lobitsky para Kitchens
//=========================================================================//
User Function FNEWCAD(cTipo, cRegistro)

Local cEmailTo := AllTrim(GetMV("XM_MAIL09")) // Conta de Email que recebe a notificaÁ„o
Local aTo      := {} 
Local cMsg     := ""
Local cError   := ""
Local cAnexo   := ""

Default cTipo  := "SA2-Fornecedor" 
Default cRegistro := ""   //Vai vir cÛdigo/loja - raz„o social do fornecedor

If !Empty(cEmailTo)
	
    cAssunto:= "Informativo de Novo Cadastro RobÛtico " + " - " + cTipo 
    cError  := ""
    cAnexo  := ""
	    
	aTo 	:= Separa(cEmailTo,";")   
	
	cMsg    := "Informamos que foi realizado novo cadastro de forma robÛtica: " + CRLF + CRLF
	cMsg    += cTipo + " -> " + cRegistro + CRLF + CRLF
	cMsg    += "Por gentileza, os respons·veis por validar o cadastro, avaliar as informaÁıes."
		
	nRet := U_MAILSEND(aTo,cAssunto,cMsg,@cError,cAnexo,"",cEmailTo,"","") 
		
	
	
	If nRet == 0 .And. Empty(cError) 
		CONOUT("<GESTAOXML> EMAIL ENVIADO COM SUCESSO PARA: " + cEmailTo + " <====") 
			
		lRet := .T.
			
	EndIf
	
	If lRet
		MsgInfo("E-mail Enviado Com Sucesso Para: " + cEmailTo)   //retirar depois
	Endif 


Endif

Return()
