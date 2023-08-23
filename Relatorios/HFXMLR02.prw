#include 'totvs.ch'
#include 'topconn.ch'
#INCLUDE "rwmake.ch"
#INCLUDE "TBICONN.CH"
#Include "Protheus.Ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |HFXMLR02  º Autor ³ Roberto Souza      º Data ³  17/01/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatório de comparação de documentos fiscais de entrada   º±±
±±º          ³ que não foi recepcionado o XML do Fornecedores.            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ IMPORTA XML                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function HFXMLR02


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de acordo com os parametros informados pelo usuario."
Local cDesc3         := "Notificações de Xml"
Local cPict          := ""
Local titulo       := "Notificações de Xml"
Local nLin         := 6

Local Cabec1       := ""
Local Cabec2       := ""
Local imprime      := .T.
Local aOrd := {}
Private xZBZ         := GetNewPar("XM_TABXML","ZBZ")      //ECOOOOOOOOOO
Private xZBZ_ 	     := iif(Substr(xZBZ,1,1)=="S", Substr(xZBZ,2,2), Substr(xZBZ,1,3)) + "_"
Private aHfCloud     := {"0","0"," ","Token",{}}  //CRAUMDE - '0' Não integrar, na posição 1
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private CbTxt        := ""
Private limite           := 80
Private tamanho          := "P"
Private nomeprog         := "HFXMLR02" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo            := 18
Private aReturn          := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey        := 0
Private cbtxt      := Space(10)
Private cbcont     := 00
Private CONTFL     := 01
Private m_pag      := 01
Private wnrel      := "NOME" // Coloque aqui o nome do arquivo usado para impressao em disco
Private cPerg      := "HFXMLR02"
Private cString := xZBZ

dVencLic := Stod(Space(8))
//lUsoOk := U_HFXML00X("HF000001","101",SM0->M0_CGC,@dVencLic)  
lUsoOk	:= U_HFXMLLIC(.F.)

If !lUsoOk
	Return(Nil)
EndIf

dbSelectArea(xZBZ)
dbSetOrder(1)


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
Local cTabela := ""
Local cWhere  := ""
Local cOrder  := ""
Local cLinCab := ""     
Local cFilDe  := MV_PAR01
Local cFilAte := MV_PAR02
Local cDtIni  := DTos(MV_PAR03)
Local cDtFim  := DTos(MV_PAR04)
Local cEspecP := MV_PAR05
Local aEspecP := Separa(cEspecP,",",.F.)
Local nCol    := 1
Local nIniLin := 6
Private cZBZ      := GetNextAlias() 

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

	cTabela:= "%"+RetSqlName(xZBZ)+"%"
	cWhere := "% AND  ZBZ."+xZBZ_+"DTRECB >='"+cDtIni+"' AND  ZBZ."+xZBZ_+"DTRECB<='"+cDtFim+"' AND ZBZ."+xZBZ_+"MAIL IN "+cEspecP
	cWhere += " AND  ZBZ."+xZBZ_+"FILIAL>='"+cFilDe+"' AND  ZBZ."+xZBZ_+"FILIAL<='"+cFilAte+"' %"						               
	cOrder := "%"+xZBZ_+"FILIAL,"+xZBZ_+"DTRECB%"
							               
	BeginSql Alias cZBZ
	
		SELECT *
			FROM %Exp:cTabela% ZBZ
			WHERE ZBZ.%notdel%
			%Exp:cWhere%
    		ORDER BY %Exp:cOrder%
	EndSql      

cLinCab:= "Especie  Serie  N.Fiscal     Emissão   Entrada   Status      "
//        "1234567890123456789012345678901234567890123456789012345679012345678901234567890"
//        "         1         2         3         4         5        6         7         8"
		
DbSelectArea(xZBZ)
DbSetOrder(6) 

DbSelectArea(cZBZ)
SetRegua(RecCount())
DbGoTop()

Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
nLin := nIniLin

aStat := {}
aadd(aStat,{"0","Ok"})
aadd(aStat,{"1","Erro (Pendente)"})
aadd(aStat,{"2","Erro (Enviado)"})
aadd(aStat,{"3","Cancelamento (Pendente)"})
aadd(aStat,{"4","Cancelamento (Enviado)"})
aadd(aStat,{"X","Falha (Erro)"})
aadd(aStat,{"Y","Falha (Cancelamento)"})

If (cZBZ)->(EOF())
	@nLin,00 PSAY "Nenhum registro foi encontrado com os parâmetros selecionados."+(cZBZ)->&(xZBZ_+"FILIAL")
Else
	
	While (cZBZ)->(!EOF())
	
	   	If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
	      	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	      	nLin := nIniLin
	   	Endif
	
		cFilProc := (cZBZ)->&(xZBZ_+"FILIAL")
		@nLin,00 PSAY "Filial - "+(cZBZ)->&(xZBZ_+"FILIAL")
		nLin ++    
		@nLin,nCol + 00 PSAY cLinCab  
		nLin ++    

		While (cZBZ)->&(xZBZ_+"FILIAL") == cFilProc .And. (cZBZ)->(!EOF())
	
		   	If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
		      	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		      	nLin := nIniLin
		   	Endif
		
			nScan := AScan(aStat, {|x| x[1] == (cZBZ)->&(xZBZ_+"MAIL")}) 
	        If nScan <= 1  
				nScan := 1
			EndIf
			cEspecNf := ""
			If (cZBZ)->&(xZBZ_+"MODELO") =="55"
				cEspecNf := "NF-e"
			ElseIf (cZBZ)->&(xZBZ_+"MODELO") =="65"
				cEspecNf := "NFC-e"	
			ElseIf (cZBZ)->&(xZBZ_+"MODELO") =="RD"
				cEspecNf := "NFS"	
			ElseIf (cZBZ)->&(xZBZ_+"MODELO") =="57"
				cEspecNf := "CT-e"	
			EndIf
					
		    @nLin,nCol + 00 PSAY cEspecNf
			@nLin,nCol + 10 PSAY (cZBZ)->&(xZBZ_+"SERIE")
		    @nLin,nCol + 17 PSAY (cZBZ)->&(xZBZ_+"NOTA")
		    @nLin,nCol + 30 PSAY ConvDate(1 , (cZBZ)->&(xZBZ_+"DTNFE"))
		    @nLin,nCol + 40 PSAY ConvDate(1 , (cZBZ)->&(xZBZ_+"DTRECB"))
		    @nLin,nCol + 50 PSAY aStat[nScan][2]


		   	nLin++  
	
					 
		   (cZBZ)->(DbSkip())
	 	EndDo
		@nLin,00 PSAY Replicate("-",80)
		nLin++
	
	   	If (cZBZ)->(!EOF())
	      	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	      	nLin := nIniLin
	   	Endif
	EndDo
EndIf	
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
Aadd( aHelpPor, "Informe os status que devem ser considerados" )
Aadd( aHelpPor, "separadas por virgulas Ex: 1,3,X,Y" )
Aadd( aHelpPor, "0-Xml Ok (Não envia)" )
Aadd( aHelpPor, "1-Xml com erro (Pendente)" )
Aadd( aHelpPor, "2-Xml com erro (Enviado)" )
Aadd( aHelpPor, "3-Xml cancelado (Pendente)" )
Aadd( aHelpPor, "4-Xml cancelado (Enviado)" )
Aadd( aHelpPor, "X-Falha ao enviar o e-mail (Erro)" )
Aadd( aHelpPor, "Y-Falha ao enviar o e-mail (Cancelamento)" )
U_HFPutSx1(cPerg,"05","Status E-mail   "	,"Status E-mail   "				,"Status E-mail   "				,"mv_ch5","C",20,0,0,"G","",   "","","","mv_par05","","","","","","","","","","","","","","","","",aHelpPor,aHelpPor,aHelpPor)

Return


Static Function __Dummy(lRecursa) //warning W0010 Static Function <?> never called
    lRecursa := .F.
    IF (lRecursa)
        __Dummy(.F.)
        U_HFXMLR02()
	EndIF
Return(lRecursa)
