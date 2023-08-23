#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HFXML02M  º Autor ³ Roberto Souza      º Data ³  13/08/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ XML dos Fornecedores                                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Importa XML                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function HFXML02M()
Local aArea  := GetArea()
Local lRet   := .T.
Local aRadio := {}
Local nRadio := 1

/*
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01" MODULO "FAT" TABLES "SF1","SF2","SD1","SD2","SF4","SB5","SF3","SB1"
	RpcSetType(3)
	DbSelectArea("ZBZ")
	DbGoTo(10)
*/
	
aAdd( aRadio, "Tipo de Documento" )
aAdd( aRadio, "Ocorrencia XML" )
//aAdd( aRadio, "Desabilitado" )
                         

 	DEFINE MSDIALOG oDlgUpd TITLE 'Alteração XML' FROM 00,00 TO 140,250 PIXEL
    
	@ 006,006 TO 060,080 LABEL "" OF oDlgUpd PIXEL
	@ 010,010 RADIO oRadio VAR nRadio ITEMS aRadio[1],aRadio[2] SIZE 65,8 PIXEL OF oDlgUpd 
	@ 006,085 BUTTON "Ok" SIZE 35,15 PIXEL OF oDlgUpd Action (oDlgUpd:End(),SelFunc(nRadio))
	@ 026,085 BUTTON "Cancelar" SIZE 35,15 PIXEL OF oDlgUpd Action oDlgUpd:End()

	ACTIVATE MSDIALOG oDlgUpd CENTERED


Return

Static Function SelFunc(nTipo)

	Local lRet := .T.

	Do Case 
		Case nTipo == 1
			lRet := EdtXML(nTipo)
		Case nTipo == 2
			U_HFXML17(nTipo)
	EndCase

Return lRet

Static Function EdtXML(nTipo)
Local lRet       := .F.   
Local oDlg
Local aObjetos   := Array(11)
Local aCombo1x    := {	"1=Preco",;	
						"2=Quantidade",;	
						"3=Frete"}
Local aCombo1    := {	"N=Normal",;	
						"D=Devolucao",;	
						"B=Beneficiamento",;	
						"I=Compl.  ICMS",;	
						"P=Compl.  IPI",;	
						"C=Compl. Preco/Frete"}
Local aCombo1A    := {	"Normal",;	
						"Devolucao",;	
						"Beneficiamento",;	
						"Compl.  ICMS",;	
						"Compl.  IPI",;	
						"Compl. Preco/Frete"}						
						
Local aCombo2       := {"Nao","Sim"}
Local lRodape       := .T. 
Local nTamProd      := 15// TAMSX3("B1_COD")[1] 
Local oGet2
Private nOpca       := 0 
Private nOpcb       := 0
Private lPreNota 	:= .F.
Private lPedido 	:= .F.
Private lPCNFE     	:= .F.
Private cUfOrig		:= Space(2)//Posicione("SA2",1,xFilial("SA2")+aHead[06][02]+aHead[07][02],"A2_EST")
Private cTipo		:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC")))
Private cTpCompl    := " ", aCompFutur := {}  //ERRMATA103
Private cFormul		:= "N"
Private cNFiscal	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA")))
Private cSerie		:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE")))
Private dDEmissao	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"DTNFE")))
Private cA100For	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR")))
Private cLoja		:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR")))
Private cIndRur     := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"INDRUR")))
Private cEspecie	:= U_SpecXml( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO"))) )
Private cNome       := Space(30) 
Private cCnpjFor   	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ")))
Private cCnpj    	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ")))
Private cCondicao	:= ""
Private cForAntNFE	:= cA100For+cLoja
Private n			:= 1
Private aCols		:= {}
Private aHeader		:= {} 
Private lVisual     := .T. 
Private aButtons    := {}
Private aPosObj     := {}
Private aHead1      := {}      
Private nI

Private nUsado      := 0
Private lRefresh    := .T.  
Private aFields     := {}   
Private aComp       := {}
Private aGets       := {} 
Private nVar        := {}
Private cTextGet    := "" 
Private aColsSDE    := {}
Private lWhen       := .T.
Private lEditCab    := .F.  
Private cSayForn    := IIf(cTipo$"DB",RetTitle("F2_CLIENTE"),RetTitle("F1_FORNECE"))
Private nCabMod     := 2 
Private aButtons    := {}
Private aItens      := {}  
Private aHead       := {}
                       

Private aRotina := {{"Pesquisar" , "AxPesqui", 0, 1},;
                    {"Visualizar", "AxVisual", 0, 2},;
                    {"Incluir"   , "AxInclui", 0, 3},;
                    {"Alterar"   , "AxAltera", 0, 4},;
                    {"Excluir"   , "AxDeleta", 0, 5}}

aHeader := aClone(aHead1)  
  
If cTipo $ "D|B"
	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek(xFilial("SA1")+cA100For+cLoja) 
Else
	DbSelectArea("SA2")
	DbSetOrder(1)
	DbSeek(xFilial("SA2")+cA100For+cLoja) 
EndIf		   
Private aPos       := {15, 1, 70, 315}	 
		   
DEFINE MSDIALOG oDlg TITLE OemToAnsi("Alteração - XML") FROM 0,0 TO 180,720  PIXEL STYLE DS_MODALFRAME STATUS

	@ 15,05 TO 70,355 LABEL "" OF oDlg PIXEL
	//Linha 1
	@ 20,015 SAY RetTitle("F1_TIPO") SIZE 35,09 OF oDlg PIXEL 
	@ 27,015 MSCOMBOBOX aObjetos[1] VAR cTipo ITEMS aCombo1 SIZE 50,90 OF oDlg PIXEL WHEN lWhen ON CHANGE SetF3But(cTipo,oForSa1,oForSa2,.T.,oForNome)

//	@ 20,035 SAY RetTitle("F1_TPCOMPL") SIZE 35,09 OF oDlg PIXEL 
//	@ 27,035 MSCOMBOBOX aObjetos[1] VAR cTpCompl ITEMS aCombo1x SIZE 50,90 OF oDlg PIXEL WHEN .F.
	
	@ 20,075 SAY RetTitle("F1_FORMUL") SIZE 52,09 Of oDlg PIXEL 
	@ 27,075 MSCOMBOBOX aObjetos[2] VAR cFormul ITEMS aCombo2 SIZE 25,50 ;
		OF oDlg PIXEL   WHEN .F.                          
		
	@ 20,135 SAY RetTitle("F1_SERIE") SIZE 23,09 Of oDlg PIXEL
	@ 27,135 MSGET aObjetos[4] VAR cSerie  PICTURE PesqPict("SF1","F1_SERIE") ;
	    SIZE 18,09 OF oDlg PIXEL WHEN .F.
	
	@ 20,195 SAY RetTitle("F1_DOC") SIZE 45,09 Of oDlg PIXEL
	@ 27,195 MSGET aObjetos[3] VAR cNFiscal PICTURE PesqPict("SF1","F1_DOC") ;
		SIZE 34,09 OF oDlg PIXEL WHEN .F.
	
	@ 20,255 SAY RetTitle("F1_EMISSAO") OF oDlg PIXEL SIZE 35,09
	@ 27,255 MSGET aObjetos[5] VAR dDEmissao PICTURE PesqPict("SF1","F1_EMISSAO") OF oDlg PIXEL SIZE 45 ,9 HASBUTTON WHEN .F.

	@ 20,315 SAY RetTitle("F1_ESPECIE") Of oDlg PIXEL SIZE 63,09
	@ 27,315 MSGET aObjetos[9] VAR cEspecie PICTURE PesqPict("SF1","F1_ESPECIE") ;
			OF oDlg PIXEL SIZE 30,09 WHEN .F.


	
	@ 45,015 SAY aObjetos[6] VAR cSayForn Of oDlg PIXEL SIZE 43,09
	@ 52,015 MSGET oForSa1 VAR cA100For PICTURE PesqPict("SF2","F2_CLIENTE") F3 "SA1PRN";
		OF oDlg PIXEL SIZE 45,09 HASBUTTON VALID U_FillCab("SA1")
	
	@ 52,015 MSGET oForSa2 VAR cA100For PICTURE PesqPict("SF1","F1_FORNECE") F3 "SA2PRN";
		OF oDlg PIXEL SIZE 45,09 HASBUTTON VALID U_FillCab("SA2")
		
	
	@ 45,075 SAY aObjetos[6] VAR "Loja" Of oDlg PIXEL SIZE 43,09	
	@ 52,075 MSGET aObjetos[8] VAR cLoja PICTURE PesqPict("SF1","F1_LOJA") ;
		OF oDlg PIXEL SIZE 15,09 HASBUTTON WHEN lWhen
	
	@ 45,135 SAY OemToAnsi("Nome") Of oDlg PIXEL SIZE 63 ,9 // 
	@ 52,135 MSGET oForNome VAR cNome PICTURE "@!" OF oDlg PIXEL SIZE 120,9 HASBUTTON READONLY

	@ 45,255 SAY OemToAnsi("CNPJ") Of oDlg PIXEL SIZE 63 ,9 // 
	@ 52,255 MSGET oCnpj VAR cCnpjFor PICTURE "@R 99.999.999/9999-99" OF oDlg PIXEL SIZE 60,9 HASBUTTON READONLY

	
	@ 45,315 SAY OemToAnsi("UF.Origem") Of oDlg PIXEL SIZE 63 ,9 // 
	@ 52,315 MSGET cUfOrig PICTURE "@!" F3 "12"  OF oDlg PIXEL SIZE 20,9 HASBUTTON READONLY
 
	SetF3But(cTipo,oForSa1,oForSa2,.F.,oForNome)	
 
	@ 073,280 BUTTON "Ok"       SIZE 35,15 PIXEL OF oDlg Action (Iif(EditOK(nTipo,cA100For,cLoja,cCnpjFor), (EdtXMLOk(nTipo),oDlg:End()),.F.))
	@ 073,320 BUTTON "Cancelar" SIZE 35,15 PIXEL OF oDlg Action (oDlg:End())
							
ACTIVATE MSDIALOG oDlg CENTERED // ON INIT EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()})



Return(lRet)


Static Function SetF3But(cTipo,oForSa1,oForSa2,lEmpty,oForNome)
Default lEmpty := .T.      

If cTipo $ "D|B"
	cSayForn    := RetTitle("F2_CLIENTE")
	cNome       := SA1->A1_NOME
	cUfOrig     := SA1->A1_EST
	oForSa2:Hide() 
	oForSa1:Show()

Else
	cSayForn    := RetTitle("F1_FORNECE")
	cNome       := SA2->A2_NOME			
	cUfOrig     := SA2->A2_EST
	oForSa1:Hide() 
	oForSa2:Show()		    
EndIf

If lEmpty
	If cTipo $ "D|B"
		cA100For    := Space( TAMSX3("A1_COD")[1] )
    	cLoja       := Space( TAMSX3("A1_LOJA")[1] )
    Else
		cA100For    := Space( TAMSX3("A2_COD")[1] )
    	cLoja       := Space( TAMSX3("A2_LOJA")[1] )
    EndIF
	cNome       := Space(30)
	cUfOrig     := Space(2)
EndIf
Return         
 



Static Function EditOK(nTipo,cA100For,cLoja,cCnpjFor)
Local lRet := .T.
Local cMsgAviso := "" 
Local cCanEdit  := "B"
Local cFilial   := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL")))
Local lSharedA1 := U_IsShared("SA1")
Local lSharedA2 := U_IsShared("SA2")


If nTipo == 1 //Tipo-Cliente - Fornecedor
	If (xZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF"))) $ cCanEdit
		If cTipo $ "D|B"
			if lSharedA1
				cFilial := xFilial("SA1")
			endif
			DbSelectArea("SA1")
			DbSetOrder(1)
			If DbSeek(cFilial+cA100For+cLoja)  //ZBZ->ZBZ_FILIAL ou xFilial("SA1")
				If cCnpjFor <> SA1->A1_CGC
			   		cMsgAviso += "CNPJ do cliente selecionado não corresponde ao emissor do Xml."+CRLF	
				EndIf 
			Else
				cMsgAviso += "Selecione um fornecedor/cliente válido."+CRLF	
			EndIf
		Else
			if lSharedA2
				cFilial := xFilial("SA2")
			endif
			DbSelectArea("SA2")
			DbSetOrder(1)
			If DbSeek(cFilial+cA100For+cLoja)  //ZBZ->ZBZ_FILIAL ou xFilial("SA2")
				If cCnpjFor <> SA2->A2_CGC
			   		cMsgAviso += "CNPJ do fornecedor selecionado não corresponde ao emissor do Xml."+CRLF
			 	Else
			 		cIndRur := SA2->A2_INDRUR
				EndIf 
			Else
				cMsgAviso += "Selecione um fornecedor/cliente válido."+CRLF	
			EndIf
		EndIf		   
		
		
		If Empty(cA100For)
			lRet := .F.      
			cMsgAviso += "Selecione um fornecedor/cliente válido."+CRLF
		EndIf
		If Empty(cLoja)
			lRet := .F.
			cMsgAviso += "Selecione uma loja válida."+CRLF
		EndIf 
	Else 
		cMsgAviso += "Registros com status "+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF")))+" não podem sofrer este tipo de alteração."+CRLF 
	EndIf
 
EndIf		 
If !Empty(cMsgAviso)
	U_MyAviso("Aviso",cMsgAviso,{"OK"},3)
EndIf               
Return(lRet)
 





Static Function EdtXMLOk(nTipo)  
Local lRet := .T.
Local cMsgAviso := ""

If AllTrim(cTipo) $ "D|B"
	cNomEmit :=  Posicione("SA1",1,xFilial("SA1")+cA100For+cLoja,"A1_NOME")
	cIndRur  := " "
Else
	cNomEmit := Posicione("SA2",1,xFilial("SA2")+cA100For+cLoja,"A2_NOME")
	cIndRur  := Posicione("SA2",1,xFilial("SA2")+cA100For+cLoja,"A2_INDRUR")
EndIf

	RecLock(xZBZ,.F.)
	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CODFOR"), cA100For ))
	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"LOJFOR"), cLoja    ))
	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"FORNEC"), cNomEmit ))
	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPDOC") , cTipo    ))
	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"INDRUR"), cIndRur  ))
	MsUnlock()

	U_MyAviso("Aviso","Alteração efetuada com sucesso.",{"OK"},2)

Return
