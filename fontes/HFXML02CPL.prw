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
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "XMLXFUN.CH" 

#define TST_MAXTHREAD 50
#DEFINE IMP_PDF 6

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HFXML02   º Autor ³ Roberto Souza      º Data ³  12/09/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Chamada para rotina principal de importação de arquivos    º±±
±±º          ³ XML de Fornecedores.                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ IMPORTA XML                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//-------------------------------------------------------------------------//
//Alterações Realizadas:
//FR - 04/05/2021 - Alterações realizadas para adequar a leitura do xml 
//                  função additens, quando nf complemento icms
//                  encontrar uma tag diferentes das que existem no array
//                  aCST, por exemplo a tag: ICMSSN900 (nunca houve)
//                  Em atendimento ao chamado #10536 - MECTRONICS
//-------------------------------------------------------------------------// 
//FR - 05/07/2021 - #10935 - Adar - error log na unidade de medida
//-------------------------------------------------------------------------//
//FR - 04/11/2021 - #11460 - ADAR - ao visualizar nf via ImportaXML, mostra
//                  uma outra nota de mesmo número e fornecedor, porém emissao
//                  diferente, e a chave estava em branco no F1_CHVNFE         
//                  correção para validar com a emissão do XML x NF
//---------------------------------------------------------------------------//

Static USANFE := AllTrim(GetNewPar("XM_USANFE","S")) $ "S "
Static USACTE := AllTrim(GetNewPar("XM_USACTE","S")) $ "S "
Static USANFCE:= AllTrim(GetNewPar("XM_USANFCE","S")) $ "S "
Static lUnix  := IsSrvUnix()
Static cBarra := Iif(lUnix,"/","\")

Static cIdEnt := iif(GetNewPar("XM_DFE","0") $ "0,1",U_GetIdEnt(),"")

//Static cURL      := PadR(GetNewPar("XM_URL",""),250)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³  XMLCPL  º Autor ³ Rolando Lero       º Data ³  05/04/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ XML de Complementos de ICMS/IPI via ExecAtuo               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Importa XML                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function XMLCPL()

Local aArea := GetArea()
Local lOk   := .T.
Local cTes	:= CriaVar("D1_TES",.F.)
Local cCct  := CriaVar("D1_CC",.F.)
Local cNfOri:= CriaVar("D1_NFORI",.F.)
Local cSerOr:= CriaVar("D1_SERIORI",.F.)
Local oSCR1
Local dEmiXML := Ctod("  /  /    ") 	//FR - 04/11/2021 - #11460 - ADAR

Private cTagFci     := ""
Private cCodFci     := ""
Private lNossoCod := .F.
Private cCnpjEmi  := ""  
Private cCodFor   := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR")))
Private cLojFor   := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR")))
Private cCodEmit  := cCodFor
Private cLojaEmit := cLojFor
Private nFormNfe  := Val(GetNewPar("XM_FORMNFE","6"))
Private cEspecNfe := PADR(GetNewPar("XM_ESP_NFE","SPED"),5)
Private cEspecNfse:= PADR(GetNewPar("XM_ESP_NFS","NFS"),5) // NFCE_03 16/05
Private cModelo   := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO")))
Private aItXml    := {}
Private lNfOri    := ( GetNewPar("XM_NFORI","N") == "S" )
Private _lCCusto  := ( GetNewPar("XM_CCNFOR","N") == "S" ), _cCCusto
Private cCnpRem   := ""
Private aCnpRem   := {}
Private cTagAux   := ""
Private nValAux   := 0
Private lSerEmp   := .NOT. Empty( AllTrim(GetNewPar("XM_SEREMP","")) )
Private nAmarris  := 0
Private cPedidis  := ""
Private cTagTot   := ""
Private nTotXml   := 0
Private lAglCTE		:= .F. //( GetNewPar('XM_AGLMCTE') == 'S' ) //Parametro se aglutina multiplos CTE ou nao
//Estes aqui de riba é para o legado, vai que o cabra use no ponto de entrada.

Private oXml
Private oDet, oOri
Private cProduto    := ""
Private lMsErroAuto	:= .F.
Private lMsHelpAuto	:= .T.
Private aCabec      := {}
Private aItens      := {}
Private nFormNfE    := Val(GetNewPar("XM_FORMNFE","9"))
Private nFormSer    := Val(GetNewPar("XM_FORMSER","2")) ///Incluido 19/01/2016
Private cTipoNf     := "N"
Private cPCSol      := GetNewPar("XM_CSOL","A")
Private cAmarra     := GetNewPar("XM_DE_PARA","0")
Private cTipoCPro   := ""
Private nAliqCTE    := 0, nBaseCTE := 0, nPedagio := 0, cModFrete := " "
Private lTemFreXml  := .F., lTemDesXml := .F., lTemSegXml := .F.
Private aAuxPeAma   := {}  //nordsonAmarraCof
Private aPerg       := {}
Private aCombo      := {}
Private cPref       := "NF-e"
Private cTAG        := "NFE"
Private nFormXML    := nFormNfe
Private cEspecXML   := cEspecNfe
Private lPergunta   := .F.
Private lDetCte     := ( GetNewPar("XM_CTE_DET","N") == "S" )
Private lTagOri     := ( GetNewPar("XM_CTE_DET","N") == "S" )
Private aReg        := {}
Private cTagRefNfe  := ""
//Private lTemFreXml  := .F., lTemDesXml := .F., lTemSegXml := .F.

dbSelectArea("SF4")
dbSetOrder(1)
DbSelectArea(xZBZ)

If Empty( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR"))) ) .Or. Empty( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR"))) )

	lOk:= .F.
	MsgStop("Este XML não possui fornecedor associado. Clique em Ações Relacionadas / Funções XML / Alterar e Associe o Fornecedor de Acordo com o CNPJ. Caso não Tenha Fornecedor Cadastrado com o CNPJ, faça-o no Cadastro de Fornecedor.")

EndIf

dEmiXML := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"DTNFE"))) 	//FR - 04/11/2021 - #11460 - ADAR
If lOk

	cChaveF1 := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))) + (xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA"))) +;
	            (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE")))  + (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR"))) +;
	            (xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR"))) + (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC")))

	//cChaveF1 := ZBZ->ZBZ_FILIAL + ZBZ->ZBZ_NOTA + ZBZ->ZBZ_SERIE + ZBZ->ZBZ_CODFOR + ZBZ->ZBZ_LOJFOR + ZBZ->ZBZ_TPDOC
	
	DbSelectArea("SF1")
	DbSetOrder(1)

	lSeekNF := DbSeek(cChaveF1)

	If !lSeekNF 

		SF1->( DbSetORder(8) )  //F1_FILIAL + F1_CHNFE
		lSeekNF := DbSeek( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL")))+Trim((xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE")))) )
		//FR - 04/11/2021 - #11460 - ADAR
		If lSeekNF
			If Empty(SF1->F1_CHVNFE)  //se a chave estiver vazia, comparar com data emissão para validar se o seek é .T. 
				If dEmiXml <> SF1->F1_EMISSAO  //se a emissão for diferente, o seek é .F.
					lSeekNF := .F.
				Endif 
			Endif 
		Endif
		//FR - 04/11/2021 - #11460 - ADAR 
		
		SF1->( DbSetORder(1) )				

	EndIF

	If !lSeekNf
		If (xZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF"))) $ "N|S"
			lOkGo := MsgYesNo("Pré-nota gerada previamente mas foi excluida.Deseja prosseguir gerando novamente?","Aviso")
			If !lOkGo
				lOK := .F.
			EndIf
		EndIf
	Else
		U_MyAviso("Atenção","Este xml já possui nota!"+CRLF +"Chave :"+cChaveF1,{"OK"},3)
		lOK := .F.
	EndIf

Endif

If lOk

	aCabec := {}

	aadd(aCabec,{"F1_TIPO"   ,"N"})
	aadd(aCabec,{"F1_FORMUL" ,"N"})

 	_xTes := Space( Len(SD1->D1_TES) )
 	_xCc  := Space( Len(SD1->D1_CC) )
 	_xNOr := Space( Len(SD1->D1_NFORI ) )
 	_xSOr := Space( Len(SD1->D1_SERIORI ) )

	If .NOT. U_VERAMARR()
		lRet := .F.
		Return( lRet )
	EndIf

	cTes  := _xTes
	cCct  := _xCc
	cNfOri:= _xNOr
	cSerOr:= _xSOr

	@ 001,001 To 280,500 Dialog oSCR1 Title "Indique a TES para Documento de Entrada"

	@ 010,010 SAY "Cod. TES" Of oSCR1 PIXEL SIZE 32 ,9 COLOR CLR_HBLUE,oSCR1:nClrPane //"Cod. TES"
	@ 025,010 MSGET cTES Picture PesqPict("SD1","D1_TES") F3 CpoRetF3("D1_TES");
		      OF oSCR1 PIXEL SIZE 25 ,9 VALID  ExistCpo("SF4",cTES) //.And. A116ChkTES(cTES)

	@ 010,110 SAY "C.Custo " Of oSCR1 PIXEL SIZE 32 ,9 COLOR CLR_HBLUE,oSCR1:nClrPane //"Cod. TES"
	@ 025,110 MSGET cCct Picture PesqPict("SD1","D1_CC") F3 CpoRetF3("D1_CC");
		      OF oSCR1 PIXEL SIZE 25 ,9 //VALID  (Empty(cCct) .or. ExistCpo("CT1",cCct)) //.And. A116ChkTES(cTES)

	@ 040,010 SAY "NF.Ori" Of oSCR1 PIXEL SIZE 32 ,9 COLOR CLR_HBLUE,oSCR1:nClrPane //"NFOR"
	@ 055,010 MSGET cNfOri Picture PesqPict("SD1","D1_NFORI") F3 CpoRetF3("D1_DOC");
		      OF oSCR1 PIXEL SIZE 25 ,9 VALID  !Empty(cNfOri)

	@ 040,110 SAY "Serie Ori" Of oSCR1 PIXEL SIZE 32 ,9 COLOR CLR_HBLUE,oSCR1:nClrPane //"NFOR"
	@ 055,110 MSGET cSerOr Picture PesqPict("SD1","D1_NFORI");
		      OF oSCR1 PIXEL SIZE 25 ,9

	@ 090,160 Button "&Cancelar" Size 030,012 Pixel Action Close(oSCR1)
	@ 090,207 Button "&Ok"       Size 030,012 Pixel Action (Close(oSCR1),Processa({|lEND| Complem(@lEND,cTes,cCct,cNfOri,cSerOr)},"Aguarde..."))
	Activate Dialog oSCR1 Centered

Endif

RestArea( aArea )

Return( NIL )


//
Static Function Complem(lEnd,cTes,cCct,cNfOri,cSerOr)

Local lRet   := .T.
Local nIte   := 0
//Local nI     := 0
//Local nPFci  := 0
//Local nPIte  := 0
//Local nPCod  := 0
Local cOri   := ""
//Local aLinha := {}
Local cError   := ""
Local cWarning := ""
//Local cMsg     := ""
//Local lXMLPEAMA   := ExistBlock( "XMLPEAMA" ), aPEAma, lAmaPe := .F. //nordsonAmarraCof
//Local lXMLPEVAL   := .F. //ExistBlock( "XMLPEVAL" )
//Local lXMLPEREG   := .F. //ExistBlock( "XMLPEREG" )
//Local lXMLPEATU   := .F. //ExistBlock( "XMLPEATU" )
//Local lXMLPE2UM   := ExistBlock( "XMLPE2UM" )
//Local lXMLPEITE   := ExistBlock( "XMLPEITE" )

aCabec	:=	{}
aItens	:=	{}
nIte	:=	0 

DbSelectArea( xZBZ )

cError := ""
cWarning := ""

cXml := NoAcento((xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML"))))
cXml := EncodeUTF8(cXml)

//Faz backup do xml sem retirar os caracteres especiais
cBkpXml := cXml

//Executa rotina para retirar os caracteres especiais
cXml := u_zCarEspec( cXml )

oXml := XmlParser(cXml, "_", @cError, @cWarning )

//retorna o backup do xml
cXml := cBkpXml

if oXml = NIL

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

endif

//Carrega Cabeçalho
addCabec()

//Carrega Itens
If !addItens( @nIte,cTes,cCct,cNfOri,cSerOr )

	MsgStop("Não foi possível carregar os itens...")

	Return( .F. )

endif

lMsErroAuto	:= .F.

xRet103	:= MSExecAuto({|x,y,z,k| mata103(x,y,z,k)},aCabec,aItens,3,.T.)

if Empty( cCancel )

	If !lMsErroAuto

		DbSelectArea( xZBZ )
		Reclock(xZBZ,.F.)

			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PRENF") , 'N' ))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPDOC") , SF1->F1_TIPO ))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CODFOR"), aCabec[6][2] ))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"LOJFOR"), aCabec[7][2] ))

			if FieldPos(xZBZ_+"MANIF") > 0

				cOri := "1"

				if FieldPos(xZBZ_+"IMPORT") > 0
					if !Empty( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"IMPORT"))) )
						cOri := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"IMPORT")))
					Endif
				Endif

				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"MANIF"), U_MANIFXML( AllTrim( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))) ), .T., cOri ) ))
			
			endif

			(xZBZ)->( MsUnlock() )

	Else

		MostraErro()
		lRet := .F.
			
	EndIf

endif

Return(lRet)


Static Function addCabec()

Local cDocXMl   := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA")))
Local cSerXml   := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE")))
Local dDataEntr := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"DTNFE")))
Local cChaveXml := AllTrim( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))) )
Local cTpXml    := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC")))

//Alterado para atender ao empresa ITAMBÉ - 16/10/2014
//Analista Alexandro de Oliveira
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

aadd(aCabec,{"F1_TIPO"   ,cTpXml })
aadd(aCabec,{"F1_FORMUL" ,"N"})
aadd(aCabec,{"F1_DOC"    ,cDocXMl})
aadd(aCabec,{"F1_SERIE"  ,cSerXml})
aadd(aCabec,{"F1_EMISSAO",dDataEntr})
aadd(aCabec,{"F1_FORNECE",cCodFor})
aadd(aCabec,{"F1_LOJA"   ,cLojFor})
aadd(aCabec,{"F1_ESPECIE",cEspecXML})
aadd(aCabec,{"F1_CHVNFE" ,cChaveXml })

Return( NIL )

//---------------------------------------------------------------------//
//Função: addItens
//Objetivo: Montar o array aItens da Nota Fiscal
//---------------------------------------------------------------------//
Static Function addItens( nIte,cTes,cCct,cNfOri,cSerOr )

Local aProdOk   := {}
Local aProdNo   := {}
Local aProdVl   := {}
Local aProdZr   := {}
Local nErrItens := 0
Local nTamProd  := TAMSX3("B1_COD")[1]
Local lFound    := .F.
//Local lRet      := .T.
Local aLinha := {}
Local lRetorno    := .F.
Local lXMLPEAMA   := ExistBlock( "XMLPEAMA" ), aPEAma, lAmaPe := .F. //nordsonAmarraCof
Local lXMLPEVAL   := .F. //ExistBlock( "XMLPEVAL" )
Local lXMLPEREG   := .F. //ExistBlock( "XMLPEREG" )
Local lXMLPEATU   := .F. //ExistBlock( "XMLPEATU" )
Local lXMLPE2UM   := .F. //ExistBlock( "XMLPE2UM" )
Local lXMLPEITE   := ExistBlock( "XMLPEITE" )
Local cTpXml      := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC")))
Local cVLRZERO    := "2"
Local i, y        := 0
Local _ICMBas     := 0
Local cTagAux     := ""

Private cTagTotIcm := ""
Private cTagPerIcm := ""
Private cTagBasIcm := ""
Private cTagTotIpi := ""
Private cTagPerIpi := ""
Private cTagBasIpi := ""
Private nvIcms     := 0
Private npIcms     := 0
Private nbIcms     := 0
Private nvIpi      := 0
Private npIpi      := 0
Private nbIpi      := 0
Private oDet

oDet := oXml:_NFEPROC:_NFE:_INFNFE:_DET
oDet := IIf(ValType(oDet)=="O",{oDet},oDet)

If Type("oXml:_NFEPROC:_NFE:_INFNFE:_DET") == "A"
	aItem := oXml:_NFEPROC:_NFE:_INFNFE:_DET
Else
	aItem := {oXml:_NFEPROC:_NFE:_INFNFE:_DET}
EndIf

nD1Item := 1

For i := 1 To len(oDet)

	//CST de origem
	aCST := FWGetSX5( "S2" ) //Tabela de CST no SX5

	For y := 1 To Len( aCST )

		//ICMS VALOR BASE - Produto
		//cTagAux := "oDet["+AllTrim(str(I))+"]:_IMPOSTO:_ICMS:_ICMS" + alltrim(aCST[y,3]) + ":_vBC:TEXT"     //FR - 04/05/2021
			
		//FR - 04/05/2021 - #10536 - MECTRONICS - NF COMPLEMENTO ICMS - Não carregava os itens devido a um nó novo que tem no XML, o qual não estava contemplado aqui
		//ICMSSN900 - é o nó novo, então eu verifico aqui antes os nós para saber qual atribuição farei na tag de verificação:
		
		cTagAux := "oDet["+AllTrim(str(I))+"]:_IMPOSTO:_ICMS" //atribui até aqui, para saber se existe o nó ICMS00 , 10, 90 e assim por diante de acordo com todas as posições do array aCST
		                                                      
		If XmlChildEx( &(cTagAux) , "_ICMS" + alltrim(aCST[y,3])) <> NIL
			cTagAux := "oDet["+AllTrim(str(I))+"]:_IMPOSTO:_ICMS:_ICMS" + alltrim(aCST[y,3]) + ":_vBC:TEXT"	
		ElseIf XmlChildEx( &(cTagAux) , "_ICMSSN900") <> NIL
			cTagAux := "oDet["+AllTrim(str(I))+"]:_IMPOSTO:_ICMS:_ICMSSN900:_vBC:TEXT"	
		Endif

		If Type( cTagAux ) <> "U"

			_ICMBas := VAL(ALLTRIM(&cTagAux))

			if _ICMBas == 0

				cTagAux := "oDet["+AllTrim(str(I))+"]:_IMPOSTO:_ICMS:_ICMS" + alltrim(aCST[y,3]) + ":_vICMS:TEXT"

				If Type( cTagAux ) <> "U"

					_ICMBas := VAL(ALLTRIM(&cTagAux))

				endif

			endif

		else
			
			Loop

		EndIf

		if _ICMBas > 0

			Exit

		endif

	Next y 

	//Verifica qual produto tem valor para alimentar o item
	if cTpXml == "I"

		if _ICMBas == 0

			Loop

		endif

	endif

	If lXMLPEAMA      //PE para Amarração de podrutos  //nordsonAmarraCof

		aPEAma := ExecBlock( "XMLPEAMA", .F., .F., { oDet,i,oDet[i]:_Prod:_CPROD:TEXT,cModelo,cTipoCPro } )

		if aPEAma == NIL .or. ValType(aPEAma) <> "A"

			cProduto := ""
			lAmaPe := .F.

		Else

			if len(aPEAma) >= 1
				cProduto := aPEAma[1]
			Else
				cProduto := ""
			endif
			if len(aPEAma) >= 2
				if .NOT. Empty(cProduto)
					aadd( aProdOk, aPEAma[2] )
				Else
					aadd( aProdNo, aPEAma[2] )
				Endif
			else
				if .NOT. Empty(cProduto)
					aadd( aProdOk, {oDet[i]:_Prod:_CPROD:TEXT,oDet[i]:_Prod:_XPROD:TEXT} )
				Else
					aadd( aProdNo, {oDet[i]:_Prod:_CPROD:TEXT,oDet[i]:_Prod:_XPROD:TEXT} )
				Endif
			endif

			lAmaPe := .T.

		endif
	else
		lAmaPe := .F.
	EndIf

	If cTipoCPro == "2" .And. ! lAmaPe  //nordsonAmarraCof// Ararracao Customizada ZB5 Produto tem que estar Amarrados Tanto Cliente como Formecedor
		
		cProduto := ""

		If aCabec[1][2] $ "D|B"
			DbSelectArea(xZB5)
			DbSetOrder(2)
			
			// Filial + CNPJ CLIENTE + Codigo do Produto do Fornecedor
			If DbSeek(xFilial(xZB5)+PADR((xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))),14)+oDet[i]:_Prod:_CPROD:TEXT)
				cProduto := (xZB5)->(FieldGet(FieldPos(xZB5_+"PRODFI"))) //ZB5_PRODFI
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
				cProduto := (xZB5)->(FieldGet(FieldPos(xZB5_+"PRODFI"))) //ZB5_PRODFI
				lRetorno := .T.
				aadd(aProdOk,{oDet[i]:_Prod:_CPROD:TEXT,oDet[i]:_Prod:_XPROD:TEXT} )
			Else
				aadd(aProdNo,{oDet[i]:_Prod:_CPROD:TEXT,oDet[i]:_Prod:_XPROD:TEXT} )
			EndIf

		EndIF

	//##################################################################
	ElseIf cTipoCPro == "1" .And. ! lAmaPe  //nordsonAmarraCof// Amarracao Padrao SA5/SA7

		If aCabec[1][2] $ "D|B" // dDevolução / Beneficiamento ( utiliza Cliente )

			cProduto  := ""
			if empty( cCodEmit )
				cCodEmit  := Posicione("SA1",3,xFilial("SA1")+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))),"A1_COD")
				cLojaEmit := Posicione("SA1",3,xFilial("SA1")+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))),"A1_LOJA")
			endif

			cAliasSA7 := GetNextAlias()
			nVz := len(aItem)

			cWhere := "%(SA7.A7_CODCLI IN ("
			cWhere += "'"+TrocaAspas( AllTrim(oDet[i]:_Prod:_CPROD:TEXT) )+"'"
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
			cKeySa7:= xFilial("SA7")+cCodEmit+cLojaEmit+TrocaAspas( oDet[i]:_Prod:_CPROD:TEXT )
			
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

				aadd(aProdOk,{TrocaAspas( oDet[i]:_Prod:_CPROD:TEXT ),oDet[i]:_Prod:_XPROD:TEXT} )
			
			Else

				aadd(aProdNo,{TrocaAspas( oDet[i]:_Prod:_CPROD:TEXT ),oDet[i]:_Prod:_XPROD:TEXT} )

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
			cWhere += "'"+TrocaAspas( AllTrim(oDet[i]:_Prod:_CPROD:TEXT) )+"'"
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
			cKeySa5:= xFilial("SA5")+cCodEmit+cLojaEmit+TrocaAspas( oDet[i]:_Prod:_CPROD:TEXT )
			
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
				aadd(aProdOk,{TrocaAspas( oDet[i]:_Prod:_CPROD:TEXT ),oDet[i]:_Prod:_XPROD:TEXT} )

			Else     

				aadd(aProdNo,{TrocaAspas( oDet[i]:_Prod:_CPROD:TEXT ),oDet[i]:_Prod:_XPROD:TEXT} )	

			EndIf

			DbCloseArea()

		EndIF          		

	//##################################################################
	ElseIf cTipoCPro = "3"   .And. ! lAmaPe   //nordsonAmarraCof// Mesmo Codigo Nao requer amarracao SB1
		
		DbSelectArea("SB1")
		DbSetOrder(1)

		If DbSeek(xFilial("SB1")+oDet[i]:_Prod:_CPROD:TEXT)

			cProduto := Substr(oDet[i]:_Prod:_CPROD:TEXT,1,nTamProd)
			lRetorno := .T.
			aadd(aProdOk,{oDet[i]:_Prod:_CPROD:TEXT,oDet[i]:_Prod:_XPROD:TEXT} )

		Else         

			aadd(aProdNo,{oDet[i]:_Prod:_CPROD:TEXT,oDet[i]:_Prod:_XPROD:TEXT} )	

		EndIF

	EndIf

	cUm    := "  "

	cTagFci:= "oDet["+AllTrim(Str(i))+"]:_Prod:_UCOM:TEXT"

	if Type(cTagFci) <> "U"

		cUm := oDet[i]:_Prod:_UCOM:TEXT

	endif

	//FR - 04/05/2021 - prevendo qdo não vier a unidade de medida no xml - #10536 - Mectronics, NF complemento ICMS
	/*	
	If cUm = '0' .OR. cUm = 0
		cUm := "UN"
	Endif
	*/
	//Correção Type Missmatch do erro na linha If cUm = '0' .OR. cUm = 0 mantendo a logica q eu não entendi e nem quero entender	
	Do Case
		Case ValType(cUm) = "C"
			If cUm = '0' .Or. cUm = '00' 
				cUm := "UN"
			EndIf
		Case ValType(cUm) = "N"
			If cUm = 0
				cUm := "UN"
			EndIf
		Case ValType(cUm) = "U"
			cUm := "UN"
		Otherwise	
	EndCase
	//Fim Correção

	cTagTotIcm := "oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VICMS:TEXT"
	cTagTotIpi := "oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VIPI:TEXT"
	nvIcms     := 0
	nvIpi      := 0

	if type("cTagTotIcm") <> "U"

		nvIcms := Val( &cTagTotIcm ) 

	endif

	if type("cTagTotIcm") <> "U"

		nvIpi := Val( &cTagTotIpi ) 

	endif

	nQuant := 0 //VAL(oDet[i]:_Prod:_QCOM:TEXT)
	nVunit := 0 //VAL(oDet[i]:_Prod:_VUNCOM:TEXT)
	nTotal := VAL(oDet[i]:_Prod:_VPROD:TEXT)

	if cTpXml = "P" .And. nvIpi 

		nTotal := nvIpi 

	elseIf cTpXml = "I" .And. nvIcms > 0

		nTotal := nvIcms 

	else //Fadiga

		if nvIpi > 0
			nTotal := nvIpi 
		elseif  nvIcms > 0
			nTotal := nvIcms 
		endif

	endif

	nVdesc := 0
	cTagAux:= "oDet["+Alltrim(STR(i))+"]:_PROD:_VDESC:TEXT"

	if Type( cTagAux ) <> "U"  

		nVdesc := Val( oDet[i]:_Prod:_VDESC:TEXT )

	endif

	cCodFci:= ""
	cTagFci:= "oDet["+AllTrim(Str(i))+"]:_PROD:_NFCI:TEXT"  //CONFIRMAR ESTA TAG

	If Type(cTagFci) <> "U"

		cCodFci:= oDet[i]:_PROD:_NFCI:TEXT   //&cTagFci.

	EndIf

	aadd(aLinha,{"D1_ITEM"  ,StrZero(nD1Item,4)              ,Nil})
	aadd(aLinha,{"D1_COD"   ,cProduto               		 ,Nil})

	if SB1->( DbSeek(xFilial("SB1")+cProduto) )
		aadd(aLinha,{"D1_UM",SB1->B1_UM               		 ,Nil})
	Endif

	If SF4->( dbSeek( xFilial( "SF4" ) + cTes ) )
		cVLRZERO := SF4->F4_VLRZERO
	EndIf

	//aadd(aLinha,{"D1_QUANT" ,nQuant						 ,Nil})
	//aadd(aLinha,{"D1_VUNIT" ,nVunit						 ,Nil})
	if cVLRZERO <> "1"  //Se não permite zero tem que por a bagaça
		aadd(aLinha,{"D1_TOTAL" ,nTotal						 ,Nil})
	Endif

	aadd(aLinha,{"D1_TES"   ,cTes							 ,Nil})
	aadd(aLinha,{"D1_NFORI"	,cNfOri						     ,Nil})
	aadd(aLinha,{"D1_SERIORI",cSerOr						 ,Nil})

	If .Not. Empty(cCodFci)

		aadd(aLinha,{"D1_FCICOD",cCodFci					 ,Nil})

	EndIf

	if cPCSol != "Z"   //=> Com o Z não preenche o D1_CC, senão ao caso utilizar um gatilho poderia sobrepor o gatilho
		if !Empty( cCct )
			aadd(aLinha,{"D1_CC",cCct						 ,Nil})
		endif
	endif

	if nvIcms > 0

		//CST de origem
		aCST := FWGetSX5( "S2" ) //Tabela de CST no SX5

		For y := 1 To Len( aCST )

			//ICMS VALOR BASE - Produto
			//cTagAux:= "oDet["+AllTrim(str(I))+"]:_IMPOSTO:_ICMS:_ICMS" + alltrim(aCST[y,3]) + ":_VBC:TEXT"   //FR - 04/05/2021
			nbIcms := 0
			
			//FR - 04/05/2021 - #10536 - MECTRONICS - NF COMPLEMENTO ICMS - Não carregava os itens devido a um nó novo que tem no XML, o qual não estava contemplado aqui
			//ICMSSN900 - é o nó novo, então eu verifico aqui antes os nós para saber qual atribuição farei na tag de verificação:
			
			cTagAux := "oDet["+AllTrim(str(I))+"]:_IMPOSTO:_ICMS" //atribui até aqui, para saber se existe o nó ICMS00 , 10, 90 e assim por diante de acordo com todas as posições do array aCST
			
			If XmlChildEx( &(cTagAux) , "_ICMS" + alltrim(aCST[y,3])) <> NIL
				cTagAux := "oDet["+AllTrim(str(I))+"]:_IMPOSTO:_ICMS:_ICMS" + alltrim(aCST[y,3]) + ":_vBC:TEXT"
					
			ElseIf XmlChildEx( &(cTagAux) , "_ICMSSN900") <> NIL
				cTagAux := "oDet["+AllTrim(str(I))+"]:_IMPOSTO:_ICMS:_ICMSSN900:_vBC:TEXT"
					
			Endif

			if Type( cTagAux ) <> "U"   

				if VAL( ALLTRIM( &cTagAux ) ) > 0

					nbIcms := VAL( ALLTRIM( &cTagAux ) )

				else

					Loop
					
				ENDIF

			else
				
				Loop

			endif

			//cTagAux:= "oDet["+Alltrim(STR(i))+"]:_IMPOSTO:_ICMS:_ICMS" + alltrim(aCST[y,3]) + ":_PICMS:TEXT"  //FR - 04/05/2021
			npIcms := 0 
			
			//FR - 04/05/2021 - #10536 - MECTRONICS - NF COMPLEMENTO ICMS - Não carregava os itens devido a um nó novo que tem no XML, o qual não estava contemplado aqui
			//ICMSSN900 - é o nó novo, então eu verifico aqui antes os nós para saber qual atribuição farei na tag de verificação:
			
			cTagAux := "oDet["+AllTrim(str(I))+"]:_IMPOSTO:_ICMS" //atribui até aqui, para saber se existe o nó ICMS00 , 10, 90 e assim por diante de acordo com todas as posições do array aCST
			
			If XmlChildEx( &(cTagAux) , "_ICMS" + alltrim(aCST[y,3])) <> NIL
				cTagAux := "oDet["+AllTrim(str(I))+"]:_IMPOSTO:_ICMS:_ICMS" + alltrim(aCST[y,3]) + ":_PICMS:TEXT"
					
			ElseIf XmlChildEx( &(cTagAux) , "_ICMSSN900") <> NIL
				cTagAux := "oDet["+AllTrim(str(I))+"]:_IMPOSTO:_ICMS:_ICMSSN900:_PICMS:TEXT"
					
			Endif

			if Type( cTagAux ) <> "U"  
				npIcms := VAL( ALLTRIM( &cTagAux ) )
			endif

			//cTagAux:= "oDet["+Alltrim(STR(i))+"]:_IMPOSTO:_ICMS:_ICMS" + alltrim(aCST[y,3]) + ":_VICMS:TEXT"  //FR - 04/05/2021
			
			//FR - 04/05/2021 - #10536 - MECTRONICS - NF COMPLEMENTO ICMS - Não carregava os itens devido a um nó novo que tem no XML, o qual não estava contemplado aqui
			//ICMSSN900 - é o nó novo, então eu verifico aqui antes os nós para saber qual atribuição farei na tag de verificação:
			
			cTagAux := "oDet["+AllTrim(str(I))+"]:_IMPOSTO:_ICMS" //atribui até aqui, para saber se existe o nó ICMS00 , 10, 90 e assim por diante de acordo com todas as posições do array aCST
			
			If XmlChildEx( &(cTagAux) , "_ICMS" + alltrim(aCST[y,3])) <> NIL
				cTagAux := "oDet["+AllTrim(str(I))+"]:_IMPOSTO:_ICMS:_ICMS" + alltrim(aCST[y,3]) + ":_VICMS:TEXT"
					
			ElseIf XmlChildEx( &(cTagAux) , "_ICMSSN900") <> NIL
				cTagAux := "oDet["+AllTrim(str(I))+"]:_IMPOSTO:_ICMS:_ICMSSN900:_VICMS:TEXT"
					
			Endif

			if Type( cTagAux ) <> "U"  

				nvIcms2 := VAL( ALLTRIM( &cTagAux ) )
				//alert(nvIcms2)
				if nvIcms2 > 0
					nvIcms := nvIcms2 
				endif

			endif

			if nbIcms > 0
				aadd(aLinha,{"D1_BASEICM",nbIcms						 ,Nil})
			endif

			if npIcms > 0
				aadd(aLinha,{"D1_PICMS",npIcms						 	 ,Nil})
			endif

			if nvIcms > 0
				aadd(aLinha,{"D1_VALICMS",nvIcms					 	 ,Nil})
			endif

		Next y

	endif

	if nvIpi > 0 .and. cVLRZERO = "1"  //Só entra se for valor zerado, caso contrario não entra
		
		cTagAux:= "oDet["+Alltrim(STR(i))+"]:_IMPOSTO:_IPI:_IPITRIB:_VBC:TEXT"
		nbIpi := 0

		if Type( cTagAux ) <> "U"  
			nbIpi := Val( oDet[i]:_IMPOSTO:_IPI:_IPITRIB:_VBC:TEXT )
		endif

		cTagAux:= "oDet["+Alltrim(STR(i))+"]:_IMPOSTO:_IPI:_IPITRIB:_PIPI:TEXT"
		npIpi := 0

		if Type( cTagAux ) <> "U"  
			npIpi := Val( oDet[i]:_IMPOSTO:_IPI:_IPITRIB:_PIPI:TEXT )
		endif

		cTagAux:= "oDet["+Alltrim(STR(i))+"]:_IMPOSTO:_IPI:_IPITRIB:_VIPI:TEXT"

		if Type( cTagAux ) <> "U"  

			nvIpi := Val( oDet[i]:_IMPOSTO:_IPI:_IPITRIB:_VIPI:TEXT )

		endif

		if nbIpi > 0
			aadd(aLinha,{"D1_BASEIPI",nbIpi						 ,Nil})
		endif

		if npIpi > 0
			aadd(aLinha,{"D1_IPI",npIpi						 	 ,Nil})
		endif

		if nvIpi > 0
			aadd(aLinha,{"D1_VALIPI",nvIpi						 	 ,Nil})
		endif

	endif

	If lXMLPEITE   //PE para incluir campos no aLinha SD1 -> para o aItens

		aRet :=	ExecBlock( "XMLPEITE", .F., .F., { cProduto,oDet,i } )

		If ValType(aRet) == "A"
			AEval(aRet,{|x| AAdd(aLinha,x)})
		EndIf

	endif

	if .not. empty( cProduto )

		if SB1->( DbSeek(xFilial("SB1")+cProduto) )

			If SB1->( FieldGet(FieldPos("B1_MSBLQL")) ) == "1"
				aadd(aProdNo,{cProduto,"Produto Bloqueado SB1->"+SB1->B1_DESC} )
			EndIf

		ElseIf cTipoCPro != "3"

			aadd(aProdNo,{cProduto,"Não Cadastrado SB1->"+oDet[i]:_Prod:_XPROD:TEXT} )

		endif

	EndIf

	if nVunit <= 0 //Não mostrar
		//aadd(aProdZr, { StrZero(i,4), oDet[i]:_Prod:_CPROD:TEXT, cProduto, nVunit, oDet[i]:_Prod:_XPROD:TEXT } )
	endif

	//if nVunit > 0 //permitir valor unitário maior zero
	aadd(aItens,aLinha)

	nD1Item++

	aadd(aItXml,{StrZero(i,4),oDet[i]:_Prod:_CPROD:TEXT,oDet[i]:_Prod:_XPROD:TEXT})

	//endif
	aLinha := {}
	//Exit

Next i


//Itens não encontrados
if .not. U_HFITNENC( "PREN", aProdOk, aProdNo, aProdVl, @nErrItens, aProdZr )
	lRetorno := .F.
endif

nIte := nD1Item

Return( lRetorno )


User Function VERAMARR()

Local aProdOk   := {}
Local aProdNo   := {}
Local aProdVl   := {}
Local aProdZr   := {}
Local nErrItens := 0
Local nTamProd  := TAMSX3("B1_COD")[1]
Local nTamCc    := TAMSX3("D1_CC")[1]
Local lFound    := .F.
Local lRet      := .T.
Local aLinha := {}
Local lXMLPEAMA   := ExistBlock( "XMLPEAMA" ), aPEAma, lAmaPe := .F. //nordsonAmarraCof
Local lXMLPEVAL   := .F. //ExistBlock( "XMLPEVAL" )
Local lXMLPEREG   := .F. //ExistBlock( "XMLPEREG" )
Local lXMLPEATU   := .F. //ExistBlock( "XMLPEATU" )
Local lXMLPE2UM   := ExistBlock( "XMLPE2UM" )
Local lXMLPEITE   := ExistBlock( "XMLPEITE" )
Local lXMLPELOK   := ExistBlock( "XMLPELOK" )
Local lXMLPETOK   := ExistBlock( "XMLPETOK" )
Local lLOk 		  := .T.
Local lTOk 		  := .T.
Local i

Private oDet
Private aParam := {}
Private cCodEmit  := cCodFor  //tem que vir como private
Private cLojaEmit := cLojFor  //tem que vir como private
Private nFormSer  := Val(GetNewPar("XM_FORMSER","0")) ///Incluido 19/01/2016

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

cAmarra := iif( cAmarra $ "4,5", "0", cAmarra )

aParam   := {" "}
cParXMLExp := cNumEmp+"IMPXML"
cExt     := ".xml"
cNfes    := ""

aAdd( aCombo, "1=Padrão(SA5/SA7)" )
aAdd( aCombo, "2=Customizada("+xZB5+")")
aAdd( aCombo, "3=Sem Amarração"   )

aadd(aPerg,{2,"Amarração Produto","",aCombo,120,".T.",.T.,".T."})

aParam[01] := ParamLoad(cParXMLExp,aPerg,1,aParam[01])

If cAmarra == "0"

	If !ParamBox(aPerg,"Importa XML - Amarração",@aParam,,,,,,,cParXMLExp,.T.,.T.)

		lRet := .F.

	Else 

   		cAmarra  := aParam[01]

	EndIf

EndIf

if lRet

	cError := ""
	cWarning := ""
	DbSelectArea( xZBZ )

	cXml := NoAcento((xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML"))))
	cXml := EncodeUTF8(cXml)

	//Faz backup do xml sem retirar os caracteres especiais
	cBkpXml := cXml

	//Executa rotina para retirar os caracteres especiais
	cXml := u_zCarEspec( cXml )

	oXml := XmlParser(cXml, "_", @cError, @cWarning )

	//retorna o backup do xml
	cXml := cBkpXml

	if oXml = NIL .Or. !Empty(cError) .Or. !Empty(cWarning)

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

			Return( .F. )
			
		endif

	Endif

	cTipoCPro := cAmarra
	aCabec := {}
	aadd(aCabec,{"F1_TIPO"   ,(xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC"))) })
	aadd(aCabec,{"F1_FORMUL" ,"N"})

	cTagRefNfe := "oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_NFREF:_REFNFE:TEXT"
	cChvReg := ""

	if type(cTagRefNfe) <> "U"

		cChvReg := &(cTagRefNfe)
		_xNOr   := Substr(cChvReg,26,9)
		_xSOr   := Substr(cChvReg,23,3)  //esta com 3 zeros

		if nFormSer = 2

			if Val(_xSOr) <= 99
				_xSOr := StrZero(Val(_xSOr),2,0)+" "
			endif

		elseif nFormSer = 0

			_xSOr := Substr(AllTrim(Str(Val(_xSOr),15,0))+space(3),1,3)

		Endif

	else

		_xNOr := Space(9)
		_xSOr := "   "

	endif

	DbSelectArea( xZBZ )
	oDet := oXml:_NFEPROC:_NFE:_INFNFE:_DET
	oDet := IIf(ValType(oDet)=="O",{oDet},oDet)

	nD1Item := 1

	For i := 1 To len(oDet)

		If lXMLPEAMA      //PE para Amarração de podrutos  //nordsonAmarraCof
			
			aPEAma := ExecBlock( "XMLPEAMA", .F., .F., { oDet,i,oDet[i]:_Prod:_CPROD:TEXT,cModelo,cTipoCPro } )

			if aPEAma == NIL .or. ValType(aPEAma) <> "A"

				cProduto := ""
				lAmaPe := .F.

			Else

				if len(aPEAma) >= 1

					cProduto := aPEAma[1]

				Else

					cProduto := ""

				endif

				if len(aPEAma) >= 2

					if .NOT. Empty(cProduto)
						aadd( aProdOk, aPEAma[2] )
					Else
						aadd( aProdNo, aPEAma[2] )
					Endif

				else
				
					if .NOT. Empty(cProduto)
						aadd( aProdOk, {oDet[i]:_Prod:_CPROD:TEXT,oDet[i]:_Prod:_XPROD:TEXT} )
					Else
						aadd( aProdNo, {oDet[i]:_Prod:_CPROD:TEXT,oDet[i]:_Prod:_XPROD:TEXT} )
					Endif

				endif

				lAmaPe := .T.

			endif

		else

			lAmaPe := .F.

		EndIf

		//Produto Inteligente - 18/07/2020 - Rogerio Lino
		if cTipoCpro == "6" .and. !lAmaPe

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

		If cTipoCPro == "2" .And. ! lAmaPe  //nordsonAmarraCof// Ararracao Customizada ZB5 Produto tem que estar Amarrados Tanto Cliente como Formecedor
			
			cProduto := ""

			If aCabec[1][2] $ "D|B"

				DbSelectArea(xZB5)
				DbSetOrder(2)
				
				// Filial + CNPJ CLIENTE + Codigo do Produto do Fornecedor
				If DbSeek(xFilial(xZB5)+PADR((xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))),14)+oDet[i]:_Prod:_CPROD:TEXT)
					
					cProduto := (xZB5)->(FieldGet(FieldPos(xZB5_+"PRODFI"))) //ZB5_PRODFI
					lRet := .T.
					aadd(aProdOk,{oDet[i]:_Prod:_CPROD:TEXT,oDet[i]:_Prod:_XPROD:TEXT} )

				Else

					aadd(aProdNo,{oDet[i]:_Prod:_CPROD:TEXT,oDet[i]:_Prod:_XPROD:TEXT} )

				EndIf

			Else

				DbSelectArea(xZB5)
				DbSetOrder(1)
				
				// Filial + CNPJ FORNECEDOR + Codigo do Produto do Fornecedor
				If DbSeek(xFilial(xZB5)+PADR((xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))),14)+oDet[i]:_Prod:_CPROD:TEXT)
					
					cProduto := (xZB5)->(FieldGet(FieldPos(xZB5_+"PRODFI"))) //ZB5_PRODFI
					lRet := .T.
					aadd(aProdOk,{oDet[i]:_Prod:_CPROD:TEXT,oDet[i]:_Prod:_XPROD:TEXT} )
				
				Else

					aadd(aProdNo,{oDet[i]:_Prod:_CPROD:TEXT,oDet[i]:_Prod:_XPROD:TEXT} )

				EndIf

			EndIF

		//##################################################################
		ElseIf cTipoCPro == "1" .And. ! lAmaPe  //nordsonAmarraCof// Amarracao Padrao SA5/SA7

			If aCabec[1][2] $ "D|B" // dDevolução / Beneficiamento ( utiliza Cliente )

				cProduto  := ""

				if empty( cCodEmit )

					cCodEmit  := Posicione("SA1",3,xFilial("SA1")+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))),"A1_COD")
					cLojaEmit := Posicione("SA1",3,xFilial("SA1")+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))),"A1_LOJA")
				
				endif

				cAliasSA7 := GetNextAlias()

				cWhere := "%(SA7.A7_CODCLI IN ("
				cWhere += "'"+TrocaAspas( AllTrim(oDet[i]:_Prod:_CPROD:TEXT) )+"'"
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

		        cKeySa7:= xFilial("SA7")+cCodEmit+cLojaEmit+TrocaAspas( oDet[i]:_Prod:_CPROD:TEXT )
		        
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
					lRet := .T.
					aadd(aProdOk,{TrocaAspas( oDet[i]:_Prod:_CPROD:TEXT ),oDet[i]:_Prod:_XPROD:TEXT} )
				
				Else

					aadd(aProdNo,{TrocaAspas( oDet[i]:_Prod:_CPROD:TEXT ),oDet[i]:_Prod:_XPROD:TEXT} )

				EndIf

				DbCloseArea()

			Else

				cProduto  := ""
				
				if empty( cCodEmit )

					cCodEmit  := Posicione("SA2",3,xFilial("SA2")+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))),"A2_COD")
					cLojaEmit := Posicione("SA2",3,xFilial("SA2")+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))),"A2_LOJA")
				
				endif

				cAliasSA5 := GetNextAlias()

				cWhere := "%(SA5.A5_CODPRF IN ("				               
				cWhere += "'"+TrocaAspas( AllTrim(oDet[i]:_Prod:_CPROD:TEXT) )+"'"
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

		        cKeySa5:= xFilial("SA5")+cCodEmit+cLojaEmit+TrocaAspas( oDet[i]:_Prod:_CPROD:TEXT )
		        
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
					lRet := .T.
					aadd(aProdOk,{TrocaAspas( oDet[i]:_Prod:_CPROD:TEXT ),oDet[i]:_Prod:_XPROD:TEXT} )
				
				Else 

					aadd(aProdNo,{TrocaAspas( oDet[i]:_Prod:_CPROD:TEXT ),oDet[i]:_Prod:_XPROD:TEXT} )				
				
				EndIf

				DbCloseArea()

			EndIF          		

		//##################################################################
		ElseIf cTipoCPro = "3"   .And. ! lAmaPe   //nordsonAmarraCof// Mesmo Codigo Nao requer amarracao SB1
			
			DbSelectArea("SB1")
			DbSetOrder(1)
			If DbSeek(xFilial("SB1")+oDet[i]:_Prod:_CPROD:TEXT)

				cProduto := Substr(oDet[i]:_Prod:_CPROD:TEXT,1,nTamProd)
				lRet := .T.
				aadd(aProdOk,{oDet[i]:_Prod:_CPROD:TEXT,oDet[i]:_Prod:_XPROD:TEXT} )

			Else      

				aadd(aProdNo,{oDet[i]:_Prod:_CPROD:TEXT,oDet[i]:_Prod:_XPROD:TEXT} )	

			EndIF

		EndIf

		cUm    := "  "
		cTagFci:= "oDet["+AllTrim(Str(i))+"]:_Prod:_UCOM:TEXT"

		if Type(cTagFci) <> "U"
			cUm := oDet[i]:_Prod:_UCOM:TEXT
		endif

		nQuant := VAL(oDet[i]:_Prod:_QCOM:TEXT)
		nVunit := VAL(oDet[i]:_Prod:_VUNCOM:TEXT)
		nTotal := VAL(oDet[i]:_Prod:_VPROD:TEXT)
		nVdesc := 0

		cTagAux:= "oDet["+Alltrim(STR(i))+"]:_PROD:_VDESC:TEXT"

		if Type( cTagAux ) <> "U" 

			nVdesc := Val( oDet[i]:_Prod:_VDESC:TEXT )

		endif


        cCodFci:= ""
        cTagFci:= "oDet["+AllTrim(Str(i))+"]:_PROD:_NFCI:TEXT"  //CONFIRMAR ESTA TAG
        If Type(cTagFci) <> "U"
			cCodFci:= oDet[i]:_PROD:_NFCI:TEXT //&cTagFci.
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

		cXped     := Space(6) //Privates e fazer as bagaceiras da Carajas, tem o oXml private também para usar la
		cXItemPed := ""
		If lXMLPEVAL
			IF ! Empty(cProduto)  //Só se passou pela amarração
				if lXMLPEREG
					aRet :=	ExecBlock( "XMLPEREG", .F., .F., { "I", cChaveXml, cProduto,oDet,i, nQuant, nVunit, nTotal } )
					If ValType(aRet) == "A"
						AEval(aRet,{|x| AAdd(aIteErr,x)})
					EndIf
				Endif
			EndIF
		EndIF

		aadd(aLinha,{"D1_ITEM"  ,StrZero(nD1Item,4)              ,Nil})
		aadd(aLinha,{"D1_COD"   ,cProduto               		 ,Nil})
		aadd(aLinha,{"D1_QUANT" ,nQuant							 ,Nil})
		aadd(aLinha,{"D1_VUNIT" ,nVunit							 ,Nil})
		aadd(aLinha,{"D1_TOTAL" ,nTotal							 ,Nil})

		if nVdesc > 0
			aadd(aLinha,{"D1_VALDESC" ,nVdesc					 ,Nil})
		endif

		if cPCSol == "S"  //Centro de Custo do Pedido, então manda vazio para pegar do pedido ao relacionar o pedido F5 ou F6
			aadd(aLinha,{"D1_CC"    ,nTamCc 					 ,Nil})
		elseif cPCSol != "Z"   //=> Com o Z não preenche o D1_CC, senão ao caso utilizar um gatilho poderia sobrepor o gatilho
			if .not. empty( cProduto ) .And. SB1->( DbSeek(xFilial("SB1")+cProduto) )
				aadd(aLinha,{"D1_CC",SB1->B1_CC					 ,Nil})
			endif
		endif

		If .Not. Empty(cCodFci)
			aadd(aLinha,{"D1_FCICOD",cCodFci					 ,Nil})
		EndIf

		If lXMLPEITE   //PE para incluir campos no aLinha SD1 -> para o aItens
   			aRet :=	ExecBlock( "XMLPEITE", .F., .F., { cProduto,oDet,i } )
			If ValType(aRet) == "A"
				AEval(aRet,{|x| AAdd(aLinha,x)})
			EndIf
 		endif

		if .not. empty( cProduto )
	 		if SB1->( DbSeek(xFilial("SB1")+cProduto) )
 				If SB1->( FieldGet(FieldPos("B1_MSBLQL")) ) == "1"
	 				aadd(aProdNo,{cProduto,"Produto Bloqueado SB1->"+SB1->B1_DESC} )
 				EndIf
	 		ElseIf cTipoCPro != "3"
 				aadd(aProdNo,{cProduto,"Não Cadastrado SB1->"+oDet[i]:_Prod:_XPROD:TEXT} )
 			endif
 			_xTes := SB1->B1_TE  //Para CPL
 			_xCc  := SB1->B1_CC  //Para CPL
  			If lXMLPELOK   //PE para validar o aItens
 				lLOk :=	ExecBlock( "XMLPELOK", .F., .F., { cModelo,cProduto,oDet,i } )
 				If ValType(lLOk) <> "L"
 					Alert( "Ponto de entrada XMLPELOK deve Retornar .T. ou .F." )
 					lLOk := .F.
 				EndIf
 				if ! lLOk
 					Exit
 				Endif
 			Endif
 
 		EndIf

 		if nVunit <= 0 //Não mostrar
			//aadd(aProdZr, { StrZero(i,4), oDet[i]:_Prod:_CPROD:TEXT, cProduto, nVunit, oDet[i]:_Prod:_XPROD:TEXT } )
 		endif

 		if nVunit > 0 //permitir valor unitário maior zero
	 		aadd(aItens,aLinha)
	 		nD1Item++
		 	aadd(aItXml,{StrZero(i,4),oDet[i]:_Prod:_CPROD:TEXT,oDet[i]:_Prod:_XPROD:TEXT})
	 	endif
		aLinha := {}

	Next i

	If lXMLPELOK   //PE Linha OK para validar os Itens
 		if ! lLOk  //Não Validou o Bixo
 			lRet := .F.
 		Endif
 	Endif

	If lRet .And. lXMLPETOK   //PE para incluir campos no aLinha SD1 -> para o aItens
 		lTOk :=	ExecBlock( "XMLPETOK", .F., .F., { cModelo } )
 		If ValType(lTOk) <> "L"
 			Alert( "Ponto de entrada XMLPETOK deve Retornar .T. ou .F." )
 			lTOk := .F.
 		EndIf
 		if ! lTOk
 			lRet := .F.
 		Endif
	Endif

//Itens não encontrados
	if lRet
		if .not. U_HFITNENC( "PREN", aProdOk, aProdNo, aProdVl, @nErrItens, aProdZr )
		    lRet := .F.
		Else
		    lRet := .T.
		endif
	endif

EndIf

Return( lRet )


Static Function TrocaAspas( cCod )

Local cRet := cCod

cRet := StrTran(cRet,"'",'"')  //troca ' por " -> Isto serve para quando o código do produto vem com ', pois o SA5/SA7 é feito query a qual utiliza-se de '

Return( cRet )


Static Function __Dummy(lRecursa) //warning W0010 Static Function <?> never called

    lRecursa := .F.

    IF (lRecursa)

        __Dummy(.F.)
        U_XMLCPL()
        U_VERAMARR()

	EndIF

Return(lRecursa)
