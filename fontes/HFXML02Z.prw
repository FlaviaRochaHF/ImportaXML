#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "PRTOPDEF.CH" 


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ HFXML02Z º Autor ³ Eneovaldo Roveri Jrº Data ³  18/02/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Exclusão de XML sómente para Fornecedores                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Importa XML                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//--------------------------------------------------------------------------//
//Alterações realizadas:
//--------------------------------------------------------------------------//
//FR - 09/11/2020 - Inclusão variável para de busca por chave na ZBS
//                  depois da exclusão na ZBZ
//--------------------------------------------------------------------------//
//FR - 12/11/2020 - Antes de excluir na ZBZ, precisa armazenar a chave
//                  numa variável, que será usada na busca na ZBS
//--------------------------------------------------------------------------//
//FR - 16/08/2021 - #11100 - TRIGO ARTE - função A103CTECOL não existe
//--------------------------------------------------------------------------//
//FR - 04/11/2021 - #11460 - ADAR - ao visualizar nf via ImportaXML, mostra
//                  uma outra nota de mesmo número e fornecedor, porém emissao
//                  diferente, e a chave estava em branco no F1_CHVNFE         
//                  correção para validar com a emissão do XML x NF
//---------------------------------------------------------------------------//
//FR - 16/12/2021 - Projeto Kitchens - error log no momento da exclusão da nf
//                  Função inexistente GetDelTitImp
//---------------------------------------------------------------------------//
//FR - 06/04/2022 - ALTERAÇÃO - BRASMOLDE - erro na exclusão de Classificação NF
//                  Array da função HFA103NFis precisava de 10 posições e havia 
//                  9 (função copiada de fonte padrão Totvs, a Totvs deve ter
//                  realizado alguma atualização e por isso tivemos que adequar)
//---------------------------------------------------------------------------//
User Function HFXML02Z()

Local aArea     := GetArea()
Local aAreaZBZ	:= (xZBZ)->(GetArea())
Local aAreaZBS	:= (xZBS)->(GetArea())
Local aAreaZBT	:= (xZBT)->(GetArea())
//Local lRet      := .T.
Local lSeek     := .F.
Local cNotaSeek := ""
Local cAliasZBZ := xZBZ
Local cTipoNf   := Iif(Empty( (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC"))) ),"N",(cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC"))) )
Local cCodFor   := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR")))+(cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR")))
//Local cIndRur   := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"INDRUR"))) 
Local cStat     := ""
Local cAliasZBT := xZBT
Local cChave    := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))) //FR - 27/11/19 - para localizar o registro na ZBT
Local lExcluiu  := .F.											  //FR - 12/12/19 - indica que foi excluído o registro na ZBZ
Local lEnd      := .F.
Local oProcess
Local dEmiXML   := Ctod("  /  /    ") 	//FR - 04/11/2021 - #11460 - ADAR

Private nFormNfe:= Val(GetNewPar("XM_FORMNFE","6"))
Private lUsaPriv:= ( GetNewPar("XM_PRIVILE","N") == "S" )


If len(aUserData) >= 2 .And. ( aUserData[1][1] == "000000" .or. aScan( aUserData[2][6], "@@@@" ) > 0 )
Else
	IF .NOT. lUsaPriv
		U_MyAviso("Atenção","Apenas Administradores podem excluir",{"OK"},3)
		Return( .F. )
	EndIF
EndIf

//Atualiza status
U_UPStatXML(.F.,@lEnd,oProcess,,,cChave) 

dEmiXML := (cAliasZBZ)->&(xZBZ_+"DTNFE")   	//FR - 04/11/2021 - #11460 - ADAR
//Checar se tem Pré-nota
DbSelectArea("SF1")
lSeek := .F.
cNotaSeek :=  Iif(nFormNfe > 0,StrZero(Val((cAliasZBZ)->&(xZBZ_+"NOTA")),nFormNfe),AllTrim(Str(Val((cAliasZBZ)->&(xZBZ_+"NOTA") ))))
lSeek := DbSeek((cAliasZBZ)->&(xZBZ_+"FILIAL")+Padr(cNotaSeek,9)+(cAliasZBZ)->&(xZBZ_+"SERIE")+cCodFor+cTipoNf)
        
If !lSeek
	cNotaSeek := AllTrim(Str(Val((cAliasZBZ)->&(xZBZ_+"NOTA") )))
    lSeek := DbSeek((cAliasZBZ)->&(xZBZ_+"FILIAL")+Padr(cNotaSeek,9)+(cAliasZBZ)->&(xZBZ_+"SERIE")+cCodFor+cTipoNf)
EndIf

If !lSeek
	cNotaSeek :=  StrZero(Val((cAliasZBZ)->&(xZBZ_+"NOTA") ),6)
    lSeek := DbSeek((cAliasZBZ)->&(xZBZ_+"FILIAL")+Padr(cNotaSeek,9)+(cAliasZBZ)->&(xZBZ_+"SERIE")+cCodFor+cTipoNf)
EndIf
 
If !lSeek
	cNotaSeek :=  StrZero(Val((cAliasZBZ)->&(xZBZ_+"NOTA") ),9)
    lSeek := DbSeek((cAliasZBZ)->&(xZBZ_+"FILIAL")+Padr(cNotaSeek,9)+(cAliasZBZ)->&(xZBZ_+"SERIE")+cCodFor+cTipoNf)
EndIf

If !lSeek

	SF1->( DbSetORder(8) )  //F1_FILIAL + F1_CHNFE
	lSeek := DbSeek( (cAliasZBZ)->&(xZBZ_+"FILIAL")+Trim((cAliasZBZ)->&(xZBZ_+"CHAVE")) )
	//FR - 04/11/2021 - #11460 - ADAR
	If lSeek
		If Empty(SF1->F1_CHVNFE)  //se a chave estiver vazia, comparar com data emissão para validar se o seek é .T. 
			If dEmiXml <> SF1->F1_EMISSAO  //se a emissão for diferente, o seek é .F.
				lSeek := .F.
			Endif 
		Endif 
	Endif
	//FR - 04/11/2021 - #11460 - ADAR 
	
	SF1->( DbSetORder(1) )

EndIF

//FR - 04/11/2021 - #11460 - ADAR
If lSeek
	If dEmiXml <> SF1->F1_EMISSAO  //se a emissão for diferente, o seek é .F.
		lSeek := .F.
		RecLock(xZBZ,.F.)
		(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PRENF"), 'B' ))
		(xZBZ)->(MsUnlock()) 		
	Endif	 
Endif
//FR - 04/11/2021 - #11460 - ADAR 

DbSelectArea(xZBZ)
If lSeek
	RecLock(xZBZ,.F.)
	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PRENF"), Iif(Empty(SF1->F1_STATUS),'S','N') ))									
	(xZBZ)->(MsUnlock())
ElseiF (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF"))) $ "S|N"
	RecLock(xZBZ,.F.)
	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PRENF"), 'B' ))
	(xZBZ)->(MsUnlock())     
EndIf	

If (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF"))) == 'B' .AND. (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"PROTC"))) == Space(15)
	cStat := "XML Importado"
ElseIf (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF"))) == 'A' .AND. (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"PROTC"))) == Space(15)
	cStat := "Aviso Recbto Carga"
	lSeek := .T.
ElseIf (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF"))) == 'S' .AND. (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"PROTC"))) == Space(15)
	cStat := "Pré-Nota a Classificar"
ElseIf (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF"))) == 'N' .AND. (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"PROTC"))) == Space(15)
	cStat := "Pré-Nota Classificada"
ElseIf (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF"))) == 'F' .AND. (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"PROTC"))) == Space(15)
	cStat := "Falha de Importação"
ElseIf (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF"))) == 'Z' .AND. (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"PROTC"))) == Space(15)
	cStat := "Xml Rejeitado"
ElseIf (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF"))) == 'X' .AND. (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"PROTC"))) <> ''
	cStat := "Xml Cancelado pelo Emissor"
ElseIf (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF"))) == 'D' .AND. (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"PROTC"))) == Space(15)
	cStat := "Xml Denegado"
Else
	cStat := "Falha na Configuração"
Endif

If lSeek

	U_MyAviso("Atenção","Status do XML é "+cStat+". Desfaça a rotina para poder excluir",{"OK"},3)

ElseiF (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF"))) == 'B'

	If U_MyAviso("Pergunta","Deseja Excluir o XML "+AllTrim( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))) )+" ?",{"SIM","NÃO"},3) == 1
		
		xChave := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE")))		//FR - 29/10/2020 - precisa armazenar aqui, porque depois que excluir na ZBZ não terá esta informação para buscar na ZBS, ocorrendo erro de Reclock
		DbSelectArea(xZBZ)
		RecLock(xZBZ,.F.)
		(xZBZ)->( dbDelete() )
		(xZBZ)->(MsUnlock())
		
		lExcluiu := .T.		//FR - 12/12/19 - somente se excluir na ZBZ pode excluir na ZBT (itens)	

		DbSelectArea(xZBS)
		DbSetOrder(3)
		if DbSeek( xChave )	//FR - 29/10/2020
		
			RecLock(xZBS,.F.)
			(xZBS)->( dbDelete() )
			(xZBS)->(MsUnlock())

		endif

	EndIf

Else

	If U_MyAviso("Pergunta","Status do XML é "+cStat+". Deseja Excluir o XML "+AllTrim( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))) )+" ?",{"SIM","NÃO"},3) == 1
		
		xChave := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE")))		//FR - 09/11/2020 - precisa armazenar aqui, porque depois que excluir na ZBZ não terá esta informação para buscar na ZBS, ocorrendo erro de Reclock
		DbSelectArea(xZBZ)
		RecLock(xZBZ,.F.)
		(xZBZ)->( dbDelete() )
		(xZBZ)->(MsUnlock())

		lExcluiu := .T.

		DbSelectArea(xZBS)
		DbSetOrder(3)
        
		If DbSeek( xChave )  	//FR - 09/11/2020 - agora sim, com xChave, tem a informação para buscar na ZBS, evitando erro de Reclock
			RecLock(xZBS,.F.)
			(xZBS)->( dbDelete() )
			(xZBS)->(MsUnlock())

		endif

	EndIf

Endif

If lExcluiu

	//===============================================================//
	//FR - 27/11/19 - tratamento para exclusão dos itens da nf (ZBT)
	//===============================================================//
	
	DbSelectArea(xZBT)
	OrdSetFocus(2)
	If (cAliasZBT)->( dbSeek( cChave ) ) //FR - 28/11/19 - ZBT_CHAVE (índice sem filial)
		
		While !(cAliasZBT)->(Eof()) .and. (cAliasZBT)->(FieldGet(FieldPos(xZBT_+"CHAVE"))) == cChave
			RecLock(xZBT,.F.)
			(xZBT)->( dbDelete() )
			(xZBT)->(MsUnlock())
			(xZBT)->(Dbskip())
		Enddo
		
	Endif	
	
Endif

RestArea(aAreaZBT)
RestArea(aAreaZBS)
RestArea(aAreaZBZ)
RestArea(aArea)

Return


//Rotina para excluir Pre nota / NF
User Function HFXML02W()

Local aArea     := GetArea()
Local aAreaZBZ	:= (xZBZ)->(GetArea())
//Local lRet      := .T.
Local lSeek     := .F.
Local cNotaSeek := ""
Local cAliasZBZ := xZBZ
Local cTipoNf   := Iif(Empty( (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC"))) ),"N",(cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC"))) )
Local cCodFor   := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR")))+(cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR")))
//Local cIndRur   := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"INDRUR"))) 
Local cStat     := ""
Local aLinha    := {}
Local aCabSF1   := {}
Local aDadSD1   := {}
Local cError    := ""
Local lConfirma := .F.
Local cChave    := (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))) //FR - 27/11/19 - para localizar o registro na ZBT
Local lEnd      := .F.
Local oProcess
Local lPadrao	:= GetNewPar("XM_ESTPAD","N") == "S"
Local dEmiXML   := Ctod("  /  /    ") 	//FR - 04/11/2021 - #11460 - ADAR

Private lMsErroAuto := .F.
Private nFormNfe:= Val(GetNewPar("XM_FORMNFE","6"))
Private lUsaPriv:= ( GetNewPar("XM_PRIVILE","N") == "S" )
Private lINTEGRACAO := .F.

if (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF"))) <> 'S' .and. (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF"))) <> 'N'

	Alert('Xml nao possui documentos a excluir')
	Return( .F. )

EndIf

//Atualiza status
U_UPStatXML(.F.,@lEnd,oProcess,,,cChave)

//Checar se tem Pré-nota
DbSelectArea("SF1")
lSeek := .F.
cNotaSeek :=  Iif(nFormNfe > 0,StrZero(Val((cAliasZBZ)->&(xZBZ_+"NOTA")),nFormNfe),AllTrim(Str(Val((cAliasZBZ)->&(xZBZ_+"NOTA") ))))
lSeek := DbSeek((cAliasZBZ)->&(xZBZ_+"FILIAL")+Padr(cNotaSeek,9)+(cAliasZBZ)->&(xZBZ_+"SERIE")+cCodFor+cTipoNf)
        
dEmiXML := (cAliasZBZ)->&(xZBZ_+"DTNFE")  	//FR - 04/11/2021 - #11460 - ADAR
If !lSeek
	cNotaSeek := AllTrim(Str(Val((cAliasZBZ)->&(xZBZ_+"NOTA") )))
    lSeek := DbSeek((cAliasZBZ)->&(xZBZ_+"FILIAL")+Padr(cNotaSeek,9)+(cAliasZBZ)->&(xZBZ_+"SERIE")+cCodFor+cTipoNf)
EndIf

If !lSeek
	cNotaSeek :=  StrZero(Val((cAliasZBZ)->&(xZBZ_+"NOTA") ),6)
    lSeek := DbSeek((cAliasZBZ)->&(xZBZ_+"FILIAL")+Padr(cNotaSeek,9)+(cAliasZBZ)->&(xZBZ_+"SERIE")+cCodFor+cTipoNf)
EndIf
 
If !lSeek
	cNotaSeek :=  StrZero(Val((cAliasZBZ)->&(xZBZ_+"NOTA") ),9)
    lSeek := DbSeek((cAliasZBZ)->&(xZBZ_+"FILIAL")+Padr(cNotaSeek,9)+(cAliasZBZ)->&(xZBZ_+"SERIE")+cCodFor+cTipoNf)
EndIf

If !lSeek

	SF1->( DbSetORder(8) )  //F1_FILIAL + F1_CHNFE
	lSeek := DbSeek( (cAliasZBZ)->&(xZBZ_+"FILIAL")+Trim((cAliasZBZ)->&(xZBZ_+"CHAVE")) )
	SF1->( DbSetORder(1) )

EndIF

//FR - 04/11/2021 - #11460 - ADAR 

If lSeek
	If dEmiXml <> SF1->F1_EMISSAO  //se a emissão for diferente, o seek é .F.
		lSeek := .F.			 
	Endif 
Endif

If !lSeek
	MsgInfo( "Não Existe NF a Excluir", "Atenção" )
	Return
Endif   

//FR - 04/11/2021 - #11460 - ADAR 
If (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF"))) == 'B' .AND. (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"PROTC"))) == Space(15)
	cStat := "XML Importado"
ElseIf (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF"))) == 'A' .AND. (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"PROTC"))) == Space(15)
	cStat := "Aviso Recbto Carga"
	lSeek := .T.
ElseIf (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF"))) == 'S' .AND. (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"PROTC"))) == Space(15)
	cStat := "Pré-Nota a Classificar"
ElseIf (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF"))) == 'N' .AND. (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"PROTC"))) == Space(15)
	cStat := "Pré-Nota Classificada"
ElseIf (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF"))) == 'F' .AND. (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"PROTC"))) == Space(15)
	cStat := "Falha de Importação"
ElseIf (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF"))) == 'Z' .AND. (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"PROTC"))) == Space(15)
	cStat := "Xml Rejeitado"
ElseIf (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF"))) == 'X' .AND. (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"PROTC"))) <> ''
	cStat := "Xml Cancelado pelo Emissor"
ElseIf (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF"))) == 'D' .AND. (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"PROTC"))) == Space(15)
	cStat := "Xml Denegado"
Else
	cStat := "Falha na Configuração"
Endif

//Posiciona na SF1, monta o cabeçalho do array
aAdd(aCabSF1, {"F1_DOC",     SF1->F1_DOC,     Nil})
aAdd(aCabSF1, {"F1_SERIE",   SF1->F1_SERIE,   Nil})
aAdd(aCabSF1, {"F1_FORNECE", SF1->F1_FORNECE, Nil})
aAdd(aCabSF1, {"F1_LOJA",    SF1->F1_LOJA,    Nil})
aAdd(aCabSF1, {"F1_TIPO",    SF1->F1_TIPO,    Nil})
aAdd(aCabSF1, {"F1_ESPECIE", SF1->F1_ESPECIE, Nil})

//Posiciona na SD1
DbSelectArea("SD1")
DbSetOrder(1)
SD1->(DbGoTop())
If SD1->(DbSeek(FWxFilial('SD1') + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA))
	
	//Percorre os itens e monta o array de itens
	While ! SD1->(EoF())               .And.;
	SD1->D1_DOC     == SF1->F1_DOC     .And.;
	SD1->D1_SERIE   == SF1->F1_SERIE   .And.;
	SD1->D1_FORNECE == SF1->F1_FORNECE .And.;
	SD1->D1_LOJA    == SF1->F1_LOJA 
			
		aLinha := {}
		aAdd(aLinha,  {"D1_DOC",     SD1->D1_DOC,     Nil})
		aAdd(aLinha,  {"D1_SERIE",   SD1->D1_SERIE,   Nil})
		aAdd(aLinha,  {"D1_FORNECE", SD1->D1_FORNECE, Nil})
		aAdd(aLinha,  {"D1_LOJA",    SD1->D1_LOJA,    Nil})
		aAdd(aLinha,  {"D1_TIPO",    SD1->D1_TIPO,    Nil})
		aAdd(aLinha,  {"D1_ITEM",    SD1->D1_ITEM,    Nil})
		aAdd(aLinha,  {"D1_COD",     SD1->D1_COD,     Nil})
		aAdd(aLinha,  {"D1_UM",      SD1->D1_UM,      Nil})
        aAdd(aLinha,  {"D1_LOCAL",   SD1->D1_LOCAL,   Nil})
        aAdd(aLinha,  {"D1_QUANT",   SD1->D1_QUANT,   Nil})
    	aAdd(aLinha,  {"D1_VUNIT",   SD1->D1_VUNIT,   Nil})
        aAdd(aLinha,  {"D1_TOTAL",   SD1->D1_TOTAL,   Nil})
        aAdd(aLinha,  {"D1_TES",     SD1->D1_TES,     Nil})
		aAdd(aDadSD1, aClone(aLinha))
			
		SD1->(DbSkip())

	EndDo
		
	//Ordena pelo número do item
	aSort(aDadSD1, , , { |x, y| x[6] < y[6] })

endif

Do Case

Case (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF"))) == 'S' .AND. (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"PROTC"))) == Space(15)
	
	if Msgyesno("Tem certeza que deseja excluir Pré Nota ? ")

		//Começa o controle de transação
		Begin Transaction

		//Se for o mesmo, verifica se o status está em branco (é uma pré nota)
		If Empty(SF1->F1_STATUS)
			
			//Chama o Execauto de exclusão da pré nota
			lMsErroAuto := .F.
			MSExecAuto({|x, y, z, a, b| MATA140(x, y, z, a, b)}, aCabSF1, aDadSD1, 5, .F., 1)
				
			//Se houve erro, mostra o erro, disarma a transação e atualiza a variável
			If lMsErroAuto

				MostraErro()
				DisarmTransaction()
				lErro := .T.
				cError += "- Documento '" + cNotaSeek + "', não foi possível excluir a Pré Nota de Entrada!" + CRLF

			else

				DbSelectArea("SF1")
				lConfirma := DbSeek((cAliasZBZ)->&(xZBZ_+"FILIAL")+Padr(cNotaSeek,9)+(cAliasZBZ)->&(xZBZ_+"SERIE")+cCodFor+cTipoNf)

				if !lConfirma
				
					DbSelectArea(xZBZ)
					If lSeek

						RecLock(xZBZ,.F.)
						(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PRENF"), 'B' ))
						MsUnlock()     

						MsgInfo( "Pré nota excluída com sucesso", "Atenção" )

					EndIf	

				endif

			EndIf

		EndIf

		End Transaction

	endif

Case (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF"))) == 'N' .AND. (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"PROTC"))) == Space(15)

	//if Msgyesno("Deseja excluir a Classificação ? " + CRLF +; 
	//"Se optar por Não excluir a Classificação, aparecerá uma tela perguntando se deseja excluir o Documento de Entrada e Pré Nota") 
	//FR - 03/03/2022 - PETRA - ERRO AO EXCLUIR CLASSIFICAÇÃO - CHAMADO 12108
	If Msgyesno("Deseja excluir APENAS a Classificação ? "  + CRLF + CRLF+; 
		"Se optar por SIM, será excluída Apenas a Classificação e ficará a Pré-Nota ativa,"+ CRLF+ CRLF+;
		"Se optar por NÃO, aparecerá uma tela perguntando se deseja excluir ambos: Classificação e Pré-Nota") 

		//Começa o controle de transação
		Begin Transaction

		//Caso haja Status, é Documento de Entrada
		If ! Empty(SF1->F1_STATUS)

			//Chama Funcao Padrao Estorno Classificacao ...   
   			If lPadrao
				A103NFiscal("SF1",SF1->(RecNo()),5,,.T.) 
			Else				
				HFA103NFis("SF1",SF1->(RecNo()),2,,.T.) //A103NFiscal("SF1",SF1->(Recno()),5,.F.,.T.) //Function A103NFiscal(cAlias,nReg,nOpcx,lWhenGet,lEstNfClass)			 								
			EndIf

			DbSelectArea("SF1")
			DbSeek((cAliasZBZ)->&(xZBZ_+"FILIAL")+Padr(cNotaSeek,9)+(cAliasZBZ)->&(xZBZ_+"SERIE")+cCodFor+cTipoNf)

			if SF1->F1_STATUS != "A"
			
				DbSelectArea(xZBZ)
				If lSeek

					RecLock(xZBZ,.F.)
					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PRENF"), 'S' ))
					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"ORIGEM"),' ' )) // Erick 14/02/2023 -> Caso seja excluído, apaga o conteúdo do campo.
					MsUnlock()     

					MsgInfo( "Classificação excluída com sucesso", "Atenção" )

				EndIf	

			endif

		endif

		End Transaction

	else

		if Msgyesno("Tem certeza que deseja excluir Documento de Entrada e Pré Nota ? ")

			//Começa o controle de transação
			Begin Transaction

			//Caso haja Status, é Documento de Entrada
			If ! Empty(SF1->F1_STATUS)
				
				//Chama o Execauto de exclusão de documento de entrada
				lMsErroAuto := .F.
				MSExecAuto({|x, y, z, w| MATA103(x, y, z, w)}, aCabSF1, aDadSD1, 5, .F.)
					
				//Se houve erro, mostra o erro, disarma a transação e atualiza a variável
				If lMsErroAuto

					MostraErro()
					DisarmTransaction()
					lErro := .T.
					cError += "- Documento '" + cNotaSeek + "', não foi possível excluir a Pré Nota de Entrada!" + CRLF

				else

					DbSelectArea("SF1")
					lConfirma := DbSeek((cAliasZBZ)->&(xZBZ_+"FILIAL")+Padr(cNotaSeek,9)+(cAliasZBZ)->&(xZBZ_+"SERIE")+cCodFor+cTipoNf)

					if !lConfirma
					
						DbSelectArea(xZBZ)
						If lSeek

							RecLock(xZBZ,.F.)
							(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PRENF"), 'B' ))
							(xZBZ)->(FieldPut(FieldPos(xZBZ_+"ORIGEM"),' ' )) // Erick 14/02/2023 -> Caso seja excluído, apaga o conteúdo do campo.
							MsUnlock()     

							MsgInfo( "Documento de entrada excluído com sucesso", "Atenção" )

						EndIf	

					endif

				EndIf

			EndIf

			End Transaction

		endif

	endif

endCase

RestArea(aAreaZBZ)
RestArea(aArea)

Return()



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³HFA103NFis³ Autor ³ Edson Maricate       ³ Data ³24.01.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Incl/Alter/Excl/Visu.de NF Entrada             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HFA103NFis(ExpC1,ExpN1,ExpN2,ExpL1,ExpL2)	              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±³          ³ ExpL1 = lWhenGet (default = .F.)                           ³±±
±±³          ³ ExpL2 = Estorno de NF Classificada (chamada MATA140)       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA103                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function HFA103NFis(cAlias,nReg,nOpcx,lWhenGet,lEstNfClass)

Local lContinua		:= .T.
Local l103Inclui	:= .F.
Local l103Exclui	:= .F.
Local lMT103NFE		:= Existblock("MT103NFE")
Local lTMT103NFE	:= ExistTemplate("MT103NFE")
Local lIntACD		:= SuperGetMV("MV_INTACD",.F.,"0") == "1" 
Local lClaNfCfDv 	:= .F.
Local lDigita		:= .F.
Local lAglutina		:= .F.
Local lQuery		:= .F.
Local lContabiliza  := .F.
Local lGeraLanc		:= .F.
Local lPyme			:= If( Type( "__lPyme" ) <> "U", __lPyme, .F. )
Local lClassOrd		:= ( SuperGetMV( "MV_CLASORD" ) == "1" )  //Indica se na classificacao do documento de entrada os itens devem ser ordenados por ITEM+COD.PRODUTO
Local lNfeOrd		:= ( GetNewPar( "MV_NFEORD" , "2" ) == "1" ) // Indica se na visualizacao do documento de entrada os itens devem ser ordenados por ITEM+COD.PRODUTO
Local lExcViaEIC	:= .F.
Local lExcViaTMS	:= .F.
Local lProcGet		:= .T.
Local lTxNeg        := .F.
Local nTaxaMoeda	:= 0
Local lConsMedic    := .F.
Local lRatLiq       := .T.
Local lRatImp       := .F.
Local lMvAtuComp    := SuperGetMV("MV_ATUCOMP",,.F.)
Local lRet := .T.
Local aArea2 := {}
//Local lHasLocEquip  := FindFunction("At800AtNFEnt") .And. AliasInDic("TEW")
Local aMT103BCLA	:= {}
Local lMT103BCLA	:= ExistBlock("MT103BCLA")
Local lRetBCla		:= .F.
Local lTColab       := .F.
Local lSubSerie     := cPaisLoc == "BRA" .And. SF1->(ColumnPos("F1_SUBSERI")) > 0 .And. SuperGetMv("MV_SUBSERI",.F.,.F.)
Local lDHQInDic     := AliasInDic("DHQ") .And. SF4->(ColumnPos("F4_EFUTUR") > 0)
Local lMt103Com     := FindFunction("A103FutVld")
Local lTrbGen       := IIf(FindFunction("ChkTrbGen"),ChkTrbGen("SD1", "D1_IDTRIB"),.F.) // Verificacao se pode ou nao utilizar tributos genericos

Local nTmpN			:= 0
Local nRecSF1		:= 0
Local nOpc			:= 0
Local nItemSDE		:= 0
Local nTpRodape		:= 1
Local nX			:= 0
Local nY			:= 0
Local nCounterSD1	:= 0
Local nMaxCodes		:= SetMaxCodes( 9999 )
Local nIndexSE2		:= 0
Local nScanBsPis	:= 0
Local nScanVlPis	:= 0
Local nScanAlPis	:= 0
Local nScanBsCof	:= 0
Local nScanVlCof	:= 0
Local nScanAlCof	:= 0
Local nLoop			:= 0
Local nTrbGen       := 0
Local nColsSE2      := 0

Local lPCCBaixa		:= SuperGetMv("MV_BX10925",.T.,"2") == "1"

Local cModRetPIS	:= GetNewPar( "MV_RT10925", "1" )

Local aStruSF3		:= {}
Local aStruSDE		:= {}
Local aStruSE2		:= {}
Local aStruSD1		:= {}
Local aRecSD1		:= {}
Local aRecSE1		:= {}
Local aRecSE2		:= {}
Local aRecSF3		:= {}
Local aRecSC5		:= {}
Local aRecSDE		:= {}
Local aHeadSDE		:= {}
Local aHeadSE2		:= {}
Local aColsSE2		:= {}
Local aHeadSEV		:= {}
Local aColsSEV		:= {}
Local aColsSDE		:= {}
Local aHistor		:= {}
//Local aObjects		:= {}
Local aInfo			:= {}
Local aPosGet		:= {}
Local aPosObj		:= {}
Local aPages		:= {"HEADER"}
Local aInfForn		:= {"","",CTOD("  /  /  "),CTOD("  /  /  "),"","","",""}
//Local a103Var		:= {0,0,0,0,0,0,0,0,0}
Local a103Var		:= {0,0,0,0,0,0,0,0,0,0}  //precisa de 10 posições  //FR - 06/04/2022 - ALTERAÇÃO - BRASMOLDE - erro na exclusão de Classificação NF
Local aButControl	:= {}
Local aTitles		:= {} // foi alterado por causa do SIGAGSP.
Local aSizeAut		:= {}
Local aButVisual	:= {}
Local aButtons		:= {}
Local aMemUser      := {}
Local aRateio		:= {0,0,0}
Local aFldCBAtu	    // foi alterado por causa do SIGAGSP.
Local aRecClasSD1	:= {}
Local aRelImp		:= MaFisRelImp("MT100",{ "SD1" })
//Local aFil10925		:= {}
Local aMultas       := {}
Local aAreaSD1	:= {}
//Local aAreaColab    := {}
Local aColTrbGen    := {}
Local aParcTrGen    := {}

Local cTituloDlg	:= IIf(Type("cCadastro") == "C" .And. Len(cCadastro) > 0,cCadastro,OemToAnsi("Documento de Entrada")) //"Documento de Entrada"
Local cPrefixo		:= IIf(Empty(SF1->F1_PREFIXO),&(SuperGetMV("MV_2DUPREF")),SF1->F1_PREFIXO)
Local cHistor		:= ""
Local cItem			:= ""
Local cItemSDE		:= ""
Local cQuery		:= ""
Local cAliasSF3		:= "SF3"
Local cAliasSDE		:= "SDE"
Local cAliasSE2		:= "SE2"
Local cAliasSD1		:= "SD1"
Local cAliasSB1		:= "SB1"
Local cNumNfGFE		:= ""
Local nHoras 		:= 0
Local nSpedExc 		:= GetNewPar("MV_SPEDEXC",24)
Local dDtDigit 		:= dDataBase
Local dCtbValiDt    := Ctod("")

Local cVarFoco		:= "     "
//Local cIndex		:= ""
//Local cCond			:= ""
Local cNatureza		:= ""

Local cCpBasePIS	:= ""
Local cCpValPIS		:= ""
Local cCpAlqPIS		:= ""
Local cCpBaseCOF	:= ""
Local cCpValCOF		:= ""
Local cCpAlqCOF		:= ""

Local nPosRec		:= 0
Local nTamX3A2CD    := TamSX3("A2_COD")[1]
Local nTamX3A2LJ    := TamSX3("A2_LOJA")[1]
Local nCombo		:= 2
//Local nItValido		:= 0
Local oDlg
Local oHistor
Local oLivro
Local oCombo
Local oCodRet

Local bKeyF12		:= Nil
Local bPMSDlgNF		:= {||PmsDlgNF(nOpcx,cNFiscal,Substr(cSerie,1,3),cA100For,cLoja,cTipo)} // Chamada da Dialog de Gerenc. Projetos
Local bCabOk		:= {|| .T.}
Local bIPRefresh	:= {|| MaFisToCols(aHeader,aCols,,"MT100"),Eval(bRefresh),Eval(bGdRefresh), A103PosFld()}	// Carrega os valores da Funcao fiscal e executa o Refresh
Local bWhileSD1		:= { || .T. }
Local lMT103NAT		:= Existblock("MT103NAT")
//Local nTitles1		:= 1
//Local nTitles2		:= 2
//Local nTitles3		:= 3
//Local nTitles4		:= 4
//Local nTitles5		:= 5
//Local nTitles6		:= 6
//Local nTitles7		:= 7
Local lGspInUseM	:= If(Type('lGspInUse')=='L', lGspInUse, .F.)
//Local lLojaAtu		:= ( GetNewPar( "MV_LJ10925", "1" ) == "1" )
Local aAUTOISS		:= &(GetNewPar("MV_AUTOISS",'{"","","",""}'))
Local aNFEletr		:= {}
Local aNoFields     := {}
Local cDescri		:= Space(Len(SE2->E2_NOMFOR))
Local nNFe			:= 0
Local nConfNF       := 0
Local cDelSDE 	    := ""
Local aCodR	        :=	{}
Local cRecIss	    :=	"1"
Local oRecIss
Local nLancAp		:= 0
Local nInfDiv       := 0
Local nInfAdic      := 0
Local nDivImp		:= 0
Local nPosGetLoja   := IIF(nTamX3A2CD< 10,(2.5*nTamX3A2CD)+(110),(2.8*nTamX3A2CD)+(100))
Local aHeadCDA		:= {}
Local aColsCDA		:= {}
Local aHeadCDV		:= {}
Local aColsCDV		:= {}
Local lRatAFN       := .T.
Local aCtbInf       := {} //Array contendo os dados para contabilizacao online:
					    //		[1] - Arquivo (cArquivo)
						//		[2] - Handle (nHdlPrv)
						//		[3] - Lote (cLote)
						//      [4] - Habilita Digitacao (lDigita)
						//      [5] - Habilita Aglutinacao (lAglutina)
						//      [6] - Controle Portugal (aCtbDia)
						//		[7,x] - Campos flags atualizados na CA100INCL
						//		[7,x,1] - Descritivo com o campo a ser atualizado (FLAG)
						//		[7,x,2] - Conteudo a ser gravado na flag
						//		[7,x,3] - Alias a ser atualizado
						//		[7,x,4] - Recno do registro a ser atualizado
Local aMT103CTB  := {}

Local oTempTable	:= NIL
Local lExcCmpAdt := .T.
Local cStatCon   := ""
Local nQtdConf   := 0
Local oList
Local aListBox   := {}
Local oEnable    := LoadBitmap( GetResources(), "ENABLE" )
Local oDisable   := LoadBitmap( GetResources(), "DISABLE" )
Local lCompAdt	 := .F.
Local aPedAdt	 := {}
Local aRecGerSE2 := {}
Local nPosPC 		:= 0
Local nPosItPC   	:= 0
Local nPosItNF	:= 0
Local nPosRat		:= 0
//Local nPosLeg	:= 0

//Verifica se a funcionalidade Lista de Presente esta ativa e aplicada
//Local lUsaLstPre := SuperGetMV("MV_LJLSPRE",,.F.) .And. LjUpd78Ok()
Local a			 := 0
Local aDigEnd	   	:= {}
Local lDistMov		:= SuperGetMV("MV_DISTMOV",.F.,.F.)

//Variaveis utilizadas na integracao NG
Local nG 		:= 0
Local nPORDEM	:= 0

//Variaveis de Posicoes no Browse
//Local nNumCol
Local lPrjCni := If(FindFunction("ValidaCNI"),ValidaCNI(),.F.)

//Chamado SDFPWW
//Local cAglutFil := SuperGetMV("MV_PCCAGFL",,"1")
//Local aAreaSM0  := {}
//Local cCGCSM0   := ""
//Local cEmpAtu   := ""

//Tratamendo de ISS por municipio.
Local nInfISS := 0
Local lISSxMun := SuperGetMV("MV_ISSXMUN",.F.,.F.)
Local aInfISS	:= Iif(lISSxMun,{{CriaVar("CC2_CODMUN",.F.),CriaVar("CC2_MUN"),CriaVar("CC2_EST"),CriaVar("CC2_MDEDMA"),CriaVar("CC2_MDEDSR"),;
					CriaVar("CC2_PERMAT"),CriaVar("CC2_PERSER")},;
					{CriaVar("D1_TOTAL"),CriaVar("D1_ABATISS"),CriaVar("D1_ABATMAT"),CriaVar("D1_BASEISS"),CriaVar("D1_VALISS")},;
           	        {CriaVar("D1_TOTAL"),CriaVar("D1_ABATINS"),CriaVar("D1_ABATINS"),CriaVar("D1_BASEINS"),CriaVar("D1_VALINS")}},{})
Local aObjetos := aClone(aInfISS)

Local lIntegGFE := SuperGetMV("MV_INTGFE",.F.,.F.) .And. SuperGetMV("MV_INTGFE2",.F.,"2") $ "1" .And. SuperGetMv("MV_GFEI10",.F.,"2") == "1"
//Verifica se a rotina foi chamada a partir da conferencia de servicos II - Financeiro
Local lFina686 := IsInCallStack("FINA686")

Local oSize 	:= nil
Local aRotAux 	:= {} //MenuDef()
Local lCTBC661 	:= IsInCallStack("CTBC661")
Local aRotBkp	:= {}

// Conferencia fisica do SIGAACD
//Local lCpConfFis := SA2->(FieldPos('A2_CONFFIS')) > 0
Local cMVTPCONFF := SuperGetMV("MV_TPCONFF",.F.,"1")
Local cMVCONFFIS := SuperGetMV("MV_CONFFIS",.F.,"N")

// Informacoes Adicionais do Documento
Local oDescMun
Local cDescMun := ""

Local aRetInt := {}
//Local aRetAux	:= {}
Local cMsgRet	:= ""
Local cInfISS 		:= ""
Local lWmsCRD  := SuperGetMV("MV_WMSCRD",.F.,.F.)
Local nFR3_TIPO := TAMSX3("FR3_TIPO")[1]
//Local aArea
//Local aAreaCE1
//Local lVcAntIss
Local aImpItem	:= {}
Local lIntGC	 := IIf((SuperGetMV("MV_VEICULO",,"N")) == "S",.T.,.F.)
Local lDclNew 	:= SuperGetMv("MV_DCLNEW",.F.,.F.)

Local aTitImp    := {}
Local nRecSE2    := 0
Local aAreaD1	 := {}
Local nPosNFOri  := 0
Local nPosSerOri := 0
Local nPosForDev := 0
Local nPosLojDev := 0
Local lDevol	 := .F.
Local lUsaGCT    := A103GCDisp()

Local lNgMnTes		:= SuperGetMV("MV_NGMNTES") == "S"
Local lNgMntCm		:= SuperGetMV("MV_NGMNTCM",.F.,"N") == "S"

If ( Type("cFornIss") == "U" )
	cFornIss := Space(nTamX3A2CD)
EndIf
If ( Type("cLojaIss") == "U" )
	cLojaIss := Space(nTamX3A2LJ)
EndIf
If ( Type("dVencISS") == "U" )
	dVencISS := CtoD("")
EndIf
If ( Type("aRateioCC") == "U" )
	PRIVATE aRateioCC := {}
EndIf

// foi alterado por causa do SIGAGSP.
aAdd(aTitles, OemToAnsi("Totais")) //"Totais"
aAdd(aTitles, OemToAnsi("Inf. Fornecedor/Cliente")) //"Inf. Fornecedor/Cliente"
aAdd(aTitles, OemToAnsi("Descontos/Frete/Despesas")) //"Descontos/Frete/Despesas"
aAdd(aTitles, OemToAnsi("Livros Fiscais")) //"Livros Fiscais"
aAdd(aTitles, OemToAnsi("Impostos")) //"Impostos"
aAdd(aTitles, OemToAnsi("Duplicatas")) //"Duplicatas"

aFldCBAtu	:= Array(Len(aTitles)) // foi alterado por causa do SIGAGSP.

PRIVATE oLancApICMS
PRIVATE oLancCDV
PRIVATE oFisRod
PRIVATE cDirf		:= Space(Len(SE2->E2_DIRF))
PRIVATE cCodRet		:= Space(Len(SE2->E2_CODRET))
PRIVATE l103Visual	:= .F.
PRIVATE lReajuste	:= .F.
PRIVATE lAmarra		:= .F.
PRIVATE lConsLoja	:= .F.
PRIVATE lPrecoDes	:= .F.
PRIVATE lVldAfter	:= .F.
PRIVATE lMt100Tok	:= .T.
PRIVATE cTipo		:= ""
PRIVATE c103Tp	:= ""
PRIVATE cTpCompl	:= ""
PRIVATE cFormul		:= ""
PRIVATE cNFiscal	:= ""
PRIVATE cSerie		:= ""
PRIVATE cSubSerie	:= ""
PRIVATE cA100For	:= ""
PRIVATE cLoja		:= ""
PRIVATE cEspecie	:= ""
PRIVATE cCondicao	:= ""
PRIVATE cForAntNFE	:= ""
PRIVATE dDEmissao	:= dDataBase
PRIVATE n			:= 1
PRIVATE nMoedaCor	:= 1
PRIVATE nTaxa       := 0
PRIVATE nValFat		:= 0
PRIVATE aCols		:= {}
PRIVATE aColsNF		:= {}  //Variavel utilizada pela Funcao NfeRFldFin - MATA103x para alimentar a variavel aColsTit
PRIVATE aHeader		:= {}
PRIVATE aRatVei		:= {}
PRIVATE aRatFro		:= {}
PRIVATE aArraySDG	:= {}
PRIVATE aRatAFN		:= {}	//Variavel utilizada pela Funcao PMSDLGRQ - Gerenc. Projetos
PRIVATE aHdrAFN		:= {}	//Variavel utilizada pela Funcao PMSDLGRQ - Gerenc. Projetos (Cabecalho da aRatAFN)
PRIVATE aMemoSDE    := {}
PRIVATE aOPBenef    := {}
PRIVATE aHeadDHP    := {}
PRIVATE aColsDHP    := {}
PRIVATE xUserData	:= NIL
PRIVATE oTpFrete
PRIVATE oModelDCL	:= Nil

PRIVATE bRefresh	:= {|nX| NfeFldChg(nX,nY,,aFldCBAtu)}
PRIVATE bGDRefresh	:= {|| IIf(oGetDados<>Nil,(oGetDados:oBrowse:Refresh()),.F.) }		// Efetua o Refresh da GetDados
PRIVATE oGetDados
PRIVATE oFolder
PRIVATE oFoco103
PRIVATE l240		:=.F.
PRIVATE l241		:=.F.
PRIVATE aBaseDup
PRIVATE aBackColsSDE:={}
PRIVATE l103TolRec  := .F.
PRIVATE l103Class   := .F.
PRIVATE lMudouNum   := .F.
PRIVATE lNfMedic    := .F.
PRIVATE aColsD1		:=	aCols
PRIVATE aHeadD1		:=	aHeader
PRIVATE cCodDiario  := ""
PRIVATE cAliasTPZ   := ""
PRIVATE cUfOrig		:= ""
PRIVATE bIRRefresh	:= {|nX| NfeFldChg(nX,oFolder:nOption,oFolder,aFldCBAtu)}
PRIVATE lContDCL   := .T.

//Variáveis para tratamento para aba de Duplicatas
PRIVATE dEmisOld	:= ""
PRIVATE cCA100ForOld:= ""
PRIVATE cCondicaoOld:= ""
PRIVATE lMoedTit	:= (SuperGetMv("MV_MOEDTIT",.F.,"N") == "S")
PRIVATE lBlqTxNeg	:= .T.
PRIVATE dNewVenc	:= CTOD('  /  /  ')

//Tratamento PLS
PRIVATE lUsouLtPLS	:= .F.
PRIVATE cCodRDA		:= ""

PRIVATE aInfAdic	:= {}

Private oListDvIm
Private nDivCount := 0
Private oDivCount
Private lDivImp		:= .F.
Private oFisTrbGen

DEFAULT lEstNfClass	:= .F.
&("M->F1_CHVNFE") := ""

l103GAuto := If(Type("l103GAuto") == "U" ,.T.,l103GAuto)

aInfAdic := Array(18)  //FR - 18/10/2022 - AJUSTE ERROR LOG NA EXCLUSÃO NF , REPORTADO PELA PAPIRUS
//-- Inserida verificação para ver o aRotina, pois quando a função é chamada de outra Rotina não esta Ok.
//-- Esta validação não deve ser retirada, pois e usada quando a chamada vem de outra rotina
If lCTBC661	.AND. ValType(aRotAux) == "A"
	aRotBkp := aRotina

	If aRotina <> aRotAux
		aRotina := {}
	 	aRotina := aRotAux
	EndIf
EndIf 

//FR - 03/03/2022 - PETRA - CHAMADO: 12108 - ERRO AO EXCLUIR CLASSIFICAÇÃO
//if ValType(aRotina[nOpcx][1]) <> "U"
//	If "Excluir" $ aRotina[nOpcx][1]	// "Excluir"
		dbSelectArea("SD1")
		dbSetOrder(1)
		dbSeek(xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA )
	//EndIf
//EndIf

dDtdigit 	:= IIf(!Empty(SF1->F1_DTDIGIT),SF1->F1_DTDIGIT,SF1->F1_EMISSAO)

If ( Type("aAutoAFN") == "U" )
	PRIVATE aAutoAFN := {}
EndIf

If ( Type("aRateioCC") == "U" )
	PRIVATE aRateioCC := {}
EndIf

If ( Type("aAutoImp") == "U" )
	PRIVATE aAutoImp := {}
EndIf

If ( Type("aNFEDanfe") == "U" )
	PRIVATE aNFEDanfe := {}
EndIf

If ( Type("aDanfeComp") == "U" )
	Private aDanfeComp:= {}
Else
	aDanfeComp:= {}
EndIf

If ( Type("cCodRSef") == "U" )
	PRIVATE cCodRSef := ""
EndIf

If ( Type("aAposEsp") == "U" )
	PRIVATE aAposEsp := {}
EndIf

If ( Type("aCompFutur") == "U" )
	PRIVATE aCompFutur := {}
EndIf

If nOpcX == 6

	//Nota gerada pela conferencia de servicos do SIGAFIN
	If SF1->F1_ORIGLAN == 'CS' .and. !lFina686
		lRet := .F.
		Help(" ",1,'NOPERMISS',,'Este documento foi gerado pela conferência de serviços do módulo Financeiro.'+CRLF+;	//'Este documento foi gerado pela conferência de serviços do módulo Financeiro.'
							    'Portanto, o cancelamento deste documento, somente será possível através da rotina que o originou.',1,0)	//'Portanto, o cancelamento deste documento, somente será possível através da rotina que o originou.'
	Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o usuario tem permissao de delecao. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aArea2 := GetArea()
		SD1->(dbSeek(xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE))
		While !SD1->(Eof()) .And. lRet .And. SD1->D1_DOC == SF1->F1_DOC .And. SD1->D1_SERIE ==  SF1->F1_SERIE
			If IsInCallStack("MATA103") //Documento de Entrada
				lRet := MaAvalPerm(1,{SD1->D1_COD,"MTA103",5})
			ElseIf IsInCallStack("MATA102N") // Remito de Entrada
				lRet := MaAvalPerm(1,{SD1->D1_COD,"MT102N",5})
			ElseIf IsInCallStack("MATA101N") // Factura de Entrada
				lRet := MaAvalPerm(1,{SD1->D1_COD,"MT101N",5})
			EndIf
			SD1->(dbSkip())
		End
		RestArea(aArea2)
		If !lRet
			Help(,,1,'SEMPERM')
		EndIf
	Endif

	If Alltrim(SF1->F1_ORIGEM) == "MSGEAI" .And. !l103Auto
		MsgAlert("NF gerada por outro sistema, somente podera ser excluida pelo sistema que a originou") //"NF gerada por outro sistema, somente podera ser excluida pelo sistema que a originou"
		lRet := .F.
		Return lRet
	Endif
EndIf

If lRet
	//Exec.Block p/Executar Ponto de Entrada de Multiplas Naturezas - MT103MNT
	bBlockSev1	:= {|nX| A103MNat(@aHeadSev, @aColsSev)}
	bBlockSev2  := {|nX| NfeTOkSEV(@aHeadSev, @aColsSev,.F.)}

	If lNgMnTes .or. lNgMntCm
		//Arquivo temporario utilizado na integracao com SIGAMNT
		aCAMPTPZ := {}
		AADD(aCAMPTPZ,{"TPZ_ITEM"   ,"C",04,0}) //Numero do item
		AADD(aCAMPTPZ,{"TPZ_CODIGO" ,"C",15,0}) //Codigo do produto
		AADD(aCAMPTPZ,{"TPZ_LOCGAR" ,"C",06,0}) //Localizacao
		AADD(aCAMPTPZ,{"TPZ_ORDEM"  ,"C",06,0}) //Ordem de servico
		AADD(aCAMPTPZ,{"TPZ_QTDGAR" ,"N",09,0}) //Quantidade de garantia
		AADD(aCAMPTPZ,{"TPZ_UNIGAR" ,"C",01,0}) //Unidade de garantia
		AADD(aCAMPTPZ,{"TPZ_CONGAR" ,"C",01,0}) //Tipo do contador da garantia
		AADD(aCAMPTPZ,{"TPZ_QTDCON" ,"N",09,0}) //Quantidade do contador da garantia

		cAliasTPZ := GetNextAlias()
		oTempTable:= FWTemporaryTable():New( cAliasTPZ )
		oTempTable:SetFields( aCAMPTPZ )
		oTempTable:AddIndex("indice1", {"TPZ_ITEM"} )
		oTempTable:Create()
	EndIf

	cDelSDE := If(lEstNfClass,GetNewPar("MV_DELRATC","1"),"1")

	lDivImp := !l103Inclui .And. ( lTColab := COLConVinc(SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA) > 0 ) .And. SuperGetMV("MV_NFDVIMP",.F.,.F.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Preenche automaticamente o fornecedor/loja ISS atraves do parâmetro                   ³
	//³MV_AUTOISS = {Fornecedor,Loja,Dirf,CodRet}                                            ³
	//³Apenas efetua o processamento se todas as posicoes do parametro estiverem preenchidas ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aAUTOISS <> NIL .And. Len(aAUTOISS) == 4	//Sempre vai entrar, o default eh todas as posicoes do array vazio, porem quando for
		//	vazio temos de manter a qtd de caracteres definidas na declaracao LOCAL das variaveis cFornIss,
		//	cLojaIss, cDirf e cCodRet, senao nao eh permitido a digitacao no rodape da NF devido ao tamanho
		//	ser ZERO (declaracao LOCAL do aAUTOISS).
		cFornIss := Iif (Empty (aAUTOISS[01]), cFornIss, PadR(aAUTOISS[01], nTamX3A2CD))
		cLojaIss := Iif (Empty (aAUTOISS[02]), cLojaIss, PadR(aAUTOISS[02], nTamX3A2LJ))
		cDirf		:= Iif (Empty (aAUTOISS[03]), cDirf, aAUTOISS[03])
		cCodRet		:= Iif (Empty (aAUTOISS[04]), cCodRet, aAUTOISS[04])

		If !Empty( cCodRet )
			If aScan( aCodR, {|aX| aX[4]=="IRR"})==0
				aAdd( aCodR, {99, cCodRet, 1, "IRR"} )
			Else
				aCodR[aScan( aCodR, {|aX| aX[4]=="IRR"})][2]	:=	cCodRet
			EndIf
		EndIf

		// Somente ira preencher se o cadastro no SA2 existir
		If !Empty(cFornIss) .And. !Empty(cLojaIss) .And. SA2->(MsSeek(xFilial("SA2")+cFornIss+cLojaIss))
			cFornIss := SA2->A2_COD
			cLojaIss := SA2->A2_LOJA
		Else
			cFornIss := Space(nTamX3A2CD)
			cLojaIss := Space(nTamX3A2LJ)
		Endif

	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o tratamento eh pela baixa e disabilita a altera ³
	//³ cao do tipo de retencao                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lPccBaixa
		cModRetPis	:= "3"
	Endif

	aBackSDE	:= If(Type('aBackSDE')=='U',{},aBackSDE)
	aAdd(aButtons, {'PEDIDO',{||Iif(Eval(bCabOk),A103ForF4( NIL, NIL, lNfMedic, lConsMedic, aHeadSDE, @aColsSDE,aHeadSEV, aColsSEV, @lTxNeg, @nTaxaMoeda),Help('   ',1,'A103CAB')),aBackColsSDE:=ACLONE(aColsSDE)},OemToAnsi("Selecionar Pedido de Compra"+" - <F5> "),"Selecionar Pedido de Compra"} ) //"Selecionar Pedido de Compra"
	aAdd(aButtons, {'pedido',{||Iif(Eval(bCabOk),A103ItemPC( NIL,NIL,NIL,lNfMedic,lConsMedic,aHeadSDE,@aColsSDE, ,@lTxNeg, @nTaxaMoeda),Help('   ',1,'A103CAB')),aBackColsSDE:=ACLONE(aColsSDE)},OemToAnsi("Selecionar Pedido de Compra ( por item )"+" - <F6> "),"Selecionar Pedido de Compra ( por item )"} ) //"Selecionar Pedido de Compra ( por item )"
	If !lGspInUseM
		aAdd(aButtons, {'RECALC',{||A103NFORI()},OemToAnsi("Selecionar Documento Original ( Devolucao/Beneficiamento/Complemento )"+" - <F7> "),"Atenção"} ) //"Selecionar Documento Original ( Devolucao/Beneficiamento/Complemento )"
		If SuperGetMV("MV_PRNFBEN",.F.,.F.)
			SF5->(dbSetOrder(1))
			If SF5->(dbSeek(xFilial("SF5")+GetMV("MV_TMPAD")))
				aAdd(aButtons, {'RECALC',{||ARetBenef()},"Retorno de Beneficiamento#Retorno Ben.","Retorno de Beneficiamento#Retorno Ben."} ) //"Retorno de Beneficiamento#Retorno Ben."
			EndIf
		EndIf
		aAdd(aButtons, {'bmpincluir',{||A103LoteF4()},OemToAnsi("Selecionar Lotes Disponiveis"+" - <F8> "),"Selecionar Lotes Disponiveis"} ) //"Selecionar Lotes Disponiveis"
		If ! lPyme
			aAdd(aButVisual,{"budget",{|| a120Posic(cAlias,nReg,nOpcX,"NF")},OemToAnsi("Consulta Aprovacao"),OemToAnsi("Consulta Aprovacao")}) //"Consulta Aprovacao"
		EndIf
		If ( aRotina[ nOpcX, 4 ] == 2 .Or. aRotina[ nOpcX, 4 ] == 6 ) .And. !AtIsRotina("A103TRACK")
			AAdd(aButtons  ,{ "bmpord1", {|| A103Track() }, OemToAnsi("System Tracker"), OemToAnsi("System Tracker") } )  // "System Tracker"
			AAdd(aButVisual,{ "bmpord1", {|| A103Track() }, OemToAnsi("System Tracker"), OemToAnsi("System Tracker") } )  // "System Tracker"
		EndIf

//		If !lPyme .And. aRotina[ nOpcX, 4 ] == 2
		If aRotina[ nOpcX, 4 ] == 2
			AAdd(aButVisual,{ "clips", {|| A103Conhec() }, "Banco de Conhecimento", "Conhecim." } ) // "Banco de Conhecimento", "Conhecim."
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Permite pesquisar docs de saida de devolucao para vincular   ³
	//³ com compra - Projeto Oleo e Gas                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If GetNewPar("MV_NFVCORI","2") == "1"
		aAdd(aButtons, {"NOTE",{||NfeVincOri()},OemToAnsi("Pesquisa Doc Saida - Vínculo"),"Pesquisa Doc Saida - Vínculo"} )//"Pesquisa Doc Saida - Vínculo"
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Tratamento para rotina automatica                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Type('l103Auto') == 'U'
		PRIVATE l103Auto	:= .F.
	EndIf
	lWhenGet   := IIf(ValType(lWhenGet) <> "L" , .F. , lWhenGet)

	lVldAfter  := lWhenGet
	lMt100Tok  := !lWhenGet

	lConsMedic := A103GCDisp()

	aRotina[nOpcx][4] := 5

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Do Case
	Case aRotina[nOpcx][4] == 2
		l103Visual := .T.
		INCLUI := IIf(Type("INCLUI")=="U",.F.,INCLUI)
		ALTERA := IIf(Type("ALTERA")=="U",.F.,ALTERA)
	Case aRotina[nOpcx][4] == 3
		l103Inclui	:= .T.
		INCLUI := IIf(Type("INCLUI")=="U",.F.,INCLUI)
		ALTERA := IIf(Type("ALTERA")=="U",.F.,ALTERA)
	Case aRotina[nOpcx][4] == 4
		l103Class	:= .T.
		l103TolRec  := .T.
		INCLUI := IIf(Type("INCLUI")=="U",.F.,INCLUI)
		ALTERA := IIf(Type("ALTERA")=="U",.F.,ALTERA)
	Case aRotina[nOpcx][4] == 5 .Or. aRotina[nOpcx][4] == 20 .or. aRotina[nOpcx][4] == 21
		l103Exclui	:= .T.
		l103Visual	:= .T.
		INCLUI := IIf(Type("INCLUI")=="U",.F.,INCLUI)
		ALTERA := IIf(Type("ALTERA")=="U",.F.,ALTERA)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Indica a chamada de exclusao via SIGAEIC                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aRotina[ nOpcx, 4 ] == 20
			lExcViaEIC := .T.
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Encontra o nOpcx referente ao tipo 5 - Exclusao padrao  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty( nScan := AScan( aRotina, { |x| x[4] == 5 } ) )
				nOpcx := nScan
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Indica a chamada de exclusao via SIGATMS                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aRotina[ nOpcx, 4 ] == 21
			lExcViaTMS := .T.
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Encontra o nOpcx referente ao tipo 5 - Exclusao padrao  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty( nScan := AScan( aRotina, { |x| x[4] == 5 } ) )
				nOpcx := nScan
			EndIf
		EndIf

	OtherWise
		l103Visual := .T.
		INCLUI := IIf(Type("INCLUI")=="U",.F.,INCLUI)
		ALTERA := IIf(Type("ALTERA")=="U",.F.,ALTERA)
	EndCase

	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Implementado o tratamento  para trazer o codigo de Retencao gravado na tabela³
	//|SE2 qdo ultilizada o parametro MV_VISDIRF=1                                  |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	If SuperGetMv("MV_VISDIRF",.F.,"1") == "1" .And. l103Visual
		dbSelectArea("SE2")
		SE2->(dbSetOrder(6))
		SE2->(dbSeek(xFilial("SE2")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_PREFIXO+SF1->F1_DOC))
		If !Empty(SE2->E2_DIRF) .And. !Empty(SE2->E2_CODRET)
			cDirf   := SE2->E2_DIRF
			cCodRet := SE2->E2_CODRET

			If !Empty( cCodRet )
				If aScan( aCodR, {|aX| aX[4]=="IRR"})==0
					aAdd( aCodR, {99, cCodRet, 1, "IRR"} )
				Else
					aCodR[aScan( aCodR, {|aX| aX[4]=="IRR"})][2]	:=	cCodRet
				EndIf
			EndIf
		EndIf
	EndIf

	nRecSF1	 := IIF(INCLUI,0,SF1->(RecNo()))

	If l103Class
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica data da emissao de acordo com a data base           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If dDataBase < SF1->F1_EMISSAO
			lContinua := .F.
			Aviso(OemToAnsi("Não é possível classificar notas emitidas posteriormente a data corrente do sistema."),OemToAnsi("Não é possível classificar notas emitidas posteriormente a data corrente do sistema."),{"Ok"})//"Não é possível classificar notas emitidas posteriormente a data corrente do sistema."
		EndIf


		If lContinua
			If !Empty( nScanBsPis := aScan(aRelImp,{|x| x[1]=="SD1" .And. x[3]=="IT_BASEPS2"} ) ) .And. ;
					!Empty( nScanVlPis := aScan(aRelImp,{|x| x[1]=="SD1" .And. x[3]=="IT_VALPS2"} ) ) .And. ;
					!Empty( nScanAlPis := aScan(aRelImp,{|x| x[1]=="SD1" .And. x[3]=="IT_ALIQPS2"} ) )
				cCpBasePIS  := aRelImp[nScanBsPis,2]
				cCpValPIS   := aRelImp[nScanVlPis,2]
				cCpAlqPIS   := aRelImp[nScanAlPis,2]
			EndIf

			If !Empty( nScanBsCof := aScan(aRelImp,{|x| x[1]=="SD1" .And. x[3]=="IT_BASECF2"} ) ) .And. ;
					!Empty( nScanVlCof := aScan(aRelImp,{|x| x[1]=="SD1" .And. x[3]=="IT_VALCF2"} ) ) .And. ;
					!Empty( nScanAlCof := aScan(aRelImp,{|x| x[1]=="SD1" .And. x[3]=="IT_ALIQCF2"} ) )
				cCpBaseCOF  := aRelImp[nScanBsCOF,2]
				cCpValCOF   := aRelImp[nScanVlCOF,2]
				cCpAlqCOF   := aRelImp[nScanAlCOF,2]
			EndIf

		EndIf
	EndIf

	// Verifica se existe bloqueio contabil - Validacao incluida em 03/08/2015 changeset 320011 release 12
	If lContinua .And. ( l103Inclui .Or. l103Exclui .Or. l103Class )
		If l103Exclui .Or. l103Class
			dCtbValiDt := SF1->F1_DTDIGIT
		Else
			dCtbValiDt := dDataBase
		EndIf
		lContinua := CtbValiDt(Nil ,dCtbValiDt ,.T. ,Nil ,Nil ,{"COM001"}) // Retorno .F. -> Help CTBBLOQ - Calendario Contabil Bloqueado. Verifique o processo.
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define as Hot-keys da rotina                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !l103Auto .And. (l103Inclui .Or. l103Class .Or. lWhenGet)
		SetKey( VK_F4 , { || A103F4() } )
		SetKey( VK_F5 , { || A103ForF4( NIL, NIL, lNfMedic, lConsMedic, aHeadSDE, @aColsSDE, aHeadSEV, aColsSEV, @lTxNeg, @nTaxaMoeda ),aBackColsSDE:=ACLONE(aColsSDE) } )
		SetKey( VK_F6 , { || A103ItemPC( NIL,NIL,NIL,lNfMedic,lConsMedic,aHeadSDE,@aColsSDE,,@lTxNeg, @nTaxaMoeda),aBackColsSDE:=ACLONE(aColsSDE) } )
		SetKey( VK_F7 , { || A103NFORI() } )
		SetKey( VK_F8 , { || A103LoteF4() } )
		SetKey( VK_F9 , { |lValidX3| NfeRatCC(aHeadSDE,aColsSDE,l103Inclui.Or.l103Class,lValidX3),aBackColsSDE:=ACLONE(aColsSDE)})
		bKeyF12 := SetKey( VK_F12 , Nil )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Integracao com o modulo de Projetos                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If IntePms()		// Integracao PMS
			SetKey( VK_F10, { || Eval(bPmsDlgNF)} )
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Integracao com o modulo de Transportes                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If IntTMS()		// Integracao TMS
			SetKey( VK_F11, { || oGetDados:oBrowse:lDisablePaint:=.T.,A103RatVei(),oGetDados:oBrowse:lDisablePaint:=.F.} )
		EndIf
	ElseIf !l103Auto .Or. lWhenGet
		bKeyF12 := SetKey( VK_F12 , Nil )
		If nOPCX<>6
			SetKey( VK_F9 , { |lValidX3| oGetDados:oBrowse:lDisablePaint:=.T.,NfeRATCC(aHeadSDE,aColsSDE,l103Inclui.Or.l103Class,lValidX3),oGetDados:oBrowse:lDisablePaint:=.F.,aBackColsSDE:=ACLONE(aColsSDE) } )
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Integracao com o modulo de Projetos                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If IntePms()		// Integracao PMS
		aadd(aButtons	, {'PROJETPMS',{||Eval(bPmsDlgNF)},OemToAnsi("Projetos"+" - <F10> "),OemToAnsi("Projetos")}) //"Projetos"
		aadd(aButVisual	, {'PROJETPMS',{||Eval(bPmsDlgNF)},OemToAnsi("Projetos"+" - <F10> "),OemToAnsi("Projetos")}) //"Projetos"
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Integracao com o modulo de Transportes                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If IntTMS()		// Integracao TMS
		Aadd(aButtons	, {'CARGA'		,{||oGetDados:oBrowse:lDisablePaint:=.T.,A103RATVEI(),oGetDados:oBrowse:lDisablePaint:=.F. },"Rateio por Veiculo/Viagem"+" - <F11>" , "Rateio por Veiculo/Viagem"}) //"Rateio por Veiculo/Viagem"
		Aadd(aButVisual	, {'CARGA'		,{||oGetDados:oBrowse:lDisablePaint:=.T.,A103RATVEI(),oGetDados:oBrowse:lDisablePaint:=.F. },"Rateio por Veiculo/Viagem"+" - <F11>", "Rateio por Veiculo/Viagem" }) //"Rateio por Veiculo/Viagem"
		Aadd(aButtons	, {'CARGASEQ'	,{||oGetDados:oBrowse:lDisablePaint:=.T.,A103FROTA(),oGetDados:oBrowse:lDisablePaint:=.F. },"Rateio por Frota","Rateio por Frota"}) //"Rateio por Frota"
		Aadd(aButVisual	, {'CARGASEQ'	,{||oGetDados:oBrowse:lDisablePaint:=.T.,A103FROTA(),oGetDados:oBrowse:lDisablePaint:=.F. },"Rateio por Frota","Rateio por Frota"}) //"Rateio por Frota"
	EndIf
	If !lGSPInUseM
		Aadd(aButtons	, {'S4WB013N' ,{||oGetDados:oBrowse:lDisablePaint:=.T.,NfeRatCC(aHeadSDE,aColsSDE,l103Inclui.Or.l103Class),oGetDados:oBrowse:lDisablePaint:=.F.,aBackColsSDE:=ACLONE(aColsSDE) },OemToAnsi("Rateio do item por Centro de Custo"+" - <F9> "),"Rateio do item por Centro de Custo"} ) //"Rateio do item por Centro de Custo"
		Aadd(aButVisual	, {'S4WB013N' ,{||oGetDados:oBrowse:lDisablePaint:=.T.,NfeRatCC(aHeadSDE,aColsSDE,l103Inclui.Or.l103Class),oGetDados:oBrowse:lDisablePaint:=.F.,aBackColsSDE:=ACLONE(aColsSDE) },OemToAnsi("Rateio do item por Centro de Custo"+" - <F9> "),"Rateio do item por Centro de Custo"} ) //"Rateio do item por Centro de Custo"
		aadd(aButVisual	, {"S4WB005N" ,{|| NfeViewPrd() },"Historico de Compras","Historico de Compras"}) //"Historico de Compras"
	EndIf

	//Itens Complemento DCL
	If lDclNew
		AAdd(aButtons, { "DCLEA013", {|| DCLEA013View(aCols,aHeader,,lConsMedic,aHeadSDE,aColsSDE,aHeadSEV,aColsSEV,lTxNeg,nTaxaMoeda,l103Inclui) }, "Complemento DCL","Complemento DCL" } )  //"Seleciona Multas", "Multas"
		AAdd(aButVisual, { "DCLEA013", {|| DCLEA013View(aCols,aHeader,.T.,lConsMedic,aHeadSDE,aColsSDE,aHeadSEV,aColsSEV,lTxNeg,nTaxaMoeda,l103Inclui) }, "Complemento DCL","Complemento DCL" } )  //"Seleciona Multas", "Multas"
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Botao para exportar dados para EXCEL                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If RemoteType() == 1
		aAdd(aButtons   , {PmsBExcel()[1],{|| DlgToExcel({ {"CABECALHO",OemToAnsi(""),{RetTitle("F1_TIPO"),RetTitle("F1_FORMUL"),RetTitle("F1_DOC"),RetTitle("F1_SERIE"),RetTitle("F1_EMISSAO"),RetTitle("F1_FORNECE"),RetTitle("F1_LOJA"),RetTitle("F1_ESPECIE"),RetTitle("F1_EST")},{cTipo,cFormul,cNFiscal,Substr(cSerie,1,3),dDEmissao,cA100For,cLoja,cEspecie,cUfOrig}},{"GETDADOS",OemToAnsi(""),aHeader,aCols},{"GETDADOS",OemToAnsi(""),aHeadSE2,aColsSE2}})},PmsBExcel()[2],PmsBExcel()[3]})
		aAdd(aButVisual , {PmsBExcel()[1],{|| DlgToExcel({ {"CABECALHO",OemToAnsi(""),{RetTitle("F1_TIPO"),RetTitle("F1_FORMUL"),RetTitle("F1_DOC"),RetTitle("F1_SERIE"),RetTitle("F1_EMISSAO"),RetTitle("F1_FORNECE"),RetTitle("F1_LOJA"),RetTitle("F1_ESPECIE"),RetTitle("F1_EST")},{cTipo,cFormul,cNFiscal,Substr(cSerie,1,3),dDEmissao,cA100For,cLoja,cEspecie,cUfOrig}},{"GETDADOS",OemToAnsi(""),aHeader,aCols},{"GETDADOS",OemToAnsi(""),aHeadSE2,aColsSE2}})},PmsBExcel()[2],PmsBExcel()[3]})
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Selecao de multas - SIGAGCT                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If A103GCDisp()
		AAdd(aButtons, { "checked", {|| A103Multas(dDEmissao,cA100For,cLoja,aMultas) }, "Seleciona Multas", "Multas" } )  //"Seleciona Multas", "Multas"
	EndIf

	//Aposentadoria Especial - Projeto REINF
	If ChkFile("DHP")
		Aadd(aButtons	, {'APOSESP' ,{||oGetDados:oBrowse:lDisablePaint:=.T.,A103Aposen(aHeadDHP,aColsDHP,l103Inclui,l103Class),oGetDados:oBrowse:lDisablePaint:=.F.},"Aposentadoria Especial","Apos.Especial"} ) //"Aposentadoria Especial"
		Aadd(aButVisual	, {'APOSESP' ,{||oGetDados:oBrowse:lDisablePaint:=.T.,A103Aposen(aHeadDHP,aColsDHP,l103Inclui,l103Class),oGetDados:oBrowse:lDisablePaint:=.F.},"Aposentadoria Especial","Apos.Especial"} ) //"Aposentadoria Especial"
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Tratamento p/ Nota Fiscal geradas no SIGAEIC            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !l103Inclui .And. SF1->F1_IMPORT == "S"
		If !lExcViaEIC .And. l103Exclui
			Help( "", 1, "A103EXCIMP" )  // "Este documento nao pode ser excluido pois foi criado pelo SIGAEIC. A exclusao devera ser efetuada pelo SIGAEIC."
		Else
			A103NFEIC(cAlias,nReg,nOpcx)
		EndIf
		lContinua := .F.
	EndIf

	//Validacao incluida pela controladoria para  valicação da Nota fical de transferencia Rotina ATFA060
	If Alltrim(SF1->F1_ORIGEM) == "ATFA060" .And. !FwIsInCallStack("ATFA060") .And. l103Exclui
		Help(" ",1,'HFA103NFis',,"Excluir",1,0)
		lRet := .F.
		Return lRet
	Endif
	//Verifica se o Produto é do tipo armamento.
	If l103Exclui .And. SuperGetMV("MV_GSXNFE",,.F.)

	 		aArea2 	:= GetArea()
	 		aAreaSD1	:= SD1->(GetArea())

	 		If SD1->(dbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))

		 		DbSelectArea('SB5')
				SB5->(DbSetOrder(1)) // acordo com o arquivo SIX -> A1_FILIAL+A1_COD+A1_LOJA

				If SB5->(DbSeek(xFilial('SB5')+SD1->D1_COD)) // Filial: 01, Código: 000001, Loja: 02
					If SB5->B5_TPISERV=='2'
	  					lRetorno := aT720Mov(SD1->D1_DOC,SD1->D1_SERIE)
	  					If !lRetorno
	  						lContinua := lRetorno
	  						Help( "", 1, "At720Mov" )
	  					EndIf
					ElseIf SB5->B5_TPISERV=='1'
	  					lRetorno := aT710Mov(SD1->D1_DOC,SD1->D1_SERIE)
	  					If !lRetorno
	  						lContinua := lRetorno
	  						Help( "", 1, "At710Mov" )
	  					EndIf
	  				ElseIf SB5->B5_TPISERV=='3'
	  					lRetorno := aT730Mov(SD1->D1_DOC,SD1->D1_SERIE)
	  					If !lRetorno
	  						lContinua := lRetorno
	  						Help( "", 1, "At730Mov" )
	  					EndIf
					EndIf

				EndIf

			EndIf

			RestArea(aAreaSD1)
			RestArea(aArea2)
	EndIf

	// Valida de permite excluir NF de compra futura, com saldo consumido
	If l103Exclui .And. lDHQInDic .And. lMt103Com .And. !A103FutVld(.T., aCompFutur)
		lContinua := .F.
	EndIf

	// Inicializa variaveis aba Informacoes Adicionais
	If FindFunction("A103ChkInfAdic")
		A103ChkInfAdic(IIF(l103Inclui,1,2)) 
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Notas Fiscais NAO Classificadas geradas pelo SIGAEIC NAO deverao ser visualizadas no MATA103 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If l103Visual .And. !Empty(SF1->F1_HAWB) .And. Empty(SF1->F1_STATUS)
		Aviso("A103NOVIEWEIC","Este documento foi gerado pelo SIGAEIC e ainda NÃO foi classificado, para visualizar utilizar a opção classificar ou no Modulo SIGAEIC opção Desembaraço/recebimento de importação/Totais. Apos a classificação o documento pode ser visualizado normalmente nesta opção.",{"Ok"}) // "Este documento foi gerado pelo SIGAEIC e ainda NÃO foi classificado, para visualizar utilizar a opção classificar ou no Modulo SIGAEIC opção Desembaraço/recebimento de importação/Totais. Apos a classificação o documento pode ser visualizado normalmente nesta opção."
		lContinua := .F.
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Notas Fiscais excluídas, rastreamento contábil ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lContinua .And. l103Visual .And. ( SD1->(Deleted()) .Or. SF1->(Deleted()) ) .And. IsInCallStack("CTBC010ROT")
		Aviso("A103NOVIEWDEL","Este documento encontrasse excluído e não é possível visualiza-lo.",{"Ok"}) //"Este documento encontrasse excluído e não é possível visualiza-lo."
		lContinua := .F.
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa as variaveis                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTipo		:= IIf(l103Inclui,CriaVar("F1_TIPO",.F.),SF1->F1_TIPO)
	If cPaisLoc == "BRA" .And. SF1->(ColumnPos("F1_TPCOMPL")) > 0
		cTpCompl	:= IIF(l103Inclui,CriaVar("F1_TPCOMPL",.F.),SF1->F1_TPCOMPL)
	EndIf
	cFormul	:= IIf(l103Inclui,CriaVar("F1_FORMUL",.F.),SF1->F1_FORMUL)
	cNFiscal	:= IIf(l103Inclui,CriaVar("F1_DOC"),SF1->F1_DOC)
	cSerie		:= IIf(l103Inclui,SerieNfId("SF1",5,"F1_SERIE") , SerieNfId("SF1",2,"F1_SERIE") )
	If lSubSerie
		cSubSerie	:= IIf(l103Inclui,CriaVar("F1_SUBSERI"),SF1->F1_SUBSERI)
	EndIf
	dDEmissao	:= IIf(l103Inclui,CriaVar("F1_EMISSAO"),SF1->F1_EMISSAO)
	cA100For	:= IIf(l103Inclui,CriaVar("F1_FORNECE",.F.),SF1->F1_FORNECE)
	cLoja		:= IIf(l103Inclui,CriaVar("F1_LOJA",.F.),SF1->F1_LOJA)
	cEspecie	:= IIf(l103Inclui,CriaVar("F1_ESPECIE"),SF1->F1_ESPECIE)
	cCondicao	:= IIf(l103Inclui,CriaVar("F1_COND"),SF1->F1_COND)
	cUfOrig	:= IIf(l103Inclui,CriaVar("F1_EST"),SF1->F1_EST)
	cRecIss	:= IIf(l103Inclui,CriaVar("F1_RECISS"),SF1->F1_RECISS)
	cFornIss	:= Iif(l103Inclui,Iif(Empty(cFornIss),CriaVar("F1_FORNECE"),cFornIss),cFornIss)
	cLojaIss	:= Iif(l103Inclui,Iif(Empty(cLojaIss),CriaVar("F1_LOJA"),cLojaIss),cLojaIss)
	dVencISS	:= IIf(l103Inclui,CtoD(""),dVencISS)
	If lISSxMun .And. cPaisLoc == "BRA"
		aInfISS[1,1] := IIf(l103Inclui,CriaVar("F1_INCISS"),SF1->F1_INCISS)
		aInfISS[1,3] := IIf(l103Inclui,CriaVar("F1_ESTPRES"),SF1->F1_ESTPRES)
		aInfAdic[1]  := aInfISS[1,1]
		cDescMun     := Posicione("CC2",1,xFilial("CC2")+aInfISS[1,3]+aInfISS[1,1],"CC2_MUN")
	Else
	If cPaisLoc == "BRA"
		cInfISS := IIf(l103Inclui,CriaVar("F1_ESTPRES"),SF1->F1_ESTPRES)
	EndIf
		If Len(aInfAdic) > 0
			cDescMun    := Posicione("CC2",1,xFilial("CC2")+cInfISS+aInfAdic[1],"CC2_MUN")
		Endif
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Trata codigo do diario  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If UsaSeqCor()
		cCodDiario := IIf(l103Inclui,CriaVar("F1_DIACTB"),SF1->F1_DIACTB)
	EndIf

	If (!cTipo$"DB" .And. !Empty(cA100For) .And. cA100For+cLoja <> SA2->A2_COD+SA2->A2_LOJA)
		SA2->(DbSetOrder(1))
		SA2->(MsSeek(xFilial("SA2")+cA100For+cLoja))
	EndIf

	If cPaisLoc == "BRA"
		If l103Inclui
			aNFEletr  := {CriaVar("F1_NFELETR"),CriaVar("F1_CODNFE"),CriaVar("F1_EMINFE"),CriaVar("F1_HORNFE"),CriaVar("F1_CREDNFE"),CriaVar("F1_NUMRPS"),;
				    	  CriaVar("F1_MENNOTA"),CriaVar("F1_MENPAD")}
			    A103CheckDanfe(2)
				If l103Auto
					If aScan(aAutoCab,{|x| AllTrim(x[1])=="F1_TPFRETE"})>0
						aNFEDanfe[14]:=aAutoCab[aScan(aAutoCab,{|x| AllTrim(x[1])=="F1_TPFRETE"})][2]
					EndIF
				EndIf
		Else
			aNFEletr  := {SF1->F1_NFELETR,SF1->F1_CODNFE,SF1->F1_EMINFE,SF1->F1_HORNFE,SF1->F1_CREDNFE,SF1->F1_NUMRPS,;
				    	  SF1->F1_MENNOTA,SF1->F1_MENPAD}
				A103CargaDanfe(l103Class,aNFEletr,aInfAdic)
		Endif
	Endif

	If l103Class .And. Empty(cCondicao) .And. SF1->F1_STATUS <> 'C'
		DbSelectArea("SA2")
		DbSetOrder(1)
		If MsSeek(xFilial("SA2")+cA100For+cLoja)
			cCondicao  := SA2->A2_COND
		EndIf
		DbSelectArea("SF1")
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa as variaveis do pergunte                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte("MTA103",.F.)
	//Carrega as variaveis com os parametros da execauto
	Ma103PerAut()

	lDigita     := (mv_par01==1)
	lAglutina   := (mv_par02==1)
	lReajuste   := (mv_par04==1)
	lAmarra     := (mv_par05==1)
	lGeraLanc   := (mv_par06==1)
	lConsLoja   := (mv_par07==1)
	IsTriangular(mv_par08==1)
	nTpRodape   := (mv_par09)
	lPrecoDes   := (mv_par10==1)
	lDataUcom   := (mv_par11==1)
	lAtuAmarra  := (mv_par12==1)
	lRatLiq     := (mv_par13==2)
	lRatImp     := (mv_par13==1 .And. mv_par14==2)
	
	If lContinua

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gera distribuicao de produtos (crossdoking)                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (l103Inclui .Or. l103Class) .And. SF1->F1_TIPO == "N" .And. SF1->F1_STATUS != "C" .AND. IntWMS()
			WmsAvalSF1("6")
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ponto de entrada para adicao de campos memo do usuario       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock( "MT103MEM" )
			If Valtype(	aMemUser := ExecBlock( "MT103MEM", .F., .F. ) ) == "A"
				aEval( aMemUser, { |x| aAdd( aMemoSDE, x ) } )
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Template acionando ponto de entrada                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lTMt103NFE
			ExecTemplate("MT103NFE",.F.,.F.,nOpcx)
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ponto de entrada no inicio do Documento de Entrada         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lMt103NFE
			Execblock("MT103NFE",.F.,.F.,nOpcx)
		EndIf
		If l103Inclui .Or. l103Class
			If l103Class
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Ponto de Entrada na Classificacao da NF                    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ExistBlock("MT100CLA")
					ExecBlock("MT100CLA",.F.,.F.)
				EndIf
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Validacoes para Inclusao/Classificacao de NF de Entrada    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//If !NfeVldIni(l103Class,lGeraLanc,@lClaNfCfDv)
			//	lContinua := .F.
			//EndIf
		ElseIf l103Exclui
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ As Validacoes para Exclusao de NF de Entrada serao aplicadas³
			//³ somente quando a NFE nao esteja Bloqueada.                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !SF1->F1_STATUS $ "BC"
				If !MaCanDelF1(nRecSF1,@aRecSC5,aRecSE2,Nil,Nil,Nil,Nil,aRecSE1,lExcViaEIC,lExcViaTMS)
					lContinua := .F.
				EndIf
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Integracao com o modulo de Armazenagem - SIGAWMS                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lContinua .And. (IntWMS() .Or. lWmsCRD) .And. SF1->F1_TIPO $ "N|D|B" //-- Validação se pode excluir a nota fiscal pelo WMS
				lContinua := WmsAvalSF1(Iif(lEstNfClass,"2","4"),"SF1")
			EndIf
			// quando a nota for de devolução, valida se já houve uma nova movimentaçao no equipamento
			If lContinua .And. SF1->F1_TIPO == 'D'.And. !At800ExcD1( nRecSF1 )
				lContinua := .F.
			EndIf

		EndIf
	EndIf
	If lContinua
		If !l103Inclui .And. !l103Auto
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicializa as veriaveis utilizadas na exibicao da NF         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lISSxMun
				NfeCabOk(l103Visual,/*oTipo*/,/*oNota*/,/*oEmissao*/,/*oFornece*/,/*oLoja*/,/*lFiscal*/,cUfOrig,aInfISS[1,1],aInfISS[1,3])
			Else
				NfeCabOk(l103Visual,/*oTipo*/,/*oNota*/,/*oEmissao*/,/*oFornece*/,/*oLoja*/,/*lFiscal*/,cUfOrig)
			EndIf 
		Else
			If !l103Inclui
				MaFisIni(SF1->F1_FORNECE,SF1->F1_LOJA,IIf(cTipo$'DB',"C","F"),cTipo,Nil,MaFisRelImp("MT100",{"SF1","SD1"}),,!l103Visual,,,,,,,,,,,,,,,,,dDEmissao,,,,,,,,lTrbGen)
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Montagem do aHeader                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Type("aBackSD1")=="U" .Or. Empty(aBackSD1)
			aBackSD1 := {}
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Trava os registros do SF1 - Alteracao e Exclusao       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If l103Class .Or. l103Exclui
			If !SoftLock("SF1")
				lContinua := .F.
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tratamento da exclusão da nota fiscal de entrada - NF-e SEFAZ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If l103Exclui
			If SF1->F1_FORMUL == "S" .And. "SPED"$cEspecie .And. (cAlias)->F1_FIMP$"TS" //verificacao apenas da especie como SPED e notas que foram transmitidas ou impressoo DANFE
				If cPaisLoc == "BRA"
					nHoras := SubtHoras(IIF(!Empty(SF1->F1_DAUTNFE),SF1->F1_DAUTNFE,dDtdigit),IIF(!Empty(SF1->F1_HAUTNFE),SF1->F1_HAUTNFE,SF1->F1_HORA), dDataBase, substr(Time(),1,2)+":"+substr(Time(),4,2) )
				EndIf
				If nHoras > nSpedExc .And. SF1->F1_STATUS<>"C"
					If l103Auto
						Help("  ",1,"" + Alltrim(STR(nSpedExc)) +"")
					Else
						MsgAlert("" + Alltrim(STR(nSpedExc)) +"")
					EndIf
					lContinua := .F.
				ElseIf SF1->F1_STATUS=="C" .And. l103Exclui
					If l103Auto
						Help("  ",1,"")
					Else
						Aviso("Não foi possivel excluir a nota, pois a mesma já foi transmitida e encotra-se bloqueada. Será necessário realizar a primeiro a classificação da nota e posteriormente a exclusão!","OK",{"Ok"}) //Não foi possivel excluir a nota, pois a mesma já foi transmitida e encotra-se bloqueada. Será necessário realizar a primeiro a classificação da nota e posteriormente a exclusão!"
					EndIf
					lContinua := .F.
				Else
					lContinua := .T.
			    EndIf
			EndIf
		EndIf

		//Quando existir a NF no Modulo de Veiculos, a exclusao da
		//NF somente pode ser realizada no Modulo de Veiculos
		If lContinua .and. l103Exclui .and. lIntGC
			cAliasAnt := Alias()
			cAliasVVF := "SQLVVF"
			cQuery := "SELECT VVF.R_E_C_N_O_ FROM "+RetSqlName("VVF")+" VVF "
			cQuery += "WHERE VVF.VVF_FILIAL='"+xFilial("VVF")+"' AND "
			cQuery += "VVF.VVF_NUMNFI = '"+SF1->F1_DOC+"' AND VVF.VVF_SERNFI = '"+SF1->F1_SERIE+"' AND VVF.VVF_CODFOR = '"+SF1->F1_FORNECE+"' AND VVF.VVF_LOJA = '"+SF1->F1_LOJA+"' AND "
        	cQuery += "VVF.VVF_SITNFI = '1' AND VVF.D_E_L_E_T_=' '"
			cQuery := ChangeQuery(cQuery)

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasVVF,.T.,.T.)

			 If (cAliasVVF)->(!Eof()) .and. !(FM_PILHA("OFI") .or. FM_PILHA("VEI"))
				cMensagem:= "Nao possivel excluir esse documento pois "+CHR(10)+CHR(13) // "Nao possivel excluir esse documento pois "
				cMensagem+= "sua origem ocorreu no Modulo de Veiculos. "+CHR(10)+CHR(13) // "sua origem ocorreu no Modulo de Veiculos. "
				cMensagem+= "Portanto seu Cancelamento so sera possivel no modulo de Veiculos."+CHR(10)+CHR(13) // "Portanto seu Cancelamento so sera possivel no modulo de Veiculos."
				Help(" ",1,"NAOEXCNFS","NAOEXCNFS",cMensagem,1,0)
				lContinua := .F.
			Endif

			DbSelectArea(cAliasVVF)
			dbCloseArea()
			DbSelectArea(cAliasAnt)

		Endif

		//Não permite excluir nota que tenha movimentacao de AVP
		If lContinua .And. l103Exclui
			dbSelectArea("SE2")
			SE2->(dbSetOrder(1))
			If SE2->(dbSeek(xFilial("SE2")+SF1->F1_SERIE+SF1->F1_DOC))
				While SE2->(!EOF()) .And. (SF1->F1_FILIAL+SF1->F1_SERIE+SF1->F1_DOC == SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM)
					If !FAVPValTit( "SE2",, SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO, SE2->E2_FORNECE, SE2->E2_LOJA, " " )
						lContinua := .F.
						Exit
					EndIF
					SE2->(dbSkip())
				End
			EndIf
		EndIf

		If lContinua
			If l103Class .Or. l103Visual .Or. l103Exclui
				aadd(aTitles,("Historico")) //"Historico"
				aAdd(aFldCBAtu,Nil)

				If Type("aNfeDanfe") == "A" .AND. Len(aNfeDanfe)>=23
					If !Empty(MafisScan("NF_MODAL",.F.)) .And. (Left(aNfeDanfe[23],2) $ "  |01|02|03|04|05|06")
						MaFisRef("NF_MODAL","MT100",Left(aNfeDanfe[23],2))
					EndIf
				EndIf

				If !l103Class .And. !Empty( MaFisScan("NF_RECISS",.F.) )
					MaFisAlt("NF_RECISS",SF1->F1_RECISS)
				EndIf
				cRecIss	:=	MaFisRet(,"NF_RECISS")
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Carrega o Array contendo os Registros Fiscais.(SF3)     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("SF3")
				DbSetOrder(4)
						lQuery    := .T.
						cAliasSF3 := "HFA103NFis"
						aStruSF3  := SF3->(dbStruct())

						cQuery    := "SELECT SF3.*,SF3.R_E_C_N_O_ SF3RECNO "
						cQuery    += "  FROM "+RetSqlName("SF3")+" SF3 "
						cQuery    += " WHERE SF3.F3_FILIAL     = '"+xFilial("SF3")+"'"
						cQuery    += "   AND SF3.F3_CLIEFOR	   = '"+SF1->F1_FORNECE+"'"
						cQuery    += "   AND SF3.F3_LOJA	   = '"+SF1->F1_LOJA+"'"
						cQuery    += "   AND SF3.F3_NFISCAL	   = '"+SF1->F1_DOC+"'"
						cQuery    += "   AND SF3.F3_SERIE	   = '"+SF1->F1_SERIE+"'"
						cQuery    += "   AND SF3.F3_FORMUL	   = '"+SF1->F1_FORMUL+"'"
						cQuery    += "   AND SF3.D_E_L_E_T_	   = ' ' "
						cQuery    += " ORDER BY "+SqlOrder(SF3->(IndexKey()))

						cQuery := ChangeQuery(cQuery)

						dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF3,.T.,.T.)
						For nX := 1 To Len(aStruSF3)
							If aStruSF3[nX,2]<>"C"
								TcSetField(cAliasSF3,aStruSF3[nX,1],aStruSF3[nX,2],aStruSF3[nX,3],aStruSF3[nX,4])
							EndIf
						Next nX
				While !Eof() .And. lContinua .And.;
						xFilial("SF3") == (cAliasSF3)->F3_FILIAL .And.;
						SF1->F1_FORNECE == (cAliasSF3)->F3_CLIEFOR .And.;
						SF1->F1_LOJA == (cAliasSF3)->F3_LOJA .And.;
						SF1->F1_DOC == (cAliasSF3)->F3_NFISCAL .And.;
						SF1->F1_SERIE == (cAliasSF3)->F3_SERIE
					If Substr((cAliasSF3)->F3_CFO,1,1) < "5" .And. (cAliasSF3)->F3_FORMUL == SF1->F1_FORMUL
						aadd(aRecSF3,If(lQuery,(cAliasSF3)->SF3RECNO,SF3->(RecNo())))
					EndIf
					DbSelectArea(cAliasSF3)
					dbSkip()
				EndDo
				If lQuery
					DbSelectArea(cAliasSF3)
					dbCloseArea()
					DbSelectArea("SF3")
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Monta o Array contendo as registros do SDE           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("SDE")
				DbSetOrder(1)
						lQuery    := .T.
						aStruSDE  := SDE->(dbStruct())
						cAliasSDE := "HFA103NFis"
						cQuery    := "SELECT SDE.*,SDE.R_E_C_N_O_ SDERECNO "
						cQuery    += "  FROM "+RetSqlName("SDE")+" SDE "
						cQuery    += " WHERE SDE.DE_FILIAL	 ='"+xFilial("SDE")+"'"
						cQuery    += "   AND SDE.DE_DOC		 ='"+SF1->F1_DOC+"'"
						cQuery    += "   AND SDE.DE_SERIE	 ='"+SF1->F1_SERIE+"'"
						cQuery    += "   AND SDE.DE_FORNECE  ='"+SF1->F1_FORNECE+"'"
						cQuery    += "   AND SDE.DE_LOJA     ='"+SF1->F1_LOJA+"'"
						cQuery    += "   AND SDE.D_E_L_E_T_  =' ' "
						cQuery    += " ORDER BY "+SqlOrder(SDE->(IndexKey()))

						cQuery := ChangeQuery(cQuery)

						dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSDE,.T.,.T.)
						For nX := 1 To Len(aStruSDE)
							If aStruSDE[nX,2]<>"C"
								TcSetField(cAliasSDE,aStruSDE[nX,1],aStruSDE[nX,2],aStruSDE[nX,3],aStruSDE[nX,4])
							EndIf
						Next nX
				While ( !Eof() .And. lContinua .And.;
						xFilial('SDE') == (cAliasSDE)->DE_FILIAL .And.;
						SF1->F1_DOC == (cAliasSDE)->DE_DOC .And.;
						SF1->F1_SERIE == (cAliasSDE)->DE_SERIE .And.;
						SF1->F1_FORNECE == (cAliasSDE)->DE_FORNECE .And.;
						SF1->F1_LOJA == (cAliasSDE)->DE_LOJA )
					If Empty(aBackSDE)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Montagem do aHeader                                          ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						DbSelectArea("SX3")
						DbSetOrder(1)
						MsSeek("SDE")
						While ( !EOF() .And. SX3->X3_ARQUIVO == "SDE" )
							If X3USO(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL .And. !"DE_CUSTO"$SX3->X3_CAMPO
								aadd(aBackSDE,{ TRIM(X3Titulo()),;
									SX3->X3_CAMPO,;
									SX3->X3_PICTURE,;
									SX3->X3_TAMANHO,;
									SX3->X3_DECIMAL,;
									SX3->X3_VALID,;
									SX3->X3_USADO,;
									SX3->X3_TIPO,;
									SX3->X3_F3,;
									SX3->X3_CONTEXT })
							EndIf
							DbSelectArea("SX3")
							dbSkip()
						EndDo
					EndIf
					aHeadSDE  := aBackSDE
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Adiciona os campos de Alias e Recno ao aHeader para WalkThru.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					ADHeadRec("SDE",aHeadSDE)

					aadd(aRecSDE,If(lQuery,(cAliasSDE)->SDERECNO,SDE->(RecNo())))
					If cItemSDE <> 	(cAliasSDE)->DE_ITEMNF
						cItemSDE	:= (cAliasSDE)->DE_ITEMNF
						aadd(aColsSDE,{cItemSDE,{}})
						nItemSDE++
					EndIf

					aadd(aColsSDE[nItemSDE][2],Array(Len(aHeadSDE)+1))
					For nY := 1 to Len(aHeadSDE)
						If IsHeadRec(aHeadSDE[nY][2])
							aColsSDE[nItemSDE][2][Len(aColsSDE[nItemSDE][2])][nY] := IIf(lQuery , (cAliasSDE)->SDERECNO , SDE->(Recno())  )
						ElseIf IsHeadAlias(aHeadSDE[nY][2])
							aColsSDE[nItemSDE][2][Len(aColsSDE[nItemSDE][2])][nY] := "SDE"
						ElseIf ( aHeadSDE[nY][10] <> "V")
							aColsSDE[nItemSDE][2][Len(aColsSDE[nItemSDE][2])][nY] := (cAliasSDE)->(FieldGet(FieldPos(aHeadSDE[nY][2])))
						Else
							aColsSDE[nItemSDE][2][Len(aColsSDE[nItemSDE][2])][nY] := (cAliasSDE)->(CriaVar(aHeadSDE[nY][2]))
						EndIf
						aColsSDE[nItemSDE][2][Len(aColsSDE[nItemSDE][2])][Len(aHeadSDE)+1] := .F.
					Next nY

					DbSelectArea(cAliasSDE)
					dbSkip()
				EndDo
				aBackColsSDE:=ACLONE(aColsSDE)
				If lQuery
					DbSelectArea(cAliasSDE)
					dbCloseArea()
					DbSelectArea("SDE")
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Monta o Array contendo as duplicatas SE2             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SF1->F1_TIPO$"DB"
					cPrefixo := PadR( cPrefixo, Len( SE1->E1_PREFIXO ) )
					DbSelectArea("SE1")
					DbSetOrder(2)
					MsSeek(xFilial("SE1")+SF1->F1_FORNECE+SF1->F1_LOJA+cPrefixo+SF1->F1_DOC)
					While !Eof() .And. xFilial("SE1") == SE1->E1_FILIAL .And.;
							SF1->F1_FORNECE == SE1->E1_CLIENTE .And.;
							SF1->F1_LOJA == SE1->E1_LOJA .And.;
							cPrefixo == SE1->E1_PREFIXO .And.;
							SF1->F1_DOC == SE1->E1_NUM
						If (SE1->E1_TIPO $ MV_CRNEG)
							aadd(aRecSe1,SE1->(Recno()))
						EndIf
						DbSelectArea("SE1")
						dbSkip()
					EndDo
				Else
					If Empty(aRecSE2)
						cPrefixo := PadR( cPrefixo, Len( SE2->E2_PREFIXO ) )
						DbSelectArea("SE2")
						DbSetOrder(6)

								lQuery    := .T.
								aStruSE2  := SE2->(dbStruct())
								cAliasSE2 := "HFA103NFis"
								cQuery    := "SELECT SE2.*,SE2.R_E_C_N_O_ SE2RECNO "
								cQuery    += "  FROM "+RetSqlName("SE2")+" SE2 "
								cQuery    += " WHERE SE2.E2_FILIAL  ='"+xFilial("SE2")+"'"
								cQuery    += "   AND SE2.E2_FORNECE ='"+SF1->F1_FORNECE+"'"
								cQuery    += "   AND SE2.E2_LOJA    ='"+SF1->F1_LOJA+"'"
								cQuery    += "   AND SE2.E2_PREFIXO ='"+cPrefixo+"'"
								cQuery    += "   AND SE2.E2_NUM     ='"+SF1->F1_DUPL+"'"
								cQuery    += "   AND SE2.E2_TIPO    ='"+MVNOTAFIS+"'"
								cQuery    += "   AND SE2.D_E_L_E_T_ =' ' "
								cQuery    += "ORDER BY "+SqlOrder(SE2->(IndexKey()))

								cQuery := ChangeQuery(cQuery)

								dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSE2,.T.,.T.)
								For nX := 1 To Len(aStruSE2)
									If aStruSE2[nX][2]<>"C"
										TcSetField(cAliasSE2,aStruSE2[nX][1],aStruSE2[nX][2],aStruSE2[nX][3],aStruSE2[nX][4])
									EndIf
								Next nX

						While ( !Eof() .And. lContinua .And.;
								xFilial("SE2")    == (cAliasSE2)->E2_FILIAL  		   .And.;
								SF1->F1_FORNECE   == (cAliasSE2)->E2_FORNECE 		   .And.;
								SF1->F1_LOJA      == (cAliasSE2)->E2_LOJA    		   .And.;
								AllTrim(cPrefixo) == AllTrim((cAliasSE2)->E2_PREFIXO) .And.;
								SF1->F1_DUPL      == (cAliasSE2)->E2_NUM )

								If AllTrim((cAliasSE2)->E2_TIPO) == AllTrim(MVNOTAFIS)
									aadd(aRecSE2,If(lQuery,(cAliasSE2)->SE2RECNO,(cAliasSE2)->(RecNo())))
								EndIf
								DbSelectArea(cAliasSE2)
							dbSkip()
						Enddo
						If lQuery
							DbSelectArea(cAliasSE2)
							dbCloseArea()
							DbSelectArea("SE2")
						EndIf
					EndIf
				EndIf
			EndIf

			If !l103Inclui
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Faz a montagem do aCols com os dados do SD1                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("SD1")
				DbSetOrder(1)

					aStruSD1  := SD1->(dbStruct())
						lQuery    := .T.
						cAliasSD1 := "HFA103NFis"
						cAliasSB1 := "HFA103NFis"
						cQuery    := "SELECT SD1.*,SD1.R_E_C_N_O_ SD1RECNO, B1_GRUPO,B1_CODITE,B1_TE,B1_COD "
						cQuery    += "  FROM "+RetSqlName("SD1")+" SD1, "
						cQuery    += RetSqlName("SB1")+" SB1 "
						cQuery    += " WHERE SD1.D1_FILIAL	= '"+xFilial("SD1")+"'"
						cQuery    += "   AND SD1.D1_DOC		= '"+SF1->F1_DOC+"'"
						cQuery    += "   AND SD1.D1_SERIE	= '"+SF1->F1_SERIE+"'"
						cQuery    += "   AND SD1.D1_FORNECE	= '"+SF1->F1_FORNECE+"'"
						cQuery    += "   AND SD1.D1_LOJA	= '"+SF1->F1_LOJA+"'"
						cQuery    += "   AND SD1.D1_TIPO	= '"+SF1->F1_TIPO+"'"
						cQuery    += "   AND SD1.D_E_L_E_T_	= ' '"
						cQuery    += "   AND SB1.B1_FILIAL  = '"+xFilial("SB1")+"'"
						cQuery    += "   AND SB1.B1_COD 	= SD1.D1_COD "
						cQuery    += "   AND SB1.D_E_L_E_T_ =' ' "

						If (l103Class .And. lClassOrd) .Or. (l103Visual .And. lClassOrd) .Or. lNfeOrd
							cQuery    += "ORDER BY "+SqlOrder( "D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_ITEM+D1_COD" )
						Else
							cQuery    += "ORDER BY "+SqlOrder(SD1->(IndexKey()))
						EndIf

						cQuery := ChangeQuery(cQuery)

						dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD1,.T.,.T.)
						For nX := 1 To Len(aStruSD1)
							If aStruSD1[nX][2]<>"C"
								TcSetField(cAliasSD1,aStruSD1[nX][1],aStruSD1[nX][2],aStruSD1[nX][3],aStruSD1[nX][4])
							EndIf
						Next nX

				bWhileSD1 := { || ( !Eof().And. lContinua .And. ; 
					(cAliasSD1)->D1_FILIAL== xFilial("SD1") .And. ;
					(cAliasSD1)->D1_DOC == SF1->F1_DOC .And. ;
					(cAliasSD1)->D1_SERIE == SF1->F1_SERIE .And. ;
					(cAliasSD1)->D1_FORNECE == SF1->F1_FORNECE .And. ;
					(cAliasSD1)->D1_LOJA == SF1->F1_LOJA ) }

				If !lQuery .And. ((l103Class .And. lClassOrd) .Or. (l103Visual .And. lClassOrd) .Or. lNfeOrd)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Este procedimento eh necessario para fazer a montagem        ³
					//³ do acols na ordem ITEM + COD quando classificacao em CDX     ³
					//³ e o parametro MV_CLASORD estiver ativado                     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aRecClasSD1 := {}
					While ( !Eof().And. lContinua .And. ;
							(cAliasSD1)->D1_FILIAL== xFilial("SD1") .And. ;
							(cAliasSD1)->D1_DOC == SF1->F1_DOC .And. ;
							(cAliasSD1)->D1_SERIE == SF1->F1_SERIE .And. ;
							(cAliasSD1)->D1_FORNECE == SF1->F1_FORNECE .And. ;
							(cAliasSD1)->D1_LOJA == SF1->F1_LOJA )

						AAdd( aRecClasSD1, { ( cAliasSD1 )->D1_ITEM + ( cAliasSD1 )->D1_COD, ( cAliasSD1 )->( Recno() ) } )

					( cAliasSD1 )->( dbSkip() )
				EndDo

				ASort( aRecClasSD1, , , { |x,y| y[1] > x[1] } )

				nCounterSD1 := 1
				bWhileSD1 := { || nCounterSD1 <= Len( aRecClasSD1 ) .And. lContinua  }
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Portaria CAT83  - Se o parâmetro não estiver ativo, não inclui o campo no acols ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !SuperGetMv("MV_CAT8309",.F.,.F.)
			aAdd(aNoFields,"D1_CODLAN")
		EndIf
		
		aAdd(aNoFields,"D1_TESDES")

		If !lDivImp
			aAdd(aNoFields,"D1_LEGENDA")
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ FILLGETDADOS (Monstagem do aHeader e aCols)                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³FillGetDados( nOpcx, cAlias, nOrder, cSeekKey, bSeekWhile, uSeekFor, aNoFields, aYesFields, lOnlyYes,       ³
		//³				  cQuery, bMountFile, lInclui )                                                                ³
		//³nOpcx			- Opcao (inclusao, exclusao, etc).                                                         ³
		//³cAlias		- Alias da tabela referente aos itens                                                          ³
		//³nOrder		- Ordem do SINDEX                                                                              ³
		//³cSeekKey		- Chave de pesquisa                                                                            ³
		//³bSeekWhile	- Loop na tabela cAlias                                                                        ³
		//³uSeekFor		- Valida cada registro da tabela cAlias (retornar .T. para considerar e .F. para desconsiderar ³
		//³				  o registro)                                                                                  ³
		//³aNoFields	- Array com nome dos campos que serao excluidos na montagem do aHeader                         ³
		//³aYesFields	- Array com nome dos campos que serao incluidos na montagem do aHeader                         ³
		//³lOnlyYes		- Flag indicando se considera somente os campos declarados no aYesFields + campos do usuario   ³
		//³cQuery		- Query para filtro da tabela cAlias (se for TOP e cQuery estiver preenchido, desconsidera     ³
		//³	           parametros cSeekKey e bSeekWhiele)                                                              ³
		//³bMountFile	- Preenchimento do aCols pelo usuario (aHeader e aCols ja estarao criados)                     ³
		//³lInclui		- Se inclusao passar .T. para qua aCols seja incializada com 1 linha em branco                 ³
		//³aHeaderAux	-                                                                                              ³
		//³aColsAux		-                                                                                              ³
		//³bAfterCols	- Bloco executado apos inclusao de cada linha no aCols                                         ³
		//³bBeforeCols	- Bloco executado antes da inclusao de cada linha no aCols                                     ³
		//³bAfterHeader -                                                                                              ³
		//³cAliasQry	- Alias para a Query                                                                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cPaisLoc == "BRA"
			If l103Class .and. SF1->F1_FIMP$'TS' .And. SF1->F1_STATUS='C'//Tratamento para bloqueio de alteracoes na classificacao de uma nota bloqueada e ja transmitida.
				nOpcX:= 2
				FillGetDados(nOpcX,"SD1",1,/*cSeek*/,/*{|| &cWhile }*/,{||.T.},aNoFields,/*aYesFields*/,/*lOnlyYes*/,cQuery,{|| MontaaCols(bWhileSD1,lQuery,l103Class,lClassOrd,lNfeOrd,aRecClasSD1,@nCounterSD1,cAliasSD1,cAliasSB1,@aRecSD1,@aRateio,cCpBasePIS,cCpValPIS,cCpAlqPIS,cCpBaseCOF,cCpValCOF,cCpAlqCOF,@aHeader,@aCols,l103Inclui,aHeadSDE,aColsSDE,@lContinua,,lTColab) },Inclui,/*aHeaderAux*/,/*aColsAux*/,/*bAfterCols*/,/*bbeforeCols*/,/*bAfterHeader*/,/*cAliasQry*/)
			Else
				FillGetDados(nOpcX,"SD1",1,/*cSeek*/,/*{|| &cWhile }*/,{||.T.},aNoFields,/*aYesFields*/,/*lOnlyYes*/,cQuery,{|| MontaaCols(bWhileSD1,lQuery,l103Class,lClassOrd,lNfeOrd,aRecClasSD1,@nCounterSD1,cAliasSD1,cAliasSB1,@aRecSD1,@aRateio,cCpBasePIS,cCpValPIS,cCpAlqPIS,cCpBaseCOF,cCpValCOF,cCpAlqCOF,@aHeader,@aCols,l103Inclui,aHeadSDE,aColsSDE,@lContinua,,lTColab) },Inclui,/*aHeaderAux*/,/*aColsAux*/,/*bAfterCols*/,/*bbeforeCols*/,/*bAfterHeader*/,/*cAliasQry*/)
			EndIf
		Else
			FillGetDados(nOpcX,"SD1",1,/*cSeek*/,/*{|| &cWhile }*/,{||.T.},aNoFields,/*aYesFields*/,/*lOnlyYes*/,cQuery,{|| MontaaCols(bWhileSD1,lQuery,l103Class,lClassOrd,lNfeOrd,aRecClasSD1,@nCounterSD1,cAliasSD1,cAliasSB1,@aRecSD1,@aRateio,cCpBasePIS,cCpValPIS,cCpAlqPIS,cCpBaseCOF,cCpValCOF,cCpAlqCOF,@aHeader,@aCols,l103Inclui,aHeadSDE,aColsSDE,@lContinua) },Inclui,/*aHeaderAux*/,/*aColsAux*/,/*bAfterCols*/,/*bbeforeCols*/,/*bAfterHeader*/,/*cAliasQry*/)
        EndIf

		If lQuery
			DbSelectArea(cAliasSD1)
			dbCloseArea()
			DbSelectArea("SD1")
		EndIf
		If lContinua
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Compatibilizacao da Base X.07 p/ X.08       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !l103Inclui .And. !l103Class .And. !l103Visual .AND. Empty(SF1->F1_RECBMTO)
				MaFisAlt("NF_VALIRR",SF1->F1_IRRF,)
				MaFisAlt("NF_VALINS",SF1->F1_INSS,)
				MaFisAlt("NF_DESPESA",SF1->F1_DESPESA,)
				MaFisAlt("NF_FRETE",SF1->F1_FRETE,)
				MaFisAlt("NF_SEGURO",SF1->F1_SEGURO,)
			EndIf
			If !l103Inclui .And.!l103Class
				MaFisAlt("NF_FUNRURAL",SF1->F1_CONTSOC,)
			EndIf
			If !l103Inclui .And.!l103Visual .And. !l103Class
				MaFisAlt("NF_TOTAL",SF1->F1_VALBRUT,)
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Rateio do valores de Frete/Seguro/Despesa do PC            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !l103Class .Or. (!l103Inclui .And. SF1->F1_IMPORT <> 'S')
				If aRateio[1] <> 0
					MaFisAlt("NF_SEGURO",aRateio[1])
				EndIf
				If aRateio[2] <> 0
					MaFisAlt("NF_DESPESA",aRateio[2])
				EndIf
				If aRateio[3] <> 0
					MaFisAlt("NF_FRETE",aRateio[3])
				EndIf
				If aRateio[1]+aRateio[2]+aRateio[3] <> 0
					MaFisToCols(aHeader,aCols,,"MT100")
				EndIf
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta o Array contendo os Historico da NF                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !l103Inclui
				aHistor := A103Histor(SF1->(RecNo()))
			EndIf
		EndIf
	EndIf

	If (l103Inclui .Or. l103Class) .And. !l103Auto
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ PNEUAC - Ponto de Entrada definicao da Operacao            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock("MT103PN")
			If !Execblock("MT103PN",.F.,.F.,)
				lContinua := .F.
			EndIf
		EndIf
	EndIf
	If lContinua .And. !l103Auto .And. !Len(aCols) > 0
		lContinua := .F.
		Help(" ",1,"RECNO")
	EndIf
	If lContinua

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona na SC5 para natureza obrigatória p/ Devolução	   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Type("l103Devol") == "L"
			lDevol := l103Devol
		EndIf

		If SuperGetMV("MV_NFENAT",.F.,.F.) .And. "C5_NATUREZ" $ SuperGetMV("MV_1DUPNAT",.F.,"") .And. ( l103Class .Or. l103Auto .Or. lDevol)
			cKeySD2 := ""
			aAreaSD2x := SD2->(GetArea())
			SD2->(DbSetOrder(3))
			SD2->(DbGoTop())
			If l103Class .And. !Empty(SD1->D1_NFORI)
				cKeySD2 := xFilial("SD2")+SD1->D1_NFORI+SD1->D1_SERIORI+SD1->D1_FORNECE+SD1->D1_LOJA
			ElseIf lDevol
				cKeySD2 := xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA
			ElseIf l103Auto
				nPosForDev := aScan(aAutoCab,{|x| AllTrim(x[1]) == "F1_FORNECE"})
				nPosLojDev := aScan(aAutoCab,{|x| AllTrim(x[1]) == "F1_LOJA"})
				nPosNfOri  := aScan(aAutoItens[1],{|x| AllTrim(x[1]) == "D1_NFORI"})
				nPosSerOri := aScan(aAutoItens[1],{|x| AllTrim(x[1]) == "D1_SERIORI"})
				If nPosNfOri > 0 .And. nPosSerOri > 0 .And. nPosForDev > 0 .And. nPosLojDev > 0 .And. !Empty(aAutoItens[1][nPosNfOri][2])
					cKeySD2 := xFilial("SD2")+aAutoItens[1][nPosNfOri][2]+aAutoItens[1][nPosSerOri][2]+aAutoCab[nPosForDev][2]+aAutoCab[nPosLojDev][2]
				EndIf
			EndIf

			If !Empty(cKeySD2) .And. SD2->(DbSeek(cKeySD2))
				DbSelectArea("SC5")
				SC5->(DbSetOrder(3))
				SC5->(DbSeek(xFilial("SC5")+SD2->D2_CLIENTE+SD2->D2_LOJA+SD2->D2_PEDIDO))
			EndIf
			RestArea(aAreaSD2x)
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³********************A T E N C A O ***************************³
		//³Quando for feita manutencao em alguma VALIDACAO dos GETs,    ³
		//³atualize as funcoes que se encontram no array aValidGet      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( l103Auto )
			aValidGet := {}
			aVldBlock := {}
			aNFeAut	  := aClone(aNFEletr)
			aDanfe    := aClone(aNFEDanfe)
			aIISS	  := aClone(aInfISS)
			aAdd(aVldBlock,{||NFeTipo(cTipo,@cA100For,@cLoja)})
			aAdd(aVldBlock,{||NfeFormul(cFormul,@cNFiscal,@cSerie)})
			aAdd(aVldBlock,{||NfeFornece(cTipo,@cA100For,@cLoja,,@nCombo,@oCombo,@cCodRet,@oCodRet,@aCodR,@cRecIss).And.CheckSX3("F1_DOC")})
			aAdd(aVldBlock,{||NfeFornece(cTipo,@cA100For,@cLoja,,@nCombo,@oCombo,@cCodRet,@oCodRet,@aCodR,@cRecIss).And.CheckSX3("F1_SERIE")})
			aAdd(aVldBlock,{||CheckSX3('F1_EMISSAO') .And. NfeEmissao(dDEmissao)})
			aAdd(aVldBlock,{||NfeFornece(cTipo,@cA100For,@cLoja,@cUfOrig,@nCombo,@oCombo,@cCodRet,@oCodRet,@aCodR,@cRecIss).And.CheckSX3("F1_FORNECE",cA100For)})
			aAdd(aVldBlock,{||NfeFornece(cTipo,@cA100For,@cLoja,@cUfOrig,@nCombo,@oCombo,@cCodRet,@oCodRet,@aCodR,@cRecIss).And.CheckSX3("F1_LOJA",cLoja)})
			aAdd(aVldBlock,{||CheckSX3('F1_ESPECIE',cEspecie)})
			aAdd(aVldBlock,{||CheckSX3('F1_EST',cUfOrig)})
			aAdd(aVldBlock,{||Vazio(cNatureza).Or.(ExistCpo('SED',cNatureza).And.NfeVldRef("NF_NATUREZA",cNatureza)) .And. If(lMt103Nat,ExecBlock("MT103NAT",.F.,.F.,cNatureza),.T.)})
			For nX = 11 to 73
				aAdd(aVldBlock,"")
			Next nX

			If l103Inclui
				Aadd(aValidGet,{"cTipo"    ,aAutoCab[ProcH("F1_TIPO"),2],"Eval(aVldBlock[1])",.F.})
				Aadd(aValidGet,{"cFormul"  ,aAutoCab[ProcH("F1_FORMUL"),2],"Eval(aVldBlock[2])",.F.})
				Aadd(aValidGet,{"cNFiscal" ,aAutoCab[ProcH("F1_DOC"),2],"Eval(aVldBlock[3])",.F.})
				Aadd(aValidGet,{"cSerie"   ,aAutoCab[ProcH("F1_SERIE"),2],"Eval(aVldBlock[4])",.F.})
				Aadd(aValidGet,{"dDEmissao",aAutoCab[ProcH("F1_EMISSAO"),2],"Eval(aVldBlock[5])",.F.})
				Aadd(aValidGet,{"cA100For" ,aAutoCab[ProcH("F1_FORNECE"),2],"Eval(aVldBlock[6])",.F.})
				Aadd(aValidGet,{"cLoja"    ,aAutoCab[ProcH("F1_LOJA"),2],"Eval(aVldBlock[7])",.F.})
				Aadd(aValidGet,{"cEspecie" ,aAutoCab[ProcH("F1_ESPECIE"),2],"Eval(aVldBlock[8])",.F.})

				If lSubSerie .And. ProcH("F1_SUBSERI") > 0
					aVldBlock[73] := {||NfeFornece(cTipo,@cA100For,@cLoja,,@nCombo,@oCombo,@cCodRet,@oCodRet,@aCodR,@cRecIss).And.CheckSX3("F1_SUBSERI")}
					Aadd(aValidGet,{"cSubSerie",aAutoCab[ProcH("F1_SUBSERI"),2],"Eval(aVldBlock[73])",.F.})
				EndIf

				If ProcH("F1_MOEDA") > 0
					Aadd(aValidGet,{"nMoedaCor" ,aAutoCab[ProcH("F1_MOEDA"),2],"",.F.})
				EndIf

				If ProcH("F1_TXMOEDA") > 0
					Aadd(aValidGet,{"nTaxa"     ,aAutoCab[ProcH("F1_TXMOEDA"),2],"",.F.})
				EndIf

				If ProcH("F1_EST") > 0
					Aadd(aValidGet,{"cUfOrig"  ,aAutoCab[ProcH("F1_EST"),2],"Eval(aVldBlock[9])",.F.})
				EndIf

				If cPaisLoc == "BRA"
				    // NFE
					If ProcH("F1_NFELETR") > 0
						aVldBlock[11] := {||CheckSX3('F1_NFELETR',aNFeAut[01])}
						Aadd(aValidGet,{"aNFeAut[01]",aAutoCab[ProcH("F1_NFELETR"),2],"Eval(aVldBlock[11])",.F.})
						aNFEletr[01] := aAutoCab[ProcH("F1_NFELETR"),2]
					Endif
					If ProcH("F1_CODNFE") > 0
						aVldBlock[12] := {||CheckSX3('F1_CODNFE',aNFeAut[02])}
						Aadd(aValidGet,{"aNFeAut[02]",aAutoCab[ProcH("F1_CODNFE"),2],"Eval(aVldBlock[12])",.F.})
						aNFEletr[02] := aAutoCab[ProcH("F1_CODNFE"),2]
					Endif
					If ProcH("F1_EMINFE") > 0
						aVldBlock[13] := {||A103NFe('EMINFE',aNFeAut) .And. CheckSX3('F1_EMINFE',aNFeAut[03])}
						Aadd(aValidGet,{"aNFeAut[03]",aAutoCab[ProcH("F1_EMINFE"),2],"Eval(aVldBlock[13])",.F.})
						aNFEletr[03] := aAutoCab[ProcH("F1_EMINFE"),2]
					Endif
					If ProcH("F1_HORNFE") > 0
						aVldBlock[14] := {||CheckSX3('F1_HORNFE',aNFeAut[04])}
						Aadd(aValidGet,{"aNFeAut[04]",aAutoCab[ProcH("F1_HORNFE"),2],"Eval(aVldBlock[14])",.F.})
						aNFEletr[04] := aAutoCab[ProcH("F1_HORNFE"),2]
					Endif
					If ProcH("F1_CREDNFE") > 0
						aVldBlock[15] := {||A103NFe('CREDNFE',aNFeAut) .And. CheckSX3('F1_CREDNFE',aNFeAut[05])}
						Aadd(aValidGet,{"aNFeAut[05]",aAutoCab[ProcH("F1_CREDNFE"),2],"Eval(aVldBlock[15])",.F.})
						aNFEletr[05] := aAutoCab[ProcH("F1_CREDNFE"),2]
					Endif
					If ProcH("F1_NUMRPS") > 0
						aVldBlock[16] := {||CheckSX3('F1_NUMRPS',aNFeAut[06])}
						Aadd(aValidGet,{"aNFeAut[06]",aAutoCab[ProcH("F1_NUMRPS"),2],"Eval(aVldBlock[16])",.F.})
						aNFEletr[06] := aAutoCab[ProcH("F1_NUMRPS"),2]
					Endif
					If ProcH("F1_MENNOTA") > 0
						aVldBlock[29] := {||CheckSX3('F1_MENNOTA',aNFeAut[07])}
						Aadd(aValidGet,{"aNFeAut[07]",aAutoCab[ProcH("F1_MENNOTA"),2],"Eval(aVldBlock[29])",.F.})
						aNFEletr[07] := aAutoCab[ProcH("F1_MENNOTA"),2]
					Endif
					If ProcH("F1_MENPAD") > 0
						aVldBlock[64] := {||CheckSX3('F1_MENPAD',aNFeAut[08])}
						Aadd(aValidGet,{"aNFeAut[08]",aAutoCab[ProcH("F1_MENPAD"),2],"Eval(aVldBlock[64])",.F.})
						aNFEletr[08] := aAutoCab[ProcH("F1_MENPAD"),2]
					Endif

					//Danfe
						If ProcH("F1_TRANSP") > 0
		 					aVldBlock[17] := {|| ExistCpo("SA4",aDanfe[01],1,NIL,.T.)}
							Aadd(aValidGet,{"aDanfe[01]",aAutoCab[ProcH("F1_TRANSP"),2],"Eval(aVldBlock[17])",.F.})
							aNfeDanfe[01] := aAutoCab[ProcH("F1_TRANSP"),2]
						Endif

						If ProcH("F1_PLIQUI") > 0
		 					aVldBlock[18] := {||CheckSX3('F1_PLIQUI',aDanfe[02])}
							Aadd(aValidGet,{"aDanfe[02]",aAutoCab[ProcH("F1_PLIQUI"),2],"Eval(aVldBlock[18])",.F.})
							aNfeDanfe[02] := aAutoCab[ProcH("F1_PLIQUI"),2]
						Endif

						If ProcH("F1_PBRUTO") > 0
		 					aVldBlock[19] := {||CheckSX3('F1_PBRUTO',aDanfe[03])}
							Aadd(aValidGet,{"aDanfe[03]",aAutoCab[ProcH("F1_PBRUTO"),2],"Eval(aVldBlock[19])",.F.})
							aNfeDanfe[03] := aAutoCab[ProcH("F1_PBRUTO"),2]
						Endif

						If ProcH("F1_ESPECI1") > 0
	 						aVldBlock[20] := {||CheckSX3('F1_ESPECI1',aDanfe[04])}
							Aadd(aValidGet,{"aDanfe[04]",aAutoCab[ProcH("F1_ESPECI1"),2],"Eval(aVldBlock[20])",.F.})
							aNfeDanfe[04] := aAutoCab[ProcH("F1_ESPECI1"),2]
						Endif

						If ProcH("F1_VOLUME1") > 0
	 						aVldBlock[21] := {||CheckSX3('F1_VOLUME1',aDanfe[05])}
							Aadd(aValidGet,{"aDanfe[05]",aAutoCab[ProcH("F1_VOLUME1"),2],"Eval(aVldBlock[21])",.F.})
							aNfeDanfe[05] := aAutoCab[ProcH("F1_VOLUME1"),2]
						Endif

						If ProcH("F1_ESPECI2") > 0
	 						aVldBlock[22] := {||CheckSX3('F1_ESPECI2',aDanfe[06])}
							Aadd(aValidGet,{"aDanfe[06]",aAutoCab[ProcH("F1_ESPECI2"),2],"Eval(aVldBlock[22])",.F.})
							aNfeDanfe[06] := aAutoCab[ProcH("F1_ESPECI2"),2]
						Endif

						If ProcH("F1_VOLUME2") > 0
	 						aVldBlock[23] := {||CheckSX3('F1_VOLUME2',aDanfe[07])}
							Aadd(aValidGet,{"aDanfe[07]",aAutoCab[ProcH("F1_VOLUME2"),2],"Eval(aVldBlock[23])",.F.})
							aNfeDanfe[07] := aAutoCab[ProcH("F1_VOLUME2"),2]
						Endif

						If ProcH("F1_ESPECI3") > 0
	 						aVldBlock[24] := {||CheckSX3('F1_ESPECI3',aDanfe[08])}
							Aadd(aValidGet,{"aDanfe[08]",aAutoCab[ProcH("F1_ESPECI3"),2],"Eval(aVldBlock[24])",.F.})
							aNfeDanfe[08] := aAutoCab[ProcH("F1_ESPECI3"),2]
						Endif

						If ProcH("F1_VOLUME3") > 0
	 						aVldBlock[25] := {||CheckSX3('F1_VOLUME3',aDanfe[09])}
							Aadd(aValidGet,{"aDanfe[09]",aAutoCab[ProcH("F1_VOLUME3"),2],"Eval(aVldBlock[25])",.F.})
							aNfeDanfe[09] := aAutoCab[ProcH("F1_VOLUME3"),2]
						Endif

						If ProcH("F1_ESPECI4") > 0
	 						aVldBlock[26] := {||CheckSX3('F1_ESPECI4',aDanfe[10])}
							Aadd(aValidGet,{"aDanfe[10]",aAutoCab[ProcH("F1_ESPECI4"),2],"Eval(aVldBlock[26])",.F.})
							aNfeDanfe[10] := aAutoCab[ProcH("F1_ESPECI4"),2]
						Endif

						If ProcH("F1_VOLUME4") > 0
	 						aVldBlock[27] :=  {||CheckSX3('F1_VOLUME4',aDanfe[11])}
							Aadd(aValidGet,{"aDanfe[11]",aAutoCab[ProcH("F1_VOLUME4"),2],"Eval(aVldBlock[27])",.F.})
							aNfeDanfe[11] := aAutoCab[ProcH("F1_VOLUME4"),2]
						Endif

						If ProcH("F1_PLACA") > 0
	 						aVldBlock[28] := {||CheckSX3('F1_PLACA',aDanfe[12])}
							Aadd(aValidGet,{"aDanfe[12]",aAutoCab[ProcH("F1_PLACA"),2],"Eval(aVldBlock[28])",.F.})
							aNfeDanfe[12] := aAutoCab[ProcH("F1_PLACA"),2]
						Endif

						If ProcH("F1_CHVNFE") > 0
							If !l103GAuto	// Nao deve efetuar validacao da chave na importacao do XML ou no vinculo de pedidos de compra do TOTVS Colab (COMXCOL)
								aVldBlock[66] := {||CheckSX3('F1_CHVNFE',aDanfe[13])}
							Else
								aVldBlock[66] := {||CheckSX3('F1_CHVNFE',aDanfe[13]),A103ConsNfeSef()}
							EndIf
							Aadd(aValidGet,{"aDanfe[13]",aAutoCab[ProcH("F1_CHVNFE"),2],"Eval(aVldBlock[66])",.F.})
							aNfeDanfe[13] := aAutoCab[ProcH("F1_CHVNFE"),2]
						Endif

						If ProcH("F1_TPFRETE") > 0
		 					aVldBlock[30] := {||CheckSX3('F1_TPFRETE',aDanfe[14])}
							Aadd(aValidGet,{"aDanfe[14]",aAutoCab[ProcH("F1_TPFRETE"),2],"Eval(aVldBlock[30])",.F.})
							aNfeDanfe[14] := aAutoCab[ProcH("F1_TPFRETE"),2]
						Endif

						If ProcH("F1_VALPEDG") > 0
	 						aVldBlock[31] := {||CheckSX3('F1_VALPEDG',aDanfe[15])}
							Aadd(aValidGet,{"aDanfe[15]",aAutoCab[ProcH("F1_VALPEDG"),2],"Eval(aVldBlock[31])",.F.})
							aNfeDanfe[15] := aAutoCab[ProcH("F1_VALPEDG"),2]
						Endif

						If ProcH("F1_FORRET") > 0
	 						aVldBlock[32] := {||CheckSX3('F1_FORRET',aDanfe[16])}
							Aadd(aValidGet,{"aDanfe[16]",aAutoCab[ProcH("F1_FORRET"),2],"Eval(aVldBlock[32])",.F.})
							aNfeDanfe[16] := aAutoCab[ProcH("F1_FORRET"),2]
						Endif

						If ProcH("F1_LOJARET") > 0
	 						aVldBlock[33] := {||CheckSX3('F1_LOJARET',aDanfe[17])}
							Aadd(aValidGet,{"aDanfe[17]",aAutoCab[ProcH("F1_LOJARET"),2],"Eval(aVldBlock[33])",.F.})
							aNfeDanfe[17] := aAutoCab[ProcH("F1_LOJARET"),2]
						Endif

						If ProcH("F1_TPCTE") > 0
		 					aVldBlock[34] := {||CheckSX3('F1_TPCTE',aDanfe[18])}
							Aadd(aValidGet,{"aDanfe[18]",aAutoCab[ProcH("F1_TPCTE"),2],"Eval(aVldBlock[34])",.F.})
							aNfeDanfe[18] := aAutoCab[ProcH("F1_TPCTE"),2]
						Endif

						If ProcH("F1_FORENT") > 0
	 						aVldBlock[35] := {||CheckSX3('F1_FORENT',aDanfe[19])}
							Aadd(aValidGet,{"aDanfe[19]",aAutoCab[ProcH("F1_FORENT"),2],"Eval(aVldBlock[35])",.F.})
							aNfeDanfe[19] := aAutoCab[ProcH("F1_FORENT"),2]
						Endif

						If ProcH("F1_LOJAENT") > 0
	 						aVldBlock[36] := {||CheckSX3('F1_LOJAENT',aDanfe[20])}
							Aadd(aValidGet,{"aDanfe[20]",aAutoCab[ProcH("F1_LOJAENT"),2],"Eval(aVldBlock[36])",.F.})
							aNfeDanfe[20] := aAutoCab[ProcH("F1_LOJAENT"),2]
						Endif

						If ProcH("F1_NUMAIDF") > 0
	 						aVldBlock[37] := {||CheckSX3('F1_NUMAIDF',aDanfe[21])}
							Aadd(aValidGet,{"aDanfe[21]",aAutoCab[ProcH("F1_NUMAIDF"),2],"Eval(aVldBlock[37])",.F.})
							aNfeDanfe[21] := aAutoCab[ProcH("F1_NUMAIDF"),2]
						Endif

						If ProcH("F1_ANOAIDF") > 0
	 						aVldBlock[38] := {||CheckSX3('F1_ANOAIDF',aDanfe[22])}
							Aadd(aValidGet,{"aDanfe[22]",aAutoCab[ProcH("F1_ANOAIDF"),2],"Eval(aVldBlock[38])",.F.})
							aNfeDanfe[22] := aAutoCab[ProcH("F1_ANOAIDF"),2]
						Endif

						If ProcH("F1_MODAL") > 0
							aVldBlock[65] := {||CheckSX3('F1_MODAL',aDanfe[23])}
							Aadd(aValidGet,{"aDanfe[23]",aAutoCab[ProcH("F1_MODAL"),2],"Eval(aVldBlock[65])",.F.})
							aNfeDanfe[23] := aAutoCab[ProcH("F1_MODAL"),2]
						Endif

						If ProcH("F1_DEVMERC") > 0
							aVldBlock[67] := {||CheckSX3('F1_DEVMERC',aDanfe[24])}
							Aadd(aValidGet,{"aDanfe[24]",aAutoCab[ProcH("F1_DEVMERC"),2],"Eval(aVldBlock[67])",.F.})
							If ProcH("F1_TIPO") > 0 .And. aAutoCab[ProcH("F1_TIPO"),2] $ "DBN" .And. ProcH("F1_FORMUL") > 0 .And. aAutoCab[ProcH("F1_FORMUL"),2] == "S"
								aNfeDanfe[24] := aAutoCab[ProcH("F1_DEVMERC"),2]
							Else
								aNfeDanfe[24] := " "
							EndIf
						EndIf
					// Informacoes adicionais
					If ProcH("F1_INCISS") > 0
 						aVldBlock[56] := {||CheckSX3('F1_INCISS',aInfAdic[01])}
						Aadd(aValidGet,{"aInfAdic[01]",aAutoCab[ProcH("F1_INCISS"),2],"Eval(aVldBlock[56])",.F.})
						aInfAdic[01] := aAutoCab[ProcH("F1_INCISS"),2]
					EndIf

					If ProcH("F1_VEICUL1") > 0
 						aVldBlock[57] := {||CheckSX3('F1_VEICUL1',aInfAdic[02])}
						Aadd(aValidGet,{"aInfAdic[02]",aAutoCab[ProcH("F1_VEICUL1"),2],"Eval(aVldBlock[57])",.F.})
						aInfAdic[02] := aAutoCab[ProcH("F1_VEICUL1"),2]
					EndIf

					If ProcH("F1_VEICUL2") > 0
 						aVldBlock[58] := {||CheckSX3('F1_VEICUL2',aInfAdic[03])}
						Aadd(aValidGet,{"aInfAdic[03]",aAutoCab[ProcH("F1_VEICUL2"),2],"Eval(aVldBlock[58])",.F.})
						aInfAdic[03] := aAutoCab[ProcH("F1_VEICUL2"),2]
					EndIf

					If ProcH("F1_VEICUL3") > 0
 						aVldBlock[59] := {||CheckSX3('F1_VEICUL3',aInfAdic[04])}
						Aadd(aValidGet,{"aInfAdic[04]",aAutoCab[ProcH("F1_VEICUL3"),2],"Eval(aVldBlock[59])",.F.})
						aInfAdic[04] := aAutoCab[ProcH("F1_VEICUL3"),2]
					EndIf

					If ProcH("F1_DTCPISS") > 0
						aVldBlock[60] := {||CheckSX3('F1_DTCPISS',aInfAdic[05])}
						Aadd(aValidGet,{"aInfAdic[05]",aAutoCab[ProcH("F1_DTCPISS"),2],"Eval(aVldBlock[60])",.F.})
						aInfAdic[05] := aAutoCab[ProcH("F1_DTCPISS"),2]
					EndIf

					If ProcH("F1_SIMPNAC") > 0
 						aVldBlock[61] := {||CheckSX3('F1_SIMPNAC',aInfAdic[06])}
						Aadd(aValidGet,{"aInfAdic[06]",aAutoCab[ProcH(F1_SIMPNAC),2],"Eval(aVldBlock[61])",.F.})
						aInfAdic[06] := aAutoCab[ProcH("F1_SIMPNAC"),2]
					EndIf

					If ProcH("F1_CLIDEST") > 0
						aVldBlock[62] := {||CheckSX3('F1_CLIDEST',aInfAdic[07])}
						Aadd(aValidGet,{"aInfAdic[07]",aAutoCab[ProcH("F1_CLIDEST"),2],"Eval(aVldBlock[62])",.F.})
						aInfAdic[07] := aAutoCab[ProcH("F1_CLIDEST"),2]
					EndIf

					If ProcH("F1_LOJDEST") > 0
						aVldBlock[63] := {||CheckSX3('F1_LOJDEST',aInfAdic[08])}
						Aadd(aValidGet,{"aInfAdic[08]",aAutoCab[ProcH("F1_LOJDEST"),2],"Eval(aVldBlock[63])",.F.})
						aInfAdic[08] := aAutoCab[ProcH("F1_LOJDEST"),2]
					EndIf

					If ProcH("F1_ESTDES") > 0
						aVldBlock[68] := {||CheckSX3("F1_ESTDES",aInfAdic[09])}
						Aadd(aValidGet,{"aInfAdic[09]",aAutoCab[ProcH("F1_ESTDES"),2],"Eval(aVldBlock[68])",.F.})
						aInfAdic[09] := aAutoCab[ProcH("F1_ESTDES"),2]
					EndIf

					If ProcH("F1_UFORITR") > 0
						aVldBlock[69] := {||CheckSX3('F1_UFORITR',aInfAdic[10])}
						Aadd(aValidGet,{"aInfAdic[10]",aAutoCab[ProcH("F1_UFORITR"),2],"Eval(aVldBlock[69])",.F.})
						aInfAdic[10] := aAutoCab[ProcH("F1_UFORITR"),2]
						MaFisAlt("NF_UFORIGEM",aInfAdic[10])
					EndIf

					If ProcH("F1_MUORITR") > 0
						aVldBlock[70] := {||CheckSX3('F1_MUORITR',aInfAdic[11])}
						Aadd(aValidGet,{"aInfAdic[11]",aAutoCab[ProcH("F1_MUORITR"),2],"Eval(aVldBlock[70])",.F.})
						aInfAdic[11] := aAutoCab[ProcH("F1_MUORITR"),2]
					EndIf

					If ProcH("F1_UFDESTR") > 0
						aVldBlock[71] := {||CheckSX3('F1_UFDESTR',aInfAdic[12])}
						Aadd(aValidGet,{"aInfAdic[12]",aAutoCab[ProcH("F1_UFDESTR"),2],"Eval(aVldBlock[71])",.F.})
						aInfAdic[12] := aAutoCab[ProcH("F1_UFDESTR"),2]
						MaFisAlt("NF_UFDEST",aInfAdic[12])
					EndIf

					If ProcH("F1_MUDESTR") > 0
						aVldBlock[72] := {||CheckSX3('F1_MUDESTR',aInfAdic[13])}
						Aadd(aValidGet,{"aInfAdic[13]",aAutoCab[ProcH("F1_MUDESTR"),2],"Eval(aVldBlock[72])",.F.})
						aInfAdic[13] := aAutoCab[ProcH("F1_MUDESTR"),2]
					EndIf

					If cPaisLoc = "BRA" .And. lISSxMun .And. Ascan(aAutoCab,{|x| x[1] == 'A2_COD_MUN'}) > 0
						//DADOS DO MUNICIPIO
						aVldBlock[39] := {||CheckSX3('A2_COD_MUN',aIISS[1][1])}
						Aadd(aValidGet,{"aIISS[1][1]",aAutoCab[ProcH("A2_COD_MUN"),2],"Eval(aVldBlock[39])",.F.})
						aInfISS[1][1] := aAutoCab[ProcH("A2_COD_MUN"),2]

						aVldBlock[40] := {||CheckSX3('CC2_MUN',aIISS[1][2])}
						Aadd(aValidGet,{"aIISS[1][2]",aAutoCab[ProcH("CC2_MUN"),2],"Eval(aVldBlock[40])",.F.})
						aInfISS[1][2] := aAutoCab[ProcH("CC2_MUN"),2]

						aVldBlock[41] := {||CheckSX3('CC2_EST',aIISS[1][3])}
						Aadd(aValidGet,{"aIISS[1][3]",aAutoCab[ProcH("CC2_EST"),2],"Eval(aVldBlock[41])",.F.})
						aInfISS[1][3] := aAutoCab[ProcH("CC2_EST"),2]

						aVldBlock[42] := {||CheckSX3('CC2_MDEDMA',aIISS[1][4])}
						Aadd(aValidGet,{"aIISS[1][4]",aAutoCab[ProcH("CC2_MDEDMA"),2],"Eval(aVldBlock[42])",.F.})
						aInfISS[1][4] := aAutoCab[ProcH("CC2_MDEDMA"),2]

						aVldBlock[43] := {||CheckSX3('CC2_MDEDSR',aIISS[1][5])}
						Aadd(aValidGet,{"aIISS[1][5]",aAutoCab[ProcH("CC2_MDEDSR"),2],"Eval(aVldBlock[43])",.F.})
						aInfISS[1][5] := aAutoCab[ProcH("CC2_MDEDSR"),2]

						aVldBlock[44] := {||CheckSX3('CC2_PERMAT',aIISS[1][6])}
						Aadd(aValidGet,{"aIISS[1][6]",aAutoCab[ProcH("CC2_PERMAT"),2],"Eval(aVldBlock[44])",.F.})
						aInfISS[1][6] := aAutoCab[ProcH("CC2_PERMAT"),2]

						aVldBlock[45] := {||CheckSX3('CC2_PERSER',aIISS[1][7])}
						Aadd(aValidGet,{"aIISS[1][7]",aAutoCab[ProcH("CC2_PERSER"),2],"Eval(aVldBlock[45])",.F.})
						aInfISS[1][7] := aAutoCab[ProcH("CC2_PERSER"),2]

						//ISS APURADO
						aVldBlock[46] := {||CheckSX3('D1_TOTAL',aIISS[2][1])}
						Aadd(aValidGet,{"aIISS[2][1]",aAutoCab[ProcH("D1_TOTAL"),2],"Eval(aVldBlock[46])",.F.})
						aInfISS[2][1] := aAutoCab[ProcH("D1_TOTAL"),2]

						aVldBlock[47] := {||CheckSX3('D1_ABATISS',aIISS[2][2])}
						Aadd(aValidGet,{"aIISS[2][2]",aAutoCab[ProcH("D1_ABATISS"),2],"Eval(aVldBlock[47])",.F.})
						aInfISS[2][2] := aAutoCab[ProcH("D1_ABATISS"),2]

						aVldBlock[48] := {||CheckSX3('D1_ABATMAT',aIISS[2][3])}
						Aadd(aValidGet,{"aIISS[2][3]",aAutoCab[ProcH("D1_ABATMAT"),2],"Eval(aVldBlock[48])",.F.})
						aInfISS[2][3] := aAutoCab[ProcH("D1_ABATMAT"),2]

						aVldBlock[49] := {||CheckSX3('D1_BASEISS',aIISS[2][4])}
						Aadd(aValidGet,{"aIISS[2][4]",aAutoCab[ProcH("D1_BASEISS"),2],"Eval(aVldBlock[49])",.F.})
						aInfISS[2][4] := aAutoCab[ProcH("D1_BASEISS"),2]

						aVldBlock[50] := {||CheckSX3('D1_VALISS',aIISS[2][5])}
						Aadd(aValidGet,{"aIISS[2][5]",aAutoCab[ProcH("D1_VALISS"),2],"Eval(aVldBlock[50])",.F.})
						aInfISS[2][5] := aAutoCab[ProcH("D1_VALISS"),2]

						//INSS APURADO
						aVldBlock[51] := {||CheckSX3('D1_TOTAL',aIISS[3][1])}
						Aadd(aValidGet,{"aIISS[3][1]",aAutoCab[ProcH("D1_TOTAL"),2],"Eval(aVldBlock[51])",.F.})
						aInfISS[3][1] := aAutoCab[ProcH("D1_TOTAL"),2]

						aVldBlock[52] := {||CheckSX3('D1_ABATINS',aIISS[3][2])}
						Aadd(aValidGet,{"aIISS[3][2]",aAutoCab[ProcH("D1_ABATINS"),2],"Eval(aVldBlock[52])",.F.})
						aInfISS[3][2] := aAutoCab[ProcH("D1_ABATINS"),2]

						aVldBlock[53] := {||CheckSX3('D1_AVLINSS',aIISS[3][3])}
						Aadd(aValidGet,{"aIISS[3][3]",aAutoCab[ProcH("D1_AVLINSS"),2],"Eval(aVldBlock[53])",.F.})
						aInfISS[3][3] := aAutoCab[ProcH("D1_AVLINSS"),2]

						aVldBlock[54] := {||CheckSX3('D1_BASEINS',aIISS[3][4])}
						Aadd(aValidGet,{"aIISS[3][4]",aAutoCab[ProcH("D1_BASEINS"),2],"Eval(aVldBlock[54])",.F.})
						aInfISS[3][4] := aAutoCab[ProcH("D1_BASEINS"),2]

						aVldBlock[55] := {||CheckSX3('D1_VALINS',aIISS[3][5])}
						Aadd(aValidGet,{"aIISS[3][5]",aAutoCab[ProcH("D1_VALINS"),2],"Eval(aVldBlock[55])",.F.})
						aInfISS[3][5] := aAutoCab[ProcH("D1_VALINS"),2]
					EndIf
				Endif

				If !lWhenGet
					nOpc := 1
				EndIf
				If !SF1->(MsVldGAuto(aValidGet))
					nOpc := 0
				EndIf
				If ProcH("F1_COND") > 0
					cCondicao := aAutoCab[ProcH("F1_COND"),2]
				EndIf

				If ProcH("F1_RECISS") > 0
					cRecIss := aAutoCab[ProcH("F1_RECISS"),2]
				EndIf

				If ( nOpc == 1 .Or. lWhenGet ) .And. l103Inclui
					If cPaisLoc == "BRA" .And. SF1->(ColumnPos("F1_CLIDEST")) > 0 .And. SF1->(ColumnPos("F1_LOJDEST")) > 0 .AND. ProcH("F1_CLIDEST") > 0 .And. ProcH("F1_LOJDEST") > 0
						MaFisIni(cA100For,cLoja,IIf(cTipo$'DB',"C","F"),cTipo,Nil,MaFisRelImp("MT100",{"SF1","SD1"}),,IIf(lWhenGet,.T.,.F.),,,,,,,,,,,,,,,,,dDEmissao,,,,,,aAutoCab[ProcH("F1_CLIDEST"),2],aAutoCab[ProcH("F1_LOJDEST"),2],lTrbGen)

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Atualiza UF de Destino apos a inicializacao das rotinas fiscais³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If cPaisLoc == "BRA" .And. SF1->(ColumnPos("F1_ESTDES")) > 0
							If ProcH("F1_ESTDES") > 0 .AND. !Empty(aAutoCab[ProcH("F1_ESTDES"),2])
								MaFisAlt("NF_UFCDEST", aAutoCab[ProcH("F1_ESTDES"),2])
							EndIf
						EndIf
					Else
						MaFisIni(cA100For,cLoja,IIf(cTipo$'DB',"C","F"),cTipo,Nil,MaFisRelImp("MT100",{"SF1","SD1"}),,IIf(lWhenGet,.T.,.F.),,,,,,,,,,,,,,,,,dDEmissao,,,,,,,,lTrbGen)
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza UF de Origem apos a inicializacao das rotinas fiscais ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					MaFisAlt("NF_UFORIGEM",cUfOrig)
				Else
					If cPaisLoc == "BRA" .And. SF1->(ColumnPos("F1_CLIDEST")) > 0 .And. SF1->(ColumnPos("F1_LOJDEST")) > 0
						If ProcH("F1_CLIDEST") > 0 .And. ProcH("F1_LOJDEST") > 0;
							.and. !Empty(aAutoCab[ProcH("F1_CLIDEST"),2]) .and. !Empty(aAutoCab[ProcH("F1_LOJDEST"),2])
							MaFisAlt("NF_CLIDEST", aAutoCab[ProcH("F1_CLIDEST"),2])
							MaFisAlt("NF_LOJDEST", aAutoCab[ProcH("F1_LOJDEST"),2])
						EndIf
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza UF de Destino apos a inicializacao das rotinas fiscais³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If cPaisLoc == "BRA" .And. SF1->(ColumnPos("F1_ESTDES")) > 0
						If ProcH("F1_ESTDES") > 0 .AND. !Empty(aAutoCab[ProcH("F1_ESTDES"),2])
							MaFisAlt("NF_UFCDEST", aAutoCab[ProcH("F1_ESTDES"),2])
						EndIf
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza UF de Origem apos a inicializacao das rotinas fiscais ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					MaFisAlt("NF_UFORIGEM",cUfOrig)
				EndIf

				//ATENÇÃO!! ATENÇÃO!! ATENÇÃO!! ATENÇÃO!! ATENÇÃO!! ATENÇÃO!!
				//CAMPOS QUE RECRIAM ARRAY DA MAFIS: "NF_CODCLIFOR/NF_LOJA/NF_TIPONF/NF_OPERNF/NF_CLIFOR/NF_NATUREZA/NF_CLIDEST/NF_LOJDEST/NF_TPFRETE"

				If cPaisLoc == "BRA" .And. SF1->(ColumnPos("F1_UFORITR")) > 0 .And. SF1->(ColumnPos("F1_UFDESTR")) > 0
					If ProcH("F1_UFORITR") > 0 .And. !Empty(aAutoCab[ProcH("F1_UFORITR"),2])
						MaFisAlt("NF_UFORIGEM",aAutoCab[ProcH("F1_UFORITR"),2])
					Endif

					If ProcH("F1_UFDESTR") > 0 .And. !Empty(aAutoCab[ProcH("F1_UFDESTR"),2])
						MaFisAlt("NF_UFDEST",aAutoCab[ProcH("F1_UFDESTR"),2])
					Endif
				Endif

				//Preenche o tipo de complemento
				If cPaisLoc == "BRA" .And. cTipo == "C" .And. SF1->(ColumnPos("F1_TPCOMPL")) > 0 .And. ProcH("F1_TPCOMPL") > 0 .And. aAutoCab[ProcH("F1_TPCOMPL"),2] $ "123" .And. !Empty(MaFisScan("NF_TPCOMPL",.F.))
					cTpCompl := aAutoCab[ProcH("F1_TPCOMPL"),2]
					MaFisAlt("NF_TPCOMPL", cTpCompl)
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza Especie do documento apos a inicializacao das rotinas fiscais ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If(Type("cEspecie")<>"U" .And. cEspecie<>Nil)
					MaFisAlt("NF_ESPECIE",cEspecie)
				EndIf
			Else
				If ALTERA .and. (cPaisLoc == "BRA") .and. (ProcH("F1_CHVNFE") > 0)
 					aVldBlock[66] := {||CheckSX3('F1_CHVNFE',aDanfe[13])}
					Aadd(aValidGet,{"aDanfe[13]",aAutoCab[ProcH("F1_CHVNFE"),2],"Eval(aVldBlock[66])",.F.})
					aNfeDanfe[13] := aAutoCab[ProcH("F1_CHVNFE"),2]
				Endif
				nOpc := 1
			EndIf
			If nOpc == 1 .Or. lWhenGet
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica o preenchimento do campo D1_ITEM                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cItem := StrZero(1,Len(SD1->D1_ITEM))
				For nX := 1 To Len(aAutoItens)
					nY := aScan(aAutoItens[nX],{|x| AllTrim(x[1])=="D1_ITEM"})
					If nY == 0
						aSize(aAutoItens[nX],Len(aAutoItens[nX])+1)
						For nLoop := Len(aAutoItens[nX]) To 2 STEP -1
							aAutoItens[nX][nLoop]	:=	aAutoItens[nX][nLoop-1]
						Next nLoop
						aAutoItens[nX][1] := {"D1_ITEM", cItem, Nil}
					EndIf
					cItem := Soma1(cItem)

					// Verifica notas de remessa de entrega futura.
					nY := aScan(aAutoItens[nX], {|x| AllTrim(x[1]) == "AUT_ENTFUT"})
					If nY > 0
						aSize(aCompFutur, Len(aAutoItens))
						aCompFutur[nX] := aAutoItens[nX, nY, 2]
					EndIf

				Next nX
				If !Empty( ProcH( "E2_NATUREZ" )) 
					cNatureza := aAutoCab[ProcH("E2_NATUREZ"),2]
					Eval(aVldBlock[10])
				EndIf
				If l103Class .And. ProcH("F1_COND") > 0
					cCondicao := aAutoCab[ProcH("F1_COND"),2]
				EndIf
				If GetMV("MV_INTPMS",,"N") == "S"
					If GetMV("MV_PMSIPC",,2) == 1 //Se utiliza amarracao automatica dos itens da NFE com o Projeto
						For nX := 1 To Len(aAutoItens)
							PMS103IPC(Val(aAutoItens[nX][aScan(aAutoItens[nX],{|x| AllTrim(x[1])=="D1_ITEM"})][2]))
						Next nX
					Else
						If Empty(aAutoAFN)
							lRatAFN := .F.
						EndIf
						For nX := 1 To Len(aAutoAFN)
							If lRatAFN
								lRatAFN := !Empty(aAutoAFN[nX])
							EndIf
						Next nX
						If lRatAFN
							For nX := 1 To Len(aAutoItens)
								aRatAFN := aClone(aAutoAFN)
								If !PmsVldAFN(Val(aAutoItens[nX][aScan(aAutoItens[nX],{|x| AllTrim(x[1])=="D1_ITEM"})][2]))//Se as validacoes estiverem ok, continua o processo de amarracao
									aRatAFN := {}
									Exit
								EndIf
							Next nX
						EndIf
					EndIf
				EndIf

				// Tratamento para valores de aposentadoria especial recebidos via rotina automatica
				If ChkFile("DHP") .And. Len(aAposEsp) > 0
					A103Aposen(@aHeadDHP,@aColsDHP,.T.,.T.,aAposEsp)
				EndIf

				If l103GAuto
					If !MsGetDAuto(aAutoItens,"A103LinOk",{|| A103TudOk()},aAutoCab,aRotina[nOpcx][4])
						If lWhenGet
							If !IsBlind()
								MostraErro()
							Else
								Aviso("","",{""}, 2)
							EndIf
							lProcGet := .F.
						EndIf
						nOpc := 0
					EndIf
				Else	// l103GAuto = .F. -> Chamada via Totvs Colaboracao apenas para atualizar impostos, nao e necessario passar por A103LinOk/A103TudOk
					If !MsGetDAuto(aAutoItens,,,aAutoCab,aRotina[nOpcx][4])
						nOpc := 0
					EndIf
				EndIf
				
				If l103Auto .And. l103Exclui .And. ExistBlock("MT103EXC")
					lVldExc := ExecBlock("MT103EXC",.F.,.F.)
					If ValType(lVldExc) == "L"
						lRet := lVldExc
						If !lVldExc
							nOpc := 0
						Endif
					EndIf
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-¿
				//³ Se o item estiver amarrado a um PC com rateio, copia rateio.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-Ù
				If l103Auto
					nPosPC		:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_PEDIDO"})
					nPosItPC  	:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_ITEMPC"})
					nPosRat  	:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_RATEIO"})
					nPosItNF	:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_ITEM"})
					If nPosPC > 0 .And. nPosItPc > 0 .And. nPosRat > 0
						If Empty(aHeadSDE)
							dbSelectArea("SX3")
							dbSetOrder(1)
							MsSeek("SDE")
							While !EOF() .And. (SX3->X3_ARQUIVO == "SDE")
								IF X3USO(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL .And. !"DE_CUSTO"$SX3->X3_CAMPO
									AADD(aHeadSDE,{ TRIM(x3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT } )
								EndIf
								dbSelectArea("SX3")
								dbSkip()
							EndDo
							ADHeadRec("SDE",aHeadSDE)
						EndIf
						dbSelectArea("SC7") 
						SC7->(dbSetOrder(1))
						For nX := 1 To Len(aCols)
							If !Empty(aCols[nX][nPosPC]) .And. !Empty(aCols[nX][nPosItPC]) .And. aCols[nX][nPosRat] == "1"
								If SC7->(MsSeek(xFilial("SC7")+aCols[nX][nPosPC]+aCols[nX][nPosItPC]))
									RatPed2NF(aHeadSDE,@aColsSDE,aCols[nX][nPosItNF],SC7->(RecNo()))
								EndIf
							ElseIf !Empty(aRateioCC) .And. aCols[nX][nPosRat] == "1"
								RatPed2NF(aHeadSDE,@aColsSDE,aCols[nX][nPosItNF],0,aRateioCC)
							EndIf
						Next nX
					EndIf
				EndIf

				For nX := 1 to Len(aAutoImp)
					If Len(aAutoImp[nX]) > 2
						MaFisAlt(aAutoImp[nX][1],aAutoImp[nX][2], aAutoImp[nX][3],,,,,Iif(Len(aAutoImp[nX]) >= 4, aAutoImp[nX][4],Nil))
					Else
						MaFisAlt(aAutoImp[nX][1],aAutoImp[nX][2])
					EndIf
				Next nX
				For nX := 1 to Len(aAutoImp)
					If SubStr(aAutoImp[nX][1],1,2) == "LF"
						MaFisLoad(aAutoImp[nX][1],aAutoImp[nX][2],aAutoImp[nX][3])
					EndIf
				Next nX
				If !cTipo$"PI" .and. ProcH("F1_DESCONT") > 0
					MaFisAlt("NF_DESCONTO",aAutoCab[ProcH("F1_DESCONT"),2])
				EndIf
				If ProcH("F1_DESPESA") > 0
					MaFisAlt("NF_DESPESA",aAutoCab[ProcH("F1_DESPESA"),2])
				EndIf
				If ProcH("F1_SEGURO") > 0
					MaFisAlt("NF_SEGURO",aAutoCab[ProcH("F1_SEGURO"),2])
				EndIf
				If ProcH("F1_FRETE") > 0
					MaFisAlt("NF_FRETE",aAutoCab[ProcH("F1_FRETE"),2])
				EndIf
				If ProcH("F1_BASEICM") > 0
					MaFisAlt("NF_BASEICM",aAutoCab[ProcH("F1_BASEICM"),2])
				EndIf
				If ProcH("F1_VALICM") > 0
					MaFisAlt("NF_VALICM",aAutoCab[ProcH("F1_VALICM"),2])
				EndIf
				If ProcH("F1_BASEIPI") > 0
					MaFisAlt("NF_BASEIPI",aAutoCab[ProcH("F1_BASEIPI"),2])
				EndIf
				If ProcH("F1_VALIPI") > 0
					MaFisAlt("NF_VALIPI",aAutoCab[ProcH("F1_VALIPI"),2])
				EndIf
				If ProcH("F1_BRICMS") > 0
					MaFisAlt("NF_BASESOL",aAutoCab[ProcH("F1_BRICMS"),2])
				EndIf
				If ProcH("F1_ICMSRET") > 0
					MaFisAlt("NF_VALSOL",aAutoCab[ProcH("F1_ICMSRET"),2])
				EndIf
				If ProcH("F1_RECISS") > 0
					MaFisAlt("NF_RECISS",aAutoCab[ProcH("F1_RECISS"),2])
				EndIf

				// Tratamento para valores de aposentadoria especial recebidos via rotina automatica
				If nOpc == 1 .And. ChkFile("DHP") .And. Len(aHeadDHP) > 0 .And. Len(aColsDHP) > 0
					A103AtuApos(aHeadDHP,aColsDHP)
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Ajusta os dados de acordo com a nota fiscal original         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lWhenGet
					Ascan(aAutoItens,{|X| !Empty( nPosRec := Ascan(  x, { |Y| Alltrim( y[1] ) == "D1RECNO"}))} )
					If nPosRec > 0
						For nX := 1 to Len(aAutoItens)
							nPosRec := Ascan(aAutoItens[nX], { |y| Alltrim( y[1] ) == "D1RECNO"})
							MaFisAlt("IT_RECORI",aAutoItens[nX,nPosRec,2],nX)
							MaFisAlt("NF_UFORIGEM",SF2->F2_EST)
						Next
						MaFisToCols(aHeader,aCols,Len(aCols),'MT100')
					Endif
				Endif

				If nOpc == 1 .Or. lWhenGet
					NfeFldFin(,l103Visual,aRecSE2,0,aRecSE1,@aHeadSE2,@aColsSE2,@aHeadSEV,@aColsSEV,@aFldCbAtu[6],NIL,@cModRetPIS,lPccBaixa,@lTxNeg,@cNatureza,@nTaxaMoeda,@aColTrbGen,@nColsSE2,@aParcTrGen)
					aColsNF:= aClone(aCols) 
					Eval(aFldCbAtu[6])
					Eval(bRefresh,6,6)
				EndIf
			EndIf
			If lWhenGet
				l103Auto := .F.
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicializa a gravacao dos lancamentos do SIGAPCO          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		PcoIniLan("000054")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Montagem da Tela da Nota fiscal de entrada                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (!l103Auto .Or. lWhenGet) .And. lProcGet

			aSizeAut	:= MsAdvSize(,.F.,400)
			aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }

			aPosGet := MsObjGetPos(aSizeAut[3]-aSizeAut[1],310,;
				{If(cPaisLoc<>"PTG",If(lSubSerie,{8,30,72,92,130,150,180,200,235,250,275,295},{8,35,75,100,140,165,194,220,260,280}),{8,35,78,100,140,160,200,230,250,270}),;
				If( l103Visual .Or. l103Class .Or. !lConsMedic,{8,35,75,100,nPosGetLoja,194,220,260,280},{8,35,75,108,135,160,190,220,244,265} ) ,;
				{5,70,160,205,295},;
				{6,34,200,215},;
				{6,34,75,103,148,164,230,253},;
				{6,34,200,218,280},;
				{11,50,150,190},;
				{273,130,190,293,205},;
				{005,025,065,085,125,145,185,205,250,275},;
				{11,35,80,110,165,190},;
				{3,35,95,150,205,255,170,230,265,;
				55,115,155,217,185,245,280,167,222,272},;
				{3, 4}}) // 12 - Folder Informações Adicionais

			DEFINE MSDIALOG oDlg FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] TITLE cTituloDlg Of oMainWnd PIXEL //"Documento de Entrada"

			oSize := FwDefSize():New(.T.,,,oDlg)

			oSize:AddObject('HEADER',100,40,.T.,.F.)
			oSize:AddObject('GRID'  ,100,10,.T.,.T.)
			oSize:AddObject('FOOT'  ,100,90,.T.,.F.)

			oSize:aMargins 	:= { 3, 3, 3, 3 }
			oSize:Process()

			aAdd(aPosObj,{oSize:GetDimension('HEADER', 'LININI'),oSize:GetDimension('HEADER', 'COLINI'),oSize:GetDimension('HEADER', 'LINEND'),oSize:GetDimension('HEADER', 'COLEND')})
			aAdd(aPosObj,{oSize:GetDimension('GRID'  , 'LININI'),oSize:GetDimension('GRID'  , 'COLINI'),oSize:GetDimension('GRID'  , 'LINEND'),oSize:GetDimension('GRID'  , 'COLEND')})
			aAdd(aPosObj,{oSize:GetDimension('FOOT'  , 'LININI'),oSize:GetDimension('FOOT'  , 'COLINI'),oSize:GetDimension('FOOT'  , 'LINEND'),oSize:GetDimension('FOOT'  , 'COLEND')})

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Objeto criado para receber o foco quando pressionado o botao confirma ³
			//³ da dialog. Usado para identificar quando foi pressionado o botao      ³
			//³ confirma, atraves do parametro passado ao lostfocus                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			@ 100000,100000 MSGET oFoco103 VAR cVarFoco SIZE 12,09 PIXEL OF oDlg
			oFoco103:Cargo := {.T.,.T.}
			oFoco103:Disable()
			If cPaisLoc == "BRA"
				If (SF1->F1_FIMP$'ST'.And. SF1->F1_STATUS='C')
					NfeCabDoc(oDlg,{aPosGet[1],aPosGet[2],aPosObj[1]},@bCabOk,l103Class.Or.l103Visual,NIL,@cUfOrig,.F.,,@nCombo,@oCombo,@cCodRet,@oCodRet,@lNfMedic,@aCodR,@cRecIss,@cNatureza,,aNFEletr,aNfeDanfe,aInfAdic)
				Else
					NfeCabDoc(oDlg,{aPosGet[1],aPosGet[2],aPosObj[1]},@bCabOk,l103Class.Or.l103Visual,NIL,@cUfOrig,l103Class,,@nCombo,@oCombo,@cCodRet,@oCodRet,@lNfMedic,@aCodR,@cRecIss,@cNatureza,,aNFEletr,aNfeDanfe,aInfAdic)
				EndIf
			Else
				NfeCabDoc(oDlg,{aPosGet[1],aPosGet[2],aPosObj[1]},@bCabOk,l103Class.Or.l103Visual,NIL,@cUfOrig,l103Class,,@nCombo,@oCombo,@cCodRet,@oCodRet,@lNfMedic,@aCodR,@cRecIss,@cNatureza,,aNFEletr,aNfeDanfe,aInfAdic)
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Integracao com SIGAMNT - NG Informatica             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nPORDEM := GDFieldPos("D1_ORDEM")
			If SuperGetMV("MV_NGMNTNO",.F.,"2") == "1" .And. !Empty(nPORDEM)
				STJ->(dbSetOrder(1))
				SC7->(dbSetOrder(19))
				SC1->(dbSetOrder(1))

				For nG := 1 To Len(aCols)
					//Se a Ordem de Servico nao estiver definida e a Ordem de Producao estiver preenchida, recebe a O.S. dela caso seja valida
					If Empty(aCols[nG,nPORDEM]) .And. "OS001" $ aCols[nG,GDFieldPos("D1_OP")]
						If STJ->(dbSeek(xFilial("STJ")+SubStr(aCols[nG,GDFieldPos("D1_OP")],1,TamSX3("TJ_ORDEM")[1])))
							aCols[nG,nPORDEM] := STJ->TJ_ORDEM
						ElseIf 	SC7->(dbSeek(xFilial("SC7")+aCols[nG,GDFieldPos("D1_COD")]+aCols[nG,GDFieldPos("D1_PEDIDO")]+aCols[nG,GDFieldPos("D1_ITEMPC")])) .And. ;
								SC1->(dbSeek(xFilial("SC1")+SC7->C7_NUMSC)) .And. ;
							 	STJ->(dbSeek(xFilial("STJ")+SubStr(SC1->C1_OP,1,At("OS",SC1->C1_OP)-1)))
							aCols[nG,nPORDEM] := SubStr(SC1->C1_OP,1,At("OS",SC1->C1_OP)-1)
						EndIf
					EndIf
				Next nG
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ponto de entrada para bloquear os campos do aCols na Classificacao e definir quais poderao ser alterados	³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If l103Class .And. lMT103BCLA
				aMT103BCLA := ExecBlock("MT103BCLA",.F.,.F.)
				If ValType(aMT103BCLA) == "A"
					lRetBCla := .T.
				EndIf
			EndIf

			oGetDados := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcx,'A103LinOk','A103TudOk','+D1_ITEM',!l103Visual,If(lRetBCla,aMT103BCLA,),,,IIf(l103Class,Len(aCols),9999),"A103PosFld",,,IIf(l103Class,'AllwaysFalse()',"NfeDelItem"))
			oGetDados:oBrowse:bGotFocus	:= bCabOk

			oGetDados:oBrowse:bChange := {|| IIf(lDivImp, A103PosFld(), .T.), IIf(lTrbGen, MaFisLinTG(oFisTrbGen,oGetDados:oBrowse:nAt) ,.T.) }

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valida TES de Entrada Padrao do Produto na Classificacao de NF			  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If l103Class
				nPosTes := aScan(aHeader, {|x| AllTrim(Upper(X[2])) == "D1_TES" })
				If !Empty(aCols[n][nPosTes])
 					SF4->(dbSetOrder(1))
					If SF4->(MsSeek(xFilial("SF4")+RetFldProd(SB1->B1_COD,"B1_TE")))
						If !RegistroOk("SF4",.F.)
							Aviso("A103NTES",""+CHR(10)+""+RetFldProd(SB1->B1_COD,"B1_TE"),{""})
							aCols[n][nPosTes] := ""
			   			Endif
					EndIf
				Endif
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Valida itens da nota original na classificação da nota de devolução		 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cTipo $ "D"
					A103VLDITO()
				EndIf
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se o pedido foi gerado pelo SIGAPLS								  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If l103Class .And. !lUsouLtPLS
				nPosPed := aScan(aHeader, {|x| AllTrim(Upper(X[2])) == "D1_PEDIDO" })
				If !Empty(aCols[n][nPosPed])
					dbSelectArea("SC7")
					SC7->(dbSetOrder(1))
					// Grava Lote do PLS e o codigo de RDA
				If cPaisLoc == "BRA"
					If SC7->(MsSeek(xFilial("SC7")+aCols[n][nPosPed])) .And. !Empty(SC7->C7_LOTPLS)
						lUsouLtPLS 	:= .T.
						cCodRDA		:= SC7->C7_CODRDA
					Endif
				EndIf
 				Endif
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Apenas ira montar o folder de Nota Fiscal Eletronica se os campos existirem³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cPaisLoc == "BRA"
				Aadd(aTitles,"Nota Fiscal Eletrônica") // "Nota Fiscal Eletrônica"
				aAdd(aFldCBAtu,Nil)
				nNFe 	:= 	Len(aTitles)
				aAdd(aTitles,"Lançamentos da Apuração de ICMS")	//"Lançamentos da Apuração de ICMS"
				aAdd(aFldCBAtu,Nil)
				nLancAp	:=	Len(aTitles)
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Habilita o folder de conferencia fisica se necessario        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cPaisLoc == "BRA"
				If l103Visual .AND. !l103Exclui .AND. !Empty(SF1->F1_STATUS) .And. ( ;
				SA2->A2_CONFFIS <> "3" .And. ;// Diferente de '3 - nao utiliza'
				(((SA2->A2_CONFFIS == "0" .And. cMVTPCONFF == "2") .Or. ;
				   SA2->A2_CONFFIS == "2") .And. cMVCONFFIS == "S") .Or.;
				   (cTipo == "B" .And. cMVCONFFIS == "S" .And. cMVTPCONFF == "2"))
					aadd(aTitles,"Conferencia Fisica") // "Conferencia Fisica"
					nConfNF := Len(aTitles)
					aAdd(aFldCBAtu,Nil)
				EndIf
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Apenas ira montar o folder de Informacoes Diversas se os campos existirem  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cPaisLoc == "BRA"
				Aadd(aTitles,"Informações DANFE") // "Informações DANFE"
				nInfDiv := 	Len(aTitles)
				aAdd(aFldCBAtu,Nil)
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Apenas ira montar o folder de Informacoes Diversas se os campos existirem  |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cPaisLoc = "BRA" .And. lISSxMun
				Aadd(aTitles,"Apuração ISS/INSS") // "Apuração ISS/INSS"
				aFldCBAtu	:= Array(Len(aTitles))
				nInfISS := 	Len(aTitles)
				aAdd(aFldCBAtu,Nil)
			EndIf

			If Len(aInfAdic) > 0
				aAdd(aTitles, "Informações Adicionais") //"Informações Adicionais"
				nInfAdic := 	Len(aTitles)
				aAdd(aFldCBAtu,Nil)
			EndIf

			If lDivImp .And. !l103Inclui
				aAdd(aTitles, "")
				nDivImp	:= Len(aTitles)
				aAdd(aFldCBAtu,Nil)
			Endif

			If lTrbGen
				aAdd(aTitles, "Tributos Genericos - Por Item") // "Tributos Genericos - Por Item"
				nTrbGen	:= Len(aTitles)
				Aadd(aFldCBAtu,nil) 
			EndIf

			oFolder := TFolder():New(aPosObj[3,1],aPosObj[3,2],aTitles,aPages,oDlg,,,, .T., .F.,aPosObj[3,4]-aPosObj[3,2],aPosObj[3,3]-aPosObj[3,1],)
			oFolder:bSetOption := {|nDst| NfeFldChg(nDst,oFolder:nOption,oFolder,aFldCBAtu)}
			bRefresh := {|nX| NfeFldChg(nX,oFolder:nOption,oFolder,aFldCBAtu)}
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Folder dos Totalizadores                                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oFolder:aDialogs[1]:oFont := oDlg:oFont
			NfeFldTot(oFolder:aDialogs[1],a103Var,aPosGet[3],@aFldCBAtu[1])

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Folder dos Fornecedores                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oFolder:aDialogs[2]:oFont := oDlg:oFont
			NfeFldFor(oFolder:aDialogs[2],aInfForn,{aPosGet[4],aPosGet[5],aPosGet[6]},@aFldCBAtu[2])

			If !lGspInUseM
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Folder das Despesas acessorias e descontos                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oFolder:aDialogs[3]:oFont := oDlg:oFont
			 	If cPaisLoc == "BRA"
			 	If (SF1->F1_FIMP$'ST'.And. SF1->F1_STATUS='C' .And. l103Class) //Tratamento para bloqueio de alteracoes na classificacao de uma nota bloqueada e ja transmitida.
			 		l103Visual := .T.
			 		NfeFldDsp(oFolder:aDialogs[3],a103Var,{aPosGet[7],aPosGet[8]},@aFldCBAtu[3])
			 		l103Visual := .F.
			 	Else
					NfeFldDsp(oFolder:aDialogs[3],a103Var,{aPosGet[7],aPosGet[8]},@aFldCBAtu[3])
			 	EndIf
			 	Else
					NfeFldDsp(oFolder:aDialogs[3],a103Var,{aPosGet[7],aPosGet[8]},@aFldCBAtu[3])
			  	EndIf
			  	IF l103Class
			  		aAreaD1 := SD1->(getArea())
			  		dbSelectArea("SD1")
					SD1->(dbSetOrder(1))
					SD1->(dbGoTop())
					SD1->(DbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))  //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
					
					nTmpN := n
					n:=0
					While !Eof() .And. SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA ==;
									   SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA 
						n++		
						A103Desp()
				  	SD1->(dbSkip())
			  		EndDo
			  		restArea(aAreaD1)
			  		n  := nTmpN
			  	Endif	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Folder dos Livros Fiscais                                    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oFolder:aDialogs[4]:oFont := oDlg:oFont
				oLivro := MaFisBrwLivro(oFolder:aDialogs[4],{5,4,( aPosObj[3,4]-aPosObj[3,2] ) - 10,53},.T.,IIf(!l103Class,aRecSF3,Nil), IIf(!lWhenGet , IIf( l103Class , .T. , l103Visual ) , .F. ) )
				aFldCBAtu[4] := {|| oLivro:Refresh()}
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Folder dos Impostos                                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oFolder:aDialogs[5]:oFont := oDlg:oFont

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Folder do Financeiro                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oFolder:aDialogs[6]:oFont := oDlg:oFont
			NfeFldFin(oFolder:aDialogs[6],l103Visual,aRecSE2,( aPosObj[3,4]-aPosObj[3,2] ) - 101,aRecSe1,@aHeadSE2,@aColsSE2,@aHeadSEV,@aColsSEV,@aFldCbAtu[6],NIL,@cModRetPIS,lPccBaixa,@lTxNeg,@cNatureza,@nTaxaMoeda,@aColTrbGen,@nColsSE2,@aParcTrGen)

			If l103Visual .And. Empty(SF1->F1_RECBMTO)
				oFisRod	:=	A103Rodape(oFolder:aDialogs[5])
			ElseIf (cPaisLoc == "BRA" .And. SF1->F1_FIMP$'ST'.And. SF1->F1_STATUS='C' .And. l103Class) 				 //Tratamento para bloqueio de alteracoes na classificacao de uma nota bloqueada e ja transmitida.
				l103Visual := .T.
				oFisRod	:=	MaFisRodape(nTpRodape,oFolder:aDialogs[5],,{5,4,( aPosObj[3,4]-aPosObj[3,2] )-10,53},@bIPRefresh,l103Visual,@cFornIss,@cLojaIss,aRecSE2,@cDirf,@cCodRet,@oCodRet,@nCombo,@oCombo,@dVencIss,@aCodR,@cRecIss,@oRecIss,,@cDescri)
			Else
				oFisRod	:=	MaFisRodape(nTpRodape,oFolder:aDialogs[5],,{5,4,( aPosObj[3,4]-aPosObj[3,2] )-10,53},@bIPRefresh,l103Visual,@cFornIss,@cLojaIss,aRecSE2,@cDirf,@cCodRet,@oCodRet,@nCombo,@oCombo,@dVencIss,@aCodR,@cRecIss,@oRecIss,,@cDescri)
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Folder dos historicos do Documento de entrada                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If l103Visual .Or. l103Class
				oFolder:aDialogs[7]:oFont := oDlg:oFont
				@ 05,04 LISTBOX oHistor VAR cHistor ITEMS aHistor PIXEL SIZE ( aPosObj[3,4]-aPosObj[3,2] )-10,53 Of oFolder:aDialogs[7]
				Eval(bRefresh,oFolder:nOption)
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ponto de Entrada utilizado na classificação da nota para alterar Combobox ³
			//³ da aba Impostos que informa se gera DIRF e os códigos de retencao         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If l103Class .And. ExistBlock("MT103DRF")
				aDirfRt := ExecBlock("MT103DRF",.F.,.F.,{nCombo,cCodRet,@oCombo,@oCodRet})
				if len(aDirfRt) > 0
					for a:=1 to len(aDirfRt)
						nCombo  := aDirfRt[a][2]
						cCodRet := ""
						if nCombo = 1
							cCodRet := aDirfRt[a][3]
						endif
					    If !Empty(cCodRet)
							If aScan(aCodR,{|aX| aX[4]==aDirfRt[a][1]})==0
							   aAdd( aCodR,{99, cCodRet,1,aDirfRt[a][1]})
							Else
							   aCodR[aScan(aCodR, {|aX| aX[4]==aDirfRt[a][1]})][2] := cCodRet
							EndIf
						EndIf
					next
				else
					nCombo  := Iif(aDirfRt[1][2] > 2, 2, aDirfRt[1][2])
					cCodRet := aDirfRt[1][3]
					If !Empty( cCodRet )
						If aScan( aCodR, {|aX| aX[4]=="IRR"})==0
							aAdd( aCodR, {99, cCodRet, 1, "IRR"} )
						Else
							aCodR[aScan( aCodR, {|aX| aX[4]=="IRR"})][2] :=	cCodRet
						EndIf
					EndIf
				Endif
				If ValType( oCombo ) == "O"
					oCombo:Refresh()
				Endif
				If ValType( oCodRet ) == "O"
					oCodRet:Refresh()
				Endif
				nCombo  := 2
				cCodRet := "    "
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Folder com os dados da Nota Fiscal Eletronica³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cPaisLoc == "BRA"
				oFolder:aDialogs[nNFe]:oFont := oDlg:oFont
				NfeFldNfe(oFolder:aDialogs[nNFe],@aNFEletr,{aPosGet[10],aPosGet[8]},@aFldCBAtu[3])

				If nLancAp>0
					oFolder:aDialogs[nLancAp]:oFont := oDlg:oFont
					If  FindFunction("a017xLAICMS")
						oLancCDV := a017xLAICMS(oFolder:aDialogs[nLancAp],{5,4,( aPosObj[3,4]-aPosObj[3,2] )-10,53},aHeadCDV,aColsCDV,l103Visual,(l103Inclui.Or.l103Class),"SD1")
					Endif
					oLancApICMS := a103xLAICMS(oFolder:aDialogs[nLancAp],{5,4,( aPosObj[3,4]-aPosObj[3,2] )-10,53},@aHeadCDA,@aColsCDA,l103Visual,(l103Inclui.Or.l103Class))					
					If lWhenGet
						Eval({||GetLanc()}) 
					EndIf
					If l103Class
						a103AjuICM()						
					EndIf
				EndIf
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Folder de conferencia para os coletores                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nConfNF > 0
				oFolder:aDialogs[nConfNF]:oFont := oDlg:oFont
				Do Case
				Case SF1->F1_STATCON $ "1 "
					cStatCon := "NF conferida" // "NF conferida"
				Case SF1->F1_STATCON == "0"
					cStatCon := "NF nao conferida" //"NF nao conferida"
				Case SF1->F1_STATCON == "2"
					cStatCon := "NF com divergencia" // "NF com divergencia"
				Case SF1->F1_STATCON == "3"
					cStatCon := "NF em conferencia" // "NF em conferencia"
				Case SF1->F1_STATCON == "4"
					cStatCon := "NF Clas. C/ Diver."
				EndCase
				nQtdConf := SF1->F1_QTDCONF
				@ 06 ,aPosGet[6,1] SAY "Status" OF oFolder:aDialogs[nConfNF] PIXEL SIZE 49,09 // "Status"
				@ 05 ,aPosGet[6,2] MSGET oStatCon VAR Upper(cStatCon) COLOR CLR_RED OF oFolder:aDialogs[nConfNF] PIXEL SIZE 70,9 When .F.
				@ 25 ,aPosGet[6,1] SAY "Conferentes" OF oFolder:aDialogs[nConfNF] PIXEL SIZE 49,09 // "Conferentes"
				@ 24 ,aPosGet[6,2] MSGET oConf Var nQtdConf OF oFolder:aDialogs[nConfNF] PIXEL SIZE 70,09 When .F.
				@ 05 ,aPosGet[5,3] LISTBOX oList Fields HEADER "  ","Codigo","Quantidade Conferida" SIZE 170, 48 OF oFolder:aDialogs[nConfNF] PIXEL // "Codigo","Quantidade Conferida"
				oList:BLDblclick := {||A103DetCon(oList,aListBox)}

				DEFINE TIMER oTimer INTERVAL 3000 ACTION (A103AtuCon(oList,aListBox,oEnable,oDisable,oConf,@nQtdConf,oStatCon,@cStatCon,,oTimer)) OF oDlg
				oTimer:Activate()

				@ 30 ,aPosGet[5,3]+180 BUTTON "Recontagem" SIZE 40 ,11  FONT oDlg:oFont ACTION (A103AtuCon(oList,aListBox,oEnable,oDisable,oConf,@nQtdConf,oStatCon,@cStatCon,.T.,oTimer)) OF oFolder:aDialogs[nConfNF] PIXEL When SF1->F1_STATCON == '2' .And. !lClaNfCfDv // "Recontagem"
				@ 42 ,aPosGet[5,3]+180 BUTTON "Detalhes" SIZE 40 ,11  FONT oDlg:oFont ACTION (A103DetCon(oList,aListBox)) OF oFolder:aDialogs[nConfNF] PIXEL // "Detalhes"

				A103AtuCon(oList,aListBox,oEnable,oDisable)
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Folder com Informacoes Diversas              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cPaisLoc == "BRA"
				oFolder:aDialogs[nInfDiv]:oFont := oDlg:oFont
				NfeFldDiv(oFolder:aDialogs[nInfDiv],{aPosGet[9]})
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Folder com Informacoes ISS    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cPaisLoc == "BRA" .And. lISSxMun
				oFolder:aDialogs[nInfISS]:oFont := oDlg:oFont
				ISSFldDiv(oFolder:aDialogs[nInfISS],{aPosGet[11]},@aObjetos,@aInfISS,@aFldCBAtu,nInfISS)
				If l103Visual
					Eval(bRefresh)
				EndIf
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Folder Informacoes Adicionais do Documeno    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Len(aInfAdic) > 0
				If Len(aInfAdic) < 18 //FR - 18/10/2022 - tem q refazer aqui porque ele volta para tamanho = 16
					aInfAdic := Array(18)	//FR - 18/10/2022 - tem q refazer aqui porque ele volta para tamanho = 16
				Endif 
				oFolder:aDialogs[nInfAdic]:oFont := oDlg:oFont
				NfeFldAdic(oFolder:aDialogs[nInfAdic],{aPosGet[12]}, @aInfAdic, @oDescMun, @cDescMun, l103Visual)
			EndIf

			//-- Folder de Divergências de Impostos
			If  lDivImp .And. !l103Inclui
				oFolder:aDialogs[nDivImp]:oFont := oDlg:oFont

				oListDvIm := COLListDiv(oFolder:aDialogs[nDivImp],{5,4,( aPosObj[3,3]-aPosObj[3,2] ) - 10,53},oGetDados)
			EndIf

			// -- Folder de Tributos Genericos
			If lTrbGen
				oFolder:aDialogs[nTrbGen]:oFont := oDlg:oFont 
				oFisTrbGen := MaFisBrwTG(oFolder:aDialogs[nTrbGen],{5,4,( aPosObj[3,4]-aPosObj[3,2] ) - 10,65}, l103Visual)
				aFldCBAtu[nTrbGen] := {|| Iif(lTrbGen , MaFisLinTG(oFisTrbGen,oGetDados:oBrowse:nAt) , .T.) }				
			EndIf

			If lWhenGet .Or. l103Class
				Eval(bRefresh,oFolder:nOption)
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Transfere o foco para a getdados - nao retirar                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oFoco103:bGotFocus := { || oGetDados:oBrowse:SetFocus() }

			aButControl := {{ |x,y| aColsSEV := aClone( x ), aHeadSEV := aClone( y ) }, aColsSev,aHeadSEV }

		    // Atenção: Conserve a ordem de execução dos ExecBlocks abaixo a fim de facilitar a compreenção
            // e manutenções futuras....!
   			ACTIVATE MSDIALOG oDlg ON INIT (IIf(lWhenGet,oGetDados:oBrowse:Refresh(),Nil),;
				A103Bar(oDlg,{|| oFoco103:Enable(),oFoco103:SetFocus(),oFoco103:Disable(),;
				IIf(((!l103Inclui.And.!l103Class).Or.( Eval(bRefresh,6)          .And. ;
				Iif(l103Inclui .Or. l103Class, A103ConsCTE(aNFeDanfe[18]), .T.) .And.;
				If(l103Inclui.Or.l103Class,NfeTotFin(aHeadSE2,aColsSE2,.T.,,nColsSE2,aColTrbGen),.T.) .And. ;
				oGetDados:TudoOk()))											   .And. ;
				(IIf (l103Class .Or. l103Inclui, NfeCabOk(l103Visual,,,,,,,,,,,.T.),.T.)) .And.;
				A103VldEXC(l103Exclui,cPrefixo)									   .And. ;
				A103CodR(aCodR)													   .And. ;
				A103VldDanfe(aNFEDanfe)											   .And. ;
				a103xLOk() .And. oFoco103:Cargo[1]    							   .And. ;
				NfeVldSEV(oFoco103:Cargo[2],aHeader,aCols,aHeadSEV,aColsSEV)  	   .And. ;
			    EVAL(bBlockSev2)												   .And. ;
				    IIf(( l103Inclui .or. l103Class ),A103ChamaHelp(),.T.)	.And. ;
				A103VldGer( aNFEletr )                                             .And. ;
				NfeNextDoc(@cNFiscal,@cSerie,l103Inclui,@cNumNfGFE) 					   	   .And. ;
				A103TmsVld(l103Exclui) 					   					   	   .And. ;
				NFA103MultOk( aMultas, aColsSE2, aHeadSE2 )  					   	   .And. ;
				IIF(ExistFunc("EA013PosValid"),EA013PosValid(oModelDCL,lDclNew),.T.) .And. ;
				A103VlIGfe( l103Inclui,l103Class, .F., cNumNfGFE ),;
				(nOpc:=1,oDlg:End()),Eval({||nOpc:=0,oFoco103:Cargo[1] :=.T.}))},;
				{||nOpc:=0,oDlg:End(),A103GrvCla(l103Class,aColsSE2,cNatureza)},IIf(l103Inclui.Or.l103Class,aButtons,aButVisual),aButControl))
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Copia aHeader e aCols para uso externo  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Type("l103GAuto") == "U"
			If!l103GAuto .And. nOpc == 1
				If aImpVal <> NIL
					For nLoop := 1 to Len( aCols )
						//Conteudo, Campo, Referência Fiscal/Valor
						aAdd(aImpItem,{"TES"		,"D1_TES"		,aCols[nloop,GdFieldPos("D1_TES")]})
						aAdd(aImpItem,{"IPI"		,"D1_VALIPI"	,MaFisRet(nLoop,"IT_VALIPI")})
						aAdd(aImpItem,{"ICMS"		,"D1_VALICM"	,MaFisRet(nLoop,"IT_VALICM")})
						aAdd(aImpItem,{"ISS"		,"D1_VALISS"	,MaFisRet(nLoop,"IT_VALISS")})
						aAdd(aImpItem,{"PIS"		,"D1_VALIMP6"	,MaFisRet(nLoop,"IT_VALPS2")})
						aAdd(aImpItem,{"COFINS"		,"D1_VALIMP5"	,MaFisRet(nLoop,"IT_VALCF2")})
						aAdd(aImpItem,{"ICMS ST"	,"D1_ICMSRET"	,MaFisRet(nLoop,"IT_VALSOL")})

						aAdd(aImpItem,{"ALIQUOTA IPI"		,"D1_IPI"		,MaFisRet(nLoop,"IT_ALIQIPI")})
						aAdd(aImpItem,{"ALIQUOTA ICMS"		,"D1_PICM"		,MaFisRet(nLoop,"IT_ALIQICM")})
						aAdd(aImpItem,{"ALIQUOTA ISS"		,"D1_ALIQISS"	,MaFisRet(nLoop,"IT_ALIQISS")})
						aAdd(aImpItem,{"ALIQUOTA PIS"		,"D1_ALQIMP6"	,MaFisRet(nLoop,"IT_ALIQPS2")})
						aAdd(aImpItem,{"ALIQUOTA COFINS"	,"D1_ALQIMP5"	,MaFisRet(nLoop,"IT_ALIQCF2")})
						aAdd(aImpItem,{"ALIQUOTA ICMS ST"	,"D1_ALIQSOL"	,MaFisRet(nLoop,"IT_ALIQSOL")})
						aAdd(aImpVal, {aCols[nloop,GdFieldPos("D1_ITEM")],aImpItem})
					Next
				Endif
			EndIf
		EndIf

		If nOpc == 1 .And. (l103Inclui.Or.l103Class.Or.l103Exclui)	.And. If(Type("l103GAuto") == "U" ,.T.,l103GAuto)

			If (ExistBlock("MT100AG"))
				ExecBlock("MT100AG",.F.,.F.)
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicializa a gravacao atraves nas funcoes MATXFIS         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			MaFisWrite(1)

			If A103Trava() .And. IIf(lIntegGFE .And. l103Exclui,ExclDocGFE(),.T.)
					
					// Gera temporárias antes da transação para o processo de skip-lote
					If IntWMS()
						WmsAvalSF1("8")
					EndIf
					
					If lEstNfClass .And. cDelSDE == "3"  .And. (Len(aRecSDE) > 0)
						cDelSDE:=Str(Aviso(OemToAnsi(""),"",{"",""},2),1,0)
					EndIf

					// Valida retorno valido
					If !(cDelSDE $ "123")
						cDelSDE:="1"
					EndIf
					If !l103Auto
						SetKey(VK_F4,Nil)
						SetKey(VK_F5,Nil)
						SetKey(VK_F6,Nil)
						SetKey(VK_F7,Nil)
						SetKey(VK_F8,Nil)
						SetKey(VK_F9,Nil)
						SetKey(VK_F10,Nil)
						SetKey(VK_F11,Nil)
						SetKey(VK_F12,bKeyF12)
					EndIf
					Begin Transaction
						If l103Exclui
							SD1->(dbSetOrder(1))
							SD1->(MsSeek(xFilial("SD1")+cNFiscal+cSerie+cA100For+cLoja))
							SDH->(dbSetOrder(1))
							If SDH->(MsSeek(xFilial("SDH")+SD1->D1_NUMSEQ))
								aRetInt := FWIntegDef("MATA103A",,,,"MATA103A")	//-- CoverageDocument

								If Valtype(aRetInt) == "A"
									If Len(aRetInt) == 2 
										If !aRetInt[1]
											If Empty(AllTrim(aRetInt[2]))
												cMsgRet := ""
											Else
												cMsgRet := AllTrim(aRetInt[2])
											Endif
											Aviso("OK",cMsgRet,{"Ok"},3)
											lRet := .F.
											DisarmTransaction()
										Endif
									Endif
								Endif
							Else
								aRetInt := FWIntegDef("MATA103",,,,"MATA103")	//-- InputDocument
								If Valtype(aRetInt) == "A"
									If Len(aRetInt) == 2
										If !aRetInt[1]
											If Empty(AllTrim(aRetInt[2]))
												cMsgRet := ""
											Else
												cMsgRet := AllTrim(aRetInt[2])
											Endif
											Aviso("OK",cMsgRet,{"Ok"},3)
											lRet := .F.
											DisarmTransaction()
										Endif
									Endif
								Endif

								aRetInt := FWIntegDef("MATA103B",,,,"MATA103B")	//-- Invoice
								If Valtype(aRetInt) == "A"
									If Len(aRetInt) == 2
										If !aRetInt[1]
											If Empty(AllTrim(aRetInt[2]))
												cMsgRet := ""
											Else
												cMsgRet := AllTrim(aRetInt[2])
											Endif
											Aviso("OK",cMsgRet,{"Ok"},3)
											lRet := .F.
											DisarmTransaction()
										Endif
									Endif
								Endif
							EndIf

							If lRet

								cAlFR3 := getNextAlias()
								aRecPA := {}
	
								cQuery := ""
								cQuery += "SELECT	FR3.FR3_FILIAL "								+ CRLF
								cQuery += "		,FR3.FR3_CART"								+ CRLF
								cQuery += "		,FR3.FR3_FORNEC" 								+ CRLF
								cQuery += "		,FR3.FR3_LOJA"								+ CRLF
								cQuery += "		,FR3.FR3_PREFIX"								+ CRLF
								cQuery += "		,FR3.FR3_NUM" 								+ CRLF
								cQuery += "		,FR3.FR3_PARCEL" 								+ CRLF
								cQuery += "		,FR3.FR3_TIPO"								+ CRLF
								cQuery += "		,FR3.FR3_PEDIDO"								+ CRLF
								cQuery += "		,FR3.FR3_VALOR"								+ CRLF
								cQuery += "		,FR3.R_E_C_N_O_ AS RECNO"						+ CRLF
								cQuery += "FROM	" + retSqlname("FR3") + " FR3" 					+ CRLF
								cQuery += "WHERE	FR3.D_E_L_E_T_	= ' '"						+ CRLF
								cQuery += "AND	FR3.FR3_FILIAL	= '" + SF1->F1_FILIAL + "'"		+ CRLF
								cQuery += "AND	FR3.FR3_CART		= 'P'"						+ CRLF
								cQuery += "AND	FR3.FR3_DOC		= '" + SF1->F1_DOC + "'"		+ CRLF
								cQuery += "AND	FR3.FR3_SERIE		= '" + SF1->F1_SERIE + "'"		+ CRLF
								cQuery += "AND	FR3.FR3_TIPO		IN( 'PA','NF')"
	
								cQuery := changeQuery(cQuery)

								If select(cAlFR3) > 0
									(cAlFR3)->(dbCloseArea())
								EndIf
	
								tcQuery cQuery New Alias ((cAlFR3))
	
								dbSelectArea((cAlFR3))
								(cAlFR3)->(dbGoTop())
								aAreaE2 := SE2->(getArea())
								SE2->(dbSetOrder(1))
								dbSelectArea("FR3")
								aAreaR3 := FR3->(getArea())
								dbSelectArea("FIE")
								FIE->(dbSetOrder(3))
								FIE->(dbGoTop())
								aAreaIE := FIE->(getArea())
								While((cAlFR3)->(!eof()))
									If(SE2->(msSeek((cAlFR3)->FR3_FILIAL + (cAlFR3)->FR3_PREFIX + (cAlFR3)->FR3_NUM + (cAlFR3)->FR3_PARCEL + (cAlFR3)->FR3_TIPO + (cAlFR3)->FR3_FORNEC + (cAlFR3)->FR3_LOJA)))
										If((cAlFR3)->FR3_TIPO == PADR('PA',nFR3_TIPO))
											aadd(aRecPA,SE2->(recno()))
										EndIf
									EndIf
									FR3->(dbGoTo((cAlFR3)->RECNO))
									If(FIE->(dbSeek(FR3->FR3_FILIAL + FR3->FR3_CART + FR3->FR3_FORNEC + FR3->FR3_LOJA + FR3->FR3_PREFIX + FR3->FR3_NUM + FR3->FR3_PARCEL + FR3->FR3_TIPO + FR3->FR3_PEDIDO)))
										If(recLock("FIE",.F.))
											FIE->FIE_SALDO += FR3->FR3_VALOR
											FIE->(msUnLock())
										EndIf
									EndIf
									If(recLock("FR3",.F.))
										FR3->(dbDelete())
										FR3->(msUnLock())
									EndIf
									(cAlFR3)->(dbSkip())
								EndDo
							Endif
							
							If lRet
								//Carrega o pergunte da rotina de compensação financeira
								Pergunte("AFI340",.F.)
							
								lContabiliza 	:= MV_PAR11 == 1
								lDigita			:= MV_PAR09 == 1
								
								restArea(aAreaE2)
								restArea(aAreaR3)
								restArea(aAreaIE)
								
								If(len(aRecPA) > 0)
									aEstorno := {XGetCP()}
									MaIntBxCP(2,{SE2->(recno())},,aRecPA,,{lContabiliza,lAglutina,lDigita,.F.,.F.,.F.},,aEstorno,,,dDataBase,)
								EndIf
	
								If select(cAlFR3) > 0
									(cAlFR3)->(dbCloseArea())
								EndIf
								Pergunte("MTA103",.F.)
							Endif
						EndIf
						
						If !lRet .Or. (FindFunction("CnNotaDev") .And. lUsaGCT .And. (l103Exclui .And. SF1->F1_TIPO == 'D' .And. !CnNotaDev(1,{SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA})))
							lRet := .F.
							DisarmTransaction()
						Elseif lRet
							a103Grava(	l103Exclui,lGeraLanc ,lDigita    ,lAglutina            ,aHeadSE2   ,;
										aColsSE2  ,aHeadSEV  ,aColsSEV   ,nRecSF1              ,aRecSD1    ,;
										aRecSE2   ,aRecSF3   ,aRecSC5    ,aHeadSDE             ,aColsSDE   ,;
										aRecSDE   ,.F.       ,.F.        ,                     ,aRatVei    ,;
										aRatFro   ,cFornIss  ,cLojaIss   ,A103TemBlq(l103Class), l103Class ,;
										cDirf     ,cCodRet   ,cModRetPIS ,nIndexSE2            ,lEstNfClass,;
										dVencIss  ,lTxNeg    ,aMultas    ,lRatLiq              ,lRatImp    ,;
										aNFEletr  ,cDelSDE   ,aCodR      ,cRecIss              ,cAliasTPZ  ,;
										aCtbInf   ,aNfeDanfe ,@lExcCmpAdt, @aDigEnd            ,@lCompAdt  ,;
										aPedAdt   ,aRecGerSE2,aInfAdic   ,a103Var              ,cCodRSef   ,;
										@aTitImp  , aHeadDHP , aColsDHP  ,aCompFutur           ,aParcTrGen )


							If !(l103Exclui .and. !lExcCmpAdt)
								a103GrvCDA(l103Exclui,"E",cEspecie,cFormul,cNFiscal,cSerie,cA100For,cLoja)
								If Type("oLancCDV")=="O" 
									a017GrvCDV(l103Exclui,"E",cEspecie,cFormul,cNFiscal,cSerie,cA100For,cLoja)
								Endif
								//³ Atualiza dados dos complementos SPED automaticamente ³
								If lMvAtuComp
									AtuComp(cNFiscal,SF1->F1_SERIE,cEspecie,cA100For,cLoja,"E",cTipo)
								EndIf
							Endif

							If lIntegGFE .And. ( l103Inclui .Or. l103Class ) .And. lProcGet .AND. SF1->F1_ORIGEM != 'GFEA065'
								lRetGFE := A103VlIGfe( l103Inclui,l103Class, .T. )
								If !lRetGFE
									lRet := .F.
									DisarmTransaction()
								Endif
							EndIf

							//Atualiza os dados do movimento na locação de equipamentos
							If lRet .And. SF1->F1_TIPO == 'D'
								At800AtNFEnt( l103Exclui )
							EndIf
	
							If lRet .And. l103Inclui .Or. l103Class
								SD1->(dbSetOrder(1))
								SD1->(MsSeek(xFilial("SD1")+cNFiscal+cSerie+cA100For+cLoja))
								SDH->(dbSetOrder(1))
								If SDH->(MsSeek(xFilial("SDH")+SD1->D1_NUMSEQ))
									aRetInt := FWIntegDef("MATA103A",,,,"MATA103A")	//-- CoverageDocument
	
									If Valtype(aRetInt) == "A"
										If Len(aRetInt) == 2
											If !aRetInt[1]
												If Empty(AllTrim(aRetInt[2]))
													cMsgRet := ""
												Else
													cMsgRet := AllTrim(aRetInt[2])
												Endif
												Aviso("",cMsgRet,{"Ok"},3)
												lRet := .F.
												DisarmTransaction()
											Endif
										Endif
									Endif
								Else 
									aRetInt := FWIntegDef("MATA103",,,,"MATA103")	//-- InputDocument
									If Valtype(aRetInt) == "A"
										If Len(aRetInt) == 2
											If !aRetInt[1]
												If Empty(AllTrim(aRetInt[2]))
													cMsgRet := ""
												Else
													cMsgRet := AllTrim(aRetInt[2])
												Endif
												Aviso("",cMsgRet,{"Ok"},3)
												lRet := .F.
												DisarmTransaction()
											Endif
										Endif
									Endif
	
									aRetInt := FWIntegDef("MATA103B",,,,"MATA103B")	//-- Invoice
									If Valtype(aRetInt) == "A"
										If Len(aRetInt) == 2
											If !aRetInt[1]
												If Empty(AllTrim(aRetInt[2]))
													cMsgRet := ""
												Else
													cMsgRet := AllTrim(aRetInt[2])
												Endif
												Aviso("OK",cMsgRet,{"Ok"},3)
												lRet := .F.
												DisarmTransaction()
											Endif
										Endif
									Endif
								EndIf
								
								If !lRet .Or. (FindFunction("CnNotaDev") .And. lUsaGCT .And. (SF1->F1_TIPO == 'D' .And. !CnNotaDev(0,{SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA})))
									lRet := .F.
									DisarmTransaction()
								EndIf
								
							EndIf
						Endif 
					End Transaction

					//A execução das ordens de serviço WMS deve ser fora da transação
					//para não impedir a classificação da nota caso ocorra algum problema
					If lRet .And. SF1->F1_TIPO $ "N|D|B" .AND. IntWMS()
						//Desfaz distribuição automática quando estorna a classificação
						If lEstNfClass .And. SF1->F1_TIPO == "N"
							WmsAvalSF1("7")
						EndIf
						//A execução das ordens de serviço WMS deve ser fora da transação
						//para não impedir a classificação da nota caso ocorra algum problema
						WmsAvalSF1("5","SF1")
					EndIf

					//Verifica se está na versao 11.6 e se o endereçamento na produção está ativo.
				    IF lRet .And. lDistMov .And. Len(aDigEnd) > 0
				    	//Chama a rotina de endereçamento no recebimento / produção
						A103DigEnd(aDigEnd)
				    endif

					//Função que excluirá fisicamente as temporárias do banco de dados.
					If lRet .And. UPPER(Alltrim(TCGetDb()))=="POSTGRES"
						Fa050Drop()
					Endif

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Executa gravacao da contabilidade     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lRet .And. !(l103Exclui .and. !lExcCmpAdt)
						If Len(aCtbInf) != 0

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿[]
							//³ Ponto de entrada para tratamentos especificos     ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If ( ExistBlock("MT103CTB") )
								aMT103CTB := ExecBlock("MT103CTB",.F.,.F.,{aCtbInf,l103Exclui,lExcCmpAdt})
								If ( ValType(aMT103CTB) == "A" )
									aCtbInf := aClone(aMT103CTB)
								EndIf
							EndIf

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Cria nova transacao para garantir atualizacao do documento ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

							cA100Incl(aCtbInf[1],aCtbInf[2],3,aCtbInf[3],aCtbInf[4],aCtbInf[5],,,,aCtbInf[7],,aCtbInf[6])

						EndIf
						If lCompAdt	// Compensacao do Titulo a Pagar quando trata-se de pedido com Adiantamento
							A103CompAdR(aPedAdt,aRecGerSE2)
						EndIf
					Endif

					// Exibicao do(s) titulo(s) de PIS/COFINS importacao gerados. Retirada da funcao A103GRAVA para que
					// nao seja exibida a interface dentro da transacao.
					If lRet .And. cPaisLoc == "BRA" .And. !l103Auto .And. (l103Inclui .Or. l103Class) .And. Len(aTitImp) > 0 .And. SuperGetMv("MV_TITAPUR",.F.,.F.)
						dbSelectArea("SE2")
						nRecSE2 := SE2->(RecNo())
						Pergunte("FIN050",.F.)
						For nX := 1 To Len(aTitImp)
							If aTitImp[nX][01] <> 0
								SE2->(MsGoto(aTitImp[nX][01]))
								FINA050(,,4,'FA050Alter("SE2",SE2->(RECNO()),2)')
							EndIf
						Next nX
						SE2->(MsGoto(nRecSE2))
						Pergunte("MTA103",.F.)
					Endif

				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Para a localizacao Mexico, sera processada a funcao do ponto de entrada MT100AGR no padrao³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lRet .And. cPaisLoc == "MEX"
					PgComMex()
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Integracao o modulo ACD - Realiza o enderecamento automatico p/ o CQ 		³
				//³ na classificacao da nota						  							³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lRet .And. !(l103Exclui .and. !lExcCmpAdt)

					If lIntACD
						CBMT100AGR()
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Template acionando ponto de entrada                      ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					ElseIf ExistTemplate("MT100AGR")
						ExecTemplate("MT100AGR",.F.,.F.)
					EndIf
					If ExistBlock("MT100AGR",.T.,.T.)
						ExecBlock("MT100AGR",.F.,.F.)
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Agroindustria  									                 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If FindFunction("OGXUtlOrig") //Encontra a função
						If OGXUtlOrig()
						   If FindFunction("OGX140")
						      OGX140()
						   EndIf
						EndIf
					Endif

				Endif

                //Trade-Easy
			    //RRC - 18/07/2013 - Integração SIGACOM x SIGAESS: Geração automática das invoices e parcelas de câmbio a partir do documento de entrada
			    If lRet .And. SF1->F1_TIPO == "N" .And. GetMv("MV_COMSEIC",,.F.) .And. GetMv("MV_ESS0012",,.F.)
			       PS400BuscFat("A","SIGACOM",,SF1->F1_DOC,SF1->F1_SERIE,.T.)
			    EndIf
			Else
				//Libera Lock de Pedidos Bloqueados//
				If Type("aRegsLock")<>"U"
					If Len(aRegsLock)>0
						A103UnlkPC()
					EndIf
				EndIf

				//Desfaz distribuição automática
				If l103Class .And. !lEstNfClass .And.  SF1->F1_TIPO == "N" .And. SF1->F1_STATUS != "C" .And. IntWMS()
					WmsAvalSF1("7")
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Ponto de Entrada para verificar se o usuário clicou no botão Cancelar no Documento de Entrada   		³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (ExistBlock("MT103CAN"))
					ExecBlock("MT103CAN",.F.,.F.)
				EndIf
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Finaliza a gravacao dos lancamentos do SIGAPCO e apaga lancamentos de bloqueio nao utilizados ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRet .And. !(l103Exclui .and. !lExcCmpAdt)
				PcoFinLan("000054")
				PcoFreeBlq("000054")
			Endif
		EndIf
	EndIf
	MaFisEnd()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Destrava os registros na alteracao e exclusao          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If l103Class .Or. l103Exclui
		MsUnlockAll()
	EndIf
	If !l103Auto
		SetKey(VK_F4,Nil)
		SetKey(VK_F5,Nil)
		SetKey(VK_F6,Nil)
		SetKey(VK_F7,Nil)
		SetKey(VK_F8,Nil)
		SetKey(VK_F9,Nil)
		SetKey(VK_F10,Nil)
		SetKey(VK_F11,Nil)
		SetKey(VK_F12,bKeyF12)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Protecao para evitar ERRORLOG devido ao fato do objeto oLancApICMS   ³
	//³ nao ser destruido corretamente ao termino da rotina. Todos os demais ³
	//³ objetos sao destruidos corretamente.                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Type("oLancApICMS") == 'O'
		FreeObj(oLancApICMS)
	EndIf

	If Type("oLancCDV") == 'O'
		FreeObj(oLancCDV)
	EndIf

	If lRet .And. lPrjCni
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Limpa array Divergencias                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If  Type("_aDivPNF") != "U"
		   _aDivPNF := {}
		Endif
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto no final da rotina, para o usuario completar algum processo ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet .And. !(l103Exclui .and. !lExcCmpAdt)
		If ExistTemplate("MT103FIM")
			ExecTemplate("MT103FIM",.F.,.F.,{aRotina[nOpcX,4],nOpc})
		EndIf
		If ExistBlock("MT103FIM")
			Execblock("MT103FIM",.F.,.F.,{aRotina[nOpcX,4],nOpc})
		EndIf
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Retorna ao valor original de maxcodes ( utilizado por MayiUseCode() ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SetMaxCodes( nMaxCodes )

	If !Empty(cAliasTPZ) .and. Select(cAliasTPZ) > 0
		oTempTable:Delete()
	EndIf

EndIf

cFornIss := ""
dVencISS := CTOD("")

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ma103PerAutºAutor  ³Alvaro Camillo Neto º Data ³  07/22/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Carrega as variaveis com os parametros da execauto          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ma103PerAut()
Local nX 		:= 0
Local cVarParam := ""

If Type("aParamAuto")!="U"
	For nX := 1 to Len(aParamAuto)
		cVarParam := Alltrim(Upper(aParamAuto[nX][1]))
		If "MV_PAR" $ cVarParam
			&(cVarParam) := aParamAuto[nX][2]
		EndIf
	Next nX
EndIf
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A103Bar  ³ Prog. ³ Sergio Silveira       ³Data  ³23/02/2001³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cria a enchoicebar.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A103Bar( ExpO1, ExpB1, ExpB2, ExpA1 )                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto dialog                                      ³±±
±±³          ³ ExpB1 = Code block de confirma                             ³±±
±±³          ³ ExpB2 = Code block de cancela                              ³±±
±±³          ³ ExpA1 = Array com botoes ja incluidos.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Retorna o retorno da enchoicebar                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MATA103                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function A103Bar(oDlg,bOk,bCancel,aButtonsAtu, aInfo  )

Local aUsButtons := {}
Local lPrjCni := If(FindFunction("ValidaCNI"),ValidaCNI(),.F.)

If lPrjCni
	aadd(aButtonsAtu,{"BUDGET",   {|| _MA103Div1()},"Cadastro de divergencias","Divergencias" })
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona botoes do usuario na EnchoiceBar                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If ExistTemplate( "MA103BUT" )
	If ValType( aUsButtons := ExecTemplate( "MA103BUT", .F., .F.,{aInfo} ) ) == "A"
		AEval( aUsButtons, { |x| AAdd( aButtonsAtu, x ) } )
	EndIf
EndIf
If ExistBlock( "MA103BUT" )
	If ValType( aUsButtons := ExecBlock( "MA103BUT", .F., .F.,{aInfo} ) ) == "A"
		AEval( aUsButtons, { |x| AAdd( aButtonsAtu, x ) } )
	EndIf
EndIf

Return (EnchoiceBar(oDlg,bOK,bcancel,,aButtonsAtu))


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A103TudOk ³ Autor ³ Edson Maricate        ³ Data ³08.02.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao da TudoOk                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA103                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function A103Tudok()
Local aCodFol  	  := {}
Local aPrdBlq     := {}
Local cProdsBlq   := ""
Local cAlerta     := ""
Local cMRetISS    := GetNewPar("MV_MRETISS","1")
Local cVerbaFol	  := ""
Local cNatValid	  := MaFisRet(,"NF_NATUREZA")
Local lRestNFE	  := SuperGetMV("MV_RESTNFE")=="S"
Local nPValDesc   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_VALDESC"})
Local nPosTotal   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_TOTAL"})
Local nPosIdentB6 := aScan(aHeader,{|x| AllTrim(x[2])=="D1_IDENTB6"})
Local nPosNFOri   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_NFORI"})
Local nPosItmOri  := aScan(aHeader,{|x| AllTrim(x[2])=="D1_ITEMORI"})
Local nPosSerOri  := aScan(aHeader,{|x| AllTrim(x[2])=="D1_SERIORI"})
Local nPosTes     := aScan(aHeader,{|x| AllTrim(x[2])=="D1_TES"})
Local nPosCfo     := aScan(aHeader,{|x| AllTrim(x[2])=="D1_CF"})
Local nPosPc      := aScan(aHeader,{|x| AllTrim(x[2])=="D1_PEDIDO"})
Local nPosItPc    := aScan(aHeader,{|x| AllTrim(x[2])=="D1_ITEMPC"})
Local nPosQtd     := aScan(aHeader,{|x| AllTrim(x[2])=="D1_QUANT"})
Local nPosVlr     := aScan(aHeader,{|x| AllTrim(x[2])=="D1_VUNIT"})
Local nPosOp      := aScan(aHeader,{|x| AllTrim(x[2])=="D1_OP"})
Local nPosCod     := aScan(aHeader,{|x| AllTrim(x[2])=="D1_COD"})
Local nPosItem    := aScan(aHeader,{|x| AllTrim(x[2])=="D1_ITEM"})
Local nPosMed     := aScan(aHeader,{|x| AllTrim(x[2])=="D1_ITEMMED"})
Local nPosQuant   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_QUANT"})
Local cFilNfOri   := xFilial("SD2")
Local nItens      := 0
Local nPosAFN 	  := 0
Local nPosQtde	  := 0
Local nTotAFN	  := 0
Local nA		  := 0
Local nX          := 0
Local nY		  := 0
Local nZ          := 0
Local n_SaveLin
Local lGspInUseM  := If(Type('lGspInUse')=='L', lGspInUse, .F.)
Local lContinua	  := .T.
Local lPE		  := .T.
Local lRet        := .T.
Local lItensMed   := .F.
Local lItensNaoMed:= .F.
Local lEECFAT	  := SuperGetMv("MV_EECFAT",.F.,.F.)
Local lEspObg	  := SuperGetMV("MV_ESPOBG",.F.,.F.)
Local lMT103PBLQ  := .F.
Local lUsaAdi	  := .F.
Local lDHQInDic   := AliasInDic("DHQ") .And. SF4->(ColumnPos("F4_EFUTUR") > 0)
Local lMt103Com   := FindFunction("A103FutVld")
Local aAreaSC7    := SC7->(GetArea())
Local aMT103GCT   := {}
Local aItensPC	  := {}
Local nItemPc	  := 0
Local nQtdItPc	  := 0
Local aAreaSX3	  := SX3->(GetArea())
Local lVldItPc	  := SuperGetMv("MV_VLDITPC",.F.,.F.)
Local lVerChv	  := SuperGetMv("MV_VCHVNFE",.F.,.F.)
Local cNFForn	  := ""
//Local nNFNum	  := ""
Local nNFSerie	  := ""
Local lVtrasef	  := SuperGetMv("MV_VTRASEF",.F.,"N") == "S"
Local aDocEmp		:= {}
Local aAreaSB5	  := {}
//Local nTamTipo    := TamSX3("E2_TIPO")[1]
Local lDuplic	:= .F.
Local aAreaSD1	:= {}
Local aAreaSF1	:= {}
Local aOldArea	:= {}
Local aAreaTEW	:= {}
Local cMsgTEW		:= ""
Local lHasLocEquip	:= FindFunction("At800AtNFEnt") .And. AliasInDic("TEW")
//Local cPrefixo	:= If(SuperGetMV("MV_2DUPREF") == "SF1->F1_SERIE",cSerie,"")
Local cNfDtFin	:= SuperGetMV("MV_NFDTFIN",.F.,"1")
Local nTamCodFol	:= TamSx3("RV_CODFOL")[1]
Local lGrade		:= MaGrade()
Local lVerificou	:= .F. //verificacao de entrada de remedio controlado
Local cCaixaSup		:= Space(25)
Local lAvulsa		:= .F.

Local cDivImp		:= SuperGetMV("MV_NFVLDDI",.F.,"0")
Local lDivImp		:= SuperGetMV("MV_NFDVIMP",.F.,.F.) .And. COLConVinc(SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA) > 0 .And. !INCLUI
Local cImpMsg		:= ""
Local cImpMsg2		:= CRLF+""
Local cImpMsg3		:= CRLF+""


//Validação para integração com GFE via ExecAuto
If l103Auto .And. FunName()=="GFEA065" .And. INCLUI

	aAreaSF1 := SF1->(GetArea())
	SF1->(DbSetOrder(1))

	//Ajusta campo Série
	If Len(cSerie) <> Len(SD1->D1_SERIE)
	   cSerie := Left(cSerie,Len(SD1->D1_SERIE))
	Endif

	If lContinua .And. ;
	   SF1->(DbSeek(xFilial("SF1")+cnFiscal+SerieNfId("SD1",4,"D1_SERIE",dDEmissao,cEspecie,cSerie)+cA100For+cLoja+cTipo,.T.))

	   lContinua := .F.

	   nItens := 1 //Para não gerar mensagem de erro do item

	Endif

	SF1->(RestArea(aAreaSF1))

	If lContinua

     	//verifica se ja existe na inclusão itens da Nota

     	aAreaSD1:=SD1->(GetArea())

    	SD1->(DbSetOrder(1))

		For nX := 1 to Len(aCols)
			If !aCols[nx][Len(aHeader)+1]
	         If SD1->(DbSeek(xFilial("SD1")+cnFiscal+SerieNfId("SD1",4,"D1_SERIE",dDEmissao,cEspecie,cSerie)+cA100For+cLoja+aCols[nX,nPosCod]+aCols[nX,nPosItem],.T.))  //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
				lContinua := .F.
				exit
			  Endif
			EndIf
		Next nX

		SD1->(RestArea(aAreaSD1))

	Endif

	If ! lContinua

       AutoGRLog(""+Space(1)+cnFiscal+Space(1)+""+Space(1)+cSerie+Space(1)+""+Space(1)+""+Space(1)+cA100for) //"Documento Fiscal de Entrada "+cnFiscal+" Serie "+cSerie+" Forn "+cA100for+" já existente!"

		lRet := .F.

	Endif

Endif

If lRet
	For nx:=1 to len(aCols)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o poder de terceiro                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRet .And. !aCols[nx][Len(aCols[nx])] .And. nPosNfOri > 0 .And. nPosSerOri > 0 .And. nPosIdentB6 > 0 ;
		                                           .And. nPosQuant > 0 .And. nPosTotal  > 0 .And. nPValDesc   > 0 ;
		                                           .And. nPosCod   > 0 .And. nPosTES    > 0 .And. !lGspInUseM

			/* Com template de Drogaria, eh necessario a verificacao se o
			 remedio eh controlado. Se for , eh obrigatorio a autorizacao
			 do responsavel farmaceutico na entrada do produto */
		    If lHasTplDro .AND. !lVerificou  	        // se for drogaria, verifica se ha itens controlados pelo template
		    	If T_DroVerCont( aCols[nX,nPosCod]) 	// se for remedio controlado
	    			lRet := T_DroVERPerm(3,@cCaixaSup) 			// verifica permissao do primeiro item controlado, 2 parametro indicando que eh entrada de nota
					//Passará para a variável de referência para DroVldfuncs
					If ExistFunc( "LjSetSup" )
						LjSetSup( cCaixaSup )
					EndIf

	    			lVerificou := lRet
		    	EndIf
		    EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se o conteudo do aCols[nX][nPosIdentB6]         ³
			//³ confere com o do documento original (SD2) em casos onde  ³
			//³ o usuario altera manualmente o docto orignal ao retornar ³
			//³ devolucoes de beneficiamento pela opcao Retornar.        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SF4->(DbSetOrder(1))
			SF4->(MsSeek(xFilial("SF4") + aCols[nX][nPosTES]))

			If SF4->F4_PODER3 == "D"

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Validacao utilizada para nao permitir que o usuario altere o     ³
				//| fornecedor quando utilizado devolucao de poder de terceiros,     |
				//| pois o fornecedor do documento de entrada deve ser o mesmo       |
				//| fornecedor informado no documento original. Somente quando utili-|
				//| zada operacao triangular sera possivel alterar o fornecedor.     |
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lRet .And. !IsTriangular(mv_par08==1)
					SD2->(DbSetOrder(4))
					If SD2->(MsSeek(xFilial("SD2") + aCols[nX][nPosIdentB6])) .And.;
					   SD2->D2_CLIENTE+SD2->D2_LOJA <> cA100for+cLoja
						cAlerta := IIf(cTipo=="B","","") + " " + cA100For + "/" + cLoja + " " + "" + " " + chr(13)  //"O conteudo dos campos fornecedor/loja : ###### / ## esta incompativel"
						cAlerta += "" + " " + chr(13) 												 							 //"com a amarração dos itens informados referente a devolução de poder de terceiros."
						cAlerta += IIf(cTipo=="B","","") + chr(13) 													     //"Por favor informe o fornecedor/loja correto."
					   	Aviso("IDENTSB6",cAlerta,{"Ok"})
						lRet := .F.
					EndIf
				EndIf

				If lRet
					lRet := VldLinSB6(nx, nPosNfOri,nPosSerOri,nPosIdentB6,nPosQuant,nPosTotal,nPValDesc,nPosCod,nPosTES,nPosVlr,aCols,cFilNfOri,cA100For,cLoja,cTipo,l103Auto)
				EndIf
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| Valida qtde com a Integracao PMS                         |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRet .And. !aCols[nx][Len(aCols[nx])]
			If IntePms() .And. Len(aRatAFN)>0
				If Len(aHdrAFN) == 0
					aHdrAFN := FilHdrAFN()
				Endif
				nPosAFN  := Ascan(aRatAFN,{|x|x[1]==(StrZero(nx,4))})
				nPosQtde := Ascan(aHdrAFN,{|x|Alltrim(x[2])=="AFN_QUANT"})
				nTotAFN	:= 0

				If nPosAFN>0 .And. nPosQtde>0 .And. nPosQuant>0
					nPPed := Ascan(aHeader,{|x|Alltrim(x[2])=="D1_PEDIDO"})
					nPItP := Ascan(aHeader,{|x|Alltrim(x[2])=="D1_ITEMPC"})
					For nA := 1 To Len(aRatAfn[nPosAFN][2])
						If !aRatAFN[nPosAFN][2][nA][LEN(aRatAFN[nPosAFN][2][nA])]
							nTotAFN	+= aRatAfn[nPosAFN][2][nA][nPosQtde]
							If !PmsVldTar("AFN", aHdrAFN, aRatAFN[nPosAFN][2]) .AND. PMSHLPAFN()
								Help("   ",1,"PMSUSRNFE")
								lRet := .F.
								Exit
							EndIf
						Endif
					Next nA

					If nPPed > 0 .And. nPItP > 0
						If !PMSNFSA(aCols[nx][nPPed],aCols[nx][nPItP])[1]
							If nTotAFN > aCols[nx][nPosQuant]
								Help("   ",1,"PMSQTNF")
								lRet := .F.
								Exit
							Endif
						Endif
					Endif
				Endif
			Endif
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o preenchimaneto da TES dos itens devido a importacao do pedido de compras ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRet .And. !aCols[nx][Len(aCols[nx])]
			nItens ++
			If nPosCFO>0 .And. nPosTES>0 .And. Empty(aCols[nx][nPosCFO]) .Or. Empty(aCols[nx][nPosTES])
				Help("  ",1,"A100VZ")
				lRet := .F.
				Exit
			Endif

			// Verifica se nao esta consumindo saldo excedente de NF de compra com entrega futura (TudoOK)
			aSize(aCompFutur, Len(aCols))
			For nZ := 1 To Len(aCompFutur)
				If aCompFutur[nZ] == Nil
					aCompFutur[nZ] := {" "," "," ",0," "}
				EndIf
			Next nZ
			SF4->(DbSetOrder(1))
			SF4->(MsSeek(xFilial("SF4") + aCols[nX][nPosTES]))
			If lDHQInDic .And. lMt103Com .And. SF4->F4_EFUTUR == "2"
				If !A103FutVld(.F., aCompFutur, nX, .T.)
					lRet := .F.
					Exit
				EndIf
			EndIf

			If nPosCod>0 .And. nPosItem>0 .And. lRet .And. SB1->(MsSeek(xFilial("SB1")+aCols[nx][nPosCod])) .And. !RegistroOk("SB1",.F.)
				Aadd(aPrdBlq,aCols[nx][nPosItem])
			Endif

			If !Empty( nPosMed )
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica a existencia de itens de medicao junto com itens sem medicao               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				lItensMed    := lItensMed .Or. aCols[ nX, nPosMed ] == "1"
				lItensNaoMed := lItensNaoMed .Or. aCols[ nX, nPosMed ] $ " |2"

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Ponto de entrada permite incluir itens não-pertinentes ao gct ou não.               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (ExistBlock("MT103GCT"))
					aMT103GCT := ExecBlock("MT103GCT",.F.,.F.,{aCols,nX,nPosMed})

					If ValType(aMT103GCT) == "A"
						If Len(aMT103GCT) >= 1 .And. ValType(aMT103GCT[1]) == "L"
							lItensMed    := aMT103GCT[1]
						EndIf
						If Len(aMT103GCT) >= 2 .And. ValType(aMT103GCT[2]) == "L"
							lItensNaoMed := aMT103GCT[2]
						EndIf
					EndIf
				EndIf

				If lItensMed .And. lItensNaoMed
					Help( " ", 1, "A103MEDIC" )
					lRet := .F.
					Exit
				EndIf
			EndIf
		EndIf

		If lRet .And. !aCols[nx][Len(aCols[nx])]

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se os pedidos amarrados a NFE estao bloqueados "Classificacao" ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRet .And. ( l103Class .Or. INCLUI ) .And. lRestNFE
				SC7->(dbSetOrder(14))
				If SC7->(dbSeek(xFilEnt(xFilial('SC7'))+aCols[nx,nPosPc]) )
					If !(SC7->C7_CONAPRO $ 'L ')
						Help( "", 1, "A120BLQ" )
						lRet := .F.
						Exit
					EndIf
				EndIf
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Valida se o valor do desconto no item D1_VALDESC e maior ou igual ao valor total do item ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRet .And. cPaisLoc == "BRA"
				If aCols[nX,nPValDesc] >= aCols[nX,nPosTotal] .And. aCols[nX,nPValDesc] <> 0
					If SF4->F4_VLRZERO$"2 "
						Aviso("A103VLDESC","OK",{"Ok"}) //"Existe algum item onde o valor de desconto é maior ou igual ao valor total do item, verifique o conteúdo do campo ou realize novo rateio do desconto no folder de descontos/Frete/Despesas."
						lRet := .F.
						Exit
					EndIf
				EndIf
	        EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Valida a Amarração com o Pedido de Compras Centralizado - Referente Central de Compras   |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    If lRet .And. !A103ValPCC(nX)
		   		lRet := .F.
				Exit
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Valida se um item de pedido de compras consta mais de uma vez nos itens do documento e ultrapassa a quantidade do PC ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRet .And. !lVldItPc .And. !l103Class .And. !aCols[nX][Len(aHeader)+1] .And. !Empty(aCols[nX][nPosPc]) .And. !Empty(aCols[nX][nPosItPc])
				If lGrade
					Aadd(aItensPC,{aCols[nX][nPosPc],aCols[nX][nPosItPc],aCols[nX][nPosQtd],aCols[nX][nPosCod]})
					nItemPc  := 0
					nQtdItPc := 0
					For nY := 1 To Len(aItensPC)
						If aScan(aItensPC,{|x| x[1]==aCols[nX][nPosPc] .And. x[2]==aCols[nX][nPosItPc] .And. x[4]==aCols[nX][nPosCod]},nY,1) > 0
							nItemPc++
							nQtdItPc += aItensPC[nY][3]
						EndIf
						If nItemPc > 1
							SC7->(dbSetOrder(4))
							If SC7->(dbSeek(xFilial('SC7')+aCols[nX][nPosCod]+aCols[nY,nPosPc]+aCols[nX][nPosItPc] ))
								If nQtdItPc > ( SC7->C7_QUANT-SC7->C7_QUJE-SC7->C7_QTDACLA) .And. !l103Auto
									Help( "", 1, "A103ITDUPL" )
									lRet := .F.
									Exit
								EndIf
							EndIf
						EndIf
					 Next nY
				Else
					Aadd(aItensPC,{aCols[nX][nPosPc],aCols[nX][nPosItPc],aCols[nX][nPosQtd]})
					nItemPc  := 0
					nQtdItPc := 0
					For nY := 1 To Len(aItensPC)
						If aScan(aItensPC,{|x| x[1]==aCols[nX][nPosPc] .And. x[2]==aCols[nX][nPosItPc]},nY,1) > 0
							nItemPc++
							nQtdItPc += aItensPC[nY][3]
						EndIf
						If nItemPc > 1
							SC7->(dbSetOrder(1))
							If SC7->(dbSeek(xFilial('SC7')+aCols[nY,nPosPc]+aCols[nX][nPosItPc] ))
								If nQtdItPc > ( SC7->C7_QUANT-SC7->C7_QUJE-SC7->C7_QTDACLA) .And. !l103Auto
									Help( "", 1, "A103ITDUPL" )
									lRet := .F.
									Exit
								EndIf
							EndIf
						EndIf
					 Next nY
				Endif
			EndIf

			If lRet
			    lRet := ( Empty(aCols[nX][nPosTES]) .Or. Iif(Posicione("SF4",1,xFilial("SF4")+aCols[nX][nPosTES],"F4_MSBLQL") == '1',;
				ExistCpo("SF4",Alltrim(aCols[nX][nPosTES]),1),.T.) )
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ--¿
		    //³ Verifica se data do movimento n„o ‚ menor que data limite de   ³
			//³ movimentacao no financeiro configurada no parametro MV_DATAFIN |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ--Ù
			If lRet .And. Posicione("SF4",1,xFilial("SF4")+aCols[nX][nPosTES],"F4_DUPLIC") == "S"
				If cNfDtFin == "1"
					lRet:= DtMovFin()
				ElseIf cNfDtFin == "2"
					lRet:= DtMovFin(dDEmissao)
				EndIf
			EndIf

			// Validacao do processo de recusa de mercadoria por parte do destinatario (Devolucao) para notas do tipo B e N
			If lRet .And. cTipo $ "BN" .And. "S" $ aNfeDanfe[24] .And. ( Empty(aCols[nX][nPosNfOri]) .Or. Empty(aCols[nX][nPosSerOri]) .Or. Empty(aCols[nX][nPosItmOri]) )
				Aviso("","",{""})	// "O campo Merc.nao entregue nas Informacoes DANFE deve ser selecionado exclusivamente para devolucoes de mercadoria. Existem itens na nota sem a informacao da respectiva nota de origem."
				lRet := .F.
				Exit
			EndIf

		EndIf
	Next
EndIf

If lRet .And. Len(aPrdBlq) > 0
	If ExistBlock("MT103PBLQ")
		lMT103PBLQ:=ExecBlock("MT103PBLQ",.F.,.F.,{aPrdBlq})
		If ValType(lMT103PBLQ)<>'L'
			lMT103PBLQ:=.F.
		EndIf
		lRet:=lMT103PBLQ
	Else
		For nX:= 1 To Len(aPrdBlq)
			If nX == 1
				cProdsBlq := aPrdBlq[nX]
			Else
				cProdsBlq += " / "+aPrdBlq[nX]
			Endif
		Next

		Aviso("REGBLOQ",OemToAnsi("")+cProdsBlq,{""}, 2) //"Itens Bloqueados: "
		lRet := .F.
	EndIf
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³       Caso a rotina de locação de equipamentos do Gestão de Serviços esteja configurada no ambiente do cliente:      ³
//³ Verifica se na composição das notas fiscais de origem (NF de Saída)  selecionadas para a criação da NF de Devolução  ³
//³ existe algum equipamento de locação que possua a cobrança do serviço prestado através do controle de  apontamento de ³
//³ horimetro.  Caso encontre, verifica se a atualização do valor de sua marcação de retorno está devidamente atualizada ³
//³ no sistema. Só permitirá que a nota de devolução seja gerada para o equipamento cuja atualização do valor de retorno ³
//³ do seu horimetro tenha sido realizada.                                                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .AND. lHasLocEquip
	aOldArea	:= GetArea()
	aAreaTEW	:= TEW->(GetArea())
	cMsgTEW	:= ""
	TEW->(dBSetOrder(5))	//TEW_FILIAL+TEW_NFSAI+TEW_SERSAI+TEW_ITSAI
	For nx := 1 to len(aCols)
		If	TEW->(dBSeek(xFilial("TEW")+aCols[nx][nPosNFOri]+aCols[nx][nPosSerOri]+aCols[nx][nPosItmOri]))
			If !( At970ChkHr(	"RET" /*cFase*/,;
								TEW->TEW_NUMPED /*cNumPV*/,;
								TEW->TEW_ITEMPV /*cItemPV*/,;
								TEW->TEW_ORCSER /*cOrcSer*/,;
								TEW->TEW_CODMV /*cCodMV*/,;
								TEW->TEW_CODEQU /*cCodEqu*/,;
								TEW->TEW_PRODUT /*cProdut*/,;
								TEW->TEW_BAATD /*cBaAtd*/,;
								! l103Auto /*lExibeMsg*/) )
				cMsgTEW	+=	""+" "+TEW->TEW_PRODUT+CRLF+;																//"Produto:"
								""+" "+AllTrim(Posicione("SB1",1,xFilial("SB1")+TEW->TEW_PRODUT,"B1_DESC"))+CRLF+;	//"Descrição:"
								""+" "+AlLTrim(TEW->TEW_BAATD)+CRLF+CRLF													//"Identificação:"
				lRet := .F.
			EndIf
		EndIf
	Next nx
	If	!lRet .AND. l103Auto
		cMsgTEW	:=	""+CRLF+CRLF+;	//"O valor de retorno do horimetro da(s) base(s) de atendimento abaixo relacionada(s) não está atualizado:"
						cMsgTEW+;
						""+CRLF+;		//"Acesse o cadastro das bases de atendimento do módulo de Gestão de Serviços, localize o(s) equipamento(s) desejado(s), e atualize o valor de retorno do seu horimetro."
						""				//"A preparação do documento de entrada desse(s) equipamento(s) somente será permitida após a atualização do valor de retorno do seu horimetro."
		Aviso("A103VLDHRM",cMsgTEW,{"Ok"})
	EndIf
	RestArea(aAreaTEW)
	RestArea(aOldArea)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se ha empenho da OP e dispara o Alerta para continuar. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	For nx:=1 to len(aCols)
		If nPosOp>0 .And. !aCols[nx][Len(aCols[nx])] .And. nX <> n
			If !lGspInUseM .And. lRet .And. !Empty(aCols[nx][nPosOp])
				If ! A103ValSD4(nx)
					lRet := .F. // Corrigido p/ nao alterar o lRet, se .F., novamente p/ .T.
				EndIf
			EndIf
		EndIf
	Next
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Impede a inclusao de documentos sem nenhum item ativo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nItens == 0
	Help("  ",1,"A100VZ")
	lRet := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o preenchimento dos campos.        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(ca100For) .Or. Empty(dDEmissao) .Or. Empty(cTipo) .Or. (Empty(cNFiscal).And.cFormul<>"S") .Or. (lEspObg .And. Empty(cEspecie))
	Help(" ",1,"A100FALTA")
	lRet := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a condicao de pagamento.           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .And. MaFisRet(,"NF_BASEDUP") > 0 .And. Empty(cCondicao) .And. cTipo<>"D"
	Help("  ",1,"A100COND")
	If ( Type("l103Auto") == "U" .Or. !l103Auto )
		oFolder:nOption := 6
	EndIf
	lRet := .F.
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a natureza                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .And. MaFisRet(,"NF_BASEDUP") > 0 .And. Empty(MaFisRet(,"NF_NATUREZA")) .And. cTipo<>"D"
	If SuperGetMV("MV_NFENAT") .And. (!SuperGetMV("MV_MULNATP") .Or. (Type("l103Auto") <> "U" .And. l103Auto))
		Help("  ",1,"A103NATURE")
		If ( Type("l103Auto") == "U" .Or. !l103Auto )
			oFolder:nOption := 6
		EndIf
		lRet := .F.
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica Frete	                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .And. !A103ValFrete()
	lRet:=.F.
EndIf

//Verifica se o Produto e do tipo Munição e se sua Unidade e Caixa
If lRet .And. SuperGetMV("MV_GSXNFE",,.F.)

	aAreaSB5	:= SB5->(GetArea())

	For nX := 1 To Len(aCols)

		DbSelectArea('SB5')
		SB5->(DbSetOrder(1))
		If SB5->(DbSeek(xFilial('SB5')+aCols[nX][nPosCod])) // Filial: 01, Codigo: 000001, Loja: 02
			If SB5->B5_TPISERV=='3' .AND. !At730Prod(aCols[nX][nPosCod])
				Help("  ",1,"AT730Prod")
				lRet := .F.
			EndIf
		EndIf
	Next nX
	RestArea(aAreaSB5)

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o total da NF esta negativo devido ao valor do desconto |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .And. cMRetISS == "1"
	If MaFisRet(,"NF_TOTAL")<0  .Or. (MaFisRet(,"NF_BASEDUP")>0 .And. MaFisRet(,"NF_BASEDUP")-MaFisRet(,"NF_VALIRR")-MaFisRet(,"NF_VALINS")-MaFisRet(,"NF_VALISS")<0)
		Help("  ",1,'TOTAL')
		lRet := .F.
	EndIf
Else
	If lRet .And. MaFisRet(,"NF_TOTAL")<0  .Or. (MaFisRet(,"NF_BASEDUP")>0 .And. MaFisRet(,"NF_BASEDUP")-MaFisRet(,"NF_VALIRR")-MaFisRet(,"NF_VALINS")<0)
		Help("  ",1,'TOTAL')
		lRet := .F.
	EndIf
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-Ä¿
//³ Conforme situacao do parametro abaixo, integra com o SIGAGSP ³
//³             MV_SIGAGSP - 0-Nao / 1-Integra                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÙ
If lRet .And. SuperGetMV("MV_SIGAGSP",.F.,"0") == "1"
	If FindFunction("GSPF030")
		If ! GSPF030()
			lRet := .F. // Corrigido p/ nao alterar o lRet, se .F., novamente p/ .T.
			lContinua	:= lRet
		EndIf
	EndIf
EndIf

If lRet .And. lContinua
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se ha bloqueio em algum item do pco qdo valida for por grade ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If PcoBlqFim({{"000054","07"},{"000054","05"},{"000054","01"}})
		n_SaveLin := n
		For nx:=1 to len(aCols)
			If !aCols[nx][Len(aCols[nx])]
				n := nX
				If lRet
					Do Case
					Case cTipo == "B"
						lRet	:=	PcoVldLan("000054","07","MATA103",/*lUsaLote*/,/*lDeleta*/, .F./*lVldLinGrade*/)
					Case cTipo == "D"
						lRet	:=	PcoVldLan("000054","05","MATA103",/*lUsaLote*/,/*lDeleta*/, .F./*lVldLinGrade*/)
					OtherWise
						lRet	:=	PcoVldLan("000054","01","MATA103",/*lUsaLote*/,/*lDeleta*/, .F./*lVldLinGrade*/)
					EndCase
				Endif
				If !lRet
					Exit
				EndIf
			EndIf
		Next
		n := n_SaveLin
	EndIf
	If lRet
		Do Case
		Case cTipo == "B"
			lRet	:=	PcoVldLan("000054","20","MATA103",/*lUsaLote*/,/*lDeleta*/, .F./*lVldLinGrade*/)
		Case cTipo == "D"
			lRet	:=	PcoVldLan("000054","19","MATA103",/*lUsaLote*/,/*lDeleta*/, .F./*lVldLinGrade*/)
		OtherWise
			lRet	:=	PcoVldLan("000054","03","MATA103",/*lUsaLote*/,/*lDeleta*/, .F./*lVldLinGrade*/)
		EndCase
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Integracao com o PMS     											|
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet .And. IntePms()
		For nX := 1 To Len(aCols)
			If aCols[nX][Len(aCols[nX])] // Item Deletado
				nPosAFN  := Ascan(aRatAFN,{|x|x[1]==(StrZero(nX,4))})
				If nPosAFN >  0
					aDel( aRatAFN, nPosAFN )
					aSize( aRatAFN, Len(aRatAFN)-1)
				Endif
			Endif
		Next nX
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Integracao com o EEC     											|
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( lRet .And. lEECFAT )
		lRet := EECFAT3("VLD",.F.)
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-Ä¿
	//³ Pontos de Entrada 											 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÙ
	If (ExistTemplate("MT100TOK")) .And. lMt100Tok
		lPE := ExecTemplate("MT100TOK",.F.,.F.,{lRet})
		If ValType(lPE) = "L"
			If ! lPE
				lRet := .F. // Corrigido p/ nao alterar o lRet, se .F., novamente p/ .T.
			EndIf
		EndIf
	EndIf

	If nModulo == 72
		lPE := KEXF870(lRet)
		If ValType(lPE) = "L"
			If ! lPE
				lRet := .F. // Corrigido p/ nao alterar o lRet, se .F., novamente p/ .T.
			EndIf
		EndIf
	EndIf

	If lRet .And. (Inclui .Or. l103Class) .And. !(cTipo$"DB")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Valida a verba quando pagto de autonomo                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SA2")
		DbSetOrder(1)
		If MsSeek(xFilial("SA2")+cA100For+cLoja) .And. !Empty(SA2->A2_NUMRA)
			SF4->(DbSetOrder(1))
			For nx:=1 to len(aCols)
				SF4->(MsSeek(xFilial("SF4") + aCols[nX][nPosTES]))
				If SF4->F4_DUPLIC == "S"
					dbSelectArea("SRV")
					dbSetOrder(2)
					MsSeek(xFilial("SRV") + StrZero(1,nTamCodFol),.T.)
					If Eof()
						Help("  ",1,"A103VERBAU")
						lRet := .F.
					Else
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Identifica o funcionario                                     ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  						DbSelectArea("SRA")
						DbSetOrder(13)
						If MsSeek(SA2->A2_NUMRA) .And. FP_CODFOL(@aCodFol,SRA->RA_FILIAL)
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Obtem o codigo da verba                                      ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							cVerbaFol := aCodFol[218,001] //Pagamento de autonomos
						EndIf
					EndIf
					If lRet .And. Empty(cVerbaFol)
					   Help("  ",1,"A103VERBAU")
					   lRet := .F.
					EndIf
					Exit
				EndIf
			Next
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida se documento de entrada tem condicao de pagamento com adiantamento                |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet .and. cPaisLoc $ "BRA|MEX"
			If !cTipo $ "B|D"
				lUsaAdi := A120UsaAdi(cCondicao)
				lRet := A103Adiant(lUsaAdi)
			Endif
		Endif

	If lRet
		If !Empty(cNatValid)
			DbSelectArea("SED")
			DbSetOrder(1)
			DbSeek (xFilial("SED")+cNatValid)

			If !Eof() .And. SED->ED_TIPO == "1"
				Help("  ",1,"A103VLDNAT")
		     	lRet:= .F.
		 	EndIf
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida obrigatoriedade de preenchimento do campo F1_CHVNFE   |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet .And. alltrim(cEspecie) $ "SPED|CTE|CTEOS"
		DbSelectArea("SX3")
		DbSetOrder(2)
		If MsSeek("F1_CHVNFE")
			If SX3->X3_VISUAL == "A" .And. X3Uso(SX3->X3_USADO) .And. (SubStr(BIN2STR(SX3->X3_OBRIGAT),1,1) == "x") .And. Empty(aNfeDanfe[13])
				Aviso("","",{""})
				lRet := .F.
			EndIf
		EndIf

		If lRet .And. lVerChv .And. cFormul == "N" .And. !Empty(aNfeDanfe[13])
			cNFForn := SubStr(aNfeDanfe[13],7,14)			// CNPJ Emitente conforme manual Nota Fiscal Eletrônica
			nNFNota := Val(SubStr(aNfeDanfe[13],26,9))		// Número da nota conforme manual Nota Fiscal Eletrônica
			nNFSerie:= Val(SubStr(aNfeDanfe[13],23,3))		// Série da nota conforme manual Nota Fiscal Eletrônica
			If nNFSerie >= 890 .And. nNFSerie <= 899
				lAvulsa := .T.
			EndIf

			If cTipo == 'B' .Or. cTipo == 'D'
				SA1->(DbSetOrder(1))
				SA1->(MsSeek(xFilial("SA1")+cA100For+cLoja))
				
				If SA1->A1_PESSOA == "J" //Juridico
					cCGC		:= AllTrim(SA1->A1_CGC)
				Else
					cCGC		:= StrZero(Val(SA1->A1_CGC),14)
				Endif
			Else
				If SA2->A2_TIPO == "J" //Juridico
					cCGC		:= AllTrim(SA2->A2_CGC)
				Else
					cCGC		:= StrZero(Val(SA2->A2_CGC),14)
				Endif
			EndIf

			If !Empty(cSerie) 
				If ( cCGC == cNFForn .Or. lAvulsa ) .And. Val(cNFiscal) == nNFNota .And. (Val(cSerie) == nNFSerie) .Or. Existblock("M103ALTS")
					lRet := .T.
				Elseif (cTipo == 'B' .Or. cTipo == 'D') .And. ( cCGC == cNFForn .Or. lAvulsa ) .And. Val(cNFiscal) == nNFNota .And. (Val(cSerie) == nNFSerie) // tratamento para beneficiamento e devolução
					lRet := .T.
				Else
					Aviso("","",{""})
					lRet := .F.
				EndIf
			Else
				Aviso("","",{""})
				lRet := .F.
			EndIf
		ElseIf lRet .And. lVerChv .And. cFormul == "S" .And. !Empty(aNfeDanfe[13])
			Aviso("","",{""})
			lRet := .F.
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valida obrigatoriedade de preenchimento do campo F1_CHVNFE   |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet .And. lVtrasef .And. AllTrim(cEspecie) $ "SPED" .And. cFormul == "S"
		lRet := A103CODRSEF(aHeader,aCols)
	EndIf

	If (ExistBlock("MT100TOK")) .And. lMt100Tok
		lPE := ExecBlock("MT100TOK",.F.,.F.,{lRet})
		If ValType(lPE) = "L"
			If ! lPE
				lRet := .F. // Corrigido p/ nao alterar o lRet, se .F., novamente p/ .T.
			EndIf
		EndIf
	EndIf
	lMt100Tok := .T.

	If lRet
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Bloqueia Pedidos Amarrados ao Processo e checa tolerância ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( INCLUI .Or. ALTERA) .And. !l103Class .And. Type("aRegsLock")<>"U"
			lRet := A103LockPC(aHeader,aCols)
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se a natureza informada esta bloqueado por ED_MSBLQL ou ED_MSBLQD ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet
		SED->(dbSetOrder(1))
		If !Empty(cNatValid) .And. SED->(MsSeek(xFilial("SED")+cNatValid))
			If !RegistroOk("SED")
				lRet := .F.
			EndIf
    	EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Checa se alguma parcela de duplicata gerada pelo documento de entrada já foi lancado ³
	//³manualmente no modulo de Contas a Pagar. Assim para evitar Error Log por chave dupli-³
	//³cada o sistema alerta a existencia do pagamaneto e não insere o documento de entrada.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aArea := GetArea()

	//Verifica se documento gera duplicata
	SF4->(DbSetOrder(1))
	For nX:=1 to len(aCols)
		If SF4->(MsSeek(xFilial("SF4") + aCols[nX][nPosTES])) .And. !aCols[nX][Len(aCols[nX])]
			If SF4->F4_DUPLIC == "S"
				lDuplic := .T.
			EndIf
		EndIf
	Next nX

	/*If lRet .And. lDuplic .And. !Empty(cPrefixo) .And. TamSX3("F1_SERIE")[1] == 3
		cQuery := "Select COUNT(*) QTDUPLIC From "
		cQuery += RetSqlName("SE2")
		cQuery += " Where E2_FILIAL = '" + xFilial("SE2") + "'"
		cQuery += " And E2_NUM      = '" + cNFiscal + "'"
		cQuery += " And E2_PREFIXO  = '" + cPrefixo + "'"
		cQuery += " And E2_FORNECE  = '" + cA100For + "'"
		cQuery += " And E2_LOJA     = '" + cLoja + "'"
		cQuery += " And E2_TIPO     = '" + Left(MVNOTAFIS,nTamTipo) + "'"
		cQuery += " And D_E_L_E_T_  = ' '"

		cQuery	  := ChangeQuery(cQuery)
		cAliasQry := GetNextAlias()
		dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .T., .T. )
		DbSelectArea(cAliasQry)
		(cAliasQry)->(dbGoTop())
		nQtdDupl := (cAliasQry)->QTDUPLIC	//Quantidade de duplicatas lancadas no modulo de Contas a Pagar gerados pela nota.
		dbCloseArea()
		If nQtdDupl > 0
			Help('',1,'A103DVLD')
			lRet := .F.
		EndIf
	EndIf*/
	RestArea(aArea)

	If lRet
		A103DocEmp(aCols,@aDocEmp)
		If Len(aDocEmp) > 0
			lRet := ShowDivNe(aDocEmp,.F.)
		EndIf
	EndIf

EndIf

//Valida Totvs Colaboração
//Classificação de um CT-e onde o valor do frete não sera pago.
If lRet
	//Chave CT-e/NF-e
	SDS->(DbSetOrder(2))
	If SDS->(DbSeek(xFilial("SDS") + Padr(SF1->F1_CHVNFE,TamSx3("DS_CHAVENF")[1])))
		If SDS->DS_FRETE > 0 .And. SDS->DS_TIPO == "T"
			For nX:=1 To Len(aCols)
				If !aCols[nX,Len(aHeader)+1]
					If !Empty(aCols[nX,GdFieldPos("D1_TES")])
						If Posicione("SF4",1,xFilial("SF4") + Padr(aCols[nX,GdFieldPos("D1_TES")],TamSx3("F4_CODIGO")[1]),"F4_DUPLIC") <> "N"
							Aviso("","",{""})
							lRet := .F.
							Exit
						Endif
					Endif
				EndIf
			Next nX
		Endif
	Endif
Endif

// Integracao com SIGAMNT - NG Informatica
If lRet .And. FindFunction("NGPNEULOTE") .And.  ; // Verifica se a funcao NGPNEULOTE esta compilada no fonte MNTUTIL01
	SuperGetMV("MV_NGMNTES") == 'S' .And. ; // Verifica se o Manutencao de Ativos esta integrado com Estoque
	!Empty(GetNewPar("MV_NGPNGR","")) // Verifica se o parametro MV_NGPNGR esta configurado (desta forma sera obrigatorio o preenchimento de dados dos pneus)
	lRet := NGPNEULOTE()
EndIf

If lRet .And. lDivImp
	If cDivImp <> "0"
		For nX:=1 To Len(aCols)
			If aCols[nX,GdFieldPos("D1_LEGENDA")] == "BR_VERMELHO"
				lRet := .F.
				Exit
			EndIf
		Next nX
		If !lRet
			If cDivImp == "1"
				Aviso("",cImpMsg+cImpMsg2,{""})
			ElseIf cDivImp == "2"
				lRet := MsgYesNo(cImpMsg+cImpMsg3)
			Endif
		Endif
	Endif
Endif

//Valida Retenção/Dedução/Faturamento Direto RM
If lRet .And. Type("lTOPDRFRM") <> "U" .And. lTOPDRFRM
	lRet := A103RDFVLD()
Endif

RestArea(aAreaSX3)
RestArea(aAreaSC7)
Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³A103VLDEXC  ³ Autor ³ Julio C.Guerato     ³ Data ³04/02/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Função para Validar se existem vinculos da NFe em outras    ³±±
±±³			 ³tabelas													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T. = Não existem vinculos   				                  ³±±
±±³			 ³.F. = Existe vinculos 	  				                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³Parametros³[01]: Indica se está em exclusão 	                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function A103VldEXC(lExclui,cPrefixo)

Local lRet      := .T.
Local lContinua := .T.
Local nx        := 0
Local nPosCod   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_COD"})
Local nItem     := aScan(aHeader,{|x| AllTrim(x[2])=="D1_ITEM"})
Local cDesc     := ""
Local lVldExc	:= .T.
Local lCpRet	:= .F.

Default cPrefixo := ""

If lExclui

	If ExistBlock("A103VLEX")
		lContinua := ExecBlock("A103VLEX",.F.,.F.)
		If ValType(lContinua) != "L"
			lContinua := .T.
		EndIf
	EndIf

	If lContinua

		//Verifica vinculo com Pedidos de Venda //
		For nX = 1 to len(aCols)
		     DbSelectArea("SC6")
		     DbSetOrder(5)
		     MsSeek(xFilial("SC6")+CA100FOR+CLOJA+aCols[nX][nPosCod]+CNFISCAL+SerieNfId("SF1",4,"F1_SERIE",dDEmissao,cEspecie,cSerie)+aCols[nX][nItem])
		     If !EOF()
		         lRet:=.F.
		         cDesc:= ""+CHR(13)+""+CHR(13)+""+C6_FILIAL+" "+C6_NUM+" "+C6_ITEM+" "+C6_PRODUTO
			     AVISO("A103ValExc",cDesc,{"OK"})
		         Exit
		     EndIf
		Next nX

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Valida se Existe baixa no Contas a Pagar                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRet .And. !A120UsaAdi(cCondicao)
			dbSelectArea("SE2")
			SE2->(dbSetOrder(6))
			SE2->(DbGotop())

			MsSeek(xFilial()+cA100For+cLoja+cPrefixo+SF1->F1_DUPL)

			While ( !Eof() .And.;
				xFilial("SE2")  == SE2->E2_FILIAL  .And.;
				cA100For        == SE2->E2_FORNECE .And.;
				cLoja           == SE2->E2_LOJA    .And.;
				cPrefixo	    == SE2->E2_PREFIXO .And.;
				SF1->F1_DUPL	== SE2->E2_NUM )
				If SE2->E2_TIPO == MVNOTAFIS
					If !FaCanDelCP("SE2","MATA100")
						lRet := .F.
						Exit
					EndIf
				EndIf

				dbSelectArea("SE2")
		   		dbSkip()
			EndDo
		EndIf

		//... Inserir outros Vinculos daqui para baixo .. //

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Valida se a nota gerou um titulo com PCC que compos o saldo ³
		//³ da cumulatividade de outro titulo que ja foi retido         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRet
			dbSelectArea("SE2")
			SE2->(dbSetOrder(6))

			If MsSeek(xFilial("SE2")+cA100For+cLoja+cPrefixo+SF1->F1_DUPL)
				lCpRet := SLDRMSG(SE2->E2_EMISSAO,SE2->E2_VALOR,SE2->E2_NATUREZ,"P",SE2->E2_FORNECE,SE2->E2_LOJA,SE2->E2_TIPO)
				If lCpRet
					If !MSGNoYes("")
						lRet := .F.
					Endif
				Endif
			EndIf

		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se algum produto ja foi distribuido                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	 	If lRet
			If Localiza(SD1->D1_COD)
				dbSelectArea('SDA')
				dbSetOrder(1)
				DbSeek(xFilial()+SD1->D1_COD+SD1->D1_LOCAL+SD1->D1_NUMSEQ+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA)
				If !(SDA->DA_QTDORI == SDA->DA_SALDO)
					Help(" ",1,"SDAJADISTR")
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf

	//Ponto de entrada para validação da exclusão do documento
	If lRet .And. ExistBlock("MT103EXC")
		lVldExc := ExecBlock("MT103EXC",.F.,.F.)
		If ValType(lVldExc) == "L"
			lRet := lVldExc
		EndIf
	EndIf
EndIf

Return lRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A103TmsVld³ Autor ³Eduardo de Souza       ³ Data ³ 30/08/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida exclusao do movimentos de custos de transporte.      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ExpL1 := A103TmsVld( ExpL1 )                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpD1 - Verifica se eh exclusao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SigaTMS                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A103TmsVld(l103Exclui)

Local lRet     := .T.
Local nCnt     := 0
Local aAreaSD1 := SD1->(GetArea())

If l103Exclui .And. IntTMS() // Integracao TMS
	SD1->(DbSetOrder(1))
	For nCnt := 1 To Len(aCols)
		If SD1->(MsSeek(xFilial("SD1")+cNFiscal+SerieNfId("SF1",4,"F1_SERIE",dDEmissao,cEspecie,cSerie)+cA100For+cLoja+GDFieldGet("D1_COD",nCnt)+GDFieldGet("D1_ITEM",nCnt)))
			SDG->(DbSetOrder(7))
			If SDG->(MsSeek(xFilial("SDG")+"SD1"+SD1->D1_NUMSEQ))
				While SDG->(!Eof()) .And. SDG->DG_FILIAL + SDG->DG_ORIGEM + SDG->DG_SEQMOV == xFilial("SDG") + "SD1" + SD1->D1_NUMSEQ
					If SDG->DG_STATUS <> StrZero(1,Len(SDG->DG_STATUS)) //-- Em Aberto
						//-- Caso somente a viagem esteja informada ou Frota, estorna o movimento de custo de transporte.
						If !( Empty(SDG->DG_CODVEI) .And. Empty(SDG->DG_FILORI) .And. Empty(SDG->DG_VIAGEM) ) .And. ;
								!( Empty(SDG->DG_CODVEI) .And. !Empty(SDG->DG_FILORI) .And. !Empty(SDG->DG_VIAGEM) )
							//-- Caso a veiculo seja proprio estorna o movimento de custo de transporte.
							If !Empty(SDG->DG_CODVEI) .And. Empty(SDG->DG_FILORI) .And. Empty(SDG->DG_VIAGEM)
								DA3->(DbSetOrder(1))
								If DA3->(MsSeek(xFilial("DA3")+SDG->DG_CODVEI))
									If DA3->DA3_FROVEI <> "1"
										lRet := .F.
										Exit
									EndIf
								EndIf
							Else
							   //-- Origem MATA103, nao há validação na inclusão pelo TMSA070
								If SDG->DG_ORIGEM <> 'SD1' .And. SDG->DG_ORIGEM <> 'SD3'
									lRet := .F.
									Exit
								EndIf
							EndIf
						EndIf
					EndIf
					SDG->(DbSkip())
				EndDo
			EndIf
		EndIf
	Next nCnt
	RestArea( aAreaSD1 )
EndIf

If !lRet
	Help(" ",1,"A103NODEL") //-- Existe movimento de custo de transporte baixado, nao sera permitida a exclusao.
EndIf

Return lRet


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A103MultOk ³ Autor ³ Sergio Silveira      ³ Data ³11/04/2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Efetua a validacao das multas de contratos                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpL1 := A103MultOk( ExpA1, ExpA2, ExpA3 )                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 -> Array contendo as multas                           ³±±
±±³          ³ ExpA2 -> Acols do SE2 ( titulos )                           ³±±
±±³          ³ ExpA3 -> aHeader do SE2                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpL1 -> Indica validacao                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function NFA103MultOk( aMultas, aColsSE2, aHeadSE2 )

Local aContratos := {}

Local lRet       := .T.

Local nPosPedido := GDFieldPos( "D1_PEDIDO" )
Local nPosItem   := GDFieldPos( "D1_ITEMPC" )
Local nPValor    := GDFieldPos( "E2_VALOR", aHeadSE2 )
Local nLoop      := 0
Local nValDup    := 0
Local nValMult   := 0
Local nValBoni   := 0

If !Empty( aMultas )

	SC7->( DbSetOrder( 1 ) )
	For nLoop := 1 to Len( aCols )

		If !ATail( aCols[ nLoop ] )

			If SC7->( MsSeek( xFilial( "SC7" ) + aCols[ nLoop, nPosPedido ] + aCols[ nLoop, nPosItem ] ) )

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Alimenta o array de medicoes / item desta NF                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty( SC7->C7_CONTRA ) .And. !Empty( SC7->C7_PLANILH )

					If Empty( AScan( aContratos, SC7->C7_CONTRA ) )
						AAdd( aContratos, SC7->C7_CONTRA )
					EndIf

				EndIf

			EndIf

		EndIf

	Next nLoop

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existe alguma multa para um contrato que nao esta na NF    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	For nLoop := 1 to Len( aMultas )

		If Empty( AScan( aContratos, aMultas[ nLoop, 1 ] ) )
			Aviso( "Atencao !", "Nao e possivel inserir multas para um contrato que nao esta nos itens do documento de entrada.", { "OK" }, 2 ) // "Atencao !", "Nao e possivel inserir multas para um contrato que nao esta nos itens do documento de entrada.","Ok"
			lRet := .F.
			Exit

		EndIf

	Next nLoop

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se eh possivel aplicar as multas para o valor de titulos existente ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula o total de multas e / ou bonificacoes de contrato         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AEval( aMultas, { |x| If( x[5] == "1", nValMult += x[3], nValBoni += x[3] ) } )

		If nValMult > nValBoni

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcula a diferenca entre multas e bonificacoes                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nValMult := nValMult - nValBoni

			nValDup := 0

			For nLoop := 1 to Len( aColsSE2 )
				nValDup += aColsSE2[ nLoop, nPValor ]
			Next nLoop

			If nValMult > nValDup
				lRet := .F.
				Aviso( "Atencao !",  "O valor de multas nao pode ser superior ao valor de duplicatas do documento.", { "OK" }, 2 ) // "Atencao !", "O valor de multas nao pode ser superior ao valor de duplicatas do documento.", { "Ok" }
			EndIf

		EndIf

	EndIf

EndIf

Return( lRet )


//-----------------------------------------------------
/*/	Integra o Documento de Entrada com o SIGAGFE
@author Felipe Machado de Oliveira
@version P11
@since 22/05/2013
/*/
//------------------------------------------------------
Static Function A103VlIGfe(lIsIncl,lIsClass, lCommit,cNumNfGFE)
Local lRet := .T.
Local aDados := {}
Local aDadosIten := {}
Local nI := 0
Local cTpFrete := ""
Local nVlrIt	:= 0

Default cNumNfGFE := ""

If Type("aNfeDanfe") == "A"
	If !Empty(aNfeDanfe[14])
		cTpFrete := SubStr(aNFEDanfe[14],1,1)
	Else
		//Se o 'aNfeDanfe[14]' estiver vazio significa que o tipo de frete não foi informado (sem frete)
		//então forcei o "S" para que não haja integração com o GFE
		cTpFrete := "S"
	Endif
Endif

// Tratamento para quando o parametro MV_TPNRNFS = 3 para controlar a numeracao da nota pela SD9
// a variavel cNFiscal estara em branco e o numero da nota estara armazenado em cNumNfGFE
If Empty(cNumNfGFE)
	cNumNfGFE := cNFiscal
EndIf

//Integração Protheus com SIGAGFE
If (cTpFrete <> "S") .And. SuperGetMV("MV_INTGFE",.F.,.F.) .And. SuperGetMV("MV_INTGFE2",.F.,"2") $ "1" .And. SuperGetMv("MV_GFEI10",.F.,"2") == "1" .And. (lIsIncl .Or. lIsClass) .And. !(AllTrim(cTipo) $ 'I|P')
	aAdd(aDados, AllTrim(cTipo)    + Space( (TamSX3("F1_TIPO")[1])   - (Len( AllTrim(cTipo) )) ) )     	//F1_TIPO
	aAdd(aDados, AllTrim(cFormul)  + Space( (TamSX3("F1_FORMUL")[1]) - (Len( AllTrim(cFormul) )) ) )   	//F1_FORMUL
	aAdd(aDados, AllTrim(cNumNfGFE) + Space( (TamSX3("F1_DOC")[1])    - (Len( AllTrim(cNumNfGFE) )) ) )  	//F1_DOC
	aAdd(aDados, AllTrim(cSerie)   + Space( (TamSX3("F1_SERIE")[1])  - (Len( AllTrim(cSerie) )) ) )    	//F1_SERIE
	aAdd(aDados, dDEmissao )                                                                           		//F1_EMISSAO
	aAdd(aDados, AllTrim(cA100For) ) 																		//F1_FORNECE
	aAdd(aDados, AllTrim(cLoja) )    																		//F1_LOJA
	aAdd(aDados, AllTrim(cEspecie) + Space( (TamSX3("F1_ESPECIE")[1]) - (Len( AllTrim(cEspecie) )) ) ) 	//F1_ESPECIE
	aAdd(aDados, "" )                                                                                  		//F1_NFORIG
	aAdd(aDados, aNFEDanfe[1] )                        														//F1_TRANSP
	aAdd(aDados, aNFEDanfe[5] )                        														//F1_VOLUME1
	aAdd(aDados, SubStr(aNFEDanfe[14],1,1) )         														//F1_TPFRETE
	aAdd(aDados, IIF(Empty(SF1->F1_VALICM),0,SF1->F1_VALICM) ) 											//F1_VALICM
	aAdd(aDados, xFilial("SF1") )
	aAdd(aDados, "" )                                  	 													//F1_SERORIG
	aAdd(aDados, aNFEDanfe[13] )                       	 													//F1_CHVNFE

	For nI := 1 to Len(aCols)
		If !aCols[nI][Len(aCols[nI])]

			If Posicione("SF4",1,xFilial("SF4") + GDFieldGet("D1_TES",nI),"F4_INCSOL") == "S"
				nVlrIt := GDFieldGet("D1_TOTAL",nI)+GDFieldGet("D1_ICMSRET",nI)+GDFieldGet("D1_VALIPI",nI)
			Else
				nVlrIt := GDFieldGet("D1_TOTAL",nI)+GDFieldGet("D1_VALIPI",nI)
			Endif

			aAdd(aDadosIten, { 	GDFieldGet("D1_ITEM",nI) ,;
						    GDFieldGet("D1_COD",nI)  ,;
						    GDFieldGet("D1_QUANT",nI),;
						    nVlrIt,;
						    GDFieldGet("D1_TES",nI)  ,;
						    GDFieldGet("D1_PESO",nI)  ,;
						    GDFieldGet("D1_CF",nI) })
		EndIf
	Next nI

	lRet := OMSM011NFE("UNICO",aDados,aDadosIten,,,,lCommit)

EndIf

Return lRet


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun??o    ³NfeFormul ³Autor  ³ Eduardo Riera         ³ Data ³16.09.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de validacao do formulario proprio do documento de    ³±±
±±³          ³entrada                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Formulario proprio (S/N)                              ³±±
±±³          ³ExpC2: Numero do documento de entrada                        ³±±
±±³          ³ExpA3: Serie do documento de entrada                         ³±±
±±³          ³ExpO4: Objeto say para atualizar o texto                     ³±±
±±³          ³ExpO5: Objeto Get para atualizar o codigo do fornecedor      ³±±
±±³          ³ExpO6: Objeto Get para atualizar o codigo da loja            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Formulario valido                                     ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³Esta rotina tem como objetivo validar se o formulario eh pro-³±±
±±³          ³prio ( S/N )                                                 ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function NfeFormul(cFormul,cNota,cSerie,oNFiscal,oSerie)
Local cXEspecie:=""

If Type("cFunTipo") == "U"
	Static cFunTipo := ""
EndIf

If cFormul == "S"
	cNota		:= CriaVar("F1_DOC",.F.)
	cSerie  	:= SerieNfId("SF1",5,"F1_SERIE")
EndIf

//---------------------------//
//Ponto de Entrada: MT103ESP //
//---------------------------//
If ExistBlock("MT103ESP")     
	cXEspecie := ExecBlock("MT103ESP",.F.,.F.,{cFormul})    
	If (ValType(cXEspecie) == 'C' )
		cEspecie := Padr(cXEspecie,TamSX3("F1_ESPECIE")[1])
	EndIf
EndIf

If oNFiscal<>Nil
	oNFiscal:Refresh()
EndIf
If oSerie<>Nil
	oSerie:Refresh()
EndIf             
If oNFiscal<>Nil .And. Empty(cFunTipo)
	IF cFormul == "N"
		oNFiscal:Setfocus()
	EndIf
EndIf

cFunTipo:= ""

Return(.T.)    


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun??o    ³MaCanDelF1³ Autor ³ Edson Maricate        ³ Data ³11.10.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Rotina de validacao da exclusao de uma nota fiscal de entrada³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Numero do Registro do SF1.                       (OPC)³±±
±±³          ³ExpA2: Array com os pedidos de venda gerados a partir da nota³±±
±±³          ³       fiscal de entrada.                               (OPC)³±±
±±³          ³ExpA3: Array com os titulos financeiro gerados          (OPC)³±±
±±³          ³ExpL4: Indica se pode apagar notas de conhec de frete   (OPC)³±±
±±³          ³ExpL5: Indica se pode apagar notas de despesas de import(OPC)³±±
±±³          ³ExpL6: Indica se estou apagando um remito (localizacoes)(OPC)³±±
±±³          ³ExpL7: Indica se se trata de un retorno simbolico automatico,³±±
±±³          ³       no caso de ser, o retorno pode ser apagado.           ³±±
±±³          ³ExpA8: Array contendo os recnos dos titulos no SE1(devolucao)³±±
±±³          ³ExpL9: Indica se a exclusao esta sendo feita pelo SIGAEIC    ³±±
±±³          ³ExpL10:Indica se a exclusao esta sendo feita pelo SIGATMS    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Indica se a nota pode ser excluida                    ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri??o ³Esta rotina tem como objetivo validar a exclusao de uma Nota ³±±
±±³          ³fiscal de entrada/Documento de entrada.                      ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Materiais                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function MaCanDelF1(nRecSF1,aRecSC5,aRecSE2,lCanDelFr,lCanDelDp,lRemito,lRSAuto,aRecSe1,lExcViaEIC,lExcViaTMS)
Local lEofSD3   := .T.
Local aArea		:= GetArea()
Local aAreaSD1	:= SD1->(GetArea())
Local aAreaSF8	:= SF8->(GetArea())
Local aStruSD1  := {}
Local aStruSE2  := {}

Local lQuery    := .F.
Local lRetorno	:= .F.
Local lRetAPO   := .T.
Local l100Del	:= ExistBlock("A100DEL")  
Local lM103APO  := ExistBlock("M103APO")
Local lIntACD	:= SuperGetMV("MV_INTACD",.F.,"0") == "1"
Local lEstNeg   := (SuperGetMv("MV_ESTNEG")=="S")
Local lEECFAT	:= SuperGetMv("MV_EECFAT",.F.,.F.)
Local lForpcnf	:= SuperGetMV("MV_FORPCNF",.F.,.F.)
Local lR103ENEG := .F.
Local dDataFec	:= MVUlmes()
Local dDataVenc
Local dDataIni
Local dDataFim
Local lShowAviso:= (SuperGetMv("MV_AV10925",.T.,"2") == "1")
Local cLocTran  := SuperGetMV("MV_LOCTRAN",.F.,"95")
Local lAviso    := .F.
Local lAvisoISS := .F.
Local lVldRetISS:= .F.
Local lRetISSMes:= 	GetNewPar("MV_MODRISS","1") == "2"
Local lBxCaucGct:= .F.
Local dDataBloq	:= GetNewPar("MV_ATFBLQM",CTOD(""))

Local nPosLote	:= 0
Local nX		:= 0
Local nSldTran  := 0
Local nSldLote  := 0
Local aLotes	:= {}
Local cMensagem := ""
Local cPrefixo  := ""
Local cQuery    := ""
Local cAliasSD1 := "SD1"
Local cAliasSE2 := "SE2"
Local nRecSD1
Local nAcICMSAPR:= 0	
Local aAreaSN1  := {}
Local aRetXFin  := {}
Local cTesDR    := GetMV("MV_TESDR",,"")
Local lNumTrib	:= .T.
Local cNumTit	:= ""
Local cFilCTR   := ""
Local aAreaSE2IR
Local nRecE2in

Local cSepNeg   := If("|"$MV_CPNEG,"|",",")
Local cSepProv  := If("|"$MVPROVIS,"|",",")
Local cSepRec   := If("|"$MVPAGANT,"|",",")

Local nCountSE2 := 0
Local lPriParAdtBx := .F.
Local nValorAdtFR3 := 0

Local nContDoc := 0

local nTamPref := TamSX3("E2_PREFIXO")[1]
local cPrefPIS := PadR(SuperGetMV("MV_PREFPIS",.F.,"PIS"), nTamPref)
local cPrefCOF := PadR(SuperGetMV("MV_PREFCOF",.F.,"COF"), nTamPref)
local cPrefISS := PadR(SuperGetMv("MV_PREFISS",.F.,"ISS"), nTamPref)
local cPreFase := PadR(SuperGetMv("MV_PREFASE",.F.,"TX"), nTamPref)
local nQtdTit  := 0
local nQtdTot  := 0
Local cNatGilRat := ''
Local aNats		:= {}
Local lIntGC	 := IIf((SuperGetMV("MV_VEICULO",,"N")) == "S",.T.,.F.)
Local cE1Cliente := "" // Quando integrado com DMS, o cliente pode ser outro se utilizado condicao de pagamento TIPO A na venda.
Local cE1Loja    := "" // Quando integrado com DMS, o cliente pode ser outro se utilizado condicao de pagamento TIPO A na venda.
Local cE1NReduz  := "" // Quando integrado com DMS, o cliente pode ser outro se utilizado condicao de pagamento TIPO A na venda.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Analisa os parametros da Rotina                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFAULT aRecSC5    := {}
DEFAULT aRecSE1    := {}
DEFAULT aRecSE2    := {}
DEFAULT lCanDelFr  := .F.
DEFAULT lCanDelDp  := .F.
DEFAULT lRemito    := .F.          
DEFAULT lExcViaEIC := .F. 
DEFAULT lExcViaTMS := .F.                          

If Type("cTipo") == "U"
	cTipo:= SF1->F1_TIPO
EndIf

If nRecSF1 <> Nil
	dbSelectArea("SF1")
	MsGoto(nRecSF1)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajusta a Pesquisa das Notas de Conhecimento de Frete e D.I.  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SF8->(dbSetOrder(2))
Do Case
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a NF possui NF de Conhec. e Desp. de Import.     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Case !lCanDelFr .And. ((SF8->(MsSeek(xFilial("SF8")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_TIPO)) .And. SF1->F1_TIPO != "C" ) ) // ;
 		//.Or. A103CTECOL(SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FILIAL,SF1->F1_FORNECE,SF1->F1_LOJA+SF1->F1_TIPO) )		//FR - 16/08/2021 - #11100 - TRIGO ARTE
	Help(" ", 1, "A103CAGREG")
	lRetorno := .F.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Nao excluir NF incluida pelo MATA910                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Case SF1->F1_ORIGLAN == "LF"
	Help("  ",1,"NAOCOM")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Nao excluir NF nao classificada                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Case Empty(SF1->F1_STATUS)
	Help(" ",1,"A100NOCLAS")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verificar data do ultimo fechamento em SX6                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Case dDataFec>=dDataBase .Or. dDataFec>=SF1->F1_DTDIGIT
	Help( " ", 1, "FECHTO" )
	lRetorno := .F.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica ultima data para operacoes fiscais                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Case !FisChkExc(SF1->F1_SERIE,SF1->F1_DOC,SF1->F1_FORNECE,SF1->F1_LOJA,,"E")
	lRetorno := .F.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Integracao com o ACD		  				  	  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Case lIntACD .And. !(CBA100DEL())
	lRetorno := .F.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Template acionando ponto de entrada                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Case ExistTemplate("A100DEL") .And. !(ExecTemplate("A100DEL",.F.,.F.))				
	lRetorno := .F.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de entrada para permitir ou nao a exclusao             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Case l100Del .And. !(Execblock("A100DEL",.F.,.F.))
	lRetorno := .F.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Nao excluir nota de Frete Gerada pela rotina MATA116         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Case SF1->F1_TIPO == "C" .And. SF1->F1_ORIGLAN == "F "  .And. !lCanDelFr
	Help(" ",1,"A100NDELFR")
	lRetorno := .F.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Nao excluir nota de Despesas de Importacao                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Case SF1->F1_TIPO == "C" .And. SF1->F1_ORIGLAN == " D"	.And. !lCanDelDp
	Help(" ",1,"A100NDELDP")
	lRetorno := .F.
	//ÚLocalizacoesÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Nao excluir NF (de devolucao ou retorno) que gerou PV se este³
	//³ ainda existe.                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Case !lRsAuto .And. !Empty(SF1->F1_PEDVEND) .And. (SF1->F1_PEDVEND == "AUTO  " .Or. Eval( {|| SC5->(DbSetORder(1)),SC5->(MsSeek(xFilial("SC5")+SF1->F1_PEDVEND) ) }) )
	If SF1->F1_PEDVEND <> "AUTO  "
		Help(" ",1,"A103PV" ,,RetTitle("C9_PEDIDO") + "  " + SF1->F1_PEDVEND,04,02)
	Else
		Help(" ",1,"A103CONS" )
	Endif
	lRetorno	:=	.F.
OtherWise
	lRetorno := .T.
EndCase   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se Documento de Entrada Original está vinculado aos outros Documentos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRetorno
	lQuery    := .T.
	cAliasSD1 := GetNextAlias()

	If Select(cAliasSD1) > 0 
		dbSelectArea(cAliasSD1)
	    dbCloseArea()
	EndIf
	        
	cQuery    := "SELECT COUNT(*) NOTAORI  "
	cQuery    += "  FROM "+RetSqlName("SD1")+" SD1 "
	cQuery    += " WHERE SD1.D1_FILIAL  = '"+xFilial("SD1")+"'"
	cQuery    += "   AND SD1.D1_NFORI   = '"+SF1->F1_DOC+"'"
	cQuery    += "   AND SD1.D1_SERIORI = '"+SF1->F1_SERIE+"'"
	cQuery    += "   AND SD1.D1_FORNECE = '"+SF1->F1_FORNECE+"'"
	cQuery    += "   AND SD1.D1_LOJA    = '"+SF1->F1_LOJA+"'"
	cQuery    += "   AND SD1.D1_DOC||SD1.D1_SERIE||SD1.D1_FORNECE||SD1.D1_LOJA <>'"
	cQuery    += SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+"'"
	cQuery    += "   AND SD1.D1_TIPO IN ('P','I','C') "
	cQuery    += "   AND SD1.D_E_L_E_T_=' ' "
	
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSD1, .T., .T. )      
	
	If ctipo != "C" 
		If (cAliasSD1)->NOTAORI > 0 
		   	Help(' ',1,'A103NEXCOR') 
		   	lRetorno := .F.
		EndIf
	EndIf
	(cAliasSD1)->(dbCloseArea())
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Analisa os itens da Nota fiscal de Entrada                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SD1")
dbSetOrder(1)

lQuery    := .T.
cAliasSD1 := "MACANDELF1"
aStruSD1  := SD1->(dbStruct())
cQuery    := "SELECT SD1.*,SD1.R_E_C_N_O_ SD1RECNO "
cQuery    += "  FROM "+RetSqlName("SD1")+" SD1 "
cQuery    += " WHERE SD1.D1_FILIAL   = '"+xFilial("SD1")+"'"
cQuery    += "   AND SD1.D1_DOC	     = '"+SF1->F1_DOC+"'"
cQuery    += "   AND SD1.D1_SERIE    = '"+SF1->F1_SERIE+"'"
cQuery    += "   AND SD1.D1_FORNECE  = '"+SF1->F1_FORNECE+"'"
cQuery    += "   AND SD1.D1_LOJA	 = '"+SF1->F1_LOJA+"'"
cQuery    += "   AND SD1.D1_TIPO	 = '"+SF1->F1_TIPO+"'"
cQuery    += "   AND SD1.D_E_L_E_T_	 = ' ' "
cQuery    += "ORDER BY "+SqlOrder(SD1->(IndexKey()))

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD1,.T.,.T.)

For nX := 1 To Len(aStruSD1)
	If aStruSD1[nX][2]<>"C"
		TcSetField(cAliasSD1,aStruSD1[nX][1],aStruSD1[nX][2],aStruSD1[nX][3],aStruSD1[nX][4])
	EndIf
Next nX

While !Eof().And. (cAliasSD1)->D1_FILIAL == xFilial('SD1') .And.;
		(cAliasSD1)->D1_DOC == SF1->F1_DOC .And.;
		(cAliasSD1)->D1_SERIE == SF1->F1_SERIE .And.;
		(cAliasSD1)->D1_FORNECE == SF1->F1_FORNECE .And.;
		(cAliasSD1)->D1_LOJA == SF1->F1_LOJA .And. lRetorno

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a O.P. vinculada a uma N.F. esta encerrada     ³
	//³ ou se ja possui quantidade apontada.                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If !(SuperGetMV("MV_PRNFBEN",.F.,.F.))
		dbSelectArea("SC2")
		dbSetOrder(1)
		If MsSeek(xFilial("SC2")+(cAliasSD1)->D1_OP) .And. !lCanDelFr
			If !Empty(SC2->C2_DATRF)
				Help("",1,"A103ENCERR")
				lRetorno := .F.
			ElseIf QtdComp(SC2->C2_QUJE,.T.) > QtdComp(0,.T.)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ`¿
				//³Ponto de entrada que permite ou não a validação da exclusão da NF vinculada a uma OP³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ`Ù
				If lM103APO
					lRetAPO := ExecBlock("M103APO",.F.,.F.)										
					If ValType(lRetAPO)<> "L"
						lRetAPO := .T.
					Endif
				EndIf
				If lRetApo .And.(Type('l103Auto') <> 'U' .And. l103Auto) .Or. Aviso(OemToAnsi(""),OemToAnsi("")+(cAliasSD1)->D1_OP+OemToAnsi(""),{OemToAnsi(""),OemToAnsi("")},nil,nil,1) == 2
					lRetorno := .F.
				EndIf
			EndIf
		EndIf		
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ AvalMovDiv - Funcao utilizada para avaliar possiveis divergencias de     |
	//|              saldo no estorno do movimento selecionado.                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !(SF1->F1_TIPO$"PIC") .And. AvalMovDiv((cAliasSD1)->D1_COD,(cAliasSD1)->D1_LOCAL,(cAliasSD1)->D1_LOTECTL,(cAliasSD1)->D1_NUMLOTE,(cAliasSD1)->D1_NUMSEQ,(cAliasSD1)->D1_TES)
		lRetorno := .F.
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona o Arquivo SF4.                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea('SF4')
	dbSetOrder(1)
	MsSeek(xFilial("SF4")+(cAliasSD1)->D1_TES)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a posicao do Pedido de Vendas  (Devolucao)          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno .And. !Empty((cAliasSD1)->D1_NUMPV)
		dbSelectArea('SC5')
		If MsSeek(xFilial("SC5")+(cAliasSD1)->D1_NUMPV)
			aAdd(aRecSC5,SC5->(RecNo()))
		EndIf
		dbSelectArea('SC6')
		dbSetOrder(1)
		If MsSeek(xFilial("SC6")+(cAliasSD1)->D1_NUMPV+(cAliasSD1)->D1_ITEMPV)
			If SC6->C6_QTDLIB+SC6->C6_QTDENT <> 0
				If (Type('l103Auto') <> 'U' .And. l103Auto) .Or. Aviso(OemToAnsi(""),OemToAnsi(""),{OemToAnsi(""),OemToAnsi("")}) == 2 //"O pedido de vendas gerado pelo Docto. de devolucao ja foi liberado ou atendido e nao sera excluido. Deseja continuar ?"###"Continua"###"Abandona"
					lRetorno := .F.
					Exit
				EndIf
			EndIf
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Trava os registros do SC7.                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno .And. !Empty((cAliasSD1)->D1_PEDIDO)
		dbSelectArea('SC7')
		dbSetOrder(19)
		If MsSeek(xFilial('SC7')+(cAliasSD1)->D1_COD+(cAliasSD1)->D1_PEDIDO+(cAliasSD1)->D1_ITEMPC)
			cFilCTR := CNTBuscFil(xFilial('CND'), SC7->C7_MEDICAO)
			If !lBxCaucGct .And. CN9->(DbSeek(cFilCTR + SC7->(C7_CONTRA + C7_CONTREV)))
				lBxCaucGct := CN9->CN9_FLGCAU == "1" //Quando oriundo de contrato com caução não deve validar a exclusão do título a pagar
			EndIf
			If !SoftLock('SC7')
				lRetorno := .F.
			EndIf
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Trava os registros do SD7 e SD3                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno .And. !Empty((cAliasSD1)->D1_NUMCQ)
		dbSelectArea("SD7")
		dbSetOrder(1)
		If MsSeek(xFilial("SD7")+(cAliasSD1)->D1_NUMCQ+(cAliasSD1)->D1_COD+(cAliasSD1)->D1_LOCAL)
			While !Eof() .And.lRetorno .And. xFilial("SD7") == SD7->D7_FILIAL .And.;
					(cAliasSD1)->D1_NUMCQ == SD7->D7_NUMERO .And.;
					(cAliasSD1)->D1_COD == SD7->D7_PRODUTO .And.;
					(cAliasSD1)->D1_LOCAL == SD7->D7_LOCAL
				If ((cAliasSD1)->D1_TIPO $ 'NBD' .or. (cAliasSD1)->D1_TIPO == 'C' .and. SF1->F1_TPCOMPL == '2') .And.;
				   (SD7->D7_TIPO==1 .Or. SD7->D7_TIPO==2 ) .And. Empty(SD7->D7_ESTORNO)	
					Help(' ',1,'A100CQ')
					lRetorno := .F.
					Exit
				ElseIf !SoftLock("SD7")
					lRetorno := .F.
					Exit
				Else
					dbSelectArea("SD3")
					dbSetOrder(4)
					If lRetorno .And. MsSeek(xFilial("SD3")+SD7->D7_NUMSEQ)
						While !Eof() .And. lRetorno .And. SD3->D3_FILIAL == xFilial("SD3") .And.;
								SD3->D3_NUMSEQ == SD7->D7_NUMSEQ
							If !SoftLock("SD3")
								lRetorno := .F.
								Exit
							EndIf
							dbSelectArea("SD3")
							dbSkip()
						EndDo
					EndIf
				EndIf
				dbSelectArea("SD7")
				dbSkip()
			EndDo
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a existencia de Poder de Terceiros                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno .And. SF4->F4_PODER3=="R"
		dbSelectArea("SB6")
		dbSetOrder(3)
		MsSeek(xFilial("SB6")+(cAliasSD1)->D1_NUMSEQ+(cAliasSD1)->D1_COD+'R')
		While ( !Eof() .And. lRetorno .And. xFilial("SB6") == SB6->B6_FILIAL .And.;
				(cAliasSD1)->D1_NUMSEQ==SB6->B6_IDENT .And.;
				(cAliasSD1)->D1_COD==SB6->B6_PRODUTO .And.;
				"R"==SB6->B6_PODER3 )
			If SB6->B6_QUANT<>SB6->B6_SALDO .And. SB6->B6_TIPO=="D"
				Help(' ',1,'A520NPODER')
				lRetorno := .F.
			EndIf
			dbSelectArea("SB6")			
			dbSkip()
		EndDo
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Integracao do Ativo Fixo - Travamento                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno .And. (ExistBlock ("M103XATF"))
		lRetorno	:=	ExecBlock ("M103XATF", .F., .F., {cAliasSD1})
	Else
		If lRetorno .And. !Empty((cAliasSD1)->D1_CBASEAF)
			//lRetorno := M103XAFEXC((cAliasSD1)->D1_DOC,(cAliasSD1)->D1_SERIE,(cAliasSD1)->D1_FORNECE,(cAliasSD1)->D1_LOJA,(cAliasSD1)->D1_COD)
			lRetorno := .T. // NÃO TEM ESTA FUNÇÃO NO PROJETO M103XAFEXC((cAliasSD1)->D1_DOC,(cAliasSD1)->D1_SERIE,(cAliasSD1)->D1_FORNECE,(cAliasSD1)->D1_LOJA,(cAliasSD1)->D1_COD)
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica a existencia do CIAP                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRetorno .And. !Empty((cAliasSD1)->D1_CODCIAP)
			dbSelectArea('SF9')
			dbSetOrder(1)
			If MsSeek(xFilial("SF9")+(cAliasSD1)->D1_CODCIAP)
				If !Empty( SN1->N1_CODCIAP ) .Or. !Empty((cAliasSD1)->D1_CODCIAP)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Este WHILE se deve ao desmabrento no ativo fixo(SN1) pela quantidade.³
					//³A tabela SN1 eh posicionada logo acima                               ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nAcICMSAPR	:=	0
					aAreaSN1	:=	SN1->(GetArea ())
					
					If Alltrim(SN1->N1_NFESPEC) == ""
						DbSelectArea("SN1")
						DbSetOrder(8)
						If !DbSeek(xFilial("SN1")+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA+ "     " +(cAliasSD1)->D1_DOC+(cAliasSD1)->D1_SERIE+(cAliasSD1)->D1_ITEM)
							RestArea (aAreaSN1)						
						EndIf	
					Else
					 	If (cAliasSD1)->D1_CODCIAP<>SN1->N1_CODCIAP
							DbSelectArea("SN1")
							DbSetOrder(4)
							If !DbSeek(xFilial("SN1")+(cAliasSD1)->D1_CODCIAP)
								RestArea (aAreaSN1)						
							EndIf
						EndIf
					EndIf
					
					Do While !SN1->(Eof ()) .And.;
						(cAliasSD1)->D1_CODCIAP==SN1->N1_CODCIAP
						nAcICMSAPR	+=	SN1->N1_ICMSAPR
						
						SN1->(DbSkip ())
					EndDo
					RestArea (aAreaSN1)
					If  (((!Empty((cAliasSD1)->D1_CBASEAF) .And. SF9->F9_ICMIMOB <> nAcICMSAPR).Or.(Empty((cAliasSD1)->D1_CBASEAF) .And.SF9->F9_ICMIMOB <> 0)).Or.;
							SF9->F9_BXICMS <> 0 .Or. SF9->F9_MOTIVO <> " " .Or. SF9->F9_VLESTOR <> 0)
						Help("  ",1,"A100CIAPDE")
						lRetorno := .F.
					EndIf
				EndIf				
			EndIf
		EndIf
	EndIf
	//Verifica se existe bloqueio contabil - Validacao incluida em 03/08/2015 changeset 320011 release 12
	If lRetorno .And. SF4->F4_ATUATF == "S" .And. !Empty(dDataBloq) .And. (cAliasSD1)->D1_DTDIGIT <= dDataBloq
		Help(" ",1,"ATFCTBBLQ")	// Processo bloqueado pelo Calendario Contabil ou parametro de bloqueio nesta data ou periodo.
		lRetorno := .F.
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se algum produto esta sendo inventariado.           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno .And. BlqInvent((cAliasSD1)->D1_COD,(cAliasSD1)->D1_LOCAL)
		Help("  ",1,"BLQINVENT",,(cAliasSD1)->D1_COD+"Armazem: "+(cAliasSD1)->D1_LOCAL,1,11) //"Armazem: "
		lRetorno := .F.
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se algum produto ja foi distribuido                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Localiza((cAliasSD1)->D1_COD)
		dbSelectArea('SDA')
		dbSetOrder(1)
		If lRetorno .And. MsSeek(xFilial("SDA")+(cAliasSD1)->D1_COD+(cAliasSD1)->D1_LOCAL+(cAliasSD1)->D1_NUMSEQ+(cAliasSD1)->D1_DOC+(cAliasSD1)->D1_SERIE+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA)
			If !(SDA->DA_QTDORI == SDA->DA_SALDO)
				Help(" ",1,"SDAJADISTR")
				lRetorno := .F.
			EndIf
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a quantidade devolvida.                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno .And. ((cAliasSD1)->D1_QTDEDEV <> 0 .Or. (cAliasSD1)->D1_VALDEV <> 0)
		Help(' ',1,'NAOEXCL')
		lRetorno := .F.
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica a quantidade clasificada (remitos de localizacoes)  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno .And. lRemito .And. (cAliasSD1)->D1_QTDACLA <> (cAliasSD1)->D1_QUANT
		Help(' ',1,'NAOEXCLREM')
		lRetorno := .F.
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o remito esta amarrada a alguma nota de Credito  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno .And. lRemito
		SD1->(DbSetOrder(10))
		If SD1->(MsSeek(xFilial("SD1")+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA+(cAliasSD1)->D1_SERIE+(cAliasSD1)->D1_DOC))
			Help(' ',1,'NAOEXCLREM',,SD1->D1_ESPECIE+" "+SerieNfId("SD1",2,"D1_SERIE")+"/"+SD1->D1_DOC,1,11)
			lRetorno := .F.
		Endif
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o Servico do WMS.                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno .And. !Empty((cAliasSD1)->D1_SERVIC) .And. IntWMS() .And. cTipo $ "N|D|B" .And. SF4->F4_ESTOQUE == "S"
		lRetorno := WmsAvalSD1("7",cAliasSD1)
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Totaliza no array aLotes para validar a exclusao.            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno .And. Rastro((cAliasSD1)->D1_COD).And. SF4->F4_ESTOQUE=='S'
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ aLotes[nx][1] : Codigo do Produto        ³
		//³ aLotes[nx][2] : Almoxarifado             ³
		//³ aLotes[nx][3] : Lote                     ³
		//³ aLotes[nx][4] : SubLote                  ³
		//³ aLotes[nx][5] : OP                       ³
		//³ aLotes[nx][6] : Numero Sequencial        ³
		//³ aLotes[nx][7] : Quantidade               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nPosLote :=Ascan(aLotes,{|x| x[1]+x[2]+x[3]+x[4]==(cAliasSD1)->D1_COD+(cAliasSD1)->D1_LOCAL+(cAliasSD1)->D1_LOTECTL+(cAliasSD1)->D1_NUMLOTE+(cAliasSD1)->D1_OP+(cAliasSD1)->D1_NUMSEQ})
		If nPosLote > 0
			aLotes[nPosLote][7] += (cAliasSD1)->D1_QUANT
		Else
			aADD(aLotes,{(cAliasSD1)->D1_COD,(cAliasSD1)->D1_LOCAL,(cAliasSD1)->D1_LOTECTL,(cAliasSD1)->D1_NUMLOTE,(cAliasSD1)->D1_OP,(cAliasSD1)->D1_NUMSEQ,(cAliasSD1)->D1_QUANT})
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se Sld no B2 ficar  Neg. ou Menor que Sld em Reserva³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno .And. SF4->F4_ESTOQUE == "S" .And. (cAliasSD1)->D1_QUANT > 0
		SB2->(dbSetOrder(1))
		If SB2->(MsSeek(xFilial('SB2')+(cAliasSD1)->D1_COD+(cAliasSD1)->D1_LOCAL, .F.))
			nSaldoB2 := (SB2->B2_QATU-(cAliasSD1)->D1_QUANT)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se existe movimento de requisicao do material para a OP³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty((cAliasSD1)->D1_OP) .OR. (IntePms() .and. PmsExAFN(cAliasSD1))
				SD3->(dbSetOrder(4))
				If SD3->(dbSeek(xFilial("SD3")+(cAliasSD1)->D1_NUMSEQ))
					nSaldoB2 += SD3->D3_QUANT
				EndIf
			EndIf                                                        
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se existe movimento de material em Transito            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (cAliasSD1)->D1_TRANSIT == 'S'
				SD3->(dbSetOrder(4))
				If SD3->(dbSeek(xFilial("SD3")+(cAliasSD1)->D1_NUMSEQ))
					nSaldoB2 += SD3->D3_QUANT
				EndIf
			EndIf                                        

			If !SuperGETMV("MV_NEGATBF",.F.,.F.)                                       
			If QtdComp(nSaldoB2)<QtdComp(0)
			    If lEstNeg  //Permite Estoque Negativo
			        If (Rastro((cAliasSD1)->D1_COD) .Or. Localiza((cAliasSD1)->D1_COD))  // MV_ESTNEG = S e Produto com Rastro / Localização, não permite estoque negativo
						If !(Type('l103Auto') <> 'U' .And. l103Auto)
							Aviso("Atencao","O Saldo do Prod/Loc " + AllTrim((cAliasSD1)->D1_COD)+"/"+(cAliasSD1)->D1_LOCAL + " ficara negativo apos a Exclusao (" + AllTrim(Str(nSaldoB2))+") ",{"Aborta"}) //"Atencao" //"O Saldo do Prod/Loc "###" ficara negativo apos a Exclusao ("###"Aborta"
						EndIf	
						lRetorno := .F.
			    	Else
						If !(Type('l103Auto') <> 'U' .And. l103Auto)
					    	If !(Rastro((cAliasSD1)->D1_COD) .And. Localiza((cAliasSD1)->D1_COD)) .And. !(FunName() $ 'EICDI154')  // MV_ESTNEG = S e Produto sem Rastro / Localização, avisa que o estoque ficara negativo  e nao originado do Recebimento de Importacao
						    	lRetorno := (Aviso("Atencao","O Saldo do Prod/Loc " + AllTrim((cAliasSD1)->D1_COD)+'/'+(cAliasSD1)->D1_LOCAL + " ficara negativo apos a Exclusao (" + AllTrim(Str(nSaldoB2)) + "",{"). Continua?","Aborta"}) == 2) //"Atencao"###"O Saldo do Prod/Loc "###"Continua" //" ficara negativo apos a Exclusao ("###"). Continua?"###"Aborta"
						    EndIf
						EndIf
					EndIf
				Else  // Não Permite Estoque Negativo
					If !(Type('l103Auto') <> 'U' .And. l103Auto)  
					    lR103ENEG:=A103ValEstNeg((cAliasSD1)->D1_COD,cAliasSD1)
					EndIf	
					lRetorno := lR103ENEG	
			    EndIf
			ElseIf QtdComp(nSaldoB2)<QtdComp(SB2->B2_RESERVA)
				If lEstNeg   //Permite Estoque Negativo
				    If (Rastro((cAliasSD1)->D1_COD) .Or. Localiza((cAliasSD1)->D1_COD))  // MV_ESTNEG = S e Produto com Rastro / Localização, não permite estoque negativo
						If !(Type('l103Auto') <> 'U' .And. l103Auto)
							Aviso("Atencao","O Saldo do Prod/Loc " + AllTrim((cAliasSD1)->D1_COD)+"/"+(cAliasSD1)->D1_LOCAL + " ficara Menor que o Saldo em Reserva apos a Exclusao (" + AllTrim(Str(nSaldoB2))+")",{"Aborta"}) //"Atencao"###"O Saldo do Prod/Loc " //" ficara Menor que o Saldo em Reserva apos a Exclusao ("###"Aborta"
						EndIf	
						lRetorno := .F.
					Else
						If !(Type('l103Auto') <> 'U' .And. l103Auto)
						    If !(Rastro((cAliasSD1)->D1_COD) .And. Localiza((cAliasSD1)->D1_COD))  .And. !(FunName() $ 'EICDI154')   // MV_ESTNEG = S e Produto sem Rastro / Localização, avisa que o estoque ficara negativo
						    	lRetorno := (Aviso("Atencao","O Saldo do Prod/Loc " + AllTrim((cAliasSD1)->D1_COD)+'/'+(cAliasSD1)->D1_LOCAL + " ficara negativo apos a Exclusao (" + AllTrim(Str(nSaldoB2)) + "Continua",{"). Continua?","Aborta"}) == 2) //"Atencao"###"O Saldo do Prod/Loc "###"Continua" //" ficara negativo apos a Exclusao ("###"). Continua?"###"Aborta"
					    	EndIf
				    	EndIf
			    	EndIf
			  	Else  // Não Permite Estoque Negativo   
				  	If !(Type('l103Auto') <> 'U' .And. l103Auto)
					    lR103ENEG:=A103ValEstNeg((cAliasSD1)->D1_COD,cAliasSD1)
					EndIf	
					lRetorno := lR103ENEG
				EndIf
			EndIf
		EndIf	
	EndIf				
	EndIf				
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o item de nota originou-se do SIGAEIC                            ³
	//³ Permite a exclusao apenas quando a chamada da exclusao for feita pelo EIC    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno .And. !lExcViaEIC .And. !Empty( ( cAliasSD1 )->D1_TIPO_NF ) 
		Help( "", 1, "A103EXCIMP" )  // "Este documento nao pode ser excluido pois foi criado pelo SIGAEIC. A exclusao devera ser efetuada pelo SIGAEIC."
		lRetorno := .F. 
	EndIf 	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o item de nota originou-se do SIGATMS                            ³
	//³ Permite a exclusao apenas quando a chamada da exclusao for feita pelo TMS    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	SF4->(DbSetOrder(1))
	If SF4->(DbSeek(xFilial('SF4')+cTesDR)) .And. SF4->F4_ESTOQUE == 'S'
		dbSelectArea('DTC')
		dbSetOrder(2) //-- DTC_FILIAL+DTC_NUMNFC+DTC_SERNFC+DTC_CLIREM+DTC_LOJREM
		IF MsSeek(xFilial('DTC') + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA, .F.)
			Help('', 1, 'A103EXCTMS') //-- 'Este documento nao pode ser excluido pois foi criado pelo SIGATMS. A exclusao devera ser efetuada pelo SIGATMS.'
			lRetorno := .F.
		EndIf
	EndIf

	dbSelectArea(cAliasSD1)
	dbSkip()

EndDo
If lQuery
	dbSelectArea(cAliasSD1)
	dbCloseArea()
	dbSelectArea("SD1")
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se os Lotes podem ser excluidos                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRetorno
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ aLotes[nx][1] : Codigo do Produto        ³
	//³ aLotes[nx][2] : Almoxarifado             ³
	//³ aLotes[nx][3] : Lote                     ³
	//³ aLotes[nx][4] : SubLote                  ³
	//³ aLotes[nx][5] : OP                       ³
	//³ aLotes[nx][6] : Numero Sequencial        ³
	//³ aLotes[nx][7] : Quantidade               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 to Len(aLotes)

		nSldLote := SaldoLote(aLotes[nX][1],aLotes[nX][2],aLotes[nX][3],aLotes[nX][4],,,.T.)
		// Verifica o saldo em transito disponivel
		nSldTran := SaldoLote(aLotes[nX][1],cLocTran,aLotes[nX][3],aLotes[nX][4],,,.T.)
		If (nSldLote+nSldTran) < aLotes[nX][7]
			If !Empty(aLotes[nx,5])
				dbSelectArea("SD3")
				dbSetOrder(4)
				MsSeek(xFilial("SD3")+aLotes[nx,6])
				While !Eof() .And. SD3->D3_CF # "RE5" .And. SD3->D3_NUMSEQ == aLotes[nx,6]
					dbSkip()
				End
				lEofSD3 := IIF(SD3->D3_NUMSEQ # aLotes[nx,6],.T.,.F.)
				If lEofSD3
					Help(" ",1,"A100NOLOTE",,aLotes[nX,1]+"  "+aLotes[nX,2]+"    "+aLotes[nX,3],5,4)
					lRetorno := .F.
					Exit
				EndIf
			Else
				Help(" ",1,"A100NOLOTE",,aLotes[nX,1]+"  "+aLotes[nX,2]+"    "+aLotes[nX,3],5,4)
				lRetorno := .F.
				Exit
			EndIf
		EndIf
	Next
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se as duplicatas podem ser excluidas  SE2           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRetorno .And. (ExistBlock ("M103XFIN"))
	aRetXFin	:= ExecBlock ("M103XFIN", .F., .F. , {lAviso,lAvisoISS})
	If ValType(aRetXFin) == "A" .And. Len(aRetXFin) <= 3 
		lRetorno	:= IIF(ValType(aRetXFin[1]) == "L",aRetXFin[1],lRetorno)
		lAviso		:= IIF(ValType(aRetXFin[2]) == "L",aRetXFin[2],lAviso)
		lAvisoISS	:= IIF(ValType(aRetXFin[3]) == "L",aRetXFin[3],lAvisoISS)
	EndIf	
EndIf

If lRetorno
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o Prefixo correto da Nota fiscal de Entrada         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cPrefixo	:= IIf(Empty(SF1->F1_PREFIXO),&(SuperGetMV("MV_2DUPREF")),SF1->F1_PREFIXO)	
	dbSelectArea("SE2")
	dbSetOrder(6)

	lQuery    := .T.
	aStruSE2  := SE2->(dbStruct())
	cAliasSE2 := "MACANDELF1"
	cQuery    := "SELECT SE2.*,SE2.R_E_C_N_O_ SE2RECNO "
	cQuery    += "  FROM "+RetSqlName("SE2")+" SE2 "
	cQuery    += " WHERE SE2.E2_FILIAL   = '"+xFilial("SE2")+"'"
	cQuery    += "   AND SE2.E2_FORNECE  = '"+SF1->F1_FORNECE+"'"
	cQuery    += "   AND SE2.E2_LOJA	 = '"+SF1->F1_LOJA+"'"
	cQuery    += "   AND SE2.E2_PREFIXO  = '"+cPrefixo+"'"
	cQuery    += "   AND SE2.E2_NUM		 = '"+SF1->F1_DUPL+"'"
	cQuery    += "   AND SE2.D_E_L_E_T_  = ' ' "
	cQuery    += "ORDER BY "+SqlOrder(SE2->(IndexKey()))

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSE2,.T.,.T.)
	
	For nX := 1 To Len(aStruSE2)
		If aStruSE2[nX][2]<>"C"
			TcSetField(cAliasSE2,aStruSE2[nX][1],aStruSE2[nX][2],aStruSE2[nX][3],aStruSE2[nX][4])
		EndIf
	Next nX
		
	If cPaisLoc $ "BRA|MEX" .and. SF1->F1_TIPO != "D" .and. (cAliasSE2)->(!Eof())
		If lRetorno .and. A120UsaAdi(SF1->F1_COND) 
			If !Empty((cAliasSE2)->E2_BAIXA) .and. (cAliasSE2)->E2_VALOR != (cAliasSE2)->E2_SALDO
				cQ := "SELECT SUM(FR3_VALOR) AS FR3_VALOR "
				cQ += "  FROM "+RetSqlName("FR3")
				cQ += " WHERE FR3_FILIAL = '"+xFilial("FR3")+"' "
				cQ += "   AND FR3_CART   = 'P' "
				cQ += "   AND FR3_TIPO   IN "+FormatIn(MVPAGANT,"/")+" "
				If lForpcnf .And. ( SC7->C7_FORNECE <> SF1->F1_FORNECE .Or. SC7->C7_LOJA <> SF1->F1_LOJA )
					cQ += "   AND FR3_FORNEC = '"+SC7->C7_FORNECE+"' "
					cQ += "   AND FR3_LOJA   = '"+SC7->C7_LOJA+"' "
				Else
					cQ += "   AND FR3_FORNEC = '"+SF1->F1_FORNECE+"' "
					cQ += "   AND FR3_LOJA   = '"+SF1->F1_LOJA+"' "
				EndIf
				cQ += "   AND FR3_DOC    = '"+SF1->F1_DOC+"' "
				cQ += "   AND FR3_SERIE  = '"+SF1->F1_SERIE+"' "
				cQ += "   AND D_E_L_E_T_ = ' ' "
            	
				cQ := ChangeQuery(cQ)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQ),"TRBFR3",.T.,.T.)
					
				TcSetField("TRBFR3","FR3_VALOR","N",TamSX3("FR3_VALOR")[1],TamSX3("FR3_VALOR")[2])						
				   
			   nValorAdtFR3 := TRBFR3->FR3_VALOR           
				   
			   TRBFR3->(dbCloseArea())
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ compara o valor baixado para o titulo ( E2_VALOR - E2_SALDO ), com o valor dos adiantamentos. Se o valor for igual, continua a exclusao   ³
				//³ do documento, se o valor for diferente eh porque houveram outras baixas para o titulo, neste caso, nao eh possivel excluir o documento,   ³
				//³ primeiro deve-se excluir estas outras baixas no Financeiro.  												                                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÀÄÄÄÄÄÄÄÄÄÄÙ
				If (cAliasSE2)->(E2_VALOR-E2_SALDO) = nValorAdtFR3
					If !ApMsgYesNo("Por tratar-se de condição de pagamento com Adiantamento, a exclusão do Documento de Entrada também irá excluir a compensação do(s) título(s) de adiantamento associado(s) a este Documento de Entrada no momento da sua geração." + CRLF+ "Deseja continuar?") //"Por tratar-se de condição de pagamento com Adiantamento, a exclusão do Documento de Entrada também irá excluir a compensação do(s) título(s) de adiantamento associado(s) a este Documento de Entrada no momento da sua geração."#CRLF#"Deseja continuar?"
						lRetorno := .F.
					Endif  
			   	Endif				   
			Endif 
		Endif	
	Endif	
	
	dbSelectArea(cAliasSE2)
		
	While ( !Eof() .And. lRetorno .And.;
			xFilial("SE2")  == (cAliasSE2)->E2_FILIAL  .And.;
			SF1->F1_FORNECE == (cAliasSE2)->E2_FORNECE .And.;
			SF1->F1_LOJA    == (cAliasSE2)->E2_LOJA    .And.;
			cPrefixo	    == (cAliasSE2)->E2_PREFIXO .And.;
			SF1->F1_DUPL	== (cAliasSE2)->E2_NUM )
		If (cAliasSE2)->E2_TIPO == MVNOTAFIS
			aadd(aRecSE2,If(lQuery,(cAliasSE2)->SE2RECNO,(cAliasSE2)->(RecNo())))

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ se for nota fiscal com adiantamento compensado, valida se a nota fiscal tem somente uma parcela no contas a pagar                                        ³
			//³ se for somente 1 parcela, segue o cancelamento e nao valida se o titulo estah baixado, pois a compensacao desta parcela vai ser desfeita na rotina       ³
			//³ A103Grava                                                                                                                                                ³
			//³ se for mais de uma parcela, valida as parcelas a partir da segunda, para checar se hah alguma parcela baixada                                            ³
			//³ se a nota fiscal tiver um pedido de compra oriundo de um contrato com caução não deve validar a exclusão do título a pagar							     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cPaisLoc $ "BRA|MEX"
				If SF1->F1_TIPO != "D"	
					If nCountSE2 = 0
						If A120UsaAdi(SF1->F1_COND)
		   					If !Empty((cAliasSE2)->E2_BAIXA) .and. (cAliasSE2)->E2_VALOR != (cAliasSE2)->E2_SALDO .And. !A103BXADT((cAliasSE2)->E2_PREFIXO,(cAliasSE2)->E2_NUM,(cAliasSE2)->E2_PARCELA,(cAliasSE2)->E2_TIPO,(cAliasSE2)->E2_FORNECE,(cAliasSE2)->E2_LOJA,(cAliasSE2)->E2_FILORIG) //tem baixa para o adiantamento
		   						lPriParAdtBx := .T.
		   					Endif
				   		Endif
				   	Endif
			   	Endif
		   	Endif	
			
			If IIf((cPaisLoc == "BRA" .And. lPriParAdtBx),.F., !lBxCaucGct .And. !FaCanDelCP(cAliasSE2,"MATA100|PLSMPAG"))
				lRetorno := .F.
				Exit
			EndIf  
			
			If cPaisLoc <> "RUS"
			// Verifica se titulo foi conciliado por DDA
				If VldConcDda((cAliasSE2)->E2_FILIAL, (cAliasSE2)->E2_FORNECE, (cAliasSE2)->E2_LOJA, (cAliasSE2)->E2_CODBAR, (cAliasSE2)->E2_FILIAL+ "|" + (cAliasSE2)->E2_PREFIXO+"|" + (cAliasSE2)->E2_NUM+"|" +;
								(cAliasSE2)->E2_PARCELA+"|" + (cAliasSE2)->E2_TIPO+"|" + (cAliasSE2)->E2_FORNECE+"|" + (cAliasSE2)->E2_LOJA + "|")
					lRetorno := .F.
					Help('',1,'FIN050DDA',,"",1,0)
					Exit
				EndIf
			EndIf      

			If lRetISSMes
				dDataVenc := (cAliasSE2)->E2_VENCREA
			EndIf
			
			If ((cAliasSE2)->E2_PRETPIS == "2" .Or. (cAliasSE2)->E2_PRETCOF == "2" .Or. (cAliasSE2)->E2_PRETCSL == "2") .And.;
				((cAliasSE2)->E2_VRETPIS == 0 .Or. (cAliasSE2)->E2_VRETCOF == 0 .Or. (cAliasSE2)->E2_VRETCSL == 0)
				lAviso   := .T.
			Endif	

			If (cAliasSE2)->E2_ISS > 0 .Or. (cAliasSE2)->E2_VRETISS > 0
				lVldRetISS := .T.
		EndIf
		lPriParAdtBx := .F.
		nCountSE2++
		
		EndIf
		dbSelectArea(cAliasSE2)
		dbSkip()
	EndDo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Apaga tambem os registro de impostos	   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAreaSE2IR := GetArea()
	dbSelectArea("SE2")
	dbSetOrder(6)
	dbSeek(xFilial("SE2")+SF1->F1_FORNECE+SF1->F1_LOJA+cPrefixo+SF1->F1_DUPL) //xFilial("SE2")+cPrefixo+SF1->F1_DUPL )

    If (SE2->E2_FILIAL+SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_PREFIXO+SE2->E2_NUM == ;
		(xFilial("SE2")+SF1->F1_FORNECE+SF1->F1_LOJA+cPrefixo+SF1->F1_DUPL))
		nRecE2in:=SE2->(RecNo())
		dbSetOrder(0)
		SE2->(MsGoto(nRecE2in))
		
		// Quantidade de titulos gerados PIS, COF ou ISS
		// Como a ordenação está de acordo com o recno, verifico a quantidade total que foi gerado de titulo ( PIS, COF ou ISS)
		nQtdTit := 0
		nQtdTot := 0
		
		if SF1->F1_ISS > 0 
			nQtdTot += 1
		endif

		if SF1->F1_VALIMP5 > 0
			nQtdTot += 1
		endif

		if SF1->F1_VALIMP6 > 0
			nQtdTot += 1
		endif

		if SF1->F1_VALFASE > 0
			nQtdTot += 1
		endif

		//Natureza para Contribuição Seguridade Social.
 		IF ExistBlock("NTFUNR")
			cNatGilRat   := ExecBlock("NTFUNR",.f.,.f.,{SE2->E2_ORIGEM,SE2->E2_PREFIXO})
		Else
			cNatGilRat := SuperGetMv("MV_CSS",.F.,Criavar('ED_CODIGO'))
		Endif

		cNatGilRat := PadR(cNatGilRat,TamSX3('ED_CODIGO')[1]) 
		aNats := {&(GetMv("MV_IRF")),;
					SuperGetMv("MV_PISIMP",.F.,""),;
					SuperGetMv("MV_COFIMP",.F.,""),;
					SuperGetMv("MV_ISSIMP",.F.,""),;
					SuperGetMv("MV_FASEIMP",.F.,""),; 
					cNatGilRat }
        /*
		While (!EOF() .And. ( ( SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM == (xFilial("SE2")+cPrefixo+SF1->F1_DUPL) ) ) .Or. ;
		(SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM == (xFilial("SE2")+(cPrefPIS+SF1->F1_DUPL))) .Or.;
		(SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM == (xFilial("SE2")+(cPrefCOF+SF1->F1_DUPL))) .Or.;
		(SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM == (xFilial("SE2")+(cPrefISS+SF1->F1_DUPL))) .Or.;
		(SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM == (xFilial("SE2")+(cPreFase+SF1->F1_DUPL))) .Or.; 
		GetDelTitImp( cPrefPIS, cPrefCOF, cPrefISS, cPreFase, @nQtdTit, nQtdTot ) ) //dá erro por falta desta função //FR - 16/12/2021
        */
        
		
		While (!EOF() .And. ( ( SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM == (xFilial("SE2")+cPrefixo+SF1->F1_DUPL) ) ) .Or. ;
		(SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM == (xFilial("SE2")+(cPrefPIS+SF1->F1_DUPL))) .Or.;
		(SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM == (xFilial("SE2")+(cPrefCOF+SF1->F1_DUPL))) .Or.;
		(SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM == (xFilial("SE2")+(cPrefISS+SF1->F1_DUPL))) .Or.;
		(SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM == (xFilial("SE2")+(cPreFase+SF1->F1_DUPL)))  ) 

		 	if SE2->E2_PREFIXO == cPrefPIS .or. SE2->E2_PREFIXO == cPrefCOF .or. SE2->E2_PREFIXO == cPrefISS
		 		nQtdTit += 1
		 	endif

			If !Empty(SE2->E2_IDDARF)
				lRetorno := .F.
				Help(" ",1,"NAOEXCNFS","NAOEXCNFS","Ja foi gerado DARF, ID "+SE2->E2_IDDARF+", verifique na rotina FINA373",1,0)
				Exit
			EndIf

			If Ascan(aNats,Alltrim(SE2->E2_NATUREZ)) > 0 .And. SE2->E2_SALDO != 0 .And. aScan(aRecSE2,SE2->(RecNo())) == 0
				aadd(aRecSE2,SE2->(RecNo()))			
			EndIf
			dbSkip()
		EndDo
  	EndIf
	RestArea(aAreaSE2IR)
	If lQuery
		dbSelectArea(cAliasSE2)
		dbCloseArea()
		dbSelectArea("SE2")
	EndIf
EndIf

If lRetorno .And. lRetISSMes .And. !Empty(dDataVenc) .And. lVldRetISS
	dDataIni:= FirstDay(dDataVenc)
	dDataFim:= LastDay(dDataVenc)
	
	lQuery    := .T.
 	cAliasSE2 := GetNextAlias()

	cQuery := "SELECT E2_PREFIXO, E2_NUM, E2_ISS, E2_VRETISS, SE2.R_E_C_N_O_ SE2RECNO "
	cQuery += "  FROM "+RetSqlName( "SE2" ) + " SE2 "
	cQuery += " WHERE E2_FILIAL   = '"+xFilial("SE2")+"'"
	cQuery += "   AND E2_FORNECE  = '"+SF1->F1_FORNECE	+ "'"
	cQuery += "   AND E2_LOJA     = '"+SF1->F1_LOJA+"'"
	cQuery += "   AND E2_VENCREA  >= '"+DToS(dDataIni)+"'"
	cQuery += "   AND E2_VENCREA  <= '"+DToS(dDataFim)+"'"
	cQuery += "   AND (E2_ISS > 0 OR E2_VRETISS > 0)"
	cQuery += "   AND E2_TIPO NOT IN " + FormatIn(MVABATIM,"|")
	cQuery += "   AND E2_TIPO NOT IN " + FormatIn(MV_CPNEG,cSepNeg)
	cQuery += "   AND E2_TIPO NOT IN " + FormatIn(MVPROVIS,cSepProv)
	cQuery += "   AND E2_TIPO NOT IN " + FormatIn(MVPAGANT,cSepRec)
	cQuery += "   AND D_E_L_E_T_=' '"

	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSE2, .F., .T. )
	
    TcSetField(cAliasSE2,"E2_ISS","N",TamSX3("E2_ISS")[1],TamSX3("E2_ISS")[2])
    TcSetField(cAliasSE2,"E2_VRETISS","N",TamSX3("E2_VRETISS")[1],TamSX3("E2_VRETISS")[2])
	
	While !(cAliasSE2)->(Eof())
		If cPrefixo == (cAliasSE2)->E2_PREFIXO .And.;
	       SF1->F1_DUPL == (cAliasSE2)->E2_NUM
			(cAliasSE2)->(dbSkip())
			If (cAliasSE2)->(Eof())
				lAvisoISS:= .F.			
				lRetorno := .T.
			ElseIf (cAliasSE2)->E2_ISS > 0
				lAvisoISS:= .T.
				lRetorno := .F.
				Exit
			EndIf
		Else
			If (cAliasSE2)->E2_ISS > 0
				lAvisoISS:= .T.
				lRetorno := .F.
			End
			(cAliasSE2)->(dbSkip())
		EndIf
	EndDo
	If lQuery
		dbSelectArea(cAliasSE2)
		dbCloseArea()
		dbSelectArea("SE2")
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se as duplicatas podem ser excluidas  SE1           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRetorno .And. SF1->F1_TIPO == 'D'
	cE1Cliente := SF1->F1_FORNECE // Quando integrado com DMS, o cliente pode ser outro se utilizado condicao de pagamento TIPO A na venda.
	cE1Loja    := SF1->F1_LOJA    // Quando integrado com DMS, o cliente pode ser outro se utilizado condicao de pagamento TIPO A na venda.
	cE1NReduz  := "" 			  // Quando integrado com DMS, o cliente pode ser outro se utilizado condicao de pagamento TIPO A na venda.

	If lIntGC .and. ExistFunc("FMX_NCCCliente")
		FMX_NCCCliente(SF1->F1_DOC, SF1->F1_SERIE, SF1->F1_FORNECE, SF1->F1_LOJA, @cE1Cliente, @cE1Loja, @cE1NReduz)
	EndIf

	dbSelectArea('SE1')
	dbSetOrder(2)
	If MsSeek(xFilial("SE1")+cE1Cliente+cE1Loja+cPrefixo+SF1->F1_DOC)
		While !Eof().And. lRetorno .And. xFilial()+cE1Cliente+cE1Loja+cPrefixo+SF1->F1_DOC==;
				E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM
			If !(SE1->E1_TIPO$ MV_CRNEG)
				dbSelectArea('SE1')
				dbSkip()
				Loop
			EndIf
			aadd(aRecSE1,SE1->(RecNo()))
			If SE1->E1_SALDO <> SE1->E1_VALOR
				Help(' ',1,'A100FINBX')
				lRetorno := .F.
			ElseIf !SoftLock('SE1')
				lRetorno := .F.
			EndIf
			dbSelectArea('SE1')
			dbSkip()
		EndDo
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿                  
//³ Verifica se a NFE gerou Imposto ICMS ANTECIPACAO no SE2 CAPag³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If cPaisLoc == "BRA"
	If!Empty(SF1->F1_NUMTRIB)
		If AllTrim(SF1->F1_NUMTRIB) == "N"
			lNumTrib := .F.
		EndIf
		cNumTit := SF1->F1_NUMTRIB
	EndIf
Else
	cNumTit := SF1->F1_DOC
EndIf

If lRetorno .And. cPaisloc=="BRA" .And. lNumTrib
	dbSelectArea("SE2")
	SE2->(dbsetOrder(1))
	If dbSeek(xFilial("SE2") + "ICM" + cNumTit)
		Do While SE2->(!Eof()) .And. SE2->E2_PREFIXO+SE2->E2_NUM == "ICM" + cNumTit
			//Se o titulo sofreu pagamento nao permitir excluir a NFE
			If !Empty(SE2->E2_BAIXA).And. SE2->E2_SALDO<>SE2->E2_VALOR .And. ;
				ALLTRIM(SE2->E2_TIPO)=="TX" .And. ALLTRIM(SE2->E2_ORIGEM) == "MATA103"

				cMensagem:=" Não é possível excluir esse documento por "+CHR(10)
				cMensagem+="estar vinculado a um título a pagar de imposto "+CHR(10)
				cMensagem+="( "+SE2->E2_NUM+"/"+SE2->E2_PREFIXO+") baixado total ou parcialmente."+CHR(10)
				cMensagem+="Para excluir esse documento, será necessário "+CHR(10)
				cMensagem+="primeiramente estornar esse título através "+CHR(10)
				cMensagem+="do módulo financeiro."

				Help(" ",1,"NAOEXCNFS","NAOEXCNFS",cMensagem,1,0)
				lRetorno := .F.
			Endif
			SE2->(DbSkip())
		EndDo
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Integracao com o EEC     											|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRetorno .And. lEECFAT
	lRetorno := EECFAT3("VLD",.T.)
EndIf

If lAviso .And. lShowAviso
	If !(Type('l103Auto') <> 'U' .And. l103Auto)
		Aviso(OemToAnsi(""),OemToAnsi(""),{OemToAnsi("")},2)
	EndIf	
ElseIf lAvisoISS
	If !(Type('l103Auto') <> 'U' .And. l103Auto)
		Aviso(OemToAnsi(""),OemToAnsi(""),{OemToAnsi("")},2)
	EndIf	
Endif

//-----------------------------------------------------------------------------------------
//Verifica abaixo se existem títulos de recolhimento gerados pelo motor Fiscal/Financeiro
//-----------------------------------------------------------------------------------------
If lRetorno .And. cPaisloc == "BRA" .And. AliasInDic("F2F") .And. AliasInDic("FK7") .AND. FindFunction("xFisDelTit") .And. SF1->(FieldPos('F1_IDNF')) > 0 
	// Opcao = 1 p/ somente validar a exclusão.
	lRetorno := xFisDelTit(SF1->F1_IDNF, "SF1", "MATA100", 1)
EndIf

If !lRetorno .And. lExcViaEIC
	lMsErroAuto := .T.
EndIf

RestArea(aAreaSD1)
RestArea(aAreaSF8)
RestArea(aArea)

Return lRetorno

