#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ HFXMLR16  ∫Autor  ≥ Renan Oliveira  ∫ Data ≥  23/03/2020  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ RelatÛrio de pre-auditoria de confronto de xml vs.        ∫±±
±±∫          ≥ Documento de Entrada                                      ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ IMPORTA XML                                               ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
//--------------------------------------------------------------------------//
//Alterado por Fl·via Rocha em 13/05/2020:
//Criada rotina "Exporta para Excel" dentro da tela de divergÍncias NF x XML
//Esta chamada È autom·tica e fora do menu normal do relatÛrio 
//--------------------------------------------------------------------------//
//FR - 11/06/2020 - AlteraÁıes realizadas para adequar a validaÁ„o da licenÁa 
//                  quando for licenÁa DemonstraÁ„o (Demo)
//                  Implementado "flag" para sinalizar todo o sistema quando
//                  for licenÁa Demo e assim, N√O permitir consultas
//                  no relatÛrio de prÈ-auditoria de forma abrangente
//                  Demo = consulta È data de hoje - 30 apenas
//                  
//--------------------------------------------------------------------------//
//FR - 15/06/2020 - AlteraÁıes realizadas para adequar query de seleÁ„o
//                  Quando a data da emiss„o F1_EMISSAO for diferente da 
//                  Data de digitaÁ„o: F1_DTDIGIT
//--------------------------------------------------------------------------// 
//FR - 01/12/2020 - Solicitado por Rafael: Revisar a impress„o dos impostos
//                  PIS / COFINS 
//--------------------------------------------------------------------------//
//FR - 14/01/2021 - Solicitado por Rafael: Deixar ìdefaultî os valores 
//                  relativos ao modelo e espÈcie de notas no parambox
//                  de perguntas.Ex: SPED (espÈcie), NFE (modelo) 
//--------------------------------------------------------------------------//
//FR - 12/02/2021 - Revisıes na chamada da funÁ„o Excel
//                  Solicitado por Rafael Lobitsky
//--------------------------------------------------------------------------//

***********************************************
User Function HFXMLR16(aParams,lQuery,lDiverg)        
***********************************************

Local nX 		:= 0
Local aTab		:= {}
Local aCampos	:= {}
Local aErros	:= {"",""}
Local aBase		:= {"1=NF",;
					"2=XML"}   

Local aDiver	:= {"1=Desconsiderar",;
					"2=Valores",;
					"3=Quantidade",;
					"4=Impostos",;
					"5=Todos"}  

Local aImpCanc	:= {"1=Todas",;
					"2=Ativas",;
					"3=Canceladas"}

Local aAmarrac	:= {"1=Sim",;
					"2=N„o"}

Private xZBZ		:= GetNewPar("XM_TABXML","ZBZ")
Private xZBZ_		:= iif(Substr(xZBZ,1,1)=="S", Substr(xZBZ,2,2), Substr(xZBZ,1,3)) + "_"  
Private xZBT		:= GetNewPar("XM_TABITEM","ZBT")		//Tabela de itens do xml
Private xZBT_		:= iif(Substr(xZBT,1,1)=="S", Substr(xZBT,2,2), Substr(xZBT,1,3)) + "_"
Private xZB5		:= GetNewPar("XM_TABAMAR","ZB5")		//Tabela AmarraÁ„o de Produtos                      
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
Private LF      	:= CHR(13) + CHR(10)
Private aParamBox	:= {}
Private aParam		:= {}
Private aRet		:= {}
Private aManif		:= {}
Private aStatus		:= {}
Private lDemonstra  := .F.
Private nTotReg     := 0

//---------------------------------------------------------------------------------------------------------------------------------------------//
//FR - 14/11/2022 - PROJETO COPAG VALIDA«√O SEFAZ AMAZONAS - caso este par‚metro esteja ativado, ir· mostrar no relatÛrio uma aba SPED FISCAL
//Criar um par‚metro chamado sped fiscal 1=sim;2=n„o  Help- ìcaso este par‚metro esteja habilitado o relatÛrio 
//ira apresentar criticas relacionados ao sped fiscal.
//---------------------------------------------------------------------------------------------------------------------------------------------// 
Private cSpedFisc   := GetNewPar("XM_SPEDFIS","N")	

Default lDemo       := .F.

dVencLic := Stod(Space(8))
//lUsoOk := U_HFXML00X("HF000001","101",SM0->M0_CGC,@dVencLic)
lUsoOk	:= U_HFXMLLIC()
lDemonstra := lDemo
If !lUsoOk
	Return(Nil)
EndIf

// Verifica se o Excel est· instalado na m·quina
If !ApOleClient("MSExcel")
    MsgAlert("Microsoft Excel n„o instalado!")
    Return
EndIf            

aTab	:= {xZBZ,xZBT,xZB5,xZBA,xZBE,xZBC,xZBO,xZBI}

DbselectArea(xZBT)
cCAMPOCF := ""
If FieldPos(xZBT_+"CFOP") > 0 
	cCAMPOCF := xZBT_+"CFOP"									
Endif 

aAdd(aCampos,{xZB5, {xZB5_+"FORNEC", xZB5_+"LOJFOR", xZB5_+"CGC",    xZB5_+"PRODFO", xZB5_+"PRODFI", xZB5_+"DESCPR"}})
aAdd(aCampos,{xZBZ, {xZBZ_+"FILIAL", xZBZ_+"NOTA",   xZBZ_+"SERIE",  xZBZ_+"CNPJ",   xZBZ_+"DTNFE",  xZBZ_+"CODFOR",;
					 xZBZ_+"LOJFOR", xZBZ_+"TPDOC",	 xZBZ_+"MODELO", xZBZ_+"PRENF",  xZBZ_+"PROTC", xZBZ_+"MANIF",;
					 xZBZ_+"DTRECB", xZBZ_+"CHAVE",  xZBZ_+"VLLIQ",  xZBZ_+"VLBRUT"}})
aAdd(aCampos,{xZBT, {xZBT_+"FILIAL", xZBT_+"NOTA",   xZBT_+"SERIE",  xZBT_+"PRODUT", xZBT_+"DESCRI", xZBT_+"CHAVE",;
				 	 xZBT_+"QUANT",  xZBT_+"UM"  ,   xZBT_+"VUNIT",  xZBT_+"TOTAL",  xZBT_+"ITEM",;
					 xZBT_+"ICMCST", xZBT_+"ICMBAS", xZBT_+"ICMALQ", xZBT_+"ICMVAL",; 
					 xZBT_+"IPIENQ", xZBT_+"IPICST", xZBT_+"IPIBAS", xZBT_+"IPIALQ", xZBT_+"IPIVAL",;
					 xZBT_+"PISCST", xZBT_+"PISBAS", xZBT_+"PISALQ", xZBT_+"PISVAL",;
					 xZBT_+"COFCST", xZBT_+"COFBAS", xZBT_+"COFALQ", xZBT_+"COFVAL",;
					 xZBT_+"ISSALQ", xZBT_+"ISSVAL", xZBT_+"INSALQ", xZBT_+"INSVAL", xZBT_+"CSLALQ", xZBT_+"CSLVAL",;
					 xZBT_+"IRRALQ", xZBT_+"IRRVAL", xZBT_+"NCM", iif(!Empty(cCAMPOCF),cCAMPOCF,'') }})

aErros	:= HF16Erro(aTab, aCampos)

If !Empty(aErros[1])
	MsgAlert("Tabelas utilizadas na rotina ("+aErros[1]+") n„o foram localizadas!"+LF+"Favor rodar o compatibilizador para atualizar os campos/tabelas!")
	Return
ElseIf !Empty(aErros[2])
	MsgAlert("Campos utilizadas na rotina"+LF+" ("+aErros[2]+") "+LF+" n„o foram localizadas!"+LF+"Favor rodar o compatibilizador para atualizar os campos/tabelas!")
	Return
EndIf

//Status - Manifesto
Aadd( aManif, {"0", "N„o" } )
Aadd( aManif, {"1", "Conf.Oper" } )
Aadd( aManif, {"2", "Oper.Desconh" } )
Aadd( aManif, {"3", "Oper.N„o Realiz" } )
Aadd( aManif, {"4", "CiÍncia" } )
Aadd( aManif, {"5", "MCTe" } )
Aadd( aManif, {"W", "Pend.Conf" } )
Aadd( aManif, {"X", "Pend.Desc" } )
Aadd( aManif, {"Y", "Pend.N.Realiz" } )
Aadd( aManif, {"Z", "Pend.CiÍncia" } )

//Status XML
Aadd( aStatus, {" ", "                      " } )
Aadd( aStatus, {"A", "Recebimento Carga     " } )
Aadd( aStatus, {"B", "Importado             " } )
Aadd( aStatus, {"F", "Falha                 " } )
Aadd( aStatus, {"N", "Pre Nota Classificada " } )
Aadd( aStatus, {"S", "Pre Nota a Classificar" } )
Aadd( aStatus, {"X", "Cancelado             " } )
Aadd( aStatus, {"Z", "Falha                 " } )

//FR - 14/01/2021 - AlteraÁıes no parambox, inserindo alguns valores "default":
/*01*/AAdd( aParamBox, { 1, "Filial de"					,SPACE(TamSX3('B1_FILIAL')[01])		,	""		,	"",	"SM0"			,	"",		50,	.F.}) 
/*02*/AAdd( aParamBox, { 1, "Filial ate"				,Repli("Z",TamSX3('B1_FILIAL')[01])	,	""		,	"",	"SM0"			,	"",		50,	.T.}) 
/*03*/AAdd( aParamBox, { 1, "Entrada de"				,CTOD('01/01/2000')					,	""		,	"",	""				,	"",		50,	.T.})
/*04*/AAdd( aParamBox, { 1, "Entrada ate"				,CTOD('31/12/2099')					,	""		,	"",	""				,	"",		50,	.T.})
/*05*/AAdd( aParamBox, { 1, "Serie de"					,SPACE(TamSX3('D1_SERIE')[01])		,	""		,	"",	""				,	"",		50,	.F.}) 
/*06*/AAdd( aParamBox, { 1, "Serie ate"					,Repli('Z',TamSX3('D1_SERIE')[01])	,	""		,	"",	""				,	"",		50,	.T.}) 
/*07*/AAdd( aParamBox, { 1, "Nota de"					,SPACE(TamSX3('D1_DOC')[01])		,	""		,	"",	"SF1"			,	"",		50,	.F.}) 
/*08*/AAdd( aParamBox, { 1, "Nota ate"					,Repli('Z',TamSX3('D1_DOC')[01])	,	""		,	"",	"SF1"			,	"",		50,	.T.}) 
/*09*/AAdd( aParamBox, { 9, "Especies que devem ser consideradas separadas por virgula."	, 200		,7,.T.})
/*10*/AAdd( aParamBox, { 9, "Ex.: SPED,CTE" 												, 200		,7,.T.})
/*11*/AAdd( aParamBox, { 1, "Considera Especie"			,"SPED                         "	,	""		,	"",	""				,	"",		50,	.F.})
/*12*/AAdd( aParamBox, { 1, "Emissor XML de"			,SPACE(6)      						,	""		,	"",	"SA2"			,	"",		50,	.F.})
/*13*/AAdd( aParamBox, { 1, "Emissor XML ate"			,Repli('Z',6)      					,	""		,	"",	"SA2"			,	"",		50,	.T.})
/*14*/AAdd( aParamBox, { 1, "Loja Emissor de"			,SPACE(TamSX3('A2_LOJA')[01])		,	""		,	"",	""				,	"",		50,	.F.})
/*15*/AAdd( aParamBox, { 1, "Loja Emissor ate"			,Repli("Z",TamSX3('A2_LOJA')[01])	,	""		,	"",	""				,	"",		50,	.T.})
/*16*/AAdd( aParamBox, { 9, "EspÈcies consideradas como modelo de XML 55-NFe. "				,  200, 	 6, .T.})
/*17*/AAdd( aParamBox, { 9, "Separadas por virgula. Ex.:NFE,CTE - Somente Base NF" 			,  200, 	 6, .T.})
/*18*/AAdd( aParamBox, { 1, "Especie que s„o Modelo 55"	,"NFE                         "		,	""		,	""	,	""			,	"",	    50,	.F.}) 
/*19*/AAdd( aParamBox, { 1, "Emissao de"				,CTOD('01/01/2000')					,	""		,	""	,	""			,	"",		50,	.T.}) 
/*20*/AAdd( aParamBox, { 1, "Emissao ate"				,CTOD('31/12/2099')					,	""		,	""	,	""			,	"",		50,	.T.})
/*21*/AAdd( aParamBox, { 2, "Mostrar Divergencia"		,1			   						,aDiver		,	100	,	       "AllwaysTrue()", 	.T.})
/*22*/AAdd( aParamBox, { 1, "Grupo de"					,SPACE(4)      						,""			,	"" 	, "SBM"			,	"",		50,	.F.}) 
/*23*/AAdd( aParamBox, { 1, "Grupo ate"					,Repli('Z',4)  						,""			,	"" 	, "SBM"			,	"",		50,	.T.}) 
/*24*/AAdd( aParamBox, { 2, "Analise Base (NF ou XML)"	,	1          						,aBase		,	100	, "AllwaysTrue()"			,	.T.})
/*25*/AAdd( aParamBox, { 2, "Imprimir Notas Canceladas"	,	1          						,aImpCanc	,	100	, "AllwaysTrue()"			,	.T.})
/*26*/AAdd( aParamBox, { 2, "NF / XML sem AmarraÁ„o"	,	1          						,aAmarrac	,	100	, "AllwaysTrue()"			,	.T.})
/*27*/AAdd( aParamBox, { 6, "DiretÛrio de destino" 		,Space(80)							,""			,	""	,"!Empty(mv_par27)",80,.T.," |*.","c:\",GETF_RETDIRECTORY+GETF_LOCALHARD}) //"DiretÛrio de destino"
/*28*/AAdd( aParamBox, { 1, "CFOPs"						,Space(254)							,""			,	"",	""				,	"",		50,	.F.}) 

lCentered := .T.	//FR - 14/01/2021 - centraliza a janela de par‚metros
lCanSave  := .T.
lUserSave := .T.

//----------------------------------------------------------------------------------------------------------//
//Parambox - sintaxe geral
//ParamBox( < aParametros >  , < cTitle > , < aRet > , < bOk >, < aButtons > ,< lCentered >, < nPosX >,< nPosY > ,;
//          < oDlgWizard >, < cLoad > ,< lCanSave >,< lUserSave >  ) 

    // 1 - < aParametros > - Vetor com as configuraÁıes
    // 2 - < cTitle >      - TÌtulo da janela
    // 3 - < aRet >        - Vetor passador por referencia que contÈm o retorno dos par‚metros
    // 4 - < bOk >         - Code block para validar o bot„o Ok
    // 5 - < aButtons >    - Vetor com mais botıes alÈm dos botıes de Ok e Cancel
    // 6 - < lCentered >   - Centralizar a janela
    // 7 - < nPosX >       - Se n„o centralizar janela coordenada X para inÌcio
    // 8 - < nPosY >       - Se n„o centralizar janela coordenada Y para inÌcio
    // 9 - < oDlgWizard >  - Utiliza o objeto da janela ativa
    //10 - < cLoad >       - Nome do perfil se caso for carregar
    //11 - < lCanSave >    - Salvar os dados informados nos par‚metros por perfil
    //12 - < lUserSave >   - ConfiguraÁ„o por usu·rio
//----------------------------------------------------------------------------------------------------------//     

If aParams == Nil  .or. aParams == xZBZ   							//FR 13/05/2020
	//If ParamBox(aParamBox,"Parametros",@aRet)
	
    If ParamBox(aParamBox, "Par‚metros", @aRet,,,lCentered,,,,,lCanSave,lUserSave)
	
		For nX := 1 to Len(aParamBox)
			If aParambox[nX,1] == 2
				If ValType(aRet[nX]) == "C"
					aRet[nX] := Val(aRet[nX])
				EndIf
	
				aAdd(aParam,aParambox[nX,4,aRet[nX]])
			Else
				aAdd(aParam,aRet[nX])
			EndIf
		Next nX
	
		//HF16Dados(aCampos,,.T.,lDemonstra)
		HF16Dados(aCampos,,.T.,lDemonstra)

		DbSelectArea("TRB")
		TRB->(Dbgotop())

		If TRB->(!Eof())

			Processa({|| HF16Rel()}, "Aguarde...", "Analisando base de dados...",.F.)

		Else

			MsgAlert("Sem Dados para Gerar o RelatÛrio.")

		EndIf

	EndIf

Else 	//FR qdo chamado pela tela de divergÍncias, j· passa por par‚metro o n˙mero da NF

    aRet := Array(28)
	aRet[01] := aParams[01]
	aRet[02] := aParams[02]
	aRet[03] := aParams[03]
	aRet[04] := aParams[04]
	aRet[05] := aParams[05]
	aRet[06] := aParams[06]
	aRet[07] := aParams[07]
	aRet[08] := aParams[08]
	aRet[09] := aParams[09]
	aRet[10] := aParams[10]
	aRet[11] := aParams[11]
	aRet[12] := aParams[12]
	aRet[13] := aParams[13]
	aRet[14] := aParams[14]
	aRet[15] := aParams[15]
	aRet[16] := aParams[16]
	aRet[17] := aParams[17]
	aRet[18] := aParams[18]
	aRet[19] := aParams[19]
	aRet[20] := aParams[20]
	aRet[21] := aParams[21]
	aRet[22] := aParams[22]
	aRet[23] := aParams[23]
	aRet[24] := aParams[24]
	aRet[25] := aParams[25]
	aRet[26] := aParams[26]
	aRet[27] := aParams[27]
	If Len(aParams) > 27
		aRet[28] := aParams[28]
	Endif 
	
	For nX := 1 to Len(aParamBox)

		If aParambox[nX,1] == 2		
			aAdd(aParam,aParambox[nX,4,aRet[nX]])
		Else
			aAdd(aParam,aRet[nX])
		EndIf

	Next nX 
		
	//HF16Dados(aCampos,aParams,lQuery,lDemonstra)
	HF16Dados(aCampos,aParams,lQuery,lDemonstra)

	DbSelectArea("TRB")
	TRB->(Dbgotop())

	If TRB->(!Eof())

		lDiverg := .T.
		Processa({|| HF16Rel()}, "Aguarde...", "Analisando base de dados...",.F.)
	
	Else

		MsgAlert("Sem Dados para Gerar o RelatÛrio.")

	EndIf

Endif

Return

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ HF16Rel   ∫Autor  ≥ Renan Oliveira  ∫ Data ≥  23/03/2020  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ RelatÛrio de pre-auditoria de confronto de xml vs.        ∫±±
±±∫          ≥ Documento de Entrada                                      ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ IMPORTA XML                                               ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function HF16Rel()

Local cStartPath:= GetSrvProfString("Startpath","")
Local cTitulo   := "PrÈ Auditoria Fiscal"
Local cArquivo  := "HFXMLR16.XML"
Local cPath     := "" //"C:\WINDOWS\TEMP\"		//FR - 12/02/2021
Local cPlan     := ""
Local cTabela   := ""
Local cFornece  := ""
Local cNFiscal	:= ""
Local cSerie	:= ""
Local cNF		:= ""
Local cObs		:= ""
Local cManif	:= ""
Local cStatXml	:= ""
Local nSequen	:= 0
Local nBaseNf 	:= aRet[24]
Local nX		:= 0
Local oExcel    := Nil
Local oExcelApp := Nil
Local nAtual    := 0

if Empty( aRet[27] )
	cPath := "C:\TEMP\EXCEL\" 
else
	cPath := Alltrim(aRet[27])  //"C:\TEMP\EXCEL\" 	//FR - 14/01/2021 - caminho completo e com a "\" no final tambÈm, sen„o, n„o abre o arquivo automaticamente
endif

If !ExistDir(cPath)
	MakeDir(cPath)
EndIf

oExcel    := FWMSEXCEL():New()

cPlan   := "Parametros"
cTabela := "Parametros - Relatorio "+cTitulo

//GERA ABA COM OS PARAMETROS
oExcel:AddworkSheet(cPlan)
oExcel:AddTable(cPlan,cTabela)
oExcel:AddColumn(cPlan,cTabela,"Parametro",1,1,.F.)
oExcel:AddColumn(cPlan,cTabela,"Descricao",1,1,.F.)
oExcel:AddColumn(cPlan,cTabela,"Conteudo",1,1,.F.)
For nX := 1 to Len(aParambox)
	 oExcel:AddRow(cPlan,cTabela,{	"MV_PAR"+STRZERO(nX,2),;
                                    Alltrim(aParambox[nX,2]),;
                                    aParam[nX]})
Next nX


If cSpedFisc == "S"
	cPlan   := "SPEDFISCAL"
	cTabela := "SPEDFISCAL"

	oExcel:AddworkSheet(cPlan)
	oExcel:AddTable(cPlan,cTabela)

	// Adicionando as colunas na planilha do excel
	/*01*/oExcel:AddColumn(cPlan,cTabela,"Tipo",1,1,.F.)
	/*02*/oExcel:AddColumn(cPlan,cTabela,"Nota",1,1,.F.)
	/*03*/oExcel:AddColumn(cPlan,cTabela,"Serie",1,1,.F.)
	/*04*/oExcel:AddColumn(cPlan,cTabela,"Cnpj",1,1,.F.)
	/*05*/oExcel:AddColumn(cPlan,cTabela,"Fornecedor",1,1,.F.)
	/*06*/oExcel:AddColumn(cPlan,cTabela,"Observacao",1,1,.F.)
	/*07*/oExcel:AddColumn(cPlan,cTabela,"Emiss„o",1,4,.F.)
	/*08*/oExcel:AddColumn(cPlan,cTabela,"DigitaÁ„o",1,4,.F.)
	/*09*/oExcel:AddColumn(cPlan,cTabela,"Item",1,1,.F.)
	/*10*/oExcel:AddColumn(cPlan,cTabela,"Codigo",1,1,.F.)
	/*11*/oExcel:AddColumn(cPlan,cTabela,"Produto",1,1,.F.)
	/*12*/oExcel:AddColumn(cPlan,cTabela,"Quantidade",1,2,.F.)
	/*13*/oExcel:AddColumn(cPlan,cTabela,"Unid.Medida",1,1,.F.)
	/*14*/oExcel:AddColumn(cPlan,cTabela,"Desc.Unid.Medida",1,1,.F.)
	/*15*/oExcel:AddColumn(cPlan,cTabela,"Vlr Unit",1,3,.F.)
	/*16*/oExcel:AddColumn(cPlan,cTabela,"Vlr Total",1,3,.F.)
	/*17*/oExcel:AddColumn(cPlan,cTabela,"Base IPI",1,3,.F.)
	/*18*/oExcel:AddColumn(cPlan,cTabela,"Aliq. IPI",1,2,.F.)
	/*19*/oExcel:AddColumn(cPlan,cTabela,"Vlr IPI",1,3,.F.)	
	/*20*/oExcel:AddColumn(cPlan,cTabela,"CST",1,1,.F.)		
	/*21*/oExcel:AddColumn(cPlan,cTabela,"Base ICMS",1,3,.F.)
	/*22*/oExcel:AddColumn(cPlan,cTabela,"Aliq. ICMS",1,2,.F.)
	/*23*/oExcel:AddColumn(cPlan,cTabela,"Vlr ICMS",1,3,.F.)
	/*24*/oExcel:AddColumn(cPlan,cTabela,"Icms Desonerado",1,1,.F.)
	/*25*/oExcel:AddColumn(cPlan,cTabela,"Base PIS",1,3,.F.)
	/*26*/oExcel:AddColumn(cPlan,cTabela,"Aliq. PIS",1,2,.F.)
	/*27*/oExcel:AddColumn(cPlan,cTabela,"Vlr PIS",1,3,.F.)
	/*28*/oExcel:AddColumn(cPlan,cTabela,"Base COF",1,3,.F.)
	/*29*/oExcel:AddColumn(cPlan,cTabela,"Aliq. COF",1,2,.F.)
	/*30*/oExcel:AddColumn(cPlan,cTabela,"Vlr COF",1,3,.F.)
	/*31*/oExcel:AddColumn(cPlan,cTabela,"Aliq. ISS",1,3,.F.)
	/*32*/oExcel:AddColumn(cPlan,cTabela,"Vlr ISS",1,3,.F.)
	/*33*/oExcel:AddColumn(cPlan,cTabela,"Aliq. INSS",1,3,.F.)
	/*34*/oExcel:AddColumn(cPlan,cTabela,"Vlr INSS",1,3,.F.)
	/*35*/oExcel:AddColumn(cPlan,cTabela,"Aliq. CSLL",1,2,.F.)
	/*36*/oExcel:AddColumn(cPlan,cTabela,"Vlr CSLL",1,3,.F.)
	/*37*/oExcel:AddColumn(cPlan,cTabela,"Aliq. IR",1,3,.F.)
	/*38*/oExcel:AddColumn(cPlan,cTabela,"Vlr IR",1,3,.F.)
	/*39*/oExcel:AddColumn(cPlan,cTabela,"NCM",1,3,.F.)
	/*40*/oExcel:AddColumn(cPlan,cTabela,"Chave",1,1,.F.)
	/*41*/oExcel:AddColumn(cPlan,cTabela,"Manifesto",1,1,.F.)
	/*42*/oExcel:AddColumn(cPlan,cTabela,"Status XML",1,1,.F.)
	/*43*/oExcel:AddColumn(cPlan,cTabela,"CFOP",1,1,.F.)		
	
Endif 

ProcRegua( nTotReg )

dbSelectArea("TRB")
TRB->(dbGoTop())
While TRB->(!Eof())

	//Incrementa a mensagem na rÈgua
    nAtual++

	IncProc( "Processando dados " + cValToChar( nAtual ) + " de " + cValToChar( nTotReg ) )
	
	//FR - 14/11/2022 - PROJETO COPAG VALIDA«√O SEFAZ AMAZONAS - Nova aba: Fiscais
    If cSpedFisc <> "S"		//se este par‚metro estiver diferente de "Sim", faz o normal, que È uma aba para cada fornecedor
							//se este par‚metro estiver igual a "Sim", cria apenas uma aba SPEDFISCAL
	
		If TRB->(CLIFOR+LOJA) <> cFornece .AND. TRB->&(xZBZ_+"CNPJ") <> cFornece
			
			nSequen += 1
			
			If !Empty(TRB->CLIFOR)

				cFornece    := TRB->(CLIFOR+LOJA)
				cPlan       := STRZERO(nSequen,4)+"_"+LEFT(TRB->(NREDUZ),15)
				cTabela 	:= cFornece +" - "+ AllTrim(TRB->NOME) +" - "+ AllTrim(TRB->(CNPJ))

			Else

				cFornece	:= TRB->&(xZBZ_+"CNPJ")
				//cPlan       := cFornece
				cPlan       := STRZERO(nSequen,4)+"_" + cFornece		//FR - 01/12/2020 - estava dando erro de planilha duplicada
				cTabela		:= "N„o Cadastrado - CNPJ: "+cFornece
				
			EndIf

			//cNF		:= ""		//FR - 14/01/2021
			cManif		:= ""
			cStatXml	:= ""
			ZBT_ALQCSL  := ""

			If aScan( aManif, {|x| x[1] = TRB->(&(xZBZ_+"MANIF")) } ) > 0
				cManif := aManif[aScan( aManif, {|x| x[1] = TRB->(&(xZBZ_+"MANIF")) } )][2]
			EndIf

			If aScan( aStatus, {|x| x[1] = TRB->(&(xZBZ_+"PRENF")) } ) > 0
				cStatXml:= aStatus[aScan( aStatus, {|x| x[1] = TRB->(&(xZBZ_+"PRENF")) } )][2]
			EndIf

			oExcel:AddworkSheet(cPlan)
			oExcel:AddTable(cPlan,cTabela)

			// Adicionando as colunas na planilha do excel
			/*01*/oExcel:AddColumn(cPlan,cTabela,"Tipo",1,1,.F.)
			/*02*/oExcel:AddColumn(cPlan,cTabela,"Nota",1,1,.F.)
			/*03*/oExcel:AddColumn(cPlan,cTabela,"Serie",1,1,.F.)
			/*04*/oExcel:AddColumn(cPlan,cTabela,"Cnpj",1,1,.F.)
			/*05*/oExcel:AddColumn(cPlan,cTabela,"Fornecedor",1,1,.F.)
			/*06*/oExcel:AddColumn(cPlan,cTabela,"Observacao",1,1,.F.)
			/*07*/oExcel:AddColumn(cPlan,cTabela,"Emiss„o",1,4,.F.)
			/*08*/oExcel:AddColumn(cPlan,cTabela,"DigitaÁ„o",1,4,.F.)
			/*09*/oExcel:AddColumn(cPlan,cTabela,"Item",1,1,.F.)
			/*10*/oExcel:AddColumn(cPlan,cTabela,"Codigo",1,1,.F.)
			/*11*/oExcel:AddColumn(cPlan,cTabela,"Produto",1,1,.F.)
			/*12*/oExcel:AddColumn(cPlan,cTabela,"Quantidade",1,2,.F.)
			/*13*/oExcel:AddColumn(cPlan,cTabela,"Unid.Medida",1,1,.F.)
			/*14*/oExcel:AddColumn(cPlan,cTabela,"Desc.Unid.Medida",1,1,.F.)
			/*15*/oExcel:AddColumn(cPlan,cTabela,"Vlr Unit",1,3,.F.)
			/*16*/oExcel:AddColumn(cPlan,cTabela,"Vlr Total",1,3,.F.)
			/*17*/oExcel:AddColumn(cPlan,cTabela,"Base IPI",1,3,.F.)
			/*18*/oExcel:AddColumn(cPlan,cTabela,"Aliq. IPI",1,2,.F.)
			/*19*/oExcel:AddColumn(cPlan,cTabela,"Vlr IPI",1,3,.F.)	
			/*20*/oExcel:AddColumn(cPlan,cTabela,"CST",1,1,.F.)				
			/*21*/oExcel:AddColumn(cPlan,cTabela,"Base ICMS",1,3,.F.)
			/*22*/oExcel:AddColumn(cPlan,cTabela,"Aliq. ICMS",1,2,.F.)
			/*23*/oExcel:AddColumn(cPlan,cTabela,"Vlr ICMS",1,3,.F.)
			/*24*/oExcel:AddColumn(cPlan,cTabela,"Icms Desonerado",1,1,.F.)
			/*25*/oExcel:AddColumn(cPlan,cTabela,"Base PIS",1,3,.F.)
			/*26*/oExcel:AddColumn(cPlan,cTabela,"Aliq. PIS",1,2,.F.)
			/*27*/oExcel:AddColumn(cPlan,cTabela,"Vlr PIS",1,3,.F.)
			/*28*/oExcel:AddColumn(cPlan,cTabela,"Base COF",1,3,.F.)
			/*29*/oExcel:AddColumn(cPlan,cTabela,"Aliq. COF",1,2,.F.)
			/*30*/oExcel:AddColumn(cPlan,cTabela,"Vlr COF",1,3,.F.)
			/*31*/oExcel:AddColumn(cPlan,cTabela,"Aliq. ISS",1,3,.F.)
			/*32*/oExcel:AddColumn(cPlan,cTabela,"Vlr ISS",1,3,.F.)
			/*33*/oExcel:AddColumn(cPlan,cTabela,"Aliq. INSS",1,3,.F.)
			/*34*/oExcel:AddColumn(cPlan,cTabela,"Vlr INSS",1,3,.F.)
			/*35*/oExcel:AddColumn(cPlan,cTabela,"Aliq. CSLL",1,2,.F.)
			/*36*/oExcel:AddColumn(cPlan,cTabela,"Vlr CSLL",1,3,.F.)
			/*37*/oExcel:AddColumn(cPlan,cTabela,"Aliq. IR",1,3,.F.)
			/*38*/oExcel:AddColumn(cPlan,cTabela,"Vlr IR",1,3,.F.)
			/*39*/oExcel:AddColumn(cPlan,cTabela,"NCM",1,3,.F.)
			/*40*/oExcel:AddColumn(cPlan,cTabela,"Chave",1,1,.F.)
			/*41*/oExcel:AddColumn(cPlan,cTabela,"Manifesto",1,1,.F.)
			/*42*/oExcel:AddColumn(cPlan,cTabela,"Status XML",1,1,.F.)	
			/*43*/oExcel:AddColumn(cPlan,cTabela,"CFOP",1,1,.F.)			
			
		EndIf
	
	//FR - 14/11/2022 - PROJETO COPAG VALIDA«√O SEFAZ AMAZONAS - Nova aba: Fiscais
	Else 
		cManif		:= ""
		cStatXml	:= ""
		ZBT_ALQCSL  := ""

		If aScan( aManif, {|x| x[1] = TRB->(&(xZBZ_+"MANIF")) } ) > 0
			cManif := aManif[aScan( aManif, {|x| x[1] = TRB->(&(xZBZ_+"MANIF")) } )][2]
		EndIf

		If aScan( aStatus, {|x| x[1] = TRB->(&(xZBZ_+"PRENF")) } ) > 0
			cStatXml:= aStatus[aScan( aStatus, {|x| x[1] = TRB->(&(xZBZ_+"PRENF")) } )][2]
		EndIf

	Endif 
	//FR - 14/11/2022 - PROJETO COPAG VALIDA«√O SEFAZ AMAZONAS - Nova aba: Fiscais 

    //imprime linha em branco separando qdo troca a nota	//FR - 14/01/2021
	If nBaseNf == 1
		If !Empty(cNF) .AND. cNF <> TRB->(NOTA+SERIE)			
			oExcel:AddRow(cPlan,cTabela,ARRAY(43))		//Linha em branco
			//oExcel:AddRow(cPlan,cTabela,ARRAY(26))
		EndIf

		cNF := TRB->(NOTA+SERIE)
	Else
		If !Empty(cNF) .AND. cNF <> TRB->(&(xZBZ_+"NOTA")+&(xZBZ_+"SERIE"))
			oExcel:AddRow(cPlan,cTabela,ARRAY(43))		//Linha em branco			
			//oExcel:AddRow(cPlan,cTabela,ARRAY(26))		
		EndIf

		cNF := TRB->(&(xZBZ_+"NOTA")+&(xZBZ_+"SERIE"))
	EndIf

	If nBaseNf == 1
		cNFiscal	:= TRB->NOTA
		cSerie		:= TRB->SERIE
		If Empty(TRB->&(xZBZ_+"NOTA"))
			cObs	:= "XML N√O CADASTRADO"	
		Else			
			cObs	:= ""
		EndIf
		
	Else		//Base XML
	
		cNFiscal	:= TRB->&(xZBZ_+"NOTA")
		cSerie		:= TRB->&(xZBZ_+"SERIE")
		If Empty(TRB->NOTA)
			cObs	:= "NOTA N√O CADASTRADA"		
		Else
			cObs	:= ""
		EndIf
	EndIf
	//-----------------------//
	//obs para a linha da NF
	//-----------------------//
	//FR - 01/12/2020		
   	cTipoNf := Iif(Empty( TRB->&(xZBZ_+"TPDOC")),"N",TRB->&(xZBZ_+"TPDOC"))
	//Localiza se a NF existe na base, em virtude do XML estar cancelado
	If !Empty(TRB->CLIFOR)
		
		cForn    := TRB->(CLIFOR+LOJA)
		
		SF1->(OrdSetFocus(1))
		If SF1->(Dbseek(xFilial("SF1") + cNF + cForn)) 				
			If !Empty(SF1->F1_STATUS)
				cObs	:= "PRE-NOTA CLASSIFICADA"
			Endif
		Endif
	
	Else
		cForn	:= TRB->&(xZBZ_+"CNPJ")
		If cTipoNf == "N"
		
			SA2->(OrdSetFocus(3))   //A2_FILIAL + A2_CGC
			If SA2->(Dbseek(xFilial("SA2") + cForn ))
			
				SF1->(OrdSetFocus(1))
				If SF1->(Dbseek(xFilial("SF1") + cNF + SA2->A2_COD + SA2->A2_LOJA ))
					If !Empty(SF1->F1_STATUS)
						cObs	:= "PRE-NOTA CLASSIFICADA"
					Endif						
				Endif						
			Endif
			
		Else  //SE tipo da NF for D/B usa SA1
		
			SA1->(OrdSetFocus(3))
			If SA1->(Dbseek(xFilial("SA1") + cForn ))
			
				SF1->(OrdSetFocus(1))
				If SF1->(Dbseek(xFilial("SF1") + cNF + SA1->A1_COD + SA1->A1_LOJA))
					If !Empty(SF1->F1_STATUS)
						cObs	:= "PRE-NOTA CLASSIFICADA"
					Endif						
				Endif						
			Endif				
		Endif	//SE tipo da NF for D/B usa SA1				
	Endif		
	//FR - 01/12/2020
    
	//buscando a descriÁ„o da unidade de medida do item da nota
	cDescUM := ""
	SAH->(OrdSetFocus(1))
	If SAH->(Dbseek(xFilial("SAH") + TRB->D1_UM))
		cDescUM := SAH->AH_UMRES
	Else
		if !Empty(TRB->D1_UM)
			cDescUM := "Unidade de medida n„o encontrada no cadastro de unidade de medida PROTHEUS"
		endif 
	Endif 
	// Vinculando as informaÁıes da nota na planilha do excel.
	oExcel:AddRow(cPlan,cTabela,{   "NOTA",;
									cNFiscal,;
									cSerie,;
									TRB->CNPJ,;
									TRB->NOME,;
									cObs,;
									STOD(TRB->EMINF),;
									STOD(TRB->DTDIGIT),;
									TRB->D1_ITEM,;
									TRB->D1_COD,;
									TRB->B1_DESC,;
									TRB->D1_QUANT,;
									TRB->D1_UM,;
									cDescUM,;
									TRB->D1_VUNIT,;
									TRB->D1_TOTAL,;
									TRB->D1_BASEIPI,;									
									TRB->D1_IPI,;
									TRB->D1_VALIPI,;
									TRB->D1_CLASFIS,;									
									TRB->D1_BASEICM,;
									TRB->D1_PICM,;
									TRB->D1_VALICM,;
									0,;
									TRB->D1_BASIMP6,;  	//TRB->D1_BASEPIS,;	//FR - 01/12/2020
									TRB->D1_ALQPIS,;
									TRB->D1_VALIMP6,; 	//TRB->D1_VALPIS,;  //FR - 01/12/2020
									TRB->D1_BASIMP5,;	//TRB->D1_BASECOF,; //FR - 01/12/2020
									TRB->D1_ALQCOF,;
									TRB->D1_VALIMP5,;	//TRB->D1_VALCOF,;  //FR - 01/12/2020
									TRB->D1_ALIQISS,;
									TRB->D1_VALISS,;
									TRB->D1_ALIQINS,;
									TRB->D1_VALINS,;
									TRB->D1_ALQCSL,;
									TRB->D1_VALCSL,;
									TRB->D1_ALIQIRR,;
									TRB->D1_VALIRR,;
									TRB->D1_TEC,;
									TRB->F1_CHVNFE,;
									cManif,;
									cStatXml,;		//TRB->D1_DESC;
									TRB->D1_CF;
								})
									
	//------------------------//
	//obs para a linha do XML
	//------------------------//
	//FR - 01/12/2020 - se o XML estiver cancelado:	
	If TRB->&(xZBZ_+"PRENF") == "X"
		cObs := "XML CANCELADO"
	Endif
	//FR - 01/12/2020
	// Vinculando as informaÁıes do xml na planilha do excel.


	//buscando a descriÁ„o da unidade de medida do item da nota
	cDescUM := ""
	SAH->(OrdSetFocus(1))
	If SAH->(Dbseek(xFilial("SAH") + TRB->&(xZBT_+"UM") ))
		cDescUM := SAH->AH_UMRES
	Else
		if !Empty( TRB->&(xZBT_+"UM") )
			cDescUM := "Unidade de medida n„o encontrada no cadastro de unidade de medida PROTHEUS"
		endif 
	Endif  

	DbselectArea(xZBT)
	CCFOP := ""
	If FieldPos(xZBT_+"CFOP") > 0 
		CCFOP := TRB->&(xZBT_+"CFOP")									
	Endif 

	dbSelectArea("TRB")
	oExcel:AddRow(cPlan,cTabela,{   "XML",;
									cNFiscal,;
									cSerie,;
									TRB->CNPJ,;
									TRB->NOME,;
									cObs,;
									STOD(TRB->&(xZBZ_+"DTNFE")),;
									STOD(TRB->DTDIGIT),;
									TRB->&(xZBT_+"ITEM"),;
									TRB->&(xZBT_+"PRODUT"),;
									TRB->&(xZBT_+"DESCRI"),;
									TRB->&(xZBT_+"QUANT"),;
									TRB->&(xZBT_+"UM"),;
									cDescUM,;									
									TRB->&(xZBT_+"VUNIT"),;
									TRB->&(xZBT_+"TOTAL"),;
									TRB->&(xZBT_+"IPIBAS"),;									
									TRB->&(xZBT_+"IPIALQ"),;
									TRB->&(xZBT_+"IPIVAL"),;
									TRB->&(xZBT_+"ICMCST"),;									
									TRB->&(xZBT_+"ICMBAS"),;
									TRB->&(xZBT_+"ICMALQ"),;
									TRB->&(xZBT_+"ICMVAL"),;
									0,;
									TRB->&(xZBT_+"PISBAS"),;
									TRB->&(xZBT_+"PISALQ"),;
									TRB->&(xZBT_+"PISVAL"),;
									TRB->&(xZBT_+"COFBAS"),;
									TRB->&(xZBT_+"COFALQ"),;
									TRB->&(xZBT_+"COFVAL"),;
									TRB->&(xZBT_+"ISSALQ"),;
									TRB->&(xZBT_+"ISSVAL"),;
									TRB->&(xZBT_+"INSALQ"),;
									TRB->&(xZBT_+"INSVAL"),;
									TRB->&(xZBT_+"CSLALQ"),;
									TRB->&(xZBT_+"CSLVAL"),;
									TRB->&(xZBT_+"IRRALQ"),;
									TRB->&(xZBT_+"IRRVAL"),;
									TRB->&(xZBT_+"NCM"),;
									TRB->&(xZBT_+"CHAVE"),;
									cManif,;
									cStatXml,;
									CCFOP;									
								})
									//0,;//BASECSL
									//0,;//ALQCSL
									//0,;//VALCSL
									//0,;//BASEIRR
									//0,;//ALIQIRR
									//0,;//VALIRR

    TRB->(dbSkip())
EndDo

oExcel:Activate()
oExcel:GetXMLFile( cArquivo )

CpyS2T( cStartPath + cArquivo, cPath )

oExcelApp := MsExcel():New()
oExcelApp:WorkBooks:Open( cPath+cArquivo ) // Abre a planilha
oExcelApp:SetVisible(.T.)

Return

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ HF16Dados ∫Autor  ≥ Fl·via Rocha    ∫ Data ≥  28/02/2020  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Gera massa de dados para o relatorio                      ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ IMPORTA XML                                               ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function HF16Dados(aCampos,aParams,lQuery,lDemonstra)   

Local cQuery	:= ""
Local cQrAux	:= ""
Local nX      	:= 0
Local nY		:= 0
Local cFilDe  	:= aRet[1]
Local cFilAte 	:= aRet[2]
Local cDtIni  	:= DTos(aRet[3])
Local cDtFim  	:= DTos(aRet[4])
Local cSerIni 	:= aRet[5]
Local cSerFim 	:= aRet[6]
Local cNFIni  	:= aRet[7]
Local cNFFim  	:= aRet[8]   
Local cEspecie 	:= aRet[11]
Local aEspecie	:= {}
Local cForIni 	:= aRet[12]
Local cForFim 	:= aRet[13]
Local cLojaIni	:= aRet[14]
Local cLojaFim	:= aRet[15]
Local cModelo	:= aRet[18]
Local aModelo	:= {}
Local cEmIni  	:= DTos(aRet[19])
Local cEmFim  	:= DTos(aRet[20])
Local nDNfXml 	:= aRet[21] 
Local cGrupoIni	:= aRet[22]
Local cGrupoFim	:= aRet[23]
Local nBaseNf 	:= aRet[24]
Local nImpCanc	:= aRet[25]
Local nAmarrac	:= aRet[26]
Local cCfop		:= aRet[28]
Local aCfop		:= {}
Local cDB 	    := TcGetDB()   //FR - 31/10/2022 - AdequaÁ„o para uso em BD Oracle

Private cAliasXMl := GetNextAlias()

aEspecie := STRTOKARR(ALLTRIM(cEspecie),",")
If !Empty(aEspecie)
	cEspecie := ""
	For nX := 1 to Len(aEspecie)
		If !Empty(cEspecie)
			cEspecie += "','"
		EndIf 
		cEspecie += aEspecie[nX]
	Next nX
EndIf

aModelo := STRTOKARR(ALLTRIM(cModelo),",")
If !Empty(aModelo)
	cModelo := ""
	For nX := 1 to Len(aModelo)
		If aModelo[nX] $ 'NFE/CTE/NFSE/NFCE/CTEOS'		//FR - 14/01/2021
			If !Empty(cModelo)
				cModelo += "','"
			EndIf
			
			If UPPER(aModelo[nX]) == 'NFE' .or. UPPER(aModelo[nX]) == 'NFCE'		//FR - 14/01/2021
				cModelo += "55','65"
			ElseIf UPPER(aModelo[nX]) == 'CTE' .or. UPPER(aModelo[nX]) == 'CTEOS'	//FR - 14/01/2021
				cModelo += "57,67"
			ElseIf UPPER(aModelo[nX]) == 'NFSE'	
				cModelo += "RP"
			EndIf
		EndIf
	Next nX
EndIf 

aCfop := STRTOKARR(ALLTRIM(cCfop),",")
If !Empty(cCfop)
	cCfop := ""
	For nX := 1 to Len(aCfop)
		If !Empty(cCfop)
			cCfop += "','"
		EndIf 
		cCfop += aCfop[nX]
	Next nX
EndIf
//FR - 12/06/2020 - Tratativa para licenÁa Demo:
If aParams == Nil
	If lDemonstra
		If ( (StoD(cDtFim) - StoD(cDtIni) > 30) .or. (StoD(cEmFim) - StoD(cEmIni) > 30) )
			MsgInfo("Foi Digitado o PerÌodo: " + DtoC(StoD(cDtIni)) + " A " + DtoC(StoD(cDtFim)) + "." + CRLF+;
			"Esta È Uma LicenÁa de DemonstraÁ„o, o PerÌodo para Consulta Ser· Limitado a AtÈ 30 (Trinta) Dias Retroativos !")		
		Endif
	Endif
Endif

//-----------------------------------------------------------------------------------------------------------------------------------------//
//Caso o operador escolha a opÁ„o "base NF" e notas canceladas, a query abaixo n„o poder· ser executada (SF1) pois a nota estar· cancelada, 
//irei direcionar para a query que a base È o XML.
//Acredito ser mais prudente assim, pois, mesmo que fizesse uma query pegando as notas deletadas, n„o seria seguro exibir isto ao usu·rio.
//-----------------------------------------------------------------------------------------------------------------------------------------//
//Local aImpCanc	:= {"1=Todas",;
//					"2=Ativas",;
//					"3=Canceladas"}
//base somente NF e Notas n„o Canceladas
If nBaseNf == 1 .AND. nImpCanc <> 3

	cQuery := " SELECT	*, " + LF
	cQuery += "         A5_FORNECE, A5_LOJA, A5_PRODUTO, A5_NOMPROD, A5_CODPRF, " + LF + LF   //A5_CODPRF - cÛdigo do produto do fornecedor
 	
	For nX := 1 to Len(aCampos)
		cQuery += "         "
		For nY := 1 to Len(aCampos[nX,2])
			If !Empty(aCampos[nX,2,nY])
				cQuery += aCampos[nX,2,nY]+", "
			Endif 
		Next nY
		cQuery += LF +LF
	Next nX

	cQuery += "         ZBT.R_E_C_N_O_ ZBTRECNO, ZBZ.R_E_C_N_O_ ZBZRECNO " +LF + LF

	cQuery += "		FROM ( " +LF
	cQuery += "				SELECT "+LF
	//SF1
	cQuery += "						F1_FILIAL FILIAL, F1_DOC NOTA, F1_SERIE SERIE, (F1_FORNECE + F1_LOJA) AS ORDEM, F1_TIPO TIPONF, " + LF
 	cQuery += "						F1_ESPECIE ESPECIE, F1_EMISSAO EMINF, F1_DTDIGIT DTDIGIT, F1_CHVNFE, F1_DESCONT," + LF
 	cQuery += "						F1_VALBRUT VALBRUT, F1_VALMERC VALMERC, SF1.R_E_C_N_O_ F1RECNO, " + LF + LF	
 	//SD1
 	cQuery += "						D1_FILIAL, D1_DOC ITNOTA, D1_SERIE ITSERIE, D1_FORNECE, D1_LOJA, D1_ITEM, D1_COD, D1_QUANT, D1_UM , D1_VUNIT, D1_TOTAL, " + LF
 	cQuery += "						D1_EMISSAO, D1_CF, D1_CLASFIS , D1_DESC, "+ LF
 	//IPI
 	cQuery += "						D1_BASEIPI, D1_VALIPI, D1_IPI, " + LF
 	//ICM
 	cQuery += "						D1_BASEICM, D1_VALICM, D1_PICM, " + LF
 	//IR
 	cQuery += "						D1_BASEIRR, D1_VALIRR, D1_ALIQIRR, " + LF
 	//ISS
 	cQuery += "						D1_BASEISS, D1_VALISS, D1_ALIQISS, " + LF
 	//INSS
 	cQuery += "						D1_BASEINS, D1_ALIQINS, D1_VALINS, " + LF
 	//PIS
 	cQuery += "						D1_BASIMP6, D1_VALIMP6, D1_BASEPIS, D1_VALPIS, D1_ALQPIS, " + LF		//FR - 01/12/2020
 	//COFINS
 	cQuery += "						D1_BASIMP5, D1_VALIMP5, D1_BASECOF, D1_VALCOF, D1_ALQCOF, " + LF		//FR - 01/12/2020
 	//CSLL
 	cQuery += "						D1_BASECSL, D1_VALCSL, D1_ALQCSL,  SD1.R_E_C_N_O_ D1RECNO, " + LF + LF
 	//NCM
	cQuery += "						D1_TEC , " + LF
	//SB1
 	cQuery += "						B1_COD, B1_DESC, B1_GRUPO,"  + LF + LF 
	//CLIFOR
	cQuery += "						CASE WHEN F1_TIPO IN ('D','B') THEN A1_COD ELSE A2_COD END CLIFOR, "+LF
    cQuery += "						CASE WHEN F1_TIPO IN ('D','B') THEN A1_LOJA ELSE A2_LOJA END LOJA, "+LF
    cQuery += "						CASE WHEN F1_TIPO IN ('D','B') THEN A1_NOME ELSE A2_NOME END NOME, "+LF
    cQuery += "						CASE WHEN F1_TIPO IN ('D','B') THEN A1_NREDUZ ELSE A2_NREDUZ END NREDUZ, "+LF
    cQuery += "						CASE WHEN F1_TIPO IN ('D','B') THEN A1_TEL ELSE A2_TEL END TEL, "+LF
    cQuery += "						CASE WHEN F1_TIPO IN ('D','B') THEN A1_CGC ELSE A2_CGC END CNPJ, "+LF
    cQuery += "						CASE WHEN F1_TIPO IN ('D','B') THEN A1_EMAIL ELSE A2_EMAIL END EMAIL "+LF

	cQuery += "					FROM "+RetSqlName("SF1")+" SF1 " + LF
	//SA1
	cQuery += "						LEFT JOIN "+RetSqlName("SA1")+" SA1 " + LF
	cQuery += "							ON A1_COD = F1_FORNECE " + LF
	cQuery += "							AND A1_LOJA = F1_LOJA  " + LF
	cQuery += "							AND SA1.D_E_L_E_T_ = ' ' " + LF
	//SA2
	cQuery += "						LEFT JOIN "+RetSqlName("SA2")+" SA2 " + LF
	cQuery += "							ON A2_COD = F1_FORNECE " + LF
	cQuery += "							AND A2_LOJA = F1_LOJA  " + LF
	cQuery += "							AND SA2.D_E_L_E_T_ = ' ' " + LF
	//SD1
	cQuery += "						INNER JOIN "+RetSqlName("SD1")+" SD1 " + LF
	cQuery += "							ON D1_FILIAL 	= F1_FILIAL " + LF
	cQuery += "							AND D1_DOC 		= F1_DOC " + LF
	cQuery += "							AND D1_SERIE 	= F1_SERIE " + LF
	cQuery += "							AND F1_TIPO 	= D1_TIPO " + LF
	cQuery += "							AND F1_FORNECE 	= D1_FORNECE " + LF
	cQuery += "							AND F1_LOJA 	= D1_LOJA " + LF
	cQuery += "							AND SD1.D_E_L_E_T_ = ' ' " + LF
	//SB1
	cQuery += "						INNER JOIN "+RetSqlName("SB1")+" SB1 " + LF
	cQuery += "							ON B1_COD = D1_COD " + LF
    cQuery += "							AND B1_GRUPO BETWEEN '" + cGrupoIni + "' AND '"+ cGrupoFim + "' " + LF
	cQuery += "							AND SB1.D_E_L_E_T_ = ' ' " + LF
	cQuery += "						WHERE SF1.D_E_L_E_T_ = ' ' " + LF
	//If aParams == Nil    	//FR 15/05/2020
	If lQuery == Nil
		cQuery += "						AND SF1.F1_STATUS <> '' " + LF //somente notas classificadas 
	Endif
	
	If !lDemonstra		//FR - 11/06/2020 - tratativa para licenÁas Demo
		cQuery += "						AND ( SF1.F1_DTDIGIT BETWEEN '"+ cDtIni  +"' AND '"+cDtFim+"' " + LF
		cQuery += "               				AND SF1.F1_EMISSAO BETWEEN '"+cEmIni+"' AND '"+cEmFim+"' )"+ LF
	Else
		cQuery += "						AND ( SF1.F1_DTDIGIT BETWEEN '"+ DtoS(Date()-30)  +"' AND '"+DtoS(Date())+"' " + LF
		cQuery += "								AND SF1.F1_EMISSAO BETWEEN '"+DtoS(Date()-30)+"' AND '"+ DtoS(Date())+"' )" + LF		
	EndIf   			//FR - 11/06/2020 - tratativa para licenÁas Demo

	If !Empty(cEspecie)
		cQuery += "						AND SF1.F1_ESPECIE IN ('"+cEspecie+"') "+LF
	EndIf
	
	cQuery += "						AND SF1.F1_FILIAL	BETWEEN '"+cFilDe+"' AND '"+cFilAte+"' "+LF	
	cQuery += "						AND SF1.F1_DOC BETWEEN '"+cNFIni+"' AND '"+cNFFim+"' "+ LF
	cQuery += "						AND SF1.F1_SERIE BETWEEN '"+cSerIni+"' AND '"+cSerFim+"' "+LF						               
	cQuery += "						AND SF1.F1_FORNECE BETWEEN '"+cForIni+"' AND '"	+cForFim+"' "+LF					               
	cQuery += "						AND SF1.F1_LOJA	BETWEEN '"+cLojaIni+"' AND '"+cLojaFim+"' "+LF
	cQuery += "						AND SF1.F1_FORMUL <> 'S' "+LF
	cQuery += "				) TMP " +LF		               
    //SA5
	cQuery += "			LEFT JOIN "+RetSqlName("SA5")+" SA5 " + LF
	cQuery += "             ON A5_FORNECE = CLIFOR " + LF
    cQuery += "             AND A5_LOJA = LOJA " + LF
    cQuery += "             AND A5_PRODUTO = B1_COD " + LF
	cQuery += "             AND SA5.D_E_L_E_T_ = ' ' " + LF
	//ZBZ
	cQuery += "         LEFT JOIN " + RetSqlName(xZBZ) + " ZBZ " + LF
    cQuery += "             ON " + xZBZ_+"FILIAL = FILIAL " + LF
 	cQuery += "             AND " + xZBZ_+"CHAVE = F1_CHVNFE " + LF
 	cQuery += "             AND " + xZBZ_+"CNPJ  = CNPJ    " + LF
	cQuery += "             AND " + xZBZ_+"NOTA  = NOTA    " + LF
	cQuery += "             AND " + xZBZ_+"SERIE = SERIE  " + LF
	cQuery += "             AND " + xZBZ_+"TPDOC = TIPONF   " + LF
	If !Empty(cModelo)
		cQuery += "				AND " + xZBZ_+"MODELO IN ('"+cModelo+"') " +LF
	EndIf
	If !Empty(cCfop)
		cQuery += "				AND ( "
		cQuery += "				SUBSTRING(" + xZBZ_+"CFOP,1,4) IN ('"+cCfop+"') " +LF
		cQuery += "				OR SUBSTRING(" + xZBZ_+"CFOP,6,4) IN ('"+cCfop+"') " +LF
		cQuery += "				) "
	EndIf

	cQuery += "             AND ZBZ.D_E_L_E_T_ = ' ' " + LF

	/* //FR - 01/12/2020 - RETIRADO DAQUI E COLOCADO MAIS ABAIXO POR PROBLEMAS DE DUPICIDADE DE RESULTADOS	
	//ZBT
	cQuery += "         LEFT JOIN " + RetSqlName(xZBT) + " ZBT " + LF
    cQuery += "             ON " + xZBT_+"FILIAL = " + xZBZ_+"FILIAL " + LF  
	cQuery += "             AND " + xZBT_+"CHAVE  = " + xZBZ_+"CHAVE " 	+ LF
	//cQuery += "             AND RIGHT('000000000' + RTRIM(" + xZBT_+"NOTA),9)  = " + xZBZ_+"NOTA "  	+ LF
	//cQuery += "             AND " + xZBT_+"SERIE  = " + xZBZ_+"SERIE " 	+ LF
	//cQuery += "             AND " + xZBT_+"ITEM = SD1.D1_ITEM " + LF
	//cQuery += "             AND " + xZBT_+"PEDIDO = D1_PEDIDO " + LF
	//cQuery += "             AND " + xZBT_+"ITEMPC = D1_ITEMPC " + LF
	cQuery += "             AND ZBT.D_E_L_E_T_ = ' ' " + LF
	*/
	//ZB5
	cQuery += "         LEFT JOIN " + RetSqlName(xZB5) + " ZB5 " + LF
    //cQuery += "             ON "+ xZB5_+"FILIAL = "+xZBT_+"FILIAL " +LF
    cQuery += "             ON "+ xZB5_+"FILIAL = FILIAL " +LF         //FR - 01/12/2020
	cQuery += "             AND "+ xZB5_+"CGC = CNPJ "+LF
	cQuery += "             AND "+ xZB5_+"PRODFI = D1_COD " +LF  //nosso cÛdigo de amarraÁ„o ser igual ao cÛdigo da SD1
	cQuery += "             AND ZB5.D_E_L_E_T_ = ' ' " + LF
	//FR - 01/12/2020 - COLOCADO AQUI ESTE JOIN:
	//ZBT
	cQuery += "         LEFT JOIN " + RetSqlName(xZBT) + " ZBT " + LF
    cQuery += "             ON " + xZBT_+"FILIAL = " + xZBZ_+"FILIAL " + LF  
	cQuery += "             AND " + xZBT_+"CHAVE  = " + xZBZ_+"CHAVE " 	+ LF
	//cQuery += "             AND "+xZBT_+"PRODUT = "+ xZB5_+"PRODFO "				+ LF  //FR - 05/07/2023 - QUEIJOS IPANEMA
	//-----------------------------------------------------------------------------------//
	//BUSCA AMARRA«√O
	//FR - 03/05/2023 - REVIS√O DA QUERY: IGUALANDO COM SA5 AQUI TAMB…M, AL…M DA ZB5: 
	//cQuery += "             AND "+xZBT_+"PRODUT = "+ xZB5_+"PRODFO "	+ LF
	//-----------------------------------------------------------------------------------//
	cQuery += "             AND (                                        " + LF
	cQuery += "                     ("+xZBT_+"PRODUT = "+ xZB5_+"PRODFO) " + LF
	cQuery += "                  OR ("+xZBT_+"PRODUT = A5_CODPRF)        " + LF
	cQuery += "                  OR ("+xZBT_+"DEPARA = B1_COD )          " + LF 
	cQuery += "                  OR ("+xZBT_+"ITEM = D1_ITEM )                " + LF
	cQuery += "                  )                                       " + LF
	cQuery += "             AND ZBT.D_E_L_E_T_ = ' ' " + LF
	//FR - 01/12/2020
	If lQuery
		If nAmarrac == 2
			cQuery += "			AND ZBT."+xZBT_+"VUNIT IS NOT NULL " + LF
		EndIf

		If nDNfXml <> 1
			cQuery += "         AND ("
			
			If nDNfXml == 2 .OR. nDNfXml == 5
				cQrAux += " D1_VUNIT <> ZBT."+xZBT_+"VUNIT " +LF 
				cQrAux += "             OR D1_TOTAL <> ZBT."+xZBT_+"TOTAL " +LF  		
			EndIf

			If nDNfXml == 3 .OR. nDNfXml == 5
				If !Empty(cQrAux)
					cQrAux += "             OR"
				EndIf
				cQrAux += " D1_QUANT <> ZBT."+xZBT_+"QUANT " +LF
			EndIf

			If nDNfXml == 4 .OR. nDNfXml == 5
				If !Empty(cQrAux)
					cQrAux += "             OR"
				EndIf
				cQrAux += " D1_BASEIPI <> ZBT."+xZBT_+"IPIBAS " + LF
				cQrAux += "             OR D1_VALIPI <> ZBT."+xZBT_+"IPIVAL " + LF
				cQrAux += "             OR D1_IPI <> ZBT."+xZBT_+"IPIALQ " + LF
				cQrAux += "             OR D1_BASEICM <> ZBT."+xZBT_+"ICMBAS " + LF
				cQrAux += "             OR D1_VALICM <> ZBT."+xZBT_+"ICMVAL " + LF
				cQrAux += "             OR D1_PICM <> ZBT."+xZBT_+"ICMALQ " + LF
				//cQrAux += "             OR D1_BASEPIS <> ZBT."+xZBT_+"PISBAS " + LF
				cQrAux += "             OR D1_BASIMP6 <> ZBT."+xZBT_+"PISBAS " + LF		//FR - 01/12/2020
				//cQrAux += "             OR D1_VALPIS <> ZBT."+xZBT_+"PISVAL " + LF
				cQrAux += "             OR D1_VALIMP6 <> ZBT."+xZBT_+"PISVAL " + LF		//FR - 01/12/2020
				cQrAux += "             OR D1_ALQPIS <> ZBT."+xZBT_+"PISALQ " + LF
				//cQrAux += "             OR D1_BASECOF <> ZBT."+xZBT_+"COFBAS " + LF
				cQrAux += "             OR D1_BASIMP5 <> ZBT."+xZBT_+"COFBAS " + LF		//FR - 01/12/2020
				//cQrAux += "             OR D1_VALCOF <> ZBT."+xZBT_+"COFVAL " + LF
				cQrAux += "             OR D1_VALIMP5 <> ZBT."+xZBT_+"COFVAL " + LF		//FR - 01/12/2020
				cQrAux += "             OR D1_ALQCOF <> ZBT."+xZBT_+"COFALQ " + LF
			EndIf

			If nAmarrac == 1
				cQrAux += "			 		OR ZBT."+xZBT_+"VUNIT IS NULL " + LF
			EndIf 

			cQuery += cQrAux

			cQuery += "				) " + LF
			
		EndIf
	EndIf

	cQuery += " ORDER BY FILIAL, CLIFOR, LOJA, NOTA, SERIE, D1_ITEM " +LF
	Memowrite("C:\TEMP\HFXMLR16_NF.txt", cQuery)

//Base Xml 
Else 

	//cQuery := " SELECT	*, " + LF
	cQuery := " SELECT	TMP.* , " + LF //FR - 31/10/2022
	//SF1
	cQuery += "			F1_FILIAL FILIAL, F1_DOC NOTA, F1_SERIE SERIE, (F1_FORNECE + F1_LOJA) AS ORDEM, F1_TIPO TIPONF, " + LF
	cQuery += "			F1_ESPECIE ESPECIE, F1_EMISSAO EMINF, F1_DTDIGIT DTDIGIT, F1_CHVNFE, " + LF
	cQuery += "			F1_VALBRUT VALBRUT, F1_VALMERC VALMERC, SF1.R_E_C_N_O_ F1RECNO, " + LF + LF	
	//SD1
	cQuery += "			D1_FILIAL, D1_DOC ITNOTA, D1_SERIE ITSERIE, D1_FORNECE, D1_LOJA, D1_ITEM, D1_COD, D1_QUANT, D1_UM, D1_VUNIT, D1_TOTAL, " + LF
	cQuery += "			D1_EMISSAO, D1_CLASFIS, D1_DESC, SD1.R_E_C_N_O_ D1RECNO, "+ LF
	//IPI
	cQuery += "			D1_BASEIPI, D1_VALIPI, D1_IPI, " + LF
	//ICM
	cQuery += "			D1_BASEICM, D1_VALICM, D1_PICM, " + LF
	//IR
	cQuery += "			D1_BASEIRR, D1_VALIRR, D1_ALIQIRR, " + LF
	//ISS
	cQuery += "			D1_BASEISS, D1_VALISS, D1_ALIQISS, " + LF
	//INSS
	cQuery += "			D1_BASEINS, D1_ALIQINS, D1_VALINS, " + LF
	//PIS
	cQuery += "			D1_BASIMP6, D1_VALIMP6, D1_BASEPIS, D1_VALPIS, D1_ALQPIS, " + LF	//FR - 01/12/2020
	//COFINS
	cQuery += "			D1_BASIMP5, D1_VALIMP5, D1_BASECOF, D1_VALCOF, D1_ALQCOF, " + LF	//FR - 01/12/2020
	//CSLL
	cQuery += "			D1_BASECSL, D1_VALCSL, D1_ALQCSL,  " + LF + LF
	//NCM
	cQuery += "			D1_TEC , " + LF
	//CFOP
	cQuery += "         D1_CF , " + LF
	//SA5
	cQuery += "         A5_FORNECE, A5_LOJA, A5_PRODUTO, A5_NOMPROD, A5_CODPRF " + LF + LF   //A5_CODPRF - cÛdigo do produto do fornecedor
	
	cQuery += "		FROM ( " +LF
	cQuery += "				SELECT	" + LF
	//SB1
	cQuery += "						SB1.B1_COD, SB1.B1_DESC, SB1.B1_GRUPO,"  + LF + LF 
	For nX := 1 to Len(aCampos)
		cQuery += "						"
		For nY := 1 to Len(aCampos[nX,2])
			If !Empty(aCampos[nX,2,nY])
				cQuery += aCampos[nX,2,nY]+", "
			Endif 
		Next nY
		cQuery += LF +LF
	Next nX

	cQuery += "						ZBT.R_E_C_N_O_ ZBTRECNO, ZBZ.R_E_C_N_O_ ZBZRECNO, ZBZ.D_E_L_E_T_ ZBTDEL, "  +LF + LF

	//CLIFOR
	cQuery += "						CASE WHEN "+xZBZ_+"TPDOC IN ('D','B') THEN A1_COD ELSE A2_COD END CLIFOR, "+LF
    cQuery += "						CASE WHEN "+xZBZ_+"TPDOC IN ('D','B') THEN A1_LOJA ELSE A2_LOJA END LOJA, "+LF
    cQuery += "						CASE WHEN "+xZBZ_+"TPDOC IN ('D','B') THEN A1_NOME ELSE A2_NOME END NOME, "+LF
    cQuery += "						CASE WHEN "+xZBZ_+"TPDOC IN ('D','B') THEN A1_NREDUZ ELSE A2_NREDUZ END NREDUZ, "+LF
    cQuery += "						CASE WHEN "+xZBZ_+"TPDOC IN ('D','B') THEN A1_TEL ELSE A2_TEL END TEL, "+LF
    cQuery += "						CASE WHEN "+xZBZ_+"TPDOC IN ('D','B') THEN A1_CGC ELSE A2_CGC END CNPJ, "+LF
    cQuery += "						CASE WHEN "+xZBZ_+"TPDOC IN ('D','B') THEN A1_EMAIL ELSE A2_EMAIL END EMAIL "+LF

	cQuery += "					FROM " + RetSqlName(xZBZ) + " ZBZ " + LF
	//ZBT
	cQuery += "						INNER JOIN " + RetSqlName(xZBT) + " ZBT " + LF
	cQuery += "							ON " + xZBT_+"FILIAL = " + xZBZ_+"FILIAL " + LF  
	cQuery += "							AND " + xZBT_+"CHAVE  = " + xZBZ_+"CHAVE " 	+ LF
	//cQuery += "						AND RIGHT('000000000' + RTRIM(" + xZBT_+"NOTA),9)  = " + xZBZ_+"NOTA "  	+ LF
	//cQuery += "						AND " + xZBT_+"SERIE  = " + xZBZ_+"SERIE " 	+ LF
	cQuery += "							AND ZBT.D_E_L_E_T_ = ' ' " + LF
	//ZB5 
	cQuery += "						LEFT JOIN " + RetSqlName(xZB5) + " ZB5 "  + LF
	cQuery += "							ON  " + xZB5_+"CGC    = "+ xZBZ_+"CNPJ "  + LF
	cQuery += "							AND " + xZB5_+"PRODFO = "+ xZBT_+"PRODUT "+ LF
	cQuery += "							AND ZB5.D_E_L_E_T_ = ' ' " + LF
	
	//SA5
	cQuery += "						LEFT JOIN " + RetSqlName("SA5") + " SA5 "  + LF
	cQuery += "							ON  A5_PRODUTO = " + xZB5_+"PRODFI "  + LF
	cQuery += "							AND SA5.D_E_L_E_T_ = ' ' " + LF
	
	//SB1	
	cQuery += "						LEFT JOIN " + RetSqlName("SB1") + " SB1 "  + LF
	cQuery += "							ON  ( SB1.B1_COD = " + xZBT_+"DEPARA OR SB1.B1_COD = SA5.A5_PRODUTO ) "  + LF
	cQuery += "							AND SB1.D_E_L_E_T_ = ' ' " + LF
	
	//SA2
	cQuery += "						LEFT JOIN "+RetSqlName("SA2")+" SA2 " + LF
	cQuery += "							ON A2_CGC = "+xZBZ_+"CNPJ " + LF
	cQuery += "							AND SA2.D_E_L_E_T_ = ' ' " + LF
	//SA1
	cQuery += "						LEFT JOIN "+RetSqlName("SA1")+" SA1 " + LF
	cQuery += "							ON A1_CGC = "+xZBZ_+"CNPJ " + LF
	cQuery += "							AND SA1.D_E_L_E_T_ = ' ' " + LF
	//ZBZ
	cQuery += "						WHERE ZBZ.D_E_L_E_T_ = ' ' "+LF
	cQuery += "						AND ZBZ."+xZBZ_+"FILIAL BETWEEN '"+cFilDe+"' AND '"+cFilAte+"' " + LF

	If !Empty(cModelo)
		cQuery += "				    AND " + xZBZ_+"MODELO IN ('"+cModelo+"') " +LF
	EndIf
	
	If !lDemonstra		//FR - 11/06/2020 - tratativa para licenÁas Demo
		cQuery += "						AND ZBZ."+xZBZ_+"DTNFE BETWEEN '"+cEmIni+"' AND '"+cEmFim+"' " + LF
	Else
		cQuery += "						AND ZBZ."+xZBZ_+"DTNFE BETWEEN '"+DtoS(Date()-30)+"' AND '"+DtoS(Date())+"' " + LF	
	Endif				//FR - 11/06/2020 - tratativa para licenÁas Demo
	
	cQuery += "						AND ZBZ."+xZBZ_+"NOTA BETWEEN '"+cNFIni+"' AND '"+cNFFim+"' " + LF
	cQuery += "						AND ZBZ."+xZBZ_+"SERIE BETWEEN '"+cSerIni+"' AND '"+cSerFim+"' " + LF
	cQuery += "						AND ZBZ."+xZBZ_+"CODFOR BETWEEN '"+cForIni+"' AND '"+cForFim+"' " + LF
	cQuery += "						AND ZBZ."+xZBZ_+"LOJFOR BETWEEN '"+cLojaIni+"' AND '"+cLojaFim+"' " + LF
	
	If nImpCanc == 2		//"2 -> Imprime somente as notas n„o canceladas"
		cQuery += "						AND "+xZBZ_+"PRENF <> 'X' " + LF
	ElseIf nImpCanc == 3	//"3 -> Imprime somente as notas canceladas"
		cQuery += "						AND "+xZBZ_+"PRENF = 'X' " + LF 
	EndIf
	cQuery += "				) TMP " +LF
	
	//SD1
	cQuery += "			LEFT JOIN " + RetSqlName("SD1") + " SD1 " + LF
	cQuery += "				ON D1_FILIAL = "+ xZBZ_+"FILIAL " + LF
	cQuery += "				AND D1_DOC = "+ xZBZ_+"NOTA " + LF
	cQuery += "				AND D1_SERIE = "+ xZBZ_+"SERIE " + LF
	cQuery += "				AND D1_TIPO = "+ xZBZ_+"TPDOC " + LF
	cQuery += "				AND D1_ITEM = "+ xZBT_+"ITEM " + LF
	cQuery += "				AND D1_FORNECE = CLIFOR " + LF
	cQuery += "				AND D1_LOJA = LOJA " + LF
	cQuery += "             AND " + xZBT_+ "ITEM = D1_ITEM  " + LF //FR - 03/05/2023 - revis„o query - QUEIJOS IPANEMA
	cQuery += "				AND SD1.D_E_L_E_T_ = ' ' " + LF
	//SF1
	cQuery += "			LEFT JOIN " + RetSqlName("SF1") + " SF1 " + LF"
	cQuery += "				ON F1_FILIAL 	= D1_FILIAL " + LF
	cQuery += "				AND F1_DOC 		= D1_DOC " + LF
	cQuery += "				AND F1_SERIE 	= D1_SERIE " + LF
	cQuery += "				AND F1_TIPO 	= D1_TIPO " + LF
	cQuery += "				AND F1_FORNECE 	= D1_FORNECE " + LF
	cQuery += "				AND F1_LOJA 	= D1_LOJA " + LF
	If !lDemonstra		//FR - 11/06/2020 - tratativa para licenÁas Demo
		cQuery += "			AND ( SF1.F1_DTDIGIT BETWEEN '"+ cDtIni  +"' AND '"+cDtFim+"' " + LF
		cQuery += " 		AND   SF1.F1_EMISSAO BETWEEN '"+cEmIni+"' AND '"+cEmFim+"' )"+ LF
	Else
		cQuery += "			AND ( SF1.F1_DTDIGIT BETWEEN '"+ DtoS(Date()-30)  +"' AND '"+DtoS(Date())+"' " + LF
		cQuery += "			AND SF1.F1_EMISSAO BETWEEN '"+DtoS(Date()-30)+"' AND '"+ DtoS(Date())+"' )" + LF		
	EndIf   			//FR - 11/06/2020 - tratativa para licenÁas Demo
		
	//SB1
	cQuery += "			LEFT JOIN " + RetSqlName("SB1") + " SB1F " + LF
	cQuery += "				ON  SB1F.B1_COD = D1_COD " + LF		
	//cQuery += "             AND ("+xZBT_+"DEPARA = B1_COD )          " + LF
	cQuery += "				AND SB1F.D_E_L_E_T_ = ' ' " + LF

	//SA5
	cQuery += "			LEFT JOIN " + RetSqlName("SA5") + " SA5 " + LF
	cQuery += "				ON A5_FORNECE = CLIFOR " + LF
	cQuery += "				AND A5_LOJA = LOJA " + LF
	cQuery += "				AND A5_PRODUTO = SB1F.B1_COD " + LF
	cQuery += "             AND "+xZBT_+"PRODUT = A5_CODPRF " + LF
	cQuery += "				AND SA5.D_E_L_E_T_ = ' ' " + LF
	
	
	If !Empty(cEspecie)
		cQuery += "				AND SF1.F1_ESPECIE IN ('"+cEspecie+"') "+LF
	EndIf

	cQuery += "             AND F1_CHVNFE = "+ xZBZ_+"CHAVE " + LF
	cQuery += "             AND SF1.D_E_L_E_T_ = ' ' " + LF

	cQuery += "			WHERE ZBTDEL = ' ' "+LF
	//If aParams == Nil		//FR 15/05/2020
	If lQuery
		If nAmarrac == 2
			cQuery += "			AND SD1.D1_VUNIT IS NOT NULL " + LF
		EndIf

		If nDNfXml <> 1
			cQuery += "			AND ("
			
			If nDNfXml == 2 .OR. nDNfXml == 5
				cQrAux += " SD1.D1_VUNIT <> "+xZBT_+"VUNIT " +LF 
				cQrAux += "				OR SD1.D1_TOTAL <> "+xZBT_+"TOTAL " +LF  		
			EndIf

			If nDNfXml == 3 .OR. nDNfXml == 5
				If !Empty(cQrAux)
					cQrAux += "				OR"
				EndIf
				cQrAux += " SD1.D1_QUANT <> "+xZBT_+"QUANT " +LF
			EndIf

			If nDNfXml == 4 .OR. nDNfXml == 5
				If !Empty(cQrAux)
					cQrAux += "				OR"
				EndIf
				cQrAux += " SD1.D1_BASEIPI <> "+xZBT_+"IPIBAS " + LF
				cQrAux += "				OR SD1.D1_VALIPI <> "+xZBT_+"IPIVAL " + LF
				cQrAux += "				OR SD1.D1_IPI <> "+xZBT_+"IPIALQ " + LF
				cQrAux += "				OR SD1.D1_BASEICM <> "+xZBT_+"ICMBAS " + LF
				cQrAux += "				OR SD1.D1_VALICM <> "+xZBT_+"ICMVAL " + LF
				cQrAux += "				OR SD1.D1_PICM <> "+xZBT_+"ICMALQ " + LF
				//cQrAux += "				OR SD1.D1_BASEPIS <> "+xZBT_+"PISBAS " + LF
				cQrAux += "				OR SD1.D1_BASIMP6 <> "+xZBT_+"PISBAS " + LF		//FR - 01/12/2020
				//cQrAux += "				OR SD1.D1_VALPIS <> "+xZBT_+"PISVAL " + LF
				cQrAux += "				OR SD1.D1_VALIMP6 <> "+xZBT_+"PISVAL " + LF		//FR - 01/12/2020
				cQrAux += "				OR SD1.D1_ALQPIS <> "+xZBT_+"PISALQ " + LF
				//cQrAux += "				OR SD1.D1_BASECOF <> "+xZBT_+"COFBAS " + LF
				cQrAux += "				OR SD1.D1_BASIMP5 <> "+xZBT_+"COFBAS " + LF		//FR - 01/12/2020
				//cQrAux += "				OR SD1.D1_VALCOF <> "+xZBT_+"COFVAL " + LF
				cQrAux += "				OR SD1.D1_VALIMP5 <> "+xZBT_+"COFVAL " + LF		//FR - 01/12/2020
				cQrAux += "				OR SD1.D1_ALQCOF <> "+xZBT_+"COFALQ " + LF
			EndIf

			If nAmarrac == 1 						
				cQrAux += "				OR SD1.D1_VUNIT IS NULL " + LF		//FR 19/05/2020
			EndIf

			cQuery += cQrAux

			cQuery += "				) " + LF
		EndIf
	EndIf

	cQuery += " ORDER BY " + xZBZ_+"FILIAL, "+ xZBZ_+"CNPJ, " + xZBZ_+"NOTA, " + xZBZ_+"SERIE, ZBTRECNO " + LF
	Memowrite("C:\TEMP\HFXMLR16_XML.txt", cQuery)
EndIf

Memowrite("C:\TEMP\HFXMLR16.txt", cQuery)

If Select("TRB") > 0
	dbSelectArea("TRB")
	dbCloseArea()
Endif

//+-----------------------
//| Cria uma view no banco
//+-----------------------
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TRB", .T., .F. )
dbSelectArea("TRB")

 //Contando os registros e voltando ao topo da tabela
Count To nTotReg

TRB->( dbGoTop() )

DbSelectArea(xZBZ)
DbSetOrder(6) 

//DbSelectArea("TRB") 

//DbGoTop() 

Return

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ HF16Erro  ∫Autor  ≥ Renan Oliveira  ∫ Data ≥  22/04/2020  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Verifica tabelas ou campos do relatorio                   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ IMPORTA XML                                               ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function HF16Erro(aTab,aCampos)

Local nX		:= 0
Local nY		:= 0
Local aErros	:= {"",""}

For nX := 1 to Len(aTab)
	If !ChkFile(aTab[nX])
		If Empty(aErros[1])
			aErros[1] := aTab[nX]
		Else
			aErros[1] += " / "+aTab[nX]
		EndIf
	Else
		dbSelectArea(aTab[nX])
	EndIf
Next nX

If Empty(aErros[1])
	For nX := 1 to Len(aCampos)
		dbSelectArea(aCampos[nX,1])
		For nY := 1 to Len(aCampos[nX,2])
			If FieldPos(aCampos[nX,2,nY]) == 0
				If Empty(aErros[2])
					aErros[2] := aCampos[nX,2,nY]
				Else
					aErros[2] += " / "+aCampos[nX,2,nY]
				EndIf
			EndIf
		Next nY
	Next nX
EndIf

Return(aErros)
