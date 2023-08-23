#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "Ap5Mail.ch"
#INCLUDE "FWPrintSetup.ch"
#Include "RwMake.Ch"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ  Funcao  บAutor  ณEneo                บ Data ณ  01/09/2017 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Integra็ใo com Cloud                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
//[1] - 0,1,9          //Utiliza Cloud
//[2] - 0-Desabilitado 1-Habilitado
//[3] - N,P,A          //N-S๓ Nuvem, P-Grava ZBZ e Arquivo Normal, A-grava ZBZ e nใo guarda xmlxource
//[4] - Token da N๚vi.
//[5][n] - Dados P/ Consulta
User Function HFCLDINI(lMostra,cLog)

Local aRet  := {"0","0"," ","Token",{}}
Local cInfo := ""
Local cCloud	:=	GetNewPar("XM_CLOUD" ,"0")         //aCombo (0=Desbilitado 1=Habilitado)
Local cClTipo  	:=	GetNewPar("XM_CLTIPO"," ")         //aCombo (Nuvem/Protheus/Ambos)
Local cClToken  :=	GetNewPar("XM_CLTOKEN",Space(256)) //Editar o Bixo da primeira Vez (oWS:ctoken)

Default lMostra := .T.
Default cLog    := ""

Private	nClID   	:=	GetNewPar("XM_CLID",0)             //oWS:oWSDadosDaContaResult:nID
Private nClPlano   	:=	GetNewPar("XM_CLPLANO",0)          //oWS:oWSDadosDaContaResult:nPLANOID
Private nClStPla   	:=	GetNewPar("XM_CLSTID",0)           //oWS:oWSDadosDaContaResult:nSTATUSID
Private nClForma   	:=	GetNewPar("XM_CLFORMA",0)          //oWS:oWSDadosDaContaResult:nFORMAPAGAMENTOID
Private cClArea   	:=	GetNewPar("XM_CLAREA" ,Space(256)) //oWS:oWSDadosDaContaResult:cAREA
Private cClEmail   	:=	GetNewPar("XM_CLEMAIL",Space(256)) //oWS:oWSDadosDaContaResult:cEMAIL
Private cClNome   	:=	GetNewPar("XM_CLNOME",Space(256))  //oWS:oWSDadosDaContaResult:cNOME
Private cClRamal   	:=	GetNewPar("XM_CLRAMAL",Space(256)) //oWS:oWSDadosDaContaResult:cRAMAL
Private cClSenha   	:=	GetNewPar("XM_CLSENHA",Space(256)) //oWS:oWSDadosDaContaResult:cSENHA
Private cClTelFx   	:=	GetNewPar("XM_CLTELFX",Space(256)) //oWS:oWSDadosDaContaResult:cTELEFONEFIXO
Private cClTelMv   	:=	GetNewPar("XM_CLTELMV",Space(256)) //oWS:oWSDadosDaContaResult:cTELEFONEMOVEL

if cCloud == "1"
	aRet := {"1",cCloud,cClTipo,cClToken,{}}  //Vazio, nใo utiliza n๚vi
	if Empty(cClToken)
		cInfo := "Token Vazio"
		if lMostra
			U_MyAviso("TOKEN",cInfo ,{"Ok"},3)
		EndIf
		aRet[1] := "9"
		cLog +=  cInfo+CRLF
		Return( aRet )
	Endif

	IF .NOT. U_HFCLDTKN(cClToken,lMostra,@aRet,.T.)
		aRet[1] := "9"
		cInfo   := "Token Invแlido"
	Endif
Else
	aRet := {"0","0"," ","Token",{}}  //Vazio, nใo utiliza n๚vi
Endif

cLog += cInfo+CRLF

Return aRet


//Token
User Function HFCLDTKN(cClToken,lMostra,aCld,lSalva)
Local lRet  := .T.
Local cInfo := ""
Local oWS

Default cClToken := "9999999"
Default lMostra  := .F.
Default aCld := {"0","0"," ","Token",{}}

oWS:=WSERP():New()
oWS:ctoken := AllTrim(cClToken) //"5060-DDD2-1719"
oWS:INIT()

If oWS:DadosDaConta()
	If oWS:oWSDadosDaContaResult:cToken <> NIL .And. AllTrim(oWS:oWSDadosDaContaResult:cToken) == AllTrim(cClToken)
		lRet   := .T.
//      Private
		nClID   	:=	oWS:oWSDadosDaContaResult:nID
		nClPlano   	:=	oWS:oWSDadosDaContaResult:nPLANOID
		nClStPla   	:=	oWS:oWSDadosDaContaResult:nSTATUSID
		nClForma   	:=	oWS:oWSDadosDaContaResult:nFORMAPAGAMENTOID
		cClArea   	:=	oWS:oWSDadosDaContaResult:cAREA
		cClEmail   	:=	oWS:oWSDadosDaContaResult:cEMAIL
		cClNome   	:=	oWS:oWSDadosDaContaResult:cNOME
		cClRamal   	:=	oWS:oWSDadosDaContaResult:cRAMAL
		cClSenha   	:=	oWS:oWSDadosDaContaResult:cSENHA
		cClTelFx   	:=	oWS:oWSDadosDaContaResult:cTELEFONEFIXO
		cClTelMv   	:=	oWS:oWSDadosDaContaResult:cTELEFONEMOVEL

		aadd(aCld[5], nClID )
		aadd(aCld[5], nClPlano )
		aadd(aCld[5], nClStPla )
		aadd(aCld[5], nClForma )
		aadd(aCld[5], cClArea )
		aadd(aCld[5], cClEmail )
		aadd(aCld[5], cClNome )
		aadd(aCld[5], cClRamal )
		aadd(aCld[5], cClSenha )
		aadd(aCld[5], cClTelFx )
		aadd(aCld[5], cClTelMv )

		If lSalva
			U_HFCLDSVX( aCld[5][1],aCld[5][2],aCld[5][3],aCld[5][4],aCld[5][5],aCld[5][6],aCld[5][7],aCld[5][8],aCld[5][9],;
			           aCld[5][10],aCld[5][11] )
		EndIF

		cInfo := "Token Vแlido para: "+AllTrim(cClNome)

	Else
		cInfo := "Token Invแlido Metodo: DadosDaConta() - WS: WSERP()"
	Endif

Else

	cInfo   := IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))

Endif

If lMostra .And. !lRet
	U_MyAviso("TOKEN",cInfo ,{"Ok"},3)
EndIf

Return( lRet )


User Function HFCLDSVX( nClID,nClPlano,nClStPla,nClForma,cClArea,cClEmail,cClNome,cClRamal,cClSenha,cClTelFx,cClTelMv )

	/********************************/
	If !PutMv("XM_CLID", nClID )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_CLID"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "ID Integra็ใo Cloud"
		MsUnLock()
		PutMv("XM_CLID", nClID )
	EndIf

    /********************************/
	If !PutMv("XM_CLPLANO", nClPlano )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_CLPLANO"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Plano Integra็ใo"
		MsUnLock()
		PutMv("XM_CLPLANO", nClPlano )
	EndIf

    /********************************/
	If !PutMv("XM_CLSTID", nClStPla )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_CLSTID"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Status da Conta"
		MsUnLock()
		PutMv("XM_CLSTID", nClStPla )
	EndIf

    /********************************/
	If !PutMv("XM_CLFORMA", nClForma )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_CLFORMA"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Forma de Pagamento da Conta Cloud"
		MsUnLock()
		PutMv("XM_CLFORMA", nClForma )
	EndIf

    /********************************/
	If !PutMv("XM_CLAREA", cClArea )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_CLAREA"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Area do Resposavel da Conta"
		MsUnLock()
		PutMv("XM_CLAREA", cClArea )
	EndIf

    /********************************/
	If !PutMv("XM_CLEMAIL", cClEmail )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_CLEMAIL"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "E-Mail da Conta Cloud"
		MsUnLock()
		PutMv("XM_CLEMAIL", cClEmail )
	EndIf

    /********************************/
	If !PutMv("XM_CLNOME", cClNome )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_CLNOME"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Nome da Conta Cloud"
		MsUnLock()
		PutMv("XM_CLNOME", cClNome )
	EndIf

    /********************************/
	If !PutMv("XM_CLRAMAL", cClRamal )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_CLRAMAL"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Ramal da Representante da Conta"
		MsUnLock()                                       
		
		PutMv("XM_CLRAMAL", cClRamal )
	EndIf

    /********************************/
	If !PutMv("XM_CLSENHA", cClSenha )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_CLSENHA"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Senha da Conta"
		MsUnLock()
		PutMv("XM_CLSENHA", cClSenha )
	EndIf

    /********************************/
	If !PutMv("XM_CLTELFX", cClTelFx )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_CLTELFX"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Telefone Fixo da Conta"
		MsUnLock()
		PutMv("XM_CLTELFX", cClTelFx )
	EndIf

    /********************************/
	If !PutMv("XM_CLTELMV", cClTelMv )
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial("SX6")
		SX6->X6_VAR     := "XM_CLTELMV"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Telefone Movel do Representante da Conta"
		MsUnLock()
		PutMv("XM_CLTELMV", cClTelMv )
	EndIf

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HFCLDZBZ บAutor  ณEneo                บ Data ณ  07/09/2017 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Mandar ZBZ                                                 บฑฑ
ฑฑบ          ณ receber aGrvZBZ com os campos e valores                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Integra็ใo com Cloud                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function HFCLDZBZ( aGrvZBZ, lMostra, cErro )
//Local xRetInfo , bEval	, bOldError
Local lRet   := .T.
Local nCloId := iif(Len(aHfCloud)>=5, iif(Len(aHfCloud[5]) >= 1, aHfCloud[5][1], 0), 0 )  //Trabalhar meljor depois
Local cCpo   := ""
Local nCpo   := 0
Local nI     := 0
Local nPos   := 0
Local oWS

oWS:=WSERP():New() 
oWS:ctoken := aHfCloud[4]  //Token
oWS:INIT()
oWS:ncontaID := nCloId

oWS:oWSzbz		:= NIL
oWS:oWSzbz		:= ERP_ZBZ990():New()
oWS:oWSzbz:nID	:= 0

//ver uma maneira de fazer um For
//For nI := 1 To Len( aGrvZBZ )
//	cCpo := "oWS:oWSzbz:cZBZ_"+AllTrim(aGrvZBZ[nI][2])+" := "+AllTrim(aGrvZBZ[nI][3]) 
//
//	if WSAdvValue(	oWS:oWSzbz , cObjCpoInfo , cType , xDefault , cNotNILMsg , lAsArray , cAdvType , cAdv2Par , cRecNS )
//		bEval	:= &('{ |x| x:' + cCpo +' } ')
//		bOldError := Errorblock({|e| Break(e) })
//		BEGIN SEQUENCE
//		xRetInfo := eval(bEval , oXml)
//		END SEQUENCE
//		ErrorBlock(bOldError)
//	EndIf
//Next nI

nPos := aScan( aGrvZBZ, {|x| x[2]== "FILIAL" } )
If nPos > 0
	oWS:oWSzbz:cZBZ_FILIAL  := aGrvZBZ[nPos][3]
Else
	oWS:oWSzbz:cZBZ_FILIAL  := xFilial()
Endif
nPos := aScan( aGrvZBZ, {|x| x[2]== "MODELO" } )
If nPos > 0
	oWS:oWSzbz:cZBZ_MODELO  := aGrvZBZ[nPos][3]
Else
	oWS:oWSzbz:cZBZ_MODELO  := ""
Endif
nPos := aScan( aGrvZBZ, {|x| x[2]== "UF" } )
If nPos > 0
	oWS:oWSzbz:cZBZ_UF      := aGrvZBZ[nPos][3]
Else
	oWS:oWSzbz:cZBZ_UF      := ""
Endif
nPos := aScan( aGrvZBZ, {|x| x[2]== "SERIE" } )
If nPos > 0
	oWS:oWSzbz:cZBZ_SERIE   := aGrvZBZ[nPos][3]
Else
	oWS:oWSzbz:cZBZ_SERIE   := ""
Endif
nPos := aScan( aGrvZBZ, {|x| x[2]== "NOTA" } )
If nPos > 0
	oWS:oWSzbz:cZBZ_NOTA    := aGrvZBZ[nPos][3]
Else
	oWS:oWSzbz:cZBZ_NOTA    := ""
Endif
nPos := aScan( aGrvZBZ, {|x| x[2]== "DTNFE" } )
If nPos > 0
	oWS:oWSzbz:cZBZ_DTNFE   := Date2Soap( aGrvZBZ[nPos][3] ) //            AS dateTime  AQUIII ATENCAO, VER a DATA CONVERTIDA
Else
	oWS:oWSzbz:cZBZ_DTNFE   := Date2Soap( dDataBase )
Endif
nPos := aScan( aGrvZBZ, {|x| x[2]== "PROT" } )
If nPos > 0
	oWS:oWSzbz:cZBZ_PROT    := aGrvZBZ[nPos][3]
Else
	oWS:oWSzbz:cZBZ_PROT    := ""
Endif
nPos := aScan( aGrvZBZ, {|x| x[2]== "PRENF" } )
If nPos > 0
	oWS:oWSzbz:cZBZ_PRENF   := aGrvZBZ[nPos][3]
Else
	oWS:oWSzbz:cZBZ_PRENF   := "B"
Endif
nPos := aScan( aGrvZBZ, {|x| x[2]== "CNPJ" } )
If nPos > 0
	oWS:oWSzbz:cZBZ_CNPJ    := aGrvZBZ[nPos][3]
Else
	oWS:oWSzbz:cZBZ_CNPJ    := ""
Endif
nPos := aScan( aGrvZBZ, {|x| x[2]== "FORNEC" } )
If nPos > 0
	oWS:oWSzbz:cZBZ_FORNEC  := aGrvZBZ[nPos][3]
Else
	oWS:oWSzbz:cZBZ_FORNEC  := ""
Endif
nPos := aScan( aGrvZBZ, {|x| x[2]== "CNPJD" } )
If nPos > 0
	oWS:oWSzbz:cZBZ_CNPJD   := aGrvZBZ[nPos][3]
Else
	oWS:oWSzbz:cZBZ_CNPJD   := ""
Endif
nPos := aScan( aGrvZBZ, {|x| x[2]== "CLIENT" } )
If nPos > 0
	oWS:oWSzbz:cZBZ_CLIENT  := aGrvZBZ[nPos][3]
Else
	oWS:oWSzbz:cZBZ_CLIENT  := ""
Endif
nPos := aScan( aGrvZBZ, {|x| x[2]== "CHAVE" } )
If nPos > 0
	oWS:oWSzbz:cZBZ_CHAVE   := aGrvZBZ[nPos][3]
Else
	oWS:oWSzbz:cZBZ_CHAVE   := ""
Endif
nPos := aScan( aGrvZBZ, {|x| x[2]== "XML" } )
If nPos > 0
	oWS:oWSzbz:cZBZ_XML     := aGrvZBZ[nPos][3] //Normal
Else
	oWS:oWSzbz:cZBZ_XML     := Decode64("")
Endif
nPos := aScan( aGrvZBZ, {|x| x[2]== "DTRECB" } )
If nPos > 0
	oWS:oWSzbz:cZBZ_DTRECB  := aGrvZBZ[nPos][3]
Else
	oWS:oWSzbz:cZBZ_DTRECB  := Date2Soap(dDataBase)
Endif
nPos := aScan( aGrvZBZ, {|x| x[2]== "DTHRCS" } )
If nPos > 0
	oWS:oWSzbz:cZBZ_DTHRCS  := aGrvZBZ[nPos][3]
Else
	oWS:oWSzbz:cZBZ_DTHRCS  := ""
Endif
nPos := aScan( aGrvZBZ, {|x| x[2]== "DTHRUC" } )
If nPos > 0
	oWS:oWSzbz:cZBZ_DTHRUC  := aGrvZBZ[nPos][3]
Else
	oWS:oWSzbz:cZBZ_DTHRUC  := ""
endif
nPos := aScan( aGrvZBZ, {|x| x[2]== "CODFOR" } )
If nPos > 0
	oWS:oWSzbz:cZBZ_CODFOR  := aGrvZBZ[nPos][3]
Else
	oWS:oWSzbz:cZBZ_CODFOR  := ""
Endif
nPos := aScan( aGrvZBZ, {|x| x[2]== "LOJFOR" } )
If nPos > 0
	oWS:oWSzbz:cZBZ_LOJFOR  := aGrvZBZ[nPos][3]
Else
	oWS:oWSzbz:cZBZ_LOJFOR  := ""
Endif
nPos := aScan( aGrvZBZ, {|x| x[2]== "STATUS" } )
If nPos > 0
	oWS:oWSzbz:cZBZ_STATUS  := aGrvZBZ[nPos][3]
Else
	oWS:oWSzbz:cZBZ_STATUS  := ""
Endif
nPos := aScan( aGrvZBZ, {|x| x[2]== "OBS" } )
If nPos > 0
	oWS:oWSzbz:cZBZ_OBS     := aGrvZBZ[nPos][3]
Else
	oWS:oWSzbz:cZBZ_OBS     := Decode64("")
Endif
nPos := aScan( aGrvZBZ, {|x| x[2]== "TPEMIS" } )
If nPos > 0
	oWS:oWSzbz:cZBZ_TPEMIS  := aGrvZBZ[nPos][3]
Else
	oWS:oWSzbz:cZBZ_TPEMIS  := ""
Endif
nPos := aScan( aGrvZBZ, {|x| x[2]== "TPAMB" } )
If nPos > 0
	oWS:oWSzbz:cZBZ_TPAMB   := aGrvZBZ[nPos][3]
Else
	oWS:oWSzbz:cZBZ_TPAMB   := "1"
Endif
nPos := aScan( aGrvZBZ, {|x| x[2]== "TPDOC" } )
If nPos > 0
	oWS:oWSzbz:cZBZ_TPDOC   := aGrvZBZ[nPos][3]
Else
	oWS:oWSzbz:cZBZ_TPDOC   := "N"
Endif
nPos := aScan( aGrvZBZ, {|x| x[2]== "FORPAG" } )
If nPos > 0
	oWS:oWSzbz:cZBZ_FORPAG  := aGrvZBZ[nPos][3]
Else
	oWS:oWSzbz:cZBZ_FORPAG  := ""
Endif
nPos := aScan( aGrvZBZ, {|x| x[2]== "TOMA" } )
If nPos > 0
	oWS:oWSzbz:cZBZ_TOMA    := aGrvZBZ[nPos][3]
Else
	oWS:oWSzbz:cZBZ_TOMA    := ""
Endif
nPos := aScan( aGrvZBZ, {|x| x[2]== "DTHCAN" } )
If nPos > 0
	oWS:oWSzbz:cZBZ_DTHCAN  := aGrvZBZ[nPos][3]
Else
	oWS:oWSzbz:cZBZ_DTHCAN  := ""
endif
nPos := aScan( aGrvZBZ, {|x| x[2]== "PROTC" } )
If nPos > 0
	oWS:oWSzbz:cZBZ_PROTC   := aGrvZBZ[nPos][3]
Else
	oWS:oWSzbz:cZBZ_PROTC   := ""
Endif
nPos := aScan( aGrvZBZ, {|x| x[2]== "XMLCAN" } )
If nPos > 0
	oWS:oWSzbz:cZBZ_XMLCAN  := aGrvZBZ[nPos][3]
Else
	oWS:oWSzbz:cZBZ_XMLCAN  := Decode64("")
endif
nPos := aScan( aGrvZBZ, {|x| x[2]== "VERSAO" } )
If nPos > 0
	oWS:oWSzbz:cZBZ_VERSAO  := aGrvZBZ[nPos][3]
Else
	oWS:oWSzbz:cZBZ_VERSAO  := ""
endif
nPos := aScan( aGrvZBZ, {|x| x[2]== "MAIL" } )
If nPos > 0
	oWS:oWSzbz:cZBZ_MAIL    := aGrvZBZ[nPos][3]
Else
	oWS:oWSzbz:cZBZ_MAIL    := ""
endif
nPos := aScan( aGrvZBZ, {|x| x[2]== "DTMAIL" } )
If nPos > 0
	oWS:oWSzbz:cZBZ_DTMAIL  := aGrvZBZ[nPos][3]
Else
	oWS:oWSzbz:cZBZ_DTMAIL  := ""
endif
nPos := aScan( aGrvZBZ, {|x| x[2]== "SERORI" } )
If nPos > 0
	oWS:oWSzbz:cZBZ_SERORI  := aGrvZBZ[nPos][3]
Else
	oWS:oWSzbz:cZBZ_SERORI  := "  "
endif
nPos := aScan( aGrvZBZ, {|x| x[2]== "EXP" } )
If nPos > 0
	oWS:oWSzbz:cZBZ_EXP     := aGrvZBZ[nPos][3]
Else
	oWS:oWSzbz:cZBZ_EXP     := ""
endif
nPos := aScan( aGrvZBZ, {|x| x[2]== "MANIF" } )
If nPos > 0
	oWS:oWSzbz:cZBZ_MANIF   := aGrvZBZ[nPos][3]
Else
	oWS:oWSzbz:cZBZ_MANIF   := "0"
endif
nPos := aScan( aGrvZBZ, {|x| x[2]== "CONDPG" } )
If nPos > 0
	oWS:oWSzbz:cZBZ_CONDPG  := aGrvZBZ[nPos][3]
Else
	oWS:oWSzbz:cZBZ_CONDPG  := ""
endif
nPos := aScan( aGrvZBZ, {|x| x[2]== "TPCTE" } )
If nPos > 0
	oWS:oWSzbz:cZBZ_TPCTE   := aGrvZBZ[nPos][3]
Else
	oWS:oWSzbz:cZBZ_TPCTE   := " "
endif
nPos := aScan( aGrvZBZ, {|x| x[2]== "DOCCTE" } )
If nPos > 0
	oWS:oWSzbz:cZBZ_DOCCTE  := aGrvZBZ[nPos][3]
Else
	oWS:oWSzbz:cZBZ_DOCCTE  := ""
endif
nPos := aScan( aGrvZBZ, {|x| x[2]== "VLLIQ" } )
If nPos > 0
	oWS:oWSzbz:nZBZ_VLLIQ   := aGrvZBZ[nPos][3]
Else
	oWS:oWSzbz:nZBZ_VLLIQ   := 0.00
endif
nPos := aScan( aGrvZBZ, {|x| x[2]== "VLIMP" } )
If nPos > 0
	oWS:oWSzbz:nZBZ_VLIMP   := aGrvZBZ[nPos][3]
Else
	oWS:oWSzbz:nZBZ_VLIMP   := 0.00
endif
nPos := aScan( aGrvZBZ, {|x| x[2]== "VLDESC" } )
If nPos > 0
	oWS:oWSzbz:nZBZ_VLDESC  := aGrvZBZ[nPos][3]
Else
	oWS:oWSzbz:nZBZ_VLDESC  := 0.00
endif
nPos := aScan( aGrvZBZ, {|x| x[2]== "VLBRUT" } )
If nPos > 0
	oWS:oWSzbz:nZBZ_VLBRUT  := aGrvZBZ[nPos][3]
Else
	oWS:oWSzbz:nZBZ_VLBRUT  := 0.00
EndIf
nPos := aScan( aGrvZBZ, {|x| x[2]== "PDF" } )
If nPos > 0
	oWS:oWSzbz:cZBZ_PDF     := aGrvZBZ[nPos][3] //Normal
Else
	oWS:oWSzbz:cZBZ_PDF     := Decode64("")
Endif
nPos := aScan( aGrvZBZ, {|x| x[2]== "DTRECB" } )
nPos := aScan( aGrvZBZ, {|x| x[2]== "D_E_L_E_T_" } )
If nPos > 0
	oWS:oWSzbz:cD_E_L_E_T_  	:= aGrvZBZ[nPos][3]
Else
	oWS:oWSzbz:cD_E_L_E_T_  	:= " "
EndIf
nPos := aScan( aGrvZBZ, {|x| x[2]== "R_E_C_N_O_" } )
If nPos > 0
	oWS:oWSzbz:nR_E_C_N_O_  	:= aGrvZBZ[nPos][3]
Else
	oWS:oWSzbz:nR_E_C_N_O_  	:= 0  //(cAliasZBZ)->RECN
Endif
nPos := aScan( aGrvZBZ, {|x| x[2]== "R_E_C_D_E_L_" } )
If nPos > 0
	oWS:oWSzbz:nR_E_C_D_E_L_ 	:= aGrvZBZ[nPos][3]
Else
	oWS:oWSzbz:nR_E_C_D_E_L_ 	:= 0 //(cAliasZBZ)->R_E_C_D_E_L_
EndIF
nPos := aScan( aGrvZBZ, {|x| x[2]== "EmpresaID" } )
If nPos > 0
	oWS:oWSzbz:nEmpresaID   	:= aGrvZBZ[nPos][3]
Else
	oWS:oWSzbz:nEmpresaID   	:= 0
Endif
nPos := aScan( aGrvZBZ, {|x| x[2]== "DataEntradaWeb" } )
If nPos > 0
	oWS:oWSzbz:cDataEntradaWeb 	:= aGrvZBZ[nPos][3]
Else
	oWS:oWSzbz:cDataEntradaWeb 	:= Date2Soap( ddatabase ) //            AS dateTime  AQUIII ATENCAO, VER a DATA CONVERTIDA
Endif


If oWS:ZBZ990Adciona()
	if Substr(oWS:cZBZ990AdcionaResult,1,1) == "E"
		cErro := Substr(oWS:cZBZ990AdcionaResult,2,len(AllTrim(oWS:cZBZ990AdcionaResult)))
		if lMostra
			Alert( cErro )
		endif
		lRet := .F.
	Else
		lRet := .T.
	Endif
Else
	cErro   := IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
	lRet    := .F.
	if lMostra
		Alert( cErro )
	Endif
EndIf

Return( lRet )



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HFCLDZBE บAutor  ณEneo                บ Data ณ  16/09/2017 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Mandar ZBE                                                 บฑฑ
ฑฑบ          ณ receber aGrvZBE com os campos e valores                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Integra็ใo com Cloud                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function HFCLDZBE( aGrvZBE, lMostra, cErro )
//Local xRetInfo , bEval	, bOldError
Local lRet   := .T.
Local nCloId := aHfCloud[5][1]   //Trabalhar meljor depois
Local cCpo   := ""
Local nCpo   := 0
Local nI     := 0
Local nPos   := 0
Local oWS

oWS:=WSERP():New() 
oWS:ctoken := aHfCloud[4]  //Token
oWS:INIT()
oWS:ncontaID := nCloId

oWS:oWSzbe   := NIL
oWS:oWSzbe   := ERP_ZBE990():New()
oWS:oWSzbe:nID              := 0

nPos := aScan( aGrvZBE, {|x| x[2]== "FILIAL" } )
If nPos > 0
	oWS:oWSzbe:cZBE_FILIAL      := aGrvZBE[nPos][3]
Else
	oWS:oWSzbe:cZBE_FILIAL  	:= xFilial()
Endif

nPos := aScan( aGrvZBE, {|x| x[2]== "CHAVE" } )
If nPos > 0
	oWS:oWSzbe:cZBE_CHAVE       := aGrvZBE[nPos][3]
Else
	oWS:oWSzbe:cZBE_CHAVE       := ""
EndIF
nPos := aScan( aGrvZBE, {|x| x[2]== "TPEVE" } )
If nPos > 0
	oWS:oWSzbe:cZBE_TPEVE       := aGrvZBE[nPos][3]
Else
	oWS:oWSzbe:cZBE_TPEVE       := ""
EndIF

nPos := aScan( aGrvZBE, {|x| x[2]== "SEQEVE" } )
If nPos > 0
	oWS:oWSzbe:cZBE_SEQEVE      := aGrvZBE[nPos][3]
Else
	oWS:oWSzbe:cZBE_SEQEVE      := ""
Endif

nPos := aScan( aGrvZBE, {|x| x[2]== "STATUS" } )
If nPos > 0
	oWS:oWSzbe:cZBE_STATUS      := aGrvZBE[nPos][3]
Else
	oWS:oWSzbe:cZBE_STATUS      := ""
Endif

nPos := aScan( aGrvZBE, {|x| x[2]== "DHAUT" } )
If nPos > 0
	oWS:oWSzbe:cZBE_DHAUT       := aGrvZBE[nPos][3]
Else
	oWS:oWSzbe:cZBE_DHAUT       := dtos(dDataBase)
Endif

nPos := aScan( aGrvZBE, {|x| x[2]== "PROT" } )
If nPos > 0
	oWS:oWSzbe:cZBE_PROT        := aGrvZBE[nPos][3]
Else
	oWS:oWSzbe:cZBE_PROT        := ""
Endif

nPos := aScan( aGrvZBE, {|x| x[2]== "DTRECB" } )
If nPos > 0
	oWS:oWSzbe:cZBE_DTRECB      := aGrvZBE[nPos][3]
Else
	oWS:oWSzbe:cZBE_DTRECB      := dtos(dDataBase)
Endif

nPos := aScan( aGrvZBE, {|x| x[2]== "DESC" } )
If nPos > 0
	oWS:oWSzbe:cZBE_DESC        := aGrvZBE[nPos][3]
Else
	oWS:oWSzbe:cZBE_DESC        := ""
Endif

nPos := aScan( aGrvZBE, {|x| x[2]== "XML" } )
If nPos > 0
	oWS:oWSzbe:cZBE_XML         := aGrvZBE[nPos][3]
Else
	oWS:oWSzbe:cZBE_XML         := Decode64("")
Endif

nPos := aScan( aGrvZBE, {|x| x[2]== "EVENTO" } )
If nPos > 0
	oWS:oWSzbe:cZBE_EVENTO      := aGrvZBE[nPos][3]
Else
	oWS:oWSzbe:cZBE_EVENTO      := Decode64("")
Endif

nPos := aScan( aGrvZBE, {|x| x[2]== "D_E_L_E_T_" } )
If nPos > 0
	oWS:oWSzbe:cD_E_L_E_T_  	:= aGrvZBE[nPos][3]
Else
	oWS:oWSzbe:cD_E_L_E_T_  	:= " "
EndIf
nPos := aScan( aGrvZBE, {|x| x[2]== "R_E_C_N_O_" } )
If nPos > 0
	oWS:oWSzbe:nR_E_C_N_O_  	:= aGrvZBE[nPos][3]
Else
	oWS:oWSzbe:nR_E_C_N_O_  	:= 0  //(cAliasZBE)->RECN
Endif
nPos := aScan( aGrvZBE, {|x| x[2]== "R_E_C_D_E_L_" } )
If nPos > 0
	oWS:oWSzbe:nR_E_C_D_E_L_ 	:= aGrvZBE[nPos][3]
Else
	oWS:oWSzbe:nR_E_C_D_E_L_ 	:= 0 //(cAliasZBE)->R_E_C_D_E_L_
EndIF

nPos := aScan( aGrvZBE, {|x| x[2]== "EmpresaID" } )
If nPos > 0
	oWS:oWSzbe:nEmpresaID   	:= aGrvZBE[nPos][3]
Else
	oWS:oWSzbe:nEmpresaID       := 0
Endif
nPos := aScan( aGrvZBE, {|x| x[2]== "DataEntradaWeb" } )
If nPos > 0
	oWS:oWSzbe:cDataEntradaWeb 	:= aGrvZBE[nPos][3]
Else
	oWS:oWSzbe:cDataEntradaWeb 	:= Date2Soap( ddatabase ) //            AS dateTime  AQUIII ATENCAO, VER a DATA CONVERTIDA
Endif

If oWS:ZBE990Adciona()
	//	Alert( 	)
	if Substr(oWS:cZBE990AdcionaResult,1,1) == "E"
		cErro := Substr(oWS:cZBE990AdcionaResult,2,len(AllTrim(oWS:cZBE990AdcionaResult)))
		if lMostra
			Alert( cErro )
		endif
		lRet := .F.
	Else
		lRet := .T.
	Endif
Else
	cErro   := IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
	lRet    := .F.
	if lMostra
		Alert( cErro )
	Endif
EndIf

Return( lRet )




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HFCLDEnv บAutor  ณEneo                บ Data ณ  07/09/2017 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Mandar Dados da Chave ZBZ e/ou ZBE                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Integra็ใo com Cloud                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
USer Function HFCLDEnv(cTab,nReg,nMod,cTip)
Local aArea   := GetArea()
Local aAreaZBZ:= (xZBZ)->( GetArea() )
Local aAreaZBE:= (xZBE)->( GetArea() )
Local aGrvZBZ := {}
Local aGrvZBE := {}
Local cAliasZB := GetNextAlias()
Local nRegZbz := 0 //(xZBZ)->( Recno() )
Local nRegZbe := 0 //(xZBE)->( Recno() )
Local cChv    := ""
Local cXmlRet := ""
Local cMsgZbe := ""
Local cErro := "", cWarning := ""
Local cQuery

Default cTip := "0"

If cTip $ "01"

	nRegZbz := (xZBZ)->( Recno() )

	DbSelectArea( xZBZ )

	cQuery := " select CONVERT(datetime, "+xZBZ_+"DTNFE, 103) AS DTNFE, "+xZBZ_+"DTRECB as DTRECB, ZBZ.D_E_L_E_T_ as DELET, ZBZ.R_E_C_N_O_ as RECN "
	cQuery += " from "+RetSqlName(xZBZ)+" ZBZ "
	cQuery += " where ZBZ.R_E_C_N_O_ = "+AllTrim( Str(nRegZbz) )

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasZB)

	DbSelectARea( cAliasZB )
	(cAliasZB)->( dbGoTop() )
	Do While .NOT. (cAliasZB)->( Eof() )
	
		DbSelectArea( xZBZ )
		(xZBZ)->( dbgoto( (cAliasZB)->RECN ) )
		aGrvZBZ := {}

		aadd( aGrvZBZ, {xZBZ_,"CHAVE"	, (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE")))   } )
		aadd( aGrvZBZ, {xZBZ_,"FILIAL"	, (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL")))	} )
		aadd( aGrvZBZ, {xZBZ_,"MODELO"	, (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO")))  } )
		aadd( aGrvZBZ, {xZBZ_,"UF"  	, (xZBZ)->(FieldGet(FieldPos(xZBZ_+"UF")))      } )
		aadd( aGrvZBZ, {xZBZ_,"CNPJ"	, (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))) 	} )
		aadd( aGrvZBZ, {xZBZ_,"CNPJD"	, (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJD"))) 	} )    
		aadd( aGrvZBZ, {xZBZ_,"CLIENT"	, (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CLIENT"))) 	} )
		aadd( aGrvZBZ, {xZBZ_,"SERIE"	, (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE")))	} )
		aadd( aGrvZBZ, {xZBZ_,"NOTA"	, (xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA"))) 	} )
		aadd( aGrvZBZ, {xZBZ_,"FORNEC"	, (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FORNEC"))) 	} )
		aadd( aGrvZBZ, {xZBZ_,"DTRECB"	, (cAliasZB)->DTRECB } )
		aadd( aGrvZBZ, {xZBZ_,"DTNFE"	, (cAliasZB)->DTNFE } )
		aadd( aGrvZBZ, {xZBZ_,"XML"		, (xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML")))	  } )
		aadd( aGrvZBZ, {xZBZ_,"PRENF"	, (xZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF"))) } )
		aadd( aGrvZBZ, {xZBZ_,"STATUS"	, (xZBZ)->(FieldGet(FieldPos(xZBZ_+"STATUS"))) } )
		aadd( aGrvZBZ, {xZBZ_,"OBS"		, (xZBZ)->(FieldGet(FieldPos(xZBZ_+"OBS")))    } )
		aadd( aGrvZBZ, {xZBZ_,"CODFOR"	, (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR"))) } )
		aadd( aGrvZBZ, {xZBZ_,"LOJFOR"	, (xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR"))) } )
		aadd( aGrvZBZ, {xZBZ_,"TPDOC"	, (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC"))) } )
		aadd( aGrvZBZ, {xZBZ_,"TPEMIS"	, (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPEMIS"))) } )
		aadd( aGrvZBZ, {xZBZ_,"TPAMB"	, (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPAMB")))  } )
		aadd( aGrvZBZ, {xZBZ_,"TOMA"	, (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TOMA")))   } )
		aadd( aGrvZBZ, {xZBZ_,"DTHRCS"	, (xZBZ)->(FieldGet(FieldPos(xZBZ_+"DTHRCS"))) } )
		aadd( aGrvZBZ, {xZBZ_,"PROT"	, (xZBZ)->(FieldGet(FieldPos(xZBZ_+"PROT")))   } )
		aadd( aGrvZBZ, {xZBZ_,"DTHRUC"	, (xZBZ)->(FieldGet(FieldPos(xZBZ_+"DTHRUC"))) } )
		aadd( aGrvZBZ, {xZBZ_,"SERORI"	, (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERORI"))) } )
		aadd( aGrvZBZ, {xZBZ_,"FORPAG"  , (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FORPAG"))) } )
		aadd( aGrvZBZ, {xZBZ_,"CONDPG"	, (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CONDPG"))) } )
		aadd( aGrvZBZ, {xZBZ_,"VERSAO"	, (xZBZ)->(FieldGet(FieldPos(xZBZ_+"VERSAO"))) } )
		aadd( aGrvZBZ, {xZBZ_,"MAIL"	, (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MAIL")))   } )
		aadd( aGrvZBZ, {xZBZ_,"DTMAIL"	, (xZBZ)->(FieldGet(FieldPos(xZBZ_+"DTMAIL"))) } )
		aadd( aGrvZBZ, {xZBZ_,"MANIF"	, (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MANIF")))  } )
		aadd( aGrvZBZ, {xZBZ_,"TPCTE"   , (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPCTE")))  } )
		aadd( aGrvZBZ, {xZBZ_,"DTHCAN"  , (xZBZ)->(FieldGet(FieldPos(xZBZ_+"DTHCAN"))) } )
		aadd( aGrvZBZ, {xZBZ_,"PROTC"   , (xZBZ)->(FieldGet(FieldPos(xZBZ_+"PROTC")))  } )
		aadd( aGrvZBZ, {xZBZ_,"XMLCAN"  , (xZBZ)->(FieldGet(FieldPos(xZBZ_+"XMLCAN"))) } )
		aadd( aGrvZBZ, {xZBZ_,"EXP"     , (xZBZ)->(FieldGet(FieldPos(xZBZ_+"EXP")))    } )
		aadd( aGrvZBZ, {xZBZ_,"DOCCTE"  , (xZBZ)->(FieldGet(FieldPos(xZBZ_+"DOCCTE"))) } )
		aadd( aGrvZBZ, {xZBZ_,"VLLIQ"   , (xZBZ)->(FieldGet(FieldPos(xZBZ_+"VLLIQ")))  } )
		aadd( aGrvZBZ, {xZBZ_,"VLIMP"   , (xZBZ)->(FieldGet(FieldPos(xZBZ_+"VLIMP")))  } )
		aadd( aGrvZBZ, {xZBZ_,"VLDESC"  , (xZBZ)->(FieldGet(FieldPos(xZBZ_+"VLDESC"))) } )
		aadd( aGrvZBZ, {xZBZ_,"VLBRUT"  , (xZBZ)->(FieldGet(FieldPos(xZBZ_+"VLBRUT"))) } )
		aadd( aGrvZBZ, {xZBZ_,"VCARGA"  , (xZBZ)->(FieldGet(FieldPos(xZBZ_+"VCARGA"))) } )
		aadd( aGrvZBZ, {xZBZ_,"PDF"		, (xZBZ)->(FieldGet(FieldPos(xZBZ_+"PDF")))	   } )
		aadd( aGrvZBZ, {xZBZ_,"D_E_L_E_T_", (cAliasZB)->DELET  } )
		aadd( aGrvZBZ, {xZBZ_,"R_E_C_N_O_", (cAliasZB)->RECN   } )
	//	oWS:oWSzbz:nR_E_C_D_E_L_ := 0 //(cAliasZB)->R_E_C_D_E_L_
	//	oWS:oWSzbz:nEmpresaID    := 0
		aadd( aGrvZBZ, {xZBZ_,"DataEntradaWeb", (cAliasZB)->DTNFE } )
	
		if ! U_HFCLDZBZ( aGrvZBZ, .T., @cErro )
			RecLock( xZBZ, .F. )
			( xZBZ )->(FieldPut(FieldPos(xZBZ_+"EXP")	, "Z" ))
			MsUnLock()
		Else
			RecLock( xZBZ, .F. )
			( xZBZ )->(FieldPut(FieldPos(xZBZ_+"EXP")	, "E" ))
			MsUnLock()
			if cTip $ "0"
				U_MyAviso("Cloud","Registro "+xZBZ+" Exportado" ,{"Ok"},3)
			Endif
		endif

		DbSelectArea( cAliasZB )
		(cAliasZB)->( dbSkip() )

	EndDo

	DbSelectArea( cAliasZB )
	dbCloseArea()

	DbSelectArea( xZBZ )
	(xZBZ)->( dbgoto( nRegZbz ) )
	cChv    := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE")))

EndIf

if cTip $ "02"

	nRegZbe := (xZBE)->( Recno() )
	DbSelectArea( xZBE )

	cQuery := " select CONVERT(datetime, "+xZBE_+"DHAUT, 103) AS DHAUT, "+xZBE_+"DTRECB as DTRECB, ZBE.D_E_L_E_T_ as DELET, ZBE.R_E_C_N_O_ as RECN "
	cQuery += " from "+RetSqlName(xZBE)+" ZBE "
	
	If cTip $ "0" .And. !Empty( cChv )
		cQuery += " where ZBE.D_E_L_E_T_ = '' "
		cQuery += " AND ZBE."+xZBE_+"CHAVE = '"+AllTrim(cChv)+"'"
	Else
		cQuery += " where ZBE.R_E_C_N_O_ = "+AllTrim( Str(nRegZbe) )
	Endif

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasZB)

	DbSelectARea( cAliasZB )
	(cAliasZB)->( dbGoTop() )
	Do While .NOT. (cAliasZB)->( Eof() )
	
		DbSelectArea( xZBE )
		(xZBE)->( dbgoto( (cAliasZB)->RECN ) )
		aGrvZBE := {}

		aadd( aGrvZBE, {xZBE_,"FILIAL"  , (xZBE)->(FieldGet(FieldPos(xZBE_+"FILIAL")))  } )
		aadd( aGrvZBE, {xZBE_,"CHAVE"	, (xZBE)->(FieldGet(FieldPos(xZBE_+"CHAVE")))   } )
		aadd( aGrvZBE, {xZBE_,"TPEVE"	, (xZBE)->(FieldGet(FieldPos(xZBE_+"TPEVE")))	} )
		aadd( aGrvZBE, {xZBE_,"SEQEVE"	, (xZBE)->(FieldGet(FieldPos(xZBE_+"SEQEVE")))  } )
		aadd( aGrvZBE, {xZBE_,"STATUS"	, (xZBE)->(FieldGet(FieldPos(xZBE_+"STATUS")))  } )
		aadd( aGrvZBE, {xZBE_,"DHAUT"   , Dtos( (xZBE)->(FieldGet(FieldPos(xZBE_+"DHAUT"))) ) } )  //(cAliasZB)->DHAUT
		aadd( aGrvZBE, {xZBE_,"PROT"	, (xZBE)->(FieldGet(FieldPos(xZBE_+"PROT")))  	} )
		aadd( aGrvZBE, {xZBE_,"DTRECB"  , (cAliasZB)->DTRECB  							} )
		aadd( aGrvZBE, {xZBE_,"DESC"	, (xZBE)->(FieldGet(FieldPos(xZBE_+"DESC")))  	} )
		aadd( aGrvZBE, {xZBE_,"XML"		, (xZBE)->(FieldGet(FieldPos(xZBE_+"XML")))  	} )
		aadd( aGrvZBE, {xZBE_,"EVENTO"	, (xZBE)->(FieldGet(FieldPos(xZBE_+"EVENTO")))  } )
		aadd( aGrvZBE, {xZBE_,"D_E_L_E_T_", (cAliasZB)->DELET  } )
		aadd( aGrvZBE, {xZBE_,"R_E_C_N_O_", (cAliasZB)->RECN   } )
		//	oWS:oWSzbz:nR_E_C_D_E_L_ := 0 //(cAliasZB)->R_E_C_D_E_L_
		//	oWS:oWSzbz:nEmpresaID    := 0
		aadd( aGrvZBE, {xZBE_,"DataEntradaWeb", (cAliasZB)->DHAUT 						} )

		if ! U_HFCLDZBE( aGrvZBE, .T., @cErro )
			cMsgZbe += "Registro "+xZBE+" "+(xZBE)->(FieldGet(FieldPos(xZBE_+"TPEVE")))+" "+(xZBE)->(FieldGet(FieldPos(xZBE_+"SEQEVE")))+" NรO Exportado"+CRLF
		Else
			cMsgZbe += "Registro "+xZBE+" "+(xZBE)->(FieldGet(FieldPos(xZBE_+"TPEVE")))+" "+(xZBE)->(FieldGet(FieldPos(xZBE_+"SEQEVE")))+" Exportado"+CRLF
		endif

		DbSelectArea( cAliasZB )
		(cAliasZB)->( dbSkip() )

	EndDo

	if cTip $ "0" .And. !Empty(cMsgZbe)
		U_MyAviso("Cloud",cMsgZbe ,{"Ok"},3)
	Endif
	
	DbSelectArea( cAliasZB )
	dbCloseArea()

	DbSelectArea( xZBE )
	(xZBE)->( dbgoto( nRegZbe ) )

	DbSelectArea( xZBZ )
	
EndIF

(xZBE)->(RestArea(aAreaZBE))
(xZBZ)->(RestArea(aAreaZBZ))

RestArea(aArea)

Return(NIL)


Static Function __Dummy(lRecursa) //warning W0010 Static Function <?> never called
   
    lRecursa := .F.
    U_HFCLDINI()
    U_HFCLDTKN()
    U_HFCLDSVX()
    U_HFCLDZBZ()
    U_HFCLDZBE()
    U_HFCLDEnv()
    
    IF (lRecursa)
        __Dummy(.F.)
	EndIF
	
Return(lRecursa)
