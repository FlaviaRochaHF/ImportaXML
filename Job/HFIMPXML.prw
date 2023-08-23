/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ProcXml   º Autor ³ Roberto Souza      º Data ³  07/10/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Processa os XMLs na estrutura padrão para leitura.         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Importa Xml                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function HFIMPXML()
                    
Local aFiles   := {}
Local cDir     := ""
Local cDirDest := ""                     
Local cDirRej  := ""                     
Local cDirCfg  := ""
Local ni       := 0
Local nLen	   := 0

Private xcXml2   := ""
Private aFilsLic := {}
Private lXmlsLic := .F.
Private aFilsEmp := {}
Private lUnix    := IsSrvUnix()
Private cBarra   := Iif(lUnix,"/","\")

Private lAuto    := .T. 
Private lEnd     := .F.
Private cLogProc := ""
Private nCount   := 0
Private oProcess := Nil

RpcSetType(3)
RpcSetEnv( "99","01" )

DbSelectArea("SM0")
nRecFil := Recno()

cDir     := "\"+AllTrim(GetNewPar("MV_X_PATHX",""))+"\"
cDirDest := AllTrim(cDir+"Importados\")                     
cDirRej  := AllTrim(cDir+"Rejeitados\")                     
cDirCfg  := AllTrim(cDir+"Cfg\")

aFilsEmp := U_XGetFilS(SM0->M0_CGC,@aFilsLic)

DbSelectArea("SM0")
DbGoTo(nRecFil)

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

aFiles	:=	Directory(cDir+"*.XML","D")

If Len(aFiles) >= 500
    nLen := 500
Else
    nLen := Len(aFiles)
EndIf	

For nI := 1 To nLen

    U_HFSLVXML(aFiles[nI,1], lAuto,@lEnd,oProcess,@cLogProc,@nCount, "1" ) //FR - 13/11/19 - Chamada da rotina que grava o XML

Next

Return
