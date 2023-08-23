#INCLUDE "rwmake.ch"
#INCLUDE "TBICONN.CH"
#Include "Protheus.Ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |HFXMLR14  º Autor ³                    º Data ³  18/01/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatório das Notas de Combustiveis                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ IMPORTA XML                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//--------------------------------------------------------------------------//
//Alterações realizadas:
//FR - 10/08/2021 - #11094 - MATILAT - Aplicação de changequery
//--------------------------------------------------------------------------//
//FR
User Function HFXMLR14
Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de acordo com os parametros informados pelo usuario."
Local cDesc3         := "Documentos de Notas de Comubstíveis"
Local cPict          := ""
Local titulo       := "Notas de Combustiveis"
Local nLin         := 6

Local Cabec1       := ""
Local Cabec2       := ""
Local imprime      := .T.
Local aOrd := {}
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private CbTxt        := ""
Private limite           := 80
Private tamanho          := "P"
Private nomeprog         := "HFXMLR14" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo            := 18
Private aReturn          := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey        := 0
Private cbtxt      := Space(10)
Private cbcont     := 00
Private CONTFL     := 01
Private m_pag      := 01
Private wnrel      := "NOME" // Coloque aqui o nome do arquivo usado para impressao em disco
Private cPerg      := "HFXMLR14"

AjustaSX1(cPerg)

if Pergunte(cPerg,.T.)
	oReport:= ReportDef()
	oReport:SetParam(cPerg)
	oReport:PrintDialog()
endif

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ReportDef ºAutor  ³ Rafael Nastri      º Data ³  24/07/2015 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Função Auxiliar chamada pela HFXMLR00						  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³IMPORTA XML                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()
Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2        := "de acordo com os parametros informados pelo usuario."
Local cTitulo		:= ""
Private oReport 	:= Nil
Private oSection1	:= Nil
Private oSection2   := Nil
Private oSection3	:= Nil
Private oSection4	:= Nil
Private oSection5	:= Nil
Private oSection6	:= Nil

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta a Mensagem do titulo do relatorio, conforme opção.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTitulo := "Classificação de Notas de Combustiveis"

oReport := TReport():New("HFXMLR14",@cTitulo,"",{|oReport| PrintReport(oReport)},cDesc1+cDesc2)

oSection1 := TRSection():New(oReport,OemToAnsi("Notas de Combustiveis"),{})
TRCell():New(oSection1,"FILIAL" 	,xZBZ ,"Filial"     ,,05,.F.,,"CENTER",.T.)
TRCell():New(oSection1,"EMISSAO"	,xZBZ ,"Emissão"    ,,10,.F.,,"CENTER",.T.)
TRCell():New(oSection1,"CODFOR" 	,xZBZ ,"Cod.For."   ,,08,.F.,,"CENTER",.T.)
TRCell():New(oSection1,"LOJFOR"  	,xZBZ ,"Loj.For."   ,,04,.F.,,"CENTER",.T.)
TRCell():New(oSection1,"FORNECEDOR"	,xZBZ ,"Fornecedor" ,,50,.F.,,"LEFT",.T.)
TRCell():New(oSection1,"NOTA"	    ,xZBZ ,"Nota Fiscal",,10,.F.,,"LEFT",.T.)
TRCell():New(oSection1,"SERIE"	    ,xZBZ ,"Serie"      ,,04,.F.,,"LEFT",.T.)
TRCell():New(oSection1,"VALORNF"    ,"SF1","Valor NF"   ,"@E 999,999,999.99",20,.F.,,"RIGHT",.T.)
oSection1:SetHeaderSection(.T.)

oSection2 := TRSection():New(oReport,OemToAnsi("Totais"),{})
TRCell():New(oSection2,"FILIAL" 	,xZBZ ,"Filial"     ,,05,.F.,,"CENTER",.F.)
TRCell():New(oSection2,"EMISSAO"	,xZBZ ,"Emissão"    ,,10,.F.,,"CENTER",.F.)
TRCell():New(oSection2,"CODFOR" 	,xZBZ ,"Cod.For."   ,,08,.F.,,"CENTER",.F.)
TRCell():New(oSection2,"LOJFOR"  	,xZBZ ,"Loj.For."   ,,04,.F.,,"CENTER",.F.)
TRCell():New(oSection2,"FORNECEDOR"	,xZBZ ,"Fornecedor" ,,50,.F.,,"CENTER",.F.)
TRCell():New(oSection2,"NOTA"	    ,xZBZ ,"Nota Fiscal",,10,.F.,,"LEFT",.F.)
TRCell():New(oSection2,"SERIE"	    ,xZBZ ,"Serie"      ,,04,.F.,,"LEFT",.F.)
TRCell():New(oSection2,"TOTALNF"    ,"SF1","Total NF"   ,"@E 999,999,999.99",20,.F.,,"RIGHT",.F.)
oSection2:SetHeaderSection(.F.)


oReport:SetPortrait() 	//Impressão somente em retrato.
oReport:ParamReadOnly() //Desabilita o acesso ao parametros, no botão acoes relacionadas.
oReport:DisableOrientation() //Disabilita a selecao da opcao do papel - Retrato \ Paisagem.

Return(oReport)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PrintReportºAutor³Rafael Nastri(MONSTRO DA HF)ºData³24/07/15 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Função Auxiliar Responsavel pela impressão do conteuido.     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³IMPORTA XML                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PrintReport(oReport)
Local cQuery    := ""
Local cFilProc	:= ""
Local cCodFor	:= ""
Local cStatXml	:= ""
Local cCGC		:= ""
Local nTotal    := 0
Local cDB       := TcGetDB()
Private cAliasXMl := GetNextAlias()
Private oSection1 := oReport:Section(1)
Private oSection2 := oReport:Section(2)
//Private oSection3 := oReport:Section(3)
//Private oSection4 := oReport:Section(4)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta massa de dados temporaria com informações ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := "SELECT "+xZBZ_+"FILIAL, "+xZBZ_+"NOTA, "+xZBZ_+"SERIE, F1_DOC, F1_SERIE, F1_VALBRUT, "+xZBZ_+"DTNFE, "+xZBZ_+"DTRECB, F1_DTDIGIT, "+xZBZ_+"CODFOR, "+xZBZ_+"LOJFOR, "+xZBZ_+"FORNEC, F1_FORNECE, F1_LOJA, ZBO."+xZBO_+"TPOCOR, "+xZBO_+"DTOCOR, ZBZ.R_E_C_N_O_ as RECZBZ, F1.R_E_C_N_O_ as RECF1, ZBO.R_E_C_N_O_ as RECZBO "
cQuery += "FROM "+RetSqlName("ZBZ")+" ZBZ "
if cDB = "ORACLE"
	cQuery += "left join "+RetSqlName("SF1")+" F1 on substr(ZBZ."+xZBZ_+"CHAVE,1,44) = substr(F1_CHVNFE,1,44) and F1.D_E_L_E_T_ = ' ' "
	cQuery += "left join "+RetSqlName("ZBO")+" ZBO on substr(ZBZ."+xZBZ_+"CHAVE,1,44) = substr(ZBO."+xZBO_+"CHAVE,1,44) and ZBO.D_E_L_E_T_ = ' ' and ZBO."+xZBO_+"TPOCOR = '1' "
Else
	cQuery += "left join "+RetSqlName("SF1")+" F1 on substring(ZBZ."+xZBZ_+"CHAVE,1,44) = substring(F1_CHVNFE,1,44) and F1.D_E_L_E_T_ = ' ' "
	cQuery += "left join "+RetSqlName("ZBO")+" ZBO on substring(ZBZ."+xZBZ_+"CHAVE,1,44) = substring(ZBO."+xZBO_+"CHAVE,1,44) and ZBO.D_E_L_E_T_ = ' ' and ZBO."+xZBO_+"TPOCOR = '1' "
Endif
cQuery += "WHERE ZBZ.D_E_L_E_T_ = ' ' "
cQuery += "and ZBZ."+xZBZ_+"COMBUS = 'S' "
cQuery += "and ZBZ."+xZBZ_+"FILIAL >= '"+MV_PAR01+"' "
cQuery += "and ZBZ."+xZBZ_+"FILIAL <= '"+MV_PAR02+"' "
cQuery += "and ZBZ."+xZBZ_+"DTNFE >= '"+Dtos(MV_PAR03)+"' "
cQuery += "and ZBZ."+xZBZ_+"DTNFE <= '"+Dtos(MV_PAR04)+"' "
cQuery += "and F1.F1_DTDIGIT >= '"+Dtos(MV_PAR05)+"' "
cQuery += "and F1.F1_DTDIGIT <= '"+Dtos(MV_PAR06)+"' "
if !Empty(MV_PAR07)
	cQuery += "and ZBZ."+xZBZ_+"CODFOR = '"+MV_PAR07+"' "
	cQuery += "and ZBZ."+xZBZ_+"LOJFOR = '"+MV_PAR08+"' "
endif
cQuery += "ORDER BY "+xZBZ_+"FILIAL, F1_DTDIGIT, "+xZBZ_+"CHAVE "

cQuery := ChangeQuery(cQuery)		//FR - 10/08/2021 - #11094 - MATILAT
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasXMl)

DbSelectArea(cAliasXMl)
(cAliasXMl)->(DbGoTop())

oReport:SetMeter((cAliasXMl)->(RecCount()))

	oSection1:Init(.T.)
nTotal := 0

While !(cAliasXMl)->(EOF())
	
	If oReport:Cancel()
		MsgStop("Relatório cancelado pelo usuário")
		Exit
	EndIf

	if (cAliasXMl)->RECF1 > 0
			DbSelectArea( "SF1" )
			DbGoTo( (cAliasXMl)->RECF1 )
	endif

	if (cAliasXMl)->RECZBO > 0
			DbSelectArea( xZBO )
			DbGoTo( (cAliasXMl)->RECZBO )
	endif

	DbSelectArea( xZBZ )
	DbGoTo( (cAliasXMl)->RECZBZ )

//	oSection1:Init()
		oSection1:Cell('FILIAL'):SetValue( (xZBZ)->(FieldGet( FieldPos( xZBZ_+"FILIAL" ) ) ) )
		oSection1:Cell('EMISSAO'):SetValue( (xZBZ)->(FieldGet( FieldPos( xZBZ_+"DTNFE" ) ) ) )
		oSection1:Cell('CODFOR'):SetValue( (xZBZ)->(FieldGet( FieldPos( xZBZ_+"CODFOR" ) ) ) )
		oSection1:Cell('LOJFOR'):SetValue( (xZBZ)->(FieldGet( FieldPos( xZBZ_+"LOJFOR" ) ) ) )
		oSection1:Cell('FORNECEDOR'):SetValue( (xZBZ)->(FieldGet( FieldPos( xZBZ_+"FORNEC" ) ) ) )
		oSection1:Cell('NOTA'):SetValue( (xZBZ)->(FieldGet( FieldPos( xZBZ_+"NOTA" ) ) ) )
		oSection1:Cell('SERIE'):SetValue( (xZBZ)->(FieldGet( FieldPos( xZBZ_+"SERIE" ) ) ) )
		if (cAliasXMl)->F1_VALBRUT > 0
			oSection1:Cell('VALORNF'):SetValue( SF1->F1_VALBRUT )
			nTotal := nTotal + SF1->F1_VALBRUT
		else
			oSection1:Cell('VALORNF'):SetValue( 0.00 )
		endif
	oSection1:PrintLine()


	DbSelectArea(cAliasXMl)
	(cAliasXMl)->(DbSkip())
EndDo

	oSection1:Finish()
	oReport:SkipLine() //Pula Linha

if nTotal > 0
	oSection2:Init()
	oSection2:Cell('FILIAL'):SetValue('TOTAL')
	oSection2:Cell('EMISSAO'):SetValue('')
	oSection2:Cell('CODFOR'):SetValue('')
	oSection2:Cell('LOJFOR'):SetValue('')
	oSection2:Cell('FORNECEDOR'):SetValue('')
	oSection2:Cell('NOTA'):SetValue('')
	oSection2:Cell('SERIE'):SetValue('')
	oSection2:Cell('TOTALNF'):SetValue( nTotal )
	oSection2:PrintLine()
	oSection2:Finish()
Endif

(cAliasXMl)->(DbCloseArea())
Return


//caso queira
Static Function ConvDate(nTipo , uDado)
Local xRet      
If nTipo == 1 // AAAAMMDD -> DD/MM/AA
	xRet := Substr(uDado,7,2)+"/"+Substr(uDado,5,2)+"/"+Substr(uDado,3,2)
Else
	xRet := uDado
EndIf                                      
	
Return(xRet) 




//pregunta
Static Function AjustaSX1(cPerg)
Local aHelpPor := {}
Local nVersao := Val(GetVersao(.F.))     // Indica a versao do Protheus
Local nTmFil  := iif( nVersao >= 12, FWGETTAMFILIAL, Len( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))) )   )
Local nTF     := TAMSXG("001")[1]
Local nTL     := TAMSXG("002")[1]

Aadd( aHelpPor, "Informe a Filial inicial a ser processada." )
U_HFPutSx1(cPerg,"01","Filial de   "        ,"Filial de ","Filial de  "	,"mv_ch1","C",nTmFil,0,0,"G","","SM0","","","mv_par01","","","","","","","","","","","","","","","","",aHelpPor,aHelpPor,aHelpPor)
                 
aHelpPor := {}
Aadd( aHelpPor, "Informe a Filial final a ser processada." )
U_HFPutSx1(cPerg,"02","Filial Ate  "        ,"Filial Ate ","Filial Ate "	,"mv_ch2","C",nTmFil,0,0,"G","","SM0","","","mv_par02","","","","","","","","","","","","","","","","",aHelpPor,aHelpPor,aHelpPor)

aHelpPor := {}
Aadd( aHelpPor, "Data de Emissão da Nota Inicial." )
U_HFPutSx1(cPerg,"03","Emissão de  "        ,"Emissão de  ","Emissão de  "	,"mv_ch3","D",08,0,0,"G","",   "","","","mv_par03","","","","","","","","","","","","","","","","",aHelpPor,aHelpPor,aHelpPor)

aHelpPor := {}
Aadd( aHelpPor, "Data de Emissão da Nota Final." )
U_HFPutSx1(cPerg,"04","Emissão Ate "        ,"Emissão Ate ","Emissão Ate "	,"mv_ch4","D",08,0,0,"G","",   "","","","mv_par04","","","","","","","","","","","","","","","","",aHelpPor,aHelpPor,aHelpPor)

aHelpPor := {}
Aadd( aHelpPor, "Data de Classificação da Nota Inicial." )
U_HFPutSx1(cPerg,"05","Classificação de  "  ,"Classificação de ","Classificação de  ","mv_ch5","D",08,0,0,"G","",   "","","","mv_par05","","","","","","","","","","","","","","","","",aHelpPor,aHelpPor,aHelpPor)

aHelpPor := {}
Aadd( aHelpPor, "Data de Classificação da Nota Final." )
U_HFPutSx1(cPerg,"06","Classificação Ate " ,"Classificação Ate ","Classificação Ate ","mv_ch6","D",08,0,0,"G","",   "","","","mv_par06","","","","","","","","","","","","","","","","",aHelpPor,aHelpPor,aHelpPor)

aHelpPor := {}
Aadd( aHelpPor, "Informe o codigo do fornecedor do XML." )
U_HFPutSx1(cPerg,"07","Fornecedor   "	,"Fornecedor"				,"Fornecedor"	 ,"mv_ch7","C",nTF,0,0,"G","","SA2ZB5","","","mv_par07","","","","","","","","","","","","","","","","",aHelpPor,aHelpPor,aHelpPor)

aHelpPor := {}
Aadd( aHelpPor, "Informe a loja do fornecedor do XML." )
U_HFPutSx1(cPerg,"08","Loja    "	    ,"Loja"						,"Loja"			 ,"mv_ch8","C",nTL,0,0,"G","",   "","","","mv_par08","","","","","","","","","","","","","","","","",aHelpPor,aHelpPor,aHelpPor)


Return


Static Function __Dummy(lRecursa) //warning W0010 Static Function <?> never called
    lRecursa := .F.
    IF (lRecursa)
        __Dummy(.F.)
        U_HFXMLR14()
	EndIF
Return(lRecursa)
