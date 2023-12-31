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

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � HFXML062 � Autor � Eneovaldo Roveri Jr   � Data �22/03/2019���
�������������������������������������������������������������������������Ĵ��
���Descricao � Rotina de Download de XMLs do Sefaz S� dos erros           ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
//---------------------------------------------------------------------------//
//Altera��es realizadas:
//FR - 23/12/2020 - #5933 - Chamado Kroma 
//                  Cria��o das vari�veis Private xZBZ, xZBZ_ para uso 
//                  via macro-substitui��o 
//----------------------------------------------------------------------------//
//FR - 05/05/2021 - #10382 - Kroma - tratativa para chamada dentro do Schedule
//----------------------------------------------------------------------------//
//FR - 07/06/2021 - Rollback das altera��es da Kroma
//----------------------------------------------------------------------------//   
User Function HFXML062(lAuto,lEnd,oProcess,cLogProc,nCount,lMostra)

Local aArea := GetArea()

if ! ManifZBZ(lAuto,@lEnd,oProcess,@cLogProc,@nCount,lMostra)
	
	RestArea( aArea )
	Return( NIL )
	
endif

if ! DowErr(lAuto,@lEnd,oProcess,@cLogProc,@nCount,lMostra)
	
	RestArea( aArea )
	Return( NIL )
	
endif

RestArea( aArea )

Return(NIL)

//---------------------------------------------------------------------//
//Rotina de Manifesta��o da Chave da nf
//---------------------------------------------------------------------//
Static Function ManifZBZ(lAuto,lEnd,oProcess,cLogProc,nCount,lMostra)

Local aArea  := GetArea()
Local cQuery := ""
Local nOk    := 0
Local nErr   := 0
Local nMan   := 0
Local cJust  := ""
Local cManAnt:= ""
Local cAliasZBZ:= GetNextAlias()
Local lRet   := .T.

Private xZBZ  	  := GetNewPar("XM_TABXML","ZBZ")												//FR - 23/12/2020
Private xZBZ_ 	  := iif(Substr(xZBZ,1,1)=="S", Substr(xZBZ,2,2), Substr(xZBZ,1,3)) + "_"		//FR - 23/12/2020  
 

If lMostra

	oProcess:IncRegua1("Atualizando Manifesta��es Pendentes...")
	oProcess:IncRegua2("Aguarde...")        
                
Endif

cQuery := "SELECT "+xZBZ_+"CHAVE, ZBZ.R_E_C_N_O_ "
cQuery += "FROM "+RetSqlName(xZBZ)+" ZBZ " 
cQuery += "WHERE ZBZ.D_E_L_E_T_ = '' "
cQuery += "AND ZBZ."+xZBZ_+"MANIF IN ('W','X','Y','Z') "
cQuery += "ORDER BY "+xZBZ_+"CHAVE "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasZBZ,.T.,.T.)

DbSelectArea(cAliasZBZ) 
Dbgotop()
While !(cAliasZBZ)->(Eof())

    If lMostra
    
		//IncProc("Processando "+(cAliasZBZ)->&(xZBZ_+"CHAVE"))
		oProcess:IncRegua1("Atualizando Manifesta��es Pendentes...")
		oProcess:IncRegua2( (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))) )

		Conout("Atualizando Manifesta��es Pendentes..." + (cAliasZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))) )
		
		if lEnd
		
			MsgStop("*** Manifesta��es Cancelada pelo Operador ***","Fim")
			lRet   := .F.
			Exit
			
		endif
		
	EndIf
	
	DbSelectArea(xZBZ)
	DbGoTo((cAliasZBZ)->R_E_C_N_O_)
	
	cManAnt := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MANIF")))
	nMan   := 0
	cJust  := " "
	
	if cManAnt = "W"
	
		nMan   := 1
		
	elseif cManAnt = "X"
	
		nMan   := 2
		
	elseif cManAnt = "Y"
	
		nMan   := 3
		cJust  := AllTrim( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"PDF"))) )
	
	elseif cManAnt = "Z"
	
		nMan   := 4
		
	endif
	
	if nMan > 0
	
			U_HFMANCHV(,,,nMan,cJust,1)
		
	endif
	
	if cManAnt <> (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MANIF")))
		
		nOk++
	
	else
	
		nErr++
		
	endif
		
	DbSelectArea(cAliasZBZ)
	(cAliasZBZ)->(DbSkip())   
	 	
EndDo

cLogProc += StrZero(nOk,6)+" XMLs Manifestados. "+StrZero(nErr,6)+" n�o manifestados"+CRLF

DbSelectArea(cAliasZBZ)			             
DbCloseArea()

RestArea( aArea )

Return( lRet )


Static Function DowErr(lAuto,lEnd,oProcess,cLogProc,nCount,lMostra)

Local aArea := GetArea()
Local lRet  := .T.

RestArea( aArea )

Return( lRet )


Static Function __Dummy(lRecursa) //warning W0010 Static Function <?> never called
	
	lRecursa := .F.
	IF (lRecursa)
        	__Dummy(.F.)
        	U_HFXML062()
	EndIF
	
Return(lRecursa)

