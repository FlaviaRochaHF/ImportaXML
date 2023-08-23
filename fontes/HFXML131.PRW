#INCLUDE "protheus.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "totvs.ch"   
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE "FILEIO.CH"
#INCLUDE "XMLXFUN.CH" 
#INCLUDE "PRTOPDEF.CH"

#define TST_MAXTHREAD 50

Static lUnix  := IsSrvUnix()
Static cBarra := Iif(lUnix,"/","\")

//------------------------------------------------------------------------------------//
//FR - 18/05/2020 - Alterações realizadas para adequar na rotina Pré Auditoria Fiscal
//                  verificação de divergências entre XML x NF 
//------------------------------------------------------------------------------------//
//FR - 02/07/2020 - Alterações realizadas para adequar na rotina classificação
//                  automática Aguas do Brasil: campo Loja do Fornecedor 
//------------------------------------------------------------------------------------//
// Alterações realizadas:
// FR - 16/07/2020 - Adequação da performance do download, na execução do Job Aguas Br
//------------------------------------------------------------------------------------//
//FR - 06/08/2020 - Alterações realizadas para adequar dentro do redownload, 
//                  ao esgotar as tentativas, alertar o usuário (se dentro do Protheus), 
//                  ou enviar email (se via job) 
//------------------------------------------------------------------------------------//
//FR - 16/08/2020 - Adequação da mensagem aviso ao final do redownload 
//------------------------------------------------------------------------------------//
//FR - 08/09/2020 - Adequação das chamadas na manifestação
//------------------------------------------------------------------------------------//
//FR - 22/09/2020 - Adequação do uso do novo parâmetro XM_CLATPNF 
//                  Tipos de NF a serem contempladas na classficação automática
//                  C-Combustiveis; E-Energia; T-Todos; N-Nenhum
//------------------------------------------------------------------------------------//
//FR - 25/09/2020 - Adequação do uso da condição de pagamento da Kroma (6o. dia útil) 
//                  Pelo novo parâmetro criado: XM_DIASVCT
//------------------------------------------------------------------------------------//
//FR - 05/10/2020 - Adequação da função de classificação de nf Energia para ser usada
//                  via Schedule (fonte: HFXML134)
//                  Declaração das variáveis de macro substituição das tabelas do Importa
//                  pois no job, ocorria error log por erro de não encontrar a
//                  tabela aberta (variável não existe xZBZ , xZBT ...assim por diante)
//------------------------------------------------------------------------------------//
//FR - 03/11/2020 - Adequação de variáveis das tabelas via macro substituição
//------------------------------------------------------------------------------------//
//FR - 13/11/2020 - Adequação para uso do parâmetro XM_KRDIASR - dias a retroagir
//                  da Database, para considerar apenas NF's deste período
//------------------------------------------------------------------------------------//
//FR - 16/11/2020 - Adequação do nome do arquivo txt que será gravado na tabela de
//                  ocorrências (ZBO), para as NFs de Energia apenas
//------------------------------------------------------------------------------------//
//FR - 23/11/2020 - Ajustes qto ao vencimento do pedido as NFs de Energia apenas
//------------------------------------------------------------------------------------//
//FR - 14/12/2020 - Ajustes para otimizar o processo da query de leitura dos XMLs
//                  de Energia
//------------------------------------------------------------------------------------//
//FR - 28/10/2021 - Implementação cadastro fornecedor (SA2) automatizado (Daikin)
//                  Parâmetro: "XM_SA2AUTO" Tipo Caracter, conteúdo : S-Sim; N=Não
/*
//Escopo passado por Rafael Lobitsky - 28/10/2021:
Criar um parâmetro chamado : Fornecedor auto S=sim;N=não - "XM_SA2AUTO"
-> Help “ Informa se ao baixar o xml e não encontrar o fornecedor cadastrado , efetua o cadastro do mesmo de forma robótica “
-> Incluir este parâmetro em nossa aba de cadastros gerais ou gerais2
-> Incluir este parâmetro no programa de instalador do GESTÃO XML para ao rodar o compatibilizador será criado automático 
-> Utilizar nosso ponto de entrada do gestão XML para colocar a regra de criação de código do fornecedor padrão Daikin
no momento de ser criado de forma robotica (se usa montagem de de A2_COD modelo Daikin ou padrão SXENUM )
*/
//------------------------------------------------------------------------------------//
//FR - 07/12/2021 - Projeto Kitchens - Solicitado por Rafael Lobitsky
//                  Inclusão de rotina para geração de pedido compra
//                  Função para localizar o produto pela NCM U_fVerSB1N
//------------------------------------------------------------------------------------//
//FR - 21/12/2021 - Revisão dos parâmetros de automatização do cadastro de 
//                  fornecedor:
//                  - XM_SA2AUTO - cadastra fornecedor na classif. nf
//                  - XM_SA2AUTD - cadastra fornecedor no download xml
//-----------------------------------------------------------------------------------//

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HFXML131  ºAutor  ³Eneovaldo Roveri Jr º Data ³  Amanha     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotinas Classificação Automática de Terceiros Combustiveis º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ HFXML131                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function HFXML131()

Local aArea   := GetArea()
Local cClAt   := GetNewPar("XM_CLAT"   ,"N")
Local oSCR1
Local lTemPC	  := .F.		//FR - 18/08/2020
Local cClatTipos  := ""			//FR - 22/09/2020
Local oProcess	  :=	Nil		//FR - 25/09/2020 

//FR - 13/11/2020
Local nDiasRetro := 0 
Local dDataPartir:= CtoD("  /  /    ") 
Private lEnergia  := .F.		//FR - 18/08/2020
Private cArqOri	  := Space(200)
Private xZBC  	  := GetNewPar("XM_TABCAC","ZBC")  //Colocar no HFXML01
Private xZBC_ 	  := iif(Substr(xZBC,1,1)=="S", Substr(xZBC,2,2), Substr(xZBC,1,3)) + "_"
Private aCabE	  := {}
Private aIteE     := {}
Private lCombustXML := .F. //aqui define que a classificação da NF Combustível é via XML e não por arquivo txt da TICKET, é só pelo XML

if ! cClAt $ "S"

	U_MyAviso("Aviso","Classificação Automática Não esta Ativa!" ,{"Ok"},3)
	Return( NIL )
	
endif
//FR - AQUI PRECISA ANTES VERIFICAR SE HÁ XMLs DE ENERGIA, SE HOUVER, EFETUA CLASSIFICAÇÃO AUTOMÁTICA E NEM MOSTRA TELA DE COMBUSTÍVEIS
//FR - 22/09/2020
cClatTipos := GetNewPar("XM_CLATPNF","N")

//----------------------------------------------------------------------------------------------------------------//
//Alteração:
//FR - 05/08/2022 - PROJETO POLITEC - CLASSIFICAÇÃO ROBÓTICA DE NFs COMBUSTÍVEIS (VIA XML APENAS)
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
	
If cClatTipos $ "E"			//Se definido que o tipo é Energia ou Todos
	lEnergia := .T. 

//FR - 05/08/2022 - PROJETO POLITEC CLASSIF NF COMBUSTIVEIS VIA XML
Elseif cClatTipos $ "C1"		//COMBUSTÍVEL C1 (NF combustível que não usa integração com TICKET, só lê o próprio XML )
	lCombustXML := .T.
//FR - 05/08/2022 - PROJETO POLITEC CLASSIF NF COMBUSTIVEIS VIA XML

Elseif cClatTipos $ "C/N"
	lEnergia := .F.
Endif

//KROMA
If lEnergia 
	If MsgYesNo("Confirma A Classificação Automática das Notas de Energia ?")
		oProcess := MsNewProcess():New( {|lEND| lEnergia := U_fVerXMLEnerg(@lTemPC,@aCabE,@aIteE,.F.,oProcess)  },"Aguarde. Verificando XMLs Energia...","Verificando XMLs Energia",.T.)
		oProcess:Activate()
	Else
		MsgInfo("Operação Cancelada Pelo Usuário")	
		Return(Nil)
	Endif

//POLITEC
Elseif lCombustXML
	
	If MsgYesNo("Confirma A Classificação Automática das Notas de Combustíveis via XML ?")
		oProcess := MsNewProcess():New( {|lEND| lCombustXML := U_fVerXMLComb(@aCabE,@aIteE,.F.,oProcess)  },"Aguarde. Verificando XMLs Combustível...","Verificando XMLs Combustível",.T.)
		oProcess:Activate()
	Else
		MsgInfo("Operação Cancelada Pelo Usuário")	
		Return(Nil)
	Endif


Endif
//FR - 25/09/2020

//KROMA
If lEnergia	
	If !Empty(aCabE) .and. !Empty(aIteE) 

		Processa( {|lEND| CLASFIS( .F., @lEnd,,,,lEnergia,aCabE,aIteE,lCombustXML ) },"Processando XML Energia...")	//CLASFIS( lShow, lEnd, lAuto, nRZbi, cSt,lEnergia,aCabE,aIteE,lCombustXML )        	 				
		MsgInfo("Processo Finalizado...")
	Else
		//FR - 16/11/2020
		nDiasRetro := GetNewPar("XM_KRDIASR" , 30)
		dDataPartir:= dDatabase - nDiasRetro 	
		MsgInfo("Classificação Não Realizada. Possíveis Motivos:" + CRLF+CRLF+;
		        "- Não Existe(m) Nota(s) a Ser(em) Classificada(s) a Partir de: " + DtoC(dDataPartir) + ". (Parâmetro: XM_KRDIASR)"+CRLF+CRLF+;
		        "- Não Existe(m) Pedido(s) de Compra." )
		//FR - 16/11/2020
	Endif
	U_HF13MAIL( "ENERGIA_", .F., "Ocorrencia de XML de ENERGIA",.T. )	

//POLITEC
//FR - 05/08/2022 - PROJETO POLITEC CLASSIF NF COMBUSTIVEIS VIA XML
Elseif lCombustXML

	If !Empty(aCabE) .and. !Empty(aIteE) 

		Processa( {|lEND| CLASFIS( .F., @lEnd,,,,lEnergia,aCabE,aIteE,lCombustXML ) },"Processando XML Combustível...")	//CLASFIS( lShow, lEnd, lAuto, nRZbi, cSt,lEnergia,aCabE,aIteE,lCombustXML )        	 				
		MsgInfo("Processo Finalizado...")		
	Endif
	
	U_HF13MAIL( "COMBUSTIVEIS_", .F., "Ocorrencia de XML de COMBUSTIVEIS",lEnergia,lCombustXML )	
//FR - 05/08/2022 - PROJETO POLITEC CLASSIF NF COMBUSTIVEIS VIA XML

//AGUAS DO BRASIL
Else

////////////////////////////
// - MONTA TELA INICIAL - //
///////////////////////////
@ 001,001 To 280,500 Dialog oSCR1 Title "Selecione Arquivo para Classificação"

@ 040,010 Say "Digite o caminho e nome do arquivo de origem:" Pixel
@ 055,010 MsGet cArqOri When .F. Size 227,010 Pixel

@ 055,240 Button "?" SIZE 005,012 PIXEL ACTION ABREARQ()

@ 090,160 Button "&Cancelar" Size 030,012 Pixel Action Close(oSCR1)
@ 090,207 Button "&Ok"       Size 030,012 Pixel Action (Close(oSCR1),Processa({|lEND| CLASFIS(.T.,@lEND)},"Aguarde..."))

Activate Dialog oSCR1 Centered

Endif
RestArea(aArea)

return( NIL )



Static Function AbreArq()

Local cTipo
Local cDir     := AllTrim(SuperGetMv("MV_X_PATHX"))
Local cDirFis  := ""
Local cDirCbs  := ""

cTipo	:= "Arquivo Texto (*.txt) | *.txt  | "                     // + GETF_NOCHANGEDIR
cTipo	+= "Todos Arquivos        | *.*    | "

cDir := StrTran(cDir,cBarra+cBarra,cBarra)
cDirFis := AllTrim(cDir+cBarra+"Fiscal"+cBarra)
cDirFis := StrTran(cDirFis,cBarra+cBarra,cBarra)
cDirCbs := AllTrim(cDirFis+cBarra+"configuracao"+cBarra)
cDirCbs := StrTran(cDirCbs,cBarra+cBarra,cBarra)

If !ExistDir(cDir)
	Makedir(cDir)
EndIf
If !ExistDir(cDirFis)
	Makedir(cDirFis)
EndIf
If !ExistDir(cDirCbs)
	Makedir(cDirCbs)
EndIf

cArqOri := UPPER(cGetFile(cTipo,"Selecione o arquivo para classificação(*.txt)",,cDirCbs,.T.,GETF_LOCALHARD,.F.)) //GETF_NETWORKDRIVE

Return()


User Function ClasDebug()

	If Type('cFilAnt') == 'U'

		RpcSetType(3)
		RpcSetEnv('99','01')

	Endif
	
	Default cTipo  := " "
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
	Private x_Ped_Rec := GetNewPar("XM_PEDREC","N")
	Private x_ZBB     := GetNewPar("XM_TABREC","")
	Private aHfCloud  := {"0","0"," ","Token",{}}  //CRAUMDE - '0' Não integrar, na posição 1
	Private x_Tip_Pre := GetNewPar("XM_TIP_PRE","1")
	Private nFormNfe  := Val(GetNewPar("XM_FORMNFE","9")) 
	Private nFormCte  := Val(GetNewPar("XM_FORMCTE","9"))
	Private cFilUsu   := GetNewPar("XM_FIL_USU","N")
	Private cTpRt  	  := "J"

	lAuto := .T.
	lEnd  := .F.

	cLogProc := ""
	nCount   := 0

	U_EMailNFE(lAuto,@lEnd,,@cLogProc,@nCount)
	U_Procxml(lAuto,@lEnd,,@cLogProc,@nCount)
	
	if GetNewPar( "XM_DFE", "0" ) == "2"
		U_HFXML16JB(lAuto,@lEnd,,@cLogProc,@nCount,.F.)
	else
		//U_HFXML6JB(lAuto,@lEnd,,@cLogProc,@nCount,.F.)	
	endif 

	U_HFXML06R(lAuto,@lEnd,,@cLogProc,@nCount,.F.)  //Download dos xml´s resumidos
	U_HFXML062(lAuto,@lEnd,,@cLogProc,@nCount,.F.)  //Manifestar os pendentes de manifestação
	U_HFXML61J(lAuto,@lEnd,,@cLogProc,@nCount,.F.)  //Ver se Tem Com erros primeiro
	
Return 

//FR - 18/08/2020 - A função abaixo é chamada no fonte HF_WF_XML2, Job tipo = "B", classificação de notas de combustíveis e agora também de energia
//FR - 05/08/2022 - A função abaixo também será utilizada para classificação de NFs combustíveis Ex.: Politec 
//que é direto pelo XML, não faz integração com arquivo Ticket (txt) não, tá ok, direto pelo XML só
//qualquer cliente que for utilizar classificação robótica direto por XML pode se beneficiar desta função
User Function HFCLAJOB(lAuto,lEnd,oProcess,cLogProc,nCount)

Local lRet := .T.
Local cDir    := AllTrim(SuperGetMv("MV_X_PATHX"))
Local cDirFis := ""
Local cDirCbs := ""
Local cWhere
Local cTabela
Local cCampos
Local cOrder
Local cAliasZBI
Local lEnergia := .F.				//FR - 18/08/2020
Local lTemPC   := .F.				//FR - 18/08/2020
Local cClatTipos:= ""				//FR - 05/10/2020
Local lCombustXML := .F.			//FR - 05/08/2022

Private cArqOri	:= Space(200)
Private aCabE   := {} 				//FR - 18/08/2020
Private aIteE   := {}       		//FR - 18/08/2020

Default oProcess := Nil				//FR - 30/09/2020
//FR - 18/08/2020 - Checar antes se há notas de energia, caso haja, não fará a parte da classificação de combustíveis
//Segundo Rafael, será praticamente impossível uma empresa utilizar as duas situações
cClatTipos := GetNewPar("XM_CLATPNF","N")

If cClatTipos $ "E/T"		//Se definido que o tipo é Energia ou Todos
	lEnergia := .T. 
Elseif cClatTipos $ "C/N"
	lEnergia := .F.
Elseif cClatTipos $ "C1"		//COMBUSTÍVEL C1 (NF combustível que não usa integração com TICKET, só lê o próprio XML )
	lCombustXML := .T.
Endif

If lEnergia 
	lEnergia := U_fVerXMLEnerg( , , ,.T.,oProcess)  //U_fVerXMLEnerg(aCab,aIte,lSoCheck)
Endif

If !lEnergia .AND. !lCombustXML  //se a nota é de combustíveis (integração TICKET AGUAS BR) faz a integração via arquivo baixado do FTP o qual gravou as informações na tabela ZBI

	cDir := StrTran(cDir,cBarra+cBarra,cBarra)
	cDirFis := AllTrim(cDir+cBarra+"Fiscal"+cBarra)
	cDirFis := StrTran(cDirFis,cBarra+cBarra,cBarra)
	cDirCbs := AllTrim(cDirFis+cBarra+"configuracao"+cBarra)
	cDirCbs := StrTran(cDirCbs,cBarra+cBarra,cBarra)
	
	cAliasZBI := GetNextAlias()
	
	cTabela:= "%"+RetSqlName(xZBI)+"%"
	cWhere := "%(ZBI."+xZBI_+"ST IN ('0','1') )%"
	//cWhere += ""
	cCampos	:= "%"+xZBI_+"FILIAL, "
	cCampos	+= xZBI_+"FTP,"+xZBI_+"ARQ, "+xZBI_+"DIR, "
	cCampos	+= xZBI_+"DTARQ, "+xZBI_+"DTCLAS, "+xZBI_+"ST, ZBI.R_E_C_N_O_ AS REG "
	cCampos	+=	"%"
	cOrder := "%"+xZBI_+"FILIAL,"+xZBI_+"ST,"+xZBI_+"DTARQ%"
	CONOUT("<GESTAOXML> MONTANDO QUERY ==> ZBI <== ...")    
	BeginSql Alias cAliasZBI
	
		SELECT %Exp:cCampos%
				FROM %Exp:cTabela% ZBI
				WHERE ZBI.%notdel%
			 	AND %Exp:cWhere%
				ORDER BY %Exp:cOrder%
		EndSql

	DbSelectArea(cAliasZBI)
	Dbgotop()
	Do While ! (cAliasZBI)->( Eof() )
	
		CONOUT("<GESTAOXML> QUERY ZBI ===> OK PARA CLASSIFICAR")
		DbSelectArea( xZBI )
		DbGoTo( (cAliasZBI)->REG )
		
		if ! Empty( (xZBI)->(FieldGet(FieldPos(xZBI_+"DIR"))) )
			cArqOri := AllTrim( (xZBI)->(FieldGet(FieldPos(xZBI_+"DIR"))) ) + AllTrim( (xZBI)->(FieldGet(FieldPos(xZBI_+"ARQ"))) )
		else
			cArqOri := cDirCbs + AllTrim( (xZBI)->(FieldGet(FieldPos(xZBI_+"ARQ"))) )
		endif
		
		If File(cArqOri)
		
			CONOUT("<GESTAOXML> A CLASSIFICAR ==> " + cArqOri + " <==")
			
			CLASFIS( .F., lEnd, lAuto, (cAliasZBI)->REG, (xZBI)->(FieldGet(FieldPos(xZBI_+"ST"))) )
			
			CONOUT("<GESTAOXML> ===> EXECUTANDO ROTINA CLASFIS")
			nCount++
			
		EndIf
		
		DbSelectArea( cAliasZBI )
		(cAliasZBI)->( dbSkip() )
		
	EndDo

ElseIF lEnergia
    //Monta o array de notas de energia, passando por parâmetro as variáveis aCabE e aIteE:
    lEnergia := U_fVerXMLEnerg(@lTemPC,@aCabE,@aIteE,.F.)
   	
	//CLASFIS( .F., lEnd, lAuto, (cAliasZBI)->REG, (xZBI)->(FieldGet(FieldPos(xZBI_+"ST"))) )
	CLASFIS( .F. , @lEnd, , , ,lEnergia,aCabE,aIteE,lCombustXML )
	
	If !lTemPC        		//FR - 18/08/2020 - indica que houve inconsistência, então envia email
    	U_HF13MAIL( "ENERGIA_", .F., "Ocorrencia de XML de Energia",.T. )	
    Endif

Elseif lCombustXML

	//Monta o array de notas de XML Combustível (Politec), passando por parâmetro as variáveis aCabE e aIteE:
	lCombustXML := U_fVerXMLComb(@aCabE,@aIteE,.F.,oProcess)
	
	//depois de preparar o array, chama a função que processa a classificação dos XMLs (aCabE,aIteE)
	CLASFIS( .F. , @lEnd, , , ,lEnergia,aCabE,aIteE,lCombustXML )  
	
	U_HF13MAIL( "COMBUSTIVEIS_", .F., "Ocorrencia de XML de COMBUSTIVEIS",lEnergia,lCombustXML )	


Endif //lEnergia
Return( lRet )



Static Function CLASFIS( lShow, lEnd, lAuto, nRZbi, cSt,lEnergia,aCabE,aIteE,lCombustXML )     //CLASFIS( lShow, lEnd, lAuto, nRZbi, cSt,lEnergia,aCabE,aIteE )  //FR - 18/08/2020

Local lTem := .F.
Local oProcess
Local nVersao := Val(GetVersao(.F.))     // Indica a versao do Protheus
Local cDrive,cPath,cExt
Default lAuto := .F.
Default nRZbi := 0
Default cSt   := "0"

Private cArqTxt  := ""
Private cStZbi   := cSt
Private cTmp_ZBZ := "TMPZBZ", cAli_ZBZ, oTmp_ZBZ
Private aEmpFils := U_XGetEmpF() //aqui

//FR - 05/08/2022 - PROJETO POLITEC CLASSIF NF COMBUSTIVEIS VIA XML
Default lEnergia    := .F.
Default lCombustXML := .F.         
//FR - 05/08/2022 - PROJETO POLITEC CLASSIF NF COMBUSTIVEIS VIA XML
//FR - 18/08/2020
If lEnergia

	CriaTMP()
	cAli_ZBZ := oTmp_ZBZ:GetAlias()
	
	lTem := PROCREGS( lEnd, oProcess, .F., "99", .T., lEnergia, aCabE, aIteE, lCombustXML )  //PROCREGS( lEnd, oRegua, lShow, cNil, lAuto,lEnergia, aCabE, aIteE )
			
	If lTem
		Classifica(.F., NIL,lEnergia,lCombustXML )
	Endif
	
	If nVersao >= 12		
		oTmp_ZBZ:Delete()			
	Else		
		(cAli_ZBZ)->( dbCloseArea() )			
	Endif
//-----------------------------------------------------------------------------//
//monta markbrowse das notas caso seja acionada a opção de dentro do Protheus
//FR - 05/08/2022 - PROJETO POLITEC CLASSIF NF COMBUSTIVEIS VIA XML
//-----------------------------------------------------------------------------//
Elseif lCombustXML 

	CriaTMP()
	cAli_ZBZ := oTmp_ZBZ:GetAlias() 
	
	If !IsBlind()
		oProcess := MsNewProcess():New({| lEnd | lTem := PROCREGS( lEnd, oProcess, .F., "99", .T., lEnergia, aCabE, aIteE, lCombustXML ) },"Aguarde. Verificando XMLs...","Verificando XMLs",.T.)
		oProcess:Activate() 
	
	
		//MarkBrowse
		HFXML131Bw(lEnergia,lCombustXml)   
	Else 
		lTem := PROCREGS( lEnd, oProcess, .F., "99", .T., lEnergia, aCabE, aIteE, lCombustXML )  
		
		If lTem							
			Classifica(.F., NIL,lEnergia,lCombustXML )					
		Endif 
		
	Endif 
	
	If nVersao >= 12		
		oTmp_ZBZ:Delete()			
	Else		
		(cAli_ZBZ)->( dbCloseArea() )			
	Endif

Else
//FR - 18/08/2020
	If Len(Alltrim(cArqOri)) > 0
	
		SplitPath(AllTrim(cArqOri),@cDrive,@cPath,@cArqTxt,@cExt)
	
		If nVersao >= 12
		
			CriaTMP()
			cAli_ZBZ := oTmp_ZBZ:GetAlias()
			
		Else
		
			cAli_ZBZ := CriaTMP()
			
		Endif
	
		If .NOT. lShow
		
			lTem := PROCREGS( lEnd, oProcess, .F., "99", lAuto )
			
			If ltem
			
				Classifica(.F., NIL )
				
			Endif
			
		Else
		
			oProcess := MsNewProcess():New({| lEnd | lTem := PROCREGS( @lEnd, oProcess, .T., "99", .F.)},"Aguarde. Verificando XMLs...","Verificando XMLs",.T.)
			oProcess:Activate()
	
			//MarkBrowse
			HFXML131Bw()
			
		Endif
		
		U_HFATUZBI(nRZbi, cArqTxt+"."+cExt )
	
		If nVersao >= 12
		
			oTmp_ZBZ:Delete()
			
		Else
		
			(cAli_ZBZ)->( dbCloseArea() )
			
		Endif
	
	Else
	
		If ! lAuto
		
			MsgAlert("Arquivo nao informado.","Atenção... HFXML131")
			
		Endif
		
	EndIf

Endif //lEnergia
Return()


Static Function CriaTMP()

Local aStru := {}
Local aInd  := {}
Local nVersao     := Val(GetVersao(.F.))     // Indica a versao do Protheus
Local cArq
//FR - 05/10/2020
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
//FR - 05/10/2020

aadd( aStru, { "OK"      ,"C",02,0 } )
aadd( aStru, { "ST"      ,"C",01,0 } )
aadd( aStru, { "NOTA"    ,"C",len( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA"))) )  ,0 } )
aadd( aStru, { "SERIE"   ,"C",len( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE"))) ) ,0 } )
aadd( aStru, { "DTNFE"   ,"D",08,0 } )
aadd( aStru, { "PRENF"   ,"C",len( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF"))) ) ,0 } )
aadd( aStru, { "CNPJ"    ,"C",len( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))) )  ,0 } )
aadd( aStru, { "FORNEC"  ,"C",len( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FORNEC"))) ),0 } )
aadd( aStru, { "CHAVE"   ,"C",len( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))) ) ,0 } )
aadd( aStru, { "TPDOC"   ,"C",len( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC"))) ) ,0 } )
aadd( aStru, { "CODFOR"  ,"C",len( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR"))) ),0 } )
aadd( aStru, { "LOJFOR"  ,"C",len( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR"))) ),0 } )
aadd( aStru, { "XMLNFE"  ,"M",10,0 } )
aadd( aStru, { "CNPJD"   ,"C",len( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJD"))) ) ,0 } )
aadd( aStru, { "M0COD"   ,"C",len( SM0->M0_CODIGO ) ,0 } )
aadd( aStru, { "M0FIL"   ,"C",len( SM0->M0_CODFIL ) ,0 } )
aadd( aStru, { "REG"     ,"N",15,0 } )
aadd( aStru, { "CONDPG"  ,"C",Len( SE4->E4_CODIGO ) ,0 } )    		//FR - 18/08/2020 - Kroma Energia
aadd( aStru, { "PEDCOM"  ,"C",Len( SC7->C7_NUM    ) ,0 } )    		//FR - 30/09/2020 - Kroma Energia
aadd( aStru, { "ITEMPC"  ,"C",Len( SC7->C7_ITEM   ) ,0 } )    		//FR - 30/09/2020 - Kroma Energia


if nVersao >= 12

	If !lCombustXML
		oTmp_ZBZ := FWTemporaryTable():New( cTmp_ZBZ, aStru ) //-> Objeto FWTemporaryTable 
		
			aInd := {}
			aadd( aInd, "CHAVE" )
			
		oTmp_ZBZ:AddIndex( cTmp_ZBZ+"01", aInd )
		
			aInd := {}
			aadd( aInd, "SERIE" )
			aadd( aInd, "NOTA" )
			
		oTmp_ZBZ:AddIndex( cTmp_ZBZ+"02", aInd )
		oTmp_ZBZ:Create()
	
	//FR - 16/08/2022 - ordenação solicitada pela POLITEC
	Elseif lCombustXML
		oTmp_ZBZ := FWTemporaryTable():New( cTmp_ZBZ, aStru ) //-> Objeto FWTemporaryTable 
	
		aInd := {}
		aadd( aInd, "CODFOR" )
		aadd( aInd, "LOJFOR" )
			
		oTmp_ZBZ:AddIndex( cTmp_ZBZ+"01", aInd )		
		oTmp_ZBZ:Create() 
		
	Endif 
	
Else

	cArq := CriaTrab( aStru, .T. )
	
	dbUseArea(.T.,, cArq,cTmp_ZBZ, .T., .F.) //compartilhado
	IndRegua(cTmp_ZBZ,cArq+"01","CHAVE" ) 
	IndRegua(cTmp_ZBZ,cArq+"02","SERIE+NOTA" )
	
	dbClearIndex()
	
	dbSetIndex( cArq+"01" + OrdBagExt() )//ordem 1
	dbSetIndex( cArq+"02" + OrdBagExt() )//ordem 2
	dbSetOrder( 1 )
	
EndIf

Return(cTmp_ZBZ)

//------------------------------------------------------------------------------------------------//
//FUNÇÃO  : PROCREGS
//OBJETIVO: PEGA A CHAVE DO XML que está na posição aCab[nX][17] e valida o XML                     
//------------------------------------------------------------------------------------------------//
Static Function PROCREGS( lEnd, oRegua, lShow, cNil, lAuto,lEnergia,aCabE,aIteE,lCombustXML )   //FR - 18/08/2020

Local lRet   := .T.
Local aCab   := {}
Local aIte   := {}
Local cChave := ""
Local cCnpjD := ""
Local nPosCn := 0
Local aXEmpF := {}
Local nX     := 1
Local lBrabo := .F.
Local aMsgErr:= {}		//FR - 16/08/2020
Local cMsgErr:= ""		//FR - 16/08/2020
Local fr     := 0		//FR - 28/10/2021

Default lCombustXML := .F.  //FR - 05/08/2022 - PROJETO POLITEC CLASSIF NF COMBUSTIVEIS VIA XML
Default lEnergia    := .F.

If lShow

	//ProcRegua(Len(aCab))
	oRegua:SetRegua1(0)
	oRegua:SetRegua2(0)
	
Endif

//FR - 18/08/2020
If lEnergia .or. lCombustXML		//FR - 05/08/2022 - PROJETO POLITEC CLASSIF NF COMBUSTIVEIS VIA XML / KROMA CLASSIFICAÇÃO NFs ENERGIA
	aCab := aCabE
	aIte := aIteE	
Else
	MontaNota( @aCab, @aIte )
Endif
//FR - 18/08/2020

If lShow

	//ProcRegua(Len(aCab))
	oRegua:SetRegua1( Len(aCab) )
	oRegua:SetRegua2(0)
	
Endif

//if  !lAuto  //Fadiga Braba essa.  //Len( aCab ) > 50 .and.
If lShow


	If .NOT. MsgYesNo("O Arquivo Selecionado Possui: "+AllTrim(Str(Len( aCab )))+" Chave(s), Prossegue [Sim] ou [Não] ?","Pergunta")
		
		Return( lRet )
		

		
	Endif

	
Endif

For nX := 1 To Len( aCab )   //FR - 02/07/2020 - array cabeçalho de todas as notas do arquivo TXT

//	nFalta := (Len( aCab ) - nX)-1
//	if nFalta > TST_MAXTHREAD
//		nFalta := TST_MAXTHREAD
//	endif
//
//	For nY := 1 To nFalta
		if lShow
		
			//IncProc("Processando "+iif( Len(aCab[nX]) >= 17, aCab[nX][17], "") )
			
			If lEnd
			
				MsgStop("*** Cancelado pelo Operador ***","Fim")
				lRet := .F.
				Exit
				
			EndIf 
			
			oRegua:IncRegua1("Processando Arquivo...")
			oRegua:IncRegua2( iif( Len(aCab[nX]) >= 17, aCab[nX][17], "") )
			
		endif
	
		aXEmpF := {}
		
		cChave := aCab[nX][17]
		cCnpjD := aCab[nX][16]
		nPosCn := aScan( aEmpFils, {|x| x[4] == cCnpjD } )
		
		if nPosCn > 0
		
			//aadd( aXEmpF, { iif(aEmpFils[nPosCn][1], 1, 2), aEmpFils[nPosCn][2], aEmpFils[nPosCn][3], cCnpjD } ) 
			aadd( aXEmpF, iif(aEmpFils[nPosCn][1], 1, 2) )  //1 - Lic, 2 - Sem Lic
			aadd( aXEmpF, aEmpFils[nPosCn][2] )  //Empresa
			aadd( aXEmpF, aEmpFils[nPosCn][3] )  //Filial
			aadd( aXEmpF, cCnpjD  )              //Cnpj
			
		else
		
			//aadd( aXEmpF, { 0, cEmpAnt, cFilAnt, cCnpjD } )  //Não Tem, mas para mostrar o erro e entrar na Audit
			aadd( aXEmpF, 0 )
			aadd( aXEmpF, cEmpAnt )
			aadd( aXEmpF, cFilAnt )
			aadd( aXEmpF, cCnpjD  )
			
		endif
	
	//FR - 16/08/2020
	cMsgErr := ValidChv(aXEmpF,cChave,aCab,aIte,nX,lAuto,lBrabo,lEnergia,lCombustXML)
	If !Empty(cMsgErr)
		Aadd(aMsgErr , cMsgErr)
	Endif
	cMsgErr := ""
//	Next nY
//	If lEnd
//		Exit
//	EndIf 

Next nX

if lBrabo

	//FechaTread( "D" )
	
endif


/*if .F.  //Fadiga Nervosa essa

	DbSelectArea( cTmp_ZBZ )
	(cTmp_ZBZ)->( dbGoTop() )
	
	Do While ! (cTmp_ZBZ)->( Eof() )
	
		if lShow
		
			If lEnd
			
				MsgStop("*** Cancelado pelo Operador ***","Fim")
				lRet := .F.
				Exit
				
			EndIf 
			
			oRegua:IncRegua1("Atualizando Status Chaves...")
			oRegua:IncRegua2( (cTmp_ZBZ)->CHAVE )
			
		endif

		aZbz := {}
		
		For nI := 1 To (cTmp_ZBZ)->(FCount())
		
			aadd( aZbz, { (cTmp_ZBZ)->( FieldName( nI ) ), (cTmp_ZBZ)->(FieldGet( nI ) ) } )
	
		Next nI

		cChave := AllTrim( (cTmp_ZBZ)->CHAVE )
		
		DbSelectArea( xZBZ )
		dbSetORder( 3 )
		
		If (xZBZ)->( dbSeek( cChave ) )
		
			cPrNf := U_HFSTXMUN( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))),;
			               (xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA"))),;
			               (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE"))),;
			               (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR")))+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR"))) ,;
			               (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC"))),;
			               (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO"))),;
			               (xZBZ)->(FieldGet(FieldPos(xZBZ_+"DOCCTE"))),;
			               (xZBZ)->(Recno()),.T. )
			               
			nPos := aScan( aZbz, { |x| x[1] = "ST" } )
			
			if nPos > 0
			
				aZbz[nPos][2] := iif( cPrNf = "N", "2", iif( cPrNf = "S", "1", " ") )  //Branco e 1 porque pode pedir a classificação
			
			Endif
			
			nPos := aScan( aZbz, { |x| x[1] = "NOTA" } )
			
			if nPos > 0
			
				aZbz[nPos][2] := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA")))
				
			endif
			
			nPos := aScan( aZbz, { |x| x[1] = "SERIE" } )
			
			if nPos > 0
			
				aZbz[nPos][2] := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE")))
				
			endif
			
			nPos := aScan( aZbz, { |x| x[1] = "DTNFE" } )
			
			if nPos > 0
			
				aZbz[nPos][2] := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"DTNFE")))
				
			endif
			
			nPos := aScan( aZbz, { |x| x[1] = "PRENF" } )
			
			if nPos > 0
			
				aZbz[nPos][2] := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF")))
				
			endif
			
			nPos := aScan( aZbz, { |x| x[1] = "CNPJ" } )
			
			if nPos > 0
			
				aZbz[nPos][2] := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ")))
				
			endif
			
			nPos := aScan( aZbz, { |x| x[1] = "FORNEC" } )
			
			if nPos > 0
			
				aZbz[nPos][2] := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FORNEC")))
				
			endif
			
			nPos := aScan( aZbz, { |x| x[1] = "CHAVE" } )
			
			if nPos > 0
			
				aZbz[nPos][2] := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE")))
				
			endif
			
			nPos := aScan( aZbz, { |x| x[1] = "TPDOC" } )
			
			if nPos > 0
			
				aZbz[nPos][2] := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC")))
				
			endif
			
			nPos := aScan( aZbz, { |x| x[1] = "CODFOR" } )
			
			if nPos > 0
			
				aZbz[nPos][2] := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR")))
				
			endif
			
			nPos := aScan( aZbz, { |x| x[1] = "LOJFOR" } )
			
			if nPos > 0
			
				aZbz[nPos][2] := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR")))
				
			endif
			
			nPos := aScan( aZbz, { |x| x[1] = "XMLNFE" } )
			
			if nPos > 0
			
				aZbz[nPos][2] := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML")))
				
			endif
			
			nPos := aScan( aZbz, { |x| x[1] = "CNPJD" } )
			
			if nPos > 0
			
				aZbz[nPos][2] := cCnpjD
				
			Endif
			
			nPos := aScan( aZbz, { |x| x[1] = "M0COD" } )
			
			if nPos > 0
			
//				aZbz[nPos][2] := aXEmpF[2]

			endif
			
			nPos := aScan( aZbz, { |x| x[1] = "M0FIL" } )
			
			if nPos > 0
			
//				aZbz[nPos][2] := aXEmpF[3]

			endif
			
			nPos := aScan( aZbz, { |x| x[1] = "REG" } )
			
			if nPos > 0
			
				aZbz[nPos][2] := (xZBZ)->( Recno() )
				
			endif
			
			If Empty( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"COMBUS"))) ) //Ver o que fazer no futuro para ficar generico
				
				dbSelectArea( xZBZ )
				RecLock( xZBZ, .F. )
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"COMBUS"), "S" ))
				(xZBZ)->( MsUnlock() )
				
			Endif

			DbSelectArea( cTmp_ZBZ )
			RecLock( cTmp_ZBZ, .F. )
			
			For nI := 1 To Len(aZbz)
			
				(cTmp_ZBZ)->(FieldPut(FieldPos(aZbz[nI][1]), aZbz[nI][2] ))
				
			Next nI
			
			if lAuto
			
				(cTmp_ZBZ)->(FieldPut(FieldPos("OK"), cMarcaOK ))  //cmarca, cMarcaOK
				
			endif
			
			(cTmp_ZBZ)->( MsUnLock() )

		Endif

		DbSelectArea( cTmp_ZBZ )
		(cTmp_ZBZ)->( dbSkip() )
		
	EndDo
	
endif*/

//-----------------------------------------//
//FR - 16/08/2020 - Mostrar aviso ao final
//-----------------------------------------//
fr      := 0
cMsgErr := ""

If !IsBlind()

	If Len(aMsgErr) > 0
	
		For fr := 1 to Len(aMsgErr)
		
			cMsgErr += aMsgErr[fr] + CRLF
			
		Next
		U_MyAviso("DownLoad Não Realizado",cMsgErr ,{"Ok"},3)
	Endif
	
Else
	If !lEnergia .and. !lCombustXML		//FR 03/11/2020 - solicitado por Aguas Br enviar email ao final do download de xml na classificação de nf
		U_HF13MAIL( cArqTxt, .F., "Ocorrencia de DownLoad XML", lEnergia )	//HF13MAIL( cArq, lTod, cTitulo,lEnergia ) 	//FR 03/11/2020
	Endif
Endif
//FR - 16/08/2020
DelClassIntf() //-> Exclui todas classes de interface da thread

Return( lRet )



Static Function MontaNota( aCab, aIte )

Local nHandle := 0
Local cChave  := ""
Local aLin[19]
Local aDet[15]

nHandle := fOpen(cArqOri ,48)  //0

If nHandle = -1
	Return( .F. )
EndIf

fSeek(nHandle,0,FS_SET)

Do While .T.

	cBuf := U_HFLerLin(nHandle)[1]  //aLinha[1]  //HFXML10
	
	if Empty( cBuf )  //FT_FEOF()
	
		Exit
		
	Endif

	If Substr(cBuf,1,3) = "000"
	
		cChave := Substr(cBuf,272,44)

		aLin[01] := Substr(cBuf,004,073) //Razao
		aLin[02] := Substr(cBuf,074,103) //Enderco
		aLin[03] := Substr(cBuf,104,005) //numero
		aLin[04] := Substr(cBuf,109,035) //Bairro
		aLin[05] := Substr(cBuf,144,035) //Mun
		aLin[06] := Substr(cBuf,179,010) //CEP
		aLin[07] := Substr(cBuf,189,002) //UF
		aLin[08] := Substr(cBuf,191,014) //CNPJ_CPF
		aLin[09] := Substr(cBuf,205,002) //BR
		aLin[10] := Substr(cBuf,207,020) //Inscricao_Estadu
		aLin[11] := Substr(cBuf,227,009) //Num_NF
		aLin[12] := Substr(cBuf,236,003) //Serie
		aLin[13] := Substr(cBuf,239,003) //SubSerie
		aLin[14] := Substr(cBuf,242,008) //Dt_Lancamento
		aLin[15] := Substr(cBuf,250,008) //Dt_Emissao
		aLin[16] := Substr(cBuf,258,014) //CNPJ_Destino
		aLin[17] := Substr(cBuf,272,044) //Chave
		aLin[18] := Substr(cBuf,316,015) //Valor Total Nota  FAZER O VAL
		aLin[19] := Substr(cBuf,331,015) //Valor Total Nota  FAZER O VAL

		aadd( aCab, aClone(aLin) )

	Else

		aDet[01] := cChave
		aDet[02] := Substr(cBuf,001,007) //Id_Item
		aDet[03] := Substr(cBuf,008,020) //Cod_Produto
		aDet[04] := Substr(cBuf,028,040) //Descricao_Nota
		aDet[05] := Substr(cBuf,068,013) //Quantidade 13,4 FAZER O VAL
		aDet[06] := Substr(cBuf,081,003) //Unidade de medida
		aDet[07] := Substr(cBuf,084,015) //Vlr_Unitario FAZER O VAL
		aDet[08] := Substr(cBuf,099,010) //CFOP
		aDet[09] := Substr(cBuf,109,015) //Base_Calculo_ICMS  FAZER O VAL
		aDet[10] := Substr(cBuf,124,008) //Aliquota_ICMS  FAZER O VAL
		aDet[11] := Substr(cBuf,132,015) //Vlr_Imposto_ICMS  FAZER O VAL
		aDet[12] := Substr(cBuf,147,015) //Base_Calculo_IPI  FAZER O VAL
		aDet[13] := Substr(cBuf,162,008) //Aliquota_IPI  FAZER O VAL
		aDet[14] := Substr(cBuf,170,015) //Vlr_Imposto_IPI  FAZER O VAL
		aDet[15] := Substr(cBuf,185,015) //Vlr_Desconto  FAZER O VAL

		aadd( aIte, aClone(aDet) )
		
	Endif

EndDo

fClose(nHandle)

Return( NIL )


Static Function ValidChv(aXEmpF,cChave,aCab,aIte,nX,lAuto,lBrabo,lEnergia,lCombustXML) 		//FR - 18/08/2020

Local cRet 			:= ""
Local aZbz 			:= {}
Local aRet 			:= {}
Local aArea 		:= GetArea()
Local nI    		:= 0
Local cMsg	 		:= ""		//FR - 16/08/2020
Local nNota			:= 0		//FR - 30/09/2020
Private cIdEnt 		:= U_GetIdEnt()
Private cMarcaOK	:= GetMark()

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

Default lEnergia    := .F.	//FR - 30/09/2020 
Default lCombustXML := .F.  //FR - 05/08/2022 - PROJETO POLITEC - CLASSIFICAÇÃO ROBÓTICA DE NFs COMBUSTÍVEIS (VIA XML APENAS)

If .NOT. lBrabo

	For nI := 1 To (cTmp_ZBZ)->(FCount())
	
		aadd( aZbz, { (cTmp_ZBZ)->( FieldName( nI ) ), (cTmp_ZBZ)->(FieldGet( nI ) ) } )
	
	Next nI

	If ( aXEmpF[2] == cEmpAnt .And. alltrim( aXEmpF[3] ) == cFilAnt )
	
		aRet := U_HFzCHKCV( aCab, nX, aIte, cRet, aZbz, aXEmpF[2], aXEmpF[3],lEnergia,lCombustXML)
	
	Else
	
		aRet := StartJob("U_XML131CH",GetEnvServer(),.T., aXEmpF[1], aXEmpF[2], aXEmpF[3], aCab, nX, aIte, @cRet, @aZbz, cArqTxt, cTpRt, lEnergia  )
		//aRet := U_XML131CH( aXEmpF[1], aXEmpF[2], aXEmpF[3], aCab, nX, aIte, @cRet, @aZbz, cArqTxt, cTpRt  )
	
	EndIf
	
	if ValType( aRet ) = "A"
	
		cRet 	:= aRet[1]
		aZbz 	:= aRet[2]
		cMsg    := aRet[3]
		
	Else
	
		cRet := "[F][ ][CLAS_AUT] Erro"
		
	Endif
	
Else

	StartJob("U_XML131CH",GetEnvServer(),.F., aXEmpF[1], aXEmpF[2], aXEmpF[3], aCab, nX, aIte, @cRet, @aZbz, cArqTxt, cTpRt, lEnergia  )
	cRet := "[F][ ][CLAS_AUT] StartJob"

Endif

if Substr(cRet,1,3) = "[F]"  //Problema com Conexão

	if ! lAuto .And. Substr(cRet,4,3) = "[0]"
	
		U_MyAviso("Erro",Substr(cRet,7,len(cRet)) ,{"Ok"},3)
		
	Else
		nNota := 0
	
		DbSelectArea( cTmp_ZBZ )
		RecLock( cTmp_ZBZ, .T. )
		
		(cTmp_ZBZ)->ST     := "9"  //Não Encontrado na ZBZ Vai Para Auditoria
		(cTmp_ZBZ)->NOTA   := aCab[nX][11]
		(cTmp_ZBZ)->SERIE  := aCab[nX][12]
		(cTmp_ZBZ)->CNPJ   := aCab[nX][08]
		(cTmp_ZBZ)->FORNEC := aCab[nX][01]
		(cTmp_ZBZ)->CHAVE  := cChave
		(cTmp_ZBZ)->M0COD  := aXEmpF[2]
		(cTmp_ZBZ)->M0FIL  := aXEmpF[3]
		(cTmp_ZBZ)->REG    := 0
		If lEnergia
			(cTmp_ZBZ)->CONDPG := aCab[nX][20]
			nNota := Ascan( aIte, {|x| x[18] == aCab[nX,11] } )
			If nNota > 0
				(cTmp_ZBZ)->PEDCOM := aIte[nNota,16]
				(cTmp_ZBZ)->ITEMPC := aIte[nNota,17]
			Endif
		Else
			(cTmp_ZBZ)->CONDPG := ""
			(cTmp_ZBZ)->PEDCOM := ""
			(cTmp_ZBZ)->ITEMPC := ""
		Endif
		(cTmp_ZBZ)->( MsUnLock() )
		
	Endif

Else

	DbSelectArea( cTmp_ZBZ )
	RecLock( cTmp_ZBZ, .T. )
	nNota := 0

	If lEnergia

		For nI := 1 To Len(aZbz)
	
			If Alltrim(aZbz[nI][1]) == "CONDPG"
				(cTmp_ZBZ)->(FieldPut(FieldPos(aZbz[nI][1]), aCab[nX][20] ))			
			ElseIf Alltrim(aZbz[nI][1]) == "PEDCOM"
				nNota := Ascan( aIte, {|x| x[18] == aCab[nX,11] } )
				If nNota > 0
					(cTmp_ZBZ)->(FieldPut(FieldPos(aZbz[nI][1]), aIte[nNota,16] ))
				Else
					(cTmp_ZBZ)->(FieldPut(FieldPos(aZbz[nI][1]), "" ))				
				Endif
			Elseif Alltrim(aZbz[nI][1]) == "ITEMPC"
				nNota := Ascan( aIte, {|x| x[18] == aCab[nX,11] } )
				If nNota > 0
					(cTmp_ZBZ)->(FieldPut(FieldPos(aZbz[nI][1]), aIte[nNota,17] )) //(cTmp_ZBZ)->ITEMPC := aIte[17]
				Else
					(cTmp_ZBZ)->(FieldPut(FieldPos(aZbz[nI][1]), "" ))				
				Endif
			Else
				(cTmp_ZBZ)->(FieldPut(FieldPos(aZbz[nI][1]), aZbz[nI][2] )) 
			Endif
			
		Next nI

	Else
		For nI := 1 To Len(aZbz)

			If Alltrim(aZbz[nI][1]) == "CONDPG"
				If lCombustXml 					
					(cTmp_ZBZ)->(FieldPut(FieldPos(aZbz[nI][1]), aCab[nX][20] ))  								
				Else
					(cTmp_ZBZ)->(FieldPut(FieldPos(aZbz[nI][1]), "" ))
				Endif
			ElseIf Alltrim(aZbz[nI][1]) == "PEDCOM"
				(cTmp_ZBZ)->(FieldPut(FieldPos(aZbz[nI][1]), "" ))				
			Elseif Alltrim(aZbz[nI][1]) == "ITEMPC"
				(cTmp_ZBZ)->(FieldPut(FieldPos(aZbz[nI][1]), "" ))				
			Else
				(cTmp_ZBZ)->(FieldPut(FieldPos(aZbz[nI][1]), aZbz[nI][2] )) 
			Endif

		Next nI

	Endif
	
	if lAuto
	
		(cTmp_ZBZ)->(FieldPut(FieldPos("OK"), cMarcaOK ))  //cmarca, cMarcaOK
		
	endif
	
	(cTmp_ZBZ)->( MsUnLock() )
	dbSelectArea(xZBZ)

Endif

DelClassIntf() //-> Exclui todas classes de interface da thread

RestArea( aArea )

//Return( lRet )
Return(cMsg)


User Function TEST13()  //U_TEST13()

Local aCab := {}
Local aIte := {}
Local nX := 4
Local cRet := ""
Local aZbz := {}

Private cArqOri := "C:\AP12\Protheus\Protheus_Data_TST_02\xmlsource\Fiscal\configuracao\2018_07_13_1655.TXT"

MontaNota( @aCab, @aIte )

aRet := U_XML131CH( 0, "99", "01", aCab, nX, aIte, @cRet, @aZbz, "2018_07_13_1655.TXT", "M" )

Alert( "Opa" )


Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³U_XML131CHº Autor ³ Eneovaldo Roveri Jrº Data ³  18/10/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ alimentar TMP se Existir na ZBZ e (Tentar donwnload se não)º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function XML131CH( xLic, xEmp, xFil, aCab, nX, aIte, cRet, aZbz, cArq, cTpr, lEnergia, lCombustXML  )
                  //aXEmpF[1], aXEmpF[2], aXEmpF[3], aCab, aIte, cRet, @aZbz
Local aRet   := {}
//Local cCnpjD := aCab[nX][16]
Local aTables	:= {} // incluido apenas para compatibilizar o teste para nao consumir licencas
Local cMsg		:= "" 		//FR - 16/08/2020

Default cTpr        := "J"
Default lEnergia    := .F.		//FR - 30/09/2020 
Default lCombustXML := .F.	//FR - 05/08/2022 - PROJETO POLITEC - CLASSIFICAÇÃO ROBÓTICA DE NFs COMBUSTÍVEIS (VIA XML APENAS)

RpcClearEnv()
cRet := "[F][ ][CLAS_AUT] Erro"

//RpcSetType(3)
IF .NOT. RpcSetEnv( xEmp, xFil,,,"COM",,aTables,.F.,.F.)

	//{ "SB1","SA5","SA7","SA1","SA2" }
	cRet := "[F][0][CLAS_AUT] " + "Filial ("+xEmp+" "+xFil+"): Não Foi Possível estabelecer conexão com a Empresa/Filial."
	conout( cRet )
	
	RstMvBuff()
	
	DelClassIntf()
	
	RpcClearEnv()
	
	//RESET ENVIRONMENT
	
	aRet := {cRet,aZbz,cMsg}		//FR - 16/08/2020
	
	Return( aRet )
	
EndIf

Private xZBZ  	  := GetNewPar("XM_TABXML","ZBZ")      //ECOOOOOOOOOO
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
Private x_Ped_Rec := GetNewPar("XM_PEDREC","N")
Private x_ZBB     := GetNewPar("XM_TABREC","")
Private aHfCloud  := {"0","0"," ","Token",{}}  //CRAUMDE - '0' Não integrar, na posição 1
Private x_Tip_Pre := GetNewPar("XM_TIP_PRE","1")
Private nFormNfe  := Val(GetNewPar("XM_FORMNFE","6")) 
Private nFormCte  := Val(GetNewPar("XM_FORMCTE","6"))
Private cFilUsu   := GetNewPar("XM_FIL_USU","N")
Private cIdEnt    := U_GetIdEnt()
Private cArqTxt   := cArq
Private cTpRt  	  := cTpr

aRet := U_HFzCHKCV( aCab, nX, aIte, cRet, aZbz, xEmp, xFil, lEnergia, lCombustXML )

RstMvBuff()

DelClassIntf()

RpcClearEnv()

//RESET ENVIRONMENT

Return( aRet )


User Function HFzCHKCV( aCab, nX, aIte, cRet, aZbz, xEmp, xFil, lEnergia, lCombustXML )

Local cChave    := ""
Local nPos      := 0
Local aRet      := {}
Local cCnpjD    := aCab[nX][16]
Local aZBO, nPFil, nPCod, nPDes, nPDto, nPHro, nPChv, nPRsf, nPTpo, nPRvo, nPArq, nPFpt, nPExa, nPStt, nPEmp, nPMai
Local lVazio    := .F.		//FR 16/07/2020
Local lContinua := .T.		//FR 16/07/2020 
Local nVezes    := 0		//FR 16/07/2020
Local nEspera   := 0
Local lEsgotou  := .F.		//FR - 06/08/2020
Local lEnviaMail:= .F.		//FR - 06/08/2020  
Local cMsgErro	:= ""		//FR - 06/08/2020
Local nTotTent  := GetNewPar("XM_TENTSEND", 5 )  
//Local lEnergia:= .F.		//FR - 18/08/2020
//Local oProcess  :=	Nil		//FR - 30/09/2020
Local lGravSA2 := .F.						//FR - 28/10/2021 - indica se gravou automaticamente SA2  
Local cAutoSA2 := "" 						//FR - 28/10/2021 - indica se automatiza o cadastro do fornecedor na SA2 Sim ou Não
Local cCNPJEmi := ""						//FR - 28/10/2021 - recebe o cnpj do emitente
Local cNsu     := ""

Private xZBZ  	:= GetNewPar("XM_TABXML","ZBZ")
Private xZB5  	:= GetNewPar("XM_TABAMAR","ZB5")
Private xZBS  	:= GetNewPar("XM_TABSINC","ZBS")
Private xZBE    := GetNewPar("XM_TABEVEN","ZBE")
Private xZBZ_ 	:= iif(Substr(xZBZ,1,1)=="S", Substr(xZBZ,2,2), Substr(xZBZ,1,3)) + "_"
Private xZB5_ 	:= iif(Substr(xZB5,1,1)=="S", Substr(xZB5,2,2), Substr(xZB5,1,3)) + "_"
Private xZBS_ 	:= iif(Substr(xZBS,1,1)=="S", Substr(xZBS,2,2), Substr(xZBS,1,3)) + "_"
Private xZBE_   := iif(Substr(xZBE,1,1)=="S", Substr(xZBE,2,2), Substr(xZBE,1,3)) + "_"
Private xZBA  	:= GetNewPar("XM_TABAMA2","ZBA")
Private xZBA_ 	:= iif(Substr(xZBA,1,1)=="S", Substr(xZBA,2,2), Substr(xZBA,1,3)) + "_"
Private xZBC    := GetNewPar("XM_TABCAC","ZBC")
Private xZBC_   := iif(Substr(xZBC,1,1)=="S", Substr(xZBC,2,2), Substr(xZBC,1,3)) + "_"
Private xZBO    := GetNewPar("XM_TABOCOR","ZBO"), xRetSEF := ""
Private xZBO_   := iif(Substr(xZBO,1,1)=="S", Substr(xZBO,2,2), Substr(xZBO,1,3)) + "_"
Private xZBI    := GetNewPar("XM_TABIEXT","ZBI")
Private xZBI_   := iif(Substr(xZBI,1,1)=="S", Substr(xZBI,2,2), Substr(xZBI,1,3)) + "_"

Default lEnergia    := .F.		//FR - 30/09/2020  
Default lCombustXML := .F. 	//FR - 05/08/2022 - PROJETO POLITEC - CLASSIFICAÇÃO ROBÓTICA DE NFs COMBUSTÍVEIS (VIA XML APENAS) 

aZBO := U_HF13ZBOA()

U_HF13ZPOS( aZBO, @nPFil, @nPCod, @nPDes, @nPDto, @nPHro, @nPChv, @nPRsf, @nPTpo, @nPRvo, @nPArq, @nPFpt, @nPExa, @nPStt, @nPEmp, @nPMai )  
nEspera := GetNewPar("XM_ITSLEEP",10000)		  				//FR 17/07/2020
//lEnergia := U_fVerXMLEnerg( , , ,.T.,oProcess)  //U_fVerXMLEnerg(aCab,aIte,lSoCheck)

If nX > 0

	if Len( aCab[nX] ) >= 17
	
		cChave := aCab[nX][17]
		
	EndIf
	
Endif

DbSelectArea( xZBZ )
dbSetORder( 3 )

nVezes    := 1    		//FR - 06/08/2020
nRetDow   := 0          //FR - 06/08/2020 
//----------------//
//AQUI O DOWNLOAD   
//----------------//
If ! (xZBZ)->( dbSeek( cChave ) )

//	U_HFDGXML( cChave, lAuto, lEnd, oProcess, cLogProc, nCount, cVem )
	nVezes    := 1 
	nRetDow   := 0
	
	Do While nVezes <= nTotTent .And. lContinua
	
		xRetSEF := ""	
		Sleep(nEspera)			//FR - 06/08/2020
		
		CONOUT("<GESTAOXML> DOWNLOAD -> LOOP VEZ ==> " + Alltrim(Str(nVezes)) + "/" + Alltrim(Str(nTotTent)) + " <==" )	  	//FR - 06/08/2020	    
		
		DbSelectArea(xZBS)
		DbSetOrder(3)
		if DbSeek( cChave )

			cNsu := (xZBS)->(FieldGet(FieldPos(xZBS_+"NSU")))

		endif
		
		//If U_HFDGXML( cChave, .T.  , .F. ,  NIL    , ""      , 0     , "2"  ) > 0
		nRetDow := U_HFDGXML( cChave, .T.  , .F. ,  NIL    , ""      , 0     , "2", cNsu  ) 			//FR - 06/08/2020
		
		If nRetDow > 0
		
			Conout( "Download OK => " + cChave )
			lContinua := .F.		
		
		Else
		
			lContinua := .T.
			
			(xZBZ)->(OrdSetFocus(3))
			(xZBZ)->( dbSeek( cChave ) )
			 
		    Conout("NOTA ==> " + (xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA"))) ) 
		    
		    lVazio    := Empty( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML"))) )
			lContinua := lVazio  //.T. continua, .F. aborta  
			
			If lContinua
				Conout( "Download Nao Realizado => " + cChave )
			Endif
			
			//If Substr(xRetSEF,1,3) <> "999"			
				//EXIT				
			//Endif
			
			//--------------------------------------------------------------------------------------------//
		    //FR - 06/08/2020 - gravar ocorrência e enviar email caso esgote as tentativas de redownload
		    //--------------------------------------------------------------------------------------------//		    
		    If nVezes >= nTotTent 
		    	lEsgotou := .T.
		    Endif
			
		Endif
		
		nVezes++		
	EndDo
	//cadastra o fornecedor de forma automática caso não exista
	//----------------------------------------------------------//
	//FR - 28/10/2021 - DAIKIN - CADASTRO AUTOMÁTICO FORNECEDOR 
	//----------------------------------------------------------//
	cAutoSA2 := GetNewPar("XM_SA2AUTO","N")   //FR - 28/10/2021 - indica se automatiza o cadastro do fornecedor na SA2 Sim ou Não
			
	If cAutoSA2 == "S"

		(xZBZ)->(OrdSetFocus(3))
		If (xZBZ)->( dbSeek( cChave ) ) 
						
			//Aqui chama a função de cadastro automático de fornecedor
			If (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC"))) <> "D" .and. (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC"))) <> "B"
								
				//só cadastra automático se não for tipo Beneficiamento ou Devolução (porque nesse caso é Cliente)
				cCNPJEmi := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ")))
				U_fCADSA2(cCNPJEmi,(xZBZ)->(Recno()) )				
							
			Endif
							
		Endif
	Endif   			
	//----------------------------------------------------------//
	//FR - 28/10/2021 - DAIKIN - CADASTRO AUTOMÁTICO FORNECEDOR 
	//----------------------------------------------------------//
	
Else

	//--------------------------------------------------------------//	
	//FR - 16/07/2020 - repetir o download em caso de Xml Resumido
	//--------------------------------------------------------------//
	//AQUI O REDOWNLOAD   
	//--------------------------------------------------------------//

	lVazio    := Empty( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML"))) )
	nVezes    := 1 
	nRetDow   := 0
	If lVazio 
		
		CONOUT("<GESTAOXML> CAMPO XML VAZIO - XML RESUMIDO <===")
		Do While nVezes <= nTotTent .And. lContinua
	
			xRetSEF := ""
			
			Sleep(nEspera)
			
		    CONOUT("<GESTAOXML> REDOWNLOAD -> LOOP VEZ ==> " + Alltrim(Str(nVezes)) + "/" + Alltrim(Str(nTotTent))+ " <==" )		    
			//If U_HFDGXML( cChave, .T.  , .F. ,  NIL    , ""      , 0     , "2"  ) > 0
			nRetDow := U_HFDGXML( cChave, .T.  , .F. ,  NIL    , ""      , 0     , "2"  )
			DbSelectArea(xZBS)
			DbSetOrder(3)
			if DbSeek( cChave )

				cNsu := (xZBS)->(FieldGet(FieldPos(xZBS_+"NSU")))

			endif

			nRetDow := U_HFDGXML( cChave, .T.  , .F. ,  NIL    , ""      , 0     , "2", cNsu  )
			
			If nRetDow > 0

				Conout( "ReDownload OK => " + cChave )
				lContinua := .F.			
			
			Else

			    lContinua := .T.
			    
			    (xZBZ)->(OrdSetFocus(3))
				(xZBZ)->( dbSeek( cChave ) ) 
			    
			    Conout("NOTA ==> " + (xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA"))) )
			    
			    lVazio    := Empty( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML"))) )
				lContinua := lVazio  //.T. continua, .F. aborta
				
				If lContinua
					Conout( "ReDownload Nao Realizado => " + cChave )
				Endif
				
			   //If Substr(xRetSEF,1,3) <> "999"				
					//EXIT					
				//Endif
				//--------------------------------------------------------------------------------------------//
			    //FR - 06/08/2020 - gravar ocorrência e enviar email caso esgote as tentativas de redownload
			    //--------------------------------------------------------------------------------------------//
			    If nVezes >= nTotTent
			    	lEsgotou := .T.
			    Endif
				
			Endif

		    nVezes++		 
			   
		EndDo
		//cadastra o fornecedor de forma automática caso não exista
		//----------------------------------------------------------//
		//FR - 28/10/2021 - DAIKIN - CADASTRO AUTOMÁTICO FORNECEDOR 
		//----------------------------------------------------------//
		cAutoSA2 := GetNewPar("XM_SA2AUTO","N")   //FR - 28/10/2021 - indica se automatiza o cadastro do fornecedor na SA2 Sim ou Não
			
		If cAutoSA2 == "S"

			(xZBZ)->(OrdSetFocus(3))
			If (xZBZ)->( dbSeek( cChave ) ) 
						
				//Aqui chama a função de cadastro automático de fornecedor
				If (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC"))) <> "D" .and. (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC"))) <> "B"
								
					//só cadastra automático se não for tipo Beneficiamento ou Devolução (porque nesse caso é Cliente)
					cCNPJEmi := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ")))
					U_fCADSA2(cCNPJEmi,(xZBZ)->(Recno()) )				
							
				Endif
							
			Endif
		Endif   			
		//----------------------------------------------------------//
		//FR - 28/10/2021 - DAIKIN - CADASTRO AUTOMÁTICO FORNECEDOR 
		//----------------------------------------------------------//
		
	Endif 	//lVazio

Endif

If !(xZBZ)->( dbSeek( cChave ) ) .OR. lEsgotou   //FR - 06/08/2020 
    
	//FR - 06/08/2020 - Se dentro do Protheus, emite alerta de "não download", se via job, enviará email aos cadastrados no parâmetro XM_MAIL07
	If !IsBlind() 
	
		//MsgAlert("Chave Não Encontrada: " + CRLF + cChave + CRLF + "=> DownLoad Não Realizado <= ") 
		cMsgErro := "Chave Não Encontrada => " + cChave	
		
	Else    		//FR - 06/08/2020 - Se via job, envia email
		lEnviaMail := lEsgotou
	Endif

	cRet := "[T][8][CLAS_AUT] Chave Não Encontrada."
	nPos := aScan( aZbz, { |x| x[1] = "ST" } )
	
	if nPos > 0
		
		aZbz[nPos][2] := "9"  //Não Encontrado na ZBZ Vai Para Auditoria
	
	Endif
	
	nPos := aScan( aZbz, { |x| x[1] = "ST" } )
	
	if nPos > 0
	
		aZbz[nPos][2] := "9"  //Não Encontrado na ZBZ Vai Para Auditoria
	
	Endif
	
	nPos := aScan( aZbz, { |x| x[1] = "NOTA" } )
	
	if nPos > 0
	
		aZbz[nPos][2] := aCab[nX][11]
		
	Endif
	
	nPos := aScan( aZbz, { |x| x[1] = "SERIE" } )
	
	if nPos > 0
	
		aZbz[nPos][2] := aCab[nX][12]
		
	Endif
	
	nPos := aScan( aZbz, { |x| x[1] = "CNPJ" } )
	
	if nPos > 0
	
		aZbz[nPos][2] := aCab[nX][08]
		
	Endif
	
	nPos := aScan( aZbz, { |x| x[1] = "FORNEC" } )
	
	if nPos > 0
	
		aZbz[nPos][2] := aCab[nX][01]
		
	Endif
	
	nPos := aScan( aZbz, { |x| x[1] = "CHAVE" } )
	
	if nPos > 0
	
		aZbz[nPos][2] := cChave
		
	Endif
	
	nPos := aScan( aZbz, { |x| x[1] = "CNPJD" } )
	
	if nPos > 0
	
		aZbz[nPos][2] := cCnpjD
		
	Endif
	
	nPos := aScan( aZbz, { |x| x[1] = "REG" } )
	
	if nPos > 0
	
		aZbz[nPos][2] := 0
		
	Endif

	//AQUI vai para o ZBO, Log de not download
	if nPFil > 0
	
		aZBO[nPFil][4] := xFilial( xZBO )
		
	endif
	
	//nPCod  //Se o código for zero, vai somar 1
	if nPDes > 0
	
		aZBO[nPDes][4] := "[Download] Nao foi possível Download no SEFAZ "
	
	endif
	
	if nPDto > 0
	
		aZBO[nPDto][4] := dDataBase
		
	endif
	
	if nPHro > 0
	
		aZBO[nPHro][4] := Time()
		
	endif
	
	if nPChv > 0
	
		aZBO[nPChv][4] := cChave
		
	endif
	
	if nPRsf > 0
	
		aZBO[nPRsf][4] := xRetSEF 
		
	endif
	
	if nPTpo > 0
	
		aZBO[nPTpo][4] := "1"
		
	endif
	
	if nPExa > 0
	
		aZBO[nPExa][4] := ""
		
	endif
	
	If nPArq > 0
	
		aZBO[nPArq][4] := cArqTxt
		
	EndIf
	
	if nPStt > 0
	
		aZBO[nPStt][4] := iif( Substr(xRetSEF,1,3)="640", "0",  "1" )
		
	EndIf
	
	//nPFil, nPCod, nPDes, nPDto, nPHro, nPChv, nPRsf, nPTpo, nPRvo, nPArq, nPFpt, nPStt, nPEmp, nPMai
	//AQUI vai para o ZBO, Log de not download
	cChaveNF := cChave
	If U_HF13ZBOG( .F., 4, xFilial(xZBO)+"1"+AllTrim(cChave)+cArqTxt, aZBO,cChaveNF )    //FR 13/07/2020
			
		Conout("<GESTAOXML> GRAVOU ZBO - FALHA DOWNLOAD SEFAZ") 
		
		//U_HF13MAIL( cArqTxt, .F., "Ocorrencia de DownLoad XML" )	//FR 16/08/2020
			
	Endif	
	
	//AQUI vai para o ZBO, Log de not download

Else

	//cadastra o fornecedor de forma automática caso não exista
	//----------------------------------------------------------//
	//FR - 28/10/2021 - DAIKIN - CADASTRO AUTOMÁTICO FORNECEDOR 
	//----------------------------------------------------------//
	cAutoSA2 := GetNewPar("XM_SA2AUTO","N")   //FR - 28/10/2021 - indica se automatiza o cadastro do fornecedor na SA2 Sim ou Não
	
	If cAutoSA2 == "S"
			
		//Aqui chama a função de cadastro automático de fornecedor
		If (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC"))) <> "D" .and. (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC"))) <> "B"
					
			//só cadastra automático se não for tipo Beneficiamento ou Devolução (porque nesse caso é Cliente)
			cCNPJEmi := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ")))
			U_fCADSA2(cCNPJEmi,(xZBZ)->(Recno()) )				
				
		Endif
				
	Endif  			
	//----------------------------------------------------------//
	//FR - 28/10/2021 - DAIKIN - CADASTRO AUTOMÁTICO FORNECEDOR 
	//----------------------------------------------------------//
	cPrNf := U_HFSTXMUN( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))),;
	               (xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA"))),;
	               (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE"))),;
	               (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR")))+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR"))) ,;
	               (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC"))),;
	               (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO"))),;
	               (xZBZ)->(FieldGet(FieldPos(xZBZ_+"DOCCTE"))),;
	               (xZBZ)->(Recno()),.T. )
	               
	If AllTrim(cPrNf) $ "B,S"
	
		cRet := "[T]["+cPrNf+"][CLAS_AUT] "
		
	ElseIf AllTrim(cPrNf) $ "X"
	
		cRet := "[T][X][CLAS_AUT] XML Cancelado ."
		
	ElseIf AllTrim(cPrNf) $ "N"
	
		cRet := "[T][N][CLAS_AUT] Documento Já Classificado."
		
	ElseIf AllTrim(cPrNf) $ "Z"
	
		cRet := "[T][Z][CLAS_AUT] XML com erro de consulta ao SEFAZ."
		
	Else
	
		cRet := "[T][9][CLAS_AUT] XML com status diferente de baixado."
		
	EndIF
	
	nPos := aScan( aZbz, { |x| x[1] = "ST" } )
	
	if nPos > 0
	
		aZbz[nPos][2] := iif( cPrNf = "N", "2", iif( cPrNf = "S", "1", " ") )  //Branco e 1 porque pode pedir a classificação
	
	Endif
	
	nPos := aScan( aZbz, { |x| x[1] = "NOTA" } )
	
	if nPos > 0
	
		aZbz[nPos][2] := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA")))
		
	endif
	
	nPos := aScan( aZbz, { |x| x[1] = "SERIE" } )
	
	if nPos > 0
	
		aZbz[nPos][2] := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE")))
		
	endif
	
	nPos := aScan( aZbz, { |x| x[1] = "DTNFE" } )
	
	if nPos > 0
	
		aZbz[nPos][2] := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"DTNFE")))
		
	endif
	
	nPos := aScan( aZbz, { |x| x[1] = "PRENF" } )
	
	if nPos > 0
	
		aZbz[nPos][2] := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF")))
		
	endif
	
	nPos := aScan( aZbz, { |x| x[1] = "CNPJ" } )
	
	if nPos > 0
	
		aZbz[nPos][2] := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ")))
		
	endif
	
	nPos := aScan( aZbz, { |x| x[1] = "FORNEC" } )
	
	if nPos > 0
	
		aZbz[nPos][2] := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FORNEC")))
		
	endif
	
	nPos := aScan( aZbz, { |x| x[1] = "CHAVE" } )
	
	if nPos > 0
	
		aZbz[nPos][2] := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE")))
		
	endif
	
	nPos := aScan( aZbz, { |x| x[1] = "TPDOC" } )
	
	if nPos > 0
	
		aZbz[nPos][2] := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC")))
		
	endif
	
	nPos := aScan( aZbz, { |x| x[1] = "CODFOR" } )
	
	if nPos > 0
	
		aZbz[nPos][2] := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR")))
		
	endif
	
	nPos := aScan( aZbz, { |x| x[1] = "LOJFOR" } )
	
	if nPos > 0
	
		aZbz[nPos][2] := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR")))
		
	endif
	
	nPos := aScan( aZbz, { |x| x[1] = "XMLNFE" } )
	
	if nPos > 0
	
		aZbz[nPos][2] := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML")))
		
	endif
	
	nPos := aScan( aZbz, { |x| x[1] = "CNPJD" } )
	
	if nPos > 0
	
		aZbz[nPos][2] := cCnpjD
		
	Endif
	
	nPos := aScan( aZbz, { |x| x[1] = "M0COD" } )
	
	if nPos > 0
	
		aZbz[nPos][2] := xEmp
		
	endif
	
	nPos := aScan( aZbz, { |x| x[1] = "M0FIL" } )
	
	if nPos > 0
	
		aZbz[nPos][2] := xFil
		
	endif
	
	nPos := aScan( aZbz, { |x| x[1] = "REG" } )
	
	if nPos > 0
	
		aZbz[nPos][2] := (xZBZ)->( Recno() )
		
	endif
	
	If Empty( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"COMBUS"))) ) //Ver o que fazer no futuro para ficar generico
		If !lEnergia       				//FR - 18/08/2020
			dbSelectArea( xZBZ )
			RecLock( xZBZ, .F. )
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"COMBUS"), "S" ))
			(xZBZ)->( MsUnlock() )
		ElseIf lCombustXML      				
			RecLock( xZBZ, .F. )
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"COMBUS"), "C" )) 	//FR - 05/08/2022 - PROJETO POLITEC - CLASSIFICAÇÃO ROBÓTICA DE NFs COMBUSTÍVEIS (VIA XML APENAS)
			(xZBZ)->( MsUnlock() )		
		
		Endif
		
	Endif

Endif

aRet := {cRet,aZbz,cMsgErro}		//FR - 16/08/2020

Return( aRet )



Static Function HFXML131Bw(lEnergia,lCombustXml)

Local aButtons	:= {}
//Local aGetArea	:= GetArea()
//Local aObjects	:= {}
//Local aSize		:= MsAdvSize()  			// Define e utilização de janela padrão Microsiga
//Local cGetLOk  	:= "AllwaysTrue"	   		// Funcao executada para validar o contexto da linha atual do aCols
//Local cGetTOk  	:= "AllwaysTrue"    		// Funcao executada para validar o contexto geral da MsNewGetDados
//Local oFolder	:= Nil
Local oDlg01	:= Nil
Local oMarkBw	:= Nil
Local lInverte	:= .F.
Local lOk		:= .F.
//Local cChvAtu	:= " "
Local aCpos     := {}
Local aCores    := {}

Default lCombustXML := .F.	//FR - 05/08/2022 - PROJETO POLITEC - CLASSIFICAÇÃO ROBÓTICA DE NFs COMBUSTÍVEIS (VIA XML APENAS)
Default lEnergia    := .F. 
Private cMarcaOK := GetMark()

aCpos := {}
aadd( aCpos, {"OK"   	,,"" } )
aadd( aCpos, {"NOTA"    ,,"NOTA FISCAL","@!" } )
aadd( aCpos, {"SERIE"   ,,"SERIE","@!" } )
aadd( aCpos, {"DTNFE"   ,,"DT EMISSAO","@D" } )
aadd( aCpos, {"CHAVE"   ,,"CHAVE","@!" } )
aadd( aCpos, {"CNPJ"    ,,"CNPJ","@!" } )
aadd( aCpos, {"FORNEC"  ,,"EMITENTE","@!" } )
aadd( aCpos, {"CODFOR"  ,,"FORNEC","@!" } )
aadd( aCpos, {"LOJFOR"  ,,"LOJA","@!" } )
aadd( aCpos, {"TPDOC"   ,,"TIPO","@!" } )

aCores := {}
aAdd(aCores,{cTmp_ZBZ+"->ST == '0'","BR_PRETO"		})  //Erro Ao Crassifica
aAdd(aCores,{cTmp_ZBZ+"->ST == '2'","BR_VERMELHO"	})  //Classificada
aAdd(aCores,{cTmp_ZBZ+"->ST == '1'","BR_VERDE"	    })  //Apenas Pré-Nota
aAdd(aCores,{cTmp_ZBZ+"->ST == ' '","BR_AZUL"	    })  //Importado, esperando para classificar
aAdd(aCores,{cTmp_ZBZ+"->ST == '9'","BR_AMARELO"    })  //Pobrema Não Encontrado

dbSelectArea(cTmp_ZBZ)
//COUNT TO nQtdReg
(cTmp_ZBZ)->( dbGotop() )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apresenta botao se nao for visualizacao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aButtons,{'CHECKED' ,{ || MULTCTEInv(cMarcaOK,@oMarkBw)     }, "Inverter Marcação"      , "Inverter"  })
aAdd(aButtons,{'DESTINOS',{ || MULTCTEInv(cMarcaOK,@oMarkBw,.T.) }, "Marcar todos os títulos", "Marc Todos"})
aAdd(aButtons,{          ,{ || HFXML13Leg() 					 }, "Legenda"				 , "Legenda"   })

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define as posicoes da GetDados e Paineis ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//aAdd( aObjects, { 100, 060, .T., .T. } )      //GetDados
//aAdd( aObjects, { 100, 040, .T., .T. } )      //Folder
//aInfo := { aSize[1], aSize[2], aSize[3], aSize[4], 3, 3 }
//aPosObj := MsObjSize( aInfo, aObjects,.T. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao da tela ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    //aSize[7],0 TO aSize[6],aSize[5]
DEFINE MSDIALOG oDlg01 TITLE "Classificação Automática de Combustíveis" FROM 000,000 TO 430,800 OF oMainWnd PIXEL

oDlg01:lMaximized := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria o objeto Mark para a selecao dos podrutos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oMarkBw:=MsSelect():New(cTmp_ZBZ,"OK","",aCpos,@lInverte,@cMarcaOK,{17,10,150,400},,,,,aCores) //oFolder:aDialogs[1]

oMarkBw:oBrowse:Refresh()
oMarkBw:oBrowse:lhasMark    := .T.
oMarkBw:oBrowse:lCanAllmark := .T.
oMarkBw:oBrowse:Align       := CONTROL_ALIGN_ALLCLIENT	//Usado no modelo FLAT


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Permite selecao se não for visualizacao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oMarkBw:oBrowse:bAllMark    := { || MULTCTEInv(cMarcaOK,@oMarkBw) }
oMarkBw:oBrowse:bChange     := { || MULTCTEChg(@oMarkBw) }
oMarkBw:BMark               := { || MULTCTEDis(@oMarkBw,cMarcaOK) }

//ACTIVATE MSDIALOG oDlg01 CENTERED  ON INIT EnchoiceBar(oDlg01,;
//{|| processa({|| Classifica(.T.,@oMarkBw)}, "Classificando Documentos...","Classificando Documentos ...") },;  

ACTIVATE MSDIALOG oDlg01 CENTERED  ON INIT EnchoiceBar(oDlg01,;
{|| processa({|| Classifica(.T.,@oMarkBw,lEnergia,lCombustXML)}, "Classificando Documentos...","Classificando Documentos ...") },;
{|| iif( msgYesNo("Sair Classificação Automática ?","Pegunta"),oDlg01:End(),lOk := .F. )},,aButtons)

//Classifica(.F., NIL,lEnergia,lCombustXML )
Return( .T. )


Static Function MULTCTEInv(cMarcaOK,oMarkBw,lMarkAll)

Local aGetArea	:= GetArea()
Local lMarcSim	:= .F.

If lMarkAll

	lMarcSim := Aviso( "Marcar/Desmarcar todos", "Deseja marcar ou desmarcar todos os títulos?", { "Marcar", "Desmarcar" } ) == 1

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ While para marcar ou desmarcar os produtos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
(cTmp_ZBZ)->( dbGotop() )

Do while (cTmp_ZBZ)->( !EOF() )

	If lMarkAll
	
		RecLock(cTmp_ZBZ, .F.)
		(cTmp_ZBZ)->OK	:= if((cTmp_ZBZ)->ST $ "2,9", "  ", If(lMarcSim, cMarcaOK, "  ") )
		(cTmp_ZBZ)->( MsUnLock() )
		
	Else
	
		If  (cTmp_ZBZ)->OK == cMarcaOK
		
			RecLock(cTmp_ZBZ, .F.)
			(cTmp_ZBZ)->OK	:= "  "
			(cTmp_ZBZ)->( MsUnLock() )
			
		Else
		
			RecLock(cTmp_ZBZ, .F.)
			(cTmp_ZBZ)->OK	:= if((cTmp_ZBZ)->ST $ "2,9", "  ", cMarcaOK )
			(cTmp_ZBZ)->( MsUnLock() )
			
		EndIf
		
	EndIf

	(cTmp_ZBZ)->( dbSkip() )
	
EndDo

oMarkBw:oBrowse:Refresh(.T.)
RestArea( aGetArea )

Return


Static Function MULTCTEChg(oMarkBw)

Local cRetFun		:= " "

oMarkBw:oBrowse:Refresh(.T.)

Return cRetFun


Static Function MULTCTEDis(oMarkBw, cMarcaOK)

Local aGetArea := GetArea()

If (cTmp_ZBZ)->ST $ "2,9" //.OR. (cTmp_ZBZ)->OK == cMarcaOK

	RecLock(cTmp_ZBZ, .F.)
	(cTmp_ZBZ)->OK	:= "  "
	(cTmp_ZBZ)->( MsUnLock() )
	
Endif

oMarkBw:oBrowse:Refresh(.T.)

RestArea( aGetArea )

Return


Static Function HFXML13Leg()

Local aLegenda := {}

AADD(aLegenda,{"BR_AZUL"    ,"Aguardando Classificação" })
AADD(aLegenda,{"BR_VERDE" 	,"NF Pré-nota lançada" })
AADD(aLegenda,{"BR_VERMELHO","NF Classificada" })
AADD(aLegenda,{"BR_AMARELO" ,"XML não encontrado" })
AADD(aLegenda,{"BR_PRETO"   ,"Erro na Classificação" })

BrwLegenda("Download de XML", "Legenda", aLegenda)

Return Nil

//--------------------------------------------------------------------------------------------------------//
//Classificar Via StartJob e Ver Amarra apenas da empresa atual.
//Nesta função Classifica, a variável lEnergia vale tanto para os XMLs da Kroma (Empresa de Energia)
//Quanto para outros de combustível, no caso por exemplo Politec
//por isso não vi necessidade de criar outra variável
//Aguas do Brasil é outra sistemática então nesse caso o lEnergia vai tá = .F.
//--------------------------------------------------------------------------------------------------------//
Static Function Classifica(lMostra,oMarkBw,lEnergia,lCombustXML)
Local nReg   := (cTmp_ZBZ)->( recno() )
//Local nFadiga:= (cTmp_ZBZ)->( recno() )
Local aXEmpF := {}
Local nPosCn := 0
Local lRet   := .T.
Local lTem   := .F.
Local aRet   := {}
Local cRet   := ""
Local aReg   := {}
Local nTot   := 0
Local nPrc   := 0
Local nErr   := 0
Local nOk    := 0
//Local lEnergia:= .F.
//Local oProcess:= Nil								//FR - 30/09/2020
Private oXml
Private oDet, oOri
Private xZBZ		:= GetNewPar("XM_TABXML","ZBZ")
Private xZBZ_		:= iif(Substr(xZBZ,1,1)=="S", Substr(xZBZ,2,2), Substr(xZBZ,1,3)) + "_"  
Private aNFDiverg   := {}

Private cUsaDvg     := GetNewPar("XM_USADVG","N") 	//FR 19/05/2020 - indica de está ativada a verificação de divergências Sim / Não

Default lEnergia    := .F.		//FR - 30/09/2020   
Default lCombustXML := .F.	//FR - 05/08/2022 - PROJETO POLITEC CLASSIF NF COMBUSTIVEIS VIA XML
if lMostra

	ProcRegua((cTmp_ZBZ)->( RecCount() ))
	
Endif

cMsg := "Classficando NFE(s):" + CRLF

//lEnergia := U_fVerXMLEnerg( , , ,.T.,oProcess)  //U_fVerXMLEnerg(aCab,aIte,lSoCheck)
if lMostra //JOB não entra aqui, se tiver que dar erro da direto e boa

//	If .NOT. VERAMARRA(lMostra)  //Aqui vai ver apenas a empresa atual, se mudar o bixo.
//		lRet := .F.
//		Return( .F. )
//	EndIf

Endif

if lMostra

	ProcRegua((cTmp_ZBZ)->( RecCount() ))
	
Endif

//-------------------------------------------------------//
//FR - 18/05/2020 - TRATATIVA PARA PRÉ-AUDITORIA FISCAL  //
//-------------------------------------------------------//
//------------------------------------------------------------------------------------------//
//FR - tratativa para identificar divergências entre NF e XML:
//------------------------------------------------------------------------------------------//
aNFDiverg := {}
aCabNFE   := {}
aIteNFE   := {}
nOpDiverg := 0
nIte      := 0
lDiverg   := .F.
cMsg      := "" 

//lMostra   := .F. //FR TESTE  
If lMostra

	If cUsaDvg == "S"  //FR se o parâmetro está ativado para verificar divergências

		If !lEnergia   			//FR - 18/08/2020 - EM Xmls de Compra de Energia não é necessário verificar divergência porque a nota sempre será amarrada ao pedido de compra
			(cTmp_ZBZ)->( dbgotop() )
		
			Do While .not. (cTmp_ZBZ)->( Eof() )
						
				//If .not. empty( (cTmp_ZBZ)->OK ) // == cMarcaOK 
				If (cTmp_ZBZ)->OK == cMarcaOK //só faz do que tá marcado
					
					DbSelectArea( xZBZ )
					nReg := (cTmp_ZBZ)->REG
					
					(xZBZ)->( dbGoTo( nReg ) )
			
					cError := ""
					cWarning := ""
					
					oXml := XmlParser((xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML"))), "_", @cError, @cWarning )
								
					aReg   := {}
					aCabec := {}
					aItens := {} 
					cMsg   := "" 
					lDiverg := .F.
					
					aadd( aReg, (cTmp_ZBZ)->NOTA   )  //01
					aadd( aReg, (cTmp_ZBZ)->SERIE  )  //02
					aadd( aReg, (cTmp_ZBZ)->DTNFE  )  //03
					aadd( aReg, (cTmp_ZBZ)->CHAVE  )  //04
					aadd( aReg, (cTmp_ZBZ)->CODFOR )  //05
					aadd( aReg, (cTmp_ZBZ)->LOJFOR )  //06
					aadd( aReg, (cTmp_ZBZ)->TPDOC  )  //07
					aadd( aReg, (cTmp_ZBZ)->CONDPG )  //08
					aadd( aReg, (cTmp_ZBZ)->PEDCOM )  //09		//FR - 30/09/2020
					aadd( aReg, (cTmp_ZBZ)->ITEMPC )  //10		//FR - 30/09/2020
					
					//cria array do cabeçalho da nf
					addCabec( aReg , @cMsg, (cTmp_ZBZ)->CONDPG )         //cria o cabeçalho da nf para efetuar a comparação
					
					//cria array dos itens da nf
					addItens( @nIte  , @cMsg, lEnergia, aReg[09] , aReg[10]   , nReg   , lCombustXML  )         				
					
					If Len(aCabec) > 0
						U_fMontaArray(aCabec,aItens,@aCabNFE,@aIteNFE)
					
						//------------------------------------------------------------------------------------------------------------------------------------------// 	
						//FR - Monta os arrays aCabNFE e aIteNFE, ambos são da NF, mas não posso utilizar o aCabec nem o aItens, pois não estão na ordem necessária
						//FR - utiliza os arrays aCabec e aItens para montar os arrays aCabNFE e aIteNFE -> estes dois últimos têm a estrutura necessária
						//para comparação com o array de cabeçalho e itens do XML.
						//------------------------------------------------------------------------------------------------------------------------------------------// 	 
						lOmiTTela := .T.   //FR - .T. = omite a exibição da tela de divergência, e só gera o relatório em Excel, Nil = Mostra a tela
						lDiverg   := U_HFXML063((cTmp_ZBZ)->CHAVE, aCabNFE,aIteNFE,"NOTA FISCAL",,lOmiTTela)   //FR -  chamada da tela função da tela de divergências, porém, sem apresentar a tela, só checagem de divergências
						If lDiverg
							Aadd(aNFDiverg , {(cTmp_ZBZ)->NOTA, (cTmp_ZBZ)->SERIE, (cTmp_ZBZ)->CODFOR, (cTmp_ZBZ)->LOJFOR,(cTmp_ZBZ)->CHAVE } )			
						Endif
					Endif 
						
				Endif //Se está marcado "OK"
				
				DbSelectArea( cTmp_ZBZ )
				(cTmp_ZBZ)->( dbskip() )
			
			Enddo
		
			//FR - ordena o array de notas com divergência pela CHAVE:
			ASORT( aNFDiverg, , , { | x,y | x[5] < y[5] } )
			//FR - Zera variáveis:
			aReg   := {}
			aCabec := {}
			aItens := {} 
			
			If Len(aNFDiverg) > 0 .and. !lEnergia
				aParams := {}
				U_fPovoaPar(@aParams,aNFDiverg)		//povoa o array de parâmetros para o relatório		
						
				U_HFXMLR16(aParams)     //chama o relatório já passando por parâmetro a NF/XML a ser verificado
				nOpDiverg := Aviso("Atenção","Existem Divergências, Prossegue ?",	{"Sim","Não"},	1)  
				If nOpDiverg == 2
					MsgInfo("Somente As Notas SEM Divergência Serão Classificadas")
				Endif			
			Else
				nOpDiverg := 1    //1-prossegue;2-Não prossegue
			Endif
			
		Endif 	//lEnergia
	Endif 		//FR se o parâmetro estiver ativado de verificar divergências
	
Endif //lMostra
//--------------------------------------------------------// 
//FR - 18/05/2020 - Fim tratativas de divergência NF x XML
//--------------------------------------------------------//

(cTmp_ZBZ)->( dbgotop() )
Do While .not. (cTmp_ZBZ)->( Eof() )

    lProssegue := .T.		//FR 18/05/2020
    
	//if lMostra	
	//	IncProc("Processando "+(cTmp_ZBZ)->NOTA)		
	//endif   
    
	nTot++

	//If (cTmp_ZBZ)->OK == cMarcaOK 
	//If .not. empty( (cTmp_ZBZ)->OK )
	//-------------------------------------------------------------------------------------------------------------------------//
	//FR - 05/08/2022 - ALTERAÇÃO P/ PROJETO POLITEC, melhoria no markbrowse: qdo é dentro do Protheus, 
	//fazer apenas o que está [x] marcado, senão ele faz todos os xmls até os que não estão marcados
	//-------------------------------------------------------------------------------------------------------------------------//
	If lMostra 							//se dentro do Protheus, pega apenas os marcados
		If (cTmp_ZBZ)->OK == cMarcaOK //só faz do que tá marcado
			lProssegue := .T.
		Else 
			lProssegue := .F. 
		Endif 
	
	//-----------------------------------------------------------------------------------------------------------------------------//
	//se fora do Protheus (via job), pega todos os xmls do arquivo temporário pois não tem como marcar, 
	//aí vai pela amarração, cadastros gerais respectivos a classif. combustível, se tiver faz, 
	//se não tiver, vai gerar ocorrência e não classifica
	//-----------------------------------------------------------------------------------------------------------------------------//
	Else	
		If .not. empty( (cTmp_ZBZ)->OK )
			lProssegue := .T.
		Endif 
	Endif  

	If lProssegue		//FR - 05/08/2022 - PROJETO POLITEC

		if lMostra	
			IncProc("Processando "+(cTmp_ZBZ)->NOTA)		
		endif 
		
		If cUsaDvg == "S" //FR se o parâmetro estiver ativado
			If !lEnergia
				//FR - verifica se a chave da NF lida está na lista de notas divergências
				nDiverg := aScan( aNFDiverg, { |x| x[5] = (cTmp_ZBZ)->CHAVE } )   //FR - pesquisa se a chave existe no array de notas com divergência
				If nDiverg > 0
					lProssegue := .F.
					If nOpDiverg == 1 		//mas, se o usuário escolheu que prossegue mesmo com divergência, a NF será classificada mesmo assim
						lProssegue := .T.
					Endif
			    Endif
		    Endif
	    Endif
	    
	    If lProssegue
	
		nPrc++
		aXEmpF := {}
		nPosCn := aScan( aEmpFils, {|x| x[4] == (cTmp_ZBZ)->CNPJD } )
		
		if nPosCn > 0
		
			aadd( aXEmpF, iif(aEmpFils[nPosCn][1], 1, 2) )  //1 - Lic, 2 - Sem Lic
			aadd( aXEmpF, aEmpFils[nPosCn][2] )  //Empresa
			aadd( aXEmpF, aEmpFils[nPosCn][3] )  //Filial
			aadd( aXEmpF, (cTmp_ZBZ)->CNPJD  )   //Cnpj
			
		else
		
			aadd( aXEmpF, 0 )
			aadd( aXEmpF, cEmpAnt )
			aadd( aXEmpF, cFilAnt )
			aadd( aXEmpF, (cTmp_ZBZ)->CNPJD  )
			
		endif

		aReg   := {}
		
		aadd( aReg, (cTmp_ZBZ)->NOTA   )  //01
		aadd( aReg, (cTmp_ZBZ)->SERIE  )  //02
		aadd( aReg, (cTmp_ZBZ)->DTNFE  )  //03
		aadd( aReg, (cTmp_ZBZ)->CHAVE  )  //04
		aadd( aReg, (cTmp_ZBZ)->CODFOR )  //05
		aadd( aReg, (cTmp_ZBZ)->LOJFOR )  //06
		aadd( aReg, (cTmp_ZBZ)->TPDOC  )  //07
		aadd( aReg, (cTmp_ZBZ)->CONDPG )  //08		//FR - 18/08/2020
		aadd( aReg, (cTmp_ZBZ)->PEDCOM )  //09		//FR - 30/09/2020
		aadd( aReg, (cTmp_ZBZ)->ITEMPC )  //10		//FR - 30/09/2020

		If AllTrim( (cTmp_ZBZ)->M0COD ) == AllTrim( cEmpAnt ) .And. AllTrim( (cTmp_ZBZ)->M0FIL ) == AllTrim( cFilAnt )
			
				aRet := U_HFzClass( (cTmp_ZBZ)->REG, aReg, aNFDiverg, (cTmp_ZBZ)->CONDPG,lEnergia,lCombustXML )   //faz a classificação de uma nota por vez  // ( nReg, aReg )
	
		Else
			
			//XML131CL( xLic, xEmp, xFil, nReg, aReg, cRet, aRet, cArq )
			//aRet := U_XML131CL( aXEmpF[1], (cTmp_ZBZ)->M0COD, alltrim((cTmp_ZBZ)->M0FIL), (cTmp_ZBZ)->REG, aReg, @cRet, @aRet, cArqTxt )
			aRet := StartJob("U_XML131CL",GetEnvServer(),.T., aXEmpF[1], (cTmp_ZBZ)->M0COD, (cTmp_ZBZ)->M0FIL, (cTmp_ZBZ)->REG, aReg, @cRet, @aRet, cArqTxt,(cTmp_ZBZ)->CONDPG,lEnergia,lCombusXML )
			
			if ValType( aRet ) != "A"
			
				aRet := {}
				
				aadd( aRet, "N" )
				aadd( aRet, "Verifique os dados do xml x nota para que a classificação possa ser realizada - U_XML131CL" )
				//aadd( aRet, "Erro Retorno da Rotina Classificação U_XML131CL" )
				aadd( aRet, "0" )
				
			Endif
			
		Endif
		
		if Len( aRet ) >= 2
		
			Conout( aRet[2] )
			cMsg += aRet[2] +CRLF  //+(cTmp_ZBZ)->CHAVE
			
		Endif

		DbSelectArea( cTmp_ZBZ )
		
		If aRet[1] = "N" // oXml == NIL .Or. !Empty(cError) .Or. !Empty(cWarning)
			
			nErr++
			DbSelectArea( cTmp_ZBZ )
			
           	RecLock( cTmp_ZBZ, .F. )
           			(cTmp_ZBZ)->OK := "  "
           			(cTmp_ZBZ)->ST := aRet[3]
 	        (cTmp_ZBZ)->( MsUnLock() )
 	        
		Else
		
			nOk++
            RecLock( cTmp_ZBZ, .F. )
                	(cTmp_ZBZ)->OK := "  "
                	(cTmp_ZBZ)->ST := aRet[3]
            (cTmp_ZBZ)->( MsUnLock() )
            
		EndIf

		lTem := .T.
		
		Endif  						//FR - se prossegue com a classificação
		
	Endif							//Se está com a marca "OK"
	(cTmp_ZBZ)->( dbskip() )		//Avança para o próximo registro	
Enddo

if .Not. lTem

	if lMostra
	
		U_MyAviso("Msg","Nenhum NF-e selecionado para gerar documento !!!!",{"OK"},3)
		
	endif
	
Else

	if lMostra
	
		oMarkBw:oBrowse:Refresh(.T.)
		U_MyAviso("Mensagem",cMsg,{"OK"},3)		//FR - 16/08/2020 - Msg final avisando: Documento gerado com sucesso <num nota / serie>
		
	endif
	
endif

if cStZbi = "0"

	U_HF13MAIL( cArqTxt, .T. , , lEnergia  ) //U_HF13MAIL( "ENERGIA_", .F., "Ocorrencia de XML de Energia",.T. )	
	
else

	U_HF13MAIL( cArqTxt, .F. , , lEnergia )
	
endif

If lEnergia
	U_HF13MAIL( "ENERGIA_", .F., "Ocorrencia de XML de Energia",.T. )
Endif
(cTmp_ZBZ)->( dbgoto( nReg ) )

Return( lRet )


User Function HFATUZBI( nRZbi, cArqExt, xFtp )

Local aArea := GetArea()

Local lAcha   := .F.
Local cSt     := "0"
Local nTot    := 0
Local nErr    := 0
Local nOk     := 0
Local lTemZBI := .F. 		//FR - 17/07/2020

Default xFtp  := Nil

DbSelectArea( xZBI )
(xZBI)->(OrdSetFocus( 3 ))

If nRZbi > 0

	(xZBI)->( DbGoTo( nRZbi ) )
	lAcha := .T.
	
Else

	If (xZBI)->( dbSeek( xFilial( xZBI ) + cArqExt ) )
	
		lAcha := .T.
		
	Else
		lTemZBI := U_fExistZBI(xFtp,,cArqExt)      //U_fExistZBI(xFtp,cJa,cArqExt)
		lAcha   := lTemZBI 
	Endif
	
EndIf

If lAcha

	(cTmp_ZBZ)->( dbgotop() )
	Do While .not. (cTmp_ZBZ)->( Eof() )
	
		nTot++
		
		If (cTmp_ZBZ)->ST == ' ,1'
		
		ElseIF (cTmp_ZBZ)->ST $ '0,9'
		
			nErr++
			
		ElseIF (cTmp_ZBZ)->ST == '2'
		
			nOk++
			
		Endif
		
		(cTmp_ZBZ)->( dbskip() )
		
	EndDo
	
	cSt := "0"
	
	if nTot == nOk
	
		cSt := "2"
		
	elseIF nErr > 0
	
		cSt := "1"
		
	endif
	
Endif

If lAcha .And. cSt <> "0"

	DbSelectArea( xZBI )
	RecLock(xZBI,.F.)
	
	(xZBI)->( FieldPut(FieldPos( xZBI_+"DTCLAS" ), date() ) )  //data da baixa do arquivo via FTP, pega do servidor
	(xZBI)->( FieldPut(FieldPos( xZBI_+"ST" )    , cSt ) )
	(xZBI)->( msunlock() )
	
Endif

RestArea( aArea )

Return( NIL )


//Aqui para chamar a classificação via StartJob
User Function XML131CL( xLic, xEmp, xFil, nReg, aReg, cRet, aRet, cArq, cCondEnerg,lEnergia,lCombusXML )
                  //aXEmpF[1], aXEmpF[2], aXEmpF[3], nReg, aReg, cRet, @aRet

Local aZBO, nPFil, nPCod, nPDes, nPDto, nPHro, nPChv, nPRsf, nPTpo, nPRvo, nPArq, nPFpt, nPExa, nPStt, nPEmp, nPMai
Local aTables	:= { "SB1","SA5","SA7","SA1","SA2" } // incluido apenas para compatibilizar o teste para nao consumir licencas

//xEmp := "99"
//xFil := "01"

cRet := "[F][ ][CLAS_AUT2] Erro - Emp e/ou Fil Vazio"

IF Empty( xEmp ) .or. Empty( xFil )

	cRet := "[F][0][CLAS_AUT2] " + "Filial ("+xEmp+" "+xFil+") vazio: Não Foi Possível estabelecer conexão com a Empresa/Filial."
	conout( cRet )
	
	DelClassIntf()
	
	aRet := {"N",cRet,"0"}
	
	Return( aRet )
	
EndIf

cRet := "[F][ ][CLAS_AUT2] Erro"

RpcClearEnv()
//RpcSetType(3)

aTables	:= { "SB1","SA5","SA7","SA1","SA2" }

IF .NOT. RpcSetEnv( xEmp, xFil,,,"COM",,aTables,.F.,.F.)

	cRet := "[F][0][CLAS_AUT2] " + "Filial ("+xEmp+" "+xFil+"): Não Foi Possível estabelecer conexão com a Empresa/Filial."

	conout( cRet )
	
	//RstMvBuff()
	DelClassIntf()
	
	RpcClearEnv()
	
	//RESET ENVIRONMENT
	
	aRet := {"N",cRet,"0"}
	
	Return( aRet )
	
EndIf

Private xZBZ  	  := GetNewPar("XM_TABXML","ZBZ")      //ECOOOOOOOOOO
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
Private x_Ped_Rec := GetNewPar("XM_PEDREC","N")
Private x_ZBB     := GetNewPar("XM_TABREC","")
Private aHfCloud  := {"0","0"," ","Token",{}}  //CRAUMDE - '0' Não integrar, na posição 1
Private x_Tip_Pre := GetNewPar("XM_TIP_PRE","1")
Private nFormNfe  := Val(GetNewPar("XM_FORMNFE","6")) 
Private nFormCte  := Val(GetNewPar("XM_FORMCTE","6"))
Private cFilUsu   := GetNewPar("XM_FIL_USU","N")
Private cIdEnt    := U_GetIdEnt()
Private cArqTxt   := cArq
Private cTpRt  	  := " "

Default lEnergia  := .F.	//FR - 30/09/2020
conout( "<GESTAOXML> ====> Inicia Classificacao de NF <====" )

aZBO := U_HF13ZBOA()

U_HF13ZPOS( aZBO, @nPFil, @nPCod, @nPDes, @nPDto, @nPHro, @nPChv, @nPRsf, @nPTpo, @nPRvo, @nPArq, @nPFpt, @nPExa, @nPStt, @nPEmp, @nPMai )  

If xLic = 1

	CONOUT("<GESTAOXML> CLASSIFICACAO ====> HFzCLASS VIA JOB <====")
	aRet := U_HFzClass( nReg, aReg, /*aNfDiverg*/ , cCondEnerg )              //HFzClass( nReg, aReg )  //U_HFzClass( (cTmp_ZBZ)->REG, aReg, aNFDiverg, (cTmp_ZBZ)->CONDPG ) 
	
Else

	if nPFil > 0
	
		aZBO[nPFil][4] := xFilial( xZBO )
		
	endif
	
	//nPCod  //Se o código for zero, vai somar 1
	if nPDes > 0
	
		aZBO[nPDes][4] := "[Classificação] CNPJ Sem Licença HF. Empresa "+xEmp+" Filial "+xFil
	
	endif
	if nPDto > 0
	
		aZBO[nPDto][4] := dDataBase
		
	endif
	
	if nPHro > 0
	
		aZBO[nPHro][4] := Time()
		
	endif
	
	if nPChv > 0
	
		aZBO[nPChv][4] := aReg[4]
		
	endif
	
	if nPTpo > 0
	
		aZBO[nPTpo][4] := "1"
		
	endif
	
	If nPArq > 0
	
		aZBO[nPArq][4] := cArqTxt
		
	EndIf
	
	If nPStt > 0
	
		aZBO[nPStt][4] := "0"
		
	EndIf
	
	If nPEmp > 0
	
		aZBO[nPEmp][4] := xEmp
		
	endif
	
	if nPExa > 0
	
		aZBO[nPExa][4] := ""
		
	endif
	
	if nPStt > 0
	
		aZBO[nPStt][4] := "0"
		
	EndIf
	
	//nPFil, nPCod, nPDes, nPDto, nPHro, nPChv, nPRsf, nPTpo, nPRvo, nPArq, nPFpt, nPStt, nPEmp, nPMai
	if U_HF13ZBOG( .F., 4, xFilial(xZBO)+"1"+AllTrim(aReg[4])+cArqTxt, aZBO )
	
		//Foi
		
	endif
	
	cRet := "[F][0][CLAS_AUT2] " + "Filial ("+xEmp+" "+xFil+"): Sem Licença HF."
	aRet := {"N",cRet,"0"}
	
Endif

conout( "<GESTAOXML> =====> Finalizou Classificacao de NF <====" )

RstMvBuff()

DelClassIntf()

RpcClearEnv()

//RESET ENVIRONMENT

Return( aRet )


//Classificar mesmo
User Function HFzClass( nReg, aReg, aNFDiverg, cCondEnerg, lEnergia,lCombustXML )
Local aRet[3]
Local cOri   := ""
Local lRet   := .T.
Local lCor   := .F.
Local nIte   := 0
Local cError   := ""
Local cWarning := ""
Local cMsg     := ""
Local aLog     := {}
Local nX       := 0
Local xRet103  	  := .F.
//Local lXMLPEAMA   := ExistBlock( "XMLPEAMA" ), aPEAma, lAmaPe := .F. //nordsonAmarraCof
//Local lXMLPEVAL   := .F. //ExistBlock( "XMLPEVAL" )
//Local lXMLPEREG   := .F. //ExistBlock( "XMLPEREG" )
//Local lXMLPEATU   := .F. //ExistBlock( "XMLPEATU" )
//Local lXMLPE2UM   := ExistBlock( "XMLPE2UM" )
//Local lXMLPEITE   := ExistBlock( "XMLPEITE" )
Local aZBO, nPFil, nPCod, nPDes, nPDto, nPHro, nPChv, nPRsf, nPTpo, nPRvo, nPArq, nPFpt, nPExa, nPStt, nPEmp, nPMai
//Local lEnergia    := .F. 		//FR - 18/08/2020
Local aParamAux   := {}			//FR - 25/09/2020
//Local oProcess	  := Nil		//FR - 30/09/2020

Private cTagFci   := ""
Private cCodFci   := ""
Private lNossoCod := .F.
Private cCnpjEmi  := ""
Private cCodEmit  := ""
Private cLojaEmit := ""
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
Private lAglCTE	  := .F. //( GetNewPar('XM_AGLMCTE') == 'S' ) //Parametro se aglutina multiplos CTE ou nao
Private cIdEnt    := U_GetIdEnt()
//Estes aqui de riba é para o legado, vai que o cabra use no ponto de entrada.

Private oXml
Private oDet, oOri
Private cProduto    := ""
PRIVATE lMsErroAuto := .F.    // variável que define que o help deve ser gravado no arquivo de log e que as informações estão vindo à partir da rotina automática.
Private lMsHelpAuto	:= .T.    // força a gravação das informações de erro em array para manipulação da gravação ao invés de gravar direto no arquivo temporário 
Private lAutoErrNoFile := .T. 
Private aCabec      := {}
Private aItens      := {}
Private nFormNfE    := Val(GetNewPar("XM_FORMNFE","6"))
Private nFormSer    := Val(GetNewPar("XM_FORMSER","0")) ///Incluido 19/01/2016
Private cEspecNfe   := PADR(GetNewPar("XM_ESP_NFE","SPED"),5)
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
Private cUsaDvg     := GetNewPar("XM_USADVG","N") 	//FR 19/05/2020 - indica de está ativada a verificação de divergências Sim / Não

//FR 03/11/2020
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
//FR 03/11/2020
Default aNFDiverg   := NIL							//FR - 18/08/2020
Default cCondEnerg  := ""							//FR - 18/08/2020
Default lEnergia    := .F.							//FR - 30/09/2020
aZBO := U_HF13ZBOA()

U_HF13ZPOS( aZBO, @nPFil, @nPCod, @nPDes, @nPDto, @nPHro, @nPChv, @nPRsf, @nPTpo, @nPRvo, @nPArq, @nPFpt, @nPExa, @nPStt, @nPEmp, @nPMai )  

aRet[1] := ""
aRet[2] := ""
aRet[3] := ""

aCabec	:=	{}
aItens	:=	{}
nIte	:=	0 
nIte++

//lEnergia := U_fVerXMLEnerg( , , ,.T.,oProcess)  //U_fVerXMLEnerg(aCab,aIte,lSoCheck)
While .T.

	//Inclusao do ExecAuto, quando nao for para aglutinar se a variavel for .F.
	lMsErroAuto	:= .F.
	
	DbSelectArea( xZBZ )
	
	(xZBZ)->( dbGoTo( nReg ) )
	
	cError := ""
	cWarning := ""
	
	oXml := XmlParser((xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML"))), "_", @cError, @cWarning )
	
	if Empty( oXml )
	
		aRet[1] := "N"
		aRet[2] := "Não foi possivel classificar o xml, pois seu status esta como resumido. Por favor verificar"
		aRet[3] := "0"
		Exit
	
	endif

	DbSelectArea( xZBZ )
	cMsg := ""
	//cCondEnerg -> a condição de pagamento aqui vale tanto para Energia qto para classificação de XML combustível
	If !addCabec( aReg, @cMsg, cCondEnerg )		//FR - 18/08/2020 
	
    	aRet[1] := "N"
		aRet[2] := cMsg+" "+aReg[04]
		aRet[3] := "0"
		Exit
		
	EndIf

	cMsg := ""
	
    If !addItens( @nIte, @cMsg, lEnergia, aReg[09], aReg[10], nReg,lCombustXML  )
    
    	aRet[1] := "N"
		aRet[2] := "NF: "+aReg[01]+" / "+aReg[02]+" "+cMsg+" "+aReg[04]
		aRet[3] := "0"
		
		Exit
		
    Endif

	//Inclusao do ExecAuto, quando nao for para aglutinar se a variavel for .F.
	lMsErroAuto	:= .F. 
	xRet103     := .F.
	//--------------------------------------------------------------------//
	//FR - 25/09/2020:
	// Altera o parâmetro de mostrar lançamento contábil,
	// mas continua contabilizando online caso esteja definido assim
	// só não irá mostrar o lançamento por se tratar de execauto, 
	// senão ficará mostrando a cada nota gerada
	//---------------------------------------------------------------------//
	If lEnergia
		//para manipular o pergunte MTA103
		aAdd(aParamAux, {"MV_PAR01", 2}) //-- Mostra Lanc. Contabil? 1 = Sim, 2 = Não
		//aAdd(aParamAux, {"MV_PAR06", 1}) //-- Contabilizacao Online? 1 = Sim, 2 = Não
		cArqTXT  := "ENERGIA_NF_" + Alltrim(aCabec[3][2]) + "-" + Alltrim(aCabec[4][2]) + "_.TXT"  //FR 23/11/2020 //Nome ficará assim: ENERGIA_NF_<num nf> - <serie>_.TXT
	Endif
	//FR - 25/09/2020
	CONOUT(" <GESTAOXML> POSICIONADO NO XML ===> " + (xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA"))) + " <===")
	
	If (xZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF"))) = "S"
		
		xRet103	:=	MSExecAuto({|x,y,z| mata103(x,y,z)},aCabec,aItens,4, ,1)  //só classificar
	
	Else
	
					
		CONOUT("<GESTAOXML> BUSCA CHAVE ===> " + (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))) + aCabec[9,2] + " <===" )  
		
		SF1->(OrdSetFocus(8))   		//Ordem 8 -> F1_FILIAL + F1_CHVNFE
		lExistSF1 := SF1->(DbSeek( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))) + aCabec[9,2] ))  //Verifica se a nota já foi incluida anteriormente
	    
	    If !lExistSF1
			If !lEnergia
				xRet103	:=	MSExecAuto({|x,y,z| mata103(x,y,z)},aCabec,aItens,3, ,1)  //Inclusão
			Else
				//3-Inclusão / 4-Classificação / 5-Exclusão
				//xRet103 := MSExecAuto({|x,y,z,k,a,b| MATA103(x,y,z,,,,k,a,,,b)},aCab,aItens,nOpc,aParamAux,aItensRat,aCodRet)	
				//FR - 25/09/2020 - Precisa do aParamaux para a Kroma, pois eles contabilizam online, porém não
				//mostrarei a tela de Contabilização a cada nota gerada, pois é via Execauto		
				xRet103 := MSExecAuto({|x,y,z,k,a,b| MATA103(x,y,z,,,,k,a,,,b)},aCabec,aItens,3,aParamAux,,)	//Inclusão
			Endif		
			
			CONOUT(" <GESTAOXML> ===> Executando ...EXECAUTO CLASSIFICACAO NF <===")
			
		ElseIF Empty(SF1->F1_STATUS)		//se encontrou a chave da nota, verificar se está como pré-nota e então classifica
		
			If aCabec[6,2] == SF1->F1_FORNECE .and. aCabec[7,2] == SF1->F1_LOJA 
		
				DbSelectArea( xZBZ )
				(xZBZ)->( dbGoTo( nReg ) )
				
				Reclock(xZBZ,.F.)
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PRENF") , 'S' )) //Nota ja incluida anteriormente. Está apta a classificar
				(xZBZ)->( MsUnlock() )
				
				xRet103	:=	MSExecAuto({|x,y,z| mata103(x,y,z)},aCabec,aItens,4, ,1)  //só classificar
				
			Elseif aCabec[6,2] != SF1->F1_FORNECE .or. aCabec[7,2] != SF1->F1_LOJA
			
				aRet[1] := "N"
				aRet[2] := "Nota Incluida Anteriormente Com Dados Divergentes do Xml. Verifique inicialmente o fornecedor..."
				aRet[3] := "0"
				
				//Exit   //FR 10/07/2020
				
			Endif
			
		Elseif !Empty(SF1->F1_STATUS)		//FR - para gravar o log qdo encontrar a nota já incluída anteriormente
			
			aRet[1] := "S"                 //FR - marcar "S" para não enviar o email novamente para uma nota que já existe na base de dados
			aRet[2] := "Nota Ja Existe Na Base de Dados: "+aCabec[3][2]+" Serie: "+ aCabec[4][2]
			aRet[3] := "0"			
			
			CONOUT("<GESTAOXML> NOTA JA EXISTE NA BASE DE DADOS: " + aCabec[3][2] + " Serie: " + aCabec[4][2] + " <====")
		Endif		
	
	Endif
	
	aLog    := {}
	nX      := 0 
	cConout := ""
	
	If lMsErroAuto
		//MostraErro()  //como colocar para exibir ?
		
		CONOUT(" <GESTAOXML> ===> EXECAUTO CLASSIFICACAO NF ERRO !!! <===")
		cConout := ""
		aLog := GetAutoGRLog()
		For nX := 1 To Len(aLog)
			If !"---" $ aLog[nX]
				cConout += aLog[nX]+" ; "
			Endif
		Next nX
				
		CONOUT(" <GESTAOXML> LOG DO ERRO ===> " + cConout + " <===")
		
		
    	aRet[1] := "N"
		aRet[2] := "Erro no Execauto de classif. NF: "+aReg[01]+" Serie: "+aReg[02] + "-> " + cConout //"[Execauto]. Ver Cadastros. Documento Não Foi Gerado Chave "+aReg[04]
		aRet[3] := "0"
	
		DbSelectArea( xZBZ )
		(xZBZ)->( dbGoTo( nReg ) )
		
		cPrNf := U_HFSTXMUN( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))),;
		               (xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA"))),;
		               (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE"))),;
		               (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR")))+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR"))) ,;
		               (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC"))),;
		               (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO"))),;
		               (xZBZ)->(FieldGet(FieldPos(xZBZ_+"DOCCTE"))),;
		               (xZBZ)->(Recno()),.T. )
		               
		If AllTrim(cPrNf) $ "N"
		
			lMsErroAuto := .F.
			
		endif
		
	endif

	If !lMsErroAuto .and. xRet103
	
        DbSelectArea( xZBZ )
        (xZBZ)->( dbGoTo( nReg ) )
        
        Reclock(xZBZ,.F.)
       	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PRENF") , Iif(Empty(SF1->F1_STATUS),'S','N')  ))  //'S'
      	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPDOC") , SF1->F1_TIPO ))
       	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CODFOR"), aCabec[6][2] ))
       	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"LOJFOR"), aCabec[7][2] ))
        (xZBZ)->(FieldPut(FieldPos(xZBZ_+"DOCCTE"), aCabec[3][2] ))
        (xZBZ)->( MsUnlock() ) 						//FR - 08/09/2020
	
		If (xZBZ)->(FieldPos(xZBZ_+"MANIF")) > 0
		
			cOri := "1"
			
			If (xZBZ)->(FieldPos(xZBZ_+"IMPORT")) > 0
			
				cOri := AllTrim( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"IMPORT"))) )
				
				If empty( cOri )
				
					cOri := "1"
					
				Endif
				
			Endif
			//(xZBZ)->(FieldPut(FieldPos(xZBZ_+"MANIF"), U_MANIFXML( AllTrim( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))) ), .F., cOri ) ))
			
			//FR - 08/09/2020
			cManif := U_MANIFXML( AllTrim( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))) ), .F., cOri )
			If Reclock(xZBZ,.F.)					//FR coloquei um "if" aqui, pois quando volta da função U_MANIF deu erro de reclock
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"MANIF"), cManif ))
				(xZBZ)->( MsUnlock() ) 
			Endif						
			//FR - 08/09/2020
		
		EndIf
		
		If Reclock(xZBZ,.F.)
			If !lEnergia 		//FR - 18/08/2020
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"COMBUS"), "S" ))
			Elseif lCombustXML	
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"COMBUS"), "C" ))	//FR - 05/08/2022 - PROJETO POLITEC - CLASSIFICAÇÃO ROBÓTICA DE NFs COMBUSTÍVEIS (VIA XML APENAS)
			Else	
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"COMBUS"), "E" ))
			Endif
			(xZBZ)->( MsUnlock() )			
  		Endif
        //(xZBZ)->( MsUnlock() ) 	//FR - 08/09/2020 - não precisa, já está acima
        
        //-----------------------------------------------------------------------------------------------------------------------------------------------------//
        //FR GRAVA LOJA
		If xRet103
			
			//CONOUT(" <AGUASBR> CLASSIFICACAO OK! -> TRATA LOJA ====> " + (xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA"))) + " <====")
			
			//fGRAVALOJA( (cTmp_ZBZ)->M0FIL,(cTmp_ZBZ)->CHAVE, (cTmp_ZBZ)->NOTA, (cTmp_ZBZ)->SERIE, (cTmp_ZBZ)->CODFOR, (cTmp_ZBZ)->LOJFOR, (cTmp_ZBZ)->TPDOC  )
			fGRAVALOJA( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))),;
			            (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))),;
			            (xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA"))),;
			            (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE"))),;
			            (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR"))),;
			            (xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR"))),;
			            (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC")));
			              )		
			If lEnergia
				xCC    := ""
				nPosCC := 0
				nPosCC := ASCAN(aItens[1], { |p| UPPER(alltrim(p[1])) == "D1_CC" }) //nPosCC := aScan( aItens, { |x| x[1] == "D1_CC" } )
				If nPosCC > 0
					xCC := aItens[1][nPosCC][2]

					fGRAVACC( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))),;
							(xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))),;
							(xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA"))),;
							(xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE"))),;
							(xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR"))),;
							(xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR"))),;
							(xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC"))),;
							xCC;
							)
				Endif				
			Endif			
		Endif				
		//FR GRAVA LOJA
        //-----------------------------------------------------------------------------------------------------------------------------------------------------//
        //----------------------------------------------------------------------------------//
        //FR - 18/05/2020 - tratativa para mensagem de divergência - Divergência NF x XML:  
        //----------------------------------------------------------------------------------//
        cMsgDiverg := ""
        
        If cUsaDvg == "S"
        	If !lEnergia
	        	cMsgDiverg := ""
	        	nDiverg    := 0
	        	If aNFDiverg <> Nil
	        		nDiverg    := aScan( aNFDiverg, { |x| x[5] = (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))) } )   //FR - pesquisa se a chave existe no array de notas com divergência
					If nDiverg > 0
						cMsgDiverg := " - COM DIVERGÊNCIA(S)"  //FR - caso o usuário tenha escolhido gerar com divergência mesmo assim, então será adicionada esta mensagem para informa-lo ao final.
				    Endif
			    Endif
		    Endif
		Endif

		If lEnergia
			aRet[1] := "N"		//flag = "N" faz enviar por email, as notas geradas de energia
		Elseif lCombustXML
			aRet[1] := "N"		//flag = "N" faz enviar por email, as notas geradas de combustível (aguas br não entra aqui)
		Else
    		aRet[1] := "S"		//flag = "S" não envia email Aguas BR pediu para qdo for sucesso não precisa enviar por email
		Endif
		aRet[2] := "Documento Gerado com Sucesso: "+aCabec[3][2] + " / " + aCabec[4][2] + cMsgDiverg
		aRet[3] := Iif(Empty(SF1->F1_STATUS),'1','2')

		
		lCor   := .F.       
		//FR - 23/11/2020
		If !lEnergia		
			(xZBO)->( dbSetOrder( 4 ) )
		
			If (xZBO)->( dbSeek( xFilial(xZBO)+"1"+AllTrim(aReg[4])+cArqTxt ) )
				
				If (xZBO)->( FieldGet( FieldPos( xZBO_+"ST" ) ) ) <> "2"
					
					lCor   := .T.
					
				EndIF
				
			Endif
		Endif 		//lEnergia 		
		//FR - 23/11/2020
		
		(xZBO)->( dbSetOrder( 1 ) )
		
    Endif     //do if lMsErroAuto    
    
    Exit  
    
EndDo

//if aRet[1] = "N" .or. lCor  //Em 07/01/19, pediu-se para sair no relatório os que deram certo, então tem gravar o LOG
	if nPFil > 0
	
		aZBO[nPFil][4] := xFilial( xZBO )
		
	endif
	
	//nPCod  //Se o código for zero, vai somar 1
	if nPDes > 0
	
		aZBO[nPDes][4] := aRet[2] //"Erro no execauto de classificação NF "+aReg[01]+" Serie "+aReg[02]
	
	endif
	
	if .NOT. lCor
	    //FR - 23/11/2020 - Os campos abaixo somente serão gravados qdo não for nf de Energia, senão sobreporá a primeira gravação já efetuada
	    if nPDto > 0    			//dt ocorrência, em caso de nf energia, grava aqui a data emissão da nf
			If !lEnergia
				aZBO[nPDto][4] := dDataBase
			Else
				If Len(aCabec) > 0
					aZBO[nPDto][4] := aCabec[5][2]		//FR - 23/11/2020 - dt emissão NF para notas de energia
				Else 
					aZBO[nPDto][4] := dDataBase
				Endif 
			Endif
				
		endif		
		//FR - 23/11/2020
		
		if nPHro > 0 				//hr ocorrência
			
			aZBO[nPHro][4] := Time()
				
		endif
			
		if nPChv > 0				//chave
			
			aZBO[nPChv][4] := aReg[4]
				
		endif
			
		if nPTpo > 0 				//tipo ocorrência
			
			aZBO[nPTpo][4] := "1"
				
		endif			
			
		If nPArq > 0				//nome arquivo txt
			
			aZBO[nPArq][4] := cArqTxt
				
		EndIf
				
		If nPExa > 0
		
			aZBO[nPExa][4] := ""
			
			If lMsErroAuto
			
				aLog := GetAutoGRLog()	                  //Efetua o Tratamento para validar se o arquivo de Log Já Existe
				
				For nX := 1 To Len(aLog)
				
					aZBO[nPExa][4] += aLog[nX]+CHR(13)+CHR(10)    //log do erro
					
				Next nX
				
			Endif
			
		EndIf
		
	EndIF
	
	If nPStt > 0
	
		If aRet[1] = "S"  //Classificado direto e reto
		
			aZBO[nPStt][4] := "0" 			//status
			
		Else
		
			aZBO[nPStt][4] := iif( lCor, "2", "1" )
			
		Endif
		
	EndIf
	
	If aRet[1] = "S"  //Marcar como email enviado para não enviar novamente
	
		If nPMai > 0
		
			aZBO[nPMai][4] := "2"
			
		EndIf
		
	Else
		aZBO[nPMai][4] := " " //FR - 10/07/2020 - sem ação para log mas envia email aos envolvidos (só envia se o campo ZBO_MAIL estiver = '' ou '1'
	Endif
	
	//nPFil, nPCod, nPDes, nPDto, nPHro, nPChv, nPRsf, nPTpo, nPRvo, nPArq, nPFpt, nPExa, nPStt, nPEmp, nPMai
	cChaveNF := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE")))
	U_HF13ZBOG( .F., 4, xFilial(xZBO)+"1"+AllTrim(aReg[4])+cArqTxt, aZBO, cChaveNF  )   //GRAVA ZBO FR 13/07/2020  

	U_HF13MAIL( "COMBUSTIVEIS_", .F., "Ocorrencia de XML de COMBUSTIVEIS",lEnergia,lCombustXML )	//FR - 05/08/2022 - PROJETO POLITEC 

Return( aRet )


Static Function addCabec( aReg, cMsg,cCondEnerg )

Local lRet        := .T.
Local cDocXMl     := aReg[01]
Local cSerXml     := aReg[02]
Local dDataEntr   := aReg[03]
Local cChaveXml   := AllTrim( aReg[04] )
Local cCodFor     := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR")))
Local cLojFor     := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR")))
Private lSerEmp   := .NOT. Empty( AllTrim(GetNewPar("XM_SEREMP","")) )  //FR 20/05/2020 - esta variável não estava declarada
Private cEspecNfe := PADR(GetNewPar("XM_ESP_NFE","SPED"),5)				//FR
Private cEspecXML := cEspecNfe                                          //FR

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

If ! ChecaFor( @cCodFor, @cLojFor, (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))), @cMsg )

	cMsg := "NF "+cDocXMl+"/"+cSerXml+" "+cMsg
	Return( .F. )
	
Endif

aadd(aCabec,{"F1_TIPO"   ,Iif(Empty( aReg[07] ),"N",AllTrim( aReg[07] ))})
aadd(aCabec,{"F1_FORMUL" ,"N"})
aadd(aCabec,{"F1_DOC"    ,cDocXMl})
aadd(aCabec,{"F1_SERIE"  ,cSerXml})
aadd(aCabec,{"F1_EMISSAO",dDataEntr})
aadd(aCabec,{"F1_FORNECE",cCodFor})
aadd(aCabec,{"F1_LOJA"   ,cLojFor})
aadd(aCabec,{"F1_ESPECIE",cEspecXML})
aadd(aCabec,{"F1_CHVNFE" ,cChaveXml })
If !Empty(cCondEnerg)
	aadd(aCabec,{"F1_COND" ,cCondEnerg })
Endif

If Empty(cCodFor)  // .OR. Empty(cLojFor)

	cMsg := "F "+cDocXMl+"/"+cSerXml+" não foi encontrado o Fornecedor no sistema Protheus, favor cadastrar o mesmo no cadastro de fornecedor e vincular ao XML."
	lRet := .F.
	
EndIF

Return( lRet )


Static Function ChecaFor( cCodFor, cLojFor, cCNPJFor, cMsg )

Local lRet := .T.
Local aArea := GetArea()

DbSelectArea( "SA2" )
SA2->(DbSetOrder( 1 ))
if ! SA2->( DbSeek( xFilial( "SA2" ) + cCodFor + cLojFor ) )

	SA2->(DbSetOrder( 3 ))
	
	if ! SA2->( DbSeek( xFilial( "SA2" ) + cCNPJFor ) )
	
		cMsg := " não encontrado Fornecedor no Protheus, favor cadastrar o mesmo no cadastro de fornecedor."
		lRet := .F.
		
	Else
	
		cCodFor := SA2->A2_COD
		cLojFor := SA2->A2_LOJA
		
		DbSelectArea( xZBZ )
		RecLock( xZBZ, .F. )
		(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CODFOR"), cCodFor ))
		(xZBZ)->(FieldPut(FieldPos(xZBZ_+"LOJFOR"), cLojFor ))
		(xZBZ)->( MsUnLock() )
		
	Endif
	
EndIF

RestArea( aArea )

Return( lRet )


Static Function addItens( nIte, cMsg, lEnergia, cPedEnerg, cItpedEnerg, nRegZBZ,lCombustXML)

Local aProdOk   := {}
Local aProdNo   := {}
Local aProdVl   := {}
//Local aProdZr   := {}
//Local nTamProd  := TAMSX3("B1_COD")[1]
Local lFound    := .F.
Local lEntro    := .F.
//Local lRet      := .T.
Local oDet, i
Local aLinha := {}
Local aItem  := {}
Local cWhere, cCampos, cTabela, cOrder
Local lRetorno    := .T.
//Local lXMLPEAMA   := ExistBlock( "XMLPEAMA" ), aPEAma, lAmaPe := .F. //nordsonAmarraCof
//Local lXMLPEVAL   := .F. 
//Local lXMLPEREG   := .F. 
//Local lXMLPEATU   := .F. 
Local lXMLPE2UM   := ExistBlock( "XMLPE2UM" )
Local lXMLPEITE   := ExistBlock( "XMLPEITE" )
//Local lXMLPELOK   := .F. //ExistBlock( "XMLPELOK" )
//Local lXMLPETOK   := .F. //ExistBlock( "XMLPETOK" )
//Local lLOk 		  := .F.
//Local lTOk 		  := .F.
Local nTotDet     := 0
//Local oProcess	  := Nil		//FR - 30/09/2020
Local lTemZBC     := .F.			//FR - 28/10/2021
Local cDescProd   := ""				//FR - 28/10/2021
Local cNcm		  := ""
Local cAutoZBC    := GetNewPar("XM_ZBCAUTO" , "N") //FR - 28/10/2021

//FR 03/11/2020
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
//FR 03/11/2020

//lEnergia := U_fVerXMLEnerg( , , ,.T.,oProcess)  //U_fVerXMLEnerg(aCab,aIte,lSoCheck)
Default lEnergia := .F.			//FR - 30/09/2020

if Type("oXml:_NFEPROC:_NFE:_INFNFE:_DET") <> "U"

	oDet := oXml:_NFEPROC:_NFE:_INFNFE:_DET
	oDet := IIf(ValType(oDet)=="O",{oDet},oDet)
	
else

	oDet := {}
	
endif

If Type("oXml:_NFEPROC:_NFE:_INFNFE:_DET") == "A"

	aItem := oXml:_NFEPROC:_NFE:_INFNFE:_DET
	
Else

	aItem := {oXml:_NFEPROC:_NFE:_INFNFE:_DET}
	
EndIf

nD1Item := 1

nTotDet := Len(oDet)
For i := 1 To nTotDet

	cProduto  := ""
	cCc       := ""
	cTes      := ""
	DbSelectArea( xZBZ )
	(xZBZ)->( dbGoTo( nRegZBZ ) )
	cCodEmit  := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR")))
	cLojaEmit := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR")))
	
	//FR - 28/10/2021
	If cAutoZBC == "S" //se o cadastro da ZBC é automatizado
		cDescProd := Alltrim(oDet[i]:_Prod:_XPROD:TEXT)		//VER SE EXISTE ALGUM PRODUTO NA BASE COM A DESCRIÇÃO (B1_DESC) E A PARTIR DAÍ, CAPTAR ESSE CÓDIGO B1_COD
		cNcm	  := Alltrim(oDet[i]:_Prod:_NCM:TEXT)
		cProduto  := U_fVerSB1D(cDescProd,cNcm)
		If !Empty(cProduto)
			lTemZBC   := U_fTemZBC(cCodEmit,cLojaEmit,cProduto,"C")  //fTemZBC(cCodEmit,cLojaEmit,cProd,cTp) 
		Else
			cMsg += " não foi encontrado o produto "+ Alltrim(oDet[i]:_Prod:_XPROD:TEXT) + " no sistema Protheus. Favor cadastrar o mesmo no cadastro de produto." 
		Endif 
		
	Endif 
	if empty( cCodEmit )
	
		cCodEmit  := Posicione("SA2",3,xFilial("SA2")+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))),"A2_COD")
		cLojaEmit := Posicione("SA2",3,xFilial("SA2")+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))),"A2_LOJA")
	
	endif

	cAliasZBC := GetNextAlias()
	nVz := len(aItem)

	cTabela:= "%"+RetSqlName(xZBC)+"%"
	cWhere := "%(ZBC."+xZBC_+"CODFOR = '"+cCodEmit+"' "
	cWhere += "AND ZBC."+xZBC_+"LOJFOR = '"+cLojaEmit+"' "
	//FR - 30/09/2020
	If lEnergia
		cWhere += "AND ZBC."+xZBC_+"TIPO = 'E' "
	ElseIF lCombustXML
		cWhere += "AND ZBC."+xZBC_+"PROD = '"+ cProduto + "' "
	Endif
	//FR - 30/09/2020
	cWhere += " )%"
	cCampos	:="%"+xZBC_+"FILIAL, "
	cCampos	+= xZBC_+"CODFOR,"+xZBC_+"LOJFOR, "
	cCampos	+= xZBC_+"PROD, "+xZBC_+"CC, "+xZBC_+"TES, ZBC.R_E_C_N_O_"
	cCampos	+=	"%"
	cOrder := "%"+xZBC_+"FILIAL,"+xZBC_+"CODFOR,"+xZBC_+"LOJFOR,"+xZBC_+"PROD%"

	BeginSql Alias cAliasZBC

	SELECT %Exp:cCampos%
			FROM %Exp:cTabela% ZBC
			WHERE ZBC.%notdel%
		 	AND %Exp:cWhere%
			ORDER BY %Exp:cOrder%
	EndSql

	DbSelectArea(cAliasZBC)
	Dbgotop()
	lFound := .F.
	lEntro := .F.
	
	cKeySa5:= xFilial("ZBC")+cCodEmit+cLojaEmit  //+AllTrim(TrocaAspas( oDet[i]:_Prod:_CPROD:TEXT )) Acabaram com o Campo de produto do fornecedor
	
	While !(cAliasZBC)->(EOF())
	
		cKeyTMP := (cAliasZBC)->(FieldGet(FieldPos(xZBC_+"FILIAL")))+;
		           (cAliasZBC)->(FieldGet(FieldPos(xZBC_+"CODFOR")))+;
		           (cAliasZBC)->(FieldGet(FieldPos(xZBC_+"LOJFOR")))   //+(cAliasZBC)->ZBC_CODPRO
	
		lEntro := .T.
		
		If 	AllTrim(cKeySa5) == AllTrim(cKeyTMP)
		
	  		lFound := .T.
	   		Exit
	   		
	   	Endif
	   	
	   	(cAliasZBC)->(DbSkip())
	   	
	Enddo

	If lFound
	
		cProduto := (cAliasZBC)->(FieldGet(FieldPos(xZBC_+"PROD")))
		cCc      := (cAliasZBC)->(FieldGet(FieldPos(xZBC_+"CC")))
		cTes     := (cAliasZBC)->(FieldGet(FieldPos(xZBC_+"TES")))

		if .not. empty( cProduto )
		
	 		if SB1->( DbSeek(xFilial("SB1")+cProduto) )
	 		
				If SB1->( FieldGet(FieldPos("B1_MSBLQL")) ) == "1"
				
					lRetorno := .F.
					cMsg += " produto "+cProduto+" Bloqueado no Protheus."
					
 				EndIf
 				
	 		Else
	 		
				lRetorno := .F.
				cMsg += " não foi encontrado o produto "+cProduto+" no sistema Protheus. Favor cadastrar o mesmo no cadastro de produto."
 			
 			endif
 			
		Else
		
			lRetorno := .F.
			cMsg += " não foi encontrado DE/PARA produto noProtheus. Cadastrar na rotina de Classific.Aut.NF, Tabela [" + xZBC + "]"	//FR - 18/08/2020
		
		EndIf

		if lRetorno
		
			aadd(aProdOk,{TrocaAspas( oDet[i]:_Prod:_CPROD:TEXT ),oDet[i]:_Prod:_XPROD:TEXT} )
			
		endif

		if .not. empty( cTes )
		
			SF4->( dbSetOrder( 1 ) )
			
	 		if SF4->( DbSeek(xFilial("SF4")+cTes) )
	 		
				If SF4->( FieldGet(FieldPos("F4_MSBLQL")) ) == "1"
				
					lRetorno := .F.
					
					cMsg += " TES "+cTes+" Bloqueado no Protheus."
					
 				EndIf
 				
	 		Else
	 		
				lRetorno := .F.
				cMsg += " não foi encontrado o TES: "+cTes+" no sistema Protheus."
				
 			endif
 			
		Else
		
			lRetorno := .F.
			cMsg += " não encontrado DE/PARA TES no Protheus. Cadastrar na rotina de Classific.Aut.NF, Tabela ("+ xZBC +")"  //FR - 18/08/2020
		
		EndIf

		if .not. empty( cCc )
		
			CTT->( dbSetOrder( 1 ) )
			
	 		if CTT->( DbSeek(xFilial("CTT")+cCc) )
	 		
				If CTT->( FieldGet(FieldPos("CTT_BLOQ")) ) == "1"
				
					lRetorno := .F.
					cMsg += " Centro de Custo "+cCc+" Bloqueado no Protheus."
					
 				EndIf
 				
	 		Else
	 		
				lRetorno := .F.
				cMsg += " não encontrado o Centro de Custo "+cCc+" no Protheus."
				
 			endif
 			
		Else
		
			lRetorno := .F.
			cMsg += " não encontrado DE/PARA Centro De Custo no Protheus. Cadastrar na rotina de Classific.Aut.NF, Tab: (" + xZBC + ")"  //FR - 18/08/2020
		
		EndIf

	Else
	
		lRetorno := .F.
		cProduto := ""
		
		aadd(aProdNo,{TrocaAspas( oDet[i]:_Prod:_CPROD:TEXT ),oDet[i]:_Prod:_XPROD:TEXT} )
		
		if lEntro
					
			cMsg += " não encontrado o DE/PARA produto no Protheus. Cadastrar na rotina de Classific.Aut.NF, Tab: ("+ xZBC + ")"
	
		Else
		
			cMsg := " não encontrada amarração Fornecedor. Cadastrar na rotina de Classific.Aut.NF., Tab: (" + xZBC + ")"  //FR - 18/08/2020
		
		Endif
		
	EndIf  //If lFound -> se lFound = .F., o  lRetorno tb será .F. , então, não adicionou os itens e não prossegue com a classificação da nf

	DbCloseArea()
	
	if !lRetorno
	
		Exit
		
	endif
	
	//Até aqui é igua no veramarra

	cUm    := "  "
	
	cTagFci:= "oDet["+AllTrim(Str(i))+"]:_Prod:_UCOM:TEXT"
	
	if Type(cTagFci) <> "U"
	
		cUm := oDet[i]:_Prod:_UCOM:TEXT
		
	endif
	
	nQuant := VAL(oDet[i]:_Prod:_QCOM:TEXT)
	nVunit := VAL(oDet[i]:_Prod:_VUNCOM:TEXT)
	nTotal := VAL(oDet[i]:_Prod:_VPROD:TEXT)
	nVdesc := 0
	If !lEnergia
		cTagAux:= "oDet["+Alltrim(STR(i))+"]:_PROD:_VDESC:TEXT"	
		
		If Type( cTagAux ) <> "U" 		
			nVdesc := Val( oDet[i]:_Prod:_VDESC:TEXT )			
		Endif
    Else
    	//cTagAux   := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_COBR:_FAT:_VDESC:TEXT" 
		//cDesc     := &(cTagAux) 
		nVdesc    := 0 //Val(cDesc)
    Endif

    cCodFci := ""
    
    cTagFci := "oDet["+AllTrim(Str(i))+"]:_PROD:_NFCI:TEXT"  //CONFIRMAR ESTA TAG
    
    If Type(cTagFci) <> "U"
    
		cCodFci:= &cTagFci
		
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
				
				lRetorno := .F.
				
				cMsg += AllTrim(StrZero(nD1Item,4))+" Erro ao retornar conversão de unidades pelo PE XMLPE2UM"
			
			else
			
		 		if ABS( Round((nQuant * nVunit),2) - Round(nTotal, 2) ) >= 0.02 .And.;
				   nVunit <> VAL(oDet[i]:_Prod:_VUNCOM:TEXT) //por causa do problema de arredondar e truncar com valor unitário com 3 casas decimais (Itambé)
					
					aadd(aProdVl,{oDet[i]:_Prod:_CPROD:TEXT, cUm, nQuant, nVunit, nTotal, (nQuant * nVunit) } )
					
					lRetorno := .F.
											
					cMsg += AllTrim(StrZero(nD1Item,4))+" Erro ao retornar conversão de unidades pelo PE XMLPE2UM"
				
				endif
				
			endif
			
	 	endif

 	EndIf

	cXped     := Space(6) //Privates e fazer as bagaceiras da Carajas, tem o oXml private também para usar la
	cXItemPed := ""

	aadd(aLinha,{"D1_ITEM"  ,StrZero(nD1Item,4)              ,Nil})
	aadd(aLinha,{"D1_COD"   ,cProduto               		 ,Nil})
	
	if SB1->( DbSeek(xFilial("SB1")+cProduto) )
		aadd(aLinha,{"D1_UM",SB1->B1_UM               		 ,Nil})
	Endif
	
	aadd(aLinha,{"D1_QUANT" ,nQuant							 ,Nil})
	aadd(aLinha,{"D1_VUNIT" ,nVunit							 ,Nil})
	aadd(aLinha,{"D1_TOTAL" ,nTotal							 ,Nil})
	
	if nVdesc > 0
		aadd(aLinha,{"D1_VALDESC" ,nVdesc					 ,Nil})
	endif
	
	If .Not. Empty(cCodFci)
		aadd(aLinha,{"D1_FCICOD",cCodFci					 ,Nil})
	EndIf
	
	aadd(aLinha,{"D1_CC"    	,cCc	  					 ,Nil})
	aadd(aLinha,{"D1_TES"    	,cTes	  					 ,Nil})

	If lEnergia
		aadd(aLinha,{"D1_PEDIDO"   	,cPedEnerg	 			,Nil})
		aadd(aLinha,{"D1_ITEMPC"  	,cItpedEnerg	 		,Nil})
	Endif
	If lXMLPEITE   //PE para incluir campos no aLinha SD1 -> para o aItens
	
		aRet :=	ExecBlock( "XMLPEITE", .F., .F., { cProduto,oDet,i } )
		
		If ValType(aRet) == "A"
		
			AEval(aRet,{|x| AAdd(aLinha,x)})
			
		EndIf
		
	endif
	
	if Empty( cTes )
	
		//cMsg += AllTrim(StrZero(nD1Item,4))+" TES não informado na Amarração de Combustíveis"
		cMsg += AllTrim(StrZero(nD1Item,4))+" TES não informado na Amarração de"
		If lEnergia
			cMsg += " Energia "     			//FR - 18/08/2020
		Else
			cMsg += " Combustíveis "    		//FR - 18/08/2020
		Endif
		lRetorno := .F.
		
	Endif

	if nVunit <= 0 //Não mostrar
	
		//aadd(aProdZr, { StrZero(i,4), oDet[i]:_Prod:_CPROD:TEXT, cProduto, nVunit, oDet[i]:_Prod:_XPROD:TEXT } )

	endif

	if nVunit > 0 //permitir valor unitário maior zero
	
 		aadd(aItens,aLinha)
 		nD1Item++
 		
 	endif
 	
	aLinha := {}

Next i

//Itens não encontrados
nIte := nD1Item

Return( lRetorno )


//----------------------------------------------------------------------------------//
//Função: VERAMARRA - Verifica e valida a amarração de produto (ZBC) 
//Usado : Na classificação automática de combustíveis e energia
//----------------------------------------------------------------------------------//
Static Function VERAMARRA( lMostra )

Local aProdOk   := {}
Local aProdNo   := {}
Local aProdVl   := {}
Local aProdZr   := {}
Local nErrItens := 0
//Local nTamProd  := TAMSX3("B1_COD")[1]
Local lFound    := .F.
Local lRet      := .T.
Local lPassou   := .F.
Local oDet, i
//Local aLinha := {}
Local aItem  := {}
//Local lXMLPEAMA   := ExistBlock( "XMLPEAMA" ), aPEAma, lAmaPe := .F. //nordsonAmarraCof
//Local lXMLPEVAL   := .F. //ExistBlock( "XMLPEVAL" )
//Local lXMLPEREG   := .F. //ExistBlock( "XMLPEREG" )
//Local lXMLPEATU   := .F. //ExistBlock( "XMLPEATU" )
//Local lXMLPE2UM   := ExistBlock( "XMLPE2UM" )
//Local lXMLPEITE   := ExistBlock( "XMLPEITE" )
Local cWhere, cCampos, cTabela, cOrder, cAliasZBC

Private aParam := {}
Private cCodEmit  := "" //cCodFor
Private cLojaEmit := "" //cLojFor
Private cTipoCPro := ""
Private aCabec    := {}, aItens := {}

(cTmp_ZBZ)->( dbgotop() )
Do While .not. (cTmp_ZBZ)->( Eof() )

	if lMostra
	
		IncProc("Verificando amarração "+(cTmp_ZBZ)->CHAVE)
		
	endif
	
	if .not. empty( (cTmp_ZBZ)->OK ) .And. (cTmp_ZBZ)->M0COD == cEmpAnt // == cMarcaOK
	
		cError := ""
		cWarning := ""
		
		DbSelectArea( xZBZ )
		(xZBZ)->( dbGoTo( (cTmp_ZBZ)->REG ) )
		
		oXml := XmlParser((xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML"))), "_", @cError, @cWarning )
		
		DbSelectArea( cTmp_ZBZ )
		
		If oXml == NIL .Or. !Empty(cError) .Or. !Empty(cWarning)
		
			(cTmp_ZBZ)->( dbSkip() )
			
			Loop
			
		Endif
		
	Else
	
		(cTmp_ZBZ)->( dbSkip() )
		
		Loop
		
	Endif

	lPassou:= .T.
	aCabec := {}
	
	aadd(aCabec,{"F1_TIPO"   ,Iif(Empty( (cTmp_ZBZ)->TPDOC ),"N",AllTrim( (cTmp_ZBZ)->TPDOC ))})
	aadd(aCabec,{"F1_FORMUL" ,"N"})

	DbSelectArea( xZBZ )
	
	oDet := oXml:_NFEPROC:_NFE:_INFNFE:_DET
	oDet := IIf(ValType(oDet)=="O",{oDet},oDet)

	If Type("oXml:_NFEPROC:_NFE:_INFNFE:_DET") == "A"
	
		aItem := oXml:_NFEPROC:_NFE:_INFNFE:_DET
		
	Else
	
		aItem := {oXml:_NFEPROC:_NFE:_INFNFE:_DET}
		
	EndIf

	nD1Item := 1
	
	For i := 1 To len(oDet)

		cProduto  := ""
		cCc       := ""
		cTes      := ""
		
		cCodEmit  := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR")))
		cLojaEmit := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR")))
		
		if empty( cCodEmit )
		
			cCodEmit  := Posicione("SA2",3,xFilial("SA2")+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))),"A2_COD")
			cLojaEmit := Posicione("SA2",3,xFilial("SA2")+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))),"A2_LOJA")
		
		endif

		cAliasZBC := GetNextAlias()
		
		nVz := len(aItem)
		
		cTabela:= "%"+RetSqlName(xZBC)+"%"
		cWhere := "%(ZBC."+xZBC_+"CODFOR = '"+cCodEmit+"' "
		cWhere += "AND ZBC."+xZBC_+"LOJFOR = '"+cLojaEmit+"' "
		cWhere += " )%"
		cCampos	:="%"+xZBC_+"FILIAL, "
		cCampos	+= xZBC_+"CODFOR,"+xZBC_+"LOJFOR, "
		cCampos	+= xZBC_+"PROD, "+xZBC_+"CC, "+xZBC_+"TES, ZBC.R_E_C_N_O_"
		cCampos	+=	"%"
		cOrder := "%"+xZBC_+"FILIAL,"+xZBC_+"CODFOR,"+xZBC_+"LOJFOR,"+xZBC_+"PROD%"

		BeginSql Alias cAliasZBC

		SELECT %Exp:cCampos%
				FROM %Exp:cTabela% ZBC
				WHERE ZBC.%notdel%
			 	AND %Exp:cWhere%
				ORDER BY %Exp:cOrder%
		EndSql

		DbSelectArea(cAliasZBC)
		Dbgotop()
		
		lFound := .F.
		
		cKeySa5:= xFilial("ZBC")+cCodEmit+cLojaEmit  //+AllTrim(TrocaAspas( oDet[i]:_Prod:_CPROD:TEXT )) Acabaram com o Campo de produto do fornecedor
		
		While !(cAliasZBC)->(EOF())
		
			cKeyTMP := (cAliasZBC)->(FieldGet(FieldPos(xZBC_+"FILIAL")))+;
			           (cAliasZBC)->(FieldGet(FieldPos(xZBC_+"CODFOR")))+;
			           (cAliasZBC)->(FieldGet(FieldPos(xZBC_+"LOJFOR")))   //+(cAliasZBC)->ZBC_CODPRO
			
			If 	AllTrim(cKeySa5) == AllTrim(cKeyTMP)
			
		  		lFound := .T.
		   		Exit
		   		
		   	Endif
		   	
		   	(cAliasZBC)->(DbSkip())
		   	
		Enddo

		If lFound
		
			cProduto := (cAliasZBC)->(FieldGet(FieldPos(xZBC_+"PROD")))
			cCc      := (cAliasZBC)->(FieldGet(FieldPos(xZBC_+"CC")))
			cTes     := (cAliasZBC)->(FieldGet(FieldPos(xZBC_+"TES")))

			lRetorno := .T.
			aadd(aProdOk,{TrocaAspas( oDet[i]:_Prod:_CPROD:TEXT ),oDet[i]:_Prod:_XPROD:TEXT} )
			
		Else
		
			cProduto := ""
			aadd(aProdNo,{TrocaAspas( oDet[i]:_Prod:_CPROD:TEXT ),oDet[i]:_Prod:_XPROD:TEXT} )
	
		EndIf
		
		DbCloseArea()

		If .not. Empty( cProduto )
		
	 		if SB1->( DbSeek(xFilial("SB1")+cProduto) )
	 		
 				If SB1->( FieldGet(FieldPos("B1_MSBLQL")) ) == "1"
 				
	 				aadd(aProdNo,{cProduto,"Produto Bloqueado SB1->"+SB1->B1_DESC} )
	 				
 				EndIf
 				
	 		Else
	 		
 				aadd(aProdNo,{cProduto,"Não Cadastrado SB1->"+oDet[i]:_Prod:_XPROD:TEXT} )
 				
 			EndIf
 			
 		EndIf

	Next i

	DbSelectArea(cTmp_ZBZ)
	(cTmp_ZBZ)->( dbskip() )
	
Enddo

//Itens não encontrados
if lMostra .And. lPassou

	if .not. U_HFITNENC( "PREN", aProdOk, aProdNo, aProdVl, @nErrItens, aProdZr )
	
		if U_MyAviso( "Pergunta", "Continuar classificação ?", { "SIM", "NAO" }, 3 ) == 1
		
    		lRet := .T.
    		
		Else
		
    		lRet := .F.
    		
		Endif
		
	Else
	
    	lRet := .T.
    	
	endif
	
Else

   	lRet := .T.
	//Quem não tem vai para inconsistência.
	
Endif

(cTmp_ZBZ)->( dbgotop() )

Return( lRet )



Static Function TrocaAspas( cCod )

Local cRet := cCod

cRet := StrTran(cRet,"'",'"')  //troca ' por " -> Isto serve para quando o código do produto vem com ', pois o SA5/SA7 é feito query a qual utiliza-se de '

Return( cRet )


User Function XGetEmpF()

Local aRet    := {}
Local aArea   := GetArea()
//Local cEmpProc:= AllTrim(SM0->M0_CODIGO)
//Local cFilProc:= AllTrim(SM0->M0_CODFIL)
Local nRecFil := 1
Local lLicHF  := .T.

DbSelectArea("SM0")
nRecFil := SM0->(Recno())
DbGotop()

While !Eof()

	//If U_HFXML00X("HF000001","101",SM0->M0_CGC,,.F.)
	If U_HFXMLLIC(.F.)

		lLicHF  := .T.
		
	Else
	
		lLicHF  := .F.
		
	EndIF

	Aadd(aRet, { lLicHF,SM0->M0_CODIGO,SM0->M0_CODFIL,SM0->M0_CGC,SM0->M0_FILIAL,SM0->M0_NOMECOM,SM0->M0_INSC } )

	SM0->( DbSkip() )
	
EndDO

dbgoto(nRecFil)

RestArea(aArea)

Return(aRet)



User Function HF13ZBOA()  //U_HF13ZBOA()

Local aArea := GetArea()
Local aRet  := {}
Local nI    := 0
Local aReg[4], xIni
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

DbSelectArea( xZBO )
(xZBO)->( dbGoBottom() )
(xZBO)->( dbSkip() )  //Para ir para o EOF() e ai poder dar um valor inical nulis

For nI := 1 To ( xZBO )->( FCount() )

	xIni := ( xZBO )->( FieldGet( nI ) )
	
	aReg[1] := nI              //Numero do campo
	aReg[2] := ( xZBO )->( FieldName( nI ) )  //Nome
	aReg[3] := ValType(xIni)   //
	aReg[4] := xIni            //Valor que será usado para gravar na outra função
	
	aadd( aRet, aClone(aReg) )
	
Next nI

//Mandar o registro como zero no final.
aReg[1] := 0            //Numero do campo
aReg[2] := "RECNO"      //Nome
aReg[3] := "N"          
aReg[4] := 0            //Valor que será usado para gravar na outra função

aadd( aRet, aClone(aReg) )

RestArea( aArea )

Return( aRet )

//----------------------------------------------------------------------------------//
//Função: HF13ZBOG - Grava o Log de Ocorrências (ZBO) 
//----------------------------------------------------------------------------------//
User Function HF13ZBOG( lApp, nInd, cChv, aZbo, cChaveNF )

Local aArea   := GetArea()
Local lRet    := .F.
Local lAcha   := .T.
Local nCodSeq := 0, nTamSeq := 0
Local nI

DbSelectArea( xZBO )
DBSetOrder( 1 )

if nInd > 1

	DBSetOrder( nInd )
	
endif

if !lApp

	if Empty( cChv ) .And. aZbo[Len(aZbo)][4] == 0
	
		lApp := .T.
		
	ElseIf aZbo[Len(aZbo)][4] > 0
	
		( xZBO )->( DbGoTo( aZbo[Len(aZbo)][4] ) )
		
		If ( xZBO )->( Eof() )
		
			lAcha := .F.
			
		EndIF
		
	ElseIF ! Empty( cChv )
	
		If ! ( xZBO )->( DbSeek( cChv ) )
		
			lAcha := .F.
			
		Endif
		
	Else
	
		lAcha := .f.
		
	endif
	
	if ! lAcha
	
		lApp := .T.
		
	endif
	
endif

Reclock(xZBO,lApp)

For nI := 1 to Len( aZbo )

	if aZbo[nI][2] = xZBO_+"CODSEQ" .And. Empty(aZbo[nI][4])
	
		if !lApp  //Alteração fica ele mesmo
		
			aZbo[nI][4] := ( xZBO )->( FieldGet( nI ) )
			
		Else //Inclusão Soma Um
		
			nTamSeq := Len( ( xZBO )->( FieldGet( nI ) ) )
			
			nCodSeq := GetNewPar("XM_SEQZBO",0,cFilAnt) + 1
			
			If !PutMv("XM_SEQZBO",nCodSeq)
			
				SX6->(RecLock("SX6",.T.))
				SX6->X6_FIL     := cFilAnt //xFilial( "SX6" )
				SX6->X6_VAR     := "XM_SEQZBO"
				SX6->X6_TIPO    := "N"
				SX6->X6_DESCRIC := "HF Sequencia do Log Integração Externa"
				SX6->(MsUnLock())
				
				PutMv("XM_SEQZBO",nCodSeq)
				
			EndIf
			
			RstMvBuff()
			aZbo[nI][4] := StrZero(nCodSeq,nTamSeq,0)
			
		endif
		
	endif
	
	if aZbo[nI][2] = xZBO_+"REVISA" .And. Empty(aZbo[nI][4])
	
		nTamSeq := Len( ( xZBO )->( FieldGet( nI ) ) )
		
		aZbo[nI][4] := StrZero(Val( ( xZBO )->( FieldGet( nI ) ) )+1,nTamSeq,0)
		
	endif
	
	if aZbo[nI][2] = xZBO_+"M0COD" .And. Empty(aZbo[nI][4])
	
		aZbo[nI][4] := cEmpAnt
		
	endif
	
	If aZbo[nI][1] > 0 .And. aZbo[nI][2] <> "RECNO"
	
		(xZBO)->( FieldPut( aZbo[nI][1], aZbo[nI][4] ) )
		lRet  := .T.  //Ao Menos Um
		
	ElseIF Empty( aZbo[nI][1] ) .And. !Empty(aZbo[nI][2]) .And. aZbo[nI][2] <> "RECNO"  //Fadigando
	
		(xZBO)->( FieldPut(FieldPos(aZbo[nI][2]), aZbo[nI][4] ) )
		lRet  := .T.  //Au menus un 
		
	EndIf
	
Next nI

(xZBO)->( MsUnLock() )

CONOUT("<GESTAOXML> GRAVOU LOG ====> ZBO <==== ")
RestArea( aArea )

Return( lRet )


//----------------------------------------------------------------------------------//
//Função: HF13ZPOS - Monta o posicionamento dos campos da Tabela de Ocorrências (ZBO) 
//----------------------------------------------------------------------------------//
User Function HF13ZPOS( aZBO, nPFil, nPCod, nPDes, nPDto, nPHro, nPChv, nPRsf, nPTpo, nPRvo, nPArq, nPFpt, nPExa, nPStt, nPEmp, nPMai )  //
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

nPFil := aScan( aZBO, {|x| x[2] == xZBO_+"FILIAL" } )
nPCod := aScan( aZBO, {|x| x[2] == xZBO_+"CODSEQ" } )
nPDes := aScan( aZBO, {|x| x[2] == xZBO_+"DESCR"  } )
nPDto := aScan( aZBO, {|x| x[2] == xZBO_+"DTOCOR" } )
nPHro := aScan( aZBO, {|x| x[2] == xZBO_+"HROCOR" } )
nPChv := aScan( aZBO, {|x| x[2] == xZBO_+"CHAVE"  } )
nPRsf := aScan( aZBO, {|x| x[2] == xZBO_+"RETSEF" } )
nPTpo := aScan( aZBO, {|x| x[2] == xZBO_+"TPOCOR" } )
nPRvo := aScan( aZBO, {|x| x[2] == xZBO_+"REVISA" } )
nPArq := aScan( aZBO, {|x| x[2] == xZBO_+"ARQ"    } )
nPFpt := aScan( aZBO, {|x| x[2] == xZBO_+"FTP"    } )
nPExa := aScan( aZBO, {|x| x[2] == xZBO_+"EXAUTO" } )
nPStt := aScan( aZBO, {|x| x[2] == xZBO_+"ST"     } )
nPEmp := aScan( aZBO, {|x| x[2] == xZBO_+"M0COD"  } )
nPMai := aScan( aZBO, {|x| x[2] == xZBO_+"MAIL"   } )

Return( .T. )

//-----------------------------------------------------------------------------------------------//
//Função  : HF13MAIL
//Objetivo: Envia email das ocorrências gravadas na tabela ZBO
//Filtra pelo nome do arquivo:
// se for Aguas Brasil, é exatamente o nome do arquivo que está em cArq
// se for xml Energia o nome terá a string "ENERGIA_"
// se for xml de combustivel (sem ser Aguas Br) o nome terá a string "COMBUSTIVEIS_" 
//-----------------------------------------------------------------------------------------------//
User Function HF13MAIL( cArq, lTod, cTitulo,lEnergia,lCombust )

Local aArea   := GetArea()
Local cDes    := ""
Local cMsg    := ""
Local cUltArq := ""
Local cUltFtp := ""
Local lEnvia  := .F.
Local cAssunto:= ""
Local cError  := ""
Local cAnexo  := ""
Local cHea    := ""
Local cEmailErr:= ""
Local cTipo   := ""			//FR - 18/08/2020
Local aTo     := {}
Local aStatus := {}
Local nSt     := 0
Local aReg    := {}
Local lRet    := .F.
Local nPosPto := 0
Local cAux    := ""
Local nDiaSemana := 0
Default cArq  := ""
Default lTod  := .F.
Default cTitulo  := ""		//FR - 18/08/2020
Default lEnergia := .F. 
Default lCombust := .F.

Private cAliasXMl := GetNextAlias()
//FR - 05/10/2020
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
//FR - 05/10/2020

Aadd( aStatus, {" ", "S/Acao" } )
Aadd( aStatus, {"0", "S/Acao" } )
Aadd( aStatus, {"1", "Penden" } )
Aadd( aStatus, {"2", "Corrig" } )

//lEnergia := ("ENERGIA" $ UPPER(cTitulo) ) 

//FR 13/07/2020 - CHECAR SE já foi enviado email
If lEnergia
	cTipo   := "Energia
	cTitulo := "Classificação Automática de NF Energia"

Else
	//FR - 18/08/2020 - os xmls da Aguas do Br gravam na ZBO sem a extensão .TXT, por isso aqui eu retiro a extensão para conseguir fazer a query  		
	nPosPto := At(".", cArq)
	If nPosPto > 0
		cAux := Substr(cArq,1, (nPosPto - 1))  //123456.txt
		cArq := cAux
	Endif
	cTipo   := "Combustiveis
	cTitulo := "Classificação Automática de NF Combustiveis"
	
Endif


cQuery  := "" 

cQuery := " SELECT " + CRLF
cQuery += " "+xZBO_+"FILIAL AS FILIAL, "+ CRLF
cQuery += " "+xZBO_+"DESCR AS DESCR,   "+ CRLF
cQuery += " "+xZBO_+"DTOCOR AS DTOCOR, "+ CRLF
cQuery += " "+xZBO_+"HROCOR AS HROCOR, "+ CRLF
cQuery += " "+xZBO_+"CHAVE AS CHAVE,   "+ CRLF
cQuery += " "+xZBO_+"RETSEF AS RETSEF, "+ CRLF
cQuery += " "+xZBO_+"TPOCOR AS TPOCOR, "+ CRLF
cQuery += " "+xZBO_+"REVISA AS REVISA, "+ CRLF
cQuery += " "+xZBO_+"ARQ AS ARQ,       "+ CRLF
cQuery += " "+xZBO_+"MAIL AS MAIL,     "+ CRLF
cQuery += " "+xZBO_+"ST AS ST,         "+ CRLF
cQuery += " "+xZBO_+"FTP AS FTP,       "+ CRLF
cQuery += " ZBO.R_E_C_N_O_ AS REG      "+ CRLF

cQuery += " FROM " + RETSQLNAME(xZBO)   + " ZBO "+ CRLF
cQuery += " WHERE ZBO.D_E_L_E_T_ = '' "          + CRLF 
cQuery += " AND ZBO."+xZBO_+"MAIL IN ('1',' ') " + CRLF

If lEnergia
	cQuery += " AND ZBO."+xZBO_+"ARQ LIKE '"+AllTrim(cArq)+"%' "+ CRLF  //FR - 05/08/2022 - O nome do arquivo pode ser ENERGIA_ano_mes_dia_hora.txt

Elseif lCombust
	cQuery += " AND ZBO."+xZBO_+"ARQ LIKE '"+AllTrim(cArq)+"%' "+ CRLF  //FR - 05/08/2022 - O nome do arquivo pode ser ENERGIA_ano_mes_dia_hora.txt

Else 
	cQuery += " AND ZBO."+xZBO_+"ARQ = '"+AllTrim(cArq)+"' "+ CRLF  //AGUAS DO BRASIL USA ASSIM: 2020_04_27_150827.TXT (exemplo do formato) tem q ser exatamente igual ao arquivo passado no parametro                          
Endif                                                                   //FR - 05/08/2022 - O nome do arquivo pode ser COMBUSTIVEIS_ano_mes_dia_hora.txt
cQuery += " ORDER BY ARQ, FTP, DTOCOR, HROCOR " 

cQuery := ChangeQuery( cQuery )
MemoWrite("\TEMP\ZBOEnviaMail.SQL" , cQuery)
                 
DbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasXMl, .F., .T. )


cMsg += '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
cMsg += '<html xmlns="http://www.w3.org/1999/xhtml">'
messagePadron( "",@cHea,"",lEnergia )		//FR 03/11/2020
cMsg += cHea
cMsg += '<body>'
cMsg += '<table style="background-color: rgb(240, 240, 240); width: 1300px;" id="total" border="0" cellpadding="2" cellspacing="0">'  //text-align: left; margin-left: auto; margin-right: auto;
cMsg += '<caption>'+ cTitulo + '</caption>'		//FR - 06/08/2020
cMsg += '	<tr>'
cMsg += '		<th id="col_st">St</th>'
cMsg += '		<th id="col_Fil">Filial</th>'
cMsg += '		<th id="col_Dat">Data</th>'
cMsg += '		<th id="col_Hor">Hora</th>'
cMsg += '		<th id="col_Des">Descrição</th>'
cMsg += '		<th id="col_Chv">Chave</th>'
//cMsg += '		<th id="col_Ftp">Arquivo FTP</th>'
//cMsg += '		<th id="col_Arq">Arquivo Local</th>'
cMsg += '		<th id="col_Sef">Erro Sefaz</th>'
cMsg += '	</tr>'

DbSelectArea(cAliasXMl)
(cAliasXMl)->(DbGoTop())

While !(cAliasXMl)->(EOF())

	aadd( aReg, (cAliasXMl)->REG )
	DbSelectArea( xZBO )
	
	(xZBO)->( dbGoTo( (cAliasXMl)->REG ) )
	
	nSt := aScan( aStatus, {|x| x[1] = (xZBO)->( FieldGet( FieldPos( xZBO_+"ST" ) ) )  } )
	
	if nSt < 1 .or. nSt > Len(aStatus)
	
		nSt := 1  //Fadiga
		
	endif 

	If cUltArq <> AllTrim( (xZBO)->(FieldGet(FieldPos(xZBO_+"ARQ" ))) ) .OR. cUltFtp <> AllTrim( (xZBO)->(FieldGet(FieldPos(xZBO_+"FTP" ))) )
		
		cUltArq := AllTrim( (xZBO)->(FieldGet(FieldPos(xZBO_+"ARQ" ))) ) 
		cUltFtp := AllTrim( (xZBO)->(FieldGet(FieldPos(xZBO_+"FTP" ))) )
		
		cMsg += '	<tr align="center">'
		cMsg += '		<td width="100%" colspan="6" headers="col_st" align="center" >'+' '+'</td>'
		cMsg += '	</tr>'
		If !lCombust .and. !lEnergia
			cMsg += '	<tr align="center">'
			cMsg += '		<td width="100%" colspan="6" headers="col_st" align="center" >'+'Arquivo Local '+cUltArq+' Arquivo FTP '+cUltFtp+'</td>'
		Endif
		cMsg += '	</tr>'
		cMsg += '	<tr align="center">'
		cMsg += '		<td width="100%" colspan="6" headers="col_st" align="center" >'+' '+'</td>'
		cMsg += '	</tr>'
		
	Endif

	
	cDes  := (xZBO)->(FieldGet(FieldPos(xZBO_+"DESCR" )))
	
	if ! Empty( (xZBO)->(FieldGet( FieldPos( xZBO_+"EXAUTO"))) )
	
		cDes := cDes + CRLF
		cDes := cDes + (xZBO)->(FieldGet( FieldPos( xZBO_+"EXAUTO")))
		
	EndIf
	
	//DbSelectArea(xZBZ)
	//DbSelectArea(3)
	//DbSeek( xZBO_+"CHAVE" )

	cMsg += '	<tr>'
	cMsg += '		<td width="03%" headers="col_st">'	+ aStatus[nSt][2] +'</td>'
	cMsg += '       <td width="05%" headers="col_Fil">'	+ (xZBO)->(FieldGet(FieldPos( xZBO_+"FILIAL"))) + '</td>'
	cMsg += '		<td width="06%" headers="col_Dat">' + dtoc( (xZBO)->(FieldGet(FieldPos( xZBO_+"DTOCOR")))   ) + '</td>'
	cMsg += '		<td width="06%" headers="col_Hor">' + AllTrim( (xZBO)->(FieldGet(FieldPos(xZBO_+"HROCOR"))) ) + '</td>'
	cMsg += '		<td width="45%" headers="col_Des">' + AllTrim( cDes )+'</td>'
	cMsg += '		<td width="15%" headers="col_Chv">' + AllTrim( (xZBO)->(FieldGet(FieldPos(xZBO_+"CHAVE" ))) ) + '</td>'
//	cMsg += '		<td width="10%" headers="col_Ftp">' + AllTrim( (xZBO)->(FieldGet(FieldPos(xZBO_+"FTP"   ))) ) + '</td>'
//	cMsg += '		<td width="10%" headers="col_Arq">' + AllTrim( (xZBO)->(FieldGet(FieldPos(xZBO_+"ARQ"   ))) ) + '</td>'
	cMsg += '		<td width="20%" headers="col_Sef">' + AllTrim( (xZBO)->(FieldGet(FieldPos(xZBO_+"RETSEF"))) ) + '</td>'
	cMsg += '	</tr>'

	DbSelectArea( cAliasXMl )
	lEnvia  := .T.
	(cAliasXMl)->(dbSkip())
	
End

cMsg += '</table>'
cMsg += '</body>'
cMsg += '</html>'

/*
DOW()
Retorna um número entre zero e sete, representando o dia da semana. 
O primeiro dia da semana é 1 (Domingo) e o último é 7 (Sábado). 
Se a data for vazia ou inválida, DOW() retorna zero.
*/

nDiaSemana := Dow(Date())  //If Dow(dAux) == 7	//se sábado, soma mais 1

if lEnvia .and. nDiaSemana <> 1 .and. nDiaSemana <> 7  //não envia no sábado nem domingo

	CONOUT("<GESTAOXML> ENVIANDO EMAIL OCORRENCIA ... <====")

	cEmailErr := AllTrim(SuperGetMv("XM_MAIL07")) // Conta de Email para Combustivel
	//cEmailErr  := "flavia.rocha@hfbr.com.br" 		//FR TESTE RETIRAR
    lRet := .F.

	If !Empty(cEmailErr)
	
	    cAssunto:= "Informativo de Ocorrencias XML" //"Informativo de Notas de Combustivel (IMPXML)"	//FR - 06/08/2020
	    cError  := ""
	    cAnexo  := ""
	    
		aTo 	:= Separa(cEmailErr,";")
		
		//Ajuste necessario para tratar a filial no momento de enviar o email ZBI grava filial diferente da ZBO.
		_cFilOld := cFilAnt
		cFilAnt := (xZBO)->(FieldGet(FieldPos( xZBO_+"FILIAL")))
		
		SM0->( DbSetOrder(1) )
		SM0->( DbSeek( cEmpAnt + cFilAnt ) )
		
		nRet := U_MAILSEND(aTo,cAssunto,cMsg,@cError,cAnexo,"",cEmailErr,"","") 
		
		CONOUT("<GESTAOXML> EMAIL OCORRENCIA ENVIADO COM SUCESSO PARA: " + cEmailErr + " <====") 
		If !IsBlind()
			If lEnergia		//FR - 18/08/2020
				MsgInfo("Por Favor, Verifique o Email: " + CRLF + " => " + cEmailErr + " <= ")
			Endif
		Endif
		cFilAnt := _cFilOld
		
		SM0->( DbSetOrder(1) )
		SM0->( DbSeek( cEmpAnt + cFilAnt ) )
		
		If nRet == 0 .And. Empty(cError) //13/01/2016 retorno
		
			lRet := .T.
			
		EndIf
		
	EndIf

	DbSelectArea( cAliasXMl )
	(cAliasXMl)->(dbGoTop())
	
	While !(cAliasXMl)->(EOF())
	
		DbSelectArea( xZBO )
		
		(xZBO)->( dbGoTo( (cAliasXMl)->REG ) )
		RecLock( xZBO, .F. )
		
        if lRet
        
        	(xZBO)->( FieldPut( FieldPos(xZBO_+"MAIL"), "2" ) )
        	
        elseif (xZBO)->(FieldGet(FieldPos(xZBO_+"MAIL"))) <> "2"
        
        	(xZBO)->( FieldPut( FieldPos(xZBO_+"MAIL"), "1" ) )
        	
        endif
        
		(xZBO)->( MsUnLock() )
		
		DbSelectArea( cAliasXMl )
		
		(cAliasXMl)->(dbSkip())
		
    End

endif

RestArea( aArea )

Return( NIL )



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Empresa   ³ HF Consulting                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ´±±
±±³Funcao    ³messagePad ³ Autor ³ Eneovaldo Roveri Jr                  ³ Data ³ 28/11/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao que retorno um mensagem padrão em html para envio no corpo do e-mail³±±
±±³          ³ utilizada pelo fsendmail e tambem pela fNotific.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Obs.      ³ Voce pode passar os parametros cHead e cBody como referencia para utiliza- ³±±
±±³          ³ los em seu programa, como eh feito no FNotific.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ messagePadron( cCc, cHead, cBody )                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCc   : Mensagem padrao para ir no corpo do e-mail                         ³±±
±±³          ³ cHead : Mandar como referencia para ele retornar o cabecalho padrao        ³±±
±±³          ³ cBody : Mandar como referencia para ele retornar o corpo do e-mail padrao  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³             ATUALIZACOES SOFRIDAS DESDE CONSTRUCAO                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Data      ³ Programador      ³ Manutencao efetuada                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  /  /    ³                  ³                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Capricornio S/A                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function messagePadron( cCc, cHead, cBody, lEnergia )		//FR 03/11/2020

Local cMsgCfg := ""

cHead := ""
cHead += '<head>'
cHead += '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />'
//FR 03/11/2020
If lEnergia
	cHead += '<title>Classificação Automática de Energia</title>'
Else
	cHead += '<title>Classificação Automática de Combustiveis</title>'
Endif
//FR 03/11/2020
cHead += '  <style type="text/css"> '
cHead += '	<!-- '
cHead += '	body {background-color: rgb(37, 64, 97);} '
cHead += '	.style1 {font-family: Segoe UI,Verdana, Arial;font-size: 12pt;} '
cHead += '	.style2 {font-family: Segoe UI,Verdana, Arial;font-size: 12pt;color: rgb(255,0,0)} '
cHead += '	.style3 {font-family: Segoe UI,Verdana, Arial;font-size: 10pt;color: rgb(37,64,97)} '
cHead += '	.style4 {font-size: 8pt; color: rgb(37,64,97); font-family: Segoe UI,Verdana, Arial;} '
cHead += '	.style5 {font-size: 10pt} '
cHead += '	-->'
cHead += '  </style>'
cHead += '</head>'

cBody := ""
cBody += '<body>'
cBody += '<table style="background-color: rgb(240, 240, 240); width: 800px; text-align: left; margin-left: auto; margin-right: auto;" id="total" border="0" cellpadding="12">'
cBody += '  <tbody>'
cBody += '    <tr>'
cBody += '      <td colspan="2">'
cBody += '    	<Center>'
cBody += '      <img src="http://extranet.helpfacil.com.br/images/cabecalho.jpg">'
cBody += '      </Center><hr>'
cBody += '      <p class="style1">'+cCc+'</p>'
cBody += '      <hr></td>'
cBody += '    </tr>'
cBody += '  </tbody>'
cBody += '</table>'
cBody += '<p class="style1">&nbsp;</p>'
cBody += '</body>'

cMsgCfg := ""
cMsgCfg += '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
cMsgCfg += '<html xmlns="http://www.w3.org/1999/xhtml">'
cMsgCfg += cHead
cMsgCfg += cBody
cMsgCfg += '</html>'

Return cMsgCfg



Static Function AbreTread( cTip, cNom, nX )

Local cTrd     := cNom+AllTrim(Str(nX))+ '.lck'
Local cNomeArq := GetPathSemaforo()+cTrd
Local nHnd     := 0

MakeDir(GetPathSemaforo())

nHnd := LockTrea(cNomeArq)

return( cTrd )


Static Function FechaTread( cTip, cTrd )
//Local

Return( lRet )


Static Function LockTrea(cFile)

Local nHJob := 0

	If File(cFile)
	
		nHJob := FOPEN(cFile,2)	
								
	Else
	
		nHJob := FCREATE(cFile)
		
	EndIf
	
Return nHJob


Static Function UnLockTrd(nHandle,lOk)

Local cMsg := IIF(lOk,OK,ERRO)

FWRITE(nHandle,cMsg)

FCLOSE(nHandle) 

Return


Static Function __Dummy(lRecursa) //warning W0010 Static Function <?> never called

    lRecursa := .F.
    
    IF (lRecursa)
    
        __Dummy(.F.)
        U_XGetEmpF()
        U_HFXML131()
        U_XML131CH()
        U_HFzCHKCV()
        U_XML131CL()
        U_HFzClass()
        U_HF13ZBOA()
        U_HF13ZBOG()
        U_HF13ZPOS()
        U_HF13MAIL()
        
	EndIF
	
Return(lRecursa)
******************************************************************************************************
Static Function fGRAVALOJA(cZBZFIL, cZBZCHAVE, cZBZNOTA, cZBZSERIE, cZBZCODFOR, cZBZLOJFOR, cZBZTPDOC)
//fGRAVALOJA( (cTmp_ZBZ)->M0FIL,(cTmp_ZBZ)->CHAVE, (cTmp_ZBZ)->NOTA, (cTmp_ZBZ)->SERIE, (cTmp_ZBZ)->CODFOR, (cTmp_ZBZ)->LOJFOR, (cTmp_ZBZ)->TPDOC  )
******************************************************************************************************
Local lGravou := .F.
Local aRecnos := {} 

DbSelectArea("SF1")	
SF1->(OrdSetFocus(8))  //DbSetOrder(8)  //F1_FILIAL+F1_CHVNFE 
If SF1->(DbSeek( AllTrim( cZBZFIL ) + Alltrim( cZBZCHAVE ) )) 	
	If Empty(SF1->F1_LOJA)
	
		 RecLock( "SF1", .F. )				
			SF1->F1_LOJA := cZBZLOJFOR
			SF1->( MsUnlock() )
			lGravou := .T.			
				
	Endif				
	
	//loja SD1	
	DbSelectArea("SD1")
	SD1->(OrdSetFocus(1)) 			//D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM	
	While SD1->(DbSeek( cZBZFIL + cZBZNOTA + cZBZSERIE + cZBZCODFOR + Space(TAMSX3("D1_LOJA")[1]) ))		
				
		If Alltrim(SD1->D1_TIPO) == Alltrim( cZBZTPDOC )							
			RecLock( "SD1", .F. )					
			SD1->D1_LOJA  := Alltrim( cZBZLOJFOR )			
			SD1->( MsUnlock() )
			Aadd(aRecnos , SD1->(Recno()) )					
		Endif	
		SD1->(Dbskip())
	
	Enddo	

Endif

	
Return
//--------------------------------------------------------------//
//FR - 18/08/2020 
//Verifica se existem XMLs de Energia e monta array 
//das notas para classificar, este array será enviado por
//parâmetro para as funções: CLASFIS, PROCREGS, HFzClass
//são as mesmas funções de classificação de nfs combustíveis
//foi possível reaproveita-las com a finalidade de classificação
//de notas de energia.
//--------------------------------------------------------------//
***************************************************************
User Function fVerXMLEnerg(lTemPC,aCab,aIte,lSoCheck,oRegua)
***************************************************************
Local cQuery 	  := ""
Local lRet		  := .F.
Local LF		  := CHR(13) + CHR(10)
Local aLin[20]
Local aDet[18]
Local oXml
Local cXml             
Local cError	  := ""
Local cWarning	  := ""
Local cRazao	  := ""
Local cModelo     := ""
Local cPref		  := "" 
Local cTAG 		  := ""
Local cTGP		  := ""
Local cVerOk      := ""
Local cAux		  := ""
Local cArqTXT     := ""
Local nFormXML    := 6
Local nFormNfe    := Val(GetNewPar("XM_FORMNFE","6"))
Local nFormCTe    := Val(GetNewPar("XM_FORMCTE","6"))
//Local nFormSer    := Val(GetNewPar("XM_FORMSER","0")) ///Incluido 19/01/2016
//Local nDiasUteis  := GetNewPar("XM_DIASVCT", 0)		//Indica qtos dias uteis serão usados para calcular o vencimento da nf energia no caso de não haver a tag do vencimento
Local cTagAux     := ""
Local aZBO, nPFil, nPCod, nPDes, nPDto, nPHro, nPChv, nPRsf, nPTpo, nPRvo, nPArq, nPFpt, nPExa, nPStt, nPEmp, nPMai
Local aRet        := Array(3)
Local nReczbz     := 0
Local cVerNFE     := "2.00|2.01|3.10|4.00"
Local aVerPC 	  := {}
Local cCondPC	  := ""
Local cEmiNF	  := ""
Local lCor		  := .F.
Local lCondicao   := .F.
Local cCFOPEnergia:= ""
Local oDet 
Local lEnergia    := .F.
Local lTagVenc    := .T.
Local i 		  := 0	
Local nDiasRetro  := 0		//FR - 13/11/2020
Local dDataPartir := Ctod("  /  /    ")	
Local cDataPartir := "" 

Private xZBZ  	  := GetNewPar("XM_TABXML","ZBZ")
Private xZBZ_ 	  := iif(Substr(xZBZ,1,1)=="S", Substr(xZBZ,2,2), Substr(xZBZ,1,3)) + "_"
Private xZBO      := GetNewPar("XM_TABOCOR","ZBO"), xRetSEF := ""
Private xZBO_     := iif(Substr(xZBO,1,1)=="S", Substr(xZBO,2,2), Substr(xZBO,1,3)) + "_"
Private xZBC  	  := GetNewPar("XM_TABCAC","ZBC")  //Colocar no HFXML01
Private xZBC_ 	  := iif(Substr(xZBC,1,1)=="S", Substr(xZBC,2,2), Substr(xZBC,1,3)) + "_"
//FR - 13/11/2020
nDiasRetro := GetNewPar("XM_KRDIASR" , 30)
dDataPartir:= dDatabase - nDiasRetro 
//FR - 13/11/2020 - ex: se for 30 dias a retroagir, hoje é 13/11 - 30 dias = 14/10, Irá considerar notas emitidas a partir de 14/10/2020

cCFOPEnergia := GetNewPar("XM_CFOENERG","5251,6251,5123,6123,5922,6922")	//FR - 14/12/2020
cMontaIN     := fMontaIn( Alltrim(cCFOPEnergia) )

//FR - 14/12/2020 - 1a. query para checagem se existem XML's de Energia, para otimizar o processo para aqueles clientes que NÃO TEM XML de Energia.
cQuery := " SELECT  " + LF
cQuery += ""+xZBZ_+"CFOP   AS ZBZCFOP , "       + LF
cQuery += ""+xZBZ_+"CHAVE  AS ZBZCHAVE, "		+ LF 
cQuery += ""+xZBZ_+"XML    AS ZBZXML, " 		+ LF
cQuery += ""+xZBZ_+"MODELO AS ZBZMODELO, " 		+ LF
cQuery += ""+xZBZ_+"COMBUS AS ZBZCOMBUS, "		+ LF 
cQuery += " ZBZ.R_E_C_N_O_ RECZBZ,       "      + LF
 
cQuery += "  ZBZ.* " 							+ LF
cQuery += " FROM " + RetSqlName(xZBZ) + " ZBZ " + LF

cQuery += " WHERE "								+ LF
cQuery += " ZBZ.D_E_L_E_T_ <> '*'     " 		+ LF
cQuery += " AND ZBZ."+xZBZ_+"FILIAL = '" + Alltrim(xFilial(xZBZ)) + "' " + LF
 
cQuery += " AND " + xZBZ_+"COMBUS = 'E' " 	+ LF		//xml de energia, se já encontrar não precisa executar as próximas linhas  
//FR - 14/12/2020 - inutilizado
/*
cQuery += " AND (" + LF
cQuery += ""       + xZBZ_+"PROTC  = '" + Space(15) + "' AND " 	+ LF 
cQuery += ""       + xZBZ_+"PRENF  = 'B'                 AND "	+ LF 		//xml de notas não classificadas 
cQuery += ""       + xZBZ_+"MODELO IN ('55','65')          "	+ LF
cQuery += "      )  " 											+ LF
*/
//FR - 14/12/2020 - inutilizado

cQuery += " AND " + xZBZ_+"CFOP IN (" + Alltrim(cMontaIn) + " ) " + LF		//FR - 14/12/2020 - otimiza o processo
cQuery += " AND " + xZBZ_+"PRENF IN ('B','Z')					  " + LF 
cQuery += " AND " + xZBZ_+"MODELO IN ('55','65')          "	+ LF
cQuery += " AND " + xZBZ_+"PROTC  = '" + Space(15) + "'   " + LF

cQuery += " ORDER BY "+ xZBZ_+"COMBUS ," + xZBZ_+"NOTA "		+ LF

MemoWrite("C:\TEMP\1XMLENERGIA.SQL" , cQuery)

If Select("TMPE1") > 0
	dbSelectArea("TMPE1")
    TMPE1->(dbCloseArea())
EndIf

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPE1", .T., .F. )
DbSelectArea("TMPE1")
DbGoTop()

If TMPE1->(!Eof()) .and. lSoCheck
	lRet := .T.
	Return(lRet)
Else
	//FR - 14/12/2020 - 2a. query já para execução do processo de classificação de NFs de Energia
	cQuery := " SELECT  " + LF
	cQuery += ""+xZBZ_+"CFOP   AS ZBZCFOP,  "       + LF
	cQuery += ""+xZBZ_+"CHAVE  AS ZBZCHAVE, "		+ LF
	cQuery += ""+xZBZ_+"XML    AS ZBZXML, " 		+ LF
	cQuery += ""+xZBZ_+"MODELO AS ZBZMODELO, " 		+ LF
	cQuery += ""+xZBZ_+"COMBUS AS ZBZCOMBUS, "		+ LF
	cQuery += ""+xZBZ_+"NOTA   AS ZBZNOTA, "		+ LF
	cQuery += ""+xZBZ_+"SERIE  AS ZBZSERIE, "		+ LF
	cQuery += " ZBZ.R_E_C_N_O_ RECZBZ,       "      + LF
	
	cQuery += "  ZBZ.* " 							+ LF
	cQuery += " FROM " + RetSqlName(xZBZ) + " ZBZ " + LF
	
	cQuery += " WHERE "								+ LF
	cQuery += " ZBZ.D_E_L_E_T_ <> '*'     " 		+ LF
	cQuery += " AND ZBZ."+xZBZ_+"FILIAL = '" + Alltrim(xFilial(xZBZ)) + "' " + LF
	
	//FR - 14/12/2020 - inutilizado
	/*
	cQuery += " AND (" + LF
	cQuery += ""       + xZBZ_+"PROTC  = '" + Space(15) + "' AND " 	+ LF
	cQuery += ""       + xZBZ_+"PRENF  = 'B'                 AND "	+ LF 		//xml de notas não classificadas
	cQuery += ""       + xZBZ_+"MODELO IN ('55','65')            "	+ LF
	//cQuery += " OR "       + xZBZ_+"COMBUS = 'E' " 				+ LF
	cQuery += "      )  " 											+ LF
	*/	
	//FR - 14/12/2020 - inutilizado
	
	cQuery += " AND " + xZBZ_+"CFOP IN (" + Alltrim(cMontaIn) + " ) " + LF		//FR - 14/12/2020 - otimiza o processo
	cQuery += " AND " + xZBZ_+"PRENF  = 'B'					  " + LF 
	cQuery += " AND " + xZBZ_+"MODELO IN ('55','65')          "	+ LF
	cQuery += " AND " + xZBZ_+"PROTC  = '" + Space(15) + "'   " + LF
	
	//cQuery += " AND " + xZBZ_+"NOTA  = '000089792'       " + LF		//FR TESTE RETIRAR DEPOIS!
	//cQuery += " AND " + xZBZ_+"NOTA  = '000000470'       " + LF		//FR TESTE RETIRAR DEPOIS!
	
	cQuery += " ORDER BY " + xZBZ_+"NOTA,  "+ xZBZ_+"SERIE "		+ LF
	
	MemoWrite("C:\TEMP\2XMLENERGIA.SQL" , cQuery)
	
	If Select("TMPE1") > 0
		dbSelectArea("TMPE1")
		TMPE1->(dbCloseArea())
	EndIf
	
	cQuery := ChangeQuery( cQuery )		//FR - 13/11/2020
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPE1", .T., .F. )
	DbSelectArea("TMPE1")
	DbGoTop()
	
	If TMPE1->(!Eof())
		
		aZBO := U_HF13ZBOA()
		
		U_HF13ZPOS( aZBO, @nPFil, @nPCod, @nPDes, @nPDto, @nPHro, @nPChv, @nPRsf, @nPTpo, @nPRvo, @nPArq, @nPFpt, @nPExa, @nPStt, @nPEmp, @nPMai )
		
		aRet[1] := ""
		aRet[2] := ""
		aRet[3] := ""
		
		While TMPE1->(!Eof())
			
			cChave := TMPE1->ZBZCHAVE  //Substr(cBuf,272,44)
			cModelo:= TMPE1->ZBZMODELO
			nReczbz:= TMPE1->RECZBZ
			cNota  := TMPE1->ZBZNOTA

			If !IsBlind() .and. !lSoCheck
				oRegua:IncRegua1("Procurando por Pedidos de Compra Energia ...")
				oRegua:IncRegua2( "NF: " + cNota )
			Endif
			
			DbSelectArea( xZBZ )
			DbGoTo( nReczbz )
			cXml   := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML")))
			
			oXml := XmlParser( cXml, "_", @cError, @cWarning )
			
			If Empty(cError) .And. Empty(cWarning) .And. oXml <> Nil
				
				//----------------------------------------------------------------//
				//FR - 18/08/2020 - Kroma - XML Energia - Definido pelo NCM e CFOP
				// Início da Checagem
				//-------------------------------------------------------------------------//
				cError       := ""
				cWarning     := ""
				oDet         := NIL
				cTagAux      := ""
				cCFOPEnergia := GetNewPar("XM_CFOENERG","5251,6251,5123,6123,5922,6922")	//deixar aqui mesmo porque é algo que não mudará
				cCFOP        := ""
				lEnergia     := .F.
				//oDet 		 := {}
				oObj 		 := NIL
				lTagVenc	 := .T.		//indica se existe a tag do vencimento ou não
				cDataPartir  := ""  	//FR - 13/11/2020
				If cModelo $ "55,65"
					If Type( "oXml:_NFEPROC:_NFE:_INFNFE:_DET" ) == "U"
						oDet := oXml:_NFEPROC:_NFE:_INFNFE:_DET
						oDet := IIf(ValType(oDet)=="O",{oDet},oDet)
					Else
						oDet := {}
					Endif
					
					If Len(oDet) > 0
						For i := 1 To Len(oDet)
							
							//CFOP do produto
							cTagAux := "oDet["+AllTrim(str(I))+"]:_PROD:_CFOP:TEXT"
							//If type( cTagAux ) <> "U"
							cCFOP := (&cTagAux)
							If cCFOP $ cCFOPEnergia
								lEnergia := .T.
								lRet     := lEnergia
								Exit
							Endif
							//Endif
						Next
					Endif
				Endif
				
				//lRet := lEnergia
				
				If lEnergia
					DbSelectArea( xZBZ )
					DbGoTo( nReczbz )
					If Empty(  (xZBZ)->(FieldGet(FieldPos(xZBZ_+"COMBUS")))  )
						If RecLock( xZBZ, .F. )
							(xZBZ)->(FieldPut(FieldPos(xZBZ_+"COMBUS"), "E" ))
							(xZBZ)->( MsUnlock() )
						Endif
					Endif
				Endif
								
				//-------------------------------------------------------------------------//
				// Fim da Checagem
				//-------------------------------------------------------------------------//
				
				//--------------------------------//
				//Atualiza ZBZ - campo ZBZ_COMBUS
				//--------------------------------//
				If lEnergia .and. !lSoCheck
					
					DbSelectArea("TMPE1")	
				
					If cModelo $ "55,65"
						
						If cModelo == "55"
							cPref    := "NF-e"
						Else
							cPref    := "NFC-e"
						EndIf
						
						cTAG     := "NFE"
						cTGP     := "NFE"
						nFormXML := nFormNfe
						cVerOk   := cVerNFE
						
					ElseIf cModelo == "57"
						
						cPref    	:= "CT-e"
						cTAG     	:= "CTE"
						cTGP        := "CTE"
						nFormXML 	:= nFormCte
						cVerOk   	:= cVerCTE
						
					ElseIf cModelo == "67"
						
						cPref    	:= "CT-eOS"
						cTAG     	:= "CTE"
						cTGP        := "CTEOS"
						nFormXML 	:= nFormCte
						cVerOk   	:= cVerCTE
						
					EndIf
					
					cVencto	:= ""
					cValnf	:= ""
					cCNPJ	:= ""
					cNF		:= ""
					cSerie	:= ""
					cEmiNF	:= ""
					cEmissao:= ""
					cTagAux := ""
					nConta  := 0
					//------------------------//
					//campos chave da pesquisa
					//------------------------/

					cTagAux   := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_EMIT:_CNPJ:TEXT"
					cCNPJ     := &(cTagAux)
						
					//  NFEPROC:_NFE:_INFNFE:_IDE
					cTagAux   := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_NNF:TEXT"
					cNF       := &(cTagAux)
						
					//  NFEPROC: _NFE:_INFNFE:_IDE
					cTagAux   := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_SERIE:TEXT"
					cSerie    := &(cTagAux)
						
					//  NFEPROC:_NFE:_INFNFE:_IDE
					cTagAux   := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_DHEMI:TEXT"
					cAux      := &(cTagAux)
					cEmissao  := Substr(cAux,9,2) + Substr(cAux,6,2) + Substr(cAux,1,4)		//2020-10-24 vem assim no xml -> fica assim: 24102020
					cEmiNF    := cEmissao       //ficará no formato DDMMAAAA ex: 30072020 diamesano
					
					//FR - 13/11/2020 - filtro de data de emissão da nota a ser regido pelo parâmetro XM_KRDIASR
					cDataPartir := Substr(cEmiNF,1,2) + "/" + Substr(cEmiNF,3,2) + "/" + Substr(cEmiNF,5,4)
					If CtoD(cDataPartir) >= dDataPartir	
										
						//Checagem da tag do vencimento, se existe a tag
											 //  NFEPROC:_NFE:_INFNFE:_COBR:_DUP:_DVENC:TEXT					
						oObj := oXml:_NFEPROC:_NFE  //:_INFNFE  //coloco neste objeto pra poder validar os "nós" existentes	
						nConta := XmlChildCount(oObj:_INFNFE)	//conta os nós do xml a partir do _INFNFE
						If nConta >= 11
							oObj := XmlGetChild(oXML:_NFEPROC:_NFE:_INFNFE, 9)	//tentar pegar o 9o. elemento pra checar se existe a tag	
							cName:= oObj:REALNAME
							If UPPER(cName) == "COBR"
								//Se passou da 1a. verificação, ver se tem a tag _DUP						
								oObj := oXml:_NFEPROC:_NFE:_INFNFE
								nConta := XmlChildCount(oObj:_COBR)
								If nConta >= 2		//se for >= 2, é porque tem a tag _DUP
									cTagAux   := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_COBR:_DUP:_DVENC:TEXT"
									cAux      := &(cTagAux)
									cVencto   := Substr(cAux,1,4) + Substr(cAux,6,2) + Substr(cAux,9,2)  //vem 2020-07-30 AAAA-MM-DD, ficará 20200730 AAAAMMDD
								
									//  NFEPROC:_NFE:_INFNFE:_COBR:_DUP:_VDUP:TEXT
									cTagAux   := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_COBR:_DUP:_VDUP:TEXT"
									cValnf    := &(cTagAux)
								Else
									lTagVenc := .F.	//não tem a tag do vencimento, então será calculado pelo 6o. dia útil a partir da emissão da NF															
								Endif
							Else  //if UPPER(cName) = "PAG"
								lTagVenc := .F.
							Endif						
						Else	
							lTagVenc := .F.						
						Endif
	
						If !lTagVenc	//não tem a tag do vencimento, então será calculado pelo 6o. dia útil a partir da emissão da NF													
							//para obter o valor total do produto, pegarei da tag do detalhe:
							//  NFEPROC:  _NFE:   _INFNFE:     _DET:
							cTagAux := "oXml:_" + cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_DET"
							oDet := &(cTagAux)
							oDet := IIf(ValType(oDet)=="O",{oDet},oDet)
	
							//vlr total produto
							cTagAux    := "oDet["+AllTrim(str(I))+"]:_PROD:_VPROD:TEXT"
							cValnf    := UPPER(&cTagAux)
	
							//If nDiasUteis > 0		//RETIRADO A PEDIDO DE LEONARDO DA KROMA //FR 03/11/2020
								//cVencto := U_fSextoDU(cEmiNF,nDiasUteis) //traz a data do 6o. dia útil do mês da emissão da NF, formato AAAAMMDD
								//Exemplo: se emissão = 01/09/2020, o 6o. dia útil será = 09/09
								//alert("vencimento: " + cVencto)
								//FR 03/11/2020 - Leonardo da Kroma solicitou que quando não houver vencimento no xml, assumir a data que está no campo C7_EMISSAO
								cVencto := "PC"    //FR 03/11/2020 - não utilizará mais o parâmetro XM_DIASVCT, pegará direto do pedido de compra
							//Endif						
						Endif									
						
						//------------------------//
						//campos chave da pesquisa
						//------------------------//
						//Utiliza os 3 campos acima para pesquisar nos pedidos de compra deste fornecedor, se existe PC com este valor e vencimento
						//classifica a nf, caso não sejam encontrado PC com estas informações, não classifica e grava na tabela de ocorrências (ZBO)
						//motivo da não classificação.
						lTemPC    := .F.
						lCondicao := .F.
	
						If !Empty(cVencto) .and. !Empty(cValnf) //se não existir ao menos essas duas informações, não prossegue e vai para o próximo XML
							
							aVerPC := U_fVerPCEnergia(cCNPJ,cVencto,cValnf,cEmiNF,lTagVenc)
							cCondPC := aVerPC[8]													//FR 03/11/2020
							lCondicao := (!Empty(cCondPC)) //se estiver vazio, não irá prosseguir 	//FR 03/11/2020
							If Len(aVerPC) > 0
								If !Empty(aVerPC[1]) 							
									If aVerPC[6] .and. aVerPC[7] //se o vencimento e valor batem
										lTemPC := .T.
										cCondPC := aVerPC[8]
										lCondicao := (!Empty(cCondPC)) //se estiver vazio, não irá prosseguir
									Endif
								Else
									lTemPC    := .F.
									lCondicao := .F.
								Endif						
							Else
								lTemPC := .F.
							Endif
							//lTemPC := .T.      	//FR TESTE RETIRAR
							
							If lTemPC .and. lCondicao
								
								//  NFEPROC:  _NFE:   _INFNFE:    _EMIT:
								cTagAux:= "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_EMIT:_XNOME:TEXT"
								cRazao := &(cTagAux)
								
								cTagAux   := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_EMIT:_ENDEREMIT:_XLGR:TEXT"
								cEndereco := &(cTagAux)
								
								cTagAux   := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_EMIT:_ENDEREMIT:_NRO:TEXT"
								cNumero   := &(cTagAux)
								
								cTagAux   := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_EMIT:_ENDEREMIT:_XBAIRRO:TEXT"
								cBairro   := &(cTagAux)
								
								cTagAux   := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_EMIT:_ENDEREMIT:_XMUN:TEXT"
								cMun     := &(cTagAux)
								
								cTagAux   := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_EMIT:_ENDEREMIT:_CEP:TEXT"
								cCEP      := &(cTagAux)
								
								cTagAux   := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_EMIT:_ENDEREMIT:_UF:TEXT"
								cUF       := &(cTagAux)
								
								cTagAux   := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_EMIT:_CNPJ:TEXT"
								cCNPJ     := &(cTagAux)
								
								cTagAux   := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_EMIT:_IE:TEXT"
								cIE       := &(cTagAux)
								//  NFEPROC:  _NFE:   _INFNFE:    _IDE
								cTagAux   := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_NNF:TEXT"
								cNF       := &(cTagAux)
								
								//  NFEPROC:  _NFE:   _INFNFE: _IDE
								cTagAux   := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_SERIE:TEXT"
								cSerie    := &(cTagAux)
								
								//  NFEPROC:  _NFE:   _INFNFE:     _IDE
								cTagAux   := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_DHEMI:TEXT"
								cAux      := &(cTagAux)
								cEmissao  := Substr(cAux,9,2) + Substr(cAux,6,2) + Substr(cAux,1,4)
								
								//  NFEPROC:  _NFE:    _INFNFE:    _DEST
								cTagAux   := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_DEST:_CNPJ:TEXT"
								cCNPJDEST := &(cTagAux)
								
								//  NFEPROC:  _NFE:    _INFNFE:     _COBR:_DUP:_VDUP:
								//cTagAux   := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_COBR:_DUP:_VDUP:TEXT"
								cVNF      := cValNF //&(cTagAux)
	
								///impostos - não serão utilizados pela Kroma
								/* 
								//  NFEPROC:  _NFE:    _INFNFE:    _TOTAL:_ICMSTOT:_VBC:TEXT
								cTagAux   := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_TOTAL:_ICMSTOT:_VBC:TEXT"
								cBcicms   := &(cTagAux)
									
								//  NFEPROC:  _NFE:    _INFNFE:    _TOTAL:_ICMSTOT:_VICMS:TEXT
								cTagAux   := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_TOTAL:_ICMSTOT:_VICMS:TEXT"
								cVicms   := &(cTagAux)
									
								nAliqicm := Val(cVicms) / Val(cBcicms)
									
								//  NFEPROC:  _NFE:    _INFNFE:    _TOTAL:_ICMSTOT:_VIPI:TEXT
								cTagAux   := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_TOTAL:_ICMSTOT:_VIPI:TEXT"
								cVipi     := &(cTagAux)
									
								//  NFEPROC:  _NFE:    _INFNFE:    _TOTAL:_ICMSTOT:_VIPI:TEXT
								//cTagAux   := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_TOTAL:_ICMSTOT:VIPI:TEXT"
								cBipi     := cBcicms
									
								//  NFEPROC:  _NFE:    _INFNFE:    _COBR:_FAT:_VDESC:TEXT
								//cTagAux   := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_COBR:_FAT:_VDESC:TEXT"
								//cDesc     := &(cTagAux)
								*/
								///impostos
								
								//FR - obtive esta estrutura da função MontaNota, para poder usufruir das mesmas funções de classificação usadas nas nfs combustíveis
								aLin[01] := cRazao 		//Substr(cBuf,004,073) //Razao
								aLin[02] := cEndereco 	//Substr(cBuf,074,103) //Enderco
								aLin[03] := cNumero 	//Substr(cBuf,104,005) //numero
								aLin[04] := cBairro 	//Substr(cBuf,109,035) //Bairro
								aLin[05] := cMun 		//Substr(cBuf,144,035) //Mun
								aLin[06] := cCEP 		//Substr(cBuf,179,010) //CEP
								aLin[07] := cUF 		//Substr(cBuf,189,002) //UF
								aLin[08] := cCNPJ 		//Substr(cBuf,191,014) //CNPJ_CPF
								aLin[09] := "BR" 		//Substr(cBuf,205,002) //BR
								aLin[10] := cIE 		//Substr(cBuf,207,020) //Inscricao_Estadu
								aLin[11] := cNF 		//Substr(cBuf,227,009) //Num_NF
								aLin[12] := cSerie 		//Substr(cBuf,236,003) //Serie
								aLin[13] := Space(3) 	//Substr(cBuf,239,003) //SubSerie
								aLin[14] := cEmissao 	//Substr(cBuf,242,008) //Dt_Lancamento
								aLin[15] := cEmissao 	//Substr(cBuf,250,008) //Dt_Emissao
								aLin[16] := cCNPJDEST 	//Substr(cBuf,258,014) //CNPJ_Destino
								aLin[17] := cChave 		//Substr(cBuf,272,044) //Chave
								aLin[18] := cVNF 		//Substr(cBuf,316,015) //Valor Total Nota  FAZER O VAL
								aLin[19] := cVNF 		//Substr(cBuf,331,015) //Valor Total Nota  FAZER O VAL
								aLin[20] := cCondPC		//Código da condição de pagto no pedido de compra
								
								aadd( aCab, aClone(aLin) )
								
								//  NFEPROC:  _NFE:   _INFNFE:     _DET:
								cTagAux := "oXml:_" + cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_DET"
								oDet := &(cTagAux)
								oDet := IIf(ValType(oDet)=="O",{oDet},oDet)
								
								For I := 1 to Len(oDet)
									
									//item
									cTagAux    := "oDet["+AllTrim(str(I))+"]:_NITEM"
									cItem      := &(cTagAux)
									
									//código produto
									cTagAux    := "oDet["+AllTrim(str(I))+"]:_PROD:_CPROD:TEXT"
									cProduto := UPPER(&cTagAux)								
									
									//descrição
									cTagAux    := "oDet["+AllTrim(str(I))+"]:_PROD:_XPROD:TEXT"
									cDesc      := UPPER(&cTagAux)
									
									//qtde
									cTagAux    := "oDet["+AllTrim(str(I))+"]:_PROD:_QCOM:TEXT"
									cQt       := UPPER(&cTagAux)
									
									//um
									cTagAux    := "oDet["+AllTrim(str(I))+"]:_PROD:_UCOM:TEXT"
									cUm       := UPPER(&cTagAux)
									
									//vlr unit
									cTagAux    := "oDet["+AllTrim(str(I))+"]:_PROD:_VUNCOM:TEXT"
									cValuni    := UPPER(&cTagAux)
									
									//cfop
									cTagAux    := "oDet["+AllTrim(str(I))+"]:_PROD:_CFOP:TEXT"
									cCFOP      := UPPER(&cTagAux)			
																	
									nAliqipi := 0 //Val(cVipi) / Val(cBipi)
									nAliqicm := 0
									cBcicms  := ""
									cVicms   := ""
									cBipi    := ""
									cVipi    := ""
									
									aDet[01] := cChave
									aDet[02] := cItem 		//Substr(cBuf,001,007) //Id_Item
									aDet[03] := cProduto 	//Substr(cBuf,008,020) //Cod_Produto
									aDet[04] := cDesc 		//Substr(cBuf,028,040) //Descricao_Nota
									aDet[05] := cQt 		//Substr(cBuf,068,013) //Quantidade 13,4 FAZER O VAL
									aDet[06] := cUm 		//Substr(cBuf,081,003) //Unidade de medida
									aDet[07] := cValuni 	//Substr(cBuf,084,015) //Vlr_Unitario FAZER O VAL
									aDet[08] := cCFOP 		//Substr(cBuf,099,010) //CFOP
									aDet[09] := cBcicms 	//Substr(cBuf,109,015) //Base_Calculo_ICMS  FAZER O VAL
									aDet[10] := Alltrim(Str(nAliqicm)) //Substr(cBuf,124,008) //Aliquota_ICMS  FAZER O VAL
									aDet[11] := cVicms 		//Substr(cBuf,132,015) //Vlr_Imposto_ICMS  FAZER O VAL
									aDet[12] := cBipi 		//Substr(cBuf,147,015) //Base_Calculo_IPI  FAZER O VAL
									aDet[13] := Alltrim(Str(nAliqipi)) //Substr(cBuf,162,008) //Aliquota_IPI  FAZER O VAL
									aDet[14] := cVipi 		//Substr(cBuf,170,015) //Vlr_Imposto_IPI  FAZER O VAL
									aDet[15] := cDesc 		//Substr(cBuf,185,015) //Vlr_Desconto  FAZER O VAL
									aDet[16] := aVerPC[1]	//Número pedido compra
									aDet[17] := aVerPC[10]	//Item pedido compra
									aDet[18] := cNF			//Numero da nf para depois buscar no array de itens
	
									aadd( aIte, aClone(aDet) )
								Next
								
							Else
								//grava ocorrência														
								If !Empty(aVerPC[1])
									If aVerPC[6] .and. aVerPC[7] //se o vencimento e valor batem
										lTemPC := .T.
									Else
										cMsg := ""
										If !Empty(aVerPC[4])
											cMsg += aVerPC[4] + "; "
										Endif
											
										If !Empty(aVerPC[5])
											cMsg += aVerPC[5] + "; "
										Endif
									Endif
										
									If !lCondicao
										cMsg += "Condicao de Pagto Inexistente no PC; "		//FR 03/11/2020
									Endif
										
									aRet[1] := "N"
									aRet[2] := "NF: " + Strzero(Val(cNF),9) + "-> Pedido Encontrado, Porem:" + cMsg
									aRet[3] := "0"
										
								Else
									aRet[1] := "N"
									aRet[2] := "NF: " + Strzero(Val(cNF),9) + "-> Pedido Nao Encontrado"
									aRet[3] := "0"
								Endif								
								
								cChaveNF := cChave
								cHora    := Time()
								//cArqTXT  := "ENERGIA_" + Substr(Dtos(dDatabase),1,4) + "_" + Substr(Dtos(dDatabase),5,2) + "_" + Substr(Dtos(dDatabase),7,2) + "_" + Substr(cHora,1,2)+Substr(cHora,4,2)+Substr(cHora,7,2)+".TXT"//2020_04_27_150827
								cArqTXT  := "ENERGIA_NF_" + Strzero(Val(cNF),9) + "-" + cSerie + "_.TXT"  //FR 16/11/2020 //Nome ficará assim: ENERGIA_NF_<num nf> - <serie>_.TXT
								
								(xZBO)->(OrdSetFocus(4))							
								If (xZBO)->( dbSeek( xFilial(xZBO) + "1" + AllTrim(cChave) + cArqTxt ) )	//ZBO_FILIAL + ZBO_TPOCOR + ZBO_CHAVE + ZBO_ARQ //FR 16/11/2020
									If (xZBO)->( FieldGet( FieldPos( xZBO_+"ST" ) ) ) <> "2"
										lCor   := .T.
									EndIF
								Endif
								
								//povoa array aZbo:
								If nPFil > 0
									aZBO[nPFil][4] := xFilial( xZBO )		//ZBO_FILIAL
								Endif
								
								//nPCod  //Se o código for zero, vai somar 1
								If nPDes > 0
									aZBO[nPDes][4] := aRet[2] //"Erro no execauto de classificação NF "+aReg[01]+" Serie "+aReg[02]
								Endif
								
								//If .NOT. lCor		//FR - 16/11/2020 - para NF Energia não será utilizada esta condição
									If nPDto > 0
										aZBO[nPDto][4] := CtoD(cDataPartir) //dDataBase  //FR - 13/11/2020 - Kroma solicitou gravar a data de emissão da NF
									Endif
									
									If nPHro > 0
										aZBO[nPHro][4] := Time()
									Endif
									
									If nPChv > 0
										aZBO[nPChv][4] := cChave //aReg[4]
									Endif
									
									If nPTpo > 0
										aZBO[nPTpo][4] := "1"
									Endif
									
									If nPArq > 0
										aZBO[nPArq][4] := cArqTxt
									EndIf
									
									//If nPExa > 0
									//	aZBO[nPExa][4] := ""
									//	If lMsErroAuto
									//		aLog := GetAutoGRLog()	                  //Efetua o Tratamento para validar se o arquivo de Log Já Existe
									//		For nX := 1 To Len(aLog)
									//			aZBO[nPExa][4] += aLog[nX]+CHR(13)+CHR(10)
									//		Next nX
									//	Endif
									//EndIf
									
								//EndIF	//FR 16/11/2020
								
								If nPStt > 0
									If aRet[1] = "S"  //Classificado direto e reto
										aZBO[nPStt][4] := "0"
									Else
										aZBO[nPStt][4] := iif( lCor, "2", "1" )
									Endif
								EndIf
								
								If aRet[1] = "S"  //Marcar como email enviado para não enviar novamente
									If nPMai > 0
										aZBO[nPMai][4] := "2"
									EndIf
								Else
									aZBO[nPMai][4] := " " //FR - 10/07/2020 - sem ação para log mas envia email aos envolvidos (só envia se o campo ZBO_MAIL estiver = '' ou '1'
								Endif
								//fim povoa aZbo
								
								If U_HF13ZBOG( .F., 4, xFilial(xZBO)+"1"+AllTrim(cChave)+cArqTxt, aZBO, cChaveNF )
									Conout("<GESTAOXML> GRAVOU ZBO - PEDIDO COMPRA INEXISTENTE OU NAO CONFERE")								
								Endif
								
							Endif		//If lTemPC .and. lCondicao
							
						Endif 	//se vazio vencto e valor nf					
					Endif   //se está dentro de dDataPartir	  //FR 16/11/2020				
				Endif 		//if lEnergia
			Endif			//error no parse do xml
			
			DbSelectArea("TMPE1")
			TMPE1->(Dbskip())
		Enddo	
		
		dbSelectArea("TMPE1")
		TMPE1->(dbCloseArea())
		
	Endif  //IF !eof 2o.
	
Endif  //if !eof 1o.


Return(lRet)

//----------------------------------------------------------//
//FR - 18/08/2020 
//Verifica se existem Pedidos de Compras respectivos aos XMLs 
//de energia, somente com pedido de compra, e se bater
//Vencimento e Valor, procede com a classificação
//Caso contrário, grava na tabela de ocorrências (ZBO) 
//e envia por email aos envolvidos (parâmetro XM_MAIL07)
//----------------------------------------------------------//
*****************************************************************
User Function fVerPCEnergia(cCNPJ,cVencto,cValnf,cEmiNF,lTagVenc)
*****************************************************************
Local cQuery 	:= ""
Local cPedido	:= "" 
Local cItemPed  := ""
Local cCond		:= ""
Local nTotal 	:= 0
Local fr		:= 0 
Local nPos		:= 0
Local dVencPC	:= Ctod("  /  /    ")
Local dVencTit  := Ctod("  /  /    ")
Local aRet1     := Array(9) 
Local aRet		:= {}
Local aVencPC   := {}
Local cPcAnt    := ""
Local LF		:= CHR(13) + CHR(10)
Local dEmiNF	:= Ctod("  /  /    ")
Local dEmiPC    := Ctod("  /  /    ")
Local dVencXML  := ""
Local nDifDias  := 0		//usado para saber o intervalo de dias do prazo de pagamento 
Local lAlterCond:= .F.
//Local nDiasUteis := GetNewPar("XM_DIASVCT", 0)		//Indica qtos dias uteis serão usados para calcular o vencimento da nf energia no caso de não haver a tag do vencimento
Local lBateu    := .F.
Local lTemZBC   := .F.
Local lAchou    := .F.

cQuery := " SELECT  " + LF
cQuery += " A2_CGC, A2_COD, A2_NOME, "			+ LF
cQuery += " C7_FILIAL C7FILIAL, C7_NUM C7NUM, C7_ITEM C7ITEM, C7_PRODUTO, C7_COND, C7_TOTAL, C7_EMISSAO, C7_TOTAL, SC7.R_E_C_N_O_ RECSC7, "	+ LF
cQuery += " C7_FORNECE, C7_LOJA, C7_QUANT , C7_QUJE, C7_QTDACLA "	+ LF
cQuery += " FROM "       + RetSqlName("SA2") + " SA2 "		+ LF

cQuery += " INNER JOIN " + RetSqlName("SC7") + " SC7 " 		+ LF
cQuery += " ON C7_FORNECE = A2_COD AND C7_LOJA = A2_LOJA " 	+ LF
cQuery += " AND SC7.D_E_L_E_T_ <> '*' "			+ LF
cQuery += " AND SC7.C7_FILIAL = '" + Alltrim(xFilial("SC7")) + "' " + LF

cQuery += " WHERE "								+ LF
cQuery += " SA2.D_E_L_E_T_ <> '*'     " 		+ LF 
cQuery += " AND A2_CGC = '" + cCNPJ + "' "	 	+ LF
cQuery += " AND (C7_QUANT-C7_QUJE-C7_QTDACLA)>0 " + LF		//somente pedidos com saldo em aberto
//FR 03/11/2020 - se o xml tiver tag de vencimento, filtra já pelo mês da emissão do pedido para agilizar:
If cVencto != "PC"
	cQuery += " AND MONTH(C7_EMISSAO) = " + Substr(cVencto,5,2) 
Else
	
Endif

cQuery += " ORDER BY C7_FILIAL , C7_EMISSAO , C7_NUM "	+ LF	

MemoWrite("C:\TEMP\PCXMLENERGIA.SQL" , cQuery)

If Select("TMPPC1") > 0
	dbSelectArea("TMPPC1")
    TMPPC1->(dbCloseArea())
EndIf

cQuery := ChangeQuery(cQuery)		//FR 03/11/2020
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPPC1", .T., .F. )
DbSelectArea("TMPPC1")
DbGoTop() 

If TMPPC1->(!Eof())

	dEmiNF  := StoD( Substr(cEmiNF,5,4) + Substr(cEmiNF,3,2) + Substr(cEmiNF,1,2) ) 		//vem assim 07082020 -> fica assim 07/08/2020  			
	dVencTit:= Ctod("  /  /    ")
	lAchou  := .F.				//FR - 14/12/2020
	
	While TMPPC1->(!Eof()) 	
	    
		//-----------------------------------------------------------------------------------------------------------------------//  								
		//FR os pedidos de compra da base da Kroma, são gravados via integração (vem de outro sistema chamado iosys)
		//a data gravada no campo C7_EMISSAO, não é a database, mas sim a data do vencimento da nota de energia
		//por isso, é possível comparar o vencimento, pois C7_EMISSAO PRECISA ser igual ao vencimento da nf
		//Vencimento no XML : Contido na tag: _COBR:_DUP:_DVENC:TEXT
		//Através da função padrão TOTVS: Condicao() , obtenho o vencimento da duplicata, passando por parâmetro 
		//a data de emissão da NF (pego do xml)	--> tag: NFEPROC:_NFE:_INFNFE:_IDE:_DHEMI:TEXT"
		//-----------------------------------------------------------------------------------------------------------------------//  
		cObs04 := ""			//FR - 14/12/2020   
		cObs05 := ""			//FR - 14/12/2020	
		If !lAchou   			
			If Val(cValnf) == TMPPC1->C7_TOTAL		//se o total for igual
			    
			    //FR - 23/11/2020
				dEmiPC  := TMPPC1->C7_EMISSAO		 //FR vem assim 20200911
			    cPedido := TMPPC1->C7NUM
				cItemPed:= TMPPC1->C7ITEM
			    cCond   := TMPPC1->C7_COND
			    nTotal  := TMPPC1->C7_TOTAL
			    nRecSC7 := TMPPC1->RECSC7
		    	dVencPC := dEmiPC 
		    	//FR - 23/11/2020
	    		
		    	//FR - 14/12/2020
		    	If cVencto == "PC"	  //FR - qdo não tem tag de vencimento no XML, considera o vencimento que está no PC, então eu defini "PC" para saber qdo isso ocorre
			    	dVencXML := Stod(TMPPC1->C7_EMISSAO)
			    	lAchou   := .T.   //qdo o vencimento é "PC", ou seja, não tem tag de vencimento, assume o vencto do pedido, então se bateu valor, e caiu aqui, lAchou recebe .T.
			    Else
			    	dVencXML:= StoD(cVencto)  //cVencto vem assim 20200730 -> 30/07/2020 
			    	
			    	If cVencto == dVencPC //AAAAMMDD == AAAAMMDD esse é o formato que está dentro da variável				    	
				    	lAchou := .T.
				    Endif
				    
			    Endif
			    //FR - 14/12/2020			    
		    	
		    	If lAchou      //Se ACHOU Total == XML / Vencto == XML, já pára por aqui , não lê mais os demais registros
		    		aRet := {}	//limpa para ficar somente o que bateu tudo		    	
				Else
					cObs04 := "Vencto Nao Confere"
				Endif	
				Aadd( aRet , { ;
							cPedido,;				//01-num pedido
							nTotal,;    			//02-total pedido
							dVencPC,;   			//03-vencimento em formato AAAAMMDD
							cObs04,;				//04-vencto ok
							"",;        			//05-valor ok
							.F.,;       			//06-valor lógico que irá validar se o vencto está ok
							.F.,;       			//07-valor lógico que irá validar se o valor está ok 
							cCond,;					//08-código da condição de pagto do pedido 
							nRecSC7,;				//09-recno do SC7 a ser usado em caso de alteração da condição de pagamento
							cItemPed,;				//10-item pedido
							TMPPC1->C7FILIAL,;		//11-filial
							TMPPC1->C7_FORNECE,;	//12-cod.fornecedor
							TMPPC1->C7_LOJA,;		//13-loja
							TMPPC1->C7_PRODUTO;		//14-codigo produto						
							} )	
				//FR - 14/12/2020
			    	    
			Else	//FR - 14/12/2020 - se o valor não bater, cria o array mesmo assim, mas com a OBS do valor já preenchida (cObs05), para otimizar o processamento
				
				//FR - 14/12/2020		
				dEmiPC  := TMPPC1->C7_EMISSAO		 //FR vem assim 20200911
			    cPedido := TMPPC1->C7NUM
				cItemPed:= TMPPC1->C7ITEM
			    cCond   := TMPPC1->C7_COND
			    nTotal  := TMPPC1->C7_TOTAL
			    nRecSC7 := TMPPC1->RECSC7
		    	dVencPC := dEmiPC 	    	
		        cObs05  := "Valor Nao Confere"
		        
		    	If cVencto == "PC"
			    	dVencXML := Stod(TMPPC1->C7_EMISSAO)
			    Else
			    	dVencXML:= StoD(cVencto)  //cVencto vem assim 20200730 -> 30/07/2020 
			    Endif
			    //FR - 14/12/2020
		    	 
				Aadd( aRet , { ;
							cPedido,;				//01-num pedido
							nTotal,;    			//02-total pedido
							dVencPC,;   			//03-vencimento em formato AAAAMMDD
							"",; 					//04-vencto ok
							cObs05,;			 	//05-valor ok
							.F.,;       			//06-valor lógico que irá validar se o vencto está ok
							.F.,;       			//07-valor lógico que irá validar se o valor está ok 
							cCond,;					//08-código da condição de pagto do pedido 
							nRecSC7,;				//09-recno do SC7 a ser usado em caso de alteração da condição de pagamento
							cItemPed,;				//10-item pedido
							TMPPC1->C7FILIAL,;		//11-filial
							TMPPC1->C7_FORNECE,;	//12-cod.fornecedor
							TMPPC1->C7_LOJA,;		//13-loja
							TMPPC1->C7_PRODUTO;		//14-codigo produto						
							} )
				
			Endif	//se o total for igual
		Endif   //se lAchou = .F.
		DbSelectArea("TMPPC1")		
		TMPPC1->(Dbskip())	
					    
   	Enddo
   	
   	cVcto	:= ""
   	nVlr  	:= 0
   	cCond 	:= ""
   	aVencPC := {}
   	nTotal  := 0   	
   	
   	If Len(aRet) > 0
   		For fr := 1 to Len(aRet)    			
   			//====================================================================================================//    	
   			//FR - 14/12/2020 - se a posição em que se encontra a 'obs do valor' estiver vazia, executa esse 'if'		
   			//caso já estiver preenchida é porque o valor não confere, então nem executa a instrução abaixo
   			//====================================================================================================//    	
			If Empty( aRet[fr][5] ) //posição ref. a obs do valor											
				lBateu := .F.
				lTemZBC:= .F.
	   			nTotal := aRet[fr][2]
	   			cCond  := aRet[fr][8]
	   			
		   		If Empty(cCond)
					cCond      := U_fCalCond(0)	//se o pedido não tiver condição de pagamento cadastrada, coloco para buscar pelo "a vista"			
				Endif
	
				If lTagVenc //se encontrou a tag do vencimento executa o bloco abaixo, senão fará pelo 6o. dia útil
					aVencPC := Condicao(nTotal,cCond,,dEmiNF)
					dVencTit:= (aVencPC[1,1])		    
								
					If dVencXML <> dVencTit 
						//Se o vencimento projetado pela condição de pagamento do pedido não for igual ao vencimento do XML, alteraremos a condição do pedido para uma que atenda 
						nDifDias   := U_CalcDias( dEmiNF, dVencXML )   //( (StoD(dVencXML)) - dEmiNF ) 
						cCond      := U_fCalCond(nDifDias)
						lAlterCond := .T.
						aRet[fr][8]:= cCond					
					Endif
					cVcto := aRet[fr][3]
	
				Else							
					cVcto      := iif(cVencto == "PC" , aRet[fr][3],cVencto)		//FR 03/11/2020
					nDifDias   := U_CalcDias( dEmiNF, dVencXML )	//calcula a diferença em dias entre a emissão da NF e o Vencto
					cCond      := U_fCalCond(nDifDias)				//se o pedido não tiver condição de pagamento cadastrada, coloco para buscar pelo "a vista"			
					lAlterCond := .T.			
					aRet[fr][8]:= cCond	
				Endif
			
			Else //se a posição em que se encontra a 'obs do valor' não estiver vazia
				cVcto      := iif(cVencto == "PC" , aRet[fr][3],cVencto)		//FR 03/11/2020	    		    
   		    Endif	//FR - 14/12/2020 - Obs do valor vazia ?
   		     
   		    nVlr  := aRet[fr][2] 		//FR - 14/12/2020
   		       		    
   		    If cVencto == "PC"  					//FR 03/11/2020
   		    	aRet[fr][4] := "Vencimento OK"
		   		aRet[fr][6] := .T.
		   		
		 	Elseif cVencto == cVcto		//as datas no formato AAAAMMDD
		   		aRet[fr][4] := "Vencimento OK"
		   		aRet[fr][6] := .T.
		   	Else
		   		aRet[fr][4] := "Vencimento nao confere"
		   		
		   	Endif
		   		   		 
		   	If Val(cValnf) == nVlr
		   		aRet[fr][5] := "Valor OK"
		   		aRet[fr][7] := .T.  	
		   	Else
		   		aRet[fr][5] := "Valor nao confere"
		   			
		   	Endif			
		   	
		   	//If aRet[fr][6] .and. aRet[fr][7] 	//se já encontrar um pedido que bata valor e vencimento, já sai do loop		   	
		   	If cVencto == "PC"   	//FR 03/11/2020
				lBateu := .T.
				lTemZBC := U_fTemZBC(aRet[fr,12],aRet[fr,13],aRet[fr,14],"E")				
			ElseIf (cVencto == cVcto) .and. ( Val(cValnf) == nVlr )
				lBateu := .T.
			   	lTemZBC := U_fTemZBC(aRet[fr,12],aRet[fr,13],aRet[fr,14],"E")
				//Alert("Bateu PC => " + aRet[fr,1] )
			Endif

			If lBateu .and. lTemZBC

				//esse é o array de retorno, conterá apenas um pedido
				aRet1 := { aRet[fr,1],;		//01-numero pedido
						   aRet[fr,2],; 	//02-total pedido
						   aRet[fr,3],;  	//03-vencimento em formato C "30/07/2010"
					   	   aRet[fr,4],;   	//04-vencto ok
					   	   aRet[fr,5],;		//05-valor ok
					       aRet[fr,6],;   	//06-valor lógico que irá validar se o vencto está ok
					       aRet[fr,7],;    	//07-valor lógico que irá validar se o valor está ok 
					       aRet[fr,8],;   	//08-código da condição de pagto do pedido
					       aRet[fr,9],;   	//09-recno do Sc7
					       aRet[fr,10],;  	//10-item pedido
						   aRet[fr,11],;  	//11-filial
						   aRet[fr,12],; 	//12-cod. fornecedor
						   aRet[fr,13];   	//13-loja fornecedor
					   }
		   		Exit

		   	Else			

				aRet1 := { ;
					aRet[fr,1],;	//01-numero pedido
					aRet[fr,2],;    //02-total pedido
					"",;    		//03-vencimento em formato C "30/07/2010"
					aRet[fr][4],; 	//04-vencto ok
					aRet[fr][5],;   //05-valor ok
					aRet[fr,6],;   	//06-valor lógico que irá validar se o vencto está ok
					aRet[fr,7],;   	//07-valor lógico que irá validar se o valor está ok 
					aRet[fr,8],;	//08-código da condição de pagto do pedido
					0,;				//09-recno do Sc7
					"",;			//10-item pedido
					"",;			//11-filial
					"",;			//12-cod. fornecedor
					"";				//13-loja fornecedor
						} 

			Endif
		   			   	
	   	Next

	Endif
   	
	dbSelectArea("TMPPC1")
	TMPPC1->(dbCloseArea())
	
	//Se o vencimento e o valor baterem mas o código da condição de pagamento tiver que ser alterado, realiza aqui:
	If Len(aRet1) > 0 
		If aRet1[6] .and. aRet1[7] //se o vencimento e o valor batem, e só a condição de pagto do pedido está errada, proceder com alteração
			If lAlterCond
				//SC7->(Dbgoto(aRet1[9]))
				SC7->(OrdSetFocus(1))
				If SC7->(Dbseek(xFilial("SC7")+ aRet1[1] ))
					RecLock("SC7",.F.)
					SC7->C7_COND := aRet1[8] 		//Recebe a condição que foi recalculada perante o vencimento do XML
					SC7->(MsUnlock())				
				Endif
			Endif 
		Endif
	Endif  	
	   	
Else   //FR - 14/12/2020 - quando a query não retorna nenhum resultado, ou seja, "Pedido não encontrado

	aRet1 := { ;
				"",;	//01-numero pedido
			   	0,;     //02-total pedido
				"",;    //03-vencimento em formato C "30/07/2010"
				"",; 	//04-vencto ok
				"",;    //05-valor ok
				.F.,;   //06-valor lógico que irá validar se o vencto está ok
				.F.,;   //07-valor lógico que irá validar se o valor está ok 
				"",;	//08-código da condição de pagto do pedido
				0,;		//09-recno do Sc7
				"",;	//10-item pedido
				"",;	//11-filial
				"",;	//12-cod. fornecedor
				"";		//13-loja fornecedor
				} 

	dbSelectArea("TMPPC1")
	TMPPC1->(dbCloseArea())
	
Endif     

Return(aRet1)

//------------------------------------------------------------------------//
//FR - 14/09/2020 - Esta função captura o código da condição de pagamento 
//de acordo com o número de dias informado na variável nDifDias
//Exemplo: se nDifDias = 15, irá trazer uma condição de pagamento 
//em que o prazo seja 15 dias,
//REtorno: código da condição de pagamento
//------------------------------------------------------------------------//
********************************
User Function fCalCond(nDifDias)
********************************
Local cRetCond := ""
Local cQuery   := ""
Local LF	   := CHR(13) + CHR(10)
Local aArea    := GetArea()

DbSelectArea("SE4")
Aadd(aArea, SE4->(GetArea()) )

cQuery := " SELECT  " + LF
cQuery += " E4_FILIAL, E4_CODIGO, E4_TIPO, E4_COND, E4_DESCRI, E4_DDD "	+ LF
cQuery += " FROM "       + RetSqlName("SE4") + " SE4 "			+ LF

cQuery += " WHERE "								+ LF

cQuery += " SE4.D_E_L_E_T_ <> '*'     " 		+ LF
 
cQuery += " AND E4_TIPO = '1' "				 	+ LF   //Precisa ser tipo 1, pois o vencimento no Xml é um só
//Procura uma condição de pagamento que o prazo seja igual aos dias calculados entre a emissão da nf e o vencimento no xml
//ex.: se a diferença de dias for igual a 10, irá procurar uma condição de pagto em que o prazo seja 10 dias
cQuery += " AND E4_COND = '" + Alltrim(Str(nDifDias))    + "' " + LF 
If nDifDias = 0									//FR - 23/11/2020
	cQuery += " AND E4_DDD  = 'D' " + LF  		//qdo for "à vista" considera a data do dia
Else
	cQuery += " AND E4_DDD  = 'L' " + LF  		//fora o dia
Endif

cQuery += " AND E4_FILIAL = '" + Alltrim(xFilial("SE4")) + "' " + LF

MemoWrite("C:\TEMP\SE4_cond.SQL" , cQuery) 

cQuery := ChangeQuery( cQuery )		//FR - 13/11/2020
If Select("TMPSE4") > 0
	dbSelectArea("TMPSE4")
    TMPSE4->(dbCloseArea())
EndIf

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPSE4", .T., .F. )
DbSelectArea("TMPSE4")
DbGoTop() 

If TMPSE4->(!Eof())

	While TMPSE4->(!Eof())
	   	cRetCond := TMPSE4->E4_CODIGO
		TMPSE4->(Dbskip())		
	Enddo
	dbSelectArea("TMPSE4")
    TMPSE4->(dbCloseArea())

Else //não existe condição que atenda esse número de dias então, criarei uma

	cQuery := " SELECT MAX(E4_CODIGO) AS CODCOND " + LF		//Seleciona o max de E4_CODIGO, para saber o último código de cond. pagto usado
	cQuery += " FROM "       + RetSqlName("SE4") + " SE4 "			+ LF

	cQuery += " WHERE "								+ LF
	cQuery += " SE4.D_E_L_E_T_ <> '*'     " 		+ LF
	cQuery += " AND E4_FILIAL = '" + Alltrim(xFilial("SE4")) + "' " + LF
	cQuery += " AND LEFT(E4_CODIGO,1) = 'E' " 		+ LF
	
	If Select("TMPSE4") > 0
		dbSelectArea("TMPSE4")
		TMPSE4->(dbCloseArea())
	EndIf

	cQuery := ChangeQuery( cQuery )		//FR - 13/11/2020
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPSE4", .T., .F. )
	DbSelectArea("TMPSE4")
	DbGoTop() 

	If TMPSE4->(!Eof())
		//cRetCond := Soma1(TMPSE4->CODCOND,Len(SE4->E4_CODIGO))		//se encontrar, soma 1
		If !Empty(TMPSE4->CODCOND)
			cRetCond := "E" + StrZero( Val( SubStr( TMPSE4->CODCOND ,2 , 2 ) ) + 1 , 2 )
		Else
			cRetCond := "E00"			
		Endif
		dbSelectArea("TMPSE4")
		TMPSE4->(dbCloseArea())
	Else										//se não, será a 1a. 
		cRetCond := "E00"
		dbSelectArea("TMPSE4")
		TMPSE4->(dbCloseArea())
	Endif

	//Nova checagem para ter certeza que não há esta condição de pagamento com este código:
	DbSelectArea("SE4")
	OrdSetFocus(1)
	While SE4->(Dbseek(xFilial("SE4") + cRetCond ))		//procura para checar se já existe
		cRetCond := "E" + StrZero( Val( SubStr( cRetCond ,2 , 2 ) ) + 1 , 2 )
	Enddo
	//Cria a condição na SE4:
	RecLock("SE4", .T.)	
	SE4->E4_FILIAL := xFilial("SE4")
	SE4->E4_CODIGO := cRetCond
	SE4->E4_TIPO   := '1'
	SE4->E4_COND   := Alltrim(Str(nDifDias))		//número de dias da condição
	SE4->E4_DESCRI := Alltrim(Str(nDifDias)) + " - DIAS "
	If nDifDias = 0					//FR - 23/11/2020
		SE4->E4_DDD    := "D" 		//data do dia qdo "à vista"
	Else
		SE4->E4_DDD    := "L" 		//fora o dia
	Endif							//FR - 23/11/2020
	/*
	Opções do campo E4_DDD - Dias da Condição
	D - Data do Dia
	L - Fora o Dia
	S - Fora Semana
	Q - Fora Quinzena
	F - Fora mês
	Z - Fora Dezena
	*/	
	SE4->(MsUnlock())

Endif

Restarea( aArea )

Return(cRetCond)

//FR - função que calcula o 6o. dia útil a partir de uma data inicial informada
*****************************************
User Function fSextoDU(cEmiNF,nDiasUteis)
*****************************************
Local cVencto := ""
Local dAux    := ""
Local dSexto  := Ctod("  /  /    ")
Local nConta  := 1

dAux   := Ctod( Substr(cEmiNF,1,2) + "/" + Substr(cEmiNF,3,2) + "/" + Substr(cEmiNF,5,4))		//vem neste formato : DDMMAAAA, irei transformar para DD/MM/AAAA
While nConta <= nDiasUteis	
	dAux := DataValida(dAux + 1)	
	If Dow(dAux) == 7	//se sábado, soma mais 1
		dAux := DataValida(dAux + 1)
	Endif
	nConta++
Enddo
dSexto := dAux	
cVencto:= DtoS(dSexto)		//muda para AAAAMMDD

Return(cVencto)

//FR - função que calcula o intervalo em dias corridos entre uma data inicial e uma data final
************************************
User Function CalcDias(dIni,dFim) 
************************************
Local nDias := 0
Local dAux  := dIni

While dAux < dFim
	dAux := dAux + 1
	nDias++
Enddo

Return(nDias)

//FR - função para verificar se há amarração do fornecedor na ZBC
***********************************************
User Function fTemZBC(cCodEmit,cLojaEmit,cProd,cTp)
***********************************************
Local cQuery  := ""
Local LF      := CHR(13) + CHR(10)
Local lTemZBC := .F.
Local aArea   := GetArea()
Local cTESZBC := ""  //GetNewPar("XM_TESZBC"  , "121")		//FR - 28/10/2021 - DAIKIN
Local cCCZBC  := ""  //GetNewPar("XM_CCZBC"   , "501010104") 	//FR - 28/10/2021 - DAIKIN
Local cAutoZBC:= ""  //GetNewPar("XM_ZBCAUTO" , "N") 		//FR - 28/10/2021

Private xZBC  	  := GetNewPar("XM_TABCAC","ZBC")  
Private xZBC_ 	  := iif(Substr(xZBC,1,1)=="S", Substr(xZBC,2,2), Substr(xZBC,1,3)) + "_"

DbSelectArea(xZBC)
Aadd(aArea, (xZBC)->(GetArea()) )

cQuery := " SELECT * " + LF		
cQuery += " FROM "       + RetSqlName(xZBC) + " ZBC "			+ LF
cQuery += " WHERE "								+ LF
cQuery += " ZBC.D_E_L_E_T_ <> '*' "				+ LF
//cQuery += " AND "+ xZBC_+"TIPO  = 'E' "				+ LF
cQuery += " AND "+ xZBC_+"TIPO  = '" + cTp + "' "				+ LF  //virá tipo "E" (Energia) ou "C" Combustível
cQuery += " AND "+ xZBC_+"FILIAL= '" + Alltrim(xFilial(xZBC)) +  "' " + LF
cQuery += " AND "+ xZBC_+"CODFOR ='" + Alltrim(cCodEmit) + "' " + LF
cQuery += " AND "+ xZBC_+"LOJFOR ='" + Alltrim(cLojaEmit) + "' " + LF
cQuery += " AND "+ xZBC_+"PROD   ='" + Alltrim(cProd) + "' " + LF				//FR - PROJETO POLITEC
cQuery += " ORDER BY " + xZBC_+"FILIAL, " + xZBC_+"CODFOR, " + xZBC_+"LOJFOR, " + xZBC_+"PROD "

MemoWrite("C:\TEMP\1fBuscaZBC.sql" , cQuery)

cQuery := ChangeQuery( cQuery )		//FR - 13/11/2020
If Select("TMPZBC") > 0
	dbSelectArea("TMPZBC")
	TMPZBC->(dbCloseArea())
EndIf

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPZBC", .T., .F. )
DbSelectArea("TMPZBC")
DbGoTop() 

If TMPZBC->(!Eof())

	//While TMPZBC->(!Eof())
	//	TMPZBC->( Dbskip() )
	//Enddo
	lTemZBC := .T.

	dbSelectArea("TMPZBC")
	TMPZBC->(dbCloseArea())

Else

	//cadastra automático se encontrar o fornecedor e os dados do produto
	cCnpjZBC := ""
	cNomeZBC := ""
	cTESZBC  := ""
	cCCZBC   := ""
	cDescP   := ""
	SA2->(OrdSetFocus(1))
	If SA2->(Dbseek(xFilial("SA2") + cCodEmit + cLojaEmit ))
		cCnpjZBC := SA2->A2_CGC	
		cNomeZBC := SA2->A2_NOME

		SB1->(OrdSetFocus(1))
		If SB1->(Dbseek(xFilial("SB1") + cProd ))
			cTESZBC := SB1->B1_TE
			cCCZBC  := SB1->B1_CC
			cDescP  := SB1->B1_DESC

			cAutoZBC:= GetNewPar("XM_ZBCAUTO" , "N") 		//FR - 28/10/2021
			If cAutoZBC == "S"				
				cTESZBC := GetNewPar("XM_ZBCTES"  , Space(3) )		//FR - 28/10/2021 - DAIKIN
				cCCZBC  := GetNewPar("XM_ZBCCC"   , Space(10) ) 	//FR - 28/10/2021 - DAIKIN				 
			Endif 
			DbSelectArea(xZBC)
			RecLock(xZBC, .T.)
			(xZBC)->(FieldPut(FieldPos(xZBC_+"FILIAL"),  xFilial(xZBC) ))	
			(xZBC)->(FieldPut(FieldPos(xZBC_+"CODFOR"),  cCodEmit      ))	
			(xZBC)->(FieldPut(FieldPos(xZBC_+"LOJFOR"),  cLojaEmit     ))	
			(xZBC)->(FieldPut(FieldPos(xZBC_+"CGC"   ),  cCnpjZBC      ))	
			(xZBC)->(FieldPut(FieldPos(xZBC_+"NOME"  ),  cNomeZBC      ))	
			(xZBC)->(FieldPut(FieldPos(xZBC_+"PROD"  ),  cProd         ))
			(xZBC)->(FieldPut(FieldPos(xZBC_+"DESCPR"),  cDescP        ))
			(xZBC)->(FieldPut(FieldPos(xZBC_+"TES"   ),  cTESZBC       ))			
			(xZBC)->(FieldPut(FieldPos(xZBC_+"CC"    ),  cCCZBC        ))
			//(xZBC)->(FieldPut(FieldPos(xZBC_+"TIPO"  ),  'E'           ))						
			(xZBC)->(FieldPut(FieldPos(xZBC_+"TIPO"  ),  cTp           ))						
			(xZBC)->(MsUnlock())

			lTemZBC := .T.

		Endif		//SB1
	Endif			//SA2
Endif				//Eof

Restarea( aArea )

Return(lTemZBC)

******************************************************************************************************************************
Static Function fGRAVACC(cZBZFIL, cZBZCHAVE, cZBZNOTA, cZBZSERIE, cZBZCODFOR, cZBZLOJFOR, cZBZTPDOC, cCC)
//fGRAVALOJA( (cTmp_ZBZ)->M0FIL,(cTmp_ZBZ)->CHAVE, (cTmp_ZBZ)->NOTA, (cTmp_ZBZ)->SERIE, (cTmp_ZBZ)->CODFOR, (cTmp_ZBZ)->LOJFOR, (cTmp_ZBZ)->TPDOC  )
******************************************************************************************************************************

DbSelectArea("SF1")	
SF1->(OrdSetFocus(8))  //DbSetOrder(8)  //F1_FILIAL+F1_CHVNFE 
If SF1->(DbSeek( AllTrim( cZBZFIL ) + Alltrim( cZBZCHAVE ) )) 	
	
	//CC SD1	
	DbSelectArea("SD1")
	SD1->(OrdSetFocus(1)) 			//D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM	
	If SD1->(DbSeek( cZBZFIL + cZBZNOTA + cZBZSERIE + cZBZCODFOR + cZBZLOJFOR ))		
		While SD1->(!Eof() ) .and. SD1->D1_FILIAL == cZBZFIL .and. SD1->D1_DOC == cZBZNOTA .and. SD1->D1_SERIE == cZBZSERIE
				
			If Alltrim(SD1->D1_TIPO) == Alltrim( cZBZTPDOC ) .and. SD1->D1_FORNECE == cZBZCODFOR .and. SD1->D1_LOJA == cZBZLOJFOR							
				RecLock( "SD1", .F. )					
				SD1->D1_CC  := cCC		
				SD1->( MsUnlock() )			
			Endif	
			SD1->(Dbskip())	
		Enddo
	Endif	

Endif

	
Return
//----------------------------------------------------------------------------------//
//Função : fMontaIN
//Autoria: Flávia Rocha
//Data   : 14/12/2020
//Objetivo: função que recebe uma cadeia de caracteres e monta a expressão "IN" para
//          ser inserida na cláusula WHERE <campo> IN ...com as aspas e vírgulas em
//          seus devidos lugares.
//----------------------------------------------------------------------------------//
********************************
Static Function fMontaIN(cTexto) 
********************************
	Local cAux := ""
	Local fr   := 0
	
	For fr := 1 to Len(cTexto)
		If fr = 1	 
			cAux += "'" + Substr(cTexto,fr,1)
		Endif
		
		If fr > 1
			If Substr(cTexto,fr,1) != ","	 
				cAux += Substr(cTexto,fr,1)
			Else
				cAux += "'" + ",'"  //encerra com aspa o argumento e coloca vírgula preparando para o próximo argumento
			Endif
		Endif
		
		If fr = Len(cTexto)
			cAux += "'"      //coloca aspa simples no último argumento
		Endif
	Next
	
	If Substr(cAux,Len(cAux),1) = ","
		cAux := Substr(cAux,1,Len(cAux)-1) //retira a vírgula do último argumento
	Endif
	
Return(cAux)
//----------------------------------------------------------------------------------//
//Função : fVerSB1D
//Autoria: Flávia Rocha
//Data   : 28/10/2021
//Objetivo: função que recebe uma descrição de produto e procura na SB1
//----------------------------------------------------------------------------------//
User Function fVerSB1D(cDescProd,cNcm) //U_fVerSB1D(cDescProd)
Local cQuery    := ""
Local cLocaliza := ""
Local cCodProd  := ""

If "GASOLINA" $ cDescProd	
	cLocaliza := "GASOLINA"
Elseif "ETANOL" $ cDescProd
	cLocaliza := "ETANOL"
Elseif "DIESEL" $ cDescProd
	cLocaliza := "DIESEL"
Endif 

cQuery += " SELECT B1_COD, B1_DESC, B1_POSIPI FROM " + RetSqlname("SB1") + " SB1 "
//cQuery += " WHERE (B1_DESC LIKE '%" + cLocaliza + "%' OR B1_POSIPI = '" + Alltrim(cNcm) + "' )"
cQuery += " WHERE B1_POSIPI = '" + Alltrim(cNcm) + "' "
cQuery += " AND SB1.D_E_L_E_T_ <> '*' "

MemoWrite("C:\TEMP\fVerSB1D.sql" , cQuery)

cQuery := ChangeQuery( cQuery )		

If Select("TMPXXX") > 0
	dbSelectArea("TMPXXX")
	TMPXXX->(dbCloseArea())
EndIf

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPXXX", .T., .F. )
DbSelectArea("TMPXXX")
DbGoTop() 
//pela NCM:
If TMPXXX->(!Eof())

	cCodProd := Alltrim(TMPXXX->B1_COD)

	dbSelectArea("TMPXXX")
	TMPXXX->(dbCloseArea())

//se não encontrar pela ncm, faz pela descrição do produto
Else 

	cQuery += " SELECT B1_COD, B1_DESC, B1_POSIPI FROM " + RetSqlname("SB1") + " SB1 "
	cQuery += " WHERE B1_DESC LIKE '%" + cLocaliza + "%' "
	cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
	
	MemoWrite("D:\QUERY\fVerSB1D.sql" , cQuery)
	
	If Select("TMPXXX") > 0
		dbSelectArea("TMPXXX")
		TMPXXX->(dbCloseArea())
	EndIf
	
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPXXX", .T., .F. )
	DbSelectArea("TMPXXX")
	DbGoTop() 
	
	If TMPXXX->(!Eof())

		cCodProd := Alltrim(TMPXXX->B1_COD)

		dbSelectArea("TMPXXX")
		TMPXXX->(dbCloseArea())
		
	Endif 


Endif 

Return(cCodProd)

//----------------------------------------------------------------------------------//
//Função : fVerSB1N
//Autoria: Flávia Rocha
//Data   : 07/12/2021
//Objetivo: função que recebe uma ncm de produto e procura na SB1
//----------------------------------------------------------------------------------//
User Function fVerSB1N(cNcm) 
Local cQuery    := ""
Local cCodProd  := ""

cQuery += " SELECT B1_COD, B1_DESC, B1_POSIPI FROM " + RetSqlname("SB1") + " SB1 "
cQuery += " WHERE RTRIM(B1_POSIPI) = '" + Alltrim(cNcm) + "' "
cQuery += " AND B1_MSBLQL <> '1' "		//EXCETO BLOQUEADOS
cQuery += " AND SB1.D_E_L_E_T_ <> '*' "

MemoWrite("C:\TEMP\fVerSB1NCM.sql" , cQuery)

cQuery := ChangeQuery( cQuery )		

If Select("TMPXXX") > 0
	dbSelectArea("TMPXXX")
	TMPXXX->(dbCloseArea())
EndIf

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPXXX", .T., .F. )
DbSelectArea("TMPXXX")
DbGoTop() 
//pela NCM:
If TMPXXX->(!Eof())

	cCodProd := Alltrim(TMPXXX->B1_COD)

	dbSelectArea("TMPXXX")
	TMPXXX->(dbCloseArea())

Endif 

Return(cCodProd)
//----------------------------------------------------------------------------------//
//Função : fVerSB1NC
//Autoria: Flávia Rocha
//Data   : 24/03/2022
//Objetivo: função que recebe uma ncm de produto e procura na SB1, um B1_COD = NCM
//A Kitchens cadastra o B1_COD com o mesmo código da NCM
//----------------------------------------------------------------------------------//
User Function fVerB1_NCM(cNcm) 
Local cQuery    := ""
Local cCodProd  := ""

cQuery += " SELECT B1_COD, B1_DESC, B1_POSIPI FROM " + RetSqlname("SB1") + " SB1 "
cQuery += " WHERE B1_COD = '" + Alltrim(cNcm) + "' "
//cQuery += " WHERE RTRIM(B1_POSIPI) = '" + Alltrim(cNcm) + "' "
cQuery += " AND B1_MSBLQL <> '1' "		//EXCETO BLOQUEADOS
cQuery += " AND SB1.D_E_L_E_T_ <> '*' "

MemoWrite("C:\TEMP\fVerSB1NCM.sql" , cQuery)

cQuery := ChangeQuery( cQuery )		

If Select("TMPXXX") > 0
	dbSelectArea("TMPXXX")
	TMPXXX->(dbCloseArea())
EndIf

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPXXX", .T., .F. )
DbSelectArea("TMPXXX")
DbGoTop() 
//pela NCM:
If TMPXXX->(!Eof())

	cCodProd := Alltrim(TMPXXX->B1_COD)

	dbSelectArea("TMPXXX")
	TMPXXX->(dbCloseArea())

Endif 

Return(cCodProd)

//----------------------------------------------------------------------------------//
//Função : fCADB1Auto
//Autoria: Flávia Rocha
//Data   : 24/03/2022
//Objetivo: função que verifica se já existe na SYD (cadastro de NCMs)
//          a NCM do produto informado no xml da Kitchens
//          informada, A Kitchens cadastra o B1_COD com o mesmo código da NCM
//----------------------------------------------------------------------------------//
User Function fCADB1Auto(cNcm)
Local cProd := ""
Local cDesc := ""
Local nIpi  := 0
Local cQuery:= ""
Local _cAlias2:= GetNextAlias()	
Local aRetorno:= {}

cQuery := " SELECT YD_TEC, YD_DESC_P , YD_PER_IPI "
cQuery += " FROM "+RetSqlName("SYD")+" SYD "
cQuery += " WHERE SYD.D_E_L_E_T_=' ' "
cQuery += " AND YD_TEC = '"+ Alltrim(cNcm) + "' "


MemoWrite("C:\TEMP\fQrySYD.TXT" , cQuery)

If !Empty(Select(_cAlias2))
	DbSelectArea(_cAlias2)
	(_cAlias2)->(dbCloseArea())
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),_cAlias2,.T.,.T.)
dbSelectArea(_cAlias2)
(_cAlias2)->(dbGoTop())

If (_cAlias2)->(!Eof())
	cProd := Alltrim( (_cAlias2)->YD_TEC )
	cDesc := Alltrim( (_cAlias2)->YD_DESC_P )
    nIpi  := (_cAlias2)->YD_PER_IPI
    
	DbSelectArea(_cAlias2)
	(_cAlias2)->(dbCloseArea())

EndIf

aADD(aRetorno , cProd  )
aADD(aRetorno , cDesc  )
aADD(aRetorno , nIpi  )


Return(aRetorno) 
//------------------------------------------------------------------------------------------------------//
//U_FVERXMLCOMB - Verifica na ZBZ quais XML são de combustível e adiciona para o array de classificação
//                ZBZ_COMBUS = 'E'
//Autoria: Flávia Rocha
//Data   : 05/08/2022
//------------------------------------------------------------------------------------------------------//
User Function fVerXMLComb(aCab,aIte,oProcess) 
//User Function fVerXMLEnerg(lTemPC,aCab,aIte,lSoCheck,oRegua)

Local cQuery 	  := ""
Local lRet		  := .F.
Local LF		  := CHR(13) + CHR(10)
Local aLin[20]
Local aDet[18]
Local oXml
Local cXml             
Local cError	  := ""
Local cWarning	  := ""
Local cRazao	  := ""
Local cModelo     := ""
Local cPref		  := "" 
Local cTAG 		  := ""
Local cTGP		  := ""
Local cVerOk      := ""
Local cAux		  := ""
Local cArqTXT     := ""
Local nFormXML    := 6
Local nFormNfe    := Val(GetNewPar("XM_FORMNFE","6"))
Local nFormCTe    := Val(GetNewPar("XM_FORMCTE","6"))
Local cTagAux     := ""
Local aZBO, nPFil, nPCod, nPDes, nPDto, nPHro, nPChv, nPRsf, nPTpo, nPRvo, nPArq, nPFpt, nPExa, nPStt, nPEmp, nPMai
Local aRet        := Array(3)
Local nReczbz     := 0
Local cVerNFE     := "2.00|2.01|3.10|4.00"
Local aVerPC 	  := {}
Local cCondPC	  := ""
Local cEmiNF	  := ""
Local lCor		  := .F.
Local lCondicao   := .F.
Local oDet 
Local lCombust    := .F. //usado para checar via CFOP do XML  se de fato é um xml de Combustível  
Local cCFOPCombs  := GetNewPar("XM_CFOCOMB","5929")	//deixar aqui mesmo porque é algo que não mudará
Local i			  := 0

Private xZBZ  	  := GetNewPar("XM_TABXML","ZBZ")
Private xZBZ_ 	  := iif(Substr(xZBZ,1,1)=="S", Substr(xZBZ,2,2), Substr(xZBZ,1,3)) + "_"
Private xZBO      := GetNewPar("XM_TABOCOR","ZBO"), xRetSEF := ""
Private xZBO_     := iif(Substr(xZBO,1,1)=="S", Substr(xZBO,2,2), Substr(xZBO,1,3)) + "_"
Private xZBC  	  := GetNewPar("XM_TABCAC","ZBC")  //Colocar no HFXML01
Private xZBC_ 	  := iif(Substr(xZBC,1,1)=="S", Substr(xZBC,2,2), Substr(xZBC,1,3)) + "_"
Private cCondZBC  := Padr(GetNewPar("XM_ZBCCOND" , Space(3) ) ,3)	//CONDIÇÃO PAGTO QUE IRÁ NA CLASSIFIC. AUTOMÁTICA DA NF COMBUSTÍVEL
Private cCondSA2  := ""
Private cCondPG   := ""

cMontaIN     := fMontaIn( Alltrim(cCFOPCombs) )

cQuery := " SELECT  " + LF
cQuery += ""+xZBZ_+"CFOP   AS ZBZCFOP,  "       + LF
cQuery += ""+xZBZ_+"CHAVE  AS ZBZCHAVE, "		+ LF
cQuery += ""+xZBZ_+"XML    AS ZBZXML, " 		+ LF
cQuery += ""+xZBZ_+"MODELO AS ZBZMODELO, " 		+ LF
cQuery += ""+xZBZ_+"COMBUS AS ZBZCOMBUS, "		+ LF
cQuery += ""+xZBZ_+"NOTA   AS ZBZNOTA, "		+ LF
cQuery += ""+xZBZ_+"SERIE  AS ZBZSERIE, "		+ LF
cQuery += " ZBZ.R_E_C_N_O_ RECZBZ,       "      + LF
	
cQuery += "  ZBZ.* " 							+ LF
cQuery += " FROM " + RetSqlName(xZBZ) + " ZBZ " + LF
	
cQuery += " WHERE "								+ LF
cQuery += " ZBZ.D_E_L_E_T_ <> '*'     " 		+ LF
cQuery += " AND ZBZ."+ xZBZ_+"FILIAL = '" + Alltrim(xFilial(xZBZ)) + "' " + LF 
cQuery += " AND ZBZ."+ xZBZ_+"CFOP IN (" + Alltrim(cMontaIn) + " ) " + LF	
	
cQuery += " AND " + xZBZ_+"PRENF  = 'B'					  " + LF 
cQuery += " AND " + xZBZ_+"MODELO IN ('55','65')          "	+ LF
cQuery += " AND " + xZBZ_+"PROTC  = '" + Space(15) + "'   " + LF
	
//cQuery += " AND " + xZBZ_+"NOTA  = '000089792'       " + LF		//FR TESTE RETIRAR DEPOIS!
//cQuery += " AND " + xZBZ_+"NOTA  = '000000470'       " + LF		//FR TESTE RETIRAR DEPOIS!
	
cQuery += " ORDER BY " + xZBZ_+"NOTA,  "+ xZBZ_+"SERIE "		+ LF
	
MemoWrite("C:\TEMP\2XMLCOMBUST.SQL" , cQuery)
	
If Select("TMPE1") > 0
	dbSelectArea("TMPE1")
	TMPE1->(dbCloseArea())
EndIf
	
cQuery := ChangeQuery( cQuery )		//FR - 13/11/2020
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPE1", .T., .F. )
DbSelectArea("TMPE1")
DbGoTop()
	
If TMPE1->(!Eof())
		
	aZBO := U_HF13ZBOA()
		
	U_HF13ZPOS( aZBO, @nPFil, @nPCod, @nPDes, @nPDto, @nPHro, @nPChv, @nPRsf, @nPTpo, @nPRvo, @nPArq, @nPFpt, @nPExa, @nPStt, @nPEmp, @nPMai )
		
	aRet[1] := ""
	aRet[2] := ""
	aRet[3] := ""
		
	While TMPE1->(!Eof())
			
		cChave := TMPE1->ZBZCHAVE  //Substr(cBuf,272,44)
		cModelo:= TMPE1->ZBZMODELO
		nReczbz:= TMPE1->RECZBZ
		cNota  := TMPE1->ZBZNOTA

		DbSelectArea( xZBZ )
		DbGoTo( nReczbz )
		cXml   := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML")))
			
		oXml := XmlParser( cXml, "_", @cError, @cWarning )
			
		If Empty(cError) .And. Empty(cWarning) .And. oXml <> Nil
				
			//----------------------------------------------------------------//
			//FR - 18/08/2020 - Kroma - XML Energia - Definido pelo NCM e CFOP
			// Início da Checagem
			//-------------------------------------------------------------------------//
			cError       := ""
			cWarning     := ""
			oDet         := NIL
			cTagAux      := ""			
			oObj 		 := NIL
			cMsg		 := ""				
			cCFOP        := ""
			lCombust     := .F.		 
			
			If cModelo $ "55,65"
				If Type( "oXml:_NFEPROC:_NFE:_INFNFE:_DET" ) == "U"
					oDet := oXml:_NFEPROC:_NFE:_INFNFE:_DET
					oDet := IIf(ValType(oDet)=="O",{oDet},oDet)
				Else
					oDet := {}
				Endif
					
				If Len(oDet) > 0
					For i := 1 To Len(oDet)							
						//CFOP do produto
						cTagAux := "oDet["+AllTrim(str(I))+"]:_PROD:_CFOP:TEXT"
						cCFOP := (&cTagAux)
						If cCFOP $ cCFOPCombs
							lCombust := .T.
							lRet     := lCombust
							Exit
						Endif
					Next
				Endif
			Endif				
		    
		    //lCombust := .T. 
			If lCombust //se o XML de fato é de Combustível: 
			
				//--------------------------------//
				//Atualiza ZBZ - campo ZBZ_COMBUS
				//--------------------------------//						
				DbSelectArea( xZBZ )
				DbGoTo( nReczbz )
				If Empty(  (xZBZ)->(FieldGet(FieldPos(xZBZ_+"COMBUS")))  )
					If RecLock( xZBZ, .F. )
						(xZBZ)->(FieldPut(FieldPos(xZBZ_+"COMBUS"), "C" ))
						(xZBZ)->( MsUnlock() )
						
						
						
					Endif
				Endif
				
				//pega a condição de pagamento do fornecedor caso na tela F12 não tenha definido, vai usar a do fornecedor para classificar a nota
				SA2->(OrdSetFocus(3))
				If SA2->(Dbseek( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))) + (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))) ))
					cCondSA2 := SA2->A2_COND
				Endif 											
								
				DbSelectArea("TMPE1")	
				
				If cModelo $ "55,65"
							
					If cModelo == "55"
						cPref    := "NF-e"
					Else
						cPref    := "NFC-e"
					EndIf
							
					cTAG     := "NFE"
					cTGP     := "NFE"
					nFormXML := nFormNfe
					cVerOk   := cVerNFE
							
				ElseIf cModelo == "57"
							
					cPref    	:= "CT-e"
					cTAG     	:= "CTE"
					cTGP        := "CTE"
					nFormXML 	:= nFormCte
					cVerOk   	:= cVerCTE
							
				ElseIf cModelo == "67"
						
					cPref    	:= "CT-eOS"
					cTAG     	:= "CTE"
					cTGP        := "CTEOS"
					nFormXML 	:= nFormCte
					cVerOk   	:= cVerCTE
							
				EndIf
						
				cVencto	:= ""
				cValnf	:= ""
				cCNPJ	:= ""
				cNF		:= ""
				cSerie	:= ""
				cEmiNF	:= ""
				cEmissao:= ""
				cTagAux := ""
				nConta  := 0
				
				//------------------------//
				//campos chave da pesquisa
				//------------------------/
				cTagAux   := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_EMIT:_CNPJ:TEXT"
				cCNPJ     := &(cTagAux)
							
				//  NFEPROC:_NFE:_INFNFE:_IDE
				cTagAux   := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_NNF:TEXT"
				cNF       := &(cTagAux)
							
				//  NFEPROC: _NFE:_INFNFE:_IDE
				cTagAux   := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_SERIE:TEXT"
				cSerie    := &(cTagAux)
							
				//  NFEPROC:_NFE:_INFNFE:_IDE
				cTagAux   := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_DHEMI:TEXT"
				cAux      := &(cTagAux)
				cEmissao  := Substr(cAux,9,2) + Substr(cAux,6,2) + Substr(cAux,1,4)		//2020-10-24 vem assim no xml -> fica assim: 24102020
				cEmiNF    := cEmissao       //ficará no formato DDMMAAAA ex: 30072020 diamesano
						
											
				//Checagem da tag do vencimento, se existe a tag				
				//  NFEPROC:_NFE:_INFNFE:_COBR:_DUP:_DVENC:TEXT					
				oObj := oXml:_NFEPROC:_NFE  //:_INFNFE  //coloco neste objeto pra poder validar os "nós" existentes	
				nConta := XmlChildCount(oObj:_INFNFE)	//conta os nós do xml a partir do _INFNFE
					
				If nConta >= 11
					oObj := XmlGetChild(oXML:_NFEPROC:_NFE:_INFNFE, 9)	//tentar pegar o 9o. elemento pra checar se existe a tag	
					cName:= oObj:REALNAME
					
					If UPPER(cName) == "COBR"
						//Se passou da 1a. verificação, ver se tem a tag _DUP						
						oObj := oXml:_NFEPROC:_NFE:_INFNFE
						nConta := XmlChildCount(oObj:_COBR)
						If nConta >= 2		//se for >= 2, é porque tem a tag _DUP
							cTagAux   := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_COBR:_DUP:_DVENC:TEXT"
							cAux      := &(cTagAux)
							cVencto   := Substr(cAux,1,4) + Substr(cAux,6,2) + Substr(cAux,9,2)  //vem 2020-07-30 AAAA-MM-DD, ficará 20200730 AAAAMMDD
								
							//  NFEPROC:_NFE:_INFNFE:_COBR:_DUP:_VDUP:TEXT
							cTagAux   := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_COBR:_DUP:_VDUP:TEXT"
							cValnf    := &(cTagAux)
						Else
							lTagVenc := .F.	//não tem a tag do vencimento, então será calculado pelo 6o. dia útil a partir da emissão da NF															
						Endif
					
					Else  //if UPPER(cName) = "PAG"
						lTagVenc := .F.
					Endif
												
				Else	
					lTagVenc := .F.						
				Endif
				
				
				If !lTagVenc	//não tem a tag do vencimento													
						
					//para obter o valor total do produto, pegarei da tag do detalhe:
					//  NFEPROC:  _NFE:   _INFNFE:     _DET:
					cTagAux := "oXml:_" + cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_DET"
					oDet := &(cTagAux)
					oDet := IIf(ValType(oDet)=="O",{oDet},oDet)
					//vlr total produto
					cTagAux    := "oDet["+AllTrim(str(I))+"]:_PROD:_VPROD:TEXT"
					cValnf    := UPPER(&cTagAux)
				Endif					
					
				If !Empty(cCondZBC)  //condição pagto cadastrada na tela F12, guia Gerais2, campo "Cond.Pagto Amarr.Automat"
					cCondPG := cCondZBC
				Else 
					cCondPG := cCondSA2
				Endif 
					
				lCondicao := !Empty(cCondPG)
					
				//If !Empty(cVencto) .and. !Empty(cValnf) //se não existir ao menos essas duas informações, não prossegue e vai para o próximo XML
				If !Empty(cValnf) //se não existir essa TAG do valor NF, impossível prosseguir, não prossegue e vai para o próximo XML
							
					If lCondicao
									
						//  NFEPROC:  _NFE:   _INFNFE:    _EMIT:
						cTagAux:= "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_EMIT:_XNOME:TEXT"
						cRazao := &(cTagAux)
						
						cTagAux   := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_EMIT:_ENDEREMIT:_XLGR:TEXT"
						cEndereco := &(cTagAux)
								
						cTagAux   := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_EMIT:_ENDEREMIT:_NRO:TEXT"
						cNumero   := &(cTagAux)
							
						cTagAux   := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_EMIT:_ENDEREMIT:_XBAIRRO:TEXT"
						cBairro   := &(cTagAux)
								
						cTagAux   := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_EMIT:_ENDEREMIT:_XMUN:TEXT"
						cMun     := &(cTagAux)
								
						cTagAux   := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_EMIT:_ENDEREMIT:_CEP:TEXT"
						cCEP      := &(cTagAux)
								
						cTagAux   := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_EMIT:_ENDEREMIT:_UF:TEXT"
						cUF       := &(cTagAux)
								
						cTagAux   := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_EMIT:_CNPJ:TEXT"
						cCNPJ     := &(cTagAux)
								
						cTagAux   := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_EMIT:_IE:TEXT"
						cIE       := &(cTagAux)
						//  NFEPROC:  _NFE:   _INFNFE:    _IDE
						cTagAux   := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_NNF:TEXT"
						cNF       := &(cTagAux)
							
						//  NFEPROC:  _NFE:   _INFNFE: _IDE
						cTagAux   := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_SERIE:TEXT"
						cSerie    := &(cTagAux)
						
						//  NFEPROC:  _NFE:   _INFNFE:     _IDE
						cTagAux   := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_DHEMI:TEXT"
						cAux      := &(cTagAux)
						cEmissao  := Substr(cAux,9,2) + Substr(cAux,6,2) + Substr(cAux,1,4)
							
						//  NFEPROC:  _NFE:    _INFNFE:    _DEST
						cTagAux   := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_DEST:_CNPJ:TEXT"
						cCNPJDEST := &(cTagAux)
						
						//  NFEPROC:  _NFE:    _INFNFE:     _COBR:_DUP:_VDUP:
						//cTagAux   := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_COBR:_DUP:_VDUP:TEXT"
						cVNF      := cValNF //&(cTagAux)
																	
						//FR - obtive esta estrutura da função MontaNota, para poder usufruir das mesmas funções de classificação usadas nas nfs combustíveis
						aLin[01] := cRazao 		//Substr(cBuf,004,073) //Razao
						aLin[02] := cEndereco 	//Substr(cBuf,074,103) //Enderco
						aLin[03] := cNumero 	//Substr(cBuf,104,005) //numero
						aLin[04] := cBairro 	//Substr(cBuf,109,035) //Bairro
						aLin[05] := cMun 		//Substr(cBuf,144,035) //Mun
						aLin[06] := cCEP 		//Substr(cBuf,179,010) //CEP
						aLin[07] := cUF 		//Substr(cBuf,189,002) //UF
						aLin[08] := cCNPJ 		//Substr(cBuf,191,014) //CNPJ_CPF
						aLin[09] := "BR" 		//Substr(cBuf,205,002) //BR
						aLin[10] := cIE 		//Substr(cBuf,207,020) //Inscricao_Estadu
						aLin[11] := cNF 		//Substr(cBuf,227,009) //Num_NF
						aLin[12] := cSerie 		//Substr(cBuf,236,003) //Serie
						aLin[13] := Space(3) 	//Substr(cBuf,239,003) //SubSerie
						aLin[14] := cEmissao 	//Substr(cBuf,242,008) //Dt_Lancamento
						aLin[15] := cEmissao 	//Substr(cBuf,250,008) //Dt_Emissao
						aLin[16] := cCNPJDEST 	//Substr(cBuf,258,014) //CNPJ_Destino
						aLin[17] := cChave 		//Substr(cBuf,272,044) //Chave
						aLin[18] := cVNF 		//Substr(cBuf,316,015) //Valor Total Nota  FAZER O VAL
						aLin[19] := cVNF 		//Substr(cBuf,331,015) //Valor Total Nota  FAZER O VAL
						aLin[20] := cCondPG		//Código da condição de pagto
								
						aadd( aCab, aClone(aLin) )
									
						//  NFEPROC:  _NFE:   _INFNFE:     _DET:
						cTagAux := "oXml:_" + cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_DET"
						oDet := &(cTagAux)
						oDet := IIf(ValType(oDet)=="O",{oDet},oDet)
									
						For I := 1 to Len(oDet)
										
							//item
							cTagAux    := "oDet["+AllTrim(str(I))+"]:_NITEM"
							cItem      := &(cTagAux)
									
							//código produto
							cTagAux    := "oDet["+AllTrim(str(I))+"]:_PROD:_CPROD:TEXT"
							cProduto := UPPER(&cTagAux)								
									
							//descrição
							cTagAux    := "oDet["+AllTrim(str(I))+"]:_PROD:_XPROD:TEXT"
							cDesc      := UPPER(&cTagAux)
									
							//qtde
							cTagAux    := "oDet["+AllTrim(str(I))+"]:_PROD:_QCOM:TEXT"
							cQt       := UPPER(&cTagAux)
							
							//um
							cTagAux    := "oDet["+AllTrim(str(I))+"]:_PROD:_UCOM:TEXT"
							cUm       := UPPER(&cTagAux)
									
							//vlr unit
							cTagAux    := "oDet["+AllTrim(str(I))+"]:_PROD:_VUNCOM:TEXT"
							cValuni    := UPPER(&cTagAux)
									
							//cfop
							cTagAux    := "oDet["+AllTrim(str(I))+"]:_PROD:_CFOP:TEXT"
							cCFOP      := UPPER(&cTagAux)			
																	
							nAliqipi := 0 //Val(cVipi) / Val(cBipi)
							nAliqicm := 0
							cBcicms  := ""
							cVicms   := ""
							cBipi    := ""
							cVipi    := ""
									
							aDet[01] := cChave
							aDet[02] := cItem 		//Substr(cBuf,001,007) //Id_Item
							aDet[03] := cProduto 	//Substr(cBuf,008,020) //Cod_Produto
							aDet[04] := cDesc 		//Substr(cBuf,028,040) //Descricao_Nota
							aDet[05] := cQt 		//Substr(cBuf,068,013) //Quantidade 13,4 FAZER O VAL
							aDet[06] := cUm 		//Substr(cBuf,081,003) //Unidade de medida
							aDet[07] := cValuni 	//Substr(cBuf,084,015) //Vlr_Unitario FAZER O VAL
							aDet[08] := cCFOP 		//Substr(cBuf,099,010) //CFOP
							aDet[09] := cBcicms 	//Substr(cBuf,109,015) //Base_Calculo_ICMS  FAZER O VAL
							aDet[10] := Alltrim(Str(nAliqicm)) //Substr(cBuf,124,008) //Aliquota_ICMS  FAZER O VAL
							aDet[11] := cVicms 		//Substr(cBuf,132,015) //Vlr_Imposto_ICMS  FAZER O VAL
							aDet[12] := cBipi 		//Substr(cBuf,147,015) //Base_Calculo_IPI  FAZER O VAL
							aDet[13] := Alltrim(Str(nAliqipi)) //Substr(cBuf,162,008) //Aliquota_IPI  FAZER O VAL
							aDet[14] := cVipi 		//Substr(cBuf,170,015) //Vlr_Imposto_IPI  FAZER O VAL
							aDet[15] := cDesc 		//Substr(cBuf,185,015) //Vlr_Desconto  FAZER O VAL
							aDet[16] := ""  //aVerPC[1]	//Número pedido compra  - POLITEC NÃO VAI UTILIZAR
							aDet[17] := ""  //aVerPC[10]	//Item pedido compra - POLITEC NÃO VAI UTILIZAR
							aDet[18] := cNF			//Numero da nf para depois buscar no array de itens
							aadd( aIte, aClone(aDet) )
						Next
									
					Else
																
						cMsg += "Condicao de Pagto Inexistente - Veja Guia Gerais2 ou no Cad.Fornecedor; "		//FR 03/11/2020
															
						aRet[1] := "N"
						aRet[2] := "NF: " + Strzero(Val(cNF),9) + " -> " + cMsg
						aRet[3] := "0"
								
						cChaveNF := cChave
						cHora    := Time()
						
						cArqTXT  := "COMBUSTIVEIS_NF_" + Strzero(Val(cNF),9) + "-" + cSerie + "_.TXT"   
						//TEM Q TER A PALAVRA COMBUSTIVEIS assim será selecionado na query que envia o email
							
						(xZBO)->(OrdSetFocus(4))							
						If (xZBO)->( dbSeek( xFilial(xZBO) + "1" + AllTrim(cChave) + cArqTxt ) )	//ZBO_FILIAL + ZBO_TPOCOR + ZBO_CHAVE + ZBO_ARQ //FR 16/11/2020
							If (xZBO)->( FieldGet( FieldPos( xZBO_+"ST" ) ) ) <> "2"
								lCor   := .T.
							EndIF
						Endif
								
						//povoa array aZbo:
						If nPFil > 0
							aZBO[nPFil][4] := xFilial( xZBO )		//ZBO_FILIAL
						Endif
								
						//nPCod  //Se o código for zero, vai somar 1
						If nPDes > 0
							aZBO[nPDes][4] := aRet[2] //"Erro no execauto de classificação NF "+aReg[01]+" Serie "+aReg[02]
						Endif
						
						//If .NOT. lCor		//FR - 16/11/2020 - para NF Energia não será utilizada esta condição
						If nPDto > 0
							aZBO[nPDto][4] := dDataBase  
						Endif
									
						If nPHro > 0
							aZBO[nPHro][4] := Time()
						Endif
								
						If nPChv > 0
							aZBO[nPChv][4] := cChave //aReg[4]
						Endif
									
						If nPTpo > 0
							aZBO[nPTpo][4] := "1"
						Endif
								
						If nPArq > 0
							aZBO[nPArq][4] := cArqTxt
						EndIf
										
						If nPStt > 0
							If aRet[1] = "S"  //Classificado direto e reto
								aZBO[nPStt][4] := "0"
							Else
								aZBO[nPStt][4] := iif( lCor, "2", "1" )
							Endif
						EndIf
								
						If aRet[1] = "S"  //Marcar como email enviado para não enviar novamente
							If nPMai > 0
								aZBO[nPMai][4] := "2"
							EndIf
						Else
							aZBO[nPMai][4] := " " //FR - 10/07/2020 - sem ação para log mas envia email aos envolvidos (só envia se o campo ZBO_MAIL estiver = '' ou '1'
						Endif
						//fim povoa aZbo
								
						If U_HF13ZBOG( .F., 4, xFilial(xZBO)+"1"+AllTrim(cChave)+cArqTxt, aZBO, cChaveNF )
							Conout("<GESTAOXML> GRAVOU ZBO -> COMBUSTIVEL C1 OCORRENNCIA COND. PAGTO")								
						Endif
								
					Endif		//If lCondicao
								
				Endif 	//se vazio vencto e valor nf	
			
			Endif		//se xml é de combustível
			 
		Endif			//error no parse do xml
			
		DbSelectArea("TMPE1")
		TMPE1->(Dbskip())
	Enddo	
		
	dbSelectArea("TMPE1")
	TMPE1->(dbCloseArea())
		
Endif  //if !eof 1o.


Return(lRet)
