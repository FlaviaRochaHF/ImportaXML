#Include "Protheus.Ch"
#Include "RwMake.Ch"
#Include "TbiConn.Ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |HFXMLR01  º Autor ³ Roberto Souza      º Data ³  18/05/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatório de comparação de documentos fiscais de entrada   º±±
±±º          ³ que não foi recepcionado o XML do Fornecedores.            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ IMPORTA XML                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function HFXMLR01


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de acordo com os parametros informados pelo usuario."
Local cDesc3         := "Doctos Entrada x Xml"
Local cPict          := ""
Local titulo       := "Doctos Entrada x Xml"
Local nLin         := 6

Local Cabec1       := ""
Local Cabec2       := ""
Local imprime      := .T.
Local aOrd := {}
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private CbTxt        := ""
Private limite           := 80
Private tamanho          := "P"
Private nomeprog         := "HFXMLR01" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo            := 18
Private aReturn          := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey        := 0
Private cbtxt      := Space(10)
Private cbcont     := 00
Private CONTFL     := 01
Private m_pag      := 01
Private wnrel      := "NOME" // Coloque aqui o nome do arquivo usado para impressao em disco
Private cPerg      := "HFXMLR01"
Private cString := "SF1"

dbSelectArea("SF1")
dbSetOrder(1)

dVencLic := Stod(Space(8))
//lUsoOk := U_HFXML00X("HF000001","101",SM0->M0_CGC,@dVencLic)  
lUsoOk	:= U_HFXMLLIC(.F.)

If !lUsoOk
	Return(Nil)
EndIf

AjustaSX1(cPerg)

Pergunte(cPerg,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a interface padrao com o usuario...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.F.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif

nTipo := If(aReturn[4]==1,15,18)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ AP6 IDE            º Data ³  18/05/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
Local Nx      := 0
Local nOrdem
Local cWhere  := ""
Local cOrder  := ""
Local cLinCab := ""     
Local cFilDe  := MV_PAR01
Local cFilAte := MV_PAR02
Local cDtIni  := DTos(MV_PAR03)
Local cDtFim  := DTos(MV_PAR04)
Local cSerIni := MV_PAR05
Local cSerFim := MV_PAR06
Local cNFIni  := MV_PAR07
Local cNFFim  := MV_PAR08   
Local cEspecP := MV_PAR09//"('SPED','CTE')"
Local cForIni := MV_PAR10
Local cForFim := MV_PAR11
Local cLojaIni:= MV_PAR12
Local cLojaFim:= MV_PAR13
Local aEspecP := Separa(cEspecP,",",.F.)
Local nCol    := 7
Local nIniLin := 6
Private xZBZ      := GetNewPar("XM_TABXML","ZBZ")      //ECOOOOOOOOOO
Private xZBZ_ 	  := iif(Substr(xZBZ,1,1)=="S", Substr(xZBZ,2,2), Substr(xZBZ,1,3)) + "_"
Private cSF1      := GetNextAlias() 
Private lSharedA1 := U_IsShared("SA1")
Private lSharedA2 := U_IsShared("SA2") 
Private nFormNfe  := Val(GetNewPar("XM_FORMNFE","6"))
Private nFormCTe  := Val(GetNewPar("XM_FORMCTE","6"))
Private aHfCloud  := {"0","0"," ","Token",{}}  //CRAUMDE - '0' Não integrar, na posição 1

If Len(aEspecP)>0
	nTamesp := Len(aEspecP)
	cEspecP := "("
	For Nx := 1 To nTamesp
    	cEspecP += "'"+AllTrim(aEspecP[Nx])+"'"	
		If Nx < nTamesp
			cEspecP += ","
		EndIf
	Next     
	cEspecP += ")"
Else
	cEspecP := "('SPED','CTE')"
EndIf

	cWhere := "% AND  SF1.F1_DTDIGIT>='"+cDtIni+"' AND  SF1.F1_DTDIGIT<='"+cDtFim+"' AND SF1.F1_ESPECIE IN "+cEspecP
	cWhere += " AND  SF1.F1_FORMUL <> 'S'"
	cWhere += " AND  SF1.F1_FILIAL>='"+cFilDe+"' AND  SF1.F1_FILIAL<='"+cFilAte+"'"	
	cWhere += " AND  SF1.F1_DOC>='"+cNFIni+"' AND  SF1.F1_DOC<='"+cNFFim+"'"
	cWhere += " AND  SF1.F1_SERIE>='"+cSerIni+"' AND  SF1.F1_SERIE<='"+cSerFim+"' "
	cWhere += " AND  SF1.F1_FORNECE>='"+cForIni+"' AND  SF1.F1_FORNECE<='"+cForFim+"' "						               
	cWhere += " AND  SF1.F1_LOJA>='"+cLojaIni+"' AND  SF1.F1_LOJA<='"+cLojaFim+"' %"						               
							               
    cOrder := "%( F1_FILIAL,F1_DTDIGIT,F1_DOC,F1_SERIE )%"

	BeginSql Alias cSF1
	
		SELECT	F1_FILIAL,F1_DOC,F1_SERIE,F1_FORNECE,F1_LOJA,F1_TIPO,F1_ESPECIE,
			F1_EMISSAO,	F1_DTDIGIT,F1_CHVNFE,F1_VALBRUT,R_E_C_N_O_ 
			FROM %Table:SF1% SF1
			WHERE SF1.%notdel%
			%Exp:cWhere%
    		ORDER BY F1_FILIAL,F1_FORNECE,F1_LOJA,F1_DOC,F1_SERIE ,F1_DTDIGIT
	EndSql      

cLinCab:= "Especie     Serie   N. Fiscal       Emissão     Entrada       Valor Bruto      "
//        "1234567890123456789012345678901234567890123456789012345679012345678901234567890"
//        "         1         2         3         4         5        6         7         8"
DbSelectArea(xZBZ)
DbSetOrder(6) 

DbSelectArea(cSF1)
SetRegua(RecCount())
DbGoTop()

Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
nLin := nIniLin

While (cSF1)->(!EOF())
	cFilProc := (cSF1)->F1_FILIAL
	@nLin,00 PSAY "Filial - "+(cSF1)->F1_FILIAL
	nLin ++    
	
	While (cSF1)->F1_FILIAL == cFilProc .And. (cSF1)->(!EOF())
		
		lFirst := .F.
		If (cSF1)->F1_TIPO $ "D|B"
			DbSelectArea("SA1")
			cFilSeek := Iif(lSharedA1,xFilial("SA1"),cFilProc)
			DbSeek(cFilSeek+(cSF1)->F1_FORNECE+(cSF1)->F1_LOJA)
			cCnPjF   := SA1->A1_CGC
			cNome    := SA1->A1_NOME
			cTel     := SA1->A1_DDD + " " + SA1->A1_TEL
			cMail    := SA1->A1_EMAIL
		Else            
			DbSelectArea("SA2")
			cFilSeek := Iif(lSharedA2,xFilial("SA2"),cFilProc)
			DbSeek(cFilSeek+(cSF1)->F1_FORNECE+(cSF1)->F1_LOJA)
			cCnPjF   := SA2->A2_CGC 
			cNome    := SA2->A2_NOME
			cTel     := SA2->A2_DDD + " " + SA2->A2_TEL
			cMail    := SA2->A2_EMAIL
			
		EndIf        
		       		
		
		nLin++
		cCodFor := (cSF1)->F1_FORNECE+(cSF1)->F1_LOJA       
	    @nLin,00 PSAY (cSF1)->F1_FORNECE+"-"+(cSF1)->F1_LOJA+" "+cNome+" "+cCnPjF
		nLin++
	    @nLin,00 PSAY "Fone: " + AllTrim(cTel)
		@nLin,26 PSAY "E-mail: "+cMail 
		nLin++

		@nLin,00 PSAY Replicate("-",80)
		nLin++  
		@nLin,nCol + 00 PSAY cLinCab   
		nLin++    
		
		
	    While (cSF1)->F1_FORNECE+(cSF1)->F1_LOJA == cCodFor .And. (cSF1)->(!EOF())
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica o cancelamento pelo usuario...                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lAbortPrint
				@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			    Exit
			Endif
		   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   	//³ Impressao do cabecalho do relatorio. . .                            ³
		   	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		   	If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
		      	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		      	nLin := nIniLin
		   	Endif
			
			cStatXml:= "" 
			lSeekNf := BuscaXMl(cFilProc,@cStatXml,cCnPjF)
			
			If 	!lSeekNf	
				   
			    @nLin,nCol + 00 PSAY (cSF1)->F1_ESPECIE
				@nLin,nCol + 12 PSAY (cSF1)->F1_SERIE
			    @nLin,nCol + 20 PSAY (cSF1)->F1_DOC
			    @nLin,nCol + 36 PSAY ConvDate(1 , (cSF1)->F1_EMISSAO)
			    @nLin,nCol + 48 PSAY ConvDate(1 , (cSF1)->F1_DTDIGIT)
			    @nLin,nCol + 60 PSAY Transform((cSF1)->F1_VALBRUT,"@E 99,999,999.99")
		
			   	nLin++  
			   	lFirst := .T.
			EndIf
				 
		   (cSF1)->(DbSkip())
		EndDo       
		If 	!lFirst	
			   
		    @nLin,nCol + 00 PSAY Replicate("-",5)
			@nLin,nCol + 12 PSAY Replicate("-",3)
		    @nLin,nCol + 20 PSAY Replicate("-",9)
		    @nLin,nCol + 36 PSAY Replicate("-",8)
		    @nLin,nCol + 48 PSAY Replicate("-",8)
		    @nLin,nCol + 60 PSAY Replicate("-",13)
	
		   	nLin++  
		EndIf
	
		@nLin,00 PSAY Replicate("-",80)
		nLin++
	EndDo
   	If (cSF1)->(!EOF())
      	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      	nLin := nIniLin
   	Endif
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza a execucao do relatorio...                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SET DEVICE TO SCREEN

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se impressao em disco, chama o gerenciador de impressao...          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif

MS_FLUSH()

Return


 
Static Function ConvDate(nTipo , uDado)
Local xRet      
If nTipo == 1 // AAAAMMDD -> DD/MM/AA
	xRet := Substr(uDado,7,2)+"/"+Substr(uDado,5,2)+"/"+Substr(uDado,3,2)
Else
	xRet := uDado
EndIf                                      
	
Return(xRet) 


Static Function BuscaXml(cFilProc,cStatXml,cCnPjF)
Local lRet     := .F.
Local aArea    := GetArea()
Local lSeek    := .F. 
Local cModelo  := ""
Local cNFSeek  := ""
Local cKeySeek := "" 
Local cNotaSeek:= ""
Private nFormXML  := 6 
Private cModelo   := Iif( AllTrim((cSF1)->F1_ESPECIE) == "SPED" ,"55", Iif( AllTrim((cSF1)->F1_ESPECIE) == "CTE","57","" ))

If cModelo == "55"
 	cPref    := "NF-e"                             
	cTAG     := "NFE"
	nFormXML := nFormNfe
ElseIf cModelo == "57"
 	cPref    := "CT-e"                             
	cTAG     := "CTE"
	nFormXML := nFormCte
EndIf

/*
If (cSF1)->F1_TIPO $ "D|B"
	cFilSeek := Iif(lSharedA1,"  ",cFilProc)
	cCnPjF   := Posicione("SA1",1,cFilSeek+(cSF1)->F1_FORNECE+(cSF1)->F1_LOJA,"A1_CGC")
Else
	cFilSeek := Iif(lSharedA2,"  ",cFilProc)
	cCnPjF   := Posicione("SA2",1,cFilSeek+(cSF1)->F1_FORNECE+(cSF1)->F1_LOJA,"A2_CGC")
EndIf        
*/       

DbSelectArea(xZBZ) 
DbSelectArea(6) // "ZBZ_FILIAL+ZBZ_MODELO+ZBZ_NOTA+ZBZ_SERIE+ZBZ_CNPJ"

    lSeek := .F.
   	cNotaSeek := Iif(nFormXML > 0,StrZero(Val((cSF1)->F1_DOC),nFormXML),AllTrim(Str(Val((cSF1)->F1_DOC))))
	cKeySeek  := (cSF1)->F1_FILIAL+cModelo+cNotaSeek+(cSF1)->F1_SERIE+cCnPjF
 
	lSeek := (xZBZ)->(DbSeek(cKeySeek))
       
    If !lSeek
		cNotaSeek := Padr(AllTrim(Str(Val((cSF1)->F1_DOC))),9)
		cKeySeek  := (cSF1)->F1_FILIAL+cModelo+cNotaSeek+(cSF1)->F1_SERIE+cCnPjF
        lSeek := (xZBZ)->(DbSeek(cKeySeek))
    EndIf

    If !lSeek
   		cNotaSeek :=  Padr(StrZero(Val((cSF1)->F1_DOC),6),9)
    	cKeySeek  := (cSF1)->F1_FILIAL+cModelo+cNotaSeek+(cSF1)->F1_SERIE+cCnPjF
        lSeek := (xZBZ)->(DbSeek(cKeySeek))
    EndIf
 
    If !lSeek
   		cNotaSeek :=  Padr(StrZero(Val((cSF1)->F1_DOC),9),9)
       	cKeySeek  := (cSF1)->F1_FILIAL+cModelo+cNotaSeek+(cSF1)->F1_SERIE+cCnPjF
        lSeek := (xZBZ)->(DbSeek(cKeySeek))
 	EndIf
 
    IF !lSeek
   		cNotaSeek := Iif(nFormXML > 0,StrZero(Val((cSF1)->F1_DOC),nFormXML),AllTrim(Str(Val((cSF1)->F1_DOC))))
		cKeySeek  := (cSF1)->F1_FILIAL+cModelo+cNotaSeek+Str( Val( (cSF1)->F1_SERIE ), len( (cSF1)->F1_SERIE ) )+cCnPjF
		lSeek := (xZBZ)->(DbSeek(cKeySeek))
	ENDIF
       
    If !lSeek
		cNotaSeek := Padr(AllTrim(Str(Val((cSF1)->F1_DOC))),9)
		cKeySeek  := (cSF1)->F1_FILIAL+cModelo+cNotaSeek+Str( Val( (cSF1)->F1_SERIE ), len( (cSF1)->F1_SERIE ) )+cCnPjF
        lSeek := (xZBZ)->(DbSeek(cKeySeek))
    EndIf

    If !lSeek
   		cNotaSeek :=  Padr(StrZero(Val((cSF1)->F1_DOC),6),9)
    	cKeySeek  := (cSF1)->F1_FILIAL+cModelo+cNotaSeek+Str( Val( (cSF1)->F1_SERIE ), len( (cSF1)->F1_SERIE ) )+cCnPjF
        lSeek := (xZBZ)->(DbSeek(cKeySeek))
    EndIf
 
    If !lSeek
   		cNotaSeek :=  Padr(StrZero(Val((cSF1)->F1_DOC),9),9)
       	cKeySeek  := (cSF1)->F1_FILIAL+cModelo+cNotaSeek+Str( Val( (cSF1)->F1_SERIE ), len( (cSF1)->F1_SERIE ) )+cCnPjF
        lSeek := (xZBZ)->(DbSeek(cKeySeek))
 	EndIf
 
	If lSeek 
		cStatXml := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF")))
		lRet := .T.
	EndIf		                                  	

                       
RestArea(aArea)
Return(lRet)


Static Function AjustaSX1(cPerg)
Local aHelpPor := {}
Local nTmFil  := FWGETTAMFILIAL

Aadd( aHelpPor, "Informe a Filial inicial a ser processada." )
U_HFPutSx1(cPerg,"01","Filial de   "        ,"Prev.Fechamento de  ","Prev.Fechamento de  "	,"mv_ch1","C",nTmFil,0,0,"G","","SM0","","","mv_par01","","","","","","","","","","","","","","","","",aHelpPor,aHelpPor,aHelpPor)
                 
aHelpPor := {}
Aadd( aHelpPor, "Informe a Filial final a ser processada." )
U_HFPutSx1(cPerg,"02","Filial Ate  "        ,"Prev.Fechamento Ate ","Prev.Fechamento Ate "	,"mv_ch2","C",nTmFil,0,0,"G","","SM0","","","mv_par02","","","","","","","","","","","","","","","","",aHelpPor,aHelpPor,aHelpPor)

aHelpPor := {}
Aadd( aHelpPor, "Informe a Data de entrada inicial a ser processada." )
U_HFPutSx1(cPerg,"03","Entrada de  "        ,"Prev.Fechamento de  ","Prev.Fechamento de  "	,"mv_ch3","D",08,0,0,"G","",   "","","","mv_par03","","","","","","","","","","","","","","","","",aHelpPor,aHelpPor,aHelpPor)

aHelpPor := {}
Aadd( aHelpPor, "Informe a Data de entrada final a ser processada." )
U_HFPutSx1(cPerg,"04","Entrada Ate "        ,"Prev.Fechamento Ate ","Prev.Fechamento Ate "	,"mv_ch4","D",08,0,0,"G","",   "","","","mv_par04","","","","","","","","","","","","","","","","",aHelpPor,aHelpPor,aHelpPor)

aHelpPor := {}
Aadd( aHelpPor, "Informe a Serie inicial a ser processada." )
U_HFPutSx1(cPerg,"05","Serie de    "	 	,"Moeda"				,"Moeda"				,"mv_ch5","C",03,0,0,"G","",   "","","","mv_par05","","","","","","","","","","","","","","","","",aHelpPor,aHelpPor,aHelpPor)

aHelpPor := {}
Aadd( aHelpPor, "Informe a Serie final a ser processada." )
U_HFPutSx1(cPerg,"06","Serie Ate   "	 	,"Moeda"				,"Moeda"				,"mv_ch6","C",03,0,0,"G","",   "","","","mv_par06","","","","","","","","","","","","","","","","",aHelpPor,aHelpPor,aHelpPor)

aHelpPor := {}
Aadd( aHelpPor, "Informe a Nota Fiscal inicial a ser processada." )
U_HFPutSx1(cPerg,"07","Nota Fiscal de    " 	,"Moeda"				,"Moeda"				,"mv_ch7","C",09,0,0,"G","",   "","","","mv_par07","","","","","","","","","","","","","","","","",aHelpPor,aHelpPor,aHelpPor)

aHelpPor := {}
Aadd( aHelpPor, "Informe a Nota Fiscal final a ser processada." )
U_HFPutSx1(cPerg,"08","Nota Fiscal Ate   "	,"Moeda"				,"Moeda"				,"mv_ch8","C",09,0,0,"G","",   "","","","mv_par08","","","","","","","","","","","","","","","","",aHelpPor,aHelpPor,aHelpPor)

aHelpPor := {}
Aadd( aHelpPor, "Informe as espécies que devem ser consideradas" )
Aadd( aHelpPor, "separadas por virgulas Ex: SPED,CTE" )
U_HFPutSx1(cPerg,"09","Considera especie   "	,"Moeda"				,"Moeda"				,"mv_ch9","C",20,0,0,"G","",   "","","","mv_par09","","","","","","","","","","","","","","","","",aHelpPor,aHelpPor,aHelpPor)

aHelpPor := {}
Aadd( aHelpPor, "Informe o codigo inicial do emissor do XML." )
U_HFPutSx1(cPerg,"10","Emissor do XML de   "	,"Moeda"				,"Moeda"				,"mv_cha","C",TAMSX3("ZBZ_CODFOR")[1],0,0,"G","",   "","","","mv_par10","","","","","","","","","","","","","","","","",aHelpPor,aHelpPor,aHelpPor)

aHelpPor := {}
Aadd( aHelpPor, "Informe o codigo final do emissor do XML." )
U_HFPutSx1(cPerg,"11","Emissor do XML ate   "	,"Moeda"				,"Moeda"				,"mv_chb","C",TAMSX3("ZBZ_CODFOR")[1],0,0,"G","",   "","","","mv_par11","","","","","","","","","","","","","","","","",aHelpPor,aHelpPor,aHelpPor)


aHelpPor := {}
Aadd( aHelpPor, "Informe a loja inicial do emissor do XML." )
U_HFPutSx1(cPerg,"12","Loja do Emissor do XML de   "	,"Moeda"				,"Moeda"				,"mv_chc","C",TAMSX3("ZBZ_LOJFOR")[1],0,0,"G","",   "","","","mv_par12","","","","","","","","","","","","","","","","",aHelpPor,aHelpPor,aHelpPor)

aHelpPor := {}
Aadd( aHelpPor, "Informe a loja final do emissor do XML." )
U_HFPutSx1(cPerg,"13","Loja do Emissor do XML ate   "	,"Moeda"				,"Moeda"				,"mv_chd","C",TAMSX3("ZBZ_LOJFOR")[1],0,0,"G","",   "","","","mv_par13","","","","","","","","","","","","","","","","",aHelpPor,aHelpPor,aHelpPor)


Return


Static Function __Dummy(lRecursa) //warning W0010 Static Function <?> never called
    lRecursa := .F.
    IF (lRecursa)
        __Dummy(.F.)
        U_HFXMLR01()
	EndIF
Return(lRecursa)
