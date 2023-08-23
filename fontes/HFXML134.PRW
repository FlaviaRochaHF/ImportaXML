#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "Protheus.ch"
#INCLUDE "AP5MAIL.CH" 
#INCLUDE "TBICONN.CH"

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ HFXML134     ¦ Autora ¦ FLÁVIA ROCHA  ¦ Data ¦ 05/10/2020  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Função para Schedule - Classificação automática de NF's    ¦¦¦
¦¦¦          ¦ de Energia - Kroma                                         ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ NF Entrada                                                 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Cliente   ¦ KROMA ENERGIA                                              ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦          		                                                      ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦  /  /    ¦      					                                  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
**********************************************************
User function HFXML134()
**********************************************************        
Local aParams 	:= {}
Local cEmp 		:= ""
Local cFil 		:= ""
Local cError	:= ""
Local cClAt     := ""
Local cLogProc  := "" 
//Local nI   		:= 0
Local nCount    := 0
Local lAuto     := NIL
Local lEnd      := NIL
Local oProcess

LoadParams(@aParams,@cError,.T.)

lAuto := IsBlind()

cEmp := Substr(aParams[2][2][1],1,2) //LoadSm0( aParams[2][2], @aAguas, @cXmTpJobCx, @_nSleep )
If aParams[2][2][1] == "99"
	cFil := "01"
Else
	cFil := Substr(aParams[2][2][1],3, Len(aParams[2][2][1])-2)
Endif

ConOut("Abrindo empresa "+cEmp+" e filial "+cFil+" para executar FWLoadSM0(). ")

RpcSetType(3)
PREPARE ENVIRONMENT EMPRESA cEmp FILIAL cFil

cClAt := GetNewPar("XM_CLAT"   ,"N")

Sleep( 10000 )	

If cClAt == "S" //Verifica se a classificação robótica está habilitada
	U_HFCLAJOB(lAuto,@lEnd,oProcess,@cLogProc,@nCount) 	//U_HFCLAJOB(lAuto,lEnd,oProcess,cLogProc,nCount)
Endif

//ALERT("PROCESSO FINALIZADO COM SUCESSO !!! ")		//FR RETIRAR

RstMvBuff()
DelClassIntf()
RpcClearEnv()		//esse é o reset environment

Return

****************************************************
Static Function LoadParams(aParams,cError,lDefault)
****************************************************
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
