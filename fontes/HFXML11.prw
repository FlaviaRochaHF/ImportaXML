#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HFXML11   º Autor ³ Eneo               º Data ³  10/12/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Codigo gerado pelo AP6 IDE.                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function HFXML11()
Local lValidEmp := .T.
Private cCadastro := "Cadastro de Usuários com Amarração Secundária Para Geração da Pré-Nota"

Private aRotina := MenuDef()

Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock

Private xZBA  	:= GetNewPar("XM_TABAMA2","ZBA")
Private xZBA_ 	:= iif(Substr(xZBA,1,1)=="S", Substr(xZBA,2,2), Substr(xZBA,1,3)) + "_"

    dVencLic := Stod(Space(8))
 	//lUsoOk := U_HFXML00X("HF000001","101",SM0->M0_CGC,@dVencLic)
	lUsoOk	:= U_HFXMLLIC(.F.)

//lUsoOk := U_HFXML00X("HF000001","101",SM0->M0_CGC)

If !lUsoOk
	Return(Nil)
EndIf


dbSelectArea("SX3")
SX3->(dbSetOrder(2))
If dbSeek(xZBA_+"CODUSR")  //NFCE_01
	If AllTrim(SX3->X3_VALID) <> "U_HFX11VCD()" .OR. AllTrim(SX3->X3_WHEN) <> "!ALTERA"
		RecLock("SX3",.F.)
		SX3->X3_VALID := "U_HFX11VCD()"
		SX3->X3_WHEN  := "!ALTERA"
		MsUnLock()
	EndIF
EndIf
If dbSeek(xZBA_+"AMARRA")  //NFCE_01
	If AllTrim(SX3->X3_VALID) <> 'Pertence( "012345" )'  .or.;
	   AllTrim(SX3->X3_CBOX) <> "0=Sempre Perguntar;1=Padrão(SA5/SA7);2=Customizada("+AllTrim(GetNewPar("XM_TABAMAR","ZB5"))+");3=Sem Amarração;4=Por Pedido;5=Virtual"
		RecLock("SX3",.F.)
		SX3->X3_VALID   := 'Pertence( "012345" )'
		SX3->X3_CBOX    := "0=Sempre Perguntar;1=Padrão(SA5/SA7);2=Customizada("+AllTrim(GetNewPar("XM_TABAMAR","ZB5"))+");3=Sem Amarração;4=Por Pedido;5=Virtual"
		SX3->X3_CBOXSPA := "0=Sempre Perguntar;1=Padrão(SA5/SA7);2=Customizada("+AllTrim(GetNewPar("XM_TABAMAR","ZB5"))+");3=Sem Amarração;4=Por Pedido;5=Virtual"
		SX3->X3_CBOXENG := "0=Sempre Perguntar;1=Padrão(SA5/SA7);2=Customizada("+AllTrim(GetNewPar("XM_TABAMAR","ZB5"))+");3=Sem Amarração;4=Por Pedido;5=Virtual"
		MsUnLock()
	EndIF
EndIf

DbSelectArea(xZBA)
DbSetOrder(1)


DbSelectArea(xZBA)
MBrowse( 6,1,22,75,xZBA)

Return


Static Function MenuDef()
Local aMenu := { {"Pesquisar","AxPesqui",0,1} ,;
{"Visualizar","AxVisual",0,2} ,;
{"Incluir","AxInclui",0,3} ,;
{"Alterar","AxAltera",0,4} ,;
{"Excluir","AxDeleta",0,5} }
Return( aMenu )



User Function HFX11VCD()
Local lRet := .T. 
Local aArea := GetArea()
Local cCod  := &("M->"+xZBA_+"CODUSR" )
Local bUsua := "{|| M->"+xZBA_+"USUARI := aUserData[1][2] }"
Local bNome := "{|| M->"+xZBA_+"NOME   := aUserData[1][4] }"

IF INCLUI
	if ( xZBA )->( DbSeek( xFilial(xZBA) + cCod ) )
		U_MYAVISO("Aviso","Usuário Ja Cadastrado.",{"Ok"},1)
		lRet := .F.
	EndIf
Endif
If lRet
	PswOrder(1)
	If PswSeek( cCod, .T. )
	 	aUserData := PswRet()
	 	Eval( &bUsua )
	 	Eval( &bNome )
	EndIf
EndIf

RestArea( aArea )
Return( lRet )



Static Function __Dummy(lRecursa) //warning W0010 Static Function <?> never called
    lRecursa := .F.
    IF (lRecursa)
        __Dummy(.F.)
        U_HFXML11()
        U_HFX11VCD()
	EndIF
Return(lRecursa)
