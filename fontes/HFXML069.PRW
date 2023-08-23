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

//Static lInitSped := .F.
//Static lUnix  := IsSrvUnix()
//Static cBarra := Iif(lUnix,"/","\")

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ HFXML069 ³ Autor ³ Heverton Marcondes    ³ Data ³18/08/2018³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Download Completo dos XML Resumo no sistema                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//--------------------------------------------------------------------------//
//FR - 04/09/2020 - Alteração na chamada da rotina de download :
//     U_HFDGXML( cChave, .T.  , .F. ,  NIL    , ""      , 0     , "2"  )
//     Aplicar tentativas com limite definido pelo parâmetro XM_TENTSEND
//--------------------------------------------------------------------------//
//FR - 22/09/2020 - Implementar a chamada da função de atualizar o status
//                  na ZBZ
//--------------------------------------------------------------------------//
//FR - 02/10/2020 - Revisão da query que popula o markbrowse
//--------------------------------------------------------------------------//
//FR - 16/10/2020 - Solicitações Rafael, tratativa para redownload:
//                  Criação de campos novos: 
//                  ZBZ_DREDOW: Dt último redownload
//                  ZBZ_HREDOW: Hr.último redownload
//					Tratativa para legenda indicando 
//                  data/hora do próx download
//--------------------------------------------------------------------------//
//FR - 25/11/2020 - Retirado limitador de registros da query que popula
//                  o markbrowse, pois devido as ultimas modificações de 
//                  verificar data e hora do próximo download, não será mais 
//                  necessário limitar na query
//--------------------------------------------------------------------------//

User Function HFXML069()

Local aArea := GetArea()
Local cEmp0 := cEmpAnt
Local cFil0 := cFilAnt
Local nReg0 := SM0->( recno() )
Local cCnpj := ""
Local lTem  := .T.
Local oProcess	:=	Nil
Local cCloud		:=	alltrim(GetNewPar("XM_CLOUD" ,"0"))         //aCombo (0=Desbilitado 1=Habilitado) 

Private cTmp_RES := "TMPRES", cAli_RES, oTmp_RES

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

CriaTMP()

cAli_RES := oTMP_RES:GetAlias()

oProcess := MsNewProcess():New({| lEnd | lTem := Popula( @lEnd, oProcess, .T., "99")},"Aguarde. Verificando XMLs...","Verificando XMLs",.T.)
oProcess:Activate()

if ! lTem

   U_MyAviso("Atenção","Não Existem XML com status de resumido."+CRLF+;
	"",{"OK"},1)
	
Endif

//MarkBrowse Da Bagaça
HFXML69Brw()

oTMP_RES:Delete()

RestArea(aArea)

Return( NIL )

***************************
User Function HFTTJ3()  //U_HFTTJ2()
***************************
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

	//aHfCloud := U_HFCLDINI(.F.,@cLogProc)
	
//EndIF

U_HFXML69J(lAuto,@lEnd,oProcess,@cLogProc,@nCount,.F.)

//Alert( "Foi" )

//Alert( nCount )

//Alert( cLogProc )

Return()

//+-----------------------------------------------------------------------------------//
//|Funcao....: HFXML69J
//|Autoria...: Heverton Marcondes - 16/10/2020
//|Descricao.: Monta processo para popular tela markbrowse
//|Observação: 
//+-----------------------------------------------------------------------------------//
User Function HFXML69J(lAuto,lEnd,oProcess,cLogProc,nCount,lMostra)

Local aArea := GetArea()
Local cEmp0 := cEmpAnt
Local cFil0 := cFilAnt
Local nReg0 := SM0->( recno() )
Local cCnpj := ""
Local lTem  := .T.

Default oProcess	:=	Nil

Private cMarcaOK := GetMark()
Private cTMP_RES := "TMPRES", cAli_RES, oTMP_RES

SM0->( dbSetOrder(1) )
If SM0->( dbSeek( cEmp0 + cFil0 ) )

	cCnpj := SM0->M0_CGC
	
Else

	SM0->( dbGoTo( nReg0 ) )
	cCnpj := SM0->M0_CGC
	
Endif

CriaTMP()

cAli_RES := oTMP_RES:GetAlias()

lTem := Popula( @lEnd, oProcess, lMostra, "99", cMarcaOK )  //"Aguarde. Verificando XMLs...","Verificando XMLs",.T.)

if ! lTem

   cLogProc += "Não Existe Registros com Problema de Download."+CRLF
   
Else

	HFXML69Dow(NIL,@lEnd,oProcess,cMarcaOK,lMostra,@cLogProc)  //Tenta Fazer os Downloads

Endif

oTMP_RES:Delete()

RestArea(aArea)

Return( NIL )

//+-----------------------------------------------------------------------------------//
//|Funcao....: CriaTMP
//|Autoria...: Heverton Marcondes - 16/10/2020
//|Descricao.: Cria arquivo temporário
//|Observação: 
//+-----------------------------------------------------------------------------------//
Static Function CriaTMP()

Local aStru := {}
Local aInd  := {}
Local nTamCod   := TAMSXG("001")[1]
Local nTamLoja  := TAMSXG("002")[1]
Local nTamFil   := TAMSXG("033")[1]		//FR 22/09/2020

aadd( aStru, { "OK"     ,"C",02,0 		} )
aadd( aStru, { "FIL"    ,"C",nTamFil,0 	} )
aadd( aStru, { "TPDOWL" ,"C",01,0 		} )
aadd( aStru, { "CHAVE"  ,"C",44,0 		} )
aadd( aStru, { "NOTA"   ,"C",09,0 		} )
aadd( aStru, { "SERIE"  ,"C",03,0 		} )
aadd( aStru, { "DTNFE"  ,"D",08,0 		} )
aadd( aStru, { "RETSEF" ,"C",100,0 		} )		//FR 15/09/2020
aadd( aStru, { "DREDOW" ,"D",08,0 		} )		//FR 16/10/2020
aadd( aStru, { "HREDOW" ,"C",05,0 		} )		//FR 16/10/2020
aadd( aStru, { "PROXRED","C",25,0       } ) 	//FR 16/10/2020	//proxima data/hora disponível para redownload
aadd( aStru, { "MODEL"  ,"C",02,0 		} )		//FR 22/09/2020
aadd( aStru, { "CNPJ"	,"C",20,0 		} )
aadd( aStru, { "CODFOR" ,"C",nTamCod ,0 } )
aadd( aStru, { "LOJFOR" ,"C",nTamLoja,0 } )
aadd( aStru, { "XNOME"  ,"C",60,0 		} )
//aadd( aStru, { "DHRECB"	,"C",20,0 		} )
aadd( aStru, { "DHRECB"	,"D",08,0 		} )
aadd( aStru, { "VALBRUT","N",15,2 		} )
aadd( aStru, { "XML"    ,"M",10,0 		} )
aadd( aStru, { "XMLRES" ,"M",10,0 		} )
aadd( aStru, { "RECZBZ" ,"N",20,0 		} )		//FR 22/09/2020

oTMP_RES := FWTemporaryTable():New( cTMP_RES, aStru ) //-> Objeto FWTemporaryTable 
	
	aInd := {}                              //indice 1
	aadd( aInd, "CHAVE" )
	
oTMP_RES:AddIndex( cTMP_RES+"01", aInd )   	//indice 2

	aInd := {}
	//aadd( aInd, "SERIE" )    				//FR 04/09/2020
	aadd( aInd, "NOTA" )
	
oTMP_RES:AddIndex( cTMP_RES+"02", aInd )    //indice 3

	aInd := {}
	//aadd( aInd, "DHRECB" )    			//FR 04/09/2020
	aadd( aInd, "DTNFE" )
	
oTMP_RES:AddIndex( cTMP_RES+"03", aInd )    //indice 4

	aInd := {}
	aadd( aInd, "OK" )
	aadd( aInd, "CHAVE" )

oTMP_RES:AddIndex( cTMP_RES+"04", aInd )
	//aInd := {}
	//aadd( aInd, "NOTA" )
	
oTMP_RES:Create()

Return()


//+-----------------------------------------------------------------------------------//
//|Funcao....: Popula
//|Autoria...: Heverton Marcondes - 16/10/2020
//|Descricao.: Popula tabela temporária
//|Observação: 
//+-----------------------------------------------------------------------------------//
Static Function Popula( lEnd, oRegua, lMostra, cSt, cMarcaOK )

Local lRet      := .F.
Local aArea     := GetArea()
Local cAliasZBZ := GetNextAlias()
Local cCodFor   := Space( 6 )
Local cLojFor   := Space( 2 )
Local cFilSek   := ""
//Local lSharedA1 := U_IsShared("SA1")
//Local lSharedA2 := U_IsShared("SA2")
Local cChaveXml := ""
Local LF		:= CHR(13)+CHR(10)
Local xNome		:= ""

Private xZBZ    := GetNewPar("XM_TABXML","ZBZ")      
Private xZBZ_ 	:= iif(Substr(xZBZ,1,1)=="S", Substr(xZBZ,2,2), Substr(xZBZ,1,3)) + "_"

Default cMarcaOK := ""

cQuery := " Select " + LF
//cQuery += " TOP 50 " + LF		//FR - 25/11/2020 Top N não funciona no Oracle
cQuery += " R_E_C_N_O_ as REG,   "+ LF
cQuery += " "+xZBZ_+"FILIAL as FILZBZ,  "+ LF
cQuery += " "+xZBZ_+"CHAVE  as CHAVE,   "+ LF
cQuery += " "+xZBZ_+"TPDOWL as TPDOWL,  "+ LF
cQuery += " "+xZBZ_+"DTNFE  as DTNFE,   "+ LF
cQuery += " "+xZBZ_+"VLBRUT as VALBRUT, "+ LF
cQuery += " "+xZBZ_+"MODELO as MODELO,  "+ LF
cQuery += " "+xZBZ_+"NOTA   as NOTA,    "+ LF
cQuery += " "+xZBZ_+"SERIE  as SERIE,   "+ LF
cQuery += " "+xZBZ_+"CNPJ   as CNPJ,    "+ LF
cQuery += " "+xZBZ_+"DTNFE  as DTNFE,   "+ LF
cQuery += " "+xZBZ_+"DTRECB as DTRECB,  "+ LF
cQuery += " "+xZBZ_+"CNPJ   as CNPJ,    "+ LF
cQuery += " "+xZBZ_+"DREDOW as DREDOW,  "+ LF		//FR - 16/10/2020
cQuery += " "+xZBZ_+"HREDOW as HREDOW   "+ LF		//FR - 16/10/2020
	
cQuery += " FROM "+RetSqlName(xZBZ)+" ZBZ "	+ LF
cQuery += " Where D_E_L_E_T_ <> '*' "		+ LF
cQuery += " And "+ xZBZ_ +"FILIAL = '" + Alltrim(xFilial( xZBZ )) + "' "	+ LF   //tentar com várias filiais
cQuery += " And "+ xZBZ_ +"DTNFE >= '"+dtos(dDataBase-90)+"' "+ LF  
cQuery += " And ("+xZBZ_+"TPDOWL = 'R' Or "+xZBZ_+"TPDOWL = 'I') "+ LF 	
//TESTE FR
//cQuery += " And " + xZBZ_+"NOTA = '000380859' "
//cQuery += " And ROWNUM <= 50 " + LF  //FR - comando para Oracle	
cQuery += " ORDER BY "+xZBZ_+"DTNFE , " + xZBZ_+"NOTA "

cQuery := ChangeQuery(cQuery)		//FR 03/11/2020
MemoWrite("C:\TEMP\popula_markb.sql" , cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasZBZ)

DbSelectARea( cAliasZBZ )
(cAliasZBZ)->( dbGoTop() )
Do While .NOT. (cAliasZBZ)->( Eof() )

	cChaveXml := (cAliasZBZ)->CHAVE
    xNome     := ""
	If lMostra
	
		If lEnd
		
			MsgStop("*** Cancelado pelo Operador ***","Fim")
			Exit
			
		EndIf 
		
		oRegua:IncRegua1("Procurando por XMLs Completos de Download Resumidos ...")
		oRegua:IncRegua2( cChaveXml )
		
	EndIf

	lRet := .T.

	DbSelectARea( xZBZ )
	DbGoTo( (cAliasZBZ)->REG )

	cCodFor   := Space( 6 )
	cLojFor   := Space( 2 )
	
    If empty(cCodFor)
	
		cFilSek   := xFilial( "SA2" )  //iif(lSharedA2, xFilial( "SA2" ), (cAliasZBZ)->FILZBZ )
		DbSelectArea("SA2")
		DbSetOrder(3)
		
		If DbSeek(cFilSek + (cAliasZBZ)->CNPJ ) 
		
			cCodFor := SA2->A2_COD
			cLojFor := SA2->A2_LOJA 
			
			Do While .not. SA2->( eof() ) .and. SA2->A2_FILIAL == cFilSek .and. SA2->A2_CGC == (cAliasZBZ)->CNPJ
				
				if SA2->A2_MSBLQL != "1"
				
					cCodFor := SA2->A2_COD
					cLojFor := SA2->A2_LOJA 
					
					exit
					
				endif
				
				SA2->( dbSkip() )
				
			EndDo
			
		EndIf
		
	EndIF
	
	if empty(cCodFor)
	
		cFilSek   := xFilial( "SA1" ) //iif(lSharedA1, xFilial( "SA1" ), (cAliasZBZ)->FILZBZ )
		
		DbSelectArea("SA1")
		DbSetOrder(3)
		If DbSeek(cFilSek + (cAliasZBZ)->CNPJ ) 
		
			cCodFor := SA1->A1_COD
			cLojFor := SA1->A1_LOJA 
			
			Do While .not. SA1->( eof() ) .and. SA1->A1_FILIAL == cFilSek .and.;
					               SA1->A1_CGC == (cAliasZBZ)->CNPJ
				
				if SA1->A1_MSBLQL != "1"
				
					cCodFor := SA1->A1_COD
					cLojFor := SA1->A1_LOJA 
					
					exit
											
				endif
				
				SA1->( dbSkip() )
				
			EndDo
			
		EndIf
		
	EndIF

	DbSelectArea( cAli_RES )
	
	RecLock( cAli_RES, .T. )
	
	//xNome := ( xZBZ )->( FieldGet( FieldPos( xZBS_+"FORNEC" 	) ) ) 
	xNome := ""	
	If Empty(xNome)
		//xNome := Posicione("SA2",3,xFilial("SA2")+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))),"A2_NOME")
		xNome := Posicione("SA2",3,xFilial("SA2") + (cAliasZBZ)->CNPJ,"A2_NOME") 
	Endif
	
	(cAli_RES)->TPDOWL	:= (cAliasZBZ)->TPDOWL  		//( xZBZ )->( FieldGet( FieldPos( xZBZ_+"TPDOWL" ) ) )
	(cAli_RES)->FIL 	:= (cAliasZBZ)->FILZBZ			//( xZBZ )->( FieldGet( FieldPos( xZBZ_+"FILIAL" ) ) )
	(cAli_RES)->CHAVE 	:= cChaveXml
	(cAli_RES)->NOTA  	:= (cAliasZBZ)->NOTA 			//( xZBZ )->( FieldGet( FieldPos(xZBZ_+"NOTA"	) ) )
	(cAli_RES)->SERIE 	:= (cAliasZBZ)->SERIE			//( xZBZ )->( FieldGet( FieldPos(xZBZ_+"SERIE"	) ) )
	(cAli_RES)->CNPJ 	:= (cAliasZBZ)->CNPJ			//( xZBZ )->( FieldGet( FieldPos( xZBZ_+"CNPJ" ) ) )
	(cAli_RES)->CODFOR  := cCodFor
	(cAli_RES)->LOJFOR  := cLojFor
	(cAli_RES)->XNOME   := xNome 						//( xZBZ )->( FieldGet( FieldPos( xZBS_+"FORNEC" 	) ) )	
	(cAli_RES)->DTNFE   := Stod( (cAliasZBZ)->DTNFE)	//( xZBZ )->( FieldGet( FieldPos( xZBZ_+"DTNFE" 	) ) )  //DTOC( ( xZBZ )->( FieldGet( FieldPos( xZBZ_+"DTNFE" ) ) ) )
	(cAli_RES)->DHRECB 	:= Stod( (cAliasZBZ)->DTRECB)	//( xZBZ )->( FieldGet( FieldPos( xZBZ_+"DHRECB" 	) ) ) 
	(cAli_RES)->VALBRUT := (cAliasZBZ)->VALBRUT			//( xZBZ )->( FieldGet( FieldPos( xZBZ_+"VLBRUT" 	) ) )
	(cAli_RES)->MODEL   := (cAliasZBZ)->MODELO	   		//( xZBZ )->( FieldGet( FieldPos( xZBZ_+"MODELO" 	) ) )
	(cAli_RES)->RECZBZ  := (cAliasZBZ)->REG 
	(cAli_RES)->DREDOW  := Stod( (cAliasZBZ)->DREDOW)	//FR - 16/10/2020
	(cAli_RES)->HREDOW  := (cAliasZBZ)->HREDOW			//FR - 16/10/2020

	If ! Empty(cMarcaOK)  //Para o JOB
	
		(cAli_RES)->OK	:= cMarcaOK

	Endif
	
	(cAli_RES)->( MsUnLock() )

	DbSelectARea( cAliasZBZ )
	(cAliasZBZ)->( dbSkip() )

EndDo

(cAliasZBZ)->( dbCloseArea() )

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
Static Function HFXML69Brw()

Local aButtons	:= {}
Local aArea  	:= GetArea()
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
//Local oProgress := NIL

Private cMarcaOK := GetMark()
Private cFiltro  := "NN"

aCpos := {}
aadd( aCpos, {"OK"   	,,"" 									} )
aadd( aCpos, {"FIL"   	,,"FILIAL"						,"@!"	} )
aadd( aCpos, {"CHAVE"	,,"CHAVE"						,"@!" 	} )
aadd( aCpos, {"NOTA"    ,,"NOTA FISCAL"					,"@!"	} )
aadd( aCpos, {"SERIE"   ,,"SERIE"						,"@!" 	} )
aadd( aCpos, {"DTNFE"  	,,"DT EMISSAO"					,"@!" 	} )
aadd( aCpos, {"RETSEF" 	,,"Retorno SEFAZ"				,"@!" 	} )		//FR 15/09/2020
aadd( aCpos, {"DREDOW" 	,,"Dt.Ult. Redownload"			,"@!" 	} )		//FR 16/10/2020
aadd( aCpos, {"HREDOW" 	,,"Hr.Ult. Redownload"			,"@!" 	} )		//FR 16/10/2020
aadd( aCpos, {"PROXRED" ,,"Prox.Redownload Disponível"	,"@!"	} )		//FR 16/10/2020
aadd( aCpos, {"MODEL" 	,,"Modelo"						,"@!" 	} )		//FR 15/09/2020
aadd( aCpos, {"CNPJ"	,,"CNPJ EMITENTE"				,"@R 99.999.999/9999-99" } )
aadd( aCpos, {"CODFOR" 	,,"FORNEC"						,"@!" 	} )
aadd( aCpos, {"LOJFOR" 	,,"LOJA"						,"@!"	} )
aadd( aCpos, {"XNOME"  	,,"NOME EMITENTE"				,"@!" 	} )
aadd( aCpos, {"VALBRUT"	,,"VALOR"						,"@Z 999,999,999,999.99" } )
aadd( aCpos, {"XML"    	,,"XML"							,"@!" 	} )
aadd( aCpos, {"XMLRES" 	,,"XML RRESUMO"					,"@!" 	} )
aadd( aCpos, {"RECZBZ" 	,,"Recno"						,"@ 99999999999999999999" 	} )

aCores := {}
aAdd(aCores,{cAli_RES+"->TPDOWL == ' '","BR_VERDE"	  })
aAdd(aCores,{cAli_RES+"->TPDOWL == 'R'","BR_MARROM"   })
aAdd(aCores,{cAli_RES+"->TPDOWL == 'E'","BR_VERMELHO" })
aAdd(aCores,{cAli_RES+"->TPDOWL == 'I'","BR_CANCEL"   })
aAdd(aCores,{cAli_RES+"->TPDOWL == 'A'","BR_LARANJA"  })	//FR - 16/10/2020

dbSelectArea(cAli_RES)
//COUNT TO nQtdReg 
//(cAli_RES)->( dbSetORder( 3 ) )   //FR 04/09/2020   //1-CHAVE; 2-NOTA; 3-DTNFE; 4-OK+CHAVE
(cAli_RES)->( dbSetORder( 2 ) )    	//FR 04/09/2020   //1-CHAVE; 2-NOTA; 3-DTNFE; 4-OK+CHAVE
(cAli_RES)->( dbGotop() )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apresenta botao se nao for visualizacao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aButtons,{'CHECKED' ,{ || HFXML06Inv(cMarcaOK,@oMarkBw) }, "Inverter Marcação", "Inverter"})
aAdd(aButtons,{'DESTINOS',{ || HFXML06Inv(cMarcaOK,@oMarkBw,.T.) }, "Marcar todas as Notas", "Marc Todos"})
aAdd(aButtons,{          ,{ || HFXML06Leg() }, "Legenda", "Legenda"})
aAdd(aButtons,{          ,{ || HFXML06Ind(cMarcaOK,@oMarkBw) }, "Marcar/Desmarcar Indisponivel", "Flag Indisponivel"})
//aAdd(aButtons,{          ,{ || HFXML06Vis() }, "Visualizar Registro", "Visualizar"		 })
//aAdd(aButtons,{          ,{ || HFXML06Exc() }, "Excluir da Analise", "Excluir da Analise"})
//aAdd(aButtons,{          ,{ || HFXML69Imp() }, "Imprimir", "Imprimir"})
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
DEFINE MSDIALOG oDlg01 TITLE "Download XML Completo" FROM 000,000 TO 430,800 OF oMainWnd PIXEL 

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
oMarkBw:=MsSelect():New(cAli_RES,"OK","",aCpos,@lInverte,@cMarcaOK,{17,10,150,400},,,,,aCores) //oFolder:aDialogs[1]

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
{|lEnd| oProcess := MsNewProcess():New({|lEnd| HFXML69Dow(@oMarkBw,@lEnd,@oProcess,cMarcaOK,.T.,"")}, "Baixar...","Baixando XML ..."),oProcess:Activate() },;
{|| iif( msgYesNo("Sair Download XML ?","Pegunta"),oDlg01:End(),lOk := .F. )},,aButtons)

RestArea(aArea)

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
(cAli_RES)->( dbGotop() )
Do while (cAli_RES)->( !EOF() )

	If lMarkAll
	
		RecLock(cAli_RES, .F.)
		(cAli_RES)->OK	:= cMarcaOK 
		(cAli_RES)->( MsUnLock() )
		
	Else
	
		If  (cAli_RES)->OK == cMarcaOK
		
			RecLock(cAli_RES, .F.)
			
			(cAli_RES)->OK	:= "  "
			(cAli_RES)->( MsUnLock() )
			
		Else
		
			RecLock(cAli_RES, .F.)
			
			(cAli_RES)->OK	:= cMarcaOK
			(cAli_RES)->( MsUnLock() )
			
		EndIf
		
	EndIf

	(cAli_RES)->( dbSkip() )
	
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

AADD(aLegenda,{"BR_VERMELHO","Download com erro."     })
AADD(aLegenda,{"BR_MARROM"	,"Download XML Resumo."   })
AADD(aLegenda,{"BR_CANCEL"	,"Download Indisponivel." })
AADD(aLegenda,{"BR_VERDE" 	,"Download XML Completo." })
AADD(aLegenda,{"BR_LARANJA" ,"Download em Espera."    })

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

Local cChave := (cAli_RES)->CHAVE
Local cSt    := "89"

DbSelectArea(xZBS)
(xZBS)->( dbSetOrder( 3 ) )

if (xZBS)->( dbSeek( Substr( cChave,1,44 ) ) )

	If U_MyAviso("Pergunta","Deseja Excluir da Analise de Inconsistências (Retorno 137 SEFAZ) o XML "+AllTrim( (xZBS)->(FieldGet(FieldPos(xZBS_+"CHAVE"))) )+" ?",{"SIM","NÃO"},3) == 1
		
		RecLock(xZBS,.F.)
		( xZBS )->(FieldPut(FieldPos(xZBS_+"ST")	, cSt ))
		( xZBS )->( MsUnlock() )
		
		DbSelectArea(cAli_RES)
		RecLock( cAli_RES, .F. )
		
		(cAli_RES)->( DbDelete() )
		(cAli_RES)->( MsUnLock() )
		
	EndIf
	
Else

	U_MyAviso("Atenção","Não Encontrado",{"OK"},3) == 1
	
Endif

DbSelectArea(cAli_RES)

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
@ 018,010 Get oObj VAR (cAli_RES)->CHAVE SIZE 150,08 When .F. PIXEL OF oPage:aDialogs[nPageGer]                   

@ 040,010 Say "CNPJ Destinatário: "  PIXEL OF oPage:aDialogs[nPageGer] COLOR CLR_BLUE FONT oFont01
@ 048,010 Get oObj VAR (cAli_RES)->DEST SIZE 150,08 When .F. PIXEL OF oPage:aDialogs[nPageGer] 

@ 070,010 Say "Mensagem Retorno WS: "  PIXEL OF oPage:aDialogs[nPageGer] COLOR CLR_BLUE FONT oFont01
@ 078,010 Get oObj VAR (cAli_RES)->MSG SIZE 150,08 When .F. PIXEL OF oPage:aDialogs[nPageGer] 

@ 100,010 Say "Mensagem Erro WS: "  PIXEL OF oPage:aDialogs[nPageGer] COLOR CLR_BLUE FONT oFont01
@ 108,010 Get oObj VAR (cAli_RES)->ERRO MULTILINE SIZE 300,50 When .F. PIXEL OF oPage:aDialogs[nPageGer] 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 00.5,00.5 To 012,043 OF oPage:aDialogs[nPageNfe]

@ 010,010 Say "Manifestação do Destinatário: " PIXEL OF oPage:aDialogs[nPageNfe] COLOR CLR_BLUE FONT oFont01
@ 018,010 Get oObj VAR (cAli_RES)->CSITCONF SIZE 10,08 When .F. PIXEL OF oPage:aDialogs[nPageNfe]                   
@ 018,030 Say "0=S/Manif.     1=Conf.Oper." PIXEL OF oPage:aDialogs[nPageNfe] COLOR CLR_BLUE FONT oFont03
@ 022,030 Say "2=Desconhecida 3=Oper.Não Real. 4=Ciência" PIXEL OF oPage:aDialogs[nPageNfe] COLOR CLR_BLUE FONT oFont03

@ 010,170 Say "CNPJ Emitente: "  PIXEL OF oPage:aDialogs[nPageNfe] COLOR CLR_BLUE FONT oFont01
@ 018,170 Get oObj VAR (cAli_RES)->CNPJ_EMI SIZE 150,08 When .F. PIXEL OF oPage:aDialogs[nPageNfe] 

@ 040,010 Say "Data Emissão: "  PIXEL OF oPage:aDialogs[nPageNfe] COLOR CLR_BLUE FONT oFont01
@ 048,010 Get oObj VAR (cAli_RES)->DEMI SIZE 150,08 When .F. PIXEL OF oPage:aDialogs[nPageNfe] 

@ 040,170 Say "Emitente: "  PIXEL OF oPage:aDialogs[nPageNfe] COLOR CLR_BLUE FONT oFont01
@ 048,170 Get oObj VAR (cAli_RES)->XNOME SIZE 150,08 When .F. PIXEL OF oPage:aDialogs[nPageNfe] 

@ 070,010 Say "Valor da NFe: "  PIXEL OF oPage:aDialogs[nPageNfe] COLOR CLR_BLUE FONT oFont01
@ 078,010 Get oObj VAR AllTrim( Str( (cAli_RES)->VNF) ) SIZE 150,08 When .F. PIXEL OF oPage:aDialogs[nPageNfe] 

@ 070,170 Say "IE Emitente: "  PIXEL OF oPage:aDialogs[nPageNfe] COLOR CLR_BLUE FONT oFont01
@ 078,170 Get oObj VAR (cAli_RES)->IE SIZE 150,08 When .F. PIXEL OF oPage:aDialogs[nPageNfe] 

@ 100,010 Say "Validação: "  PIXEL OF oPage:aDialogs[nPageNfe] COLOR CLR_BLUE FONT oFont01
@ 108,010 Get oObj VAR (cAli_RES)->DIGVAL SIZE 150,08 When .F. PIXEL OF oPage:aDialogs[nPageNfe] 

@ 100,170 Say "Autorização: "  PIXEL OF oPage:aDialogs[nPageNfe] COLOR CLR_BLUE FONT oFont01
@ 108,170 Get oObj VAR (cAli_RES)->DHRECBTO SIZE 150,08 When .F. PIXEL OF oPage:aDialogs[nPageNfe] 

@ 130,010 Say "NSU: "  PIXEL OF oPage:aDialogs[nPageNfe] COLOR CLR_BLUE FONT oFont01
@ 138,010 Get oObj VAR (cAli_RES)->NSU SIZE 150,08 When .F. PIXEL OF oPage:aDialogs[nPageNfe] 

@ 130,170 Say "Situação NFe: "  PIXEL OF oPage:aDialogs[nPageNfe] COLOR CLR_BLUE FONT oFont01
@ 138,170 Get oObj VAR (cAli_RES)->CSITNFE SIZE 10,08 When .F. PIXEL OF oPage:aDialogs[nPageNfe] 
@ 140,190 Say "1=Uso autorizado 2=Uso denegado 3=NF-e cancelada" PIXEL OF oPage:aDialogs[nPageNfe] COLOR CLR_BLUE FONT oFont03

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 00.5,00.5 To 012,043 OF oPage:aDialogs[nPageCce]
@ 010,010 Say "Carta de Correção: "  PIXEL OF oPage:aDialogs[nPageCce] COLOR CLR_BLUE FONT oFont01
@ 018,010 Get oObj VAR (cAli_RES)->Correcao MULTILINE SIZE 310,140 When .F. PIXEL OF oPage:aDialogs[nPageCce] 

@ 012,355 Button "Sair" Size 040,015 PIXEL OF oDlg ACTION oDlg:End()

ACTIVATE MSDIALOG oDlg CENTERED ON INIT (nOpca := 0,.T.)

Return(NIL)



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³HFXML69Dow³ Autor ³ Nelson Mandela        ³ Data ³ 03/10/18 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Download das Chaves                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HFXML69Dow()                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function HFXML69Dow(oMarkBw,lEnd,oRegua,cMarcaOK,lMostra,cLogProc) //oProcess

Local nReg   := (cAli_RES)->( recno() )
Local aArea  := GetArea()
Local nMar   := 0
//Local cAmb   := ""
//Local cCnpj  := SM0->M0_CGC  //"61135471000100"
//Local cIdEnt := U_GetIdEnt()
//Local cDir   := AllTrim(SuperGetMv("MV_X_PATHX"))
Local lRet	 := .F.
Local nVezes := 1    							//FR - 04/09/2020
Local nRetDow:= 0       						//FR - 04/09/2020 
Local nEspera:= GetNewPar("XM_ITSLEEP",10000)	//FR - 04/09/2020
Local nTotTent:= GetNewPar("XM_TENTSEND", 5 )   //FR - 04/09/2020
Local lContinua:= .T.							//FR - 04/09/2020
Local cChave   := ""							//FR - 04/09/2020  
Local lVazio   := .F.							//FR - 04/09/2020
Local xRetSef  := ""							//FR - 15/09/2020
Local cURL     := ""							//FR - 22/09/2020
Local cModelo  := ""							//FR - 22/09/2020
Local cProtocolo:= ""							//FR - 22/09/2020
Local cMensagem:= ""							//FR - 22/09/2020
Local cCodRet  := ""							//FR - 22/09/2020
Local xManif   := ""							//FR - 22/09/2020
Local lProssegue:= .T.							//FR - 16/10/2020
Local nTempoResta:= 0							//FR - 16/10/2020
cURL		   := AllTrim(GetNewPar("XM_URL",""))

If Empty(cURL)
	cURL  := AllTrim(SuperGetMv("MV_SPEDURL"))	
EndIf

If lMostra

	oRegua:SetRegua1( (cAli_RES)->( RecCount() ))
	oRegua:SetRegua2(0)
	
EndIF

(cAli_RES)->( dbSetORder( 1 ) )
(cAli_RES)->( dbgotop() )

Do While .NOT. (cAli_RES)->( Eof() )
	aVerRedown := {}
	If lMostra
	
		if lEnd
		
			MsgStop("*** Cancelado pelo Operador ***","Fim")
			Exit
			
		endif
		
		oRegua:IncRegua1("Processando Download das Chaves")
		oRegua:IncRegua2((cAli_RES)->CHAVE)
		
	EndIF
	
	If ! Empty( (cAli_RES)->OK )

		nMar++

		If Substr((cAli_RES)->CHAVE,21,2) $ "57,67"
	//		nRet := HFXML69Bai(cCnpj,(cAli_RES)->CHAVE,cAmb,cIdEnt)
		Else
			If (cAli_RES)->TPDOWL <> "I"
				//nRet := HFXML69B55(cCnpj,(cAli_RES)->CHAVE,cAmb,cIdEnt,(cAli_RES)->NSU,lMostra,@cLogProc)
				//lRet := U_HFDGXML( (cAli_RES)->CHAVE, .T. , .F. , NIL , "" , 0 , "2" ) > 0     //HEVERTON
				
				//FR - 04/09/2020				
				cChave := (cAli_RES)->CHAVE
				cModelo:= (cAli_RES)->MODEL
				
				U_HFXML071(cChave) // Valida se pode continuar com a requisição ao SEFAZ 
				If !lConsReq
					lRet := .F.
					lProssegue:= .F.
					Return(lRet)
				EndIf
				
				Sleep(nEspera)
				
				//FR - 16/10/2020
				aVerRedown := U_fPodeRedown(cChave)	
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
				
					lRet := U_FREDownXML( Alltrim(cChave) )    //FR - função para redownload, genérica, está no fonte HFXML02P
						 
					If lRet //se conseguiu fazer o redownload, manifesta
						
						DbSelectArea(xZBZ)
						Dbgoto( (cAli_RES)->RECZBZ )
						cProtocolo := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"PROTC"))) 
						
						//grava manifestação					      
						//Manifesta e Verifica se o parametro esta habilitado para manifestar na pre nota
						if FieldPos(xZBZ_+"MANIF") 

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
						
						//grava tipo da rotina: M-Manual ; J-Job aqui no caso é Manual
						If Reclock(xZBZ,.F.)
							(xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPROT"), "M" ))		//GRAVAR COMO M-Manual, pois esta rotina é chamada manualmente pelo usuário
						    (xZBZ)->( MsUnlock() )
						Endif
						 						
					Endif  //lRet				
					//FR - 04/09/2020 
														
					RecLock( cAli_RES, .F. )				
				
					If lRet
						xRetSef := U_fVerZBE(cChave,"")	//"A"-acerto
						(cAli_RES)->TPDOWL    := " "	 //muda a legenda para verde caso download OK
						(cAli_RES)->RETSEF    := xRetSef 
					Else
						(cAli_RES)->TPDOWL    := "E"     //muda a legenda para vermelho caso nf com problema (ex: denegada, cancelada)
						xRetSef := U_fVerZBE(cChave,"E")       //"E"-erro
						(cAli_RES)->RETSEF    := xRetSef 
					EndIf				
					
					(cAli_RES)->DREDOW		  := dDatabase 								//FR - 16/10/2020
					(cAli_RES)->HREDOW		  := cHoragora 								//FR - 16/10/2020 					
									
					(cAli_RES)->( MsUnLock() ) 
					
					//FR - 22/09/2020 - atualiza status
					DbSelectArea(xZBZ)
					Dbgoto( (cAli_RES)->RECZBZ )
					cProtocolo := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"PROTC")))
					
					if GetNewPar( "XM_DFE", "0" ) == "2"

						lValidado := u_NFeConsProt( cChave, .F., @cCodRet, @xManif )

						//lValidado := U_XConsXml(cURL,cChaveXml,cModelo,cProtocolo,@cMensagem,@cCodRet,AllTrim(SuperGetMv("MV_MOSTRAA")) == "S",,,@xManif) //GETESB2
			
					else

						lValidado := U_XConsXml(cURL,cChave,cModelo,cProtocolo,@cMensagem,@cCodRet,.F.,,,@xManif)
						//lValidado := U_XConsXml(cURL,cChave,cModelo,cProtocolo,@cMensagem,@cCodRet,.F.,,,@xManif)
					
					endif 
					
					If !Empty(cCodRet)
						U_XMLSETCS(cModelo,cChave,cCodRet,cMensagem,xManif)
					Endif 
							
				Else
				
					RecLock( cAli_RES, .F. )				
					(cAli_RES)->PROXRED		  := Dtoc(dDatabase) + " - " + cProxHora 
					(cAli_RES)->TPDOWL        := 'A' 		//FR - 16/10/2020 - muda a legenda para identificar que o download está aguardando o tempo mínimo de espera
					(cAli_RES)->( MsUnLock() ) 					
					
				Endif //lProssegue
								
				DelClassIntf()				
			EndIf		//If (cAli_RES)->TPDOWL <> "I"	
		EndIf

	EndIf

	(cAli_RES)->( dbSkip() )
	
EndDo

//(cAli_RES)->( dbSetORder( 1 ) )
(cAli_RES)->( dbSetORder( 2 ) )    //FR 04/09/2020   //1-CHAVE; 2-NOTA; 3-DTNFE; 4-OK+CHAVE
(cAli_RES)->( dbgoto( nReg ) )

if nMar == 0

	If lMostra
	
		U_MyAviso("Msg","Nenhuma Chave Selecionada !!!!",{"OK"},3)
		
	Else
	
		cLogProc += "Nenhuma Chave Encontrada via Problemas Resposta SEFAZ !!!!"
		
	Endif
	
endif

If lMostra .And. oMarkBw <> NIL

	oMarkBw:oBrowse:Refresh(.T.)
	
Endif

RestArea( aArea )

Return( NIL )

//+-----------------------------------------------------------------------------------//
//|Funcao....: HFXML69B55
//|Autoria...: Heverton Marcondes - 16/10/2020
//|Descricao.: Rotina de download
//|Observação: 
//+-----------------------------------------------------------------------------------//
Static Function HFXML69B55(cCnpj,cChave,cAmb,cIdEnt,cNsu,lMostra,cLogProc)

Local nRet   := 2
Local nChv   := 0
Local cDir   := AllTrim(SuperGetMv("MV_X_PATHX"))
Local cXml   := ""
Local cInfo  := ""
Local cMsg   := ""
Local cStt   := ""
Local nHandle:= 0
//Local lOk    := .T.
Local dDtEmi := ctod( "" )
Local cChaveArq := ""
Local aAreaZBS := (xZBS)->( GetArea() )

Default lMostra  := .T.
Default cLogProc := ""

Private oWs,oWsrNfe,oWsdNfe,cErro:="",cWarning:="", aEnvNfe := {}

Do While .T.

	(xZBZ)->( dbSetOrder( 3 ) )
	if (xZBZ)->( dbSeek( Substr( cChave,1,44 ) ) )
		dDtEmi := ( xZBS )->(FieldGet(FieldPos(xZBS_+"DEMI")))
		if (xZBZ)->( FieldPos( xZBS_+"XML" ) ) > 0
			if ! Empty(( xZBS )->(FieldGet(FieldPos(xZBZ_+"XML"))))
				cXml := ( xZBZ )->(FieldGet(FieldPos(xZBZ_+"XML")))
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
					
					DbSelectArea(cAli_RES)	
									
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
		
			xRet := HFDOWCHV( cCnpj,cChave,cAmb,cIdEnt,@cLogProc )   //Pedir Pela Chave
			
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

	//Caso for nil faz a segunda checagem somente para aqueles xml´s que tem caracteres especiais
	if oXML == NIL 

		//Faz backup do xml sem retirar os caracteres especiais
		cBkpXml := cXml

		cXml := fWNOAccent(cXml)  //NoAcento(cXml)
		cXml := EncodeUTF8(cXml)

		//Executa rotina para retirar os caracteres especiais
		cXml := u_zCarEspec( cXml )

		if Len(cXml) >= 65534

			oXML := U_PARSGDE( cXml, @cErro, @cWarning )

		Else

			oXML := XmlParser( cXml, "_", @cErro, @cWarning )

		endif

		//retorna o backup do xml
		cXml := cBkpXml

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

DbSelectArea(cAli_RES)
RecLock( cAli_RES, .F. )

(cAli_RES)->ST    := cStt
(cAli_RES)->MSG   := cMsg
(cAli_RES)->ERRO  := cInfo

(cAli_RES)->( MsUnLock() )

DelClassIntf()

return( nRet )

//+-----------------------------------------------------------------------------------//
//|Funcao....: slvxmlzbz
//|Autoria...: Heverton Marcondes - 16/10/2020
//|Descricao.: Salva o xml depois do download
//|Observação: 
//+-----------------------------------------------------------------------------------//
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

//+-----------------------------------------------------------------------------------//
//|Funcao....: HFDOWCHV
//|Autoria...: Heverton Marcondes - 16/10/2020
//|Descricao.: Chama Webservices
//|Observação: 
//+-----------------------------------------------------------------------------------//
Static Function HFDOWCHV( cCnpj,cChave,cAmb,cIdEnt,cLogProc )

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
//Local cVerLayEven := "1.00"
//Local cHrVerao    := "2"
//Local cHorario    := "2"
Local ni := 0 //declaracao
Local lHF := .T.
Local cSt       := ""
Local cSitConf  := ""
Local cChaveXml := ""
Local cNf       := ""
Local cSer      := ""
Local cCnpjXml  := ""

Private oWs,oWsrNfe,oWsdNfe,cErro,cWarning

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


//+-----------------------------------------------------------------------------------//
//|Funcao....: HFXML69Imp
//|Autoria...: Heverton Marcondes - 16/10/2020
//|Descricao.: Imprimir os dados caso queiram
//|Observação: 
//+-----------------------------------------------------------------------------------//
Static Function HFXML69Imp()

Local aArea := GetArea()
Local oReport   := NIL

oReport := ReportDef(cTMP_RES,"HFXML061")

oReport:PrintDialog() 

RestArea( aArea )

Return( NIL )


//+-----------------------------------------------------------------------------------//
//|Funcao....: reportdef
//|Autoria...: Heverton Marcondes - 16/10/2020
//|Descricao.: Função de Impressão
//|Observação: 
//+-----------------------------------------------------------------------------------//
Static Function reportdef(cAlias,cPerg)

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


//+-----------------------------------------------------------------------------------//
//|Funcao....: ReportPrint
//|Autoria...: Heverton Marcondes - 16/10/2020
//|Descricao.: Função de Impressão
//|Observação: 
//+-----------------------------------------------------------------------------------//
Static Function ReportPrint(oReport,cAlias)

    local oSection1  := oReport:Section(1)
    
    oReport:SetMeter((cAlias)->(recCount()))
    
    oSection1:Print()
    
return


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
Static Function HFXML06Ind(cMarcaOK,oMarkBw)

Local aGetArea	:= GetArea()
Local lMarcSim	:= .F.
Local cFlag		:= ""


DbSelectArea(xZBZ)
(xZBZ)->( dbSetOrder( 3 ) )

lMarcSim := Aviso( "Marcar/Desmarcar", "Deseja marcar ou desmarcar como indisponivel?", { "Marcar", "Desmarcar" } ) == 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ While para marcar ou desmarcar os produtos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
(cAli_RES)->( dbGotop() )
Do while (cAli_RES)->( !EOF() )
	
	If  (cAli_RES)->OK == cMarcaOK .AND. (cAli_RES)->TPDOWL <> " "
	
		RecLock(cAli_RES, .F.)
			(cAli_RES)->TPDOWL	:= IIF(lMarcSim,"I","R")
		(cAli_RES)->( MsUnLock() )
			
		If (xZBZ)->( dbSeek( Substr( (cAli_RES)->CHAVE,1,44 ) ) )
			
			cFlag := IIF(lMarcSim,"I","R")

			RecLock(xZBZ,.F.)
				( xZBZ )->(FieldPut(FieldPos(xZBZ_+"TPDOWL")	, cFlag ))
			( xZBZ )->( MsUnlock() )
						
		Endif
	
	EndIf
		
	(cAli_RES)->( dbSkip() )
	
EndDo

oMarkBw:oBrowse:Refresh(.T.)

RestArea( aGetArea )

Return


//+-----------------------------------------------------------------------------------//
//|Funcao....: fVerZBE
//|Autoria...: Flávia Rocha - 16/10/2020
//|Descricao.: Função para obter a descrição do evento gravado na ZBE em caso de erro 
//|            de redownload 
//|Observação: 
//+-----------------------------------------------------------------------------------//
User Function fVerZBE(cChave, cTipo)

Local cRetSef := "" 
Local cQuery  := ""
Local LF      := CHR(13) + CHR(10)
Private xZBE  := GetNewPar("XM_TABEVEN","ZBE")
Private xZBE_ := iif(Substr(xZBE,1,1)=="S", Substr(xZBE,2,2), Substr(xZBE,1,3)) + "_" 
/*
(xZBE)->(OrdSetFocus(2))    //ZBE_CHAVE
If cTipo == "E" //Erro 
	If (xZBE)->( Dbseek(cChave) )
		While (xZBE)->(!Eof()) .and. Alltrim( ( xZBE )->(FieldGet(FieldPos(xZBE_+"CHAVE"))) ) == Alltrim(cChave)
			If Alltrim( ( xZBE )->(FieldGet(FieldPos(xZBE_+"TPEVE"))) ) == "HXL069" 	//grava este código no caso de erro, fiz assim para distinguir
				cRetSef := Alltrim( ( xZBE )->(FieldGet(FieldPos(xZBE_+"DESC"))) )   //pegará sempre o último
			Endif		
			(xZBE)->(Dbskip())
		Enddo
	Endif
		
Else 
	If (xZBE)->( Dbseek(cChave) )	
		While (xZBE)->(!Eof()) .and. Alltrim( ( xZBE )->(FieldGet(FieldPos(xZBE_+"CHAVE"))) ) == Alltrim(cChave)
			If Alltrim( ( xZBE )->(FieldGet(FieldPos(xZBE_+"TPEVE"))) ) != "HXL069" 	//grava este código no caso de erro, fiz assim para distinguir
				cRetSef := Alltrim( ( xZBE )->(FieldGet(FieldPos(xZBE_+"DESC"))) )   				//pegará sempre o último			
			Endif
			(xZBE)->(Dbskip())
		Enddo

	Endif 
	
Endif
*/

cQuery := ""
cQuery += " SELECT " + xZBE_+"DESC " + LF //"+xZBE_+"CHAVE as CHAVE, "+xZBE_+"DESC as DESC,  "+xZBE_+"TPEVE as TPEVE " + LF
cQuery += " FROM " + RetSqlName(xZBE) + " ZBE "	+ LF
cQuery += " WHERE ZBE.D_E_L_E_T_ <> '*' "	+ LF
cQuery += " AND RTRIM( "+xZBE_+"CHAVE ) = '"+ Alltrim(cChave)+"' "+ LF

If cTipo == "E"
	cQuery += " AND "+xZBE_+"TPEVE = 'HXL069' "+ LF  	//erro
Else                                               
	cQuery += " AND "+xZBE_+"TPEVE <> 'HXL069' "+ LF  	//acerto
Endif
cQuery += " ORDER BY "+xZBE_+"DTHRGR DESC "
 
MemoWrite("C:\TEMP\fVerZBE.sql" , cQuery)

If Select("TMPZBE") > 0
	dbSelectArea("TMPZBE")
    TMPZBE->(dbCloseArea())
EndIf

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TMPZBE", .T., .F. )
DbSelectArea("TMPZBE")
DbGoTop()
If TMPZBE->(!Eof())
 	cRetSef := Alltrim(TMPZBE->&(xZBE_+"DESC"))
   	dbSelectArea("TMPZBE")
    TMPZBE->(dbCloseArea()) 	
Endif  

Return(cRetSef)


//+-----------------------------------------------------------------------------------//
//|Funcao....: fLoadPars
//|Autoria...: Flávia Rocha - 16/10/2020
//|Descricao.: Carrega os parâmetros contidos no xml mestre da licença da empresa
//|Observação: 
//+-----------------------------------------------------------------------------------//
User Function fLoadPars(aParams,cError,lDefault)
Local lRet       := .T.
Local cFileCfg   := "hfcfgxml001a.xml"
Local aDados     := {}
Local Nx := 0 //declaracao 
Private oXml

Default lDefault := .F.
                 
If File(cFileCfg)

	oXml := U_LoadCfgX(1,cFileCfg,)

	If oXml == Nil
	
		Return	
		
	EndIf
	
	cENABLE  := AllTrim(oXml:_MAIN:_WFXML01:_ENABLE:_XTEXT:TEXT)
	cENT     := AllTrim(oXml:_MAIN:_WFXML01:_ENT:_XTEXT:TEXT)
	nWFDELAY := Val(oXml:_MAIN:_WFXML01:_WFDELAY:_XTEXT:TEXT)
	cTHREADID:= AllTrim(oXml:_MAIN:_WFXML01:_THREADID:_XTEXT:TEXT)
	nSLEEP   := Val(oXml:_MAIN:_WFXML01:_SLEEP:_XTEXT:TEXT)
	cConsole := AllTrim(oXml:_MAIN:_WFXML01:_CONSOLE:_XTEXT:TEXT)

	If Type("oXml:_MAIN:_WFXML01:_JOBS:_JOB") == "U"
		
		aJobs    := {}
		
    ElseIf ValType(oXml:_MAIN:_WFXML01:_JOBS:_JOB) == "A"
    
		aJobs    := oXml:_MAIN:_WFXML01:_JOBS:_JOB  
		  
	Else
	
		aJobs    := {oXml:_MAIN:_WFXML01:_JOBS:_JOB}	
		
	EndIf

	cJOBS := ""
	
	For Nx := 1 To Len(aJobs)
	
		cJOBS += aJobs[Nx]:_XTEXT:TEXT
		
		If Nx < Len(aJobs)
		
			cJOBS    += ","
			
		EndIf		
				
	Next	
	
	Aadd(aDados,{"ENABLE"  ,cENABLE   		,"Servico Habilitado" 					}) 
	Aadd(aDados,{"ENT"     ,{cENT}  		,"Empresa/Filial principal do processo" }) 
	Aadd(aDados,{"WFDELAY" ,nWFDELAY   		,"Atraso apos a primeira execucao"   	}) 
	Aadd(aDados,{"THREADID",cTHREADID  		,"Identificador de Thread [Debug]"   	}) 
	Aadd(aDados,{"JOBS"    ,cJOBS   		,"Servico a ser processado" 			}) 
	Aadd(aDados,{"SLEEP"   ,nSLEEP    		,"Tempo de espera"   					}) 
	Aadd(aDados,{"CONSOLE" ,cConsole   		,"Informacoes dos processos no console" }) 

Else	

	Aadd(aDados,{"ENABLE"  ,"1"		   		,"Servico Habilitado" 					}) 
	Aadd(aDados,{"ENT"     ,{"99"}  		,"Empresa/Filial principal do processo" }) 
	Aadd(aDados,{"WFDELAY" ,10 		   		,"Atraso apos a primeira execucao"   	}) 
	Aadd(aDados,{"THREADID","1"		   		,"Identificador de Thread [Debug]"   	}) 
	Aadd(aDados,{"JOBS"    ,"X"		   		,"Servico a ser processado" 			}) 
	Aadd(aDados,{"SLEEP"   ,30000	 		,"Tempo de espera"   					}) 
	Aadd(aDados,{"CONSOLE" ,"1"		   		,"Informacoes dos processos no console" }) 

EndIf                      

aParams := aDados

Return(lRet)           

//+-----------------------------------------------------------------------------------//
//|Funcao....: fPodeRedown
//|Autoria...: Flávia Rocha - 16/10/2020
//|Descricao.: verifica a data/hora do último download para permitir novo redownload 
//|Observação: 
//+-----------------------------------------------------------------------------------//
User Function fPodeRedown(xChave)
Local lProssegue := .F.
Local cHoragora  := ""
Local cHoraZBZ   := ""
Local nH1		 := 0
Local nM1		 := 0
Local nH2		 := 0
Local nM2		 := 0
Local nDifHr	 := 0
Local nDifMn     := 0
Local nDifTt     := 0
Local nSleepJob  := 0
Local nEspera    := 0
Local dUltRedow  := Ctod("  /  /    ")
Local aParams	 := {}
Local cError 	 := ""
Local aRet       := {}

Private xZBZ     := GetNewPar("XM_TABXML","ZBZ")
Private xZBZ_    := iIf(Substr(xZBZ,1,1)=="S", Substr(xZBZ,2,2), Substr(xZBZ,1,3)) + "_"

U_fLoadPars(@aParams,@cError,.T.)
                                    
//cEnable           := aParams[1][2]
//aEntidades        := aParams[2][2]
//nStartUp        	:= aParams[3][2]
//cThreadID	     	:= aParams[4][2]
nSleepJob           := aParams[6][2]
cHoragora			:= ""
cHoraZBZ			:= ""
nEspera				:= 0

(xZBZ)->(OrdSetFocus(3))
(xZBZ)->( dbSeek( xChave ) ) 

dUltRedow := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"DREDOW"))) 		//data do último redownload 

/*  
ELAPTIME( <hora inicial>, <hora final> )
as horas precisam estar no formato: hh:mm:ss SENÃO ocorre erro fatal
resultado: caracter do tempo decorrido, ex: "02:30:15" que corresponde a 2h, 30min, 15s
*/

if !Empty(dUltRedow)

	If ( Date() - dUltRedow ) >= 1		//Se o último redownload foi realizado "ontem" já permite fazer um novo
	
		lProssegue := .T.

	Else								//Caso contrário, calcula pela última hora e minuto obedecendo o tempo de espera no parâmetro "Tempo de Espera" contido na tela F12 do Importa				
		
		cHoragora := Time()											
		cHoraZBZ  := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"HREDOW")))  			
							
		//diferença entre a hora agora e a hora em que foi executado o último redownload
		//ex: 19h - 18h = 1h -> 60min -> 3600 segundos transforma a diferença entre as horas em segundos
		//ex: 17:50 -> 50 = 3000  ;   //17:20 -> 20 = 1200 -> diferença = 1800 segundos
		//ex: 0 + 1800
		
		nEspera:= (nSleepJob / 1000) 	//transforma nSleepJob de milisegundos para segundos, dividindo por 1000, ex: 60.000 / 1000 = 60s (1 min)
		
		//calcula a diferença entre a hora agora e a hora do último redownload (desde que este tenha sido feito no mesmo dia)
		cElapsed := ""
		cElapsed := ELAPTIME( cHoraZBZ + ":00" , cHoragora  )  //ex: cElapsed resultou em 02h:18m:05s
		nH1      := ( Val(substr(cElapsed,1,2)) * 60 ) * 60    //transforma tudo em segundos    02 -> 120min -> 7200s
		nM1      := ( Val(substr(cElapsed,4,2)) * 60 )         //transfroma tudo em segundos    18 -> ...    -> 1080s
		nS1      := ( Val(substr(cElapsed,7,2))  )             //idem                           05 -> ...    -> 0005s
		nDifTt   := nH1 + nM1 + nS1                            //8285s
		
		//outro ex: cElapsed resultou em 00h:30m:10s ou sejam 30min e 10s
		//00h -> 0s
		//30m -> 1800s
		//10s -> 10s
		//total: 1810s
		
		lProssegue := nDifTt >= nEspera	   				//8285s > 60s -> .T.
		
	Endif

else

	lProssegue := .T.

endif

Aadd(aRet, lProssegue)
Aadd(aRet, nEspera )

Return(aRet)


//+-----------------------------------------------------------------------------------//
//|Funcao....: fCalcProxHr
//|Autoria...: Flávia Rocha - 16/10/2020
//|Descricao.: Calcula a hora do próximo download, respeitando o tempo de espera
//|            definido nos parâmetros da tela F12 do Importa 
//|Observação: 
//+-----------------------------------------------------------------------------------//
User Function fCalcProxHr(cHoragora,nTempoResta)
Local cProxHr := ""  
Local nH1     := 0
Local nM1     := 0 
Local nS1     := 0
Local nProxHr := 0
Local nPos    := 0
Local cAux    := ""
Local cAux2   := ""
Local cAux3   := ""
//Vem por parâmetro cHoragora que é a hora recebida pela função Time()
//E a partir dela, soma o tempo contido na variável nTempoResta:
//nTempoResta vem em segundos, exemplo 1 = 60 segundos

nH1     := ( Val(substr(cHoragora,1,2)) * 60  ) * 60     //17:20 -> 17 * 60 * 60
nM1     := ( Val(substr(cHoragora,4,2)) * 60  )
nS1     := ( Val(substr(cHoragora,7,2))       ) 
nDifTt  := nH1 + nM1 + nS1      //transformou tudo em segundos
nDifTt  += nTempoResta
nProxHr := (nDifTt / 60) / 60
cHora01 := Alltrim(Str(nProxHr))  //ex: 
nPos    := At(".", cHora01)
//Monta os dígitos da hora:
cAux := Substr(cHora01,1, nPos-1) + ":"

//Monta os dígitos dos minutos:
nAux := Val( "0." + Substr(cHora01, nPos+1, Len(cHora01)- nPos ) ) 
nAux := Round(nAux * 60, 0 )
cAux2:= Alltrim(Str(nAux)) 

//caso os minutos tenham ficado só com um dígito:
If Len(cAux2) <= 1
	cAux3 := "0" + cAux2
	cAux2 := cAux3
Endif

cProxHr := cAux + cAux2 

Return(cProxHr)
