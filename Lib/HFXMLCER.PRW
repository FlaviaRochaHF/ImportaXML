#INCLUDE "FILEIO.CH"
#INCLUDE "RPTDEF.CH"                                      
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "XMLXFUN.CH"

Static cBarra := Iif(IsSrvUnix(),"/","\")


/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �SpedNFeCFG� Autor �Eduardo Riera          � Data �18.06.2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Configura o Totvs Services para a nota fiscal eletronica    ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function HFXMLCER( cModel )
Local nRet      := 0
Local cDir      := AllTrim(SuperGetMv("MV_X_PATHX"))
Local oSCR1     := NIL
Local cPassWord := Space(24)
Local cFunName  := FunName() //Retorna o nome do programa em execu��o a partir do menu do Protheus
Local aTexto    := {}
Local cIdEnt    := AllTrim(cEmpAnt)+AllTrim(cFilAnt) //+AllTrim( U_GetIdEnt() )   //ident para criar os no
Local nI := 0
Local nLin := 0

Default cModel	:= ""

Private cCert    := Space(250)
Private cDirCert := AllTrim(cDir+cBarra+"certs"+cBarra)

cDirCert := StrTran(cDirCert,cBarra+cBarra,cBarra)
cDirCert := StrTran(cDirCert,cBarra+cBarra,cBarra)

If !ExistDir(cDirCert)
	Makedir(cDirCert)
EndIf

	if cModel == "2"  //Verificar se o bixo ta configurado
		if Verificado( cIdEnt )
			Return( nRet )
		endif
	endif


	aadd( aTexto, "Esta rotina tem como objetivo configurar o certificado para integra��o do Protheus X Importa XML." )
	aadd( aTexto, "Empresa.: "+cEmpAnt+" "+SM0->M0_NOMECOM )
	aadd( aTexto, "Cnpj.: "+SM0->M0_CGC )
	aadd( aTexto, "Filial.: "+cFilAnt )
	aadd( aTexto, "Entidade.: "+cIdEnt )

	////////////////////////////
	// - MONTA TELA INICIAL - //
	///////////////////////////
	@ 001,001 To 280,500 Dialog oSCR1 Title "Selecione Certificado PFX" //STYLE DS_MODALFRAME
	//DEFINE MSDIALOG oDlg TITLE "Configura��es Importa XML" FROM 000,000 TO 430,800 PIXEL STYLE DS_MODALFRAME STATUS

	nLin := 10
	@ nLin+=9,010 Say aTexto[ 01 ] //Pixel
	@ nLin+=9,010 Say aTexto[ 02 ] //Pixel
	@ nLin+=9,010 Say aTexto[ 03 ] //Pixel
	@ nLin+=9,010 Say aTexto[ 04 ] //Pixel
	@ nLin+=9,010 Say aTexto[ 05 ] //Pixel

	@ 075,010 Say "Digite o caminho e nome do arquivo certificado:" Pixel
	@ 085,010 MsGet cCert When .F. Size 227,010 Pixel

	@ 085,240 Button "?" SIZE 005,012 PIXEL ACTION ABREARQ()
	
	@ 110,010 SAY "Informe senha do arquivo digital" SIZE 270,010 PIXEL
	@ 110,010 GET cPassWord SIZE 100,010 PIXEL PASSWORD

	@ 110,160 Button "&Cancelar" Size 030,012 Pixel Action (nRet := 9, Close( oSCR1 ) )
	@ 110,207 Button "&Ok"       Size 030,012 Pixel Action Processa({ || iif(IsCDReady(cCert,AllTrim(cPassWord),cIdEnt),Close(oSCR1),nRet := 9) },"Aguarde...")
	Activate Dialog oSCR1 Centered

Return( nRet )

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �IsCDReady � Autor �Eduardo Riera          � Data �18.06.2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Verifica se o certificado digital foi transferido com suces-���
���          �so                                                          ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpN1: [1] PEM; [2] PFX                                     ���
���          �ExpC2: Certificado digital                                  ���
���          �ExpC3: Private Key                                          ���
���          �ExpC4: Password                                             ���
���          �ExpC5: Slot                                                 ���
���          �ExpC6: Label                                                ���
���          �ExpC7: Modulo                                               ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function IsCDReady(cCert,cPassWord,cIdEnt)
Local oWS
Local lRetorno := .T.

//������������������������������������������������������������������������Ŀ
//�Obtem o codigo da entidade                                              �
//��������������������������������������������������������������������������
If (!Empty(cCert) .And. !Empty(cPassWord) )

	If !File(cCert)
		Aviso("CERT","Arquivo n�o encontrado",{"OK"},3)
		lRetorno := .F.
	EndIf
	If !Empty(cIdEnt) .And. lRetorno
		cResult := U_HFCfgPFX( "TOTVS",cIdEnt,cCert,cPassWord )
		Aviso("CERT",cResult,{"OK"},3)
	EndIf
Else
	lRetorno := .F.
	if empty(cCert)
		Aviso("CERT","Arquivo n�o Informado",{"OK"},3)
	endif
	if Empty(cPassWord)
		Aviso("CERT","Senha n�o Informada",{"OK"},3)
	endif
EndIf
Return(lRetorno)



//U_HFCfgPFX()
USer Function HFCfgPFX(cTok,cID_ENT,Certificate,cPASS) //WSSEND MSG WSSERVICE SPEDCFGNFE
	Local lRet      := .F.
	Local cPFX      := ""
	Local cError    := ""
	Local cContent  := ""
	Local cKey      := ""
	Local cCert     := ""
	Local cCA       := ""
	Local cMsg      := ""
	
	Default cTok := "TOTVS"
	Default cID_ENT := AllTrim(cEmpAnt)+AllTrim(cFilAnt) //+AllTrim(U_GetIdEnt())
	Default Certificate := ""
	Default cPASS       := ""

	cPFX      := cDirCert + cID_ENT + ".pfx"
	cKey      := cDirCert + cID_ENT + "_key.pem"
	cCert     := cDirCert + cID_ENT + "_cert.pem"
	cCA       := cDirCert + cID_ENT + "_ca.pem"
	__CopyFile( Certificate, cPFX )

	lRet := PFXKey2PEM( cPFX, cKey, @cError, cPASS )
    If lRet
    	cContent := MemoRead(cKey)
    	ConOut(Repl("-", 80))
    	ConOut(cContent)
    	ConOut(Repl("-", 80))
    	varinfo("Key", cContent)
		If !PutMv("XM_CERTKEY",cKey)
			SX6->(RecLock("SX6",.T.))
				SX6->X6_FIL     := cFilAnt //xFilial( "SX6" )
				SX6->X6_VAR     := "XM_CERTKEY"
				SX6->X6_TIPO    := "C"
				SX6->X6_DESCRIC := "Certificado KEY IMPXML"
				SX6->(MsUnLock())
			PutMv("XM_CERTKEY",cKey)
		EndIf
    Else
    	cMsg := "ERR "+cKey+" "+cError
    	Alert( cMSg )
    EndIf

	lRet := PFXCert2PEM( cPFX, cCert, @cError, cPASS )
    If lRet
    	cContent := MemoRead(cCert)
    	ConOut(Repl("-", 80))
    	ConOut(cContent)
    	ConOut(Repl("-", 80))
    	varinfo("Cert", cContent)
		If !PutMv("XM_CERTCER",cCert)
			SX6->(RecLock("SX6",.T.))
				SX6->X6_FIL     := cFilAnt //xFilial( "SX6" )
				SX6->X6_VAR     := "XM_CERTCER"
				SX6->X6_TIPO    := "C"
				SX6->X6_DESCRIC := "Certificado Cert IMPXML"
				SX6->(MsUnLock())
			PutMv("XM_CERTCER",cCert)
		EndIf
    Else
    	cMsg := "ERR "+cCert+" "+cError
    	Alert( cMSg )
    EndIf

	lRet := PFXCA2PEM( cPFX, cCA, @cError, cPASS )
	if lRet
    	cContent := MemoRead(cCA)
    	ConOut(Repl("-", 80))
    	ConOut(cContent)
    	ConOut(Repl("-", 80))
    	varinfo("CA", cContent)
		If !PutMv("XM_CERTCA",cCA)
			SX6->(RecLock("SX6",.T.))
				SX6->X6_FIL     := cFilAnt //xFilial( "SX6" )
				SX6->X6_VAR     := "XM_CERTCA"
				SX6->X6_TIPO    := "C"
				SX6->X6_DESCRIC := "Certificado CA IMPXML"
				SX6->(MsUnLock())
			PutMv("XM_CERTCA",cCA)
		EndIf
    Else
    	cMsg := "ERR "+cCA+" "+cError
    	Alert( cMSg )
    EndIf


    if Empty( cMsg )
    	cMSg := "OK Cetificado Configurado."
 		If !PutMv("XM_CERTPSW",cPASS)
			SX6->(RecLock("SX6",.T.))
				SX6->X6_FIL     := cFilAnt //xFilial( "SX6" )
				SX6->X6_VAR     := "XM_CERTPSW"
				SX6->X6_TIPO    := "C"
				SX6->X6_DESCRIC := "Senha do Certificado"
				SX6->(MsUnLock())
			PutMv("XM_CERTPSW",cPASS)
		EndIf
    endif

    rstmvbuff()

    if cPFX <> Certificate
    	FErase(cPFX)
    endif
    
Return( cMsg )



Static Function AbreArq()
Local cTipo

cTipo	:= "Arquivo Texto (*.txt) | *.PFX  | "                     // + GETF_NOCHANGEDIR

cCert := UPPER(cGetFile(cTipo,"Selecione o arquivo para classifica��o(*.txt)",,"C:"+cBarra,.T.,GETF_LOCALHARD,.F.)) //GETF_NETWORKDRIVE

Return()


Static Function Verificado( cIdEnt )
Local lRet  := .T.
Local cKey  := ""
Local cCert := ""
Local cCA   := ""
Local cPass := ""

cCA   := AllTrim( GetNewPar("XM_CERTCA" ,"", cFilAnt) )
cCert := AllTrim( GetNewPar("XM_CERTCER","", cFilAnt) )
cKey  := AllTrim( GetNewPar("XM_CERTKEY","", cFilAnt) )
cPass := AllTrim( GetNewPar("XM_CERTPSW","", cFilAnt) )

if empty(cCA) .or. empty(cCert) .or. empty(cKey) //.or. Empty(cPass)
	if U_MyAviso("Certificado","N�o foi identificado Certificado para a Filial"+cFilAnt+" Ent "+cIdEnt+". Deseja ?" ,{"Configurar","Continuar"},3) == 1
		lRet := .F.
	endif
endif
if lRet
	if .not. File(cCA)
		if U_MyAviso("Certificado","N�o foi encontrado Arquivo CA "+cCA+" p/ Filial"+cFilAnt+" Ent "+cIdEnt+". Deseja Configurar o Certificado?" ,{"SIM","N�O"},3) == 1
			lRet := .F.
		endif
	endif
endif
if lRet
	if .not. File(cCert)
		if U_MyAviso("Certificado","N�o foi encontrado Arquivo cCert "+cCert+" p/ Filial"+cFilAnt+" Ent "+cIdEnt+". Deseja Configurar o Certificado?" ,{"SIM","N�O"},3) == 1
			lRet := .F.
		endif
	endif
endif
if lRet
	if .not. File(cKey)
		if U_MyAviso("Certificado","N�o foi encontrado Arquivo cKey "+cKey+" p/ Filial"+cFilAnt+" Ent "+cIdEnt+". Deseja Configurar o Certificado?" ,{"SIM","N�O"},3) == 1
			lRet := .F.
		endif
	endif
endif
if lRet
	if Empty(cPass)
		if U_MyAviso("Certificado","Senha do Certificado Vazia p/ Filial"+cFilAnt+" Ent "+cIdEnt+". Deseja Configurar o Certificado?" ,{"SIM","N�O"},3) == 1
			lRet := .F.
		endif
	endif
endif

Return( lRet )
