#include "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "XMLXFUN.CH" 
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "FILEIO.CH"



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HF_WF_XML2 ºAutor  ³ Raul Seixas      º Data ³ Quinta-Feira º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Baixar arquivos da Ticket FTP                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ HFXML133                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AutoXml2  º Autor ³ Eneo               º Data ³  15/11/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Direciona os jobs automaticos FTP, Classificação Automaticaº±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Importa Xml                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//--------------------------------------------------------------------------//
// Alterações realizadas:
// Flávia Rocha - 02/07/2020:
// Adequação da execução do Job Aguas do Brasil
//--------------------------------------------------------------------------//
// Alterações realizadas:
// Flávia Rocha - 16/07/2020:
// Adequação da performance do download, na execução do Job Aguas do Brasil
//--------------------------------------------------------------------------//
// Alterações realizadas:
// Flávia Rocha - 18/08/2020:
// Projeto Kroma - implementação de job para classificação de notas de energia
//--------------------------------------------------------------------------//
User Function AutoXml2(cTipo,lAuto,lEnd,oProcess,cLogProc,nCount,cUrl)
Local cDayExec
Local lProssegue  := .T.
Local nTamFil     := TAMSXG("033")[1]		//FR - 16/07/2020 - captura o tamanho da filial no grupo de campos SXG
Local cFILLANT    := ""                     //FR - 16/07/2020
Local aArea       := GetArea()
Local _nSleep     := 0  
Local cFileCfg    := "hfcfgxml001a.xml"		//FR - 16/07/2020
Local cENT		  := ""                     //FR - 16/07/2020
Local cClAt       := GetNewPar("XM_CLAT"   ,"N")
Local cCloud	  := GetNewPar("XM_CLOUD" ,"0")         //aCombo (0=Desbilitado 1=Habilitado)

Default cTipo     := " "

Private xZBZ  	  := GetNewPar("XM_TABXML","ZBZ")
Private xZBZ_ 	  := iif(Substr(xZBZ,1,1)=="S", Substr(xZBZ,2,2), Substr(xZBZ,1,3)) + "_"
Private xZB5  	  := GetNewPar("XM_TABAMAR","ZB5")
Private xZB5_ 	  := iif(Substr(xZB5,1,1)=="S", Substr(xZB5,2,2), Substr(xZB5,1,3)) + "_"
Private xZBS  	  := GetNewPar("XM_TABSINC","ZBS")
Private xZBS_ 	  := iif(Substr(xZBS,1,1)=="S", Substr(xZBS,2,2), Substr(xZBS,1,3)) + "_"
Private xZBE      := GetNewPar("XM_TABEVEN","ZBE")
Private xZBE_     := iif(Substr(xZBE,1,1)=="S", Substr(xZBE,2,2), Substr(xZBE,1,3)) + "_"
Private xZBT      := GetNewPar("XM_TABITEM","ZBT") 
Private xZBT_ 	  := iif(Substr(xZBT,1,1)=="S", Substr(xZBT,2,2), Substr(xZBT,1,3)) + "_"
Private xZBA  	  := GetNewPar("XM_TABAMA2","ZBA")
Private xZBA_ 	  := iif(Substr(xZBA,1,1)=="S", Substr(xZBA,2,2), Substr(xZBA,1,3)) + "_"
Private xZBC      := GetNewPar("XM_TABCAC","ZBC")
Private xZBC_     := iif(Substr(xZBC,1,1)=="S", Substr(xZBC,2,2), Substr(xZBC,1,3)) + "_"
Private xZBO      := GetNewPar("XM_TABOCOR","ZBO"), xRetSEF := ""
Private xZBO_     := iif(Substr(xZBO,1,1)=="S", Substr(xZBO,2,2), Substr(xZBO,1,3)) + "_"
Private xZBI      := GetNewPar("XM_TABIEXT","ZBI")
Private xZBI_     := iif(Substr(xZBI,1,1)=="S", Substr(xZBI,2,2), Substr(xZBI,1,3)) + "_"
Private x_Ped_Rec := GetNewPar("XM_PEDREC","N")
Private x_ZBB     := GetNewPar("XM_TABREC","")
Private aHfCloud  := {"0","0"," ","Token",{}}  //CRAUMDE - '0' Não integrar, na posição 1
Private x_Tip_Pre := GetNewPar("XM_TIP_PRE","1")
Private nFormNfe  := Val(GetNewPar("XM_FORMNFE","6")) 
Private nFormCte  := Val(GetNewPar("XM_FORMCTE","6"))
Private cFilUsu   := GetNewPar("XM_FIL_USU","N")
Private cTpRt  	  := "J"
Private oXml				//FR 16/07/2020

if cClAt == "S" //Verifica se integração esta habilitada

	DbSelectArea(xZBI)
	Aadd(aArea, (xZBI)->(GetArea()) )

	DbSelectArea(xZBO)
	Aadd(aArea, (xZBO)->(GetArea()) )

	DbSelectArea(xZBZ)
	Aadd(aArea, (xZBZ)->(GetArea()) )

	DbSelectArea(xZBT)
	Aadd(aArea, (xZBT)->(GetArea()) )

	DbSelectArea(xZB5)
	Aadd(aArea, (xZB5)->(GetArea()) )

	DbSelectArea(xZBE)
	Aadd(aArea, (xZBE)->(GetArea()) )

	DbSelectArea(xZBS)
	Aadd(aArea, (xZBS)->(GetArea()) ) 
	
	DbSelectArea(xZBA)
	Aadd(aArea, (xZBA)->(GetArea()) ) 

	DbSelectArea(xZBC)
	Aadd(aArea, (xZBC)->(GetArea()) )

	if cCloud <> "1"

		cIdEnt := U_GetIdEnt()

	else

		cIdEnt := ""
		
	endif

	//IF ExistBlock( "HFCLDINI" )
	//	aHfCloud := U_HFCLDINI(.F.,@cLogProc)
	//EndIF

	rstmvbuff() 

	//FR - 16/07/2020
	If File(cFileCfg)
		oXml := U_LoadCfgX(1,cFileCfg,)
		
		If oXml == Nil	
			Return			
		EndIf
		cENT     := AllTrim(oXml:_MAIN:_WFXML01:_ENT:_XTEXT:TEXT)
	Endif

	If nTamFil == 2
		cFILLANT := "01"	
	Elseif nTamFil == 4
		cFILLANT := "0101"	
	Elseif nTamFil == 6
		cFILLANT := "010101"	
	Endif

	If Alltrim(cENT) <> Alltrim(cFILLANT)
		//CONOUT("<GESTAOXML> cENT ==> " + cENT + " /  cFILLANT ==> "+ cFILLANT)
		cFILLANT := Substr(cENT,3,nTamFil)	//sempre irá acatar a filial definida no parâmetro da tela F12 para emp/filial usada no job		
	Endif

	If cFilAnt <> cFILLANT

	If IsBlind()         //FR - 16/07/2020 - se está via job, e a filial for diferente da que está no parametro do importa, passa direto, pois só baixa FTP na filial definida no parametro F12 para integração (ex.: emp: 00 / filial: 010101).
			lProssegue := .F.
		Endif
		
	Endif

	_nSleep := GetNewPar("XM_ITSLEEP",30000)  							
	//FR 16/07/2020
	If cTipo == "A"

	    If lProssegue		//esse job "A" só baixa o arquivo TXT via FTP na filial definida no parâmetro do importa (empresa / filial para integração)
	    					//atualmente a única empresa que utiliza é a AGUAS DO BRASIL
			
			//CONOUT("<GESTAOXML> ACESSOU JOB 'A' ===> BAIXAR FTP <===")
					
				If HFVERFTP(@nCount)
					
					//Sleep(_nSleep)										//FR 17/07/2020 RETIRAR
						
					cDayExec := Dtos( date() )
					
					If U_HFFTPJOB(lAuto,@lEnd,oProcess,@cLogProc,@nCount)
						If !PutMv("XM_DT_ITAT", cDayExec ) 
							RecLock("SX6",.T.)
							SX6->X6_FIL     := xFilial("SX6")
							SX6->X6_VAR     := "XM_DT_ITAT"
							SX6->X6_TIPO    := "C"
							SX6->X6_DESCRIC := "Data da Ultima Execução Integração Externa."
							MsUnLock()
							PutMv("XM_DT_ITAT", cDayExec ) 
						EndIf
					Endif
				Endif
			Endif 		//lProssegue
	ElseIf cTipo == "B"         //FR - 18/08/2020 - este job "B" é usado tanto para classificação de nfs combustíveis (Aguas Br), 
								//qto para nfs energia (Kroma)
								//FR - 05/08/2022 - este job "B" é usado para a classificação de nfs combustíveis por exemplo: Politec,
								//este job "B" não requer a integração via arquivo txt, é totalmente pelo XML, faz o download e classifica

	//CONOUT("<GESTAOXML> ACESSOU JOB 'B' ===> CLASSIFICAR <===")	
		//If U_fExistZBI(,,)
			If HFVERCLA(@nCount)
			
				//Sleep(_nSleep)											//FR 17/07/2020
				
				cDayExec := Dtos( date() )
				
				If U_HFCLAJOB(lAuto,@lEnd,oProcess,@cLogProc,@nCount)
					If !PutMv("XM_DT_CLAT", cDayExec ) 
						RecLock("SX6",.T.)
						SX6->X6_FIL     := xFilial("SX6")
						SX6->X6_VAR     := "XM_DT_CLAT"
						SX6->X6_TIPO    := "C"
						SX6->X6_DESCRIC := "Data da Ultima Execução Classificação Automática."
						MsUnLock()
						PutMv("XM_DT_CLAT", cDayExec ) 
					EndIf
				Endif
			Endif
		//Endif //ver se tem ZBI para não acessar a função em vão
	EndIf

endif

RestArea( aArea )
rstmvbuff()

Return


Static Function HFVERFTP(nCount)

Local lRet := .T.
Local cItAtJob := GetNewPar("XM_ITATJOB","0")						//FR - 25/06/2020 - habilitado Sim/Não
Local cItAtDia := Padr(GetNewPar("XM_ITATDIA",Space(256)),256)		//FR - 25/06/2020 - Dia para execução (X - Todos)
Local cItAtMes := Padr(GetNewPar("XM_ITATMES",Space(256)),256)		//FR - 25/06/2020 - Mês para execução (X - Todos)
Local cItAtAnC := Padr(GetNewPar("XM_ITATANC",Space(7)),7)			//FR - 25/06/2020 - Ano/mês para integração automática
Local cItAtHrC := Padr(GetNewPar("XM_ITATHRC",Space(5)),5)			//FR - 25/06/2020 - Hora para início
Local cDtExec  := GetNewPar("XM_DT_ITAT","20180101")				//FR - 25/06/2020 - Data da última integração executada: ex: 20200625

If cItAtJob == "0"
	lRet := .F.
	nCount := -1
Else
	lRet := VaiMesmo( cItAtDia, cItAtMes, cItAtAnC, cItAtHrC, cDtExec )
Endif

Return( lRet )


Static Function HFVERCLA(nCount)

Local lRet := .T.
Local cClAt    := GetNewPar("XM_CLAT"   ,"N")
Local cClAtJob := GetNewPar("XM_CLATJOB","0")
Local cClAtDia := Padr(GetNewPar("XM_CLATDIA",Space(256)),256)
Local cClAtMes := Padr(GetNewPar("XM_CLATMES",Space(256)),256)
Local cClAtAnC := Padr(GetNewPar("XM_CLATANC",Space(7)),7)
Local cClAtHrC := Padr(GetNewPar("XM_CLATHRC",Space(5)),5)
Local cDtExec  := GetNewPar("XM_DT_CLAT","20180101")

If cClAt = "N" .OR. cClAtJob == "0"
	lRet := .F.
	nCount := -1
Else
	lRet := VaiMesmo( cClAtDia, cCLAtMes, cCLAtAnC, cCLAtHrC, cDtExec )
Endif

Return( lRet )


Static Function VaiMesmo( cDia, cMes, cAnC, cHrC, cDtExec )
Local lRet     := .F.
Local cDate    := Dtos( Date() )

Local cHora    := Substr(Time(),1,5)
Local cMesAtu  := Substr(cDate,5,2) //Month( Date() )
Local cDiaSem  := AllTrim(Str(Dow( Date() )))
Local nHr      := 0

If ! Empty( cAnC ) .and. cAnC <> "/      "
	If cAnC = Substr( cDate,1,4 )+"/"+Substr( cDate,5,2 )
		lRet := .T.
	Else
		lRet := .F.
	Endif
Else
	If "X" $ cMes .or. cMesAtu $ cMes
		If "X" $ cDia .or. cDiaSem $ cDia
			lRet := .T.
		Else
			lRet := .F.
		Endif
	Else
		lRet := .F.
	Endif
Endif

If ! Empty( cHrC ) .and. Alltrim(cHrC)  <> ":"  //if lRet .And. ! Empty( cHrC )
	
	nHr := Val(substr(cHora,1,2)) -  Val(Substr(cHrC,1,2)) //FR 11/07/2020
	
	//If cDtExec <= cDate .And. cHora < cHrC		//FR - 25/06/2020 - Se a data da última vez que executou é menor igual data de hoje, e se a hora atual é menor que hora para início, se essas duas condições forem .T., não executa
	If cDtExec <= cDate .And. (nHr < 0 .or. nHr > 6)
		lRet := .F.  
		                                                                                                    
		If !Empty(cDtExec) .and. !Empty(cHrC)
			CONOUT("<GESTAOXML> AGUARDANDO HORA INTEGRACAO EXT cDTEXEC: " + cDtExec + " - cHRC ==> " + cHrC + " <===> FUNCAO VMSMO RET =  <<< F >>> ")
		Endif
		
	//ElseIF cDtExec < cDate1						//FR - 25/06/2020 - <else auxiliar> Se a data da última vez que executou é menor data de hoje
	
													
	Elseif cDtExec < cDate .And. (nHr >=0 .and. nHr <= 6)		//FR - 25/06/2020 - Se a data da última vez que executou é menor data de hoje, e hora atual for maior que hora para início
	
		lRet := .T.
		
	    //CONOUT("<GESTAOXML> DIA/HORA OK PARA JOB  ===> FUNCAO VMSMO RET = <<< T >>> ")
	    If !Empty(cDtExec) .and. !Empty(cHrC) .and. Alltrim(cHrC)  <> ":"
	    	CONOUT("<GESTAOXML> ACESSOU INTEGRACAO AGENDADA DIA/HORA ===> " + cDtExec + " / " + cHrC + " <====")
	    Endif
	
	Endif
	
Endif


Return( lRet )
Static Function __Dummy(lRecursa) //warning W0010 Static Function <?> never called
    
    lRecursa := .F.
    
    IF (lRecursa)
    
        __Dummy(.F.)
        U_AutoXml2()
        
	EndIF
	
Return(lRecursa)
