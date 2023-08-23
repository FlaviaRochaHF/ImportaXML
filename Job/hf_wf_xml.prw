#INCLUDE "XMLXFUN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH" 
#INCLUDE "Ap5Mail.ch"

#DEFINE MAXJOBNOAR 1   
#DEFINE SEMAFORO 'IDIMPXML'

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
// Flávia Rocha - 06/08/2020:
// Adequação das mensagens conout
//--------------------------------------------------------------------------//
// Alterações realizadas:
// Flávia Rocha - 18/08/2020:
// Projeto Kroma - implementação de job para classificação de notas de energia
//--------------------------------------------------------------------------//
User Function WF_XML01()

Local lIPc          := .F.
Local aRotina   	:= {}
Local aEntidades	:= {}
Local nX        	:= 0
Local nY        	:= 0
Local nW        	:= 0
Local nZ        	:= 0
Local nJobs     	:= 1
Local cHoraIni  	:= ""
Local cHoraFim  	:= ""
Local lOk       	:= .F.
Local lStartUp  	:= .T.
Local nStartUp  	:= 0
Local aParams       := {}  
Local cError        := ""  
Local nTotalCount   := 0
Local aAguas        := {}
Local cXmTpJobCx    := "1"
local cDate		    := Dtos( Date() )
local cHora         := Substr(Time(),1,5)
Local cnW5          := ""
Local cnW6          := ""
Local nH1           := 0
Local nM1           := 0 
Local nH2           := 0
Local nM2           := 0
Private cMsgModelo  := "[XML]"
Private cThreadID	:= "0"
Private nSleepJob 	:= 0
Private lChegouHR   := .F.
Private _nSleep     := 0
Private nMostraI    := 0				//FR - 06/08/2020
Private nMostraC    := 0				//FR - 06/08/2020
Private cItAtLOG    := ""				//FR - 05/08/2022 - PROJETO POLITEC - verificar se existe usuário/senha cadastrado,se estiver vazio, não deixa prosseguir no job A
Private cItAtPAS    := ""		  		//FR - 05/08/2022 - PROJETO POLITEC - verificar se existe usuário/senha cadastrado,se estiver vazio, não deixa prosseguir no job A

LoadParams(@aParams,@cError,.T.)
                                    
cEnable             := aParams[1][2]
aEntidades          := aParams[2][2]
nStartUp        	:= aParams[3][2]
cThreadID	     	:= aParams[4][2]
nSleepJob           := aParams[6][2]

MakeDir(GetPathSemaforo())
cArq := GetPathSemaforo()+"HFWF*.LCK"
FErase(cArq)

While !KillApp()

	cHoraIni   := "00:00:01"
	cHoraFim   := "23:59:59"
	aRotina    := {} 
	aAguas     := {}
	cXmTpJobCx := "1"
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se a Rotina deve ser executada                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	LoadParams(@aParams,@cError,.T.)

	cEnable             := aParams[1][2]
	aEntidades  		:= LoadSm0( aParams[2][2], @aAguas, @cXmTpJobCx, @_nSleep, @cItAtLOG, @cItAtPAS )
	nStartUp        	:= aParams[3][2]
	cThreadID	     	:= aParams[4][2]
	nSleepJob           := aParams[6][2]

	cIdJobs   := aParams[5][2]
	aadd(aRotina,{"U_XMLWF01A",cIdJobs})

	If cEnable <> "0"
	
	    //--------------------------------------------------------------------//
		// JOBS AGUAS DO BRASIL 
		//--------------------------------------------------------------------//
		//FR 17/07/2020 - mudei para fazer primeiro a integração, devido ao 
		// tempo que leva os jobs de 1 até 8, conforme testes realizados, 
		// acarretar chegar na hora do job da Aguas e ainda não terem terminado
		//--------------------------------------------------------------------//		
		lStartUp := .F.
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Espera                                                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//PtInternal(1,"WF Integracao XML - Sleeping...("+StrZero(nSleepJob,3)+")")
		Conout("WF Integracao XML - Sleeping...("+StrZero(nSleepJob,3)+")")
		cnW5   := ""
		cnW6   := ""
					
		Sleep(_nSleep)  																					//FR 17/07/2020
		
		//Ftp e Classificação Automática
		cDate  := Dtos( Date() )
		cHora  := Substr(Time(),1,5)
		nHr    := 0
		
		//FR - Array de retorno com os parâmetros do job
		//               1-job habilitado   2-class habilitada  3-hr integração 4-hr classifi. 
		//aadd( aAguas, { cFtp            , cCla               , cFhr            , cChr       , "", "" } )
		
		If cXmTpJobCx == "1"            //Jobs concorrentes
		
			For nW := 1 To Len( aAguas )
			 
			    //FR - 18/08/2020 - cálculo da hora da integração
				nH1 := ( Val(substr(cHora,1,2))            )
			    nM1 := ( Val(substr(cHora,4,2))/60         ) 
			    nH2 := ( Val(Substr(aAguas[nW][3],1,2))    )
			    nM2 := ( Val(Substr(aAguas[nW][3],4,2))/60 )
				//nHr := Val(substr(cHora,1,2)) -  Val(Substr(aAguas[nW][3],1,2)) 							//FR 11/07/2020							
			    
			    If !Empty(aAguas[nW][3]) .and. Alltrim(aAguas[nW][3]) <> ":"		//FR - 18/08/2020 - se a hora estiver vazia, é porque não foi parametrizado, então não pode executar
				    nHr := ( nH1 + nM1) - ( nH2 + nM2)                                        
				                                                         
					If !Empty(cItAtLOG) .and. !Empty(cItAtPAS)  		//FR - 05/08/2022 - PROJETO POLITEC - verificar se existe usuário/senha cadastrado
						If !Empty(aAguas[nW][1]) .And. aAguas[nW][5] < cDate .And. (nHr >= 0 .and. nHr <= 6 ) 		//FR 11/07/2020 < XM_ITATHRC >  espaço de 3h de tolerância, pois antes somente com a hora exata, o job não conseguia em pouco tempo realizar todas as funções até o horário agendado já teria passado 
							
							StartJob("U_XMLWF01A",GetEnvServer(),.F.,aEntidades[nW],"A,B"         ,"A",nTotalCount) //Integração Externa FTP -> Aguas do Brasil
							aAguas[nW][5] := cDate
							
						Else
							If !Empty(aAguas[nW][3]) .and. Alltrim(aAguas[nW][3]) <> ":" .and. nMostraI <= 0
								CONOUT("<GESTAOXML> AGUARDANDO HORARIO P/ INTEGRACAO  ===> " + aAguas[nW][5] + " / " + aAguas[nW][3] + " <====")
								nMostraI++
							Endif 
						Endif
					Endif 

				Endif				
				Sleep(_nSleep)
				
				//FR - 18/08/2020 - hora da classificação
				nH1 := ( Val(substr(cHora,1,2))            )
			    nM1 := ( Val(substr(cHora,4,2))/60         ) 
			    nH2 := ( Val(Substr(aAguas[nW][4],1,2))    )
			    nM2 := ( Val(Substr(aAguas[nW][4],4,2))/60 )
			    			
			    If !Empty(aAguas[nW][4]) .and. Alltrim(aAguas[nW][4]) <> ":"		//FR - 18/08/2020 - se a hora estiver vazia, é porque não foi parametrizado, então não pode executar
				    nHr := ( nH1 + nM1) - ( nH2 + nM2)     														//FR 18/08/2020
					                                                     
					If !Empty(aAguas[nW][2]) .And. aAguas[nW][6] < cDate .And. (nHr >= 0 .and. nHr <= 6 )		//FR 11/07/2020 < XM_CLATHRC > espaço de 3h de tolerância, pois antes somente com a hora exata, o job não conseguia em pouco tempo realizar todas as funções até o horário agendado já teria passado
						
						StartJob("U_XMLWF01A",GetEnvServer(),.F.,aEntidades[nW],"A,B"         ,"B",nTotalCount) //Classificação Automática - NFe Combustiveis -> Aguas do Brasil
						aAguas[nW][6] := cDate																	//Classificação Automática - NFe Energia -> Kroma  //FR 18/08/2020
						
					Else				
						If !Empty(aAguas[nW][4]) .and. Alltrim(aAguas[nW][4]) <> ":" .and. nMostraC <= 0
							CONOUT("<GESTAOXML> AGUARDANDO HORARIO P/ CLASS AUTOMAT  ===> " + aAguas[nW][6] + " / " + aAguas[nW][4] + " <====")
							nMostraC++
						Endif					 
					Endif
				Endif
				
			Next nW
			
		Else    					//Jobs em Fila			
		    
		    //cnW5 := "20180101" //FR TESTE RETIRAR
		    //cnW6 := "20180101" //FR TESTE RETIRAR
		     
			For nW := 1 To Len( aAguas )
			
				//FR - 18/08/2020 - cálculo da hora da integração
			    nH1 := ( Val(substr(cHora,1,2))            )
			    nM1 := ( Val(substr(cHora,4,2))/60         ) 
			    nH2 := ( Val(Substr(aAguas[nW][3],1,2))    )
			    nM2 := ( Val(Substr(aAguas[nW][3],4,2))/60 )
				//nHr := (  Val(substr(cHora,1,2)) + (Val(substr(cHora,4,2))/60)  ) -  (  Val(Substr(aAguas[nW][3],1,2)) + (Val(Substr(aAguas[nW][3],4,2))/60)  )				 			//FR 11/07/2020			
				If !Empty(aAguas[nW][3]) .and. Alltrim(aAguas[nW][3]) <> ":"		//FR - 18/08/2020 - se a hora estiver vazia, é porque não foi parametrizado, então não pode executar
					nHr := ( nH1 + nM1) - ( nH2 + nM2)                                        
					If !Empty(cItAtLOG) .and. !Empty(cItAtPAS)  		//FR - 05/08/2022 - PROJETO POLITEC - verificar se existe usuário/senha cadastrado, se estiver vazio, não deixa prosseguir no job A
						
						If !Empty(aAguas[nW][1]) .And. cnW5 < cDate .And. (nHr >= 0 .and. nHr <= 6 )       			//FR 11/07/2020 < XM_ITATHRC >  espaço de 3h de tolerância, pois antes somente com a hora exata, o job não conseguia em pouco tempo realizar todas as funções até o horário agendado já teria passado
							
							//If !Empty(aAguas[nW][3])  
							//	CONOUT("<GESTAOXML> ACESSOU INTEGRACAO AGENDADA DIA/HORA ===> " + cnW5 + " / " + aAguas[nW][3] + " <====")     
							//Endif
							
							U_XMLWF01B(aEntidades,"A,B"         ,"A",nTotalCount,aAguas)  //Integração Externa FTP -> Aguas do Brasil     //FR 02/07/2020 //FR VOLTAR
							cnW5 := cDate         
							Exit
							
						Else
							If !Empty(aAguas[nW][3]) .and. Alltrim(aAguas[nW][3]) <> ":" .and. nMostraI <= 0
								CONOUT("<GESTAOXML> AGUARDANDO HORARIO P/ INTEGRACAO  ===> " + cnW5 + " / " + aAguas[nW][3] + " <====")
								nMostraI++
							Endif 
						Endif
					Endif 

				Endif
			Next nW
			
			Sleep(_nSleep)  																				//FR 17/07/2020
			 
			For nW := 1 To Len( aAguas )
				//FR - 18/08/2020 - hora da classificação
				nH1 := ( Val(substr(cHora,1,2))            )
			    nM1 := ( Val(substr(cHora,4,2))/60         ) 
			    nH2 := ( Val(Substr(aAguas[nW][4],1,2))    )
			    nM2 := ( Val(Substr(aAguas[nW][4],4,2))/60 )
			
				//nHr := (   Val(substr(cHora,1,2)) + ( Val( substr(cHora,4,2) )/60 )  )   -  (  Val(Substr(aAguas[nW][4],1,2))  +  (Val( Substr(aAguas[nW][4],4,2) )/60) )							//FR 11/07/2020
				If !Empty(aAguas[nW][4]) .and. Alltrim(aAguas[nW][4]) <> ":"					//FR - 18/08/2020 - se a hora estiver vazia, é porque não foi parametrizado, então não pode executar
					nHr := ( nH1 + nM1) - ( nH2 + nM2) 
												                
					If !Empty(aAguas[nW][2]) .And. cnW6 < cDate .And. (nHr >=0 .and. nHr <= 6)  //FR 11/07/2020 < XM_CLATHRC > espaço de 3h de tolerância, pois antes somente com a hora exata, o job não conseguia em pouco tempo realizar todas as funções até o horário agendado já teria passado
					
						//If !Empty(aAguas[nW][4])  
						//	CONOUT("<GESTAOXML> ACESSOU CLASS AUTOMAT AGENDADA DIA/HORA ===> " + cnW6 + " / " + aAguas[nW][4] + " <====")
						//Endif				
						
						U_XMLWF01B(aEntidades,"A,B"         ,"B",nTotalCount,aAguas)  //Classificação Automática - NFe Combustiveis -> Aguas do Brasil  //FR 02/07/2020
						cnW6 := cDate      											  //Classificação Automática - NFe Energia -> Kroma  //FR 18/08/2020
						Exit
						
					Else
					
						If !Empty(aAguas[nW][4]) .and. Alltrim(aAguas[nW][4]) <> ":" .and. nMostraC <= 0
							CONOUT("<GESTAOXML> AGUARDANDO HORARIO P/ CLASS AUTOMAT  ===> " + cnW6 + " / " + aAguas[nW][4] + " <====")
							nMostraC++
						Endif
					Endif
				Endif
				
			Next nW

		EndIf				//If cXmTpJobCx
		////AGUAS
		
	     
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Espera                                                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//PtInternal(1,"WF Integracao XML - Sleeping...("+StrZero(nSleepJob,3)+")")
		Conout("WF Integracao XML - Sleeping...("+StrZero(nSleepJob,3)+")")
		
		Sleep(_nSleep)  										//FR 17/07/2020
		
		//-----------------------------------//
		//Jobs de 1 ao 8	
		//-----------------------------------//    
		If cXmTpJobCx == "1"      //FR 1=Jobs concorrentes  <XM_TPJOBCX>
		
			For nX := 1 To Len(aRotina)
			
				For nW := 1 To Len(aEntidades)
				    
			    	nTotalCount++

			    	Sleep(_nSleep)  							//FR 17/07/2020
			    	if "1" $ aRotina[nX][2] .Or. "X" $ aRotina[nX][2]
			    	
						StartJob("U_XMLWF01A",GetEnvServer(),.F.,aEntidades[nW],aRotina[nX][2],"1",nTotalCount)
					
					endif
					
			    	if "2" $ aRotina[nX][2] .Or. "X" $ aRotina[nX][2]
						
						StartJob("U_XMLWF01A",GetEnvServer(),.F.,aEntidades[nW],aRotina[nX][2],"2",nTotalCount)
					
					endif
					
			    	if "3" $ aRotina[nX][2] .Or. "X" $ aRotina[nX][2]
			    	
						StartJob("U_XMLWF01A",GetEnvServer(),.F.,aEntidades[nW],aRotina[nX][2],"3",nTotalCount)
					
					endif
					
			    	if "4" $ aRotina[nX][2] .Or. "X" $ aRotina[nX][2]
			    	
						StartJob("U_XMLWF01A",GetEnvServer(),.F.,aEntidades[nW],aRotina[nX][2],"4",nTotalCount)
					
					endif
					
			    	if "5" $ aRotina[nX][2] .Or. "X" $ aRotina[nX][2]
						
						StartJob("U_XMLWF01A",GetEnvServer(),.F.,aEntidades[nW],aRotina[nX][2],"5",nTotalCount)
				
					endif
					
			    	if "6" $ aRotina[nX][2] .Or. "X" $ aRotina[nX][2]
						
						StartJob("U_XMLWF01A",GetEnvServer(),.F.,aEntidades[nW],aRotina[nX][2],"6",nTotalCount)
				
					endif
					
					if "8" $ aRotina[nX][2] .Or. "X" $ aRotina[nX][2]
						
						StartJob("U_XMLWF01A",GetEnvServer(),.F.,aEntidades[nW],aRotina[nX][2],"8",nTotalCount)
				
					endif
					
					if "9" $ aRotina[nX][2] .Or. "X" $ aRotina[nX][2]
						
						StartJob("U_XMLWF01A",GetEnvServer(),.F.,aEntidades[nW],aRotina[nX][2],"9",nTotalCount)
				
					endif

			    	if ! Empty( aAguas[nW][1] )
			    	
						StartJob("U_XMLWF01A",GetEnvServer(),.F.,aEntidades[nW],"A,B"         ,"A",nTotalCount)  //Integração Externa FTP -> Aguas do Brasil
					
					endif
					
			    	if ! Empty( aAguas[nW][2] )
			    	
						StartJob("U_XMLWF01A",GetEnvServer(),.F.,aEntidades[nW],"A,B"         ,"B",nTotalCount)  //Classificação Automática - NFe Combustiveis -> Aguas do Brasil
					
					endif
					If nX == 1 .And. lStartup
					
						Sleep(nStartUp)
						
					Else
					
						Sleep(_nSleep)  							//FR 17/07/2020
						
					EndIf


				Next nW
				
			Next nX
			
		Else          	//FR 2=Jobs em Fila
		
			For nX := 1 To Len(aRotina)
			
			   	nTotalCount++
			   	
			   	Sleep(_nSleep)  						   			//FR 17/07/2020
			   	if "1" $ aRotina[nX][2] .Or. "X" $ aRotina[nX][2]
					
					U_XMLWF01B(aEntidades,aRotina[nX][2],"1",nTotalCount,aAguas)
				
				endif
				
			   	if "2" $ aRotina[nX][2] .Or. "X" $ aRotina[nX][2]					
				
					U_XMLWF01B(aEntidades,aRotina[nX][2],"2",nTotalCount,aAguas)
				
				endif
				
				
			   	if "3" $ aRotina[nX][2] .Or. "X" $ aRotina[nX][2]					
				
					U_XMLWF01B(aEntidades,aRotina[nX][2],"3",nTotalCount,aAguas)
				
				endif
				
			   	if "4" $ aRotina[nX][2] .Or. "X" $ aRotina[nX][2]					
				
					U_XMLWF01B(aEntidades,aRotina[nX][2],"4",nTotalCount,aAguas)
				
				endif
				
			   	if "5" $ aRotina[nX][2] .Or. "X" $ aRotina[nX][2]			
				
					U_XMLWF01B(aEntidades,aRotina[nX][2],"5",nTotalCount,aAguas)
				
				endif
				
			   	if "6" $ aRotina[nX][2] .Or. "X" $ aRotina[nX][2]					
				
					U_XMLWF01B(aEntidades,aRotina[nX][2],"6",nTotalCount,aAguas)
				
				endif
				
				if "8" $ aRotina[nX][2] .Or. "X" $ aRotina[nX][2]					
				
					U_XMLWF01B(aEntidades,aRotina[nX][2],"8",nTotalCount,aAguas)
				
				endif
				
				if "9" $ aRotina[nX][2] .Or. "X" $ aRotina[nX][2]					
				
					U_XMLWF01B(aEntidades,aRotina[nX][2],"9",nTotalCount,aAguas)
				
				endif

				//retirado porque já é chamado logo mais abaixo //FR - 02/07/2020
				//StartJob("U_XMLWF01B",GetEnvServer(),.F.,aEntidades,"A,B"         ,"A",nTotalCount,aAguas)  //Integração Externa FTP -> Aguas do Brasil     //FR 02/07/2020
				
				//StartJob("U_XMLWF01B",GetEnvServer(),.F.,aEntidades,"A,B"         ,"B",nTotalCount,aAguas)  //Classificação Automática - NFe Combustiveis -> Aguas do Brasil //FR 02/07/2020
				
				If nX == 1 .And. lStartup
				
					Sleep(nStartUp)
					
				Else
				
					Sleep(_nSleep)  							//FR 17/07/2020
										
				EndIf
				
			Next nX
			
		Endif
		
	Else
	
		ConOut(cMsgModelo + IIF(cThreadID=="1","[ThreadID:"+AllTrim(Str(ThreadID(),10))+"] ","")+" Job XML desabilitado...")
	
	EndIf
	
	if nTotalCount > 998
		nTotalCount := 0
	endif

	If KillApp()
		Exit
	EndIf
	
	//RstMvBuff()
	DelClassIntf()
	
	nMostraI := 0 			//FR - 06/08/2020
	nMostraC := 0			//FR - 06/08/2020
EndDo

Return(nil)



User Function XMLWF01B( aEntidades, cIDJob, cJobAT, nTotalCount, aAguas )

Local nW := 0
Local lRet := .F.

//PtInternal(1,"WF Integracao XML - Executando em Fila JOB...("+cJobAT+")")
Conout("WF Integracao XML - Executando em Fila JOB...("+cJobAT+")")

For nW := 1 To Len( aEntidades )
   	
   	if "1" $ cJobAT    //Aguardar fim da execução para a próxima filial -> .T.
		
		lRet := StartJob("U_XMLWF01A",GetEnvServer(),.T.,aEntidades[nW],cIDJob,"1",nTotalCount)
	
	endif
	
   	if "2" $ cJobAT
   	
		lRet := StartJob("U_XMLWF01A",GetEnvServer(),.T.,aEntidades[nW],cIDJob,"2",nTotalCount)

	endif
	
   	if "3" $ cJobAT
		
		lRet := StartJob("U_XMLWF01A",GetEnvServer(),.T.,aEntidades[nW],cIDJob,"3",nTotalCount)
	
	endif
	
	if "4" $ cJobAT
	
		lRet := StartJob("U_XMLWF01A",GetEnvServer(),.T.,aEntidades[nW],cIDJob,"4",nTotalCount)
	
	endif
	
	if "5" $ cJobAT
		
		lRet := StartJob("U_XMLWF01A",GetEnvServer(),.T.,aEntidades[nW],cIDJob,"5",nTotalCount)
	
	endif
	
	if "6" $ cJobAT
		
		lRet := StartJob("U_XMLWF01A",GetEnvServer(),.T.,aEntidades[nW],cIDJob,"6",nTotalCount)
	
	endif
	
	if "8" $ cJobAT
		
		lRet := StartJob("U_XMLWF01A",GetEnvServer(),.T.,aEntidades[nW],cIDJob,"8",nTotalCount)
	
	endif
	
	if "9" $ cJobAT
		
		lRet := StartJob("U_XMLWF01A",GetEnvServer(),.T.,aEntidades[nW],cIDJob,"9",nTotalCount)
	
	endif
	if "A" $ cJobAT .And. ! Empty( aAguas[nW][1] )
		
		lRet := StartJob("U_XMLWF01A",GetEnvServer(),.T.,aEntidades[nW],cIDJob,"A",nTotalCount)  //Integração Externa FTP -> Aguas do Brasil
		//U_XMLWF01A(aEntidades[nW],cIDJob,"A",nTotalCount)  //Integração Externa FTP -> Aguas do Brasil    //FR TESTE RETIRAR
	
	endif
	
	if "B" $ cJobAT .And. ! Empty( aAguas[nW][2] )
		
		lRet := StartJob("U_XMLWF01A",GetEnvServer(),.T.,aEntidades[nW],cIDJob,"B",nTotalCount)  //Classificação Automática - NFe Combustiveis -> Aguas do Brasil
		//U_XMLWF01A(aEntidades[nW],cIDJob,"B",nTotalCount)  //Classificação Automática - NFe Combustiveis -> Aguas do Brasil //FR TESTE RETIRAR
	
	endif
	
Next nW

Return( .T. )

/*/
/*/
//cIdent = Empresa + filial
//cIdJob = "1,2,3,4,5,6"
//cJobAt = qual job será executado
//nTotalCount = Contador pode-se iniciar com zero
User Function XMLWF01A( cIdEnt, cIDJob, cJobAT, nTotalCount )

Local lContinua   := .T.

Local cTimeSPEDWF := Time()
Local cArqLck     := ""
Local nHdl        := 0 // para trava

Local nMaxFor     := 0
Local cTime       := ""

Local nY          := 0
Local nCount      := 0
Local nTimes      := 1
Local nMemory     := 1

//Variaveis de teste
//Local cIdEnt := "9901"
//Local cIDJob := "6"
//Local cJobAT := "6"
//Local nTotalCount := 0

Local cEmp      := Substr(cIdEnt,1,2)
Local cFilEmp   := Substr(cIdEnt,3,len(cIdEnt)-2)	 
Local aTables	:= {} // incluido apenas para compatibilizar o teste para nao consumir licencas

Local nZ := 0 //declaracao
Local aParams       := {}  
Local cError        := ""  
                 
Local cDir      := ""
Local cDirLog   := ""
Local cURL      := ""
Local cBar      := "" //Iif(lUnix,"/","\")

//Local nTamFil     := 0                     	//FR - 16/07/2020
//Local cFILLANT    := ""                     //FR - 16/07/2020
Private cDatahora  	:= 	""
Private cMsgModelo  := "[XML]"
Private cThreadID	:= "0"
Private nSleepJob 	:= 0
Private oProcess  := Nil
Private lEnd      := .F. 
Private lAuto     := .T.
Private cLogProc  := ""

LoadParams(@aParams,@cError,.T.)
                                    
cEnable    := aParams[1][2]
nStartUp   := aParams[3][2]
cThreadID  := aParams[4][2]
nSleepJob  := aParams[6][2]
cHF_WF     := aParams[7][2]

ConOut(cMsgModelo + IIF(cThreadID=="1","[ThreadID:"+AllTrim(Str(ThreadID(),10))+"] ","")+" Carregando Parametros...")

If cEnable == "0" 

	ConOut(cMsgModelo + IIF(cThreadID=="1","[ThreadID:"+AllTrim(Str(ThreadID(),10))+"] ","")+" Job XML desabilitado...")
	
	For nZ := 0 To nSleepJob
	
		Sleep(GetNewPar("XM_ITSLEEP",10000) )  							//FR 17/07/2020
		
		If KillApp()
			Exit
		EndIf
		
	Next nZ
	
	Return(nil)
	
EndIf

//RpcSetType(3)                                                         
/*
RpcSetEnv - Abertura do ambiente em rotinas automáticas 
[ cRpcEmp ]  	-- cEmp
[ cRpcFil ]     -- cFilEmp
[ cEnvUser ] 
[ cEnvPass ] 
[ cEnvMod ]     -- CFG
[ cFunName ] 
[ aTables ] 
[ lShowFinal ]  -- F
[ lAbend ]      -- F [ default .T. ]
[ lOpenSX ]     --   [ default .T. ]
[ lConnect ] 	--   [ default .T. ]
*/
//IF .NOT. RpcSetEnv( cEmp, cFilEmp,,,"COM",,{ "SF1","SF2","SD1","SD2","SF4","SB5","SF3","SB1" },.F.,.F.)
IF .NOT. RpcSetenv( cEmp , cFilEmp , , , "CFG" , , aTables , .F. , .F. , .T. , .T. )
	
	If cHF_WF>="1"
		ConOut("[IMPXML] " + "JOB ("+cIdEnt+"): Não Foi Possível estabelecer conexão com a empresa.")
	EndIf
	
	DelClassIntf()
	
	Return(.T.)
	
EndIf

cBar     := Iif(IsSrvUnix(),"/","\")
cDir     := AllTrim(SuperGetMv("MV_X_PATHX"))                     
cDir 	 := StrTran(cDir,cBar+cBar,cBar)
cDirLog  := AllTrim(cDir+cBar+"Log"+cBar)                     
cDirLog	 := StrTran(cDirLog,cBar+cBar,cBar)
cURL     := AllTrim(GetNewPar("XM_URL",""))

If Empty(cURL)
	cURL  := AllTrim(SuperGetMv("MV_SPEDURL"))
EndIf

/*Cria arquivo de Lock dependendo do modelo a ser processado*/
cArqLck     := GetPathSemaforo()+"HFWFXML_"+cIdEnt+"_"+cJobAT+".LCK"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Controle de execucao. Nao permite que o mesmo JOB seja inicializado mais³
//³de uma vez                                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MakeDir(GetPathSemaforo())

Do While ! KillApp()

	cDatahora  	:= 	dTos(date()) +"-"+ Substr(Time(),1,2) + "-" + Substr(Time(),4,2)
	
	//PtInternal(1,"WF XML - Emp: "+cIdEnt+" - Job: "+cJobAT+" - Verificando Semaforo." )
	Conout("WF XML - Emp: "+cIdEnt+" - Job: "+cJobAT+" - Verificando Semaforo." )
	
	ConOut(cArqLck)
	
	
	lContinua := TravaJov("TRAVA", cArqLck, @nHdl)  //só essa fera aqio
	
	Begin Sequence
		
		If lContinua
		
			cTeste := "b"
			cLogProc := ""
			
			//PtInternal(1,"WF Integracao XML - Emp: "+cIdEnt+" - Job: "+cJobAT+" - Times: "+StrZero(nTimes,2)+" - Total: "+StrZero(nTotalCount,3))
			Conout("WF Integracao XML - Emp: "+cIdEnt+" - Job: "+cJobAT+" - Times: "+StrZero(nTimes,2)+" - Total: "+StrZero(nTotalCount,3))
			If cHF_WF>="1"
				
				ConOut(cMsgModelo + IIF(cThreadID=="1","[ThreadID:"+AllTrim(Str(ThreadID(),10))+"] ","") + "JOB ("+cIdEnt+"): "+cJobAT+" Times: "+AllTrim(Str(nTimes,10))+" Memory: "+AllTrim(Str(nMemory,10))+ " Time: "+cTimeSPEDWF)
			
			EndIf      
			                                                  
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Job 1                                                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ("1" $ cIDJob .Or. "X" $ cIDJob) .And. cJobAT == "1"
	  			
	  			nCount := 0
	  			
				cTime  := Time()
	
				U_AutoXml1(1,lAuto,@lEnd,oProcess,@cLogProc,@nCount,cUrl)
	
				If cHF_WF=="1" .Or. (cHF_WF=="2" .And. nCount>0 )
					
					ConOut(cMsgModelo + IIF(cThreadID=="1","[ThreadID:"+AllTrim(Str(ThreadID(),10))+"] ","") + "Verificando e-mails ("+cIdEnt+"-"+cTime+" a "+Time()+"): "+AllTrim(Str(nCount,10)))
				
				EndIf		
				
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Job 2                                                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ("2" $ cIDJob .Or. "X" $ cIDJob) .And. cJobAT == "2"
				
				nCount := 0
				cTime  := Time()
	
				U_AutoXml1(2,lAuto,@lEnd,oProcess,@cLogProc,@nCount,cUrl)
	
				If cHF_WF=="1" .Or. (cHF_WF=="2" .And. nCount>0 )
					
					ConOut(cMsgModelo + IIF(cThreadID=="1","[ThreadID:"+AllTrim(Str(ThreadID(),10))+"] ","") + "Processando XMLs ("+cIdEnt+"-"+cTime+" a "+Time()+"): "+AllTrim(Str(nCount,10)))
				
				EndIf
				
			EndIf
				
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Job 3                                                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ("3" $ cIDJob .Or. "X" $ cIDJob) .And. cJobAT == "3"
				
				nCount := 0
				cTime  := Time()	
	
				U_AutoXml1(3,lAuto,@lEnd,oProcess,@cLogProc,@nCount,cUrl)
	
				If cHF_WF=="1" .Or. (cHF_WF=="2" .And. nCount>0 )
					
					ConOut(cMsgModelo + IIF(cThreadID=="1","[ThreadID:"+AllTrim(Str(ThreadID(),10))+"] ","") + "Status XMLs ("+cIdEnt+"-"+cTime+" a "+Time()+"): "+AllTrim(Str(nCount,10)))
				
				EndIf	
					
			EndIf
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Job 4                                                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ("4" $ cIDJob .Or. "X" $ cIDJob) .And. cJobAT == "4"
				
				nCount := 0
				cTime  := Time()	
	
				rstmvbuff()
				
				cDtCons := GetNewPar("XM_DT_CONS","20120101",cFilAnt)
				
				//Vamos fazer ser exclusivo esse bixo aqui
				SX6->( dbSetOrder( 1 ) )
				If !SX6->( dbSeek( cFilAnt + "XM_DT_CONS" ) )
					
					SX6->(RecLock("SX6",.T.))
						SX6->X6_FIL     := cFilAnt //xFilial( "SX6" )
						SX6->X6_VAR     := "XM_DT_CONS"
						SX6->X6_TIPO    := "C"
						SX6->X6_DESCRIC := "Data de execução da ultima consulta XML na SEFAZ."
						SX6->(MsUnLock())
					PutMv("XM_DT_CONS",cDtCons)
					
				EndIf
				
				//cHrCons := GetNewPar("XM_HR_CONS","22:00")
				
				If cDtCons <= Dtos(dDataBase) .And. ( Time() <= "08:00" .or. Time() >= "18:00" ) //Time() >= cHrCons
					
					U_AutoXml1(4,lAuto,@lEnd,oProcess,@cLogProc,@nCount,cUrl)
					PutMv("XM_DT_CONS",dTos(dDataBase))
					
				EndIf            
	
				If cHF_WF=="1" .Or. (cHF_WF=="2" .And. nCount>0 )
					
					ConOut(cMsgModelo + IIF(cThreadID=="1","[ThreadID:"+AllTrim(Str(ThreadID(),10))+"] ","") + "Consulta XMLs ("+cIdEnt+"-"+cTime+" a "+Time()+"): "+AllTrim(Str(nCount,10)))
				
				EndIf	
					
			EndIf
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Job 5                                                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ("5" $ cIDJob .Or. "X" $ cIDJob) .And. cJobAT == "5"
				
				nCount := 0
				cTime  := Time()	
	
				U_AutoXml1(5,lAuto,@lEnd,oProcess,@cLogProc,@nCount,cUrl)
	
				If cHF_WF=="1" .Or. (cHF_WF=="2" .And. nCount>0 )
				
					ConOut(cMsgModelo + IIF(cThreadID=="1","[ThreadID:"+AllTrim(Str(ThreadID(),10))+"] ","") + "E-mails de Notificações ("+cIdEnt+"-"+cTime+" a "+Time()+"): "+AllTrim(Str(nCount,10)))
				
				EndIf	
					
			EndIf
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Job 6                                                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//Colocado Antes do 2
			If ("6" $ cIDJob .Or. "X" $ cIDJob) .And. cJobAT == "6"  // AQUIIIII por causa da ZBSSSSSS
				
				nCount := 0
				cTime  := Time()	
	
				U_AutoXml1(6,lAuto,@lEnd,oProcess,@cLogProc,@nCount,cUrl)
//				If "2" $ cIDJob .Or. "X" $ cIDJob  //Fazer a importação para a ZBZ]  NÃO PRECISA MAIS, PORQUE AGORA VAI DIRETO PELO ANTERIOR
//					U_AutoXml1(2,lAuto,@lEnd,oProcess,@cLogProc,nCount,cUrl)  //deixar o nCount do download
//				Endif
	
				If cHF_WF=="1" .Or. (cHF_WF=="2" .And. nCount>0 )
					
					ConOut(cMsgModelo + IIF(cThreadID=="1","[ThreadID:"+AllTrim(Str(ThreadID(),10))+"] ","") + "Download XML ("+cIdEnt+"-"+cTime+" a "+Time()+"): "+AllTrim(Str(nCount,10)))
				
				EndIf		
				
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Job 8 - Envia e Baixa PDF convertido                                                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ("8" $ cIDJob .Or. "X" $ cIDJob) .And. cJobAT == "8"  
				
				nCount := 0
				cTime  := Time()	
	
				U_AutoXml1(8,lAuto,@lEnd,oProcess,@cLogProc,@nCount,cUrl)
	
				If cHF_WF=="1" .Or. (cHF_WF=="2" .And. nCount>0 )
					
					ConOut(cMsgModelo + IIF(cThreadID=="1","[ThreadID:"+AllTrim(Str(ThreadID(),10))+"] ","") + "Envia e Baixa PDF convertido ("+cIdEnt+"-"+cTime+" a "+Time()+"): "+AllTrim(Str(nCount,10)))
				
				EndIf		
				
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Job 9 - Download NFSE API                                                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ("9" $ cIDJob .Or. "X" $ cIDJob) .And. cJobAT == "9"  
				
				nCount := 0
				cTime  := Time()	
	
				U_AutoXml1(9,lAuto,@lEnd,oProcess,@cLogProc,@nCount,cUrl)
	
				If cHF_WF=="1" .Or. (cHF_WF=="2" .And. nCount>0 )
					
					ConOut(cMsgModelo + IIF(cThreadID=="1","[ThreadID:"+AllTrim(Str(ThreadID(),10))+"] ","") + "Download NFSE API ("+cIdEnt+"-"+cTime+" a "+Time()+"): "+AllTrim(Str(nCount,10)))
				
				EndIf		
				
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Job A - Integração Externa SFTP -> Aguas do Brasil, Ver Parâmetros       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If  "A" $ cIDJob .And. cJobAT == "A"
				
				nCount := 0
				cTime  := Time()	
	
				U_AutoXml2("A",lAuto,@lEnd,oProcess,@cLogProc,@nCount,cUrl)

				If (cHF_WF=="1" .And. nCount>=0 ) .Or. (cHF_WF=="2" .And. nCount>0 )
					
					ConOut(cMsgModelo + IIF(cThreadID=="1","[ThreadID:"+AllTrim(Str(ThreadID(),10))+"] ","") + "Integração Externa SFTP ("+cIdEnt+"-"+cTime+" a "+Time()+"): "+AllTrim(Str(nCount,10)))
				
				Elseif (cHF_WF=="2" .And. nCount<0 )
					
					ConOut(cMsgModelo + IIF(cThreadID=="1","[ThreadID:"+AllTrim(Str(ThreadID(),10))+"] ","") + "Parâmetro (JOB) Integração Externa SFTP Desabilitado ("+cIdEnt+"-"+cTime+" a "+Time()+"). ")
				
				EndIf
						
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Job A - Integração Externa FTP -> Aguas do Brasil, Ver Parâmetros       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If  "B" $ cIDJob .And. cJobAT == "B"  //KROMA TAMBÉM USA ESTA OPÇÃO "B"
				
				nCount := 0
				cTime  := Time()

				U_AutoXml2("B",lAuto,@lEnd,oProcess,@cLogProc,@nCount,cUrl)

				If (cHF_WF=="1" .And. nCount>=0 ) .Or. (cHF_WF=="2" .And. nCount>0 )
					
					ConOut(cMsgModelo + IIF(cThreadID=="1","[ThreadID:"+AllTrim(Str(ThreadID(),10))+"] ","") + "Classificacao Automatica ("+cIdEnt+"-"+cTime+" a "+Time()+"): "+AllTrim(Str(nCount,10)))
				
				Elseif (cHF_WF=="2" .And. nCount<0 )
					
					ConOut(cMsgModelo + IIF(cThreadID=="1","[ThreadID:"+AllTrim(Str(ThreadID(),10))+"] ","") + "Parâmetro (JOB) Classificação Automática Desabilitado ("+cIdEnt+"-"+cTime+" a "+Time()+"). ")
				
				EndIf		
				
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Rotina de espera de processamento - importante para o consumo da CPU    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbCommit()
			cTimeSPEDWF := Time()
			DelClassIntf()
	
			If !ExistDir(cDirLog)
			
				Makedir(cDirLog)
			
			EndIf		
			
			MemoWrite(cDirLog+"XML-"+cDataHora+".log",cLogProc)
	
			nMaxFor := 1 //IIf(nTimes==0,10,IIf(nTimes==1,nSleepJob,nSleepJob*2))
			
			//PtInternal(1,"WF Integracao XML - Emp: "+cIdEnt+" - Job: "+cJobAT+" - Sleeping...("+StrZero(nMaxFor,3)+")")
			Conout("WF Integracao XML - Emp: "+cIdEnt+" - Job: "+cJobAT+" - Sleeping...("+StrZero(nMaxFor,3)+")")
			For nY := 1 To nMaxFor
			
	  			Sleep(30000)  							//FR 17/07/2020
	  				
				If KillApp()
					Exit
				EndIf
				
			Next nY        
			                           
			nTimes++
			nMemory++
			
			ConOut("[IMPXML] Finalizou " + "JOB ("+cIdEnt+")"+" - Job: "+cJobAT+".")
			
		Else
		
			ConOut("[IMPXML] Não Liberado foi finalizado de forma inesperada. Por favor tente novamente" + "JOB ("+cIdEnt+")"+" - Job: "+cJobAT+".")
			
		Endif
		
		TravaJov("SOLTA", cArqLck, @nHdl)
		
		Recover
		
		ConOut("[IMPXML] Interrompeu " + "JOB ("+cIdEnt+")"+" - Job: "+cJobAT+".")
		TravaJov("SOLTA", cArqLck, @nHdl)
		
	End Sequence
	
	Exit //Ocrim

EndDo

ConOut("[IMPXML] " + "JOB ("+cIdEnt+"): Finalizar Conexão.")

RstMvBuff()
DelClassIntf()
RpcClearEnv()

//Quit

Return(.T.)


Static Function LoadParams(aParams,cError,lDefault)

Local lRet       := .T.
Local cFileCfg   := "hfcfgxml001a.xml"
Local aDados     := {}
Local Nx := 0 //declaracao 
Private oXml

Default lDefault := .F.

/*                 
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
*/

	Aadd(aDados,{"ENABLE"  ,"1"		   		,"Servico Habilitado" 					}) 
	Aadd(aDados,{"ENT"     ,{"01"}  		,"Empresa/Filial principal do processo" }) 
	Aadd(aDados,{"WFDELAY" ,600 		   		,"Atraso apos a primeira execucao"  }) 
	Aadd(aDados,{"THREADID","1"		   		,"Identificador de Thread [Debug]"   	}) 
	Aadd(aDados,{"JOBS"    ,"2"		   		,"Servico a ser processado" 			}) 
	Aadd(aDados,{"SLEEP"   ,30000	 		,"Tempo de espera"   					}) 
	Aadd(aDados,{"CONSOLE" ,"1"		   		,"Informacoes dos processos no console" }) 

aParams := aDados

Return(lRet)           



Static Function LoadSm0( aENT, aAguas, cXmTpJobCx, _nSleep, cItAtLOG, cItAtPAS )

Local aRet := {} //aENT
Local aSm0 := {}
Local aSm2 := {}
Local cEmp := ""
Local cFil := ""
Local cFtp := ""
Local cCla := ""
Local cFhr := ""
Local cChr := ""
Local nI   := 0

Default aAguas := {}
Default cXmTpJobCx := "1"

aRet := aClone( aENT )

If Len( aENT ) >= 1

	cEmp := Substr(aENT[1],1,2)
	cFil := Substr(aENT[1],3,len(aENT[1])-2)  //4-2 = 2

	ConOut("Abrindo empresa "+cEmp+" e filial "+cFil+" para executar FWLoadSM0(). ")

	//RpcSetType(3)
	RpcSetEnv( cEmp, cFil ) //PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFil 

	aSm0 := FWLoadSM0()
	
	if Len( aSm0 ) > 0

		aRet := {}
		
		For nI := 1 To Len( aSm0 )
		   
			dbSelectArea("SM0")
			dbSetOrder(1)
			if dbSeek(aSm0[nI][1]+aSm0[nI][2])
			
				//Verifica se possui licença HF
				//if U_HFXML00X("HF000001","101",SM0->M0_CGC,,.F.)	
				If U_HFXMLLIC(.F.)

					DbSelectArea( "SX6" )
					dbSetOrder(1)

					//Verifica se a empresa esta bloqueado via parametro job
					if SX6->( dbSeek( aSm0[nI][2] + "XM_EMPBLQ" ) )

						if !(AllTrim( aSm0[nI][1]+aSm0[nI][2] ) $ AllTrim( SX6->X6_CONTEUD ))

							aadd( aRet, aSm0[nI][1]+aSm0[nI][2] )
							aadd( aSm2, aSm0[nI][1] )

						endif

					elseif SX6->( dbSeek( Space( Len(aSm0[nI][2]) ) + "XM_EMPBLQ" ) )

						if !(AllTrim( aSm0[nI][1]+aSm0[nI][2] ) $ AllTrim( SX6->X6_CONTEUD ))

							aadd( aRet, aSm0[nI][1]+aSm0[nI][2] )
							aadd( aSm2, aSm0[nI][1] )

						endif

					else

						aadd( aRet, aSm0[nI][1]+aSm0[nI][2] )
						aadd( aSm2, aSm0[nI][1] )

					endif
					
					cFtp := " "
					cFhr := ""
					
					if SX6->( dbSeek( aSm0[nI][2] + "XM_ITATJOB" ) )
						
						if AllTrim( SX6->X6_CONTEUD ) = "1"
							cFtp := "A"
						Endif
						
					elseif SX6->( dbSeek( Space( Len(aSm0[nI][2]) ) + "XM_ITATJOB" ) )
						
						if AllTrim( SX6->X6_CONTEUD ) = "1"
							cFtp := "A"
						Endif
						
					endif
					
					if SX6->( dbSeek( aSm0[nI][2] + "XM_ITATHRC" ) )
						
						cFhr := AllTrim( SX6->X6_CONTEUD )
						
					elseif SX6->( dbSeek( Space( Len(aSm0[nI][2]) ) + "XM_ITATHRC" ) )
						
						cFhr := AllTrim( SX6->X6_CONTEUD )
						
					endif
					cCla := " "
					cChr := " "
					
					if SX6->( dbSeek( aSm0[nI][2] + "XM_CLATJOB" ) )
						
						if AllTrim( SX6->X6_CONTEUD ) = "1"
							cCla := "A"
						Endif
						
					elseif SX6->( dbSeek( Space( Len(aSm0[nI][2]) ) + "XM_CLATJOB" ) )
						
						if AllTrim( SX6->X6_CONTEUD ) = "1"
							cCla := "A"
						Endif
						
					endif
					
					if SX6->( dbSeek( aSm0[nI][2] + "XM_CLATHRC" ) )
						
						cChr := AllTrim( SX6->X6_CONTEUD )
					
					elseif SX6->( dbSeek( Space( Len(aSm0[nI][2]) ) + "XM_CLATHRC" ) )
						
						cChr := AllTrim( SX6->X6_CONTEUD )
					
					endif
					
					aadd( aAguas, { cFtp, cCla, cFhr, cChr, "", "" } )
					
					//FR - 05/08/2022 - PROJETO POLITEC - verificar se existe usuário/senha cadastrado,se estiver vazio, não deixa prosseguir no job A
					If SX6->( dbSeek( aSm0[nI][2] + "XM_ITATLOG" ) )
						cItAtLOG := AllTrim( SX6->X6_CONTEUD )
					Endif 

					If SX6->( dbSeek( aSm0[nI][2] + "XM_ITATPAS" ) )
						cItAtPAS := AllTrim( SX6->X6_CONTEUD )
					Endif
					//FR - 05/08/2022 - PROJETO POLITEC - verificar se existe usuário/senha cadastrado,se estiver vazio, não deixa prosseguir no job A
				else
				    //"@R 99.999.999/9999-99"
					Conout("Licenca nao encontrada para este CNPJ: " + Transform(SM0->M0_CGC, "@R 99.999.999/9999-99") + " - " + SM0->M0_FILIAL)   //Cnpj + Nome da Filial para melhor identificação
					
				endif
				
			endIf
		   
		Next nI

	EndIf
	
	cXmTpJobCx := GetNewPar("XM_TPJOBCX","1")
	_nSleep    := GetNewPar("XM_ITSLEEP",30000)  
	
	RstMvBuff()
	DelClassIntf()
	
	RpcClearEnv()  //RESET ENVIRONMENT
	
EndIf

Return( aRet )


Static Function TravaJov(xTip, cArqLck, nHdl) //TravaJov("TRAVA", cArqLck, @nHdl)

Local cArq := ""
//Local cDir := cBarra+AllTrim(GetNewPar("MV_X_PATHX",""))+cBarra
Local lRet := .T.
Local nConta := 0

//If Empty(cArqLck)
//	return( .T. )
//endIf
//cDir := StrTran(cDir,cBarra+cBarra,cBarra)
cArq := cArqLck   //cDir + xChaveXml + ".Trv"

If xTip == "TRAVA"

	nConta := 0
	
	Do While File( cArq )
	
		Sleep( 50 )
		nConta++
		
		if nConta > 10
		
			lRet := .F.
			Exit
			
		endif
		
	EndDo
	
	if lRet
	
		nConta := 0
		nHdl := -1
		
		Do While nHdl < 0
		
			if nConta > 0
				Sleep( 50 )
			endif
			
			nHdl := fCreate(cArq)
			nConta++
			
			if nConta > 10
				lRet := .F.
				Exit
			endif
			
		EndDo
		
		if nHdl >= 0
		
			MemoWrite(cArq,"TRAVA")
//			conout( "conseguiu "+cArq )

		endif
		
	endif
	
Else

	if File( cArq )
	
		if nHdl > 0
		   fClose(nHdl)
		endif
		
		nHdl := -1

		nConta := 0
		
		Do While nHdl < 0
		
			if nConta > 0
				Sleep( 50 )
			endif
			
			nHdl := FErase(cArq)
			nConta++
			
			if nConta > 10
			
				Exit
				
			endif
			
		EndDo
		

	EndIf
	
Endif

Return( lRet )


Static Function __Dummy(lRecursa) //warning W0010 Static Function <?> never called
    
    lRecursa := .F.
    
    IF (lRecursa)
    
        __Dummy(.F.)
        U_WF_XML01()
        U_XMLWF01A()
        
	EndIF
	
Return(lRecursa)
