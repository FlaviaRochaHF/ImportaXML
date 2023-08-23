#Include "Protheus.Ch"
#Include "RwMake.Ch"
#Include "TbiConn.Ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HFXMLR01  ºAutor  ³ Rafael Nastri (MONSTRO)ºDt³  24/07/2015 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Relatório de comparação de documentos fiscais de entrada    º±±
±±º          ³que não foi recepcionado o XML do Fornecedores.		      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³IMPORTA XML                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//--------------------------------------------------------------------------//
//FR - 12/06/2020 - Alterações realizadas para adequar a validação da licença 
//                  quando for licença Demonstração (Demo)
//                  Implementado "flag" para sinalizar todo o sistema quando
//                  for licença Demo e assim, NÃO permitir consultas
//                  no relatório de pré-auditoria de forma abrangente
//                  Demo = consulta é data de hoje - 30 apenas
//                  
//--------------------------------------------------------------------------//
User Function HFXMLR00()
Local oReport	    := Nil
Private cPerg 	    := "HFXMLR00"
Private lDemonstra  := .F.
Default lDemo       := .F. 
dVencLic := Stod(Space(8))
//lUsoOk := U_HFXML00X("HF000001","101",SM0->M0_CGC,@dVencLic)  
lUsoOk	:= U_HFXMLLIC()
lDemonstra := lDemo		//FR - 12/06/2020 - tratativa para licenças Demo

If !lUsoOk
	Return(Nil)
EndIf

AjustaSX1()
If Pergunte( cPerg , .T. )
	oReport:= ReportDef(lDemonstra)
	oReport:SetParam(cPerg)
	oReport:PrintDialog()
EndIf

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
Static Function ReportDef(lDemonstra)
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
If MV_PAR14 == 1
	cTitulo := "Doctos Entrada S/ Xml"
Else
	cTitulo := "Xml S/ Doctos Entrada"
EndIf

oReport := TReport():New("HFXMLR00",@cTitulo,"",{|oReport| PrintReport(oReport,lDemonstra)},cDesc1+cDesc2)

oSection1 := TRSection():New(oReport,OemToAnsi("Impressão da Filial"),{})
TRCell():New(oSection1,"FILIAL" ,"SF1",,,20)
oSection1:SetHeaderSection(.F.)

oSection2 := TRSection():New(oReport,OemToAnsi("Impressão dos Dados Fornecedor 1"),{})
TRCell():New(oSection2,"FORNE1"	,"SF1",,,80)
oSection2:SetHeaderSection(.F.)

oSection3 := TRSection():New(oReport,OemToAnsi("Impressão dos Dados Fornecedor 2"),{})
TRCell():New(oSection3,"FORNE2"	,"SF1",,,80)
oSection3:SetHeaderSection(.F.)

oSection4 := TRSection():New(oReport,OemToAnsi("Cabeçalho dos Itens"),{})
TRCell():New(oSection4,"FILIAL" ,"SF1",,,20)
TRCell():New(oSection4,"STXML" 	  ,"SF1",,,09,.F.,,"CENTER")
TRCell():New(oSection4,"ESPECIE"  ,"SF1",,,11,.F.,,"CENTER")
TRCell():New(oSection4,"SERIE"	  ,"SF1",,,07,.F.,,"CENTER")
TRCell():New(oSection4,"NOTA"	  ,"SF1",,,15,.F.,,"CENTER")
TRCell():New(oSection4,"EMISSAO"  ,"SF1",,,15,.F.,,"CENTER")
TRCell():New(oSection4,"DTDIGIT"  ,"SF1",,,15,.F.,,"CENTER")
TRCell():New(oSection4,"MANIFESTA","SF1",,,15,.F.,,"CENTER")
TRCell():New(oSection4,"VALORBRT" ,"SF1",,,15,.F.,,"CENTER")
TRCell():New(oSection4,"CHAVE"    ,"SF1",,,44,.F.,,"CENTER")
TRCell():New(oSection4,"CNPJ_EMIT","SF1",,,15,.F.,,"CENTER")
TRCell():New(oSection4,"NOME_EMIT","SF1",,,35,.F.,,"CENTER")
TRCell():New(oSection4,"CFOP"	  ,"SF1",,,09,.F.,,"CENTER")

oSection4:SetHeaderSection(.F.)

oSection5 := TRSection():New(oReport,OemToAnsi("Itens das Notas Fiscais"),{})
TRCell():New(oSection5,"FILIAL" ,"SF1",,,20)
TRCell():New(oSection5,"STXML" 	  ,"SF1",,,09,.F.,,"CENTER")
TRCell():New(oSection5,"ESPECIE"  ,"SF1",,,11,.F.,,"CENTER")
TRCell():New(oSection5,"SERIE"	  ,"SF1",,,07,.F.,,"CENTER")
TRCell():New(oSection5,"NOTA"	  ,"SF1",,,15,.F.,,"CENTER")
TRCell():New(oSection5,"EMISSAO"  ,"SF1",,,15,.F.,,"CENTER")
TRCell():New(oSection5,"DTDIGIT"  ,"SF1",,,15,.F.,,"CENTER")
TRCell():New(oSection5,"MANIFESTA","SF1",,,15,.F.,,"CENTER")
TRCell():New(oSection5,"VALORBRT" ,"SF1",,,15,.F.,,"CENTER")
TRCell():New(oSection5,"CHAVE"    ,"SF1",,,44,.F.,,"CENTER")
TRCell():New(oSection5,"CNPJ_EMIT","SF1",,,15,.F.,,"CENTER")
TRCell():New(oSection5,"NOME_EMIT","SF1",,,35,.F.,,"CENTER")
TRCell():New(oSection5,"CFOP"	  ,"SF1",,,09,.F.,,"CENTER")
oSection5:SetHeaderSection(.F.)

oSection6 := TRSection():New(oReport,OemToAnsi("Itens Status Diferente"),{})
TRCell():New(oSection6,"VRNF"	 ,"SF1",,,15,.F.,,"CENTER")
TRCell():New(oSection6,"VRXML"	 ,"SF1",,,15,.F.,,"CENTER")
TRCell():New(oSection6,"QTNF"	 ,"SF1",,,15,.F.,,"CENTER")
TRCell():New(oSection6,"QTXML"	 ,"SF1",,,15,.F.,,"CENTER")
oSection6:SetHeaderSection(.F.)

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
Static Function PrintReport(oReport,lDemonstra)
Local cFilProc	:= ""
Local cCodFor	:= ""
Local cStatXml	:= ""
Local cCGC		:= ""
Local aStatus 	:= {}
Local aManif    := {}
Local lImpTudo  := iif( MV_PAR19 == 1, .F., .T. )

Private cAliasXMl := GetNextAlias()
Private oSection1 := oReport:Section(1)
Private oSection2 := oReport:Section(2)
Private oSection3 := oReport:Section(3)
Private oSection4 := oReport:Section(4)
Private oSection5 := oReport:Section(5)
Private oSection6 := oReport:Section(6)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta massa de dados temporaria com informações de NF x XML³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
U_XmlInfoX(cAliasXMl,.T.,"1",lImpTudo,lDemonstra)

Aadd( aStatus, {" ", " " } )
Aadd( aStatus, {"A", "R.Carg" } )
Aadd( aStatus, {"B", "Import" } )
Aadd( aStatus, {"F", "Falha " } )
Aadd( aStatus, {"N", "Doc-En" } )
Aadd( aStatus, {"S", "Pre-Nt" } )
Aadd( aStatus, {"X", "Cancel" } )
Aadd( aStatus, {"Z", "Rejeit" } )
Aadd( aStatus, {"1", "Xml/NF" } )
Aadd( aStatus, {"2", "Dv.Vlr" } )
Aadd( aStatus, {"3", "Dv.Qtd" } )
Aadd( aStatus, {"4", "Vlr/Qt" } )
Aadd( aStatus, {"+", "Encontr"} )
Aadd( aStatus, {"-", "Não Enc"} )

Aadd( aManif, {"0", "Não" } )
Aadd( aManif, {"1", "Conf.Oper" } )
Aadd( aManif, {"2", "Oper.Desconh" } )
Aadd( aManif, {"3", "Oper.Não Realiz" } )
Aadd( aManif, {"4", "Ciência" } )
Aadd( aManif, {"5", "MCTe" } )
Aadd( aManif, {"W", "Pend.Conf" } )
Aadd( aManif, {"X", "Pend.Desc" } )
Aadd( aManif, {"Y", "Pend.N.Realiz" } )
Aadd( aManif, {"Z", "Pend.Ciência" } )
 
DbSelectArea(cAliasXMl)
(cAliasXMl)->(DbGoTop())

oReport:SetMeter((cAliasXMl)->(RecCount()))

While !(cAliasXMl)->(EOF())
	
	cFilProc := (cAliasXMl)->F1_FILIAL
	oSection1:Init()
	oSection1:Cell('FILIAL'):SetValue('Filial - '+(cAliasXMl)->F1_FILIAL)
	oSection1:PrintLine()
	oSection1:Finish()
	
	oReport:SkipLine() //Pula Linha
	
	While (cAliasXMl)->(!EOF()) .And. (cAliasXMl)->F1_FILIAL == cFilProc
		
		cCodFor := (cAliasXMl)->F1_FORNECE+(cAliasXMl)->F1_LOJA+(cAliasXMl)->F1_TIPO //ENEO includo F1_TIPO em 27/08/2015  
		cCGC := IIF(Len((cAliasXMl)->F1_CGC)==14,Transform((cAliasXMl)->F1_CGC,"@R 99.999.999/9999-99"),Transform((cAliasXMl)->F1_CGC,"@R 999.999.999-99"))

		if ! lImpTudo
			oSection2:Init()
			oSection2:Cell('FORNE1'):SetValue("Codigo:"+(cAliasXMl)->F1_FORNECE+"-"+(cAliasXMl)->F1_LOJA+" - "+(cAliasXMl)->F1_NOME+" - CNPJ\CPF: "+cCGC)
			oSection2:PrintLine()
			oSection2:Finish()
		
			oReport:SkipLine() //Pula Linha
		
			oSection3:Init()
			oSection3:Cell('FORNE2'):SetValue("Fone: "+(cAliasXMl)->F1_FONE+" E-mail: "+(cAliasXMl)->F1_EMAIL)
			oSection3:PrintLine()
			oSection3:Finish()
		
			oReport:ThinLine() //Imprime uma linha
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime o Cabeçalho dos Itens³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oSection4:Init()
		oSection4:Cell('FILIAL'):SetValue('Filial')
		oSection4:Cell('STXML'):SetValue('St. XML')
		oSection4:Cell('ESPECIE'):SetValue('Especie')
		oSection4:Cell('SERIE'):SetValue('Serie')
		oSection4:Cell('NOTA'):SetValue('N. Fiscal')
		oSection4:Cell('EMISSAO'):SetValue('Emissão')
		oSection4:Cell('DTDIGIT'):SetValue('Entrada')
		oSection4:Cell('MANIFESTA'):SetValue('Manifestacao')
		oSection4:Cell('VALORBRT'):SetValue('Valor Bruto')
		oSection4:Cell('CHAVE'):SetValue('Chave')
		oSection4:Cell('CNPJ_EMIT'):SetValue('Cnpj Emitente')
		oSection4:Cell('NOME_EMIT'):SetValue('Nome Emitente')
		oSection4:Cell('CFOP'):SetValue('Cfop')
		oSection4:PrintLine()
		oSection4:Finish()
		
		While (cAliasXMl)->(!EOF()) .And. (cAliasXMl)->F1_FILIAL == cFilProc .And. ( (cAliasXMl)->F1_FORNECE+(cAliasXMl)->F1_LOJA+(cAliasXMl)->F1_TIPO == cCodFor .or. lImpTudo ) //ENEO includo F1_TIPO em 27/08/2015  

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica o cancelamento pelo usuario³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If oReport:Cancel()
				MsgStop("Relatório cancelado pelo usuário")
				Exit
				Return
			EndIf

			cStatXml := ""
			If aScan( aStatus, {|x| x[1] = (cAliasXMl)->F1_STXML } ) > 0
				cStatXml:= aStatus[aScan( aStatus, {|x| x[1] = (cAliasXMl)->F1_STXML } )][2]
			EndIf
			
			cManif := ""
			If aScan( aManif, {|x| x[1] = (cAliasXMl)->F1_MANIF } ) > 0
				cManif := aManif[aScan( aManif, {|x| x[1] = (cAliasXMl)->F1_MANIF } )][2]
			EndIf

			oSection5:Init()
			oSection5:Cell('FILIAL'):SetValue((cAliasXMl)->F1_FILIAL)
			oSection5:Cell('STXML'):SetValue(cStatXml)
			oSection5:Cell('ESPECIE'):SetValue((cAliasXMl)->F1_ESPECIE)
			oSection5:Cell('SERIE'):SetValue((cAliasXMl)->F1_SERIE)
			oSection5:Cell('NOTA'):SetValue((cAliasXMl)->F1_DOC)
			oSection5:Cell('EMISSAO'):SetValue((cAliasXMl)->F1_EMISSAO)
			oSection5:Cell('DTDIGIT'):SetValue((cAliasXMl)->F1_DTDIGIT)
			oSection5:Cell('MANIFESTA'):SetValue(cManif)
			oSection5:Cell('VALORBRT'):SetValue(Transform((cAliasXMl)->F1_VALBRUT,"@E 99,999,999.99"))
			oSection5:Cell('CHAVE'):SetValue((cAliasXMl)->F1_CHVNFE)
			oSection5:Cell('CNPJ_EMIT'):SetValue((cAliasXML)->F1_CGC)
			oSection5:Cell('NOME_EMIT'):SetValue((cAliasXML)->F1_NOME)
			oSection5:Cell('CFOP'):SetValue((cAliasXML)->F1_CFO)
			oSection5:PrintLine()

			If (cAliasXMl)->F1_STXML $ "1234"
				oReport:SkipLine() //Pula Linha
				oSection6:Init()
				oSection6:Cell('VRNF'):SetValue("VR NF "  + Transform((cAliasXMl)->F1_VALBRUT,"@E 99,999,999.99"))
				oSection6:Cell('VRXML'):SetValue("VR Xml " + Transform((cAliasXMl)->XM_VALBRUT,"@E 99,999,999.99"))
				oSection6:Cell('QTNF'):SetValue("Qt NF "  + Transform((cAliasXMl)->D1_QTITEM ,"@E 999,999.99"))
				oSection6:Cell('QTXML'):SetValue("Qt Xml " + Transform((cAliasXMl)->XM_QTITEM ,"@E 999,999.99"))
				oSection6:PrintLine()
				oSection6:Finish()
				oReport:SkipLine() //Pula Linha
			EndIf
			oSection5:Finish()
			oReport:SkipLine() //Pula Linha
			oReport:IncMeter()
			
			(cAliasXMl)->(DbSkip())
			if (cAliasXMl)->(!EOF()) .And. (cAliasXMl)->F1_FILIAL == cFilProc .And. ( (cAliasXMl)->F1_FORNECE+(cAliasXMl)->F1_LOJA+(cAliasXMl)->F1_TIPO == cCodFor .or. lImpTudo )
				if cCGC <> IIF(Len((cAliasXMl)->F1_CGC)==14,Transform((cAliasXMl)->F1_CGC,"@R 99.999.999/9999-99"),Transform((cAliasXMl)->F1_CGC,"@R 999.999.999-99"))
					Exit
				endif
			endif
		EndDo
		oReport:ThinLine() //Imprime uma linha
		oReport:SkipLine() //Pula Linha
	EndDo
EndDo

(cAliasXMl)->(DbCloseArea())
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AjustaSX1ºAutor  ³ Rafael Nastri      º Data ³  24/07/2015 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Função Auxiliar Responsavel pela criação da Pergunta.      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³IMPORTA XML                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AjustaSX1()
Local nTmFil  := FWGETTAMFILIAL

u_zPutSX1(cPerg,"01","Filial de   " ,"MV_PAR01","MV_CH1","C",nTmFil, 0, "G", "","SM0", "", "","","", "", "", "Informe a Filial inicial a ser processada.")
u_zPutSX1(cPerg,"02","Filial Ate  "  ,"MV_PAR02","MV_CH2","C",nTmFil, 0, "G", "","SM0", "", "","","", "", "", "Informe a Filial final a ser processada.")
u_zPutSX1(cPerg,"03","Entrada de  "  ,"MV_PAR03","MV_CH3","D",08, 0, "G", "","", "", "","","", "", "", "Informe a Data de entrada inicial a ser processada." )
u_zPutSX1(cPerg,"04","Entrada Ate  "  ,"MV_PAR04","MV_CH4","D",08, 0, "G", "","", "", "","","", "", "", "Informe a Data de entrada final a ser processada." )
u_zPutSX1(cPerg,"05","Serie de  "  ,"MV_PAR05","MV_CH5","C",03, 0, "G", "","", "", "","","", "", "", "Informe a Serie inicial a ser processada." )
u_zPutSX1(cPerg,"06","Serie Ate  "  ,"MV_PAR06","MV_CH6","C",03, 0, "G", "","", "", "","","", "", "", "Informe a Serie final a ser processada." )
u_zPutSX1(cPerg,"07","Nota Fiscal de   "  ,"MV_PAR07","MV_CH7","C",09, 0, "G", "","", "", "","","", "", "", "Informe a Nota Fiscal inicial a ser processada." )
u_zPutSX1(cPerg,"08","Nota Fiscal Ate   "  ,"MV_PAR08","MV_CH8","C",09, 0, "G", "","", "", "","","", "", "", "Informe a Nota Fiscal final a ser processada."  )
u_zPutSX1(cPerg,"09","Considera especie   "  ,"MV_PAR09","MV_CH9","C",20, 0, "G", "","", "", "","","", "", "", "Informe as espécies que devem ser consideradas" + CRLF + "separadas por virgulas Ex: SPED,CTE" )
u_zPutSX1(cPerg,"10","Emissor do XML de  "  ,"MV_PAR10","MV_CHA","C",TAMSX3("ZBZ_CODFOR")[1], 0, "G", "","", "", "","","", "", "", "Informe o codigo inicial do emissor do XML." )
u_zPutSX1(cPerg,"11","Emissor do XML ate  "  ,"MV_PAR11","MV_CHB","C",TAMSX3("ZBZ_CODFOR")[1], 0, "G", "","", "", "","","", "", "", "Informe o codigo final do emissor do XML.")
u_zPutSX1(cPerg,"12","Loja do Emissor do XML de  "  ,"MV_PAR12","MV_CHC","C",TAMSX3("ZBZ_LOJFOR")[1], 0, "G", "","", "", "","","", "", "", "Informe a loja inicial do emissor do XML.")
u_zPutSX1(cPerg,"13","Loja do Emissor do XML ate  "  ,"MV_PAR13","MV_CHD","C",TAMSX3("ZBZ_LOJFOR")[1], 0, "G", "","", "", "","","", "", "", "Informe a loja final do emissor do XML.")
u_zPutSX1(cPerg,"14","Analise Base NF ou Base XML? "  ,"MV_PAR14","MV_CHE","N",01, 0, "G", "","", "", "","","", "", "", "NF Analisar NFs que não tem XML." + CRLF + "XML Analisar XMLs que não tem NF." )
u_zPutSX1(cPerg,"15","Especie que são Modelo 55 "  ,"MV_PAR15","MV_CHF","C",20, 0, "G", "","", "", "","","", "", "", "Informe as espécies que são consideradas como" + CRLF + "modelo de XML 55-NF-e Ex: SPED,NFE" + CRLF + "Isto para quando for Base NF."  )
u_zPutSX1(cPerg,"16","Emissão de  "  ,"MV_PAR16","MV_CHF","D",08, 0, "G", "","", "", "","","", "", "", "Informe a Data de EMISSÃO inicial a ser processada."  )
u_zPutSX1(cPerg,"17","Emissão Ate  "  ,"MV_PAR17","MV_CHH","D",08, 0, "G", "","", "", "","","", "", "", "Informe a Data de EMISSÃO final a ser processada."  )

_cHelp := "Mostrar Diferenças Entre Valores" + CRLF
_cHelp += "Digitados / XML." + CRLF
_cHelp += "TOTAL XML -> Mostra Dif.Total Dig." + CRLF
_cHelp += " / Total XML." + CRLF
_cHelp += "QTD TOTAL ITENS -> Dif.Qtd Item Dig." + CRLF
_cHelp += " / Qtd Item XML. " + CRLF
_cHelp += "AMBOS -> Mostra Valores e Quantidades." 
u_zPutSX1(cPerg,"18","Mostrar Divergencia NF/Xml?"  ,"MV_PAR18","MV_CHI","N",01, 0, "C", "","", "", "TOTAL XML","QTD TOTAL ITENS","AMBOS", "", "", _cHelp  )

_cHelp := "Imprimir Notas(Base XML) ou XML(Base NF)" + CRLF
_cHelp += "que foram encontradas ? " + CRLF
_cHelp += "NÃO -> Vai imprimir apenas as divergen- " + CRLF
_cHelp += "cias entre a base XML e a NF (SF1) " + CRLF
_cHelp += "SIM -> irá imprimir mesmo as notas que " + CRLF
_cHelp += "tenham NF na (SF1) e XML cadastrado,Fil-" + CRLF
_cHelp += "trando apenas os parâmetros escolhidos"
u_zPutSX1(cPerg,"19","Imprimir Encontradas?"  ,"MV_PAR19","MV_CHJ","N",01, 0, "C", "","", "", "Não","Sim","", "", "", _cHelp  )

_cHelp := "Imprimir Notas Canceladas ?" + CRLF
_cHelp += "1 -> Imprime notas desse grupo" + CRLF
_cHelp += "2 -> Não imprime notas desse grupo" + CRLF
_cHelp += "Somente para paremetro XML(Base NF)" + CRLF

u_zPutSX1(cPerg,"20","Imprimir Notas Canceladas ?"  ,"MV_PAR20","MV_CHK","N",01, 0, "C", "","", "", "Sim","Não","", "", "", _cHelp  )

_cHelp := "Imprimir Notas Vendas ?" + CRLF
_cHelp += "1 -> Imprime notas desse grupo" + CRLF
_cHelp += "2 -> Não imprime notas desse grupo" + CRLF
_cHelp += "Somente para paremetro XML(Base NF)" + CRLF

u_zPutSX1(cPerg,"21","Imprimir Notas Vendas ?"  ,"MV_PAR21","MV_CHL","N",01, 0, "C", "","", "", "Sim","Não","", "", "", _cHelp  )

_cHelp := "Imprimir Notas de Remessa ?" + CRLF
_cHelp += "1 -> Imprime notas desse grupo" + CRLF
_cHelp += "2 -> Não imprime notas desse grupo" + CRLF
_cHelp += "Somente para paremetro XML(Base NF)" + CRLF

u_zPutSX1(cPerg,"22","Imprimir Notas de Remessa ?"  ,"MV_PAR22","MV_CHM","N",01, 0, "C", "","", "", "Sim","Não","", "", "", _cHelp  )

_cHelp := "Imprimir Notas de Devolução ?" + CRLF
_cHelp += "1 -> Imprime notas desse grupo" + CRLF
_cHelp += "2 -> Não imprime notas desse grupo" + CRLF
_cHelp += "Somente para paremetro XML(Base NF)" + CRLF

u_zPutSX1(cPerg,"23","Imprimir Notas de Devolucao ?"  ,"MV_PAR23","MV_CHN","N",01, 0, "C", "","", "", "Sim","Não","", "", "", _cHelp  )

_cHelp := "Imprimir Notas de Bonificação ?" + CRLF
_cHelp += "1 -> Imprime notas desse grupo" + CRLF
_cHelp += "2 -> Não imprime notas desse grupo" + CRLF
_cHelp += "Somente para paremetro XML(Base NF)" + CRLF

u_zPutSX1(cPerg,"24","Imprimir Notas de Bonificação ?","MV_PAR24","MV_CHO","N",01, 0, "C", "","", "", "Sim","Não","", "", "", _cHelp  )

Return
