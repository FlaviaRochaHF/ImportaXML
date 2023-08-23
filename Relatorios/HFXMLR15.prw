#Include "Protheus.Ch"
#Include "RwMake.Ch"
#Include "TbiConn.Ch"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HFXMLR15  �Autor  � Fl�via Rocha           �Dt�  25/09/2019 ���
�������������������������������������������������������������������������͹��
���Descricao ��Divergencia de NCM� que mostra os itens das pr�-notas      ���
���            ou documento de entrada cujo NCM est�o diferentes do NCM   ���
���            do XML.Relat�rio de compara��o de documentos fiscais de    ���
���            entrada que n�o foi recepcionado o XML do Fornecedores.    ���		      
�������������������������������������������������������������������������͹��
���Uso       �IMPORTA XML                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
//--------------------------------------------------------------------------//
//FR - 12/06/2020 - Altera��es realizadas para adequar a valida��o da licen�a 
//                  quando for licen�a Demonstra��o (Demo)
//                  Implementado "flag" para sinalizar todo o sistema quando
//                  for licen�a Demo e assim, N�O permitir consultas
//                  no relat�rio de pr�-auditoria de forma abrangente
//                  Demo = consulta � data de hoje - 30 apenas
//                  
//--------------------------------------------------------------------------//
User Function HFXMLR15()
Local oReport	    := Nil
Private cPerg 	    := "HFXMLR15"
Private lDemonstra  := .F.

dVencLic   := Stod(Space(8))
//lUsoOk     := U_HFXML00X("HF000001","101",SM0->M0_CGC,@dVencLic)  
lUsoOk	:= U_HFXMLLIC()
lDemonstra := lDemo		//FR - 12/06/2020 - tratativa para licen�as Demo

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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ReportDef �Autor  � Fl�via Rocha       � Data �  25/09/2019 ���
�������������������������������������������������������������������������͹��
���Descricao �Fun��o Auxiliar chamada pela HFXMLR15						  ���
�������������������������������������������������������������������������͹��
���Uso       �IMPORTA XML                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef(lDemonstra)
Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2        := "de acordo com os parametros informados pelo usuario."
Local cTitulo		:= ""
Private oReport 	:= Nil
Private oSection1   := Nil
Private oSection2   := Nil

//��������������������������������������������������������Ŀ
//�Monta a Mensagem do titulo do relatorio, conforme op��o.�
//����������������������������������������������������������
cTitulo := "Rela��o de Diverg�ncia de NCM"

oReport := TReport():New("HFXMLR15",@cTitulo,"",{|oReport| PrintReport(oReport,lDemonstra)},cDesc1+cDesc2)

oSection1 := TRSection():New(oReport,OemToAnsi("Cabe�alho dos Itens"),{})

TRCell():New(oSection1,"NOTA"	  	,"SF1",		,,15,.F.,,"CENTER")
TRCell():New(oSection1,"SERIE"  	,"SF1",		,,07,.F.,,"CENTER")
TRCell():New(oSection1,"ITEM"	  	,"SF1",		,,07,.F.,,"CENTER")
TRCell():New(oSection1,"NOME_EMIT"	,"SF1",		,,35,.F.,,"CENTER")
TRCell():New(oSection1,"EMISSAO"	,"SF1",		,,15,.F.,,"CENTER")
TRCell():New(oSection1,"DTDIGIT"	,"SF1",		,,15,.F.,,"CENTER")
TRCell():New(oSection1,"D1COD"		,"SF1",		,,15,.F.,,"CENTER")
TRCell():New(oSection1,"B1POSIPI"	,"SF1",		,,15,.F.,,"CENTER")
TRCell():New(oSection1,"D1TEC"		,"SF1",		,,15,.F.,,"CENTER")
TRCell():New(oSection1,"PAGINA"		,"SF1",		,,07,.F.,,"CENTER")
oSection1:SetHeaderSection(.F.) 

oSection2 := TRSection():New(oReport,OemToAnsi("Itens das Notas Fiscais"),{})

TRCell():New(oSection2,"NOTA"	  	,"SF1",	,,15,.F.,,"CENTER")
TRCell():New(oSection2,"SERIE"	  	,"SF1",	,,07,.F.,,"CENTER")
TRCell():New(oSection2,"ITEM"  		,"SF1",	,,07,.F.,,"CENTER") //item
TRCell():New(oSection2,"NOME_EMIT"	,"SF1",	,,35,.F.,,"CENTER") //nome fornecedor
TRCell():New(oSection2,"EMISSAO"  	,"SF1",	,,15,.F.,,"CENTER")
TRCell():New(oSection2,"DTDIGIT"  	,"SF1",	,,15,.F.,,"CENTER")
TRCell():New(oSection2,"D1COD"		,"SF1",	,,15,.F.,,"CENTER") //produto
TRCell():New(oSection2,"B1POSIPI"  	,"SF1",	,,15,.F.,,"CENTER") //produto ncm C10
TRCell():New(oSection2,"D1TEC"     	,"SF1",	,,15,.F.,,"CENTER") //cad ncm C16
oSection2:SetHeaderSection(.F.)

oReport:SetPortrait() 			//Impress�o somente em retrato.
oReport:ParamReadOnly() 		//Desabilita o acesso ao parametros, no bot�o acoes relacionadas.
oReport:DisableOrientation() 	//Desabilita a selecao da opcao do papel - Retrato \ Paisagem.

Return(oReport)
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PrintReport� Autor: Fl�via Rocha             � Data�26/09/19 ���
��������������������������������������������������������������������������͹��
���Descricao �Fun��o Auxiliar Responsavel pela impress�o do conteuido.     ���
��������������������������������������������������������������������������͹��
���Uso       �IMPORTA XML                                                  ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Static Function PrintReport(oReport,lDemonstra)
Local cFilProc		:= ""
Local cCodFor		:= ""
Local cStatXml		:= ""
Local cCGC			:= ""
Local aManif      	:= {}
Private cAliasXMl 	:= GetNextAlias()
Private oSection1 	:= oReport:Section(1)
Private oSection2 	:= oReport:Section(2)

//������������������������������������������������������������Ŀ
//� Monta massa de dados temporaria com informa��es de NF x XML�
//��������������������������������������������������������������
//fGeraDados(cAliasXML,"1",.T.)
fGeraDados(cAliasXML,lDemonstra)

DbSelectArea(cAliasXMl)
(cAliasXMl)->(DbGoTop())

oReport:SetMeter((cAliasXMl)->(RecCount()))
nLin := 1
While !(cAliasXMl)->(EOF())
	
	cNota    := (cAliasXMl)->F1_DOC
	cSerie   := (cAliasXMl)->F1_SERIE
	cFornece := (cAliasXMl)->F1_FORNECE
    cLoja    := (cAliasXMl)->F1_LOJA
	oSection1:Init()
	
	//������������������������������Ŀ
	//� Imprime o Cabe�alho dos Itens�
	//��������������������������������
	
	oSection1:Cell('NOTA'):SetValue('Nota Fiscal')
	oSection1:Cell('SERIE'):SetValue('Serie')
	oSection1:Cell('ITEM'):SetValue('Item')
	oSection1:Cell('NOME_EMIT'):SetValue('Fornecedor')
	oSection1:Cell('EMISSAO'):SetValue('Emiss�o')
	oSection1:Cell('DTDIGIT'):SetValue('Digita��o')
	oSection1:Cell('D1COD'):SetValue('Produto')
	oSection1:Cell('B1POSIPI'):SetValue('NCM Cadastro')
	oSection1:Cell('D1TEC'):SetValue('NCM XML')	
	oSection1:PrintLine()
	oSection1:Finish()
	oReport:SkipLine() //Pula Linha
		
	While (cAliasXMl)->(!EOF()) .And. ((cAliasXMl)->F1_DOC + (cAliasXMl)->F1_SERIE) == (cNota + cSerie)  .And. ((cAliasXMl)->F1_FORNECE + (cAliasXMl)->F1_LOJA) == (cFornece + cLoja)
		
			//�������������������������������������Ŀ
			//� Verifica o cancelamento pelo usuario�
			//���������������������������������������
			If oReport:Cancel()
				MsgStop("Relat�rio cancelado pelo usu�rio")
				Exit
				Return
			EndIf
        
			oSection2:Init()
		
			oSection2:Cell('NOTA'):SetValue((cAliasXMl)->F1_DOC)
			oSection2:Cell('SERIE'):SetValue((cAliasXMl)->F1_SERIE)
			oSection2:Cell('ITEM'):SetValue((cAliasXMl)->D1_ITEM) //item
			oSection2:Cell('NOME_EMIT'):SetValue((cAliasXML)->F1_NOME)
			oSection2:Cell('EMISSAO'):SetValue((cAliasXMl)->F1_EMISSAO)
			oSection2:Cell('DTDIGIT'):SetValue((cAliasXMl)->F1_DTDIGIT)
			oSection2:Cell('D1COD'):SetValue((cAliasXMl)->D1_COD) //produto
			oSection2:Cell('B1POSIPI'):SetValue((cAliasXMl)->B1_POSIPI) //cad produto ncm
			oSection2:Cell('D1TEC'):SetValue((cAliasXMl)->D1_TEC) //xml ncm
								
			oSection2:PrintLine()		
			oSection2:Finish()
			oReport:SkipLine() //Pula Linha
			oReport:IncMeter()
			
			(cAliasXMl)->(DbSkip())
				
	EndDo
	oReport:ThinLine() //Imprime uma linha
	oReport:SkipLine() //Pula Linha
EndDo

(cAliasXMl)->(DbCloseArea())
Return
/*/
����������������������������������������������������������������������������
����������������������������������������������������������������������������
������������������������������������������������������������������������ͻ��
���Programa  �AjustaSX1� Autor  � Fl�via Rocha      � Data �  25/09/2019 ���
������������������������������������������������������������������������͹��
���Descricao �Fun��o Auxiliar Responsavel pela cria��o da Pergunta.      ���
������������������������������������������������������������������������͹��
���Uso       �IMPORTA XML                                                ���
������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������
����������������������������������������������������������������������������
/*/
Static Function AjustaSX1()
Local aHelpPor := {}    
Local nTmFil  := FWGETTAMFILIAL

Aadd( aHelpPor, "Informe a Filial inicial a ser processada." )
U_HFPutSx1(cPerg,"01","Filial de   "        ,"Prev.Fechamento de  "				,"Prev.Fechamento de  "			,"mv_ch1","C",nTmFil,0,0,"G","","SM0","","","mv_par01","","","","","","","","","","","","","","","","",aHelpPor,aHelpPor,aHelpPor)//Alterado para criar o SX1 de acordo com a filial, 04/07/2016

aHelpPor := {}
Aadd( aHelpPor, "Informe a Filial final a ser processada." )
U_HFPutSx1(cPerg,"02","Filial Ate  "        ,"Prev.Fechamento Ate "				,"Prev.Fechamento Ate "			,"mv_ch2","C",nTmFil,0,0,"G","","SM0","","","mv_par02","","","","","","","","","","","","","","","","",aHelpPor,aHelpPor,aHelpPor)

aHelpPor := {}
Aadd( aHelpPor, "Informe o codigo inicial do emissor do XML." )
U_HFPutSx1(cPerg,"03","Emissor do XML de   "	,"Emissor do XML de "				,"Emissor do XML de "			,"mv_ch3","C",TAMSX3("ZBZ_CODFOR")[1],0,0,"G","","SA2","","","mv_par03","","","","","","","","","","","","","","","","",aHelpPor,aHelpPor,aHelpPor)

aHelpPor := {}
Aadd( aHelpPor, "Informe o codigo final do emissor do XML." )
U_HFPutSx1(cPerg,"04","Emissor do XML ate   "	,"Emissor do XML ate "				,"Emissor do XML ate "			,"mv_ch4","C",TAMSX3("ZBZ_CODFOR")[1],0,0,"G","","SA2","","","mv_par04","","","","","","","","","","","","","","","","",aHelpPor,aHelpPor,aHelpPor)

aHelpPor := {}
Aadd( aHelpPor, "Informe a loja inicial do emissor do XML." )
U_HFPutSx1(cPerg,"05","Loja do Emissor do XML de   "	,"Loja de "					,"Loja de "						,"mv_ch5","C",TAMSX3("ZBZ_LOJFOR")[1],0,0,"G","","","","","mv_par05","","","","","","","","","","","","","","","","",aHelpPor,aHelpPor,aHelpPor)

aHelpPor := {}
Aadd( aHelpPor, "Informe a loja final do emissor do XML." )
U_HFPutSx1(cPerg,"06","Loja do Emissor do XML ate   "	,"Loja ate"					,"Loja ate "					,"mv_ch6","C",TAMSX3("ZBZ_LOJFOR")[1],0,0,"G","","","","","mv_par06","","","","","","","","","","","","","","","","",aHelpPor,aHelpPor,aHelpPor)

aHelpPor := {}
Aadd( aHelpPor, "Informe a Data de EMISS�O inicial." )
U_HFPutSx1(cPerg,"07","Emiss�o de  "        			,"Emiss�o de  "				,"Emiss�o de  "					,"mv_ch7","D",08,0,0,"G","", "","","","mv_par07","","","","","","","","","","","","","","","","",aHelpPor,aHelpPor,aHelpPor)

aHelpPor := {}
Aadd( aHelpPor, "Informe a Data de EMISS�O final." )
U_HFPutSx1(cPerg,"08","Emiss�o Ate "        			,"Emiss�o Ate "				,"Emiss�o Ate "					,"mv_ch8","D",08,0,0,"G","","","","","mv_par08","","","","","","","","","","","","","","","","",aHelpPor,aHelpPor,aHelpPor)


aHelpPor := {}
Aadd( aHelpPor, "Informe a Data de DIGITA��O inicial." )
U_HFPutSx1(cPerg,"09","Digita��o de  "        		,"Digita��o de "			,"Digita��o de "				,"mv_ch9","D",08,0,0,"G","","","","","mv_par09","","","","","","","","","","","","","","","","",aHelpPor,aHelpPor,aHelpPor)

aHelpPor := {}
Aadd( aHelpPor, "Informe a Data de DIGITA��O final." )
U_HFPutSx1(cPerg,"10","Digita��o Ate "        		,"Digita��o Ate "			,"Digita��o Ate "				,"mv_cha","D",08,0,0,"G","","","","","mv_par10","","","","","","","","","","","","","","","","",aHelpPor,aHelpPor,aHelpPor)

Return   


****************************************
Static Function fGeraDados(cAliasXML,lDemonstra)
****************************************
Local cPerg   := "HFXMLR15" 
Local lperg   := Pergunte(cPerg,.F.)
Local Nx      := 0
Local nOrdem
Local cWhere  := ""
Local cTabela := ""
Local cOrder  := ""
Local cLinCab := ""     
Local cFilDe  := MV_PAR01
Local cFilAte := MV_PAR02
Local cForIni := MV_PAR03
Local cForFim := MV_PAR04
Local cLojaIni:= MV_PAR05
Local cLojaFim:= MV_PAR06 
Local cEmIni  := MV_PAR07
Local cEmFim  := MV_PAR08
Local cDtIni  := MV_PAR09
Local cDtFim  := MV_PAR10
Local cQuery  := ""

Private cSF1   		:= GetNextAlias() 
Private lSharedA1	:= U_IsShared("SA1")
Private lSharedA2	:= U_IsShared("SA2") 
Private nFormNfe  	:= Val(GetNewPar("XM_FORMNFE","6"))
Private nFormCTe  	:= Val(GetNewPar("XM_FORMCTE","6"))

aCampos := {}
AADD(aCampos,{"F1_FILIAL"	,"C" ,	FWGETTAMFILIAL	,0 })// alterado pois a CIEE tem a filial de 4 posi��es, Analista Alexandro e Rodrigo data 04/07/2016
AADD(aCampos,{"F1_FORNECE"	,"C" ,	006	,0 })
AADD(aCampos,{"F1_LOJA"		,"C" ,	002	,0 })
AADD(aCampos,{"F1_TIPO"		,"C" ,	001	,0 })
AADD(aCampos,{"F1_DOC"      ,"C" ,	009	,0 })
AADD(aCampos,{"F1_SERIE"	,"C" ,	003	,0 })
AADD(aCampos,{"F1_EMISSAO"	,"D" ,	008	,0 })
AADD(aCampos,{"F1_DTDIGIT"	,"D" ,	008	,0 })	
AADD(aCampos,{"D1_SERIE"	,"C" ,	003	,0 })
AADD(aCampos,{"D1_DOC"      ,"C" ,	009	,0 })	
AADD(aCampos,{"D1_ITEM"		,"C" ,	004	,0 })	
AADD(aCampos,{"F1_NOME"		,"C" ,	030	,0 })
AADD(aCampos,{"D1_EMISSAO"	,"D" ,	008	,0 })
AADD(aCampos,{"D1_DTDIGIT"	,"D" ,	008	,0 })
AADD(aCampos,{"D1_COD"      ,"C" ,	015	,0 })
AADD(aCampos,{"B1_POSIPI"   ,"C" ,	010	,0 })
AADD(aCampos,{"D1_TEC"   	,"C" ,	016	,0 })

cArqEmp	:=	CriaTrab(aCampos)
	
dbUseArea(.T.,__LocalDrive,cArqEmp,cAliasXML,.T.,.F.)
	       
DbSelectArea(cAliasXML)
cIndEmp		:=CriaTrab (NIL, .F.)
cChave      := "F1_FILIAL+F1_FORNECE+F1_LOJA+F1_TIPO+F1_DOC+F1_SERIE" //ENEO includo F1_TIPO em 27/08/2015
cFiltroTmp	:= ""
  
IndRegua(cAliasXML, cIndEmp, cChave,, cFiltroTmp)
DbSetIndex(cIndEmp+OrdBagExt ())
DbSetOrder(1)	
DbGoTop()   

//FR - 12/06/2020 - Tratativa para licen�a Demo:
If lDemonstra
	If ( (cDtFim - cDtIni) > 30 .or. (cEmFim - cEmIni) > 30 )
		MsgInfo("Esta � Uma Licen�a de Demonstra��o, o Per�odo para Consulta Ser� Limitado a At� 30 (Trinta) Dias!")		
	Endif
Endif

LF := CHR(13)+ CHR(10)
cQuery := " Select F1_FILIAL, F1_DOC, F1_SERIE, F1_TIPO, F1_FORNECE, F1_LOJA, F1_EMISSAO, F1_DTDIGIT, " + LF
cQuery += " D1_SERIE, D1_DOC, D1_ITEM, D1_EMISSAO, D1_DTDIGIT, D1_COD, D1_TEC, " + LF
cQuery += " B1_POSIPI "+ LF
cQuery += " FROM " + RetSqlName("SD1") + " SD1 " + LF
cQuery += " INNER JOIN " + RetSqlName("SF1") + " SF1 ON F1_FILIAL = D1_FILIAL AND F1_TIPO = D1_TIPO AND F1_SERIE = D1_SERIE AND F1_DOC = D1_DOC AND SF1.D_E_L_E_T_ <> '*' "+ LF
cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 ON B1_COD = D1_COD AND SB1.D_E_L_E_T_ <> '*' " + LF
cQuery += " WHERE " + LF
cQuery += " SD1.D_E_L_E_T_ <> '*' "
If !lDemonstra		//FR - 12/06/2020 - tratativa para licen�as Demo
	cQuery += " AND  SF1.F1_DTDIGIT >='"+ DtoS(cDtIni) +"' AND  SF1.F1_DTDIGIT <='"+ DtoS(cDtFim) +"' "+ LF 
	cQuery += " AND  SF1.F1_EMISSAO >='"+ DtoS(cEmIni) +"' AND SF1.F1_EMISSAO <='" + DtoS(cEmFim) +"'"+ LF
Else
	cQuery += " AND  SF1.F1_DTDIGIT >='"+ DtoS(Date()-30) +"' AND SF1.F1_DTDIGIT <='"+ DtoS(Date()) +"' "+ LF 
	cQuery += " AND  SF1.F1_EMISSAO >='"+ DtoS(Date()-30) +"' AND SF1.F1_EMISSAO <='"+ DtoS(Date()) +"'"+ LF
Endif
cQuery += " AND  SF1.F1_FORMUL <> 'S' "	+ LF
cQuery += " AND  SF1.F1_FILIAL>='"+cFilDe+"' AND  SF1.F1_FILIAL<='"+cFilAte+"'"	+ LF
cQuery += " AND  SF1.F1_FORNECE>='"+cForIni+"' AND  SF1.F1_FORNECE<='"+cForFim+"' "+ LF						               
cQuery += " AND  SF1.F1_LOJA >='"+cLojaIni+"' AND  SF1.F1_LOJA <='"+cLojaFim+"' "	+ LF
cQuery += " AND  LTRIM(RTRIM(SB1.B1_POSIPI)) <> LTRIM(RTRIM(SD1.D1_TEC)) " + LF					               
cQuery += " ORDER BY F1_FILIAL,F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, D1_ITEM "+ LF
MemoWrite("C:\TEMP\HFXMLR15.SQL", cQuery)

If Select(cSF1)> 0
	DbselectArea(cSF1)
	DbCloseArea()
Endif
DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cSF1,.F.,.T.)
DbSelectArea(cSF1)

DbGoTop()
If (cSF1)->(!Eof()) 
	(cSF1)->(Dbgotop())
	While (cSF1)->(!EOF())
		cFilProc := (cSF1)->F1_FILIAL
				
		If (cSF1)->F1_TIPO $ "D|B"
			DbSelectArea("SA1")
			dbsetorder(1)
			cFilSeek := Iif(lSharedA1,xFilial("SA1"),cFilProc)
			if DbSeek(cFilSeek+(cSF1)->F1_FORNECE+(cSF1)->F1_LOJA)
				cCnPjF   := SA1->A1_CGC
				cNome    := SA1->A1_NOME			
			Else
				cCnPjF   := SA1->A1_CGC
				cNome    := SA1->A1_NOME
				cTel     := SA1->A1_DDD + " " + SA1->A1_TEL			
			EndIf
		Else            
			DbSelectArea("SA2")
			dbsetorder(1)
			cFilSeek := Iif(lSharedA2,xFilial("SA2"),cFilProc)
			IF DbSeek(cFilSeek+(cSF1)->F1_FORNECE+(cSF1)->F1_LOJA)
				cCnPjF   := SA2->A2_CGC 
				cNome    := SA2->A2_NOME			
			Else
				cCnPjF   := SA2->A2_CGC 
				cNome    := SA2->A2_NOME
				cTel     := SA2->A2_DDD + " " + SA2->A2_TEL			
			Endif
			
		EndIf        
				
		RecLock(cAliasXML,.T.)
		(cAliasXML)->F1_DOC		:= (cSF1)->F1_DOC
		(cAliasXML)->F1_SERIE	:= (cSF1)->F1_SERIE
		(cAliasXML)->D1_ITEM    := (cSF1)->D1_ITEM
		(cAliasXML)->F1_NOME    := cNome
		(cAliasXML)->F1_EMISSAO := Stod((cSF1)->F1_EMISSAO)
		(cAliasXML)->F1_DTDIGIT := Stod((cSF1)->F1_DTDIGIT)
		(cAliasXML)->D1_COD		:= (cSF1)->D1_COD
		(cAliasXML)->B1_POSIPI  := (cSF1)->B1_POSIPI
		(cAliasXML)->D1_TEC     := (cSF1)->D1_TEC
		(cAliasXML)->F1_FILIAL	:= (cSF1)->F1_FILIAL
		(cAliasXML)->F1_FORNECE	:= (cSF1)->F1_FORNECE
		(cAliasXML)->F1_LOJA	:= (cSF1)->F1_LOJA
		(cAliasXML)->F1_TIPO    := (cSF1)->F1_TIPO    //ENEO includo F1_TIPO em 27/08/2015  
				
		MsUnlock()
										
		(cSF1)->(DbSkip())				   
	EndDo
	(cSF1)->( dbCloseArea() )  //ENEO includo F1_TIPO em 27/08/2015
Endif  

Return
