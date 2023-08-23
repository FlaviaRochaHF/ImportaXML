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


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HFXML02CTEº Autor ³Eneovaldo Roveri Jr.º Data ³  13/10/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Menu de Notas de Conhecimento de Frete (CT-e)              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Importa Xml                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//--------------------------------------------------------------------------//
//Alterações realizadas:
//--------------------------------------------------------------------------//
//FR - 15/03/2021 - #10315 - Cimentos Itambé - correção na chamada da função
//                  U_fNoAcento 
//--------------------------------------------------------------------------//
User Function HFXML02CTE

Local lOk := .T.     
Local aArea:= GetArea()
Local cMsg := "Gerando o Nota de Conhecimento de Transporte..."

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

If lOk

	cXMLExp    := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML")))
	
	If (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO"))) == "55"
		U_MyAviso("Aviso","Este XML é modelo 55 (NF-e). Clique em gera pré-nota.",{"OK"},2)
   	ELseIf (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO"))) == "57"
		//U_MyAviso("Aviso","Em Desenvolvimento",{"OK"},2)
		Processa( {|| U_XMLNFCTE() }, "Aguarde...", "Gerando a Nota de Conhecimento de Transporte ...",.F.)
	EndIf
    
EndIf
                       
RestArea(aArea)
Return



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ XMLNFCTE º Autor ³ Eneovaldo Roveri Jrº Data ³  13/10/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ CTe dos Fornecedores                                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Importa XML                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function XMLNFCTE()

Local cError    := ""
Local cWarning  := ""

Local lRetorno  := .F.
Local aLinha    := {}
Local nX        := 0
Local nY        := 0
Local cDoc      := ""
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
Local nQuant      := 0
Local nVunit      := 0
Local nTotal      := 0
Local cUm         := "  "
Local nErrItens   := 0
Local nD1Item     := 0
Local oIcm
Local cKeyFe	  := SetKEY( VK_F3 ,  Nil )
Local cFornOri	  := space( len(SF1->F1_FORNECE) )
Local cLojaOri	  := space( len(SF1->F1_LOJA) )
Local cTipoNfo    := "N"
Local cFormul     := space( len(SF2->F2_FORMUL) )
Local nVersao     := Val(GetVersao(.F.))     // Indica a versao do Protheus
Local lSoSaida    := .T.
Local cSoSaida    := ""
Local cMunIni	:= ""
Local UFIni     := ""
Local cMunFim	:= ""
Local UFFim     := ""
Local i         := 0
Private cChaveF1 := ""
Private oFont01   := TFont():New("Arial",07,14,,.T.,,,,.T.,.F.)
Private oXml
Private oDet, oOri
Private lMsErroAuto	:= .F.
Private lMsHelpAuto	:= .T.
Private aCabec      := {}
Private aItens      := {}
Private cProduto  := "" //nTamProd
Private cCnpjEmi  := ""
Private cCodEmit  := ""
Private cLojaEmit := ""
Private nFormCTE  := Val(GetNewPar("XM_FORMCTE","9"))
Private nFormSer  := Val(GetNewPar("XM_FORMSER","0")) 
Private cEspecCte := GetNewPar("XM_ESP_CTE","CTE")
Private cModelo   := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO")))
Private aItXml    := {}
Private cAmarra   := "3" //Sem amarração para N Conhec de Frete CTe //GetNewPar("XM_DE_PARA","0")
Private aPerg     := {}
Private aCombo    := {}
Private nAliqCTE  := 0, nBaseCTE := 0, nPedagio := 0, lDetPed := .T.
Private cPCSol    := GetNewPar("XM_CSOL","A")
Private lNfOri    := .T. //( GetNewPar("XM_NFORI","N") == "S" )//Aqui sempre será pelo SF3 documento de entrada
Private cCnpRem   := ""                                        //pois a rotina MATA116 utiliza apenas entradis
Private lSerEmp   := .NOT. Empty( AllTrim(GetNewPar("XM_SEREMP","")) )
Private lTemFreXml:= .F., lTemDesXml := .F., lTemSegXml := .F.
Private cNFOri		:=	""	//Erro de variavel nao existe na empresa norsal incluido pelo alexandro 24/05
Private cSerOri		:=	""	//Erro de variavel nao existe na empresa norsal incluido pelo alexandro 25/05


cPref    := "CT-e"
cTAG     := "CTE"
nFormXML := nFormCte
cEspecXML:= cEspecCte
lPergunta:= .F.

cPerg := "IMPXML"
U_HFValPg1(cPerg)

DbSelectArea( xZBA )
(xZBA)->( dbSetOrder( 1 ) )
If (xZBA)->( dbSeek( xFilial( xZBA ) + __cUserID ) )
	If ! Empty( (XZBA)->(FieldGet(FieldPos(XZBA_+"AMARRA"))) )
		// cAmarra := (XZBA)->(FieldGet(FieldPos(XZBA_+"AMARRA"))) //Aqui não tem esta coisa de amarração, CCM q pediu
	EndIf
EndIF

DbSelectArea( xZBZ )

aParam   := {" "}
cParXMLExp := cNumEmp+"IMPXML"
cExt     := ".xml"
cNfes    := ""

aAdd( aCombo, "1=Padrão(SA5/SA7)" )
aAdd( aCombo, "2=Customizada("+xZB5+")")
aAdd( aCombo, "3=Sem Amarração"   )

aadd(aPerg,{2,"Amarração Produto","",aCombo,120,".T.",.T.,".T."})

aParam[01] := ParamLoad(cParXMLExp,aPerg,1,aParam[01])

If cAmarra $ "0,4" //.And. !cModelo $ "57"  0,4 -> 4 - Pedido, pedir amarração
	
	//cChaveF1 := ZBZ->ZBZ_FILIAL + ZBZ->ZBZ_NOTA + ZBZ->ZBZ_SERIE + ZBZ->ZBZ_CODFOR + ZBZ->ZBZ_LOJFOR + ZBZ->ZBZ_TPDOC
	cChaveF1 := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))) + (xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA"))) +;
	            (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE")))  + (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR"))) +;
	            (xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR"))) + (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC")))
	DbSelectArea("SF1")
	DbSetOrder(1)

	lSeekNF := DbSeek(cChaveF1)

	If lSeekNf
		U_MyAviso("Atenção","Esta NFE já foi importada para a Base!"+CRLF +"Chave :"+cChaveF1,{"OK"},3)
		lRetorno := .F.
		SetKEY( VK_F3 ,  cKeyFe )
		Return()
	EndIf

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

//cTipoCPro := MV_PAR02
cTipoCPro := cAmarra

cXml := U_fNoAcento((xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML"))))		//FR - 15/03/2021 - #10315 - Cimentos Itambé
cXml := EncodeUTF8(cXml)

//Faz backup do xml sem retirar os caracteres especiais
cBkpXml := cXml

//Executa rotina para retirar os caracteres especiais
cXml := u_zCarEspec( cXml )

oXml := XmlParser(cXml, "_", @cError, @cWarning )

//retorna o backup do xml
cXml := cBkpXml

if oXml = NIL  .Or. !Empty(cError) .Or. !Empty(cWarning)

	cError := ""
	cWarning := ""
	
	cXml := U_fNoAcento((xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML"))))		//FR - 15/03/2021 - #10315 - Cimentos Itambé
	cXml := EncodeUTF8(cXml)

	//Faz backup do xml sem retirar os caracteres especiais
	cBkpXml := cXml

	//Executa rotina para retirar os caracteres especiais
	cXml := u_zCarEspec( cXml )

	oXml := U_PARSGDE( cXml, @cError, @cWarning )

	//retorna o backup do xml
	cXml := cBkpXml

endif

If oXml == NIL .Or. !Empty(cError) .Or. !Empty(cWarning)

	MsgSTOP("XML Invalido ou Não Encontrado, a Importação Não foi Efetuada.")
	SetKEY( VK_F3 ,  cKeyFe )
	
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

If cModelo == "57"

		cTagDtEmit := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_DHEMI:TEXT"
		cTagDocDest:= "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_REM:_CNPJ:TEXT"
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
				If AllTRim( UPPER(oDet[i]:_XNOME:TEXT) ) $ "PEDAGIO,PED..GIO"
	   				nPedagio := Val(oDet[i]:_VCOMP:TEXT)
	   			EndIf
	   		Next i
	   		
	   	EndIf
	   	
Else

		cTagDtEmit := ""
		cTagDocDest:= ""
		
EndIf

cCodEmit  := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR")))
cLojaEmit := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR")))
cDocXMl   := Iif(nFormXML > 0,StrZero(Val(&(cTagDocXMl)),nFormXML),&(cTagDocXMl))
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

cSerXml := Substr(cSerXml + space(len(SF1->F1_SERIE)), 1, len(SF1->F1_SERIE) )

if lSerEmp
	cSerXml := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE")))
endif

cChaveXml := &(cTagKey)
cDtEmit   := &(cTagDtEmit)
dDataEntr := StoD(substr(cDtEmit,1,4)+Substr(cDtEmit,6,2)+Substr(cDtEmit,9,2))

aCabec := {}

aadd(aCabec,{"F1_DTDIGIT",dDataBase-90})
aadd(aCabec,{"F1_DTDIGIT",dDataBase  })		//dDataFim	   := aAutoCab[2,2]
aadd(aCabec,{""	         ,1          })		//nRotina      := aAutoCab[3,2]
aadd(aCabec,{"F1_FORNECE",space( len(SF1->F1_FORNECE) )})		//cFornOri	   := aAutoCab[4,2]
aadd(aCabec,{"F1_LOJA"   ,space( len(SF1->F1_LOJA) )   })		//cLojaOri	   := aAutoCab[5,2]
aadd(aCabec,{""          ,1          })		//nTipoOri	   := aAutoCab[6,2]
aadd(aCabec,{""          ,1          })		//lAglutProd     := If(aAutoCab[7,2]==1,.T.,.F.)
aadd(aCabec,{"F1_EST"    ,U_VerUfOri( cCodEmit, cLojaEmit, (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC"))) )		 })		//cUFOri         := aAutoCab[8,2]  (xZBZ)->(FieldGet(FieldPos(xZBZ_+"UF"))), vai dor do For
aadd(aCabec,{"F1_VALBRUT",0          })		//valoire := aAutoCab[9,2]
aadd(aCabec,{"F1_FORMUL" ,1          })		//Formulario póprio 1=Non        := aAutoCab[10,2]
aadd(aCabec,{"F1_DOC"    ,cDocXMl    })		//c116NumNF	    := If(l116Auto,aAutoCab[11,2],CriaVar("F1_DOC",.F.))
aadd(aCabec,{"F1_SERIE"  ,cSerXml    })		//c116SerNF	    := If(l116Auto,aAutoCab[12,2],CriaVar("F1_SERIE",.F.))
aadd(aCabec,{"F1_FORNECE",cCodEmit   })		//c116Fornece   := If(l116Auto,aAutoCab[13,2],CriaVar("F1_FORNECE",.F.))
aadd(aCabec,{"F1_LOJA"   ,cLojaEmit  })     //c116Loja	    := If(l116Auto,aAutoCab[14,2],CriaVar("F1_LOJA",.F.))
aadd(aCabec,{"D1_TES"    ,space(len(SD1->D1_TES))})     //c116Tes	    := If(l116Auto,aAutoCab[15,2],CriaVar("D1_TES",.F.))
aadd(aCabec,{"D1_BRICMS" ,0          })     //Base ICMS
aadd(aCabec,{"D1_ICMSRET",0          })     //ICMS Retido
aadd(aCabec,{"F1_ESPECIE",cEspecXML  })     //c116Especie   := If(l116Auto,aAutoCab[18,2],CriaVar("F1_ESPECIE",.F.))
aadd(aCabec,{"F1_CHVNFE" ,cChaveXml}) //nosso
aadd(aCabec,{"F1_VALPEDG",nPedagio }) //nosso
aadd(aCabec,{"NF_BASEICM",nBaseCTE   })     //Base ICMS
aadd(aCabec,{"NF_VALICM" ,nBaseCTE*(nAliqCte/100)})     //ICMS Retido
aadd(aCabec,{"F1_EMISSAO",dDataEntr }) 
/* Incremento do Tipo de CTe , tornando campo obrigatorio */
aadd(aCabec,{"F1_TPCTE",(xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPCTE"))) })
/* Fim do Incremento */
IF SF1->(FieldPos("F1_UFORITR")) > 0 .And. SF1->(FieldPos("F1_MUORITR")) > 0 .And. SF1->(FieldPos("F1_UFDESTR")) > 0 .And. SF1->(FieldPos("F1_MUDESTR")) > 0
	if Type( "oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_CMUNINI:TEXT" ) <> "U"  //variavel oXml private, vindo do importa.
		cMunIni := oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_CMUNINI:TEXT
		if Len(cMunIni) == 7
			cMunIni := Substr(cMunIni,3,5)  //Os dois primeiros dígito é o Estado, no Prohtues o Código inicia direto na cidade.
		Endif
	endif
	if Type( "oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_UFINI:TEXT" ) <> "U"
		UFIni := oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_UFINI:TEXT
	endif

	if Type( "oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_CMUNFIM:TEXT" ) <> "U"  //variavel oXml private, vindo do importa.
		cMunFim := oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_CMUNFIM:TEXT
		if Len(cMunFim) == 7
			cMunFim := Substr(cMunFim,3,5)  //Os dois primeiros dígito é o Estado, no Prohtues o Código inicia direto na cidade.
		Endif
	endif
	if Type( "oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_UFFIM:TEXT" ) <> "U"
		UFFim := oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_UFFIM:TEXT
	endif

	aadd(aCabec,{"F1_MUORITR",cMunIni }) 
	aadd(aCabec,{"F1_UFORITR",UFIni   }) 
	aadd(aCabec,{"F1_MUDESTR",cMunFim }) 
	aadd(aCabec,{"F1_UFDESTR",UFFim   }) 
ENDIF

lCadastra := .F.

Do while nErrItens < 2

 	nErrItens++
 	lRetorno := .T.
 	aLinha   := {}
 	aProdOk  := {}
 	aProdNo  := {}
 	aProdZr  := {}
 	aProdVl  := {}
 	aItens   := {}

	lRetorno := .T.
	cCnpRem := ""
	
	if lNfOri
		if Type(cTagDocDest) != "U"
			cCnpRem := &cTagDocDest
		endif
	endif

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
			cProduto := (xZB5)->(FieldGet(FieldPos(xZB5_+"PRODFI"))) //ZB5->ZB5_PRODFI
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
		//DbSelectArea("SB1")
		//DbSetOrder(1)
		//If DbSeek(xFilial("SB1")+cProdCte)
			cProduto := Substr(cProdCte,1,nTamProd)
			lRetorno := .T.
			aadd(aProdOk,{cProdCte,"PRESTACAO DE SERVICO - FRETE"} )
		//Else
		//	aadd(aProdNo,{cProdCte,"PRESTACAO DE SERVICO - FRETE"} )
		//EndIF
	EndIf

	lSoSaida := .T.
	cSoSaida := ""
	If Type("oXml:_CTEPROC:_CTE:_INFCTE:_REM:_INFNF") != "U"
		oOri := oXml:_CTEPROC:_CTE:_INFCTE:_REM:_INFNF
		oOri := IIf(ValType(oOri)=="O",{oOri},oOri)

		For i := 1 To Len(oOri)

			aLinha := {}
			cFornOri := space( len(SF1->F1_FORNECE) )
			cLojaOri := space( len(SF1->F1_LOJA) )
			cTipoNfo := "N"
			cFormul  := space( len(SF2->F2_FORMUL) )
			cNfOri   := oOri[i]:_NDOC:TEXT
			if Val(cNfOri) > 0
				cNfOri := StrZero( Val(cNfOri), len(SD1->D1_NFORI) )
			endif
			cSerOri := AllTrim( oOri[i]:_SERIE:TEXT )
			cCnpRem := ""

			if lNfOri
				if Type(cTagDocDest) != "U"
					cCnpRem := &cTagDocDest
				endif
				if .not. empty(cCnpRem)
					U_ExistSf3( @cNfOri, @cSerOri, @cFornOri, @cLojaOri, @cTipoNfo, @cFormul )
				endif
			else //aqui nunca entrará to forçando o Bixo
				U_ExistDoc( @cNfOri, @cSerOri, @cFornOri, @cLojaOri, @cTipoNfo, @cFormul )
			endif
			aadd(aLinha,{"D1_NFORI"  ,cNfOri			     ,Nil})
			aadd(aLinha,{"D1_SERIORI",cSerOri				 ,Nil})
			aadd(aLinha,{"D1_FORNECE",cFornOri				 ,Nil})
			aadd(aLinha,{"D1_LOJA"   ,cLojaOri				 ,Nil})
			aadd(aLinha,{"D1_TIPO"   ,cTipoNfo				 ,Nil})
			aadd(aLinha,{"D1_FORMUL" ,cFormul				 ,Nil})

			aadd(aItens,aLinha)
			if Empty( aCabec[4,2] )
				aCabec[4,2] := cFornOri
				aCabec[5,2] := cLojaOri
				aCabec[6,2] := iif( cTipoNfo $ "D|B", 2, 1 )
			endif
			If Len( aCabec ) >= 8 .And. Empty( aCabec[8,2] )
				aCabec[8,2] := U_VerUfOri( cCodEmit, cLojaEmit, "N" )
			EndIf
			cChaveF1 := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))) + cNfOri + cSerOri + cFornOri + cLojaOri + cTipoNfo
			SF1->( DbSetOrder(1) )
			If SF1->( DbSeek(cChaveF1) )
				If SF1->F1_DTDIGIT < aCabec[1,2]
					aCabec[1,2] := SF1->F1_DTDIGIT
				EndIf
			EndIf

		Next i

	ElseIf Type("oXml:_CTEPROC:_CTE:_INFCTE:_REM:_INFNFE") != "U"
		oOri := oXml:_CTEPROC:_CTE:_INFCTE:_REM:_INFNFE
		oOri := IIf(ValType(oOri)=="O",{oOri},oOri)

		For i := 1 To Len(oOri)

			//Verificar se é chave de Nota Fiscal de Saida, dai tem que fazer via documento de entrada.
			aDocDaChave := U_DocDaChave( oOri[i]:_CHAVE:TEXT, cFornOri, cLojaOri, cTipoNfo, cFormul )  //Pegar Documentos no SF2
			If ! ("N/E" $ aDocDaChave[1])
				cSoSaida += oOri[i]:_CHAVE:TEXT + CRLF
				Loop
			EndIF
			
			lSoSaida := .F.

            cCnpRem  := ""
			cFornOri := space( len(SF1->F1_FORNECE) )
			cLojaOri := space( len(SF1->F1_LOJA) )
			cTipoNfo := "N"
			cFormul  := space( len(SF2->F2_FORMUL) )
			aLinha := {}
			
			if lNfOri
				aDocDaChave := U_Sf3DaChave( oOri[i]:_CHAVE:TEXT, @cFornOri, @cLojaOri, @cTipoNfo, @cFormul )  //Pegar Documentos no SF3
			else  //aqui nunca entrará to forçando o Bixo
				aDocDaChave := U_DocDaChave( oOri[i]:_CHAVE:TEXT, @cFornOri, @cLojaOri, @cTipoNfo, @cFormul )  //Pegar Documentos no SF2
			endif
			
			cNfOri := aDocDaChave[1]
			cSerOri := aDocDaChave[2]
			
			aadd(aLinha,{"D1_NFORI"  ,cNfOri			     ,Nil})
			aadd(aLinha,{"D1_SERIORI",cSerOri				 ,Nil})
			aadd(aLinha,{"D1_FORNECE",cFornOri				 ,Nil})
			aadd(aLinha,{"D1_LOJA"   ,cLojaOri				 ,Nil})
			aadd(aLinha,{"D1_TIPO"   ,cTipoNfo				 ,Nil})
			aadd(aLinha,{"D1_FORMUL" ,cFormul				 ,Nil})

			aadd(aItens,aLinha)
			
			if Empty( aCabec[4,2] )
				aCabec[4,2] := cFornOri
				aCabec[5,2] := cLojaOri
				aCabec[6,2] := iif( cTipoNfo $ "D|B", 2, 1 )
			endif
			
			If Len( aCabec ) >= 8 .And. Empty( aCabec[8,2] )
				aCabec[8,2] := U_VerUfOri( cCodEmit, cLojaEmit, "N" )
			EndIf
			
			cChaveF1 := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))) + cNfOri + cSerOri + cFornOri + cLojaOri + cTipoNfo
			SF1->( DbSetOrder(1) )
			If SF1->( DbSeek(cChaveF1) )
				If SF1->F1_DTDIGIT < aCabec[1,2]
					aCabec[1,2] := SF1->F1_DTDIGIT
				EndIf
			EndIf

		Next i

	ElseIf Type("oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF") != "U"
		
		oOri := oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF
		oOri := IIf(ValType(oOri)=="O",{oOri},oOri)

		For i := 1 To Len(oOri)

			aLinha := {}
			cFornOri := space( len(SF1->F1_FORNECE) )
			cLojaOri := space( len(SF1->F1_LOJA) )
			cTipoNfo := "N"
			cFormul  := space( len(SF2->F2_FORMUL) )
			cNfOri := oOri[i]:_NDOC:TEXT
			
			if Val(cNfOri) > 0
				cNfOri := StrZero( Val(cNfOri), len(SD1->D1_NFORI) )
			endif
			
			cSerOri := AllTrim( oOri[i]:_SERIE:TEXT )
			cCnpRem := ""

			if lNfOri
			
				if Type(cTagDocDest) != "U"
					cCnpRem := &cTagDocDest
				endif
				if .not. empty(cCnpRem)
					U_ExistSf3( @cNfOri, @cSerOri, @cFornOri, @cLojaOri, @cTipoNfo, @cFormul )
				endif
				
			else  //Aqui nunca entrará to forçando o Bixo
				
				U_ExistDoc( @cNfOri, @cSerOri, @cFornOri, @cLojaOri, @cTipoNfo, @cFormul )
			
			endif
			
			If Empty( cFornOri )  //aqui na xandro
				cSoSaida += Alltrim( oOri[i]:_CHAVE:TEXT ) + CRLF
				Loop
			EndIF
			
			lSoSaida := .F.   //até aqui na xandro
			
			aadd(aLinha,{"D1_NFORI"  ,cNfOri			     ,Nil})
			aadd(aLinha,{"D1_SERIORI",cSerOri				 ,Nil})
			aadd(aLinha,{"D1_FORNECE",cFornOri				 ,Nil})
			aadd(aLinha,{"D1_LOJA"   ,cLojaOri				 ,Nil})
			aadd(aLinha,{"D1_TIPO"   ,cTipoNfo				 ,Nil})
			aadd(aLinha,{"D1_FORMUL" ,cFormul				 ,Nil})

			aadd(aItens,aLinha)
			
			if Empty( aCabec[4,2] )
				aCabec[4,2] := cFornOri
				aCabec[5,2] := cLojaOri
				aCabec[6,2] := iif( cTipoNfo $ "D|B", 2, 1 )
			endif
			
			If Len( aCabec ) >= 8 .And. Empty( aCabec[8,2] )
				aCabec[8,2] := U_VerUfOri( cCodEmit, cLojaEmit, "N" )
			EndIf
			
			cChaveF1 := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))) + cNfOri + cSerOri + cFornOri + cLojaOri + cTipoNfo
			SF1->( DbSetOrder(1) )
			If SF1->( DbSeek(cChaveF1) )
				If SF1->F1_DTDIGIT < aCabec[1,2]
					aCabec[1,2] := SF1->F1_DTDIGIT
				EndIf
			EndIf

		Next i

	ElseIf Type("oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE") != "U"
	
		oOri := oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE  
		oOri := IIf(ValType(oOri)=="O",{oOri},oOri)

		For i := 1 To Len(oOri)

			//Verificar se é chave de Nota Fiscal de Saida, dai tem que fazer via documento de entrada.
			aDocDaChave := U_DocDaChave( oOri[i]:_CHAVE:TEXT, cFornOri, cLojaOri, cTipoNfo, cFormul )  //Pegar Documentos no SF2
			If ! ("N/E" $ aDocDaChave[1])
				cSoSaida += aLLtRIM(oOri[i]:_CHAVE:TEXT) + CRLF
				Loop
			EndIF
			
			lSoSaida := .F.

			aLinha   := {}
			cFornOri := space( len(SF1->F1_FORNECE) )
			cLojaOri := space( len(SF1->F1_LOJA) )
			cTipoNfo := "N"
			cFormul  := space( len(SF2->F2_FORMUL) )
			cCnpRem  := ""
			
			if lNfOri
				aDocDaChave := U_Sf3DaChave( oOri[i]:_CHAVE:TEXT, @cFornOri, @cLojaOri, @cTipoNfo, @cFormul )  //Pegar Documentos no SF3
			else  //aqui nunca entrará to forçando o Bixo
				aDocDaChave := U_DocDaChave( oOri[i]:_CHAVE:TEXT, @cFornOri, @cLojaOri, @cTipoNfo, @cFormul )  //Pegar Documentos no SF2
			endif
			
			cNfOri := aDocDaChave[1]
			cSerOri := aDocDaChave[2]
			
			aadd(aLinha,{"D1_NFORI"  ,cNfOri			     ,Nil})
			aadd(aLinha,{"D1_SERIORI",cSerOri				 ,Nil})
			aadd(aLinha,{"D1_FORNECE",cFornOri				 ,Nil})
			aadd(aLinha,{"D1_LOJA"   ,cLojaOri				 ,Nil})
			aadd(aLinha,{"D1_TIPO"   ,cTipoNfo				 ,Nil})
			aadd(aLinha,{"D1_FORMUL" ,cFormul				 ,Nil})

			aadd(aItens,aLinha)
			
			if Empty( aCabec[4,2] )
				aCabec[4,2] := cFornOri
				aCabec[5,2] := cLojaOri
				aCabec[6,2] := iif( cTipoNfo $ "D|B", 2, 1 )
			endif
			
			If Len( aCabec ) >= 8 .And. Empty( aCabec[8,2] )
				aCabec[8,2] := U_VerUfOri( cCodEmit, cLojaEmit, "N" )
			EndIf
			
			cChaveF1 := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))) + cNfOri + cSerOri + cFornOri + cLojaOri + cTipoNfo
			
			SF1->( DbSetOrder(1) )
			If SF1->( DbSeek(cChaveF1) )
				If SF1->F1_DTDIGIT < aCabec[1,2]
					aCabec[1,2] := SF1->F1_DTDIGIT
				EndIf
			EndIf

		Next i

	Else

		//Verificar se é chave de Nota Fiscal de Saida, dai tem que fazer via documento de entrada.
		cSoSaida += "XML não contem as TAGs das Chaves de Origem do CTE." + CRLF

		aLinha := {}
		cFornOri := space( len(SF1->F1_FORNECE) )
		cLojaOri := space( len(SF1->F1_LOJA) )
		cTipoNfo := "N"
		cFormul  := space( len(SF2->F2_FORMUL) )

		aadd(aLinha,{"D1_NFORI"  ,cNfOri			     ,Nil})
		aadd(aLinha,{"D1_SERIORI",cSerOri				 ,Nil})
		aadd(aLinha,{"D1_FORNECE",cFornOri				 ,Nil})
		aadd(aLinha,{"D1_LOJA"   ,cLojaOri				 ,Nil})
		aadd(aLinha,{"D1_TIPO"   ,cTipoNfo				 ,Nil})
		aadd(aLinha,{"D1_FORMUL" ,cFormul				 ,Nil})

		aadd(aItens,aLinha)

		If Len( aCabec ) >= 8 .And. Empty( aCabec[8,2] )
			aCabec[8,2] := U_VerUfOri( cCodEmit, cLojaEmit, "N" )
		EndIf

	EndIf
	
	aCabec[9,2] := VAL(oDet:_VTPREST:TEXT)
	
	if aCabec[9,2] == nBaseCTE //Conforme Zanete em 02/02/2015, se o Valor do Frete For Igual da Base do ICMS, não rateia o Pedagio nos itens
		lDetPed := .F.
//		if nPedagio > 0
//			nBaseCTE := nBaseCTE - nPedagio
//			if nBaseCTE > 0
//				aCabec[21,2] := nBaseCTE
//				aCabec[22,2] := nBaseCTE*(nAliqCte/100)
//			endif
//		endif
	endif

	If .not. empty( cProduto )
	
		if SB1->( DbSeek(xFilial("SB1")+cProduto) )

			If SB1->( FieldGet(FieldPos("B1_MSBLQL")) ) == "1"

				aadd(aProdNo,{cProduto,"Produto Bloqueado SB1->"+SB1->B1_DESC} )

			EndIf			

			if GetNewPar("XM_TESDEV", "N") == "S"  //Verifica cliente usará TES de devolução do campo F4_TESDV

				if cTipoNfo == "D"
				
					DbSelectArea("SF4")
					DbSetOrder(1)
					DbSeek( xFilial("SF4") + SB1->B1_TE )

					if !Empty(SF4->F4_TESDV)

						aCabec[15,2] := SF4->F4_TESDV
						
					endif

				else
					
					aCabec[15,2] := SB1->B1_TE

				endif	

			else
				
				aCabec[15,2] := SB1->B1_TE

			endif			

		ElseIf cTipoCPro != "3"

			aadd(aProdNo,{cProduto,"Não Cadastrado SB1->"+"PRESTACAO DE SERVICO - FRETE"} )

		EndIf
		
	EndIf

	if VAL(oDet:_VTPREST:TEXT) <= 0
		aadd(aProdZr, { "0001", cProdCte, cProduto, VAL(oDet:_VTPREST:TEXT), "PRESTACAO DE SERVICO - FRETE" } )
	endif

	aLinha := {}

	if .not. U_ItNaoEnc( "NFCF", aProdOk, aProdNo, aProdVl, @nErrItens, aProdZr )
	    lRetorno := .F.
		Loop
	endif

	if lSoSaida 
	
		if valtype(cSoSaida) <> "C"
			cSoSaida := "Não Encontrado TAG"
		endif
		
		if valtype(cChaveF1) <> "C"
			cChaveF1 := ""
		endif
		
		U_MyAviso("ATENÇÃO","Este CTE tem origem em Notas de Saída. Esta opção é referente a rotina (MATA116) Conhecimento de Frete, padrão Protheus, que deve ser emitidos em CTes com origem em Notas de Entrada."+CRLF+;
				"Para lançamentos de CTE com origem em Nota de Saída deve ser lançado na Tela de Documento de Entrada (MATA103) "+;
				"no importa xml opção Gerar Pré-Nota"+CRLF+"Origem: "+cSoSaida+CRLF+"Chave CTE :"+cChaveF1,{"OK"},3)
	    lRetorno := .F.
	    
	    Exit
	    
	Endif

	//cChaveF1 := ZBZ->ZBZ_FILIAL + ZBZ->ZBZ_NOTA + ZBZ->ZBZ_SERIE + ZBZ->ZBZ_CODFOR + ZBZ->ZBZ_LOJFOR + ZBZ->ZBZ_TPDOC
	cChaveF1 := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))) + (xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA"))) +;
	            (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE")))  + (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR"))) +;
	            (xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR"))) + (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC")))

	DbSelectArea("SF1")
	DbSetOrder(1)

	lSeekNF := DbSeek(cChaveF1)

	If !lSeekNF 

		SF1->( DbSetORder(8) )  //F1_FILIAL + F1_CHNFE
		lSeekNF := DbSeek( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL")))+Trim((xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE")))) )
		SF1->( DbSetORder(1) )

	EndIF

	If !lSeekNf
		If (xZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF"))) $ "N|S"
			lOkGo := MsgYesNo("Pré-nota gerada previamente mas foi excluida.Deseja prosseguir gerando novamente?","Aviso")
			If !lOkGo
				lRetorno := .F.
			EndIf
		EndIf
	Else
		U_MyAviso("Atenção","Este XML já possui nota!"+CRLF +"Chave :"+cChaveF1,{"OK"},3)
		lRetorno := .F.
	EndIf

 	Exit //só para o nErrItens checar o erro, caso ele inclua pelo DePara a 2a vez estará certo e ele continuará com o aitens preenchido

EndDo

If lRetorno

	aCols    := {}
	aRetHead := {}
	aRetCol  := {}

	lSetPC := .F.

	If cModelo =='57'
//		If !Empty(cTesPcNf) .And. (Posicione("SB1",1,xFilial("SB1")+aItens[1][2][2],"B1_TE") $ AllTrim(cTesPcNf))
//			lSetPC := .T.
//		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Inicio da Inclusao                                           |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lRetorno :=.T.   // U_VisNota(cModelo, ZBZ->ZBZ_CNPJ,oXml, aCols, @aCabec, @aItens )
                         
	If lRetorno  
	
		xRet116 := .F.

		xReg  := (xZBZ)->(Recno())
		aAuxRot := aClone( aRotina )
		aRotina := U_get2Menu()    //Para não dar erro na rotina padrão.

   		xRet116:= U_XMATA116(aCabec,aItens)
  		
		aRotina := aClone( aAuxRot )
		(xZBZ)->( DbGoTo( xReg ) )

		lEditStat := .F.

		If lMsErroAuto .and. .Not. xRet116
		
			MOSTRAERRO()
			MsgSTOP("O documento de entrada não foi gerado.")
			lRetorno := .F.
			lEditStat := .T.
			
		Else                    
		          
			lEditStat := .T.
		    lMsHelpAuto:=.F.
 
			If xRet116
				//If EditDocXml(cModelo,lSetPc,.F.,.F.)
				    U_MyAviso("Aviso","Geração da Nt de Frete Efetuada com Sucesso."+CRLF+" Utilize a opção :"+CRLF+;
					"Movimento -> Nt. Conhec Frete"+CRLF+" para Verificar a Integridade dos Dados.",{"OK"},3)
				//EndIf 
			EndIf	
			lRetorno := .T.
		EndIf 

		If lEditStat
		
				cChaveF1 := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))) + (xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA"))) +;
				            (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE")))  + (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR"))) +;
				            (xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR"))) //+ (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC")))
				
				DbSelectArea("SF1")
				DbSetOrder(1)

				lSeekNF := DbSeek(cChaveF1)

				DbSelectArea(xZBZ)
				Reclock(xZBZ,.F.)
				
				If lSeekNf  //Mano o Cara não pode mudar poque desposiciona o SF1 dai tava dando asneira
					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PRENF") , Iif(Empty(SF1->F1_STATUS),'S','N') ))
					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPDOC") , SF1->F1_TIPO    ))
					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CODFOR"), SF1->F1_FORNECE ))
					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"LOJFOR"), SF1->F1_LOJA    ))
				EndIf
				
				if lSeekNf .And. (xZBZ)->(FieldPos(xZBZ_+"MANIF")) > 0
					cOri := "1"
					if (xZBZ)->(FieldPos(xZBZ_+"IMPORT")) > 0
						cOri := AllTrim( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"IMPORT"))) )
						if empty( cOri )
							cOri := "1"
						endif
					Endif
					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"MANIF"), U_MANIFXML( AllTrim( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))) ), .T., cOri ) ))
				endif
				
				DbSelectArea(xZBZ)
				MsUnlock()    
				 
		EndIf				
	
	EndIf

Endif
           
RestArea(aArea)

SetKEY( VK_F3 ,  cKeyFe )

Return


//Norsal
User Function VerUfOri( cCodigo, cCodLoja, cTipo )

Local aArea		:= GetArea()
Local aAreaSA2	:= SA2->(GetArea())
Local aAreaSA1	:= SA1->(GetArea())
Local cRet      := ""

if AllTrim(cTipo) $ "D,B"

	DbSelectArea( "SA1" )
	SA1->(dbSetOrder(1))
	SA1->(MsSeek(xFilial("SA1")+cCodigo+cCodLoja))
	If SA1->(Found())
		cRet := SA1->A1_EST
	EndIF
	
Else

	DbSelectArea( "SA2" )
	SA2->(dbSetOrder(1))
	SA2->(MsSeek(xFilial("SA2")+cCodigo+cCodLoja))
	If SA2->(Found())
		cRet := SA2->A2_EST
	EndIF
	
Endif

RestArea(aAreaSA1)
RestArea(aAreaSA2)
RestArea(aArea)

Return( cRet )
