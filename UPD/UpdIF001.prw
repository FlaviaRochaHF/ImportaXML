#INCLUDE "PROTHEUS.CH"
#INCLUDE "UPDCOMP.CH"

static nVersao := Val( GetVersao( .F.) )
static cReleas := GetRPORelease()

#DEFINE X3_USADO_EMUSO			iif( (nVersao<12 .or. cReleas < "12.1.025"), "€€€€€€€€€€€€€€ ", "x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x"  ) 
#DEFINE X3_USADO_NAOUSADO		"€€€€€€€€€€€€€€€"
#DEFINE X3_USADO_USADOKEY		"€€€€€€€€€€€€€€°"
#DEFINE X3_USADO_NAOALTERA		iif( (nVersao<12 .or. cReleas < "12.1.025"), "€€€€€€€€€€€€€€° ", "x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x"  )
#DEFINE X3_OBRIGATORIO			"Á€"                  
#DEFINE X3_RESER 				"þÀ"
#DEFINE X3_RESER_NUMERICO		"øÇ" 
#DEFINE X3_RESER_DATA			"“€" 
#DEFINE X3_RESER_ALTERA_TAM		"–À"
#DEFINE X3_RESERKEY				"ƒ€"
#DEFINE X3_RES					"€€"               
#DEFINE X3_RESNAO				"›€"               
#DEFINE X3_NAOOBRIGAT			"šÀ" 
#DEFINE X3_RESER_ALT_TAM_DEC    "Ü+"
//#DEFINE X3_USADO               "x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x"

#DEFINE SIMPLES Char( 39 )
#DEFINE DUPLAS  Char( 34 )

#DEFINE CSSBOTAO	"QPushButton { color: #024670; "+;
					"    border-image: url(rpo:fwstd_btn_nml.png) 3 3 3 3 stretch; "+;
					"    border-top-width: 3px; "+;
					"    border-left-width: 3px; "+;
					"    border-right-width: 3px; "+;
					"    border-bottom-width: 3px }"+;
					"QPushButton:pressed {	color: #FFFFFF; "+;
					"    border-image: url(rpo:fwstd_btn_prd.png) 3 3 3 3 stretch; "+;
					"    border-top-width: 3px; "+;
					"    border-left-width: 3px; "+;
					"    border-right-width: 3px; "+;
					"    border-bottom-width: 3px }"

//--------------------------------------------------------------------
/*/{Protheus.doc} UPDCOMP
Função de update de dicionários para compatibilização
/*/

//--------------------------------------------------------------------------//
//Alterações realizadas:
//FR - 16/03/2020 - Projeto Politec - criação dos campos: ZBT_ITEM, ZBT_NOTA, 
//                  ZBT_SERIE, ZBT_CLIFOR, ZBT_LOJA, ZBT_TIPOFO
//                  Para gravação das notas de origem que compõem 
//                  o Cte por linha na ZBT e SD1.
//----------------------------------------------------------------------------//
//FR 19/05/2020 - Alterações realizadas para incluir novo novo parâmetro 
//                XM_USADVG - ativa ou desativa a verificação de divergências
//                entre XML x NF
//----------------------------------------------------------------------------//
//FR - 04/06/2020 - Projeto CCM: criação de novo campo ZBZ_ORIPRT 
//                  Origem da prestação de serviço: irá armazenar:
//                  o município - UF. Ex.: JUNDIAI - SP
//----------------------------------------------------------------------------//
//FR - 16/07/2020 - Águas do Brasil: Adequação da performance do download, 
//                  na execução do Job Aguas do Brasil, criação do parâmetro
//                  XM_ITSLEEP
//----------------------------------------------------------------------------//
//HM - 17/08/2020 - Eventos de manifestação, aumento do campo ZBE_DESC
//                  (Descrição do evento), aumento de 50 para 254 caracteres 
//--------------------------------------------------------------------------//
//FR - 20/08/2020 - Criação do parâmetro XM_SEPARAD, para guardar caracteres
//                  utilizados como "separadores" entre strings
//                  ex.: pedido de compra: 020236/000027/020211
//                  neste caso, a "barra" é um separador
//--------------------------------------------------------------------------//
//FR - 08/09/2020 - Criação de novo campo ZBE_DTHRGR grava a data e hora 
//                  da geração do registro na ZBE 
//                  Criação do parâmetro XM_CFOENERG, para guardar os CFOPs
//                  utilizados nas NFs de Energia (Kroma)
//--------------------------------------------------------------------------//
//FR - 14/09/2020 - Adequação para o campo _FILIAL pois há empresas que 
//                  utilizam até 6 caracteres para o campo FILIAL
//					Ex.: Aguas do Br
//--------------------------------------------------------------------------//
//FR - 22/09/2020 - Inclusão dos parâmetros:
//                  XM_CLATPNF: 
//                  armazena os tipos de NF que podem ser classificadas
//					automaticamente (escolha do cliente)
//
//					XM_DIASVCT: número de dias úteis para cálculo do vencimento
//                  da duplicata da nf de energia.
//--------------------------------------------------------------------------//
//FR - 16/10/2020 - Solicitações Rafael, tratativa para redownload:
//                  Criação de campos novos: 
//                  ZBZ_DREDOW: Dt último redownload
//                  ZBZ_HREDOW: Hr.último redownload//				
//--------------------------------------------------------------------------//
//FR - 09/11/2020 - Novo índice: Data emissão NF (ZBZ_DTNFE)
//--------------------------------------------------------------------------//
//FR - 12/11/2020 - Solicitado por Sintex - chamado 5680
//                  Novo parâmetro: XM_USAUMB1
//                  Indica se utilizará a Unidade Medida principal do produto
//                  Qdo em caso de diferença de UM entre Pedido x Xml
//                  e for escolhido "por XML"
//                  (e a medida do XML for diferente da UM principal do produto)
//                  P = usa UM do SB1
//                  X = usa UM xml
//
//                  Solicitado por Kroma Energia
//                  Novo parâmetro: XM_KRDIASR (Específico Kroma - Dias a Retroagir)
//                  Dias a retroagir para filtro das notas de energia para classificar
//                  Solicitado por Kroma Energia
//                  Em reunião realizada em  12/11/2020 Rafael solicitou que não
//                  precisa mostrar este parâmetro na tela F12 por ser algo específico
//                  da Kroma Energia apenas.
//-----------------------------------------------------------------------------------//
//FR - 24/11/2020 - Correção do campo TAMANHO FILIAL das tabelas ZBM / ZBN
//-----------------------------------------------------------------------------------//
//FR - 10/12/2020 - Correção para aumento do campo ZBT_QUANT de 2 casas decimais para 4
//                  Chamado #5860 - ADAR
//-----------------------------------------------------------------------------------//
//FR - 15/02/2021 - #6166 - MaxiRubber - incluir campo nos itens do xml (ZBT), 
//                 que armazene a chave da nf original: ZBT_CHAVEO
//-----------------------------------------------------------------------------------//
//NA - 02/03/2021 - Projeto Nordson - criação de parâmetro para tela F12 
//                  XM_CENTRO - este parâmetro será utilizado pela rotina Múltiplos
//                  CTE - rege se a rotina buscará o centro de custo da NF Saída (SD2)
//                  Ou do cadastro de produto (SB1).
//-----------------------------------------------------------------------------------//
//FR - 10/03/2021 - Melhorias na amarração de NF x XML 
//                  Solicitado por Rogério Lino   
//                  Implementação da função: fAlterF3() que inclui automaticamente
//                  na tabela SX3, as consultas padrões adicionadas nas tabelas.
//-----------------------------------------------------------------------------------//
//FR - 13/04/2021 - Alinhar o tamanho dos campos: ZBT_PRODUT e ZB5_PRODFO
//                  (código produto fornecedor) com a SA5 - A5_CODPRF
//                  Aumento dos campos: ZBT_PRODUT e ZB5_PRODFO
//-----------------------------------------------------------------------------------//
//FR - 15/04/2021 - Criação de novos campos: ZBT_UM , ZBT_NCM
//-----------------------------------------------------------------------------------//
//FR - 28/04/2021 - NOVA TELA GESTÃO XML - Solicitações feitas na reunião
//                  de apresentação para: Diretor Rafael e Coordenador Rogerio
//                  Criação de parâmetro para reger se traz os dados da 
//                  última compra 
//-----------------------------------------------------------------------------------//
//FR - 18/09/2021 - Criação de novo campo: ZBT_ITEMNF para amarrar à nota gerada qual
//                  item da nota se refere o item do XML
//-----------------------------------------------------------------------------------//
//FR - 28/10/2021 - Implementação cadastro fornecedor (SA2) automatizado (Daikin)
//                  Parâmetro: "XM_SA2AUTO" Tipo Caracter, conteúdo : S-Sim; N=Não
/*
//Escopo passado por Rafael Lobitsky - 28/10/2021:
Criar um parâmetro chamado : Fornecedor auto S=sim;N=não - "XM_SA2AUTO"
-> Help “ Informa se ao baixar o xml e não encontrar o fornecedor cadastrado , 
   efetua o cadastro do mesmo de forma robótica “
   
-> Incluir este parâmetro em nossa aba de cadastros gerais ou gerais2

-> Incluir este parâmetro no programa de instalador do GESTÃO XML para ao rodar 
   o compatibilizador será criado automático 
   
-> Utilizar nosso ponto de entrada do gestão XML para colocar a regra de criação 
   de código do fornecedor padrão Daikin no momento de ser criado de forma robotica
   (se usa montagem de de A2_COD modelo Daikin ou padrão SXENUM )
*/
//-----------------------------------------------------------------------------------//
//FR - 21/12/2021 - Revisão dos parâmetros de automatização do cadastro de 
//                  fornecedor:
//                  - XM_SA2AUTO - cadastra fornecedor na classif. nf
//                  - XM_SA2AUTD - cadastra fornecedor no download xml
//-----------------------------------------------------------------------------------//
//FR - 11/01/2022 - PETRA - 11840 - tela análise fiscal, incluir campo ICM ST
//-----------------------------------------------------------------------------------//
//FR - 17/02/2022 - RAFAEL LOBITSKY - Tópicos solicitados:
//                  Quando acionada a api que traz as informações do fornecedor:
//					Gravar no campo memo (ZBZ_OBS):
//                  - a url da Sefaz;
//                  - a situação do fornecedor (ATIVA OU INATIVA) 
//                  Criação parâmetro liga/desliga para gravar na nova tabela
//                  Log Consultas Fornecedor: ZBG
//                  Criação tabela nova: ZBG e campos
//------------------------------------------------------------------------------//
//FR - 02/03/2022 - OCRIM - AJUSTE DE CAMPOS - chamado 12100 
//					Aumento dos seguintes campos da tabela ZBT:
//					ZBT_PRODUT (de 20 para 60)
//					ZBT_DESCRI (de 30 para 120)
//					ZBT_UM (de 2 para 6)
//------------------------------------------------------------------------------//
//FR - 24/05/2022 - TELETEX - OPÇÕES DE MANIFESTAÇÃO ZBZ_MANIF                    
//------------------------------------------------------------------------------//
//FR - 05/08/2022 - PROJETO POLITEC CLASSIFICAÇÃO NFs COMBUSTÍVEIS
//------------------------------------------------------------------------------//
//FR - 27/01/2023 - DAIKIN - AJUSTE DE CAMPOS
//					Aumento dos seguintes campos da tabela ZBT:
//					ZBT_DESCRI (de 120 para 250) 
//-------------------------------------------------------------------------------//
//FR - 28/04/2023 - INCLUSÃO NOVO PARÂMETRO XM_PCMARK que rege se traz os itens 
//                  de pedidos de compras já pré-marcados [x]
//                  na tela de seleção de pedido de compra
//-------------------------------------------------------------------------------//
User Function UpdIF001( cEmpAmb, cFilAmb )

	Local   aSay      := {}
	Local   aButton   := {}
	Local   aMarcadas := {}
	//Local   cTitulo   := 'COMPATIBILIZADOR - GESTAO XML - ' + MesExtenso( Month( Date() ) ) //"ATUALIZAÇÃO DE DICIONÁRIOS E TABELAS"		//FR - 18/08/2020
	Local   cTitulo   := 'COMPATIBILIZADOR - GESTAO XML - JULHO/2023'
	Local   cDesc1    := "Esta rotina tem como função fazer  a atualização  dos dicionários do Sistema ( SX?/SIX )"
	Local   cDesc2    := "em relação as atualizações referentes ao projeto de Importação de XML de Fornecedores."
	Local   cDesc3    := "Este processo deve ser executado em modo EXCLUSIVO, ou seja não podem haver outros"
	Local   cDesc4    := "usuários  ou  jobs utilizando  o sistema.  É EXTREMAMENTE recomendavél  que  se  faça um"
	Local   cDesc5    := "BACKUP  dos DICIONÁRIOS  e da  BASE DE DADOS antes desta atualização, para que caso "
	Local   cDesc6    := "ocorram eventuais falhas, esse backup possa ser restaurado."
	Local   cDesc7    := ""
	Local   lOk       := .F.
	Local   lAuto     := .F. //( cEmpAmb <> NIL .or. cFilAmb <> NIL )

	Private oMainWnd  := NIL
	Private oProcess  := NIL
	Private lBOSSKEY  := AllTrim(GetSrvProfString("BOSSKEY","0"))=="1"
	Private cFilSm    := ""  //Aqui vai ser compartilhado
	Private nFilSm    := 0
	Private nFilLay   := 0
	Private lAltera   := .F.

	#IFDEF TOP
	    TCInternal( 5, "*OFF" ) // Desliga Refresh no Lock do Top
	#ENDIF

	__cInterNet := NIL
	__lPYME     := .F.

	Set Dele On

	// Mensagens de Tela Inicial
	aAdd( aSay, cDesc1 )
	aAdd( aSay, cDesc2 )
	aAdd( aSay, cDesc3 )
	aAdd( aSay, cDesc4 )
	aAdd( aSay, cDesc5 )
	aAdd( aSay, cDesc6 )
	aAdd( aSay, cDesc7 )

	// Botoes Tela Inicial
	aAdd(  aButton, {  1, .T., { || lOk := .T., FechaBatch() } } )
	aAdd(  aButton, {  2, .T., { || lOk := .F., FechaBatch() } } )

	If lAuto
		lOk := .T.
	Else
		FormBatch(  cTitulo,  aSay,  aButton )
	EndIf

	If lOk
		If lAuto
			aMarcadas :={{ cEmpAmb, cFilAmb, "" }}
		Else
			oProcess := MsNewProcess():New( { | lEnd | aMarcadas := EscEmpresa() }, "Aguarde", "Aguarde, verificando empresas ...", .F. )
			oProcess:Activate()
		EndIf

		If !Empty( aMarcadas )
			If lAuto .OR. MsgNoYes( "Confirma a atualização dos dicionários ?", cTitulo ) //"Confirma a atualização dos dicionários ?"
				oProcess := MsNewProcess():New( { | lEnd | lOk := FSTProc( @lEnd, aMarcadas, lAuto ) }, "Atualizando", "Aguarde, atualizando ...", .F. ) //"Atualizando"###"Aguarde, atualizando ..."
				oProcess:Activate()

				If lAuto
					If lOk
						MsgStop( "Atualização Realizada.", "UPDIF001" ) //"Atualização Realizada."
					Else
						MsgStop( "Atualização não Realizada.", "UPDIF001" ) //"Atualização não Realizada."
					EndIf
					dbCloseAll()
				Else
					If lOk
						Final( "Atualização Concluída." ) //"Atualização Concluída."
					Else
						Final( "Atualização não Realizada." ) //"Atualização não Realizada."
					EndIf
				EndIf

			Else
				MsgStop( "Atualização não Realizada.", "UPDIF001" ) //"Atualização não Realizada."

			EndIf

		Else
			MsgStop( "Atualização não Realizada.", "UPDIF001" ) //"Atualização não Realizada."

		EndIf

	EndIf

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSTProc
Função de processamento da gravação dos arquivos
/*/
//--------------------------------------------------------------------
Static Function FSTProc( lEnd, aMarcadas, lAuto )
	Local   aInfo     := {}
	Local   aRecnoSM0 := {}
	//Local   cAux      := ""
	Local   cFile     := ""
	//Local   cFileLog  := ""
	Local   cMask     := "Arquivos Texto" + "(*.TXT)|*.txt|" 
	Local   cTCBuild  := "TCGetBuild"
	Local   cTexto    := ""
	Local   cTopBuild := ""
	Local   lOpen     := .F.
	Local   lRet      := .T.
	Local   nI        := 0
	Local   nPos      := 0
	//Local   nRecno    := 0
	Local   nX        := 0
	Local   oDlg      := NIL
	Local   oFont     := NIL
	Local   oMemo     := NIL

	Private aArqUpd   := {}
	Private xZBZ, xZBZ_, xZB5, xZB5_, xZBX, xZBX_, xZBB, xZBB_, xZBS, xZBS_, xZBA, xZBA_, xZBE, xZBE_, xZYX, xZYX_, xZBC, xZBC_, xZBO, xZBO_, xZBI, xZBI_
	Private xZBT, xZBT_   		//FR 11/11/2019
	Private xZBM, xZBM_			//HMS 31/08/2020
	Private xZBN, xZBN_			//HMS 31/08/2020
	Private xZBD, xZBD_			//HMS 06/01/2021 
	Private xZBF, xZBF_			//HMS 14/04/2021 
	Private xZBG, xZBG_			//FR - 10/02/2022 - novas tabelas para armazenar os logs de consulta situação fornecedor (HFXML08F)

	Private xZBH, xZBH_			//HMS - 12/12/2022


	Private xSA2ZB5, xSA1ZB5, xSB1ZB5

	If ( lOpen := MyOpenSm0( .T.) )

		dbSelectArea( "SM0" )
		dbGoTop()

		While !SM0->( EOF() )
			// Só adiciona no aRecnoSM0 se a empresa for diferente
			If aScan( aRecnoSM0, { |x| x[2] == SM0->M0_CODIGO } ) == 0 ;
			   .AND. aScan( aMarcadas, { |x| x[1] == SM0->M0_CODIGO } ) > 0
			   nPos := aScan( aMarcadas, { |x| x[1] == SM0->M0_CODIGO } )
				//aAdd( aRecnoSM0, { Recno(), SM0->M0_CODIGO, "", "", "", aMarcadas[nPos][6], aMarcadas[nPos][7], aMarcadas[nPos][8], aMarcadas[nPos][9], aMarcadas[nPos][10], aMarcadas[nPos][11], aMarcadas[nPos][12], aMarcadas[nPos][13], aMarcadas[nPos][14], aMarcadas[nPos][15], aMarcadas[nPos][16], aMarcadas[nPos][17], aMarcadas[nPos][18], aMarcadas[nPos][19], aMarcadas[nPos][20] ,aMarcadas[nPos][21] } )
				//FR - 17/02/2022 - LOG Consulta fornecedores
				aAdd( aRecnoSM0, { Recno(), SM0->M0_CODIGO, "", "", "", aMarcadas[nPos][6], aMarcadas[nPos][7], aMarcadas[nPos][8], aMarcadas[nPos][9], aMarcadas[nPos][10], aMarcadas[nPos][11], aMarcadas[nPos][12], aMarcadas[nPos][13], aMarcadas[nPos][14], aMarcadas[nPos][15], aMarcadas[nPos][16], aMarcadas[nPos][17], aMarcadas[nPos][18], aMarcadas[nPos][19], aMarcadas[nPos][20] ,aMarcadas[nPos][21], aMarcadas[nPos][22],aMarcadas[nPos][23] } )
			EndIf
			SM0->( dbSkip() )
		End

		SM0->( dbCloseArea() )

		If lOpen

			For nI := 1 To Len( aRecnoSM0 )

				If !( lOpen := MyOpenSm0(.F.) )
					MsgStop( "Atualização da empresa " + aRecnoSM0[nI][2] + " não efetuada." ) //"Atualização da empresa "###" não efetuada."
					Exit
				EndIf

				SM0->( dbGoTo( aRecnoSM0[nI][1] ) )

				RpcSetType( 3 )
				RpcSetEnv( SM0->M0_CODIGO, SM0->M0_CODFIL )    
				//RpcSetEnv( SM0->M0_CODIGO, "02" )   	//FR TESTE 19/05/2020 

				xZBZ  := aRecnoSM0[nI][6]
				xZBZ_ := iif(Substr(xZBZ,1,1)=="S", Substr(xZBZ,2,2), Substr(xZBZ,1,3)) + "_"
				xZB5  := aRecnoSM0[nI][7]
				xZB5_ := iif(Substr(xZB5,1,1)=="S", Substr(xZB5,2,2), Substr(xZB5,1,3)) + "_"
				xZBB  := aRecnoSM0[nI][8]
				xZBB_ := iif(Substr(xZBB,1,1)=="S", Substr(xZBB,2,2), Substr(xZBB,1,3)) + "_"
				xZBX  := aRecnoSM0[nI][9]
				xZBX_ := iif(Substr(xZBX,1,1)=="S", Substr(xZBX,2,2), Substr(xZBX,1,3)) + "_"
				xZBS  := aRecnoSM0[nI][10]
				xZBS_ := iif(Substr(xZBS,1,1)=="S", Substr(xZBS,2,2), Substr(xZBS,1,3)) + "_"
				xZBA  := aRecnoSM0[nI][11]
				xZBA_ := iif(Substr(xZBA,1,1)=="S", Substr(xZBA,2,2), Substr(xZBA,1,3)) + "_"
				xZBE  := aRecnoSM0[nI][12]
				xZBE_ := iif(Substr(xZBE,1,1)=="S", Substr(xZBE,2,2), Substr(xZBE,1,3)) + "_"
				xZYX  := aRecnoSM0[nI][13]
				xZYX_ := iif(Substr(xZYX,1,1)=="S", Substr(xZYX,2,2), Substr(xZYX,1,3)) + "_"
				xZBC  := aRecnoSM0[nI][14]
				xZBC_ := iif(Substr(xZBC,1,1)=="S", Substr(xZBC,2,2), Substr(xZBC,1,3)) + "_"
				xZBO  := aRecnoSM0[nI][15]
				xZBO_ := iif(Substr(xZBO,1,1)=="S", Substr(xZBO,2,2), Substr(xZBO,1,3)) + "_"
				xZBI  := aRecnoSM0[nI][16]
				xZBI_ := iif(Substr(xZBI,1,1)=="S", Substr(xZBI,2,2), Substr(xZBI,1,3)) + "_"			
				xZBT  := aRecnoSM0[nI][17]                                                    		//FR 12/11/2019
				xZBT_ := iif(Substr(xZBT,1,1)=="S", Substr(xZBT,2,2), Substr(xZBT,1,3)) + "_"       //FR 12/11/2019
				xZBM  := aRecnoSM0[nI][18]                                                    		//HMS 31/08/2019
				xZBM_ := iif(Substr(xZBM,1,1)=="S", Substr(xZBM,2,2), Substr(xZBM,1,3)) + "_"       //HMS 31/08/2019
				xZBN  := aRecnoSM0[nI][19]                                                    		//HMS 03/09/2019
				xZBN_ := iif(Substr(xZBN,1,1)=="S", Substr(xZBN,2,2), Substr(xZBN,1,3)) + "_"       //HMS 03/09/2019
				xZBD  := aRecnoSM0[nI][20]                                                    		//HMS 06/01/2021
				xZBD_ := iif(Substr(xZBD,1,1)=="S", Substr(xZBD,2,2), Substr(xZBD,1,3)) + "_"       //HMS 06/01/2021				
				xZBF  := aRecnoSM0[nI][21]                                                    		//HMS 06/01/2021
				xZBF_ := iif(Substr(xZBF,1,1)=="S", Substr(xZBF,2,2), Substr(xZBF,1,3)) + "_"       //HMS 06/01/2021 
				
				xZBG  := aRecnoSM0[nI][22]                                                    		//HMS 06/01/2021
				xZBG_ := iif(Substr(xZBG,1,1)=="S", Substr(xZBG,2,2), Substr(xZBG,1,3)) + "_"       //FR - 17/02/2022 - Log Consulta Fornecedor

				xZBH  := aRecnoSM0[nI][23]                                                    		//HMS 06/01/2021
				xZBH_ := iif(Substr(xZBH,1,1)=="S", Substr(xZBH,2,2), Substr(xZBH,1,3)) + "_"       //FR - 17/02/2022 - Log Consulta Fornecedor


				xSA2ZB5 := "SA2"+xZB5
				xSA1ZB5 := "SA1"+xZB5
				xSB1ZB5 := "SB1"+xZB5

				lMsFinalAuto := .F.
				lMsHelpAuto  := .F.

				AutoGrLog( Replicate( "-", 124 ) )
				AutoGrLog( Replicate( " ", 124 ) )
				AutoGrLog( "LOG DA ATUALIZAÇÃO DOS DICIONÁRIOS" ) //"LOG DA ATUALIZAÇÃO DOS DICIONÁRIOS"
				AutoGrLog( Replicate( " ", 124 ) )
				AutoGrLog( Replicate( "-", 124 ) )
				AutoGrLog( " " )
				AutoGrLog( " Dados Ambiente" ) //" Dados Ambiente"
				AutoGrLog( " --------------------" )
				AutoGrLog( " Empresa / Filial...: " + cEmpAnt + "/" + cFilAnt ) //" Empresa / Filial...: "
				AutoGrLog( " Nome Empresa.......: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOMECOM", cEmpAnt + cFilAnt, 1, "" ) ) ) ) //" Nome Empresa.......: "
				AutoGrLog( " Nome Filial........: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) ) ) //" Nome Filial........: "
				AutoGrLog( " DataBase...........: " + DtoC( dDataBase ) ) //" DataBase...........: "
				AutoGrLog( " Data / Hora Ínicio.: " + DtoC( Date() )  + " / " + Time() ) //" Data / Hora Ínicio.: "
				AutoGrLog( " Environment........: " + GetEnvServer()  ) //" Environment........: "
				AutoGrLog( " StartPath..........: " + GetSrvProfString( "StartPath", "" ) ) //" StartPath..........: "
				AutoGrLog( " RootPath...........: " + GetSrvProfString( "RootPath" , "" ) ) //" RootPath...........: "
				AutoGrLog( " Versão.............: " + GetVersao(.T.) ) //" Versão.............: "
				AutoGrLog( " Usuário TOTVS .....: " + __cUserId + " " +  cUserName ) //" Usuário TOTVS .....: "
				AutoGrLog( " Computer Name......: " + GetComputerName() ) //" Computer Name......: "

				aInfo   := GetUserInfo()
				If ( nPos    := aScan( aInfo,{ |x,y| x[3] == ThreadId() } ) ) > 0
					AutoGrLog( " " )
					AutoGrLog( " Dados Thread" ) //" Dados Thread"
					AutoGrLog( " --------------------" )
					AutoGrLog( " Usuário da Rede....: " + aInfo[nPos][1] ) //" Usuário da Rede....: "
					AutoGrLog( " Estação............: " + aInfo[nPos][2] ) //" Estação............: "
					AutoGrLog( " Programa Inicial...: " + aInfo[nPos][5] ) //" Programa Inicial...: "
					AutoGrLog( " Environment........: " + aInfo[nPos][6] ) //" Environment........: "
					AutoGrLog( " Conexão............: " + AllTrim( StrTran( StrTran( aInfo[nPos][7], Chr( 13 ), "" ), Chr( 10 ), "" ) ) ) //" Conexão............: "
				EndIf
				AutoGrLog( Replicate( "-", 124 ) )
				AutoGrLog( " " )

				If !lAuto
					AutoGrLog( Replicate( "-", 124 ) )
					AutoGrLog( "Empresa : " + SM0->M0_CODIGO + "/" + SM0->M0_NOME + CRLF ) //"Empresa : "
				EndIf

				oProcess:SetRegua1( 8 )

				//Para SX6 para ser compartilhado a Filial, por enquanto
				if SM0->M0_SIZEFIL == 2 
					cFilSm := "  "  //Compartilhado Direto
				Else
					nFilLay := AT( SM0->M0_LEIAUTE, "F" )-1
					If nFilSm == 1  //Compartilhado
			 			cFilSm := Space( SM0->M0_SIZEFIL )
					Else
			 			cFilSm := Substr( Substr(SM0->M0_CODFIL,1,nFilLay) + Space( SM0->M0_SIZEFIL ), 1, SM0->M0_SIZEFIL )
					EndIF
				EndIf			

				//³Atualiza Folders                  ³
				oProcess:IncRegua1( "Folders" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
				IFAtuSXA(oProcess)


				//³Atualiza Pergiuntas³
				oProcess:IncRegua1( "Perguntas de Relatorios" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
				IFAtuSX1()


				//------------------------------------
				// Atualiza o dicionário SX2
				//------------------------------------
				oProcess:IncRegua1( "Dicionário de arquivos" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." ) //"Dicionário de arquivos"
				FSAtuSX2()


				//------------------------------------
				// Atualiza o dicionário SIX
				//------------------------------------
				oProcess:IncRegua1( "Dicionário de índices" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
				IFAtuSIX()

				//------------------------------------
				// Atualiza o dicionário SX3
				//------------------------------------
				oProcess:IncRegua1( "Dicionário de campos" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
				FSAtuSX3()

				//------------------------------------
				// Atualiza o parametros SX6
				//------------------------------------
				oProcess:IncRegua1( "Parâmetros" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
				IFAtuSX6()


				//------------------------------------
				// Atualiza o dicionário SX7
				//------------------------------------
				oProcess:IncRegua1( "Dicionário de gatilhos" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
				IFAtuSX7()

				//------------------------------------
				// Atualiza o dicionário SXB
				//------------------------------------
				oProcess:IncRegua1( "Dicionário de Consulta Padrão" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
				IFAtuSXB()


				oProcess:IncRegua1( "Dicionário de dados" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." ) //"Dicionário de dados"
				oProcess:IncRegua2( "Atualizando campos/índices" ) //"Atualizando campos/índices"

				// Alteração física dos arquivos
				__SetX31Mode( .F. )

				If FindFunction(cTCBuild)
					cTopBuild := &cTCBuild.()
				EndIf

				//FR - 30/03/2022 - Alteração - Ajuste para simular o erro reportado "alias não existe"		
				aSort(aArqUpd)
				//FR - 30/03/2022 - Alteração - Ajuste para simular o erro reportado "alias não existe"
				For nX := 1 To Len( aArqUpd )

					If cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
						If ( ( aArqUpd[nX] >= "NQ " .AND. aArqUpd[nX] <= "NZZ" ) .OR. ( aArqUpd[nX] >= "O0 " .AND. aArqUpd[nX] <= "NZZ" ) ) .AND.;
							!aArqUpd[nX] $ "NQD,NQF,NQP,NQT"
							TcInternal( 25, "CLOB" )
						EndIf
					EndIf

					If Select( aArqUpd[nX] ) > 0
						if !Empty( aArqUpd[nX] )
							(aArqUpd[nX])->(DbCloseArea())
						endif
					EndIf

					X31UpdTable( aArqUpd[nX] )

					If __GetX31Error()
						Alert( __GetX31Trace() )
						MsgStop( "Ocorreu um erro desconhecido durante a atualização da tabela : " + aArqUpd[nX] + ". Verifique a integridade do dicionário e da tabela.", "ATENÇÃO" ) //"Ocorreu um erro desconhecido durante a atualização da tabela : "###". Verifique a integridade do dicionário e da tabela."###"ATENÇÃO"
						AutoGrLog( "Ocorreu um erro desconhecido durante a atualização da estrutura da tabela : " + aArqUpd[nX] ) //"Ocorreu um erro desconhecido durante a atualização da estrutura da tabela : "
					EndIf

					If cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
						TcInternal( 25, "OFF" )
					EndIf

				Next nX

				//------------------------------------
				// Atualiza o dicionário SX6
				//------------------------------------
				//oProcess:IncRegua1( STR0024 + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." ) //"Dicionário de parâmetros"
				//FSAtuSX6()

				If !lAltera
					AutoGrLog( "Não foram localizados dados pendentes de atualização!"+CHR(13)+CHR(10)) 
				EndIf

				AutoGrLog( Replicate( "-", 124 ) )
				AutoGrLog( STR0050 + DtoC( Date() ) + " / " + Time() ) 
				AutoGrLog( Replicate( "-", 124 ) )

				RpcClearEnv()

			Next nI

			If !lAuto

				cTexto := LeLog()
	
				Define Font oFont Name "Mono AS" Size 5, 12
	
				Define MsDialog oDlg Title "Atualização concluida." From 3, 0 to 340, 417 Pixel 
	
				@ 5, 5 Get oMemo Var cTexto Memo Size 200, 145 Of oDlg Pixel
				oMemo:bRClicked := { || AllwaysTrue() }
				oMemo:oFont     := oFont
	
				Define SButton From 153, 175 Type  1 Action oDlg:End() Enable Of oDlg Pixel // Apaga
				Define SButton From 153, 145 Type 13 Action ( cFile := cGetFile( cMask, "" ), If( cFile == "", .T., ;
				MemoWrite( cFile, cTexto ) ) ) Enable Of oDlg Pixel
	
				Activate MsDialog oDlg Center
	
			EndIf
	
		EndIf
	
	Else
	
		lRet := .F.
	
	EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³IFAtuSXA  ³ Autor ³Roberto Souza          ³ Data ³24/04/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de processamento da gravacao do SXA                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Atualizacao Importa XML                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function IFAtuSXA(oProcess)
	Local cTexto := ''
	Local aSXA   := {}
	Local aEstrut:= {}
	Local i      := 0
	Local j      := 0 
	Local lSXA   := .F.
	
	aEstrut:= {"XA_ALIAS","XA_ORDEM","XA_DESCRIC","XA_DESCSPA","XA_DESCENG","XA_PROPRI"}
	oProcess:IncRegua2('Atualizando Folders (SXA)' )
	
	AADD(aSXA,{xZBZ,"1","Xml","Xml","Xml","U"})
	AADD(aSXA,{xZBZ,"2","Cancelamento","Cancelamento","Cancelamento","U"})
	AADD(aSXA,{xZBZ,"3","Notificações","Notificações","Notificações","U"})
	
	dbSelectArea("SXA")
	dbSetOrder(1)
	For i:= 1 To Len(aSXA)
		If !Empty(aSXA[i][1])
			If !dbSeek(aSXA[i,1]+aSXA[i,2])
				RecLock("SXA",.T.)
				lSXA := .T.
				For j:=1 To Len(aSXA[i])
					If !Empty(FieldName(FieldPos(aEstrut[j])))
						FieldPut(FieldPos(aEstrut[j]),aSXA[i,j])
					EndIf
				Next j
	
				dbCommit()
				MsUnLock()
				
				
				AutoGrLog( aSXA[i,1] + ' - ' + aSXA[i,3]+CHR(13)+CHR(10) ) //"Foi incluída a tabela "
	
			EndIf
		EndIf
	Next i
	If lSXA
		lAltera := .T.
		AutoGrLog( "Folders atualizados  : "+"SXA"+CHR(13)+CHR(10) ) //"Foi incluída a tabela "
	EndIf

Return(cTexto)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³IFAtuSX1  ³ Autor ³Marcos Favaro          ³ Data ³04/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de processamento da gravacao dos SX1                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Atualizacao COM                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function IFAtuSX1()
	//				X1_GRUPO   X1_ORDEM   X1_PERGUNT X1_PERSPA X1_PERENG  X1_VARIAVL X1_TIPO    X1_TAMANHO X1_DECIMAL X1_PRESEL
	//				X1_GSC     X1_VALID   X1_VAR01   X1_DEF01  X1_DEFSPA1 X1_DEFENG1 X1_CNT01   X1_VAR02   X1_DEF02
	//				X1_DEFSPA2 X1_DEFENG2 X1_CNT02   X1_VAR03  X1_DEF03   X1_DEFSPA3 X1_DEFENG3 X1_CNT03   X1_VAR04   X1_DEF04
	// 				X1_DEFSPA4 X1_DEFENG4 X1_CNT04   X1_VAR05  X1_DEF05   X1_DEFSPA5 X1_DEFENG5 X1_CNT05   X1_F3      X1_GRPSXG X1_PYME
	//Local aSX1   	:= {}
	Local aEstrut	:= {}
	//Local nI      	:= 0
	//Local nJ      	:= 0
	Local lSX1	 	:= .F.
	Local cTexto 	:= ''
	Local aHelpPor	:=	{}
	Local aHelpEng	:=	{}
	Local aHelpSpa	:=	{}
	Local nTamSx1Grp:= Len(SX1->X1_GRUPO)
	
	aEstrut:= {	"X1_GRUPO"  ,"X1_ORDEM"  ,"X1_PERGUNT","X1_PERSPA","X1_PERENG" ,"X1_VARIAVL","X1_TIPO"   ,"X1_TAMANHO","X1_DECIMAL","X1_PRESEL",;
	"X1_GSC"    ,"X1_VALID"  ,"X1_VAR01"  ,"X1_DEF01" ,"X1_DEFSPA1","X1_DEFENG1","X1_CNT01"  ,"X1_VAR02"  ,"X1_DEF02"  ,;
	"X1_DEFSPA2","X1_DEFENG2","X1_CNT02"  ,"X1_VAR03" ,"X1_DEF03"  ,"X1_DEFSPA3","X1_DEFENG3","X1_CNT03"  ,"X1_VAR04"  ,"X1_DEF04",;
	"X1_DEFSPA4","X1_DEFENG4","X1_CNT04"  ,"X1_VAR05" ,"X1_DEF05"  ,"X1_DEFSPA5","X1_DEFENG5","X1_CNT05"  ,"X1_F3"     ,"X1_GRPSXG","X1_PYME"}
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tipo da Nota                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aHelpPor	:=	{}
	aHelpEng	:=	{}
	aHelpSpa	:=	{}
	Aadd( aHelpPor, "Informe o Tipo da Nota no XML           " )
	aHelpEng := aHelpSpa := aHelpPor
	
	u_zPutSX1(PadR("IMPXML",nTamSx1Grp), "01", "Informe Tipo da Nota do XML ?", "MV_PAR01", "MV_CH0", "N", 1, 0, "C", "", "", "", "N=Normal", "B=Beneficiament", "D=Devolucao", "", "", "Informe o Tipo da Nota no XML")
	
	u_zPutSX1(PadR("IMPXML",nTamSx1Grp), "02", "Cod. Prod. a Utilizar", "MV_PAR02", "MV_CH1", "N", 1, 0, "C", "", "", "", "N=Codigo Padrao", "B=Amarracao Padrao", "C=Amar. Customizada", "", "", "Cod. Prod. a Utilizar")
	
	//lSX1	:= .T.
	
	/*aAdd (aSx1, {PadR("IMPXML",nTamSx1Grp), "01", "Informe Tipo da Nota do XML ? ", "Informe Tipo da Nota do XML ? ", "Informe Tipo da Nota do XML ? ",;
	"mv_ch0", "N", 1, 0, 1,"C", "", "mv_par01", "N=Normal","","","","","B=Beneficiament","","",;
	"", "", "D=Devolucao", "",  "", "", "", "", "", "", "", "", "", "", "", "", "", "", "S" })
	PutSX1Help("1IMPXML",aHelpPor,aHelpEng,aHelpSpa)
	
	aAdd (aSx1, {PadR("IMPXML",nTamSx1Grp), "01", "Cod. Prod. a Utilizar", "Cod. Prod. a Utilizar", "Cod. Prod. a Utilizar",;
	"mv_ch1", "N", 1, 0, 1,"C", "", "mv_par02", "N=Codigo Padrao","","","","","B=Amarracao Padrao","","",;
	"", "", "C=Amar. Customizada", "",  "", "", "", "", "", "", "", "", "", "", "", "", "", "", "S" })
	PutSX1Help("2IMPXML",aHelpPor,aHelpEng,aHelpSpa)
	
	ProcRegua(Len(aSX1))
	
	dbSelectArea("SX1")                           
	dbSetOrder(1)
	For nI:= 1 To Len(aSX1)
		If !Empty(aSX1[nI][1])
			If !dbSeek(PADR(aSX1[nI,1],nTamSx1Grp)+aSX1[nI,2])
				lSX1	:= .T.
				RecLock("SX1",.T.)
				
				For nJ:=1 To Len(aSX1[nI])
					If !Empty(FieldName(FieldPos(aEstrut[nJ])))
						FieldPut(FieldPos(aEstrut[nJ]),aSX1[nI,nJ])
					EndIf
				Next nJ
				
				dbCommit()
				MsUnLock()
				IncProc("Atualizando Perguntas de Relatorios...")
			EndIf
		EndIf
	Next nI*/
	
	If lSX1
		lAltera := .T.
		AutoGrLog( "Incluidas/Alteradas novas perguntas no SX1."+CHR(13)+CHR(10) ) //"Foi incluída a tabela "
	//Else
	//	AutoGrLog( "Não houve alteração no cadastro de perguntas (SX1)."+CHR(13)+CHR(10) ) //"Não Houve Alteração "
	EndIf
	
Return cTexto


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX2
Função de processamento da gravação do SX2 - Arquivos
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX2()
	Local aEstrut   := {}
	Local aSX2      := {}
	Local cAlias    := ""
	Local cCpoUpd   := "X2_ROTINA /X2_UNICO  /X2_DISPLAY/X2_SYSOBJ /X2_USROBJ /X2_POSLGT /"
	Local cEmpr     := ""
	Local cPath     := ""
	Local nI        := 0
	Local nJ        := 0
	Local lSX2		:= .F.

	aEstrut := { "X2_CHAVE"  , "X2_PATH"   , "X2_ARQUIVO", "X2_NOME"   , "X2_NOMESPA", "X2_NOMEENG", "X2_MODO"   , ;
	             "X2_TTS"    , "X2_ROTINA" , "X2_PYME"   , "X2_UNICO"  , "X2_DISPLAY", "X2_SYSOBJ" , "X2_USROBJ" , ;
	             "X2_POSLGT" , "X2_MODOEMP", "X2_MODOUN" , "X2_MODULO" }

	dbSelectArea( "SX2" )
	SX2->( dbSetOrder( 1 ) )
	SX2->( dbGoTop() )
	cPath := SX2->X2_PATH
	cPath := IIf( Right( AllTrim( cPath ), 1 ) <> "\", PadR( AllTrim( cPath ) + "\", Len( cPath ) ), cPath )
	cEmpr := Substr( SX2->X2_ARQUIVO, 4 )

	//
	// Tabela ZB5
	//
	aAdd( aSX2, { ;
		xZB5																	, ; //X2_CHAVE
		cPath																	, ; //X2_PATH
		xZB5+cEmpr																, ; //X2_ARQUIVO
		"Amarração P.For. X P.Emp/Fil"											, ; //X2_NOME
		"Amarração P.For. X P.Emp/Fil"											, ; //X2_NOMESPA
		"Amarração P.For. X P.Emp/Fil"											, ; //X2_NOMEENG
		"E"																		, ; //X2_MODO
		""																		, ; //X2_TTS
		""																		, ; //X2_ROTINA
		""																		, ; //X2_PYME
		""																		, ; //X2_UNICO
		""																		, ; //X2_DISPLAY
		""																		, ; //X2_SYSOBJ
		""																		, ; //X2_USROBJ
		"2"																		, ; //X2_POSLGT
		"E"																		, ; //X2_MODOEMP
		"E"																		, ; //X2_MODOUN
		0																		} ) //X2_MODULO

	//AADD(aSX2,{xZBZ,"","","XML de Entrada Importado","XML de Entrada Importado","XML de Entrada Importado",0,"E","","",""})
	aAdd( aSX2, { ;
		xZBZ																	, ; //X2_CHAVE
		cPath																	, ; //X2_PATH
		xZBZ+cEmpr																, ; //X2_ARQUIVO
		"XML de Entrada Importado"												, ; //X2_NOME
		"XML de Entrada Importado"												, ; //X2_NOMESPA
		"XML de Entrada Importado"												, ; //X2_NOMEENG
		"E"																		, ; //X2_MODO
		""																		, ; //X2_TTS
		""																		, ; //X2_ROTINA
		""																		, ; //X2_PYME
		""																		, ; //X2_UNICO
		""																		, ; //X2_DISPLAY
		""																		, ; //X2_SYSOBJ
		""																		, ; //X2_USROBJ
		"2"																		, ; //X2_POSLGT
		"E"																		, ; //X2_MODOEMP
		"E"																		, ; //X2_MODOUN
		0																		} ) //X2_MODULO

	If lBOSSKEY
		//AADD(aSX2,{xZBX,"","","Uso de licencas","Uso de licencas","Uso de licencas",0,"E","","",""})
		aAdd( aSX2, { ;
			xZBX																	, ; //X2_CHAVE
			cPath																	, ; //X2_PATH
			xZBX+cEmpr																, ; //X2_ARQUIVO
			"Uso de licencas"														, ; //X2_NOME
			"Uso de licencas"														, ; //X2_NOMESPA
			"Uso de licencas"														, ; //X2_NOMEENG
			"E"																		, ; //X2_MODO
			""																		, ; //X2_TTS
			""																		, ; //X2_ROTINA
			""																		, ; //X2_PYME
			""																		, ; //X2_UNICO
			""																		, ; //X2_DISPLAY
			""																		, ; //X2_SYSOBJ
			""																		, ; //X2_USROBJ
			"2"																		, ; //X2_POSLGT
			"E"																		, ; //X2_MODOEMP
			"E"																		, ; //X2_MODOUN
			0																		} ) //X2_MODULO
	EndIf

		//AADD(aSX2,{xZBB,"","","Pedido Recorrente","Pedido Recorrente","Pedido Recorrente",0,"E","","",""})
	aAdd( aSX2, { ;
			xZBB																	, ; //X2_CHAVE
			cPath																	, ; //X2_PATH
			xZBB+cEmpr																, ; //X2_ARQUIVO
			"Pedido Recorrente"														, ; //X2_NOME
			"Pedido Recorrente"														, ; //X2_NOMESPA
			"Pedido Recorrente"														, ; //X2_NOMEENG
			"E"																		, ; //X2_MODO
			""																		, ; //X2_TTS
			""																		, ; //X2_ROTINA
			""																		, ; //X2_PYME
			""																		, ; //X2_UNICO
			""																		, ; //X2_DISPLAY
			""																		, ; //X2_SYSOBJ
			""																		, ; //X2_USROBJ
			"2"																		, ; //X2_POSLGT
			"E"																		, ; //X2_MODOEMP
			"E"																		, ; //X2_MODOUN
			0																		} ) //X2_MODULO

	//AADD(aSX2,{xZBS,"","","Sincronizacao com SEFAZ","Sincronizacao com SEFAZ","Sincronizacao com SEFAZ",0,"E","","",""})
	aAdd( aSX2, { ;
		xZBS																	, ; //X2_CHAVE
		cPath																	, ; //X2_PATH
		xZBS+cEmpr																, ; //X2_ARQUIVO
		"Sincronizacao com SEFAZ"												, ; //X2_NOME
		"Sincronizacao com SEFAZ"												, ; //X2_NOMESPA
		"Sincronizacao com SEFAZ"												, ; //X2_NOMEENG
		"E"																		, ; //X2_MODO
		""																		, ; //X2_TTS
		""																		, ; //X2_ROTINA
		""																		, ; //X2_PYME
		xZBS_+"CHAVE"															, ; //X2_UNICO
		""																		, ; //X2_DISPLAY
		""																		, ; //X2_SYSOBJ
		""																		, ; //X2_USROBJ
		"2"																		, ; //X2_POSLGT
		"E"																		, ; //X2_MODOEMP
		"E"																		, ; //X2_MODOUN
		0																		} ) //X2_MODULO

	//AADD(aSX2,{xZBA,"","","Usuário com Amarração Secundaria","Usuário com Amarração Secundaria","Usuário com Amarração Secundaria",0,"E","","",""})
	aAdd( aSX2, { ;
		xZBA																	, ; //X2_CHAVE
		cPath																	, ; //X2_PATH
		xZBA+cEmpr																, ; //X2_ARQUIVO
		"Usuário com Amarração Secundaria"										, ; //X2_NOME
		"Usuário com Amarração Secundaria"										, ; //X2_NOMESPA
		"Usuário com Amarração Secundaria"										, ; //X2_NOMEENG
		"E"																		, ; //X2_MODO
		""																		, ; //X2_TTS
		""																		, ; //X2_ROTINA
		""																		, ; //X2_PYME
		""																		, ; //X2_UNICO
		""																		, ; //X2_DISPLAY
		""																		, ; //X2_SYSOBJ
		""																		, ; //X2_USROBJ
		"2"																		, ; //X2_POSLGT
		"E"																		, ; //X2_MODOEMP
		"E"																		, ; //X2_MODOUN
		0																		} ) //X2_MODULO

	//AADD(aSX2,{xZBE,"","","Carta de Correção e Eventos","Carta de Correção e Eventos","Carta de Correção e Eventos",0,"E","","",""})
	aAdd( aSX2, { ;
		xZBE																	, ; //X2_CHAVE
		cPath																	, ; //X2_PATH
		xZBE+cEmpr																, ; //X2_ARQUIVO
		"Carta de Correção e Eventos"											, ; //X2_NOME
		"Carta de Correção e Eventos"											, ; //X2_NOMESPA
		"Carta de Correção e Eventos"											, ; //X2_NOMEENG
		"E"																		, ; //X2_MODO
		""																		, ; //X2_TTS
		""																		, ; //X2_ROTINA
		""																		, ; //X2_PYME
		""																		, ; //X2_UNICO
		""																		, ; //X2_DISPLAY
		""																		, ; //X2_SYSOBJ
		""																		, ; //X2_USROBJ
		"2"																		, ; //X2_POSLGT
		"E"																		, ; //X2_MODOEMP
		"E"																		, ; //X2_MODOUN
		0																		} ) //X2_MODULO

	aAdd( aSX2, { ;
		xZYX																	, ; //X2_CHAVE
		cPath																	, ; //X2_PATH
		xZYX+cEmpr																, ; //X2_ARQUIVO
		"Systax"																, ; //X2_NOME
		"Systax"																, ; //X2_NOMESPA
		"Systax"																, ; //X2_NOMEENG
		"E"																		, ; //X2_MODO
		""																		, ; //X2_TTS
		""																		, ; //X2_ROTINA
		""																		, ; //X2_PYME
		""																		, ; //X2_UNICO
		""																		, ; //X2_DISPLAY
		""																		, ; //X2_SYSOBJ
		""																		, ; //X2_USROBJ
		"2"																		, ; //X2_POSLGT
		"E"																		, ; //X2_MODOEMP
		"E"																		, ; //X2_MODOUN
		0																		} ) //X2_MODULO

	aAdd( aSX2, { ;
		xZBC																	, ; //X2_CHAVE
		cPath																	, ; //X2_PATH
		xZBC+cEmpr																, ; //X2_ARQUIVO
		"Amarração Classificação Automática"									, ; //X2_NOME
		"Amarração Classificação Automática"									, ; //X2_NOMESPA
		"Amarração Classificação Automática"									, ; //X2_NOMEENG
		"C"																		, ; //X2_MODO
		""																		, ; //X2_TTS
		""																		, ; //X2_ROTINA
		""																		, ; //X2_PYME
		""																		, ; //X2_UNICO
		""																		, ; //X2_DISPLAY
		""																		, ; //X2_SYSOBJ
		""																		, ; //X2_USROBJ
		"2"																		, ; //X2_POSLGT
		"C"																		, ; //X2_MODOEMP
		"C"																		, ; //X2_MODOUN
		0																		} ) //X2_MODULO


	aAdd( aSX2, { ;
		xZBI																	, ; //X2_CHAVE
		cPath																	, ; //X2_PATH
		xZBI+cEmpr																, ; //X2_ARQUIVO
		"Integração Externa"													, ; //X2_NOME
		"Integração Externa"													, ; //X2_NOMESPA
		"Integração Externa"													, ; //X2_NOMEENG
		"E"																		, ; //X2_MODO
		""																		, ; //X2_TTS
		""																		, ; //X2_ROTINA
		""																		, ; //X2_PYME
		""																		, ; //X2_UNICO
		""																		, ; //X2_DISPLAY
		""																		, ; //X2_SYSOBJ
		""																		, ; //X2_USROBJ
		"2"																		, ; //X2_POSLGT
		"E"																		, ; //X2_MODOEMP
		"E"																		, ; //X2_MODOUN
		0																		} ) //X2_MODULO


	aAdd( aSX2, { ;
		xZBO																	, ; //X2_CHAVE
		cPath																	, ; //X2_PATH
		xZBO+cEmpr																, ; //X2_ARQUIVO
		"Ocorrência de Integração Exterena"										, ; //X2_NOME
		"Ocorrência de Integração Exterena"										, ; //X2_NOMESPA
		"Ocorrência de Integração Exterena"										, ; //X2_NOMEENG
		"E"																		, ; //X2_MODO
		""																		, ; //X2_TTS
		""																		, ; //X2_ROTINA
		""																		, ; //X2_PYME
		""																		, ; //X2_UNICO
		""																		, ; //X2_DISPLAY
		""																		, ; //X2_SYSOBJ
		""																		, ; //X2_USROBJ
		"2"																		, ; //X2_POSLGT
		"E"																		, ; //X2_MODOEMP
		"E"																		, ; //X2_MODOUN
		0																		} ) //X2_MODULO

	aAdd( aSX2, { ;
		xZBT																	, ; //X2_CHAVE
		cPath																	, ; //X2_PATH
		xZBT+cEmpr																, ; //X2_ARQUIVO
		"Itens da NF"															, ; //X2_NOME
		"Itens da NF"									   						, ; //X2_NOMESPA
		"Itens da NF"									   						, ; //X2_NOMEENG
		"E"																		, ; //X2_MODO
		""																		, ; //X2_TTS
		""																		, ; //X2_ROTINA
		""																		, ; //X2_PYME
		""																		, ; //X2_UNICO
		""																		, ; //X2_DISPLAY
		""																		, ; //X2_SYSOBJ
		""																		, ; //X2_USROBJ
		"2"																		, ; //X2_POSLGT
		"E"																		, ; //X2_MODOEMP
		"E"																		, ; //X2_MODOUN
		0																		} ) //X2_MODULO
		
	aAdd( aSX2, { ;
		xZBM																	, ; //X2_CHAVE
		cPath																	, ; //X2_PATH
		xZBM+cEmpr																, ; //X2_ARQUIVO
		"Municipios API"															, ; //X2_NOME
		"Municipios API"									   						, ; //X2_NOMESPA
		"Municipios API"									   						, ; //X2_NOMEENG
		"E"																		, ; //X2_MODO
		""																		, ; //X2_TTS
		""																		, ; //X2_ROTINA
		""																		, ; //X2_PYME
		""																		, ; //X2_UNICO
		""																		, ; //X2_DISPLAY
		""																		, ; //X2_SYSOBJ
		""																		, ; //X2_USROBJ
		"2"																		, ; //X2_POSLGT
		"E"																		, ; //X2_MODOEMP
		"E"																		, ; //X2_MODOUN
		0																		} ) //X2_MODULO

	aAdd( aSX2, { ;
		xZBN																	, ; //X2_CHAVE
		cPath																	, ; //X2_PATH
		xZBN+cEmpr																, ; //X2_ARQUIVO
		"Leituras API"															, ; //X2_NOME
		"Leituras API"									   						, ; //X2_NOMESPA
		"Leituras API"									   						, ; //X2_NOMEENG
		"E"																		, ; //X2_MODO
		""																		, ; //X2_TTS
		""																		, ; //X2_ROTINA
		""																		, ; //X2_PYME
		""																		, ; //X2_UNICO
		""																		, ; //X2_DISPLAY
		""																		, ; //X2_SYSOBJ
		""																		, ; //X2_USROBJ
		"2"																		, ; //X2_POSLGT
		"E"																		, ; //X2_MODOEMP
		"E"																		, ; //X2_MODOUN
		0																		} ) //X2_MODULO

	aAdd( aSX2, { ;
		xZBD																	, ; //X2_CHAVE
		cPath																	, ; //X2_PATH
		xZBD+cEmpr																, ; //X2_ARQUIVO
		"Image Converter"														, ; //X2_NOME
		"Image Converter"								   						, ; //X2_NOMESPA
		"Image Converter"								   						, ; //X2_NOMEENG
		"E"																		, ; //X2_MODO
		""																		, ; //X2_TTS
		""																		, ; //X2_ROTINA
		""																		, ; //X2_PYME
		""																		, ; //X2_UNICO
		""																		, ; //X2_DISPLAY
		""																		, ; //X2_SYSOBJ
		""																		, ; //X2_USROBJ
		"2"																		, ; //X2_POSLGT
		"E"																		, ; //X2_MODOEMP
		"E"																		, ; //X2_MODOUN
		0																		} ) //X2_MODULO
	aAdd( aSX2, { ;
		xZBF																	, ; //X2_CHAVE
		cPath																	, ; //X2_PATH
		xZBF+cEmpr																, ; //X2_ARQUIVO
		"Controle Consumo"														, ; //X2_NOME
		"Controle Consumo"								   						, ; //X2_NOMESPA
		"Controle Consumo"								   						, ; //X2_NOMEENG
		"E"																		, ; //X2_MODO
		""																		, ; //X2_TTS
		""																		, ; //X2_ROTINA
		""																		, ; //X2_PYME
		""																		, ; //X2_UNICO
		""																		, ; //X2_DISPLAY
		""																		, ; //X2_SYSOBJ
		""																		, ; //X2_USROBJ
		"2"																		, ; //X2_POSLGT
		"E"																		, ; //X2_MODOEMP
		"E"																		, ; //X2_MODOUN
		0																		} ) //X2_MODULO  
		
		//FR - 17/02/2022 - Log Consulta Fornecedor
		aAdd( aSX2, { ;
		xZBG																	, ; //X2_CHAVE
		cPath																	, ; //X2_PATH
		xZBG+cEmpr																, ; //X2_ARQUIVO
		"Log Consulta Fornecedores"												, ; //X2_NOME
		"Log Consulta Fornecedores"						   						, ; //X2_NOMESPA
		"Log Consulta Fornecedores"						   						, ; //X2_NOMEENG
		"E"																		, ; //X2_MODO
		""																		, ; //X2_TTS
		""																		, ; //X2_ROTINA
		""																		, ; //X2_PYME
		""																		, ; //X2_UNICO
		""																		, ; //X2_DISPLAY
		""																		, ; //X2_SYSOBJ
		""																		, ; //X2_USROBJ
		"2"																		, ; //X2_POSLGT
		"E"																		, ; //X2_MODOEMP
		"E"																		, ; //X2_MODOUN
		0																		} ) //X2_MODULO

	aAdd( aSX2, { ;
		xZBH																	, ; //X2_CHAVE
		cPath																	, ; //X2_PATH
		xZBH+cEmpr																, ; //X2_ARQUIVO
		"Ocorrencias de XML"													, ; //X2_NOME
		"Ocorrencias de XML"									   						, ; //X2_NOMESPA
		"Ocorrencias de XML"									   						, ; //X2_NOMEENG
		"E"																		, ; //X2_MODO
		""																		, ; //X2_TTS
		""																		, ; //X2_ROTINA
		""																		, ; //X2_PYME
		""																		, ; //X2_UNICO
		""																		, ; //X2_DISPLAY
		""																		, ; //X2_SYSOBJ
		""																		, ; //X2_USROBJ
		"2"																		, ; //X2_POSLGT
		"E"																		, ; //X2_MODOEMP
		"E"																		, ; //X2_MODOUN
		0																		} ) //X2_MODULO


	//
	// Atualizando dicionário
	//
	oProcess:SetRegua2( Len( aSX2 ) )

	dbSelectArea( "SX2" )
	dbSetOrder( 1 )

	For nI := 1 To Len( aSX2 )

		oProcess:IncRegua2( STR0056 ) //"Atualizando Arquivos (SX2)..."

		If !SX2->( dbSeek( aSX2[nI][1] ) )   //FR - 12/11/2019 - Busca na SX2 para verificar se a tabela já existe

			If !( aSX2[nI][1] $ cAlias )
				If !lSX2
					lSX2	:= .T.
					AutoGrLog( STR0055 + " SX2" + CRLF ) //"Ínicio da Atualização"
				EndIf
				cAlias += aSX2[nI][1] + "/"
				AutoGrLog( STR0057 + aSX2[nI][1] ) //"Foi incluída a tabela "
			EndIf

			RecLock( "SX2", .T. )
			For nJ := 1 To Len( aSX2[nI] )
				If FieldPos( aEstrut[nJ] ) > 0
					If AllTrim( aEstrut[nJ] ) == "X2_ARQUIVO"
						FieldPut( FieldPos( aEstrut[nJ] ), SubStr( aSX2[nI][nJ], 1, 3 ) + cEmpAnt +  "0" )
					Else
						FieldPut( FieldPos( aEstrut[nJ] ), aSX2[nI][nJ] )
					EndIf
				EndIf
			Next nJ
			MsUnLock()

		Else       
			//FR - se já existe a tabela no SX2, compara o X2_UNICO da tabela já gravada com a que está tentando gravar
			If  !( StrTran( Upper( AllTrim( SX2->X2_UNICO ) ), " ", "" ) == StrTran( Upper( AllTrim( aSX2[nI][11]  ) ), " ", "" ) )  
				RecLock( "SX2", .F. )
				SX2->X2_UNICO := aSX2[nI][11]
				MsUnlock()

				If MSFILE( RetSqlName( aSX2[nI][1] ),RetSqlName( aSX2[nI][1] ) + "_UNQ"  )
					TcInternal( 60, RetSqlName( aSX2[nI][1] ) + "|" + RetSqlName( aSX2[nI][1] ) + "_UNQ" )
				EndIf

				If !lSX2
					lSX2	:= .T.
					AutoGrLog( STR0055 + " SX2" + CRLF ) //"Ínicio da Atualização"
				EndIf

				AutoGrLog( STR0058 + aSX2[nI][1] ) //"Foi alterada a chave única da tabela "
			EndIf

			RecLock( "SX2", .F. )
			For nJ := 1 To Len( aSX2[nI] )
				If FieldPos( aEstrut[nJ] ) > 0
					If PadR( aEstrut[nJ], 10 ) $ cCpoUpd
						FieldPut( FieldPos( aEstrut[nJ] ), aSX2[nI][nJ] )
					EndIf

				EndIf
			Next nJ
			MsUnLock()

		EndIf

	Next nI

	If lSX2
		lAltera := .T.
		AutoGrLog( CRLF + STR0060 + " SX2" + CRLF + Replicate( "-", 124 ) + CRLF ) //"Final da Atualização"
	//Else
	//	AutoGrLog( "Não houve alteração no cadastro de tabelas (SX2)" + CRLF + Replicate( "-", 124 ) + CRLF ) //"Não houve alteração "
	EndIf

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX3
Função de processamento da gravação do SX3 - Campos
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX3()
	Local aSX3   := {}
	Local aPHelpPor	:={}
	Local aPHelpEng	:={}
	Local aPHelpSpa	:={}
	Local i      := 0
	Local j      := 0
	Local fr     := 0
	Local lSX3	 := .F.
	//Local lIndexCC8 := .F.
	Local cTexto    := ""
	Local cAlias    := ""
	Local cCpo		:= ""
	Local cCpoAlter := ""    		//FR 10/03/2020 - guarda os campos que foram criados/alterados
	Local cAliaAlter:= ""			//FR 14/09/2020 - guarda os alias que foram criados/alterados
	Local cOrdem    := ""
	Local cfolder   := ""
	//Local cAux      := ""
	Local aAlterTb	:=	{} 
	Local nTamDoc   := TAMSX3("F3_NFISCAL")[1]
	Local nTamProd  := TAMSX3("B1_COD")[1]
	Local nTamPrif  := 20
	Local nTamPed   := TAMSX3("C7_NUM")[1]
	Local nTamIte   := TAMSX3("C7_ITEM")[1]
	Local nTamTes   := TAMSX3("D1_TES")[1]
	Local nTamCc    := TAMSX3("D1_CC")[1]
	Local nTamCod   := TAMSXG("001")[1]
	Local nTamLoja  := TAMSXG("002")[1]
	Local lTemZBB   := (.NOT. Empty( xZBB ) )
	Local nTamQtdZbb:= TAMSX3("C7_QUANT")[1]
	Local nDecQtdZbb:= TAMSX3("C7_QUANT")[2]
	Local nTamUniZbb:= TAMSX3("C7_PRECO")[1]
	Local nDecUniZbb:= TAMSX3("C7_PRECO")[2]
	Local nTamTotZbb:= TAMSX3("C7_TOTAL")[1]
	Local nDecTotZbb:= TAMSX3("C7_TOTAL")[2]
	Local nTamUM    := TAMSX3("B1_UM")[1]			//FR - 15/04/2021 - tamanho padrão de campo
	Local nTamNCM   := TAMSX3("B1_POSIPI")[1]		//FR - 15/04/2021 - tamanho padrão de campo
	//Local nTamPedZbt:= TAMSX3("C7_NUM")[1]		//FR 03/01/2020 - Tamanho padrão do campo ZBT_PEDIDO = C7_NUM
	Local cPict     := ""
	
	//Estrutura para gravacao dos itens no SX3
	Local aEstrut:= { 	"X3_ARQUIVO","X3_ORDEM"  ,"X3_CAMPO"  ,;
	"X3_TIPO"   ,"X3_TAMANHO","X3_DECIMAL",;
	"X3_TITULO" ,"X3_TITSPA" ,"X3_TITENG" ,;
	"X3_DESCRIC","X3_DESCSPA","X3_DESCENG",;
	"X3_PICTURE","X3_VALID"  ,"X3_USADO"  ,;
	"X3_RELACAO","X3_F3"     ,"X3_NIVEL"  ,;
	"X3_RESERV" ,"X3_CHECK"  ,"X3_TRIGGER",;
	"X3_PROPRI" ,"X3_BROWSE" ,"X3_VISUAL" ,;
	"X3_CONTEXT","X3_OBRIGAT","X3_VLDUSER",;
	"X3_CBOX"   ,"X3_CBOXSPA","X3_CBOXENG",;
	"X3_PICTVAR","X3_WHEN"   ,"X3_INIBRW" ,;
	"X3_GRPSXG" ,"X3_FOLDER" ,"X3_PYME"}
	
	Local nTamFil   := 0 
	nTamFil         := TAMSXG("033")[1]	   		//FR - 14/09/2020 - captura o tamanho da filial no grupo de campos SXG
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posicoes a serem consideradas na definicao dos campos³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// Titulo 		= 12 caracteres
	// Descricao 	= 25 caracteres
	// Help			= 40 caracteres por linha de help
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao de novos campos no SX3               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	cOrdem    := ""
	
	
	If lBossKey
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tabela ZBX - LIBERACOES DE USO               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AADD(aSX3,{xZBX,"",xZBX_+"FILIAL",;
		"C",nTamFil,0,; 		//"C",02,0,;		//FR - 14/09/2020
		"Filial","Filial","Filial",;
		"Filial do Sistema","Filial do Sistema","Filial do Sistema",;
		"@!","",X3_USADO_NAOUSADO,;
		"","",1,;
		"","","",;
		"","N","",;
		"","","",;
		"","","",;
		"","","033",;
		"",""})
		aPHelpPor := {"Filial do Sistema"}
		aPHelpEng := aPHelpPor
		aPHelpSpa := aPHelpPor
		PutHelp("P"+xZBX_+"FILIAL",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
		
		AADD(aSX3,{xZBX,"",xZBX_+"CODCLI",;
		"C",nTamCod,0,;
		"Cod. Cliente ","Cod. Cliente","Cod. Cliente",;
		"Codigo do Cliente","Codigo do Cliente","Codigo do Cliente",;
		"@!","",X3_USADO_EMUSO,;
		"","SA1ZB5",0,;
		"","","S",;
		"U","S","A",;
		"R","","vazio() .or. existcpo('SA1',M->"+xZBX_+"CODCLI,1)",;
		"","","",;
		"","","001",;
		"",""})
		
		aPHelpPor := {"Codigo do Cliente"}
		aPHelpEng := aPHelpPor
		aPHelpSpa := aPHelpPor
		PutHelp("P"+xZBX_+"CODCLI",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
		//------------------------------------------------------------//                                                         
		
		AADD(aSX3,{xZBX,"",xZBX_+"LOJCLI",;
		"C",nTamLoja,0,;
		"Loja Cliente ","Loja Cliente","Loja Cliente",;
		"Loja do Cliente","Loja do Cliente","Loja do Cliente",;
		"@!","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","002",;
		"",""})
		
		aPHelpPor := {"Loja do Cliente"}
		aPHelpEng := aPHelpPor
		aPHelpSpa := aPHelpPor
		PutHelp("P"+xZBX_+"LOJCLI",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
		//------------------------------------------------------------//                                                         
		
		
		AADD(aSX3,{xZBX,"",xZBX_+"CNPJ",;
		"C",14,0,;
		"CNPJ/CPF","CNPJ/CPF","CNPJ/CPF",;
		"CNPJ/CPF do Cliente","CNPJ/CPF do Cliente","CNPJ/CPF do Cliente",;
		"@R 99.999.999/9999-99","Vazio().Or. Cgc(M->A1_CGC)",X3_USADO_EMUSO,;
		"","",0,;
		"","","",;
		"U","S","A",;
		"R","","(cgc(M->A1_CGC) .and. existchav('SA1',M->A1_CGC,3,'A1_CGC') .and. naovazio() .AND. VldCgcCpf(M->A1_Tipo,M->A1_Cgc))",;
		"","","",;
		"",".F.","",;
		"",""})
		
		aPHelpPor := {"CNPJ do Cliente"}
		aPHelpEng := aPHelpPor
		aPHelpSpa := aPHelpPor
		PutHelp("P"+xZBX_+"CNPJ",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
		//------------------------------------------------------------//                                                         
	
		AADD(aSX3,{xZBX,"",xZBX_+"CNPJ_L",;
		"C",14,0,;
		"CNPJ Liberado","CNPJ Liberado","CNPJ Liberado",;
		"CNPJ Liberado","CNPJ Liberado","CNPJ Liberado",;
		"@R 99.999.999/9999-99","NaoVazio().Or. Cgc(M->ZBX_CNPJ_L)",X3_USADO_EMUSO,;
		"","",0,;
		"","","",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"",".F.","",;
		"",""})
		
		aPHelpPor := {"CNPJ do Cliente"}
		aPHelpEng := aPHelpPor
		aPHelpSpa := aPHelpPor
		PutHelp("P"+xZBX_+"CNPJL",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
		//------------------------------------------------------------//                                                         
	
		AADD(aSX3,{xZBX,"",xZBX_+"RAZAO",;
		"C",40,0,;
		"Nome","Nome","Nome",;
		"Razao Social Cliente.","Razao Social Cliente.","Razao Social Cliente.",;
		"@!","",X3_USADO_EMUSO,;
		"","",0,;
		"","","",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"",".F.","",;
		"",""})
		
		aPHelpPor := {"Razao Social do Cliente"}
		aPHelpEng := aPHelpPor
		aPHelpSpa := aPHelpPor
		PutHelp("P"+xZBX_+"RAZAO",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
		//------------------------------------------------------------// 
		
		                                                        
		AADD(aSX3,{xZBX,"",xZBX_+"DTLIB",;
		"D",08,0,;
		"Dt. Liberacao","Dt. Liberacao","Dt. Liberacao",;
		"Dt. Liberacao","Dt. Liberacao","Dt. Liberacao",;
		"@D","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
		
		aPHelpPor := {"Dt. Liberacao"}
		aPHelpEng := aPHelpPor
		aPHelpSpa := aPHelpPor
		PutHelp("P"+xZBX_+"DTLIB",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
		//------------------------------------------------------------//                                                         	
	
		AADD(aSX3,{xZBX,"",xZBX_+"DTVLD",;
		"D",08,0,;
		"Validade","Validade","Validade",;
		"Validade","Validade","Validade",;
		"@D","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
		
		aPHelpPor := {"Validade"}
		aPHelpEng := aPHelpPor
		aPHelpSpa := aPHelpPor
		PutHelp("P"+xZBX_+"DTVLD",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
		//------------------------------------------------------------//                                                         		     
	
	EndIf
	
	
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tabela ZB5 - Amarração                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AADD(aSX3,{xZB5,"",xZB5_+"FILIAL",;
	"C",nTamFil,0,; 		//"C",02,0,; //FR - 14/09/2020
	"Filial","Filial","Filial",;
	"Filial do Sistema","Filial do Sistema","Filial do Sistema",;
	"@!","",X3_USADO_NAOUSADO,;
	"","",1,;
	"","","",;
	"","N","",;
	"","","",;
	"","","",;
	"","","033",;
	"",""})
	aPHelpPor := {"Filial do Sistema"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZB5_+"FILIAL",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZB5,"",xZB5_+"FORNEC",;
	"C",nTamCod,0,;
	"Cod. Fornec.","Cod. Fornec.","Cod. Fornec.",;
	"Codigo do Fornecedor","Codigo do Fornecedor","Codigo do Fornecedor",;
	"@!","",X3_USADO_EMUSO,;
	"","SA2ZB5",0,;
	"","","S",;
	"U","S","A",;
	"R","","vazio() .or. existcpo('SA2',M->"+xZB5_+"FORNEC,1)",;
	"","","",;
	"","","001",;
	"",""})
	
	aPHelpPor := {"Codigo do Fornecedor"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZB5_+"FORNEC",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                         
	
	
	AADD(aSX3,{xZB5,"",xZB5_+"LOJFOR",;
	"C",nTamLoja,0,;
	"Loja Fornec.","Loja Fornec.","Loja Fornec.",;
	"Loja do Fornecedor","Loja do Fornecedor","Loja do Fornecedor",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","A",;
	"R","","",;
	"","","",;
	"","","002",;
	"",""})
	
	aPHelpPor := {"Loja do Fornecedor"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZB5_+"LOJFO",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         	                 
	
	
	AADD(aSX3,{xZB5,"",xZB5_+"CGC",;
	"C",14,0,;
	"CNPJ/CPF","CNPJ/CPF","CNPJ/CPF",;
	"CNPJ/CPF do Fornec.","CNPJ/CPF do Fornec.","CNPJ/CPF do Fornec.",;
	"@R 99.999.999/9999-99","Vazio().Or.(Cgc(M->A2_CGC).And.A020CGC(M->A2_TIPO,M->A2_CGC))",X3_USADO_EMUSO,;
	"","",0,;
	"","","",;
	"U","S","A",;
	"R","","(cgc(M->A2_CGC) .and. existchav('SA2',M->A2_CGC,3,'A2_CGC') .and. naovazio() .AND. VldCgcCpf(M->A2_Tipo,M->A2_Cgc))",;
	"","","",;
	"",".F.","",;
	"",""})
	
	aPHelpPor := {"CGC do Fornecedor"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZB5_+"CGC",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZB5,"",xZB5_+"NOME",;
	"C",40,0,;
	"Razao Social","Razao Social","Razao Social",;
	"Razao Social Fornec.","Razao Social Fornec.","Razao Social Fornec.",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","",;
	"U","S","A",;
	"R","","",;
	"","","",;
	"",".F.","",;
	"",""})
	
	aPHelpPor := {"Razao Social do Fornecedor"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZB5_+"NOME",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                         
	
	
	AADD(aSX3,{xZB5,"",xZB5_+"CLIENT",;
	"C",nTamCod,0,;
	"Cod. Cliente ","Cod. Cliente","Cod. Cliente",;
	"Codigo do Cliente","Codigo do Cliente","Codigo do Cliente",;
	"@!","",X3_USADO_EMUSO,;
	"","SA1ZB5",0,;
	"","","S",;
	"U","S","A",;
	"R","","vazio() .or. existcpo('SA1',M->"+xZB5_+"CLIENT,1)",;
	"","","",;
	"","","001",;
	"",""})
	
	aPHelpPor := {"Codigo do Cliente"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZB5_+"CLIENTE",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                         
	                                                         
	
	AADD(aSX3,{xZB5,"",xZB5_+"LOJCLI",;
	"C",nTamLoja,0,;
	"Loja Cliente ","Loja Cliente","Loja Cliente",;
	"Loja do Cliente","Loja do Cliente","Loja do Cliente",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","A",;
	"R","","",;
	"","","",;
	"","","002",;
	"",""})
	
	aPHelpPor := {"Loja do Cliente"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZB5_+"LOJCLI",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         	
	
	
	AADD(aSX3,{xZB5,"",xZB5_+"CGCC",;
	"C",14,0,;
	"CNPJ/CPF","CNPJ/CPF","CNPJ/CPF",;
	"CNPJ/CPF do Cliente","CNPJ/CPF do Cliente","CNPJ/CPF do Cliente",;
	"@R 99.999.999/9999-99","Vazio().Or. Cgc(M->A1_CGC)",X3_USADO_EMUSO,;
	"","",0,;
	"","","",;
	"U","S","A",;
	"R","","(cgc(M->A1_CGC) .and. existchav('SA1',M->A1_CGC,3,'A1_CGC') .and. naovazio() .AND. VldCgcCpf(M->A1_Tipo,M->A1_Cgc))",;
	"","","",;
	"",".F.","",;
	"",""})
	
	aPHelpPor := {"CNPJ do Cliente"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZB5_+"CGCC",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         
	
	
	AADD(aSX3,{xZB5,"",xZB5_+"NOMEC",;
	"C",40,0,;
	"R. Social Clie.","R. Social Clie.","R. Social Clie.",;
	"Razao Social Cliente.","Razao Social Cliente.","Razao Social Cliente.",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","",;
	"U","S","A",;
	"R","","",;
	"","","",;
	"",".F.","",;
	"",""})
	
	aPHelpPor := {"Razao Social do Cliente"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZB5_+"NOMEC",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZB5,"",xZB5_+"PRODFO",;
	"C",nTamPrif,0,;							//"C",nTamProd,0,; //FR - 13/04/2021 - Alinhar o tamanho do código produto fornecedor com a SA5 - A5_CODPRF
	"Prod. do For","Prod. do For","Prod. do For",;
	"Cod. Produto do Fornecedor","Cod. Produto do Fornecedor","Cod. Produto do Fornecedor",;
	"","",X3_USADO_EMUSO,;
	"","",0,;
	"","","",;
	"U","S","A",;
	"R","","ExistChav('"+xZB5+"',M->"+xZB5_+"CGC+M->"+xZB5_+"PRODFO,1,'"+xZB5_+"CGC+"+xZB5_+"PRODFO')",;
	"","","",;
	"","","",;
	"",""})
	aPHelpPor := {"Codigo o Produto do Fornecedor"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZB5_+"PRODFO",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                         
	
	//nTamProd
	AADD(aSX3,{xZB5,"",xZB5_+"PRODFI",;
	"C",nTamPrif,0,;
	"Codigo Amarr","Codigo Amarr","Codigo Amarr",;
	"Nosso Codigo de Produto","Nosso Codigo de Produto","Nosso Codigo de Produto",;
	"","",X3_USADO_EMUSO,;
	"","SB1ZB5",0,;
	"","","S",;
	"U","S","A",;
	"R","","existcpo('SB1',M->"+xZB5_+"PRODFI,1)",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"Nosso Codigo de Produto"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZB5_+"PRODFI",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZB5,"",xZB5_+"DESCPR",;
	"C",40,0,;
	"Descricao","Descricao","Descricao",;
	"Descricao Nosso Produto","Descricao Nosso Produto","Descricao Nosso Produto",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","",;
	"U","S","A",;
	"R","","",;
	"","","",;
	"",".F.","",;
	"",""})
	
	aPHelpPor := {"Descricao Nosso Produto"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZB5_+"DESCPR",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         	                    
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tabela ZBZ - XML Fornecedores                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AADD(aSX3,{xZBZ,"01",xZBZ_+"FILIAL",;
	"C",nTamFil,0,;		//"C",02,0,;	//FR - 14/09/2020
	"Filial","Filial","Filial",;
	"Filial do Sistema","Filial do Sistema","Filial do Sistema",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","A",;
	"R","","",;
	"","","",;
	"","","033",;
	"",""})
	
	aPHelpPor := {"Filial do Sistema"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"FILIAL",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                          
	
	//NFCE_01
	AADD(aSX3,{xZBZ,"02",xZBZ_+"MODELO",;
	"C",02,0,;
	"Modelo","Modelo","Modelo",;
	"Modelo do XML","Modelo do XML","Modelo do XML",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","V",;
	"R","","",;
	"55=NF-e;RP=NFS-e Txt;57=CT-e;65=NFCe;67=CTeOS",;
	"55=NF-e;RP=NFS-e Txt;57=CT-e;65=NFCe;67=CTeOS",;
	"55=NF-e;RP=NFS-e Txt;57=CT-e;65=NFCe;67=CTeOS",;
	"","","",;
	"",""})
	
	aPHelpPor := {"Modelo do XML :" }
	Aadd(aPHelpPor,"55=NF-e"        )
	Aadd(aPHelpPor,"RP=NFS-e Txt"       )
	Aadd(aPHelpPor,"57=CT-e"        )
	Aadd(aPHelpPor,"65=NFC-e"       )
	Aadd(aPHelpPor,"67=CT-eOs"      )
	
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"MODELO",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)  
	//------------------------------------------------------------//                                                         
	
	
	//UF destinatário a Pedido da ISERO
	AADD(aSX3,{xZBZ,"03",xZBZ_+"UF",;
	"C",02,0,;
	"UF","UF","UF",;
	"UF Destinatario","UF Destinatario","UF Destinatario",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","V",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"UF Destinatario" }
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"UF",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//UF destinatário a Pedido da ISERO 
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZBZ,"04",xZBZ_+"SERIE",;
	"C",03,0,;
	"Serie NF","Serie NF","Serie NF",;
	"Serie da Nota","Serie da Nota","Serie da Nota",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","A",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"Serie da N. Fiscal do Fornecedor"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"SERIE",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                         
	
	
	AADD(aSX3,{xZBZ,"05",xZBZ_+"NOTA",;
	"C",nTamDoc,0,;
	"Doc Fiscal","Doc Fiscal","Doc Fiscal",;
	"Doc Fiscal","Doc Fiscal","Doc Fiscal",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","A",;
	"R","","",;
	"","","",;
	"","","018",;
	"",""})
	
	aPHelpPor := {"Numero do Documento Fiscal do Fornecedor"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"NOTA",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                          
	
	AADD(aSX3,{xZBZ,"06",xZBZ_+"DTNFE",;
	"D",08,0,;
	"Dt. da NFE","Dt. da NFE","Dt. da NFE",;
	"Data da NFE de Entrada","Data da NFE de Entrada","Data da NFE de Entrada",;
	"@D","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","V",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"Data da Nota Fiscal do Fornecedor"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"DTNFE",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                           
	
	AADD(aSX3,{xZBZ,"07",xZBZ_+"PROT",;
	"C",15,0,;
	"Protocolo","Protocolo","Protocolo",;
	"Protocolo de autorização","Protocolo de autorização","Protocolo de autorização",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","N","V",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"Protocolo de autorização do XML"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"PROT",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                         
	
	                                                       
	AADD(aSX3,{xZBZ,"08",xZBZ_+"PRENF",;
	"C",01,0,;
	"Flag Xml","Flag Xml","Flag Xml",;
	"Flag de importação do Xml","Flag de importação do Xml","Flag de importação do Xml",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","A",;
	"R","","",;
	"#u_zOpcoes()","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"Flag da Pre Nota Gerada na Entrada"}
	AADD(aPHelpPor,"B=XML Importado")
	AADD(aPHelpPor,"A=Aviso Recbto Carga")
	AADD(aPHelpPor,"S=Pré-Nota a Classificar")
	AADD(aPHelpPor,"N=Pré-Nota Classificada" )
	AADD(aPHelpPor,"F=Falha de Importação" )
	AADD(aPHelpPor,"X=Xml Cancelado Pelo Emissor" )
	
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"PRENF",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                         
	
	
	AADD(aSX3,{xZBZ,"09",xZBZ_+"CNPJ",;
	"C",14,0,;
	"CNPJ Emit.","CNPJ Emit.","CNPJ Emit.",;
	"CNPJ Fornec.","CNPJ Fornec.","CNPJ Fornec.",;
	"@X","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","A",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"CNPJ do Fornecedor"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"CNPJ",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZBZ,"10",xZBZ_+"FORNEC",;
	"C",60,0,;
	"R. Social","R. Social","R. Social",;
	"Razao Social","Razao Social","Razao Social",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","A",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"Razao Social do Fornecedor"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"FORNEC",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                          
	
	AADD(aSX3,{xZBZ,"11",xZBZ_+"CNPJD",;
	"C",14,0,;
	"CNPJ Dest.","CNPJ Dest.","CNPJ Dest.",;
	"CNPJ Destino","CNPJ Destino","CNPJ Destino",;
	"@X","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","A",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"CNPJ da Filial de Entrada"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"CNPJD",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)   
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZBZ,"12",xZBZ_+"CLIENT",;
	"C",60,0,;
	"Fil Destino","Fil Destino","Fil Destino",;
	"Fil Destino","Fil Destino","Fil Destino",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","A",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"Razao Social da Filial Destino"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"CLIENT",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                         
	
	                                                      
	AADD(aSX3,{xZBZ,"13",xZBZ_+"CHAVE",;                                    
	"C",60,0,;
	"Chave NFE","Chave NFE","Chave NFE",;
	"Chave da NFE","Chave da NFE","Chave da NFE",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","A",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"Chave da Nfe do Fornecedor"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"CHAVE",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                         
	
	
	AADD(aSX3,{xZBZ,"14",xZBZ_+"XML",;
	"M",10,0,;
	"XML  ","XML   ","XML  ",;
	"XML da NFE/CTE  ","XML da NFE/CTE  ","XML da NFE/CTE  ",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","V",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"XML Nfe/CTe do Fornecedor"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"XML",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//
	
	AADD(aSX3,{xZBZ,"15",xZBZ_+"ICOMPL",;
	"M",10,0,;
	"Info.Compl","Info.Compl","Info.Compl",;
	"Info.Compl","Info.Compl","Info.Compl",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","V",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"Informações Complementares"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"ICOMPL",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZBZ,"16",xZBZ_+"DTRECB",;
	"D",08,0,;
	"Dt. Rec. XML","Dt. Rec. XML","Dt. Rec. XML",;
	"Dt. do Recebimento do XML","Dt. do Recebimento do XML","Dt. do Recebimento do XML",;
	"@D","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","N","V",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"Data do Recebimento do XML"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"DTRECB",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         
	
	
	AADD(aSX3,{xZBZ,"17",xZBZ_+"DTHRCS",;
	"C",19,0,;
	"D/H Consulta","D/H consulta","D/H consulta",;
	"Data/Hora consulta","Data/Hora consulta","Data/Hora consulta",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","N","V",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"Data e hora da primeira consulta do XML","Formato AAAA-MM-DDTHH:MM:DD"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"DTHRCS",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZBZ,"18",xZBZ_+"DTHRUC",;
	"C",19,0,;
	"D/H Ult Cons","D/H Ult Cons","D/H Ult Cons",;
	"Data/Hora Ult consulta","Data/Hora Ult consulta","Data/Hora Ult consulta",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","N","V",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"Data e hora da ultima consulta do XML","Formato AAAA-MM-DDTHH:MM:DD"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"DTHRUC",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         
	    
	
	AADD(aSX3,{xZBZ,"19",xZBZ_+"CODFOR",;
	"C",nTamCod,0,;
	"Cod Forn","Cod Forn","Cod Forn",;
	"Cod Fornecedor","Cod Fornecedor","Cod Fornecedor",;
	"@X","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","A",;
	"R","","",;
	"","","",;
	"","","001",;
	"",""})
	
	aPHelpPor := {"Codigo do Fornecedor"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"CODFOR",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         	
	
	
	AADD(aSX3,{xZBZ,"20",xZBZ_+"LOJFOR",;
	"C",nTamLoja,0,;
	"Loja Forn","Loja Forn","Loja Forn",;
	"Loja Fornecedor","Loja Fornecedor","Loja Fornecedor",;
	"@X","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","A",;
	"R","","",;
	"","","",;
	"","","002",;
	"",""})
	
	aPHelpPor := {"Loja do Fornecedor"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"LOJFOR",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)  
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZBZ,"21",xZBZ_+"STATUS",;
	"C",1,0,;
	"Status","Status","Status",;
	"Status","Status","Status",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","A",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"Status do xml."+CRLF+;
					"1=OK"+CRLF+;
					"2=Erro"+CRLF+;
					"3=Aviso"}
	                                                                                                             
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"STATUS",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                         
	                                                         
	AADD(aSX3,{xZBZ,"22",xZBZ_+"OBS",;
	"M",10,0,;
	"Observacao","Observacao","Observacao",;
	"Observacao","Observacao","Observacao",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","A",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"Observaçoes e informaçoes sobre o XML."}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"OBS",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                         
	         
	AADD(aSX3,{xZBZ,"23",xZBZ_+"TPEMIS",;
	"C",1,0,;
	"Tp Emissao","Tp Emissao","Tp Emissao",;
	"Tp Emissao","Tp Emissao","Tp Emissao",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","A",;
	"R","","",;
	"1=Normal;2=Contingência FS;3=Contingência SCAN; 4=Contingência DPEC; 5=Contingência FS-DA",;
	"1=Normal;2=Contingência FS;3=Contingência SCAN; 4=Contingência DPEC; 5=Contingência FS-DA",;
	"1=Normal;2=Contingência FS;3=Contingência SCAN; 4=Contingência DPEC; 5=Contingência FS-DA",;
	"","","",;
	"",""})
	
	aPHelpPor := {"Tipo de Emissao."}
	Aadd(aPHelpPor,"1=Normal")
	Aadd(aPHelpPor,"2=Contingência FS")
	Aadd(aPHelpPor,"3=Contingência SCAN")
	Aadd(aPHelpPor,"4=Contingência DPEC")
	Aadd(aPHelpPor,"5=Contingência FS-DA")
	                                                                                                             
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"TPEMIS",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZBZ,"24",xZBZ_+"TPAMB",;
	"C",1,0,;
	"Ambiente","Ambiente","Ambiente",;
	"Ambiente","Ambiente","Ambiente",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","A",;
	"R","","",;
	"1=Produção;2=Homologação",;
	"1=Produção;2=Homologação",;
	"1=Produção;2=Homologação",;
	"","","",;
	"",""})
	
	aPHelpPor := {"Ambiente de emissão do xml."}
	Aadd(aPHelpPor,"1=Produção")
	Aadd(aPHelpPor,"2=Homologação")
	                                                                                                             
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"TPAMB",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                            
	
	 
	AADD(aSX3,{xZBZ,"25",xZBZ_+"TPDOC",;
	"C",01,0,;
	"Tipo Doc","Tipo Doc","Tipo Doc",;
	"Tipo do Documento","Tipo do Documento","Tipo do Documento",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","V",;
	"R","","",;
	"N=Normal;D=Devolucao;B=Beneficiamento;C=Complemento Preco/Frete;I=Comp. ICMS;P=Comp. IPI",;
	"N=Normal;D=Devolucao;B=Beneficiamento;C=Complemento Preco/Frete;I=Comp. ICMS;P=Comp. IPI",;
	"N=Normal;D=Devolucao;B=Beneficiamento;C=Complemento Preco/Frete;I=Comp. ICMS;P=Comp. IPI",;
	"","","",;
	"",""})
	  
	aPHelpPor := {"Tipo do Documento :"}
	Aadd(aPHelpPor,"N=Normal"        )
	Aadd(aPHelpPor,"D=Devolucao"        )
	Aadd(aPHelpPor,"B=Beneficiamento"        )
	Aadd(aPHelpPor,"C=Complemento Preco/Frete"        )
	Aadd(aPHelpPor,"I=Comp. ICMS"        )
	Aadd(aPHelpPor,"P=Comp. IPI"        )   	
	
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"TPDOC",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)  
	//------------------------------------------------------------//                                                         
	                             
	AADD(aSX3,{xZBZ,"26",xZBZ_+"FORPAG",;
	"C",01,0,;
	"Forma Pgto","Forma Pgto","Forma Pgto",;
	"Forma Pgto","Forma Pgto","Forma Pgto",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","V",;
	"R","","",;
	"0=Pago;1=A Pagar;2=Outros",;
	"0=Pago;1=A Pagar;2=Outros",;
	"0=Pago;1=A Pagar;2=Outros",;
	"","","",;
	"",""})
	  
	aPHelpPor := {"Forma de Pagamento :"}
	Aadd(aPHelpPor,"0=Pago"        )
	Aadd(aPHelpPor,"1=A Pagar"        )
	Aadd(aPHelpPor,"2=Outros"        )
	
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"FORPAG",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                         
	               
	AADD(aSX3,{xZBZ,"27",xZBZ_+"TOMA",;
	"C",02,0,;
	"Tomador CT-e","Tomador","Tomador",;
	" Indicador do papel do tomador do CT-e "," Indicador do papel do tomador do CT-e "," Indicador do papel do tomador do CT-e ",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","V",;
	"R","","",;
	"0-Remetente;1-Expedidor;2-Recebedor;3-Destinatário",;
	"0-Remetente;1-Expedidor;2-Recebedor;3-Destinatário",;
	"0-Remetente;1-Expedidor;2-Recebedor;3-Destinatário",;
	"","","",;
	"",""})
	 
	aPHelpPor := {"Indicador do papel do tomador do serviço no CT-e."}
	Aadd(aPHelpPor,"0-Remetente"        )
	Aadd(aPHelpPor,"1-Expedidor"        )
	Aadd(aPHelpPor,"2-Recebedor"        )
	Aadd(aPHelpPor,"3-Destinatário"     )
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"TOMA",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZBZ,"28",xZBZ_+"DTHCAN",;
	"C",19,0,;
	"D/H Ccancel","D/H Ccancel","D/H Ccancel",;
	"Data/Hora cancelamento","Data/Hora cancelamento","Data/Hora cancelamento",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","N","V",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"Data e hora do cancelamento do XML","Formato AAAA-MM-DDTHH:MM:DD"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"DTHCAN",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	
	AADD(aSX3,{xZBZ,"29",xZBZ_+"PROTC",;
	"C",15,0,;
	"Prot Canc","Prot Canc","Prot Canc",;
	"Protocolo de cancelamento","Protocolo de  cancelamento","Protocolo de  cancelamento",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","N","V",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"Protocolo de  cancelamento do XML"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"PROTC",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZBZ,"30",xZBZ_+"XMLCAN",;
	"M",10,0,;
	"XML Cancel","XML Cancel","XML Cancel",;
	"XML de cancelamento","XML de cancelamento","XML de cancelamento",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","V",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"XML de cancelamento"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"XMLCAN",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                         
	
	//em 25/03/2019
	AADD(aSX3,{xZBZ,"31",xZBZ_+"XMLRES",;
	"M",10,0,;
	"XML Resumo","XML Resumo","XML Resumo",;
	"XML Resumido NFE/CTE","XML Resumido NFE/CTE","XML Resumido NFE/CTE",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","V",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"XML Resumido NFE/CTE do Fornecedor"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"XMLRES",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                         
	
	//em 25/03/2019
	AADD(aSX3,{xZBZ,"32",xZBZ_+"TPDOWL",;
	"C",01,0,;
	"Tp XML Bx","Tp XML Bx","Tp XML Bx",;
	"Tipo XML Baixado","Tipo XML Baixado","Tipo XML Baixado",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","A",;
	"R","","",;
	" =Completo;R=Resumido;I=Indisponivel","","",;
	"","","",;
	"",""})
	aPHelpPor := {"Tipo Atual do XML Baixado"}
	Aadd(aPHelpPor," =Completo"         )
	Aadd(aPHelpPor,"R=Resumido"         )
	Aadd(aPHelpPor,"I=Indisponivel"     )	
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"TPDOWL",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                         
	
	
	AADD(aSX3,{xZBZ,"33",xZBZ_+"VERSAO",;
	"C",5,0,;
	"Versao XML","Versao XML","Versao XML",;
	"Versao do XML","Versao do XML","Versao do XML",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","V",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"Versao do XML"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"VERSA",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                           
	
	//Aguas 21-6-19
	AADD(aSX3,{xZBZ,"34",xZBZ_+"CFOP",;
	"C",15,0,;
	"CFOP","CFOP","CFOP",;
	"CFOP","CFOP","CFOP",;
	"@X","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","V",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"CFOP da NF"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"CFOP",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZBZ,"35",xZBZ_+"MAIL",;
	"C",1,0,;
	"E-mail","E-mail","E-mail",;
	"Status E-mail","Status E-mail","Status E-mail",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","A",;
	"R","","",;
	"0=Ok;1=Erro (Pendente);2=Erro (Enviado);3=Cancelamento (Pendente);4=Cancelamento (Enviado);X=Falha (Erro);Y=Falha (Cancelamento)",;
	"0=Ok;1=Erro (Pendente);2=Erro (Enviado);3=Cancelamento (Pendente);4=Cancelamento (Enviado);X=Falha (Erro);Y=Falha (Cancelamento)",;
	"0=Ok;1=Erro (Pendente);2=Erro (Enviado);3=Cancelamento (Pendente);4=Cancelamento (Enviado);X=Falha (Erro);Y=Falha (Cancelamento)",;
	"","","",;
	"",""})
	
	aPHelpPor := {"Status de Notificações por e-mail."}
	Aadd(aPHelpPor,"0-Xml Ok (Não envia)"     )
	Aadd(aPHelpPor,"1-Xml com erro (Pendente)"     )
	Aadd(aPHelpPor,"2-Xml com erro (Enviado)"     )
	Aadd(aPHelpPor,"3-Xml cancelado (Pendente)"     )
	Aadd(aPHelpPor,"4-Xml cancelado (Enviado)"     )
	Aadd(aPHelpPor,"X-Falha ao enviar o e-mail (Erro)"     )
	Aadd(aPHelpPor,"Y-Falha ao enviar o e-mail (Cancelamento) "     )
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"MAIL",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                          
	
	AADD(aSX3,{xZBZ,"36",xZBZ_+"DTMAIL",;
	"M",10,0,;
	"Msg E-mail","Msg E-mail","Msg E-mail",;
	"Mensagem do E-mail","Mensagem do E-mail","Mensagem do E-mail",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","V",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"Observação/Mensagens de erros"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"DTMAIL",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         
	
	
	AADD(aSX3,{xZBZ,"37",xZBZ_+"SERORI",;
	"C",03,0,;
	"Serie Ori","Serie Ori","Serie Ori",;
	"Serie Original da Nota","Serie da Nota","Serie Original da Nota",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","A",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"Serie Original (XML) da N. Fiscal do Fornecedor"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"SERORI",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)  
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZBZ,"38",xZBZ_+"EXP",;
	"C",01,0,;
	"Exportado ?","Exportado ?","Exportado ?",;
	"Exportado dados para banco oracle","Exportado dados para banco oracle","Exportado dados para banco oracle",;
	"@!","",X3_USADO_NAOUSADO,;
	"","",0,;
	"","","",;
	"U","S","A",;
	"R","","",;
	"S=Sim;N=Não","","",;
	"","","",;
	"",""})
	aPHelpPor := {"Exportado para banco oracle"}
	Aadd(aPHelpPor,"S=Sim"        )
	Aadd(aPHelpPor,"N=Não"        )
	
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"EXP",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         
	
	
	AADD(aSX3,{xZBZ,"39",xZBZ_+"MANIF",;
	"C",01,0,;
	"Manif ?","Manif ?","Manif ?",;
	"Manifestado ?","Manifestado ?","Manifestado ?",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","A",;
	"R","","",;
	"0=Não;1=Conf.Oper.;2=Oper.Desconh.;3=Oper.Não Realiz.;4=Ciência;5=MCTe;W=Pend.Conf.;X=Pend.Desc.;Y=Pend.N.Realiz;Z=Pend.Ciência","","",;
	"","","",;
	"",""})
	aPHelpPor := {"Manifestado ?"}
	Aadd(aPHelpPor,"0=Não Manifesta"          )
	Aadd(aPHelpPor,"1=Conf.Operação"          )
	Aadd(aPHelpPor,"2=Operação Desconhecida"  )
	Aadd(aPHelpPor,"3=Operação Não Realizada" )
	Aadd(aPHelpPor,"4=Ciência da Operação"    )
	Aadd(aPHelpPor,"5=Manifestação CTe"       )
	Aadd(aPHelpPor,"W=Pendente Conf.Operação"       )
	Aadd(aPHelpPor,"X=Pendente Oper.Desconhecida"   )
	Aadd(aPHelpPor,"Y=Pendente Oper.Não Realizada"  )
	Aadd(aPHelpPor,"Z=Pendente Ciência da Operação" )
	
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"MANIF",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//    
	//------------------------------------------------------------//                                                         
	
	//GETESB
	AADD(aSX3,{xZBZ,"40",xZBZ_+"CONDPG",;   
	"M",10,0,;
	"Cond. Pag.","Cond. Pag.","Cond. Pag.",;
	"Condição de Pagamento","Condição de Pagamento","Condição de Pagamento",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","A",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"Condição de Pagamento da NF-e"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"CONDPG",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                         
	
	/* Tipo CTE, campo obrigatorio - 26/12/2016 */
	AADD(aSX3,{xZBZ,"41",xZBZ_+"TPCTE",;
	"C",01,0,;
	"Tp CT-e","Tp CT-e","Tp CT-e",;
	"Tipo de CTE","Tipo de CTE","Tipo de CTE",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","V",;
	"R","","",;
	"N=Normal;C=Complem. Valores;A=Anula Valores;S=Substituto","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"Tipo de CT-e" }
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"TPCTE",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	/* Fim a inclusão */   
	//------------------------------------------------------------//                                                         
	
	
	AADD(aSX3,{xZBZ,"42",xZBZ_+"DOCCTE",;
	"C",nTamDoc,0,;
	"Doc Original CTE","Doc Original CTE","Doc Original CTE",;
	"Doc Original CTE","Doc Original CTE","Doc Original CTE",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","A",;
	"R","","",;
	"","","",;
	"","","018",;
	"",""})
	
	aPHelpPor := {"Numero do Documento Fiscal Original do Fornecedor"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"DOCCTE",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         
	
	//25/03/2019
	AADD(aSX3,{xZBZ,"43",xZBZ_+"DIRMCT",;
	"C",30,0,;
	"Pasta M.CTE","Pasta M.CTE","Pasta M.CTE",;
	"Pasta Multpl.CTE","Pasta Multpl.CTE","Pasta Multpl.CTE",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","A",;
	"R","","",;
	"","","",;
	"","","018",;
	"",""})
	
	aPHelpPor := {"Pasta Multiplo CTE"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"DIRMCT",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZBZ,"44",xZBZ_+"IMPORT",;
	"C",01,0,;
	"Import.De","Import.De","Import.De",;
	"Importado De","Importado De","Importado De",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","A",;
	"R","","",;
	"1=E-mail/Direto Pasta;2=Download Sefaz","","",;
	"","","",;
	"",""})
	aPHelpPor := {"Importado De"}
	Aadd(aPHelpPor,"1=E-mail/Direto Pasta" )
	Aadd(aPHelpPor,"2=Download Sefaz"  )
	
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"IMPORT",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)  
	//------------------------------------------------------------//                                                         
	
	
	AADD(aSX3,{xZBZ,"45",xZBZ_+"COMBUS",;
	"C",01,0,;
	"Clas.Auto","Clas.Auto","Clas.Auto",;
	"Clasifcação Automática (Combustível)","Clasifcação Automática (Combustível)","Clasifcação Automática (Combustível)",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","A",;
	"R","","",;
	"S=Sim","","",;
	"","","",;
	"",""})
	aPHelpPor := {"Clasifcação Automática (Combustível)?"}
	Aadd(aPHelpPor,"S=Sim" )
	
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"COMBUS",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZBZ,"46",xZBZ_+"INDRUR",;
	"C",01,0,;
	"Prod. Rural"," Prod. Rural "," Prod. Rural ",;
	"Produtor Rural","Produtor Rural ","Produtor Rural ",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","A",;
	"R","","",;
	" 0=Não é prod.rural;1=Seg.Espec.Geral PF;2=Seg.Espec.Ent.PAA PF;3=Entupa-a PJ "," 0=Não é prod.rural;1=Seg.Espec.Geral PF;2=Seg.Espec.Ent.PAA PF;3=entala PJ "," 0=Não é prod.rural;1=Seg.Espec.Geral PF;2=Seg.Espec.Ent.PAA PF;3=entupa-a PJ ",;
	"","","",;
	"",""})
	aPHelpPor := {" Produtor Rural "}
	Aadd(aPHelpPor,"0=Não é prod.rural " )
	Aadd(aPHelpPor,"1=Seg.Espec.Geral PF " )
	Aadd(aPHelpPor,"2=Seg.Espec.Ent.PAA PF " )
	Aadd(aPHelpPor,"3=Ent.PAA PJ " )
	
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"INDRUR",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         
	
	
	AADD(aSX3,{xZBZ,"47",xZBZ_+"SITGFE",;
	"C",01,0,;
	"GFE Situação","GFE Situação","GFE Situação",;
	"Situação do GFE","Situação do GFE","Situação do GFE",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","A",;
	"R","","",;
	" =Não se Aplica;1=Não Encontrado;2=Bloqueado;3=Aprovado;4=Aprovado",;
	"","","",;
	"",""})
	aPHelpPor := {"Situação do GFE"}
	Aadd(aPHelpPor," =Não se Aplica" )
	Aadd(aPHelpPor,"1=Não Encontrado" )
	Aadd(aPHelpPor,"2=Bloqueado" )
	Aadd(aPHelpPor,"3=Aprovado" )
	Aadd(aPHelpPor,"4=Aprovado" )
	
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"SITGFE",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                         
	
	
	AADD(aSX3,{xZBZ,"48",xZBZ_+"IDDES",;
	"C",01,0,;
	"Id Desac Cte","Id Desac Cte","Id Desac Cte",;
	"ID Desacordo CTe","ID Desacordo CTe","ID Desacordo CTe",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","A",;
	"R","","",;
	"1-Recebido;2-Assinado;3-Falha Schema;4-Transmitido;5-Problemas;6-Vinculado",;
	"","","",;
	"",""})
	aPHelpPor := {"ID Desacordo CTe"}
	Aadd(aPHelpPor,"1-Evento recebido" )
	Aadd(aPHelpPor,"2-Evento assinado" )
	Aadd(aPHelpPor,"3-Evento com falha no schema XML" )
	Aadd(aPHelpPor,"4-Evento transmitido" )
	Aadd(aPHelpPor,"5-Evento com problemas" )
	Aadd(aPHelpPor,"6-Evento vinculado" )
	
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"IDDES",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZBZ,"49",xZBZ_+"OBSDES",;   
	"M",10,0,;
	"OBS Desac.","OBS Desac.","OBS Desac.",;
	"OBS Desacordo","OBS Desacordo","OBS Desacordo",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","A",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"OBS Desacordo"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"OBSDES",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZBZ,"50",xZBZ_+"STMNCT",;
	"C",01,0,;
	"ST Desac Cte","ST Desac Cte","ST Desac Cte",;
	"Status Desacordo CTe","Status Desacordo CTe","Status Desacordo CTe",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","A",;
	"R","","",;
	"D=Aguardando retorno;E=Vinculado;F=Rejeição",;
	"","","",;
	"",""})
	aPHelpPor := {"Status Desacordo CTe"}
	Aadd(aPHelpPor,"D=Aguardando retorno SEFAZ evento desacordo" )
	Aadd(aPHelpPor,"E=Evento desacordo vinculado " )
	Aadd(aPHelpPor,"F=Evento desacordo rejeição" )
	
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"STMNCT",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                          
	
	//CAMPOS PARA NUVEM
	AADD(aSX3,{xZBZ,"51",xZBZ_+"VLLIQ",;
	"N",14,2,;
	"Valor Liq","Valor Liq","Valor Liq",;
	"Valor Liquido Produtos","Valor Liquido Produtos","Valor Liquido Produtos",;
	"@E 999,999,999.99","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","A",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"Valor Liquido dos Produtos"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"VLLIQ",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                         
	
	
	AADD(aSX3,{xZBZ,"52",xZBZ_+"VLIMP",;
	"N",14,2,;
	"Impostos","Impostos","Impostos",;
	"Valor dos Impostos","Valor dos Impostos","Valor dos Impostos",;
	"@E 999,999,999.99","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","A",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"Valor dos Impostos"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"VLIMP",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)  
	//------------------------------------------------------------//                                                         
	
	
	AADD(aSX3,{xZBZ,"53",xZBZ_+"VLDESC",;
	"N",14,2,;
	"Descontos","Descontos","Descontos",;
	"Valor dos Descontos","Valor dos Descontos","Valor dos Descontos",;
	"@E 999,999,999.99","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","A",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"Valor dos Descontos"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"VLDESC",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                         
	
	
	AADD(aSX3,{xZBZ,"54",xZBZ_+"VLBRUT",;
	"N",14,2,;
	"Valor NF","Valor NF","Valor NF",;
	"Valor Bruto da NF","Valor Bruto da NF","Valor Bruto da NF",;
	"@E 999,999,999.99","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","A",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"Valor Bruto da NF"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"VLBRUT",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                         
	
	
	AADD(aSX3,{xZBZ,"55",xZBZ_+"PDF",;
	"M",10,0,;
	"PDF  ","PDF   ","PDF  ",;
	"PDF da NFSE     ","PDF da NFSE     ","PDF da NFSE     ",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","V",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"PDF Nfse do Fornecedor"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"PDF",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         
	
	//em 21/06/2019
	AADD(aSX3,{xZBZ,"56",xZBZ_+"TPROT",;
	"C",01,0,;
	"Tp Rotina","Tp Rotina","Tp Rotina",;
	"Tipo da Rotina","Tipo da Rotina","Tipo da Rotina",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","A",;
	"R","","",;
	"J=JOB;M=Manual","","",;
	"","","",;
	"",""})
	aPHelpPor := {"Tipo da Rotina que Importou o XML."}
	Aadd(aPHelpPor,"J=JOB"          )
	Aadd(aPHelpPor,"M=Manual"          )
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"TPROT",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZBZ,"57",xZBZ_+"VCARGA",;
	"N",14,2,;
	"Vl Tot Carga","Vl Tot Carga","Vl Tot Carga",;
	"Valor Total Carga","Valor Total Carga","Valor Total Carga",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","A",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"Valor Total Carga"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"VCARGA",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//     
	
	//------------------------------------------------------------//     
	//INICIO IMPOSTOS ZBZ - 25/01/2020
	//------------------------------------------------------------//                                                          
	
	AADD(aSX3,{xZBZ,"58",xZBZ_+"BASCAL",;
	"N",14,2,;
	"Base Calc","Base Calc","Base Calc",;
	"Base Calculo Impostos ","Base Calculo Impostos ","Base Calculo Impostos ",;
	"@E 999,999,999.99","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","A",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	aPHelpPor := {"Base Calculo Impostos "}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"BASCAL",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 

	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZBZ,"59",xZBZ_+"ICMVAL",;
	"N",14,2,;
	"Valor ICMS","Valor ICMS","Valor ICMS",;
	"Valor do ICMS ","Valor do ICMS  ","Valor do ICMS  ",;
	"@E 999,999,999.99","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","A",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	aPHelpPor := {"Valor do ICMS  "}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"ICMVAL",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 

	//------------------------------------------------------------//                                                         

	AADD(aSX3,{xZBZ,"60",xZBZ_+"ICMDES",;
	"N",14,2,;
	"ICMS Desonera","ICMS Desonera","ICMS Desonera",;
	"ICMS Desoneracao","ICMS Desoneracao","ICMS Desoneracao",;
	"@E 999,999,999.99","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","A",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	aPHelpPor := {"ICMS Desoneracao"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"ICMDES",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 

	//------------------------------------------------------------//                                                         

	AADD(aSX3,{xZBZ,"61",xZBZ_+"STBASE",;
	"N",14,2,;
	"Base ST      ","Base ST      ","Base ST      ",;
	"Base ST      ","Base ST      ","Base ST      ",;
	"@E 999,999,999.99","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","A",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	aPHelpPor := {"Base ST      "}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"STBASE",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 

	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZBZ,"62",xZBZ_+"STVALO",;
	"N",14,2,;
	"Valor ST     ","Valor ST     ","Valor ST     ",;
	"Valor ST     ","Valor ST     ","Valor ST     ",;
	"@E 999,999,999.99","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","A",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	aPHelpPor := {"Valor ST     "}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"STVALO",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 

	//------------------------------------------------------------//                                                         

	AADD(aSX3,{xZBZ,"63",xZBZ_+"IPIVAL",;
	"N",14,2,;
	"Valor IPI    ","Valor IPI    ","Valor IPI    ",;
	"Valor IPI    ","Valor IPI    ","Valor IPI    ",;
	"@E 999,999,999.99","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","A",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	aPHelpPor := {"Valor IPI    "}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"IPIVAL",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 

	//------------------------------------------------------------//                                                         

	AADD(aSX3,{xZBZ,"64",xZBZ_+"IPIDEV",;
	"N",14,2,;
	"V.IPI Devoluc","V.IPI Devoluc","V.IPI Devoluc",;
	"V.IPI Devoluc","V.IPI Devoluc","V.IPI Devoluc",;
	"@E 999,999,999.99","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","A",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	aPHelpPor := {"V.IPI Devoluc"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"IPIDEV",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 

	//------------------------------------------------------------//                                                         

	AADD(aSX3,{xZBZ,"65",xZBZ_+"PISVAL",;
	"N",14,2,;
	"Valor Do PIS ","Valor Do PIS ","Valor Do PIS ",;
	"Valor Do PIS ","Valor Do PIS ","Valor Do PIS ",;
	"@E 999,999,999.99","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","A",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	aPHelpPor := {"Valor Do PIS "}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"PISVAL",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 

	//------------------------------------------------------------//                                                         

	AADD(aSX3,{xZBZ,"66",xZBZ_+"COFVAL",;
	"N",14,2,;
	"Valor COFINS ","Valor COFINS ","Valor COFINS ",;
	"Valor COFINS ","Valor COFINS ","Valor COFINS ",;
	"@E 999,999,999.99","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","A",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	aPHelpPor := {"Valor COFINS "}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"COFVAL",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 

	//------------------------------------------------------------//                                                         

	AADD(aSX3,{xZBZ,"67",xZBZ_+"OUTVAL",;
	"N",14,2,;
	"Valor OUTROS ","Valor OUTROS ","Valor OUTROS ",;
	"Valor OUTROS ","Valor OUTROS ","Valor OUTROS ",;
	"@E 999,999,999.99","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","A",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	aPHelpPor := {"Valor OUTROS "}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"OUTVAL",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 

	//------------------------------------------------------------//                                                          
	
	AADD(aSX3,{xZBZ,"68",xZBZ_+"DTFIS",;
	"D",08,0,;
	"Dt.Intg FIS","Dt.Intg FIS","Dt.Intg FIS",;
	"Data da Integr. FISCAL","Data da Integr. FISCAL","Data da Integr. FISCAL",;
	"@D","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","V",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"Data da Integracao FISCAL"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"DTFIS",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	
	//------------------------------------------------------------//                                                          
	
	AADD(aSX3,{xZBZ,"69",xZBZ_+"ORIPRT",;     						//FR 04/06/2020 - novo campo para CCM - origem da prestação de serviço (irá armazenar Município - UF)
	"C",40,0,;
	"Orig.Pr.Srv","Orig.Pr.Srv","Orig.Pr.Srv",;
	"Origem Prest. Serviço ","Origem Prest. Serviço ","Origem Prest. Serviço ",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","V",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"Origem da Prestação Serv."}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"ORIPRT",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//
	
	AADD(aSX3,{xZBZ,"70",xZBZ_+"DREDOW",;							  //FR - 16/10/2020
	"D",08,0,;
	"Dt.Redownload","Dt.Redownload","Dt.Redownload",;
	"Dt.Redownload","Dt.Redownload","Dt.Redownload",;
	"@D","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","V",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"Data do Último Redownload"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"DREDOW",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//
	
	AADD(aSX3,{xZBZ,"71",xZBZ_+"HREDOW",;							  //FR - 16/10/2020
	"C",05,0,;
	"Hr.Redownload","Hr.Redownload","Hr.Redownload",;
	"Hr.Redownload","Hr.Redownload","Hr.Redownload",;
	"99:99","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","V",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"Hora do Último Redownload"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"HREDOW",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//  

	AADD(aSX3,{xZBZ,"72",xZBZ_+"CNPJT",;
	"C",14,0,;
	"CNPJ Tomador","CNPJ Tomador","CNPJ Tomador",;
	"CNPJ Tomador","CNPJ Tomador","CNPJ Tomador",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","V",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"CNPJ do Tomador"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"CNPJT",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)   
	//------------------------------------------------------------//  
	
	AADD(aSX3,{xZBZ,"73",xZBZ_+"CODOCO",;
	"C",3,0,;
	"Cod Ocorrencia","Cod Ocorrencia","Cod Ocorrencia",;
	"Cod Ocorrencia","Cod Ocorrencia","Cod Ocorrencia",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","V",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"Cod Ocorrencia"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"CODOCO",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//  
	
	AADD(aSX3,{xZBZ,"74",xZBZ_+"DESOCO",;
	"C",254,0,;
	"Desc Ocorrencia","Desc Ocorrencia","Desc Ocorrencia",;
	"Desc Ocorrencia","Desc Ocorrencia","Desc Ocorrencia",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","V",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"Desc Ocorrencia"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"DESOCO",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//  
	
	AADD(aSX3,{xZBZ,"75",xZBZ_+"TPOCOR",;
	"C",1,0,;
	"Tipo Ocorrencia","Tipo Ocorrencia","Tipo Ocorrencia",;
	"Tipo Ocorrencia","Tipo Ocorrencia","Tipo Ocorrencia",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","V",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"Tipo Ocorrencia"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"TPOCOR",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//  
	
	AADD(aSX3,{xZBZ,"76",xZBZ_+"ORIGEM",;							//LUCAS SAN -> 16/02/2023
	"C",01,0,;
	"Classif Por:","Classif Por","Classif Por",;
	"Classificado Por","Classificado Por","Classificado Por",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","V",;
	"R","","",;
	"1=Gestão XML;2=Protheus Padrão","","",; //  Erick - 16/02/2023 -> ListBox para criar o Filtro
	"","","",;
	"",""})
	aPHelpPor := {"Indica por qual rotina a NF foi classificada"}
	Aadd(aPHelpPor,"1=Significa que o xml foi classificado via Gestão XML.")
	Aadd(aPHelpPor,"2=Significa que o xml foi classificado via rotina padrão do protheus.")
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBZ_+"ORIGEM",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)

	
	//------------------------------------------------------------//   //FIM ZBZ                                                       
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tabela (xZBB) - Pedido Recorrente            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lTemZBB
		AADD(aSX3,{xZBB,"",xZBB_+"FILIAL",;
		"C",nTamFil,0,;		//"C",02,0,;		//FR - 14/09/2020
		"Filial","Filial","Filial",;
		"Filial do Sistema","Filial do Sistema","Filial do Sistema",;
		"@!","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","033",;
		"",""})
		aPHelpPor := {"Filial do Sistema"}
		aPHelpEng := aPHelpPor
		aPHelpSpa := aPHelpPor
		PutHelp("P"+xZBB_+"FILIAL",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
		//------------------------------------------------------------//                                                         
	
		AADD(aSX3,{xZBB,"",xZBB_+"FORNEC",;
		"C",nTamCod,0,;
		"Cod Forn","Cod Forn","Cod Forn",;
		"Cod Fornecedor","Cod Fornecedor","Cod Fornecedor",;
		"@!","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","001",;
		"",""})
		aPHelpPor := {"Codigo do Fornecedor"}
		aPHelpEng := aPHelpPor
		aPHelpSpa := aPHelpPor
		PutHelp("P"+xZBB_+"FORNEC",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)  
		//------------------------------------------------------------//                                                         
	
		AADD(aSX3,{xZBB,"",xZBB_+"LOJA",;
		"C",nTamLoja,0,;
		"Loja Forn","Loja Forn","Loja Forn",;
		"Loja Fornecedor","Loja Fornecedor","Loja Fornecedor",;
		"@!","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","002",;
		"",""})
		aPHelpPor := {"Loja do Fornecedor"}
		aPHelpEng := aPHelpPor
		aPHelpSpa := aPHelpPor
		PutHelp("P"+xZBB_+"LOJA",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
		//------------------------------------------------------------//                                                         
	
		AADD(aSX3,{xZBB,"",xZBB_+"PROD",;
		"C",nTamProd,0,;
		"Codigo Prod","Codigo Prod","Codigo Prod",;
		"Codigo do Produto","Codigo do Produto","Codigo do Produto",;
		"","",X3_USADO_EMUSO,;
		"","SB1"+xZBB,0,;
		"","","S",;
		"U","S","A",;
		"R","","existcpo('SB1',M->"+xZBB_+"PROD,1)",;
		"","","",;
		"","","030",;
		"",""})
		aPHelpPor := {"Nosso Codigo de Produto"}
		aPHelpEng := aPHelpPor
		aPHelpSpa := aPHelpPor
		PutHelp("P"+xZBB_+"PROD",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
		//------------------------------------------------------------//                                                         
	
		AADD(aSX3,{xZBB,"",xZBB_+"DESC",;
		"C",30,0,;
		"Descr Prod","Descr Prod","Descr Prod",;
		"Descrição do Produto","Descrição do Produto","Descrição do Produto",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
		aPHelpPor := {"Descrção do Produto"}
		aPHelpEng := aPHelpPor
		aPHelpSpa := aPHelpPor
		PutHelp("P"+xZBB_+"DESC",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
		//------------------------------------------------------------//                                                         
	
		AADD(aSX3,{xZBB,"",xZBB_+"UN",;
		"C",30,0,;
		"Unid","Unid","Unid",;
		"Unidade","Unidade","Unidade",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
		aPHelpPor := {"Unidade do Produto"}
		aPHelpEng := aPHelpPor
		aPHelpSpa := aPHelpPor
		PutHelp("P"+xZBB_+"UN",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
		//------------------------------------------------------------//                                                         
		
		cPict := hfPESQPICT("SC7","C7_QUANT")
	
		AADD(aSX3,{xZBB,"",xZBB_+"QUANT",;
		"N",nTamQtdZbb,nDecQtdZbb,;
		"Quantidade","Quantidade","Quantidade",;
		"Quantidade","Quantidade","Quantidade",;
		cPict,"",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
		aPHelpPor := {"Quantidade"}
		aPHelpEng := aPHelpPor
		aPHelpSpa := aPHelpPor
		PutHelp("P"+xZBB_+"QUANT",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
		//------------------------------------------------------------//                                                         
	
		cPict := hfPESQPICT("SC7","C7_PRECO")
	
		AADD(aSX3,{xZBB,"",xZBB_+"VUNIT",;
		"N",nTamUniZbb,nDecUniZbb,;
		"Vr Unitario","Vr Unitario","Vr Unitario",;
		"Valor Unitario","Valor Unitario","Valor Unitario",;
		cPict,"",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
		aPHelpPor := {"Valor Unitario"}
		aPHelpEng := aPHelpPor
		aPHelpSpa := aPHelpPor
		PutHelp("P"+xZBB_+"VUNIT",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
		//------------------------------------------------------------//                                                         
	
		cPict := hfPESQPICT("SC7","C7_TOTAL")
	
		AADD(aSX3,{xZBB,"",xZBB_+"TOTAL",;
		"N",nTamTotZbb,nDecTotZbb,;
		"Vr Total","Vr Total","Vr Total",;
		"Valor Total","Valor Total","Valor Total",;
		cPict,"",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
		aPHelpPor := {"Valor Total"}
		aPHelpEng := aPHelpPor
		aPHelpSpa := aPHelpPor
		PutHelp("P"+xZBB_+"TOTAL",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
		//------------------------------------------------------------//                                                         
	
		AADD(aSX3,{xZBB,"",xZBB_+"PEDIDO",;
		"C",nTamPed,0,;
		"Pedido","Pedido","Pedido",;
		"Numero Pedido","Numero Pedido","Numero Pedido",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
		aPHelpPor := {"Numero Pedido Compra"}
		aPHelpEng := aPHelpPor
		aPHelpSpa := aPHelpPor
		PutHelp("P"+xZBB_+"PEDIDO",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
		//------------------------------------------------------------//                                                         
	
		AADD(aSX3,{xZBB,"",xZBB_+"ITEM",;
		"C",nTamIte,0,;
		"Item","Item","Item",;
		"Item Pedido","Item Pedido","Item Pedido",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
		aPHelpPor := {"Item Pedido Compra"}
		aPHelpEng := aPHelpPor
		aPHelpSpa := aPHelpPor
		PutHelp("P"+xZBB_+"ITEM",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
		//------------------------------------------------------------//                                                         
	
		AADD(aSX3,{xZBB,"",xZBB_+"TES",;
		"C",nTamTes,0,;
		"TES","TES","TES",;
		"Tipo de Entrada","Tipo de Entrada","Tipo de Entrada",;
		"","",X3_USADO_EMUSO,;
		"","SF4",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
		aPHelpPor := {"Tipo de Entrada"}
		aPHelpEng := aPHelpPor
		aPHelpSpa := aPHelpPor
		PutHelp("P"+xZBB_+"TES",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
		//------------------------------------------------------------//                                                         
	
		AADD(aSX3,{xZBB,"",xZBB_+"AMARRA",;
		"C",1,0,;
		"Amarracao","Amarracao","Amarracao",;
		"Amarracao Produto","Amarracao Produto","Amarracao Produto",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
		aPHelpPor := {"Amarracao Produto"}
		aPHelpEng := aPHelpPor
		aPHelpSpa := aPHelpPor
		PutHelp("P"+xZBB_+"AMARRA",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
		//------------------------------------------------------------//                                                         
	
	
		AADD(aSX3,{xZBB,"",xZBB_+"ATUAL",;
		"C",1,0,;
		"Ped Atual","Ped Atual","Ped Atual",;
		"Pedido Atual","Pedido Atual","Pedido Atual",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
		aPHelpPor := {"Pedido Atual"}
		aPHelpEng := aPHelpPor
		aPHelpSpa := aPHelpPor
		PutHelp("P"+xZBB_+"ATUAL",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
		//------------------------------------------------------------//                                                         
	
	Endif
	
	//===============================//
	// ZBS - Sincronização com Sefaz //
	//===============================//
	AADD(aSX3,{xZBS,"",xZBS_+"FILIAL",;
		"C",nTamFil,0,;		//"C",02,0,;		//FR - 14/09/2020
		"Filial","Filial","Filial",;
		"Filial do Sistema","Filial do Sistema","Filial do Sistema",;
		"@!","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","033",;
		"",""})
	aPHelpPor := {"Filial do Sistema"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBS_+"FILIAL",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZBS,"",xZBS_+"OK",;
		"C",2,0,;
		"Marcar","Marcar","Marcar",;
		"Marcar","Marcar","Marcar",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Marcar"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBS_+"OK",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZBS,"",xZBS_+"ST",;
		"C",2,0,;
		"Status","Status","Status",;
		"Status Sicronismo","Status Sicronismo","Status Sicronismo",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Status"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBS_+"ST",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZBS,"",xZBS_+"CHAVE",;
		"C",44,0,;
		"Chave","Chave","Chave",;
		"Chave do XML","Chave do XML","Chave do XML",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Chave do XML"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBS_+"CHAVE",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZBS,"",xZBS_+"MSG",;
		"C",30,0,;
		"Mensagem","Mensagem","Mensagem",;
		"Mensagem do Serviço Executado","Mensagem do Serviço Executado","Mensagem do Serviço Executado",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Mensagem do Serviço Executado"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBS_+"MSG",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZBS,"",xZBS_+"ERRO",;
		"M",10,0,;
		"Resp.Sefaz","Resp.Sefaz","Resp.Sefaz",;
		"Resposta do Sefaz","Resposta do Sefaz","Resposta do Sefaz",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Resposta do Sefaz"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBS_+"ERRO",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZBS,"",xZBS_+"DEST",;
		"C",14,0,;
		"Cnpj Dest","Cnpj Dest","Cnpj Dest",;
		"Cnpj Destinatario","Cnpj Destinatario","Cnpj Destinatario",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Cnpj Destinatario"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBS_+"DEST",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                         
	
	
	AADD(aSX3,{xZBS,"",xZBS_+"CNPJEM",;
		"C",14,0,;
		"Cnpj Emit","Cnpj Emit","Cnpj Emit",;
		"Cnpj Emitente","Cnpj Emitente","Cnpj Emitente",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Cnpj Emitente"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBS_+"CNPJEM",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZBS,"",xZBS_+"DEMI",;
		"D",8,0,;
		"Emissao","Emissao","Emissao",;
		"Data Emissao","Data Emissao","Data Emissao",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Data Emissao"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBS_+"DEMI",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZBS,"",xZBS_+"CNF",;
		"C",nTamDoc,0,;
		"NF","NF","NF",;
		"Numero da Nota Fiscal","Numero da Nota Fiscal","Numero da Nota Fiscal",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","018",;
		"",""})
	aPHelpPor := {"Numero da Nota Fiscal"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBS_+"CNF",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZBS,"",xZBS_+"SERIE",;
		"C",3,2,;
		"Serie","Serie","Serie",;
		"Serie da Nota Fiscal","Serie da Nota Fiscal","Serie da Nota Fiscal",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Serie da Nota Fiscal"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBS_+"SERIE",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZBS,"",xZBS_+"VNF",;
		"N",17,2,;
		"Valor","Valor","Valor",;
		"Valor Da Nota","Valor Da Nota","Valor Da Nota",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Valor Da Nota"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBS_+"VNF",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZBS,"",xZBS_+"XNOME",;
		"C",60,0,;
		"Nome","Nome","Nome",;
		"Nome da Empresa","Nome da Empresa","Nome da Empresa",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Nome da Empresa"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBS_+"XNOME",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZBS,"",xZBS_+"IE",;
		"C",14,0,;
		"Insc Est","Insc Est","Insc Est",;
		"Inscricao Estadual","Inscricao Estadual","Inscricao Estadual",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Inscricao Estadual"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBS_+"IE",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)  
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZBS,"",xZBS_+"DHRECB",;
		"D",8,0,;
		"Data Autor","Data Autor","Data Autor",;
		"Data de autorização da NF-e","Data de autorização da NF-e","Data de autorização da NF-e",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Data de autorização da NF-e"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBS_+"DHRECB",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZBS,"",xZBS_+"CSITNF",;
		"C",1,0,;
		"Situação","Situação","Situação",;
		"Situação da NF-e","Situação da NF-e","Situação da NF-e",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Situação da NF-e:"}
	Aadd(aPHelpPor,"1=Uso autorizado no momento da consulta;")
	Aadd(aPHelpPor,"2=Uso denegado;")
	Aadd(aPHelpPor,"3=NF-e cancelada.")
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBS_+"CSITNF",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZBS,"",xZBS_+"CSITCO",;
		"C",1,0,;
		"Manif","Manif","Manif",;
		"Situação da Manifestação do Destinatário","Situação da Manifestação do Destinatário","Situação da Manifestação do Destinatário",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Situação da Manifestação do Destinatário:"}
	Aadd(aPHelpPor,"0=Sem Manifestação do Destinatário;")
	Aadd(aPHelpPor,"1=Confirmada Operação;")
	Aadd(aPHelpPor,"2=Desconhecida;")
	Aadd(aPHelpPor,"3=Operação não Realizada;")
	Aadd(aPHelpPor,"4=Ciência.")
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBS_+"CSITCO",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZBS,"",xZBS_+"NSU",;
		"C",15,0,;
		"NSU","NSU","NSU",;
		"NSU do documento fiscal.","NSU do documento fiscal.","NSU do documento fiscal.",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"NSU do documento fiscal."}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBS_+"NSU",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZBS,"",xZBS_+"CORREC",;
		"M",10,0,;
		"Carta Correção","Carta Correção","Carta Correção",;
		"Correção a ser considerada","Correção a ser considerada","Correção a ser considerada",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Correção a ser considerada."}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBS_+"CORREC",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZBS,"",xZBS_+"DIGVAL",;
		"C",28,0,;
		"Digest","Digest","Digest",;
		"Digest Value da NF-e","Digest Value da NF-e","Digest Value da NF-e",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Digest Value da NF-e na base de dados da SEFAZ"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBS_+"DIGVAL",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         
	
	//aadd( aStru, { "IDENT"   ,"C",14,0 } )
	AADD(aSX3,{xZBS,"",xZBS_+"IDENT",;
		"C",14,0,;
		"Id Ent","Id Ent","Id Ent",;
		"Id Entidade","Id Entidade","Id Entidade",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Identificação da Entidade no Protheus"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBS_+"IDENT",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZBS,"",xZBS_+"AMB",;
		"C",1,0,;
		"Ambiente","Ambiente","Ambiente",;
		"Ambiente","Ambiente","Ambiente",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Ambiente"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBS_+"AMB",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZBS,"",xZBS_+"ESPIAO",;
		"C",1,0,;
		"Espião","Espião","Espião",;
		"Espião","Espião","Espião",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Espião"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBS_+"ESPIAO",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         
	
	
	//DownCte
	AADD(aSX3,{xZBS,"",xZBS_+"MODELO",;
	"C",02,0,;
	"Modelo","Modelo","Modelo",;
	"Modelo do XML","Modelo do XML","Modelo do XML",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","V",;
	"R","","",;
	"55=NF-e;57=CT-e;65=NFCe;67=CTeOS",;
	"55=NF-e;57=CT-e;65=NFCe;67=CTeOS",;
	"55=NF-e;57=CT-e;65=NFCe;67=CTeOS",;
	"","","",;
	"",""})
	
	aPHelpPor := {"Modelo do XML :" }
	Aadd(aPHelpPor,"55=NF-e"        )
	Aadd(aPHelpPor,"57=CT-e"        )
	Aadd(aPHelpPor,"65=NFC-e"       )
	Aadd(aPHelpPor,"67=CT-eOs"      )
	
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBS_+"MODELO",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                         
	
	
	AADD(aSX3,{xZBS,"",xZBS_+"XML",;
	"M",10,0,;
	"XML  ","XML   ","XML  ",;
	"XML da NFE/CTE  ","XML da NFE/CTE  ","XML da NFE/CTE  ",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","V",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"XML Nfe/CTe do Fornecedor"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBS_+"XML",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                         
	
	//Inclusão de campo para Tomador de serviço.
	AADD(aSX3,{xZBS,"",xZBS_+"TOMA",;
		"C",14,0,;
		"Cnpj Tomador","Cnpj Tomador","Cnpj Tomador",;
		"Cnpj Tomador","Cnpj Tomador","Cnpj Tomador",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Cnpj Tomador"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBS_+"TOMA",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         
	
	//em 21/06/2019
	AADD(aSX3,{xZBS,"",xZBS_+"TPROT",;
	"C",01,0,;
	"Tp Rotina","Tp Rotina","Tp Rotina",;
	"Tipo da Rotina","Tipo da Rotina","Tipo da Rotina",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","A",;
	"R","","",;
	"J=JOB;M=Manual","","",;
	"","","",;
	"",""})
	aPHelpPor := {"Tipo da Rotina que Leu a Chave."}
	Aadd(aPHelpPor,"J=JOB"          )
	Aadd(aPHelpPor,"M=Manual"          )
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBS_+"TPROT",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                         
	
	 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tabela ZBA - Usuáriso com Amarração Secundária ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AADD(aSX3,{xZBA,"",xZBA_+"FILIAL",;
	"C",nTamFil,0,;		//"C",02,0,;	//FR - 14/09/2020
	"Filial","Filial","Filial",;
	"Filial do Sistema","Filial do Sistema","Filial do Sistema",;
	"@!","",X3_USADO_NAOUSADO,;
	"","",1,;
	"","","",;
	"","N","",;
	"","","",;
	"","","",;
	"","","033",;
	"033",""})
	aPHelpPor := {"Filial do Sistema"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBA_+"FILIAL",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZBA,"",xZBA_+"CODUSR",;
	"C",6,0,;
	"Cod. Usuário.","Cod. Usuário.","Cod. Usuário.",;
	"Codigo do Usuário","Codigo do Usuário","Codigo do Usuário",;
	"@!","",X3_USADO_EMUSO,;
	"","US2",0,;
	"","","S",;
	"U","S","A",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"Codigo do Usuário"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBA_+"CODUSR",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)  
	//------------------------------------------------------------//                                                         
	
	
	AADD(aSX3,{xZBA,"",xZBA_+"USUARI",;
	"C",25,0,;
	"Login Usuário.","Login Usuário.","Login Usuário.",;
	"Login do Usuário","Login do Usuário","Login do Usuário",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","V",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"Login do Usuário - ID"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBA_+"USUARI",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         
	
	
	AADD(aSX3,{xZBA,"",xZBA_+"NOME",;
	"C",40,0,;
	"Nome Usuário.","Nome Usuário.","Nome Usuário.",;
	"Nome do Usuário","Nome do Usuário","Nome do Usuário",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","V",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"Nome do Usuário"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBA_+"NOME",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZBA,"",xZBA_+"AMARRA",;
		"C",1,0,;
		"Amarração","Amarração","Amarração",;
		"Amarração Secundária","Amarração Secundária","Amarração Secundária",;
		"@!","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"0=Sempre Perguntar;1=Padrão(SA5/SA7);2=Customizada("+AllTrim(GetNewPar("XM_TABAMAR","ZB5"))+");3=Sem Amarração;4=Por Pedido;5=Virtual",;
		"0=Sempre Perguntar;1=Padrão(SA5/SA7);2=Customizada("+AllTrim(GetNewPar("XM_TABAMAR","ZB5"))+");3=Sem Amarração;4=Por Pedido;5=Virtual",;
		"0=Sempre Perguntar;1=Padrão(SA5/SA7);2=Customizada("+AllTrim(GetNewPar("XM_TABAMAR","ZB5"))+");3=Sem Amarração;4=Por Pedido;5=Virtual",;
		"","","",;
		"",""})
	aPHelpPor := {"Amarração:"}
	Aadd(aPHelpPor,"0=Sempre Perguntar;")
	Aadd(aPHelpPor,"1=Padrão(SA5/SA7);")
	Aadd(aPHelpPor,"2=Customizada("+AllTrim(GetNewPar("XM_TABAMAR","ZB5"))+");")
	Aadd(aPHelpPor,"3=Sem Amarração;")
	Aadd(aPHelpPor,"4=Por Pedido;")
	Aadd(aPHelpPor,"5=Virtual.")
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBA_+"AMARRA",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                         
	
	
	//=====================================//
	// ZBE - Carta de correção e eventos   //
	//=====================================//
	AADD(aSX3,{xZBE,"",xZBE_+"FILIAL",;
		"C",nTamFil,0,;		//"C",02,0,;		//FR - 14/09/2020
		"Filial","Filial","Filial",;
		"Filial do Sistema","Filial do Sistema","Filial do Sistema",;
		"@!","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","033",;
		"",""})
	aPHelpPor := {"Filial do Sistema"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBE_+"FILIAL",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZBE,"",xZBE_+"CHAVE",;
		"C",60,0,;
		"Chave","Chave","Chave",;
		"Chave do XML","Chave do XML","Chave do XML",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Chave do XML"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBE_+"CHAVE",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)  
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZBE,"",xZBE_+"TPEVE",;
		"C",6,0,;
		"Tp Evento","Tp Evento","Tp Evento",;
		"Tipo do Evento","Tipo do Evento","Tipo do Evento",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"110110=Carta Correção;110111=Cancelada;210200=Conf.Oper.;210210=Ciência Op.;210220=Descon.Op;210240=Oper.N.Real.;610110=Desacordo CTe",;
		"110110=Carta Correção;110111=Cancelada;210200=Conf.Oper.;210210=Ciência Op.;210220=Descon.Op;210240=Oper.N.Real.;610110=Desacordo CTe",;
		"110110=Carta Correção;110111=Cancelada;210200=Conf.Oper.;210210=Ciência Op.;210220=Descon.Op;210240=Oper.N.Real.;610110=Desacordo CTe",;
		"","","",;
		"",""})
	aPHelpPor := {"Tipo do Envento"}
	Aadd(aPHelpPor,"110110=Carta de Correção;")
	Aadd(aPHelpPor,"110111=NF. Cancelada;")
	Aadd(aPHelpPor,"Manifestações do Destinatário:")
	Aadd(aPHelpPor,"210200=Confirmação da operação;")
	Aadd(aPHelpPor,"210210=Ciência da operação;")
	Aadd(aPHelpPor,"210220=Desconhecimento da Operação;")
	Aadd(aPHelpPor,"210240=Operação Não Realizada.")
	Aadd(aPHelpPor,"Manifestações do CTe:")
	Aadd(aPHelpPor,"610110=Desacordo CTe.")
	
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBE_+"TPEVE",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)    
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZBE,"",xZBE_+"SEQEVE",;
		"C",2,0,;
		"Seq Evento","Seq Evento","Seq Evento",;
		"Sequencia do Evento","Sequencia do Evento","Sequencia do Evento",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Sequencia do Envento"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBE_+"SEQEVE",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZBE,"",xZBE_+"STATUS",;
	"C",1,0,;
	"Status","Status","Status",;
	"Status","Status","Status",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","A",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	aPHelpPor := {"Status do xml."+CRLF+;
					"1=OK"+CRLF+;
					"2=Erro"+CRLF+;
					"3=Aviso"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBE_+"STATUS",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                         
	
	
	AADD(aSX3,{xZBE,"",xZBE_+"DHAUT",;
		"D",8,0,;
		"Data Autor","Data Autor","Data Autor",;
		"Data de autorização do Evento","Data de autorização do Evento","Data de autorização do Evento",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Data de autorização do Evento"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBE_+"DHAUT",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)  
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZBE,"",xZBE_+"PROT",;
	"C",15,0,;
	"Protocolo","Protocolo","Protocolo",;
	"Protocolo do Evento","Protocolo do Evento","Protocolo do Evento",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","A",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	aPHelpPor := {"Protocolo do Evento do XML"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBE_+"PROT",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                          
	
	AADD(aSX3,{xZBE,"",xZBE_+"DTRECB",;
	"D",08,0,;
	"Dt.Rec.Evento","Dt.Rec.Evento","Dt.Rec.Evento",;
	"Dt. do Recebimento do Evento","Dt. do Recebimento do Evento","Dt. do Recebimento do Evento",;
	"@D","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","A",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	aPHelpPor := {"Data do Recebimento do Evento"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBE_+"DTRECB",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         
	
	
	AADD(aSX3,{xZBE,"",xZBE_+"DESC",;
	"C",254,0,;
	"Descr.","Descr.","Descr.",;
	"Descrição do Evento","Descrição do Evento","Descrição do Evento",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","A",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	aPHelpPor := {"Descrição do Evento"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBE_+"DESC",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZBE,"",xZBE_+"XML",;
	"M",10,0,;
	"XML","XML","XML",;
	"XML do Evento","XML do Evento","XML do Evento",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","V",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	aPHelpPor := {"XML do Evento"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBE_+"XML",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                          
	
	AADD(aSX3,{xZBE,"",xZBE_+"EVENTO",;
	"M",10,0,;
	"EVENTO","EVENTO","EVENTO",;
	"Descrição do Evento","Descrição do Evento","Descrição do Evento",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","V",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	aPHelpPor := {"Descrição Completa do Evento"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBE_+"EVENTO",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         
	
	//FR - 08/09/2020 - novo campo grava data e hora do registro
	AADD(aSX3,{xZBE,"",xZBE_+"DTHRGR",;
	"C",19,0,;
	"D/H Gravação","D/H gravação","D/H gravação",;
	"Data/Hora gravação","Data/Hora gravação","Data/Hora gravação",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","N","V",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"Data e hora da gravação do registro","Formato AAAA-MM-DDTHH:MM:DD"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBE_+"DTHRGR",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                                
	
	//=====================//
	// ZYX - Systax       //
	//=====================//
	AADD(aSX3,{xZYX,"",xZYX_+"FILIAL",;
		"C",nTamFil,0,;	//"C",02,0,;		//FR - 14/09/2020
		"Filial","Filial","Filial",;
		"Filial do Sistema","Filial do Sistema","Filial do Sistema",;
		"@!","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","033",;
		"",""})
	aPHelpPor := {"Filial do Sistema"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZYX_+"FILIAL",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)  
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZYX,"",xZYX_+"CHAVE",;
		"C",44,0,;
		"Chave","Chave","Chave",;
		"Chave do XML","Chave do XML","Chave do XML",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Chave do XML"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZYX_+"CHAVE",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZYX,"",xZYX_+"SEQ",;
		"C",3,0,;
		"Seq Consulta","Seq Consulta","Seq Consulta",;
		"Sequencia de Consultas","Sequencia de Consulta","Sequencia de Consulta",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Sequencia de Consulta"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZYX_+"SEQ",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZYX,"",xZYX_+"PROT",;
	"C",30,0,;
	"Protocolo","Protocolo","Protocolo",;
	"Protocolo de autorização","Protocolo de autorização","Protocolo de autorização",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","N","V",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"Protocolo de Consulta Systax"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZYX_+"PROT",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZYX,"",xZYX_+"QTCRIT",;
		"N",4,0,;
		"Qtd Criticas","Qtd Criticas","Qtd Criticas",;
		"Qtd Criticas","Qtd Criticas","Qtd Criticas",;
		"9999","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
		aPHelpPor := {"Qtd Criticas"}
		aPHelpEng := aPHelpPor
		aPHelpSpa := aPHelpPor
	PutHelp("P"+xZYX_+"QTCRIT",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZYX,"",xZYX_+"QTSUG",;
		"N",4,0,;
		"Qtd Sugestões","Qtd Sugestões","Qtd Sugestões",;
		"Qtd Sugestões","Qtd Sugestões","Qtd Sugestões",;
		"9999","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
		aPHelpPor := {"Qtd Sugestões"}
		aPHelpEng := aPHelpPor
		aPHelpSpa := aPHelpPor
	PutHelp("P"+xZYX_+"QTSUG",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZYX,"",xZYX_+"XMLRET",;
	"M",10,0,;
	"XML Retorno","XML Retorno","XML Retorno",;
	"XML de Retorno Systax","XML de Retorno Systax","XML de Retorno Systax",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","V",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	aPHelpPor := {"XML de Retorno Systax"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZYX_+"XMLRET",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZYX,"",xZYX_+"DTCON",;
	"D",08,0,;
	"Dt.Consulta","Dt.Consulta","Dt.Consulta",;
	"Data da Consulta","Data da Consulta","Data da Consulta",;
	"@D","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","N","V",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"Data da Consulta Systax"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZYX_+"DTCON",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZYX,"",xZYX_+"HRCON",;
	"C",08,0,;
	"Hr.Consulta","Hr.Consulta","Hr.Consulta",;
	"Hora da Consulta","Hora da Consulta","Hora da Consulta",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","N","V",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"Hora da Consulta Systax"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZYX_+"HRCON",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZYX,"",xZYX_+"STATUS",;
	"C",1,0,;
	"Status","Status","Status",;
	"Status","Status","Status",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","A",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	aPHelpPor := {"Status do xml."+CRLF+;
					"0=OK"+CRLF+;
					"1=Sem Parâmetros"+CRLF+;
					"2=Não Parece NF-e"+CRLF+;
					"3=Fora do Período"+CRLF+;
					"4=NF-e com erros" }
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZYX_+"STATUS",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZYX,"",xZYX_+"MSG",;
	"C",30,0,;
	"Msg Consulta","Msg Consulta","Msg Consulta",;
	"Mensagem Consulta","Mensagem Consulta","Mensagem Consulta",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","N","V",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"Mensagem da Consulta Systax"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZYX_+"MSG",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         
	
	
	AADD(aSX3,{xZYX,"",xZYX_+"FINALI",;
	"C",60,0,;
	"Finalidade","Finalidade","Finalidade",;
	"Finalidade","Finalidade","Finalidade",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","N","V",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"Finalidade utilizada na Consulta Systax"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZYX_+"FINALI",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         
	
	
	//===========================================//
	// ZBC - Amarração Classificação Automática //
	//===========================================//
	AADD(aSX3,{xZBC,"",xZBC_+"FILIAL",;
	"C",nTamFil,0,;		//"C",02,0,;	//FR - 14/09/2020
	"Filial","Filial","Filial",;
	"Filial do Sistema","Filial do Sistema","Filial do Sistema",;
	"@!","",X3_USADO_NAOUSADO,;
	"","",0,;
	"","","",;
	"","N","",;
	"","","",;
	"","","",;
	"","","",;
	"033",""})
	aPHelpPor := {"Filial do Sistema"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBA_+"FILIAL",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)  
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZBC,"",xZBC_+"CODFOR",;
	"C",nTamCod,0,;
	"Cod. Fornec.","Cod. Fornec.","Cod. Fornec.",;
	"Codigo do Fornecedor","Codigo do Fornecedor","Codigo do Fornecedor",;
	"@!","",X3_USADO_NAOALTERA,;
	"","SA2",0,;
	"","","S",;
	"U","S","A",;
	"R","","",;
	"","","",;
	"","!ALTERA","",;
	"001",""})
	
	aPHelpPor := {"Codigo do Fornecedor"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBC_+"CODFOR",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         
	
	
	AADD(aSX3,{xZBC,"",xZBC_+"LOJFOR",;
	"C",nTamLoja,0,;
	"Loja Fornec.","Loja Fornec.","Loja Fornec.",;
	"Loja do Fornecedor","Loja do Fornecedor","Loja do Fornecedor",;
	"@!","",X3_USADO_NAOALTERA,;
	"","",0,;
	"","","S",;
	"U","S","A",;
	"R","","",;
	"","","",;
	"","!ALTERA","",;
	"002",""})
	
	aPHelpPor := {"Loja do Fornecedor"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBC_+"LOJFOR",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         
	
	                   
	AADD(aSX3,{xZBC,"",xZBC_+"CGC",;
	"C",14,0,;
	"CNPJ/CPF","CNPJ/CPF","CNPJ/CPF",;
	"CNPJ/CPF do Fornec.","CNPJ/CPF do Fornec.","CNPJ/CPF do Fornec.",;
	"@R 99.999.999/9999-99","Vazio().Or.(Cgc(M->"+xZBC_+"CGC))",X3_USADO_NAOALTERA,;
	"","",0,;
	"","","",;
	"U","S","A",;
	"R","","",;
	"","","",;
	"",".F.","",;
	"",""})
	
	aPHelpPor := {"CNPJ do Fornecedor"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBC_+"CGC",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZBC,"",xZBC_+"NOME",;
	"C",40,0,;
	"Razao Social","Razao Social","Razao Social",;
	"Razao Social Fornec.","Razao Social Fornec.","Razao Social Fornec.",;
	"@!","",X3_USADO_NAOALTERA,;
	"","",0,;
	"","","",;
	"U","S","A",;
	"R","","",;
	"","","",;
	"",".F.","",;
	"",""})
	
	aPHelpPor := {"Razao Social do Fornecedor"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBC_+"NOME",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         
	
	
	AADD(aSX3,{xZBC,"",xZBC_+"PROD",;
	"C",nTamProd,0,;
	"Produto","Produto","Produto",;
	"Nosso Codigo de Produto","Nosso Codigo de Produto","Nosso Codigo de Produto",;
	"","",X3_USADO_EMUSO,;
	"","SB1",0,;
	"","","S",;
	"U","S","A",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"Nosso Codigo de Produto"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBC_+"PROD",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZBC,"",xZBC_+"DESCPR",;
	"C",40,0,;
	"Descricao","Descricao","Descricao",;
	"Descricao Nosso Produto","Descricao Nosso Produto","Descricao Nosso Produto",;
	"@!","",X3_USADO_NAOALTERA,;
	"","",0,;
	"","","",;
	"U","S","A",;
	"R","","",;
	"","","",;
	"",".F.","",;
	"",""})
	
	aPHelpPor := {"Descricao Nosso Produto"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBC_+"DESCPR",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZBC,"",xZBC_+"TES",;
		"C",nTamTes,0,;
		"TES","TES","TES",;
		"Tipo de Entrada","Tipo de Entrada","Tipo de Entrada",;
		"","",X3_USADO_EMUSO,;
		"","SF4",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
		aPHelpPor := {"Tipo de Entrada"}
		aPHelpEng := aPHelpPor
		aPHelpSpa := aPHelpPor
		PutHelp("P"+xZBC_+"TES",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
		//------------------------------------------------------------//                                                         
	                                                              
	AADD(aSX3,{xZBC,"",xZBC_+"CC",;
		"C",nTamCc,0,;
		"C. Custo","C. Custo","C. Custo",;
		"Centro de Custo","Centro de Custo","Centro de Custo",;
		"","",X3_USADO_EMUSO,;
		"","CTT",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","",;
		"004",""})
	aPHelpPor := {"Centro de Custo"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBC_+"CC",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                         
	
	
	AADD(aSX3,{xZBC,"",xZBC_+"TIPO",; 		//pos: 3
		"C",1,0,;
		"Tp. Amar","Tp Amar","Tp Amar",;
		"Tipo da Amaração","Tipo da Amaração","Tipo da Amaração",;
		"","",X3_USADO_EMUSO,;
		'"C"',"",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"C=Combustivel;E=Energia",;   //pos:28			//FR - 18/08/2020 - Kroma Energia
		"C=Combustivel;E=Energia",;
		"C=Combustivel;E=Energia",;
		"","","",;
		"",""})
	aPHelpPor := {"Tipo da Amarração"}
	Aadd(aPHelpPor,"C=Combustivel.")
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBC_+"TIPO",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                         
	
	//===========================//
	// ZBI - Integração Externa //
	//===========================//
	AADD(aSX3,{xZBI,"",xZBI_+"FILIAL",;
		"C",nTamFil,0,;		//"C",02,0,;	//FR - 14/09/2020
		"Filial","Filial","Filial",;
		"Filial do Sistema","Filial do Sistema","Filial do Sistema",;
		"@!","",X3_USADO_NAOUSADO,;
		"","",0,;
		"","","",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","",;
		"033",""})
	aPHelpPor := {"Filial do Sistema"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBI_+"FILIAL",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZBI,"",xZBI_+"ARQ",;
		"C",45,0,;
		"Arquivo","Arquivo","Arquivo",;
		"Nome do Arquivo","Nome do Arquivo","Nome do Arquivo",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Nome do Arquivo da Ocorrencia"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBI_+"ARQ",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZBI,"",xZBI_+"DIR",;
		"C",90,0,;
		"Pasta","Pasta","Pasta",;
		"Diretorio do Arquivo","Diretorio do Arquivo","Diretorio do Arquivo",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Diretorio do Arquivo da Ocorrencia"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBI_+"DIR",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         
	
	
	AADD(aSX3,{xZBI,"",xZBI_+"FTP",;
		"C",45,0,;
		"Arq FTP","Arq FTP","Arq FTP",;
		"Nome do Arquivo FTP","Nome do Arquivo FTP","Nome do Arquivo FTP",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Nome do Arquivo no FTP da Ocorrencia"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBI_+"FTP",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                         
	
	
	AADD(aSX3,{xZBI,"",xZBI_+"DTARQ",;
	"D",08,0,;
	"Dt.Arquivo","Dt.Arquivo","Dt.Arquivo",;
	"Data do Arquivo","Data do Arquivo","Data do Arquivo",;
	"@D","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","N","V",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"Data do Arquivo"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBI_+"DTARQ",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                         
	
	
	AADD(aSX3,{xZBI,"",xZBI_+"DTCLAS",;
	"D",08,0,;
	"Dt.Class","Dt.Class","Dt.Class",;
	"Data Cassificação","Data Classificação","Data Classificação",;
	"@D","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","N","V",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"Data da Classificação"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBI_+"DTCLAS",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                         
	
	
	AADD(aSX3,{xZBI,"",xZBI_+"ST",;
		"C",1,0,;
		"Status","Status","Stauts",;
		"Status Classif","Status Classif","Status Classif",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Status Classif"+CRLF+;
				  "0=Aguardando"+CRLF+;
				  "1=Erro"+CRLF+;
	              "2=Executado" }
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBI_+"ST",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                         
	
	//=======================================//
	// ZBO - Ocorrências Integração Externa //
	//=======================================//
	AADD(aSX3,{xZBO,"",xZBO_+"FILIAL",;
		"C",nTamFil,0,;		//"C",02,0,;	//FR - 14/09/2020
		"Filial","Filial","Filial",;
		"Filial do Sistema","Filial do Sistema","Filial do Sistema",;
		"@!","",X3_USADO_NAOUSADO,;
		"","",0,;
		"","","",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","",;
		"033",""})
	aPHelpPor := {"Filial do Sistema"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBO_+"FILIAL",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         
	
	
	AADD(aSX3,{xZBO,"",xZBO_+"CODSEQ",;
	"C",6,0,;
	"Código","Código","Código",;
	"Código Sequêncial","Código Sequêncial","Código Sequêncial",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","",;
	"U","S","A",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"Código Sequencial das Ocorrências de Integração"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBO_+"CODSEQ",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)  
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZBO,"",xZBO_+"DESCR",;
	"C",254,0,;     			//FR - 18/08/2020
	"Descrição","Descrição","Descrição",;
	"Descrição Sequêncial","Descrição Sequêncial","Descrição Sequêncial",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","",;
	"U","S","A",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"Descrição Sequencial das Ocorrências de Integração"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBO_+"DESCR",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                         
	
	
	AADD(aSX3,{xZBO,"",xZBO_+"DTOCOR",;
	"D",08,0,;
	"Dt.Ocorrencia","Dt.Ocorrencia","Dt.Ocorrencia",;
	"Data da Ocorrencia","Data da Ocorrencia","Data da Ocorrencia",;
	"@D","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","N","V",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"Data da Ocorrencia"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBO_+"DTOCOR",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZBO,"",xZBO_+"HROCOR",;
	"C",08,0,;
	"Hr.Ocorrencia","Hr.Ocorrencia","Hr.Ocorrencia",;
	"Hora da Ocorrencia","Hora da Ocorrencia","Hora da Ocorrencia",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","N","V",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"Hora da Ocorrencia"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBO_+"HROCOR",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                         
	
	
	AADD(aSX3,{xZBO,"",xZBO_+"CHAVE",;
		"C",44,0,;
		"Chave","Chave","Chave",;
		"Chave do XML","Chave do XML","Chave do XML",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Chave do XML"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBO_+"CHAVE",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                         
	
	
	AADD(aSX3,{xZBO,"",xZBO_+"RETSEF",;
		"C",54,0,;
		"Ret.Sefaz","Ret.Sefaz","Ret.Sefaz",;
		"Retorno do Sefaz","Retorno do Sefaz","Retorno do Sefaz",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Retorno do Sefaz"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBO_+"RETSEF",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         
	
	
	AADD(aSX3,{xZBO,"",xZBO_+"EXAUTO",;
	"M",10,0,;
	"ExecAuto","ExecAuto","ExecAuto",;
	"ExecAuto Mostra Erro","ExecAuto Mostra Erro","ExecAuto Mostra Erro",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","V",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	aPHelpPor := {"Erro na Classificação por ExecAuto. Tela MostraErro()."}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBO_+"EXAUTO",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                         
	
	
	AADD(aSX3,{xZBO,"",xZBO_+"TPOCOR",;
	"C",1,0,;
	"Tipo","Tipo","Tipo",;
	"Tipo da Ocorrencia","Tipo da Ocorrencia","Tipo da Ocorrencia",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","A",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	aPHelpPor := {"Tipo da Ocorrencia."+CRLF+;
					"1=Classificação"+CRLF+;
					"2=Auditoria" }
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBO_+"TPOCOR",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZBO,"",xZBO_+"REVISA",;
		"C",3,0,;
		"Revisão","Revisão","Revisão",;
		"Revisão da Ocorrencia","Revisão da Ocorrencia","Revisão da Ocorrencia",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Revisão da Ocorrencia"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBO_+"REVISA",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZBO,"",xZBO_+"ARQ",;
		"C",45,0,;
		"Arquivo","Arquivo","Arquivo",;
		"Nome do Arquivo","Nome do Arquivo","Nome do Arquivo",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Nome do Arquivo da Ocorrencia"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBO_+"ARQ",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZBO,"",xZBO_+"FTP",;
		"C",45,0,;
		"Arq FTP","Arq FTP","Arq FTP",;
		"Nome do Arquivo FTP","Nome do Arquivo FTP","Nome do Arquivo FTP",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Nome do Arquivo no FTP da Ocorrencia"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBO_+"FTP",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZBO,"",xZBO_+"ST",;
	"C",1,0,;
	"Status","Status","Status",;
	"Status da Ocorrencia","Status da Ocorrencia","Status da Ocorrencia",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","A",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	aPHelpPor := {"Status da Ocorrencia."+CRLF+;
					"0=Sem Ação"+CRLF+;
					"1=Pendente"+CRLF+;
					"2=Corrigida" }
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBO_+"ST",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZBO,"",xZBO_+"M0COD",;
		"C",len( SM0->M0_CODIGO ),0,;
		"Empresa","Empresa","Empresa",;
		"Empresa","Empresa","Empresa",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Empresa Sigamat"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBO_+"M0COD",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         
	
	
	AADD(aSX3,{xZBO,"",xZBO_+"MAIL",;
		"C",1,0,;
		"e-mail","e-mail","e-mail",;
		"Status e-mail","Status e-mail","Status e-mail",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Status e-mail"+CRLF+;
				  "1=Email a Enviar"+CRLF+;
	              "2=Enviado" }
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBO_+"MAIL",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                         
	
	//FR - 14/11/19
	//====================//
	// ZBT - Itens da NF //
	//====================//
	AADD(aSX3,{xZBT,"",xZBT_+"FILIAL",;
		"C",nTamFil,0,;		//"C",02,0,;	//FR - 14/09/2020
		"Filial","Filial","Filial",;
		"Filial do Sistema","Filial do Sistema","Filial do Sistema",;
		"@!","",X3_USADO_NAOUSADO,;
		"","",0,;
		"","","",;
		"U","N","V",;
		"R","","",;
		"","","",;
		"","","033",;
		"",""})
	aPHelpPor := {"Filial do Sistema"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBT_+"FILIAL",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//-------------------------------------------------------------//
	
	AADD(aSX3,{xZBT,"",xZBT_+"ITEM",;
		"C",04,0,;
		"Item XML","Item XML","Item XML",;
		"Item XML","Item XML","Item XML",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Item do XML"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBT_+"ITEM",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//-------------------------------------------------------------// 
	/*
	AADD(aSX3,{xZBT,"",xZBT_+"PRODUT",;
		"C",nTamPrif,0,;  //"C",nTamProd,0,;		//FR - 13/04/2021 - Alinhar o tamanho do código produto fornecedor com a SA5 - A5_CODPRF
		"Prod.Forn.","Prod.Forn.","Prod.Forn.",;	//FR - 13/04/2021 - Alterado nome do campo para ficar visível o que é o código produto fornecedor em relação ao campo ZBT_DEPARA (que é o código interno do produto)
		"Cod.Prod.For","Cod.Prod.For","Cod.Prod.For",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Codigo do Produto do Fornecedor"}	//FR - 13/04/2021
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBT_+"PRODUT",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	*/
	AADD(aSX3,{xZBT,"",xZBT_+"PRODUT",;
		"C",60,0,;  								//FR - 02/03/2022 - OCRIM - AJUSTE DE CAMPOS - chamado 12100
		"Prod.Forn.","Prod.Forn.","Prod.Forn.",;	
		"Cod.Prod.For","Cod.Prod.For","Cod.Prod.For",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Codigo do Produto do Fornecedor"}	//FR - 13/04/2021
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBT_+"PRODUT",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//-------------------------------------------------------------//
	/*
	AADD(aSX3,{xZBT,"",xZBT_+"DESCRI",;
		"C",30,0,;
		"Desc.Produto","Desc.Produto","Desc.Produto",;
		"Descrição do Produto","Descrição do Produto","Descrição do Produto",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Descrição do Produto"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBT_+"DESCRI",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	*/
	AADD(aSX3,{xZBT,"",xZBT_+"DESCRI",;					//FR - 02/03/2022 - OCRIM - AJUSTE DE CAMPOS - chamado 12100
		"C",250,0,;										//FR - 27/01/2023 - DAIKIN - AUMENTO DO CAMPO POR EXIGÊNCIA DO SPED-AM
		"Desc.Produto","Desc.Produto","Desc.Produto",;
		"Descrição do Produto","Descrição do Produto","Descrição do Produto",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Descrição do Produto"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBT_+"DESCRI",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//-------------------------------------------------------------//
	
	AADD(aSX3,{xZBT,"",xZBT_+"QUANT",;
		"N",14,5,;											//FR - 10/12/2020			
		"Quant.XML","Quant.XML","Quant.XML",;				//FR - 29/03/2021
		"Qtde.Prod.XML","Qtde.Prod.XML","Qtde.Prod.XML",;	//FR - 29/03/2021
		"@E 99999999.99999","",X3_USADO_EMUSO,;				//FR - 10/12/2020
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Quantidade Produto"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBT_+"QUANT",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)	
	//-------------------------------------------------------------//
	/*
	AADD(aSX3,{xZBT,"",xZBT_+"UM",;									//FR - 15/04/2021 - novo campo para unidade de medida
		"C",nTamUM,0,;
		"Unid.Medida","Unid.Medida","Unid.Medida",;		//aqui o tamanho máximo é 10
		"Unid.Medida","Unid.Medida","Unid.Medida",;		//aqui o tamanho é 12
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Unidade de Medida"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBT_+"UM",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	*/
	
	AADD(aSX3,{xZBT,"",xZBT_+"UM",;									//FR - 02/03/2022 - OCRIM - AJUSTE DE CAMPOS - chamado 12100
		"C",6,0,;
		"Unid.Medida","Unid.Medida","Unid.Medida",;		//aqui o tamanho máximo é 10
		"Unid.Medida","Unid.Medida","Unid.Medida",;		//aqui o tamanho é 12
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Unidade de Medida"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBT_+"UM",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//-------------------------------------------------------------//	
	AADD(aSX3,{xZBT,"",xZBT_+"VUNIT",;
		"N",16,4,;				
		"Vlr.Unitario","Vlr.Unitario","Vlr.Unitario",;
		"Valor Unitario","Valor Unitario","Valor Unitario",;
		"@E 999,999,999.9999","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Valor Unitario Produto"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBT_+"VUNIT",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)	
	//-------------------------------------------------------------//	
	
	AADD(aSX3,{xZBT,"",xZBT_+"TOTAL",;
		"N",14,2,;				
		"Vlr.Total","Vlr.Total","Vlr.Total",;
		"Vlr.Total","Vlr.Total","Vlr.Total",;
		"@E 999,999,999.99","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Valor Total Produto"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBT_+"TOTAL",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)	
	//-------------------------------------------------------------//
	
	AADD(aSX3,{xZBT,"",xZBT_+"NCM",;									//FR - 15/04/2021 - novo campo para NCM
		"C",nTamNCM,0,;
		"NCM","NCM","NCM",;							//aqui o tamanho máximo é 10
		"NCM Produto","NCM Produto","NCM Produto",;	//aqui o tamanho é 12
		"@E 9999999999","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"NCM Produto"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBT_+"NCM",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//-------------------------------------------------------------//
	AADD(aSX3,{xZBT,"",xZBT_+"CLIFOR",;
		"C",nTamCod,0,;
		"Cli/For","Cli/For","Cli/For",;
		"Client/Forn","Client/Forn","Client/Forn",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","001",;
		"",""})
	aPHelpPor := {"Client/Fornecedor"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBT_+"CLIFOR",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)	
	//-------------------------------------------------------------//
	
	AADD(aSX3,{xZBT,"",xZBT_+"LOJA",;
		"C",nTamLoja,0,;
		"Lj Cli/For","Lj Cli/For","Lj Cli/For",;
		"Loja Cli/For","Loja Cli/For","Loja Cli/For",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","002",;
		"",""})
	aPHelpPor := {"Loja Cliente ou Fornecedor"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBT_+"LOJA",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)	
	//-------------------------------------------------------------//
	
	AADD(aSX3,{xZBT,"",xZBT_+"TIPOFO",;
		"C",01,0,;
		"Tipo Cli/For","Tipo Cli/For","Tipo Cli/For",;
		"Tipo Cli/For","Tipo Cli/For","Tipo Cli/For",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"C=Cliente;F=Fornecedor",;
		"","","",;
		"",""})
	aPHelpPor := {"Tipo: C=Cliente ou F=Fornecedor"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBT_+"TIPOFO",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)	 
	//-------------------------------------------------------------//
	AADD(aSX3,{xZBT,"",xZBT_+"PEDIDO",;
		"C",60,0,;		//"C",06,0,; //FR - 03/01/2020 - alterado o tamanho por solicitação de Aguas do Br para conter mais pedidos
		"Ped.Compra","Ped.Compra","Ped.Compra",;
		"Pedido de Compra","Pedido de Compra","Pedido de Compra",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Pedido de Compra"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBT_+"PEDIDO",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//-------------------------------------------------------------//
	
	AADD(aSX3,{xZBT,"",xZBT_+"ITEMPC",;
		"C",nTamIte,0,;
		"Item Pedido","Item Pedido","Item Pedido",;
		"Item Pedido de Compra","Item Pedido de Compra","Item Pedido de Compra",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Item Pedido de Compra"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBT_+"ITEMPC",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//-------------------------------------------------------------//		
	
	AADD(aSX3,{xZBT,"",xZBT_+"CHAVE",;
		"C",60,0,;
		"Chave","Chave","Chave",;
		"Chave do XML","Chave do XML","Chave do XML",;	
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Chave do XML"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBT_+"CHAVE",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//-------------------------------------------------------------//
	
	AADD(aSX3,{xZBT,"",xZBT_+"NOTA",;
		"C",nTamDoc,0,;
		"Doc Origem","Doc Origem","Doc Origem",;
		"Doc Origem","Doc Origem","Doc Origem",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","018",;
		"",""})
	aPHelpPor := {"Nota Fiscal/Original"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBT_+"NOTA",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//-------------------------------------------------------------//
	
	AADD(aSX3,{xZBT,"",xZBT_+"SERIE",;
		"C",03,0,;
		"Serie Orig","Serie Orig","Serie Orig",;
		"Serie NF Ori","Serie NF Ori","Serie NF Ori",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Serie NF Origem"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBT_+"SERIE",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//-------------------------------------------------------------//
	
	AADD(aSX3,{xZBT,"",xZBT_+"ITEMNF",;		//FR - 18/09/2021 - irá gravar neste campo após a geração da NF , pois pode ser que o item do XML não seja o mesmo item da NF depois de gerada
		"C",04,0,;
		"It.NF Gera","It.NF Gera","It.NF Gera",;
		"It.NF Gerada","It.NF Gerada","It.NF Gerada",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Item da NF Gerada"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBT_+"ITEMNF",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//-------------------------------------------------------------//
	//-------------------------------------------------------------------------------------------------------------------------------------//
	//FR - 15/02/2021 - #6166 - MaxiRubber - criar campo CHAVE DA NF ORIGEM -> ZBT_CHAVEO
	//No item do XML, esse campo refere-se a chave da nota original, em caso de CTE, não será a mesma chave da nota mãe (CTE),
	//cujo campo ZBT_CHAVE existente, refere-se à chave da nota mãe, e houve confusão de entendimento deste campo
	//por parte de alguns clientes, inclusive MaxiRubber que abriu este chamado,
	//por isso, resolvi criar este novo campo, para ficar mais claro, o que é a chave da nota mãe, e o que é a chave das notas que estão
	//dentro do Cte (nfs origem)
	//-------------------------------------------------------------------------------------------------------------------------------------//
	AADD(aSX3,{xZBT,"",xZBT_+"CHAVEO",;		//FR - 15/02/2021 - #6166 - MaxiRubber - NOVO CAMPO, chave da nf original (CTE)
		"C",60,0,;
		"Chave NF Ori","Chave NF Ori","Chave NF Ori",;
		"Chave NF Origem ","Chave NF Origem","Chave NF Origem",;	
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Chave NF Origem"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBT_+"CHAVEO",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//-------------------------------------------------------------//
	AADD(aSX3,{xZBT,"",xZBT_+"DEPARA",;
		"C",nTamProd,0,;
		"Produto","Produto","Produto",;					//FR - 13/04/2021 - Alterado nome do campo para ficar visível o que é o código produto fornecedor em relação ao campo ZBT_DEPARA (que é o código interno do produto)
		"Prod.Interno","Prod.Interno","Prod.Interno",;	//FR - 13/04/2021 - Alterado nome do campo para ficar visível o que é o código produto fornecedor em relação ao campo ZBT_DEPARA (que é o código interno do produto)
		"","",X3_USADO_EMUSO,;
		"","SB1",0,;			//"","",0,;		//FR - 10/03/2021 - inserida consulta padrão SB1 para o campo "DEPARA"
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Opção De/Para"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBT_+"DEPARA",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//-------------------------------------------------------------//	
	
	AADD(aSX3,{xZBT,"",xZBT_+"CSTORI",;
		"N",01,0,;				//"N",12,2,; //FR - 10/01/2020 - solicitado por Aguas do BR
		"CST Origem","CST Origem","CST Origem",;
		"CST Origem","CST Origem","CST Origem",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"CST Origem"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBT_+"CSTORI",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)	
	
	//-------------------------------------------------------------//	
	//INICIO IMPOSTOS
	// ICMS
	//-------------------------------------------------------------//	
	
	AADD(aSX3,{xZBT,"",xZBT_+"ICMCST",;
		"C",02,0,;				//"N",12,2,; //FR - 25/01/2020 - Ajuste de Projeto Fiscal  
		"CST Icms","CST Icms","CST Icms",;
		"CST Icms","CST Icms","CST Icms",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"CST Icms"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBT_+"ICMCST",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)	

	//-------------------------------------------------------------//	
	
	AADD(aSX3,{xZBT,"",xZBT_+"ICMBAS",;
		"N",12,2,;				
		"Base Icms","Base Icms","Base Icms",;
		"Base Icms","Base Icms","Base Icms",;
		"@E 999,999,999.99","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Base Icms"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBT_+"ICMBAS",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)	

	//-------------------------------------------------------------//	
	
	AADD(aSX3,{xZBT,"",xZBT_+"ICMALQ",;
		"N",12,2,;				
		"Aliq. Icms","Aliq. Icms","Aliq. Icms",;
		"Aliq. Icms","Aliq. Icms","Aliq. Icms",;
		"@E 999,999,999.99","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Aliq. Icms"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBT_+"ICMALQ",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)	

	//-------------------------------------------------------------//	
	
	AADD(aSX3,{xZBT,"",xZBT_+"ICMVAL",;
		"N",12,2,;				
		"Valor Icms","Valor Icms","Valor Icms",;
		"Valor Icms","Valor Icms","Valor Icms",;
		"@E 999,999,999.99","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Valor Icms"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBT_+"ICMVAL",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)	

	//-------------------------------------------------------------//	
	// ISS
	
	AADD(aSX3,{xZBT,"",xZBT_+"ISSALQ",;
		"N",12,2,;				
		"Aliq. Iss","Aliq. Iss","Aliq. Iss",;
		"Aliq. Iss","Aliq. Iss","Aliq. Iss",;
		"@E 999,999,999.99","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Aliq. Iss"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBT_+"ISSALQ",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)	

	//-------------------------------------------------------------//	
	
	AADD(aSX3,{xZBT,"",xZBT_+"ISSVAL",;
		"N",12,2,;				
		"Valor Iss","Valor Iss","Valor Iss",;
		"Valor Iss","Valor Iss","Valor Iss",;
		"@E 999,999,999.99","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Valor Iss"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBT_+"ISSVAL",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)	
 
	//-------------------------------------------------------------//	
	// PIS
	
	AADD(aSX3,{xZBT,"",xZBT_+"PISCST",;
		"C",02,0,;				  
		"CST PIS","CST PIS","CST PIS",;
		"CST PIS","CST PIS","CST PIS",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"CST PIS"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBT_+"PISCST",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)	

 	//-------------------------------------------------------------//	
	
	AADD(aSX3,{xZBT,"",xZBT_+"PISBAS",;
		"N",12,2,;				
		"Base PIS","Base PIS","Base PIS",;
		"Base PIS","Base PIS","Base PIS",;
		"@E 999,999,999.99","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Base PIS"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBT_+"PISBAS",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)	


	//-------------------------------------------------------------//	
	
	AADD(aSX3,{xZBT,"",xZBT_+"PISALQ",;
		"N",12,2,;				
		"Aliq. PIS","Aliq. PIS","Aliq. PIS",;
		"Aliq. PIS","Aliq. PIS","Aliq. PIS",;
		"@E 999,999,999.99","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Aliq. PIS"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBT_+"PISALQ",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)	

 	//-------------------------------------------------------------//	
	
	AADD(aSX3,{xZBT,"",xZBT_+"PISVAL",;
		"N",12,2,;				
		"Valor PIS","Valor PIS","Valor PIS",;
		"Valor PIS","Valor PIS","Valor PIS",;
		"@E 999,999,999.99","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Valor PIS"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBT_+"PISVAL",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)	

//COFINS

	//-------------------------------------------------------------//	
	// COFINS
	
	AADD(aSX3,{xZBT,"",xZBT_+"COFCST",;
		"C",02,0,;				  
		"CST COFINS","CST COFINS","CST COFINS",;
		"CST COFINS","CST COFINS","CST COFINS",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"CST COFINS"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBT_+"COFCST",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)	

 	//-------------------------------------------------------------//	
	
	AADD(aSX3,{xZBT,"",xZBT_+"COFBAS",;
		"N",12,2,;				
		"Base COFINS","Base COFINS","Base COFINS",;
		"Base COFINS","Base COFINS","Base COFINS",;
		"@E 999,999,999.99","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Base COFINS"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBT_+"COFBAS",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)	


	//-------------------------------------------------------------//	
	
	AADD(aSX3,{xZBT,"",xZBT_+"COFALQ",;
		"N",12,2,;				
		"Aliq. COFINS","Aliq. COFINS","Aliq. COFINS",;
		"Aliq. COFINS","Aliq. COFINS","Aliq. COFINS",;
		"@E 999,999,999.99","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Aliq. COFINS"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBT_+"COFALQ",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)	

 
	//-------------------------------------------------------------//	
	
	AADD(aSX3,{xZBT,"",xZBT_+"COFVAL",;
		"N",12,2,;				
		"Valor COFINS","Valor COFINS","Valor COFINS",;
		"Valor COFINS","Valor COFINS","Valor COFINS",;
		"@E 999,999,999.99","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Valor COFINS"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBT_+"COFVAL",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)	

	//-------------------------------------------------------------//	
	// CSLL
	
	AADD(aSX3,{xZBT,"",xZBT_+"CSLALQ",;
		"N",12,2,;				
		"Aliq. Csll","Aliq. Csll","Aliq. Csll",;
		"Aliq. Csll","Aliq. Csll","Aliq. Csll",;
		"@E 999,999,999.99","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Aliq. Csll"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBT_+"CSLALQ",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)	

	//-------------------------------------------------------------//	
	
	AADD(aSX3,{xZBT,"",xZBT_+"CSLVAL",;
		"N",12,2,;				
		"Valor Csll","Valor Csll","Valor Csll",;
		"Valor Csll","Valor Csll","Valor Csll",;
		"@E 999,999,999.99","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Valor Csll"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBT_+"CSLVAL",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)	

	//-------------------------------------------------------------//	
	// INSS
	
	AADD(aSX3,{xZBT,"",xZBT_+"INSALQ",;
		"N",12,2,;				
		"Aliq. Inss","Aliq. Inss","Aliq. Inss",;
		"Aliq. Inss","Aliq. Inss","Aliq. Inss",;
		"@E 999,999,999.99","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Aliq. Inss"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBT_+"INSALQ",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)	

	//-------------------------------------------------------------//	
	
	AADD(aSX3,{xZBT,"",xZBT_+"INSVAL",;
		"N",12,2,;				
		"Valor Inss","Valor Inss","Valor Inss",;
		"Valor Inss","Valor Inss","Valor Inss",;
		"@E 999,999,999.99","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Valor Inss"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBT_+"INSVAL",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)	


	//-------------------------------------------------------------//	
	// IRRF
	
	AADD(aSX3,{xZBT,"",xZBT_+"IRRALQ",;
		"N",12,2,;				
		"Aliq. Irrf","Aliq. Irrf","Aliq. Irrf",;
		"Aliq. Irrf","Aliq. Irrf","Aliq. Irrf",;
		"@E 999,999,999.99","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Aliq. Irrf"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBT_+"IRRALQ",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)	

	//-------------------------------------------------------------//	
	
	AADD(aSX3,{xZBT,"",xZBT_+"IRRVAL",;
		"N",12,2,;				
		"Valor Irrf","Valor Irrf","Valor Irrf",;
		"Valor Irrf","Valor Irrf","Valor Irrf",;
		"@E 999,999,999.99","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Valor Irrf"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBT_+"IRRVAL",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)	
	//-------------------------------------------------------------//	
	// IPI

	AADD(aSX3,{xZBT,"",xZBT_+"IPIENQ",;
		"C",03,0,;				//"N",12,2,; //FR - 25/01/2020 - Ajuste de Projeto Fiscal  
		"Enquad. IPI","Enquad. IPI","Enquad. IPI",;
		"Enquad. IPI","Enquad. IPI","Enquad. IPI",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Enqram.IPI"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBT_+"IPIENQ",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)	

	//-------------------------------------------------------------//	
	
	AADD(aSX3,{xZBT,"",xZBT_+"IPICST",;
		"C",02,0,;				//"N",12,2,; //FR - 25/01/2020 - Ajuste de Projeto Fiscal  
		"CST IPI","CST IPI","CST IPI",;
		"CST IPI","CST IPI","CST IPI",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"CST IPI"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBT_+"IPICST",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)	

	//-------------------------------------------------------------//	
	
	AADD(aSX3,{xZBT,"",xZBT_+"IPIBAS",;
		"N",12,2,;				
		"Base IPI","Base IPI","Base IPI",;
		"Base IPI","Base IPI","Base IPI",;
		"@E 999,999,999.99","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Base IPI"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBT_+"IPIBAS",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)	

	//-------------------------------------------------------------//	
	
	AADD(aSX3,{xZBT,"",xZBT_+"IPIALQ",;
		"N",12,2,;				
		"Aliq. IPI","Aliq. IPI","Aliq. IPI",;
		"Aliq. IPI","Aliq. IPI","Aliq. IPI",;
		"@E 999,999,999.99","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Aliq. IPI"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBT_+"IPIALQ",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)	

	//-------------------------------------------------------------//	
	
	AADD(aSX3,{xZBT,"",xZBT_+"IPIVAL",;
		"N",12,2,;				
		"Valor IPI","Valor IPI","Valor IPI",;
		"Valor IPI","Valor IPI","Valor IPI",;
		"@E 999,999,999.99","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Valor IPI"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBT_+"IPIVAL",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	
	//-------------------------------------------------------------//	
	
	AADD(aSX3,{xZBT,"",xZBT_+"VLDESC",;                         //FR - 19/04/2021 - novo campo valor desconto
		"N",12,2,;				
		"Vlr Descon","Vlr Descon","Vlr Descon",;
		"Vlr Desconto","Vlr Desconto","Vlr Desconto",;
		"@E 999,999,999.99","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Valor Desconto"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBT_+"VLDESC",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	
	//-------------------------------------------------------------//
	
	AADD(aSX3,{xZBT,"",xZBT_+"NFCI",;							//FR - 19/04/2021 - Novo campo
		"C",120,0,;
		"NFCI","NFCI","NFCI",;
		"Cod. NFCI","Cod. NFCI","Cod. NFCI",;	
		"","",X3_USADO_EMUSO,;
		"","",0,;    
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Codigo NFCI"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBT_+"NFCI",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)		
	
	//-------------------------------------------------------------//
	AADD(aSX3,{xZBT,"",xZBT_+"LOTE",;							//FR - 28/04/2021 - Novo campo
		"C",60,0,;
		"Num.Lote","Num.Lote","Num.Lote",;
		"Num.Lote","Num.Lote","Num.Lote",;	
		"","",X3_USADO_EMUSO,;
		"","",0,;    
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Numero Lote"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBT_+"LOTE",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)	
	
	//-------------------------------------------------------------//
	
	AADD(aSX3,{xZBT,"",xZBT_+"DVLOTE",;							//FR - 28/04/2021 - Novo campo
		"D",08,0,;
		"Dt.Val.Lote","Dt.Val.Lote","Dt.Val.Lote",;
		"Dt.Val.Lote","Dt.Val.Lote","Dt.Val.Lote",;	
		"","",X3_USADO_EMUSO,;
		"","",0,;    
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Dt.Validade Lote"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBT_+"DVLOTE",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)	
	
	//-------------------------------------------------------------//
	
	AADD(aSX3,{xZBT,"",xZBT_+"ANOFAB",;							
		"C",02,0,;
		"Ano Fabric.","Ano Fabric.","Ano Fabric.",;
		"Ano Fabric.","Ano Fabric.","Ano Fabric.",;	
		"","",X3_USADO_EMUSO,;
		"","",0,;    
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Ano Fabricação"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBT_+"ANOFAB",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)	
	
	//-------------------------------------------------------------//	
	//FR - 11/01/2022 - Petra - incluir campo ICMST
	AADD(aSX3,{xZBT,"",xZBT_+"STBASE",;
		"N",14,2,;				
		"Base ICMST","Base ICMST","Base ICMST",;
		"Base ICMST","Base ICMST","Base ICMST",;
		"@E 999,999,999.99","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Base ICMST"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBT_+"STBASE",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)	

	//-------------------------------------------------------------//	
	
	AADD(aSX3,{xZBT,"",xZBT_+"STALIQ",;
		"N",06,2,;				
		"Aliq.ICMST","Aliq.ICMST","Aliq.ICMST",;
		"Aliq.ICMST","Aliq.ICMST","Aliq.ICMST",;
		"@E 999.99","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Aliq. ICM ST"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBT_+"STALIQ",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)	

	//-------------------------------------------------------------//	
	
	AADD(aSX3,{xZBT,"",xZBT_+"STVALO",;
		"N",14,2,;				
		"Val.ICMST","Val.ICMST","Val.ICMST",;
		"Val.ICMST","Val.ICMST","Val.ICMST",;
		"@E 999,999,999.99","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Valor ICM ST"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBT_+"STVALO",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)	

	//------------------------------------------------------------//                                                           
	//FR - 16/05/2023 - CHAMADO ELECON #14880
	//     Criar campo CFOP no item do XML
	//

	nTAMCFOP := TAMSX3("D1_CF")[1]
	
	AADD(aSX3,{xZBT,"",xZBT_+"CFOP",;
	"C",nTAMCFOP,0,;
	"CFOP","CFOP","CFOP",;
	"CFOP","CFOP","CFOP",;
	"@X","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","V",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"CFOP da NF"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBT_+"CFOP",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         
	
	
	//-------------------------------------------------------------//
	//Fim ZBT 
	//-------------------------------------------------------------//
	
	//-------------------------------------------------------------//
	//Inicio ZBM 
	//-------------------------------------------------------------//

	AADD(aSX3,{xZBM,"",xZBM_+"FILIAL",;
		"C",nTamFil,0,;  			//"C",02,0,;			//FR - 24/11/2020
		"Filial","Filial","Filial",;
		"Filial do Sistema","Filial do Sistema","Filial do Sistema",;
		"@!","",X3_USADO_NAOUSADO,;
		"","",0,;
		"","","",;
		"U","N","V",;
		"R","","",;
		"","","",;
		"","","033",;
		"",""})
	aPHelpPor := {"Filial do Sistema"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBM_+"FILIAL",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 

	//-------------------------------------------------------------// 
	AADD(aSX3,{xZBM,"",xZBM_+"COD",;
		"C",7,0,;
		"Codigo IBGE","Codigo IBGE","Codigo IBGE",;
		"Codigo do IBGE","Codigo do IBGE","Codigo do IBGE",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Codigo do IBGE"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBM_+"COD",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//-------------------------------------------------------------//
	
	AADD(aSX3,{xZBM,"",xZBM_+"MUNIC",;
		"C",60,0,;
		"Nome Municipio","Nome Municipio","Nome Municipio",;
		"Nome do Municipio","Nome do Municipio","Nome do Municipio",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Nome do Municipio"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBM_+"MUNIC",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//-------------------------------------------------------------//

	AADD(aSX3,{xZBM,"",xZBM_+"EST",;
		"C",02,0,;
		"Estado","Estado","Estado",;
		"Estado","Estado","Estado",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Estado"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBM_+"EST",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//-------------------------------------------------------------//

	AADD(aSX3,{xZBM,"",xZBM_+"DATA",;
		"D",08,0,;
		"Data Ult Ver","Data Ult Ver","Data Ult Ver",;
		"Data da Ultima Verificacao","Data da Ultima Verificacao","Data da Ultima Verificacao",;
		"@D","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Data da Ultima Verificacao"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBM_+"DATA",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//-------------------------------------------------------------//
	AADD(aSX3,{xZBM,"",xZBM_+"ATIVO",;
		"C",1,0,;
		"Ativo","Ativo","Ativo",;
		"Municipio Ativos","Municipio Ativos","Municipio Ativos",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"1=Sim;2=Não","1=Sim;2=Não","1=Sim;2=Não",;
		"","","",;
		"",""})
	aPHelpPor := {"Municipio Ativos"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBM_+"LINK",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//-------------------------------------------------------------//
	AADD(aSX3,{xZBM,"",xZBM_+"QUANT",;
		"N",9,0,;
		"Quantidade","Quantidade","Quantidade",;
		"Quantidade de Notas","Quantidade de Notas","Quantidade de Notas",;
		"@E 999,999,999","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Quantidade de Notas da consulta"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBM_+"LINK",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//-------------------------------------------------------------//
	AADD(aSX3,{xZBM,"",xZBM_+"PREST",;
		"C",1,0,;
		"Prestador","Prestador","Prestador",;
		"Necessita Prestador","Necessita Prestador","Necessita Prestador",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"1=Sim;2=Não","1=Sim;2=Não","1=Sim;2=Não",;
		"","","",;
		"",""})
	aPHelpPor := {"Informe se necessita de dados do prestador na consulta"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBM_+"PREST",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//-------------------------------------------------------------//
	AADD(aSX3,{xZBM,"",xZBM_+"USER",;
		"C",60,0,;
		"Usuario","Usuario","Usuario",;
		"Usuario Portal","Usuario Portal","Usuario Portal",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Usuario Portal Prefeitura"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBM_+"USER",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//-------------------------------------------------------------//
	AADD(aSX3,{xZBM,"",xZBM_+"PSW",;
		"C",60,0,;
		"Senha","Senha","Senha",;
		"Senha Portal","Senha Portal","Senha Portal",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Senha Portal Prefeitura"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBM_+"PSW",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//-------------------------------------------------------------//
	AADD(aSX3,{xZBM,"",xZBM_+"STATUS",;
		"C",20,0,;
		"Status","Status","Status",;
		"Status da Consulta","Status da Consulta","Status da Consulta",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Status da Consulta"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBM_+"STATUS",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//-------------------------------------------------------------//
	AADD(aSX3,{xZBM,"",xZBM_+"JOB",;
		"C",1,0,;
		"Apenas Job","Apenas Job","Apenas Job",;
		"Informe se será executado apenas no Job","Informe se será executado apenas no Job","Informe se será executado apenas no Job",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"1=Sim;2=Não","1=Sim;2=Não","1=Sim;2=Não",;
		"","","",;
		"",""})
	aPHelpPor := {"Informe se será executado apenas no Job"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBM_+"PREST",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//-------------------------------------------------------------//
	AADD(aSX3,{xZBM,"",xZBM_+"CFG",;
	"M",10,0,;
	"Configuração","Configuração","Configuração",;
	"Configuração","Configuração","Configuração",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","V",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"Configuracao"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBM_+"CFG",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//   
	AADD(aSX3,{xZBM,"",xZBM_+"OBRTMIN",;
		"C",1,0,;
		"Obr Ins Tom","Obr Ins Tom","Obr Ins Tom",;
		"Obrigatorio Inscrição do Tomador","Obrigatorio Inscrição do Tomador","Obrigatorio Inscrição do Tomador",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"1=Sim;2=Não","1=Sim;2=Não","1=Sim;2=Não",;
		"","","",;
		"",""})
	aPHelpPor := {"Se é obrigatorio inscrição do tomador"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBM_+"OBRTMIN",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//-------------------------------------------------------------//
	AADD(aSX3,{xZBM,"",xZBM_+"OBRTMCG",;
		"C",1,0,;
		"Obr Cgc Tom","Obr Cgc Tom","Obr Cgc Tom",;
		"Obrigatorio Cgc do Tomador","Obrigatorio Cgc do Tomador","Obrigatorio Cgc do Tomador",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"1=Sim;2=Não","1=Sim;2=Não","1=Sim;2=Não",;
		"","","",;
		"",""})
	aPHelpPor := {"Se é obrigatorio cgc do tomador"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBM_+"OBRTMCG",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//-------------------------------------------------------------//
	AADD(aSX3,{xZBM,"",xZBM_+"OBRPRIN",;
		"C",1,0,;
		"Obr Ins Pr","Obr Ins Pr","Obr Ins Pr",;
		"Obrigatorio Inscrição do Prestador","Obrigatorio Inscrição do Prestador","Obrigatorio Inscrição do Prestador",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"1=Sim;2=Não","1=Sim;2=Não","1=Sim;2=Não",;
		"","","",;
		"",""})
	aPHelpPor := {"Se é obrigatorio inscrição do Prestador"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBM_+"OBRPRIN",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//-------------------------------------------------------------//
	AADD(aSX3,{xZBM,"",xZBM_+"OBRPRCG",;
		"C",1,0,;
		"Obr Cgc Pr","Obr Cgc Pr","Obr Cgc Pr",;
		"Obrigatorio Cgc do Prestador","Obrigatorio Cgc do Prestador","Obrigatorio Cgc do Prestador",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"1=Sim;2=Não","1=Sim;2=Não","1=Sim;2=Não",;
		"","","",;
		"",""})
	aPHelpPor := {"Se é obrigatorio Cgc do prestador"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBM_+"OBRPRCG",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//-------------------------------------------------------------//
	AADD(aSX3,{xZBM,"",xZBM_+"JOB",;
		"C",1,0,;
		"Apenas Job","Apenas Job","Apenas Job",;
		"Informe se será executado apenas no Job","Informe se será executado apenas no Job","Informe se será executado apenas no Job",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"1=Sim;2=Não","1=Sim;2=Não","1=Sim;2=Não",;
		"","","",;
		"",""})
	aPHelpPor := {"Informe se será executado apenas no Job"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBM_+"JOB",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//-------------------------------------------------------------//	

	//-------------------------------------------------------------//
	//Fim ZBM 
	//-------------------------------------------------------------//

	//-------------------------------------------------------------//
	//Inicio ZBN
	//-------------------------------------------------------------//

	AADD(aSX3,{xZBN,"",xZBN_+"FILIAL",;
		"C",nTamFil,0,;		//"C",02,0,;		//FR - 24/11/2020
		"Filial","Filial","Filial",;
		"Filial do Sistema","Filial do Sistema","Filial do Sistema",;
		"@!","",X3_USADO_NAOUSADO,;
		"","",0,;
		"","","",;
		"U","N","V",;
		"R","","",;
		"","","",;
		"","","033",;
		"",""})
	aPHelpPor := {"Filial do Sistema"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBN_+"FILIAL",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 

	//-------------------------------------------------------------// 
	AADD(aSX3,{xZBN,"",xZBN_+"COD",;
		"C",7,0,;
		"Codigo IBGE","Codigo IBGE","Codigo IBGE",;
		"Codigo do IBGE","Codigo do IBGE","Codigo do IBGE",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Codigo do IBGE"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBN_+"COD",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//-------------------------------------------------------------//
	AADD(aSX3,{xZBN,"",xZBN_+"FORNEC",;
		"C",nTamCod,0,;
		"Cod. Fornec.","Cod. Fornec.","Cod. Fornec.",;
		"Codigo do Fornecedor","Codigo do Fornecedor","Codigo do Fornecedor",;
		"@!","",X3_USADO_EMUSO,;
		"","SA2ZB5",0,;
		"","","S",;
		"U","S","V",;
		"R","","vazio() .or. existcpo('SA2',M->"+xZBN_+"FORNEC,1)",;
		"","","",;
		"","","001",;
		"",""})		
	aPHelpPor := {"Codigo do Fornecedor"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBN_+"FORNEC",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//                                                         
	AADD(aSX3,{xZBN,"",xZBN_+"LOJFOR",;
		"C",nTamLoja,0,;
		"Loja Fornec.","Loja Fornec.","Loja Fornec.",;
		"Loja do Fornecedor","Loja do Fornecedor","Loja do Fornecedor",;
		"@!","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","002",;
		"",""})	
	aPHelpPor := {"Loja do Fornecedor"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBN_+"LOJFOR",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//                                                         	                 
	AADD(aSX3,{xZBN,"",xZBN_+"DATA",;
		"D",08,0,;
		"Data","Data","Data",;
		"Data da Verificacao","Data da Verificacao","Data da Verificacao",;
		"@D","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Data da Verificacao"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBN_+"DATA",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//-------------------------------------------------------------//
	AADD(aSX3,{xZBN,"",xZBN_+"STATUS",;
		"C",20,0,;
		"Status","Status","Status",;
		"Status da Consulta","Status da Consulta","Status da Consulta",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Status da Consulta"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBN_+"STATUS",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//-------------------------------------------------------------//
	AADD(aSX3,{xZBN,"",xZBN_+"LINK",;
		"C",254,0,;
		"Link","Link","Link",;
		"Link de Consulta","Link de Consulta","Link de Consulta",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Link de Consulta"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBN_+"LINK",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//-------------------------------------------------------------//
	AADD(aSX3,{xZBN,"",xZBN_+"QUANT",;
		"N",9,0,;
		"Quantidade","Quantidade","Quantidade",;
		"Quantidade de Notas","Quantidade de Notas","Quantidade de Notas",;
		"@E 999,999,999","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Quantidade de Notas da consulta"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBN_+"LINK",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//-------------------------------------------------------------//
		AADD(aSX3,{xZBN,"",xZBN_+"MSG",;
		"C",254,0,;
		"Mensagem","Mensagem","Mensagem",;
		"Mensagem","Mensagem","Mensagem",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Mensagem"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBN_+"MSG",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//-------------------------------------------------------------//
	AADD(aSX3,{xZBN,"",xZBN_+"REQ",;
	"M",10,0,;
	"Requisicao","Requisicao","Requisicao",;
	"Requisicao","Requisicao","Requisicao",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","V",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"Requisicao"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBN_+"REQ",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//   
	//Fim ZBN
	//-------------------------------------------------------------//
	
	//-------------------------------------------------------------//
	//Inicio ZBD
	//-------------------------------------------------------------//

	AADD(aSX3,{xZBD,"",xZBD_+"FILIAL",;
		"C",02,0,;
		"Filial","Filial","Filial",;
		"Filial do Sistema","Filial do Sistema","Filial do Sistema",;
		"@!","",X3_USADO_NAOUSADO,;
		"","",0,;
		"","","",;
		"U","N","V",;
		"R","","",;
		"","","",;
		"","","033",;
		"",""})
	aPHelpPor := {"Filial do Sistema"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBD_+"FILIAL",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 

	//-------------------------------------------------------------// 
	AADD(aSX3,{xZBD,"",xZBD_+"ID",;
		"C",20,0,;
		"ID","ID","ID",;
		"ID Image Converter","ID Image Converter","ID Image Converter",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"ID Image Converter"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBD_+"ID",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//-------------------------------------------------------------// 
	AADD(aSX3,{xZBD,"",xZBD_+"ARQUIV",;
		"C",254,0,;
		"Arquivo","Arquivo","Arquivo",;
		"Nome do Arquivo","Nome do Arquivo","Nome do Arquivo",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Nome do Arquivo"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBD_+"ARQUIV",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 	
	//-------------------------------------------------------------// 
	AADD(aSX3,{xZBD,"",xZBD_+"TAM",;
		"C",20,0,;
		"Tamanho","Tamanho","Tamanho",;
		"Tamanho do Arquivo","Tamanho do Arquivo","Tamanho do Arquivo",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Tamanho do Arquivo"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBD_+"TAM",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 	
	//-------------------------------------------------------------// 
	AADD(aSX3,{xZBD,"",xZBD_+"STATUS",;
		"C",20,0,;
		"Status","Status","Status",;
		"Status","Status","Status",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Status"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBD_+"STATUS",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 	
	//-------------------------------------------------------------// 
	AADD(aSX3,{xZBD,"",xZBD_+"LOG",;
		"C",254,0,;
		"Log","Log","Log",;
		"Log","Log","Log",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Log"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBD_+"LOG",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//-------------------------------------------------------------// 
	AADD(aSX3,{xZBD,"",xZBD_+"OK",;
		"C",1,0,;
		"Flag","Flag","Flag",;
		"Flag","Flag","Flag",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Flag"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBD_+"OK",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//-------------------------------------------------------------// 
	AADD(aSX3,{xZBD,"",xZBD_+"PDFON",;
		"C",1,0,;
		"PDF Online","PDF Online","PDF Online",;
		"PDF Online","PDF Online","PDF Online",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"1=Sim;2=Não","1=Sim;2=Não","1=Sim;2=Não",;
		"","","",;
		"",""})
	aPHelpPor := {"Flag"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBD_+"PDFON",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//-------------------------------------------------------------//
	AADD(aSX3,{xZBD,"",xZBD_+"DATAUP",;
		"C",20,0,;
		"Data Upload","Data Upload","Data InUploadteg",;
		"Data Upload","Data Upload","Data Upload",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	//-------------------------------------------------------------//
	AADD(aSX3,{xZBD,"",xZBD_+"DATAIN",;
		"C",20,0,;
		"Data Conver","Data Conver","Data Conver",;
		"Data Conversao","Data Conversao","Data Conversao",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	//-------------------------------------------------------------//
	AADD(aSX3,{xZBD,"",xZBD_+"DATADO",;
		"C",20,0,;
		"Data Download","Data Download","Data Download",;
		"Data Download","Data Download","Data Download",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	//-------------------------------------------------------------//

	//-------------------------------------------------------------//
	//Fim ZBD
	//-------------------------------------------------------------//

	//-------------------------------------------------------------//		
	//Inicio ZBF
	//-------------------------------------------------------------//

	AADD(aSX3,{xZBF,"",xZBF_+"FILIAL",;
		"C",02,0,;
		"Filial","Filial","Filial",;
		"Filial do Sistema","Filial do Sistema","Filial do Sistema",;
		"@!","",X3_USADO_NAOUSADO,;
		"","",0,;
		"","","",;
		"U","N","V",;
		"R","","",;
		"","","",;
		"","","033",;
		"",""})
	aPHelpPor := {"Filial do Sistema"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBF_+"FILIAL",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 

	//-------------------------------------------------------------// 
	AADD(aSX3,{xZBF,"",xZBF_+"CHAVE",;
		"C",44,0,;
		"Chave","Chave","Chave",;
		"Chave","Chave","Chave",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Chave"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBF_+"CHAVE",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//-------------------------------------------------------------// 
		AADD(aSX3,{xZBF,"",xZBF_+"NUMCON",;
		"N",3,0,;
		"Num Consulta","Num Consulta","Num Consulta",;
		"Num. Consulta","Num. Consulta","Num. Consulta",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Num. Consulta"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBF_+"NUMCONS",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//-------------------------------------------------------------// 
		AADD(aSX3,{xZBF,"",xZBF_+"DATA",;
		"D",8,0,;
		"Data","Data","Data",;
		"Data Consulta","Data Consulta","Data Consulta",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Data Consulta"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBF_+"DATA ",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//-------------------------------------------------------------// 
		AADD(aSX3,{xZBF,"",xZBF_+"HORA",;
		"C",8,0,;
		"Hora","Hora","Hora",;
		"Hora Consulta","Hora Consulta","Hora Consulta",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Hora Consulta"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBF_+"HORA ",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//-------------------------------------------------------------// 
		AADD(aSX3,{xZBF,"",xZBF_+"ROTINA",;
		"C",15,0,;
		"Rotina","Rotina","Rotina",;
		"Rotina Consulta","Rotina Consulta","Rotina Consulta",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Rotina Consulta"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBF_+"ROTINA ",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//-------------------------------------------------------------//
	//Fim ZBF
	//-------------------------------------------------------------//
	
	//-------------------------------------------------------------//
	//Inicio ZBG 
	//Tabela Log Consulta Situação Fornecedor (via api) 
	//Grava nesta tabela mediante parametrização 
	//liga/desliga: XM_LOGFORN
	//-------------------------------------------------------------//
	AADD(aSX3,{xZBG,"",xZBG_+"FILIAL",;
		"C",nTamFil,0,;  			
		"Filial","Filial","Filial",;
		"Filial do Sistema","Filial do Sistema","Filial do Sistema",;
		"@!","",X3_USADO_NAOUSADO,;
		"","",0,;
		"","","",;
		"U","N","V",;
		"R","","",;
		"","","",;
		"","","033",;
		"",""})
	aPHelpPor := {"Filial do Sistema"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBG_+"FILIAL",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	
	//-------------------------------------------------------------// 
	
	AADD(aSX3,{xZBG,"",xZBG_+"CHAVE",;
		"C",44,0,;
		"Chave","Chave","Chave",;
		"Chave","Chave","Chave",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","V",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Chave"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBG_+"CHAVE",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)	
	//-------------------------------------------------------------//
	
	AADD(aSX3,{xZBG,"",xZBG_+"CNPJ",;
	"C",14,0,;
	"CNPJ Emit.","CNPJ Emit.","CNPJ Emit.",;
	"CNPJ Fornec.","CNPJ Fornec.","CNPJ Fornec.",;
	"@X","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","A",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"CNPJ do Fornecedor"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBG_+"CNPJ",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 	
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZBG,"",xZBG_+"FORNEC",;
	"C",60,0,;
	"R. Social","R. Social","R. Social",;
	"Razao Social","Razao Social","Razao Social",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","A",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"Razao Social do Fornecedor"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBG_+"FORNEC",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	
	//------------------------------------------------------------//                                                         
	
	AADD(aSX3,{xZBG,"",xZBG_+"SITUAC",;
	"C",30,0,;
	"Situação","Situação","Situação",;
	"Razao Social","Razao Social","Razao Social",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","A",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"Razao Social do Fornecedor"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBG_+"FORNEC",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	
	//------------------------------------------------------------//	                                                      
	
	AADD(aSX3,{xZBG,"",xZBG_+"URL",;
	"C",60,0,;
	"URL.Consul","URL.Consul","URL.Consul",;
	"URL.Consulta","URL.Consulta","URL.Consulta",;
	"@!","",X3_USADO_EMUSO,;
	"","",0,;
	"","","S",;
	"U","S","A",;
	"R","","",;
	"","","",;
	"","","",;
	"",""})
	
	aPHelpPor := {"URL Consulta"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBG_+"URL",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//------------------------------------------------------------//
	
	AADD(aSX3,{xZBG,"",xZBG_+"DTCONS",;
		"D",8,0,;
		"Dt.Consulta","Dt.Consulta","Dt.Consulta",;
		"Dt.Consulta","Dt.Consulta","Dt.Consulta",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Data Consulta"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBG_+"DTCONS",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	
	//------------------------------------------------------------//
	
	AADD(aSX3,{xZBG,"",xZBG_+"HRCONS",;
		"C",8,0,;
		"HR.Consulta","HR.Consulta","HR.Consulta",;
		"HR.Consulta","HR.Consulta","HR.Consulta",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Hora Consulta"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBG_+"HRCONS",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)
	//-------------------------------------------------------------//
	//Fim ZBG
	//-------------------------------------------------------------//

	//-------------------------------------------------------------//
	//Inicio ZBH
	//-------------------------------------------------------------//
	AADD(aSX3,{xZBH,"",xZBH_+"FILIAL",;
		"C",nTamFil,0,;		//"C",02,0,;		//FR - 24/11/2020
		"Filial","Filial","Filial",;
		"Filial do Sistema","Filial do Sistema","Filial do Sistema",;
		"@!","",X3_USADO_NAOUSADO,;
		"","",0,;
		"","","",;
		"U","N","V",;
		"R","","",;
		"","","",;
		"","","033",;
		"",""})
	aPHelpPor := {"Filial do Sistema"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBH_+"FILIAL",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//-------------------------------------------------------------// 
	AADD(aSX3,{xZBH,"",xZBH_+"COD",;
		"C",3,0,;
		"Cod. Motivo","Cod. Motivo","Cod. Motivo",;
		"Codigo do Motivo","Codigo do Motivo","Codigo do Motivo",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Codigo do Motivo"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBH_+"COD",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//-------------------------------------------------------------//
	AADD(aSX3,{xZBH,"",xZBH_+"DESC",;
		"C",254,0,;
		"Desc. Motivo","Desc. Motivo","Desc. Motivo",;
		"Descrição do Motivo","Descrição do Motivo","Descrição do Motivo",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"","","",;
		"","","",;
		"",""})
	aPHelpPor := {"Descrição do Motivo"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBH_+"DESC",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//-------------------------------------------------------------//
	AADD(aSX3,{xZBH,"",xZBH_+"ATIVO",;
		"C",1,0,;
		"Ativo","Ativo","Ativo",;
		"Ativo","Ativo","Ativo",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"1=Sim;2=Não","1=Sim;2=Não","1=Sim;2=Não",;
		"","","",;
		"",""})
	aPHelpPor := {"Flag"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBH_+"ATIVO",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//-------------------------------------------------------------//
	AADD(aSX3,{xZBH,"",xZBH_+"TIPO",;
		"C",1,0,;
		"Tipo Ocorrencia","Tipo Ocorrencia","Tipo Ocorrencia",;
		"Tipo de Ocorrencia","Tipo de Ocorrencia","Tipo de Ocorrencia",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","S","A",;
		"R","","",;
		"1=Devolução;2=Beneficiamento;3=Transferência","1=Devolução;2=Beneficiamento;3=Transferência","1=Devolução;2=Beneficiamento;3=Transferência",;
		"","","",;
		"",""})
	aPHelpPor := {"Tipo Ocorrencia"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+xZBH_+"TIPO",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//------------------------------------------------------------//   
	//Fim ZBH
	//-------------------------------------------------------------//

	//-------------------------------------------------------------//
	//Inicio SA2
	//-------------------------------------------------------------//
	AADD(aSX3,{"SA2","","A2_"+"XHFPRES",;
		"C",1,0,;
		"Prest. Nfse","Prest. Nfse","Prest. Nfse",;
		"Será considerado esse fornecedor na consulta Nfs-e","Será considerado esse fornecedor na consulta Nfs-e","Será considerado esse fornecedor na consulta Nfs-e",;
		"","",X3_USADO_EMUSO,;
		"","",0,;
		"","","S",;
		"U","N","A",;
		"R","","",;
		"1=Sim;2=Não","1=Sim;2=Não","1=Sim;2=Não",;
		"","","",;
		"",""})
	aPHelpPor := {"Será considerado esse fornecedor na consulta Nfs-e"}
	aPHelpEng := aPHelpPor
	aPHelpSpa := aPHelpPor
	PutHelp("P"+"SA2"+"XHFPRES",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
	//-------------------------------------------------------------//
	//Fim SA2
	//-------------------------------------------------------------//

	//-------------------------------------------------------------//		
	//Fim campos SX3
	//-------------------------------------------------------------//
	cCpo      := ""
	cCpoAlter := ""
	cAliaAlter:= ""          //FR - 18/08/2020
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Alterações de campo                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SX3")
		SX3->(dbSetOrder(2))
		If dbSeek(xZBZ_+"LOJFOR") 
			cCpo := xZBZ_+"LOJFOR"
			If SX3->X3_TAMANHO <> nTamLoja 
				RecLock("SX3",.F.)
				SX3->X3_TAMANHO := nTamLoja
				MsUnLock()
				aAdd(aAlterTb,xZBZ)			
				If !(cCpo $ cCpoAlter)
					cCpoAlter  += cCpo + "/"  //Log do campo alterado para exibir no final //FR - 10/03/2020
				Endif 
				If !(SX3->X3_ARQUIVO $ cAliaAlter)
					cAliaAlter  += SX3->X3_ARQUIVO + "/"  //Log da tabela alterada para exibir no final //FR - 18/08/2020
				Endif			
			EndIF                                                                                     
		EndIf
		
		If dbSeek(xZBZ_+"MODELO") 
			cCpo := xZBZ_+"MODELO" 
			If AllTrim(SX3->X3_CBOX) <> "55=NF-e;RP=NFS-e Txt;57=CT-e;65=NFCe;67=CTeOS"
				RecLock("SX3",.F.)
				SX3->X3_CBOX := "55=NF-e;RP=NFS-e Txt;57=CT-e;65=NFCe;67=CTeOS"
				MsUnLock()
				aAdd(aAlterTb,xZBZ)
				If !(cCpo $ cCpoAlter)
					cCpoAlter  += cCpo + "/"  //Log do campo alterado para exibir no final //FR - 10/03/2020
				Endif
			EndIF
		EndIf   
	
		If dbSeek(xZBZ_+"TPDOWL") 
			cCpo := xZBZ_+"TPDOWL"
			If AllTrim(SX3->X3_CBOX) <> " =Completo;R=Resumido;I=Indisponivel"//o CTe"
				RecLock("SX3",.F.)
				SX3->X3_CBOX := " =Completo;R=Resumido;I=Indisponivel" 
				MsUnLock()
				aAdd(aAlterTb,xZBZ)			
				If !(cCpo $ cCpoAlter)
					cCpoAlter  += cCpo + "/"
				Endif
			EndIF
		EndIf

		If dbSeek(xZB5_+"PRODFI")
			cCpo := xZB5_+"PRODFI" 
			If SX3->X3_TAMANHO <> nTamPrif
				RecLock("SX3",.F.)
				SX3->X3_TAMANHO := nTamPrif
				MsUnLock()
				aAdd(aAlterTb,xZB5)
				If !(cCpo $ cCpoAlter)
					cCpoAlter  += cCpo + "/"  //Log do campo alterado para exibir no final //FR - 10/03/2020
				Endif
				If !(SX3->X3_ARQUIVO $ cAliaAlter)
					cAliaAlter  += SX3->X3_ARQUIVO + "/"  //Log da tabela alterada para exibir no final //FR - 18/08/2020
				Endif
			EndIF
		EndIf         
	
		If dbSeek(xZB5_+"LOJFOR")
			cCpo := xZB5_+"LOJFOR" 
			If SX3->X3_TAMANHO <> nTamLoja 
				RecLock("SX3",.F.)
				SX3->X3_TAMANHO := nTamLoja
				MsUnLock()
				aAdd(aAlterTb,xZB5)
				If !(cCpo $ cCpoAlter)
					cCpoAlter  += cCpo + "/"  //Log do campo alterado para exibir no final //FR - 10/03/2020
				Endif
				If !(SX3->X3_ARQUIVO $ cAliaAlter)
					cAliaAlter  += SX3->X3_ARQUIVO + "/"  //Log da tabela alterada para exibir no final //FR - 18/08/2020
				Endif
			EndIF                                                                                     
		EndIf
	
		If dbSeek(xZB5_+"LOJCLI")
			cCpo := xZB5_+"LOJCLI"
			If SX3->X3_TAMANHO <> nTamLoja 
				RecLock("SX3",.F.)
				SX3->X3_TAMANHO := nTamLoja
				MsUnLock()
				aAdd(aAlterTb,xZB5) 
				If !(cCpo $ cCpoAlter)
					cCpoAlter  += cCpo + "/"  //Log do campo alterado para exibir no final //FR - 10/03/2020			
				Endif
				If !(SX3->X3_ARQUIVO $ cAliaAlter)
					cAliaAlter  += SX3->X3_ARQUIVO + "/"  //Log da tabela alterada para exibir no final //FR - 18/08/2020
				Endif
			EndIF                                                                                     
		EndIf
	
		If dbSeek(xZBZ_+"PRENF")
			cCpo := xZBZ_+"PRENF"
			If AllTrim(SX3->X3_CBOX) <> "#u_zOpcoes()"  //"B=Importado;A=Aviso Recbto Carga;S=Pre-Nota a Classificar;N=Pre-Nota Classificada;F=Falha de Importacao;X=Xml Cancelado;Z=Falha de Consulta"
				RecLock("SX3",.F.)
				SX3->X3_CBOX   := "#u_zOpcoes()"  //"B=Importado;A=Aviso Recbto Carga;S=Pre-Nota a Classificar;N=Pre-Nota Classificada;F=Falha de Importacao;X=Xml Cancelado;Z=Falha de Consulta"
				SX3->X3_TITULO := "Flag Xml"
				SX3->X3_DESCRIC:= "Flag de importação do Xml"
				MsUnLock()
				aAdd(aAlterTb,xZBZ) 
				If !(cCpo $ cCpoAlter)
					cCpoAlter  += cCpo + "/"  //Log do campo alterado para exibir no final //FR - 10/03/2020
				Endif
				If !(SX3->X3_ARQUIVO $ cAliaAlter)
					cAliaAlter  += SX3->X3_ARQUIVO + "/"  //Log da tabela alterada para exibir no final //FR - 18/08/2020
				Endif
			EndIF
		EndIf
	
		If dbSeek(xZBZ_+"MANIF") 
			cCpo := xZBZ_+"MANIF"
			If AllTrim(SX3->X3_CBOX) <> "0=Não;1=Conf.Oper.;2=Oper.Desconh.;3=Oper.Não Realiz.;4=Ciência;5=MCTe;W=Pend.Conf.;X=Pend.Desc.;Y=Pend.N.Realiz;Z=Pend.Ciência" .or.;
				SX3->X3_USADO <> X3_USADO_EMUSO
				RecLock("SX3",.F.)
				SX3->X3_CBOX   := "0=Não;1=Conf.Oper.;2=Oper.Desconh.;3=Oper.Não Realiz.;4=Ciência;5=MCTe;W=Pend.Conf.;X=Pend.Desc.;Y=Pend.N.Realiz;Z=Pend.Ciência"
				SX3->X3_USADO  := X3_USADO_EMUSO
				MsUnLock()
				aAdd(aAlterTb,xZBZ)			
				If !(cCpo $ cCpoAlter)
					cCpoAlter  += cCpo + "/"  //Log do campo alterado para exibir no final //FR - 10/03/2020
				Endif
				If !(SX3->X3_ARQUIVO $ cAliaAlter)
					cAliaAlter  += SX3->X3_ARQUIVO + "/"  //Log da tabela alterada para exibir no final //FR - 18/08/2020
				Endif
			EndIF
		EndIF
	
		If dbSeek(xZBE_+"CHAVE") 
			cCpo := xZBE_+"CHAVE"
			If SX3->X3_TAMANHO <> 60 
				RecLock("SX3",.F.)
				SX3->X3_TAMANHO := 60
				MsUnLock()
				aAdd(aAlterTb,xZBE)
				If !(cCpo $ cCpoAlter)
					cCpoAlter  += cCpo + "/"  //Log do campo alterado para exibir no final //FR - 10/03/2020
				Endif
				If !(SX3->X3_ARQUIVO $ cAliaAlter)
					cAliaAlter  += SX3->X3_ARQUIVO + "/"  //Log da tabela alterada para exibir no final //FR - 18/08/2020
				Endif
			EndIF
		EndIf
	
		If dbSeek(xZBE_+"DESC") 
			cCpo := xZBE_+"DESC"
			If SX3->X3_TAMANHO <> 254
				RecLock("SX3",.F.)
				SX3->X3_TAMANHO := 254
				MsUnLock()
				aAdd(aAlterTb,xZBE)
				If !(cCpo $ cCpoAlter)
					cCpoAlter  += cCpo + "/"  //Log do campo alterado para exibir no final //HM - 18/08/2020
				Endif
			EndIF
		EndIf
		If dbSeek(xZBE_+"TPEVE") 
			cCpo := xZBE_+"TPEVE"
			If AllTrim(SX3->X3_CBOX) <> "110110=Carta Correção;110111=Cancelada;210200=Conf.Oper.;210210=Ciência Op.;210220=Descon.Op;210240=Oper.N.Real.;610110=Desacord"//o CTe"
				RecLock("SX3",.F.)
				SX3->X3_CBOX := "110110=Carta Correção;110111=Cancelada;210200=Conf.Oper.;210210=Ciência Op.;210220=Descon.Op;210240=Oper.N.Real.;610110=Desacordo CTe" 
				MsUnLock()
				aAdd(aAlterTb,xZBE)			
				If !(cCpo $ cCpoAlter)
					cCpoAlter  += cCpo + "/"  //Log do campo alterado para exibir no final //FR - 10/03/2020
				Endif
			EndIF
		EndIf
		
		If dbSeek(xZBT_+"TIPOFO")
			cCpo := xZBT_+"TIPOFO"
			If AllTrim(SX3->X3_CBOX) <> "C=Cliente;F=Fornecedor"
				RecLock("SX3",.F.)
				SX3->X3_CBOX := "C=Cliente;F=Fornecedor"
				MsUnLock()
				aAdd(aAlterTb,xZBT)
				If !(cCpo $ cCpoAlter)
					cCpoAlter  += cCpo + "/"  //Log do campo alterado para exibir no final //FR - 10/03/2020
				Endif
			EndIF
		EndIf
	
		If dbSeek(xZBD_+"DATADO") 
			cCpo := xZBD_+"DATADO"
			If SX3->X3_TIPO <> "C"
				RecLock("SX3",.F.)
					SX3->X3_TIPO := "C"
				MsUnLock()
				aAdd(aAlterTb,xZBD)			
				If !(cCpo $ cCpoAlter)
					cCpoAlter  += cCpo + "/"
				Endif
			EndIF	
			If SX3->X3_TAMANHO <> 20
				RecLock("SX3",.F.)
					SX3->X3_TAMANHO := 20 
				MsUnLock()
				aAdd(aAlterTb,xZBD)			
				If !(cCpo $ cCpoAlter)
					cCpoAlter  += cCpo + "/"
				Endif
			EndIF
		EndIf

		If dbSeek(xZBD_+"DATAIN") 
			cCpo := xZBD_+"DATAIN"
			If SX3->X3_TIPO <> "C"
				RecLock("SX3",.F.)
					SX3->X3_TIPO := "C"
				MsUnLock()
				aAdd(aAlterTb,xZBD)			
				If !(cCpo $ cCpoAlter)
					cCpoAlter  += cCpo + "/"
				Endif
			EndIF				
			If SX3->X3_TAMANHO <> 20
				RecLock("SX3",.F.)
					SX3->X3_TAMANHO := 20 
				MsUnLock()
				aAdd(aAlterTb,xZBD)			
				If !(cCpo $ cCpoAlter)
					cCpoAlter  += cCpo + "/"
				Endif
			EndIF
		EndIf

		If dbSeek(xZBD_+"DATAUP") 
			cCpo := xZBD_+"DATAUP"
			If SX3->X3_TIPO <> "C"
				RecLock("SX3",.F.)
					SX3->X3_TIPO := "C"
				MsUnLock()
				aAdd(aAlterTb,xZBD)			
				If !(cCpo $ cCpoAlter)
					cCpoAlter  += cCpo + "/"
				Endif
			EndIF			
			If SX3->X3_TAMANHO <> 20
				RecLock("SX3",.F.)
					SX3->X3_TAMANHO := 20 
				MsUnLock()
				aAdd(aAlterTb,xZBD)			
				If !(cCpo $ cCpoAlter)
					cCpoAlter  += cCpo + "/"
				Endif
			EndIF			
		EndIf
		//-----------------------------------------------------------------------------// 
		//FR - 03/01/2020 - verifica se houve alteração de tamanho no campo ZBT_PEDIDO
		//-----------------------------------------------------------------------------//		
		cCpo    := ""
		nTamARR := 0 
		fr      := 0
		For fr := 1 to Len(aSX3)
			If aSX3[fr,1] == xZBT 
				If "PEDIDO" $ aSX3[fr,3]
					nTamARR := aSX3[fr,5] //captura o tamanho definido no array de atualização	
				Endif
			Endif
		Next
		
		If nTamARR > 0
			If dbSeek(xZBT_+"PEDIDO")
				cCpo := xZBT_+"PEDIDO"
				If SX3->X3_TAMANHO <> nTamARR 
					RecLock("SX3",.F.)
					SX3->X3_TAMANHO := nTamARR
					MsUnLock()
					aAdd(aAlterTb,xZBT)
					If !(cCpo $ cCpoAlter)
						cCpoAlter  += cCpo + "/"  //Log do campo alterado para exibir no final //FR - 10/03/2020
					Endif
				EndIF                                                                                     
			EndIf
		Endif
		
		//FR - 10/01/2020 - Verifica se houve alteração de tamanho em campo da tabela ZBT:
		//FR - 13/04/2021 - Verifica se houve alteração de tamanho em campo da tabela ZB5:
		nTamARR := 0 
		nDecARR := 0
		fr      := 0
		cCpo    := ""
		For fr := 1 to Len(aSX3)
			nTamARR := 0 
			cCpo    := ""
			//If aSX3[fr,1] == xZBT
			If aSX3[fr,1] == xZBT .or. aSX3[fr,1] == xZB5 
				nTamARR := aSX3[fr,5] 	//captura o tamanho definido no array de atualização
				nDecARR := aSX3[fr,6]	//captura os decimais definidos no array de atualização
				cCpo    := aSX3[fr,3]	
				
				If nTamARR > 0
					If dbSeek(cCpo)
						If SX3->X3_TAMANHO <> nTamARR .or. SX3->X3_DECIMAL <> nDecARR 
							RecLock("SX3",.F.)
							SX3->X3_TAMANHO := nTamARR
							SX3->X3_DECIMAL := nDecARR
							MsUnLock()
							//FR - 13/04/2021
							If aSX3[fr,1] == xZBT
								aAdd(aAlterTb,xZBT) 
							Elseif aSX3[fr,1] == xZB5
								aAdd(aAlterTb,xZB5)
							Endif
							//FR - 13/04/2021
							If !(cCpo $ cCpoAlter)
								cCpoAlter  += cCpo + "/"  //Log do campo alterado para exibir no final //FR - 10/03/2020
							Endif
						EndIF                                                                                     
					Else  //campo novo
						If !(cCpo $ cCpoAlter)
							cCpoAlter  += cCpo + "/"
						Endif
					EndIf
				Endif				
			Endif
		Next
		//------------------------------------------------------------------//
		//FR - 18/08/2020 - Alterações de X3_CBOX: 
		//------------------------------------------------------------------//
		U_fAlterBox(aSX3,@aAlterTb,@aArqUpd,@cAliaAlter,@cCpoAlter)	 
		
		//------------------------------------------------------------------//
		//FR - 10/03/2021 - Alterações de X3_F3 
		//------------------------------------------------------------------//
		U_fAlterF3(aSX3,@aAlterTb,@aArqUpd,@cAliaAlter,@cCpoAlter)	
		
		//------------------------------------------------------------------//
		//FR - 29/03/2021 - Alterações de X3_TITULO 
		//------------------------------------------------------------------//
		U_fAlterDesc(aSX3,@aAlterTb,@aArqUpd,@cAliaAlter,@cCpoAlter)	
		
		//------------------------------------------------------------------//
		//FR - 30/08/2021 - Alterações de X3_PICTURE: 
		//------------------------------------------------------------------//
		U_fAlterPic(aSX3,@aAlterTb,@aArqUpd,@cAliaAlter,@cCpoAlter)	 	
	ProcRegua(Len(aSX3))
	
	dbSelectArea("SX3")
	SX3->(dbSetOrder(2))    //X3_CAMPO - ordem de campo

	aSort( aSX3,,, { |x,y| x[1]+x[2] < y[1]+y[2] } )
	
	For i:= 1 To Len(aSX3)
		If !Empty(aSX3[i][1])
			//FR - 30/03/2022 - Alteração - Ajuste para simular o erro reportado "alias não existe"		
			If Ascan(aArqUpd,aSX3[i,1]) == 0
				aAdd(aArqUpd,aSX3[i,1])
			Endif
			//FR - 30/03/2022 - Alteração - Ajuste para simular o erro reportado "alias não existe"		
			If !dbSeek(PadR(aSX3[i,3],Len(SX3->X3_CAMPO)))   //se não encontrou o campo no SX3, o campo é novo
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³A ordem sera analisada no momento da gravacao visto que    ³
				//³a base pode conter alguns dos campos informados neste      ³
				//³fonte para gravacao. Neste caso, se definissemos a ordem   ³
				//³no momento da criacao do array aSX3, algumas ordem ficariam³
				//³perdidas no SX3.                                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cOrdem		:= ProxOrdem(aSX3[i,1])
				aSX3[i,2] 	:= cOrdem
				//
				lSX3	:= .T.
				If !(aSX3[i,1]$cAlias)
					cAlias     += aSX3[i,1]+"/"  //Tabela
					If !(aSX3[i,3] $ cCpoAlter)
						cCpoAlter  += aSX3[i,3]+"/"  //Campo novo //FR - 10/03/2020
					Endif
					//If Ascan(aArqUpd,aSX3[i,1]) == 0
					//	aAdd(aArqUpd,aSX3[i,1])
					//Endif					
					aAdd(aAlterTb,aSX3[i,1])
					If !(aSX3[i,1] $ cAliaAlter)
						cAliaAlter  += aSX3[i,1]+"/"  //FR - 18/08/2020
					Endif
				EndIf
				RecLock("SX3",.T.)
				For j:=1 To Len(aSX3[i])
					If FieldPos(aEstrut[j])>0
						If aEstrut[j] $ "X3_NIVEL/X3_TAMANHO/X3_DECIMAL" .And. Valtype(aSX3[i,j]) == "C"
							FieldPut(FieldPos(aEstrut[j]),Val(aSX3[i,j]))
						ElseIf aEstrut[j] $ "X3_OBRIGAT" .And. Valtype(aSX3[i,j]) <> "C"
							FieldPut(FieldPos(aEstrut[j]),"")
						Else
							FieldPut(FieldPos(aEstrut[j]),aSX3[i,j])
						EndIf
					EndIf
				Next j
				dbCommit()
				MsUnLock()
				IncProc("Atualizando Dicionario de Dados...")
			Else    											//FR - 18/08/2020 - Cpo já existe
	//			IF aSX3[i,15] = X3_USADO_EMUSO 
					If AllTrim(SX3->X3_USADO) <> AllTrim(aSX3[i,15])
						RecLock("SX3",.F.)
						SX3->X3_USADO  := aSX3[i,15]
						MsUnLock()						
						aAdd(aAlterTb,aSX3[i,1])						
						If !(aSX3[i,3] $ cCpoAlter)
							cCpoAlter  += aSX3[i,3]+"/"  		//Campo alterado  //FR - 10/03/2020
						Endif
					Endif
	//			Endif
			Endif
		EndIf
	Next i
	             
	For i:= 1 to len(aAlterTb)
		If !(aAlterTb[i]$cAlias)
			lSX3 := .T.
			cAlias += aAlterTb[i]+"/"
			//FR - 30/03/2022 - Alteração - Ajuste para simular o erro reportado "alias não existe"		
			If Ascan(aArqUpd,aAlterTb[i])==0
				aAdd(aArqUpd,aAlterTb[i])
			Endif 
			//FR - 30/03/2022 - Alteração - Ajuste para simular o erro reportado "alias não existe"		
		EndIf
	Next i
	
	lSX3 := (!Empty(cAliaAlter))	//FR - 18/08/2020
	
	DbSelectArea("SX3")
	SX3->(dbSetOrder(1))  
	DbSeek(xZBZ)
	While   SX3->X3_ARQUIVO  == xZBZ 
		cFolder := "1"
		If AllTrim(SX3->X3_CAMPO) == xZBZ_+"DTHCAN" .Or. AllTrim(SX3->X3_CAMPO) == xZBZ_+"XMLCAN" .Or. AllTrim(SX3->X3_CAMPO) == xZBZ_+"PROTC"
			cFolder := "2"
		EndIf
		If AllTrim(SX3->X3_CAMPO) == xZBZ_+"MAIL" .Or. AllTrim(SX3->X3_CAMPO) == xZBZ_+"DTMAIL"
			cFolder := "3"
		EndIf
	
		RecLock("SX3",.F.)
		SX3->X3_FOLDER := cFolder
		MsUnLock()
	
		SX3->(dbSkip())	
	EndDo
	
	TcInternal(60,RetSqlName(xZB5) + "|" + RetSqlName(xZB5) + "1") //Inclui sem precisar baixar o TOP
	TcInternal(60,RetSqlName(xZBZ) + "|" + RetSqlName(xZBZ) + "1") //Inclui sem precisar baixar o TOP
	If lTemZBB
		TcInternal(60,RetSqlName(xZBB) + "|" + RetSqlName(xZBB) + "1") //Inclui sem precisar baixar o TOP
	EndIF
	TcInternal(60,RetSqlName(xZBS) + "|" + RetSqlName(xZBS) + "1") //Inclui sem precisar baixar o TOP
	TcInternal(60,RetSqlName(xZBE) + "|" + RetSqlName(xZBE) + "1") //Inclui sem precisar baixar o TOP
	TcInternal(60,RetSqlName(xZYX) + "|" + RetSqlName(xZYX) + "1") //Inclui sem precisar baixar o TOP
	TcInternal(60,RetSqlName(xZBC) + "|" + RetSqlName(xZBC) + "1") //Inclui sem precisar baixar o TOP
	TcInternal(60,RetSqlName(xZBI) + "|" + RetSqlName(xZBI) + "1") //Inclui sem precisar baixar o TOP
	TcInternal(60,RetSqlName(xZBO) + "|" + RetSqlName(xZBO) + "1") //Inclui sem precisar baixar o TOP
	TcInternal(60,RetSqlName(xZBT) + "|" + RetSqlName(xZBT) + "1") //Inclui sem precisar baixar o TOP
	TcInternal(60,RetSqlName(xZBG) + "|" + RetSqlName(xZBG) + "1") //Inclui sem precisar baixar o TOP
	
	If lSX3
		cMsg := ""
		If !Empty(cAliaAlter) //If !Empty(cAlias) 
			//cMsg += 'Foram alteradas as estruturas das seguintes tabelas : '+ cAlias + CHR(13)+CHR(10)
			cMsg += 'Foram alteradas as estruturas das seguintes tabelas : '+ cAliaAlter + CHR(13)+CHR(10)
		Endif
		If !Empty(cCpoAlter)
			cMsg += 'Foram alterados/criados os seguintes campos: ' + cCpoAlter + CHR(13)+CHR(10)
		Endif
		lAltera := .T.		
		AutoGrLog( cMsg )
	EndIf

Return cTexto

//--------------------------------------------------------------------
/*{Protheus.doc}
Função de processamento da gravação do SX6 - Parâmetros
*/
//--------------------------------------------------------------------
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ IFAtuSX6 ³ Autor ³Marcos Favaro          ³ Data ³04/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de processamento da gravacao do SX6                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Atualizacao COM                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function IFAtuSX6()
Local aSX6   := {}
Local aEstrut:= {}
Local i      := 0
Local j      := 0
Local lSX6	 := .F.
Local cTexto := ''
Local cAlias := ''
Local cDeldp := ''

aEstrut:= { "X6_FIL","X6_VAR","X6_TIPO","X6_DESCRIC","X6_DSCSPA","X6_DSCENG","X6_DESC1","X6_DSCSPA1","X6_DSCENG1","X6_DESC2","X6_DSCSPA2","X6_DSCENG2","X6_CONTEUD","X6_CONTSPA","X6_CONTENG","X6_PROPRI","X6_PYME"}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Importacao XML NF- Entrada³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*
AADD(aSx6,{"  ","MV_XMLIMPO","C","Pasta onde os XML de Pre Nota Importados Serao","","","","","","","","","IMPORTADOS","","","",""})
AADD(aSx6,{"  ","MV_XMLREJE","C","Pasta onde os XML de Pre Nota Rejeitados Serao","","","","","","","","","REJEITADOS","","","",""})
AADD(aSx6,{"  ","MV_XMLEXTR","C","Onde Sera Gerada a Pasta de Extrutura dos XML","","","Para serem importados e Arquivados","","","Servidor ou Local","","","XML_FORNECEDORES","","","",""})
AADD(aSx6,{"  ","MV_NFEFOR1","C","SMTP de Envio de XML Fornecedor","","","","","","","","","","","","",""})
AADD(aSx6,{"  ","MV_NFEFOR2","C","Conta de Email de Envio de XML Fornecedor","","","","","","","","","","","","",""})
AADD(aSx6,{"  ","MV_NFEFOR3","C","Senha da Conta de Envio de XML Fornecedor","","","","","","","","","","","","",""})
*/
AADD(aSx6,{cFilSm,"MV_MOSTRAA","C","Mostra todas Consultas junto a Sefaz S ou N." ,"","","","","","","","","N","N","N","",""})
                       
/* COnfiguração de envios SMTP */
AADD(aSx6,{cFilSm,"XM_PROTENV","C","Protocolo de envio de notificação de xml."    ,"","","","","","","","","1","","","",""}) //space(len(SX6->X6_FIL))
AADD(aSx6,{cFilSm,"XM_SMTP"   ,"C","SMTP de Envio de e-mail"	          		    ,"","","","","","","","","","","","",""})
AADD(aSx6,{cFilSm,"XM_ACCOUNT","C","Conta de Email de Envio de XML Fornecedor."	,"","","","","","","","","","","","",""})
AADD(aSx6,{cFilSm,"XM_LOGIN"  ,"C","Login de Email de Envio de XML Fornecedor."	,"","","","","","","","","","","","",""})
AADD(aSx6,{cFilSm,"XM_PASS"   ,"C","Senha da Conta de Envio de XML Fornecedor."	,"","","","","","","","","","","","",""})
AADD(aSx6,{cFilSm,"XM_AUT"    ,"C","Informa se e-mail utiliza autenticação."		,"","","","","","","","","","","","",""})
AADD(aSx6,{cFilSm,"XM_SSL"    ,"C","Informa se e-mail utiliza conexao segura."   	,"","","","","","","","","","","","",""})
AADD(aSx6,{cFilSm,"XM_TLS"    ,"C","Informa se e-mail utiliza conexao segura TLS.","","","","","","","","","","","","",""})
AADD(aSx6,{cFilSm,"XM_ENVPORT","C","Porta de Envio."                             	,"","","","","","","","","","","","",""})

/* Configuração de recebimento POP / IMAP */
AADD(aSx6,{cFilSm,"XM_PROTREC","C","Protocolo de recebimento de xml."	                    ,"","","","","","","","","1","","","",""})
AADD(aSx6,{cFilSm,"XM_POPIMAP","C","Endereço POP/IMAP de Recebimento de XML Fornecedor"	,"","","","","","","","","","","","",""})
AADD(aSx6,{cFilSm,"XM_POPACC" ,"C","Conta de Email de Recebimento de XML Fornecedor."		,"","","","","","","","","","","","",""})
AADD(aSx6,{cFilSm,"XM_POPPASS","C","Senha da Conta de Recebimento de XML Fornecedor."		,"","","","","","","","","","","","",""})
AADD(aSx6,{cFilSm,"XM_POPAUT" ,"C","Informa se e-mail utiliza autenticação."				,"","","","","","","","","","","","",""})
AADD(aSx6,{cFilSm,"XM_POPSSL" ,"C","Informa se e-mail utiliza conexao segura."			,"","","","","","","","","","","","",""})
AADD(aSx6,{cFilSm,"XM_RECPORT","C","Porta de Recebimento."                             	,"","","","","","","","","","","","",""})
AADD(aSx6,{cFilSm,"XM_POPTLS" ,"C","Informa se e-mail utiliza conexao segura TLS p/ POP.","","","","","","","","","","","","",""})

/* E-mail de Notificacao */
AADD(aSx6,{cFilSm,"XM_MAIL01"   ,"C","E-mail para notificaçao de eventos."				        ,"","","","","","","","","","","","",""})
AADD(aSx6,{cFilSm,"XM_MAIL02"   ,"C","E-mail para notificaçao de eventos."				        ,"","","","","","","","","","","","",""})
AADD(aSx6,{cFilSm,"XM_MAIL03"   ,"C","E-mail para notificaçao de eventos."				        ,"","","","","","","","","","","","",""})
AADD(aSx6,{cFilSm,"XM_MAIL04"   ,"C","E-mail para notificaçao de eventos."				        ,"","","","","","","","","","","","",""})
AADD(aSx6,{cFilSm,"XM_MAIL05"   ,"C","E-mail para XML que não consta na Base de Dados."        	,"","","","","","","","","","","","",""})
AADD(aSx6,{cFilSm,"XM_MAIL06"   ,"C","E-mail - XML que não consta na Base JOB Separado"        	,"","","","","","","","","","","","",""})
AADD(aSx6,{cFilSm,"XM_MAIL07"   ,"C","E-mail para notificações de classificação automática"    	,"","","","","","","","","","","","",""})
AADD(aSx6,{cFilSm,"XM_MAIL08"   ,"C","E-mail para notificações de divergencia de valores"    	,"","","","","","","","","","","","",""})
AADD(aSx6,{cFilSm,"XM_MAIL09"   ,"C","E-mail p/ notificações novos cadastros"   				,"","","de Fornecedor feitos de forma robótica","","","","","","","","","",""})    //FR - 12/07/2022 - KITCHENS - Avisar
AADD(aSx6,{cFilSm,"XM_MAIL10"   ,"C","E-mail p/ notificações novos XMLs gravados"   			,"","","na base de dados.","","","","","","","","","",""})    //FR - 21/12/2022 - BRASMOLDE
AADD(aSx6,{cFilSm,"XM_MAIL11"   ,"C","E-mail p/ notificações nova pre-nota gerada" 				,"","","","","","","","","","","","",""})    //FR - 21/12/2022 - BRASMOLDE
AADD(aSx6,{cFilSm,"XM_MAIL12"   ,"C","E-mail p/ notificações classificação de nota" 			,"","","","","","","","","","","","",""})    //FR - 21/12/2022 - BRASMOLDE
AADD(aSx6,{cFilSm,"XM_ENVIMP"   ,"C","Verificar pastas Importados nas rotinas de Chk XML?(S/N)","","","","","","","","","","","","",""})

AADD(aSx6,{cFilSm,"XM_DIRFIL"   ,"C","Informa se cria diretorio por Filial do cliente."   ,"","","","","","","","","","","","",""})
AADD(aSx6,{cFilSm,"XM_DIRCNPJ"  ,"C","Informa se cria diretorio por CNPJ do emitente."    ,"","","","","","","","","","","","",""})
AADD(aSx6,{cFilSm,"XM_DIRMOD"   ,"C","Informa se cria diretorio por modelo de XML."       ,"","","","","","","","","","","","",""})

/*Configuração das Tabelas Geral*/
AADD(aSx6,{cFilSm,"XM_TABXML" ,"C","Tabela Padrão onde ficarão os XMLs Importados","","","","","","","","",xZBZ,xZBZ,xZBZ,"",""})
AADD(aSx6,{cFilSm,"XM_TABAMAR","C","Tabela Amarração de Produtos"				  ,"","","","","","","","",xZB5,xZB5,xZB5,"",""})
AADD(aSx6,{cFilSm,"XM_TABREC" ,"C","Tabela de Fornecedores com Pedido Recorrente" ,"","","","","","","","",xZBB,xZBB,xZBB,"",""})

If lBossKey
	AADD(aSx6,{cFilSm,"XM_TABZBX","C","Tabela Uso de Licencas Importaxml"		  ,"","","","","","","","",xZBX,xZBX,xZBX,"",""})
EndIf

AADD(aSx6,{cFilSm,"XM_TABSINC" ,"C","Tabela Sincronização com SEFAZ"			  ,"","","","","","","","",xZBS,xZBS,xZBS,"",""})
AADD(aSx6,{cFilSm,"XM_TABAMA2" ,"C","Tabela Usuáriso com Amarração Secundária"	  ,"","","","","","","","",xZBA,xZBA,xZBA,"",""})
AADD(aSx6,{cFilSm,"XM_TABEVEN" ,"C","Tabela de Carta de Correção e Eventos"		  ,"","","","","","","","",xZBE,xZBE,xZBE,"",""})
AADD(aSx6,{cFilSm,"XM_TABSYX"  ,"C","Tabela de Consultas Systax"				  ,"","","","","","","","",xZYX,xZYX,xZYX,"",""})
AADD(aSx6,{cFilSm,"XM_TABCAC"  ,"C","Tabela de Classificação Automática"		  ,"","","","","","","","",xZBC,xZBC,xZBC,"",""})
AADD(aSx6,{cFilSm,"XM_TABIEXT" ,"C","Tabela de Integração Extermna"				  ,"","","","","","","","",xZBI,xZBI,xZBI,"",""})
AADD(aSx6,{cFilSm,"XM_TABOCOR" ,"C","Tabela de Ocorrência de Integrações"		  ,"","","","","","","","",xZBO,xZBO,xZBO,"",""})
AADD(aSx6,{cFilSm,"XM_TABITEM" ,"C","Tabela de Itens da NF"						  ,"","","","","","","","",xZBT,xZBT,xZBT,"",""})  //FR - 15/11/19 - nova tabela de itens da NF
AADD(aSx6,{cFilSm,"XM_TABMUN" ,"C","Tabela de Municipios API"					  ,"","","","","","","","",xZBM,xZBM,xZBM,"",""})  //HMS - 31/08/20 - nova tabela de municipios api
AADD(aSx6,{cFilSm,"XM_TABMUN2" ,"C","Tabela de Leituras API"					  ,"","","","","","","","",xZBN,xZBN,xZBN,"",""})  //HMS - 03/09/20 - nova tabela de leituras api
AADD(aSx6,{cFilSm,"XM_TABIMC" ,"C","Tabela do Image Converter"					  ,"","","","","","","","",xZBD,xZBD,xZBD,"",""})  //HMS - 06/01/21 - nova tabela do image converter
AADD(aSx6,{cFilSm,"XM_TABCON" ,"C","Tabela Controle de Consumo"					  ,"","","","","","","","",xZBF,xZBF,xZBF,"",""})  //HMS - 06/01/21 - nova tabela Controle Consumo
AADD(aSx6,{cFilSm,"XM_TABLOG" ,"C","Tabela Log Consulta Fornecedor"				  ,"","","","","","","","",xZBG,xZBG,xZBG,"",""})  //FR - 17/02/2022 - Log Consulta Fornecedor
AADD(aSx6,{cFilSm,"XM_TABTPO" ,"C","Tabela Tipos de IOcorrencias de XML"		  ,"","","","","","","","",xZBH,xZBH,xZBH,"",""})  //FR - 17/02/2022 - Log Consulta Fornecedor

/*Configuração da ABA Geral*/
AADD(aSx6,{cFilSm,"MV_X_PATHX"  ,"C","Diretorio Raiz dos XMLs importados."                ,"","","","","","","","","","","","",""})
AADD(aSx6,{cFilSm,"XM_FORMNFE"  ,"C","Formato do campo Documento/Nota fiscal para NF-e."  ,"","","","","","","","","9","","","",""})
AADD(aSx6,{cFilSm,"XM_FORMCTE"  ,"C","Formato do campo Documento/Nota fiscal para CT-e."  ,"","","","","","","","","9","","","",""})
AADD(aSx6,{cFilSm,"XM_FORCET3"  ,"C","Informa se força a busca pelo tomador do CT-e."     ,"","","","","","","","","","","","",""})

AADD(aSx6,{cFilSm,"XM_USANFE"   ,"C","Informa se utiliza importação de NF-e."             ,"","","","","","","","","S","S","S","",""})
AADD(aSx6,{cFilSm,"XM_USACTE"   ,"C","Informa se utiliza importação de CT-e."             ,"","","","","","","","","S","S","S","",""})
AADD(aSx6,{cFilSm,"XM_USANFCE"  ,"C","Informa se utiliza importação de NFC-e."            ,"","","","","","","","","S","S","S","",""})

AADD(aSx6,{cFilSm,"XM_PRODCTE"  ,"C","Código de produto padrão para NF de CT-e."          ,"","","","","","","","","","","","",""})

AADD(aSx6,{cFilSm,"XM_PED_PRE"  ,"C","Informa se assume valores do pedido na Pre-nota."   ,"","","","","","","","","","","","",""})

AADD(aSx6,{cFilSm,"XM_CFDEVOL"  ,"C","Cfops de devolução em entradas de NF-e."            ,"","","","","","","","","","","","",""})
AADD(aSx6,{cFilSm,"XM_CFBENEF"  ,"C","Cfops de beneficiamento em entradas de NF-e."       ,"","","","","","","","","","","","",""})

//Adicionado dia 22/01/2016 pelo analista Alexandro / Eneo
AADD(aSx6,{cFilSm,"XM_CFTRANS"  ,"C","Cfops de transfrencia de entradas de NF-e."       ,"","","","","","","","","","","","",""})
//Fim
//Adicionado dia 21/09/2022 pelo Erick Gonça
AADD(aSx6,{cFilSm,"XM_CFCOMPL"  ,"C","Cfops de complemento em entradas de NF-e."		 ,"","","","","","","","","","","","",""})

AADD(aSx6,{cFilSm,"XM_D_STATUS" ,"C","Dias a retroceder para verificar Status XML."          ,"","","","","","","","","180","180","180","",""})
AADD(aSx6,{cFilSm,"XM_D_CANCEL" ,"C","Dias a retroceder para consultar XML na SEFAZ."        ,"","","","","","","","","30","30","30","",""})
AADD(aSx6,{"  "  ,"XM_TPJOBCX"  ,"C","Tipo das Execuções do JOB. 1=Concorrentes ou 2=Em Fila","","","","","","","","","2","2","2","",""})
//XM_TPJOBCX -> Compartilhar

AADD(aSx6,{cFilSm,"XM_DT_CONS"  ,"C","Data de execução da ultima consulta XML na SEFAZ." ,"","","","","","","","","20130101","20130101","20130101","",""})
AADD(aSx6,{cFilSm,"XM_HR_CONS"  ,"C","Hora programada de execução da consulta XML na SEFAZ." ,"","","","","","","","","22:00","22:00","22:00","",""})																						

AADD(aSx6,{cFilSm,"XM_ROTINAS"  ,"C","Rotinas a serem executadas pelo botão 'Baixar XML'.","","","","","","","","","1,2,3,5","1,2,3,5","1,2,3,5","",""})	

AADD(aSx6,{cFilSm,"XM_CFGPRE"   ,"C","Define a ação após a geração de pré-nota","","","","","","","","","2","2","2","",""})	
AADD(aSx6,{cFilSm,"XM_TIP_PRE"  ,"C","Tipo de pré-nota","","","","","","","","","1","1","1","",""})
AADD(aSx6,{cFilSm,"XM_FIL_USU"  ,"C","Filtra Filial por Usuário","","","","","","","","","N","N","N","",""})
AADD(aSx6,{cFilSm,"XM_URL"      ,"C","URL do TSS a qual será utilizado pelo importa.","","","","","","","","","","","","",""})
AADD(aSx6,{cFilSm,"XM_CTE_DET"  ,"C","Detalha Notas Fiscias nos itens de CT-e","","","","","","","","","N","N","N","",""})

AADD(aSx6,{cFilSm,"XM_NFORI"   ,"C","Amarra NF Origem pelo Livro Fiscal(Entradas)?","","","S - Livro Fiscal(SF3); N - NF Saida(SF2).","","","","","","N","N","N","",""})
AADD(aSx6,{cFilSm,"XM_CSOL"    ,"C","Amarra C.Custo de Qual Cadastro?","","","S - Ped.Compra; N - Cad.Produto; A - Ambos","","","","","","A","A","A","",""})

/*Configuração da ABA Geral 2 - Alexandro de Oliveira - 25/11/2014*/
AADD(aSx6,{cFilSm,"XM_SEREMP"  ,"C","SERIE POR EMPRESA"          ,"","","EX: SP=01,02;ES=10,11"                 ,"","","VAZIO Mantem Série do XML","","","","","","",""})
AADD(aSx6,{cFilSm,"XM_SERXML"  ,"C","SERIE DO XML VAZIA QUANDO 0","","","EX: S=SIM EM BRANCO; N=NAO COM VALOR 0","","",""                         ,"","","N","N","N","",""})
AADD(aSx6,{cFilSm,"XM_PED_GBR" ,"C","Trava XML Diferente Pedido" ,"","",""                                      ,"","",""                         ,"","","N","N","N","",""})
AADD(aSx6,{cFilSm,"XM_CCNFOR"  ,"C","C.Custo da NF Origem para CTE?","","",""                                   ,"","",""                         ,"","","N","N","N","",""})

AADD(aSx6,{cFilSm,"XM_PEDREC"  ,"C","Utiliza Pedido Recorrente"     ,"","",""                                   ,"","",""                         ,"","","N","N","N","",""})
AADD(aSx6,{cFilSm,"XM_RECDOC"  ,"C","Tipo de documento a gerar por pedido recorrente"     ,"","",""                                   ,"","",""                         ,"","","1","1","1","",""})

AADD(aSx6,{cFilSm,"XM_ROT_CON"  ,"C","ROTINA DE CONSULTA AO SEFAZ","","","1=Importa XML, 2=TSS"                  ,"","",""                         ,"","","1","1","1","",""})
AADD(aSx6,{cFilSm,"XM_GRBMOD"   ,"C","CONSULTA TODAS MODALIDADES" ,"","",""                                      ,"","",""                         ,"","","N","N","N","",""})
AADD(aSx6,{cFilSm,"XM_XMLSEF"   ,"C","Comparar TAGs do XML com a SEFAZ","","",""                                   ,"","",""                         ,"","","N","N","N","",""})
AADD(aSx6,{cFilSm,"XM_MANPRE"   ,"C","Manifestar após gerar a pré-nota","","",""                                   ,"","",""                         ,"","","N","N","N","",""})
AADD(aSx6,{cFilSm,"XM_SEFPRN"	,"C","Consulta SEFAZ antes da Pré-Nota S=Sim ou N=Nao"  ,"","","","","",""  ,"","","N","N","N","",""})

//Rotinas para Download e Manifestação
//Adicionado no dia 27/02/2020 pelo Analista - Rogério Lino
AADD(aSx6,{cFilSm,"XM_NSUZERO"  ,"C","Verifica NSU zerado N=Não ou S=Sim"               ,"","","","","",""  ,"","","N","N","N","",""})
AADD(aSx6,{cFilSm,"XM_DAYZERO"  ,"C","Realiza a verificação de nsu zerado"              ,"","","","","",""  ,"","","S","S","S","",""})
AADD(aSx6,{cFilSm,"XM_DFE"	    ,"C","Rotina de Download do XML (0,1,2)"  			  	,"","","","","",""  ,"","","1","1","1","",""})
AADD(aSx6,{cFilSm,"XM_DFEMAN"	,"C","Rotina de Manifestação Destinatário (0,1)"  		,"","","","","",""  ,"","","0","0","0","",""})

//Adicionado dia 16/06/2015 pelo analista Alexandro
AADD(aSx6,{cFilSm,"XM_LOGOD"   ,"C","Emissão do Logo na Danfe"        ,"","","EX: S=SIM EMITE LOGO; N=NAO EMITE LOGO","","",""                         ,"","","N","N","N","",""})

//Adicionado dia 22/01/2016 pelo analista Alexandro / Eneo
AADD(aSx6,{cFilSm,"XM_DE_PARA"  ,"C","Tipo de seleção de amarração de produto."       ,"","","","","","","","","0","","","",""})
AADD(aSx6,{cFilSm,"XM_FORMSER"  ,"C","Formato da serie"							      ,"","","EX: 0=Serie Original; 2=2 Dígitos; 3=3 Dígitos","","",""                         									 ,"","","0","0","0","",""})
AADD(aSx6,{cFilSm,"XM_XPEDXML"  ,"C","Tipo de amarração por Pedido" 				  ,"","","1-Saldo Pedido 2-XML 3-Perguntar" ,"","","4-Saldo por Item Pedido"												 ,"","","3","3","3","",""})
AADD(aSx6,{cFilSm,"XM_USAGFE"   ,"C","Atualiza status Frete Embarcador" 			  ,"GFE - S=Sim N=Não","","Atualiza status Frete Embarcador" ,"GFE - S=Sim N=Não","",""										 ,"","","N","N","N","",""})
AADD(aSx6,{cFilSm,"XM_PNFCPL"   ,"C","Notas Complementares Lançar?" 				  ,"1-Doc.Entrada, 2-Pré-Nota, 3-Perguntar","","Notas Complementares Lançar?" ,"1-Doc.Entrada, 2-Pré-Nota, 3-Perguntar","","","","","1","1","1","",""})

//Fim
AADD(aSx6,{cFilSm,"XM_USANFSE"  ,"C","UTILIZA ROTINA DE NFSE"                          ,"","","","","","","","","N","N","N","",""                     		})
AADD(aSx6,{cFilSm,"XM_ESP_NFS"  ,"C","ESPECIE PARA PRE NOTA DE NFSE"                   ,"","","","","","","","","NFSE","NFSE","NFSE","",""            		})
AADD(aSx6,{cFilSm,"XM_PRODNFS"  ,"C","PRODUTO GENERICO DOS FORNECEDORES DE NFSE"       ,"","","","","","","",""," "," "," ","",""                     		})
AADD(aSx6,{cFilSm,"XM_ARQ_NFS"  ,"C","Extensão do Arquivo (texto) para importação NFSE","","","","","","","","","nfs;nfse","nfs;nfse","nfs;nfse","",""		})
AADD(aSx6,{cFilSm,"XM_MANAUT"   ,"C","Manifesta Para Download Automatico"              ,"","","","","","","","","N","N","N","",""                     		})
AADD(aSx6,{cFilSm,"XM_VERLOJA"  ,"C","Considera Loja na Amarração por pedido"		   ,"","","","","","","","","N","N","N","",""                     		})
AADD(aSx6,{cFilSm,"XM_CTE_AVI"  ,"C","Mostra Avisos CTE"							   ,"","","","","","","","","S","S","S","",""                     		})
AADD(aSx6,{cFilSm,"XM_LOGARQ"   ,"C","Gravar LOGs"									   ,"","","","","","","","","S","S","S","",""                     		})
AADD(aSx6,{cFilSm,"XM_BROWSE"   ,"C","Browse da Tela Principal"                        ,"1=Somente Nfe; 2=NFe e CCe(Eventos);","","3=Três Browses: Nfe, Itens e Cce","","","","","2","2","2","",""})  //FR - 26/11/19

//Adicionado para criaçao do paramentro multiplo CTE - 31/05/2017
AADD(aSx6,{cFilSm,"XM_AGLMCTE"  ,"C","Aglutina multiplos CTE S=Sim, N=Nao"				    ,"","","","","",""  ,"","","N","N","N","",""})
AADD(aSx6,{cFilSm,"XM_TPMCTE"   ,"C","Tipo Multiplos CTE 1=Fornecedor, 2=Da Pasta, 3=Ambos"	,"","","","","",""  ,"","","3","3","3","",""})

AADD(aSx6,{cFilSm,"XM_PRIVILE"  ,"C","Utiliza Privilégio S=Sim ou N=Nao"  				,"","","","","",""  ,"","","N","N","N","",""})
/*Parametro para retorno XML considerado*/
AADD(aSx6,{cFilSm,"XM_RETOK"   ,"C","Retorno XML considerado como OK"					,"","","","","",""  ,"","","526,731,217","526,731,217","526,731,217","",""})

/*Integração Externa/Classificação Automática*/
AADD(aSx6,{cFilSm,"XM_ITATFTP" ,"C","Caminho URL do FTP"								,"","","","","",""  ,"","","","","","",""})
AADD(aSx6,{cFilSm,"XM_ITATLOG" ,"C","Usuário do FTP Para Integração Externa"	  		,"","","","","",""  ,"","","","","","",""})
AADD(aSx6,{cFilSm,"XM_ITATPAS" ,"C","Senha para Integração Externa"						,"","","","","",""  ,"","","","","","",""})
AADD(aSx6,{cFilSm,"XM_ITATJOB" ,"C","Agendamento Integração Externa? (1-Hab/0-Desabil)"	,"","","","","",""  ,"","","0","0","0","",""})
AADD(aSx6,{cFilSm,"XM_ITATDIA" ,"C","Dia da Semana para rodar integração automaticamente","","","","","",""  ,"","","","","","",""})
AADD(aSx6,{cFilSm,"XM_ITATMES" ,"C","Mês para rodar integração automatica"				,"","","","","",""  ,"","","","","","",""})
AADD(aSx6,{cFilSm,"XM_ITATANC" ,"C","Ano/Mês para rodar integração automatica"			,"","","","","",""  ,"","","","","","",""})
AADD(aSx6,{cFilSm,"XM_ITATHRC" ,"C","Hora inicio para integração automatica"			,"","","","","",""  ,"","","","","","",""})
AADD(aSx6,{cFilSm,"XM_ITATPOR" ,"C","Caminho PORTA do FTP"								,"","","","","",""  ,"","",Space(10),Space(10),Space(10),"",""})
AADD(aSx6,{cFilSm,"XM_ITATDIR" ,"C","Diretório onde estão os arquivos no FTP"			,"","","","","",""  ,"","","","","","",""})
AADD(aSx6,{cFilSm,"XM_ITATPRT" ,"C","Protocolo 1-FTP 2=SFTP(SSH)"						,"","","","","",""  ,"","","","","","",""})

/*Integração Externa/Classificação Automática*/
AADD(aSx6,{cFilSm,"XM_CLAT"    ,"C","Utiliza Classificação Automática? (S/N)"			,"","","","","",""  ,"","","S","S","S","",""})
AADD(aSx6,{cFilSm,"XM_CLATJOB" ,"C","Agendamento Classificação Automática? (0/1)"		,"","","","","",""  ,"","","0","0","0","",""})
AADD(aSx6,{cFilSm,"XM_CLATDIA" ,"C","Dia da Semana para rodar classificação automaticamente","","","","","" ,"","","","","","","",""})
AADD(aSx6,{cFilSm,"XM_CLATMES" ,"C","Mês para rodar classificação automatica"			,"","","","","",""  ,"","","","","","",""})
AADD(aSx6,{cFilSm,"XM_CLATANC" ,"C","Ano/Mês para rodar classificação automatica"		,"","","","","",""  ,"","","","","","",""})
AADD(aSx6,{cFilSm,"XM_CLATHRC" ,"C","Hora inicio para classificação automatica"	  		,"","","","","",""  ,"","","","","","",""})
AADD(aSx6,{cFilSm,"XM_NFE_TES" ,"C","TES para Classificação Automática de NFe"  		,"","","","","",""  ,"","","","","","",""}) //FR - 26/11/19
AADD(aSx6,{cFilSm,"XM_CTE_TES" ,"C","TES para Classificação Automática de NF CTe"  		,"","","","","",""  ,"","","","","","",""}) //FR - 03/12/19

//FR - 27/11/19: o parâmetro abaixo trabalha em conjunto com o parâmetro XM_CLAT:
AADD(aSx6,{cFilSm,"XM_CLATRBT" ,"C","Tipo da Robotização Classificação Automática"		,"1=Pergunta Múltiplos;2=Múltiplos NFE e CTE;","","3=Automat.NFE/CTE;4=TES Cad.Produto;5=Não utilizado.","","",""     ,"","","1","1","1","",""}) //FR - 27/11/19

//Rotinas PutDepara1 e 2 utilizar tela de consulta do SB1 padrão ou customizada
//Optar sempre pela customizada, pois a padrão causa lentidão
//Adicionado no dia 27/02/2020 pelo Analista - Rogério Lino
AADD(aSx6,{cFilSm,"XM_PESSB1"  ,"C","Utiliza Consulta Padrão SB1? (S/N)"			    ,"","","","","",""  ,"","","N","N","N","",""})

//-------------------------------------------------------------------------------------------------------------------//
//FR 19/05/2020: Adicionado por Flávia Rocha, ativa a rotina de verificação de divergências entre XML x NF (Sim/Não) 
//FR por default a opção é "NÃO" se a empresa desejar, precisará ativar via tela F12 configurações do Gestão XML.
//-------------------------------------------------------------------------------------------------------------------//
AADD(aSx6,{cFilSm,"XM_USADVG"  ,"C","Ativa Verifica Divergências" ,"Ativa Verifica Divergências","","Ver Divergências: S=Sim N=Não" ,"Ver Divergências: S=Sim N=Não","",""	,"","","N","N","N","",""})
AADD(aSx6,{cFilSm,"XM_USAPDFN" ,"C","Diretorio do pdf api"        ,"Diretorio do pdf api","","Diretorio do pdf api: S=Sim N=Não" ,"Diretorio do pdf api: S=Sim N=Não","",""	,"","","N","N","N","",""})
AADD(aSx6,{cFilSm,"XM_TESDEV"  ,"C","Utiliza TES de Devolucao"    ,"Utiliza TES de Devolucao","","TES de Devolucao: S=Sim N=Não" ,"TES de Devolucao: S=Sim N=Não","",""	,"","","N","N","N","",""})
AADD(aSx6,{cFilSm,"XM_BANTSS"  ,"C","Nome Database TSS?"		  ,"","","","","",""  ,"","","PRODUCAO","PRODUCAO","PRODUCAO","",""})
AADD(aSx6,{cFilSm,"XM_GRVZB5"  ,"C","Prod. Int. Grava ZB5?"		  ,"Prod. Int. Grava ZB5?","","Grava ZB5? : S=Sim N=Não","Grava ZB5? : S=Sim N=Não","","","","","S","S","S","",""})
//------------------------------------------------------------------------------------------------------------------------//
//FR 17/07/2020: Adicionado por Flávia Rocha, regula o tempo de espera do comando Sleep, exemplo: integração Águas do Brasil 
//------------------------------------------------------------------------------------------------------------------------//
AADD(aSx6,{cFilSm,"XM_ITSLEEP" ,"N","Tempo espera no job em milisegundos"        ,"Tempo espera no job em milisegundos","","Tempo espera no job em milisegundos" ,"Tempo espera no job em milisegundos","",""	,"","","10000","10000","10000","",""})
//------------------------------------------------------------------------------------------------------------------------//
//FR 20/08/2020: Adicionado por Flávia Rocha, guarda quais caracteres podem ser utilizados como separadores entre strings 
//------------------------------------------------------------------------------------------------------------------------//
AADD(aSx6,{cFilSm,"XM_SEPARAD" ,"C","Caracteres Separadores"					,"","","","","",""  ,"","","|,*,/,-","|,*,/,-","|,*,/,-","",""})

//------------------------------------------------------------------------------------------------------------------------//
//FR 04/09/2020: Adicionado por Flávia Rocha, guarda o número máximo de tentativas para download e redownload de xml 
//------------------------------------------------------------------------------------------------------------------------//
AADD(aSx6,{cFilSm,"XM_TENTSEND" ,"N","Numero maximo de tentativas"             ,"Numero maximo de tentativas","","Numero maximo de tentativas" ,"Numero maximo de tentativas","","","","","5","5","5","",""})

//------------------------------------------------------------------------------------------------------------------------//
//FR 08/09/2020: Adicionado por Flávia Rocha, guarda quais CFOPs são considerados como NF Energia 
//------------------------------------------------------------------------------------------------------------------------//
AADD(aSx6,{cFilSm,"XM_CFOENERG" ,"C","Cfops de NF Energia"					   ,"Cfops de NF Energia"        ,"","Cfops de NF Energia"         ,"Cfops de NF Energia"        ,"","","","","5251,6251,5123,6123,5922,6922","5251,6251,5123,6123,5922,6922","5251,6251,5123,6123,5922,6922","",""})

//------------------------------------------------------------------------------------------------------------------------//
//FR 22/09/2020: Adicionado por Flávia Rocha, guarda quais tipos de NF poderão ser classificadas automaticamente 
//------------------------------------------------------------------------------------------------------------------------//
	//Alteração:
	//FR - 05/08/2022 - PROJETO POLITEC
	//Onde está:
	// C – NF Combustível , mudar o nome para NF Combustível + Audit Terc,
	//
	//Criar uma nova opção na lista acima C1- NF Combustível – Esta será a opção a ser utilizada pelo cliente
	//que não terá integração com a empresa Ticket não tendo necessidade de auditoria de terceiros Robótica junto.
	//Efetuar a alteração do parâmetro acima , via programação do nosso programa de instalador, 
	//além de efetuar todas as adequações necessárias para que não gere problema nos processos já utilizados hoje.
	/*
	aAdd( aCombo27, "C= NF Combustíveis + Audit Terc"  ) - integra com empresa TICKET
	aAdd( aCombo27, "C1= NF Combustível")		         - não integra com empresa TICKET nem nenhuma outra, é apenas pelo XML
	aAdd( aCombo27, "E= NF Energia" )
	aAdd( aCombo27, "T= Todos"    )
	aAdd( aCombo27, "N= Nenhum"   )
	*/
AADD(aSx6,{cFilSm,"XM_CLATPNF" ,"C","Tipos NF Classificação Robótica"		,"C=NF Combust.+Audit Terc;C1=NF Combust. via XML;","","E=NF Energia;T=Todos;N=Nao Utilizado","","",""     ,"","","N","N","N","",""}) //FR - 22/09/2020

//------------------------------------------------------------------------------------------------------------------------//
//FR 24/09/2020: Adicionado por Flávia Rocha, guarda regra para XML sem tag de vencimento - específico Kroma 
//Quando o XML não possuir a tag do vencimento, o mesmo será calculado com base no número que está neste parâmetro
//se estiver vazio, não classificará a nf
//------------------------------------------------------------------------------------------------------------------------//
AADD(aSx6,{cFilSm,"XM_DIASVCT" ,"N","Dias uteis para calculo do vencto NF Energia"		,"Dias uteis para calculo do vencto NF Energia","","Dias uteis para calculo do vencto NF Energia","","",""     ,"","","0","0","0","",""}) //FR - 22/09/2020

//------------------------------------------------------------------------------------------------------------------------//
//HMS 09/10/2020: Adicionado por Heverton Marcondes, para não ficar toda vez rodando atualização de municipio, grava a ultima vez que rodou 
//------------------------------------------------------------------------------------------------------------------------//
AADD(aSx6,{cFilSm,"XM_DATAMUN" ,"C","Data da Ultima Verificacao de atualizacao de municipio"        ,"Data da Ultima Verificacao de atualizacao de municipio","","Data da Ultima Verificacao de atualizacao de municipio" ,"Data da Ultima Verificacao de atualizacao de municipio","",""	,"","","20201001","20201001","20201001","",""})
AADD(aSx6,{cFilSm,"XM_DATAVEZ" ,"C","Data da Ultima Verificacao das notas do dia"        		,"Data da Ultima Verificacao das notas do dia"        			,"","Data da Ultima Verificacao das notas do dia"        		,"Data da Ultima Verificacao das notas do dia"        		,"",""	,"","","2020100100"	,"2020100100"	,"2020100100"	,"",""})
AADD(aSx6,{cFilSm,"XM_VEZDIA"  ,"C","Quantas vezes ao dia consulta as notas do dia"        		,"Quantas vezes ao dia consulta as notas do dia"        		,"","Quantas vezes ao dia consulta as notas do dia"        		,"Quantas vezes ao dia consulta as notas do dia"        	,"",""	,"","","0"			,"0"			,"0"			,"",""})


AADD(aSx6,{cFilSm,"XM_QTDNFSE" ,"N","Quantidade de envio por vez ao image converter"    ,"Quantidade de envio por vez ao image converter"        		,"","Quantidade de envio por vez ao image converter"        	,"Quantidade de envio por vez ao image converter"        	,"",""	,"","","25"			,"25"			,"25"			,"",""})
AADD(aSx6,{cFilSm,"XM_MEINFS"  ,"C","Meio de envio ao image 1=FTP 2=API"        		,"Meio de envio ao image 1=FTP 2=API"        					,"","Meio de envio ao image 1=FTP 2=API"        				,"Meio de envio ao image 1=FTP 2=API"        				,"",""	,"","","2"			,"2"			,"2"			,"",""})
//------------------------------------------------------------------------------------------------------------------------//
//FR 12/11/2020: Adicionado por Flávia Rocha, define se utiliza a UM principal do produto qdo for diferente da UM do XML
//               A conversão é realizada pelos campos padrões: B1_CONV, B1_TIPCONV 
//------------------------------------------------------------------------------------------------------------------------//
AADD(aSx6,{cFilSm,"XM_USAUMB1" ,"C","Usa UM Cad.Produto em caso diferença UM Xml"		,"P=Usa UM Cad.Produto;X=Usa UM XML","","","","",""     ,"","","X","X","X","",""}) //FR - 12/11/2020

//------------------------------------------------------------------------------------------------------------------------//
//FR 12/11/2020: Adicionado por Flávia Rocha, define a quantidade de dias a retroagir a partir da Database
//               De forma a filtrar as NF's de Energia por Data de Emissão que serão classificadas automaticamente
//               Específico Kroma Energia 
//------------------------------------------------------------------------------------------------------------------------//
AADD(aSx6,{cFilSm,"XM_KRDIASR" ,"N","Dias a retroagir p/ filtrar NF's Energia"		    ,"Usado no fonte HFXML131","","O nro colocado aqui (x) será usado em Database - x","","",""     ,"","","30","30","30","",""}) //FR - 22/09/2020

AADD(aSx6,{cFilSm,"XM_VISFAL" ,"C","Mostra erro na tela"		,"S=Sim;n=Não;","","S=Sim;N=Não","","",""     ,"","","N","N","N","",""}) //FR - 22/09/2020

AADD(aSx6,{cFilSm,"XM_EMPBLQ"  ,"C","Bloqueia empresa/filial no job"               ,"","","","","",""  ,"","","","","","",""})

//------------------------------------------------------------------------------------------------------------------------//
//NA 02/03/2021: Adicionado por Najla Acemel, define a origem da busca do centro de custo na rotina múltiplos cte:
//               1 - D2_CC - PADRÃO TOTVS
//               2 - B1_CC - CADASTRO PRODUTO
//------------------------------------------------------------------------------------------------------------------------//
AADD(aSx6,{cFilSm,"XM_CENTRO" ,"C","Define origem c.custo multiplo CTE"		,"1=Padrão Totvs;2=Cad.Produto","","","","",""     ,"","","1","1","1","",""}) //NA - 02/03/2021
//------------------------------------------------------------------------------------------------------------------------//
//FR 28/04/2021: Adicionado por Flávia Rocha, para NOVA TELA GESTÃOXML
//               Define se antes da exibição da tela de geração de documentos, serão carregados os dados da última compra
//------------------------------------------------------------------------------------------------------------------------//
AADD(aSx6,{cFilSm,"XM_ULTCOMP" ,"C","Traz Dados Última Compra"		,"S=Sim;N=Não;P=Perguntar;","","S=Sim;N=Não;P=Perguntar","","",""     ,"","","P","P","P","",""}) //FR - 28/04/2021 - NOVA TELA GESTÃOXML

//------------------------------------------------------------------------------------------------------------------------//
//FR 28/04/2021: Adicionado por Flávia Rocha, para NOVA TELA GESTÃOXML
//               Define se atualizará a NCM do SB1 com a NCM do XML
//------------------------------------------------------------------------------------------------------------------------//
AADD(aSx6,{cFilSm,"XM_NCMXML" ,"C","Atualiza NCM do SB1 c/ NCM do XML"		,"S=Sim;N=Não;P=Perguntar;","","S=Sim;N=Não;P=Perguntar","","",""     ,"","","P","P","P","",""}) //FR - 28/04/2021 - NOVA TELA GESTÃOXML

//------------------------------------------------------------------------------------------------------------------------//
//FR 17/05/2021: Adicionado por Flávia Rocha, para NOVA TELA GESTÃOXML
//               Define se usa a nova tela amarração ou não
//------------------------------------------------------------------------------------------------------------------------//
AADD(aSx6,{cFilSm,"XM_NOVATEL" ,"C","Usa Nova Tela GestãoXML ?"		,"S=Sim;N=Não","","S=Sim;N=Não","","",""     ,"","","N","N","N","",""}) 

//NA 15/04/2021: Adicionado por Najla Acemel, define a quantidade de requisição da mesma chave dentro de uma hora no sefaz:
//              
//------------------------------------------------------------------------------------------------------------------------//
AADD(aSx6,{cFilSm,"XM_NREQSEF" ,"N","Quantidade de Requisição por hora no Sefaz"		,"Quantidade de Requisição por hora no Sefaz","","Quantidade de Requisição por hora no Sefaz","","",""     ,"","","5","5","5","",""}) //NA - 15/04/2021
AADD(aSx6,{cFilSm,"XM_ESTPAD" ,"C","Estorno de xml pela rotina padrao?"		,"Estorno de xml pela rotina padrao?","","Estorno de xml pela rotina padrao?","","",""     ,"","","N","N","N","",""}) 
//------------------------------------------------------------------------------------------------------------------------//
//FR 16/08/2021: Adicionado por Flávia Rocha, para exibir nova tela análise fiscal / Sim ou Não
//------------------------------------------------------------------------------------------------------------------------//
AADD(aSx6,{cFilSm,"XM_ANAFIS" ,"C","Analise Fiscal Modelo Arvore?"		,"S=Sim;N=Não","","S=Sim;N=Não","","",""     ,"","","N","N","N","",""})

//------------------------------------------------------------------------------------------------------------------------//
//FR 28/10/2021: Adicionado por Flávia Rocha, para Daikin e Todos clientes - CADASTRA FORNECEDOR SA2 AUTOMATIZADO
//------------------------------------------------------------------------------------------------------------------------//
AADD(aSx6,{cFilSm,"XM_SA2AUTO" ,"C","Cad Fornec. Automat Classif NF ?"			,"S=Sim;N=Não","","S=Sim;N=Não","","",""     ,"","","N","N","N","",""}) 
AADD(aSx6,{cFilSm,"XM_ZBCAUTO" ,"C","Cadastra Amarra. Automat?"					,"S=Sim;N=Não","","S=Sim;N=Não","","",""     ,"","","N","N","N","",""}) 
AADD(aSx6,{cFilSm,"XM_ZBCTES"  ,"C","TES Amarra. Automat"		    			,""           ,"",""           ,"","",""     ,"","","","","","",""}) 
AADD(aSx6,{cFilSm,"XM_ZBCCC"   ,"C","Centro Custo Amarra. Automat"  			,""           ,"",""           ,"","",""     ,"","","","","","",""}) 
AADD(aSx6,{cFilSm,"XM_ZBCCOND" ,"C","Cond.Pagto Amarra. Automat"    			,""           ,"",""           ,"","",""     ,"","","","","","",""}) 

//FR - 21/12/2021:
AADD(aSx6,{cFilSm,"XM_SA2AUTD" ,"C","Cad Fornec. Automat Downld XML ?"			,"S=Sim;N=Não","","S=Sim;N=Não","","",""     ,"","","N","N","N","",""})

//------------------------------------------------------------------------------------------------------------------------//
//FR 17/02/2022: Adicionado por Flávia Rocha, habilita/desabilita Log Consulta Fornecedor - Solicitado por Rafael Lobitsky
//------------------------------------------------------------------------------------------------------------------------//

//------------------------------------------------------------------------------------------------------------------------//
//FR 26/08/2022: Adicionado por Henrique Tofanelli, habilita/desabilita Download de XML Resumida - Solicitado por Rafael Lobitsky
//------------------------------------------------------------------------------------------------------------------------//
AADD(aSx6,{cFilSm,"XM_BXRESUM" ,"C","Baixar XML NFe Resumido?"			,"S=Sim;N=Não","","S=Sim;N=Não","","",""     ,"","","N","N","N","",""})

//------------------------------------------------------------------------------------------------------------------------//
//FR 05/10/2022: Adicionado por Henrique Tofanelli, habilita/desabilita Download de CTE que oCliente não é o Tomador - Solicitado por Rafael Lobitsky
//------------------------------------------------------------------------------------------------------------------------//
AADD(aSx6,{cFilSm,"XM_BXCTETM" ,"C","Baixar Apenas CTE Tomador?"			,"S=Sim;N=Não","","S=Sim;N=Não","","",""     ,"","","N","N","N","",""})

AADD(aSx6,{cFilSm,"XM_LOGFORN" ,"C","Grava Log Consulta Fornecedor?"		,"S=Sim;N=Não","","S=Sim;N=Não","","",""     ,"","","N","N","N","",""})
//FR - 09/07/2022 - específico para Forceline: 
AADD(aSx6,{cFilSm,"XM_IMPCST" ,"C","Indica se imprime informacoes do ICM ST na Danfe"	,"no campo da descrição do produto","","S=Sim;N=Não","","",""     ,"","","N","N","N","",""})

//FR - 09/07/2022 - específico para KITCHENS:
AADD(aSx6,{cFilSm,"XM_PESQNCM" ,"C","Indica como fará a pesquisa de produto na SB1:"	,"Opções: 1-B1_POSIPI = NCM ; 2-B1_COD = NCM","1=traz qualquer B1_COD com a NCM informada;","2= Traz o B1_COD que seja igual a NCM informada (específico Kitchens)","","",""     ,"","","1","1","1","",""})

AADD(aSx6,{cFilSm,"XM_SB1AUTO" ,"C","Habilita gravação robótica do produto na SB1?"		,"S=Sim;N=Não","","S=Sim;N=Não","","",""     ,"","","N","N","N","",""})

AADD(aSx6,{cFilSm,"XM_KITVENC" ,"C","Habilita o campo Dt.1o. vencimento na geração do PC (KITCHENS)"		,"S=Sim;N=Não","","S=Sim;N=Não","","",""     ,"","","N","N","N","",""})


AADD(aSx6,{cFilSm,"XM_KITMODE" ,"C","Habilita quais modelos podem gerar PC de forma robótica (KITCHENS)"	,"55/RP","","55/RP","","",""     ,"","","55/RP","55/RP","55/RP","",""})

AADD(aSx6,{cFilSm,"XM_KIPCZBT" ,"C","Força Amarração de Pedido com o PC gravado na ZBT"						,"S=Sim;N=Não","","S=Sim;N=Não","","",""     ,"","","N","N","N","",""})
//FR - 09/07/2022 - específico para KITCHENS

AADD(aSx6,{cFilSm,"XM_ATUMANF" ,"C","HABILITA SE ATUALIZA OU NAO CABECALHO ZBZ"			,"ZBZ_MANIF COM ZBE MANIFESTAÇÕES","","S=Sim;N=Não","","",""     ,"","","N","N","N","",""})

//----------------------------------------------------------------------------------------------------------------//
//Alteração:
//FR - 05/08/2022 - PROJETO POLITEC
//Define os CFOPs de XML combustivel - que serão utilizados como filtro para selecionar para classificação
//de NF direto pelo XML (não tem integração com TICKET)
//----------------------------------------------------------------------------------------------------------------//
AADD(aSx6,{cFilSm,"XM_CFOCOMB" ,"C","Informa CFOPs XML Combustivel"	,"","","Classif. direto via XML","","",""     ,"","","5929,5949","5929,5949","5929,5949","",""})

AADD(aSx6,{cFilSm,"XM_USASTAT" ,"C","Habilita se usa ou nao status XML"	,"S=Sim;N=Não","","S=Sim;N=Não","","",""     ,"","","N","N","N","",""})

//EG 10/11/2022: Adicionado por Erick Gonçalves, habilita/desabilita preenchimento do tipo do frete na SF1
AADD(aSx6,{cFilSm,"XM_TPFRETE" ,"C","Habilita o prenchimento do Tipo do Frete"	,"S=Sim;N=Não","","S=Sim;N=Não","","",""     ,"","","N","N","N","",""})

//FR - 19/10/2022 - MBIOLOG - PARÂMETRO QUE ATIVA O DESMEMBRAMENTO DA QTDE DO PRODUTO POR LOTE
AADD(aSx6,{cFilSm,"XM_DESLOTE" ,"C","Habilita se desmembra a Qtde Por Lote"			,"S=Sim;N=Não","","S=Sim;N=Não","","",""     ,"","","N","N","N","",""})
AADD(aSx6,{cFilSm,"XM_LOTEFOR" ,"C","Indica se Usa o Nro.Lote do Fornecedor"		,"S=Sim;N=Não","","S=Sim;N=Não","","",""     ,"","","N","N","N","",""})
//FR - 19/10/2022 - MBIOLOG - PARÂMETRO QUE ATIVA O DESMEMBRAMENTO DA QTDE DO PRODUTO POR LOTE

//FR - 14/11/2022 - PROJETO COPAG VALIDAÇÃO SEFAZ AMAZONAS
AADD(aSx6,{cFilSm,"XM_CFEXSPD" ,"C","CFOPs informados aqui de NFs que não serão"	,"enviadas no sped buscando informações do xml","","CFOPs exceçao no sped fiscal"			,"","",""     ,"","","","","","",""})
AADD(aSx6,{cFilSm,"XM_SPEDFIS" ,"C","Habilita se irá mostrar no Rel.Pre-Auditoria"	,"Fiscal críticas relacionados ao sped fiscal" ,"","S=Sim -> Habilita; N=Não -> Desabilita"	,"","",""     ,"","","N","N","N","",""})
//FR - 14/11/2022 - PROJETO COPAG VALIDAÇÃO SEFAZ AMAZONAS
  
//FR - 28/04/2023 - VYDENCE - SOLICITOU QUE NA TELA DE SELEÇÃO DE PEDIDOS NÃO VENHA MARCADO, 
//ENTÃO CRIEI ESTE PARÂMETRO PARA DEFINIR SE JÁ VEM MARCADO OU NÃO
AADD(aSx6,{cFilSm,"XM_PCMARK"  ,"C","Traz Pedido(s) Marcado(s) [x]?"			    ,"","","","","",""  ,"","","S","S","S","",""})

//FR - 08/05/2023 - COPAG PEDIU QUE O USO DO (*) ASTERISCO POSSA SER OPCIONAL, CRIO ESTE PARÂMETRO COM DEFAULT "S" PARA NÃO AFETAR OS DEMAIS CLIENTES
//A COPAG PARA NÃO USAR *, MUDA PARA N 
AADD(aSx6,{cFilSm,"XM_ASTERXP"  ,"C","USA * P/ UNIFICAR VÁRIOS ITENS NF C/ APENAS 1 DO "			    ,"","","PC","","",""  ,"","","S","S","S","",""})
                                      //DESCRIÇÃO                                                               CONTINUAÇÃO DESCRIÇÃO É ONDE TÁ ESSA PALAVRA: PC
ProcRegua(Len(aSX6))

dbSelectArea("SX6")
dbSetOrder(1)

For i:= 1 To Len(aSX6)
	If !Empty(aSX6[i][2])
		If !dbSeek(aSX6[i,1]+aSX6[i,2])
			lSX6	:= .T.
			If !(aSX6[i,2]$cAlias)
				cAlias += aSX6[i,2]+"/"
			EndIf
			RecLock("SX6",.T.)
			For j:=1 To Len(aSX6[i])
				If Valtype(aEstrut[j]) == "C"
					If !Empty(FieldName(FieldPos(aEstrut[j])))
						FieldPut(FieldPos(aEstrut[j]),aSX6[i,j])
					EndIf
				Else 
					//erro
					conout("UPDIF001 - variavel: " + aEstrut[j] + "-> tipo: " + Valtype(aEstrut[j]))
				Endif 
			Next j
			
			dbCommit()
			MsUnLock()
			IncProc("Atualizando Parametros...") //
		Else
			j := 0
			Do While .Not. SX6->( Eof() ) .And. SX6->X6_FIL == aSX6[i,1] .And. AllTrim(SX6->X6_VAR) == AllTrim(aSX6[i,2])
				j++
				If j >= 2
					RecLock("SX6",.F.)
					SX6->( dbDelete() )
					SX6->( dbCommit() )
					SX6->( MsUnLock() )
					If !(aSX6[i,2]$cDeldp)
						cDeldp += aSX6[i,2]+"/"
					EndIf
				EndIf
				SX6->( dbSkip() )
			EndDo
		EndIf
	EndIf
Next i

If lSX6
	lAltera := .T.
	AutoGrLog( 'Incluidos novos parametros. Verifique as suas configuracoes e funcionalidades : '+cAlias+CHR(13)+CHR(10) )
EndIf

If .Not. Empty( cDeldp )
	lAltera := .T.
	AutoGrLog( 'Parametros Duplicados que foram Ajustados : '+cDeldp+CHR(13)+CHR(10) )
EndIf

Return cTexto


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³IFAtuSIX  ³ Autor ³Roberto Souza          ³ Data ³04/05/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de processamento da gravacao do SIX                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Atualizacao COM                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function IFAtuSIX()
Local cTexto    := ''
Local lSix      := .F.
Local aSix      := {}
Local aEstrut   := {}
//Local aOld      := {}
//Local nOld      := 0
Local nI         := 0
Local nJ         := 0
Local cAlias    := ''
//Local lDelInd   := .F.
//Local cDelInd   := ''
Local lTemZBB   := ( .NOT. Empty( xZBB ) )

aEstrut:= {"INDICE","ORDEM","CHAVE","DESCRICAO","DESCSPA","DESCENG","PROPRI","F3","NICKNAME","SHOWPESQ"}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Indices que serao criados apenas para o Brasil.                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lBossKey
	Aadd(aSIX,{xZBX,"1",xZBX_+"FILIAL+"+xZBX_+"CODCLI+"+xZBX_+"LOJCLI","Codigo Cliente + Loja","Codigo Cliente + Loja","Codigo Cliente + Loja","U","","","S"})
	Aadd(aSIX,{xZBX,"2",xZBX_+"FILIAL+"+xZBX_+"CNPJ_L","CNPJ Liberado","CNPJ Liberado","CNPJ Liberado","U","","","S"})
EndIf

//Tabela ZB5
Aadd(aSIX,{xZB5,"1",xZB5_+"FILIAL+"+xZB5_+"CGC+"+xZB5_+"PRODFO" ,"CGC/CPF+Prod. do For" ,"CGC/CPF+Prod. do For","CGC/CPF+Prod. do For","U","","","S"})
Aadd(aSIX,{xZB5,"2",xZB5_+"FILIAL+"+xZB5_+"CGCC+"+xZB5_+"PRODFO","CGC/CPF+Prod. do Cli" ,"CGC/CPF+Prod. do Cli","CGC/CPF+Prod. do Cli","U","","","S"})
Aadd(aSIX,{xZB5,"3",xZB5_+"FILIAL+"+xZB5_+"CGC+"+xZB5_+"PRODFI" ,"CGC/CPF+Prod.Interno" ,"CGC/CPF+Prod.Interno","CGC/CPF+Prod.Interno","U","","","S"})
 
//Tabelz ZBZ
Aadd(aSIX,{xZBZ,"1",xZBZ_+"FILIAL+"+xZBZ_+"CNPJ+"+xZBZ_+"CHAVE+"+xZBZ_+"DTRECB","CNPJ+Chave+Dt. Rec. XML","CNPJ+Chave+Dt. Rec. XML","CNPJ+Chave+Dt. Rec. XML","U","","","S"})
Aadd(aSIX,{xZBZ,"2",xZBZ_+"FILIAL+"+xZBZ_+"NOTA+"+xZBZ_+"SERIE+"+xZBZ_+"CNPJ","Doc Fiscal+Serie+CNPJ","Doc Fiscal+Serie+CNPJ","Doc Fiscal+Serie+CNPJ","U","","","S"})
Aadd(aSIX,{xZBZ,"3",xZBZ_+"CHAVE","Chave","Chave","Chave","U","","","N"})

Aadd(aSIX,{xZBZ,"4",xZBZ_+"FILIAL+"+xZBZ_+"FORNEC+"+xZBZ_+"NOTA+"+xZBZ_+"SERIE","Fornecedor+Doc Fiscal+Serie","Fornecedor+Doc Fiscal+Serie","Fornecedor+Doc Fiscal+Serie","U","","","S"})
Aadd(aSIX,{xZBZ,"5",xZBZ_+"FILIAL+"+xZBZ_+"DTRECB+"+xZBZ_+"FORNEC+"+xZBZ_+"NOTA+"+xZBZ_+"SERIE","Dt. Rec. XML+Fornecedor+Doc Fiscal+Serie","Dt. Rec. XML+Fornecedor+Doc Fiscal+Serie","Dt. Rec. XML+Fornecedor+Doc Fiscal+Serie","U","","","S"})

Aadd(aSIX,{xZBZ,"6",xZBZ_+"FILIAL+"+xZBZ_+"MODELO+"+xZBZ_+"NOTA+"+xZBZ_+"SERIE+"+xZBZ_+"CNPJ","Modelo+Doc Fiscal+Serie+CNPJ","Modelo+Doc Fiscal+Serie+CNPJ","Modelo+Doc Fiscal+Serie+CNPJ","U","","","S"})
Aadd(aSIX,{xZBZ,"7",xZBZ_+"MODELO+"+xZBZ_+"CHAVE","Modelo+Chave","Modelo+Chave","Modelo+Chave","U","","","N"})

Aadd(aSIX,{xZBZ,"8",xZBZ_+"FILIAL+"+xZBZ_+"CODFOR+"+xZBZ_+"LOJFOR+"+xZBZ_+"PRENF","Cod Forn+Loja+Stat XML","Cod Forn+Loja+Stat XML","Cod Forn+Loja+Stat XML","U","","","S"})
Aadd(aSIX,{xZBZ,"9",xZBZ_+"FILIAL+"+xZBZ_+"CHAVE","Chave","Chave","Chave","U","","","S"})//nova indice para ser tratado com multiplas empresas

//FR - 09/11/2020 - novo índice: Data emissão NF
Aadd(aSIX,{xZBZ,"A",xZBZ_+"FILIAL+"+xZBZ_+"DTNFE","Dt.Emissao NF","Dt.Emissao NF","Dt.Emissao NF","U","","","S"})
//ZBB
If lTemZBB
	Aadd(aSIX,{xZBB,"1",xZBB_+"FILIAL+"+xZBB_+"FORNEC+"+xZBB_+"LOJA+"+xZBB_+"PROD+"+xZBB_+"PEDIDO+"+xZBB_+"ITEM+"+xZBB_+"ATUAL","Fornec+Loja+Prod+Atual","Fornec+Loja+Prod+Atual","Fornec+Loja+Prod+Atual","U","","","S"})
	Aadd(aSIX,{xZBB,"2",xZBB_+"FILIAL+"+xZBB_+"PEDIDO+"+xZBB_+"ITEM"                  					                       ,"Pedido+Item"           ,"Pedido+Item"           ,"Pedido+Item"           ,"U","","","S"})
EndIf

//ZBS -> Indices da ZBS
Aadd(aSIX,{xZBS,"1",xZBS_+"FILIAL+"+xZBS_+"CHAVE"							  ,"Chave"     ,"Chave"     ,"Chave"     ,"U","","","S"})
Aadd(aSIX,{xZBS,"2",xZBS_+"FILIAL+"+xZBS_+"ST"	 							  ,"Status"    ,"Status"    ,"Status"    ,"U","","","S"})
Aadd(aSIX,{xZBS,"3",xZBS_+"CHAVE"											  ,"Chave(S/F)","Chave(S/F)","Chave(S/F)","U","","","N"})
Aadd(aSIX,{xZBS,"4",xZBS_+"FILIAL+"+xZBS_+"DHRECB"							  ,"Dt Autor"  ,"Dt Autor"  ,"Dt Autor"  ,"U","","","S"})
Aadd(aSIX,{xZBS,"5",xZBS_+"FILIAL+"+xZBS_+"CNPJEM+"+xZBS_+"CNF+"+xZBS_+"SERIE","Fornecedor","Fornecedor","Fornecedor","U","","","S"})
Aadd(aSIX,{xZBS,"6",xZBS_+"FILIAL+"+xZBS_+"CNF+"+xZBS_+"SERIE+"+xZBS_+"CNPJEM","Doc/Serie" ,"Doc/Serie" ,"Doc/Serie" ,"U","","","S"})
Aadd(aSIX,{xZBS,"7",xZBS_+"FILIAL+"+xZBS_+"MODELO+"+xZBS_+"DHRECB"			  ,"Modelo+Dt" ,"Modelo+Dt" ,"Modelo+Dt" ,"U","","","S"})

//ZBA
Aadd(aSIX,{xZBA,"1",xZBA_+"FILIAL+"+xZBA_+"CODUSR","CodUsuario","CodUsuario","CodUsuario","U","","","S"})

//ZBE
Aadd(aSIX,{xZBE,"1",xZBE_+"FILIAL+"+xZBE_+"CHAVE+"+xZBE_+"TPEVE+"+xZBE_+"SEQEVE","Chave"     ,"Chave"     ,"Chave"     ,"U","","","S"})
Aadd(aSIX,{xZBE,"2",xZBE_+"CHAVE"											    ,"Chave(S/F)","Chave(S/F)","Chave(S/F)","U","","","S"})
Aadd(aSIX,{xZBE,"3",xZBE_+"FILIAL+"+xZBE_+"TPEVE+"+xZBE_+"CHAVE+"+xZBE_+"SEQEVE","Tp Evento" ,"Tp Evento" ,"Tp Evento" ,"U","","","S"})
Aadd(aSIX,{xZBE,"4",xZBE_+"FILIAL+"+xZBE_+"DTRECB"							    ,"Dt Receb"  ,"Dt Receb"  ,"Dt Receb"  ,"U","","","S"})

//ZYX
Aadd(aSIX,{xZYX,"1",xZYX_+"FILIAL+"+xZYX_+"CHAVE+"+xZYX_+"SEQ"					,"Chave+Seq" ,"Chave+Seq" ,"Chave+Seq" ,"U","","","S"})

//ZBC
Aadd(aSIX,{xZBC,"1",xZBC_+"FILIAL+"+xZBC_+"CODFOR+"+xZBC_+"LOJFOR+"+xZBC_+"PROD" ,"CodFor+Loja+Prod","CodFor+Loja+Prod","CodFor+Loja+Prod","U","","","S"})
Aadd(aSIX,{xZBC,"2",xZBC_+"FILIAL+"+xZBC_+"CGC+"+xZBC_+"PROD"                  	,"CNPJ+Produto"    ,"CNPJ+Produto"    ,"CNPJ+Produto"    ,"U","","","S"})
Aadd(aSIX,{xZBC,"3",xZBC_+"FILIAL+"+xZBC_+"TES+"+xZBC_+"PROD"                  	,"TES+Produto"     ,"TES+Produto"     ,"TES+Produto"     ,"U","","","S"})

//ZBI
Aadd(aSIX,{xZBI,"1",xZBI_+"FILIAL+"+xZBI_+"FTP"									,"Int Externa" ,"Int Externa" ,"Int Externa" ,"U","","","S"})
Aadd(aSIX,{xZBI,"2",xZBI_+"ST"													,"Status     " ,"status     " ,"Status     " ,"U","","","S"})
Aadd(aSIX,{xZBI,"3",xZBI_+"FILIAL+"+xZBI_+"ARQ"									,"Arquivo"     ,"Arquivo"     ,"Arquivo"     ,"U","","","S"})

//ZBO
Aadd(aSIX,{xZBO,"1",xZBO_+"FILIAL+"+xZBO_+"CODSEQ"								,"C.OCorrencia","C.OCorrencia","C.OCorrencia","U","","","S"})
Aadd(aSIX,{xZBO,"2",xZBO_+"FILIAL+"+xZBO_+"TPOCOR+"+xZBO_+"CODSEQ"				,"T.Ocorrenica","T.Ocorrenica","T.Ocorrenica","U","","","S"})
Aadd(aSIX,{xZBO,"3",xZBO_+"FILIAL+"+xZBO_+"DTOCOR+"+xZBO_+"HROCOR"				,"Data/Hora Oc","Data/Hora Oc","Data/Hora Oc","U","","","S"})
Aadd(aSIX,{xZBO,"4",xZBO_+"FILIAL+"+xZBO_+"TPOCOR+"+xZBO_+"CHAVE+"+xZBO_+"ARQ"	,"Tp+Chave+Arq","Chave+Arq"   ,"Chave+Arq"   ,"U","","","S"})
Aadd(aSIX,{xZBO,"5",xZBO_+"ST+"+xZBO_+"DTOCOR+"+xZBO_+"HROCOR"					,"Status"      ,"Status"      ,"Status"      ,"U","","","S"})

//ZBT
Aadd(aSIX,{xZBT,"1",xZBT_+"FILIAL+"+xZBT_+"CHAVE+"+xZBT_+"PEDIDO+"+xZBT_+"ITEMPC"  	,"Chave+Ped. Compra+Item Pedido"      	,"Chave+Ped. Compra+Item Pedido"       	,"Chave+Ped. Compra+Item Pedido"       	,"U","","","S"})
Aadd(aSIX,{xZBT,"2",xZBT_+"CHAVE"											       	,"Chave (sem filial)"                 	,"Chave (sem filial)"                  	,"Chave (sem filial)"                  	,"U","","","S"})
Aadd(aSIX,{xZBT,"3",xZBT_+"FILIAL+"+xZBT_+"PEDIDO+"+xZBT_+"ITEMPC"                 	,"Ped. Compra+Item Pedido"            	,"Ped. Compra+Item Pedido"             	,"Ped. Compra+Item Pedido"             	,"U","","","S"})
Aadd(aSIX,{xZBT,"4",xZBT_+"FILIAL+"+xZBT_+"PRODUT+"+xZBT_+"PEDIDO+"+xZBT_+"ITEMPC" 	,"Cod.Produto+Ped. Compra+Item Pedido"	,"Cod.Produto+Ped. Compra+Item Pedido" 	,"Cod.Produto+Ped. Compra+Item Pedido" 	,"U","","","S"}) 
Aadd(aSIX,{xZBT,"5",xZBT_+"FILIAL+"+xZBT_+"PRODUT+"+xZBT_+"ITEM" 					,"Cod.Prod.Forn+Item XML"				,"Cod.Prod.Forn+Item XML" 				,"Cod.Prod.Forn+Item XML" 				,"U","","","S"}) 

//ZBM
Aadd(aSIX,{xZBM,"1",xZBM_+"FILIAL+"+xZBM_+"COD"								  ,"Filial+Codigo Municipio"      ,"Filial+Codigo Municipio"       ,"Filial+Codigo Municipio"       ,"U","","","S"})
Aadd(aSIX,{xZBM,"2",xZBM_+"FILIAL+"+xZBM_+"MUNIC"						      ,"Filial+Nome Municipio"        ,"Filial+Nome Municipio"         ,"Filial+Nome Municipio"         ,"U","","","S"})
Aadd(aSIX,{xZBM,"3",xZBM_+"FILIAL+"+xZBM_+"EST"						      	  ,"Filial+Estado"        		  ,"Filial+Estado"                 ,"Filial+Estado"                 ,"U","","","S"})

//ZBN
Aadd(aSIX,{xZBN,"1",xZBN_+"FILIAL+"+xZBN_+"COD"								  ,"Filial+Codigo Municipio"      ,"Filial+Codigo Municipio"       ,"Filial+Codigo Municipio"       ,"U","","","S"})
Aadd(aSIX,{xZBN,"2",xZBN_+"FILIAL+"+xZBN_+"FORNEC+"+xZBN_+"LOJFOR"			  ,"Filial+Fornecedor+Loja"       ,"Filial+Fornecedor+Loja"        ,"Filial+Fornecedor+Loja"        ,"U","","","S"})

//ZBD
Aadd(aSIX,{xZBD,"1",xZBD_+"FILIAL+"+xZBD_+"ID"								  ,"Filial+ID"      		,"Filial+ID"       			,"Filial+ID"       			,"U","","","S"})
Aadd(aSIX,{xZBD,"2",xZBD_+"FILIAL+"+xZBD_+"ARQUIV"							  ,"Filial+Arquivo" 		,"Filial+Arquivo" 			,"Filial+Arquivo"  			,"U","","","S"})
Aadd(aSIX,{xZBD,"3",xZBD_+"FILIAL+"+xZBD_+"TAM"								  ,"Filial+Tamanho" 		,"Filial+Tamanho"  			,"Filial+Tamanho"  			,"U","","","S"})
Aadd(aSIX,{xZBD,"4",xZBD_+"FILIAL+"+xZBD_+"ARQUIV+"+xZBD_+"TAM"				  ,"Filial+Arquivo+Tamamho" ,"Filial+Arquivo+Tamanho"  	,"Filial+Arquivo+Tamanho"  	,"U","","","S"})

//ZBF
Aadd(aSIX,{xZBF,"1",xZBF_+"FILIAL+"+xZBF_+"CHAVE"								  ,"Filial+Chave"      ,"Filial+Chave"       ,"Filial+Chave"       ,"U","","","S"})
Aadd(aSIX,{xZBF,"2",xZBF_+"FILIAL+"+xZBF_+"CHAVE+"+xZBF_+"NUMCON"				  ,"Filial+Chave+Num Consulta"      ,"Filial+Chave+Num Consulta"       ,"Filial+Chave+Num Consulta"       ,"U","","","S"})

//FR - 17/02/2022 - Log Consulta Fornecedor
//ZBG
Aadd(aSIX,{xZBG,"1",xZBG_+"CHAVE+" +xZBG_+"DTCONS+"+xZBG_+"HRCONS"				,"Chave+Dt.Hr.Consulta"     ,"Chave+Dt.Hr.Consulta"	,"Chave+Dt.Hr.Consulta"     ,"U","","","S"})
Aadd(aSIX,{xZBG,"2",xZBG_+"CNPJ+"  +xZBG_+"DTCONS+"+xZBG_+"HRCONS"  			,"CNPJ+Dt.Hr.Consulta"		,"CNPJ+Dt.Hr.Consulta" 	,"CNPJ+Dt.Hr.Consulta"  	,"U","","","S"})
Aadd(aSIX,{xZBG,"3",xZBG_+"DTCONS+"+xZBG_+"CNPJ"                  				,"Dt.Hr.Consulta+CNPJ"		,"Dt.Hr.Consulta+CNPJ" 	,"Dt.Hr.Consulta+CNPJ"  	,"U","","","S"})

//ZBH
Aadd(aSIX,{xZBH,"1",xZBH_+"FILIAL+"+xZBH_+"COD"								  ,"Filial+Codigo"      ,"Filial+Codigo"      ,"Filial+Codigo"      ,"U","","","S"})
Aadd(aSIX,{xZBH,"2",xZBH_+"FILIAL+"+xZBH_+"TIPO"						  	  ,"Filial+Tipo"        ,"Filial+Tipo"        ,"Filial+Tipo"        ,"U","","","S"})
Aadd(aSIX,{xZBH,"3",xZBH_+"FILIAL+"+xZBH_+"DESC"  						  	  ,"Filial+Desc"        ,"Filial+Desc"        ,"Filial+Desc"        ,"U","","","S"})


ProcRegua(Len(aSIX))

dbSelectArea("SIX")
SIX->(DbSetOrder(1))
For nI := 1 To Len(aSIX)
	If !MsSeek(aSIX[nI,1]+aSIX[nI,2])
		RecLock("SIX",.T.)
	Else
		RecLock("SIX",.F.)
	EndIf
	If UPPER(AllTrim(CHAVE)) != UPPER(Alltrim(aSIX[nI,3])) .OR. UPPER(AllTrim(SHOWPESQ)) != UPPER(Alltrim(aSIX[nI,10]))
		
		//FR - 30/03/2022 - Alteração - Ajuste para simular o erro reportado "alias não existe"		
		If Ascan(aArqUpd, Alltrim(aSIX[nI,1])) == 0
			aAdd(aArqUpd, Alltrim(aSIX[nI,1]))
		Endif
		//FR - 30/03/2022 - Alteração - Ajuste para simular o erro reportado "alias não existe"
		lSix := .T.
		If !(aSIX[nI,1]$cAlias)
			cAlias += aSIX[nI,1]+"/"
		EndIf
		For nJ:=1 To Len(aSIX[nI])
			If FieldPos(aEstrut[nJ])>0
				FieldPut(FieldPos(aEstrut[nJ]),aSIX[nI,nJ])
			EndIf
		Next nJ
		dbCommit()
		AutoGrLog( (aSix[nI][1] + " - " + aSix[nI][3] + Chr(13) + Chr(10)) )
		//TcInternal(60,RetSqlName(aSix[nI,1]) + "|" + RetSqlName(aSix[nI,1]) + aSix[nI,2]) //Exclui sem precisar baixar o TOP
	EndIf
	MsUnLock()
	IncProc("Atualizando índices...")
Next i

If lSix
	lAltera := .T.
	AutoGrLog( "Indices atualizados  : "+cAlias+CHR(13)+CHR(10) )
EndIf

Return cTexto

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³IFAtuSX7 ³ Autor ³Marcos Favaro           ³ Data ³04/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de processamento da gravacao do SX7                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Atualizacao COM                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function IFAtuSX7()
Local aSX7   := {}
Local aEstrut:= {}
Local i      := 0
Local j      := 0
Local lSX7	 := .F.
Local cTexto := ''
aEstrut:= {"X7_CAMPO","X7_SEQUENC","X7_REGRA","X7_CDOMIN","X7_TIPO","X7_SEEK","X7_ALIAS","X7_ORDEM","X7_CHAVE","X7_CONDIC","X7_PROPRI"}

aAdd(aSX7,{xZB5_+"FORNEC" ,"001","M->"+xZB5_+"NOME:=SA2->A2_NOME"     ,xZB5_+"NOME"  ,"P","S","SA2",1,"xFilial('SA2')+M->"+xZB5_+"FORNEC" ,"!EMPTY(M->"+xZB5_+"FORNEC)","U"})
aAdd(aSX7,{xZB5_+"FORNEC" ,"002","M->"+xZB5_+"LOJFOR:=SA2->A2_LOJA"   ,xZB5_+"LOJFOR","P","S","SA2",1,"xFilial('SA2')+M->"+xZB5_+"FORNEC" ,"!EMPTY(M->"+xZB5_+"FORNEC)","U"})
aAdd(aSX7,{xZB5_+"FORNEC" ,"003","M->"+xZB5_+"CGC := SA2->A2_CGC"     ,xZB5_+"CGC"   ,"P","S","SA2",1,"xFilial('SA2')+M->"+xZB5_+"FORNEC+M->"+xZB5_+"LOJFOR","!EMPTY(M->"+xZB5_+"FORNEC)","U"})
aAdd(aSX7,{xZB5_+"PRODFI" ,"001","M->"+xZB5_+"DESCPR := SB1->B1_DESC" ,xZB5_+"DESCPR","P","S","SB1",1,"xFilial('SB1')+M->"+xZB5_+"PRODFI" ,"!EMPTY("+xZB5_+"PRODFI)","U"})
aAdd(aSX7,{xZB5_+"CLIENTE","001","M->"+xZB5_+"NOMEC:=SA1->A1_NOME"    ,xZB5_+"NOMEC" ,"P","S","SA1",1,"xFilial('SA1')+M->"+xZB5_+"CLIENTE","!EMPTY(M->"+xZB5_+"CLIENTE)","U"})
aAdd(aSX7,{xZB5_+"CLIENTE","002","M->"+xZB5_+"LOJCLI:= SA1->A1_LOJA"  ,xZB5_+"LOJCLI","P","S","SA1",1,"xFilial('SA1')+M->"+xZB5_+"CLIENTE","!EMPTY(M->"+xZB5_+"CLIENTE)","U"})
aAdd(aSX7,{xZB5_+"CLIENTE","003","M->"+xZB5_+"CGCC := SA1->A1_CGC"    ,xZB5_+"CGCC"  ,"P","S","SA1",1,"xFilial('SA1')+M->"+xZB5_+"CLIENTE+M->"+xZB5_+"LOJCLI","!EMPTY(M->"+xZB5_+"LOJCLI)","U"})
aAdd(aSX7,{xZB5_+"LOJCLI" ,"001","M->"+xZB5_+"CGCC := SA1->A1_CGC"    ,xZB5_+"CGCC"  ,"P","S","SA1",1,"xFilial('SA1')+M->"+xZB5_+"CLIENTE+M->"+xZB5_+"LOJCLI","!EMPTY(M->"+xZB5_+"CLIENTE)","U"})


//Gatilhos da Amarração da classificação automática de combusta (aguas do brasil)
aAdd(aSX7,{xZBC_+"CODFOR" ,"001","M->"+xZBC_+"NOME:=SA2->A2_NOME"     ,xZBC_+"NOME"  ,"P","S","SA2",1,"xFilial('SA2')+M->"+xZBC_+"CODFOR" ,"!EMPTY(M->"+xZBC_+"CODFOR)","U"})
aAdd(aSX7,{xZBC_+"CODFOR" ,"002","M->"+xZBC_+"LOJFOR:=SA2->A2_LOJA"   ,xZBC_+"LOJFOR","P","S","SA2",1,"xFilial('SA2')+M->"+xZBC_+"CODFOR" ,"!EMPTY(M->"+xZBC_+"CODFOR)","U"})
aAdd(aSX7,{xZBC_+"CODFOR" ,"003","M->"+xZBC_+"CGC := SA2->A2_CGC"     ,xZBC_+"CGC"   ,"P","S","SA2",1,"xFilial('SA2')+M->"+xZBC_+"CODFOR+M->"+xZBC_+"LOJFOR","!EMPTY(M->"+xZBC_+"CODFOR)","U"})
aAdd(aSX7,{xZBC_+"LOJFOR" ,"001","M->"+xZBC_+"NOME:= SA2->A2_NOME"    ,xZBC_+"NOME"  ,"P","S","SA2",1,"xFilial('SA2')+M->"+xZBC_+"CODFOR+M->"+xZBC_+"LOJFOR","!EMPTY(M->"+xZBC_+"CODFOR)","U"})
aAdd(aSX7,{xZBC_+"LOJFOR" ,"002","M->"+xZBC_+"CGC := SA2->A2_CGC"     ,xZBC_+"CGC"   ,"P","S","SA2",1,"xFilial('SA2')+M->"+xZBC_+"CODFOR+M->"+xZBC_+"LOJFOR","!EMPTY(M->"+xZBC_+"CODFOR)","U"})
aAdd(aSX7,{xZBC_+"PROD"   ,"001","M->"+xZBC_+"DESCPR := SB1->B1_DESC" ,xZBC_+"DESCPR","P","S","SB1",1,"xFilial('SB1')+M->"+xZBC_+"PROD"   ,"!EMPTY("+xZBC_+"PROD)","U"})


ProcRegua(Len(aSX7))

dbSelectArea("SX7")
dbSetOrder(1)
For i:= 1 To Len(aSX7)
	If !Empty(aSX7[i][1])
		If !dbSeek(PADR(aSX7[i,1],len(SX7->X7_CAMPO))+aSX7[i,2])
			lSX7	 := .T.
			RecLock("SX7",.T.)
			
			For j:=1 To Len(aSX7[i])
				If !Empty(FieldName(FieldPos(aEstrut[j])))
					FieldPut(FieldPos(aEstrut[j]),aSX7[i,j])
				EndIf
			Next j
			dbCommit()
			MsUnLock()
			DbSelectArea("SX3")
			dbSetOrder(2)
			If MsSeek(aSX7[i,1])
				RecLock("SX3")
				SX3->X3_TRIGGER := "S"
				dbCommit()
				MsUnLock()
			EndIf
			DbSelectArea("SX3")
			dbSetOrder(1)
			IncProc("Atualizando Gatilhos...") //
		EndIf
	EndIf
	dbSelectArea("SX7")
Next i      

If lSX7
	lAltera := .T.
	AutoGrLog( 'Incluidos novos Gatilhos. Verifique as suas configuracoes e funcionalidades : '+"SX7"+CHR(13)+CHR(10) )
EndIF

Return(cTexto)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³IFAtuSXB ³ Autor ³Marcos Favaro           ³ Data ³04/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de processamento da gravacao do SXB                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Atualizacao COM                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function IFAtuSXB()
Local aSXB   	:= {}
Local aEstrut	:= {}
Local cAlias	:= ""
Local cTexto	:= ""
Local i      	:= 0
Local j      	:= 0
Local lSXB		:= .F.

aEstrut:= {"XB_ALIAS","XB_TIPO","XB_SEQ","XB_COLUNA","XB_DESCRI","XB_DESCSPA","XB_DESCENG","XB_CONTEM"}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Consultas                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Aadd(aSXB,{"SA2ZB5","1","01","DB","Fornecedores","Fornecedores","Fornecedores","SA2"})
Aadd(aSXB,{"SA2ZB5","2","01","01","Codigo + Loja","Codigo + Loja","Codigo + Loja",""})
Aadd(aSXB,{"SA2ZB5","2","02","02","Razao Social + Loja","Razao Social + Loja","Razao Social + Loja",""})
Aadd(aSXB,{"SA2ZB5","4","01","01","Filial","Filial","Filial","A2_FILIAL"})
Aadd(aSXB,{"SA2ZB5","4","01","02","Codigo","Codigo","Codigo","A2_COD"})
Aadd(aSXB,{"SA2ZB5","4","01","03","Loja","Loja","Loja","A2_LOJA"})
Aadd(aSXB,{"SA2ZB5","4","01","04","Razao Social","Razao Social","Razao Social","A2_NOME"})
Aadd(aSXB,{"SA2ZB5","4","01","05","CGC/CPF","CGC/CPF","CGC/CPF","A2_CGC"})
Aadd(aSXB,{"SA2ZB5","4","02","01","Filial","Filial","Filial","A2_FILIAL"})
Aadd(aSXB,{"SA2ZB5","4","02","02","Razao Social","Razao Social","Razao Social","A2_NOME"})
Aadd(aSXB,{"SA2ZB5","4","02","03","Codigo","Codigo","Codigo","A2_COD"})
Aadd(aSXB,{"SA2ZB5","4","02","04","Loja","Loja","Loja","A2_LOJA"})
Aadd(aSXB,{"SA2ZB5","4","02","05","CGC/CPF","CGC/CPF","CGC/CPF","A2_CGC"})
Aadd(aSXB,{"SA2ZB5","5","01",""  ,""       ,""       ,""       ,"SA2->A2_COD"})
Aadd(aSXB,{"SA2ZB5","5","03",""  ,""       ,""       ,""       ,"SA2->A2_LOJA"})
Aadd(aSXB,{"SA2ZB5","5","04",""  ,""       ,""       ,""       ,"SA2->A2_NOME"})
Aadd(aSXB,{"SA2ZB5","5","05",""  ,""       ,""       ,""       ,"SA2->A2_CGC"})
Aadd(aSXB,{"SA2ZB5","6","01",""  ,""       ,""       ,""       ,"SA2->A2_MSBLQL <> '1' "})

Aadd(aSXB,{"SA1ZB5","1","01","DB","Clientes","Clientes","Clientes","SA1"})
Aadd(aSXB,{"SA1ZB5","2","01","01","Codigo + Loja","Codigo + Loja","Codigo + Loja",""})
Aadd(aSXB,{"SA1ZB5","2","02","02","Razao Social + Loja","Razao Social + Loja","Razao Social + Loja",""})
Aadd(aSXB,{"SA1ZB5","4","01","01","Filial","Filial","Filial","A1_FILIAL"})
Aadd(aSXB,{"SA1ZB5","4","01","02","Codigo","Codigo","Codigo","A1_COD"})
Aadd(aSXB,{"SA1ZB5","4","01","03","Loja","Loja","Loja","A1_LOJA"})
Aadd(aSXB,{"SA1ZB5","4","01","04","Razao Social","Razao Social","Razao Social","A1_NOME"})
Aadd(aSXB,{"SA1ZB5","4","01","05","CGC/CPF","CGC/CPF","CGC/CPF","A1_CGC"})
Aadd(aSXB,{"SA1ZB5","4","02","01","Filial","Filial","Filial","A1_FILIAL"})
Aadd(aSXB,{"SA1ZB5","4","02","02","Razao Social","Razao Social","Razao Social","A1_NOME"})
Aadd(aSXB,{"SA1ZB5","4","02","03","Codigo","Codigo","Codigo","A1_COD"})
Aadd(aSXB,{"SA1ZB5","4","02","04","Loja","Loja","Loja","A1_LOJA"})
Aadd(aSXB,{"SA1ZB5","4","02","05","CGC/CPF","CGC/CPF","CGC/CPF","A1_CGC"})
Aadd(aSXB,{"SA1ZB5","5","01",""  ,""       ,""       ,""       ,"SA1->A1_COD"})
Aadd(aSXB,{"SA1ZB5","5","02",""  ,""       ,""       ,""       ,"SA1->A1_LOJA"})
Aadd(aSXB,{"SA1ZB5","5","04",""  ,""       ,""       ,""       ,"SA1->A1_NOME"})
Aadd(aSXB,{"SA1ZB5","5","05",""  ,""       ,""       ,""       ,"SA1->A1_CGC"})
Aadd(aSXB,{"SA1ZB5","6","01",""  ,""       ,""       ,""       ,"SA1->A1_MSBLQL <> '1' "})

Aadd(aSXB,{"SB1ZB5","1","01","DB","Produto + Descricao","Produto + Descricao","Produto + Descricao","SB1"})
Aadd(aSXB,{"SB1ZB5","2","01","01","Codigo","Codigo","Codigo",""})
Aadd(aSXB,{"SB1ZB5","2","02","03","Descricao + Codigo","Descricao + Codigo","Descricao + Codigo",""})
Aadd(aSXB,{"SB1ZB5","4","01","01","Filial","Filial","Filial","B1_FILIAL"})
Aadd(aSXB,{"SB1ZB5","4","01","02","Codigo","Codigo","Codigo","B1_COD"})
Aadd(aSXB,{"SB1ZB5","4","01","03","Descricao","Descricao","Descricao","B1_DESC"})
Aadd(aSXB,{"SB1ZB5","4","02","01","Filial","Filial","Filial","B1_FILIAL"})
Aadd(aSXB,{"SB1ZB5","4","02","02","Descricao","Descricao","Descricao","B1_DESC"})
Aadd(aSXB,{"SB1ZB5","4","02","03","Codigo","Codigo","Codigo","B1_COD"})
Aadd(aSXB,{"SB1ZB5","5","02",""  ,"","","","SB1->B1_COD"})
Aadd(aSXB,{"SB1ZB5","5","03",""  ,"","","","SB1->B1_DESC"})
Aadd(aSXB,{"SB1ZB5","6","01",""  ,"","","","SB1->B1_MSBLQL <> '1'"})

Aadd(aSXB,{"SA2PRN","1","01","DB","Fornecedores","Fornecedores","Fornecedores","SA2"})
Aadd(aSXB,{"SA2PRN","2","01","01","Codigo + Loja","Codigo + Loja","Codigo + Loja",""})
Aadd(aSXB,{"SA2PRN","2","02","02","Razao Social + Loja","Razao Social + Loja","Razao Social + Loja",""})
Aadd(aSXB,{"SA2PRN","4","01","01","Filial","Filial","Filial","A2_FILIAL"})
Aadd(aSXB,{"SA2PRN","4","01","02","Codigo","Codigo","Codigo","A2_COD"})
Aadd(aSXB,{"SA2PRN","4","01","03","Loja","Loja","Loja","A2_LOJA"})
Aadd(aSXB,{"SA2PRN","4","01","04","Razao Social","Razao Social","Razao Social","A2_NOME"})
Aadd(aSXB,{"SA2PRN","4","01","05","CGC/CPF","CGC/CPF","CGC/CPF","A2_CGC"})
Aadd(aSXB,{"SA2PRN","4","02","01","Filial","Filial","Filial","A2_FILIAL"})
Aadd(aSXB,{"SA2PRN","4","02","02","Razao Social","Razao Social","Razao Social","A2_NOME"})
Aadd(aSXB,{"SA2PRN","4","02","03","Codigo","Codigo","Codigo","A2_COD"})
Aadd(aSXB,{"SA2PRN","4","02","04","Loja","Loja","Loja","A2_LOJA"})
Aadd(aSXB,{"SA2PRN","4","02","05","CGC/CPF","CGC/CPF","CGC/CPF","A2_CGC"})
Aadd(aSXB,{"SA2PRN","5","01",""  ,""       ,""       ,""       ,"SA2->A2_COD"})
Aadd(aSXB,{"SA2PRN","6","01",""  ,""       ,""       ,""       ,"SA2->A2_MSBLQL <> '1' .AND.  SA2->A2_CGC == cCnpj "})
Aadd(aSXB,{"SA2PRN","5","02",""  ,""       ,""       ,""       ,"SA2->A2_LOJA"})

Aadd(aSXB,{"SA2XCG","1","01","DB","Fornecedores","Fornecedores","Fornecedores","SA2"})
Aadd(aSXB,{"SA2XCG","2","01","03","CPF/CNPJ","CPF/CNPJ","CPF/CNPJ",""})
Aadd(aSXB,{"SA2XCG","2","02","01","Codigo + Loja","Codigo + Loja","Codigo + Loja",""})
Aadd(aSXB,{"SA2XCG","2","03","02","Razao Social + Loja","Razao Social + Loja","Razao Social + Loja",""})
Aadd(aSXB,{"SA2XCG","4","01","01","Filial","Filial","Filial","A2_FILIAL"})
Aadd(aSXB,{"SA2XCG","4","01","02","CGC/CPF","CGC/CPF","CGC/CPF","A2_CGC"})
Aadd(aSXB,{"SA2XCG","4","01","03","Codigo","Codigo","Codigo","A2_COD"})
Aadd(aSXB,{"SA2XCG","4","01","04","Loja","Loja","Loja","A2_LOJA"})
Aadd(aSXB,{"SA2XCG","4","01","05","Razao Social","Razao Social","Razao Social","A2_NOME"})
Aadd(aSXB,{"SA2XCG","4","02","01","Filial","Filial","Filial","A2_FILIAL"})
Aadd(aSXB,{"SA2XCG","4","02","02","Codigo","Codigo","Codigo","A2_COD"})
Aadd(aSXB,{"SA2XCG","4","02","03","Loja","Loja","Loja","A2_LOJA"})
Aadd(aSXB,{"SA2XCG","4","02","04","Razao Social","Razao Social","Razao Social","A2_NOME"})
Aadd(aSXB,{"SA2XCG","4","02","05","CGC/CPF","CGC/CPF","CGC/CPF","A2_CGC"})
Aadd(aSXB,{"SA2XCG","4","03","01","Filial","Filial","Filial","A2_FILIAL"})
Aadd(aSXB,{"SA2XCG","4","03","02","Razao Social","Razao Social","Razao Social","A2_NOME"})
Aadd(aSXB,{"SA2XCG","4","03","03","CGC/CPF","CGC/CPF","CGC/CPF","A2_CGC"})
Aadd(aSXB,{"SA2XCG","4","03","04","Codigo","Codigo","Codigo","A2_COD"})
Aadd(aSXB,{"SA2XCG","4","03","05","Loja","Loja","Loja","A2_LOJA"})
Aadd(aSXB,{"SA2XCG","5","01",""  ,""       ,""       ,""       ,"SA2->A2_CGC"})

Aadd(aSXB,{"SA1PRN","1","01","DB","Clientes","Clientes","Clientes","SA1"})
Aadd(aSXB,{"SA1PRN","2","01","01","Codigo + Loja","Codigo + Loja","Codigo + Loja",""})
Aadd(aSXB,{"SA1PRN","2","02","02","Razao Social + Loja","Razao Social + Loja","Razao Social + Loja",""})
Aadd(aSXB,{"SA1PRN","4","01","01","Filial","Filial","Filial","A1_FILIAL"})
Aadd(aSXB,{"SA1PRN","4","01","02","Codigo","Codigo","Codigo","A1_COD"})
Aadd(aSXB,{"SA1PRN","4","01","03","Loja","Loja","Loja","A1_LOJA"})
Aadd(aSXB,{"SA1PRN","4","01","04","Razao Social","Razao Social","Razao Social","A1_NOME"})
Aadd(aSXB,{"SA1PRN","4","01","05","CGC/CPF","CGC/CPF","CGC/CPF","A1_CGC"})
Aadd(aSXB,{"SA1PRN","4","02","01","Filial","Filial","Filial","A1_FILIAL"})
Aadd(aSXB,{"SA1PRN","4","02","02","Razao Social","Razao Social","Razao Social","A1_NOME"})
Aadd(aSXB,{"SA1PRN","4","02","03","Codigo","Codigo","Codigo","A1_COD"})
Aadd(aSXB,{"SA1PRN","4","02","04","Loja","Loja","Loja","A1_LOJA"})
Aadd(aSXB,{"SA1PRN","4","02","05","CGC/CPF","CGC/CPF","CGC/CPF","A1_CGC"})
Aadd(aSXB,{"SA1PRN","5","01",""  ,""       ,""       ,""       ,"SA1->A1_COD"})
Aadd(aSXB,{"SA1PRN","6","01",""  ,""       ,""       ,""       ,"SA1->A1_MSBLQL <> '1' .AND.  SA1->A1_CGC == cCnpj "})
Aadd(aSXB,{"SA1PRN","5","02",""  ,""       ,""       ,""       ,"SA1->A1_LOJA"})

//Aadd(aSXB,{"SB1NCM","1","01","DB","Produto com NCM","Produto com NCM","Produto com NCM","SB1"})
//Aadd(aSXB,{"SB1NCM","2","01","01","Codigo","Codigo","Codigo",""})
//Aadd(aSXB,{"SB1NCM","2","02","03","Descricao + Codigo","Descricao + Codigo","Descricao + Codigo",""})
//Aadd(aSXB,{"SB1NCM","4","01","01","Filial","Filial","Filial","B1_FILIAL"})
//Aadd(aSXB,{"SB1NCM","4","01","02","Codigo","Codigo","Codigo","B1_COD"})
//Aadd(aSXB,{"SB1NCM","4","01","03","Descricao","Descricao","Descricao","B1_DESC"})
//Aadd(aSXB,{"SB1NCM","4","01","04","Pos.IPI/NCM","Pos.IPI/NCM","Pos.IPI/NCM","B1_POSIPI"})
//Aadd(aSXB,{"SB1NCM","5","01",""  ,"","","","SB1->B1_COD"})
//Aadd(aSXB,{"SB1NCM","6","01",""  ,"","","","(SB1->B1_POSIPI = cNcm .or. Empty(cNcm))"})

Aadd(aSXB,{"HFNCM","1","01","RE","Produto por NCM","Produto por NCM","Produto por NCM","SB1"})
Aadd(aSXB,{"HFNCM","2","01","01","","","","U_HFPRONCM()"})
Aadd(aSXB,{"HFNCM","5","01",""  ,"","","","U_HFRETPNC()"})

//FR - 12/07/2022 - KITCHENS condições de pagamento da tela "Gera pedido Compra"
Aadd(aSXB,{"HFSE4","1","01","DB","Cond. Pagtos. ","Cond. Pagtos.","Cond. Pagtos.","SE4"})
Aadd(aSXB,{"HFSE4","2","01","01","Codigo"				,"Codigo"				,"Codigo"				,""})
Aadd(aSXB,{"HFSE4","2","02","02","Descrição + Código"	,"Descrição + Código"	,"Descrição + Código"	,""})
Aadd(aSXB,{"HFSE4","3","01","01","Cadastra Novo"		,"Cadastra Novo"		,"Cadastra Novo"		,"01"})
Aadd(aSXB,{"HFSE4","4","01","01","Tipo"					,"Tipo"					,"Tipo"					,"E4_TIPO"})
Aadd(aSXB,{"HFSE4","4","01","02","Condição"				,"Condição"				,"Condição"				,"E4_DESCRI"})
Aadd(aSXB,{"HFSE4","4","01","03","Codigo"				,"Codigo"				,"Codigo"				,"E4_CODIGO"})
Aadd(aSXB,{"HFSE4","4","02","01","Tipo"					,"Tipo"					,"Tipo"					,"E4_TIPO"})
Aadd(aSXB,{"HFSE4","4","02","02","Condição"				,"Condição"				,"Condição"				,"E4_DESCRI"})
Aadd(aSXB,{"HFSE4","4","02","03","Codigo"				,"Codigo"				,"Codigo"				,"E4_CODIGO"})
Aadd(aSXB,{"HFSE4","5","01",""  ,""       				,""       				,""       				,"SE4->E4_CODIGO"})

//FR - 12/07/2022 - KITCHENS - Cadastro de solicitantes
Aadd(aSXB,{"HFSAI","1","01","DB","Solicitantes"			,"Solicitantes"			,"Solicitantes"			,"SAI"})
Aadd(aSXB,{"HFSAI","2","01","02","Cod.Usuario"			,"Cod.Usuario"			,"Cod.Usuario"			,""})
Aadd(aSXB,{"HFSAI","3","01","01","Cadastra Novo"		,"Cadastra Novo"		,"Cadastra Novo"		,"01"})
Aadd(aSXB,{"HFSAI","4","01","01","Cod.Usuario"			,"Usuario"				,"User's Code"			,"AI_USER"})
Aadd(aSXB,{"HFSAI","4","01","02","Cod.Usuario"			,"Usuario"				,"User's Code"			,"UsrRetName(AI_USER)"})
Aadd(aSXB,{"HFSAI","5","01",""  ,""       				,""       				,""       				,"SAI->AI_USER"})
ProcRegua(Len(aSXB))

dbSelectArea("SXB")
dbSetOrder(1)
For i:= 1 To Len(aSXB)
	If !Empty(aSXB[i][1])
		If !dbSeek(PADR(aSXB[i,1],Len(SXB->XB_ALIAS))+aSXB[i,2]+aSXB[i,3]+aSXB[i,4])
			lSXB := .T.
			RecLock("SXB",.T.)
			
			If !(aSXB[i,1]$cAlias)
				cAlias += aSXB[i,1]+"/"
			Endif
			
			For j:=1 To Len(aSXB[i])
				If !Empty(FieldName(FieldPos(aEstrut[j])))
					FieldPut(FieldPos(aEstrut[j]),aSXB[i,j])
				EndIf
			Next j
			
			dbCommit()
			MsUnLock()
			IncProc("Atualizando Consultas Padroes...")
		EndIf
	EndIf
Next i

If lSXB
	lAltera := .T.
	AutoGrLog( 'Foram incluídas as seguintes consultas padrão : '+cAlias+CHR(13)+CHR(10) )
EndIf
Return(cTexto)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ProxOrdem ºAutor  ³Marcos Favaro       º Data ³  04/05/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica a proxima ordem no SX3 para criacao de novos camposº±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Sigafis                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ProxOrdem(cTabela,cOrdem)
Local aOrdem	:= {"0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","X","W","Y","Z"}
Local cProxOrdem:= ""
Local nX		:= 0
Local aAreaSX3 := SX3->(GetArea())

Default cOrdem	:= ""

// Verificando a ultima ordem utilizada
If Empty(cOrdem)
	dbSelectArea("SX3")
	dbSetOrder(1)
	If MsSeek(cTabela)
		Do While SX3->X3_ARQUIVO == cTabela .And. !SX3->(Eof())
			cOrdem := SX3->X3_ORDEM
			SX3->(dbSkip())
		Enddo
	Else
		cOrdem := "00"
	EndIf
Endif

// Criando a nova ordem para o cadastro do novo campo
If Val(SubStr(cOrdem,2,1)) < 9
	cProxOrdem 	:= SubStr(cOrdem,1,1) + Str((Val(SubStr(cOrdem,2,1))+1),1)
Else
	For nX := 1 To Len(aOrdem)
		If aOrdem[nX] == SubStr(cOrdem,1,1)
			Exit
		Endif
	Next
	cProxOrdem 	:= aOrdem[nX+1] + "0"
Endif

SX3->(RestArea(aAreaSX3))
Return cProxOrdem

//AQUIIII
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³hfPESQPICT³ Autor ³ Eneo                  ³ Data ³11/02/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Pesqisar Picture.                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Atualizacao COM                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function hfPESQPICT(cArq,cCampo)
Local cRet := ""
Local aArea := GetArea()

DbSelectArea( "SX3" )
DbSetOrder( 2 )
DbSeek( cCampo )
Do While .NOT. SX3->( Eof() ) .And. AllTrim(SX3->X3_CAMPO) == cCampo
	if SX3->X3_ARQUIVO == cArq
		cRet := SX3->X3_PICTURE
		Exit
	EndIf
	SX3->( dbSkip() )
EndDo

DbSetOrder( 1 )
RestArea( aArea )
Return cRet


//--------------------------------------------------------------------
/*{Protheus.doc} EscEmpresa
Função genérica para escolha de Empresa, montada pelo SM0

@return aRet Vetor contendo as seleções feitas.
             Se não for marcada nenhuma o vetor volta vazio
*/
//--------------------------------------------------------------------
Static Function EscEmpresa()
	
	//---------------------------------------------
	// Parâmetro  nTipo
	// 1 - Monta com Todas Empresas/Filiais
	// 2 - Monta só com Empresas
	// 3 - Monta só com Filiais de uma Empresa
	//
	// Parâmetro  aMarcadas
	// Vetor com Empresas/Filiais pré marcadas
	//
	// Parâmetro  cEmpSel
	// Empresa que será usada para montar seleção
	//---------------------------------------------
	Local   aRet      := {}
	Local   nPos      := 0
	//Local   aSalvAmb  := GetArea()
	Local   aSalvSM0  := {}
	Local   aVetor    := {}
	Local   cMascEmp  := "??"
	Local   cVar      := ""
	Local   lChk      := .F.
	//Local   lOk       := .F.
	Local   lTeveMarc := .F.
	Local   oNo       := LoadBitmap( GetResources(), "LBNO" )
	Local   oOk       := LoadBitmap( GetResources(), "LBOK" )
	Local   oDlg, oChkMar, oLbx, oMascEmp, oSay
	Local   oButDMar 
	//Local   oButInv
	Local oButMarc, oButOk, oButCanc, oButTab
	Local   aMarcadas := {}
	Local   nGestao   := 0
	Local   aDefs := {}
	Local   ni    := 0

	If !MyOpenSm0(.F.)
		Return aRet
	EndIf
	//If !OpenSm0()
	//	Return aRet
	//EndIf

	dbSelectArea( "SM0" )
	aSalvSM0 := SM0->( GetArea() )
	dbSetOrder( 1 )
	dbGoTop()

	While !SM0->( EOF() )
		if "E" $ SM0->M0_LEIAUTE .And. nFilSm == 2		// = "EEUUFF      "
			nFilLay := AT( "F", SM0->M0_LEIAUTE )-1
 			cFilSm := Substr(SM0->M0_CODFIL,1,nFilLay)
			If aScan( aVetor, {|x| x[2] == SM0->M0_CODIGO .and. Substr(x[3],1,nFilLay) == cFilSm } ) == 0

				//aAdd(  aVetor, { aScan( aMarcadas, {|x| x[1] == SM0->M0_CODIGO .and. x[2] == SM0->M0_CODFIL} ) > 0, SM0->M0_CODIGO, SM0->M0_CODFIL, SM0->M0_NOME, SM0->M0_FILIAL, "   ", "   ", "   ", iif(lBOSSKEY, "   ", "   "), "   ", "   ", "   ", "   ", "   ", "   ", "   ", "  " , " ", " ", " "," " } )
				aAdd(  aVetor, { aScan( aMarcadas, {|x| x[1] == SM0->M0_CODIGO .and. x[2] == SM0->M0_CODFIL} ) > 0, SM0->M0_CODIGO, SM0->M0_CODFIL, SM0->M0_NOME, SM0->M0_FILIAL, "   ", "   ", "   ", iif(lBOSSKEY, "   ", "   "), "   ", "   ", "   ", "   ", "   ", "   ", "   ", "  " , " ", " ", " "," ", " " , " " } ) //FR - 17/02/2022 - Log Consulta Fornecedor
				                 //1                                                                                  2              3                     4          5              6     7      8         9                         10    11     12     13     14     15     16     17    18   19   20 , 21, 22, 23
			EndIf
 		Else
			If aScan( aVetor, {|x| x[2] == SM0->M0_CODIGO} ) == 0

				//aAdd(  aVetor, { aScan( aMarcadas, {|x| x[1] == SM0->M0_CODIGO .and. x[2] == SM0->M0_CODFIL} ) > 0, SM0->M0_CODIGO, SM0->M0_CODFIL, SM0->M0_NOME, SM0->M0_FILIAL, "   ", "   ", "   ", iif(lBOSSKEY, "   ", "   "), "   ", "   ", "   ", "   ", "   ", "   ", "   ", "  " , " ", " ", " "," " } )
				aAdd(  aVetor, { aScan( aMarcadas, {|x| x[1] == SM0->M0_CODIGO .and. x[2] == SM0->M0_CODFIL} ) > 0, SM0->M0_CODIGO, SM0->M0_CODFIL, SM0->M0_NOME, SM0->M0_FILIAL, "   ", "   ", "   ", iif(lBOSSKEY, "   ", "   "), "   ", "   ", "   ", "   ", "   ", "   ", "   ", "  " , " ", " ", " "," ", " ", " " } )  //FR - 17/02/2022 - Log Consulta Fornecedores
				                 //1                                                                                  2              3                     4          5              6     7      8         9                         10    11     12     13      14    15     16     17    18   19   20 ,21 , 22, 23
			EndIf
		EndIf

		dbSkip()
	End

	RestArea( aSalvSM0 )
	dbSelectArea( "SM0" )
	dbCloseArea()

	cFileX := "hfcfgxml002a.xml"

	aDefs := {}
	If File(cFileX)
		lNoyStw := .T.
		oXml := U_HFUPDXML(1,cFileX,@aDefs)  //tipo 1 carrega o arquivo (caso exista na pasta system)
		if oXml == NIL
			lNoyStw := .F.
		Else
			if Type( "oXml:_MAIN:_WFXML02:_SHARED:_XTEXT:TEXT" ) <> "U"
				cAux  := AllTrim(oXml:_MAIN:_WFXML02:_SHARED:_XTEXT:TEXT)
				if cAux == "C"
					nGestao := 1
				Else
					nGestao := 2
				EndIf
			endif
			if Type( "oXml:_MAIN:_WFXML02:_SIGAMAT:_GRP" ) <> "U"
				oDet  := oXml:_MAIN:_WFXML02:_SIGAMAT:_GRP
				oDet  := iif( valtype(oDet)=="O", {oDet}, oDet )
				For nI := 1 To Len( oDet )
					if Type( "oDet["+AllTrim(str(nI))+"]:_EMP:TEXT" ) <> "U"
						cEmpF := oDet[nI]:_EMP:TEXT
					Else
						cEmpF := "99"
					Endif
					nPos := aScan( aVetor, {|x| x[2] == cEmpF } )
					if nPos > 0
						if Type( "oDet["+AllTrim(str(nI))+"]:_XM_TABXML:_XTEXT:TEXT" ) <> "U"
							aVetor[nPos][06] := oDet[nI]:_XM_TABXML:_XTEXT:TEXT
						endif
						if Type( "oDet["+AllTrim(str(nI))+"]:_XM_TABAMAR:_XTEXT:TEXT" ) <> "U"
							aVetor[nPos][07] := oDet[nI]:_XM_TABAMAR:_XTEXT:TEXT
						endif
						if Type( "oDet["+AllTrim(str(nI))+"]:_XM_TABREC:_XTEXT:TEXT" ) <> "U"
			   				aVetor[nPos][08] := oDet[nI]:_XM_TABREC:_XTEXT:TEXT
			   			endif
						If lBossKey
							if Type( "oDet["+AllTrim(str(nI))+"]:_XM_TABZBX:_XTEXT:TEXT" ) <> "U"
								aVetor[nPos][09] := oDet[nI]:_XM_TABZBX:_XTEXT:TEXT
							endif
						EndIf
						if Type( "oDet["+AllTrim(str(nI))+"]:_XM_TABSINC:_XTEXT:TEXT" ) <> "U"
							aVetor[nPos][10] := oDet[nI]:_XM_TABSINC:_XTEXT:TEXT
						endif
						if Type( "oDet["+AllTrim(str(nI))+"]:_XM_TABAMA2:_XTEXT:TEXT" ) <> "U"
							aVetor[nPos][11] := oDet[nI]:_XM_TABAMA2:_XTEXT:TEXT
						endif
						if Type( "oDet["+AllTrim(str(nI))+"]:_XM_TABEVEN:_XTEXT:TEXT" ) <> "U"
							aVetor[nPos][12] := oDet[nI]:_XM_TABEVEN:_XTEXT:TEXT
						endif
						if Type( "oDet["+AllTrim(str(nI))+"]:_XM_TABSYX:_XTEXT:TEXT" ) <> "U"
							aVetor[nPos][13] := oDet[nI]:_XM_TABSYX:_XTEXT:TEXT
						endif
						if Type( "oDet["+AllTrim(str(nI))+"]:_XM_TABCAC:_XTEXT:TEXT" ) <> "U"
							aVetor[nPos][14] := oDet[nI]:_XM_TABCAC:_XTEXT:TEXT
						endif
						if Type( "oDet["+AllTrim(str(nI))+"]:_XM_TABOCOR:_XTEXT:TEXT" ) <> "U"
							aVetor[nPos][15] := oDet[nI]:_XM_TABOCOR:_XTEXT:TEXT
						endif
						if Type( "oDet["+AllTrim(str(nI))+"]:_XM_TABIEXT:_XTEXT:TEXT" ) <> "U"
							aVetor[nPos][16] := oDet[nI]:_XM_TABIEXT:_XTEXT:TEXT
						endif
						if Type( "oDet["+AllTrim(str(nI))+"]:_XM_TABITEM:_XTEXT:TEXT" ) <> "U"    //FR - 19/11/19
							aVetor[nPos][17] := oDet[nI]:_XM_TABITEM:_XTEXT:TEXT
						endif
						if Type( "oDet["+AllTrim(str(nI))+"]:_XM_TABMUN:_XTEXT:TEXT" ) <> "U"    //HMS - 31/08/20
							aVetor[nPos][18] := oDet[nI]:_XM_TABMUN:_XTEXT:TEXT
						endif
						if Type( "oDet["+AllTrim(str(nI))+"]:_XM_TABMUN2:_XTEXT:TEXT" ) <> "U"    //HMS - 03/09/20
							aVetor[nPos][19] := oDet[nI]:_XM_TABMUN2:_XTEXT:TEXT
						endif
						if Type( "oDet["+AllTrim(str(nI))+"]:_XM_TABIMC:_XTEXT:TEXT" ) <> "U"    //HMS - 06/01/21
							aVetor[nPos][20] := oDet[nI]:_XM_TABIMC:_XTEXT:TEXT
						endif						
  						if Type( "oDet["+AllTrim(str(nI))+"]:_XM_TABCON:_XTEXT:TEXT" ) <> "U"    //HMS - 06/01/21
							aVetor[nPos][21] := oDet[nI]:_XM_TABCON:_XTEXT:TEXT				
						endif 
						If Type( "oDet["+AllTrim(str(nI))+"]:_XM_TABLOG:_XTEXT:TEXT" ) <> "U"    //FR - 17/02/2022- Log Consulta Fornecedores
							aVetor[nPos][22] := oDet[nI]:_XM_TABLOG:_XTEXT:TEXT				
						Endif
						If Type( "oDet["+AllTrim(str(nI))+"]:_XM_TABTPO:_XTEXT:TEXT" ) <> "U"    
							aVetor[nPos][23] := oDet[nI]:_XM_TABTPO:_XTEXT:TEXT				
						Endif						
					endif
				Next nPos
			endif
		EndIf

	Else
		lNoyStw := .F.
	Endif

	if nGestao == 0
		nGestao := U_MyAviso("Gestão de Empresas","Compartilhar os parâmetros (SX6) para as Empresas (EE) (Gestão de Empresas)?",{"SIM","NAO"},1)

		if nGestao == 0
			Return aRet
		EndIf
	Endif
	nFilSm := nGestao

	If lNoyStw
	Else

		For nPos := 1 To Len( aVetor )
				RpcSetType(3)
				RpcSetEnv(aVetor[nPos][2], aVetor[nPos][3])   //SM0->M0_CODIGO, SM0->M0_CODFIL

				aVetor[nPos][06] := GetNewPar("XM_TABXML","   ")
				aVetor[nPos][07] := GetNewPar("XM_TABAMAR","   ")
				aVetor[nPos][08] := GetNewPar("XM_TABREC","   ")
				If lBossKey
					aVetor[nPos][09] := GetNewPar("XM_TABZBX","   ")
				EndIf
				aVetor[nPos][10] := GetNewPar("XM_TABSINC","   ")
				aVetor[nPos][11] := GetNewPar("XM_TABAMA2","   ")
				aVetor[nPos][12] := GetNewPar("XM_TABEVEN","   ")
				aVetor[nPos][13] := GetNewPar("XM_TABSYX" ,"   ")
				aVetor[nPos][14] := GetNewPar("XM_TABCAC" ,"   ")
				aVetor[nPos][15] := GetNewPar("XM_TABOCOR","   ")
				aVetor[nPos][16] := GetNewPar("XM_TABIEXT","   ")
                aVetor[nPos][17] := GetNewPar("XM_TABITEM","   ")  //FR - 11/11/2019 
                aVetor[nPos][18] := GetNewPar("XM_TABMUN" ,"   ")  //HMS - 31/08/2020 
                aVetor[nPos][19] := GetNewPar("XM_TABMUN2","   ")  //HMS - 31/08/2020 
                aVetor[nPos][20] := GetNewPar("XM_TABIMC" ,"   ")  //HMS - 06/01/2021 
				aVetor[nPos][21] := GetNewPar("XM_TABCON" ,"   ")  //HMS - 06/01/2021  
				aVetor[nPos][22] := GetNewPar("XM_TABLOG" ,"   ")  //FR - 17/02/2022 - Log Consulta fornecedores
				aVetor[nPos][23] := GetNewPar("XM_TABTPO" ,"   ")
				RstMvBuff()
				DelClassIntf()
				RpcClearEnv()
		Next nPos
	EndIf

	//Define MSDialog  oDlg Title "" From 0, 0 To 280, 995 Pixel
	Define MSDialog  oDlg Title "" From 0, 0 To 330, 850 Pixel

	oDlg:cToolTip := "Tela para Múltiplas Seleções de Empresas/Filiais"

	oDlg:cTitle   := "Selecione a(s) Empresa(s) para Atualização"

	@ 10, 10 Listbox  oLbx Var  cVar Fields Header;
	 " "		   					,;
	 " "		   					,;
	 "Empresa"						,;
	 "XML"							,;
	 "Amar"		   					,;
	 "P.Rec"						,;
	 iif(lBOSSKEY, "Boss", "Resev."),;
	 "Sincr"						,;
	 "Am.Sec"						,;
	 "CCe"							,;
	 "Systax"						,;
	 "Classif"						,;
	 "Ocor."						,;
	 "I.Ext."						,;
	 "Itens NF" 					,;  		//FR - 15/11/19 - nova tabela itens da nf
	 "Municipios" 					,;  		//HMS - 31/08/20 - nova tabela municipios
	 "Leituras" 					,;  		//HMS - 03/09/20 - nova tabela leituras
	 "Image Conv" 					,;  		//HMS - 06/01/21 - nova tabela image converter
	 "Consultas de Chaves"			,;
	 "Log de Consulta Fornecedores" ;			//FR - 17/02/2022 - Log Consulta Fornecedores
	 Size 410, 115 Of oDlg Pixel //"Empresa"
	 //Size 478, 095 Of oDlg Pixel //"Empresa"
	oLbx:SetArray(  aVetor )
	oLbx:bLine := {|| {IIf( aVetor[oLbx:nAt, 1], oOk, oNo ), ;
	aVetor[oLbx:nAt, 2], ;
	aVetor[oLbx:nAt, 4], ;
	aVetor[oLbx:nAt, 6], ;
	aVetor[oLbx:nAt, 7], ;
	aVetor[oLbx:nAt, 8], ;
	aVetor[oLbx:nAt, 9], ;
	aVetor[oLbx:nAt,10], ;
	aVetor[oLbx:nAt,11], ;
	aVetor[oLbx:nAt,12], ;
	aVetor[oLbx:nAt,13], ;
	aVetor[oLbx:nAt,14], ;
	aVetor[oLbx:nAt,15], ;
	aVetor[oLbx:nAt,16], ;
	aVetor[oLbx:nAt,17], ;
	aVetor[oLbx:nAt,18], ;
	aVetor[oLbx:nAt,19], ;
	aVetor[oLbx:nAt,20], ;
	aVetor[oLbx:nAt,21], ; //aVetor[oLbx:nAt,21] }}
	aVetor[oLbx:nAt,22], ;
	aVetor[oLbx:nAt,23] }}	//FR - 17/02/2022 - Log Consulta fornecedores
	oLbx:BlDblClick := { || aVetor[oLbx:nAt, 1] := !aVetor[oLbx:nAt, 1], VerTodos( aVetor, @lChk, oChkMar ), oChkMar:Refresh(), oLbx:Refresh()}
	oLbx:cToolTip   :=  oDlg:cTitle
	oLbx:lHScroll   := .T. // NoScroll

	@ 132, 10 CheckBox oChkMar Var  lChk Prompt STR0120 Message STR0121 Size 40, 007 Pixel Of oDlg; //"Todos"###"Marca / Desmarca"+ CRLF + "Todos"
	on Click MarcaTodos( lChk, @aVetor, oLbx )

	// Marca/Desmarca por mascara
	@ 133, 51 Say   oSay Prompt STR0119 Size  40, 08 Of oDlg Pixel //"Empresa"
	@ 132, 80 MSGet oMascEmp Var  cMascEmp Size  05, 05 Pixel Picture "@!"  Valid (  cMascEmp := StrTran( cMascEmp, " ", "?" ), oMascEmp:Refresh(), .T. ) ;
	Message STR0124  Of oDlg //"Máscara Empresa ( ?? )"
	oSay:cToolTip := oMascEmp:cToolTip

	/*@ 128, 10 Button oButInv    Prompt STR0122  Size 32, 12 Pixel Action ( InvSelecao( @aVetor, oLbx, @lChk, oChkMar ), VerTodos( aVetor, @lChk, oChkMar ) ) ; //"&Inverter"
	Message STR0123 Of oDlg //"Inverter Seleção"
	oButInv:SetCss( CSSBOTAO )*/
	@ 148, 50 Button oButMarc   Prompt STR0125    Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .T. ), VerTodos( aVetor, @lChk, oChkMar ) ) ; //"&Marcar"
	Message STR0126    Of oDlg //"Marcar usando" + CRLF + "máscara ( ?? )"
	oButMarc:SetCss( CSSBOTAO )
	@ 148, 80 Button oButDMar   Prompt STR0127 Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .F. ), VerTodos( aVetor, @lChk, oChkMar ) ) ; //"&Desmarcar"
	Message STR0128 Of oDlg //"Desmarcar usando" + CRLF + "máscara ( ?? )"
	oButDMar:SetCss( CSSBOTAO )
	@ 132, 157  Button oButOk   Prompt STR0147  Size 32, 12 Pixel Action (  iif(RetSelecao( @aRet, aVetor ), oDlg:End(), .T. )  ) ; //"Processar"
	Message STR0145 Of oDlg //"Confirma a seleção e efetua" + CRLF + "o processamento"
	oButOk:SetCss( CSSBOTAO )
	@ 148, 157  Button oButCanc Prompt STR0148   Size 32, 12 Pixel Action ( IIf( lTeveMarc, aRet :=  aMarcadas, .T. ), oDlg:End() ) ; //"Cancelar"
	Message STR0146 Of oDlg //"Cancela o processamento" + CRLF + "e abandona a aplicação"
	oButCanc:SetCss( CSSBOTAO )
	@ 148, 234  Button oButTab Prompt "Tabelas"   Size 32, 12 Pixel Action ( EdtTabelas( @aVetor, oLbx, oLbx:nAT )  ) ;
	Message "Escolher Tabelas do sistema" + CRLF + "da empresa selecionada" Of oDlg //
	oButCanc:SetCss( CSSBOTAO )

	Activate MSDialog  oDlg Center
		
	//RestArea( aSalvAmb )
	if !Empty( aRet )
		aDefs  := {}  //{{"SHARED"," ","Compartilhado/Exclusivo"},{"SIGAMAT",{},"Empresas Siga Mat"}}
		Aadd(aDefs,{"SHARED"  ,iif(nGestao==1,"C","E"),"Compartilhado/Exclusivo"  })
		Aadd(aDefs,{"SIGAMAT" ,{}                     ,"Empresas Siga Mat"        })
		For nI :=  1 To Len( aVetor )
			aadd(aDefs[2][2],{"Grp",{},aVetor[nI][02] } )
			aadd(aDefs[2][2][nI][2],{"XM_TABXML" , aVetor[nI][06], "Xml Importados"  } )
			aadd(aDefs[2][2][nI][2],{"XM_TABAMAR", aVetor[nI][07], "Amarracao" } )
			aadd(aDefs[2][2][nI][2],{"XM_TABREC" , aVetor[nI][08], "Pedido Recorrente"  } )
			aadd(aDefs[2][2][nI][2],{"XM_TABZBX" , aVetor[nI][09], "XM_TABZBX"  } )
			aadd(aDefs[2][2][nI][2],{"XM_TABSINC", aVetor[nI][10], "Sincronismo Sefaz" } )
			aadd(aDefs[2][2][nI][2],{"XM_TABAMA2", aVetor[nI][11], "Amarracao Secundaria" } )
			aadd(aDefs[2][2][nI][2],{"XM_TABEVEN", aVetor[nI][12], "Enventos e Carta de Correcao" } )
			aadd(aDefs[2][2][nI][2],{"XM_TABSYX" , aVetor[nI][13], "Consultas Systax" } )
			aadd(aDefs[2][2][nI][2],{"XM_TABCAC" , aVetor[nI][14], "Classificação Automática" } )
			aadd(aDefs[2][2][nI][2],{"XM_TABOCOR", aVetor[nI][15], "Ocorrência de Integrações" } )
			aadd(aDefs[2][2][nI][2],{"XM_TABIEXT", aVetor[nI][16], "Integrações Externa" } )
			aadd(aDefs[2][2][nI][2],{"XM_TABITEM", aVetor[nI][17], "Itens da NF" } ) 				//FR - 15/11/19
			aadd(aDefs[2][2][nI][2],{"XM_TABMUN" , aVetor[nI][18], "Municipios API" } ) 				//HMS - 31/08/20
			aadd(aDefs[2][2][nI][2],{"XM_TABMUN2", aVetor[nI][19], "Leituras API" } ) 				//HMS - 03/09/20
			aadd(aDefs[2][2][nI][2],{"XM_TABIMC", aVetor[nI][20], "Image Converter" } )
			aadd(aDefs[2][2][nI][2],{"XM_TABCON", aVetor[nI][21], "Controla Requisição" } ) 
			aadd(aDefs[2][2][nI][2],{"XM_TABLOG", aVetor[nI][22], "Log Consulta Fornecedores" } )  	//FR - 17/02/2022 - Log Consulta Fornecedores
			//aadd(aDefs[2][2][nI][2],{aRet[nI][02],aRet[nI][06],aRet[nI][07],aRet[nI][08],aRet[nI][09],aRet[nI][10],aRet[nI][11],aRet[nI][12]})
		Next
		cXmlCfg := U_HFUPDXML(2,cFileX,aDefs)   //tipo 2, salva o arquivo na pasta system, caso não exista
		If !Empty(cXmlCfg)
    		MemoWrite(cFileX,cXmlCfg)
		EndIf
	EndIF

Return  aRet

//--------------------------------------------------------------------
/*/{Protheus.doc} MarcaTodos
Função auxiliar para marcar/desmarcar todos os ítens do ListBox ativo
@param lMarca  Contéudo para marca .T./.F.
@param aVetor  Vetor do ListBox
@param oLbx    Objeto do ListBox
/*/
//--------------------------------------------------------------------
Static Function MarcaTodos( lMarca, aVetor, oLbx )
	Local  nI := 0
	
	For nI := 1 To Len( aVetor )
		aVetor[nI][1] := lMarca
	Next nI
	
	oLbx:Refresh()

Return NIL

//--------------------------------------------------------------------
/*/{Protheus.doc} InvSelecao
Função auxiliar para inverter a seleção do ListBox ativo
@param aVetor  Vetor do ListBox
@param oLbx    Objeto do ListBox
/*/
//--------------------------------------------------------------------
Static Function InvSelecao( aVetor, oLbx )
	Local  nI := 0
	
	For nI := 1 To Len( aVetor )
		aVetor[nI][1] := !aVetor[nI][1]
	Next nI
	
	oLbx:Refresh()

Return NIL

//--------------------------------------------------------------------
/*{Protheus.doc} RetSelecao
Função auxiliar que monta o retorno com as seleções
@param aRet    Array que terá o retorno das seleções (é alterado internamente)
@param aVetor  Vetor do ListBox
*/
//--------------------------------------------------------------------
Static Function RetSelecao( aRet, aVetor )
	Local  nI    := 0
	LOcal lRet   := .T.

	aRet := {}
	For nI := 1 To Len( aVetor )
		If aVetor[nI][1]
			if Empty(aVetor[nI][6])  .Or. Empty(aVetor[nI][7])  .Or. Empty(aVetor[nI][8])  .or. Iif(lBossKey,Empty(aVetor[nI][9]),.F.) .or. Empty(aVetor[nI][10]);
		  .or. Empty(aVetor[nI][11]) .or. Empty(aVetor[nI][12]) .or. Empty(aVetor[nI][13]) .or. Empty(aVetor[nI][14]) .or. Empty(aVetor[nI][15]);
		  .or. Empty(aVetor[nI][16]) .or. Empty(aVetor[nI][17]) .Or. Empty(aVetor[nI][18]) .Or. Empty(aVetor[nI][19]) .or. Empty(aVetor[nI][20]) .or. Empty(aVetor[nI][21]);  //FR - 29/11/19 - valida se alguma tabela está vazia
		  .or. Empty(aVetor[nI][22]) .or. Empty(aVetor[nI][23])
				lRet := .F.
				cAvi := "Empressa "+ Alltrim(aVetor[nI][4])+" sem Tabelas Definidas:"+CRLF
				If Empty(aVetor[nI][06])
					cAvi += "XML importados.: "+aVetor[nI][06]+" -> Vazia"+CRLF
				Endif
				
				If Empty(aVetor[nI][07])
					cAvi += "Amarração......: "+aVetor[nI][07]+" -> Vazia"+CRLF
				Endif
				
				If Empty(aVetor[nI][08])
					cAvi += "Ped.Recorrente.: "+aVetor[nI][08]+" -> Vazia"+CRLF
				Endif
				If lBossKey
					If Empty(aVetor[nI][09])
						cAvi += "Boss Key......: "+aVetor[nI][09]+" -> Vazia"+CRLF
					Endif
				EndIf
				
				If Empty(aVetor[nI][10])
					cAvi += "Sincronismo...: "+aVetor[nI][10]+" -> Vazia"+CRLF
				Endif
				
				If Empty(aVetor[nI][11])
					cAvi += "Amarra Secund.: "+aVetor[nI][11]+" -> Vazia"+CRLF
				Endif
				
				If Empty(aVetor[nI][12])
					cAvi += "Eventos C.Cor.: "+aVetor[nI][12]+" -> Vazia"+CRLF
				Endif
				
				If Empty(aVetor[nI][13])
					cAvi += "Integr.Fiscal.: "+aVetor[nI][13]+" -> Vazia"+CRLF
				Endif
				
				If Empty(aVetor[nI][14])
					cAvi += "Class.Automat.: "+aVetor[nI][14]+" -> Vazia"+CRLF
				Endif
				
				If Empty(aVetor[nI][15])
					cAvi += "Ocor.Integraç.: "+aVetor[nI][15]+" -> Vazia"+CRLF
				Endif
				
				If Empty(aVetor[nI][16])
					cAvi += "Integr.Externa: "+aVetor[nI][16]+" -> Vazia"+CRLF
				Endif
				
				If Empty(aVetor[nI][17])
					cAvi += "Itens da NF   : "+aVetor[nI][17]+" -> Vazia"+CRLF
				Endif
				If Empty(aVetor[nI][18])
					cAvi += "Municipios    : "+aVetor[nI][18]+" -> Vazia"+CRLF
				Endif

				If Empty(aVetor[nI][19])
					cAvi += "Leituras      : "+aVetor[nI][19]+" -> Vazia"+CRLF
				Endif
				If Empty(aVetor[nI][20])
					cAvi += "Image Converter: "+aVetor[nI][20]+" -> Vazia"+CRLF
				Endif
				If Empty(aVetor[nI][21])
					cAvi += "Controle Consumo: "+aVetor[nI][21]+" -> Vazia"+CRLF
				Endif
				//FR - 17/02/2022 - Log Consulta Fornecedores
				If Empty(aVetor[nI][22])
					cAvi += "Log Consulta Fornecedores: "+aVetor[nI][22]+" -> Vazia"+CRLF
				Endif
				If Empty(aVetor[nI][23])
					cAvi += "Tipo Ocorrencia XML: "+aVetor[nI][23]+" -> Vazia"+CRLF
				Endif	
				
				cAvi += "Por Favor, Clique no botão 'Tabelas' Para Preenchimento."
				U_MyAviso("Tabelas Empresa",cAvi ,{"Ok"},3)  
				
			Else
				aAdd( aRet, { aVetor[nI][2] , aVetor[nI][3], aVetor[nI][2] +  aVetor[nI][3], "", "", aVetor[nI][6], aVetor[nI][7], aVetor[nI][8], aVetor[nI][9], aVetor[nI][10], aVetor[nI][11], aVetor[nI][12], aVetor[nI][13], aVetor[nI][14], aVetor[nI][15], aVetor[nI][16], aVetor[nI][17],aVetor[nI][18],aVetor[nI][19],aVetor[nI][20],aVetor[nI][21],aVetor[nI][22],aVetor[nI][23]} ) //FR - 17/02/2022 - Log consulta fornecedores
			EndIF
		EndIf
	Next nI
	If lRet .And. Empty( aRet )
		U_MyAviso("Aviso","Nenhuma Empresa Selecionada",{"Ok"},1)
		lRet := .F.
	Endif
	If ! lRet
		aRet := {}
	EndIf

Return( lRet )

//--------------------------------------------------------------------
/*{Protheus.doc} MarcaMas
Função para marcar/desmarcar usando máscaras
@param oLbx     Objeto do ListBox
@param aVetor   Vetor do ListBox
@param cMascEmp Campo com a máscara (???)
@param lMarDes  Marca a ser atribuída .T./.F.
*/
//--------------------------------------------------------------------
Static Function MarcaMas( oLbx, aVetor, cMascEmp, lMarDes )
	Local cPos1 := SubStr( cMascEmp, 1, 1 )
	Local cPos2 := SubStr( cMascEmp, 2, 1 )
	Local nPos  := oLbx:nAt
	Local nZ    := 0
	
	For nZ := 1 To Len( aVetor )
		If cPos1 == "?" .or. SubStr( aVetor[nZ][2], 1, 1 ) == cPos1
			If cPos2 == "?" .or. SubStr( aVetor[nZ][2], 2, 1 ) == cPos2
				aVetor[nZ][1] := lMarDes
			EndIf
		EndIf
	Next
	
	oLbx:nAt := nPos
	oLbx:Refresh()
Return NIL

//--------------------------------------------------------------------
/*/{Protheus.doc} VerTodos
Função auxiliar para verificar se estão todos marcados ou não
@param aVetor   Vetor do ListBox
@param lChk     Marca do CheckBox do marca todos (referncia)
@param oChkMar  Objeto de CheckBox do marca todos
/*/
//--------------------------------------------------------------------
Static Function VerTodos( aVetor, lChk, oChkMar )
	Local lTTrue := .T.
	Local nI     := 0
	
	For nI := 1 To Len( aVetor )
		lTTrue := IIf( !aVetor[nI][1], .F., lTTrue )
	Next nI
	
	lChk := IIf( lTTrue, .T., .F. )
	oChkMar:Refresh()

Return NIL

//--------------------------------------------------------------------
/*/{Protheus.doc} MyOpenSM0
Função de processamento abertura do SM0 modo exclusivo
/*/
//--------------------------------------------------------------------
Static Function MyOpenSM0(lShared)

	Local lOpen := .F.
	Local nLoop := 0
	Local nVersao := Val( GetVersao( .F.) )
	Local cReleas := GetRPORelease()
	
	//Alert( cReleas )

	For nLoop := 1 To 20
		If nVersao >= 12 .And. cReleas >= "12.1.025"
			if lShared
				OpenSm0(,.F.)
			else
				OpenSM0Exc(,.F.)
			endif
			If !Empty( Select( "SM0" ) )
				lOpen := .T.
				//dbSetIndex( "SIGAMAT.IND" )
				Exit
			EndIf
			if nLoop == 5  //Para ir mais rápido
				Exit
			endif
		Else
			dbUseArea( .T., , "SIGAMAT.EMP", "SM0", lShared, .F. )

			If !Empty( Select( "SM0" ) )
				lOpen := .T.
				dbSetIndex( "SIGAMAT.IND" )
				Exit
			EndIf
		endif
	
		Sleep( 500 )
	
	Next nLoop
	
	If !lOpen
		MsgStop( "Não foi possível a abertura da tabela " + ; //
		IIf( lShared, "de empresas (SM0).", "de empresas (SM0) de forma exclusiva." ), "ATENÇÃO" ) 
	EndIf

Return lOpen

//--------------------------------------------------------------------
/*/{Protheus.doc} LeLog
Função de leitura do LOG gerado com limitacao de string
/*/
//--------------------------------------------------------------------
Static Function LeLog()

	Local cRet  := ""
	Local cFile := NomeAutoLog()
	Local cAux  := ""

	if !Empty(cFile)
	
		FT_FUSE( cFile )
		FT_FGOTOP()
		
		While !FT_FEOF()
		
			cAux := FT_FREADLN()
		
			If Len( cRet ) + Len( cAux ) < 1048000
				cRet += cAux + CRLF
			Else
				cRet += CRLF
				cRet += Replicate( "=" , 124 ) + CRLF
				cRet += "Tamanho de exibição maxima do LOG alcançado." + CRLF
				cRet += "LOG Completo no arquivo " + iif(Valtype(cFile) == "C",cFile,cValToChar(cFile)) + CRLF
				cRet += Replicate( "=" , 124 ) + CRLF
				Exit
			EndIf
		
			FT_FSKIP()
		End
		
		FT_FUSE()

	endif

Return cRet






/*======================================================================================================================================
PARTE NOVA
========================================================================================================================================*/
User Function HFUPDXML(nTipo,cFileX,aDefs)  //U_HFUPDXML(nTipo,cFileX,aDefs)
//Local lRet     := .T.
Local uRet     := Nil
Local Nx       := 0
Local NY       := 0
Local nz       := 0
Local cError   := ""
Local cWarning := ""
Local cXml     := ""
//Local cJobs    := ""
//Local nJobs    := 0
//Local nAt1     := nAt2 := nAt3 := nAt4 := 0
Local lLoadDef := .F.
Private oXmlCfg                 
Private aJobs  := ""
Private aDados := {}
Default nTipo  := 1
Default cFileX := "hfcfgxml002a.xml"
Default aDefs  := {{"SHARED"," ","Compartilhado/Exclusivo"},{"SIGAMAT",{},"Empresas Siga Mat"}}

If nTipo == 1 // Carrega
	If File(cFileX)

		cXml := MemoRead(cFileX)
		oXmlCfg := XmlParser( cXml, "_", @cError, @cWarning )

		If Empty(cError) .And. Empty(cWarning)
			uRet:=oXmlCfg
		EndIf
		oXmlCfg:= Nil
	EndIf

ElseIf nTipo == 2  //Salva
	cXml    := MemoRead(cFileX)
	aDados  := aDefs
    cXmlEnd := ""


	cXmlEnd := '<?xml version = "1.0" encoding = "UTF-8"?>'
	cXmlEnd += '<Main>'
	cXmlEnd += '<wfxml02 version="1.00">'

	For Nx := 1 To Len(aDados)
		cTag   := Lower(aDados[Nx][1])
	    cTipo  := ValType(aDados[Nx][2])
		cDesc  := aDados[Nx][3]
		uText  := aDados[Nx][2]
		cSubTag:= Left(cTag,Len(cTag)-0) 
        
		If cTipo <> "A"
			cXmlEnd += '<'+cTag+'>'
			cXmlEnd += xTag("xDesc","C"  ,cDesc, cSubTag)
			cXmlEnd += xTag("xType","C"  ,cTipo, cSubTag)
			cXmlEnd += xTag("xText",cTipo,uText, cSubTag)
			cXmlEnd += '</'+cTag+'>'
		Else
			aProc := uText
			cXmlEnd += '<'+cTag+'>'
            For Ny:=1 to Len(aProc)
				cTag2   := Lower(aProc[Ny][1])
			    cTipo2  := ValType(aProc[Ny][2])
				cDesc2  := aProc[NY][3]
				uText2  := aProc[Ny][2]

				cXmlEnd += '<'+cTag2+' emp="'+cDesc2+'">'
				aProc2 := uText2
				For nZ := 1 To Len( aProc2 )
					cXmlEnd += '<'+aProc2[nZ][1]+'>'
					cXmlEnd += xTag("xDesc","C"  ,aProc2[nZ][3], cSubTag)
					cXmlEnd += xTag("xType","C"  ,ValType(aProc2[nZ][2]), cSubTag)
					cXmlEnd += xTag("xText",ValType(aProc2[nZ][2]),aProc2[nZ][2], cSubTag)
					cXmlEnd += '</'+aProc2[nZ][1]+'>'
				Next nZ
				cXmlEnd += '</'+cTag2+'>'
    		Next
			cXmlEnd += '</'+cTag+'>'
		EndIf
	Next

	cXmlEnd += '</wfxml02>'
	cXmlEnd += '</Main>'
	uRet    := cXmlEnd
EndIf

If lLoadDef .Or. nTipo == 3
	uRet := '<?xml version = "1.0" encoding = "UTF-8"?>'
	uRet += '<Main>'
	uRet += '<wfxml02 version="1.00">'
	uRet += '<SHARED><xDesc>Empresa Compartilhado/Exclusivo</xDesc><xType>C</xType><xText>C</xText></SHARED>'
	uRet += '<SIGAMAT>'
	uRet += '<Grp emp="99">'
	uRet += '<XM_TABXML><xDesc>Xml Importados</xDesc><xType>C</xType><xText>ZBZ</xText></XM_TABXML>'
	uRet += '<XM_TABAMAR><xDesc>Amarracao</xDesc><xType>C</xType><xText>ZB5</xText></XM_TABAMAR>'
	uRet += '<XM_TABREC><xDesc>Pedido Recorrente</xDesc><xType>C</xType><xText>ZBB</xText></XM_TABREC>'
	uRet += '<XM_TABZBX><xDesc>XM_TABZBX</xDesc><xType>C</xType><xText>ZBX</xText></XM_TABZBX>'
	uRet += '<XM_TABSINC><xDesc>Sincronismo Sefaz</xDesc><xType>C</xType><xText>ZBS</xText></XM_TABSINC>'
	uRet += '<XM_TABAMA2><xDesc>Amarracao Secundária</xDesc><xType>C</xType><xText>ZBA</xText></XM_TABAMA2>'
	uRet += '<XM_TABEVEN><xDesc>Enventos e Carta de Correcao</xDesc><xType>C</xType><xText>ZBE</xText></XM_TABEVEN>'
	uRet += '<XM_TABSYX><xDesc>Consultas Systax</xDesc><xType>C</xType><xText>ZYX</xText></XM_TABSYX>'
	uRet += '<XM_TABCAC><xDesc>Classific.Automática</xDesc><xType>C</xType><xText>ZBC</xText></XM_TABCAC>'
	uRet += '<XM_TABOCOR><xDesc>Ocorrencia Integr.</xDesc><xType>C</xType><xText>ZBO</xText></XM_TABOCOR>'
	uRet += '<XM_TABIEXT><xDesc>Integração Externa</xDesc><xType>C</xType><xText>ZBI</xText></XM_TABIEXT>'
	uRet += '</Grp>'
	uRet += '<Grp emp="ZZ">'
	uRet += '<XM_TABXML><xDesc>Xml Importados</xDesc><xType>C</xType><xText>ZBZ</xText></XM_TABXML>'
	uRet += '<XM_TABAMAR><xDesc>Amarracao</xDesc><xType>C</xType><xText>ZB5</xText></XM_TABAMAR>'
	uRet += '<XM_TABREC><xDesc>Pedido Recorrente</xDesc><xType>C</xType><xText>ZBB</xText></XM_TABREC>'
	uRet += '<XM_TABZBX><xDesc>XM_TABZBX</xDesc><xType>C</xType><xText>ZBX</xText></XM_TABZBX>'
	uRet += '<XM_TABSINC><xDesc>Sincronismo Sefaz</xDesc><xType>C</xType><xText>ZBS</xText></XM_TABSINC>'
	uRet += '<XM_TABAMA2><xDesc>Amarracao Secundaria</xDesc><xType>C</xType><xText>ZBA</xText></XM_TABAMA2>'
	uRet += '<XM_TABEVEN><xDesc>Enventos e Carta de Correcao</xDesc><xType>C</xType><xText>ZBE</xText></XM_TABEVEN>'
	uRet += '<XM_TABSYX><xDesc>Consultas Systax</xDesc><xType>C</xType><xText>ZYX</xText></XM_TABSYX>'
	uRet += '<XM_TABCAC><xDesc>Classific.Automática</xDesc><xType>C</xType><xText>ZBC</xText></XM_TABCAC>'
	uRet += '<XM_TABOCOR><xDesc>Ocorrencia Integr.</xDesc><xType>C</xType><xText>ZBO</xText></XM_TABOCOR>'
	uRet += '<XM_TABIEXT><xDesc>Integração Externa</xDesc><xType>C</xType><xText>ZBI</xText></XM_TABIEXT>'
	uRet += '</Grp>'
	uRet += '</SIGAMAT>'
	uRet += '</wfxml02>'
	uRet += '</Main>'
	//uRet := XmlParser( uRet, "_", @cError, @cWarning )
EndIf

Return(uRet)

************************************************
Static Function EdtTabelas( aVetor, oLbx, nPos )
************************************************
	Local cTab1, cTab2, cTab3, cTab4, cTab5, cTab6, cTab7, cTab8, cTab9, cTab10, cTab11, cTab12, cTab13, cTab14, cTab15, cTab16
	Local cTab17		//FR - 17/02/2022 - Log Consulta Fornecedores
	Local cTab18
	//Private aWhen := {.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.} 
	//FR - 17/02/2022 - ALTERAÇÃO: posição 22 tabela log consulta fornecedores
	Private aWhen := { .F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F. , .F. , .F.} 
	
	cTab1 := aVetor[nPos, 06]
	cTab2 := aVetor[nPos, 07]
	cTab3 := aVetor[nPos, 08]
	cTab4 := aVetor[nPos, 09]
	cTab5 := aVetor[nPos, 10]
	cTab6 := aVetor[nPos, 11]
	cTab7 := aVetor[nPos, 12]
	cTab8 := aVetor[nPos, 13]
	cTab9 := aVetor[nPos, 14]
	cTab10:= aVetor[nPos, 15]
	cTab11:= aVetor[nPos, 16]
	cTab12:= aVetor[nPos, 17]
	cTab13:= aVetor[nPos, 18]
	cTab14:= aVetor[nPos, 19]
	cTab15:= aVetor[nPos, 20]
	cTab16:= aVetor[nPos, 21]
	cTab17:= aVetor[nPos, 22]  	//FR - 17/02/2022 - posição 22 tabela log consulta fornecedores
	cTab18:= aVetor[nPos, 23]
	
	if empty( cTab1 )
		aWhen[01] := .T.
	endif
	if empty( cTab2 )
		aWhen[02] := .T.
	endif
	if empty( cTab3 )
		aWhen[03] := .T.
	endif
	if empty( cTab4 )
		aWhen[04] := .T.
	endif
	if empty( cTab5 )
		aWhen[05] := .T.
	endif
	if empty( cTab6 )
		aWhen[06] := .T.
	endif
	if empty( cTab7 )
		aWhen[07] := .T.
	endif
	if empty( cTab8 )
		aWhen[08] := .T.
	endif
	if empty( cTab9 )
		aWhen[09] := .T.
	endif
	if empty( cTab10 )
		aWhen[10] := .T.
	endif
	if empty( cTab11 )
		aWhen[11] := .T.
	endif 
	if empty( cTab12 )
		aWhen[12] := .T.
	endif
	if empty( cTab13 )
		aWhen[13] := .T.
	endif
	if empty( cTab14 )
		aWhen[14] := .T.
	endif	
	if empty( cTab15 )
		aWhen[15] := .T.
	endif	
	if empty( cTab16 )
		aWhen[16] := .T.
	endif 
	
	//FR - 17/02/2022 - posição 22 tabela log consulta fornecedores	
	If empty( cTab17 )
		aWhen[17] := .T.
	Endif 

	If empty( cTab18 )
		aWhen[18] := .T.
	Endif 

	//if aWhen[01] .or. aWhen[02] .or. aWhen[03] .or. aWhen[04] .or. aWhen[05] .or. aWhen[06] .or. aWhen[07] .or. aWhen[08] .or. aWhen[09] .or. aWhen[10] .or. aWhen[11] .or. aWhen[12] .or. aWhen[13] .or. aWhen[14] .or. aWhen[15] .or. aWhen[16]
	//FR - 17/02/2022 - tabela log consulta fornecedores	
	if aWhen[01] .or. aWhen[02] .or. aWhen[03] .or. aWhen[04] .or. aWhen[05] .or. aWhen[06] .or. aWhen[07] .or. aWhen[08] .or. aWhen[09] .or. aWhen[10] .or. aWhen[11] .or. aWhen[12] .or. aWhen[13] .or. aWhen[14] .or. aWhen[15] .or. aWhen[16] .or. aWhen[17] .or. aWhen[18] 
		
		//aWhen := {.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.}   //FR - 15/11/19		
		//FR - 17/02/2022 - tabela log consulta fornecedores	
		aWhen := {.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F.,.F., .F.,.F.} 
		RpcSetType(3)
		RpcSetEnv(aVetor[nPos][2], aVetor[nPos][3])   //SM0->M0_CODIGO, SM0->M0_CODFIL
	
		cTab1 := GetNewPar("XM_TABXML" ,"   ")
		cTab2 := GetNewPar("XM_TABAMAR","   ")
		cTab3 := GetNewPar("XM_TABREC" ,"   ")
		If lBossKey
			cTab4 := GetNewPar("XM_TABZBX","   ")
		EndIf
		cTab5 := GetNewPar("XM_TABSINC","   ")
		cTab6 := GetNewPar("XM_TABAMA2","   ")
		cTab7 := GetNewPar("XM_TABEVEN","   ")
		cTab8 := GetNewPar("XM_TABSYX" ,"   ")
		cTab9 := GetNewPar("XM_TABCAC" ,"   ")
		cTab10:= GetNewPar("XM_TABOCOR","   ")
		cTab11:= GetNewPar("XM_TABIEXT","   ")
		cTab12:= GetNewPar("XM_TABITEM","   ")
		cTab13:= GetNewPar("XM_TABMUN","   ")
		cTab14:= GetNewPar("XM_TABMUN2","   ")
		cTab15:= GetNewPar("XM_TABIMC","   ")
		cTab16:= GetNewPar("XM_TABCON","   ") 
		//FR - 17/02/2022 - tabela log consulta fornecedores	
		cTab17:= GetNewPar("XM_TABLOG","   ") 
		cTab18:= GetNewPar("XM_TABTPO","   ") 
	
		RstMvBuff()
	EndIf
	
	if empty( cTab1 )
		cTab1 := "ZBZ"
		aWhen[1] := .T.
	endif
	if empty( cTab2 )
		cTab2 := "ZB5"
		aWhen[2] := .T.
	endif
	if empty( cTab3 )
		cTab3 := "ZBB"
		aWhen[3] := .T.
	endif
	if empty( cTab4 )
		cTab4 := "ZBX"
		aWhen[4] := .T.
	endif
	if empty( cTab5 )
		cTab5 := "ZBS"
		aWhen[5] := .T.
	endif
	if empty( cTab6 )
		cTab6 := "ZBA"
		aWhen[6] := .T.
	endif
	if empty( cTab7 )
		cTab7 := "ZBE"
		aWhen[7] := .T.
	endif
	if empty( cTab8 )
		cTab8 := "ZYX"
		aWhen[8] := .T.
	endif
	if empty( cTab9 )
		cTab9 := "ZBC"
		aWhen[9] := .T.
	endif
	if empty( cTab10 )
		cTab10:= "ZBO"
		aWhen[10] := .T.
	endif
	if empty( cTab11 )
		cTab11:= "ZBI"
		aWhen[11] := .T.
	endif 
	if empty( cTab12 )
		cTab12:= "ZBT"
		aWhen[12] := .T.
	endif
	if empty( cTab13 )
		cTab13:= "ZBM"
		aWhen[13] := .T.
	endif
	if empty( cTab14 )
		cTab14:= "ZBN"
		aWhen[14] := .T.
	endif
	if empty( cTab15 )
		cTab15:= "ZBD"
		aWhen[15] := .T.
	endif
	if empty( cTab16 )
		cTab16:= "ZBF"
		aWhen[16] := .T.
	endif

	//FR - 17/02/2022 - tabela log consulta fornecedores
	If empty( cTab17 )
		cTab17:= "ZBG"
		aWhen[17] := .T.
	Endif	

	If empty( cTab18 )
		cTab18:= "ZBH"
		aWhen[18] := .T.
	Endif	

	//lRet := TelaTab( aVetor, nPos, @cTab1, @cTab2, @cTab3, @cTab4, @cTab5, @cTab6, @cTab7, @cTab8, @cTab9, @cTab10, @cTab11, @cTab12, @cTab13, @cTab14, @cTab15, @cTab16 )
	//FR - 17/02/2022 - ALTERAÇÃO tabela log consulta fornecedores
 	lRet := TelaTab( aVetor, nPos, @cTab1, @cTab2, @cTab3, @cTab4, @cTab5, @cTab6, @cTab7, @cTab8, @cTab9, @cTab10, @cTab11, @cTab12, @cTab13, @cTab14, @cTab15, @cTab16, @cTab17, @cTab18 )
	
	if lRet
		aVetor[nPos, 06] := cTab1
		aVetor[nPos, 07] := cTab2
		aVetor[nPos, 08] := cTab3
		aVetor[nPos, 09] := cTab4
		aVetor[nPos, 10] := cTab5
		aVetor[nPos, 11] := cTab6
		aVetor[nPos, 12] := cTab7
		aVetor[nPos, 13] := cTab8
		aVetor[nPos, 14] := cTab9
		aVetor[nPos, 15] := cTab10
		aVetor[nPos, 16] := cTab11
		aVetor[nPos, 17] := cTab12
		aVetor[nPos, 18] := cTab13
		aVetor[nPos, 19] := cTab14
		aVetor[nPos, 20] := cTab15
		aVetor[nPos, 21] := cTab16
		//FR - 17/02/2022 - tabela log consulta fornecedores
		aVetor[nPos, 22] := cTab17
		aVetor[nPos, 23] := cTab18
		
		oLbx:Refresh()
	endif
	
	//if aWhen[1] .or. aWhen[2] .or. aWhen[3] .or. aWhen[4] .or. aWhen[5] .or. aWhen[6] .or. aWhen[7] .or. aWhen[8] .or. aWhen[9] .or. aWhen[10] .or. aWhen[11] .or. aWhen[12] .or. aWhen[13] .or. aWhen[14] .or. aWhen[15] .or. aWhen[16] 
	//FR - 17/02/2022 - alteração - tabela log consulta fornecedores
	if aWhen[1] .or. aWhen[2] .or. aWhen[3] .or. aWhen[4] .or. aWhen[5] .or. aWhen[6] .or. aWhen[7] .or. aWhen[8] .or. aWhen[9] .or. aWhen[10] .or. aWhen[11] .or. aWhen[12] .or. aWhen[13] .or. aWhen[14] .or. aWhen[15] .or. aWhen[16] .or. aWhen[17] .or. aWhen[18]
		RstMvBuff()
		DelClassIntf()
		RpcClearEnv()
	endif

Return( NIL )

*******************************************************************************************************************************
Static Function TelaTab( aVetor, nPos, cTab1, cTab2, cTab3, cTab4, cTab5, cTab6, cTab7, cTab8, cTab9, cTab10, cTab11, cTab12, cTab13, cTab14, cTab15, cTab16, cTab17, cTab18 ) 
*******************************************************************************************************************************
	Local lRet := .T.
	Local oDlg
	
	
	DO While .T.
	
		//DEFINE MSDIALOG oDlg TITLE "Tabelas P/ o Importa XML ("+aVetor[nPos][2]+"-"+alltrim(aVetor[nPos][4])+")" FROM 000,000 TO 490,400 PIXEL
		DEFINE MSDIALOG oDlg TITLE "Tabelas P/ o Gestão XML ("+aVetor[nPos][2]+"-"+alltrim(aVetor[nPos][4])+")" FROM 000,000 TO 480,820 PIXEL
	
		@ 010,010 Say "Tabela dos XMLs Importados (exemplo: ZBZ)" SIZE 310,230 PIXEL OF oDlg
		@ 010,150 Get oTab1 VAR cTab1 When aWhen[1] SIZE 30,08 PIXEL OF oDlg
	
		@ 030,010 Say "Tabela Amarração Produtos (exemplo: ZB5)" SIZE 310,230 PIXEL OF oDlg
		@ 030,150 Get oTab2 VAR cTab2 When aWhen[2] SIZE 30,08 PIXEL OF oDlg
	
		@ 050,010 Say "Tabela Pedido Recorrente (exemplo: ZBB)" SIZE 310,230 PIXEL OF oDlg
		@ 050,150 Get oTab3 VAR cTab3 When aWhen[3] SIZE 30,08 PIXEL OF oDlg
	
		@ 070,010 Say "Tabela Sincronização XML com Sefaz (exemplo: ZBS)" SIZE 310,230 PIXEL OF oDlg
		@ 070,150 Get oTab5 VAR cTab5 When aWhen[5] SIZE 30,08 PIXEL OF oDlg
	
		@ 090,010 Say "Tabela Usuário Amarração Secundária (exemplo: ZBA)" SIZE 310,230 PIXEL OF oDlg
		@ 090,150 Get oTab6 VAR cTab6 When aWhen[6] SIZE 30,08 PIXEL OF oDlg
	
		@ 110,010 Say "Tabela Eventos e Carta de Correção (exemplo: ZBE)" SIZE 310,230 PIXEL OF oDlg
		@ 110,150 Get oTab7 VAR cTab7 When aWhen[7] SIZE 30,08 PIXEL OF oDlg
	
		@ 130,010 Say "Tabela Consultas Systax (exemplo: ZYX)" SIZE 310,230 PIXEL OF oDlg
		@ 130,150 Get oTab8 VAR cTab8 When aWhen[8] SIZE 30,08 PIXEL OF oDlg
	
		@ 150,010 Say "Tabela Classificação Automática (exemplo: ZBC)" SIZE 310,230 PIXEL OF oDlg
		@ 150,150 Get oTab9 VAR cTab9 When aWhen[9] SIZE 30,08 PIXEL OF oDlg
	
		@ 170,010 Say "Tabela Ocorrências de Integrações (exemplo: ZBO)" SIZE 310,230 PIXEL OF oDlg
		@ 170,150 Get oTab10 VAR cTab10 When aWhen[10] SIZE 30,08 PIXEL OF oDlg
	
		@ 190,010 Say "Tabela Integrações Externa (exemplo: ZBI)" SIZE 310,230 PIXEL OF oDlg
		@ 190,150 Get oTab11 VAR cTab11 When aWhen[11] SIZE 30,08 PIXEL OF oDlg
	
		//FR - 17/02/2022 - tabela log consulta fornecedores			
		//@ 210,210 Say "Log Consulta Fornecedores (exemplo: ZBG)" SIZE 310,230 PIXEL OF oDlg
		//@ 210,350 Get oTab17 VAR cTab17 When aWhen[17] SIZE 30,08 PIXEL OF oDlg		
		If lBossKey
		    @ 010,210 Say "Tabela Licenças de Uso (exemplo: ZBX)" SIZE 310,230 PIXEL OF oDlg
			@ 010,350 Get oTab4 VAR cTab4 When aWhen[4] SIZE 30,08 PIXEL OF oDlg
			
			@ 030,210 Say "Tabela Itens da NF (exemplo: ZBT)" SIZE 310,230 PIXEL OF oDlg
			@ 030,350 Get oTab12 VAR cTab12 When aWhen[12] SIZE 30,08 PIXEL OF oDlg

			@ 050,210 Say "Tabela Municipios API (exemplo: ZBM)" SIZE 310,230 PIXEL OF oDlg
			@ 050,350 Get oTab12 VAR cTab13 When aWhen[13] SIZE 30,08 PIXEL OF oDlg

			@ 070,210 Say "Tabela Leituras API (exemplo: ZBN)" SIZE 310,230 PIXEL OF oDlg
			@ 070,350 Get oTab12 VAR cTab14 When aWhen[14] SIZE 30,08 PIXEL OF oDlg

			@ 090,210 Say "Image Converter (exemplo: ZBD)" SIZE 310,230 PIXEL OF oDlg
			@ 090,350 Get oTab15 VAR cTab15 When aWhen[15] SIZE 30,08 PIXEL OF oDlg

			@ 110,210 Say "Controle de Consumo (exemplo: ZBF)" SIZE 310,230 PIXEL OF oDlg
			@ 110,350 Get oTab16 VAR cTab16 When aWhen[16] SIZE 30,08 PIXEL OF oDlg
			//FR - 17/02/2022 - tabela log consulta fornecedores			
			@ 130,210 Say "Log Consulta Fornecedores (exemplo: ZBG)" SIZE 310,230 PIXEL OF oDlg
			@ 130,350 Get oTab17 VAR cTab17 When aWhen[17] SIZE 30,08 PIXEL OF oDlg

			@ 150,210 Say "Tipos de Ocorrencias de XML (exemplo: ZBH)" SIZE 310,230 PIXEL OF oDlg
			@ 150,350 Get oTab18 VAR cTab18 When aWhen[18] SIZE 30,08 PIXEL OF oDlg

		Else
			@ 010,210 Say "Tabela Itens da NF (exemplo: ZBT)" SIZE 310,230 PIXEL OF oDlg
			@ 010,350 Get oTab12 VAR cTab12 When aWhen[12] SIZE 30,08 PIXEL OF oDlg

			@ 030,210 Say "Tabela Municipios API (exemplo: ZBM)" SIZE 310,230 PIXEL OF oDlg
			@ 030,350 Get oTab12 VAR cTab13 When aWhen[13] SIZE 30,08 PIXEL OF oDlg

			@ 050,210 Say "Tabela Leituras API (exemplo: ZBN)" SIZE 310,230 PIXEL OF oDlg
			@ 050,350 Get oTab12 VAR cTab14 When aWhen[14] SIZE 30,08 PIXEL OF oDlg

			@ 070,210 Say "Image Converter (exemplo: ZBD)" SIZE 310,230 PIXEL OF oDlg
			@ 070,350 Get oTab15 VAR cTab15 When aWhen[15] SIZE 30,08 PIXEL OF oDlg

			@ 090,210 Say "Controle de Consumo (exemplo: ZBF)" SIZE 310,230 PIXEL OF oDlg
			@ 090,350 Get oTab16 VAR cTab16 When aWhen[16] SIZE 30,08 PIXEL OF oDlg	 
			
			//FR - 17/02/2022 - tabela log consulta fornecedores			
			@ 110,210 Say "Log Consulta Fornecedores (exemplo: ZBG)" SIZE 310,230 PIXEL OF oDlg
			@ 110,350 Get oTab17 VAR cTab17 When aWhen[17] SIZE 30,08 PIXEL OF oDlg

			@ 130,210 Say "Tipos de Ocorrencias de XML (exemplo: ZBH)" SIZE 310,230 PIXEL OF oDlg
			@ 130,350 Get oTab18 VAR cTab18 When aWhen[18] SIZE 30,08 PIXEL OF oDlg

		Endif
		
		@ 220,180 BUTTON "OK" SIZE 30,15 PIXEL OF oDlg ACTION oDlg:End()
		@ 220,220 BUTTON "Cancela" SIZE 30,15 PIXEL OF oDlg ACTION ( lRet:=.F.,oDlg:End() )
	
		ACTIVATE MSDIALOG oDlg CENTERED
	
		if !( lRet )
			Exit
		endif
		cTab1 := UPPER(cTab1)
		cTab2 := UPPER(cTab2)
		cTab3 := UPPER(cTab3)
		cTab4 := UPPER(cTab4)
		cTab5 := UPPER(cTab5)
		cTab6 := UPPER(cTab6)
		cTab7 := UPPER(cTab7)
		cTab8 := UPPER(cTab8)
		cTab9 := UPPER(cTab9)
		cTab10:= UPPER(cTab10)
		cTab11:= UPPER(cTab11)
		cTab12:= UPPER(cTab12)
		cTab13:= UPPER(cTab13)
		cTab14:= UPPER(cTab14)
		cTab15:= UPPER(cTab15)
		cTab16:= UPPER(cTab16)
	
		//FR - 17/02/2022 - alteração - tabela log consulta fornecedores
		cTab17:= UPPER(cTab17)		
		cTab18:= UPPER(cTab18)	
	
		//If aWhen[1] .or. aWhen[2] .or. aWhen[3] .or. aWhen[4] .or. aWhen[5] .or. aWhen[6] .or. aWhen[6] .or. aWhen[7] .or. aWhen[8] .or. aWhen[9] .or. aWhen[10] .or. aWhen[11];
		//   .or. aWhen[12] .or. aWhen[13] .or. aWhen[14] .or. aWhen[15] .or. aWhen[16]
		
		//FR - 17/02/2022 - alteração - tabela log consulta fornecedores
		If aWhen[1] .or. aWhen[2] .or. aWhen[3] .or. aWhen[4] .or. aWhen[5] .or. aWhen[6] .or. aWhen[6] .or. aWhen[7] .or. aWhen[8] .or. aWhen[9] .or. aWhen[10] .or. aWhen[11];
		   .or. aWhen[12] .or. aWhen[13] .or. aWhen[14] .or. aWhen[15] .or. aWhen[16] .or. aWhen[17] .or. aWhen[18]
			dbSelectArea( "SX2" )
			dbSetOrder(1)
			If SX2->( DbSeek( cTab1 ) ) .and. aWhen[1]
				If ! Ver2TAB( "1", cTab1 )				
					U_MyAviso("Aviso","Tabela " + cTab1 + "-" + Alltrim(SX2->X2_NOME) + " já é utilizada pelo seu sistema.",{"Ok"},1)
					Loop
				EndIf
			EndIf
			If SX2->( DbSeek( cTab2 ) ) .and. aWhen[2]
				If ! Ver2TAB( "2", cTab2 )				
					U_MyAviso("Aviso","Tabela " + cTab2 + "-" + Alltrim(SX2->X2_NOME) + " já é utilizada pelo seu sistema.",{"Ok"},1)
					Loop
				EndIf
			EndIf
			If SX2->( DbSeek( cTab3 ) ) .and. aWhen[3]
				If ! Ver2TAB( "3", cTab3 )
					U_MyAviso("Aviso","Tabela " + cTab3 + "-" + Alltrim(SX2->X2_NOME) + " já é utilizada pelo seu sistema.",{"Ok"},1)
					Loop
				EndIf
			EndIf
			If lBossKey
				If SX2->( DbSeek( cTab4 ) ) .and. aWhen[4]
					If ! Ver2TAB( "4", cTab4 )					
						U_MyAviso("Aviso","Tabela " + cTab4 + "-" + Alltrim(SX2->X2_NOME) + " já é utilizada pelo seu sistema.",{"Ok"},1)
						Loop
					EndIF
				EndIf
			EndIf
			If SX2->( DbSeek( cTab5 ) ) .and. aWhen[5]
				If ! Ver2TAB( "5", cTab5 )			
					U_MyAviso("Aviso","Tabela " + cTab5 + "-" + Alltrim(SX2->X2_NOME) + " já é utilizada pelo seu sistema.",{"Ok"},1)
					Loop
				EndIF
			EndIf
			If SX2->( DbSeek( cTab6 ) ) .and. aWhen[6]
				If ! Ver2TAB( "6", cTab6 )				
					U_MyAviso("Aviso","Tabela " + cTab6 + "-" + Alltrim(SX2->X2_NOME) + " já é utilizada pelo seu sistema.",{"Ok"},1)
					Loop
				EndIf
			EndIf
			If SX2->( DbSeek( cTab7 ) ) .and. aWhen[7]
				If ! Ver2TAB( "7", cTab7 )				
					U_MyAviso("Aviso","Tabela " + cTab7 + "-" + Alltrim(SX2->X2_NOME) + " já é utilizada pelo seu sistema.",{"Ok"},1)
					Loop
				EndIF
			EndIf
			If SX2->( DbSeek( cTab8 ) ) .and. aWhen[8]
				If ! Ver2TAB( "8", cTab8 )				
					U_MyAviso("Aviso","Tabela " + cTab8 + "-" + Alltrim(SX2->X2_NOME) + " já é utilizada pelo seu sistema.",{"Ok"},1)
					Loop
				EndIF
			EndIf
			If SX2->( DbSeek( cTab9 ) ) .and. aWhen[9]
				If ! Ver2TAB( "9", cTab9 )				
					U_MyAviso("Aviso","Tabela " + cTab9 + "-" + Alltrim(SX2->X2_NOME) + " já é utilizada pelo seu sistema.",{"Ok"},1)
					Loop
				EndIF
			EndIf
			If SX2->( DbSeek( cTab10 ) ) .and. aWhen[10]
				If ! Ver2TAB( "10", cTab10 )				
					U_MyAviso("Aviso","Tabela " + cTab10 + "-" + Alltrim(SX2->X2_NOME) + " já é utilizada pelo seu sistema.",{"Ok"},1)
					Loop
				EndIF
			EndIf
			If SX2->( DbSeek( cTab11 ) ) .and. aWhen[11]
				If ! Ver2TAB( "11", cTab11 )				
					U_MyAviso("Aviso","Tabela " + cTab11 + "-" + Alltrim(SX2->X2_NOME) + " já é utilizada pelo seu sistema.",{"Ok"},1)
					Loop
				EndIF
			EndIf		
			If SX2->( DbSeek( cTab12 ) ) .and. aWhen[12]			//FR - 15/11/19
				If ! Ver2TAB( "12", cTab12 )				
					U_MyAviso("Aviso","Tabela " + cTab12 + "-" + Alltrim(SX2->X2_NOME) + " já é utilizada pelo seu sistema.",{"Ok"},1)
					Loop
				EndIF
			EndIf
			If SX2->( DbSeek( cTab13 ) ) .and. aWhen[13]			//HMS - 31/08/19
				If ! Ver2TAB( "13", cTab13 )				
					U_MyAviso("Aviso","Tabela " + cTab13 + "-" + Alltrim(SX2->X2_NOME) + " já é utilizada pelo seu sistema.",{"Ok"},1)
					Loop
				EndIF
			EndIf		
			If SX2->( DbSeek( cTab14 ) ) .and. aWhen[14]			//HMS - 03/09/19
				If ! Ver2TAB( "14", cTab14 )				
					U_MyAviso("Aviso","Tabela " + cTab14 + "-" + Alltrim(SX2->X2_NOME) + " já é utilizada pelo seu sistema.",{"Ok"},1)
					Loop
				EndIF
			EndIf					
			If SX2->( DbSeek( cTab15 ) ) .and. aWhen[15]			//HMS - 03/09/19
				If ! Ver2TAB( "15", cTab15 )				
					U_MyAviso("Aviso","Tabela " + cTab15 + "-" + Alltrim(SX2->X2_NOME) + " já é utilizada pelo seu sistema.",{"Ok"},1)
					Loop
				EndIF
			EndIf	
			If SX2->( DbSeek( cTab16 ) ) .and. aWhen[16]			//HMS - 03/09/19
				If ! Ver2TAB( "16", cTab16 )				
					U_MyAviso("Aviso","Tabela " + cTab16 + "-" + Alltrim(SX2->X2_NOME) + " já é utilizada pelo seu sistema.",{"Ok"},1)
					Loop
				EndIF
			EndIf
			//FR - 17/02/2022 - alteração - tabela log consulta fornecedores  
			If SX2->( DbSeek( cTab17 ) ) .and. aWhen[17]		
				If ! Ver2TAB( "17", cTab17 )				
					U_MyAviso("Aviso","Tabela " + cTab17 + "-" + Alltrim(SX2->X2_NOME) + " já é utilizada pelo seu sistema.",{"Ok"},1)
					Loop
				EndIF
			EndIf		
			If SX2->( DbSeek( cTab18 ) ) .and. aWhen[18]		
				If ! Ver2TAB( "18", cTab18 )				
					U_MyAviso("Aviso","Tabela " + cTab18 + "-" + Alltrim(SX2->X2_NOME) + " já é utilizada pelo seu sistema.",{"Ok"},1)
					Loop
				EndIF
			EndIf								
		EndIF
	
		Exit
	
	EndDo

Return( lRet )

***************************************
Static Function Ver2TAB( cQual, cTab )  //Só para o Legado 
***************************************
	Local aArea := GetArea()
	Local lRet  := .F.
	Local cPrf  := iif(Substr(cTab,1,1)=="S", Substr(cTab,2,2), Substr(cTab,1,3)) + "_"
	
	DbSelectArea("SX2")
	dbSetOrder(1)
	if DbSeek(cTab)
		lRet  := .F.
		DbSelectArea("SX3")
		dbSetOrder(2)
		if cQual == "1"       				//ZBZ
			//===================================================================================//
			//se existir estes quatro campos é a nossa Tabela por legado da ZBZ                  //
			//===================================================================================//
			if DbSeek( cPrf+"CHAVE" )
				if  DbSeek( cPrf+"XML" )
					if  DbSeek( cPrf+"PRENF" )
						if  DbSeek( cPrf+"PROT" )  
							lRet := .T.
						endif
					endif
				endif
			endif
		elseif cQual == "2"     			//ZB5
			if DbSeek( cPrf+"PRODFI" ) 
				if DbSeek( cPrf+"PRODFO" )
					if DbSeek( cPrf+"DESCPR" )
						if DbSeek( cPrf+"CGCC" )
							lRet := .T.
						endif
					endif
				endif
			endif
		elseif cQual == "3"  				//ZBB
			if DbSeek( cPrf+"FORNEC" ) 
				if DbSeek( cPrf+"AMARRA" )
					if DbSeek( cPrf+"ATUAL" )
						if DbSeek( cPrf+"VUNIT" )
							lRet := .T.
						endif
					endif
				endif
			endif
		Elseif cQual == "4" 				//ZBX
			if DbSeek( cPrf+"CNPJ_L" ) 
				if DbSeek( cPrf+"DTLIB" )
					lRet := .T.
				endif
			endif
		Elseif cQual == "5" 				//ZBS
			if DbSeek( cPrf+"CHAVE" ) 
				if DbSeek( cPrf+"NSU" )
					if DbSeek( cPrf+"DIGVAL" )
						lRet := .T.
					EndIF
				endif
			endif
		Elseif cQual == "6"      			//ZBA
			if DbSeek( cPrf+"CODUSR" ) 
				if DbSeek( cPrf+"USUARI" )
					if DbSeek( cPrf+"AMARRA" )
						lRet := .T.
					EndIF
				endif
			endif
		Elseif cQual == "7"     			//ZBE
			if DbSeek( cPrf+"CHAVE" ) 
				if DbSeek( cPrf+"TPEVE" )
					if DbSeek( cPrf+"SEQEVE" )
						lRet := .T.
					EndIF
				endif
			endif
		Elseif cQual == "8"    				//ZYX
			if DbSeek( cPrf+"CHAVE" ) 
				if DbSeek( cPrf+"SEQ" )
					if DbSeek( cPrf+"PROT" )
						if DbSeek( cPrf+"XMLRET" )
							lRet := .T.
						Endif
					EndIF
				endif
			endif
		Elseif cQual == "9"   				//ZBC
			if DbSeek( cPrf+"CODFOR" ) 
				if DbSeek( cPrf+"PROD" )
					if DbSeek( cPrf+"TES" )
						if DbSeek( cPrf+"CC" )
							lRet := .T.
						Endif
					EndIF
				endif
			endif
		Elseif cQual == "10"  				//ZBO
			if DbSeek( cPrf+"CODSEQ" ) 
				if DbSeek( cPrf+"RETSEF" )
	 				if DbSeek( cPrf+"FTP" )
	  						lRet := .T.
					endif
				endif
			endif
		Elseif cQual == "11"  				//ZBI
			if DbSeek( cPrf+"ARQ" ) 
				if DbSeek( cPrf+"DIR" )
	 				if DbSeek( cPrf+"DTARQ" )
						if DbSeek( cPrf+"FTP" )
	  						lRet := .T.
						endif
					endIF
				endif
			endif
		Elseif cQual == "12"  				//ZBT
			if DbSeek( cPrf+"CHAVE" ) 
				if DbSeek( cPrf+"PEDIDO" ) 
					if DbSeek( cPrf+"ITEMPC" )
	 					if DbSeek( cPrf+"PRODUT" )
							lRet := .T.
						endif
					endif
				endif
			endif
		Elseif cQual == "18"  				//ZBH
			if DbSeek( cPrf+"COD" ) 
				if DbSeek( cPrf+"ATIVO" ) 
					if DbSeek( cPrf+"DESC" )
	 					if DbSeek( cPrf+"TIPO" )
							lRet := .T.
						endif
					endif
				endif
			endif
		EndIf		
	Else
		lRet := .T.
	EndIf
	
	RestArea(aArea)
Return( lRet )



//===============//
//     xTag      //
//===============//
**********************************************
Static Function xTag(cTag,cTipo,uText,SubTag)
**********************************************
	Local cRetorno := ""                                                       
	cRetorno += '<'+cTag+'>'
	If cTipo=="C"
		cRetorno += AllTrim(uText)
	ElseIf cTipo=="N"
		cRetorno += AllTrim(Str(uText))
	ElseIf cTipo=="A"
	
	EndIf
	cRetorno += '</'+cTag+'>'
Return(cRetorno)


/*/{Protheus.doc} zPutSX1
Função para criar Grupo de Perguntas
@author Rogério Lino
@since 26/03/2020
@version 1.0
@type function
    @param cGrupo,    characters, Grupo de Perguntas       (ex.: X_TESTE)
    @param cOrdem,    characters, Ordem da Pergunta        (ex.: 01, 02, 03, ...)
    @param cTexto,    characters, Texto da Pergunta        (ex.: Produto De, Produto Até, Data De, ...)
    @param cMVPar,    characters, MV_PAR?? da Pergunta     (ex.: MV_PAR01, MV_PAR02, MV_PAR03, ...)
    @param cVariavel, characters, Variável da Pergunta     (ex.: MV_CH0, MV_CH1, MV_CH2, ...)
    @param cTipoCamp, characters, Tipo do Campo            (C = Caracter, N = Numérico, D = Data)
    @param nTamanho,  numeric,    Tamanho da Pergunta      (Máximo de 60)
    @param nDecimal,  numeric,    Tamanho de Decimais      (Máximo de 9)
    @param cTipoPar,  characters, Tipo do Parâmetro        (G = Get, C = Combo, F = Escolha de Arquivos, K = Check Box)
    @param cValid,    characters, Validação da Pergunta    (ex.: Positivo(), u_SuaFuncao(), ...)
    @param cF3,       characters, Consulta F3 da Pergunta  (ex.: SB1, SA1, ...)
    @param cPicture,  characters, Máscara do Parâmetro     (ex.: @!, @E 999.99, ...)
    @param cDef01,    characters, Primeira opção do combo
    @param cDef02,    characters, Segunda opção do combo
    @param cDef03,    characters, Terceira opção do combo
    @param cDef04,    characters, Quarta opção do combo
    @param cDef05,    characters, Quinta opção do combo
    @param cHelp,     characters, Texto de Help do parâmetro
    @obs Função foi criada, pois a partir de algumas versões do Protheus 12, a função padrão PutSX1 não funciona (por medidas de segurança)
    @example Abaixo um exemplo de como criar um grupo de perguntas
     
    cPerg    := "X_TST"
     
    cValid   := ""
    cF3      := ""
    cPicture := ""
    cDef01   := ""
    cDef02   := ""
    cDef03   := ""
    cDef04   := ""
    cDef05   := ""
     
    u_zPutSX1(cPerg, "01", "Produto De?",       "MV_PAR01", "MV_CH0", "C", TamSX3('B1_COD')[01], 0, "G", cValid,       "SB1", cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe o produto inicial")
    u_zPutSX1(cPerg, "02", "Produto Até?",      "MV_PAR02", "MV_CH1", "C", TamSX3('B1_COD')[01], 0, "G", cValid,       "SB1", cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe o produto final")
    u_zPutSX1(cPerg, "03", "A partir da Data?", "MV_PAR03", "MV_CH2", "D", 08,                   0, "G", cValid,       cF3,   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe a data inicial a ser considerada")
    u_zPutSX1(cPerg, "04", "Média maior que?",  "MV_PAR04", "MV_CH3", "N", 09,                   2, "G", "Positivo()", cF3,   "@E 999,999.99", cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe a média de atraso que será considerada")
    u_zPutSX1(cPerg, "05", "Tipo de Saldos?",   "MV_PAR05", "MV_CH4", "N", 01,                   0, "C", cValid,       cF3,   cPicture,        "Todos", "Maior que 0", "Menor que 0", "Zerados", cDef05, "Informe o tipo de saldo a ser considerado")
    u_zPutSX1(cPerg, "06", "Tipos de Produto?", "MV_PAR06", "MV_CH5", "C", 60,                   0, "K", cValid,       cF3,   cPicture,        "PA",    "PI",          "MP",          cDef04,    cDef05, "Informe os tipos de produto que serão considerados")
    u_zPutSX1(cPerg, "07", "Caminho de Log?",   "MV_PAR07", "MV_CH6", "C", 60,                   0, "F", cValid,       cF3,   cPicture,        cDef01,  cDef02,        cDef03,        cDef04,    cDef05, "Informe o caminho para geração do log")
/*/
 
User Function zPutSX1(cGrupo, cOrdem, cTexto, cMVPar, cVariavel, cTipoCamp, nTamanho, nDecimal, cTipoPar, cValid, cF3, cPicture, cDef01, cDef02, cDef03, cDef04, cDef05, cHelp)
    Local aArea       := GetArea()
    Local cChaveHelp  := ""
    Local nPreSel     := 0
    Default cGrupo    := Space(10)
    Default cOrdem    := Space(02)
    Default cTexto    := Space(30)
    Default cMVPar    := Space(15)
    Default cVariavel := Space(6)
    Default cTipoCamp := Space(1)
    Default nTamanho  := 0
    Default nDecimal  := 0
    Default cTipoPar  := "G"
    Default cValid    := Space(60)
    Default cF3       := Space(6)
    Default cPicture  := Space(40)
    Default cDef01    := Space(15)
    Default cDef02    := Space(15)
    Default cDef03    := Space(15)
    Default cDef04    := Space(15)
    Default cDef05    := Space(15)
    Default cHelp     := ""
     
    //Se tiver Grupo, Ordem, Texto, Parâmetro, Variável, Tipo e Tamanho, continua para a criação do parâmetro
    If !Empty(cGrupo) .And. !Empty(cOrdem) .And. !Empty(cTexto) .And. !Empty(cMVPar) .And. !Empty(cVariavel) .And. !Empty(cTipoCamp) .And. nTamanho != 0
         
        //Definição de variáveis
        cGrupo     := PadR(cGrupo, Len(SX1->X1_GRUPO), " ")           //Adiciona espaços a direita para utilização no DbSeek
        cChaveHelp := "P." + AllTrim(cGrupo) + AllTrim(cOrdem) + "."  //Define o nome da pergunta
        cMVPar     := Upper(cMVPar)                                   //Deixa o MV_PAR tudo em maiúsculo
        nPreSel    := Iif(cTipoPar == "C", 1, 0)                      //Se for Combo, o pré-selecionado será o Primeiro
        cDef01     := Iif(cTipoPar == "F", "56", cDef01)              //Se for File, muda a definição para ser tanto Servidor quanto Local
        nTamanho   := Iif(nTamanho > 60, 60, nTamanho)                //Se o tamanho for maior que 60, volta para 60 - Limitação do Protheus
        nDecimal   := Iif(nDecimal > 9,  9,  nDecimal)                //Se o decimal for maior que 9, volta para 9
        nDecimal   := Iif(cTipoPar == "N", nDecimal, 0)               //Se não for parâmetro do tipo numérico, será 0 o Decimal
        cTipoCamp  := Upper(cTipoCamp)                                //Deixa o tipo do Campo em maiúsculo
        cTipoCamp  := Iif(! cTipoCamp $ 'C;D;N;', 'C', cTipoCamp)     //Se o tipo do Campo não estiver entre Caracter / Data / Numérico, será Caracter
        cTipoPar   := Upper(cTipoPar)                                 //Deixa o tipo do Parâmetro em maiúsculo
        cTipoPar   := Iif(Empty(cTipoPar), 'G', cTipoPar)             //Se o tipo do Parâmetro estiver em branco, será um Get
        nTamanho   := Iif(cTipoPar == "C", 1, nTamanho)               //Se for Combo, o tamanho será 1
     
        DbSelectArea('SX1')
        SX1->(DbSetOrder(1)) // Grupo + Ordem
     
        //Se não conseguir posicionar, a pergunta será criada
        If ! SX1->(DbSeek(cGrupo + cOrdem))
        
            RecLock('SX1', .T.)
            
                X1_GRUPO   := cGrupo
                X1_ORDEM   := cOrdem
                X1_PERGUNT := cTexto
                X1_PERSPA  := cTexto
                X1_PERENG  := cTexto
                X1_VAR01   := cMVPar
                X1_VARIAVL := cVariavel
                X1_TIPO    := cTipoCamp
                X1_TAMANHO := nTamanho
                X1_DECIMAL := nDecimal
                X1_GSC     := cTipoPar
                X1_VALID   := cValid
                X1_F3      := cF3
                X1_PICTURE := cPicture
                X1_DEF01   := cDef01
                X1_DEFSPA1 := cDef01
                X1_DEFENG1 := cDef01
                X1_DEF02   := cDef02
                X1_DEFSPA2 := cDef02
                X1_DEFENG2 := cDef02
                X1_DEF03   := cDef03
                X1_DEFSPA3 := cDef03
                X1_DEFENG3 := cDef03
                X1_DEF04   := cDef04
                X1_DEFSPA4 := cDef04
                X1_DEFENG4 := cDef04
                X1_DEF05   := cDef05
                X1_DEFSPA5 := cDef05
                X1_DEFENG5 := cDef05
                X1_PRESEL  := nPreSel
                 
                //Se tiver Help da Pergunta
                If !Empty(cHelp)
                
                    X1_HELP    := cChaveHelp
                     
                    fPutHelp(cChaveHelp, cHelp)
                    
                EndIf
                
            SX1->(MsUnlock())
            
        Else
        
        	 RecLock('SX1', .F.)
            
                X1_GRUPO   := cGrupo
                X1_ORDEM   := cOrdem
                X1_PERGUNT := cTexto
                X1_PERSPA  := cTexto
                X1_PERENG  := cTexto
                X1_VAR01   := cMVPar
                X1_VARIAVL := cVariavel
                X1_TIPO    := cTipoCamp
                X1_TAMANHO := nTamanho
                X1_DECIMAL := nDecimal
                X1_GSC     := cTipoPar
                X1_VALID   := cValid
                X1_F3      := cF3
                X1_PICTURE := cPicture
                X1_DEF01   := cDef01
                X1_DEFSPA1 := cDef01
                X1_DEFENG1 := cDef01
                X1_DEF02   := cDef02
                X1_DEFSPA2 := cDef02
                X1_DEFENG2 := cDef02
                X1_DEF03   := cDef03
                X1_DEFSPA3 := cDef03
                X1_DEFENG3 := cDef03
                X1_DEF04   := cDef04
                X1_DEFSPA4 := cDef04
                X1_DEFENG4 := cDef04
                X1_DEF05   := cDef05
                X1_DEFSPA5 := cDef05
                X1_DEFENG5 := cDef05
                X1_PRESEL  := nPreSel
                 
                //Se tiver Help da Pergunta
                If !Empty(cHelp)
                
                    X1_HELP    := cChaveHelp
                     
                    fPutHelp(cChaveHelp, cHelp)
                    
                EndIf
                
            SX1->(MsUnlock())
            
        EndIf
        
    EndIf
     
    RestArea(aArea)
    
Return
 
/*---------------------------------------------------*
 | Função: fPutHelp                                  |
 | Desc:   Função que insere o Help do Parametro     |
 *---------------------------------------------------*/
 
Static Function fPutHelp(cKey, cHelp, lUpdate)

    Local cFilePor  := "SIGAHLP.HLP"
    Local cFileEng  := "SIGAHLE.HLE"
    Local cFileSpa  := "SIGAHLS.HLS"
    Local nRet      := 0
    Local cQuery    := ""
    Local cAliasXB4 := GetNextAlias() 
    Local nStatus   := 0
    //Local cVersion  := Substr(GetRPORelease(),6,3)
    //Local bHelpExec := &("{|w,x,y,z| EngHLP123(w,x,y,z) }")
    
    Default cKey    := ""
    Default cHelp   := ""
    Default lUpdate := .F.
    
    //Verifica se a tabela existe no banco de dados
    if MsFile("XB4") 
    
	    //Posiciona na nova tabela XB4 - SIGAHLP
	    cQuery := " SELECT R_E_C_N_O_ AS RECNO FROM XB4 WHERE XB4_CODIGO = '"+cKey+"' " 
	    
	    DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasXB4,.T.,.T.)
	    
	    if (cAliasXB4)->( Eof() )
	    
		    nStatus := TCSqlExec(" INSERT INTO XB4 (XB4_CODIGO, XB4_TIPO, XB4_HLP40, XB4_HELP, XB4_IDIOMA) VALUES ('"+cKey+"', 'P', 'N', '"+cHelp+"', 'pt-br')" )
   
			if ( nStatus < 0 )
			
			  Conout( "TCSQLError() - UPDIF001 " + TCSQLError() )
			  
			endif
		  
		    	
		else
		
			nStatus := TCSqlExec(" UPDATE XB4 SET XB4_CODIGO = '"+cKey+"', XB4_TIPO = 'P', XB4_HLP40 = 'N', XB4_HELP = '"+cHelp+"', XB4_IDIOMA = 'pt-br' WHERE R_E_C_N_O_ = '"+cValToChar((cAliasXB4)->RECNO)+"'" )
   
			if ( nStatus < 0 )
			
			  Conout( "TCSQLError() - UPDIF001 " + TCSQLError() )
			  
			endif
    
		endif
		
		(cAliasXB4)->( DbCloseArea() )
    
    else
     
	    //Se a Chave ou o Help estiverem em branco
	    If Empty(cKey) .Or. Empty(cHelp)
	        Return
	    EndIf
	    
	    aHelp := {cHelp}
	    
	    //Eval(bHelpExec,cKey,aHelp,aHelp,aHelp)	    
	     
	    //**************************** Português
	    nRet := SPF_SEEK(cFilePor, cKey, 1)
	     
	    //Se não encontrar, será inclusão
	    If nRet < 0
	        SPF_INSERT(cFilePor, cKey, , , cHelp)
	     
	    //Senão, será atualização
	    Else
	        If lUpdate
	            SPF_UPDATE(cFilePor, nRet, cKey, , , cHelp)
	        EndIf
	    EndIf
	     
	         
	    //**************************** Inglês
	    nRet := SPF_SEEK(cFileEng, cKey, 1)
	     
	    //Se não encontrar, será inclusão
	    If nRet < 0
	        SPF_INSERT(cFileEng, cKey, , , cHelp)
	     
	    //Senão, será atualização
	    Else
	        If lUpdate
	            SPF_UPDATE(cFileEng, nRet, cKey, , , cHelp)
	        EndIf
	    EndIf
	     
	          
	    //**************************** Espanhol
	    nRet := SPF_SEEK(cFileSpa, cKey, 1)
	     
	    //Se não encontrar, será inclusão
	    If nRet < 0
	        SPF_INSERT(cFileSpa, cKey, , , cHelp)
	     
	    //Senão, será atualização
	    Else
	        If lUpdate
	            SPF_UPDATE(cFileSpa, nRet, cKey, , , cHelp)
	        EndIf
	    EndIf
	    
	endif
    
Return
//---------------------------------------------------------------------------------------------------//
//FR - 18/08/2020 - realiza a alteração nos campos: X3_CBOX, X3_CBOXSPA, X3_CBOXENG
//---------------------------------------------------------------------------------------------------//
*******************************************************************
User Function fAlterBox(aSX3,aAlterTb,aArqUpd,cAliaAlter,cCpoAlter)
*******************************************************************
Local cCBox := ""
Local fr    := 0
Local cCpo  := ""
Local cTab  := ""

dbSelectArea("SX3")
SX3->(dbSetOrder(2))   //X3_CAMPO 

cCBox := ""

ASORT( aSX3, , , { | x,y | x[3] < y[3] } )   //ordena por nome de campo
		
For fr := 1 to Len(aSX3)
	cCBox := aSX3[fr,28]
	cTab    := aSX3[fr,1] 
	
	If dbSeek(aSX3[fr,3])		//busca o campo
		If Alltrim(SX3->X3_CBOX) <> Alltrim(cCBox) 	//verifica se houve alteração no Combo Box
			cCpo := SX3->X3_CAMPO
					
			RecLock("SX3",.F.)
			SX3->X3_CBOX    := cCBox
			SX3->X3_CBOXSPA := cCBox
			SX3->X3_CBOXENG := cCBox
			MsUnLock()					
			
			If Ascan(aAlterTb, cTab) == 0
				aAdd(aAlterTb,cTab) 
			Endif
			
			If Ascan(aArqUpd,cTab) == 0
				aAdd(aArqUpd,cTab)
			Endif
					
			If !(cCpo $ cCpoAlter)
				cCpoAlter  += cCpo + "/"  //Log do campo alterado para exibir no final //FR - 10/03/2020
			Endif
			
			If !(cTab $ cAliaAlter)
				cAliaAlter  += cTab + "/"  //Log da tabela alterada para exibir no final //FR - 18/08/2020
			Endif
						                                                                                    
		EndIf
		
	Else  //campo novo
		//atualiza arrays e strings referência de alteração/criação de campo ou tabela para exibir no final
		If Ascan(aAlterTb, cTab) == 0
			aAdd(aAlterTb,cTab) 
		Endif
				
		If Ascan(aArqUpd,cTab) == 0
			aAdd(aArqUpd,cTab)
		Endif
				
		If !(cCpo $ cCpoAlter)
			cCpoAlter  += cCpo + "/"
		Endif
		
		If !(cTab $ cAliaAlter)
			cAliaAlter  += cTab + "/"  //Log da tabela alterada para exibir no final //FR - 18/08/2020
		Endif
		//atualiza arrays e strings referência de alteração/criação de campo ou tabela para exibir no final		
	Endif
	
Next

Return		
//---------------------------------------------------------------------------------------------------//
//FR - 10/03/2021 - realiza a alteração no campo: X3_F3
//---------------------------------------------------------------------------------------------------//
*******************************************************************
User Function fAlterF3(aSX3,aAlterTb,aArqUpd,cAliaAlter,cCpoAlter)
*******************************************************************
Local cF3   := ""
Local fr    := 0
Local cCpo  := ""
Local cTab  := ""

dbSelectArea("SX3")
SX3->(dbSetOrder(2))   //X3_CAMPO 

cF3 := ""

ASORT( aSX3, , , { | x,y | x[3] < y[3] } )   //ordena por nome de campo
		
For fr := 1 to Len(aSX3)
	cF3 := aSX3[fr,17]
	cTab    := aSX3[fr,1] 
	
	If dbSeek(aSX3[fr,3])		//busca o campo
		If Alltrim(SX3->X3_CBOX) <> Alltrim(cF3) 	//verifica se houve alteração no Combo Box
			cCpo := SX3->X3_CAMPO
					
			RecLock("SX3",.F.)
			SX3->X3_F3    := cF3		
			MsUnLock()					
			
			If Ascan(aAlterTb, cTab) == 0
				aAdd(aAlterTb,cTab) 
			Endif
			
			If Ascan(aArqUpd,cTab) == 0
				aAdd(aArqUpd,cTab)
			Endif
					
			If !(cCpo $ cCpoAlter)
				cCpoAlter  += cCpo + "/"  //Log do campo alterado para exibir no final //FR - 10/03/2020
			Endif
			
			If !(cTab $ cAliaAlter)
				cAliaAlter  += cTab + "/"  //Log da tabela alterada para exibir no final //FR - 18/08/2020
			Endif
						                                                                                    
		EndIf
		
	Else  //campo novo
		//atualiza arrays e strings referência de alteração/criação de campo ou tabela para exibir no final
		If Ascan(aAlterTb, cTab) == 0
			aAdd(aAlterTb,cTab) 
		Endif
				
		If Ascan(aArqUpd,cTab) == 0
			aAdd(aArqUpd,cTab)
		Endif
				
		If !(cCpo $ cCpoAlter)
			cCpoAlter  += cCpo + "/"
		Endif
		
		If !(cTab $ cAliaAlter)
			cAliaAlter  += cTab + "/"  //Log da tabela alterada para exibir no final //FR - 18/08/2020
		Endif
		//atualiza arrays e strings referência de alteração/criação de campo ou tabela para exibir no final		
	Endif
	
Next

Return				



//---------------------------------------------------------------------------------------------------//
//FR - 29/03/2021 - realiza a alteração no campo: X3_TITULO e X3_DESCRIC
//---------------------------------------------------------------------------------------------------//
*******************************************************************
User Function fAlterDesc(aSX3,aAlterTb,aArqUpd,cAliaAlter,cCpoAlter)
*******************************************************************
Local cDesc := ""
Local cTit  := ""
Local fr    := 0
Local cCpo  := ""
Local cTab  := ""

dbSelectArea("SX3")
SX3->(dbSetOrder(2))   //X3_CAMPO 

cF3 := ""

ASORT( aSX3, , , { | x,y | x[3] < y[3] } )   //ordena por nome de campo
		
For fr := 1 to Len(aSX3)
	cTit  := aSX3[fr,7]
	cDesc := aSX3[fr,10]	
	cTab    := aSX3[fr,1] 
	
	If dbSeek(aSX3[fr,3])		//busca o campo
		If ( Alltrim(SX3->X3_TITULO) <> Alltrim(cTit) ) .or. ( Alltrim(SX3->X3_DESCRIC) <> Alltrim(cDesc) )	//verifica se houve alteração no Título do campo
			cCpo := SX3->X3_CAMPO
					
			RecLock("SX3",.F.)
			SX3->X3_TITULO    := cTit
			SX3->X3_TITSPA    := cTit
			SX3->X3_TITENG    := cTit
			
			SX3->X3_DESCRIC   := cDesc
			SX3->X3_DESCSPA   := cDesc
			SX3->X3_DESCENG   := cDesc		
			MsUnLock()					
			
			If Ascan(aAlterTb, cTab) == 0
				aAdd(aAlterTb,cTab) 
			Endif
			
			If Ascan(aArqUpd,cTab) == 0
				aAdd(aArqUpd,cTab)
			Endif
					
			If !(cCpo $ cCpoAlter)
				cCpoAlter  += cCpo + "/"  //Log do campo alterado para exibir no final //FR - 10/03/2020
			Endif
			
			If !(cTab $ cAliaAlter)
				cAliaAlter  += cTab + "/"  //Log da tabela alterada para exibir no final //FR - 18/08/2020
			Endif
						                                                                                    
		EndIf
		
	Else  //campo novo
		//atualiza arrays e strings referência de alteração/criação de campo ou tabela para exibir no final
		If Ascan(aAlterTb, cTab) == 0
			aAdd(aAlterTb,cTab) 
		Endif
				
		If Ascan(aArqUpd,cTab) == 0
			aAdd(aArqUpd,cTab)
		Endif
				
		If !(cCpo $ cCpoAlter)
			cCpoAlter  += cCpo + "/"
		Endif
		
		If !(cTab $ cAliaAlter)
			cAliaAlter  += cTab + "/"  //Log da tabela alterada para exibir no final //FR - 18/08/2020
		Endif
		//atualiza arrays e strings referência de alteração/criação de campo ou tabela para exibir no final		
	Endif
	
Next

Return				
//---------------------------------------------------------------------------------------------------//
//FR - 30/08/2021 - realiza a alteração no campo: X3_PICTURE
//---------------------------------------------------------------------------------------------------//
*******************************************************************
User Function fAlterPic(aSX3,aAlterTb,aArqUpd,cAliaAlter,cCpoAlter)
*******************************************************************
Local cPic  := ""
Local fr    := 0
Local cCpo  := ""
Local cTab  := ""

dbSelectArea("SX3")
SX3->(dbSetOrder(2))   //X3_CAMPO 

cPic := ""

ASORT( aSX3, , , { | x,y | x[3] < y[3] } )   //ordena por nome de campo
		
For fr := 1 to Len(aSX3)
	cPic := aSX3[fr,13]
	cTab := aSX3[fr,1] 
	
	If dbSeek(aSX3[fr,3])		//busca o campo
		If Alltrim(SX3->X3_PICTURE) <> Alltrim(cPic) 	//verifica se houve alteração no Combo Box
			cCpo := SX3->X3_CAMPO
					
			RecLock("SX3",.F.)
			SX3->X3_PICTURE := cPic			
			MsUnLock()					
			
			If Ascan(aAlterTb, cTab) == 0
				aAdd(aAlterTb,cTab) 
			Endif
			
			If Ascan(aArqUpd,cTab) == 0
				aAdd(aArqUpd,cTab)
			Endif
					
			If !(cCpo $ cCpoAlter)
				cCpoAlter  += cCpo + "/"  //Log do campo alterado para exibir no final //FR - 10/03/2020
			Endif
			
			If !(cTab $ cAliaAlter)
				cAliaAlter  += cTab + "/"  //Log da tabela alterada para exibir no final //FR - 18/08/2020
			Endif
						                                                                                    
		EndIf
		
	Else  //campo novo
		//atualiza arrays e strings referência de alteração/criação de campo ou tabela para exibir no final
		If Ascan(aAlterTb, cTab) == 0
			aAdd(aAlterTb,cTab) 
		Endif
				
		If Ascan(aArqUpd,cTab) == 0
			aAdd(aArqUpd,cTab)
		Endif
				
		If !(cCpo $ cCpoAlter)
			cCpoAlter  += cCpo + "/"
		Endif
		
		If !(cTab $ cAliaAlter)
			cAliaAlter  += cTab + "/"  //Log da tabela alterada para exibir no final //FR - 18/08/2020
		Endif
		//atualiza arrays e strings referência de alteração/criação de campo ou tabela para exibir no final		
	Endif
	
Next

Return		
