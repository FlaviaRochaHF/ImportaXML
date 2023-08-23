#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#include "FileIO.CH"
#include "TBICONN.CH"
#include "TBICODE.CH"      
#INCLUDE "PROTHEUS.CH"
	
/*
//==============================================================================================//
Programa  HFXML072   Autor  Najla Acemel       Data 06/05/21   
Desc.     Validaco da quantidade de requisicos maximas a serem realizadas por hora na sefaz.  
//==============================================================================================//
*/
//---------------------------------------------------------------------------//
//Alterações Realizadas:
//FR - 09/08/2021 - Teclaser - correção de erro na query HFXML072
//---------------------------------------------------------------------------//
//FR - 03/09/2021 - #11222 - Ocrim - erro em query que utiliza Top 1, Oracle 
//                           não reconhece, correção e adaptação
//---------------------------------------------------------------------------//
//FR - 05/10/2021 - #11157 - Prodata - adequação query para BD Oracle
//---------------------------------------------------------------------------//

User Function HFXML072(cCnpj)

Local cChave     := cCnpj //"23210204214792000158550010000063991000639910"
Local cQuery 	 := ""  
Local nReqSefaz  := GetNewPar("XM_NCNPJSE", 5)
//Local cEmpresa 		:= cEmpAnt
//Local cFilial		:= cFilAnt
//Local dData			:= SubStr(DTOS(dDataBase),7,2)+SubStr(DTOS(dDataBase),5,2)+SubStr(DTOS(dDataBase),1,4) 
Local cHora		 := Time()
Local xZBF  	 := GetNewPar("XM_TABCON" ,"ZBF")
Local xZBF_      := iif(Substr(xZBF,1,1)=="S", Substr(xZBF,2,2), Substr(xZBF,1,3)) + "_"
Local nTop		 := 0

Public lConsCnpj := .T. 

//HFXML072B(cChave)  //FR TESTE RETIRAR

//Valida se o parametro esta zerado
if nReqSefaz > 0

	//cQUERY := " SELECT TOP(1) ZBF."+xZBF_+"NUMCON,ZBF."+xZBF_+"DATA,ZBF."+xZBF_+"HORA"      	
	cQUERY := " SELECT ZBF."+xZBF_+"NUMCON,ZBF."+xZBF_+"DATA,ZBF."+xZBF_+"HORA"
	cQUERY += " FROM " + RetSqlName(xZBF)+ " ZBF "    
	cQUERY += " WHERE ZBF.D_E_L_E_T_ <> '*' "
	cQuery += " AND ZBF."+xZBF_+"CHAVE   ='"+cChave+"' "
	cQUERY += " ORDER BY ZBF."+xZBF_+"NUMCON DESC " 
	cQuery := ChangeQuery( cQuery )

	If Select("QRY") > 0
		QRY->(dbCloseArea())
	EndIf
	TCQUERY cQUERY NEW ALIAS "QRY"  

	dbSelectArea("QRY")
	QRY->(dbGoTop())                    

	If QRY->(!Eof())//Select("QRY") > 0 

		While QRY->(!Eof()) //cDataPed == QRY->C6_ENTREG .AND. (agrupamento por data comentado)
														//cUltChave:= QRY->ZBF_CHAVE
			If nTop <= 1								
				IF	QRY->&(xZBF_+"NUMCON") < nReqSefaz
	
					//colocar a inclusÃ£o na ZBF
					dbSelectArea(xZBF)
					Reclock(xZBF, .T.)				
	
					(xZBF)->(FieldPut(FieldPos(xZBF_+"FILIAL") , xFilial(xZBF) )) 
					(xZBF)->(FieldPut(FieldPos(xZBF_+"CHAVE") , cChave )) 
					(xZBF)->(FieldPut(FieldPos(xZBF_+"NUMCON") , (QRY->&(xZBF_+"NUMCON")+1) )) 
					(xZBF)->(FieldPut(FieldPos(xZBF_+"DATA") , dDataBase )) 
					(xZBF)->(FieldPut(FieldPos(xZBF_+"HORA") , cHora )) 
					(xZBF)->(FieldPut(FieldPos(xZBF_+"ROTINA") ,"HFXML072" )) 
	
					MsUnlock()    
	
				else
	
					HFXML072B(cChave)
	
				EndIf
												
				nTop++		//o "o Top 1" coloquei como contador aqui já que o Oracle é outra sintaxe para top 1 e o change query não converteu como deveria	
			
			Endif 									
			QRY->(dbSkip())
										
		EndDo  

	else

		dbSelectArea(xZBF)

		Reclock(xZBF, .T.)			

			(xZBF)->(FieldPut(FieldPos(xZBF_+"FILIAL") , xFilial(xZBF) )) 
			(xZBF)->(FieldPut(FieldPos(xZBF_+"CHAVE") , cChave )) 
			(xZBF)->(FieldPut(FieldPos(xZBF_+"NUMCON") , 1)) 
			(xZBF)->(FieldPut(FieldPos(xZBF_+"DATA") , dDataBase )) 
			(xZBF)->(FieldPut(FieldPos(xZBF_+"HORA") , cHora )) 
			(xZBF)->(FieldPut(FieldPos(xZBF_+"ROTINA") ,"HFXML072" )) 

		MsUnlock()    

	EndIf

else
	
	lConsCnpj := .F.

	If !IsBlind() 
		MsgInfo( "Não é possível consultar CNPJ devido campo cons. CNPJ estar com zero consultas, favor alterar o parâmetro com a quantidade de consultas. Padrão 5 ","Controle de Requisição" )//+ cChave	
	Else    	
		ConOut( "Não é possível consultar CNPJ devido campo cons. CNPJ estar com zero consultas, favor alterar o parâmetro com a quantidade de consultas. Padrão 5 ","Controle de Requisição" )
	Endif

endif

Return ()


/*
//==============================================================================================//
Programa  HFXML071C   Autor  Najla Acemel       Data 16/04/21   
Desc.     Verifica se ha menos de 5 requisicoes na ultima uma hora realizadas na sefaz. 
//==============================================================================================//
*/
Static Function HFXML072B(cChave)

Local _cQuery 	 := ""  
Local nTempo     := GetNewPar("XM_NHRSEF",60)
Local cHora		 := Time()
Local cChaveCons := ""
Local nNumCon    := 0
Local lAlt		 := .F.
Local xZBF  	 := GetNewPar("XM_TABCON" ,"ZBF")
Local xZBF_      := iif(Substr(xZBF,1,1)=="S", Substr(xZBF,2,2), Substr(xZBF,1,3)) + "_"

Local cDB 			:= TcGetDB()  //FR - 05/10/2021 - captura o banco de dados que está conectado

/*
A função TCGetDB() retorna uma string contendo um identificado que representa 
o banco de dados relacional (SGBD) em uso pela conexão atual/ativa com o DBAccess.
A seguir, observe na tabela a string que será retornada:

Banco de Dados						String retornada
 Microsoft SQL Server	 			MSSQL
 Oracle	 							ORACLE
 IBM DB2 ( UDB )	 				DB2
 IBM DB2 ( AS400 / iSeries )(**)	DB2/400
 IBM Informix	 					INFORMIX
 Sybase	 							SYBASE
 PostgreSQL	 						POSTGRES
 Generic ODBC Connection	 		ODBC
 MySQL	 							MYSQL
*/

If Alltrim(cDB) <> 'ORACLE'

	_cQuery := " SELECT ZBF."+xZBF_+"CHAVE, ZBF."+xZBF_+"NUMCON,ZBF."+xZBF_+"DATA,ZBF."+xZBF_+"HORA,"
	_cQuery += " DATEDIFF( MINUTE, ZBF."+xZBF_+"DATA + ' ' + ZBF."+xZBF_+"HORA, getdate() ) as TEMPODIF"     	
	_cQuery += " FROM " + RetSqlName(xZBF)+ " ZBF "    
	_cQuery += " WHERE ZBF.D_E_L_E_T_ <> '*' "
	_cQuery += " AND ZBF."+xZBF_+"CHAVE   ='"+cChave+"' "
	//cQUERY += " ORDER BY ZBF_NUMCON DESC " 

Else
    //se for Oracle:
    
	/*SELECT ZBF.ZBF_CHAVE,ZBF.ZBF_NUMCON,ZBF.ZBF_DATA,ZBF.ZBF_HORA, SYSDATE,
	TO_CHAR(SYSDATE, 'YYYYMMDD HH:MM') AS DATAHOJE
	,TO_DATE( ZBF_DATA , 'YYYYMMDD' )  AS ZBFDATE
	,( TO_DATE( SYSDATE , 'YYYYMMDD' )  - TO_DATE( ZBF_DATA , 'YYYYMMDD' ) ) * 24  AS DATEDIFHR
	,TO_DATE( SYSDATE , 'YYYYMMDD' )  - TO_DATE( ZBF_DATA , 'YYYYMMDD' )  AS DATEDIFDIAS
	 FROM ZBF020 ZBF WHERE ZBF.D_E_L_E_T_ <> '*' AND ZBF.ZBF_CHAVE ='01566137000413'   
 	*/

	_cQuery := " SELECT ZBF."+xZBF_+"CHAVE, ZBF."+xZBF_+"NUMCON,ZBF."+xZBF_+"DATA,ZBF."+xZBF_+"HORA, SYSDATE "
	_cQuery += " ,  TO_CHAR(SYSDATE, 'YYYYMMDD HH:MM') AS DATAHOJE "
	_cQuery += " ,  TO_DATE( ZBF." + xZBF_+"DATA , 'YYYYMMDD' )  AS ZBFDATE "
	_cQuery += " ,( TO_DATE( SYSDATE , 'YYYYMMDD' )  - TO_DATE( ZBF." + xZBF_+"DATA , 'YYYYMMDD' ) ) * 24  AS DATEDIFHR "   //diferença em horas
	_cQuery += " ,  TO_DATE( SYSDATE , 'YYYYMMDD' )  - TO_DATE( ZBF." + xZBF_+"DATA , 'YYYYMMDD' )  AS DATEDIFDIAS "  		//diferença em dias
	_cQuery += " ,( TO_DATE( SYSDATE , 'YYYYMMDD' )  - TO_DATE( ZBF." + xZBF_+"DATA , 'YYYYMMDD' ) ) * 1440  AS TEMPODIF "   //diferença em minutos
		
	_cQuery += " FROM " + RetSqlName(xZBF)+ " ZBF "    
	_cQuery += " WHERE ZBF.D_E_L_E_T_ <> '*' "
	_cQuery += " AND ZBF."+xZBF_+"CHAVE   ='"+cChave+"' "

Endif
MemoWrite("C:\TEMP\HFXML072B.SQL" , _cQuery)

_cQuery := ChangeQuery( _cQuery )
	
If Select("_QRY") > 0
	_QRY->(dbCloseArea())
EndIf
TCQUERY _cQuery NEW ALIAS "_QRY"  

dbSelectArea("_QRY")
_QRY->(dbGoTop())                    

If _QRY->(!Eof())

	While _QRY->(!Eof()) 
					//cUltChave:= QRY->ZBF_CHAVE
		cChaveCons := _QRY->&(xZBF_+"CHAVE")
		nNumCon := _QRY->&(xZBF_+"NUMCON")

		IF	_QRY->TEMPODIF > nTempo .AND. !lAlt

			dbSelectArea(xZBF)
			dbSetOrder(2)

			If (xZBF)->( DbSeek(xFilial(xZBF)+cChaveCons+ cValToChar(nNumCon) ))

				Reclock(xZBF, .F.)							
				(xZBF)->(FieldPut(FieldPos(xZBF_+"DATA") , dDataBase )) 
				(xZBF)->(FieldPut(FieldPos(xZBF_+"HORA") , cHora )) 
				MsUnlock()    
				lAlt := .T.			

			EndIf

		EndIf

	_QRY->(dbSkip())

	EndDo   

EndIf

If !lAlt

	If !IsBlind() 
		MsgInfo("CNPJ atingiu o limite de consulta na ultima hora","")	
	Else    	
		ConOut("CNPJ atingiu o limite de consulta na ultima hora" + cChave	)
	Endif

	lConsCnpj := .F.
	
EndIf

Return (lConsCnpj)
