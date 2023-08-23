#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#include "FileIO.CH"
#include "TBICONN.CH"
#include "TBICODE.CH"      
#INCLUDE "PROTHEUS.CH"
	
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHFXML071   บAutor  ณNajla Acemel       บ Data ณ  16/04/21   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida็ใo da quantidade de requisi็๕es mแximas a serem     บฑฑ
ฑฑบ          ณ   realizadas por hora na sefaz.                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Geral                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
//---------------------------------------------------------------------------//
//Altera็๕es Realizadas:
//FR - 09/08/2021 - Teclaser - corre็ใo de erro na query HFXML071A
//                             order by com '+', alterado para , (virgula)
//---------------------------------------------------------------------------//
//FR - 03/09/2021 - #11222 - Ocrim - erro em query que utiliza Top 1, Oracle 
//                           nใo reconhece, corre็ใo e adapta็ใo
//---------------------------------------------------------------------------//
User Function HFXML071(cChavexml)

Local cChave    := cChavexml //"23210204214792000158550010000063991000639910"
Local xZBZ      := GetNewPar("XM_TABXML" ,"ZBZ")
Local xZBZ_     := iif(Substr(xZBZ,1,1)=="S", Substr(xZBZ,2,2), Substr(xZBZ,1,3)) + "_"
Local nTempo    := GetNewPar("XM_NHRSEF",60)
Local nReqSefaz := GetNewPar("XM_NREQSEF",5)

Public lConsReq := .T.

//Valida se o parametro esta zerado
if nTempo == 0 

	lConsReq := .F.

	If !IsBlind() 
		MsgInfo( "Nใo ้ possํvel consultar chave, consultar CNPJ devido campo tempo requisi็ใo estar zerado, favor incluir 60 como padrใo ","Controle de Requisi็ใo" )//+ cChave	
	Else    	
		ConOut( "Nใo ้ possํvel consultar chave, consultar CNPJ devido campo tempo requisi็ใo estar zerado, favor incluir 60 como padrใo ","Controle de Requisi็ใo" )
	Endif

	Return()

endif

//Valida se o parametro esta zerado
if nReqSefaz == 0 

	lConsReq := .F.

	If !IsBlind() 
		MsgInfo( "Nใo ้ possํvel consultar chave devido campo cons. Chave estar com zero consultas, favor alterar o parโmetro com a quantidade de consultas. Padrใo 5","Controle de Requisi็ใo" )//+ cChave	
	Else    	
		ConOut( "Nใo ้ possํvel consultar chave devido campo cons. Chave estar com zero consultas, favor alterar o parโmetro com a quantidade de consultas. Padrใo 5","Controle de Requisi็ใo" )
	Endif

	Return()

endif

//Verifica o modelo de nota
DbSelectArea(xZBZ)  
DbSetOrder(3)
DbSeek(cChave)

if (xZBZ)->&(xZBZ_+"MODELO") <> "RP"
	
	HFXML071A(cChave)

	If lConsReq

		HFXML071B(cChave)

	EndIf

	//Verifica a quantidade de chaves por hora - Rogerio Lino 04/03/2022
	//HFXML071D(cChave)

else

	lConsReq := .T. // dessa forma prossegue para os proximos passos.

	If !IsBlind() 
		MsgInfo( "Nota Fiscal de Servi็o nใo exige controle de requisi็ใo","Controle de Requisi็ใo" )//+ cChave	
	Else    	
		ConOut( "Nota Fiscal de Servi็o nใo exige controle de requisi็ใo","Controle de Requisi็ใo" )
	Endif

endif

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHFXML071A   บAutor  ณNajla Acemel       บ Data ณ  16/04/21   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se a chave a ser consultada ้ a mesma que a ultima บฑฑ
ฑฑบ          ณ   realizadas na sefaz.                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Geral                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function HFXML071A(cChave)

Local cQuery 	:= ""  
//Local cEmpresa 		:= cEmpAnt
//Local cFilial		:= cFilAnt
Local cUltChave := ""
Local xZBF  	:= GetNewPar("XM_TABCON" ,"ZBF")
Local xZBF_     := iif(Substr(xZBF,1,1)=="S", Substr(xZBF,2,2), Substr(xZBF,1,3)) + "_"  
Local nTop		:= 0

//Verifica ultima chave consultada
//cQUERY := " SELECT TOP(1) ZBF."+xZBF_+"CHAVE"    	//FR - #11222 - OCRIM  	
cQUERY := " SELECT ZBF."+xZBF_+"CHAVE"
cQUERY += " FROM " + RetSqlName(xZBF)+ " ZBF "    
cQUERY += " WHERE ZBF.D_E_L_E_T_ <> '*' "
cQUERY += " ORDER BY ZBF."+xZBF_+"DATA , ZBF."+xZBF_+"HORA DESC  " 
cQuery := ChangeQuery( cQuery )
	
If Select("QRY") > 0
	QRY->(dbCloseArea())
EndIf
TCQUERY cQUERY NEW ALIAS "QRY"  

dbSelectArea("QRY")
QRY->(dbGoTop())                    

While QRY->(!Eof()) 

	cUltChave := QRY->&(xZBF_+"CHAVE") 
	
	If nTop <= 1    			//FR - 28/10/2021 - substituํ o Top N por aqui, porque em Oracle nใo funciona
		IF	Alltrim(cUltChave) == Alltrim(cChave)
	
			If !IsBlind() 
				MsgInfo("Chave igual a ๚ltima consultada"+CHR(13)+CHR(10)+"Obs. Sefaz nใo permite consulta em sequ๊ncia da mesma chave.","Controle de Requisi็ใo")//+ cChave	
			Else    	
				ConOut("Chave igual a ๚ltima consultada:" + cChave	)
			Endif
	
			lConsReq := .F.
	
		EndIf
		nTop++
		
	Endif 	

	QRY->(dbSkip())

EndDo   
		
Return (lConsReq)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHFXML071B   บAutor  ณNajla Acemel       บ Data ณ  16/04/21   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se hแ menos de 5 requisi็๕es na ultima uma hora   บฑฑ
ฑฑบ          ณ   realizadas na sefaz.                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Geral                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function HFXML071B(cChave)

Local cQuery 	:= ""  
Local nReqSefaz := GetNewPar("XM_NREQSEF",5)
//Local cEmpresa 		:= cEmpAnt
//Local cFilial		:= cFilAnt
//Local dData			:= SubStr(DTOS(dDataBase),7,2)+SubStr(DTOS(dDataBase),5,2)+SubStr(DTOS(dDataBase),1,4) 
Local cHora		:= Time()
Local xZBF  	:= GetNewPar("XM_TABCON" ,"ZBF")
Local xZBF_     := iif(Substr(xZBF,1,1)=="S", Substr(xZBF,2,2), Substr(xZBF,1,3)) + "_"
Local nTop 		:= 0

//cQUERY := " SELECT TOP(1) ZBF."+xZBF_+"NUMCON,ZBF."+xZBF_+"DATA,ZBF."+xZBF_+"HORA"      	
cQUERY := " SELECT ZBF."+xZBF_+"NUMCON,ZBF."+xZBF_+"DATA,ZBF."+xZBF_+"HORA"		//FR - #11222 - OCRIM
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
		//FR - #11222 - OCRIM
		If nTop <= 1
		
			IF	QRY->&(xZBF_+"NUMCON") < nReqSefaz

				//colocar a inclusใo na ZBF
				dbSelectArea(xZBF)
				Reclock(xZBF, .T.)			

					(xZBF)->(FieldPut(FieldPos(xZBF_+"FILIAL") , xFilial(xZBF) )) 
					(xZBF)->(FieldPut(FieldPos(xZBF_+"CHAVE") , cChave )) 
					(xZBF)->(FieldPut(FieldPos(xZBF_+"NUMCON") , (QRY->&(xZBF_+"NUMCON")+1) )) 
					(xZBF)->(FieldPut(FieldPos(xZBF_+"DATA") , dDataBase )) 
					(xZBF)->(FieldPut(FieldPos(xZBF_+"HORA") , cHora )) 
					(xZBF)->(FieldPut(FieldPos(xZBF_+"ROTINA") ,"HFXML071" )) 

				MsUnlock()    

			else

				HFXML071C(cChave)

			EndIf	

			//FR - #11222 - OCRIM
			nTop++		//o "o Top 1" coloquei como contador aqui jแ que o Oracle ้ outra sintaxe para top 1 e o change query nใo converteu como deveria
		
		Endif	

		QRY->(dbSkip())
	
	EndDo   

else

	dbSelectArea(xZBF)

	Reclock(xZBF, .T.)		

		(xZBF)->(FieldPut(FieldPos(xZBF_+"FILIAL") , xFilial(xZBF) )) 
		(xZBF)->(FieldPut(FieldPos(xZBF_+"CHAVE") , cChave )) 
		(xZBF)->(FieldPut(FieldPos(xZBF_+"NUMCON") , 1 )) 
		(xZBF)->(FieldPut(FieldPos(xZBF_+"DATA") , dDataBase )) 
		(xZBF)->(FieldPut(FieldPos(xZBF_+"HORA") , cHora )) 
		(xZBF)->(FieldPut(FieldPos(xZBF_+"ROTINA") ,"HFXML071" )) 

	MsUnlock()    

EndIf

Return (lConsReq)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHFXML071C   บAutor  ณNajla Acemel       บ Data ณ  16/04/21   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se hแ menos de 5 requisi็๕es na ultima uma hora   บฑฑ
ฑฑบ          ณ   realizadas na sefaz.                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function HFXML071C(cChave)

Local _cQuery 	  := ""  
Local nTempo      := GetNewPar("XM_NHRSEF",60)
Local cHora		  := Time()
Local cChaveCons  := ""
Local nNumCon     := 0
Local lAlt		  := .F.
Local cTempoRest  := "0"
Local xZBF  	  := GetNewPar("XM_TABCON" ,"ZBF")
Local xZBF_       := iif(Substr(xZBF,1,1)=="S", Substr(xZBF,2,2), Substr(xZBF,1,3)) + "_"
Local nTempoDif	  := 0

_cQuery := " SELECT ZBF."+xZBF_+"CHAVE, ZBF."+xZBF_+"NUMCON,ZBF."+xZBF_+"DATA,ZBF."+xZBF_+"HORA "
//_cQuery += " DATEDIFF( MINUTE, ZBF."+xZBF_+"DATA + ' ' + ZBF."+xZBF_+"HORA, getdate() ) as TEMPODIF"     	
_cQuery += " FROM " + RetSqlName(xZBF)+ " ZBF "    
_cQuery += " WHERE ZBF.D_E_L_E_T_ <> '*' "
_cQuery += " AND ZBF."+xZBF_+"CHAVE   ='"+cChave+"' "
_cQUERY += " ORDER BY ZBF."+xZBF_+"NUMCON " 
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
  		nTempoDif := Hrs2Min(ELAPTIME( _QRY->&(xZBF_+"hora"),time() ))

		IF nTempoDif > nTempo .AND. !lAlt

			dbSelectArea(xZBF)
			dbSetOrder(2)
			If (xZBF)->( DbSeek(xFilial(xZBF)+cChaveCons+ cValToChar(nNumCon) ))

				Reclock(xZBF, .F.)							
				(xZBF)->(FieldPut(FieldPos(xZBF_+"DATA") , dDataBase )) 
				(xZBF)->(FieldPut(FieldPos(xZBF_+"HORA") , cHora )) 
				MsUnlock()    
				lAlt := .T.		

			EndIf

		else

			lAlt := .T.

		EndIf									

		If (cTempoRest == "0" .OR. cTempoRest < cValToChar(nTempoDif)) .AND. !lAlt
			cTempoRest := cValToChar(nTempoDif)
		EndIf		

		_QRY->(dbSkip())

	EndDo   

EndIf

If !lAlt

	If !IsBlind() 

		MsgInfo("Chave atingiu o limite de consulta conforme parโmetros."+CHR(13)+CHR(10)+"Espere "+cValToChar(ntempo - Val(cTempoRest))+ "minutos para nova consulta.","Controle de Requisi็ใo")	
	
	Else   

		ConOut("Chave atingiu o limite de consulta conforme parโmetros." + cChave	)

	Endif

	lConsReq := .F.
	
EndIf

Return (lConsReq)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHFXML071D   บAutor  ณNajla Acemel       บ Data ณ  16/04/21   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica a quantidade de consulta por chave                 บฑฑ
ฑฑบ          ณ   realizadas na sefaz.                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function HFXML071D(cChave)

Local cQuery 	:= ""  
//Local nReqSefaz := 20 //GetNewPar("XM_NREQSEF",20)
//Local cEmpresa 		:= cEmpAnt
//Local cFilial		:= cFilAnt
//Local dData			:= SubStr(DTOS(dDataBase),7,2)+SubStr(DTOS(dDataBase),5,2)+SubStr(DTOS(dDataBase),1,4) 
//Local cHora		:= Time()
Local xZBF  	:= GetNewPar("XM_TABCON" ,"ZBF")
Local xZBF_     := iif(Substr(xZBF,1,1)=="S", Substr(xZBF,2,2), Substr(xZBF,1,3)) + "_"
//Local nTop 		:= 0
Local aChave    := {}

if ( "ORACLE" $ Upper( TcGetDb() ) )

	cQUERY := " SELECT ZBF."+xZBF_+"NUMCON,ZBF."+xZBF_+"DATA,ZBF."+xZBF_+"HORA"

else

	cQUERY := " SELECT TOP 20 ZBF."+xZBF_+"NUMCON,ZBF."+xZBF_+"DATA,ZBF."+xZBF_+"HORA"

endif
		
cQUERY += " FROM " + RetSqlName(xZBF)+ " ZBF "    

if ( "ORACLE" $ Upper( TcGetDb() ) )

	cQUERY += " WHERE ROWNUM = 20 AND ZBF.D_E_L_E_T_ <> '*' AND "

else

	cQUERY += " WHERE ZBF.D_E_L_E_T_ <> '*' AND "

endif

cQuery += " ZBF."+xZBF_+"ROTINA  ='HFXML071' "
cQUERY += " ORDER BY ZBF."+xZBF_+"DATA DESC, ZBF."+xZBF_+"HORA DESC  " 
cQuery := ChangeQuery( cQuery )
	
If Select("QRY") > 0
	QRY->(dbCloseArea())
EndIf
TCQUERY cQUERY NEW ALIAS "QRY"  

DbSelectArea("QRY")
QRY->(dbGoTop())                    

While QRY->(!Eof()) 

	If SubHoras(QRY->&(xZBF_+"HORA"),Time()) < 1 .and. dDatabase == STOD(QRY->&(xZBF_+"DATA"))
	
		aAdd(aChave,{cChave,QRY->&(xZBF_+"DATA"),QRY->&(xZBF_+"HORA")})
		
	Endif	

	QRY->(dbSkip())

EndDo   

if Len(aChave) >= 20

	lConsReq := .F.

	If !IsBlind() 

		MsgInfo("Chave atingiu o limite de consulta conforme parโmetros."+CHR(13)+CHR(10)+"Espere 60 minutos para nova consulta.","Controle de Requisi็ใo")	
	
	Else   

		ConOut("Chave atingiu o limite de consulta conforme parโmetros." + cChave	)

	Endif

else
	
	lConsReq := .T.

endif

Return(lConsReq)

