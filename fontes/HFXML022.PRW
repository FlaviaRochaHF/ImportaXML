#include "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "RWMAKE.CH" 

Static lUnix  := IsSrvUnix()
Static cBarra := Iif(lUnix,"/","\")

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HFXML022  ºAutor  ³Eneovaldo Roveri Jr º Data ³    Hoje     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotinas Complementares HFXML02                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ HFXML02                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ HFXMLMNF ºAutor  ³Eneovaldo Roveri Jr º Data ³   Sabado    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gerar documento de entrada com Multiplos NFE               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ HFXML02                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
//Alterações: 
//08/02/2020 - Flávia Rocha - Tela para informar TES - Politec
//                            Mostrar tela apenas uma vez, para multiplos 
//                            CTE / NFE. 
//-------------------------------------------------------------------------//
//18/05/2020 - Flávia Rocha - Alterações realizadas para adequar na rotina 
//                            Pré Auditoria Fiscal verificação de divergências
//                            entre XML x NF 
//--------------------------------------------------------------------------// 
//FR - 09/06/2020 - Alterações realizadas para adequar nova opção para 
//                  "gerar nota fiscal direto"
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
//FR - 06/08/2020 - Tela Tes Automático 
//                  
//-------------------------------------------------------------------------//
//FR - 30/09/2020 - Uso da regua de processo
//-------------------------------------------------------------------------//
//FR - 17/03/2021 - Projeto MaxiRubber - Criação de novo filtro para a tela
//                  Multiplos Cte, trazer também xmls que já tem pré-nota
//                  gerada, já pronto para classificar também.
//                  O filtro antigo trazia apenas os xmls com status = 'B'
//                  O novo filtro irá trazer também os xmls com status = 'S'
//-------------------------------------------------------------------------//
//FR - 22/06/2021 - #10851 - TELETEX - Customização para campos:
//                  D1_CC, D1_ITEMCTA, F1_NATUREZ
//-------------------------------------------------------------------------//
//FR - 26/07/2021 - #11021 - DAIKIN - trazer o numero/item docto original         
//-------------------------------------------------------------------------//
//FR - 09/02/2022 - Alteração mediante chamado Trigoarte, 
//                  campo deles de Centro Custo possui 12 caracteres 
//                  corrigida nossa tela onde o campo centro custo acompanhava
//                  o padrão Protheus, aumentei para 30 caracteres o get de tela
//-------------------------------------------------------------------------//
//FR - 26/05/2022 - PETRA - MULTIPLOS NFE - Ajuste para trazer o centro de custo
//                  da pré-nota já lançada anteriormente, pois utilizam o multiplos
//                  nfe apenas para classificar a nf (isso serve para qq cliente)
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function HFXMLMNF()

Local aArea   := GetArea()
Local lRet    := .T.
Local lOk     := .T.

If Empty( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR"))) ) .Or. Empty( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR"))) )
	
	lOk:= .F.
	MsgStop("Este XML não possui fornecedor associado. Clique em Ações Relacionadas / Funções XML / Alterar e Associe o Fornecedor de Acordo com o CNPJ. Caso não Tenha Fornecedor Cadastrado com o CNPJ, faça-o no Cadastro de Fornecedor.")

EndIf

If lOk
	If (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO"))) <> "55"	
		U_MyAviso("Aviso","Este XML não é modelo 55 (NF-e). Clique em gera pré-nota.",{"OK"},2)		
   	ELseIf (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO"))) == "55"   	
		//U_MyAviso("Aviso","Em Desenvolvimento",{"OK"},2)		
		Processa( {|| XMLMULTNFE() }, "Aguarde...", "Gerando a Nota Com Multiplos NFe ...",.F.)		
	EndIf
EndIf

RestArea(aArea)

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³XMLMULTNFEºAutor  ³Eneovaldo Roveri Jr º Data ³  14/10/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gerar documento de entrada com Multiplos NFE               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ HFXML02                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function XMLMULTNFE()

Local aArea     := GetArea()
Local lRet      := .F.
Local cAliasZBZ := GetNextAlias()
Local cMarcaOK  := GetMark()
//Local nReg      := 0
Local lTMP      := .F.

Private oTempTable
Private cGetAlias := "TMPHF"
Private cArq      := ""
Private oFont01   := TFont():New("Arial",07,14,,.T.,,,,.T.,.F.)
Private cCodFor   := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR")))
Private cLojFor   := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR")))
Private cCnpjFor  := PADR((xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))),14)
Private cTabela   := ""
Private cWhere    := ""
Private cOrder    := ""
Private cCampos   := ""
Private lAglCTE	  := ( GetNewPar('XM_AGLMCTE') == 'S' ) //Parametro se aglutina multiplos CTE/NFE ou nao //FR - 17/03/2021 - MaxiRubber
//-------------------
//Criação do objeto
//-------------------
oTempTable := FWTemporaryTable():New( cGetAlias )

lTMP := CriaTMP()

If !lTMP
   U_MyAviso("Erro","Não foi possível criar o Arquivo Temporário."+CRLF+;
	"Verifique suas permissões e tente novamente.",{"OK"},1)	
	RestArea(aArea)	
	Return(.F.)	
Endif


cTabela := "%"+RetSqlName(xZBZ)+"%"

cWhere  := "%(   ZBZ."+xZBZ_+"FILIAL = '"+xFilial( xZBZ )+"' "
cWhere  += " AND ZBZ."+xZBZ_+"MODELO = '55' "
cWhere  += " AND ZBZ."+xZBZ_+"STATUS = '1' "
//cWhere  += " AND ZBZ."+xZBZ_+"PRENF  = 'B' "
//--------------------------------------------------------------------------------------------//
//FR - 17/03/2021 - Projeto MaxiRubber
//Adição de novo filtro para a tela Multiplos Nfe (além do status B, acrescentar o status S),
//adicionar os xmls que já tem pré-nota gerada e estão prontos para classificação
//Exceto se o parâmetro de aglutinar (XM_AGLMCTE) estiver ativado, conforme explicação abaixo:
//--------------------------------------------------------------------------------------------//
		
//--------------------------------------------------------------------------------------------//
//Seleciona com filtro B somente, quando o parâmetro de Aglutinar (XM_AGLMCTE) estiver ativo,
//porque não terá como gerar um docto único (aglutinado) se a query retornar 
//dois tipos de status, a pré nota aglutinada só pode ser gerada para status = B 
//--------------------------------------------------------------------------------------------//
If lAglCTE
	cWhere  += " AND ZBZ."+xZBZ_+"PRENF  = 'B' "   		//seleciona somente status = B (importado)													
Else
	cWhere  += " AND ZBZ."+xZBZ_+"PRENF IN ('B','S')"	//seleciona status B e S (importado e pré-nota a classificar)
Endif
//FR - 17/03
cWhere  += " AND ZBZ."+xZBZ_+"CODFOR = '"+cCodFor+"' "
cWhere  += " AND ZBZ."+xZBZ_+"LOJFOR = '"+cLojFor+"' )%"

cCampos	:= "%R_E_C_N_O_% "

BeginSql Alias cAliasZBZ
	
	SELECT	ZBZ.R_E_C_N_O_
			FROM %Exp:cTabela% ZBZ
			WHERE ZBZ.%notdel%
    		AND %Exp:cWhere%
EndSql


DbSelectArea(cAliasZBZ)
(cAliasZBZ)->( dbGoTop() )

While !(cAliasZBZ)->(Eof())

	DbSelectArea( xZBZ )
	(xZBZ)->( dbGoto( (cAliasZBZ)->R_E_C_N_O_ ) )
	
	/*
	if U_HFSTXMUN( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))),;
	               (xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA"))),;
	               (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE"))),;
	               (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR")))+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR"))) ,;
	               (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC"))),;
	               (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO"))),;
	               (xZBZ)->(FieldGet(FieldPos(xZBZ_+"DOCCTE"))),;
	               (xZBZ)->(Recno()) ) == "B"
	*/
	//FR - 17/03/2021 - atribuí à variáveis antes de passar à função pois o campo TPDOC apesar de ter conteúdo estava indo "em branco"
	xFil 	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL")))
	xNF  	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA")))
	xSer 	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE")))
	xForLoj	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR")))+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR")))
	xTpdoc	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC")))
	xModel	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO")))
	xDoccte	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"DOCCTE")))
	xRecno	:= (xZBZ)->(Recno())
	
	//FR - 17/03/2021 - Aqui procura se já existe pré-nota ou nota, para atualizar o status:
	cPrNf := U_HFSTXMUN( xFil, xNF, xSer, xForLoj, xTpdoc, xModel, xDoccte, xRecno )  
	
	If cPrNf $ "B/S"   		//Agora gera para status "B"-Importado e "S" - Pré-Nota a Classificar
	               
		lRet := .T.
		
		DbSelectArea( "TMPHF" )
		RecLock( "TMPHF", .T. )
		
		TMPHF->NOTA   := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA")))
		TMPHF->SERIE  := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE")))
		TMPHF->DTNFE  := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"DTNFE")))
		TMPHF->PRENF  := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF")))
		TMPHF->CNPJ   := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ")))
		TMPHF->FORNEC := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FORNEC")))
		TMPHF->CHAVE  := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE")))
		TMPHF->TPDOC  := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC")))
		TMPHF->CODFOR := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR")))
		TMPHF->LOJFOR := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR")))
		TMPHF->XMLCTE := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML")))
		TMPHF->REG    := (xZBZ)->( Recno() )
		
		//FR - 17/03/2021
		If cPrNf <> "B"
        	If cPrNf == "S" 		//Gerou Pré-Nota               
	        	TMPHF->ST := "2"   	//"2" = Verde, gerou só pré-nota
			Elseif cPrNf == "N" 	//NF Classificada            
	        	TMPHF->ST := "1"    //"1" - Vermelho, documento classificado
	  		Endif	        
	    Else   
        	TMPHF->ST := " "   		//"" - Importado         	
		Endif
		//FR - 17/03/2021
		
		TMPHF->( MsUnLock() )
		
	EndIF
	
	dbSelectArea(cAliasZBZ)
	(cAliasZBZ)->( dbSkip() )
	
End

If lRet
	MULTNFEBrw()	
Else
	U_MyAviso("Atenção","Nenhuma Chave NFE em Aberto para Gerar Documento de Entrada",{"Sair"},3)
EndIf

DbSelectArea(cAliasZBZ)

(cAliasZBZ)->( dbCloseArea() )

dbSelectArea( "TMPHF" )
TMPHF->( dbCloseArea() )

//---------------------------------
//Exclui a tabela
//---------------------------------
oTempTable:Delete() 
//fErase( cArq+GetDBExtension() )

RestArea(aArea)

Return(lRet)


//Criar temporário para markbrowse do CTE
*************************
Static Function CriaTMP()
*************************
Local aStru := {}
//Local cRet

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
aadd( aStru, { "TPCTE"   ,"C",len( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPCTE"))) ),0 } )
aadd( aStru, { "XMLCTE"  ,"M",10,0 } )
aadd( aStru, { "REG"     ,"N",15,0 } )

oTemptable:SetFields( aStru )

oTempTable:AddIndex( "01", { "NOTA","SERIE" } ) 
oTempTable:AddIndex( "02", { "CHAVE" } )

//------------------
//Criação da tabela
//------------------
oTempTable:Create()

Return( .T. )



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MULTCTEBrw³ Autor ³ Eneovaldo Roveri Jr   ³ Data ³14/02/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ MarkBrowse dos Multiplos CTE.                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MULTNFEBrw()

Local aButtons	:= {}
//Local aGetArea	:= GetArea()
//Local aInfo		:= {}
//Local aPosObj	:= {}
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
//Local cChvAnt	:= " "
//Local oFont		:= Nil
Local aCpos     := {}
Local aCores    := {}

Private cMarcaOK := GetMark()

aCpos := {}
aadd( aCpos, {"OK"   	,,""                 } )
aadd( aCpos, {"NOTA"    ,,"NOTA FISCAL","@!" } )
aadd( aCpos, {"SERIE"   ,,"SERIE","@!"       } )
aadd( aCpos, {"DTNFE"   ,,"DT EMISSAO","@D"  } )
aadd( aCpos, {"CHAVE"   ,,"CHAVE","@!"       } )
aadd( aCpos, {"CNPJ"    ,,"CNPJ","@!"        } )
aadd( aCpos, {"FORNEC"  ,,"EMITENTE","@!"    } )
aadd( aCpos, {"CODFOR"  ,,"FORNEC","@!"      } )
aadd( aCpos, {"LOJFOR"  ,,"LOJA","@!"        } )
aadd( aCpos, {"TPDOC"   ,,"TIPO","@!"        } )
//aadd( aCpos, {"CSITCONF",,"MANIFESTO","@!" } )
//aadd( aStru, { "PRENF"   ,"C",len( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF"))) ) ,0 } )

aCores := {}
aAdd(aCores,{"TMPHF->ST == '1'","BR_VERMELHO"	})
aAdd(aCores,{"TMPHF->ST == ' '","BR_AZUL"	    })
aAdd(aCores,{"TMPHF->ST == '0'","BR_AMARELO"    })
aAdd(aCores,{"TMPHF->ST == '2'","BR_VERDE"      })	//FR - 17/03/2021 - Projeto MaxiRubber - Criação de novo filtro para a tela Multiplos Nfe

dbSelectArea("TMPHF")
//COUNT TO nQtdReg
TMPHF->( dbGotop() )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apresenta botao se nao for visualizacao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aButtons,{'CHECKED' ,{ || MULTCTEInv(cMarcaOK,@oMarkBw)     }, "Inverter Marcação"      , "Inverter"  })
aAdd(aButtons,{'DESTINOS',{ || MULTCTEInv(cMarcaOK,@oMarkBw,.T.) }, "Marcar todos os títulos", "Marc Todos"})
aAdd(aButtons,{'DESTINOS',{ || HFXML22Leg() 					 }, "Legenda"				 , "LEGENDA"   })	//FR - 17/03/2021

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
DEFINE MSDIALOG oDlg01 TITLE "Gerar Documentos Multiplos NF-e(s)" FROM 000,000 TO 430,800 OF oMainWnd PIXEL

oDlg01:lMaximized := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria o objeto Mark para a selecao dos podrutos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oMarkBw := MsSelect():New("TMPHF","OK","",aCpos,@lInverte,@cMarcaOK,{17,10,150,400},,,,,aCores) //oFolder:aDialogs[1]

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

ACTIVATE MSDIALOG oDlg01 CENTERED  ON INIT EnchoiceBar(oDlg01,;
{|| processa({|| MULTCTEGER(@oMarkBw)}, "Gerar...","Gerando Documentos NFE ...") },;
{|| iif( msgYesNo("Sair Multiplo NFE ?","Pegunta"),oDlg01:End(),lOk := .F. )},,aButtons)

Return( .T. )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MULTCTEInv³ Autor ³ Eneo                  ³ Data ³23/11/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Esta rotina ira marcar ou desmarcar os ctes.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MULTCTEInv(cMarcaOK,oMarkBw,lMarkAll)

Local aGetArea	:= GetArea()
Local lMarcSim	:= .F.

If lMarkAll
	lMarcSim := Aviso( "Marcar/Desmarcar todos", "Deseja marcar ou desmarcar todos os títulos?", { "Marcar", "Desmarcar" } ) == 1
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ While para marcar ou desmarcar os produtos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TMPHF->( dbGotop() )
While TMPHF->( !EOF() )
	If lMarkAll	
		RecLock("TMPHF", .F.)		
		TMPHF->OK	:= if(TMPHF->ST == "1", "  ", If(lMarcSim, cMarcaOK, "  ") )		
		TMPHF->( MsUnLock() )
	Else	
		If  TMPHF->OK == cMarcaOK		
			RecLock("TMPHF", .F.)			
			TMPHF->OK	:= "  "			
			TMPHF->( MsUnLock() )			
		Else		
			RecLock("TMPHF", .F.)			
			TMPHF->OK	:= if(TMPHF->ST == "1", "  ", cMarcaOK )			
			TMPHF->( MsUnLock() )			
		EndIf		
	EndIf
	TMPHF->( dbSkip() )	
EndDo

oMarkBw:oBrowse:Refresh(.T.)
RestArea( aGetArea )

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MULTCTEChg³ Autor ³                       ³ Data ³25/09/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MULTCTEChg(oMarkBw)

Local cRetFun := " "
oMarkBw:oBrowse:Refresh(.T.)
Return cRetFun


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MULTCTEDis³ Autor ³ Eneovaldo Roveri Jr   ³ Data ³19/01/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MULTCTEDis(oMarkBw, cMarcaOK)

Local aGetArea := GetArea()

If TMPHF->ST == "1" .And. TMPHF->OK	== cMarcaOK
	RecLock("TMPHF", .F.)
	TMPHF->OK := "  "
	TMPHF->( MsUnLock() )	
Endif

oMarkBw:oBrowse:Refresh(.T.)
RestArea( aGetArea )

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MULTCTEGER³ Autor ³Eneovaldo Roveri Junior³ Data ³ 05/02/17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Geração do Documento de Entrada para CT-e.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MULTCTEGER()                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MULTCTEGER(oMarkBw)

Local nReg   := TMPHF->( recno() )
Local nRecno := TMPHF->( recno() )
Local lRet   := .T.
Local lTem   := .F.
Local nIte   := 0
Local nI     := 0
Local nPFci  := 0
Local nPIte  := 0
Local nPCod  := 0
//Local aLinha := {}
Local cError   := ""
Local cWarning := ""
Local cMsg     := ""
Local lXMLPEAMA   := ExistBlock( "XMLPEAMA" ), aPEAma, lAmaPe := .F. //nordsonAmarraCof
Local lXMLPEVAL   := .F. //ExistBlock( "XMLPEVAL" )
Local lXMLPEREG   := .F. //ExistBlock( "XMLPEREG" )
Local lXMLPEATU   := .F. //ExistBlock( "XMLPEATU" )
Local lXMLPE2UM   := ExistBlock( "XMLPE2UM" )
Local lXMLPEITE   := ExistBlock( "XMLPEITE" )

Local cCfgPre     := GetNewPar("XM_CFGPRE","0")		//FR 09/06/2020 - "tarefa: gera nota fiscal direto"
Local lNFDireto   := (cCfgPre $ "3")				//FR 09/06/2020 - "tarefa: gera nota fiscal direto" - Se = 3, já gera documento de entrada direto, sem passsar por pré nota

/*
//FR - 09/06/2020 - Lembrete das opções do combo (tela F12)
aAdd( aCombo7, "0=Pré-Nota Somente")
aAdd( aCombo7, "1=Gera Pré-Nota e Classifica")
aAdd( aCombo7, "2=Sempre Perguntar") 
aAdd( aCombo7, "3=Gera Docto.Entrada Direto")  
*/

//-------------------------------------------//
//FR - Projeto Politec Saúde:
//-------------------------------------------//
Local nOpcAlt     := 0	
Local lClassifica := cCfgPre $ "1/3"  //classifica direto ou pergunta antes de classificar   //FR - 06/08/2020
Local lPergAlt    := cCfgPre $ "2" 	  //indica se pergunta ou não
Local cTesPcNf    := GetNewPar("MV_TESPCNF","") 	// Tes que nao necessita de pedido de compra amarrado

Local cClAtRBT    := GetNewPar("XM_CLATRBT","1")  	//FR - 27/11/19 - Tipo da robotização quando utilizada Classificação Automática:
//==================================================================================================================//
// Opções do parâmetro XM_CLATRBT
//"Indica a regra a ser utilizada para Classificar as notas de forma automática: "
//"1=Pergunta Múltiplos: Sistema irá perguntar se deseja incluir pre-Nota ou Nota fiscal de Entrada;"
//"2=Múltiplos NFE e CTE: Sistema irá abrir a tela p/ usuário informar a TES sem perguntar;"
//"3=CTE: Sistema irá selecionar qual TES está informado no parâmetro XM_CTE_TES ou XM_NFE_TES para classificar automático sem perguntar;"
//"Se o parâmetro XM_CTE_TES ou XM_NFE_TES estiver vazio, não será possível selecionar opção 3;"
//"4=Utiliza TES do Cad.Produto;"
//"5=Não Utilizado."
//==================================================================================================================//
Local cTESAut     := GetNewPar("XM_NFE_TES","")		//FR - 27/11/19 - Tes para classificação automática
Local lClassAut   := cClAtRBT $ "1/2/3/4"           //FR - 03/12/19 - até a opção 4, utiliza algum tipo de classificação, a opção 5 não utiliza nenhuma e só gera pré-nota
Local aNotas      := {} 
Local lPreNF	  := .T.
Local nTotReg     := 0
Local cOri        := ""
Local cManif      := ""
Local cManPre     := GetNewPar("XM_MANPRE","N")  //Verifica qual tipo de manifestação
Local lGerouPNF   := .F.   //FR - 17/03/2021 - variável que indica que ao menos uma pré-nota foi gerada, p/ qdo houver a pergunta "Deseja Classificar pré-nota gerada" não seja feita em vão
//projeto Politec Saúde   

Local lMostraMsg  := .T.  //FR - 26/05/2022 - PETRA - MULTIPLOS NFE
Local aBKaItens   := {}

Private cTagFci   := ""
Private cCodFci   := ""
Private lNossoCod := .F.
Private cCnpjEmi  := ""
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
Private lAglCTE	  := .F. //( GetNewPar('XM_AGLMCTE') == 'S' ) //Parametro se aglutina multiplos CTE ou nao
//Estes aqui de cima é para o legado, para o caso de uso em ponto de entrada

Private oXml
Private oDet, oOri
Private cProduto    := ""
Private lMsErroAuto	:= .F.
Private lMsHelpAuto	:= .T.
Private aCabec      := {}
Private _aItens      := {}
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
Private aReg        := {}

//Private lTemFreXml  := .F., lTemDesXml := .F., lTemSegXml := .F.

aCabec := {}
aadd(aCabec,{"F1_TIPO"   ,"N"})
aadd(aCabec,{"F1_FORMUL" ,"N"})

DbSelectArea( "TMPHF" )

Count To nTotReg

ProcRegua( nTotReg )

cMsg := "Gerando Multiplos NFE(s):" + CRLF

If .NOT. VERAMARRA()
	lRet := .F.
	Return( .F. )	
EndIf

aCabec	:=	{}
_aItens	:=	{}
nIte	:=	0 
cPrenf  := ""
//ProcRegua(TMPHF->( RecCount() ))
//cMsg := "Gerando Multiplos NFE(s):"+CRLF

TMPHF->( DbGotop() )

While .not. TMPHF->( Eof() )
	IncProc("Processando " + TMPHF->CHAVE)	
	if .not. empty( TMPHF->OK ) // == cMarcaOK	
		nIte++
		lTem := .T.
		
		DbSelectArea( xZBZ )
		(xZBZ)->( dbGoTo( TMPHF->REG ) )
		cError := ""
		cWarning := ""
		
		cXml := NoAcento((xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML"))))
		cXml := EncodeUTF8(cXml) 
		
		cPrenf:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF")))		//FR - 17/03/2021 - MaxiRubber
		//Faz backup do xml sem retirar os caracteres especiais
		cBkpXml := cXml

		//Executa rotina para retirar os caracteres especiais
		cXml := u_zCarEspec( cXml )

		oXml := XmlParser(cXml, "_", @cError, @cWarning )

		//retorna o backup do xml
		cXml := cBkpXml

		DbSelectArea( "TMPHF" )
		
		If oXml == NIL .Or. !Empty(cError) .Or. !Empty(cWarning)		
			If !lAglCTE			
				cMsg += "XML Invalido ou Não Encontrado. Documento Não Gerado "+TMPHF->CHAVE+CRLF				
				aCabec	:=	{}
				_aItens	:=	{}
				nIte	:=	0 
				
				DbSelectArea( "TMPHF" )
              	RecLock( "TMPHF", .F. )              	
               		TMPHF->OK := "  "
               		TMPHF->ST := "0"               		
            	TMPHF->( MsUnLock() )            	
				TMPHF->( dbskip() )				
				Loop				
			Else			
				MsgSTOP("XML Invalido ou Não Encontrado, a Operação será Cancelada. Chave: "+TMPHF->CHAVE)
				lRet := .F.				
				Exit				
			Endif			
		EndIf

		DbSelectArea( xZBZ )
		
		If nIte == 1				
			addCabec()					
		EndIF
        
        If !addItens( @nIte, lClassifica,TMPHF->NOTA,TMPHF->SERIE,TMPHF->CODFOR,TMPHF->LOJFOR)     //FR - 26/05/2022 - PETRA - MULTIPLOS NFE
			If !lAglCTE			
				cMsg += "XML Invalido ou Não Encontrado. Documento Não Gerado "+TMPHF->CHAVE+CRLF				
				aCabec	:=	{}
				_aItens	:=	{}
				nIte	:=	0 
				
				DbSelectArea( "TMPHF" )
              	RecLock( "TMPHF", .F. )              	
               		TMPHF->OK := "  "
               		TMPHF->ST := "0"               		
            	TMPHF->( MsUnLock() )            	
				TMPHF->( dbskip() )			
				Loop				
			Else			
				MsgSTOP("XML Invalido ou Não Encontrado, a Operação será Cancelada. Chave: "+TMPHF->CHAVE)
				lRet := .F.				
				Exit				
			Endif        
        Endif

		//Inclusao do ExecAuto, quando nao for para aglutinar se a variavel for .F.
		If !lAglCTE

			lMsErroAuto	:= .F.
			nRecno := TMPHF->( recno() )

			aBKaItens := _aItens
			
			//FR - 17/03/2021 - MaxiRubber
			If cPrenf == "B"		//Somente irá gerar pré-nota do xml status = 'B' -> Importado, se for status = 'S' (pré-nota a classificar)
									//Irá apenas adicionar no array aNotas para posterior classificação
				
				//=====================================================//
				//FR - 06/06/2020 - geração da pré-nota ou nota direto
				//=====================================================//
				If !lNFDireto //FR - 09/06/2020 - "tarefa: gera nota fiscal direto" - se não estiver parametrizado para gerar nota direto, gera pré-nota
					xRet140	:=	MSExecAuto({|x,y,z| mata140(x,y,z)},aCabec,_aItens,3,.T.)  //execauto de geração da pré-nota
				Endif
			Endif

			_aItens := aBKaItens

			//----------------------------------------------------------//
			//FR - 28/11/19 - array a ser usado pela função fClassAut 
			//(classificação automática)
			//----------------------------------------------------------//
			Aadd(aNotas, {TMPHF->NOTA, aCabec, _aItens, TMPHF->REG, TMPHF->CHAVE, TMPHF->SERIE, TMPHF->CODFOR, TMPHF->LOJFOR, .F. } )	//FR - 28/11/19 
			
			If !lMsErroAuto
				lGerouPNF := .T.	//FR - 17/03/2021
				If !lNFDireto    				//FR - 09/06/2020 - "tarefa: gera nota fiscal direto" - se não estiver parametrizado para gerar nota direto, gera pré-nota
					nTotLen := Len( _aItens )
					For nI := 1 To nTotLen				
						nPFci := aScan( _aItens[nI], {|x| x[1] = "D1_FCICOD" } )
						nPIte := aScan( _aItens[nI], {|x| x[1] = "D1_ITEM" } )
						nPCod := aScan( _aItens[nI], {|x| x[1] = "D1_COD" } )
						
						if nPFci > 0 .And. nPIte > 0 .And. nPCod > 0					
							if ! Empty( _aItens[nI][nPFci][2] )						
								DbSelectArea( "SD1" )
								DbSetOrder(1)
								if SD1->( dbSeek( xFilial("SD1") + aCabec[3][2] + aCabec[4][2] + aCabec[6][2] + aCabec[7][2] + _aItens[nI][nPCod][2] + _aItens[nI][nPIte][2] ) )								
									RecLock("SD1",.F.)								
									SD1->D1_FCICOD := _aItens[nI][nPFci][2]								
									MsUnLock()								
								Endif							
							endif						
						endif					
					Next nI
				
					If !lNFDireto	//FR - 09/06/2020 - "tarefa: gera nota fiscal direto" - se não estiver parametrizado para gerar nota direto, gera pré-nota	
			           	cMsg += "Pré-Nota (Já) Gerada com Sucesso: " + aCabec[3][2]+CRLF                
			        Endif			
					//============================//
					// Atualiza informações na ZBZ
					//============================//
	                DbSelectArea( xZBZ )
	                (xZBZ)->( dbGoTo( TMPHF->REG ) )                
	                Reclock(xZBZ,.F.)                
	                	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PRENF") , 'S' ))
	                	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPDOC") , SF1->F1_TIPO ))
	                	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CODFOR"), aCabec[6][2] ))
	                	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"LOJFOR"), aCabec[7][2] ))
	                    (xZBZ)->(FieldPut(FieldPos(xZBZ_+"DOCCTE"), aCabec[3][2] ))                    
	                (xZBZ)->( MsUnlock() ) 

					//FR - 17/03/2021
					/*
					Opções do XM_MANPRE:
					N = Não Manifestar
					1 = Confirma operação (Pré-NF)
					2 = Ciência operação (Pré-NF)
					3 = Confirmação operação (Classificação)
					*/
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
                
				Endif  			//FR - 09/06/2020 - "tarefa: gera nota fiscal direto" - se não estiver parametrizado para gerar nota direto, gera pré-nota
				
					
				
	            DbSelectArea( "TMPHF" )
				TMPHF->( DbGoto( nRecno ) )				
	            //If !lNFDireto	//FR - 09/06/2020 - "tarefa: gera nota fiscal direto" - se não estiver parametrizado para gerar nota direto, gera pré-nota	
	            //	cMsg += "Pré-Nota Gerada com Sucesso: " + aCabec[3][2]+CRLF                
	            //Endif			//FR - 09/06/2020 - "tarefa: gera nota fiscal direto" - se não estiver parametrizado para gerar nota direto, gera pré-nota
	            RecLock( "TMPHF", .F. )                
	            	TMPHF->OK := "  "
	            	//TMPHF->ST := "1"                	
	            	TMPHF->ST := "2"   		//FR - 17/03/2021             	
	            TMPHF->( MsUnLock() )  
	    		
            Else            
            	MostraErro()
            	
				
             	DbSelectArea( "TMPHF" )
				TMPHF->( DbGoto( nRecno ) )
				
				cMsg += "Pré-Nota Não Foi Gerada Chave "+TMPHF->CHAVE+CRLF				
              	RecLock( "TMPHF", .F. )              	
               		TMPHF->OK := "  "
               		TMPHF->ST := "0"               		
            	TMPHF->( MsUnLock() )            	
   			EndIF

			aCabec	:=	{}
			_aItens	:=	{}
			nIte	:=	0 			
        EndIf
	endif	
	TMPHF->( dbskip() )	
End

if .Not. lTem
	U_MyAviso("Msg","Nenhum NF-e selecionado para gerar documento !!!!",{"OK"},3)
	TMPHF->( DbGoto( nReg ) )	
	return( lRet )	
endif

If lRet

	//Neste ponto se o parametro for SIM ele executa a condiçao abaixo - 31/05/2017
	
	If lAglCTE

		If !lNFDireto	//FR - 09/06/2020 - "tarefa: gera nota fiscal direto" - se não estiver parametrizado para gerar nota direto, gera pré-nota
			xRet140 := MSExecAuto({|x,y,z| mata140(x,y,z)},aCabec,_aItens,3,.T.)
			lMata140 := .T.
		Else
			lGerouPNF := .T.  	//FR - 17/03/2021
		Endif
		
		If lMsErroAuto 

			If xRet140			
				MOSTRAERRO()
				MsgSTOP("O documento de entrada não foi gerado.")				
			EndIf		

			lRet := .F.			
			DbSelectArea( "TMPHF" )
			
			Count To nTotReg
			
			ProcRegua( nTotReg )
			TMPHF->( DbGotop() )
			
			While .not. TMPHF->( Eof() )		

				IncProc("Atualizando " + TMPHF->CHAVE)				
				if .not. empty( TMPHF->OK ) // == cMarcaOK				
					RecLock( "TMPHF", .F. )
					TMPHF->OK := "  "
					TMPHF->ST := "0"					
					TMPHF->( MsUnLock() )					
				EndIF	

				TMPHF->( dbskip() )	

			EndDo
				
		Else		

			lMsHelpAuto:=.F.

			If !lNFDireto  			//FR - 09/06/2020 - "tarefa: gera nota fiscal direto" - se não estiver parametrizado para gerar nota direto, gera pré-nota								
				cMsg := "Foi Gerado Um Único Documento de Entrada NFE Número "+aCabec[3][2]+" para as chaves:"+CRLF	
			Endif
			
			lGerouPNF := .T.	//FR - 17/03/2021 - Se chegou aqui é porque gerou a pré-nota, ao menos uma é suficiente para alimentar esta variável
					
			DbSelectArea( "TMPHF" )			
			Count To nTotReg			
			ProcRegua( nTotReg )			
			TMPHF->( DbGotop() )			
			While .NOT. TMPHF->( Eof() )
			
			
				IncProc("Atualizando " + TMPHF->CHAVE)	

				If .not. empty( TMPHF->OK ) // == cMarcaOK	

					If !lNFDireto  			//FR - 09/06/2020 - "tarefa: gera nota fiscal direto" - se não estiver parametrizado para gerar nota direto, gera pré-nota									
						
						DbSelectArea( xZBZ )					
						(xZBZ)->( dbGoTo( TMPHF->REG ) )

						Reclock(xZBZ,.F.)					
							(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PRENF") , 'S' ))
							(xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPDOC") , SF1->F1_TIPO ))
							(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CODFOR"), aCabec[6][2] ))
							(xZBZ)->(FieldPut(FieldPos(xZBZ_+"LOJFOR"), aCabec[7][2] ))
							(xZBZ)->(FieldPut(FieldPos(xZBZ_+"DOCCTE"), aCabec[3][2] ))						
						(xZBZ)->( MsUnlock() ) 
						
						//FR - 17/03/2021
						/*
						Opções do XM_MANPRE:
						N = Não Manifestar
						1 = Confirma operação (Pré-NF)
						2 = Ciência operação (Pré-NF)
						3 = Confirmação operação (Classificação)
						*/						
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

						cMsg += TMPHF->CHAVE+CRLF 

					Endif  			//FR - 09/06/2020 - "tarefa: gera nota fiscal direto" - se não estiver parametrizado para gerar nota direto, gera pré-nota								
				
					DbSelectArea( "TMPHF" )					
					RecLock( "TMPHF", .F. )					
					TMPHF->OK := "  "
					//TMPHF->ST := "1"					
					TMPHF->ST := "2"            	//FR - 17/03/2021 - "2" = Verde, gerou só pré-nota					
					TMPHF->( MsUnLock() )		

				EndIF	

				TMPHF->( dbskip() )			

			End	

			If !lNFDireto	 	//FR - 09/06/2020 - "tarefa: gera nota fiscal direto" - se não estiver parametrizado para gerar nota direto, gera pré-nota			
				U_MyAviso("Aviso",cMsg,{"OK"},3)
			Endif				
									
		EndIf		

	Else

		If !lNFDireto //.or. lMostraMsg //FR - 09/06/2020 - "tarefa: gera nota fiscal direto" - se não estiver parametrizado para gerar nota direto, gera pré-nota	
			U_MyAviso("Aviso",cMsg,{"OK"},3)		
		Endif	

	EndIf	
	
EndIF

TMPHF->( DbGoto( nReg ) )

//FR - 17/03/2021 - basta uma pré-nota gerada para alimentar esta variável (lGerouPNF) e fazer válida a pergunta abaixo:
If lGerouPNF 		
	If cClAtRBT = '1' .or. cClAtRBT = '2' 	//FR - 1=Pergunta se deseja classificar; 2=Classifica direto 
		If !lNFDireto 						//FR - 09/06/2020 - "tarefa: gera nota fiscal direto" - se não estiver parametrizado para gerar nota direto, gera pré-nota e pergunta se deseja classificar.
			If lPergAlt		
				nOpcAlt := Aviso("Atenção","Deseja Classificar a(s) Pré-Nota(s) Gerada(s)?",	{"Sim","Não"},	1) 	
			Else	
				nOpcAlt := 1		
			Endif
		
			If nOpcAlt = 1	
				lClassifica := .T.		
			Else	
				lClassifica := .F.		
			Endif
		Else										//FR - 09/06/2020 - "tarefa: gera nota fiscal direto"
			lClassifica := .T.
		Endif
				
	Elseif cClatRBT = '3' .or. cClatRBT = '4' 		//FR -> 3-não pergunta, classifica automaticamente de acordo com TES do parâmetro XM_NFE_TES
	   												//FR -> 4-não pergunta, classifica a nf de acordo com o TES do cadastro de produto (B1_TE) 
		If cClatRBT = '3'	
			If Empty(cTESAut)		
				lClassifica := .F.
				MsgAlert("A(s) Pré-Nota(s) Não Poderão Ser Classificada(s) Devido Ausência de Cadastro de TES Automático")		
			Else		
				lClassifica := .T.									
			Endif		
		Else	
			lClassifica := .T.		
		Endif			
	Elseif cClatRBT = '5'							//FR -> 5-desabilita a classificação automática	
		lClassifica := .F.	
	Endif
	
	If lClassifica
		cDesc := "Classificação de NFE(s):"+CRLF 
		U_fClassAut( aNotas, cClAtRBT, cTESAut, cDesc, 'NFE' )     //User Function fClassAut( aNotas, cClAtRBT, cTESAut, cDesc, cTipo ) 
		
		//--------------------------------------------------//
		//FR - 17/03/2021 - Atualiza status do Markbrowse:
		//--------------------------------------------------//
		DbSelectArea( "TMPHF" )
		nTotReg := 0
			
		Count To nTotReg			
		ProcRegua( nTotReg )			
		TMPHF->( DbGotop() )  
		
		nRecTMPHF := 0	
		
		While .NOT. TMPHF->( Eof() ) 
		
			nRecTMPHF := TMPHF->( recno() ) 
			
			IncProc("Atualizando Status... " + TMPHF->CHAVE)
		    
		    //Localiza e captura informações direto na ZBZ:
		    DbSelectArea( xZBZ )
			(xZBZ)->( dbGoTo( TMPHF->REG ) )    
			
			xFil 	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL")))
			xNF  	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA")))
			xSer 	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE")))
			xForLoj	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR")))+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR")))
			xTpdoc	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC")))
			xModel	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO")))
			xDoccte	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"DOCCTE")))
			xRecno	:= (xZBZ)->(Recno())
   			
	   		//FR - 17/03/2021 - Aqui procura se já existe pré-nota ou nota, para atualizar o status:
			cPrNf := U_HFSTXMUN( xFil, xNF, xSer, xForLoj, xTpdoc, xModel, xDoccte, xRecno )  
			
			DbSelectArea( "TMPHF" )
			TMPHF->( DbGoto( nRecTMPHF ) )			
			RecLock( "TMPHF", .F. )       		
       		
	        If cPrNf <> "B"	            
		    	If cPrNf == "S" 					//Gerou Pré-Nota               		           
		           	TMPHF->ST := "2"            	//FR - 17/03/2021 - "2" = Verde, gerou só pré-nota		            
		        Elseif cPrNf == "N" 				//NF Classificada            
		          	TMPHF->ST := "1"
		          	TMPHF->OK := "  "				//Se classificou a pré-NF, desmarca o [x]
		        Endif		                        
			Else   //if cPrNf == "B"     			//Importado - se continuar o mesmo status é porque não gerou a pré-nota        
	           	TMPHF->ST := "0"           	
	        Endif            
            TMPHF->( MsUnLock() )
			TMPHF->( dbskip() )				
		Enddo
		//FR - 17/03/2021 - atualização status
		
	Endif
	
Endif //lGerouPNF
//FR - 17/03/2021

//Refresh no grid
oMarkBw:oBrowse:Refresh(.T.)

Return( lRet )

*************************************************************************************
Static Function addItens( nIte, lClassifica, xNota, xSerie, xFornece, xLoja )
*************************************************************************************
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
Local lXMLPE2UM   := ExistBlock( "XMLPE2UM" )
Local lXMLPEITE   := ExistBlock( "XMLPEITE" )
Local lXMLPELOK   := ExistBlock( "XMLPELOK" )   //FR - 11/10/2019
Local lXMLPETOK   := ExistBlock( "XMLPETOK" )   //FR - 11/10/2019
Local nTamIte     := TAMSX3("C7_ITEM")[1]
Local nvIcms      := 0
Local nvIpi       := 0
Local fr		  := 0
Local i
Local cAuxTag     := ""

Private oDet

	oDet := oXml:_NFEPROC:_NFE:_INFNFE:_DET
	oDet := IIf(ValType(oDet)=="O",{oDet},oDet)

	If Type("oXml:_NFEPROC:_NFE:_INFNFE:_DET") == "A"	
		aItem := oXml:_NFEPROC:_NFE:_INFNFE:_DET		
	Else	
		aItem := {oXml:_NFEPROC:_NFE:_INFNFE:_DET}		
	EndIf

	nD1Item := 1
	
	nTotLen := Len(oDet)
	For i := 1 To nTotLen
	
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
		        End

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
		        End

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
		//################################################################## //fim valida amarração produto
		
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
			cCodFci:= oDet[i]:_PROD:_NFCI:TEXT   //&cTagFci.		
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
	 	
	 	//pedido de compra	
	 	cXped     := Space(6) //FR - 28/11/19
		cXItemPed := ""			
	  	cTagAux    := "oDet["+AllTrim(str(i))+"]:_PROD:_XPED:TEXT"	  	
		If type( cTagAux ) <> "U"		
			cXped := UPPER(&cTagAux)			
		Endif
		
		//Item do pedido de compra
		cTagAux    := "oDet["+AllTrim(str(i))+"]:_PROD:_NITEMPED:TEXT"
		
		If type( cTagAux ) <> "U"		
			cXItemPed  := StrZero( Val( &cTagAux ), nTamIte )			
		Endif
			
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
		
		cUM := ""
		c2UM:= ""
		cLocPad := ""		
        If SB1->( DbSeek(xFilial("SB1") + cProduto) )         
        	cUM     := SB1->B1_UM
        	c2UM    := SB1->B1_SEGUM 
        	cLocPad := iif(!Empty(SB1->B1_LOCPAD),SB1->B1_LOCPAD,"01")        	
        Endif 
        
        //==============================//
        //FR - 28/11/19 - Politec Saúde
        // Reunindo conteúdos/variáveis:
        //==============================//
	 	If lClassifica	 		 			 		
	 		//ICMS
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
	 		
	 		cTagAux:= "oDet["+Alltrim(STR(i))+"]:_IMPOSTO:_ICMS:_ICMS00:_VBC:TEXT"
			nbIcms := 0
			
			if Type( cTagAux ) <> "U" 			
				nbIcms := Val( oDet[i]:_IMPOSTO:_ICMS:_ICMS00:_VBC:TEXT )				
			endif
			
			cTagAux:= "oDet["+Alltrim(STR(i))+"]:_IMPOSTO:_ICMS:_ICMS00:_PICMS:TEXT"
			npIcms := 0
			
			if Type( cTagAux ) <> "U"  			
				npIcms := Val( oDet[i]:_IMPOSTO:_ICMS:_ICMS00:_PICMS:TEXT )				
			endif
			
			cTagAux:= "oDet["+Alltrim(STR(i))+"]:_IMPOSTO:_ICMS:_ICMS00:_VICMS:TEXT"
			
			if Type( cTagAux ) <> "U"  			
				nvIcms2 := Val( oDet[i]:_IMPOSTO:_ICMS:_ICMS00:_VICMS:TEXT )				
				if nvIcms2 > 0				
					nvIcms := nvIcms2 					
				endif				
			endif	
			
			//IPI
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
		Endif
	 	//FR
	 	
	 	cCCT     := Space(TAMSX3("D1_CC")[1])
	 	cFornece := cCodFor     //recebe variavel private
	 	cLojaFor := cLojFor     //recebe variavel private
		
		If cPCSol == "S"  //Centro de Custo do Pedido, então manda vazio para pegar do pedido ao relacionar o pedido F5 ou F6			
			//If lClassifica				//FR - 26/05/2022 - PETRA - MULTIPLOS NFE - comentado porque se é pra pegar do pedido vai pegar em qq situação			
				SC7->(OrdSetFocus(1))  //C7_FILIAL + C7_NUM + C7_ITEM				
				If SC7->(Dbseek(xFilial("SC7") + cXPed + cXItemPed))				
					cCCT := SC7->C7_CC
					cFornece := SC7->C7_FORNECE
					cLojaFor := SC7->C7_LOJA					
				Endif				
			//Else							//FR - 26/05/2022 - PETRA - MULTIPLOS NFE		
			//	cCCT := TAMSX3("D1_CC")[1] 	//FR - 26/05/2022 - PETRA - MULTIPLOS NFE				
			//Endif			   				//FR - 26/05/2022 - PETRA - MULTIPLOS NFE		
			
		Elseif cPCSol != "Z"   //=> Com o Z não preenche o D1_CC, senão ao caso utilizar um gatilho poderia sobrepor o gatilho			
			
			//D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM                                                                                                     
			//se já tiver pré-nota pega o CC da pré nota caso tenha sido feita primeiro e associado ped. compra com cc ou se já foi digitado na própria pré-nota o CC
			SD1->(OrdSetFocus(1))
			If SD1->(DbSeek(xFilial("SD1") + xNota + xSerie + xFornece + xLoja + cProduto + StrZero(nIte,4) )) //StrZero(nD1Item,4) )) 
				cCCT := SD1->D1_CC 
				
			Else
				if .not. empty( cProduto ) .And. SB1->( DbSeek(xFilial("SB1")+cProduto) )  			
					cCCT := SB1->B1_CC					
				endif
			Endif 
						
		Endif
		
		If Empty(cCCT)	
						
			//se ainda assim continuar vazio, pega do cadastro produto
			If Empty(cCCT)
				if .not. empty( cProduto ) .And. SB1->( DbSeek(xFilial("SB1")+cProduto) )  			
					cCCT := SB1->B1_CC					
				endif
			Endif 

		Endif
		//FR - 26/05/2022 - PETRA - MULTIPLOS NFE 
				 	
	 	//==============================//
		//Montando o array de itens: 
		//De acordo com a ordem no SX3  
		//==============================//
		aadd(aLinha,{"D1_ITEM"  	,StrZero(nD1Item,4)     ,Nil})
		aadd(aLinha,{"D1_COD"   	,cProduto               ,Nil})		
		aadd(aLinha,{"D1_UM"		,cUM           		 	,Nil})
		aadd(aLinha,{"D1_LOCAL"		,cLocPad	 			,Nil})
		aadd(aLinha,{"D1_SEGUM"		,c2UM           	 	,Nil})
		aadd(aLinha,{"D1_QUANT" 	,nQuant					,Nil})
		aadd(aLinha,{"D1_VUNIT" 	,nVunit					,Nil})
		aadd(aLinha,{"D1_TOTAL" 	,nTotal					,Nil})
		aadd(aLinha,{"D1_TES" 		,Space(3) 				,Nil})
		
		If lClassifica		
			aadd(aLinha,{"D1_VALIPI"	,nvIpi					,Nil})
			aadd(aLinha,{"D1_VALICM"	,nvIcms					,Nil})
			//aadd(aLinha,{"D1_TES" 		,Space(3) 				,Nil})
			//aadd(aLinha,{"D1_CF" 		,Space(4) 				,Nil})				
			aadd(aLinha,{"D1_IPI"		,npIpi					,Nil}) 
			aadd(aLinha,{"D1_PICM"		,npIcms					,Nil})
			//aadd(aLinha,{"D1_CC"    	,cCCT					,Nil}) 					
		Endif
		aadd(aLinha,{"D1_CC"    	,cCCT					,Nil}) 	//FR - 26/05/2022 - PETRA - MULTIPLOS NFE 				
		
		If lXMLPEVAL		
			aadd(aLinha,{"D1_PEDIDO"	,cXped         	   		,Nil})			
			if !Empty(cXItemPed)			
				aadd(aLinha,{"D1_ITEMPC",cXItemPed		   		,Nil})				
			endif			
		Endif
		
		//aadd(aLinha,{"D1_FORNECE"	,cFornece		   			,Nil})
		//aadd(aLinha,{"D1_LOJA"		,cLojaFor					,Nil}) 
		
		
		////NFORI
		//---------------------------------------------------------------------//
		//FR - 26/07/2021 - #11021 - DAIKIN - trazer o numero docto original    
		//---------------------------------------------------------------------//     
	    cTagItOri  := ""
	    cTagRefNfe := ""
	    lSubstring := .F.
	    _NfOri     := ""
	    _SrOri	   := ""	    
	    _xNOr      := Space(9)
		_xSOr      := "   "
		//----------------------------------------------------------------------------------------------------------------------//    
		//Aqui, pega o número da nf / série -> documento de origem
		//pode ser que venha mais de uma nf original, então estará dentro de um array, abaixo contemplo as duas possibilidades:
		//----------------------------------------------------------------------------------------------------------------------//
    	obj := Nil
    	If XmlChildEx(oXml:_NFEPROC:_NFE:_INFNFE:_IDE, '_NFREF') <> Nil  //Documento original vem dentro de um array
    	
    		If XmlChildEx(oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_NFREF, '_REFNFE') <> Nil
    		
    			cTagRefNfe := ""  //"oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_NFREF:_REFNFE:TEXT"
    		Else 
    		
    			obj := oXml:_NFEPROC:_NFE:_INFNFE:_IDE
		    	If ValType(obj:_NFREF) == "A" //Se for array 
		    	
		    		If nD1Item <= Len(obj:_NFREF)
		    			cTagRefNfe := obj:_NFREF[nD1Item]:_REFNFE:TEXT        //obj:_NFREF[1]:_REFNFE:TEXT 
		    			cChvReg    := cTagRefNfe
						_xNOr      := Substr(cChvReg,26,9)
						_xSOr      := Substr(cChvReg,23,3)  //esta com 3 zeros
							
			   		Else
			   			cTagRefNfe := "." //SE PASSOU POR AQUI para não cair lá embaixo, coloco este ponto
			   		Endif
		    	Else
		    		cTagRefNfe := "oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_NFREF:_REFNFE:TEXT"
		    	Endif
    		Endif
	    Endif
        
    	If Empty(cTagRefNfe)    //Documento original vem dentro de uma cadeia de caracteres
    	
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
						
            cAuxTag := "oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_NFREF"
            If Type(cAuxTag) <> "U"

				If lSubstring 		//indica que a informação do documento original está dentro de uma cadeia de caracteres, então tenho que pegar via substring
		
					cChvReg := &(cTagRefNfe)
					_xNOr   := Substr(cChvReg,26,9)
					_xSOr   := Substr(cChvReg,23,3)  //esta com 3 zeros		
			
				Else				//indica que o número e série da nf estão em campos distintos, então dá pra pegar direto
						
					cChvReg := &(_NfOri)
					//No caso de nota de origem não encontrada ECOURBIS CHAMADO 11664
					If ValType(cChvReg) <> "U"
						_xNOr   := StrZero( Val(cChvReg),9,0)
					Else
						_xNOr   := ""
					EndIf                   
			
					cChvReg := &(_SrOri)
					//No caso de nota de origem não encontrada ECOURBIS CHAMADO 11664
					If ValType(cChvReg) <> "U"
						_xSOr   := StrZero( Val(cChvReg),3,0)   
					Else
						_xSOr   := ""
					EndIf   

				Endif		

			EndIf
				
			If nFormSer = 2
				If Val(_xSOr) <= 99
					_xSOr := StrZero(Val(_xSOr),2,0)+" "
				Endif
			Elseif nFormSer = 3
				_xSOr := StrZero( Val(_xSOr),3,0)	  
			Endif		
	    
	    Endif		//If Empty(cTagRefNfe)
	    
		cNfOri := _xNOr
		cSerOri:= _xSOr
		
		//--------------------------------------------------------//
		//FR - 13/08/2021 - item da nf original - #11021 - DAIKIN
		//--------------------------------------------------------//
		cItOri     := "" 
		cDescIt    := ""
		limite     := 0
		
		cTagItOri:= "oDet["+AllTrim(Str(i))+"]:_Prod:_XPROD:TEXT"
		 If Type(cTagItOri) <> "U"
			cDescIt:= Alltrim(&(cTagItOri))  //deixa aqui com a descrição completa 		
		EndIf
		//----------------------------------------------------------------------------------------------------------------------------------//
		//A CHAVE DE TUDO É AQUI, SÓ SE TIVER DOIS PONTOS NA DESCRIÇÃO, A DAIKIN INSERE O ITEM DA NF ORIGINAL JUNTO COM A DESCRIÇÃO DO ITEM
		//----------------------------------------------------------------------------------------------------------------------------------//
		nPos := 0
		nPos := At(":" , cDescIt)  //Daikin usa ":" dois pontos para separar dentro da descrição do produto, qual item original se refere.
		
		//----------------------------------------------------------------------------------------------------------------------------------//		
		//SÓ ENTRA NO BLOCO ABAIXO QUANDO NA DESCRIÇÃO DO ITEM DO XML, POSSUIR ":" (DOIS PONTOS) 
		//PARA DESIGNAR QUE O ITEM DA NOTA ORIGINAL FAZ PARTE DA DESCRIÇÃO DO PRODUTO NO XML
		//----------------------------------------------------------------------------------------------------------------------------------//
		If nPos > 0  .AND. "-NF" $ cDescIt
							
		    //qdo a nfori fica vazio é porque o array de notas originais tem menos notas do que a qtde de itens da nf
			cItOri := Strzero(Val(Substr(cDescIt,nPos+1,Len(cDescIt)-nPos)), 4)     //aqui fica só o numero do item, trouxe da tag nferef			
			cAux := ""
			//o item original já tem, agora pegar o número da nf que está na descrição do item
			If "-NF" $ cDescIt           //Exemplo: "CONTROLE REMOTO SEM FIO P/UNID.EVAP.VRV/-NF40590 ITEM:01"
			
				limite := nPos - 5
				For fr := 1 to limite //Len(cDescIt)
					If Substr(cDescIt,fr,3) == "-NF"
						cAux += Alltrim(Substr(cDescIt,fr+3,6)) //pega a partir do primeiro caracter depois de -NF e vai até o " " espaço antes de ITEM:
						Exit       //qdo encontra, cai fora do For
					Endif
				Next
				cNfOri := Strzero(Val(cAux),9)				
			Endif						
		Else
			cItOri := ""
		Endif
		//--------------------------------------------------------------------------//		
		//FR - 26/07/2021 - #11021 - DAIKIN - trazer o numero docto original
		//--------------------------------------------------------------------------//         
		
		aadd(aLinha,{"D1_NFORI"		,cNfOri			,Nil})
		aadd(aLinha,{"D1_SERIORI"	,cSerOri 		,Nil})
		aadd(aLinha,{"D1_ITEMORI"   ,cItOri			,Nil})
		////NFORI
		
		If lClassifica 		
			//aadd(aLinha,{"D1_NFORI"		,Space(9)		,Nil})
			//aadd(aLinha,{"D1_SERIORI"	,Space(3) 			,Nil})		
			
	 		aadd(aLinha,{"D1_BASEICM"	,nbIcms				,Nil})
	 		
	 		if nVdesc > 0	 		
				aadd(aLinha,{"D1_VALDESC" ,nVdesc			,Nil})				
			endif
			
			aadd(aLinha,{"D1_BASEIPI"	,nbIpi					,Nil})			
		Endif
		
	 	If .Not. Empty(cCodFci)	 	
			aadd(aLinha,{"D1_FCICOD",cCodFci				,Nil})			
		EndIf
		
		//----------------------------------//
		//fim da montagem do array de itens
		//----------------------------------//
		
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
	 		aadd(_aItens,aLinha)	 		
	 		nD1Item++	 		
		 	aadd(aItXml,{StrZero(i,4),oDet[i]:_Prod:_CPROD:TEXT,oDet[i]:_Prod:_XPROD:TEXT})	 	
	 	endif	 	
		aLinha := {}
	Next i

	//Itens não encontrados
	if .not. U_HFITNENC( "PREN", aProdOk, aProdNo, aProdVl, @nErrItens, aProdZr )	
	    lRetorno := .F.	    
	endif	
	nIte := nD1Item

Return( lRetorno )



//Verificação da amarração 
***************************
Static Function VERAMARRA()
***************************
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
Local lLOk 		  := .F.
Local lTOk 		  := .F.
Local i

Private oDet
Private aParam := {}
Private cCodEmit  := cCodFor
Private cLojaEmit := cLojFor

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

	DbSelectArea( "TMPHF" )
	TMPHF->( DbGotop() )	

	While .not. TMPHF->( Eof() )

		IncProc("Verificando amarração " + TMPHF->CHAVE)
		
		if .not. empty( TMPHF->OK ) // == cMarcaOK		

			cError := ""
			cWarning := ""			

			DbSelectArea( xZBZ )			
			(xZBZ)->( dbGoTo( TMPHF->REG ) )	

			cXml := NoAcento((xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML"))))
			cXml := EncodeUTF8(cXml)

			//Faz backup do xml sem retirar os caracteres especiais
			cBkpXml := cXml

			//Executa rotina para retirar os caracteres especiais
			cXml := u_zCarEspec( cXml )

			oXml := XmlParser(cXml, "_", @cError, @cWarning )

			//retorna o backup do xml
			cXml := cBkpXml	

			DbSelectArea( "TMPHF" )			

			If oXml == NIL .Or. !Empty(cError) .Or. !Empty(cWarning)	

				TMPHF->( dbSkip() )
				Loop	

			Endif

		Else	

			TMPHF->( dbSkip() )			
			Loop

		Endif

		cTipoCPro := cAmarra
		aCabec := {}
		
		aadd(aCabec,{"F1_TIPO"   ,Iif(Empty( TMPHF->TPDOC ),"N",AllTrim( TMPHF->TPDOC ))})
		aadd(aCabec,{"F1_FORMUL" ,"N"})

		DbSelectArea( xZBZ )
		
		oDet := oXml:_NFEPROC:_NFE:_INFNFE:_DET
		oDet := IIf(ValType(oDet)=="O",{oDet},oDet)

		nD1Item := 1
		
		nTotLen := Len(oDet)
		For i := 1 To nTotLen
		
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
				aadd(aLinha,{"D1_CC"    ,nTamCc  					 ,Nil})				
			elseif cPCSol != "Z"   //=> Com o Z não preenche o D1_CC, senão ao caso utilizar um gatilho poderia sobrepor o gatilho				
				if .not. empty( cProduto ) .And. SB1->( DbSeek(xFilial("SB1")+cProduto) )				
					aadd(aLinha,{"D1_CC",SB1->B1_CC					 ,Nil})				
				endif				
			endif
			
			If lXMLPEVAL // .Or. !Empty(cXped)			
				aadd(aLinha,{"D1_PEDIDO",cXped		            		,Nil})				
				if !Empty(cXItemPed)				
					aadd(aLinha,{"D1_ITEMPC",cXItemPed					,Nil})					
				endif				
			EndIF
			
	//		aadd(aLinha,{"D1_CC"    ,Space(9)  						 ,Nil})
	//		aadd(aLinha,{"D1_PEDIDO",Space(6)               		 ,Nil})
	//		aadd(aLinha,{"D1_ITEMPC",Space(4)              			 ,Nil})
	
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
		 		aadd(_aItens,aLinha)		 		
		 		nD1Item++		 		
			 	aadd(aItXml,{StrZero(i,4),oDet[i]:_Prod:_CPROD:TEXT,oDet[i]:_Prod:_XPROD:TEXT})			 	
		 	endif		 	
			aLinha := {}	
		Next i
	
		If lLOk .And. lXMLPETOK   //PE para incluir campos no aLinha SD1 -> para o aItens	 		
	 		lTOk :=	ExecBlock( "XMLPETOK", .F., .F., { cModelo } )	 		
	 		If ValType(lTOk) <> "L"	 		
	 			Alert( "Ponto de entrada XMLPETOK deve Retornar .T. ou .F." )	 			
	 			lTOk := .F.	 			
	 		EndIf	 		
		Endif
	
		DbSelectArea( "TMPHF" )		
		if ! lLOk .or. ! lTOk		
			if U_MyAviso("Atenção","NF "+TMPHF->NOTA+" "+TMPHF->SERIE+" invalidado por suas regras, pré-nota não será gerada, deseja interromper ou continuar com as outras notas?",{"INTERROMPE","CONTINUA"},3) == 2				
				RecLock("TMPHF",.F.)				
				TMPHF->OK := "  "				
				Msunlock()				
			else			
				lRet := .F.				
				Exit				
			endif			
		endif	
		TMPHF->( dbskip() )		
	Enddo

	//Itens não encontrados
	
	if .not. U_HFITNENC( "PREN", aProdOk, aProdNo, aProdVl, @nErrItens, aProdZr )	
	    lRet := .F.	    
	endif
EndIf

TMPHF->( DbGotop() )

Return( lRet )


******************************************************************************************************
User Function HFSTXMU2( cFilZbz, cNotaZbz, cSerieZbz, cCodFor, cTipoNf, cModZbz, cDocCteZbz, nRecZbz )
******************************************************************************************************
Local aArea     := GetArea()
Local nFormNfe  := Val(GetNewPar("XM_FORMNFE","6"))
Local cNotaSeek := ""
Local lSeek     := .F.
Default cDocCteZbz := Space(9)
Default nRecZbz    := (xZBZ)->( Recno() )

nOk := 0
nNo := 0

DbSelectArea("SF1")
DbSetOrder(1)

	lSeek := .F.	
	cNotaSeek :=  Iif(nFormNfe > 0,StrZero(Val(cNotaZbz),nFormNfe),AllTrim(Str(Val(cNotaZbz))))    
    lSeek := DbSeek(cFilZbz+Padr(cNotaSeek,9)+cSerieZbz+cCodFor+cTipoNf)
    If !lSeek    
		cNotaSeek := AllTrim(Str(Val(cNotaZbz)))
   	   	lSeek := DbSeek(cFilZbz+Padr(cNotaSeek,9)+cSerieZbz+cCodFor+cTipoNf)  
    EndIf

    If !lSeek    
   		cNotaSeek :=  StrZero(Val(cNotaZbz),6)
   	   	lSeek := DbSeek(cFilZbz+Padr(cNotaSeek,9)+cSerieZbz+cCodFor+cTipoNf)   
    EndIf
 
    If !lSeek    
   		cNotaSeek :=  StrZero(Val(cNotaZbz),9)
   	  	lSeek := DbSeek(cFilZbz+Padr(cNotaSeek,9)+cSerieZbz+cCodFor+cTipoNf)    
    EndIf

	//aquiii Multiplos NFE
    If !lSeek .And. cModZbz == "55" .AND. ! Empty( cDocCteZbz )		
		cNotaSeek :=  Iif(nFormNfe > 0,StrZero(Val(cDocCteZbz),nFormNfe),AllTrim(Str(Val(cDocCteZbz ))))
        lSeek := DbSeek(cFilZbz+Padr(cNotaSeek,9)+cSerieZbz+cCodFor+cTipoNf)   
    EndIF

    If !lSeek .And. cTipoNf == "N" .and. cModZbz == "55"    
		cTipoNf := "C" //->Checar se é C
		cNotaSeek :=  Iif(nFormNfe > 0,StrZero(Val(cNotaZbz),nFormNfe),AllTrim(Str(Val(cNotaZbz))))
	   	lSeek := DbSeek(cFilZbz+Padr(cNotaSeek,9)+cSerieZbz+cCodFor+cTipoNf)
	   		
	   	If !lSeek	   	
			cNotaSeek := AllTrim(Str(Val(cNotaZbz)))
	    	lSeek := DbSeek(cFilZbz+Padr(cNotaSeek,9)+cSerieZbz+cCodFor+cTipoNf)	  
	   	EndIf
	
	   	If !lSeek	   	
			cNotaSeek :=  StrZero(Val(cNotaZbz),6)
	    	lSeek := DbSeek(cFilZbz+Padr(cNotaSeek,9)+cSerieZbz+cCodFor+cTipoNf)	   
	   	EndIf
	 
	   	If !lSeek	   	
			cNotaSeek :=  StrZero(Val(cNotaZbz),9)
	    	lSeek := DbSeek(cFilZbz+Padr(cNotaSeek,9)+cSerieZbz+cCodFor+cTipoNf)	   
	   	EndIf

		//aquiii Multiplos NFE
		If !lSeek		
			cNotaSeek :=  Iif(nFormNfe > 0,StrZero(Val(cDocCteZbz),nFormNfe),AllTrim(Str( Val(cDocCteZbz ))))
        	lSeek := DbSeek(cFilZbz+Padr(cNotaSeek,9)+cSerieZbz+cCodFor+cTipoNf)	    
	    EndIF
	    
	Endif

	DbSelectArea(xZBZ)
	DbGoTo(nRecZbz)
   
    If lSeek    
		nOk++
		RecLock(xZBZ,.F.)		
		(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PRENF"), Iif(Empty(SF1->F1_STATUS),'S','N') ))		
		if cTipoNf == "C" .and. (xZBZ)->&(xZBZ_+"TPDOC") == "N" .And. (xZBZ)->&(xZBZ_+"MODELO") == "57" //aqui			
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPDOC"), cTipoNf ))		
		endif
		
		(xZBZ)->( MsUnlock() )
		
	ElseiF (xZBZ)->&(xZBZ_+"PRENF") $ "A|S|N" 	
		If (xZBZ)->&(xZBZ_+"PRENF") == "A"		
			nNo++			
		Endif

		DbSelectArea("DB2")
		DbSetorder(1)
	  
	    lSeek := .F.		
		cNotaSeek :=  Iif(nFormNfe > 0,StrZero(Val(cNotaZbz),nFormNfe),AllTrim(Str(Val(cNotaZbz ))))	   
	    lSeek := DbSeek(cFilZbz+Padr(cNotaSeek,9)+cSerieZbz+cCodFor)        
		DbSelectArea(xZBZ)		
		DbGoTo(nRecZbz)		
		RecLock(xZBZ,.F.)		
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PRENF"), iif(lSeek, 'A', 'B') ))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"DOCCTE"), space(9) ))			
		(xZBZ)->( MsUnlock() )			
	Else	
		nNo++		
	EndIf
	cRet := (xZBZ)->(FieldGet( FieldPos(xZBZ_+"PRENF") ) )

RestArea( aArea )

Return( cRet )


**********************************
Static Function TrocaAspas( cCod )
**********************************
Local cRet := cCod
cRet := StrTran(cRet,"'",'"')  //troca ' por " -> Isto serve para quando o código do produto vem com ', pois o SA5/SA7 é feito query a qual utiliza-se de '
Return( cRet )


**********************************
Static Function __Dummy(lRecursa) //warning W0010 Static Function <?> never called  
**********************************
lRecursa := .F.
IF (lRecursa)
    __Dummy(.F.)    
    U_HFXMLMCT()    
EndIF
	
Return(lRecursa)


User Function fClassAut( aNotas, cClAtRBT, cTESAut, cDesc, cTipo )

Local aArea       := GetArea()
//Local lOk         := .T.
Local cTes	      := CriaVar("D1_TES",.F.)
Local nOpcTES     := 0
//Local nRecno      := 0
Local nIte		  := 0
//Local lTem 		  := .F.
//Local cError      := ""
//Local cWarning    := ""
Local cMsg		  := ""
Local nRecZBZ     := 0
Local cNota		  := ""
Local aCabec	  := {}
Local _aItens	  := {}
Local lInfTES     := .T.
Local cTESAut     := ""  							//Tes automático caso a regra esteja definida para não ser informado pelo usuário 
Local cTitulo     := ""
Local lMostraTela := .T.  
Local lTemTES	  := .T. 							//indica que o item lido possui TES associado e pode prosseguir com a geração da nf 
Local lProssegue  := .T.   
Local cCfgPre     := GetNewPar("XM_CFGPRE","0")		//FR 09/06/2020 - "tarefa: gera nota fiscal direto"
Local lNFDireto   := (cCfgPre $ "3")				//FR 09/06/2020 - "tarefa: gera nota fiscal direto" - Se = 3, já gera documento de entrada direto, sem passsar por pré nota
Local nPos        := 0
Local fr          := 0
Local it          := 0
Local x           := 0
Local cClAtRBT    := GetNewPar("XM_CLATRBT","1")  	//FR - 06/08/2020 - Tipo da robotização quando utilizada Classificação Automática:
Local lEnergia    := .F.							//FR - 22/09/2020
Local oProcess	  :=	Nil							//FR - 30/09/2020
Local cManPre     := GetNewPar("XM_MANPRE","N")  	//FR - 17/03/2021 - Verifica qual tipo de manifestação
Local cNaturez    := ""								//FR - 28/06/2021 - TELETEX
Local cCustoPC    := "" 							//FR - 26/05/2022 - PETRA MULTIPLOS NFE 
Local nX          := 0 

Private lPCNFE    := GetNewPar("MV_PCNFE",.F.)		//indica se exige pedido de compra para a nf
Private nOpClas   := 0
Private cSayITES  := Space(1)  						//label do campo se informa TES S/N
Private nCBoxITES := 0         						//combo box se informa TES S/N 
Private aInfTES   := {"Sim","Não"} 					//array de itens do combobox acima
Private cTES      := Space(3)  						//get do TES
Private cGetITES  := Space(3)						//get visual do informa TES
Private cSayTES   := Space(1)  						//label do get do TES
Private cUsaDvg   := GetNewPar("XM_USADVG","N") 	//FR 19/05/2020 - ativa se usa verificação de divergências Sim/Não
Private aDocOri   := {"1",;    // (Gestão XML)     -> Erick Silva - 16/02/2023
					  "2"}     // (Protheus Padrão) 
Private lDiverg   := .F. 		

SetPrvt("oDlgClas","oGrpClas","oSayTpArq","oCBoxTpArq","oSayITES","oCBoxITES","oSayTES","oGetTES","oGetITES","oSBtnCla1","oSBtnCla2") 

If cTipo = 'NFE'

	cTESAut  := Padr(GetNewPar("XM_NFE_TES",Space(3)),3)   //Tes automático caso a regra esteja definida para não ser informado pelo usuário 	

Else

	cTESAut  := Padr(GetNewPar("XM_CTE_TES",Space(3)),3)	

Endif

lEnergia := U_fVerXMLEnerg(,,,.T.,oProcess)  //U_fVerXMLEnerg(aCab,aIte,lSoCheck)

//fSX6NAT("2") //FR - 28/06/2021 - #10851 - TELETEX 1-Liga; 2-Desliga


//FR - 22/06/2021 - #10851 - TELETEX
//variáveis do cadastro
_cCondPg := ""
_cNaturez:= ""
_cCusto  := Space(30)  //FR - 09/02/2022 - Alteração mediante chamado Trigoarte, campo deles de Centro Custo possui 12 caracteres
_cItemCtb:= ""
_cTES    := ""

//variáveis da tela
cCondPg  := ""
cNaturez := ""
cCusto   := Space(30)  //FR - 09/02/2022 - Alteração mediante chamado Trigoarte, campo deles de Centro Custo possui 12 caracteres
cItemCtb := ""
x 		 := 0
_cFornece:= ""
_cLojaFor:= ""

//nPos := ASCAN(aNotas[1][2], { |p| UPPER(alltrim(p[2])) == "F1_FORNECE" }) 
For x := 1 to Len(aNotas[1,2])
	nPos := 0
	If Upper(aNotas[1,2,x,1]) == "F1_FORNECE"
		nPos      := x
		_cFornece := aNotas[1,2,x,2]		
	Endif
	
	If Upper(aNotas[1,2,x,1]) == "F1_LOJA"
   		_cLojaFor := aNotas[1,2,x,2]
 	Endif
 	
 	If !Empty(_cFornece) .and. !Empty(_cLojaFor) //se encontrou os dois códigos, pode sair do For
 		Exit
 	Endif
 	
Next


SA2->(OrdSetFocus(1))
If SA2->(Dbseek(xFilial("SA2") + _cFornece + _cLojaFor ))
	_cCondPg := SA2->A2_COND
	_cNaturez:= SA2->A2_NATUREZ		
Endif

//For x := 1 to Len(aItens[1]) 
For x := 1 to Len(aNotas[1][3][1])

	//Checa D1_COD 				   
   	//nPos := ASCAN(aNotas[1], { |p| UPPER(alltrim(p[1])) == "D1_COD" }) 
	If Upper(aNotas[1,3,1,x,1]) == "D1_COD"
		SB1->(OrdSetFocus(1))			   	
   		If SB1->(Dbseek(xFilial("SB1") + aNotas[1,3,1,x,2] )) //produto	 				   			
   			_cCusto   := SB1->B1_CC
   			_cItemCtb := SB1->B1_ITEMCC
   			_cTES     := SB1->B1_TE				   			
   		Endif
	Endif			   	
Next

//FR - 22/06/2021
cTitulo     := "Campos p/ Nota Fiscal"	
If cClAtRBT $ '1/2' 								

	lMostraTela  := .T.
	nOpClas      := 0	
	
Elseif cClatRBT = '3'							//FR ->3-captura direto o TES do parâmetro XM_NFE_TES

	cTES        := cTESAut 
	
Elseif cClatRBT = '4'							//FR ->4-captura direto o TES do cadastro do produto

	cTES        := _cTES   

Endif

//novas variáveis de tela - #10851 - TELETEX
If !Empty(_cCondPg)
	cCondPg  := _cCondPg			//FR - 22/06/2021
Else
	cCondPg  := Padr(Space(3),3)
Endif
		
If !Empty(_cNaturez)
	cNaturez := _cNaturez			//FR - 22/06/2021
Else
	cNaturez := Padr(Space(9),9)
Endif
		
If !Empty(_cCusto)
	cCusto   := _cCusto				//FR - 22/06/2021
Else
	cCusto   := Space(30) //Space(TAMSX3("D1_CC")[1])  //FR - 09/02/2022 - Alteração mediante chamado Trigoarte, campo deles de Centro Custo possui 12 caracteres
Endif
		
If !Empty(_cItemCtb)
	cItemCtb := _cItemCtb			//FR - 22/06/2021
Else
	cItemCtb := Padr(Space(9),9)
Endif
//FR - 22/06/2021

//Dialog para informar/capturar automaticamente o TES
If lMostraTela
	
	oDlgClas := MSDialog():New( 174,431,500,737,cTitulo,,,.F.,,,,,,.T.,,,.T. )  
	oGrpClas := TGroup():New( 004,004,108,152,"",oDlgClas,CLR_BLACK,CLR_WHITE,.T.,.F. ) 
					
	oSayTES := TSay():New( 012,008,{||"* TES:"},oGrpClas,,,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,122,008) 
			
	oGetTES := TGet():New( 012,060,{|u| If(PCount()>0,cTES:=u,cTES)},oGrpClas,076,008,'',{|| fValTES(cTES)} /*bvalid*/,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SF4","cTES",,)      //EDITAVEL	
	
	oSayCond := TSay():New( 032,008,{||"* Cond.Pagto:"},oGrpClas,,,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,044,008) 
	oGetCond := TGet():New( 032,060,{|u| If(PCount()>0,cCondPg:=u,cCondPg)},oGrpClas,076,008,'',{|| fValCond(cCondPg)} /*bvalid*/,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SE4","cCondPg",,)      
	
	oSayNat  := TSay():New( 052,008,{||"* Natureza:"},oGrpClas,,,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,044,008) 
	oGetNatu := TGet():New( 052,060,{|u| If(PCount()>0,cNaturez:=u,cNaturez)},oGrpClas,076,008,'',{|| fValNAT(cNaturez)} /*bvalid*/,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SED","cNaturez",,)
	
	oSayCC   := TSay():New( 072,008,{||"Centro Custo:"},oGrpClas,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,044,008) 
	oGetCC   := TGet():New( 072,060,{|u| If(PCount()>0,cCusto:=u,cCusto)},oGrpClas,076,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"CTT","cCusto",,)
	
	oSayICC  := TSay():New( 092,008,{||"Item Contab:"},oGrpClas,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,044,008) 
	oGetICC  := TGet():New( 092,060,{|u| If(PCount()>0,cItemCtb:=u,cItemCtb)},oGrpClas,076,008,'',{|| fValITCTB(cItemCtb)} /*bvalid*/,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"CTD","cItemCtb",,)
    //fValITCTB							
	oSayObs  := TSay():New( 112,008,{||"* Altere, Caso Necessario os Campos Acima"},oDlgClas,,,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,120,008) 
	
	oSBtnCla1          := TButton():New( 132,066,"Confirma",oDlgClas,,037,012,,,,.T.,,"",,,,.F. )
	oSBtnCla1:bAction  := {|| ( nOpClas := 1, oDlgClas:End() ) }
		
	oSBtnCla2          := TButton():New( 132,110,"Cancela",oDlgClas,,037,012,,,,.T.,,"",,,,.F. )
	oSBtnCla2:bAction  := {|| ( nOpClas:= 0, oDlgClas:End()) } 
					
	oDlgClas:Activate(,,,.T.)

Endif
		
lin := 0
fr  := 0
lDoubleChk:= .F.
lSA2 := .F. //FR - 02/07/2021
If nOpClas = 1 		//se confirmou a tela de Classifica Automática x TES
    lSA2 := fSA2NAT(_cFornece,_cLojaFor,cNaturez)    //fr - 02/07/2021

	nTotLen := Len(aNotas)
	
	//------------------------------------------------------------------------------------------//
	//FR Pré Auditoria Fiscal
	//FR - tratativa para identificar divergências entre NF e XML:
	//FR 14/05/2020 primeira varrida no array de notas para verificar possíveis divergências
	//------------------------------------------------------------------------------------------//
	aNFDiverg := {}
	nOpDiverg := 0
	lProssegue:= .T.
	lDoubleChk:= .F.

	//FR - CHECAGEM DE DIVERGÊNCIA
	If cUsaDvg == "S" .and. cTipo <> "CTE"  
	
		For fr := 1 to nTotLen       //Len(aNotas)  		//aNotas

			cNota      := aNotas[fr][1]		
			aCabec     := aNotas[fr][2]
			_aItens    := aNotas[fr][3]  

			nPos := ASCAN(aCabec, { |p| UPPER(alltrim(p[1])) == "F1_CHVNFE" })
			if nPos > 0
				cChave := aCabec[nPos,2]    //Aadd(aNotas, {TMPHF->NOTA, aCabec, aItens, TMPHF->REG, TMPHF->CHAVE} )	//FR - 28/11/19 
			endif

			nPos := ASCAN(aCabec, { |p| UPPER(alltrim(p[1])) == "F1_SERIE" })
			if nPos > 0
				cSerie := aCabec[nPos,2]    //Aadd(aNotas, {TMPHF->NOTA, aCabec, aItens, TMPHF->REG, TMPHF->CHAVE} )	//FR - 28/11/19 
			endif

			nPos := ASCAN(aCabec, { |p| UPPER(alltrim(p[1])) == "F1_FORNECE" })
			if nPos > 0
				cFornece := aCabec[nPos,2]    //Aadd(aNotas, {TMPHF->NOTA, aCabec, aItens, TMPHF->REG, TMPHF->CHAVE} )	//FR - 28/11/19 
			endif

			nPos := ASCAN(aCabec, { |p| UPPER(alltrim(p[1])) == "F1_LOJA" })
			if nPos > 0
				cLojfor := aCabec[nPos,2]    //Aadd(aNotas, {TMPHF->NOTA, aCabec, aItens, TMPHF->REG, TMPHF->CHAVE} )	//FR - 28/11/19 
			endif

			aCabNFE    := {}
			aIteNFE    := {} 
			lDiverg    := .F.

		
			U_fMontaArray(aCabec,_aItens,@aCabNFE,@aIteNFE) 
			//FR - Monta os arrays aCabNFE e aIteNFE, ambos são da NF, mas não posso utilizar o aCabec nem o aItens, pois não estão na ordem necessária	
			//FR - utiliza os arrays aCabec e aItens para montar os arrays aCabNFE e aIteNFE -> estes dois últimos têm a estrutura necessária
			//para comparação com o array de cabeçalho e itens do XML 
			lOmiTTela := .T.     //FR - .T. = omite a exibição da tela de divergência, e só gera o relatório em Excel, Nil = Mostra a tela
			lDiverg   := U_HFXML063(cChave,aCabNFE,aIteNFE,"NOTA FISCAL",,lOmiTTela)  //FR este parâmetro .T. indica se a chamada da função é "de fora", ou seja, sem mostrar a tela. 
			//FR -  chamada da tela função da tela de divergências, porém, sem apresentar a tela, só checagem de divergências mediante apresentação do relatório em Excel
			
			If lDiverg

				aAdd( aNotas[fr,2], {"DIVERG",lDiverg} )	//povoa a posição da divergência com o resultado obtido: .T. ou .F.
				Aadd( aNFDiverg , {cNota, cSerie, cFornece, cLojfor} )	

			else

				aAdd( aNotas[fr,2], {"DIVERG",.F.} )	
			
			Endif	

		Next fr
		
		//depois de verificar todas as notas do array aNotas, e filtrar apenas as que tem divergências, exportaremos para excel para mostrar ao usuário:
		If lDiverg .and. !lEnergia		//FR - 22/09/2020
			
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
		
	Else 
		lProssegue := .T.
	Endif
	//FR 19/05/2020
	
	//FR segunda varrida no array já é para processar a classificação
	For fr := 1 To Len(aNotas)	

		If fr <= Len(aNotas)	
            lProssegue := .T.		//reinicia o lProssegue para a próxima nota, pois será verificado se gera ou não

			nPos := ASCAN(aNotas[fr,2], { |p| UPPER(alltrim(p[1])) == "DIVERG" })
			
			if nPos > 0

				lDiverg := aNotas[fr,2,nPos,2]    //Aadd(aNotas, {TMPHF->NOTA, aCabec, aItens, TMPHF->REG, TMPHF->CHAVE} )	//FR - 28/11/19 
			
				If lDiverg     //aNotas[fr,9]			//FR - se tem divergência, esta posição estará = .T.
				
					lProssegue := .F.       //não prossegue
					lDoubleChk := .T.		//dupla checagem caso no loop anterior não tenha sido identificada divergência devido ainda estar apenas em modo pré-nota
										    //depois que classificar é possível pegar da SD1/SF1 já com mais valores, farei isto ao final deste loop caso lDoubleChk estiver .F.
					If nOpDiverg == 1 		//mas, se o usuário escolheu que prossegue mesmo com divergência, a NF será classificada mesmo assim
						lProssegue := .T.
					Endif

				Endif

			endif

		  	cNota := aNotas[fr][1]
		  
			If lProssegue		//FR - lProssegue da geração com divergência (escolha do usuário) - haverá várias chamadas para esta variável devido às checagens no decorrer abaixo que precisam ser feitas 
				
				cNota := aNotas[fr][1]

				nPos := ASCAN(aNotas[fr,2], { |p| UPPER(alltrim(p[1])) == "F1_SERIE" })
				if nPos > 0

					cSerie	   := aNotas[fr,2,nPos,2]		

				endif	
				aCabec  := aNotas[fr][2]
				_aItens  := aNotas[fr][3]
				nRecZBZ := aNotas[fr][4]
				
				lTemTES    := .T.
				lProssegue := .T.
					
				IncProc("Processando NF: " + cNota )   
		 
				cab      := 0
				it       := 0
				x        := 0
				nPos     := 0			//FR - 06/08/2020
				cPedComp := ""
				//cCondPg  := ""    	//FR - 22/06/2021
				cCfop    := ""
			 						
				//FR - 28/06/2021
				lTemITCTA := .F.
				lTemCC    := .F.
				aLinha    := {}
				nTotIt    := Len(_aItens)
				
				For it := 1 to nTotIt					
					For x := 1 to Len(_aItens[it]) 
						nPos := ASCAN(_aItens[it], { |p| UPPER(alltrim(p[1])) == "D1_ITEMCTA" })
						If nPos > 0
							lTemITCTA := .T.
						Endif
						nPos := 0
						nPos := ASCAN(_aItens[it], { |p| UPPER(alltrim(p[1])) == "D1_CC" })
						If nPos > 0
							lTemCC := .T.
						Endif

					Next x
				Next it

				If !lTemITCTA  //se não tiver a linha, cria
					aLinha := {"D1_ITEMCTA","",Nil}
					For nX := 1 to Len(_aItens)    
    					aadd(_aItens[nX], aLinha)	//FR - 22/06/2020 - já cria aqui a linha do TES, depois só povoa
 					Next
				Endif
				aLinha := {}

				If !lTemCC	//se não tiver a linha, cria 
					aLinha := {"D1_CC","",Nil}
					For nX := 1 to Len(_aItens)    
    					aadd(_aItens[nX], aLinha)	//FR - 22/06/2020 - já cria aqui a linha do TES, depois só povoa
 					Next
 					
					aLinha := {"D1_ITEMCC","",Nil}
					For nX := 1 to Len(_aItens)    
    					aadd(_aItens[nX], aLinha)	//FR - 22/06/2020 - já cria aqui a linha do TES, depois só povoa
 					Next
				Endif
				aLinha := {}
				//FR - 28/06/2021

				SB1->(OrdSetFocus(1))
		
				//tratativa para povoar o campo D1_TES, D1_CC, D1_ITEMCTA
				nTotIt := Len(_aItens)
				For it := 1 to nTotIt
					
					For x := 1 to Len(_aItens[it]) 
                        						
						//Checa D1_TES
						nPos := ASCAN(_aItens[it], { |p| UPPER(alltrim(p[1])) == "D1_TES" })						
					   	If nPos > 0		
					   				   	
					   		If !Empty(cTES)	.and. Empty(_aItens[it][nPos][2])		 
					   	  		_aItens[it][nPos][2] := Alltrim(cTES)   //povoa o array no campo D1_TES com o conteÃºdo da variÃ¡vel cTES (que pode ter como origem: digitaÃ§Ã£o do usuÃ¡rio;parÃ¢metro;cad.produto)			   	 				   	 	
					   	 	Elseif Empty(cTES)
					   	 		lTemTES := .F.
					   	 	Endif 
					   	 				   	 	
						Endif
						
						//FR - 06/08/2020 - Verifica se há pedido de compra para obter a condição de pagto do mesmo
						//Checa D1_PEDIDO / CONDIÇÃO PAGTO
						nPos := ASCAN(_aItens[it], { |p| UPPER(alltrim(p[1])) == "D1_PEDIDO" })
						
						If nPos > 0
						
							If !Empty(_aItens[it][nPos][2])
							    If Empty(cPedComp)
									cPedComp := _aItens[it][nPos][2]		
							   		//obtém o pedido de compra que está nos itens 
							   		//para comparar a condição de pagto do pedido com a do cad. do fornecedor
							   		//prevalecerá a condição do pedido
							  	Endif						   						   	
						  	Endif
						  	
						  	SC7->(OrdSetFocus(1))		//C7_FILIAL + C7_NUM + C7_ITEM
							If !Empty(cPedComp)		
								If SC7->(Dbseek(xFilial("SC7") + cPedComp ))										
									If !Empty(SC7->C7_COND)
										cCondPg := SC7->C7_COND
										cCustoPC:= SC7->C7_CC
										//obtém o pedido de compra que está nos itens 
						   				//para comparar a condição de pagto do pedido com a do cad. do fornecedor
						   				//prevalecerá a condição do pedido
									Endif												
								Endif
						    Endif
						  	
						Endif  //nPos > 0
                        
						//VER TES DEVOLUÇÃO
						if GetNewPar("XM_TESDEV", "N") == "S"  //Verifica cliente usará TES de devolução do campo F4_TESDV

							if cTipoNF == "D"
							
								DbSelectArea("SF4")
								DbSetOrder(1)
								DbSeek( xFilial("SF4") + cTES )

								if !Empty(SF4->F4_TESDV)

									cTES := SF4->F4_TESDV 
									
								endif
			
							endif	

						endif						 
					   	//FR - 22/06/2021 - #10851 - TELETEX 
					   	
					   	//FR - 26/05/2022 - PETRA - MULTIPLOS NFE
					   	cProdnf := ""
					   	cItnf   := ""
					   													
						If _aItens[it][x][1] = "D1_CC"	
							
							//FR - 26/05/2022 - PETRA - MULTIPLOS NFE		   	
					   		If Empty(_aItens[it][x][2]) 
								
								nPos := ASCAN(_aItens[it], { |p| UPPER(alltrim(p[1])) == "D1_COD" })	 
								If nPos > 0
									cProdnf := _aItens[it][nPos][2]
								Endif
								
   								nPos := ASCAN(_aItens[it], { |p| UPPER(alltrim(p[1])) == "D1_ITEM" })	 
								If nPos > 0
									cItnf := _aItens[it][nPos][2]
								Endif
								
								//ver se já existe esta nf como pré nota aí pega o CC dela 					
								SD1->(OrdSetFocus(1))
								If SD1->(DbSeek(xFilial("SD1") + aCabec[3][2] + aCabec[4][2] + aCabec[6][2] + aCabec[7][2] + cProdnf + cItnf )) //StrZero(nD1Item,4) )) 
									If !Empty(SD1->D1_CC)
										_aItens[it][x][2] := SD1->D1_CC

									Else  //se o D1_CC da pré-nota estiver vazio, pega do pedido compra, se não tiver, pega da variável informada na tela

										If Empty(cCustoPC)
											If !Empty(cCusto)			   		
												_aItens[it][x][2] := Alltrim(cCusto)   //povoa o array no campo D1_CC com o conteúdo da variável cCusto
											Endif
										Else
											_aItens[it][x][2] := Alltrim(cCustoPC) 
										Endif 

									Endif 
								
								Else 	//se não localizar pré-nota segue tentando pegar do pedido de compra, se não tiver pega do que foi informado na tela
				  		
							   		If Empty(cCustoPC)
								   		If !Empty(cCusto)			   		
								   	  		_aItens[it][x][2] := Alltrim(cCusto)   //povoa o array no campo D1_CC com o conteúdo da variável cCusto
								   	 	Endif
								   	Else
								   	 	_aItens[it][x][2] := Alltrim(cCustoPC) 
								   	Endif 
								Endif 
								
					   	 	Endif
							//FR - 26/05/2022 - PETRA - MULTIPLOS NFE		   				   	 	
						Endif
						
						If _aItens[it][x][1] = "D1_ITEMCTA"			   	
					   		If !Empty(cItemCtb)			   		
					   	  		_aItens[it][x][2] := Alltrim(cItemCtb)   //povoa o array no campo D1_CC com o conteúdo da variável cCusto
					   	 	Endif			   	 	
						Endif
						//FR - 22/06/2021 - #10851 - TELETEX	

				    Next x	

				Next it
				
				If Empty(cTES)				   	
			   		lTemTES := .F.				   		
			   	Endif	 
		
				If !lTemTES		
					lProssegue := .F.			
					cMsg += "Documento Não Foi Gerado NF: "+ cNota + CRLF
					cMsg += "-> Motivo: TES inexistente "+CRLF						
				Endif
							
				nPos := ASCAN(aCabec, { |p| UPPER(alltrim(p[1])) == "F1_COND" })
				If nPos == 0
					If !Empty(cCondPg)						
						aAdd(aCabec, {'F1_COND', Alltrim(cCondPg) , Nil}) 			
					Else		
						lProssegue := .F.		//sem condição de pagamento, não pode prosseguir, será exibido um aviso com os números das NFs com este problema 			
						cMsg += "Documento Não Foi Gerado NF: "+ cNota + CRLF	
						cMsg += "-> Motivo: Condição de Pagamento inexistente no Cad.Fornecedor ou no Pedido de Compra"+ CRLF			
					Endif				
				Endif
			
			
				If lProssegue  	//FR - lProssegue depois de todas as checagens (TES e Cond. Pagto)

					lMsErroAuto	:= .F.												
					xRet103     := .F.

					//FR - 26/05/2022 - algumas empresas fazem a pré nota fora da rotina multiplos nfe e usa essa rotina só para classificar:
					DbSelectArea( xZBZ )
					(xZBZ)->( dbGoTo( nRecZBZ ) )
						
					If (xZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF"))) == "S"
						
						xRet103	:=	MSExecAuto({|x,y,z| mata103(x,y,z)},aCabec,_aItens,4, ,1)  //só classificar a pré-nota existente
					
					Else 
					
						If !lNFDireto	  //FR - 17/03/2021		
							xRet103	:=	MSExecAuto({|x,y,z| mata103(x,y,z)},aCabec,_aItens,4, ,1)  //só classificar a pré-nota existente
						Else
							xRet103	:=	MSExecAuto({|x,y,z| mata103(x,y,z)},aCabec,_aItens,3, ,1)  //FR 09/06/2020 - inclui a NF - "tarefa: gera nota fiscal direto"
						Endif
					Endif 					
					//FR - 26/05/2022				
					
					//FR - 25/05/2020
					If cUsaDvg == "S" .and. cTipo <> "CTE" //FR se o parâmetro de verificar divergências estiver ativado
					//FR - neste caso a verificação de divergência só após a classificação da NF, exportando para o relatório
						If Len(aNFDiverg) <= 0
							Aadd(aNFDiverg , {cNota, cSerie, cCodFor, cLojFor} ) 
						Endif
					Endif
				
					If !lMsErroAuto
					
						//============================//
						// Atualiza informações na ZBZ
						//============================//
															               					        
						DbSelectArea( xZBZ )
						(xZBZ)->( dbGoTo( nRecZBZ ) )
						
						Reclock(xZBZ,.F.)
						
					   	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PRENF") , 'N' ))
					   	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPDOC") , SF1->F1_TIPO ))
					   	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CODFOR"), aCabec[6][2] ))
					   	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"LOJFOR"), aCabec[7][2] ))
						(xZBZ)->(FieldPut(FieldPos(xZBZ_+"ORIGEM"), aDocOri[1]	 ))

					  	If cTipo = 'CTE'                                           //FR - 09/12/19
					   		(xZBZ)->(FieldPut(FieldPos(xZBZ_+"DOCCTE"), aCabec[3][2] ))
					   	Endif

					   	//FR - 17/03/2021
						/*
						Opções do XM_MANPRE:
						N = Não Manifestar
						1 = Confirma operação (Pré-NF)
						2 = Ciência operação (Pré-NF)
						3 = Confirmação operação (Classificação)
						*/
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
						
					    (xZBZ)->( MsUnlock() )	            
					    cMsg += "Documento Classificado com Sucesso: "+aCabec[3][2]+CRLF			

					    //FR - 28/06/2021
				    	_cPrefixo := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE")))
						_cNum     := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA")))
						_cTipo    := ""
						_cFornece := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR")))
						_cLojfor  := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR")))
						_cParcela := ""
						If (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC"))) == "N"
							_cTipo := "NF"
						Endif 
                        
                        //FR - 28/06/2021 - TELETEX
						DbSelectArea("SE2")
						SE2->(OrdSetFocus(6))  //E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
						
						If SE2->(Dbseek(xFilial("SE2")+ _cFornece + _cLojfor + _cPrefixo + _cNum  )) 
							While SE2->(!Eof()) .and. SE2->E2_FILIAL == xFilial("SE2") .and. SE2->E2_FORNECE == _cFornece .and. SE2->E2_LOJA == _cLojfor ;
							.and. SE2->E2_PREFIXO == _cPrefixo .and. SE2->E2_NUM == _cNum
							
								If Alltrim(SE2->E2_TIPO) == Alltrim(_cTipo)
									RecLock("SE2", .F.)
									SE2->E2_NATUREZ := cNaturez
									SE2->(MsUnlock())
									
								Endif
								
								SE2->(Dbskip())
							Enddo              
						Endif
						//FR - 28/06/2021 - TELETEX							
					
					Elseif lMsErroAuto

					   	MostraErro()   			//FR - 26/05/2022 - MOSTRAR O ERRO
					   	aLog := GetAutoGRLog()
						For nX := 1 To Len(aLog)
							If !"---" $ aLog[nX]
								cMsg += aLog[nX]+" ; " + CRLF
							Endif
						Next nX
						cMsg += CRLF			   	
					    cMsg += " Documento Não Foi Classificado NF: "+ cNota + CRLF

					Endif				
				
					aCabec	:=	{}
					_aItens	:=	{}
					nIte	:=	0
					nRecZBZ :=  0	

				//Else
				//	U_MyAviso("Aviso",cMsg,{"OK"},3)    mostrar só no final
				Endif	 //FR - 2o. lProssegue	
					
			Else  	//FR - lProssegue 

			    //FR - 15/05/2020  - aviso sobre a divergência caso encontrada:
				//cMsg := "Nota(s) Pendente(s) Para Classificar." + CRLF		//FR - 06/08/2020
				cMsg += "Documento Não Foi Gerado NF: "+ cNota + CRLF

				//Alterado por Rogério Lino em 15/02/2021 para tratar erro Itambé. Chamado 6209
				nPos := ASCAN(aNotas[fr,2], { |p| UPPER(alltrim(p[1])) == "DIVERG" })

				if nPos > 0

					if aNotas[fr,2,nPos,2]	
						cMsg += "-> Motivo: Divergências Valores/Impostos "+CRLF 
					Endif	

				endif	
				
				//If aNotas[fr,9]
					//cMsg += "-> Motivo: Divergências Valores/Impostos "+CRLF 
				//Endif
				//FR
									
		  	Endif  //FR lProssegue
		  
		Endif 	//fr <= Len(aNotas)
		
	Next
	
	//Ao término do processo, emite mensagem aviso
	U_MyAviso("Aviso",cMsg,{"OK"},3) 

	
	//FR 06/08/2020 - no caso de não ter sido identificada divergência (qdo o xml não tem nenhum imposto e o TES usado calcula, não está gerando divergência na classificação)
	If cUsaDvg == "S" //FR se o parâmetro de verificar divergências estiver ativado 

		if lDiverg  //Se ele lDiverg estiver como false certamente o vetor aNfDiverg estará vazio

			If !lDoubleChk

				aParams := {} 
				lQuery  := .T. 							//faz a query completa de checagem
				U_fPovoaPar(@aParams,aNFDiverg)			//povoa o array de parâmetros para o relatório		
				U_HFXMLR16(aParams,lQuery,@lDiverg)  	//chama o relatório já passando por parâmetro a NF/XML a ser verificado 
				cMsg    := ""

				If lDiverg

					cMsg := "Existe(m)  Divergência(s)  No(s)  Documento(s)  Gerado(s)."+CRLF+;
							"Por Favor, Confira a Planilha Excel Gerada Automaticamente, No Rodapé da Tela."			
					U_MyAviso("Aviso",cMsg,{"OK"},3)

				Endif

			Else

				U_MyAviso("Aviso",cMsg,{"OK"},3)	

			Endif

		endif

	Else

		U_MyAviso("Aviso",cMsg,{"OK"},3)

	Endif

Else

	U_MyAviso("Aviso",cMsg,{"OK"},3) 
		
Endif  //nOpClas = 1 
	
Return


**************************
Static Function addCabec()
**************************
Local cDocXMl   := TMPHF->NOTA
Local cSerXml   := TMPHF->SERIE
Local dDataEntr := TMPHF->DTNFE
Local cChaveXml := AllTrim( TMPHF->CHAVE )
Local cTpCte    := TMPHF->TPCTE
Local cCond     := "" 
Local cCondPE   := ""
Local lM145HCDP := ExistBlock('M145HCDP')
Local cTipoNF   := ""

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

cTipoNF := Iif(Empty( TMPHF->TPDOC ),"N",AllTrim( TMPHF->TPDOC ))

aadd(aCabec,{"F1_TIPO"   ,cTipoNF})
aadd(aCabec,{"F1_FORMUL" ,"N"})
aadd(aCabec,{"F1_DOC"    ,cDocXMl})
aadd(aCabec,{"F1_SERIE"  ,cSerXml})
aadd(aCabec,{"F1_EMISSAO",dDataEntr})
aadd(aCabec,{"F1_FORNECE",cCodFor})
aadd(aCabec,{"F1_LOJA"   ,cLojFor})
aadd(aCabec,{"F1_ESPECIE",cEspecXML})
aadd(aCabec,{"F1_CHVNFE" ,cChaveXml }) 

Return( NIL )


User Function fPovoaPar(aParams,aNFDiverg)		//povoa o array de parâmetros para o relatório		

Local xFiliXMLDe := "" 
Local xFiliXMLAte:= ""
Local xEmissaoDe := Ctod("  /  /    ")
Local xEmissaoAte:= Ctod("  /  /    ")
Local xSerieDe   := ""
Local xSerieAte  := ""
Local xDoctoDe   := ""
Local xDoctoAte  := ""
Local xCodFornDe := "" 
Local xCodFornAte:= ""
Local xLojFornDe := ""
Local xLojFornAte:= ""

xFiliXMLDe := ''
xFiliXMLAte:= 'ZZ'
xEmissaoDe := Ctod("  /  /    ")
xEmissaoAte:= Ctod("31/12/2049")
xSerieDe   := aNFDiverg[1,2]
xSerieAte  := aNFDiverg[len(aNFDiverg),2]
xDoctoDe   := aNFDiverg[1,1]
xDoctoAte  := aNFDiverg[len(aNFDiverg),1]
xCodFornDe := aNFDiverg[1,3]
xCodFornAte:= aNFDiverg[len(aNFDiverg),3]
xLojFornDe := aNFDiverg[1,4]
xLojFornAte:= aNFDiverg[len(aNFDiverg),4]

/*01*/Aadd(aParams , xFiliXMLDe  )	
/*02*/Aadd(aParams , xFiliXMLAte )
/*03*/Aadd(aParams , xEmissaoDe  )
/*04*/Aadd(aParams , xEmissaoAte )
/*05*/Aadd(aParams , xSerieDe    )
/*06*/Aadd(aParams , xSerieAte   )
/*07*/Aadd(aParams , xDoctoDe    )
/*08*/Aadd(aParams , xDoctoAte   ) 
/*09*/Aadd(aParams , ''		     )
/*10*/Aadd(aParams , ''		     )
/*11*/Aadd(aParams , ''          )
/*12*/Aadd(aParams , xCodFornDe  )
/*13*/Aadd(aParams , xCodFornAte )
/*14*/Aadd(aParams , xLojFornDe  )  
/*15*/Aadd(aParams , xLojFornAte )
/*16*/Aadd(aParams , ''       )
/*17*/Aadd(aParams , ''       )
/*18*/Aadd(aParams , ''       )
/*19*/Aadd(aParams , xEmissaoDe  )
/*20*/Aadd(aParams , xEmissaoAte )   
/*21*/Aadd(aParams , 5        ) 
/*22*/Aadd(aParams , ""       )
/*23*/Aadd(aParams , "ZZZZ"   )
/*24*/Aadd(aParams , 2        )
/*25*/Aadd(aParams , 1        ) 
/*26*/Aadd(aParams , 1        )
/*27*/Aadd(aParams , ""       )
/*28*/Aadd(aParams , ""       )
/*29*/Aadd(aParams , ""       )



Return
//==================================================================================//
//Função  : HFXML22Leg 
//Autoria : Flávia Rocha
//Data    : 17/03/2021
//Objetivo: Exibe Legenda para os XMLs modelo Nfe - Tela multiplos Nfe
//==================================================================================//
Static Function HFXML22Leg()
Local aLegenda := {}

AADD(aLegenda,{"BR_AZUL"    	,"XML Importado" 					})
AADD(aLegenda,{"BR_AMARELO" 	,"Erro ao Gerar Documento" 			})
AADD(aLegenda,{"BR_VERDE" 		,"Pré-Nota a Classificar" 			})
AADD(aLegenda,{"BR_VERMELHO"	,"Pré-Nota Classificada" 			})

BrwLegenda("Status Xml Nfe", "Legenda", aLegenda)

Return Nil
//--------------------------------------------------------------//
//Valida campo TES da tela de multiplos Cte
//Autoria: Flávia Rocha
//Data   : 28/06/2021
//--------------------------------------------------------------//
Static Function fValTES(xTES)
Local lOK := .T.

If !Empty(xTES)
	SF4->(Ordsetfocus(1))
	If SF4->(Dbseek(xFilial("SF4") + xTES))
		If FieldPos("F4_MSBLQL") > 0
			If SF4->F4_MSBLQL = "1"  //bloqueado sim
				lOK := .F.
				Alert("TES bloqueado no cadastro")
			Endif
	
			If SF4->F4_QTDZERO == "1"
				lOK := .F.
				Alert("TES Configurado Para Qtde. Zerada Não Permitido")
			Endif
		Endif
	Else
		MsgAlert("TES Não Cadastrado!")
		lOK := .F.
	Endif
Endif

Return(lOK) 

//--------------------------------------------------------------//
//Valida campo Natureza da tela de multiplos Cte
//Autoria: Flávia Rocha
//Data   : 28/06/2021
//--------------------------------------------------------------//
Static Function fValNAT(xNAT)
Local lOK := .T.

If !Empty(xNAT)
	SED->(Ordsetfocus(1))
	If SED->(Dbseek(xFilial("SED") + xNAT))
		If FieldPos("ED_MSBLQL") > 0	
			If SED->ED_MSBLQL = "1"  //bloqueado sim
				lOK := .F.
				Alert("Natureza bloqueada no cadastro")
			Endif
		Endif	
	Else
		MsgAlert("Natureza Não Cadastrada!")
		lOK := .F.
	Endif
Endif

Return(lOK)


//--------------------------------------------------------------//
//Valida campo Condição Pagto da tela de multiplos Cte
//Autoria: Flávia Rocha
//Data   : 28/06/2021
//--------------------------------------------------------------//
Static Function fValCond(xCond)
Local lOK := .T.

If !Empty(xCond)
	SE4->(Ordsetfocus(1))
	If SE4->(Dbseek(xFilial("SE4") + xCond)) 
		If FieldPos("E4_MSBLQL") > 0		
			If SE4->E4_MSBLQL = "1"  //bloqueado sim
				lOK := .F.
				Alert("Condição Pagto bloqueada no cadastro")
			Endif
		Endif	
	Else
		MsgAlert("Condição Pagto Não Cadastrada!")
		lOK := .F.
	Endif
Endif

Return(lOK) 


//--------------------------------------------------------------//
//Valida campo Item Contábil da tela de multiplos Cte
//Autoria: Flávia Rocha
//Data   : 28/06/2021
//--------------------------------------------------------------//
Static Function fValITCTB(xITCBT)
Local lOK := .T.

If !Empty(xITCBT)
	
	CTD->(Ordsetfocus(1))
	If CTD->(Dbseek(xFilial("CTD") + xITCBT))
		If FieldPos("CTD_MSBLQL") > 0	
			If CTD->CTD_MSBLQL = "1"  //bloqueado sim
				lOK := .F.
				Alert("Item Contábil bloqueado no cadastro")
			Endif
		Else
			//alert("campo bloqueio de item contábil não existe!")
		Endif	
	Else
		MsgAlert("Item Contábil Não Cadastrado!")
		lOK := .F.
	Endif
Endif

Return(lOK)

//FR - 28/06/2021 - TELETEX
//--------------------------------------------------------------------------------//
//Função  : fSX6NAT 
//Objetivo: Liga/desliga parâmetro para poder classificar o documento de entrada 
//          (porque a natureza não tá no cadastro do fornecedor - TELETEX
//--------------------------------------------------------------------------------//
Static Function fSX6NAT(xAcao)      

Local lObrigNAT

If xAcao == "2" //desliga

	lObrigNAT := GetMV("MV_NFENAT") 
	//If !lObrigNAT
		PutMv("MV_NFENAT","F") 
		lObrigNAT := GetMV("MV_NFENAT") //verifica novamente
								
		If lObrigNAT
			DBselectArea("SX6")
			SX6->(OrdSetFocus(1))	//X6_FIL + X6_VAR		//FR - 05/05/2021 														
			If SX6->(Dbseek(xFilial("SX6") + "MV_NFENAT" ))
				Reclock("SX6",.F.)
				SX6->X6_CONTEUD := "F"
				//alert("Foi alterada natureza: " + Alltrim(SX6->X6_CONTEUD) )
				SX6->(MsUnLock())
			Endif									
		Endif
	//Endif

Else 	//liga

	lObrigNAT := GetMV("MV_NFENAT") 
	//If !lObrigNAT
		PutMv("MV_NFENAT","T") 
		lObrigNAT := GetMV("MV_NFENAT") //verifica novamente
								
		If !lObrigNAT
			DBselectArea("SX6")
			SX6->(OrdSetFocus(1))	//X6_FIL + X6_VAR		//FR - 05/05/2021 														
			If SX6->(Dbseek(xFilial("SX6") + "MV_NFENAT" ))
				Reclock("SX6",.F.)
				SX6->X6_CONTEUD := "T"
				//alert("Foi alterada natureza: " + Alltrim(SX6->X6_CONTEUD) )
				SX6->(MsUnLock())
			Endif									
		Endif
	//Endif
	
Endif


Return

//--------------------------------------------------------------------------------//
//FunÃ§Ã£o  : fSA2NAT 
//Objetivo: Altera a natureza no cadastro do fornecedor visto que Ã© obrigatÃ³rio
//          para classificar o documento de entrada - TELETEX
//--------------------------------------------------------------------------------//
Static Function fSA2NAT(_cFornece,_cLojaFor,_cNaturez)    //fr - 02/07/2021

Local lGravou := .F.

DBSelectArea("SA2")
SA2->(OrdSetFocus(1))
If SA2->(Dbseek(xFilial("SA2") + _cFornece + _cLojaFor ))
    RecLock("SA2",.F.)
	SA2->A2_NATUREZ := Alltrim(_cNaturez)
    SA2->(MsUnlock())
    lGravou := .T.

Endif

Return(lGravou)
