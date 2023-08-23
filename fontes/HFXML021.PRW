#include "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "XMLXFUN.CH" 
#INCLUDE "FILEIO.CH"
#INCLUDE "rwmake.ch"
//#INCLUDE "topconn.ch"
//#INCLUDE "tbiconn.ch"

Static lUnix  := IsSrvUnix()
Static cBarra := Iif(lUnix,"/","\")

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HFXML021  ºAutor  ³Eneovaldo Roveri Jr º Data ³    /  /     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotinas Complementares HFXML02                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ HFXML02                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ HFXMLMCT ºAutor  ³Eneovaldo Roveri Jr º Data ³  31/01/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gerar documento de entrada com Multiplos CTE               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ HFXML02                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
//-------------------------------------------------------------------------//
//Alterações realizadas:
//08/02/2020 - Flávia Rocha - Tela para informar TES - Politec
//                            Mostrar tela apenas uma vez, para multiplos 
//                            CTE / NFE.
//--------------------------------------------------------------------------//
//Alterações realizadas:
//FR - 16/03/2020 - Projeto Politec - criação dos campos: ZBT_ITEM, ZBT_NOTA, 
//                  ZBT_SERIE, ZBT_CLIFOR, ZBT_LOJA, ZBT_TIPOFO
//                  Para gravação das notas de origem que compõem 
//                  o Cte por linha na ZBT e SD1.
//----------------------------------------------------------------------------//
//Alterações realizadas:
//NA - 02/03/2021 - Projeto Nordson - criação de parâmetro para tela F12 
//                  XM_CENTRO - este parâmetro será utilizado pela rotina Múltiplos
//                  CTE - rege se a rotina buscará o centro de custo da NF Saída (SD2)
//                  Ou do cadastro de produto (SB1).
//----------------------------------------------------------------------------//
//FR - 17/03/2021 - Projeto MaxiRubber - Criação de novo filtro para a tela
//                  Multiplos Cte, trazer também xmls que já tem pré-nota
//                  gerada, já pronto para classificar também.
//                  O filtro antigo trazia apenas os xmls com status = 'B'
//                  O novo filtro irá trazer também os xmls com status = 'S'
//----------------------------------------------------------------------------//
//FR - 29/05/2023 - CHAMADO IVOCLAR 14933- RATEIO CTE na Rotina Multiplos CTE
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function HFXMLMCT()

Local aArea   := GetArea()
Local lRet    := .T.
Local lOk     := .T.
Local cDir    := AllTrim(SuperGetMv("MV_X_PATHX"))
Local cDirMCT := AllTrim(cDir+cBarra+"MCTE"+cBarra)
Local cTpMCte := GetNewPar("XM_TPMCTE","1")
Local nQual   := 0 
Local oProcess  

Private cArqOri  := Space( 200 )
Private cPstOri  := ""
Private cPstCpl  := "" 
Private lDirCnpj := AllTrim(GetNewPar("XM_DIRCNPJ","N")) == "S"                     
Private lDirFil  := AllTrim(GetNewPar("XM_DIRFIL" ,"N")) == "S" 
Private lDirMod  := AllTrim(GetNewPar("XM_DIRMOD" ,"N")) == "S"                     
Private cDirDest := AllTrim(cDir+cBarra+"Importados"+cBarra)                     
Private aFrete   := {"C=CIF","F=FOB","T=Por Conta Terceiros","R=Por Conta Remetente","D=Por Conta Destinatário","S=Sem Frete"}
Private cModFrete:= " "
Private cTipoDoc := " "
Private cTpCompl := " "
Private aCombo1x := {	" = ",;
						"1=Preco",;	
						"2=Quantidade",;	
						"3=Frete"}
Private aCombo1  := {	"N=Normal",;	
						"C=Compl. Preco/Frete"}
Private cTpCentro  := GetNewPar("XM_CENTRO","1")

cDirMCT := StrTRan( cDirMCT, cBarra+cBarra, cBarra )
cDirMCT := StrTRan( cDirMCT, cBarra+cBarra, cBarra )

If !ExistDir(cDirMCT)

	Makedir(cDirMCT)
	
EndIf

if cTpMCte = "3"
	nQual := U_MYAVISO("Atenção","Multiplo CTe "+CRLF+"1-Fornecedor. Do Fornecedor do CTe Selecionado Atual"+CRLF+"2-Da Pasta. De uma Pasta Escolhida.",{"1-Fornec","2-Da Pasta"},3)
else
	nQual := Val(cTpMCte)	
endif

If nQual == 1
	If Empty( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR"))) ) .Or. Empty( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR"))) )		
		lOk:= .F.
		MsgStop("Este XML não possui fornecedor associado. Clique em Ações Relacionadas / Funções XML / Alterar e Associe o Fornecedor de Acordo com o CNPJ. Caso não Tenha Fornecedor Cadastrado com o CNPJ, faça-o no Cadastro de Fornecedor.")	
	ElseIf (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO"))) <> "57"		
		lOk:= .F.		
		U_MyAviso("Aviso","Este XML não é modelo 57 (CT-e). Clique em gera pré-nota.",{"OK"},2)	
	EndIf	
ElseIf nQual == 2
	Processa( {|| lOK := EscolhePst(cDirMCT)}, "Aguarde...", "Escolher Pasta ...",.F.)
Else
	lOK := .F.	
EndIf

If lOk

	@ 001,001 To 200,560 Dialog oSCR1 Title "Indique Dados do Frete"
	@ 010,010 SAY "Tipo da Nota?:" Of oSCR1 PIXEL SIZE 48 ,9 COLOR CLR_HBLUE,oSCR1:nClrPane
	@ 010,060 COMBOBOX oTipo VAR cTipoDoc ITEMS aCombo1 SIZE 70,10 PIXEL OF oSCR1
	@ 010,150 SAY "Tipo Complemento?:" Of oSCR1 PIXEL SIZE 48 ,9 COLOR CLR_HBLUE,oSCR1:nClrPane
	@ 010,210 COMBOBOX oTpCompl VAR cTpCompl ITEMS aCombo1x SIZE 70,10 PIXEL OF oSCR1
	@ 040,010 SAY "Tipo de Frete?:" Of oSCR1 PIXEL SIZE 48 ,9 COLOR CLR_HBLUE,oSCR1:nClrPane
	@ 040,060 COMBOBOX oModFrete VAR cModFrete ITEMS aFrete SIZE 100,10 PIXEL OF oSCR1
	@ 070,010 Button "&Ok" Size 030,012 Pixel Action Close(oSCR1)
	Activate Dialog oSCR1 Centered
	
	if empty(cModFrete) .or. empty(cTipoDoc)	
		lOk := .F.		
	endif
		
endif

If lOk
	If nQual == 1	
		Processa( {|| XMLMULTCTE(nQual) }, "Aguarde...", "Gerando a Nota Com Multiplos CTe ...",.F.)	
	ElseIf nQual == 2	
		//Processa( {|| XMLLEPST() }, "Aguarde...", "Lendo Pasta "+AllTrim(cArqOri)+" CTe ...",.F.)
		oProcess := MsNewProcess():New({| lEnd | lOk := XMLLEPST( @lEnd, oProcess, .F., "", 0)},"Aguarde. Verificando XMLs...","Lendo Pasta "+AllTrim(cArqOri)+" CTe ...",.T.)
		oProcess:Activate()
		
		if lOk		
			Processa( {|| XMLMULTCTE(nQual) }, "Aguarde...", "Gerando a Nota Com Multiplos CTe ...",.F.)		
		endif		
	EndIf	
EndIf

RestArea(aArea)

Return(lRet)


Static Function EscolhePst(cDirMCT)

Local lRet := .T.
Local nL   := 0
Local cL   := ""
Local oSCR1
Local nI   := 0

@ 001,001 To 280,500 Dialog oSCR1 Title "Selecione a Pasta Desejada"

@ 040,010 Say "Digite o caminho e nome do arquivo de origem:" Pixel
@ 055,010 MsGet cArqOri Picture "@!" Size 227,010 Pixel

@ 055,240 Button "?" SIZE 005,012 PIXEL ACTION cArqOri := ABREARQ(cDirMCT)

@ 090,160 Button "&Cancelar" Size 030,012 Pixel Action (lRet := .F., Close(oSCR1))
@ 090,207 Button "&Ok"       Size 030,012 Pixel Action (lRet := .T., Close(oSCR1))

Activate Dialog oSCR1 Centered

cArqOri := UPPER( AllTrim( cArqOri ) )
//cPstOri := UPPER( substr(cArqOri,RAT(cBarra,Substr(cArqOri,1,len(cArqOri)-1)),len(cArqOri)) )
cPstOri := ""
cL      := ""

nTotLen := Len(cArqOri)
For nL := 1 To nTotLen

	cL := Substr( cArqOri, nL, 1 )
	
	If cL == "/" .or.cL == "\"	
		cL := ""		
		if nL < Len(cArqOri)		
			cPstOri := ""			
		endif		
	Else	
		cPstOri += cL		
	EndIf
	
Next nL

cPstOri := cBarra+cPstOri+cBarra
cPstCpl := cDirMCT + cPstOri 
cPstCpl := StrTRan( cPstCpl, cBarra+cBarra, cBarra )
cPstCpl := StrTRan( cPstCpl, cBarra+cBarra, cBarra )

if U_MYAVISO("Atenção","Será criado a Pasta "+cPstCpl+CRLF+"Serão copiados os arquivos para esta pasta"+CRLF+"Continuar?",{"1-SIM","2-NÃO"},3) <> 1	
	lRet := .F.	
Else
	If !ExistDir(cPstCpl)	
		Makedir(cPstCpl)		
	EndIf

	aFiles	:=	Directory(cArqOri+"*.XML","D")
	
	nTotLen := Len(aFiles)
	For nI := 1 To nTotLen
	
		IncProc("Copiando "+aFiles[nI][1])
		__CopyFile( cArqOri+aFiles[nI][1], cPstCpl+aFiles[nI][1] )
		
		If File(cPstCpl+aFiles[nI][1])		
			FErase(cArqOri+aFiles[nI][1])			
		Else		
			U_MYAVISO("Atenção","Nao foi possivel copiar o arquivo "+cArqOri+aFiles[nI][1]+CRLF+"Será interrompida, tente novamente.",{"OK"},3)
			lRet := .F.			
		EndIf
		
	Next nI
	
endif

Return( lRet )


Static Function AbreArq(cDirMCT)

Local cTipo
Local cDir     := AllTrim(SuperGetMv("MV_X_PATHX"))
Local cPathx

cTipo	:= "Todos Arquivos        | *.*    | "

If !ExistDir(cDir)
	Makedir(cDir)	
EndIf

If !ExistDir(cDirMCT)
	Makedir(cDirMCT)	
EndIf

cPathx  := AllTrim(UPPER(cGetFile("*.*","Selecione a pasta",,"C:"+cBarra,.T.,nOR( GETF_LOCALHARD, GETF_RETDIRECTORY ),.F.,)))  //GETF_RETDIRECTORY GETF_NOCHANGEDIR
//cDirMCT
//if UPPER(AllTrim(cDirMCT)) <> Upper(Substr(cPathx,1,Len(AllTrim(cDirMCT)))) //.or. UPPER(AllTrim(cDirMCT)) == UPPER(AllTrim(cPathx))
	//U_MyAviso("Atenção","Pasta Selecionada deve estar dentro da pasta "+AllTrim(cDirMCT),{"Continuar"})
	//cPathx := Substr(cDirMCT+Space(201),1,201)
//endif

Return(cPathx)


Static Function XMLLEPST(lEnd, oProcess, lAuto, cLogProc, nCount)

Local aArea     := GetArea()
Local lRet      := .T.
Local nMov      := 0
Local nI        := 0
Local nX        := 0
Local cNewKey   := ""
Local cNewArq   := ""
Local cError    := ""
Local aMonta    := {}
Local aErr      := {}
Local cDirMCte  := ""
Local nOrd

DbSelectArea( xZBZ )
nOrd := (xZBZ)->(IndexOrd())
(xZBZ)->( DbSetOrder( 3 ) )

oProcess:IncRegua1("Processando Xml...")
oProcess:IncRegua2("Entidade : - Status Sefaz Ok...")                        

aFiles	:=	Directory(cPstCpl+"*.XML","D")

oProcess:SetRegua1(0)
oProcess:SetRegua2(Len(aFiles))

nTotLen := Len(aFiles)
For nI := 1 To nTotLen

	oProcess:IncRegua2(aFiles[nI][1])
	nMov := 0
	
	For nX := 1 To 4	
		nMov := MoveXml(lAuto, aFiles[nI][1], cError, cLogProc, cPstCpl)
		
		if nMov >= 0		
			Exit			
		endif		
	Next nX
	
	If nMov = -1		
		//U_MyAviso("Erro","Não Foi possível copiar o arquivo "+AllTrim(aFiles[nI][1])+". Verifique os arquivos da pasta e Refaça Operação.",{"Voltar"})
		//lRet := .F.
		//Exit
		
	Elseif nMov == 0 	
		U_HFSLVXML(aFiles[nI,1], lAuto,@lEnd,oProcess,@cLogProc,@nCount, "1", @cNewKey, @cNewArq )  //Rotina de importação para ZBZ
	Elseif nMov == 1 //Não é XML	
		Loop		
	Endif

	DbSelectArea( xZBZ )
	(xZBZ)->( DbSetOrder( 3 ) )
	If (xZBZ)->( dbSeek( cNewKey ) )
	
		RecLock( xZBZ, .F. )
		(xZBZ)->(FieldPut(FieldPos(xZBZ_+"DIRMCT"), cPstOri))
		(xZBZ)->(MsUnLock())
		
		If lDirMod		
			cDirMCte := cDirDest + "CTe" + cBarra
			cDirMCte := StrTRan( cDirMCte, cBarra+cBarra+cBarra	, cBarra )
			cDirMCte := StrTRan( cDirMCte, cBarra+cBarra		, cBarra )
			
			If !ExistDir(cDirMCte)			
				Makedir(cDirMCte)				
			EndIf 			
		Endif
		
		If lDirFil
		
			cDirMCte := cDirMCte + (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))) + cBarra
			cDirMCte := StrTRan( cDirMCte, cBarra+cBarra+cBarra	, cBarra )
			cDirMCte := StrTRan( cDirMCte, cBarra+cBarra		, cBarra )
			
			If !ExistDir(cDirMCte)			
				Makedir(cDirMCte)				
			EndIf 
			
		Endif 
		
		If lDirCnpj
		
			cDirMCte := cDirMCte + Substr(cNewKey,7,14) + cBarra
			cDirMCte := StrTRan( cDirMCte, cBarra+cBarra+cBarra	, cBarra )
			cDirMCte := StrTRan( cDirMCte, cBarra+cBarra		, cBarra )
			
			If !ExistDir(cDirMCte)			
				Makedir(cDirMCte)				
			EndIf 
			
		Endif
		
		cDirMCte := cDirMCte + cPstOri + cBarra
		cDirMCte := StrTRan( cDirMCte, cBarra+cBarra+cBarra	, cBarra )
		cDirMCte := StrTRan( cDirMCte, cBarra+cBarra		, cBarra )
		
		If !ExistDir(cDirMCte)		
			Makedir(cDirMCte)			
		EndIf 
		
		aadd( aMonta, {cNewKey, cPstCpl+aFiles[nI][1], cDirMCte+cNewArq } )
		//nStatus1 := fRename( cArqOri+aFiles[nI][1], cArqOri+cNewArq )		
	Else	
		aadd( aErr, {cNewKey, cPstCpl+aFiles[nI][1], cPstCpl+cNewArq, nMov } )
		//errro - Não conseguiu importar		
	EndIf
	
Next nI

nTotLen := Len(aMonta)
For nI := 1 To nTotLen

	lCopyFile:=__CopyFile( aMonta[nI][2], aMonta[nI][3] )	
	if lCopyFile	
		FErase(aMonta[nI][2])		
		lRet := .T.		
	else	
		//Alert("Não "+aMonta[nI][2])		
	endif	
Next nI

(xZBZ)->( DbSetOrder( nOrd ) )

RestArea(aArea)

Return( lRet )


//Copiar XML para xmlsource, para importar para ZBZ se caso precisar.
Static Function MoveXml(lAuto,cFilename, cError, cLogProc, acPath)

Local cPathXml  := cBarra+AllTrim(SuperGetMv("MV_X_PATHX"))+cBarra            
Local nRet      := 0
//Local nHandle   := 0
//Local cIni      := ""
//Local nPos      := 0
Default cLogProc:= ""

cPathXml := StrTRan( cPathXml, cBarra+cBarra, cBarra )
cPathXml := StrTRan( cPathXml, cBarra+cBarra, cBarra )

If Right(Upper(cFilename),3) $ "XML"

	__CopyFile( acPath+cFilename, cPathXml+cFilename )
	
	If File(cPathXml+cFilename)	
    	cLogProc+= Time()+"-"+"Arquivo "+cPathXml+cFilename + " criado com sucesso."+CRLF
		nRet := 0		
	Else	
    	cLogProc+= Time()+"-"+"Arquivo "+cPathXml+cFilename + " não foi possivel copiar."+CRLF
    	nRet := -1    	
	EndIf
	
Else
	nRet := 1	
EndIf

Return(nRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³XMLMULTCTEºAutor  ³Eneovaldo Roveri Jr º Data ³  04/02/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gerar documento de entrada com Multiplos CTE               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ HFXML02                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function XMLMULTCTE(nQual)

Local aArea     := GetArea()
Local lRet      := .F.
Local lFor      := .T.
Local lRemove   := .F.
Local cPrNf     := ""
Local cAliasZBZ := GetNextAlias()
Local lTMP      := .F.

Private oTempTable
Private cGetAlias := "TMPHF"
Private cArq      := ""
Private oFont01   := TFont():New("Arial",07,14,,.T.,,,,.T.,.F.)
Private cCodFor   := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR")))
Private cLojFor   := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR")))
Private cCnpjFor  := PADR((xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))),14)
Private lSharedA2 := U_IsShared("SA2")
Private cFilSeek  := "" //Iif(lSharedA2,xFilial("SA2"),(cAliasZBZ)->&(xZBZ_+"FILIAL") )
Private cMsg      := ""
Private cTabela   := ""
Private cWhere    := ""
Private cOrder    := ""
Private cCampos   := ""
Private lAglCTE	  := ( GetNewPar('XM_AGLMCTE') == 'S' ) //Parametro se aglutina multiplos CTE/NFE ou nao //FR - 17/03/2021 - MaxiRubber

//-------------------
//Criação do objeto
//-------------------
oTempTable := FWTemporaryTable():New( cGetAlias )

lTMP := CriaTMP()

If !lTMP
   U_MyAviso("Erro","Não foi possível criar o Arquivo Temporário."+CRLF+;
	"Verifique suas permissões e tente novamente.",{"OK"},1)	
	RestArea(aArea)	
	Return(.F.)	
Endif

//If Select("TMPHF") > 0

//	TMPHF->( dbCloseArea() )
	
//EndIf

/*dbUseArea(.T.,, cArq,"TMPHF", .F., .F.) //exclusivo
IndRegua("TMPHF",cArq+"A","NOTA+SERIE" )
IndRegua("TMPHF",cArq+"B","CHAVE" )
dbClearIndex()
dbSetIndex( cArq+"A" + OrdBagExt() )//ordem 1
dbSetIndex( cArq+"B" + OrdBagExt() )//ordem 2
dbSetOrder( 1 )*/

cTabela := "%"+RetSqlName(xZBZ)+"%"

if nQual = 1

	cWhere  := "%(   ZBZ."+xZBZ_+"FILIAL = '"+xFilial( xZBZ )+"' "
	cWhere  += " AND ZBZ."+xZBZ_+"MODELO = '57' "
	cWhere  += " AND ZBZ."+xZBZ_+"STATUS = '1' "
	//--------------------------------------------------------------------------------------------//
	//FR - 17/03/2021 - Projeto MaxiRubber
	//Adição de novo filtro para a tela Multiplos Cte (além do status B, acrescentar o status S),
	//adicionar os xmls que já tem pré-nota gerada e estão prontos para classificação
	//Exceto se o parâmetro de aglutinar (XM_AGLMCTE) estiver ativado, conforme explicação abaixo:
	//--------------------------------------------------------------------------------------------//
		
	//--------------------------------------------------------------------------------------------//
	//Seleciona com filtro B somente, quando o parâmetro de Aglutinar (XM_AGLMCTE) estiver ativo,
	//porque não terá como gerar um docto único (aglutinado) se a query retornar 
	//dois tipos de status, a pré nota aglutinada só pode ser gerada para status = B 
	//--------------------------------------------------------------------------------------------//
	If lAglCTE
		cWhere  += " AND ZBZ."+xZBZ_+"PRENF  = 'B' "   		//seleciona somente status = B (importado)													
	Else		
		cWhere  += " AND ZBZ."+xZBZ_+"PRENF IN ('B','S')"	//seleciona status B e S (importado e pré-nota a classificar)
	Endif
	//FR - 17/03
	
	cWhere  += " AND ZBZ."+xZBZ_+"CODFOR = '"+cCodFor+"' " 
	cWhere  += " AND ZBZ."+xZBZ_+"LOJFOR = '"+cLojFor+"' )%" 	
Else
	cWhere  := "%(   ZBZ."+xZBZ_+"MODELO = '57' " + CRLF
	cWhere  += " AND ZBZ."+xZBZ_+"DIRMCT = '"+cPstOri+"' )%" 	
Endif

cCampos	:= "%R_E_C_N_O_% "

cOrder := "%"+xZBZ_+"FILIAL,"+xZBZ_+"NOTA%"   //FR - 17/03/2021

BeginSql Alias cAliasZBZ
	
	SELECT	ZBZ.R_E_C_N_O_
			FROM %Exp:cTabela% ZBZ
			WHERE ZBZ.%notdel%
    		AND %Exp:cWhere% 
    		ORDER BY %Exp:cOrder%			//FR - 17/03/2021
    EndSql
//    		ORDER BY %Exp:cOrder%

DbSelectArea(cAliasZBZ)
(cAliasZBZ)->( dbGoTop() )

While !(cAliasZBZ)->(Eof())

	DbSelectArea( xZBZ )
	(xZBZ)->( dbGoto( (cAliasZBZ)->R_E_C_N_O_ ) )
	
//	if U_HFSTXMUN( cFilZbz, cNotaZbz, cSerieZbz, cCodFor+loja, cTipoNf, cModZbz, cDocCteZbz, nRecZbz ) == "B"	
	
	//FR - 17/03/2021 - atribuí à variáveis antes de passar à função pois o campo TPDOC apesar de ter conteúdo estava indo "em branco"
	xFil 	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL")))
	xNF  	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA")))
	xSer 	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE")))
	xForLoj	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR")))+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR")))
	xTpdoc	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC")))
	xModel	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO")))
	xDoccte	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"DOCCTE")))
	xRecno	:= (xZBZ)->(Recno())
	
	
	/* 
	cPrNf := U_HFSTXMUN( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))),;
	               (xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA"))),;
	               (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE"))),;
	               (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR")))+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR"))) ,;
	               (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC"))),;
	               (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO"))),;
	               (xZBZ)->(FieldGet(FieldPos(xZBZ_+"DOCCTE"))),;
	               (xZBZ)->(Recno()) ) 
	*/
	
	//FR - 17/03/2021 - Aqui procura se já existe pré-nota ou nota, para atualizar o status:
	cPrNf := U_HFSTXMUN( xFil, xNF, xSer, xForLoj, xTpdoc, xModel, xDoccte, xRecno )  
	
	//cPrNf := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF")))     //somente para teste
	              
	//if cPrNf == "B" .OR. (nQual = 2 .And. cPrNf $ "B,N,S"  )
	If cPrNf $ "B/S" .OR. (nQual = 2 .And. cPrNf $ "B,N,S"  )     //FR - 17/03/2021 - MaxiRubber
	
		lRet := .T.
		
		if Empty( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR"))) )
		
			cFilSeek := Iif(lSharedA2,xFilial("SA2"),(xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))) )
			DbSelectArea( "SA2" )
			DbSetORder( 3 )
			
			if SA2->( DbSeek( cFilSeek + (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))) ) ) .And. SA2->A2_MSBLQL != "1"
				
				DbSelectArea( xZBZ )
				RecLock( xZBZ, .F. )
				
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CODFOR"), SA2->A2_COD ))
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"LOJFOR"), SA2->A2_LOJA ))
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"FORNEC"), SA2->A2_NOME ))
				(xZBZ)->( MsUnLOck() )				
			else			
				DbSelectArea( xZBZ )
				lFor := .F.
				cMsg += "Fornecedor sem cadastro. CNPJ "+PADR((xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))),14)+CRLF
				Exit				
			endif
			
		else
		
			cFilSeek := Iif(lSharedA2,xFilial("SA2"),(xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))) )
			DbSelectArea( "SA2" )
			DbSetORder( 1 )
			
			If .NOT. SA2->( dbSeek( cFilSeek +  (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR"))) + (xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR"))) ) )
				
				DbSetORder( 3 )
				if SA2->( dbSeek( cFilSeek + (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))) ) ) .And. SA2->A2_MSBLQL != "1"
					
					DbSelectArea( xZBZ )
					RecLock( xZBZ, .F. )
					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CODFOR"), SA2->A2_COD ))
					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"LOJFOR"), SA2->A2_LOJA ))
					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"FORNEC"), SA2->A2_NOME ))
					(xZBZ)->( MsUnLOck() )					
				else				
					DbSelectArea( xZBZ )
					lFor := .F.
					cMsg += "Fornecedor não encontrado COD "+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR"))) + (xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR")))+CRLF
					Exit					
				Endif				
			Endif	
			
		endif
		
		DbSelectArea( "TMPHF" )
		RecLock( "TMPHF", .T. )		
		
		TMPHF->FILIAL := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL")))
		TMPHF->NOTA   := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA")))
		TMPHF->SERIE  := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE")))
		TMPHF->DTNFE  := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"DTNFE")))
		TMPHF->PRENF  := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF")))
		TMPHF->CNPJ   := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ")))
		TMPHF->FORNEC := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FORNEC")))
		TMPHF->CHAVE  := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE")))
		TMPHF->CODFOR := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR")))
		TMPHF->LOJFOR := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR")))
		TMPHF->TPDOC  := cTipoDoc
		TMPHF->TPCOMPL:= iif(cTipoDoc = "N", " ", cTpCompl )
		TMPHF->TPFRETE:= cModFrete
		TMPHF->TPCTE  := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPCTE")))
		TMPHF->XMLCTE := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML")))
		
		//FR - 17/03 - Legenda das cores:
		//aAdd(aCores,{"TMPHF->ST == '1'","BR_VERMELHO"	})
		//aAdd(aCores,{"TMPHF->ST == ' '","BR_AZUL"	    })
		//aAdd(aCores,{"TMPHF->ST == '0'","BR_AMARELO"  })
		//aAdd(aCores,{"TMPHF->ST == '2'","BR_VERDE"    })
		
		If nQual = 2 .And. cPrNf <> "B"		
			TMPHF->ST := "1"
		
		Elseif nQual == 1 .And. cPrNf ="B"		//FR - 17/03 - se a opção é por fornecedor e o registro não tem pré-nota:
			TMPHF->ST := " " 			
		
		//Elseif nQual == 1 .And. cPrNf ="N"		//FR - 17/03 - se a opção é por fornecedor e o registro já tem documento classificado (não entra no filtro, coloquei aqui só para visualizar a situação)
		//	TMPHF->ST := "1"
		
		Elseif nQual == 1 .And. cPrNf ="S"		//FR - 17/03 - se a opção é por fornecedor e o registro já tem pré-nota:
			TMPHF->ST := "2"
		Endif
		
		TMPHF->REG    := (xZBZ)->( Recno() )
		TMPHF->( MsUnLock() )		
	EndIF
	
	dbSelectArea(cAliasZBZ)
	(cAliasZBZ)->( dbSkip() )
	
End

If lRet .And. lFor

	MULTCTEBrw(nQual)
	
	dbSelectArea(cAliasZBZ)
	(cAliasZBZ)->( dbGoTop() )
	lRemove   := .T.
	
	While !(cAliasZBZ)->(Eof())	
		if TMPHF->ST <> "1"		
			lRemove   := .F.			
		endif 		
		(cAliasZBZ)->( dbSkip() )
	End
	
	if lRemove	
		DirRemove( cArqOri )		
	endif	
	
Else

	if ! lFor	
		U_MyAviso("Atenção",cMsg,{"Sair"},3)		
	Else	
		U_MyAviso("Atenção","Nenhuma Chave CTE em Aberto para Gerar Documento de Entrada",{"Sair"},3)	
	Endif
	
EndIf

DbSelectArea(cAliasZBZ)

(cAliasZBZ)->( dbCloseArea() )

dbSelectArea( "TMPHF" )
TMPHF->( dbCloseArea() )

//---------------------------------
//Exclui a tabela
//---------------------------------
oTempTable:Delete() 
//fErase( cArq+GetDBExtension() )

RestArea(aArea)

Return(lRet)


//Criar temporário para markbrowse do CTE
Static Function CriaTMP()

Local aStru := {}
//Local cRet

aadd( aStru, { "OK"      ,"C",02,0 } )
aadd( aStru, { "ST"      ,"C",01,0 } )
aadd( aStru, { "TPDOC"   ,"C",01,0 } )
aadd( aStru, { "TPCOMPL" ,"C",01,0 } )
aadd( aStru, { "TPFRETE" ,"C",01,0 } )
aadd( aStru, { "NOTA"    ,"C",len( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA"))) )  ,0 } )
aadd( aStru, { "SERIE"   ,"C",len( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE"))) ) ,0 } )
aadd( aStru, { "DTNFE"   ,"D",08,0 } )
aadd( aStru, { "PRENF"   ,"C",len( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF"))) ) ,0 } )
aadd( aStru, { "CNPJ"    ,"C",len( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))) )  ,0 } )
aadd( aStru, { "FORNEC"  ,"C",len( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FORNEC"))) ),0 } )
aadd( aStru, { "CHAVE"   ,"C",len( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))) ) ,0 } )
aadd( aStru, { "CODFOR"  ,"C",len( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR"))) ),0 } )
aadd( aStru, { "LOJFOR"  ,"C",len( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR"))) ),0 } )
aadd( aStru, { "TPCTE"   ,"C",len( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPCTE"))) ),0 } )
aadd( aStru, { "FILIAL"  ,"C",len( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))) ),0 } )
aadd( aStru, { "XMLCTE"  ,"M",10,0 } )
aadd( aStru, { "REG"     ,"N",15,0 } )

oTemptable:SetFields( aStru )

oTempTable:AddIndex( "01", { "NOTA","SERIE" } ) 
oTempTable:AddIndex( "02", { "CHAVE" } )

//------------------
//Criação da tabela
//------------------
oTempTable:Create()

Return( .T. )



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MULTCTEBrw³ Autor ³ Eneovaldo Roveri Jr   ³ Data ³04/02/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ MarkBrowse dos Multiplos CTE.                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MULTCTEBrw(nQual)

Local aButtons	:= {}
//Local aGetArea	:= GetArea()
//Local aInfo		:= {}
//Local aPosObj	:= {}
//Local aObjects	:= {}
//Local aSize		:= MsAdvSize()  			// Define e utilização de janela padrão Microsiga
//Local cGetLOk  	:= "AllwaysTrue"	   		// Funcao executada para validar o contexto da linha atual do aCols
//Local cGetTOk  	:= "AllwaysTrue"    		// Funcao executada para validar o contexto geral da MsNewGetDados
//Local oFolder	:= Nil
Local oDlg01	:= Nil
Local oMarkBw	:= Nil
Local lInverte	:= .F.
Local lOk		:= .F.
//Local cChvAtu	:= " "
//Local cChvAnt	:= " "
//Local oFont		:= Nil
Local aCpos     := {}
Local aCores    := {}

Private cMarcaOK := GetMark()

aCpos := {}
aadd( aCpos, {"OK"   	,,"" } )
aadd( aCpos, {"TPDOC"   ,,"Tp","!" } )
aadd( aCpos, {"TPCOMPL" ,,"Cpl","!" } )
aadd( aCpos, {"TPFRETE" ,,"TpFr","!" } )
aadd( aCpos, {"NOTA"    ,,"NOTA FISCAL","@!" } )
aadd( aCpos, {"SERIE"   ,,"SERIE","@!" } )
aadd( aCpos, {"DTNFE"   ,,"DT EMISSAO","@D" } )
aadd( aCpos, {"CHAVE"   ,,"CHAVE","@!" } )
aadd( aCpos, {"CNPJ"    ,,"CNPJ","@!" } )
aadd( aCpos, {"FORNEC"  ,,"EMITENTE","@!" } )
aadd( aCpos, {"CODFOR"  ,,"FORNEC","@!" } )
aadd( aCpos, {"LOJFOR"  ,,"LOJA","@!" } )
//aadd( aCpos, {"CSITCONF",,"MANIFESTO","@!" } )
//aadd( aStru, { "PRENF"   ,"C",len( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF"))) ) ,0 } )

aCores := {}
aAdd(aCores,{"TMPHF->ST == '1'","BR_VERMELHO"	})
aAdd(aCores,{"TMPHF->ST == ' '","BR_AZUL"	    })
aAdd(aCores,{"TMPHF->ST == '0'","BR_AMARELO"    })
aAdd(aCores,{"TMPHF->ST == '2'","BR_VERDE"      })	//FR - 17/03/2021 - Projeto MaxiRubber - Criação de novo filtro para a tela Multiplos Cte 


dbSelectArea("TMPHF")
//COUNT TO nQtdReg
TMPHF->( dbGotop() )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apresenta botao se nao for visualizacao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aButtons,{'DESTINOS',{ || MULTCTEEdt(@oMarkBw)     		 }, "Editar Tipo de Nota"    , "EDITAR"    })
aAdd(aButtons,{          ,{ || HFXML21Fil(@oMarkBw, "TMPHF")	 }, "Filtrar Registro"		 , "FILTRAR"   })
aAdd(aButtons,{'CHECKED' ,{ || MULTCTEInv(cMarcaOK,@oMarkBw)     }, "Inverter Marcação"      , "Inverter"  })
aAdd(aButtons,{'DESTINOS',{ || MULTCTEInv(cMarcaOK,@oMarkBw,.T.) }, "Marcar todos os títulos", "Marc Todos"})
aAdd(aButtons,{'DESTINOS',{ || HFXML21Leg() 					 }, "Legenda"				 , "LEGENDA"   })	//FR - 17/03/2021

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define as posicoes da GetDados e Paineis ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//aAdd( aObjects, { 100, 060, .T., .T. } )      //GetDados
//aAdd( aObjects, { 100, 040, .T., .T. } )      //Folder
//aInfo := { aSize[1], aSize[2], aSize[3], aSize[4], 3, 3 }
//aPosObj := MsObjSize( aInfo, aObjects,.T. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao da tela ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    //aSize[7],0 TO aSize[6],aSize[5]
DEFINE MSDIALOG oDlg01 TITLE "Gerar Documentos Multiplos CT-e(s)" FROM 000,000 TO 430,800 OF oMainWnd PIXEL

oDlg01:lMaximized := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria o objeto Mark para a selecao dos podrutos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oMarkBw := MsSelect():New("TMPHF","OK","",aCpos,@lInverte,@cMarcaOK,{17,10,150,400},,,,,aCores) //oFolder:aDialogs[1]

oMarkBw:oBrowse:Refresh()
oMarkBw:oBrowse:lhasMark    := .T.
oMarkBw:oBrowse:lCanAllmark := .T.
oMarkBw:oBrowse:Align       := CONTROL_ALIGN_ALLCLIENT	//Usado no modelo FLAT


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Permite selecao se não for visualizacao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oMarkBw:oBrowse:bAllMark    := { || MULTCTEInv(cMarcaOK,@oMarkBw) }
oMarkBw:oBrowse:bChange     := { || MULTCTEChg(@oMarkBw) }
oMarkBw:BMark               := { || MULTCTEDis(@oMarkBw,cMarcaOK) }

ACTIVATE MSDIALOG oDlg01 CENTERED  ON INIT EnchoiceBar(oDlg01,;
{|| processa({|| MULTCTEGER(@oMarkBw,nQual)}, "Gerar...","Gerando Documentos CTE ...") },;
{|| iif( msgYesNo("Sair Multiplo CTE ?","Pegunta"),oDlg01:End(),lOk := .F. )},,aButtons)

Return( .T. )




/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MULTCTEEdt³ Autor ³ Eneo                  ³ Data ³23/11/2019³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Editar Tipo de Nota, Complemento e Tipo de Freete          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MULTCTEEdt(oMarkBw)

Local aGetArea	:= GetArea()
Local lRet := .T.

if TMPHF->(Eof())
	RestArea( aGetArea )
	Return	
endif

cTipoDoc  := TMPHF->TPDOC
cTpCompl  := TMPHF->TPCOMPL
cModFrete := TMPHF->TPFRETE

@ 001,001 To 200,560 Dialog oSCR1 Title "Indique Dados do Frete"
@ 010,010 SAY "Tipo da Nota?:" Of oSCR1 PIXEL SIZE 48 ,9 COLOR CLR_HBLUE,oSCR1:nClrPane
@ 010,060 COMBOBOX oTipo VAR cTipoDoc ITEMS aCombo1 SIZE 70,10 PIXEL OF oSCR1
@ 010,150 SAY "Tipo Complemento?:" Of oSCR1 PIXEL SIZE 48 ,9 COLOR CLR_HBLUE,oSCR1:nClrPane
@ 010,210 COMBOBOX oTpCompl VAR cTpCompl ITEMS aCombo1x SIZE 70,10 PIXEL OF oSCR1
@ 040,010 SAY "Tipo de Frete?:" Of oSCR1 PIXEL SIZE 48 ,9 COLOR CLR_HBLUE,oSCR1:nClrPane
@ 040,060 COMBOBOX oModFrete VAR cModFrete ITEMS aFrete SIZE 100,10 PIXEL OF oSCR1
@ 070,010 Button "&Ok" Size 030,012 Pixel Action (lRet := .T., Close(oSCR1) )
@ 070,060 Button "&Cancela" Size 030,012 Pixel Action (lRet := .F., Close(oSCR1) )

Activate Dialog oSCR1 Centered

if lRet
	RecLock("TMPHF", .F.)	
	TMPHF->TPDOC   := cTipoDoc
	TMPHF->TPCOMPL := iif(cTipoDoc == "N", " ", cTpCompl )
	TMPHF->TPFRETE := cModFrete	
	TMPHF->( MsUnLock() )	
endif

oMarkBw:oBrowse:Refresh(.T.)
RestArea( aGetArea )

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MULTCTEInv³ Autor ³ Eneo                  ³ Data ³23/11/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Esta rotina ira marcar ou desmarcar os ctes.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MULTCTEInv(cMarcaOK,oMarkBw,lMarkAll)

Local aGetArea	:= GetArea()
Local lMarcSim	:= .F.

If lMarkAll
	lMarcSim := Aviso( "Marcar/Desmarcar todos", "Deseja marcar ou desmarcar todos os títulos?", { "Marcar", "Desmarcar" } ) == 1
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ While para marcar ou desmarcar os produtos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TMPHF->( dbGotop() )

//FR - 17/03 - Legenda das cores:
//aAdd(aCores,{"TMPHF->ST == '1'","BR_VERMELHO"	})
//aAdd(aCores,{"TMPHF->ST == ' '","BR_AZUL"	    })
//aAdd(aCores,{"TMPHF->ST == '0'","BR_AMARELO"  })
//aAdd(aCores,{"TMPHF->ST == '2'","BR_VERDE"    })
/*
If nQual = 2 .And. cPrNf <> "B"		
	TMPHF->ST := "1"
	
Elseif nQual == 1 .And. cPrNf ="B"		//FR - 17/03 - se a opção é por fornecedor e o registro não tem pré-nota:
	TMPHF->ST := " " 			
		
Elseif nQual == 1 .And. cPrNf ="S"		//FR - 17/03 - se a opção é por fornecedor e o registro já tem pré-nota:
	TMPHF->ST := "2"
Endif
*/
While TMPHF->( !EOF() )

	If lMarkAll	
		RecLock("TMPHF", .F.)
		TMPHF->OK	:= if(TMPHF->ST == "1", "  ", If(lMarcSim, cMarcaOK, "  ") )
		TMPHF->( MsUnLock() )		
	Else
	
		If  TMPHF->OK == cMarcaOK		
			RecLock("TMPHF", .F.)
			TMPHF->OK	:= "  "
			TMPHF->( MsUnLock() )			
		Else		
			RecLock("TMPHF", .F.)
			TMPHF->OK	:= if(TMPHF->ST == "1", "  ", cMarcaOK )
			TMPHF->( MsUnLock() )			
		EndIf		
	EndIf
	TMPHF->( dbSkip() )	
End

oMarkBw:oBrowse:Refresh(.T.)
RestArea( aGetArea )

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MULTCTEChg³ Autor ³                       ³ Data ³25/09/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MULTCTEChg(oMarkBw)

Local cRetFun		:= " "
oMarkBw:oBrowse:Refresh( .T. )
Return cRetFun


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MULTCTEDis³ Autor ³ Eneovaldo Roveri Jr   ³ Data ³19/01/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MULTCTEDis( oMarkBw, cMarcaOK )

Local aGetArea := GetArea()

If TMPHF->ST == "1" .And. TMPHF->OK	== cMarcaOK
	RecLock("TMPHF", .F.)	
	TMPHF->OK	:= "  "	
	TMPHF->( MsUnLock() )	
Endif

oMarkBw:oBrowse:Refresh(.T.)
RestArea( aGetArea )

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funo    ³MULTCTEGER³ Autor ³Eneovaldo Roveri Junior³ Data ³ 05/02/17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrio ³ Geração do Documento de Entrada para CT-e.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MULTCTEGER()                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MULTCTEGER(oMarkBw,nQual)

Local nReg     := TMPHF->( recno() )
Local nRecTMPHF:= TMPHF->( recno() )
Local lRemove  := .T.
Local lRet     := .T.
Local lTem     := .F.
Local nIte     := 0
Local aLinha   := {}
Local lPCNFE   := .F. //GetNewPar("MV_PCNFE",.F.) 07/11/2022 -> Heverton Desconsiderar e olhar o Ponto de Entrada MT140PC
Local nOpcPut  := 1
Local cError   := ""
Local cWarning := ""
//Local cMsgOK   := ""
Local cMsgErr  := ""
Local aZBO, nPFil, nPCod, nPDes, nPDto, nPHro, nPChv, nPRsf, nPTpo, nPRvo, nPArq, nPFpt, nPExa, nPStt, nPEmp, nPMai 

//-------------------------------------------//
//FR - Projeto Politec Saúde:

Local cClAtRBT    := GetNewPar("XM_CLATRBT","1")  	//FR - 27/11/19 - Tipo da robotização quando utilizada Classificação Automática:
//==================================================================================================================//
// Opções do parâmetro XM_CLATRBT
//"Indica a regra a ser utilizada para Classificar as notas de forma automática: "
//"1=Pergunta Múltiplos: Sistema irá perguntar se deseja incluir pre-Nota ou Nota fiscal de Entrada;"
//"2=Múltiplos NFE e CTE: Sistema irá abrir a tela p/ usuário informar a TES sem perguntar;"
//"3=CTE: Sistema irá selecionar qual TES está informado no parâmetro XM_CTE_TES ou XM_NFE_TES para classificar automático sem perguntar;"
//"Se o parâmetro XM_CTE_TES ou XM_NFE_TES estiver vazio, não será possível selecionar opção 3;"
//"4=Utiliza TES do Cad.Produto;"
//"5=Não Utilizado."
//==================================================================================================================//
Local cTESAut     := GetNewPar("XM_CTE_TES","")		//FR - 27/11/19 - Tes para classificação automática
Local lClassAut   := cClAtRBT $ "1/2/3/4"           //FR - 03/12/19 - até a opção 4, utiliza algum tipo de classificação, a opção 5 não utiliza nenhuma e só gera pré-nota
Local aNotas      := {} 
//Local lInfTES     := .T.
Local lClassifica := .F.
Local cCondPg     := ""
Local cMsg        := ""
Local nTotReg     := 0
//projeto Politec Saúde 
//-------------------------------------------//

Local cManPre     := GetNewPar("XM_MANPRE","N")  //Verifica qual tipo de manifestação		//FR - 17/03/2021 - Projeto MaxiRubber
Local cPrenf      := ""																		//FR - 17/03/2021 - Projeto MaxiRubber
Local lGerouPNF   := .F.		
Local Fr          := 0
Local nX          := 0
															//FR - 17/03/2021 - Projeto MaxiRubber
Private cTagFci   := ""
Private cCodFci   := ""
Private lNossoCod := .F.
Private cCnpjEmi  := ""
Private cCodEmit  := ""
Private cLojaEmit := ""
Private nFormNfe  := Val(GetNewPar("XM_FORMNFE","6"))
Private cEspecNfe := PADR(GetNewPar("XM_ESP_NFE","SPED"),5)
Private cEspecNfse:= PADR(GetNewPar("XM_ESP_NFS","NFS"),5) // NFCE_03 16/05
Private cModelo   := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO")))
Private aItXml    := {}
Private lNfOri    := ( GetNewPar("XM_NFORI","S") == "S" )
Private _lCCusto  := ( GetNewPar("XM_CCNFOR","N") == "S" ), _cCCusto
Private cCnpRem   := ""
Private aCnpRem   := {}
Private cTagAux   := ""
Private nValAux   := 0
Private lSerEmp   := .NOT. Empty( AllTrim(GetNewPar("XM_SEREMP","")) )
Private nAmarris  := 0
Private cPedidis  := ""
Private cTagTot   := ""
Private nTotXml   := 0
Private lAglCTE	  := ( GetNewPar('XM_AGLMCTE') == 'S' ) //Parametro se aglutina multiplos CTE ou nao
//Estes aqui de cima é para o legado, vai que o cabra use no ponto de entrada.

Private oXml
Private oDet, oOri
Private cProduto    := ""
Private aProduto    := {}
Private lMsErroAuto	:= .F.
Private lMsHelpAuto	:= .T.    // força a gravação das informações de erro em array para manipulação da gravação ao invés de gravar direto no arquivo temporário 
Private lAutoErrNoFile := .T. 
Private aCabec      := {}
Private aItens      := {}
Private nFormCTE    := Val(GetNewPar("XM_FORMCTE","6"))
Private nFormSer    := Val(GetNewPar("XM_FORMSER","0")) ///Incluido 19/01/2016
Private cEspecCte   := PADR(GetNewPar("XM_ESP_CTE","CTE"),5)
Private cTipoNf     := "N"
Private cPCSol      := GetNewPar("XM_CSOL","A")
Private cAmarra     := GetNewPar("XM_DE_PARA","0")
Private cTipoCPro   := ""
Private nAliqCTE    := 0, nBaseCTE := 0, nPedagio := 0  //, cModFrete := " "
Private lTemFreXml  := .F., lTemDesXml := .F., lTemSegXml := .F.
Private aAuxPeAma   := {}  //nordsonAmarraCof
Private aPerg       := {}
Private aCombo      := {}
Private cPref       := "CT-e"
Private cTAG        := "CTE"
Private nFormXML    := nFormCte
Private cEspecXML   := cEspecCte
Private lPergunta   := .F.
Private lDetCte     := ( GetNewPar("XM_CTE_DET","N") == "S" )
Private lTagOri     := ( GetNewPar("XM_CTE_DET","N") == "S" )
Private aReg        := {}
//Private lTemFreXml  := .F., lTemDesXml := .F., lTemSegXml := .F. 
Private cCfgPre     := GetNewPar("XM_CFGPRE","0")	//FR 17/03/2021
Private lNFDireto   := (cCfgPre $ "3")				//FR 17/03/2021 - Se = 3, já gera documento de entrada direto, sem passsar por pré nota

aZBO := U_HF13ZBOA()

U_HF13ZPOS( aZBO, @nPFil, @nPCod, @nPDes, @nPDto, @nPHro, @nPChv, @nPRsf, @nPTpo, @nPRvo, @nPArq, @nPFpt, @nPExa, @nPStt, @nPEmp, @nPMai )  //para fadigar

If nQual = 2
	cCodFor := TMPHF->CODFOR   // (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR")))
	cLojFor := TMPHF->LOJFOR   // (xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR")))
Endif

aCabec := {}
aadd(aCabec,{"F1_TIPO"   ,"N"})
aadd(aCabec,{"F1_FORMUL" ,"N"})

If .NOT. VERAMARRA()
	Return( .F. )	
EndIf

//----------------------------------------------------------------------------------------------------------------------------------------------------//
// FR - 04/12/19:
// Fazer com que esta pergunta apareça somente se o parâmetro Classifica NF automática =  1-Pergunta múltiplos, e o parâmetro XM_CTE_TES estiver vazio:
//----------------------------------------------------------------------------------------------------------------------------------------------------//
/*       //retirar
If lClassAut //indica que está parametrizada a classificação automática 
	cMsg    := "Geração Automática de Documentos:"+CRLF 
	

	nOpcPut := U_MYAVISO("Atenção","Deseja incluir Pré-Nota ou Nota Fiscal de Entrada?",{"Pré-Nota","Nota Fiscal"},3) 
Endif
*/
nOpcPut := 1 //força pré nota nesta etapa, só no final irá perguntar se deseja classificar
If lPCNFE
	if U_MYAVISO("Atenção","O Parametro MV_PCNFE está habilitado."+CRLF+"As pré-nota só serão geradas para os  CTes marcados como Complemento Tipo 3."+CRLF+"Deseja Continuar?",{"SIM","NÃO"},3) == 2
		Return( .F. )
	endif
Endif

aCabec := {}

DbSelectArea( "TMPHF" )

Count To nTotReg
ProcRegua( nTotReg )
cMsg := "Gerando Multiplos CTE(s):" + CRLF

TMPHF->( DbGotop() )
lGerouPNF := .F.   //NA - 02/03/2021 - variável que indica que ao menos uma pré-nota foi gerada, p/ qdo houver a pergunta "Deseja Classificar pré-nota gerada" não seja feita em vão

While .not. TMPHF->( Eof() )
	IncProc("Processando " + TMPHF->CHAVE)	
	if .not. empty( TMPHF->OK ) // == cMarcaOK	
		if nOpcPut = 1		
			if lPCNFE			
				if TMPHF->TPDOC <> "C"				
		            RecLock( "TMPHF", .F. )		            
	            	TMPHF->ST := "0"	            	
		            TMPHF->( MsUnLock() )		            
					TMPHF->(dbSkip())					
					Loop					
				endif				
			endif			
		else		
			if TMPHF->TPDOC = "C"			
		        RecLock( "TMPHF", .F. )		        
	            TMPHF->ST := "0"
		        TMPHF->( MsUnLock() )
				TMPHF->(dbSkip())				
				Loop				
			endif			
		endif

		nIte++
		lTem := .T.
		
		cCodFor  := TMPHF->CODFOR   // (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR")))
		cLojFor  := TMPHF->LOJFOR   // (xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR")))
		cCnpjFor := TMPHF->CNPJ   // (xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR")))
		cCodEmit := TMPHF->CODFOR
		cLojaEmit:= TMPHF->LOJFOR
		cCnpjEmi := TMPHF->CNPJ
        cCondPg  := ""
        cAuxXml  := ""      //FR - 17/02/2021
        
		DbSelectArea( xZBZ )
		(xZBZ)->( dbGoTo( TMPHF->REG ) )
		
		cAuxXml := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML")))        //FR - 17/02/2021
		
		cPrenf  := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF")))		//FR - 17/03/2021 - MaxiRubber
		//cXml := NoAcento((xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML"))))
		cXml := U_fNoAcento(cAuxXml)	//FR - 17/02/2021 - a função NoAcento é static e está no fonte HFXML02 e portanto, não poderia ser chamada daqui, criei essa user function assim poderá ser chamada de qq lugar
		cXml := EncodeUTF8(cXml)

		//Faz backup do xml sem retirar os caracteres especiais
		cBkpXml := cXml       

		//Executa rotina para retirar os caracteres especiais
		//cXml := u_zCarEspec( cXml )       //FR - 17/02/2021 - é aqui q tá zerando o xml , qdo passa por esta função aparentemente não mostra nenhum erro
											// e a variável cXml continua com conteúdo, porém, qdo passa no parse o objeto torna-se nulo
											//testei sem esta passagem e deu certo, qdo passou no parse, o oXml fica ok, como objeto

		oXml := XmlParser(cXml, "_", @cError, @cWarning )

		//retorna o backup do xml
		//cXml := cBkpXml					//FR - 17/02/2021
		
		If oXml == NIL .Or. !Empty(cError) .Or. !Empty(cWarning)	
            //retorna o backup do xml       //FR - 17/02/2021	
            cXml := cBkpXml
			cError := ""
			cWarning := ""

			//cXml := NoAcento((xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML"))))
			cXml := U_fNoAcento((xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML"))))	//FR - 17/02/2021 - a função NoAcento é static e está no fonte HFXML02 e portanto, não poderia ser chamada daqui, criei essa user function assim poderá ser chamada de qq lugar
			cXml := EncodeUTF8(cXml)

			//Faz backup do xml sem retirar os caracteres especiais
			cBkpXml := cXml

			//Executa rotina para retirar os caracteres especiais
			cXml := u_zCarEspec( cXml )

			oXml := U_PARSGDE( cXml, @cError, @cWarning )

			//retorna o backup do xml
			cXml := cBkpXml

		endif
		
		DbSelectArea( "TMPHF" )		
		If oXml == NIL .Or. !Empty(cError) .Or. !Empty(cWarning)		
			If !lAglCTE			
				cMsg += "XML Invalido ou Não Encontrado. Documento Não Gerado "+TMPHF->CHAVE+CRLF
				aCabec	:=	{}
				aItens	:=	{}
				nIte	:=	0 
				
				DbSelectArea( "TMPHF" )
              	RecLock( "TMPHF", .F. )
              	
               		TMPHF->OK := "  "
               		TMPHF->ST := "0"
               		
            	TMPHF->( MsUnLock() )
				TMPHF->( dbskip() )				
				Loop				
			Else			
				MsgSTOP("XML Invalido ou Não Encontrado, a Operação será Cancelada. Chave: "+TMPHF->CHAVE)
				lRet := .F.
				lRemove:= .F.
				Exit				
			Endif			
		EndIf
		
		oDet := oXml:_CTEPROC:_CTE:_INFCTE:_VPREST
		
		If nIte == 1		
			addCabec()			
		EndIF
		
		//------------------------------//
        //monta o array de itens da NF: 
        //------------------------------//
        //FR - 18/03/2020 - Ajuste na rotina de geração da nota ref. ao CTe
        // (para adequar aos itens gravados na ZBT, um para cada nota de origem)
        cNFOri      := ""
        cSROri      := ""
		cItemOri    := ""
		cCCOri      := ""
        fr          := 0
        nContaItens := 0
        aDocDaChave := {}
        _cCc        := ""

		//Verifica se tem nota fiscal de origem
		u_NTReferenc( oXml )
       
        If !lDetCte            			//FR - 18/03/2020
        	addItens( nIte, cNFOri, cSROri, cItemOri, cCCOri)     //addItens( nIte, , , )       //addItens( nIte, cNFOri, cSROri, nContaItens)
        Else
        	If Type( "oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE" ) != "U"
				oOri := oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE				
				oOri := iif( ValType(oOri) == "O", {oOri}, oOri )
			else
				oOri := {}
			EndIf
			
			nContaItens := Len(oOri) //qtde de notas que compõem o Cte			
        	
			//FR - 17/02/2021 - tratativa para qdo o CTe é de complemento
			cNFOri      := ""
			cSROri      := ""
			cChaveOri   := ""

			If Len(oOri) > 0         	
			
	        	For fr := 1 to Len(oOri)      //NA - 02/03/2021 - Loop de leitura das notas que compõem o Cte
	        	  
				    //NA - 02/03/2021
	        		cNFOri      := ""
			        cSROri      := ""
					cChaveOri   := ""
					_cCc        := ""
			        //NA - 02/03/2021
			        
					If lNfOri
						aDocDaChave := U_Sf3DaChave( oOri[fr]:_CHAVE:TEXT,,,,,@_cCc )  //Pegar Documentos no SF3
					Else
						aDocDaChave := U_DocDaChave( oOri[fr]:_CHAVE:TEXT,,,,,@_cCc )  //Pegar Documentos no SF2
					Endif 
					cNFOri := aDocDaChave[1]
					cSROri := aDocDaChave[2]
					cCCOri := aDocDaChave[3]		//NA - 02/03/2021
	        	                 
	        		addItens( fr, cNFOri, cSROri, nContaItens,cCCOri  )
					//addItens( nIte, cNFOri, cSROri, cItemOri, cCCOri)
	        	Next fr	
			
			Else //se não trouxe nenhum item, pode ser nf complemento, então faço nova tentativa com outra tag
				
				nContaItens := 1
				If Type("oXml:_CTEPROC:_CTE:_INFCTE:_INFCTECOMP:_CHCTE:TEXT") <> "U"	//tag que contem o número da nf origem, em caso de cte de complemento				
					cTagAux := "oXml:_CTEPROC:_CTE:_INFCTE:_INFCTECOMP:_CHCTE:TEXT" 
					cNFOri    := UPPER( Substr( &cTagAux,26,9) )
					cSROri    := UPPER( Substr( &cTagAux,23,3) )
					cChaveOri := &cTagAux	
				Endif
				
				//FR - 15/02/2021 - MaxiRubber - se não encontrar as informações na tag acima (pode ser que a tag não exista), então procura na tag abaixo:
				//neste caso, a nota original tem a mesma numeração do CTe.
				If Empty(cNFOri) .OR. Empty(cChaveOri)
					If Type("oXml:_CTEPROC:_PROTCTE:_INFPROT:_CHCTE:TEXT") <> "U"
                        cTagAux := "oXml:_CTEPROC:_PROTCTE:_INFPROT:_CHCTE:TEXT"					
						cNFOri    := UPPER( Substr( &cTagAux,26,9) )
						cSROri    := UPPER( Substr( &cTagAux,23,3) )
						cChaveOri := &cTagAux	//FR - 15/02/2021 - #6166 - MaxiRubber
					EndIf
				Endif
																//      Nro.item, nf original, série nf original, total itens
				addItens( 1, cNFOri, cSROri, nContaItens  )		//addItens( nIte, cNFOri     , cSROri           , nContaItens)
			//addItens( nIte, cNFOri, cSROri, cItemOri, cCCOri)
			Endif //Len(oOri)
			//FR - 17/02/2021
        	
        Endif
        it := 0
        x  := 0 
        lTemTES := .T.        
                      
        
        //Inclusao do ExecAuto, quando nao for para aglutinar se a variavel for .F.
        If !lAglCTE

			lMsErroAuto	:= .F.
			
			nRecTMPHF := TMPHF->( recno() )

			//if nOpcPut == 1
			nOpcPut := 1    //FR - 09/12/19 - só gera a pré-nota, depois irá perguntar se deseja classificar		
			//	xRet140	:=	MSExecAuto({|x,y,z| mata140(x,y,z)},aCabec,aItens,3,.T.)		//FR - 17/03/2021 - MaxiRubber		
			//else
			//	xRet140	:=	MSExecAuto({|x,y,z| mata103(x,y,z)},aCabec,aItens,3,.T.)				
			//endif
			
			//FR - 17/03/2021 - MaxiRubber
			If cPrenf == "B"		//Somente irá gerar pré-nota do xml status = 'B' -> Importado, se for status = 'S' (pré-nota a classificar)
									//Irá apenas adicionar no array aNotas para posterior classificação
				//FR - 17/03/2021
				If !lNFDireto 		//se não estiver parametrizado para gerar nota direto, gera pré-nota
					xRet140	:=	MSExecAuto({|x,y,z| mata140(x,y,z)},aCabec,aItens,3,.T.)									
				Endif
			Endif
			//FR - 17/03/2021 - MaxiRubber
			
			//----------------------------------------------------------//
			//FR - 28/11/19 - array a ser usado pela função fClassAut 
			//(classificação automática)
			//----------------------------------------------------------//
			Aadd(aNotas, {TMPHF->NOTA, aCabec, aItens, TMPHF->REG, cPrenf} )	//FR - 28/11/19 //FR - 17/03/2021 - MaxiRubber

			If !lMsErroAuto
				
				lGerouPNF := .T.	//NA - 02/03/2021 - Se chegou aqui é porque gerou a pré-nota, ao menos uma é suficiente para alimentar esta variável
	            
	            If !lNFDireto  			//FR - 17/03/2021 - se não estiver parametrizado para gerar nota direto, gera pré-nota
	            
		            DbSelectArea( xZBZ )
		            (xZBZ)->( dbGoTo( TMPHF->REG ) )                
		            Reclock(xZBZ,.F.)                
		           	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PRENF") , Iif(Empty(SF1->F1_STATUS),'S','N') ))
		           	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPDOC") , SF1->F1_TIPO ))
		           	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CODFOR"), aCabec[6][2] ))
		           	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"LOJFOR"), aCabec[7][2] ))
		            (xZBZ)->(FieldPut(FieldPos(xZBZ_+"DOCCTE"), aCabec[3][2] ))                    
		            (xZBZ)->( MsUnlock() )
		
					//FR - 17/03/2021
					/*
					Opções do XM_MANPRE:
					N = Não Manifestar
					1 = Confirma operação (Pré-NF)
					2 = Ciência operação (Pré-NF)
					3 = Confirmação operação (Classificação)
					*/
					//Manifesta e Verifica se o parametro esta habilitado para manifestar na pre nota				
					If FieldPos(xZBZ_+"MANIF") > 0 .and. cManPre == "2"				
		
						cOri := "1"
		
						if FieldPos(xZBZ_+"IMPORT") > 0
							if !Empty( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"IMPORT"))) )
								cOri := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"IMPORT")))
							Endif
						Endif
		
						cManif := U_MANIFXML( AllTrim( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))) ), .T., cOri ) 
		
						DbSelectArea(xZBZ)
						DbSetOrder(3)
						DbSeek( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))) )
						Reclock(xZBZ,.F.)                        
		
						(xZBZ)->(FieldPut(FieldPos(xZBZ_+"MANIF"), cManif ))
		
						(xZBZ)->( MsUnlock() )  
		
					Endif
	                
			    	DbSelectArea( "TMPHF" )
	                                      
	            	cMsg += "Pré-NF Gerada com Sucesso: " + TMPHF->NOTA +" Serie "+TMPHF->SERIE + CRLF                	
	    	    
	    	    Endif //lNFDireto
	    			
	        Else   //lMsErroAuto
            
            	lRet := .F.
            	lRemove:= .F.
            	
            	//MostraErro() 
            	//NA - 02/03/2021
            	aLog := GetAutoGRLog()
            	nX   := 0 
            	_cMsg := "" 
            	_cErro:= ""
            	For nX := 1 To Len(aLog)
            		If nX == 1
            			_cErro:= aLog[1]
            		Endif
					//If !"---" $ aLog[nX]
						_cMsg += aLog[nX]+" ; " + CRLF						
					//Endif
				Next nX
				
				cMsgErr := _cMsg   //NA - 02/03/2021 - Recebe a msg completa do erro gerado no GetAutoGRLog()
            	//NA - 02/03/2021
            	
				if nPFil > 0				
					aZBO[nPFil][4] := xFilial( xZBO )					
				endif
				
				if nPDes > 0				
					aZBO[nPDes][4] := "Erro ao gerar pré-nota NF "+TMPHF->NOTA+" Serie "+TMPHF->SERIE + "-> " +_cErro  //NA - 02/03/2021 - adicionar o motivo do erro e mostrar no myaviso no final					
				endif
				
				if nPDto > 0					
					aZBO[nPDto][4] := dDataBase						
				endif
					
				if nPHro > 0					
					aZBO[nPHro][4] := Time()						
				endif
					
				if nPChv > 0					
					aZBO[nPChv][4] := TMPHF->CHAVE						
				endif
					
				if nPTpo > 0					
					aZBO[nPTpo][4] := "1"						
				endif
					
				If nPArq > 0					
					aZBO[nPArq][4] := cPstOri						
				EndIf
					
				If nPExa > 0					
					aZBO[nPExa][4] := ""					
					if lMsErroAuto						
						aLog := GetAutoGRLog()	                  //Efetua o Tratamento para validar se o arquivo de Log Já Existe							
						For nX := 1 To Len(aLog)							
							aZBO[nPExa][4] += aLog[nX]+CHR(13)+CHR(10)								
						Next nX							
					endif						
				EndIf
					
				If nPStt > 0				
					aZBO[nPStt][4] := "1"					
				EndIf
				
				If nPMai > 0				
					aZBO[nPMai][4] := "1"					
				endif
				
				//nPFil, nPCod, nPDes, nPDto, nPHro, nPChv, nPRsf, nPTpo, nPRvo, nPArq, nPFpt, nPExa, nPStt, nPEmp, nPMai
				if U_HF13ZBOG( .F., 3, xFilial(xZBO)+"1"+AllTrim(TMPHF->CHAVE)+cPstOri, aZBO )					
					//Foi
					conout( "ZBO Gravou Log" )					
				endif

				/*If Select("TMPHF") <= 0
				
					dbUseArea(.T.,, cArq,"TMPHF", .F., .F.) //exclusivo
					IndRegua("TMPHF",cArq+"A","NOTA+SERIE" )
					IndRegua("TMPHF",cArq+"B","CHAVE" )
					dbClearIndex()
					dbSetIndex( cArq+"A" + OrdBagExt() )//ordem 1
					dbSetIndex( cArq+"B" + OrdBagExt() )//ordem 2
					dbSetOrder( 1 )
					
				EndIF*/
				
				//FR - 04/12/19:
				//Ao término do processo, da nota lida, emite mensagem aviso
				U_MyAviso("Aviso",cMsgErr,{"OK"},3)
   			
	   		EndIF  //lMsErroAuto
	   		
	   		If !lNFDireto  			//FR - 17/03/2021 - se não estiver parametrizado para gerar nota direto, gera pré-nota	
		        DbSelectArea( xZBZ )
		        (xZBZ)->( dbGoTo( TMPHF->REG ) )
		          
		        //cPrNf := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF")))
		            
		        xFil 	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL")))
				xNF  	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA")))
				xSer 	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE")))
				xForLoj	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR")))+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR")))
				xTpdoc	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC")))
				xModel	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO")))
				xDoccte	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"DOCCTE")))
				xRecno	:= (xZBZ)->(Recno())
					
		        /*
		   		cPrNf := U_HFSTXMUN( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL"))),;
		   				(xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA"))),;
		   				(xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE"))),;
		   				(xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR")))+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR"))) ,;
		   				(xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC"))),;
		   				(xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO"))),;
		   				(xZBZ)->(FieldGet(FieldPos(xZBZ_+"DOCCTE"))),;
		   				(xZBZ)->(Recno()) ) 
		   		*/
		   			
		   		
		   		//FR - 17/03/2021 - Aqui procura se já existe pré-nota ou nota, para atualizar o status:
				cPrNf := U_HFSTXMUN( xFil, xNF, xSer, xForLoj, xTpdoc, xModel, xDoccte, xRecno )  
		   					
		        DbSelectArea( "TMPHF" )
				TMPHF->( DbGoto( nRecTMPHF ) )
					
		        RecLock( "TMPHF", .F. )
		       	TMPHF->OK := "  "
		       		
		        If cPrNf <> "B"
		            
			    	If cPrNf == "S" 		//Gerou Pré-Nota               
			        	//cMsg += "Documento Gerado com Sucesso: "+aCabec[3][2]+CRLF
			            //TMPHF->ST := "1"            	
			            TMPHF->ST := "2"            	//FR - 17/03/2021 - "2" = Verde, gerou só pré-nota
			            
			        Elseif cPrNf == "N" 	//NF Classificada            
			          	cMsg += "Documento Classificado Chave "+TMPHF->CHAVE+CRLF
			           	TMPHF->ST := "1"
			        Endif
			        
			    //NÃO ATIVAR                
		      	//Else   //if cPrNf == "B"     //Importado - se continuar o mesmo status é porque não gerou a pré-nota        
		           	//cMsg += "Documento Não Foi Gerado Chave "+TMPHF->CHAVE+CRLF
		           	//TMPHF->ST := "0"            	
		        Endif
		            
		        TMPHF->( MsUnLock() )  
		        
	        Endif //lNFDireto
	                    
			aCabec	:=	{}
			aItens	:=	{}
			nIte	:=	0 
        EndIf        
    Else    
        lRemove:= .F.        
	endif	
	TMPHF->( dbskip() )	
End

//NA - 02/03/2021
If !Empty(cMsgErr)
	MsgInfo("As ocorrências de erro foram gravadas na tabela de ocorrências ("+xZBO+")."+ CRLF + " Podem ser Visualizadas no Relatório de Ocorrências Em 'Outras Ações' ")					
Endif
//NA - 02/03/2021
if .Not. lTem
	U_MyAviso("Msg","Nenhum CT-e selecionado para gerar documento !!!!",{"OK"},3)	
	TMPHF->( DbGoto( nReg ) )	
	return( .F. )	
endif

If lRet

	//Neste ponto se o parametro for SIM ele executa a contiçao abaixo - 31/05/2017
	If lAglCTE	
		lMata140 := .T.
		lMsErroAuto := .F.		
		//if nOpcPut == 1
		nOpcPut := 1 	//FR - 09/12/19 - só gera a pré-nota, depois irá perguntar se deseja classificar, 
						//e só oferecer a opção de classificação ao final, porque 
						//já teremos o array aNotas montado
		//FR - 17/03/2021
		If !lNFDireto 		//se não estiver parametrizado para gerar nota direto, gera pré-nota
			xRet140 := MSExecAuto({|x,y,z| mata140(x,y,z)},aCabec,aItens,3,.T.)
		Else
			lGerouPNF := .T.
		Endif
		//FR - 17/03/2021

		If lMsErroAuto		
			If xRet140			
				MOSTRAERRO()
				MsgSTOP("O documento de entrada não foi gerado.")				
			EndIf
			
			lRet := .F.
			lRemove:= .F.
			
			Count To nTotReg
			ProcRegua( nTotReg )
			
			TMPHF->( DbGotop() )
			
			While .not. TMPHF->( Eof() )			
				IncProc("Atualizando " + TMPHF->CHAVE)				
				if .not. empty( TMPHF->OK ) // == cMarcaOK				
					RecLock( "TMPHF", .F. )					
					TMPHF->OK := "  "
					TMPHF->ST := "0"					
					TMPHF->( MsUnLock() )					
				EndIF	
				TMPHF->( dbskip() )				
			Enddo
				
		Else	//If lMsErroAuto		
		
			//lMsHelpAuto:=.F.
			cMsg      := "Foi Gerado Um Único Documento de Entrada CTE Número " + aCabec[3][2] + " para as chaves:" + CRLF
			lGerouPNF := .T.	//FR - 17/03/2021 - Se chegou aqui é porque gerou a pré-nota, ao menos uma é suficiente para alimentar esta variável
					
			DbSelectArea( "TMPHF" )
			
			Count To nTotReg			
			ProcRegua( nTotReg )			
			TMPHF->( DbGotop() )
			
			While .NOT. TMPHF->( Eof() )
			
				IncProc("Atualizando " + TMPHF->CHAVE)
			
				if .not. empty( TMPHF->OK ) // == cMarcaOK	
					DbSelectArea( xZBZ )
					(xZBZ)->( dbGoTo( TMPHF->REG ) )
					
					Reclock(xZBZ,.F.)
					
						(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PRENF") , 'S' ))
						(xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPDOC") , SF1->F1_TIPO ))
						(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CODFOR"), aCabec[6][2] ))
						(xZBZ)->(FieldPut(FieldPos(xZBZ_+"LOJFOR"), aCabec[7][2] ))
						(xZBZ)->(FieldPut(FieldPos(xZBZ_+"DOCCTE"), aCabec[3][2] ))
						
					(xZBZ)->( MsUnlock() )
					
					cMsg += TMPHF->CHAVE+CRLF	
					DbSelectArea( "TMPHF" )					
					RecLock( "TMPHF", .F. )					
					TMPHF->OK := "  "
					//TMPHF->ST := "1"
					TMPHF->ST := "2"            	//FR - 17/03/2021 - "2" = Verde, gerou só pré-nota					
					TMPHF->( MsUnLock() )					
				EndIF	
				TMPHF->( dbskip() )				
			Enddo			
			U_MyAviso("Aviso",cMsg,{"OK"},3) 
						
		EndIf	//If lMsErroAuto
	Else	
		U_MyAviso("Aviso",cMsg,{"OK"},3)		
	EndIf	
Else
	U_HF13MAIL( cPstOri, .F. )	
EndIF

TMPHF->( DbGoto( nReg ) ) 

//----------------------------------------------------------------------------------------------------------------------------------------------------//
// FR - 04/12/19:
// Fazer com que esta pergunta apareça somente se o parâmetro Classifica NF automática =  1-Pergunta múltiplos, e o parâmetro XM_CTE_TES estiver vazio:
//----------------------------------------------------------------------------------------------------------------------------------------------------//
If lGerouPNF 		//NA - 02/03/2021
	If !lNFDireto	//FR - 17/03/2021
		If lClassAut //indica que está parametrizada a classificação automática 
			If cClAtRBT $ '1/2'    		//Pergunta		
				nOpcPut := U_MYAVISO("Atenção","Deseja Classificar a Pré-Nota Gerada ?",{"Sim","Não"},3)
				lClassifica := (nOpcPut = 1)
			Elseif cClAtRBT $ '3/4'  	//Classifica automático
				lClassifica := .T.
			Endif	
		Else
			nOpcPut := U_MYAVISO("Atenção","Deseja Classificar a Pré-Nota Gerada ?",{"Sim","Não"},3) 
			lClassifica := (nOpcPut = 1)
		Endif
	Else
		lClassifica := .T.
	Endif
	//FR - 17/03/2021

	If lPCNFE
		If lClassifica
			if U_MYAVISO("Atenção","O Parametro MV_PCNFE está habilitado."+CRLF+"Não é permitido emitir nota sem pedido de compra"+CRLF+"a menos que a TES do produto esteja no MV_TESPCNF."+CRLF+"Somente notas marcadas como tipo Normal será gerada. Continuar?",{"SIM","NÃO"},3) == 2
				Return( .F. )
				lClassifica := .F.			//FR - 04/12/19
			endif
		Endif	
	Else
		if U_MYAVISO("Atenção","Somente nota(s) marcada(s) como tipo Normal será(ão) gerada(s), a(s) marcada(s) como complemento de frete não será(ão) gerada(s), pois precisa da nota de origem. Continuar?",{"SIM","NÃO"},3) == 2
			Return( .F. )
			lClassifica := .F.			//FR - 04/12/19
		endif			
	Endif

	//FR - 09/12/19 - classifica a pré-nota gerada baseado nos parâmetros
	If lClassifica
		cDesc := "Classificação de CTE(s):"+CRLF 
		U_fClassAut( aNotas, cClAtRBT, cTESAut, cDesc, 'CTE' ) 	//User Function fClassAut( aNotas, cClAtRBT, cTESAut, cDesc, cTipo )
		//--------------------------------------------------//
		//FR - 17/03/2021 - Atualiza status do Markbrowse:
		//--------------------------------------------------//
		DbSelectArea( "TMPHF" )
		nTotReg := 0
			
		Count To nTotReg			
		ProcRegua( nTotReg )			
		TMPHF->( DbGotop() )
		cMsg := ""	
		While .NOT. TMPHF->( Eof() ) 
		
			nRecTMPHF := TMPHF->( recno() ) 
			
			IncProc("Atualizando Status... " + TMPHF->CHAVE)
		    
		    //Localiza e captura informações direto na ZBZ:
		    DbSelectArea( xZBZ )
			(xZBZ)->( dbGoTo( TMPHF->REG ) )    
			
			xFil 	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FILIAL")))
			xNF  	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA")))
			xSer 	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE")))
			xForLoj	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR")))+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR")))
			xTpdoc	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC")))
			xModel	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO")))
			xDoccte	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"DOCCTE")))
			xRecno	:= (xZBZ)->(Recno())
   			
	   		//FR - 17/03/2021 - Aqui procura se já existe pré-nota ou nota, para atualizar o status:
			cPrNf := U_HFSTXMUN( xFil, xNF, xSer, xForLoj, xTpdoc, xModel, xDoccte, xRecno )  
			
			DbSelectArea( "TMPHF" )
			TMPHF->( DbGoto( nRecTMPHF ) )			
			RecLock( "TMPHF", .F. )       		
       		
	        If cPrNf <> "B"	            
		    	If cPrNf == "S" 					//Gerou Pré-Nota               		           
		           	TMPHF->ST := "2"            	//FR - 17/03/2021 - "2" = Verde, gerou só pré-nota
		           	cMsg += "Documento Não Classificado: " + xNF + CRLF
		           			            
		        Elseif cPrNf == "N" 				//NF Classificada
		                    
		          	TMPHF->ST := "1"
		          	TMPHF->OK := "  "				//Se classificou a pré-NF, desmarca o [x]		          	
		          	cMsg += "Documento Classificado Com Sucesso: " + xNF + CRLF
		          	
		        Endif		                        
			Else   //if cPrNf == "B"     			//Importado - se continuar o mesmo status é porque não gerou a pré-nota        
	           	TMPHF->ST := "0"           	
	        Endif            
            TMPHF->( MsUnLock() )
            
            
            
			TMPHF->( dbskip() )				
		Enddo
		
		U_MyAviso("Aviso",cMsg,{"OK"},3)	
		//FR - 17/03/2021 - atualização status
		
	Endif

Endif //lGerouPNF
if lRemove .And. nQual = 2
	DirRemove( cArqOri )	
endif

//Refresh no grid
oMarkBw:oBrowse:Refresh(.T.)

Return( lRet )


//Verificação da amarração
//                          
//
***************************
Static Function VERAMARRA()
***************************
Local aProdOk   := {}
Local aProdNo   := {}
Local aProdVl   := {}
Local aProdZr   := {}
Local nErrItens := 0
Local nTamProd  := TAMSX3("B1_COD")[1]
Local lFound    := .F.
Local lRet      := .T.
Local aJaAmarou := {}

Private aParam := {}

cPerg := "IMPXML"
U_HFValPg1(cPerg)

DbSelectArea( xZBA )
(xZBA)->( dbSetOrder( 1 ) )
If (xZBA)->( dbSeek( xFilial( xZBA ) + __cUserID ) )
	If ! Empty( (XZBA)->(FieldGet(FieldPos(XZBA_+"AMARRA"))) )
		cAmarra := (XZBA)->(FieldGet(FieldPos(XZBA_+"AMARRA")))
	EndIf
EndIF
DbSelectArea( xZBZ )

cAmarra := iif( cAmarra $ "4,5", "0", cAmarra )

aParam   := {" "}
cParXMLExp := cNumEmp+"IMPXML"
cExt     := ".xml"
cNfes    := ""

aAdd( aCombo, "1=Padrão(SA5/SA7)" )
aAdd( aCombo, "2=Customizada("+xZB5+")")
aAdd( aCombo, "3=Sem Amarração"   )

aadd(aPerg,{2,"Amarração Produto","",aCombo,120,".T.",.T.,".T."})

aParam[01] := ParamLoad(cParXMLExp,aPerg,1,aParam[01])

If cAmarra == "0"
	If !ParamBox(aPerg,"Importa XML - Amarração",@aParam,,,,,,,cParXMLExp,.T.,.T.)
		lRet := .F.
	Else 
   		cAmarra  := aParam[01]
	EndIf
EndIf

if lRet
	cTipoCPro := cAmarra

	TMPHF->( dbgotop() )
	Do While .not. TMPHF->( Eof() )
		IncProc("Processando "+TMPHF->CHAVE)
		if .not. empty( TMPHF->OK ) // == cMarcaOK
			cCodFor  := TMPHF->CODFOR   // (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR")))
			cLojFor  := TMPHF->LOJFOR   // (xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR")))
			cCnpjFor := TMPHF->CNPJ   // (xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR")))
			cCodEmit := TMPHF->CODFOR
			cLojaEmit:= TMPHF->LOJFOR
			cCnpjEmi := TMPHF->CNPJ
			cNomEmit := TMPHF->FORNEC
			If aScan(aJaAmarou, {|x| x[1] = cCodFor .and. x[2] = cLojFor .And. x[2] = cCnpjFor } ) > 0
				TMPHF->( dbskip() )
				Loop
			EndIf
			DbSelectArea( xZBZ )
            (xZBZ)->( dbGoTo( TMPHF->REG ) )
			nErrItens := 0
			Do while nErrItens < 2
				lRet     := .T.
		 		aProdOk  := {}
		 		aProdNo  := {}
		 		aProdZr  := {}
				aProdVl  := {}
		 		nErrItens++
				cProdCte := Padr(GetNewPar("XM_PRODCTE","FRETE"),nTamProd)
		    	cProdCte := Iif(Empty(cProdCte),Padr("FRETE",nTamProd),cProdCte)
		
				If cTipoCPro == "2" // Ararracao Customizada ZB5 Produto tem que estar Amarrados Tanto Cliente como Formecedor
					cProduto := ""
		
					DbSelectArea(xZB5)
					DbSetOrder(1)
					// Filial + CNPJ FORNECEDOR + Codigo do Produto do Fornecedor
					If DbSeek(xFilial(xZB5)+cCnpjFor+cProdCte)
						cProduto := (xZB5)->(FieldGet(FieldPos(xZB5_+"PRODFI"))) //ZB5->ZB5_PRODFI
						aadd( aProduto, {cCodFor, cLojFor, cCnpjFor, cProduto} )
						lRet     := .T.
						aadd(aProdOk,{cProdCte,"PRESTACAO DE SERVICO - FRETE"} )
					Else
						aadd(aProdNo,{cProdCte,"PRESTACAO DE SERVICO - FRETE"} )
					EndIf
		
				//##################################################################
				ElseIf cTipoCPro == "1"  // Amarracao Padrao SA5/SA7
		
					cProduto  := ""
		
					cAliasSA5 := GetNextAlias()
		
					cWhere := "%(SA5.A5_CODPRF IN ("
					cWhere += "'"+AllTrim(cProdCte)+"'"
					cWhere += ") )%"
		
					BeginSql Alias cAliasSA5
		
					SELECT	A5_FILIAL, A5_FORNECE, A5_LOJA, A5_CODPRF, A5_PRODUTO, R_E_C_N_O_ 
							FROM %Table:SA5% SA5
							WHERE SA5.%notdel%
			    			AND A5_FORNECE = %Exp:cCodFor%
			    			AND A5_LOJA = %Exp:cLojFor%
				    		AND %Exp:cWhere%
				    		ORDER BY A5_FILIAL, A5_FORNECE, A5_LOJA, A5_CODPRF
					EndSql
		
					DbSelectArea(cAliasSA5)
					Dbgotop()
		        	lFound := .F.
			        cKeySa5:= xFilial("SA5")+cCodFor+cLojFor+cProdCte
		    	    While !(cAliasSA5)->(EOF())
						cKeyTMP := (cAliasSA5)->A5_FILIAL+(cAliasSA5)->A5_FORNECE+(cAliasSA5)->A5_LOJA+(cAliasSA5)->A5_CODPRF
						If 	AllTrim(cKeySa5) == AllTrim(cKeyTMP)
		        			lFound := .T.
		        			Exit
			        	Endif
		    	    	(cAliasSA5)->(DbSkip())
		        	Enddo
		
					If lFound
						cProduto := (cAliasSA5)->A5_PRODUTO
						aadd( aProduto, {cCodFor, cLojFor, cCnpjFor, cProduto} )
						lRet     := .T.
						aadd(aProdOk,{cProduto,"PRESTACAO DE SERVICO - FRETE"} )
					Else
						cProduto := cProdCte
						aadd(aProdNo,{cProdCte,"PRESTACAO DE SERVICO - FRETE"} )
					EndIf
		
					DbCloseArea()
		
				//##################################################################
				ElseIf cTipoCPro = "3" // Mesmo Codigo Nao requer amarracao SB1
					DbSelectArea("SB1")
					DbSetOrder(1)
					If DbSeek(xFilial("SB1")+cProdCte)
						cProduto := Substr(cProdCte,1,nTamProd)
						aadd( aProduto, {cCodFor, cLojFor, cCnpjFor, cProduto} )
						lRet     := .T.
						aadd(aProdOk,{cProdCte,"PRESTACAO DE SERVICO - FRETE"} )
					Else
						aadd(aProdNo,{cProdCte,"PRESTACAO DE SERVICO - FRETE"} )
					EndIF
				EndIf

				If .not. empty( cProduto )
					if SB1->( DbSeek(xFilial("SB1")+cProduto) )
						If SB1->( FieldGet(FieldPos("B1_MSBLQL")) ) == "1"
							aadd(aProdNo,{cProduto,"Produto Bloqueado SB1->"+SB1->B1_DESC} )
						EndIf
					ElseIf cTipoCPro != "3"
						aadd(aProdNo,{cProduto,"Não Cadastrado SB1->"+"PRESTACAO DE SERVICO - FRETE"} )
					EndIf
				EndIf

				if !Empty(aProdNo)
					//U_MyAviso("FORNECEDOR","CNPJ: "+cCnpjEmi+" Código: "+cCodEmit+" Lj: "+cLojaEmit ,{"Ok"},3)
				endif

				if .not. U_HFITNENC( "PREN", aProdOk, aProdNo, aProdVl, @nErrItens, aProdZr )
				    lRet := .F.
					//alert("cNãoCodFor")
				    Loop
				Else
					//alert(cCodFor)
					aadd(aJaAmarou, {cCodFor,cLojFor,cCnpjFor})
				    lRet := .T.
				    Exit
				endif
			EndDo
		endif
		//alert(lRet)
		if !lRet
			Exit
		endif
		TMPHF->( dbskip() )
	EndDo

EndIf

Return( lRet )



Static Function addCabec()

Local cDocXMl   := TMPHF->NOTA
Local cSerXml   := TMPHF->SERIE
Local dDataEntr := TMPHF->DTNFE
Local cChaveXml := AllTrim( TMPHF->CHAVE )
Local cTpCte    := TMPHF->TPCTE
//Local aFrete    := {" ","C-CIF","F-FOB","T-Por Conta Terceiros","S-Sem Frete"}
Local cModal    := ""
Local cModFrete := TMPHF->TPFRETE

Private cTagModal	:= "oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_MODAL:TEXT"
Private cTagToma    := ""

if Type( cTagModal ) <> "U"
	cModal := oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_MODAL:TEXT
endif
If Type("oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_TOMA03:_TOMA:TEXT") <> "U"
	cTagToma := "oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_TOMA03:_TOMA:TEXT" 
ElseIf Type("oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_TOMA4:_TOMA:TEXT") <> "U"
	cTagToma := "oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_TOMA4:_TOMA:TEXT"
ElseIf Type("oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_TOMA3:_TOMA:TEXT") <> "U"  /*Incluindo este else, pois a tag esta vindo toma3, implementando versao CT-e 3.00 - data 06/02/2017*/
   	cTagToma := "oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_TOMA3:_TOMA:TEXT"
EndIf

if !Empty(cTagToma) .And. Type( cTagToma ) <> "U"
	//cModFrete := &(cTagToma)
endif
/*
Do Case
	Case cModFrete == "0"
		cModFrete := "R"   //_REM:
	Case cModFrete == "1"
		cModFrete := "C"   //EXPED:_
	Case cModFrete == "2"
		cModFrete := "F"   //RECEB:_
	Case cModFrete == "3"
		cModFrete := "D"   //_DEST
	Case cModFrete == "4"
		cModFrete := "T"   //	_TOMA4:
	OtherWise
		cModFrete := "S"
		//{" ","C-CIF fornec","F-FOB cliente ","T-Por Conta Terceiros","R-Remetente","D-Destinatario","S-Sem Frete"}
EndCase
*/
//Alterado para atender ao empresa ITAMBÉ - 16/10/2014
//Analista Alexandro de Oliveira
Do Case
Case ( GetNewPar("XM_SERXML","N") == "S" )

	if alltrim( cSerXml ) == '0' .or. alltrim( cSerXml ) == '00' .or. alltrim( cSerXml ) == '000'
		cSerXml := '   '
	EndIf

Case ( GetNewPar("XM_SERXML","N") == "Z" )

	If Empty(cSerXml)
		cSerXml := '0'
	Endif

Case ( GetNewPar("XM_SERXML","N") == "P" )

	cSerXml := Padl(alltrim(cSerXml),nFormSer,"0")   //Padl(alltrim(cSerXml),Tamsx3("D1_SERIE")[1],"0")

EndCase

if lSerEmp
	cSerXml := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE")))
endif


aadd(aCabec,{"F1_TIPO"   ,Iif(Empty( TMPHF->TPDOC ),"N",AllTrim( TMPHF->TPDOC ))})
aadd(aCabec,{"F1_FORMUL" ,"N"})
aadd(aCabec,{"F1_DOC"    ,cDocXMl})
aadd(aCabec,{"F1_SERIE"  ,cSerXml})
aadd(aCabec,{"F1_EMISSAO",dDataEntr})
aadd(aCabec,{"F1_FORNECE",cCodFor})
aadd(aCabec,{"F1_LOJA"   ,cLojFor})
aadd(aCabec,{"F1_ESPECIE",cEspecXML})
aadd(aCabec,{"F1_CHVNFE" ,cChaveXml })
aadd(aCabec,{"F1_TPFRETE",cModFrete })
aadd(aCabec,{"F1_MODAL"  ,cModal })
aadd(aCabec,{"F1_TPCOMPL",Iif(TMPHF->TPDOC = "N", " ", TMPHF->TPCOMPL) })
aadd(aCabec,{"F1_TPCTE"  ,cTpCte })
IF SF1->(FieldPos("F1_UFORITR")) > 0 .And. SF1->(FieldPos("F1_MUORITR")) > 0 .And. SF1->(FieldPos("F1_UFDESTR")) > 0 .And. SF1->(FieldPos("F1_MUDESTR")) > 0
	if Type( "oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_CMUNINI:TEXT" ) <> "U"  //variavel oXml private, vindo do importa.
		cMunIni := oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_CMUNINI:TEXT
		if Len(cMunIni) == 7
			cMunIni := Substr(cMunIni,3,5)  //Os dois primeiros dígito é o Estado, no Prohtues o Código inicia direto na cidade.
		Endif
	endif
	if Type( "oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_UFINI:TEXT" ) <> "U"
		UFIni := oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_UFINI:TEXT
	endif

	if Type( "oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_CMUNFIM:TEXT" ) <> "U"  //variavel oXml private, vindo do importa.
		cMunFim := oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_CMUNFIM:TEXT
		if Len(cMunFim) == 7
			cMunFim := Substr(cMunFim,3,5)  //Os dois primeiros dígito é o Estado, no Prohtues o Código inicia direto na cidade.
		Endif
	endif
	if Type( "oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_UFFIM:TEXT" ) <> "U"
		UFFim := oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_UFFIM:TEXT
	endif

	aadd(aCabec,{"F1_MUORITR",cMunIni }) 
	aadd(aCabec,{"F1_UFORITR",UFIni   }) 
	aadd(aCabec,{"F1_MUDESTR",cMunFim }) 
	aadd(aCabec,{"F1_UFDESTR",UFFim   }) 
ENDIF

Return( NIL )


*************************************************************
Static Function addItens( nIte, cNFOri, cSROri, cItemOri, cCCOri,nCtaItens)
*************************************************************
Local aLinha    := {}
Local cTesB1PcNf:= ""
Local nPo       := 0
Local lXMLPEITE := ExistBlock( "XMLPEITE" )
//Local xTES      := ""
Local cTESNF    := ""
Local cCC       := ""
Local cProduto  := ""
Local nTamCc    := TAMSX3("D1_CC")[1]
Local lDetCte   := ( GetNewPar("XM_CTE_DET","N") == "S" )  //FR - 29/05/2023 - CHAMADO IVOCLAR 14933- RATEIO CTE
Local aValRat   := {}

Default nCtaItens := 0

For nPo := 1 To Len(aProduto)
	if aProduto[nPo][1] == cCodFor .And.  aProduto[nPo][2] == cLojFor .And. aProduto[nPo][3] == cCnpjFor
		if ! Empty (aProduto[nPo][4])
			cProduto := aProduto[nPo][4]
		endif
	endif
Next nPo

cTesB1PcNf := Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_TE")

cTagAliq   := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IMP:_ICMS:_ICMS00:_PICMS:TEXT" 
cTagAliq1  := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IMP:_ICMS:_ICMS20:_PICMS:TEXT"
If Type(cTagAliq)<> "U"  
	 	nAliqCTE   := Val(&(cTagAliq))
ElseIf Type(cTagAliq1)<>"U"
	    nAliqCTE  := Val(&(cTagAliq1))
EndIf    
cTagBase   := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IMP:_ICMS:_ICMS00:_VBC:TEXT"
cTagBase1  := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IMP:_ICMS:_ICMS20:_VBC:TEXT"
If Type(cTagBase)<> "U"
	nBaseCTE   := Val(&(cTagBase))
ElseIf Type(cTagBase1)<> "U"
	nBaseCTE   := Val(&(cTagBase1))
EndIf

nPedagio := 0
If Type( "oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_COMP" ) != "U"
//	For i := 1 to Len( oDet )
//		If AllTRim( oDet[i]:_XNOME:TEXT ) == "PEDAGIO"
//			nPedagio := Val(oDet[i]:_VCOMP:TEXT)
//		EndIf
//	Next i
EndIf
cTagTot    := "oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_VPREST:_VTPREST:TEXT"
//Trazendo doc e serie
//cTagDoc		:=	"oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_nCT:TEXT"
//cTagSerie	:=	"oXml:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_SERIE:TEXT"
//Fim
If Type(cTagTot)<> "U"
 	nTotXml   := Val(&(cTagTot))
Else
 	nTotXml   := 0
EndIf

If cPCSol == "S"  	//Centro de Custo do Pedido, então manda vazio para pegar do pedido ao relacionar o pedido F5 ou F6
	cCC := nTamCc  		
Elseif cPCSol != "Z"   //=> Com o Z não preenche o D1_CC, senão ao caso utilizar um gatilho poderia sobrepor o gatilho
	If .not. Empty( cProduto ) .And. SB1->( DbSeek(xFilial("SB1")+cProduto) )
		cCC := SB1->B1_CC
	EndIf
EndIf

lTagOri := .F.
//----------------------------------//
// Monta o array com itens para NF
//----------------------------------//                  
aadd(aLinha,{"D1_ITEM" 		,StrZero(nIte,4,0)       	,Nil})
aadd(aLinha,{"D1_COD"  		,cProduto                	,Nil})
if TMPHF->TPDOC <> "C"
	aadd(aLinha,{"D1_QUANT"	,1                   		,Nil})
endif
//--------------------------------------------------------------------------------//
//FR - 18/03/2020 - Tratamento para itens da ZBT que contém notas de origem do Cte
//--------------------------------------------------------------------------------//
If cNFOri <> Nil .and. cSROri <> Nil 				
// (quando há detalhamento de item regido pelo parâmetro XM_CTE_DET)
	aadd(aLinha,{"D1_NFORI"  	,cNfOri			     	   					,Nil})
	aadd(aLinha,{"D1_SERIORI"	,cSROri					 					,Nil}) 
	aadd(aLinha,{"D1_ITEMORI"   ,cItemOri	                                ,"AllwaysTrue()"})
	//aadd(aLinha,{"D1_VUNIT"		,VAL(oDet:_VTPREST:TEXT)   	,Nil})
	//aadd(aLinha,{"D1_TOTAL"		,VAL(oDet:_VTPREST:TEXT)  	,Nil})
	//FR - 29/05/2023 - CHAMADO IVOCLAR 14933 - FAZER RATEIO DOS ITENS DO CTE (NOTAS) PELO VALOR PROPORCIONAL DE CADA UMA EM RELAÇÃO AO TOTAL DO CTE
	nPrest := 0
	if valtype(oDet:_VTPREST:TEXT) <> "U"
		nPrest := ( VAL(oDet:_VTPREST:TEXT) )  //Valor da Prestação do Seviço que  ira ser rateado pelos DOCs que compõe o CTE
	endif
	
	//lDetCte     := ( GetNewPar("XM_CTE_DET","N") == "S" )
	aValRat := U_FRATEIOCTE(nPrest,cNfOri,cSROri,cItemOri,oDet)
	//aScan(aJaAmarou, {|x| x[1] = cCodFor .and. x[2] = cLojFor .And. x[2] = cCnpjFor } ) > 0
	nNota := aScan(aValRat, {|x| x[1] = cNfOri+cSROri } ) 
	If nNota > 0
		aadd(aLinha,{"D1_VUNIT"		,aValRat[nNota,2]  	,Nil})
		aadd(aLinha,{"D1_TOTAL"		,aValRat[nNota,2]  	,Nil})
	Else 
		aadd(aLinha,{"D1_VUNIT"		,VAL(oDet:_VTPREST:TEXT) 	,Nil})
		aadd(aLinha,{"D1_TOTAL"		,VAL(oDet:_VTPREST:TEXT) 	,Nil})
	Endif 
	
Else
	aadd(aLinha,{"D1_VUNIT"		,VAL(oDet:_VTPREST:TEXT) 	,Nil})
	aadd(aLinha,{"D1_TOTAL"		,VAL(oDet:_VTPREST:TEXT) 	,Nil})
Endif
//aadd(aLinha,{"D1_TES"  	,cTesB1PcNf					,Nil})
aadd(aLinha,{"D1_TES"  		,cTESNF						,Nil})
If cTpCentro =='2'
	aadd(aLinha,{"D1_CC"    	,cCC  						,Nil})
	Else
	aadd(aLinha,{"D1_CC"    	,cCCOri  						,Nil})
EndIf
If nAliqCte > 0
	aadd(aLinha,{"D1_PICM"	,nAliqCte         			,Nil})
EndIf
If nBaseCTE > 0
	aadd(aLinha,{"D1_BASEICM",nBaseCTE      			,Nil})
EndIf
If nAliqCte > 0 .And. nBaseCTE > 0
	aadd(aLinha,{"D1_VALICM",(nBaseCTE*(nAliqCte/100))	,Nil})
EndIf

If lXMLPEITE   //PE para incluir campos no aLinha SD1 -> para o aItens
	aRet :=	ExecBlock( "XMLPEITE", .F., .F., { cProduto,oDet,1 } )
	If ValType(aRet) == "A"
		AEval(aRet,{|x| AAdd(aLinha,x)})
	EndIf
endif

aadd(aItens,aLinha)

Return( NIL )


//=========================================================================================
//=== 
//==================
User Function HFSTXMUN( cFilZbz, cNotaZbz, cSerieZbz, cCodFor, cTipoNf, cModZbz, cDocCteZbz, nRecZbz, lAuto )
Local aArea     := GetArea()
Local nFormNfe  := Val(GetNewPar("XM_FORMNFE","6"))
Local cNotaSeek := ""
Local lSeek     := .F.
Default cDocCteZbz := Space(9)
Default nRecZbz    := (xZBZ)->( Recno() )
Default lAuto      := .F.

nOk := 0
nNo := 0

DbSelectArea("SF1")
DbSetOrder(1)
	lSeek := .F.
	cNotaSeek :=  Iif(nFormNfe > 0,StrZero(Val(cNotaZbz),nFormNfe),AllTrim(Str(Val(cNotaZbz))))
    lSeek := DbSeek(cFilZbz+Padr(cNotaSeek,9)+cSerieZbz+cCodFor+cTipoNf)

    If !lSeek
		cNotaSeek := AllTrim(Str(Val(cNotaZbz)))
   	   	lSeek := DbSeek(cFilZbz+Padr(cNotaSeek,9)+cSerieZbz+cCodFor+cTipoNf)
    EndIf

    If !lSeek
   		cNotaSeek :=  StrZero(Val(cNotaZbz),6)
   	   	lSeek := DbSeek(cFilZbz+Padr(cNotaSeek,9)+cSerieZbz+cCodFor+cTipoNf)
    EndIf
 
    If !lSeek
   		cNotaSeek :=  StrZero(Val(cNotaZbz),9)
   	  	lSeek := DbSeek(cFilZbz+Padr(cNotaSeek,9)+cSerieZbz+cCodFor+cTipoNf)
    EndIf

	//aquiii Multiplos CTE
    If !lSeek .And. cModZbz == "57" .AND. ! Empty( cDocCteZbz )
		cNotaSeek :=  Iif(nFormNfe > 0,StrZero(Val(cDocCteZbz),nFormNfe),AllTrim(Str(Val(cDocCteZbz ))))
        lSeek := DbSeek(cFilZbz+Padr(cNotaSeek,9)+cSerieZbz+cCodFor+cTipoNf)
    EndIF

    If !lSeek .And. cTipoNf == "N" .and. cModZbz == "57"
		cTipoNf := "C" //->Checar se é C
		cNotaSeek :=  Iif(nFormNfe > 0,StrZero(Val(cNotaZbz),nFormNfe),AllTrim(Str(Val(cNotaZbz))))
	   	lSeek := DbSeek(cFilZbz+Padr(cNotaSeek,9)+cSerieZbz+cCodFor+cTipoNf)
	
	   	If !lSeek
			cNotaSeek := AllTrim(Str(Val(cNotaZbz)))
	    	lSeek := DbSeek(cFilZbz+Padr(cNotaSeek,9)+cSerieZbz+cCodFor+cTipoNf)
	   	EndIf
	
	   	If !lSeek
			cNotaSeek :=  StrZero(Val(cNotaZbz),6)
	    	lSeek := DbSeek(cFilZbz+Padr(cNotaSeek,9)+cSerieZbz+cCodFor+cTipoNf)
	   	EndIf
	 
	   	If !lSeek
			cNotaSeek :=  StrZero(Val(cNotaZbz),9)
	    	lSeek := DbSeek(cFilZbz+Padr(cNotaSeek,9)+cSerieZbz+cCodFor+cTipoNf)
	   	EndIf

		//aquiii Multiplos CTE
		If !lSeek
			cNotaSeek :=  Iif(nFormNfe > 0,StrZero(Val(cDocCteZbz),nFormNfe),AllTrim(Str( Val(cDocCteZbz ))))
        	lSeek := DbSeek(cFilZbz+Padr(cNotaSeek,9)+cSerieZbz+cCodFor+cTipoNf)
	    EndIF
	Endif

	DbSelectArea(xZBZ)
	DbGoTo(nRecZbz)
    If lSeek
 			nOk++
			RecLock(xZBZ,.F.)
					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PRENF"), Iif(Empty(SF1->F1_STATUS),'S','N') ))
					if cTipoNf == "C" .and. (xZBZ)->&(xZBZ_+"TPDOC") == "N" .And. (xZBZ)->&(xZBZ_+"MODELO") == "57" 
						(xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPDOC"), cTipoNf ))
					endif
			(xZBZ)->( MsUnlock() )
	ElseiF (xZBZ)->&(xZBZ_+"PRENF") $ "A|S|N" 
			If (xZBZ)->&(xZBZ_+"PRENF") == "A"
				nNo++
			Endif

			DbSelectArea("DB2")
			DbSetorder(1)
		    lSeek := .F.
			cNotaSeek :=  Iif(nFormNfe > 0,StrZero(Val(cNotaZbz),nFormNfe),AllTrim(Str(Val(cNotaZbz ))))
    	    lSeek := DbSeek(cFilZbz+Padr(cNotaSeek,9)+cSerieZbz+cCodFor)
            
			DbSelectArea(xZBZ)
			DbGoTo(nRecZbz)
			RecLock(xZBZ,.F.)
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PRENF"), iif(lSeek, 'A', 'B') ))
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"DOCCTE"), space(9) ))
			(xZBZ)->( MsUnlock() )			
	Else
			nNo++
	EndIf

    If !lSeek

		If ( GetNewPar("XM_SEFPRN", "N") == "S" )

			//Proceder consulta do Bixo 
			if GetNewPar("XM_DFE","0") $ "0,1"
				U_HFXML02X( ,,,.F.,lAuto )
			else
				U_HFXML16X( ,,,.F.,lAuto )
			endif

		EndIf

	Endif

	cRet := (xZBZ)->(FieldGet( FieldPos(xZBZ_+"PRENF") ) )

RestArea( aArea )

Return( cRet )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³HFXML06Fil³ Autor ³ Mandela               ³ Data ³29/15/2018³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Filtrar por Coiso                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Bops ³ Manutencao Efetuada                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function HFXML21Fil(oMark, cAlias)
Local bCond := {|| TMPHF->ST = "0" }
Local cCond := 'ST="0"'
Local nOp   := 0

nOp := Filtros()
if nOp == 2
	bCond := {|| TMPHF->ST = " " }
	cCond := 'ST=" "'
elseif nOp == 3
	bCond := {|| TMPHF->ST = "1" }
	cCond := 'ST="1"'
elseif nOp == 4
	bCond := {|| TMPHF->ST = "0" }
	cCond := 'ST="0"' 
//FR - 17/03/2021 - MaxiRubber - novo filtro para tela Multiplos Cte
elseif nOp == 5
	bCond := {|| TMPHF->ST = "2" }
	cCond := 'ST="2"'
endif

if nOp == 0
	TMPHF->( DBClearFilter())
Else
	TMPHF->( DBSetFilter( bCond, cCond ) )
Endif

oMark:oBrowse:Refresh(.T.)

Return( NIL )


//;filtros
Static Function Filtros()
Local nRet := 0
Local nRadio := 1
Local aItems := {}
Local aCores := {}
Local oDlg

//aAdd(aCores,{"TMPHF->ST == '1'","BR_VERMELHO"	})
//aAdd(aCores,{"TMPHF->ST == ' '","BR_AZUL"	    })
//aAdd(aCores,{"TMPHF->ST == '0'","BR_AMARELO"  })
//aAdd(aCores,{"TMPHF->ST == '2'","BR_VERDE"    })

AADD(aCores,{"BR_AZUL"    ,"Aguardando gerar documento" 		})
AADD(aCores,{"BR_VERMELHO","Documento Gerado com sucesso" 		})
AADD(aCores,{"BR_AMARELO" ,"Erro ao tentar gerar o documento" 	})
AADD(aCores,{"BR_VERDE"   ,"Pré-Nota Aguardando Classificação" 	})		//FR - 17/03/2021 - nova legenda para o novo filtro - Projeto MaxiRubber

DEFINE DIALOG oDlg TITLE "Filtrar por Status" FROM 180,180 TO 350,500 PIXEL
   
	nRadio := 1
 	aItems := {'TODOS','Aguardando gerar documento - Azul','Documento Gerado com sucesso - Vermelho','Erro ao tentar gerar o documento - Amarelo','Pré-Nota Aguardando Classificação - Verde'}	//17/03/2021 - nova legenda para o novo filtro - Projeto MaxiRubber 
 	oRadio := TRadMenu():New (01,01,aItems,,oDlg,,,,,,,,200,12,,,,.T.)
 	oRadio:bSetGet := {|u|Iif (PCount()==0,nRadio,nRadio:=u)}
	@ 50,77 BUTTON oBtnOut PROMPT "&OK" SIZE 38,11 PIXEL ACTION (oDlg:End())

ACTIVATE DIALOG oDlg CENTERE

if nRadio == 0 .or. nRadio == 1
	nRet := 0
Else
	nRet := nRadio
Endif

Return( nRet )


Static Function __Dummy(lRecursa) //warning W0010 Static Function <?> never called
    lRecursa := .F.
    IF (lRecursa)
        __Dummy(.F.)
        U_HFXMLMCT()
	EndIF
Return(lRecursa)
//==================================================================================//
//Função  : HFXML21Leg 
//Autoria : Flávia Rocha
//Data    : 17/03/2021
//Objetivo: Exibe Legenda para os XMLs modelo Cte - Tela multiplos Cte
//==================================================================================//
Static Function HFXML21Leg()
Local aLegenda := {}

AADD(aLegenda,{"BR_AZUL"    	,"XML Importado" 					})
AADD(aLegenda,{"BR_AMARELO" 	,"Erro ao Gerar Documento" 			})
AADD(aLegenda,{"BR_VERDE" 		,"Pré-Nota a Classificar" 			})
AADD(aLegenda,{"BR_VERMELHO"	,"Pré-Nota Classificada" 			})

BrwLegenda("Status Xml Cte", "Legenda", aLegenda)

Return Nil

//=================================================================================================//
//FUNÇÃO : FRATEIOCTE
//AUTORIA: FLÁVIA ROCHA
//DATA   : 29/05/2023
//FAZ O RATEIO DO VALOR DO CTE PELOS ITENS (NFs) , DE FORMA PROPORCIONAL AO VALOR DA NF ORIGINAL
//=================================================================================================//
USER FUNCTION FRATEIOCTE(nPrest,xNfOri,xSROri,cItemOri,oDet)
Local aRateio := {}
Local oOri
Local i       := 0
//Local cNfOri  := ""
//Local cSerOri := ""
Local lNfOri  := ( GetNewPar("XM_NFORI","N") == "S" )
Local nValBrut:= 0
Local lSemNfe := .F.
Local aTotal  := {}
Local nTotNfe := 0
Local y       := 0
Local cTGP    := "CTE"
Local cTAG    := "CTE"
Local nContaitens := cItemOri
Local _cCc    := ""

//TESTE COM XML CTE 000693377 / 3
//If cModelo == "57" .And. lDetCte .And. Type("oXml:_CTEPROC:_CTE:_INFCTE:_REM:_INFNF") != "U"
		
//oOri := oXml:_CTEPROC:_CTE:_INFCTE:_REM:_INFNF
//oOri := IIf(ValType(oOri)=="O",{oOri},oOri)

//checa os nós do XML: 
If XmlChildEx(oXml:_CTEPROC:_CTE:_INFCTE,"_REM") <> nil
	If XmlChildEx(oXml:_CTEPROC:_CTE:_INFCTE:_REM,"_INFNFE") <> nil
		oOri := oXml:_CTEPROC:_CTE:_INFCTE:_REM:_INFNFE
	Endif 
Endif 

//se não encontrar, checa neste nó:  _INFDOC:_INFNF
If oOri == Nil 
	If XmlChildEx(oXml:_CTEPROC:_CTE:_INFCTE,"_INFCTENORM") <> nil
		If XmlChildEx(oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM,"_INFDOC") <> nil
			If XmlChildEx(oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC,"_INFNF") <> nil
				oOri := oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNF
			Endif 
		Endif 
	Endif
Endif 

//se não encontrar, checa neste nó: _INFDOC:_INFNFE
If oOri == Nil 
	If XmlChildEx(oXml:_CTEPROC:_CTE:_INFCTE,"_INFCTENORM") <> nil
		If XmlChildEx(oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM,"_INFDOC") <> nil
			If XmlChildEx(oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC,"_INFNFE") <> nil
				oOri := oXml:_CTEPROC:_CTE:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE
			Endif 
		Endif 
	Endif 
Endif 

If oOri == Nil 
	oOri := IIf(ValType(oOri)=="O",{oOri},oOri)

	For i := 1 To Len(oOri)
			
		if lNfOri
			aDocDaChave := U_Sf3DaChave( oOri[i]:_CHAVE:TEXT,,,,,@_cCc )  //Pegar Documentos no SF3
		else
			aDocDaChave := U_DocDaChave( oOri[i]:_CHAVE:TEXT,,,,,@_cCc )  //Pegar Documentos no SF2
		endif
				
		if lNfOri			
			DbSelectArea("SF3")
			DbSetOrder(6)
			DbSeek( xFilial("SF3") + aDocDaChave[1] + aDocDaChave[2] )				
			nValBrut := SF3->F3_VALCONT			
		else			
			DbSelectArea("SF2")
			DbSetOrder(1)
			DbSeek( xFilial("SF2") + aDocDaChave[1] + aDocDaChave[2] )				
			nValBrut := SF2->F2_VALBRUT			
		endif
				
		if nValBrut == 0			
			lSemNfe := .T.
			aTotal  := {}
			Exit
		endif 
				
		nTotNfe += nValBrut
				
		aAdd( aTotal, { nValBrut, 0 } )
				
	Next i 
EndIf

For y := 1 To Len(aTotal)
	aTotal[y,2] := aTotal[y,1] / nTotNfe
Next y

nTotal := 0
nIctot := 0
nVPeda := 0  //Fadiga da OCRIM
nTPeda := 0

For i := 1 To Len(oOri)

    //If i == Len(oOri)
       	//nVunit := nPrest - nTotal
       	//nBunit := nBaseCTE - nIctot
            	
		//if nPedagio > 0  //Fadiga da OCRIM
		//	nVPeda := nPedagio - nTPeda
		//Else
		//	nVPeda := 0
		//endif
				
	//Else
		nVunit := iif( lSemNfe, Round( ( nPrest / Len(oOri) ), 2 ), Round( ( nPrest * aTotal[i,2] ), 2 ) )				
		//nBunit := iif( lSemNfe, Round( ( nBaseCTE / Len(oOri) ), 2 ), Round( ( nBaseCTE * aTotal[i,2]  ), 2 ) )
		
		//if nPedagio > 0  //Fadiga da OCRIM
		//	nVPeda := iif( lSemNfe, Round( ( nPedagio / Len(oOri) ), 2 ), Round( ( nPedagio * aTotal[i,2]  ), 2 ) )
		//endif
	//EndIf
            
	//nTPeda += nVPeda
    //nTotal += nVunit
    //nIctot += nBunit
            
    //cCnpRem := ""
	//aLinha = {}
	//_cCCusto:= ""
	//_cCc    := ""
			
	//if _lCCusto
	//	_cCCusto := _cCc
	//endif
			
	//aadd( aCnpRem, cCnpRem )
			
	if lNfOri
		aDocDaChave := U_Sf3DaChave( oOri[i]:_CHAVE:TEXT,,,,,@_cCc )  //Pegar Documentos no SF3
	else
		aDocDaChave := U_DocDaChave( oOri[i]:_CHAVE:TEXT,,,,,@_cCc )  //Pegar Documentos no SF2
	endif

	cNfOri := aDocDaChave[1]
	cSerOri := aDocDaChave[2]

	Aadd(aRateio, {cNfOri+cSerOri, nVunit})
	
	/*		
	aadd(aLinha,{"D1_ITEM" ,StrZero(i,4,0)          ,Nil})
	aadd(aLinha,{"D1_COD"  ,cProduto                 ,Nil})
	aadd(aLinha,{"D1_QUANT",1                        ,Nil})
	aadd(aLinha,{"D1_NFORI",cNfOri				     ,Nil})
	aadd(aLinha,{"D1_SERIORI",cSerOri				 ,Nil})
	aadd(aLinha,{"D1_VUNIT",nVunit					 ,Nil})
	aadd(aLinha,{"D1_TOTAL",nVunit					 ,Nil})
		
	if nVPeda > 0
		aadd(aLinha,{"D1_PEDAGIO",nVPeda			 ,Nil})
		aadd(aLinha,{"D1_BASEPIS",nVunit-nVPeda		,Nil})
		aadd(aLinha,{"D1_BASECOF",nVunit-nVPeda		,Nil})
		aadd(aLinha,{"D1_BASECSL",nVunit-nVPeda		,Nil})
	Endif
	if .NOT. Empty( _cCCusto )
		aadd(aLinha,{"D1_CC"    ,_cCCusto  					 ,Nil})
	elseif cPCSol == "S"  //Centro de Custo do Pedido, então manda vazio para pegar do pedido ao relacionar o pedido F5 ou F6
		aadd(aLinha,{"D1_CC"    ,nTamCc  					 ,Nil})
	elseif cPCSol != "Z"   //=> Com o Z não preenche o D1_CC, senão ao caso utilizar um gatilho poderia sobrepor o gatilho
		if .not. empty( cProduto ) .And. SB1->( DbSeek(xFilial("SB1")+cProduto) )
			aadd(aLinha,{"D1_CC",SB1->B1_CC					 ,Nil})
		endif
	endif
			
	If nAliqCte > 0
		aadd(aLinha,{"D1_PICM",nAliqCte             ,Nil})
	EndIf
			
	If nBunit > 0
		aadd(aLinha,{"D1_BASEICM",nBunit             ,Nil})
	EndIf
			
	If nAliqCte > 0 .And. nBunit > 0
		aadd(aLinha,{"D1_VALICM",(nBunit*(nAliqCte/100)),Nil})
	EndIf
	If lXMLPEITE   //PE para incluir campos no aLinha SD1 -> para o aItens
		aRet :=	ExecBlock( "XMLPEITE", .F., .F., { cProduto,oDet,i } )
		If ValType(aRet) == "A"
			AEval(aRet,{|x| AAdd(aLinha,x)})
		EndIf
	endif

	If lXMLPELOK   //PE para lin OK
 			
		IF ! Empty(cProduto)  //Só se passou pela amarração
 				
 			lLOk :=	ExecBlock( "XMLPELOK", .F., .F., { cModelo,cProduto,oDet,i } )
	 				
			If ValType(lLOk) <> "L"
				Alert( "Ponto de entrada XMLPELOK deve Retornar .T. ou .F." )
				lLOk := .F.
			EndIf
	 				
			if ! lLOk
				Exit
			Endif
	 				
		Else
	 			
			lLOk := .T.
					
		EndIf
	 			
 	Endif

	//aadd(aItens,aLinha)
	*/
	
Next i	

Return(aRateio)
