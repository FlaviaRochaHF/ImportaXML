#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HFXML13   º Autor ³ AP6 IDE            º Data ³  28/09/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Codigo gerado pelo AP6 IDE.                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function HFXML13()
Local lValidEmp := .T.
Private cCadastro := "Cadastro de Classificação Automática Nota Fiscal"

Private aRotina := MenuDef() 

//Private cDelFunc := "U_EXCZZF()" // Validacao para a exclusao. Pode-se utilizar ExecBlock
Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock

Private xZBC  	:= GetNewPar("XM_TABCAC","ZBC")
Private xZBC_ 	:= iif(Substr(xZBC,1,1)=="S", Substr(xZBC,2,2), Substr(xZBC,1,3)) + "_"

    dVencLic := Stod(Space(8))
 	//lUsoOk := U_HFXML00X("HF000001","101",SM0->M0_CGC,@dVencLic)  
	lUsoOk	:= U_HFXMLLIC(.F.)

//lUsoOk := U_HFXML00X("HF000001","101",SM0->M0_CGC)

If !lUsoOk
	Return(Nil)
EndIf


DbSelectArea(xZBC)
DbSetOrder(1)


DbSelectArea(xZBC)
MBrowse( 6,1,22,75,xZBC)

Return


Static Function MenuDef()
Local aMenu := { {"Pesquisar","AxPesqui",0,1} ,;
{"Visualizar","AxVisual",0,2} ,;
{"Incluir","U_HF13MNU(3)",0,3} ,;
{"Alterar","U_HF13MNU(4)",0,4} ,;
{"Excluir","AxDeleta",0,5} }
//{"Incluir","AxInclui",0,3} ,;
//{"Alterar","AxAltera",0,4} ,;

Return( aMenu )


User Function HF13MNU( nOpc )
Private cTudoOk := "U_HF13TOK()"
do Case
	Case nOpc == 3
		AxInclui( xZBC, Recno(xZBC), 3,,,,cTudoOk,,,)
	Case nOpc == 4
		AxAltera( xZBC, Recno(xZBC), 4,,,,,cTudoOk,,,)
EndCase

Return( NIL )


User Function HF13TOK()
Local lRet := .T.
Local aArea := GetArea()
Local nReg    := (xZBC)->( Recno() )
Local cCodFor := M->&(xZBC_+"CODFOR")
Local cLojFor := M->&(xZBC_+"LOJFOR")
Local cProFor := M->&(xZBC_+"PROD")
Local cTes    := M->&(xZBC_+"TES")
Local cCc     := M->&(xZBC_+"CC")

If INCLUI
	DbSelectArea( xZBC )
	DbSetORder( 1 )
	If ( xZBC )->( dbSeek( xFilial( xZBC ) + cCodFor + cLojFor  ) )
		lRet := .F.
		U_myAviso( "Alerta","Fornecedor já posssui amarração cadastrada!",{"Ok"},3 )
	Endif
ElseIf ALTERA
	DbSelectArea( xZBC )
	DbSetORder( 1 )
	If ( xZBC )->( dbSeek( xFilial( xZBC ) + cCodFor + cLojFor  ) )
		if ( xZBC )->( Recno() ) <> nReg
			lRet := .F.
			U_myAviso( "Alerta","Fornecedor já posssui outra amarração cadastrada!",{"Ok"},3 )
		endif
	Endif
Endif
if lRet
	lRet := VerSA2( cCodFor, cLojFor )
Endif
if lRet
	lRet := VerSB1( cProFor )
endif
if lRet
	lRet := VerSF4( cTes ) 
endif
if lRet
	lRet := VerCC( cCc )
endif

RestArea( aArea )
Return( lRet )


Static Function VerSA2( cCodFor, cLojFor )
Local lRet := .T.
DbSelectArea( "SA2" )
DbSetORder( 1 )
If .Not. SA2->( dbSeek( xFilial( "SA2" ) + cCodFor + cLojFor ) )
	U_myAviso( "SA2","Fornecedor não cadastrado!",{"Ok"},3 )
	lRet := .F.
Else
	if SA2->A2_MSBLQL = "1"
		U_myAviso( "SA2","Fornecedor Bloqueado!",{"Ok"},3 )
		lRet := .F.
	Endif
Endif
DbSelectArea( xZBC )
Return( lRet )


Static Function VerSB1( cProFor )
Local lRet := .T.
DbSelectArea( "SB1" )
DbSetORder( 1 )
If .Not. SB1->( dbSeek( xFilial( "SB1" ) + cProFor ) )
	U_myAviso( "SB1","Produto não cadastrado!",{"Ok"},3 )
	lRet := .F.
Else
	if SB1->B1_MSBLQL = "1"
		U_myAviso( "SB1","Produto Bloqueado!",{"Ok"},3 )
		lRet := .F.
	Endif
Endif
DbSelectArea( xZBC )
Return( lRet )


Static Function VerSF4( cTes )
Local lRet := .T.
DbSelectArea( "SF4" )
DbSetORder( 1 )
If .Not. SF4->( dbSeek( xFilial( "SF4" ) + cTes ) )
	U_myAviso( "SF4","Código da TES não cadastrada!",{"Ok"},3 )
	lRet := .F.
Else
	if SF4->F4_MSBLQL = "1"
		U_myAviso( "SF4","TES Bloqueada!",{"Ok"},3 )
		lRet := .F.
	Else
		If SF4->F4_TIPO = "S"
			if ( U_myAviso( "SF4","TES de Saída Continua!",{"NÃO","SIM"},3 ) <> 2 )
				lRet := .F.
			Endif
		Endif
	Endif
Endif
DbSelectArea( xZBC )
Return( lRet )


Static Function VerCC( cCc )
Local lRet := .T.
DbSelectArea( "CTT" )
DbSetORder( 1 )
If .Not. CTT->( dbSeek( xFilial( "CTT" ) + cCc ) )
	U_myAviso( "CTT","Código do Centro de Custo não cadastrado!",{"Ok"},3 )
	lRet := .F.
Else
	if CTT->CTT_BLOQ = "1"
		U_myAviso( "CTT","Centro de Custo Bloqueado!",{"Ok"},3 )
		lRet := .F.
	Else
		If CTT->CTT_CLASSE = "1"
			U_myAviso( "CTT","Centro de Custo Sintético. Utilize um Centro de Custo analítico!",{"OK"},3 )
			lRet := .F.
		Endif
	Endif
Endif
DbSelectArea( xZBC )
Return( lRet )


Static Function __Dummy(lRecursa) //warning W0010 Static Function <?> never called
    lRecursa := .F.
    IF (lRecursa)
        __Dummy(.F.)
        U_HFXML13()
	EndIF
Return(lRecursa)
