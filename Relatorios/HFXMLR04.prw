#include "Totvs.ch"
#include "Topconn.ch"


//Partindo da ZBZ U_HFR4GFE1()
User Function HFR4GFE1()

dVencLic := Stod(Space(8))
//lUsoOk := U_HFXML00X("HF000001","101",SM0->M0_CGC,@dVencLic)  
lUsoOk	:= U_HFXMLLIC()

If !lUsoOk
	Return(Nil)
EndIf

U_HFXMLR04("ZBZ")

Return(NIL)


//Partindo da GW3 U_HFR4GFE2()
User Function HFR4GFE2()

dVencLic := Stod(Space(8))
//lUsoOk := U_HFXML00X("HF000001","101",SM0->M0_CGC,@dVencLic)  
lUsoOk	:= U_HFXMLLIC(.F.)

If !lUsoOk
	Return(Nil)
EndIf

U_HFXMLR04("GW3")

Return(NIL)


/*/{Protheus.doc} HfXmlR04()
    (long_description)
    @type  Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return returno,return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    Relatorio de registros xml com frete embarcador GW3
/*/

User Function HFXMLR04(cQual)  //U_HFXMLR04("ZBZ")

    Local oReport   := NIL
    //Local aPergs    := {}
    Default cQual   := "   "

    Private cPerg := "HFXMLR04" 
    Private xZBZ  := GetNewPar("XM_TABXML","ZBZ")
    Private xZBZ_ := iif(Substr(xZBZ,1,1)=="S", Substr(xZBZ,2,2), Substr(xZBZ,1,3)) + "_"
    Private cRef  := cQual 

	dVencLic := Stod(Space(8))
	//lUsoOk := U_HFXML00X("HF000001","101",SM0->M0_CGC,@dVencLic)  
	lUsoOk	:= U_HFXMLLIC(.F.)

	If !lUsoOk
		Return(Nil)
	EndIf

	ValidPerg(cPerg) 
	
	If !Pergunte(cPerg,.T.)
	     Return()
	EndIf 

    oReport := ReportDef()
    oReport:PrintDialog() 
    
Return

/*/{Protheus.doc} ReportPrint(oReport,cAlias)
    (long_description)
    @type  Static Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return returno,return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/

Static Function PrintReport(oReport)

    Local oSection  := oReport:Section(1)
    Local cQuery    := ""
    Local nTotReg   := 0
    
    cQuery := " SELECT "+xZBZ_+"PRENF AS STATUS_IMPORTA, "
    cQuery += " GW3_SIT AS STATUS_GFE, "
    cQuery += " (CASE WHEN GW3_CTE IS NULL THEN "+xZBZ_+"CHAVE ELSE GW3_CTE END) as CHAVE, "
    cQuery += " "+xZBZ_+"CODFOR AS FORNECEDOR, "+xZBZ_+"LOJFOR AS LOJA,"
    cQuery += " (CASE WHEN "+xZBZ_+"DTNFE IS NULL THEN GW3_DTEMIS ELSE "+xZBZ_+"DTNFE END) as DATA, " 
    cQuery += " (CASE WHEN "+xZBZ_+"VLBRUT IS NULL THEN GW3_FRVAL ELSE "+xZBZ_+"VLBRUT END) as VALOR FROM "+ RetSqlName(xZBZ) + " ZBZ "
    cQuery += " FULL OUTER JOIN "+ RetSqlName("GW3") + " GW3 ON GW3_CTE = "+xZBZ_+"CHAVE AND GW3.D_E_L_E_T_ = ' ' "
    if cRef = "ZBZ"
    	cQuery += " WHERE "+xZBZ_+"FILIAL BETWEEN '"+Mv_Par01+"' and '"+Mv_Par02+"' AND "
	   	cQuery += " "+xZBZ_+"MODELO = '57' AND "
	    cQuery += " "+xZBZ_+"CODFOR BETWEEN '"+Mv_Par03+"' and '"+Mv_Par04+"' AND "
	    cQuery += " "+xZBZ_+"LOJFOR BETWEEN '"+Mv_Par05+"' and '"+Mv_Par06+"' AND "
	    cQuery += " "+xZBZ_+"DTNFE BETWEEN '"+Dtos(Mv_Par07)+"' and '"+Dtos(Mv_Par08)+"'"
	    cQuery += " ORDER BY "+xZBZ_+"DTNFE "
    else  //if cRef = "GW3"
    	cQuery += " WHERE GW3_FILIAL BETWEEN '"+Mv_Par01+"' and '"+Mv_Par02+"' AND "
	    cQuery += " GW3_DTEMIS BETWEEN '"+Dtos(Mv_Par07)+"' and '"+Dtos(Mv_Par08)+"'"
	    cQuery += " ORDER BY GW3_DTEMIS "
    endif

    TCQuery cQuery NEW ALIAS "TCQ" 

    Count to nTotreg 

    TCQ->( DbGotop() )

    oReport:SetMeter( nTotreg )
    
    While ( TCQ->( !Eof() ) )
	
		If oReport:Cancel()
			Exit
		EndIf
		
		oSection:Init()
		
		oSection:Cell("ZBZ_PRENF"):SetValue(TCQ->STATUS_IMPORTA)
		//oSection:Cell("ZBZ_PRENF"):SetValue(u_zHFDesc(TCQ->STATUS_IMPORTA, xZBZ_+"PRENF", "") )
		oSection:Cell("GW3_SIT"):SetValue(u_zHFDesc(TCQ->STATUS_GFE, "GW3_SIT", ""))
		oSection:Cell("GW3_CTE"):SetValue(TCQ->CHAVE)
		
		DbSelectArea("SA2")
		DbSetOrder(1)
		DbSeek( xFilial("SA2") + TCQ->FORNECEDOR + TCQ->LOJA )
		
		oSection:Cell("A2_NOME"):SetValue(TCQ->FORNECEDOR +" - "+ Alltrim( SA2->A2_NOME ))
		oSection:Cell("ZBZ_DTNFE"):SetValue(Substr(TCQ->DATA,7,2)+"/"+Substr(TCQ->DATA,5,2)+"/"+LEFT(TCQ->DATA,4))
		oSection:Cell("ZBZ_VLBRUT"):SetValue(TCQ->VALOR)
		
		oSection:PrintLine()
		
		oReport:SkipLine()
		oReport:IncMeter()
		
		TCQ->( DbSkip() )

	End
	
	oSection:Finish()
	
	TCQ->( DbCloseArea() )
	
    
    
   // oSection1:endQuery()
   // oReport:SetMeter((cAlias)->(recCount()))
   // oSection1:Print()
    
return

/*/{Profheus.doc} reportdef(cAlias,cPerg)
    (long_description)
    @type  Static Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return returno,return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/

Static Function ReportDef(cAlias)

Local oReport
Local oSection
Local cTit := ""

if cRef = "ZBZ"
	cTit := "Relação dos CTE Importa Xml x GFE"
else
	cTit := "Relação dos CTE GFE x Importa Xml"
endif

oReport := TReport():New("HFXMLR04",cTit,"HFXMLR04",{|oReport| PrintReport(oReport)},"Este relatorio ira imprimir a Relação dos CTE Importa Xml x GFE conforme os parametros solicitados.")

if cRef = "ZBZ"
	oSection := TRSection():New(oReport,OemToAnsi("Relação dos CTE Importa Xml x GFE"),{xZBZ,"GW3","SA2"})
else
	oSection := TRSection():New(oReport,OemToAnsi("Relação dos CTE GFE x Importa Xml"),{xZBZ,"GW3","SA2"})
endif

TRCell():New(oSection,xZBZ_+"PRENF",xZBZ)
TRCell():New(oSection,"GW3_SIT","GW3")
TRCell():New(oSection,"GW3_CTE","GW3")
TRCell():New(oSection,"A2_NOME","SA2")
TRCell():New(oSection,xZBZ_+"DTNFE",xZBZ)
TRCell():New(oSection,xZBZ_+"VLBRUT",xZBZ,"VALOR","@E 999,999,999.99")

Return oReport

/*/{Protheus.doc} ajustaSX1(cPerg)
    (long_description)
    @type  Static Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return returno,return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/


Static Function ValidPerg(cPerg)

Local _sAlias 	:= Alias()
Local aRegs 	:= {}
Local nI,nJ

SX1->(DbSelectArea("SX1"))
SX1->(DbSetOrder(1))
cPerg := PADR(cPerg,Len(SX1->X1_GRUPO))
	
// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05  
AADD(aRegs,{cPerg,"01","De Filial ?     ",".....           ",".....          ","mv_ch1","C",2, 0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"02","Ate Filial ?    ",".....           ",".....          ","mv_ch2","C",2 ,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})  
AADD(aRegs,{cPerg,"03","De Emissor ?    ",".....           ",".....          ","mv_ch3","C",6, 0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SA2"})
AADD(aRegs,{cPerg,"04","Ate Emissor ?   ",".....           ",".....          ","mv_ch4","C",6 ,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SA2"})  
AADD(aRegs,{cPerg,"05","De Loja Emis. ? ",".....           ",".....          ","mv_ch5","C",2, 0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"06","Ate Loja Emis. ?",".....           ",".....          ","mv_ch6","C",2 ,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})  
AADD(aRegs,{cPerg,"07","De Data xml ?   ",".....           ",".....          ","mv_ch7","D",8, 0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"08","Ate Data xml ?  ",".....           ",".....          ","mv_ch8","D",8 ,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})  

For nI:=1 to Len(aRegs)
	If !SX1->(DbSeek(cPerg+aRegs[nI,2]))
		SX1->(RecLock("SX1",.T.))
		For nJ:=1 to SX1->(FCount())
			If nJ <= Len(aRegs[nI])
				SX1->(FieldPut(nJ,aRegs[nI,nJ]))
			EndIf
		Next nJ
		SX1->(MsUnlock())
	EndIf
Next nI
	
&(_sAlias)->(DbSelectArea(_sAlias))

Return


/*/{Protheus.doc} zCmbDesc
Função que retorna a descrição da opção do Combo selecionada
@type function
@author Atilio
@since 28/08/2016
@version 1.0
	@param cChave, character, Chave de pesquisa dentro do combo
	@param cCampo, character, Campo do tipo combo
	@param cConteudo, character, Conteúdo no formato de combo
	@return cDescri, Descrição da opção do combo
	@example
	u_zCmbDesc("D", "C5_TIPO", "") //Utilizando por Campo
	u_zCmbDesc("S", "", "S=Sim;N=Não;A=Ambos;") //Utilizando por Conteúdo
/*/
User Function zHFDesc( cChave, cCampo, cConteudo )

Local aArea       := GetArea()
Local aCombo      := {}
Local nAtual      := 1
Local cDescri     := ""
Default cChave    := ""
Default cCampo    := ""
Default cConteudo := ""

//Se o campo e o conteúdo estiverem em branco, ou a chave estiver em branco, não há descrição a retornar
If (Empty(cCampo) .And. Empty(cConteudo)) .Or. Empty(cChave)

	cDescri := "Não Encontrado"
	
Else

	//Se tiver campo
	If !Empty(cCampo)
	
		aCombo := RetSX3Box(GetSX3Cache(cCampo, "X3_CBOX"),,,1)
		
		//Percorre as posições do combo
		For nAtual := 1 To Len(aCombo)
			//Se for a mesma chave, seta a descrição
			If cChave == aCombo[nAtual][2]
				cDescri := aCombo[nAtual][3]
			EndIf
		Next
		
	//Se tiver conteúdo
	ElseIf !Empty(cConteudo)
	
		aCombo := StrTokArr(cConteudo, ';')
		
		//Percorre as posições do combo
		For nAtual := 1 To Len(aCombo)
			//Se for a mesma chave, seta a descrição
			If cChave == SubStr(aCombo[nAtual], 1, At('=', aCombo[nAtual])-1)
				cDescri := SubStr(aCombo[nAtual], At('=', aCombo[nAtual])+1, Len(aCombo[nAtual]))
			EndIf
		Next
		
	EndIf
	
EndIf

RestArea(aArea)

Return cDescri
