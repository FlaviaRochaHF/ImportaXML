#include "totvs.ch"
#include "shell.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

static aMsgs
//--------------------------------------------------------------------------//
// Alterações realizadas:
// Flávia Rocha - 02/07/2020:
// Adequação da execução do Job Aguas do Brasil
//--------------------------------------------------------------------------//

//------------------------------------------------------------------------------------------------
/*/
CLASS:uSFTP
Autor:Marinaldo de Jesus [BlackTDN:(http://www.blacktdn.com.br/)]
Data:29/04/2015
Adequação para importa XML: Eneo
Data:28/11/2018
Descricao:Transferencia de dados segura usando o protocolo SFTP a partir do pscp.exe
Sintaxe:uSFTP():New()->Objeto do Tipo uSFTP

//------------------------------------------------------------------------------------------------
Documentacao de uso de pscp.exe:
http://tartarus.org/~simon/putty-snapshots/htmldoc/Chapter5.html#pscp-starting

//------------------------------------------------------------------------------------------------
Downloads do pscp.exe:
http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html

//------------------------------------------------------------------------------------------------
Obs.: pscp.exe devera ser adicionado como Resource no Projeto do IDE (TDS)
TODO: (1) Implementar o envio via socket utilizando o Harbour como conector sftp (https://github.com/NaldoDj/PuTTY)

//------------------------------------------------------------------------------------------------
PuTTY Secure Copy client

Release 0.64

Usage:

pscp [options] [user@]host:source target
pscp [options] source [source...] [user@]host:target
pscp [options] -ls [user@]host:filespec

Options:

-V        print version information and exit
-pgpfp    print PGP key fingerprints and exit
-p        preserve file attributes
-q        quiet, don't show statistics
-r        copy directories recursively
-v        show verbose messages
-load sessname  Load settings from saved session
-P port   connect to specified port
-l user   connect with specified username
-pw passw login with specified password
-1 -2     force use of particular SSH protocol version
-4 -6     force use of IPv4 or IPv6
-C        enable compression
-i key    private key file for user authentication
-noagent  disable use of Pageant
-agent    enable use of Pageant
-hostkey aa:bb:cc:...
manually specify a host key (may be repeated)
-batch    disable all interactive prompts
-unsafe   allow server-side wildcards (DANGEROUS)
-sftp     force use of SFTP protocol
-scp      force use of SCP protocol
/*/

//------------------------------------------------------------------------------------------------
CLASS uSFTP
DATA aSFTPLog

DATA cClassName
DATA nError
DATA oParameters

METHOD New() CONSTRUCTOR
METHOD FreeObj() /*DESTRUCTOR*/
METHOD ClassName()
METHOD Get(cParameter)
METHOD Set(cParameter,uValue)
//METHOD Execute(cSource,cTarget,cURL,cUSR,cPWD,cMode,lSrv,cPort,lForceClient,nSWMode)
METHOD ExecLoc(cSource,cTarget,cURL,cUSR,cPWD,cMode,lSrv,cPort,lForceClient,nSWMode)

END CLASS

//User Function SFTP()
//Return(uSFTP():New())
METHOD New() CLASS uSFTP
	self:ClassName()
	self:nError:=0
	self:aSFTPLog:=Array(0)
	IF FindFunction("U_THash")
		self:oParameters:=tHash():New()
	EndIF
	LoadMsgs()
Return(self)

METHOD FreeObj() CLASS uSFTP
	IF (Valtype(self:oParameters)=="O")
		self:oParameters:=self:oParameters:FreeObj()
	EndIF
	aSize(self:aSFTPLog,0)
	//self:=FreeObj(self)
Return(self)

METHOD ClassName() CLASS uSFTP
	self:cClassName:="USFTP"
Return(self:cClassName)

METHOD Get(cParameter) CLASS uSFTP
	Local uValue
	IF (Valtype(self:oParameters)=="O")
		uValue:=self:oParameters:Get(cParameter)
	EndIF
Return(uValue)

METHOD Set(cParameter,uValue) CLASS uSFTP
	IF (Valtype(self:oParameters)=="O")
		uValue:=self:oParameters:Set(cParameter,uValue)
	EndIF
Return(self)



METHOD ExecLoc(cSource,cTarget,cURL,cUSR,cPWD,cPort,nSWMode) CLASS uSFTP

	Local cEndWS := ""
	Local cCnpj  := AllTrim( GetNewPar("MV_ITCNPJ","12364969000120") )    //alltrim( SM0->M0_CGC )  //12364969000120
	Local aHeaderDel    := {}
              
	Aadd(aHeaderDel, "Authorization: Basic " + Encode64(cUSR+":"+cPWD))    //HEVERTON 07/07/2020 Necessário criar um array "aHeader" contendo os dados de login/senha
    Aadd(aHeaderDel, "Content-Type: application/json")                     //HEVERTON 07/07/2020 

	BEGIN SEQUENCE
	
		IF (Valtype(self:oParameters)=="O")
			DEFAULT cSource:=self:Get("cSource")
			DEFAULT cTarget:=self:Get("cTarget")
			DEFAULT cURL:=self:Get("cURL")
			DEFAULT cUSR:=self:Get("cUSR")
			DEFAULT cPWD:=self:Get("cPWD")
			DEFAULT cPort:=self:Get("cPort")
			DEFAULT nSWMode:=self:Get("nSWMode")
		EndIF
		
		cApi := "http://integrationsftp.hfconsulting.com.br"                   //endereço
		
		if !Empty(cCnpj)
			cEndWS += "//api/dados/?doc=" + cCnpj                              //CNPJ '//api/dados/?doc=12364969000120'
		else
			MsgAlert("Por favor informar um CNPJ")
		endif
		BaxArqSFTP(cApi,cEndWS,cTarget,aHeaderDel)
		
	END SEQUENCE
	
Return(self:nError)

//Mensagens
Static Function LoadMsgs(nError)

	Local cMsg
	Local nMsg
	DEFAULT aMsgs:=Array(0)
	
	IF Empty(aMsgs)
	
		aAdd(aMsgs,{0,"OK"})
		aAdd(aMsgs,{-1,"Impossivel Criar Diretorio"})
		aAdd(aMsgs,{-2,"Recurso de Transferencia SFTP nao Encontrado"})
		aAdd(aMsgs,{-3,"Problema na Execucao do Comando"})
		aAdd(aMsgs,{-4,""})
		aAdd(aMsgs,{-5,""})
		aAdd(aMsgs,{-6,""})
		aAdd(aMsgs,{-7,""})
		aAdd(aMsgs,{-8,""})
		aAdd(aMsgs,{-9,""})
		
	EndIF
	
	IF (ValType(nError)=="N")
		nMsg:=aScan(aMsgs,{|e|e[1]==nError})
		IF (nMsg>0)
			cMsg:=aMsgs[nMsg][2]
		EndIF
	EndIF
	
	DEFAULT cMsg:=""
	
Return(cMsg)


/////////////////////////////////////////////////////////////////////////////////
//  Funcao: GrvArqSFTP 			                           Data: 27/11/2019    //
//  Autor: Henrique Tofanelli 			            	   Cliente: HF         //
//  Descrição: Grava o conteudo do arquivo baixado no SFTP do metodo get.      //
/////////////////////////////////////////////////////////////////////////////////
Static Function GrvArqSFTP(cVarFile,cConteudo,cDirIma)

	Local cArq := ""
	//Local cDir := cDirIma //RetornaDir( cCnpj ) + cBarra + "Txt" + cBarra
	Local cVal := cConteudo
	Local nHandle := 00

	//TRATAMENTO REALIZADO PARA RETIRAR ESPAÇOS, ACENTOS E AJUSTAR O NOME PARA GRAVAÇÃO
	cArq := StrTran(cVarFile,".txt","")
	cArq := StrTran(cArq," ","")
	cArq := FwCutOff(cArq, .t.)

	If !Empty( cConteudo )
	
		// CRIA O NOME DO ARQUIVO (FUNÇÕES UTILIZADAS PARA GRAVAR COM O MESMO NOME DO ARQUIVO DO SFTP)
		nHandle := FCreate(cDirIma +"\"+ cArq + ".txt")
		FWrite(nHandle, cVal)
		FClose(nHandle)

		// VERIFICA SE O ARQUIVO FOI CRIADO CORRETAMENTE
		if nHandle = -1
		
			conout("Erro ao criar arquivo - ImpXMLSFTP " + Str(Ferror()))
			//else
			//FWrite(nHandle, Time() + CRLF)
			//FClose(nHandle)
			
		endif
		
	Else
	
		ConOut("@ImpXMLSFTP: Não foi possível capturar o conteúdo do arquivo na API")
		
	EndIf

Return

/////////////////////////////////////////////////////////////////////////////////
//  Funcao: BaxArqSFTP 			                           Data: 27/11/2019    //
//  Autor: Henrique Tofanelli 			            	   Cliente: HF         //
//  Descrição: Baixa os Arquivos retornados da API do SFTP do metodo get.      //
/////////////////////////////////////////////////////////////////////////////////
Static Function BaxArqSFTP(cEndWS,cDirHost,cDirIma,aHeaderDel)

	Local cVarFile := ""
	Local cCnpj    := AllTrim( GetNewPar("MV_ITCNPJ","12364969000120") ) 
    Local lContinua:= .T.
    Local nVezes   := 1
    Local lGetOK   := .F. 
    Local cErro    := ""
    Local nEspera  := 0
    
	oRestClient := FWRest():New( cEndWS )  //   http://integrationsftp.hfconsulting.com.br
	oRestClient:setPath(cDirHost)          //   //api/dados/?doc=12364969000120
	oRestClient:nTimeout := 20
	
    nEspera := GetNewPar("XM_ITSLEEP",10000)		  				//FR 17/07/2020	
    
	While lContinua .and. nVezes <= 10    //FR - 17/07/2020 - LOOP Para Tentar Baixar caso a 1a. tentativa dê erro, tenta 10x ou até conseguir
	
		Sleep(nEspera)
		
		If oRestClient:Get() 		
			lGetOk    := .T.
			lContinua := .F.
			Conout("<GESTAOXML> SUCESSO Na Tentativa Nro ==> " + Alltrim(Str(nVezes)) + " <== Da 2a. Requisicao SFTP ")  
									
		Else
			
			//ConOut("SFTP - " + oRestClient:GetLastError() )
			cErro := oRestClient:GetLastError()
			
			Conout("<GESTAOXML> FALHA Na Tentativa Nro ==> " + Alltrim(Str(nVezes)) + " <== Da 2a. Requisicao SFTP ==> " + cErro)  
						
			If oRestClient:GetLastError() == "204 NoContent"
						
				U_ShowResult( "SFTP - " + "Arquivo em fila de processamento. Tente novamente mais tarde..."  )	
			
			ElseIf "500" $ cErro
										
				CONOUT("<GESTAOXML> ===> " + cErro + " <===")	
				
			Elseif "401" $ cErro
			
				CONOUT("<GESTAOXML> LOGIN NAO AUTORIZADO ==> LOGIN INCORRETO <==")
				
			Elseif "407" $ cErro
			
				CONOUT("<GESTAOXML> LOGIN NAO AUTORIZADO ==> DADOS INCORRETOS: HOST ou USUARIO ou SENHA ou ARQUIVO <==")
						
			Else			
				U_ShowResult( "GETSFTP - " + oRestClient:GetLastError()  )				
			Endif  
			
			lContinua := .T.
			lGetOK    := .F. 
			
		Endif
		
		nVezes++  //FR continua a tentar
    
	Enddo  //FR - loop para tentar o get "n" vezes até conseguir 
	
	If lGetOK		//FR - 17/07/2020 - se conseguiu realizar o get, procede com o download do(s) arquivo(s)
	
		//PEGA O NOME DO ARQUIVO NO HEADER
		If !Empty( oRestClient:oresponseh:AHEADERFIELDS )			
			cVarFile := oRestClient:oresponseh:AHEADERFIELDS[7][2]
			cVarFile := FwCutOff( Alltrim( substr(cVarFile,22,50) ) )				
		Endif
		
		//Grava o arquivo Texto dentro da pasta definida
		GrvArqSFTP( cVarFile,oRestClient:GetResult(),cDirIma )
			
		Sleep(nEspera)
		
		xFtp := cVarFile
		xDir := cDirIma
		
		//Exclui o arquivo no SFTP 
		oRestDel := FWRest():New( cEndWS )	
			
		//cVarFile := "159267_NF_41082_NF_20190926.txt"	
		oRestDel:setPath("/api/dados/delete/?doc="+cCNPJ+"&fileName="+cVarFile)    //  /api/dados/delete/?doc=12364969000120&fileName=159267_NF_41082_NF_20190925.txt
		
		oRestDel:nTimeout := 20		
        
	    //FR 07/07/2020
		If oRestDel:Delete(aHeaderDel)	
					
			Conout("<GESTAOXML> Arquivo DELETADO Na Api E MOVIDO p/ Pasta LIDOS: " + Alltrim(cVarFile) + " -> Cod.Retorno: " + oRestDel:GetResult() +  iif( oRestDel:GetResult() == "200", " - OK"," - NO" ) )
			
			//MsgInfo("<GESTAOXML> - Arquivo MOVIDO p/ Pasta LIDOS: " + cVarFile + " - " + oRestDel:GetResult() )
				
		Else
			
			U_ShowResult( "<GESTAOXML> NAO DELETADO Na Api - Cod.Retorno: " + oRestDel:GetLastError()  ) 		
				
		Endif	  
			
		// primeiro limpa a propriedade
		oRestDel := NIL
	
		// agora sim limpa o objeto ou , limpa a instancia usando freeobj()
		FreeObj(oRestDel)  //FWFreeVar(@oFile)
	
	Endif		//lGetOK


	// primeiro limpa a propriedade
	oRestClient := NIL

	// agora sim limpa o objeto ou , limpa a instancia usando freeobj()
	FreeObj(oRestClient)  //FWFreeVar(@oFile)

	//Next nQtFile

	// FIM HENRIQUE

Return


//Exibe a mensagem de acordo com a chamada solicitado job ou erp.
User Function ShowResult( cValue )

if IsBlind()

	Conout( cValue )
	
else

	MsgStop( cValue )
	
endif

Return Nil
