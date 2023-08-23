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
#DEFINE MAXITEM    018                                                // Máximo de produtos para a primeira página
#DEFINE MAXITEMP2  049                                                // Máximo de produtos para a pagina 2 em diante
#DEFINE MAXITEMP2F 069                                                // Máximo de produtos para a página 2 em diante quando a página não possui informações complementares
#DEFINE MAXITEMP3  025                                                // Máximo de produtos para a pagina 2 em diante (caso utilize a opção de impressao em verso) - Tratamento implementado para atender a legislacao que determina que a segunda pagina de ocupar 50%.
#DEFINE MAXITEMC   040                                                // Máxima de caracteres por linha de produtos/serviços
#DEFINE MAXMENLIN  080                                                // Máximo de caracteres por linha de dados adicionais
#DEFINE MAXMSG     013                                                // Máximo de dados adicionais por página
#DEFINE MAXVALORC  008                                                // Máximo de caracteres por linha de valores numéricos
#DEFINE DMPAPER_A4 009                                                // A4 210 x 297 mm  

Static Linha_INI  := 0100
Static Coluna_INI := 0100
Static Linha_FIM  := 3400
Static Coluna_FIM := 2290


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ DanfseSP º Autor ³ HF                 º Data ³  12/09/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Impressao de Danfse São Paulo - SP                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ XML                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ DanfseSP º Autor ³ LUCAS SANTANA      º Data ³  06/09/2022 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³INCLUSÃO DE COLUNAS E IMPOSTOS NA DANFSE, INICIO EM 06/09/22º±±
±±º          ³ TÉRMINO EM 09/09/2022                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ XML                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

//User Function DanfseSP()
User Function DanfseSP(lAutoDanf,xDirDanf,xArqDanfe)

Local aArea     := GetArea()
Local cError    := ""
Local cWarning  := ""
Local cDestFile := GetSrvProfString("STARTPATH","")       		//FR - 01/12/2020

//FR - 31/03/2022 - PROJETO KITCHENS
Local lAutoDanfe := .F.  			 
Local cDirDanfe  := ""
Local cFilePrint := ""
Local oSetup
Local oDanfe
Local aDevice    := {}
Local cSession   := GetPrinterSession()	
Local nPrintType
//FR - 31/03/2022 - PROJETO KITCHENS	

If (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO"))) <> "RP"
	Aviso("DANFSESP","Somente Nota Fiscal de Serviço de SP, importada com TXT...",{"OK"},3)
	Return( .T. )
Endif

Private cTitulo  := "NFS-e DE PREFEITURA " //LUCAS SAN 06/09/2022
Private oXml := XmlParser( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML"))), "_", @cError, @cWarning )
Private cCod := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR")))
Private cLoj := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR")))

cDestFile += "pdf\"

Makedir(cDestFile)
	
If lAutoDanf <> NIL
	If Valtype(lAutoDanf) <> "C" //If lAutoDanf
		
		cFilePrint := xArqDanfe 
		lAutoDanfe := .T. 		
		cDirDanfe  := xDirDanf
		
		AADD(aDevice,"DISCO") // 1
		AADD(aDevice,"SPOOL") // 2
		AADD(aDevice,"EMAIL") // 3
		AADD(aDevice,"EXCEL") // 4
		AADD(aDevice,"HTML" ) // 5
		AADD(aDevice,"PDF"  ) // 6		
		
		nLocal       	:= If(GetProfString(cSession,"LOCAL","SERVER",.T.)=="SERVER",1,2 )
		nOrientation 	:= If(GetProfString(cSession,"ORIENTATION","PORTRAIT",.T.)=="PORTRAIT",1,2)
		cDevice     	:= GetProfString(cSession,"PRINTTYPE","SPOOL",.T.)
		nPrintType      := aScan(aDevice,{|x| x == cDevice })
	
		lAdjustToLegacy := .F. // Inibe legado de resolução com a TMSPrinter
		
		oDanfe := FWMSPrinter():New(cFilePrint, IMP_PDF, lAdjustToLegacy, cDestFile, .T.)     //cDestFile --> \system\pdf\
		nFlags := PD_ISTOTVSPRINTER + PD_DISABLEPAPERSIZE + PD_DISABLEPREVIEW + PD_DISABLEMARGIN
		
		oSetup := FWPrintSetup():New(nFlags, "DANFE")
		
		// ----------------------------------------------
		// Define saida
		// ----------------------------------------------
		oSetup:SetPropert(PD_PRINTTYPE   , nPrintType)
		oSetup:SetPropert(PD_ORIENTATION , nOrientation)
		oSetup:SetPropert(PD_DESTINATION , nLocal)
		oSetup:SetPropert(PD_MARGIN      , {60,60,60,60})
		oSetup:SetPropert(PD_PAPERSIZE   , DMPAPER_A4)
		
		If oSetup:Activate() == PD_OK // PD_OK =1
		    		
			oSetup:AOPTIONS[6]:= cDirDanfe
			
			WriteProfString( cSession, "LOCAL"      , If(oSetup:GetProperty(PD_DESTINATION)==1 ,"SERVER"    ,"CLIENT"    ), .T. )
			WriteProfString( cSession, "PRINTTYPE"  , If(oSetup:GetProperty(PD_PRINTTYPE)==1   ,"SPOOL"     ,"PDF"       ), .T. )
			WriteProfString( cSession, "ORIENTATION", If(oSetup:GetProperty(PD_ORIENTATION)==1 ,"PORTRAIT"  ,"LANDSCAPE" ), .T. )
			
			ImpRel(lAutoDanf,oDanfe,oSetup)
		
	   	Endif

	Else 
	
		dbSelectArea( "SA2" )
		dbSetOrder(1)
		if ! SA2->( dbSeek( xFilial( "SA2" ) + cCod + cLoj ) )
			Aviso("DANFSESP","Fornecedor não Encontrado, Verifique...",{"OK"},3)
		Elseif oXml != NIl
			ImpRel()
		endif
	
	Endif 
	
Endif 

RestArea( aArea )
Return( .T. )


Static Function ImpRel(lAutoDanfe,oDanfe,oSetup)
Local   cAux        := ""
Local   nPos        := 0

Private nomeProg	:= FunName()
Private cFileLogo   := GetSrvProfString('Startpath','') + 'rlogo' + '.bmp'
Private _aArea		:= GetArea()
Private nLin 		:= 1650 // Linha de inicio da impressao
Private nPag        := 0, nPagTot := 0 

/*
Private oPrn	:= TMSPrinter():New(OemToAnsi(cTitulo)),;
oFont06	 		:= TFont():New("Times New Roman",06,06,,.F.,,,,.T.,.F.),;
oFont06N 		:= TFont():New("Times New Roman",06,06,,.T.,,,,.T.,.F.),;
oFont07	 		:= TFont():New("Times New Roman",07,07,,.F.,,,,.T.,.F.),;
oFont07N 		:= TFont():New("Times New Roman",07,07,,.T.,,,,.T.,.F.),;
oFont08	 		:= TFont():New("Times New Roman",08,08,,.F.,,,,.T.,.F.),;
oFont08N 		:= TFont():New("Times New Roman",08,08,,.T.,,,,.T.,.F.),;
oFont09	 		:= TFont():New("Times New Roman",09,09,,.F.,,,,.T.,.F.),;
oFont09N 		:= TFont():New("Times New Roman",09,09,,.T.,,,,.T.,.F.),;
oFont10	 		:= TFont():New("Times New Roman",10,10,,.F.,,,,.T.,.F.),;
oFont10N 		:= TFont():New("Times New Roman",10,10,,.T.,,,,.T.,.F.),;
oFont11  		:= TFont():New("Times New Roman",11,11,,.F.,,,,.T.,.F.),;
oFont11N  		:= TFont():New("Times New Roman",11,11,,.T.,,,,.T.,.F.),;
oFont12  		:= TFont():New("Times New Roman",12,12,,.F.,,,,.T.,.F.),;
oFont12N 		:= TFont():New("Times New Roman",12,12,,.T.,,,,.T.,.F.),;
oFont14	 		:= TFont():New("Times New Roman",14,14,,.F.,,,,.T.,.F.),;
oFont14N 		:= TFont():New("Times New Roman",14,14,,.T.,,,,.T.,.F.),;
oFont16	 		:= TFont():New("Times New Roman",16,16,,.F.,,,,.T.,.F.),;
oFont16N 		:= TFont():New("Times New Roman",16,16,,.T.,,,,.T.,.F.),;
oFont18	 		:= TFont():New("Times New Roman",18,18,,.F.,,,,.T.,.F.),;
oFont18N 		:= TFont():New("Times New Roman",18,18,,.T.,,,,.T.,.F.),;
oFont20N 		:= TFont():New("Times New Roman",20,20,,.T.,,,,.T.,.F.)
oFont22N 		:= TFont():New("Times New Roman",22,22,,.T.,,,,.T.,.F.)
*/

//FR - 30/04/2022 - PROJETO KITCHENS 
Private oPrn
Private oFont07	 		
Private oFont07N 		
Private oFont08	 		
Private oFont08N 		
Private oFont09	 		
Private oFont09N 		
Private oFont10	 		
Private oFont10N 		
Private oFont11  		
Private oFont11N  		
Private oFont12  		
Private oFont12N 		
Private oFont14	 		
Private oFont14N 		
Private oFont16	 		
Private oFont16N 		
Private oFont18	 		
Private oFont18N 		
Private oFont20N 		
Private oFont22N 		
//FR - 30/04/2022 - PROJETO KITCHENS

oBrush1         := TBrush():New( , CLR_HGRAY )

If lAutoDanfe <> Nil
 
	//oDanfe     := TMSPrinter():New(OemToAnsi(cTitulo))
	oFont07    := TFontEx():New(oDanfe,"Times New Roman",07,07,.F.,.T.,.F.)
	oFont07N   := TFontEx():New(oDanfe,"Times New Roman",07,07,.T.,.T.,.F.)
	oFont08    := TFontEx():New(oDanfe,"Times New Roman",08,08,.F.,.T.,.F.)
	oFont08N   := TFontEx():New(oDanfe,"Times New Roman",08,08,.T.,.T.,.F.)
	oFont09N   := TFontEx():New(oDanfe,"Times New Roman",08,08,.T.,.T.,.F.)
	oFont09    := TFontEx():New(oDanfe,"Times New Roman",08,08,.F.,.T.,.F.)
	oFont10    := TFontEx():New(oDanfe,"Times New Roman",09,09,.F.,.T.,.F.)
	oFont10N   := TFontEx():New(oDanfe,"Times New Roman",08,08,.T.,.T.,.F.)
	oFont11    := TFontEx():New(oDanfe,"Times New Roman",10,10,.F.,.T.,.F.)
	oFont11N   := TFontEx():New(oDanfe,"Times New Roman",10,10,.T.,.T.,.F.)	
	oFont12    := TFontEx():New(oDanfe,"Times New Roman",11,11,.F.,.T.,.F.)
	OFONT12N   := TFontEx():New(oDanfe,"Times New Roman",11,11,.T.,.T.,.F.) 
	oFont14N   := TFontEx():New(oDanfe,"Times New Roman",13,13,.T.,.T.,.F.) 
	oFont16	   := TFontEx():New(oDanfe,"Times New Roman",16,16,.F.,.T.,.F.)
	oFont16N   := TFontEx():New(oDanfe,"Times New Roman",16,16,.T.,.T.,.F.)
	oFont18	   := TFontEx():New(oDanfe,"Times New Roman",18,18,.F.,.T.,.F.)
	oFont18N   := TFontEx():New(oDanfe,"Times New Roman",18,18,.T.,.T.,.F.)
	oFont20N   := TFontEx():New(oDanfe,"Times New Roman",20,20,.T.,.T.,.F.)
	oFont22N   := TFontEx():New(oDanfe,"Times New Roman",22,22,.T.,.T.,.F.)
	

	If lAutoDanfe
	
		oDanfe:SetResolution(72) //Tamanho estipulado para a Danfe
		oDanfe:SetPortrait()
		oDanfe:SetPaperSize(DMPAPER_A4)
		//oDanfe:SetMargin(60,60,60,60)
		//oDanfe:SetMargin(30,30,30,30)
		oDanfe:SetMargin(5,5,5,5)
		oDanfe:lServer := oSetup:GetProperty(PD_DESTINATION)==AMB_SERVER
		cAux := ""
		nPos := 0
	
		If oSetup:GetProperty(PD_PRINTTYPE) == IMP_PDF
		
			oDanfe:nDevice := IMP_PDF
			// ----------------------------------------------
			// Define para salvar o PDF
			// ----------------------------------------------
			oDanfe:cPathPDF := oSetup:aOptions[PD_VALUETYPE]
			cAux            := oSetup:aOptions[PD_VALUETYPE] 
		    nPos            := RAT("\", cAux)          //D:\SPOOL\DANFE_20220404.PDF
			cDirDanfe       := Substr(cAux,1,nPos)  			
			
			//oPrn:SetPortrait()	 //--> SetLandsCape() 		// Definir Orientacao da Impressao
			//oPrn:setPaperSize(9) //--> PAPEL A4
			//oPrn:StartPage()     //-->
			
			//nPagTot++			
			CabecRel(@oDanfe,oSetup)
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| exibe em Video, e finaliza a impressao. ! ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 		
			//oPrn:Preview()
			//oPrn:EndPage() 
			oDanfe:EndPage()
			//MS_FLUSH()
			
			oDanfe:lViewpdf := .F.	//para não explodir na tela o pdf gerado	
			oDanfe:Print()	//aqui gera o pdf de fato
			
			FreeObj(oDanfe)
   			oDanfe := Nil 									 
			
		Endif
		
	Endif 
		
Else

	oPrn			:= TMSPrinter():New(OemToAnsi(cTitulo))
	oFont06	 		:= TFont():New("Times New Roman",06,06,,.F.,,,,.T.,.F.)
	oFont06N 		:= TFont():New("Times New Roman",06,06,,.T.,,,,.T.,.F.)
	oFont07	 		:= TFont():New("Times New Roman",07,07,,.F.,,,,.T.,.F.)
	oFont07N 		:= TFont():New("Times New Roman",07,07,,.T.,,,,.T.,.F.)
	oFont08	 		:= TFont():New("Times New Roman",08,08,,.F.,,,,.T.,.F.)
	oFont08N 		:= TFont():New("Times New Roman",08,08,,.T.,,,,.T.,.F.)
	oFont09	 		:= TFont():New("Times New Roman",09,09,,.F.,,,,.T.,.F.)
	oFont09N 		:= TFont():New("Times New Roman",09,09,,.T.,,,,.T.,.F.)
	oFont10	 		:= TFont():New("Times New Roman",10,10,,.F.,,,,.T.,.F.)
	oFont10N 		:= TFont():New("Times New Roman",10,10,,.T.,,,,.T.,.F.)
	oFont11  		:= TFont():New("Times New Roman",11,11,,.F.,,,,.T.,.F.)
	oFont11N  		:= TFont():New("Times New Roman",11,11,,.T.,,,,.T.,.F.)
	oFont12  		:= TFont():New("Times New Roman",12,12,,.F.,,,,.T.,.F.)
	oFont12N 		:= TFont():New("Times New Roman",12,12,,.T.,,,,.T.,.F.)
	oFont14	 		:= TFont():New("Times New Roman",14,14,,.F.,,,,.T.,.F.)
	oFont14N 		:= TFont():New("Times New Roman",14,14,,.T.,,,,.T.,.F.)
	oFont16	 		:= TFont():New("Times New Roman",16,16,,.F.,,,,.T.,.F.)
	oFont16N 		:= TFont():New("Times New Roman",16,16,,.T.,,,,.T.,.F.)
	oFont18	 		:= TFont():New("Times New Roman",18,18,,.F.,,,,.T.,.F.)
	oFont18N 		:= TFont():New("Times New Roman",18,18,,.T.,,,,.T.,.F.)
	oFont20N 		:= TFont():New("Times New Roman",20,20,,.T.,,,,.T.,.F.)
	oFont22N 		:= TFont():New("Times New Roman",22,22,,.T.,,,,.T.,.F.)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicia a montagem da impressao.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPrn:SetPortrait()	 //--> SetLandsCape() 		// Definir Orientacao da Impressao
oPrn:setPaperSize(9) //--> PAPEL A4
oPrn:StartPage()     //-->

nPagTot++
//ItensSomis() //só pa acha o total de pagina

CabecRel()
//ItensRel()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| exibe em Video, e finaliza a impressao. ! ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  

	oPrn:Preview()
	oPrn:EndPage()
	MS_FLUSH()

Endif 

RestArea( _aArea )
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CabecRel ³ Autor ³ José Ferreira Neto    ³ Data ³   		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³  cabecalho do relatorio de necessidad de insumo por cliente³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Estr0002 - Exclusivo Coferly - HF Consulting               ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function CabecRel(oDanfe,oSetup)
Local cBitMap3	 :=	"logo.bmp"
Local cDoc       := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA")))
Local dEmi       := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"DTNFE")))
Local cChave     := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE")))
Local cCodSErv   := ""
Local nVrServ    := 0
Local nVrDedz    := 0
Local nAliq      := 0
Local nVRISS     := 0
Local nICMVAL	 := (xZBT)->(FieldGet(FieldPos(xZBT_+"ICMVAL")))	//Lucas San 06/09/2022
Local nINSVAL	 := (xZBT)->(FieldGet(FieldPos(xZBT_+"INSVAL")))	//Lucas San 09/08/2022
Local nIrrVal	 := (xZBT)->(FieldGet(FieldPos(xZBT_+"IRRVAL"))) 	//Lucas San 08/09/2022
Local nCsllVal	 := (xZBT)->(FieldGet(FieldPos(xZBT_+"CSLVAL")))	//Lucas San 08/09/2022
Local nCofVal	 := (xZBT)->(FieldGet(FieldPos(xZBT_+"COFVAL")))	//Lucas San 08/09/2022
Local nPisVal	 := (xZBT)->(FieldGet(FieldPos(xZBT_+"PISVAL")))	//Lucas San 08/09/2022
Local cDescr     := ""
Local cError     := "", cWarning := ""
Local nI         := 0
Local nHPage     := 0
Local nVPage     := 0 
Private PixelX   
Private PixelY   
Private nColAux   

Private oXmlSrv

#Define PAD_LEFT            0
#Define PAD_RIGHT           1
#Define PAD_CENTER          2

(xZBT)->( dbSetOrder(2) )		//FR - 27/11/19 - ZBT_CHAVE (índice sem filial)
If (xZBT)->( dbSeek( cChave ) )
	cCodSErv := (xZBT)->(FieldGet(FieldPos(xZBT_+"PRODUT")))
EndIf

oXmlSrv := XmlParser( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"XML"))), "_", @cError, @cWarning )

cDescr := ""
if Type( "oXmlSrv:_NFSETXT:_INFPROC:_DESSRV:TEXT" ) <> "U"
	cDescr  := AllTrim(oXmlSrv:_NFSETXT:_INFPROC:_DESSRV:TEXT)
Endif
If Type( "oXmlSrv:_NFSETXT:_INFPROC:_COFVAL:TEXT") <> "U"
	nCofVal := Val( oXmlSrv:_NFSETXT:_INFPROC:_COFVAL:TEXT )	//LUCAS SAN 08/09/2022
ENDIF															
if Type( "oXmlSrv:_NFSETXT:_INFPROC:_VRSERV:TEXT" ) <> "U"
	nVrServ := Val( oXmlSrv:_NFSETXT:_INFPROC:_VRSERV:TEXT )
Endif
if Type( "oXmlSrv:_NFSETXT:_INFPROC:_VRDEDZ:TEXT" ) <> "U"
	nVrDedz := Val( oXmlSrv:_NFSETXT:_INFPROC:_VRDEDZ:TEXT )
Endif
if Type( "oXmlSrv:_NFSETXT:_INFPROC:_ALIQ:TEXT" ) <> "U"
	nAliq   := Val( oXmlSrv:_NFSETXT:_INFPROC:_ALIQ:TEXT )
Endif
if Type( "oXmlSrv:_NFSETXT:_INFPROC:_VRISS:TEXT" ) <> "U"
	nVRISS  := Val( oXmlSrv:_NFSETXT:_INFPROC:_VRISS:TEXT )
EndIF
if Type( "oXmlSrv:_NFSETXT:_INFPROC:_ICMVAL:TEXT" ) <> "U"
	nICMVAL  := Val( oXmlSrv:_NFSETXT:_INFPROC:_ICMVAL:TEXT )
EndIF

If oDanfe == NIL
	// C A B E C A L H O
nPag++

//oPrn:Box(Linha_INI,Coluna_INI,Linha_FIM,Coluna_FIM)
//oPrn:Box(0010,0010,0320,2390)	//--> BOX - Cabecalho
oPrn:Box(Linha_INI,Coluna_INI,3300     ,Coluna_FIM)	  //--> BOX - Pagina Inteiris
oPrn:Box(Linha_INI,Coluna_INI,0400     ,Coluna_FIM)	  //--> BOX - Cabeçalho
oPrn:Box(Linha_INI,1900      ,0400     ,Coluna_FIM)   //--> BOX - pagina
//oPrn:Box(0400     ,Coluna_INI,0400     ,Coluna_FIM)   //--> FOX - Prestador
oPrn:Box(0650     ,Coluna_INI,0650     ,Coluna_FIM)   //--> FOX - Tomador
oPrn:Box(0910     ,Coluna_INI,0910     ,Coluna_FIM)   //--> FOX - Discriminaçao
//oPrn:FillRect( {Linha_INI+5,0505,0150  ,1900}, oBrush1 )

oPrn:SayBitmap(0115,0115,cBitMap3,0180,0120)
oPrn:Say(0150,0110, PADC(cTitulo,65) ,oFont18N)
oPrn:Say(0225,0180, PADC("NFS-e IMPRESSA PELO GESTÃO XML",80) ,oFont14N)
oPrn:Say(0300,0180, PADC("NOTA FISCAL DE SERVICO ELETRONICA (NFS-e)",80) ,oFont14N)

oPrn:Box(0225,1900,0225     ,Coluna_FIM)  //--> BOX - Doc
oPrn:Box(0320,1900,0320     ,Coluna_FIM)  //--> BOX - Datis

oPrn:Say(0115,1910,"Numero da Nota:",oFont11)
oPrn:Say(0170,1950,PadC(AllTrim(cDoc),15),oFont12N)
oPrn:Say(0225,1910,"Data:"   ,oFont11)
oPrn:Say(0270,1950,dToc(dEmi),oFont12N)

oPrn:Say(0410,0250, PADC("PRESTADOR SERVIÇOS",132) ,oFont12N)
oPrn:Say(0455,0110, "CPF/CNPJ:",oFont10N)
oPrn:Say(0455,0460, SA2->A2_CGC,oFont10)
oPrn:Say(0455,1110, "Inscrição Municipal:",oFont10N)
oPrn:Say(0455,1460, SA2->A2_INSCRM,oFont10)
oPrn:Say(0505,0110, "Nome/Razão Social:",oFont10N)
oPrn:Say(0505,0460, SA2->A2_NOME,oFont10)
oPrn:Say(0555,0110, "Endereço:",oFont10N)
oPrn:Say(0555,0460, SA2->A2_END,oFont10)
oPrn:Say(0605,0110, "Município:",oFont10N)
oPrn:Say(0605,0460, SA2->A2_MUN,oFont10)
oPrn:Say(0605,1390, "UF:",oFont10N)
oPrn:Say(0605,1460, SA2->A2_EST,oFont10)

oPrn:Say(0660,0250, PADC("TOMADOR SERVIÇOS",132) ,oFont12N)

oPrn:Say(0705,0110, "CPF/CNPJ:",oFont10N)
oPrn:Say(0705,0460, SM0->M0_CGC,oFont10)
oPrn:Say(0705,1110, "Inscrição Municipal:",oFont10N)
oPrn:Say(0705,1460, SM0->M0_INSCM,oFont10)
oPrn:Say(0755,0110, "Nome/Razão Social:",oFont10N)
oPrn:Say(0755,0460, SM0->M0_NOMECOM,oFont10)
oPrn:Say(0805,0110, "Endereço:",oFont10N)
oPrn:Say(0805,0460, SM0->M0_ENDENT,oFont10)
oPrn:Say(0855,0110, "Município:",oFont10N)
oPrn:Say(0855,0460, SM0->M0_CIDENT,oFont10)
oPrn:Say(0855,1390, "UF:",oFont10N)
oPrn:Say(0855,1460, SM0->M0_ESTENT,oFont10)
//oPrn:Say(3350,0025, PADC(AllTrim(SM0->M0_NOMECOM),0400) ,oFont06)
//oPrn:Say(3375,0025, PADC(AllTrim(SM0->M0_ENDENT)+" - "+AllTrim(SM0->M0_BAIRENT)+" - "+AllTrim(SM0->M0_CIDENT)+Alltrim(SM0->M0_ESTENT),0390) ,oFont06)
//oPrn:Say(3400,0025, PADC("TEL.: "+AllTrim(SM0->M0_TEL)+" www.coferly.com.br",0400)  ,oFont06)

oPrn:Say(0915,0250, PADC("DISCRIMINAÇÃO DOS SERVIÇOS",132) ,oFont12N)
nLin := 1015
//cDescr := "1111111111222222222233333333334444444444555555555566666666667777777777888888888899999999990000000000"
//cDescr += "A111111111222222222233333333334444444444555555555566666666667777777777888888888899999999990000000000"
//cDescr += "B111111111222222222233333333334444444444555555555566666666667777777777888888888899999999990000000000"
For nI := 1 To Len( cDescr ) Step 100
	oPrn:Say(nLin,0140, Substr(cDescr,nI,100) ,oFont10)
	nLin += 50
	if nLin > 2300
		Exit
	endif
Next
	//LUCAS SAN 08/09/2022
	oPrn:Box(2300     ,Coluna_INI,2300     ,Coluna_FIM)   //--> BOX - Linha horizontal 
	oPrn:Say(2330,Coluna_INI+5, PADC("VALOR TOTAL DA NF/SERVIÇO = R$ "+AllTrim(Str(nVrServ,15,2)),120) ,oFont14N)
	oPrn:Box(2400	  ,Coluna_INI,2400	   ,Coluna_FIM)

//LUCAS SAN 08/09/2022 -> INCLUSÃO DE NOVA LINHA DE IMPOSTOS
	oPrn:Box(2400     ,Coluna_INI+0400,2550,Coluna_INI+0400) //Linha vertical ->INSS
	oPrn:Box(2400     ,Coluna_INI+0800,2550,Coluna_INI+0800) //Linha vertical ->IRRF
	oPrn:Box(2400     ,Coluna_INI+1200,2550,Coluna_INI+1200) //Linha vertical ->CSLL
	oPrn:Box(2400     ,Coluna_INI+1600,2550,Coluna_INI+1600) //Linha vertical ->COFINS
	oPrn:Say(2400,Coluna_INI+0150, "INSS (R$)", oFont11)
	oPrn:Say(2400,Coluna_INI+0550, "IRRF (R$)", oFont11)
	oPrn:Say(2400,Coluna_INI+0950, "CSLL (R$)", oFont11)
	oPrn:Say(2400,Coluna_INI+1300, "COFINS (R$)", oFont11)
	oPrn:Say(2400,Coluna_INI+1800, "PIS/PASEP (R$)", oFont11)
	Oprn:Say(2500,Coluna_INI+0160, Transform(nINSVAL,"@E 999,999,999,999.99"),oFont12N)
	Oprn:Say(2500,Coluna_INI+0555, Transform(nIrrVal,"@E 999,999,999,999.99"),oFont12N)
	Oprn:Say(2500,Coluna_INI+0955, Transform(nCsllVal,"@E 999,999,999,999.99"),oFont12N)
	Oprn:Say(2500,Coluna_INI+1305, Transform(nCofVal,"@E 999,999,999,999.99"),oFont12N)
	Oprn:Say(2500,Coluna_INI+1805, Transform(nPisVal,"@E 999,999,999,999.99"),oFont12N)
//LUCAS SAN 09/09/2022 -> FINALIZADO GRAVAÇÃO DE IMPOSTOS

	oPrn:Box(2550     ,Coluna_INI,2550     ,Coluna_FIM)   //--> BOX
	oPrn:Say(2565   ,Coluna_INI+0010, "Código do Serviço" ,oFont10)
	oPrn:Say(2565+40,Coluna_INI+0040, cCodSErv            ,oFont12N)
	
	oPrn:Box(2700     ,Coluna_INI,2700     ,Coluna_FIM)   //--> BOX
	oPrn:Box(2700     ,Coluna_INI+0705,2850,Coluna_INI+0705)   //--> Linha Vertical
	oPrn:Box(2700     ,Coluna_INI+1205,2850,Coluna_INI+1205)   //--> Linha Vertical
	oPrn:Box(2700     ,Coluna_INI+1505,2850,Coluna_INI+1505)   //--> Linha Vertical
	oPrn:Box(2700     ,Coluna_INI+1805,2850,Coluna_INI+1805)   //--> Linha Vertical
	oPrn:Say(2715,Coluna_INI+0120, "Valor Total das Deduções (R$)" ,oFont11)
	oPrn:Say(2715,Coluna_INI+0750, "Base de Cálculo (R$)" ,oFont11)
	oPrn:Say(2715,Coluna_INI+1275, "Alíquota (%)" ,oFont11)
	oPrn:Say(2715,Coluna_INI+1520, "Valor do ISS (R$)" ,oFont11)
	oPrn:Say(2715,Coluna_INI+1900, "ICMS (R$)" ,oFont11)		//LUCAS SAN 09/09/2022
	oPrn:Say(2800,Coluna_INI+0325, Transform(nVrDedz,"@E 999,999,999,999.99") ,oFont12N)
	oPrn:Say(2800,Coluna_INI+0915, Transform(nVrServ-nVrDedz,"@E 999,999,999,999.99") ,oFont12N)
	oPrn:Say(2800,Coluna_INI+1315, Transform(nAliq,"@E 999.99") ,oFont12N)
	oPrn:Say(2800,Coluna_INI+1550, Transform(nVRISS,"@E 999,999,999,999.99") ,oFont12N)
	oPrn:Say(2800,Coluna_INI+1905, Transform(nICMVAL,"@E 999,999,999,999.99") ,oFont12N) //LUCAS SAN 06/09/2022
	
	oPrn:Box(2850     ,Coluna_INI,3300     ,Coluna_FIM)   //--> BOX - Observaciones, antes do rodapesis
	//oPrn:FillRect( {2730     ,Coluna_INI+5,2800     ,Coluna_FIM}, oBrush1 )
	
	oPrn:Say(2875,0950, "OUTRAS INFORMAÇÕES" ,oFont12N)
	oPrn:Say(3000,Coluna_INI+0010, "- Esta NFS-e foi emitida com respaldo da Lei No. 14.097/2005." ,oFont10)
	
	//oPrn:Say(3350,0025, PADC(AllTrim(SM0->M0_NOMECOM),0400) ,oFont06)
	//oPrn:Say(3375,0025, PADC(AllTrim(SM0->M0_ENDENT)+" - "+AllTrim(SM0->M0_BAIRENT)+" - "+AllTrim(SM0->M0_CIDENT)+Alltrim(SM0->M0_ESTENT),0390) ,oFont06)
	//oPrn:Say(3400,0025, PADC("TEL.: "+AllTrim(SM0->M0_TEL)+" www.coferly.com.br",0400)  ,oFont06)
	
	//oPrn:Say(Linha_FIM+2,Coluna_FIM-195, "BETA TESTE DANFSESP" ,oFont06) 
	
	MS_FLUSH() 

Else
	
	PixelX   := odanfe:nLogPixelX()
	PixelY   := odanfe:nLogPixelY()	
 
	oDanfe:StartPage()     	//--> inicia a página 
	
	// C A B E C A L H O
	nPag++
	
	nLinhaIni  := 0
	nLinhaIni  := Linha_INI - 40  //100
	nColunaIni := 0
	nColunaIni := Coluna_INI / 2
	nColunaFim := 0
	nColunaFim := (Coluna_FIM / 2) - 600    
	nBottom    := (oDanfe:NPAGEHEIGHT /2) - 800     
	oDanfe:Box(nLinhaIni,nColunaIni,nBottom,nColunaFim)	  //--> BOX - Pagina Inteiris      //Box ( [ nRow], [ nCol], [ nBottom], [ nRight], [ uParam5] ) 
	
	nAltura := nLinhaIni + 60	
	oDanfe:Box(nLinhaIni,nColunaIni,nAltura,nColunaFim)	  	//--> BOX - Cabeçalho
	cTexto := "PREFEITURA DO MUNICIPIO DE SÃO PAULO"
	cFont  := "Times New Roman"
	oDanfe:Say(nLinhaIni+15,nColunaIni, PADC(cTexto,65)    ,oFont18N:oFont)
	
	cTexto := "SECRETARIA MUNICIPAL DE FINANCAS"
	oDanfe:Say(nLinhaIni+27,nColunaIni, PADC(cTexto,80),oFont14N:oFont) 
	
	cTexto := "NOTA FISCAL DE SERVICO ELETRONICA NFS-e"
	oDanfe:Say(nLinhaIni+37,nColunaIni, PADC(cTexto,80) ,oFont14N:oFont) 	
	
	nColunaIni := nColunaFim - 100
	oDanfe:Box(nLinhaIni,nColunaIni,nLinhaIni+30,nColunaFim)   //--> BOX - pagina nro nf
	oDanfe:Say(nLinhaIni+8	,nColunaIni+2	,"Numero da Nota:",oFont11:oFont)
	oDanfe:Say(nLinhaIni+17	,nColunaIni+2	,PadC(AllTrim(cDoc),15),oFont12N:oFont)
		
	oDanfe:Box(nLinhaIni+30	,nColunaIni		,nAltura	,nColunaFim)   //--> BOX - pagina data
	oDanfe:Say(nLinhaIni+37	,nColunaIni+2	,"Data:"   	,oFont11:oFont)
	oDanfe:Say(nLinhaIni+47	,nColunaIni+2	,dToc(dEmi),oFont12N:oFont)
	
	nLinhaIni := nAltura
	nAltura   := nLinhaIni + 70
	nColunaIni:= Coluna_INI / 2
	oDanfe:Box(nLinhaIni,nColunaIni,nAltura,nColunaFim)   //--> BOX - Prestador 
	oDanfe:Say(nLinhaIni+14,nColunaIni, PADC("PRESTADOR SERVIÇOS",132) ,oFont12N:oFont) 
		
		nLinBox := (nLinhaIni+14) + 14
		oDanfe:Say(nLinBox,nColunaIni+2, "CPF/CNPJ:",oFont11N:oFont)	
		oDanfe:Say(nLinBox,nColunaIni+80, SA2->A2_CGC,oFont11:oFont)
		
		//nLinBox +=8
		oDanfe:Say(nLinBox,nColunaIni+240, "Inscrição Municipal:",oFont11N:oFont)
		oDanfe:Say(nLinBox,nColunaIni+320, SA2->A2_INSCRM,oFont11:oFont)
		
		nLinBox +=10
		oDanfe:Say(nLinBox,nColunaIni+2, "Nome/Razão Social:",oFont11N:oFont)
		oDanfe:Say(nLinBox,nColunaIni+80, SA2->A2_NOME,oFont11:oFont) 
		
		nLinBox +=10
		oDanfe:Say(nLinBox,nColunaIni+2, "Endereço:",oFont11N:oFont)
		oDanfe:Say(nLinBox,nColunaIni+80, SA2->A2_END,oFont11:oFont)
		
		nLinBox +=10
		oDanfe:Say(nLinBox,nColunaIni+2, "Município:",oFont11N:oFont)
		oDanfe:Say(nLinBox,nColunaIni+80, SA2->A2_MUN,oFont11:oFont) 
		
		//nLinBox +=8
		oDanfe:Say(nLinBox,nColunaIni+240, "UF:",oFont11N:oFont)
		oDanfe:Say(nLinBox,nColunaIni+260, SA2->A2_EST,oFont11:oFont)
	
	
	nLinhaIni := nAltura
	nAltura   := nLinhaIni + 70
	//oDanfe:Box(0650     ,Coluna_INI,0650     ,Coluna_FIM)   //--> BOX - Tomador
	oDanfe:Box(nLinhaIni	,nColunaIni,nAltura,nColunaFim)   //--> BOX - Tomador
	oDanfe:Say(nLinhaIni+14	,nColunaIni, PADC("TOMADOR SERVIÇOS",132) ,oFont12N:oFont)
		
		nLinBox := (nLinhaIni+14) + 14 
		oDanfe:Say(nLinBox,nColunaIni+2, "CPF/CNPJ:",oFont11N:oFont)
		oDanfe:Say(nLinBox,nColunaIni+80, SM0->M0_CGC,oFont11:oFont)
		
		oDanfe:Say(nLinBox,nColunaIni+240, "Inscrição Municipal:",oFont11N:oFont)
		oDanfe:Say(nLinBox,nColunaIni+320, SM0->M0_INSCM,oFont11:oFont)
		
		nLinBox +=10
		oDanfe:Say(nLinBox,nColunaIni+2, "Nome/Razão Social:",oFont11N:oFont)
		oDanfe:Say(nLinBox,nColunaIni+80, SM0->M0_NOMECOM,oFont11:oFont) 
		
		nLinBox +=10
		oDanfe:Say(nLinBox,nColunaIni+2, "Endereço:",oFont11N:oFont)
		oDanfe:Say(nLinBox,nColunaIni+80, SM0->M0_ENDENT,oFont11:oFont) 
		
		nLinBox +=10
		oDanfe:Say(nLinBox,nColunaIni+2, "Município:",oFont11N:oFont)
		oDanfe:Say(nLinBox,nColunaIni+80, SM0->M0_CIDENT,oFont11:oFont) 
		
		oDanfe:Say(nLinBox,nColunaIni+240, "UF:",oFont11N:oFont)
		oDanfe:Say(nLinBox,nColunaIni+260, SM0->M0_ESTENT,oFont11:oFont)
	
	nLinhaIni := nAltura
	nAltura   := nLinhaIni + 280
	oDanfe:Box(nLinhaIni,nColunaIni,nAltura,nColunaFim)   //--> BOX - Discriminaçao
	oDanfe:Say(nLinhaIni+14,nColunaIni, PADC("DISCRIMINAÇÃO DOS SERVIÇOS",132) ,oFont12N:oFont)
		
		nLinBox := (nLinhaIni+14) + 14 
		For nI := 1 To Len( cDescr ) Step 100
			oDanfe:Say(nLinBox,nColunaIni+5, Substr(cDescr,nI,100) ,oFont12:oFont)
			nLinBox += 12
			if nLinBox > 2300
				Exit
			endif
		Next
	
	nLinhaIni := nAltura
	nAltura   := nLinhaIni + 20
	oDanfe:Box(nLinhaIni    ,nColunaIni,nAltura ,nColunaFim)   //--> BOX
	oDanfe:Say(nLinhaIni+12	,nColunaIni, PADC("VALOR TOTAL DA NF/SERVIÇO = R$ "+ Transform(nVrServ,"@E 999,999,999,999.99"),200) ,oFont16N:oFont)
	
	nLinhaIni := nAltura
	nAltura	  := nLinhaIni +30
	//oDanfe:Box(nLinhaIni	,)
	 
	nLinhaIni := nAltura
	nAltura   := nLinhaIni + 30	
	oDanfe:Box(nLinhaIni     ,nColunaIni,nAltura,nColunaFim)   //--> BOX
	oDanfe:Say(nLinhaIni+10,nColunaIni+10, "Código do Serviço" ,oFont12:oFont) 
	oDanfe:Say(nLinhaIni+25,nColunaIni+10, cCodSErv ,oFont12N:oFont)
	
	
	nLinhaIni := nAltura
	nAltura   := nLinhaIni + 40	
	oDanfe:Box(nLinhaIni     	,nColunaIni			,nAltura     ,nColunaFim)   //--> BOX  
		//valor total das deduções
		nColBox := nColunaIni+135
		oDanfe:Box(nLinhaIni    ,nColunaIni		, nAltura							,nColunaIni+135)   	//--> Linha Vertical
		oDanfe:Say(nLinhaIni+10	,nColunaIni+8	, "Valor Total das Deduções (R$)" 					,oFont12:oFont) 
		oDanfe:Say(nLinhaIni+25	,nColunaIni+30	, Transform(nVrDedz,"@E 999,999,999,999.99") 		,oFont12N:oFont)
		
		//base de cálculo R$		
		oDanfe:Box(nLinhaIni    ,nColBox	, nAltura								,nColBox+90)   				//--> Linha Vertical
		oDanfe:Say(nLinhaIni+10	,nColBox+8	, "Base de Cálculo (R$)" 								,oFont12:oFont) 
		oDanfe:Say(nLinhaIni+25	,nColBox+25	, Transform(nVrServ-nVrDedz,"@E 999,999,999,999.99") 	,oFont12N:oFont)
		
		//alíquota %
		nColBox += 90
		oDanfe:Box(nLinhaIni    ,nColBox	, nAltura								,nColBox+60)   			//--> Linha Vertical
		oDanfe:Say(nLinhaIni+10	,nColBox+8	, "Alíquota (%)" 	 									,oFont12:oFont)
		oDanfe:Say(nLinhaIni+25	,nColBox+25	, Transform(nAliq,"@E 999.99") 							,oFont12N:oFont)
		
		//valor do ISS R$
		nColBox += 60
		oDanfe:Box(nLinhaIni	,nColBox	, nAltura								,nColBox+60)   //--> Linha Vertical
		oDanfe:Say(nLinhaIni+10	,nColBox+8	, "Valor do ISS (R$)" 									,oFont12:oFont)  
		oDanfe:Say(nLinhaIni+25	,nColBox+25	, Transform(nVRISS,"@E 999,999,999,999.99") 			,oFont12N:oFont)

		//Valor do ICMS R$ -LUCAS SAN 06/09/2022
		nColBox += 80
		oDanfe:Box(nLinhaIni	,nColBox	, nAltura								,nColunaFim)
		oDanfe:Say(nLinhaIni+10 ,nColBox+8	, "ICMS (R$)"										,oFont12:oFont)
		oDanfe:Say(nLinhaIni+25 ,nColBox+25 , Transform(nICMVAL,"@E 999,999,999,999.99")				,oFont12:oFont)
		
		oDanfe:Say(nLinhaIni+50	,nColunaIni+90	, "OUTRAS INFORMAÇÕES" 								,oFont12N:oFont)
		oDanfe:Say(nLinhaIni+65	,nColunaIni+8	, "- Esta NFS-e foi emitida com respaldo da Lei No. 14.097/2005." ,oFont12:oFont)
			
	oDanfe:EndPage()

Endif  
Return
