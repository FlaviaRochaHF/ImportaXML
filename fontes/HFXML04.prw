#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "RPTDEF.CH"  
#INCLUDE "TBICONN.CH"  
#INCLUDE "AP5MAIL.CH"

Static __nHdlSMTP := 0
Static lUnix  := IsSrvUnix()
Static cBarra := Iif(lUnix,"/","\")

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³           ³ Autor ³Roberto Souza        ³ Data ³27/06/2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//--------------------------------------------------------------------------//
//FR 19/05/2020 - Alterações realizadas para incluir novo campo para o
//novo parâmetro XM_USADVG - ativa ou desativa a verificação de divergências
//entre XML x NF
//--------------------------------------------------------------------------//
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
//--------------------------------------------------------------------------//
// FR - 16/07/2020 - Alterações realizadas:
// Adequação da performance do download, na execução do Job Aguas do Brasil
// Inclusão do parâmetro XM_ITSLEEP
//--------------------------------------------------------------------------//
// FR - 12/11/2020 - Adequar o retorno da pesquisa padrão SA1PRN para trazer
//                   no campo "código" o código do cliente/fornecedor
//                   pois estava trazendo apenas a loja
//--------------------------------------------------------------------------//
//NA - 02/03/2021 - Projeto Nordson - criação de parâmetro para tela F12 
//                  XM_CENTRO - este parâmetro será utilizado pela rotina
//                  Múltiplos CTE - rege se a rotina buscará o centro de custo
//                  da NF Saída (SD2) Ou do cadastro de produto (SB1).
//--------------------------------------------------------------------------//
//FR - 08/03/2021 - Ajuste estético de linhas e caixas e posição do logotipo
//                  da HF 
//--------------------------------------------------------------------------//
//FR - 28/04/2021 - NOVA TELA GESTÃO XML - Solicitações feitas na reunião
//                  de apresentação para: Diretor Rafael e Coordenador Rogerio
//                  Criação de parâmetro para reger se traz os dados da 
//                  última compra 
//--------------------------------------------------------------------------//
//FR - 28/10/2021 - Implementação cadastro fornecedor (SA2) automatizado (Daikin)
//                  Parâmetro: "XM_SA2AUTO" Tipo Caracter, conteúdo : S-Sim; N=Não
/*
//Escopo passado por Rafael Lobitsky - 28/10/2021:
Criar um parâmetro chamado : Fornecedor auto S=sim;N=não - "XM_SA2AUTO"
-> Help “ Informa se ao baixar o xml e não encontrar o fornecedor cadastrado , 
   efetua o cadastro do mesmo de forma robótica “
   
-> Incluir este parâmetro em nossa aba de cadastros gerais ou gerais2

-> Incluir este parâmetro no programa de instalador do GESTÃO XML para ao rodar 
   o compatibilizador será criado Robótica 
   
-> Utilizar nosso ponto de entrada do gestão XML para colocar a regra de criação 
   de código do fornecedor padrão Daikin no momento de ser criado de forma robotica
   (se usa montagem de de A2_COD modelo Daikin ou padrão SXENUM )
*/
//------------------------------------------------------------------------------//
//FR - 21/12/2021 - Revisão dos parâmetros de automatização do cadastro de 
//                  fornecedor:
//                  - XM_SA2AUTO - cadastra fornecedor na classif. nf
//                  - XM_SA2AUTD - cadastra fornecedor no download xml
//--------------------------------------------------------------------------------//
//FR - 20/04/2022 - #12482 - JOHNSON - Alteração aumentar campo série nfs
//--------------------------------------------------------------------------------//
//FR - 21/06/2022 - BRASMOLDE - Validações para valores de XML x PEDIDO COMPRA
//     Mudança no parâmetro "Trava Pré nota" (XM_PED_GBR) para acrescentar mais uma opção:
//     E-Especifico -> validação via pto entrada HFXMLVLPED
//     Ficando as opções assim: S-Sim;N-Não;P-Pergunta;E-Específico
//--------------------------------------------------------------------------------//
//FR - 05/08/2022 - PROJETO POLITEC CLASSIFICAÇÃO NFs COMBUSTÍVEIS
//-----------------------------------------------------------------------------------//
//FR - 26/08/2022 - HFCONSULT - Foi adicionado o parametro XM_BXRESUM
//     para definir se baixa ou não XML Resumido
//--------------------------------------------------------------------------------//
//FR - 05/10/2022 - HFCONSULT - Foi adicionado o parametro XM_BXCTETM
//     para definir se baixa apenas CTE onde ocliente é Tomador
//--------------------------------------------------------------------------------//
//FR - 14/11/2022 - PROJETO COPAG VALIDAÇÃO SEFAZ AMAZONAS
//--------------------------------------------------------------------------------//
User Function HFXML04()  

Local oDlg
Local nX			:= 0
//Local aHead1		:= {}
//Local aHead2		:= {}
//Local aParams		:= {}
//Local nstyle		:= GD_UPDATE
//Local cFileCfg		:= "hfcfgxml001a.xml"
//Local cStyle  := "Q3Frame{ border-style:solid }"
Local aParJob		:= {}
//Local nLin			:= 0
//Local nCol			:= 0
//Local i				:= 0
//Local j				:= 0
//Local y				:= 1
//Local aX			:= {}
//Local cCoord 		:= "040,003,005,027,047,045,026,350,568"
//Local oSay1
Local oProcess		:= Nil
Local lDebugKey		:= AllTrim(GetSrvProfString("HF_DEBUGKEY","0"))=="1"
Local lMailAdv		:= .T. // AllTrim(GetSrvProfString("HF_ENABLEIMAP","0"))=="1"
Local cURL			:= "" 
Local cVerTSS		:= "" 
Local cIdEnt		:= ""
Local nTamProd		:= TAMSX3("B1_COD")[1]
Local cCloud	    := GetNewPar("XM_CLOUD" ,"0")         //aCombo (0=Desbilitado 1=Habilitado)

Private oXml
Private oGet1
Private aCols1		:= {}                             
Private aCols2		:= {}                             
Private VISUAL		:= .F.
Private INCLUI		:= .F.
Private ALTERA		:= .F.
Private DELETA		:= .F.

Private aPages		:= {"Configurações Job",;
						"E-mail/SMTP",;
						"E-mail/POP",;
						"Notificações",;
						"Gerais",;
						"Gerais(2)",;
						"CTe",;
						"Fiscais",;										//FR - 14/11/2022 - PROJETO COPAG VALIDAÇÃO SEFAZ AMAZONAS
						"Integração Externa",;
						"Classificação Robótica",;						//FR - 19/06/2020 - TÓPICOS RAFAEL
						"NF Serviço",;
						"Integração Conector Sefaz",;
						"Ferramentas",;
						"Avançado",;
						"Info"}
Private aPages2		:= {}
Private oFont01		:= TFont():New("Arial",07,14,,.T.,,,,.T.,.F.)
Private oFont02		:= TFont():New("Lucida Console",07,14,,.T.,,,,.T.,.F.)
Private oFont03		:= TFont():New("Courier",07,14,,.T.,,,,.T.,.F.) 

Private nPageCfg	:= aScan(aPages,{|x| x == "Configurações Job"})
Private nPageSMTP	:= aScan(aPages,{|x| x == "E-mail/SMTP"})
Private nPagePOP	:= aScan(aPages,{|x| x == "E-mail/POP"})
Private nPageNot	:= aScan(aPages,{|x| x == "Notificações"})
Private nPageGer	:= aScan(aPages,{|x| x == "Gerais"})
Private nPageGerII	:= aScan(aPages,{|x| x == "Gerais(2)"})
Private nPageCte	:= aScan(aPages,{|x| x == "CTe"})
Private nPageCfop	:= aScan(aPages,{|x| x == "CFOP"})
Private nPageInExt	:= aScan(aPages,{|x| x == "Integração Externa"})
Private nPageClAut  := aScan(aPages,{|x| x == "Classificação Robótica"})    //FR - 19/06/2020 - TÓPICOS RAFAEL
Private nPageNfs	:= aScan(aPages,{|x| x == "NF Serviço"})
Private nPageNuvem	:= aScan(aPages,{|x| x == "Integração Conector Sefaz"})
Private nPageTool	:= aScan(aPages,{|x| x == "Ferramentas"})
Private nPageAdv	:= aScan(aPages,{|x| x == "Avançado"})
Private nPageInfo	:= aScan(aPages,{|x| x == "Info"})
Private nPageFisc	:= aScan(aPages,{|x| x == "Fiscais"})	//FR - 14/11/2022 - PROJETO COPAG VALIDAÇÃO SEFAZ AMAZONAS

Private cENABLE,cNSU,cENT,nWFDELAY,cTHREADID,cJOBS,nSLEEP,cCONSOLE,cEmpBlq
Private oENABLE,oNSU,oENT,oWFDELAY,oTHREADID,oJOBS,oSLEEP,oCONSOLE,oEmpBlq
Private aCombo		:= {}
Private aCombo1		:= {}
Private aCombo2		:= {}
Private aCombo3		:= {}
Private aCombo4		:= {}
Private aCombo5		:= {}
Private aCombo6		:= {}   
Private aCombo7		:= {}
Private aCombo8 	:= {}
Private aCombo9		:= {}
Private aCombo10	:= {}
Private aCombo11	:= {}
Private aCombo02	:= {}
Private aCombo12	:= {}
Private aCombo13	:= {}
Private aCombo14	:= {}
Private aCombo15	:= {}
Private aCombo16	:= {}
Private aCombo17    := {}
Private aCombo18    := {}
Private aCombo19    := {}
Private aCombo20    := {}
Private aCombo21    := {}
Private aCombo22    := {}
Private aCombo23    := {}
Private aCombo24    := {}
Private aCombo25    := {}	//FR - 26/11/19 - foi necessário criar um novo combo, porque o Combo2 era usado por mais de uma opção
Private aCombo26	:= {}	//FR 19/05/2020 - combo para opções de divergência xml x nf -> usa sim / não
Private aCombo27	:= {}	//FR 22/09/2020 - combo para opções de tipos de notas para classificação Robótica
Private aCombo28    := {}   //NA 02/03/2021 - Combo tipo centro de custo
Private aCombo29    := {}   //FR - 21/06/2022 - Combo de opções para o "trava pré-nota"
Private aCombo30    := {}   //HMS - 26/07/2022 - Combo de opções para consultar notas do dia"
Private aInfo 		:= U_GetverIX()
Private aFilsEmp 	:= {} 
Private xZBZ		:= GetNewPar("XM_TABXML","ZBZ")
Private xZBT		:= GetNewPar("XM_TABITEM","ZBT")   //FR - 11/11/19
Private xZB5		:= GetNewPar("XM_TABAMAR","ZB5")
Private xZBS		:= GetNewPar("XM_TABSINC","ZBS")
Private xZBE        := GetNewPar("XM_TABEVEN","ZBE")
Private xZBA  	    := GetNewPar("XM_TABAMA2","ZBA")
Private xZBC        := GetNewPar("XM_TABCAC","ZBC")
Private xZBO        := GetNewPar("XM_TABOCOR","ZBO") 
Private xZBI        := GetNewPar("XM_TABIEXT","ZBI")
Private xRetSEF     := ""
Private xZBZ_		:= iif(Substr(xZBZ,1,1)=="S", Substr(xZBZ,2,2), Substr(xZBZ,1,3)) + "_"
Private xZBT_		:= iif(Substr(xZBT,1,1)=="S", Substr(xZBT,2,2), Substr(xZBT,1,3)) + "_"  //FR - 11/11/19
Private xZB5_		:= iif(Substr(xZB5,1,1)=="S", Substr(xZB5,2,2), Substr(xZB5,1,3)) + "_"
Private xZBS_		:= iif(Substr(xZBS,1,1)=="S", Substr(xZBS,2,2), Substr(xZBS,1,3)) + "_"
Private xZBE_       := iif(Substr(xZBE,1,1)=="S", Substr(xZBE,2,2), Substr(xZBE,1,3)) + "_"
Private xZBA_     	:= iif(Substr(xZBA,1,1)=="S", Substr(xZBA,2,2), Substr(xZBA,1,3)) + "_"
Private xZBC_       := iif(Substr(xZBC,1,1)=="S", Substr(xZBC,2,2), Substr(xZBC,1,3)) + "_"
Private xZBO_       := iif(Substr(xZBO,1,1)=="S", Substr(xZBO,2,2), Substr(xZBO,1,3)) + "_"
Private xZBI_       := iif(Substr(xZBI,1,1)=="S", Substr(xZBI,2,2), Substr(xZBI,1,3)) + "_"
Private aHfCloud    := {"0","0"," ","Token",{}}  //CRAUMDE - '0' Não integrar, na posição 1
Private cTpRt  	    := "M"

RstMvBuff()  //Limpar o buffer por causa de quando vir pelo F12 pela segunda vez, só para evitar a fadiga.


aAdd( aCombo, "0=Desabilitado" )
aAdd( aCombo, "1=Habilitado" )

aAdd( aCombo1, "N=Não" )
aAdd( aCombo1, "S=Sim" )

aAdd( aCombo2, "S=Sim" )		
aAdd( aCombo2, "N=Não" )
                        
aAdd( aCombo3, "0=Doc Original" )
aAdd( aCombo3, "6=6 Dígitos"    )             
aAdd( aCombo3, "9=9 Dígitos"    )
 
aAdd( aCombo4, "0=Sempre Perguntar")
aAdd( aCombo4, "1=Padrão(SA5/SA7)" )
aAdd( aCombo4, "2=Customizada("+AllTrim(GetNewPar("XM_TABAMAR","ZB5"))+")")
aAdd( aCombo4, "3=Sem Amarração"   )
aAdd( aCombo4, "4=Por Pedido"      )
aAdd( aCombo4, "5=Virtual"         )    //nordsonAmarra
aAdd( aCombo4, "6=Prod. Inteligente" )  //RL - Produto inteligente 18/07/2020

aAdd( aCombo5, "0=Não Utiliza"  )
aAdd( aCombo5, "1=SMTP"         )             
aAdd( aCombo5, "2=IMAP"         )

aAdd( aCombo6, "0=Não Utiliza"  )
aAdd( aCombo6, "1=POP"         )             
aAdd( aCombo6, "2=IMAP"         )

/* //FR 08/06/2020 - Classificação de NF direto, tratativa para esta opção, sem geração de pré-nota 
aAdd( aCombo7, "0=Nenhuma ação")
aAdd( aCombo7, "1=Classificar NF")
aAdd( aCombo7, "2=Sempre Perguntar")                                                                                                                                                                                                
*/

//FR 08/06/2020 - "tarefa: gera nota fiscal direto"
aAdd( aCombo7, "0=Pré-Nota Somente"          )
aAdd( aCombo7, "1=Gera Pré-Nota e Classifica")
aAdd( aCombo7, "2=Sempre Perguntar"          ) 
aAdd( aCombo7, "3=Gera Docto.Entrada Direto" )     

aAdd( aCombo8, "1=Pré-Nota")
aAdd( aCombo8, "2=Rec Carga")                                                                                                                                                                                                
aAdd( aCombo8, "3=Pré-Nota + Rec Carga") 
aAdd( aCombo8, "4=Pré-Nota + Nt C.Frete") 
aAdd( aCombo8, "5=Rec Carga+ Nt C.Frete") 
aAdd( aCombo8, "6=Todos") 


aAdd( aCombo9, "S=Sim" )
aAdd( aCombo9, "N=Não" )
aAdd( aCombo9, "0=Remetente" )
aAdd( aCombo9, "1=Expedidor" )
aAdd( aCombo9, "2=Recebedor" )
aAdd( aCombo9, "3=Destinatario" )

aAdd( aCombo10, "S=Pedido Compra" )
aAdd( aCombo10, "N=Cad. Produto" )
aAdd( aCombo10, "A=Ambos" )
aAdd( aCombo10, "Z=Sem C.Custo" )

aAdd( aCombo11, "S=Sim      " )
aAdd( aCombo11, "N=Não      " )
aAdd( aCombo11, "P=Perguntar" )

aAdd( aCombo12, "0=TSS Protheus" )
aAdd( aCombo12, "1=TSS Imp XML" )
aAdd( aCombo12, "2=Imp XML    " )

aAdd( aCombo02, "0=TSS Imp XML" )
aAdd( aCombo02, "1=Imp XML    " )

aAdd( aCombo13, "S=Sim" )
aAdd( aCombo13, "N=Não" )
aAdd( aCombo13, "Z=Zerar" )
aAdd( aCombo13, "P=Preenche" )

aAdd( aCombo14, "1=Pré-Nota" )
aAdd( aCombo14, "2=Documento de Entrada" )

aAdd( aCombo15, "N=Não Manifestar" )
aAdd( aCombo15, "1=Confirmação da Operação (Pré-NF)" )
aAdd( aCombo15, "2=Ciência da Operação (Pré-NF)" ) 
aAdd( aCombo15, "3=Confirmação Operação (Classif.)" ) //FR - 19/06/2020 - ATIVAR QUANDO A TRATATIVA ESTIVER PRONTA

aAdd( aCombo16, "0=Serie Original" )
aAdd( aCombo16, "2=2 Dígitos" )
aAdd( aCombo16, "3=3 Dígitos" )

aAdd( aCombo17, "1=Apenas browse NFe" )
aAdd( aCombo17, "2=Browse NFe e CCe " )
aAdd( aCombo17, "3=Browse NFe,CCe e Itens XML " )

aAdd( aCombo18, "G=Gestao Cloud" )

aAdd( aCombo19, "1=FTP" )
aAdd( aCombo19, "2=SFTP (SSH)" )

aAdd( aCombo20, "1=Concorrentes" )
aAdd( aCombo20, "2=Fila" )

aAdd( aCombo21, "1=Fornecedor" )
aAdd( aCombo21, "2=Da Pasta" )
aAdd( aCombo21, "3=Ambos" )

aAdd( aCombo22, "1=Saldo Pedido")
aAdd( aCombo22, "2=XML")
aAdd( aCombo22, "3=Sempre Perguntar")
aAdd( aCombo22, "4=Saldo por item pedido")

aAdd( aCombo23, "1=Doc.Entrada (ExecAuto)")
aAdd( aCombo23, "2=Pré-Nota")
aAdd( aCombo23, "3=Sempre Perguntar")

aAdd( aCombo24, "S=Utiliza Image Converter" )
aAdd( aCombo24, "N=Não Utiliza" )

//==============================================//
//FR - 26/11/19 - novas opções, projeto Politec 
//Referente à classificação Robótica
//==============================================//
aAdd( aCombo25, "1=Pergunta Múltiplos"  )		
aAdd( aCombo25, "2=Múltiplos NFE e CTE" )
aAdd( aCombo25, "3=Automat. NFE/CTE"    )
aAdd( aCombo25, "4=TES Cad.Produto"     )
aAdd( aCombo25, "5=Não Utilizado"       )
//FR - 26/11/19

aAdd( aCombo26, "N=Não" )  //FR 19/05/2020 - opções para o parâmetro se usa conferência de divergência de NF x XML Sim/Não
aAdd( aCombo26, "S=Sim" )
	
//==============================================//
//FR - 22/09/2020 - Tipos de NF
//Referente à classificação Robótica
//==============================================//
aAdd( aCombo27, "C= NF Combustíveis + Audit Terc"  )
aAdd( aCombo27, "C1= NF Combustível")		
aAdd( aCombo27, "E= NF Energia" )
aAdd( aCombo27, "T= Todos"    )
aAdd( aCombo27, "N= Nenhum"   )

//NA - 02/03/2021
aAdd( aCombo28, "1= Padrão Totvs"  )		
aAdd( aCombo28, "2= Cadastro do Produto" ) 

aAdd( aCombo29, "S=Sim      " )
aAdd( aCombo29, "N=Não      " )
aAdd( aCombo29, "P=Perguntar" )
aAdd( aCombo29, "E=Especifico")
//NA - 02/03/2021
//FR - 22/09/2020
aAdd( aCombo30, "0=Nenhuma")
aAdd( aCombo30, "1=Uma vez")
aAdd( aCombo30, "2=Duas vezes")
aAdd( aCombo30, "3=Três vezes")
aAdd( aCombo30, "4=Quatro vezes")
//HMS 26/07/2022
	If lDebugKey
		PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" MODULO "FAT" TABLES "SF1","SF2","SD1","SD2","SF4","SB5","SF3","SB1"
		RpcSetType(3)
	EndIf
	
	//aFilsEmp := U_XGetFilS(SM0->M0_CGC)
	//lUsoOk    := U_HFXML00X("HF000001","101",SM0->M0_CGC)
	lUsoOk    := U_HFXMLLIC(.F.)

	if GetNewPar("XM_DFE","0") $ "0,1"

		if cCloud <> "1"
		
			cIdEnt := U_GetIdEnt()

			cURL   := PadR(GetNewPar("XM_URL",""),250)

			If Empty(cURL)

				cURL := PadR(GetNewPar("MV_SPEDURL","http://"),250)

			EndIf

		else

			cIdEnt := ""
			cUrl := ""
			
		endif

	else
		
		cUrl := ""
		
	endif

	U_VerTSS(cUrl,@cVerTSS,.T.)

	If !lUsoOk
		Return(.T.)
	EndIf
	
	RetSqlCond("SA2")

	FWMsgRun(, {|| CursorWait(),oXml:=U_LoadCfgX(1,,),Sleep(1000),CursorArrow() }, "Aguarde", "Carregando definições...")

	DEFINE MSDIALOG oDlg TITLE "Configurações Gestão XML" FROM 000,000 TO 530,800 PIXEL STYLE DS_MODALFRAME STATUS       //FR 19/05/2020

	aPages2	:=	Aclone(aPages)	

	oPage := TFolder():New(002,002,aPages2,{},oDlg,,,,.T.,.F.,350,257,)     //FR 19/05/2020   //350=largura,257=altura
	
	ShowLogo(aPages)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Definicoes Job                                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	aDefs  := {}

	aParJob := GetJobInfo(1)      

	If oXml == Nil
		Return	
	Endif

	cENABLE  := PadR(oXml:_MAIN:_WFXML01:_ENABLE:_XTEXT:TEXT,25)
	cENT     := PadR(oXml:_MAIN:_WFXML01:_ENT:_XTEXT:TEXT,25)
	nWFDELAY := Val(oXml:_MAIN:_WFXML01:_WFDELAY:_XTEXT:TEXT)
	cTHREADID:= PadR(oXml:_MAIN:_WFXML01:_THREADID:_XTEXT:TEXT,25)
	nSLEEP   := Val(oXml:_MAIN:_WFXML01:_SLEEP:_XTEXT:TEXT)
	cConsole := PadR(oXml:_MAIN:_WFXML01:_CONSOLE:_XTEXT:TEXT,25)

	If Type("oXml:_MAIN:_WFXML01:_JOBS:_JOB") == "U"
		aJobs    := {}
    ElseIf ValType(oXml:_MAIN:_WFXML01:_JOBS:_JOB)=="A"
		aJobs    := oXml:_MAIN:_WFXML01:_JOBS:_JOB    
	Else
		aJobs    := {oXml:_MAIN:_WFXML01:_JOBS:_JOB}	
	EndIf

	cJOBS    := ""
	For Nx:=1 To Len(aJobs)
		cJOBS    += aJobs[Nx]:_XTEXT:TEXT
		If Nx < Len(aJobs)
			cJOBS    += ","
		EndIf				
	Next	
	cJOBS    := PadR(cJOBS,25)

	nDiasRet   := Val(GetNewPar("XM_D_CANCEL","3"))
	cHrCons    := GetNewPar("XM_HR_CONS","22:00")
	cXmTpJobCx := GetNewPar("XM_TPJOBCX","1")
	cNSUzero   := GetNewPar("XM_NSUZERO","N")
	cEmpBlq    := GetNewPar("XM_EMPBLQ","")
	cReqSefaz  := strzero(GetNewPar("XM_NREQSEF", 5  ),2)
	cCnpjSefaz := strzero(GetNewPar("XM_NCNPJSE", 5 ),2)
	cHoraSefaz := strzero(GetNewPar("XM_NHRSEF", 60  ),2)

/*
	cReqSefaz  := strzero(cValtoChar(GetNewPar("XM_NREQSEF", 5  )),2)
	cCnpjSefaz := strzero(cValtoChar(GetNewPar("XM_NCNPJSE", 5 )),2)
	cHoraSefaz := strzero(cValtoChar(GetNewPar("XM_NHRSEF", 60  )),2)
*/	
	if Empty( cEmpBlq )

		cEmpBlq := Space(40)

	endif
	
	Aadd(aDefs,{"ENABLE"  ,cENABLE   		,"Serviço Habilitado" 					}) 
	Aadd(aDefs,{"ENT"     ,cENT  			,"Empresa/Filial principal do processo" }) 
	Aadd(aDefs,{"WFDELAY" ,nWFDELAY    		,"Atraso apos a primeira execucao"   	}) 
	Aadd(aDefs,{"THREADID",cTHREADID   		,"Identificador de Thread [Debug]"   	}) 
	Aadd(aDefs,{"JOBS"    ,cJOBS   			,"Serviço a ser processado" 			}) 
	Aadd(aDefs,{"SLEEP"   ,nSLEEP    		,"Tempo de espera"   					}) 
	Aadd(aDefs,{"CONSOLE" ,cConsole   		,"Informacoes dos processos no console" }) 
	
	nPosG1    := 000.50
	nPosG2    := 002.50
	nPosInc   := 002.125
	//@ 015,00.1 To 015.1,043.8 OF oPage:aDialogs[nPageCfg]   //FR 19/05/2020 - linha antes do telefone  FR - 08/03/2021 - retirada porque estava sobrepondo o logotipo
	/*** Linha 1 ***/
	@ nPosG1,00.5 to nPosG2,020 OF oPage:aDialogs[nPageCfg]    
	@ 010  ,010 Say oXml:_MAIN:_WFXML01:_ENABLE:_XDESC:TEXT  PIXEL OF oPage:aDialogs[nPageCfg] COLOR CLR_BLUE FONT oFont01
	@ 018  ,010 COMBOBOX oEnable VAR cEnable ITEMS aCombo SIZE 55,08 PIXEL OF oPage:aDialogs[nPageCfg] 

	cTip := "Deixa ou não habilitado o serviço de agendamento"
	oEnable:cToolTip := cTip
	  
	@ 010  ,080 Say "NSU Zerado ?"  PIXEL OF oPage:aDialogs[nPageCfg] COLOR CLR_BLUE FONT oFont01
	@ 018  ,080 COMBOBOX oNSU VAR cNSUZero ITEMS aCombo1 SIZE 55,08 PIXEL OF oPage:aDialogs[nPageCfg]

	cTip := "Zera o Sequencial do Sefaz contido no parâmetro XM_NSUNFE e XM_NSUCTE"
	oNSU:cToolTip := cTip

	@ nPosG1,20.5 to nPosG2,040 OF oPage:aDialogs[nPageCfg]    
	@ 010  ,170 Say oXml:_MAIN:_WFXML01:_SLEEP:_XDESC:TEXT  PIXEL OF oPage:aDialogs[nPageCfg] COLOR CLR_BLUE FONT oFont01
	@ 018  ,170 MSGet oSleep VAR nSleep SIZE 55,08 PICTURE "999999" PIXEL OF oPage:aDialogs[nPageCfg]

	cTip := "Tempo de Espera de um job para outro em milisegundos"
	oSleep:cToolTip := cTip                   
	@ 010  ,240 Say "Conexões" PIXEL OF oPage:aDialogs[nPageCfg] COLOR CLR_BLUE FONT oFont01
	@ 018  ,240 COMBOBOX oTpCnx VAR cXmTpJobCx ITEMS aCombo20 SIZE 60,08 PIXEL OF oPage:aDialogs[nPageCfg]               

   	cTip := "1-Concorrentes. No momento da execução do JOB, será aberto uma conexão" +CRLF
	cTip += "  para cada Empresa/Filial/Tarefa. "+CRLF
	cTip += "2-FILA. No momento da execução do JOB terá uma fila de execução das Tarefas,"+CRLF
	cTip += "  abrindo uma conexão por vez para cada empresa/Filial."+CRLF
	cTip += "  Isto fará com demore mais a execução das rotinas, mas utilizará menos"+CRLF
	cTip += "  recurso do servidor."
	oTpCnx:cToolTip := cTip


	/*** Linha 2 ***/
	nPosG1    += nPosInc
	nPosG2    += nPosInc

	@ nPosG1,00.5 to nPosG2,020 OF oPage:aDialogs[nPageCfg]    
	@ 040  ,010 Say oXml:_MAIN:_WFXML01:_ENT:_XDESC:TEXT  PIXEL OF oPage:aDialogs[nPageCfg] COLOR CLR_BLUE FONT oFont01
	@ 048  ,010 MSGet oEnt VAR cEnt F3 "EMP" SIZE 100,08 OF oPage:aDialogs[nPageCfg] F3 "SM0" PIXEL

	cTip :=" Informe ao sistema a empresa que deve ser a primeira da fila de execução."
	cTip +=" O sistema executa o Job em cada empresa de maneira sequencial."
	oEnt:cToolTip := cTip
	@ nPosG1,20.5 to nPosG2,040 OF oPage:aDialogs[nPageCfg]    
	@ 040  ,170 Say oXml:_MAIN:_WFXML01:_CONSOLE:_XDESC:TEXT  PIXEL OF oPage:aDialogs[nPageCfg] COLOR CLR_BLUE FONT oFont01
	@ 048  ,170 COMBOBOX oConsole VAR cConsole ITEMS aCombo SIZE 100,10 PIXEL OF oPage:aDialogs[nPageCfg] 
	cTip :=" Visualiza informações do JOB no Console do Protheus."
	oConsole:cToolTip := cTip

	/*** Linha 3 ***/              
	nPosG1    += nPosInc
	nPosG2    += nPosInc

	@ nPosG1,00.5 to nPosG2,020 OF oPage:aDialogs[nPageCfg]    
	@ 070  ,010 Say oXml:_MAIN:_WFXML01:_WFDELAY:_XDESC:TEXT  PIXEL OF oPage:aDialogs[nPageCfg] COLOR CLR_BLUE FONT oFont01
	@ 078  ,010 Get oWfdelay VAR nWfdelay SIZE 100,08  PICTURE "999999" PIXEL OF oPage:aDialogs[nPageCfg] 

	cTip :=" Após a inicialização do agendamento em quantos minutos irá rodar"
	oWfdelay:cToolTip := cTip                  
	@ nPosG1,20.5 to nPosG2,040 OF oPage:aDialogs[nPageCfg]    
	@ 070  ,170 Say "Serviços [Jobs]" PIXEL OF oPage:aDialogs[nPageCfg] COLOR CLR_BLUE FONT oFont01
	@ 078  ,170 Get oJobs VAR cJobs SIZE 100,08 PIXEL OF oPage:aDialogs[nPageCfg] READONLY                  
	@ 078  ,270 Button "..." Size 010,011 PIXEL OF oPage:aDialogs[nPageCfg] ACTION (cJobs:=U_GetJob(cJobs))
	cTip :=" JOB's sequenciais"
	oJobs:cToolTip := cTip
		
	/*** Linha 4 ***/
	nPosG1    += nPosInc
	nPosG2    += nPosInc

	@ nPosG1,00.5 to nPosG2,020 OF oPage:aDialogs[nPageCfg]    
	@ 100  ,010 Say "Identificador de Thread [Debug]"  PIXEL OF oPage:aDialogs[nPageCfg] COLOR CLR_BLUE FONT oFont01
	//@ 100  ,010 Say oXml:_MAIN:_WFXML01:_THREADID:_XDESC:TEXT  PIXEL OF oPage:aDialogs[nPageCfg] COLOR CLR_BLUE FONT oFont01
	@ 108  ,010 COMBOBOX oTHREADID VAR cTHREADID ITEMS aCombo SIZE 100,10 PIXEL OF oPage:aDialogs[nPageCfg] 
	cTip :="Gera log referente às baixas dos xmls da Sefaz e E-mail."
	oTHREADID:cToolTip := cTip
 
	@ nPosG1,20.5 to nPosG2,040 OF oPage:aDialogs[nPageCfg]    
	@ 100  ,170 Say "Dias Consulta " PIXEL OF oPage:aDialogs[nPageCfg] COLOR CLR_BLUE FONT oFont01
	@ 108  ,170 Get oDiasRet VAR nDiasRet SIZE 15,08  PICTURE "99" PIXEL OF oPage:aDialogs[nPageCfg] VALID  (nDiasRet >= 0 .And. nDiasRet <= 30)                 

	@ 100  ,230 Say "Hora Consulta" PIXEL OF oPage:aDialogs[nPageCfg] COLOR CLR_BLUE FONT oFont01
	@ 108  ,230 Get oHrCons VAR cHrCons SIZE 40,08  PICTURE "@E 99:99" PIXEL OF oPage:aDialogs[nPageCfg]               

   	cTip := "Informe quantos dias o sistema deve retroagir para consultar " +CRLF
	cTip += "xml, verificando se houve cancelamento posterior ao recebimento "+CRLF
	cTip += "e processamento do XML. "+CRLF
	cTip += "Efetua download completo de todos XML Resumo "+CRLF
	cTip += "O recomendado é 1 vez ao dia. "
	oDiasRet:cToolTip := cTip

   	cTip := "Hora programada de execução da consulta XML na SEFAZ."+CRLF
	cTip += "Preencher no formato HH:MM ."
	oHrCons:cToolTip := cTip

	//@ nPosG1,20.5 to nPosG2,040 OF oPage:aDialogs[nPageCfg]    

	/*** Linha 5 ***/
//	nPosG1    += nPosInc
//	nPosG2    += nPosInc

//	@ nPosG1,00.5 to nPosG2,020 OF oPage:aDialogs[nPageCfg]    
//	@ 130  ,010 Say "Serviços [Jobs]" PIXEL OF oPage:aDialogs[nPageCfg] COLOR CLR_BLUE FONT oFont01
//	@ 138  ,010 Get oJobs VAR cJobs SIZE 100,10 PIXEL OF oPage:aDialogs[nPageCfg]                   
	                 
	nPosG1    += nPosInc
	nPosG2    += nPosInc + 1

	@ nPosG1,00.5 to nPosG2,040 OF oPage:aDialogs[nPageCfg]  
                           	
	@ 185,270 Button "Confirma" Size 045,015 PIXEL OF oPage:aDialogs[nPageCfg] ACTION ;
		MsgRun("Salvando definições...",,{|| CursorWait(),SetDefs(cENABLE,cENT,nWFDELAY,cTHREADID,cJOBS,nSLEEP,cConsole,nDiasRet,cHrCons,cXmTpJobCx,cNSUZero,cEmpBlq,cHoraSefaz,cReqSefaz,cCnpjSefaz),Sleep(1000),CursorArrow()})

	@ 130,010 Say "Serv. Atual Logado. JOB ativará neste Serv." PIXEL OF oPage:aDialogs[nPageCfg] COLOR CLR_BLUE FONT oFont03
	@ 140,010 Say GetPvProfString("Service", "DIsplayName", GetPvProfString("Service", "Name", "----", GetAdv97()), GetAdv97()) PIXEL OF oPage:aDialogs[nPageCfg] COLOR CLR_RED FONT oFont02

	lOnJob := (aParJob[1][3]=="INATIVO") 
	oBtJob := TButton():New(150,010,Iif(lOnJob,"Ativar Job .ini","Desativar Job .ini"),oPage:aDialogs[nPageCfg],;
				{|| Iif(lOnJob,GetJobInfo(2),GetJobInfo(3) ),;
				aParJob:=GetJobInfo(1),;
				lOnJob := (aParJob[1][3]=="INATIVO") ,;
				oBtJob:CCAPTION:=Iif(lOnJob,"Ativar Job .ini","Desativar Job .ini") ,;
				oBtJob:Refresh()  },;
				70,15,,oFont01,.F.,.T.,.F.,,.F.,,,.F.)   

	@ nPosG1,20.5 to nPosG2,040 OF oPage:aDialogs[nPageCfg]    
	@ 130  ,170 Say "Cons. Chave" PIXEL OF oPage:aDialogs[nPageCfg] COLOR CLR_BLUE FONT oFont01
	@ 140  ,170 MSGet oTpChave VAR cReqSefaz SIZE 20,08 PICTURE "999999" PIXEL OF oPage:aDialogs[nPageCfg]                   

	@ 130  ,217 Say "Cons. CNPJ" PIXEL OF oPage:aDialogs[nPageCfg] COLOR CLR_BLUE FONT oFont01
	@ 140  ,217 MSGet oTpCNPJ VAR cCnpjSefaz SIZE 20,08 PICTURE "999999" PIXEL OF oPage:aDialogs[nPageCfg]              

	@ 130  ,260 Say "Tempo Requisição" PIXEL OF oPage:aDialogs[nPageCfg] COLOR CLR_BLUE FONT oFont01
	@ 140  ,260 MSGet oConsulta VAR cHoraSefaz SIZE 20,08 PICTURE "999999" PIXEL OF oPage:aDialogs[nPageCfg] 

 	cTip := "Quantidade de requisições por chave dentro do período informado no" +CRLF
	cTip += "  parâmetro minutos requisições. "+CRLF
	oTpChave:cToolTip := cTip

	cTip := "Quantidade de requisições por CNPJ dentro do período informado no" +CRLF
	cTip += "  parâmetro minutos requisições. "+CRLF
	oTpCNPJ:cToolTip := cTip

	cTip := "Informar em minutos o tempo de intervalo de requisições" +CRLF
	cTip += "  no sefaz. "+CRLF
	oConsulta:cToolTip := cTip
	/*** Linha 6 ***/	

	nPosG1    += nPosInc + 1
	nPosG2    += nPosInc + 1

	@ nPosG1,00.5 to nPosG2,040 OF oPage:aDialogs[nPageCfg]      

	@ 175 ,010 Say "Empresa/Filial que deseja bloquear ? Ex: 9901;9902"  PIXEL OF oPage:aDialogs[nPageCfg] COLOR CLR_BLUE FONT oFont01
	@ 185 ,010 MSGet oEmpBlq VAR cEmpBlq SIZE 100,08 Pixel OF oPage:aDialogs[nPageCfg]

	cTip := "Caso necessite bloquear alguma empresa para nao executar os jobs"
	oEmpBlq:cToolTip := cTip

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Configuracoes E-mail SMTP                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                                 
	oMailServer := Nil
	oLogin      := Nil
	oMailConta  := Nil
	oMailSenha  := Nil
	oSMTPAuth   := Nil
	oSSL        := Nil
	oTLS        := Nil   //aquuiiiiiii

	aSmtp       := U_XCfgMail(1,1,{})
	
	cMailServer := aSmtp[1] //Padr(GetNewPar("XM_SMTP",Space(40)),40)
	cLogin      := aSmtp[2] //Padr(GetNewPar("XM_LOGIN",Space(40)),40)
	cMailConta  := aSmtp[3] //Padr(GetNewPar("XM_ACCOUNT",Space(40)),40)
	cMailSenha  := aSmtp[4] //Padr(Decode64(GetNewPar("XM_PASS",Space(25))),25)
	lSMTPAuth   := aSmtp[5] //GetNewPar("XM_AUT",Space(1))=="S"
	lSSL        := aSmtp[6] //GetNewPar("XM_SSL",Space(1))=="S"                                     
	cProtocolE  := aSmtp[7] //GetNewPar("XM_PROTENV","0")
	cPortEnv    := aSmtp[8] //GetNewPar("XM_ENVPORT","0")
	lTLS        := aSmtp[9] //GetNewPar("XM_TLS",Space(1))=="S"                 //aquuiiiiii

	@ 015,00.1 To 015.1,043.8 OF oPage:aDialogs[nPageSMTP]   //FR 19/05/2020     
	
	If lMailAdv 

		@ 010,010 Say "Protocolo de Envio : "  PIXEL OF oPage:aDialogs[nPageSMTP] COLOR CLR_BLUE FONT oFont01
		@ 018,010 COMBOBOX  oProtocolE VAR cProtocolE ITEMS aCombo5 SIZE 150,10 PIXEL OF oPage:aDialogs[nPageSMTP]

//		@ 010,010 Say "Servidor SMTP : "  PIXEL OF oPage:aDialogs[nPageSMTP] COLOR CLR_BLUE FONT oFont01
//		@ 018,010 Get  oMailServer VAR cMailServer SIZE 150,08 PIXEL OF oPage:aDialogs[nPageSMTP]
	
		@ 035,010 Say "Servidor de Envio: "  PIXEL OF oPage:aDialogs[nPageSMTP] COLOR CLR_BLUE FONT oFont01                                             
		@ 043,010 Get  oMailServer VAR cMailServer SIZE 120,08 PIXEL OF oPage:aDialogs[nPageSMTP]

		@ 035,130 Say "Porta: "  PIXEL OF oPage:aDialogs[nPageSMTP] COLOR CLR_BLUE FONT oFont01
		@ 043,130 Get  oPortEnv VAR cPortEnv SIZE 30,08 PIXEL OF oPage:aDialogs[nPageSMTP]
	
		@ 060,010 Say "Login : "  PIXEL OF oPage:aDialogs[nPageSMTP] COLOR CLR_BLUE FONT oFont01
		@ 068,010 Get oLogin VAR cLogin SIZE 150,08 PIXEL OF oPage:aDialogs[nPageSMTP]             
	
		@ 085,010 Say "Conta de E-mail : "  PIXEL OF oPage:aDialogs[nPageSMTP] COLOR CLR_BLUE FONT oFont01
		@ 093,010 Get oMailConta VAR cMailConta SIZE 150,08 PIXEL OF oPage:aDialogs[nPageSMTP]                   
	
		@ 110,010 Say "Senha : "  PIXEL OF oPage:aDialogs[nPageSMTP] COLOR CLR_BLUE FONT oFont01
		@ 118,010 Get oMailSenha VAR cMailSenha SIZE 150,08 PIXEL OF oPage:aDialogs[nPageSMTP] PASSWORD
	
		@ 135,010 Say "Servidor Requer Autenticação : "  PIXEL OF oPage:aDialogs[nPageSMTP] COLOR CLR_BLUE FONT oFont01
		@ 134,140 CHECKBOX oSMTPAuth VAR lSMTPAuth PROMPT "" SIZE 65,8 PIXEL OF oPage:aDialogs[nPageSMTP]
	
		@ 145,010 Say "Usa Conexão Segura (SSL) : "  PIXEL OF oPage:aDialogs[nPageSMTP] COLOR CLR_BLUE FONT oFont01
		@ 144,140 CHECKBOX oSSL VAR lSSL PROMPT "" SIZE 65,8 PIXEL OF oPage:aDialogs[nPageSMTP]

		@ 155,010 Say "Usa Conexão Segura (TLS) : "  PIXEL OF oPage:aDialogs[nPageSMTP] COLOR CLR_BLUE FONT oFont01
		@ 154,140 CHECKBOX oTLS VAR lTLS PROMPT "" SIZE 65,8 PIXEL OF oPage:aDialogs[nPageSMTP]


	Else

		@ 010,010 Say "Servidor SMTP : "  PIXEL OF oPage:aDialogs[nPageSMTP] COLOR CLR_BLUE FONT oFont01
		@ 018,010 Get  oMailServer VAR cMailServer SIZE 150,08 PIXEL OF oPage:aDialogs[nPageSMTP]
	
		@ 040,010 Say "Login : "  PIXEL OF oPage:aDialogs[nPageSMTP] COLOR CLR_BLUE FONT oFont01
		@ 048,010 Get oLogin VAR cLogin SIZE 150,08 PIXEL OF oPage:aDialogs[nPageSMTP]             
	
		@ 070,010 Say "Conta de E-mail : "  PIXEL OF oPage:aDialogs[nPageSMTP] COLOR CLR_BLUE FONT oFont01
		@ 078,010 Get oMailConta VAR cMailConta SIZE 150,08 PIXEL OF oPage:aDialogs[nPageSMTP]                   
	
		@ 100,010 Say "Senha : "  PIXEL OF oPage:aDialogs[nPageSMTP] COLOR CLR_BLUE FONT oFont01
		@ 108,010 Get oMailSenha VAR cMailSenha SIZE 150,08 PIXEL OF oPage:aDialogs[nPageSMTP] PASSWORD
	
		@ 131,010 Say "Servidor Requer Autenticação : "  PIXEL OF oPage:aDialogs[nPageSMTP] COLOR CLR_BLUE FONT oFont01
		@ 130,140 CHECKBOX oSMTPAuth VAR lSMTPAuth PROMPT "" SIZE 65,8 PIXEL OF oPage:aDialogs[nPageSMTP]
	
		@ 144,010 Say "Usa Conexão Segura (SSL) : "  PIXEL OF oPage:aDialogs[nPageSMTP] COLOR CLR_BLUE FONT oFont01
		@ 144,140 CHECKBOX oSSL VAR lSSL PROMPT "" SIZE 65,8 PIXEL OF oPage:aDialogs[nPageSMTP]

		@ 155,010 Say "Usa Conexão Segura (TLS) : "  PIXEL OF oPage:aDialogs[nPageSMTP] COLOR CLR_BLUE FONT oFont01
		@ 154,140 CHECKBOX oTLS VAR lTLS PROMPT "" SIZE 65,8 PIXEL OF oPage:aDialogs[nPageSMTP]

	EndIf

	@ 190,240 Button "Valida E-mail" Size 050,015 PIXEL OF oPage:aDialogs[nPageSMTP] ACTION (TestMail(cMailServer,cLogin,cMailConta,cMailSenha,lSMTPAuth,lSSL,cProtocolE,cPortEnv))	     
	@ 190,300 Button "Salvar" Size 040,015 PIXEL OF oPage:aDialogs[nPageSMTP] ACTION (SetMail(1,2,cMailServer,cLogin,cMailConta,cMailSenha,lSMTPAuth,lSSL,cProtocolE,cPortEnv,lTLS))  //FR 19/05/2020
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Configuracoes E-mail POP                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                                 
	oServerPOP  := Nil
	oLoginPOP   := Nil
	oPOPConta   := Nil
	oPOPSenha   := Nil
	oPOPAuth    := Nil
	oPOPSSL     := Nil    
	oPOPTLS     := Nil

	aPop        := U_XCfgMail(2,1,{})
	aPopS		:= U_XCfgMail(3,1,{})

	cServerPOP  := aPop[1]   //Padr(GetNewPar("XM_POPIMAP",Space(40)),40)
	cLoginPOP   := aPop[2]   //""//Padr(GetNewPar("XM_LOGIN"  ,Space(40)),40)
	cPOPConta   := aPop[3]   //Padr(GetNewPar("XM_POPACC" ,Space(40)),40)
	cPOPPass    := aPop[4]   //Padr(Decode64(GetNewPar("XM_POPPASS",Space(25))),25)
	lPOPAuth    := aPop[5]   //GetNewPar("XM_POPAUT",Space(1))=="S"
	lPOPSSL     := aPop[6]   //GetNewPar("XM_POPSSL",Space(1))=="S"
	cProtocolR  := aPop[7]   //GetNewPar("XM_PROTREC","0")
	cPortRec    := aPop[8]   //GetNewPar("XM_RECPORT","0")
	cPOPSConta   := aPopS[3]   //Padr(GetNewPar("XM_POPACC" ,Space(40)),40)
	cPOPSPass    := aPopS[4]   //Padr(Decode64(GetNewPar("XM_POPPASS",Space(25))),25)

	if Len(aPop) >= 9
		lPOPTLS     := aPop[9] //GetNewPar("XM_RECPORT","0")
	Else
		lPOPTLS     := .F.
	Endif

	/* 
	AADD(aSx6,{"  ","XM_POPIMAP","C","Endereço POP/IMAP de Recebimento de XML Fornecedor"	,"","","","","","","","","","","","",""})
	AADD(aSx6,{"  ","XM_POPACC" ,"C","Conta de Email de Recebimento de XML Fornecedor."		,"","","","","","","","","","","","",""})
	AADD(aSx6,{"  ","XM_POPPASS","C","Senha da Conta de Recebimento de XML Fornecedor."		,"","","","","","","","","","","","",""})
	AADD(aSx6,{"  ","XM_POPAUT" ,"C","Informa se e-mail utiliza autenticação."				,"","","","","","","","","","","","",""})
	AADD(aSx6,{"  ","XM_POPSSL" ,"C","Informa se e-mail utiliza conexao segura."			,"","","","","","","","","","","","",""})
	*/
		
	@ 015,00.1 To 015.1,043.8 OF oPage:aDialogs[nPagePOP]	//FR 19/05/2020 
	
	If lMailAdv 
	
		@ 010,010 Say "Protocolo de Recebimento : "  PIXEL OF oPage:aDialogs[nPagePOP] COLOR CLR_BLUE FONT oFont01
		@ 018,010 COMBOBOX  oProtocolR VAR cProtocolR ITEMS aCombo6 SIZE 150,10 PIXEL OF oPage:aDialogs[nPagePOP]

		@ 035,010 Say "Servidor de Recebimento  : "  PIXEL OF oPage:aDialogs[nPagePOP] COLOR CLR_BLUE FONT oFont01
		@ 043,010 Get oServerPOP VAR cServerPOP SIZE 120,08 PIXEL OF oPage:aDialogs[nPagePOP]

		@ 035,130 Say "Porta: "  PIXEL OF oPage:aDialogs[nPagePOP] COLOR CLR_BLUE FONT oFont01
		@ 043,130 Get  oPortRec VAR cPortRec SIZE 30,08 PIXEL OF oPage:aDialogs[nPagePOP] 
/*			
		@ 060,010 Say "Login : "  PIXEL OF oPage:aDialogs[nPagePOP] COLOR CLR_BLUE FONT oFont01
		@ 068,010 Get oLoginPOP VAR cLoginPOP SIZE 150,08 PIXEL OF oPage:aDialogs[nPagePOP]                  
	
		@ 085,010 Say "Conta de E-mail : "  PIXEL OF oPage:aDialogs[nPagePOP] COLOR CLR_BLUE FONT oFont01
		@ 093,010 Get oPOPConta VAR cPOPConta SIZE 150,08 PIXEL OF oPage:aDialogs[nPagePOP]                   
	
		@ 110,010 Say "Senha : "  PIXEL OF oPage:aDialogs[nPagePOP] COLOR CLR_BLUE FONT oFont01
		@ 118,010 Get oPOPPass VAR cPOPPass SIZE 150,08 PIXEL OF oPage:aDialogs[nPagePOP] PASSWORD
	
		@ 135,010 Say "Servidor Requer Autenticação : "  PIXEL OF oPage:aDialogs[nPagePOP] COLOR CLR_BLUE FONT oFont01
		@ 134,140 CHECKBOX oPOPAuth VAR lPOPAuth PROMPT "" SIZE 65,8 PIXEL OF oPage:aDialogs[nPagePOP]
	
		@ 150,010 Say "Usa Conexão Segura (SSL) : "  PIXEL OF oPage:aDialogs[nPagePOP] COLOR CLR_BLUE FONT oFont01
		@ 149,140 CHECKBOX oPOPSSL VAR lPOPSSL PROMPT "" SIZE 65,8 PIXEL OF oPage:aDialogs[nPagePOP]
 */
 
		@ 060,010 Say "Login / Conta de E-mail : "  PIXEL OF oPage:aDialogs[nPagePOP] COLOR CLR_BLUE FONT oFont01
		@ 068,010 Get oPOPConta VAR cPOPConta SIZE 150,08 PIXEL OF oPage:aDialogs[nPagePOP]                   
	
		@ 085,010 Say "Senha : "  PIXEL OF oPage:aDialogs[nPagePOP] COLOR CLR_BLUE FONT oFont01
		@ 093,010 Get oPOPPass VAR cPOPPass SIZE 150,08 PIXEL OF oPage:aDialogs[nPagePOP] PASSWORD
	
		@ 110,010 Say "Servidor Requer Autenticação : "  PIXEL OF oPage:aDialogs[nPagePOP] COLOR CLR_BLUE FONT oFont01
		@ 109,140 CHECKBOX oPOPAuth VAR lPOPAuth PROMPT "" SIZE 65,8 PIXEL OF oPage:aDialogs[nPagePOP]
	
		@ 125,010 Say "Usa Conexão Segura (SSL) : "  PIXEL OF oPage:aDialogs[nPagePOP] COLOR CLR_BLUE FONT oFont01
		@ 124,140 CHECKBOX oPOPSSL VAR lPOPSSL PROMPT "" SIZE 65,8 PIXEL OF oPage:aDialogs[nPagePOP]

		@ 140,010 Say "Usa Conexão Segura (TLS) : "  PIXEL OF oPage:aDialogs[nPagePOP] COLOR CLR_BLUE FONT oFont01
		@ 139,140 CHECKBOX oPOPTLS VAR lPOPTLS PROMPT "" SIZE 65,8 PIXEL OF oPage:aDialogs[nPagePOP]
		
	Else

		@ 010,010 Say "Servidor POP : "  PIXEL OF oPage:aDialogs[nPagePOP] COLOR CLR_BLUE FONT oFont01
		@ 018,010 Get oServerPOP VAR cServerPOP SIZE 150,08 PIXEL OF oPage:aDialogs[nPagePOP]
	
		@ 040,010 Say "Login : "  PIXEL OF oPage:aDialogs[nPagePOP] COLOR CLR_BLUE FONT oFont01
		@ 048,010 Get oLoginPOP VAR cLoginPOP SIZE 150,08 PIXEL OF oPage:aDialogs[nPagePOP]                  
	
		@ 070,010 Say "Conta de E-mail : "  PIXEL OF oPage:aDialogs[nPagePOP] COLOR CLR_BLUE FONT oFont01
		@ 078,010 Get oPOPConta VAR cPOPConta SIZE 150,08 PIXEL OF oPage:aDialogs[nPagePOP]                   
	
		@ 100,010 Say "Senha : "  PIXEL OF oPage:aDialogs[nPagePOP] COLOR CLR_BLUE FONT oFont01
		@ 108,010 Get oPOPPass VAR cPOPPass SIZE 150,08 PIXEL OF oPage:aDialogs[nPagePOP] PASSWORD
	
		@ 131,010 Say "Servidor Requer Autenticação : "  PIXEL OF oPage:aDialogs[nPagePOP] COLOR CLR_BLUE FONT oFont01
		@ 130,140 CHECKBOX oPOPAuth VAR lPOPAuth PROMPT "" SIZE 65,8 PIXEL OF oPage:aDialogs[nPagePOP]
	
		@ 146,010 Say "Usa Conexão Segura (SSL) : "  PIXEL OF oPage:aDialogs[nPagePOP] COLOR CLR_BLUE FONT oFont01
		@ 145,140 CHECKBOX oPOPSSL VAR lPOPSSL PROMPT "" SIZE 65,8 PIXEL OF oPage:aDialogs[nPagePOP]

		@ 155,010 Say "Usa Conexão Segura (TLS) : "  PIXEL OF oPage:aDialogs[nPagePOP] COLOR CLR_BLUE FONT oFont01
		@ 154,140 CHECKBOX oPOPTLS VAR lPOPTLS PROMPT "" SIZE 65,8 PIXEL OF oPage:aDialogs[nPagePOP]

	EndIf
	
	@ 190,240 Button "Valida E-mail" Size 050,015 PIXEL OF oPage:aDialogs[nPagePOP] ACTION (TestPop(cServerPOP,cLoginPOP,cPOPConta,cPOPPass,lPOPAuth,lPOPSSL,lPOPTLS,cProtocolR,cPortRec,aSmtp))	     
	@ 190,300 Button "Salvar" Size 040,015 PIXEL OF oPage:aDialogs[nPagePOP] ACTION (SetMail(2,2,cServerPOP,cLoginPOP,cPOPConta,cPOPPass,lPOPAuth,lPOPSSL,cProtocolR,cPortRec,lPOPTLS))	     //FR 19/05/2020
   	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Configurações de notificacao                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//oMail01, oMail02, oMail03, oMail04, oMail05
	cMail01 := Padr(GetNewPar("XM_MAIL01",Space(256)),256)
	cMail02 := Padr(GetNewPar("XM_MAIL02",Space(256)),256)
	cMail03 := Padr(GetNewPar("XM_MAIL03",Space(256)),256)
	cMail04 := Padr(GetNewPar("XM_MAIL04",Space(256)),256)
	cMail05 := Padr(GetNewPar("XM_MAIL05",Space(256)),256)
	cMail06 := Padr(GetNewPar("XM_MAIL06",Space(256)),256)
	lChk6	:=	IIF( Alltrim(GetNewPar("XM_ESPIAO" ,"N")) == "S", .T.,.F.)
	lChkImp	:=	IIF( Alltrim(GetNewPar("XM_ENVIMP" ,"N")) == "S", .T.,.F.)
	cMail07 := Padr(GetNewPar("XM_MAIL07",Space(256)),256)
	cMail08 := Padr(GetNewPar("XM_MAIL08",Space(256)),256)
	cMail09 := Padr(GetNewPar("XM_MAIL09",Space(256)),256)  //FR - 21/12/2022 - Flávia Rocha - EMAIL AVISANDO SOBRE NOVO CADASTRO DE FORNECEDOR
	cMail10 := Padr(GetNewPar("XM_MAIL10",Space(256)),256)  //FR - 21/12/2022 - Flávia Rocha - EMAIL AVISANDO SOBRE NOVO XML GRAVADO NA BASE
	cMail11 := Padr(GetNewPar("XM_MAIL11",Space(256)),256)  //FR - 21/12/2022 - Flávia Rocha - EMAIL AVISANDO SOBRE NOVA PRE-NOTA
	cMail12 := Padr(GetNewPar("XM_MAIL12",Space(256)),256)  //FR - 21/12/2022 - Flávia Rocha - EMAIL AVISANDO SOBRE CLASSIFICAÇÃO DA NOTA
	cTentativas:= Strzero(GetNewPar("XM_TENTSEND", 5  ),2)	//FR - 02/05/2023 - Flávia Rocha - Limite máximo de tentativas de envio de email notificação

	@ 015,00.1 To 015.1,043.8 OF oPage:aDialogs[nPageNot]	//FR 19/05/2020 

	@ 010,010 Say "E-mail - Cancelamento de Nota: " PIXEL OF oPage:aDialogs[nPageNot] COLOR CLR_BLUE FONT oFont01
	@ 018,010 Get oMail01 VAR cMail01 SIZE 150,08 PIXEL OF oPage:aDialogs[nPageNot]                   
	cTip := "E-mail responsável por receber as notificações." +CRLF
	cTip += "dos cancelamentos das NF-e."
	oMail01:cToolTip := cTip
	
	@ 040,010 Say "E-mail - Erros de importação: "  PIXEL OF oPage:aDialogs[nPageNot] COLOR CLR_BLUE FONT oFont01
	@ 048,010 Get oMail02 VAR cMail02 SIZE 150,08 PIXEL OF oPage:aDialogs[nPageNot] 
	cTip := "E-mail responsável por receber as notificações." +CRLF
	cTip += "dos erros que acontece na hora da importação."
	oMail02:cToolTip := cTip

	@ 070,010 Say "E-Mail - Falha Geração Pré-Nota c/ Ped.Recorrente: "  PIXEL OF oPage:aDialogs[nPageNot] COLOR CLR_BLUE FONT oFont01
	@ 078,010 Get oMail03 VAR cMail03 SIZE 150,08 PIXEL OF oPage:aDialogs[nPageNot] 
	cTip := "E-mail responsável por receber as notificações." +CRLF
	cTip += "das notas que houve falhas ao gerar Pré-Nota" +CRLF
	cTip += "com pedido recorrente."
	oMail03:cToolTip := cTip

    @ 100,010 CHECKBOX oChk6 VAR lChk6 PROMPT ""  SIZE 95,8 PIXEL OF oPage:aDialogs[nPageNot] COLOR CLR_BLUE FONT oFont01
	@ 100,020 Say "[Espião] E-mail: "  PIXEL OF oPage:aDialogs[nPageNot] COLOR CLR_BLUE FONT oFont01    //Acrescentado no dia 04/02/2016 - (analista Alexandro de Oliveira)
	@ 108,010 Get oMail04 VAR cMail04 SIZE 150,08 PIXEL OF oPage:aDialogs[nPageNot] 
	cTip := "E-mail responsável por receber as notificações." +CRLF
	cTip += "das notas que foram emittidas contra o CNPJ,"    +CRLF
	cTip += "através do WS de Manifestação do SEFAZ. Esta"    +CRLF
	cTip += "opção é executada no JOB Robótica desde que"   +CRLF
	cTip += "a opção 6 esteja selecionada."
	oMail04:cToolTip := cTip

	@ 010,180 Say "XML que não consta na Base (Operadores)(HFCKXML1).: " PIXEL OF oPage:aDialogs[nPageNot] COLOR CLR_BLUE FONT oFont01
	@ 018,180 Get oMail05 VAR cMail05 SIZE 150,08 PIXEL OF oPage:aDialogs[nPageNot]                   
	cTip := "E-mail responsável por receber as notificações." +CRLF
	cTip += "XML que não consta na Base de Dados do Protheus."+CRLF
	cTip += "Rotina U_HFCKXML1, NÃO consta no JOB Importa."   +CRLF
	cTip += "Deve ser incluida nos JOBS do Protheus."
	oMail05:cToolTip := cTip

    @ 030,180 CHECKBOX oChkImp VAR lChkImp PROMPT "Checar Pasta de XML Importados"  SIZE 105,8 PIXEL OF oPage:aDialogs[nPageNot] COLOR CLR_BLUE FONT oFont01
	cTip := "Nas Rotinas executadas por JOB, U_HFCKXML1 e U_HFCKXML2 " +CRLF
	cTip += "que notificam os e-mails acima e abaixo, vai verificar."  +CRLF
	cTip += "a pasta de e-mail Importados?  Visto que os XML desta "   +CRLF
	cTip += "pasta já constam como importados, a menos que deletados"  +CRLF
	cTip += "manualmente."
	oChkImp:cToolTip := cTip
	
	@ 040,180 Say "XML que não consta na Base (Gerentes)(HFCKXML2).: "  PIXEL OF oPage:aDialogs[nPageNot] COLOR CLR_BLUE FONT oFont01
	@ 048,180 Get oMail06 VAR cMail06 SIZE 160,08 PIXEL OF oPage:aDialogs[nPageNot] 
	cTip := "E-mail responsável por receber as notificações."   +CRLF
	cTip += "e XML que não consta na Base de Dados do Protheus" +CRLF
	cTip += "por JOB Separado, indicados aos gestores."         +CRLF
	cTip += "Rotina U_HFCKXML2, NÃO consta no JOB Importa."     +CRLF
	cTip += "Deve ser incluida nos JOBS do Protheus."
	oMail06:cToolTip := cTip

	@ 070,180 Say "E-Mail - Classificação Robótica: "  PIXEL OF oPage:aDialogs[nPageNot] COLOR CLR_BLUE FONT oFont01  //FR - 19/06/2020 - TÓPICOS RAFAEL
	@ 078,180 Get oMail07 VAR cMail07 SIZE 150,08 PIXEL OF oPage:aDialogs[nPageNot] 
	cTip := "E-mail responsável por receber as notificações." +CRLF
	cTip += "das notificações da Integração Externa SFTP " +CRLF			//FR - 17/07/2020
	cTip += "e da Classificação Robótica."
	oMail07:cToolTip := cTip

 	@ 100,180 Say "E-Mail - Divergência Valor Pedido X XML: "  PIXEL OF oPage:aDialogs[nPageNot] COLOR CLR_BLUE FONT oFont01  //FR - 19/06/2020 - TÓPICOS RAFAEL
	@ 108,180 Get oMail08 VAR cMail08 SIZE 150,08 PIXEL OF oPage:aDialogs[nPageNot] 
	cTip := "E-mail responsável por receber as notificações." +CRLF
	cTip += "das divergência de valores maiores " +CRLF			//NA- 01/04/2022
	cTip += "do pedido de em relação ao XML."
	oMail08:cToolTip := cTip

	@ 130,010 Say "E-Mail - Ao Receber XML: "  PIXEL OF oPage:aDialogs[nPageNot] COLOR CLR_BLUE FONT oFont01  //FR - 21/12/2022
	@ 138,010 Get oMail10 VAR cMail10 SIZE 150,08 PIXEL OF oPage:aDialogs[nPageNot] 
	cTip := "E-mail responsável por receber as notificações." +CRLF
	cTip += "de toda vez que um novo XML for gravado na Base de dados." +CRLF	
	oMail10:cToolTip := cTip

	@ 130,180 Say "E-Mail - Gerar Pre-NF"  PIXEL OF oPage:aDialogs[nPageNot] COLOR CLR_BLUE FONT oFont01  //FR - 21/12/2022
	@ 138,180 Get oMail11 VAR cMail11 SIZE 150,08 PIXEL OF oPage:aDialogs[nPageNot] 
	cTip := "E-mail responsável por receber as notificações." +CRLF
	cTip += "de toda vez que gerar a Pre-NF do XML." + CRLF
	oMail11:cToolTip := cTip

	@ 160,010 Say "E-Mail - Classificar o XML"  PIXEL OF oPage:aDialogs[nPageNot] COLOR CLR_BLUE FONT oFont01  //FR - 21/12/2022
	@ 168,010 Get oMail12 VAR cMail12 SIZE 150,08 PIXEL OF oPage:aDialogs[nPageNot] 
	cTip := "E-mail responsável por receber as notificações." +CRLF
	cTip += "de toda vez que classificar a NF do XML." + CRLF
	oMail12:cToolTip := cTip

	@ 160,180 Say "E-Mail - Novo Cadastro Fornecedor: "  PIXEL OF oPage:aDialogs[nPageNot] COLOR CLR_BLUE FONT oFont01  //FR - 21/12/2022
	@ 168,180 Get oMail09 VAR cMail09 SIZE 150,08 PIXEL OF oPage:aDialogs[nPageNot] 
	cTip := "E-mail responsável por receber as notificações." +CRLF
	cTip += "de toda vez que se fizer um novo Cad.Fornecedor via GestãoXML" +CRLF	
	oMail09:cToolTip := cTip
	
	//FR - 02/05/2023 - Flávia Rocha - Limite máximo de tentativas de envio de email notificação
	@ 188,010 Say "Limite de Tentativas de Envio"  PIXEL OF oPage:aDialogs[nPageNot] COLOR CLR_BLUE FONT oFont01  
	@ 196,010 Get oTentaMax VAR cTentativas SIZE 50,08 PIXEL OF oPage:aDialogs[nPageNot] 
	cTip := "Número máximo de tentativas que o Serviço de Email irá" +CRLF
	cTip += "realizar para enviar o(s) email(s) de Notificações." + CRLF
	oTentaMax:cToolTip := cTip
	


	@ 190,300 Button "Salvar" Size 040,015 PIXEL OF oPage:aDialogs[nPageNot] ACTION (SetCfgMail(cMail01, cMail02, cMail03, cMail04, cMail05, lChk6, cMail06, lChkImp, cMail07,cMail08, cMail09, cMail10, cMail11, cMail12,cTentativas ))  //FR 19/05/2020


/*                                                                                   
	label1 := 'QLabel("&lt;h2&gt;Hello&lt;/h2&gt;")'
	label2 := 'QLabel("&lt;h2 style=\"color: #3000FF\"&gt;World...&lt;/h2&gt;")'                                       
	label3 := "Q3Frame{ border-style:solid }"
	
	oradio := Nil
	nradio := 1
	aRadio := {"Estilo 1","Estilo 2","Estilo 3"} 
	@ 30, 170 RADIO oRadio VAR nRadio ITEMS ;
		 aRadio[1],; 
		 aRadio[2],; 
		 aRadio[3]; 
		 SIZE 65,8 PIXEL OF ;
         oPage:aDialogs[nPageNot] ;
         ON CHANGE (SetCss( &("label"+AllTrim(Str(nRadio))) ))
*/

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Configurações Gerais                                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nOpcFile := GETF_RETDIRECTORY
	cPathx   := Padr(GetNewPar("MV_X_PATHX",Space(256)),256)
	cSubFil  := GetNewPar("XM_DIRFIL" ,"S")
	cSubCnpj := GetNewPar("XM_DIRCNPJ","S")
	cSubXML  := GetNewPar("XM_DIRMOD" ,"S")
	cFormNfe := GetNewPar("XM_FORMNFE","6")
	cFormCTe := GetNewPar("XM_FORMCTE","6")
	cPedido  := GetNewPar("XM_PED_PRE","N")

	cDayStat := PadR(GetNewPar("XM_D_STATUS","180"),3)
	cDayCanc := PadR(GetNewPar("XM_D_CANCEL","90"),3)

	cAmarra  := GetNewPar("XM_DE_PARA","0")
	cCfgPre  := GetNewPar("XM_CFGPRE","0")
	cTipPre  := GetNewPar("XM_TIP_PRE","1")
	cFilUsu  := GetNewPar("XM_FIL_USU","N")
	cUrlTss  := Padr(GetNewPar("XM_URL",Space(256)),256)
	cPedXML  := GetNewPar("XM_XPEDXML","1")
	cUsaGfe  := GetNewPar("XM_USAGFE","N")
	cPNfCpl  := GetNewPar("XM_PNFCPL","1")
	nPedTru  := GetNewPar("XM_PEDTRUN",0 )
    cUsaDvg  := GetNewPar("XM_USADVG","N")
    cUltComp := GetNewPar("XM_ULTCOMP","P") 
    cNCM     := GetNewPar("XM_NCMXML","P")
    cFornAuto:= GetNewPar("XM_SA2AUTO","N")		//FR - 28/10/2021  //CADASTRA FORNECEDOR Robótica NA CLASSIFICAÇÃO NF COMBUSTIVEIS
    cFornAutoD:= GetNewPar("XM_SA2AUTD","N")	//FR - 21/12/2021  //CADASTRA FORNECEDOR Robótica NO DOWNLOAD DO XML
    cFisAnali:= GetNewPar("XM_ANAFIS" ,"N")		//FR - 28/10/2021 - indica se usa a nova tela de análise fiscal modelo árvore
	cPCMark  := GetNewPar("XM_PCMARK", "N")		//FR - 28/04/2023 - VYDENCE - pediu para o item pedido compra VIR DESMARCADO
	cBcoConhe:= GetNewPar("XM_BCONHEC", "N")	//FR - 17/05/223 - JADLOG - PARÂMETRO PARA DEFINIR SE UTILIZA FUNÇÃO BANCO CONHECIMENTO AUTOMATIZADA 
												//(INCLUI AUTOMATICAMENTE O DANFE COMO ANEXO NO BCO CONHECIMENTO)

	@ 015,00.1 To 015.1,043.8 OF oPage:aDialogs[nPageGer]		//FR 19/05/2020 

 	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Linha 1 - 10 18                                          ³
 	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	

	@ 010,010 Say "Diretorio XML: " PIXEL OF oPage:aDialogs[nPageGer] COLOR CLR_BLUE FONT oFont01
	@ 018,010 Get oPathX VAR cPathx SIZE 90,08 PIXEL OF oPage:aDialogs[nPageGer]                   
	@ 018,100 BUTTON "..."                      SIZE 010,11 PIXEL OF oPage:aDialogs[nPageGer] ACTION (cPathx:=AllTrim(cGetFile("*.*",,,,.T.,nOpcFile)),ValdGetDir(@cPathx))
  
	cTip := "Informe o Diretório para armazenamento de arquivos XML."
	oPathx:cToolTip := cTip
	@ 010,120 Say "Formato Doc [NF-e]: "  PIXEL OF oPage:aDialogs[nPageGer] COLOR CLR_BLUE FONT oFont01
	@ 018,120 COMBOBOX oFormNfe VAR cFormNfe ITEMS aCombo3 SIZE 100,10 PIXEL OF oPage:aDialogs[nPageGer] 	
		
	cTip := "Se no momento da importação será gravado com 6 ou 9 caracteres 
	cTip += "preenchendo com zeros à esquerda ou natural sem incluir zeros à esquerda."
	oFormNfe:cToolTip := cTip
	@ 010,230 Say "Formato Doc [CT-e]: "  PIXEL OF oPage:aDialogs[nPageGer] COLOR CLR_BLUE FONT oFont01
	@ 018,230 COMBOBOX oFormCte VAR cFormCte ITEMS aCombo3 SIZE 100,10 PIXEL OF oPage:aDialogs[nPageGer] 
	cTip := "Se no momento da importação será gravado com 6 ou 9 caracteres 
	cTip += "preenchendo com zeros à esquerda ou natural sem incluir zeros à esquerda."
	oFormCte:cToolTip := cTip

 	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  	//³ Linha 2 - 32 40                                          ³
 	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	

	@ 032,010 Say "SubDiretorio por Tipo de XML: "  PIXEL OF oPage:aDialogs[nPageGer] COLOR CLR_BLUE FONT oFont01
	@ 040,010 COMBOBOX oSubXML VAR cSubXML ITEMS aCombo2 SIZE 100,10 PIXEL OF oPage:aDialogs[nPageGer] 
	
	cTip := "Informe SIM se deverá gerar pastas por tipo de XML sendo uma pasta para CTE e outra para NFE."
	oSubXml:cToolTip := cTip
	@ 032,120 Say "SubDiretorio por filial: "  PIXEL OF oPage:aDialogs[nPageGer] COLOR CLR_BLUE FONT oFont01
	@ 040,120 COMBOBOX oSubFil VAR cSubFil ITEMS aCombo2 SIZE 100,10 PIXEL OF oPage:aDialogs[nPageGer] 

	cTip := "Informe SIM se no momento da importação na rede organiza os XMLs por filiais."
	oSubFil:cToolTip := cTip
	@ 032,230 Say "SubDiretorio por Emitente [CNPJ]: "  PIXEL OF oPage:aDialogs[nPageGer] COLOR CLR_BLUE FONT oFont01
	@ 040,230 COMBOBOX oSubCNPJ VAR cSubCNPJ ITEMS aCombo2 SIZE 100,10 PIXEL OF oPage:aDialogs[nPageGer] 
     
	cTip := "Informe SIM se no momento da importação na rede organiza os XMLs por CNPJ de fornecedor."
	oSubCNPJ:cToolTip = cTip 

 	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Linha 3 - 54 62                                          ³
 	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	

	@ 054,010 Say "Amarração de produtos: "  PIXEL OF oPage:aDialogs[nPageGer] COLOR CLR_BLUE FONT oFont01
	@ 062,010 COMBOBOX oAmarra VAR cAmarra ITEMS aCombo4 SIZE 100,10 PIXEL OF oPage:aDialogs[nPageGer]
 	cTip := "Selecione o modo de amarração DE/PARA de produtos ." +CRLF
	cTip += "na geração de pré-nota de NF-e."
	oAmarra:cToolTip := cTip

	@ 054,120 Say "Assume pedido na Pré-nota: "  PIXEL OF oPage:aDialogs[nPageGer] COLOR CLR_BLUE FONT oFont01
	@ 062,120 COMBOBOX oPedido VAR cPedido ITEMS aCombo2 SIZE 100,10 PIXEL OF oPage:aDialogs[nPageGer] 
    cTip := "Na consulta de pedido por item <F6> na geração de Pré-nota assume os valores de Pedido." +CRLF
	cTip += "Caso esteja como não mantém os valores do XML."
	oPedido:cToolTip := cTip


	@ 054,230 Say "Tipo de Pré-nota:"  PIXEL OF oPage:aDialogs[nPageGer] COLOR CLR_BLUE FONT oFont01
	@ 062,230 COMBOBOX oTipPre VAR cTipPre ITEMS aCombo8 SIZE 100,10 PIXEL OF oPage:aDialogs[nPageGer] 
	cTip := "Informe o Tipo de Pré-nota a ser gerada." +CRLF
	cTip += "1-Pré-nota 2-Aviso Recebto Carga 3-Ambos"+CRLF
	cTip += "4-Pré-nota + Nt Conhecimento Frete"+CRLF
	cTip += "5-Aviso Recbto Carga + Nt Conhec Frete"+CRLF
	cTip += "6-Todos."
	oTipPre:cToolTip := cTip

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Linha 4 - 76 84                                          
 	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	@ 076,010 Say "Dias p/ Ajuste de Status:"  PIXEL OF oPage:aDialogs[nPageGer] COLOR CLR_BLUE FONT oFont01
	@ 084,010 Get oDayStat VAR cDayStat SIZE 100,08 PICTURE "999" PIXEL OF oPage:aDialogs[nPageGer]                    
   	cTip := "Informe quantos dias o sistema deve retroagir para verificar " +CRLF
	cTip += "os status dos xml quanto a geração e classificação de Pré-notas."+CRLF
	cTip += "Esta verificação é feita Robóticamente ao utilizar a opção "+CRLF
	cTip += "'Baixar Xml' no menu padrão do Importa Xml."+CRLF	
	cTip += "Quanto menor o número de dias mais rápido a rotina é executada."
	oDayStat:cToolTip := cTip	

	@ 076,120 Say "Traz Item PC Marcado?: "  PIXEL OF oPage:aDialogs[nPageGer] COLOR CLR_BLUE FONT oFont01	
	@ 084,120 COMBOBOX oPCMark VAR cPCMark ITEMS aCombo2 SIZE 100,10 PIXEL OF oPage:aDialogs[nPageGer]                   
    cTip := "S=Sim Traz Itens Pedido Compra Já Marcados [x];" +CRLF
	cTip += "N=Não Traz Itens sem marcar, o usuário seleciona e marca manualmente"+CRLF
	oPCMark:cToolTip := cTip
	
	//FR 08/06/2020 - Classificação de NF direto, tratativa para esta opção, sem geração de pré-nota	
	@ 076,230 Say "Ação Para Nota Fiscal:"  PIXEL OF oPage:aDialogs[nPageGer] COLOR CLR_BLUE FONT oFont01
	@ 084,230 COMBOBOX oCfgPre VAR cCfgPre ITEMS aCombo7 SIZE 100,08 PIXEL OF oPage:aDialogs[nPageGer]                    
   	cTip := "0-Gera Pré-Nota: Apenas gera a pré-nota, ficando pendente classificação;" +CRLF
	cTip += "1-Gera Pré-Nota e Classifica: Gera a pré-nota e em seguida já a classifica;"+CRLF
	cTip += "2-Sempre Perguntar"
	cTip += "3-Gera Docto.Entrada Direto: Geração direta do Documento Entrada, sem passar por pré-nota."
	oCfgPre:cToolTip := cTip

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Linha 5                                                
 	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 

	@ 098,010 Say "URL TSS: "  PIXEL OF oPage:aDialogs[nPageGer] COLOR CLR_BLUE FONT oFont01
	@ 106,010 Get oUrlTss VAR cUrlTss SIZE 100,08 PIXEL OF oPage:aDialogs[nPageGer]
	cTip := "Informe a URL do TSS que será utilizado para o importa XML." + CRLF
	cTip += "com a devida porta. Exemplo http://192.168.1.100:8081/" + CRLF
	cTip += "Caso fique em branco será utilizado o parametro MV_SPEDURL."
	oUrlTss:cToolTip := cTip 
 	
 	@ 098,120 Say "Filtra Filial do Usuário:" PIXEL OF oPage:aDialogs[nPageGer] COLOR CLR_BLUE FONT oFont01
	@ 106,120 COMBOBOX oFilUsu VAR cFilUsu ITEMS aCombo2 SIZE 100,10 PIXEL OF oPage:aDialogs[nPageGer]                    
   	cTip := "Filtrar XMLs da filial de acordo com o especificado no cadastro" +CRLF
	cTip += "de usuário. Administradores não filtra filial."
	oFilUsu:cToolTip := cTip

	@ 098,230 Say "Tipo Amarração por Pedido:"  PIXEL OF oPage:aDialogs[nPageGer] COLOR CLR_BLUE FONT oFont01
	@ 106,230 COMBOBOX oPedXML VAR cPedXML ITEMS aCombo22 SIZE 100,08 PIXEL OF oPage:aDialogs[nPageGer]                    
   	cTip := "1-Monta Pré-nota com o Saldo do Pedido Selecionado; " +CRLF
	cTip += "2-Monta Pré-nota com o XML, validando as diferenças;"+CRLF
	cTip += "3-Perguntar como montar a pré-nota; "
	cTip += "4-Saldo por item de pedido."
	oPedXML:cToolTip := cTip
 	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Linha 6
 	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	@ 120,010 Say "Considera Frete Embarcador (GFE):"  PIXEL OF oPage:aDialogs[nPageGer] COLOR CLR_BLUE FONT oFont01
	@ 128,010 COMBOBOX oUsaGfe VAR cUsaGfe ITEMS aCombo2 SIZE 100,08 PIXEL OF oPage:aDialogs[nPageGer]                    
   	cTip := "Se SIM irá atualizar o campo de Situação do GFE," +CRLF
	cTip += "a partir dos registro do modulo frete embarcador"+CRLF
	cTip += "tabela GW3. A situação será atualizada na importação"+CRLF
	cTip += "do XML e na rotina de atualização de status do XML."
	oUsaGfe:cToolTip := cTip
 	
	@ 120,120 Say "  Notas Complemento:"  PIXEL OF oPage:aDialogs[nPageGer] COLOR CLR_BLUE FONT oFont01
	@ 128,120 COMBOBOX oPNfCpl VAR cPNfCpl ITEMS aCombo23 SIZE 100,10 PIXEL OF oPage:aDialogs[nPageGer]
   	cTip := "Notas de Complemento de ICMS e IPI" +CRLF
	cTip += "1-Lançar Execauto do Documento de Entrada, como Tipo Complemento"+CRLF
	cTip += "2-Lançar Pré-Nota, como Tipo Normal"+CRLF
	cTip += "3-Perguntar"
	oPNfCpl:cToolTip := cTip

	@ 120,230 Say "Trunca Amarração p/Pedido:"  PIXEL OF oPage:aDialogs[nPageGer] COLOR CLR_BLUE FONT oFont01
	@ 128,230 Get oPedTru VAR nPedTru SIZE 100,10  PICTURE "99" PIXEL OF oPage:aDialogs[nPageGer]                    
   	cTip := "Numero de casas decimais mínimna para truncar" +CRLF
	cTip += "quantidade do XML, quando for amarração p/pedido"+CRLF
	cTip += "e montada por XML, se o saldo do Pedido for "+CRLF
	cTip += "que a quantidade do XML"+CRLF
	cTip += "Deixando com Zero ele obedece o C7_QUANT."	
	oPedTru:cToolTip := cTip  
 	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Linha 7                                                 
 	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	@ 142,010 Say "Verifica Divergências XML x NF?"  PIXEL OF oPage:aDialogs[nPageGer] COLOR CLR_BLUE FONT oFont01
	@ 150,010 COMBOBOX oUsaDvg VAR cUsaDvg ITEMS aCombo26 SIZE 100,08 PIXEL OF oPage:aDialogs[nPageGer]                    
   	cTip := "Se SIM irá verificar divergências entre" +CRLF
	cTip += "o XML e NF."
	oUsaDvg:cToolTip := cTip

 	//FR - 28/04/2021 - NOVA TELA GESTÃOXML 	
	@ 142,120 Say "Dados Última Compra:"  PIXEL OF oPage:aDialogs[nPageGer] COLOR CLR_BLUE FONT oFont01
	@ 150,120 COMBOBOX oUltComp VAR cUltComp ITEMS aCombo11 SIZE 100,10 PIXEL OF oPage:aDialogs[nPageGer]
   	cTip := "Carrega Dados da Última Compra na geração de documentos ?" +CRLF
	cTip += "S-Sim"+CRLF
	cTip += "N-Não"+CRLF
	cTip += "P-Perguntar"
	oUltComp:cToolTip := cTip
	
	//FR - 28/04/2021 - NOVA TELA GESTÃOXML 	
	@ 142,230 Say "Assume NCM do XML?"  PIXEL OF oPage:aDialogs[nPageGer] COLOR CLR_BLUE FONT oFont01
	@ 150,230 COMBOBOX oNCM VAR cNCM ITEMS aCombo11 SIZE 100,10 PIXEL OF oPage:aDialogs[nPageGer]
   	cTip := "Atualiza a NCM do Cad.Produto com NCM do XML ?" +CRLF
	cTip += "S-Sim"+CRLF
	cTip += "N-Não"+CRLF
	cTip += "P-Perguntar"
	oNCM:cToolTip := cTip
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Linha 8                                                 
 	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	@ 164,010 Say "Utiliza Análise Fiscal Mod. Árvore?"  PIXEL OF oPage:aDialogs[nPageGer] COLOR CLR_BLUE FONT oFont01
	@ 172,010 COMBOBOX oFisAnali VAR cFisAnali ITEMS aCombo26 SIZE 100,10  PIXEL OF oPage:aDialogs[nPageGer]                    
   	cTip := "Indica se Utiliza a Tela de Análise Fiscal  " +CRLF
	cTip += "Modelo 'Árvore' "+CRLF	
	cTip += "S=Sim Utiliza " + CRLF
	cTip += "N=Não Utiliza " + CRLF	
	oFisAnali:cToolTip := cTip

 	//FR - 28/10/2021
	@ 164,120 Say "Fornecedor Auto?"  PIXEL OF oPage:aDialogs[nPageGer] COLOR CLR_BLUE FONT oFont01		
	@ 172,120 COMBOBOX oFornauto VAR cFornAuto ITEMS aCombo26 SIZE 100,10 PIXEL OF oPage:aDialogs[nPageGer]	
	cTip := "Cadastra fornecedor na SA2 antes da Classificação Robótica de NF combustíveis (caso não encontrar o fornecedor),"+CRLF 
	cTip += "efetua o cadastro do mesmo de forma robótica"+CRLF
	cTip += "S-Sim Cadastra o Fornecedor"+CRLF
	cTip += "N-Não Cadastra"+CRLF	
	oFornauto:cToolTip := cTip
	
	@ 164,230 Say "Cad.Fornecedor Download ?"  PIXEL OF oPage:aDialogs[nPageGer] COLOR CLR_BLUE FONT oFont01		
	@ 172,230 COMBOBOX oFornautoD VAR cFornAutoD ITEMS aCombo26 SIZE 100,10 PIXEL OF oPage:aDialogs[nPageGer]	
	cTip := "No download do XML e não encontrar o fornecedor cadastrado,"+CRLF 
	cTip += "efetua o cadastro do mesmo de forma robótica"+CRLF
	cTip += "S-Sim Cadastra o Fornecedor"+CRLF
	cTip += "N-Não Cadastra"+CRLF	
	oFornautoD:cToolTip := cTip

	
	@ 186,010 Say "Utiliza Bco. Conhecimento Autom.?"  PIXEL OF oPage:aDialogs[nPageGer] COLOR CLR_BLUE FONT oFont01
	@ 194,010 COMBOBOX oBcoConhe VAR cBcoConhe ITEMS aCombo26 SIZE 100,10  PIXEL OF oPage:aDialogs[nPageGer]                    
   	cTip := "Indica se Utiliza Bco.Conhecimento Automatizado" +CRLF
	cTip += "S=Sim Utiliza " + CRLF
	cTip += "N=Não Utiliza " + CRLF	
	oBcoConhe:cToolTip := cTip
 	
	
	@ 216,289 Button "Salvar" Size 040,015 PIXEL OF oPage:aDialogs[nPageGer] ACTION (SetCfgGer(cPathx, cSubFil, cSubCNPJ, cFormNfe,cFormCTe,cSubxml,cPedido,cDayStat,cCfgPre,cTipPre,cFilUsu,cUrlTss,cAmarra,cPedXML,cUsaGfe,cPNfCpl,nPedTru,cUsaDvg,cUltComp,cNCM,cFornAuto,cFisAnali,cFornAutoD,cPCMark,cBcoConhe)) 
																																			        //cForceCte,cCteDet,cCSol,cCCNfOr
    
    //incluido configuraçoes aba Gerais 2 - Alexandro de Oliveira - 25/11/2014 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Configurações Gerais 2                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSerEmp    	:=	Padr(GetNewPar("XM_SEREMP",Space(256)),256)
	_cSerXML   	:=	GetNewPar("XM_SERXML","N")
	_cTravPrN  	:=	GetNewPar("XM_PED_GBR","N")
	cRotCon    	:=	GetNewPar("XM_ROT_CON","1")
	cConMod    	:=	GetNewPar("XM_GRBMOD","N")    //DFE777
	cDfeDow     :=  GetNewPar("XM_DFE","2")
	cDfeMan     :=  GetNewPar("XM_DFEMAN","0")
	cPedRec    	:=	GetNewPar("XM_PEDREC","N")
	cRecDoc    	:=	GetNewPar("XM_RECDOC","1")
	cTabRec    	:=	Padr(GetNewPar("XM_TABREC",Space(3)),3)
	cXmlSef    	:=	GetNewPar("XM_XMLSEF","N")
	cManPre    	:=	GetNewPar("XM_MANPRE","N")
	cLogoDan   	:=	GetNewPar("XM_LOGOD" ,"N")
	cMostra     :=  GetNewPar("MV_MOSTRAA","N")
	_cFormSer	:=  GetNewPar("XM_FORMSER","0")
	cManAut    	:=  GetNewPar("XM_MANAUT","N")
	cVerLoja	:=	SuperGetMv("XM_VERLOJA",.T.,"N") // Incluido considerar Loja no 4=Pedido
	cCteAvi 	:=	GetNewPar("XM_CTE_AVI","S")   //Jardel
	cCadForn	:=	SuperGetMv("XM_USACFOR",.T.,"S") // Incluido para cadastro de fornecedores
	cMBrw       :=  GetNewPar("XM_BROWSE", "1"  )  //ZBEMANO
	cAglCTE		:=	SuperGetMv("XM_AGLMCTE",.T.,"N") // Incluido considerar Multiplos CTE - 31/05/2017
	cUsaPriv    :=  GetNewPar("XM_PRIVILE", "N"  )
	cCentro     :=  GetNewPar("XM_CENTRO", "1"  )
	cRetOk      :=  Padr(GetNewPar("XM_RETOK", "526,731"+Space(256)),256)
	cLpaTrv     :=  GetNewPar("XM_LPATRV", "N"  )
	cSefPrn     :=  GetNewPar("XM_SEFPRN", "N"  )
	cBxResu     :=  GetNewPar("XM_BXRESUM", "N"  )
	cBxCteT     :=  GetNewPar("XM_BXCTETM", "N"  )
	cUsaStat    :=  GetNewPar("XM_USASTAT", "N"  )
	cDesmembra  :=  GetNewPar("XM_DESLOTE" , "N")  //FR - 19/10/2022 - MBIOLOG - ATIVA DESMEMBRAMENTO DE LOTE
	cLoteFor    :=  GetNewPar("XM_LOTEFOR")

	@ 015,00.1 To 015.1,043.8 OF oPage:aDialogs[nPageGerII] 	//FR 19/05/2020

   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Linha 1                                                  ³
 	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 010,010 Say "Série Por Empresa:" PIXEL OF oPage:aDialogs[nPageGerII] COLOR CLR_BLUE FONT oFont01
	@ 018,010 Get oSerEmp VAR cSerEmp SIZE 100,10 PIXEL OF oPage:aDialogs[nPageGerII]
   	cTip := "Série padrão para empresa para a importação do XML substituindo a" +CRLF
	cTip += "série que vem no XML. EX: SP todo XML será importado com série SP" +CRLF
	cTip += "a pré-nota será gravada também com esta série, e a série original" +CRLF
	cTip += "ficará gravada no campo a parte na tabela. Série Padrão p/ Filial" +CRLF
	cTip += "EX:SP=01,03;ES=02,05. Neste exemplo as filiais 01 e 03 terão suas" +CRLF
	cTip += "séries como SP e as filiais 02 e 05 terão suas séries ES, e a" +CRLF
	cTip += "filial 04 será importado com a Série Original." +CRLF
	cTip += "OBS: Para manter somente a Série Original do XML deixar VAZIO."
	oSerEmp:cToolTip := cTip
	
	@ 010,120 Say "Serie XML Vazia para 0: " PIXEL OF oPage:aDialogs[nPageGerII] COLOR CLR_BLUE FONT oFont01 
	@ 018,120 COMBOBOX  oSerXML VAR _cSerXML ITEMS aCombo13 SIZE 100,10 PIXEL OF oPage:aDialogs[nPageGerII]                  
  	cTip := "SIM para importar a Série 0 como Vazia." +CRLF
	cTip += "NAO permanece a série 0." +CRLF
	cTip += "ZERAR para importar a Série vazia com o 0." +CRLF
	cTip += "PREENCHE com zeros a esquerda." +CRLF
	cTip += "OBS: Caso a série seja diferente de 0 permanece a série normal."
	oSerXML:cToolTip := cTip 

	@ 010,230 Say "Travar Pré-Nota: " PIXEL OF oPage:aDialogs[nPageGerII] COLOR CLR_BLUE FONT oFont01 
	@ 018,230 COMBOBOX  oTravPrN VAR _cTravPrN ITEMS aCombo29 SIZE 100,10 PIXEL OF oPage:aDialogs[nPageGerII]    //FR - 21/06/2022 - BRASMOLDE - nova opção para validação da pré-nota              
	cTip := "SIM - Trava Tudo -> Quando valor total do XML for diferente do Lançado" +CRLF
	cTip += "na pré-nota, não deixará gravar o lançamento;" +CRLF
	cTip += "NÃO - Não Trava -> Deixa gravar a pré-nota sem checar a diferença;" +CRLF
	cTip += "PERGUNTAR -> O usuário escolherá se grava ou não a pré-nota" +CRLF
	cTip += "quando o total for diferente;"+CRLF
	cTip += "ESPECÍFICO - Valida Via Ponto de Entrada (HFXMLVLPED)" + CRLF
	cTip += "no qual fica a critério definir as regras para travamento ou não."
	oTravPrN:cToolTip := cTip 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Linha 2                                                ³
 	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//	@ 032,010 Say "Rotina Consulta Sefaz:" PIXEL OF oPage:aDialogs[nPageGerII] COLOR CLR_BLUE FONT oFont01
//	@ 040,010 COMBOBOX oRotCon VAR cRotCon ITEMS aCombo12 SIZE 100,10 PIXEL OF oPage:aDialogs[nPageGerII]
//   	cTip := "1 - Consulta ao Sefaz Pela Rotina do importa XML" +CRLF
//   	cTip += "2 - Consulta ao Sefaz Pela Rotina Padrão do TSS" +CRLF
//   	cTip += "OBS: Na consulta pela rotina do importa, se a resposta" +CRLF
//   	cTip += "for negativa, será feita uma consulta pelo TSS. " +CRLF
//   	cTip += "A rotina do importa também esta no repositório do TSS," +CRLF
//   	cTip += "então a Patch do TSS deverá ter sido aplicada."
//	oRotCon:cToolTip := cTip 
	@ 032,010 Say "Rotina do WS DFE (Download): "  PIXEL OF oPage:aDialogs[nPageGerII] COLOR CLR_BLUE FONT oFont01
	@ 040,010 COMBOBOX oDfeDow VAR cDfeDow ITEMS aCombo12 SIZE 100,10 PIXEL OF oPage:aDialogs[nPageGerII]
   	cTip := "Definir qual rotina do WS DFE será utilizada:" +CRLF
   	cTip += "0 - Utiliza Rotina padrão Protheus no Repositório do TSS;" +CRLF
   	cTip += "1 - Utiliza Rotina Importa XML no Repositório do TSS;" +CRLF
   	cTip += "2 - Utiliza baixa do SEFAZ diretamente pelo Protheus." +CRLF
	cTip += "Caso Aba interação cloud esteja habilitado , " +CRLF
	cTip += "Baixa direto da nuvem por conector ou aplicação cloud." +CRLF
   	cTip += "OBS: Para a utilização das rotinas 0 -> TSS Protheus ou " +CRLF
   	cTip += "1 -> TSS Imp XML é necessário estar aplicada a patch do " +CRLF
   	cTip += "TSS do importa xml (TSS_IMPXML_20190627_A_tttp120). " +CRLF
   	cTip += "OBS2: Para a utilização das rotinas 0 -> TSS Protheus ou " +CRLF
   	cTip += "1 -> TSS Imp XML é necessário configurar os certificados na" +CRLF
   	cTip += "tela do Faturamento NFESEFAZ, para utilização da rotina 2 " +CRLF
   	cTip += "os Certificados (PFX) deverão ser configurados na rotina do" +CRLF
   	cTip += "importa XML na opção Certificado no browse de download"
	oDfeDow:cToolTip := cTip

	@ 032,120 Say "Rotina Manifestação Destinatário: " PIXEL OF oPage:aDialogs[nPageGerII] COLOR CLR_BLUE FONT oFont01 
	@ 040,120 COMBOBOX  oDfeMan VAR cDfeMan ITEMS aCombo02 SIZE 100,10 PIXEL OF oPage:aDialogs[nPageGerII]                  
   	cTip := "Definir qual rotina WS de Manifestação será utilizada:" +CRLF
   	cTip += "0 - Utiliza Rotina Importa XML no Repositório do TSS;" +CRLF
   	cTip += "1 - Utiliza Rotina Importa XML no Repositório Protheus." +CRLF
   	cTip += "OBS: Para a utilização das rotinas 0 -> TSS Imp XML " +CRLF
   	cTip += "é necessário estar aplicada a patch do TSS do importa xml" +CRLF
   	cTip += "(TSS_IMPXML_20190627_A_tttp120). "+CRLF
   	cTip += "OBS2: Para a utilização das rotinas 0 -> TSS Imp XML " +CRLF
   	cTip += "é necessário configurar os certificados na Tela do " +CRLF
   	cTip += "Faturamento NFESEFAZ, para utilização da rotina 1 os  "+CRLF
   	cTip += "Certificados (PFX) deverão ser configurados na rotina do" +CRLF
   	cTip += "importa XML na opção Certificado no browse de download"
	oDfeMan:cToolTip := cTip 

	@ 032,230 Say "Utiliza Pedido Recorrente: " PIXEL OF oPage:aDialogs[nPageGerII] COLOR CLR_BLUE FONT oFont01 
	@ 040,230 COMBOBOX oPedRec VAR cPedRec ITEMS aCombo2 SIZE 100,10 PIXEL OF oPage:aDialogs[nPageGerII]
	cTip := "Habilitará a Função de Pedido Recorrente," +CRLF
	cTip += "a qual a pré-nota será gerada Robóticamente" +CRLF
	cTip += "ao importar o XML para o sistema, desde que o" +CRLF
	cTip += "fornecedor e produto tenham pedido amarrado e" +CRLF
	cTip += "com saldo."
	oPedRec:cToolTip := cTip

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Linha 3                                                ³
 	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 	@ 054,010 Say "Tabela Pedido Recorrente:"  PIXEL OF oPage:aDialogs[nPageGerII] COLOR CLR_BLUE FONT oFont01
	@ 062,010 Get oTabRec VAR cTabRec SIZE 100,08 PICTURE "!!!" PIXEL OF oPage:aDialogs[nPageGerII]                    
   	cTip := "Tabela de amarração do fornecedor" +CRLF
	cTip += "com o seu pedido recorrente."
	oTabRec:cToolTip := cTip

	@ 054,120 Say "Tipo Doc. Pedido Recorrente:" PIXEL OF oPage:aDialogs[nPageGerII] COLOR CLR_BLUE FONT oFont01
	@ 062,120 COMBOBOX oRecDoc VAR cRecDoc ITEMS aCombo14 SIZE 100,10 PIXEL OF oPage:aDialogs[nPageGerII]
   	cTip := "Tipo de Documento a ser gerado por pedido Recorrente:" +CRLF
   	cTip += "1 - Pré-Nota;" +CRLF
   	cTip += "2 - Documento de Entrada (Classificado)."
	oRecDoc:cToolTip := cTip 

	@ 054,230 Say "Compara XML com a SEFAZ: " PIXEL OF oPage:aDialogs[nPageGerII] COLOR CLR_BLUE FONT oFont01 
	@ 062,230 COMBOBOX oXmlSef VAR cXmlSef ITEMS aCombo2 SIZE 100,10 PIXEL OF oPage:aDialogs[nPageGerII]
	cTip := "Habilitará a Função de Comparação do XML" +CRLF
	cTip += "baixado por e-mail com o XML da SEFAZ." +CRLF
	cTip += "As TAGs para comparar deverão ser informadas" +CRLF
	cTip += "no arquivo TagNfe.Cfg na pasta CFG dentro do" +CRLF
	cTip += "diretório definido no parâmetro MV_X_PATHX." +CRLF
	cTip += "EX: \Protheus_Data\xmlsource\Cfg\TagNfe.Cfg"
	oXmlSef:cToolTip := cTip

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Linha 4                                                ³
 	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	@ 076,010 Say "Manifestação Robótica:" PIXEL OF oPage:aDialogs[nPageGerII] COLOR CLR_BLUE FONT oFont01   //FR - 19/06/2020 - TÓPICOS RAFAEL
	@ 084,010 COMBOBOX oManPre VAR cManPre ITEMS aCombo15 SIZE 100,10 PIXEL OF oPage:aDialogs[nPageGerII]
   	cTip := "Tipos de Manifestação:" +CRLF
   	cTip += "N - Não Manifestar;" +CRLF
   	cTip += "1 - Confirmar Operação (pré-NF);" +CRLF
   	cTip += "2 - Ciência da Operação (pré-NF)"
   	cTip += "3 - Confirmação da Operação Classificação." 		//FR - 19/06/2020 - TÓPICOS RAFAEL   desenvolver tratativa
	oManPre:cToolTip := cTip 

	@ 076,120 Say "Emissão do Logo na Danfe:" PIXEL OF oPage:aDialogs[nPageGerII] COLOR CLR_BLUE FONT oFont01
	@ 084,120 COMBOBOX oLogoDan VAR cLogoDan ITEMS aCombo2 SIZE 100,10 PIXEL OF oPage:aDialogs[nPageGerII]
   	cTip := "Se na emissão da danfe aparece o logo:" +CRLF
   	cTip += "S - Sim aparece;" +CRLF
   	cTip += "N - Não aparece;" +CRLF
	oLogoDan:cToolTip := cTip 

	@ 076,230 Say "Consulta SEFAZ na Pré-Nota:"  PIXEL OF oPage:aDialogs[nPageGerII] COLOR CLR_BLUE FONT oFont01
	@ 084,230 COMBOBOX oSefPrn VAR cSefPrn ITEMS aCombo2 SIZE 100,10 PIXEL OF oPage:aDialogs[nPageGerII]
	cTip := "Realiza consulta SEFAZ antes de Gerar o Documento (PréNota, Aviso Carga, Conh.Frete)." +CRLF
	cTip += "Para que caso seja cancelado o XML seja atualizado o status e não permitir gerar o Documento."
	oSefPrn:cToolTip := cTip
		
 	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Linha 5                                                  ³
 	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
    
    @ 098,010 Say "Formato Serie [NF-e]:" PIXEL OF oPage:aDialogs[nPageGerII] COLOR CLR_BLUE FONT oFont01
	@ 106,010 COMBOBOX oFormSer VAR _cFormSer ITEMS aCombo16 SIZE 100,10 PIXEL OF oPage:aDialogs[nPageGerII]
   	cTip := "Formatação da Série:" +CRLF
   	cTip += "0 - Original;" +CRLF
   	cTip += "2 - 2 Dígitos;" +CRLF
   	cTip += "3 - 3 Dígitos."
	oFormSer:cToolTip := cTip
	
	@ 098,120 Say "Manifesta (ciência) p/Download Aut:" PIXEL OF oPage:aDialogs[nPageGerII] COLOR CLR_BLUE FONT oFont01
	@ 106,120 COMBOBOX oManAut VAR cManAut ITEMS aCombo2 SIZE 100,10 PIXEL OF oPage:aDialogs[nPageGerII]
   	cTip := "Se a rotina de download pelo  Job Robótica" +CRLF
   	cTip += "(opção 6 do campo rotinas, na tela de confi-" +CRLF
   	cTip += "guração de JOB, primeira Aba), estiver Sele-" +CRLF
   	cTip += "cionada e este parâmetro estiver  como  Sim" +CRLF
   	cTip += "ira fazer a manifestação do destinatário como" +CRLF
   	cTip += "ciência da operação para as chaves que ainda" +CRLF
   	cTip += "não tem manifestação para que seja Feito o" +CRLF
   	cTip += "download. Serão obedecidos os critérios da" +CRLF
   	cTip += "nota técnica NT_2012_002."
	oManAut:cToolTip := cTip
	
	/*Incluido para considera a loja na amarração 4=Pedido*/
	@ 098,230 Say "Considera Loja Pedido:"  PIXEL OF oPage:aDialogs[nPageGerII] COLOR CLR_BLUE FONT oFont01
	@ 106,230 COMBOBOX oVerLoja VAR cVerLoja ITEMS aCombo2 SIZE 100,10 PIXEL OF oPage:aDialogs[nPageGerII]
	cTip := "Parametro que define se a loja do fornecedor" +CRLF
	cTip += "deve ser considerado no momento de selecionar"+CRLF
	cTip += "o pedido para amarra-lo a pre-nota /nota"+CRLF
	cTip += "1-Sim para considerar a Loja"+CRLF
	cTip += "2-Não para não considerar a loja."
	oVerLoja:cToolTip := cTip
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Linha 6                                                  ³
 	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	    

	@ 120,010 Say "Cadastro Fornecedor:"  PIXEL OF oPage:aDialogs[nPageGerII] COLOR CLR_BLUE FONT oFont01
	@ 128,010 COMBOBOX oCadForn VAR cCadForn ITEMS aCombo2 SIZE 100,10 PIXEL OF oPage:aDialogs[nPageGerII]
	cTip := "Habilita cadastro do fornecedor via Tela funções XML-> Cad. Fornecedor."+CRLF
	cTip += "Exemplo XXXXXX não esta cadastrado no sistema chama tela de cadastro preenchida."
	cTip += "S = Sim Habilita cadastro;"+CRLF
	cTip += "N = Não habilita cadastro"
	oCadForn:cToolTip := cTip

	@ 120,120 Say "BROWSE INICIAL:"  PIXEL OF oPage:aDialogs[nPageGerII] COLOR CLR_BLUE FONT oFont01
	@ 128,120 COMBOBOX oMBrw VAR cMBrw ITEMS aCombo17 SIZE 100,10 PIXEL OF oPage:aDialogs[nPageGerII]
	cTip := "1 - Na Tela inicial do importa, apresentar apenas o " +CRLF
	cTip += "browse da chave da NFe." +CRLF
	cTip += "2 - Na Tela inicial do importa, apresentar dois browses" +CRLF
	cTip += "o da chave da NFe e outro com as CCe e Eventos da Nfe  " +CRLF
	cTip += "selecionada."
	cTip += "3 - Na Tela inicial do importa, apresentar três browses" +CRLF
	cTip += "o da chave da NFe, outro c/ as CCe e Eventos da Nfe  " +CRLF
	cTip += "e outro com os Itens da NF selecionada."
	oMBrw:cToolTip := cTip

	@ 120,230 Say "Usa Privilegio:"  PIXEL OF oPage:aDialogs[nPageGerII] COLOR CLR_BLUE FONT oFont01
	@ 128,230 COMBOBOX oUsaPriv VAR cUsaPriv ITEMS aCombo2 SIZE 100,10 PIXEL OF oPage:aDialogs[nPageGerII]
	cTip := "Utilizar cadastro de Regras de Acesso de usuários (Padrão Protheus)." +CRLF
	cTip += "Fazer as regras na opção do protheus Privilégio e associar aos usuários."
	oUsaPriv:cToolTip := cTip
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Linha 7                                                 ³
 	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 	
	@ 142,010 Say "Ret SEFAZ considerado como OK:"  PIXEL OF oPage:aDialogs[nPageGerII] COLOR CLR_BLUE FONT oFont01
	@ 150,010 Get oRetOk VAR cRetOk SIZE 100,10 PICTURE "@!" PIXEL OF oPage:aDialogs[nPageGerII]
	cTip := "Código de Retorno XML do Sefaz considerado como Valido." +CRLF
	cTip += "Ex: 526,731"
	oRetOk:cToolTip := cTip

	//NA - 02/03/2021
	@ 142,230 Say "Centro de Custo:"  PIXEL OF oPage:aDialogs[nPageGerII] COLOR CLR_BLUE FONT oFont01
	@ 150,230 COMBOBOX oCentro VAR cCentro ITEMS aCombo28 SIZE 100,10 PIXEL OF oPage:aDialogs[nPageGerII]
	cTip := "Informar de onde irá pegar o centro de custo:" + CRLF
	cTip += "1 - Padrão totvs; " +CRLF
	cTip += "2 - Cadastro do Produto"
	oCentro:cToolTip := cTip
	//NA - 02/03/2021
	@ 142,120 Say "Limpa Semaforo:"  PIXEL OF oPage:aDialogs[nPageGerII] COLOR CLR_BLUE FONT oFont01
	@ 150,120 COMBOBOX oUsaPriv VAR cLpaTrv ITEMS aCombo2 SIZE 100,10 PIXEL OF oPage:aDialogs[nPageGerII]
	cTip := "Rodar rotina de limpeza de semáforo antes da rotina de importação de XML?" +CRLF
	cTip += "Antes de importar rodar rotina que limpa arquivos *.trv que podem estar na" +CRLF
	cTip += "pasta por conta de interrupção inesperada da rotina ou problema de acesso."
	oUsaPriv:cToolTip := cTip

	@ 164,010 Say "Baixar XML Nfe Resumido:"  PIXEL OF oPage:aDialogs[nPageGerII] COLOR CLR_BLUE FONT oFont01
	@ 172,010 COMBOBOX oBxResu VAR cBxResu ITEMS aCombo2 SIZE 100,10 PIXEL OF oPage:aDialogs[nPageGerII]
	cTip := "Informar se XML´s resumidos serão baixados para o Protheus." +CRLF
	cTip += "OBs.: Apenas NFe"
	oBxResu:cToolTip := cTip
	
	@ 164,120 Say "Usa Status XML:"  PIXEL OF oPage:aDialogs[nPageGerII] COLOR CLR_BLUE FONT oFont01
	@ 172,120 COMBOBOX oBaxResu VAR cUsaStat ITEMS aCombo2 SIZE 100,10 PIXEL OF oPage:aDialogs[nPageGerII]
	cTip := "Informar se será usado a segunda legenda para mostrar última manifestação." +CRLF
	oBaxResu:cToolTip := cTip

	@ 164,230 Say "Permite Desmembrar Lote:"  PIXEL OF oPage:aDialogs[nPageGerII] COLOR CLR_BLUE FONT oFont01
	@ 172,230 COMBOBOX oBaxResu VAR cDesmembra ITEMS aCombo2 SIZE 100,10 PIXEL OF oPage:aDialogs[nPageGerII]
	cTip := "Define se irá desmembrar na nota, as qtdes por lotes do fornecedor." +CRLF
	cTip += "S=Sim"+CRLF
	cTip += "N=Não"+CRLF + CRLF
	cTip += "Ex.: Qtde = 100, se o desmembra estiver = Sim, ficará assim:" +CRLF
	cTip += "Ex.: Se vier 4 lotes de qtde = 25, o sistema irá desmembrar: " + CRLF
	cTip += "QTDE 25 -> LOTE01"+ CRLF
	cTip += "QTDE 25 -> LOTE02"+ CRLF
	cTip += "QTDE 25 -> LOTE03"+ CRLF
	cTip += "QTDE 25 -> LOTE04"+ CRLF
	oBaxResu:cToolTip := cTip

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Linha 9                                                  ³
 	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 186,010 Say "Usa o Lote do Fornecedor?"  PIXEL OF oPage:aDialogs[nPageGerII] COLOR CLR_BLUE FONT oFont01
	@ 194,010 COMBOBOX oFisAnali VAR cLoteFor ITEMS aCombo2 SIZE 100,10  PIXEL OF oPage:aDialogs[nPageGerII]                    
   	cTip := "Indica se o Nro.Lote interno é o mesmo do Fornecedor." +CRLF
	cTip += "S = Sim Utiliza " + CRLF
	cTip += "N = Não Utiliza " + CRLF	
	oFisAnali:cToolTip := cTip

	@ 190,300 Button "Salvar" Size 040,015 PIXEL OF oPage:aDialogs[nPageGerII] ACTION (SetCfgGerII(cSerEmp,_cSerXML,_cTravPrN,cRotCon,cConMod,cPedRec,cTabRec,cRecDoc,cXmlSef,cManPre,cLogoDan,_cFormSer,cMostra,cManAut,cVerLoja,cCadForn,cMBrw,cUsaPriv,cRetOk,cLpaTrv,cSefPrn,cDfeDow,cDfeMan,cCentro,cUsaStat,cDesmembra,cLoteFor)) //FR 19/05/2020
	
    //incluido configuraçoes aba CTe - 27/04/2018
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Configurações CTe                                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cForceCte:= GetNewPar("XM_FORCET3","N")
	cCteDet  := GetNewPar("XM_CTE_DET","N")
	cCSol    := GetNewPar("XM_CSOL","A")
	cCCNfOr  := GetNewPar("XM_CCNFOR","N")
	cCteAvi	 :=	GetNewPar("XM_CTE_AVI","S")   //Jardel
	cAglCTE	 :=	SuperGetMv("XM_AGLMCTE",.T.,"N") // Incluido considerar Multiplos CTE - 31/05/2017
	cNfOri   := GetNewPar("XM_NFORI","N")
	cIcmCte  := GetNewPar("XM_ICMSCTE","S")
	cTpMCte  := GetNewPar("XM_TPMCTE","1")
	cBxCteT	 := GetNewPar("XM_BXCTETM", "N")

	@ 015,00.1 To 015.1,043.8 OF oPage:aDialogs[nPageCte]	//FR 19/05/2020
   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Linha 1                                                  ³
 	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//	@ 010,010 Say "Série Por Empresa:" PIXEL OF oPage:aDialogs[nPageGerII] COLOR CLR_BLUE FONT oFont01
//	@ 018,010 Get oSerEmp VAR cSerEmp SIZE 100,10 PIXEL OF oPage:aDialogs[nPageGerII]
	@ 010,010 Say "Força Tomador CT-e: "  PIXEL OF oPage:aDialogs[nPageCte] COLOR CLR_BLUE FONT oFont01
	@ 018,010 COMBOBOX oForceCte VAR cForceCte ITEMS aCombo9 SIZE 100,10 PIXEL OF oPage:aDialogs[nPageCte] 
    cTip := "Informe se força a busca pelo papel do tomador do CT-e." +CRLF
	cTip += "A Tag <TOMA3> define o papel do tomador."+CRLF
	cTip += "Habilitar esta opção faz com que seja buscado nos outros elementos do CT-e "+CRLF
	cTip += "quando o Tomador indicado pela TAG não for a empresa."
	oForceCte:cToolTip := cTip
	
 	@ 010,120 Say "Mostra Avisos CTE:"  PIXEL OF oPage:aDialogs[nPageCte] COLOR CLR_BLUE FONT oFont01
	@ 018,120 COMBOBOX oCteAvi VAR cCteAvi ITEMS aCombo2 SIZE 100,10 PIXEL OF oPage:aDialogs[nPageCte]
	cTip := "Mostrar Avisos de Inconsistencias dos detalhes" +CRLF
	cTip += "de CTE?"+CRLF
	cTip += "Exemplo CNPJ da Transportadora,NF não Encontrada."
	oCteAvi:cToolTip := cTip	

 	@ 010,230 Say "Detalhar Itens(NF) no CT-e:" PIXEL OF oPage:aDialogs[nPageCte] COLOR CLR_BLUE FONT oFont01
	@ 018,230 COMBOBOX oCteDet VAR cCteDet ITEMS aCombo2 SIZE 100,10 PIXEL OF oPage:aDialogs[nPageCte]
   	cTip := "Detalhar CT-e em itens as NFs que deram origem ao CT-e " +CRLF
	cTip += "conforme TAG <infNF> do remetente."
	oCteDet:cToolTip := cTip

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Linha 2                                                ³
 	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// 	@ 032,010 Say "Aglutina Multiplo CTE:"  PIXEL OF oPage:aDialogs[nPageCte] COLOR CLR_BLUE FONT oFont01
//	@ 040,010 COMBOBOX oAglCTE VAR cAglCTE ITEMS aCombo2 SIZE 100,10 PIXEL OF oPage:aDialogs[nPageCte]
	@ 032,010 Say "NF Entr. Origem L.Fiscais? (CT-e):"  PIXEL OF oPage:aDialogs[nPageCte] COLOR CLR_BLUE FONT oFont01
	@ 040,010 COMBOBOX oNfOri VAR cNfOri ITEMS aCombo2 SIZE 100,10 PIXEL OF oPage:aDialogs[nPageCte]
   	cTip := "Se SIM Busca Notas Entrada p/ Origem nos Livros Fiscais (SF3)." +CRLF
	cTip += "Se NÃO Busca Notas Saida p/ Origem (SF2). Para detalhes CT-e." +CRLF
	cTip += "Obs: Ao Selecionar o tipo de pré-nota Nt Conhec Frete será " +CRLF
	cTip += "     assumido como SIM, pois a rotina padrão assim o exige."
	oNfOri:cToolTip := cTip
	
 	@ 032,120 Say "De onde amarra Centro Custo?:" PIXEL OF oPage:aDialogs[nPageCte] COLOR CLR_BLUE FONT oFont01
	@ 040,120 COMBOBOX oCSol VAR cCSol ITEMS aCombo10 SIZE 100,10 PIXEL OF oPage:aDialogs[nPageCte]
   	cTip := "Se S=Pedido: utiliza Centro de Custo do Pedido Compra através de F5 ou F6." +CRLF
	cTip += "Se N=C.Prod: utiliza Centro de Custo do Cadastro de Produto."+CRLF
	cTip += "Se Z=Não utiliza Centro de Custo ao preencher os Itens da Pré-Nota."+CRLF
	cTip += "Se A=Ambos: utiliza do Cad.Produto ao gerar a Pré-Nota e do Pedido"+CRLF
	cTip += "ao Seleciona-lo com as Teclas F5 ou F6."
	oCSol:cToolTip := cTip

 	@ 032,230 Say "(CTe) C.C. NF Origem?:" PIXEL OF oPage:aDialogs[nPageCte] COLOR CLR_BLUE FONT oFont01
	@ 040,230 COMBOBOX oCCNfOr VAR cCCNfOr ITEMS aCombo2 SIZE 100,10 PIXEL OF oPage:aDialogs[nPageCte]
   	cTip := "Para CTE amarrar centro de custo pela" +CRLF
	cTip += "NF de origem do CT-e"
	oCCNfOr:cToolTip := cTip
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Linha 3                                                ³
 	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 	@ 054,010 Say "Aglutina Multiplo CTE:"  PIXEL OF oPage:aDialogs[nPageCte] COLOR CLR_BLUE FONT oFont01
	@ 062,010 COMBOBOX oAglCTE VAR cAglCTE ITEMS aCombo2 SIZE 100,10 PIXEL OF oPage:aDialogs[nPageCte]
	cTip := "Aglutina varios CTE's em um só pre nota" +CRLF
	cTip += "lancamentos fiscais unico?"+CRLF
	cTip += "Exemplo varios CTE para uma mesma Transportadora."
	oAglCTE:cToolTip := cTip


 	@ 054,120 Say "Considera ICMS no CTE:"  PIXEL OF oPage:aDialogs[nPageCte] COLOR CLR_BLUE FONT oFont01
	@ 062,120 COMBOBOX oIcmCTE VAR cIcmCte ITEMS aCombo2 SIZE 100,10 PIXEL OF oPage:aDialogs[nPageCte]
	cTip := "Considerar ICMS no CTE?" +CRLF
	cTip += "S->Ira preencher os campos D1_BASEICM de acordo"+CRLF
	cTip += "com as TAGs <ICMS00><VBC> ou <ICMS20><VBC>."
	oIcmCTE:cToolTip := cTip

 	@ 054,230 Say "Tipo do Multiplo CTE:"  PIXEL OF oPage:aDialogs[nPageCte] COLOR CLR_BLUE FONT oFont01
	@ 062,230 COMBOBOX oTpMCte VAR cTpMCte ITEMS aCombo21 SIZE 100,10 PIXEL OF oPage:aDialogs[nPageCte]
	cTip := "Na rotina multiplo CTE:" +CRLF
	cTip += "1-Monta a Tela com os CTes do Fornecedor Selecionado;"+CRLF
	cTip += "2-Monta a Tela com os CTes a ser importado de uma pasta de usuário;"+CRLF
	cTip += "3-Ambos, Mostra pergunta para escolher na hora qual opção utilizar."
	oTpMCte:cToolTip := cTip
	
	@ 074,010 Say "Baixar Somente CTE Tomador:"  PIXEL OF oPage:aDialogs[nPageCte] COLOR CLR_BLUE FONT oFont01
	@ 082,010 COMBOBOX oBxCteT VAR cBxCteT ITEMS aCombo2 SIZE 100,10 PIXEL OF oPage:aDialogs[nPageCte]
	cTip := "Caso esteja SIM, o sistema irá baixar apenas CTE quando o tomador" +CRLF
	cTip += "seja o mesmo cnpj da empresa.  Obs.: Apenas CTE"
	oBxCteT:cToolTip := cTip
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Linha 4                                                ³
 	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//	@ 076,010 Say "Manifestação ao gerar pré-nota:" PIXEL OF oPage:aDialogs[nPageGerII] COLOR CLR_BLUE FONT oFont01
//	@ 084,010 COMBOBOX oManPre VAR cManPre ITEMS aCombo15 SIZE 100,10 PIXEL OF oPage:aDialogs[nPageGerII]

 	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Linha 5                                                  ³
 	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
    
//    @ 098,010 Say "Formato Serie [NF-e]:" PIXEL OF oPage:aDialogs[nPageGerII] COLOR CLR_BLUE FONT oFont01
//	@ 106,010 COMBOBOX oFormSer VAR _cFormSer ITEMS aCombo16 SIZE 100,10 PIXEL OF oPage:aDialogs[nPageGerII]


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Linha 6                                                  ³
 	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// 	@ 120,010 Say "Mostra Avisos CTE:"  PIXEL OF oPage:aDialogs[nPageCte] COLOR CLR_BLUE FONT oFont01
//	@ 128,010 COMBOBOX oCteAvi VAR cCteAvi ITEMS aCombo2 SIZE 100,10 PIXEL OF oPage:aDialogs[nPageCte]

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Linha 7                                                 ³
 	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//	@ 142,010 Say "NF Entr. Origem L.Fiscais? (CT-e):"  PIXEL OF oPage:aDialogs[nPageCte] COLOR CLR_BLUE FONT oFont01
//	@ 150,010 COMBOBOX oNfOri VAR cNfOri ITEMS aCombo2 SIZE 100,10 PIXEL OF oPage:aDialogs[nPageCte]

	@ 190,300 Button "Salvar" Size 040,015 PIXEL OF oPage:aDialogs[nPageCte] ACTION (SetCfgCte(cForceCte,cCteDet,cCSol,cCCNfOr,cCteAvi,cAglCTE,cNfOri,cIcmCte,cTpMCte,cBxCteT))  //FR 19/05/2020

	//=================================================================================//
	//FR - 14/11/2022 - PROJETO COPAG VALIDAÇÃO SEFAZ AMAZONAS - Nova aba: Fiscais
	//=================================================================================//

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	// Fiscais                                                                
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 015,00.1 To 015.1,043.8 OF oPage:aDialogs[nPageFisc]	

	cCfExSped   := Padr(GetNewPar("XM_CFEXSPD",Space(256)),256)  //Cfops exceção ao SPED
	cSpedFisc   := GetNewPar("XM_SPEDFIS","N")
	cCfDevol 	:= Padr(GetNewPar("XM_CFDEVOL",Space(256)),256)
	cCfBenef 	:= Padr(GetNewPar("XM_CFBENEF",Space(256)),256)
	cCfTrans	:= Padr(GetNewPar("XM_CFTRANS",Space(256)),256)
	cCfCompl	:= Padr(GetNewPar("XM_CFCOMPL",Space(256)),256) // Erick Gonça - Melhoria - CFOP de Complemento.
	cCfVenda	:= Padr(GetNewPar("XM_CFVENDA",Space(256)),256)
	cCfRemes	:= Padr(GetNewPar("XM_CFREMES",Space(256)),256)
	cCfBonif	:= Padr(GetNewPar("XM_CFBONIF",Space(256)),256)	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Linha 1                                                  ³
 	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 010,010 Say "CFOP Devolução: "  PIXEL OF oPage:aDialogs[nPageFisc] COLOR CLR_BLUE FONT oFont01
	@ 018,010 Get oCfDevol VAR cCfDevol SIZE 100,08 PIXEL OF oPage:aDialogs[nPageFisc]                    
    cTip := "Informe os CFOPs utilizados para entrada de devolução." +CRLF
	cTip += "Deve-se informar os códigos separados por ';'"+CRLF
	cTip += "Exemplo 5959;5949;6959;6949 ."
	oCfDevol:cToolTip := cTip	
	
	@ 010,120 Say "CFOP's Exceção SPED: "  PIXEL OF oPage:aDialogs[nPageFisc] COLOR CLR_BLUE FONT oFont01	
    @ 018,120 Get oCfExSped VAR cCfExSped SIZE 100,08 PIXEL OF oPage:aDialogs[nPageFisc]                    
    cTip := "Os CFOPs informados neste campo significa que notas fiscais" + CRLF
	cTip += "que contém estes CFOPs, não serão enviadas no Sped buscando informações do xml."+CRLF
	cTip += "Exemplo 5959;5949;6959;6949." + CRLF
	oCfExSped:cToolTip := cTip

	@ 010,230 Say "Sped Fiscal ?" PIXEL OF oPage:aDialogs[nPageFisc] COLOR CLR_BLUE FONT oFont01 
	@ 018,230 COMBOBOX  oSpedFisc VAR cSpedFisc ITEMS aCombo1 SIZE 100,10 PIXEL OF oPage:aDialogs[nPageFisc]                  
  	cTip := "Caso este parâmetro esteja habilitado (Sim)," + CRLF
	cTip += "o relatório irá apresentar críticas relacionados ao sped fiscal."+CRLF
	cTip += "Opções:"+CRLF
	cTip += "Sim - Habilita Críticas no Relatório de Pré-Auditoria Fiscal"+CRLF
	cTip += "Não - Desabilita Crtíticas no Relatório de Pré-Auditoria Fiscal"
	oSpedFisc:cToolTip := cTip 
	
	@ 032,010 Say "CFOP Beneficiamento: "  PIXEL OF oPage:aDialogs[nPageFisc] COLOR CLR_BLUE FONT oFont01
	@ 040,010 Get oCfBenef VAR cCfBenef SIZE 100,08 PIXEL OF oPage:aDialogs[nPageFisc]           
	cTip := "Informe os CFOPs utilizados para entrada de beneficiamento." +CRLF
	cTip += "Deve-se informar os códigos separados por ';'"+CRLF
	cTip += "Exemplo 5959;5949;6959;6949 ."
	oCfBenef:cToolTip := cTip
	
	@ 032,120 Say "CFOP Transfêrencia: "  PIXEL OF oPage:aDialogs[nPageFisc] COLOR CLR_BLUE FONT oFont01
	@ 040,120 Get oCfTrans VAR cCfTrans SIZE 100,08 PIXEL OF oPage:aDialogs[nPageFisc]           
	cTip := "Informe os CFOPs utilizados para entrada de transferencia." +CRLF
	cTip += "Deve-se informar os códigos separados por ';'"+CRLF
	cTip += "Exemplo 5959;5949;6959;6949 ."
	oCfTrans:cToolTip := cTip	
	
	@ 032,230 Say "CFOP Complemento: "  PIXEL OF oPage:aDialogs[nPageFisc] COLOR CLR_BLUE FONT oFont01
	@ 040,230 Get oCfCompl VAR cCfCompl SIZE 100,08 PIXEL OF oPage:aDialogs[nPageFisc]           
	cTip := "Informe os CFOPs utilizados para entrada de complemento." +CRLF
	cTip += "Deve-se informar os códigos separados por ';'"+CRLF
	cTip += "Exemplo 5959;5949;6959;6949 ."
	oCfCompl:cToolTip := cTip
	
	@ 054,010 Say "CFOP Vendas: "  PIXEL OF oPage:aDialogs[nPageFisc] COLOR CLR_BLUE FONT oFont01
	@ 062,010 Get oCfVenda VAR cCfVenda SIZE 100,08 PIXEL OF oPage:aDialogs[nPageFisc]           
	cTip := "Informe os CFOPs utilizados para vendas." +CRLF
	cTip += "Deve-se informar os códigos separados por ';'"+CRLF
	cTip += "Exemplo 5959;5949;6959;6949 ."
	oCfVenda:cToolTip := cTip

	@ 054,120 Say "CFOP Remessa: "  PIXEL OF oPage:aDialogs[nPageFisc] COLOR CLR_BLUE FONT oFont01
	@ 062,120 Get oCfRemes VAR cCfRemes SIZE 100,08 PIXEL OF oPage:aDialogs[nPageFisc]           
	cTip := "Informe os CFOPs utilizados para Remessa." +CRLF
	cTip += "Deve-se informar os códigos separados por ';'"+CRLF
	cTip += "Exemplo 5959;5949;6959;6949 ."
	oCfRemes:cToolTip := cTip
	
	@ 054,230 Say "CFOP Bonificação: "  PIXEL OF oPage:aDialogs[nPageFisc] COLOR CLR_BLUE FONT oFont01
	@ 062,230 Get oCfBonif VAR cCfBonif SIZE 100,08 PIXEL OF oPage:aDialogs[nPageFisc]           
	cTip := "Informe os CFOPs utilizados para entrada de Bonificação." +CRLF
	cTip += "Deve-se informar os códigos separados por ';'"+CRLF
	cTip += "Exemplo 5959;5949;6959;6949 ."
	oCfBonif:cToolTip := cTip
	
	@ 190,300 Button "Salvar" Size 040,015 PIXEL OF oPage:aDialogs[nPageFisc] ACTION (SetCfgFisc(cCfExSped,cSpedFisc,cCfDevol,cCfBenef,cCfTrans,cCfCompl,cCfVenda,cCfRemes,cCfBonif))  

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Configurações Integração Externa                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cItAtFTP := Padr(GetNewPar("XM_ITATFTP",Space(256)),256)
	cItAtPOR := Padr(GetNewPar("XM_ITATPOR",Space(10)),10)
	cItAtLOG := Padr(GetNewPar("XM_ITATLOG",Space(256)),256)
	cItAtPAS := Padr(Decode64(GetNewPar("XM_ITATPAS",Space(50))),50)  //Padr(GetNewPar("XM_ITATPAS",Space(256)),256)
	cItAtDIR := Padr(GetNewPar("XM_ITATDIR",Space(256)),256)
	cItAtPRT := GetNewPar("XM_ITATPRT","1")
	cItAtJob := GetNewPar("XM_ITATJOB","0")
	cItAtDia := Padr(GetNewPar("XM_ITATDIA",Space(256)),256)
	cItAtMes := Padr(GetNewPar("XM_ITATMES",Space(256)),256)
	cItAtAnC := Padr(GetNewPar("XM_ITATANC",Space(7)),7)
	cItAtHrC := Padr(GetNewPar("XM_ITATHRC",Space(5)),5)
	cItSleep := GetNewPar("XM_ITSLEEP",10)		//FR - 17/07/2020

	@ 015,00.1 To 015.1,043.8 OF oPage:aDialogs[nPageInExt]	//FR 19/05/2020

 	@ 010,010 Say "Caminho SFTP:"  PIXEL OF oPage:aDialogs[nPageInExt] COLOR CLR_BLUE FONT oFont01			//FR - 17/07/2020
	@ 018,010 GET oItAtFTP VAR cItAtFTP SIZE 100,10 PIXEL OF oPage:aDialogs[nPageInExt]
	cTip := "Caminho ( URL ) para acessar" +CRLF
	cTip += "o FTP da Ticket."
	oItAtFTP:cToolTip := cTip

 	@ 010,120 Say "Nome Usuário SFTP:"  PIXEL OF oPage:aDialogs[nPageInExt] COLOR CLR_BLUE FONT oFont01		//FR - 17/07/2020
	@ 018,120 GET oItAtLOG VAR cItAtLOG SIZE 100,10 PIXEL OF oPage:aDialogs[nPageInExt]
	cTip := "Login (usuario) para acessar" +CRLF
	cTip += "o FTP da Ticket."
	oItAtLOG:cToolTip := cTip

 	@ 010,230 Say "Senha SFTP:"  PIXEL OF oPage:aDialogs[nPageInExt] COLOR CLR_BLUE FONT oFont01			//FR - 17/07/2020
	@ 018,230 GET oItAtPAS VAR cItAtPAS SIZE 100,08 PIXEL OF oPage:aDialogs[nPageInExt] PASSWORD
	cTip := "Login (senha) para acessar" +CRLF
	cTip += "o FTP da Ticket."
	oItAtPAS:cToolTip := cTip

 	@ 032,010 Say "Porta SFTP:"  PIXEL OF oPage:aDialogs[nPageInExt] COLOR CLR_BLUE FONT oFont01			//FR - 17/07/2020
	@ 040,010 GET oItAtPOR VAR cItAtPOR SIZE 100,10 PIXEL OF oPage:aDialogs[nPageInExt]
	cTip := "Caminho (PORTA) para acessar" +CRLF
	cTip += "o SFTP da Ticket. Padrão é 21."																//FR - 17/07/2020
	oItAtPOR:cToolTip := cTip

 	@ 032,120 Say "Diretório SFTP:"  PIXEL OF oPage:aDialogs[nPageInExt] COLOR CLR_BLUE FONT oFont01		//FR - 17/07/2020
	@ 040,120 GET oItAtDIR VAR cItAtDIR SIZE 100,10 PIXEL OF oPage:aDialogs[nPageInExt]
	cTip := "Diretório onde estão os arquivos no SFTP." +CRLF
	cTip += "Utilizar (/). Deixar vazio caso seja o Raiz."
	oItAtDIR:cToolTip := cTip

 	@ 032,230 Say "Protocolo SFTP:"  PIXEL OF oPage:aDialogs[nPageInExt] COLOR CLR_BLUE FONT oFont01		//FR - 17/07/2020
	@ 040,230 COMBOBOX oItAtPRT VAR cItAtPRT ITEMS aCombo19 SIZE 100,10 PIXEL OF oPage:aDialogs[nPageInExt]
	cTip := "Protocolo SFTP." +CRLF
	cTip += "1 - FTP " +CRLF
	cTip += "2 - SFTP"
	oItAtPRT:cToolTip := cTip

 	@ 054,010 Say "Agendamento Robótica :"  PIXEL OF oPage:aDialogs[nPageInExt] COLOR CLR_BLUE FONT oFont01
	@ 062,010 COMBOBOX oItAtJob VAR cItAtJob ITEMS aCombo SIZE 100,10 PIXEL OF oPage:aDialogs[nPageInExt]
	cTip := "Habilita ou desabilita robô para rodar " +CRLF
	cTip += "a integração de forma Robótica."
	oItAtJob:cToolTip := cTip

	@ 053,118 to 063,260 OF oPage:aDialogs[nPageInExt]    
	@ 054,120 Say "Dias da Semana" PIXEL OF oPage:aDialogs[nPageInExt] COLOR CLR_BLUE FONT oFont01
	@ 062,120 Get oItAtDia VAR cItAtDia SIZE 090,08 PIXEL OF oPage:aDialogs[nPageInExt] READONLY                  
	@ 062,210 Button "..." Size 010,011 PIXEL OF oPage:aDialogs[nPageInExt] ACTION (cItAtDia:=U_HFDiaSem(cItAtDia))
	cTip := "Informar Dia da Semana em que rodará" +CRLF
	cTip += "a integração de forma Robótica."
	oItAtDia:cToolTip := cTip


	@ 053,118 to 063,260 OF oPage:aDialogs[nPageInExt]    
	@ 054,230 Say "Mês" PIXEL OF oPage:aDialogs[nPageInExt] COLOR CLR_BLUE FONT oFont01
	@ 062,230 Get oItAtMes VAR cItAtMes SIZE 090,08 PIXEL OF oPage:aDialogs[nPageInExt] READONLY
	@ 062,320 Button "..." Size 010,011 PIXEL OF oPage:aDialogs[nPageInExt] ACTION (cItAtMes:=U_HFMes(cItAtMes))
	cTip := "Possível Informar Mês em que rodará" +CRLF
	cTip += "a integração de forma Robótica."
	oItAtMes:cToolTip := cTip


	@ 076,010 Say "Ano/Mês: " PIXEL OF oPage:aDialogs[nPageInExt] COLOR CLR_BLUE FONT oFont01
	@ 084,010 Get oItAtAnC VAR cItAtAnC SIZE 30,10  PICTURE "@E 9999/99" PIXEL OF oPage:aDialogs[nPageInExt]               
	cTip := "Possivel informar Ano e Mês da" +CRLF
	cTip += "Integração de forma Robótica."
	oItAtAnC:cToolTip := cTip

	@ 076,120 Say "Hora Execução: " PIXEL OF oPage:aDialogs[nPageInExt] COLOR CLR_BLUE FONT oFont01
	@ 084,120 Get oItAtHrC VAR cItAtHrC SIZE 30,10  PICTURE "@E 99:99" PIXEL OF oPage:aDialogs[nPageInExt]
	cTip := "Possivel informar hora de inicio da" +CRLF
	cTip += "inicializção da integração de forma Robótica."
	oItAtHrC:cToolTip := cTip


	@ 190,300 Button "Salvar" Size 040,015 PIXEL OF oPage:aDialogs[nPageInExt] ACTION (SetCfgInt(cItAtFTP,cItAtLOG,cItAtPAS,cItAtJob,cItAtDia,cItAtMes,cItAtAnC,cItAtHrC,cItAtPOR,cItAtDIR,cItAtPRT))  //FR 19/05/2020


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Configurações Classificação Robótica                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cClAt    := GetNewPar("XM_CLAT"   ,"N") 
	cClAtRBT := GetNewPar("XM_CLATRBT","1") 		//FR - 27/11/19- novo parâmetro indicando o tipo da robotização para classificação Robótica
	cTESNFE  := Padr(GetNewPar("XM_NFE_TES",Space(3)),3)
	cTESCTE  := Padr(GetNewPar("XM_CTE_TES",Space(3)),3)
	cClAtJob := GetNewPar("XM_CLATJOB","0")
	cClAtDia := Padr(GetNewPar("XM_CLATDIA",Space(256)),256)
	cClAtMes := Padr(GetNewPar("XM_CLATMES",Space(256)),256)
	cClAtAnC := Padr(GetNewPar("XM_CLATANC",Space(7)),7)
	cClAtHrC := Padr(GetNewPar("XM_CLATHRC",Space(5)),5)
	cClAtpClass := GetNewPar("XM_CLATPNF","C")
	cAutoZBC    := GetNewPar("XM_ZBCAUTO" , "N") 				//FR - 28/10/2021
	cTESZBC     := Padr(GetNewPar("XM_ZBCTES"  , Space(3) ) ,3) 	//FR - 28/10/2021
	cCCZBC      := Padr(GetNewPar("XM_ZBCCC"   , Space(10)),10) //FR - 28/10/2021
	cCondZBC    := Padr(GetNewPar("XM_ZBCCOND" , Space(3) ) ,3)	//FR - 28/10/2021
	//----------------------------------------------------------------------------------------------------------------//
	//Alteração:
	//FR - 05/08/2022 - PROJETO POLITEC
	//----------------------------------------------------------------------------------------------------------------//
	cCfopComb  := Padr(GetNewPar("XM_CFOCOMB" , Space(256)),256) 	//FR - 05/08/2022 - PROJETO POLITEC

	@ 015,00.1 To 015.1,043.8 OF oPage:aDialogs[nPageClaut]	//FR 19/05/2020
	
	@ 010,010 Say "Robotização NF: "  PIXEL OF oPage:aDialogs[nPageClAut] COLOR CLR_BLUE FONT oFont01		
	@ 018,010 COMBOBOX oClAt VAR cClAt ITEMS aCombo2 SIZE 100,10 PIXEL OF oPage:aDialogs[nPageClAut]
	cTip := "Irá Classificar as notas de Combustível de forma Robótica " +CRLF
	cTip += "obedecendo as regras do cadastro de Classificão Robótica "+CRLF
	cTip += "de Nota Fiscal."		
	oClAt:cToolTip := cTip
	
	//FR - 27/11/19:
	@ 010,120 Say "Tipos Robotização NF: "  PIXEL OF oPage:aDialogs[nPageClAut] COLOR CLR_BLUE FONT oFont01  //FR - 19/06/2020 - TÓPICOS RAFAEL
	@ 018,120 COMBOBOX oClAtRBT VAR cClAtRBT ITEMS aCombo25 SIZE 100,10 PIXEL OF oPage:aDialogs[nPageClAut] VALID fTemX6(cClAtRBT,cTESNFE,cTESCTE,.T.)	
    	cTip := "Indica a regra a ser utilizada para Classificar as notas de forma Robótica: " +CRLF
    	cTip += "1=Pergunta Múltiplos: Sistema irá perguntar se deseja incluir pre-Nota ou Nota fiscal de Entrada;" + CRLF
	cTip += "2=Múltiplos NFE e CTE: Sistema irá abrir a tela p/ usuário informar a TES sem perguntar;" + CRLF
	cTip += "3=CTE: Sistema irá selecionar qual TES está informado no parâmetro XM_CTE_TES ou XM_NFE_TES para classificar Robótica sem perguntar;"+CRLF
	cTip += "Se o parâmetro XM_CTE_TES ou XM_NFE_TES estiver vazio, não será possível selecionar opção 3;" + CRLF
	cTip += "4=Utiliza TES do Cad.Produto;"+CRLF
	cTip += "5=Não Utilizado."
		
	oClAtRBT:cToolTip := cTip			

	@ 010,230 Say "Agendamento Robótico :"  PIXEL OF oPage:aDialogs[nPageClAut] COLOR CLR_BLUE FONT oFont01
	@ 018,230 COMBOBOX oClAtJob VAR cClAtJob ITEMS aCombo SIZE 100,10 PIXEL OF oPage:aDialogs[nPageClAut]
	cTip := "Habilita ou desabilita robô para rodar " +CRLF
	cTip += "a rotina de forma Robótica."
	oClAtJob:cToolTip := cTip		

	@ 031,008 Say "Dias da Semana" PIXEL OF oPage:aDialogs[nPageClAut] COLOR CLR_BLUE FONT oFont01
	@ 039,010 Get oClAtDia VAR cClAtDia SIZE 090,08 PIXEL OF oPage:aDialogs[nPageClAut] READONLY                  
	@ 039,100 Button "..." Size 010,011 PIXEL OF oPage:aDialogs[nPageClAut] ACTION (cClAtDia:=U_HFDiaSem(cClAtDia))
	cTip := "Informar Dia da Semana em que rodará" +CRLF
	cTip += "a classificação de forma Robótica."
	oClAtDia:cToolTip := cTip	
	
	@ 032,120 Say "Mês" PIXEL OF oPage:aDialogs[nPageClAut] COLOR CLR_BLUE FONT oFont01
	@ 040,120 Get oClAtMes VAR cClAtMes  SIZE 090,08 PIXEL OF oPage:aDialogs[nPageClAut] READONLY
	@ 040,210 Button "..." Size 010,011 PIXEL OF oPage:aDialogs[nPageClAut] ACTION (cClAtMes:=U_HFMes(cClAtMes))
	cTip := "Possível Informar Mês em que rodará" +CRLF
	cTip += "a classificação de forma Robótica."
	oClAtMes:cToolTip := cTip	
	
	@ 032,230 Say "Ano/Mês: " PIXEL OF oPage:aDialogs[nPageClAut] COLOR CLR_BLUE FONT oFont01
	@ 040,230 Get oClAtAnC VAR cClAtAnC SIZE 30,10  PICTURE "@E 9999/99" PIXEL OF oPage:aDialogs[nPageClAut]               
	cTip := "Possivel informar Ano e Mês da" +CRLF
	cTip += "classificação de forma Robótica."
	oClAtAnC:cToolTip := cTip	
	
	@ 054,008 Say "Hora Execução: " PIXEL OF oPage:aDialogs[nPageClAut] COLOR CLR_BLUE FONT oFont01
	@ 062,010 Get oClAtHrC VAR cClAtHrC SIZE 30,10  PICTURE "@E 99:99" PIXEL OF oPage:aDialogs[nPageClAut]
	cTip := "Possivel informar hora de inicio da" +CRLF
	cTip += "inicialização da classificação de forma Robótica."
	oClAtHrC:cToolTip := cTip
			
	@ 054,120 Say "TES Robótica NFE: " PIXEL OF oPage:aDialogs[nPageClAut] COLOR CLR_BLUE FONT oFont01
	@ 062,120 Get oClAtTESNFE VAR cTESNFE SIZE 30,10  PICTURE "@ XXX" PIXEL OF oPage:aDialogs[nPageClAut] //VALID fTemX6(cClAtRBT,cTESNFE,,.F.) /*F3 "SF4"*/  
	cTip := "Informe o código do TES para classificação Robótica de NFE." +CRLF
	oClAtTESNFE:cToolTip := cTip
	
	@ 054,230 Say "TES Robótica CTE: " PIXEL OF oPage:aDialogs[nPageClAut] COLOR CLR_BLUE FONT oFont01
	@ 062,230 Get oClAtTESCTE VAR cTESCTE SIZE 30,10   PICTURE "@ XXX" PIXEL OF oPage:aDialogs[nPageClAut] //VALID fTemX6(cClAtRBT,,cTESCTE,.F.)
	cTip := "Informe o código do TES para classificação Robótica de CTE." +CRLF
	oClAtTESCTE:cToolTip := cTip
	
	//----------------------------------------------------------------------------------------------------------------//
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
	//----------------------------------------------------------------------------------------------------------------//	
	@ 078,010 Say "Tipos NF p/ Robotização: " PIXEL OF oPage:aDialogs[nPageClAut]  COLOR CLR_BLUE FONT oFont01
	@ 086,010 COMBOBOX oTpClass VAR cClAtpClass ITEMS aCombo27 SIZE 100,10 PIXEL OF oPage:aDialogs[nPageClAut]
	cTip := "Tipos de Classificação Robótica:" +CRLF
	cTip += "C - Notas de Combustíveis + Audit Terc " +CRLF
	cTip += "C1- Notas de Combustíveis via XML " +CRLF
	cTip += "E - Notas de Energia"       +CRLF
	cTip += "T - Todas as Notas"         +CRLF
	cTip += "N - Nenhum"         
	oTpClass:cToolTip := cTip		
		
	//FR - 28/10/2021
	@ 078,120 Say "Amarração Robótica?" PIXEL OF oPage:aDialogs[nPageClAut] COLOR CLR_BLUE FONT oFont01
	@ 086,120 COMBOBOX oZBCAut VAR cAutoZBC ITEMS aCombo26 SIZE 100,08  PIXEL OF oPage:aDialogs[nPageClAut] 
	cTip := "Informe se o cadastro de amarração ('ZBC') p/ classificação Robótica será automatizado." +CRLF
	oZBCAut:cToolTip := cTip

	//cTESZBC     := GetNewPar("XM_ZBCTES"  , "") //FR - 28/10/2021
	//cCCZBC     := GetNewPar("XM_ZBCCC"    , "") //FR - 28/10/2021

	@ 102,120 Say "TES Amarr. Robótica: " PIXEL OF oPage:aDialogs[nPageClAut] COLOR CLR_BLUE FONT oFont01
	@ 110,120 MSGet oClATESZBC VAR cTESZBC F3 "SF4" SIZE 30,10 OF oPage:aDialogs[nPageClAut]  F3 "SF4" PIXEL
	cTip := "Informe o código do TES para Amarração Robótica 'ZBC' " +CRLF
	oClATESZBC:cToolTip := cTip

	@ 124,120 Say "C.Custo Amarr. Robot.: " PIXEL OF oPage:aDialogs[nPageClAut] COLOR CLR_BLUE FONT oFont01
	@ 132,120 MSGet oClACCZBC VAR cCCZBC F3 "CTT" SIZE 80,10 OF oPage:aDialogs[nPageClAut]  F3 "CTT" PIXEL
	cTip := "Informe o código do C.Custo para Amarração Robótica 'ZBC' " +CRLF
	oClACCZBC:cToolTip := cTip

	//----------------------------------------------------------------------------------------------------------------//
	//Alteração:
	//FR - 05/08/2022 - PROJETO POLITEC
	//----------------------------------------------------------------------------------------------------------------//
	@ 146,010 Say "CFOP NF Combustivel: " PIXEL OF oPage:aDialogs[nPageClAut]  COLOR CLR_BLUE FONT oFont01
	@ 154,010 MsGet oCfopClass VAR cCfopComb SIZE 100,10 PIXEL OF oPage:aDialogs[nPageClAut]	 
	cTip := "Informe os CFOPs das NF Combustívels que serão classifidadas via XML" +CRLF
	oCfopClass:cToolTip := cTip		
	
	//cCondZBC    := Padr(GetNewPar("XM_ZBCCOND" , Space(3))),3)	//FR - 28/10/2021
	@ 146,120 Say "Cond.Pagto Amarr. Robot.: " PIXEL OF oPage:aDialogs[nPageClAut] COLOR CLR_BLUE FONT oFont01
	@ 154,120 MSGet oClASE4ZBC VAR cCondZBC F3 "SE4" SIZE 30,10 OF oPage:aDialogs[nPageClAut]  F3 "SE4" PIXEL
	cTip := "Informe o código da Cond.Pagto para Amarração Robótica 'ZBC' " +CRLF
	oClASE4ZBC:cToolTip := cTip
		
	@ 190,300 Button "Salvar" Size 040,015 PIXEL OF oPage:aDialogs[nPageClAut] ACTION (SetCfgClA(cClAt,cClAtJob,cClAtDia,cClAtMes,cClAtAnC,cClAtHrC,cClAtRBT,cTESNFE,cTESCTE,cClAtpClass,cAutoZBC,cTESZBC,cCCZBC,cCondZBC,cCfopComb))  //FR 22/09/2020


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Configurações NFS-e                                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 015,00.1 To 015.1,043.8 OF oPage:aDialogs[nPageNfs]	//FR 19/05/2020

	cGrvNfse := GetNewPar("XM_GRVNFSE","N")
	cUsaNfse := GetNewPar("XM_USANFSE","N")
	//cSerNfse := GetNewPar("XM_SER_NFS","")
	cSerNfse := GetNewPar("XM_SER_NFS",Space(3))		//FR - 20/04/2022 - #12482 - JOHNSON - Alteração aumentar campo série nfs
	cVezNfse :=	GetNewPar("XM_VEZDIA","0")
	If Empty(cSerNfse)
		cSerNfse := Space(3)
	Endif 
	cEspNfe  := Padr(GetNewPar("XM_ESP_NFS","NFS"),5) // NFCE_03 16/05
	cPRODNFS := Padr(GetNewPar("XM_PRODNFS","SERVICO"),nTamProd)
	cArqTxt  := Padr(GetNewPar("XM_ARQ_NFS","NFSE"),200) // NFCE_03 16/05
	cDiasNfse:= Padr(GetNewPar("XM_QTDIMC","90"),5) // NFCE_03 16/05

	@ 010,010 Say "Utiliza NFS-e:" PIXEL OF oPage:aDialogs[nPageNfs] COLOR CLR_BLUE FONT oFont01
	@ 018,010 COMBOBOX oUsaNfse VAR cUsaNfse ITEMS aCombo24 SIZE 100,10 PIXEL OF oPage:aDialogs[nPageNfs]
   	cTip := "Utiliza Nota Fiscal de Serviço via texto/pdf?" +CRLF
   	cTip += "Pdf será a NF de serviço em PDF e texto será" +CRLF
   	cTip += "a partir do layout de exportação da cidade." +CRLF
   	cTip += "Somente das cidades homologadas." +CRLF
   	cTip += "S - Utiliza Image Converter" +CRLF
   	cTip += "N - Não Utiliza"
	oUsaNfse:cToolTip := cTip

	@ 010,120 Say "Espécie NFS-e:" PIXEL OF oPage:aDialogs[nPageNfs] COLOR CLR_BLUE FONT oFont01
	@ 018,120 Get oEspNfe VAR cEspNfe SIZE 100,10 PIXEL OF oPage:aDialogs[nPageNfs]
   	cTip := "Espécie para geração NFS-e" +CRLF
   	cTip += "Ex: NFS" 
	oEspNfe:cToolTip := cTip

	@ 010,230 Say "Produto Serviço: " PIXEL OF oPage:aDialogs[nPageNfs] COLOR CLR_BLUE FONT oFont01 
	@ 018,230 Get oPRODNFS VAR cPRODNFS SIZE 100,10 PIXEL OF oPage:aDialogs[nPageNfs]                  
   	cTip := "Código Padrão do Produto de Serviço" +CRLF
   	cTip += "do Fornecedor para fazer a amarração."
	oPRODNFS:cToolTip := cTip

 	@ 032,010 Say "Extensão Arq. TXT:"  PIXEL OF oPage:aDialogs[nPageNfs] COLOR CLR_BLUE FONT oFont01
	@ 040,010 Get oArqTxt VAR cArqTxt SIZE 100,08 PIXEL OF oPage:aDialogs[nPageNfs]
   	cTip := "Extensão do arquivo texto que contém" +CRLF
   	cTip += "as NFSe. Pode ter mais de uma." +CRLF
   	cTip += "Ex: nfse;nfs;txt" +CRLF
   	cTip += "Obs: Não utilize as extensões xml/pdf."
	oArqTxt:cToolTip := cTip

	@ 032,120 Say "Grava NFS-e Localmente:" PIXEL OF oPage:aDialogs[nPageNfs] COLOR CLR_BLUE FONT oFont01
	@ 040,120 COMBOBOX oGrvNfse VAR cGrvNfse ITEMS aCombo2 SIZE 100,10 PIXEL OF oPage:aDialogs[nPageNfs]
   	cTip := "Define se será necessário gravar os PDFs" +CRLF
   	cTip += "enviados ao image converter" +CRLF
   	cTip += "S - Sim" +CRLF
   	cTip += "N - Não"
	oGrvNfse:cToolTip := cTip

	@ 032,230 Say "Dias Monitoramento:" PIXEL OF oPage:aDialogs[nPageNfs] COLOR CLR_BLUE FONT oFont01
	@ 040,230 Get oDiasNfse VAR cDiasNfse SIZE 100,10 PIXEL OF oPage:aDialogs[nPageNfs]
   	cTip := "Informe a quantidade de dias " +CRLF
   	cTip := "para monitoramento do image converter. " +CRLF
	cTip := "Qualquer numero acima de 90 será considerado 90" +CRLF
	oDiasNfse:cToolTip := cTip
	@ 054,010 Say "Serie NFS-e:" PIXEL OF oPage:aDialogs[nPageNfs] COLOR CLR_BLUE FONT oFont01
	@ 062,010 Get oSerNfse VAR cSerNfse SIZE 100,10 PIXEL OF oPage:aDialogs[nPageNfs]
   	cTip := "Serie para geração NFS-e" +CRLF
   	cTip += "Ex: A" 
	oSerNfse:cToolTip := cTip
	@ 054,010 Say "Serie NFS-e:" PIXEL OF oPage:aDialogs[nPageNfs] COLOR CLR_BLUE FONT oFont01
	@ 062,010 Get oSerNfse VAR cSerNfse SIZE 100,10 PIXEL OF oPage:aDialogs[nPageNfs]
   	cTip := "Serie para geração NFS-e" +CRLF
   	cTip += "Ex: A" 
	oSerNfse:cToolTip := cTip

	@ 054,010 Say "Serie NFS-e:" PIXEL OF oPage:aDialogs[nPageNfs] COLOR CLR_BLUE FONT oFont01
	@ 062,010 Get oSerNfse VAR cSerNfse SIZE 100,10 PIXEL OF oPage:aDialogs[nPageNfs]
   	cTip := "Serie para geração NFS-e" +CRLF
   	cTip += "Ex: A" 
	oSerNfse:cToolTip := cTip

	@ 076,010 Say "Login / Conta de E-mail : "  		PIXEL OF oPage:aDialogs[nPageNfs] COLOR CLR_BLUE FONT oFont01
	@ 084,010 Get oPOPSConta VAR cPOPSConta SIZE 150,08 	PIXEL OF oPage:aDialogs[nPageNfs]                   
   	cTip := "Conta de email par buscar NFS-e" +CRLF
	oPOPSConta:cToolTip := cTip

	@ 098,010 Say "Senha : "  							PIXEL OF oPage:aDialogs[nPageNfs] COLOR CLR_BLUE FONT oFont01
	@ 106,010 Get oPOPSPass VAR cPOPSPass SIZE 150,08 	PIXEL OF oPage:aDialogs[nPageNfs] PASSWORD
   	cTip := "Senha de email par buscar NFS-e" +CRLF
	oPOPSPass:cToolTip := cTip
// 	@ 032,230 Say "Tabela Lay Out Cidades:"  PIXEL OF oPage:aDialogs[nPageNfs] COLOR CLR_BLUE FONT oFont01
//	@ 040,230 Get oTabRec VAR cTabCid SIZE 100,08 PICTURE "!!!" PIXEL OF oPage:aDialogs[nPageNfs]

	@ 054,120 Say "Vezes de download do dia atual: " PIXEL OF oPage:aDialogs[nPageNfs] COLOR CLR_BLUE FONT oFont01 
	@ 062,120 COMBOBOX  oVezNfse VAR cVezNfse ITEMS aCombo30 SIZE 100,10 PIXEL OF oPage:aDialogs[nPageNfs]

	cTip := "0 - Não executa download de NFS-e do dia" +CRLF
	cTip += "1 - Executa uma vez o download das NFS-e do dia atual (13:00)" +CRLF
	cTip += "2 - Executa duas vezes o download das NFS-e do dia atual (10:00, 13:00)" +CRLF
	cTip += "3 - Executa três vezes o download das NFS-e do dia atual (10:00, 13:00, 16:00)" +CRLF
	cTip += "4 - Executa quatro vezes o download das NFS-e do dia atual (9:00, 12:00, 15:00, 18:00)" +CRLF
	oVezNfse:cToolTip := cTip 
	@ 190,240 Button "Valida E-mail" Size 050,015 PIXEL OF oPage:aDialogs[nPageNfs] ACTION (TestPop(cServerPOP,cLoginPOP,cPOPSConta,cPOPSPass,lPOPAuth,lPOPSSL,lPOPTLS,cProtocolR,cPortRec,aSmtp))	     
	@ 190,300 Button "Salvar" Size 040,015 PIXEL OF oPage:aDialogs[nPageNfs] ACTION (SetCfgNfse(cUsaNfse,cEspNfe,cPRODNFS,cArqTxt,cGrvNfse,cDiasNfse,cSerNfse,cPOPSConta,cPOPSPass))  //FR 19/05/2020
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Configurações Integração na Nuvem                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 015,00.1 To 015.1,043.8 OF oPage:aDialogs[nPageNuvem]  	//FR 19/05/2020
	cCloud    	:=	GetNewPar("XM_CLOUD" ,"0")         //aCombo (0=Desbilitado 1=Habilitado)
	cClTipo    	:=	GetNewPar("XM_CLTIPO"," ")         //aCombo (Nuvem/Protheus/Ambos)
	cClToken   	:=	Substr(GetNewPar("XM_CLTOKEN",Space(256))+space(256),1,256) //Editar da primeira Vez (oWS:ctoken)
	nClID   	:=	GetNewPar("XM_CLID",0)             //oWS:oWSDadosDaContaResult:nID
	nClPlano   	:=	GetNewPar("XM_CLPLANO",0)          //oWS:oWSDadosDaContaResult:nPLANOID
	nClStPla   	:=	GetNewPar("XM_CLSTID",0)           //oWS:oWSDadosDaContaResult:nSTATUSID
	nClForma   	:=	GetNewPar("XM_CLFORMA",0)          //oWS:oWSDadosDaContaResult:nFORMAPAGAMENTOID
	cClArea   	:=	GetNewPar("XM_CLAREA" ,Space(256)) //oWS:oWSDadosDaContaResult:cAREA
	cClEmail   	:=	GetNewPar("XM_CLEMAIL",Space(256)) //oWS:oWSDadosDaContaResult:cEMAIL
	cClNome   	:=	GetNewPar("XM_CLNOME",Space(256))  //oWS:oWSDadosDaContaResult:cNOME
	cClRamal   	:=	GetNewPar("XM_CLRAMAL",Space(256)) //oWS:oWSDadosDaContaResult:cRAMAL
	cClSenha   	:=	GetNewPar("XM_CLSENHA",Space(256)) //oWS:oWSDadosDaContaResult:cSENHA
	cClTelFx   	:=	GetNewPar("XM_CLTELFX",Space(256)) //oWS:oWSDadosDaContaResult:cTELEFONEFIXO
	cClTelMv   	:=	GetNewPar("XM_CLTELMV",Space(256)) //oWS:oWSDadosDaContaResult:cTELEFONEMOVEL
	cStatNF     :=  GetNewPar("XM_STATXML","N")

	@ 010,010 Say "Habilita Integração:" PIXEL OF oPage:aDialogs[nPageNuvem] COLOR CLR_BLUE FONT oFont01
	@ 018,010 COMBOBOX  oCloud  VAR cCloud ITEMS aCombo  SIZE 100,10 PIXEL OF oPage:aDialogs[nPageNuvem] //*Valid( ValCloud())*/
   	cTip := "Habilita Integração Conector Sefaz com Gestao XML?" +CRLF
   	cTip += "0 - Desabilitado" +CRLF
   	cTip += "1 - Habilitado"
	oCloud:cToolTip := cTip

	@ 010,120 Say "Token: " PIXEL OF oPage:aDialogs[nPageNuvem] COLOR CLR_BLUE FONT oFont01
	@ 018,120 Get oClToken VAR cClToken SIZE 090,08 PIXEL OF oPage:aDialogs[nPageNuvem] WHEN cCloud == "1"  //VALID ( ValidToken(cClToken) ) 
//	@ 018,320 BUTTON "..."              SIZE 010,11 PIXEL OF oPage:aDialogs[nPageNuvem] ACTION ( ValidToken(cClToken) )
	cTip := "Informe o Token da Conta para Intgegração." +CRLF
	cTip += "Token com a validação do cadastro na HF."
	oClToken:cToolTip := cTip

	@ 010,220 Say "Integração Status XML: " PIXEL OF oPage:aDialogs[nPageNuvem] COLOR CLR_BLUE FONT oFont01
	@ 018,220 COMBOBOX  oStatNF  VAR cStatNF ITEMS aCombo2  SIZE 100,10 PIXEL OF oPage:aDialogs[nPageNuvem] //*Valid( ValCloud())*/
	cTip := "Habilita integração de gravação de status na nuvem a cada etapa de entrada da nota fiscal," + CRLF
	cTip += "Sendo como pré-nota e nota classificada junto com seus estornos." + CRLF
   	cTip += "S - Sim" +CRLF
   	cTip += "N - Não"
	oStatNF:cToolTip := cTip

/*
	@ 010,120 Say "Tipo da Integração:" PIXEL OF oPage:aDialogs[nPageNuvem] COLOR CLR_BLUE FONT oFont01 
	@ 018,120 COMBOBOX  oClTipo VAR cClTipo ITEMS aCombo18 SIZE 100,10 PIXEL OF oPage:aDialogs[nPageNuvem]  WHEN cCloud == "1"
  	cTip := "Tipo da Integração:" +CRLF
  	cTip += "G = Quando estiver habilitado, irá baixar os xmls do tipo NFE que estão dentro do gestão xml cloud. Outros tipos de xmls são baixados direto pelo TOTVS"
	oClTipo:cToolTip := cTip 


	//Linha 2
	@ 032,010 Say "ID: " PIXEL OF oPage:aDialogs[nPageNuvem] COLOR CLR_BLUE FONT oFont01
	@ 040,010 Get oClID VAR nClID SIZE 100,08 PIXEL OF oPage:aDialogs[nPageNuvem] WHEN .F.
	cTip := "ID da Conta para Intgegração."
	oClID:cToolTip := cTip

	@ 032,120 Say "PLANO: " PIXEL OF oPage:aDialogs[nPageNuvem] COLOR CLR_BLUE FONT oFont01 
	@ 040,120 Get oClPlano VAR nClPlano SIZE 100,08 PIXEL OF oPage:aDialogs[nPageNuvem] WHEN .F.
	cTip := "Plano da Conta para Intgegração."
	oClPlano:cToolTip := cTip 

	@ 032,230 Say "Status: " PIXEL OF oPage:aDialogs[nPageNuvem] COLOR CLR_BLUE FONT oFont01 
	@ 040,230 Get oClStPla VAR nClStPla SIZE 100,08 PIXEL OF oPage:aDialogs[nPageNuvem] WHEN .F.
	cTip := "Status da Conta para Intgegração."
	oClStPla:cToolTip := cTip

	//Linha 3 - //54 62
	@ 054,010 Say "ID Forma Pgto: " PIXEL OF oPage:aDialogs[nPageNuvem] COLOR CLR_BLUE FONT oFont01
	@ 062,010 Get oClForma VAR nClForma SIZE 100,08 PIXEL OF oPage:aDialogs[nPageNuvem] WHEN .F.
	cTip := "ID da Forma de Pagamento."
	oClForma:cToolTip := cTip

	@ 054,120 Say "AREA: " PIXEL OF oPage:aDialogs[nPageNuvem] COLOR CLR_BLUE FONT oFont01 
	@ 062,120 Get oClArea VAR cClArea SIZE 100,08 PIXEL OF oPage:aDialogs[nPageNuvem] WHEN .F.
	cTip := "Area do Responável pela Intgegração."
	oClArea:cToolTip := cTip

	@ 054,230 Say "Email: " PIXEL OF oPage:aDialogs[nPageNuvem] COLOR CLR_BLUE FONT oFont01 
	@ 062,230 Get oClEmail VAR cClEmail SIZE 100,08 PIXEL OF oPage:aDialogs[nPageNuvem] WHEN .F.
	cTip := "e-mail do Responável pela Intgegração."
	oClEmail:cToolTip := cTip


	//Linha 4 - //76 84
	@ 076,010 Say "Nome: " PIXEL OF oPage:aDialogs[nPageNuvem] COLOR CLR_BLUE FONT oFont01
	@ 084,010 Get oClNome VAR cClNome SIZE 200,08 PIXEL OF oPage:aDialogs[nPageNuvem] WHEN .F.
	cTip := "Nome do Responsável"
	oClNome:cToolTip := cTip

	//@ 054,120 Say "AREA: " PIXEL OF oPage:aDialogs[nPageNuvem] COLOR CLR_BLUE FONT oFont01 
	//@ 062,120 Get oClArea VAR cClArea SIZE 100,08 PIXEL OF oPage:aDialogs[nPageNuvem] WHEN .F.
	//cTip := "Area do Responável pela Intgegração." +CRLF
	//oClArea:cToolTip := cTip

	@ 076,230 Say "Senha: " PIXEL OF oPage:aDialogs[nPageNuvem] COLOR CLR_BLUE FONT oFont01 
	@ 084,230 Get oClSenha VAR cClSenha SIZE 100,08 PIXEL OF oPage:aDialogs[nPageNuvem] WHEN .F.
	cTip := "Senha."
	oClSenha:cToolTip := cTip


	//Linha 5 - //98 106
	@ 098,010 Say "Ramal: " PIXEL OF oPage:aDialogs[nPageNuvem] COLOR CLR_BLUE FONT oFont01
	@ 106,010 Get oClRamal VAR cClRamal SIZE 100,08 PIXEL OF oPage:aDialogs[nPageNuvem] WHEN .F.
	cTip := "Ramal"
	oClRamal:cToolTip := cTip

	@ 098,120 Say "Telefone Fixo: " PIXEL OF oPage:aDialogs[nPageNuvem] COLOR CLR_BLUE FONT oFont01 
	@ 106,120 Get oClTelFx VAR cClTelFx SIZE 100,08 PIXEL OF oPage:aDialogs[nPageNuvem] WHEN .F.
	cTip := "Telefone Fixo."
	oClArea:cToolTip := cTip

	@ 098,230 Say "Telefone Movel: " PIXEL OF oPage:aDialogs[nPageNuvem] COLOR CLR_BLUE FONT oFont01 
	@ 106,230 Get oClTelMv VAR cClTelMv SIZE 100,08 PIXEL OF oPage:aDialogs[nPageNuvem] WHEN .F.
	cTip := "Celular."
	oClTelMv:cToolTip := cTip
*/

	@ 190,200 Button "Certificado"			Size 040,015 PIXEL OF oPage:aDialogs[nPageNuvem] ACTION (U_CertNVM(cClToken)) //HMS 14/06/2022
	@ 190,250 Button "Testar Conexão"		Size 040,015 PIXEL OF oPage:aDialogs[nPageNuvem] ACTION (U_TesteNVM(cClToken)) //HMS 14/06/2022
	@ 190,300 Button "Salvar"				Size 040,015 PIXEL OF oPage:aDialogs[nPageNuvem] ACTION (SetCfgNuve(cCloud,cClTipo,cClToken,nClID,nClPlano,nClStPla,nClForma,cClArea,cClEmail,cClNome,cClRamal,cClSenha,cClTelFx,cClTelMv,cStatNF)) //FR 19/05/2020


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Configurações Ferramentas                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	@ 015,00.1 To 015.1,043.8 OF oPage:aDialogs[nPageTool] 	//FR 19/05/2020
	@ 010,010 Button "Atualiza"+CRLF+"Status XML" Size 070,020 PIXEL OF oPage:aDialogs[nPageTool];
	 ACTION (Processa({|lEnd| U_UPStatXML(.F.,@lEnd,oProcess)} ,"Processando...","Atualizando Status...",.T.))
	 
	@ 040,010 Button "Atualiza"+CRLF+"Fornecedor XML" Size 070,020 PIXEL OF oPage:aDialogs[nPageTool];
	 ACTION (Processa({|lEnd| U_UPForXML(.F.,@lEnd,oProcess)} ,"Processando...","Atualizando Dados...",.T.))

	//BOTÃO DE CONSULTA SEFAZ FOI DESATIVADO MEDIANTE INTEGRAÇÃO COM CLOUD. 18/08/2022 - LS
	//@ 070,010 Button "Consulta XML"+CRLF+"Sefaz" Size 070,020 PIXEL OF oPage:aDialogs[nPageTool];
	 //ACTION (Processa({|lEnd| U_UPConsXML(.F.,@lEnd,oProcess)} ,"Processando...","Consultando XML's...",.T.))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Avançado                                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	@ 015,00.1 To 015.1,043.8 OF oPage:aDialogs[nPageAdv]	//FR 19/05/2020 
	@ 010,010 Button "Configuração"+CRLF+"'Baixar Xml'" Size 070,020 PIXEL OF oPage:aDialogs[nPageAdv];
	 ACTION U_UPCfgXML()

	@ 040,010 Button "Parâmetros"+CRLF+"Exclusivos" Size 070,020 PIXEL OF oPage:aDialogs[nPageAdv];
	 ACTION U_UPParExc()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Info                                                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	@ 015,00.1 To 015.1,043.8 OF oPage:aDialogs[nPageInfo]	//FR 19/05/2020
//    aInfo := U_GetverIX()                           
    cProd := "Gestão XML"
    dVencLic := Stod(Space(8))
	cTipoLic := ""
 	lUsoOk := U_HFXMLLIC(.F.,@dVencLic,@cTipoLic)  
 	                                                                  
	@ 01.0, 01 To 004.5, 021 PROMPT "Gestão XML " OF oPage:aDialogs[nPageInfo]
	@ 025,015 Say "Versão......:" PIXEL OF oPage:aDialogs[nPageInfo] COLOR CLR_BLUE FONT oFont03
	@ 035,015 Say "Compilação..:" PIXEL OF oPage:aDialogs[nPageInfo] COLOR CLR_BLUE FONT oFont03
	//@ 045,015 Say "TSS Importa.:" PIXEL OF oPage:aDialogs[nPageInfo] COLOR CLR_BLUE FONT oFont03

	@ 025,065 Say aInfo[1][2] PIXEL OF oPage:aDialogs[nPageInfo] COLOR CLR_RED FONT oFont03
	@ 035,065 Say aInfo[2][2] PIXEL OF oPage:aDialogs[nPageInfo] COLOR CLR_RED FONT oFont03
	@ 045,065 Say aInfo[5][2] PIXEL OF oPage:aDialogs[nPageInfo] COLOR CLR_RED FONT oFont03

	@ 01.0, 21.5 To 004.5, 042 PROMPT "Conector Sefaz" OF oPage:aDialogs[nPageInfo] //LS 05/08/2022
	@ 025,180 Say "URL.......:" PIXEL OF oPage:aDialogs[nPageInfo] COLOR CLR_BLUE FONT oFont03
	@ 025,220 Say "https://cloud.importaxml.com.br/" PIXEL OF oPage:aDialogs[nPageInfo] COLOR CLR_RED FONT oFont03
	@ 035,180 Say "Versão....:" PIXEL OF oPage:aDialogs[nPageInfo] COLOR CLR_BLUE FONT oFont03
	@ 035,220 Say "v2.0.9b" PIXEL OF oPage:aDialogs[nPageInfo] COLOR CLR_RED FONT oFont03
	//@ 045,180 Say "Entidade....:" PIXEL OF oPage:aDialogs[nPageInfo] COLOR CLR_BLUE FONT oFont03

	//@ 025,230 Say cURL PIXEL OF oPage:aDialogs[nPageInfo] COLOR CLR_RED FONT oFont03
	//@ 035,230 Say cVerTSS PIXEL OF oPage:aDialogs[nPageInfo] COLOR CLR_RED FONT oFont03
	//@ 045,230 Say cIdEnt PIXEL OF oPage:aDialogs[nPageInfo] COLOR CLR_RED FONT oFont03


	@ 04.8, 01 To 011.5, 042 PROMPT "Licença" OF oPage:aDialogs[nPageInfo]
	@ 075,015 Say "Empresa......: " PIXEL OF oPage:aDialogs[nPageInfo] COLOR CLR_BLUE FONT oFont03
	@ 085,015 Say "Cnpj.........: " PIXEL OF oPage:aDialogs[nPageInfo] COLOR CLR_BLUE FONT oFont03
	@ 095,015 Say "Vencimento...: " PIXEL OF oPage:aDialogs[nPageInfo] COLOR CLR_BLUE FONT oFont03
	@ 105,015 Say "Tipo.........: " PIXEL OF oPage:aDialogs[nPageInfo] COLOR CLR_BLUE FONT oFont03

	@ 075,065 Say SM0->M0_NOMECOM PIXEL OF oPage:aDialogs[nPageInfo] COLOR CLR_RED FONT oFont03
	@ 085,065 Say SM0->M0_CGC PIXEL OF oPage:aDialogs[nPageInfo] COLOR CLR_RED FONT oFont03
	@ 095,065 Say Dtoc(dVencLic) PIXEL OF oPage:aDialogs[nPageInfo] COLOR CLR_RED FONT oFont03
	@ 105,065 Say cTipoLic PIXEL OF oPage:aDialogs[nPageInfo] COLOR CLR_RED FONT oFont03

	@ 012,355 Button "Sair" Size 040,015 PIXEL OF oDlg ACTION oDlg:End()
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT (nOpca := 0,.T.)
	
	//RESET ENVIRONMENT         
	                            
Return                                              

**************************
Static Function ValCloud()
**************************
	oClTipo:Refresh()
	oClToken:Refresh()

Return( .T. )      

**********************************
Static Function ValdGetDir(cPathx)
**********************************
	Local lret := .T.
	Local _lUnix := IsSrvUnix() /*Informa se Application Server está sendo executado em ambiente Unix®, Linux® ou Microsoft Windows®.*/
	
	if .Not. upper("xmlsource") $ upper(cPathx)
		cPathx := StrTran(cPathx,"xmlsource","")
	EndIf
	if empty(cPathx) .or. AllTrim(cPathx) == "/" .or. AllTrim(cPathx) == "\"
	    if _lUnix 
	    	cPathx:= cPathx+"\xmlsource\"
			cPathx := StrTran(cPathx,"\","/")
		else 
			cPathx:= cPathx+"\xmlsource\"
			cPathx := "\"+cPathx+"\"
			cPathx := StrTran(cPathx,"\\\\","\")
			cPathx := StrTran(cPathx,"\\\","\")
			cPathx := StrTran(cPathx,"\\","\")
		endif
	endif

Return(lRet)

***************************************
Static Function ValidToken(cClTokenVal) 
***************************************
	Local lRet := .F.
	Local oWS
	
	if Empty(cClTokenVal)
		cInfo := "Token Vazio"
		Alert( cInfo )
		Return( .T. )
	Endif
	
	oWS:=WSERP():New() 
	
	//Fazer uma ABA com parâmetros da conta. Informar o toquem, executar o WS e pegar os dados
	//ver quais parâmetros criar
	oWS:ctoken := AllTrim(cClTokenVal) //"5060-DDD2-1719"
	oWS:INIT()
	
	If oWS:DadosDaConta()
	
	//  Private
		If oWS:oWSDadosDaContaResult:cToken <> NIL .And. AllTrim(oWS:oWSDadosDaContaResult:cToken) == AllTrim(cClTokenVal)
			lRet   := .T.
			nClID   	:=	oWS:oWSDadosDaContaResult:nID
			nClPlano   	:=	oWS:oWSDadosDaContaResult:nPLANOID
			nClStPla   	:=	oWS:oWSDadosDaContaResult:nSTATUSID
			nClForma   	:=	oWS:oWSDadosDaContaResult:nFORMAPAGAMENTOID
			cClArea   	:=	oWS:oWSDadosDaContaResult:cAREA
			cClEmail   	:=	oWS:oWSDadosDaContaResult:cEMAIL
			cClNome   	:=	oWS:oWSDadosDaContaResult:cNOME
			cClRamal   	:=	oWS:oWSDadosDaContaResult:cRAMAL
			cClSenha   	:=	oWS:oWSDadosDaContaResult:cSENHA
			cClTelFx   	:=	oWS:oWSDadosDaContaResult:cTELEFONEFIXO
			cClTelMv   	:=	oWS:oWSDadosDaContaResult:cTELEFONEMOVEL
	
			oClID:Refresh()
			oClPlano:Refresh()
			oClStPla:Refresh()
			oClForma:Refresh()
			oClArea:Refresh()
			oClEmail:Refresh()
			oClNome:Refresh()
			oClRamal:Refresh()
			oClSenha:Refresh()
			oClTelFx:Refresh()
			oClTelMv:Refresh()
	
			cInfo := "Token Válido para: "+AllTrim(cClNome)
			U_MyAviso("TOKEN",cInfo ,{"Ok"},3)
	
		Else
			cInfo := "Token Inválido Metodo: DadosDaConta() - WS: WSERP()"
			Alert( cInfo )
		Endif
	
	Else
	
		cInfo   := IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
		Alert( cInfo )
	
	Endif

Return( .T. )


**********************************************************************************************************
Static Function SetDefs(cENABLE,cENT,nWFDELAY,cTHREADID,cJOBS,nSLEEP,cConsole,nDiasRet,cHrCons,cXmTpJobCx,cNSUZero,cEmpBlq,cHoraSefaz,cReqSefaz,cCnpjSefaz)
**********************************************************************************************************
Local aDefs   := {}
//Local Nx      := 0
Local cFileX  := "hfcfgxml001a.xml"
Local cXmlCfg := ""

Aadd(aDefs,{"ENABLE"  ,cENABLE   		,"Serviço Habilitado"                     }) 
Aadd(aDefs,{"ENT"     ,cENT  			,"Empresa/Filial principal do processo"   }) 
Aadd(aDefs,{"WFDELAY" ,nWFDELAY    		,"Atraso apos a primeira execucao"   }) 
Aadd(aDefs,{"THREADID",cTHREADID   		,"Identificador de Thread [Debug]"   }) 
Aadd(aDefs,{"JOBS"    ,Separa(cJobs,","),"Serviço a ser processado"   }) 
Aadd(aDefs,{"SLEEP"   ,nSLEEP    		,"Tempo de espera"   }) 
Aadd(aDefs,{"CONSOLE" ,cConsole   		,"Informacoes dos processos no console"   }) 

cXmlCfg := U_LoadCfgX(2,cFileX,aDefs)

If !Empty(cXmlCfg)

	MemoWrite(cFileX,cXmlCfg)
	
EndIf

If !PutMv("XM_NSUZERO", cNSUZero ) 

	RecLock("SX6",.T.)
	SX6->X6_FIL     := xFilial("SX6")
	SX6->X6_VAR     := "XM_NSUZERO"
	SX6->X6_TIPO    := "C"
	SX6->X6_DESCRIC := "Verifica NSU zerado. N=Nao ou S=Sim"
	MsUnLock()
	PutMv("XM_NSUZERO", cNSUZero ) 
	
EndIf

/********************************/
If !PutMv("XM_TPJOBCX", cXmTpJobCx ) 

	RecLock("SX6",.T.)
	SX6->X6_FIL     := xFilial("SX6")
	SX6->X6_VAR     := "XM_TPJOBCX"
	SX6->X6_TIPO    := "C"
	SX6->X6_DESCRIC := "Tipo das Execuções do JOB. 1=Concorrentes ou 2=Em Fila"
	MsUnLock()
	PutMv("XM_TPJOBCX", cXmTpJobCx ) 
	
EndIf

cDayCanc:= StrZero(nDiasRet,2)

If !PutMv("XM_D_CANCEL", cDayCanc ) 

	RecLock("SX6",.T.)
	SX6->X6_FIL     := xFilial("SX6")
	SX6->X6_VAR     := "XM_D_CANCEL"
	SX6->X6_TIPO    := "C"
	SX6->X6_DESCRIC := "Dias a retroceder para consultar XML na SEFAZ."
	MsUnLock()
	PutMv("XM_D_CANCEL", cDayCanc ) 
	
EndIf

If !PutMv("XM_HR_CONS", cHrCons ) 

	RecLock("SX6",.T.)
	SX6->X6_FIL     := xFilial("SX6")
	SX6->X6_VAR     := "XM_HR_CONS"
	SX6->X6_TIPO    := "C"
	SX6->X6_DESCRIC := "Hora programada de execução da consulta XML na SEFAZ."
	MsUnLock()
	PutMv("XM_HR_CONS", cHrCons ) 
	
EndIf

//FR 17/07/2020
If !PutMv("XM_ITSLEEP", nSleep ) 

	RecLock("SX6",.T.)
	SX6->X6_FIL     := xFilial("SX6")
	SX6->X6_VAR     := "XM_ITSLEEP"
	SX6->X6_TIPO    := "N"
	SX6->X6_DESCRIC := "Tempo espera Job em milisegundos"
	MsUnLock()
	PutMv("XM_HR_CONS", cHrCons ) 
	
EndIf

If !PutMv("XM_EMPBLQ", cEmpBlq ) 

	RecLock("SX6",.T.)
	SX6->X6_FIL     := xFilial("SX6")
	SX6->X6_VAR     := "XM_EMPBLQ"
	SX6->X6_TIPO    := "C"
	SX6->X6_DESCRIC := "Bloqueia Empresa/Filial"
	MsUnLock()
	PutMv("XM_EMPBLQ", cEmpBlq ) 
	
EndIf

/********************************/

If !PutMv("XM_NHRSEF", cHoraSefaz )
	RecLock("SX6",.T.)
	SX6->X6_FIL     := xFilial("SX6")
	SX6->X6_VAR     := "XM_NHRSEF"
	SX6->X6_TIPO    := "N"
	SX6->X6_DESCRIC := "Tempo para requisições na Sefaz"
	MsUnLock()
	PutMv("XM_NHRSEF", cHoraSefaz )
EndIf

 /********************************/
	If !PutMv("XM_NREQSEF", cReqSefaz )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_NREQSEF"
		SX6->X6_TIPO    := "N"
		SX6->X6_DESCRIC := "Quantidade de Requisição da Chave por hora no Sefaz"
		MsUnLock()
		PutMv("XM_NREQSEF", cReqSefaz )
	EndIf

 /********************************/

If !PutMv("XM_NCNPJSE", cCnpjSefaz )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_NCNPJSE"
		SX6->X6_TIPO    := "N"
		SX6->X6_DESCRIC := "Quantidade de Requisição do CNPJ na Sefaz"
		MsUnLock()
		PutMv("XM_NCNPJSE", cCnpjSefaz )
	EndIf

rstmvbuff()	
		
Return


*****************************************************************************************************************
Static Function SetMail(nTipo,nOpc,cMailServer,cLogin,cMailConta,cMailSenha,lSMTPAuth,lSSL,cProtocol,cPort,lTLS)
*****************************************************************************************************************  
	Local aRet := {}
	//Local cError := ""
	Local nret   := 0 
	//Local cret   := ""
	aRet :=U_XCfgMail(nTipo,nOpc,{cMailServer,cLogin,cMailConta,cMailSenha,lSMTPAuth,lSSL,cProtocol,cPort,lTLS})  //aquuii
	
	If nOpc == 2 .And. nRet == 0
		MsgInfo("Configurações de E-mail atualizadas com sucesso!")
	EndIf
	Return
	      
	
	Static Function SetCfgMail(cMail01, cMail02, cMail03, cMail04, cMail05, lChk6, cMail06, lChkImp, cMail07, cMail08, cMail09, cMail10, cMail11, cMail12,cTentativas )
	Local Nx := 0
	
	//For Nx:=1 to 7
	For Nx:=1 to 12		//FR - Flávia Rocha - 21/12/2022 - AJUSTE NA QTDE DE REPETIÇÕES PELO NÚMERO DE PARÂMETROS XM_MAILn
	
	
		If !PutMv("XM_MAIL" + StrZero(Nx,2), &("cMail"+ StrZero(Nx,2)) )
			RecLock("SX6",.T.)
			SX6->X6_FIL     := cFilAnt
			SX6->X6_VAR     := "XM_MAIL" + StrZero(Nx,2)
			SX6->X6_TIPO    := "C"
			if nX == 5
				SX6->X6_DESCRIC := "Notificação de XML que não consta na Base de Dados do Protheus."
			ElseIf nX == 6
				SX6->X6_DESCRIC := "Notificação, aos gestores, de XML que não consta na Base de Dados do Protheus por JOB Separado."
			ElseIf nX == 7
				SX6->X6_DESCRIC := "Notificação, aos gestores, de XML foi classificado de forma robótica."
			ElseIf nX == 8
				SX6->X6_DESCRIC := "Notificação, aos gestores, de XML x NF com divergencia de valores."
			ElseIf nX == 9
				SX6->X6_DESCRIC := "Notificação por E-mail de novos cadastros de Fornecedor"
			ElseIf nX == 10
				SX6->X6_DESCRIC := "Notificação por E-mail de novo XML gravado na base de dados."
			ElseIf nX == 11
				SX6->X6_DESCRIC := "Notificação por E-mail de nova pre-nota gerada."
			ElseIf nX == 12
				SX6->X6_DESCRIC := "Notificação por E-mail de classificação de nota."
			Else
				SX6->X6_DESCRIC := "E-mail para notificaçao de eventos."
			EndIF
			MsUnLock()
			PutMv("XM_MAIL" + StrZero(Nx,2), &("cMail"+ StrZero(Nx,2)) )
		EndIf
	
	Next
	
			/********************************/
			If !PutMv("XM_ESPIAO", IIF(lChk6, "S","N" ))
				RecLock("SX6",.T.)
				SX6->X6_FIL     := xFilial("SX6")
				SX6->X6_VAR     := "XM_ESPIAO"
				SX6->X6_TIPO    := "C"
				SX6->X6_DESCRIC := "Ativa espião"
				SX6->X6_DESC1   := ""
				SX6->X6_DESC2   := ""
				MsUnLock()
				PutMv("XM_ESPIAO", IIF(lChk6, "S","N"))
			EndIf
	
			/********************************/
			If !PutMv("XM_ENVIMP", IIF(lChkImp, "S","N" ))
				RecLock("SX6",.T.)
				SX6->X6_FIL     := xFilial("SX6")
				SX6->X6_VAR     := "XM_ENVIMP"
				SX6->X6_TIPO    := "C"
				SX6->X6_DESCRIC := "Verificar pastas Importados nas rotinas de Chk XML?(S/N)"
				SX6->X6_DESC1   := ""
				SX6->X6_DESC2   := ""
				MsUnLock()
				PutMv("XM_ENVIMP", IIF(lChkImp, "S","N"))
			EndIf

			
			/********************************/
			If !PutMv("XM_TENTSEND", cTentativas )
				RecLock("SX6",.T.)
				SX6->X6_FIL     := xFilial("SX6")
				SX6->X6_VAR     := "XM_TENTSEND"
				SX6->X6_TIPO    := "N"
				SX6->X6_DESCRIC := "Numero maximo de tentativas"
				MsUnLock()
				PutMv("XM_TENTSEND", cTentativas )
			EndIf

		/********************************/

	
	rstmvbuff()
	MsgInfo("Configurações de E-mail atualizadas com sucesso!")
Return

//--------------------------------------------------------------------------//
//FR - Flávia Rocha - Projeto COPAG - SEFAZ AMAZONAS
//FR - 14/11/2022 - Algumas variáveis foram movidas para a aba Fiscais: 
//Solicitado por Rafael, mover os parâmetros de CFOP para a nova aba Fiscais 
//cCfDevol,cCfBenef,cCfTrans,cCfCompl
//--------------------------------------------------------------------------//
********************************************************************************************************************
Static Function SetCfgGer(cPathx, cSubFil, cSubCNPJ, cFormNfe,cFormCTe,cSubXml,cPedido,;		
                cDayStat,cCfgPre,cTipPre,cFilUsu,cUrlTss,cAmarra,cPedXML,cUsaGfe,cPNfCpl,nPedTru,cUsaDvg,cUltComp,cNCM,;
                cFornAuto,cFisAnali,cFornAutoD,cPCMark,cBcoConhe)  //FR - 28/04/2021 - NOVA TELA GESTÃOXML
********************************************************************************************************************                
//Local Nx := 0
//Local cError     := ""


	If !PutMv("MV_X_PATHX", cPathx ) 
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "MV_X_PATHX"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Diretorio Raiz dos XMLs importados."  
		MsUnLock()
		PutMv("MV_X_PATHX", cPathx ) 
	EndIf
	/********************************/
	If !PutMv("XM_DIRFIL", cSubFil ) 
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_DIRFIL"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Informa se cria diretorio por Filial do cliente." 
		MsUnLock()
		PutMv("XM_DIRFIL", cSubFil ) 
	EndIf
	
	/********************************/
	If !PutMv("XM_DIRCNPJ", cSubCnpj ) 
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_DIRCNPJ"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Informa se cria diretorio por CNPJ do emitente." 
		MsUnLock()
		PutMv("XM_DIRCNPJ", cSubCnpj ) 
	EndIf
	/********************************/
	If !PutMv("XM_DIRMOD", cSubXml ) 
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_DIRMOD"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Informa se cria diretorio por modelo de XML."
		MsUnLock()
		PutMv("XM_DIRMOD", cSubXml ) 
	EndIf

	/********************************/
	If !PutMv("XM_FORMNFE", cFormNfe ) 
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_FORMNFE"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Formato do campo Documento/Nota fiscal para NF-e." 
		MsUnLock()
		PutMv("XM_FORMNFE", cFormNfe ) 
	EndIf
	     
	/********************************/
	If !PutMv("XM_FORMCTE", cFormCTe ) 
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_FORMCTE"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Formato do campo Documento/Nota fiscal para CT-e." 
		MsUnLock()
		PutMv("XM_FORMCTE", cFormCTe ) 
	EndIf	

	/********************************/
	If !PutMv("XM_PED_PRE", cPedido ) 
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_PED_PRE"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Informa se assume valores do pedido na Pre-nota."
		MsUnLock()
		PutMv("XM_PED_PRE", cPedido ) 
	EndIf


	/********************************/
	If !PutMv("XM_D_STATUS", cDayStat ) 
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_D_STATUS"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Dias a retroceder para verificar Status XML." 
		MsUnLock()
		PutMv("XM_D_STATUS", cDayStat ) 
	EndIf

	/********************************/
	If !PutMv("XM_CFGPRE", cCfgPre ) 
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_CFGPRE"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Define a ação após a geração de pré-nota"
		MsUnLock()
		PutMv("XM_CFGPRE", cCfgPre ) 
	EndIf	

	/********************************/
	If !PutMv("XM_TIP_PRE", cTipPre ) 
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_TIP_PRE"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Tipo de pré-nota"
		MsUnLock()
		PutMv("XM_TIP_PRE", cTipPre ) 
	EndIf	

	/********************************/
	If !PutMv("XM_FIL_USU", cFilUsu ) 
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_FIL_USU"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Filtra Filial por Usuário"
		MsUnLock()
		PutMv("XM_FIL_USU", cFilUsu ) 
	EndIf	

	/********************************/
	If !PutMv("XM_URL", cUrlTss )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_URL"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "URL do TSS a qual será utilizado pelo importa."
		MsUnLock()
		PutMv("XM_URL", cUrlTss ) 
	EndIf	

	/********************************/
	If !PutMv("XM_DE_PARA", cAmarra )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_DE_PARA"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Tipo de seleção de amarração de produtos"
		SX6->X6_DESC1   := ""
		SX6->X6_DESC2   := ""
		MsUnLock()
		PutMv("XM_DE_PARA", cAmarra )
	EndIf
	
	/********************************/
	If !PutMv("XM_XPEDXML", cPedXML )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_XPEDXML"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Tipo de amarração por Pedido"
		SX6->X6_DESC1   := "1-Saldo Pedido 2-XML 3-Perguntar"
		SX6->X6_DESC2   := ""
		MsUnLock()
		PutMv("XM_XPEDXML", cPedXML )
	EndIf

	/********************************/
	If !PutMv("XM_USAGFE", cUsaGfe )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_USAGFE"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Atualiza status Frete Embarcador"
		SX6->X6_DESC1   := "GFE - S=Sim N=Não"
		SX6->X6_DESC2   := ""
		MsUnLock()
		PutMv("XM_USAGFE", cUsaGfe )
	EndIf

	/********************************/
	If !PutMv("XM_PNFCPL", cPNfCpl )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_PNFCPL"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Notas Complementares Larçar?"
		SX6->X6_DESC1   := "1-Doc.Entrada, 2-Pré-Nota, 3-Perguntar"
		SX6->X6_DESC2   := ""
		MsUnLock()
		PutMv("XM_PNFCPL", cPNfCpl )
	EndIf

	/********************************/
	If !PutMv("XM_PEDTRUN", nPedTru )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_PEDTRUN"
		SX6->X6_TIPO    := "N"
		SX6->X6_DESCRIC := "Casas Decimais Para Truncar Saldo Pedido x XML na"
		SX6->X6_DESC1   := "amarração por Pedido via XML"
		SX6->X6_DESC2   := ""
		MsUnLock()
		PutMv("XM_PEDTRUN", nPedTru )
	EndIf

	/********************************/
	If !PutMv("XM_USADVG", cUsaDvg )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_USADVG"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Ativa Verifica Divergências"
		SX6->X6_DESC1   := "Ver Divergências - S=Sim N=Não"
		SX6->X6_DESC2   := ""
		MsUnLock()
		PutMv("XM_USADVG", cUsaDvg )
	EndIf
	/*
	AADD(aSx6,{"  ","XM_D_STATUS"  ,"C","Dias a retroceder para verificar Status XML."      ,"","","","","","","","","30","30","30","",""})
	AADD(aSx6,{"  ","XM_D_CANCEL"  ,"C","Dias a retroceder para consultar XML na SEFAZ."    ,"","","","","","","","","7","7","7","",""})
	*/			
	
	/********************************/
	If !PutMv("XM_ULTCOMP", cUltComp )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_ULTCOMP"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Traz Dados da Última Compra"
		SX6->X6_DESC1   := "S=Sim;N=Não;P=Perguntar"
		SX6->X6_DESC2   := ""
		MsUnLock()
		PutMv("XM_ULTCOMP", cUltComp )
	EndIf	
	/********************************/	
	
	If !PutMv("XM_NCMXML", cNCM )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_NCMXML"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Atualiza NCM do SB1 c/ NCM do XML"
		SX6->X6_DESC1   := "S=Sim;N=Não;P=Perguntar"
		SX6->X6_DESC2   := ""
		MsUnLock()
		PutMv("XM_NCMXML", cNCM )
	EndIf
	/********************************/		
	
	If !PutMv("XM_SA2AUTO", cFornAuto )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_SA2AUTO"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Cadastra Fornec. Automat Classif NF?"
		SX6->X6_DESC1   := "S=Sim N=Não"
		SX6->X6_DESC2   := ""
		MsUnLock()
		PutMv("XM_SA2AUTO", cFornAuto )
	EndIf	
		
	/********************************/
	If !PutMv("XM_ANAFIS", cFisAnali )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_ANAFIS"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Analise Fiscal Modelo Arvore?"
		SX6->X6_DESC1   := "S=Sim N=Não"
		SX6->X6_DESC2   := ""
		MsUnLock()
		PutMv("XM_ANAFIS", cFisAnali )
	EndIf
		
	
	/********************************/		
	
	If !PutMv("XM_SA2AUTD", cFornAutoD )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_SA2AUTD"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Cadastra Fornec. Automat Download Xml?"
		SX6->X6_DESC1   := "S=Sim N=Não"
		SX6->X6_DESC2   := ""
		MsUnLock()
		PutMv("XM_SA2AUTD", cFornAutoD )
	EndIf

	/********************************/		
	
	If !PutMv("XM_PCMARK", cPCMark )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_PCMARK"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Traz Pedido(s) Marcado(s) [x]?"
		SX6->X6_DESC1   := "S=Sim ; N=Não"
		SX6->X6_DESC2   := ""
		MsUnLock()
		PutMv("XM_PCMARK", cFornAutoD )
	EndIf

	
	/********************************/		
	
	If !PutMv("XM_BCONHEC", cBcoConhe )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_BCONHEC"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "DEFINE SE UTILIZA BCO CONHECIMENTO AUTOMATIZADO"
		SX6->X6_DESC1   := "S=Sim ; N=Não"
		SX6->X6_DESC2   := ""
		MsUnLock()
		PutMv("XM_BCONHEC", cBcoConhe )
	EndIf


	Makedir(cPathx)
	rstmvbuff()
	MsgInfo("Configurações gerais atualizadas com sucesso!")
Return

*************************************************************
Static Function SetCfgNfse(cUsaNfse,cEspNfe,cPRODNFS,cArqTxt,cGrvNfse,cDiasNfse,cSerNfse,cConta,cPass)
*************************************************************
//Local Nx := 0
//Local cError     := ""
	Local nDiasNfse := val(cDiasNfse)

	/********************************/
	If !PutMv("XM_USANFSE", cUsaNfse )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_USANFSE"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "UTILIZA ROTIMA DE NFSE"
		MsUnLock()
		PutMv("XM_USANFSE", cUsaNfse )
	EndIf

	If !PutMv("XM_GRVNFSE", cGrvNfse )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_GRVNFSE"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "GRAVA PDFS LOCALMENTE"
		MsUnLock()
		PutMv("XM_GRVNFSE", cGrvNfse )
	EndIf
	/********************************/
	If !PutMv("XM_ESP_NFS", cEspNfe )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_ESP_NFS"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "ESPECIE PARA PRE NOTA DE NFSE"
		MsUnLock()
		PutMv("XM_ESP_NFS", cEspNfe )
	EndIf

	/********************************/
	If nDiasNfse > 90 .Or. nDiasNfse <= 0 
		nDiasNfse	:= 90
	EndIf	
	
	If !PutMv("XM_QTDIMC", cValToChar(nDiasNfse) )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_QTDIMC"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "DIAS PARA MONITORAMENTO IMAGE CONVERTER"
		MsUnLock()
		PutMv("XM_QTDIMC", cValToChar(nDiasNfse) )
	EndIf

	/********************************/
	If !PutMv("XM_PRODNFS", cPRODNFS )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_PRODNFS"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "PRODUTO GENERICO DOS FORNECEDORES DE NFSE"
		MsUnLock()
		PutMv("XM_PRODNFS", cPRODNFS )
	EndIf

	/********************************/
	If !PutMv("XM_ARQ_NFS", cArqTxt )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_ARQ_NFS"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Extensão do Arquivo"
		MsUnLock()
		PutMv("XM_ARQ_NFS", cArqTxt )
	EndIf

	/********************************/
	If !PutMv("XM_SER_NFS", cSerNfse )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_SER_NFS"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "SERIE PARA PRE NOTA DE NFSE"
		MsUnLock()
		PutMv("XM_SER_NFS", cSerNfse )
	EndIf
	If !PutMv("XM_POPACCS", cConta  )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_POPACCS"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Conta de Email de Recebimento de XML Serviço."	
		MsUnLock()
		PutMv("XM_POPACCS", cConta  )
	EndIf	
		/********************************/
	If !PutMv("XM_POPSPAS", Encode64(AllTrim(cPass))  )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_POPSPAS"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Senha da Conta de Recebimento de XML Serviço."
		MsUnLock()
		PutMv("XM_POPSPAS", Encode64(AllTrim(cPass))  )
	EndIf
	If !PutMv("XM_VEZDIA", cVezNfse  )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_VEZDIA"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Quantas vezes ao dia consulta as notas do dia."
		MsUnLock()
		PutMv("XM_VEZDIA", cVezNfse  )
	EndIf
	rstmvbuff()
	MsgInfo("Configurações NFSE atualizadas com sucesso!")
Return


//incluido para aba Gerais 2 - Alexandro de Oliveira - 25/11/2014
*****************************************************************************************************
Static Function SetCfgGerII(cSerEmp,_cSerXML,_cTravPrN,cRotCon,cConMod,cPedRec,cTabRec,cRecDoc,cXmlSef,;
                            cManPre,cLogoDan,_cFormSer,cMostra,cManAut,cVerLoja,cCadForn,cMBrw,cUsaPriv,;
                            cRetOk,cLpaTrv,cSefPrn,cDfeDow,cDfeMan,cCentro,cUsaStat,cDesmembra,cLoteFor)
*****************************************************************************************************                            
//Local Nx := 0
//Local cError     := ""

	/********************************/
	If !PutMv("XM_SEREMP", cSerEmp )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_SEREMP"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "SERIE POR EMPRESA"
		SX6->X6_DESC1   := "EX: SP=01,02;ES=10,11"
		SX6->X6_DESC2   := "VAZIO Mantem Série do XML"
		MsUnLock()
		PutMv("XM_SEREMP", cSerEmp ) 
	EndIf	


	/********************************/
	If !PutMv("XM_SERXML", _cSerXML )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_SERXML"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "SERIE DO XML VAZIA QUANDO 0"
		SX6->X6_DESC1   := "EX: S=SIM EM BRANCO; N=NAO COM VALOR 0"
		SX6->X6_DESC2   := ""
		MsUnLock()
		PutMv("XM_SERXML", _cSerXML ) 
	EndIf

	/********************************/
	If !PutMv("XM_PED_GBR", _cTravPrN )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_PED_GBR"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "TRAVA A PRE-NOTA"
		SX6->X6_DESC1   := "EX: S=SIM TRAVA A PRE NOTA; N=NAO APENAS PERGUNTA SE CONTINUA"
		SX6->X6_DESC2   := "  "
		MsUnLock()
		PutMv("XM_PED_GBR", _cTravPrN ) 
	EndIf
	
	/********************************/
	If !PutMv("XM_ROT_CON", cRotCon )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_ROT_CON"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "ROTINA DE CONSULTA AO SEFAZ"
		SX6->X6_DESC1   := "1=Importa XML, 2=TSS"
		SX6->X6_DESC2   := ""
		MsUnLock()
		PutMv("XM_ROT_CON", cRotCon )
	EndIf

	/********************************/
	If !PutMv("XM_GRBMOD", cConMod )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_GRBMOD"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "CONSULTA TODAS MODALIDADES"
		SX6->X6_DESC1   := ""
		SX6->X6_DESC2   := ""
		MsUnLock()
		PutMv("XM_GRBMOD", cConMod )
	EndIf

	/********************************/
	If !PutMv("XM_PEDREC", cPedRec )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_PEDREC"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Utiliza Pedido Recorrente"
		SX6->X6_DESC1   := ""
		SX6->X6_DESC2   := ""
		MsUnLock()
		PutMv("XM_PEDREC", cPedRec )
	EndIf

	/********************************/
	If !PutMv("XM_TABREC", cTabRec )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_TABREC"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Tabela de Fonrecedores com Pedido Recorrente"
		SX6->X6_DESC1   := ""
		SX6->X6_DESC2   := ""
		MsUnLock()
		PutMv("XM_TABREC", cTabRec )
	EndIf

	/********************************/
	If !PutMv("XM_RECDOC", cRecDoc )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_RECDOC"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Tipo de documento a gerar por pedido recorrente"
		SX6->X6_DESC1   := ""
		SX6->X6_DESC2   := ""
		MsUnLock()
		PutMv("XM_RECDOC", cRecDoc )
	EndIf

	/********************************/
	If !PutMv("XM_XMLSEF", cXmlSef )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_XMLSEF"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Comparar TAGs do XML com a SEFAZ"
		SX6->X6_DESC1   := ""
		SX6->X6_DESC2   := ""
		MsUnLock()
		PutMv("XM_XMLSEF", cXmlSef )
	EndIf

	/********************************/
	If !PutMv("XM_MANPRE", cManPre )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_MANPRE"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Manifestacao Robótica - pre-NF ou NF"
		SX6->X6_DESC1   := ""
		SX6->X6_DESC2   := ""
		MsUnLock()
		PutMv("XM_MANPRE", cManPre )
	EndIf

	/********************************/
	If !PutMv("XM_LOGOD", cLogoDan )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_LOGOD"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Emissão do Logo"
		SX6->X6_DESC1   := ""
		SX6->X6_DESC2   := ""
		MsUnLock()
		PutMv("XM_LOGOD", cLogoDan )
	EndIf 
	
	/********************************/
	If !PutMv("XM_FORMSER", _cFormSer )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_FORMSER"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Formatação da série"
		SX6->X6_DESC1   := ""
		SX6->X6_DESC2   := ""
		MsUnLock()
		PutMv("XM_FORMSER", _cFormSer )
	EndIf

	/********************************/
	If !PutMv("MV_MOSTRAA", cMostra )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "MV_MOSTRAA"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Mostra todas Consultas junto a Sefaz S ou N."
		MsUnLock()
		PutMv("MV_MOSTRAA", cMostra ) 
	EndIf

	/********************************/
	If !PutMv("XM_MANAUT", cManAut )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_MANAUT"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Manifesta Para Download Robótica"
		MsUnLock()
		PutMv("XM_MANAUT", cManAut )
	EndIf  
	
	/********************************/
	If !PutMv("XM_VERLOJA", cVerLoja )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_VERLOJA"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Considera Loja na amarração por pedido"
		MsUnLock()
		PutMv("XM_VERLOJA", cVerLoja )
	EndIf

	/********************************/
	If !PutMv("XM_USACFOR", cCadForn )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_USACFOR"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Mostrar Cadastro de Fornecedor?"
		MsUnLock()
		PutMv("XM_USACFOR", cCadForn )
	EndIf
	/********************************/
	If !PutMv("XM_BROWSE", cMBrw )  	//FR - 14/11/19 - Neste ponto grava a opção selecionada para o tipo de Browse: Simples ou Triplo(ZBZ-Xml, ZBT-Itens Xml e ZBE-Carta correção)
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_BROWSE"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Browse da Tela Principal 1=Somente Nfe, 2=NFe e CCe(Eventos)"
		MsUnLock()
		PutMv("XM_BROWSE", cMBrw )
	EndIf
    /********************************/
	If !PutMv("XM_PRIVILE", cUsaPriv )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_PRIVILE"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Utiliza Privilégio S=Sim ou N=Nao"
		MsUnLock()
		PutMv("XM_PRIVILE", cUsaPriv )
	EndIf

    /********************************/
	If !PutMv("XM_RETOK", cRetOk )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_RETOK"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Retorno XML do SEFAZ considerado como OK"
		MsUnLock()
		PutMv("XM_RETOK", cRetOk )
	EndIf

    /********************************/
	If !PutMv("XM_LPATRV", cLpaTrv )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_LPATRV"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Limpa Semáforo S=Sim ou N=Nao"
		MsUnLock()
		PutMv("XM_LPATRV", cLpaTrv )
	EndIf

    /********************************/
	If !PutMv("XM_SEFPRN", cSefPrn )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_SEFPRN"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Consulta SEFAZ antes da Pré-Nota S=Sim ou N=Nao"
		MsUnLock()
		PutMv("XM_SEFPRN", cSefPrn )
	EndIf

    /********************************/
	If !PutMv("XM_DFE", cDfeDow )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_DFE"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Rotina de Download do XML (0,1,2)"
		MsUnLock()
		PutMv("XM_DFE", cDfeDow )
	EndIf

    /********************************/
	If !PutMv("XM_DFEMAN", cDfeMan )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_DFEMAN"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Rotina de Manifestação Destinatário (0,1)"
		MsUnLock()
		PutMv("XM_DFEMAN", cDfeMan )
	EndIf

 /********************************/
	If !PutMv("XM_NREQSEF", cReqSefaz )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_NREQSEF"
		SX6->X6_TIPO    := "N"
		SX6->X6_DESCRIC := "Quantidade de Requisição da Chave por hora no Sefaz"
		MsUnLock()
		PutMv("XM_NREQSEF", cReqSefaz )
	EndIf

 /********************************/

If !PutMv("XM_NCNPJSE", cCnpjSefaz )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_NCNPJSE"
		SX6->X6_TIPO    := "N"
		SX6->X6_DESCRIC := "Quantidade de Requisição do CNPJ na Sefaz"
		MsUnLock()
		PutMv("XM_NCNPJSE", cCnpjSefaz )
	EndIf

	 /********************************/

	If !PutMv("XM_NHRSEF", cHoraSefaz )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_NHRSEF"
		SX6->X6_TIPO    := "N"
		SX6->X6_DESCRIC := "Tempo para requisições na Sefaz"
		MsUnLock()
		PutMv("XM_NHRSEF", cHoraSefaz )
	EndIf

 /********************************/
	If !PutMv("XM_BXRESUM", cBxResu )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_BXRESUM"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Baixar XML NFe Resumido?"
		MsUnLock()
		PutMv("XM_BXRESUM", cBxResu )
	EndIf
 /********************************/
	If !PutMv("XM_CENTRO", cCentro )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_CENTRO"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Centro de Custo 1=Padrão ou 2=Produto"
		MsUnLock()
		PutMv("XM_CENTRO", cCentro )
	EndIf
 /********************************/
	If !PutMv("XM_USASTAT", cUsaStat )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_USASTAT"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Habilita se usa ou nao status XML"
		MsUnLock()
		PutMv("XM_USASTAT", cUsaStat )
	EndIf
/********************************/
	If !PutMv("XM_DESLOTE", cDesmembra )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_DESLOTE"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Habilita se desmembra a Qtde Por Lote"
		MsUnLock()
		PutMv("XM_USASTAT", cDesmembra )
	EndIf

/********************************/
	If !PutMv("XM_LOTEFOR", cLoteFor )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_LOTEFOR"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Indica se Usa o Nro.Lote do Fornecedor"
		MsUnLock()
		PutMv("XM_USASTAT", cLoteFor )
	EndIf
	rstmvbuff()
	MsgInfo("Configurações gerais(2) atualizadas com sucesso!")
Return

**************************************************************************************************
Static Function SetCfgCte(cForceCte,cCteDet,cCSol,cCCNfOr,cCteAvi,cAglCTE,cNfOri,cIcmCte,cTpMCte,cBxCteT)
**************************************************************************************************
//Local Nx := 0
//Local cError   := ""
Local cDir     := AllTrim(SuperGetMv("MV_X_PATHX"))
Local cDirMCT  := AllTrim(cDir+cBarra+"MCTE"+cBarra)

	/********************************/
	If !PutMv("XM_FORCET3", cForceCte ) 
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_FORCET3"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Informa se força a busca pelo tomador do CT-e." 
		MsUnLock()
		PutMv("XM_FORCET3", cForceCte ) 
	EndIf	 

	/********************************/
	If !PutMv("XM_CTE_DET", cCteDet )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_CTE_DET"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Detalha Notas Fiscias nos itens de CTE."
		MsUnLock()
		PutMv("XM_CTE_DET", cCteDet ) 
	EndIf	

	/********************************/
	If !PutMv("XM_CSOL", cCSol )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_CSOL"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Amarra C.Custo de Qual Cadastro?"
		SX6->X6_DESC1   := "S - Ped.Compra; N - Cad.Produto; A-Ambos."
		MsUnLock()
		PutMv("XM_CSOL", cCSol ) 
	EndIf

	/********************************/
	If !PutMv("XM_CCNFOR", cCCNfOr )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_CCNFOR"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "C.Custo da NF Origem para CTE?"
		SX6->X6_DESC1   := ""
		MsUnLock()
		PutMv("XM_CCNFOR", cCCNfOr )
	EndIf

	/********************************/
	If !PutMv("XM_CTE_AVI", cCteAvi )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_CTE_AVI"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Mostrar Avisos de Detalhe de CTE?"
		MsUnLock()
		PutMv("XM_CTE_AVI", cCteAvi )
	EndIf

    /********************************/
	If !PutMv("XM_AGLMCTE", cAglCTE )  //inclusao do parametro para aglutinaçao de CTE
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_AGLMCTE"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Aglutina multiplos CTE S=Sim ou N=Nao"
		MsUnLock()
		PutMv("XM_AGLMCTE", cAglCTE )
	EndIf

	/********************************/
	If !PutMv("XM_NFORI", cNfOri )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_NFORI"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Amarra NF Origem pelo Livro Fiscal(Entradas)?"
		SX6->X6_DESC1   := "S - Livro Fiscal(SF3); N - NF Saida(SF2)."
		MsUnLock()
		PutMv("XM_NFORI", cNfOri ) 
	EndIf

	/********************************/
	If !PutMv("XM_ICMSCTE", cIcmCte )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_ICMSCTE"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Considera ICMS no CTE? (S/N)"
		SX6->X6_DESC1   := "S - Prencher D1_BASICM conforme TAG xml"
		MsUnLock()
		PutMv("XM_ICMSCTE", cIcmCte )
	EndIf

	/********************************/
	If !PutMv("XM_TPMCTE", cTpMCte )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_TPMCTE"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Tipo Multiplos CTE"
		SX6->X6_DESC1   := " 1=Fornecedor, 2=Da Pasta, 3=Ambos"
		MsUnLock()
		PutMv("XM_TPMCTE", cTpMCte )
	EndIf
	
	If !PutMv("XM_BXCTETM", cBxCteT )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_BXCTETM"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Baixar Apenas Cte Tomador?"
		MsUnLock()
		PutMv("XM_BXCTETM", cBxCteT )
	EndIf
	If !ExistDir(cDirMCT)
		Makedir(cDirMCT)
	EndIf
	
	rstmvbuff()
	MsgInfo("Configurações CTe atualizadas com sucesso!")
Return

*****************************************************************************************************************************
Static Function SetCfgInt(cItAtFTP,cItAtLOG,cItAtPAS,cItAtJob,cItAtDia,cItAtMes,cItAtAnC,cItAtHrC,cItAtPOR,cItAtDIR,cItAtPRT) 
*****************************************************************************************************************************

	/********************************/
	If !PutMv("XM_ITATFTP", cItAtFTP )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_ITATFTP"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Caminho URL do FTP"
		SX6->X6_DESC1   := ""
		MsUnLock()
		PutMv("XM_ITATFTP", cItAtFTP )
 	EndIf

	/********************************/
	If !PutMv("XM_ITATLOG", cItAtLOG )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_ITATLOG"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Usuário do FTP"
		SX6->X6_DESC1   := "Para Integração Externa"
		MsUnLock()
		PutMv("XM_ITATLOG", cItAtLOG )
 	EndIf

	/********************************/
	If !PutMv("XM_ITATPAS", Encode64(AllTrim(cItAtPAS)) )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_ITATPAS"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Senha para Integração Externa"
		SX6->X6_DESC1   := ""
		MsUnLock()
		PutMv("XM_ITATPAS", Encode64(AllTrim(cItAtPAS)) )
//		cPass    := Padr(Decode64(GetNewPar("XM_ITATPAS",Space(50))),50)
//      Encode64(AllTrim(cPass))
//		v_-w@D$1k!nncY_
//                  Padr(Decode64(GetNewPar("XM_ITATPAS",Space(50))),50)
 	EndIf

	/********************************/
	If !PutMv("XM_ITATJOB", cItAtJob )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_ITATJOB"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Agendamento Integração Externa? (0/1)"
		SX6->X6_DESC1   := "1-Habilita/0-Desabilita JOB para rodar Robóticamente"
		MsUnLock()
		PutMv("XM_ITATJOB", cItAtJob )
 	EndIf

 	/********************************/
	If !PutMv("XM_ITATDIA", cItAtDia )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_ITATDIA"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Dia da Semana"
		SX6->X6_DESC1   := "para rodar integração Robóticamente"
		MsUnLock()
		PutMv("XM_ITATDIA", cItAtDia )
 	EndIf

	/********************************/
	If !PutMv("XM_ITATMES", cItAtMes )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_ITATMES"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Mês para rodar integração Robótica"
		SX6->X6_DESC1   := ""
		MsUnLock()
		PutMv("XM_ITATMES", cItAtMes )
 	EndIf

	/********************************/
	If !PutMv("XM_ITATANC", cItAtAnC )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_ITATANC"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Ano/Mês para rodar integração Robótica"
		SX6->X6_DESC1   := ""
		MsUnLock()
		PutMv("XM_ITATANC", cItAtAnC )
 	EndIf

	/********************************/
	If !PutMv("XM_ITATHRC", cItAtHrC )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_ITATHRC"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Hora inicio para integração Robótica"
		SX6->X6_DESC1   := ""
		MsUnLock()
		PutMv("XM_ITATHRC", cItAtHrC )
 	EndIf

	/********************************/
	If !PutMv("XM_ITATPOR", cItAtPOR )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_ITATPOR"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Caminho PORTA do FTP"
		SX6->X6_DESC1   := ""
		MsUnLock()
		PutMv("XM_ITATPOR", cItAtPOR )
 	EndIf

	/********************************/
	If !PutMv("XM_ITATDIR", cItAtDIR )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_ITATDIR"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Diretório onde estão os arquivos no FTP"
		SX6->X6_DESC1   := ""
		MsUnLock()
		PutMv("XM_ITATDIR", cItAtDIR )
 	EndIf

	/********************************/
	If !PutMv("XM_ITATPRT", cItAtPRT )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_ITATPRT"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Protocolo 1-FTP 2=SFTP(SSH)"
		SX6->X6_DESC1   := ""
		MsUnLock()
		PutMv("XM_ITATPRT", cItAtPRT )
 	EndIf

	rstmvbuff()
	MsgInfo("Configurações Integração Externa atualizadas com sucesso!")
Return

***************************************************************************************
Static Function SetCfgClA(cClAt,cClAtJob,cClAtDia,cClAtMes,cClAtAnC,cClAtHrC,cClAtRBT,cTESNFE,cTESCTE,cClAtpClass,cAutoZBC,cTESZBC,cCCZBC,cCondZBC,cCfopComb) 
***************************************************************************************
Local lProssegue := .T.

	If cClatRBT = '3'
		If !fTemX6(cClAtRBT,cTESNFE,cTESCTE,.T.)
			lProssegue := .F.
		Endif			
	Endif
	
	If lProssegue
		/********************************/
		If !PutMv("XM_CLAT", cClAt )
			RecLock("SX6",.T.)
			SX6->X6_FIL     := xFilial("SX6")
			SX6->X6_VAR     := "XM_CLAT"
			SX6->X6_TIPO    := "C"
			SX6->X6_DESCRIC := "Utiliza Classificação Robótica? (S/N)"
			SX6->X6_DESC1   := "Atendendo Regra do Cadastro Classific.Aut.NF"
			MsUnLock()
			PutMv("XM_CLAT", cClAt )
		EndIf
	
		/********************************/
		If !PutMv("XM_CLATJOB", cClAtJob )
			RecLock("SX6",.T.)
			SX6->X6_FIL     := xFilial("SX6")
			SX6->X6_VAR     := "XM_CLATJOB"
			SX6->X6_TIPO    := "C"
			SX6->X6_DESCRIC := "Agendamento Classificação Robótica? (0/1)"
			SX6->X6_DESC1   := "1-Habilita/0-Desabilita JOB para rodar Robóticamente"
			MsUnLock()
			PutMv("XM_CLATJOB", cClAtJob )
		EndIf
	
	 	/********************************/
		If !PutMv("XM_CLATDIA", cClAtDia )
			RecLock("SX6",.T.)
			SX6->X6_FIL     := xFilial("SX6")
			SX6->X6_VAR     := "XM_CLATDIA"
			SX6->X6_TIPO    := "C"
			SX6->X6_DESCRIC := "Dia da Semana"
			SX6->X6_DESC1   := "para rodar classificação Robóticamente"
			MsUnLock()
			PutMv("XM_CLATDIA", cClAtDia )
	 	EndIf
	
		/********************************/
		If !PutMv("XM_CLATMES", cClAtMes )
			RecLock("SX6",.T.)
			SX6->X6_FIL     := xFilial("SX6")
			SX6->X6_VAR     := "XM_CLATMES"
			SX6->X6_TIPO    := "C"
			SX6->X6_DESCRIC := "Mês para rodar classificação Robótica"
			SX6->X6_DESC1   := ""
			MsUnLock()
			PutMv("XM_CLATMES", cClAtMes )
	 	EndIf
	
		/********************************/
		If !PutMv("XM_CLATANC", cClAtAnC )
			RecLock("SX6",.T.)
			SX6->X6_FIL     := xFilial("SX6")
			SX6->X6_VAR     := "XM_CLATANC"
			SX6->X6_TIPO    := "C"
			SX6->X6_DESCRIC := "Ano/Mês para rodar classificação Robótica"
			SX6->X6_DESC1   := ""
			MsUnLock()
			PutMv("XM_CLATANC", cClAtAnC )
	 	EndIf
	
		/********************************/
		If !PutMv("XM_CLATHRC", cClAtHrC )
			RecLock("SX6",.T.)
			SX6->X6_FIL     := xFilial("SX6")
			SX6->X6_VAR     := "XM_CLATHRC"
			SX6->X6_TIPO    := "C"
			SX6->X6_DESCRIC := "Hora inicio para classificação Robótica"
			SX6->X6_DESC1   := ""
			MsUnLock()
			PutMv("XM_CLATHRC", cClAtHrC )
	 	EndIf
	 	
	 	/********************************/
		If !PutMv("XM_CLATRBT", cClAtRBT )	//FR - 21/11/19
			RecLock("SX6",.T.)
			SX6->X6_FIL     := xFilial("SX6")
			SX6->X6_VAR     := "XM_CLATRBT"
			SX6->X6_TIPO    := "C"
			SX6->X6_DESCRIC := "Regra para Robotização Classificação Robótica""
			SX6->X6_DESC1   := "1=Pergunta múltiplos;2=Multiplos NFE e CTE;3=CTE;4=TES Cad.Produto;5=Não Utilizado"
			MsUnLock()
			PutMv("XM_CLAT", cClAtRBT ) 
			
		EndIf
		
		/********************************/
		If !PutMv("XM_NFE_TES", cTESNFE )	//FR - 05/12/19
			RecLock("SX6",.T.)
			SX6->X6_FIL     := xFilial("SX6")
			SX6->X6_VAR     := "XM_NFE_TES"
			SX6->X6_TIPO    := "C"
			SX6->X6_DESCRIC := "TES para Classificação Robótica de NFe"
			SX6->X6_DESC1   := ""
			MsUnLock()
			PutMv("XM_NFE_TES", cTESNFE ) 
			
		EndIf
		
		/********************************/
		If !PutMv("XM_CTE_TES", cTESCTE )	//FR - 05/12/19
			RecLock("SX6",.T.)
			SX6->X6_FIL     := xFilial("SX6")
			SX6->X6_VAR     := "XM_CTE_TES"
			SX6->X6_TIPO    := "C"
			SX6->X6_DESCRIC := "TES para Classificação Robótica de NF CTe"
			SX6->X6_DESC1   := ""
			MsUnLock()
			PutMv("XM_CTE_TES", cTESCTE ) 
			
		EndIf
		If !PutMv("XM_CLATPNF", cClAtpClass )	//FR - 22/09/2020
			RecLock("SX6",.T.)
			SX6->X6_FIL     := xFilial("SX6")
			SX6->X6_VAR     := "XM_CLATPNF"
			SX6->X6_TIPO    := "C"
			SX6->X6_DESCRIC := "Tipos de NF para Classificação Robótica"
			SX6->X6_DESC1   := ""
			MsUnLock()
			PutMv("XM_CLATPNF", cClAtpClass ) 
			
		EndIf
		If !PutMv("XM_ZBCAUTO", cAutoZBC )	//FR - 28/10/2021
			RecLock("SX6",.T.)
			SX6->X6_FIL     := xFilial("SX6")
			SX6->X6_VAR     := "XM_ZBCAUTO"
			SX6->X6_TIPO    := "C"
			SX6->X6_DESCRIC := "Cadastra Amarra. Automat?"
			SX6->X6_DESC1   := ""
			MsUnLock()
			PutMv("XM_ZBCAUTO", cAutoZBC ) 
		Endif 

		If !PutMv("XM_ZBCTES", cTESZBC )	//FR - 28/10/2021
			RecLock("SX6",.T.)
			SX6->X6_FIL     := xFilial("SX6")
			SX6->X6_VAR     := "XM_ZBCTES"
			SX6->X6_TIPO    := "C"
			SX6->X6_DESCRIC := "TES Amarra. Automat?"
			SX6->X6_DESC1   := ""
			MsUnLock()
			PutMv("XM_ZBCTES", cTESZBC ) 
		Endif

		If !PutMv("XM_ZBCCC", cCCZBC )	//FR - 28/10/2021
			RecLock("SX6",.T.)
			SX6->X6_FIL     := xFilial("SX6")
			SX6->X6_VAR     := "XM_ZBCCC"
			SX6->X6_TIPO    := "C"
			SX6->X6_DESCRIC := "Centro Custo Amarra. Automat?"
			SX6->X6_DESC1   := ""
			MsUnLock()
			PutMv("XM_ZBCCC", cCCZBC ) 
		Endif 

		 
		If !PutMv("XM_ZBCCOND", cCondZBC )	//FR - 28/10/2021
			RecLock("SX6",.T.)
			SX6->X6_FIL     := xFilial("SX6")
			SX6->X6_VAR     := "XM_ZBCCOND"
			SX6->X6_TIPO    := "C"
			SX6->X6_DESCRIC := "Cond.Pagto Amarra. Automa"
			SX6->X6_DESC1   := ""
			MsUnLock()
			PutMv("XM_ZBCCOND", cCondZBC ) 
		Endif 
		//FR - 05/08/2022 - PROJETO POLITEC
		If !PutMv("XM_CFOCOMB", cCfopComb )	//FR - 28/10/2021
			RecLock("SX6",.T.)
			SX6->X6_FIL     := xFilial("SX6")
			SX6->X6_VAR     := "XM_CFOCOMB"
			SX6->X6_TIPO    := "C"
			SX6->X6_DESCRIC := "Informa CFOPs XML Combustivel"
			SX6->X6_DESC1   := "Classif. direto via XML"
			MsUnLock()
			PutMv("XM_CFOCOMB", cCfopComb ) 
		Endif
		rstmvbuff()
		MsgInfo("Configurações Classificação de Integração atualizadas com sucesso!")
	Else
		MsgAlert("Parâmetros Não Atualizados, Por Favor, Verificar as Regras de Classificação Robótica")
	Endif


Return          


*************************************************************
Static Function fTemX6(cClatRBT, cTESNFE, cTESCTE,lTudOK) 
*************************************************************	
Local lRet   := .T.
Local cMsg   := ""

	If cClatRBT <> '3' //FR - 25/11/19 - TES para CTE, parâmetro XM_CTE_TES / XM_NFE_TES precisa estar preenchido, validar se .T. ou .F.
		Return(lRet)
	Endif
	
	cMsg := "Quando utilizada a opção '3-Multiplos NFE/CTE', é necessário preencher o(s) Parâmetro(s):" + CRLF + CRLF
	
	If lTudOK		//a validação é para todos os campos
		If cClatRBT = '3'
			If Empty(cTESNFE)
				lRet := .F.
				cMsg += "'TES Automat.NFE' --> vazio" + CRLF
			Endif
			
			If Empty(cTESCTE)
				lRet := .F.
				cMsg += "'TES Automat.CTE' --> vazio" + CRLF
			Endif		
		Endif
	Else		//a validação é para um campo em específico
		If cClatRBT = '3'
			If cTESNFE <> NIL
				If Empty(cTESNFE)
					lRet := .F.
					cMsg += "'TES Automat.NFE' --> vazio" + CRLF
				Endif
			Else
				lRet := .T.
			Endif
			
			If cTESCTE <> NIL
				If Empty(cTESCTE)
					lRet := .F.
					cMsg += "'TES Automat.CTE' --> vazio" + CRLF
				Endif
			Else
				lRet := .T.
			Endif
		Else
			lRet := .T.
		Endif
	Endif
	
	If !lRet
		MsgAlert(cMsg)				
	Endif
	
Return(lRet)

*************************************************************************************************************************************************
Static Function SetCfgCfo(cCfDevol,cCfBenef,cCfTrans,cCfCompl,cCfVenda,cCfRemes,cCfBonif)
*************************************************************************************************************************************************

	/********************************/
	If !PutMv("XM_CFDEVOL", cCfDevol ) 
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_CFDEVOL"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Cfops de devolução em entradas de NF-e."
		MsUnLock()
		PutMv("XM_CFDEVOL", cCfDevol ) 
	EndIf
 
	/********************************/
	If !PutMv("XM_CFBENEF", cCfBenef ) 
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_CFBENEF"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Cfops de beneficiamento em entradas de NF-e."
		MsUnLock()
		PutMv("XM_CFBENEF", cCfBenef ) 
	EndIf

 
	/********************************/
	If !PutMv("XM_CFTRANS", cCfTrans ) 
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_CFTRANS"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "CFOP de transferencia de NF-e."
		MsUnLock()
		PutMv("XM_CFTRANS", cCfTrans ) 
	EndIf
	
	/********************************/
	If !PutMv("XM_CFCOMPL", cCfCompl ) 
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_CFCOMPL"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "CFOP de complemento de NF-e."
		MsUnLock()
		PutMv("XM_CFCOMPL", cCfCompl ) 
	EndIf

	/********************************/
	If !PutMv("XM_CFVENDA", cCfVenda ) 
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_CFVENDA"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "CFOP de Vendas"
		MsUnLock()
		PutMv("XM_CFVENDA", cCfVenda ) 
	EndIf

	/********************************/
	If !PutMv("XM_CFREMES", cCfRemes ) 
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_CFREMES"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "CFOP de Remessa"
		MsUnLock()
		PutMv("XM_CFREMES", cCfRemes ) 
	EndIf

	/********************************/
	If !PutMv("XM_CFBONIF", cCfBonif ) 
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_CFBONIF"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "CFOP de Bonificacao"
		MsUnLock()
		PutMv("XM_CFBONIF", cCfBonif ) 
	EndIf	
	
	rstmvbuff()
	MsgInfo("Configurações CFOP atualizadas com sucesso!")

Return

*************************************************************************************************************************************************
Static Function SetCfgNuve(cCloud,cClTipo,cClToken,nClID,nClPlano,nClStPla,nClForma,cClArea,cClEmail,cClNome,cClRamal,cClSenha,cClTelFx,cClTelMv,cStatNF)
*************************************************************************************************************************************************

    /********************************/
	If !PutMv("XM_CLOUD", cCloud )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_CLOUD"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Utiliza Integração na Nuvem S=Sim ou N=Nao"
		MsUnLock()
		PutMv("XM_CLOUD", cCloud )
	EndIf

    /********************************/
	If !PutMv("XM_CLTIPO", cClTipo )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_CLTIPO"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Tipo da Integação"
		MsUnLock()
		PutMv("XM_CLTIPO", cClTipo )
	EndIf

    /********************************/
	If !PutMv("XM_CLTOKEN", cClToken )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_CLTOKEN"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Token Cloud"
		MsUnLock()
		PutMv("XM_CLTOKEN", cClToken )
	EndIf

    /********************************/
	If !PutMv("XM_STATXML", cStatNF )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_STATXML"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Habilita gravação de status na nuvem"
		MsUnLock()
		PutMv("XM_STATXML", cStatNF )
	EndIf
	
	U_HFCLDSVX(nClID,nClPlano,nClStPla,nClForma,cClArea,cClEmail,cClNome,cClRamal,cClSenha,cClTelFx,cClTelMv,cStatNF)
	
	rstmvbuff()
	MsgInfo("Configurações Integração Cloud atualizadas com sucesso!")

Return

//FR - 14/11/2022 - PROJETO COPAG VALIDAÇÃO SEFAZ AMAZONAS
*************************************************************************************************************************************************
Static Function SetCfgFisc(cCfExSped,cSpedFisc,cCfDevol,cCfBenef,cCfTrans,cCfCompl,cCfVenda,cCfRemes,cCfBonif) 
*************************************************************************************************************************************************
//cCfExSped := Padr(GetNewPar("XM_CFEXSPD",Space(256)),256)  //Cfops exceção ao SPED
//cSpedFisc := GetNewPar("XM_SPEDFIS","N")

	
	/********************************/
	If !PutMv("XM_CFEXSPD", cCfExSped )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_CFEXSPD"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "CFOPs informados aqui de NFs que não serão "	//max 50 caracteres
		SX6->X6_DESC1   := "enviadas no sped buscando informações do xml."	//max 50 caracteres
		SX6->X6_DESC2   := "CFOPs exceçao no sped fiscal." 				//max 50 caracteres
		MsUnLock()
		PutMv("XM_CFEXSPD", cCfExSped )
	EndIf

    /********************************/
	If !PutMv("XM_SPEDFIS", cSpedFisc )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_SPEDFIS"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Habilita se irá mostrar no Rel.Pre-Auditoria"  //max 50 caracteres
		SX6->X6_DESC1   := "Fiscal críticas relacionados ao sped fiscal. " //max 50 caracteres
		SX6->X6_DESC2   := "S=Sim -> Habilita; N=Não -> Desabilita" 		//max 50 caracteres
		
		MsUnLock()
		PutMv("XM_SPEDFIS", cSpedFisc )
	EndIf

	/********************************/
	If !PutMv("XM_CFDEVOL", cCfDevol ) 
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_CFDEVOL"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Cfops de devolução em entradas de NF-e."
		MsUnLock()
		PutMv("XM_CFDEVOL", cCfDevol ) 
	EndIf
 
	/********************************/
	If !PutMv("XM_CFBENEF", cCfBenef ) 
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_CFBENEF"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Cfops de beneficiamento em entradas de NF-e."
		MsUnLock()
		PutMv("XM_CFBENEF", cCfBenef ) 
	EndIf
 
	/********************************/
	If !PutMv("XM_CFTRANS", cCfTrans ) 
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_CFTRANS"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "CFOP de transferencia de NF-e."
		MsUnLock()
		PutMv("XM_CFTRANS", cCfTrans ) 
	EndIf
	
	/********************************/
	If !PutMv("XM_CFCOMPL", cCfCompl ) 
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_CFCOMPL"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "CFOP de complemento de NF-e."
		MsUnLock()
		PutMv("XM_CFCOMPL", cCfCompl ) 
	EndIf 	
	
	/********************************/
	If !PutMv("XM_CFVENDA", cCfVenda ) 
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_CFVENDA"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "CFOP de Vendas"
		MsUnLock()
		PutMv("XM_CFVENDA", cCfVenda ) 
	EndIf

	/********************************/
	If !PutMv("XM_CFREMES", cCfRemes ) 
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_CFREMES"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "CFOP de Remessa"
		MsUnLock()
		PutMv("XM_CFREMES", cCfRemes ) 
	EndIf

	/********************************/
	If !PutMv("XM_CFBONIF", cCfBonif ) 
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_CFBONIF"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "CFOP de Bonificacao"
		MsUnLock()
		PutMv("XM_CFBONIF", cCfBonif ) 
	EndIf	
		
	rstmvbuff()
	MsgInfo("Configurações 'Fiscal' atualizadas com sucesso!")

Return
//-----------------------------------------------------------//
//FR - 14/11/2022 - PROJETO COPAG VALIDAÇÃO SEFAZ AMAZONAS
//-----------------------------------------------------------//




//Rotina para testar conexão pop ou imap
Static Function TestPop(cServer,cUser,cMailConta,cPassword,lSMTPAuth,lSSL,lTLS,cProtocolE,cPortRec,aSMTP) 

	//Local nResult := 0
	Local nTimeOut     := 30
	Local __MailServer := TMailManager():New()
	Local __MailError  := 0
	
	//TMailManager(): Init ( < cMailServer>, < cSmtpServer>, < cAccount>, < cPassword>, [ nMailPort], [ nSmtpPort] ) 
	if lSSL
		__MailServer:SetUseSSL( lSSL )
	endif
	
	if lTLS
		__MailServer:SetUseTLS( lTLS )
	Endif
	
	if lSMTPAuth .and. !Empty(aSmtp) 

		cPopSMTP  := aSmtp[1]
		cPortSMTP := aSmtp[8]

		__MailServer:Init(AllTrim(cServer), Alltrim(cPopSMTP), AllTrim(cMailConta), AllTrim(cPassword) ,Val(cPortRec), Val(cPortSMTP))

	else

		__MailServer:Init(AllTrim(cServer),'', AllTrim(cMailConta), AllTrim(cPassword) ,Val(cPortRec))

	endif

	if cProtocolE == "2"

		__MailError := __MailServer:ImapConnect()

		If __MailError == 0
			MsgInfo( "Conexão Imap realizado com sucesso" )
		else
    		MsgInfo( "Erro: " + "Usuário, senha ou configurações do servidor inválidos " + cValToChar(__MailError) + " - " + __MailServer:GetErrorString( __MailError ) )
  		EndIf

		__MailServer:IMAPDisconnect()

	else

		__MailError	:= __MailServer:SetPopTimeOut( nTimeOut )

		If __MailError == 0
			conout( "Timeout com setado com sucesso" )
		Else
			MsgInfo( "Erro: " + cValToChar(__MailError) + " - " + __MailServer:GetErrorString( __MailError ) )
		Endif

		__MailError := __MailServer:PopConnect()

		If __MailError == 0
    		MsgInfo( "Conexão Pop realizado com sucesso" )
		Else
			MsgInfo( "Erro: " + "Usuário, senha ou configurações do servidor inválidos " + cValToChar(__MailError) + " - " + __MailServer:GetErrorString( __MailError ) )
		Endif

		__MailServer:PopDisconnect()

	endif

Return


*****************************************************************************************************
Static Function TestMail(cMailServer,cLogin,cMailConta,cMailSenha,lSMTPAuth,lSSL,cProtocolE,cPortEnv) 
*****************************************************************************************************
//Local Nx := 0
//Local aDadosMail :={}
Local oDlg     := NIL
//Local cMask    := "Todos os arquivos (*.*) |*.*|"
Local oMsg

Private cTitulo  := "Criar e-mail"
Private cServer  := cMailServer
Private cEmail   := cMailConta
Private cPass    := cMailSenha

Private cDe      := cMailConta
Private cPara    := Padr(cMailConta,200) // Space(200)
Private cCc      := Space(200)
Private cAssunto := "Teste de Configuração Importa XML" // Space(200)
Private cAnexo   := Space(200)
Private cMsg     := ""
                      
If Empty(cServer) .And. Empty(cEmail) .And. Empty(cPass)
   MsgAlert("Não foi definido os parâmetros do server do Protheus para envio de e-mail",cTitulo)
   Return
Endif
cMsg := "Este é um e-mail de teste de configuração de SMTP do importa XML."+CRLF
cMsg += "Data : "+Dtoc(dDataBase)+CRLF 
cMsg += "Hora : "+Time()+CRLF      
cMsg += "Usuario : "+Substr(cUsuario,7,15)+CRLF                                             

DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO 350,570 OF oDlg PIXEL

@  3,3 SAY "De"   SIZE 30,7 PIXEL OF oDlg
@ 15,3 SAY "Para" SIZE 30,7 PIXEL OF oDlg
@ 27,3 SAY "Cc"       SIZE 30,7 PIXEL OF oDlg
@ 39,3 SAY "Assunto"  SIZE 30,7 PIXEL OF oDlg
@ 51,3 SAY "Anexo"    SIZE 30,7 PIXEL OF oDlg
@ 63,3 SAY "Mensagem" SIZE 30,7 PIXEL OF oDlg

@  2, 35 MSGET cDe      PICTURE "@" SIZE 248, 7 PIXEL OF oDlg READONLY
@ 14, 35 MSGET cPara    PICTURE "@" SIZE 248, 7 PIXEL OF oDlg
@ 26, 35 MSGET cCc      PICTURE "@" SIZE 248, 8 PIXEL OF oDlg
@ 38, 35 MSGET cAssunto PICTURE "@" SIZE 248, 8 PIXEL OF oDlg
@ 50, 35 MSGET cAnexo   PICTURE "@" SIZE 233, 8 PIXEL OF oDlg When .F.
//@ 49,269 BUTTON "..." SIZE 13,11 PIXEL OF oDlg ACTION cAnexo:=AllTrim(cGetFile(cMask,"Inserir anexo"))
@ 62, 35 GET oMsg VAR cMsg MEMO SIZE 248,93 PIXEL OF oDlg 

@ 160,210 BUTTON "&Enviar"    SIZE 36,13 PIXEL ACTION (lOpc:=Validar(),Iif(lOpc,Eval({||SendMail(cDe,cPara,cCc,cAssunto,cAnexo,cMsg),oDlg:End()}),NIL))
@ 160,248 BUTTON "&Abandonar" SIZE 36,13 PIXEL ACTION oDlg:End()

ACTIVATE MSDIALOG oDlg CENTERED

Return

*************************************************************
Static Function SendMail(cDe,cPara,cCc,cAssunto,cAnexo,cMsg)
*************************************************************
Local nret   := 0
Local cError := "" 
//Local cRet   := ""
  
    aTo := Separa(cPara,";")
//    MsgRun("Testanto envio...","E-mail / SMTP",{|| nRet:= 	U_HX_MAIL(aTo,cAssunto,cMsg,@cError,cAnexo,cAnexo,cPara,cCc) })                              
    MsgRun("Testanto envio...","E-mail / SMTP",{|| nRet:= 	U_MAILSEND(aTo,cAssunto,cMsg,@cError,cAnexo,cAnexo,cPara,cCc) })  
    
	If nRet == 0 .And. Empty(cError)
		U_MyAviso("Aviso","E-mail enviado com sucesso!",{"OK"})
	Else
		cError += U_MailErro(nRet)                  
		U_MyAviso("Aviso",cError,{"OK"},3)
	EndIf

Return(nret)
           

*************************
Static Function Validar()
*************************
	Local lRet := .T.
	If Empty(cDe)
	   MsgInfo("Campo 'De' preenchimento obrigatório",cTitulo)
	   lRet:=.F.
	Endif
	If Empty(cPara) .And. lRet
	   MsgInfo("Campo 'Para' preenchimento obrigatório",cTitulo)
	   lRet:=.F.
	Endif
	If Empty(cAssunto) .And. lRet
	   MsgInfo("Campo 'Assunto' preenchimento obrigatório",cTitulo)
	   lRet:=.F.
	Endif
	
	If lRet
	   cDe      := AllTrim(cDe)
	   cPara    := AllTrim(cPara)
	   cCC      := AllTrim(cCC)
	   cAssunto := AllTrim(cAssunto)
	   cAnexo   := AllTrim(cAnexo)
	Endif
	
RETURN(lRet)

********************************
Static Function ShowLogo(aPages)
********************************
	Local Nx := 0
	Local nLogo := 2
	For Nx := 1 to Len(aPages)                               
	
	    If nLogo == 1
	        
			oBmp1          := TBITMAP():Create(oPage:aDialogs[Nx])
			oBmp1:cName    := "oBmp1"
			oBmp1:nWidth   := 50
			oBmp1:nHeight  := 50
			oBmp1:cBmpFile := "" //"HFCONSULT.JPG"
			oBmp1:lStretch := .T.   
			oBmp1:nTop     := 342                     
			oBmp1:nLeft    := 002                     
			
			@ 175,030 Say "By HF Consulting"   PIXEL OF oPage:aDialogs[Nx] COLOR CLR_BLACK FONT oFont01
			@ 185,030 Say "Telefone : (11) 5524-5124 "  PIXEL OF oPage:aDialogs[Nx] COLOR CLR_BLACK FONT oFont01
			
			oTHButton := THButton():New(178,130,"E-mail : comercial@hfbr.com.br",oPage:aDialogs[Nx],;
			                 {||ShellExecute("open","mailto:comercial@hfbr.com.br","","",3)},120,20,oFont01,"Contato")
		ElseIf nLogo == 2
		//	oBmp1          := TBITMAP():Create(oPage:aDialogs[Nx])
		//	oBmp1:cName    := "oBmp1"
		//	oBmp1:nWidth   := 170
		//	oBmp1:nHeight  := 50
	//		oBmp1:cBmpFile := "HFCONSULT2.JPG"
	//		oBmp1:lStretch := .T.   
	//		oBmp1:nTop     := 342                     
	//		oBmp1:nLeft    := 010
						
			@ 224,135 Say "Telefone : (11) 5524-5124 "  PIXEL OF oPage:aDialogs[Nx] COLOR CLR_BLACK FONT oFont01    //FR 19/05/2020
			
			oTHButton := THButton():New(225,124,"E-mail : comercial@hfbr.com.br",oPage:aDialogs[Nx],;              //FR 19/05/2020
			                 {||ShellExecute("open","mailto:comercial@hfbr.com.br","","",3)},120,20,oFont01,"Contato")
		
		EndIf
	Next
Return()
      
    


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  GetJobInfo ºAutor  ³Microsiga           º Data ³  26/02/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cria as perguntas do programa no dicionario de perguntas    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GetJobInfo(nTipo)

	Local cConteudo := ""
	Local cSepara   := ""
	Local cRefRat   := ""
	Local aParams   := {}
	Default nTipo   := 1
	
	cConteudo:= GetPvProfString('ONSTART','JOBS',"",GetAdv97())
	cRefRat   :=GetPvProfString('ONSTART','RefreshRate',"",GetAdv97())
	
	If !Empty(cConteudo)
		cSepara :=","
	EndIf
	
	If nTipo == 2
		If "IMP_XML" $ cConteudo
			WritePProString("IMP_XML",'MAIN','U_WF_XML01',GetAdv97())
			WritePProString("IMP_XML",'ENVIRONMENT',GetEnvServer(),GetAdv97())
	    Else
			WritePProString('ONSTART','JOBS',cConteudo+cSepara+"IMP_XML",GetAdv97())
			if empty(cRefRat)
				WritePProString('ONSTART','RefreshRate',"7200",GetAdv97())
			endif
			WritePProString("IMP_XML",'MAIN','U_WF_XML01',GetAdv97())
			WritePProString("IMP_XML",'ENVIRONMENT',GetEnvServer(),GetAdv97())
		EndIf		
	
	ElseIf nTipo == 3
	
		WritePProString('ONSTART','JOBS',StrTran(cConteudo,"IMP_XML",""),GetAdv97())
	
	EndIf
	
	Aadd(aParams,{'ONSTART' ,cConteudo,Iif("IMP_XML" $ cConteudo,"ATIVO","INATIVO")})

Return(aParams)



/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ HX_MAIL  ³ Autor ³ Roberto Souza         ³ Data ³27/06/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina que envia e-mail                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HX_MAIL(aTo,cSubject,cMsg,cError,cAnexo,cAnexo2,cEmailDest)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³ ExpA1 = aTo                                                ³±±
±±³          ³ ExpC2 = Subject                                            ³±±
±±³          ³ ExpC3 = Mensagem a ser enviada                             ³±±
±±³          ³ ExpC4 = Mensagem de erro retornada                    (OPC)³±±
±±³          ³ ExpC5 = Arquivo para anexar a mensagem                (OPC)³±±
±±³          ³ ExpC6 = Arquivo para anexar a mensagem                (OPC)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function HX_MAIL(aTo,cSubject,cMensagem,cError,cAnexo,cAnexo2,cEmailDest,cCCdest,cBCCdest)

	Local aSMTP       := U_XCfgMail(1,1,{})
	Local cMailServer := AllTrim(aSMTP[1]) //GetNewPar("XM_SMTP",Space(100))
	Local cLogin      := AllTrim(aSMTP[2]) //GetNewPar("XM_LOGIN",Space(100))
	Local cMailConta  := AllTrim(aSMTP[3]) //GetNewPar("XM_ACCOUNT",Space(100))
	Local cMailSenha  := AllTrim(aSMTP[4]) //Decode64(GetNewPar("XM_PASS",Space(100)))
	Local lSMTPAuth   := aSMTP[5] //GetNewPar("XM_AUT",Space(100))=="S"
	Local lSSL        := aSMTP[6] //GetNewPar("XM_SSL",Space(100))=="S"
	Local cThreadID   := "1"
	Local lOk         := .F.
	Local lSendOk     := .F.
	Local nX          := 0 
	Local oServer
	Local oMessage
	Local nRet        := 0
	//Local nNumMsg 	  := 0
	//Local nTam   	  := 0
	//Local nI     	  := 0
	Local nModel      := Val(GetSrvProfString("HF_MODOMAIL","1"))
	
	Default cSubject  := "Mensagem de Teste"
	//Default cMensagem := "Este é um email enviado Robóticamente pelo Gerenciador de Contas do Protheus durante o teste das configurações da sua conta SMTP."
	Default aTo       := {cMailConta}
	Default cError    := ""
	Default cEmailDest:= ""
	Default cCCdest   := ""
	Default cBCCdest  := ""
	
	cMsgCfg := ""
	cMsgCfg += '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
	cMsgCfg += '<html xmlns="http://www.w3.org/1999/xhtml">
	cMsgCfg += '<head>
	cMsgCfg += '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
	cMsgCfg += '<title>Importa XML</title>
	cMsgCfg += '  <style type="text/css"> 
	cMsgCfg += '	<!-- 
	cMsgCfg += '	body {background-color: rgb(37, 64, 97);} 
	cMsgCfg += '	.style1 {font-family: Segoe UI,Verdana, Arial;font-size: 12pt;} 
	cMsgCfg += '	.style2 {font-family: Segoe UI,Verdana, Arial;font-size: 12pt;color: rgb(255,0,0)} 
	cMsgCfg += '	.style3 {font-family: Segoe UI,Verdana, Arial;font-size: 10pt;color: rgb(37,64,97)} 
	cMsgCfg += '	.style4 {font-size: 8pt; color: rgb(37,64,97); font-family: Segoe UI,Verdana, Arial;} 
	cMsgCfg += '	.style5 {font-size: 10pt} 
	cMsgCfg += '	--> 
	cMsgCfg += '  </style>
	cMsgCfg += '</head>
	cMsgCfg += '<body>
	cMsgCfg += '<table style="background-color: rgb(240, 240, 240); width: 800px; text-align: left; margin-left: auto; margin-right: auto;" id="total" border="0" cellpadding="12">
	cMsgCfg += '  <tbody>
	cMsgCfg += '    <tr>
	cMsgCfg += '      <td colspan="2">
	cMsgCfg += '    <Center>
	cMsgCfg += '      <img src="http://extranet.helpfacil.com.br/images/cabecalho.jpg">
	cMsgCfg += '      </Center>
	cMsgCfg += '      <p class="style1">Este é um email enviado Robóticamente pelo Gerenciador de Contas do Protheus durante o teste das configurações da sua conta  de envio de notificações do Importa XML.</p>
	cMsgCfg += '      </td>
	cMsgCfg += '    </tr>
	cMsgCfg += '  </tbody>
	cMsgCfg += '</table>
	cMsgCfg += '<p class="style1">&nbsp;</p>
	cMsgCfg += '</body>
	cMsgCfg += '</html>
	Default cMensagem := cMsgCfg
	
	If !Empty(cMailServer) .And. !Empty(cMailConta) .And. !Empty(cMailSenha) .And. !Empty(cLogin)
	
		If nModel == 2	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| Cria o objeto d e e-mail                                                         |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oServer := TMailManager():New()  
			
			oServer:SetUseSSL(lSSL) 
			If lSMTPAuth
			//	MailAuth(cLogin,cMailSenha)
	        EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| Inicia o objeto d e e-mail                                                       |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    oServer:Init("", AllTrim(cMailServer), AllTrim(cMailConta), AllTrim(cMailSenha) )
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| Timeout de espera                                                                |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nRet := oServer:SetSmtpTimeOut( 30 )
			If nRet <> 0
				Return(nRet)
			EndIf
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| Conecta ao servidor de SMTP                                                      |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nRet := oServer:SmtpConnect()
			If nRet != 0
				Return(nRet)
			EndIf
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| Cria o Objeto da mensagem                                                        |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oMessage := TMailMessage():New()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| Limpa o Objeto da mensagem                                                       |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oMessage:Clear()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| Atribui o Objeto da mensagem                                                     |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oMessage:cFrom 		:= "Importa XML"
			oMessage:cTo 		:= cEmailDest
			oMessage:cCc 		:= cCCdest
			oMessage:cBcc 		:= cBCCdest
			oMessage:cSubject 	:= cSubject
			oMessage:cBody 		:= cMensagem
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| Processa os anexos                                                               |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(cAnexo)
				nRet := oMessage:AttachFile(cAnexo)
				If nRet != 0
					Return(nRet)
				Else
					oMessage:AddAtthTag( 'Content-Disposition: attachment; filename='+cAnexo)
				EndIf
			EndIf
			If !Empty(cAnexo2)
				nRet := oMessage:AttachFile(cAnexo2)
				If nRet != 0
					Return(nRet)
				Else
					oMessage:AddAtthTag( 'Content-Disposition: attachment; filename='+cAnexo2)				
				EndIf
			EndIf
				
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| Envia o E-mail                                                                   |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nRet := oMessage:Send( oServer )
			If nRet != 0
				Return(nRet)
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| Envia o E-mail                                                                   |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nRet := oServer:SmtpDisconnect()
			If nRet != 0
				Return(nRet)
			EndIf
	
	     Else
		                                                                                                                     
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| Conecta ao servidor de SMTP                                                      |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If __nHdlSMTP == 0
				If lSSL
					CONNECT SMTP SERVER cMailServer ACCOUNT cLogin PASSWORD cMailSenha RESULT lOk
				Else
					CONNECT SMTP SERVER cMailServer ACCOUNT cLogin PASSWORD cMailSenha RESULT lOk
				EndIf
				If lOk
					__nHdlSMTP := 1
				Else
					__nHdlSMTP := 0
				EndIf	
			Else 
				lSMTPAuth := .F.
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| Verifica se há necessidade de autenticacao                                       |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If __nHdlSMTP <> 0
				If ( lSMTPAuth )
					lOk := MailAuth(cLogin,cMailSenha)
				Else
					lOk := .T.
				EndIf
				If lOk
					__nHdlSMTP := 1
				Else
					GET MAIL ERROR cError
					ConOut(IIF(cThreadID=="1",'ThreadID='+AllTrim(Str(ThreadID(),15)),"")+" - Log SMTP: " + cError)
					MailFree()
				EndIf	
			EndIf
			If __nHdlSMTP <> 0
				For nX := 1 To Len(aTo)
					If !("@" $ aTo[nX])                                        
						cSubject += " - email de destino inválido ("+aTo[nX]+")"
						aTo[nX]  := cMailConta
					EndIf		
					If !Empty(cAnexo2)
						SEND MAIL FROM cMailConta to AllTrim(aTo[nX]) SUBJECT cSubject BODY cMensagem ATTACHMENT cAnexo,cAnexo2 RESULT lSendOk
					ElseIf !Empty(cAnexo)
						SEND MAIL FROM cMailConta to AllTrim(aTo[nX]) SUBJECT cSubject BODY cMensagem ATTACHMENT cAnexo RESULT lSendOk
					Else
						SEND MAIL FROM cMailConta to AllTrim(aTo[nX]) SUBJECT cSubject BODY cMensagem RESULT lSendOk
					EndIf
					If !lSendOk
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Erro no Envio do e-maIil                                                 ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						cEmailDest := aTo[nX]
						GET MAIL ERROR cError
						ConOut(IIF(cThreadID=="1",'ThreadID='+AllTrim(Str(ThreadID(),15)),"")+" - Log SMTP: " + cError)
						MailFree()
						Exit
					EndIf
				Next nX
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Erro na conexao com o SMTP Server ou na autenticacao da conta          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Empty(cError)
					GET MAIL ERROR cError
					ConOut(IIF(cThreadID=="1",'ThreadID='+AllTrim(Str(ThreadID(),15)),"")+" - Log SMTP: " + cError)
				EndIf
			EndIf
		EndIf
	EndIf	
	Return(__nHdlSMTP)   

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MailFree   ³ Autor ³Roberto Souza          ³ Data ³27/06/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina que desconecta o servidor de email                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MailFree                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GENERICO                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MailFree()
	
	If __nHdlSMTP == 1
		DISCONNECT SMTP SERVER
		__nHdlSMTP := 0
	EndIf
Return

******************************************
User Function LoadCfgX(nTipo,cFileX,aDefs)
******************************************
	
	//Local lRet     := .T.
	Local uRet     := Nil
	Local Nx       := 0
	Local NY       := 0
	Local cError   := ""
	Local cWarning := ""
	Local cXml     := ""
	Local cJobs    := ""
	Local nJobs    := 0
	//Local nAt1     := nAt2 := nAt3 := nAt4 := 0
	Local lLoadDef := .F.
	Private oXmlCfg                 
	Private aJobs  := ""
	Private aDados := {}
	Default nTipo  := 1
	Default cFileX := "hfcfgxml001a.xml"
	Default aDefs  := {}
	
	    
	If nTipo == 1 // Carrega  
		If File(cFileX)
			
			cXml := MemoRead(cFileX)    
			oXmlCfg := XmlParser( cXml, "_", @cError, @cWarning )  
			
			If Empty(cError) .And. Empty(cWarning) 
				If Type("oXmlCfg:_MAIN:_WFXML01:_JOBS:_JOB") == "A"
					aJobs := oXmlCfg:_MAIN:_WFXML01:_JOBS:_JOB
				Else
					aJobs := {oXmlCfg:_MAIN:_WFXML01:_JOBS}	
				EndIf
				nJobs := Len(aJobs)
				For Nx := 1 to nJobs
					cJobs += aJobs[Nx]:TEXT
					If Nx <  nJobs
					 	cJobs += ","
					EndIf
				Next
				uRet:=oXmlCfg
			Else
				lLoadDef := .T.				
			EndIf
			oXmlCfg:= Nil
		Else
			lLoadDef := .T.
		EndIf
		
	ElseIf nTipo == 2  //Salva 
		cXml    := MemoRead(cFileX)
		aDados  := aDefs
	    cXmlEnd := ""
	
	
		cXmlEnd += '<?xml version = "1.0" encoding = "UTF-8"?>'
		cXmlEnd += '<Main>'
		cXmlEnd += '<wfxml01 version="1.00">'
		            
		For Nx := 1 To Len(aDados)
			cTag   := Lower(aDados[Nx][1])
		    cTipo  := ValType(aDados[Nx][2])
			cDesc  := aDados[Nx][3]
			uText  := aDados[Nx][2]               
			cSubTag:= Left(cTag,Len(cTag)-1) 
	        
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
					cXmlEnd += '<'+cSubTag+'>'				
					cXmlEnd += xTag("xDesc","C"  ,cDesc, cSubTag)
					cXmlEnd += xTag("xType","C"  ,ValType(aProc[Ny]), cSubTag)
					cXmlEnd += xTag("xText",ValType(aProc[Ny]),aProc[Ny], cSubTag)	                                              
					cXmlEnd += '</'+cSubTag+'>'
	    		Next
				cXmlEnd += '</'+cTag+'>'
			
			EndIf
		Next
	
		cXmlEnd += '</wfxml01>'
		cXmlEnd += '</Main>'
		uRet    := cXmlEnd
	EndIf
	    
	If lLoadDef .Or. nTipo == 3
		uRet := '<?xml version = "1.0" encoding = "UTF-8"?><Main><wfxml01 version="1.00"><enable><xDesc>Servico Habilitado</xDesc><xType>C</xType><xText>1</xText></enable><ent><xDesc>Empresa/Filial principal do processo</xDesc><xType>C</xType><xText>9901</xText></ent><wfdelay><xDesc>Atraso apos a primeira execucao</xDesc><xType>N</xType><xText>5</xText></wfdelay><threadid><xDesc>Identificador de Thread [Debug]</xDesc><xType>C</xType><xText>1</xText></threadid><jobs><job><xDesc>Servico a ser processado</xDesc><xType>C</xType><xText>1</xText></job><job><xDesc>Servico a ser processado</xDesc><xType>C</xType><xText>2</xText></job><job><xDesc>Servico a ser processado</xDesc><xType>C</xType><xText>3</xText></job><job><xDesc>Servico a ser processado</xDesc><xType>C</xType><xText>4</xText></job><job><xDesc>Servico a ser processado</xDesc><xType>C</xType><xText>5</xText></job><job><xDesc>Servico a ser processado</xDesc><xType>C</xType><xText>6</xText></job></jobs><sleep><xDesc>Tempo de espera</xDesc><xType>N</xType><xText>600</xText></sleep><console><xDesc>Informacoes dos processos no console</xDesc><xType>C</xType><xText>1</xText></console></wfxml01></Main>'
		uRet := XmlParser( uRet, "_", @cError, @cWarning )  
	EndIf
	
	
	If nTipo==1 .And. uRet == Nil
		nAviso := 0
		nAviso := Aviso("Atencao","O Arquivo de configuração é inválido."+CRLF+"Deseja Carregar as configurações padrão?",{"Sim","Não"},3)
		If nAviso == 1
			MsgInfo("Carregamento Finalizado.")				
			//Desenvolver
		Else
			MsgInfo("Carregamento Abortado.")	
		EndIf
	EndIf

Return(uRet)         

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

****************************
User Function GetJob(cJobs)
****************************
	Local cRet := ""
	//Local aJobs:= {}
	//Local Nx   := 1
	Local oDlg                                                        
	Local oChkOnX, oChkOn1, oChkOn2, oChkOn3, oChkOn4, oChkOn5, oChkOn6, /*oChkOn7,*/ oChkOn8, oChkOn9
	Local lChkOnX  :=  ("X" $ cJobs)
	Local lChkOn1  :=  ("1" $ cJobs)
	Local lChkOn2  :=  ("2" $ cJobs)
	Local lChkOn3  :=  ("3" $ cJobs)
	Local lChkOn4  :=  ("4" $ cJobs)
	Local lChkOn5  :=  ("5" $ cJobs)
	Local lChkOn6  :=  ("6" $ cJobs)
	//Local lChkOn7  :=  ("7" $ cJobs)
	Local lChkOn8  :=  ("8" $ cJobs)
	Local lChkOn9  :=  ("9" $ cJobs)
	Local nOpc     := 0
	Private oFont01:= TFont():New("Arial",07,14,,.T.,,,,.T.,.F.)
	                                                                  
	DEFINE MSDIALOG oDlg TITLE "Seleção de Serviços [Jobs]" FROM 000,000 TO 400,400 PIXEL STYLE DS_MODALFRAME STATUS
	
	@ 00.5,00.5 to 011,024.5 OF oDlg   
	
	@ 010 ,010 SAY "Selecione os jobs a serem executados:" PIXEL OF oDlg COLOR CLR_BLUE FONT oFont01
	@ 020 ,010 CHECKBOX oChkOnX VAR lChkOnX PROMPT "X-Todos"            SIZE 65,8 PIXEL OF oDlg COLOR CLR_BLUE FONT oFont01//;
	//         ON CHANGE(Iif( lChkOnX ,(oChkOn1:LREADONLY:=.T.,lChkOn2:LREADONLY:=.T.,lChkOn3:LREADONLY:=.T.),;
	
	@ 035 ,010 CHECKBOX oChkOn1 VAR lChkOn1 PROMPT "1-Verificar E-mail" SIZE 65,8 PIXEL OF oDlg COLOR CLR_BLUE FONT oFont01
	//         ON CHANGE(Iif(!lChkOn1,lChkOnX:=.F.,Nil))
	
	@ 050 ,010 CHECKBOX oChkOn2 VAR lChkOn2 PROMPT "2-Validar Xml"      SIZE 65,8 PIXEL OF oDlg COLOR CLR_BLUE FONT oFont01
	//         ON CHANGE(Iif(!lChkOn2,lChkOnX:=.F.,Nil))
	
	@ 065 ,010 CHECKBOX oChkOn3 VAR lChkOn3 PROMPT "3-Checar Pré-Nota"  SIZE 65,8 PIXEL OF oDlg COLOR CLR_BLUE FONT oFont01
	//         ON CHANGE(Iif(!lChkOn3,lChkOnX:=.F.,Nil))
	
	@ 080 ,010 CHECKBOX oChkOn4 VAR lChkOn4 PROMPT "4-Consulta de xmls"  SIZE 95,8 PIXEL OF oDlg COLOR CLR_BLUE FONT oFont01 
	//         ON CHANGE(Iif(!lChkOn3,lChkOnX:=.F.,Nil))
	
	@ 095 ,010 CHECKBOX oChkOn5 VAR lChkOn5 PROMPT "5-Notificações por E-mail"  SIZE 95,8 PIXEL OF oDlg COLOR CLR_BLUE FONT oFont01
	//         ON CHANGE(Iif(!lChkOn3,lChkOnX:=.F.,Nil))
	
	@ 110 ,010 CHECKBOX oChkOn6 VAR lChkOn6 PROMPT "6-Download XML SEFAZ"  SIZE 95,8 PIXEL OF oDlg COLOR CLR_BLUE FONT oFont01
	//         ON CHANGE(Iif(!lChkOn3,lChkOnX:=.F.,Nil))

	//@ 125 ,010 CHECKBOX oChkOn7 VAR lChkOn7 PROMPT "7-Envia PDF Conversor"  SIZE 95,8 PIXEL OF oDlg COLOR CLR_BLUE FONT oFont01
	//         ON CHANGE(Iif(!lChkOn3,lChkOnX:=.F.,Nil))

	@ 125 ,010 CHECKBOX oChkOn8 VAR lChkOn8 PROMPT "8-Integração Conversão de Imagens"  SIZE 150,8 PIXEL OF oDlg COLOR CLR_BLUE FONT oFont01
	//         ON CHANGE(Iif(!lChkOn3,lChkOnX:=.F.,Nil))
	
	@ 140 ,010 CHECKBOX oChkOn9 VAR lChkOn9 PROMPT "9-Download NFSE API"  SIZE 150,8 PIXEL OF oDlg COLOR CLR_BLUE FONT oFont01
	oChkOnX:cToolTip := "Todas as rotinas disponíveis."
	oChkOn1:cToolTip := "Verificar E-mail e salvar arquivos no diretório indicado."
	oChkOn2:cToolTip := "Validar Xml quanto a estrutura e consulta junto a SEFAZ."
	oChkOn3:cToolTip := "Checar Pré-Nota e sincronizar os Status." 
	oChkOn4:cToolTip := "Consulta os Xmls já recebidos previamente, de acordo com os parametros configurados."+CRLF+"Atenção."+CRLF+"Esta opção somente pode ser habilitada para o Job de execução Robótica.[Configurações Job]"
	oChkOn5:cToolTip := "Enviar e-mails de notificação de erros e cancelamentos."
	oChkOn6:cToolTip := "Download XML SEFAZ, de acordo com Nota Tecnica 2012_002. Esta sujeito as regras da nota técnica."+CRLF+"Atenção."+CRLF+"Se a chave não estiver manifestada será manifestada com confirmação da Operação somente XML de dois dias ou mais atras."
	//oChkOn7:cToolTip := "Envia PDF para o Image Convertor na Nuvem, essa ferramenta converte o pdf pre configurado em xml.
	oChkOn8:cToolTip := "Envia PDF e baixa XML Convertido do Image Convertor e disponibiliza dentro da pasta xmlsource/imagem, essa rotina traz o pdf convertido em xml e importa para o protheus.
	oChkOn9:cToolTip := "Consulta as Notas das prefeituras via webservice."
	
	@ 160 ,110 Button "Cancela" Size 040,015 PIXEL OF oDlg ACTION oDlg:End()                                                        
	@ 160 ,155 Button "OK" Size 040,015 PIXEL OF oDlg ACTION (nOpc:=1,oDlg:End())                                                        
	
	ACTIVATE MSDIALOG oDlg CENTERED 
	
	If nOpc ==1
		If lChkOnX
			cRet := "X"
		Else
			cRet := ""
			If lChkOn1
				cRet += Iif(!Empty(cRet),",","" )+"1"
			EndIf
			If lChkOn2
				cRet += Iif(!Empty(cRet),",","" )+"2"
			EndIf
			If lChkOn3
				cRet += Iif(!Empty(cRet),",","" )+"3"
			EndIf
			If lChkOn4
				cRet += Iif(!Empty(cRet),",","" )+"4"
			EndIf
			If lChkOn5
				cRet += Iif(!Empty(cRet),",","" )+"5"
			EndIf							
			If lChkOn6
				cRet += Iif(!Empty(cRet),",","" )+"6"
			EndIf		
			//If lChkOn7
			//	cRet += Iif(!Empty(cRet),",","" )+"7"
			//EndIf
			If lChkOn8
				cRet += Iif(!Empty(cRet),",","" )+"8"
			EndIf							
			If lChkOn9
				cRet += Iif(!Empty(cRet),",","" )+"9"
			EndIf										
		EndIf	
	
	Else
		cRet := cJobs      
	Endif
Return(cRet)

*****************************
User Function MailErro(nErro) 
*****************************
	Local aErro := {}
	Local nCod  := 0
	Local xRet  := "" 
	Default nErro := 999  
	
	//aadd(aErro,{ 0,"Operation completed successfully.","SUCCESS "})
	aadd(aErro,{ 1,"Operation failed.","ERROR "})
	//aadd(aErro,{ ,"","// Connection errors"})
	aadd(aErro,{ 2,"The connection failed.","CONNECT_FAILED "})
	aadd(aErro,{ 3,"The connection was rejected.","CONNECT_REJECTED "})
	aadd(aErro,{ 4,"The connection was terminated.","CONNECT_TERMINATED "})
	aadd(aErro,{ 5,"The connection timed-out.","CONNECT_TIMEOUT "})
	aadd(aErro,{ 6,"There was no connection.","NOCONNECTION "})
	aadd(aErro,{ 7,"Name lookup failed.","NAME_LOOKUP_FAILED "})
	aadd(aErro,{ 8,"Data port could not be opened.","DATAPORT_FAILED "})
	aadd(aErro,{ 9,"Accept failed.","ACCEPT_FAILED "})
	//aadd(aErro,{ ,"","// Server errors "})
	aadd(aErro,{ 10,"The request was denied by the server.","SVR_REQUEST_DENIED "})
	aadd(aErro,{ 11,"The request is not supported by the server.","SVR_NOT_SUPPORTED "})
	aadd(aErro,{ 12,"There was no response from the server.","SVR_NO_RESPONSE "})
	aadd(aErro,{ 13,"Permission denied by the server.","SVR_ACCESS_DENIED "})
	aadd(aErro,{ 14,"The Server failed to connect on the data port.","SVR_DATA_CONNECT_FAILED "})
	//aadd(aErro,{ ,"","// Socket errors"})
	aadd(aErro,{ 15,"The socket is not opened.","SOCK_NOT_OPEN "})
	aadd(aErro,{ 16,"The socket is already opened or in use.","SOCK_ALREADY_OPEN "})
	aadd(aErro,{ 17,"The socket creation failed.","SOCK_CREATE_FAILED "})
	aadd(aErro,{ 18,"The socket binding to local port failed.","SOCK_BIND_FAILED "})
	aadd(aErro,{ 19,"The socket connection failed.","SOCK_CONNECT_FAILED "})
	aadd(aErro,{ 20,"A timeout occurred.","SOCK_TIMEOUT "})
	aadd(aErro,{ 21,"A receive socket error occurred.","SOCK_RECEIVE_ERROR "})
	aadd(aErro,{ 22,"Winsock send command failed.","SOCK_SEND_ERROR "})
	aadd(aErro,{ 23,"The listen process failed.","SOCK_LISTEN_ERROR "})
	aadd(aErro,{ 24,"A client socket closure  caused a failure.","CLIENT_RESET "})
	aadd(aErro,{ 25,"A server socket closure caused failure.","SERVER_RESET "})
	//aadd(aErro,{ ,"","// File errors"})
	aadd(aErro,{ 26,"An error occurred as a result of an invalid file type.","FILE_TYPE_ERROR "})
	aadd(aErro,{ 27,"An error occurred as a result of not being able to open a file.","FILE_OPEN_ERROR "})
	aadd(aErro,{ 28,"An error occurred as a result of not being able to create a file.","FILE_CREATE_ERROR "})
	aadd(aErro,{ 29,"A file read error occurred.","FILE_READ_ERROR "})
	aadd(aErro,{ 30,"A file write error occurred.","FILE_WRITE_ERROR "})
	aadd(aErro,{ 31,"Error trying to close file.","FILE_CLOSE_ERROR "})
	aadd(aErro,{ 32,"There was no output file name provided, and no output file name was included with the attachment.","FILE_ERROR "})
	aadd(aErro,{ 33,"File format error.","FILE_FORMAT_ERROR "})
	aadd(aErro,{ 34,"Get temporary file name failed.","FILE_TMP_NAME_FAILED "})
	//aadd(aErro,{ ,"","// Buffer errors"})
	aadd(aErro,{ 35,"An error resulted due to the buffer being too short.","BUFFER_TOO_SHORT "})
	aadd(aErro,{ 36,"An error resulted due to a NULL buffer","NULL_PARAM "})
	//aadd(aErro,{ ,"","// Response errors"})
	aadd(aErro,{ 37,"An error occurred as a result of an invalid or negative response.","INVALID_RESPONSE "})
	aadd(aErro,{ 38,"There was no response.","NO_RESPONSE "})
	//aadd(aErro,{ ,"","// Index errors"})
	aadd(aErro,{ 39,"The index value was out of range.","INDEX_OUTOFRANGE "})
	//aadd(aErro,{ ,"","// User validation errors"})
	aadd(aErro,{ 40,"The user name was invalid.","USER_ERROR "})
	aadd(aErro,{ 41,"The password was invalid.","PASSWORD_ERROR "})
	//aadd(aErro,{ ,"","// Message errors "})
	aadd(aErro,{ 42,"This is a malformed message.","INVALID_MESSAGE "})
	aadd(aErro,{ 43,"Invalid format.","INVALID_FORMAT "})
	aadd(aErro,{ 44,"Not a MIME file.","FILE_NOT_MIME "})
	//aadd(aErro,{ ,"","// URL errors"})
	aadd(aErro,{ 45,"A bad URL was given.","BAD_URL "})
	//aadd(aErro,{ ,"","// Command errors"})
	aadd(aErro,{ 46 ,"An invalid command.","INVALID_COMMAND "})
	aadd(aErro,{ 47,"MAIL command failed.","MAIL_FAILED "})
	aadd(aErro,{ 48,"The RETR command failed.","RETR_FAILED "})
	aadd(aErro,{ 49,"The PORT command failed.","PORT_FAILED "})
	aadd(aErro,{ 50,"The LIST command failed.","LIST_FAILED "})
	aadd(aErro,{ 51,"The STOR command failed.","STOR_FAILED "})
	aadd(aErro,{ 52,"The DATA command failed.","DATA_FAILED "})
	aadd(aErro,{ 53,"The USER command failed.","USER_FAILED "})
	aadd(aErro,{ 54,"The HELLO command failed.","HELLO_FAILED "})
	aadd(aErro,{ 55,"The PASS command failed.","PASS_FAILED "})
	aadd(aErro,{ 56,"The STAT command failed.","STAT_FAILED "})
	aadd(aErro,{ 57,"The TOP command failed.","TOP_FAILED "})
	aadd(aErro,{ 58,"The UIDL command failed.","UIDL_FAILED "})
	aadd(aErro,{ 59,"The DELE command failed.","DELE_FAILED "})
	aadd(aErro,{ 60,"The RSET command failed.","RSET_FAILED "})
	aadd(aErro,{ 61,"The XOVER command failed.","XOVER_FAILED "})
	aadd(aErro,{ 62,"The USER command was not accepted.","USER_NA "})
	aadd(aErro,{ 63,"The PASS command was not accepted.","PASS_NA "})
	aadd(aErro,{ 64,"The ACCT command was not accepted.","ACCT_NA "})
	aadd(aErro,{ 65,"The RNFR command not accepted.","RNFR_NA "})
	aadd(aErro,{ 66,"The RNTO command not accepted.","RNTO_NA "})
	aadd(aErro,{ 67,"The RCPT command failed. The specified account does not exsist.","RCPT_FAILED "})
	aadd(aErro,{ 68,"Bad article, posting rejected by server","NNTP_BAD_ARTICLE "})
	aadd(aErro,{ 69,"Posting is not allowed.","NNTP_NOPOSTING "})
	aadd(aErro,{ 70,"Posting rejected by server","NNTP_POST_FAILED "})
	aadd(aErro,{ 71,"AUTHINFO USER command failed.","NNTP_AUTHINFO_USER_FAILED "})
	aadd(aErro,{ 72,"AUTHINFO PASS command failed.","NNTP_AUTHINFO_PASS_FAILED "})
	aadd(aErro,{ 73,"The XOVER command failed.","XOVER_COMMAND_FAILED "})
	//aadd(aErro,{ ,"","// Message errors"})
	aadd(aErro,{ 74,"Can","MSG_OPEN_FAILED "})
	aadd(aErro,{ 75,"Close message data source failed.","MSG_CLOSE_FAILED "})
	aadd(aErro,{ 76,"Failed to read a line from the message data source.","MSG_READ_LINE_FAILED "})
	aadd(aErro,{ 77,"Failed to write a line to the message data source.","MSG_WRITE_LINE_FAILED "})
	aadd(aErro,{ 78,"There is no any attachments in the message data source.","MSG_NO_ATTACHMENTS "})
	aadd(aErro,{ 79,"Message body exceeds maximum length.","MSG_BODY_TOO_BIG "})
	aadd(aErro,{ 80,"Failed to add attachment to the message.","MSG_ATTACHMENT_ADD_FAILED "})
	//aadd(aErro,{ ,"","// Data source errors"})
	aadd(aErro,{ 81,"Failed to open data source.","DS_OPEN_FAILED "})
	aadd(aErro,{ 82,"Failed to close data source.","DS_CLOSE_FAILED "})
	aadd(aErro,{ 83,"Failed to write to the data source.","DS_WRITE_FAILED "})
	//aadd(aErro,{ ,"","// Encoding errors"})
	aadd(aErro,{ 84,"Invalid character in the stream.","ENCODING_INVALID_CHAR "})
	aadd(aErro,{ 85,"Too many characters on one line.","ENCODING_LINE_TOO_LONG "})
	//aadd(aErro,{ ,"","// IMAP4 errors"})
	aadd(aErro,{ 86,"Server login failed. Username or password invalid.","LOGIN_FAILED "})
	aadd(aErro,{ 87,"NOOP command failed.","NOOP_FAILED "})
	aadd(aErro,{ 88,"Command unknown or arguments invalid.","UNKNOWN_COMMAND "})
	aadd(aErro,{ 89,"Unknown response.","UNKNOWN_RESPONSE "})
	aadd(aErro,{ 90,"You must login first.","AUTH_OR_SELECTED_STATE_REQUIRED "})
	aadd(aErro,{ 91,"You must select the mailbox first.","SELECTED_STATE_REQUIRED "})
	//aadd(aErro,{ ,"","//RAS Errors"})
	aadd(aErro,{ 92,"Unable to load the required RAS DLLs","RAS_LOAD_ERROR "})
	aadd(aErro,{ 93,"An error occurred during the dialing process","RAS_DIAL_ERROR "})
	aadd(aErro,{ 94,"An error occurred when attempting to dial","RAS_DIALINIT_ERROR "})
	aadd(aErro,{ 95,"An invalid RAS handle was given","RAS_HANDLE_ERROR "})
	aadd(aErro,{ 96,"An error occurred when performing a RAS enumeration","RAS_ENUM_ERROR "})
	aadd(aErro,{ 97,"An invalid or non-existant RAS entry name was given","RAS_ENTRYNAME_ERROR "})
	//aadd(aErro,{ ,"","// Unclassified errors"})
	aadd(aErro,{ 98,"Aborted by user.","ABORTED "})
	aadd(aErro,{ 99,"A bad hostname format.","BAD_HOSTNAME "})
	aadd(aErro,{ 100,"The address is not valid.","INVALID_ADDRESS "})
	aadd(aErro,{ 101,"The address format is not valid.","INVALID_ADDRESS_FORMAT "})
	aadd(aErro,{ 102,"User terminated the process.","USER_TERMINATED "})
	aadd(aErro,{ 103,"The authorized name server was not found.","ANS_NOT_FOUND "})
	aadd(aErro,{ 104,"Failed to set the server name.","SERVER_SET_NAME_FAILED "})
	aadd(aErro,{ 105,"Parameter too long.","PARAMETER_TOO_LONG "})
	aadd(aErro,{ 106,"Invalid value of the parameter.","PARAMETER_INVALID_VALUE "})
	aadd(aErro,{ 107,"Get temorary filename failed.","TEMP_FILENAME_FAILED "})
	aadd(aErro,{ 108,"Out of memory.","OUT_OF_MEMORY "})
	aadd(aErro,{ 109,"Update of group information failed.","GROUP_INFO_UPDATE_FAILED "})
	aadd(aErro,{ 110,"No selected news group.","GROUP_NOT_SELECTED "})
	aadd(aErro,{ 111 ,"Internal error.","INTERNAL_ERROR "})
	aadd(aErro,{ 112,"Already in use.","ALREADY_IN_USE "})
	aadd(aErro,{ 113,"No current message set.","NO_CURRENT_MSG_SET "})
	aadd(aErro,{ 114,"The Quote Command was empty","QUOTE_LINE_IS_EMPTY "})
	aadd(aErro,{ 115,"The REST command is not supported by the server","REST_COMMAND_NOT_SUPPORTED "})
	aadd(aErro,{ 116,"Failed to load system information.","SYSTEM_INFO_LOAD_FAILED "})
	aadd(aErro,{ 117,"Failed to load user information.","USER_INFO_LOAD_FAILED "})
	aadd(aErro,{ 118,"with this name is alredy existing.","USER_NAME_ALREDY_EXIST "})
	aadd(aErro,{ 119,"with this name is alredy existing.","MAILBOX_NAME_ALREDY_EXIST "})
	aadd(aErro,{ 120,"Authentication failed.","AUTH_FAILED "})
	aadd(aErro,{ 121,"Server not capable to do authentication (Extended SMTP needed).","AUTH_SERVER_NOT_CAPABLE "})
	aadd(aErro,{ 122,"Authentication method is not supported, only LOGIN and NTLM are supported","AUTH_METHOD_NOT_SUPPORTED "})
	
	nCod := aScan(aErro,{|x| x[1] == nErro})
	
	If nCod <> 0
		xRet := aErro[nCod][2]
	Else
		xRet := "Erro indeterminado.Entre em contato com o suporte/desenvolvimento."
	EndIf 
		
Return(xRet)                 
         

*****************************
USer Function HFDiaSem(cJobs) 
*****************************
	Local cRet := ""
	//Local aJobs:= {}
	//Local Nx   := 1
	Local oDlg                                                        
	Local oChkOnX, oChkOn1, oChkOn2, oChkOn3, oChkOn4, oChkOn5, oChkOn6, oChkOn7
	Local lChkOnX  :=  ("X" $ cJobs)
	Local lChkOn1  :=  ("1" $ cJobs)
	Local lChkOn2  :=  ("2" $ cJobs)
	Local lChkOn3  :=  ("3" $ cJobs)
	Local lChkOn4  :=  ("4" $ cJobs)
	Local lChkOn5  :=  ("5" $ cJobs)
	Local lChkOn6  :=  ("6" $ cJobs)
	Local lChkOn7  :=  ("7" $ cJobs)
	Local nOpc     := 0
	Private oFont01:= TFont():New("Arial",07,14,,.T.,,,,.T.,.F.)
	                                                                  
	DEFINE MSDIALOG oDlg TITLE "Selecao de Dias da Semana " FROM 000,000 TO 300,400 PIXEL STYLE DS_MODALFRAME STATUS
	
	@ 00.5,00.5 to 010,024.5 OF oDlg   
	
	@ 010 ,010 SAY "Selecione os dias a serem executados:" PIXEL OF oDlg COLOR CLR_BLUE FONT oFont01
	@ 020 ,010 CHECKBOX oChkOnX VAR lChkOnX PROMPT "X-Todos"          SIZE 65,8 PIXEL OF oDlg COLOR CLR_BLUE FONT oFont01//;
	
	@ 035 ,010 CHECKBOX oChkOn1 VAR lChkOn1 PROMPT "1-Domingo"        SIZE 65,8 PIXEL OF oDlg COLOR CLR_BLUE FONT oFont01
	
	@ 050 ,010 CHECKBOX oChkOn2 VAR lChkOn2 PROMPT "2-Segunda-Feira"  SIZE 65,8 PIXEL OF oDlg COLOR CLR_BLUE FONT oFont01
	
	@ 065 ,010 CHECKBOX oChkOn3 VAR lChkOn3 PROMPT "3-Terça-Feira"    SIZE 65,8 PIXEL OF oDlg COLOR CLR_BLUE FONT oFont01
	
	@ 080 ,010 CHECKBOX oChkOn4 VAR lChkOn4 PROMPT "4-Quarta-Feira"   SIZE 95,8 PIXEL OF oDlg COLOR CLR_BLUE FONT oFont01 
	
	@ 095 ,010 CHECKBOX oChkOn5 VAR lChkOn5 PROMPT "5-Quinta-Feira"   SIZE 95,8 PIXEL OF oDlg COLOR CLR_BLUE FONT oFont01
	
	@ 110 ,010 CHECKBOX oChkOn6 VAR lChkOn6 PROMPT "6-Sexta-Feira"    SIZE 95,8 PIXEL OF oDlg COLOR CLR_BLUE FONT oFont01
	
	@ 125 ,010 CHECKBOX oChkOn7 VAR lChkOn7 PROMPT "7-Sábado"         SIZE 95,8 PIXEL OF oDlg COLOR CLR_BLUE FONT oFont01
	
	oChkOnX:cToolTip := "Executar todos os dias."
	oChkOn1:cToolTip := "Executar aos domingos."
	oChkOn2:cToolTip := "Executar as segundas-feiras."
	oChkOn3:cToolTip := "Executar as terças-feiras."
	oChkOn4:cToolTip := "Executar as quartas-feiras."
	oChkOn5:cToolTip := "Executar as quintas-feiras."
	oChkOn6:cToolTip := "Executar as sextas-feiras."
	oChkOn7:cToolTip := "Executar aos sabados."
	
	@ 135 ,110 Button "Cancela" Size 040,015 PIXEL OF oDlg ACTION oDlg:End()
	@ 135 ,155 Button "OK" Size 040,015 PIXEL OF oDlg ACTION (nOpc:=1,oDlg:End())
	
	ACTIVATE MSDIALOG oDlg CENTERED 
	
	If nOpc ==1
		If lChkOnX
			cRet := "X"
		Else
			cRet := ""
			If lChkOn1
				cRet += Iif(!Empty(cRet),",","" )+"1"
			EndIf
			If lChkOn2
				cRet += Iif(!Empty(cRet),",","" )+"2"
			EndIf
			If lChkOn3
				cRet += Iif(!Empty(cRet),",","" )+"3"
			EndIf
			If lChkOn4
				cRet += Iif(!Empty(cRet),",","" )+"4"
			EndIf
			If lChkOn5
				cRet += Iif(!Empty(cRet),",","" )+"5"
			EndIf
			If lChkOn6
				cRet += Iif(!Empty(cRet),",","" )+"6"
			EndIf
			If lChkOn7
				cRet += Iif(!Empty(cRet),",","" )+"7"
			EndIf
		EndIf	
	
	Else
		cRet := cJobs      
	Endif
Return(cRet)

**************************
User Function HFMes(cJobs)
**************************
	Local cRet := ""
	//Local aJobs:= {}
	//Local Nx   := 1
	Local oDlg                                                        
	Local oChkOnX, oChkOn1, oChkOn2, oChkOn3, oChkOn4, oChkOn5, oChkOn6, oChkOn7
	Local lChkOnX  :=  ( "X" $ cJobs)
	Local lChkOn1  :=  ("01" $ cJobs)
	Local lChkOn2  :=  ("02" $ cJobs)
	Local lChkOn3  :=  ("03" $ cJobs)
	Local lChkOn4  :=  ("04" $ cJobs)
	Local lChkOn5  :=  ("05" $ cJobs)
	Local lChkOn6  :=  ("06" $ cJobs)
	Local lChkOn7  :=  ("07" $ cJobs)
	Local lChkOn8  :=  ("08" $ cJobs)
	Local lChkOn9  :=  ("09" $ cJobs)
	Local lChkOn10 :=  ("10" $ cJobs)
	Local lChkOn11 :=  ("11" $ cJobs)
	Local lChkOn12 :=  ("12" $ cJobs)
	Local nOpc     := 0
	Private oFont01:= TFont():New("Arial",07,14,,.T.,,,,.T.,.F.)
	
	DEFINE MSDIALOG oDlg TITLE "Selecao de Meses " FROM 000,000 TO 300,400 PIXEL STYLE DS_MODALFRAME STATUS
	
	@ 00.5,00.5 to 009,024.5 OF oDlg
	
	@ 010 ,010 SAY "Selecione os meses a serem executados:" PIXEL OF oDlg COLOR CLR_BLUE FONT oFont01
	@ 020 ,010 CHECKBOX oChkOnX  VAR lChkOnX  PROMPT "X-Todos"   SIZE 35,8 PIXEL OF oDlg COLOR CLR_BLUE FONT oFont01
	
	@ 035 ,010 CHECKBOX oChkOn1  VAR lChkOn1  PROMPT "01-JAN"    SIZE 35,8 PIXEL OF oDlg COLOR CLR_BLUE FONT oFont01
	
	@ 035 ,060 CHECKBOX oChkOn2  VAR lChkOn2  PROMPT "02-FEV"    SIZE 35,8 PIXEL OF oDlg COLOR CLR_BLUE FONT oFont01
	
	@ 050 ,010 CHECKBOX oChkOn3  VAR lChkOn3  PROMPT "03-MAR"    SIZE 35,8 PIXEL OF oDlg COLOR CLR_BLUE FONT oFont01
	
	@ 050 ,060 CHECKBOX oChkOn4  VAR lChkOn4  PROMPT "04-ABR"    SIZE 35,8 PIXEL OF oDlg COLOR CLR_BLUE FONT oFont01 
	
	@ 065 ,010 CHECKBOX oChkOn5  VAR lChkOn5  PROMPT "05-MAI"    SIZE 35,8 PIXEL OF oDlg COLOR CLR_BLUE FONT oFont01
	
	@ 065 ,060 CHECKBOX oChkOn6  VAR lChkOn6  PROMPT "06-JUN"    SIZE 35,8 PIXEL OF oDlg COLOR CLR_BLUE FONT oFont01
	
	@ 080 ,010 CHECKBOX oChkOn7  VAR lChkOn7  PROMPT "07-JUL"    SIZE 35,8 PIXEL OF oDlg COLOR CLR_BLUE FONT oFont01
	
	@ 080 ,060 CHECKBOX oChkOn8  VAR lChkOn8  PROMPT "08-AGO"    SIZE 35,8 PIXEL OF oDlg COLOR CLR_BLUE FONT oFont01
	
	@ 095 ,010 CHECKBOX oChkOn9  VAR lChkOn9  PROMPT "09-SET"    SIZE 35,8 PIXEL OF oDlg COLOR CLR_BLUE FONT oFont01
	
	@ 095 ,060 CHECKBOX oChkOn10 VAR lChkOn10 PROMPT "10-OUT"    SIZE 35,8 PIXEL OF oDlg COLOR CLR_BLUE FONT oFont01
	
	@ 110 ,010 CHECKBOX oChkOn11 VAR lChkOn11 PROMPT "11-NOV"    SIZE 35,8 PIXEL OF oDlg COLOR CLR_BLUE FONT oFont01
	
	@ 110 ,060 CHECKBOX oChkOn12 VAR lChkOn12 PROMPT "12-DEZ"    SIZE 35,8 PIXEL OF oDlg COLOR CLR_BLUE FONT oFont01
	
	oChkOnX:cToolTip  := "Executar todos os meses."
	oChkOn1:cToolTip  := "Executar em Janeiro."
	oChkOn2:cToolTip  := "Executar em Fevereiro."
	oChkOn3:cToolTip  := "Executar em Março."
	oChkOn4:cToolTip  := "Executar em Abril."
	oChkOn5:cToolTip  := "Executar em Maio."
	oChkOn6:cToolTip  := "Executar em Junho."
	oChkOn7:cToolTip  := "Executar em Julho."
	oChkOn8:cToolTip  := "Executar em Agosto."
	oChkOn9:cToolTip  := "Executar em Setembro."
	oChkOn10:cToolTip := "Executar em Outubro."
	oChkOn11:cToolTip := "Executar em Novembro."
	oChkOn12:cToolTip := "Executar em Dezembro."
	
	@ 130 ,110 Button "Cancela" Size 040,015 PIXEL OF oDlg ACTION oDlg:End()
	@ 130 ,155 Button "OK" Size 040,015 PIXEL OF oDlg ACTION (nOpc:=1,oDlg:End())
	
	ACTIVATE MSDIALOG oDlg CENTERED 
	
	If nOpc == 1
		If lChkOnX
			cRet := "X"
		Else
			cRet := ""
			If lChkOn1
				cRet += Iif(!Empty(cRet),",","" )+"01"
			EndIf
			If lChkOn2
				cRet += Iif(!Empty(cRet),",","" )+"02"
			EndIf
			If lChkOn3
				cRet += Iif(!Empty(cRet),",","" )+"03"
			EndIf
			If lChkOn4
				cRet += Iif(!Empty(cRet),",","" )+"04"
			EndIf
			If lChkOn5
				cRet += Iif(!Empty(cRet),",","" )+"05"
			EndIf
			If lChkOn6
				cRet += Iif(!Empty(cRet),",","" )+"06"
			EndIf
			If lChkOn7
				cRet += Iif(!Empty(cRet),",","" )+"07"
			EndIf
			If lChkOn8
				cRet += Iif(!Empty(cRet),",","" )+"08"
			EndIf
			If lChkOn9
				cRet += Iif(!Empty(cRet),",","" )+"09"
			EndIf
			If lChkOn10
				cRet += Iif(!Empty(cRet),",","" )+"10"
			EndIf
			If lChkOn11
				cRet += Iif(!Empty(cRet),",","" )+"11"
			EndIf
			If lChkOn12
				cRet += Iif(!Empty(cRet),",","" )+"12"
			EndIf
		EndIf
	
	Else
		cRet := cJobs
	Endif
Return(cRet)


**********************
User Function ShowPN()
**********************
 	RpcSetType(3)
	PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" MODULO "FAT" TABLES "SF1","SF2","SD1","SD2","SF4","SB5","SF3","SB1"
	//	u_AAABBB("N","N",.T.)
	aCols1 := {}
	cErro := ""
	cWarn := ""
	AcABEC := {} 
	cCnpj := "00000000000000" 
	aadd(aCabec,{"F1_TIPO"   ,"D"}) // normal
	aadd(aCabec,{"F1_FORMUL" ,"N"})
	aadd(aCabec,{"F1_DOC"    ,"000000001"})
	aadd(aCabec,{"F1_SERIE"  ,"1  "})
	aadd(aCabec,{"F1_EMISSAO",DdATAbASE})
	aadd(aCabec,{"F1_FORNECE","000999"})
	aadd(aCabec,{"F1_LOJA"   ,"01"})
	aadd(aCabec,{"F1_ESPECIE","CTE"})
	aadd(aCabec,{"F1_CHVNFE" ,Space(44)}) 

	Aadd(aCols1,{"0001",Padr("FPROD001",15),"Desc Produto",Padr("3050110008",15),Replicate("-",30),1,500,500,"12345679123","000001","001",.F.})	
	Aadd(aCols1,{"0002",Padr("FPROD002",15),"Desc Produto",Padr("3050110008",15),Replicate("-",30),3,300,900,"12345679123","000001","001",.F.})	
	Aadd(aCols1,{"0003",Padr("FPROD002",15),"Desc Produto",Padr("3050110008",15),Replicate("-",30),3,300,900,"12345679123","000001","001",.F.})	
	Aadd(aCols1,{"0004",Padr("FPROD003",15),"Desc Produto",Padr("3050110008",15),Replicate(" ",30),5,700,3500,"12345679123","000001","001",.F.})	
	Aadd(aCols1,{"0005",Padr("FPROD004",15),"Desc Produto",Padr("3050110009",15),Replicate("-",30),6,800,4800,"12345679123","000001","001",.F.})	
	Aadd(aCols1,{"0006",Padr("FPROD005",15),"Desc Produto",Padr("3050110009",15),Replicate("-",30),7,200,1400,"12345679123","000001","001",.F.})	
	Aadd(aCols1,{"0007",Padr("FPROD006",15),"Desc Produto",Padr("3050110009",15),Replicate("-",30),525852,8858585.400,388858200,"12345679123","000001","001",.F.})	
    
    cXml := Memoread("nfe.xml")
    oXml := XmlParser( cXml, "_", @cErro, @cWarn )  
	U_VisNota("55",cCnpj,oXml,aCols1,@aCabec,@aCols1)
Return
                               


//"N=Normal;D=Devolucao;B=Beneficiamento;C=Complemento Preco/Frete;I=Comp. ICMS;P=Comp. IPI"
***********************************
User Function XMLOkCab(aHead,oGet2)
***********************************
	Local lRet      := .T.           
	Local cMsgErro  := ""
	
	If cCnpjFor  <> cCnpj
		cMsgErro += "O CNPJ do Emissor do XML é diferente do Fornecedor/Cliente selecionado."+CRLF		   
	EndIf
	
	If Empty(cA100For)  .Or. Empty(cLoja)
		cMsgErro += "O código/loja do emissor do xml é obrigatorio."+CRLF		   
	EndIf           
	
	If cTipo $ "D|B"
		DbSelectArea("SA1")
		DbSetOrder(1)
		If !DbSeek(xFilial("SA1")+cA100For+cLoja) 
			cMsgErro += "Código/loja do emissor do xml não encontrado."+CRLF
		Else
			If SA1->A1_CGC <> cCnpj
				cMsgErro += "O CNPJ do Emissor do XML é diferente do Fornecedor/Cliente selecionado."+CRLF			
			EndIf	
		EndIf
	Else
		DbSelectArea("SA2")
		DbSetOrder(1)
		If !DbSeek(xFilial("SA2")+cA100For+cLoja) 
			cMsgErro += "Código/loja do emissor do xml não encontrado."+CRLF
		Else
			If SA2->A2_CGC <> cCnpj
				cMsgErro += "O CNPJ do Emissor do XML é diferente do Fornecedor/Cliente selecionado."+CRLF			
			EndIf	
		EndIf		
	EndIf
		
	If Empty(cMsgErro)
		aHead[01][02] := cTipo	
		aHead[02][02] := Substr(cFormul,1,1)	
		aHead[03][02] := cNFiscal	
		aHead[04][02] := cSerie		
		aHead[05][02] := dDEmissao	
		aHead[06][02] := cA100For	
		aHead[07][02] := cLoja		
		aHead[08][02] := cEspecie
	Else
		U_MyAviso("Atenção",cMsgErro,{"OK"},3)              
		lRet := .F.
	EndIf	
Return(lRet)
	
***************************	                     
User Function FillCab(cTab) 
***************************
	Local lret := .T.
	
	If cTipo $ "D|B"

		cCliExist := Posicione('SA1', 3, xFilial('SA1') + cCnpj, 'A1_COD' )

		If !Empty(cCliExist)
			cA100For := Posicione('SA1', 3, xFilial('SA1') + cCnpj, 'A1_COD' ) // SA1->A1_COD
			cLoja    := Posicione('SA1', 3, xFilial('SA1') + cCnpj, 'A1_LOJA') // SA1->A1_LOJA
			cNome    := Posicione('SA1', 3, xFilial('SA1') + cCnpj, 'A1_NOME') // SA1->A1_NOME  
			//	cCnpjFor := SA1->A1_CGC
			cUfOrig  := Posicione('SA1', 3, xFilial('SA1') + cCnpj, 'A1_EST' ) // SA1->A1_EST
		Else
			MsgInfo("Cliente não encontrado, por favor verifique se existe um cadastro para este CNPJ.","Filtro por Cliente")
		EndIf
		
	Else //If cTab == "SA2" 
		cA100For := SA2->A2_COD
		cLoja    := SA2->A2_LOJA
		cNome    := SA2->A2_NOME  
	//	cCnpjFor := SA2->A2_CGC
		cUfOrig  := SA2->A2_EST
	EndIf

Return(lret)  
  
/*****************************************************************  
Static Function SetF3But(cTipo,oForSa1,oForSa2,lEmpty,oForNome)
****************************************************************
	Default lEmpty := .T.      
		If cTipo $ "D|B"
			oForSa2:Hide() 
			oForSa1:Show()
			cSayForn    := RetTitle("F2_CLIENTE")
			cNome       := SA1->A1_NOME
			cUfOrig     := SA1->A1_EST
		Else
			oForSa1:Hide() 
			oForSa2:Show()		    
			cSayForn    := RetTitle("F1_FORNECE")
			cNome       := SA2->A2_NOME			
			cUfOrig     := SA2->A2_EST
		EndIf
	
	
	If lEmpty
		cA100For	:= Space(6)
		cLoja		:= Space(2)
		cNome       := Space(30) 
		cUfOrig     := Space(2)
	//
	EndIf
Return*/

******************************************************
User Function XmlSetNF(nOpca,oGet2,aHead,aCols1,oXml) 
******************************************************              
	Local Ny       := 0
	Local nLinhas  := Len(oGet2:ACOLS) 
	Local cMsgErro := "" 
	Local lRet     := .T.
	//Local nPosProd := aScan(oGet2:AHEADER,{|x,y| AllTrim(x[2]) ==  "D1_COD" })
	//Local nPosCC   := aScan(oGet2:AHEADER,{|x,y| AllTrim(x[2]) ==  "D1_CC" })
	Local nPosPed  := aScan(oGet2:AHEADER,{|x,y| AllTrim(x[2]) ==  "D1_PEDIDO" })
	//Local nPosItPc := aScan(oGet2:AHEADER,{|x,y| AllTrim(x[2]) ==  "D1_ITEMPC" })
	Local aItemProc:= {}  
	Local aItensFim:= {}
	//Local cTesPcNf := GetNewPar("MV_TESPCNF","") // Tes que nao necessita de pedido de compra amarrado
	If nOpca == 1
		//aRetHead := aClone(aHead)
		For Ny := 1 to nLinhas
			If EmpTy(oGet2:ACOLS[Ny][04])
				cMsgErro += oGet2:ACOLS[Ny][01] + CRLF
				lRet := .F.
			Else	
				aCols1[Ny][01][2] := oGet2:ACOLS[Ny][04] // Codigo do Produto
				aCols1[Ny][05][2] := oGet2:ACOLS[Ny][09] // CC
				aCols1[Ny][06][2] := oGet2:ACOLS[Ny][10] // Pedido
				aCols1[Ny][07][2] := oGet2:ACOLS[Ny][11] // Item do Pedido			
	            
	            aItemProc:= aClone(aCols1[Ny]) 
	            aSize(aItemProc,4)
	            If  !Empty(aCols1[Ny][05][2])
	            	aadd(aItemProc,aCols1[Ny][05])
	            EndIf
	 
				If nPosPed > 0
		            If  !Empty(aCols1[Ny][06][2]) .And. !Empty(aCols1[Ny][07][2])
		            	aadd(aItemProc,aCols1[Ny][06])
		            	aadd(aItemProc,aCols1[Ny][07])            	
		    		Else	
	//					If !Empty(cTesPcNf) .And. (Posicione("SB1",1,xFilial("SB1")+oGet2:ACOLS[Ny][nPosProd],"B1_TE") $ AllTrim(cTesPcNf))
	//		            	aadd(aItemProc,Space(6))
	//		            	aadd(aItemProc,Space(2))   
	//					Endif 
		            	
		            EndIf
	   			EndIf
	   			aadd(aItensFim,aItemProc)
	   		EndIf
	    Next
		
		If !lRet                           
			cMsgErro := "Preencha o(s) item(ns):"+CRLF+cMsgErro     
			U_MyAviso("Atenção",cMsgErro,{"OK"},3)
		
		Else
			aCols1 := aClone(aItensFim)
			oDlg:End()	
		EndIf
			
	
	Else
	
		U_MyAviso("Atenção","Operação cancelada pelo usuário",{"OK"})
	
	EndIf

Return(lRet)                                                                         

*********************** 
User FUnction XmlLINOK  
*********************** 
	Local lRet := .T. 
Return(lRet)     

***************************
User FUnction XmlTOK(oGet2) 
***************************
	Local lRet    := .T. 
	Local nw      := 0
	Local nLinhas := Len(oGet2:ACOLS) 
	Local cMsgErro:= ""  
	
	For Nw := 1 To nLinhas
		If EmpTy(oGet2:ACOLS[Nw][04])
			cMsgErro += StrZero(Nw,4)+ " "
			lRet := .F.
		EndIf	
	Next
	If !lRet
		cMsgErro := "Preencha o(s) item(ns):"+CRLF+cMsgErro     
		U_MyAviso("Atenção",cMsgErro,{"OK"},3)
	EndIf
	
	
	oGet2:Refresh(.F.)

Return(lRet)

*****************************
User FUnction XmlFLDOK(oGet2)
*****************************
	Local lRet := .T. 
	Local nAt  := oGet2:nAt
	 
	If oGet2:OBROWSE:NCOLPOS == 4 
		oGet2:ACOLS[nAt][05] := Posicione("SB1",1,xFilial("SB1")+oGet2:ACOLS[oGet2:nAt][04],"B1_DESC")
	//	ACOLS[nAt][05] := Posicione("SB1",1,xFilial("SB1")+oGet2:ACOLS[oGet2:nAt][04],"B1_DESC")
		oGet2:Refresh(.F.)
	//	oGet2:ForceRefresh()
	EndIf		

Return(lRet)

***********************                          		
User FUnction XmlDELOK
***********************
	Local lRet := .T.
Return(lRet)
             
****************************
User Function RefGetF(oGet2)
****************************
	Local lRet := .T.
	Local nw := 0
	Local nLinhas := Len(oGet2:ACOLS)   
	
	
	For Nw := 1 To nLinhas
		oGet2:ACOLS[Nw][05] := Posicione("SB1",1,xFilial("SB1")+oGet2:ACOLS[Nw][04],"B1_DESC")
	Next
	
	oGet2:Refresh(.F.)
Return(lRet)

/***************************************************
Static Function XmlRodape(oDlg,cModelo,oXml,aComp) 
**************************************************
	Local oPage      
	//Local Nx     := 0 
	//Local aGets  := {}
	Private aPages := { "Componentes do Valor","Info"}  
	Private nPageXml := aScan(aPages,{|x| x ==  "Componentes do Valor" })
	Private nPageInfo:= aScan(aPages,{|x| x == "Info"})
	Private oFont01:= TFont():New("Arial",07,12,,.T.,,,,.T.,.F.)        
	Private oGet1,oGet2,oGet3,oGet4,oGet5,oGet6,oGet7,oGet8,oGet9,oGet10,oGet11,oGet12,oGet13
	Private cTit1,cTit2,cTit3,cTit4,cTit5,cTit6,cTit7,cTit8,cTit9,cTit10,cTit11,cTit12,cTit13
	Private nGet1:=nGet2:=nGet3:=nGet4:=nGet5:=nGet6:=nGet7:=nGet8:=nGet9:=nGet10:=nGet11:=nGet12:=nGet13:=0        
	                  
	If cModelo == "55"      

		//aPages := { "Componentes do Valor","Info"}  
		//nPageXml := aScan(aPages,{|x| x ==  "Componentes do Valor" })
		//nPageInfo:= aScan(aPages,{|x| x == "Info"})
		nComp := Len(aComp)
		nPosG1    := 000.50
		nPosG2    := 002.50
		nPosInc   := 002.125
		
		oPage := TFolder():New(182,005,aPages,{},oDlg,,,,.T.,.F.,540,079,)
		
		@ 00.2,00.5 to 4.6,067 OF oPage:aDialogs[nPageXml] 
	
		nCC1  := 005
		nCC2  := 010       
		nColCC:= 140
		nDist := 6
		nSalt := 020 
	
		//Coluna 1
		If Type("aComp[1]:_XNOME:TEXT") <> "U" .And. Type("aComp[1]:_VCOMP:TEXT") <> "U"
			@ nCC1    	  ,nCC2 Say aComp[1]:_XNOME:TEXT  PIXEL OF oPage:aDialogs[nPageXml] COLOR CLR_BLUE FONT oFont01
			@ nCC1+nDist  ,nCC2 MSGet oGet1 VAR Val(aComp[1]:_VCOMP:TEXT) SIZE 60,08 PICTURE "@E 999,999.99" PIXEL OF oPage:aDialogs[nPageXml] WHEN lWhen          	    
			nCC1  += nSalt
	    EndIf
	   	If Type("aComp[2]:_XNOME:TEXT") <> "U" .And. Type("aComp[2]:_VCOMP:TEXT") <> "U"
			@ nCC1        ,nCC2 Say aComp[2]:_XNOME:TEXT  PIXEL OF oPage:aDialogs[nPageXml] COLOR CLR_BLUE FONT oFont01
			@ nCC1+nDist  ,nCC2 MSGet oGet2 VAR Val(aComp[2]:_VCOMP:TEXT) SIZE 60,08 PICTURE "@E 999,999.99" PIXEL OF oPage:aDialogs[nPageXml] WHEN lWhen         	    
			nCC1  += nSalt
	    EndIf
	   	If Type("aComp[3]:_XNOME:TEXT") <> "U" .And. Type("aComp[3]:_VCOMP:TEXT") <> "U"
			@ nCC1        ,nCC2 Say aComp[3]:_XNOME:TEXT  PIXEL OF oPage:aDialogs[nPageXml] COLOR CLR_BLUE FONT oFont01
			@ nCC1+nDist  ,nCC2 MSGet oGet3 VAR Val(aComp[3]:_VCOMP:TEXT) SIZE 60,08 PICTURE "@E 999,999.99" PIXEL OF oPage:aDialogs[nPageXml] WHEN lWhen           	    
			nCC1  += nSalt
	    EndIf
	  	 
			nCC1  := 005
			nCC2  += nColCC  
	
	ElseIf cModelo == "57"

		lWhen := .F.
		//aPages := { "Componentes do Valor","Info"}  
		//nPageXml := aScan(aPages,{|x| x ==  "Componentes do Valor" })
		//nPageInfo:= aScan(aPages,{|x| x == "Info"})
		nComp := Len(aComp)
	
		nPosG1    := 000.50
		nPosG2    := 002.50
		nPosInc   := 002.125
		
		oPage := TFolder():New(182,005,aPages,{},oDlg,,,,.T.,.F.,540,079,)
		
		@ 00.2,00.5 to 4.6,067 OF oPage:aDialogs[nPageXml] 
		
		nCC1  := 005
		nCC2  := 010       
		nColCC:= 140
		nDist := 6
		nSalt := 020 
	
		//Coluna 1
		If Type("aComp[1]:_XNOME:TEXT") <> "U" .And. Type("aComp[1]:_VCOMP:TEXT") <> "U"
			@ nCC1    	  ,nCC2 Say aComp[1]:_XNOME:TEXT  PIXEL OF oPage:aDialogs[nPageXml] COLOR CLR_BLUE FONT oFont01
			@ nCC1+nDist  ,nCC2 MSGet oGet1 VAR Val(aComp[1]:_VCOMP:TEXT) SIZE 60,08 PICTURE "@E 999,999.99" PIXEL OF oPage:aDialogs[nPageXml] WHEN lWhen          	    
			nCC1  += nSalt
	    EndIf
	   	If Type("aComp[2]:_XNOME:TEXT") <> "U" .And. Type("aComp[2]:_VCOMP:TEXT") <> "U"
			@ nCC1        ,nCC2 Say aComp[2]:_XNOME:TEXT  PIXEL OF oPage:aDialogs[nPageXml] COLOR CLR_BLUE FONT oFont01
			@ nCC1+nDist  ,nCC2 MSGet oGet2 VAR Val(aComp[2]:_VCOMP:TEXT) SIZE 60,08 PICTURE "@E 999,999.99" PIXEL OF oPage:aDialogs[nPageXml] WHEN lWhen         	    
			nCC1  += nSalt
	    EndIf
	   	If Type("aComp[3]:_XNOME:TEXT") <> "U" .And. Type("aComp[3]:_VCOMP:TEXT") <> "U"
			@ nCC1        ,nCC2 Say aComp[3]:_XNOME:TEXT  PIXEL OF oPage:aDialogs[nPageXml] COLOR CLR_BLUE FONT oFont01
			@ nCC1+nDist  ,nCC2 MSGet oGet3 VAR Val(aComp[3]:_VCOMP:TEXT) SIZE 60,08 PICTURE "@E 999,999.99" PIXEL OF oPage:aDialogs[nPageXml] WHEN lWhen           	    
			nCC1  += nSalt
	    EndIf
	  	 
			nCC1  := 005
			nCC2  += nColCC       
		
			//Coluna 2
	  
	   	If Type("aComp[4]:_XNOME:TEXT") <> "U" .And. Type("aComp[4]:_VCOMP:TEXT") <> "U"	
			@ nCC1    	  ,nCC2 Say aComp[4]:_XNOME:TEXT  PIXEL OF oPage:aDialogs[nPageXml] COLOR CLR_BLUE FONT oFont01
			@ nCC1+nDist  ,nCC2 MSGet oGet4 VAR Val(aComp[4]:_VCOMP:TEXT) SIZE 60,08 PICTURE "@E 999,999.99" PIXEL OF oPage:aDialogs[nPageXml] WHEN lWhen           	    
			nCC1  += nSalt
	    EndIf
	   	If Type("aComp[5]:_XNOME:TEXT") <> "U" .And. Type("aComp[5]:_VCOMP:TEXT") <> "U"
			@ nCC1        ,nCC2 Say aComp[5]:_XNOME:TEXT  PIXEL OF oPage:aDialogs[nPageXml] COLOR CLR_BLUE FONT oFont01
			@ nCC1+nDist  ,nCC2 MSGet oGet5 VAR Val(aComp[5]:_VCOMP:TEXT) SIZE 60,08 PICTURE "@E 999,999.99" PIXEL OF oPage:aDialogs[nPageXml] WHEN lWhen           	    
			nCC1  += nSalt
	    EndIf
	   	If Type("aComp[6]:_XNOME:TEXT") <> "U" .And. Type("aComp[6]:_VCOMP:TEXT") <> "U"
			@ nCC1        ,nCC2 Say aComp[6]:_XNOME:TEXT  PIXEL OF oPage:aDialogs[nPageXml] COLOR CLR_BLUE FONT oFont01
			@ nCC1+nDist  ,nCC2 MSGet oGet6 VAR Val(aComp[6]:_VCOMP:TEXT) SIZE 60,08 PICTURE "@E 999,999.99" PIXEL OF oPage:aDialogs[nPageXml] WHEN lWhen          	    
			nCC1  += nSalt
	    EndIf
		   
			nCC1  := 005
			nCC2  += nColCC       
		
			//Coluna 3 
	 
	  	If Type("aComp[7]:_XNOME:TEXT") <> "U" .And. Type("aComp[7]:_VCOMP:TEXT") <> "U"	
			@ nCC1    	  ,nCC2 Say aComp[7]:_XNOME:TEXT  PIXEL OF oPage:aDialogs[nPageXml] COLOR CLR_BLUE FONT oFont01
			@ nCC1+nDist  ,nCC2 MSGet oGet7 VAR Val(aComp[7]:_VCOMP:TEXT) SIZE 60,08 PICTURE "@E 999,999.99" PIXEL OF oPage:aDialogs[nPageXml] WHEN lWhen           	    
			nCC1  += nSalt
	    EndIf
	   	If Type("aComp[8]:_XNOME:TEXT") <> "U" .And. Type("aComp[8]:_VCOMP:TEXT") <> "U"
			@ nCC1        ,nCC2 Say aComp[8]:_XNOME:TEXT  PIXEL OF oPage:aDialogs[nPageXml] COLOR CLR_BLUE FONT oFont01
			@ nCC1+nDist  ,nCC2 MSGet oGet8 VAR Val(aComp[8]:_VCOMP:TEXT) SIZE 60,08 PICTURE "@E 999,999.99" PIXEL OF oPage:aDialogs[nPageXml] WHEN lWhen           	    
			nCC1  += nSalt
	    EndIf
	   	If Type("aComp[9]:_XNOME:TEXT") <> "U" .And. Type("aComp[9]:_VCOMP:TEXT") <> "U"
			@ nCC1        ,nCC2 Say aComp[9]:_XNOME:TEXT  PIXEL OF oPage:aDialogs[nPageXml] COLOR CLR_BLUE FONT oFont01
			@ nCC1+nDist  ,nCC2 MSGet oGet9 VAR Val(aComp[9]:_VCOMP:TEXT) SIZE 60,08 PICTURE "@E 999,999.99" PIXEL OF oPage:aDialogs[nPageXml] WHEN lWhen           	    
			nCC1  += nSalt
	    EndIf
	 
	 		nCC1  := 005
			nCC2  += nColCC       
		
			//Coluna 4
	 
	  	If Type("aComp[10]:_XNOME:TEXT") <> "U" .And. Type("aComp[10]:_VCOMP:TEXT") <> "U"	
			@ nCC1    	  ,nCC2 Say aComp[10]:_XNOME:TEXT  PIXEL OF oPage:aDialogs[nPageXml] COLOR CLR_BLUE FONT oFont01
			@ nCC1+nDist  ,nCC2 MSGet oGet10 VAR Val(aComp[10]:_VCOMP:TEXT) SIZE 60,08 PICTURE "@E 999,999.99" PIXEL OF oPage:aDialogs[nPageXml] WHEN lWhen          	    
			nCC1  += nSalt
	    EndIf
	   	If Type("aComp[11]:_XNOME:TEXT") <> "U" .And. Type("aComp[11]:_VCOMP:TEXT") <> "U"
			@ nCC1        ,nCC2 Say aComp[11]:_XNOME:TEXT  PIXEL OF oPage:aDialogs[nPageXml] COLOR CLR_BLUE FONT oFont01
			@ nCC1+nDist  ,nCC2 MSGet oGet11 VAR Val(aComp[11]:_VCOMP:TEXT) SIZE 60,08 PICTURE "@E 999,999.99" PIXEL OF oPage:aDialogs[nPageXml] WHEN lWhen           	    
			nCC1  += nSalt
	    EndIf
	   	If Type("aComp[12]:_XNOME:TEXT") <> "U" .And. Type("aComp[12]:_VCOMP:TEXT") <> "U"
			@ nCC1        ,nCC2 Say aComp[12]:_XNOME:TEXT  PIXEL OF oPage:aDialogs[nPageXml] COLOR CLR_BLUE FONT oFont01
			@ nCC1+nDist  ,nCC2 MSGet oGet12 VAR Val(aComp[12]:_VCOMP:TEXT) SIZE 60,08 PICTURE "@E 999,999.99" PIXEL OF oPage:aDialogs[nPageXml] WHEN lWhen           	    
			nCC1  += nSalt
	    EndIf
	Else
	
	EndIf
		
Return()*/

**********************************
User Function XMLF6ItemPC2(oGet2)
**********************************
	//Local lRet    := .T. 
	Local Nx      := 0
	Local aFields := {"C7_NUM","C7_ITEM","C7_PRODUTO","C7_QUANT"}      
	Local aCab    := {}
	Local aCampos := {} 
	Local aTamCab := {} 
	Local aPedido := {}
	Local nPosPRD := aScan(aHeader,{|x| Alltrim(x[2]) == "D1_COD" })
	Local nPosPDD := aScan(aHeader,{|x| Alltrim(x[2]) == "D1_PEDIDO" })
	Local nPosITM := aScan(aHeader,{|x| Alltrim(x[2]) == "D1_ITEMPC" })
	//Local nPosQTD := aScan(aHeader,{|x| Alltrim(x[2]) == "D1_QUANT" })
	Local cVar	  := aCols[n][nPosPrd]
	Local oPanel , oDlg
	//Local nSavQual:= 0  
	Local bClickF6 := {|| BblClkPC(oGet2,oQual,nPosPDD,nPosITM), oDlg:End() }
	Local aButPed		:= { {'PESQUISA',{||A103VisuPC(aPedido[oQual:nAt][2])},"Visualiza Pedido","Visualiza Pedido"},; //
		{'pesquisa',{||A103PesqP(aCab,aCampos,aPedido,oQual)},"Pesquisar"} } //
	//MsgAlert("Pedido") 
	aadd(aPedido,{"012358","01",Padr("FRETE",15),  12} )
	aadd(aPedido,{"775858","03",Padr("FRETE",15),  01} )
	aadd(aPedido,{"222222","05",Padr("FRETE",15),  14} )
	aadd(aPedido,{"099999","05",Padr("FRETE",15), 100} ) 
	
	DbSelectArea("SX3")
	DbSetOrder(2)
	
	For Nx := 1 To Len(aFields)
	
		DbSeek(aFields[Nx])
		AAdd(aCab,x3Titulo())
		Aadd(aCampos,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_CONTEXT,SX3->X3_PICTURE})
		aadd(aTamCab,CalcFieldSize(SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_PICTURE,X3Titulo()))
	Next
	                   
	
		DEFINE MSDIALOG oDlg FROM 30,20  TO 265,521 TITLE OemToAnsi("Selecionar Pedido de Compra ( por item ) - <F6> ") Of oDlg PIXEL //"Selecionar Pedido de Compra ( por item )"
	
		    
		DbSelectArea("SX3")
	 	DbSetOrder(2)								
		
		For nX := 1 to Len(aCab)
	    	If aScan(aCampos,{|x| x[1]= aCab[nX]})==0
				If SX3->(MsSeek(aCab[nX]))				
	        		aadd(aCampos,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_CONTEXT,SX3->X3_PICTURE})
	        	EndIf
	   		EndIf
		Next
			
		@ 12,0 MSPANEL oPanel PROMPT "" SIZE 100,19 OF oDlg CENTERED LOWERED //"Botoes"
		oPanel:Align := CONTROL_ALIGN_TOP
	
		oQual := TWBrowse():New( 29,4,243,85,,aCab,aTamCab,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
		oQual:SetArray(aPedido)
		oQual:bLine := { || aPedido[oQual:nAT] }
		oQual:BLDBLCLICK := bClickF6 
		oQual:nFreeze := 1 
	
		oQual:Align := CONTROL_ALIGN_ALLCLIENT
	
		If !Empty(cVar)
			@ 6  ,4   SAY OemToAnsi("Produto") Of oPanel PIXEL SIZE 47 ,9 //"Produto"
			@ 4  ,30  MSGET cVar PICTURE PesqPict('SB1','B1_COD') When .F. Of oPanel PIXEL SIZE 80,9
		Else
			@ 6  ,4   SAY OemToAnsi("Selecione o Pedido de Compra") Of oPanel PIXEL SIZE 120 ,9 //"Selecione o Pedido de Compra"
		EndIf
	
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,bClickF6,{||oDlg:End()},,aButPed)
	Conout("Pedido")
Return      

*****************************************************
Static Function BblClkPC(oGet2,oQual,nPosPDD,nPosITM) 
*****************************************************
	Local nPc := oQual:nAT 
	Local nIt := oGet2:NAT
	 
	oGet2:ACOLS[nIt][nPosPDD] := oQual:AARRAY[nPc][1]
	oGet2:ACOLS[nIt][nPosITM] := oQual:AARRAY[nPc][3] 
	
	oGet2:Refresh(.F.)
   
Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³  F6ItemPC ³ Autor ³Roberto Souza        ³ Data ³27/06/2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³  Retorna a especie padrao de acordo com o modelo           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function F6ItemPC(lUsaFiscal,aPedido,oGetDAtu,lNfMedic,lConsMedic,aHeadSDE,aColsSDE,aGets,oGet2)

Local cSeek			:= ""
Local nOpca			:= 0
Local aArea			:= GetArea()
Local aAreaSA2		:= SA2->(GetArea())
Local aAreaSC7		:= SC7->(GetArea())
Local aAreaSB1		:= SB1->(GetArea())
//Local aRateio       := {0,0,0}
Local aNew			:= {}
Local aTamCab		:= {}
//Local lGspInUseM	:= If(Type('lGspInUse')=='L', lGspInUse, .F.)
Local aButtons		:= { {'PESQUISA',{||A103VisuPC(aArrSldo[oQual:nAt][2])},"Visualiza Pedido","Visualiza Pedido"},; //"Visualiza Pedido"
	{'pesquisa',{||A103PesqP(aCab,aCampos,aArrayF4,oQual)},"Pesquisar"} } //"Pesquisar"
Local aEstruSC7		:= SC7->( dbStruct() )
Local bSavSetKey	:= SetKey(VK_F4,Nil)
Local bSavKeyF5		:= SetKey(VK_F5,Nil)
Local bSavKeyF6		:= SetKey(VK_F6,Nil)
Local bSavKeyF7		:= SetKey(VK_F7,Nil)
Local bSavKeyF8		:= SetKey(VK_F8,Nil)
Local bSavKeyF9		:= SetKey(VK_F9,Nil)
Local bSavKeyF10	:= SetKey(VK_F10,Nil)
Local bSavKeyF11	:= SetKey(VK_F11,Nil)
Local nFreeQt		:= 0
Local nPosPRD		:= aScan(aHeader,{|x| Alltrim(x[2]) == "D1_COD" })
Local nPosPDD		:= aScan(aHeader,{|x| Alltrim(x[2]) == "D1_PEDIDO" })
Local nPosITM		:= aScan(aHeader,{|x| Alltrim(x[2]) == "D1_ITEMPC" })
Local nPosQTD		:= aScan(aHeader,{|x| Alltrim(x[2]) == "D1_QUANT" })
Local nPosTes       := aScan(aHeader,{|x| AllTrim(x[2])=="D1_TES"})
Local nLinACols     := N
Local cVar			:= oGet2:ACOLS[oGet2:NAT][4] //aCols[n][nPosPrd] 
Local cQuery		:= ""
Local cAliasSC7		:= "SC7"
Local cCpoObri		:= ""
Local nSavQual
Local nPed			:= 0
Local nX			:= 0
Local nAuxCNT		:= 0
Local lMt103Vpc		:= ExistBlock("MT103VPC")
Local lMt100C7D		:= ExistBlock("MT100C7D")
Local lMt100C7C		:= ExistBlock("MT100C7C")
Local lMt103Sel		:= ExistBlock("MT103SEL")
Local nMT103Sel     := 0
//Local nSelOk        := 1
Local lRet103Vpc	:= .T.
Local lContinua		:= .T.
Local lQuery		:= .F.
Local oQual
Local oDlg
Local oPanel
Local aUsButtons  := {}
Local bClickF6 := {|| BblClkPC(oGet2,oQual,nPosPDD,nPosITM), nSavQual:=oQual:nAT,nOpca:=1,oDlg:End() }

PRIVATE aCab	   := {}
PRIVATE aCampos	   := {}
PRIVATE aArrSldo   := {}
PRIVATE aArrayF4   := {} 
PRIVATE lConsLoja  := .F.

DEFAULT lUsaFiscal := .T.
DEFAULT aPedido	   := {}
DEFAULT lNfMedic   := .F.
DEFAULT lConsMedic := .F.
DEFAULT aHeadSDE   := {}
DEFAULT aColsSDE   := {}
DEFAULT aGets      := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impede de executar a rotina quando a tecla F3 estiver ativa		    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("InConPad") == "L"
	lContinua := !InConPad
EndIf  

If Empty(cVar)
	U_MyAviso("Atenção","Selecione o produto antes.",{"OK"},2)
	lContinua:= .F.
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona botoes do usuario na EnchoiceBar                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "MTIPCBUT" )
	If ValType( aUsButtons := ExecBlock( "MTIPCBUT", .F., .F. ) ) == "A"
		AEval( aUsButtons, { |x| AAdd( aButtons, x ) } )
	EndIf
EndIf

If lContinua

	If MaFisFound('NF') .Or. !lUsaFiscal
		If cTipo == 'N'
			#IFDEF TOP
				DbSelectArea("SC7")
				If TcSrvType() <> "AS/400"

					If Empty(cVar)
						DbSetOrder(9)
					Else
						DbSetOrder(6)
					EndIf

					lQuery    := .T.
					cAliasSC7 := "QRYSC7"

					cQuery	  := "SELECT "
					For nAuxCNT := 1 To Len( aEstruSC7 )
						If nAuxCNT > 1
							cQuery += ", "
						EndIf
						cQuery += aEstruSC7[ nAuxCNT, 1 ]
					Next
					cQuery += ", R_E_C_N_O_ RECSC7 FROM "
					cQuery += RetSqlName("SC7") + " SC7 "
					cQuery += "WHERE "
					cQuery += "C7_FILENT = '"+xFilEnt(xFilial("SC7"))+"' AND "

					If HasTemplate( "DRO" ) .AND. FunName() == "MATA103" .AND. MV_PAR15 == 1
						cQuery += "C7_FORNECE IN ( " + T_DrogForn( cA100For ) + " ) AND "
					Else
					If Empty(cVar)
						If lConsLoja
							cQuery += "C7_FORNECE = '"+cA100For+"' AND "
							cQuery += "C7_LOJA = '"+cLoja+"' AND "
						Else
							cQuery += "C7_FORNECE = '"+cA100For+"' AND "
						Endif	
					Else
						If lConsLoja
							cQuery += "C7_FORNECE = '"+cA100For+"' AND "
							cQuery += "C7_LOJA = '"+cLoja+"' AND "
							cQuery += "C7_PRODUTO = '"+cVar+"' AND "
						Else
							cQuery += "C7_FORNECE = '"+cA100For+"' AND "
							cQuery += "C7_PRODUTO = '"+cVar+"' AND "
						Endif
					Endif
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Filtra os pedidos de compras de acordo com os contratos             ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

					If lConsMedic
						If lNfMedic
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Traz apenas os pedidos oriundos de medicoes                         ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							cQuery += "C7_CONTRA<>'"  + Space( Len( SC7->C7_CONTRA ) )  + "' AND "
							cQuery += "C7_MEDICAO<>'" + Space( Len( SC7->C7_MEDICAO ) ) + "' AND "		    		
						Else
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Traz apenas os pedidos que nao possuem medicoes                     ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							cQuery += "C7_CONTRA='"  + Space( Len( SC7->C7_CONTRA ) )  + "' AND "
							cQuery += "C7_MEDICAO='" + Space( Len( SC7->C7_MEDICAO ) ) + "' AND "		    		
						EndIf
					EndIf 					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Filtra os Pedidos Bloqueados e Previstos.                ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cQuery += "C7_TPOP <> 'P' AND "
					If SuperGetMV("MV_RESTNFE") == "S"
						cQuery += "C7_CONAPRO <> 'B' AND "
					EndIf					
					cQuery += "SC7.C7_ENCER='"+Space(Len(SC7->C7_ENCER))+"' AND "					
					cQuery += "SC7.C7_RESIDUO='"+Space(Len(SC7->C7_RESIDUO))+"' AND "					

					cQuery += "SC7.D_E_L_E_T_ = ' '"
					cQuery += "ORDER BY "+SqlOrder(SC7->(IndexKey()))	

//					cQuery := ChangeQuery(cQuery)

					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC7,.T.,.T.)
					For nX := 1 To Len(aEstruSC7)
						If aEstruSC7[nX,2]<>"C"
							TcSetField(cAliasSC7,aEstruSC7[nX,1],aEstruSC7[nX,2],aEstruSC7[nX,3],aEstruSC7[nX,4])
						EndIf
					Next nX										
				Else
			#ENDIF			
				If Empty(cVar)
					DbSelectArea("SC7")
					DbSetOrder(9)
					If lConsLoja
						cCond := "C7_FILENT+C7_FORNECE+C7_LOJA"
						cSeek := cA100For+cLoja
						MsSeek(xFilEnt(xFilial("SC7"))+cSeek)
					Else
						cCond := "C7_FILENT+C7_FORNECE"
						cSeek := cA100For
						MsSeek(xFilEnt(xFilial("SC7"))+cSeek)
					EndIf
				Else
					DbSelectArea("SC7")
					DbSetOrder(6)
					If lConsLoja
						cCond := "C7_FILENT+C7_PRODUTO+C7_FORNECE+C7_LOJA"
						cSeek := cVar+cA100For+cLoja
						MsSeek(xFilEnt(xFilial("SC7"))+cSeek)
					Else
						cCond := "C7_FILENT+C7_PRODUTO+C7_FORNECE"
						cSeek := cVar+cA100For
						MsSeek(xFilEnt(xFilial("SC7"))+cSeek)
					EndIf
				EndIf
				#IFDEF TOP
				EndIf
				#ENDIF

			If Empty(cVar)
				cCpoObri := "C7_LOJA|C7_PRODUTO|C7_QUANT|C7_DESCRI|C7_TIPO|C7_LOCAL|C7_OBS"
			Else
				cCpoObri := "C7_LOJA|C7_QUANT|C7_DESCRI|C7_TIPO|C7_LOCAL|C7_OBS"
			Endif				

			If (cAliasSC7)->(!Eof())

				DbSelectArea("SX3")
				DbSetOrder(2)

				If lNfMedic .And. lConsMedic

					MsSeek("C7_MEDICAO")

					AAdd(aCab,x3Titulo())
					Aadd(aCampos,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_CONTEXT,SX3->X3_PICTURE})
					aadd(aTamCab,CalcFieldSize(SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_PICTURE,X3Titulo()))

					MsSeek("C7_CONTRA")

					AAdd(aCab,x3Titulo())
					Aadd(aCampos,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_CONTEXT,SX3->X3_PICTURE})
					aadd(aTamCab,CalcFieldSize(SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_PICTURE,X3Titulo()))

					MsSeek("C7_PLANILH")

					AAdd(aCab,x3Titulo())
					Aadd(aCampos,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_CONTEXT,SX3->X3_PICTURE})
					aadd(aTamCab,CalcFieldSize(SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_PICTURE,X3Titulo()))

				EndIf 			

				MsSeek("C7_NUM")

				AAdd(aCab,x3Titulo())
				Aadd(aCampos,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_CONTEXT,SX3->X3_PICTURE})
				aadd(aTamCab,CalcFieldSize(SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_PICTURE,X3Titulo()))

				DbSelectArea("SX3")
				DbSetOrder(1)
				MsSeek("SC7")
				While !Eof() .And. SX3->X3_ARQUIVO == "SC7"
					IF ( SX3->X3_BROWSE=="S".And.X3Uso(SX3->X3_USADO).And. AllTrim(SX3->X3_CAMPO)<>"C7_PRODUTO" .And. AllTrim(SX3->X3_CAMPO)<>"C7_NUM" .And.;
							If( lConsMedic .And. lNfMedic, AllTrim(SX3->X3_CAMPO)<>"C7_MEDICAO" .And. AllTrim(SX3->X3_CAMPO)<>"C7_CONTRA" .And. AllTrim(SX3->X3_CAMPO)<>"C7_PLANILH", .T. )).Or.;
							(AllTrim(SX3->X3_CAMPO) $ cCpoObri)
						AAdd(aCab,x3Titulo())
						Aadd(aCampos,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_CONTEXT,SX3->X3_PICTURE})
						aadd(aTamCab,CalcFieldSize(SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_PICTURE,X3Titulo()))
					EndIf
					dbSkip()		
				Enddo					

				DbSelectArea(cAliasSC7)
				Do While If(lQuery, ;
						(cAliasSC7)->(!Eof()), ;
						(cAliasSC7)->(!Eof()) .And. xFilEnt(cFilial)+cSeek == &(cCond))

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Filtra os Pedidos Bloqueados, Previstos e Eliminados por residuo   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !lQuery
						If (SuperGetMV("MV_RESTNFE") == "S" .And. (cAliasSC7)->C7_CONAPRO == "B") .Or. ;
								(cAliasSC7)->C7_TPOP == "P" .Or. !Empty((cAliasSC7)->C7_RESIDUO)
							dbSkip()
							Loop
						EndIf
					Endif

					nFreeQT := 0

					nPed    := aScan(aPedido,{|x| x[1] = (cAliasSC7)->C7_NUM+(cAliasSC7)->C7_ITEM})

					nFreeQT -= If(nPed>0,aPedido[nPed,2],0)

					For nAuxCNT := 1 To Len( aCols )
						If (nAuxCNT # n) .And. ;
							(aCols[ nAuxCNT,nPosPRD ] == (cAliasSC7)->C7_PRODUTO) .And. ;
							(aCols[ nAuxCNT,nPosPDD ] == (cAliasSC7)->C7_NUM) .And. ;
							(aCols[ nAuxCNT,nPosITM ] == (cAliasSC7)->C7_ITEM) .And. ;
							!ATail( aCols[ nAuxCNT ] )
							nFreeQT += aCols[ nAuxCNT,nPosQTD ]
						EndIf
					Next
					
					lRet103Vpc := .T.

					If lMt103Vpc
						If lQuery
							('SC7')->(dbGoto((cAliasSC7)->RECSC7))
						EndIf															
						lRet103Vpc := Execblock("MT103VPC",.F.,.F.)
					Endif

					If lRet103Vpc
						If ((nFreeQT := ((cAliasSC7)->C7_QUANT-(cAliasSC7)->C7_QUJE-(cAliasSC7)->C7_QTDACLA-nFreeQT)) > 0)
							Aadd(aArrayF4,Array(Len(aCampos)))							

							SB1->(DbSetOrder(1))
							SB1->(MsSeek(xFilial("SB1")+(cAliasSC7)->C7_PRODUTO))							
							For nX := 1 to Len(aCampos)

								If aCampos[nX][3] != "V"
									If aCampos[nX][2] == "N"
										If Alltrim(aCampos[nX][1]) == "C7_QUANT"
											aArrayF4[Len(aArrayF4)][nX] :=Transform(nFreeQt,PesqPict("SC7",aCampos[nX][1]))
										ElseIf Alltrim(aCampos[nX][1]) == "C7_QTSEGUM"
											aArrayF4[Len(aArrayF4)][nX] :=Transform(ConvUm(SB1->B1_COD,nFreeQt,nFreeQt,2),PesqPict("SC7",aCampos[nX][1]))
										Else
											aArrayF4[Len(aArrayF4)][nX] := Transform((cAliasSC7)->(FieldGet(FieldPos(aCampos[nX][1]))),PesqPict("SC7",aCampos[nX][1]))
										Endif											
									Else
										aArrayF4[Len(aArrayF4)][nX] := (cAliasSC7)->(FieldGet(FieldPos(aCampos[nX][1])))								
									Endif	
								Else
									aArrayF4[Len(aArrayF4)][nX] := CriaVar(aCampos[nX][1],.T.)
									If Alltrim(aCampos[nX][1]) == "C7_CODGRP"
										aArrayF4[Len(aArrayF4)][nX] := SB1->B1_GRUPO                            									
									EndIf
									If Alltrim(aCampos[nX][1]) == "C7_CODITE"
										aArrayF4[Len(aArrayF4)][nX] := SB1->B1_CODITE
									EndIf
								Endif

							Next

							aAdd(aArrSldo, {nFreeQT, IIF(lQuery,(cAliasSC7)->RECSC7,(cAliasSC7)->(RecNo()))})

							If lMT100C7D
								If lQuery
									('SC7')->(dbGoto((cAliasSC7)->RECSC7))
								EndIf									
								aNew := ExecBlock("MT100C7D", .f., .f., aArrayF4[Len(aArrayF4)])
								If ValType(aNew) = "A"
									aArrayF4[Len(aArrayF4)] := aNew
								EndIf
							EndIf
						EndIf
					Endif
					(cAliasSC7)->(dbSkip())
				EndDo

				If ExistBlock("MT100C7L")
					ExecBlock("MT100C7L", .F., .F., { aArrayF4, aArrSldo })
				EndIf

				If !Empty(aArrayF4)

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Monta dinamicamente o bline do CodeBlock                 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					DEFINE MSDIALOG oDlg FROM 30,20  TO 265,521 TITLE OemToAnsi("Selecionar Pedido de Compra ( por item )"+" - <F6> ") Of oMainWnd PIXEL //"Selecionar Pedido de Compra ( por item )"

					If lMT100C7C
						aNew := ExecBlock("MT100C7C", .f., .f., aCab)
						If ValType(aNew) == "A"
							aCab := aNew      
							    
							DbSelectArea("SX3")
			 				DbSetOrder(2)								
							
							For nX := 1 to Len(aCab)
						    	If aScan(aCampos,{|x| x[1]= aCab[nX]})==0
        						 If SX3->(MsSeek(aCab[nX]))				
        						 		Aadd(aCampos,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_CONTEXT,SX3->X3_PICTURE})
        						 EndIf
   								EndIf
							Next nX
							
							
						EndIf
					EndIf

					@ 12,0 MSPANEL oPanel PROMPT "" SIZE 100,19 OF oDlg CENTERED LOWERED //"Botoes"
					oPanel:Align := CONTROL_ALIGN_TOP

					oQual := TWBrowse():New( 29,4,243,85,,aCab,aTamCab,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
					oQual:SetArray(aArrayF4)
					oQual:bLine := { || aArrayF4[oQual:nAT] }
					oQual:BLDBLCLICK := bClickF6
					OQual:nFreeze := 1 

					oQual:Align := CONTROL_ALIGN_ALLCLIENT

					If !Empty(cVar)
						@ 6  ,4   SAY OemToAnsi("Produto") Of oPanel PIXEL SIZE 47 ,9 //"Produto"
						@ 4  ,30  MSGET cVar PICTURE PesqPict('SB1','B1_COD') When .F. Of oPanel PIXEL SIZE 80,9
					Else
						@ 6  ,4   SAY OemToAnsi("Selecione o Pedido de Compra") Of oPanel PIXEL SIZE 120 ,9 //"Selecione o Pedido de Compra"
					EndIf

					ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,bClickF6,{||oDlg:End()},,aButtons)
					
				  	If lMt103Sel .And. !Empty(nSavQual)		
				   		nOpca := If(ValType(nMT103Sel:=ExecBlock("MT103SEL",.F.,.F.,{aArrSldo[nSavQual][2]}))=='N',nMT103Sel,nOpca)
				   	Endif     
					If nOpca == 1
						DbSelectArea("SC7")
						MsGoto(aArrSldo[nSavQual][2])
						
   				        // Verifica se o Produto existe Cadastrado na Filial de Entrada
					    DbSelectArea("SB1")
						DbSetOrder(1)
						MsSeek(xFilial("SB1")+SC7->C7_PRODUTO)
						If !Eof()
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Qdo digitado o produto no aCols para buscar o PC via F6 e carregado uma TES vinda do  ³
							//³ SB1 se esta for igual a TES digitada no PC o recalculo dos impostos nao e acionado    ³
							//³ na matxfis,para forcar o recalculo o TES do aCols e limpa neste ponto.                ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If lUsaFiscal
								aCols[nLinACols][nPosTes] := CriaVar(aHeader[nPosTes][2]) 
								MaFisAlt("IT_TES",aCols[nLinACols][nPosTes],nLinACols)
                            EndIf
/*                            
							If	!ATail( aCols[ n ] )
								u_NfePC2Acol(aArrSldo[nSavQual][2],n,aArrSldo[nSavQual][1],,,@aRateio,aHeadSDE,@aColsSDE)
		        				Else
								u_NfePC2Acol(aArrSldo[nSavQual][2],n+1,aArrSldo[nSavQual][1],,,@aRateio,aHeadSDE,@aColsSDE)        				
		        				EndIf
*/							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Impede que o item do PC seja deletado pela getdados da NFE na movimentacao das setas. ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If ValType( oGetDAtu ) == "O"
								oGetDAtu:lNewLine := .F.
							Else
								If Type( "oGetDados" ) == "O"
									oGetDados:lNewLine:=.F.
								EndIf
							EndIf
						Else
  						   Aviso("A103ItemPC","O Produto selecionado do Pedido de compra, não possui cadastro na Filial de Entrada da Nota Fiscal. Favor efetuar cadastro !",{"Ok"})
						EndIf
					EndIf
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Rateio do valores de Frete/Seguro/Despesa do PC            ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*
					If lUsaFiscal
						Eval(bRefresh)
					Else
						aGets[07] += aRateio[1]
						aGets[05]+= aRateio[2]
						aGets[04]  += aRateio[3]
					EndIf
*/
				Else
					U_MyAviso("Aviso","Item sem pedidos disponíveis para este fornecedor.",{"OK"})
//					Help(" ",1,"A103F4")
				EndIf
			Else
				U_MyAviso("Aviso","Item sem pedidos disponíveis para este fornecedor.",{"OK"})
//				Help(" ",1,"A103F4")

			EndIf
		Else
			U_MyAviso("Aviso","Consulta habilitada apenas para notas do tipo N=Normal.",{"OK"})
		EndIf
	Else
		Help('   ',1,'A103CAB')
	EndIf

Endif

If lQuery
	DbSelectArea(cAliasSC7)
	dbCloseArea()
	DbSelectArea("SC7")
Endif	

SetKey(VK_F4,bSavSetKey)
SetKey(VK_F5,bSavKeyF5)
SetKey(VK_F6,bSavKeyF6)
SetKey(VK_F7,bSavKeyF7)
SetKey(VK_F8,bSavKeyF8)
SetKey(VK_F9,bSavKeyF9)
SetKey(VK_F10,bSavKeyF10)
SetKey(VK_F11,bSavKeyF11)
RestArea(aAreaSA2)
RestArea(aAreaSC7)
RestArea(aAreaSB1)
RestArea(aArea)
Return() 
                  

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³  RetF3    ³ Autor ³Roberto Souza        ³ Data ³27/06/2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³  Pesquisa de GET usando F3                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/*Static Function RetF3(cCampo,cDefault)

	Local aArea	:= GetArea()
	Local cF3 	:= ""
	Local cSavRec
	//cCampo := IIf(cTipo$"DB","F2_CLIENTE","F1_FORNECE")
	cDefault 	:= IIF(cDefault==Nil,"",cDefault)
	
	dbSelectArea("SX3")
	cSavRec	:= RecNo()
	dbSetOrder(2)
	If dbSeek(cCampo)
		If !Empty(X3_F3)
			cF3 := X3_F3
		Else
			cF3 := cDefault
		EndIf
	EndIf
	dbSetOrder(1)
	dbGoto(cSavRec)
	RestArea(aArea)

Return(cF3)  */   
           
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³  SpecXml  ³ Autor ³Roberto Souza        ³ Data ³27/06/2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³  Retorna a especie padrao de acordo com o modelo           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function SpecXml(cModelo, cDefault)
	Local cRet := ""
	Default cModelo := "55"
	Default cDefault := "SPED"
	If cModelo == "55"
		cRet := "SPED"                     
	ElseIf cModelo == "57"
		cRet := "CTE" 
	Else 
		cRet := cDefault
	EndIf	         

Return(cRet)



/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³  XChkXml  ³ Autor ³Roberto Souza        ³ Data ³30/08/2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³  Retorna a especie padrao de acordo com o modelo           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function UPCfgXML()

	//Local cRet := ""
	//Local aJobs:= {}
	//Local Nx   := 1
	Local oDlg                                                        
	Local oChkOnX, oChkOn1, oChkOn2, oChkOn3, oChkOn4, oChkOn5, oChkOn6, /*oChkOn7,*/ oChkOn8, oChkOn9
	Local cRotImp  := GetNewPar("XM_ROTINAS","1,2,3,6")
	Local lChkOnX  :=  ("X" $ cRotImp)
	Local lChkOn1  :=  ("1" $ cRotImp)
	Local lChkOn2  :=  ("2" $ cRotImp)
	Local lChkOn3  :=  ("3" $ cRotImp)
	Local lChkOn4  :=  ("4" $ cRotImp)
	Local lChkOn5  :=  ("5" $ cRotImp)
	Local lChkOn6  :=  ("6" $ cRotImp)
	Local lChkOn7  :=  ("7" $ cRotImp)
	Local lChkOn8  :=  ("8" $ cRotImp)
	Local lChkOn9  :=  ("9" $ cRotImp)
	Local nOpc     := 0
	Private oFont01:= TFont():New("Arial",07,14,,.T.,,,,.T.,.F.)
	//
	// A Consulta de xml (4) é desabilitada por default para evitar lentidão	 
	//
	                                                                  
	DEFINE MSDIALOG oDlg TITLE "Selecao de Rotinas" FROM 000,000 TO 400,400 PIXEL STYLE DS_MODALFRAME STATUS
	
	@ 00.5,00.5 to 011,024.5 OF oDlg   
	
	@ 010 ,010 SAY "Selecione as rotinas a serem executadas:" PIXEL OF oDlg COLOR CLR_BLUE FONT oFont01
	@ 025 ,010 CHECKBOX oChkOnX VAR lChkOnX PROMPT "X-Todos"            SIZE 65,8 PIXEL OF oDlg COLOR CLR_BLUE FONT oFont01//;
	//         ON CHANGE(Iif( lChkOnX ,(oChkOn1:LREADONLY:=.T.,lChkOn2:LREADONLY:=.T.,lChkOn3:LREADONLY:=.T.),;
	//         			             (oChkOn1:LREADONLY:=.F.,lChkOn2:LREADONLY:=.F.,lChkOn3:LREADONLY:=.F.))    )
	
	@ 040 ,010 CHECKBOX oChkOn1 VAR lChkOn1 PROMPT "1-Verificar E-mail" SIZE 65,8 PIXEL OF oDlg COLOR CLR_BLUE FONT oFont01
	//         ON CHANGE(Iif(!lChkOn1,lChkOnX:=.F.,Nil))
	
	@ 055 ,010 CHECKBOX oChkOn2 VAR lChkOn2 PROMPT "2-Validar Xml"      SIZE 65,8 PIXEL OF oDlg COLOR CLR_BLUE FONT oFont01
	//         ON CHANGE(Iif(!lChkOn2,lChkOnX:=.F.,Nil))
	
	@ 070 ,010 CHECKBOX oChkOn3 VAR lChkOn3 PROMPT "3-Checar Pré-Nota"  SIZE 65,8 PIXEL OF oDlg COLOR CLR_BLUE FONT oFont01
	//         ON CHANGE(Iif(!lChkOn3,lChkOnX:=.F.,Nil))
	
	@ 085 ,010 CHECKBOX oChkOn4 VAR lChkOn4 PROMPT "4-Consulta de xmls"  SIZE 95,8 PIXEL OF oDlg COLOR CLR_BLUE FONT oFont01 WHEN .F.
	//         ON CHANGE(Iif(!lChkOn3,lChkOnX:=.F.,Nil))
	
	@ 100 ,010 CHECKBOX oChkOn5 VAR lChkOn5 PROMPT "5-Notificações por E-mail"  SIZE 95,8 PIXEL OF oDlg COLOR CLR_BLUE FONT oFont01
	//         ON CHANGE(Iif(!lChkOn3,lChkOnX:=.F.,Nil))
	
	@ 115 ,010 CHECKBOX oChkOn6 VAR lChkOn6 PROMPT "6-Download Conector Sefaz"  SIZE 100,8 PIXEL OF oDlg COLOR CLR_BLUE FONT oFont01
	//         ON CHANGE(Iif(!lChkOn3,lChkOnX:=.F.,Nil))
	
	//@ 130 ,010 CHECKBOX oChkOn7 VAR lChkOn7 PROMPT "7-Envia PDF Conversor"  SIZE 95,8 PIXEL OF oDlg COLOR CLR_BLUE FONT oFont01
	//         ON CHANGE(Iif(!lChkOn3,lChkOnX:=.F.,Nil))

	@ 130 ,010 CHECKBOX oChkOn8 VAR lChkOn8 PROMPT "8-Integração Conversão de Imagens"  SIZE 150,8 PIXEL OF oDlg COLOR CLR_BLUE FONT oFont01
	//         ON CHANGE(Iif(!lChkOn3,lChkOnX:=.F.,Nil))
	
	@ 145 ,010 CHECKBOX oChkOn9 VAR lChkOn9 PROMPT "9-Download NFSE API"  SIZE 150,8 PIXEL OF oDlg COLOR CLR_BLUE FONT oFont01
	oChkOnX:cToolTip := "Todas as rotinas disponíveis."
	oChkOn1:cToolTip := "Verificar E-mail e salvar arquivos no diretório indicado."
	oChkOn2:cToolTip := "Validar Xml quanto a estrutura e consulta junto a SEFAZ."
	oChkOn3:cToolTip := "Checar Pré-Nota e sincronizar os Status." 
	oChkOn4:cToolTip := "Consulta os Xmls já recebidos previamente, de acordo com os parametros configurados."+CRLF+"Atenção."+CRLF+"Esta opção somente pode ser habilitada para o Job de execução Robótica.[Configurações Job]"
	oChkOn5:cToolTip := "Enviar e-mails de notificação de erros e cancelamentos."
	oChkOn6:cToolTip := "Fazer Download das chaves que tiveram problemas na SEFAZ."
	//oChkOn7:cToolTip := "Envia PDF para o Image Convertor na Nuvem, essa ferramenta converte o pdf pre configurado em xml.
	oChkOn8:cToolTip := "Baixa XML Convertido do Image Convertor e disponibiliza dentro da pasta xmlsource/imagem, essa rotina traz o pdf convertido em xml e importa para o protheus.
	oChkOn9:cToolTip := "Consulta as Notas das prefeituras via webservice."
	
	@ 160 ,110 Button "Cancelar" Size 040,015 PIXEL OF oDlg ACTION oDlg:End()                                                        
	@ 160 ,155 Button "Salvar" Size 040,015 PIXEL OF oDlg ACTION (nOpc:=1,oDlg:End())                                                        
	
	ACTIVATE MSDIALOG oDlg CENTERED 
	
	If nOpc ==1
		If lChkOnX
			cRet := "X"
		Else
			cRet := ""
			If lChkOn1
				cRet += Iif(!Empty(cRet),",","" )+"1"
			EndIf
			If lChkOn2
				cRet += Iif(!Empty(cRet),",","" )+"2"
			EndIf
			If lChkOn3
				cRet += Iif(!Empty(cRet),",","" )+"3"
			EndIf
			If lChkOn4
				cRet += Iif(!Empty(cRet),",","" )+"4"
			EndIf
			If lChkOn5
				cRet += Iif(!Empty(cRet),",","" )+"5"
			EndIf							
			If lChkOn6
				cRet += Iif(!Empty(cRet),",","" )+"6"
			EndIf			
			If lChkOn7
				cRet += Iif(!Empty(cRet),",","" )+"7"
			EndIf				
			If lChkOn8
				cRet += Iif(!Empty(cRet),",","" )+"8"
			EndIf
			If lChkOn9
				cRet += Iif(!Empty(cRet),",","" )+"9"
			EndIf			
		EndIf	
	
		/********************************/
		If !PutMv("XM_ROTINAS", cRet ) 
			RecLock("SX6",.T.)
			SX6->X6_FIL     := xFilial("SX6")
			SX6->X6_VAR     := "XM_ROTINAS"
			SX6->X6_TIPO    := "C"
			SX6->X6_DESCRIC := "Rotinas a serem executadas pelo botão 'Baixar XML'."
			MsUnLock()
			PutMv("XM_ROTINAS", cRet ) 
		EndIf
		rstmvbuff()
	
	Else
		cRet := cRotImp      
	Endif

Return

User Function UPParExc()

	Local aAreaSm0 		:= GetArea("SM0")
	Local aCombo		:= {"C=COMPARTILHADO","E=EXCLUSIVO"}
	Local aParams		:= {"XM_DATAMUN","XM_CLTOKEN"}
	Local cCombo1		:= ""
	Local cCombo2		:= ""
	Local aFil			:= {}
	Local nRet			:= 0
	Local nX			:= 0
	Local cPar			:= ""

    DEFINE DIALOG oDlg TITLE "Parâmetros Exclusivos/Compartilhados" FROM 0,0 TO 250,640 PIXEL

  		oFont := TFont():New('Courier new',,-18,.T.)
  
  		//Labels
		oSPar	:= TSay():New(002,005,{||'Parâmetro'}				,oDlg,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,050,10)
		oSNome	:= TSay():New(002,080,{||'Modo'}					,oDlg,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,030,10)

		//XM_DATAMUN
		oPar1 	:= TGet():New(015,005,{||aParams[1]							},oDlg,050,010, "@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,"aParams[1]"	,,,, )
		cCombo1:= aCombo[1]
        oCombo1 := TComboBox():New(015,080,{|u|if(PCount()>0,cCombo1:=u,cCombo1)},aCombo,100,013,oDlg,,,,,,.T.,,,,,,,,,'cCombo1')

		//XM_CLTOKEN
		oPar2 	:= TGet():New(030,005,{||aParams[2]							},oDlg,050,010, "@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,"aParams[2]"	,,,, )
		cCombo2:= aCombo[1]
        oCombo2 := TComboBox():New(030,080,{|u|if(PCount()>0,cCombo2:=u,cCombo2)},aCombo,100,013,oDlg,,,,,,.T.,,,,,,,,,'cCombo2')

		oButOk:=tButton():New(080,080,'Salvar'	,oDlg,{||oDlg:End(),nRet := 1},050,20,,,,.T.) 
 		oButCa:=tButton():New(080,150,'Cancelar',oDlg,{||oDlg:End(),nRet := 0},050,20,,,,.T.) 
    
	ACTIVATE DIALOG oDlg CENTERED
 
	If nRet == 1
		dbSelectArea("SM0")
		SM0->(dbSetOrder(1))
		SM0->(dbGoTop())

		SM0->(dbSeek(CEMPANT))

		While !SM0->(EOF()) .And. SM0->M0_CODIGO == CEMPANT
			aAdd(aFil,{alltrim(SM0->M0_CODFIL),SM0->M0_NOMECOM})
			SM0->(dbSkip())
		End	

		dbSelectArea("SX6")
		SX6->(dbSetOrder(1))

		If cCombo1 == "C"
			For nX := 1 to Len(aFil)
				If SX6->(dbSeek(aFil[nX,1]+aParams[1]))
					RecLock("SX6",.F.)
						SX6->(dbDelete())
					SX6->(MsUnLock())
				EndIf
			Next

			If !SX6->(dbSeek(space(len(cFilAnt))+aParams[1]))

				RecLock("SX6",.T.)
					SX6->X6_FIL     := ""
					SX6->X6_VAR     := aParams[1]
					SX6->X6_TIPO    := "C"
					SX6->X6_DESCRIC := "Data da Ultima Verificacao de atualizacao de munic"
				SX6->(MsUnLock())
			
			EndIf	

		Else

			For nX := 1 to Len(aFil)
				If !SX6->(dbSeek(aFil[nX,1]+aParams[1]))
					RecLock("SX6",.T.)
						SX6->X6_FIL     := aFil[nX,1]
						SX6->X6_VAR     := aParams[1]
						SX6->X6_TIPO    := "C"
						SX6->X6_DESCRIC := "Data da Ultima Verificacao de atualizacao de munic"
					SX6->(MsUnLock())				
				EndIf
			Next

			If SX6->(dbSeek(space(len(cFilAnt))+aParams[1]))
				RecLock("SX6",.F.)
					SX6->(dbDelete())
				SX6->(MsUnLock())				
			EndIf
		
		EndIf

		If cCombo2 == "C"
			For nX := 1 to Len(aFil)
				If SX6->(dbSeek(aFil[nX,1]+aParams[2]))
					RecLock("SX6",.F.)
						SX6->(dbDelete())
					SX6->(MsUnLock())
				EndIf
			Next

			If !SX6->(dbSeek(space(len(cFilAnt))+aParams[2]))

				RecLock("SX6",.T.)
					SX6->X6_FIL     := ""
					SX6->X6_VAR     := aParams[2]
					SX6->X6_TIPO    := "C"
					SX6->X6_DESCRIC := "Token Cloud"
				SX6->(MsUnLock())
			
			EndIf	

		Else

			For nX := 1 to Len(aFil)
				If !SX6->(dbSeek(aFil[nX,1]+aParams[2]))
					RecLock("SX6",.T.)
						SX6->X6_FIL     := aFil[nX,1]
						SX6->X6_VAR     := aParams[2]
						SX6->X6_TIPO    := "C"
						SX6->X6_DESCRIC := "Token Cloud"
					SX6->(MsUnLock())				
				EndIf
			Next

			If SX6->(dbSeek(space(len(cFilAnt))+aParams[2]))
				RecLock("SX6",.F.)
					SX6->(dbDelete())
				SX6->(MsUnLock())
			EndIf
		
		EndIf

	else
			
		MsgAlert("Cancelado pelo operador")
	Return

	EndIf

	RestArea(aAreaSm0)
	
	msgInfo("Processo concluído com sucesso")

Return

************************************
Static Function __Dummy(lRecursa) //warning W0010 Static Function <?> never called  
***********************************
    lRecursa := .F.
    IF (lRecursa)
        __Dummy(.F.)
        U_XMLLINOK()
        U_XMLOKCAB()
        U_F6ITEMPC()
        U_XMLF6ITEMPC2()
        U_SHOWPN()
        U_GETJOB()
        U_FILLCAB()
        U_HFXML04()
        U_LOADCFGX()
        U_REFGETF()
        U_MAILERRO()
        U_HF_MAIL()
        U_XMLDELOK()
        U_XMLFLDOK()
        U_XMLTOK()
        U_XMLSETNF()
        U_SPECXML()
        U_UPCFGXML()
		U_UPPAREXC()
        U_VISNOTA()
	EndIF
Return(lRecursa)
