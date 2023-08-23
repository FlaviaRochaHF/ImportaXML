#INCLUDE "MATA145.CH"
#INCLUDE "PROTHEUS.CH"
#DEFINE APOS { 15, 1, 65, 315 }
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³U_XMATA145³ Autor ³ Eneovaldo Roveri Jr.  ³ Data ³18.07.2013  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ (HF) Cadastro de Aviso de Recebimento (Via Importa Xml)      ³±±
±±           ³ Variáveis e Funções começadas por "_" são nossas para        ³±±
±±           ³ controles de rotinas e telas                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
USer Function XMATA145(xAutoCab,xAutoIt,xAutoIt2,nOpcAuto)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aCoresUsr := {}
Local aCores := {{"(Empty(DB1_HOMOLO).Or.DB1_HOMOLO=='1')",'ENABLE' },;	    //-- A.R. Nao Homologado
									   { "DB1_HOMOLO=='2'",'BR_AMARELO'},;	//-- A.R. Parcialmente Homologado
								       { "DB1_HOMOLO=='3'",'DISABLE'}}		//-- A.R. Homologado
Local aRotAdic  	:= {}
Local _lRet         := .T.   //(HF) nossa variável para receber retornos das funções ditas como padrão.
Local _nRet         := 0     //(HF) variável para retornar ao HFXML02, para fazer os devidos tratamentos.
Private _cNrAvRC    := ""  //(HF) para garantir o posicionamento do DB1 quando incluido com sucesso.
Private cCadastro 	:= OemToAnsi(STR0001) //"Aviso de Recebimento"
Private aRotina		:= MenuDef()
Private cTipo      	:= DB1->DB1_TIPONF
Private nOri  
Private aAutoCab	:= {}
Private aAutoIt		:= {}
Private aAutoIt2	:= {}
Private l145Auto 	:= (ValType(xAutoCab)	== "A" .AND.ValType(nOpcAuto)	== "N"  ) 
Private aLegenda    := {{'ENABLE',STR0036},; //'Legenda'###'A.R. Nao Homologado'
						{'BR_AMARELO',STR0037},; //'A.R. Parcialmente Homologado'
						{'DISABLE',STR0038}}
						
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida opcao da execauto³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If l145Auto .And. !(nOpcAuto >= 3 .AND. nOpcAuto <= 6)
	l145Auto := .F.
ElseIf l145Auto .And. (nOpcAuto == 3 .OR. nOpcAuto == 4) .AND.;
	(ValType(xAutoIt2) != "A" .OR. ValType(xAutoIt) != "A")
	l145Auto := .F.
EndIf

If !M145ChkInd()
   Return
EndIf

AjustaSX1()
AjustaSX3()
AjustaHelp()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada para inclusão de novo STATUS da legenda     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( ExistBlock("MT145LEG") )
	aCoresUsr := ExecBlock("MT145LEG",.F.,.F.,{aCores})
	If ( ValType(aCoresUsr) == "A" )
		aCores := aClone(aCoresUsr)
	EndIf
EndIf
                

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ P.E. Utilizado para adicionar botoes ao Menu Principal       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !l145Auto .And. ExistBlock("MT145MNU")
	aRotAdic := ExecBlock("MT145MNU",.F.,.F.)
	If ValType(aRotAdic) == "A"
		AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Exibe mBrowse se a rotina nao for executada via execauto³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !l145Auto
	Set Key VK_F12 To M145F12()
	mBrowse(6, 1, 22, 75, "DB1",,,,,,aCores)
	Set Key VK_F12 To 
Else
	aAutoCab	:= aClone(xAutoCab)
	aAutoIt		:= aClone(xAutoIt)
	aAutoIt2	:= aClone(xAutoIt2)

	//MBrowseAuto(nOpcAuto,Aclone(xAutoCab),"DB1")   (HF) aqui é o padron

	if nOpcAuto == 6
		_lRet := .T.                                     //(HF) aqui é quando é só homologar
		_cNrAvRC := DB1->DB1_NRAVRC
	else
		_lRet := U_M145Incl("DB1",Recno(),nOpcAuto)      //(HF) chamamos a inclusão do bixo
		if _lRet
			_nRet := 1
		endif
	endif

	if _lRet  //(HF) dentro desse if é nosso.
		lMsErroAuto := .F.  //(HF) para não mostrar erros de digitação do browse que foi acertado.
		l145Auto = .F.      //(HF) para a rotina da homologação ser visual
		_lRet := ( U_MyAviso("Homologação","Deseja Homologar este Aviso de Recebimento de Carga ("+_cNrAvRC+")",{"SIM","NAO"},1) == 1 )
		Do While .T.
			if _lRet
				lMsErroAuto := .F.  //(HF) para não mostrar erros de digitação do browse que foi acertado.
				DbSeek(xFilial("DB1") + _cNrAvRC)
				_lRet := U_M145AltE("DB1",Recno(),6)  //nOpcAuto := 6
				if _lRet
					lMsErroAuto := .F.  //(HF) para não mostrar erros de digitação do browse que foi acertado.
					_nRet := 2
					exit
				endif
			endif
			_lRet := ( U_MyAviso("Atenção","Você cancelou a Homologação. Para Homologar este Aviso de Recebimento de Carga ("+;
			   			_cNrAvRC+") você terá que utilizar a opção de Aviso de Recebimento de Carga. "+;
			   			"O que você deseja fazer?",{"Homologar","Sair S/Homol."},2) == 1 )
			if .not. _lRet
			   exit
			endif
		EndDo
	endif

EndIf

// (HF) valores de _nRet
// 0 => cancelado a inclusão (rotina abortada, não faz nada)
// 1 => Aviso de Recebimento Incluido, porém não Homologado
// 2 => Aviso de Recebimento Incluido e Homologado

Return( _nRet )  //(HF) no padron retorna .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ M145F12  ³ Autor ³Alexandre Inacio Lemes ³ Data ³11/11/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chama a pergunte do MATA145                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA145                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function M145F12()
Pergunte("MTA145",.T.)
If ExistBlock("MT145SX1")
	ExecBlock("MT145SX1",.F.,.F.)
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³M145Inclui³ Autor ³ Aline Correa do Vale  ³ Data ³29.01.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de Tratamento da Inclusao                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias do arquivo                                     ³±±
±±³          ³ExpN2: Registro do Arquivo                                  ³±±
±±³          ³ExpN3: Opcao da MBrowse                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³05/01/2006³Norbert Waage  ³Incluido tratamento para execucao automatica³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function M145Incl(cAlias,nReg,nOpcx)

Local aSize      := MsAdvSize()
Local oGetDad1
Local oGetDad2
Local aButtons   := {}
Local aButtonUsr := {}
Local aPosObj    := {}
Local aObjects   := {}
Local aArea      := GetArea()
Local aTitles    := {OemToAnsi(STR0010),OemToAnsi(STR0011)} //'Notas Fiscais'###'Itens da Nota Fiscal'
Local cOldFilter := ''
Local nGd1       := 0
Local nGd2       := 0
Local nGd3       := 0
Local nGd4       := 0
Local nPosDoc	 := 0
Local nX         := 0
Local nY         := 0
Local nOpcA      := 0
Local nSaveSX8   := GetSX8Len()
Local oDlg
Local aCpos      := {}
Local aAlter     := {}
Local bKeyF12    := Nil
Local nPosAut	 := 0
Local lM145NOBT	 := .F.
Local _lShowTela := .T.       //(HF) nossa var para visualizaire a teila - hfxml.
Local _bMontCols := {|| .F. } //(HF) nossa var pa carrega os acoles

Private aHeader  := {}
Private aCols    := {}
Private aHeader1 := {}
Private aCols1   := {}
Private aHeader2 := {}
Private aCols2   := {}
Private aColsIt  := {''}
Private oFolder
Private oGetDados
Private cCliFor  := ""    
Private cLoja    := ""
Private cTipoCF  := ""
Private aTELA[0][0],aGETS[0]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Habilita as HotKeys e botoes da barra de ferramentas         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !l145Auto .or. _lShowTela   //(HF) Abilitar F5 F6 para nós também
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de Entrada  para inibir os botoes e HotKeys            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("M145NOBT")
	     lM145NOBT:= ExecBlock("M145NOBT",.F.,.F.)
	     If ValType(lM145NOBT) != "L"
	        lM145NOBT:= .F.
	     Endif
	Endif
	If !lM145NOBT
	aButtons	:= {{'PEDIDO' ,{||IIf(oFolder:nOption==2,U_XML5F5PC(),.f.)}         ,STR0008+" - <F5> ",STR0044},; //"Selecionar Pedido de Compra"
	                {'SDUPROP',{||IIf(oFolder:nOption==2,U_XML5F6PC(@oGetDad2),.f.)},STR0009+" - <F6> ",STR0045} } //"Selecionar Pedido de Compra ( por item )"	
	SetKey( VK_F5, { || IIf(oFolder:nOption==2,U_XML5F5PC(),.F.)  } )
	SetKey( VK_F6, { || IIf(oFolder:nOption==2,U_XML5F6PC(@oGetDad2),.F.) } )	
	Endif
EndIf

dbSelectArea('DB1')
dbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada para adicionar botoes do Usuario na ToolBar  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( ExistBlock("M145BUT") ) .And. !l145Auto
	aButtonUsr := ExecBlock("M145BUT",.F.,.F.,{nOpcx})
	If ( ValType(aButtonUsr) == "A" )
		For nX := 1 To Len(aButtonUsr)
			Aadd(aButtons,aClone(aButtonUsr[nX]))
		Next nX
	EndIf
EndIf

bKeyF12 := SetKey( VK_F12 , Nil )
Set Key VK_F12 To M145F12()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Limpa algum filtro do DB1                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea('DB1')
cOldFilter := dbFilter()
dbClearFilter()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montagem da Variaveis de Memoria                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 To FCount()
	M->&(FieldName(nX)) := CriaVar(FieldName(nX))
	If (FieldName(nX)) != "DB1_HOMOLO"
		Aadd(aCpos,FieldName(nX))
	EndIf
Next nX
cTipo := M->DB1_TIPONF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Preenche variaveis de memoria com valores recebidos via³
//³execauto                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If l145Auto

	For nX := 1 To FCount()
		If ProcH(FieldName(nX)) > 0
			M->&(FieldName(nX)) := aAutoCab[ProcH(FieldName(nX)),2]
		EndIf
	Next nX

	If ProcH("DB1_TIPONF") > 0
		cTipo := aAutoCab[ProcH("DB1_TIPONF"),2]
	EndIf

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montagem do aHeader e aCols (1) usando a Funcao FillGetDados  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("DB2")
dbSetOrder(1)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sintaxe da FillGetDados(nOpcX,Alias,nOrdem,cSeek,bSeekWhile,uSeekFor,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//FillGetDados(nOpcX,"DB2",1,,,,/*aNoFields*/,,,,,.T.,,,,,)          (HF) aqui é o padron
_bMontCols := { || _MontaAcols( aAutoIt ) }							 //(HF) _MontaAcols( aAutoIt ) -> nossa função
FillGetDados(nOpcX,"DB2",1,,,,/*aNoFields*/,,,,_bMontCols,.T.,,,,,)  //(HF) _bMontCols nosso bloco
//aCols[1][aScan(aHeader,{|x| Trim(x[2])=="DB2_ITEM"})] := StrZero(1,Len(DB2->DB2_ITEM))  (HF) aqui é o padron

aHeader1 := aClone(aHeader)
aCols1   := aClone(aCols)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montagem do aHeader e aCols (2) usando a Funcao FillGetDados  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeader:= {}
aCols  := {}

dbSelectArea("DB3")
dbSetOrder(1)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sintaxe da FillGetDados(nOpcX,Alias,nOrdem,cSeek,bSeekWhile,uSeekFor,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//FillGetDados(nOpcX,"DB3",1,,,,/*aNoFields*/,,,,,.T.,,,,,)   (HF) aqui é o padrão
_bMontCols := { || _MontaAcols( aAutoIt2 ) }                  //(HF) _MontaAcols( aAutoIt2 ) -> nossa função
FillGetDados(nOpcX,"DB3",1,,,,/*aNoFields*/,,,,_bMontCols,.T.,,,,,)   //(HF) _bMontCols nosso bloco
//aCols[1][aScan(aHeader,{|x| Trim(x[2])=="DB3_ITDOC"})]:= StrZero(1,Len(DB3->DB3_ITDOC))  (HF) aqui é o padrão
//aCols[1][aScan(aHeader,{|x| Trim(x[2])=="DB3_ITEM"})] := StrZero(1,Len(DB3->DB3_ITEM))   (HF) aqui é o padrão

For nX := 1 To Len(aHeader)
	If AllTrim(aHeader[nX,2]) != "DB3_ITDOC"
		Aadd(aAlter,AllTrim(aHeader[nX,2]))
	EndIf
Next nX

aHeader2  := aClone(aHeader)
aCols2    := aClone(aCols)
aColsIt[1]:= aClone(aCols)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se a execucao for manual, exibe interface³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !l145Auto .or. _lShowTela  //(HF) _lShowTela variavel nossa

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta a tela principal³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aObjects := {}
	aAdd( aObjects, {   0,  90, .t., .f. } )
	aAdd( aObjects, { 100, 100, .t., .t. } )
	
	aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects )
	
	DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],00 To aSize[6],aSize[5] OF oMainWnd PIXEL
	EnChoice( cAlias ,nReg, nOpcx, , , , , APOSOBJ[1], aCpos , nOpcx)
	
	oFolder := TFolder():New(aPosObj[2,1],aPosObj[2,2],aTitles,{'',''},oDlg,,,,.T.,.F.,aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1])
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define as posicoes da Getdados a partir do folder    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nGd1 := 2
	nGd2 := 2
	nGd3 := aPosObj[2,3]-aPosObj[2,1]-15
	nGd4 := aPosObj[2,4]-aPosObj[2,2]-4
	
	aHeader  := aClone(aHeader2)
	aCols    := aClone(aCols2)
	oGetDad2 := MSGetDados():New(nGd1,nGd2,nGd3,nGd4,nOpcx,'U_M145LOk2','U_M145TOk2','+DB3_ITEM',.T.,aAlter,,.T.,900,'U_M145COK',,,,oFolder:aDialogs[2])
	oGetDad2 :oBrowse:lDisablePaint := .T.
	oGetDad2:lF3Header = .T.
	
	aHeader  := aClone(aHeader1)
	aCols    := aClone(aCols1)
	oGetDad1 := MSGetDados():New(nGd1,nGd2,nGd3,nGd4,nOpcx,'U_M145LOk1','U_M145TOk1','+DB2_ITEM',.T.,,,.T.,900,'U_M145COK',,,,oFolder:aDialogs[1])
	oGetDad1 :oBrowse:lDisablePaint := .T.
	
	oFolder:bSetOption:={|nAtu| M145Fld(nAtu,oFolder:nOption,oFolder,{oGetDad1,oGetDad2})}
	
	ACTIVATE MSDIALOG oDlg ON INIT (M145Refre({oGetDad1,oGetDad2}), EnchoiceBar(oDlg,{|| If(Obrigatorio(aGets,aTela) .And. U_M145TdOk(nOpcx) .And. U_A145FldR(oFolder),(nOpcA:=1,oDlg:End()),nOpcA:=0)},{||(nOpcA:=2,oDlg:End())},,aButtons))

Else

	nOpcA := 1 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Validacao das Gets³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aValidGet := {}
	
	For nX :=1 to Len(aCpos)
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Pula campo Filial³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If AllTrim(aCpos[nX]) == 'DB1_FILIAL'
			Loop
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Inclui validacao da chave primaria³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If AllTrim(aCpos[nX]) == "DB1_NRAVRC"
			Aadd(aValidGet,{aCpos[nX] ,M->&(aCpos[nX]),"CheckSX3('" + aCpos[nX] + "') .AND. ExistChav('DB1')",.F.})
			Loop
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida todos os campos obrigatorios, independente de terem³
		//³sido enviados pela execauto                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( ProcH(aCpos[nX]) != 0 ) .OR. ( X3Obrigat(aCpos[nX]) )
			Aadd(aValidGet,{aCpos[nX] ,M->&(aCpos[nX]),"CheckSX3('" + aCpos[nX] + "')",.F.})
		EndIf
		
	Next nX
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Executa validacoes³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If !DB1->(MsVldGAuto(aValidGet))
		nOpcA := 0
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Prepara e valida GetDados1³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aHeader  := aClone(aHeader1)
	aCols    := aClone(aCols1)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se nao existir coluna do item, cria-a³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 to Len(aAutoIt)
		If (nY := AScan(aAutoIt[nX],{|x| AllTrim(x[1]) == "DB2_ITEM"})) == 0
			AAdd(aAutoIt[nX],{"DB2_ITEM",StrZero(nX,3),NIL})
		Else
			If Empty(aAutoIt[nX][nY])
				aAutoIt[nX][nY] := StrZero(nX,3)
			EndIf
		EndIf
	Next nX

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida getdados³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If	(nOpcA == 1) .And. !MsGetDAuto(aAutoIt,"U_M145LOk1",{|| U_M145TOk1()},aAutoCab,aRotina[nOpcx][4]) 
		nOpcA := 0
	EndIf

	aHeader1	:= aClone(aHeader)
	aCols1		:= aClone(aCols)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Prepara e valida GetDados2³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aHeader  := aClone(aHeader2)
	aCols    := aClone(aCols2)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se nao existir coluna do item, cria-a³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 to Len(aAutoIt2)
		If (nY := AScan(aAutoIt2[nX],{|x| AllTrim(x[1]) == "DB3_ITEM"})) == 0
			AAdd(aAutoIt2[nX],{"DB3_ITEM",StrZero(nX,3),NIL})
		Else
			If Empty(aAutoIt2[nX][nY])
				aAutoIt2[nX][nY] := StrZero(nX,3)
			EndIf
		EndIf
	Next nX
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se nao existir coluna do item da nota, cria-a³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (nX := AScan(aAutoIt2[1],{|x| AllTrim(x[1]) == "DB3_ITDOC"})) == 0
		AAdd(aAutoIt2[1],{"DB3_ITDOC","001",NIL})
	Else
		If Empty(aAutoIt2[1][nX])
			aAutoIt2[1][nX] := "001"
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida getdados³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  (nOpca == 1) .And. !MsGetDAuto(aAutoIt2,"U_M145LOk2",{|| U_M145TOk2()},aAutoCab,aRotina[nOpcx][4])
		nOpcA := 0
	EndIf
	
	aHeader2	:= aClone(aHeader)
	aCols2		:= aClone(aCols)
	aHeader	  	:= aClone(aHeader1)
	aCols   	:= aClone(aCols1)

		
EndIf

If nOpcA == 1
	Begin Transaction    
		nPosDoc := aScan(aHeader,{|x| AllTrim(x[2])=='DB3_ITDOC'})
		If nPosDoc > 0
			aColsIt[Val(aCols[1,nPosDoc])] := aClone(aCols)
		EndIf
	 	M145Grv(1)
        While ( GetSX8Len() > nSaveSX8 )
			ConfirmSX8()
		EndDo
		EvalTrigger()
	End Transaction
Else
    While ( GetSX8Len() > nSaveSX8 )
		RollBackSX8()
	EndDo
EndIf
MsUnLockAll()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna o filtro original                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(cOldFilter)
	dbSelectArea(cAlias)
	Set Filter To &cOldFilter
EndIf

If !l145Auto .or. _lShowTela  //(HF) _lShowTela variavel nossa
	SetKey( VK_F5 , Nil    )
	SetKey( VK_F6 , Nil    )
	SetKey( VK_F12, bKeyF12)
Endif

RestArea(aArea)

_cNrAvRC := M->DB1_NRAVRC  //(HF) Para garantir o posicionamento no caso de retorno .T.

Return( (nOpcA==1) )  //(HF) aqui no padrão retorna simplesmente .T.

//(HF) Nossa função para montagem dos acols 1 e 2, do nosso jeito
Static Function _MontaAcols( _aIt )
Local nX := 0
Local nY := 0
Local _nCpo := 0

aCols := {}
For nX := 1 To Len(_aIt)

	aadd(aCols,Array(Len(aHeader)+1))
	For nY := 1 to len( aHeader )
		_nCpo := aScan(_aIt[nX],{|x| AllTrim(x[1]) == AllTrim(aHeader[nY][2]) } )
		if _nCpo > 0
			aCOLS[Len(aCols)][nY] := _aIt[nX][_nCpo][2]
		else
			if Trim(aHeader[nY][2]) == "DB3_ALI_WT"
				aCols[Len(aCols)][nY] := "DB3"
			elseif Trim(aHeader[nY][2]) == "DB2_ALI_WT"
				aCols[Len(aCols)][nY] := "DB2"
			elseif Trim(aHeader[nY][2]) == "DB3_REC_WT" .or. Trim(aHeader[nY][2]) == "DB2_REC_WT"
				aCols[Len(aCols)][nY] := 0
			else
				aCols[Len(aCols)][nY] := CriaVar(aHeader[nY][2])
			endif
		endif
	Next nY
	aCols[Len(aCols)][Len(aHeader)+1] := .F.

Next nX

Return(NIL)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³M145AltExc³ Autor ³ Aline Correa do Vale  ³ Data ³06.02.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de Tratamento da Visualizacao / Alteracao / Exclusao ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Alias do arquivo                                     ³±±
±±³          ³ExpN2: Registro do Arquivo                                  ³±±
±±³          ³ExpN3: Opcao da MBrowse                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³05/01/2006³Norbert Waage  ³Incluido tratamento para execucao automatica³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function M145AltE(cAlias,nReg,nOpcx)

Local aArea      := GetArea()
Local aPosObj    := {}
Local aObjects   := {}
Local aSize      := MsAdvSize()
Local oGetDad1
Local oGetDad2
Local aButtons   := {}
Local aButtonUsr := {}
Local aRecDB3	 := {}

Local cOldFilter := ""

Local nGd1       := 0
Local nGd2       := 0
Local nGd3       := 0
Local nGd4       := 0
Local nPosDoc	  := 0
Local nX         := 0

Local aTitles    := { OemToAnsi(STR0010),OemToAnsi(STR0011)} //"Notas Fiscais"###"Itens da Nota Fiscal"
Local lAltHomolo := .F.
Local lRet       := .T.
Local lM145NOBT	 := .F.
Local lQuery     := .F.
Local cQuery	  := ""
Local nUsado     := 0
Local nCntFor    := 0
Local nCntFor2   := 0
Local nOpcA      := 0
Local nRecDB2	  := 0
Local oDlg
Local aCpos      := {}
Local aAlter     := {}
Local aColsItPE  := {}
Local bKeyF12    := Nil

Private aHeader  := {}
Private aCols    := {}
Private aHeader1 := {}
Private aCols1   := {}
Private aHeader2 := {}
Private aCols2   := {}
Private aColsIt  := {}
Private lEnd     := .F.
Private oFolder
Private oGetDados
Private cCliFor    := ""    
Private cLoja      := ""
Private cTipoCF    := ""
Private aTELA[0][0],aGETS[0]

If nOpcX == 6 .And. DB1->DB1_HOMOLO=='3' .And. !l145Auto
	Aviso(STR0026, STR0042, {'Ok'})
EndIf

If nOpcX == 4 .And. DB1->DB1_HOMOLO=='3' .And. !l145Auto
	lAltHomolo := .T.
EndIf

If nOpcX == 5 .And. DB1->DB1_HOMOLO<>'1' .And. DB1->DB1_HOMOLO<>' ' .And. !l145Auto
	Aviso(STR0026, STR0042, {'Ok'})
	Return(.T.)
EndIf

bKeyF12 := SetKey( VK_F12 , Nil )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Habilita as HotKeys e botoes da barra de ferramentas         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !l145Auto .And. nOpcX == 4
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de Entrada  para inibir os botoes e HotKeys            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("M145NOBT")
	     lM145NOBT:= ExecBlock("M145NOBT",.F.,.F.)
	     If ValType(lM145NOBT) != "L"
	     	lM145NOBT:= .F.
	     Endif
	Endif
	If !lM145NOBT
	aButtons	:= {{'PEDIDO' ,{||IIf(oFolder:nOption==2,U_XML5F5PC(),.F.)}         ,STR0008+" - <F5> ",STR0044},; //"Selecionar Pedido de Compra"
	                {'SDUPROP',{||IIf(oFolder:nOption==2,U_XML5F6PC(@oGetDad2),.F.)},STR0009+" - <F6> ",STR0045} } //"Selecionar Pedido de Compra ( por item )"	
	SetKey( VK_F5, { || IIf(oFolder:nOption==2,U_XML5F5PC(),.F.)} )
	SetKey( VK_F6, { || IIf(oFolder:nOption==2,U_XML5F6PC(@oGetDad2),.F.) } )	
	Endif
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada para adicionar botoes do Usuario na ToolBar  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( ExistBlock("M145BUT") ) .And. !l145Auto
	aButtonUsr := ExecBlock("M145BUT",.F.,.F.,{nOpcx})
	If ( ValType(aButtonUsr) == "A" )
		For nX := 1 To Len(aButtonUsr)
			Aadd(aButtons,aClone(aButtonUsr[nX]))
		Next nX
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Limpa algum filtro do DB1                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cOldFilter := DB1->( dbFilter() )
DB1->( dbClearFilter() )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montagem da Variaveis de Memoria                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("DB1")
dbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Forca posicionamento quando a homologacao for executada³
//³via execauto                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If l145Auto .AND. nOpcX == 6
	DbSeek(xFilial("DB1") + aAutoCab[ProcH('DB1_NRAVRC'),2])
EndIf

For nCntFor := 1 To FCount()
	M->&(FieldName(nCntFor)) := FieldGet(nCntFor)
	If (FieldName(nCntFor)) != "DB1_HOMOLO"
		Aadd(aCpos,FieldName(nCntFor))
	EndIf
Next nCntFor
cTipo := DB1->DB1_TIPONF

dbSelectArea("DB2")
dbSetOrder(2)
dbSeek(xFilial("DB2")+DB1->DB1_NRAVRC)
nRecDB2 := Recno()

#IFDEF TOP
	If ( TcSrvType()!="AS/400" )
		lQuery := .T.
		cQuery := "SELECT DB2.*,DB2.R_E_C_N_O_ DB2RECNO "
		cQuery += "FROM "+RetSqlName("DB2")+" DB2 "
		cQuery += "WHERE DB2.DB2_FILIAL='"+xFilial("DB2")+"' AND "
		cQuery +=       "DB2.DB2_NRAVRC='"+DB1->DB1_NRAVRC+"' AND "
		cQuery +=       "DB2.D_E_L_E_T_<>'*' "
		cQuery += "ORDER BY "+SqlOrder(DB2->(IndexKey()))

		cQuery := ChangeQuery(cQuery)

		DB2->( dbCloseArea() )
	EndIf
#ENDIF                   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montagem do aHeader e aCols (1) usando a Funcao FillGetDados  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSeek  := xFilial("DB2")+DB1->DB1_NRAVRC
cWhile := "DB2->DB2_FILIAL+DB2->DB2_NRAVRC"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sintaxe da FillGetDados(nOpcX,Alias,nOrdem,cSeek,bSeekWhile,uSeekFor,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FillGetDados(nOpcX,"DB2",2,cSeek,{|| &cWhile },,,,,cQuery,,,,,,,,"DB2")

If ( lQuery )
	dbSelectArea("DB2")
	dbCloseArea()
	ChkFile("DB2",.F.)
EndIf

dbSelectArea("DB2")
dbSetOrder(2)
DB2->(dbGoto(nRecDB2))

aHeader1 := aClone(aHeader)
aCols1   := aClone(aCols)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montagem do aHeader e aCols (2)                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeader:= {}
aCols  := {}

dbSelectArea("SX3")
dbSetOrder(1)
MsSeek("DB3")
While ( !Eof() .And. SX3->X3_ARQUIVO == "DB3" )
	If ( X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL )
		Aadd(aHeader,{ TRIM(X3Titulo()),;
			TRIM(SX3->X3_CAMPO),;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			SX3->X3_VALID ,;
			SX3->X3_USADO,;
			SX3->X3_TIPO,;
			SX3->X3_F3,;
			SX3->X3_CONTEXT } )
	EndIf
	If AllTrim(SX3->X3_CAMPO) != "DB3_ITDOC"
		Aadd(aAlter,AllTrim(SX3->X3_CAMPO))
	EndIf
	dbSelectArea("SX3")
	dbSkip()
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Adiciona os campos de Alias e Recno da tabela para WalkThru   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ADHeadRec("DB3",aHeader)

dbSelectArea("DB3")
dbSetOrder(1)
#IFDEF TOP
	If ( TcSrvType()!="AS/400" )
		lQuery := .T.
		cQuery := "SELECT DB3.*,DB3.R_E_C_N_O_ DB3RECNO "
		cQuery += "FROM "+RetSqlName("DB3")+" DB3 "
		cQuery += "WHERE DB3.DB3_FILIAL='"+xFilial("DB3")+"' AND "
		cQuery +=       "DB3.DB3_NRAVRC='"+DB1->DB1_NRAVRC+"' AND "
		cQuery +=       "DB3.D_E_L_E_T_<>'*' "
		cQuery += "ORDER BY "+SqlOrder(DB3->(IndexKey()))

		cQuery := ChangeQuery(cQuery)
		DB3->( dbCloseArea() )

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"DB3",.T.,.T.)
		For nCntFor := 1 To Len(aHeader)
			If aHeader[nCntFor,8] <> "C" .And. aHeader[nCntFor,10] <> "V"
				TcSetField("DB3",AllTrim(aHeader[nCntFor][2]),aHeader[nCntFor,8],aHeader[nCntFor,4],aHeader[nCntFor,5])
			EndIf 	
		Next nCntFor
	Else
#ENDIF
		DB3->(MsSeek(xFilial("DB3")+DB1->DB1_NRAVRC))
#IFDEF TOP
	EndIf
#ENDIF

While xFilial("DB3")+DB1->DB1_NRAVRC==DB3_FILIAL+DB3_NRAVRC .And. !Eof()
	While xFilial("DB3")+DB2->DB2_NRAVRC+DB2->DB2_ITEM==DB3_FILIAL+DB3->DB3_NRAVRC+DB3_ITDOC .And. !Eof()
		aadd(aCols,Array(Len(aHeader)+1))
		For nCntFor	:= 1 To Len(aHeader)
            If IsHeadRec(aHeader[nCntFor][2])
			    aCols[Len(aCols)][nCntFor] := IIf(lQuery , DB3RECNO , DB3->(Recno()) )
            ElseIf IsHeadAlias(aHeader[nCntFor][2])
			    aCols[Len(aCols)][nCntFor] := "DB3"
			ElseIf ( aHeader[nCntFor][10] != "V" )
				aCols[Len(aCols)][nCntFor] := FieldGet(FieldPos(aHeader[nCntFor][2]))
			Else
				aCols[Len(aCols)][nCntFor] := CriaVar(aHeader[nCntFor][2])
			EndIf
		Next nCntFor
		aCols[Len(aCols)][Len(aHeader)+1] := .F.
		Aadd(aRecDB3,SuperRecno())
		dbSelectArea("DB3")
		dbSkip()
	EndDo
	DB2->(dbSkip())
	If Len(aCols) == 0
		dbSkip()
	Else
		Aadd(aColsIt,aClone(aCols))
	EndIf
	aCols := {}
EndDo

If Len(aColsIt) < 1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Sintaxe da FillGetDados(nOpcX,Alias,nOrdem,cSeek,bSeekWhile,uSeekFor,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    aHeader := {}
	FillGetDados(nOpcX,"DB3",1,,,,/*aNoFields*/,,,,,.T.,,,,,)
	aCols[1][aScan(aHeader,{|x| Trim(x[2])=="DB3_ITDOC"})]:= StrZero(1,Len(DB3->DB3_ITDOC))
	aCols[1][aScan(aHeader,{|x| Trim(x[2])=="DB3_ITEM"})] := StrZero(1,Len(DB3->DB3_ITEM))

	For nX := 1 To Len(aHeader)
		If AllTrim(aHeader[nX,2]) != "DB3_ITDOC"
			Aadd(aAlter,AllTrim(aHeader[nX,2]))
		EndIf
	Next nX
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Encerra a area de trabalho da query                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( lQuery )
	dbSelectArea("DB3")
	dbCloseArea()
	ChkFile("DB3",.F.)
	dbSelectArea("DB3")
EndIf  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada: MT145ALT			    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
If ExistBlock("MT145ALT")     
	aColsItPE:=ExecBlock("MT145ALT",.F.,.F.,{nOpcx,aHeader2, aColsIt})
	If (ValType(aColsItPE)== "A") 
		If Len(aColsItPE)>0
			aColsIt:=aClone(aColsItPE)
		EndIf
	EndIf
EndIf

aHeader2 := aClone(aHeader)
aCols2   := aClone(aColsIt[1])
            
aHeader := aClone(aHeader1)
aCols   := aClone(aCols1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se a execucao for manual, exibe interface³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !l145Auto

	aObjects := {}
	AAdd( aObjects, {   0,  90, .t., .f. } )
	AAdd( aObjects, { 100, 100, .t., .t. } )
	
	aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects )
	
	DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],00 To aSize[6],aSize[5] OF oMainWnd PIXEL
	EnChoice( cAlias ,nReg, If(nOpcx==6,2,nOpcX), , , , , APOSOBJ[1], aCpos, If(nOpcx==6,2,nOpcX))
	
	oFolder := TFolder():New(aPosObj[2,1],aPosObj[2,2],aTitles,{"",""},oDlg,,,,.T.,.F.,aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1])
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define as posicoes da Getdados a partir do folder    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	nGd1 := 2
	nGd2 := 2
	nGd3 := aPosObj[2,3]-aPosObj[2,1]-15
	nGd4 := aPosObj[2,4]-aPosObj[2,2]-4
	
	aHeader  := aClone(aHeader2)
	aCols    := aClone(aCols2)
	oGetDad2 := MSGetDados():New(nGd1,nGd2,nGd3,nGd4,If(nOpcx==6 .Or. lAltHomolo,2,nOpcX),"U_M145LOk2","U_M145TOk2","+DB3_ITEM",If(nOpcx==6 .Or. lAltHomolo,.F.,.T.),aAlter,,.T.,900,"U_M145COK",,,,oFolder:aDialogs[2])
	oGetDad2 :oBrowse:lDisablePaint := .T.
	oGetDad2:lF3Header = .T.
	
	aHeader  := aClone(aHeader1)
	aCols    := aClone(aCols1)
	oGetDad1 := MSGetDados():New(nGd1,nGd2,nGd3,nGd4,If(nOpcx==6 .Or. lAltHomolo,2,nOpcX),"U_M145LOk1","U_M145TOk1","+DB2_ITEM",If(nOpcx==6 .Or. lAltHomolo,.F.,.T.),,,.T.,900,"U_M145COK",,,,oFolder:aDialogs[1])
	oGetDad1 :oBrowse:lDisablePaint := .T.
	
	oFolder:bSetOption:={|nAtu| M145Fld(nAtu,oFolder:nOption,oFolder,{oGetDad1,oGetDad2})}
	ACTIVATE MSDIALOG oDlg ON INIT ( M145Refre( {oGetDad1,oGetDad2} ),;
		EnchoiceBar(oDlg,{|| If(nOpcx!=2,If(Obrigatorio(aGets,aTela) .And. U_M145TdOk(nOpcx) .And. U_A145FldR(oFolder),(nOpcA:= 1,oDlg:End()),nOpcA:=0),(nOpca:=2,oDlg:End())) },{|| (nOpcA:= 2,oDlg:End())},, aButtons))

Else

	nOpcA := 1 
	
	If !((nOpcX == 5) .OR. (nOpcX == 6) )//Se não for exclusao ou homologacao

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Validacao das Gets³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aValidGet := {}
	
		For nX :=1 to Len(aCpos)
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Pula campo Filial³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If AllTrim(aCpos[nX]) == 'DB1_FILIAL'
				Loop
			EndIf
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Inclui validacao da chave primaria³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If AllTrim(aCpos[nX]) == "DB1_NRAVRC"
				Aadd(aValidGet,{aCpos[nX] ,M->&(aCpos[nX]),"CheckSX3('" + aCpos[nX] + "') .AND. ExistChav('DB1')",.F.})
				Loop
			EndIf
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valida todos os campos obrigatorios, independente de terem³
			//³sido enviados pela execauto                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ( ProcH(aCpos[nX]) != 0 ) .OR. ( X3Obrigat(aCpos[nX]) )
				Aadd(aValidGet,{aCpos[nX] ,M->&(aCpos[nX]),"CheckSX3('" + aCpos[nX] + "')",.F.})
			EndIf
			
		Next nX
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Executa validacoes³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    If !DB1->(MsVldGAuto(aValidGet))
			nOpcA := 0
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Prepara e valida GetDados1³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aHeader  := aClone(aHeader1)
		aCols    := aClone(aCols1)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se nao existir coluna do item, cria-a³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nX := 1 to Len(aAutoIt)
			If (nY := AScan(aAutoIt[nX],{|x| AllTrim(x[1]) == "DB2_ITEM"})) == 0
				AAdd(aAutoIt[nX],{"DB2_ITEM",StrZero(nX,3),NIL})
			Else
				If Empty(aAutoIt[nX][nY])
					aAutoIt[nX][nY] := StrZero(nX,3)
				EndIf
			EndIf
		Next nX
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida getdados³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		If	(nOpcA == 1) .And. !MsGetDAuto(aAutoIt,"U_M145LOk1",{|| U_M145TOk1()},aAutoCab,aRotina[nOpcx][4]) 
			nOpcA := 0
		EndIf
	
		aHeader1	:= aClone(aHeader)
		aCols1		:= aClone(aCols)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Prepara e valida GetDados2³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aHeader  := aClone(aHeader2)
		aCols    := aClone(aCols2)
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se nao existir coluna do item, cria-a³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nX := 1 to Len(aAutoIt2)
			If (nY := AScan(aAutoIt2[nX],{|x| AllTrim(x[1]) == "DB3_ITEM"})) == 0
				AAdd(aAutoIt2[nX],{"DB3_ITEM",StrZero(nX,3),NIL})
			Else
				If Empty(aAutoIt2[nX][nY])
					aAutoIt2[nX][nY] := StrZero(nX,3)
				EndIf
			EndIf
		Next nX
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se nao existir coluna do item da nota, cria-a³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (nX := AScan(aAutoIt2[1],{|x| AllTrim(x[1]) == "DB3_ITDOC"})) == 0
			AAdd(aAutoIt2[1],{"DB3_ITDOC","001",NIL})
		Else
			If Empty(aAutoIt2[1][nX])
				aAutoIt2[1][nX] := "001"
			EndIf
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida getdados³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If  (nOpca == 1) .And. !MsGetDAuto(aAutoIt2,"U_M145LOk2",{|| U_M145TOk2()},aAutoCab,aRotina[nOpcx][4])
			nOpcA := 0
		EndIf
		
		aHeader2	:= aClone(aHeader)
		aCols2		:= aClone(aCols)
		aHeader	  	:= aClone(aHeader2)
		aCols   	:= aClone(aCols2)
	    
	EndIf

EndIf

If nOpcA == 1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de Entrada antes da Exclusao/Alteração e Homologacao  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("MT145GRV")
		lRet := ExecBlock("MT145GRV",.F.,.F.,{nOpcx})
		If ValType(lRet) <> "L"
			lRet := .T.			
		EndIf
	EndIf
         
	If lRet
		If nOpcX == 5 // Exclusao
			Begin Transaction
			M145Grv(3,aRecDB3)
			End Transaction
		EndIf
		If nOpcX == 4 // Alteracao
			nPosDoc := aScan(aHeader,{|x| AllTrim(x[2])=="DB3_ITDOC"})
			If nPosDoc > 0
				If Val(aCols[1,nPosDoc]) > Len(aColsIt)
					aColsIt[Len(aColsIt)] := aClone(aCols)
				Else 
                    If Inclui
						aColsIt[Val(aCols[1,nPosDoc])] := aClone(aCols)
					Else	
						If (Val(aCols[1,nPosDoc]) == Len(aColsIt) .And. n < Len(aColsIt)) .Or. n < Len(aColsIt)
							aColsIt[n] := aClone(aCols)
						Else 
							aColsIt[Val(aCols[1,nPosDoc])] := aClone(aCols)
						Endif						
					Endif	
				Endif								
			Else
				aCols1 := aClone(aCols)
			EndIf
			Begin Transaction
			M145Grv(2,aRecDB3)
			End Transaction
		EndIf
		If nOpcX == 6 // Homologacao
			If !l145Auto
				//Processa({|lEnd| U_M145Homo(@lEnd)}, STR0012,, .T.) //'Homologacao de A.R.'
				Processa({|lEnd| nOpcA := iif( !U_M145Homo(@lEnd),2,nOpcA ) }, STR0012,, .T.) //(HF) se der erro retorna .F.
			Else
				U_M145Homo(@lEnd)
			EndIF
		EndIf
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna o filtro original                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty( cOldFilter )
	dbSelectArea( cAlias )
	Set Filter To &cOldFilter
EndIf

If !l145Auto
	SetKey( VK_F5 , Nil    )
	SetKey( VK_F6 , Nil    )
	SetKey( VK_F12, bKeyF12)
Endif

RestArea(aArea)
Return( (nOpcA==1) )  //(HF) aqui no padrão retorna .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ M145Fld  ³ Autor ³ Aline Correa do Vale  ³ Data ³30.01.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de Tratamento dos Folders                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Folder de Destino                                    ³±±
±±³          ³ExpN2: Folder Atual                                         ³±±
±±³          ³ExpO3: Objeto do Folder                                     ³±±
±±³          ³ExpA4: Array com as getdados.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function M145Fld(nFldDst,nFldAtu,oFolder,aGetDad)

Local nCntFor := 0
Local lRetorno:= .F.
Local nY	  := 1
Local i		  := 1
Local nPosIt1 := aScan(aHeader,{|x| AllTrim(x[2])=="DB2_ITEM"})
Local nPosCF  := aScan(aHeader,{|x| AllTrim(x[2])=="DB2_CLIFOR"}) 
Local nPosLoj := aScan(aHeader,{|x| AllTrim(x[2])=="DB2_LOJA"}) 
Local nPosTip := aScan(aHeader,{|x| AllTrim(x[2])=="DB2_TIPO"})  
Local nPosIt2 := aScan(aHeader2,{|x| AllTrim(x[2])=="DB3_ITDOC"})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Efetua a Validacao da GetDados                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( aGetDad[nFldAtu]:TudoOk() )
	lRetorno := .T.
	aGetDad[nFldAtu]:oBrowse:lDisablePaint := .T.
	Do Case
		Case ( nFldAtu == 2 )
			If Val(aCols[n,nPosIt2]) > Len(aColsIt)
				aColsIt[Len(aColsIt)] := aClone(aCols)
			Else 
				If Inclui
					aColsIt[Val(aCols[n,nPosIt2])] := aClone(aCols)
				Endif	
			Endif	
		Case ( nFldAtu == 1 )
			aCols1  := aClone(aCols)
	EndCase
	Do Case
		Case ( nFldDst == 2 )
			While n > Len(aColsIt)
				aadd(aColsIt,{Array(Len(aHeader2)+1)})
				dbSelectArea("DB3")
				For nY := 1 To Len(aHeader2)
		            If IsHeadRec(aHeader2[nY][2])
					    aColsIt[Len(aColsIt)][1][nY] := 0
		            ElseIf IsHeadAlias(aHeader2[nY][2])
					    aColsIt[Len(aColsIt)][1][nY] := "DB3"
					ElseIf Trim(aHeader2[nY][2]) == "DB3_ITDOC"
						aColsIt[Len(aColsIt)][1][nY] := "001"
					ElseIf Trim(aHeader2[nY][2]) == "DB3_ITEM"
						aColsIt[Len(aColsIt)][1][nY] := "001"
					ElseIf Trim(aHeader2[nY][2]) != "DB3_NRAVRC"
						aColsIt[Len(aColsIt)][1][nY] := CriaVar(aHeader2[nY][2])
					EndIf
					aColsIt[Len(aColsIt)][1][Len(aHeader2)+1] := .F.
				Next nY
			EndDo
			cCliFor := aCols1[n][nPosCF]    
			cLoja   := aCols1[n][nPosLoj]
			cTipoCF := aCols1[n][nPosTip]
			If Val(aCols1[n][nPosIt1]) > Len(aColsIt) 
				aCols := aClone(aColsIt[Len(aColsIt)])
			Else
				If Inclui
					aCols := aClone(aColsIt[Val(aCols1[n][nPosIt1])])
				Else
					If (Val(aCols1[n][nPosIt1]) == Len(aColsIt) .And. n < Len(aColsIt)) .Or. n < Len(aColsIt)
						aCols := aClone(aColsIt[n])
					Else 
						aCols := aClone(aColsIt[Val(aCols1[n][nPosIt1])])
					Endif	
				Endif	
 			Endif	
			aHeader	:= aClone(aHeader2)
			aCols[1][nPosIt2] := aCols1[n][nPosIt1]
		Case ( nFldDst == 1 )
			aCols   := aClone(aCols1)
			aHeader := aClone(aHeader1)
	EndCase
	nOri := aGetDad[nFldAtu]:oBrowse:nAt
	n := Max(aGetDad[nFldDst]:oBrowse:nAt,1)
	aGetDad[nFldDst]:oBrowse:lDisablePaint := .F.
	aGetDad[nFldDst]:oBrowse:Refresh(.T.)
EndIf
Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ M145LOk1 ³ Autor ³Aline Correa do Vale   ³ Data ³30.01.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de validacao da linha Ok                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function M145LOK1()

Local lRetorno:= .T.
Local nPItem  := aScan(aHeader,{|x| AllTrim(x[2])=="DB2_ITEM"})
Local nPCliFor:= aScan(aHeader,{|x| AllTrim(x[2])=="DB2_CLIFOR"})
Local nPLoja  := aScan(aHeader,{|x| AllTrim(x[2])=="DB2_LOJA"})
Local nPSerie := aScan(aHeader,{|x| AllTrim(x[2])=="DB2_SERIE"})
Local nPNota  := aScan(aHeader,{|x| AllTrim(x[2])=="DB2_DOC"})
Local nPCodPro:= aScan(aHeader2,{|x| AllTrim(x[2])=="DB3_CODPRO"})
Local nUsado  := Len(aHeader)
Local nX      := 0
Local nY      := 0
Local lVALNFE := GetNewPar( "MV_VALNFE", .T. ) //-- Valida a existencia da Nota Fiscal Informada ?
Local nNrAvrc := IIF(INCLUI,M->DB1_NRAVRC,DB1->DB1_NRAVRC)
Local lHomolog:= IIF(ALTERA .And. DB1_HOMOLO=='3',.F.,.T.)

If ( !aCols[n][nUsado+1] )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica os campo obrigatórios                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(aCols[n][nPCliFor]) .Or. Empty(aCols[n][nPNota]) .Or. Empty(aCols[n][nPLoja])
		Help(" ",1,"OBRIGAT2")
		lRetorno := .F.
	EndIf
	
	If lVALNFE .And. lHomolog  //-- Se o parametro estiver configurado para validar a existencia da Nota Fiscal Informada 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica a duplicidade de lancamentos de NFs                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	

		dbSelectArea("SD1")
		dbSetOrder(1)
		If MsSeek(xFilial("SD1")+aCols[n][nPNota]+aCols[n][nPSerie]+aCols[n][nPCliFor]+aCols[n][nPLoja])
			Help(" ",1,"EXISTNF")
			lRetorno := .F.
		EndIf
			
		dbSelectArea("DB2")
		dbSetOrder(1)
		If MsSeek(xFilial("DB2")+aCols[n][nPNota]+aCols[n][nPSerie]+aCols[n][nPCliFor]+aCols[n][nPLoja]) .And.;
		   DB2->DB2_NRAVRC <> nNrAvrc 
			While !Eof() .And. xFilial("DB2") == DB2->DB2_FILIAL .And.;
				aCols[n][nPNota] == DB2->DB2_DOC .And.;
				aCols[n][nPSerie] == DB2->DB2_SERIE
					
				If aCols[n][nPCliFor] == DB2->DB2_CLIFOR .And.;
					aCols[n][nPLoja] == DB2->DB2_LOJA 
					
					Help(" ",1,"EXISTNF")
					lRetorno := .F.
				EndIf
				dbSelectArea("DB2")
				dbSkip()
			EndDo
		EndIf
		
		For nX := 1 To Len(aCols)
			If nX <> N .And.  !aCols[nX][nUsado+1]
				If aCols[nX][nPNota] == aCols[n][nPNota] .And.;
					aCols[nX][nPSerie] ==  aCols[n][nPSerie] .And.;
					aCols[nX][nPCliFor] == aCols[n][nPCliFor] .And.;
					aCols[nX][nPLoja] == aCols[n][nPLoja] 
					
						Help(" ",1,"EXISTNF")
						lRetorno := .F.								
				EndIf		
		    EndIf
		Next nX
	EndIf	
	If lRetorno .And. (ExistBlock("MT145LK1"))
		lRetorno := ExecBlock("MT145LK1",.F.,.F.)
		If ValType(lRetorno) <> "L"
	    	lRetorno := .T.
	    EndIf 
	EndIf	
Else
	For nX := 1 To Len(aColsIt[n])
		aColsIt[n][nX][Len(aHeader2)+1] := .T.
	Next	
EndIf

Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ M145LOk2 ³ Autor ³Aline Correa do Vale   ³ Data ³01.02.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de validacao da linha Ok                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: item do aCols (opcional)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function M145LOK2()   
Local lRetorno:= .T.
Local nPItDoc := aScan(aHeader,{|x| AllTrim(x[2])=="DB3_ITDOC"})
Local nCodPro := aScan(aHeader,{|x| AllTrim(x[2])=="DB3_CODPRO"})
Local nQuant  := aScan(aHeader,{|x| AllTrim(x[2])=="DB3_QUANT"})
Local nUnit   := aScan(aHeader,{|x| AllTrim(x[2])=="DB3_VUNIT"})
Local nTotal  := aScan(aHeader,{|x| AllTrim(x[2])=="DB3_TOTAL"})
Local nValDesc:= aScan(aHeader,{|x| AllTrim(x[2])=="DB3_VALDES"})
Local nDesc   := aScan(aHeader,{|x| AllTrim(x[2])=="DB3_DESC"})
Local nUsado  := Len(aHeader)
Local nLin    := N 
Local nValor  := 0

If ( !aCols[nLin][nUsado+1] )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se nao ha Campos obrigatorios em branco              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(aCols[nLin][nCodPro]) .Or. Empty(aCols[nLin][nQuant]) .Or. Empty(aCols[nLin][nUnit])
		Help(" ",1,"OBRIGAT")
		lRetorno := .F.
	EndIf
	If Empty(aCols[nLin][nTotal])
		aCols[nLin][nTotal] := aCols[nLin][nQuant] * aCols[nLin][nUnit]
	EndIf
	If !Empty(aCols[nLin][nQuant]) .And. !Empty(aCols[nLin][nUnit]) .And. !Empty(aCols[nLin][nTotal])
	                  
	    nValor:= aCols[nLin][nQuant] * aCols[nLin][nUnit]
	    
	    If QtdComp(NoRound(aCols[nLin][nTotal])) > QtdComp(NoRound(nValor))+0.49 .Or.;
		   QtdComp(NoRound(aCols[nLin][nTotal])) < QtdComp(NoRound(nValor))-0.49
			Help("  ",1,'TOTAL')
			lRetorno := .F.
		Endif
		
		If QtdComp(NoRound(aCols[nLin][nValdesc]))<0 .Or. QtdComp(NoRound(aCols[nLin][nValdesc])) >= QtdComp(NoRound(nValor)) .Or.;
			aCols[nLin][nDesc]>100 .Or. aCols[nLin][nDesc]<0
			Help("  ",1,'MATA14503')
			lRetorno := .F.
		Endif

	Endif
	If nPItDoc != 0 .And. nLin > 1
		If Empty(aCols[nLin,nPItDoc])
			aCols[nLin,nPItDoc] := aCols[nLin-1,nPItDoc]
		EndIf
	EndIf
	
	If cTipoCF == "2" .and. lRetorno
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o Fornecedor x Produto possui bloqueio da Qualidade.  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lRetorno := QieSitFornec(cCliFor,cLoja,aCols[nLin][nCodPro],.T.)
	EndIf
	If lRetorno .And. (ExistBlock("MT145LK2"))
		lRetorno := ExecBlock("MT145LK2",.F.,.F.)
		If ValType(lRetorno) <> "L"
	    	lRetorno := .T.
	    EndIf 
	EndIf		
EndIf

Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ M145TOk1 ³ Autor ³ Aline Correa do Vale  ³ Data ³30.01.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de validacao da Getdados                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function M145TOk1()

Local lRetorno:= .T.
Local nCntFor := 0
Local nPDoc  := GDFieldPos( "DB2_DOC" )
Local nUsado  := Len(aHeader)
Local nX      := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Exclui os itens nao informados                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nCntFor := 1 To Len(aCols)
	If ( Empty(aCols[nCntFor][nPDoc]) )
		aCols[nCntfor][nUsado+1] := .T.
	EndIf
Next nCntFor

For nX := 1 to Len(aCols)
	If !(lRetorno:=U_M145LOK1(nX))
		Exit
	EndIf
Next nX

Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ M145TOk2 ³ Autor ³ Aline Correa do Vale  ³ Data ³01.02.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de validacao da Getdados                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³05/01/2005³Norbert Waage  ³Incluido tratamento para exec. automatica   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function M145TOk2()
Local nPosIt2 := aScan(aHeader2,{|x| AllTrim(x[2])=="DB3_ITDOC"})
Local lRetorno:= .T.
Local nX      := 0
Local nSave   := N

If l145Auto .Or. oFolder:nOption = 2
	For nX := 1 to Len(aCols)
        N := nX
		If !(lRetorno:=U_M145LOK2())
			Exit
		EndIf
	Next nX

    N := nSave

	If lRetorno
		If Val(aCols[n,nPosIt2]) > Len(aColsIt)
			aColsIt[Len(aColsIt)] := aClone(aCols)
		Else 
			If Inclui
				aColsIt[Val(aCols[n,nPosIt2])] := aClone(aCols)
			Else	
				If (Val(aCols[n,nPosIt2]) == Len(aColsIt) .And. nOri < Len(aColsIt)) .Or. nOri < Len(aColsIt)
					aColsIt[nOri] := aClone(aCols)
				Else 
					aColsIt[Val(aCols[n,nPosIt2])] := aClone(aCols)
				Endif						
			Endif	
		Endif	
	EndIf	
EndIf

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ M145Refre³ Autor ³Aline Correa do Vale   ³ Data ³30.01.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua o refresh nas GetDados                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ M145Refre( ExpA1 )                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 -> Array contendo objetos GetDados                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function M145Refre( aGetDad )

Local nLoop      := 0
Local cNomeCols  := ''
Local cNomeHead  := ''
Local aColsAnt   := aClone(aCols)
Local aHeaderAnt := aClone(aHeader)

For nLoop := 1 To Len( aGetDad )
	cNomeCols := 'aCols'	+ StrZero(nLoop, 1)
	aCols     := aClone(&(cNomeCols))
	cNomeHead := 'aHeader' + StrZero(nLoop, 1)
	aHeader   := aClone(&(cNomeHead))
	aGetDad[nLoop]:oBrowse:lDisablePaint := .F.
	aGetDad[nLoop]:oBrowse:Refresh(.T.)
Next nLoop

aCols   := aClone(aColsAnt)
aHeader := aClone(aHeaderAnt)
cTipo   := M->DB1_TIPONF

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ M145COk  ³ Autor ³Aline Correa do Vale   ³ Data ³04.02.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua a validacao dos Campos das GetDados                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ M145COk( ExpC1, ExpC2)	                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. / .F.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 -> Campo a ser validado                              ³±±
±±³          ³ ExpC2 -> Origem da Validacao                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function M145COk( cCampo, cOrigem )
Local lRetorno := .T.
Local nPosTipo := aScan(aHeader,{|x| AllTrim(x[2])=="DB2_TIPO"})
Local nPosLoja := aScan(aHeader,{|x| AllTrim(x[2])=="DB2_LOJA"})
Local nPosCF   := aScan(aHeader,{|x| AllTrim(x[2])=="DB2_CLIFOR"})
Local nQuant  := aScan(aHeader,{|x| AllTrim(x[2])=="DB3_QUANT"})
Local nUnit   := aScan(aHeader,{|x| AllTrim(x[2])=="DB3_VUNIT"})
Local nTotal  := aScan(aHeader,{|x| AllTrim(x[2])=="DB3_TOTAL"})

DEFAULT cCampo := ReadVar()
DEFAULT cOrigem:= ""

cCampo := If(Subs(cCampo,1,3)=="M->",Subs(cCampo,4,(Len(cCampo)-3)),cCampo)
Do Case
	Case cOrigem == "CLF"
		If "DB1" $ ReadVar()
			ConPad1(,,,If(M->DB1_TIPO == "1","SA1","FOR"))
		Else
			ConPad1(,,,If(aCols[n][nPosTipo] == "1","SA1","FOR"))
		EndIf
	Case cCampo == "DB1_TIPO"
	Case cCampo == "DB1_CLIFOR" .Or. cCampo == "DB1_LOJA"
		dbSelectArea(If(M->DB1_TIPO == "1","SA1","SA2"))
		dbSetOrder(1)
		lRetorno := dbSeek(xFilial()+M->DB1_CLIFOR+If(cCampo=="DB1_LOJA",M->DB1_LOJA,Alltrim(M->DB1_LOJA)))
		If !lRetorno
			Help(" ",1,"REGNOIS")
		EndIf		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o Registro esta Bloqueado.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    If lRetorno
		    If !Empty(M->DB1_LOJA) .And. !RegistroOk(If(M->DB1_TIPO == "1","SA1","SA2"))
		        lRetorno := .F.
			EndIf	
		Endif	
	Case cCampo == "DB2_LOJA"
		dbSelectArea(If(aCols[n][nPosTipo] == "1","SA1","SA2"))
		dbSetOrder(1)
		lRetorno := dbSeek(xFilial()+aCols[n][nPosCF]+M->DB2_LOJA)
		If !lRetorno
			Help(" ",1,"REGNOIS")
		EndIf
		If lRetorno .And. !RegistroOk(If(aCols[n][nPosTipo] == "1","SA1","SA2"))
			lRetorno := .F.
		EndIf	
	Case cCampo == "DB3_VUNIT"
		If Empty(aCols[n][nTotal])
			aCols[n][nTotal] := aCols[n][nQuant] * M->DB3_VUNIT
		EndIf
	Case cCampo == "DB3_QUANT"
		If Empty(aCols[n][nTotal])
			aCols[n][nTotal] := M->DB3_QUANT * aCols[n][nUnit]
		EndIf
EndCase
Return( lRetorno )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ M145Grv  ³ Autor ³ Aline Correa do Vale  ³ Data ³04.02.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de Aviso de Recebimento de Carga                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1 -> Efetuado                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: [1] Inclusao                                         ³±±
±±³          ³       [2] Alteracao                                        ³±±
±±³          ³       [3] Exclusao                                         ³±±
±±³          ³ExpA1: Array com registros de Cabecalho de NF - DB2         ³±±
±±³          ³ExpA2: Array com registros de Itens de NF     - DB3         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³02/12/2005³Ricardo Berti  ³BOPS 89569:PE p/tratar delecao do Aviso Rec.³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function M145Grv(nOpc,aRecDB3)
Local cSerie  	 := ""
Local cSerieAnt  := ""
Local cTipoNF    := SuperGetMV("MV_TPNRNFS",.F.,"1")
Local nCntFor	 := 0
Local nCntFor2	 := 0
Local nCntItem	 := 0
Local nUsado	 := Len(aHeader1)
Local nDelet 	 := 0
Local lDeletaAvR := .T.
Local nNumAvrc   := " "
Local nPosRecDB2 := Len(aHeader1)
Local nX         := 0
Local nY         := 0

Do Case
	Case nOpc == 1		// Inclusao
		dbSelectArea("DB1")
		Reclock("DB1",.T.)
		For nCntFor := 1 To DB1->(FCount())
			If ( FieldName(nCntFor)!="DB1_FILIAL" )
				FieldPut(nCntFor,M->&(FieldName(nCntFor)))
			Else
				DB1->DB1_FILIAL := xFilial("DB1")
			EndIf
		Next nCntFor
		MsUnlock()
		dbSelectArea("DB2")
		For nCntFor := 1 To Len(aCols1)
			If ( !aCols1[nCntFor][nUsado+1] )
				Reclock("DB2",.T.)
				For nCntFor2 := 1 To nUsado
					If ( aHeader1[nCntFor2][10] != "V" )
						FieldPut(FieldPos(aHeader1[nCntFor2][2]),aCols1[nCntFor][nCntFor2])
					EndIf
				Next nCntFor2
				DB2->DB2_FILIAL := xFilial("DB2")
				DB2->DB2_NRAVRC := DB1->DB1_NRAVRC
				MsUnlock()
			EndIf
			If DB2->DB2_FORMUL == "1"
				If nCntFor == 1
					cSerieAnt:= DB2->DB2_SERIE 
				EndIf
				cSerie:= DB2->DB2_SERIE
				If cSerieAnt <> cSerie
					NxtSX5Nota(cSerieAnt,.T.,cTipoNF)
					cSerieAnt:= cSerie
				EndIf
			EndIf
		Next
		If DB2->DB2_FORMUL == "1" .And. cSerieAnt == cSerie
			NxtSX5Nota(cSerie,.T.,cTipoNF)
		EndIf
		dbSelectArea("DB3")
		nUsado := Len(aHeader2)
		For nCntItem := 1 To Len(aColsIt)
			aCols2 := aClone(aColsIt[nCntItem])
			For nCntFor := 1 To Len(aCols2)
				If ( !aCols2[nCntFor][nUsado+1] )
					Reclock("DB3",.T.)
					For nCntFor2 := 1 To nUsado
						If ( aHeader2[nCntFor2][10] != "V" )
							FieldPut(FieldPos(aHeader2[nCntFor2][2]),aCols2[nCntFor][nCntFor2])
						EndIf
					Next nCntFor2
					DB3->DB3_FILIAL := xFilial("DB3")
					DB3->DB3_NRAVRC := DB1->DB1_NRAVRC
					MsUnlock()
				EndIf
			Next
		Next
		nNumAvrc := DB1->DB1_NRAVRC
	Case nOpc == 2		//Alteracao
		dbSelectArea("DB3")
		For nX := 1 To Len(aRecDB3)
			DB3->(dbGoto(aRecDB3[nX]))
			If !DB3->(EOF())
				Reclock("DB3",.F.,.T.)	
				dbDelete()
				MsUnlock()
			EndIf
		Next nX
		
		dbSelectArea("DB2")
		For nX := 1 To Len(aCols1)
			DB2->(dbGoto(aCols1[nX][nPosRecDB2]))		
			If !DB2->(Eof())
				Reclock("DB2",.F.,.T.)
				dbDelete()
				MsUnlock()
			EndIf
		Next nX
		dbSelectArea("DB1")
		Reclock("DB1",.F.)
		For nCntFor := 1 To DB1->(FCount())
			If ( FieldName(nCntFor)!="DB1_FILIAL" )
				FieldPut(nCntFor,M->&(FieldName(nCntFor)))
			Else
				DB1->DB1_FILIAL := xFilial("DB1")
			EndIf
		Next nCntFor
		MsUnlock()
		dbSelectArea("DB2")
		For nCntFor := 1 To Len(aCols1)
			If ( !aCols1[nCntFor][nUsado+1] )
				Reclock("DB2",.T.)
				For nCntFor2 := 1 To nUsado
					If ( aHeader1[nCntFor2][10] != "V" )
						FieldPut(FieldPos(aHeader1[nCntFor2][2]),aCols1[nCntFor][nCntFor2])
					EndIf
				Next nCntFor2
				DB2->DB2_FILIAL := xFilial("DB2")
				DB2->DB2_NRAVRC := DB1->DB1_NRAVRC
				DB2->DB2_ITEM   := StrZero(Val(DB2->DB2_ITEM) - nDelet,Len(DB2->DB2_ITEM))  //renumerar qdo deletar NFs
				MsUnlock()      
				
				If DB2->DB2_FORMUL == "1"
					If nCntFor == 1
						cSerieAnt:= DB2->DB2_SERIE 
					EndIf
					cSerie:= DB2->DB2_SERIE
					If cSerieAnt <> cSerie
						NxtSX5Nota(cSerieAnt,.T.,cTipoNF)
						cSerieAnt:= cSerie
					EndIf
				EndIf
			Else
				nDelet ++
			EndIf
		Next       
		
		If DB2->DB2_FORMUL == "1" .And. cSerieAnt == cSerie
			NxtSX5Nota(cSerie,.T.,cTipoNF)
		EndIf
		
		nDelet := 0
		dbSelectArea("DB3")
		nUsado := Len(aHeader2)
		For nCntItem := 1 To Len(aColsIt)
			aCols2 := aClone(aColsIt[nCntItem])
			If ( !aCols1[nCntItem][Len(aHeader1)+1] )
				For nCntFor := 1 To Len(aCols2)
					If ( !aCols2[nCntFor][nUsado+1] )
						Reclock("DB3",.T.)
						For nCntFor2 := 1 To nUsado
							If ( aHeader2[nCntFor2][10] != "V" )
								FieldPut(FieldPos(aHeader2[nCntFor2][2]),aCols2[nCntFor][nCntFor2])
							EndIf
						Next nCntFor2
						DB3->DB3_FILIAL := xFilial("DB3")
						DB3->DB3_NRAVRC := DB1->DB1_NRAVRC
						DB3->DB3_ITDOC  := StrZero(Val(DB3_ITDOC) - nDelet,Len(DB3->DB3_ITDOC))
						MsUnlock()
					EndIf
				Next
			Else
				nDelet ++
			EndIf
		Next
		nNumAvrc := DB1->DB1_NRAVRC
	Case nOpc == 3		//Exclusao
		//-- ExecBlock p/ tratar a delecao do Aviso de Recebto -- BOPS 089569
		If ExistBlock( 'M145ARDEL' )
			lDeletaAvR := ExecBlock('M145ARDEL', .F., .F.)
			If ValType(lDeletaAvR) <> "L"
				lDeletaAvR := .T.			
			EndIf
		EndIf
		nNumAvrc := DB1->DB1_NRAVRC
		If lDeletaAvR       

			dbSelectArea("DB3")
			For nX := 1 To Len(aRecDB3)
				dbGoto(aRecDB3[nX])
				If !(Eof())
					Reclock("DB3",.F.,.T.)
					dbDelete()
					MsUnlock()
				EndIf
			Next nX
	
			dbSelectArea("DB2")
			For nX := 1 To Len(aCols1)
				dbGoto(aCols1[nX][nPosRecDB2])
				If !(Eof())
					Reclock("DB2",.F.,.T.)
					dbDelete()
					MsUnlock()
				EndIf
			Next nX
			Reclock("DB1",.F.,.T.)
			dbDelete()
			MsUnlock()
		EndIf
EndCase

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada apos inclusao/alteracao/exclusao do Aviso Recebimento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( ExistBlock("MT145ATU") )
	ExecBlock("MT145ATU",.F.,.F.,{nOpc,nNumAvrc})
Endif

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ XML5F6PC ³ Autor ³ Aline Correa do Vale  ³ Data ³18.03.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Tela de importacao de Pedidos de Compra por Item.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ U_XML5F6PC(ExpO1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ ExpO1: Objeto da getdados (itens selecionados do PC)       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³19/12/2005³Ricardo Berti  ³BOPS 89891:lnewline=.f. para nao perder item³±±
±±³          ³               ³				selecionado do PC             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³ Uso      ³ MATA145                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function XML5F6PC(oGetDad2)

Local aArea			:= GetArea()
Local aAreaSB1		:= SB1->(GetArea())
Local aCab			:= {}
Local aArrSldo		:= {}
Local aArrayF4		:= {}
Local aNewArray 	:= {}
Local aButtons		:= { {'PESQUISA',{||A103VisuPC(aArrSldo[oQual:nAt][2])},OemToAnsi(STR0013),OemToAnsi(STR0008)} } //"Pedido de Compras"

Local _bSavKeyF3	:= SetKey(VK_F3,Nil)  //(HF) por conta e risco
Local bSavKeyF5		:= SetKey(VK_F5,Nil)
Local bSavKeyF6     := SetKey(VK_F6,Nil)

Local nPosPRD		:= aScan(aHeader,{|x| Alltrim(x[2]) == "DB3_CODPRO" })
Local nPosPDD		:= aScan(aHeader,{|x| Alltrim(x[2]) == "DB3_NUMPC" })
Local nPosITM		:= aScan(aHeader,{|x| Alltrim(x[2]) == "DB3_ITEMPC" })
Local nPosQTD		:= aScan(aHeader,{|x| Alltrim(x[2]) == "DB3_QUANT" })
Local nPosItDoc	 	:= aScan(aHeader,{|x| Alltrim(x[2]) == "DB3_ITDOC" })
Local nPosCF		:= aScan(aHeader1,{|x| Alltrim(x[2]) == "DB2_CLIFOR"})
Local nPosLoja		:= aScan(aHeader1,{|x| Alltrim(x[2]) == "DB2_LOJA"})
Local nFreeQt		:= 0
Local nSavQual		:= 0
Local nAuxCnt		:= 0
Local nOpca 		:= 0
Local nSalPed       := 0 
Local nPreco        := 0

Local cSeek			:= If(oFolder:nOption > 1,aCols1[Val(aCols[1][nPosItDoc])][nPosCF] + aCols1[Val(aCols[1][nPosItDoc])][nPosLoja],"")
Local cVar			:= If(oFolder:nOption > 1,aCols[n][nPosPrd],"")

Local oQual
Local oDlg

Local lAllPC        := .T.

Pergunte("MTA145",.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ MV_PAR01 - Quanto ao PC ? 1-Fornecedor+Loja  2-Fornecedor    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If MV_PAR01 == 2 
   cSeek := If(oFolder:nOption > 1,aCols1[Val(aCols[1][nPosItDoc])][nPosCF],"")
EndIf

dbSelectArea("SC7")
If Empty(cVar)
	dbSetOrder(9)
Else
	dbSetOrder(6)
	cSeek := cVar + cSeek
EndIf
MsSeek(xFilEnt(xFilial("SC7"))+cSeek)

If !Eof()
	If Empty(cVar)
		cCond := "C7_FILENT+C7_FORNECE" + IIF( MV_PAR01 == 1,"+C7_LOJA","")
	Else
		cCond := "C7_FILENT+C7_PRODUTO+C7_FORNECE" + IIF( MV_PAR01 == 1,"+C7_LOJA","")
	EndIf
	
	While !Eof() .And. xFilEnt(cFilial)+cSeek == &(cCond)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Filtra os Pedidos Bloqueados e Previstos.                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (GetMV("MV_RESTNFE") == "S" .And. C7_CONAPRO == "B") .Or. C7_TPOP == "P"
			dbSkip()
			Loop
		EndIf
		If Empty(C7_RESIDUO)
			nFreeQT := 0
			For nAuxCNT := 1 To Len( aCols )
				If (nAuxCNT # n) .And. ;
						(aCols[ nAuxCNT,nPosPRD ] == C7_PRODUTO) .And. ;
						(aCols[ nAuxCNT,nPosPDD ] == C7_NUM) .And. ;
						(aCols[ nAuxCNT,nPosITM ] == C7_ITEM) .And. ;
						!ATail( aCols[ nAuxCNT ] )
					nFreeQT += aCols[ nAuxCNT,nPosQTD ]
				EndIf
			Next
			
			If ((nFreeQT := (C7_QUANT-C7_QUJE-C7_QTDACLA-nFreeQT)) > 0)
				AAdd( aArrayF4,{	SC7->C7_LOJA,;
					SC7->C7_NUM,;
					SC7->C7_ITEM,;
					TransForm(nFreeQT,PesqPict("SC7","C7_QUANT")),;
					DTOC(SC7->C7_DATPRF),;
					Substr(C7_PRODUTO,1,15),;
					Substr(C7_DESCRI,1,20),;
					IIF(C7_TIPO==2,"AE","PC"),;
					TransForm(SC7->C7_PRECO,PesqPict("SC7","C7_PRECO")) ,;
					DTOC(SC7->C7_EMISSAO) ,;
					SC7->C7_Local ,;
					SC7->C7_OBS } )
				
				AAdd( aArrSldo,{nFreeQT,SuperRecno()} )
			EndIf
		EndIf
		dbSkip()
	End
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Efetua a chamada do ponto de entrada                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock( "MT145F6P" )
		aNewArray := ExecBlock( "MT145F6P", .F., .F.,{aArrayF4} )
		If ValType(aNewArray) == 'A'
			aArrayF4 := aNewArray
		Endif
	EndIf
	
	If !Empty(aArrayF4)
		
		DEFINE MSDIALOG oDlg FROM 30,20  TO 265,521 TITLE OemToAnsi(STR0013) Of oMainWnd PIXEL //"Pedido de Compras"
		
		aCab := {OemToAnsi(STR0014),OemToAnsi(STR0008),OemToAnsi(STR0015),OemToAnsi(STR0016),OemToAnsi(STR0017),OemToAnsi(STR0018),OemToAnsi(STR0019),OemToAnsi(STR0020),OemToAnsi(STR0021),OemToAnsi(STR0022),OemToAnsi(STR0023),OemToAnsi(STR0023)} //"Loja"###"Pedido"###"Item"###"Saldo"###"Entrega"###"Produto"###"Descricao"###"Tipo"###"Valor Unit."###"Emissao"###"Local"###"Local"
		
		oQual := TWBrowse():New( 29,4,243,76,,aCab,{15,30,15,40,30,60,70,15,40,30},oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
		oQual:SetArray(aArrayF4)
		oQual:bLine := { || aArrayF4[oQual:nAT] }
		
		If !Empty(cVar)
			@ 15  ,4   SAY OemToAnsi(STR0018) Of oDlg PIXEL SIZE 47 ,9 //"Produto"
			@ 14  ,30  MSGET cVar PICTURE PesqPict('SB1','B1_COD') When .F. Of oDlg PIXEL SIZE 80,9
		Else
			@ 15  ,4   SAY OemToAnsi(STR0024) Of oDlg PIXEL SIZE 120 ,9 //'Selecione o Pedido de Compra'
		EndIf
		
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nSavQual:=oQual:nAT,nOpca:=1,oDlg:End()},{||oDlg:End()},,aButtons)
		
		If nOpca == 1
			dbSelectArea("SC7")
			MsGoto(aArrSldo[nSavQual][2])

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Converte o Pedido para a Moeda 1 (Real) usada na NFE         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nPreco := xMoeda(SC7->C7_PRECO,SC7->C7_MOEDA,1,dDataBase,TamSX3("DB3_VUNIT")[2],SC7->C7_TXMOEDA)
			nSalPed:= aArrSldo[nSavQual][1]
			lAllPC := SC7->C7_QUANT==nSalPed 

			If !Empty(aCols[Len(aCols)][nPosPrd]) .And. n > Len(aCols)
				aAdd(aCols,Array(Len(aHeader)+1))
				//(HF)  isso no padrão ta fora do IF
				For nAuxCnt := 1 To Len(aHeader)
				Do Case
					Case Trim(aHeader[nAuxCnt][2]) == "DB3_ITDOC"
						If Empty(aCols[Len(aCols)][nAuxCnt]) .And. Len(aCols) > 1
							aCols[Len(aCols)][nAuxCnt] 	:= aCols[Len(aCols)-1][nAuxCnt]
						EndIf
					Case Trim(aHeader[nAuxCnt][2]) == "DB3_ITEM"
						If Len(aCols) == 1
							aCols[Len(aCols)][nAuxCnt] 	:= "001"
						Else
							aCols[Len(aCols)][nAuxCnt] 	:= Soma1(aCols[Len(aCols)-1][nAuxCnt])
						EndIf
					Case Trim(aHeader[nAuxCnt][2]) == "DB3_NRAVRC"
						aCols[Len(aCols)][nAuxCnt] := M->DB1_NRAVRC
					Case Trim(aHeader[nAuxCnt][2]) == "DB3_CODPRO"
						aCols[Len(aCols)][nAuxCnt] := SC7->C7_PRODUTO
					Case Trim(aHeader[nAuxCnt][2]) == "DB3_NUMPC"
						aCols[Len(aCols)][nAuxCnt]	:= SC7->C7_NUM
					Case Trim(aHeader[nAuxCnt][2]) == "DB3_ITEMPC"
						aCols[Len(aCols)][nAuxCnt]	:= SC7->C7_ITEM
	 				Case Trim(aHeader[nAuxCnt][2]) == "DB3_QUANT"
						if AllTrim(GetNewPar("XM_PED_PRE","N")) == "S"  //Itambé
							aCols[Len(aCols)][nAuxCnt]	:= nSalPed
						endif
					Case Trim(aHeader[nAuxCnt][2]) == "DB3_VUNIT"
						if AllTrim(GetNewPar("XM_PED_PRE","N")) == "S"  //Itambé
							aCols[Len(aCols)][nAuxCnt]	:= nPreco
						endif
					Case Trim(aHeader[nAuxCnt][2]) == "DB3_TOTAL"
						if AllTrim(GetNewPar("XM_PED_PRE","N")) == "S"  //Itambé
							aCols[Len(aCols)][nAuxCnt] := IIf(lAllPC,xMoeda(SC7->C7_TOTAL,SC7->C7_MOEDA,,dDataBase,,SC7->C7_TXMOEDA,),NoRound(nSalPed*nPreco,TamSX3('DB3_TOTAL')[2]))
						endif
					Case Trim(aHeader[nAuxCnt][2]) == "DB3_DESC"
						if AllTrim(GetNewPar("XM_PED_PRE","N")) == "S"  //Itambé
							aCols[Len(aCols)][nAuxCnt] := SC7->C7_DESC
						endif
					Case Trim(aHeader[nAuxCnt][2]) == "DB3_VALDES"
						if AllTrim(GetNewPar("XM_PED_PRE","N")) == "S"  //Itambé
							aCols[Len(aCols)][nAuxCnt] := ((SC7->C7_VLDESC/SC7->C7_QUANT) * nSalPed)
						endif
					Case Trim(aHeader[nAuxCnt][2]) == "DB3_ALI_WT"
						aCols[Len(aCols)][nAuxCnt] 	:= "DB3"
					Case Trim(aHeader[nAuxCnt][2]) == "DB3_REC_WT"
						aCols[Len(aCols)][nAuxCnt] 	:= 0
					OtherWise
						If Empty(aCols[Len(aCols)][nAuxCnt])
							aCols[Len(aCols)][nAuxCnt] := CriaVar(aHeader[nAuxCnt][2])
						EndIf
				EndCase
				Next nAuxCnt
				aCols[Len(aCols)][Len(aHeader)+1] := .F.
			else
				// (HF) Este else foi implementado para acerto de erro do padrão
				For nAuxCnt := 1 To Len(aHeader)
				Do Case
					Case Trim(aHeader[nAuxCnt][2]) == "DB3_CODPRO"
						aCols[N][nAuxCnt] := SC7->C7_PRODUTO
					Case Trim(aHeader[nAuxCnt][2]) == "DB3_NUMPC"
						aCols[N][nAuxCnt]	:= SC7->C7_NUM
					Case Trim(aHeader[nAuxCnt][2]) == "DB3_ITEMPC"
						aCols[N][nAuxCnt]	:= SC7->C7_ITEM
	 				Case Trim(aHeader[nAuxCnt][2]) == "DB3_QUANT"
						if AllTrim(GetNewPar("XM_PED_PRE","N")) == "S"   //Itambé
							aCols[N][nAuxCnt]	:= nSalPed
						EndIf
					Case Trim(aHeader[nAuxCnt][2]) == "DB3_VUNIT"
						if AllTrim(GetNewPar("XM_PED_PRE","N")) == "S"   //Itambé
							aCols[N][nAuxCnt]	:= nPreco
						endif
					Case Trim(aHeader[nAuxCnt][2]) == "DB3_TOTAL"
						if AllTrim(GetNewPar("XM_PED_PRE","N")) == "S"   //Itambé
							aCols[N][nAuxCnt] := IIf(lAllPC,xMoeda(SC7->C7_TOTAL,SC7->C7_MOEDA,,dDataBase,,SC7->C7_TXMOEDA,),NoRound(nSalPed*nPreco,TamSX3('DB3_TOTAL')[2]))
						endif
					Case Trim(aHeader[nAuxCnt][2]) == "DB3_DESC"
						if AllTrim(GetNewPar("XM_PED_PRE","N")) == "S"  //Itambé
							aCols[N][nAuxCnt] := SC7->C7_DESC
						endif
					Case Trim(aHeader[nAuxCnt][2]) == "DB3_VALDES"
						if AllTrim(GetNewPar("XM_PED_PRE","N")) == "S"  //Itambé
							aCols[N][nAuxCnt] := ((SC7->C7_VLDESC/SC7->C7_QUANT) * nSalPed)
						endif
				EndCase
				Next nAuxCnt
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Impede que o item obtido do PC seja deletado pela getdados do A.R. na mov. das setas. ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ValType( oGetDad2 ) == "O" 	
				oGetDad2:lNewLine:=.F.
			EndIf 	
		EndIf
	Else
		HELP(" ",1,"A103F4")
	EndIf
Else
	HELP(" ",1,"A103F4")
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Efetua a chamada do ponto de entrada                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "MT145IPC" )
	ExecBlock( "MT145IPC", .F., .F. )
EndIf

SetKey(VK_F5,bSavKeyF5)
SetKey(VK_F6,bSavKeyF6)
SetKey(VK_F3,_bSavKeyF3) //(HF) 

RestArea(aAreaSB1)
RestArea(aArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³M145Homolo³ Autor ³ Fernando Joly Siquini ³ Data ³12.04.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Funcao de Homologacao dos A.R.E.s                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Void()                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1: Array com registros de Cabecalho de NF - DB2        ³±±
±±³          ³ ExpA2: Array com registros de Itens de NF     - DB3        ³±±
±±³          ³ ExpL1: Encerra a Homolocacao                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MATA145                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function M145Homo(lEnd)  //(HF) M145Homolo

Local aCabs      := {}
Local aLogErro   := {}
Local aItens     := {}
Local aParam     := {}
Local aParamNew  := {}
Local aItensNew  := {}
Local aCabsNew   := {}
Local aMt145Add  := {}
Local cSeek      := ''
Local cUM        := ''
Local cCC        := ''
Local cCond      := ''
Local cCondPE    := ''
Local cCF        := ''
Local cCFPE      := ''
Local cTesEnt    := ''
Local cTesEntPE  := ''
Local cServEnt   := ''
Local cConta     := ''
Local cLocPad    := ''
Local cPercent   := ''
Local cUsaForm   := ''
Local lM145HTF   := ExistBlock('M145HTF')
Local lM145HCI   := ExistBlock('M145HCI')
Local lM145HCDP  := ExistBlock('M145HCDP')
Local lM145HTES  := ExistBlock('M145HTES')
Local lM145HCF   := ExistBlock('M145HCF')
Local lM145HANF  := ExistBlock('M145HANF')
Local lM145HAAR  := ExistBlock('M145HAAR') 
Local lM145HERR  := ExistBlock('M145HERR')
Local lM145HMIT  := ExistBlock('M145HMIT')
Local lM145CMSG  := ExistBlock('M145CMSG')    
Local lM145HOM   := ExistBlock('M145HOM')
Local lRet       := .T.
Local lSemTES    := .F.
Local nX         := 0
Local nY         := 0
Local nContDB2   := 0
Local nTamItem   := TamSX3('D1_ITEM')[1]
Local oDlg
Local oBtn1
Local lMvIntDl   := GetMv("MV_INTDL") == "S" // Integracao com WMS
Local lFirst     := .T.
Local lRetorno   := .T.
Local lFormul    := !Empty(DB2->(FieldPos("DB2_FORMUL")))
Local cTipoNF    := SuperGetMV("MV_TPNRNFS")
Local cNumNF     := ""
Local cSerie     := ""
Local nPosRecDB2 := Len(aHeader1)
Local lShow      := .T.         
Local nPosForm	 := aScan(aHeader1,{|x| AllTrim(x[2])=="DB2_FORMUL"})
Local nQtd2UM    := 0

// Variaveis utilizadas em processo de mudanca de data 
Local dDataOrig  := dDataBase
Local lMudaData  := GetMv("MV_DATAHOM",NIL,"1") == "2" // Identifica se na homologacao qdo classifica NF (1) Usa database (2) Usa data final da entrega
Local lVALNFE    := GetNewPar( "MV_VALNFE", .T. ) //-- Valida a existencia da Nota Fiscal Informada ?
Local _aRet      := {}  //(HF) Retorno do nosso Ponto de Entrada para incluir campos no aItem

Default lEnd     := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Funcao utilizada para verificar a ultima versao dos fontes      ³
//³ SIGACUS.PRW, SIGACUSA.PRX e SIGACUSB.PRX, aplicados no rpo do   |
//| cliente, assim verificando a necessidade de uma atualizacao     |
//| nestes fontes. NAO REMOVER !!!							        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF !(FindFunction("SIGACUS_V") .and. SIGACUS_V() >= 20050512)
    Final(OemToAnsi(STR0043)+" SIGACUS.PRW !!!") //"Atualizar"
Endif
IF !(FindFunction("SIGACUSA_V") .and. SIGACUSA_V() >= 20050512)
    Final(OemToAnsi(STR0043)+" SIGACUSA.PRX !!!") //"Atualizar"
Endif
IF !(FindFunction("SIGACUSB_V") .and. SIGACUSB_V() >= 20050512)
    Final(OemToAnsi(STR0043)+" SIGACUSB.PRW !!!") //"Atualizar"
Endif

If lM145CMSG
	lShow := ExecBlock('M145CMSG', .F., .F.)
	If ValType(lShow) <> 'L'
		lShow := .T.
	EndIf	
Endif

If !(DB1->DB1_HOMOLO=='3') .And. IIf(!l145Auto,IIF(lShow,MsgYesNo(STR0025, STR0026),.T.),.T.) //'Confirma a Homologacao deste Aviso de Recebimento?'###'Atencao'
	ProcRegua(Len(aCols1))
	For nX := 1 to Len(aCols1)
		nContDB2 ++
		cPercent := AllTrim(Str(Int((nContDB2/Len(aCols1))*100)))
		If !l145Auto
			IncProc(STR0027+cPercent+'%' ) //'Aguarde... Homologando '
		EndIf
		//-- Interrompe a Homologacao
		If lEnd
			If Aviso(STR0026, STR0028, {STR0029, STR0030}) == 1 //'Atencao'###'Deseja interromper a Homolocacao?'###'Sim'###'Nao'
				Exit
			Else
				lEnd := .F.
			EndIf
		EndIf
		cUsaForm := If( aCols1[nX][nPosForm] == "1","S","N")
		//-- ExecBlock ANTERIOR A INICIALIZACAO DOS CAMPOS para a geracao da NF
		If lM145HTF
			aParam := {cTipo, cUsaForm}
			aParamNew := ExecBlock('M145HTF', .F., .F., aParam)
			If ValType(aParamNew) == 'A'
				cTipo    := aParamNew[1]
				cUsaForm := aParamNew[2]
			EndIf
		EndIf
		aCabs  := {}
		aItens := {}
		aCabsNew  := {}
		aItensNew := {}
		cNumNF := ""
				
		dbSelectArea('DB2')
		dbSetOrder(1)
		dbGoto(aCols1[nX][nPosRecDB2])

		If lFormul .And. DB2->DB2_FORMUL == "1" .And. ((TRIM(DB2->DB2_DOC)+TRIM(DB2->DB2_SERIE)) == (TRIM(DB2->DB2_NRAVRC)+TRIM(DB2->DB2_ITEM)))
			If lFirst
				lRetorno := Sx5NumNota(@cSerie,cTipoNF)
				If lRetorno
					lFirst   := .F.
				EndIf
			EndIf
			If lRetorno .And. cTipoNF <> "3"
				cNumNF := NxtSX5Nota(cSerie,.T.,cTipoNF)
			Else
				cNumNF := ""
				cSerie := ""
			EndIf
		Else
			cNumNF := DB2->DB2_DOC
			cSerie := DB2->DB2_SERIE
		EndIf

		dbSelectArea('DB2')
		//-- Desconsidera NF que ja foram homologadas
		If !Empty(cNumNF) 
			SF1->(dbSetOrder(1))
			If SF1->(dbSeek(xFilial('SF1')+cNumNF+cSerie+DB2->DB2_CLIFOR+DB2->DB2_LOJA+cTipo, .F.))
				If lVALNFE //-- Valida a existencia da Nota Fiscal Informada ?                        
					Aviso(STR0026,STR0048+cNumNF+cSerie+cTipo+" "+STR0046+DB2->DB2_CLIFOR+DB2->DB2_LOJA+" "+STR0049 ,{'Ok'}) //'Atencao'###'
				EndIf	
				nContDB2 --
				Loop
			EndIf
		Else
			nContDB2 --
			Loop
		EndIf
		cCond := ''
		SA2->(dbSetOrder(1))
		If SA2->(dbSeek(xFilial('SA2')+DB2->DB2_CLIFOR+DB2->DB2_LOJA, .F.))
			cCond := SA2->A2_COND
		EndIf
		//-- Execblock para Inicializacao da Condicao de Pagamento
		If lM145HCDP
			cCondPE := ExecBlock('M145HCDP', .F., .F., cCond)
			If ValType(cCondPE) == 'C'
				cCond := cCondPE
			EndIf
		EndIf
		aAdd(aCabs, {'F1_FILIAL ', xFilial('SF1'), Nil})
		aAdd(aCabs, {'F1_TIPO   ', cTipo       , Nil})
		aAdd(aCabs, {'F1_FORMUL ', cUsaForm      , Nil})
		aAdd(aCabs, {'F1_DOC    ', cNumNF        , Nil})
		aAdd(aCabs, {'F1_SERIE  ', cSerie        , Nil})
		aAdd(aCabs, {'F1_EMISSAO', DB2_EMISSA    , Nil})
		aAdd(aCabs, {'F1_FORNECE', DB2_CLIFOR    , Nil})
		aAdd(aCabs, {'F1_LOJA   ', DB2_LOJA      , Nil})
        If !Empty(DB2_VALICM)
			aAdd(aCabs, {'F1_VALICM ', DB2_VALICM    , Nil})
		Endif	
		If !Empty(DB2_VALIPI)
			aAdd(aCabs, {'F1_VALIPI ', DB2_VALIPI    , Nil})
		Endif	
		aAdd(aCabs, {'F1_PESO   ', DB2_PESO      , Nil})
		aAdd(aCabs, {'F1_ESPECIE', DB2_ESPECI    , Nil})
		aAdd(aCabs, {'F1_COND   ', cCond         , Nil})
		aadd(aCabs, {"F1_CHVNFE" , cChaveXml     , Nil})  //(HF) aqui por nossa conta e risco.
		aadd(aCabec,{"F1_VALPEDG", nPedagio      , Nil})
		if .not. empty(cxmlUfo)
			aadd(aCabs, {"F1_EST", cxmlUfo 		 , Nil})  //(HF) aqui cUf de Origem.
		endif
		lSemTES := .F.
		dbSelectArea('DB3')
		If dbSeek(cSeek:=DB2->DB2_FILIAL+DB2->DB2_NRAVRC+DB2->DB2_ITEM, .F.)
			Do While !Eof() .And. !lEnd .And. cSeek==DB3_FILIAL+DB3_NRAVRC+DB3_ITDOC
				//-- Interrompe a Homologacao
				If lEnd
					If Aviso(STR0026, STR0028, {STR0029, STR0030}) == 1 //'Atencao'###'Deseja interromper a Homolocacao?'###'Sim'###'Nao'
						Exit
					Else
						lEnd := .F.
					EndIf
				EndIf
				cUM      := ''
				cCC      := ''
				cConta   := ''
				cLocPad  := ''
				cTesEnt  := ''
				cCF      := ''
				cServEnt := ''
				nQtd2UM  := 0
				SB1->(dbSetOrder(1))
				If SB1->(dbSeek(xFilial('SB1')+DB3->DB3_CODPRO, .F.))
					cUM     := SB1->B1_UM
					if cPCSol == "S"
						cCC := space( len( SB1->B1_CC ) )
					else
						cCC := SB1->B1_CC
					endif
					cTesEnt := RetFldProd(SB1->B1_COD,"B1_TE")
					cConta  := SB1->B1_CONTA
					cLocPad := RetFldProd(SB1->B1_COD,"B1_LOCPAD")
					SB5->(dbSetOrder(1))
					If SB5->(dbSeek(xFilial('SB5')+DB3->DB3_CODPRO, .F.))
						cServEnt := SB5->B5_SERVENT
					EndIf
				EndIf
				//-- Execblock para Inicializacao da TES de Entrada
				If lM145HTES
					cTesEntPE := ExecBlock('M145HTES', .F., .F., cTesEnt)
					If ValType(cTesEntPE) == 'C'
						cTesEnt := cTesEntPE
					EndIf
				EndIf
				SF4->(dbSetOrder(1))
				If SF4->(dbSeek(xFilial('SF4')+cTesEnt, .F.))
					cCF := SF4->F4_CF
				EndIf
				//-- Execblock para Inicializacao do CF
				If lM145HCF
					cCFPE := ExecBlock('M145HCF', .F., .F., cCF)
					If ValType(cCFPE) == 'C'
						cCF := cCFPE
					EndIf
				EndIf
				If !lSemTES .And. Empty(cTesEnt)
					lSemTES := .T.
				EndIf

				nQtd2UM := ConvUM(DB3_CODPRO,DB3_QUANT,0,2)
				If !Empty(DB3_NUMPC) .And. !Empty(DB3_ITEMPC)
					SC7->(dbSetOrder(1))
					If SC7->(dbSeek(xFilial("SC7")+DB3->DB3_NUMPC+DB3->DB3_ITEMPC))
						cLocPad := SC7->C7_LOCAL
					Endif
					if cPCSol == "S"
						cCC := SC7->C7_CC
					endif
				Endif    
				
				aAdd(aItens, {})
				aAdd(aItens[Len(aItens)], {'D1_FILIAL ', xFilial('SD1')   , Nil})
				aAdd(aItens[Len(aItens)], {'D1_DOC    ', cNumNF           , Nil})
				aAdd(aItens[Len(aItens)], {'D1_SERIE  ', cSerie           , Nil})
				aAdd(aItens[Len(aItens)], {'D1_FORNECE', DB2->DB2_CLIFOR  , Nil})
				aAdd(aItens[Len(aItens)], {'D1_LOJA   ', DB2->DB2_LOJA    , Nil})
				aAdd(aItens[Len(aItens)], {'D1_UM     ', cUM              , Nil})
				aAdd(aItens[Len(aItens)], {'D1_COD    ', DB3_CODPRO       , Nil})
				aAdd(aItens[Len(aItens)], {'D1_CC     ', cCC              , Nil})
				aAdd(aItens[Len(aItens)], {'D1_CONTA  ', cConta           , Nil})				
				If !Empty(DB3_NUMPC) .And. !Empty(DB3_ITEMPC)
					aAdd(aItens[Len(aItens)], {'D1_PEDIDO ', DB3_NUMPC    , ""	})
					aAdd(aItens[Len(aItens)], {'D1_ITEMPC ', DB3_ITEMPC   , ""	})
				EndIf
				aAdd(aItens[Len(aItens)], {'D1_QUANT  ', DB3_QUANT        , Nil})
				aAdd(aItens[Len(aItens)], {'D1_QTSEGUM', nQtd2UM          , Nil})
				aAdd(aItens[Len(aItens)], {'D1_VUNIT  ', DB3_VUNIT        , Nil})
				aAdd(aItens[Len(aItens)], {'D1_TOTAL  ', DB3_TOTAL        , Nil})
				If !lSemTes
					aAdd(aItens[Len(aItens)], {'D1_TES    ', cTesEnt      , Nil})
					aAdd(aItens[Len(aItens)], {'D1_CF     ', cCF          , Nil})
				EndIf
				aAdd(aItens[Len(aItens)], {'D1_LOCAL  ', cLocPad          , Nil})
				aAdd(aItens[Len(aItens)], {'D1_ORIGLAN', 'AR'             , Nil})
				aAdd(aItens[Len(aItens)], {'D1_VALDESC', DB3_VALDES       , Nil})
				aAdd(aItens[Len(aItens)], {'D1_DESC   ', DB3_DESC         , Nil})
				
				If !Empty(DB3_SERVIC) .Or. !Empty(cServEnt)
					aAdd(aItens[Len(aItens)], {'D1_SERVIC ', DB3_SERVIC     , Nil})
					If lMvIntDl
						aAdd(aItens[Len(aItens)], {'D1_ENDER  ', DB3_ENDER  , Nil})
	
						aAdd(aItens[Len(aItens)], {'D1_TPESTR ', DB3_TPESTR , Nil})
	
						If Empty(DB3_SERVIC) .And. !Empty(cServEnt)
							aAdd(aItens[Len(aItens)], {'D1_SERVIC ', cServEnt , Nil})
						EndIf
					EndIf
	
					If !Empty(DB3_SERVIC) .Or. !Empty(cServEnt)
						aAdd(aItens[Len(aItens)], {'D1_STSERV ', '1'           , 'AllWaysTrue()'})
					EndIf
				Endif
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Ponto de entrada para inclusão de novos itens no array aCabs e aItens ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ExistBlock( "XMLPEITE" )   //(HF) PE para incluir campos SD1 no aItens. Ponto Entrada Nosso
		   			_aRet := ExecBlock( "XMLPEITE", .F., .F., { DB3->DB3_CODPRO,oDet,val(DB3->DB3_ITEM) } )
					If ValType(_aRet) == "A"
						AEval(_aRet, {|x| AAdd(aItens[Len(aItens)],x)})
					EndIf
 				endif
				If ( ExistBlock("MT145ADD") )  //(HF) padrão, vai SEM o oDet que é o item do XML
					aMt145Add := ExecBlock("MT145ADD",.F.,.F.,{aCabs,aItens})
					If ( ValType(aMt145Add) == "A" ) .And. Len(aMt145Add) > 1
						aCabsNew  := aMt145Add[1]
						aItensNew := aMt145Add[2]

						If ( ValType(aCabsNew) == "A" ) .And. Len(aCabsNew) > 0
							aCabs := aClone(aCabsNew)
						EndIf

						If ( ValType(aItensNew) == "A" ) .And. Len(aItensNew) > 0
							aItens := aClone(aItensNew)
						EndIf

					Endif	
				EndIf			
				
				If lM145HMIT
					ExecBlock('M145HMIT', .F., .F., {DB3_NUMPC,DB3_ITEMPC})
				EndIf

				dbSelectArea('DB3')
				dbSkip()
			EndDo
			If lEnd
				Exit
			EndIf
		EndIf
		If !lEnd .And. (Len(aCabs)>0 .And. Len(aItens)>0)
			//-- ExecBlock ANTERIOR a geracao da NF
			If lM145HCI
				aParam := {}
				aAdd(aParam, aClone(aCabs))
				aAdd(aParam, aClone(aItens))
				aParamNew := ExecBlock('M145HCI', .F., .F., aParam)
				If ValType(aParamNew) == 'A'
					aCabs := aClone(aParamNew[1])
					aItens := aClone(aParamNew[2])
				EndIf
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Protege a ordem do SC7 para a chamada da Rotina Automatica³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SC7")
			dbSetOrder(1)
			lMSErroAuto := .F.
			// Identifica se na homologacao muda a data - ALTERA DATABASE 
			If lMudaData .And. !Empty(DB1->DB1_ENTREF)
				dDataBase:=DB1->DB1_ENTREF
			EndIf
			If lSemTES
				MSExecAuto({|x,y,z| MATA140(x,y,z)}, aCabs, aItens, 3)
			Else
				MSExecAuto({|x,y,z| MATA103(x,y,z)}, aCabs, aItens, 3)
			EndIf
			// Identifica se na homologacao muda a data - RESTAURA DATABASE Original
			If lMudaData .And. !Empty(DB1->DB1_ENTREF)
				dDataBase:=dDataOrig
			EndIf
			If lMSErroAuto     
				If aScan(aLogErro, {|x| x[1]+x[2]+x[3]+x[4]==DB2->DB2_NRAVRC+DB2->DB2_ITEM+DB2->DB2_DOC+DB2->DB2_SERIE}) == 0
					aAdd(aLogErro, {DB2->DB2_NRAVRC, DB2->DB2_ITEM, DB2->DB2_DOC, DB2->DB2_SERIE})
				EndIf
			Else
				RecLock("DB2", .F.)
				Replace DB2_DOC   With cNumNF
				Replace DB2_SERIE With cSerie
				MsUnlock()
			EndIf
			//-- ExecBlock APOS a geracao da NF
			If lM145HANF
				ExecBlock('M145HANF', .F., .F., lMSErroAuto)
			EndIf
		EndIf
	Next nX
	If Len(aLogErro) > 0 .Or. lEnd
		//Aviso('Atencao', 'Ocorreram problemas na Homologacao, e este A.R. foi PARCIALMENTE gerado.', {'Ok'})
		U_M145GeNH(aLogErro, lEnd)
		If lEnd
			Aviso(STR0026, STR0031, {'Ok'}) //'Atencao'###'Homologacao Interrompida pelo Operador'
		Else
			DEFINE MSDIALOG oDlg FROM  96, 039 TO 310,612 TITLE OemToAnsi(STR0001) PIXEL //"Aviso de Recebimento"
			@ 18,6 TO 66,280 LABEL '' OF oDlg  PIXEL
			@ 29, 015 SAY OemToAnsi(STR0032) OF oDlg PIXEL SIZE 268, 8 //'Algumas Notas Fiscais deste Aviso de Recebimento nao foram Homologados.  Corrija os problemas que'
			@ 38, 015 SAY OemToAnsi(STR0033) OF oDlg PIXEL SIZE 268, 8 //'impossibiliaram a Homolocacao Completa do A.R. e execute novamente a rotrina de Homolocacao.     '
			@ 48, 015 SAY OemToAnsi(STR0034) OF oDlg PIXEL SIZE 268, 8 //'Obs.: Foi gerado o arquivo "ARNAOHOM.LOG" com informacoes sobre os itens nao Homologados         '
			@ 86, 505 BTNBMP oBtn1 RESOURCE 'S4WB016N' PIXEL SIZE 25,25 DESIGN ACTION U_M145ShNH(aLogErro) OF oDlg
			DEFINE SBUTTON FROM 80, 252 TYPE 1 ACTION (oDlg:End()) ENABLE OF oDlg
			ACTIVATE DIALOG oDlg
		EndIf
		lRet := .F.
	Else                                   
	 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	 //³Ponto de entrada para homologar o Aviso de Recebimento da NFE ³
	 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		       
	 If lM145HOM
	    lRet := ExecBlock('M145HOM', .F., .F.,{aCols1,aCols2})    
	    
	    If ValType(lRet) <> "L"
	       lRet := .T.
	    EndIf
	    
	 EndIf
	 
	 If lRet   
		If lVALNFE //-- Valida a existencia da Nota Fiscal Informada ?                        
	        If nContDB2 == Len(aCols1)  
				If RecLock("DB1", .F.)
					Replace DB1_HOMOLO With "3" // Homologou todas as NFes
					MsUnlock()
				EndIf
		    ElseIf nContDB2 <> Len(aCols1) .And. DB1->DB1_HOMOLO == "1"
				If RecLock("DB1", .F.)
					Replace DB1_HOMOLO With "2" // Homologou Parcialmente NFe
					MsUnlock()
				EndIf
		    ElseIf nContDB2 == 0 .And. DB1->DB1_HOMOLO == "2"
				If RecLock("DB1", .F.)
					Replace DB1_HOMOLO With "3" // Homologou Todas as NFes
					MsUnlock()
				EndIf
	        EndIf
	    Else 
			If RecLock("DB1", .F.)
				Replace DB1_HOMOLO With "3" // Homologou todas as NFes
				MsUnlock()
			EndIf	    
	    EndIf
	 EndIf       
	EndIf
	//-- ExecBlock APOS a geracao do AR
	If lM145HAAR
		ExecBlock('M145HAAR', .F., .F., (Len(aLogErro)>0))
	EndIf
	If lM145HERR
		ExecBlock('M145HERR', .F., .F.,{aLogErro})
    EndIf
else
	lRet := .F. //(HF) Se o cabra não confirmar a homologação
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³M145Legend ³Autor ³ Fernando Joly Siquini ³ Data ³04.09.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Demonstra a legenda das cores da mbrowse                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina monta uma dialog com a descricao das cores da    ³±±
±±³          ³Mbrowse.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
//Function M145Legend()
//
//BrwLegenda(cCadastro,STR0035,aLegenda)
//
//Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M145ShowNH³ Autor ³Fernando joly Siquini  ³ Data ³ 16/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Indica o log dos Itens da AR nao Homologados               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA145                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function M145ShNH(aLogErro)  //(HF) U_M145ShNH

Local cNAR       := AllTrim(RetTitle('DB2_NRAVRC'))
Local cItem      := AllTrim(RetTitle('DB2_ITEM'))
Local cDoc       := AllTrim(RetTitle('DB2_DOC'))
Local cSerie     := AllTrim(RetTitle('DB2_SERIE'))
Local cVarq      := ''
Local nAt        := 0
Local oDlg
Local oQual

Default aLogErro   := {}

If Len(aLogErro) > 0
	DEFINE MSDIALOG oDlg TITLE STR0039 From 130,70 To 350,410 OF oMainWnd PIXEL //'Item(ns) do A.R. nao Homologado(s)'
	@ 10,13 TO 90,172 LABEL '' OF oDlg  PIXEL
	@ 20,18 LISTBOX oQual VAR cVarQ Fields HEADER cNAR,cItem,cDoc, cSerie SIZE 150,62 NOSCROLL OF oDlg PIXEL
	oQual:SetArray(aLogErro)
	oQual:bLine := { || {aLogErro[oQual:nAt,1],aLogErro[oQual:nAt,2],aLogErro[oQual:nAt,3],aLogErro[oQual:nAt,4]}}
	DEFINE SBUTTON FROM 95,90 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg PIXEL
	ACTIVATE MSDIALOG oDlg
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M145GeraNH³ Autor ³Fernando joly Siquini  ³ Data ³ 16/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera Arquivo Texto com LOG de erro c/itens nao homologados ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA145                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function M145GeNH(aLogErro, lEnd)  //(HF) U_M145GeNH

Local cLogFile   := 'ARNAOHOM.LOG'
Local cString    := ''
Local cNAR       := AllTrim(RetTitle('DB2_NRAVRC'))
Local cItem      := AllTrim(RetTitle('DB2_ITEM'))
Local cDoc       := AllTrim(RetTitle('DB2_DOC'))
Local cSerie     := AllTrim(RetTitle('DB2_SERIE'))
Local nLogHdl    := 0
Local nX         := 0

Default aLogErro   := {}
Default lEnd       := .F.

If File(cLogFile)
	nLogHdl := fOpen(cLogFile, 2)
	fSeek(nLogHdl, 0, 2)
Else
	nLogHdl := MSfCreate(cLogFile, 0)
EndIf
If nLogHdl > 0
	cString := Replicate('-', 80) + Chr(13) + Chr(10)
	fWrite(nLogHdl,cString,Len(cString))
	cString := SubStr(cUsuario,7,6) + ', ' + Time() + ', ' + DtoC(Date()) + Chr(13) + Chr(10)
	fWrite(nLogHdl,cString,Len(cString))
	If Len(aLogErro) > 0
		cString := PadR(cNAR, TamSX3('DB2_NRAVRC')[1]) + '|' + PadR(cItem, TamSX3('DB2_ITEM')[1])+ '|' + PadR(cDoc, TamSX3('DB2_DOC')[1])+ '|' + PadR(cSerie, TamSX3('DB2_SERIE')[1]) + Chr(13) + Chr(10)
		fWrite(nLogHdl,cString,Len(cString))
		For nX := 1 to Len(aLogErro)
			cString := aLogErro[nX,1] + '|' + aLogErro[nX,2] + '|' + aLogErro[nX,3] + '|' + aLogErro[nX,4] + Chr(13) + Chr(10)
			fWrite(nLogHdl,cString,Len(cString))
		Next nX
	EndIf
	If lEnd
		cString := STR0040 //'INTERROMPIDO PELO USUARIO'
		fWrite(nLogHdl,cString,Len(cString))
	EndIf
	fClose(nLogHdl)
Else
	Aviso(STR0026, STR0041, {'Ok'})		 //'Atencao'###'Nao foi possivel realizar a gravacao do LOG de erro referente ao(s) item(ns) da A.R.'
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M145TudOk ºAutor  ³Fernando Joly       º Data ³  09/06/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida a digitacao do Cabecalho                             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function M145TdOk(nOpcx)   //(HF) U_M145TdOk

Local nCntFor := 0
Local nSave   := N
Local lRet    := .T.
Local nPDoc   := aScan(aHeader1,{|x| AllTrim(x[2])=="DB2_DOC"  })
Local nPSerie := aScan(aHeader1,{|x| AllTrim(x[2])=="DB2_SERIE"})
Local nPItem  := aScan(aHeader1,{|x| AllTrim(x[2])=="DB2_ITEM" })
Local nQuant  := aScan(aHeader2,{|x| AllTrim(x[2])=="DB3_QUANT"})
Local nUnit   := aScan(aHeader2,{|x| AllTrim(x[2])=="DB3_VUNIT"})
Local nTotal  := aScan(aHeader2,{|x| AllTrim(x[2])=="DB3_TOTAL"})
Local nPItDoc := aScan(aHeader2,{|x| AllTrim(x[2])=="DB3_ITDOC"})
Local nUsado  := Len(aHeader1)
Local nX      := 0
Local aSvCols := {}

If Empty(M->DB1_NRAVRC) .Or. Empty(M->DB1_EMISSA) .Or. Empty(M->DB1_TIPO) .Or. Empty(M->DB1_CLIFOR) .Or. Empty(M->DB1_LOJA)
	Help(' ', 1, 'OBRIGAT2')
	lRet := .F.
EndIf

If oFolder:nOption == 1
	aCols1  := aClone(aCols)
	If A145SemDoc(aCols1)
		Help(" ",1,"MATA14501")
		lRet := .F.
	EndIf
	If lRet
		For nCntFor := 1 To Len(aCols)
			If !GdNoEmpty({'DB2_DOC','DB2_EMISSA','DB2_TIPO','DB2_CLIFOR','DB2_LOJA'},nCntFor,aHeader,aCols)
				lRet := .F.
				Exit
			EndIf
			If !aCols[nCntFor][nUsado+1]
				If nCntFor <= Len(aColsIt) .And. A145SemItm(aColsIt[nCntFor])
					Help(" ",1,"MATA14502")
					lRet := .F.
					Exit
				EndIf
			EndIf
		Next nCntFor
	EndIf
	If lRet
		// Quando se inclui uma NF e nao clica no folder "Itens"
		// o aColsIt nao possui nenhum item novo referente a NF
		If (Len(aCols) != Len(aColsIt))
			Help(" ",1,"MATA14502")
			lRet := .F.
		EndIf
		//-- Ao confirmar os dados, se estiver posicionado na pasta notas fiscais, verifica se os campos obrigatorios
		//-- da pasta itens da nota fiscal foram preenchidos
		If lRet
			For nX := 1 to Len(aColsIt)
				For nCntFor := 1 To Len(aColsIt[nX])
					If !GdNoEmpty({'DB3_CODPRO','DB3_QUANT','DB3_VUNIT','DB3_TOTAL'},nCntFor,aHeader2,aColsIt[nX])
						lRet := .F.
						Exit
					EndIf
				Next nCntFor
				If !lRet
					Exit
				EndIf
			Next nX
		EndIf
	EndIf
	If lRet
		For nCntFor := 1 to Len(aCols)
			If !(lRet:=U_M145LOK1(nCntFor))
				Exit
			EndIf
		Next
	Endif	
ElseIf oFolder:nOption == 2
	If lRet
		If A145SemDoc(aCols1)
			Help(" ",1,"MATA14501")
			lRet := .F.
		EndIf
		// Quando se inclui uma NF e nao clica no folder "Itens"
		// o aColsIt nao possui nenhum item novo referente a NF
		If lRet .And. (Len(aCols1) != Len(aColsIt))
			Help(" ",1,"MATA14502")
			lRet := .F.
		EndIf
		
		If lRet .And. A145SemItm(aCols)
			Help(" ",1,"MATA14502")
			lRet := .F.
		EndIf
		
		If lRet
			If Empty(aCols[n][nTotal])
				aCols[n][nTotal] := aCols[n][nQuant] * aCols[n][nUnit]
			EndIf
			If nPItDoc != 0 .And. n > 1
				If Empty(aCols[n,nPItDoc])
					aCols[n,nPItDoc] := aCols[n-1,nPItDoc]
				EndIf
			EndIf
			If Val(aCols[n,nPItDoc]) > Len(aColsIt)
				aColsIt[Len(aColsIt)] := aClone(aCols)
			Else 
				aColsIt[Val(aCols[n,nPItDoc])] := aClone(aCols)
			Endif				
			// Garantir que todos os elementos do aColsIt sejam validados
			aSvCols := aClone(aCols)
			For nCntFor := 1 To Len(aCols1)
				If !aCols1[nCntFor][nUsado+1]
					aCols := aClone(aColsIt[nCntFor])
					For nX := 1 to Len(aCols)
			            N := nX
						If !(lRet:=U_M145LOK2())
							Exit
						EndIf
					Next nX
				EndIf
				If !lRet
					Exit
				EndIf
			Next nCntFor
			// Restaura o aCols original para os itens atuais
			aCols := aClone(aSvCols)
			N := nSave
			
			If lRet
				For nCntFor := 1 To Len(aCols1)
					If !aCols1[nCntFor][nUsado+1]
						If A145SemItm(aColsIt[nCntFor])
							Help(" ",1,"MATA14502")
							lRet := .F.
							Exit
						EndIf
					EndIf
				Next nCntFor
			EndIf
		EndIf	
	EndIf	
Else
	aCols1  := aClone(aCols)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada antes da Confirmacao do Aviso Recebimento  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .And. ExistBlock("MT145TOK")
	lRet := ExecBlock("MT145TOK",.F.,.F.,{nOpcx})
	If ValType(lRet) <> "L"
		lRet := .T.			
	EndIf
EndIf
Return lRet    
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³DLA145Tot³ Autor ³ Fernando Joly Siquini ³ Data ³07.09.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao do valor total digitado                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Dicionario de Dados - Campo:DB3_TOTAL                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
//Function DLA145Tot(nTotal)
//
//Local aArea		  := GetArea()
//Local nPQuant    := aScan(aHeader,{|x| AllTrim(x[2]) == 'DB3_QUANT'})
//Local nPPreco    := aScan(aHeader,{|x| AllTrim(x[2]) == 'DB3_VUNIT'})
//Local nQuant	  := 0
//Local nPreco	  := 0
//Local lRet 		  := .T.
//Local nDif		  := 0
//
//If nPQuant > 0
//	nQuant := aCols[n, nPQuant]
//EndIf
//
//If nPPreco > 0
//	nPreco := aCols[n, nPPreco]
//EndIf
//
//nDif := NoRound(nQuant*nPreco,2)-nTotal
//If nDif < 0
//	nDif := -(nDif)
//EndIf
//
//If cTipo$'NDB' .And. nDif > 0.49
//	Help(' ',1,'TOTAL')
//	lRet := .F.
//EndIf
//
//RestArea(aArea)
//Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³A145ClDescºAutor  ³Fernando Joly S.    º Data ³  09/18/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Função alterada em 14/08/2009		        				  º±±
±±º          ³Quando for digitador o Valor do Desconto, calcula o % Desc  º±±
±±º          ³Quando for digitador o % Desc, calcula o Valor do Desconto  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SX3, nos campos DB3_VALDES ou DB3_DESC                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
//Function DLA145Desc()
//
//Local cCpo       := ReadVar()
//
//If 'DB3_VALDES' $cCpo
// 	GDFieldPut('DB3_DESC', 0)       
// 	GDFieldPut('DB3_DESC', NoRound((M->DB3_VALDES / (GdFieldGet("DB3_QUANT")*GdFieldGet("DB3_VUNIT")))*100))
//ElseIf 'DB3_DESC' $cCpo
//	GDFieldPut('DB3_VALDES', 0)                                            
// 	GDFieldPut('DB3_VALDES', NoRound((((GdFieldGet("DB3_QUANT")*GdFieldGet("DB3_VUNIT"))*M->DB3_DESC)/100)))
//EndIf
//
//Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SuperRecnoºAutor  ³Microsiga           º Data ³  08/29/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna o Recno do arquivo corrente                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function SuperRecno()

Local nRet := Recno()

#IFDEF TOP
	If !(TcSrvType()=='AS/400') .And. FieldPos('R_E_C_N_O_') > 0
		nRet := R_E_C_N_O_
	EndIf	
#ENDIF
	
Return nRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AjustaSX1 ºAutor  ³Alexandre Inacio Lemesº Data ³17/11/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA145                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AjustaSX1()

Local aHelpPor	:= {}
Local aHelpEng	:= {}
Local aHelpSpa	:= {}

Aadd( aHelpPor, "Indica se na busca do pedido de compra, " )
Aadd( aHelpPor, "através dos botões ou tecla de atalho, d" )
Aadd( aHelpPor, "eve ser considerado somente o código do " )
Aadd( aHelpPor, "fornecedor ou o código + loja do fornece" )
Aadd( aHelpPor, "dor.                                    " )

Aadd( aHelpEng, "It indicates whether during the order se" )
Aadd( aHelpEng, "arch by using the buttons or the shortcu" )
Aadd( aHelpEng, "t key only the supplier's code or the co" )
Aadd( aHelpEng, "de + the supplier's unit should be consi" )
Aadd( aHelpEng, "dered.                                  " )

Aadd( aHelpSpa, "Indica si en la busca del pedido de comp" )
Aadd( aHelpSpa, "ra, por medio de los botones o tecla de " )
Aadd( aHelpSpa, "atajo, se debe considerar solamente el c" )
Aadd( aHelpSpa, "odigo del proveedor o el codigo + tienda" )
Aadd( aHelpSpa, " del proveedor.                         " )

PutSx1("MTA145","01","Quanto ao PC       ?","Cuanto al PC ?      ","Purchase Order     ?","mv_ch1","N",1,0,1,"C","","","","","mv_par01",;
"Fornecedor+Loja","Proveedor+Tiend","Supplier+Unit","","Fornecedor","Proveedor","Supplier","","","","","","","","","","","","","")
PutSX1Help("P.MTA14501.",aHelpPor,aHelpEng,aHelpSpa)	 

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ProcH     ºAutor  ³Norbert Waage Juniorº Data ³  05/01/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna a posicao do campo no vetor do cabecalho da execautoº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³MATA145                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ProcH(cCampo)
Return aScan(aAutoCab,{|x|AllTrim(x[1])== AllTrim(cCampo) })

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³XML5F5PC  ³Autor  ³Alexandre Inacio Lemes ³Data  ³16/01/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Importacao dos Pedidos de Compras.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³(HF) U_MATA145                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function XML5F5PC()

Local aArea      := GetArea()
Local aAreaSA2   := SA2->(GetArea())
Local aAreaSC7   := SC7->(GetArea())
Local aButtons   := { {'PESQUISA',{||A103VisuPC(aRecSC7[oListBox:nAt])},OemToAnsi(STR0013),OemToAnsi(STR0008)} } //"Visualiza Pedido"
Local aF5Pc      := {}
Local aRecSC7    := {}
Local aTitCampos := {}
Local aConteudos := {}

Local bLine      := { || .T. }
Local _bSavKeyF3 := SetKey(VK_F3,Nil) //(HF) por conta e risco
Local bSavKeyF5  := SetKey(VK_F5,Nil)
Local bSavKeyF6  := SetKey(VK_F6,Nil)

Local nPosItDoc	 := aScan(aHeader2,{|x| Alltrim(x[2]) == "DB3_ITDOC" })
Local nPosCF	 := aScan(aHeader1,{|x| Alltrim(x[2]) == "DB2_CLIFOR"})
Local nPosLoja	 := aScan(aHeader1,{|x| Alltrim(x[2]) == "DB2_LOJA"})
Local nSldPed    := 0
Local nOpc       := 0
Local nF5Pc      := 0

Local cQuery     := ""
Local cAliasSC7  := "SC7"
Local cChave     := ""
Local cNomeFor   := ""
Local cLine      := ""
Local cFornece   := aCols1[Val(aCols[1][nPosItDoc])][nPosCF]
Local cLoja      := aCols1[Val(aCols[1][nPosItDoc])][nPosLoja]

Local lQuery     := .F.
Local lContinua  := .T.
Local lConsLoja  := .T.

Local oListBox
Local oDlg
Local oOk        := LoadBitMap(GetResources(), "LBOK")
Local oNo        := LoadBitMap(GetResources(), "LBNO")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ MV_PAR01 - Quanto ao PC ? 1-Fornecedor+Loja  2-Fornecedor    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte("MTA145",.F.)
lConsLoja := (MV_PAR01 == 1) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impede de executar a rotina quando a tecla F3 estiver ativa		    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("InConPad") == "L"
	lContinua := !InConPad
EndIf

If lContinua
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o aCols esta vazio, se o Tipo da Nota e'     ³
		//³ normal e se a rotina foi disparada pelo campo correto    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cTipo == "N"
			dbSelectArea("SA2")
			dbSetOrder(1)
			MsSeek(xFilial("SA2")+cFornece+cLoja)
			cNomeFor	:= SA2->A2_NOME

			#IFDEF TOP
				dbSelectArea("SC7")
				If TcSrvType() <> "AS/400"
					SC7->( dbSetOrder( 9 ) ) 				
					lQuery    := .T.
					cAliasSC7 := "QRYSC7"

					cQuery := "SELECT R_E_C_N_O_ RECSC7 FROM "
					cQuery += RetSqlName("SC7") + " SC7 "
					cQuery += "WHERE "
					cQuery += "C7_FILENT = '"+xFilEnt(xFilial("SC7"))+"' AND "
					cQuery += "C7_FORNECE = '"+cFornece+"' AND "		    		
					cQuery += "(C7_QUANT-C7_QUJE-C7_QTDACLA)>0 AND "					
					If ( lConsLoja )		    		
						cQuery += "C7_LOJA = '"+cLoja+"' AND "		    							
					Endif						
					cQuery += "SC7.D_E_L_E_T_ = ' '"
					cQuery += "ORDER BY " + SqlOrder( SC7->( IndexKey() ) ) 					

					cQuery := ChangeQuery(cQuery)

					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC7,.T.,.T.)
				Else
			#ENDIF
				dbSelectArea("SC7")
				dbSetOrder(9)
				If ( lConsLoja )
					cChave := cFornece+cLoja
				Else
					cChave := cFornece
				EndIf
				MsSeek(xFilEnt(xFilial("SC7"))+cChave,.T.)
				#IFDEF TOP
				Endif
				#ENDIF
			Do While If(lQuery, ;
					(cAliasSC7)->(!Eof()), ;
					(cAliasSC7)->(!Eof()) .And. xFilEnt(xFilial('SC7'))+cFornece==(cAliasSC7)->C7_FILENT+;
					(cAliasSC7)->C7_FORNECE .And. If(lConsLoja, cLoja == (cAliasSC7)->C7_LOJA, .T.))

				If lQuery
					('SC7')->(dbGoto((cAliasSC7)->RECSC7))
				EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica o Saldo do Pedido de Compra                     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nSldPed := ('SC7')->C7_QUANT-('SC7')->C7_QUJE-('SC7')->C7_QTDACLA
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica se nao h  residuos, se possui saldo em abto e   ³
					//³ se esta liberado por alcadas se houver controle.         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If ( Empty(('SC7')->C7_RESIDUO) .And. nSldPed > 0 .And.;
							If(SuperGetMV("MV_RESTNFE")=="S",('SC7')->C7_CONAPRO <> "B",.T.).And.;
							('SC7')->C7_TPOP <> "P" )
						nF5Pc := aScan(aF5Pc,{|x|x[2]==('SC7')->C7_LOJA .And. x[3]==('SC7')->C7_NUM})
						If ( nF5Pc == 0 )

							aConteudos := {.F.,('SC7')->C7_LOJA,('SC7')->C7_NUM,DTOC(('SC7')->C7_EMISSAO),If(('SC7')->C7_TIPO==2,'AE', 'PC') }

							aAdd(aF5Pc , aConteudos )
							aAdd(aRecSC7, ('SC7')->(Recno()))
						EndIf
					EndIf
				(cAliasSC7)->(dbSkip())
			EndDo
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Exibe os dados na Tela                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ( !Empty(aF5Pc) )

				aTitCampos := {" ",OemToAnsi(STR0014),OemToAnsi(STR0044),OemToAnsi(STR0022),OemToAnsi(STR0047)} //"Loja"###"Pedido"###"Emissao"###"Origem"

				cLine := "{If(aF5Pc[oListBox:nAt,1],oOk,oNo),aF5Pc[oListBox:nAT][2],aF5Pc[oListBox:nAT][3],aF5Pc[oListBox:nAT][4],aF5Pc[oListBox:nAT][5] } "
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Monta dinamicamente o bline do CodeBlock                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				bLine := &( "{ || " + cLine + " }" )
				DEFINE MSDIALOG oDlg FROM 050,040  TO 285,541 TITLE OemToAnsi(STR0008+" - <F5> ") Of oMainWnd PIXEL //"Selecionar Pedido de Compra"

				oListBox := TWBrowse():New( 027,004,243,086,,aTitCampos,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
				oListBox:SetArray(aF5Pc)
				oListBox:bLDblClick := { || aF5Pc[oListBox:nAt,1] := !aF5Pc[oListBox:nAt,1] }
				oListBox:bLine := bLine

				@ 015,004 SAY OemToAnsi(STR0046) Of oDlg PIXEL SIZE 047,009 //"Fornecedor"
				@ 014,035 MSGET cNomeFor PICTURE PesqPict('SA2','A2_NOME') When .F. Of oDlg PIXEL SIZE 120,009

				ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||(nOpc := 1,nF5Pc := oListBox:nAt,oDlg:End())},{||(nOpc := 0,nF5Pc := oListBox:nAt,oDlg:End())},,aButtons)

				Processa({|| U_M145PrPC(aF5Pc,nOpc,cFornece,cLoja,@nSldPed)})

			Else
				Help(" ",1,"A103F4")
			EndIf
		Else
			Help('   ',1,'A103TIPON')
		EndIf
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura a Integrida dos dados de Entrada                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lQuery
	dbSelectArea(cAliasSC7)
	dbCloseArea()
	dbSelectArea("SC7")
Endif

SetKey(VK_F5,bSavKeyF5)
SetKey(VK_F6,bSavKeyF6)
SetKey(VK_F3,_bSavKeyF3)  //(HF) 

RestArea(aAreaSA2)
RestArea(aAreaSC7)
RestArea(aArea)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M145ProcPC|Autor  ³Alexandre Inacio Lemes ³Data  ³16/01/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Processa o carregamento do pedido de compras para o Aviso  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array com os itens do pedido de compras            ³±±
±±³          ³ ExpN1 = Opcao valida                                       ³±±
±±³          ³ ExpC1 = Fornecedor                                         ³±±
±±³          ³ ExpC2 = loja fornecedor                                    ³±±
±±³          ³ ExpN2 = Saldo do pedido                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
USer Function M145PrPC(aF5Pc,nOpc,cFornece,cLoja,nSldPed)   //(HF) U_M145PrPC

Local cSeek      := ""
Local cFilialOri := ""
Local cItDoc     := ""
Local cItem		 := StrZero(1,Len(DB3->DB3_ITEM))
Local lZeraCols  := .T.
Local nPosItDoc	 := aScan(aHeader ,{|x| Alltrim(x[2]) == "DB3_ITDOC" })
Local nX         := 0

If ( nOpc == 1 )
	For nx	:= 1 to Len(aF5Pc)
		If aF5Pc[nx][1]
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona Fornecedor                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SA2")
			dbSetOrder(1)
			MsSeek(xFilial("SA2")+cFornece+cLoja)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona Pedido de Compra                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SC7")
			dbSetOrder(9)
			cSeek := ""
			cSeek += xFilEnt(xFilial("SC7"))+cFornece
			cSeek += aF5Pc[nx][2]+aF5Pc[nx][3]
			MsSeek(cSeek)
			If lZeraCols
                cItDoc      := aCols[1,nPosItDoc] 
				aCols		:= {}
				lZeraCols	:= .F.
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Muda ordem para trazer ordenado por item                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Eof()
				cSeek      :=xFilEnt(xFilial("SC7"))+aF5Pc[nx][3]
				cFilialOri :=C7_FILIAL
				dbSetOrder(14)
				dbSeek(cSeek)
			EndIf

			While ( !Eof() .And. SC7->C7_FILENT+SC7->C7_NUM==;
					cSeek )
				// Verifica se o fornecedor esta correto 
				If C7_FILIAL+C7_FORNECE+C7_LOJA == cFilialOri+cFornece+aF5Pc[nx][2]
						nSldPed := SC7->C7_QUANT-SC7->C7_QUJE-SC7->C7_QTDACLA
						If (nSldPed > 0 .And. Empty(SC7->C7_RESIDUO) )
							Pc2Acols(SC7->(RecNo()),,nSlDPed,cItem,cItDoc)
							cItem := SomaIt(cItem)
						EndIf
                EndIf
				
				dbSelectArea("SC7")
				dbSkip()
			EndDo
		EndIf
	Next
EndIf

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pc2Acols  ³Autor  ³Alexandre Inacio Lemes ³Data  ³16/01/2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Esta rotina atualiza o acols com base no item do pedido de   ³±±
±±³          ³compra                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 : Numero do registro do SC7                            ³±±
±±³          ³ExpN2 : Item da NF                                           ³±±
±±³          ³ExpN3 : Saldo do Pedido                                      ³±±
±±³          ³ExpC4 : Item a ser carregado no aCols ( DB3_ITEM )           ³±±
±±³          ³ExpC5 : Item da Getdados das NFEs (cabecalho) para vincular  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Sempre .T.                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Pc2Acols(nRecSC7,nItem,nSalPed,cItem,cItDoc)

Local aArea		:= GetArea()
Local aAreaSC7	:= SC7->(GetArea())
Local aAreaSF4	:= SF4->(GetArea())
Local aAreaSB1	:= SB1->(GetArea())
Local nX        := 0   
Local nCntFor   := 0 
Local nPreco    := 0 
Local lAllPC    := .T.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a existencia do item do acols                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nItem == Nil .Or. nItem > Len(aCols)
	aadd(aCols,Array(Len(aHeader)+1))
	For nX := 1 to Len(aHeader)
		If Trim(aHeader[nX][2]) == "DB3_ITEM"
			aCols[Len(aCols)][nX] 	:= IIF(cItem<>Nil,cItem,StrZero(1,Len(DB3->DB3_ITEM)))
		ElseIf Trim(aHeader[nX][2]) == "DB3_ITDOC"
			aCols[Len(aCols)][nX] 	:= cItDoc
		ElseIf Trim(aHeader[nX][2]) == "DB3_ALI_WT"
			aCols[Len(aCols)][nX] 	:= "DB3"
		ElseIf Trim(aHeader[nX][2]) == "DB3_REC_WT"
			aCols[Len(aCols)][nX] 	:= 0
		Else
			aCols[Len(aCols)][nX] := CriaVar(aHeader[nX][2], (aHeader[nX][10] <> "V") )
		EndIf
		aCols[Len(aCols)][Len(aHeader)+1] := .F.
	Next nX
	nItem := Len(aCols)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona registros                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SC7")
MsGoto(nRecSC7)
lAllPC := SC7->C7_QUANT==nSalPed 

dbSelectArea("SB1")
dbSetOrder(1)
MsSeek(xFilial("SB1")+SC7->C7_PRODUTO)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Converte o Pedido para a Moeda 1 (Real) usada na NFE         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPreco    := xMoeda(SC7->C7_PRECO,SC7->C7_MOEDA,1,dDataBase,TamSX3("DB3_VUNIT")[2],SC7->C7_TXMOEDA)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza o acols com base no pedido de compras               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nCntFor := 1 To Len(aHeader)
	Do Case
		Case Trim(aHeader[nCntFor][2]) == "DB3_ITDOC"
			If  Len(aCols) > 1
				aCols[Len(aCols)][nCntFor] 	:= aCols[Len(aCols)-1][nCntFor]
			EndIf
		Case Trim(aHeader[nCntFor,2]) == "DB3_CODPRO"
			aCols[nItem,nCntFor] := SC7->C7_PRODUTO
		Case Trim(aHeader[nCntFor,2]) == "DB3_TOTAL"
			aCols[nItem,nCntFor] := IIf(lAllPC,xMoeda(SC7->C7_TOTAL,SC7->C7_MOEDA,,dDataBase,,SC7->C7_TXMOEDA,),NoRound(nSalPed*nPreco,TamSX3('DB3_TOTAL')[2]))
		Case Trim(aHeader[nCntFor,2]) == "DB3_NUMPC"
			aCols[nItem,nCntFor] := SC7->C7_NUM
		Case Trim(aHeader[nCntFor,2]) == "DB3_QUANT"
			aCols[nItem,nCntFor] := nSalPed
		Case Trim(aHeader[nCntFor,2]) == "DB3_VUNIT"
			aCols[nItem,nCntFor] := nPreco
		Case Trim(aHeader[nCntFor,2]) == "DB3_ITEMPC"
			aCols[nItem,nCntFor] := SC7->C7_ITEM
		Case Trim(aHeader[nCntFor,2]) == "DB3_DESC"
			aCols[nItem,nCntFor] := SC7->C7_DESC
		Case Trim(aHeader[nCntFor,2]) == "DB3_VALDES"
			aCols[nItem,nCntFor] := ((SC7->C7_VLDESC/SC7->C7_QUANT)* nSalPed)
		Case Trim(aHeader[nCntFor][2]) == "DB3_NRAVRC"
			aCols[nItem,nCntFor] := M->DB1_NRAVRC
		Case Trim(aHeader[nCntFor][2]) == "DB3_ALI_WT"
			aCols[Len(aCols)][nCntFor] 	:= "DB3"
		Case Trim(aHeader[nCntFor][2]) == "DB3_REC_WT"
			aCols[Len(aCols)][nCntFor] 	:= 0
		OtherWise
			If Empty(aCols[nItem,nCntFor])
				aCols[nItem,nCntFor] := CriaVar(aHeader[nCntFor][2])
			EndIf

	EndCase
Next nCntFor

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Efetua a chamada do ponto de entrada                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "MT145IPC" )
	ExecBlock( "MT145IPC", .F., .F. )
EndIf

RestArea(aAreaSB1)
RestArea(aAreaSF4)
RestArea(aAreaSC7)
RestArea(aArea)
Return .T.   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M145ChkInd|Autor  ³ Nereu Humberto Junior ³Data  ³18/04/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se a chave de indice da tabela DB2 esta correta.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function M145ChkInd()

Local aArea     := GetArea()
Local aAreaSIX  := SIX->(GetArea())
Local lRet      := .T.
Local aHlpP	    :=	{}
Local aHlpE	    :=	{}
Local aHlpS	    :=	{}

aAdd (aHlpP, Subs(STR0050,1,34))	
aAdd (aHlpP, Subs(STR0050,35,40))	
aAdd (aHlpP, Subs(STR0050,76,40))	
aAdd (aHlpP, Subs(STR0050,117,34))	
aAdd (aHlpP, Subs(STR0050,151,40))	

aAdd (aHlpE, Subs(STR0050,1,34))	
aAdd (aHlpE, Subs(STR0050,35,40))	
aAdd (aHlpE, Subs(STR0050,76,40))	
aAdd (aHlpE, Subs(STR0050,117,34))	
aAdd (aHlpE, Subs(STR0050,151,40))	

aAdd (aHlpS, Subs(STR0050,1,34))	
aAdd (aHlpS, Subs(STR0050,35,40))	
aAdd (aHlpS, Subs(STR0050,76,40))	
aAdd (aHlpS, Subs(STR0050,117,34))	
aAdd (aHlpS, Subs(STR0050,151,40))	

PutHelp("PMT145IND", aHlpP, aHlpE, aHlpS, .F.) //"Para utilizar a rotina de Aviso de Recebimento de Carga, a chave de indice ordem 1 da tabela DB2, deve ser alterada para DB2_FILIAL+DB2_DOC+DB2_SERIE+DB2_CLIFOR+DB2_LOJA"

dbSelectArea("SIX")
If dbSeek("DB21")
   If SIX->ORDEM == "1" .And. Alltrim(SIX->CHAVE) <> "DB2_FILIAL+DB2_DOC+DB2_SERIE+DB2_CLIFOR+DB2_LOJA"
      lRet := .F.
	  HELP(" ",1,"MT145IND")
   EndIf                                                           
Endif

RestArea(aAreaSIX)
RestArea(aArea)

Return lRet 		

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Ma145Form³ Autor ³ Kleber Dias Gomes     ³ Data ³10/07/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao do Formulario Proprio.                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Dicionario de Dados - Campo:DB2_FORMUL                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
//Function Ma145Form()
//
//Local aArea		  := GetArea()
//Local lRetorno    := .T.
//Local lRet        := .T.
//Local nPDoc       := aScan(aHeader,{|x| AllTrim(x[2]) == 'DB2_DOC'})
//Local nPSerie     := aScan(aHeader,{|x| AllTrim(x[2]) == 'DB2_SERIE'})
//Local nPItem      := aScan(aHeader,{|x| AllTrim(x[2]) == 'DB2_ITEM'}) 
//
//If ReadVar() == "M->DB2_FORMUL" .And. &(ReadVar()) == "1"      
//
//	If ExistBlock("MT145NFE")
//		lRet := ExecBlock("MT145NFE",.F.,.F.)
//		If ValType(lRet) <> "L"
//			lRet := .F.			
//		EndIf
//	EndIf
//	
	// Retorno .T., atribui numeração do documento através da SX5
//	IF lRET
//		Private cNumero:= ""
//		Private cSerie := ""
//		lRetorno:= Sx5NumNota(@cSerie,"1")
//		aCols[n][nPDoc]   := cNumero
//		aCols[n][nPSerie] := cSerie
//	Else
	    // Retonto .F., atribui numeracao do documento atraves da SXF
//		aCols[n][nPDoc]   := M->DB1_NRAVRC
//		aCols[n][nPSerie] := aCols[n][nPItem]
//	EndIf
//Else
//   aCols[n][nPDoc]   := CriaVar(aHeader[nPDoc,2])
//   aCols[n][nPSerie] := CriaVar(aHeader[nPSerie,2])
//EndIf
//
//RestArea(aArea)
//Return lRetorno 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³AjustaSX3 ³ Autor ³Alexandre Inacio Lemes ³ Data ³24/08/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Ajusta o X3_VALID do campo D1_PEDIDO 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³MATA103                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function AjustaSX3()
Local aAreaAnt := GetArea()
Local aAreaSX3 := SX3->(GetArea())

dbSelectArea("SX3")
dbsetOrder(2)
If dbSeek("D1_PEDIDO")
	If SX3->X3_VALID <> 'vazio().or. (existcpo("SC7").And.A103PC())  '
		Reclock("SX3",.F.)
        SX3->X3_VALID := 'vazio().or. (existcpo("SC7").And.A103PC())  '
		MsUnlock()
	Endif	
Endif

If dbSeek("DB1_NRAVRC")
	Reclock("SX3",.F.)
	SX3->X3_VALID := 'NaoVazio() .And. ExistChav("DB1",M->DB1_NRAVRC)'
	MsUnlock()
Endif

RestArea(aAreaSX3)
RestArea(aAreaAnt)
Return  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Fabio Alves Silva     ³ Data ³08/11/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function MenuDef()     
PRIVATE aRotina	:= {	{ OemToAnsi(STR0002),"AxPesqui"  , 0, 1, 0, .F.},; //"Pesquisar"
						{ OemToAnsi(STR0003),"U_M145AltE", 0, 2, 0, NIL},;       //"Visualiza"
						{ OemToAnsi(STR0004),"U_M145Incl", 0, 3, 0, nil},;       //"Incluir"
						{ OemToAnsi(STR0005),"U_M145AltE", 0, 4, 0, nil},;       //"Alterar"
						{ OemToAnsi(STR0006),"U_M145AltE", 0, 5, 0, nil},;       //"Excluir"
						{ OemToAnsi(STR0007),"U_M145AltE", 0, 6, 0, nil},;      //"Homologar"
						{ OemToAnsi(STR0035),'M145Legend', 0, 3, 0, .F.}}    //"Legenda"	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada utilizado para inserir novas opcoes no array aRotina  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("MTA145MNU")
	ExecBlock("MTA145MNU",.F.,.F.)
EndIf
Return(aRotina)           

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A145FldRfr³ Autor ³Marcelo Custodio       ³ Data ³02/07/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Atualiza posicao do folder para manter integridade dos dados³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function A145FldR(oFolder)   //(HF) U_A145FldR

If oFolder:nOption == 2
	oFolder:SetOption(1)
EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³A145SemDoc ³Autor ³Emerson Rony Oliveira ³ Data ³ 07/07/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Verifica se existe ao menos um documento no aviso           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1: aCols dos documentos (notas fiscais)                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A145SemDoc(aColsDocs)
Local nUsado := Len(aHeader1) // Pasta "Notas Fiscais"
Local lRet   := .T.
Local nX     := 0

For nX := 1 to Len(aColsDocs)
	If !aColsDocs[nX][nUsado+1]
		lRet := .F.
		Exit
	EndIf
Next nX

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³A145SemItm ³Autor ³Emerson Rony Oliveira ³ Data ³ 07/07/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Verifica se existe nota sem item                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1: aCols dos itens das notas                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A145SemItm(aColsItens)
Local nUsado := Len(aHeader2) // Pasta "Itens"
Local lRet   := .T.
Local nX     := 0

For nX := 1 to Len(aColsItens)
	If !aColsItens[nX][nUsado+1]
		lRet := .F.
		Exit
	EndIf
Next nX

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³AjustaHelp ³Autor ³Emerson Rony Oliveira ³ Data ³ 05/08/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Ajusta Help's da Rotina                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function AjustaHelp()
//-- Problemas
PutHelp( 'PMATA14501', {'É necessário que exista ao menos uma    ',;
                        'nota fiscal no aviso de recebimento de  ',;
                        'carga.                                  '},;
                       {' '},;
                       {'Es necesario que haya, al menos, una    ',;
                        'factura en el aviso de recibimiento de  ',;
                        'carga'}, .F. )
                        
PutHelp( 'PMATA14502', {'É necessário que exista ao menos um item',;
                        'em cada nota fiscal relacionada.        '},;
                       {' '},;
                       {'Es necesario que haya, minimo, un item  ',;
                        'en cada factura relacionada.'}, .F. )
                        
PutHelp("PMATA14503", {"Valor Desconto incorreto!","",""},;
					  {"Descuento valor incorrecto!","",""},;
					  {"Discount incorrect value!","",""},.F.)

//-- Solucoes 
PutHelp( 'SMATA14501', {'Inclua ao menos um documento no aviso de',;
                        'recebimento de carga.                   '},;
                       {' '},;
					   {'Incluya, al menos, un documento en el   ',;
					    'aviso de recibimiento de carga.'}, .F. )
					    
PutHelp( 'SMATA14502', {'Inclua ao menos um item ou exclua a nota',;
                        'fiscal.                                 '},;
                       {' '},;
					   {'Incluya, al menos, un item o excluya la ',;
					    'factura.'}, .F. )


PutHelp("SMATA14503", {"Verifique se o valor do desconto","é inferior ao valor total e se ","não é negativo !"},;
					  {"Compruebe que el valor del descuento","es menor que el valor total y que","no sea negativo!"},;
					  {"Verify that the value of the discount","is less than the total value and that","is not negative!"},.F.)

Return Nil


Static Function __Dummy(lRecursa) //warning W0010 Static Function <?> never called
    lRecursa := .F.
    IF (lRecursa)
        __Dummy(.F.)
        U_M145LOK1()
        U_M145INCL()
        U_M145PRPC()
        U_M145TDOK()
        U_M145ALTE()
        U_A145FLDR()
        U_M145COK()
        U_M145HOMO()
        U_XMATA145()
        U_M145TOK2()
        U_XML5F5PC()
        U_XML5F6PC()
        U_M145LOK2()
        U_M145GENH()
        U_M145TOK1()
        U_M145SHNH()
	EndIF
Return(lRecursa)
