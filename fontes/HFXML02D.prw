#include "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "Ap5Mail.ch"
#INCLUDE "FILEIO.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "PRTOPDEF.CH"
#INCLUDE "FWMVCDEF.CH"
//#INCLUDE "INKEY.CH"


Static lUnix  := IsSrvUnix()
Static cBarra := Iif(lUnix,"/","\")
//Static cIdEnt := iif(GetNewPar("XM_DFE","0") $ "0,1",U_GetIdEnt(),"")
//Static cURL   := PadR(GetNewPar("XM_URL",""),250)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHFXML02D  บ Autor ณ Roberto Souza      บ Data ณ  12/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina do botao baixar xml                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Importa XML                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function HFXML02D()

Local aArea    := GetArea()
Local aAreaZBZ := (xZBZ)->(GetArea())
Local aAreaZBT := (xZBT)->(GetArea())
Local aAreaZBE := (xZBE)->(GetArea())
Local lEnd     := .F.
Local oProcess := Nil
Local cLogProc := ""
Local cDir     := AllTrim(SuperGetMv("MV_X_PATHX"))
//Local cDirLog  := AllTrim(cDir+cBarra+"Log"+cBarra)
Local cDirLog  := AllTrim(cDir+"Log"+cBarra)
Local lAuto    := .F.
Local nCount   := 0
Local cCloud	:=	GetNewPar("XM_CLOUD" ,"0")         //aCombo (0=Desbilitado 1=Habilitado)
//Local lNoMail  := AllTrim(GetSrvProfString("HF_XFUNC","0")) == "1"

Default cIdEnt := "" //iif(GetNewPar("XM_DFE","0") $ "0,1",U_GetIdEnt(),"")		//FR - 05/05/2021 - #10382 - Kroma

if GetNewPar("XM_DFE","0") $ "0,1"

	if cCloud <> "1"
	
		cIdEnt := U_GetIdEnt()

		cURL   := PadR(GetNewPar("XM_URL",""),250)

		If Empty(cURL)

			cURL := PadR(GetNewPar("MV_SPEDURL","http://"),250)

		EndIf

	else

		cIdEnt := ""
		
	endif

else
	
	cUrl := ""
	
endif

(xZBZ)->( dbUnLock() )   

cLogProc := "### Importa็ใo de Xml iniciada ###"+CRLF
cLogProc += dToC(date()) +"-"+ Substr(Time(),1,2) + "-" + Substr(Time(),4,2)+CRLF

oProcess := MsNewProcess():New( {|lEnd| U_OkProc(lAuto,@lEnd,oProcess,@cLogProc,@nCount)} ,"Processando...","Processando Rotinas...",.T.)	//###
oProcess:Activate()

cDatahora  	:= 	dTos(date()) +"-"+ Substr(Time(),1,2) + "-" + Substr(Time(),4,2)

cLogProc    += "### Importa็ใo de Xml Finalizada ###"+CRLF

If !ExistDir(cDirLog)
	Makedir(cDirLog)
EndIf

if GetNewPar("XM_LOGARQ" ,"S") == "S"
	MemoWrite(cDirLog+"XML-"+cDataHora+".log",cLogProc)
endif

If !lAuto
	U_MyAviso("Importa็ใo XML",cLogProc,{"OK"},3)
EndIf

RestArea(aAreaZBE)
RestArea(aAreaZBT)
RestArea(aAreaZBZ)
RestArea(aArea)

Return


//Rotina do botใo baixar xml
*********************************************************
User Function OkProc(lAuto,lEnd,oProcess,cLogProc,nCount) 
*********************************************************

Local cRotImp  := GetNewPar("XM_ROTINAS","1,2,3,5,6,7,8,9")
Local lRotinaX := ("X" $ cRotImp)
Local lRotina1 := ("1" $ cRotImp)
Local lRotina2 := ("2" $ cRotImp)
Local lRotina3 := ("3" $ cRotImp)
Local lRotina4 := ("4" $ cRotImp)
Local lRotina5 := ("5" $ cRotImp)
Local lRotina6 := ("6" $ cRotImp)
Local lRotina7 := ("7" $ cRotImp)
Local lRotina8 := ("8" $ cRotImp)
Local lRotina9 := ("9" $ cRotImp)
Local cCloud	:=	GetNewPar("XM_CLOUD" ,"0")         //aCombo (0=Desbilitado 1=Habilitado)

if GetNewPar("XM_DFE","0") $ "0,1"

	if cCloud <> "1"
	
		cIdEnt := U_GetIdEnt()

		cURL   := PadR(GetNewPar("XM_URL",""),250)

		If Empty(cURL)

			cURL := PadR(GetNewPar("MV_SPEDURL","http://"),250)

		EndIf

	else

		cIdEnt := ""
		
	endif

else
	
	cUrl := ""
	
endif

If lRotina1 .Or. lRotinaX
	U_EMailNFE(lAuto,@lEnd,oProcess,@cLogProc,@nCount)
	Conout("EMailNFE")
EndIf

If lRotina2 .Or. lRotinaX
	U_ProcXml(lAuto,@lEnd,oProcess,@cLogProc,@nCount) 
	Conout("ProcXml")
EndIf

If lRotina3 .Or. lRotinaX
	U_AtuXmlStat(lAuto,@lEnd,oProcess,@cLogProc,@nCount)
	Conout("AtuXmlStat")	
EndIf	 
  
If lRotina4 .Or. lRotinaX

	If cCloud <> "1"

		U_UPConsXML(lAuto,@lEnd,oProcess,@cLogProc,@nCount,cUrl)
		Conout("UPConsXML")	

	ENDIF

EndIf		 

If lRotina5 .Or. lRotinaX
	U_ProcMail(lAuto,@lEnd,oProcess,@cLogProc,@nCount,.F.)
	Conout("ProcMail")	
EndIf
		 
If lRotina6 .Or. lRotinaX

	If cCloud == "1"

		U_HFXMLNVM(lAuto,@lEnd,oProcess,@cLogProc,@nCount)
		Conout("Gestใo na Nuvem")	

	else

		U_HFXML06R(lAuto,@lEnd,oProcess,@cLogProc,@nCount,.T.)
		U_HFXML062(lAuto,@lEnd,oProcess,@cLogProc,@nCount,.T.)
		U_HFXML61J(lAuto,@lEnd,oProcess,@cLogProc,@nCount,.T.)
		Conout("Manifesta็๕es Pendentes e Download 137")	

	endif

endif

If lRotina8 .Or. lRotinaX

	U_HFPDF002(lAuto,@lEnd,oProcess,@cLogProc,@nCount)
	Conout("PostFile")
	//U_HFPDF005(lAuto,@lEnd,oProcess,@cLogProc,@nCount)
	//Conout("Synchro")	
	U_HFPDF003(lAuto,@lEnd,oProcess,@cLogProc,@nCount)
	Conout("GetFile")	

EndIf

If lRotina9 .Or. lRotinaX

	U_HF068MUN(lAuto,lEnd,oProcess,cLogProc,nCount)
	U_HFXML068(lAuto,@lEnd,oProcess,@cLogProc,@nCount)
	Conout("Download NFSE")	

EndIf

/*If cCloud == "1"
	U_HFXMLNVM(lAuto,@lEnd,oProcess,@cLogProc,@nCount)
	Conout("Gestใo na Nuvem")	
EndIf*/

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEMailNFE  บ Autor ณ Roberto Souza      บ Data ณ  12/11/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ XML dos Fornecedores                                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Importa Xml                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function EMailNFE(lAuto,lEnd,oProcess,cLogProc,nCount)

//Static __MailFormatText := .f. // Mensagem em formato Texto
local oMessage
local nInd
//local lRunTbi	 := .F.
local nCount
local cFilename
local aAttInfo
local acFrom := ""
local acTo := ""
local acCc := ""
local acBcc := ""
local acSubject := ""
local acBody := ""
local acPath  := ""
local alDelete := .T. // Deleta ou nใo do servidor
local aaFiles := { }
Local aPOP        := U_XCfgMail(2,1,{})
Local aSMTP       := U_XCfgMail(1,1,{})
Local aPops		  := U_XCfgMail(3,1,{})
Local cMailServer := aPOP[1]
Local cLogin      := aPOP[2]
Local cMailConta  := aPOP[3]
Local cMailSenha  := aPOP[4]
Local lSMTPAuth   := aPOP[5]
Local lSSL        := aPOP[6]
Local cProtocolE  := aPOP[7]
Local cPortRec    := aPOP[8]
Local lTLS        := aPOP[9]
Local cMailSCont  := aPOPS[3]
Local cMailSSenh  := aPOPS[4]
Local cError      := ""
Local i           := 0
Local ttx         := 0
Local ttfmail     := 0

Private __MailServer
Private __MailError

Default oProcess := nil

//NFE
If !lAuto .Or. oProcess<>Nil      

	oProcess:IncRegua1("Verificando e-mail NF-e"+AllTrim(cMailConta)+"...")
	oProcess:IncRegua2("Aguarde...")      

EndIf

if cProtocolE == "2"

	U_MailImapConn ( cMailServer, cMailConta, cMailSenha ,,cPortRec, lSSL, lTLS, lSMTPAuth, aSMTP )

else

	U_MailPopConn ( cMailServer, cMailConta, cMailSenha ,,cPortRec, lSSL, lTLS, lSMTPAuth, aSMTP )

endif

If __MailError > 0 

	cRet := U_MailErro(__MailError)
	MsgAlert(cRet)
	return(.F.)

endif

//Modificado para versใo prothues 12 - 16/10/14
//inicio a variavel com valor 0
nMsgCount := 0
//Fun็ao PopMsgCountNFE e passo a variavel por referencia.
U_PopMsgCountNFE(@nMsgCount)

nCountMail := 0

If !lAuto .Or. oProcess<>Nil 
           
	oProcess:SetRegua1(nMsgCount)
	oProcess:SetRegua2(0)

	oProcess:IncRegua1(AllTrim(Str(nMsgCount))+" E-mails encontrados...")

EndIf

For ttfmail := 1 to nMsgCount

	oMessage := TMailMessage():New()
	oMessage:Clear()  

	__MailError := oMessage:Receive(__MailServer, ttfmail)
	
	//Tenta mais uma vez caso perca a conexใo
	If __MailError == 6 .Or. __MailError == 12

		if cProtocolE == "2"

			U_MailImapConn ( cMailServer, cMailConta, cMailSenha ,,cPortRec, lSSL, lTLS, lSMTPAuth, aSMTP)

		else

			U_MailPopConn ( cMailServer, cMailConta, cMailSenha ,,cPortRec, lSSL, lTLS, lSMTPAuth, aSMTP)

		endif
	
	EndIf

	If __MailError == 0
	
		acFrom := oMessage:cFrom
		acTo := oMessage:cTo
		acCc := oMessage:cCc
		acBcc := oMessage:cBcc
		acSubject := oMessage:cSubject
		acBody := oMessage:cBody
		nCountMail ++
		nCount := 0
		aaFiles := {}
		nTemXML := 0
		nAttach := oMessage:getAttachCount()

		For nInd := 1 to nAttach
		
			nTemXML := 0			
			aAttInfo := oMessage:getAttachInfo(nInd) 
			
			For ttx := 1 to Len(aAttInfo)

				//Alert(aAttInfo[ttx])
				if ValType(aAttInfo[ttx]) = "C"
					
					If Upper(Right(aAttInfo[ttx],3)) $ "XML;"+iif(GetNewPar("XM_USANFSE","N")=="S", Upper(AllTrim(GetNewPar("XM_ARQ_NFS"))), "")  //NFCE_03 16/05 Pr้-Nota.
						
						nTemXML := ttx
						ttx := Len(aAttInfo)

					EndIf

				EndIf

			Next ttx
	
			If nTemXML <> 0

				cFilename := acPath + cBarra + U_RancaBarras( aAttInfo[nTemXML] )
				
				If !lAuto .Or. oProcess<>Nil            
					oProcess:IncRegua1("Verificando e-mail NF-e...")
					oProcess:IncRegua2("Arquivo ..."+Right(cFilename,20))                        
    			EndIf

				While file(cFilename)

					nCount++
					cFilename := acPath + cBarra + substr(aAttInfo[nTemXML], 1, at(".", aAttInfo[nTemXML]) - 1) + strZero(nCount, 3) +;
					substr(aAttInfo[nTemXML], at(".", aAttInfo[nTemXML]))
				
				EndDo

					If .NOT. Upper(Right(cFilename,3)) $ "XML"  //NFCE_03 16/05 Pr้-Nota.
					
					Loop

				EndIf

//    			if at(".", cFilename) == 0  //Se nใo tiver a extensใo nใo ้ um xml correto.
//					Loop
//    			endif

					if Upper(Right(cFilename,4)) $ ".XML"

					nHandle := FCreate(cFilename)

					if nHandle == 0

						__MailError == 2000
						return .f.

					EndIf

					FWrite(nHandle, oMessage:getAttach(nInd))
					FClose(nHandle)
					xRet := .T.

				Else  //Porque tava dando pau nos PDFs e adjacentes.
					
					xRet := oMessage:SaveAttach( nInd, GetSrvProfString( "RootPath", "" )+cFilename )  //Gravaire o Bixo
					if xRet == .F.
						cLogProc += "Nใo Foi posํvel Gravar Em Disco "+cFilename
					Endif

				EndIF

				aAdd(aaFiles, { cFilename, aAttInfo[nTemXML]})
				
				if xRet

					U_MoveXml(lAuto,cFilename, @cError, @cLogProc,acPath+cBarra)
					FERASE(cFilename)

				Endif

			EndIf

		Next

		If alDelete .and. GetNewPar("XM_USANFSE","N") == "N"  //Altera็ใo Heverton - 11/01/2022

			__MailServer:DeleteMsg(ttfmail)

		Endif

	EndIf

	If !lAuto .Or. oProcess<>Nil  

		oProcess:IncRegua1("Restando "+AllTrim(Str(nMsgCount-ttfmail))+" E-mails...")
	
	EndIf

Next

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDesconecta o e-mail                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
if cProtocolE == "2"
	U_MailIma2Off()
else
	U_MailPopOff ( )
endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณLimpa os objetos em memoria                                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DelClassIntf()

//NFSe
cUsaNfse := GetNewPar("XM_USANFSE","N")

if cUsaNfse <> "N"

	If !lAuto .Or. oProcess<>Nil      

		oProcess:IncRegua1("Verificando e-mail NFS-e"+AllTrim(cMailSCont)+"...")
		oProcess:IncRegua2("Aguarde...")      

	EndIf

	if !Empty(cMailSCont)

		if cProtocolE == "2"

			U_MailImapConn ( cMailServer, cMailSCont, cMailSSenh ,,cPortRec, lSSL, lTLS, lSMTPAuth, aSMTP)

		else

			U_MailPopConn ( cMailServer, cMailSCont, cMailSSenh ,,cPortRec, lSSL, lTLS, lSMTPAuth, aSMTP)

		endif

		If __MailError > 0 

			cRet := U_MailErro(__MailError)
			MsgAlert(cRet)
			return(.F.)

		endif

		//Modificado para versใo prothues 12 - 16/10/14
		//inicio a variavel com valor 0
		nMsgCount := 0
		//Fun็ao PopMsgCountNFE e passo a variavel por referencia.
		U_PopMsgCountNFE(@nMsgCount)

		nCountMail := 0
		oMessage   := TMailMessage():New()
		oMessage:Clear()  

		If !lAuto .Or. oProcess<>Nil 
				
			oProcess:SetRegua1(nMsgCount)
			oProcess:SetRegua2(0)

			oProcess:IncRegua1(AllTrim(Str(nMsgCount))+" E-mails encontrados...")

		EndIf

		For ttfmail := 1 to nMsgCount         

			oMessage := TMailMessage():New()
			oMessage:Clear()  

			__MailError := oMessage:Receive(__MailServer, ttfmail)
			
			//Tenta mais uma vez caso perca a conexใo
			If __MailError == 6 .Or. __MailError == 12

				if cProtocolE == "2"

					U_MailImapConn ( cMailServer, cMailConta, cMailSenha ,,cPortRec, lSSL, lTLS, lSMTPAuth, aSMTP)

				else

					U_MailPopConn ( cMailServer, cMailConta, cMailSenha ,,cPortRec, lSSL, lTLS, lSMTPAuth, aSMTP)

				endif
			
			EndIf

			If __MailError == 0
			
				acFrom := oMessage:cFrom
				acTo := oMessage:cTo
				acCc := oMessage:cCc
				acBcc := oMessage:cBcc
				acSubject := oMessage:cSubject
				acBody := oMessage:cBody
				nCountMail ++
				nCount := 0
				aaFiles := {}
				nTemXML := 0
				nAttach := oMessage:getAttachCount()

				For nInd := 1 to nAttach
				
					nTemXML := 0			
					aAttInfo := oMessage:getAttachInfo(nInd) 
					
					For ttx := 1 to Len(aAttInfo)

						//Alert(aAttInfo[ttx])
						if ValType(aAttInfo[ttx]) = "C"
							
							If Upper(Right(aAttInfo[ttx],3)) $ iif(GetNewPar("XM_USANFSE","N")=="S", Upper(AllTrim(GetNewPar("XM_ARQ_NFS"))), "")  //NFCE_03 16/05 Pr้-Nota.
								
								nTemXML := ttx
								ttx := Len(aAttInfo)

							EndIf

						EndIf

					Next
			
					If nTemXML <> 0

						cFilename := acPath + cBarra + U_RancaBarras( aAttInfo[nTemXML] )
						
						If !lAuto .Or. oProcess<>Nil            
							oProcess:IncRegua1("Verificando e-mail NFS-e...")
							oProcess:IncRegua2("Arquivo ..."+Right(cFilename,20))                        
						EndIf

						While file(cFilename)

							nCount++
							cFilename := acPath + cBarra + substr(aAttInfo[nTemXML], 1, at(".", aAttInfo[nTemXML]) - 1) + strZero(nCount, 3) +;
							substr(aAttInfo[nTemXML], at(".", aAttInfo[nTemXML]))
						
						EndDo

						If .NOT. Upper(Right(cFilename,3)) $ +iif(GetNewPar("XM_USANFSE","N")=="S", Upper(AllTrim(GetNewPar("XM_ARQ_NFS"))), "")  //NFCE_03 16/05 Pr้-Nota.
							
							Loop

						EndIf

		//    			if at(".", cFilename) == 0  //Se nใo tiver a extensใo nใo ้ um xml correto.
		//					Loop
		//    			endif

						if Upper(Right(cFilename,4)) $ ".PDF"

							nHandle := FCreate(cFilename)

							if nHandle == 0

								__MailError == 2000
								return .f.

							EndIf

							FWrite(nHandle, oMessage:getAttach(nInd))
							FClose(nHandle)
							xRet := .T.

						Else  //Porque tava dando pau nos PDFs e adjacentes.
							
							xRet := oMessage:SaveAttach( nInd, GetSrvProfString( "RootPath", "" )+cFilename )  //Gravaire o Bixo
							if xRet == .F.
								cLogProc += "Nใo Foi posํvel Gravar Em Disco "+cFilename
							Endif

						EndIF

						aAdd(aaFiles, { cFilename, aAttInfo[nTemXML]})
						
						if xRet

							U_MoveXml(lAuto,cFilename, @cError, @cLogProc,acPath+cBarra)
							FERASE(cFilename)

						Endif

					EndIf

				Next

				If alDelete

					__MailServer:DeleteMsg(ttfmail)

				Endif

			EndIf

			If !lAuto .Or. oProcess<>Nil  

				oProcess:IncRegua1("Restando "+AllTrim(Str(nMsgCount-ttfmail))+" E-mails...")
			
			EndIf

		Next 
	
	Endif

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDesconecta o e-mail                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	if cProtocolE == "2"
		U_MailIma2Off()
	else
		U_MailPopOff( )
	endif
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณLimpa os objetos em memoria                                     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	DelClassIntf()

endif

return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMailPopConn บ Autor ณ Roberto Souza    บ Data ณ  12/11/11   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ XML dos Fornecedores                                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Importa Xml                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function MailPopConn ( cServer, cUser, cPassword, nTimeOut , cPortRec, lSSL, lTLS, lSMTPAuth, aSMTP )

	Local nResult := 0
	Default nTimeOut := 30                    		
	Default lTLS := .F.
	
	__MailError	 := 0
	
	If ValType(__MailServer) == "U"
		__MailServer := TMailManager():New()
	Endif
	
	if lSSL
		__MailServer:SetUseSSL( lSSL )
	endif
	
	if lTLS
		__MailServer:SetUseTLS( lTLS )
	Endif
	
	//TMailManager(): Init ( < cMailServer>, < cSmtpServer>, < cAccount>, < cPassword>, [ nMailPort], [ nSmtpPort] ) 
	__MailServer:Init(AllTrim(cServer), '', AllTrim(cUSer), AllTrim(cPassword) ,Val(cPortRec))
	__MailError	:= __MailServer:SetPopTimeOut( nTimeOut )
	__MailError := __MailServer:PopConnect()

Return( __MailError == 0 )


*****************************************************************************************
User Function MailImapConn ( cServer, cUser, cPassword, nTimeOut , cPortRec, lSSL, lTLS, lSMTPAuth, aSMTP )
*****************************************************************************************
	Local nResult := 0
	Default nTimeOut := 15
	Default lTLS := .F.
	
	__MailError	 := 0
	
	If ValType(__MailServer) == "U"
		__MailServer := TMailManager():New()
	Endif
	
	//TMailManager(): Init ( < cMailServer>, < cSmtpServer>, < cAccount>, < cPassword>, [ nMailPort], [ nSmtpPort] ) 
	if lSSL
		__MailServer:SetUseSSL( lSSL )
	endif
	
	if lTLS
		__MailServer:SetUseTLS( lTLS )
	Endif
	
	__MailServer:Init(AllTrim(cServer),'', AllTrim(cUSer), AllTrim(cPassword) ,Val(cPortRec))
	__MailError	:= __MailServer:SetPopTimeOut( nTimeOut )
	__MailError := __MailServer:ImapConnect()

Return( __MailError == 0 )

                        
                                                            
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPopConn     บ Autor ณ Roberto Souza    บ Data ณ  12/09/11   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ XML dos Fornecedores                                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Importa Xml                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function PopConn ( cServer, cUser, cPassword, nTimeOut, nPort )

//Local nRet   := 0
//Local lRet   := .F.  
Local nMailError := 0
Default nTimeOut := 30                    		

nMailError	 := 0

If ValType(__MailServer) == "U"
	__MailServer := TMailMng():New( 0 )  
Endif

//TMailManager(): Init ( < cMailServer>, < cSmtpServer>, < cAccount>, < cPassword>, [ nMailPort], [ nSmtpPort] ) 
__MailServer:Init(AllTrim(cServer), '', AllTrim(cUSer), AllTrim(cPassword) )
__MailError	:= __MailServer:SetPopTimeOut( nTimeOut )
__MailError := __MailServer:PopConnect()

U_MYAviso("Importa XML", "Visualiza detalhes",{"Sim","Nใo"})

Return( __MailError == 0 )
  

********************************
User Function MailPopOffNFE ( )
********************************
	__MailError := __MailServer:PopDisconnect()

Return( __MailError == 0 ) 


***************************
User Function MailIma2Off()
***************************

	__MailError := __MailServer:ImapDisconnect()

Return( __MailError == 0 )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัอออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPopMsgCountNFE บ Autor ณ Roberto Souza บ Data ณ  12/09/11   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯอออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ XML dos Fornecedores                                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Importa Xml                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User function PopMsgCountNFE(nMsgCount)

nMsgCount := 0
__MailError := __MailServer:GetNumMsgs(@nMsgCount)

Return( __MailError == 0,nMsgCount)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAutoXml1  บ Autor ณ Roberto Souza      บ Data ณ  01/01/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Direciona os jobs automaticos                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Importa Xml                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function AutoXml1(nTipo,lAuto,lEnd,oProcess,cLogProc,nCount,cUrl)

Local cCloud	:=	GetNewPar("XM_CLOUD" ,"0")         //aCombo (0=Desbilitado 1=Habilitado)

Default nTipo  := 0

Private xZBZ  	  := GetNewPar("XM_TABXML","ZBZ")     
Private xZB5  	  := GetNewPar("XM_TABAMAR","ZB5")
Private xZBS  	  := GetNewPar("XM_TABSINC","ZBS")
Private xZBE      := GetNewPar("XM_TABEVEN","ZBE")
Private xZBA  	  := GetNewPar("XM_TABAMA2","ZBA")
Private xZBC      := GetNewPar("XM_TABCAC","ZBC")
Private xZBI      := GetNewPar("XM_TABIEXT","ZBI")
Private xZBO      := GetNewPar("XM_TABOCOR","ZBO")
Private xZBT      := GetNewPar("XM_TABITEM","ZBT")   //FR 11/11/19
Private xRetSEF   := ""
Private xZBZ_ 	  := iif(Substr(xZBZ,1,1)=="S", Substr(xZBZ,2,2), Substr(xZBZ,1,3)) + "_"
Private xZB5_ 	  := iif(Substr(xZB5,1,1)=="S", Substr(xZB5,2,2), Substr(xZB5,1,3)) + "_"
Private xZBS_ 	  := iif(Substr(xZBS,1,1)=="S", Substr(xZBS,2,2), Substr(xZBS,1,3)) + "_"
Private xZBE_     := iif(Substr(xZBE,1,1)=="S", Substr(xZBE,2,2), Substr(xZBE,1,3)) + "_"
Private xZBA_ 	  := iif(Substr(xZBA,1,1)=="S", Substr(xZBA,2,2), Substr(xZBA,1,3)) + "_"
Private xZBC_     := iif(Substr(xZBC,1,1)=="S", Substr(xZBC,2,2), Substr(xZBC,1,3)) + "_"
Private xZBI_     := iif(Substr(xZBI,1,1)=="S", Substr(xZBI,2,2), Substr(xZBI,1,3)) + "_"
Private xZBO_     := iif(Substr(xZBO,1,1)=="S", Substr(xZBO,2,2), Substr(xZBO,1,3)) + "_"
Private xZBT_     := iif(Substr(xZBT,1,1)=="S", Substr(xZBT,2,2), Substr(xZBT,1,3)) + "_"   //FR - 11/11/19
Private x_Ped_Rec := GetNewPar("XM_PEDREC","N")
Private x_ZBB     := GetNewPar("XM_TABREC","")
Private aHfCloud  := {"0","0"," ","Token",{}}  //CRAUMDE - '0' Nใo integrar, na posi็ใo 1
Private x_Tip_Pre := GetNewPar("XM_TIP_PRE","1")
Private nFormNfe  := Val(GetNewPar("XM_FORMNFE","6")) 
Private nFormCte  := Val(GetNewPar("XM_FORMCTE","6"))
Private cFilUsu   := GetNewPar("XM_FIL_USU","N")
Private cTpRt  	  := "J"  

//No caso de existir cnpj duplicado no sigamat, iremos verificar se existe a tabela antes de prosseguir
//Caso nao seja encontrada a tabela a fun็ใo irแ retornar
IF !ChkFile(xZBZ) 

	Conout("Tabela nao encontrada "+ xZBZ +" - Empresa: "+cEmpAnt+cFilAnt)
	Conout("Finalizado")
	Return()

endif

if GetNewPar("XM_DFE","0") $ "0,1"

	if cCloud <> "1"

		cIdEnt := U_GetIdEnt()

	else

		cIdEnt := ""
		
	endif

else

	cIdEnt := ""
	
endif

//IF ExistBlock( "HFCLDINI" )
//	aHfCloud := U_HFCLDINI(.F.,@cLogProc)
//EndIF

If nTipo == 1  

	Conout("Executando leitura de xmls por email - EMAILNFE")
	U_EMailNFE(lAuto,@lEnd,oProcess,@cLogProc,@nCount)

ElseIf nTipo == 2

	Conout("Validando xmls do e-mail - PROCXML")
	U_ProcXml(lAuto,@lEnd,oProcess,@cLogProc,@nCount)

ElseIf nTipo == 3

	Conout("Sincronizando status dos xmls - ATUXMLSTAT")
	U_AtuXmlStat(lAuto,@lEnd,oProcess,@cLogProc,@nCount)

ElseIf nTipo == 4

	If cCloud <> "1"

		Conout("Verificando xmls cancelados - UPCONSXML")
		U_UPConsXML(lAuto,@lEnd,oProcess,@cLogProc,@nCount,cUrl)

	endif

ElseIf nTipo == 5

	Conout("Enviando e-mails de notificacao - PROCMAIL")
	U_ProcMail(lAuto,@lEnd,oProcess,@cLogProc,@nCount,.F.)	

ElseIf nTipo == 6

	If cCloud == "1"

		U_HFXMLNVM(lAuto,@lEnd,oProcess,@cLogProc,@nCount)
		Conout("Gestใo na Nuvem")	

	else
	
		if GetNewPar( "XM_DFE", "0" ) == "2"
			Conout("Executando download dos xmls - HFXML16JB")
			U_HFXML16JB(lAuto,@lEnd,oProcess,@cLogProc,@nCount,.F.)
		else
			Conout("Executando download dos xmls - HFXML6JB")
			U_HFXML6JB(lAuto,@lEnd,oProcess,@cLogProc,@nCount,.F.)	
		endif 

		Conout("Executando xmls resumidos - HFXML06R")
		U_HFXML06R(lAuto,@lEnd,oProcess,@cLogProc,@nCount,.F.)  //Download dos xmlดs resumidos
		Conout("Executando as manifestacoes - HFXML062")
		U_HFXML062(lAuto,@lEnd,oProcess,@cLogProc,@nCount,.F.)  //Manifestar os pendentes de manifesta็ใo
		Conout("Analisando xmls com divergencias - HFXML61J")
		U_HFXML61J(lAuto,@lEnd,oProcess,@cLogProc,@nCount,.F.)  //Ver se Tem Com erros primeiro

	endif

ElseIf nTipo == 7

	Conout(" Enviando e-mails para os usuarios - HFCKXML1 ")
	U_HFCKXML1(lAuto,@lEnd,oProcess,@cLogProc,@nCount,.F.)	

ElseIf nTipo == 8

	Conout(" Executando conversao do PDF em XML - HFPDF002 ")
	//U_HFPDF002(lAuto,@lEnd,oProcess,@cLogProc,@nCount)
	//U_HFPDF003(lAuto,@lEnd,oProcess,@cLogProc,@nCount)
	U_HFPDF002(lAuto,@lEnd,oProcess,@cLogProc,@nCount)
	Conout("PostFile")
	U_HFPDF005(lAuto,@lEnd,oProcess,@cLogProc,@nCount)
	Conout("Synchro")	
	U_HFPDF003(lAuto,@lEnd,oProcess,@cLogProc,@nCount)
	Conout("GetFile")	

ElseIf nTipo == 9

	Conout(" Executando a baixa dos xmls NFSE -  HFXML068 ")
	U_HF068MUN(lAuto,@lEnd,oProcess,@cLogProc,@nCount)
	U_HFXML068(lAuto,@lEnd,oProcess,@cLogProc,@nCount)

EndIf

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณProcXml   บ Autor ณ Roberto Souza      บ Data ณ  07/10/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Processa os XMLs na estrutura padrใo para leitura.         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Importa Xml                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function ProcXml(lAuto,lEnd,oProcess,cLogProc,nCount)

Local lRet     := .F.                     
//Local ny       := 0
Local aFiles   := {}
Local aFilTr   := {}
Local cDir     := "\"+AllTrim(GetNewPar("MV_X_PATHX",""))+"\"
//Local lDirCnpj := AllTrim(GetNewPar("XM_DIRCNPJ","N")) == "S"                     
//Local lDirFil  := AllTrim(GetNewPar("XM_DIRFIL" ,"N")) == "S" 
//Local lDirMod  := AllTrim(GetNewPar("XM_DIRMOD" ,"N")) == "S"                     
Local cDirDest := AllTrim(cDir+"Importados\")                     
Local cDirRej  := AllTrim(cDir+"Rejeitados\")                     
Local cDirCfg  := AllTrim(cDir+"Cfg\")
Local cDrive   := "" 
Local cPath    := ""  
Local cNewFile := ""
Local cExt     := ""                        
//Local lCopy    := .F.
Local nErase   := 0 
//Local cFilXml  := ""
//Local cSeqCce  := ""
//Local cKeyXml  := ""
Local lOnline  := .F.
Local cInfo    := ""
Local cErroR   := ""
//Local cErroProc:= ""
Local cMsg     := ""
//Local cOcorr   := ""
//Local cPref    := ""  
//Local aPref    := {"CTE","NFE","NFCE"}
//Local lNewVer  := AllTrim(GetSrvProfString("HF_DEBUGKEY","0"))=="1"
//Local nTag     := 0
Local ni       := 0
//Private oXml     := Nil
//Private lOver    := .F.
//Private lCanc    := .F., lCCe := .F.
//Private cMsgTag  := ""
DbSelectArea("SM0")
nRecFil := Recno()

Private xcXml2   := ""
Private aFilsLic := {}
Private lXmlsLic := .F.
Private aFilsEmp := U_XGetFilS(SM0->M0_CGC,@aFilsLic)

DbSelectArea("SM0")
DbGoTo(nRecFil)

Default oProcess:= Nil

//inicio aqui para linux
cDir     := Iif(lUnix,StrTran(cDir,"\","/"),cDir)
cDirDest := Iif(lUnix,StrTran(cDirDest,"\","/"),cDirDest)
cDirRej  := Iif(lUnix,StrTran(cDirRej,"\","/"),cDirRej)
cDirCfg  := Iif(lUnix,StrTran(cDirCfg,"\","/"),cDirCfg)
//fim aqui para linux

cDir           := StrTran(cDir,cBarra+cBarra,cBarra)
cDirDest       := StrTran(cDirDest,cBarra+cBarra,cBarra)
cDirRej        := StrTran(cDirRej,cBarra+cBarra,cBarra)
cDirCfg        := StrTran(cDirCfg,cBarra+cBarra,cBarra)

cDir           := StrTran(cDir,cBarra+cBarra,cBarra)
cDirDest       := StrTran(cDirDest,cBarra+cBarra,cBarra)
cDirRej        := StrTran(cDirRej,cBarra+cBarra,cBarra)
cDirCfg        := StrTran(cDirCfg,cBarra+cBarra,cBarra)
_cDirDest      := cDirDest
_cDirRej       := cDirRej
     
If !ExistDir(cDirDest)
	Makedir(cDirDest)
EndIf
If !ExistDir(cDirRej)
	Makedir(cDirRej)
EndIf

lOnline := U_HFSTATSEF(lAuto,@cIdEnt,@cInfo,.F.)

If Empty( aFilsEmp )

    cAssunto := "Aviso de Falta de Licen็a - Importa็ใo XML"
    cPara	 := AllTrim(SuperGetMv("XM_MAIL02")) // Conta de Email para erros
    aTo := Separa(cPara,";")
	
	cDirMail  := AllTrim(SuperGetMv("MV_X_PATHX")) + cBarra+"template"+cBarra+"xml_erro.html"
	
	If File(cDirMail)
		cTemplate := MemoRead(cDirMail)		  
	Else   
		cTemplate := ''
	EndIf 
	
	cInfo := "<center><b>Nใo foi possํvel encontrar licen็a valida.</b></center>"+CRLF+cInfo
	    
	cMsgCfg := ""
	cMsgCfg += '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
	cMsgCfg += '<html xmlns="http://www.w3.org/1999/xhtml">'
	cMsgCfg += '<head>'
	cMsgCfg += '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />'
	cMsgCfg += '<title>Importa XML</title>'
	cMsgCfg += '  <style type="text/css"> '
	cMsgCfg += '	<!-- '
	cMsgCfg += '	body {background-color: rgb(37, 64, 97);} '
	cMsgCfg += '	.style1 {font-family: Hyperfont,Verdana, Arial;font-size: 12pt;} '
	cMsgCfg += '	.style2 {font-family: Segoe UI,Verdana, Arial;font-size: 12pt;color: rgb(255,0,0)} '
	cMsgCfg += '	.style3 {font-family: Segoe UI,Verdana, Arial;font-size: 10pt;color: rgb(37,64,97)}' 
	cMsgCfg += '	.style4 {font-size: 8pt; color: rgb(37,64,97); font-family: Segoe UI,Verdana, Arial;} '
	cMsgCfg += '	.style5 {font-size: 10pt} '
	cMsgCfg += '	--> '
	cMsgCfg += '  </style>'
	cMsgCfg += '</head>'
	cMsgCfg += '<body>'
	cMsgCfg += '<table style="background-color: rgb(240, 240, 240); width: 800px; text-align: left; margin-left: auto; margin-right: auto;" id="total" border="0" cellpadding="12">'
	cMsgCfg += '  <tbody>'
	cMsgCfg += '    <tr>'
	cMsgCfg += '      <td colspan="2">'
	cMsgCfg += '    <Center>'
	cMsgCfg += '      <H2>LICENวA NรO ENCONTRADA OU VENCIDA PARA TODAS AS FILIAIS</H2>'
	cMsgCfg += '      </Center>'
	cMsgCfg += '      <hr>'			
	cMsgCfg += '      <p class="style1">'+cInfo + CRLF +'</p>'
	cMsgCfg += '      <hr>'			
	cMsgCfg += '      </td>'
	cMsgCfg += '    </tr>'
	cMsgCfg += '  </tbody>'
	cMsgCfg += '</table>'
	cMsgCfg += '<p class="style1">&nbsp;</p>'
	cMsgCfg += '</body>'
	cMsgCfg += '</html>'

	cBodyMail := ""
	cObs := cInfo + CRLF

	cMsg :=cMsgCfg
//	nRet:= 	U_HX_MAIL(aTo,cAssunto,cMsg,@cError,"","",cPara)	
	nRet:= 	U_MAILSEND(aTo,cAssunto,cMsg,@cError,"","",cPara,"","")
	lRet:=.F.

ElseIf !lOnline

    cAssunto := "Aviso de Falha - Importa็ใo XML - Conexใo - Entidade : "+cIdEnt
    cPara	 := AllTrim(SuperGetMv("XM_MAIL02")) // Conta de Email para erros
    aTo := Separa(cPara,";")
	
	cDirMail  := AllTrim(SuperGetMv("MV_X_PATHX")) + cBarra+"template"+cBarra+"xml_erro.html"
	
	If File(cDirMail)
		cTemplate := MemoRead(cDirMail)		  
	Else   
		cTemplate := ''
	EndIf 
	
	If "WSCERR044" $ cInfo
		cInfo := "<center><b>Nใo foi possํvel se conectar com o servidor de WebServices.</b></center>"+CRLF+cInfo
	EndIf
	    
	cMsgCfg := ""
	cMsgCfg += '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
	cMsgCfg += '<html xmlns="http://www.w3.org/1999/xhtml">'
	cMsgCfg += '<head>'
	cMsgCfg += '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />'
	cMsgCfg += '<title>Importa XML</title>'
	cMsgCfg += '  <style type="text/css"> '
	cMsgCfg += '	<!--' 
	cMsgCfg += '	body {background-color: rgb(37, 64, 97);} '
	cMsgCfg += '	.style1 {font-family: Hyperfont,Verdana, Arial;font-size: 12pt;} '
	cMsgCfg += '	.style2 {font-family: Segoe UI,Verdana, Arial;font-size: 12pt;color: rgb(255,0,0)}' 
	cMsgCfg += '	.style3 {font-family: Segoe UI,Verdana, Arial;font-size: 10pt;color: rgb(37,64,97)}' 
	cMsgCfg += '	.style4 {font-size: 8pt; color: rgb(37,64,97); font-family: Segoe UI,Verdana, Arial;} '
	cMsgCfg += '	.style5 {font-size: 10pt}' 
	cMsgCfg += '	-->' 
	cMsgCfg += '  </style>'
	cMsgCfg += '</head>'
	cMsgCfg += '<body>'
	cMsgCfg += '<table style="background-color: rgb(240, 240, 240); width: 800px; text-align: left; margin-left: auto; margin-right: auto;" id="total" border="0" cellpadding="12">'
	cMsgCfg += '  <tbody>'
	cMsgCfg += '    <tr>'
	cMsgCfg += '      <td colspan="2">'
	cMsgCfg += '    <Center>'
	cMsgCfg += '      <H2>FALHA DE CONEXรO - WEBSERVICES</H2>'
	cMsgCfg += '      </Center>'
	cMsgCfg += '      <hr>'			
	cMsgCfg += '      <p class="style1">'+cInfo + CRLF + cError+'</p>'
	cMsgCfg += '      <hr>'			
	cMsgCfg += '      </td>'
	cMsgCfg += '    </tr>'
	cMsgCfg += '  </tbody>'
	cMsgCfg += '</table>'
	cMsgCfg += '<p class="style1">&nbsp;</p>'
	cMsgCfg += '</body>'
	cMsgCfg += '</html>'

	cBodyMail := ""
	cObs := cInfo + CRLF + cError

	cMsg :=cMsgCfg
//	nRet:= 	U_HX_MAIL(aTo,cAssunto,cMsg,@cError,"","",cPara)	
	nRet:= 	U_MAILSEND(aTo,cAssunto,cMsg,@cError,"","",cPara,"","")
	lRet:=lOnline
	
Else

	IF GetNewPar("XM_LPATRV", "N" ) == "S"
	
		If !lAuto .Or. oProcess <> NIL
			oProcess:IncRegua1("Limpando Semaforo...")
			oProcess:IncRegua2("Entidade : "+cIdEnt+" - Status Sefaz Ok...")
		EndIF

		aFilTr	:=	Directory(cDir+"*.TRV","D")

		For nI := 1 To Len(aFilTr)
		
			SplitPath(cDir+AllTrim(aFilTr[nI,1]),@cDrive,@cPath, @cNewFile,@cExt)
			nErase := FErase(cDir+cNewFile+cExt)

	  		If nErase < 0
				//cLogProc += "(EM USO) Em processo arquivo ["+cDir+cNewFile+cExt+"]"+CRLF
			Else
				cLogProc += "Semaforo removido. Arquivo ["+cDir+cNewFile+cExt+"]"+CRLF
			EndIf

		Next nI
		
	EndIF

	If !lAuto .Or. oProcess <> Nil    
	        
		oProcess:IncRegua1("Processando Xml...")
		oProcess:IncRegua2("Entidade : "+cIdEnt+" - Status Sefaz Ok...")                        

		aFiles	:=	Directory(cDir+"*.XML","D")

		oProcess:SetRegua1(0)
		oProcess:SetRegua2(Len(aFiles))    
		                    
	Else
	
		aFiles	:=	Directory(cDir+"*.XML","D")	
		
	EndIf
	
	aSort( aFiles,,,{|x,y| x[1]<y[1] } )

	For nI := 1 To Len(aFiles)

		U_HFSLVXML(aFiles[nI,1], lAuto,@lEnd,oProcess,@cLogProc,@nCount, "1" ) //FR - 13/11/19 - Chamada da rotina que grava o XML

	Next

	//IF AllTrim(GetNewPar("XM_USANFSE","N")) == "S"
	 
		//U_HFPOSTFILE( lAuto, @lEnd, oProcess, @cLogProc, @nCount )

		//U_HFGETFILE( lAuto, @lEnd, oProcess, @cLogProc, @nCount )

		//U_HFTXTCSV(lAuto,@lEnd,oProcess,@cLogProc,@nCount)  //NFCE_02 07/03. Para Evitar a Fadiga. Importar TXT/CSV de NF de Servi็os. A priori NF de SP.
	
	//ENDIF

EndIf

Return(lRet)

*************************************************************
User Function AtuXmlStat(lAuto,lEnd,oProcess,cLogProc,nCount)
*************************************************************

	U_COMP0012(lAuto,@lEnd,oProcess,@cLogProc,@nCount)
	U_UPForXML(lAuto,@lEnd,oProcess,@cLogProc,@nCount,.F.)
	
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณProcMail  บ Autor ณ Roberto Souza        บ Data ณ  16/01/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescri??o ณ Rotina que atualiza os status de e-mail na tabela ZBZ        บฑฑ
ฑฑฬฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤนฑฑ
ฑฑบSintaxe   ณ HfSetMail(aTo,cSubject,cMsg,cError,cAnexo,cAnexo2,cEmailDest)บฑฑ
ฑฑฬอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ                               Status                                    บฑฑ
ฑฑฬออออออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบE-Mail    ณ 0-Xml Ok (Nใo envia)                                         บฑฑ
ฑฑบ          ณ 1-Xml com erro (Pendente)                                    บฑฑ
ฑฑบ          ณ 2-Xml com erro (Enviado)                                     บฑฑ
ฑฑบ          ณ 3-Xml cancelado (Pendente)                                   บฑฑ
ฑฑบ          ณ 4-Xml cancelado (Enviado)                                    บฑฑ
ฑฑบ          ณ X-Falha ao enviar o e-mail (Erro)                            บฑฑ
ฑฑบ          ณ Y-Falha ao enviar o e-mail (Cancelamento)                    บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Importa XML                                                  บฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function ProcMail(lAuto,lEnd,oProcess,cLogProc,nCount,lMostra)

Local aArea     := GetArea()
//Local cQry      := ""
Local cTabela   := ""
Local cWhere    := ""
Local cOrder    := ""
Local cAliasZBZ := GetNextAlias()
Local nErr      := 0
Local nCan      := 0
Default cLogProc:= ""
Default lAuto   := .F.     
Default oProcess:= Nil
Default lEnd    := .F. 
Default nCount  := 0 
Default lMostra := .T.

ProcRegua(0)    
cLogProc +="### Notifica็๕es por E-mail. ###"+CRLF

cTabela:= "%"+RetSqlName(xZBZ)+"%"

cCampos := "%"+xZBZ_+"FILIAL, "+xZBZ_+"NOTA, "+xZBZ_+"SERIE, "+xZBZ_+"DTNFE, "+xZBZ_+"PRENF, "+;
               xZBZ_+"CNPJ, "+xZBZ_+"FORNEC, "+xZBZ_+"CNPJD, "+xZBZ_+"CLIENT,"+xZBZ_+"CHAVE, "+;
               xZBZ_+"CODFOR, "+xZBZ_+"LOJFOR,"+xZBZ_+"TPDOC,"+xZBZ_+"MAIL, ZBZ.R_E_C_N_O_%"    //"+xZBZ_+"DTMAIL, tinha cliente dando erro por causa do Memo

cWhere := "%( ZBZ."+xZBZ_+"MAIL IN ('1','3') )%"
//	cWhere := "%( ZBZ."+xZBZ_+"MAIL IN ('1','3','X','Y') )%"  //Acredito que em alguns e-mail esteja devolvendo outras coisas.
cOrder := "%"+xZBZ_+"FILIAL,"+xZBZ_+"DTNFE%"

BeginSql Alias cAliasZBZ

SELECT	%Exp:cCampos%
		FROM %Exp:cTabela% ZBZ
		WHERE ZBZ.%notdel%
		AND %Exp:cWhere%
		ORDER BY %Exp:cOrder%
EndSql           

DbSelectArea(cAliasZBZ)

While !(cAliasZBZ)->(Eof())    

	DbSelectArea(xZBZ)
	DbGoTo((cAliasZBZ)->R_E_C_N_O_)

	nRet := U_HFNotificaMail((xZBZ)->(FieldGet(FieldPos(xZBZ_+"MAIL"))),;
						 (xZBZ)->(FieldGet(FieldPos(xZBZ_+"DTMAIL"))),;
						 (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO"))),;
						 (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))) )
						 
    cNewStat := ""
	DbGoTo((cAliasZBZ)->R_E_C_N_O_)
	
	If nRet >= 0
	
		If (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MAIL"))) $ "1|X" // Erros
			cNewStat := "2"
   			nErr++
		ElseIf (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MAIL"))) $ "3|Y" // Cancelamentos
			cNewStat := "4"
			nCan++
		EndIf
		
		RecLock(xZBZ,.F.)
		(xZBZ)->(FieldPut(FieldPos(xZBZ_+"MAIL"), cNewStat )) //Iif(ZBZ->ZBZ_MAIL=="1","2","4")
		MsUnlock()
		
	Else
	
		RecLock(xZBZ,.F.)
		(xZBZ)->(FieldPut(FieldPos(xZBZ_+"MAIL"), Iif((xZBZ)->(FieldGet(FieldPos(xZBZ_+"MAIL"))) $ "1|X", "X", "Y") ))
		MsUnlock()	
			
	EndIf
	
	IncProc("Processando "+(cAliasZBZ)->&(xZBZ_+"CNPJ"))
	
	(cAliasZBZ)->(DbSkip())    	
	
EndDo

cLogProc += StrZero(nErr,6)+" Xml(s) com erro  notificado(s)."+CRLF		
cLogProc += StrZero(nCan,6)+" Xml(s) cancelado(s) notificado(s)."+CRLF					              

DbSelectArea(cAliasZBZ)			             
DbCloseArea()
RestArea(aArea)

If lMostra
	Aviso("Aviso", cLogProc,{"OK"},3)
EndIf

Return


/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun??o    ณ HfSetMailณ Autor ณ Roberto Souza           ณ Data ณ16/01/2013ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri??o ณ Rotina que atualiza os status de e-mail na tabela ZBZ        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ HfSetMail(aTo,cSubject,cMsg,cError,cAnexo,cAnexo2,cEmailDest)ณฑฑ
ฑฑฬอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ                               Status                                    บฑฑ
ฑฑฬออออออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบE-Mail    ณ 0-Xml Ok (Nใo envia)                                         บฑฑ
ฑฑบ          ณ 1-Xml com erro (Pendente)                                    บฑฑ
ฑฑบ          ณ 2-Xml com erro (Enviado)                                     บฑฑ
ฑฑบ          ณ 3-Xml cancelado (Pendente)                                   บฑฑ
ฑฑบ          ณ 4-Xml cancelado (Enviado)                                    บฑฑ
ฑฑบ          ณ X-Falha ao enviar o e-mail (Erro)                            บฑฑ
ฑฑบ          ณ Y-Falha ao enviar o e-mail (Cancelamento)                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Generico                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function HfSetMail(aTo,cSubject,cMensagem,cError,cAnexo,cAnexo2,cEmailDest,cCCdest,cBCCdest)
Return(Nil)  

*********************************************************
User Function HFNotificaMail(cStatus,cMsg,cModelo,cChave)
*********************************************************	

Local cPref     := ""                             
Local cTAG      := ""
Local cAnexo    := ""
Local cTpMail   := ""                
Local nRet      := 0 
Local cError    := ""
lOCAL cEmailErr := ""

If cModelo == "55"
 	cPref   := "NF-e"                             
	cTAG    := "NFE"
ElseIf cModelo == "65"
 	cPref   := "NFC-e"
	cTAG    := "NFE"
ElseIf cModelo == "57"
 	cPref   := "CT-e"                             
	cTAG    := "CTE"
EndIf
    
If cStatus $ "1|X" // Erro
	cEmailErr := AllTrim(SuperGetMv("XM_MAIL02")) // Conta de Email para cancelamentos
	cTpMail   := "Erro"
ElseIf cStatus $ "3|Y" // Cancelamento
	cEmailErr := AllTrim(SuperGetMv("XM_MAIL01")) // Conta de Email para Erros	
	cTpMail   := "Cancelamento"
EndIf  

lMailErr := !Empty(cEmailErr)        

If lMailErr

    aTo := Separa(cEmailErr,";")
    cAssunto:= "Aviso de "+cTpMail+" de Xml/"+cPref+" de Entrada."
	nRet := U_MAILSEND(aTo,cAssunto,cMsg,@cError,cAnexo,cAnexo,cEmailErr,"","")
	
EndIf

Return(nRet)

*************************************************
User Function GetInfoErro(cStatMail,cMsg,cModelo)
*************************************************

Local cPref     := ""                             
Local cTAG      := "" 
Local cRet      := ""

If cModelo == "55"
 	cPref   := "NF-e"                             
	cTAG    := "NFE"
ElseIf cModelo == "65"
 	cPref   := "NFC-e"                             
	cTAG    := "NFE"
ElseIf cModelo == "57"
 	cPref   := "CT-e"                             
	cTAG    := "CTE"
EndIf    

If cStatMail $ "1|X" // Erro
	cTpMail   := "erro"
ElseIf cStatMail $ "3|Y" // Cancelamento
	cTpMail   := "cancelamento"
EndIf  

cMsg := StrTran(cMsg,CRLF,'<br>')

If cStatMail $ "1|X|3|Y"
// Futuramente incluir template   
	cMsgCfg := ""
	cMsgCfg += '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
	cMsgCfg += '<html xmlns="http://www.w3.org/1999/xhtml">'
	cMsgCfg += '<head>'
	cMsgCfg += '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />'
	cMsgCfg += '<title>Importa XML</title>'
	cMsgCfg += '  <style type="text/css"> '
	cMsgCfg += '	<!--' 
	cMsgCfg += '	body {background-color: rgb(37, 64, 97);}' 
	cMsgCfg += '	.style1 {font-family: Hyperfont,Verdana, Arial;font-size: 12pt;}' 
	cMsgCfg += '	.style2 {font-family: Segoe UI,Verdana, Arial;font-size: 12pt;color: rgb(255,0,0)}' 
	cMsgCfg += '	.style3 {font-family: Segoe UI,Verdana, Arial;font-size: 10pt;color: rgb(37,64,97)}' 
	cMsgCfg += '	.style4 {font-size: 8pt; color: rgb(37,64,97); font-family: Segoe UI,Verdana, Arial;} '
	cMsgCfg += '	.style5 {font-size: 10pt}' 
	cMsgCfg += '	--> '
	cMsgCfg += '  </style>'
	cMsgCfg += '</head>'
	cMsgCfg += '<body>'
	cMsgCfg += '<table style="background-color: rgb(240, 240, 240); width: 800px; text-align: left; margin-left: auto; margin-right: auto;" id="total" border="0" cellpadding="12">'
	cMsgCfg += '  <tbody>'
	cMsgCfg += '    <tr>'
	cMsgCfg += '      <td colspan="2">'
	cMsgCfg += '    <Center>'
//			cMsgCfg += '      <img src="http://extranet.helpfacil.com.br/images/cabecalho.jpg">
	cMsgCfg += '      <H2>'+Capital(cTpMail)+'</H2>'
	cMsgCfg += '      </Center>'
	cMsgCfg += '      <hr>	'		
	cMsgCfg += '      <p class="style1">'+cMsg+'</p>'
	cMsgCfg += '      <hr>'			
	cMsgCfg += '      </td>'
	cMsgCfg += '    </tr>'
	cMsgCfg += '  </tbody>'
	cMsgCfg += '</table>'
	cMsgCfg += '<p class="style1">&nbsp;</p>'
	cMsgCfg += '</body>'
	cMsgCfg += '</html>'
 	cRet    := cMsgCfg
 	
EndIf

Return(cRet) 


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMoveXml   บ Autor ณ Roberto Souza      บ Data ณ  07/10/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Move o xml para a estrutura padrใo de grava็ใo.            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Importa Xml                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/           
User Function MoveXml(lAuto,cFilename, cError, cLogProc, acPath)

Local cPathXml  := AllTrim(SuperGetMv("MV_X_PATHX"))            
Local lRet      := .F.
Local nHandle   := 0
Local cIni      := ""
Local nPos      := 0

Private cCnpj   := SM0->M0_CGC    //AllTrim(GetNewPar("XM_PD_CNPJ","")) 

Default cLogProc:= ""

If Empty(cPathXml)
	cPathXml := cBarra+"xmlsource"+cBarra
EndIf

If !ExistDir(cPathXml)
	Makedir(cPathXml)
EndIf

If Right(Upper(cFilename),3) $ iif(GetNewPar("XM_USANFSE","N")=="S", "PDF", "")

	//if Getnewpar("XM_USAPDFN","N") == "S"

		If !ExistDir(cPathXml + "PDF\" + cCnpj + "\")
			Makedir(cPathXml + "PDF\" + cCnpj + "\")
		EndIf

		__CopyFile( cFilename, cPathXml + "PDF\" + cCnpj + "\" + cFilename)

		If File(cPathXml + "PDF\" + cCnpj + "\" + cFilename)
    		cLogProc+= Time()+"-"+"Arquivo "+cPathXml + "PDF\" + cCnpj + "\" + cFilename+ " criado com sucesso."+CRLF
			lRet := .T.
		Else
    		cLogProc+= Time()+"-"+"Arquivo "+cPathXml + "PDF\" + cCnpj + "\" + cFilename+ " nใo foi possivel copiar."+CRLF
		EndIf

	//else

		/*__CopyFile( cFilename, cPathXml+cFilename )

		If File(cPathXml+cFilename)
    		cLogProc+= Time()+"-"+"Arquivo "+cPathXml+cFilename + " criado com sucesso."+CRLF
			lRet := .T.
		Else
    		cLogProc+= Time()+"-"+"Arquivo "+cPathXml+cFilename + " nใo foi possivel copiar."+CRLF
		EndIf

	endif
	
	If File(cPathXml+cFilename)
    	cLogProc+= Time()+"-"+"Arquivo "+cPathXml+cFilename + " criado com sucesso."+CRLF
		lRet := .T.
	Else
    	cLogProc+= Time()+"-"+"Arquivo "+cPathXml+cFilename + " nใo foi possivel copiar."+CRLF
	EndIf*/

ElseIf Right(Upper(cFilename),3) $ "XML;" //"XML;"+iif(GetNewPar("XM_USANFSE","N")=="S", Upper(AllTrim(GetNewPar("XM_ARQ_NFS"))), "")  //NFCE_03 16/05 Pr้-Nota.

	cXml := MemoRead(cFilename)
	If Len(cXml) >= 65534
		cXml := LerComFRead( cFilename )
	endif

	//para ordenar primeiro as nfe e por ultimo as canceladas, e entใo se tiver a mesma chave com o xml principal
	//e o xml cancelado ele processa primeiro o xml principal depois o cancelado.
	If "<PROCCANCNFE" $ Upper(cXml) .Or.;
	   "<PROCCANCCTE" $ Upper(cXml) .Or.;
	  ("<PROCEVENTONFE" $ Upper(cXml) .and. "<TPEVENTO>110111" $ Upper(cXml) )
		cIni := "PCan"
	Elseif Right(Upper(cFilename),3) $ Upper(AllTrim(GetNewPar("XM_ARQ_NFS")))
		cIni := "NfseTxt"
	Else
		cIni := "Nfe"
	Endif

	nPos := AT(acPath,cFilename)
	
	if nPos > 0
		nPos := nPos + len(acPath)
		cFilename := Substr(cFilename,1,nPos-1)+cIni+Substr(cFilename,nPos,len(cFilename))
	endif

	nHandle := FCreate(cPathXml+cFilename)

	If nHandle <= 0
    	cError += "Nao foi possivel criar o arquivo "+cPathXml+cFilename
    	cLogProc+= Time()+"-"+"Nao foi possivel criar o arquivo "+cPathXml+cFilename+CRLF
	Else
		FWrite(nHandle, cXml)
		FClose(nHandle)
    	cLogProc+= Time()+"-"+"Arquivo "+cPathXml+cFilename + " criado com sucesso."+CRLF	
		lRet := .T.
	EndIf

EndIf

Return(lRet)

************************************
Static Function LerComFRead( cFile )
************************************
Local cRet := ""
Local nHandle := 0
Local cBuf := space(1200)
//Local nPointer := 0
//Local nLido := 0
//Local nEof := 0
//Local cEol := Chr( 13 ) + Chr( 10 )


nHandle := FT_FUse( cFile )

if nHandle = -1  
   return( "" )
endif

FT_FGoTop()
//nLast := FT_FLastRec()

While !FT_FEOF()   

   cBuf := FT_FReadLn() // Retorna a linha corrente
   cRet := cRet + cBuf

   FT_FSKIP()
End

FT_FUSE()

return cRet

****************************************************
Static Function GravarComFRead(cFinalF,cFileToWrite) //28032016
****************************************************
	Local nHandle := 0
	Local nTentai := 0
	Local lRet    := .T.
	nHandle := FCreate(cFinalF)
	
	If nHandle <= 0
		Return( .F. )
	Else
		do while FWrite(nHandle, cFileToWrite) <= 0
			nTentai++
			if nTentai > 3
				lRet := .F.
				Exit
			endif
		enddo
		FClose(nHandle)
	EndIf
	
Return( lRet )

*********************************
Static Function __Dummy(lRecursa) //warning W0010 Static Function <?> never called
*********************************
    lRecursa := .F.
    IF (lRecursa)
        __Dummy(.F.)
        U_MOVEXML()
        U_GetInfoErro()
        U_HFNotificaMail()
        U_HfSetMail()
        U_ProcMail()
        U_AtuXmlStat()
        U_ProcXml()
        U_AutoXml1()
        U_PopMsgCountNFE()
        U_MailIma2Off()
        U_MailPopOffNFE()
        U_PopConn()
        U_MailImapConn()
        U_MailPopConn()
        U_EMailNFE()
        U_OkProc()
        U_HFXML02D()
	EndIF
Return(lRecursa)
