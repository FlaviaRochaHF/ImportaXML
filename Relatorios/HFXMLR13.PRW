#INCLUDE "rwmake.ch"
#INCLUDE "TBICONN.CH"
#Include "Protheus.Ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |HFXMLR13  บ Autor ณ                    บ Data ณ  30/09/18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relat๓rio de Auditoria de Notas de Combustiveis            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ IMPORTA XML                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function HFXMLR13
Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de acordo com os parametros informados pelo usuario."
Local cDesc3         := "Doctos Entrada x Xml"
Local cPict          := ""
Local titulo       := "Doctos Entrada x Xml"
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
Private nomeprog         := "HFXMLR13" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo            := 18
Private aReturn          := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey        := 0
Private cbtxt      := Space(10)
Private cbcont     := 00
Private CONTFL     := 01
Private m_pag      := 01
Private wnrel      := "NOME" // Coloque aqui o nome do arquivo usado para impressao em disco
Private cPerg      := "HFXMLR13"

AjustaSX1(cPerg)

if Pergunte(cPerg,.T.)
	oReport:= ReportDef()
	oReport:SetParam(cPerg)
	oReport:PrintDialog()
endif

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณReportDef บAutor  ณ Rafael Nastri      บ Data ณ  24/07/2015 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณFun็ใo Auxiliar chamada pela HFXMLR00						  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณIMPORTA XML                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta a Mensagem do titulo do relatorio, conforme op็ใo.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If MV_PAR05 == 1
	cTitulo := "Ocorr๊ncias de Classifica็ใo"
Else
	cTitulo := "Ocorr๊ncias de Arquivo Integra็ใo"
EndIf

oReport := TReport():New("HFXMLR13",@cTitulo,"",{|oReport| PrintReport(oReport)},cDesc1+cDesc2)

oSection1 := TRSection():New(oReport,OemToAnsi("Impressใo da Filial"),{})
TRCell():New(oSection1,"FILIAL" ,xZBO,,,20)
oSection1:SetHeaderSection(.F.)

oSection2 := TRSection():New(oReport,OemToAnsi("Ocorrencias"),{})
TRCell():New(oSection2,"ST"      ,xZBO,,,05,.F.,,"LEFT")
TRCell():New(oSection2,"DTOCOR"  ,xZBO,,,08,.F.,,"CENTER")
TRCell():New(oSection2,"HROCOR"  ,xZBO,,,08,.F.,,"CENTER")
TRCell():New(oSection2,"DESCR"	 ,xZBO,,,90,.F.,,"CENTER")
TRCell():New(oSection2,"CHAVE"	 ,xZBO,,,49,.F.,,"CENTER")
TRCell():New(oSection2,"FTP"     ,xZBO,,,40,.F.,,"LEFT")
TRCell():New(oSection2,"ARQ"     ,xZBO,,,40,.F.,,"LEFT")
oSection2:SetHeaderSection(.F.)

oSection3 := TRSection():New(oReport,OemToAnsi("Ocorrencias"),{})
TRCell():New(oSection3,"ST"      ,xZBO,,,05,.F.,,"LEFT")
TRCell():New(oSection3,"DTOCOR"  ,xZBO,,,10,.F.,,"CENTER")
TRCell():New(oSection3,"HROCOR"  ,xZBO,,,10,.F.,,"CENTER")
TRCell():New(oSection3,"DESCR"	 ,xZBO,,,90,.F.,,"LEFT",.T.)
TRCell():New(oSection3,"CHAVE"	 ,xZBO,,,49,.F.,,"LEFT")
TRCell():New(oSection3,"FTP"     ,xZBO,,,40,.F.,,"LEFT",.T.)
TRCell():New(oSection3,"ARQ"     ,xZBO,,,40,.F.,,"LEFT",.T.)
//TRCell():New(oSection3,"EXAUTO"  ,xZBO,,,35,.F.,,"CENTER")
oSection3:SetHeaderSection(.F.)


oSection4 := TRSection():New(oReport,OemToAnsi("ExecAuto"),{})
TRCell():New(oSection4,"EXAUTO"  ,xZBO,,,200,.F.,,"LEFT",.T.)
oSection4:SetHeaderSection(.F.)


oReport:SetPortrait() 	//Impressใo somente em retrato.
oReport:ParamReadOnly() //Desabilita o acesso ao parametros, no botใo acoes relacionadas.
oReport:DisableOrientation() //Disabilita a selecao da opcao do papel - Retrato \ Paisagem.

Return(oReport)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPrintReportบAutorณRafael Nastri(MONSTRO DA HF)บDataณ24/07/15 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณFun็ใo Auxiliar Responsavel pela impressใo do conteuido.     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณIMPORTA XML                                                  บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function PrintReport(oReport)
Local cFilProc	:= ""
Local cCodFor	:= ""
Local cStatXml	:= ""
Local cCGC		:= ""
Local aStatus 	:= {}
Local nSt       := 0
Private cAliasXMl := GetNextAlias()
Private oSection1 := oReport:Section(1)
Private oSection2 := oReport:Section(2)
Private oSection3 := oReport:Section(3)
Private oSection4 := oReport:Section(4)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta massa de dados temporaria com informa็๕es ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cTabela:= "%"+RetSqlName(xZBO)+"%"
cCampos	:="%"+xZBO_+"FILIAL as FILIAL, "+xZBO_+"DESCR   as DESCR,    "+xZBO_+"DTOCOR as DTOCOR, "+;
              xZBO_+"HROCOR as HROCOR, "+xZBO_+"CHAVE   as CHAVE,    "+xZBO_+"RETSEF as RETSEF, "+;
              xZBO_+"TPOCOR as TPOCOR, "+xZBO_+"REVISA  as REVISA,   "+xZBO_+"ARQ    as ARQ,    "+;
              xZBO_+"ST     as ST,     "+xZBO_+"FTP     as FTP, R_E_C_N_O_ as REG %"
cWhere := "% ZBO.D_E_L_E_T_ <> '*' "
cWhere += " AND  ZBO."+xZBO_+"DTOCOR>='"+Dtos(MV_PAR03)+  "' AND  ZBO."+xZBO_+"DTOCOR<='"+Dtos(MV_PAR04)+"' "
cWhere += " AND  ZBO."+xZBO_+"FILIAL>='"+MV_PAR01+  "' AND  ZBO."+xZBO_+"FILIAL<='"+MV_PAR02+"'"
if MV_PAR07 == 1
	cWhere += " AND  ZBO."+xZBO_+"ST IN (' ','0') "
ElseIf MV_PAR07 == 2
	cWhere += " AND  ZBO."+xZBO_+"ST = '1' "
ElseIf MV_PAR07 == 3
	cWhere += " AND  ZBO."+xZBO_+"ST = '2' "
Endif
cWhere += " AND  ZBO."+xZBO_+"TPOCOR ='"+AllTrim(Str(MV_PAR05))+"' %"

cOrder := "%FILIAL,DTOCOR,HROCOR%"

BeginSql Alias cAliasXMl

	SELECT %Exp:cCampos%
			FROM %Exp:cTabela% ZBO
			WHERE %Exp:cWhere%
    		ORDER BY %Exp:cOrder%
EndSql

Aadd( aStatus, {" ", "S/Acao" } )
Aadd( aStatus, {"0", "S/Acao" } )
Aadd( aStatus, {"1", "Penden" } )
Aadd( aStatus, {"2", "Corrig" } )

DbSelectArea(cAliasXMl)
(cAliasXMl)->(DbGoTop())

oReport:SetMeter((cAliasXMl)->(RecCount()))

While !(cAliasXMl)->(EOF())
	
	cFilProc := (cAliasXMl)->FILIAL
	oSection1:Init()
	oSection1:Cell('FILIAL'):SetValue('Filial - '+(cAliasXMl)->FILIAL)
	oSection1:PrintLine()
	oSection1:Finish()
	
	oReport:SkipLine() //Pula Linha

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Imprime o Cabe็alho dos Itensณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oSection2:Init()
	oSection2:Cell('ST'):SetValue('Stat')
	oSection2:Cell('DTOCOR'):SetValue('Dt.Ocor')
	oSection2:Cell('HROCOR'):SetValue('Hora')
	oSection2:Cell('DESCR'):SetValue('Descri็ใo')
	oSection2:Cell('CHAVE'):SetValue('Chave')
	oSection2:Cell('FTP'):SetValue('Arq.Ftp')
	oSection2:Cell('ARQ'):SetValue('Arq.Local')
	oSection2:PrintLine()
	oSection2:Finish()

	While (cAliasXMl)->(!EOF()) .And. (cAliasXMl)->FILIAL == cFilProc

		If oReport:Cancel()
				MsgStop("Relat๓rio cancelado pelo usuแrio")
				Exit
				Return
		EndIf

		DbSelectArea( xZBO )
		DbGoTo( (cAliasXMl)->REG )
		nSt := aScan( aStatus, {|x| x[1] = (xZBO)->( FieldGet( FieldPos( xZBO_+"ST" ) ) )  } )
		if nSt < 1 .or. nSt > Len(aStatus)
			nSt := 1  //Fadiga
		endif

		oSection3:Init()
		oSection3:Cell('ST'):SetValue( aStatus[nSt][2] )
		oSection3:Cell('DTOCOR'):SetValue( (xZBO)->(FieldGet( FieldPos( xZBO_+"DTOCOR" ) ) ) )
		oSection3:Cell('HROCOR'):SetValue( (xZBO)->(FieldGet( FieldPos( xZBO_+"HROCOR" ) ) ) )
		oSection3:Cell('DESCR'):SetValue( (xZBO)->(FieldGet( FieldPos( xZBO_+"DESCR" ) ) ) )
		oSection3:Cell('CHAVE'):SetValue( (xZBO)->(FieldGet( FieldPos( xZBO_+"CHAVE" ) ) ) )
		oSection3:Cell('FTP'):SetValue( (xZBO)->(FieldGet( FieldPos( xZBO_+"FTP" ) ) ) )
		oSection3:Cell('ARQ'):SetValue( (xZBO)->(FieldGet( FieldPos( xZBO_+"ARQ" ) ) ) )
		oSection3:PrintLine()

		oSection3:Finish()
		oReport:SkipLine() //Pula Linha

		If MV_PAR06 == 1 .AND. ! Empty( (xZBO)->(FieldGet( FieldPos( xZBO_+"EXAUTO" ) ) ) )
			oSection4:Init()
			oSection4:Cell('EXAUTO'):SetValue( (xZBO)->(FieldGet( FieldPos( xZBO_+"EXAUTO" ) ) ) )
			oSection4:PrintLine()
		Endif

		oReport:SkipLine() //Pula Linha
		oReport:IncMeter()

		DbSelectArea(cAliasXMl)
		(cAliasXMl)->(DbSkip())
	EndDo
	oReport:ThinLine() //Imprime uma linha
	oReport:SkipLine() //Pula Linha
EndDo

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

Aadd( aHelpPor, "Informe a Filial inicial a ser processada." )
U_HFPutSx1(cPerg,"01","Filial de   "        ,"Prev.Fechamento de  ","Prev.Fechamento de  "	,"mv_ch1","C",nTmFil,0,0,"G","","SM0","","","mv_par01","","","","","","","","","","","","","","","","",aHelpPor,aHelpPor,aHelpPor)
                 
aHelpPor := {}
Aadd( aHelpPor, "Informe a Filial final a ser processada." )
U_HFPutSx1(cPerg,"02","Filial Ate  "        ,"Prev.Fechamento Ate ","Prev.Fechamento Ate "	,"mv_ch2","C",nTmFil,0,0,"G","","SM0","","","mv_par02","","","","","","","","","","","","","","","","",aHelpPor,aHelpPor,aHelpPor)

aHelpPor := {}
Aadd( aHelpPor, "Informe a Data da ocorrencia Inicial." )
U_HFPutSx1(cPerg,"03","Data de  "        ,"Prev.Fechamento de  ","Prev.Fechamento de  "	,"mv_ch3","D",08,0,0,"G","",   "","","","mv_par03","","","","","","","","","","","","","","","","",aHelpPor,aHelpPor,aHelpPor)

aHelpPor := {}
Aadd( aHelpPor, "Informe a Data da ocorrencia final." )
U_HFPutSx1(cPerg,"04","Data Ate "        ,"Prev.Fechamento Ate ","Prev.Fechamento Ate "	,"mv_ch4","D",08,0,0,"G","",   "","","","mv_par04","","","","","","","","","","","","","","","","",aHelpPor,aHelpPor,aHelpPor)

aHelpPor := {}
Aadd( aHelpPor, "Tipo da Ocorrencia:" )
Aadd( aHelpPor, "1 - Classifica็ใo;" )
Aadd( aHelpPor, "2 - Arquivo da Integra็ใo." )
U_HFPutSx1(cPerg,"05","Tipo Ocorrencia " ,"Tipo Ocorrencia "    ,"Tipo Ocorrencia "  	,"mv_ch5","N",1,0,0,"C","",   "","","","mv_par05","Classifica็ใo","","","","Arquivo","","","","","","","","","","","",aHelpPor,aHelpPor,aHelpPor)

aHelpPor := {}
Aadd( aHelpPor, "Para Tipo Classifica็ใo:" )
Aadd( aHelpPor, "1 - Imprime erro do Execauto;" )
Aadd( aHelpPor, "2 - NรO Imprime erro do Execauto." )
U_HFPutSx1(cPerg,"06","Impr.Erro Classif." ,"Impr.Erro Classif.","Impr.Erro Classif."  	,"mv_ch6","N",1,0,0,"C","",   "","","","mv_par06","SIM"          ,"","","","NรO"     ,"","",""         ,"","",""     ,"","","","","",aHelpPor,aHelpPor,aHelpPor)

aHelpPor := {}
Aadd( aHelpPor, "Status:" )
Aadd( aHelpPor, "0 - Sem A็ใo;" )
Aadd( aHelpPor, "1 - Pendente;"  )
Aadd( aHelpPor, "2 - Corrigido;" )
Aadd( aHelpPor, "3 - Todos."     )
U_HFPutSx1(cPerg,"07","Status" 			   ,"Status"            ,"Status"  	            ,"mv_ch7","N",1,0,0,"C","",   "","","","mv_par07","S/A็ใo"       ,"","","","Pendente","","","Corrigido","","","Todos","","","","","",aHelpPor,aHelpPor,aHelpPor)

Return


Static Function __Dummy(lRecursa) //warning W0010 Static Function <?> never called
    lRecursa := .F.
    IF (lRecursa)
        __Dummy(.F.)
        U_HFXMLR13()
	EndIF
Return(lRecursa)