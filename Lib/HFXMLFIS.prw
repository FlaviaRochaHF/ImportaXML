#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "Ap5Mail.ch"
#INCLUDE "FILEIO.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "PRTOPDEF.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "XMLXFUN.CH"
#Include "TopConn.ch"
//#INCLUDE "INKEY.CH"

#DEFINE IMP_PDF 6
#DEFINE LF CHR(13)+CHR(10)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHFXMLFIS  บ Autor ณ Henrique Tofanelli บ Data ณ  30/01/2020 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Chamada para importa็ใo de informa็๕es Fiscais de arquivo  บฑฑ
ฑฑบ          ณ XML de Fornecedores.                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ IMPORTA XML                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
//--------------------------------------------------------------------------//
// Altera็๕es realizadas:
// Flแvia Rocha - 23/03/2020:
// Ajuste na rotina de grava็ใo da ZBT conforme solicitado pela Coferly
// estava ocorrendo replica็ใo de registros na tabela ZBT quando
// quando a chave nใo era encontrada.
//--------------------------------------------------------------------------//
// Flแvia Rocha - 03/07/2020:
// Ajuste para gravar o campo criado para a CCM: ZBZ_ORIPRT
// Uma vez que a rotina de download de xml grava este campo, procurei alinhar
// tamb้m na rotina aqui codificada de importa็ใo de informa็๕es fiscais
// de Xmls antigos jแ gravados na base.
//---------------------------------------------------------------------------//
/*/

User Function HFXMLFIS(cCodeOne,lOk)

Local oProcess	:= Nil
Local aPergs	:= {}
Local dDataDe	:= FirstDate(Date())
Local dDataAt	:= LastDate(Date())
//Local dVencLic	:= Ctod("  /  /    ")
Local aItens	:= {"1=Todos",;
					"2=Registros em Branco"}
Private aRet	:= {}
Private xZBZ	:= GetNewPar("XM_TABXML" ,"ZBZ")
Private xZBT	:= GetNewPar("XM_TABITEM","ZBT")

//lUsoOk := U_HFXML00X("HF000001","101",SM0->M0_CGC,,.F.)
lUsoOk	:= U_HFXMLLIC(.F.)

If !lUsoOk
	Return(Nil)
EndIf

//verifico se o usuario logado ้ do grupo de administradores
//Comentar esse trecho apenas para a Politec pois o usuario Marciano nao tem perfil admin.
If !(FWIsAdmin( __cUserID ) )
	MsgStop(' O usuแrio ' + __cUserID + ' nใo pertence ao grupo de administradores!')
	Return
Endif

cTexto := "Esta rotina atualiza o hist๓rico de dados Fiscais nos registros de Notas Baixadas (XML) "
cTexto += "conforme parโmetros, sendo limitado a 12 meses de cada vez.  "
cTexto += "Aconselhamos utilizar o processamento em modo exclusivo !!  "
cTexto += "Deseja continuar ?  "

//MSGALERT( cTexto, "Alerta - Processamento de Registros XML" )
If MsgYesNo(cTexto,"ATENวรO","YESNO")

	// ***********************************************************
	// * PARAMBOX - PARAMETROS DO PROCESSAMENTO     			 *
	// ***********************************************************

	aAdd(aPergs, {1, "Data De",  dDataDe,  "", ".T.", "", ".T.", 80,  .F.})
	aAdd(aPergs, {1, "Data At้", dDataAt,  "", ".T.", "", ".T.", 80,  .T.})
	AAdd(aPergs, {2, "Atualiza",	1,	aItens,	100,	"AllwaysTrue()",	.T.})

	lRet := ParamBox( aPergs , "Atualiza็ใo Fiscal - GestใoXML" , @aRet , NIL , NIL , .T. )

If ValType(aRet[3]) == "C"
	aRet[3] := Val(aRet[3])
EndIf
	nQtdDias := MV_PAR02 - MV_PAR01
	
	if nQtdDias > 365
	
		MsgStop('Processamento Limitado Para o Perํodo Mแximo de 01 ano !')
		
		Return
		
	EndIf
	
	If lRet
		oProcess := MsNewProcess():New({|lEnd| EXCPROC(@lEnd,@oProcess) },"Aguarde...","Analisando Arquivos XML",.T.)
		oProcess:Activate()
	Else  
		MsgInfo("Processo Cancelado Pelo Operador.")
	Endif

Else
	MsgInfo("Processo Cancelado Pelo Operador.")
	Return()		
EndIf
	
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ EXCPROC  บ Autor ณ Henrique Tofanelli บ Data ณ  30/01/2020 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ IMPORTA XML                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function EXCPROC(lEnd,oProcess)

Local cError	:= ""
Local cWarning	:= ""
Local nRec		:= 0
Local nTotReg	:= 0
Local nTotLen   := 0
Local i         := 0
Private xZBZ	:= GetNewPar("XM_TABXML","ZBZ")
Private xZBZ_	:= iif(Substr(xZBZ,1,1)=="S", Substr(xZBZ,2,2), Substr(xZBZ,1,3)) + "_"
Private xZBT	:= GetNewPar("XM_TABITEM","ZBT")		//Tabela de itens do xml
Private xZBT_	:= iif(Substr(xZBT,1,1)=="S", Substr(xZBT,2,2), Substr(xZBT,1,3)) + "_"
Private xZB5	:= GetNewPar("XM_TABAMAR","ZB5")		//Tabela Amarra็ใo de Produtos
Private xZB5_	:= iif(Substr(xZB5,1,1)=="S", Substr(xZB5,2,2), Substr(xZB5,1,3)) + "_"
Private xZBA	:= GetNewPar("XM_TABAMA2","ZBA")
Private xZBA_	:= iif(Substr(xZBA,1,1)=="S", Substr(xZBA,2,2), Substr(xZBA,1,3)) + "_"
Private xZBE	:= GetNewPar("XM_TABEVEN","ZBE")
Private xZBE_	:= iif(Substr(xZBE,1,1)=="S", Substr(xZBE,2,2), Substr(xZBE,1,3)) + "_"
Private xZBC	:= GetNewPar("XM_TABCAC","ZBC")
Private xZBC_	:= iif(Substr(xZBC,1,1)=="S", Substr(xZBC,2,2), Substr(xZBC,1,3)) + "_"
Private xZBO	:= GetNewPar("XM_TABOCOR","ZBO"), xRetSEF := ""
Private xZBO_	:= iif(Substr(xZBO,1,1)=="S", Substr(xZBO,2,2), Substr(xZBO,1,3)) + "_"
Private xZBI	:= GetNewPar("XM_TABIEXT","ZBI")
Private xZBI_	:= iif(Substr(xZBI,1,1)=="S", Substr(xZBI,2,2), Substr(xZBI,1,3)) + "_"

cQuery := QueryXmlF()
If Select("TMPXML") > 0
	DbSelectArea("TMPXML")
	DbCloseArea()
Endif
TCQuery cQuery New Alias "TMPXML"
Count to nTotReg

oProcess:SetRegua1( nTotReg )

oProcess:SetRegua2( nRec )

TMPXML->(DbGoTop())

//Verifica se ha dados na tabela temporaria
//--------------------------------//
//1o. LIMPA CAMPO ZBT_ITEM
//--------------------------------//
If TMPXML->(!Eof())
	//1o. LIMPEZA DO CAMPO ZBT_ITEM:
	
	While TMPXML->( !EoF() )
		
		oProcess:IncRegua1()
		oProcess:IncRegua2("Organizando Itens ....-> NF - "+TMPXML->NOTA+"/"+TMPXML->SERIE )
		If lEnd
			MsgStop("*** Cancelado pelo Operador ***","Fim")
			Exit
		EndIf

		DbSelectArea(xZBZ)
		DbGoto( TMPXML->ZRECNO )

		cChaveXml := (xZBZ)->&(xZBZ_ + "CHAVE")  //(xZBZ)->ZBZ_CHAVE
		cXml      := (xZBZ)->&(xZBZ_ + "XML")    //(xZBZ)->ZBZ_XML
		oXmlFIS   := XmlParser( cXml, "_", @cError, @cWarning )
		//FAZER O FILTRO NA ZBZ PARA CONTINUAR
		If TMPXML->MODELO $ "55,65" .and. !Empty( oXmlFis )
			                 
			//Limpa o campo ZBT_ITEM, para evitar dois ou mais registros com mesmo n๚mero de item, de grava็๕es anteriores
			DbSelectArea(xZBT)
			( xZBT )->( DbSetOrder( 2 ) )
			If ( xZBT )->( dbSeek( cChaveXml ) )
				While !(xZBT)->(EOF()) .and. (xZBT)->&(xZBT_+"CHAVE") == cChaveXml					 
					Reclock(xZBT,.F.)
					(xZBT)->(FieldPut(FieldPos(xZBT_+"ITEM"  ) , ""  ))					
					DbSelectArea(xZBT)
					MsUnLock()					
					(xZBT)->(dbskip())						
				Enddo
			Endif				
		Endif
		TMPXML->(dbskip())		
	Enddo

Else
	MsgInfo("Nใo hแ dados para o filtro selecionado!")
	Return
EndIf
 
//--------------------------------//
//2o. RE-ITEMIZA O CAMPO ZBT_ITEM:	  
//--------------------------------//
DbSelectArea("TMPXML")
TMPXML->(DbGoTop())
If ! TMPXML->(Eof())

	While TMPXML->( !EoF() )
		
		oProcess:IncRegua1()		
		oProcess:IncRegua2( "Reordenando Itens ....-> NF - " + TMPXML->NOTA +"/"+ TMPXML->SERIE )		
		If lEnd		
			MsgStop("*** Cancelado pelo Operador ***","Fim")
			Exit			
		EndIf 

		DbSelectArea(xZBZ)
		DbGoto( TMPXML->ZRECNO )

		cChaveXml := (xZBZ)->&(xZBZ_ + "CHAVE")  //(xZBZ)->ZBZ_CHAVE
		cXml      := (xZBZ)->&(xZBZ_ + "XML")    //(xZBZ)->ZBZ_XML

		oXmlFIS := XmlParser( cXml, "_", @cError, @cWarning )
		
		//FAZER O FILTRO NA ZBZ PARA CONTINUAR
		If TMPXML->MODELO $ "55,65" .and. !Empty( oXmlFis )
            
			//TRATAMENTO ZBZ
			cTAG := "NFE"
			cTGP := "NFE"
	       
			//TRATAMENTO ZBT
			//FAZER O FILTRO NA ZBT PARA CONTINUAR
			if Type( "oXmlFIS:_NFEPROC:_NFE:_INFNFE:_DET" ) != "U"
				oDet := oXmlFIS:_NFEPROC:_NFE:_INFNFE:_DET
				oDet := IIf(ValType(oDet)=="O",{oDet},oDet)				
			else			
				oDet := {}				
			endif
			
			cTagAux := "oXmlfis:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_IDE:_SERIE:TEXT"               //s้rie

			If type( cTagAux ) <> "U"	
				cSeriNF := &cTagAux	
			Endif
	
			cTagAux := "oXmlfis:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_IDE:_N"+Left(cTAG,2)+":TEXT"   //documento nf
	
			If type( cTagAux ) <> "U"	
				cNF := &cTagAux	
			Endif

			nTotLen := Len(oDet)
            //Loop de leitura dos detalhes do xml (a serem gravados na ZBT)
            //1o. gravar o campo ZBT_ITEM
            //atualiza primeiro o campo ZBT_ITEM
			For i := 1 To nTotLen
				cProduto  := ""	
				cItem     := ""
							
				//item
				cTagAux    := "oDet["+AllTrim(str(I))+"]:_NITEM:TEXT"  //odet[1]:_NITEM:TEXT
				If type( cTagAux ) <> "U"
					cItem := Strzero(VAL(&cTagAux),4)
				Endif
				//c๓digo produto
				cTagAux    := "oDet["+AllTrim(str(I))+"]:_PROD:_CPROD:TEXT"
				If type( cTagAux ) <> "U"
					cProduto := UPPER(&cTagAux)
				Endif			
					
				//Depois de limpo o campo ZBT_ITEM, re-itemiza
				cQuery := "	SELECT	" + LF
				cQuery += "			"+xZBT_+"PRODUT PRODUTO, "	+ LF
				cQuery += "			"+xZBT_+"CHAVE  CHAVE,	"	+ LF
				cQuery += "			ZBT.R_E_C_N_O_ AS ZBTRECNO	"	+ LF
				cQuery += "		FROM "+RetSqlName(xZBT)+" ZBT "	+ LF
				cQuery += "			WHERE ZBT.D_E_L_E_T_ = ''	"	+ LF
				cQuery += "			AND " + xZBT_+"FILIAL = '"+xFilial(xZBT)+"'"	+ LF
				cQuery += "			AND " + xZBT_+"CHAVE  = '"+cChaveXml+"'"	+ LF
				cQuery += "			AND " + xZBT_+"PRODUT = '"+SUBSTR(cProduto,1,15)+"'"	+ LF
				cQuery += "			AND " + xZBT_+"ITEM   = ''"	+ LF
				
				MemoWrite("C:\Temp\HFXMLFIS_ITEM.SQL" , cQuery)
				If Select("TMPZBT") > 0
					DbSelectArea("TMPZBT")
					DbCloseArea()
				Endif
				TCQuery cQuery New Alias "TMPZBT"
				
				nRecZBT:= 0

				If TMPZBT->(!Eof())
					TMPZBT->(DbGoTop())
					nRecZBT := TMPZBT->ZBTRECNO
				EndIf
				DbSelectArea("TMPZBT")
				DbCloseArea()
	 
				//GRAVA O ITEM NA ZBT:
				If nRecZBT > 0
					DbSelectArea(xZBT)
					DbGoto(nRecZBT)
					Reclock(xZBT,.F.)
						(xZBT)->(FieldPut(FieldPos(xZBT_+"ITEM"),cItem))
						DbSelectArea(xZBT)
					MsUnLock()
				EndIf
			Next i
					
		EndIf		
		TMPXML->(dbskip())				
	Enddo
	//Fim atualiza ZBT_ITEM		//FR - 26/03/2020 
Else
	MsgInfo("Nใo hแ dados para o filtro selecionado!")
	Return
Endif

//--------------------------------//
//3o. GRAVA ZBZ E ZBT 	            
//--------------------------------//
DbSelectArea("TMPXML")
TMPXML->(DbGoTop())
If ! TMPXML->(Eof())	
	
	//a partir daqui, atualiza geral: ZBZ e ZBT		
	TMPXML->(DbGoTop())
	While TMPXML->( !EoF() )
		
		oProcess:IncRegua1()		
		oProcess:IncRegua2( "Gravando Informa็๕es....-> NF - " + TMPXML->NOTA +"/"+ TMPXML->SERIE )		
		If lEnd		
			MsgStop("*** Cancelado pelo Operador ***","Fim")
			Exit			
		EndIf 

		DbSelectArea("ZBZ")
		DbGoto( TMPXML->ZRECNO )

		cChaveXml := (xZBZ)->&(xZBZ_ + "CHAVE")  //(xZBZ)->ZBZ_CHAVE
		cXml      := (xZBZ)->&(xZBZ_ + "XML")    //(xZBZ)->ZBZ_XML

		oXmlFIS := XmlParser( cXml, "_", @cError, @cWarning )
		
		cTAG := ""
		cTGP := ""
		
		If TMPXML->MODELO $ "55,65" .and. !Empty( oXmlFis )
			cTAG     := "NFE"
			cTGP     := "NFE"
		ElseIf TMPXML->MODELO == "57" .and. !Empty( oXmlFis )
			cTAG     	:= "CTE"
			cTGP        := "CTE"
		ElseIf TMPXML->MODELO == "67" .and. !Empty( oXmlFis )
			cTAG     	:= "CTE"
			cTGP        := "CTEOS"
		EndIf
		
		If !Empty(cTAG) .AND. !Empty(cTGP)
			//TRATAMENTO IMPOSTOS - AUDITORIA
			nBASCAL		:= 0
			nICMVAL		:= 0
			nICMDES		:= 0
			nSTBASE		:= 0
			nSTVALO		:= 0
			nIPIVAL		:= 0
			nIPIDEV		:= 0
			nPISVAL		:= 0
			nCOFVAL		:= 0
			nOUTVAL		:= 0
			cTagAux		:= ""
			cModelo		:= TMPXML->MODELO
			cNumNF		:= TMPXML->NOTA
			cSeriNF		:= TMPXML->SERIE
			cDocDest	:= TMPXML->CNPJD
			xMunIni     := ""
			xUFIni      := ""
			
			cTagAux := ("oXmlFIS:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_TOTAL:_ICMSTOT:_VBC:TEXT")
			If Type( cTagAux ) <> "U"
				nBASCAL := VAL(&cTagAux)
			EndIf
			
			cTagAux := ("oXmlFIS:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_TOTAL:_ICMSTOT:_VICMS:TEXT")
			If Type( cTagAux ) <> "U"
				nICMVAL := VAL(&cTagAux)
			EndIf
			
			cTagAux := ("oXmlFIS:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_TOTAL:_ICMSTOT:_VICMSDESON:TEXT")
			If Type( cTagAux ) <> "U"
				nICMDES := VAL(&cTagAux)
			EndIf
			
			cTagAux := ("oXmlFIS:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_TOTAL:_ICMSTOT:_VBCST:TEXT")
			If Type( cTagAux ) <> "U"
				nSTBASE := VAL(&cTagAux)
			EndIf
			
			cTagAux := ("oXmlFIS:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_TOTAL:_ICMSTOT:_VST:TEXT")
			If Type( cTagAux ) <> "U"
				nSTVALO := VAL(&cTagAux)
			EndIf
			
			cTagAux := ("oXmlFIS:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_TOTAL:_ICMSTOT:_VIPI:TEXT")
			If Type( cTagAux ) <> "U"
				nIPIVAL := VAL(&cTagAux)
			EndIf
			
			cTagAux := ("oXmlFIS:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_TOTAL:_ICMSTOT:_VIPIDEVOL:TEXT")
			If Type( cTagAux ) <> "U"
				nIPIDEV := VAL(&cTagAux)
			EndIf
			
			cTagAux := ("oXmlFIS:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_TOTAL:_ICMSTOT:_VPIS:TEXT")
			If Type( cTagAux ) <> "U"
				nPISVAL := VAL(&cTagAux)
			EndIf
			
			cTagAux := ("oXmlFIS:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_TOTAL:_ICMSTOT:_VCOFINS:TEXT")
			If Type( cTagAux ) <> "U"
				nCOFVAL := VAL(&cTagAux)
			EndIf
			
			cTagAux := ("oXmlFIS:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_TOTAL:_ICMSTOT:_VOUTRO:TEXT")
			If Type( cTagAux ) <> "U"
				nOUTVAL := VAL(&cTagAux)
			EndIf

			//-------------------------------------------------------------------------------//	
			//FR - 03/07/2020 - Projeto CCM - novo campo origem presta็ใo servi็o ZBZ_ORIPRT 
			//-------------------------------------------------------------------------------//
			xMunIni := ""
			//cTagAux := "oXml  :_CTEPROC:_CTE:_INFCTE:_IDE:_XMUNINI:TEXT"
			cTagAux := "oXmlFIS:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_XMUNINI:TEXT"
		
			if type(cTagAux) <> "U"
				xMunIni := &(cTagAux)
			endif
			
			xUFIni := ""
			//cTagAux := "oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_UFINI:TEXT"
			cTagAux := "oXmlFIS:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_UFINI:TEXT"
		
			if type(cTagAux) <> "U"
				xUFIni := &(cTagAux)
			endif
			//FR 03/07/2020
			//TRATAMENTO IMPOSTOS - AUDITORIA
			Reclock(xZBZ,.F.)
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"BASCAL"), nBASCAL))
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"ICMVAL"), nICMVAL))
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"ICMDES"), nICMDES))
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"STBASE"), nSTBASE))
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"STVALO"), nSTVALO))
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"IPIVAL"), nIPIVAL))
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"IPIDEV"), nIPIDEV))
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PISVAL"), nPISVAL))
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"COFVAL"), nCOFVAL))
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"OUTVAL"), nOUTVAL))
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"DTFIS") , DDATABASE))
				//--------------------------------------------------------------------------------//
				//FR - 03/07/2020 - Projeto CCM - Tratativa para grava็ใo no novo campo ZBZ_ORIPRT
				//                - origem presta็ใo de Servi็o (Municํpio - UF)  
				//--------------------------------------------------------------------------------//
				If cModelo == "57"	
					If (xZBZ)->(FieldPos(xZBZ_+"ORIPRT")) > 0
						(xZBZ)->(FieldPut(FieldPos(xZBZ_+"ORIPRT"), (xMunIni + "-" + xUFIni) ))
					Endif
				Endif
			MsUnlock(xZBZ)
			
			U_fGravaZBT(cXml,cModelo,cChaveXml,cNumNF,cSeriNF,cDocDest)
			
		EndIf
		TMPXML->(dbskip())
	EndDo
	

Else
	MsgInfo("Nใo hแ dados para o filtro selecionado!")
	Return
EndIf
MsgInfo("Processo de Auditoria realizado com sucesso")

TMPXML->(dbCloseArea())
	
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ QueryXmlF บ Autor ณ Henrique Tofanelli บ Data ณ 30/01/2020 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ IMPORTA XML                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function QueryXmlF()

Local cQuery := ""

cQuery += "	SELECT	"	+ LF
cQuery += "			"+xZBZ_+"MODELO MODELO,	"	+ LF
cQuery += "			"+xZBZ_+"SERIE  SERIE,	"	+ LF
cQuery += "			"+xZBZ_+"NOTA   NOTA,	" 	+ LF
cQuery += "			"+xZBZ_+"DTNFE  DTNFE,	"	+ LF
cQuery += "			"+xZBZ_+"CHAVE  CHAVE,	"	+ LF
cQuery += "			"+xZBZ_+"CNPJD CNPJD,	"	+ LF
cQuery += "			"+xZBZ_+"TPDOWL TPDOWL,	"	+ LF
cQuery += "			ZBZ.R_E_C_N_O_ AS ZRECNO	"	+ LF
cQuery += "		FROM "+RetSqlName(xZBZ)+" ZBZ	"	+ LF
cQuery += "			WHERE ZBZ.D_E_L_E_T_ = ''	"	+ LF
cQuery += "			AND "+xZBZ_+"FILIAL = '"+xFilial(xZBZ)+"'	"	+ LF
cQuery += "			AND "+xZBZ_+"TPDOWL <> 'R'	"	+ LF
cQuery += "			AND "+xZBZ_+"DTNFE BETWEEN '"+ALLTRIM(DtoS(MV_PAR01))+"' AND '"+ALLTRIM(DtoS(MV_PAR02))+"'	"	+ LF

//FILTRA SOMENTE REGISTROS SEM "ZBT"
If aRet[3] == 2
	cQuery += "			AND "+xZBZ_+"CHAVE NOT IN ( SELECT DISTINCT "+xZBT_+"CHAVE	"	+LF
	cQuery += "											FROM "+RetSqlName(xZBT)+" ZBT	"	+ LF
	cQuery += "												WHERE ZBT.D_E_L_E_T_ = ' '	"	+ LF
	cQuery += "											GROUP BY "+xZBT_+"CHAVE )	"	+ LF
EndIf

cQuery += "	ORDER BY "+xZBZ_+"NOTA, "+xZBZ_+"SERIE	"	+ LF

MemoWrite("C:\Temp\HFXMLFIS.SQL" , cQuery)

Return cQuery
