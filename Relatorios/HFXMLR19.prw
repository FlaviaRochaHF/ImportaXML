#Include "Protheus.Ch"
#Include "RwMake.Ch"
#Include "TbiConn.Ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HFXMLR19  ºAutor  ³ Heverton Marcondes     ºDt³  03/04/2023 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³“Relatório de Xmls pendentes de Classificação      		  ¹±±
±±º                                                                       ¹±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³IMPORTA XML                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function HFXMLR19()
Local oReport	    := Nil

Private cPerg 	    := "HFXMLR19"
Private lDemonstra  := .F.
Private xZBZ  		:= GetNewPar("XM_TABXML" ,"ZBZ")
Private xZBZ_		:= iif(Substr(xZBZ,1,1)=="S", Substr(xZBZ,2,2), Substr(xZBZ,1,3)) + "_"

Private oProcess	:= Nil
Private lEnd        := .F.

aHelpPor := {}
Aadd( aHelpPor, "Informe a Data de emissão inicial a ser processada." )
U_HFPutSx1(cPerg,"01","Emissao de  "        ,"Prev.Fechamento de  ","Prev.Fechamento de  "	,"mv_ch1","D",08,0,0,"G","",   "","","","mv_par01","","","","","","","","","","","","","","","","",aHelpPor,aHelpPor,aHelpPor)

aHelpPor := {}
Aadd( aHelpPor, "Informe a Data de emissão final a ser processada." )
U_HFPutSx1(cPerg,"02","Emissao ate "        ,"Prev.Fechamento Ate ","Prev.Fechamento Ate "	,"mv_ch2","D",08,0,0,"G","",   "","","","mv_par02","","","","","","","","","","","","","","","","",aHelpPor,aHelpPor,aHelpPor)

/*
If msgYesNo("Deseja atualizar os status dos xmls importados")
	U_UPStatXML(.F.,@lEnd,oProcess)
EndIf
*/

dVencLic   := Stod(Space(8))
//lUsoOk     := U_HFXML00X("HF000001","101",SM0->M0_CGC,@dVencLic)  
lUsoOk	:= U_HFXMLLIC(.F.)
//lUsoOk	:= .T.

lDemonstra := .F.		//FR - 12/06/2020 - tratativa para licenças Demo

If !lUsoOk
	Return(Nil)
EndIf

oReport:= ReportDef(lDemonstra)
oReport:PrintDialog()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ReportDef ºAutor  ³ Heverton Marcondes º Data ³  04/04/2023 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Função Auxiliar chamada pela HFXMLR19						  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³IMPORTA XML                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function ReportDef(lDemonstra)
Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2        := "de acordo com os parametros informados pelo usuario."
Local cTitulo		:= ""
Private oReport 	:= Nil
Private oSection1   := Nil

Pergunte(cPerg,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta a Mensagem do titulo do relatorio, conforme opção.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTitulo := "Relação de XMLs Pendentes de Classificação"

oReport := TReport():New("HFXMLR19",@cTitulo,cPerg,{|oReport| PrintReport(oReport,lDemonstra)},cDesc1+cDesc2)

oSection1 := TRSection():New(oReport,OemToAnsi("Cabeçalho dos Itens"),{})

TRCell():New(oSection1,"CHAVE"	  	,"SF1",		,,44						,.F.,,"CENTER")
TRCell():New(oSection1,"NOTA"  		,"SF1",		,,TamSX3('F1_DOC')[01]		,.F.,,"CENTER")
TRCell():New(oSection1,"NOME"		,"SF1",		,,TamSX3('A2_NOME')[01]		,.F.,,"CENTER")
TRCell():New(oSection1,"CFOP"		,"SF1",		,,09						,.F.,,"CENTER")
TRCell():New(oSection1,"SERIE"		,"SF1",		,,TamSX3('F1_SERIE')[01]	,.F.,,"CENTER")
TRCell():New(oSection1,"VALOR"		,"SF1",		,,15						,.F.,,"CENTER")
TRCell():New(oSection1,"EMISSAO"	,"SF1",		,,10						,.F.,,"CENTER")

oReport:SetLandscape() 			//Impressão somente em paisagem.
oReport:ParamReadOnly() 		//Desabilita o acesso ao parametros, no botão acoes relacionadas.
oReport:DisableOrientation() 	//Desabilita a selecao da opcao do papel - Retrato \ Paisagem.

Return(oReport)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PrintReportº Autor: Heverton Marcondes       º Data³04/04/23 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Função Auxiliar Responsavel pela impressão do conteuido.     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³IMPORTA XML                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PrintReport(oReport,lDemonstra)

Private cCfDevol 	:= GetNewPar("XM_CFDEVOL","")
Private cCfBenef 	:= GetNewPar("XM_CFBENEF","")
Private cCfTrans	:= GetNewPar("XM_CFTRANS","")
Private cCfCompl	:= GetNewPar("XM_CFCOMPL","") 
Private cCfVenda	:= GetNewPar("XM_CFVENDA","")
Private cCfRemes	:= GetNewPar("XM_CFREMES","")
Private cCfBonif	:= GetNewPar("XM_CFBONIF","")	

Private cZBZ 		:= GetNextAlias()
Private oSection1 	:= oReport:Section(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta massa de dados temporaria com informações de NF      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
fGeraDados(cZBZ,lDemonstra)

DbSelectArea(cZBZ)
(cZBZ)->(DbGoTop())

oReport:SetMeter((cZBZ)->(RecCount()))

oSection1:Init()

While !(cZBZ)->(EOF())

	oSection1:Cell('CHAVE'):SetValue((cZBZ)->CHAVE)
	oSection1:Cell('NOTA'):SetValue((cZBZ)->NOTA)
	oSection1:Cell('NOME'):SetValue((cZBZ)->NOME) 
	oSection1:Cell('CFOP'):SetValue((cZBZ)->CFOP)
	oSection1:Cell('SERIE'):SetValue((cZBZ)->SERIE)
	oSection1:Cell('VALOR'):SetValue(Transform((cZBZ)->VALOR,"@E 999,999,999.99"))
	oSection1:Cell('EMISSAO'):SetValue(stod((cZBZ)->EMISSAO))

	oReport:IncMeter()					
	oSection1:PrintLine()		
	
	(cZBZ)->(DbSkip())
EndDo

oSection1:Finish()

(cZBZ)->(DbCloseArea())

Return


****************************************
Static Function fGeraDados(cZBZ,lDemonstra)
****************************************

Local cQuery  := ""

//FR - 12/06/2020 - Tratativa para licença Demo:
If lDemonstra
	MsgInfo("Esta é Uma Licença de Demonstração, o Período para Consulta Será Limitado a Até 30 (Trinta) Dias!")		
Endif

LF := CHR(13)+ CHR(10)
cQuery := " select " + LF	
cQuery += "		"+xZBZ+"_CHAVE AS CHAVE, " + LF
cQuery += "		"+xZBZ+"_NOTA AS NOTA, " + LF
cQuery += "		"+xZBZ+"_FORNEC AS NOME, " + LF
cQuery += "		"+xZBZ+"_CFOP AS CFOP, " + LF
cQuery += "		"+xZBZ+"_SERIE AS SERIE, " + LF
cQuery += "		"+xZBZ+"_VLBRUT AS VALOR, " + LF
cQuery += "		"+xZBZ+"_MODELO AS MODELO, " + LF
cQuery += "		"+xZBZ+"_PRENF AS PRENF, " + LF
cQuery += "   	"+xZBZ+"_DTNFE AS EMISSAO "+ LF 


cQuery += "	FROM "+RetSqlName(xZBZ)+" ZBZ " + LF

cQuery += "	WHERE "+xZBZ+"_FILIAL ='"+ xFilial(xZBZ) +"' "+ LF 

If lDemonstra		//FR - 12/06/2020 - tratativa para licenças Demo
	cQuery += " AND "+xZBZ+"_DTNFE>='"+ DtoS(Date()-30) +"' AND "+xZBZ+"_DTNFE <='"+ DtoS(Date()) +"' "+ LF 
Else
	cQuery += "	AND "+xZBZ+"_DTNFE>='"+ DtoS(Mv_Par01) +"' AND "+xZBZ+"_DTNFE <='"+ DtoS(Mv_Par02) +"' "+ LF 
Endif

cQuery += "	AND ZBZ.D_E_L_E_T_ = ' ' " + LF 	

MemoWrite("C:\TEMP\HFXMLR19.SQL", cQuery)

DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cZBZ,.F.,.T.)
DbSelectArea(cZBZ)
DbGoTop()

Return

Static Function RetTipo(cCFOP)

Local cTipo 		:= ""
Local cCFOP1 		:= ""
Local cCFOP2		:= ""
Local lEncontrou 	:= .T.

cCFOP1	:= subStr(cCFOP,1,4)

If Len(alltrim(cCFOP)) > 4
	cCFOP2	:= subStr(cCFOP,6,4)
EndIf	

Do Case 
	Case cCFOP1 $ cCfDevol 
		cTipo := "Devolução"
	Case cCFOP1 $ cCfBenef 
		cTipo := "Beneficiamento"
	Case cCFOP1 $ cCfTrans 
		cTipo := "Transferencia"
	Case cCFOP1 $ cCfCompl 
		cTipo := "Complemento"
	Case cCFOP1 $ cCfVenda 
		cTipo := "Venda"
	Case cCFOP1 $ cCfRemes 
		cTipo := "Remessa"
	Case cCFOP1 $ cCfBonif 
		cTipo := "Bonificação"
	OTHERWISE
		cTipo := "Informar CFOP F12 Aba Fiscal"
		lEncontrou := .F.
EndCase	

If !lEncontrou .And. Len(cCFOP2) > 0 

	Do Case 
		Case cCFOP2 $ cCfDevol 
			cTipo := "Devolução"
		Case cCFOP2 $ cCfBenef 
			cTipo := "Beneficiamento"
		Case cCFOP2 $ cCfTrans 
			cTipo := "Transferencia"
		Case cCFOP2 $ cCfCompl 
			cTipo := "Complemento"
		Case cCFOP2 $ cCfVenda 
			cTipo := "Venda"
		Case cCFOP2 $ cCfRemes 
			cTipo := "Remessa"
		Case cCFOP2 $ cCfBonif 
			cTipo := "Bonificação"
		OTHERWISE
			cTipo := "Informar CFOP F12 Aba Fiscal"
	EndCase	

EndIf

Return cTipo
