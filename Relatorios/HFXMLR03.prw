#include 'totvs.ch'
#include 'topconn.ch'
#include 'hfxmlr03.ch'
#Include "Protheus.Ch"
#Include "RwMake.Ch"
#Include "TbiConn.Ch"

/*/{Protheus.doc} HfXmlR01()
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
/*/

user function HFXMLR03()
    local oReport   := NIL
    local cPerg     := padr(STR0001,10)

    private cAlias  := GetNextAlias()

    dVencLic := Stod(Space(8))
    //lUsoOk := U_HFXML00X("HF000001","101",SM0->M0_CGC,@dVencLic)  
    lUsoOk	:= U_HFXMLLIC(.F.)

    If !lUsoOk
    	Return(Nil)
    EndIf

    ajustaSX1(cPerg)
    
    pergunte(cPerg,.f.)

    oReport := ReportDef(cAlias,cPerg)
    oReport:PrintDialog() 
    /*
    if Pergunte( cPerg , .T. )
        oReport:= ReportDef()        
        oReport:PrintDialog()
    endif
    */
return

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
static function ReportPrint(oReport,cAlias)
    local oSection1  := oReport:Section(1)

    oSection1:beginQuery()
    
    beginSql alias cAlias
        select 
            ZBS.ZBS_CNF,ZBS.ZBS_SERIE,ZBS.ZBS_MODELO,
            Case
            	When SA1.A1_COD Is Null Then SA2.A2_COD
            	Else SA1.A1_COD End
            As A2_COD,
            Case
            	When SA1.A1_LOJA Is Null Then SA2.A2_LOJA
            	Else SA1.A1_LOJA End
            As A2_LOJA,
            Case 
            	When SA1.A1_NOME Is Null Then SA2.A2_NOME
            	Else SA1.A1_NOME End
            As A2_NOME,
            ZBS.ZBS_DHRECB,ZBS.ZBS_DEMI,ZBS.ZBS_CHAVE,SF1.F1_DOC,
            SF1.F1_SERIE,SF1.F1_CHVNFE
        from
            %table:ZBS% ZBS
            left join %table:SA2% SA2 on ( ZBS.ZBS_CNPJEM = SA2.A2_CGC )
            left join %table:SA1% SA1 on ( ZBS.ZBS_CNPJEM = SA1.A1_CGC )
            left join %table:SF1% SF1 on ( /*ZBS.ZBS_CNF = SF1.F1_DOC and ZBS.ZBS_SERIE = SF1.F1_SERIE and */ZBS.ZBS_CHAVE = SF1.F1_CHVNFE and ZBS.ZBS_FILIAL = SF1.F1_FILIAL ) 
        where
            ZBS_FILIAL = %Exp:xFilial('ZBS')% and
            ZBS_DEMI between %Exp:mv_par01% and %Exp:mv_par02% and
            ZBS_SERIE >= %Exp:mv_par03% and ZBS_SERIE <= %Exp:mv_par04% and
            ZBS_CNF >= %Exp:mv_par05% and ZBS_CNF <= %Exp:mv_par06% and
            ZBS.%notdel% and
            ZBS_DEST = %Exp:SM0->M0_CGC% and
            /*SF1.F1_DOC is null and
            SF1.F1_SERIE is null and*/
            SF1.F1_CHVNFE is null
        order by ZBS.ZBS_CNF        
    endSql
    
    oSection1:endQuery()
    oReport:SetMeter((cAlias)->(recCount()))
    oSection1:Print()
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
static function reportdef(cAlias,cPerg)

    local cTitle    := STR0002
    local cHelp     := STR0003
    local oReport
    local oSection1

    oReport := treport():new(STR0004,cTitle,cPerg,{|oReport|ReportPrint(oReport,cAlias)},cHelp)
    oReport:SetLandScape()

    oSection1    := TRSection():new(oReport,STR0005,{'ZBS'})  

    TRCell():New(oSection1, 'ZBS_CNF'   , 'ZBS' ,   STR0005 ,   PesqPict('SF1','F1_DOC')    ,   TamSX3('F1_DOC')[1]+1       ,   /*lPixel*/  ,   /*{|| code-block de impressao }*/)
    TRCell():New(oSection1, 'ZBS_SERIE' , 'ZBS' ,   STR0006 ,   PesqPict('SF1','F1_SERIE')  ,   TamSX3('F1_SERIE')[1]+1     ,   /*lPixel*/  ,   /*{|| code-block de impressao }*/)
    TRCell():New(oSection1, 'ZBS_MODELO', 'ZBS' ,   STR0007 ,   PesqPict('ZBS','ZBS_MODELO'),   TamSX3('ZBS_MODELO')[1]+1   ,   /*lPixel*/  ,   /*{|| code-block de impressao }*/)
    TRCell():New(oSection1, 'A2_COD'    , 'SA2' ,   STR0008 ,   PesqPict('SA2','A2_COD')    ,   TamSX3('A2_COD')[1]+1       ,   /*lPixel*/  ,   /*{|| code-block de impressao }*/)
    TRCell():New(oSection1, 'A2_LOJA'   , 'SA2' ,   STR0009 ,   PesqPict('SA2','A2_LOJA')   ,   TamSX3('A2_LOJA')[1]+1      ,   /*lPixel*/  ,   /*{|| code-block de impressao }*/)
    TRCell():New(oSection1, 'A2_NOME'   , 'SA2' ,   STR0010 ,   PesqPict('SA2','A2_NOME')   ,   TamSX3('A2_NOME')[1]+1      ,   /*lPixel*/  ,   /*{|| code-block de impressao }*/)
    TRCell():New(oSection1, 'ZBS_DHRECB', 'ZBS' ,   STR0011 ,   PesqPict('SF1','F1_EMISSAO'),   TamSX3('F1_EMISSAO')[1]+1   ,   /*lPixel*/  ,   /*{|| code-block de impressao }*/)
    TRCell():New(oSection1, 'ZBS_DEMI'  , 'ZBS' ,   STR0012 ,   PesqPict('SF1','F1_EMISSAO'),   TamSX3('F1_EMISSAO')[1]+1   ,   /*lPixel*/  ,   /*{|| code-block de impressao }*/)
    TRCell():New(oSection1, 'ZBS_CHAVE' , 'ZBS' ,   STR0013 ,   PesqPict('SF1','F1_CHVNFE') ,   TamSX3('F1_CHVNFE')[1]+1    ,   /*lPixel*/  ,   /*{|| code-block de impressao }*/)
return(oReport)  

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
static function ajustaSX1(cPerg)
    local aHelpPor  := {}
    local nTamFil   := FwGetTamFilial
    
    aHelpPor := {}
    aadd( aHelpPor, STR0016 )
    HFPutSx1(cPerg,'01',STR0014,STR0014,STR0014,"mv_ch1","D",08,0,0,"G","",   "","","","mv_par01","","","","","","","","","","","","","","","","",aHelpPor,aHelpPor,aHelpPor)

    aHelpPor := {}
    aadd( aHelpPor, STR0017 )
    HFPutSx1(cPerg,'02',STR0015,STR0015,STR0015,"mv_ch2","D",08,0,0,"G","",   "","","","mv_par02","","","","","","","","","","","","","","","","",aHelpPor,aHelpPor,aHelpPor)

    aHelpPor := {}
    aadd( aHelpPor, STR0020 )
    HFPutSx1(cPerg,'03',STR0022,STR0022,STR0022,"mv_ch3","C",03,0,0,"G","",   "","","","mv_par03","","","","","","","","","","","","","","","","",aHelpPor,aHelpPor,aHelpPor)

    aHelpPor := {}
    aadd( aHelpPor, STR0021 )
    HFPutSx1(cPerg,'04',STR0023,STR0023,STR0023,"mv_ch4","C",03,0,0,"G","",   "","","","mv_par04","","","","","","","","","","","","","","","","",aHelpPor,aHelpPor,aHelpPor)

    aHelpPor := {}
    aadd( aHelpPor, STR0018 )
    HFPutSx1(cPerg,'05',STR0024,STR0024,STR0024,"mv_ch5","C",09,0,0,"G","",   "","","","mv_par05","","","","","","","","","","","","","","","","",aHelpPor,aHelpPor,aHelpPor)

    aHelpPor := {}
    aadd( aHelpPor, STR0019 )
    HFPutSx1(cPerg,'06',STR0025,STR0025,STR0025,"mv_ch6","C",09,0,0,"G","",   "","","","mv_par06","","","","","","","","","","","","","","","","",aHelpPor,aHelpPor,aHelpPor)
return 

Static Function HFPutSx1(cGrupo,cOrdem,cPergunt,cPerSpa,cPerEng,cVar,;
	cTipo ,nTamanho,nDecimal,nPresel,cGSC,cValid,;
	cF3, cGrpSxg,cPyme,;
	cVar01,cDef01,cDefSpa1,cDefEng1,cCnt01,;
	cDef02,cDefSpa2,cDefEng2,;
	cDef03,cDefSpa3,cDefEng3,;
	cDef04,cDefSpa4,cDefEng4,;
	cDef05,cDefSpa5,cDefEng5,;
	aHelpPor,aHelpEng,aHelpSpa,cHelp)

    LOCAL aArea := GetArea()
    Local cKey
    Local lPort := .f.
    Local lSpa  := .f.
    Local lIngl := .f. 

	cKey  := "P." + AllTrim( cGrupo ) + AllTrim( cOrdem ) + "."
	
	cPyme    := Iif( cPyme 		== Nil, " ", cPyme		)
	cF3      := Iif( cF3 		== NIl, " ", cF3		)
	cGrpSxg  := Iif( cGrpSxg	== Nil, " ", cGrpSxg	)
	cCnt01   := Iif( cCnt01		== Nil, "" , cCnt01 	)
	cHelp	 := Iif( cHelp		== Nil, "" , cHelp		)
	
	dbSelectArea( "SX1" )
	dbSetOrder( 1 )
	
	// Ajusta o tamanho do grupo. Ajuste emergencial para validação dos fontes.
	// RFC - 15/03/2007
	cGrupo := PadR( cGrupo , Len( SX1->X1_GRUPO ) , " " )
	
	If !( DbSeek( cGrupo + cOrdem ))
	
	    cPergunt:= If(! "?" $ cPergunt .And. ! Empty(cPergunt),Alltrim(cPergunt)+" ?",cPergunt)
		cPerSpa	:= If(! "?" $ cPerSpa  .And. ! Empty(cPerSpa) ,Alltrim(cPerSpa) +" ?",cPerSpa)
		cPerEng	:= If(! "?" $ cPerEng  .And. ! Empty(cPerEng) ,Alltrim(cPerEng) +" ?",cPerEng)
	
		Reclock( "SX1" , .T. )
	
		Replace X1_GRUPO   With cGrupo
		Replace X1_ORDEM   With cOrdem
		Replace X1_PERGUNT With cPergunt
		Replace X1_PERSPA  With cPerSpa
		Replace X1_PERENG  With cPerEng
		Replace X1_VARIAVL With cVar
		Replace X1_TIPO    With cTipo
		Replace X1_TAMANHO With nTamanho
		Replace X1_DECIMAL With nDecimal
		Replace X1_PRESEL  With nPresel
		Replace X1_GSC     With cGSC
		Replace X1_VALID   With cValid
	
		Replace X1_VAR01   With cVar01
	
		Replace X1_F3      With cF3
		Replace X1_GRPSXG  With cGrpSxg
	
		If Fieldpos("X1_PYME") > 0
			If cPyme != Nil
				Replace X1_PYME With cPyme
			Endif
		Endif
	
		Replace X1_CNT01   With cCnt01
		If cGSC == "C"			// Mult Escolha
			Replace X1_DEF01   With cDef01
			Replace X1_DEFSPA1 With cDefSpa1
			Replace X1_DEFENG1 With cDefEng1
	
			Replace X1_DEF02   With cDef02
			Replace X1_DEFSPA2 With cDefSpa2
			Replace X1_DEFENG2 With cDefEng2
	
			Replace X1_DEF03   With cDef03
			Replace X1_DEFSPA3 With cDefSpa3
			Replace X1_DEFENG3 With cDefEng3
	
			Replace X1_DEF04   With cDef04
			Replace X1_DEFSPA4 With cDefSpa4
			Replace X1_DEFENG4 With cDefEng4
	
			Replace X1_DEF05   With cDef05
			Replace X1_DEFSPA5 With cDefSpa5
			Replace X1_DEFENG5 With cDefEng5
		Endif
	
		Replace X1_HELP  With cHelp
	
		PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)
	
		MsUnlock()
	Else
	
	   lPort := ! "?" $ X1_PERGUNT .And. ! Empty(SX1->X1_PERGUNT)
	   lSpa  := ! "?" $ X1_PERSPA  .And. ! Empty(SX1->X1_PERSPA)
	   lIngl := ! "?" $ X1_PERENG  .And. ! Empty(SX1->X1_PERENG)
	
	   If lPort .Or. lSpa .Or. lIngl
			RecLock("SX1",.F.)
			If lPort 
	         SX1->X1_PERGUNT:= Alltrim(SX1->X1_PERGUNT)+" ?"
			EndIf
			If lSpa 
				SX1->X1_PERSPA := Alltrim(SX1->X1_PERSPA) +" ?"
			EndIf
			If lIngl
				SX1->X1_PERENG := Alltrim(SX1->X1_PERENG) +" ?"
			EndIf
			SX1->(MsUnLock())
		EndIf
	Endif
	
	RestArea( aArea )

Return
