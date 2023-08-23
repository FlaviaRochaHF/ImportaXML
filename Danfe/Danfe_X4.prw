#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

#DEFINE IMP_SPOOL 2

#DEFINE VBOX       080
#DEFINE VSPACE     008
#DEFINE HSPACE     010
#DEFINE SAYVSPACE  008
#DEFINE SAYHSPACE  008
#DEFINE HMARGEM    030
#DEFINE VMARGEM    030
#DEFINE MAXITEM    022                                                // Máximo de produtos para a primeira página
#DEFINE MAXITEMP2  049                                                // Máximo de produtos para a pagina 2 em diante
#DEFINE MAXITEMP2F 069                                                // Máximo de produtos para a página 2 em diante quando a página não possui informações complementares
#DEFINE MAXITEMP3  025                                                // Máximo de produtos para a pagina 2 em diante (caso utilize a opção de impressao em verso) - Tratamento implementado para atender a legislacao que determina que a segunda pagina de ocupar 50%.
#DEFINE MAXITEMC   038                                                // Máxima de caracteres por linha de produtos/serviços
#DEFINE MAXMENLIN  090                                                // Máximo de caracteres por linha de dados adicionais
#DEFINE MAXMSG     013                                                // Máximo de dados adicionais por página
#DEFINE MAXVALORC  009                                                // Máximo de caracteres por linha de valores numéricos
#DEFINE DMPAPER_A4 009                                                // A4 210 x 297 mm  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Danfe_X   º Autor ³ Raul Seixas        º Data ³  12/09/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Impressao de Danfe Generico                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ XML                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//--------------------------------------------------------------------------//
//Alterações realizadas:
//FR - 01/12/2020 - #Chamado 5808 - Forceline 
//                  Incluir duas novas perguntas:
//                  CNPJ De / CNPJ Até 
//--------------------------------------------------------------------------// 
//FR - 17/12/2021 - #Chamado 11661 - TEBE
//                  Impressão do logotipo do próprio cliente e não pode, precisa
//                  ser o logotipo do fornecedor 
//                  (desde que este exista na pasta system)
//                  Os parâmetros para impressão precisam estar assim:
//					MV_LOGOD (PADRÃO = S)
//                  XM_LOGOD (customizado = N)
//--------------------------------------------------------------------------//
//FR - 07/02/2022 - ALTERAÇÃO ==> ORMEC - Incluir coluna valor desconto 
//                  no modo retrato
//--------------------------------------------------------------------------//
//FR - 31/03/2022 - PROJETO KITCHENS - IMPRESSÃO DANFE PDF para anexar 
//                  ao pedido compra
//-----------------------------------------------------------------------------------//


User Function Danfe_X4(lAuto,oNota,cIdEnt,cVal1,cVal2,oDanfe,oSetup,cFilePrint,lAutoDanfe)

Local aArea     := GetArea()
Local lExistNfe := .T.
Local aPergs    := {}
//FR - 27/09/2021
Local cFilDe    := Space(6)
Local cFilAte   := Space(6)
Local aTiponf   := {}
Local cTiponf   := Space(1)
Local cFlagxml  := Space(1)						//FR - 06/10/2021
Local aFlagxml  := {}							//FR - 06/10/2021
Local cNotaDe   := SPACE(TamSX3('D1_DOC')[01])
Local cNotaAt   := SPACE(TamSX3('D1_DOC')[01])
Local dDataDe   := CTOD(SPACE(8))
Local dDataAt   := CTOD(SPACE(8))
Local cQuery    := ""
Local cAliasZBZ := GetNextAlias()
Local cPasta    := iif( Type("oSetup:AopTions") == "U", oSetup:AopTions[6], GetTempPath()) //Diretorio de impressão
Local cArquivo  := ""
Local lImprimi  := .F. 
Local cCNPJDe   := SPACE(TamSX3('A2_CGC')[01])	//FR - 01/12/2020
Local cCNPJAt   := SPACE(TamSX3('A2_CGC')[01])	//FR - 01/12/2020  
Local lPergunta := .T.							//FR - 31/03/2022 - PROJETO KITCHENS - anexar automaticamente o arquivo danfe
Local lImpLote  := .F.							//FR - 31/03/2022 - PROJETO KITCHENS - anexar automaticamente o arquivo danfe
Local cDirDanfe := ""							//FR - 31/03/2022 - PROJETO KITCHENS

Private nConsNeg := 0.4 // Constante para concertar o cálculo retornado pelo GetTextWidth para fontes em negrito.
Private nConsTex := 0.5 // Constante para concertar o cálculo retornado pelo GetTextWidth.
Private PixelX   := odanfe:nLogPixelX()
Private PixelY   := odanfe:nLogPixelY()
Private oRetNf   := nil 
Private nColAux   

//N=Normal;D=Devolucao;B=Beneficiamento;C=Complemento Preco/Frete;I=Comp. ICMS;P=Comp. IPI                                        
aAdd( aTiponf, "N=Normal" )
aAdd( aTiponf, "D=Devolução" )
aAdd( aTiponf, "C=Compl.Preço" )
aAdd( aTiponf, "I=Compl.ICMS" )
aAdd( aTiponf, "P=Compl.IPI" )
aAdd( aTiponf, "T=Todos" )

aFlagxml	:= {}							//FR - 06/10/2021
cFlagxml	:= ""

aAdd( aFlagxml, "B=Importado" 				)
aAdd( aFlagxml, "A=Aviso Recbto Carga"		)
aAdd( aFlagxml, "S=Pre-Nota a Classificar"	)
aAdd( aFlagxml, "N=Pre-Nota Classificada"	)
aAdd( aFlagxml, "F=Falha de Importacao"		)
aAdd( aFlagxml, "X=Xml Cancelado"			)
aAdd( aFlagxml, "Z=Xml Rejeitado"			)
aAdd( aFlagxml, "D=Denegada"				)
aAdd( aFlagxml, "T=Todos" 					)

If lAutoDanfe <> Nil 
	If lAutoDanfe
		lPergunta := .F.
	Endif 
Endif 

If lPergunta
	If MsgYesNo( 'Deseja imprimir em lote ?', 'Impressão Xml' ) 
		lImpLote := .T.
	Endif
Endif  

If lImpLote  //se imprime em lote

	aAdd(aPergs, {1, "Nota De",  cNotaDe,  "",             ".T.",        "",    ".T.", 80,  .F.})
	aAdd(aPergs, {1, "Nota Até", cNotaAt,  "",             ".T.",        "",    ".T.", 80,  .T.})
	aAdd(aPergs, {1, "Data De",  dDataDe,  "",             ".T.",        "",    ".T.", 80,  .F.})
	aAdd(aPergs, {1, "Data Até", dDataAt,  "",             ".T.",        "",    ".T.", 80,  .T.})
	//FR - 01/12/2020
	aAdd(aPergs, {1, "CNPJ De",  cCNPJDe,  "",             ".T.",        "",    ".T.", 80,  .F.})
	aAdd(aPergs, {1, "CNPJ Até", cCNPJAt,  "",             ".T.",        "",    ".T.", 80,  .T.})
	//FR - 01/12/2020

	//FR - 27/09/2021	
	aAdd(aPergs, {1,"Filial Inicial"	,cFilDe		,  ""		,".T."	,"SM0"	,".T."	, 80	,  .F.	})
	aAdd(aPergs, {1,"Filial Final"		,cFilAte	,  ""		,".T."	,"SM0"	,".T."	, 80	,  .F.	})
	aadd(aPergs, {2,"Tipo NF"         	,cTiponf   	,aTiponf	,100	,".T."	,.T.,".T."	})
    
    //FR - 06/10/2021
	aadd(aPergs, {2,"Flag XML"         	,cFlagxml  	,aFlagxml	,100	,".T."	,.T.,".T."	})
	If ParamBox(aPergs, "Parametros de impressão em lote")
		//FR - 01/12/2020
		cQuery := " SELECT ZBZ.R_E_C_N_O_ , " 
		cQuery += " ZBZ."+xZBZ_+"NOTA, " 												 
		cQuery += " ZBZ."+xZBZ_+"CNPJ "
		cQuery += " FROM " + RetSqlName(xZBZ) + " ZBZ "
		cQuery += " WHERE "
		cQuery += " ZBZ.D_E_L_E_T_ <> '*' "
		cQuery += " AND ZBZ."+xZBZ_+"NOTA BETWEEN '"+Mv_Par01+"' AND '"+Mv_Par02+"' "
		cQuery += " AND ZBZ."+xZBZ_+"TPDOWL <> 'R' "
		cQuery += " AND ZBZ."+xZBZ_+"DTNFE BETWEEN '"+DTOS(Mv_Par03)+"' AND '"+DTOS(Mv_Par04)+"' " 
		cQuery += " AND ZBZ."+xZBZ_+"MODELO = '55' "
		cQuery += " AND ZBZ."+xZBZ_+"PRENF IN ('B','A','S','N') "		
		cQuery += " AND ZBZ."+xZBZ_+"CNPJ   BETWEEN '"+ Alltrim(MV_PAR05) + "' AND '"+ Alltrim(MV_PAR06)+ "' "                   
		//FR - 27/09/2021
		cQuery += " AND ZBZ."+xZBZ_+"FILIAL BETWEEN '"+ Alltrim(MV_PAR07) + "' AND '"+ Alltrim(MV_PAR08)+ "' "
		
		If MV_PAR09 <> "T" 
			cQuery += " AND ZBZ."+xZBZ_+"TPDOC = '" + MV_PAR09 + "' "		
		Endif
		
		If MV_PAR10 <> "T"   //flag xml
			cQuery += " AND ZBZ."+xZBZ_+"PRENF = '" + Alltrim(MV_PAR10) + "' "		
		Endif 
		cQuery += " ORDER BY ZBZ."+xZBZ_+"FILIAL, ZBZ."+xZBZ_+"NOTA "											
		//FR - 01/12/2020
		cQuery := ChangeQuery( cQuery )
		
		MemoWrite("C:\TEMP\danfe_x4.sql" , cQuery) //FR - 01/12/2020

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasZBZ)

		DbSelectArea(cAliasZBZ)

		If !(cAliasZBZ)->(Eof())
			While !(cAliasZBZ)->(Eof())
	
				//Posiciona no registro da ZBZ
				DbSelectArea(xZBZ)
				DbGoTo( (cAliasZBZ)->R_E_C_N_O_ ) 
				
				//Se o último caracter da pasta não for barra, será barra para integridade
				If SubStr(cPasta, Len(cPasta), 1) != "\"
					cPasta += "\"
				EndIf
				
				//Gera o XML da Nota
				cArquivo := "DANFE_"+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA")))+cIdEnt+Dtos(MSDate())+StrTran(Time(),":","")
				
				//Define as perguntas da DANFE
				//Pergunte("NFSIGW",.F.)
				MV_PAR01 := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA")))           //PadR(cNota,  nTamNota)     //Nota Inicial
				MV_PAR02 := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA")))           //Nota Final
				MV_PAR03 := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE")))          //Série da Nota
				//MV_PAR04 := 2                        //NF de Saida
				MV_PAR05 := 0                          //Frente e Verso = Sim
				//MV_PAR06 := 2                        //DANFE simplificado = Nao
				
				//Cria a Danfe
				oDanfe := FWMSPrinter():New(cArquivo, IMP_PDF, .F., , .T.)
				
				//Propriedades da DANFE
				oDanfe:SetResolution(78)
				oDanfe:SetPortrait()
				oDanfe:SetPaperSize(DMPAPER_A4)
				oDanfe:SetMargin(60, 60, 60, 60)
				
				//Força a impressão em PDF
				oDanfe:nDevice  := 6
				oDanfe:cPathPDF := cPasta                
				oDanfe:lServer  := .F.
				oDanfe:lViewPDF := .F.
				
				//Variáveis obrigatórias da DANFE (pode colocar outras abaixo)
				PixelX    := oDanfe:nLogPixelX()
				PixelY    := oDanfe:nLogPixelY()
				nConsNeg  := 0.4
				nConsTex  := 0.5
				oRetNF    := Nil
				nColAux   := 0
	
				if oNota == NIL
	
					cError := ""
					cWarning := ""
	
					oNota := XmlParser((xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML"))), "_", @cError, @cWarning )
					
					if oNota == NIL
	
						cXml  := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML")))
						cError := ""
						cWarning := ""
						oNota := U_PARSGDE( cXml, @cError, @cWarning )
	
					endif
					
				Endif
	
				if oNota == NIL
					Aviso("DANFE","Não foi possivel ler o XML, refaça a importação",{"OK"},3)
					Return( .T. )
				endif
	
				//Chamando a impressão da danfe no RDMAKE
				//RptStatus({|lEnd| StaticCall(DANFE_X4, DanfeProc, @oDanfe, @lEnd, cIdent, , , .F.)}, "Imprimindo Danfe...")
				RptStatus({|lEnd| DanfeProc(lAuto,oNota,@oDanfe,@lEnd,cIdEnt,,,@lExistNfe)},"Imprimindo Danfe...")
				
				oDanfe:Print()
	
				lImprimi := .T. 
	
				oNota := nil
				oDanfe := Nil
	
				(cAliasZBZ)->(DbSkip())
	
			Enddo
        Else
        	//não foram encontrados dados para os parâmetros fornecidos
        	Aviso("DANFE","Não Há Dados Para Os Parâmetros Fornecidos",{"OK"},3)
        Endif
        //FR - 01/12/2020
        
		FreeObj(oDanfe)
		FreeObj(oNota)

		(cAliasZBZ)->( DbCloseArea() )

		if lImprimi

			Msginfo("Nota(s) gerada(s) com sucesso")

		endif

	endif

else
	
	if oNota == NIL

		cError := ""
		cWarning := ""

		oNota := XmlParser((xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML"))), "_", @cError, @cWarning )
		
		if oNota == NIL

			cXml  := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML")))
			cError := ""
			cWarning := ""
			oNota := U_PARSGDE( cXml, @cError, @cWarning )

		endif
		
	Endif

	if oNota == NIL
		Aviso("DANFE","Não foi possivel ler o XML, refaça a importação",{"OK"},3)
		Return( .T. )
	endif

	MV_PAR01:= "000000000"
	MV_PAR02:= "999999999"
	MV_PAR05:= 0

	oDanfe:SetResolution(78) //Tamanho estipulado para a Danfe
	oDanfe:SetPortrait()
	oDanfe:SetPaperSize(DMPAPER_A4)
	oDanfe:SetMargin(60,60,60,60)
	oDanfe:lServer := oSetup:GetProperty(PD_DESTINATION)==AMB_SERVER
    cAux := ""
    nPos := 0

	// ----------------------------------------------
	// Define saida de impressão
	// ----------------------------------------------
	If oSetup:GetProperty(PD_PRINTTYPE) == IMP_SPOOL

		oDanfe:nDevice := IMP_SPOOL
		// ----------------------------------------------
		// Salva impressora selecionada
		// ----------------------------------------------
		WriteProfString(GetPrinterSession(),"DEFAULT", oSetup:aOptions[PD_VALUETYPE], .T.)
		oDanfe:cPrinter := oSetup:aOptions[PD_VALUETYPE]

	ElseIf oSetup:GetProperty(PD_PRINTTYPE) == IMP_PDF

		oDanfe:nDevice := IMP_PDF
		// ----------------------------------------------
		// Define para salvar o PDF
		// ----------------------------------------------
		oDanfe:cPathPDF := oSetup:aOptions[PD_VALUETYPE]
        If lAutoDanfe
        	cAux            := oSetup:aOptions[PD_VALUETYPE] 
        	nPos            := RAT("\", cAux)          //D:\SPOOL\DANFE_20220404.PDF
			cDirDanfe       := Substr(cAux,1,nPos)  
		Endif 
	Endif

	PixelX := odanfe:nLogPixelX()
	PixelY := odanfe:nLogPixelY()

	If !lAutoDanfe
		RptStatus({|lEnd| DanfeProc(lAuto,oNota,@oDanfe,@lEnd,cIdEnt,,,@lExistNfe)},"Imprimindo Danfe...")
	
		If lExistNfe
			oDanfe:Preview()  //Visualiza antes de imprimir			
		Else
			Aviso("DANFE","Nenhuma NF-e a ser impressa nos parametros utilizados.",{"OK"},3)
		EndIf
	Else
	    //lAutoDanfe := .T.
		//qdo a chamada for via botão "gera pedido compra" anexa o danfe no bco conhecimento
		DanfeProc(lAuto,oNota,@oDanfe,@lEnd,cIdEnt,,,@lExistNfe)  
	    oDanfe:lViewpdf := .F.	//para não explodir na tela o pdf gerado, pois é só pra anexar ao banco conhecimento (ACB, AC9)	

	    oDanfe:Print()	//aqui gera o pdf de fato   
		
	Endif 

	FreeObj(oDanfe)
	oDanfe := Nil

endif

RestArea(aArea)

Return(.T.)



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DANFEProc ³ Autor ³ Eduardo Riera         ³ Data ³16.11.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rdmake de exemplo para impressão da DANFE no formato Retrato³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto grafico de impressao                    (OPC) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function DanfeProc(lAuto,oNfe,oDanfe,lEnd,cIdEnt,cVal1,cVal2,lExistNfe)

Local aArea      := GetArea()
Local aAreaSF3   := {}
Local aNotas     := {}
Local aXML       := {}
Local aAutoriza  := {}
Local cNaoAut    := ""
Local cAliasSF3  := "SF3"
Local cWhere     := ""
Local cAviso     := ""
//Local cCodRetNFE := "";Local cCodRetSF3 := "";Local cMsgSF3    := ""
Local cErro      := ""
Local cAutoriza  := ""
Local cModalidade:= ""
Local cChaveSFT  := ""
Local cAliasSFT  := "SFT"
Local cCondicao	 := ""
Local cIndex	 := ""
Local cChave	 := "", cChaveSF3  := "" 
Local oNfeDPEC
Local cCodAutDPEC:= ""
Local cDtHrRecCab:= ""
Local dDtReceb   := ""
Local aNota      := {}
Local lQuery     := .F.

Local nX         := 0
Local nI		 := 0

Local oNfe
Local nLenNotas
Local lImpDir	 :=GetNewPar("MV_IMPDIR",.F.)
Local nLenarray	 := 0
Local nCursor	 := 0
Local lBreak	 := .F.
Local aGrvSF3    := {}

//aXml := GetXML(cIdEnt,aNotas,@cModalidade)

ImpDet(lAuto,@oDanfe,oNFe,cAutoriza,cModalidade,oNfeDPEC,cCodAutDPEC,cDtHrRecCab,dDtReceb,aNota)

Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ ImpDet   ³ Autor ³ Eduardo Riera         ³ Data ³16.11.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Controle de Fluxo do Relatorio.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto grafico de impressao                    (OPC) ³±±
±±³          ³ExpC2: String com o XML da NFe                              ³±±
±±³          ³ExpC3: Codigo de Autorizacao do fiscal                (OPC) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/ //Static Function ImpDet(oDanfe,oNfe,cCodAutSef,cModalidade,oNfeDPEC,cCodAutDPEC,cDtHrRecCab,dDtReceb,aNota,lImpSimp)
Static Function ImpDet(lAuto,oDanfe,oNfe,cCodAutSef,cModalidade,oNfeDPEC,cCodAutDPEC,cDtHrRecCab,dDtReceb,aNota,lImpSimp)

PRIVATE oFont10N   := TFontEx():New(oDanfe,"Times New Roman",08,08,.T.,.T.,.F.)// 1
PRIVATE oFont07N   := TFontEx():New(oDanfe,"Times New Roman",06,06,.T.,.T.,.F.)// 2
PRIVATE oFont07    := TFontEx():New(oDanfe,"Times New Roman",06,06,.F.,.T.,.F.)// 3
PRIVATE oFont08    := TFontEx():New(oDanfe,"Times New Roman",07,07,.F.,.T.,.F.)// 4
PRIVATE oFont08N   := TFontEx():New(oDanfe,"Times New Roman",06,06,.T.,.T.,.F.)// 5
PRIVATE oFont09N   := TFontEx():New(oDanfe,"Times New Roman",08,08,.T.,.T.,.F.)// 6
PRIVATE oFont09    := TFontEx():New(oDanfe,"Times New Roman",08,08,.F.,.T.,.F.)// 7
PRIVATE oFont10    := TFontEx():New(oDanfe,"Times New Roman",09,09,.F.,.T.,.F.)// 8
PRIVATE oFont11    := TFontEx():New(oDanfe,"Times New Roman",10,10,.F.,.T.,.F.)// 9
PRIVATE oFont12    := TFontEx():New(oDanfe,"Times New Roman",11,11,.F.,.T.,.F.)// 10
PRIVATE oFont11N   := TFontEx():New(oDanfe,"Times New Roman",10,10,.T.,.T.,.F.)// 11
PRIVATE oFont18N   := TFontEx():New(oDanfe,"Times New Roman",17,17,.T.,.T.,.F.)// 12 
PRIVATE OFONT12N   := TFontEx():New(oDanfe,"Times New Roman",11,11,.T.,.T.,.F.)// 12 
PRIVATE lUsaColab	  :=  .F.

Static lImpSimp   := .F.

PrtDanfe(lAuto,@oDanfe,oNfe,cCodAutSef,cModalidade,oNfeDPEC,cCodAutDPEC,cDtHrRecCab,dDtReceb,aNota)

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PrtDanfe  ³ Autor ³Eduardo Riera          ³ Data ³16.11.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressao do formulario DANFE grafico conforme laytout no   ³±±
±±³          ³formato retrato                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PrtDanfe()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto grafico de impressao                          ³±±
±±³          ³ExpO2: Objeto da NFe                                        ³±±
±±³          ³ExpC3: Codigo de Autorizacao do fiscal                (OPC) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//Static Function PrtDanfe(lAuto,oDanfe,oNFE,cCodAutSef,cModalidade,oNfeDPEC,cCodAutDPEC,cDtHrRecCab,dDtReceb,aNota)
Static Function PrtDanfe(lAuto,oDanfe,oNota,cCodAutSef,cModalidade,oNfeDPEC,cCodAutDPEC,cDtHrRecCab,dDtReceb,aNota)
Local aAuxCabec     := {} // Array que conterá as strings de cabeçalho das colunas de produtos/serviços.
Local aTamanho      := {}
Local aTamCol       := {} // Array que conterá o tamanho das colunas dos produtos/serviços.
Local aSitTrib      := {}
Local aSitSN        := {}
Local aTransp       := {}
Local aDest         := {}
Local aHrEnt        := {}
Local aFaturas      := {}
Local aItens        := {}
Local aISSQN        := {}
Local aSimpNac		:= {}
Local aTotais       := {}
Local aAux          := {}
Local aUF           := {}
Local aMensagem     := {}
Local aEspVol       := {}
Local aResFisco     := {} 
Local aEspecie      := {}
Local aIndImp	    := {}
Local aIndAux	    := {} 
Local aLote         := {}

Local nHPage        := 0
Local nVPage        := 0
Local nPosV         := 0
Local nPosVOld      := 0
Local nPosH         := 0
Local nPosHOld      := 0
Local nAuxH         := 0
Local nAuxH2        := 0
Local nAuxV         := 0
Local nSnBaseIcm	 := 0
Local nSnValIcm    := 0
Local nDetImp		 := 0
Local nS			 := 0
Local nX            := 0
Local nY            := 0
Local nL            := 0
Local nJ            := 0
Local nW            := 0
Local nTamanho      := 0
Local nFolha        := 1
Local nFolhas       := 0
Local nItem         := 0
Local nMensagem     := 0
Local nBaseICM      := 0
Local nValICM       := 0
Local nValIPI       := 0
Local nPICM         := 0
Local nPIPI         := 0
Local nFaturas      := 0
Local nVTotal       := 0
Local nQtd          := 0
Local nVUnit        := 0
Local nVolume	    := 0
Local nLenFatura
Local nLenVol
Local nLenDet
Local nLenSit
Local nLenItens     := 0
Local nLenMensagens := 0
Local nLen          := 0
Local nColuna	    := 0
Local nLinSum	    := 0
Local nRecSF3		:= 0
Local nE		    := 0
Local nPag
Local nItensRes
Local nSoma       
Local nZ		    := 0 
Local nMaxCod	    := 10
Local nMaxDes	    := 30  //MAXITEMC //FR - 18/05/2022 - #12764 - PORTAL SOLAR - qtde máxima de caracteres que comporta a descrição do produto
Local nLinhavers    := 0
Local nMaxItemP2    := MAXITEM // Variável utilizada para tratamento de quantos itens devem ser impressos na página corrente 

Local cAux          := ""
Local cSitTrib      := ""
Local cUF		 	:= ""  
Local cMVCODREG		:= Alltrim( SuperGetMV("MV_CODREG", ," ") )
Local cChaveCont 	:= ""
Local cLogo      	:= FisxLogo("1")
Local cGuarda       := ""  
Local cEsp		    := "" 
Local lMv_Logod     := If( GetNewPar("MV_LOGOD", "N" ) == "S", .T., .F. ) //.F.
Local cLogoD	    := ""
local cEndDest      := ""
local cLogoTotvs 	:= "Powered_by_TOTVS.bmp"
local cStartPath 	:= GetSrvProfString("Startpath","")

Local lPreview      := .F.
Local lFlag         := .T.
Local lConverte     := GetNewPar("MV_CONVERT",.F.)
Local lImpAnfav     := GetNewPar("MV_IMPANF",.F.)
Local lImpInfAd   	:= GetNewPar("MV_IMPADIC",.F.)  //IMPRIME no box de informações adicionais (ex. descrição completa do produto)
Local lImpSimpN		:= .F.
Local lPagPar
Local lMv_Logod     := If(GetNewPar("MV_LOGOD", "N" ) == "S", .T., .F.   )
Local lMv_ItDesc    := Iif( GetNewPar("MV_ITDESC","N")=="S", .T., .F. )
Local lNFori2 	    := .T.
Local lFimpar	    := .T. 	                     
Local lCompleECF    := .F.
Local lEntIpiDev   	:= GetNewPar("MV_EIPIDEV",.F.) /*Apenas para nota de entrada de Devolução de ipi. .T.-Séra destacado no cabeçalho + inf.compl/.F.-Será destacado apenas em inf.compl*/
Local cDhCont		:= ""
Local cXJust		:= ""

Local cDescLogo		:= ""
Local cGrpCompany	:= ""
Local cCodEmpGrp	:= ""
Local cUnitGrp		:= ""
Local cFilGrp		:= ""

Local lPontilhado	:= .F.

Local aAuxCom		:= {}
Local cUnCom		:= ""
Local nQtdCom		:= 0
Local nVUnitCom		:= 0
Local cX_ESTADO     := HFVerEst(oNota)
//HF ver se o Emissore é MG 
Local lUf_MG		:= (cX_ESTADO $ "MG") //( SuperGetMv("MV_ESTADO") $ "MG" )	// Criado esta variavel para atender o RICMS de MG para totalizar por CFOP
Local nSequencia	:= 0
Local nSubTotal		:= 0
Local cCfop			:= ""
Local cCfopAnt		:= ""
Local aItensAux     := {}
Local aArray		:= {}  
Local nVDesc		:= 0 		//FR - 07/02/2022 - ORMEC - Incluir coluna valor desconto no modo retrato 

Private oNFe      := oNota:_NFEPROC  //HF
Private aInfNf    := {}
Private oDPEC     := oNfeDPEC
Private oNF       := oNFe:_NFe
Private oEmitente := oNF:_InfNfe:_Emit
Private oIdent    := oNF:_InfNfe:_IDE
Private oDestino  := oNF:_InfNfe:_Dest
Private oTotal    := oNF:_InfNfe:_Total
Private oTransp   := oNF:_InfNfe:_Transp
Private oDet      := oNF:_InfNfe:_Det
Private oFatura   := IIf(Type("oNF:_InfNfe:_Cobr")=="U",Nil,oNF:_InfNfe:_Cobr)
Private oImposto
Private nPrivate  := 0
Private nPrivate2 := 0
Private nXAux	  := 0
Private lArt488MG := .F.
Private lArt274SP := .F. 

Private oPDF
Private n := 0
PRIVATE lAdjustToLegacy := .F.
PRIVATE lDisableSetup  := .T.
Private cNomePDF:= "rel.pdf" 

Private cImpSTNaDesc:= ""
Private	cInfoIST 	:= ""
Private cInfoIST1   := ""
Private cInfoIST2   := "" 
Private cInfoIST3   := ""
Private	cTagAux		:= ""
Private	_ICMSTBas   := ""
Private	_ICMSTAlq   := ""
Private	_ICMSTVal   := ""

Static lAuto := .F.    //FR - 04/04/2022 - 
Static cDtHrRecCab := ""
Static dDtReceb    := CToD("")

if Type( "oNF:_InfNfe:_Cobr:_Dup" ) <> "U"
	nFaturas := IIf(oFatura<>Nil,IIf(ValType(oNF:_InfNfe:_Cobr:_Dup)=="A",Len(oNF:_InfNfe:_Cobr:_Dup),1),0)
Else
	nFaturas := 0
Endif
oDet := IIf(ValType(oDet)=="O",{oDet},oDet)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega as variaveis de impressao                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aadd(aSitTrib,"00")
aadd(aSitTrib,"10")
aadd(aSitTrib,"20")
aadd(aSitTrib,"30")
aadd(aSitTrib,"40")
aadd(aSitTrib,"41")
aadd(aSitTrib,"50")
aadd(aSitTrib,"51")
aadd(aSitTrib,"60")
aadd(aSitTrib,"70")
aadd(aSitTrib,"90")
aadd(aSitTrib,"PART")

aadd(aSitSN,"101")
aadd(aSitSN,"102")
aadd(aSitSN,"201")
aadd(aSitSN,"202")
aadd(aSitSN,"500")
aadd(aSitSN,"900")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro Destinatario                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cEndDest := NoChar(oDestino:_EnderDest:_Xlgr:Text,lConverte)
If  " SN" $ (UPPER (oDestino:_EnderDest:_Xlgr:Text)) .Or. ",SN" $ (UPPER (oDestino:_EnderDest:_Xlgr:Text)) .Or. ;
    "S/N" $ (UPPER (oDestino:_EnderDest:_Xlgr:Text)) 
   
            cEndDest += IIf(Type("oDestino:_EnderDest:_xcpl")=="U","",", " + NoChar(oDestino:_EnderDest:_xcpl:Text,lConverte))
Else
            cEndDest += +","+NoChar(oDestino:_EnderDest:_NRO:Text,lConverte) + IIf(Type("oDestino:_EnderDest:_xcpl")=="U","",", "+ NoChar(oDestino:_EnderDest:_xcpl:Text,lConverte))
Endif   

aDest := {cEndDest,;
NoChar(oDestino:_EnderDest:_XBairro:Text,lConverte),;
IIF(Type("oDestino:_EnderDest:_Cep")=="U","",Transform(oDestino:_EnderDest:_Cep:Text,"@r 99999-999")),;
IIF(oNF:_INFNFE:_VERSAO:TEXT >= "3.10",IIF(Type("oIdent:_DHSaiEnt")=="U","",oIdent:_DHSaiEnt:Text),IIF(Type("oIdent:_DSaiEnt")=="U","",oIdent:_DSaiEnt:Text)),;
oDestino:_EnderDest:_XMun:Text,;
IIF(Type("oDestino:_EnderDest:_fone")=="U","",oDestino:_EnderDest:_fone:Text),;
oDestino:_EnderDest:_UF:Text,;
IIF(Type("oDestino:_IE")=="U","",oDestino:_IE:Text),;
""}

If oNF:_INFNFE:_VERSAO:TEXT >= "3.10"
	aadd(aHrEnt,IIF(Type("oIdent:_dhSaiEnt")=="U","",SubStr(oIdent:_dhSaiEnt:TEXT,12,8)))
Else
	If Type("oIdent:_DSaiEnt")<>"U" .And. Type("oIdent:_HSaiEnt:Text")<>"U"
		aAdd(aHrEnt,oIdent:_HSaiEnt:Text)
	Else
		aAdd(aHrEnt,"")
	EndIf	
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calculo do Imposto                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTotais := {"","","","","","","","","","",""}
aTotais[01] := Transform(Val(oTotal:_ICMSTOT:_vBC:TEXT),"@e 9,999,999,999,999.99")
aTotais[02] := Transform(Val(oTotal:_ICMSTOT:_vICMS:TEXT),"@e 9,999,999,999,999.99")
aTotais[03] := Transform(Val(oTotal:_ICMSTOT:_vBCST:TEXT),"@e 9,999,999,999,999.99")
aTotais[04] := Transform(Val(oTotal:_ICMSTOT:_vST:TEXT),"@e 9,999,999,999,999.99")
//HF - Aguas do Brasil
if Type( "oTotal:_ICMSTOT:_vFCPST:TEXT" ) <> "U"
	aTotais[04] := Transform(Val(oTotal:_ICMSTOT:_vST:TEXT)+Val(oTotal:_ICMSTOT:_vFCPST:TEXT),"@e 9,999,999,999,999.99")
Endif
//HF - Fim Aguas do Brasiule
aTotais[05] := Transform(Val(oTotal:_ICMSTOT:_vProd:TEXT),"@e 9,999,999,999,999.99")
aTotais[06] := Transform(Val(oTotal:_ICMSTOT:_vFrete:TEXT),"@e 9,999,999,999,999.99")
aTotais[07] := Transform(Val(oTotal:_ICMSTOT:_vSeg:TEXT),"@e 9,999,999,999,999.99")
aTotais[08] := Transform(Val(oTotal:_ICMSTOT:_vDesc:TEXT),"@e 9,999,999,999,999.99")
aTotais[09] := Transform(Val(oTotal:_ICMSTOT:_vOutro:TEXT),"@e 9,999,999,999,999.99")

aTotais[10] := 	Transform(Val(oTotal:_ICMSTOT:_vIPI:TEXT),"@e 9,999,999,999,999.99")

aTotais[11] := 	Transform(Val(oTotal:_ICMSTOT:_vNF:TEXT),"@e 9,999,999,999,999.99")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Impressão da Base de Calculo e ICMS nos campo Proprios do ICMS quando optante pelo Simples Nacional    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 
If lImpSimpN   

	nDetImp := Len(oDet)
	nS := nDetImp 
	aSimpNac := {"",""}

	    if Type("oDet["+Alltrim(Str(nS))+"]:_IMPOSTO:_ICMS:_ICMSSN101:_VCREDICMSSN:TEXT") <> "U"
	    	SF3->(dbSetOrder(5))
	
			if SF3->(MsSeek(xFilial("SF3")+aNota[4]+aNota[5]))
				while SF3->(!eof()) .and. ( SF3->F3_SERIE + SF3->F3_NFISCAL  == aNota[4] + aNota[5] )
					nSnBaseIcm += (SF3->F3_BASEICM)
					nSnValIcm  += (SF3->F3_VALICM)
					SF3->(dbSkip())
				end 
		   	endif
		    		    	
	    elseif Type("oDet["+Alltrim(Str(nS))+"]:_IMPOSTO:_ICMS:_ICMSSN900:_VCREDICMSSN:TEXT") <> "U"
			nS:= 0	    
	    	For nS := 1 To nDetImp 
	    		If Type("oDet["+Alltrim(Str(nS))+"]:_IMPOSTO:_ICMS:_ICMSSN900:_VBC:TEXT") <> "U"
	 				nSnBaseIcm += Val(oDet[nS]:_IMPOSTO:_ICMS:_ICMSSN900:_VBC:TEXT)
				EndIf			
				If Type("oDet["+Alltrim(Str(nS))+"]:_IMPOSTO:_ICMS:_ICMSSN900:_VCREDICMSSN:TEXT") <> "U"
					nSnValIcm  += Val(oDet[nS]:_IMPOSTO:_ICMS:_ICMSSN900:_VCREDICMSSN:TEXT)
				EndIf				
			Next nS
			
	    endif
    	    
	   	aSimpNac[01] := Transform((nSnBaseIcm),"@e 9,999,999,999,999.99")
		aSimpNac[02] := Transform((nSnValIcm),"@e 9,999,999,999,999.99")
    
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro Faturas                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nFaturas > 0
	For nX := 1 To 3
		aAux := {}
		For nY := 1 To Min(9, nFaturas)
			Do Case
				Case nX == 1
					If nFaturas > 1
						AAdd(aAux, AllTrim(oFatura:_Dup[nY]:_nDup:TEXT))
					Else
						AAdd(aAux, AllTrim(oFatura:_Dup:_nDup:TEXT))
					EndIf
				Case nX == 2
					If nFaturas > 1
						AAdd(aAux, AllTrim(ConvDate(oFatura:_Dup[nY]:_dVenc:TEXT)))
					Else
						AAdd(aAux, AllTrim(ConvDate(oFatura:_Dup:_dVenc:TEXT)))
					EndIf
				Case nX == 3
					If nFaturas > 1
						AAdd(aAux, AllTrim(TransForm(Val(oFatura:_Dup[nY]:_vDup:TEXT), "@E 9,999,999,999,999.99")))
					Else
						AAdd(aAux, AllTrim(TransForm(Val(oFatura:_Dup:_vDup:TEXT), "@E 9,999,999,999,999.99")))
					EndIf
			EndCase
		Next nY
		If nY <= 9
			For nY := 1 To 9
				AAdd(aAux, Space(20))
			Next nY
		EndIf
		AAdd(aFaturas, aAux)
	Next nX
Elseif Type("oNF:_InfNfe:_Pag") <> "U"  //HF -> aguas do braziu
	aTpg := {}
	aadd(aTpg, {"01","Dinheiro"})
	aadd(aTpg, {"02","Cheque"})
	aadd(aTpg, {"03","Cartão de Crédito"})
	aadd(aTpg, {"04","Cartão de Débito"})
	aadd(aTpg, {"05","Crédito Loja"})
	aadd(aTpg, {"10","Vale Alimentação"})
	aadd(aTpg, {"11","Vale Refeição"})
	aadd(aTpg, {"12","Vale Presente"})
	aadd(aTpg, {"13","Vale Combustível"})
	aadd(aTpg, {"14","Duplicata Mercantil"})
	aadd(aTpg, {"99","Outros"})
	oFatura  := oNF:_InfNfe:_Pag
	nFaturas := IIf(oFatura<>Nil,IIf(ValType(oNF:_InfNfe:_Pag:_DetPag)=="A",Len(oNF:_InfNfe:_Pag:_DetPag),1),0)
	For nX := 1 To 3
		aAux := {}
		For nY := 1 To Min(9, nFaturas)
			Do Case
				Case nX == 1
					If nFaturas > 1
						AAdd(aAux, "Forma "+AllTrim(oFatura:_DetPag[nY]:_tPag:TEXT))
					Else
						AAdd(aAux, "Forma "+AllTrim(oFatura:_DetPag:_tPag:TEXT))
					EndIf
				Case nX == 2
					nTpg := 0
					If nFaturas > 1
						nTpg := aScan( aTpg, {|x| x[1] == oFatura:_DetPag[nY]:_tPag:TEXT } )
					Else
						nTpg := aScan( aTpg, {|x| x[1] == oFatura:_DetPag:_tPag:TEXT } )
					EndIf
					If nTpg > 0
						AAdd(aAux, AllTrim(aTpg[nTpg][2]))
					EndIF
				Case nX == 3
					If nFaturas > 1
						AAdd(aAux, AllTrim(TransForm(Val(oFatura:_DetPag[nY]:_VPag:TEXT), "@E 9,999,999,999,999.99")))
					Else
						AAdd(aAux, AllTrim(TransForm(Val(oFatura:_DetPag:_vPag:TEXT), "@E 9,999,999,999,999.99")))
					EndIf
			EndCase
		Next nY
		If nY <= 9
			For nY := 1 To 9
				AAdd(aAux, Space(20))
			Next nY
		EndIf
		AAdd(aFaturas, aAux)
	Next nX
EndIf  //HF Fim Agoa du Bazio

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro transportadora                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTransp := {"","0","","","","","","","","","","","","","",""}

If Type("oTransp:_ModFrete")<>"U"
	aTransp[02] := IIF(Type("oTransp:_ModFrete:TEXT")<>"U",oTransp:_ModFrete:TEXT,"0")
EndIf
If Type("oTransp:_Transporta")<>"U"
	aTransp[01] := IIf(Type("oTransp:_Transporta:_xNome:TEXT")<>"U",NoChar(oTransp:_Transporta:_xNome:TEXT,lConverte),"")
	//	aTransp[02] := IIF(Type("oTransp:_ModFrete:TEXT")<>"U",oTransp:_ModFrete:TEXT,"0")
	aTransp[03] := IIf(Type("oTransp:_VeicTransp:_RNTC")=="U","",oTransp:_VeicTransp:_RNTC:TEXT)
	aTransp[04] := IIf(Type("oTransp:_VeicTransp:_Placa:TEXT")<>"U",oTransp:_VeicTransp:_Placa:TEXT,"")
	aTransp[05] := IIf(Type("oTransp:_VeicTransp:_UF:TEXT")<>"U",oTransp:_VeicTransp:_UF:TEXT,"")
	If Type("oTransp:_Transporta:_CNPJ:TEXT")<>"U"
		aTransp[06] := Transform(oTransp:_Transporta:_CNPJ:TEXT,"@r 99.999.999/9999-99")
	ElseIf Type("oTransp:_Transporta:_CPF:TEXT")<>"U"
		aTransp[06] := Transform(oTransp:_Transporta:_CPF:TEXT,"@r 999.999.999-99")
	EndIf
	aTransp[07] := IIf(Type("oTransp:_Transporta:_xEnder:TEXT")<>"U",NoChar(oTransp:_Transporta:_xEnder:TEXT,lConverte),"")
	aTransp[08] := IIf(Type("oTransp:_Transporta:_xMun:TEXT")<>"U",oTransp:_Transporta:_xMun:TEXT,"")
	aTransp[09] := IIf(Type("oTransp:_Transporta:_UF:TEXT")<>"U",oTransp:_Transporta:_UF:TEXT,"")
	aTransp[10] := IIf(Type("oTransp:_Transporta:_IE:TEXT")<>"U",oTransp:_Transporta:_IE:TEXT,"")
ElseIf Type("oTransp:_VEICTRANSP")<>"U"
	aTransp[03] := IIf(Type("oTransp:_VeicTransp:_RNTC")=="U","",oTransp:_VeicTransp:_RNTC:TEXT)
	aTransp[04] := IIf(Type("oTransp:_VeicTransp:_Placa:TEXT")<>"U",oTransp:_VeicTransp:_Placa:TEXT,"")
	aTransp[05] := IIf(Type("oTransp:_VeicTransp:_UF:TEXT")<>"U",oTransp:_VeicTransp:_UF:TEXT,"")
EndIf
If Type("oTransp:_Vol")<>"U"
	If ValType(oTransp:_Vol) == "A"
		nX := nPrivate
		nLenVol := Len(oTransp:_Vol)
		For nX := 1 to nLenVol
			nXAux := nX
			nVolume += IIF(!Type("oTransp:_Vol[nXAux]:_QVOL:TEXT")=="U",Val(oTransp:_Vol[nXAux]:_QVOL:TEXT),0)
		Next nX
		aTransp[11]	:= AllTrim(str(nVolume))
		aTransp[12]	:= IIf(Type("oTransp:_Vol:_Esp")=="U","Diversos","")
		aTransp[13] := IIf(Type("oTransp:_Vol:_Marca")=="U","",NoChar(oTransp:_Vol:_Marca:TEXT,lConverte))
		aTransp[14] := IIf(Type("oTransp:_Vol:_nVol:TEXT")<>"U",oTransp:_Vol:_nVol:TEXT,"")
		If  Type("oTransp:_Vol[1]:_PesoB") <>"U"
			nPesoB := Val(oTransp:_Vol[1]:_PesoB:TEXT)
			aTransp[15] := AllTrim(str(nPesoB))
		EndIf
		If Type("oTransp:_Vol[1]:_PesoL") <>"U"
			nPesoL := Val(oTransp:_Vol[1]:_PesoL:TEXT)
			aTransp[16] := AllTrim(str(nPesoL))
		EndIf
	Else
		aTransp[11] := IIf(Type("oTransp:_Vol:_qVol:TEXT")<>"U",oTransp:_Vol:_qVol:TEXT,"")
		aTransp[12] := IIf(Type("oTransp:_Vol:_Esp")=="U","",oTransp:_Vol:_Esp:TEXT)
		aTransp[13] := IIf(Type("oTransp:_Vol:_Marca")=="U","",NoChar(oTransp:_Vol:_Marca:TEXT,lConverte))
		aTransp[14] := IIf(Type("oTransp:_Vol:_nVol:TEXT")<>"U",oTransp:_Vol:_nVol:TEXT,"")
		aTransp[15] := IIf(Type("oTransp:_Vol:_PesoB:TEXT")<>"U",oTransp:_Vol:_PesoB:TEXT,"")
		aTransp[16] := IIf(Type("oTransp:_Vol:_PesoL:TEXT")<>"U",oTransp:_Vol:_PesoL:TEXT,"")
	EndIf
	aTransp[15] := strTRan(aTransp[15],".",",")
	aTransp[16] := strTRan(aTransp[16],".",",")
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Volumes / Especie Nota de Saida                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Especie Nota de Entrada                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄ-----ÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tipo do frete    ³
//ÀÄÄÄÄÄÄ-----ÄÄÄÄÄÄÙ

If Type("oTransp:_ModFrete") <> "U"
	cModFrete := oTransp:_ModFrete:TEXT
Else
	cModFrete := "1"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro Dados do Produto / Serviço                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLenDet := Len(oDet)
If lMv_ItDesc
	For nX := 1 To nLenDet
		Aadd(aIndAux, {nX, SubStr(NoChar(oDet[nX]:_Prod:_xProd:TEXT,lConverte),1,MAXITEMC)})
	Next
	
	aIndAux := aSort(aIndAux,,, { |x, y| x[2] < y[2] })
	
	For nX := 1 To nLenDet
		Aadd(aIndImp, aIndAux[nX][1] )
	Next
EndIf
nXAnt := 0 //FR - 29/06/2023
For nZ := 1 To nLenDet

	If lMv_ItDesc
		nX := aIndImp[nZ]
	Else
		nX := nZ
	EndIf

	nPrivate := nX

    If lArt488MG .And. lUf_MG
        nVTotal  := 0
        nVUnit   := 0 
    Else
	    nVTotal  := Val(oDet[nX]:_Prod:_vProd:TEXT)//-Val(IIF(Type("oDet[nPrivate]:_Prod:_vDesc")=="U","",oDet[nX]:_Prod:_vDesc:TEXT))
	    nVUnit   := Val(oDet[nX]:_Prod:_vUnTrib:TEXT)
	EndIf

	nQtd     	:= Val(oDet[nX]:_Prod:_qTrib:TEXT)
	nBaseICM 	:= 0
	nValICM  	:= 0
	nValIPI  	:= 0
	nPICM    	:= 0
	nPIPI    	:= 0
	oImposto 	:= oDet[nX]
	cSitTrib 	:= ""   
	
	//FR - 07/02/2022 - ORMEC - Incluir coluna valor desconto no modo retrato 
	nVDesc      := 0    
	If XmlChildEx(oDet[nX]:_Prod,"_VDESC") <> NIL
		nVDesc      := Val(oDet[nX]:_Prod:_vDesc:TEXT) 
	Endif 
	//FR - 07/02/2022 - ORMEC - Incluir coluna valor desconto no modo retrato 

    lPontilhado	:= .F.	

	If Type("oImposto:_Imposto")<>"U"
		If Type("oImposto:_Imposto:_ICMS")<>"U"
			nLenSit := Len(aSitTrib)
			For nY := 1 To nLenSit
				nPrivate2 := nY
				If Type("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nPrivate2])<>"U"
					If Type("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nPrivate2]+":_VBC:TEXT")<>"U"
						if Type("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nY]+":_VBC:TEXT") <> "U"
							nBaseICM := Val(&("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nY]+":_VBC:TEXT"))
						endif
						if Type("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nY]+":_vICMS:TEXT") <> "U"
							nValICM  := Val(&("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nY]+":_vICMS:TEXT"))
						endif
						if Type("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nY]+":_PICMS:TEXT") <> "U"
							nPICM    := Val(&("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nY]+":_PICMS:TEXT")) 
						endif
					ElseIf Type("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nPrivate2]+":_MOTDESICMS") <> "U" .And. Type("oImposto:_PROD:_VDESC:TEXT") <> "U"   //SINIEF 25/12, efeitos a partir de 20.12.12 
						If oNF:_INFNFE:_VERSAO:TEXT >= "3.10" .and. &("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nY]+":_CST:TEXT") <> "40"
							If AllTrim(&("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nY]+":_motDesICMS:TEXT")) == "7" .And. &("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nY]+":_CST:TEXT") == "30"
								nValICM  := 0
							Else
								if Type("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nY]+":_vICMSDESON:TEXT") <> "U"
									nValICM  := Val(&("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nY]+":_vICMSDESON:TEXT")) 
								endif
							EndIf
						Elseif &("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nY]+":_CST:TEXT") <> "40"
							If AllTrim(&("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nY]+":_motDesICMS:TEXT")) == "7" .And. &("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nY]+":_CST:TEXT") == "30"
								nValICM  := 0
							Else
								if Type("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nY]+":_vICMS:TEXT") <> "U"
									nValICM  := Val(&("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nY]+":_vICMS:TEXT"))
								endif
							EndIf
						EndIf
					EndIf
					if Type("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nY]+":_ORIG:TEXT") <> "U"
						cSitTrib := &("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nY]+":_ORIG:TEXT")
					endif
					if Type("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nY]+":_CST:TEXT") <> "U"
						cSitTrib += &("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nY]+":_CST:TEXT")
					endif
				EndIf												
			Next nY			
		
			//Tratamento para o ICMS para optantes pelo Simples Nacional
			If Type("oEmitente:_CRT") <> "U" .And. oEmitente:_CRT:TEXT == "1"
				nLenSit := Len(aSitSN)
				For nY := 1 To nLenSit
					nPrivate2 := nY
					If Type("oImposto:_Imposto:_ICMS:_ICMSSN"+aSitSN[nPrivate2])<>"U"
						If Type("oImposto:_Imposto:_ICMS:_ICMSSN"+aSitSN[nPrivate2]+":_VBC:TEXT")<>"U"
							if Type("oImposto:_Imposto:_ICMS:_ICMSSN"+aSitSN[nY]+":_VBC:TEXT") <> "U"
								nBaseICM := Val(&("oImposto:_Imposto:_ICMS:_ICMSSN"+aSitSN[nY]+":_VBC:TEXT"))
							endif
							if Type("oImposto:_Imposto:_ICMS:_ICMSSN"+aSitSN[nY]+":_vICMS:TEXT") <> "U"
								nValICM  := Val(&("oImposto:_Imposto:_ICMS:_ICMSSN"+aSitSN[nY]+":_vICMS:TEXT"))
							endif
							if Type("oImposto:_Imposto:_ICMS:_ICMSSN"+aSitSN[nY]+":_PICMS:TEXT") <> "U"
								nPICM    := Val(&("oImposto:_Imposto:_ICMS:_ICMSSN"+aSitSN[nY]+":_PICMS:TEXT"))      
							endif             
						EndIf
						if Type("oImposto:_Imposto:_ICMS:_ICMSSN"+aSitSN[nY]+":_ORIG:TEXT") <> "U"
							cSitTrib := &("oImposto:_Imposto:_ICMS:_ICMSSN"+aSitSN[nY]+":_ORIG:TEXT")
						endif
						if Type("oImposto:_Imposto:_ICMS:_ICMSSN"+aSitSN[nY]+":_CSOSN:TEXT") <> "U"
							cSitTrib += &("oImposto:_Imposto:_ICMS:_ICMSSN"+aSitSN[nY]+":_CSOSN:TEXT")	
						endif			
					EndIf
				Next nY	
			EndIf			
		
		EndIf
		If Type("oImposto:_Imposto:_IPI")<>"U"
			If Type("oImposto:_Imposto:_IPI:_IPITrib:_vIPI:TEXT")<>"U"
				nValIPI := Val(oImposto:_Imposto:_IPI:_IPITrib:_vIPI:TEXT)
			EndIf
			If Type("oImposto:_Imposto:_IPI:_IPITrib:_pIPI:TEXT")<>"U"
				nPIPI   := Val(oImposto:_Imposto:_IPI:_IPITrib:_pIPI:TEXT)
			EndIf
		EndIf
	EndIf
	
	nMaxCod := MaxCod(oDet[nX]:_Prod:_cProd:TEXT, 50)
	
	// Tratamento para quebrar os digitos dos valores
	aAux := {}
	AADD(aAux, AllTrim(TransForm(nQtd,TM(nQtd,TamSX3("D2_QUANT")[1],TamSX3("D2_QUANT")[2]))))     			//1
	AADD(aAux, AllTrim(TransForm(nVUnit,TM(nVUnit,TamSX3("D2_PRCVEN")[1],TamSX3("D2_PRCVEN")[2]))))    		//2
	AADD(aAux, AllTrim(TransForm(nVTotal,TM(nVTotal,TamSX3("D2_TOTAL")[1],TamSX3("D2_TOTAL")[2]))))     	//3
	AADD(aAux, AllTrim(TransForm(nBaseICM,TM(nBaseICM,TamSX3("D2_BASEICM")[1],TamSX3("D2_BASEICM")[2]))))  	//4
	AADD(aAux, AllTrim(TransForm(nValICM,TM(nValICM,TamSX3("D2_VALICM")[1],TamSX3("D2_VALICM")[2]))))      	//5
	AADD(aAux, AllTrim(TransForm(nValIPI,TM(nValIPI,TamSX3("D2_VALIPI")[1],TamSX3("D2_BASEIPI")[2]))))   	//6
	If nVDesc > 0
		AADD(aAux, AllTrim(TransForm(nVDesc,TM(nVDesc,TamSX3("D2_DESCON")[1],TamSX3("D2_DESCON")[2]))))  		//7	//FR - 07/02/2022 - ORMEC - Incluir coluna valor desconto no modo retrato 
	Else  
		AADD(aAux, AllTrim(TransForm(0,"@E 999.99") )) 															//7	//FR - 07/02/2022 - ORMEC - Incluir coluna valor desconto no modo retrato 
	Endif
	
	//FR - 19/03/2022 - ALTERAÇÃO - Forceline - imprimir junto à descrição do produto, as respectivas: base, valor e alíquota de ICM ST
	cImpSTNaDesc:= GEtNewPar("XM_IMPCST" , "N")  //Define se imprime as informações do ICM ST junto à descrição do produto
	//cImpSTNaDesc:= "S" //FR TESTE
	cInfoIST 	:= ""
	cInfoIST1   := ""
	cInfoIST2   := ""
	cInfoIST3   := ""
	cTagAux		:= ""
	_ICMSTBas   := "0"
	_ICMSTAlq   := "0"
	_ICMSTVal   := "0"
	
	
	If XmlChildEx(oDet[nX]:_IMPOSTO,"_ICMS") <> nil
			
		If XmlChildEx(oDet[nX]:_IMPOSTO:_ICMS,"_ICMS60") <> nil
			cTagAux    := "oDet["+AllTrim(str(nX))+"]:_IMPOSTO:_ICMS:_ICMS60:_VBCSTRET:TEXT"
			If Type( cTagAux ) <> "U"
				_ICMSTBas := ALLTRIM(&cTagAux)
			EndIf 
					
			cTagAux    := "oDet["+AllTrim(str(nX))+"]:_IMPOSTO:_ICMS:_ICMS60:_PST:TEXT"
			If Type( cTagAux ) <> "U"
				_ICMSTAlq := ALLTRIM(&cTagAux)
			EndIf
					
			cTagAux    := "oDet["+AllTrim(str(nX))+"]:_IMPOSTO:_ICMS:_ICMS60:_VICMSSTRET:TEXT"
			If Type( cTagAux ) <> "U"
				_ICMSTVal := ALLTRIM(&cTagAux)
			EndIf
					
		ElseIf XmlChildEx(oDet[nX]:_IMPOSTO:_ICMS,"_ICMS30") <> nil
				
			cTagAux    := "oDet["+AllTrim(str(nX))+"]:_IMPOSTO:_ICMS:_ICMS30:_VBCST:TEXT"
			If Type( cTagAux ) <> "U"
				_ICMSTBas := ALLTRIM(&cTagAux)
			EndIf 
					
			cTagAux    := "oDet["+AllTrim(str(nX))+"]:_IMPOSTO:_ICMS:_ICMS30:_PICMSST:TEXT"
			If Type( cTagAux ) <> "U"
				_ICMSTAlq := ALLTRIM(&cTagAux)
			EndIf
					
			cTagAux    := "oDet["+AllTrim(str(nX))+"]:_IMPOSTO:_ICMS:_ICMS30:_VICMSST:TEXT"
			If Type( cTagAux ) <> "U"
				_ICMSTVal := ALLTRIM(&cTagAux)
			EndIf 
		
		ElseIf XmlChildEx(oDet[nX]:_IMPOSTO:_ICMS,"_ICMS10") <> nil
				
			cTagAux    := "oDet["+AllTrim(str(nX))+"]:_IMPOSTO:_ICMS:_ICMS10:_VBCST:TEXT"
			If Type( cTagAux ) <> "U"
				_ICMSTBas := ALLTRIM(&cTagAux)
			EndIf 
					
			cTagAux    := "oDet["+AllTrim(str(nX))+"]:_IMPOSTO:_ICMS:_ICMS10:_PICMSST:TEXT"
			If Type( cTagAux ) <> "U"
				_ICMSTAlq := ALLTRIM(&cTagAux)
			EndIf
					
			cTagAux    := "oDet["+AllTrim(str(nX))+"]:_IMPOSTO:_ICMS:_ICMS10:_VICMSST:TEXT"
			If Type( cTagAux ) <> "U"
				_ICMSTVal := ALLTRIM(&cTagAux)
			EndIf

		ElseIf XmlChildEx(oDet[nX]:_IMPOSTO:_ICMS,"_ICMS00") <> nil
				
			cTagAux    := "oDet["+AllTrim(str(nX))+"]:_IMPOSTO:_ICMS:_ICMS00:_VBCST:TEXT"
			If Type( cTagAux ) <> "U"
				_ICMSTBas := ALLTRIM(&cTagAux)
			EndIf 
					
			cTagAux    := "oDet["+AllTrim(str(nX))+"]:_IMPOSTO:_ICMS:_ICMS00:_PICMSST:TEXT"
			If Type( cTagAux ) <> "U"
				_ICMSTAlq := ALLTRIM(&cTagAux)
			EndIf
					
			cTagAux    := "oDet["+AllTrim(str(nX))+"]:_IMPOSTO:_ICMS:_ICMS00:_VICMSST:TEXT"
			If Type( cTagAux ) <> "U"
				_ICMSTVal := ALLTRIM(&cTagAux)
			EndIf
				 
		Endif
		
	Endif 
	 
	If cImpSTNaDesc == "S"   //se o parâmetro estiver ativado para adicionar informações do ICM ST na descrição, alimenta a variável cInfoIST
		//cInfoIST := " pIcmsSt= " + _ICMSTAlq + "%" + " BcIcmsSt= " + _ICMSTBas + CRLF + " vIcmsSt= " + _ICMSTVal
		If Val(_ICMSTAlq) > 0
			cInfoIST1 := " pIcmsSt= " + _ICMSTAlq + "%" 
			cInfoIST2 := " BcIcmsSt= " + _ICMSTBas 
			cInfoIST3 := " vIcmsSt= " + _ICMSTVal
		Endif 
	Else
		cInfoIST  := ""  
		cInfoIST1 := ""  
		cInfoIST2 := ""  
		cInfoIST3 := ""  
	Endif 
	//FR - 19/03/2022 - ALTERAÇÃO - Forceline - imprimir junto à descrição do produto, as respectivas: base, valor e alíquota de ICM ST
		
	aadd(aItens,{;
		SubStr(oDet[nX]:_Prod:_cProd:TEXT,1,nMaxCod),;									//1
		SubStr(NoChar(oDet[nX]:_Prod:_xProd:TEXT,lConverte),1,nMaxDes) ,;  				//2
		IIF(Type("oDet[nPrivate]:_Prod:_NCM")=="U","",oDet[nX]:_Prod:_NCM:TEXT),;		//3
		cSitTrib,;                                                                     	//4
		oDet[nX]:_Prod:_CFOP:TEXT,;                                                   	//5
		oDet[nX]:_Prod:_utrib:TEXT,;                                                  	//6
		SubStr(aAux[1], 1, PosQuebrVal(aAux[1])),;                                     	//7
		SubStr(aAux[2], 1, PosQuebrVal(aAux[2])),;                                    	//8
		SubStr(aAux[3], 1, PosQuebrVal(aAux[3])),;                                     	//9
		SubStr(aAux[4], 1, PosQuebrVal(aAux[4])),;                                    	//10
		SubStr(aAux[5], 1, PosQuebrVal(aAux[5])),;                                    	//11
		SubStr(aAux[6], 1, PosQuebrVal(aAux[6])),;                                     	//12
		AllTrim(TransForm(nPICM,"@r 99.99%")),;                                        	//13
		AllTrim(TransForm(nPIPI,"@r 99.99%")),;                                        	//14
		SubStr(aAux[7], 1, PosQuebrVal(aAux[7]));  										//15	//FR - 07/02/2022 - ORMEC - Incluir coluna valor desconto no modo retrato 
	})

	// Tratamento somente para o estado de MG, para totalizar por CFOP conforme RICMS-MG
	If lUf_MG
		aadd(aItensAux,{;
			SubStr(oDet[nX]:_Prod:_cProd:TEXT,1,nMaxCod),;										//1
			SubStr(NoChar(oDet[nX]:_Prod:_xProd:TEXT,lConverte),1,nMaxDes) ,;			      	//2
			IIF(Type("oDet[nPrivate]:_Prod:_NCM")=="U","",oDet[nX]:_Prod:_NCM:TEXT),;			//3
			cSitTrib,;																			//4
			oDet[nX]:_Prod:_CFOP:TEXT,;                                                       	//5
			oDet[nX]:_Prod:_utrib:TEXT,;                                                      	//6
			SubStr(aAux[1], 1, PosQuebrVal(aAux[1])),;                                        	//7
			SubStr(aAux[2], 1, PosQuebrVal(aAux[2])),;                                        	//8
			SubStr(aAux[3], 1, PosQuebrVal(aAux[3])),;                                        	//9
			SubStr(aAux[4], 1, PosQuebrVal(aAux[4])),;                                        	//10
			SubStr(aAux[5], 1, PosQuebrVal(aAux[5])),;                                       	//11
			SubStr(aAux[6], 1, PosQuebrVal(aAux[6])),;                                       	//12
			AllTrim(TransForm(nPICM,"@r 99.99%")),;                                          	//13
			AllTrim(TransForm(nPIPI,"@r 99.99%")),;                                           	//14
			StrZero( ++nSequencia, 4 ),;                                                   		//15
			nVTotal,;             																//16  //FR - 07/02/2022 - ORMEC - Incluir coluna valor desconto no modo retrato 
			SubStr(aAux[7], 1, PosQuebrVal(aAux[7]));  											//17  //FR - 07/02/2022 - ORMEC - Incluir coluna valor desconto no modo retrato 
		})
	Endif
	
	// Tramento quando houver diferença entre as unidades uCom e uTrib ( SEFAZ MT )
	If ( oDet[nX]:_Prod:_uTrib:TEXT <> oDet[nX]:_Prod:_uCom:TEXT )

	    //lPontilhado := IIf( nLenDet > 1, .T., lPontilhado )  //FR - 29/06/2023
    	
		cUnCom		:= oDet[nX]:_Prod:_uCom:TEXT
		nQtdCom		:= Val(oDet[nX]:_Prod:_qCom:TEXT)
	    nVUnitCom	:= Val(oDet[nX]:_Prod:_vUnCom:TEXT)

		aAuxCom := {}
		AADD(aAuxCom, AllTrim(TransForm(nQtdCom,TM(nQtdCom,TamSX3("D2_QUANT")[1],TamSX3("D2_QUANT")[2]))))
		AADD(aAuxCom, AllTrim(TransForm(nVUnitCom,TM(nVUnitCom,TamSX3("D2_PRCVEN")[1],TamSX3("D2_PRCVEN")[2]))))
   	
		If lUf_MG
			aadd(aItensAux,{;
				"",;         											//1
				"",;                                                   	//2
				"",;                                                   	//3
				"",;                                                   	//4
				oDet[nX]:_Prod:_CFOP:TEXT,;                            	//5
				cUnCom,;                                               	//6
				SubStr(aAuxCom[1], 1, PosQuebrVal(aAuxCom[1])),;       	//7
				SubStr(aAuxCom[2], 1, PosQuebrVal(aAuxCom[2])),;       	//8
				"",;                                                   	//9
				"",;                                                   	//10
				"",;                                                  	//11
				"",;                                                   	//12
				"",;                                                   	//13
				"",;                                                   	//14
				StrZero( ++nSequencia, 4 ),;                           	//15
				0,; 													//16	//FR - 07/02/2022 - ORMEC - Incluir coluna valor desconto no modo retrato 
				0; 														//17	//FR - 07/02/2022 - ORMEC - Incluir coluna valor desconto no modo retrato 
			})
		else
			aadd(aItens,{;
				"",;  													//1
				"",;                                                   	//2
				"",;                                                   	//3
				"",;                                                  	//4
				"",;                                                  	//5
				cUnCom,;                                              	//6
				SubStr(aAuxCom[1], 1, PosQuebrVal(aAuxCom[1])),;      	//7
				SubStr(aAuxCom[2], 1, PosQuebrVal(aAuxCom[2])),;      	//8
				"",;                                                  	//9
				"",;                                                   	//10
				"",;                                                    //11
				"",;                                                   	//12
				"",;                                                   	//13
				"",;													//14	
				""	;													//15	//FR - 07/02/2022 - ORMEC - Incluir coluna valor desconto no modo retrato 
			})
		endif

	Endif
	
	cAuxItem := AllTrim(SubStr(oDet[nX]:_Prod:_cProd:TEXT,nMaxCod+1))
	cAux     := AllTrim(SubStr(NoChar(oDet[nX]:_Prod:_xProd:TEXT,lConverte),(nMaxDes+1)))
	//cAux     += cInfoIST
	aAux[1]  := SubStr(aAux[1], PosQuebrVal(aAux[1]) + 1)
	aAux[2]  := SubStr(aAux[2], PosQuebrVal(aAux[2]) + 1)
	aAux[3]  := SubStr(aAux[3], PosQuebrVal(aAux[3]) + 1)
	aAux[4]  := SubStr(aAux[4], PosQuebrVal(aAux[4]) + 1)
	aAux[5]  := SubStr(aAux[5], PosQuebrVal(aAux[5]) + 1)
	aAux[6]  := SubStr(aAux[6], PosQuebrVal(aAux[6]) + 1) 
	//FR - 07/02/2022 - ORMEC - Incluir coluna valor desconto no modo retrato
	aAux[7]  := SubStr(aAux[7], PosQuebrVal(aAux[7]) + 1)  

	While !Empty(cAux) .Or. !Empty(cAuxItem) .Or. !Empty(aAux[1]) .Or. !Empty(aAux[2]) .Or. !Empty(aAux[3]) .Or. !Empty(aAux[4]) .Or. !Empty(aAux[5]) .Or. !Empty(aAux[6])
	//.Or. !Empty(cInfoIST1) .Or. !Empty(cInfoIST2) .Or. !Empty(cInfoIST3)
		nMaxCod := MaxCod(cAuxItem, 50)
		
		aadd(aItens,{;
			SubStr(cAuxItem,1,nMaxCod),;       						//1
			SubStr(cAux,1,nMaxDes),;                               	//2
			"",;                                                   	//3
			"",;                                                   	//4
			"",;                                                   	//5
			"",;                                                   	//6
			SubStr(aAux[1], 1, PosQuebrVal(aAux[1])),;             	//7
			SubStr(aAux[2], 1, PosQuebrVal(aAux[2])),;             	//8
			SubStr(aAux[3], 1, PosQuebrVal(aAux[3])),;             	//9
			SubStr(aAux[4], 1, PosQuebrVal(aAux[4])),;             	//10
			SubStr(aAux[5], 1, PosQuebrVal(aAux[5])),;             	//11
			SubStr(aAux[6], 1, PosQuebrVal(aAux[6])),;             	//12
			"",;                                                  	//13
			"",;													//14	
			"";														//15	//FR - 07/02/2022 - ORMEC - Incluir coluna valor desconto no modo retrato 
		}) 		

		If lUf_MG
			aadd(aItensAux,{;
				SubStr(cAuxItem,1,nMaxCod),;						//1
				SubStr(cAux,1,nMaxDes),;                           	//2
				"",;                                               	//3
				"",;                                               	//4
				oDet[nX]:_Prod:_CFOP:TEXT,;                       	//5
				"",;                                               	//6
				SubStr(aAux[1], 1, PosQuebrVal(aAux[1])),;         	//7
				SubStr(aAux[2], 1, PosQuebrVal(aAux[2])),;         	//8
				SubStr(aAux[3], 1, PosQuebrVal(aAux[3])),;         	//9
				SubStr(aAux[4], 1, PosQuebrVal(aAux[4])),;         	//10
				SubStr(aAux[5], 1, PosQuebrVal(aAux[5])),;         	//11
				SubStr(aAux[6], 1, PosQuebrVal(aAux[6])),;         	//12
				"",;                                               	//13
				"",;                                               	//14
				StrZero( ++nSequencia, 4 ),;                       	//15
				0;	   												//16		//FR - 07/02/2022 - ORMEC - Incluir coluna valor desconto no modo retrato 
			})
		Endif
		
		// Popula as informações para as próximas linhas adicionais
		cAux        := SubStr(cAux,(nMaxDes+1)) 
		cAuxItem    := SubStr(cAuxItem,nMaxCod+1)		
		aAux[1]     := SubStr(aAux[1], PosQuebrVal(aAux[1]) + 1)
		aAux[2]     := SubStr(aAux[2], PosQuebrVal(aAux[2]) + 1)
		aAux[3]     := SubStr(aAux[3], PosQuebrVal(aAux[3]) + 1)
		aAux[4]     := SubStr(aAux[4], PosQuebrVal(aAux[4]) + 1)
		aAux[5]     := SubStr(aAux[5], PosQuebrVal(aAux[5]) + 1)
		aAux[6]     := SubStr(aAux[6], PosQuebrVal(aAux[6]) + 1)
		//FR - 07/02/2022 - ORMEC - Incluir coluna valor desconto no modo retrato 
		aAux[7]     := SubStr(aAux[7], PosQuebrVal(aAux[7]) + 1)
		//lPontilhado := .T.  //FR - 29/06/2023 - AJUSTE NA IMPRESSÃO DO PONTILHADO Q SEPARA OS ITENS
	EndDo	
	
	If (Type("oNf:_infnfe:_det[nPrivate]:_Infadprod:TEXT") <> "U" .Or. Type("oNf:_infnfe:_det:_Infadprod:TEXT") <> "U") .And. ( lImpAnfav .Or. lImpInfAd )
		If at("<", AllTrim(SubStr(oDet[nX]:_Infadprod:TEXT,1))) <> 0
			cAux := stripTags(AllTrim(SubStr(oDet[nX]:_Infadprod:TEXT,1)), .T.) + " "
			cAux += stripTags(AllTrim(SubStr(oDet[nX]:_Infadprod:TEXT,1)), .F.)
		else
			cAux := stripTags(AllTrim(SubStr(oDet[nX]:_Infadprod:TEXT,1)), .T.)
		endIf
		
		While !Empty(cAux)
			aadd(aItens,{;
				"",;      								//1
				SubStr(cAux,1,nMaxDes),;               	//2
				"",;                                   	//3
				"",;                                   	//4
				"",;                                   	//5
				"",;                                   	//6
				"",;                                   	//7
				"",;                                   	//8
				"",;                                   	//9
				"",;                                   	//10
				"",;                                  	//11
				"",;                                   	//12
				"",;                                   	//13
				"",;									//14
				"";								   		//15	//FR - 07/02/2022 - ORMEC - Incluir coluna valor desconto no modo retrato 
			})

			If lUf_MG
				aadd(aItensAux,{;
					"",;           						//1
					SubStr(cAux,1,nMaxDes),;           	//2
					"",;                               	//3
					"",;                               	//4
					oDet[nX]:_Prod:_CFOP:TEXT,;        	//5
					"",;                             	//6
					"",;                              	//7
					"",;                              	//8
					"",;                             	//9
					"",;                               	//10
					"",;                              	//11
					"",;                             	//12
					"",;                             	//13
					"",;                             	//14
					StrZero( ++nSequencia, 4 ),;       	//15
					0;   								//16 	//FR - 07/02/2022 - ORMEC - Incluir coluna valor desconto no modo retrato 
				})
            Endif
            
			cAux := SubStr(cAux,(nMaxDes + 1))
	    	lPontilhado := .T.	//FR - 29/06/2023
			//lPontilhado := IIf( nLenDet > 1, .T., lPontilhado )  //FR - 29/06/2023
			//If nX <> nXAnt
			//	lPontilhado := .T.
			//	nXAnt := nX
			//Endif
		EndDo
	EndIf
	lPontilhado := .T.	//FR - 30/06/2023 - coloquei aqui onde em tese terminou a impressão do item anterior

	//----------------------------------------------------------------------------------------------------------------------------------//
	//FR - 30/06/2023 - FORCELINE  
	//SÓ IMPRIME AS INFORMAÇÕES DO ICM ST DEPOIS QUE IMPRIMIU TODA A DESCRIÇÃO DO PRODUTO, OU SEJA, IMPRIME LOGO ABAIXO DA DESCRIÇÃO
	//----------------------------------------------------------------------------------------------------------------------------------//
	If cImpSTNaDesc == "S"
		//SÓ IMPRIME AS INFORMAÇÕES DO ICM ST DEPOIS QUE IMPRIMIU TODA A DESCRIÇÃO DO PRODUTO, OU SEJA, IMPRIME LOGO ABAIXO DA DESCRIÇÃO
		If !Empty(cInfoIST1)
			aadd(aItens,{;
			SubStr(cAuxItem,1,nMaxCod),;       						//1
			cInfoIST1,; //Substr(cInfoIST,1,nMaxDes),;                           	//2
			"",;                                                   	//3
			"",;                                                   	//4
			"",;                                                   	//5
			"",;                                                   	//6
			SubStr(aAux[1], 1, PosQuebrVal(aAux[1])),;             	//7
			SubStr(aAux[2], 1, PosQuebrVal(aAux[2])),;             	//8
			SubStr(aAux[3], 1, PosQuebrVal(aAux[3])),;             	//9
			SubStr(aAux[4], 1, PosQuebrVal(aAux[4])),;             	//10
			SubStr(aAux[5], 1, PosQuebrVal(aAux[5])),;             	//11
			SubStr(aAux[6], 1, PosQuebrVal(aAux[6])),;             	//12
			"",;                                                  	//13
			"",;													//14	
			"";														//15	//FR - 07/02/2022 - ORMEC - Incluir coluna valor desconto no modo retrato 
			})
				
			aadd(aItens,{;
			SubStr(cAuxItem,1,nMaxCod),;       						//1
			cInfoIST2,; //Substr(cInfoIST,1,nMaxDes),;                           	//2
			"",;                                                   	//3
			"",;                                                   	//4
			"",;                                                   	//5
			"",;                                                   	//6
			SubStr(aAux[1], 1, PosQuebrVal(aAux[1])),;             	//7
			SubStr(aAux[2], 1, PosQuebrVal(aAux[2])),;             	//8
			SubStr(aAux[3], 1, PosQuebrVal(aAux[3])),;             	//9
			SubStr(aAux[4], 1, PosQuebrVal(aAux[4])),;             	//10
			SubStr(aAux[5], 1, PosQuebrVal(aAux[5])),;             	//11
			SubStr(aAux[6], 1, PosQuebrVal(aAux[6])),;             	//12
			"",;                                                  	//13
			"",;													//14	
			"";														//15	//FR - 07/02/2022 - ORMEC - Incluir coluna valor desconto no modo retrato 
			})
					
			aadd(aItens,{;
			SubStr(cAuxItem,1,nMaxCod),;       						//1
			cInfoIST3,; //Substr(cInfoIST,1,nMaxDes),;                           	//2
			"",;                                                   	//3
			"",;                                                   	//4
			"",;                                                   	//5
			"",;                                                   	//6
			SubStr(aAux[1], 1, PosQuebrVal(aAux[1])),;             	//7
			SubStr(aAux[2], 1, PosQuebrVal(aAux[2])),;             	//8
			SubStr(aAux[3], 1, PosQuebrVal(aAux[3])),;             	//9
			SubStr(aAux[4], 1, PosQuebrVal(aAux[4])),;             	//10
			SubStr(aAux[5], 1, PosQuebrVal(aAux[5])),;             	//11
			SubStr(aAux[6], 1, PosQuebrVal(aAux[6])),;             	//12
			"",;                                                  	//13
			"",;													//14	
			"";														//15	//FR - 07/02/2022 - ORMEC - Incluir coluna valor desconto no modo retrato 
			})

			//cInfoIST1 := Alltrim(SubStr(cInfoIST1,(nMaxDes+1)) )
			//cInfoIST2 := Alltrim(SubStr(cInfoIST2,(nMaxDes+1)) )
			//cInfoIST3 := Alltrim(SubStr(cInfoIST3,(nMaxDes+1)) )
		Endif	
	Endif 	//If cImpSTNaDesc == "S"		

	If lPontilhado
		aadd(aItens,{;
			"-",; 					//1
			"-",;                	//2
			"-",;               	//3
			"-",;                	//4
			"-",;               	//5
			"-",;               	//6
			"-",;                  	//7
			"-",;                 	//8
			"-",;                	//9
			"-",;                	//10
			"-",;                	//11
			"-",;                	//12
			"-",;                 	//13
			"-",;					//14	
			"-";					//15 	//FR - 07/02/2022 - ORMEC - Incluir coluna valor desconto no modo retrato 	
		})

		If lUf_MG
			aadd(aItensAux,{;
				"-",; 								//1
				"-",;                              	//2
				"-",;                              	//3
				"-",;                              	//4
				oDet[nX]:_Prod:_CFOP:TEXT,;       	//5
				"-",;                             	//6
				"-",;                            	//7
				"-",;                            	//8
				"-",;                            	//9
				"-",;                            	//10
				"-",;                             	//11
				"-",;                              	//12
				"-",;                            	//13
				"-",;                            	//14
				StrZero( ++nSequencia, 4 ),;      	//15
				0;									//16	//FR - 07/02/2022 - ORMEC - Incluir coluna valor desconto no modo retrato 
			})
		Endif

	EndIf 

Next nZ

//----------------------------------------------------------------------------------
// Tratamento somente para o estado de MG, para totalizar por CFOP conforme RICMS-MG
//----------------------------------------------------------------------------------
If lUf_MG  

	If 	Len( aItensAux ) > 0

		aItensAux	:= aSort( aItensAux,,, { |x,y| x[5]+x[15] < y[5]+y[15] } )
	
		nSubTotal	:= 0

		aItens		:= {}
	  
		cCfop		:= aItensAux[1,5]
		cCfopAnt	:= aItensAux[1,5]			
		
		For nX := 1 To Len( aItensAux )

			//aArray		:= ARRAY(14)
			aArray			:= ARRAY(15)  	//FR - 07/02/2022 - ORMEC - Incluir coluna valor desconto no modo retrato 
			
			aArray[01]	:= aItensAux[nX,01]
			aArray[02]	:= aItensAux[nX,02]
			aArray[03]	:= aItensAux[nX,03]
			aArray[04]	:= aItensAux[nX,04]
			
			If Empty( aItensAux[nX,03] ) .Or. aItensAux[nX,03] == "-"
				aArray[05] := ""
			Else
				aArray[05] := aItensAux[nX,05]
			Endif

			aArray[06]	:= aItensAux[nX,06]
			aArray[07]	:= aItensAux[nX,07]
			aArray[08]	:= aItensAux[nX,08]
			aArray[09]	:= aItensAux[nX,09]
			aArray[10]	:= aItensAux[nX,10]
			aArray[11]	:= aItensAux[nX,11]
			aArray[12]	:= aItensAux[nX,12]
			aArray[13]	:= aItensAux[nX,13]
			aArray[14]	:= aItensAux[nX,14] 
			aArray[15]  := aItensAux[nX,16]	//FR - 07/02/2022 - ORMEC - Incluir coluna valor desconto no modo retrato 

			If aItensAux[nX,5] == cCfop

				aadd( aItens, {; 
					aArray[01],;
					aArray[02],;
					aArray[03],;
					aArray[04],;
					aArray[05],;
					aArray[06],;
					aArray[07],;
					aArray[08],;
					aArray[09],;
					aArray[10],;
					aArray[11],;
					aArray[12],;
					aArray[13],;
					aArray[14],;
					aArray[15];		//FR - 07/02/2022 - ORMEC - Incluir coluna valor desconto no modo retrato 
				} )

				nSubTotal += aItensAux[nX,16]

			Else

				aadd(aItens,{;
					"-",;     				//1
					"-",;                   //2
					"-",;                  	//3
					"-",;                  	//4
					"-",;                  	//5
					"-",;                  	//6
					"-",;                 	//7
					"-",;                   //8
					"-",;                 	//9
					"-",;                 	//10
					"-",;                  	//11
					"-",;               	//12
					"-",;                 	//13
					"-",;	              	//14
					"-";					//15	//FR - 07/02/2022 - ORMEC - Incluir coluna valor desconto no modo retrato 
				})
				
				aadd(aItens,{;
					"",;      				//1
					"SUB-TOTAL",;          	//2
					"",;                   	//3
					"",;                  	//4
					"",;                  	//5
					"",;                	//6
					"",;                   	//7
					"",;                  	//8
					AllTrim(TransForm(nSubTotal,TM(nSubTotal,TamSX3("D2_TOTAL")[1],TamSX3("D2_TOTAL")[2]))),;	//9
					"",;                                                                                       	//10
					"",;                                                                                       	//11
					"",;                                                                                       	//12
					"",;                                                                                      	//13
					"",;																			         	//14
					"";		//FR - 07/02/2022 - ORMEC - Incluir coluna valor desconto no modo retrato          	//15
				})

				aadd(aItens,{;
					"",;     				//1
					"",;                    //2
					"",;                   	//3
					"",;                  	//4
					"",;                   	//5
					"",;                  	//6
					"",;                   	//7
					"",;                 	//8
					"",;                   	//9
					"",;                   	//10
					"",;                 	//11
					"",;                  	//12
					"",;                 	//13
					"",;                   	//14
					"";						//15	//FR - 07/02/2022 - ORMEC - Incluir coluna valor desconto no modo retrato 
				})
				
				cCfop 		:= aItensAux[nX,05]
				nSubTotal 	:= aItensAux[nX,16]

				aadd( aItens, {; 
					aArray[01],;  			//1
					aArray[02],;            //2
					aArray[03],;           	//3
					aArray[04],;           	//4
					aArray[05],;           	//5
					aArray[06],;           	//6
					aArray[07],;          	//7
					aArray[08],;          	//8
					aArray[09],;          	//9
					aArray[10],;         	//10
					aArray[11],;           	//11
					aArray[12],;           	//12
					aArray[13],;          	//13
					aArray[14],;	     	//14
					aArray[15];				//15	//FR - 07/02/2022 - ORMEC - Incluir coluna valor desconto no modo retrato 
				} )

			Endif
			
		Next nX
		
		If cCfopAnt <> cCfop .And. nSubTotal > 0

			aadd(aItens,{;
				"-",;     				//1
				"-",;
				"-",;
				"-",;
				"-",;
				"-",;
				"-",;
				"-",;
				"-",;
				"-",;
				"-",;
				"-",;
				"-",;
				"-",;
				"-";    				//15	//FR - 07/02/2022 - ORMEC - Incluir coluna valor desconto no modo retrato 
			})
			
			aadd(aItens,{;
				"",;      			//1
				"SUB-TOTAL",;
				"",;
				"",;
				"",;
				"",;
				"",;
				"",;
				AllTrim(TransForm(nSubTotal,TM(nSubTotal,TamSX3("D2_TOTAL")[1],TamSX3("D2_TOTAL")[2]))),;
				"",;
				"",;
				"",;
				"",;
				"",;	
				"";					//15	//FR - 07/02/2022 - ORMEC - Incluir coluna valor desconto no modo retrato 
			})		
		
		Endif
		
	Endif
	
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro ISSQN                                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aISSQN := {"","","",""}
If Type("oEmitente:_IM:TEXT")<>"U"
	aISSQN[1] := oEmitente:_IM:TEXT
EndIf
If Type("oTotal:_ISSQNtot")<>"U"
	if Type("oTotal:_ISSQNtot:_vServ:TEXT") <> "U"
		aISSQN[2] := Transform(Val(oTotal:_ISSQNtot:_vServ:TEXT),"@e 999,999,999.99")
	EndIf
	if Type("oTotal:_ISSQNtot:_vBC:TEXT") <> "U"
		aISSQN[3] := Transform(Val(oTotal:_ISSQNtot:_vBC:TEXT),"@e 999,999,999.99")
	Endif
	If Type("oTotal:_ISSQNtot:_vISS:TEXT") <> "U"
		aISSQN[4] := Transform(Val(oTotal:_ISSQNtot:_vISS:TEXT),"@e 999,999,999.99")
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro de informacoes complementares                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If Type("oIdent:_DHCONT:TEXT")<>"U"
	cDhCont:= oIdent:_DHCONT:TEXT
EndIf
If Type("oIdent:_XJUST:TEXT")<>"U"
	cXJust:=oIdent:_XJUST:TEXT
EndIf

aMensagem := {}
If Type("oIdent:_tpAmb:TEXT")<>"U" .And. oIdent:_tpAmb:TEXT=="2"
	cAux := "DANFE emitida no ambiente de homologação - SEM VALOR FISCAL"
	While !Empty(cAux)
		aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
		cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
	EndDo
EndIf

If Type("oNF:_InfNfe:_infAdic:_infAdFisco:TEXT")<>"U"
	cAux := oNF:_InfNfe:_infAdic:_infAdFisco:TEXT
	While !Empty(cAux)
		aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
		cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
	EndDo
EndIf

If !Empty(cCodAutSef) .AND. oIdent:_tpEmis:TEXT<>"4"
	cAux := "Protocolo: "+cCodAutSef
	While !Empty(cAux)
		aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
		cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
	EndDo
ElseIf !Empty(cCodAutSef) .AND. oIdent:_tpEmis:TEXT=="4" .AND. cModalidade $ "1"
	cAux := "Protocolo: "+cCodAutSef
	While !Empty(cAux)
		aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
		cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
	EndDo
	cAux := "DANFE emitida anteriormente em contingência DPEC"
	While !Empty(cAux)
		aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
		cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
	EndDo
EndIf

If !Empty(cCodAutDPEC) .And. oIdent:_tpEmis:TEXT=="4"
	cAux := "Número de Registro DPEC: "+cCodAutDPEC
	While !Empty(cAux)
		aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
		cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
	EndDo
EndIf

If (Type("oIdent:_tpEmis:TEXT")<>"U" .And. !oIdent:_tpEmis:TEXT$"1,4")
	cAux := "DANFE emitida em contingência"
	If !Empty(cXJust) .and. !Empty(cDhCont) .and. oIdent:_tpEmis:TEXT$"6,7"// SVC-AN e SVC-RS Deve ser impresso o xjust e dhcont
		cAux += " Motivo da adoção da contingência: "+cXJust+ " Data e hora de início de utilização: "+cDhCont
	EndIf
	While !Empty(cAux)
		aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
		cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
	EndDo
ElseIf (!Empty(cModalidade) .And. !cModalidade $ "1,4,5") .And. Empty(cCodAutSef)
	cAux := "DANFE emitida em contingência devido a problemas técnicos - será necessária a substituição."
	While !Empty(cAux)
		aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
		cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
	EndDo
ElseIf (!Empty(cModalidade) .And. cModalidade $ "5" .And. oIdent:_tpEmis:TEXT=="4")
	cAux := "DANFE impresso em contingência"
	While !Empty(cAux)
		aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
		cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
	EndDo
	cAux := "DPEC regularmento recebido pela Receita Federal do Brasil."
	While !Empty(cAux)
		aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
		cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
	EndDo
ElseIf (Type("oIdent:_tpEmis:TEXT")<>"U" .And. oIdent:_tpEmis:TEXT$"5")
	cAux := "DANFE emitida em contingência FS-DA"
	While !Empty(cAux)
		aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
		cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
	EndDo
EndIf

If Type("oNF:_InfNfe:_infAdic:_infCpl:TEXT")<>"U"
	If at("<", oNF:_InfNfe:_infAdic:_InfCpl:TEXT) <> 0
		cAux := stripTags(oNF:_InfNfe:_infAdic:_InfCpl:TEXT, .T.) + " "
		cAux += stripTags(oNF:_InfNfe:_infAdic:_InfCpl:TEXT, .F.)
	else
		cAux := stripTags(oNF:_InfNfe:_infAdic:_InfCpl:TEXT, .T.)
	endIf
	While !Empty(cAux)
		aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
		cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
	EndDo
EndIf
/*
dbSelectArea("SF1")
dbSetOrder(1)
If MsSeek(xFilial("SF1")+aNota[5]+aNota[4]+aNota[6]+aNota[7]) .And. SF1->(FieldPos("F1_FIMP"))<>0
	If SF1->F1_TIPO == "D"
		If Type("oNF:_InfNfe:_Total:_icmsTot:_VIPI:TEXT")<>"U"
			cAux := "Valor do Ipi : " + oNF:_InfNfe:_Total:_icmsTot:_VIPI:TEXT
			While !Empty(cAux)
				aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
				cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
			EndDo
		EndIf      
	EndIf
	MsUnlock()
	DbSkip()
EndIf
*/
If lArt274SP .And. cX_ESTADO$"SP"   //SuperGetMv("MV_ESTADO")$"SP"
	If Type("oNF:_INFNFE:_TOTAL:_ICMSTOT:_VBCST:TEXT") <> "U"
		aLote := RastroNFOr(SD2->D2_DOC,SD2->D2_SERIE,SD2->D2_CLIENTE,SD2->D2_LOJA)
		If oNF:_INFNFE:_TOTAL:_ICMSTOT:_VBCST:TEXT <> "0" .Or. !Empty(aLote)
			cAux := "Imposto recolhido por Substituição - Art 274 do RICMS"
			If oNF:_INFNFE:_DEST:_ENDERDEST:_UF:TEXT == "SP"
				cAux += ": "				
				For nX := 1 To Len(aLote)
					nBaseICM := aLote[nX][33]
					nValICM  := aLote[nX][38]
					cAux += Alltrim(aLote[nX][3]) + " - BCST: " + AllTrim(TransForm(nBaseICM,TM(nBaseICM,TamSX3("D1_BRICMS")[1],TamSX3("D1_BRICMS")[2]))) + " e ICMSST: " + ;
									AllTrim(TransForm(nValICM,TM(nValICM,TamSX3("D1_ICMSRET")[1],TamSX3("D1_ICMSRET")[2]))) + "/ " 
				Next nX                      
			Endif
			While !Empty(cAux)
				aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
				cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
			EndDo
		Endif
	Endif
Endif     

/*
If MV_PAR04 == 2
	//impressao do valor do desconto calculdo conforme decreto 43.080/02 RICMS-MG
	nRecSF3 := SF3->(Recno())
	SF3->(dbSetOrder(4))
	SF3->(MsSeek(xFilial("SF3")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_DOC+SF2->F2_SERIE))
	While !SF3->(Eof()) .And. SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_DOC+SF2->F2_SERIE == SF3->F3_CLIEFOR+SF3->F3_LOJA+SF3->F3_NFISCAL+SF3->F3_SERIE
	    If SF3->(FieldPos("F3_DS43080"))<>0 .And. SF3->F3_DS43080 > 0
			cAux := "Base de calc.reduzida conf.Art.43, Anexo IV, Parte 1, Item 3 do RICMS-MG. Valor da deducao ICMS R$ " 
			cAux += Alltrim(Transform(SF3->F3_DS43080,"@e 9,999,999,999,999.99")) + " ref.reducao de base de calculo"  
			While !Empty(cAux)
				aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
				cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
			EndDo
	    EndIf
	    SF3->(dbSkip())
	EndDo
	SF3->(dbGoTo(nRecSF3))
ElseIf MV_PAR04 == 1
	//impressao do valor do desconto calculdo conforme decreto 43.080/02 RICMS-MG
	dbSelectArea("SF1")
	dbSetOrder(1)
	IF MsSeek(xFilial("SF1")+aNota[5]+aNota[4]+aNota[6]+aNota[7])
		dbSelectArea("SF3")
		dbSetOrder(4)
		If MsSeek(xFilial("SF3")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC+SF1->F1_SERIE)	                                                                                                                                      		
			If SF3->(FieldPos("F3_DS43080"))<>0 .And. SF3->F3_DS43080 > 0
				cAux := "Base de calc.reduzida conf.Art.43, Anexo IV, Parte 1, Item 3 do RICMS-MG. Valor da deducao ICMS R$ " 
				cAux += Alltrim(Transform(SF3->F3_DS43080,"@ze 9,999,999,999,999.99")) + " ref.reducao de base de calculo"  
				While !Empty(cAux)
					aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
					cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
				EndDo                                                                                                                                                               
		    EndIf                                                                                                                                  	
		EndIf 
	EndIf
EndIF
*/


For Nx := 1 to Len(aMensagem)
	NoChar(aMensagem[Nx],lConverte)
Next

If Type("oNF:_INFNFE:_IDE:_NFREF")<>"U"
	If Type("oNF:_INFNFE:_IDE:_NFREF") == "A"
		aInfNf := oNF:_INFNFE:_IDE:_NFREF
	Else
		aInfNf := {oNF:_INFNFE:_IDE:_NFREF}
	EndIf
	
	For nX := 1 to Len(aMensagem)
		If "ORIGINAL"$ Upper(aMensagem[nX])
			lNFori2 := .F.
		EndIf
	Next Nx
	
	cAux1 := ""
	cAux2 := ""
	For Nx := 1 to Len(aInfNf)
		If Type("aInfNf["+Str(nX)+"]:_REFNFE:TEXT")<>"U" .And. !AllTrim(aInfNf[nx]:_REFNFE:TEXT)$cAux1
			If !"CHAVE"$Upper(cAux1)
				If "65" $ substr (aInfNf[nx]:_REFNFE:TEXT,21,2)
					cAux1 += "Chave de acesso da NFC-E referenciada: "
				Else
					cAux1 += "Chave de acesso da NF-E referenciada: "
				Endif
			EndIf
			cAux1 += aInfNf[nx]:_REFNFE:TEXT+","
		ElseIf Type("aInfNf["+Str(nX)+"]:_REFNF:_NNF:TEXT")<>"U" .And. !AllTrim(aInfNf[nx]:_REFNF:_NNF:TEXT)$cAux2 .And. lNFori2
			If !"ORIGINAL"$Upper(cAux2)
				cAux2 += " Numero da nota original: "
			EndIf
			cAux2 += aInfNf[nx]:_REFNF:_NNF:TEXT+","
		EndIf
	Next
	
	cAux	:=	""
	If !Empty(cAux1)
		cAux1	:=	Left(cAux1,Len(cAux1)-1)
		cAux 	+= cAux1
	EndIf
	If !Empty(cAux2)
		cAux2	:=	Left(cAux2,Len(cAux2)-1)
		cAux 	+= 	Iif(!Empty(cAux),CRLF,"")+cAux2
	EndIf
	
	While !Empty(cAux)
		aadd(aMensagem,SubStr(cAux,1,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN) - 1, MAXMENLIN)))
		cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, EspacoAt(cAux, MAXMENLIN), MAXMENLIN) + 1)
	EndDo

  	For Nx := 1 to Len(aMensagem)
   		NoChar(aMensagem[Nx],lConverte)
	Next

EndIf

//³Quadro "RESERVADO AO FISCO"                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aResFisco := {}
nBaseIcm  := 0

If GetNewPar("MV_BCREFIS",.F.) .And. cX_ESTADO$"PR"  //SuperGetMv("MV_ESTADO")$"PR"
	If Val(&("oTotal:_ICMSTOT:_VBCST:TEXT")) <> 0
		cAux := "Substituição Tributária: Art. 471, II e §1º do RICMS/PR: "
   		nLenDet := Len(oDet)
   		For nX := 1 To nLenDet
	   		oImposto := oDet[nX]
	   		If Type("oImposto:_Imposto")<>"U"
		 		If Type("oImposto:_Imposto:_ICMS")<>"U"
		 			nLenSit := Len(aSitTrib)
		 			For nY := 1 To nLenSit
		 				nPrivate2 := nY
		 				If Type("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nPrivate2])<>"U"
		 					If Type("oImposto:_IMPOSTO:_ICMS:_ICMS"+aSitTrib[nPrivate2]+":_VBCST:TEXT")<>"U"
		 		   				nBaseIcm := Val(&("oImposto:_Imposto:_ICMS:_ICMS"+aSitTrib[nY]+":_VBCST:TEXT"))
		 						cAux += oDet[nX]:_PROD:_CPROD:TEXT + ": BCICMS-ST R$" + AllTrim(TransForm(nBaseICM,TM(nBaseICM,TamSX3("D2_BASEICM")[1],TamSX3("D2_BASEICM")[2]))) + " / "	
   		 	  				Endif
   		 	 			Endif
   					Next nY
   	   			Endif
   	 		Endif
   	   	Next nX
	Endif
	While !Empty(cAux)   
 		aadd(aResFisco,SubStr(cAux,1,60))
   		cAux := SubStr(cAux,IIf(EspacoAt(cAux, MAXMENLIN) > 1, 59, MAXMENLIN) +2)
	EndDo	
Endif
       
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calculo do numero de folhas                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
nFolhas	  := 1
nLenItens := Len(aItens) - MAXITEM // Todos os produtos/serviços excluindo a primeira página
nMsgCompl := Len(aMensagem) - MAXMSG // Todas as mensagens complementares excluindo a primeira página
lFlag     := .T.
While lFlag
	// Caso existam produtos/serviços e mensagens complementares a serem escritas
	If nLenItens > 0 .And. nMsgCompl > 0
		nFolhas++
		// Se estiver habilitado frente e verso e for uma página impar
		If MV_PAR05 == 1 .And. (nFolhas % 2) == 0
			nLenItens -= MAXITEMP3
		Else
			nLenItens -= MAXITEMP2
			nMsgCompl -= MAXMSG
		EndIf
	// Caso existam apenas mensagens complementares a serem escritas
	ElseIf nLenItens <= 0 .And. nMsgCompl > 0
		nFolhas++
		nMsgCompl := 0
	// Caso existam apenas produtos/serviços a serem escritos
	ElseIf nLenItens > 0 .And. nMsgCompl <= 0
		nFolhas++
		// Se estiver habilitado frente e verso e for uma página impar
		If MV_PAR05 == 1 .And. (nFolhas % 2) == 0
			nLenItens -= MAXITEMP3
		Else
			nLenItens -= MAXITEMP2F
		EndIf
	// Se não tiver mais nada a ser escrito fecha a contagem
	Else
		lFlag := .F.
	EndIf
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializacao do objeto grafico                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oDanfe == Nil
	lPreview := .T.
	oDanfe 	:= FWMSPrinter():New("DANFE", IMP_SPOOL)
	oDanfe:SetPortrait()
	oDanfe:Setup()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializacao da pagina do objeto grafico                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDanfe:StartPage()
nHPage := oDanfe:nHorzRes()
nHPage *= (300/PixelX)
nHPage -= HMARGEM
nVPage := oDanfe:nVertRes()
nVPage *= (300/PixelY)
nVPage -= VBOX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Definicao do Box - Recibo de entrega                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oDanfe:Box(000,000,010,501)
oDanfe:Say(006, 002, "RECEBEMOS DE "+NoChar(oEmitente:_xNome:Text,lConverte)+" OS PRODUTOS CONSTANTES DA NOTA FISCAL INDICADA AO LADO", oFont07:oFont)
oDanfe:Box(009,000,037,101)
oDanfe:Say(017, 002, "DATA DE RECEBIMENTO", oFont07N:oFont)
oDanfe:Box(009,100,037,500)
oDanfe:Say(017, 102, "IDENTIFICAÇÃO E ASSINATURA DO RECEBEDOR", oFont07N:oFont)
oDanfe:Box(000,500,037,603)
oDanfe:Say(007, 542, "NF-e", oFont08N:oFont)
oDanfe:Say(017, 510, "N. "+StrZero(Val(oIdent:_NNf:Text),9), oFont08:oFont)
oDanfe:Say(027, 510, "SÉRIE "+oIdent:_Serie:Text, oFont08:oFont)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro 1 IDENTIFICACAO DO EMITENTE                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDanfe:Box(042,000,137,250)
oDanfe:Say(052,098, "Identificação do emitente",oFont12N:oFont)
nLinCalc	:=	065
cStrAux		:=	AllTrim(NoChar(oEmitente:_xNome:Text,lConverte))
nForTo		:=	Len(cStrAux)/25
nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
For nX := 1 To nForTo
	oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*25)+1),25), oFont12N:oFont )
	nLinCalc+=10
Next nX

cStrAux		:=	AllTrim(NoChar(oEmitente:_EnderEmit:_xLgr:Text,lConverte))+", "+AllTrim(oEmitente:_EnderEmit:_Nro:Text)
nForTo		:=	Len(cStrAux)/40
nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
For nX := 1 To nForTo
	oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*40)+1),40),oFont08N:oFont)
	nLinCalc+=10
Next nX

If Type("oEmitente:_EnderEmit:_xCpl") <> "U"
	cStrAux		:=	"Complemento: "+AllTrim(NoChar(oEmitente:_EnderEmit:_xCpl:TEXT,lConverte))
	nForTo		:=	Len(cStrAux)/40
	nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
	For nX := 1 To nForTo
		oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*40)+1),40),oFont08N:oFont)
		nLinCalc+=10
	Next nX
	
	cStrAux		:=	AllTrim(oEmitente:_EnderEmit:_xBairro:Text)
	If Type("oEmitente:_EnderEmit:_Cep")<>"U"
		cStrAux		+=	" Cep:"+TransForm(oEmitente:_EnderEmit:_Cep:Text,"@r 99999-999")
	EndIf
	nForTo		:=	Len(cStrAux)/40
	nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
	For nX := 1 To nForTo
		oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*40)+1),40),oFont08N:oFont)
		nLinCalc+=10
	Next nX
	oDanfe:Say(nLinCalc,098, oEmitente:_EnderEmit:_xMun:Text+"/"+oEmitente:_EnderEmit:_UF:Text,oFont08N:oFont)
	nLinCalc+=10
	oDanfe:Say(nLinCalc,098, "Fone: "+IIf(Type("oEmitente:_EnderEmit:_Fone")=="U","",oEmitente:_EnderEmit:_Fone:Text),oFont08N:oFont)
Else
	oDanfe:Say(nLinCalc,098, NoChar(oEmitente:_EnderEmit:_xBairro:Text,lConverte)+" Cep:"+TransForm(IIF(Type("oEmitente:_EnderEmit:_Cep")=="U","",oEmitente:_EnderEmit:_Cep:Text),"@r 99999-999"),oFont08N:oFont)
	nLinCalc+=10
	oDanfe:Say(nLinCalc,098, oEmitente:_EnderEmit:_xMun:Text+"/"+oEmitente:_EnderEmit:_UF:Text,oFont08N:oFont)
	nLinCalc+=10
	oDanfe:Say(nLinCalc,098, "Fone: "+IIf(Type("oEmitente:_EnderEmit:_Fone")=="U","",oEmitente:_EnderEmit:_Fone:Text),oFont08N:oFont)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro 2                                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oDanfe:Box(042,248,137,351)
oDanfe:Say(055,275, "DANFE",oFont18N:oFont)
oDanfe:Say(065,258, "DOCUMENTO AUXILIAR DA",oFont07:oFont)
oDanfe:Say(075,258, "NOTA FISCAL ELETRÔNICA",oFont07:oFont)
oDanfe:Say(085,266, "0-ENTRADA",oFont08:oFont)
oDanfe:Say(095,266, "1-SAÍDA"  ,oFont08:oFont)
oDanfe:Box(078,315,095,325)
oDanfe:Say(089,318, oIdent:_TpNf:Text,oFont08N:oFont)
oDanfe:Say(110,255,"N. "+StrZero(Val(oIdent:_NNf:Text),9),oFont10N:oFont)
oDanfe:Say(120,255,"SÉRIE "+oIdent:_Serie:Text,oFont10N:oFont)
oDanfe:Say(130,255,"FOLHA "+StrZero(nFolha,2)+"/"+StrZero(nFolhas,2),oFont10N:oFont)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Preenchimento do Array de UF                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aadd(aUF,{"RO","11"})
aadd(aUF,{"AC","12"})
aadd(aUF,{"AM","13"})
aadd(aUF,{"RR","14"})
aadd(aUF,{"PA","15"})
aadd(aUF,{"AP","16"})
aadd(aUF,{"TO","17"})
aadd(aUF,{"MA","21"})
aadd(aUF,{"PI","22"})
aadd(aUF,{"CE","23"})
aadd(aUF,{"RN","24"})
aadd(aUF,{"PB","25"})
aadd(aUF,{"PE","26"})
aadd(aUF,{"AL","27"})
aadd(aUF,{"MG","31"})
aadd(aUF,{"ES","32"})
aadd(aUF,{"RJ","33"})
aadd(aUF,{"SP","35"})
aadd(aUF,{"PR","41"})
aadd(aUF,{"SC","42"})
aadd(aUF,{"RS","43"})
aadd(aUF,{"MS","50"})
aadd(aUF,{"MT","51"})
aadd(aUF,{"GO","52"})
aadd(aUF,{"DF","53"})
aadd(aUF,{"SE","28"})
aadd(aUF,{"BA","29"})
aadd(aUF,{"EX","99"})

nHPage := oDanfe:nHorzRes()
nHPage *= (300/PixelX)
nHPage -= HMARGEM
nVPage := oDanfe:nVertRes()
nVPage *= (300/PixelY)
nVPage -= VBOX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Logotipo                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cXM_USALOGO := GetNewPar("XM_LOGOD", "N" )	//FR - 17/12/2021 - #Chamado 11661 - TEBE
//If (GetNewPar("XM_LOGOD", "N" ) == "S")
If cXM_USALOGO == "S"
	If lMv_Logod
		cGrpCompany	:= AllTrim(FWGrpCompany())
		cCodEmpGrp	:= AllTrim(FWCodEmp())
		cUnitGrp	:= AllTrim(FWUnitBusiness())
		cFilGrp		:= AllTrim(FWFilial())

		If !Empty(cUnitGrp)
			cDescLogo	:= cGrpCompany + cCodEmpGrp + cUnitGrp + cFilGrp
		Else
			cDescLogo	:= cEmpAnt + cFilAnt
		EndIf

		cLogoD := GetSrvProfString("Startpath","") + "DANFE" + cDescLogo + ".BMP"
		If !File(cLogoD)
			cLogoD	:= GetSrvProfString("Startpath","") + "DANFE" + cEmpAnt + ".BMP"
			If !File(cLogoD)
				lMv_Logod := .F.
			EndIf
		EndIf
	EndIf

	//If nfolha==1   //FR - 17/12/2021 - #Chamado 11661 - TEBE - IMPRESSÃO LOGOTIPO SÓ FICAVA OK NA PÁGINA 1, ENTÃO COMENTEI ESTA PARTE PARA IMPRIMIR CERTO EM TODAS AS PÁGINAS
		If lMv_Logod
			oDanfe:SayBitmap(045,005,cLogoD,090,090)
		Else
			oDanfe:SayBitmap(045,005,cLogo,090,090)
		EndIF
	//Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Codigo de barra                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oDanfe:Box(042,350,088,603)
oDanfe:Box(075,350,110,603)
oDanfe:Say(095,355,TransForm(SubStr(oNF:_InfNfe:_ID:Text,4),"@r 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999"),oFont12N:oFont)
oDanfe:Box(105,350,137,603)

If nFolha == 1
	oDanfe:Say(085,355,"CHAVE DE ACESSO DA NF-E",oFont12N:oFont)
	nFontSize := 28
	oDanfe:Code128C(072,370,SubStr(oNF:_InfNfe:_ID:Text,4), nFontSize )
EndIf

If !Empty(cCodAutDPEC) .And. (oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"4" .And. !lUsaColab
	cDataEmi := Iif(oNF:_INFNFE:_VERSAO:TEXT >= "3.10",Substr(oNFe:_NFE:_INFNFE:_IDE:_DHEMI:Text,9,2),Substr(oNFe:_NFE:_INFNFE:_IDE:_DEMI:Text,9,2))
	cTPEmis  := "4"
	
	If Type("oDPEC:_ENVDPEC:_INFDPEC:_RESNFE") <> "U"
		cUF      := aUF[aScan(aUF,{|x| x[1] == oDPEC:_ENVDPEC:_INFDPEC:_RESNFE:_UF:Text})][02]
		cValIcm := StrZero(Val(StrTran(oDPEC:_ENVDPEC:_INFDPEC:_RESNFE:_VNF:TEXT,".","")),14)
		cICMSp := iif(Val(oDPEC:_ENVDPEC:_INFDPEC:_RESNFE:_VICMS:TEXT)>0,"1","2")
		cICMSs := iif(Val(oDPEC:_ENVDPEC:_INFDPEC:_RESNFE:_VST:TEXT)>0,"1","2")
	ElseIf type ("oDPEC:_EVENTO:_INFEVENTO:_DETEVENTO:_DEST") <> "U" //EPEC NFE
		If Type ("oDPEC:_EVENTO:_INFEVENTO:_DETEVENTO:_DEST:_UF:TEXT") <> "U"
			cUF := aUF[aScan(aUF,{|x| x[1] == oDPEC:_EVENTO:_INFEVENTO:_DETEVENTO:_DEST:_UF:TEXT})][02]			
		EndIf
		If Type ("oDPEC:_EVENTO:_INFEVENTO:_DETEVENTO:_DEST:_VNF:TEXT") <> "U"
			cValIcm := StrZero(Val(StrTran(oDPEC:_EVENTO:_INFEVENTO:_DETEVENTO:_DEST:_VNF:TEXT,".","")),14)
		EndIf
		If 	Type ("oDPEC:_EVENTO:_INFEVENTO:_DETEVENTO:_DEST:_VICMS:TEXT") <> "U"
			cICMSp:= IIf(Val(oDPEC:_EVENTO:_INFEVENTO:_DETEVENTO:_DEST:_VICMS:TEXT) > 0,"1","2")
		EndIf
		If 	Type ("oDPEC:_EVENTO:_INFEVENTO:_DETEVENTO:_DEST:_VST:TEXT") <> "U"
			cICMSs := IIf(Val(oDPEC:_EVENTO:_INFEVENTO:_DETEVENTO:_DEST:_VST:TEXT )> 0,"1","2")
		EndIf	
	EndIf	
	
ElseIF (oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"25" .Or. ( (oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"4" .And. lUsaColab .And. !Empty(cCodAutDPEC) )
	cUF      := aUF[aScan(aUF,{|x| x[1] == oNFe:_NFE:_INFNFE:_DEST:_ENDERDEST:_UF:Text})][02]
	cDataEmi := Iif(oNF:_INFNFE:_VERSAO:TEXT >= "3.10",Substr(oNFe:_NFE:_INFNFE:_IDE:_DHEMI:Text,9,2),Substr(oNFe:_NFE:_INFNFE:_IDE:_DEMI:Text,9,2))
	cTPEmis  := oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT
	cValIcm  := StrZero(Val(StrTran(oNFe:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VNF:TEXT,".","")),14)
	cICMSp   := iif(Val(oNFe:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VICMS:TEXT)>0,"1","2")
	cICMSs   :=iif(Val(oNFe:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VST:TEXT)>0,"1","2")
EndIf
If !Empty(cUF) .And. !Empty(cDataEmi) .And. !Empty(cTPEmis) .And. !Empty(cValIcm) .And. !Empty(cICMSp) .And. !Empty(cICMSs)
	If Type("oNF:_InfNfe:_DEST:_CNPJ:Text")<>"U"
		cCNPJCPF := oNF:_InfNfe:_DEST:_CNPJ:Text
		If cUf == "99"
			cCNPJCPF := STRZERO(val(cCNPJCPF),14)
		EndIf
	ElseIf Type("oNF:_INFNFE:_DEST:_CPF:Text")<>"U"
		cCNPJCPF := oNF:_INFNFE:_DEST:_CPF:Text
		cCNPJCPF := STRZERO(val(cCNPJCPF),14)
	Else
		cCNPJCPF := ""
	EndIf
	cChaveCont += cUF+cTPEmis+cCNPJCPF+cValIcm+cICMSp+cICMSs+cDataEmi
	cChaveCont := cChaveCont+Modulo11(cChaveCont)
EndIf

If Empty(cCodAutDPEC)
	If Empty(cChaveCont)
		oDanfe:Say(117,355,"Consulta de autenticidade no portal nacional da NF-e",oFont12:oFont)
		oDanfe:Say(127,355,"www.nfe.fazenda.gov.br/portal ou no site da SEFAZ Autorizada",oFont12:oFont)
	Endif
Endif

If  !Empty(cCodAutDPEC)
	oDanfe:Say(117,355,"Consulta de autenticidade no portal nacional da NF-e",oFont12:oFont)
	oDanfe:Say(127,355,"www.nfe.fazenda.gov.br/portal ou no site da SEFAZ Autorizada",oFont12:oFont)
Endif

// inicio do segundo codigo de barras ref. a transmissao CONTIGENCIA OFF LINE
If !Empty(cChaveCont) .And. Empty(cCodAutDPEC) .And. !(Val(oNF:_INFNFE:_IDE:_SERIE:TEXT) >= 900)
	If nFolha == 1
		If !Empty(cChaveCont)
			nFontSize := 28
			oDanfe:Code128C(135,370,cChaveCont, nFontSize )
		EndIf
	Else
		If !Empty(cChaveCont)
			nFontSize := 28
			oDanfe:Code128C(112,370,cChaveCont, nFontSize )
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro 4                                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oDanfe:Box(139,000,162,603)
oDanfe:Box(139,000,162,350)
oDanfe:Say(148,002,"NATUREZA DA OPERAÇÃO",oFont08N:oFont)
oDanfe:Say(158,002,oIdent:_NATOP:TEXT,oFont08:oFont)


If !Empty(cCodAutDPEC)
	oDanfe:Say(148,352,"NÚMERO DE REGISTRO DPEC",oFont08N:oFont)
Endif

If Empty(cCodAutDPEC) .And. (((Val(oNF:_INFNFE:_IDE:_SERIE:TEXT) >= 900).And.(oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"23") .Or. (oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"1|6|7")
	oDanfe:Say(148,352,"PROTOCOLO DE AUTORIZAÇÃO DE USO",oFont08N:oFont)
Endif
If((oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"25")
	oDanfe:Say(148,352,"DADOS DA NF-E",oFont08N:oFont)
Endif
oDanfe:Say(158,354,IIF(!Empty(cCodAutDPEC),cCodAutDPEC+" "+AllTrim(IIF(!Empty(dDtReceb),ConvDate(DTOS(dDtReceb)),Iif(oNF:_INFNFE:_VERSAO:TEXT >= "3.10",ConvDate(oNF:_InfNfe:_IDE:_DHEMI:Text),ConvDate(oNF:_InfNfe:_IDE:_DEMI:Text))))+" "+AllTrim(cDtHrRecCab),IIF(!Empty(cCodAutSef) .And. ((Val(oNF:_INFNFE:_IDE:_SERIE:TEXT) >= 900).And.(oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"23") .Or. (oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"1|6|7",cCodAutSef+" "+AllTrim(IIF(!Empty(dDtReceb),ConvDate(DTOS(dDtReceb)),Iif(oNF:_INFNFE:_VERSAO:TEXT >= "3.10",ConvDate(oNF:_InfNfe:_IDE:_DHEMI:Text),ConvDate(oNF:_InfNfe:_IDE:_DEMI:Text))))+" "+AllTrim(cDtHrRecCab),TransForm(cChaveCont,"@r 9999 9999 9999 9999 9999 9999 9999 9999 9999"))),oFont08:oFont)

nFolha++


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro 5                                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDanfe:Box(164,000,187,603)
oDanfe:Box(164,000,187,200)
oDanfe:Box(164,200,187,400)
oDanfe:Box(164,400,187,603)
oDanfe:Say(172,002,"INSCRIÇÃO ESTADUAL",oFont08N:oFont)
oDanfe:Say(180,002,IIf(Type("oEmitente:_IE:TEXT")<>"U",oEmitente:_IE:TEXT,""),oFont08:oFont)
oDanfe:Say(172,205,"INSC.ESTADUAL DO SUBST.TRIB.",oFont08N:oFont)
oDanfe:Say(180,205,IIf(Type("oEmitente:_IEST:TEXT")<>"U",oEmitente:_IEST:TEXT,""),oFont08:oFont)
oDanfe:Say(172,405,"CNPJ/CPF",oFont08N:oFont)
If Type("oEmitente:_CNPJ:TEXT") <> "U"
	oDanfe:Say(180,405,TransForm(oEmitente:_CNPJ:TEXT,IIf(Len(oEmitente:_CNPJ:TEXT)<>14,"@r 999.999.999-99","@r 99.999.999/9999-99")),oFont08:oFont)
Else 
	oDanfe:Say(180,405,TransForm(oEmitente:_CPF:TEXT,IIf(Len(oEmitente:_CPF:TEXT)<>14,"@r 999.999.999-99","@r 99.999.999/9999-99")),oFont08:oFont)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro destinatário/remetente                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
	Case Type("oDestino:_CNPJ")=="O"
		cAux := TransForm(oDestino:_CNPJ:TEXT,"@r 99.999.999/9999-99")
	Case Type("oDestino:_CPF")=="O"
		cAux := TransForm(oDestino:_CPF:TEXT,"@r 999.999.999-99")
	OtherWise
		cAux := Space(14)
EndCase


oDanfe:Say(195,002,"DESTINATARIO/REMETENTE",oFont08N:oFont)
oDanfe:Box(197,000,217,450)
oDanfe:Say(205,002, "NOME/RAZÃO SOCIAL",oFont08N:oFont)
oDanfe:Say(215,002,NoChar(oDestino:_XNome:TEXT,lConverte),oFont08:oFont)
oDanfe:Box(197,280,217,500)
oDanfe:Say(205,283,"CNPJ/CPF",oFont08N:oFont)
oDanfe:Say(215,283,cAux,oFont08:oFont)

oDanfe:Box(217,000,237,500)
oDanfe:Box(217,000,237,260)
oDanfe:Say(224,002,"ENDEREÇO",oFont08N:oFont)
oDanfe:Say(234,002,aDest[01],oFont08:oFont)
oDanfe:Box(217,230,237,380)
oDanfe:Say(224,232,"BAIRRO/DISTRITO",oFont08N:oFont)
oDanfe:Say(234,232,aDest[02],oFont08:oFont)
oDanfe:Box(217,380,237,500)
oDanfe:Say(224,382,"CEP",oFont08N:oFont)
oDanfe:Say(234,382,aDest[03],oFont08:oFont)

oDanfe:Box(236,000,257,500)
oDanfe:Box(236,000,257,180)
oDanfe:Say(245,002,"MUNICIPIO",oFont08N:oFont)
oDanfe:Say(255,002,aDest[05],oFont08:oFont)
oDanfe:Box(236,150,257,256)
oDanfe:Say(245,152,"FONE/FAX",oFont08N:oFont)
oDanfe:Say(255,152,aDest[06],oFont08:oFont)
oDanfe:Box(236,255,257,341)
oDanfe:Say(245,257,"UF",oFont08N:oFont)
oDanfe:Say(255,257,aDest[07],oFont08:oFont)
oDanfe:Box(236,340,257,500)
oDanfe:Say(245,342,"INSCRIÇÃO ESTADUAL",oFont08N:oFont)
oDanfe:Say(255,342,aDest[08],oFont08:oFont)


oDanfe:Box(197,502,217,603)
oDanfe:Say(205,504,"DATA DE EMISSÃO",oFont08N:oFont)
oDanfe:Say(215,504,Iif(oNF:_INFNFE:_VERSAO:TEXT >= "3.10",ConvDate(oIdent:_DHEmi:TEXT),ConvDate(oIdent:_DEmi:TEXT)),oFont08:oFont)
oDanfe:Box(217,502,237,603)
oDanfe:Say(224,504,"DATA ENTRADA/SAÍDA",oFont08N:oFont)
oDanfe:Say(233,504,Iif( Empty(aDest[4]),"",ConvDate(aDest[4]) ),oFont08:oFont)
oDanfe:Box(236,502,257,603)
oDanfe:Say(243,503,"HORA ENTRADA/SAÍDA",oFont08N:oFont)
oDanfe:Say(252,503,aHrEnt[01],oFont08:oFont)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro fatura                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAux := {{{},{},{},{},{},{},{},{},{}}}
nY := 0
For nX := 1 To Len(aFaturas)
	nY++
	aadd(Atail(aAux)[nY],aFaturas[nX][1])
	nY++
	aadd(Atail(aAux)[nY],aFaturas[nX][2])
	nY++
	aadd(Atail(aAux)[nY],aFaturas[nX][3])
	nY++
	aadd(Atail(aAux)[nY],aFaturas[nX][4])
	nY++
	aadd(Atail(aAux)[nY],aFaturas[nX][5])
	nY++
	aadd(Atail(aAux)[nY],aFaturas[nX][6])
	nY++
	aadd(Atail(aAux)[nY],aFaturas[nX][7])
	nY++
	aadd(Atail(aAux)[nY],aFaturas[nX][8])
	nY++
	aadd(Atail(aAux)[nY],aFaturas[nX][9])
	If nY >= 9
		nY := 0
	EndIf
Next nX

oDanfe:Say(263,002,"FATURA",oFont08N:oFont)
oDanfe:Box(265,000,296,068)
oDanfe:Box(265,067,296,134)
oDanfe:Box(265,134,296,202)
oDanfe:Box(265,201,296,268)
oDanfe:Box(265,268,296,335)
oDanfe:Box(265,335,296,403)
oDanfe:Box(265,402,296,469)
oDanfe:Box(265,469,296,537)
oDanfe:Box(265,536,296,603)

nColuna := 002
If Len(aFaturas) >0
	For nY := 1 To 9
		oDanfe:Say(273,nColuna,aAux[1][nY][1],oFont08:oFont)
		oDanfe:Say(281,nColuna,aAux[1][nY][2],oFont08:oFont)
		oDanfe:Say(289,nColuna,aAux[1][nY][3],oFont08:oFont)
		nColuna:= nColuna+67
	Next nY
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calculo do imposto                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDanfe:Say(305,002,"CALCULO DO IMPOSTO",oFont08N:oFont)
oDanfe:Box(307,000,330,121)
oDanfe:Say(316,002,"BASE DE CALCULO DO ICMS",oFont08N:oFont)
If cMVCODREG $ "3" 
	oDanfe:Say(326,002,aTotais[01],oFont08:oFont)
ElseIf lImpSimpN
	oDanfe:Say(326,002,aSimpNac[01],oFont08:oFont)	
Endif
oDanfe:Box(307,120,330,200)
oDanfe:Say(316,125,"VALOR DO ICMS",oFont08N:oFont)
If cMVCODREG $ "3" 
	oDanfe:Say(326,125,aTotais[02],oFont08:oFont)
ElseIf lImpSimpN
	oDanfe:Say(326,125,aSimpNac[02],oFont08:oFont)
Endif
oDanfe:Box(307,199,330,360)
oDanfe:Say(316,200,"BASE DE CALCULO DO ICMS SUBSTITUIÇÃO",oFont08N:oFont)
oDanfe:Say(326,202,aTotais[03],oFont08:oFont)
oDanfe:Box(307,360,330,490)
oDanfe:Say(316,363,"VALOR DO ICMS SUBSTITUIÇÃO",oFont08N:oFont)
oDanfe:Say(326,363,aTotais[04],oFont08:oFont)
oDanfe:Box(307,490,330,603)
oDanfe:Say(316,491,"VALOR TOTAL DOS PRODUTOS",oFont08N:oFont)
oDanfe:Say(327,491,aTotais[05],oFont08:oFont)


oDanfe:Box(330,000,353,110)
oDanfe:Say(339,002,"VALOR DO FRETE",oFont08N:oFont)
oDanfe:Say(349,002,aTotais[06],oFont08:oFont)
oDanfe:Box(330,100,353,190)
oDanfe:Say(339,102,"VALOR DO SEGURO",oFont08N:oFont)
oDanfe:Say(349,102,aTotais[07],oFont08:oFont)
oDanfe:Box(330,190,353,290)
oDanfe:Say(339,194,"DESCONTO",oFont08N:oFont)
oDanfe:Say(349,194,aTotais[08],oFont08:oFont)
oDanfe:Box(330,290,353,415)
oDanfe:Say(339,295,"OUTRAS DESPESAS ACESSÓRIAS",oFont08N:oFont)
oDanfe:Say(349,295,aTotais[09],oFont08:oFont)
oDanfe:Box(330,414,353,500)
oDanfe:Say(339,420,"VALOR DO IPI",oFont08N:oFont)
oDanfe:Say(349,420,aTotais[10],oFont08:oFont)
oDanfe:Box(330,500,353,603)
oDanfe:Say(339,506,"VALOR TOTAL DA NOTA",oFont08N:oFont)
oDanfe:Say(349,506,aTotais[11],oFont08:oFont)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Transportador/Volumes transportados                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDanfe:Say(361,002,"TRANSPORTADOR/VOLUMES TRANSPORTADOS",oFont08N:oFont)
oDanfe:Box(363,000,386,603)
oDanfe:Say(372,002,"RAZÃO SOCIAL",oFont08N:oFont)
oDanfe:Say(382,002,aTransp[01],oFont08:oFont)
oDanfe:Box(363,245,386,315)
oDanfe:Say(372,247,"FRETE POR CONTA",oFont08N:oFont)
If cModFrete =="0"
	oDanfe:Say(382,247,"0-EMITENTE",oFont08:oFont)
ElseIf cModFrete =="1"
	oDanfe:Say(382,247,"1-DEST/REM",oFont08:oFont)
ElseIf cModFrete =="2"
	oDanfe:Say(382,247,"2-TERCEIROS",oFont08:oFont)
ElseIf cModFrete =="9"
	oDanfe:Say(382,247,"9-SEM FRETE",oFont08:oFont)
Else
	oDanfe:Say(382,247,"",oFont08:oFont)
Endif
//oDanfe:Say(382,102,"0-EMITENTE/1-DESTINATARIO       [" + aTransp[02] + "]",oFont08:oFont)
oDanfe:Box(363,315,386,370)
oDanfe:Say(372,317,"CÓDIGO ANTT",oFont08N:oFont)
oDanfe:Say(382,319,aTransp[03],oFont08:oFont)
oDanfe:Box(363,370,386,490)
oDanfe:Say(372,375,"PLACA DO VEÍCULO",oFont08N:oFont)
oDanfe:Say(382,375,aTransp[04],oFont08:oFont)
oDanfe:Box(363,450,386,510)
oDanfe:Say(372,452,"UF",oFont08N:oFont)
oDanfe:Say(382,452,aTransp[05],oFont08:oFont)
oDanfe:Box(363,510,386,603)
oDanfe:Say(372,512,"CNPJ/CPF",oFont08N:oFont)
oDanfe:Say(382,512,aTransp[06],oFont08:oFont)

oDanfe:Box(385,000,409,603)
oDanfe:Box(385,000,409,241)
oDanfe:Say(393,002,"ENDEREÇO",oFont08N:oFont)
oDanfe:Say(404,002,aTransp[07],oFont08:oFont)
oDanfe:Box(385,240,409,341)
oDanfe:Say(393,242,"MUNICIPIO",oFont08N:oFont)
oDanfe:Say(404,242,aTransp[08],oFont08:oFont)
oDanfe:Box(385,340,409,440)
oDanfe:Say(393,342,"UF",oFont08N:oFont)
oDanfe:Say(404,342,aTransp[09],oFont08:oFont)
oDanfe:Box(385,440,409,603)
oDanfe:Say(393,442,"INSCRIÇÃO ESTADUAL",oFont08N:oFont)
oDanfe:Say(404,442,aTransp[10],oFont08:oFont)


oDanfe:Box(408,000,432,603)
oDanfe:Box(408,000,432,101)
oDanfe:Say(418,002,"QUANTIDADE",oFont08N:oFont)
oDanfe:Say(428,002,aTransp[11],oFont08:oFont)
oDanfe:Box(408,100,432,200)
oDanfe:Say(418,102,"ESPECIE",oFont08N:oFont)
oDanfe:Say(428,102,Iif(!Empty(aTransp[12]),aTransp[12],Iif(Len(aEspVol)>0,aEspVol[1][1],"")),oFont08:oFont)
//oDanfe:Say(428,102,aEspVol[1][1],oFont08:oFont)
oDanfe:Box(408,200,432,301)
oDanfe:Say(418,202,"MARCA",oFont08N:oFont)
oDanfe:Say(428,202,aTransp[13],oFont08:oFont)
oDanfe:Box(408,300,432,400)
oDanfe:Say(418,302,"NUMERAÇÃO",oFont08N:oFont)
oDanfe:Say(428,302,aTransp[14],oFont08:oFont)
oDanfe:Box(408,400,432,501)
oDanfe:Say(418,402,"PESO BRUTO",oFont08N:oFont)
oDanfe:Say(428,402,Iif(!Empty(aTransp[15]),aTransp[15],Iif(Len(aEspVol)>0 .And. Val(aEspVol[1][3])>0,Transform(Val(aEspVol[1][3]),"@E 999999.9999"),"")),oFont08:oFont)
//oDanfe:Say(428,402,Iif (!Empty(aEspVol[1][3]),Transform(val(aEspVol[1][3]),"@E 999999.9999"),""),oFont08:oFont)
oDanfe:Box(408,500,432,603)
oDanfe:Say(418,502,"PESO LIQUIDO",oFont08N:oFont)
oDanfe:Say(428,502,Iif(!Empty(aTransp[16]),aTransp[16],Iif(Len(aEspVol)>0 .And. Val(aEspVol[1][2])>0,Transform(Val(aEspVol[1][2]),"@E 999999.9999"),"")),oFont08:oFont)
//oDanfe:Say(428,502,Iif (!Empty(aEspVol[1][2]),Transform(val(aEspVol[1][2]),"@E 999999.9999"),""),oFont08:oFont)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calculo do ISSQN                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oDanfe:Say(686,000,"CALCULO DO ISSQN",oFont08N:oFont)
oDanfe:Box(688,000,711,151)
oDanfe:Say(696,002,"INSCRIÇÃO MUNICIPAL",oFont08N:oFont)
oDanfe:Say(706,002,aISSQN[1],oFont08:oFont)
oDanfe:Box(688,150,711,301)
oDanfe:Say(696,152,"VALOR TOTAL DOS SERVIÇOS",oFont08N:oFont)
oDanfe:Say(706,152,aISSQN[2],oFont08:oFont)
oDanfe:Box(688,300,711,451)
oDanfe:Say(696,302,"BASE DE CÁLCULO DO ISSQN",oFont08N:oFont)
oDanfe:Say(706,302,aISSQN[3],oFont08:oFont)
oDanfe:Box(688,450,711,603)
oDanfe:Say(696,452,"VALOR DO ISSQN",oFont08N:oFont)
oDanfe:Say(706,452,aISSQN[4],oFont08:oFont)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Dados Adicionais                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDanfe:Say(719,000,"DADOS ADICIONAIS",oFont08N:oFont)
oDanfe:Box(721,000,865,351)
oDanfe:Say(729,002,"INFORMAÇÕES COMPLEMENTARES",oFont08N:oFont)

nLenMensagens:= Len(aMensagem)
nLin:= 741
nMensagem := 0
For nX := 1 To Min(nLenMensagens, MAXMSG)
	oDanfe:Say(nLin,002,aMensagem[nX],oFont08:oFont)
	nLin:= nLin+10
Next nX
nMensagem := nX

oDanfe:Box(721,350,865,603)
oDanfe:Say(729,352,"RESERVADO AO FISCO",oFont08N:oFont)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Logotipo Rodape
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ												
if file(cLogoTotvs) .or. Resource2File ( cLogoTotvs, cStartPath+cLogoTotvs )
	oDanfe:SayBitmap(866,484,cLogoTotvs,120,20)
endif	
				
nLenMensagens:= Len(aResFisco)
nLin:= 741
For nX := 1 To Min(nLenMensagens, MAXMSG)
	oDanfe:Say(nLin,351,aResFisco[nX],oFont08:oFont)
	nLin:= nLin+10
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Dados do produto ou servico                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//aAux := {{{},{},{},{},{},{},{},{},{},{},{},{},{},{}}}    //14 POSIÇÕES
//FR - 07/02/2022 - ORMEC - Incluir coluna valor desconto no modo retrato
aAux := {{ {},{},{},{},{},{},{},{},{},{},{},{},{},{},{} }} //15 posições já com o array do desconto

nY := 0
nLenItens := Len(aItens)

For nX :=1 To nLenItens
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][01])
	nY++
	aadd(Atail(aAux)[nY],NoChar(aItens[nX][02],lConverte))
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][03])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][04])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][05])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][06])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][07])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][08])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][09])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][10])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][11])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][12])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][13])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][14])  
	
	//FR - 07/02/2022 - ORMEC - Incluir coluna valor desconto no modo retrato 
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][15])  
	//FR - 07/02/2022 - ORMEC - Incluir coluna valor desconto no modo retrato
	
	If nY >= 14
		nY := 0
	EndIf
Next nX
For nX := 1 To nLenItens
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"") 
	
	//FR - 07/02/2022 - ORMEC - Incluir coluna valor desconto no modo retrato 
	nY++
	aadd(Atail(aAux)[nY],"")
	//FR - 07/02/2022 - ORMEC - Incluir coluna valor desconto no modo retrato
	 
	//If nY >= 14
	If nY >= 15				//FR - 07/02/2022 - ORMEC - Incluir coluna valor desconto no modo retrato
		nY := 0
	EndIf
	
Next nX

// Popula o array de cabeçalho das colunas de produtos/serviços.
aAuxCabec := {;
	"COD. PROD",;
	"DESCRIÇÃO DO PROD./SERV.",;
	"NCM/SH",;
	IIf( cMVCODREG == "1", "CSOSN","CST" ),;
	"CFOP",;
	"UN",;
	"QUANT.",;
	"V.UNITARIO",;
	"V.TOTAL",;
	"BC.ICMS",;
	"V.ICMS",;
	"V.IPI",;
	"A.ICMS",;
	"A.IPI",;    
	"VLR.DESC";  //FR - 07/02/2022 - ORMEC - Incluir coluna valor desconto no modo retrato
}

// Retorna o tamanho das colunas baseado em seu conteudo
nLarguraPag := oDanfe:nPAGEWIDTH  //FR - 11/05/2022 - Alteração - Kitchens para adequar as colunas "espremidas"

aTamCol := RetTamCol(aAuxCabec, aAux, oDanfe, oFont08:oFont, oFont08N:oFont,nLarguraPag)

oDanfe:Say(440,002,"DADOS DO PRODUTO / SERVIÇO",oFont08N:oFont)
oDanfe:Box(442,000,678,603)
nAuxH := 0
oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[1])
oDanfe:Say(450, nAuxH + 2, "COD. PROD",oFont08N:oFont)
nAuxH += aTamCol[1]
oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[2])
oDanfe:Say(450, nAuxH + 2, "DESCRIÇÃO DO PROD./SERV.", oFont08N:oFont)
nAuxH += aTamCol[2]
oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[3])
oDanfe:Say(450, nAuxH + 2, "NCM/SH", oFont08N:oFont)
nAuxH += aTamCol[3]
oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[4])

If cMVCODREG == "1"
	oDanfe:Say(450, nAuxH + 2, "CSOSN", oFont08N:oFont)
Else
	oDanfe:Say(450, nAuxH + 2, "CST", oFont08N:oFont)
Endif

nAuxH += aTamCol[4]
oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[5])
oDanfe:Say(450, nAuxH + 2, "CFOP", oFont08N:oFont)
nAuxH += aTamCol[5]
oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[6])
oDanfe:Say(450, nAuxH + 2, "UN", oFont08N:oFont)
nAuxH += aTamCol[6]
oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[7])
oDanfe:Say(450, nAuxH + 2, "QUANT.", oFont08N:oFont)
nAuxH += aTamCol[7]
oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[8])
oDanfe:Say(450, nAuxH + 2, "V.UNITARIO", oFont08N:oFont)
nAuxH += aTamCol[8]
oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[9])
oDanfe:Say(450, nAuxH + 2, "V.TOTAL", oFont08N:oFont)
nAuxH += aTamCol[9]
oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[10])
oDanfe:Say(450, nAuxH + 2, "BC.ICMS", oFont08N:oFont)
nAuxH += aTamCol[10]
oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[11])
oDanfe:Say(450, nAuxH + 2, "V.ICMS", oFont08N:oFont)
nAuxH += aTamCol[11]
oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[12])
oDanfe:Say(450, nAuxH + 2, "V.IPI", oFont08N:oFont)
nAuxH += aTamCol[12]
oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[13])
oDanfe:Say(450, nAuxH + 2, "A.ICMS", oFont08N:oFont)
nAuxH += aTamCol[13]
oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[14])
oDanfe:Say(450, nAuxH + 2, "A.IPI", oFont08N:oFont)   

//FR - 07/02/2022 - ALTERAÇÃO ==> ORMEC - Incluir coluna valor desconto no modo retrato
nAuxH += aTamCol[14]
//oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[15])   //442 é o topo do retangulo
oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[15]+5)   //442 é o topo do retangulo
oDanfe:Say(450, nAuxH + 2, "VLR.DESC", oFont08N:oFont)
//FR - 07/02/2022 - ALTERAÇÃO ==> ORMEC - Incluir coluna valor desconto no modo retrato

If MV_PAR05=1 .And. nFolhas>1
	oDanfe:Say(875,497,"CONTINUA NO VERSO")
Endif

// INICIANDO INFORMAÇÕES PARA O CABEÇALHO DA PAGINA 2
nLinha	:= 460
nL	:= 0
lFlag	:= .T.

For nY := 1 To nLenItens
	nL++
	
	nLin:= 741
	nCont := 0
	
	If lflag
		If nL > nMaxItemP2
			oDanfe:EndPage()
			oDanfe:StartPage()
			If MV_PAR05 == 1
				nLinhavers := 42
			Else
				nLinhavers := 0
			EndIf		
			nLinha    	:=	181 + IIF(nFolha >=3 ,0, nLinhavers)
			
			oDanfe:Box(000+nLinhavers,000,095+nLinhavers,250)
			oDanfe:Say(010+nLinhavers,098, "Identificação do emitente",oFont12N:oFont)
			
			nLinCalc	:=	023 + nLinhavers
			cStrAux		:=	AllTrim(NoChar(oEmitente:_xNome:Text,lConverte))
			nForTo		:=	Len(cStrAux)/25
			nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
			For nX := 1 To nForTo
				oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*25)+1),25), oFont12N:oFont )
				nLinCalc+=10
			Next nX
			
			cStrAux		:=	AllTrim(NoChar(oEmitente:_EnderEmit:_xLgr:Text,lConverte))+", "+AllTrim(oEmitente:_EnderEmit:_Nro:Text)
			nForTo		:=	Len(cStrAux)/40
			nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
			For nX := 1 To nForTo
				oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*40)+1),40),oFont08N:oFont)
				nLinCalc+=10
			Next nX
			
			If Type("oEmitente:_EnderEmit:_xCpl") <> "U"
				cStrAux		:=	"Complemento: "+AllTrim(NoChar(oEmitente:_EnderEmit:_xCpl:TEXT,lConverte))
				nForTo		:=	Len(cStrAux)/40
				nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
				For nX := 1 To nForTo
					oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*40)+1),40),oFont08N:oFont)
					nLinCalc+=10
				Next nX
				
				cStrAux		:=	AllTrim(NoChar(oEmitente:_EnderEmit:_xBairro:Text,lConverte))
				If Type("oEmitente:_EnderEmit:_Cep")<>"U"
					cStrAux		+=	" Cep:"+TransForm(oEmitente:_EnderEmit:_Cep:Text,"@r 99999-999")
				EndIf
				nForTo		:=	Len(cStrAux)/40
				nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
				For nX := 1 To nForTo
					oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*40)+1),40),oFont08N:oFont)
					nLinCalc+=10
				Next nX
				oDanfe:Say(nLinCalc,098, oEmitente:_EnderEmit:_xMun:Text+"/"+oEmitente:_EnderEmit:_UF:Text,oFont08N:oFont)
				nLinCalc+=10
				oDanfe:Say(nLinCalc,098, "Fone: "+IIf(Type("oEmitente:_EnderEmit:_Fone")=="U","",oEmitente:_EnderEmit:_Fone:Text),oFont08N:oFont)
			Else
				oDanfe:Say(nLinCalc,098, NoChar(oEmitente:_EnderEmit:_xBairro:Text,lConverte)+" Cep:"+TransForm(IIF(Type("oEmitente:_EnderEmit:_Cep")=="U","",oEmitente:_EnderEmit:_Cep:Text),"@r 99999-999"),oFont08N:oFont)
				nLinCalc+=10
				oDanfe:Say(nLinCalc,098, oEmitente:_EnderEmit:_xMun:Text+"/"+oEmitente:_EnderEmit:_UF:Text,oFont08N:oFont)
				nLinCalc+=10
				oDanfe:Say(nLinCalc,098, "Fone: "+IIf(Type("oEmitente:_EnderEmit:_Fone")=="U","",oEmitente:_EnderEmit:_Fone:Text),oFont08N:oFont)
			EndIf
			
			oDanfe:Box(000+nLinhavers,248,095+nLinhavers,351)
			oDanfe:Say(013+nLinhavers,255, "DANFE",oFont18N:oFont)
			oDanfe:Say(023+nLinhavers,255, "DOCUMENTO AUXILIAR DA",oFont07:oFont)
			oDanfe:Say(033+nLinhavers,255, "NOTA FISCAL ELETRÔNICA",oFont07:oFont)
			oDanfe:Say(043+nLinhavers,255, "0-ENTRADA",oFont08:oFont)
			oDanfe:Say(053+nLinhavers,255, "1-SAÍDA"  ,oFont08:oFont)
			oDanfe:Box(037+nLinhavers,305,047+nLinhavers,315)
			oDanfe:Say(045+nLinhavers,307, oIdent:_TpNf:Text,oFont08N:oFont)
			oDanfe:Say(062+nLinhavers,255,"N. "+StrZero(Val(oIdent:_NNf:Text),9),oFont10N:oFont)
			oDanfe:Say(072+nLinhavers,255,"SÉRIE "+oIdent:_Serie:Text,oFont10N:oFont)
			oDanfe:Say(082+nLinhavers,255,"FOLHA "+StrZero(nFolha,2)+"/"+StrZero(nFolhas,2),oFont10N:oFont)
			
			oDanfe:Box(000+nLinhavers,350,095+nLinhavers,603)
			oDanfe:Box(000+nLinhavers,350,040+nLinhavers,603)
			oDanfe:Box(040+nLinhavers,350,062+nLinhavers,603)
			oDanfe:Box(063+nLinhavers,350,095+nLinhavers,603)
			oDanfe:Say(058+nLinhavers,355,TransForm(SubStr(oNF:_InfNfe:_ID:Text,4),"@r 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999"),oFont12N:oFont)
			
			oDanfe:Say(048+nLinhavers,355,"CHAVE DE ACESSO DA NF-E",oFont12N:oFont)
			nFontSize := 28
			oDanfe:Code128C(036+nLinhavers,370,SubStr(oNF:_InfNfe:_ID:Text,4), nFontSize )
			
			If lMv_Logod
				oDanfe:SayBitmap(003+nLinhavers,005,cLogoD,090,090)
			Else
				oDanfe:SayBitmap(003+nLinhavers,005,cLogo,090,090)
			EndIf
			
			If Empty(cChaveCont)
				oDanfe:Say(075+nLinhavers,355,"Consulta de autenticidade no portal nacional da NF-e",oFont12:oFont)
				oDanfe:Say(085+nLinhavers,355,"www.nfe.fazenda.gov.br/portal ou no site da SEFAZ Autorizada",oFont12:oFont)
			Endif
			
			If  !Empty(cCodAutDPEC)
				oDanfe:Say(075+nLinhavers,355,"Consulta de autenticidade no portal nacional da NF-e",oFont12:oFont)
				oDanfe:Say(085+nLinhavers,355,"www.nfe.fazenda.gov.br/portal ou no site da SEFAZ Autorizada",oFont12:oFont)
			Endif
			
			
			If nFolha == 1
				If !Empty(cCodAutDPEC)
					nFontSize := 28
					oDanfe:Code128C(093+nLinhavers,370,cCodAutDPEC, nFontSize )
				Endif
			Endif
			
			// inicio do segundo codigo de barras ref. a transmissao CONTIGENCIA OFF LINE
			If !Empty(cChaveCont) .And. Empty(cCodAutDPEC) .And. !(Val(oNF:_INFNFE:_IDE:_SERIE:TEXT) >= 900)
				If nFolha == 1
					If !Empty(cChaveCont)
						nFontSize := 28
						oDanfe:Code128C(093+nLinhavers,370,cChaveCont, nFontSize )
					EndIf
				Else
					If !Empty(cChaveCont)
						nFontSize := 28
						oDanfe:Code128C(093+nLinhavers,370,cChaveCont, nFontSize )
					EndIf
				EndIf
			EndIf
			
			oDanfe:Box(100+nLinhavers,000,123+nLinhavers,603)
			oDanfe:Box(100+nLinhavers,000,123+nLinhavers,300)
			oDanfe:Say(109+nLinhavers,002,"NATUREZA DA OPERAÇÃO",oFont08N:oFont)
			oDanfe:Say(119+nLinhavers,002,oIdent:_NATOP:TEXT,oFont08:oFont)
			If(!Empty(cCodAutDPEC))
				oDanfe:Say(109+nLinhavers,300,"NÚMERO DE REGISTRO DPEC",oFont08N:oFont)
			Endif
			If(((Val(oNF:_INFNFE:_IDE:_SERIE:TEXT) >= 900).And.(oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"2") .Or. (oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"1")
				oDanfe:Say(109+nLinhavers,302,"PROTOCOLO DE AUTORIZAÇÃO DE USO",oFont08N:oFont)
			Endif
			If((oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"25")
				oDanfe:Say(109+nLinhavers,300,"DADOS DA NF-E",oFont08N:oFont)
			Endif
			oDanfe:Say(119+nLinhavers,302,IIF(!Empty(cCodAutDPEC),cCodAutDPEC+" "+Iif(oNF:_INFNFE:_VERSAO:TEXT >= "3.10",AllTrim(ConvDate(oNF:_InfNfe:_IDE:_DHEMI:Text)),AllTrim(ConvDate(oNF:_InfNfe:_IDE:_DEMI:Text)))+" "+AllTrim(cDtHrRecCab),IIF(!Empty(cCodAutSef) .And. ((Val(oNF:_INFNFE:_IDE:_SERIE:TEXT) >= 900).And.(oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"23") .Or. (oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"1",cCodAutSef+" "+Iif(oNF:_INFNFE:_VERSAO:TEXT >= "3.10",AllTrim(ConvDate(oNF:_InfNfe:_IDE:_DHEMI:Text)),AllTrim(ConvDate(oNF:_InfNfe:_IDE:_DEMI:Text)))+" "+AllTrim(cDtHrRecCab),TransForm(cChaveCont,"@r 9999 9999 9999 9999 9999 9999 9999 9999 9999"))),oFont08:oFont)
							
			nFolha++
			
			oDanfe:Box(126+nLinhavers,000,153+nLinhavers,603)
			oDanfe:Box(126+nLinhavers,000,153+nLinhavers,200)
			oDanfe:Box(126+nLinhavers,200,153+nLinhavers,400)
			oDanfe:Box(126+nLinhavers,400,153+nLinhavers,603)
			oDanfe:Say(135+nLinhavers,002,"INSCRIÇÃO ESTADUAL",oFont08N:oFont)
			oDanfe:Say(143+nLinhavers,002,IIf(Type("oEmitente:_IE:TEXT")<>"U",oEmitente:_IE:TEXT,""),oFont08:oFont)
			oDanfe:Say(135+nLinhavers,205,"INSC.ESTADUAL DO SUBST.TRIB.",oFont08N:oFont)
			oDanfe:Say(143+nLinhavers,205,IIf(Type("oEmitente:_IEST:TEXT")<>"U",oEmitente:_IEST:TEXT,""),oFont08:oFont)
			oDanfe:Say(135+nLinhavers,405,"CNPJ",oFont08N:oFont)
			oDanfe:Say(143+nLinhavers,405,TransForm(oEmitente:_CNPJ:TEXT,IIf(Len(oEmitente:_CNPJ:TEXT)<>14,"@r 999.999.999-99","@r 99.999.999/9999-99")),oFont08:oFont)
			
			nLenMensagens:= Len(aMensagem)
			
			nColLim		:=	Iif(MV_PAR05==1,435,Iif(nMensagem <= nLenMensagens,680,865)) + nLinhavers 
			oDanfe:Say(161+nLinhavers,002,"DADOS DO PRODUTO / SERVIÇO",oFont08N:oFont)
			oDanfe:Box(163+nLinhavers,000,nColLim,603)
			
			nAuxH := 0
			oDanfe:Box(163+nLinhavers, nAuxH, nColLim, nAuxH + aTamCol[1])
			oDanfe:Say(171+nLinhavers, nAuxH + 2, "COD. PROD",oFont08N:oFont)
			nAuxH += aTamCol[1]
			oDanfe:Box(163+nLinhavers, nAuxH, nColLim, nAuxH + aTamCol[2])
			oDanfe:Say(171+nLinhavers, nAuxH + 2, "DESCRIÇÃO DO PROD./SERV.", oFont08N:oFont)
			nAuxH += aTamCol[2]
			oDanfe:Box(163+nLinhavers, nAuxH, nColLim, nAuxH + aTamCol[3])
			oDanfe:Say(171+nLinhavers, nAuxH + 2, "NCM/SH", oFont08N:oFont)
			nAuxH += aTamCol[3]
			oDanfe:Box(163+nLinhavers, nAuxH, nColLim, nAuxH + aTamCol[4])

			If cMVCODREG == "1"
				oDanfe:Say(171+nLinhavers, nAuxH + 2, "CSOSN", oFont08N:oFont)
			Else
				oDanfe:Say(171+nLinhavers, nAuxH + 2, "CST", oFont08N:oFont)
			Endif

			nAuxH += aTamCol[4]
			oDanfe:Box(163+nLinhavers, nAuxH, nColLim, nAuxH + aTamCol[5])
			oDanfe:Say(171+nLinhavers, nAuxH + 2, "CFOP", oFont08N:oFont)
			nAuxH += aTamCol[5]
			oDanfe:Box(163+nLinhavers, nAuxH, nColLim, nAuxH + aTamCol[6])
			oDanfe:Say(171+nLinhavers, nAuxH + 2, "UN", oFont08N:oFont)
			nAuxH += aTamCol[6]
			oDanfe:Box(163+nLinhavers, nAuxH, nColLim, nAuxH + aTamCol[7])
			oDanfe:Say(171+nLinhavers, nAuxH + 2, "QUANT.", oFont08N:oFont)
			nAuxH += aTamCol[7]
			oDanfe:Box(163+nLinhavers, nAuxH, nColLim, nAuxH + aTamCol[8])
			oDanfe:Say(171+nLinhavers, nAuxH + 2, "V.UNITARIO", oFont08N:oFont)
			nAuxH += aTamCol[8]
			oDanfe:Box(163+nLinhavers, nAuxH, nColLim, nAuxH + aTamCol[9])
			oDanfe:Say(171+nLinhavers, nAuxH + 2, "V.TOTAL", oFont08N:oFont)
			nAuxH += aTamCol[9]
			oDanfe:Box(163+nLinhavers, nAuxH, nColLim, nAuxH + aTamCol[10])
			oDanfe:Say(171+nLinhavers, nAuxH + 2, "BC.ICMS", oFont08N:oFont)
			nAuxH += aTamCol[10]
			oDanfe:Box(163+nLinhavers, nAuxH, nColLim, nAuxH + aTamCol[11])
			oDanfe:Say(171+nLinhavers, nAuxH + 2, "V.ICMS", oFont08N:oFont)
			nAuxH += aTamCol[11]
			oDanfe:Box(163+nLinhavers, nAuxH, nColLim, nAuxH + aTamCol[12])
			oDanfe:Say(171+nLinhavers, nAuxH + 2, "V.IPI", oFont08N:oFont)
			nAuxH += aTamCol[12]
			oDanfe:Box(163+nLinhavers, nAuxH, nColLim, nAuxH + aTamCol[13])
			oDanfe:Say(171+nLinhavers, nAuxH + 2, "A.ICMS", oFont08N:oFont)
			nAuxH += aTamCol[13]
			oDanfe:Box(163+nLinhavers, nAuxH, nColLim, nAuxH + aTamCol[14])
			oDanfe:Say(171+nLinhavers, nAuxH + 2, "A.IPI", oFont08N:oFont)
			
			//FR - 07/02/2022 - ALTERAÇÃO ==> ORMEC - Incluir coluna valor desconto
			nAuxH += aTamCol[14]
			oDanfe:Box(163+nLinhavers, nAuxH, nColLim, nAuxH + aTamCol[15])
			oDanfe:Say(171+nLinhavers, nAuxH + 2, "VLR.DESC", oFont08N:oFont)
			//FR - 07/02/2022 - ALTERAÇÃO ==> ORMEC - Incluir coluna valor desconto
			
			// FINALIZANDO INFORMAÇÕES PARA O CABEÇALHO DA PAGINA 2
			nL	:= 1
			lFlag	:= .F.                                         		
			
			//Verifico se ainda existem Dados Adicionais a serem impressos
			IF MV_PAR05 <> 1 .And. nMensagem <= nLenMensagens
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Dados Adicionais                                                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oDanfe:Say(719+nLinhavers,000,"DADOS ADICIONAIS",oFont08N:oFont)
				oDanfe:Box(721+nLinhavers,000,865+nLinhavers,351)
				oDanfe:Say(729+nLinhavers,002,"INFORMAÇÕES COMPLEMENTARES",oFont08N:oFont)				
				
				nLin:= 741
				nLenMensagens:= Len(aMensagem)
				--nMensagem
				For nX := 1 To Min(nLenMensagens - nMensagem, MAXMSG)
					oDanfe:Say(nLin,002,aMensagem[nMensagem+nX],oFont08:oFont)
					nLin:= nLin+10
				Next nX
				nMensagem := nMensagem+nX
				
				oDanfe:Box(721+nLinhavers,350,865+nLinhavers,603)
				oDanfe:Say(729+nLinhavers,352,"RESERVADO AO FISCO",oFont08N:oFont)
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Logotipo Rodape
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ												
				if file(cLogoTotvs) .or. Resource2File ( cLogoTotvs, cStartPath+cLogoTotvs )
					oDanfe:SayBitmap(866,484,cLogoTotvs,120,20)
				endif	
				
				// Seta o máximo de itens para o MAXITEMP2
				nMaxItemP2 := MAXITEMP2
			Else
				// Seta o máximo de itens para o MAXITEMP2F
				nMaxItemP2 := MAXITEMP2F
			EndIF
		Endif		
	Endif
	
	// INICIANDO INFORMAÇÕES PARA O CABEÇALHO DA PAGINA 3 E DIANTE	
	If	nL > Iif( (nfolha-1)%2==0 .And. MV_PAR05==1,MAXITEMP3,nMaxItemP2)
		oDanfe:EndPage()
		oDanfe:StartPage()
		nLenMensagens:= Len(aMensagem)							
		nColLim		:=	Iif(!(nfolha-1)%2==0 .And. MV_PAR05==1,435,Iif(nMensagem <= nLenMensagens,680,865))
		lFimpar		:=  ((nfolha-1)%2==0)
		nLinha    	:=	181      
		If nfolha >= 3
			nLinhavers := 0
		EndIf
		oDanfe:Box(000,000,095,250)
		oDanfe:Say(010,098, "Identificação do emitente",oFont12N:oFont)
		nLinCalc	:=	023
		cStrAux		:=	AllTrim(NoChar(oEmitente:_xNome:Text,lConverte))
		nForTo		:=	Len(cStrAux)/25
		nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
		For nX := 1 To nForTo
			oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*25)+1),25), oFont12N:oFont )
			nLinCalc+=10
		Next nX
		
		cStrAux		:=	AllTrim(NoChar(oEmitente:_EnderEmit:_xLgr:Text,lConverte))+", "+AllTrim(oEmitente:_EnderEmit:_Nro:Text)
		nForTo		:=	Len(cStrAux)/40
		nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
		For nX := 1 To nForTo
			oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*40)+1),40),oFont08N:oFont)
			nLinCalc+=10
		Next nX
		
		If Type("oEmitente:_EnderEmit:_xCpl") <> "U"
			cStrAux		:=	"Complemento: "+AllTrim(NoChar(oEmitente:_EnderEmit:_xCpl:TEXT,lConverte))
			nForTo		:=	Len(cStrAux)/40
			nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
			For nX := 1 To nForTo
				oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*40)+1),40),oFont08N:oFont)
				nLinCalc+=10
			Next nX
			
			cStrAux		:=	AllTrim(NoChar(oEmitente:_EnderEmit:_xBairro:Text,lConverte))
			If Type("oEmitente:_EnderEmit:_Cep")<>"U"
				cStrAux		+=	" Cep:"+TransForm(oEmitente:_EnderEmit:_Cep:Text,"@r 99999-999")
			EndIf
			nForTo		:=	Len(cStrAux)/40
			nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
			For nX := 1 To nForTo
				oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*40)+1),40),oFont08N:oFont)
				nLinCalc+=10
			Next nX
			oDanfe:Say(nLinCalc,098, oEmitente:_EnderEmit:_xMun:Text+"/"+oEmitente:_EnderEmit:_UF:Text,oFont08N:oFont)
			nLinCalc+=10
			oDanfe:Say(nLinCalc,098, "Fone: "+IIf(Type("oEmitente:_EnderEmit:_Fone")=="U","",oEmitente:_EnderEmit:_Fone:Text),oFont08N:oFont)
		Else
			oDanfe:Say(nLinCalc,098, NoChar(oEmitente:_EnderEmit:_xBairro:Text,lConverte)+" Cep:"+TransForm(IIF(Type("oEmitente:_EnderEmit:_Cep")=="U","",oEmitente:_EnderEmit:_Cep:Text),"@r 99999-999"),oFont08N:oFont)
			nLinCalc+=10
			oDanfe:Say(nLinCalc,098, oEmitente:_EnderEmit:_xMun:Text+"/"+oEmitente:_EnderEmit:_UF:Text,oFont08N:oFont)
			nLinCalc+=10
			oDanfe:Say(nLinCalc,098, "Fone: "+IIf(Type("oEmitente:_EnderEmit:_Fone")=="U","",oEmitente:_EnderEmit:_Fone:Text),oFont08N:oFont)
		EndIf
		
		oDanfe:Box(000,248,095,351)
		oDanfe:Say(013,255, "DANFE",oFont18N:oFont)
		oDanfe:Say(023,255, "DOCUMENTO AUXILIAR DA",oFont07:oFont)
		oDanfe:Say(033,255, "NOTA FISCAL ELETRÔNICA",oFont07:oFont)
		oDanfe:Say(043,255, "0-ENTRADA",oFont08:oFont)
		oDanfe:Say(053,255, "1-SAÍDA"  ,oFont08:oFont)
		oDanfe:Box(037,305,047,315)
		oDanfe:Say(045,307, oIdent:_TpNf:Text,oFont08N:oFont)
		oDanfe:Say(062,255,"N. "+StrZero(Val(oIdent:_NNf:Text),9),oFont10N:oFont)
		oDanfe:Say(072,255,"SÉRIE "+oIdent:_Serie:Text,oFont10N:oFont)
		oDanfe:Say(082,255,"FOLHA "+StrZero(nFolha,2)+"/"+StrZero(nFolhas,2),oFont10N:oFont)
		
		oDanfe:Box(000,350,095,603)
		oDanfe:Box(000,350,040,603)
		oDanfe:Box(040,350,062,603)
		oDanfe:Box(063,350,095,603)
		oDanfe:Say(058,355,TransForm(SubStr(oNF:_InfNfe:_ID:Text,4),"@r 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999"),oFont12N:oFont)
		
		oDanfe:Say(048,355,"CHAVE DE ACESSO DA NF-E",oFont12N:oFont)
		nFontSize := 28
		oDanfe:Code128C(036,370,SubStr(oNF:_InfNfe:_ID:Text,4), nFontSize )
		
		If lMv_Logod
			oDanfe:SayBitmap(003,005,cLogoD,090,090)
		Else
			oDanfe:SayBitmap(003,005,cLogo,090,090)
		EndIf
		
		If Empty(cChaveCont)
			oDanfe:Say(075,355,"Consulta de autenticidade no portal nacional da NF-e",oFont12:oFont)
			oDanfe:Say(085,355,"www.nfe.fazenda.gov.br/portal ou no site da SEFAZ Autorizada",oFont12:oFont)
		Endif
		
		If  !Empty(cCodAutDPEC)
			oDanfe:Say(075,355,"Consulta de autenticidade no portal nacional da NF-e",oFont12:oFont)
			oDanfe:Say(085,355,"www.nfe.fazenda.gov.br/portal ou no site da SEFAZ Autorizada",oFont12:oFont)
		Endif
		
		
		If nFolha == 1
			If !Empty(cCodAutDPEC)
				nFontSize := 28
				oDanfe:Code128C(093,370,cCodAutDPEC, nFontSize )
			Endif
		Endif
		
		// inicio do segundo codigo de barras ref. a transmissao CONTIGENCIA OFF LINE
		If !Empty(cChaveCont) .And. Empty(cCodAutDPEC) .And. !(Val(oNF:_INFNFE:_IDE:_SERIE:TEXT) >= 900)
			If nFolha == 1
				If !Empty(cChaveCont)
					nFontSize := 28
					oDanfe:Code128C(093,370,cChaveCont, nFontSize )
				EndIf
			Else
				If !Empty(cChaveCont)
					nFontSize := 28
					oDanfe:Code128C(093,370,cChaveCont, nFontSize )
				EndIf
			EndIf
		EndIf
		
		oDanfe:Box(100,000,123,603)
		oDanfe:Box(100,000,123,300)
		oDanfe:Say(109,002,"NATUREZA DA OPERAÇÃO",oFont08N:oFont)
		oDanfe:Say(119,002,oIdent:_NATOP:TEXT,oFont08:oFont)
		If(!Empty(cCodAutDPEC))
			oDanfe:Say(109,300,"NÚMERO DE REGISTRO DPEC",oFont08N:oFont)
		Endif
		If(((Val(oNF:_INFNFE:_IDE:_SERIE:TEXT) >= 900).And.(oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"2") .Or. (oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"1")
			oDanfe:Say(109,302,"PROTOCOLO DE AUTORIZAÇÃO DE USO",oFont08N:oFont)
		Endif
		If((oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"25")
			oDanfe:Say(109,300,"DADOS DA NF-E",oFont08N:oFont)
		Endif
		oDanfe:Say(119,302,IIF(!Empty(cCodAutDPEC),cCodAutDPEC+" "+Iif(oNF:_INFNFE:_VERSAO:TEXT >= "3.10",AllTrim(ConvDate(oNF:_InfNfe:_IDE:_DHEMI:Text)),AllTrim(ConvDate(oNF:_InfNfe:_IDE:_DEMI:Text)))+" "+AllTrim(cDtHrRecCab),IIF(!Empty(cCodAutSef) .And. ((Val(oNF:_INFNFE:_IDE:_SERIE:TEXT) >= 900).And.(oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"23") .Or. (oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"1",cCodAutSef+" "+Iif(oNF:_INFNFE:_VERSAO:TEXT >= "3.10",AllTrim(ConvDate(oNF:_InfNfe:_IDE:_DHEMI:Text)),AllTrim(ConvDate(oNF:_InfNfe:_IDE:_DEMI:Text)))+" "+AllTrim(cDtHrRecCab),TransForm(cChaveCont,"@r 9999 9999 9999 9999 9999 9999 9999 9999 9999"))),oFont08:oFont)
		nFolha++
		
		oDanfe:Box(126,000,153,603)
		oDanfe:Box(126,000,153,200)
		oDanfe:Box(126,200,153,400)
		oDanfe:Box(126,400,153,603)
		oDanfe:Say(135,002,"INSCRIÇÃO ESTADUAL",oFont08N:oFont)
		oDanfe:Say(143,002,IIf(Type("oEmitente:_IE:TEXT")<>"U",oEmitente:_IE:TEXT,""),oFont08:oFont)
		oDanfe:Say(135,205,"INSC.ESTADUAL DO SUBST.TRIB.",oFont08N:oFont)
		oDanfe:Say(143,205,IIf(Type("oEmitente:_IEST:TEXT")<>"U",oEmitente:_IEST:TEXT,""),oFont08:oFont)
		oDanfe:Say(135,405,"CNPJ",oFont08N:oFont)
		oDanfe:Say(143,405,TransForm(oEmitente:_CNPJ:TEXT,IIf(Len(oEmitente:_CNPJ:TEXT)<>14,"@r 999.999.999-99","@r 99.999.999/9999-99")),oFont08:oFont)
		
		oDanfe:Say(161,002,"DADOS DO PRODUTO / SERVIÇO",oFont08N:oFont)
		oDanfe:Box(163,000,nColLim,603)
		
		nAuxH := 0
		oDanfe:Box(163, nAuxH, nColLim, nAuxH + aTamCol[1])
		oDanfe:Say(171, nAuxH + 2, "COD. PROD",oFont08N:oFont)
		nAuxH += aTamCol[1]
		oDanfe:Box(163, nAuxH, nColLim, nAuxH + aTamCol[2])
		oDanfe:Say(171, nAuxH + 2, "DESCRIÇÃO DO PROD./SERV.", oFont08N:oFont)
		nAuxH += aTamCol[2]
		oDanfe:Box(163, nAuxH, nColLim, nAuxH + aTamCol[3])
		oDanfe:Say(171, nAuxH + 2, "NCM/SH", oFont08N:oFont)
		nAuxH += aTamCol[3]
		oDanfe:Box(163, nAuxH, nColLim, nAuxH + aTamCol[4])

		If cMVCODREG == "1"
			oDanfe:Say(171, nAuxH + 2, "CSOSN", oFont08N:oFont)
		Else
			oDanfe:Say(171, nAuxH + 2, "CST", oFont08N:oFont)
		Endif
		
		nAuxH += aTamCol[4]
		oDanfe:Box(163, nAuxH, nColLim, nAuxH + aTamCol[5])
		oDanfe:Say(171, nAuxH + 2, "CFOP", oFont08N:oFont)
		nAuxH += aTamCol[5]
		oDanfe:Box(163, nAuxH, nColLim, nAuxH + aTamCol[6])
		oDanfe:Say(171, nAuxH + 2, "UN", oFont08N:oFont)
		nAuxH += aTamCol[6]
		oDanfe:Box(163, nAuxH, nColLim, nAuxH + aTamCol[7])
		oDanfe:Say(171, nAuxH + 2, "QUANT.", oFont08N:oFont)
		nAuxH += aTamCol[7]
		oDanfe:Box(163, nAuxH, nColLim, nAuxH + aTamCol[8])
		oDanfe:Say(171, nAuxH + 2, "V.UNITARIO", oFont08N:oFont)
		nAuxH += aTamCol[8]
		oDanfe:Box(163, nAuxH, nColLim, nAuxH + aTamCol[9])
		oDanfe:Say(171, nAuxH + 2, "V.TOTAL", oFont08N:oFont)
		nAuxH += aTamCol[9]
		oDanfe:Box(163, nAuxH, nColLim, nAuxH + aTamCol[10])
		oDanfe:Say(171, nAuxH + 2, "BC.ICMS", oFont08N:oFont)
		nAuxH += aTamCol[10]
		oDanfe:Box(163, nAuxH, nColLim, nAuxH + aTamCol[11])
		oDanfe:Say(171, nAuxH + 2, "V.ICMS", oFont08N:oFont)
		nAuxH += aTamCol[11]
		oDanfe:Box(163, nAuxH, nColLim, nAuxH + aTamCol[12])
		oDanfe:Say(171, nAuxH + 2, "V.IPI", oFont08N:oFont)
		nAuxH += aTamCol[12]
		oDanfe:Box(163, nAuxH, nColLim, nAuxH + aTamCol[13])
		oDanfe:Say(171, nAuxH + 2, "A.ICMS", oFont08N:oFont)
		nAuxH += aTamCol[13]
		oDanfe:Box(163, nAuxH, nColLim, nAuxH + aTamCol[14])
		oDanfe:Say(171, nAuxH + 2, "A.IPI", oFont08N:oFont)
		
		//FR - 07/02/2022 - ALTERAÇÃO ==> ORMEC - Incluir coluna valor desconto
		nAuxH += aTamCol[14]	
		oDanfe:Box(163, nAuxH, nColLim, nAuxH + aTamCol[15])
		oDanfe:Say(171, nAuxH + 2, "VLR.DESC", oFont08N:oFont)
		//FR - 07/02/2022 - ALTERAÇÃO ==> ORMEC - Incluir coluna valor desconto
		
		//Verifico se ainda existem Dados Adicionais a serem impressos
		nLenMensagens:= Len(aMensagem)			
		IF (MV_PAR05 <> 1 .Or. (MV_PAR05 == 1 .And. lFimpar )).And. nMensagem <= nLenMensagens
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Dados Adicionais                                                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oDanfe:Say(719,000,"DADOS ADICIONAIS",oFont08N:oFont)
			oDanfe:Box(721,000,865,351)
			oDanfe:Say(729,002,"INFORMAÇÕES COMPLEMENTARES",oFont08N:oFont)				
			
			nLin:= 741
			nLenMensagens:= Len(aMensagem)
			--nMensagem
			For nX := 1 To Min(nLenMensagens - nMensagem, MAXMSG)				
				oDanfe:Say(nLin,002,aMensagem[nMensagem+nX],oFont08:oFont)
				nLin:= nLin+10
			Next nX
			nMensagem := nMensagem+nX
			
			oDanfe:Box(721+nLinhavers,350,865+nLinhavers,603)
			oDanfe:Say(729+nLinhavers,352,"RESERVADO AO FISCO",oFont08N:oFont)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Logotipo Rodape
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ												
			if file(cLogoTotvs) .or. Resource2File ( cLogoTotvs, cStartPath+cLogoTotvs )
				oDanfe:SayBitmap(866,484,cLogoTotvs,120,20)
			endif	

			// Seta o máximo de itens para o MAXITEMP2
			nMaxItemP2 := MAXITEMP2
		Else
			// Seta o máximo de itens para o MAXITEMP2F
			nMaxItemP2 := MAXITEMP2F
		EndIF	
		If (!(nfolha-1)%2==0) .And. MV_PAR05==1
			If nY+69<nLenItens
				oDanfe:Say(875+nLinhavers,497,"CONTINUA NO VERSO")
			Endif
		End
		
		nL := 1
	EndIf
	
	nAuxH := 0
	
	If aAux[1][1][nY] == "-"
		oDanfe:Say(nLinha, nAuxH, Replicate("- ", 150), oFont08:oFont)
	Else
		oDanfe:Say(nLinha, nAuxH + 2, aAux[1][1][nY], oFont08:oFont )
		nAuxH += aTamCol[1]
		oDanfe:Say(nLinha, nAuxH + 2, aAux[1][2][nY], oFont08:oFont) // DESCRICAO DO PRODUTO
		nAuxH += aTamCol[2]
		oDanfe:Say(nLinha, nAuxH + 2, aAux[1][3][nY], oFont08:oFont) // NCM
		nAuxH += aTamCol[3]
		oDanfe:Say(nLinha, nAuxH + 2, aAux[1][4][nY], oFont08:oFont) // CST
		nAuxH += aTamCol[4]
		oDanfe:Say(nLinha, nAuxH + 2, aAux[1][5][nY], oFont08:oFont) // CFOP
		nAuxH += aTamCol[5]
		oDanfe:Say(nLinha, nAuxH + 2, aAux[1][6][nY], oFont08:oFont) // UN
		nAuxH += aTamCol[6]
		// Workaround para falha no FWMSPrinter:GetTextWidth()
		
		nAuxH2 := len(aAux[1][7][nY]) + (nAuxH + (aTamCol[7]) - RetTamTex(aAux[1][7][nY], oFont08:oFont, oDanfe))
		oDanfe:Say(nLinha, nAuxH2, aAux[1][7][nY], oFont08:oFont) // QUANT
		nAuxH += aTamCol[7]
		
		nAuxH2 := len(aAux[1][8][nY]) + (nAuxH + (aTamCol[8]) - RetTamTex(aAux[1][8][nY], oFont08:oFont, oDanfe)) 
		oDanfe:Say(nLinha, nAuxH2, aAux[1][8][nY], oFont08:oFont) // V UNITARIO
		nAuxH += aTamCol[8]
		
		nAuxH2 := len(aAux[1][9][nY]) + (nAuxH + (aTamCol[9]) - RetTamTex(aAux[1][9][nY], oFont08:oFont, oDanfe))
		oDanfe:Say(nLinha, nAuxH2, aAux[1][9][nY], oFont08:oFont) // V. TOTAL
		nAuxH += aTamCol[9]

		nAuxH2 := len(aAux[1][10][nY]) + (nAuxH + (aTamCol[10]) - RetTamTex(aAux[1][10][nY], oFont08:oFont, oDanfe))
		oDanfe:Say(nLinha, nAuxH2, aAux[1][10][nY], oFont08:oFont) // BC. ICMS
		nAuxH += aTamCol[10]
		
		nAuxH2 := len(aAux[1][11][nY]) + (nAuxH + (aTamCol[11]) - RetTamTex(aAux[1][11][nY], oFont08:oFont, oDanfe))
		oDanfe:Say(nLinha, nAuxH2, aAux[1][11][nY], oFont08:oFont) // V. ICMS
		nAuxH += aTamCol[11]
		
		nAuxH2 := len(aAux[1][12][nY]) + (nAuxH + (aTamCol[12]) - RetTamTex(aAux[1][12][nY], oFont08:oFont, oDanfe))
		oDanfe:Say(nLinha, nAuxH2, aAux[1][12][nY], oFont08:oFont) // V.IPI
		nAuxH += aTamCol[12]
		
		nAuxH2 := len(aAux[1][13][nY]) + (nAuxH + (aTamCol[13]) - RetTamTex(aAux[1][13][nY], oFont08:oFont, oDanfe)) 
		oDanfe:Say(nLinha, nAuxH2, aAux[1][13][nY], oFont08:oFont) // A.ICMS
		nAuxH += aTamCol[13]
		
		nAuxH2 := len(aAux[1][14][nY]) + (nAuxH + (aTamCol[14]) - RetTamTex(aAux[1][14][nY], oFont08:oFont, oDanfe)) 
		oDanfe:Say(nLinha, nAuxH2, aAux[1][14][nY], oFont08:oFont) // A.IPI				
		//FR - 07/02/2022 - ALTERAÇÃO ==> ORMEC - Incluir coluna valor desconto		
		nAuxH += aTamCol[14] 
		//FR - 07/02/2022 - ALTERAÇÃO ==> ORMEC - Incluir coluna valor desconto		
		
		//FR - 07/02/2022 - ALTERAÇÃO ==> ORMEC - Incluir coluna valor desconto		
		nAuxH2 := len(aAux[1][15][nY]) + (nAuxH + (aTamCol[15]) - RetTamTex(aAux[1][15][nY], oFont08:oFont, oDanfe)) 
		oDanfe:Say(nLinha, nAuxH2, aAux[1][15][nY], oFont08:oFont) // VLR.DESC		
		//FR - 07/02/2022 - ALTERAÇÃO ==> ORMEC - Incluir coluna valor desconto
		
	EndIf
	
	nLinha :=nLinha + 10
Next nY

nLenMensagens := Len(aMensagem)
While nMensagem <= nLenMensagens
	DanfeCpl(oDanfe,aItens,aMensagem,@nItem,@nMensagem,oNFe,oIdent,oEmitente,@nFolha,nFolhas,cCodAutSef,oNfeDPEC,cCodAutDPEC,cDtHrRecCab,cLogoD,aUF)
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Finaliza a Impressão                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lPreview
	//	oDanfe:Preview()
EndIf

oDanfe:EndPage()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento para nao imprimir DANFEs diferentes na mesma folha, uma na FRENTE e outra no VERSO.  |
//|   Isso quando a impressora estiver configurada para frente e verso                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If MV_PAR05==1 .And. MV_PAR01 <> MV_PAR02 .And. (--nFolha)%2<>0
	oDanfe:StartPage()
	oDanfe:EndPage()
EndIf

Return(.T.)

/*
Private oNF        := oNFe:_NFe
Private oDPEC    :=oNfeDPEC
Default cCodAutSef := ""
Default cCodAutDPEC:= ""
Default cDtHrRecCab:= ""
Default dDtReceb   := CToD("")
*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Impressao do Complemento da NFe                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function DanfeCpl(oDanfe,aItens,aMensagem,nItem,nMensagem,oNFe,oIdent,oEmitente,nFolha,nFolhas,cCodAutSef,oNfeDPEC,cCodAutDPEC,cDtHrRecCab,cLogoD,aUF)
Local nX            := 0
Local nLinha        := 0
Local nLenMensagens := Len(aMensagem)
Local nItemOld	    := nItem
Local nMensagemOld  := nMensagem
Local nForMensagens := 0
Local lMensagens    := .F.
Local cLogo      	:= FisxLogo("1")
Local cChaveCont 	:= ""
Local lConverte     := GetNewPar("MV_CONVERT",.F.)
Local lMv_Logod := If(GetNewPar("MV_LOGOD", "N" ) == "S", .T., .F.   )

Local 	cCNPJCPF :=  ""
Local 	cUF      :=  ""
Local 	cDataEmi :=  ""
Local 	cTPEmis  :=  ""
Local 	cValIcm  :=  ""
Local 	cICMSp   :=  ""
Local 	cICMSs   :=  ""
local cLogoTotvs := "Powered_by_TOTVS.bmp"
local cStartPath := GetSrvProfString("Startpath","")

If (nLenMensagens - (nMensagemOld - 1)) > 0
	lMensagens := .T.
	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄ------------------------ÄÄÄÄ¿
//³Dados Adicionais segunda parte em diante³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄ------------------------ÄÄÄÄÙ
If lMensagens
	nLenMensagens := Len(aMensagem)
	nForMensagens := Min(nLenMensagens, MAXITEMP2 + (nMensagemOld - 1) - (nItem - nItemOld))
	oDanfe:EndPage()
	oDanfe:StartPage()
	nLinha    :=180
	oDanfe:Say(160,000,"DADOS ADICIONAIS",oFont08N:oFont)
	oDanfe:Box(172,000,865,351)
	oDanfe:Say(170,002,"INFORMAÇÕES COMPLEMENTARES",oFont08N:oFont)
	oDanfe:Box(172,350,865,603)
	oDanfe:Say(170,352,"RESERVADO AO FISCO",oFont08N:oFont)
	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Logotipo Rodape
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ												
	if file(cLogoTotvs) .or. Resource2File ( cLogoTotvs, cStartPath+cLogoTotvs )
		oDanfe:SayBitmap(866,484,cLogoTotvs,120,20)
	endif	

	oDanfe:Box(000,000,095,250)
	oDanfe:Say(010,098, "Identificação do emitente",oFont12N:oFont)
	nLinCalc	:=	023
	cStrAux		:=	AllTrim(NoChar(oEmitente:_xNome:Text,lConverte))
	nForTo		:=	Len(cStrAux)/25
	nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
	For nX := 1 To nForTo
		oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*25)+1),25), oFont12N:oFont )
		nLinCalc+=10
	Next nX
	
	cStrAux		:=	AllTrim(NoChar(oEmitente:_EnderEmit:_xLgr:Text,lConverte))+", "+AllTrim(oEmitente:_EnderEmit:_Nro:Text)
	nForTo		:=	Len(cStrAux)/40
	nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
	For nX := 1 To nForTo
		oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*40)+1),40),oFont08N:oFont)
		nLinCalc+=10
	Next nX
	
	If Type("oEmitente:_EnderEmit:_xCpl") <> "U"
		cStrAux		:=	"Complemento: "+AllTrim(NoChar(oEmitente:_EnderEmit:_xCpl:TEXT,lConverte))
		nForTo		:=	Len(cStrAux)/40
		nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
		For nX := 1 To nForTo
			oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*40)+1),40),oFont08N:oFont)
			nLinCalc+=10
		Next nX
		
		cStrAux		:=	AllTrim(NoChar(oEmitente:_EnderEmit:_xBairro:Text,lConverte))
		If Type("oEmitente:_EnderEmit:_Cep")<>"U"
			cStrAux		+=	" Cep:"+TransForm(oEmitente:_EnderEmit:_Cep:Text,"@r 99999-999")
		EndIf
		nForTo		:=	Len(cStrAux)/40
		nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
		For nX := 1 To nForTo
			oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*40)+1),40),oFont08N:oFont)
			nLinCalc+=10
		Next nX
		oDanfe:Say(nLinCalc,098, oEmitente:_EnderEmit:_xMun:Text+"/"+oEmitente:_EnderEmit:_UF:Text,oFont08N:oFont)
		nLinCalc+=10
		oDanfe:Say(nLinCalc,098, "Fone: "+IIf(Type("oEmitente:_EnderEmit:_Fone")=="U","",oEmitente:_EnderEmit:_Fone:Text),oFont08N:oFont)
	Else
		oDanfe:Say(nLinCalc,098, oEmitente:_EnderEmit:_xBairro:Text+" Cep:"+TransForm(IIF(Type("oEmitente:_EnderEmit:_Cep")=="U","",oEmitente:_EnderEmit:_Cep:Text),"@r 99999-999"),oFont08N:oFont)
		nLinCalc+=10
		oDanfe:Say(nLinCalc,098, oEmitente:_EnderEmit:_xMun:Text+"/"+oEmitente:_EnderEmit:_UF:Text,oFont08N:oFont)
		nLinCalc+=10
		oDanfe:Say(nLinCalc,098, "Fone: "+IIf(Type("oEmitente:_EnderEmit:_Fone")=="U","",oEmitente:_EnderEmit:_Fone:Text),oFont08N:oFont)
	EndIf
	
	oDanfe:Box(000,248,095,351)
	oDanfe:Say(013,255, "DANFE",oFont18N:oFont)
	oDanfe:Say(023,255, "DOCUMENTO AUXILIAR DA",oFont07:oFont)
	oDanfe:Say(033,255, "NOTA FISCAL ELETRÔNICA",oFont07:oFont)
	oDanfe:Say(043,255, "0-ENTRADA",oFont08:oFont)
	oDanfe:Say(053,255, "1-SAÍDA"  ,oFont08:oFont)
	oDanfe:Box(037,305,047,315)
	oDanfe:Say(045,307, oIdent:_TpNf:Text,oFont08N:oFont)
	oDanfe:Say(062,255,"N. "+StrZero(Val(oIdent:_NNf:Text),9),oFont10N:oFont)
	oDanfe:Say(072,255,"SÉRIE "+oIdent:_Serie:Text,oFont10N:oFont)
	oDanfe:Say(082,255,"FOLHA "+StrZero(nFolha,2)+"/"+StrZero(nFolhas,2),oFont10N:oFont)
	
	oDanfe:Box(000,350,095,603)
	oDanfe:Box(000,350,040,603)
	oDanfe:Box(040,350,062,603)
	oDanfe:Box(063,350,095,603)
	oDanfe:Say(058,355,TransForm(SubStr(oNF:_InfNfe:_ID:Text,4),"@r 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999"),oFont12N:oFont)
	
	oDanfe:Say(048,355,"CHAVE DE ACESSO DA NF-E",oFont12N:oFont)
	nFontSize := 28
	oDanfe:Code128C(036,370,SubStr(oNF:_InfNfe:_ID:Text,4), nFontSize )
	
	If lMv_Logod
		oDanfe:SayBitmap(003,005,cLogoD,090,090)
	Else
		oDanfe:SayBitmap(003,005,cLogo,090,090)
	EndIf
	
	If Empty(cChaveCont)
		oDanfe:Say(075,355,"Consulta de autenticidade no portal nacional da NF-e",oFont12:oFont)
		oDanfe:Say(085,355,"www.nfe.fazenda.gov.br/portal ou no site da SEFAZ Autorizada",oFont12:oFont)
	Endif
	
	If  !Empty(cCodAutDPEC)
		oDanfe:Say(075,355,"Consulta de autenticidade no portal nacional da NF-e",oFont12:oFont)
		oDanfe:Say(085,355,"www.nfe.fazenda.gov.br/portal ou no site da SEFAZ Autorizada",oFont12:oFont)
	Endif
	
	
	If nFolha == 1
		If !Empty(cCodAutDPEC)
			nFontSize := 28
			oDanfe:Code128C(093,370,cCodAutDPEC, nFontSize )
		Endif
	Endif
	
	// inicio do segundo codigo de barras ref. a transmissao CONTIGENCIA OFF LINE
	If !Empty(cChaveCont) .And. Empty(cCodAutDPEC) .And. !(Val(oNF:_INFNFE:_IDE:_SERIE:TEXT) >= 900)
		If nFolha == 1
			If !Empty(cChaveCont)
				nFontSize := 28
				oDanfe:Code128C(093,370,cChaveCont, nFontSize )
			EndIf
		Else
			If !Empty(cChaveCont)
				nFontSize := 28
				oDanfe:Code128C(093,370,cChaveCont, nFontSize )
			EndIf
		EndIf
	EndIf
	
	oDanfe:Box(100,000,123,603)
	oDanfe:Box(100,000,123,300)
	oDanfe:Say(109,002,"NATUREZA DA OPERAÇÃO",oFont08N:oFont)
	oDanfe:Say(119,002,oIdent:_NATOP:TEXT,oFont08:oFont)
	If(!Empty(cCodAutDPEC))
		oDanfe:Say(109,300,"NÚMERO DE REGISTRO DPEC",oFont08N:oFont)
	Endif
	If(((Val(oNF:_INFNFE:_IDE:_SERIE:TEXT) >= 900).And.(oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"2") .Or. (oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"1")
		oDanfe:Say(109,302,"PROTOCOLO DE AUTORIZAÇÃO DE USO",oFont08N:oFont)
	Endif
	If((oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"25")
		oDanfe:Say(109,300,"DADOS DA NF-E",oFont08N:oFont)
	Endif
	
	If !Empty(cCodAutDPEC) .And. (oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"4"
		cDataEmi := Iif(oNF:_INFNFE:_VERSAO:TEXT >= "3.10",Substr(oNFe:_NFE:_INFNFE:_IDE:_DHEMI:Text,9,2),Substr(oNFe:_NFE:_INFNFE:_IDE:_DEMI:Text,9,2))
		cTPEmis  := "4"
		
		If Type("oDPEC:_ENVDPEC:_INFDPEC:_RESNFE") <> "U"
			cUF      := aUF[aScan(aUF,{|x| x[1] == oDPEC:_ENVDPEC:_INFDPEC:_RESNFE:_UF:Text})][02]
			cValIcm := StrZero(Val(StrTran(oDPEC:_ENVDPEC:_INFDPEC:_RESNFE:_VNF:TEXT,".","")),14)
			cICMSp := iif(Val(oDPEC:_ENVDPEC:_INFDPEC:_RESNFE:_VICMS:TEXT)>0,"1","2")
			cICMSs := iif(Val(oDPEC:_ENVDPEC:_INFDPEC:_RESNFE:_VST:TEXT)>0,"1","2")
		ElseIf type ("oDPEC:_EVENTO:_INFEVENTO:_DETEVENTO:_DEST") <> "U" //EPEC NFE
			If Type ("oDPEC:_EVENTO:_INFEVENTO:_DETEVENTO:_DEST:_UF:TEXT") <> "U"
				cUF := aUF[aScan(aUF,{|x| x[1] == oDPEC:_EVENTO:_INFEVENTO:_DETEVENTO:_DEST:_UF:TEXT})][02]			
			EndIf
			If Type ("oDPEC:_EVENTO:_INFEVENTO:_DETEVENTO:_DEST:_VNF:TEXT") <> "U"
				cValIcm := StrZero(Val(StrTran(oDPEC:_EVENTO:_INFEVENTO:_DETEVENTO:_DEST:_VNF:TEXT,".","")),14)
			EndIf
			If 	Type ("oDPEC:_EVENTO:_INFEVENTO:_DETEVENTO:_DEST:_VICMS:TEXT") <> "U"
				cICMSp:= IIf(Val(oDPEC:_EVENTO:_INFEVENTO:_DETEVENTO:_DEST:_VICMS:TEXT) > 0,"1","2")
			EndIf
			If 	Type ("oDPEC:_EVENTO:_INFEVENTO:_DETEVENTO:_DEST:_VST:TEXT") <> "U"
				cICMSs := IIf(Val(oDPEC:_EVENTO:_INFEVENTO:_DETEVENTO:_DEST:_VST:TEXT )> 0,"1","2")
			EndIf	
		EndIf
				
	ElseIF (oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"25"
		cUF      := aUF[aScan(aUF,{|x| x[1] == oNFe:_NFE:_INFNFE:_DEST:_ENDERDEST:_UF:Text})][02]
		cDataEmi := Iif(oNF:_INFNFE:_VERSAO:TEXT >= "3.10",Substr(oNFe:_NFE:_INFNFE:_IDE:_DHEMI:Text,9,2),Substr(oNFe:_NFE:_INFNFE:_IDE:_DEMI:Text,9,2))
		cTPEmis  := oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT
		cValIcm  := StrZero(Val(StrTran(oNFe:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VNF:TEXT,".","")),14)
		cICMSp   := iif(Val(oNFe:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VICMS:TEXT)>0,"1","2")
		cICMSs   :=iif(Val(oNFe:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VST:TEXT)>0,"1","2")
	EndIf
	If !Empty(cUF) .And. !Empty(cDataEmi) .And. !Empty(cTPEmis) .And. !Empty(cValIcm) .And. !Empty(cICMSp) .And. !Empty(cICMSs)
		If Type("oNF:_InfNfe:_DEST:_CNPJ:Text")<>"U"
			cCNPJCPF := oNF:_InfNfe:_DEST:_CNPJ:Text
			If cUf == "99"
				cCNPJCPF := STRZERO(val(cCNPJCPF),14)
			EndIf
		ElseIf Type("oNF:_INFNFE:_DEST:_CPF:Text")<>"U"
			cCNPJCPF := oNF:_INFNFE:_DEST:_CPF:Text
			cCNPJCPF := STRZERO(val(cCNPJCPF),14)
		Else
			cCNPJCPF := ""
		EndIf
		cChaveCont += cUF+cTPEmis+cCNPJCPF+cValIcm+cICMSp+cICMSs+cDataEmi
		cChaveCont := cChaveCont+Modulo11(cChaveCont)
	EndIf
	
	oDanfe:Say(119,302,IIF(!Empty(cCodAutDPEC),cCodAutDPEC+" "+Iif(oNF:_INFNFE:_VERSAO:TEXT >= "3.10",AllTrim(ConvDate(oNF:_InfNfe:_IDE:_DHEMI:Text)),AllTrim(ConvDate(oNF:_InfNfe:_IDE:_DEMI:Text)))+" "+AllTrim(cDtHrRecCab),IIF(!Empty(cCodAutSef) .And. ((Val(oNF:_INFNFE:_IDE:_SERIE:TEXT) >= 900).And.(oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"23") .Or. (oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"1",cCodAutSef+" "+Iif(oNF:_INFNFE:_VERSAO:TEXT >= "3.10",AllTrim(ConvDate(oNF:_InfNfe:_IDE:_DHEMI:Text)),AllTrim(ConvDate(oNF:_InfNfe:_IDE:_DEMI:Text)))+" "+AllTrim(cDtHrRecCab),TransForm(cChaveCont,"@r 9999 9999 9999 9999 9999 9999 9999 9999 9999"))),oFont08:oFont)
	nFolha++
	
	oDanfe:Box(126,000,153,603)
	oDanfe:Box(126,000,153,200)
	oDanfe:Box(126,200,153,400)
	oDanfe:Box(126,400,153,603)
	oDanfe:Say(135,002,"INSCRIÇÃO ESTADUAL",oFont08N:oFont)
	oDanfe:Say(143,002,IIf(Type("oEmitente:_IE:TEXT")<>"U",oEmitente:_IE:TEXT,""),oFont08:oFont)
	oDanfe:Say(135,205,"INSC.ESTADUAL DO SUBST.TRIB.",oFont08N:oFont)
	oDanfe:Say(143,205,IIf(Type("oEmitente:_IEST:TEXT")<>"U",oEmitente:_IEST:TEXT,""),oFont08:oFont)
	oDanfe:Say(135,405,"CNPJ",oFont08N:oFont)
	oDanfe:Say(143,405,TransForm(oEmitente:_CNPJ:TEXT,IIf(Len(oEmitente:_CNPJ:TEXT)<>14,"@r 999.999.999-99","@r 99.999.999/9999-99")),oFont08:oFont)
	
	For nX := nMensagem To nForMensagens
		oDanfe:Say(nlinha,002,aMensagem[nX],oFont08:oFont)
		nMensagem++
		nLinha:= nLinha+ 10
	Next nX
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Finalizacao da pagina do objeto grafico                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDanfe:EndPage()

Return(.T.)

Static Function GetXML(cIdEnt,aIdNFe,cModalidade)  

Local aRetorno		:= {}
Local aDados		:= {}

Local cURL			:= PadR(GetNewPar("MV_SPEDURL","http://localhost:8080/sped"),250)
Local cModel		:= "55"


Local nZ			:= 0
Local nCount		:= 0

Local oWS

If Empty(cModalidade)    

	oWS := WsSpedCfgNFe():New()
	oWS:cUSERTOKEN := "TOTVS"
	oWS:cID_ENT    := cIdEnt
	oWS:nModalidade:= 0
	oWS:_URL       := AllTrim(cURL)+"/SPEDCFGNFe.apw"
	oWS:cModelo    := cModel 
	If oWS:CFGModalidade()
		cModalidade    := SubStr(oWS:cCfgModalidadeResult,1,1)
	Else
		cModalidade    := ""
	EndIf  
	
EndIf  
         
oWs := nil

For nZ := 1 To len(aIdNfe) 
	nCount++

	aDados := executeRetorna( aIdNfe[nZ], cIdEnt )
	
	if ( nCount == 10 )
		delClassIntF()
		nCount := 0
	endif
	
	aAdd(aRetorno,aDados)
	
Next nZ

Return(aRetorno)

Static Function ConvDate(cData)

Local dData
cData  := StrTran(cData,"-","")
dData  := Stod(cData)
Return PadR(StrZero(Day(dData),2)+ "/" + StrZero(Month(dData),2)+ "/" + StrZero(Year(dData),4),15)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DANFE     ºAutor  ³Marcos Taranta      º Data ³  10/01/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Pega uma posição (nTam) na string cString, e retorna o      º±±
±±º          ³caractere de espaço anterior.                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function EspacoAt(cString, nTam)

Local nRetorno := 0
Local nX       := 0

/**
* Caso a posição (nTam) for maior que o tamanho da string, ou for um valor
* inválido, retorna 0.
*/
If nTam > Len(cString) .Or. nTam < 1
	nRetorno := 0
	Return nRetorno
EndIf

/**
* Procura pelo caractere de espaço anterior a posição e retorna a posição
* dele.
*/
nX := nTam
While nX > 1
	If Substr(cString, nX, 1) == " "
		nRetorno := nX
		Return nRetorno
	EndIf
	
	nX--
EndDo

/**
* Caso não encontre nenhum caractere de espaço, é retornado 0.
*/
nRetorno := 0

Return nRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ DANFE_V   ³ Autor ³ Luana Ferrari        ³ Data ³ 20/07/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao utilizada para verificar a ultima versao do fonte   ³±±
±±³			 ³ DANFEII..PRW aplicado no rpo do cliente, assim verificando ³±±
±±³			 ³ a necessidade de uma atualizacao neste fonte.			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FAT/FIS                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/

//User Function DANFE_V
//Local nRet := 20100720 // 20 de Julho de 2010 # Luana Ferrari
//Local nRet := 20100929 // 29 de Setembro de 2010 # Roberto Souza
//Local nRet := 20130417 // 17 de Abril de 2013 # Rafael Iaquinto
//Return nRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DANFE     ºAutor  ³Fabio Santana	     º Data ³  04/10/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Converte caracteres espceiais						          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
STATIC FUNCTION NoChar(cString,lConverte)

Static lConverte := .F.

If lConverte
	cString := (StrTran(cString,"&lt;","<"))
	cString := (StrTran(cString,"&gt;",">"))
	cString := (StrTran(cString,"&amp;","&"))
	cString := (StrTran(cString,"&quot;",'"'))
	cString := (StrTran(cString,"&#39;","'"))
EndIf

Return(cString)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DANFEIII  ºAutor  ³Microsiga           º Data ³  12/17/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tratamento para o código do item                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION MaxCod(cString,nTamanho)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento para saber quantos caracteres irão caber na linha ³
//³ visto que letras ocupam mais espaço do que os números.      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local nMax	:= 0
Local nY   	:= 0
Static nTamanho := 45

For nMax := 1 to Len(cString)
	If IsAlpha(SubStr(cString,nMax,1)) .And. SubStr(cString,nMax,1) $ "MOQW"  // Caracteres que ocupam mais espaço em pixels
		nY += 7
	Else
		nY += 5
	EndIf
	
	If nY > nTamanho   // é o máximo de espaço para uma coluna
		nMax--
		Exit
	EndIf
Next

Return nMax

//-----------------------------------------------------------------------
/*/{Protheus.doc} RetTamCol
Retorna um array do mesmo tamanho do array de entrada, contendo as
medidas dos maiores textos para cálculo de colunas.

@author Marcos Taranta
@since 24/05/2011
@version 1.0 

@param  aCabec     Array contendo as strings de cabeçalho das colunas
        aValores   Array contendo os valores que serão populados nas
                   colunas.
        oPrinter   Objeto de impressão instanciado para utilizar o método
                   nativo de cálculo de tamanho de texto.
        oFontCabec Objeto da fonte que será utilizada no cabeçalho.
        oFont      Objeto da fonte que será utilizada na impressão.

@return aTamCol  Array contendo os tamanhos das colunas baseados nos
                 valores.
/*/
//-----------------------------------------------------------------------
Static Function RetTamCol(aCabec, aValores, oPrinter, oFontCabec, oFont,nLarguraPag)
	
	Local aTamCol    := {}
	Local nAux       := 0

	Local nX         := 0
	Local nY         := 0
	Local ncolunas   := 0  //FR - 11/05/2022 - ALTERAÇÃO - ajuste impressão largura colunas 
	Local nLgpadrao  := 0  //FR - 11/05/2022 - ALTERAÇÃO - ajuste impressão largura colunas 
	Local ndilui     := 0  //FR - 11/05/2022 - ALTERAÇÃO - ajuste impressão largura colunas 
	                          
	Local oFontSize	 := FWFontSize():new()
	Local nLargDesc  := 0
	Local nAux2      := 0
	
	For nX := 1 To Len(aCabec)
		
		AADD(aTamCol, {})
		//aTamCol[nX] := Round(oPrinter:GetTextWidth(aCabec[nX], oFontCabec) * nConsNeg + 4, 0)
		aTamCol[nX] := oFontSize:getTextWidth( alltrim(aCabec[nX]), oFontCabec:Name, oFontCabec:nWidth, oFontCabec:Bold, oFontCabec:Italic )
		
	Next nX
	
	For nX := 1 To Len(aValores[1])
		
		nAux := 0
		
		For nY := 1 To Len(aValores[1][nX])			
			
			If Valtype(aValores[1][nX][nY]) == "C"  //se for caracter
				If (oPrinter:GetTextWidth(aValores[1][nX][nY], oFont) * nConsTex) > nAux
					//nAux := Round(oPrinter:GetTextWidth(aValores[1][nX][nY], oFont) * nConsTex + 4, 0)
					nAux := oFontSize:getTextWidth( Alltrim(aValores[1][nX][nY]), oFontCabec:Name, oFontCabec:nWidth, oFontCabec:Bold, oFontCabec:Italic )
				EndIf 
				
			Elseif Valtype(avalores[1][nX][nY]) == "N" //se for numérico, converte para caracter para calcular o tamanho da coluna
				
				aValores[1][nX][nY] := Alltrim(Str(aValores[1][nX][nY])) 
				If (oPrinter:GetTextWidth(aValores[1][nX][nY], oFont) * nConsTex) > nAux				
					nAux := oFontSize:getTextWidth( Alltrim(aValores[1][nX][nY]), oFontCabec:Name, oFontCabec:nWidth, oFontCabec:Bold, oFontCabec:Italic )
				EndIf 
			
			Endif 
			
		Next nY		
		
	Next nX
	
	
	//FR - 11/05/2022 - Alteração - ajuste para impressão das colunas, estava "espremido"
	nAux2 := 0
	For nX := 1 To Len(aTamCol)		
		nAux2 += aTamCol[nX]   //somatório da largura de todas as colunas --> 536		
	Next nX 
	
	ncolunas := Len(aTamCol)   //qtde de colunas
	nLgpadrao:= GetNewPar("XM_DANFLARG",605)  //FR - 11/05/2022 - DEFINE A LARGURA PADRÃO DO DANFE
	
	If nAux2 < nLgpadrao
		ndilui   := Round((nLgpadrao - nAux2) / ncolunas,0)  //diferença entre largura padrão e largura somada -> 603 - 536 = 67 -> 67/15 = 4,46666... 
		//arredonda pra 5 -> 4,46666 soma isso em cada coluna para diluir a diferença e equalizar as larguras de cada coluna com a largura total da página	
		For nX := 1 To Len(aTamCol)
		
			aTamCol[nX] += ndilui			
			
		Next nX 
	Endif
	//FR - 11/05/2022 - Alteração - ajuste para impressão das colunas, estava "espremido" 

	

	//FR - 07/02/2022 - ESTÁ DIMINUINDO O TAMANHO DA COLUNA DESC. PRODUTO            
	// Checa se os campos completam a página, senão joga o resto na coluna da
	//   descrição de produtos/serviços           
	//If nAux < 603			
	//	aTamCol[2] += 603 - nAux
	//EndIf                       
	//If nAux > 603   		//FR - 07/02/2022 - ESTÁ DIMINUINDO O TAMANHO DA COLUNA DESC. PRODUTO            
	//	aTamCol[2] -= nAux - 603	
	//EndIf
	//FR - 07/02/2022 - ESTÁ DIMINUINDO O TAMANHO DA COLUNA DESC. PRODUTO            
	
Return aTamCol

//-----------------------------------------------------------------------
/*/{Protheus.doc} RetTamTex
Retorna o tamanho em pixels de uma string. (Workaround para o GetTextWidth)

@author Marcos Taranta
@since 24/05/2011
@version 1.0 

@param  cTexto   Texto a ser medido.
        oFont    Objeto instanciado da fonte a ser utilizada.
        oPrinter Objeto de impressão instanciado.

@return nTamanho Tamanho em pixels da string.
/*/
//-----------------------------------------------------------------------
Static Function RetTamTex(cTexto, oFont, oPrinter)
	
	Local nTamanho := 0
	//Local oFontSize:= FWFontSize():new() 
	Local cAux := ""
		
	Local cValor := "0123456789"
	Local cVirgPonto := ",."
	Local cPerc := "%"	
	Local nX := 0	
	
	//nTamanho := oPrinter:GetTextWidth(cTexto, oFont)
	//nTamanho := oFontSize:getTextWidth( cTexto, oFont:Name, oFont:nWidth, oFont:Bold, oFont:Italic )
	/*O calculo abaixo é o mesmo realizado pela oFontSize:getTextWidth
	Retorna 5 para numeros (0123456789), 2 para virgula e ponto (, .) e 7 para percentual (%)
	O ajuste foi realizado para diminuir o tempo na impressão de um danfe com muitos itens*/
	For nX:= 1 to len(cTexto)
		cAux:= Substr(cTexto,nX,1)
		If cAux $ cValor
			nTamanho += 5
		ElseIf cAux $ cVirgPonto
			nTamanho += 2
		ElseIf cAux $ cPerc
			nTamanho += 7
		EndIf		
	Next nX	
	
  	nTamanho := Round(nTamanho, 0)
	
Return nTamanho

//-----------------------------------------------------------------------
/*/{Protheus.doc} PosQuebrVal
Retorna a posição onde um valor deve ser quebrado

@author Marcos Taranta
@since 27/05/2011
@version 1.0 

@param  cTexto Texto a ser medido.

@return nPos   Posição aonde o valor deve ser quebrado.
/*/
//-----------------------------------------------------------------------
Static Function PosQuebrVal(cTexto)
	
	Local nPos := 0
	
	If Empty(cTexto)
		Return 0
	EndIf
	
	If Len(cTexto) <= MAXVALORC
		Return Len(cTexto)
	EndIf
	
	If SubStr(cTexto, MAXVALORC, 1) $ ",."
		nPos := MAXVALORC - 2
	Else
		nPos := MAXVALORC
	EndIf
	
Return nPos

//-----------------------------------------------------------------------
/*/{Protheus.doc} executeRetorna
Executa o retorna de notas

@author Henrique Brugugnoli
@since 17/01/2013
@version 1.0 

@param  cID ID da nota que sera retornado

@return aRetorno   Array com os dados da nota
/*/
//-----------------------------------------------------------------------
static function executeRetorna( aNfe, cIdEnt, lUsacolab )

Local aExecute		:= {}  
Local aFalta		:= {}
Local aResposta		:= {}
Local aRetorno		:= {}
Local aDados		:= {} 
Local aIdNfe		:= {}

Local cAviso		:= "" 
Local cDHRecbto		:= ""
Local cDtHrRec		:= ""
Local cDtHrRec1		:= ""
Local cErro			:= "" 
Local cModTrans		:= ""
Local cProtDPEC		:= ""
Local cProtocolo	:= ""
Local cMsgNFE		:= ""
Local cRetDPEC		:= ""
Local cRetorno		:= ""
Local cCodRetNFE	:= ""
Local cURL			:= PadR(GetNewPar("MV_SPEDURL","http://localhost:8080/sped"),250)
Local cModel		:= "55"

Local dDtRecib		:= CToD("")

Local lFlag			:= .T.

Local nDtHrRec1		:= 0
Local nL			:= 0
Local nX			:= 0
Local nY			:= 0
Local nZ			:= 1
Local nCount		:= 0
Local nLenNFe
Local nLenWS

Local oWS

Private oDHRecbto
Private oNFeRet
Private oDoc

Static lUsacolab	:= .F.

aAdd(aIdNfe,aNfe)

if !lUsacolab

	oWS:= WSNFeSBRA():New()
	oWS:cUSERTOKEN        := "TOTVS"
	oWS:cID_ENT           := cIdEnt
	oWS:nDIASPARAEXCLUSAO := 0
	oWS:_URL 			  := AllTrim(cURL)+"/NFeSBRA.apw"
	oWS:oWSNFEID          := NFESBRA_NFES2():New()
	oWS:oWSNFEID:oWSNotas := NFESBRA_ARRAYOFNFESID2():New()  
	
	aadd(aRetorno,{"","",aIdNfe[nZ][4]+aIdNfe[nZ][5],"","","",CToD(""),"","",""})
	
	aadd(oWS:oWSNFEID:oWSNotas:oWSNFESID2,NFESBRA_NFESID2():New())
	Atail(oWS:oWSNFEID:oWSNotas:oWSNFESID2):cID := aIdNfe[nZ][4]+aIdNfe[nZ][5]
	
	If oWS:RETORNANOTASNX()
		If Len(oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5) > 0
			For nX := 1 To Len(oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5)
				cRetorno        := oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSNFE:CXML
				cProtocolo      := oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSNFE:CPROTOCOLO								
				cDHRecbto  		:= oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSNFE:CXMLPROT
				oNFeRet			:= XmlParser(cRetorno,"_",@cAviso,@cErro)
				cModTrans		  := IIf(Type("oNFeRet:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT") <> "U",IIf (!Empty("oNFeRet:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT"),oNFeRet:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT,1),1)
				If ValType(oWs:OWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:OWSDPEC)=="O"
					cRetDPEC        := oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSDPEC:CXML
					cProtDPEC       := oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:oWSDPEC:CPROTOCOLO
				EndIf
				
	
				//Tratamento para gravar a hora da transmissao da NFe
				If !Empty(cProtocolo)
					oDHRecbto		:= XmlParser(cDHRecbto,"","","")
					cDtHrRec		:= IIf(Type("oDHRecbto:_ProtNFE:_INFPROT:_DHRECBTO:TEXT")<>"U",oDHRecbto:_ProtNFE:_INFPROT:_DHRECBTO:TEXT,"")
					nDtHrRec1		:= RAT("T",cDtHrRec)
					
					If nDtHrRec1 <> 0
						cDtHrRec1   :=	SubStr(cDtHrRec,nDtHrRec1+1)
						dDtRecib	:=	SToD(StrTran(SubStr(cDtHrRec,1,AT("T",cDtHrRec)-1),"-",""))
					EndIf
					
					AtuSF2Hora(cDtHrRec1,aIdNFe[nZ][5]+aIdNFe[nZ][4]+aIdNFe[nZ][6]+aIdNFe[nZ][7])
					
				EndIf
	
				nY := aScan(aIdNfe,{|x| x[4]+x[5] == SubStr(oWs:oWSRETORNANOTASNXRESULT:OWSNOTAS:OWSNFES5[nX]:CID,1,Len(x[4]+x[5]))})
	
				oWS:cIdInicial    := aIdNfe[nZ][4]+aIdNfe[nZ][5]
				oWS:cIdFinal      := aIdNfe[nZ][4]+aIdNfe[nZ][5]
				If oWS:MONITORFAIXA()
					cCodRetNFE := oWS:oWsMonitorFaixaResult:OWSMONITORNFE[1]:OWSERRO:OWSLOTENFE[len(oWS:oWsMonitorFaixaResult:OWSMONITORNFE[1]:OWSERRO:OWSLOTENFE)]:CCODRETNFE
					cMsgNFE	:= oWS:oWsMonitorFaixaResult:OWSMONITORNFE[1]:OWSERRO:OWSLOTENFE[len(oWS:oWsMonitorFaixaResult:OWSMONITORNFE[1]:OWSERRO:OWSLOTENFE)]:CMSGRETNFE
				EndIf
	
				If nY > 0
					aRetorno[nY][1] := cProtocolo
					aRetorno[nY][2] := cRetorno
					aRetorno[nY][4] := cRetDPEC
					aRetorno[nY][5] := cProtDPEC
					aRetorno[nY][6] := cDtHrRec1
					aRetorno[nY][7] := dDtRecib
					aRetorno[nY][8] := cModTrans
					aRetorno[nY][9] := cCodRetNFE
					aRetorno[nY][10]:= cMsgNFE
					
					//aadd(aResposta,aIdNfe[nY])
				EndIf
				cRetDPEC := ""
				cProtDPEC:= ""
			Next nX
			/*For nX := 1 To Len(aIdNfe)
				If aScan(aResposta,{|x| x[4] == aIdNfe[nX,04] .And. x[5] == aIdNfe[nX,05] })==0
				
					conout("Falta")
					conout(aIdNfe[nX][4]+" - "+aIdNfe[nX][5])
					aadd(aFalta,aIdNfe[nX])
				EndIf
			Next nX
			If Len(aFalta)>0
				aExecute := GetXML(cIdEnt,aFalta,@cModalidade)
			Else
				aExecute := {}
			EndIf*/
			/*For nX := 1 To Len(aExecute)
				nY := aScan(aRetorno,{|x| x[3] == aExecute[nX][03]})
				If nY == 0
					aadd(aRetorno,{aExecute[nX][01],aExecute[nX][02],aExecute[nX][03]})
				Else
					aRetorno[nY][01] := aExecute[nX][01]
					aRetorno[nY][02] := aExecute[nX][02]
				EndIf
			Next nX*/
		EndIf
	Else
		Aviso("DANFE",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"OK"},3)
	EndIf 
else
	oDoc 			:= ColaboracaoDocumentos():new()		
	oDoc:cModelo	:= "NFE"
	oDoc:cTipoMov	:= "1"									
	oDoc:cIDERP	:= aIdNfe[nZ][4]+aIdNfe[nZ][5]+FwGrpCompany()+FwCodFil()
	
	aadd(aRetorno,{"","",aIdNfe[nZ][4]+aIdNfe[nZ][5],"","","",CToD(""),"","",""})
	
	if odoc:consultar()
		aDados := ColDadosNf(1)
		
		if !Empty(oDoc:cXMLRet)
			cRetorno	:= oDoc:cXMLRet 
		else
			cRetorno	:= oDoc:cXml
		endif
		
		aDadosXml := ColDadosXMl(cRetorno, aDados, @cErro, @cAviso)
		
		if '<obsCont xCampo="nRegDPEC">' $ cRetorno
			aDadosXml[9] := SubStr(cRetorno,At('<obsCont xCampo="nRegDPEC"><xTexto>',cRetorno)+35,15)
		endif	
					
		cProtocolo		:= aDadosXml[3]		
		cModTrans		:= IIF(Empty(aDadosXml[5]),aDadosXml[7],aDadosXml[5])
		cCodRetNFE := aDadosXml[1]
		cMsgNFE := iif (aDadosXml[2]<> nil ,aDadosXml[2],"")
		//Dados do DEPEC
		If !Empty( aDadosXml[9] )
			cRetDPEC        := cRetorno
			cProtDPEC       := aDadosXml[9] 
		EndIf
		
		//Tratamento para gravar a hora da transmissao da NFe
		If !Empty(cProtocolo)
			cDtHrRec		:= aDadosXml[4]
			nDtHrRec1		:= RAT("T",cDtHrRec)
			
			If nDtHrRec1 <> 0
				cDtHrRec1   :=	SubStr(cDtHrRec,nDtHrRec1+1)
				dDtRecib	:=	SToD(StrTran(SubStr(cDtHrRec,1,AT("T",cDtHrRec)-1),"-",""))
			EndIf
			
			AtuSF2Hora(cDtHrRec1,aIdNFe[nZ][5]+aIdNFe[nZ][4]+aIdNFe[nZ][6]+aIdNFe[nZ][7])
			
		EndIf
				
		aRetorno[1][1] := cProtocolo
		aRetorno[1][2] := cRetorno
		aRetorno[1][4] := cRetDPEC
		aRetorno[1][5] := cProtDPEC
		aRetorno[1][6] := cDtHrRec1
		aRetorno[1][7] := dDtRecib
		aRetorno[1][8] := cModTrans
		aRetorno[1][9] := cCodRetNFE
		aRetorno[1][10]:= cMsgNFE
								
		cRetDPEC := ""
		cProtDPEC:= ""		
				
	endif
endif

oWS       := Nil
oDHRecbto := Nil
oNFeRet   := Nil

return aRetorno[len(aRetorno)]


//-----------------------------------------------------------------------
/*/{Protheus.doc} SimpDanfe
Impressao do formulario DANFE grafico conforme laytout no formato 
simplificado.

@author Rafael Iaquinto
@since 17.04.2013
@version 10   

@param		oDanfe		Objeto FWMSPrinter, para desenho do documento.
@param		oNfe		Objeto do XML da NF-e
@param		cCodAutSef	Código de autorização da NF-e
@param		cModalidade	Modalidade de transmissão da NF-e
@param		oNfeDPEC	Objeto do XML do DPEC.
@param		cCodAutDPEC	Codigo de autorização do DPEC
@param		cDtHrRecCab	Hora de Recebimento da NF-e
@param		dDtReceb	Data de recebimento da NF-e
@param		aNota		Array com informações do documento a ser impresso.
			
@return		.T.
/*/
//-----------------------------------------------------------------------
Static Function SimpDanfe(oDanfe,oNfe,cCodAutSef,cModalidade,oNfeDPEC,cCodAutDPEC,cDtHrRecCab,dDtReceb,aNota)

Local cLogo      	:= FisxLogo("1")
Local cUF      	:= ""
Local cDataEmi 	:= ""
Local cTPEmis  	:= ""
Local cValIcm  	:= ""
Local cICMSp   	:= ""
Local cICMSs   	:= ""

Local nX			:= 0
Local nY			:= 0
Local nZ			:= 0
Local nFolha      := 1
Local nFolhas		:= 0      
Local nMaxDes	    := 54
Local nMaxI		:= 066 //MAXIMO DE ITENS PRIMEIRA PAGINA
Local nMaxI2		:= 080 //MAXIMO DE ITENS SEGUNDA PAG. SE FOR O VERSO PAGINA
Local nMaxIAll		:= 085 //MAXIMO DE ITENS DA TERCEIRA PAGINA EM DIANTE
Local nFimL		:= 855 //NUMERO DA LINHA FINAL QUANDO HOUVER MAIS PAGINAS
Local nFimLUlt		:= 825 //NUMERO DA LINHA FINAL SE FOR ULTIMA PAGINA

Local aIndImp	    := {}      
Local aIndAux	    := {}
Local aItens		:= {}    
Local aMensagem   := {}
Local aSitTrib		:= {}
Local aSitSN		:= {}
Local aHrEnt		:= {} 
Local aUF			:= {} 
Local aTamCol 		:= {271,27,76,91,138} //Tamanho das colunas são fixas para os Itens	

Local lConverte   := .F.//GetNewPar("MV_CONVERT",.F.)
Local lMv_ItDesc  := .F.//Iif( GetNewPar("MV_ITDESC","N")=="S", .T., .F. )  
Local lImpAnfav   := .F.//GetNewPar("MV_IMPANF",.F.)
Local lImpInfAd   := .F.//GetNewPar("MV_IMPADIC",.F.)      
Local lMv_Logod   := .F.//If(GetNewPar("MV_LOGOD", "N" ) == "S", .T., .F.   )
Local cChaveCont	:= ""

Private oDPEC     := oNfeDPEC
Private oNF       := oNFe:_NFe
Private oEmitente := oNF:_InfNfe:_Emit
Private oIdent    := oNF:_InfNfe:_IDE
Private oDestino  := oNF:_InfNfe:_Dest
Private oTotal    := oNF:_InfNfe:_Total  
Private oDet      := oNF:_InfNfe:_Det


aadd(aSitTrib,"00")
aadd(aSitTrib,"10")
aadd(aSitTrib,"20")
aadd(aSitTrib,"30")
aadd(aSitTrib,"40")
aadd(aSitTrib,"41")
aadd(aSitTrib,"50")
aadd(aSitTrib,"51")
aadd(aSitTrib,"60")
aadd(aSitTrib,"70")
aadd(aSitTrib,"90")

aadd(aSitSN,"101")
aadd(aSitSN,"102")
aadd(aSitSN,"201")
aadd(aSitSN,"202")
aadd(aSitSN,"500")
aadd(aSitSN,"900")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Preenchimento do Array de UF                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aadd(aUF,{"RO","11"})
aadd(aUF,{"AC","12"})
aadd(aUF,{"AM","13"})
aadd(aUF,{"RR","14"})
aadd(aUF,{"PA","15"})
aadd(aUF,{"AP","16"})
aadd(aUF,{"TO","17"})
aadd(aUF,{"MA","21"})
aadd(aUF,{"PI","22"})
aadd(aUF,{"CE","23"})
aadd(aUF,{"RN","24"})
aadd(aUF,{"PB","25"})
aadd(aUF,{"PE","26"})
aadd(aUF,{"AL","27"})
aadd(aUF,{"MG","31"})
aadd(aUF,{"ES","32"})
aadd(aUF,{"RJ","33"})
aadd(aUF,{"SP","35"})
aadd(aUF,{"PR","41"})
aadd(aUF,{"SC","42"})
aadd(aUF,{"RS","43"})
aadd(aUF,{"MS","50"})
aadd(aUF,{"MT","51"})
aadd(aUF,{"GO","52"})
aadd(aUF,{"DF","53"})
aadd(aUF,{"SE","28"})
aadd(aUF,{"BA","29"})
aadd(aUF,{"EX","99"})

cEndDest := NoChar(oDestino:_EnderDest:_Xlgr:Text,lConverte)
If  " SN" $ (UPPER (oDestino:_EnderDest:_Xlgr:Text)) .Or. ",SN" $ (UPPER (oDestino:_EnderDest:_Xlgr:Text)) .Or. ;
    "S/N" $ (UPPER (oDestino:_EnderDest:_Xlgr:Text)) 
   
            cEndDest += IIf(Type("oDestino:_EnderDest:_xcpl")=="U","",", " + NoChar(oDestino:_EnderDest:_xcpl:Text,lConverte))
Else
            cEndDest += +","+NoChar(oDestino:_EnderDest:_NRO:Text,lConverte) + IIf(Type("oDestino:_EnderDest:_xcpl")=="U","",", "+ NoChar(oDestino:_EnderDest:_xcpl:Text,lConverte))
Endif   

aDest := {cEndDest,;
NoChar(oDestino:_EnderDest:_XBairro:Text,lConverte),;
IIF(Type("oDestino:_EnderDest:_Cep")=="U","",Transform(oDestino:_EnderDest:_Cep:Text,"@r 99999-999")),;
IIF(Type("oIdent:_DSaiEnt")=="U","",oIdent:_DSaiEnt:Text),;//                              oIdent:_DSaiEnt:Text,;
oDestino:_EnderDest:_XMun:Text,;
IIF(Type("oDestino:_EnderDest:_fone")=="U","",oDestino:_EnderDest:_fone:Text),;
oDestino:_EnderDest:_UF:Text,;
IIF(Type("oDestino:_IE:Text")=="U","",oDestino:_IE:Text),;
""}  

If Type("oIdent:_DSaiEnt")<>"U" .And. Type("oIdent:_HSaiEnt:Text")<>"U"
	aAdd(aHrEnt,oIdent:_HSaiEnt:Text)
Else
	aAdd(aHrEnt,"")
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializacao da pagina do objeto grafico                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDanfe:StartPage()
nHPage := oDanfe:nHorzRes()
nHPage *= (300/PixelX)
nHPage -= HMARGEM
nVPage := oDanfe:nVertRes()
nVPage *= (300/PixelY)
nVPage -= VBOX 



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Definicao do Box - Recibo de entrega                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDanfe:Box(000,000,010,501)
oDanfe:Say(006, 002, "RECEBEMOS DE "+NoChar(oEmitente:_xNome:Text,lConverte)+" OS PRODUTOS CONSTANTES DA NOTA FISCAL INDICADA AO LADO", oFont07:oFont)
oDanfe:Box(009,000,037,101)
oDanfe:Say(017, 002, "DATA DE RECEBIMENTO", oFont07N:oFont)
oDanfe:Box(009,100,037,500)
oDanfe:Say(017, 102, "IDENTIFICAÇÃO E ASSINATURA DO RECEBEDOR", oFont07N:oFont)
oDanfe:Box(000,500,037,603)
oDanfe:Say(007, 542, "NF-e", oFont08N:oFont)
oDanfe:Say(017, 510, "N. "+StrZero(Val(oIdent:_NNf:Text),9), oFont08:oFont)
oDanfe:Say(027, 510, "SÉRIE "+oIdent:_Serie:Text, oFont08:oFont)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro 1 IDENTIFICACAO DO EMITENTE                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDanfe:Box(042,000,147,250)
oDanfe:Say(052,098, "Identificação do emitente",oFont12N:oFont)
nLinCalc	:=	065
cStrAux		:=	AllTrim(NoChar(oEmitente:_xNome:Text,lConverte))
nForTo		:=	Len(cStrAux)/25
nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
For nX := 1 To nForTo
	oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*25)+1),25), oFont12N:oFont )
	nLinCalc+=10
Next nX

cStrAux		:=	AllTrim(NoChar(oEmitente:_EnderEmit:_xLgr:Text,lConverte))+", "+AllTrim(oEmitente:_EnderEmit:_Nro:Text)
nForTo		:=	Len(cStrAux)/40
nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
For nX := 1 To nForTo
	oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*40)+1),40),oFont08N:oFont)
	nLinCalc+=10
Next nX

If Type("oEmitente:_EnderEmit:_xCpl") <> "U"
	cStrAux		:=	"Complemento: "+AllTrim(NoChar(oEmitente:_EnderEmit:_xCpl:TEXT,lConverte))
	nForTo		:=	Len(cStrAux)/40
	nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
	For nX := 1 To nForTo
		oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*40)+1),40),oFont08N:oFont)
		nLinCalc+=10
	Next nX
	
	cStrAux		:=	AllTrim(oEmitente:_EnderEmit:_xBairro:Text)
	If Type("oEmitente:_EnderEmit:_Cep")<>"U"
		cStrAux		+=	" Cep:"+TransForm(oEmitente:_EnderEmit:_Cep:Text,"@r 99999-999")
	EndIf
	nForTo		:=	Len(cStrAux)/40
	nForTo		+=	Iif(nForTo>Round(nForTo,0),Round(nForTo,0)+1-nForTo,nForTo)
	For nX := 1 To nForTo
		oDanfe:Say(nLinCalc,098,SubStr(cStrAux,Iif(nX==1,1,((nX-1)*40)+1),40),oFont08N:oFont)
		nLinCalc+=10
	Next nX
	oDanfe:Say(nLinCalc,098, oEmitente:_EnderEmit:_xMun:Text+"/"+oEmitente:_EnderEmit:_UF:Text,oFont08N:oFont)
	nLinCalc+=10
	oDanfe:Say(nLinCalc,098, "Fone: "+IIf(Type("oEmitente:_EnderEmit:_Fone")=="U","",oEmitente:_EnderEmit:_Fone:Text),oFont08N:oFont)
Else
	oDanfe:Say(nLinCalc,098, NoChar(oEmitente:_EnderEmit:_xBairro:Text,lConverte)+" Cep:"+TransForm(IIF(Type("oEmitente:_EnderEmit:_Cep")=="U","",oEmitente:_EnderEmit:_Cep:Text),"@r 99999-999"),oFont08N:oFont)
	nLinCalc+=10
	oDanfe:Say(nLinCalc,098, oEmitente:_EnderEmit:_xMun:Text+"/"+oEmitente:_EnderEmit:_UF:Text,oFont08N:oFont)
	nLinCalc+=10
	oDanfe:Say(nLinCalc,098, "Fone: "+IIf(Type("oEmitente:_EnderEmit:_Fone")=="U","",oEmitente:_EnderEmit:_Fone:Text),oFont08N:oFont)
EndIf 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Logotipo                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lMv_Logod
	cLogoD := GetSrvProfString("Startpath","") + "DANFE" + cEmpAnt + cFilAnt + ".BMP"
	If !File(cLogoD)
		cLogoD	:= GetSrvProfString("Startpath","") + "DANFE" + cEmpAnt + ".BMP"
		If !File(cLogoD)
			lMv_Logod := .F.
		EndIf
	EndIf
EndIf 

//If nfolha==1 	//FR - 17/12/2021 - #Chamado 11661 - TEBE - IMPRESSÃO LOGOTIPO SÓ FICAVA OK NA PÁGINA 1, ENTÃO COMENTEI ESTA PARTE PARA IMPRIMIR CERTO EM TODAS AS PÁGINAS
	If lMv_Logod
		oDanfe:SayBitmap(043,001,cLogoD,095,096)
	Else
		oDanfe:SayBitmap(043,001,cLogo,095,096)
	EndIF
//Endif



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Codigo de barra                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oDanfe:Box(042,350,093,603)
oDanfe:Box(085,350,115,603)
oDanfe:Say(107,355,TransForm(SubStr(oNF:_InfNfe:_ID:Text,4),"@r 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999"),oFont12N:oFont)
oDanfe:Box(115,350,147,603)



If !Empty(cCodAutDPEC) .And. (oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"4"
	cDataEmi := Iif(oNF:_INFNFE:_VERSAO:TEXT >= "3.10",Substr(oNFe:_NFE:_INFNFE:_IDE:_DHEMI:Text,9,2),Substr(oNFe:_NFE:_INFNFE:_IDE:_DEMI:Text,9,2))
	cTPEmis  := "4"
	
	If Type("oDPEC:_ENVDPEC:_INFDPEC:_RESNFE") <> "U"
		cUF      := aUF[aScan(aUF,{|x| x[1] == oDPEC:_ENVDPEC:_INFDPEC:_RESNFE:_UF:Text})][02]
		cValIcm := StrZero(Val(StrTran(oDPEC:_ENVDPEC:_INFDPEC:_RESNFE:_VNF:TEXT,".","")),14)
		cICMSp := iif(Val(oDPEC:_ENVDPEC:_INFDPEC:_RESNFE:_VICMS:TEXT)>0,"1","2")
		cICMSs := iif(Val(oDPEC:_ENVDPEC:_INFDPEC:_RESNFE:_VST:TEXT)>0,"1","2")
	ElseIf type ("oDPEC:_EVENTO:_INFEVENTO:_DETEVENTO:_DEST") <> "U" //EPEC NFE
		If Type ("oDPEC:_EVENTO:_INFEVENTO:_DETEVENTO:_DEST:_UF:TEXT") <> "U"
			cUF := aUF[aScan(aUF,{|x| x[1] == oDPEC:_EVENTO:_INFEVENTO:_DETEVENTO:_DEST:_UF:TEXT})][02]			
		EndIf
		If Type ("oDPEC:_EVENTO:_INFEVENTO:_DETEVENTO:_DEST:_VNF:TEXT") <> "U"
			cValIcm := StrZero(Val(StrTran(oDPEC:_EVENTO:_INFEVENTO:_DETEVENTO:_DEST:_VNF:TEXT,".","")),14)
		EndIf
		If 	Type ("oDPEC:_EVENTO:_INFEVENTO:_DETEVENTO:_DEST:_VICMS:TEXT") <> "U"
			cICMSp:= IIf(Val(oDPEC:_EVENTO:_INFEVENTO:_DETEVENTO:_DEST:_VICMS:TEXT) > 0,"1","2")
		EndIf
		If 	Type ("oDPEC:_EVENTO:_INFEVENTO:_DETEVENTO:_DEST:_VST:TEXT") <> "U"
			cICMSs := IIf(Val(oDPEC:_EVENTO:_INFEVENTO:_DETEVENTO:_DEST:_VST:TEXT )> 0,"1","2")
		EndIf	
	EndIf

ElseIF (oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"25"
	cUF      := aUF[aScan(aUF,{|x| x[1] == oNFe:_NFE:_INFNFE:_DEST:_ENDERDEST:_UF:Text})][02]
	cDataEmi := Iif(oNF:_INFNFE:_VERSAO:TEXT >= "3.10",Substr(oNFe:_NFE:_INFNFE:_IDE:_DHEMI:Text,9,2),Substr(oNFe:_NFE:_INFNFE:_IDE:_DEMI:Text,9,2))
	cTPEmis  := oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT
	cValIcm  := StrZero(Val(StrTran(oNFe:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VNF:TEXT,".","")),14)
	cICMSp   := iif(Val(oNFe:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VICMS:TEXT)>0,"1","2")
	cICMSs   :=iif(Val(oNFe:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VST:TEXT)>0,"1","2")
EndIf
If !Empty(cUF) .And. !Empty(cDataEmi) .And. !Empty(cTPEmis) .And. !Empty(cValIcm) .And. !Empty(cICMSp) .And. !Empty(cICMSs)
	If Type("oNF:_InfNfe:_DEST:_CNPJ:Text")<>"U"
		cCNPJCPF := oNF:_InfNfe:_DEST:_CNPJ:Text
		If cUf == "99"
			cCNPJCPF := STRZERO(val(cCNPJCPF),14)
		EndIf
	ElseIf Type("oNF:_INFNFE:_DEST:_CPF:Text")<>"U"
		cCNPJCPF := oNF:_INFNFE:_DEST:_CPF:Text
		cCNPJCPF := STRZERO(val(cCNPJCPF),14)
	Else
		cCNPJCPF := ""
	EndIf
	cChaveCont += cUF+cTPEmis+cCNPJCPF+cValIcm+cICMSp+cICMSs+cDataEmi
	cChaveCont := cChaveCont+Modulo11(cChaveCont)
EndIf

oDanfe:Say(127,355,"Consulta de autenticidade no portal nacional da NF-e",oFont12:oFont)
oDanfe:Say(137,355,"www.nfe.fazenda.gov.br/portal ou no site da SEFAZ Autorizada",oFont12:oFont)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro 2                                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oDanfe:Box(042,248,147,351)
oDanfe:Say(055,275, "DANFE",OFONT12N:oFont)
oDanfe:Say(065,258, "SIMPLIFICADO",OFONT12N:oFont)
oDanfe:Say(075,258, "DOCUMENTO AUXILIAR DA",oFont07:oFont)
oDanfe:Say(085,258, "NOTA FISCAL ELETRÔNICA",oFont07:oFont)
oDanfe:Say(095,266, "0-ENTRADA",oFont08:oFont)
oDanfe:Say(105,266, "1-SAÍDA"  ,oFont08:oFont)
oDanfe:Box(088,315,105,325)
oDanfe:Say(099,318, oIdent:_TpNf:Text,oFont08N:oFont)
oDanfe:Say(120,258,"N. "+StrZero(Val(oIdent:_NNf:Text),9),oFont10N:oFont)
oDanfe:Say(130,258,"SÉRIE "+oIdent:_Serie:Text,oFont10N:oFont)
oDanfe:Say(140,258,"FOLHA "+StrZero(nFolha,2)+"/"+StrZero(nFolhas,2),oFont10N:oFont)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro 4                                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDanfe:Box(149,000,172,603)
oDanfe:Box(149,351,172,603)
oDanfe:Say(158,002,"NATUREZA DA OPERAÇÃO",oFont08N:oFont)
oDanfe:Say(168,002,oIdent:_NATOP:TEXT,oFont08:oFont)

oDanfe:Say(158,353,"PROTOCOLO DE AUTORIZAÇÃO DE USO",oFont08N:oFont)


If nFolha == 1		
	If ((oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"25")
		oDanfe:Say(097,355,"DADOS DA NF-E",oFont12N:oFont)
	Else		
		oDanfe:Say(097,355,"CHAVE DE ACESSO DA NF-E",oFont12N:oFont)
	EndIf	
	nFontSize := 28
	oDanfe:Code128C(077,370,SubStr(oNF:_InfNfe:_ID:Text,4), nFontSize )
EndIf
oDanfe:Say(168,354,IIF(!Empty(cCodAutDPEC),cCodAutDPEC+" "+AllTrim(IIF(!Empty(dDtReceb),ConvDate(DTOS(dDtReceb)),Iif(oNF:_INFNFE:_VERSAO:TEXT >= "3.10",ConvDate(oNF:_InfNfe:_IDE:_DHEMI:Text),ConvDate(oNF:_InfNfe:_IDE:_DEMI:Text))))+" "+AllTrim(cDtHrRecCab),IIF(!Empty(cCodAutSef) .And. ((Val(oNF:_INFNFE:_IDE:_SERIE:TEXT) >= 900).And.(oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"23") .Or. (oNFe:_NFE:_INFNFE:_IDE:_TPEMIS:TEXT)$"1",cCodAutSef+" "+AllTrim(IIF(!Empty(dDtReceb),ConvDate(DTOS(dDtReceb)),Iif(oNF:_INFNFE:_VERSAO:TEXT >= "3.10",ConvDate(oNF:_InfNfe:_IDE:_DHEMI:Text),ConvDate(oNF:_InfNfe:_IDE:_DEMI:Text))))+" "+AllTrim(cDtHrRecCab),TransForm(cChaveCont,"@r 9999 9999 9999 9999 9999 9999 9999 9999 9999"))),oFont08:oFont)
nFolha++


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro 5                                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDanfe:Box(174,000,197,603)
oDanfe:Box(174,000,197,200)
oDanfe:Box(174,200,197,400)
oDanfe:Box(174,400,197,603)
oDanfe:Say(182,002,"INSCRIÇÃO ESTADUAL",oFont08N:oFont)
oDanfe:Say(190,002,IIf(Type("oEmitente:_IE:TEXT")<>"U",oEmitente:_IE:TEXT,""),oFont08:oFont)
oDanfe:Say(182,205,"INSC.ESTADUAL DO SUBST.TRIB.",oFont08N:oFont)
oDanfe:Say(190,205,IIf(Type("oEmitente:_IEST:TEXT")<>"U",oEmitente:_IEST:TEXT,""),oFont08:oFont)
oDanfe:Say(182,405,"CNPJ",oFont08N:oFont)
oDanfe:Say(190,405,TransForm(oEmitente:_CNPJ:TEXT,IIf(Len(oEmitente:_CNPJ:TEXT)<>14,"@r 999.999.999-99","@r 99.999.999/9999-99")),oFont08:oFont)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro destinatário/remetente                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
	Case Type("oDestino:_CNPJ")=="O"
		cAux := TransForm(oDestino:_CNPJ:TEXT,"@r 99.999.999/9999-99")
	Case Type("oDestino:_CPF")=="O"
		cAux := TransForm(oDestino:_CPF:TEXT,"@r 999.999.999-99")
	OtherWise
		cAux := Space(14)
EndCase


oDanfe:Say(205,002,"DESTINATARIO/REMETENTE",oFont08N:oFont)
oDanfe:Box(207,000,227,450)
oDanfe:Say(215,002, "NOME/RAZÃO SOCIAL",oFont08N:oFont)
oDanfe:Say(225,002,NoChar(oDestino:_XNome:TEXT,lConverte),oFont08:oFont)
oDanfe:Box(207,280,227,500)
oDanfe:Say(215,283,"CNPJ/CPF",oFont08N:oFont)
oDanfe:Say(225,283,cAux,oFont08:oFont)

oDanfe:Box(227,000,247,500)
oDanfe:Box(227,000,247,260)
oDanfe:Say(234,002,"ENDEREÇO",oFont08N:oFont)
oDanfe:Say(244,002,aDest[01],oFont08:oFont)
oDanfe:Box(227,230,247,380)
oDanfe:Say(234,232,"BAIRRO/DISTRITO",oFont08N:oFont)
oDanfe:Say(254,232,aDest[02],oFont08:oFont)
oDanfe:Box(227,380,247,500)
oDanfe:Say(234,382,"CEP",oFont08N:oFont)
oDanfe:Say(244,382,aDest[03],oFont08:oFont)

oDanfe:Box(246,000,267,500)
oDanfe:Box(246,000,267,180)
oDanfe:Say(255,002,"MUNICIPIO",oFont08N:oFont)
oDanfe:Say(265,002,aDest[05],oFont08:oFont)
oDanfe:Box(246,150,267,256)
oDanfe:Say(255,152,"FONE/FAX",oFont08N:oFont)
oDanfe:Say(265,152,aDest[06],oFont08:oFont)
oDanfe:Box(246,255,267,341)
oDanfe:Say(255,257,"UF",oFont08N:oFont)
oDanfe:Say(265,257,aDest[07],oFont08:oFont)
oDanfe:Box(246,340,267,500)
oDanfe:Say(255,342,"INSCRIÇÃO ESTADUAL",oFont08N:oFont)
oDanfe:Say(265,342,aDest[08],oFont08:oFont)


oDanfe:Box(207,502,227,603)
oDanfe:Say(215,504,"DATA DE EMISSÃO",oFont08N:oFont)
oDanfe:Say(225,504,Iif(oNF:_INFNFE:_VERSAO:TEXT >= "3.10",ConvDate(oIdent:_DHEmi:TEXT),ConvDate(oIdent:_DEmi:TEXT)),oFont08:oFont)
oDanfe:Box(227,502,247,603)
oDanfe:Say(234,504,"DATA ENTRADA/SAÍDA",oFont08N:oFont)
oDanfe:Say(243,504,Iif( Empty(aDest[4]),"",ConvDate(aDest[4]) ),oFont08:oFont)
oDanfe:Box(246,502,267,603)
oDanfe:Say(255,503,"HORA ENTRADA/SAÍDA",oFont08N:oFont)
oDanfe:Say(262,503,aHrEnt[01],oFont08:oFont)

oDet := IIf(ValType(oDet)=="O",{oDet},oDet)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro Dados do Produto / Serviço                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLenDet := Len(oDet)
If lMv_ItDesc
	For nX := 1 To nLenDet
		Aadd(aIndAux, {nX, SubStr(NoChar(oDet[nX]:_Prod:_xProd:TEXT,lConverte),1,MAXITEMC)})
	Next
	
	aIndAux := aSort(aIndAux,,, { |x, y| x[2] < y[2] })
	
	For nX := 1 To nLenDet
		Aadd(aIndImp, aIndAux[nX][1] )
	Next
EndIf

For nZ := 1 To nLenDet
	If lMv_ItDesc
		nX := aIndImp[nZ]
	Else
		nX := nZ
	EndIf
	nPrivate := nX   
    nVTotal  := Val(oDet[nX]:_Prod:_vProd:TEXT)//-Val(IIF(Type("oDet[nPrivate]:_Prod:_vDesc")=="U","",oDet[nX]:_Prod:_vDesc:TEXT))
    nVUnit   := Val(oDet[nX]:_Prod:_vUnCom:TEXT)
	nQtd     := Val(oDet[nX]:_Prod:_qTrib:TEXT)	
	
	// Tratamento para quebrar os digitos dos valores
	aAux := {}
	AADD(aAux, AllTrim(TransForm(nQtd,TM(nQtd,TamSX3("D2_QUANT")[1],TamSX3("D2_QUANT")[2]))))
	AADD(aAux, AllTrim(TransForm(nVUnit,TM(nVUnit,TamSX3("D2_PRCVEN")[1],TamSX3("D2_PRCVEN")[2]))))
	AADD(aAux, AllTrim(TransForm(nVTotal,TM(nVTotal,TamSX3("D2_TOTAL")[1],TamSX3("D2_TOTAL")[2]))))

	
	aadd(aItens,{;		
		SubStr(NoChar(oDet[nX]:_Prod:_xProd:TEXT,lConverte),1,nMaxDes),;		
		oDet[nX]:_Prod:_utrib:TEXT,;
		SubStr(aAux[1], 1, Len(aAux[1])),;
		SubStr(aAux[2], 1, Len(aAux[2])),;
		SubStr(aAux[3], 1, Len(aAux[3])),;		
	})
	
	cAux     := AllTrim(SubStr(NoChar(oDet[nX]:_Prod:_xProd:TEXT,lConverte),(nMaxDes+1)))
	aAux[1]  := SubStr(aAux[1], Len(aAux[1]) + 1)
	aAux[2]  := SubStr(aAux[2], Len(aAux[2]) + 1)
	aAux[3]  := SubStr(aAux[3], Len(aAux[3]) + 1)	

    lPontilhado := .F.	
	While !Empty(cAux) .Or. !Empty(aAux[1]) .Or. !Empty(aAux[2]) .Or. !Empty(aAux[3])
	
		aadd(aItens,{;		
			SubStr(cAux,1,nMaxDes),;
			"",;
			SubStr(aAux[1], 1, Len(aAux[1])),;
			SubStr(aAux[2], 1, Len(aAux[2])),;
			SubStr(aAux[3], 1, Len(aAux[3])),;
		})
		
		// Popula as informações para as próximas linhas adicionais
		cAux        := SubStr(cAux,(nMaxDes+1))
		aAux[1]     := SubStr(aAux[1], Len(aAux[1]) + 1)
		aAux[2]     := SubStr(aAux[2], Len(aAux[2]) + 1)
		aAux[3]     := SubStr(aAux[3], Len(aAux[3]) + 1)		
		lPontilhado := .T.	//FR - 29/06/2023
	EndDo
	
	If lPontilhado
		aadd(aItens,{;
			"-",;
			"-",;
			"-",;
			"-",;
			"-",;
			"-",;
			"-",;
			"-",;
			"-",;
			"-",;
			"-",;
			"-",;
			"-",;
			"-",;
			"-";		//FR - 07/02/2022 - ORMEC - Incluir coluna valor desconto no modo retrato  
		})
	EndIf

Next nZ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calculo do numero de folhas                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
nFolhas	  := 1
nLenItens := Len(aItens) - nMaxI // Todos os produtos/serviços excluindo a primeira página
lFlag     := .T.
While lFlag
	If nLenItens > 0
		nFolhas++
		// Se estiver habilitado frente e verso e for a segunda folha
		If MV_PAR05 == 1 .And. nFolhas == 2
			nLenItens -= nMaxI2						
		Else
			nLenItens -= nMaxIAll
		EndIf
		if ( nLenItens > -10 .And. nLenItens < 0 ) .And. nFolhas > 1//Coloca mais uma folha para impressao do rodape
			nFolhas++
		endif
	Else
		if ( nLenItens > -10 .And. nLenItens < 0 ) .And. nFolhas == 1//Coloca mais uma folha para impressao do rodape
			nFolhas++
		endif
		lFlag := .F.
	EndIf
EndDo  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Dados do produto ou servico                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAux := {{{},{},{},{},{}}}
nY := 0
nLenItens := Len(aItens)

For nX :=1 To nLenItens
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][01])
	nY++
	aadd(Atail(aAux)[nY],NoChar(aItens[nX][02],lConverte))
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][03])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][04])
	nY++
	aadd(Atail(aAux)[nY],aItens[nX][05])
	If nY >= 5
		nY := 0
	EndIf
Next nX
For nX := 1 To nLenItens
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	nY++
	aadd(Atail(aAux)[nY],"")
	If nY >= 5
		nY := 0
	EndIf
	
Next nX

nFolha := 1
nLinha := 294 //Linha inicial da primeira pagina
RiscaItem( @oDanfe, nFolha, nFolhas, aTamCol )

For nX := 1 to Len(aAux)
	
	For nZ := 1 to Len(aAux[nX][1])
		
		ImpItem( @oDanfe, aAux[nX], nFolha, nFolhas, nZ, nLinha, aTamCol )
		
		nLinha := nLinha + 10
		
		if ( nFolha < nFolhas .And. nLinha >= nFimL )
			nFolha++
			oDanfe:EndPage()
			oDanfe:StartPage()
			nHPage := oDanfe:nHorzRes()
			nHPage *= (300/PixelX)
			nHPage -= HMARGEM
			nVPage := oDanfe:nVertRes()
			nVPage *= (300/PixelY)
			nVPage -= VBOX 
			RiscaItem( @oDanfe, nFolha, nFolhas, aTamCol )
			if MV_PAR05 == 1 .And. nFolha == 2
				nLinha := 052
			else
				nLinha := 006		 
			endif
		endif		
				
	Next Nz			 			
Next nX

//Monta quadro dos Totais
oDanfe:Box(845, 000, 865, 374)
oDanfe:Say(859,002 , "VALOR TOTAL DA NOTA", oFont18N:oFont)        	
oDanfe:Box( 845, 374, 865, 603 )
oDanfe:Say(859, 376, Alltrim(Transform(Val(oTotal:_ICMSTOT:_vNF:TEXT),"@e 9,999,999,999,999.99")) ,oFont18N:oFont)

oDanfe:EndPage()

return(.T.)


static Function ImpItem(oDanfe, aItens, nFolha, nFolhas ,nItem ,nLinha, aTamCol)

local nAuxH 		:= 0


if aAux[1][1][nItem] == "-"
	oDanfe:Say(nLinha, nAuxH, Replicate("- ", 150), oFont08:oFont)
else    
	oDanfe:Say(nLinha, nAuxH + 2, aAux[1][1][nItem], oFont08:oFont) // DESCRICAO DO PRODUTO
	nAuxH += aTamCol[1]
	
	oDanfe:Say(nLinha, nAuxH + 2, aAux[1][2][nItem], oFont08:oFont) // UN
	nAuxH += aTamCol[2]
	
	oDanfe:Say(nLinha, nAuxH + 2, aAux[1][3][nItem], oFont08:oFont) // QUANT
	nAuxH += aTamCol[3]
	
	oDanfe:Say(nLinha, nAuxH + 2, aAux[1][4][nItem], oFont08:oFont) // V UNITARIO
	nAuxH += aTamCol[4]
	
	oDanfe:Say(nLinha, nAuxH + 2, aAux[1][5][nItem], oFont08:oFont) // V. TOTAL
endif
	

return(.T.)
       			                                                                                 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Finalizacao da pagina do objeto grafico                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

static Function RiscaItem( oDanfe, nFolha, nFolhas, aTamCol ) 

local lUltFolha		:= .F.
local lFrentVers	:= .F. 
local lFirsFolha	:= nFolha == 1
local nAuxH			:= 0

//Declara onde inicia as linhas dos quadros dos itens e dos Says de cada quadro, 
//os valores padrões são para a primeira pagina com Danfe de apenas 1 pagina.
local nRow1			:= 277 //Linha dos Box's 
local nRow2			:= 284 //Linha dos Say's 

//Declara a altura dos quadros dos itens, o valor padrão é para a primeira 
//página com DANFE de apenas 1 pagina
local nAlt1			:= 843   


if MV_PAR05 == 1
	lFrentVers := .T.	
endif             
if nFolhas == nFolha
	lUltFolha	:= .T.	
endif

if nFolha ==1	
	oDanfe:Say(275,002,"DADOS DO PRODUTO / SERVIÇO",oFont08N:oFont)
	oDanfe:Box(277,000,678,603)
	if !lUltFolha
		nAlt1 := 865	
	endif
elseif nFolhas > 1  .And. nFolha <> 1 
	if lFrentVers .And. nFolha == 2		
		nRow1	:= 042  
		nRow2	:= 052
		if !lUltFolha
			nAlt1	:= 865	
		endif			
		//oDanfe:Box(042,000,147,250)
	else
		nRow1	:= 000  
		nRow2	:= 010
		if !lUltFolha
			nAlt1	:= 865	
		endif			
		//oDanfe:Box(042,000,147,250)						
	endif		
else	
	
endif	
nAuxH := 0
oDanfe:Box(nRow1, nAuxH, nAlt1, nAuxH + aTamCol[1])
if lFirsFolha
	oDanfe:Say(nRow2, nAuxH + 2, "DESCRIÇÃO DO PROD./SERV.", oFont08N:oFont)
endif	
nAuxH += aTamCol[1]
oDanfe:Box(nRow1, nAuxH, nAlt1, nAuxH + aTamCol[2])
if lFirsFolha
	oDanfe:Say(nRow2, nAuxH + 2, "UN", oFont08N:oFont)
endif	
nAuxH += aTamCol[2]
oDanfe:Box(nRow1, nAuxH, nAlt1, nAuxH + aTamCol[3])
if lFirsFolha
	oDanfe:Say(nRow2, nAuxH + 2, "QUANT.", oFont08N:oFont)
endif	
nAuxH += aTamCol[3]
oDanfe:Box(nRow1, nAuxH, nAlt1, nAuxH + aTamCol[4])
if lFirsFolha
	oDanfe:Say(nRow2, nAuxH + 2, "V.UNITARIO", oFont08N:oFont)
endif	
nAuxH += aTamCol[4]
oDanfe:Box(nRow1, nAuxH, nAlt1, nAuxH + aTamCol[5])
if lFirsFolha
	oDanfe:Say(nRow2, nAuxH + 2, "V.TOTAL", oFont08N:oFont)
endif	

return(.T.)


static function getXMLColab(aIdNFe,cModalidade,lUsaColab)

local nZ			:= 0
local nCount		:= 0

local cIdEnt 		:= "000000"

local aDados		:= {}
local aRetorno	:= {}



If Empty(cModalidade)
	cModalidade := ColGetPar( "MV_MODALID", "1" )	
EndIf  
         

For nZ := 1 To len(aIdNfe) 

	nCount++

	aDados := executeRetorna( aIdNfe[nZ], cIdEnt, lUsaColab )
	
	if ( nCount == 10 )
		delClassIntF()
		nCount := 0
	endif
	
	aAdd(aRetorno,aDados)
	
Next nZ

Return(aRetorno)

static function atuSf2Hora( cDtHrRec,cSeek )

local aArea := GetArea()
 
dbSelectArea("SF2")
dbSetOrder(1)
If MsSeek(xFilial("SF2")+cSeek)
	If SF2->(FieldPos("F2_HORA"))<>0 .And. Empty(SF2->F2_HORA)
		RecLock("SF2")
		SF2->F2_HORA := cDtHrRec
		MsUnlock()
	EndIf
EndIf
dbSelectArea("SF1")
dbSetOrder(1)
If MsSeek(xFilial("SF1")+cSeek)
	If SF1->(FieldPos("F1_HORA"))<>0 .And. Empty(SF1->F1_HORA)
		RecLock("SF1")
		SF1->F1_HORA := cDtHrRec
		MsUnlock()
	EndIf
EndIf

RestArea(aArea)

return nil

//-----------------------------------------------------------------------
/*/{Protheus.doc} ColDadosNf
Devolve os dados com a informação desejada conforme parâmetro nInf.
 
@author 	Rafel Iaquinto
@since 		30/07/2014
@version 	11.9
 
@param	nInf, inteiro, Codigo da informação desejada:<br>1 - Normal<br>2 - Cancelametno<br>3 - Inutilização						

@return aRetorno Array com as posições do XML desejado, sempre deve retornar a mesma quantidade de posições.
/*/
//-----------------------------------------------------------------------
static function ColDadosNf(nInf)

local aDados	:= {}

	do case
		case nInf == 1
			//Informaçoes da NF-e
			aadd(aDados,"NFEPROC|PROTNFE|INFPROT|CSTAT") //1 - Codigo Status documento 
			aadd(aDados,"NFEPROC|PROTNFE|INFPROT|XMOTIVO") //2 - Motivo do status
			aadd(aDados,"NFEPROC|PROTNFE|INFPROT|NPROT")	//3 - Protocolo Autporizacao		
			aadd(aDados,"NFEPROC|PROTNFE|INFPROT|DHRECBTO")	//4 - Data e hora de recebimento					
			aadd(aDados,"NFEPROC|NFE|INFNFE|IDE|TPEMIS") //5 - Tipo de Emissao
			aadd(aDados,"NFEPROC|NFE|INFNFE|IDE|TPAMB") //6 - Ambiente de transmissão		
			aadd(aDados,"NFE|INFNFE|IDE|TPEMIS") //7 - Tipo de Emissao - Caso nao tenha retorno
			aadd(aDados,"NFE|INFNFE|IDE|TPAMB") //8 - Ambiente de transmissão -  Caso nao tenha retorno			
			aadd(aDados,"NFEPROC|RETDEPEC|INFDPECREG|NREGDPEC") //9 - Numero de autorização DPEC
			aadd(aDados,"NFEPROC|PROTNFE|INFPROT|CHNFE") //10 - Chave da autorizacao
		
		case nInf == 2	
			//Informacoes do cancelamento - evento
			aadd(aDados,"PROCEVENTONFE|RETEVENTO|INFEVENTO|CSTAT") //1 - Codigo Status documento 
			aadd(aDados,"PROCEVENTONFE|RETEVENTO|INFEVENTO|XMOTIVO") //2 - Motivo do status
			aadd(aDados,"PROCEVENTONFE|RETEVENTO|INFEVENTO|NPROT")	//3 - Protocolo Autporizacao		
			aadd(aDados,"PROCEVENTONFE|RETEVENTO|INFEVENTO|DHREGEVENTO")	//4 - Data e hora de recebimento					
			aadd(aDados,"") //5 - Tipo de Emissao
			aadd(aDados,"PROCEVENTONFE|RETEVENTO|INFEVENTO|TPAMB") //6 - Ambiente de transmissão		
			aadd(aDados,"") //7 - Tipo de Emissao - Caso nao tenha retorno
			aadd(aDados,"ENVEVENTO|EVENTO|INFEVENTO|TPAMB") //8 - Ambiente de transmissão -  Caso nao tenha retorno												
			aadd(aDados,"") //9 - Numero de autorização DPEC
			aadd(aDados,"") //10 - Chave da autorizacao
		
		case nInf == 3	
			//Informações da Inutilização
			aadd(aDados,"PROCINUTNFE|RETINUTNFE|INFINUT|CSTAT") //1 - Codigo Status documento 
			aadd(aDados,"PROCINUTNFE|RETINUTNFE|INFINUT|XMOTIVO") //2 - Motivo do status
			aadd(aDados,"PROCINUTNFE|RETINUTNFE|INFINUT|NPROT")	//3 - Protocolo Autporizacao		
			aadd(aDados,"PROCINUTNFE|RETINUTNFE|INFINUT|DHRECBTO")	//4 - Data e hora de recebimento					
			aadd(aDados,"") //5 - Tipo de Emissao
			aadd(aDados,"PROCINUTNFE|RETINUTNFE|INFINUT|TPAMB") //6 - Ambiente de transmissão		
			aadd(aDados,"") //7 - Tipo de Emissao - Caso nao tenha retorno
			aadd(aDados,"INUTNFE|INFINUT|TPAMB	") //8 - Ambiente de transmissão -  Caso nao tenha retorno												
			aadd(aDados,"") //9 - Numero de autorização DPEC
			aadd(aDados,"") //10 - Chave da autorizacao
	end
	
return(aDados)


static function UsaColaboracao(cModelo)
Local lUsa := .F.

If FindFunction("ColUsaColab")
	lUsa := ColUsaColab(cModelo)
endif
return (lUsa)


//==============================================================
//== HF Divisoire de Aguas
//==============================================================
Static Function HFVerEst(oNota)
Local cEstado := ""
Local xxUf    := ""
Private cAux := ""

cAux := "oNota:_NFEPROC:_NFE:_INFNFE:_IDE:_CUF:TEXT"
If Type("cAux") <> "U"
	xxUf := oNota:_NFEPROC:_NFE:_INFNFE:_IDE:_CUF:TEXT
Endif

Do Case
	Case xxUF == "11"
		cEstado := "RO"
	Case xxUF == "12"
		cEstado := "AC"
	Case xxUF == "13"
		cEstado := "AM"
	Case xxUF == "14"
		cEstado := "RR"
	Case xxUF == "15"
		cEstado := "PA"
	Case xxUF == "16"
		cEstado := "AP"
	Case xxUF == "17"
		cEstado := "TO"
	Case xxUF == "21"
		cEstado := "MA"
	Case xxUF == "22"
		cEstado := "PI"
	Case xxUF == "23"
		cEstado := "CE"
	Case xxUF == "24"
		cEstado := "RN"
	Case xxUF == "25"
		cEstado := "PB"
	Case xxUF == "26"
		cEstado := "PE"
	Case xxUF == "27"
		cEstado := "AL"
	Case xxUF == "28"
		cEstado := "SE"
	Case xxUF == "29"
		cEstado := "BA"
	Case xxUF == "31"
		cEstado := "MG"
	Case xxUF == "32"
		cEstado := "ES"
	Case xxUF == "33"
		cEstado := "RJ"
	Case xxUF == "35"
		cEstado := "SP"
	Case xxUF == "41"
		cEstado := "PR"
	Case xxUF == "42"
		cEstado := "SC"
	Case xxUF == "43"
		cEstado := "RS"
	Case xxUF == "50"
		cEstado := "MS"
	Case xxUF == "51"
		cEstado := "MT"
	Case xxUF == "52"
		cEstado := "GO"
	Case xxUF == "53"
		cEstado := "DF"
EndCase

Return( cEstado )


/*/{Protheus.doc} zGerDanfe
Função que gera a danfe e o xml de uma nota em uma pasta passada por parâmetro
@author Atilio
@since 07/07/2020
@version 1.0
@param cNota, characters, Nota que será buscada
@param cSerie, characters, Série da Nota
@param cPasta, characters, Pasta que terá o XML e o PDF salvos
@type function
@example u_zGerDanfe("000123ABC", "1", "C:\TOTVS\NF")
@obs Para o correto funcionamento dessa rotina, é necessário:
    1. Ter baixado e compilado o rdmake danfeii.prw
/*/
Static Function zGerDanfe(cNota, cSerie, cPasta, cFile)

    Local aArea     := GetArea()
    Local cIdent    := ""
    Local cArquivo  := ""
    Local oDanfe    := Nil
    Local lEnd      := .F.
    Local nTamNota  := TamSX3('F2_DOC')[1]
    Local nTamSerie := TamSX3('F2_SERIE')[1]
    Private PixelX
    Private PixelY
    Private nConsNeg
    Private nConsTex
    Private oRetNF
    Private nColAux
    Static cNota   := ""
    Static cSerie  := ""
    Static cPasta  := GetTempPath()
     
    //Se existir nota
    If ! Empty(cNota)

        //Pega o IDENT da empresa
        cIdent := RetIdEnti()
         
        //Se o último caracter da pasta não for barra, será barra para integridade
        If SubStr(cPasta, Len(cPasta), 1) != "\"
            cPasta += "\"
        EndIf
         
        //Gera o XML da Nota
        cArquivo := cFile  //cNota + "_" + dToS(Date()) + "_" + StrTran(Time(), ":", "-")
        //u_zSpedXML(cNota, cSerie, cPasta + cArquivo  + ".xml", .F.)
         
        //Define as perguntas da DANFE
        //Pergunte("NFSIGW",.F.)
        MV_PAR01 := PadR(cNota,  nTamNota)     //Nota Inicial
        MV_PAR02 := PadR(cNota,  nTamNota)     //Nota Final
        MV_PAR03 := PadR(cSerie, nTamSerie)    //Série da Nota
        //MV_PAR04 := 2                          //NF de Saida
        MV_PAR05 := 1                          //Frente e Verso = Sim
        //MV_PAR06 := 2                          //DANFE simplificado = Nao
         
        //Cria a Danfe
        oDanfe := FWMSPrinter():New(cArquivo, IMP_PDF, .F., , .T.)
         
        //Propriedades da DANFE
        oDanfe:SetResolution(78)
        oDanfe:SetPortrait()
        oDanfe:SetPaperSize(DMPAPER_A4)
        oDanfe:SetMargin(60, 60, 60, 60)
         
        //Força a impressão em PDF
        oDanfe:nDevice  := 6
        oDanfe:cPathPDF := cPasta                
        oDanfe:lServer  := .F.
        oDanfe:lViewPDF := .F.
         
        //Variáveis obrigatórias da DANFE (pode colocar outras abaixo)
        PixelX    := oDanfe:nLogPixelX()
        PixelY    := oDanfe:nLogPixelY()
        nConsNeg  := 0.4
        nConsTex  := 0.5
        oRetNF    := Nil
        nColAux   := 0
         
        //Chamando a impressão da danfe no RDMAKE
        //RptStatus({|lEnd| StaticCall(DANFE_X4, DanfeProc, @oDanfe, @lEnd, cIdent, , , .F.)}, "Imprimindo Danfe...")		
		//RptStatus({|lEnd| DanfeProc(lAuto,oNota,@oDanfe,@lEnd,cIdEnt,,,@lExistNfe)},"Imprimindo Danfe...")
        
		oDanfe:Print()

    EndIf
     
    RestArea(aArea)

Return
