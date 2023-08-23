#include "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "XMLXFUN.CH" 
#INCLUDE "topconn.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "FILEIO.CH"
//#include "xmlcsvcs.ch"

#DEFINE RETOOK  "OK"
#DEFINE ERRO01 	"Pagina FTP não encontrada - Favor verificar os parametros                  "
#DEFINE RETO01 	"ERR01"
#DEFINE ERRO02 	"Diretorio pesquisado no FTP não encontrado - Favor verificar os parametros "
#DEFINE RETO02 	"ERR02"
#DEFINE ERRO03 	"Arquivos da Ticket nao encontrados no diretorio informado !!!!             "
#DEFINE RETO03 	"ERR03"
#DEFINE ERRO04 	"Erro ao efetuar download - conexao instavel                                "
#DEFINE RETO04 	"ERR04"

Static lUnix  := IsSrvUnix()
Static cBarra := Iif(lUnix,"/","\")

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HFXML133  ºAutor  ³ Raul Seixas       º Data ³ Quinta-Feira º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Baixar arquivos da Ticket FTP                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ HFXML133                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//--------------------------------------------------------------------------//
// Alterações realizadas:
// Flávia Rocha - 02/07/2020:
// Adequação da execução do Job Aguas do Brasil
//--------------------------------------------------------------------------//
// Alterações realizadas:
// Flávia Rocha - 16/07/2020:
// Adequação da performance do download, na execução do Job Aguas do Brasil
//--------------------------------------------------------------------------//
User Function HFXML133()
Local aArea   := GetArea()
Local cItAtFTP := Padr(GetNewPar("XM_ITATFTP",Space(256)),256)
Local cItAtPOR := Padr(GetNewPar("XM_ITATPOR",Space(10)),10)
Local cItAtLOG := Padr(GetNewPar("XM_ITATLOG",Space(256)),256)
Local cItAtPAS := AllTrim( Decode64(GetNewPar("XM_ITATPAS",Space(50))) ) //Padr(GetNewPar("XM_ITATPAS",Space(256)),256)
Local cItAtDIR := Padr(GetNewPar("XM_ITATDIR",Space(256)),256)
Local cItAtPRT := GetNewPar("XM_ITATPRT","1")
Local oSCR1
Local oItAtFTP
Local oItAtPOR
Local oItAtDIR
Local oItAtPRT
Local oItAtLOG
Local oItAtPAS

Private aCombo19 := {}
Private xZBI      := GetNewPar("XM_TABIEXT","ZBI") 												//FR 17/07/2020
Private xZBI_     := iif(Substr(xZBI,1,1)=="S", Substr(xZBI,2,2), Substr(xZBI,1,3)) + "_"   	//FR 17/07/2020

DbSelectArea(xZBI)
Aadd(aArea, (xZBI)->(GetArea()) )

aAdd( aCombo19, "1=FTP" )
aAdd( aCombo19, "2=SFTP (SSH)" )

////////////////////////////
// - MONTA TELA INICIAL - //
////////////////////////////
@ 001,001 To 280,500 Dialog oSCR1 Title "Download Arquivo Integração Externa"

//@ 040,010 Say "Digite o caminho e nome do arquivo de origem:" Pixel
//@ 055,010 MsGet cArqOri When .F. Size 187,010 Pixel

@ 010,010 Say "Caminho SFTP:"  PIXEL //OF oPage:aDialogs[nPageInExt] COLOR CLR_BLUE FONT oFont01
@ 018,010 GET oItAtFTP VAR cItAtFTP WHEN .F. SIZE 100,10 PIXEL //OF oPage:aDialogs[nPageInExt]

@ 010,120 Say "Porta SFTP:"  PIXEL //OF oPage:aDialogs[nPageInExt] COLOR CLR_BLUE FONT oFont01
@ 018,120 GET oItAtPOR VAR cItAtPOR WHEN .F. SIZE 050,10 PIXEL //OF oPage:aDialogs[nPageInExt]

@ 032,010 Say "Diretório SFTP:"  PIXEL //OF oPage:aDialogs[nPageInExt] COLOR CLR_BLUE FONT oFont01
@ 040,010 GET oItAtDIR VAR cItAtDIR WHEN .F. SIZE 100,10 PIXEL //OF oPage:aDialogs[nPageInExt]

@ 032,120 Say "Protocolo SFTP:"  PIXEL //OF oPage:aDialogs[nPageInExt] COLOR CLR_BLUE FONT oFont01
@ 040,120 COMBOBOX oItAtPRT VAR cItAtPRT ITEMS aCombo19 WHEN .F. SIZE 100,10 PIXEL //OF oPage:aDialogs[nPageInExt]

@ 054,010 Say "Nome Usuário SFTP:"  PIXEL //OF oPage:aDialogs[nPageInExt] COLOR CLR_BLUE FONT oFont01
@ 062,010 GET oItAtLOG VAR cItAtLOG WHEN .F. SIZE 100,10 PIXEL //OF oPage:aDialogs[nPageInExt]

@ 054,120 Say "Senha SFTP:"  PIXEL //OF oPage:aDialogs[nPageInExt] COLOR CLR_BLUE FONT oFont01
@ 062,120 GET oItAtPAS VAR cItAtPAS WHEN .F. SIZE 100,10 PIXEL PASSWORD//OF oPage:aDialogs[nPageInExt]

//@ 055,200 Button "?" SIZE 005,012 PIXEL ACTION ABREARQ()

@ 100,050 Button "&Cancelar" Size 030,012 Pixel Action Close(oSCR1)
@ 100,117 Button "&Ok"       Size 030,012 Pixel Action (Close(oSCR1),Processa({|lEND| LERFTP(.T.,@lEND) },"Aguarde..."))

Activate Dialog oSCR1 Centered

RestArea( aArea )

Return()


//Vem do JOB
User Function HFFTPJOB(lAuto,lEnd,oProcess,cLogProc,nCount)

Local lRet := .F.
Local aArea   := GetArea()

Private xZBI      := GetNewPar("XM_TABIEXT","ZBI") 												//FR 17/07/2020
Private xZBI_     := iif(Substr(xZBI,1,1)=="S", Substr(xZBI,2,2), Substr(xZBI,1,3)) + "_"   	//FR 17/07/2020

DbSelectArea(xZBI)
Aadd(aArea, (xZBI)->(GetArea()) )

LERFTP(.F.,@lEND,@cLogProc,@nCount)

if nCount > 0
	lRet := .T.
endif
RestArea( aArea )     //FR 17/07/2020

Return( lRet )


/////////////////////////////////////////////////////////////////////////////////
//  Funcao: LERFTP 			                              Data: 27/11/2019     //
//  Autor: Rogerio Lino     			            	  Cliente: Aguas Brasil//
//  Descrição: Baixa os Arquivos retornados da API do SFTP do metodo get.      //
/////////////////////////////////////////////////////////////////////////////////
Static Function LERFTP(lMostra,lEND,cLogProc,nCount)

Local aRet := {}
Local lGrv := .F.
Local lErr := .F.
//Local lCon := .T.
Local nCon := 0
Local nErr := 0
Local nResta := 0
Local cItAtPRT := GetNewPar("XM_ITATPRT","1")
Local lSSH := (cItAtPRT = "2")
Local nQtArq := 0
Local cItAtFTP 	:= AllTrim( GetNewPar("XM_ITATFTP","") ) //GETMV("AB_HOST")
Local cItAtPOR	:= AllTRim( GetNewPar("XM_ITATPOR","22        ") ) //NIL //GETMV("AB_DOOR")
Local cItAtLOG	:= AllTrim( GetNewPar("XM_ITATLOG","") )  //GETMV("AB_USER")
Local cItAtPAS	:= AllTrim( Decode64(GetNewPar("XM_ITATPAS",Space(50))) ) 	//GETMV("AB_PASS")
//Local cItAtPAS	:= AllTrim( Encode64(GetNewPar("XM_ITATPAS",Space(50))) )   //FR TESTE
Local cItAtDIR  := AllTrim( GetNewPar("XM_ITATDIR","") )
Local cDir  	:= AllTrim( GetNewPar("MV_X_PATHX","\xmlsource\") )  		//GETMV("AB_DIRE")  //ver isso aqui
Local cCnpj     := AllTrim( GetNewPar("MV_ITCNPJ","12364969000120") ) 
Local cEndWS    := ""
Local oRestApi

Local lProssegue:= .T.						//FR 16/07/2020 
Local cErro     := ""						//FR 16/07/2020
Local nTamFil   := TAMSXG("033")[1]	   		//FR - 16/07/2020 - captura o tamanho da filial no grupo de campos SXG
Local cFILLANT  := ""                  		//FR - 16/07/2020
Local cFilAux   := ""						//FR - 16/07/2020
Local lContinua := .T.						//FR - 16/07/2020
Local nVezes    := 0						//FR - 16/07/2020
Local nEspera   := 0                                         
Local cFileCfg  := "hfcfgxml001a.xml"		//FR - 16/07/2020
Local cENT		:= ""                     //FR - 16/07/2020

Local aZBO, nPFil, nPCod, nPDes, nPDto, nPHro, nPChv, nPRsf, nPTpo, nPRvo, nPArq, nPFpt, nPExa, nPStt, nPEmp, nPMai
Local cHora    := ""

Private lVazio := .F.
Private xFtp   := ""
Private xArq   := ""
Private xDir   := ""
Private cJa    := ""
Private xZBI      := GetNewPar("XM_TABIEXT","ZBI") 												//FR 17/07/2020
Private xZBI_     := iif(Substr(xZBI,1,1)=="S", Substr(xZBI,2,2), Substr(xZBI,1,3)) + "_"   	//FR 17/07/2020
Private oXml																					//FR 16/07/2020

Default cLogProc := ""
Default nCount   := 0

//FR - 16/07/2020
If File(cFileCfg)
	oXml := U_LoadCfgX(1,cFileCfg,)	
	If oXml == Nil	
		Return			
	EndIf	
	cENT     := AllTrim(oXml:_MAIN:_WFXML01:_ENT:_XTEXT:TEXT)
Endif


//FR 16/07/2020
If nTamFil == 2
	cFILLANT := "01"
Elseif nTamFil == 4
	cFILLANT := "0101"
Elseif nTamFil == 6
	cFILLANT := "010101"
Endif

If Alltrim(cENT) <> Alltrim(cFILLANT)
	cFILLANT := Substr(cENT,3,nTamFil)
Endif

If cFilAnt <> cFILLANT  // "010101"
		
	If !IsBlind()					
		cFilAux  := cFilAnt     //FR - 16/07/2020 - dentro do protheus, troca pela filial 010101 (caso seja diferente) para baixar o arquivo
		cFilAnt  := cFILLANT    //FR - 16/07/2020 - cFilAnt recebe a filial "010101" que é a que tem acesso para baixar ftp, depois troca de volta 
	Else                        //FR - 16/07/2020 - se está via job, e a filial for diferente de 010101, passa direto e não executa esta função, porque já baixou pela filial 010101
		lProssegue := .F.
	Endif
	
Endif
//FR 16/07/2020

If lProssegue
cApi := "http://integrationsftp.hfconsulting.com.br"                   //endereço:http://integrationsftp.hfconsulting.com.br
		
cEndWS := "//api/dados/get/?doc=" + cCnpj                              //CNPJ: //api/dados/get/?doc=12364969000120

if !Empty( cItAtFTP )
	cEndWS += "&host="  + cItAtFTP                                     //Url :integracao.embratec.com.br 
else
	Conout("Por favor informar uma url")
endif
if !Empty( cItAtLOG )
	cEndWS += "&username=" + cItAtLOG                                      //Username: sftp.C14587
else
	Conout("Por favor informar um usuario")
endif
if !Empty( cItAtPAS )
	cEndWS += "&password=" + cItAtPAS                                      //Senha: v_-w@D$1k!nncY_
else
	Conout("Por favor informar uma senha")
endif

cEndWS += "&remoteFileName=SAIDA"                             //Diretorio
	nEspera := GetNewPar("XM_ITSLEEP",10000)		  				//FR 17/07/2020


	//-----------------------------------------------------------//
	// 1a. REQUISIÇÃO - CONEXÃO COM API - TRAZ A QTDE DE ARQUIVOS
	//-----------------------------------------------------------//
	//oRestClient:setPath( "//api/dados/?doc=61154480000130&host=integracao.embratec.com.br&username=sftp.C14587&password=v_-w%40D%241k!nncY_&remoteFileName=SAIDA")
	oRestApi := FWRest():New( cApi  )      	//     http://integrationsftp.hfconsulting.com.br
	oRestApi:setPath( cEndWS )     			//    //api/dados/get/?doc=12364969000120&host=integracao.embratec.com.br&username=sftp.C14587&password=v_-w@D$1k!nncY_&remoteFileName=SAIDA
	oRestApi:nTimeout := 120 
		
	nVezes   := 1
	cLogProc := "LOG DA INTEGRACAO: " + CRLF
	
	CONOUT("<GESTAOXML> INTEGRACAO EXTERNA SFTP -> A PROCESSAR ==> 1A. REQUISICAO: APi <==")
	
	While lContinua .and. nVezes <= 10    //FR - 17/07/2020 - LOOP Para Tentar Baixar caso a 1a. tentativa dê erro, tenta 10x ou até conseguir
	
		Sleep(nEspera)  							//FR 17/07/2020
		
		If oRestApi:Get()
			nQtArq    := Val( oRestApi:GetResult() )
			lContinua := .F.
			lErr      := .F.
			Conout("<GESTAOXML> SUCESSO Na Tentativa Nro ==> " + Alltrim(Str(nVezes)) + " <== Da 1a. Requisicao Api ==> " + Alltrim(Str(nQtArq)) + " <== Arquivos p/ Download")  
			
		Else
		
			U_ShowResult( oRestApi:GetLastError() )
			cErro := oRestApi:GetLastError()
			
			Conout("<GESTAOXML> FALHA Na Tentativa Nro ==> " + Alltrim(Str(nVezes)) + " <== Da 1a. Requisicao Api ===> " + cErro)  
			
			lContinua := .T.
			nEspera += 60000		//FR - acrescenta mais um minuto quando for fazer mais uma tentativa
			
			If "500" $ cErro
				lErr := .T.
				cLogProc += cErro + CRLF
				lContinua := .T.
				
			Elseif "401" $ cErro
				lErr := .T.
				cLogProc += cErro + " -> CNPJ / DOC INVÁLIDO -> " + cCnpj + CRLF
				lContinua := .T.
				CONOUT("<GESTAOXML> LOGIN NAO AUTORIZADO ==> LOGIN INCORRETO <==")
				
			Elseif "407" $ cErro
				lErr := .T.
				cLogProc += cErro + " ==> DADOS INCORRETOS: HOST ou USUARIO ou SENHA ou ARQUIVO <==" + CRLF
				lContinua := .T.
				CONOUT("<GESTAOXML> LOGIN NAO AUTORIZADO ==> DADOS INCORRETOS: HOST ou USUARIO ou SENHA ou ARQUIVO <==")
				
			Endif
			
		Endif
	    nVezes++
	    
	Enddo
	
	If !lErr
		// primeiro limpa a propriedade
		oRestApi := NIL   
		
		// agora sim limpa o objeto ou , limpa a instancia usando freeobj()
		FreeObj(oRestApi)  //FWFreeVar(@oFile)      
		
		ProcRegua( nQtArq )
		
		If nQtArq > 0
		    
		    CONOUT("<GESTAOXML> DOWNLOAD PREVISTO -> QTDE ARQUIVOS ==> " + Alltrim(Str(nQtArq)) + " <==")  		//FR 17/07/2020
		    
		    Sleep(nEspera)
			For nCon := 1 To nQtArq	
					
				If IsBlind()
					Conout( "<GESTAOXML> Baixando Arquivo SFTP " + cValToChar(nCon) + " de " + cValToChar(nQtArq) + "..." )
				Else
					IncProc( "Baixando Arquivo SFTP " + cValToChar(nCon) + " de " + cValToChar(nQtArq) + "..." )
				Endif
				
				lGrv := .F.
				lErr := .F.
				xFtp := ""
				xArq := ""
				xDir := ""
			
				aZBO := U_HF13ZBOA()
				U_HF13ZPOS( aZBO, @nPFil, @nPCod, @nPDes, @nPDto, @nPHro, @nPChv, @nPRsf, @nPTpo, @nPRvo, @nPArq, @nPFpt, @nPExa, @nPStt, @nPEmp, @nPMai )  
			
				IF lSSH
				
				    CONOUT("<GESTAOXML> INTEGRACAO EXTERNA SFTP -> A PROCESSAR ==> 2A. REQUISICAO: SFTP <==")
				    
					aRet := U_HF13SFTP( @xFtp, @xArq, lMostra, @nResta, @xDir ) 
				
					If aRet[1] = "OK"
					
						lGrv := .T.
						
					Else		
								
						If nErr > 0
							Exit
						Endif
						
						lErr := .T.
						nErr++
						
						If Len( aRet ) >= 2
							cLogProc += aRet[2]+CRLF
						EndIf
						
					EndIf
					
						
				Else
				
					If ! U_HF13FTP2( @xFtp, @xArq, @xDir )
					
						aRet := U_HF13FTP( @xFtp, @xArq, lMostra, @xDir )
						
						If aRet[1] = "OK"
						
							lGrv := .T.
							
						Else
						
							//if lVazio .and. nCon > 0
							//	Exit
							//endif
							
							If nErr > 0
								Exit
							Endif
							
							lErr := .T.
							nErr++
							
							If Len( aRet ) >= 2
								cLogProc += aRet[2]+CRLF
							Endif
							
						Endif
						
					Else
					
						lGrv := .T.
						
					Endif
					
				EndIF
			
				If lGrv
				
					nCount++
					cTmpFile := ""
					lTemZBI  := .F.
					If U_HF13GRVZBI( xFtp, xArq, @cJa, xDir, cFilAnt )				
					
						cLogProc += "Arquivo "+xFtp+" Baixado para: " + xDir + xArq + CRLF 					//FR 25/06/2020
						
						Conout(" <GESTAOXML> Arquivo ===> "+xFtp+" Baixado para ===> " + xDir + xArq + CRLF) 	//FR - 25/06/2020
						
						If !IsBlind()
							MsgInfo(" Arquivo -> "+xFtp+" Baixado Para -> " + xDir + xArq ) 				//FR - 25/06/2020
						Endif
						
									
					Else
					
						cLogProc += "Arquivo "+xFtp+" Ja baixado p/ pasta/nome ==> " + cJa + CRLF           //FR - 25/06/2020 - cJa já contém o caminho completo do arquivo
						
						Conout(" <GESTAOXML> Arquivo ===> "+xFtp+" Ja Baixado p/ Pasta/Nome ====> " + cJa)
						
						If !IsBlind()
							MsgInfo(" Arquivo -> "+xFtp+" Já Baixado com p/ Pasta/Nome ===> " + cJa)     
						Endif
						
					Endif
			
					
				Endif
			
				If lErr
				
					//AQUI vai para o ZBO, Log de not download
					If empty(xArq)
						xArq := Substr(dtos( date() ),1,6)+aRet[1]  //para não repetir e-mail
					Endif
					
					If nPFil > 0
						aZBO[nPFil][4] := xFilial( xZBO )
					Endif
					
					//nPCod  //Se o código for zero, vai somar 1
					If nPDes > 0
						aZBO[nPDes][4] := aRet[2]
					Endif
					
					If nPDto > 0
						aZBO[nPDto][4] := dDataBase
					Endif
					
					If nPHro > 0
						aZBO[nPHro][4] := Time()
					Endif
					
					If nPTpo > 0
						aZBO[nPTpo][4] := "2"
					Endif
					
					If nPArq > 0
						aZBO[nPArq][4] := xArq
					EndIf
					
					If nPFpt > 0
						aZBO[nPFpt][4] := xFtp
					EndIf
					
					If nPStt > 0
						aZBO[nPStt][4] := "0"
					EndIf
					
					//nPFil, nPCod, nPDes, nPDto, nPHro, nPChv, nPRsf, nPTpo, nPRvo, nPArq, nPFpt, nPStt, nPEmp, nPMai
					(xZBO)->( dbSetORder( 4 ) )
					If !(xZBO)->( dbSeek( xFilial(xZBO)+"2"+space(44)+xArq ) )	
						
						If U_HF13ZBOG( iif(empty(xArq),.T.,.F.), 4, xFilial(xZBO)+"2"+space(44)+xArq, aZBO )
					
						Endif
						
					Endif
					
				//AQUI vai para o ZBO, Log de not download
				Endif
			
				U_HF13MAIL( xArq, .F. )         //FR - 27/06/2020 - ENVIA O EMAIL para os endereços cadastrados na tela F12
				//nCon++
				
			Next nCon 
		
		Endif
	
	Endif //lErr   //FR 16/07/2020


	//If lMostra .And. !Empty(cLogProc)
	If !Empty(cLogProc)
	
		If IsBlind()  
			Conout( "SFTP - " + cLogProc )
		Else
			U_myAviso( "SFTP",cLogProc,{"Ok"},3 )
		Endif
		
	Endif
	
	If !IsBlind()
	
		If !Empty(cFilAux)
			cFilAnt := cFilAux 	//FR - volta a filial anterior
		Endif
		
	Endif
	
Endif 		//FR lProssegue

Return( NIL )


**********************************************************
User Function HF13GRVZBI( xFtp, xArq, cJa, xDir, xFilAnt )
**********************************************************
Local lRet      := .T.
Local aArea     := GetArea()
Local lTemZBI   := .F. 
Private xZBI    := GetNewPar("XM_TABIEXT","ZBI")
Private xZBI_   := iif(Substr(xZBI,1,1)=="S", Substr(xZBI,2,2), Substr(xZBI,1,3)) + "_" 


DbSelectArea(xZBI)
Aadd(aArea, (xZBI)->(GetArea()) )
(xZBI)->( OrdSetFocus(1) )

If (xZBI)->( dbSeek( xFilAnt + xFtp ) )
	cJa     := Alltrim(  (xZBI)->( FieldGet(FieldPos( xZBI_+"DIR" )) )  ) +  Alltrim(  (xZBI)->( FieldGet(FieldPos( xZBI_+"ARQ" )) )  )   //FR - 13/07/2020
	lTemZBI := .T. 
Else
	lTemZBI := U_fExistZBI(xFtp,@cJa) 
Endif

If !lTemZBI

	DbSelectArea( xZBI )
	RecLock(xZBI,.T.)
	
	(xZBI)->( FieldPut(FieldPos( xZBI_+"FILIAL"), xFilial( xZBI ) ) )
	(xZBI)->( FieldPut(FieldPos( xZBI_+"FTP"   ), xFtp ) )
	(xZBI)->( FieldPut(FieldPos( xZBI_+"ARQ"   ), xArq ) )
	(xZBI)->( FieldPut(FieldPos( xZBI_+"DIR"   ), xDir ) )
	(xZBI)->( FieldPut(FieldPos( xZBI_+"DTARQ" ), date() ) )  //data da baixa do arquivo via FTP, pega do servidor
	(xZBI)->( FieldPut(FieldPos( xZBI_+"ST" )   , "0" ) )
	
	(xZBI)->( MsUnlock() )
	
	cJa     := Alltrim(  (xZBI)->( FieldGet(FieldPos( xZBI_+"DIR" )) )  ) +  Alltrim(  (xZBI)->( FieldGet(FieldPos( xZBI_+"ARQ" )) )  )   //FR - 13/07/2020
	
	DbSelectArea( xZBI )
	DbCloseArea()
	
Endif

RestArea( aArea )

return(lRet)


User Function HF13FTP( xFtp, xArq, lMostra, xDir )

Local aArea     := GetArea()
Local lRet      := .T.
Local lOk       := .T.
Local aRetDir 	:= {}
Local cItAtFTP 	:= AllTrim( GetNewPar("XM_ITATFTP","") ) //GETMV("AB_HOST")
Local cItAtPOR	:= Val( GetNewPar("XM_ITATPOR","21        ") ) //NIL //GETMV("AB_DOOR")
Local cItAtLOG	:= AllTrim( GetNewPar("XM_ITATLOG","") )  //GETMV("AB_USER")
Local cItAtPAS	:= AllTrim( Decode64(GetNewPar("XM_ITATPAS",Space(50))) )  //AllTrim( GetNewPar("XM_ITATPAS","") )  //GETMV("AB_PASS")
Local cItAtDIR  := AllTrim( GetNewPar("XM_ITATDIR","") )
Local cDir  	:= AllTrim( GetNewPar("MV_X_PATHX","\xmlsource\") )  //GETMV("AB_DIRE")  //ver isso aqui
Local cDirFisc  := "", cDirConf := ""
Local cDate     := Dtos( date() )
Local cHora     := Time()
Local cArq      := ""
Local aErr      := ArrErr()
Local nErr      := 0
Local cMsg      := ""
Local nPos      := 0
Local oFtp

Default lMostra := .F.

cDirFisc := cDir + cBarra+"Fiscal"+cBarra
cDirFisc := StrTran(cDirFisc,cBarra+cBarra,cBarra)
If !ExistDir(cDirFisc)
	Makedir(cDirFisc)
EndIf
cDirConf := cDirFisc + cBarra+"Configuracao"+cBarra
cDirConf := StrTran(cDirConf,cBarra+cBarra,cBarra)
If !ExistDir(cDirConf)
	Makedir(cDirConf)
EndIf

cArq := Substr(cDate,1,4)+"_"+Substr(cDate,5,2)+"_"+Substr(cDate,7,2)+"_"+Substr(cHora,1,2)+Substr(cHora,4,2)+Substr(cHora,7,2)+".TXT"

oFtp := TFtpClient():New()
//oFtp:bFireWallMode := .T.
//oFtp:bUsesIpConnection := .T.
//oFtp:nControlPort  := cItAtPOR

//------------------//
// CONEXÃO COM O FTP
//------------------//
nErr := oFtp:FTPCONNECT ( cItAtFTP , cItAtPOR , cItAtLOG , cItAtPAS )    //CONEXÃO COM O FTP

if nErr <> 0
	nPos := aScan( aErr, {|x| x[1] = nErr  } )
	if nPos > 0
		cMsg := "FTP "+cItAtFTP + " " + aErr[nPos][2]
	else
		cMsg := "Nao foi possivel se conectar a "+cItAtFTP
	endif
	conout( AllTrim(oFtp:cErrorString)+" "+cMsg )
	if lMostra
		U_MyAviso("FTP", AllTrim(oFtp:cErrorString)+" "+cMsg ,{"Ok"},3)
	endif
	Return ( {RETO01,cMsg} )	
EndIf    

//	Tenta mudar do diretorio corrente ftp, para o diretorio
//	especificado como parametro
nErr := oFtp:ChDir( cItAtDIR )
if nErr  <>  0   // if ! FTPDIRCHANGE ( cItAtDIR )
	nPos := aScan( aErr, {|x| x[1] = nErr  } )
	if nPos > 0
		cMsg := "Diretorio "+cItAtDIR + ". " + aErr[nPos][2]
	else
		cMsg := "Nao foi possivel modificar diretorio " + cItAtDIR
	endif
	conout( cMsg )
	if lMostra
		U_MyAviso("FTP", cMsg ,{"Ok"},3)
	endif
	oFtp:Close()
	Return ( {RETO02,cMsg} )
EndIf

// Retorna apenas os arquivos contidos no local
// aRetDir := FTPDIRECTORY ( "*.txt" , )
aRetDir := oFtp:Directory( "*.txt", )
//Verifica se o array esta vazio
If Empty( aRetDir )
	conout( "Array Vazio!!" )
	cMsg := ERRO03
	if lMostra
		U_MyAviso("FTP",ERRO03 ,{"Ok"},3)
	endif
	oFtp:Close()
	Return ( {RETO03,cMsg} )
EndIf

nErr := oFtp:ReceiveFile( AllTrim(aRetDir[1][1]), cDirConf+cArq )  //cDirConf+cArq
if nErr <> 0   //if ! FTPDOWNLOAD ( cDirConf + cArq, aRetDir[1][1] )
	xFtp := aRetDir[1][1]
	nPos := aScan( aErr, {|x| x[1] = nErr  } )
	if nPos > 0
		cMsg := aRetDir[1][1] + " para " + cArq + ". " + aErr[nPos][2]
	else
		cMsg := "Nao foi possivel realizar o download!! do arquivo " + aRetDir[1][1] + " para " + cArq
	endif
	conout( cMsg )
	if lMostra
		U_MyAviso("FTP", cMsg ,{"Ok"},3)
	endif
	oFtp:Close()
	Return ( {RETO04,cMsg} )
EndIf

xFtp := aRetDir[1][1]
xArq := cArq
xDir := cDirConf

oFtp:DeleteFile( aRetDir[1][1] )  //Excluir o Bixo. Ja que baixou

oFtp:Close()  // FTPDISCONNECT()

RestArea(aArea)
CONOUT(" <GESTAOXML> ====> Baixado Com Sucesso <==== ") //FR - 25/06/2020
Return( {RETOOK,"Baixado Com Sucesso"} )


User Function HF13FTP2( xFtp, xArq, xDir )
Local aArea     := GetArea()
Local lRet      := .T.
Local lOk       := .T.
Local aRetDir 	:= {}
Local cItAtFTP 	:= AllTrim( GetNewPar("XM_ITATFTP","") ) //GETMV("AB_HOST")
Local cItAtPOR	:= Val( GetNewPar("XM_ITATPOR","21        ") ) //NIL //GETMV("AB_DOOR")
Local cItAtLOG	:= AllTrim( GetNewPar("XM_ITATLOG","") )  //GETMV("AB_USER")
Local cItAtPAS	:= AllTrim( Decode64(GetNewPar("XM_ITATPAS",Space(50))) )   //AllTrim( GetNewPar("XM_ITATPAS","") )  //GETMV("AB_PASS")
Local cItAtDIR  := AllTrim( GetNewPar("XM_ITATDIR","") )
Local cDir  	:= AllTrim( GetNewPar("MV_X_PATHX","\xmlsource\") )  //GETMV("AB_DIRE")  //ver isso aqui
Local cDirFisc  := "", cDirConf := ""
Local cDate     := Dtos( date() )
Local cHora     := Time()
Local cArq      := ""
Local aErr      := ArrErr()
Local nErr      := 0
Local cMsg      := ""
Local nPos      := 0
Local oFtp

cDirFisc := cDir + cBarra+"Fiscal"+cBarra
cDirFisc := StrTran(cDirFisc,cBarra+cBarra,cBarra)
If !ExistDir(cDirFisc)
	Makedir(cDirFisc)
EndIf
cDirConf := cDirFisc + cBarra+"Configuracao"+cBarra
cDirConf := StrTran(cDirConf,cBarra+cBarra,cBarra)
If !ExistDir(cDirConf)
	Makedir(cDirConf)
EndIf

cArq := Substr(cDate,1,4)+"_"+Substr(cDate,5,2)+"_"+Substr(cDate,7,2)+"_"+Substr(cHora,1,2)+Substr(cHora,4,2)+Substr(cHora,7,2)+".TXT"


if ! FTPCONNECT ( cItAtFTP , cItAtPOR , cItAtLOG , cItAtPAS )
	Return( .F. )
Endif

//	Tenta mudar do diretorio corrente ftp, para o diretorio
//	especificado como parametro
if ! FTPDIRCHANGE ( cItAtDIR )
	FTPDISCONNECT()
	Return ( .F. )
EndIf

// Retorna apenas os arquivos contidos no local
aRetDir := FTPDIRECTORY ( "*.txt" , )
//Verifica se o array esta vazio
If Empty( aRetDir )
	lVazio := .T.
	FTPDISCONNECT()
	Return ( .F. )
EndIf

if ! FTPDOWNLOAD ( cDirConf + cArq, aRetDir[1][1] )
	FTPDISCONNECT()
	Return ( .F. )
EndIf

xFtp := aRetDir[1][1]
xArq := cArq
xDir := cDirConf

FTPERASE( aRetDir[1][1] )

FTPDISCONNECT()

RestArea(aArea)
Return(.T.)


/////////////////////////////////////////////////////////////////////////////////
//  Funcao: HF13SFTP 			                               Data: 27/11/2019//
//  Autor: Rogerio Lino     			            	   Cliente: Aguas Brasil//
//  Descrição: Baixa os Arquivos retornados da API do SFTP do metodo get.      //
/////////////////////////////////////////////////////////////////////////////////
User Function HF13SFTP( xFtp, xArq, lMostra, nResta, xDir )

Local aArea     := GetArea()
Local lRet      := .T.
Local lOk       := .T.
Local lSrv      := .T.
Local lTem      := .F.
Local lForceClient := .F.
Local lCopyFile    := .F.
Local nMode     := 1
Local aRetDir 	:= {}
Local cItAtFTP 	:= AllTrim( GetNewPar("XM_ITATFTP","") ) //GETMV("AB_HOST")
Local cItAtPOR	:= AllTRim( GetNewPar("XM_ITATPOR","22        ") ) //NIL //GETMV("AB_DOOR")
Local cItAtLOG	:= AllTrim( GetNewPar("XM_ITATLOG","") )  //GETMV("AB_USER")
Local cItAtPAS	:= AllTrim( GetNewPar("XM_ITATPAS","") )  //AllTrim( Decode64(GetNewPar("XM_ITATPAS",Space(50))) ) //GETMV("AB_PASS")
Local cItAtDIR  := AllTrim( GetNewPar("XM_ITATDIR","") )
Local cDir  	:= AllTrim( GetNewPar("MV_X_PATHX","\xmlsource\") )  //GETMV("AB_DIRE")  //ver isso aqui
Local cDirFisc  := "", cDirConf := ""
Local nFiles    := 0
Local aFiles    := {}
Local cDate     := Dtos( date() )
Local cHora     := Time()
Local cArq      := ""
Local cFtp      := ""
Local aErr      := ArrErr()
Local nErr      := 0
Local cMsg      := ""
Local nPos      := 0
Local cDirArq   := ""
Local oSFtp
Local lTemZBI   := .F.		//FR 16/07/2020
Local lCopia    := .F.		//FR 16/07/2020

Default lMostra := .F.

cDirFisc := cDir + cBarra+"Fiscal"+cBarra  				// \xmlsource\can\\Fiscal\
cDirFisc := StrTran(cDirFisc,cBarra+cBarra,cBarra)		// \xmlsource\can\Fiscal\

If !ExistDir(cDirFisc)
	Makedir(cDirFisc)
EndIf

cDirConf := cDirFisc + cBarra+"Configuracao"+cBarra		// \xmlsource\can\Fiscal\\Configuracao\
cDirConf := StrTran(cDirConf,cBarra+cBarra,cBarra)  	// \xmlsource\can\Fiscal\Configuracao\

If !ExistDir(cDirConf)
	Makedir(cDirConf)
EndIf

if Right(cItAtDIR,1) != "/" //essa do FTP por isso a barra normal
	cDirArq := cItAtDIR + "/"
Endif

cDirArq := cItAtDIR + "*.*"  //Todo los arcuevos TXT		//SAIDA/*.*

if lMostra
	lSrv := .F.
	lForceClient := .T.
endif

Sleep(GetNewPar("XM_ITSLEEP",10000) )  							//FR 17/07/2020
oSFtp := uSFTP():New()

if nResta <= 0
	//If lMostra  //Via Tela
		nErr := oSFtp:ExecLoc( cItAtDIR, cDirFisc, cItAtFTP, cItAtLOG, cItAtPAS, cItAtPOR, nMode)      //FR aqui baixa efetivamente o arquivo do FTP para a pasta \fiscal
	//Else   //Via JOB
	//	nErr := oSFtp:Execute( cItAtDIR, cDirFisc, cItAtFTP, cItAtLOG, cItAtPAS, "G", lSrv, cItAtPOR, lForceClient, nMode )
	//EndIf
Else 
	nErr := 0  //Pegar o resto da pasta
Endif

oSFtp:FreeObj()   //FR

if nErr <> 0
	if nErr = -1
		RestArea(aArea)
		Return({ERRO04,"Impossivel Criar Diretorio"})
	ElseIf nErr = -2
		RestArea(aArea)
		Return({ERRO01,"Recurso de Transferencia SFTP nao Encontrado"})
	Else
		RestArea(aArea)
		Return({ERRO01,"Problema na Execucao do Comando"})
 	Endif
Endif

nFiles := aDir(cDirFisc+"*.*",@aFiles)
nFile  := 0
if nFiles > 0
    /*            //FR - inserido no loop de leitura por arquivo, senão fará apenas para um arquivo somente
	Sleep(GetNewPar("XM_ITSLEEP",10000) )  							//FR 17/07/2020
	cArq := Substr(cDate,1,4)+"_"+Substr(cDate,5,2)+"_"+Substr(cDate,7,2)+"_"+Substr(cHora,1,2)+Substr(cHora,4,2)+Substr(cHora,7,2)+".TXT"
	lTem := .F.
	*/
	For nFile := 1 To Len(aFiles) //nFiles
	    
        lTemZBI := .F.
		cArq := Substr(cDate,1,4)+"_"+Substr(cDate,5,2)+"_"+Substr(cDate,7,2)+"_"+Substr(cHora,1,2)+Substr(cHora,4,2)+Substr(cHora,7,2)+".TXT"
			
        If aFiles[nFile] <> Nil
        	cFtp := AllTrim(aFiles[nFile])
        	lTemZBI := U_fExistZBI(cFtp) 
	    Endif
        
      	If !lTemZBI    	     	
      	
			lCopia := .T.		
			
			If lCopia				
				cTmpFile := cDirConf + cArq
				lCopyFile:=__CopyFile(cDirFisc+cFtp,cTmpFile)
				
				IF .NOT.(lCopyFile)
					Return ( {RETO04,ERRO04} )
				Else
					FErase(cDirFisc+cFtp)  //Ja que copiou tenta apagar
				Endif
				
				xFtp := cFtp
				xArq := cArq
				xDir := cDirConf
				nResta := aDir(cDirFisc+"*.*",@aFiles)				
			Else			
				nResta := 0
				lVazio := .T.				
				xArq := cArq				
				//RestArea(aArea)
				//Return ( {RETO03,ERRO03} )				
			Endif 
			
		Else
		
      		FErase(cDirFisc+AllTrim(aFiles[nFile]))  //Ja que copiou tenta apagar  (EX: 218946_NF_39982_NF_20200522.txt apaga o arquivo original vindo do ftp) 
      		     	     	
      	Endif
        
	Next nFile
	/*      //FR - comentado e colocado dentro do loop, pois fazia apenas para um arquivo e não vários que possam ter sido baixados
	If lTem
	
		cTmpFile := cDirConf + cArq
		lCopyFile:=__CopyFile(cDirFisc+cFtp,cTmpFile)
		
		IF .NOT.(lCopyFile)
			Return ( {RETO04,ERRO04} )
		Else
			FErase(cDirFisc+cFtp)  //Ja que copiou tenta apagar
		Endif
		
		xFtp := cFtp
		xArq := cArq
		xDir := cDirConf
		nResta := aDir(cDirFisc+"*.*",@aFiles)
		
	Else
	
		nResta := 0
		lVazio := .T.
		
		xArq := cArq
		
		//RestArea(aArea)
		//Return ( {RETO03,ERRO03} )
		
	Endif
	*/            
	          
Else

	lVazio := .T.
	RestArea(aArea)
	Return ( {RETO03,ERRO03} )
	
Endif

RestArea(aArea)

Return( { RETOOK,"Baixado Com Sucesso"} )


User Function TSTGetSSL()

  Local cURL := "http://integracao.embratec.com.br"
  Local nTimeOut := 120
  Local aHeadOut := {}
  Local cHeadRet := ""
  Local cGetRet := ""

  // Acrescenta o UserAgent na requisição ...
  // http://tools.ietf.org/html/rfc3261#page-179

  Private sPostRet := ""

  AAdd( aHeadOut, 'User-Agent: Mozilla/4.0 (compatible; Protheus ' + GetBuild() + ')' )
  cGetRet := HTTPSGet( cURL, "\certs\cert.pem", "\certs\privkey.pem", "pwdprivkey", "WSDL", nTimeOut, aHeadOut, @cHeadRet )
   
  if Empty( sPostRet )
    conout( "Fail HTTPSGet" )
  else
    conout( "OK HTTPSGet" )
    varinfo( "WebPage", cGetRet )
  endif
   
  varinfo( "Header", cHeadRet )
  
return


Static Function ArrErr()

Local aRet := {}

aadd( aRet, { 0, 'Operação completada com Sucesso'})
aadd( aRet, { 4, 'Conecção terminada por que foi completada'})
aadd( aRet, { 8, 'Porta Invalida'                   })
aadd( aRet, {10, 'The request was denied by server' })
aadd( aRet, {14, 'Could not connect to the server'  })
aadd( aRet, {27, 'Caminho não existe RootPath Protheus'  })
aadd( aRet, {32, 'Could not find the source file'  })
aadd( aRet, {38, 'There was no response by the server'  })
aadd( aRet, {48, 'RETR comando falhou'  })
aadd( aRet, {49, 'Porta ou comando PASV Falhou'  })
aadd( aRet, {50, 'LIST comando falhou'  })
aadd( aRet, {51, 'STOR comando falhou'  })
aadd( aRet, {62, 'Usuário Inválido'     })
aadd( aRet, {63, 'Senha Inválida'       })
aadd( aRet, {64, 'ACCT comando falhou'  })
aadd( aRet, {65, 'RNFR comando falhou'  })
aadd( aRet, {66, 'RNTO comando falhou'  })
aadd( aRet, {98, 'Conecção Abortada'    })
aadd( aRet, {99, 'HostName Inválido'    })
aadd( aRet, {100,'Endereço IP Inválido' })
aadd( aRet, {106,'The parameter provided to the method was invalid' })
aadd( aRet, {108,'The command send in Quote method was empty' })
aadd( aRet, {115,'The REST command is not supported by the server' })

Return( aRet )



Static Function __Dummy(lRecursa) //warning W0010 Static Function <?> never called

    lRecursa := .F.
    
    IF (lRecursa)
        __Dummy(.F.)
        U_HFXML133()
        U_HF13FTP()
        U_HF13FTP2()
	EndIF
	
Return(lRecursa)
User Function fExistZBI(xFtp,cJa,cArqExt)
Local cQuery := ""
Local cAliasZBI := GetNextAlias() 
Local lTemZBI   := .F.
Local cQuery    := ""
Private xZBI    := GetNewPar("XM_TABIEXT","ZBI") 												//FR 17/07/2020
Private xZBI_   := iif(Substr(xZBI,1,1)=="S", Substr(xZBI,2,2), Substr(xZBI,1,3)) + "_"   	//FR 17/07/2020

cQuery := " SELECT * FROM " + RetSqlName(xZBI) + " ZBI "  + CRLF
cQuery += " WHERE " + CRLF

If xFtp <> Nil
	cQuery += " RTRIM( UPPER(" + xZBI_+"FTP )) = '" + UPPER(Alltrim(xFtp)) + "' "  + CRLF
Elseif cArqExt <> Nil
	cQuery += " RTRIM( UPPER(" + xZBI_+"ARQ )) = '" + UPPER(Alltrim(cArqExt)) + "' "  + CRLF 
Elseif (cArqExt == Nil .and. xFtp == Nil)
	cQuery += " " + xZBI_+"ST IN ('0','1') "+CRLF
	
	//CONOUT("<AGUASBR> VER SE TEM ZBI <===") //FR RETIRAR
Endif 

cQuery += " AND ZBI.D_E_L_E_T_ <> '*' "
MemoWrite("\TEMP\TEMZBI.SQL", cQuery)

If Select(cAliasZBI)> 0
	DbselectArea(cAliasZBI)
	DbCloseArea()
Endif

DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasZBI,.F.,.T.)
DbSelectArea(cAliasZBI) 

DbGoTop()
If (cAliasZBI)->(!Eof()) 
	(cAliasZBI)->(Dbgotop()) 
	While (cAliasZBI)->(!EOF())
	    
	    If cJa <> Nil
			cJa  := Alltrim( (cAliasZBI)->( FieldGet(FieldPos( xZBI_+"DIR" )) )  ) + Alltrim( (cAliasZBI)->( FieldGet(FieldPos( xZBI_+"ARQ" )) ) )   //FR - 16/07/2020
		Endif
		lTemZBI := .T.
		
		(cAliasZBI)->(Dbskip())
		
	Enddo
	DbselectArea(cAliasZBI)
	DbCloseArea()
Endif

Return(lTemZBI)
