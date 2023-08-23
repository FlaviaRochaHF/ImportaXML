#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"                                                                                                                           
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "Ap5Mail.ch"
#INCLUDE "FILEIO.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH" 
#INCLUDE "XMLXFUN.CH" 
#INCLUDE 'APWEBSRV.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE "PRTOPDEF.CH"
#INCLUDE "HTTPCLASS.CH"

Static lInitSped := .F.
Static lUnix  := IsSrvUnix()
Static cBarra := Iif(lUnix,"/","\")

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ HFXML061 ³ Autor ³ Eneovaldo Roveri Jr   ³ Data ³15/09/2018³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Controle de XMLs com Problema de Download do SEFAZ         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
//FR - 16/10/2020 - Solicitações Rafael, tratativa para redownload:
//                  Criação de campos novos: 
//                  ZBZ_DREDOW: Dt último redownload
//                  ZBZ_HREDOW: Hr.último redownload
//					Tratativa para legenda indicando 
//                  data/hora do próx download
//--------------------------------------------------------------------------//
/*/
//----------------------------------------------------------------------------//
//Alterações realizadas:
//----------------------------------------------------------------------------//
//FR - 05/05/2021 - #10382 - Kroma - tratativa para chamada dentro do Schedule
//----------------------------------------------------------------------------//    
//FR - 07/06/2021 - Rollback das alterações da Kroma
//----------------------------------------------------------------------------//   
User Function HFXML061()

Local aArea := GetArea()
Local cEmp0 := cEmpAnt
Local cFil0 := cFilAnt
Local nReg0 := SM0->( recno() )
Local cCnpj := ""
Local lTem  := .T.
Local oProcess	:=	Nil
Local cCloud		:=	alltrim(GetNewPar("XM_CLOUD" ,"0"))         //aCombo (0=Desbilitado 1=Habilitado) 

Private cTmp_137 := "TMPZBS", cAli_137, oTmp_137

If cCloud == "1"
	msgAlert("Função desabilitada para NF-e devido estar habilitado integração cloud, nesse caso utilize o botão baixar xml")
	Return
EndIf	

SM0->( dbSetOrder(1) )
If SM0->( dbSeek( cEmp0 + cFil0 ) )

	cCnpj := SM0->M0_CGC
	
Else

	SM0->( dbGoTo( nReg0 ) )
	cCnpj := SM0->M0_CGC
	
Endif

/*ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Valida se pode continuar com a requisição ao SEFAZ        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±*/
U_HFXML072(cCnpj)
If !lConsCnpj
	lRet := .F.
		Return(lRet)
EndIf
CriaTMP()

cAli_137 := oTmp_137:GetAlias()

oProcess := MsNewProcess():New({| lEnd | lTem := Popula( @lEnd, oProcess, .T., "99")},"Aguarde. Verificando XMLs...","Verificando XMLs",.T.)
 
	oProcess:Activate()

	if ! lTem
	
	   U_MyAviso("Atenção","Não Existe Registros com Problema de Download."+CRLF+;
		"",{"OK"},1)
		
	Endif

	//MarkBrowse
	HFXML61Brw()
	oTmp_137:Delete()
	

RestArea(aArea)


Return( NIL )



USer Function HFTTJ2()  //U_HFTTJ2()

Local lAuto := .T.
Local lEnd  := .F.
Local cLogProc := ""
Local nCount := 0
Local oProcess
Local cCloud	  := GetNewPar("XM_CLOUD" ,"0")         //aCombo (0=Desbilitado 1=Habilitado)

Private xZBZ  	  := GetNewPar("XM_TABXML","ZBZ")      //ECOOOOOOOOOO
Private xZB5  	  := GetNewPar("XM_TABAMAR","ZB5")
Private xZBS  	  := GetNewPar("XM_TABSINC","ZBS")
Private xZBE      := GetNewPar("XM_TABEVEN","ZBE")
Private xZBZ_ 	  := iif(Substr(xZBZ,1,1)=="S", Substr(xZBZ,2,2), Substr(xZBZ,1,3)) + "_"
Private xZB5_ 	  := iif(Substr(xZB5,1,1)=="S", Substr(xZB5,2,2), Substr(xZB5,1,3)) + "_"
Private xZBS_ 	  := iif(Substr(xZBS,1,1)=="S", Substr(xZBS,2,2), Substr(xZBS,1,3)) + "_"
Private xZBE_     := iif(Substr(xZBE,1,1)=="S", Substr(xZBE,2,2), Substr(xZBE,1,3)) + "_"
Private xZBC      := GetNewPar("XM_TABCAC","ZBC")
Private xZBC_     := iif(Substr(xZBC,1,1)=="S", Substr(xZBC,2,2), Substr(xZBC,1,3)) + "_"
Private xZBO      := GetNewPar("XM_TABOCOR","ZBO"), xRetSEF := ""
Private xZBO_     := iif(Substr(xZBO,1,1)=="S", Substr(xZBO,2,2), Substr(xZBO,1,3)) + "_"
Private xZBI      := GetNewPar("XM_TABIEXT","ZBI")
Private xZBI_     := iif(Substr(xZBI,1,1)=="S", Substr(xZBI,2,2), Substr(xZBI,1,3)) + "_"
Private xZBA  	  := GetNewPar("XM_TABAMA2","ZBA")
Private xZBA_ 	  := iif(Substr(xZBA,1,1)=="S", Substr(xZBA,2,2), Substr(xZBA,1,3)) + "_"
Private x_Ped_Rec := GetNewPar("XM_PEDREC","N")
Private x_ZBB     := GetNewPar("XM_TABREC","")
Private aHfCloud  := {"0","0"," ","Token",{}}  //CRAUMDE - '0' Não integrar, na posição 1
Private x_Tip_Pre := GetNewPar("XM_TIP_PRE","1")
Private nFormNfe  := Val(GetNewPar("XM_FORMNFE","6")) 
Private nFormCte  := Val(GetNewPar("XM_FORMCTE","6"))
Private cFilUsu   := GetNewPar("XM_FIL_USU","N")
Private cTpRt  	  := "J"


if cCloud <> "1"

	cIdEnt := U_GetIdEnt()

else

	cIdEnt := ""
	
endif

//IF ExistBlock( "HFCLDINI" )

//	aHfCloud := U_HFCLDINI(.F.,@cLogProc)
	
//EndIF

U_HFXML61J(lAuto,@lEnd,oProcess,@cLogProc,@nCount,.F.)

Alert( "Foi" )

Alert( nCount )

Alert( cLogProc )

Return()

//+-----------------------------------------------------------------------------------//
//|Funcao....: HFXML61J
//|Autoria...: Heverton Marcondes
//|Descricao.: Checa SM0 antes de chamar funções principais
//|Observação: 
//+-----------------------------------------------------------------------------------//
User Function HFXML61J(lAuto,lEnd,oProcess,cLogProc,nCount,lMostra)

Local aArea := GetArea()
Local cEmp0 := cEmpAnt
Local cFil0 := cFilAnt
Local nReg0 := SM0->( recno() )
Local cCnpj := ""
Local lTem  := .T.

Default oProcess	:=	Nil

Private cMarcaOK := GetMark()
Private cTmp_137 := "TMPZBS", cAli_137, oTmp_137


SM0->( dbSetOrder(1) )
If SM0->( dbSeek( cEmp0 + cFil0 ) )

	cCnpj := SM0->M0_CGC
	
Else

	SM0->( dbGoTo( nReg0 ) )
	cCnpj := SM0->M0_CGC
	
Endif

/*ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Valida se pode continuar com a requisição ao SEFAZ        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±*/
U_HFXML072(cCnpj)
If !lConsCnpj
	lRet := .F.
		Return(lRet)
EndIf
CriaTMP()

cAli_137 := oTmp_137:GetAlias()

lTem := Popula( @lEnd, oProcess, lMostra, "99", cMarcaOK )  //"Aguarde. Verificando XMLs...","Verificando XMLs",.T.)

if ! lTem

   cLogProc += "Não Existe Registros com Problema de Download."+CRLF
   
Else

	HFXML61Dow(NIL,@lEnd,oProcess,cMarcaOK,lMostra,@cLogProc)  //Tenta Fazer os Downloads

Endif

oTmp_137:Delete()

RestArea(aArea)

Return( NIL )


Static Function CriaTMP()

Local aStru := {}
Local aInd  := {}
Local nTamCod   := TAMSXG("001")[1]
Local nTamLoja  := TAMSXG("002")[1]

aadd( aStru, { "OK"      ,"C",02,0 } )
aadd( aStru, { "ST"      ,"C",02,0 } )
aadd( aStru, { "CHAVE"   ,"C",44,0 } )
aadd( aStru, { "AMB"     ,"C",01,0 } )
aadd( aStru, { "MSG"     ,"C",30,0 } )
aadd( aStru, { "ERRO"    ,"M",10,0 } )
aadd( aStru, { "CNF"     ,"C",09,0 } )
aadd( aStru, { "SERIE"   ,"C",03,0 } )
aadd( aStru, { "DREDOW"  ,"D",08,0 } )		//FR 16/10/2020
aadd( aStru, { "HREDOW"  ,"C",05,0 } )		//FR 16/10/2020
aadd( aStru, { "PROXRED" ,"C",25,0 } )	 	//FR 16/10/2020	//proxima data/hora disponível para redownload
aadd( aStru, { "DEST"    ,"C",14,0 } )
//dados do xml para consulta
aadd( aStru, { "CNPJ_EMI","C",14,0 } )
aadd( aStru, { "CODFOR"  ,"C",nTamCod ,0 } )
aadd( aStru, { "LOJFOR"  ,"C",nTamLoja,0 } )
aadd( aStru, { "DEMI"    ,"C",10,0 } )
aadd( aStru, { "VNF"     ,"N",15,2 } )
aadd( aStru, { "XNOME"   ,"C",60,0 } )
aadd( aStru, { "IE"      ,"C",14,0 } )
aadd( aStru, { "DIGVAL"  ,"C",28,0 } )
aadd( aStru, { "DHRECBTO","C",10,0 } )
aadd( aStru, { "CSITNFE" ,"C",01,0 } )
aadd( aStru, { "CSITCONF","C",01,0 } )
aadd( aStru, { "NSU"     ,"C",15,0 } )
aadd( aStru, { "Correcao","M",10,0 } )
aadd( aStru, { "IDENT"   ,"C",14,0 } )
aadd( aStru, { "XML"     ,"M",10,0 } )
aadd( aStru, { "XMLCANC" ,"M",10,0 } )
aadd( aStru, { "TOMA" 	 ,"C",14,0 } )

oTmp_137 := FWTemporaryTable():New( cTmp_137, aStru ) //-> Objeto FWTemporaryTable 
	
	aInd := {}
	aadd( aInd, "CHAVE" )
	
oTmp_137:AddIndex( cTmp_137+"01", aInd )

	aInd := {}
	aadd( aInd, "SERIE" )
	aadd( aInd, "CNF" )
	
oTmp_137:AddIndex( cTmp_137+"02", aInd )

	aInd := {}
	aadd( aInd, "DHRECBTO" )
	
oTmp_137:AddIndex( cTmp_137+"03", aInd )

	aInd := {}
	aadd( aInd, "OK" )
	aadd( aInd, "CHAVE" )
	
oTmp_137:AddIndex( cTmp_137+"04", aInd )

oTmp_137:Create()

Return()


Static Function Popula( lEnd, oRegua, lMostra, cSt, cMarcaOK )

Local lRet      := .F.
Local aArea     := GetArea()
Local cAliasZBS := GetNextAlias()
Local cCodFor   := Space( 6 )
Local cLojFor   := Space( 2 )
Local cFilSek   := ""
Local lSharedA1 := U_IsShared("SA1")
Local lSharedA2 := U_IsShared("SA2")
Local cChaveXml := ""

Private xZBS  	  := GetNewPar("XM_TABSINC","ZBS")
Private xZBS_ 	  := iif(Substr(xZBS,1,1)=="S", Substr(xZBS,2,2), Substr(xZBS,1,3)) + "_"
Private xZBZ  	  := GetNewPar("XM_TABXML","ZBZ")
Private xZBZ_ 	  := iif(Substr(xZBZ,1,1)=="S", Substr(xZBZ,2,2), Substr(xZBZ,1,3)) + "_"
Default cMarcaOK := ""

cQuery := ""
cQuery += " Select ZBS.R_E_C_N_O_ as REG, "
cQuery += " "+xZBS_+"CHAVE  as CHAVE, "
cQuery += " "+xZBS_+"ST     as ST  "
cQuery += " FROM "+RetSqlName(xZBS)+" ZBS "
cQuery += " Where ZBS.D_E_L_E_T_ <> '*' "
cQuery += " And "+xZBS_+"FILIAL = '"+xFilial( xZBS )+"' "
cQuery += " And "+xZBS_+"ST IN ('"+cSt+"') "

MemoWrite("C:\TEMP\DOWN137.SQL", cQuery)

If Select(cAliasZBS) > 0
	dbSelectArea(cAliasZBS)
	(cAliasZBS)->(dbCloseArea())
EndIf
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasZBS)

DbSelectARea( cAliasZBS )
(cAliasZBS)->( dbGoTop() )
If !(cAliasZBS)->(Eof())
	While !(cAliasZBS)->( Eof() )

		cChaveXml := (cAliasZBS)->CHAVE
        dRedow    := Ctod("  /  /    ")  	//FR - 16/10/2020
        hRedow    := ""                		//FR - 16/10/2020

		If lMostra
		
			If lEnd
			
				MsgStop("*** Cancelado pelo Operador ***","Fim")
				Exit
				
			EndIf 
			
			oRegua:IncRegua1("Procurando por XMLs não disponibilizados pelo SEFAZ ...")
			oRegua:IncRegua2( cChaveXml )
			
		EndIf

		lRet := .T.

		DbSelectARea( xZBS )
		DbGoTo( (cAliasZBS)->REG )

		cCodFor   := Space( 6 )
		cLojFor   := Space( 2 )
		
		If empty(cCodFor)
		
			cFilSek   := iif(lSharedA2, xFilial( "SA2" ), ( xZBS )->( FieldGet( FieldPos( xZBS_+"FILIAL" ) ) ) )
			DbSelectArea("SA2")
			DbSetOrder(3)
			
			If DbSeek(cFilSek+( xZBS )->( FieldGet( FieldPos( xZBS_+"CNPJEM" ) ) )) 
			
				cCodFor := SA2->A2_COD
				cLojFor := SA2->A2_LOJA 
				
				Do While .not. SA2->( eof() ) .and. SA2->A2_FILIAL == cFilSek .and.;
									SA2->A2_CGC == ( xZBS )->( FieldGet( FieldPos( xZBS_+"CNPJEM" ) ) )
					
					If SA2->A2_MSBLQL != "1"
					
						cCodFor := SA2->A2_COD
						cLojFor := SA2->A2_LOJA 
						
						Exit
						
					Endif
					
					SA2->( dbSkip() )
					
				EndDo
				
			EndIf
			
		EndIF
		
		If empty(cCodFor)
		
			cFilSek   := iif(lSharedA1, xFilial( "SA1" ), ( xZBS )->( FieldGet( FieldPos( xZBS_+"FILIAL" ) ) ) )
			
			DbSelectArea("SA1")
			DbSetOrder(3)
			If DbSeek(cFilSek+( xZBS )->( FieldGet( FieldPos( xZBS_+"CNPJEM" ) ) )) 
			
				cCodFor := SA1->A1_COD
				cLojFor := SA1->A1_LOJA 
				
				Do While .not. SA1->( eof() ) .and. SA1->A1_FILIAL == cFilSek .and.;
									SA1->A1_CGC == ( xZBS )->( FieldGet( FieldPos( xZBS_+"CNPJEM" ) ) )
					
					If SA1->A1_MSBLQL != "1"
					
						cCodFor := SA1->A1_COD
						cLojFor := SA1->A1_LOJA 
						
						exit
												
					Endif
					
					SA1->( dbSkip() )
					
				EndDo
				
			EndIf
			
		EndIF
		
		(xZBZ)->(OrdSetFocus(3))
		(xZBZ)->( dbSeek( (cAliasZBS)->CHAVE ) ) 
		dRedow := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"DREDOW"))) 
	   	hRedow := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"HREDOW"))) 

		DbSelectArea( cAli_137 )
		
		RecLock( cAli_137, .T. )
		
		(cAli_137)->ST    := ( xZBS )->( FieldGet( FieldPos( xZBS_+"ST" ) ) )
		(cAli_137)->CHAVE := cChaveXml
		(cAli_137)->AMB   := ( xZBS )->( FieldGet( FieldPos( xZBS_+"AMB" ) ) )
		(cAli_137)->DEST  := ( xZBS )->( FieldGet( FieldPos( xZBS_+"DEST" ) ) )
		(cAli_137)->CNF      := ( xZBS )->( FieldGet( FieldPos(xZBS_+"CNF") ) )
		(cAli_137)->SERIE    := ( xZBS )->( FieldGet( FieldPos(xZBS_+"SERIE") ) )
		(cAli_137)->CNPJ_EMI := ( xZBS )->( FieldGet( FieldPos( xZBS_+"CNPJEM" ) ) )
		(cAli_137)->CODFOR   := cCodFor
		(cAli_137)->LOJFOR   := cLojFor
		(cAli_137)->DEMI     := DTOC( ( xZBS )->( FieldGet( FieldPos( xZBS_+"DEMI" ) ) ) )
		(cAli_137)->VNF      := ( xZBS )->( FieldGet( FieldPos( xZBS_+"VNF" ) ) )
		(cAli_137)->XNOME    := ( xZBS )->( FieldGet( FieldPos( xZBS_+"XNOME" ) ) )
		(cAli_137)->IE       := ( xZBS )->( FieldGet( FieldPos( xZBS_+"IE" ) ) )
		(cAli_137)->DIGVAL   := ( xZBS )->( FieldGet( FieldPos( xZBS_+"DIGVAL" ) ) )
		(cAli_137)->DHRECBTO := DTOC( ( xZBS )->( FieldGet( FieldPos( xZBS_+"DHRECB" ) ) ) )
		(cAli_137)->CSITNFE  := ( xZBS )->( FieldGet( FieldPos( xZBS_+"CSITNF" ) ) )
		(cAli_137)->CSITCONF := ( xZBS )->( FieldGet( FieldPos( xZBS_+"CSITCO" ) ) )
		(cAli_137)->NSU      := ( xZBS )->( FieldGet( FieldPos( xZBS_+"NSU" ) ) )
		(cAli_137)->TOMA	  := ( xZBS )->( FieldGet( FieldPos(xZBS_+"TOMA" ) ) )
		
		If ! Empty(cMarcaOK)  //Para o JOB		
			(cAli_137)->OK	:= If((cAli_137)->ST == "10", "  ", cMarcaOK ) 
		Endif
		
		(cAli_137)->DREDOW  := dRedow		//FR - 16/10/2020
		(cAli_137)->HREDOW  := hRedow		//FR - 16/10/2020
		
		(cAli_137)->( MsUnLock() )

		DbSelectARea( cAliasZBS )
		(cAliasZBS)->( dbSkip() )

	EndDo
Endif
(cAliasZBS)->( dbCloseArea() )

RestArea( aArea )

Return( lRet )




/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³HFXML06Brw³ Autor ³ Raul Rock Seixas      ³ Data ³15/09/2018³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ MarkBrowse das Chaves 137                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function HFXML61Brw()

Local aButtons	:= {}
Local aGetArea	:= GetArea()
Local aInfo		:= {}
Local aPosObj	:= {}
Local aObjects	:= {}
Local aSize		:= MsAdvSize()  			// Define e utilização de janela padrão Microsiga
Local cGetLOk  	:= "AllwaysTrue"	   		// Funcao executada para validar o contexto da linha atual do aCols
Local cGetTOk  	:= "AllwaysTrue"    		// Funcao executada para validar o contexto geral da MsNewGetDados
Local oFolder	:= Nil
Local oDlg01	:= Nil
Local oMarkBw	:= Nil
Local lInverte	:= .F.
Local lOk		:= .F.
Local cChvAtu	:= " "
Local cChvAnt	:= " "
Local oFont		:= Nil
Local aCpos     := {}
Local aCores    := {}
Local oProgress := NIL

Private cMarcaOK := GetMark()
Private cFiltro  := "NN"

aCpos := {}
aadd( aCpos, {"OK"   ,,"" } )
//aadd( aCpos, {"ST"   ,,"ST","@!" } )
aadd( aCpos, {"CHAVE"	,,"CHAVE","@!" 	   					} )
aadd( aCpos, {"ERRO" 	,,"RESP SEFAZ","@!" 				} )
aadd( aCpos, {"CNPJ_EMI",,"EMITENTE","@!" 					} )
aadd( aCpos, {"CODFOR"  ,,"FORNEC","@!" 					} )
aadd( aCpos, {"LOJFOR"  ,,"LOJA","@!" 	   					} )
aadd( aCpos, {"NSU"     ,,"NSU","@!" 	   					} )
aadd( aCpos, {"DEMI"    ,,"DT EMISSAO","@!" 				} )
aadd( aCpos, {"CNF"     ,,"NOTA FISCAL","@!" 				} )
aadd( aCpos, {"SERIE"   ,,"SERIE","@!" 						} )
aadd( aCpos, {"VNF"     ,,"VALOR","@Z 999,999,999,999.99" 	} )
aadd( aCpos, {"XNOME"   ,,"EMITENTE","@!" 					} )
aadd( aCpos, {"IE"      ,,"IE EMIT","@!" 					} )
aadd( aCpos, {"DIGVAL"  ,,"DIGEST VAL","@!" 				} )
aadd( aCpos, {"DHRECBTO",,"DT AUTORIZ","@!" 				} )
aadd( aCpos, {"CSITNFE" ,,"SIT NFE","@!" 					} )
aadd( aCpos, {"CSITCONF",,"MANIFESTO","@!" 					} )
aadd( aCpos, {"Correcao",,"CARTA DE CORRECAO","@!" 			} )
aadd( aCpos, {"MSG"  	,,"MENSAGEM","@!" 					} )

aadd( aCpos, {"DREDOW" 	,,"Dt.Ult.Redownload"		,"@!" 	} )		//FR 16/10/2020
aadd( aCpos, {"HREDOW" 	,,"Hr.Ult.Redownload"		,"@!" 	} )		//FR 16/10/2020
aadd( aCpos, {"PROXRED" ,,"Prox.Redown Disponível" 	,"@!"	} )		//FR 16/10/2020

aadd( aCpos, {"XML"     ,,"XML","@!" 						} )
aadd( aCpos, {"XMLCANC" ,,"XML Cancel","@!" 				} )
aadd( aCpos, {"TOMA"	,,"TOMADOR CNPJ","@!" 				} )

aCores := {}
aAdd(aCores,{cAli_137+"->ST == '10'","BR_VERDE"				})
aAdd(aCores,{cAli_137+"->ST == '  '","BR_AMARELO"			})
aAdd(aCores,{cAli_137+"->ST == '90'","BR_AZUL" 				})
aAdd(aCores,{cAli_137+"->ST == '99'","BR_VERMELHO" 			})
aAdd(aCores,{cAli_137+"->ST == '98'","BR_MARROM" 			})
aAdd(aCores,{cAli_137+"->ST == '97'","BR_PRETO" 			})
aAdd(aCores,{cAli_137+"->ST == 'A'" ,"BR_LARANJA" 			})  	//FR 16/10/2020

dbSelectArea(cAli_137)
//COUNT TO nQtdReg
(cAli_137)->( dbGotop() )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apresenta botao se nao for visualizacao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aButtons,{'CHECKED' ,{ || HFXML06Inv(cMarcaOK,@oMarkBw) }, "Inverter Marcação", "Inverter"})
aAdd(aButtons,{'DESTINOS',{ || HFXML06Inv(cMarcaOK,@oMarkBw,.T.) }, "Marcar todos os títulos", "Marc Todos"})
aAdd(aButtons,{          ,{ || HFXML06Leg() }, "Legenda", "Legenda"})
aAdd(aButtons,{          ,{ || HFXML06Vis() }, "Visualizar Registro", "Visualizar"		 })
aAdd(aButtons,{          ,{ || HFXML06Exc() }, "Excluir da Analise", "Excluir da Analise"})
aAdd(aButtons,{          ,{ || HFXML61Imp() }, "Imprimir", "Imprimir"})
//aAdd(aButtons,{          ,{ || HFXML06Pes(oMarkBw, "TMP") }, "Pesquisar Registro", "Pesquisar"})
//aAdd(aButtons,{          ,{ || HFXML06Fil(oMarkBw, "TMP") }, "Filtrar Registro", "Filtrar"})

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
DEFINE MSDIALOG oDlg01 TITLE "Download XML Indisponibilizado pela Sefaz (137)" FROM 000,000 TO 430,800 OF oMainWnd PIXEL 

oDlg01:lMaximized := .F.

//@ -15,270 Button "ZOCA" Size 010,011 PIXEL OF oMainWnd ACTION (cJobs:=U_GetJob(cJobs)) 
//@ -15,-15 BUTTON oBtn PROMPT "ZOCA" SIZE 10,50 PIXEL OF oDlg01

//DEFINE FONT oFont NAME "Arial" SIZE 10,12 BOLD

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao do objeto Folder ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//oFolder	:= TFolder():New(10,2,{"Chaves"},{},oDlg01,,,,.T.,.F.,aPosObj[1][4],aPosObj[2][3],)  //-aPosObj[2][1]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria o objeto Mark para a selecao dos podrutos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oMarkBw:=MsSelect():New(cAli_137,"OK","",aCpos,@lInverte,@cMarcaOK,{17,10,150,400},,,,,aCores) //oFolder:aDialogs[1]

oMarkBw:oBrowse:Refresh()
oMarkBw:oBrowse:lhasMark    := .T.
oMarkBw:oBrowse:lCanAllmark := .T.
oMarkBw:oBrowse:Align       := CONTROL_ALIGN_ALLCLIENT	//Usado no modelo FLAT


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Permite selecao se não for visualizacao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oMarkBw:oBrowse:bAllMark    := { || HFXML06Inv(cMarcaOK,@oMarkBw) }
oMarkBw:oBrowse:bChange     := { || HFXML06Chg(@oMarkBw) }
oMarkBw:BMark               := { || HFXML06Dis(@oMarkBw,cMarcaOK) }

ACTIVATE MSDIALOG oDlg01 CENTERED  ON INIT EnchoiceBar(oDlg01,;
{|lEnd| oProcess := MsNewProcess():New({|lEnd| HFXML61Dow(@oMarkBw,@lEnd,@oProcess,cMarcaOK,.T.,"")}, "Baixar...","Baixando XML ..."),oProcess:Activate() },;
{|| iif( msgYesNo("Sair Download XML ?","Pegunta"),oDlg01:End(),lOk := .F. )},,aButtons)

Return( .T. )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³HFXML06Inv³ Autor ³ Eneo                  ³ Data ³23/11/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Locacao   ³ Parceiros        ³Contato ³ adilson.gomes@advbrasil.com.br ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Esta rotina ira marcar ou desmarcar as chaves.             ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Bops ³ Manutencao Efetuada                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function HFXML06Inv(cMarcaOK,oMarkBw,lMarkAll)

Local aGetArea	:= GetArea()
Local lMarcSim	:= .F.

If lMarkAll
	
	lMarcSim := Aviso( "Marcar/Desmarcar todos", "Deseja marcar ou desmarcar todos os títulos?", { "Marcar", "Desmarcar" } ) == 1

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ While para marcar ou desmarcar os produtos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
(cAli_137)->( dbGotop() )
Do while (cAli_137)->( !EOF() )

	If lMarkAll
	
		RecLock(cAli_137, .F.)
		(cAli_137)->OK	:= if((cAli_137)->ST == "10", "  ", If(lMarcSim, cMarcaOK, "  ") )
		(cAli_137)->( MsUnLock() )
		
	Else
	
		If  (cAli_137)->OK == cMarcaOK
		
			RecLock(cAli_137, .F.)
			
			(cAli_137)->OK	:= "  "
			(cAli_137)->( MsUnLock() )
			
		Else
		
			RecLock(cAli_137, .F.)
			
			(cAli_137)->OK	:= if((cAli_137)->ST == "10", "  ", cMarcaOK )
			(cAli_137)->( MsUnLock() )
			
		EndIf
		
	EndIf

	(cAli_137)->( dbSkip() )
	
EndDo

oMarkBw:oBrowse:Refresh(.T.)

RestArea( aGetArea )

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³HFXML06Dis³ Autor ³ Eneovaldo Roveri Jr   ³ Data ³19/01/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Locacao   ³ Parceiros        ³Contato ³                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Rotina para execucao do filtro na tabela temporaria        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Bops ³ Manutencao Efetuada                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function HFXML06Dis(oMarkBw, cMarcaOK)

Local aGetArea := GetArea()

oMarkBw:oBrowse:Refresh(.T.)

RestArea( aGetArea )

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³HFXML06Chg³ Autor ³                       ³ Data ³25/09/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Rotina para execucao do filtro na tabela temporaria        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Bops ³ Manutencao Efetuada                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function HFXML06Chg(oMarkBw)

Local cRetFun		:= " "

oMarkBw:oBrowse:Refresh(.T.)

Return cRetFun



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³HFXML06Leg³ Autor ³Eneovaldo Roveri Junior³ Data ³ 17/02/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Legenda do Download e Manifestação                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HFXML06Leg()                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function HFXML06Leg()

Local aLegenda := {}

AADD(aLegenda,{"BR_AMARELO" ,"XML disponivel para tentar download."    })
AADD(aLegenda,{"BR_VERMELHO","Download Indisponibilizado pela SEFAZ."  })
AADD(aLegenda,{"BR_AZUL"    ,"Falta Manifestação do Destinatário"      })
AADD(aLegenda,{"BR_VERDE" 	,"Download Concluido com sucesso."         })
AADD(aLegenda,{"BR_MARROM"  ,"Download Indisponibilizado (Ja refeito)" })
AADD(aLegenda,{"BR_PRETO"   ,"XML Muito Antigo. Não Disponivel SEFAZ " })
AADD(aLegenda,{"BR_LARANJA" ,"Aguardando horário próximo Download."    })

BrwLegenda("Download de XML", "Legenda", aLegenda)

Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³HFXML06Exc³ Autor ³ Joreia                ³ Data ³28/09/2018³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Excluir do relatório de inconsistencias 137 do SEFAZ       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function HFXML06Exc()

Local cChave := (cAli_137)->CHAVE
Local cSt    := "89"

DbSelectArea(xZBS)
(xZBS)->( dbSetOrder( 3 ) )

if (xZBS)->( dbSeek( Substr( cChave,1,44 ) ) )

	If U_MyAviso("Pergunta","Deseja Excluir da Analise de Inconsistências (Retorno 137 SEFAZ) o XML "+AllTrim( (xZBS)->(FieldGet(FieldPos(xZBS_+"CHAVE"))) )+" ?",{"SIM","NÃO"},3) == 1
		
		RecLock(xZBS,.F.)
		( xZBS )->(FieldPut(FieldPos(xZBS_+"ST")	, cSt ))
		( xZBS )->( MsUnlock() )
		
		DbSelectArea(cAli_137)
		RecLock( cAli_137, .F. )
		
		(cAli_137)->( DbDelete() )
		(cAli_137)->( MsUnLock() )
		
	EndIf
	
Else

	U_MyAviso("Atenção","Não Encontrado",{"OK"},3) == 1
	
Endif

DbSelectArea(cAli_137)

Return



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³HFXML06Vis³ Autor ³ Eneo                  ³ Data ³28/05/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Visualizar Registro, quando for consulta por CNPJ mostrará ³±±
±±³          ³ os dados adicionais                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Bops ³ Manutencao Efetuada                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function HFXML06Vis()

Local oDlg

Private oFont01:= TFont():New("Arial",07,14,,.T.,,,,.T.,.F.)
Private oFont02:= TFont():New("Lucida Console",07,14,,.T.,,,,.T.,.F.)
Private oFont03:= TFont():New("Arial",05,10,,.F.,,,,.f.,.F.) 

Private aPages := {"Gerais","NF-e","Carta Correção"}
Private nPageGer := aScan(aPages,{|x| x == "Gerais"})
Private nPageNfe := aScan(aPages,{|x| x == "NF-e"})
Private nPageCCe := aScan(aPages,{|x| x == "Carta Correção"})

DEFINE MSDIALOG oDlg TITLE "Visualização Registro" FROM 000,000 TO 430,800 PIXEL STYLE DS_MODALFRAME STATUS

oPage := TFolder():New(002,002,aPages,{},oDlg,,,,.T.,.F.,350,210,)
    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 00.5,00.5 To 012,043 OF oPage:aDialogs[nPageGer]

@ 010,010 Say "Chave: " PIXEL OF oPage:aDialogs[nPageGer] COLOR CLR_BLUE FONT oFont01
@ 018,010 Get oObj VAR (cAli_137)->CHAVE SIZE 150,08 When .F. PIXEL OF oPage:aDialogs[nPageGer]                   

@ 040,010 Say "CNPJ Destinatário: "  PIXEL OF oPage:aDialogs[nPageGer] COLOR CLR_BLUE FONT oFont01
@ 048,010 Get oObj VAR (cAli_137)->DEST SIZE 150,08 When .F. PIXEL OF oPage:aDialogs[nPageGer] 

@ 070,010 Say "Mensagem Retorno WS: "  PIXEL OF oPage:aDialogs[nPageGer] COLOR CLR_BLUE FONT oFont01
@ 078,010 Get oObj VAR (cAli_137)->MSG SIZE 150,08 When .F. PIXEL OF oPage:aDialogs[nPageGer] 

@ 100,010 Say "Mensagem Erro WS: "  PIXEL OF oPage:aDialogs[nPageGer] COLOR CLR_BLUE FONT oFont01
@ 108,010 Get oObj VAR (cAli_137)->ERRO MULTILINE SIZE 300,50 When .F. PIXEL OF oPage:aDialogs[nPageGer] 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 00.5,00.5 To 012,043 OF oPage:aDialogs[nPageNfe]

@ 010,010 Say "Manifestação do Destinatário: " PIXEL OF oPage:aDialogs[nPageNfe] COLOR CLR_BLUE FONT oFont01
@ 018,010 Get oObj VAR (cAli_137)->CSITCONF SIZE 10,08 When .F. PIXEL OF oPage:aDialogs[nPageNfe]                   
@ 018,030 Say "0=S/Manif.     1=Conf.Oper." PIXEL OF oPage:aDialogs[nPageNfe] COLOR CLR_BLUE FONT oFont03
@ 022,030 Say "2=Desconhecida 3=Oper.Não Real. 4=Ciência" PIXEL OF oPage:aDialogs[nPageNfe] COLOR CLR_BLUE FONT oFont03

@ 010,170 Say "CNPJ Emitente: "  PIXEL OF oPage:aDialogs[nPageNfe] COLOR CLR_BLUE FONT oFont01
@ 018,170 Get oObj VAR (cAli_137)->CNPJ_EMI SIZE 150,08 When .F. PIXEL OF oPage:aDialogs[nPageNfe] 

@ 040,010 Say "Data Emissão: "  PIXEL OF oPage:aDialogs[nPageNfe] COLOR CLR_BLUE FONT oFont01
@ 048,010 Get oObj VAR (cAli_137)->DEMI SIZE 150,08 When .F. PIXEL OF oPage:aDialogs[nPageNfe] 

@ 040,170 Say "Emitente: "  PIXEL OF oPage:aDialogs[nPageNfe] COLOR CLR_BLUE FONT oFont01
@ 048,170 Get oObj VAR (cAli_137)->XNOME SIZE 150,08 When .F. PIXEL OF oPage:aDialogs[nPageNfe] 

@ 070,010 Say "Valor da NFe: "  PIXEL OF oPage:aDialogs[nPageNfe] COLOR CLR_BLUE FONT oFont01
@ 078,010 Get oObj VAR AllTrim( Str( (cAli_137)->VNF) ) SIZE 150,08 When .F. PIXEL OF oPage:aDialogs[nPageNfe] 

@ 070,170 Say "IE Emitente: "  PIXEL OF oPage:aDialogs[nPageNfe] COLOR CLR_BLUE FONT oFont01
@ 078,170 Get oObj VAR (cAli_137)->IE SIZE 150,08 When .F. PIXEL OF oPage:aDialogs[nPageNfe] 

@ 100,010 Say "Validação: "  PIXEL OF oPage:aDialogs[nPageNfe] COLOR CLR_BLUE FONT oFont01
@ 108,010 Get oObj VAR (cAli_137)->DIGVAL SIZE 150,08 When .F. PIXEL OF oPage:aDialogs[nPageNfe] 

@ 100,170 Say "Autorização: "  PIXEL OF oPage:aDialogs[nPageNfe] COLOR CLR_BLUE FONT oFont01
@ 108,170 Get oObj VAR (cAli_137)->DHRECBTO SIZE 150,08 When .F. PIXEL OF oPage:aDialogs[nPageNfe] 

@ 130,010 Say "NSU: "  PIXEL OF oPage:aDialogs[nPageNfe] COLOR CLR_BLUE FONT oFont01
@ 138,010 Get oObj VAR (cAli_137)->NSU SIZE 150,08 When .F. PIXEL OF oPage:aDialogs[nPageNfe] 

@ 130,170 Say "Situação NFe: "  PIXEL OF oPage:aDialogs[nPageNfe] COLOR CLR_BLUE FONT oFont01
@ 138,170 Get oObj VAR (cAli_137)->CSITNFE SIZE 10,08 When .F. PIXEL OF oPage:aDialogs[nPageNfe] 
@ 140,190 Say "1=Uso autorizado 2=Uso denegado 3=NF-e cancelada" PIXEL OF oPage:aDialogs[nPageNfe] COLOR CLR_BLUE FONT oFont03

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 00.5,00.5 To 012,043 OF oPage:aDialogs[nPageCce]
@ 010,010 Say "Carta de Correção: "  PIXEL OF oPage:aDialogs[nPageCce] COLOR CLR_BLUE FONT oFont01
@ 018,010 Get oObj VAR (cAli_137)->Correcao MULTILINE SIZE 310,140 When .F. PIXEL OF oPage:aDialogs[nPageCce] 

@ 012,355 Button "Sair" Size 040,015 PIXEL OF oDlg ACTION oDlg:End()

ACTIVATE MSDIALOG oDlg CENTERED ON INIT (nOpca := 0,.T.)

Return(NIL)



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³HFXML61Dow³ Autor ³ Nelson Mandela        ³ Data ³ 03/10/18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Download das Chaves                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HFXML61Dow()                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function HFXML61Dow(oMarkBw,lEnd,oRegua,cMarcaOK,lMostra,cLogProc) //oProcess

Local nReg   := (cAli_137)->( recno() )
Local aArea  := GetArea()
Local nMar   := 0
Local cAmb   := ""
Local cCnpj  := SM0->M0_CGC  //"61135471000100"
Local cIdEnt := U_GetIdEnt()
Local cDir   := AllTrim(SuperGetMv("MV_X_PATHX")) 
Local lProssegue := .F.		//FR - 16/10/2020

If lMostra

	oRegua:SetRegua1( (cAli_137)->( RecCount() ))
	oRegua:SetRegua2(0)
	
EndIF

(cAli_137)->( dbSetORder( 1 ) )
(cAli_137)->( dbgotop() )

Do While .NOT. (cAli_137)->( Eof() )

	If lMostra
	
		if lEnd
		
			MsgStop("*** Cancelado pelo Operador ***","Fim")
			Exit
			
		endif
		
		oRegua:IncRegua1("Processando Download das Chaves")
		oRegua:IncRegua2((cAli_137)->CHAVE)

		Conout("Processando Download das Chaves" + (cAli_137)->CHAVE)
		
	EndIF
	
	If ! Empty( (cAli_137)->OK )			//se está marcado [x]

		nMar++

		cCnpj  := (cAli_137)->DEST
		cAmb   := (cAli_137)->AMB
		
		//FR - 16/10/2020 - efetua cálculo do tempo de espera entre um download e o próximo desta chave:
		aVerRedown := U_fPodeRedown((cAli_137)->CHAVE)
		lProssegue := .F.	
		If Len(aVerRedown) > 0
			lProssegue := aVerRedown[1]	
			nTempoResta:= aVerRedown[2]
		Else
			lProssegue := .T.
		Endif
									
		cHoragora := Time()	
		cProxHora := U_fCalcProxHr(cHoragora,nTempoResta)	
		//FR - 16/10/2020
		
		If lProssegue
		
			If Substr((cAli_137)->CHAVE,21,2) $ "57,67"
		//		nRet := HFXML61Bai(cCnpj,(cAli_137)->CHAVE,cAmb,cIdEnt)
			Else
				nRet := HFXML61B55(cCnpj,(cAli_137)->CHAVE,cAmb,cIdEnt,(cAli_137)->NSU,lMostra,@cLogProc)
			EndIf
		
		Else
			//FR - 16/10/2020 - grava na tabela temporária que esta chave ainda está aguardando tempo de espera para download
			DbSelectArea(cAli_137)
			RecLock( cAli_137, .F. )
			
			(cAli_137)->ST    	:= 'A'		
			(cAli_137)->PROXRED	:= Dtoc(dDatabase) + " - " + cProxHora					

			(cAli_137)->( MsUnLock() )
		
		Endif

	EndIf

	(cAli_137)->( dbSkip() )
	
EndDo

//(cAli_137)->( dbSetORder( 1 ) )
(cAli_137)->( dbgoto( nReg ) )

if nMar == 0

	If lMostra
	
		U_MyAviso("Msg","Nenhuma Chave Selecionada !!!!",{"OK"},3)
		
	Else
	
		cLogProc += "Nenhuma Chave Encontrada via Problemas Resposta 137 SEFAZ !!!!"
		
	Endif
	
endif

If lMostra .And. oMarkBw <> NIL

	oMarkBw:oBrowse:Refresh(.T.)
	
Endif

RestArea( aArea )

Return( NIL )


Static Function HFXML61B55(cCnpj,cChave,cAmb,cIdEnt,cNsu,lMostra,cLogProc)

Local nRet   		:= 2
Local nChv   		:= 0
Local cDir   		:= AllTrim(SuperGetMv("MV_X_PATHX"))
Local cXml   		:= ""
Local cInfo  		:= ""
Local cMsg   		:= ""
Local cStt   		:= ""
Local nHandle		:= 0
Local lOk    		:= .T.
Local dDtEmi 		:= ctod( "" )
Local cChaveArq 	:= ""
Local aAreaZBS 		:= (xZBS)->( GetArea() )
Local aVerRedown 	:= {}  		//FR - 16/10/2020
Local nTempoResta   := 0		//FR - 16/10/2020

Default lMostra  	:= .T.
Default cLogProc 	:= ""

Private oWs,oWsrNfe,oWsdNfe,cErro:="",cWarning:="", aEnvNfe := {}

Do While .T.

	(xZBS)->( dbSetOrder( 3 ) )
	if (xZBS)->( dbSeek( Substr( cChave,1,44 ) ) )
		dDtEmi := ( xZBS )->(FieldGet(FieldPos(xZBS_+"DEMI")))
		if (xZBS)->( FieldPos( xZBS_+"XML" ) ) > 0
			if ! Empty(( xZBS )->(FieldGet(FieldPos(xZBS_+"XML"))))
				cXml := ( xZBS )->(FieldGet(FieldPos(xZBS_+"XML")))
				if upper("<resNFe ") $ upper( cXml )
					nRet := 1  //Falta Manifestação e depois tentar o NFe
				else
					nRet := 0
				endif
			endif
		endif
	EndIF 
	
	nChv++
	
	if nRet <> 0 .And. nChv < 2
	
		if GetNewPar( "XM_DFE", "0" ) == "2"
		
			cExt := ""
			cMsg := ""
			cInfo := ""
			l137  := .f.
			cChaveArq := ""
			
			cChaveArq := U_HFBxXML("55","CN",cNsu,@cExt,@cMsg,@cInfo,@l137,.F.,NIL)
			
			cLogProc += cMsg
			
			if !Empty(cChaveArq)
			
				if ! slvxmlzbz(cChaveArq, .T.,.F.,NIL,"",0, "2", Substr(cChave,1,44), @cInfo )  //2=Downlaod Sefaz
				
				else
				
					DbSelectArea(xZBS)
					(xZBS)->( dbSetOrder( 3 ) )
					
					if (xZBS)->( dbSeek( Substr( cChave,1,44 ) ) )
						RecLock(xZBS,.F.)
						( xZBS )->(FieldPut(FieldPos(xZBS_+"ST")	, "10" ))
						( xZBS )->( MsUnlock() )
					Endif
					
					DbSelectArea(cAli_137)	
									
				EndIf
				
			endif
			
		else
		
			U_HFDOWDFE( cCnpj,cChave,cAmb,cIdEnt,cNsu,@cLogProc )   //Pedir ao SEFAZ por NSU
			
		endif
		
		Loop
		
	ElseIf nRet <> 0 .And. nChv < 3
	
		if GetNewPar( "XM_DFE", "0" ) == "2"
		
			cExt := ""
			cMsg := ""
			cInfo := ""
			l137  := .f.
			
			cChaveArq := U_HFBxXML("55","DC",Substr(cChave,1,44),@cExt,@cMsg,@cInfo,@l137,.F.,NIL)
			
			cLogProc += cMsg
			
			if !Empty(cChaveArq)
			
				if ! slvxmlzbz(cChaveArq, .T.,.F.,NIL,"",0, "2", Substr(cChave,1,44), @cInfo )  //2=Downlaod Sefaz
					
					xRet := 3
					
				Else
				
					DbSelectArea(xZBS)
					(xZBS)->( dbSetOrder( 3 ) )
					
					if (xZBS)->( dbSeek( Substr( cChave,1,44 ) ) )
					
						RecLock(xZBS,.F.)
						( xZBS )->(FieldPut(FieldPos(xZBS_+"ST")	, "10" ))
						( xZBS )->( MsUnlock() )
						
					Endif
					
					xRet := 0
					
				EndIf
				
			else
			
				if "633" $ cMsg
				
					xRet := 1
					
				else
				
					xRet := 2
					
				endif
				
				if l137
				
					xRet := 3
					
				endif
				
			endif
			
		else
		
			xRet := U_HFDOWCHV( cCnpj,cChave,cAmb,cIdEnt,@cLogProc )   //Pedir Pela Chave
			
		endif
		
		if xRet == 0
		
//			Alert( "Chave "+cChave )
			cStt  := "10"
			nRet  := 9  //Porque Fez O Download
			
		ElseIf xRet == 3
		
			cStt  := "98"
			nRet  := 2  //137 de novo
			
		ElseIf xRet == 1
		
			cStt  := "10"
			nRet  := 1  //fALTA MANIFESTA
			
		Else
		
			Loop
			
		Endif
		
	Endif
	
	Exit
	
EndDo

if nRet == 0 //.And. !Empty( cXml )

		cChaveArq := cDir + Substr(cChave,1,44) + "-procNFe.xml"
		
		if Len(cXml) >= 65534
			oXML := U_PARSGDE( cXml, @cErro, @cWarning )
		Else
			oXml := XmlParser( cXml, "_", @cErro, @cWarning )
		endif
	
		if oXML == NIL //.Or. !Empty(cErro) .Or. !Empty(cWarning)
		
			cStt  := "98"
			cMsg  := "Erro Parser do XML"
			cInfo := cErro + " " + cWarning
			
		Else
			SAVE oXML XMLFILE cChaveArq
			
			nHandle := FT_FUse( cChaveArq )
			
			if nHandle == -1
			
				cStt  := "98"
				cMsg  := "Erro Gravação"
				cInfo := "Erro de Gravação XML no Diretório "+cChaveArq
				
			else
			
				cStt  := "10"
				cMsg  := "Download Efetuado"
				cInfo := "Download Efetuado do XML "+Substr(cChave,1,44)
				
			endif
			
			FT_FUSE()
			
			if cStt == "10"
			
				if ! slvxmlzbz(Substr(cChave,1,44) + "-procNFe.xml", .T.,.F.,NIL,"",0, "2", Substr(cChave,1,44), @cInfo )  //2=Downlaod Sefaz
				
					cStt  := "98"
					cMsg  := "Erro Importação"
					
				EndIf
				
			Endif
			
		EndIf
		
ElseIF nRet == 9

	nRet := 0
	cStt := "10"
	cMsg  := "Download Efetuado"
	cInfo := "Download Efetuado do XML "+Substr(cChave,1,44)
	
ElseIf nRet == 1

	cStt := "90"
	cMsg  := "Falta Manifestação"
	cInfo := "Falta Manifestação do Destinatário"
	
Else

	nRet := 2
	
	if !Empty(dDtEmi) .And. dDtEmi < dDataBase - 90
	
		cStt := "97"
		cMsg  := "XML Não Encontrado"
		cInfo := "XML Muito Antigo. Não mais Disponivel pela SEFAZ via WS"
		
	Else
	
		cStt := "98"		
		cMsg  := "XML Não Encontrado"
		cInfo := "XML Não Disponibilizado pela SEFAZ."
		
	Endif
	
Endif

(xZBS)->(RestArea( aAreaZBS ))

DbSelectArea(cAli_137)
RecLock( cAli_137, .F. )

(cAli_137)->ST    	:= cStt
(cAli_137)->MSG   	:= cMsg
(cAli_137)->ERRO  	:= cInfo
(cAli_137)->DREDOW	:= dDatabase 	//FR - 16/10/2020
(cAli_137)->HREDOW	:= Time()  		//FR - 16/10/2020

(cAli_137)->( MsUnLock() )

DelClassIntf()

Return( nRet )


Static Function slvxmlzbz(cNomArq, lAuto, lEnd, oProcess, cLogProc, nCount, cVem, cChv, cInfo)

Local lRet := .T.
Local aArea := GetArea()
Local nOrd  := (xZBZ)->( indexord() )

U_HFSLVXML(cNomArq, lAuto, lEnd, oProcess, cLogProc, nCount, cVem )

DbSelectArea( xZBZ )
dbSetORder( 3 )

If ! (xZBZ)->( dbSeek( cChv ) )  //Arquivo Baixado mas não conseguiu importar
	
	cInfo := "Download Efetuado, mas não foi possível importar para a Base o XML "+Substr(cChv,1,44)
	lRet := .F.
	
EndIf

(xZBZ)->( dbSetORder( nOrd ) )

RestArea( aArea )

Return( lRet )


User Function HFDOWCHV( cCnpj,cChave,cAmb,cIdEnt,cLogProc )

Local nRet   := 0
Local cURL   := ""
Local cDir   := AllTrim(SuperGetMv("MV_X_PATHX"))
Local cXml   := ""
Local cNfe   := ""
Local cInfo  := ""
Local cMsg   := ""
Local cStt   := ""
Local nHandle:= 0
Local lOk    := .T.
Local cVerLayEven := "1.00"
Local cHrVerao    := "2"
Local cHorario    := "2"
Local ni := 0 //declaracao
Local lHF := .T.
Local cSt       := ""
Local cSitConf  := ""
Local cChaveXml := ""
Local cNf       := ""
Local cSer      := ""
Local cCnpjXml  := ""

Private oWs,oWsrNfe,oWsdNfe,cErro,cWarning

/*±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Valida se pode continuar com a requisição ao SEFAZ        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±*/
U_HFXML071(cChave)
If !lConsReq
	lRet := .F.
		Return(lRet)
EndIf
cURL      := AllTrim(GetNewPar("XM_URL",""))

If Empty(cURL)

	cURL  := AllTrim(SuperGetMv("MV_SPEDURL"))
	
EndIf

If Right( AllTrim(cURL), 1 ) != "/"

	cURL := AllTrim(cURL)+"/"
	
EndIf

if lHF

	oWSdNfe:= WSHFXMLNFEDISTRIBUICAODFE():New()
	oWSdNfe:Init()
	oWSdNfe:cCIDENT       := cIdEnt
	oWSdNfe:cCCURL        := cURL
	oWSdNfe:cCAMBIENTE    := cAmb
	oWSdNfe:cCVERSAODADOS := "1.01" //esse é a parada cVerLayEven
	oWSdNfe:cCCUF         := substr(cChave,1,2) //"AN"  //ver isso aqui, é o Estado, agora vem de 1 em 1
	oWSdNfe:cCCNPJ        := cCnpj
	oWSdNfe:cCNSU         := ""
	oWSdNfe:cCCHSTR       := cChave

//	Alert(cChave)
//	Alert(cCnpj)

	if oWSdNfe:HFNFEDISTRDFE()
	
		cXml := "<"+AllTrim(oWSdNfe:cHFNFEDISTRDFERESULT)
		nAt1:= At('<RETDISTDFEINT ',Upper(cXml))
		nAt2:= At('</RETDISTDFEINT>',Upper(cXml))+ 16
		
		//Corpo do XML
		If nAt1 <=0
		
			nAt1:= At('<RETDISTDFEINT>',Upper(cXml))
			
		EndIf 	
		
		If nAt1 > 0 .And. nAt2 > 16
		
			cNfe := Substr(cXml,nAt1,nAt2-nAt1)

			cXml:= '<?xml version="1.0" encoding="UTF-8"?>'
			cXml+= cNfe
			
			//cXml := NoAcento(cXml)
			cXml := EncodeUTF8(cXml)
			cErro:= ""
			cWarning:= ""
			
			if Len(cXml) >= 65534
				oWSrNfe := U_PARSGDE( cXml, @cErro, @cWarning )
			Else
				oWSrNfe := XmlParser( cXml ,"_",@cErro, @cWarning )
			endif
			
			If oWSrNfe == NIL //.Or. !Empty(cErro) .Or. !Empty(cWarning)
			
				cMsg   := "Erro Parser do XML de Resposta"
				cInfo  := cErro + " " + cWarning
				
			ElseIf oWSrNfe:_RETDISTDFEINT:_CSTAT:TEXT <> "138" //"139"
			
				cMsg   := "Retorno do Sefaz "+oWSrNfe:_RETDISTDFEINT:_CSTAT:TEXT
				
				if oWSrNfe:_RETDISTDFEINT:_CSTAT:TEXT = "137"
				
					cStt := "137"
					
				endif
				
				cInfo  := oWSrNfe:_RETDISTDFEINT:_XMOTIVO:TEXT
			    nOrd   := (xZBZ)->( IndexOrd() )
			    
			    cSitConf  := " "
			    
				cChaveXml := substr(cChave,1,44)
				cNf       := Substr( cChaveXml, 26, 9 )
				cSer      := Substr( cChaveXml, 23, 3 )
				cCnpjXml  := Substr( cChaveXml, 07, 14 )
								
			    ( xZBZ )->( DbSetOrder( 3 ) )
			    
				If ( xZBZ )->(dbSeek( cChaveXml ) )
				
					cSt := "10"
					
				Else
				
					cSt := "99"
					
				Endif
				
				( xZBZ )->( DbSetORder( nOrd ) )
				
				nHdl := -1
				
				If U_HFTrvXml("TRAVA", "ZBS"+cChaveXml, @nHdl)
				
					( xZBS )->( DbSetOrder( 3 ) )
					
					If .Not. ( xZBS )->(dbSeek( cChaveXml ) )
					
						cLogProc += cChaveXml+" Nova Chave Sincronizada NFeDistribuicaoDFe."+CRLF

						RecLock(xZBS, .T. )
						
						( xZBS )->(FieldPut(FieldPos(xZBS_+"FILIAL"), XFilial(xZBS) ))  
						( xZBS )->(FieldPut(FieldPos(xZBS_+"CHAVE")	,  cChaveXml ))
						( xZBS )->(FieldPut(FieldPos(xZBS_+"AMB")	,  cAmb ))
						( xZBS )->(FieldPut(FieldPos(xZBS_+"DEST")	,  cCnpj ))
						( xZBS )->(FieldPut(FieldPos(xZBS_+"IDENT")	,  cIdEnt ))
						
						If ( xZBS )->( FieldPos(xZBS_+"MODELO") ) > 0
						
							( xZBS )->(FieldPut(FieldPos(xZBS_+"MODELO"), Substr(cChaveXml,21,2) ))
							
						EndIF
						
						if (xZBS)->(FieldPos(xZBS_+"TPROT")) > 0 //Tipo de Rotina Job ou Manual
						
							if Empty(  (xZBS)->(FieldGet(FieldPos(xZBS_+"TPROT"))) )
							
								if Type("cTpRt") <> "U"
								
									(xZBS)->(FieldPut(FieldPos(xZBS_+"TPROT"), cTpRt ))
									
								endif
								
							endif
							
						endif
						
					Else
					
						cLogProc += cChaveXml+" Chave Ja esta na Sincronizacao NFeDistribuicaoDFe."+CRLF
						
						RecLock(xZBS, .F. )
						
						if ! Empty( ( xZBS )->(FieldGet(FieldPos(xZBS_+"DEMI"))) ) .And. ( xZBS )->(FieldGet(FieldPos(xZBS_+"DEMI"))) < (dDataBase - 90)
							
							if cSt == "99"  //Não aparecer, é muito velho o Bixo
							
								cSt := ( xZBS )->(FieldGet(FieldPos(xZBS_+"ST")))
								
							endif
							
						Endif
						
					Endif
					
					if ! Empty( ( xZBS )->(FieldGet(FieldPos(xZBS_+"CSITCO"))) )
					
						if cSitConf == "4" .And. ( xZBS )->(FieldGet(FieldPos(xZBS_+"CSITCO"))) > "0"
						
							cSitConf := ( xZBS )->(FieldGet(FieldPos(xZBS_+"CSITCO")))
							
						Else
						
							if ( xZBS )->(FieldGet(FieldPos(xZBS_+"CSITCO"))) > cSitConf
							
								cSitConf := ( xZBS )->(FieldGet(FieldPos(xZBS_+"CSITCO")))
								
							Endif
							
						Endif
						
					Endif
					
					( xZBS )->(FieldPut(FieldPos(xZBS_+"ST")	, cSt ))
					( xZBS )->(FieldPut(FieldPos(xZBS_+"CSITCO"), cSitConf ))
					( xZBS )->(FieldPut(FieldPos(xZBS_+"CNF")	, cNf ))
					( xZBS )->(FieldPut(FieldPos(xZBS_+"SERIE")	, cSer ))
					( xZBS )->(FieldPut(FieldPos(xZBS_+"CNPJEM"), cCnpjXml ))
					( xZBS )->(MsUnLock())
					
					U_HFTrvXml("SOLTA", "ZBS"+cChaveXml, nHdl) //SOLTAR
					
				Endif
				
			Else
			
				oDet := oWSrNfe:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP
				oDet := iif( valtype(oDet)=="O", {oDet}, oDet )
				
				For nI := 1 to len( oDet )  //Deixar assim para quando for mais de 1, mas agora tem que ser de 1 em 1.
					
					cStt  := ""
					cMsg  := ""
					cInfo := ""

					cFileZip	:= Decode64( oDet[nI]:TEXT )
					nLenZip		:= Len( cFileZip )
					cFileUnZip  := ""

					// Funcao de descompactacao de arquivos compactados no formato GZip
					lOk  :=  GzStrDecomp( cFileZip, nLenZip, @cFileUnZip )
					oXml := XmlParser( cFileUnZip, "_", @cErro, @cWarning )

					//Alteração em 13/04/2017, erro SalOnline
					//If UPPER(Substr(oDet[nI]:_SCHEMA:TEXT,1,7)) <> UPPER("procNFe") //"139"
					//	cMsg	:=	"633"
					//	cInfo	:=	"Falta Manifestação do Destinatário."
					//	cStt	:=	"0"
					
					If valtype(oXml) <> "O"
					
						cMsg	:=	"XXX"
						cInfo	:=	"Não foi possível Descompactar o XML."
						cStt	:=	"0"
						
					Else
					
						cChaveArq := cDir + Substr(cChave,1,44) + "-procNfe.xml" //alltrim( oDet[nI]:_CHNFE:TEXT ) + "-procNfe.xml"

						SAVE oXml XMLSTRING cXML
						
						nAt1:= At('<NFE ',Upper(cXml))
						nAt2:= At('</NFE>',Upper(cXml))+ 6
						
						//Corpo da Nfe
						If nAt1 <=0
						
							nAt1:= At('<NFE>',Upper(cXml))
							
						EndIf 	
						
						If nAt1 > 0 .And. nAt2 > 6
						
							cNfe := Substr(cXml,nAt1,nAt2-nAt1)
							
						Else
						
							cStt  := "0"
							cMsg  := "Xml Retorno Inválido"
							cInfo := "XML "+cChave+" sem TAG <NFE>"
							
						EndIf	
						
						nAt3:= At('<PROTNFE ',Upper(cXml))
						nAt4:= At('</PROTNFE>',Upper(cXml))+ 10
						
						//Protocolo	
						If nAt3 > 0 .And. nAt4 > 10
						
							cProt := Substr(cXml,nAt3,nAt4-nAt3)
							
						Else
						
							cStt  := "0"
							cMsg  := "Xml Retorno Inválido"
							cInfo += "XML "+cChave+" sem Protocolo, falta TAG <PROTNFE>"
							
						EndIf
						
						if empty( cMsg )
						
							//cXml:= '<?xml version="1.0"?>'
							cXml:= '<?xml version="1.0" encoding="UTF-8"?>'
							cXml+= '<nfeProc versao="2.00" xmlns="http://www.portalfiscal.inf.br/nfe">'
							cXml+= cNfe
							cXml+= cProt
							cXml+= '</nfeProc>'
							cXml := NoAcento(cXml)
							cXml := EncodeUTF8(cXml)
							
							if Len(cXml) >= 65534
								oXML := U_PARSGDE( cXml, @cErro, @cWarning )
							Else
								oXml := XmlParser( cXml, "_", @cErro, @cWarning )
							endif
	
							if oXML == NIL //.Or. !Empty(cErro) .Or. !Empty(cWarning)
							
								cStt  := "0"
								cMsg  := "Erro Parser do XML"
								cInfo := cErro + " " + cWarning
								
							Else
							
								SAVE oXML XMLFILE cChaveArq
								nHandle := FT_FUse( cChaveArq )
								
								if nHandle == -1
								
									cStt  := "0"
									cMsg  := "Erro Gravação"
									cInfo := "Erro de Gravação XML no Diretório "+cChaveArq
									
								else
								
									cStt  := "1"
									cMsg  := "Download Efetuado"
									cInfo := "Download Efetuado do XML "+Substr(cChave,1,44)
									
								endif
								
								FT_FUSE()
								
								if cStt == "1"
								
									if ! slvxmlzbz(Substr(cChave,1,44) + "-procNFe.xml", .T.,.F.,NIL,@cLogProc,0, "2", Substr(cChave,1,44), @cInfo )  //2=Downlaod Sefaz
										
										cStt  := "0"
										cMsg  := "Erro Importação"
									
									EndIf
									
								Endif
								
							EndIf
							
						Endif
	
					Endif
					
					cLogProc += cInfo + CRLF
					DelClassIntf()
					
				Next nI
				
			Endif
			
		Else
		
			cInfo := "FALTA TAG RETDISTR"
			cMsg  := "Erro TSS ou WS"
			cLogProc += cInfo + CRLF
        	//sem TAG RET e Tal
        	
		EndIf	
		
	else
	
		cInfo := IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
		cMsg  := "Erro TSS ou WS"
		cLogProc += cInfo + CRLF
		
	endif

Endif

if cMsg == "633"

	nRet := 1
	
Else

	if cStt == "1"
	
		nRet := 0
		
	ElseIF cStt == "137"
	
		nRet := 3
		
	else
	
		nRet := 2
		
	endif
	
Endif

DelClassIntf()

Return( nRet )


//Imprimir os dados caso queiram
Static Function HFXML61Imp()

Local aArea := GetArea()
Local oReport   := NIL

oReport := ReportDef(cTmp_137,"HFXML061")

oReport:PrintDialog() 

RestArea( aArea )

Return( NIL )



static function reportdef(cAlias,cPerg)

    local cTitle    := "Relatório de Chaves com Problema de Download (SEFAZ 137)"
    local cHelp     := ""
    local oReport
    local oSection1
	Local nTamCod   := TAMSXG("001")[1]
	Local nTamLoja  := TAMSXG("002")[1]

    Default cPerg := ""

    oReport := treport():new("HFXML061",cTitle,cPerg,{|oReport|ReportPrint(oReport,cAlias)},cHelp)
    oReport:SetLandScape()

    oSection1    := TRSection():new(oReport,"Chaves",{ cAlias })  

    TRCell():New(oSection1, "CHAVE"     , cAlias ,  "Chave"       ,   PesqPict('SF1','F1_CHVNFE') ,   TamSX3('F1_CHVNFE')[1]+1  ,   /*lPixel*/  ,   /*{|| code-block de impressao }*/)
    TRCell():New(oSection1, "CNF"       , cAlias ,  "NOTA FISCAL" ,   PesqPict('SF1','F1_DOC')    ,   TamSX3('F1_DOC')[1]+1     ,   /*lPixel*/  ,   /*{|| code-block de impressao }*/)
    TRCell():New(oSection1, "SERIE"     , cAlias ,  "SERIE"       ,   PesqPict('SF1','F1_SERIE')  ,   TamSX3('F1_SERIE')[1]+1   ,   /*lPixel*/  ,   /*{|| code-block de impressao }*/)
    TRCell():New(oSection1, "DEMI"      , cAlias ,  "DT EMISSAO"  ,   "@!"                        ,   11   						,   /*lPixel*/  ,   /*{|| code-block de impressao }*/)
    TRCell():New(oSection1, "DHRECBTO"  , cAlias ,  "DT AUTORIZ"  ,   "@!"                        ,   11   						,   /*lPixel*/  ,   /*{|| code-block de impressao }*/)
    TRCell():New(oSection1, "VNF"	    , cAlias ,  "VALOR"		  ,   "@Z 999,999,999,999.99"     ,   16   						,   /*lPixel*/  ,   /*{|| code-block de impressao }*/)
    TRCell():New(oSection1, "CNPJ_EMI"  , cAlias ,"CNPJ EMITENTE" ,   "@!"                        ,   15   						,   /*lPixel*/  ,   /*{|| code-block de impressao }*/)
    TRCell():New(oSection1, "XNOME"	    , cAlias ,	"EMITENTE"	  ,   "@!"                        ,   35   						,   /*lPixel*/  ,   /*{|| code-block de impressao }*/)
    TRCell():New(oSection1, "CODFOR"    , cAlias ,	"FORNEC"	  ,   PesqPict('SF1','F1_FORNECE'),   nTamCod+1   				,   /*lPixel*/  ,   /*{|| code-block de impressao }*/)
    TRCell():New(oSection1, "LOJFOR"    , cAlias ,	"LOJA"		  ,   PesqPict('SF1','F1_LOJA')	  ,   nTamLoja+1   				,   /*lPixel*/  ,   /*{|| code-block de impressao }*/)
    TRCell():New(oSection1, "NSU" 	    , cAlias ,	"NSU" 		  ,   "@!"                        ,   16   						,   /*lPixel*/  ,   /*{|| code-block de impressao }*/)
    TRCell():New(oSection1, "ST"        , cAlias ,  "ST"          ,   "!!"                        ,   3                         ,   /*lPixel*/  ,   /*{|| code-block de impressao }*/)
    TRCell():New(oSection1, "ERRO"	    , cAlias ,	"RESP SEFAZ"  ,   "@!"                        ,   15   						,   /*lPixel*/  ,   /*{|| code-block de impressao }*/)
    TRCell():New(oSection1, "MSG"	    , cAlias ,	"RETORNO"  	  ,   "@!"                        ,   31   						,   /*lPixel*/  ,   /*{|| code-block de impressao }*/)

return(oReport)


static function ReportPrint(oReport,cAlias)

    local oSection1  := oReport:Section(1)
    
    oReport:SetMeter((cAlias)->(recCount()))
    
    oSection1:Print()
    
return
