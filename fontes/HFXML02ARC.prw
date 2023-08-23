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
//#INCLUDE "INKEY.CH"
#INCLUDE "XMLXFUN.CH"


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HFXML2ARCº Autor ³Eneovaldo Roveri Jr.º Data ³  25/07/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Menu de Aviso de Recebimento de Carga                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Importa Xml                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function HFXML2ARC

Local lOk := .T.
Local aArea:= GetArea()
Local cMsg := "Gerando o Aviso do Recebimento de Carga ..."

If (xZBZ)->(FieldPos(xZBZ_+"STATUS"))>0 .And. (xZBZ)->(FieldGet(FieldPos(xZBZ_+"STATUS"))) <> "1"  //Ja tinha antes 18/8/18
	
	//Proceder consulta do Bixo 
	if GetNewPar("XM_DFE","0") $ "0,1"
		U_HFXML02X( ,,,.T. )
	else
		U_HFXML16X( ,,,.T. )
	endif

ElseIf ( GetNewPar("XM_SEFPRN", "N") == "S" )

	//Proceder consulta do Bixo em 18/08. Consulta Todos mas não mostra Tela.
	if GetNewPar("XM_DFE","0") $ "0,1"
		U_HFXML02X( ,,,.F. )
	else
		U_HFXML16X( ,,,.F. )
	endif

endif

If (xZBZ)->(FieldPos(xZBZ_+"STATUS"))>0
	If (xZBZ)->(FieldGet(FieldPos(xZBZ_+"STATUS"))) <>"1"
		lOk:= .F.
   		MsgStop("Esta rotina não pode ser executada em um registro com erros na importação ou cancelado.")
	EndIf
EndIf

If (xZBZ)->(FieldPos(xZBZ_+"PROTC"))>0  .And. AllTrim( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"PROTC"))) ) <> ""
	lOk:= .F.
	MsgStop("Este xml foi cancelado pelo emissor.Não pode ser gerada e pré-nota.")
EndIf

If Empty( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR"))) ) .Or. Empty( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR"))) )
	lOk:= .F.
	MsgStop("Este XML não possui fornecedor associado. Clique em Ações Relacionadas / Funções XML / Alterar e Associe o Fornecedor de Acordo com o CNPJ. Caso não Tenha Fornecedor Cadastrado com o CNPJ, faça-o no Cadastro de Fornecedor.")
EndIf

if lOk
	if (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOWL"))) <> "R"  //É só Fadiga mesmo
		cXMLExp    := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML")))
		if upper("<resNFe ") $ upper( cXMLExp )
			dbSelectArea(xZBZ)
			RecLock(xZBZ,.F.)
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPDOWL"), "R" ))
			(xZBZ)->( MsUnlock() )
		endif
	endif
	if (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOWL"))) = "R"
		if U_MyAviso("Resumo","Esse XML é Resumido. Deseja Tentar o Download do XML completo para prosseguir?",{"SIM","NAO"},3) = 1
			U_HFDGXML( AllTrim( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))) ), .T. , .F. ,  NIL    ,"", 0, "2"  )
		endif
	endif
	if (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOWL"))) = "R"
		lOk:= .F.   
		MsgStop("Este XML é Resumido, não gera pré-nota.")
	endif
endif


If lOk

	cXMLExp    := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML")))

	If (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO"))) == "55"
		Processa( {|| U_XMLRECCAR() }, "Aguarde...", cMsg,.F.)
   	ELseIf (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO"))) == "57"
   		if U_MyAviso("Pergunta","Este XML é modelo 57 (CTE). Você deseja incluir Aviso de Recebimento de Carga ou Documento de Entrada (NF,pré-nota)?",{"A.R.Carga","Doc.Entrada"},2) == 1
   			Processa( {|| U_XMLRECCAR() }, "Aguarde...", cMsg,.F.)
   		else
			Processa( {|| U_IMPXMLFOR() }, "Aguarde...", "Gerando a Pré-Nota ...",.F.)
   		endif
	EndIf

EndIf
                       
RestArea(aArea)

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³XMLRECCAR º Autor ³ Eneovaldo Roveri Jrº Data ³  10/07/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ XML dos Fornecedores                                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Importa XML para Aviso de Recebimento de Carga             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function XMLRECCAR()

Local cError    := ""
Local cWarning  := ""
Local lRetorno  := .F.
Local aLinha    := {}
Local nX        := 0
Local nY        := 0                                                   
Local cDoc      := ""
Local cNrAvRC   := ""
Local nTotIcms  := 0
Local nTotIpi   := 0
Local nPeso     := 0
Local nVolume   := 0
Local lOk       := .T.  
Local aProdOk   := {} 
Local aProdNo   := {}
Local aProdVl   := {}
Local aProdZr   := {}
Local oDlg
Local aArea       := GetArea()
Local nTamProd    := TAMSX3("B1_COD")[1]
Local lPergunta   := .F.   
Local cTesPcNf    := GetNewPar("MV_TESPCNF","") // Tes que nao necessita de pedido de compra amarrado
Local lPCNFE      := GetNewPar("MV_PCNFE",.F.)
Local lXMLPE2UM   := ExistBlock( "XMLPE2UM" )
Local lXMLPEIT2   := ExistBlock( "XMLPEIT2" )
Local nQuant      := 0
Local nVunit      := 0
Local nTotal      := 0
Local cUm         := "  "
Local nOpcAuto    := 3
Local nErrItens   := 0
Local nD1Item     := 0
Local oIcm
Local cKeyFe	  := SetKEY( VK_F3 ,  Nil )
Local i           := 0
Local lSeekNF     := .F.

Private oFont01   := TFont():New("Arial",07,14,,.T.,,,,.T.,.F.)
Private oXml
Private oDet
Private lDetCte     := .F.   //Não se aplica
Private lTagOri     := .F.   //Não se aplica
Private cTagFci     := ""
Private cCodFci     := ""
Private lMsErroAuto	:= .F.
Private lMsHelpAuto	:= .T.
Private aCabec    := {}
Private aItens    := {}
Private aItens2   := {}
Private lNossoCod := .F.
Private cProduto  := "" //nTamProd
Private cCnpjEmi  := ""
Private cCodEmit  := ""
Private cLojaEmit := ""
Private nFormNfe  := Val(GetNewPar("XM_FORMNFE","6"))
Private nFormCTE  := Val(GetNewPar("XM_FORMCTE","6"))
Private nFormSer  := Val(GetNewPar("XM_FORMSER","0")) 
Private cEspecNfe := GetNewPar("XM_ESP_NFE","SPED")
Private cEspecNfce:= PADR(GetNewPar("XM_ESP_NFC","NFCE"),5)
Private cEspecCte := GetNewPar("XM_ESP_CTE","CTE")
Private cModelo   := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO")))
Private cTipoNf   := "N"
Private aItXml    := {}
Private cAmarra   := GetNewPar("XM_DE_PARA","0")
Private aPerg     := {}
Private aCombo    := {}
Private nAliqCTE  := 0, nBaseCTE := 0, nPedagio := 0, cModFrete := " "
Private cPCSol    := GetNewPar("XM_CSOL","A")
Private lNfOri    := .F.  //Não se aplica
Private cCnpRem   := ""   //Não se aplica
Private lSharedA1 := U_IsShared("SA1")
Private lSharedA2 := U_IsShared("SA2")

Private cTagTotIcm:= ""
Private cTagTotIpi:= ""
Private cTagPeso  := ""
Private cTagVolume:= ""
Private cTagUfO   := ""
Private cxmlUfo   := "" 
Private lSerEmp   := .NOT. Empty( AllTrim(GetNewPar("XM_SEREMP","")) )
Private lTemFreXml:= .F., lTemDesXml := .F., lTemSegXml := .F.
Private i         := 0

If cModelo == "55"
 	cPref    := "NF-e"                             
	cTAG     := "NFE"
	nFormXML := nFormNfe
	cEspecXML:= cEspecNfe 
	lPergunta:= .F.
ElseIf cModelo == "57"
 	cPref    := "CT-e"                             
	cTAG     := "CTE"
	nFormXML := nFormCte
	cEspecXML:= cEspecCte 
	lPergunta:= .F.
EndIf

cPerg := "IMPXML"
U_HFValPg1(cPerg)

DbSelectArea( xZBA )
(xZBA)->( dbSetOrder( 1 ) )
If (xZBA)->( dbSeek( xFilial( xZBA ) + __cUserID ) )
	If ! Empty( (XZBA)->(FieldGet(FieldPos(XZBA_+"AMARRA"))) )
		cAmarra := (XZBA)->(FieldGet(FieldPos(XZBA_+"AMARRA")))
	EndIf
EndIF
DbSelectArea( xZBZ )

aParam   := {" "}
cParXMLExp := cNumEmp+"IMPXML"
cExt     := ".xml"
cNfes    := ""

aAdd( aCombo, "1=Padrão(SA5/SA7)" )             
aAdd( aCombo, "2=Customizada("+xZB5+")" )
aAdd( aCombo, "3=Sem Amarração"   )            

aadd(aPerg,{2,"Amarração Produto","",aCombo,120,".T.",.T.,".T."})

aParam[01] := ParamLoad(cParXMLExp,aPerg,1,aParam[01])

//cChaveF1 := (xZBZ)->ZBZ_FILIAL + (xZBZ)->ZBZ_NOTA + (xZBZ)->ZBZ_SERIE + (xZBZ)->ZBZ_CODFOR + (xZBZ)->ZBZ_LOJFOR //+ ZBZ->ZBZ_TPDOC
cChaveF1 := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))) + (xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA"))) +;
            (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE")))  + (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR"))) +;
            (xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR"))) //+ (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC")))

DbSelectArea("DB2")
DbSetOrder(1)

DbSelectArea("SF1")
DbSetOrder(1)
	
lSeekNF := DbSeek(cChaveF1)

If !lSeekNF 

		SF1->( DbSetORder(8) )  //F1_FILIAL + F1_CHNFE
		lSeekNF := DbSeek( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL")))+Trim((xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE")))) )
		SF1->( DbSetORder(1) )

EndIF
	
If !lSeekNf

	nOpcAuto := 3

Else

	//cChaveF1 := ZBZ->ZBZ_FILIAL + ZBZ->ZBZ_NOTA + ZBZ->ZBZ_SERIE + ZBZ->ZBZ_CODFOR + ZBZ->ZBZ_LOJFOR + ZBZ->ZBZ_TPDOC
	cChaveF1 := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))) + (xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA"))) +;
    	        (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE")))  + (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR"))) +;
        	    (xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR"))) + (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC")))
	
	DbSelectArea("SF1")
	DbSetOrder(1)
	
	if DbSeek(cChaveF1)

		U_MyAviso("Atenção","Este XML já possui nota!"+CRLF +"Chave :"+cChaveF1,{"OK"},3)
		lRetorno := .T.
		SetKEY( VK_F3 ,  cKeyFe )
		Return

	endif
	
	DbSelectArea("DB1")
	DbSetOrder(1)
	DbSeek(xFilial("DB1") + DB2->DB2_NRAVRC)
	nOpcAuto := 6
	lRetorno := .T.
	
EndIf

If cAmarra $ "0,4" .and. nOpcAuto != 6 //.And. !cModelo $ "57"  0,4 -> 4 é Pedido então pede amarração
	
	If !ParamBox(aPerg,"Importa XML - Amarração",@aParam,,,,,,,cParXMLExp,.T.,.T.)
		SetKEY( VK_F3 ,  cKeyFe )
		Return()
	Else 
   		cAmarra  := aParam[01]
	EndIf
	
EndIf

If lPergunta

	lContImp := Pergunte(cPerg,.T.)
	If !lContImp
		SetKEY( VK_F3 ,  cKeyFe )
		Return()
	EndIf
	
ELse

	lContImp:= .T.
	
EndIf
	
cTipoCPro := MV_PAR02
cTipoCPro := cAmarra

cXml := NoAcento((xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML"))))
cXml := EncodeUTF8(cXml)

//Faz backup do xml sem retirar os caracteres especiais
cBkpXml := cXml

//Executa rotina para retirar os caracteres especiais
cXml := u_zCarEspec( cXml )

oXml := XmlParser(cXml, "_", @cError, @cWarning )

//retorna o backup do xml
cXml := cBkpXml

If oXml == NIL .Or. !Empty(cError) .Or. !Empty(cWarning)

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

	If oXml == NIL .Or. !Empty(cError) .Or. !Empty(cWarning)

		MsgSTOP("XML Invalido ou Não Encontrado, a Importação Não foi Efetuada.")
		SetKEY( VK_F3 ,  cKeyFe )

	endif

	Return

EndIf
        
cTagTpEmiss:= "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_TPEMIS:TEXT"
cTagTpAmb  := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_TPAMB:TEXT"
cTagCHId   := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_ID:TEXT"
cTagSign   := "oXml:_"+cTAG+"PROC:_"+cTAG+":_SIGNATURE"
cTagProt   := "oXml:_"+cTAG+"PROC:_PROT"+cTAG+":_INFPROT:_NPROT:TEXT"
cTagKey    := "oXml:_"+cTAG+"PROC:_PROT"+cTAG+":_INFPROT:_CH"+cTAG+":TEXT"
/* Inclusão da tag CPF empresa Bela Ischa - 20/09/2016 */
If Type("oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_EMIT:_CNPJ:TEXT") == "U"
	cTagDocEmit:= "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_EMIT:_CPF:TEXT"  
Else 
	cTagDocEmit:= "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_EMIT:_CNPJ:TEXT"
EndIf
/* Fim */

cTagDocXMl := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_N"+Left(cTAG,2)+":TEXT"
cTagSerXml := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_SERIE:TEXT"

If cModelo == "55"

	cTagDtEmit := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_DEMI:TEXT"
	if type(cTagDtEmit) == "U"
		cTagDtEmit := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_DHEMI:TEXT"
	endif
	cTagDocDest:= "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_DEST:_CNPJ:TEXT"
	cTagUfO    := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_EMIT:_ENDEREMIT:_UF:TEXT"

	cTagTotIcm := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_TOTAL:_ICMSTOT:_VICMS:TEXT"
	cTagTotIpi := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_TOTAL:_ICMSTOT:_VIPI:TEXT"
	cTagPeso   := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_TRANSP:_VOL:_PESOB:TEXT"
	cTagVolume := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_TRANSP:_VOL:_QVOL:TEXT"
		
ElSeIf cModelo == "57"

	cTagDtEmit := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_DHEMI:TEXT"
	cTagDocDest:= "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_REM:_CNPJ:TEXT"
	cTagUfO    := ""
	cTagAliq   := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IMP:_ICMS:_ICMS00:_PICMS:TEXT"  
	//Incluindo a TAG ICMS20 pelo Analista Alexandro de Oliveira - 16/12/2014
	cTagAliq1  := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IMP:_ICMS:_ICMS20:_PICMS:TEXT"
	
	If Type(cTagAliq)<> "U"
		nAliqCTE   := Val(&(cTagAliq))  
	ElseIf Type(cTagAliq1)<>"U"
		nAliqCTE  := Val(&(cTagAliq1))
	EndIf	
	
	cTagBase   := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IMP:_ICMS:_ICMS00:_VBC:TEXT"
	//Incluindo a TAG ICMS20 pelo Analista Alexandro de Oliveira - 16/12/2014
	cTagBase1  := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IMP:_ICMS:_ICMS20:_VBC:TEXT"
	
	If Type(cTagBase)<> "U"
		nBaseCTE   := Val(&(cTagBase))
	ElseIf Type(cTagBase1)<> "U"
		nBaseCTE   := Val(&(cTagBase1))
	EndIf	  
		
	nPedagio := 0
	
	If Type( "oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP" ) != "U"
	
		oDet := oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP
		oDet := iif( ValType(oDet) == "O", {oDet}, oDet )
		
		For i := 1 to Len( oDet )
			If AllTRim( oDet[i]:_XNOME:TEXT ) == "PEDAGIO"
				nPedagio := Val(oDet[i]:_VCOMP:TEXT)
			EndIf
		
		Next i
		
	EndIf

	cTagTotIcm := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IMP:_ICMS:_CST00:_VICMS:TEXT"
	cTagTotIpi := ""

	oDet := oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ
	oDet := IIf(ValType(oDet)=="O",{oDet},oDet)
	
	For i := 1 To len(oDet)
		if oDet[i]:_CUNID:TEXT == "01"
			cTagPeso   := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_INF"+cTAG+"NORM:_INFCARGA:_INFQ["+alltrim(str(i))+"]:_QCARGA:TEXT"
		elseif oDet[i]:_CUNID:TEXT == "03"
			cTagVolume := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_INF"+cTAG+"NORM:_INFCARGA:_INFQ["+alltrim(str(i))+"]:_QCARGA:TEXT"
		endif
	Next i

Else

	cTagUfO    := ""
	cTagDtEmit := "" 
	cTagDocDest:= ""	
	cTagTotIcm := ""
	cTagTotIpi := ""
	cTagPeso   := ""
	cTagVolume := ""
		
EndIf

cCodEmit  := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR")))
cLojaEmit := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR")))
//cDocXMl   := Iif(nFormXML > 0,StrZero(Val(&(cTagDocXMl)),nFormXML),&(cTagDocXMl))
cDocXMl   := Iif(nFormXML > 0,StrZero(Val((xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA")))),nFormXML),(xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA"))))
cSerXml   := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE"))) //&(cTagSerXml)  //aqui em 21/01/2016

//Alterado para atender ao empresa ITAMBÉ - 16/10/2014
Do Case
Case ( GetNewPar("XM_SERXML","N") == "S" )

	if alltrim( cSerXml ) == '0' .or. alltrim( cSerXml ) == '00' .or. alltrim( cSerXml ) == '000'
		cSerXml := '   '
	EndIf

Case ( GetNewPar("XM_SERXML","N") == "Z" )

	If Empty(cSerXml)
		cSerXml := '0'
	Endif

Case ( GetNewPar("XM_SERXML","N") == "P" )

	cSerXml := Padl(alltrim(cSerXml),nFormSer,"0")   //Padl(alltrim(cSerXml),Tamsx3("D1_SERIE")[1],"0")

EndCase

if lSerEmp
	cSerXml := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE")))
endif
  
cChaveXml := &(cTagKey)

If Type(cTagUfO)<> "U"
	cxmlUfo := &(cTagUfO)
endif

cDtEmit   := &(cTagDtEmit) 
dDataEntr := StoD(substr(cDtEmit,1,4)+Substr(cDtEmit,6,2)+Substr(cDtEmit,9,2))
//	cNrAvRC   := GETSXENUM("DB1","DB1_NRAVRC")
nTotIcms  := iif(Type(cTagTotIcm)<>"U", Val(&(cTagTotIcm)), 0)
nTotIpi   := iif(Type(cTagTotIpi)<>"U", Val(&(cTagTotIpi)), 0)
nPeso     := iif(Type(cTagPeso)<>"U", Val(&(cTagPeso)), 0)
nVolume   := iif(Type(cTagVolume)<>"U", Val(&(cTagVolume)), 0)

aCabec := {}
aadd(aCabec,{"DB1_TIPONF" , Iif(Empty((xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC")))),"N",AllTrim( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC"))) ))})
aadd(aCabec,{"DB1_TIPO"   , Iif((xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC"))) $ "D|B", "1", "2" ) })
aadd(aCabec,{"DB1_CLIFOR" , cCodEmit  })
aadd(aCabec,{"DB1_LOJA"   , cLojaEmit })
aadd(aCabec,{"DB1_EMISSA" , dDataBase })
aadd(aCabec,{"DB1_ENTREG" , dDataBase })
aadd(aCabec,{"DB1_HORA1"  , substr(Time(),1,5) })
aadd(aCabec,{"DB1_ENTREF" , dDataBase })
aadd(aCabec,{"DB1_HORA2"  , substr(Time(),1,5) })
//	aadd(aCabec,{"DB1_NRAVRC" , cNrAvRC  })
//	aadd(aCabec,{"DB1_NRDOC"  , cNrAvRC })

aItens := {}
aLinha := {}
aadd(aLinha,{"DB2_DOC"    , cDocXMl  								,Nil })
aadd(aLinha,{"DB2_SERIE"  , cSerXml  								,Nil })
aadd(aLinha,{"DB2_EMISSA" , dDataEntr								,Nil })
aadd(aLinha,{"DB2_TIPO"   , Iif((xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC"))) $ "D|B", "1", "2" ) 	,Nil })
aadd(aLinha,{"DB2_CLIFOR" , cCodEmit 								,Nil })
aadd(aLinha,{"DB2_LOJA"   , cLojaEmit 								,Nil })
aadd(aLinha,{"DB2_ITEM"   , StrZero(1,Len(DB2->DB2_ITEM))			,Nil })
aadd(aLinha,{"DB2_ESPECI" , cEspecXML 								,Nil })
aadd(aLinha,{"DB2_FORMUL" , "2"										,Nil })
aadd(aLinha,{"DB2_VALICM" , nTotIcms								,Nil })
aadd(aLinha,{"DB2_VALIPI" , nTotIpi									,Nil })
aadd(aLinha,{"DB2_PESO"   , nPeso									,Nil })
aadd(aLinha,{"DB2_VOLUME" , nVolume									,Nil })
//	aadd(aLinha,{"DB2_NRAVRC" , cNrAvRC									,Nil })

aadd(aItens,aLinha)
//	aadd(aItens,{"F1_CHVNFE"  ,cChaveXml}) ta la no hfxml05.prw

lCadastra := .F.
  
Do while nErrItens < 2

 nErrItens++
 lRetorno := .T.
 aLinha   := {}
 aProdOk  := {} 
 aProdNo  := {}
 aProdVl  := {}
 aProdZr  := {}
 aItXml   := {}
 aItens2 := {}
 
 If cModelo == "55" .and. nOpcAuto != 6
 
	oDet := oXml:_NFEPROC:_NFE:_INFNFE:_DET            
	oDet := IIf(ValType(oDet)=="O",{oDet},oDet)
	
	If Type("oXml:_NFEPROC:_NFE:_INFNFE:_DET") == "A"
		aItem := oXml:_NFEPROC:_NFE:_INFNFE:_DET
	Else
		aItem := {oXml:_NFEPROC:_NFE:_INFNFE:_DET}
	EndIf

	nD1Item := 1
	
	For i := 1 To len(oDet)

		//Produto Inteligente - 18/07/2020 - Rogerio Lino
		if cTipoCpro == "6" 

			aRetProd := {}

			//Rotina para executar produto inteligente
			aRetProd := u_HFPRDINT()

			if !Empty( aRetProd )

				if aRetProd[1,4]

					cProduto := aRetProd[1,3]

					aadd( aProdOk, { oDet[i]:_Prod:_CPROD:TEXT, oDet[i]:_Prod:_XPROD:TEXT } )

				else

					aadd( aProdNo, { oDet[i]:_Prod:_CPROD:TEXT, oDet[i]:_Prod:_XPROD:TEXT } )

				endif

			else

				aadd( aProdNo, { oDet[i]:_Prod:_CPROD:TEXT, oDet[i]:_Prod:_XPROD:TEXT } )

			endif

		endif
	
		If cTipoCPro == "2" // Ararracao Customizada ZB5 Produto tem que estar Amarrados Tanto Cliente como Formecedor

			cProduto := ""

			If aCabec[1][2] $ "D|B"

				DbSelectArea(xZB5)
				DbSetOrder(2)
				// Filial + CNPJ CLIENTE + Codigo do Produto do Fornecedor
				If DbSeek(xFilial(xZB5)+PADR((xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))),14)+oDet[i]:_Prod:_CPROD:TEXT)
					cProduto := (xZB5)->(FieldGet(FieldPos(xZB5_+"PRODFI")))
					lRetorno := .T.
					aadd(aProdOk,{oDet[i]:_Prod:_CPROD:TEXT,oDet[i]:_Prod:_XPROD:TEXT} )
				Else         
					aadd(aProdNo,{oDet[i]:_Prod:_CPROD:TEXT,oDet[i]:_Prod:_XPROD:TEXT} )				
				EndIf     

			Else 

				DbSelectArea(xZB5)
				DbSetOrder(1)
				// Filial + CNPJ FORNECEDOR + Codigo do Produto do Fornecedor
				If DbSeek(xFilial(xZB5)+PADR((xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))),14)+oDet[i]:_Prod:_CPROD:TEXT)
					cProduto := (xZB5)->(FieldGet(FieldPos(xZB5_+"PRODFI")))
					lRetorno := .T.
					aadd(aProdOk,{oDet[i]:_Prod:_CPROD:TEXT,oDet[i]:_Prod:_XPROD:TEXT} )
				Else         
					aadd(aProdNo,{oDet[i]:_Prod:_CPROD:TEXT,oDet[i]:_Prod:_XPROD:TEXT} )				
				EndIf

			EndIF          
	
		//##################################################################		
		ElseIf cTipoCPro == "1" // Amarracao Padrao SA5/SA7
		
			If aCabec[1][2] $ "D|B" // dDevolução / Beneficiamento ( utiliza Cliente )

				cProduto  := ""
				
				if empty( cCodEmit )
					cCodEmit  := Posicione("SA2",3,xFilial("SA2")+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))),"A2_COD")
					cLojaEmit := Posicione("SA2",3,xFilial("SA2")+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))),"A2_LOJA")
				endif
		
				cAliasSA7 := GetNextAlias()
				nVz := len(aItem)
				
				cWhere := "%(SA7.A7_CODCLI IN ("				               
				cWhere += "'"+U_TrocaAspas( AllTrim(oDet[i]:_Prod:_CPROD:TEXT) )+"'"
				cWhere += ") )%"				               	
			
				BeginSql Alias cAliasSA7
				
				SELECT	A7_FILIAL, A7_CLIENTE, A7_LOJA, A7_CODCLI, A7_PRODUTO, R_E_C_N_O_ 
						FROM %Table:SA7% SA7
						WHERE SA7.%notdel%
			    		AND A7_CLIENTE = %Exp:cCodEmit%
			    		AND A7_LOJA = %Exp:cLojaEmit%
			    		AND %Exp:cWhere%
			    		ORDER BY A7_FILIAL, A7_CLIENTE, A7_LOJA, A7_CODCLI
				EndSql           
		
				DbSelectArea(cAliasSA7)            
				Dbgotop()
		        lFound := .F.
		        cKeySa7:= xFilial("SA7")+cCodEmit+cLojaEmit+U_TrocaAspas( oDet[i]:_Prod:_CPROD:TEXT )
		        
		        While !(cAliasSA7)->(EOF())
					
					cKeyTMP := (cAliasSA7)->A7_FILIAL+(cAliasSA7)->A7_CLIENTE+(cAliasSA7)->A7_LOJA+(cAliasSA7)->A7_CODCLI
					If 	AllTrim(cKeySa7) == AllTrim(cKeyTMP)
		        		lFound := .T.
		        		Exit
		        	Endif
		        	
		        	(cAliasSA7)->(DbSkip())
		        	
		        Enddo
				
				If lFound
					cProduto := (cAliasSA7)->A7_PRODUTO
					lRetorno := .T.
					aadd(aProdOk,{U_TrocaAspas( oDet[i]:_Prod:_CPROD:TEXT ),oDet[i]:_Prod:_XPROD:TEXT} )
				Else         
					aadd(aProdNo,{U_TrocaAspas( oDet[i]:_Prod:_CPROD:TEXT ),oDet[i]:_Prod:_XPROD:TEXT} )				
				EndIf
	
				DbCloseArea()
			
			Else
			
				cProduto  := ""
				if empty( cCodEmit )
					cCodEmit  := Posicione("SA2",3,xFilial("SA2")+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))),"A2_COD")
					cLojaEmit := Posicione("SA2",3,xFilial("SA2")+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))),"A2_LOJA")
				endif
		
				cAliasSA5 := GetNextAlias()
				nVz := len(aItem)
				
				cWhere := "%(SA5.A5_CODPRF IN ("				               
				cWhere += "'"+U_TrocaAspas( AllTrim(oDet[i]:_Prod:_CPROD:TEXT) )+"'"
				cWhere += ") )%"				               	
			
				BeginSql Alias cAliasSA5
				
				SELECT	A5_FILIAL, A5_FORNECE, A5_LOJA, A5_CODPRF, A5_PRODUTO, R_E_C_N_O_ 
						FROM %Table:SA5% SA5
						WHERE SA5.%notdel%
			    		AND A5_FORNECE = %Exp:cCodEmit%
			    		AND A5_LOJA = %Exp:cLojaEmit%
			    		AND %Exp:cWhere%
			    		ORDER BY A5_FILIAL, A5_FORNECE, A5_LOJA, A5_CODPRF
				EndSql           
		
				DbSelectArea(cAliasSA5)            
				Dbgotop()
		        lFound := .F.
		        cKeySa5:= xFilial("SA5")+cCodEmit+cLojaEmit+U_TrocaAspas( oDet[i]:_Prod:_CPROD:TEXT )
		        
		        While !(cAliasSA5)->(EOF())
					
					cKeyTMP := (cAliasSA5)->A5_FILIAL+(cAliasSA5)->A5_FORNECE+(cAliasSA5)->A5_LOJA+(cAliasSA5)->A5_CODPRF
					
					If 	AllTrim(cKeySa5) == AllTrim(cKeyTMP)
		        		
		        		lFound := .T.
		        		Exit
		        	
		        	Endif
		        	
		        	(cAliasSA5)->(DbSkip())
		        	
		        Enddo
				
				If lFound
				
					cProduto := (cAliasSA5)->A5_PRODUTO
					lRetorno := .T.
					aadd(aProdOk,{U_TrocaAspas( oDet[i]:_Prod:_CPROD:TEXT ),oDet[i]:_Prod:_XPROD:TEXT} )
				
				Else         
					
					aadd(aProdNo,{U_TrocaAspas( oDet[i]:_Prod:_CPROD:TEXT ),oDet[i]:_Prod:_XPROD:TEXT} )				
				
				EndIf
	
				DbCloseArea()
			
			EndIF          		
		
		//##################################################################
		ElseIf cTipoCPro = "3" // Mesmo Codigo Nao requer amarracao SB1
			
			DbSelectArea("SB1")
			DbSetOrder(1)
			If DbSeek(xFilial("SB1")+oDet[i]:_Prod:_CPROD:TEXT)
				cProduto := Substr(oDet[i]:_Prod:_CPROD:TEXT,1,nTamProd)
				lRetorno := .T.
				aadd(aProdOk,{oDet[i]:_Prod:_CPROD:TEXT,oDet[i]:_Prod:_XPROD:TEXT} )
			Else         
				cProduto := Substr(oDet[i]:_Prod:_CPROD:TEXT,1,nTamProd)
				aadd(aProdNo,{oDet[i]:_Prod:_CPROD:TEXT,oDet[i]:_Prod:_XPROD:TEXT} )				
			EndIF
		
		EndIf

		cUm    := "  "
		cTagFci:= "oDet[i]:_Prod:_UCOM:TEXT"
		
		if Type(cTagFci) <> "U"
			cUm := oDet[i]:_Prod:_UCOM:TEXT
		endif
		
		nQuant := VAL(oDet[i]:_Prod:_QCOM:TEXT)
		nVunit := VAL(oDet[i]:_Prod:_VUNCOM:TEXT)
		nTotal := VAL(oDet[i]:_Prod:_VPROD:TEXT)
        cCodFci:= ""
        cTagFci:= "oDet[i]:_PROD:_NFCI:TEXT"
       
        If Type(cTagFci) <> "U"
			cCodFci:= &cTagFci.
		EndIf

		If lXMLPE2UM   //PE para conversão da 2 unidade de medida
			
			if Type("oDet["+AllTrim(Str(i))+"]:_Imposto:_ICMS") <> "U"  //Coferly 14/01/2016
				oIcm := oDet[i]:_Imposto:_ICMS
				oIcm := IIf(ValType(oIcm)=="O",{oIcm},oIcm)
			Else
				oIcm := {}
			EndIF
	   		
	   		aRet :=	ExecBlock( "XMLPE2UM", .F., .F., { cProduto,cUm,nQuant,nVunit,oIcm } )
	   		
	   		if aRet == NIL
				cUm    := "  "
				nQuant := 0
				nVunit := 0
			else
				cUm    := iif( len(aRet) >= 2, aRet[2], "  " )
				nQuant := iif( len(aRet) >= 3, aRet[3], 0 )
				nVunit := iif( len(aRet) >= 4, aRet[4], 0 )
	   		endif
		 	
		 	if NoRound((nQuant * nVunit),2) != NoRound(nTotal, 2)
		 		
		 		if ABS( NoRound((nQuant * nVunit),2) - NoRound(nTotal, 2) ) >= 0.02
					aadd(aProdVl,{oDet[i]:_Prod:_CPROD:TEXT, cUm, nQuant, nVunit, nTotal, (nQuant * nVunit) } )
				else
					if nVunit <> VAL(oDet[i]:_Prod:_VUNCOM:TEXT) //por causa do problema de arredondar e truncar com valor unitário com 3 casas decimais (Itambé)
						aadd(aProdVl,{oDet[i]:_Prod:_CPROD:TEXT, cUm, nQuant, nVunit, nTotal, (nQuant * nVunit) } )
					endif
				endif
				
		 	endif
		 	
	 	EndIf

		aadd(aLinha,{"DB3_ITDOC"  , StrZero(1,Len(DB3->DB3_ITDOC))	,Nil })
		aadd(aLinha,{"DB3_ITEM"   , StrZero(nD1Item,Len(DB3->DB3_ITEM)) 	,Nil })
		aadd(aLinha,{"DB3_CODPRO" , cProduto						,Nil })
		aadd(aLinha,{"DB3_QUANT"  , nQuant							,Nil })
		aadd(aLinha,{"DB3_VUNIT"  , nVunit							,Nil })
		aadd(aLinha,{"DB3_TOTAL"  , nTotal							,Nil })
//		aadd(aLinha,{"DB3_NRAVRC" , cNrAvRC 						,Nil })

		If lXMLPEIT2   //PE para incluir campos no aLinha DB3 -> para o aItens2
	   		
	   		aRet :=	ExecBlock( "XMLPEIT2", .F., .F., { cProduto,oDet,i } )
			
			If ValType(aRet) == "A"
				AEval(aRet,{|x| AAdd(aLinha,x)})
			EndIf
			
	 	endif

		If .not. Empty( cProduto )
		
	 		if SB1->( DbSeek(xFilial("SB1")+cProduto) )
 				
 				If SB1->( FieldGet(FieldPos("B1_MSBLQL")) ) == "1"
	 				aadd(aProdNo,{cProduto,"Produto Bloqueado SB1->"+SB1->B1_DESC} )
 				EndIf
 				
	 		ElseIf cTipoCPro != "3"
	 		
 				aadd(aProdNo,{cProduto,"Nãa Cadastrado SB1->"+oDet[i]:_Prod:_XPROD:TEXT} )
 				
 			EndIf
 			
 		EndIf

 		if nVunit <= 0   //Em natal é permitido valor unitário Zero
			//aadd(aProdZr, { StrZero(i,4), oDet[i]:_Prod:_CPROD:TEXT, cProduto, nVunit, oDet[i]:_Prod:_XPROD:TEXT } )
 		endif

 		if nVunit > 0 //permitir valor unitário maior zero
 		
		 	aadd(aItens2,aLinha)
		 	nD1Item++
		 	aadd(aItXml,{StrZero(i,4),oDet[i]:_Prod:_CPROD:TEXT,oDet[i]:_Prod:_XPROD:TEXT})
		 		
		endif
		
		aLinha := {}

	Next i
         
	if .not. U_ItNaoEnc( "AVRC", aProdOk, aProdNo, aProdVl, @nErrItens, aProdZr )
	
	    lRetorno := .F.
		Loop
		
	endif
	
	//cChaveF1 := ZBZ->ZBZ_FILIAL + ZBZ->ZBZ_NOTA + ZBZ->ZBZ_SERIE + ZBZ->ZBZ_CODFOR + ZBZ->ZBZ_LOJFOR //+ ZBZ->ZBZ_TPDOC
	cChaveF1 := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))) + (xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA")))   +;
    	        (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE")))  + (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR"))) +;
     	        (xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR")))    //+ ZBZ->ZBZ_TPDOC
	
	DbSelectArea("DB2")
	DbSetOrder(1)
	
	lSeekNF := DbSeek(cChaveF1)
	
	If !lSeekNf
	
		If (xZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF"))) $ "A"
			lOkGo := MsgYesNo("A.Rec. Carga gerada previamente mas foi excluida.Deseja prosseguir gerando novamente?","Aviso")						
			If !lOkGo
				lRetorno := .F.
			EndIf
		EndIf
		
		nOpcAuto := 3
		
	Else
	
		cChaveF1 := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))) + (xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA"))) +;
					(xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE")))  + (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR"))) +;
					(xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR"))) + (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC")))
		//cChaveF1 := ZBZ->ZBZ_FILIAL + ZBZ->ZBZ_NOTA + ZBZ->ZBZ_SERIE + ZBZ->ZBZ_CODFOR + ZBZ->ZBZ_LOJFOR + ZBZ->ZBZ_TPDOC
		DbSelectArea("SF1")
		DbSetOrder(1)
	
		if DbSeek(cChaveF1)
			U_MyAviso("Atenção","Esta NFE já foi importada para a Base!"+CRLF +"Chave :"+cChaveF1,{"OK"},3)
			lRetorno := .F.
		endif
		
		DbSelectArea("DB1")
		DbSetOrder(1)
		DbSeek(xFilial("DB1") + DB2->DB2_NRAVRC)
		nOpcAuto := 6
		
	EndIf
	
 ElseIf cModelo == "57" .and. nOpcAuto != 6
 
	lRetorno := .T.
	
	oDet := oXml:_CTEPROC:_CTE:_INFCTE:_VPREST
	cProdCte := Padr(GetNewPar("XM_PRODCTE","FRETE"),nTamProd)
    cProdCte :=Iif(Empty(cProdCte),Padr("FRETE",nTamProd),cProdCte)

	//Produto Inteligente - 18/07/2020 - Rogerio Lino
	if cTipoCpro == "6"

		aRetProd := {}

		//Rotina para executar produto inteligente
		aRetProd := u_HFPRDINT()

		if !Empty( aRetProd )

			if aRetProd[1,4]

				cProduto := aRetProd[1,3]

				aadd( aProdOk, { cProdCte, "PRESTACAO DE SERVICO - FRETE" } )

			else

				aadd( aProdNo, { cProdCte, "PRESTACAO DE SERVICO - FRETE" } )

			endif

		else

			aadd( aProdNo, { cProdCte, "PRESTACAO DE SERVICO - FRETE" } )

		endif

	endif
    
	If cTipoCPro == "2" // Ararracao Customizada ZB5 Produto tem que estar Amarrados Tanto Cliente como Formecedor
		
		cProduto := ""

		DbSelectArea(xZB5)
		DbSetOrder(1)
		
		// Filial + CNPJ FORNECEDOR + Codigo do Produto do Fornecedor
		If DbSeek(xFilial(xZB5)+PADR((xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))),14)+cProdCte)
			cProduto := (xZB5)->(FieldGet(FieldPos(xZB5_+"PRODFI")))
			lRetorno := .T.
			aadd(aProdOk,{cProdCte,"PRESTACAO DE SERVICO - FRETE"} )
		Else         
			aadd(aProdNo,{cProdCte,"PRESTACAO DE SERVICO - FRETE"} )				
		EndIf

	//##################################################################		
	ElseIf cTipoCPro == "1" // Amarracao Padrao SA5/SA7
	
		cProduto  := ""
		
		if empty( cCodEmit )
			cCodEmit  := Posicione("SA2",3,xFilial("SA2")+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))),"A2_COD")
			cLojaEmit := Posicione("SA2",3,xFilial("SA2")+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))),"A2_LOJA")
		endif

		cAliasSA5 := GetNextAlias()
		
		cWhere := "%(SA5.A5_CODPRF IN ("				               
		cWhere += "'"+AllTrim(cProdCte)+"'"
		cWhere += ") )%"				               	
	
		BeginSql Alias cAliasSA5
		
		SELECT	A5_FILIAL, A5_FORNECE, A5_LOJA, A5_CODPRF, A5_PRODUTO, R_E_C_N_O_ 
				FROM %Table:SA5% SA5
				WHERE SA5.%notdel%
	    		AND A5_FORNECE = %Exp:cCodEmit%
	    		AND A5_LOJA = %Exp:cLojaEmit%
	    		AND %Exp:cWhere%
	    		ORDER BY A5_FILIAL, A5_FORNECE, A5_LOJA, A5_CODPRF
		EndSql           

		DbSelectArea(cAliasSA5)            
		Dbgotop()
        lFound := .F.
        cKeySa5:= xFilial("SA5")+cCodEmit+cLojaEmit+cProdCte
        
        While !(cAliasSA5)->(EOF())
        
			cKeyTMP := (cAliasSA5)->A5_FILIAL+(cAliasSA5)->A5_FORNECE+(cAliasSA5)->A5_LOJA+(cAliasSA5)->A5_CODPRF
			
			If 	AllTrim(cKeySa5) == AllTrim(cKeyTMP)
        		lFound := .T.
        		Exit
        	Endif
        	
        	(cAliasSA5)->(DbSkip())
        	
        Enddo
				
		If lFound
			cProduto := (cAliasSA5)->A5_PRODUTO
			lRetorno := .T.
			aadd(aProdOk,{cProduto,"PRESTACAO DE SERVICO - FRETE"} )
		Else         
			cProduto := cProdCte
			aadd(aProdNo,{cProdCte,"PRESTACAO DE SERVICO - FRETE"} )				
		EndIf

		DbCloseArea()
       		
	
	//##################################################################
	ElseIf cTipoCPro = "3" // Mesmo Codigo Nao requer amarracao SB1
		
		DbSelectArea("SB1")
		DbSetOrder(1)
		
		If DbSeek(xFilial("SB1")+cProdCte)
			cProduto := Substr(cProdCte,1,nTamProd)
			lRetorno := .T.
			aadd(aProdOk,{cProdCte,"PRESTACAO DE SERVICO - FRETE"} )
		Else         
			aadd(aProdNo,{cProdCte,"PRESTACAO DE SERVICO - FRETE"} )				
		EndIF
		
	EndIf

	aadd(aLinha,{"DB3_ITDOC"  , StrZero(1,Len(DB3->DB3_ITDOC))	,Nil })
	aadd(aLinha,{"DB3_ITEM"   , StrZero(1,Len(DB3->DB3_ITEM)) 	,Nil })
	aadd(aLinha,{"DB3_CODPRO" , cProduto						,Nil })
	aadd(aLinha,{"DB3_QUANT"  , 1								,Nil })
	aadd(aLinha,{"DB3_VUNIT"  , VAL(oDet:_VTPREST:TEXT)			,Nil })
	aadd(aLinha,{"DB3_TOTAL"  , VAL(oDet:_VTPREST:TEXT)			,Nil })
//	aadd(aLinha,{"DB3_NRAVRC" , cNrAvRC 						,Nil })

	If lXMLPEIT2   //PE para incluir campos no aLinha para o aItens2
   		aRet :=	ExecBlock( "XMLPEIT2", .F., .F., { cProduto,oDet,1 } )
		If ValType(aRet) == "A"
			AEval(aRet,{|x| AAdd(aLinha,x)})
		EndIf
 	endif

	if VAL(oDet:_VTPREST:TEXT) <= 0
		aadd(aProdZr, { StrZero(1,Len(DB3->DB3_ITEM)), cProdCte, cProduto, VAL(oDet:_VTPREST:TEXT),"PRESTACAO DE SERVICO - FRETE" } )
	endif

	If .not. Empty( cProduto )
		if SB1->( DbSeek(xFilial("SB1")+cProduto) )
			If SB1->( FieldGet(FieldPos("B1_MSBLQL")) ) == "1"
				aadd(aProdNo,{cProduto,"Produto Bloqueado SB1->"+SB1->B1_DESC} )
			EndIf
		ElseIf cTipoCPro != "3"
			aadd(aProdNo,{cProduto,"Nãa Cadastrado SB1->"+"PRESTACAO DE SERVICO - FRETE"} )
		EndIf
	EndIf

 	aadd(aItens2,aLinha)
 	aadd(aItXml,{"0001",cProdCte,Posicione("SB1",1,xFilial("SB1")+cProdCte,"B1_DESC")})	
	
	aLinha := {}

	if .not. U_ItNaoEnc( "AVRC", aProdOk, aProdNo, aProdVl, @nErrItens, aProdZr )
	    lRetorno := .F.
		Loop
	endif
	
	//cChaveF1 := ZBZ->ZBZ_FILIAL + ZBZ->ZBZ_NOTA + ZBZ->ZBZ_SERIE + ZBZ->ZBZ_CODFOR + ZBZ->ZBZ_LOJFOR //+ ZBZ->ZBZ_TPDOC
	cChaveF1 := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))) + (xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA"))) +;
	            (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE")))  + (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR"))) +;
	            (xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR"))) //+ (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC")))
	DbSelectArea("DB2")
	DbSetOrder(1)
	
	lSeekNF := DbSeek(cChaveF1)
	
	If !lSeekNf
	
		If (xZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF"))) $ "A"
			lOkGo := MsgYesNo("Av. Rec. de Carga gerada previamente mas foi excluida. Deseja prosseguir gerando novamente?","Aviso")
			If !lOkGo
				lRetorno := .F.
			EndIf
		EndIf
		nOpcAuto := 3
		
	Else
	
		cChaveF1 := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))) + (xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA"))) +;
		            (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE")))  + (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR"))) +;
	    	        (xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR"))) + (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC")))
		//cChaveF1 := ZBZ->ZBZ_FILIAL + ZBZ->ZBZ_NOTA + ZBZ->ZBZ_SERIE + ZBZ->ZBZ_CODFOR + ZBZ->ZBZ_LOJFOR + ZBZ->ZBZ_TPDOC
		DbSelectArea("SF1")
		DbSetOrder(1)

		if DbSeek(cChaveF1)
			U_MyAviso("Atenção","Esta NFE já foi importada para a Base!"+CRLF +"Chave :"+cChaveF1,{"OK"},3)
			lRetorno := .F.
		endif
		DbSelectArea("DB1")
		DbSetOrder(1)
		DbSeek(xFilial("DB1") + DB2->DB2_NRAVRC)
		nOpcAuto := 6
		
	EndIf

 Elseif nOpcAuto == 6
 
  If cModelo == "55"
	oDet := oXml:_NFEPROC:_NFE:_INFNFE:_DET            
	oDet := IIf(ValType(oDet)=="O",{oDet},oDet)
  ElseIf cModelo == "57"
	oDet := oXml:_CTEPROC:_CTE:_INFCTE:_VPREST
  Endif
	
 EndIf

 Exit
 
Enddo

If lRetorno

	DbSelectArea("DB1")
	DbSetOrder(1)

	aCols    := {}
	aRetHead := {}
	aRetCol  := {}

	lSetPC := .F.

	If cModelo =='57' .and. nOpcAuto != 6
		If !Empty(cTesPcNf) .And. (Posicione("SB1",1,xFilial("SB1")+aItens[1][2][2],"B1_TE") $ AllTrim(cTesPcNf))
			lSetPC := .T.
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Inicio da Inclusao                                           |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lRetorno :=.T. // U_VisNota(cModelo, ZBZ->ZBZ_CNPJ,oXml, aCols, @aCabec, @aItens )                        

	If lRetorno  
	
		lmata140 := .F.

		xRet145 := 0

//		xRet145:= MSExecAuto({|x,y,z| U_Xmata145(x,y,z)},aCabec,aItens,3,,1)
		xRet145 := U_XMATA145(aCabec,aItens,aItens2,nOpcAuto)

		lMata140 := .T.

		lEditStat := .F.

		If lMsErroAuto
			MOSTRAERRO()
		Endif

		if xRet145 > 0
		
		    lMsHelpAuto := .F.

			If xRet145 > 1   //para ver se classifica a nota.
			
				lEditStat := SF1->( DbSeek(cChaveF1) )
				
				if lEditStat .and. Empty(SF1->F1_STATUS)
					U_EditDocXml(cModelo,lSetPc,lMata140,.F.)
				endif
				
			    U_MyAviso("Aviso","Importação do Aviso de Rec. e Carga Efetuado e Homologado com Sucesso."+CRLF+" Utilize a opção :"+CRLF+;
				"Movimento -> Pre-Nota Entrada / Aviso Recbto Carga "+CRLF+" para Verificar a Integridade dos Dados.",{"OK"},3)
			
			Else
			
				lEditStat := SF1->( DbSeek(cChaveF1) )
			    U_MyAviso("Aviso","Importação do Aviso de Rec. e Carga Efetuado com Sucesso."+CRLF+" Utilize a opção :"+CRLF+;
				"Movimento -> Aviso Recbto Carga "+CRLF+" para Verificar a Integridade dos Dados.",{"OK"},3)
			
			EndIf
			
			DbSelectArea(xZBZ)
			Reclock(xZBZ,.F.)
			
			If lEditStat
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PRENF") , Iif(Empty(SF1->F1_STATUS),'S','N') ))
			elseif xRet145 > 1
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PRENF") , "S" ))
			else
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PRENF") , "A" ))
		    endif
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPDOC") , aCabec[1][2] ))
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CODFOR"), aCabec[3][2] ))
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"LOJFOR"), aCabec[4][2] ))
				if FieldPos(xZBZ_+"MANIF") > 0
					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"MANIF"), U_MANIFXML( AllTrim( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))) ), .T. ) ))
				endif
				
			DbSelectArea(xZBZ)
			MsUnlock()

			lRetorno := .T.
		EndIf
	EndIf
Endif

RestArea(aArea)

SetKEY( VK_F3 ,  cKeyFe )

Return
