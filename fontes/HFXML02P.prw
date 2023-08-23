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
#INCLUDE "TOPCONN.CH"
#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HFXML02P  º Autor ³ Roberto Souza      º Data ³  12/09/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ XML dos Fornecedores                                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Importa Xml                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

//--------------------------------------------------------------//
//FR - 08/05/2020 - Alterações realizadas para adequar na rotina 
//                  Pré Auditoria Fiscal verificação de 
//                  divergências entre XML x NF 
//-------------------------------------------------------------//
//FR - 28/05/2020 - Alterações realizadas para adequar ao uso do 
//                  Ponto de Entrada MT100TOK 
//                  (qdo utilizado pelo cliente) 
//-------------------------------------------------------------------------//
//FR - 09/06/2020 - Alterações realizadas para adequar nova opção para 
//                  "gera nota fiscal direto"
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
//FR - 22/06/2020 - Tratativa para povoar o array de TES 
//                 Criar primeiramente a linha com o conteúdo TES = vazio
//                 depois povoa o conteúdo com o TES do pedido de compra ou
//                 cadastro do produto.  
//--------------------------------------------------------------------------// 
//FR - 28/07/2020 - Chamado 5274 - Aguas do Brasil 
//                  Correção da chamada da tela para selecionar Ped. Compra
//                  via função HFXMLPED, estava sendo chamada 2x 
//                  sem necessidade
//--------------------------------------------------------------------------//   
//FR - 06/08/2020 - Função para redownload de xml resumido na geração da 
//                  Pré-Nota / NF
//--------------------------------------------------------------------------//
//FR - 02/10/2020 - Trazer retorno da SEFAZ após o redownload na geração da 
//					pré-nota
//--------------------------------------------------------------------------//   
//FR - 16/10/2020 - Solicitações Rafael:
//			     	Tratativa no redownload na geração da pré-nota,
//                  gravação dos novos campos:
//                  ZBZ_DREDOW: Dt último redownload
//                  ZBZ_HREDOW: Hr.último redownload
//                  Atualizar o status da chave na ZBS quando o resultado 
//                  for 137 - Download indisponível
//--------------------------------------------------------------------------// 
//FR - 28/12/2020 - #5922 - Chamado Razzo - Tratativa para incluir informação 
//                  do número da OS no item da NF
//--------------------------------------------------------------------------//    
//FR - 08/02/2021 - #6170 - MaxiRubber - correção do retorno da função 
//                  EncodeUTF8 nulo
//--------------------------------------------------------------------------//    
//FR - 02/03/2021 - #6272 - Mectronics - correção para trazer nos itens,
//                  o número da nf / série original 
//--------------------------------------------------------------------------//    
//NA - 02/03/2021 - Projeto Nordson - criação de parâmetro para tela F12 
//                  XM_CENTRO - este parâmetro será utilizado pela rotina 
//                  Múltiplos CTE - rege se a rotina buscará o centro de 
//                  custo da NF Saída (SD2) Ou do cadastro de produto (SB1).
//--------------------------------------------------------------------------//   
//FR - 09/03/2021 - #10274 - CCM - tratativa para sujeira no xml no último 
//                  caracter
//--------------------------------------------------------------------------//     
//FR - 30/03/2021 - #10372 - Mectronics - correção para trazer nos itens,
//                  o número da nf / série original (estrutura do xml diferente)
//--------------------------------------------------------------------------//
//FR - 31/03/2021 - Carregar número de lote do fornecedor na geração da nota
//                  Solicitado por Rafael Lobitsky
//--------------------------------------------------------------------------//
//FR - 18/06/2021 - Retorno da rotina SF3DACHAVE , aRet array com 3 posições  
//--------------------------------------------------------------------------//     
//FR - 04/11/2021 - #11460 - ADAR - ao visualizar nf via ImportaXML, mostra
//                  uma outra nota de mesmo número e fornecedor, porém emissao
//                  diferente, e a chave estava em branco no F1_CHVNFE         
//                  correção para validar com a emissão do XML x NF
//---------------------------------------------------------------------------//
//FR - 24/11/2021 - #11571 - WINDROSE - correção error log qdo gera pré-nota
//argument error in function Len() on U_IMPXMLFOR(HFXML02P.PRW) 28/10/2021 
//12:10:36 line : 1353
//Erro ocorria porque nem sempre a informação sobre o numero de lote está
//em um array, as vezes vem só na tag direto
//Correção: inserida checagem da tag para ver se é array ou não
//---------------------------------------------------------------------------//
//FR - 07/12/2021 - Projeto Kitchens - Solicitado por Rafael Lobitsky
//                  Inclusão de rotina para geração de pedido compra
//                  Adaptar chamada tela amarração U_ITNAOENC 
//                  para ser chamada do HFXML08PC
//---------------------------------------------------------------------------//
//FR - 03/02/2022 - #11864 - PETRA , trazer valor das despesas do item
//---------------------------------------------------------------------------//
//FR - 10/03/2022 - ALTERAÇÃO - TransUnião - não estava amarrando ZB5
//---------------------------------------------------------------------------//
//FR - 29/08/2022 - ECO AUTOMAÇÃO - CHAMADO #13333
//                  Quando a tag XPED já vier com o pedido, apenas validar 
//                  se existe e já amarrar ao item
//                  Sem que haja obrigação da amarração por produto estar = "4"
//---------------------------------------------------------------------------//
//FR - 26/05/2023 - TESTE COMMIT BRANCH FLÁVIA ROCHA
User Function HFXML02P()

Local lOk      := .T.     
Local aArea    := GetArea()
Local cMsg     := "Gerando Documento ..."
Local cError   := "", cWarning := ""
Local cFinNfe1 := ""
Local cTip     := ""
Local nTip     := 0
Local cPNfCpl  := GetNewPar("XM_PNFCPL","1")
Local oXmlMod
Local xRetSEF  := ""		//FR - 02/10/2020

Private cTagFinNfe1 := ""

If (xZBZ)->(FieldPos(xZBZ_+"STATUS")) > 0 .And. (xZBZ)->(FieldGet(FieldPos(xZBZ_+"STATUS"))) <> "1"  //Ja tinha antes 18/8/18
	
	//Proceder consulta do Bixo 
	//if GetNewPar("XM_DFE","0") $ "0,1"
		U_HFXML02X( ,,,.T. )
	//else
		//U_HFXML16X( ,,,.T. )
	//endif

ElseIf ( GetNewPar("XM_SEFPRN", "N") == "S" )

	//Proceder consulta do Bixo em 18/08. Consulta Todos mas não mostra Tela.
	//if GetNewPar("XM_DFE","0") $ "0,1"
		U_HFXML02X( ,,,.F. )
	//else
	//	U_HFXML16X( ,,,.F. )
	//endif

endif

If (xZBZ)->(FieldPos(xZBZ_+"STATUS"))>0 .And. lOk
	If (xZBZ)->(FieldGet(FieldPos(xZBZ_+"STATUS"))) <>"1"
		lOk:= .F.
   		MsgStop("Esta rotina não pode ser executada em um registro com erros na importação ou cancelado.")
	EndIf	
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

	lRedown := .F.	//FR - 02/10/2020
	xChave  := ""
	xChave  := Alltrim( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))) )

	If (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOWL"))) = "R"

		If U_MyAviso("ReDownLoad Resumido","Esse XML é Resumido. Deseja Tentar o Download do XML completo para prosseguir?",{"SIM","NAO"},3) = 1
			//U_HFDGXML( AllTrim( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))) ), .T. , .F. ,  NIL    ,"", 0, "2"  )  
			//If U_FREDownXML(Alltrim( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))) ) )		//FR - 06/08/2020
			
			Processa( {|| lRedown := U_FREDownXML( xChave ) }, "Aguarde...", "Redownload",.F.)
			
			If lRedown
				MsgInfo("ReDownLoad Realizado Com Sucesso")
			Else
				xRetSef := U_fVerZBE(xChave , "E" )       //"E"-erro	
				MsgAlert("Falha no ReDownLoad -> " + xRetSEF)			
				lOk := .F.
				
				/*If "137" $ xRetSef
					//atualiza registro na ZBS para aparecer na tela de download 137					
					If U_fAtu137(xChave)
						MsgInfo("Em caso de " + xRetSef + ", " + CRLF + "Por Favor, Utilize a Rotina 'Download Indisponível 137' ")
					Endif
				Endif*/
			Endif
			
		Endif

	Endif
	/*		//FR - 02/10/2020 - já é informado acima o motivo
	If (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOWL"))) = "R"
		lOk:= .F.   
		MsgStop("Este XML é Resumido, não gera pré-nota.")
	Endif
	*/
Endif

If (xZBZ)->(FieldPos(xZBZ_+"PROTC"))>0  .And. AllTrim( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"PROTC"))) ) <> ""
	lOk:= .F.   
	MsgStop("Este xml foi cancelado pelo emissor.Não pode ser gerada a pré-nota.")
EndIf

If Empty( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR"))) ) .Or. Empty( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR"))) )
	lOk:= .F.   
	MsgStop("Este XML não possui fornecedor associado. Clique em Ações Relacionadas / Funções XML / Alterar e Associe o Fornecedor de Acordo com o CNPJ. Caso não Tenha Fornecedor Cadastrado com o CNPJ, faça-o no Cadastro de Fornecedor.")
EndIf

If (xZBZ)->(FieldGet(FieldPos(xZBZ_+"INDRUR"))) > "0" .And. lOk
	//lOk:= .F.   
	//MsgStop("Este XML é NF de Produtor Rural. Não pode ser gerada a pré-nota.")
EndIf

//FR - 08/02/2021 - #6170 - MaxiRubber
_cBkpXml := ""
cOcorr   := ""
lInvalid := .F.
cModelo  := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO")))
//FR - 08/02/2021
If lOk

	cXMLExp := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML")))

	If (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO"))) $ "55" .And. (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC"))) = "N" .and. cPNfCpl $ "1,3"
		
		//-------------------------------------------------------------------------------------------------------//
		//FR - 08/02/2021 - a função "NoAcento" não estava declarada aqui neste fonte, então copiei 
		//e transformei para User Function, porque mesmo não estando declarada anteriormente, 
		//não ocorria erro, o que ao meu ver, é provavel que haja alguma função padrão Totvs com nome semelhante, 
		//por isso não ocorria erro na execução, mas também o retorno não era o esperado, causando retorno nulo
		//quando a string era passada pela função EncodeUTF8()
		//-------------------------------------------------------------------------------------------------------//
		cXml := U_fNoAcento(cXMLExp)		//FR - 08/02/2021 - nova função "NoAcento" por precaução mudei o nome											
			cXMLExp := cXml
		
		//Faz backup do xml sem retirar os caracteres especiais
		cBkpXml := cXml	

		//Executa rotina para retirar os caracteres especiais
		cXml := u_zCarEspec( cXml )		//FR - 08/02/2021 - #6170 - MaxiRubber - error log após encodeutf8 deixa xml nulo

		//Faz backup do xml já retirados os caracteres especiais
		_cBkpXml := cXml				//FR - 08/02/2021 - #6170 - MaxiRubber

        cAux := Substr(cXml,Len(cXml), 1)        		//FR - 10274 - CCM - 09/03/2021 - pega a última posição
        If cAux != ">"                                  //verifica se a última posição é diferente do sinal de "maior", se não for:
            cXml := Substr(cXml,1,Len(cXml) -1 )        //refaço o cXml para receber todo o conteúdo da string menos o último caracter
        Endif
		oXmlMod := XmlParser(cXml, "_", @cError, @cWarning )

		If oXmlMod == NIL .Or. !Empty(cError) .Or. !Empty(cWarning)
			//MsgInfo("Nulo, continua")		//FR - 08/02/2021 - para testes
		Endif
		
		//FR - 08/02/2021 - #6170 - MaxiRubber
		cXml := EncodeUTF8(cXml)	//FR - 08/02/2021 - colocado aqui após função zCarEspec e backup do xml, 
									//esta função estava retornando nulo após passada pela função "NoAcento", 
									//por isso adaptei esta função para User Function fNoAcento	no final deste fonte
		
		If cXml == Nil				//se ficar nulo, volto o backup, no caso aqui, ficava nulo devido ao explicado acima, agora deixei só por precaução este "if"
			cXml := _cBkpXml		//FR - volta o backup sem os caracteres especiais
		Endif
		//FR - 08/02/2021 - #6170 - MaxiRubber

		//FR - 08/02/2021 - se passar deste parse e ficar em formato objeto, seguirá perfeita geração da pré-nota.
		oXmlMod := XmlParser(cXml, "_", @cError, @cWarning )
		
		If oXmlMod == NIL .Or. !Empty(cError) .Or. !Empty(cWarning)
			MsgSTOP("XML Invalido ou Não Encontrado, a Importação Não foi Efetuada.")
			RestArea(aArea)
			Return
		EndIf
		
		cTagFinNfe1 := "oXmlMod:_NFEPROC:_NFE:_INFNFE:_IDE:_FINNFE:TEXT"
		cFinNfe1    := "" 
		if type("cTagFinNfe1") <> "U"
			cFinNfe1 := &(cTagFinNfe1)
		endif
		if cFinNfe1 = "2"
			cTip := U_VERIPIICM(oXmlMod)
			if cTip <> "N"
				if cPNfCpl $ "3"
					nTip := U_MyAviso("Tipo de NFe","Esse XML é de complemento de "+iif(cTip="I","Icms","Ipi")+". Deseja alterar o seu tipo e assim gerar o Documento de Entrada Direto?",{"SIM","NAO"},3)
				else
					nTip := 1
				endif
				if nTip = 1
					dbSelectArea(xZBZ)
					RecLock(xZBZ,.F.)
					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPDOC"), cTip ))
					(xZBZ)->( MsUnlock() )
				endif
			Endif
		endif
		
	Elseif (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO"))) $ "55" .And. (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC"))) $ "P,I" .and. cPNfCpl $ "2,3"
		
		cTip := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC")))
		if cPNfCpl $ "3"
			nTip := U_MyAviso("Tipo de NFe","Esse XML é de complento de "+iif(cTip="I","Icms","Ipi")+". Deseja alterar o seu tipo e gerar Pré-Nota com Tipo Normal ou gerar Documento de Entrada Direto com Tipo de Complemento via ExecAuto?",{"Pré-Nota","Documento Entrada"},3)
		else
			nTip := 1
		endif
		
		if nTip = 1
			dbSelectArea(xZBZ)
			RecLock(xZBZ,.F.)
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPDOC"), "N" ))
			(xZBZ)->( MsUnlock() )
		endif
	Endif


	If (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO"))) $ "55,65,RP"
		
		if (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC"))) $ "IP"  //Complemento
			cMsg += "Complemento"
			Processa( {|| U_XMLCPL()  }, "Aguarde...", cMsg,.F.)
		Else
			Processa( {|| U_IMPXMLFOR() }, "Aguarde...", cMsg,.F.)
		Endif
		
   	ELseIf (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO"))) $ "57,67"
		
		Processa( {|| U_IMPXMLFOR() }, "Aguarde...", cMsg,.F.)
    
    EndIf

EndIf
                       
RestArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IMPXMLFOR º Autor ³ Roberto Souza      º Data ³  11/04/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ XML dos Fornecedores                                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Importa XML                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function IMPXMLFOR()

//Local aVetor	  := {}
//Local aPedaco	  := {}
Local cError      := ""
Local cWarning    := ""
Local lRetorno    := .F.
Local aLinha      := {}
Local nX          := 0
//Local nY          := 0
//Local cDoc        := ""
//Local lOk         := .T.
Local aProdOk     := {}
Local aProdNo     := {}
Local aProdVl     := {}
Local aProdZr     := {}
//Local oDlg
Local aArea       := GetArea()
Local nTamProd    := TAMSX3("B1_COD")[1]
//Local nTamPed     := TAMSX3("C7_NUM")[1]
Local nTamIte     := TAMSX3("C7_ITEM")[1]
Local lPergunta   := .F.
Local cTesPcNf    := GetNewPar("MV_TESPCNF","") // Tes que nao necessita de pedido de compra amarrado
Local cTesB1PcNf  := ""
Local lPCNFE      := GetNewPar("MV_PCNFE",.F.)
Local lXMLPE2UM   := ExistBlock( "XMLPE2UM" )
Local lXMLPEITE   := ExistBlock( "XMLPEITE" )
Local lXMLPELOK   := ExistBlock( "XMLPELOK" )
Local lXMLPETOK   := ExistBlock( "XMLPETOK" )
Local lLOk 		  := .F.
Local lTOk 		  := .F.
Local nQuant      := 0
Local nVunit      := 0
Local nVdesc      := 0
Local lXMLPEAMA   := ExistBlock( "XMLPEAMA" ), aPEAma, lAmaPe := .F. //nordsonAmarraCof
Local lXMLPEVAL   := ExistBlock( "XMLPEVAL" )
Local lXMLPEREG   := ExistBlock( "XMLPEREG" )
Local lXMLPEATU   := ExistBlock( "XMLPEATU" )
Local nTotal      := 0
Local cUm         := "  "
Local nErrItens   := 0
Local nD1Item     := 0
Local oIcm, _cCc  := ""
Local cKeyFe	  := SetKEY( VK_F3 ,  Nil )
Local cMunIni	  := ""
Local UFIni       := ""
Local cMunFim	  := ""
Local UFFim       := ""
Local aTotal      := {}
Local nTotNfe     := 0
Local lSemNfe     := .F.
Local lAvulsa     := .F.
Local i           := 0
Local y           := 0
Local fr          := 0
Local cManif      := ""		                     //FR - 08/09/2020
Local cManPre     := GetNewPar("XM_MANPRE","N")  //Verifica qual tipo de manifestação
Local cTipoCTE    := ""
Local cMUORITR    := ""
Local cUFORITR    := ""
Local cMUDESTR    := ""
Local cUFDESTR    := ""
Local nTamCc      := TAMSX3("D1_CC")[1]
Local cTipo_CTE   := ""
Local nTotFre     := 0
Local nAuxFret    := 0

Local dEmiXML     := Ctod("  /  /    ") 	//FR - 04/11/2021 - #11460 - ADAR
Local nVdesp      := 0  					//FR - 03/02/2022 - #11864 - PETRA , trazer valor das despesas do item


Local lXMLCPCLI   := ExistBlock( "XMLCMPCLI" )
Local aItmPE := {}
Local aCabPE := {}

Private oFont01     := TFont():New("Arial",07,14,,.T.,,,,.T.,.F.)
Private oXml
Private oDet, oOri
Private lDetCte     := ( GetNewPar("XM_CTE_DET","N") == "S" )
Private lTagOri     := ( GetNewPar("XM_CTE_DET","N") == "S" )
Private cTagFci     := ""
Private cCodFci     := ""
Private lMsErroAuto	:= .F.
Private lMsHelpAuto	:= .T.
Private aCabec      := {}
Private aItens      := {}
Private lNossoCod   := .F.
Private cProduto    := "" //nTamProd
Private cOrige		:= "" // LUCAS SAN 15/09/2022 -> PEGA O ICMS DO PRODUTO
Private cCnpjEmi    := ""
Private cCodEmit    := ""
Private cLojaEmit   := ""
Private nFormNfe    := Val(GetNewPar("XM_FORMNFE","6"))
Private nFormCTE    := Val(GetNewPar("XM_FORMCTE","6"))
Private nFormSer    := Val(GetNewPar("XM_FORMSER","0")) ///Incluido 19/01/2016
Private cEspecNfe   := PADR(GetNewPar("XM_ESP_NFE","SPED"),5)
Private cEspecNfce  := PADR(GetNewPar("XM_ESP_NFC","NFCE"),5)
Private cEspecCte   := PADR(GetNewPar("XM_ESP_CTE","CTE"),5)
Private cEspecCteO  := PADR(GetNewPar("XM_ESP_CTO","CTEOS"),5)
Private cEspecNfse  := PADR(GetNewPar("XM_ESP_NFS","NFS"),5)
Private cProdCte    := ""
Private cModelo     := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO")))
Private cTipoNf     := "N"
Private aItXml      := {}
Private cAmarra     := GetNewPar("XM_DE_PARA","0")
Private aPerg       := {}
Private aCombo      := {}
Private nAliqCTE    := 0, nBaseCTE := 0, nPedagio := 0, cModFrete := " "
Private nVPeda      := 0, nTPeda := 0 //Fadiga da OCRIM
Private cPCSol      := GetNewPar("XM_CSOL","A")
Private lNfOri      := ( GetNewPar("XM_NFORI","N") == "S" )
Private _lCCusto    := ( GetNewPar("XM_CCNFOR","N") == "S" ), _cCCusto
Private lIcmsCte    := ( GetNewPar("XM_ICMSCTE","S") == "S" )  //Icms GoSuper Fadigando
Private cCnpRem     := ""
Private aCnpRem     := {}
Private cTagAux     := ""
Private nValAux     := 0
Private lSerEmp     := .NOT. Empty( AllTrim(GetNewPar("XM_SEREMP","")) )
Private nAmarris    := 0
Private cPedidis    := ""
Private cPedXML     := ""
Private cTagTot     := ""
Private nTotXml     := 0
Private lTemFreXml  := .F., lTemDesXml := .F., lTemSegXml := .F.
Private aAuxPeAma   := {}  //nordsonAmarraCof 
Private cProdNfse   := "" //inicializando a variavel - analista Alexandro - 10/08/2017
Private cXped       := Space(6)
Private cXItemPed   := ""
Private cTagRefNfe  := ""  //Para Devolução NF Referencia
Private cChvReg     := ""  //Para Devolução NF Referencia
Private cxNOr       := ""  //Para Devolução NF Referencia
Private cxSOr       := ""  //Para Devolução NF Referencia
Private aCabErr     := {}
Private aIteErr     := {}
Private cCtrl_C     := "CTRL_C", oCtr_C  //Para pontos de entrada Carajas
Private cCtrl_V     := "CTRL_V", oCtr_V
Private aNForig     := {}
Private cUsaDvg     := GetNewPar("XM_USADVG","N") 	//FR 19/05/2020 - indica de está ativada a verificação de divergências Sim / Não
Private cCfgPre     := GetNewPar("XM_CFGPRE","0")	//FR 09/06/2020 - "tarefa: gera nota fiscal direto"
Private lNFDireto   := (cCfgPre $ "3")			    //FR 09/06/2020 - "tarefa: gera nota fiscal direto" - Se = 3, já gera documento de entrada direto, sem passsar por pré nota
Private lTemTESPC   := .F.							//FR - 19/06/2020 - TÓPICOS RAFAEL - indica se o pedido de compra já possui TES
Private lSemTES     := .F.							//FR - 19/06/2020 - TÓPICOS RAFAEL
Private cCondPag    := ""							//FR - 19/06/2020 - TÓPICOS RAFAEL
Private lTESBloq    := .F.							//FR - 19/06/2020 - TÓPICOS RAFAEL  
Private cMsgExec    := ""							//FR - 19/06/2020 - TÓPICOS RAFAEL  
Private lCondBloq   := .F.							//FR - 19/06/2020 - TÓPICOS RAFAEL
Private aPedidos    := {}
Private aFrete   := {"C=CIF","F=FOB","T=Por Conta Terceiros","R=Por Conta Remetente","D=Por Conta Destinatário","S=Sem Frete"}
Private cTipoDoc := " "
Private cTpCompl := " "
Private aCombo1x := {	" = ",;
						"1=Preco",;	
						"2=Quantidade",;	
						"3=Frete"}
Private aCombo1  := {	"N=Normal",;	
						"C=Compl. Preco/Frete"}
Private aDocOri  := {"1",; // (Gestão XML)     -> Erick Silva - 16/02/2023
					 "2"}  // (Protheus Padrão)
Private cTipoFrete	:= GetNewPar("XM_TPFRETE","N")
Private lMata140, lMata103
Private cDesmembra  := GetNewPar("XM_DESLOTE" , "N")  	//FR - 19/10/2022 - MBIOLOG - ATIVA DESMEMBRAMENTO DE LOTE
Private lDesmembra  := .F.
Private lTEMLOTE    := .F. //FR - REVISÃO - 24/07/2023 - USO DO CONTROLE DE LOTE-> verifica se no XML existe a tag RASTRO
Private cUsaLoteFor := GetNewPar("XM_LOTEFOR" , "N")	//FR - 19/10/2022 - MBIOLOG - ATIVA DESMEMBRAMENTO DE LOTE
Private lUSALOTE    := .F. //FR - 13/04/2023 - CHECA SE USA LOTE B1_RASTRO
//FR - 18/04/2023 - VYDENCE
Private cNATUREZ    := ""
Private lALTNAT     := .F.  
//usado na tela de informar TES, COND.PAGTO qdo parametrizado para "GERAR DOCUMENTO ENTRADA DIRETO"
//FR - 18/04/2023 - VYDENCE - 

/*
//FR - 09/06/2020 - Lembrete das opções do combo (tela F12)
aAdd( aCombo7, "0=Pré-Nota Somente")
aAdd( aCombo7, "1=Gera Pré-Nota e Classifica")
aAdd( aCombo7, "2=Sempre Perguntar") 
aAdd( aCombo7, "3=Gera Docto.Entrada Direto")  
*/
Public  lPCTES      := .F. //FR - 12/05/2020 indica se fez a tela de divergência para o pedido de compra
Public  cChaveXml   := ""  //FR - 12/05/2020 
Public  lHFXMLPED   := .F. //FR - 28/07/2020 - indica se executou a função HFXMLPED para não ser chamada duas vezes

If cModelo == "55" 
	lDetCte  := .F.
	lTagOri  := .F.
 	cPref    := "NF-e"
	cTGP     := "NFE"
	cTAG     := "NFE"
	nFormXML := nFormNfe
	cEspecXML:= cEspecNfe
	lPergunta:= .F.
ElseIf cModelo == "57"
 	cPref    := "CT-e"
	cTGP     := "CTE"
	cTAG     := "CTE"
	nFormXML := nFormCte
	cEspecXML:= cEspecCte
	lPergunta:= .F.
ElseIf cModelo == "65"
	lDetCte  := .F.
	lTagOri  := .F.
 	cPref    := "NFC-e"
	cTGP     := "NFE"
	cTAG     := "NFE"
	nFormXML := nFormNfe
	cEspecXML:= cEspecNfce
	lPergunta:= .F.
ElseIf cModelo == "67"
	lDetCte  := .F.
 	cPref    := "CT-eOS"
	cTGP     := "CTEOS"
	cTAG     := "CTE"
	nFormXML := nFormCte
	cEspecXML:= cEspecCteO
	lPergunta:= .F.
ElseIf cModelo == "RP"
	lDetCte  := .F.
	lTagOri  := .F.
 	cPref    := "NFS-e"
	cTGP     := "NFSE"
	cTAG     := "NFSE"
	nFormXML := nFormNfe
	cEspecXML:= cEspecNfse
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
aAdd( aCombo, "2=Customizada("+xZB5+")")
aAdd( aCombo, "3=Sem Amarração"   )
if !(xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC"))) $ "BD"
	aAdd( aCombo, "4=Por Pedido"  )
Else
	cAmarra := iif( cAmarra=="4", "0", cAmarra )
endif
aAdd( aCombo, "5=Virtual"  ) //nordsonAmarra

aadd(aPerg,{2,"Amarração Produto","",aCombo,120,".T.",.T.,".T."})

aParam[01] := ParamLoad(cParXMLExp,aPerg,1,aParam[01])

dEmiXML := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"DTNFE"))) 	//FR - 04/11/2021 - #11460 - ADAR
If cAmarra == "0" //.And. !cModelo $ "57"
	
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

	If lSeekNf
		//FR - 04/11/2021 - #11460 - ADAR
		If lSeekNF
			If Empty(SF1->F1_CHVNFE)  //se a chave estiver vazia, comparar com data emissão para validar se o seek é .T. 
				If dEmiXml <> SF1->F1_EMISSAO  //se a emissão for diferente, o seek é .F.
					lSeekNF := .F.
				Endif 
			Endif 
		Endif
		//FR - 04/11/2021 - #11460 - ADAR	
		If lSeekNf
			U_MyAviso("Atenção","Este XML já possui nota!"+CRLF +"Chave :"+cChaveF1,{"OK"},3)
			lRetorno := .F.
			SetKEY( VK_F3 ,  cKeyFe )
			Return()
		Endif 
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

cTipoCPro := MV_PAR02
cTipoCPro := cAmarra

cXml := U_fNoAcento((xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML"))))		//FR - 08/02/2021
cXml := EncodeUTF8(cXml)

//Faz backup do xml sem retirar os caracteres especiais
cBkpXml := cXml

//Executa rotina para retirar os caracteres especiais
cXml := u_zCarEspec( cXml )

cAux := Substr(cXml,Len(cXml), 1)               //FR - 10274 - CCM - 09/03/2021 - pega a última posição
If cAux != ">"                                  //verifica se a última posição é diferente do sinal de "maior", se não for:
    cXml := Substr(cXml,1,Len(cXml) -1 )        //refaço o cXml para receber todo o conteúdo da string menos o último caracter
Endif
oXml := XmlParser(cXml, "_", @cError, @cWarning )

//retorna o backup do xml
cXml := cBkpXml

If oXml == NIL .Or. !Empty(cError) .Or. !Empty(cWarning)

	MsgSTOP("XML Invalido ou Não Encontrado, a Importação Não foi Efetuada.")
	SetKEY( VK_F3 ,  cKeyFe )

	Return
	
EndIf

cTagTpEmiss:= "oXml:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_IDE:_TPEMIS:TEXT"
cTagTpAmb  := "oXml:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_IDE:_TPAMB:TEXT"
cTagCHId   := "oXml:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_ID:TEXT"
cTagSign   := "oXml:_"+cTGP+"PROC:_"+cTGP+":_SIGNATURE"
cTagProt   := "oXml:_"+cTGP+"PROC:_PROT"+cTAG+":_INFPROT:_NPROT:TEXT"
cTagKey    := "oXml:_"+cTGP+"PROC:_PROT"+cTAG+":_INFPROT:_CH"+cTAG+":TEXT"
/* Inclusão da tag CPF empresa Bela Ischa - 20/09/2016 */
If Type("oXml:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_EMIT:_CNPJ:TEXT") == "U"
	cTagDocEmit:= "oXml:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_EMIT:_CPF:TEXT"  
Else 
	cTagDocEmit:= "oXml:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_EMIT:_CNPJ:TEXT"
EndIf
/* Fim */


cTagDocXMl := "oXml:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_IDE:_N"+Left(cTAG,2)+":TEXT"
cTagSerXml := "oXml:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_IDE:_SERIE:TEXT"

If cModelo $ "55,65"

	cTagDtEmit := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_DEMI:TEXT"
	if type(cTagDtEmit) == "U"
		cTagDtEmit := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_DHEMI:TEXT"
	endif
	cTagDocDest:= "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_DEST:_CNPJ:TEXT"
	If Type(cTagDocDest) == "U"
		cTagDocDest:= "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_DEST:_CPF:TEXT"
	EndIf
	cTagTot    := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_TOTAL:_ICMSTOT:_VNF:TEXT"
	If Type(cTagTot)<> "U"
		nTotXml   := Val(&(cTagTot))
	Else
		nTotXml   := 0
	EndIf
	cTagTipFre:= "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_TRANSP:_MODFRETE:TEXT"
	If Type(cTagTipFre)<> "U"
   		cModFrete := &(cTagTipFre)
   	EndIf
   	
ElSeIf cModelo $ "57,67"

	cTagDtEmit := "oXml:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_IDE:_DHEMI:TEXT"
	cTagDocDest:= "oXml:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_REM:_CNPJ:TEXT"
	cTagAliq   := "oXml:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_IMP:_ICMS:_ICMS00:_PICMS:TEXT" 
	//Incluindo a TAG ICMS20 pelo Analista Alexandro de Oliveira - 16/12/2014
	cTagAliq1  := "oXml:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_IMP:_ICMS:_ICMS20:_PICMS:TEXT"
	If Type(cTagAliq)<> "U"  
   		nAliqCTE   := Val(&(cTagAliq))
   	ElseIf Type(cTagAliq1)<>"U"
   	    nAliqCTE  := Val(&(cTagAliq1))
   	EndIf    
	cTagBase   := "oXml:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_IMP:_ICMS:_ICMS00:_VBC:TEXT"
	//Incluindo a TAG ICMS20 pelo Analista Alexandro de Oliveira - 16/12/2014
	cTagBase1  := "oXml:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_IMP:_ICMS:_ICMS20:_VBC:TEXT"
	if lIcmsCte
		If Type(cTagBase)<> "U"
	   		nBaseCTE := Val(&(cTagBase))
   		ElseIf Type(cTagBase1)<> "U"
   			nBaseCTE := Val(&(cTagBase1))
	   	EndIf
	Else
		nBaseCTE := 0
	Endif

   	nPedagio := 0

   	if cModelo $ "57"

		cTagTpCte := "oXml:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_IDE:_TPCTE:TEXT"

		If Type(cTagTpCte) <> "U"  

			cTipo_CTE := &(cTagTpCte)

		endif

	   	If Type( "oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP" ) != "U"

			oDet := oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP
			oDet := iif( ValType(oDet) == "O", {oDet}, oDet )

			For i := 1 to Len( oDet )
				If UPPER( AllTRim( oDet[i]:_XNOME:TEXT ) ) == "PEDAGIO"
	   				nPedagio := Val(oDet[i]:_VCOMP:TEXT)
	   			EndIf
	   		Next i

	   	EndIf

	Else

	   	If Type( "oXml:_CTEOSPROC:_CTEOS:_INFCTE:_VPREST:_COMP" ) != "U"

			oDet := oXml:_CTEOSPROC:_CTEOS:_INFCTE:_VPREST:_COMP
			oDet := iif( ValType(oDet) == "O", {oDet}, oDet )

			For i := 1 to Len( oDet )
				If UPPER( AllTRim( oDet[i]:_XNOME:TEXT ) ) == "PEDAGIO"
	   				nPedagio := Val(oDet[i]:_VCOMP:TEXT)
	   			EndIf
	   		Next i

	   	EndIf

	Endif

	cTagTot    := "oXml:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_VPREST:_VTPREST:TEXT"

	If Type(cTagTot)<> "U"
		nTotXml   := Val(&(cTagTot))
	Else
		nTotXml   := 0
	EndIf
	
ElseIf cModelo == "RP"

	cTagDocEmit:= "oXml:_NFSETXT:_INFPROC:_CNPJ:TEXT"
	cTagDtEmit := ""
	cTagDocDest:= ""
	cTagTot    := ""
	cTagTot    := "oXml:_NFSETXT:_INFPROC:_VRSERV:TEXT"
	If Type(cTagTot)<> "U"
		nTotXml   := Val(&(cTagTot))
	Else
		nTotXml   := 0
	EndIf
	cTagTipFre := ""
	cModFrete  := ""
	
Else

	cTagDtEmit := ""
	cTagDocDest:= ""
	
EndIf

cCodEmit  := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR")))
cLojaEmit := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR")))
If cModelo == "RP"
	cDocXMl   := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA"))) //Iif(nFormXML > 0,StrZero(Val(&(cTagDocXMl)),nFormXML),&(cTagDocXMl))
Else
	cDocXMl   := Iif(nFormXML > 0,StrZero(Val(&(cTagDocXMl)),nFormXML),&(cTagDocXMl))
EndIF
cSerXml   := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE"))) //&(cTagSerXml)  //aqui em 21/01/2016

If cModelo == "RP"
	cSerXml := GetNewPar("XM_SER_NFS","")
EndIf
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

	cSerXml := Padl(alltrim(cSerXml),nFormSer,"0")  //Padl(alltrim(cSerXml),Tamsx3("D1_SERIE")[1],"0")

EndCase

if lSerEmp
	cSerXml := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE")))
endif

If cModelo == "RP"
	cChaveXml := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE")))
	cDtEmit   := Dtos( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"DTNFE"))) )
	dDataEntr := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"DTNFE")))
Else
	cChaveXml := &(cTagKey)
	cDtEmit   := &(cTagDtEmit)
	dDataEntr := StoD(substr(cDtEmit,1,4)+Substr(cDtEmit,6,2)+Substr(cDtEmit,9,2))
EndIf

cTipoNF  := AllTrim( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC"))))
cTpCompl := ""
If Empty( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC"))) )
	cTipoNF := "N"
Elseif cTipoNF == "C"
	cTipoNF := AllTrim( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC"))))
	cTpCompl:= ""

	@ 001,001 To 200,560 Dialog oSCR1 Title "Indique Dados do Frete"
	@ 010,010 SAY "Tipo da Nota?:" Of oSCR1 PIXEL SIZE 48 ,9 COLOR CLR_HBLUE,oSCR1:nClrPane
	@ 010,060 COMBOBOX oTipo VAR cTipoDoc ITEMS aCombo1 SIZE 70,10 PIXEL OF oSCR1
	@ 010,150 SAY "Tipo Complemento?:" Of oSCR1 PIXEL SIZE 48 ,9 COLOR CLR_HBLUE,oSCR1:nClrPane
	@ 010,210 COMBOBOX oTpCompl VAR cTpCompl ITEMS aCombo1x SIZE 70,10 PIXEL OF oSCR1
	@ 040,010 SAY "Tipo de Frete?:" Of oSCR1 PIXEL SIZE 48 ,9 COLOR CLR_HBLUE,oSCR1:nClrPane
	@ 040,060 COMBOBOX oModFrete VAR cModFrete ITEMS aFrete SIZE 100,10 PIXEL OF oSCR1
	@ 070,010 Button "&Ok" Size 030,012 Pixel Action (lRet := .T., Close(oSCR1) )
	@ 070,060 Button "&Cancelar" Size 030,012 Pixel Action (lRet := .F., Close(oSCR1) )

	Activate Dialog oSCR1 Centered
Endif

aadd(aCabec,{"F1_TIPO"   ,cTipoNF })
aadd(aCabec,{"F1_TPCOMPL",cTpCompl})

lAvulsa := .F.

If !lNFDireto   		//FR - 09/06/2020 - "tarefa: gera nota fiscal direto"

	if Val( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE"))) ) >= 890 .And. Val( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE"))) ) <= 899
		
		if U_MYAVISO("Atenção","XML de NF AVULSA"+CRLF+;
		   "Deseja Alterar para Formulário Próprio e Gerar Nota Fiscal de Entrada com número interno ou apenas gerar Pré-Nota normalmente?",{"F.Próprio","Pré-Nota"},3) == 1
			aadd(aCabec,{"F1_FORMUL" ,"S"})
			lAvulsa := .T.
		else
			aadd(aCabec,{"F1_FORMUL" ,"N"})
		endif
		
	Else
	
		aadd(aCabec,{"F1_FORMUL" ,"N"})
		
	EndIF 
Else
	aadd(aCabec,{"F1_FORMUL" ,"N"})
Endif

aadd(aCabec,{"F1_DOC"    ,cDocXMl})
aadd(aCabec,{"F1_SERIE"  ,cSerXml})

IF lAvulsa   //Val( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE"))) ) >= 890 .And. Val( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE"))) ) <= 899
	aadd(aCabec,{"F1_EMISSAO",dDataBase})
Else
	aadd(aCabec,{"F1_EMISSAO",dDataEntr})
EndIF

aadd(aCabec,{"F1_FORNECE",cCodEmit})
aadd(aCabec,{"F1_LOJA"   ,cLojaEmit})
aadd(aCabec,{"F1_ESPECIE",cEspecXML})
aadd(aCabec,{"F1_CHVNFE" ,iif(cModelo=="RP","",cChaveXml) })
aadd(aCabec,{"F1_VALPEDG",nPedagio })

If cTipoFrete == "S"
	if cModFrete <> " "
		if cModFrete == "0"
			cModFrete := "C"
		elseif cModFrete == "1"
			cModFrete := "F"
		elseif cModFrete == "2"
			cModFrete := "T"
		else
			cModFrete := "S"
		endif
			//aadd(aCabec,{"F1_TPFRETE",cModFrete })
	endif 
Endif
 
/* Inclusão obrigatoria tipo ct-e , somente para especie CT-e. analista Alexandro e Heverton - 26/12/2016 */
If alltrim(cEspecXML) == "CTE"         
	if !Empty((xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPCTE"))) )
		aadd(aCabec,{"F1_TPCTE",(xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPCTE"))) })
	else
		aadd(aCabec,{"F1_TPCTE","N" })
	endif
EndIf
/* Fim */

aadd(aCabec,{"F1_EST"    ,U_VerUfOri( cCodEmit, cLojaEmit, (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC"))) )		 })		//cUFOri         := aAutoCab[8,2]  (xZBZ)->(FieldGet(FieldPos(xZBZ_+"UF"))), vai dor do For

IF alltrim(cEspecXML) = "CTE" .And. SF1->(FieldPos("F1_UFORITR")) > 0 .And. SF1->(FieldPos("F1_MUORITR")) > 0 .And. SF1->(FieldPos("F1_UFDESTR")) > 0 .And. SF1->(FieldPos("F1_MUDESTR")) > 0
	
	if Type( "oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_CMUNINI:TEXT" ) <> "U"  //variavel oXml private, vindo do importa.
		
		cMunIni := oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_CMUNINI:TEXT
		
		if Len(cMunIni) == 7
			cMunIni := Substr(cMunIni,3,5)  //Os dois primeiros dígito é o Estado, no Protheus o Código inicia direto na cidade.
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

cTagAux   := "oXml:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_TOTAL:_ICMSTOT:_VFRETE:TEXT"

if Type(cTagAux) <> "U" 

	nTotFre := Val( &(cTagAux) )
	if nTotFre > 0
		aadd(aCabec,{"F1_FRETE",nTotFre })
		lTemFreXml := .T.
	endif
	
endif

cTagAux   := "oXml:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_TOTAL:_ICMSTOT:_VOUTRO:TEXT"

if Type(cTagAux) <> "U" 

	nValAux := Val( &(cTagAux) )
	if nValAux > 0
		aadd(aCabec,{"F1_DESPESA",nValAux })
		lTemDesXml := .T.
	endif
	
endif

cTagAux   := "oXml:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_TOTAL:_ICMSTOT:_VSEG:TEXT"

if Type(cTagAux) <> "U" 
	
	nValAux := Val( &(cTagAux) )
	if nValAux > 0
		aadd(aCabec,{"F1_SEGURO",nValAux })
		lTemSegXml := .T.
	endif
	
endif

cTagAux   := "oXml:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_TRANSP:_VOL:_QVOL:TEXT"    //AQUIIIII OS VOLUMES
if Type(cTagAux) <> "U" 
	
	nValAux := Val( &(cTagAux) )
	if nValAux > 0
		aadd(aCabec,{"F1_VOLUME1",nValAux })
	endif
	
else
	
	cTagAux   := "oXml:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_TRANSP:_VOL[1]:_QVOL:TEXT"
	if Type(cTagAux) <> "U" 
		nValAux := Val( &(cTagAux) )
		if nValAux > 0
			aadd(aCabec,{"F1_VOLUME1",nValAux })
		endif
	endif
	
endif

cTagAux   := "oXml:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_TRANSP:_VOL:_ESP:TEXT"    //AQUIIIII OS VOLUMES
if Type(cTagAux) <> "U" 

	cValAux := &(cTagAux)
	If SubsTr(cValAux,Len(cValAux),1) <> '"'  //FR - 10/06/2020 - para evitar que fique = "3 sem a aspa final
		cValAux += '"'
	Endif
	if .Not. Empty(cValAux)
		aadd(aCabec,{"F1_ESPECI1",cValAux })
	endif
	
else

	cTagAux   := "oXml:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_TRANSP:_VOL[1]:_ESP:TEXT"
	if Type(cTagAux) <> "U" 
		cValAux := &(cTagAux)
		If SubsTr(cValAux,Len(cValAux),1) <> '"'  //FR - 10/06/2020 - para evitar que fique = "3 sem a aspa final
			cValAux += '"'
		Endif
		if .Not. Empty(cValAux)
			aadd(aCabec,{"F1_ESPECI1",cValAux })
		endif
	endif
	
endif

lCadastra := .F.

if lXMLPEVAL <> lXMLPEREG .or. lXMLPEVAL <> lXMLPEATU .or. lXMLPEREG <> lXMLPEATU

	U_MyAviso("Atenção","Pontos de Entrada XMLPEVAL, XMLPEREG e XMLPEATU, devem trabalhar em concordancia. Como nem todos estão compilados nenhum será executado.",{"OK"},3)
	lXMLPEVAL := .F. 
	lXMLPEREG := .F. 
	lXMLPEATU := .F.
	
endif

If lXMLPEVAL .And. lXMLPEREG
 
	cCtrl_C   := "CTRL_C"
	oCtr_C    := NIL   //Para pontos de entrada Carajas
	cCtrl_V   := "CTRL_V"
	oCtr_V    := NIL
	aCabErr     := {}  //ver para pegar do SXG
	aadd(aCabErr, {"CHVNFE" , "C", 44                  , 0, cChaveXml } )
	aadd(aCabErr, {"FORNECE", "C", Len(SF1->F1_FORNECE), 0, cCodEmit  } )
	aadd(aCabErr, {"LOJA"   , "C", Len(SF1->F1_LOJA)   , 0, cLojaEmit } )
	aadd(aCabErr, {"DOC"    , "C", Len(SF1->F1_DOC)    , 0, cDocXMl   } )
	aadd(aCabErr, {"SERIE"  , "C", Len(SF1->F1_SERIE)  , 0, cSerXml   } )
	aadd(aCabErr, {"EMISSAO", "D", 8                   , 0, dDataEntr } )
	
	aIteErr     := {}  //Alimentar conforme os ITENS no U_HFCARA1 e U_HFCARA2
	ExecBlock( "XMLPEREG", .F., .F., { "C",aCabErr,,,,,, } )  //Para Criar TMP

EndIF

Do while ( nErrItens < 2 .and. ! cTipoCPro $ '4,5' ) //nordsonAmarra

 If lXMLPEVAL .And. lXMLPEREG
	aIteErr     := {}  //Alimentar conforme os ITENS no U_HFCARA1 e U_HFCARA2
	DbSelectArea( cCtrl_V )
	Zap
 EndIF

 nErrItens++
 lRetorno  := .T.
 aLinha    := {}
 aProdOk   := {}
 aProdNo   := {}
 aProdZr   := {}
 aProdVl   := {}
 aItXml    := {}
 aItens    := {}
 aAuxPeAma := {} //nordsonAmarraCof
 
 aTotal    := {}
 nTotNfe   := 0
 lSemNfe   := .F.
 lHFXMLPED := .F.

 If cModelo $ "55,65"

	//FR - 02/03/2021 - #6272 - Mectronics - trazer automaticamente o número / série da nf original em cada item da nf
 	//cTagRefNfe := "oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_NFREF:_REFNFE:TEXT"
	/*cChvReg := ""
 	
 	//FR - 30/03/2021 - #10372 - Mectronics - prever quando a estrutura do XML não possuir a informação do documento original        
    cTagRefNfe := ""
    lSubstring := .F.
    _NfOri     := ""
    _SrOri	   := ""
    
    cTagRefNfe := "oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_NFREF:_REFNFE:TEXT"
    
    If type("oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_NFREF:_REFNFE:TEXT")<>'U'		//os nós apresentados atenderam para obter o documento original
      
	   cTagRefNfe := "oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_NFREF:_REFNFE:TEXT"
       lSubstring := .T.    
    
    Else																	//os nós apresentados NÃO atenderam, então buscarei um nó acima
              
       If type("oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_NFREF:_REFNFP:_NNF:TEXT")<>'U'

          cTagRefNfe := "oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_NFREF:_REFNFP:_NNF:TEXT"
          _NfOri	 := "oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_NFREF:_REFNFP:_NNF:TEXT"  	//JÁ Alimenta com o número da nf original
          
          If type("oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_NFREF:_REFNFP:_SERIE:TEXT")<>'U'
          	_SrOri   := "oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_NFREF:_REFNFP:_SERIE:TEXT"	//JÁ Alimenta com a série da nf original
          Endif       

       Endif	
	
	Endif
	
	If type(cTagRefNfe) <> "U"
		
		If lSubstring 		//indica que a informação do documento original está dentro de uma cadeia de caracteres, então tenho que pegar via substring
			
			cChvReg := &(cTagRefNfe)
			_xNOr   := Substr(cChvReg,26,9)
			_xSOr   := Substr(cChvReg,23,3)  //esta com 3 zeros		

		Else				//indica que o número e série da nf estão em campos distintos, então dá pra pegar direto
			
			cChvReg := &(_NfOri)
			_xNOr   := StrZero( Val(cChvReg),9,0)
			cChvReg := &(_SrOri)
			_xSOr   := StrZero( Val(cChvReg),3,0)		

		Endif
	//FR - 30/03/2021 - #10372 - Mectronics - prever quando a estrutura do XML não possuir a informação do documento original
		
		If nFormSer = 2
			If Val(_xSOr) <= 99
				_xSOr := StrZero(Val(_xSOr),2,0)+" "
			Endif
		Elseif nFormSer = 3
			_xSOr := StrZero( Val(_xSOr),3,0)	  //Substr(AllTrim(Str(Val(_xSOr),15,0))+space(3),1,3)
		Endif
	
	Else

		_xNOr := Space(9)
		_xSOr := "   "

	Endif

	cNfOri := _xNOr
	cSerOri:= _xSOr*/
 	//FR - 02/03/2021
 
	oDet := oXml:_NFEPROC:_NFE:_INFNFE:_DET
	oDet := IIf(ValType(oDet)=="O",{oDet},oDet)

	If Type("oXml:_NFEPROC:_NFE:_INFNFE:_DET") == "A"
		aItem := oXml:_NFEPROC:_NFE:_INFNFE:_DET
	Else
		aItem := {oXml:_NFEPROC:_NFE:_INFNFE:_DET}
	EndIf

	aItmPE := {}
	nD1Item := 1
	
	For i := 1 To Len(oDet)

		//FR - 31/03/2021 - Implementar a carga do número de lote do fornecedor para os xmls que possuam a tag "rastro"
		cLote    := ""						//tipo C , tamanho 18
		dValLote := Ctod("  /  /    ")		//tipo D , tamanho 8
		cValLote := ""
		cAnoFab  := ""						//tipo C , tamanho 2
		cValFab  := ""
		dDatFab  := Ctod("  /  /    ")
	
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
			aRetProd := u_HFPRDINT(i)

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
				cWhere += "'"+U_TrocaAspas( AllTrim(oDet[i]:_Prod:_CPROD:TEXT) )+"'"
				cWhere += ") )%"

						BeginSql Alias cAliasSA7
							SELECT
								A7_FILIAL,
								A7_CLIENTE,
								A7_LOJA,
								A7_CODCLI,
								A7_PRODUTO,
								R_E_C_N_O_
							FROM
								%Table:SA7% SA7
							WHERE
								SA7.%notdel%
								AND A7_CLIENTE = %Exp:cCodEmit%
								AND A7_LOJA = %Exp:cLojaEmit%
								AND %Exp:cWhere%
							ORDER BY
								A7_FILIAL,
								A7_CLIENTE,
								A7_LOJA,
								A7_CODCLI
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
							SELECT
								A5_FILIAL,
								A5_FORNECE,
								A5_LOJA,
								A5_CODPRF,
								A5_PRODUTO,
								R_E_C_N_O_
							FROM
								%Table:SA5% SA5
							WHERE
								SA5.%notdel%
								AND A5_FORNECE = %Exp:cCodEmit%
								AND A5_LOJA = %Exp:cLojaEmit%
								AND %Exp:cWhere%
							ORDER BY
								A5_FILIAL,
								A5_FORNECE,
								A5_LOJA,
								A5_CODPRF
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

		nQuant := VAL(oDet[i]:_Prod:_QCOM:TEXT)
		nVunit := VAL(oDet[i]:_Prod:_VUNCOM:TEXT)
		nTotal := VAL(oDet[i]:_Prod:_VPROD:TEXT)
		
		//FR - 31/03/2021 - Implementar a carga do número de lote do fornecedor para os xmls que possuam a tag "rastro"
		if Type("oDet["+Str(i)+"]:_Prod") <> "U"

			if XmlChildEx(oDet[i]:_Prod,"_RASTRO") <> nil   //Complemento

				//if Len(oDet[i]:_Prod:_Rastro) > 1
				//FR - 24/11/2021 - #11571 - WINDROSE - correção error log qdo gera pré-nota
                If Valtype(oDet[i]:_Prod:_Rastro) == "A" //SE FOR ARRAY
					
					//-----------------------------------------------------------------------------------//
					//FR - 19/10/2022 -TRATATIVA DO NÚMERO DE LOTE QUANDO HÁ VÁRIOS LOTES NO MESMO ITEM
					//MBIOLOG
					//----------------------------------------------------------------------------------//
					If Len(oDet[i]:_PROD:_RASTRO) > 1
						If cDesmembra == "S" //só faz o desmembramento se o parâmetro estiver ativado Sim					
							lDesmembra := .T.
							lTEMLOTE   := .T.
						Endif
					Else   
						cLote   := oDet[i]:_Prod:_Rastro[1]:_NLOTE:TEXT
						cValLote:= oDet[i]:_Prod:_Rastro[1]:_DVAL:TEXT		//vem assim: "2045-12-16" -> transformar para 16/12/2045
						dValLote:= CtoD( Substr(cValLote,9,2) + "/" + Substr(cValLote,6,2) + "/" + Substr(cValLote,1,4) ) 
						cAnoFab := Substr(oDet[i]:_Prod:_Rastro[1]:_DFAB:TEXT , 3,2)  	//vem assim: "2018-08-01" -> transformar para 18 o ano tem 2 dígitos apenas
						cValFab := oDet[i]:_Prod:_Rastro[1]:_DFAB:TEXT
						dDatFab := CtoD( Substr(cValFab,9,2) + "/" + Substr(cValFab,6,2) + "/" + Substr(cValFab,1,4) )	
						lTEMLOTE:= .T.
					Endif 
				else
			
					cLote   := oDet[i]:_Prod:_Rastro:_NLOTE:TEXT
					cValLote:= oDet[i]:_Prod:_Rastro:_DVAL:TEXT		//vem assim: "2045-12-16" -> transformar para 16/12/2045
					dValLote:= CtoD( Substr(cValLote,9,2) + "/" + Substr(cValLote,6,2) + "/" + Substr(cValLote,1,4) ) 
					cAnoFab := Substr(oDet[i]:_Prod:_Rastro:_DFAB:TEXT , 3,2)  	//vem assim: "2018-08-01" -> transformar para 18 o ano tem 2 dígitos apenas
					cValFab := oDet[i]:_Prod:_Rastro:_DFAB:TEXT
					dDatFab := CtoD( Substr(cValFab,9,2) + "/" + Substr(cValFab,6,2) + "/" + Substr(cValFab,1,4) )	
					lTEMLOTE:= .T.

				endif
			Endif 	//if XmlChildEx(oDet[i]:_Prod,"_RASTRO") <> nil   //Complemento		
			//endif

		endif
		//FR - 31/03/2021

		if (Empty(nQuant) .Or. nQuant = 1  ) .And. Empty(nVunit) .And. Empty(nTotal)
		
			If nTotXml > 0 .And. len(oDet) == 1  //Complemento de Alguma Coisa
				nQuant := 1
				nVunit := nTotXml
				nTotal := nTotXml
			ElseIF len(oDet) == 1
				nQuant := 1
				if Type("oDet["+AllTrim(Str(i))+"]:_Imposto:_ICMS:_ICMS00:_VBC:TEXT") <> "U"
					nVunit := VAL(oDet[i]:_Imposto:_ICMS:_ICMS00:_VBC:TEXT)
					nTotal := VAL(oDet[i]:_Imposto:_ICMS:_ICMS00:_VBC:TEXT)
				elseif Type("oDet["+AllTrim(Str(i))+"]:_Imposto:_ICMS:_ICMS10:_VBC:TEXT") <> "U"
					nVunit := VAL(oDet[i]:_Imposto:_ICMS:_ICMS10:_VBC:TEXT)
					nTotal := VAL(oDet[i]:_Imposto:_ICMS:_ICMS10:_VBC:TEXT)
				elseif Type("oDet["+AllTrim(Str(i))+"]:_Imposto:_ICMS:_ICMS20:_VBC:TEXT") <> "U"
					nVunit := VAL(oDet[i]:_Imposto:_ICMS:_ICMS20:_VBC:TEXT)
					nTotal := VAL(oDet[i]:_Imposto:_ICMS:_ICMS20:_VBC:TEXT)
				elseif type("oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VBC:TEXT") <> "U"
					nVunit := VAL(oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VBC:TEXT)
					nTotal := VAL(oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VBC:TEXT)				
				endif
			EndIf
			
		Endif

		nVdesc := 0
		cTagAux:= "oDet["+Alltrim(STR(i))+"]:_PROD:_VDESC:TEXT"
		if Type( cTagAux ) <> "U"  
			nVdesc := Val( oDet[i]:_Prod:_VDESC:TEXT )
		endif

		//FR - 03/02/2022 - #11864 - PETRA , trazer valor das despesas do item
		nVdesp      := 0  					
		If XmlChildEx(oDet[i]:_Prod,"_VOUTRO") <> nil 
		
			cTagAux:= "oDet["+Alltrim(STR(i))+"]:_PROD:_VOUTRO:TEXT"
			if Type( cTagAux ) <> "U"  
				nVdesp := Val( oDet[i]:_Prod:_VOUTRO:TEXT )
			endif 
			
		Endif
		//FR - 03/02/2022 - #11864 - PETRA , trazer valor das despesas do item 
        cCodFci:= ""
        cTagFci:= "oDet["+AllTrim(Str(i))+"]:_PROD:_NFCI:TEXT"  //CONFIRMAR ESTA TAG
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
			 		if ABS( Round((nQuant * nVunit),2) - Round(nTotal, 2) ) >= 0.02 .And.;
					   nVunit <> VAL(oDet[i]:_Prod:_VUNCOM:TEXT) //por causa do problema de arredondar e truncar com valor unitário com 3 casas decimais (Itambé)
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
		
		//---------------------------------------------------------------------------//
		//FR - 29/08/2022 - ECO AUTOMAÇÃO - CHAMADO #13333
		//                  Quando a tag XPED já vier com o pedido, apenas validar 
		//                  se existe e já amarrar ao item
		//                  Sem que haja obrigação da amarração por produto estar = "4"
		//---------------------------------------------------------------------------//
		if empty(cXped) //.and. cTipoCPro == "4"  //retirar essa obrigatoriedade
		
			cTagAux    := "oDet["+AllTrim(str(I))+"]:_PROD:_XPED:TEXT"
			if type( cTagAux ) <> "U"
				//cXped := Substr(&cTagAux,1,6)
				cXPed := StrZero( Val(Substr(&cTagAux,1,6)),6 )
			endif
			
			cTagAux    := "oDet["+AllTrim(str(I))+"]:_PROD:_NITEMPED:TEXT"
			if type( cTagAux ) <> "U"
				cXItemPed  := StrZero( Val( &cTagAux ), nTamIte )
			Else
				//cXItemPed  := StrZero( 0, nTamIte )  //a pedidos, não checar item
			Endif
			
		endif
		
		//Cfop - Precisa ter estrutura ZB4 para fazer depara de cfop
		/*if Type("oXml:_NFEPROC:_NFE:_INFNFE:_DET["+ AllTrim(str(I)) +"]:_PROD:_CFOP") <> "U"
		
			_cCfop := oXml:_NFEPROC:_NFE:_INFNFE:_DET[I]:_PROD:_CFOP:TEXT
			
			DbSelectArea(xZB4)
			DbSetOrder(1)
			if DbSeek( xFilial(xZB4) + _cCfop )
			
				cCfopIn := (xZB4)->(FieldGet(FieldPos(xZB4+"_CFOPIN")))
				
				aadd(aLinha,{"D1_CF", cCfopIn			        ,Nil})
			
			endif							
		
		endif*/

        //--------------------------------------------------------------------------------------------//
        //FR - 30/12/2022 - KIM PÃES - GRAVAÇÃO DO CAMPO ZBT_DEPARA (CÓDIGO INTERNO PRODUTO)
        (xZBT)->(OrdSetFocus(4))
        //Localiza o produto na ZBT e verifica se já foi gravado o código interno no ZBT_DEPARA
        //se já estiver gravado, confere se é o mesmo código obtido agora pela amarração 
        //escolhida pelo usuário, se for o mesmo código, mantém, 
        //se for diferente, grava por cima com a amarração escolhida pelo usuário
        //--------------------------------------------------------------------------------------------//
        If (xZBT)->(Dbseek(xFilial(xZBT) + oDet[i]:_Prod:_XPROD:TEXT)) //ZBT_FILIAL+ZBT_PRODUT+ZBT_PEDIDO+ZBT_ITEMPC
            If Alltrim( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"DEPARA"))) ) <> Alltrim(cProduto)
                
                //se for diferente, sobrescreve
                RecLock(xZBT,.F.)
			        (xZBT)->(FieldPut(FieldPos(xZBT_+"DEPARA"), cProduto ))
			    (xZBT)->( MsUnlock() )                

            Endif
        Endif 
        //--------------------------------------------------------------------------------------------//
        //FR - 30/12/2022 - KIM PÃES - GRAVAÇÃO DO CAMPO ZBT_DEPARA (CÓDIGO INTERNO PRODUTO)
        //--------------------------------------------------------------------------------------------//

		//--------------------------------------------------------------------------------------------//
		//FR - 16/02/2023 - MBIOLOG - CHECAGEM SE O PRODUTO REALMENTE USA LOTE, SE NÃO UTILIZAR, 
		//DESATIVA O DESMEMBRAMENTO SÓ NESTE LANÇAMENTO DA NOTA, 
		//O PARÂMETRO FICA INTACTO (XM_DESLOTE)
		//--------------------------------------------------------------------------------------------//
		//
		//FR - 13/04/2023
		lUSALOTE := .F.
		If lDesmembra .OR. lTEMLOTE
			SB1->(OrdSetFocus(1))
			SB1->(Dbseek(xFilial("SB1") + cProduto))
			If SB1->B1_RASTRO == "N"  
			//se o produto não controla Lote, desativo o lDesmembra para não realizar desmembramento indevidamente
				lDesmembra := .F.
			//FR - 13/04/2023
			Elseif SB1->B1_RASTRO == "L"
				lUSALOTE := .T.
			Endif
		Endif  
		//--------------------------------------------------------------------------------------------//
		//FR - 16/02/2023 - MBIOLOG - CHECAGEM SE O PRODUTO REALMENTE USA LOTE
		//--------------------------------------------------------------------------------------------//

		If !lDesmembra
			aadd(aLinha,{"D1_ITEM"  ,StrZero(nD1Item,4)             ,Nil})
			aadd(aLinha,{"D1_COD"   ,cProduto               		,Nil})

			//Antes da Quantidade
			If lXMLPEVAL  //.Or. !Empty(cXped)
			
				aadd(aLinha,{"D1_PEDIDO",cXped		           		,Nil})
				if !Empty(cXItemPed)
					aadd(aLinha,{"D1_ITEMPC",cXItemPed				,Nil})
				endif
				
			Else
			
				SC7->(OrdSetFocus(1))
				If !Empty(cXped) .And. val(cXped) <> 0 .And. SC7->( dbSeek( xFilial( "SC7" ) + cXped ) )
				
					If !Empty(cXItemPed) .and. SC7->( dbSeek( xFilial( "SC7" ) + cXped + cXItemPed ) )
						
						If Empty( SC7->C7_RESIDUO ) .And. (SC7->C7_QUANT-SC7->C7_QUJE-SC7->C7_QTDACLA >= nQuant)    //FR - 06/08/2020 - Se o pedido de compra tem saldo
							
							aadd(aLinha,{"D1_PEDIDO",cXped		       	,Nil})
							aadd(aLinha,{"D1_ITEMPC",cXItemPed			,Nil})

						Endif
					Endif					
				Endif				
			EndIF
			//---------------------------------------------------------------------------//
			//FR - 29/08/2022 - ECO AUTOMAÇÃO - CHAMADO #13333
			//---------------------------------------------------------------------------//



			//Erick Gonça - 22/09/2022 - IF criado para não apresentar a quantidade no compl. de preço e frete.
			If cTpCompl == ""
				aadd(aLinha,{"D1_QUANT" ,nQuant							 ,Nil})
			Elseif cTpCompl == "1|3"
				//aadd(aLinha,{"D1_QUANT",1                       ,Nil})
			Elseif cTpCompl == "2"
				aadd(aLinha,{"D1_QUANT" ,nQuant							 ,Nil})
			Endif
			
			aadd(aLinha,{"D1_VUNIT" ,nVunit							 ,Nil})
			aadd(aLinha,{"D1_TOTAL" ,nTotal							 ,Nil})
			
			if nVdesc > 0
				aadd(aLinha,{"D1_VALDESC" ,nVdesc					 ,Nil})
			endif
			
			//FR - 03/02/2022 - #11864 - PETRA , trazer valor das despesas do item
			if nVdesp > 0
				aadd(aLinha,{"D1_DESPESA" ,nVdesp					 ,Nil})
			endif

			if nTotFre > 0
				nAuxFret := (nTotFre / Len(oDet))
				aadd(aLinha,{"D1_VALFRE" ,nAuxFret					 ,Nil})
			endif
		
			//FR - 03/02/2022 - #11864 - PETRA , trazer valor das despesas do item
			//If .Not. Empty(cCodFci)        //FR - 06/08/2020 - comentado para não criar em posição diferente entre os itens
				aadd(aLinha,{"D1_FCICOD",cCodFci					 ,Nil})
			//EndIf
			
			if cPCSol == "S"  //Centro de Custo do Pedido, então manda vazio para pegar do pedido ao relacionar o pedido F5 ou F6
				aadd(aLinha,{"D1_CC"    ,nTamCc 					 ,Nil})
			elseif cPCSol != "Z"   //=> Com o Z não preenche o D1_CC, senão ao caso utilizar um gatilho poderia sobrepor o gatilho
				if .not. empty( cProduto ) .And. SB1->( DbSeek(xFilial("SB1")+cProduto) )
					aadd(aLinha,{"D1_CC",SB1->B1_CC					 ,Nil})
				endif
			endif

			//FR - 02/03/2021 - #6272 - Mectronics - trazer automaticamente o número / série da nf original
			/*If !Empty(cNfOri)		//FR - 30/03/2021 - #10372 - Mectronics

				aadd(aLinha,{"D1_NFORI"		,cNfOri					     ,Nil})
				aadd(aLinha,{"D1_SERIORI"	,cSerOri					 ,Nil})

				//Valida item da nota de origem
				cItemOri := ""
				U_ExistDoc( @cNfOri, @cSerOri,,,,,, cProduto, @cItemOri )

				aadd(aLinha,{"D1_ITEMORI"	,cItemOri					 ,"AllwaysTrue()"})

			Endif*/
			//FR - 02/03/2021
			
			//FR - 13/04/2023 - CHECA SE USA LOTE
			IF lUSALOTE
				//FR - 31/03/2021 - Implementar a carga do número de lote do fornecedor para os xmls que possuam a tag "rastro"
				If !Empty(cLote)
					aadd(aLinha,{"D1_LOTEFOR"		,cLote				     ,Nil})		//tipo C , tamanho 18
					//FR - 01/11/2022 - correção 
					If cUsaLoteFor == "S"
						aadd(aLinha,{"D1_LOTECTL"	, Alltrim(Substr(cLote,1,TamSX3("D1_LOTECTL")[1]))    ,Nil})		
					Endif 
				Endif
				
				If !Empty(dValLote)
					aadd(aLinha,{"D1_DTVALID"		,dValLote			     ,Nil})		//tipo D , tamanho 8
				Endif
				
				If !Empty(cAnoFab)
					aadd(aLinha,{"D1_ANOFAB"		,cAnoFab			     ,Nil})		//tipo C , tamanho 2			
				Endif

				If !Empty(dDatFab)
					aadd(aLinha,{"D1_DFABRIC"		,dDatFab			     ,Nil})		//tipo D , tamanho 8
				Endif	
				//FR - 31/03/2021
			Endif 
			//FR - 13/04/2023 - VERIFICA SE O PRODUTO REALMENTE USA LOTE OU NÃO

			If lXMLPEITE   //PE para incluir campos no aLinha SD1 -> para o aItens
				
				aRet :=	ExecBlock( "XMLPEITE", .F., .F., { cProduto,oDet,i } )
				If ValType(aRet) == "A"
					AEval(aRet,{|x| AAdd(aLinha,x)})
				EndIf
				
			endif

			if .not. Empty( cProduto )
				
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

			if nVunit > 0 //permitir valor unitário maior zero
				
				If lXMLPELOK   //PE para validar os aItens
					IF ! Empty(cProduto)  //Só se passou pela amarração
						lLOk :=	ExecBlock( "XMLPELOK", .F., .F., { cModelo,cProduto,oDet,i } )
						If ValType(lLOk) <> "L"
							Alert( "Ponto de entrada XMLPELOK deve Retornar .T. ou .F." )
							lLOk := .F.
						EndIf
						if ! lLOk
							Exit
						Endif
					Else
						lLOk := .T.
					EndIf
				Endif
				aadd(aItens,aLinha)
				nD1Item++
				aLinha := {}
				aadd(aItXml,{StrZero(i,4),oDet[i]:_Prod:_CPROD:TEXT,oDet[i]:_Prod:_XPROD:TEXT})
			
			Else  //Lobato também 10/05/18 complemento de IPI
				
				If len(oDet) == 1  //nTotXml > 0 .And.//ADAR //Complemento de Alguma Coisa
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
					aadd(aItens,aLinha)
					nD1Item++
					aLinha := {}
					aadd(aItXml,{StrZero(i,4),oDet[i]:_Prod:_CPROD:TEXT,oDet[i]:_Prod:_XPROD:TEXT})
				EndIf
				
			endif

		ELSE
		//=======================//
		//DESMEMBRA POR LOTE
		//=======================//
			nRastro := 0
			nl := 1
			While nl <= Len(oDet[i]:_PROD:_RASTRO)
				//quantidade do produto										//FR - 10/03/2020
				cTagAux := "oDet["+AllTrim(str(I))+"]:_PROD:_RASTRO[" + Alltrim(str(nl))+ "]:_QLOTE:TEXT"  
				If type( cTagAux ) <> "U"
					nQuant := VAL(&cTagAux)		
				Endif
							
				nTotal := nQuant * nVunit

				//numero lote
				cTagAux := "oDet["+AllTrim(str(I))+"]:_PROD:_RASTRO[" + Alltrim(str(nl))+ "]:_NLOTE:TEXT"  
				If type( cTagAux ) <> "U"
					cLOTE := (&cTagAux)		
				Endif

				//Validade lote
				cTagAux := "oDet["+AllTrim(str(I))+"]:_PROD:_RASTRO[" + Alltrim(str(nl))+ "]:_DVAL:TEXT"  
				cValLote  := &cTagAux 	//vem assim: "2024-06-30" -> transformar para 30/06/2024
				dValLote  := CtoD( Substr(cValLote,9,2) + "/" + Substr(cValLote,6,2) + "/" + Substr(cValLote,1,4) ) 

				//ano fabricação do lote
				cTagAux   := "oDet["+AllTrim(str(I))+"]:_PROD:_RASTRO[" + Alltrim(str(nl))+ "]:_DFAB:TEXT"  
				cAnoFab   := &cTagAux 	//vem assim: "2022-06-30" -> transformar para 22 o ano tem 2 dígitos apenas
				cValFab := &cTagAux   
				dDatFab := CtoD( Substr(cValFab,9,2) + "/" + Substr(cValFab,6,2) + "/" + Substr(cValFab,1,4) )	

				//=======================================================//
				//INICIO MONTA ARRAY ITENS DA NOTA
				//=======================================================//
				aadd(aLinha,{"D1_ITEM"  ,StrZero(nD1Item,4)             ,Nil})
				aadd(aLinha,{"D1_COD"   ,cProduto               		,Nil})

				//Antes da Quantidade
				If lXMLPEVAL  //.Or. !Empty(cXped)
				
					aadd(aLinha,{"D1_PEDIDO",cXped		           		,Nil})
					if !Empty(cXItemPed)
						aadd(aLinha,{"D1_ITEMPC",cXItemPed				,Nil})
					endif
					
				Else
				
					SC7->(OrdSetFocus(1))
					If !Empty(cXped) .And. val(cXped) <> 0 .And. SC7->( dbSeek( xFilial( "SC7" ) + cXped ) )
					
						If !Empty(cXItemPed) .and. SC7->( dbSeek( xFilial( "SC7" ) + cXped + cXItemPed ) )
							
							If Empty( SC7->C7_RESIDUO ) .And. (SC7->C7_QUANT-SC7->C7_QUJE-SC7->C7_QTDACLA >= nQuant)    //FR - 06/08/2020 - Se o pedido de compra tem saldo
								
								aadd(aLinha,{"D1_PEDIDO",cXped		       	,Nil})
								aadd(aLinha,{"D1_ITEMPC",cXItemPed			,Nil})

							Endif

						Endif
						
					Endif
					
				EndIF
				//---------------------------------------------------------------------------//
				//FR - 29/08/2022 - ECO AUTOMAÇÃO - CHAMADO #13333
				//---------------------------------------------------------------------------//
				
				aadd(aLinha,{"D1_QUANT" ,nQuant							 ,Nil})
				aadd(aLinha,{"D1_VUNIT" ,nVunit							 ,Nil})
				aadd(aLinha,{"D1_TOTAL" ,nTotal							 ,Nil})
				
				if nVdesc > 0
					aadd(aLinha,{"D1_VALDESC" ,nVdesc					 ,Nil})
				endif
				
				//FR - 03/02/2022 - #11864 - PETRA , trazer valor das despesas do item
				if nVdesp > 0
					aadd(aLinha,{"D1_DESPESA" ,nVdesp					 ,Nil})
				endif

				if nTotFre > 0
					nAuxFret := (nTotFre / Len(oDet))
					aadd(aLinha,{"D1_VALFRE" ,nAuxFret					 ,Nil})
				endif
			
				aadd(aLinha,{"D1_FCICOD",cCodFci					 ,Nil})
								
				if cPCSol == "S"  //Centro de Custo do Pedido, então manda vazio para pegar do pedido ao relacionar o pedido F5 ou F6
					aadd(aLinha,{"D1_CC"    ,nTamCc 					 ,Nil})
				elseif cPCSol != "Z"   //=> Com o Z não preenche o D1_CC, senão ao caso utilizar um gatilho poderia sobrepor o gatilho
					if .not. empty( cProduto ) .And. SB1->( DbSeek(xFilial("SB1")+cProduto) )
						aadd(aLinha,{"D1_CC",SB1->B1_CC					 ,Nil})
					endif
				endif
			
			
				//FR - 31/03/2021 - Implementar a carga do número de lote do fornecedor para os xmls que possuam a tag "rastro"
				If !Empty(cLote)
					aadd(aLinha,{"D1_LOTEFOR"		, Alltrim(cLote)				     ,Nil})		//tipo C , tamanho 18
					If cUsaLoteFor == "S"
						aadd(aLinha,{"D1_LOTECTL"	, Alltrim(Substr(cLote,1,TamSX3("D1_LOTECTL")[1]))    ,Nil})		
					Endif 
				Endif
				
				If !Empty(dValLote)
					aadd(aLinha,{"D1_DTVALID"		,dValLote			     ,Nil})		//tipo D , tamanho 8
				Endif
				
				If !Empty(cAnoFab)
					aadd(aLinha,{"D1_ANOFAB"		,cAnoFab			     ,Nil})		//tipo C , tamanho 2			
				Endif

				If !Empty(dDatFab)
					aadd(aLinha,{"D1_DFABRIC"		,dDatFab			     ,Nil})		//tipo D , tamanho 8
				Endif	
				
				If lXMLPEITE   //PE para incluir campos no aLinha SD1 -> para o aItens
					
					aRet :=	ExecBlock( "XMLPEITE", .F., .F., { cProduto,oDet,i } )
					If ValType(aRet) == "A"
						AEval(aRet,{|x| AAdd(aLinha,x)})
					EndIf
					
				endif

				if .not. Empty( cProduto )
					
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

				if nVunit > 0 //permitir valor unitário maior zero
					
					If lXMLPELOK   //PE para validar os aItens
						IF ! Empty(cProduto)  //Só se passou pela amarração
							lLOk :=	ExecBlock( "XMLPELOK", .F., .F., { cModelo,cProduto,oDet,i } )
							If ValType(lLOk) <> "L"
								Alert( "Ponto de entrada XMLPELOK deve Retornar .T. ou .F." )
								lLOk := .F.
							EndIf
							if ! lLOk
								Exit
							Endif
						Else
							lLOk := .T.
						EndIf
					Endif
					aadd(aItens,aLinha)
					nD1Item++
					aLinha := {}
					aadd(aItXml,{StrZero(i,4),oDet[i]:_Prod:_CPROD:TEXT,oDet[i]:_Prod:_XPROD:TEXT})
				
				Else  //Lobato também 10/05/18 complemento de IPI
					
					If len(oDet) == 1  //nTotXml > 0 .And.//ADAR //Complemento de Alguma Coisa
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
						aadd(aItens,aLinha)
						nD1Item++
						aLinha := {}
						aadd(aItXml,{StrZero(i,4),oDet[i]:_Prod:_CPROD:TEXT,oDet[i]:_Prod:_XPROD:TEXT})
					EndIf
					
				endif
				//=======================================================//
				//FIM MONTA ARRAY ITENS DA NOTA
				//=======================================================//

							
				nl++
			Enddo

            //--------------------------------------------------------------------------------------------//
            //FR - 30/12/2022 - KIM PÃES - GRAVAÇÃO DO CAMPO ZBT_DEPARA (CÓDIGO INTERNO PRODUTO)
            (xZBT)->(OrdSetFocus(4))
            //Localiza o produto na ZBT e verifica se já foi gravado o código interno no ZBT_DEPARA
            //se já estiver gravado, confere se é o mesmo código obtido agora pela amarração 
            //escolhida pelo usuário, se for o mesmo código, mantém, 
            //se for diferente, grava por cima com a amarração escolhida pelo usuário
            //--------------------------------------------------------------------------------------------//
            If (xZBT)->(Dbseek(xFilial(xZBT) + oDet[i]:_Prod:_XPROD:TEXT)) //ZBT_FILIAL+ZBT_PRODUT+ZBT_PEDIDO+ZBT_ITEMPC
                If Alltrim( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"DEPARA"))) ) <> Alltrim(cProduto)
                    
                    //se for diferente, sobrescreve
                    RecLock(xZBT,.F.)
                        (xZBT)->(FieldPut(FieldPos(xZBT_+"DEPARA"), cProduto ))
                    (xZBT)->( MsUnlock() )                

                Endif
            Endif 
            //--------------------------------------------------------------------------------------------//
            //FR - 30/12/2022 - KIM PÃES - GRAVAÇÃO DO CAMPO ZBT_DEPARA (CÓDIGO INTERNO PRODUTO)
            //--------------------------------------------------------------------------------------------//
             


	 	Endif //lDesmembra 
		
		//TRATATIVA PARA PEGAR A ORIGEM DO PRODUTO
		If XmlChildEx("oDet["+AllTrim(Str(i))+"]:_Imposto:_ICMS","_ICMS00") <> Nil
			if Type("oDet["+AllTrim(Str(i))+"]:_Imposto:_ICMS:_ICMS00:_VBC:TEXT") <> "U"
				cOrige := oDet[i]:_Imposto:_ICMS:_ICMS00:_ORIG:TEXT
			endif 
		Elseif XmlChildEx("oDet["+AllTrim(Str(i))+"]:_Imposto:_ICMS","_ICMS10") <> Nil
			if Type("oDet["+AllTrim(Str(i))+"]:_Imposto:_ICMS:_ICMS10:_VBC:TEXT") <> "U"
				cOrige := oDet[i]:_Imposto:_ICMS:_ICMS10:_ORIG:TEXT
			endif 
		Elseif XmlChildEx("oDet["+AllTrim(Str(i))+"]:_Imposto:_ICMS","_ICMS20") <> Nil
			if Type("oDet["+AllTrim(Str(i))+"]:_Imposto:_ICMS:_ICMS20:_VBC:TEXT") <> "U"
				cOrige := oDet[i]:_Imposto:_ICMS:_ICMS20:_ORIG:TEXT
			endif 
		Elseif XmlChildEx("oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL","_ICMSTOT") <> Nil
			if type("oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VBC:TEXT") <> "U"
				cOrige := oDet[i]:_Imposto:_ICMS:_ICMSTOT:_ORIG:TEXT
			endif 		
		Endif 

		aadd(aItmPE,{StrZero(i,4),cProduto,oDet[i]:_Prod:_CPROD:TEXT,oDet[i]:_Prod:_XPROD:TEXT,oDet[i]:_Prod:_NCM:TEXT,cOrige})
		//aLinha := {}

	Next i

	If lXMLPELOK   //PE Linha OK para validar os Itens
 		if ! lLOk  //Não Validou o Bixo
 			lRetorno := .F.
 			Exit
 		Endif
 	Endif

	//Itens não encontrados
	if .not. U_ItNaoEnc( "PREN", aProdOk, aProdNo, aProdVl, @nErrItens, aProdZr, cTipoCpro )     //FR - 10/03/2022 - ALTERAÇÃO - TransUnião - não estava amarrando ZB5
	    lRetorno := .F.
		Loop
	endif

	If lXMLPETOK   //PE para incluir campos no aLinha SD1 -> para o aItens
 		lTOk :=	ExecBlock( "XMLPETOK", .F., .F., { cModelo } )
 		If ValType(lTOk) <> "L"
 			Alert( "Ponto de entrada XMLPETOK deve Retornar .T. ou .F." )
 			lTOk := .F.
 		EndIf
 		if ! lTOk
 			lRetorno := .F.
 			Exit
 		Endif
	Endif

	cChaveF1 := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))) + (xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA"))) +;
	            (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE")))  + (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR"))) +;
	            (xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR"))) + (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC")))
	//cChaveF1 := ZBZ->ZBZ_FILIAL + ZBZ->ZBZ_NOTA + ZBZ->ZBZ_SERIE + ZBZ->ZBZ_CODFOR + ZBZ->ZBZ_LOJFOR + ZBZ->ZBZ_TPDOC
	DbSelectArea("SF1")
	DbSetOrder(1)

	lSeekNF := DbSeek(cChaveF1)

	If !lSeekNf
	
		If (xZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF"))) $ "N|S"
			lOkGo := MsgYesNo("Pré-nota gerada previamente mas foi excluida.Deseja prosseguir gerando novamente?","Aviso")
			If !lOkGo
				lRetorno := .F.
			EndIf
		EndIf
		
	Else
	
		U_MyAviso("Atenção","Esta NFE já foi importada para a Base!"+CRLF +"Chave :"+cChaveF1,{"OK"},3)
		lRetorno := .F.
		
	EndIf

			//SOLAR
			if lRetorno
				//****************************************************************************
				//Controle de Gravação de Campos específicos ou de escolha do cliente
				//conforme execução de ponto de entrada
				//****************************************************************************

				if lXMLCPCLI

					aCabPE := {}

						aadd(aCabPE,{"CODIGO",cCodEmit})

						aadd(aCabPE,{"LOJA",cLojaEmit})


					//A1_PAIS CPAIS  / XPAIS
					cTagcPais := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_EMIT:_ENDEREMIT:_CPAIS:TEXT"
					cTagXPais := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_EMIT:_ENDEREMIT:_XPAIS:TEXT"

					//A1_CONTRIB  INDIEDEST
					cTagContr := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_DEST:_INDIEDEST:TEXT"

					//A1_COD_MUM CMUN
					cTagcMun := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_EMIT:_ENDEREMIT:_CMUN:TEXT"
					cTagxMun := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_EMIT:_ENDEREMIT:_XMUN:TEXT"

					//A1_CEP CEP
					cTagcCEP := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_EMIT:_ENDEREMIT:_CEP:TEXT"

					//A1_BAIRRO
					cTagBairr := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_EMIT:_ENDEREMIT:_XBAIRRO:TEXT"


					IF TYPE(cTagcPais) <> "U"
						aadd(aCabPE,{"CPAIS",&(cTagcPais)})
					ELSE
						aadd(aCabPE,{"CPAIS",""})
					ENDIF

					IF TYPE(cTagXPais) <> "U"
						aadd(aCabPE,{"XPAIS",&(cTagXPais)})
					ELSE
						aadd(aCabPE,{"XPAIS",""})
					ENDIF

					IF TYPE(cTagContr) <> "U"
						aadd(aCabPE,{"INDIEDEST",&(cTagContr)})
					ELSE
						aadd(aCabPE,{"INDIEDEST",""})
					ENDIF

					IF TYPE(cTagcMun) <> "U"
						aadd(aCabPE,{"CMUN",&(cTagcMun)})
					ELSE
						aadd(aCabPE,{"CMUN",""})
					ENDIF

					IF TYPE(cTagxMun) <> "U"
						aadd(aCabPE,{"XMUN",&(cTagxMun)})
					ELSE
						aadd(aCabPE,{"XMUN",""})
					ENDIF

					IF TYPE(cTagcCEP) <> "U"
						aadd(aCabPE,{"CEP",&(cTagcCEP)})
					ELSE
						aadd(aCabPE,{"CEP",""})
					ENDIF

					IF TYPE(cTagBairr) <> "U"
						aadd(aCabPE,{"BAIRRO",&(cTagBairr)})
					ELSE
						aadd(aCabPE,{"BAIRRO",""})
					ENDIF


					ExecBlock( "XMLCMPCLI", .F., .F., { cModelo,cTipoNF,aCabPE,aItmPE,cChaveXml } )


				ENDIF
			ENDIF
 ElseIf cModelo $ "57,67"
 
	lRetorno := .T.
	cCnpRem := ""
	
	if lNfOri
		if !Empty(cTagDocDest) .And. Type(cTagDocDest) != "U"
			cCnpRem := &cTagDocDest
		endif
	endif

	If cModelo $ "57"

		if type("oXml:_CTEPROC:_CTE:_INFCTE:_VPREST") <> "U"
			oDet := oXml:_CTEPROC:_CTE:_INFCTE:_VPREST
		endif

		cProdCte := Padr(GetNewPar("XM_PRODCTE","FRETE"),nTamProd)
    	cProdCte :=Iif(Empty(cProdCte),Padr("FRETE",nTamProd),cProdCte)

	Else

		if type("oXml:_CTEOSPROC:_CTEOS:_INFCTE:_VPREST") <> "U"
			oDet := oXml:_CTEOSPROC:_CTEOS:_INFCTE:_VPREST
		endif

    	cProdCte :=Iif(Empty(cProdCte),Padr("CTEOS",nTamProd),cProdCte)

	Endif

	If lXMLPEAMA   //PE para Amarração de podrutos //nordsonAmarraCof

			aPEAma := ExecBlock( "XMLPEAMA", .F., .F., { oDet,1,cProdCte,cModelo,cTipoCPro } )

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
						aadd( aProdOk, {cProduto,"PRESTACAO DE SERVICO - FRETE"} )
					Else
						aadd( aProdNo, {cProdCte,"PRESTACAO DE SERVICO - FRETE"} )
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
		aRetProd := u_HFPRDINT(i)

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

	If cTipoCPro == "2" .And. ! lAmaPe // Ararracao Customizada ZB5 Produto tem que estar Amarrados Tanto Cliente como Formecedor
		
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
	ElseIf cTipoCPro == "1"  .And. ! lAmaPe  //nordsonAmarraCof// Amarracao Padrao SA5/SA7

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
					SELECT
						A5_FILIAL,
						A5_FORNECE,
						A5_LOJA,
						A5_CODPRF,
						A5_PRODUTO,
						R_E_C_N_O_
					FROM
						%Table:SA5% SA5
					WHERE
						SA5.%notdel%
						AND A5_FORNECE = %Exp:cCodEmit%
						AND A5_LOJA = %Exp:cLojaEmit%
						AND %Exp:cWhere%
					ORDER BY
						A5_FILIAL,
						A5_FORNECE,
						A5_LOJA,
						A5_CODPRF
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

	nPrest := 0
	if valtype(oDet:_VTPREST:TEXT) <> "U"
		nPrest := ( VAL(oDet:_VTPREST:TEXT) )  //Valor da Prestação do Seviço que  ira ser rateado pelos DOCs que compõe o CTE
	endif
	
	If cModelo == "57" .And. lDetCte .And. Type("oXml:_CTEPROC:_CTE:_INFCTE:_REM:_INFNF") != "U"
		
		oOri := oXml:_CTEPROC:_CTE:_INFCTE:_REM:_INFNF
		oOri := IIf(ValType(oOri)=="O",{oOri},oOri)

		For i := 1 To Len(oOri)
		
			cNfOri := oOri[i]:_NDOC:TEXT
			
			if Val(cNfOri) > 0
				cNfOri := StrZero( Val(cNfOri), len(SD1->D1_NFORI) )
			endif
			
			cSerOri := AllTrim( oOri[i]:_SERIE:TEXT )
			
			if lNfOri
			
				DbSelectArea("SF3")
				DbSetOrder(6)
				DbSeek( xFilial("SF3") + cNfOri + cSerOri )
				
				nValBrut := SF3->F3_VALCONT
			
			else
			
				DbSelectArea("SF2")
				DbSetOrder(1)
				DbSeek( xFilial("SF2") + cNfOri + cSerOri )
				
				nValBrut := SF2->F2_VALBRUT
			
			endif
			
			if nValBrut == 0
			
				lSemNfe := .T.
				aTotal  := {}
				Exit
			
			endif 
			
			nTotNfe += nValBrut
			
			aAdd( aTotal, { nValBrut, 0 } )
			
		Next i 
		
		For y := 1 To Len(aTotal)
		
			aTotal[y,2] := aTotal[y,1] / nTotNfe
		
		Next y

		nTotal := 0
		nIctot := 0
		nVPeda := 0  //Fadiga da OCRIM
		nTPeda := 0

		For i := 1 To Len(oOri)

            If i == Len(oOri)
            
            	nVunit := nPrest - nTotal
            	nBunit := nBaseCTE - nIctot
            	
				if nPedagio > 0  //Fadiga da OCRIM
					nVPeda := nPedagio - nTPeda
				Else
					nVPeda := 0
				endif
				
			else
			
				nVunit := iif( lSemNfe, Round( ( nPrest / Len(oOri) ), 2 ), Round( ( nPrest * aTotal[i,2] ), 2 ) )				
				nBunit := iif( lSemNfe, Round( ( nBaseCTE / Len(oOri) ), 2 ), Round( ( nBaseCTE * aTotal[i,2]  ), 2 ) )
				
				if nPedagio > 0  //Fadiga da OCRIM
					nVPeda := iif( lSemNfe, Round( ( nPedagio / Len(oOri) ), 2 ), Round( ( nPedagio * aTotal[i,2]  ), 2 ) )
				endif
				
            EndIf
            
			nTPeda += nVPeda
            nTotal += nVunit
            nIctot += nBunit
			aLinha = {}
			
			cNfOri := oOri[i]:_NDOC:TEXT
			
			if Val(cNfOri) > 0
				cNfOri := StrZero( Val(cNfOri), len(SD1->D1_NFORI) )
			endif
			
			cSerOri := AllTrim( oOri[i]:_SERIE:TEXT )
			cCnpRem := ""
			_cCCusto:= ""
			_cCc    := ""
			
			if lNfOri
			
				if Type(cTagDocDest) != "U"
					cCnpRem := &cTagDocDest
				endif
				
				if .not. empty(cCnpRem)
					U_ExistSf3( @cNfOri, @cSerOri,,,,, @_cCc )
				endif
				
			else
			
				U_ExistDoc( @cNfOri, @cSerOri,,,,, @_cCc )
				
			endif
			
			if _lCCusto
				_cCCusto := _cCc
			endif
			
			aadd( aCnpRem, cCnpRem )
			
			aadd(aLinha,{"D1_ITEM" ,StrZero(i,4,0)           ,Nil})
			aadd(aLinha,{"D1_COD"  ,cProduto                 ,Nil})
			aadd(aLinha,{"D1_QUANT",1                        ,Nil})
			aadd(aLinha,{"D1_NFORI",cNfOri				     ,Nil})
			aadd(aLinha,{"D1_SERIORI",cSerOri				 ,Nil})
			aadd(aLinha,{"D1_VUNIT",nVunit					 ,Nil})
			aadd(aLinha,{"D1_TOTAL",nVunit					 ,Nil})
			
			if nVPeda > 0
				aadd(aLinha,{"D1_PEDAGIO",nVPeda			 ,Nil})
			Endif

			if .NOT. Empty( _cCCusto )  //aqui idepende o parâmetro anterior por que utiliza o mesmo da nf principal
				aadd(aLinha,{"D1_CC"    ,_cCCusto  					 ,Nil})
			elseif cPCSol == "S"  //Centro de Custo do Pedido, então manda vazio para pegar do pedido ao relacionar o pedido F5 ou F6
				aadd(aLinha,{"D1_CC"    ,nTamCc  					 ,Nil})
			elseif cPCSol != "Z"   //=> Com o Z não preenche o D1_CC, senão ao caso utilizar um gatilho poderia sobrepor o gatilho
				if .not. empty( cProduto ) .And. SB1->( DbSeek(xFilial("SB1")+cProduto) )
					aadd(aLinha,{"D1_CC",SB1->B1_CC					 ,Nil})
				endif
			endif
			
			If nAliqCte > 0
				aadd(aLinha,{"D1_PICM",nAliqCte             ,Nil})
			EndIf
			
			If nBunit > 0
				aadd(aLinha,{"D1_BASEICM",nBunit             ,Nil})
			EndIf
			
			If nAliqCte > 0 .And. nBunit > 0
				aadd(aLinha,{"D1_VALICM",(nBunit*(nAliqCte/100)),Nil})
			EndIf

			If lXMLPEITE   //PE para incluir campos no aLinha SD1 -> para o aItens
				
				aRet :=	ExecBlock( "XMLPEITE", .F., .F., { cProduto,oDet,i } )
				
				If ValType(aRet) == "A"
					AEval(aRet,{|x| AAdd(aLinha,x)})
				EndIf
				
			endif

 			If lXMLPELOK   //PE para lin OK
 			
 				IF ! Empty(cProduto)  //Só se passou pela amarração
 					
 					lLOk :=	ExecBlock( "XMLPELOK", .F., .F., { cModelo,cProduto,oDet,i } )
	 				
	 				If ValType(lLOk) <> "L"
	 					Alert( "Ponto de entrada XMLPELOK deve Retornar .T. ou .F." )
	 					lLOk := .F.
	 				EndIf
	 				
	 				if ! lLOk
	 					Exit
	 				Endif
	 				
	 			Else
	 			
	 				lLOk := .T.
	 				
	 			EndIf
	 			
 			Endif

			aadd(aItens,aLinha)

		Next i

	ElseIf cModelo == "57" .And. lDetCte .And. Type("oXml:_CTEPROC:_CTE:_INFCTE:_REM:_INFNFE") != "U"
		
		oOri := oXml:_CTEPROC:_CTE:_INFCTE:_REM:_INFNFE
		oOri := IIf(ValType(oOri)=="O",{oOri},oOri)

		For i := 1 To Len(oOri)
		
			if lNfOri
				aDocDaChave := U_Sf3DaChave( oOri[i]:_CHAVE:TEXT,,,,,@_cCc )  //Pegar Documentos no SF3
			else
				aDocDaChave := U_DocDaChave( oOri[i]:_CHAVE:TEXT,,,,,@_cCc )  //Pegar Documentos no SF2
			endif
			
			if lNfOri
			
				DbSelectArea("SF3")
				DbSetOrder(6)
				DbSeek( xFilial("SF3") + aDocDaChave[1] + aDocDaChave[2] )
				
				nValBrut := SF3->F3_VALCONT
			
			else
			
				DbSelectArea("SF2")
				DbSetOrder(1)
				DbSeek( xFilial("SF2") + aDocDaChave[1] + aDocDaChave[2] )
				
				nValBrut := SF2->F2_VALBRUT
			
			endif
			
			if nValBrut == 0
			
				lSemNfe := .T.
				aTotal  := {}
				Exit
			
			endif 
			
			nTotNfe += nValBrut
			
			aAdd( aTotal, { nValBrut, 0 } )
			
		Next i 
		
		For y := 1 To Len(aTotal)
		
			aTotal[y,2] := aTotal[y,1] / nTotNfe
		
		Next y

		nTotal := 0
		nIctot := 0
		nVPeda := 0  //Fadiga da OCRIM
		nTPeda := 0

		For i := 1 To Len(oOri)

            If i == Len(oOri)
            
            	nVunit := nPrest - nTotal
            	nBunit := nBaseCTE - nIctot
            	
				if nPedagio > 0  //Fadiga da OCRIM
					nVPeda := nPedagio - nTPeda
				Else
					nVPeda := 0
				endif
				
			else
			
				nVunit := iif( lSemNfe, Round( ( nPrest / Len(oOri) ), 2 ), Round( ( nPrest * aTotal[i,2] ), 2 ) )				
				nBunit := iif( lSemNfe, Round( ( nBaseCTE / Len(oOri) ), 2 ), Round( ( nBaseCTE * aTotal[i,2]  ), 2 ) )
				
				if nPedagio > 0  //Fadiga da OCRIM
					nVPeda := iif( lSemNfe, Round( ( nPedagio / Len(oOri) ), 2 ), Round( ( nPedagio * aTotal[i,2]  ), 2 ) )
				endif
				
            EndIf
            
			nTPeda += nVPeda
            nTotal += nVunit
            nIctot += nBunit
            
            cCnpRem := ""
			aLinha = {}
			_cCCusto:= ""
			_cCc    := ""
			
			if _lCCusto
				_cCCusto := _cCc
			endif
			
			aadd( aCnpRem, cCnpRem )
			
			if lNfOri
				aDocDaChave := U_Sf3DaChave( oOri[i]:_CHAVE:TEXT,,,,,@_cCc )  //Pegar Documentos no SF3
			else
				aDocDaChave := U_DocDaChave( oOri[i]:_CHAVE:TEXT,,,,,@_cCc )  //Pegar Documentos no SF2
			endif

			cNfOri := aDocDaChave[1]
			cSerOri := aDocDaChave[2]
			
			aadd(aLinha,{"D1_ITEM" ,StrZero(i,4,0)          ,Nil})
			aadd(aLinha,{"D1_COD"  ,cProduto                 ,Nil})
			aadd(aLinha,{"D1_QUANT",1                        ,Nil})
			aadd(aLinha,{"D1_NFORI",cNfOri				     ,Nil})
			aadd(aLinha,{"D1_SERIORI",cSerOri				 ,Nil})
			aadd(aLinha,{"D1_VUNIT",nVunit					 ,Nil})
			aadd(aLinha,{"D1_TOTAL",nVunit					 ,Nil})
			
			if nVPeda > 0
				aadd(aLinha,{"D1_PEDAGIO",nVPeda			 ,Nil})
				aadd(aLinha,{"D1_BASEPIS",nVunit-nVPeda		,Nil})
				aadd(aLinha,{"D1_BASECOF",nVunit-nVPeda		,Nil})
				aadd(aLinha,{"D1_BASECSL",nVunit-nVPeda		,Nil})
			Endif

			if .NOT. Empty( _cCCusto )
				aadd(aLinha,{"D1_CC"    ,_cCCusto  					 ,Nil})
			elseif cPCSol == "S"  //Centro de Custo do Pedido, então manda vazio para pegar do pedido ao relacionar o pedido F5 ou F6
				aadd(aLinha,{"D1_CC"    ,nTamCc  					 ,Nil})
			elseif cPCSol != "Z"   //=> Com o Z não preenche o D1_CC, senão ao caso utilizar um gatilho poderia sobrepor o gatilho
				if .not. empty( cProduto ) .And. SB1->( DbSeek(xFilial("SB1")+cProduto) )
					aadd(aLinha,{"D1_CC",SB1->B1_CC					 ,Nil})
				endif
			endif
			
			If nAliqCte > 0
				aadd(aLinha,{"D1_PICM",nAliqCte             ,Nil})
			EndIf
			
			If nBunit > 0
				aadd(aLinha,{"D1_BASEICM",nBunit             ,Nil})
			EndIf
			
			If nAliqCte > 0 .And. nBunit > 0
				aadd(aLinha,{"D1_VALICM",(nBunit*(nAliqCte/100)),Nil})
			EndIf

			If lXMLPEITE   //PE para incluir campos no aLinha SD1 -> para o aItens
				aRet :=	ExecBlock( "XMLPEITE", .F., .F., { cProduto,oDet,i } )
				If ValType(aRet) == "A"
					AEval(aRet,{|x| AAdd(aLinha,x)})
				EndIf
			endif

 			If lXMLPELOK   //PE para lin OK
 			
 				IF ! Empty(cProduto)  //Só se passou pela amarração
 				
 					lLOk :=	ExecBlock( "XMLPELOK", .F., .F., { cModelo,cProduto,oDet,i } )
	 				
	 				If ValType(lLOk) <> "L"
	 					Alert( "Ponto de entrada XMLPELOK deve Retornar .T. ou .F." )
	 					lLOk := .F.
	 				EndIf
	 				
	 				if ! lLOk
	 					Exit
	 				Endif
	 				
	 			Else
	 			
	 				lLOk := .T.
	 				
	 			EndIf
	 			
 			Endif

			aadd(aItens,aLinha)

		Next i

	ElseIf cModelo == "57" .And. lDetCte .And. Type("oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF") != "U"
		
		oOri := oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF
		oOri := IIf(ValType(oOri)=="O",{oOri},oOri)
		
		For i := 1 To Len(oOri)
		
			cNfOri := oOri[i]:_NDOC:TEXT
			
			if Val(cNfOri) > 0
				cNfOri := StrZero( Val(cNfOri), len(SD1->D1_NFORI) )
			endif
			
			cSerOri := AllTrim( oOri[i]:_SERIE:TEXT )
			
			if lNfOri
			
				DbSelectArea("SF3")
				DbSetOrder(6)
				DbSeek( xFilial("SF3") + cNfOri + cSerOri )
				
				nValBrut := SF3->F3_VALCONT
			
			else
			
				DbSelectArea("SF2")
				DbSetOrder(1)
				DbSeek( xFilial("SF2") + cNfOri + cSerOri )
				
				nValBrut := SF2->F2_VALBRUT
			
			endif
			
			if nValBrut == 0
			
				lSemNfe := .T.
				aTotal  := {}
				Exit
			
			endif 
			
			nTotNfe += nValBrut
			
			aAdd( aTotal, { nValBrut, 0 } )
			
		Next i 
		
		For y := 1 To Len(aTotal)
		
			aTotal[y,2] := aTotal[y,1] / nTotNfe
		
		Next y

		nTotal := 0
		nIctot := 0
		nVPeda := 0 //Fadiga da OCRIM
		nTPeda := 0

		For i := 1 To Len(oOri)

            If i == Len(oOri)
            
            	nVunit := nPrest - nTotal
            	nBunit := nBaseCTE - nIctot
            	
				if nPedagio > 0  //Fadiga da OCRIM
					nVPeda := nPedagio - nTPeda
				Else
					nVPeda := 0
				endif
				
			else
			
				nVunit := iif( lSemNfe, Round( (  nPrest/ Len(oOri) ), 2 ), Round( ( nPrest * aTotal[i,2] ), 2 ) )				
				nBunit := iif( lSemNfe, Round( ( nBaseCTE / Len(oOri) ), 2 ), Round( ( nBaseCTE * aTotal[i,2]  ), 2 ) )
				
				if nPedagio > 0  //Fadiga da OCRIM
					nVPeda := iif( lSemNfe, Round( ( nPedagio / Len(oOri) ), 2 ), Round( ( nPedagio * aTotal[i,2]  ), 2 ) )
				endif
				
            EndIf
            
			nTPeda += nVPeda
            nTotal += nVunit
            nIctot += nBunit
			aLinha = {}
			cNfOri := oOri[i]:_NDOC:TEXT
			
			if Val(cNfOri) > 0
				cNfOri := StrZero( Val(cNfOri), len(SD1->D1_NFORI) )
			endif
			
			cSerOri := AllTrim( oOri[i]:_SERIE:TEXT )
			cCnpRem := ""
			_cCCusto:= ""
			_cCc    := ""
			
			if lNfOri
			
				if Type(cTagDocDest) != "U"
					cCnpRem := &cTagDocDest
				endif
				
				if .not. empty(cCnpRem)
					U_ExistSf3( @cNfOri, @cSerOri,,,,, @_cCc )
				endif
				
			else
			
				U_ExistDoc( @cNfOri, @cSerOri,,,,, @_cCc )
				
			endif
			
			if _lCCusto
				_cCCusto := _cCc
			endif
			
			aadd( aCnpRem, cCnpRem )
			
			aadd(aLinha,{"D1_ITEM" ,StrZero(i,4,0)          ,Nil})
			aadd(aLinha,{"D1_COD"  ,cProduto                 ,Nil})
			aadd(aLinha,{"D1_QUANT",1                        ,Nil})
			aadd(aLinha,{"D1_NFORI",cNfOri				     ,Nil})
			aadd(aLinha,{"D1_SERIORI",cSerOri				 ,Nil})
			aadd(aLinha,{"D1_VUNIT",nVunit					 ,Nil})
			aadd(aLinha,{"D1_TOTAL",nVunit					 ,Nil})
			
			if nVPeda > 0
				aadd(aLinha,{"D1_PEDAGIO",nVPeda			 ,Nil})
				aadd(aLinha,{"D1_BASEPIS",nVunit-nVPeda		,Nil})
				aadd(aLinha,{"D1_BASECOF",nVunit-nVPeda		,Nil})
				aadd(aLinha,{"D1_BASECSL",nVunit-nVPeda		,Nil})
			Endif

			if .NOT. Empty( _cCCusto )
				aadd(aLinha,{"D1_CC"    ,_cCCusto  					 ,Nil})
			elseif cPCSol == "S"  //Centro de Custo do Pedido, então manda vazio para pegar do pedido ao relacionar o pedido F5 ou F6
				aadd(aLinha,{"D1_CC"    ,nTamCc  					 ,Nil})
			elseif cPCSol != "Z"   //=> Com o Z não preenche o D1_CC, senão ao caso utilizar um gatilho poderia sobrepor o gatilho
				if .not. empty( cProduto ) .And. SB1->( DbSeek(xFilial("SB1")+cProduto) )
					aadd(aLinha,{"D1_CC",SB1->B1_CC					 ,Nil})
				endif
			endif
			
			If nAliqCte > 0
				aadd(aLinha,{"D1_PICM",nAliqCte             ,Nil})
			EndIf
			
			If nBunit > 0
				aadd(aLinha,{"D1_BASEICM",nBunit             ,Nil})
			EndIf
			
			If nAliqCte > 0 .And. nBunit > 0
				aadd(aLinha,{"D1_VALICM",(nBunit*(nAliqCte/100)),Nil})
			EndIf

			If lXMLPEITE   //PE para incluir campos no aLinha SD1 -> para o aItens
				aRet :=	ExecBlock( "XMLPEITE", .F., .F., { cProduto,oDet,i } )
				If ValType(aRet) == "A"
					AEval(aRet,{|x| AAdd(aLinha,x)})
				EndIf
			endif

 			If lXMLPELOK   //PE para lin OK
 			
 				IF ! Empty(cProduto)  //Só se passou pela amarração
 				
 					lLOk :=	ExecBlock( "XMLPELOK", .F., .F., { cModelo,cProduto,oDet,i } )
 					
	 				If ValType(lLOk) <> "L"
	 					Alert( "Ponto de entrada XMLPELOK deve Retornar .T. ou .F." )
	 					lLOk := .F.
	 				EndIf
	 				if ! lLOk
	 					Exit
	 				Endif
	 				
	 			Else
	 			
	 				lLOk := .T.
	 				
	 			EndIf
	 			
 			Endif

			aadd(aItens,aLinha)

		Next i

	ElseIf cModelo == "57" .And. lDetCte .And. Type("oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE") != "U"
		
		oOri := oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE  
		oOri := IIf(ValType(oOri) == "O",{oOri},oOri)
		
		For i := 1 To Len(oOri)
		
			if lNfOri
				aDocDaChave := U_Sf3DaChave( oOri[i]:_CHAVE:TEXT,,,,,@_cCc )  //Pegar Documentos no SF3
			else
				aDocDaChave := U_DocDaChave( oOri[i]:_CHAVE:TEXT,,,,,@_cCc )  //Pegar Documentos no SF2
			endif
			
			if lNfOri
			
				DbSelectArea("SF3")
				DbSetOrder(6)
				DbSeek( xFilial("SF3") + aDocDaChave[1] + aDocDaChave[2] )
				
				nValBrut := SF3->F3_VALCONT
			
			else
			
				DbSelectArea("SF2")
				DbSetOrder(1)
				DbSeek( xFilial("SF2") + aDocDaChave[1] + aDocDaChave[2] )
				
				nValBrut := SF2->F2_VALBRUT
			
			endif
			
			if nValBrut == 0
			
				lSemNfe := .T.
				aTotal  := {}
				Exit
			
			endif 
			
			nTotNfe += nValBrut
			
			aAdd( aTotal, { nValBrut, 0 } )
			
		Next i 
		
		For y := 1 To Len(aTotal)
		
			aTotal[y,2] := aTotal[y,1] / nTotNfe
		
		Next y
		
		nTotal := 0
		nIctot := 0
		nVPeda := 0 //Fadiga da OCRIM
		nTPeda := 0

		For i := 1 To Len(oOri)

            If i == Len(oOri)
            
            	nVunit := nPrest - nTotal
            	nBunit := nBaseCTE - nIctot
            	
				if nPedagio > 0  //Fadiga da OCRIM
					nVPeda := nPedagio - nTPeda
				Else
					nVPeda := 0
				endif
				
			else 
			
				nVunit := iif( lSemNfe, Round( ( nPrest / Len(oOri) ), 2 ), Round( ( nPrest * aTotal[i,2] ), 2 ) )				
				nBunit := iif( lSemNfe, Round( ( nBaseCTE / Len(oOri) ), 2 ), Round( ( nBaseCTE * aTotal[i,2]  ), 2 ) )
				
				if nPedagio > 0  //Fadiga da OCRIM
					nVPeda := iif( lSemNfe, Round( ( nPedagio / Len(oOri) ), 2 ), Round( ( nPedagio * aTotal[i,2]  ), 2 ) )
				endif
				
            EndIf
            
			nTPeda += nVPeda
            nTotal += nVunit
            nIctot += nBunit
			aLinha = {}
			cCnpRem := ""
			_cCCusto:= ""
			_cCc    := ""
			
			if lNfOri
				aDocDaChave := U_Sf3DaChave( oOri[i]:_CHAVE:TEXT,,,,,@_cCc )  //Pegar Documentos no SF3
			else
				aDocDaChave := U_DocDaChave( oOri[i]:_CHAVE:TEXT,,,,,@_cCc )  //Pegar Documentos no SF2
			endif

			if _lCCusto
				_cCCusto := _cCc
			endif
			
			aadd( aCnpRem, cCnpRem )
			
			cNfOri := aDocDaChave[1]
			cSerOri := aDocDaChave[2]
			
			aadd(aLinha,{"D1_ITEM" ,StrZero(i,4,0)           ,Nil})
			aadd(aLinha,{"D1_COD"  ,cProduto                 ,Nil})
			aadd(aLinha,{"D1_QUANT",1                        ,Nil})
			aadd(aLinha,{"D1_NFORI",cNfOri				     ,Nil})
			aadd(aLinha,{"D1_SERIORI",cSerOri				 ,Nil})
			aadd(aLinha,{"D1_VUNIT",nVunit					 ,Nil})
			aadd(aLinha,{"D1_TOTAL",nVunit					 ,Nil})
			
			if nVPeda > 0
				aadd(aLinha,{"D1_PEDAGIO",nVPeda			,Nil})
				aadd(aLinha,{"D1_BASEPIS",nVunit-nVPeda		,Nil})
				aadd(aLinha,{"D1_BASECOF",nVunit-nVPeda		,Nil})
				aadd(aLinha,{"D1_BASECSL",nVunit-nVPeda		,Nil})
			Endif

			if .NOT. Empty( _cCCusto )
				aadd(aLinha,{"D1_CC"    ,_cCCusto  					 ,Nil})
			elseif cPCSol == "S"  //Centro de Custo do Pedido, então manda vazio para pegar do pedido ao relacionar o pedido F5 ou F6
				aadd(aLinha,{"D1_CC"    ,nTamCc  					 ,Nil})
			elseif cPCSol != "Z"   //=> Com o Z não preenche o D1_CC, senão ao caso utilizar um gatilho poderia sobrepor o gatilho
				if .not. empty( cProduto ) .And. SB1->( DbSeek(xFilial("SB1")+cProduto) )
					aadd(aLinha,{"D1_CC",SB1->B1_CC					 ,Nil})
				endif
			endif
			
			If nAliqCte > 0
				aadd(aLinha,{"D1_PICM",nAliqCte             ,Nil})
			EndIf
			
			If nBunit > 0
				aadd(aLinha,{"D1_BASEICM",nBunit             ,Nil})
			EndIf
			
			If nAliqCte > 0 .And. nBunit > 0
				aadd(aLinha,{"D1_VALICM",(nBunit*(nAliqCte/100)),Nil})
			EndIf

			If lXMLPEITE   //PE para incluir campos no aLinha SD1 -> para o aItens
				aRet :=	ExecBlock( "XMLPEITE", .F., .F., { cProduto,oDet,i } )
				If ValType(aRet) == "A"
					AEval(aRet,{|x| AAdd(aLinha,x)})
				EndIf
			endif

 			If lXMLPELOK   //PE para lin OK
 				IF ! Empty(cProduto)  //Só se passou pela amarração
 					lLOk :=	ExecBlock( "XMLPELOK", .F., .F., { cModelo,cProduto,oDet,i } )
	 				If ValType(lLOk) <> "L"
	 					Alert( "Ponto de entrada XMLPELOK deve Retornar .T. ou .F." )
	 					lLOk := .F.
	 				EndIf
	 				if ! lLOk
	 					Exit
	 				Endif
	 			Else
	 				lLOk := .T.
	 			EndIf
 			Endif

			aadd(aItens,aLinha)

		Next i

	Else
	
		//cModelo == "67" .OR. lDetCte := .F.
		lTagOri := .F.
		nPrest := ( VAL(oDet:_VTPREST:TEXT) )
		
		aadd( aCnpRem, cCnpRem )
		aadd(aLinha,{"D1_ITEM" ,"0001"                  ,Nil})
		aadd(aLinha,{"D1_COD"  ,cProduto                ,Nil})
		//Erick Gonça - 22/09/2022 - IF criado para não apresentar a quantidade no compl. de preço e frete.

		If cTpCompl == ""
			aadd(aLinha,{"D1_QUANT",1                       ,Nil})
		Elseif cTpCompl == "1|3"
			//aadd(aLinha,{"D1_QUANT",1                       ,Nil})
		Elseif cTpCompl == "2"
			aadd(aLinha,{"D1_QUANT",1                       ,Nil})
		Endif

			aadd(aLinha,{"D1_VUNIT",nPrest ,Nil})
			aadd(aLinha,{"D1_TOTAL",nPrest ,Nil})
		
		if nPedagio > 0
			aadd(aLinha,{"D1_PEDAGIO",nPedagio			,Nil})
			aadd(aLinha,{"D1_BASEPIS",nPrest-nPedagio	,Nil})
			aadd(aLinha,{"D1_BASECOF",nPrest-nPedagio	,Nil})
			aadd(aLinha,{"D1_BASECSL",nPrest-nPedagio	,Nil})
		Endif
		
		if cPCSol == "S"  //Centro de Custo do Pedido, então manda vazio para pegar do pedido ao relacionar o pedido F5 ou F6
			aadd(aLinha,{"D1_CC"    ,nTamCc  					 ,Nil})
		elseif cPCSol != "Z"   //=> Com o Z não preenche o D1_CC, senão ao caso utilizar um gatilho poderia sobrepor o gatilho
			if .not. empty( cProduto ) .And. SB1->( DbSeek(xFilial("SB1")+cProduto) )
				aadd(aLinha,{"D1_CC",SB1->B1_CC					 ,Nil})
			endif
		endif
		
		If nAliqCte > 0
			aadd(aLinha,{"D1_PICM",nAliqCte             ,Nil})
		EndIf
		
		If nBaseCTE > 0
			aadd(aLinha,{"D1_BASEICM",nBaseCTE          ,Nil})
		EndIf
		
		If nAliqCte > 0 .And. nBaseCTE > 0
			aadd(aLinha,{"D1_VALICM",(nBaseCTE*(nAliqCte/100)),Nil})
		EndIf

		If lXMLPEITE   //PE para incluir campos no aLinha SD1 -> para o aItens
			aRet :=	ExecBlock( "XMLPEITE", .F., .F., { cProduto,oDet,1 } )
			If ValType(aRet) == "A"
				AEval(aRet,{|x| AAdd(aLinha,x)})
			EndIf
		endif

		If lXMLPELOK   //PE para incluir campos no aLinha SD1 -> para o aItens
			IF ! Empty(cProduto)  //Só se passou pela amarração
				lLOk :=	ExecBlock( "XMLPELOK", .F., .F., { cModelo,cProduto,oDet,1 } )
 				If ValType(lLOk) <> "L"
 					Alert( "Ponto de entrada XMLPELOK deve Retornar .T. ou .F." )
 					lLOk := .F.
 				EndIf
 				if ! lLOk
 					lretorno := .F.
 					Exit
 				Endif
 			Else
 				lLOk := .T.
 			EndIf
 		Endif

		aadd(aItens,aLinha)

	EndIf

	If lXMLPELOK   //PE Linha OK para validar os Itens
 		if ! lLOk  //Não Validou o Bixo
 			lRetorno := .F.
 			Exit
 		Endif
 	Endif

	If .not. empty( cProduto )
		if SB1->( DbSeek(xFilial("SB1")+cProduto) )
			If SB1->( FieldGet(FieldPos("B1_MSBLQL")) ) == "1"
				aadd(aProdNo,{cProduto,"Produto Bloqueado SB1->"+SB1->B1_DESC} )
			EndIf
		ElseIf cTipoCPro != "3"
			aadd(aProdNo,{cProduto,"Não Cadastrado SB1->"+"PRESTACAO DE SERVICO - FRETE"} )
		EndIf
	EndIf

	if VAL(oDet:_VTPREST:TEXT) <= 0
		aadd(aProdZr, { "0001", cProdCte, cProduto, VAL(oDet:_VTPREST:TEXT), "PRESTACAO DE SERVICO - FRETE" } )
	endif

 	aadd(aItXml,{"0001",cProdCte,Posicione("SB1",1,xFilial("SB1")+cProdCte,"B1_DESC")})
	aLinha := {}

	if .not. U_ItNaoEnc( "PREN", aProdOk, aProdNo, aProdVl, @nErrItens, aProdZr, cTipoCpro )
	    lRetorno := .F.
		Loop
	endif

	If lXMLPETOK   //PE tudo OK
 		lTOk :=	ExecBlock( "XMLPETOK", .F., .F., { cModelo } )
 		If ValType(lTOk) <> "L"
 			Alert( "Ponto de entrada XMLPETOK deve Retornar .T. ou .F." )
 			lTOk := .F.
 		EndIf
 		if ! lTOk
 			lRetorno := .F.
 			Exit
 		Endif
	Endif

	cChaveF1 := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))) + (xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA"))) +;
	            (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE")))  + (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR"))) +;
	            (xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR"))) + (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC")))
	//cChaveF1 := ZBZ->ZBZ_FILIAL + ZBZ->ZBZ_NOTA + ZBZ->ZBZ_SERIE + ZBZ->ZBZ_CODFOR + ZBZ->ZBZ_LOJFOR + ZBZ->ZBZ_TPDOC
	DbSelectArea("SF1")
	DbSetOrder(1)

	lSeekNF := DbSeek(cChaveF1)

	If !lSeekNf
		If (xZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF"))) $ "N|S"
			lOkGo := MsgYesNo("Pré-nota gerada previamente mas foi excluida.Deseja prosseguir gerando novamente?","Aviso")
			If !lOkGo
				lRetorno := .F.
			EndIf
		EndIf
	Else
		U_MyAviso("Atenção","Esta NFE já foi importada para a Base!"+CRLF +"Chave :"+cChaveF1,{"OK"},3)
		lRetorno := .F.
	EndIf

 ElseIf cModelo == "RP"

 	If .NOT. U_HFPRNNFS(@nErrItens)
	    lRetorno := .F.
		Loop
	endif

 EndIf

 Exit //só para o nErrItens checar o erro, caso ele inclua pelo DePara a 2a vez estará certo e ele continuará com o aitens preenchido

EndDo

if cTipoCPro $ '4,5'     //nordsonAmarraCof

	//Se o cabra tiver escolhido por pedido ou virtal e tiver ponto de entrada ele tera de fazer as tais
	//variáveis, aItens e o escambal. Caso não quiera ele só retorna NIL a Bagaça que ele procede dentro da
	//normalidade.
	cProdCte := ""
	oDet := {}
	
	if Type( "oXml:_NFEPROC:_NFE:_INFNFE:_DET" ) <> "U"
		oDet := oXml:_NFEPROC:_NFE:_INFNFE:_DET
		oDet := IIf(ValType(oDet)=="O",{oDet},oDet)
	ElseIf Type( "oXml:_CTEPROC:_CTE:_INFCTE:_VPREST" ) <> "U"  //Se Foire CTE
		oDet := oXml:_CTEPROC:_CTE:_INFCTE:_VPREST
		cProdCte := Padr(GetNewPar("XM_PRODCTE","FRETE"),nTamProd)
    	cProdCte :=Iif(Empty(cProdCte),Padr("FRETE",nTamProd),cProdCte)
	ElseIf Type( "oXml:_CTEOSPROC:_CTEOS:_INFCTE:_VPREST" ) <> "U"  //Se Foire CTEOS
		oDet := oXml:_CTEOSPROC:_CTEOS:_INFCTE:_VPREST
		cProdCte := Padr(GetNewPar("XM_PRODCTE","FRETE"),nTamProd)
    	cProdCte :=Iif(Empty(cProdCte),Padr("FRETE",nTamProd),cProdCte)
  	ElseIf Type( "oXml:_NFSETXT:_INFPROC" )  <> "U" //Se for NFSe NFCE_03 16/05, usado cProdCte só para passar no msm parÂmetro
		oDet := oXml:_NFSETXT:_INFPROC
		cProdCte := Padr(GetNewPar("XM_PRODNFS","SERVICO"),nTamProd)
    	cProdCte :=Iif(Empty(cProdNfse),Padr("SERVICO",nTamProd),cProdCte)
	Endif
	
	lAmaPe   := .F.
	aItens   := {}
	nAmarris := 1
	cPedidis := ""
	
	If lXMLPEAMA      //PE para Amarração de produtos
		aPEAma := ExecBlock( "XMLPEAMA", .F., .F., { oDet,1,cProdCte,cModelo,cTipoCPro } )
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
			if empty(aItens)   //para esse tipo, se não tiver aItens, então tem que pedir a amarração
				lAmaPe := .F.
			Else
				lAmaPe := .T.
			Endif
		endif
	else
		lAmaPe := .F.
	EndIf
Endif

if cTipoCPro == '4'  .And. ! lAmaPe

	aItens   := {}
	nAmarris := 1
	cPedidis := ""	
	aRetorno := {}
	aPedidos := {}
	//nValorXml:= 0        //FR - 14/06/2022 - BRASMOLDE - JÁ VALIDA POR ITEM, NÃO PODE SER PELO TOTAL SEGUNDO SOLICITADO PELA CLIENTE
	
	aRetorno := U_HFXMLPED(cCodEmit,cLojaEmit,"N")
	If Len(aRetorno) > 0
		lRetorno := aRetorno[1] 
		aPedidos := aRetorno[2]                                   
		nAmarris := 2
	Endif 
    //FR - 14/06/2022 - BRASMOLDE - JÁ VALIDA POR ITEM, NÃO PODE SER PELO TOTAL SEGUNDO SOLICITADO PELA CLIENTE
    /*
	If ExistBlock("HFXMLVLPED")
	  nValorXML := oXml:_NFEPROC:_NFE:_INFNFE:_COBR:_FAT:_VLIQ:TEXT
			U_HFXMLVLPED( aPedidos ,nValorXml)
			lRetorno := lContVlPed
	EndIf
	*/
ElseIf cTipoCPro == '5'  .And. ! lAmaPe     //nordsonAmarra
	
	aItens   := {}
	nAmarris := 0
	cPedidis := ""
	lRetorno := U_HFXMLVTL(cCodEmit,cLojaEmit,"N")
	
endif


If lRetorno .And. lXMLPEVAL
	
	if Len(aIteErr)>0
		aErr := ExecBlock( "XMLPEVAL", .F., .F., { aCabErr,aIteErr } )
		lRetorno := aErr[1]
		if lRetorno
			//aItens
			aCabErr2 := aErr[2]
			aIteErr2 := aErr[3]
			if lXMLPEATU
				lRetorno := ExecBlock( "XMLPEATU", .F., .F., { aCabErr2,aIteErr2 } )
			endif
		endIF
	endif

EndIF

If lXMLPEVAL .And. lXMLPEREG
	ExecBlock( "XMLPEREG", .F., .F., { "F",,,,,,, } )  //Para Excluir o TMP
EndIF

lTemTESPC   := .F.		//FR - 19/06/2020 - TÓPICOS RAFAEL - indica se o pedido de compra já possui TES
lSemTES     := .F.		//FR - 19/06/2020 - TÓPICOS RAFAEL
cCondPag    := ""		//FR - 19/06/2020 - TÓPICOS RAFAEL
lTESBloq	:= .F.		//FR - 19/06/2020 - TÓPICOS RAFAEL
lGera		:= .F.		//FR - 19/06/2020 - TÓPICOS RAFAEL
cMsgExec    := ""		//FR - 19/06/2020 - TÓPICOS RAFAEL
lPCTES		:= .F.		//FR - 19/06/2020 - TÓPICOS RAFAEL - indica que executou a tela de divergência no pedido de compra
cNATUREZ    := ""		//FR - 18/04/2023 - VYDENCE - usado na tela de informar TES, COND.PAGTO qdo parametrizado para "GERAR DOCUMENTO ENTRADA DIRETO"

						

//FR - a partir daqui, Geração de pré-NF ou NOTA FISCAL e as validações para TELA DIVERGÊNCIA
If lRetorno

	//If cTipoNF $ "D/N/B" // dDevolução NT2013.005_v1.02_Versao_Nacional_2013
	
	//Verifica as notas referenciadas
	u_NTReferenc( oXml )
			
	//endif

	//FR - 22/06/2020 - cria a posição do TES no array de itens da NF, e depois sim, povoa com o TES (Caso haja no pedido ou no produto).
	//aLinha := {"D1_TES","",Nil} 	//FR - 22/06/2020 - esta linha será adicionada a cada item da NF

	//For nX := 1 to Len(aItens)    
    //	aadd(aItens[nX], aLinha)	//FR - 22/06/2020 - já cria aqui a linha do TES, depois só povoa
 	//Next
	//FR - 22/06/2020

	aCols    := {}
	aRetHead := {}
	aRetCol  := {}
	lSetPC := .F.

	cTesB1PcNf := ""
	If cModelo == '57'
		If !Empty(cTesPcNf) .And. (Posicione("SB1",1,xFilial("SB1")+aItens[1][2][2],"B1_TE") $ AllTrim(cTesPcNf))
			lSetPC := .T.
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Inicio da Inclusao                                           |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lRetorno :=.T.// U_VisNota(cModelo, ZBZ->ZBZ_CNPJ,oXml, aCols, @aCabec, @aItens )
    lSemTES  := .F.                     
    cCondPag := ""
	cNATUREZ := ""

	If lRetorno  

		nOpcPut    := 1    	//FR - 10/06/2020 - 1=pré nota; 2 = nota fiscal
		
		If lNFDireto
			nOpcPut := 2	//FR - 09/06/2020 - "tarefa: gera nota fiscal direto"

			//FR - 17/04/2023 - cria a posição do TES no array de itens da NF, e depois sim, povoa com o TES (Caso haja no pedido ou no produto).
			aLinha := {"D1_TES","",Nil} 	//FR - 17/04/2023 - esta linha será adicionada a cada item da NF

			For nX := 1 to Len(aItens)    
				aadd(aItens[nX], aLinha)	//FR - 22/06/2020 - já cria aqui a linha do TES, depois só povoa
			Next
			//FR - 17/04/2023											
		Endif

		lmata140   := .F.
		lmata103   := .F.

		If lSetPC

			If lPCNFE 

				If !lNFDireto

					nOpcPut := U_MYAVISO("Atenção","O Parametro MV_PCNFE está habilitado."+CRLF+"Não é permitido emitir pré-nota sem pedido de compra."+CRLF+"Deseja incluir uma Pré-Nota ou uma Nota Fiscal de Entrada?",{"Pré-Nota","Nota Fiscal"},3)				   				
				
				Else	
			
					nOpcPut := 2		//FR - 09/06/2020 - "tarefa: gera nota fiscal direto"								
				
				Endif

			Else
				
				nOpcPut := U_MYAVISO("Atenção","Deseja incluir uma Pré-Nota ou uma Nota Fiscal de Entrada?",{"Pré-Nota","Nota Fiscal"},3)
			
			EndIf	
				
		EndIf

		//-----------------------------------------------------------------------------------------------------------------------//
		//FR - 10/06/2020 - Tratativa para obter o TES do pedido de compra, caso haja e depois alimentar no array de itens da NF
		//-----------------------------------------------------------------------------------------------------------------------//
		If cTipoCPro == '4' //FR se fez amarração por pedido:

			//verifica se no pedido, há preenchimento do campo C7_TES:
			lTemTESPC := .F. 
			fr        := 0
			lPCTES    := .F.
			lSemTES   := .F.

			If Len(aPedidos) > 0 .and. nOpcPut <> 1  //só valida TES se for gerar NF

				For fr := 1 to Len(aPedidos)

					SC7->(OrdSetFocus(1)) //C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN                                                                                                                              
					If SC7->(Dbseek(xFilial("SC7") + aPedidos[fr] ))		

						While SC7->(!Eof()) .AND. SC7->C7_FILIAL == xFilial("SC7") .AND. SC7->C7_NUM == aPedidos[fr]
						
							If !Empty(SC7->C7_TES)
								lTemTESPC := .T.									
							Endif

							SC7->(Dbskip()) 

						Enddo

					Endif
					
					//FR - 10/06/2020 - alimenta o array de itens da nf com o TES
					For Nx := 1 to Len(aItens)		

						//SC7->(OrdSetFocus(4))   //4-C7_FILIAL+C7_PRODUTO+C7_NUM+C7_ITEM+C7_SEQUEN 
						SC7->(OrdSetFocus(1))   //4-C7_FILIAL+C7_NUM+C7_ITEM
						//SC7->(Dbseek(xFilial("SC7") +  aItens[Nx][2][2] + aPedidos[fr] ))
						nPos := ASCAN(aitens[1], { |p| UPPER(alltrim(p[1])) == "D1_ITEMPC" })
						If nPos > 0
							SC7->(Dbseek(xFilial("SC7") +  aPedidos[fr] + aItens[Nx][nPos][2]  ))
							cTesB1PcNf := SC7->C7_TES							
						else //se não encontrar, pega o 1o. de entrada q encontrar na SF4 pois pode alterar depois
							cTesB1PcNf := ""							
						Endif 
																						
						nPos := ASCAN(aitens[1], { |p| UPPER(alltrim(p[1])) == "D1_TES" }) //Empty(aItens[Nx][11][2])     //FR - 22/06/2020 - se estiver vazia a posição do TES

						if nPos > 0
							If Empty(aItens[Nx][nPos][2])

								If !Empty(cTesB1PcNf)     	//FR - 22/06/2020 - se houver TES no item do pedido de compra referente ao produto lido no array
									
									aItens[Nx][nPos][2] := cTesB1PcNf       //FR - 22/06/2020 - povoa o array na posição que está o TES
								
								Else 
								Endif
							Endif 
						Endif
						
					Next Nx	

				Next fr

				//-----------------------------------------------------------------------------------------------------------//
				//FR - 28/12/2020 - #5922 - Chamado Razzo - Tratativa para incluir informação do número da OS no item da NF
				// Foi necessária esta implementação porque o campo D1_ORDEM não consta na getdados da pré-nota, somente
				// consta no modo "Documento de Entrada"   
				//-----------------------------------------------------------------------------------------------------------//
				If lXMLPEITE   					//PE para incluir campos no aLinha SD1 -> para o aItens
					U_fAdNumOS(@aItens,cModelo) //aqui apenas adiciona o campo no array de itens				
				Endif							//If XMLPEITE
				//FR - 28/12/2020
			Endif					
			//---------------------------------------------//
			//FR CHAMA TELA DIVERGÊNCIA XML x PEDIDO COMPRA
			//---------------------------------------------//
			//FR - 23/06/2020 - a Tela de Divergências completa não será mostrada na Pré-Nota conforme alinhado em reunião com RAfael em 23/06/2020
			/*
			If cUsaDvg == "S" //FR - SE está ativado o parâmetro de verificar divergências
				If lTemTESPC
					lGeraPrenf := U_fDVGPC(aPedidos,cChaveXml,cDocXMl,cSerXml,dDataEntr,cCodEmit,cLojaEmit,cEspecXML,cTipoNF)
					lPCTES     := .T. //FR - indica que executou a tela de divergência no pedido de compra, então, não precisará executar na pré-nota nem na NF
				Endif
			Endif
			*/
						
		Endif		//If cTipoCPro == '4'
	    //FR fim - amarração pedido
		       
		xRet140 := .F.
		xRet103 := .F.
		
		If nOpcPut == 1  		//Gera Pré Nota
		
			aAuxRot := aClone( aRotina )
			aRotina := U_get2Menu()    //Para não dar erro na rotina padrão.

			if !Empty(aCabec) .and. !Empty(aItens)

				If GetNewPar("XM_PED_GBR", "N") == "S" .And. cAmarra <> "4"
					msgInfo("Parâmetro trava pré nota esta como sim, nesse caso é aconselhavel entrar selecionando um pedido para poder comparar pedido x Xml")
				EndIf

           		MATA140(aCabec,aItens,3,,1) //FR 19/05/2020 - Aqui dentro chama a rotina da tela de divergências (caso o parâmetro esteja ativado), no momento de confirmar a gravação da pré-nota

				aRotina := aClone( aAuxRot )

				If lMsErroAuto

					lMata140 := .F. //xRet140 //o retorno da função indica se a pré-nota foi gerada ou não
					xRet140  := .F.

				else

					DbSelectArea("SF1")
					DbSetOrder(1)
					if DbSeek(FWxFilial("SF1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_TIPO)
		
						lMata140 := .T. //xRet140 //o retorno da função indica se a pré-nota foi gerada ou não
						xRet140  := .T.

						if cModelo == "57"  //CTE

							//Tipo CTE
							nPos := ASCAN(acabec, { |m| UPPER(alltrim(m[1])) == "F1_TPCTE" })

							if nPos > 0 

								cTipoCTE := aCabec[nPos,2]

							endif

							//Municipio de Origem
							nPos := ASCAN(acabec, { |m| UPPER(alltrim(m[1])) == "F1_MUORITR" })

							if nPos > 0 

								cMUORITR := aCabec[nPos,2]

							endif

							//Uf de Origem
							nPos := ASCAN(acabec, { |m| UPPER(alltrim(m[1])) == "F1_UFORITR" })

							if nPos > 0 

								cUFORITR := aCabec[nPos,2]

							endif

							//Municipio de Destino
							nPos := ASCAN(acabec, { |m| UPPER(alltrim(m[1])) == "F1_MUDESTR" })

							if nPos > 0 

								cMUDESTR := aCabec[nPos,2]

							endif

							//Uf de Destino
							nPos := ASCAN(acabec, { |m| UPPER(alltrim(m[1])) == "F1_UFDESTR" })

							if nPos > 0 

								cUFDESTR := aCabec[nPos,2]

							endif

						endif

						RecLock("SF1",.F.)

						SF1->F1_CHVNFE  := cChaveXML
						SF1->F1_TPCTE   := cTipoCTE
						SF1->F1_MUORITR := cMUORITR
						SF1->F1_UFORITR := cUFORITR
						SF1->F1_MUDESTR := cMUDESTR
						SF1->F1_UFDESTR := cUFDESTR

						If !Empty(cModFrete)

							SF1->F1_TPFRETE := cModFrete

						ENDIF
						MsUnlock("SF1")
			
					else

						lMata140 := .F. //xRet140 //o retorno da função indica se a pré-nota foi gerada ou não
						xRet140  := .F.

					endif

				endif

			else

				lMata140 := .F. //xRet140 //o retorno da função indica se a pré-nota foi gerada ou não
				xRet140  := .F.

			endif
			
		ElseIf nOpcPut == 2		//Gera Documento de Entrada

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ O ponto de entrada e disparado apos a inclusão referente ao MT140SAI padrão                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

			If ExistBlock( "XMLPE001" )
		   		aCabec :=	ExecBlock( "XMLPE001", .F., .F., { aCabec,oXml } )
				If Empty(aCabec)
					Conout("[XMLPE001] "+dtos(ddatabase)+"-"+Time())
					U_MYAviso("Erro","O cabeçalho da nota fiscal é inválido.Verifique o ponto de entrada 'XMLPE001'.",{"OK"},3)
					SetKEY( VK_F3 ,  cKeyFe )
					Return(Nil)
				EndIf
			EndIf
			
			//FR - 19/06/2020 - Melhora dos alertas sobre TES e condição de pagamento -TÓPICOS RAFAEL
			cCondPag   := ""
			lTESBloq   := .F.
			cTesB1PcNf := ""
			cNATUREZ   := "" 
			
			//Inserir a TES cTesPcNf para CTE quando Documento de Entrada Direto. Em 03/02/2015 conf. Thiago Almada
			For Nx := 1 to Len(aItens)  	//FR - 10/06/2020 - VARRE O ARRAY DE ITENS PARA VER SE TEM TES, caso não haja, captura do cadastro do produto
				
				nPos := ASCAN(aitens[1], { |p| UPPER(alltrim(p[1])) == "D1_TES" })  //Empty( aItens[Nx][11][2] )    	//FR - 22/06/2020 - se a posição referente ao TES no array, estiver vazia
				If Empty(aItens[Nx][nPos][2])	
					if nPos > 0

						cTesB1PcNf := ""				
						cTesB1PcNf := Posicione("SB1",1,xFilial("SB1")+aItens[Nx][2][2],"B1_TE") 	

						DbSelectArea("SA2")
						DbSetOrder(1)
						DbSeek( xFilial("SA2") + cCodEmit + cLojaEmit )

						xCnpj    := SA2->A2_CGC
						cCondPag := SA2->A2_COND

						if GetNewPar("XM_TESDEV", "N") == "S"  //Verifica cliente usará TES de devolução do campo F4_TESDV

							if cTipoNF == "D"

								//Cliente
								DbSelectArea("SA1")
								DbSetOrder(3)
								DbSeek( xFilial("SA1") + xCnpj )

								//Nota de saida
								DbSelectArea("SD2")
								DbSetOrder(3)
								if DbSeek( xFilial("SD2") + SD1->D1_NFORI + SD1->D1_SERIORI + SA1->A1_COD + SA1->A1_LOJA + SD1->D1_COD + SD1->D1_ITEMORI )

									cTesB1PcNf := SD2->D2_TES

								endif
					
								DbSelectArea("SF4")
								DbSetOrder(1)
								DbSeek( xFilial("SF4") + cTesB1PcNf )

								if !Empty(SF4->F4_TESDV)

									cTesB1PcNf := SF4->F4_TESDV

								else

									if !Empty(cUlTES)

										cTesB1PcNf := cUlTES

									elseif !Empty(SB1->B1_TE)

										cTesB1PcNf := SB1->B1_TE

									else

										cTesB1PcNf := u_HFRETSF4() //Chama a rotina que retorna tes de entrada

									endif
									
								endif
			
							endif	

						endif			
						
						If Empty(cTesB1PcNf)	

							lSemTES := .T.	

						Else	

							SF4->(OrdSetFocus(1))
							
							If SF4->(DbSeek( xFilial( "SF4" ) + cTesB1PcNf ) ) 
								
								If SF4->(FieldPos("F4_MSBLQL")) > 0  //FR verificar se o campo de bloqueio está ativo na base
									
									If SF4->F4_MSBLQL = "1"
									
										lTESBloq := .T.   //FR 19/06/2020 - Indica que o TES está bloqueado no cadastro SF4							
									
									Endif
								
								Endif
							
							Endif
							If Empty(aItens[Nx][nPos][2])
								aItens[Nx][nPos][2] := cTesB1PcNf	   //FR - 22/06/2020 - Recebe o TES do cadastro de produto, caso não tenha no pedido de compra						
							Endif 
						Endif

						//aLinha := {"D1_TES",cTesB1PcNf,Nil}
						//aadd(aItens[nX], aLinha)		

					Endif	
				Endif 
			Next Nx
			
			SA2->(OrdSetFocus(1))			
			If SA2->(dbSeek(xFilial('SA2')+ cCodEmit+cLojaEmit))				
				cCondPag := SA2->A2_COND      			//FR obtém a condição de pagamento do cadastro do fornecedor
				cNATUREZ := SA2->A2_NATUREZ 			//FR obtém a natureza do fornecedor
				SE4->(OrdSetFocus(1))
				If SE4->(DbSeek( xFilial( "SE4" ) + cCondPag ) )
					If SE4->(FieldPos("E4_MSBLQL")) > 0  //FR verificar se o campo de bloqueio está ativo na base 
						If SE4->E4_MSBLQL = "1"
							lCondBloq := .T.   			//FR 19/06/2020 - Indica que a condição de pagto está bloqueada no cadastro SE4
						Endif
					Endif			
				Endif
				
				SED->(OrdSetFocus(1))
				If SED->(DbSeek( xFilial( "SED" ) + cNATUREZ ) )
					If SED->(FieldPos("ED_MSBLQL")) > 0  //FR verificar se o campo de bloqueio está ativo na base 
						If SED->ED_MSBLQL = "1"
							cNATUREZ := ""
						Endif
					//Else 
						//cNATUREZA := cNATUREZ
					Endif			
				Endif

			EndIf			
			//FR - 19/06/2020 - TÓPICOS RAFAEL            
            
			If cUsaDvg == "S"    	//FR 20/05/2020 Usa verificação de divergências

				aCabNFE    := {}
				aIteNFE    := {}
				lGera      := .T. 		//FR - 02/10/2020 - PRECISA FICAR .T. !!! Pois logo mais abaixo serão feitas críticas e aí poderá ficar .F., caso contrário, mantendo .T. gera a NF

				U_fMontaArray(aCabec,aItens,@aCabNFE,@aIteNFE)
				//-----------------------------------------------------------------------------------------------------------------------------------------//
				//FR - Monta os arrays aCabNFE e aIteNFE, ambos são da NF, mas não posso utilizar o aCabec nem o aItens, pois não estão na ordem necessária	
				//FR - utiliza os arrays aCabec e aItens para montar os arrays aCabNFE e aIteNFE -> estes dois últimos têm a estrutura necessária
				//para comparação com o array de cabeçalho e itens do XML 
				//-----------------------------------------------------------------------------------------------------------------------------------------//
				lOmiTTela := Nil     //FR - .T. = omite a exibição da tela de divergência, e só gera o relatório em Excel, Nil = Mostra a tela
				
					//FR - 19/06/2020 - TOPICOS RAFAEL
					xTES := Space(3)
					xCOND:= Space(3)
					xNAT := Space(10)
					If lSemTES 
						cMsgExec += "- TES Inexistente No Cadastro do Produto (Campo: B1_TE)." + CRLF + CRLF
						lGera := .F.
						nOPc  := 0
						//mostra tela para informar TES
						DEFINE MSDIALOG oDlgQtd TITLE "Informe:" FROM 000, 000  TO 170, 300 PIXEL

						@ 006, 004 GROUP oGroup TO 064, 144 OF oDlgQtd PIXEL
						@ 016, 012 SAY oSay PROMPT "TES: " SIZE 050, 007 OF oDlgQtd PIXEL
						@ 014, 065 MSGET xTES PICTURE X3Picture("D1_TES") F3 "SF4" VALID FEXISTCPO(xTES,"1") SIZE 060, 010 OF oDlgQtd PIXEL
						
						If Empty(cCondPag)
							@ 032, 012 SAY oSay PROMPT "Cond.Pagto: " SIZE 050, 007 OF oDlgQtd PIXEL
							@ 030, 065 MSGET xCOND PICTURE X3Picture("A2_COND") F3 "SE4" VALID FEXISTCPO(xCOND,"2") SIZE 060, 010 OF oDlgQtd PIXEL
						Endif 
						
						If GETNEWPAR("MV_NFENAT" , .F.) //se é obrigatório preencher natureza
							If Empty(cNATUREZ)
								@ 048, 012 SAY oSay PROMPT "Natureza: " SIZE 050, 007 OF oDlgQtd PIXEL
								@ 046, 065 MSGET xNAT PICTURE X3Picture("ED_CODIGO") F3 "SED" VALID FEXISTCPO(xNAT,"3") SIZE 060, 010 OF oDlgQtd PIXEL
							Endif 
						Endif 
						@ 070, 107 BUTTON oOk PROMPT "OK" ACTION ( nOpc := 1,iIf(nOpc==1,oDlgQtd:End(),.F.)) SIZE 037, 012 OF oDlgQtd PIXEL
						
						ACTIVATE MSDIALOG oDlgQtd

						If nOpc == 1
							//FR - 10/06/2020 - alimenta o array de itens da nf com o TES
							If !Empty(xTES)

								For Nx := 1 to Len(aItens)	
									nPos := ASCAN(aitens[1], { |p| UPPER(alltrim(p[1])) == "D1_TES" }) //Empty(aItens[Nx][11][2])     //FR - 22/06/2020 - se estiver vazia a posição do TES

									if nPos > 0
										If Empty(aItens[Nx][nPos][2])
											aItens[Nx][nPos][2] := xTES
										Endif								
									Endif							
								Next Nx	
								lGera    := .T.
								lTESBloq := .F. //se chegou aqui é porque validou
								cMsgExec := ""
							Endif 					

							If !Empty(xCOND)
								aAdd(aCabec, {"F1_COND" , xCOND,  nil}) 
								cCondPag := xCOND
								lCondBloq:= .F.  //se chegou aqui é porque validou
							Endif 

							If !Empty(xNAT)
								//aAdd(aCabec, {"F1_NATUREZ" , xNAT,  nil})   //esse campo não existe na SF1
								cNATUREZ  := xNAT								
								SA2->(OrdSetFocus(1))			
								If SA2->(dbSeek(xFilial('SA2')+ cCodEmit+cLojaEmit))
									If Reclock("SA2" , .F.)	
										SA2->A2_NATUREZ := cNATUREZ 
										SA2->(MsUnlock())
										lALTNAT := .T.
									Endif 
								Endif 
							Endif 
						EndIf

						//mostra tela para informar TES
					Endif
                    	                    	
                    If lTESBloq  	//FR - 19/06/2020 - se tem TES e o mesmo estiver bloqueado, também não irá gerar o Documento                                        		
                    	cMsgExec += "- TES Com Bloqueio no Cadastro de Tipos de Entrada/Saída (F4_MSBLQL)."+ CRLF + CRLF
                    	lGera := .F.                    	                     	                   	
                    Endif
                    
                    If Empty(cCondPag)                                         
						cMsgExec += "- Condição de Pagamento Inexistente no Cadastro do Fornecedor (A2_COND)."+CRLF + CRLF
						lGera := .F.											
					Endif	
                                       		
					If lCondBloq                                         
						cMsgExec += "- Condição de Pagamento Bloqueada no Cadastro Cond.Pagto (E4_MSBLQL)."+CRLF + CRLF
						lGera := .F.											
					Endif

					If Empty(cNATUREZ)
						cMsgExec += "- Natureza Inexistente no Cadastro do Fornecedor (A2_NATUREZ)."+CRLF + CRLF
						lGera := .F.											
					Endif 	

				If lGera 	//FR - 06/08/2020 - somente acessa a tela de divergências se as condições acima foram atendidas
				
					lGera := U_HFXML063(cChaveXml,aCabNFE,aIteNFE,"NOTA FISCAL",,lOmiTTela)   //FR -  chamada da tela função da tela de divergências 
					
					If !lGera
					
						Aviso(	"Documento de Entrada",;
						"A nota não poderá ser incluída, Motivo: Divergências XML x NF." + CHR(13) + CHR(10) +;
						"Favor entrar em contato com o Administrador",;
						{"&Ok"},,;
						"XML x NF")
						lMata103    := .F.
						xRet103     := .F.
						//lMsErroAuto := .T.  //FR força erro para mostrar msg de que o docto não foi gerado
						
					Endif
								
				Endif
				
				If lGera		//FR - 19/06/2020 - TES e CONDIÇÃO PAGTO OK - TOPICOS RAFAEL

                   	aAuxRot := aClone( aRotina )
					aRotina := U_get2Menu()    //Para não dar erro na rotina padrão.
					xRet103 := MSExecAuto({|x,y,z,k| mata103(x,y,z,k)},aCabec,aItens,3,.T.)  //FR
						
					aRotina := aClone( aAuxRot ) 

					If lMsErroAuto

						lMata103 := .F. //xRet140 //o retorno da função indica se a pré-nota foi gerada ou não
						xRet103  := .F.

					else

						DbSelectArea("SF1")
						DbSetOrder(1)
						if DbSeek(FWxFilial("SF1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_TIPO)
			
							lMata103 := .T.
							xRet103  := .T.

						else

							lMata103 := .F. //xRet140 //o retorno da função indica se a pré-nota foi gerada ou não
							xRet103  := .F.
							
						endif

					endif

				Else

					MsgAlert("O Documento de Entrada Não Foi Gerado. Motivo(s):" + CRLF + CRLF + cMsgExec )
				
				Endif
				//FR - 19/06/2020 - TOPICOS RAFAEL					
				
				 
			Elseif cUsaDvg != "S" 		//FR - caso não use verificação de Divergências
			
			    lGera := .T.    		//FR - 19/06/2020 - TÓPICOS RAFAEL
				//FR - 19/06/2020 - TOPICOS RAFAEL
				xTES := Space(3)
				xCOND:= Space(3)
				xNAT := Space(10)
    			If lSemTES 
                   	cMsgExec += "- TES Inexistente No Cadastro do Produto (Campo: B1_TE)." + CRLF + CRLF
					lGera := .F.
					nOPc  := 0
					//mostra tela para informar TES
					DEFINE MSDIALOG oDlgQtd TITLE "Informe:" FROM 000, 000  TO 170, 300 PIXEL

					@ 006, 004 GROUP oGroup TO 064, 144 OF oDlgQtd PIXEL
					@ 016, 012 SAY oSay PROMPT "TES: " SIZE 050, 007 OF oDlgQtd PIXEL
					@ 014, 065 MSGET xTES PICTURE X3Picture("D1_TES") F3 "SF4" VALID FEXISTCPO(xTES,"1") SIZE 060, 010 OF oDlgQtd PIXEL
						
					If Empty(cCondPag)
						@ 032, 012 SAY oSay PROMPT "Cond.Pagto: " SIZE 050, 007 OF oDlgQtd PIXEL
						@ 030, 065 MSGET xCOND PICTURE X3Picture("A2_COND") F3 "SE4" VALID FEXISTCPO(xCOND,"2") SIZE 060, 010 OF oDlgQtd PIXEL
					Endif 

					If GETNEWPAR("MV_NFENAT" , .F.) //se é obrigatório preencher natureza
						If Empty(cNATUREZ)
							@ 048, 012 SAY oSay PROMPT "Natureza: " SIZE 050, 007 OF oDlgQtd PIXEL
							@ 046, 065 MSGET xNAT PICTURE X3Picture("ED_CODIGO") F3 "SED" VALID FEXISTCPO(xNAT,"3") SIZE 060, 010 OF oDlgQtd PIXEL
						Endif 
					Endif 

					@ 070, 107 BUTTON oOk PROMPT "OK" ACTION ( nOpc := 1,iIf(nOpc==1,oDlgQtd:End(),.F.)) SIZE 037, 012 OF oDlgQtd PIXEL
					
					ACTIVATE MSDIALOG oDlgQtd

					If nOpc == 1
						//FR - 10/06/2020 - alimenta o array de itens da nf com o TES
						If !Empty(xTES)

							For Nx := 1 to Len(aItens)	
								nPos := ASCAN(aitens[1], { |p| UPPER(alltrim(p[1])) == "D1_TES" }) //Empty(aItens[Nx][11][2])     //FR - 22/06/2020 - se estiver vazia a posição do TES

								if nPos > 0
									If Empty(aItens[Nx][nPos][2])
										aItens[Nx][nPos][2] := xTES
									Endif								
								Endif							
							Next Nx	
							lGera    := .T.
							lTESBloq := .F. //se chegou aqui é porque validou
							cMsgExec := ""
						Endif 					

						If !Empty(xCOND)
							aAdd(aCabec, {"F1_COND" , xCOND,  nil}) 
							cCondPag := xCOND
							lCondBloq:= .F.  //se chegou aqui é porque validou
						Endif 

						If !Empty(xNAT)
							//aAdd(aCabec, {"F1_NATUREZ" , xNAT,  nil}) 
							cNATUREZ  := xNAT							
							SA2->(OrdSetFocus(1))			
							If SA2->(dbSeek(xFilial('SA2')+ cCodEmit+cLojaEmit))
								If Reclock("SA2" , .F.)	
									SA2->A2_NATUREZ := cNATUREZ 
									SA2->(MsUnlock())
									lALTNAT := .T.
								Endif 
							Endif 
						Endif 
					EndIf
					//mostra tela para informar TES
                Endif
                    	                    	
                If lTESBloq  	//FR - 19/06/2020 - se tem TES e o mesmo estiver bloqueado, também não irá gerar o Documento                                        		
                	cMsgExec += "- TES Com Bloqueio no Cadastro de Tipos de Entrada/Saída (F4_MSBLQL)."+ CRLF + CRLF
                    lGera := .F.                    	                     	                   	
                Endif
                    
                If Empty(cCondPag)                                         
					cMsgExec += "- Condição de Pagamento Inexistente no Cadastro do Fornecedor (A2_COND)."+CRLF + CRLF
					lGera := .F.											
				Endif	
				
				If lCondBloq                                      
					cMsgExec += "- Condição de Pagamento Bloqueada no Cadastro Cond.Pagto (E4_MSBLQL)."+CRLF + CRLF
					lGera := .F.											
				Endif

				If Empty(cNATUREZ)
					cMsgExec += "- Natureza Inexistente no Cadastro do Fornecedor (A2_NATUREZ)."+CRLF + CRLF
					lGera := .F.											
				Endif 		
				
				If lGera

					aAuxRot := aClone( aRotina )
					aRotina := U_get2Menu()    //Para não dar erro na rotina padrão.
					xRet103 := MSExecAuto({|x,y,z,k| mata103(x,y,z,k)},aCabec,aItens,3,.T.)  //FR 
					//mata103(aCabec,aItens,3)  //FR 27/04 //não funciona assim
					
					lMata103 := .T.	

				Else

					MsgAlert("O Documento de Entrada Não Foi Gerado. Motivo(s):" + CRLF + CRLF + cMsgExec )
				
				Endif			
				//FR - 19/06/2020 - TOPICOS RAFAEL
				
			Endif			
			
		EndIf 
                       
		lEditStat := .F.
		If lMata103
			lEditStat := .T.     //FR - 10/06/2020 - Checagem para garantir a edição do status do XML.
		Endif

		If lMsErroAuto		

			//If xRet140 .Or. xRet103   //FR 20/05/2020
				MOSTRAERRO()
				//cMsgTES := ""
				//If lSemTES
				//	cMsgTES += "Motivo: TES Inexistente"
				//Endif

				//MsgSTOP("O Documento de entrada não foi gerado." + cMsgTES)
			//EndIf

			lRetorno := .F.
			lMata103 := .F.

			If lMata103
				lEditStat := .T.    //FR - 10/06/2020 - dupla checagem se der erro no ExecAuto, não editará o Status do XML.
			Endif

		Else               
		               
		    lMsHelpAuto:=.F.
 
			If lMata140

				//----------------------------------------------------------------------------------------------------//
				//FR - 22/12/2022 - PROJETO BRASMOLDE - NOTIFICAÇÕES POR EMAIL QDO BAIXA XML
				//Depois de GERAR A PRÉ-NOTA aciona rotina que dispara email caso esteja parametrizado para receber
				//----------------------------------------------------------------------------------------------------//
				cMail11 := GetNewPar("XM_MAIL11",Space(256))  
				If !Empty(cMail11) //emails que receberão notificação qdo gravar xml na base
										
					cFornec  := ""
					cLojFor  := ""
					cNomeFor := ""
					cRazao   := ""
					cCNPJ    := ""
					nFormNfe := Val(GetNewPar("XM_FORMNFE","9"))

					cAssunto := "Importação NFe: " + SF1->F1_DOC + "/" + SF1->F1_SERIE 
					cTipo    := "2"  //classificação ok
					aMsg     := {}			
					cFornec  := SF1->F1_FORNECE 
					cLojFor  := SF1->F1_LOJA

					//se a nota for de beneficiamento ou devolução, pega do cad. cliente:
					If SF1->F1_TIPO $ "B/D"
						cNomeFor := Posicione("SA1",1,xFilial("SA1")+ cFornec + cLojFor,"A1_NOME")
						cCNPJ    := Posicione("SA1",1,xFilial("SA1")+ cFornec + cLojFor,"A1_CGC")
						cTpCliFor:= "Cliente"					
					Else
						cNomeFor := Posicione("SA2",1,xFilial("SA2")+ cFornec + cLojFor,"A2_NOME")
						cCNPJ    := Posicione("SA2",1,xFilial("SA2")+ cFornec + cLojFor,"A2_CGC")
						cTpCliFor:= "Fornecedor"
					Endif 

					cRazao   := cNomeFor
					
					cMotivo  := ""
					cTAG     := ""
					cAssunto += " - Forn: " + cFornec + "/" + cLojFor + "-" + cNomeFor + " - SUCESSO"

					U_FNOTIFICA(cMail11, cTipo, cFornec, cLojfor, cNomeFor, cRazao, cCNPJ, Val(SF1->F1_DOC), SF1->F1_SERIE, nFormNfe,SF1->F1_EMISSAO,cMotivo,cTAG,SF1->F1_CHVNFE,cTpCliFor)
										
					//MODELO
					//Assunto  - Nota Fiscal Classificada com sucesso 
					//Conteúdo 
					//Fornecedor......: 000996 - TE CONNECTIVITY BRASIL IN
					//Nota Fiscal.....: 000196943/1 - Emissão: 19/04/2021
					//Chave da NFe....: 35210400907845001560550010001969431286545563
					//Situação SEFAZ..: 100 - Autorizado o uso da NF-e
						 
				Endif
				//FR - 22/12/2022 - PROJETO BRASMOLDE - NOTIFICAÇÕES POR EMAIL QDO CLASSIFICA A NF

				If xRet140

					DbSelectArea(xZBZ)
					DbSetOrder(3)
					DbSeek( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))) )

					Reclock(xZBZ,.F.)

					If Val( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE"))) ) >= 890 .And. Val( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE"))) ) <= 899
						(xZBZ)->(FieldPut(FieldPos(xZBZ_+"SERORI") , (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE"))) ))
						(xZBZ)->(FieldPut(FieldPos(xZBZ_+"DOCCTE") , (xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA"))) ))
						(xZBZ)->(FieldPut(FieldPos(xZBZ_+"NOTA")   , SF1->F1_DOC ))
						(xZBZ)->(FieldPut(FieldPos(xZBZ_+"SERIE")  , SF1->F1_SERIE ))
						(xZBZ)->(FieldPut(FieldPos(xZBZ_+"DTNFE")  , SF1->F1_EMISSAO ))
					EndIf
					
					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PRENF") , Iif(Empty(SF1->F1_STATUS),'S','N') ))
					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPDOC") , SF1->F1_TIPO ))

					if Len(aCabec) >= 7
											
						nPos := ASCAN(aCabec, { |m| UPPER(alltrim(m[1])) == "F1_FORNECE" })

						if nPos > 0 

							(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CODFOR"), aCabec[nPos][2] ))

						endif

						nPos := ASCAN(aCabec, { |m| UPPER(alltrim(m[1])) == "F1_LOJA" })

						if nPos > 0 

							(xZBZ)->(FieldPut(FieldPos(xZBZ_+"LOJFOR"), aCabec[nPos][2] ))

						endif

					Endif

					(xZBZ)->(MsUnlock() )

					//Manifesta e Verifica se o parametro esta habilitado para manifestar na pre nota
					if FieldPos(xZBZ_+"MANIF") > 0 .and. cManPre == "2"

						cOri := "1"

						if FieldPos(xZBZ_+"IMPORT") > 0
							if !Empty( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"IMPORT"))) )
								cOri := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"IMPORT")))
							Endif
						Endif

                        cManif := U_MANIFXML( AllTrim( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))) ), .T., cOri ) 

                        DbSelectArea(xZBZ)
                        DbSetOrder(3)
                        DbSeek( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))) )
                        Reclock(xZBZ,.F.)                        

						(xZBZ)->(FieldPut(FieldPos(xZBZ_+"MANIF"), cManif ))

                        (xZBZ)->( MsUnlock() )  

					endif

					//FR 19/05/2020 - aviso sobre a geração da pré-nota com sucesso:
					U_MyAviso("Aviso","Importação da Pré-Nota Efetuada com Sucesso."+CRLF+" Utilize a opção :"+CRLF+;
						"Movimento -> Pre-Nota Entrada "+CRLF+" para Verificar a Integridade dos Dados.",{"OK"},3)
					
					//-----------------------------------------------------------------------------------------------------------//
					// FR - 28/12/2020 - #5922 - Chamado Razzo - Tratativa para incluir informação do número da OS no item da NF
					// Foi necessária esta implementação porque o campo D1_ORDEM não consta na getdados da pré-nota, somente
					// consta no modo "Documento de Entrada".   
					// Verifica se existe pedido de compra e respectiva solicitação de compra, e na SC, localiza se existe 
					// número de ordem de serviço associada e grava no campo D1_ORDEM.
					//-----------------------------------------------------------------------------------------------------------//
					xDoc := SD1->D1_DOC
					xSeri:= SD1->D1_SERIE
					xForn:= SD1->D1_FORNECE
					xLoj := SD1->D1_LOJA
					//xPed := SD1->D1_PEDIDO
					//xItPC:= SD1->D1_ITEMPC
					 U_fGrvNumOS(xDoc,xSeri,xForn,xLoj)   //aqui grava o número da OS (caso haja) no campo D1_ORDEM #5922-Razzo
					//FR - 28/12/2020


					//----------------------------------------------------------------------------------------------------//
					//FR - 15/05/2023 - PROJETO JADLOG - GRAVAÇÃO DE DOCTO FISCAL NO BCO CONHECIMENTO (POR AUTOMAÇÃO)
					//Depois de GERAR A PRÉ-NOTA aciona rotina que grava bco conhecimento inserindo docto fiscal (pdf Danfe)
					//Depois abre tela perguntando ao usuário se deseja inserir mais algum docto no bco conhecimento
					//Caso o usuário escolha "Sim", chama a rotina do banco conhecimento e o usuário insere manualmente
					//----------------------------------------------------------------------------------------------------//					
					If GetNewPar("XM_BCONHEC" , "N") == "S"
						//testando com a nfe 000008935 , cte 000057627 , 
						//gera pdf danfe
						cDirDanfe  := "C:\DANFE\"      //nf 000058701
						If !lIsDir( cDirDanfe)
							nMDir := MakeDir( cDirDanfe )
							if nMDir <> 0
								alert("nao foi possivel criar Dir: "+ cDirDanfe + ", result -> " + Alltrim(Str(nMDir)))	
							endif	
						endif 
	
						xHora      := Time()
						cArqDanfe  := "DANFE_"+ xDoc +".PDF"  //DANFE_modelo_numeroNF_data_hora.pdf -> ex.: danfe_55_000058701_20220501_1527h.pdf

						Processa( {|| 	lGerouDanfe := U_XMLPRTdoc(.T.,cDirDanfe,cArqDanfe) }, "Aguarde...", "Gerando Danfe PDF Para Anexar...",.F.) 

						//Private cDirAN1    := "\dirdoc" //Pasta do banco de conhecimento	//"\ANEXOS\SC1\"    //D:\PROTHEUS12\Protheus_R25\protheus_data\dirdoc\co99 o arquivo precisa estar nesta pasta para gravar na AC8 e ACB
						//Private cDirAN2    := "\co" 	//Pasta do banco de conhecimento	//"\ANEXOS\SC1\"    //D:\PROTHEUS12\Protheus_R25\protheus_data\dirdoc\co99 o arquivo precisa estar nesta pasta para gravar na AC8 e ACB
						//Private cDirAN3    := "\shared\" 
						//Private cDir	   := ""

						cDirAN1    := "\dirdoc" //Pasta do banco de conhecimento	//"\ANEXOS\SC1\"    //D:\PROTHEUS12\Protheus_R25\protheus_data\dirdoc\co99 o arquivo precisa estar nesta pasta para gravar na AC8 e ACB
						cDirAN2    := "\co" 	//Pasta do banco de conhecimento	//"\ANEXOS\SC1\"    //D:\PROTHEUS12\Protheus_R25\protheus_data\dirdoc\co99 o arquivo precisa estar nesta pasta para gravar na AC8 e ACB
						cDirAN3    := "\shared\" 
						cDir	   := ""

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

						cDir := cDirAN1 + cDirAN2 + cDirAN3  //  "\dirdoc\co99\shared\" //aqui criou a pasta por completo e suas subpastas

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
								//MsgAlert("PDF não gravou na pasta") 
								lGerouDanfe := .F.
							Else
								lGerouDanfe := .T.
								//MsgInfo("DANFE PDF OK")
							Endif
								
						Else 
							lGerouDanfe := .F.
						Endif

						If lGerouDanfe
							If !Empty(cArqDanfe)
								xPathArq := Alltrim(cDirDanfe) + Alltrim(cArqDanfe)
								lCopiouD := CpyT2S( xPathArq , cDir , .F. )   // cDirDanfe: "C:\DANFE\" ; cArqDanfe: "DANFE_20220429.PDF" ;  cDir: "\dirdoc\co99\shared\"
							Endif
							fAnexaBco(cArqDanfe , xDoc,xSeri,xForn,xLoj)  //anexa bco automaticamente							
						Endif 

						If MsgYesNo("Precisa Incluir Documento no Banco Conhecimento ?")
							//aqui deverá chamar a função padrão do bco conhecimento para o usuário inserir manualmente
							MsDocument("SF1", SF1->( Recno() ), 2)  //precisa ser opção 2 para deixar inserir documento
						Endif 
					Endif 
					//FR - 15/05/2023 - JADLOG - ABRIR TELA BANCO CONHECIMENTO APÓS GERAÇÃO DA PRÉ-NOTA

					If U_EditDocXml(cModelo,lSetPc)  
						//FR nesta função é feita a classificação da pré-nota e não tem como inserir a tela de divergência, 
						//exceto por ponto de entrada, mas no Gestão XML não é permitido usar ponto de entrada padrão
						
						lDiverg    := .F. //retorna se tem divergência
					
						If lMata103       //FR - 19/06/2020 - checagem se classificou a NF
							
							If !ExistBlock( "MT100TOK" ) //FR - se não existir o ponto de entrada na confirmação da NF Entrada, aí sim executa o relatório, após a classificação:
								
								If cUsaDvg == "S"    	//FR 20/05/2020 Usa verificação de divergências
									//FR - neste caso a verificação de divergência só após a classificação da NF, exportando para o relatório
									lDiverg    := .F. //retorna se tem divergência
									aNFDiverg := {}
									Aadd(aNFDiverg , {cDocXMl, cSerXml, cCodEmit, cLojaEmit} ) 
									aParams := {} 
									lQuery  := .T. 							//faz a query completa de checagem
									U_fPovoaPar(@aParams,aNFDiverg)			//povoa o array de parâmetros para o relatório		
									U_HFXMLR16(aParams,lQuery,@lDiverg)  	//chama o relatório já passando por parâmetro a NF/XML a ser verificado
								
								Endif
								
								//FR 19/05/2020 - aviso sobre a classificação da pré-nota com sucesso:  
								If !lDiverg

									U_MyAviso("Aviso","Classificação da Pré-Nota Efetuada com Sucesso."+CRLF+" Utilize a opção :"+CRLF+;
									"Movimento -> Documento de Entrada "+CRLF+" para Verificar a Integridade dos Dados.",{"OK"},3)							
								
								Else

									U_MyAviso("Aviso","Classificação da Pré-Nota Efetuada com Sucesso,"+CRLF+"Porém, Com Divergências Entre XML x NF."+CRLF+;
									"Utilize a opção :"+CRLF+;
									"Movimento -> Documento de Entrada "+CRLF+" para Verificar a Integridade dos Dados.",{"OK"},3)						
								
								Endif	

							Endif
							
						Endif			//FR - 19/06/2020 - checagem se classificou a NF

						lEditStat := .T.

					else
						
						lEditStat := .F.

					EndIf 

				EndIf	
				
			Else			    
				//PRÉ NOTA NÃO GERADA					
			EndIf	
			
			If lEditStat 

				DbSelectArea(xZBZ)
                DbSetOrder(3)
                DbSeek( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))) )

				Reclock(xZBZ,.F.)

				If Val( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE"))) ) >= 890 .And. Val( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE"))) ) <= 899

					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"SERORI") , (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE"))) ))
					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"DOCCTE") , (xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA"))) ))
					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"NOTA")   , SF1->F1_DOC ))
					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"SERIE")  , SF1->F1_SERIE ))
					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"DTNFE")  , SF1->F1_EMISSAO ))
					
				EndIf
				
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PRENF") , Iif(Empty(SF1->F1_STATUS),'S','N') ))
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPDOC") , SF1->F1_TIPO ))
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"ORIGEM"), aDocOri[1] )) // Erick Silva -> Preenche o campo Classificado por: Gestão XML.

				nPos := ASCAN(aCabec, { |m| UPPER(alltrim(m[1])) == "F1_TPCTE" })

				if nPos > 0 

					cTipoCTE := aCabec[nPos,2]

				endif

				if Len(aCabec) >= 7

					nPos := ASCAN(aCabec, { |m| UPPER(alltrim(m[1])) == "F1_FORNECE" })

					if nPos > 0 

						(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CODFOR"), aCabec[nPos][2] ))

					endif

					nPos := ASCAN(aCabec, { |m| UPPER(alltrim(m[1])) == "F1_LOJA" })

					if nPos > 0 

						(xZBZ)->(FieldPut(FieldPos(xZBZ_+"LOJFOR"), aCabec[nPos][2] ))

					endif

				Endif

				(xZBZ)->(MsUnlock() )
				
				if lMata103 //lNFDireto .and.

					//Manifesta e Verifica se o parametro esta habilitado para manifestar na classificação
					if FieldPos(xZBZ_+"MANIF") > 0 .and. cManPre == "3"

						cOri := "1"

						if FieldPos(xZBZ_+"IMPORT") > 0
							if !Empty( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"IMPORT"))) )
								cOri := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"IMPORT")))
							Endif
						Endif

                        cManif := U_MANIFXML( AllTrim( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))) ), .T., cOri ) 

                        DbSelectArea(xZBZ)
                        DbSetOrder(3)
                        DbSeek( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))) )
                        Reclock(xZBZ,.F.)                        

						(xZBZ)->(FieldPut(FieldPos(xZBZ_+"MANIF"), cManif ))

                        (xZBZ)->( MsUnlock() )  

					endif

					//qdo é gera nf direto, colocar aqui a notificação da Brasmolde
					//----------------------------------------------------------------------------------------------------//
					//FR - 22/12/2022 - PROJETO BRASMOLDE - NOTIFICAÇÕES POR EMAIL QDO BAIXA XML
					//Depois de Classificar a nota aciona rotina que dispara email caso esteja parametrizado para receber
					//----------------------------------------------------------------------------------------------------//					
					cMail12 := GetNewPar("XM_MAIL12",Space(256))  //FR - 21/12/2022 - Flávia Rocha - EMAIL AVISANDO SOBRE NOVO XML GRAVADO NA BASE	
					If !Empty(cMail12) //emails que receberão notificação qdo gravar xml na base
										
						cFornec  := ""
						cLojFor  := ""
						cNomeFor := ""
						cRazao   := ""
						cCNPJ    := ""
						nFormNfe := Val(GetNewPar("XM_FORMNFE","9"))

						//cAssunto := "Nota Fiscal Classificada Com Sucesso"
						cAssunto := "Classificação NFe: " + SF1->F1_DOC + "/" + SF1->F1_SERIE 
						cTipo    := "2"  //classificação ok
						aMsg     := {}			
						cFornec  := SF1->F1_FORNECE 
						cLojFor  := SF1->F1_LOJA

						//se a nota for de beneficiamento ou devolução, pega do cad. cliente:
						If SF1->F1_TIPO $ "B/D"
							cNomeFor := Posicione("SA1",1,xFilial("SA1")+ cFornec + cLojFor,"A1_NOME")
							cCNPJ    := Posicione("SA1",1,xFilial("SA1")+ cFornec + cLojFor,"A1_CGC")
							cTpCliFor:= "Cliente"
						Else 
							cNomeFor := Posicione("SA2",1,xFilial("SA2")+ cFornec + cLojFor,"A2_NOME")
							cCNPJ    := Posicione("SA2",1,xFilial("SA2")+ cFornec + cLojFor,"A2_CGC")
							cTpCliFor:= "Fornecedor"
						Endif

						cRazao   := cNomeFor
						cMotivo  := ""
						cTAG     := ""
						cAssunto += "Forn: " + cFornec + "/" + cLojFor + "-" + cNomeFor + " - SUCESSO"

						U_FNOTIFICA(cMail12, cTipo, cFornec, cLojfor, cNomeFor, cRazao, cCNPJ, Val(SF1->F1_DOC), SF1->F1_SERIE, nFormNfe,SF1->F1_EMISSAO,cMotivo,cTAG,SF1->F1_CHVNFE,cTpCliFor)
											
						//MODELO
						//Assunto  - Nota Fiscal Classificada com sucesso 
						//Conteúdo 
						//Fornecedor......: 000996 - TE CONNECTIVITY BRASIL IN
						//Nota Fiscal.....: 000196943/1 - Emissão: 19/04/2021
						//Chave da NFe....: 35210400907845001560550010001969431286545563
						//Situação SEFAZ..: 100 - Autorizado o uso da NF-e
						 
					Endif					 
					//FR - 22/12/2022 - PROJETO BRASMOLDE - NOTIFICAÇÕES POR EMAIL QDO CLASSIFICA A NF

					//FR - 27/04/2023 - VYDENCE - campo natureza no cad. fornecedor
					//qdo gera docto entrada direto, refaz a natureza do fornecedor caso tenha sido digitada na tela
					  //testar
					//If lALTNAT
						//SA2->(OrdSetFocus(1))			
						//If SA2->(dbSeek(xFilial('SA2')+ cCodEmit+cLojaEmit))
							//If Reclock("SA2" , .F.)	
								//SA2->A2_NATUREZ := "" //cNATUREZ volta o campo ser vazio, só preenchi para gerar a nota 
								//SA2->(MsUnlock())
							//Endif
						//Endif 
					//Endif 
					 

				endif
				  
			EndIf				
	
			lRetorno := .T.
			
		EndIf 
	
	EndIf
	
Endif
           
RestArea(aArea)

SetKEY( VK_F3 ,  cKeyFe )

Return

//+-----------------------------------------------------------------------------------//
//|Funcao....: VERIPIICM
//|Descricao.: Função para trazer Valor ICM ou IPI
//|Observação: 
//+-----------------------------------------------------------------------------------//
User Function VERIPIICM(oXmlImp)

Local cRet := "N"
Local nIcm := 0
Local nIpi := 0

Private oXml       := oXmlImp
Private cTagTotIcm := "oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VICMS:TEXT"
Private cTagTotIpi := "oXml:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VIPI:TEXT"

if type("cTagTotIcm") <> "U" .and. oXml <> NIL
	nIcm := Val( &(cTagTotIcm) )
endif
if type("cTagTotIpi") <> "U" .and. oXml <> NIL
	nIpi := Val( &(cTagTotIpi) )
endif
if nIpi > 0
	cRet := "P"
endif
if nIcm > 0
	cRet := "I"
endif

Return(cRet)


//cTipoProc -> AVRC -> Aviso Recebimento de Carga
//             PREN -> Pré-Nota de Entrada
//             NFCF -> NT Conhecimento Frete
//             PDRC -> Pedido Recorrente
//cTipoCPro -> esta variável tem que vir como private
//aCabec    -> tem que vir como private
//nErrItens -> variável para controlar quantas vezes passou pelos ítens, mostrar erros apenas uma vez, na segunda cai fora
//aProdZr   -> Produtos com valores unitários Zerado.
User Function ItNaoEnc( cTipoProc, aProdOk, aProdNo, aProdVl, nErrItens, aProdZr, cTipoCpro, lAmarrou )

Local lRet := .T.

Default aProdOk := {}
Default aProdNo := {}
Default aProdVl := {}
Default aProdZr := {} 
Default cTipocPro := "1"
Default lAmarrou := .F.

lRet := U_HFITNENC( cTipoProc, aProdOk, aProdNo, aProdVl, @nErrItens, aProdZr, cTipoCpro, @lAmarrou )

Return( lRet )


//+-----------------------------------------------------------------------------------//
//|Funcao....: ExistSf3
//|Descricao.: Função para buscar nos livros fiscais o fornecedor/loja
//|            tanto nota de entrada como saída
//|Observação: 
//+-----------------------------------------------------------------------------------//
User Function ExistSf3( cNfOri, cSerOri, cFornOri, cLojaOri, cTipoNfo, cFormul, cCc )  //Ver se poe zeros a Frente ou não

Local aArea   := GetArea()
Local lAcho   := .T.
Local xNfOri  := cNfOri
Local xSerOri := cSerOri
Local cCod    := ""
Local cLoj    := ""
Local cFilSeek:= xFilial("SA2")  //Iif(U_IsShared("SA2"),xFilial("SA2"),(xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))) )

SA2->( dbSetOrder( 3 ) )
If SA2->( DbSeek( cFilSeek + cCnpRem ) )
	cCod := SA2->A2_COD
	cLoj := SA2->A2_LOJA
	cFornOri:= SA2->A2_COD
	cLojaOri:= SA2->A2_LOJA
EndIf
If empty(cCod) .and. empty(cLoj) //para ver se é Bene ou Devole
	cFilSeek:= xFilial("SA1") //Iif(U_IsShared("SA1"),xFilial("SA1"),(xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))) )
	SA1->( dbSetOrder( 3 ) )
	If SA1->( DbSeek( cFilSeek + cCnpRem ) )
		cCod := SA1->A1_COD
		cLoj := SA1->A1_LOJA
		cFornOri:= SA1->A1_COD
		cLojaOri:= SA1->A1_LOJA
	EndIf
endif


DbSelectArea( "SF3" )
DbSetOrder( 4 )

lAcho := SF3->( DbSeek( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))) + cCod + cLoj + xNfOri + xSerOri ) )

If .Not. lAcho
	xNfOri  := Substr( AllTrim( Str( val(xNfOri) ) ) + space(len(SF3->F3_NFISCAL)), 1, len(SF3->F3_NFISCAL) )
	xSerOri := Substr( AllTrim( Str( val(xSerOri) ) ) + space(len(SF3->F3_SERIE)), 1, len(SF3->F3_SERIE) )
	lAcho := SF3->( DbSeek( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))) + cCod + cLoj + xNfOri + xSerOri ) )

	if .Not. lAcho
		xNfOri  := StrZero( Val(xNfOri), len(SF3->F3_NFISCAL) )
		xSerOri := StrZero( Val(xSerOri), len(SF3->F3_SERIE) )
		lAcho   := SF3->( DbSeek( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))) + cCod + cLoj + xNfOri + xSerOri ) )
	Endif

	if .Not. lAcho
		xNfOri  := StrZero( Val(xNfOri), len(SF3->F3_NFISCAL) )
		xSerOri := Substr( AllTrim( Str( val(xSerOri) ) ) + space(len(SF3->F3_SERIE)), 1, len(SF3->F3_SERIE) )
		lAcho   := SF3->( DbSeek( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))) + cCod + cLoj + xNfOri + xSerOri ) )
	Endif

	if .Not. lAcho
		xNfOri  := Substr( AllTrim( Str( val(xNfOri) ) ) + space(len(SF3->F3_NFISCAL)), 1, len(SF3->F3_NFISCAL) )
		xSerOri := StrZero( Val(xSerOri), len(SF3->F3_SERIE) )
		lAcho   := SF3->( DbSeek( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))) + cCod + cLoj + xNfOri + xSerOri ) )
	Endif

	if .Not. lAcho
		xNfOri  := Substr( AllTrim( Str( val(xNfOri), 6, 0 ) ) + space(len(SF3->F3_NFISCAL)), 1, len(SF3->F3_NFISCAL) )
		xSerOri := StrZero( Val(xSerOri), len(SF3->F3_SERIE) )
		lAcho   := SF3->( DbSeek( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))) + cCod + cLoj + xNfOri + xSerOri ) )
	Endif

	if .Not. lAcho
		xNfOri  := Substr( AllTrim( Str( val(xNfOri), 6, 0 ) ) + space(len(SF3->F3_NFISCAL)), 1, len(SF3->F3_NFISCAL) )
		xSerOri := Substr( AllTrim( Str( val(xSerOri) ) ) + space(len(SF3->F3_SERIE)), 1, len(SF3->F3_SERIE) )
		lAcho   := SF3->( DbSeek( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))) + cCod + cLoj + xNfOri + xSerOri ) )
	Endif

EndIf

if lAcho
	cNfOri  := xNfOri
	cSerOri := xSerOri
	if SF3->F3_TIPO $ "BD"
		cFornOri := SF3->F3_CLIEFOR
		cLojaOri := SF3->F3_LOJA
		cTipoNfo := SF3->F3_TIPO
	endif
	cFormul := SF3->F3_FORMUL
	SD1->( dbSetOrder( 1 ) )
	if SD1->( dbSeek( SF3->F3_FILIAL + SF3->F3_NFISCAL + SF3->F3_SERIE + SF3->F3_CLIEFOR + SF3->F3_LOJA ) )
		cCc := SD1->D1_CC
	endif
Endif

RestArea(aArea)

Return( NIL )


//+-----------------------------------------------------------------------------------//
//|Funcao....: ExistDoc
//|Descricao.: Função para buscar na tabela de NF's de saída (Faturamento)
//|            o fornecedor/loja e centro de custo
//|Observação: 
//+-----------------------------------------------------------------------------------//
User Function ExistDoc( cNfOri, cSerOri, cFornOri, cLojaOri, cTipoNfo, cFormul, cCc, cCodPro, cItemOri )  //Ver se poe zeros a Frente ou não

Local aArea   := GetArea()
Local lAcho   := .T.
Local xNfOri  := cNfOri
Local xSerOri := cSerOri

Static cCodPro := ""

DbSelectArea( "SF2" )
DbSetOrder( 1 )

lAcho := SF2->( DbSeek( xFilial("SF2") + xNfOri + xSerOri ) )

If .Not. lAcho

	xNfOri  := Substr( AllTrim( Str( val(xNfOri) ) ) + space(len(SF2->F2_DOC)), 1, len(SF2->F2_DOC) )
	xSerOri := Substr( AllTrim( Str( val(xSerOri) ) ) + space(len(SF2->F2_SERIE)), 1, len(SF2->F2_SERIE) )
	lAcho := SF2->( DbSeek( xFilial("SF2") + xNfOri + xSerOri ) )

	if .Not. lAcho
		xNfOri  := StrZero( Val(xNfOri), len(SF2->F2_DOC) )
		xSerOri := StrZero( Val(xSerOri), len(SF2->F2_SERIE) )
		lAcho   := SF2->( DbSeek( xFilial("SF2") + xNfOri + xSerOri ) )
	Endif

	if .Not. lAcho
		xNfOri  := StrZero( Val(xNfOri), len(SF2->F2_DOC) )
		xSerOri := Substr( AllTrim( Str( val(xSerOri) ) ) + space(len(SF2->F2_SERIE)), 1, len(SF2->F2_SERIE) )
		lAcho   := SF2->( DbSeek( xFilial("SF2") + xNfOri + xSerOri ) )
	Endif

	if .Not. lAcho
		xNfOri  := Substr( AllTrim( Str( val(xNfOri) ) ) + space(len(SF2->F2_DOC)), 1, len(SF2->F2_DOC) )
		xSerOri := StrZero( Val(xSerOri), len(SF2->F2_SERIE) )
		lAcho   := SF2->( DbSeek( xFilial("SF2") + xNfOri + xSerOri ) )
	Endif

	if .Not. lAcho
		xNfOri  := Substr( AllTrim( Str( val(xNfOri), 6, 0 ) ) + space(len(SF2->F2_DOC)), 1, len(SF2->F2_DOC) )
		xSerOri := StrZero( Val(xSerOri), len(SF2->F2_SERIE) )
		lAcho   := SF2->( DbSeek( xFilial("SF2") + xNfOri + xSerOri ) )
	Endif

	if .Not. lAcho
		xNfOri  := Substr( AllTrim( Str( val(xNfOri), 6, 0 ) ) + space(len(SF2->F2_DOC)), 1, len(SF2->F2_DOC) )
		xSerOri := Substr( AllTrim( Str( val(xSerOri) ) ) + space(len(SF2->F2_SERIE)), 1, len(SF2->F2_SERIE) )
		lAcho   := SF2->( DbSeek( xFilial("SF2") + xNfOri + xSerOri ) )
	Endif

EndIf

if lAcho

		cNfOri  := xNfOri
		cSerOri := xSerOri
		cFornOri:= SF2->F2_CLIENTE
		cLojaOri:= SF2->F2_LOJA
		cTipoNfo:= SF2->F2_TIPO
		cFormul := SF2->F2_FORMUL

		SD2->( dbSetOrder( 3 ) )

		if Empty(cCodPro)

			if SD2->( dbSeek( SF2->F2_FILIAL + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA ) )

				cCc := SD2->D2_CCUSTO

			endif

		else

			if SD2->( dbSeek( SF2->F2_FILIAL + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA + cCodPro ) )
				
				cCc      := SD2->D2_CCUSTO
				cItemOri := SD2->D2_ITEM

			endif

		endif
Endif

RestArea(aArea)

Return( NIL )


//+-----------------------------------------------------------------------------------//
//|Funcao....: Sf3DaChave
//|Descricao.: Função para buscar na tabela de Livros Fiscais a nf / série da chave
//|            selecionada
//|Observação: 
//+-----------------------------------------------------------------------------------//
User Function Sf3DaChave( cChv, cFornOri, cLojaOri, cTipoNfo, cFormul, cCc )  //Pegar Documentos no SF3

Local aRet[3]			//FR - 18/06/2021
Local cQuery := ""
Local aArea  := GetArea()
Local cAliasSF3 := GetNextAlias()
Local cFilSeek:= xFilial("SA2")  //Iif(U_IsShared("SA2"),xFilial("SA2"),(xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))) )

SA2->( dbSetorder(1) )

aRet[1] := Substr("N/E"+space( len(SF3->F3_NFISCAL ) ), 1, len(SF3->F3_NFISCAL ) )
aRet[2] := space( len(SF3->F3_SERIE ) )

If .Not. Empty( cChv )

	cQuery := "SELECT SF3.F3_NFISCAL,SF3.F3_SERIE,SF3.F3_CLIEFOR,SF3.F3_LOJA,SF3.F3_TIPO,SF3.F3_FORMUL "
	cQuery += "FROM "+RetSqlName("SF3")+" SF3 "
	cQuery += "WHERE SF3.F3_FILIAL='"+xFilial("SF3")+"' AND "
	cQuery += "SF3.F3_CHVNFE = '"+cChv+"' AND "
	cQuery += "SF3.D_E_L_E_T_ = ' ' "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF3)

	DbSelectARea( cAliasSF3 )
	
	Do While .Not. ( cAliasSF3 )->( Eof() )
	
		aRet[1] := ( cAliasSF3 )->F3_NFISCAL
		aRet[2] := ( cAliasSF3 )->F3_SERIE
		
		SA2->( dbSeek( cFilSeek + ( cAliasSF3 )->F3_CLIEFOR + ( cAliasSF3 )->F3_LOJA )  )
		
		cCnpRem := SA2->A2_CGC
		cFornOri:= ( cAliasSF3 )->F3_CLIEFOR
		cLojaOri:= ( cAliasSF3 )->F3_LOJA
		
		if ( cAliasSF3 )->F3_TIPO $ "BD"
			cTipoNfo := ( cAliasSF3 )->F3_TIPO
			cFilSeek:= xFilial("SA1")  //Iif(U_IsShared("SA1"),xFilial("SA1"),(xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))) )
			SA1->( dbSeek( cFilSeek + ( cAliasSF3 )->F3_CLIEFOR + ( cAliasSF3 )->F3_LOJA )  )
			cCnpRem := SA1->A1_CGC
		endif
		
		cFormul := ( cAliasSF3 )->F3_FORMUL
		
		if empty(cCc)
			SD1->( dbSetOrder( 1 ) )
			if SD1->( dbSeek( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))) + ( cAliasSF3 )->F3_NFISCAL + ( cAliasSF3 )->F3_SERIE + ( cAliasSF3 )->F3_CLIEFOR + ( cAliasSF3 )->F3_LOJA ) )
				cCc     := SD1->D1_CC
				aRet[3] := cCc		
			else
				aRet[3] := ""		//FR - 18/06/2021
			endif
		endif
		
		( cAliasSF3 )->( dbSkip() )
		
	EndDo
	
EndIf

DbSelectArea(cAliasSF3)
DbCloseArea()
RestArea(aArea)

Return( aRet )

//+-----------------------------------------------------------------------------------//
//|Funcao....: DocDaChave
//|Descricao.: Função para buscar na tabela de NF's Saída a nf / série da chave
//|            selecionada
//|Observação: 
//+-----------------------------------------------------------------------------------//
User Function DocDaChave( cChv, cFornOri, cLojaOri, cTipoNfo, cFormul, cCc )  //Pegar Documentos no SF2

Local aRet[3]  
Local cQuery := ""
Local aArea  := GetArea()
Local cAliasSF2 := GetNextAlias()

aRet[1] := Substr("N/E"+space( len(SF2->F2_DOC ) ), 1, len(SF2->F2_DOC ) )
aRet[2] := space( len(SF2->F2_SERIE ) )
aRet[3] := Space( Len(SD2->D2_CCUSTO) )

If .Not. Empty( cChv )

	cQuery := "SELECT SF2.F2_DOC,SF2.F2_SERIE,SF2.F2_CLIENTE,SF2.F2_LOJA,SF2.F2_TIPO,SF2.F2_FORMUL, SF2.F2_CHVNFE "
	cQuery += "FROM "+RetSqlName("SF2")+" SF2 "
	cQuery += "WHERE SF2.F2_FILIAL='"+xFilial("SF2")+"' AND "
	cQuery += "SF2.F2_CHVNFE = '"+cChv+"' AND "
	cQuery += "SF2.D_E_L_E_T_ = ' ' "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF2)

	DbSelectARea( cAliasSF2 )
	
	Do While .Not. ( cAliasSF2 )->( Eof() )
	
		aRet[1] := ( cAliasSF2 )->F2_DOC
		aRet[2] := ( cAliasSF2 )->F2_SERIE
		cFornOri:= ( cAliasSF2 )->F2_CLIENTE
		cLojaOri:= ( cAliasSF2 )->F2_LOJA
		cTipoNfo:= ( cAliasSF2 )->F2_TIPO
		cFormul := ( cAliasSF2 )->F2_FORMUL
		
		if empty( cCc )
		
			SD2->( dbSetOrder( 3 ) )
			if SD2->( dbSeek( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))) + ( cAliasSF2 )->F2_DOC + ( cAliasSF2 )->F2_SERIE + ( cAliasSF2 )->F2_CLIENTE + ( cAliasSF2 )->F2_LOJA ) )
				cCc := SD2->D2_CCUSTO
				aRet[3] := cCc
			Else
				aRet[3] := ""		//FR - 18/06/2021
			endif
		
		endif
		
		( cAliasSF2 )->( dbSkip() )
		
	EndDo
	
EndIf

DbSelectArea(cAliasSF2)
DbCloseArea()
RestArea(aArea)

Return( aRet )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³EditDocXml ³ Autor ³ Roberto Souza        ³ Data ³14/02/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Acçao tomada após incluir pré-nota de entrada conforme     ³±±
±±³          ³ parametro XM_CFGPRE                      	              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ EditDocXml()                             	              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Conteudo do Parametro XM_CFGPRE                            ³±±
±±³          ³ 0=Nenhuma ação                                             ³±±
±±³          ³ 1=Alterar Pré-Nota                                         ³±±
±±³          ³ 2=Classificar NF                                           ³±±
±±³          ³ 3=Alterar Pré-Nota e Classificar NF                        ³±±
±±³          ³ 4=Sempre Perguntar                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Importa Xml                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/ 
User Function EditDocXml(cModelo,lSetPc)

Local lRet        := .T.
Local aArea       := GetArea()
Local cAliasEdt   := "SF1"
Local nReg        := 0 
//Local nOpcY       := 5
//Local nOpcW       := 5
Local cCfgPre     := GetNewPar("XM_CFGPRE","0")
//Local lAltPreNf   := cCfgPre $ "4/4" 		//FR 09/06/2020 - Se altera pré nota = .F. ESTA VARIÁVEL DEIXOU DE SER FUNCIONAL com os Demais parâmetros   
Local lClassifica := cCfgPre $ "1/2"        //FR 09/06/2020 - 1=Classifica; 2=Pergunta - "tarefa: gera nota fiscal direto"
Local lPergAlt    := cCfgPre $ "2"          //FR 09/06/2020 - Se = 2, Pergunta, então lPergAlt = .T. - "tarefa: gera nota fiscal direto"
//Local cTesPcNf    := GetNewPar("MV_TESPCNF","") // Tes que nao necessita de pedido de compra amarrado
Local cKeyFe	  := SetKEY( VK_F3 ,  Nil )
Local cTes        := ""
Local cCondPag    := ""
Local y           := 0
Local aCab        := {}
Local aItem       := {}
Local aItens      := {}
Local xCnpj       := ""
Local cUlTes      := ""
 
Private lMsErroAuto := .F.
Private lPCNFE    := GetNewPar("MV_PCNFE",.F.)
Private aHeadSD1  := {}
Private lOnUpdate := .T.
Private nOpcAlt   := 0                                
Private aAutoCab  := {}
Private lRetorna  := .T., lEditCol := .T. //Para corrigir erro a partir da LIB de 20/06/18
Private lNFDireto := cCfgPre $ "3"			//FR 09/06/2020 - Se = 3, já gera documento de entrada direto, sem passsar por pré nota - "tarefa: gera nota fiscal direto" 
/*
//FR - 09/06/2020 - Lembrete das opções do combo (tela F12)
aAdd( aCombo7, "0=Pré-Nota Somente")
aAdd( aCombo7, "1=Gera Pré-Nota e Classifica")
aAdd( aCombo7, "2=Sempre Perguntar") 
aAdd( aCombo7, "3=Gera Docto.Entrada Direto")  
*/
If !lNFDireto      

	DbSelectArea(cAliasEdt)
	nReg := Recno()
	
	If lPergAlt// .And. !lSetPc
	
		nOpcAlt := Aviso("Atenção","Deseja Classificar a Pré-Nota Gerada?",;
		{"Sim","Não"},;
		1)

		Do Case

	 		Case nOpcAlt == 1 
				//lAltPreNf  := .F.
		   		lClassifica:= .T.
			OtherWise
				//lAltPreNf  := .F.
		   		lClassifica:= .F.  
	
		EndCase

	EndIf        

	If lClassifica
	
		cCadastro := "Classificar Documento Entrada"
		aAuxRot := aClone( aRotina )
		aRotina := U_get2Menu()    //Para não dar erro na rotina padrão.
	
		rstmvbuff()
		DelClassIntf()

		if GetNewPar("XM_TESDEV", "N") == "S"  //Verifica cliente usará TES de devolução do campo F4_TESDV  //Empty(aPedidos) //Se for por produto

			DbSelectArea('SF1')
			DbSetOrder(1)
			DbSeek(cChaveF1)

			//Cabeçalho
			aadd(aCab,{"F1_TIPO" ,SF1->F1_TIPO,NIL})
			aadd(aCab,{"F1_FORMUL" ,SF1->F1_FORMUL,NIL})
			aadd(aCab,{"F1_DOC" ,SF1->F1_DOC ,NIL})
			aadd(aCab,{"F1_SERIE" ,SF1->F1_SERIE ,NIL})
			aadd(aCab,{"F1_EMISSAO" ,SF1->F1_EMISSAO ,NIL})
			aadd(aCab,{"F1_DTDIGIT" ,SF1->F1_DTDIGIT ,NIL})
			aadd(aCab,{"F1_FORNECE" ,SF1->F1_FORNECE ,NIL})
			aadd(aCab,{"F1_LOJA" ,SF1->F1_LOJA ,NIL})
			aadd(aCab,{"F1_ESPECIE" ,SF1->F1_ESPECIE,NIL})

			DbSelectArea("SA2")
			DbSetOrder(1)
			DbSeek( xFilial("SA2") + SF1->F1_FORNECE + SF1->F1_LOJA )

			xCnpj    := SA2->A2_CGC
			cCondPag := SA2->A2_COND

			if !Empty( cCondPag )

				aAdd(aCab, {"F1_COND" , cCondPag,  nil}) 

			endif

			//Busca ultima tes e cond. Pagto nas notas
			cQuery := ""
			cQuery := " SELECT TOP 1 D1_TES, F1_COND FROM " + RetSqlName("SD1") + " SD1 "
			cQuery += " INNER JOIN " + RetSqlName("SF1") + " SF1 ON F1_FILIAL = D1_FILIAL AND F1_DOC = D1_DOC AND F1_SERIE = D1_SERIE AND F1_FORNECE = D1_FORNECE AND F1_LOJA = D1_LOJA AND F1_TIPO = D1_TIPO AND F1_COND <> '' AND SF1.D_E_L_E_T_ = '' "
			cQuery += " WHERE "
			cQuery += " D1_EMISSAO = ( SELECT MAX(D1_EMISSAO) FROM " + RetSqlName("SD1") + " SD1A where SD1A.D_E_L_E_T_ = '' AND SD1A.D1_TES <> '' ) "
			cQuery += " AND SD1.D_E_L_E_T_ = '' "
			cQuery += " ORDER BY 1 "

			If Select("QRY") > 0

				dbSelectArea("QRY")
				QRY->( dbCloseArea() )
				
			EndIf

			TCQUERY (cQuery) ALIAS "QRY" NEW

			While QRY->( !Eof() )

				if !Empty( QRY->D1_TES )

					cUlTES   := QRY->D1_TES 

					if Empty( cCondPag )
						
						cCondPag := QRY->F1_COND

						aAdd(aCab, {"F1_COND" , cCondPag,  nil}) 

					endif

				endif

				QRY->( DbSkip() )

			End

			QRY->( DbCloseArea() )

			//Itens
			DbSelectArea("SD1")
			DbSetOrder(1)
			DbSeek(xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA )

			While SD1->( !Eof() ) .and. SF1->F1_DOC + SF1->F1_SERIE  + SF1->F1_FORNECE + SF1->F1_LOJA == SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA

				aItem := {}
				
				aadd(aItem,{"D1_ITEM" ,SD1->D1_ITEM ,NIL})
				aadd(aItem,{"D1_COD" ,SD1->D1_COD ,NIL})
				aadd(aItem,{"D1_UM" ,SD1->D1_UM ,NIL})
				aadd(aItem,{"D1_LOCAL" ,SD1->D1_LOCAL,NIL})
				aadd(aItem,{"D1_QUANT" ,SD1->D1_QUANT ,NIL})
				aadd(aItem,{"D1_VUNIT" ,SD1->D1_VUNIT ,NIL})
				aadd(aItem,{"D1_TOTAL" ,SD1->D1_TOTAL ,NIL})

				DbSelectArea("SB1")
				DbSetOrder(1)
				DbSeek( xFilial("SB1") + SD1->D1_COD )

				if !Empty( cUlTES )

					cTes := cUlTES

				else

					cTes := SB1->B1_TE

				endif

				if SF1->F1_TIPO == "D"

					//Cliente
					DbSelectArea("SA1")
					DbSetOrder(3)
					DbSeek( xFilial("SA1") + xCnpj )

					//Nota de saida
					DbSelectArea("SD2")
					DbSetOrder(3)
					if DbSeek( xFilial("SD2") + SD1->D1_NFORI + SD1->D1_SERIORI + SA1->A1_COD + SA1->A1_LOJA + SD1->D1_COD + SD1->D1_ITEMORI )

						cTes := SD2->D2_TES

					endif
		
					DbSelectArea("SF4")
					DbSetOrder(1)
					DbSeek( xFilial("SF4") + cTes )

					if !Empty(SF4->F4_TESDV) .and. SF4->F4_TIPO == "S"

						cTes := SF4->F4_TESDV

					else

						if !Empty(cUlTES)

							cTes := cUlTES

						elseif !Empty(SB1->B1_TE)

							cTes := SB1->B1_TE

						else

							cTes := u_HFRETSF4() //Chama a rotina que retorna tes de entrada

						endif
						
					endif

				endif

				aadd(aItem,{"D1_TES" ,cTes ,NIL})

				aAdd(aItem, {"LINPOS" , "D1_ITEM",  SD1->D1_ITEM}) //ou SD1->D1_ITEM  se estiver posicionado.

				aadd(aItens,aItem)

				SD1->( DbSkip() )

			End

			MSExecAuto({|x,y,z,k| mata103(x,y,z,k)},aCab,aItens,4,.T.)  //Mata103(, , 4 , )  //FR - 20/05/2020 aqui não será chamada a tela de divergência, para tanto seria necessário o ponto de entrada MT100TOK que foi retirado do projeto
			//xRet103	    :=	MSExecAuto({|x,y,z| mata103(x,y,z)},aCabec,aItens,4, ,1)  //só classificar	

			If !lMsErroAuto
				ConOut(" Inclusao realizada com sucesso")
			Else
				MostraErro()
				ConOut("Erro na inclusao!")
			EndIf			

		else

			Mata103(, , 4 , )

			If !lMsErroAuto
				ConOut(" Inclusao realizada com sucesso")
			Else
				MostraErro()
				ConOut("Erro na inclusao!")
			EndIf

		endif	
	
		aRotina := aClone( aAuxRot )

		//Verifica se não classificou. O usuario pode cancelar a tela de classificação
		if Empty( SF1->F1_STATUS )

			lRet := .F.

		Else //CLASSIFICOU

			//----------------------------------------------------------------------------------------------------//
			//FR - 22/12/2022 - PROJETO BRASMOLDE - NOTIFICAÇÕES POR EMAIL QDO BAIXA XML
			//Depois de Classificar a nota aciona rotina que dispara email caso esteja parametrizado para receber
			//----------------------------------------------------------------------------------------------------//
			cMail12 := GetNewPar("XM_MAIL12",Space(256))  //FR - 21/12/2022 - Flávia Rocha - EMAIL AVISANDO SOBRE NOVO XML GRAVADO NA BASE	
			If !Empty(cMail12) //emails que receberão notificação qdo gravar xml na base
								
				cFornec  := ""
				cLojFor  := ""
				cNomeFor := ""
				cRazao   := ""
				cCNPJ    := ""
				nFormNfe := Val(GetNewPar("XM_FORMNFE","9"))

				//cAssunto := "Nota Fiscal Classificada Com Sucesso"
				cAssunto := "Classificação NFe: " + SF1->F1_DOC + "/" + SF1->F1_SERIE 
				cTipo    := "2"  //classificação ok
				aMsg     := {}			
				cFornec  := SF1->F1_FORNECE 
				cLojFor  := SF1->F1_LOJA

				//se a nota for de beneficiamento ou devolução, pega do cad. cliente:
				If SF1->F1_TIPO $ "B/D"
					cNomeFor := Posicione("SA1",1,xFilial("SA1")+ cFornec + cLojFor,"A1_NOME")
					cCNPJ    := Posicione("SA1",1,xFilial("SA1")+ cFornec + cLojFor,"A1_CGC")
					cTpCliFor:= "Cliente"
				Else 
					cNomeFor := Posicione("SA2",1,xFilial("SA2")+ cFornec + cLojFor,"A2_NOME")
					cCNPJ    := Posicione("SA2",1,xFilial("SA2")+ cFornec + cLojFor,"A2_CGC")
					cTpCliFor:= "Fornecedor"
				Endif

				cRazao   := cNomeFor
				cMotivo  := ""
				cTAG     := ""
				cAssunto += "Forn: " + cFornec + "/" + cLojFor + "-" + cNomeFor + " - SUCESSO"

				U_FNOTIFICA(cMail12, cTipo, cFornec, cLojfor, cNomeFor, cRazao, cCNPJ, Val(SF1->F1_DOC), SF1->F1_SERIE, nFormNfe,SF1->F1_EMISSAO,cMotivo,cTAG,SF1->F1_CHVNFE,cTpCliFor)
								
				
				//MODELO
				//Assunto  - Nota Fiscal não importada com sucesso 
				//Conteúdo 
				//Fornecedor......: 000996 - TE CONNECTIVITY BRASIL IN
				//Nota Fiscal.....: 000196943/1 - Emissão: 19/04/2021
				//Chave da NFe....: 35210400907845001560550010001969431286545563
				//Situação SEFAZ..: 100 - Autorizado o uso da NF-e
				
			Endif
			
			//FR - 22/12/2022 - PROJETO BRASMOLDE - NOTIFICAÇÕES POR EMAIL QDO CLASSIFICA A NF
		endif

		lMata103 := .T.
		lMata140 := .F.

	else

		lRet := .F.

	EndIf 
	             
Endif    		//FR - 09/06/2020 - somente fará caso o parâmetro de criar NF direto NÃO ESTIVER ATIVADO. - "tarefa: gera nota fiscal direto"

SetKEY( VK_F3 ,  cKeyFe )

RestArea(aArea)

Return(lRet)    

//+-----------------------------------------------------------------------------------//
//|Funcao....: Get2Menu
//|Descricao.: Função para criação do menu (estilo mbrowse) necessário à rotina do
//|            ExecAuto
//|Observação: 
//+-----------------------------------------------------------------------------------//
User Function Get2Menu()

Local aMenu := {}
Local aSub1 := {}
//Local aSub2 := {}           

 
aSub1   := {{"Alterar"           ,"U_HFXML02M" ,0,2},; 
			{"Consulta Chave Xml","U_HFXML02X" ,0,2}}
                 
aMenu   := { {"Pesquisar"      ,"AxPesqui"   ,0,1,0,Nil},;
			 {"Baixar Xml"     ,"U_HFXML02D" ,0,2,0,Nil},;
			 {"&Visualiza NF"  ,"U_HFXML02V" ,0,2,0,Nil},;
			 {"Vis. Registro"  ,"AxVisual"   ,0,2,0,Nil},;
			 {"Gera &Pre Nota" ,"U_HFXML02P" ,0,4,0,Nil},;
			 {"Danfe"          ,"U_XMLPRTdoc",0,2,0,Nil},;
			 {"Exportar XML"   ,"U_HFXML02E" ,0,2,0,Nil},;
			 {"Funções XML"    , aSub1 		 ,0,5,0,Nil},;
			 {"Legenda"        ,"U_HFXML02L" ,0,2,0,Nil} }


Return(aMenu)

//+-----------------------------------------------------------------------------------//
//|Funcao....: NTReferenc
//|Descricao.: Localiza as amarrações do produto, valida a nf devolução
//|Observação: 
//+-----------------------------------------------------------------------------------//
User Function NTReferenc( oXml )

Local aArea       := GetArea()
//Local aLinha      := {}
Local _cFornec    := ""
Local _cLoja      := ""
Local _cClient    := ""
Local _cLojCli    := ""
Local _cProd      := ""
Local cProd       := ""
Local _cItem      := ""
Local _cCnpj      := ""
Local _nQuant     := 0
Local x           := 0
Local y           := 0
Local oDet
Local oItem       
//Local nDevNfe     := Val(GetNewPar("XM_DEVNFE","9"))
//Local nDevSer     := Val(GetNewPar("XM_DEVSER","1")) ///Incluido 09/10/2020
Local cTagRefNfe  := ""
Local cChvReg     := ""
Local cxNOr       := Space(9)
Local cxSOr       := "   "
Local lAcho       := .F.
Local cUsaFor     := GetNewPar("XM_USAFOR","N")

if cModelo == "55"

	if Type("oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_NFREF") <> "U" 
	
	oDet := oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_NFREF
	oDet := IIf(ValType(oDet) == "O",{oDet},oDet)
	
	nTotLen := Len(oDet)
	
	For x := 1 To nTotLen

		Do Case

			Case XmlChildEx(oDet[x],"_REFNFE") <> NIL

				cTagRefNfe := oDet[x]:_REFNFE:TEXT 

				cChvReg := cTagRefNfe            //&(cTagRefNfe) //NfeVincOri
				cxNOr   := Substr(cChvReg,26,9)
				cxSOr   := Substr(cChvReg,23,3)  //esta com 3 zeros

			Case XmlChildEx(oDet[x],"_REFNFP") <> NIL

				cxNOr := oDet[x]:_REFNFP:_NNF:TEXT
				cxSOr := oDet[x]:_REFNFP:_SERIE:TEXT

		EndCase
		
		//Fornecedor e Cliente
		if Type("oXml:_NFEPROC:_NFE:_INFNFE:_EMIT:_CNPJ") <> "U"
		
			_cCnpj := oXml:_NFEPROC:_NFE:_INFNFE:_EMIT:_CNPJ:TEXT
			
			DbSelectArea("SA2")
			DbSetOrder(3)
			if DbSeek( xFilial("SA2") + _cCnpj )
			
				_cFornec := SA2->A2_COD
				_cLoja   := SA2->A2_LOJA
			
			endif	
			
			DbSelectArea("SA1")
			DbSetOrder(3)
			if DbSeek( xFilial("SA1") + _cCnpj )
			
				_cClient := SA1->A1_COD
				_cLojCli := SA1->A1_LOJA
			
			endif	
		
		endif

		//Parametro criado para Daikin que usa fornecedor para notas de saida
		if cUsafor == "S"

			_cClient := _cFornec
			_cLojCli := _cLoja

		endif

		oItem := oXml:_NFEPROC:_NFE:_INFNFE:_DET

		oItem := iif( valtype(oItem)=="O", {oItem}, oItem )

		For y := 1 To Len(oItem)

			aNForig := {}
		
			//Produto
			Do Case

			Case Type("oXml:_NFEPROC:_NFE:_INFNFE:_DET["+ cValToChar(y) +"]:_PROD:_CPROD") <> "U"

				_cProd := oXml:_NFEPROC:_NFE:_INFNFE:_DET[y]:_PROD:_CPROD:TEXT

			Case Type("oXml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_CPROD") <> "U"

				_cProd := oXml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_CPROD:TEXT

			EndCase

			if !Empty( _cProd )

				Do Case
				
				Case cTipoCPro == "1"  //Amarração por produto

					if cTipoNf $ "D|B"
				
						DbSelectArea("SA7")
						DbSetOrder(3)
						if DbSeek( xFilial("SA7") + _cClient + _cLojCli + _cProd )
						
							cProd := SA7->A7_PRODUTO
						
						endif	

					else

						DbSelectArea("SA5")
						DbSetOrder(14)
						if DbSeek( xFilial("SA5") + _cFornec + _cLoja + _cProd )
						
							cProd := SA5->A5_PRODUTO
						
						endif	

					endif
					
				Case cTipoCPro == "2"  //Customizada ZB5
				
					DbSelectArea(xZB5)
					DbSetOrder(2)
					If DbSeek(xFilial(xZB5)+PADR((xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))),14) + _cProd)
					
						cProd := (xZB5)->(FieldGet(FieldPos(xZB5_+"PRODFI")))
					
					endif

					if Empty(cProd)

						DbSelectArea(xZB5)
						DbSetOrder(1)
						If DbSeek(xFilial(xZB5)+PADR((xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))),14) + _cProd)
						
							cProd := (xZB5)->(FieldGet(FieldPos(xZB5_+"PRODFI")))
						
						endif

					endif

				Case cTipoCPro == "3"	//Tipo de amarração 3 - Sem amarração

					DbSelectArea("SB1")
					DbSetOrder(1)
					if DbSeek( xFilial("SB1") + Padr( _cProd, TamSX3("B1_COD")[1] ) )

						cProd := SB1->B1_COD

					endif

				Case cTipoCPro == "4"	//Tipo de amarração 4 - Por Pedido

					if cTipoNf $ "D|B"
				
						DbSelectArea("SA7")
						DbSetOrder(3)
						if DbSeek( xFilial("SA7") + _cClient + _cLojCli + _cProd )
						
							cProd := SA7->A7_PRODUTO
						
						endif	

					else

						DbSelectArea("SA5")
						DbSetOrder(14)
						if DbSeek( xFilial("SA5") + _cFornec + _cLoja + _cProd )
						
							cProd := SA5->A5_PRODUTO
						
						endif	

					endif

					if Empty(cProd)

						DbSelectArea(xZB5)
						DbSetOrder(2)
						If DbSeek(xFilial(xZB5)+PADR((xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))),14) + _cProd)
						
							cProd := (xZB5)->(FieldGet(FieldPos(xZB5_+"PRODFI")))
						
						endif

						if Empty(cProd)

							DbSelectArea(xZB5)
							DbSetOrder(1)
							If DbSeek(xFilial(xZB5)+PADR((xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))),14) + _cProd)
							
								cProd := (xZB5)->(FieldGet(FieldPos(xZB5_+"PRODFI")))
							
							endif

						endif

					endif

					if Empty(cProd)

						DbSelectArea("SB1")
						DbSetOrder(1)
						if DbSeek( xFilial("SB1") + Padr( _cProd, TamSX3("B1_COD")[1] ) )

							cProd := SB1->B1_COD

						endif
						
					endif
			
				Case cTipoCPro == "5"	//Tipo de amarração 5 - Virtual

					if type("aitens") == "A"

						nPos :=  ASCAN(aItens[1], { |z| UPPER(z[1]) == "D1_COD" })

						if nPos > 0 

							DbSelectArea("SB1")
							DbSetOrder(1)
							if DbSeek( xFilial("SB1") + Padr( aItens[y,nPos,2], TamSX3("B1_COD")[1] ) )

								cProd := SB1->B1_COD

							endif

						endif

					endif

				EndCase	
			
			endif
			
			if !Empty(cxNOr) .and. !Empty(_cClient) .and. !Empty(cProd)

				DbSelectArea( "SF2" )
				DbSetOrder( 1 )

				lAcho := SF2->( DbSeek( xFilial("SF2") + cxNor + cxSOr ) )

				If .Not. lAcho

					xNfOri  := Substr( AllTrim( Str( val(cxNor) ) ) + space(len(SF2->F2_DOC)), 1, len(SF2->F2_DOC) )
					cxSOr := Substr( AllTrim( Str( val(cxSOr) ) ) + space(len(SF2->F2_SERIE)), 1, len(SF2->F2_SERIE) )
					lAcho := SF2->( DbSeek( xFilial("SF2") + cxNor + cxSOr ) )

					if .Not. lAcho
						cxNor   := StrZero( Val(cxNor), len(SF2->F2_DOC) )
						cxSOr := StrZero( Val(cxSOr), len(SF2->F2_SERIE) )
						lAcho   := SF2->( DbSeek( xFilial("SF2") + cxNor + cxSOr ) )
					Endif

					if .Not. lAcho
						cxNor   := StrZero( Val(cxNor), len(SF2->F2_DOC) )
						cxSOr := Substr( AllTrim( Str( val(cxSOr) ) ) + space(len(SF2->F2_SERIE)), 1, len(SF2->F2_SERIE) )
						lAcho   := SF2->( DbSeek( xFilial("SF2") + cxNor + cxSOr ) )
					Endif

					if .Not. lAcho
						cxNor   := Substr( AllTrim( Str( val(cxNor) ) ) + space(len(SF2->F2_DOC)), 1, len(SF2->F2_DOC) )
						cxSOr := StrZero( Val(cxSOr), len(SF2->F2_SERIE) )
						lAcho   := SF2->( DbSeek( xFilial("SF2") + cxNor + cxSOr ) )
					Endif

					if .Not. lAcho
						cxNor   := Substr( AllTrim( Str( val(cxNor), 6, 0 ) ) + space(len(SF2->F2_DOC)), 1, len(SF2->F2_DOC) )
						cxSOr := StrZero( Val(cxSOr), len(SF2->F2_SERIE) )
						lAcho   := SF2->( DbSeek( xFilial("SF2") + cxNor + cxSOr ) )
					Endif

					if .Not. lAcho
						cxNor   := Substr( AllTrim( Str( val(cxNor), 6, 0 ) ) + space(len(SF2->F2_DOC)), 1, len(SF2->F2_DOC) )
						cxSOr := Substr( AllTrim( Str( val(cxSOr) ) ) + space(len(SF2->F2_SERIE)), 1, len(SF2->F2_SERIE) )
						lAcho   := SF2->( DbSeek( xFilial("SF2") + cxNor + cxSOr ) )
					Endif

				EndIf

				if lAcho
			
					//Nota de saida
					cQuery := ""
					cQuery := " SELECT D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, D2_COD, D2_ITEM, D2_QUANT FROM "+ RetSqlName("SD2")
					cQuery += " WHERE "
					cQuery += " D2_DOC = '"+cxNor+"' AND D2_SERIE = '"+cxSOr+"' AND "
					cQuery += " D2_CLIENTE = '"+_cClient+"' AND D2_LOJA = '"+_cLojCli+"' AND "
					cQuery += " D2_COD = '"+cProd+"' AND D_E_L_E_T_ = '' "
					cQuery += " ORDER BY 1 "

					If Select("QRY") > 0                                 
						QRY->( DbCloseArea() )
					EndIf    

					TCQUERY (cQuery) ALIAS "QRY" NEW

					if !Empty( QRY->D2_DOC )
					
						While QRY->( !Eof() ) .and. alltrim(QRY->D2_COD) == Alltrim(cProd)
						
							_cItem  := QRY->D2_ITEM

							Do Case
							Case Type("oXml:_NFEPROC:_NFE:_INFNFE:_DET["+ cValToChar(y) +"]:_PROD:_QCOM") <> "U"

								_nQuant := oXml:_NFEPROC:_NFE:_INFNFE:_DET[y]:_PROD:_QCOM:TEXT

							Case Type("oXml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_QCOM") <> "U"

								_nQuant := oXml:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_QCOM:TEXT

							EndCase
							
							if Val(_nQuant) <= QRY->D2_QUANT
							
								aAdd(aNForig,{cxNOr,cxSOr,_cItem}) //Nota, Serie, Item					
								
							else 
							
								MsgAlert("Quantidade de devolução do item maior que a quantidade de saida. Verificar processo...")
							
							endif
							
							QRY->( DbSkip() )
						
						End

						QRY->( DbCloseArea() )
					
					endif

				endif
			
			endif

			//Para Devolução
			if ! Empty( aNForig )  //y <= Len(aNForig) 

				aadd(aItens[y], {"D1_NFORI"	 , aNForig[1,1]	,Nil})
				aadd(aItens[y], {"D1_SERIORI", aNForig[1,2]	,Nil})
				aadd(aItens[y], {"D1_ITEMORI", aNForig[1,3]	,"AllwaysTrue()"})

			endif

			//aadd(aItens[y],aLinha)
		
		Next y

	Next x

	endif

else

	if cModelo == "57"

		if Type("OXML:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE:_CHAVE:TEXT") <> "U" 

			cTagRefNfe := OXML:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE:_CHAVE:TEXT

			cChvReg := cTagRefNfe            //&(cTagRefNfe) //NfeVincOri
			cxNOr   := Substr(cChvReg,26,9)
			cxSOr   := Substr(cChvReg,23,3)  //esta com 3 zeros

			DbSelectArea( "SF2" )
			DbSetOrder( 1 )

			lAcho := SF2->( DbSeek( xFilial("SF2") + cxNor + cxSOr ) )

			if lAcho 

				aNForig := {}

				aAdd(aNForig,{cxNOr,cxSOr})

			else

				xNfOri  := Substr( AllTrim( Str( val(cxNor) ) ) + space(len(SF2->F2_DOC)), 1, len(SF2->F2_DOC) )
				cxSOr := Substr( AllTrim( Str( val(cxSOr) ) ) + space(len(SF2->F2_SERIE)), 1, len(SF2->F2_SERIE) )
				lAcho := SF2->( DbSeek( xFilial("SF2") + cxNor + cxSOr ) )

				if .Not. lAcho
					cxNor   := StrZero( Val(cxNor), len(SF2->F2_DOC) )
					cxSOr := StrZero( Val(cxSOr), len(SF2->F2_SERIE) )
					lAcho   := SF2->( DbSeek( xFilial("SF2") + cxNor + cxSOr ) )
				Endif

				if .Not. lAcho
					cxNor   := StrZero( Val(cxNor), len(SF2->F2_DOC) )
					cxSOr := Substr( AllTrim( Str( val(cxSOr) ) ) + space(len(SF2->F2_SERIE)), 1, len(SF2->F2_SERIE) )
					lAcho   := SF2->( DbSeek( xFilial("SF2") + cxNor + cxSOr ) )
				Endif

				if .Not. lAcho
					cxNor   := Substr( AllTrim( Str( val(cxNor) ) ) + space(len(SF2->F2_DOC)), 1, len(SF2->F2_DOC) )
					cxSOr := StrZero( Val(cxSOr), len(SF2->F2_SERIE) )
					lAcho   := SF2->( DbSeek( xFilial("SF2") + cxNor + cxSOr ) )
				Endif

				if .Not. lAcho
					cxNor   := Substr( AllTrim( Str( val(cxNor), 6, 0 ) ) + space(len(SF2->F2_DOC)), 1, len(SF2->F2_DOC) )
					cxSOr := StrZero( Val(cxSOr), len(SF2->F2_SERIE) )
					lAcho   := SF2->( DbSeek( xFilial("SF2") + cxNor + cxSOr ) )
				Endif

				if .Not. lAcho
					cxNor   := Substr( AllTrim( Str( val(cxNor), 6, 0 ) ) + space(len(SF2->F2_DOC)), 1, len(SF2->F2_DOC) )
					cxSOr := Substr( AllTrim( Str( val(cxSOr) ) ) + space(len(SF2->F2_SERIE)), 1, len(SF2->F2_SERIE) )
					lAcho   := SF2->( DbSeek( xFilial("SF2") + cxNor + cxSOr ) )
				Endif
	
				//cProd := cProduto
				aNForig := {}
				aAdd(aNForig,{cxNOr,cxSOr})

			endif

			//Para Devolução
			if ! Empty( aNForig )  //y <= Len(aNForig) 

				if FWIsInCallStack("MULTCTEGER") 

					cNFori   := aNForig[1,1]	
					cSROri   := aNForig[1,2]
					//cItemOri := aNForig[1,3]

				else

					aadd(aItens[1], {"D1_NFORI"	 , aNForig[1,1]	,Nil})
					aadd(aItens[1], {"D1_SERIORI", aNForig[1,2]	,Nil})
					//aadd(aItens[1], {"D1_ITEMORI", aNForig[1,3]	,"AllwaysTrue()"})

				endif

			endif

		endif

	endif
	
endif

RestArea( aArea )

Return()

//+-----------------------------------------------------------------------------------//
//|Funcao....: fDVGPC
//|Autoria...: Flávia Rocha - 11/05/2020
//|Descricao.: Verifica divergência pelo pedido de compra, desde que haja TES no PC
//|Observação: 
//+-----------------------------------------------------------------------------------//
User Function fDVGPC(aPedidos,cChaveXml,cDocXMl,cSerXml,dDataEntr,cCodEmit,cLojaEmit,cEspecXML,cTipoNF)

Local fr   := 0

aCabNFE    := {} //cabeçalho
aIteNFE    := {} //itens do PC           	
lGeraPrenf := .T. //indica se prossegue ou não com a geração da pré-nota
fr         := 0
				
SC7->(OrdSetFocus(1)) //C7_FILIAL + C7_NUM

If Len(aPedidos) > 0

	xC7Total	:= 0   
	xC7Baseicm 	:= 0
	xC7Valicm  	:= 0
	xC7Baseipi 	:= 0
	xC7Valipi  	:= 0
	xC7Baseir  	:= 0
	xC7Valir   	:= 0

	For fr := 1 to Len(aPedidos)

		If SC7->(Dbseek(xFilial("SC7") + aPedidos[fr] ))

			nC7Total   := 0 
			nC7Baseicm := 0
			nC7Valicm  := 0 
			nC7Baseipi := 0
			nC7Valipi  := 0
			nC7Baseir  := 0
			nC7Valir   := 0

			While SC7->(!Eof()) .AND. SC7->C7_FILIAL == xFilial("SC7") .AND. SC7->C7_NUM == aPedidos[fr]					
						
				Aadd( aIteNFE, { SC7->C7_ITEM	,; 		//01
								 SC7->C7_PRODUTO		,; 		//02
								 SC7->C7_QUANT			,;   	//03
								 SC7->C7_UM				,;	 	//04
								 SC7->C7_TES			,; 	 	//05	
								 "" 					,;		//06	
								 SC7->C7_PRECO			,;  	//07	
								 SC7->C7_TOTAL		  	,;  	//08
								 SC7->C7_BASEIPI		,;  	//09
								 SC7->C7_VALIPI		 	,;  	//10
								 SC7->C7_IPI	    	,;  	//11
								 SC7->C7_BASEICM		,;	 	//12
								 SC7->C7_VALICM		 	,; 		//13	 
								 SC7->C7_PICM	 	 	,;	   	//14	
								 0 /*nBasepis*/			,;	 	//15
								 0 /*nValpis*/		 	,;	 	//16
								 0 /*nPis*/		 		,;	 	//17
								 0 /*nBasecof*/			,;	 	//18
								 0 /*nValcof*/		 	,;	 	//19
								 0 /*nCof*/			   	,; 	 	//20
								 SC7->C7_BASEIR		 	,;	 	//21
								 SC7->C7_VALIR		 	,; 	 	//22
								 SC7->C7_ALIQIR			,;		//23								 
								 SC7->C7_TEC		    ;       //24  //FR - 19/06/2020 - ECOURBIS								 
								   } )   //Armazena no array de itens da NF, para comparar com o xml
										 
								 nC7Total   += SC7->C7_TOTAL 
								 nC7Baseicm += SC7->C7_BASEICM
								 nC7Valicm  += SC7->C7_VALICM 
								 nC7Baseipi += SC7->C7_BASEIPI
								 nC7Valipi  += SC7->C7_VALIPI
								 nC7Baseir  += SC7->C7_BASEIR
								 nC7Valir   += SC7->C7_VALIR
										 										 
				SC7->(Dbskip())
			Enddo
			//totais gerais para o cabeçalho
			xC7Total   += nC7Total
			xC7Baseicm += nC7Baseicm
			xC7Valicm  += nC7Valicm
			xC7Baseipi += nC7Baseipi
			xC7Valipi  += nC7Valipi
			xC7Baseir  += nC7Baseir
			xC7Valir   += nC7Valir
			          
        Endif
	Next
    Aadd( aCabNFE, {cDocXMl   		,;		//01-SF1->F1_DOC
					cSerXml			,;		//02-SF1->F1_SERIE
					dDataEntr		,;		//03-SF1->F1_EMISSAO
					cCodEmit   		,;		//04-SF1->F1_FORNECE
					cLojaEmit		,;		//05-SF1->F1_LOJA
					cEspecXML  		,;		//06-SF1->F1_ESPECIE
					cTipoNF	   		,;		//07-SF1->F1_TIPO
					xC7Total		,; 		//a140Total[VALMERC]	,;		//08-SF1->F1_VALMERC
					xC7Total		,; 		//a140Total[TOTPED]	;		//09-SF1->F1_VALBRUT
					xC7Baseicm		,;		//10-SF1->F1_BASEICM
					xC7Valicm	   	,;		//11-SF1->F1_VALICM
					xC7Baseipi		,;		//12-SF1->F1_BASEIPI
					xC7Valipi		,;		//13-SF1->F1_VALIPI
					0				,;		//14-SF1->F1_BASEPIS //Estes impostos não tem no SC7
					0		   		,;		//15-SF1->F1_VALPIS
					0	   			,;		//16-SF1->F1_BASCOFI
					0	   			,;		//17-SF1->F1_VALCOFI
					xC7Baseir		,;		//18-SF1->F1_(BASEIR) ?
					xC7Valir		;		//19-SF1->F1_VALIRF			
					})
Endif            
//chamada da tela de divergências:
lOmitTela  := Nil    //FR - .T. = omite a exibição da tela de divergência, e só gera o relatório em Excel, Nil mostra a tela
lGeraPrenf := U_HFXML063(cChaveXml,aCabNFE,aIteNFE,"PEDIDO DE COMPRA",aPedidos,lOmitTela)  //1-gera; 2-aborta

Return(lGeraPrenf)


//+-----------------------------------------------------------------------------------//
//|Funcao....: HFPRDINT
//|Autoria...: Rogerio Lino 18/07/2020
//|Descricao.: Produto Inteligente
//|Observação: 
//+-----------------------------------------------------------------------------------//
User Function HFPRDINT(i)
Local aProd      := {}
Local lProd      := .F.
Local _cCodProd  := ""

Private cProdXml  := ""
Private cDescXml  := ""

If cModelo $ "55,65"

	cProdXml := oDet[i]:_Prod:_CPROD:TEXT
	cDescXml := oDet[i]:_Prod:_XPROD:TEXT

ElseIf cModelo == "57,67"

	cProdXml := cProdCte
	cDescXml := "PRESTACAO DE SERVICO - FRETE"

EndIf

//Verifica se tem SA5/SA7
aProd := u_HFSA5SA7()

//Verifica se tem ZB5
if Len( aProd ) == 0

	aProd := u_HFPRDZB5()

endif

//Verifica e cadastra SB1
if Len( aProd ) == 0

	//Sequencial SB1
	_cCodProd := GetSxeNum("SB1","B1_COD")

	lProd := u_HFPRDSB1( _cCodProd, i )

	if lProd

		aadd( aProd, { cProdXml, cDescXml, _cCodProd, .T. } )

		ConfirmSx8()

	else

		RollbackSx8()

	endif

endif

Return aProd


//+-----------------------------------------------------------------------------------//
//|Funcao....: HFPRDSB1
//|Autoria...: Rogerio Lino
//|Descricao.: Rotina de Apoio do produto inteligente, VerIfica se tem produto ou
//|            se precisa cria-lo 
//|Observação: 
//+-----------------------------------------------------------------------------------//
//User Function HFPRDSB1( _cCodProd, i )
User Function HFPRDSB1( _cCodProd, i,xProd,xDescri,xModelo,xUM,xNCM,nIpi )     //FR - 15/04/2021 - mudança na chamada para adequar com parâmetros vindos da nova tela amarração
//                    ( código SB1,posição linha, código produto fornecedor, descrição produto, modelo xml , unidade medida, NCM, Alíq IPI)
Local oModel
Local lRet       := .F.
Local lOk        := .F.
Local aErro      := {}
Local cMessage   := ""
Local cTblCad    := Iif(cTipoNF $ "D|B","SA1","SA2")
Local cTblDP     := Iif(GetNewPar("XM_GRVZB5","S") == "S",xZB5, Iif(cTipoNF $ "D|B", "SA7","SA5")  )
Local lGravou    := .F.
Local cUn        := ""
Local cNcm       := ""
Local _cTipo     := ""
Local cNomEmit   := ""
Local cLojaEmit  := ""
Local cCodEmit   := ""

Default cProdXml := xProd
Default cDescXml := xDescri
Default cModelo  := xModelo 

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
//FR - 25/03/2022 - Alteração - Kitchens - Cadastro automático de produtos 
//Caso a unidade do XML não exista no cadastro de unidade de medidas, assume o código "UN"-"UNIDADE"
SAH->(OrdSetFocus(1))
If !SAH->(Dbseek(xFilial("SAH") + cUn)) 
	cUn := "UN"
Endif

//Pegando o modelo de dados, setando a operação de inclusão
oModel := FWLoadModel("MATA010")
oModel:SetOperation(3)
oModel:Activate()
   
//Pegando o model e setando os campos
oSB1Mod := oModel:GetModel("SB1MASTER")
oSB1Mod:SetValue("B1_COD"    , _cCodProd ) //oDet[i]:_Prod:_CPROD:TEXT

//FR - Alteração - 25/03/2022 - Cadastro automático produto - Kitchens
If xDescri == Nil											
	oSB1Mod:SetValue("B1_DESC"   , Substr(cDescXml,1,30) ) 
Else  
	oSB1Mod:SetValue("B1_DESC"   , Alltrim(Substr(xDescri,1,TAMSX3("B1_DESC")[1])) ) 
Endif 
//FR - Alteração - 25/03/2022 - Cadastro automático produto - Kitchens

oSB1Mod:SetValue("B1_TIPO"   , _cTipo ) 
oSB1Mod:SetValue("B1_UM"     , cUn  ) 
oSB1Mod:SetValue("B1_LOCPAD" , "01"  ) 
oSB1Mod:SetValue("B1_POSIPI" , cNcm  )

//FR - Alteração - 25/03/2022 - Cadastro automático produto - Kitchens 
//If nIpi <> Nil
//	oSB1Mod:SetValue("B1_IPI" , nIpi  ) 	
//Endif
//FR - Alteração - 25/03/2022 - Cadastro automático produto - Kitchens 

//Setando o complemento do produto
oSB5Mod := oModel:GetModel("SB5DETAIL")
If xDescri == Nil
	If oSB5Mod != Nil
	    oSB5Mod:SetValue("B5_CEME"   , cDescXml  )
	EndIf
Else 
	If oSB5Mod != Nil
	    oSB5Mod:SetValue("B5_CEME"   , Alltrim(Substr(xDescri,1,TAMSX3("B1_DESC")[1]))  )
	EndIf	
Endif 
   
//Se conseguir validar as informações
If oModel:VldData()
       
    //Tenta realizar o Commit
    If oModel:CommitData()
        lOk := .T.
           
    //Se não deu certo, altera a variável para false
    Else
        lOk := .F.
    EndIf
       
//Se não conseguir validar as informações, altera a variável para false
Else
    lOk := .F.
EndIf
   
//Se não deu certo a inclusão, mostra a mensagem de erro
If ! lOk

    //Busca o Erro do Modelo de Dados
    aErro := oModel:GetErrorMessage()
    If !IsBlind()
    	MostraErro()
    Endif 
       
    //Monta o Texto que será mostrado na tela
    cMessage := "Id do formulário de origem:"  + ' [' + cValToChar(aErro[01]) + '], ' + CRLF
    cMessage += "Id do campo de origem: "      + ' [' + cValToChar(aErro[02]) + '], ' + CRLF
    cMessage += "Id do formulário de erro: "   + ' [' + cValToChar(aErro[03]) + '], ' + CRLF
    cMessage += "Id do campo de erro: "        + ' [' + cValToChar(aErro[04]) + '], ' + CRLF
    cMessage += "Id do erro: "                 + ' [' + cValToChar(aErro[05]) + '], ' + CRLF
    cMessage += "Mensagem do erro: "           + ' [' + cValToChar(aErro[06]) + '], ' + CRLF
    cMessage += "Mensagem da solução: "        + ' [' + cValToChar(aErro[07]) + '], ' + CRLF
    cMessage += "Valor atribuído: "            + ' [' + cValToChar(aErro[08]) + '], ' + CRLF
    cMessage += "Valor anterior: "             + ' [' + cValToChar(aErro[09]) + ']'
     
    //Mostra mensagem de erro
    lRet := .F.
    //ConOut("Erro: " + cMessage)
	U_MyAviso("Atenção","Erro: " + cMessage,{"OK"},3)

Else

    lRet := .T.
    ConOut( "Produto incluido! - HFPRDSB1" )

	//cTagAux := "OXML:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_EMIT:_CNPJ:TEXT"  
	cCnpjEmi := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ")))

	/*If type( cTagAux ) <> "U"

		cCnpjEmi := &cTagAux

	Endif    */

	//Grava amarração produto x fornecedor 
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
			
				RecLock(xZB5,.T.)
				
				(xZB5)->(FieldPut(FieldPos(xZB5_+"FILIAL"), xFilial(xZB5)))
				(xZB5)->(FieldPut(FieldPos(xZB5_+"FORNEC"), cCodEmit))
				(xZB5)->(FieldPut(FieldPos(xZB5_+"LOJFOR"), cLojaEmit))
				(xZB5)->(FieldPut(FieldPos(xZB5_+"CGC"),    cCnpjEmi))
				(xZB5)->(FieldPut(FieldPos(xZB5_+"NOME"),   cNomEmit))
				//(xZB5)->(FieldPut(FieldPos(xZB5_+"PRODFO"), _cCodProd))  	//FR - 16/04/2021 - estava trocado os códigos				
				//(xZB5)->(FieldPut(FieldPos(xZB5_+"PRODFI"), cProdXml))	//FR - 16/04/2021 - estava trocado os códigos
				(xZB5)->(FieldPut(FieldPos(xZB5_+"PRODFO"), cProdXml))
				(xZB5)->(FieldPut(FieldPos(xZB5_+"PRODFI"), _cCodProd))
				(xZB5)->(FieldPut(FieldPos(xZB5_+"DESCPR"), cDescXml))
				(xZB5)->(FieldPut(FieldPos(xZB5_+"CLIENT"), ""))
				(xZB5)->(FieldPut(FieldPos(xZB5_+"CGCC"),   ""))
				(xZB5)->(FieldPut(FieldPos(xZB5_+"NOMEC"),  ""))
				(xZB5)->(FieldPut(FieldPos(xZB5_+"LOJCLI"), ""))
													
				MsUnlock()
				
				lGravou := .T.
				
			ElseIf cTblCad == "SA1"
			
				RecLock(xZB5,.T.)
				
				(xZB5)->(FieldPut(FieldPos(xZB5_+"FILIAL"), xFilial(xZB5)))
				(xZB5)->(FieldPut(FieldPos(xZB5_+"FORNEC"), ""))
				(xZB5)->(FieldPut(FieldPos(xZB5_+"LOJFOR"), ""))
				(xZB5)->(FieldPut(FieldPos(xZB5_+"CGC"),    ""))
				(xZB5)->(FieldPut(FieldPos(xZB5_+"NOME"),   ""))
				//(xZB5)->(FieldPut(FieldPos(xZB5_+"PRODFO"), _cCodProd)) 	//FR - 16/04/2021 - estava trocado os códigos				
				//(xZB5)->(FieldPut(FieldPos(xZB5_+"PRODFI"), cProdXml)) 	//FR - 16/04/2021 - estava trocado os códigos				
				(xZB5)->(FieldPut(FieldPos(xZB5_+"PRODFO"), cProdXml))
				(xZB5)->(FieldPut(FieldPos(xZB5_+"PRODFI"), _cCodProd))
				(xZB5)->(FieldPut(FieldPos(xZB5_+"DESCPR"), cDescXml))
				(xZB5)->(FieldPut(FieldPos(xZB5_+"CLIENT"), cCodEmit))
				(xZB5)->(FieldPut(FieldPos(xZB5_+"LOJCLI"), cLojaEmit))									
				(xZB5)->(FieldPut(FieldPos(xZB5_+"CGCC"),   cCnpjEmi))
				(xZB5)->(FieldPut(FieldPos(xZB5_+"NOMEC"),  cNomEmit))
			
				MsUnlock()
				
				lGravou := .T.
				
			EndIf	

		ElseIf cTblDP =="SA5"
		
			If cTblCad == "SA2"
			
				DbSelectArea("SA5")		
				DbSetOrder(1)
				If DbSeek(xFilial("SA5")+cCodEmit+cLojaEmit+cProdXml)
				
					if .not. empty( SA5->A5_CODPRF )
					
						Conout("Já existe um relacionamento cadastrado para o produto:"+CRLF+cProdXml+" - "+;
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
		
						Conout( "Já existe um relacionamento cadastrado para o produto:"+CRLF+cProdXml+" - "+;
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
					SA7->A7_DESCCLI := cDescXml //cNomEmit em 31/03/2014
					SA7->A7_PRODUTO := cProdXml
					SA7->A7_CODCLI  := _cCodProd
					
					MsUnlock()
					
					lGravou := .T.
					
				EndIf
				
			EndIf
			
		EndIf

	EndIf
							
	If lGravou 

		//U_MyAviso("Aviso","Relacionamento cadastrado com sucesso!",{"OK"},2)
		Conout("Relacionamento cadastrado com sucesso! - HFPRDSB1")

	EndIf

EndIf
   
//Desativa o modelo de dados
oModel:DeActivate()
oModel:Destroy()
 
oModel := NIL

Return lRet


//+-----------------------------------------------------------------------------------//
//|Funcao....: HFPRDZB5
//|Autoria...: Rogerio Lino
//|Descricao.: Rotina de Apoio do produto inteligente, Verifica se tem produto amarrado
//|            na tabela ZB5
//|Observação: 
//+-----------------------------------------------------------------------------------//
User Function HFPRDZB5()

Local cProduto := ""
Local aProdOK  := {}

If cTipoNF $ "D|B"

	DbSelectArea(xZB5)
	DbSetOrder(2)
	// Filial + CNPJ CLIENTE + Codigo do Produto do Fornecedor
	If DbSeek( xFilial(xZB5) + PADR((xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))),14) + cProdXml )

		cProduto := (xZB5)->(FieldGet(FieldPos(xZB5_+"PRODFI"))) //ZB5_PRODFI

		aadd(aProdOk,{ cProdXml, cDescXml, cProduto, .T. } )

	//Else

		//aadd(aProdNo,{ oDet[i]:_Prod:_CPROD:TEXT, oDet[i]:_Prod:_XPROD:TEXT, cProduto } )

	EndIf

Else

	DbSelectArea(xZB5)
	DbSetOrder(1)
	// Filial + CNPJ FORNECEDOR + Codigo do Produto do Fornecedor
	If DbSeek( xFilial(xZB5) + PADR((xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))),14) + cProdXml )

		cProduto := (xZB5)->(FieldGet(FieldPos(xZB5_+"PRODFI"))) //ZB5_PRODFI

		aadd(aProdOk,{ cProdXml, cDescXml, cProduto, .T. } )

	//Else

		//aadd(aProdNo,{oDet[i]:_Prod:_CPROD:TEXT,oDet[i]:_Prod:_XPROD:TEXT} )

	EndIf

EndIF

Return aProdOK


//+-----------------------------------------------------------------------------------//
//|Funcao....: HFSA5SA7
//|Descricao.: Rotina de Apoio do produto inteligente
//|            Verifica se tem produto amarrado na tabela SA5/SA7 
//|Observação: 
//+-----------------------------------------------------------------------------------//
User Function HFSA5SA7()

//Local aItem     := {}
Local cProduto  := ""
Local cCodEmit  := ""
Local cLojaEmit := ""
Local cAliasSA7 := ""
Local cAliasSA5 := ""
Local cKeySA7   := ""
Local cKeySA5   := ""
Local cKeyTMP   := ""
Local aProdOK   := {}

If cTipoNF $ "D|B" // dDevolução / Beneficiamento ( utiliza Cliente )

	if empty( cCodEmit )

		cCodEmit  := Posicione("SA1",3,xFilial("SA1")+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))),"A1_COD")
		cLojaEmit := Posicione("SA1",3,xFilial("SA1")+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))),"A1_LOJA")

	endif

	cAliasSA7 := GetNextAlias()

	cWhere := "%(SA7.A7_CODCLI IN ("
	cWhere += "'"+U_TrocaAspas( AllTrim( cProdXml ) )+"'"
	cWhere += ") )%"

		BeginSql Alias cAliasSA7
			SELECT
				A7_FILIAL,
				A7_CLIENTE,
				A7_LOJA,
				A7_CODCLI,
				A7_PRODUTO,
				R_E_C_N_O_
			FROM
				%Table:SA7% SA7
			WHERE
				SA7.%notdel%
				AND A7_CLIENTE = %Exp:cCodEmit%
				AND A7_LOJA = %Exp:cLojaEmit%
				AND %Exp:cWhere%
			ORDER BY
				A7_FILIAL,
				A7_CLIENTE,
				A7_LOJA,
				A7_CODCLI
		EndSql

	DbSelectArea(cAliasSA7)            
	Dbgotop()
	lFound  := .F.
	cKeySa7 := xFilial("SA7")+cCodEmit+cLojaEmit+U_TrocaAspas( cProdXml )
	
	While !(cAliasSA7)->(EOF())

		cKeyTMP := (cAliasSA7)->A7_FILIAL+(cAliasSA7)->A7_CLIENTE+(cAliasSA7)->A7_LOJA+(cAliasSA7)->A7_CODCLI
		
		If AllTrim(cKeySa7) == AllTrim(cKeyTMP)

			lFound := .T.
			Exit

		Endif

		(cAliasSA7)->(DbSkip())

	Enddo

	If lFound

		cProduto := (cAliasSA7)->A7_PRODUTO
		aadd(aProdOk,{ U_TrocaAspas( cProdXml ), cDescXml, cProduto, .T. } )

	//Else

		//aadd(aProdNo,{U_TrocaAspas( oDet[i]:_Prod:_CPROD:TEXT ),oDet[i]:_Prod:_XPROD:TEXT} )

	EndIf

	DbCloseArea()

Else
	
	if empty( cCodEmit )

		cCodEmit  := Posicione("SA2",3,xFilial("SA2")+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))),"A2_COD")
		cLojaEmit := Posicione("SA2",3,xFilial("SA2")+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))),"A2_LOJA")
	
	endif

	cAliasSA5 := GetNextAlias()

	cWhere := "%(SA5.A5_CODPRF IN ("				               
	cWhere += "'" + U_TrocaAspas( AllTrim( cProdXml ) ) + "'"
	cWhere += ") )%"				               	

		BeginSql Alias cAliasSA5
			SELECT
				A5_FILIAL,
				A5_FORNECE,
				A5_LOJA,
				A5_CODPRF,
				A5_PRODUTO,
				R_E_C_N_O_
			FROM
				%Table:SA5% SA5
			WHERE
				SA5.%notdel%
				AND A5_FORNECE = %Exp:cCodEmit%
				AND A5_LOJA = %Exp:cLojaEmit%
				AND %Exp:cWhere%
			ORDER BY
				A5_FILIAL,
				A5_FORNECE,
				A5_LOJA,
				A5_CODPRF
		EndSql

	DbSelectArea(cAliasSA5)            
	Dbgotop()
	lFound  := .F.
	cKeySa5 := xFilial("SA5")+cCodEmit+cLojaEmit+U_TrocaAspas( cProdXml )
	
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
		aadd(aProdOk,{ U_TrocaAspas( cProdXml ), cDescXml, cProduto, .T. } )

	//Else         

		//aadd(aProdNo,{U_TrocaAspas( oDet[i]:_Prod:_CPROD:TEXT ),oDet[i]:_Prod:_XPROD:TEXT} )		

	EndIf

	DbCloseArea()
	
EndIF          		

Return aProdOK
//+-----------------------------------------------------------------------------------//
//|Funcao....: FREDownXML
//|Autoria...: Flávia Rocha - 06/08/2020
//|Descricao.: Efetua o redownload da chave selecionada em tentativas regidas pelo 
//|            parâmetro XM_TENTSEND
//|Observação: 
//+-----------------------------------------------------------------------------------//
User Function FREDownXML(cChaveXML)

Local lVazio 	:= .F.
Local lResumido := .F.
Local lReDowOK	:= .F.
Local lContinua := .T. 
Local lOrigemPNF:= .F.							//FR - 16/10/2020 

Private xZBZ    := GetNewPar("XM_TABXML","ZBZ")
Private xZBZ_   := iIf(Substr(xZBZ,1,1)=="S", Substr(xZBZ,2,2), Substr(xZBZ,1,3)) + "_"

//--------------------------------------------------------------//
//AQUI O REDOWNLOAD   
//--------------------------------------------------------------//
DbSelectArea( xZBZ )
dbSetORder( 3 )

If (xZBZ)->( dbSeek( cChaveXML ) )

	lVazio    := Empty( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML"))) )
    lResumido := Alltrim( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOWL"))) ) == "R"
    lOrigemPNF:= FWIsInCallStack("U_HFXML02P") //FR - 16/10/2020 - para saber se a chamada veio da rotina "Gera Pré-Nota"

	If lVazio .or. lResumido
		
		CONOUT("<GESTAOXML> CAMPO XML VAZIO - XML RESUMIDO <===")
		
		u_HFXNVMCHV(cChaveXML)
		//nRetDow := U_HFDGXML( cChaveXML, .T.  , .F. ,  NIL    , ""      , 0     , "2", cNsu  )

		DbSelectArea( xZBZ )
		(xZBZ)->(OrdSetFocus(3))
		(xZBZ)->( dbSeek( cChaveXML ) ) 
		
		Conout("NOTA ==> " + (xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA"))) )
		lResumido := Alltrim( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOWL"))) ) == "R"
		lVazio    := Empty( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML"))) )
		lContinua := lVazio  //.T. continua, .F. aborta
		
		If !lVazio .and. !lResumido

			Conout( "ReDownload OK => " + cChaveXML )

			lReDowOK := .T. //Redownload OK

			Reclock(xZBZ, .F.)
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"DREDOW"), dDatabase ))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"HREDOW"), Time()    ))
			(xZBZ)->(MsUnlock() )
		
		Else
		
			Conout( "ReDownload Nao Realizado => " + cChaveXML )
			
		Endif	    
		//EndDo
				
	Endif 	//lVazio
	
Else 

	Conout("Chave -> " + cChaveXML + " -> Nao Encontrada")
	
Endif //seek na ZBZ pela Chave
	
Return(lReDowOK)		//retorna se o Redownload foi OK = .T. ou não = .F.


//+-----------------------------------------------------------------------------------//
//|Funcao....: fAtu137
//|Autoria...: Flávia Rocha - 16/10/2020
//|Descricao.: Atualiza o status da chave na ZBS quando o resultado for 137
//|            Download indisponível
//|Observação: 
//+-----------------------------------------------------------------------------------//
User Function fAtu137(xChave)

Local aAreaZBS	  := {}
Local lGravZBS    := .F.
Local cQuery 	  := ""
Local LF	      := CHR(13) + CHR(10)
Local nRecZBS     := 0

Private xZBZ  	  := GetNewPar("XM_TABXML","ZBZ")
Private xZB5  	  := GetNewPar("XM_TABAMAR","ZB5")
Private xZBS  	  := GetNewPar("XM_TABSINC","ZBS")
Private xZBE      := GetNewPar("XM_TABEVEN","ZBE")
Private xZBZ_ 	  := iif(Substr(xZBZ,1,1)=="S", Substr(xZBZ,2,2), Substr(xZBZ,1,3)) + "_"
Private xZB5_ 	  := iif(Substr(xZB5,1,1)=="S", Substr(xZB5,2,2), Substr(xZB5,1,3)) + "_"
Private xZBS_ 	  := iif(Substr(xZBS,1,1)=="S", Substr(xZBS,2,2), Substr(xZBS,1,3)) + "_"
Private xZBE_     := iif(Substr(xZBE,1,1)=="S", Substr(xZBE,2,2), Substr(xZBE,1,3)) + "_"
Private xZBA  	  := GetNewPar("XM_TABAMA2","ZBA")
Private xZBA_ 	  := iif(Substr(xZBA,1,1)=="S", Substr(xZBA,2,2), Substr(xZBA,1,3)) + "_"
Private xZBC      := GetNewPar("XM_TABCAC","ZBC")
Private xZBC_     := iif(Substr(xZBC,1,1)=="S", Substr(xZBC,2,2), Substr(xZBC,1,3)) + "_"
Private xZBO      := GetNewPar("XM_TABOCOR","ZBO"), xRetSEF := ""
Private xZBO_     := iif(Substr(xZBO,1,1)=="S", Substr(xZBO,2,2), Substr(xZBO,1,3)) + "_"
Private xZBI      := GetNewPar("XM_TABIEXT","ZBI")
Private xZBI_     := iif(Substr(xZBI,1,1)=="S", Substr(xZBI,2,2), Substr(xZBI,1,3)) + "_"

DbSelectArea( xZBS )
Aadd(aAreaZBS, (xZBS)->( GetArea() ) )

cQuery := " SELECT ZBS.R_E_C_N_O_  RECZBS , " + xZBS_ + "CHAVE ,  " + xZBS_ + "CNF , " + xZBS_ + "ST "  + LF		//Seleciona o max de E4_CODIGO, para saber o último código de cond. pagto usado
cQuery += " FROM "       + RetSqlName(xZBS) + " ZBS "			+ LF
cQuery += " WHERE "								+ LF
cQuery += " ZBS.D_E_L_E_T_ <> '*' "				+ LF
cQuery += " AND "+ xZBS_+"CHAVE = '" + (xChave) +  "' " + LF

MemoWrite("C:\TEMP\fAtu137.sql" , cQuery)

If Select("TMPZBS") > 0
	dbSelectArea("TMPZBS")
	TMPZBS->(dbCloseArea())
EndIf

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPZBS", .T., .F. )
DbSelectArea("TMPZBS")
DbGoTop() 

If TMPZBS->(!Eof())
	nRecZBS := TMPZBS->RECZBS
	DbSelectArea( xZBS )

	Dbgoto(nRecZBS)
	Reclock( xZBS , .F. )
	(xZBS)->(FieldPut(FieldPos(xZBS_+"ST"), "99" ))		//99 é o status na ZBS para os downloads em que o documento não foi encontrado: cod. 137
	(xZBS)->(MsUnlock() )
	lGravZBS := .T.

	dbSelectArea("TMPZBS")
	TMPZBS->(dbCloseArea())

Endif

//RestArea(aAreaZBS)

Return(lGravZBS)


//=========================================================================//
//Função  : fAdNumOS
//Autoria : Flávia Rocha
//Data    : 28/12/2020
//Objetivo: Adiciona ao array de itens com o campo D1_ORDEM caso haja retorno
//          via tratativa do ponto de entrada XMLPEITE
//=========================================================================//          
User Function fAdNumOS(aItens,cModelo)

Local aLinha := {}
Local nPos   := 0
Local fr     := 0
Local xItem  := ""
Local xOS    := ""
Local xPC    := ""
Local xItPC  := ""


//-----------------------------------------------------------------------------------------------------------//
//FR - 28/12/2020 - #5922 - Chamado Razzo - Tratativa para incluir informação do número da OS no item da NF:   
//-----------------------------------------------------------------------------------------------------------//
aLinha := {} 
fr := 0
For fr := 1 to Len(aItens)
	
	xItem:= ""
	xOS  := ""
	xPC  := ""
	xItPC:= ""
	
	nPos := ASCAN(aItens[1], { |p| UPPER(alltrim(p[1])) == "D1_ITEM" })
	
	//localiza o item da nf:
	If nPos > 0
		xItem := aItens[fr][nPos][2]
		nPos := ASCAN(aItens[1], { |p| UPPER(alltrim(p[1])) == "D1_ORDEM" })
		If nPos > 0
			xOS := aItens[fr][nPos][2]
			//verifica se o campo D1_ORDEM está vazio ou preenchido, só faz a instrução abaixo se estiver vazio, para poupar processamento:
			If Empty(xOS)
				//verifica se está preenchido o número do pedido de compra:
				nPos := ASCAN(aItens[1], { |p| UPPER(alltrim(p[1])) == "D1_PEDIDO" })
				If nPos > 0
					xPC := aItens[fr][nPos][2]
					nPos := ASCAN(aItens[1], { |p| UPPER(alltrim(p[1])) == "D1_ITEMPED" })
					If nPos > 0
						xItPC:= aItens[fr][nPos][2]
						
						//de posse do pedido de compra e respectivo item, já podemos executar o PE XMLPEITE para trazer as informações da SC e OS:
						If cModelo $ "55,65"
							oDet := {}
							If Type( "oXml:_NFEPROC:_NFE:_INFNFE:_DET" ) <> "U"
								oDet := oXml:_NFEPROC:_NFE:_INFNFE:_DET
								oDet := IIf(ValType(oDet)=="O",{oDet},oDet)
							Endif
							
							//--------------------------------------------------------//
							//aqui executa o P.E. XMLPEITE e adiciona o número da OS:
							//--------------------------------------------------------//
							aRet :=	ExecBlock( "XMLPEITE", .F., .F., { SC7->C7_PRODUTO, oDet, Val(xItem) , SC7->C7_NUM, SC7->C7_ITEM } )  //FR - 28/12/2020 - #5922-RAZZO
							If ValType(aRet) == "A"
								AEval(aRet,{|x| AAdd(aLinha,x)})
							EndIf
							
						Endif
					Endif	//nPos do D1_ITEMPED
				Endif 	//nPos do D1_PEDIDO
			Endif 		//se o campo D1_ORDEM está vazio
		Endif			//nPos do D1_ORDEM
	Endif				//nPos do D1_ITEM
Next fr

If Len(aLinha) > 0
	aadd(aItens,aLinha)		//depois de povoado, aí adiciona ao aItens
Endif
	
Return

//==================================================================================//
//Função  : fGrvNumOS
//Autoria : Flávia Rocha
//Data    : 28/12/2020
//Objetivo: Gravar o número da ordem de serviço no campo D1_ORDEM
//          Desde que exista associação via pedido de compra e solicitação de compra
//          Foi necessária esta implementação porque o campo D1_ORDEM não consta na
//          getdados da pré-nota, somente consta no modo "Documento de Entrada" 
//          O acionamento desta função, é na gravação da pré-nota, desta maneira,
//          o registro na SD1 já "nasce" com o campo D1_ORDEM povoado.
//====================================================================================//
User Function fGrvNumOS(xDoc,xSeri,xForn,xLoj) //,xPed,xItPC)  
Local cNumSC := ""
Local cItemSC:= "" 
Local cNumOS := ""
Local xPed   := ""
Local xItPC  := ""

//SD1->(Dbgoto(xRecD1))
DbSelectArea("SD1")
SD1->(OrdSetFocus(1))		//D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM 
If SD1->(Dbseek(xFilial("SD1") + xDoc + xSeri + xForn + xLoj ))
	If SD1->(FieldPos("D1_ORDEM")) > 0 
		While !SD1->(Eof()) .and. SD1->D1_FILIAL == xFilial("SD1") .and. SD1->D1_DOC == xDoc .and. SD1->D1_SERIE == xSeri;
			                .and. SD1->D1_FORNECE == xForn .and. SD1->D1_LOJA == xLoj
			
			xPed   := SD1->D1_PEDIDO
			xItPC  := SD1->D1_ITEMPC
			cNumOS := ""
			cNumSC := ""
			cItemSC:= ""
			
			SC7->(OrdSetFocus(1)) //C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN 
			If SC7->(Dbseek(xFilial("SC7") + xPed + xItPC ))	//localiza o pedido para obter o número da solicitação de compra
				cNumSC := SC7->C7_NUMSC
				cItemSC:= SC7->C7_ITEMSC
				
				If !Empty(cNumSC)
					SC1->(OrdSetFocus(1))	//C1_FILIAL + C1_NUM + C1_ITEM
					SC1->(Dbseek(xFilial("SC1") + cNumSC + cItemSC ))
					cNumOS := SC1->C1_OS
					
					If !Empty(cNumOs)
						Reclock("SD1",.F.)
						SD1->D1_ORDEM := cNumOS
						SD1->(MsUnlock())
					Endif //se número da OS está preenchido
					 
				Endif	//se número da SC está preenchido
			
			Endif  		//dbseek na SC7                
			
			SD1->(Dbskip()) 
			
		Enddo
	Endif
Endif //dbseek da SD1

Return


//+-----------------------------------------------------------------------------------//
//|Funcao....: HFRETSF4
//|Autoria...: Rogério Lino - 21/01/2021
//|Descricao.: Retorna a primeira tes valida de entrada.
//|Observação: 
//+-----------------------------------------------------------------------------------//
User Function HFRETSF4()

Local cRet    := "" 
Local cQuery  := ""
Local LF      := CHR(13) + CHR(10)

cQuery := ""
cQuery += " SELECT TOP 1 F4_CODIGO " + LF //"+xZBE_+"CHAVE as CHAVE, "+xZBE_+"DESC as DESC,  "+xZBE_+"TPEVE as TPEVE " + LF
cQuery += " FROM " + RetSqlName("SF4") + " SF4 " + LF
cQuery += " WHERE SF4.D_E_L_E_T_ = '' AND F4_MSBLQL <> '1' AND F4_TIPO = 'E' "	+ LF
cQuery += " ORDER BY F4_CODIGO ASC " + LF

If Select("TCQ") > 0

	dbSelectArea("TCQ")
    TCQ->(dbCloseArea())

EndIf

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TCQ", .T., .F. )

DbSelectArea("TCQ")
DbGoTop()

If TCQ->(!Eof())

 	cRet := TCQ->F4_CODIGO

Endif  

TCQ->( DbCloseArea() )

Return( cRet )

//==========================================================================//
// Programa  fNoAcento  - Autor: Roberto Souza        Data: 07/10/2011      //
//                      - Adaptado por: Flávia Rocha  Data: 08/02/2021      //
//==========================================================================//
// Descricao  Retira caracteres especiais.                                  //
//==========================================================================//
// Uso       Importa Xml                                                    //
//==========================================================================//
User Function fNoAcento(cString)

Local cChar  := ""
Local nX     := 0
Local nY     := 0
Local cVogal := "aeiouAEIOU"
Local cAgudo := "áéíóú"+"ÁÉÍÓÚ"
Local cCircu := "âêîôû"+"ÂÊÎÔÛ"
Local cTrema := "äëïöü"+"ÄËÏÖÜ"
Local cCrase := "àèìòù"+"ÀÈÌÒÙ"
Local cTio   := "ãõ"
Local cCecid := "çÇ"
//Local lChar  := .F.

For nX:= 1 To Len(cString)

	cChar:=SubStr(cString, nX, 1)

	IF cChar$cAgudo+cCircu+cTrema+cCecid+cTio+cCrase

		nY:= At(cChar,cAgudo)

		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf

		nY:= At(cChar,cCircu)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf

		nY:= At(cChar,cTrema)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf

		nY:= At(cChar,cCrase)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf

		nY:= At(cChar,cTio)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("ao",nY,1))
		EndIf

		nY:= At(cChar,cCecid)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("cC",nY,1))
		EndIf

	Endif

Next

For nX := 1 To Len(cString)

	cChar:=SubStr(cString, nX, 1)

	If Asc(cChar) < 32 .Or. Asc(cChar) > 123// .and. (cChar<> 10 .And. cChar<> 13)

		cString:=StrTran(cString,cChar,".")

	Endif

Next nX

Return(cString)

//------------------------------------------------------------------------------------------------------------//
//FUNÇÃO UTILIZADA NA TELA DE GERA DOCUMENTO ENTRADA QDO PARAMETRIZADO "GERA DOCUMENTO ENTRADA DIRETO"
//CASO NÃO ENCONTRE O TES NEM NO PEDIDO COMPRA, NEM NO CADASTRO PRODUTO, DÁ ESSA CHANCE AO USUÁRIO INFORMAR
//------------------------------------------------------------------------------------------------------------//
STATIC FUNCTION FEXISTCPO(xCONTEUDO,xTIPO)
Local lOK := .T.

If xTIPO == "1" //TES
	If Empty(xCONTEUDO)
		MsgAlert("Precisa Preencher o TES")
		lOK := .F.
	Else 
		SF4->(OrdSetFocus(1))
		If !SF4->(Dbseek(xFilial("SF4") + xCONTEUDO))
			MsgAlert("TES Não Localizado !!!")
			lOK := .F.	
		Elseif SF4->F4_MSBLQL == '1'
			MsgAlert("TES Bloqueado no Cadastro !!!")
			lOK := .F.
		Endif 
	Endif

Elseif xTIPO == "2"  //condição pagto
	If Empty(xCONTEUDO)
		MsgAlert("Precisa Preencher a CONDIÇÃO PAGTO")
		lOK := .F.
	Else 
		SE4->(OrdSetFocus(1))
		If !SE4->(Dbseek(xFilial("SE4") + xCONTEUDO))
			MsgAlert("COND.PAGTO Não Localizada !!!")
			lOK := .F.	
		Elseif SE4->E4_MSBLQL == '1'
			MsgAlert("COND.PAGTO Bloqueado no Cadastro !!!")
			lOK := .F.		 
		Endif 
	Endif
Elseif xTIPO == "3"  //natureza
	If Empty(xCONTEUDO)
		MsgAlert("Precisa Preencher a NATUREZA")
		lOK := .F.
	Else 
		SED->(OrdSetFocus(1))
		If !SED->(Dbseek(xFilial("SED") + xCONTEUDO))
			MsgAlert("NATUREZA Não Localizada !!!")
			lOK := .F.	
		Elseif SED->ED_MSBLQL == '1'
			MsgAlert("NATUREZA Bloqueado no Cadastro !!!")
			lOK := .F.		 
		Endif 
	Endif
Endif  

Return(lOK)


//--------------------------------------------------------------//
//Função  : fAnexaBco
//Objetivo: Cria registros nas tabelas do banco de conhecimento
//Autoria : Flávia Rocha
//Data    : 31/03/2022
//--------------------------------------------------------------//
Static Function fAnexaBco(cArq,cNUMDOC,cSeri,xForn,xLoj)        //cArq = nome do arquivo.extensão , cNUMPC = Numero do pedido de compra + item (0001)
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
				
PARA CRIAR OS REGISTROS, COPIAR TAMBÉM PARA A SEGUINTE PASTA:
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
//Verifica se o objeto já existe na ACB, senão, cria:
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
	cProxObj := ACB->ACB_CODOBJ  //se encontrou, pega o código do objeto		
Endif					
					
//cCodent := 	cFilant + cNUMDOC + Space(2) + xForn + xLoj //numero Nf+série + espaço(2) + código+loja fornecedor
cCodent := 	cNUMDOC + cSeri + xForn + xLoj //numero Nf+ série + código+loja fornecedor
				
//grava AC9
DbSelectArea("AC9")
AC9->(OrdSetFocus(1)) //AC9_FILIAL+AC9_CODOBJ+AC9_ENTIDA+AC9_FILENT+AC9_CODENT
If !AC9->(Dbseek(xFilial("AC9") + cProxObj + "SF1" + cFilAnt + cCodent)) 
	RecLock("AC9",.T.) 
	
	AC9->AC9_FILIAL := xFilial("AC9")
	AC9->AC9_FILENT := cFilAnt
	AC9->AC9_ENTIDA := "SF1"
	AC9->AC9_CODENT := cCodent
	AC9->AC9_CODOBJ := cProxObj
	
	AC9->(MsUnlock())
	lAnexou := .T.
	
Endif 

RestArea(aArea)

Return(lAnexou)

//==================================================================================//
//Função  : fProxACB 
//Autoria : Flávia Rocha
//Data    : 30/03/2022
//Objetivo: Função para trazer o próximo código livre da tabela ACB
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
