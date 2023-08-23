#INCLUDE "PROTHEUS.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "FWMVCDef.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HFXML01   ºAutor  ³Microsiga           º Data ³  04/26/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Inicializador do Ambiente do Importa Xml.                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Importa Xml                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//-------------------------------------------------------------------------//
//FR - 09/06/2020 - Alterações realizadas para adequar nova opção para 
//                  "gera nota fiscal direto"
//					Alterado o label do menu de Gera Pré-Nota para
//                  "Gera Pre-NF / NF
//					As opções abaixo, constam na tela F12-parâmetros:
//					aAdd( aCombo7, "0=Pré-Nota Somente")
//					aAdd( aCombo7, "1=Gera Pré-Nota e Classifica")
//					aAdd( aCombo7, "2=Sempre Perguntar") 
//					aAdd( aCombo7, "3=Gera Docto.Entrada Direto")
//					Se for escolhida 3-Gera Docto.Entrada Direto, o sistema
//					não gerará pré-nota e nem perguntará, apenas irá gerar
//					o Documento de Entrada diretamente.                          
//                  
//-------------------------------------------------------------------------//
//FR - 19/11/2021 - Band Agro - Inclusão de opção de menu para chamar a
//                  rotina Banco de Conhecimento MsDocument
//-------------------------------------------------------------------------//
//FR - 07/12/2021 - Projeto Kitchens - Solicitado por Rafael Lobitsky
//                  Inclusão de rotina para geração de pedido compra
//-------------------------------------------------------------------------//
//FR - 17/01/2022 - Alteração da função U_HFVISU
//                  Adaptação da chamada para cliente Petra 
//                  Via pto Entrada MA103BUT - qdo a chamada vier de fora 
//                  da ferramenta GestãoXML                                  
//-------------------------------------------------------------------------//
//FR - 10/02/2022 - RAFAEL LOBITSKY - Tópicos solicitados:
//                  botão no menu: "consulta situação fornecedor"
//-------------------------------------------------------------------------//
//FR - 31/03/2022 - PROJETO KITCHENS - BOTÃO Gerar Pedido Compra
//-------------------------------------------------------------------------//
//-------------------------------------------------------------------------//
//Erick Gonçalves, Rafael Tavares------------------------------------------//
//LUCAS SAN - NOVO MENU OUTRAS AÇÕES---------------------------------------//
//-------------------------------------------------------------------------//

User Function HFXML01()

	Local   aArea := GetArea()

	Private aRotina   := {} //GetMenu()
	Private aCores    := {}
	Private aUserData := {"",""} 
	Private cTopFun   := ""
	Private cBotFun   := "ZZZZ"
	Private cFilUsu   := GetNewPar("XM_FIL_USU","N")
	Private x_Ped_Rec := GetNewPar("XM_PEDREC","N")
	Private x_Tip_Pre := GetNewPar("XM_TIP_PRE","1")
	Private cDelFunc  := ".F." // Validacao para a exclusao. Pode-se utilizar ExecBlock
	Private lSetParam := .T.
	
	Private xZBZ  	  := GetNewPar("XM_TABXML" ,"ZBZ")
	Private xZB5  	  := GetNewPar("XM_TABAMAR","ZB5")
	Private xZBS  	  := GetNewPar("XM_TABSINC","ZBS")
	Private xZBA  	  := GetNewPar("XM_TABAMA2","ZBA")
	Private x_ZBB     := GetNewPar("XM_TABREC","")
	Private xZBE      := GetNewPar("XM_TABEVEN","ZBE")
	Private xZBT 	  := GetNewPar("XM_TABITEM","ZBT")		//FR - 11/11/19
	Private xZBC      := GetNewPar("XM_TABCAC" ,"ZBC")
	Private xZBO      := GetNewPar("XM_TABOCOR","ZBO"), xRetSEF := ""
	Private xZBI      := GetNewPar("XM_TABIEXT","ZBI")
	Private xZBG  	  := GetNewPar("XM_TABLOG" ,"ZBG")											//FR - 17/02/2022 - LOG Consulta Fornecedores
	Private xZBG_ 	  := iif(Substr(xZBG,1,1)=="S", Substr(xZBG,2,2), Substr(xZBG,1,3)) + "_"	//FR - 17/02/2022 - LOG Consulta Fornecedores
	Private xZBZ_ 	  := iif(Substr(xZBZ,1,1)=="S", Substr(xZBZ,2,2), Substr(xZBZ,1,3)) + "_"
	Private xZB5_ 	  := iif(Substr(xZB5,1,1)=="S", Substr(xZB5,2,2), Substr(xZB5,1,3)) + "_"
	Private xZBS_ 	  := iif(Substr(xZBS,1,1)=="S", Substr(xZBS,2,2), Substr(xZBS,1,3)) + "_"
	Private xZBA_ 	  := iif(Substr(xZBA,1,1)=="S", Substr(xZBA,2,2), Substr(xZBA,1,3)) + "_"
	Private xZBE_     := iif(Substr(xZBE,1,1)=="S", Substr(xZBE,2,2), Substr(xZBE,1,3)) + "_"
	Private xZBC_     := iif(Substr(xZBC,1,1)=="S", Substr(xZBC,2,2), Substr(xZBC,1,3)) + "_"
	Private xZBO_     := iif(Substr(xZBO,1,1)=="S", Substr(xZBO,2,2), Substr(xZBO,1,3)) + "_"
	Private xZBI_     := iif(Substr(xZBI,1,1)=="S", Substr(xZBI,2,2), Substr(xZBI,1,3)) + "_" 
	Private xZBT_ 	  := iif(Substr(xZBT,1,1)=="S", Substr(xZBT,2,2), Substr(xZBT,1,3)) + "_"
	Private aHfCloud  := {"0","0"," ","Token",{}}  //CRAUMDE - '0' Não integrar, na posição 1
	Private cTipBrw   := GetNewPar("XM_BROWSE", "1" )      
	Private cTpRt  	  := "M"

	//=======
	//CRAUMDE
	//IF ExistBlock( "HFCLDINI" )
	//	aHfCloud := U_HFCLDINI(.T.)
	//EndIF
	
	//Iniciare
	dbSelectArea( xZBE )
	dbSetOrder(1)
	dbSelectArea( xZBZ )
	dbSetOrder(1)
	DbSeek( xFilial( xZBZ ), .T. )
	if (xZBZ)->( Eof() )
		(xZBZ)->( dbSkip( -1 ) )
	endif

	//Cores para legenda
	AADD(aCores,{xZBZ_+"INDRUR > '0' .AND. "+xZBZ_+"PROTC == Space(15)" ,"BR_VERDE_ESCURO" })
	AADD(aCores,{xZBZ_+"PRENF == 'B' .AND. "+xZBZ_+"PROTC == Space(15) .AND. "+xZBZ_+"COMBUS == 'S'" ,"BR_CINZA" })
	AADD(aCores,{xZBZ_+"PRENF == 'B' .AND. "+xZBZ_+"PROTC == Space(15) .AND. "+xZBZ_+"TPDOWL == 'R'" ,"BR_MARROM" })
	AADD(aCores,{xZBZ_+"PRENF == 'B' .AND. "+xZBZ_+"PROTC == Space(15)" ,"BR_AZUL" })
	AADD(aCores,{xZBZ_+"PRENF == 'A' .AND. "+xZBZ_+"PROTC == Space(15)" ,"BR_LARANJA" })   //,BR_CINZA,,BR_MARRON
	AADD(aCores,{xZBZ_+"PRENF == 'S' .AND. "+xZBZ_+"PROTC == Space(15)" ,"BR_VERDE" })
	AADD(aCores,{xZBZ_+"PRENF == 'N' .AND. "+xZBZ_+"PROTC == Space(15) .AND. "+xZBZ_+"COMBUS == 'S'" ,"BR_PINK" })
	AADD(aCores,{xZBZ_+"PRENF == 'N' .AND. "+xZBZ_+"PROTC == Space(15)" ,"BR_VERMELHO" })
	AADD(aCores,{xZBZ_+"PRENF == 'F' .AND. "+xZBZ_+"PROTC == Space(15)" ,"BR_PRETO" })
	AADD(aCores,{xZBZ_+"PRENF == 'Z' .AND. "+xZBZ_+"PROTC == Space(15)" ,"BR_AMARELO" })
	AADD(aCores,{xZBZ_+"PRENF == 'X' .OR.  "+xZBZ_+"PROTC <> '' "       ,"BR_BRANCO" })
	AADD(aCores,{xZBZ_+"PRENF == 'D' .OR.  "+xZBZ_+"PROTC == Space(15)" ,"BR_VIOLETA" })

	//Setar F12 conforme usuário for Admin
	lSetParam := .F.

	PswOrder(2)
	cUserNome := Substr(cUsuario,7,15)
	If PswSeek( cUserNome, .T. )
		aUserData := PswRet()
		If aUserData[1][1]== "000000" .or. ( Ascan(aUserData[1][10],'000000') <> 0 ) //.or. aScan( aUserData[2][6], "@@@@" ) > 0
			lSetParam := .T.
		EndIf
	Else
		PswOrder(1)
		_cCodUsr := RetCodUsr()
		If PswSeek( _cCodUsr, .T. )
			aUserData := PswRet()
			If aUserData[1][1]== "000000" .or. ( Ascan(aUserData[1][10],'000000') <> 0 ) //.or. aScan( aUserData[2][6], "@@@@" ) > 0
				lSetParam := .T.
			EndIf
		Else
			aUserData:={{"",""}}
			cFilUsu := "N"
		Endif
	EndIf
	//Fim Inicializaciones
	
	If cTipBrw == "1"  //Antigo, Apenas um Browse, somente do XML NFe.
		aRotina := MenuDef()
	Endif
	
	//MsgRun("Carregando configuraçoes...",,{|| CursorWait(),LoadEmp(),CursorArrow()})
	FWMsgRun(, {|| CursorWait(),LoadEmp(),CursorArrow() }, "Aguarde", "Processando a rotina...")

	RestArea( aArea )

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |LoadEmp   ºAutor  ³Roberto Souza       º Data ³  01/11/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica o carregamento de licenças de uso.                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Importa Xml                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LoadEmp()

	//Local lValidEmp := .F. 
	Local lUsoOk      := .F.
	Local lEnv      := .F.
	Private cFile := ""
	  
	cPerg := "IMPXML"
	
	dVencLic := Stod(Space(8))
	lUsoOk := U_HFXMLLIC(.T.)

	If !lUsoOk
		Return(.T.)
	EndIf
	
	lEnv := EnvOk() 
	If lEnv		
		U_HFXML02("HF351058875875878XSSD7XVXVUETVEIIIQPQNZZ6574883AJJANI00983881FFDHSEJJSNW",.T.)
	EndIf

Return(.T.)  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  | EnvOk    ºAutor  ³Roberto Souza       º Data ³  03/05/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica o ambiente para uso.                              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Importa Xml                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function EnvOk()

	Local lRet   := .T.
	//Local lTable := .F.
	//Local lIndex := .F.
	Local cErro  := ""
	
	If !AliasInDic(xZBZ) .Or. !AliasInDic(xZB5)  
		cErro += "As tabelas "+xZBZ+" e "+xZB5+" não estão devidamente criadas."+CRLF	
	EndIf
	
	If (xZBZ)->(FieldPos(xZBZ_+"XMLCAN")) <= 0 ;
		.Or. (xZBZ)->(FieldPos(xZBZ_+"PROTC")) <= 0 ; 
		.Or. (xZBZ)->(FieldPos(xZBZ_+"DTHCAN")) <= 0 ; 
		.Or. (xZBZ)->(FieldPos(xZBZ_+"MAIL")) <= 0  
		cErro += "Existem campos a serem criados."+CRLF
	EndIf
	
	If !Empty(cErro)
		cErro := "Existem imcompatibilidades no dicionário de dados."+CRLF+ cErro +CRLF+"Execute o compatibilizador 'U_UPDIF001' antes de continuar."    
	    U_MyAviso("Atenção", cErro, {"Ok"},3)
	    lRet   := .F.
	EndIf
Return(lRet)


//Para o menu no MBrowse, antiga GetMenu do HFXML02
**********************
USer Function HFMENU() 
**********************
Local aMenu := {}

	aMenu := MenuDef()

Return( aMenu )


//MenuDef -> Para novo conceito de Menu
*************************
Static Function MenuDef()
*************************
	Local aMenu := {}
	Local aSub1 := {}
	Local aSub2 := {}
	Local aSub3 := {}
	Local aSub4 := {}
	Local aSub5 := {}
	Local aSub6 := {}
	Local aSub7 := {}
	Local aSub8 := {}
	Local aSub9 := {}
	Local aSub10:= {}
	//Local aSub11:= {} // Variável de Suporte - Erick, Rafael e Lucas San - 04/11/2022
	Local aRotAdic    := {}
	Local lImpAnt     := ( GetNewPar("XM_IMPANT","S") == "S" )
	Local lXMLPEMNU   := ExistBlock( "XMLPEMNU" )
	Private x_Ped_Rec := GetNewPar("XM_PEDREC","N")
	Private x_Tip_Pre := GetNewPar("XM_TIP_PRE","1")
	Private lUsaPriv  := .F. //( GetNewPar("XM_PRIVILE","N") == "S" ) //FR - 19/11/2021 - NÃO TEM FUNÇÃO AQUI QQ UMA DAS OPÇÕES MOSTRA TODOS OS ITENS DE MENU
	Private aHfCloud  := {"0","0"," ","Token",{}}  //CRAUMDE - '0' Não integrar, na posição 1
	Private xZBZ  	  := GetNewPar("XM_TABXML","ZBZ")   //FR - 19/08/2022 - TÓPICO 31 - RAFAEL - PLANILHA VALIDAÇÃO PATCH GERAL
	
	//=======
	//CRAUMDE
	//IF ExistBlock( "HFCLDINI" )
	//	aHfCloud := U_HFCLDINI(.T.)
	//EndIF
	
	aadd(aSub1, {"Alterar"             ,"U_HFXML02M" ,0,2} )
	aadd(aSub1, {"Excluir"             ,"U_HFXML02Z" ,0,2} )
	aadd(aSub1, {"Exportar XML"        ,"U_HFXML02E" ,0,2} )
	//if GetNewPar("XM_DFE","0") $ "0,1"
		aadd(aSub1, {"Consulta Chave Xml"  ,"U_HFXML02X" ,0,2} )
		aadd(aSub1, {"Download por Chave"  ,"U_HFXML06D" ,0,3} )
	//else
	//	aadd(aSub1, {"Consulta Chave Xml"  ,"U_HFXML16X" ,0,2} )
	//	aadd(aSub1, {"Download Sefaz Xml"  ,"U_HFXML16"  ,0,3} )
	//endif
	//aadd(aSub1, {"Download Indisponivel-137" 	,"U_HFXML061" ,0,3} )
	//aadd(aSub1, {"Download Completo XML Resumo"	,"U_HFXML069" ,0,4} )
	aadd(aSub1, {"* Cadastrar Fornecedor"		,"U_HFXML08"  ,0,2} )
	aadd(aSub1, {"* Cons.Situação Fornecedor"	,"U_HFXML08F" ,0,2} )
	aadd(aSub1, {"* LOG Situação Fornecedor"	,"U_HFXML08LF",0,2} )
	//aadd(aSub1, {"* Atualiza Campos de Impostos","U_HFATUBASE",0,2} )
	//aadd(aSub1, {"* Atuliz. Ult.Manifestação *" ,"U_FATUMANIF",0,4} )
	//aadd(aSub1, {"* Atuliz. Status XML * "      ,"U_UPStatXML",0,4} )
	
	//FR - 07/12/2021 - Projeto Kitchens - Solicitado por Rafael Lobitsky-  Inclusão de rotina para geração de pedido compra
	aadd(aSub1, {"* Gera Pedido Compra *"		,"U_HFXML8PC",0,4} )
	if  x_Ped_Rec == "S" 
		aadd(aSub1, {"Pedido Recorrente"  ,"U_HFXML09" ,0,4} )
	endif
	
	aSub2 := {}
	if  x_Tip_Pre $ "1,3,4,6"  
		aadd(aSub2, {"Gera &Pre-NF / NF","U_HFXML02P"   ,0,4})
	endif
	if  x_Tip_Pre $ "2,3,5,6"  
		aadd(aSub2, {"Aviso &Recbto Carga","U_HFXML2ARC" ,0,4})
	endif
	if  x_Tip_Pre $ "4,5,6" 
		aadd(aSub2, {"Nt Conhec Frete-CTe","U_HFXML02CTE" ,0,4})
	endif
	if  x_Ped_Rec == "S" 
		aadd(aSub2, {"Pre Nota p/Ped.Rec.","U_XML09PDR( ,.T. )",0,4})
	endif
	aadd(aSub2, {"Banco de Conhecimento"  ,"U_HFXML02BC"		,0,4} )  //FR - 19/11/2021 - BAND AGRO
	
	aadd(aSub3, {"Baixar Integração"     ,"U_HFXML133" ,0,3} )
	aadd(aSub3, {"Classif. Automat."     ,"U_HFXML131" ,0,3} )
	aadd(aSub3, {"Auditor.NFe.Terc."     ,"U_HFXML132" ,0,3} )
	aadd(aSub3, {"Relat.Auditor.NFe"     ,"U_HFXMLR14" ,0,3} )
	aadd(aSub3, {"Relat.Ocorrencias"     ,"U_HFXMLR13" ,0,3} )
	aadd(aSub3, {"Relat.Pré-Aud.Fiscal"  ,"U_HFXMLR16" ,0,3} )

	//aadd(aSub4, {"Monitoramento Sefaz "  ,"U_HFNVMMON" ,0,3} )
	aadd(aSub4, {"Monitor Sefaz "  ,"U_HFNVMMON" ,0,3} )	
	aadd(aSub4, {"Monitor NFSE WS"				,"U_HF068BRW"  ,0,4} )
	aadd(aSub4, {"Monitor NFSE IC"				,"U_POSTBRW2"  ,0,4} )
	
	//Multiplos Nfe e Cte
	aadd(aSub5, {"NFE"  ,"U_HFXMLMNF" ,0,4} )
	aadd(aSub5, {"CTE"  ,"U_HFXMLMCT" ,0,4} )	
	
	//Impressão de Danfe
	aadd(aSub6, {"Danfe/Dacte","U_XMLPRTdoc",0,4})
	aadd(aSub6, {"Danfse","U_DANFSESP",0,4})

	//Ações NF 
	aadd(aSub7, {"Classificar nota"   		,"U_HFXML12C"  		,0,4,0,Nil} ) // incluso no dia 07/07/2017 - para cliente Etilux - prospect. U_ClNfisca
	aadd(aSub7, {"Excluir Pre Nota/NF"		,"U_HFXML02W"  		,0,4,0,Nil} ) 
	aadd(aSub7, {"Banco de Conhecimento"	,"U_HFXML02BC"		,0,4,0,Nil} )

	//Eventos
	aadd(aSub8, {"Manifestar"         		,"U_HFMANCHV"  ,0,5,0,Nil} )   //GETESB2
	aadd(aSub8, {"Env. Desacordo"     		,"U_HFXML024"  ,0,5,0,Nil} )   //Envio de desacordo CTE
	aadd(aSub8, {"Eventos / CCe"      		,"U_HF20VCCE"  ,0,5,0,Nil} )   //ZBEMANO
	aadd(aSub8, {"Manifestação em Lote" 	,"U_HFXML073" ,0,5,0,Nil} )
	
	//Análise
	aadd(aSub9, {"Fiscal"				,"U_HFXML065"  ,0,2,0,Nil} )
	aadd(aSub9, {"Gráfica"         		,"U_HFXMLGR1"  ,0,2,0,Nil} ) //U_HFXMLHLP
	aadd(aSub9, {"Relat.Pré-Aud.Fiscal"  ,"U_HFXMLR16" ,0,2,0,Nil} )
	//Atualiza Campos
	//aadd(aSub10, {"* Atualiz. Campos de Impostos","U_HFATUBASE",0,2} )
	//aadd(aSub10, {"* Atualiz. Ult.Manifestação *" ,"U_FATUMANIF",0,4} )
	aadd(aSub10, {"* Atualiz. Status XML * "      ,"U_UPStatXML",0,4} )
	aMenu   := {}
	
	aadd(aMenu, {"Pesquisar"          ,"AxPesqui"    ,0,1,0,Nil} )
	aadd(aMenu, {"Baixar Xml"         ,"U_HFXML02D"  ,0,3,0,Nil} )
	aadd(aMenu, {"&Visualiza NF"      ,"U_HFXML02V"  ,0,2,0,Nil} )
	aadd(aMenu, {"Vis. Registro"      ,"U_HFVISU"    ,0,2,0,Nil} )
	//aadd(aMenu, {"Conhecimento"       ,"U_HFXML02BC" ,0,5,0,Nil} )  //FR - 19/11/2021 - BAND AGRO  //AQUI VIRA BOTÃO MAS TIRA O GERA PRE NF
	aadd(aMenu, {"Gerar Multiplas"       , aSub5 		 ,0,5,0,Nil} )

	aadd(aMenu, {"Impressão PDF"       , aSub6 		 ,0,5,0,Nil} )

	aadd(aMenu, {"Ações NF"       , aSub7 		 ,0,5,0,Nil} )
	
	//Gerar Documentos
	if .NOT. lUsaPriv
		if  len( aSub2 ) > 1  //cTipBrw != "1" .OR.
			aadd(aMenu, {"Gera &Doctos"       	,aSub2		 	,0,4,0,Nil} )
		elseif x_Tip_Pre == "2"
			aadd(aMenu, {"Av. &Recbto Carga"  	,"U_HFXML2ARC"	,0,4,0,Nil} )
		else
			aadd(aMenu, {"Gera &Pre-NF / NF"   	,"U_HFXML02P"  	,0,4,0,Nil} )
		endif
		//aadd(aMenu, {"Conhecimento"       		,"U_HFXML02BC" 	,0,4,0,Nil} )  //FR - 19/11/2021 - BAND AGRO 
	Else
		if x_Tip_Pre $ "1,3,4,6"
			aadd(aMenu, {"Gera &Pre-NF / NF"  , "U_HFXML02P"        , 0, 4})
		endif
		if x_Tip_Pre $ "2,3,5,6"
			aadd(aMenu, {"Aviso &Recbto Carga", "U_HFXML2ARC"       , 0, 4})
		endif
		if x_Tip_Pre $ "4,5,6"
			aadd(aMenu, {"Nt Conhec Frete-CTe", "U_HFXML02CTE"      , 0, 4})
		endif
		if x_Ped_Rec == "S"
			aadd(aMenu, {"Pre Nota p/Ped.Rec.", "U_XML09PDR( ,.T. )", 0, 4})
		endif
		//aadd(aMenu, {"Bco. de Conhecimento"      ,"U_HFXML02BC" ,0,4})  //FR - 19/11/2021 - BAND AGRO  
	EndIF
	//Fim Gerar Doctos
	
	//aadd(aMenu, {"Gera &Multiplos CTE"		,"U_HFXMLMCT"  		,0,4,0,Nil} ) //está no HFXML021
	//aadd(aMenu, {"Gera &Multiplos NFE"		,"U_HFXMLMNF"  		,0,4,0,Nil} ) //está no HFXML022
	//aadd(aMenu, {"Danfe/Dacte"        		,"U_XMLPRTdoc" 		,0,2,0,Nil} )   		//FR - 31/03/2022 - PROJETO KITCHENS
	//aadd(aMenu, {"Danfse"    		  		,"U_DANFSESP"  		,0,2,0,Nil} )
	//aadd(aMenu, {"Exportar XML"       		, "U_HFXML02E",   		,0,4,0,Nil} ) 
	//aadd(aMenu, {"Classificar nota"   		,"U_HFXML12C"  		,0,4,0,Nil} ) // incluso no dia 07/07/2017 - para cliente Etilux - prospect. U_ClNfisca
	//aadd(aMenu, {"Excluir Pre Nota/NF"		,"U_HFXML02W"  		,0,4,0,Nil} ) 
	//aadd(aMenu, {"Banco de Conhecimento" 	,"U_HFXML02BC" 		,0,4,0,Nil} )  //FR - 19/11/2021 - BAND AGRO

	if .NOT. lUsaPriv
		aadd(aMenu, {"Funções XML"        , aSub1 		 ,0,5,0,Nil} )
	Else
		//Inicio Funções XML
		aadd(aMenu, {"Alterar"             ,"U_HFXML02M" ,0,2} )
		aadd(aMenu, {"Excluir"             ,"U_HFXML02Z" ,0,2} )
		aadd(aMenu, {"Exportar XML"        ,"U_HFXML02E" ,0,2} )
		aadd(aMenu, {"Consulta Chave Xml"  ,"U_HFXML02X" ,0,2} )
		if GetNewPar("XM_DFE","0") $ "0,1"
			//aadd(aMenu, {"Download Sefaz Xml"  ,"U_HFXML06D" ,0,3} )
		else
			//aadd(aMenu, {"Download Sefaz Xml"  ,"U_HFXML16"  ,0,3} )
		endif
		//aadd(aMenu, {"Download Indisponivel-137" ,"U_HFXML061" ,0,3} )
		//aadd(aMenu, {"Download Completo XML Resumo","U_HFXML069"  ,0,4} )
		aadd(aMenu, {"Cadastrar Fornecedor","U_HFXML08"  ,0,4} )
		if  x_Ped_Rec == "S" 
			aadd(aMenu, {"Pedido Recorrente"  ,"U_HFXML09" ,0,4} )
		endif
		//Fim das funções XML
	EndIf
	aadd(aMenu, {"Eventos"       , aSub8		 ,0,5,0,Nil} )
	//aadd(aMenu, {"Manifestar"         ,"U_HFMANCHV"  ,0,5,0,Nil} )   //GETESB2
	//aadd(aMenu, {"Env. Desacordo"     ,"U_HFXML024"  ,0,5,0,Nil} )   //Envio de desacordo CTE
	//aadd(aMenu, {"Eventos / CCe"      ,"U_HF20VCCE"  ,0,5,0,Nil} )   //ZBEMANO
	aadd(aMenu, {"Legenda"    , "U_HFXML02L", 0, 2, 0, Nil})
	If aHfCloud[1] != "0" //.And. aHfCloud[3] != "N"
		aadd(aMenu, {"Envia Nuvem", "U_HFCLDEnv", 0, 2, 0, Nil})
	EndIF
	if .NOT. lUsaPriv
		//aadd(aMenu, {"Class.Aut.Terc."       , aSub3 		 ,0,5,0,Nil} )
	Else
		aadd(aMenu, {"Baixar Integração"     ,"U_HFXML133" ,0,3} )
		aadd(aMenu, {"Classif. Automat."     ,"U_HFXML131" ,0,3} )
		aadd(aMenu, {"Auditor.NFe.Terc."     ,"U_HFXML132" ,0,3} )
		aadd(aMenu, {"Relat.Auditor.NFe"     ,"U_HFXMLR14" ,0,3} )
		aadd(aMenu, {"Relat.Ocorrencias"     ,"U_HFXMLR13" ,0,3} )
	Endif
	
	//Rafael Pediu para tirar	
	aadd(aMenu, {"Monitoramento", aSub4       , 0, 5, 0, Nil})
	aadd(aMenu, {"Análise"      , aSub9       , 0, 5, 0, Nil})
	aadd(aMenu, {"Atualização"  , aSub10      , 0, 5, 0, Nil})
	//aadd(aMenu, {"Suporte"      , "U_HFXMLSUP", 0, 2, 0, Nil})

/*
	aadd(aMenu, {"Monitoramento Sefaz "  ,"U_HFNVMMON" ,0,3} )	
	aadd(aMenu, {"Monitor NFSE WS"				,"U_HF068BRW"  ,0,4} )
	aadd(aMenu, {"Monitor NFSE IC"				,"U_POSTBRW2"  ,0,4} )
*/

	//aadd(aMenu, {"Gera &Multiplos CTE"		,"U_HFXMLMCT"  		,0,4,0,Nil} ) //está no HFXML021
	//aadd(aMenu, {"Gera &Multiplos NFE"		,"U_HFXMLMNF"  		,0,4,0,Nil} ) //está no HFXML022

	//aadd(aMenu, {"Analise Fiscal"			,"U_HFXML065"  ,0,2,0,Nil} )
	//aadd(aMenu, {"Analise Gráfica"         ,"U_HFXMLGR1"  ,0,2,0,Nil} ) //U_HFXMLHLP

	/*if lImpAnt
		aadd(aMenu, {"Importa xml Antigo"         ,"U_HFIMPANT"  ,0,2,0,Nil} ) 
	endif */
	
	If lXMLPEMNU
		aRotAdic := ExecBlock("XMLPEMNU",.F.,.F.)
		If ValType(aRotAdic) == "A"
			AEval(aRotAdic,{|x| AAdd(aMenu,x)})
		EndIf
	EndIf

Return(aMenu)



**********************
User Function HFVISU()
**********************

	Local aArea := GetArea()
	Local cAlias:= ""  //xZBZ  //FR - 17/01/2022
	Local nReg  := 0 //(xZBZ)->(recno())
	Local nOpca := 0
	Local aButtons  := {}
	Local nVersao := Val( GetVersao( .F.) )
	Local cReleas := GetRPORelease()
	local aAcho := {}, nX 
	
	Private xZBZ  	  := GetNewPar("XM_TABXML" ,"ZBZ")
	Private xZB5  	  := GetNewPar("XM_TABAMAR","ZB5")
	Private xZBS  	  := GetNewPar("XM_TABSINC","ZBS")
	Private xZBA  	  := GetNewPar("XM_TABAMA2","ZBA")
	Private x_ZBB     := GetNewPar("XM_TABREC","")
	Private xZBE      := GetNewPar("XM_TABEVEN","ZBE")
	Private xZBT 	  := GetNewPar("XM_TABITEM","ZBT")		//FR - 11/11/19
	Private xZBC      := GetNewPar("XM_TABCAC" ,"ZBC")
	Private xZBO      := GetNewPar("XM_TABOCOR","ZBO"), xRetSEF := ""
	Private xZBI      := GetNewPar("XM_TABIEXT","ZBI")
	Private xZBZ_ 	  := iif(Substr(xZBZ,1,1)=="S", Substr(xZBZ,2,2), Substr(xZBZ,1,3)) + "_"
	Private xZB5_ 	  := iif(Substr(xZB5,1,1)=="S", Substr(xZB5,2,2), Substr(xZB5,1,3)) + "_"
	Private xZBS_ 	  := iif(Substr(xZBS,1,1)=="S", Substr(xZBS,2,2), Substr(xZBS,1,3)) + "_"
	Private xZBA_ 	  := iif(Substr(xZBA,1,1)=="S", Substr(xZBA,2,2), Substr(xZBA,1,3)) + "_"
	Private xZBE_     := iif(Substr(xZBE,1,1)=="S", Substr(xZBE,2,2), Substr(xZBE,1,3)) + "_"
	Private xZBC_     := iif(Substr(xZBC,1,1)=="S", Substr(xZBC,2,2), Substr(xZBC,1,3)) + "_"
	Private xZBO_     := iif(Substr(xZBO,1,1)=="S", Substr(xZBO,2,2), Substr(xZBO,1,3)) + "_"
	Private xZBI_     := iif(Substr(xZBI,1,1)=="S", Substr(xZBI,2,2), Substr(xZBI,1,3)) + "_" 
	Private xZBT_ 	  := iif(Substr(xZBT,1,1)=="S", Substr(xZBT,2,2), Substr(xZBT,1,3)) + "_"
	
	cAlias:= xZBZ 
	If IsInCallStack("HFXML02A") 		//dentro da ferramenta GestãoXML 
		nReg  := (xZBZ)->(recno())    
	
	//FR - 17/01/2022 - ADAPTAÇÃO DA CHAMADA PARA PETRA (VIA PTO ENTRADA MA103BUT - qdo a chamada vier da rotina Documento entrada)
	ElseIf IsInCallStack("A103NFISCAL") //fora da ferramenta GestãoXML 
		
		cChave := SF1->F1_CHVNFE 
		(xZBZ)->(OrdSetFocus(3))  //ZBZ_CHAVE
		If (xZBZ)->(Dbseek(cChave))
			nReg := (xZBZ)->(recno())  
			(xZBZ)->(Dbgoto(nReg))
		Else
			MsgAlert("Registro Não Localizado - Tabela: " + xZBZ + " -> Chave Nfe: " + cChave )
		Endif
		
	Endif 
	//FR - 17/01/2022 - ADAPTAÇÃO DA CHAMADA PARA PETRA (VIA PTO ENTRADA MA103BUT - qdo a chamada vier da rotina Documento entrada)	
	
	DbSelectArea( xZBZ )	
	If nVersao >= 12 .And. cReleas >= "12.1.025"

		For nX := 1 To (xZBZ)->(FCount())
			aadd( aAcho, (xZBZ)->( FieldName( nX ) ) )
		Next  
		
		nOpca := (xZBZ)->( AxVisual(cAlias, nReg, 1,aAcho,,,,aButtons, .T.) )
		
	else

		nOpca := AxVisual(cAlias, nReg, 2,     ,,,,aButtons)

	Endif
	
	//Adicionando opções
    //ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.zMVCMd3' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	//Local aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,"Salvar"},{.T.,"Cancelar"},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil}}
	//FWExecView("Visualização de XML e Itens","VIEWDEF.HFXML067",MODEL_OPERATION_VIEW,,{|| .T.})

	RestArea( aArea )

Return( NIL )


**********************************
Static Function __Dummy(lRecursa) //warning W0010 Static Function <?> never called 
**********************************
    lRecursa := .F.
    IF (lRecursa)
        __Dummy(.F.)
        U_HFXML01()
        U_HFVISU()
        U_HFMENU()
	EndIF

Return(lRecursa)
