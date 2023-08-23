#include "Protheus.ch"
#include "Totvs.ch"
#Include "Parmtype.ch"
//#include "Xmlcsvcs.ch"
#include "Restful.ch"
#include "TbiConn.ch"
#include "xmlxfun.ch"
#include "fileio.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "RPTDEF.CH" 
#INCLUDE 'APWEBSRV.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE "PRTOPDEF.CH"
//#INCLUDE "HTTPCLASS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"

/////////////////////////////////////////////////////////////////////////////////
//  Funcao: HFPDF003  			                           Data: 05/09/2019    //
//  Autor: RogÈrio Rafael Lino			            	   Cliente: HF         //                                     
//  DescriÁ„o: LÍ os arquivos da pasta imagens                                 //
/////////////////////////////////////////////////////////////////////////////////  
//AlteraÁıes realizadas:
//----------------------------------------------------------------------------//
//FR - 05/05/2021 - #10382 - Kroma - tratativa para chamada dentro do Schedule
//----------------------------------------------------------------------------//    
//FR - 07/06/2021 - Rollback das alteraÁıes da Kroma
//----------------------------------------------------------------------------//
User Function HFPDF003(lAuto,lEnd,oProcess,cLogProc,nCount)
 
Processa( {|| GETFILE(lAuto,lEnd,oProcess,cLogProc,nCount) }, "Aguarde...", "Processamento...",.F.)

Return


//LÍ os arquivos da pasta imagens e grava no protheus 
Static Function GETFILE(lAuto,lEnd,oProcess,cLogProc,nCount)	

//Local aFiles    := {}
//Local nTotLen   := 0
//Local cExtensao := "*"
//Local nI        := 0
//Local cFilePDF  := ""

Private cPathx  := AllTrim(GetNewPar("MV_X_PATHX",""))  //Diretorio xml
Private cCnpj   := Alltrim(FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , { "M0_CGC" } )[1][2])
Private cDir    := cPathx + "pdf\" + cCnpj +"\aguardando\"

Conout("Inicio da rotina de conversao de pdf - GETFILE " + TIME() )

//aFiles	:=	Directory(cDir+"*."+cExtensao,"H")
//aSort( aFiles,,,{|x,y| x[1] < y[1] } )
//nTotLen := Len(aFiles)

ProcRegua(1)

HFPDF004( /*aFiles*/ )

Return


/////////////////////////////////////////////////////////////////////////////////
//  Funcao: HFPDF004  			                           Data: 05/09/2019    //
//  Autor: RogÈrio Rafael Lino			            	   Cliente: HF         //                                     
//  DescriÁ„o: Baixa o arquivo conteudo do arquivo pdf e grava em xml.         //
/////////////////////////////////////////////////////////////////////////////////  
Static Function HFPDF004( aFiles )

Local oRestClient := FWRest():New( "https://api.imageconverter.com.br" )
Local lAtualiza := .F.
Local oObjJson	
Local aHeader := {}
Local nX		:= 0

//SplitPath( cPathx + "imagens\" + cCnpj + "\" + cFile, @cDrive, @cDir, @cNome, @cExt ) //10202852000115

oRestClient:setPath( "/api/arquivo/?id=" + cCnpj) //+ "&fileName=" + cFile + "&tipoDoc=NFSE&origin=API" )

//If len(aFiles) > 0

	cUrl  := "https://api.imageconverter.com.br"
	//cUrl  := "https://devapi.imageconverter.com.br:443"
	cPath := "/api/arquivo/?id=" + cCnpj + "&tipoDoc=NFSE&origin=API"            //+ "&fileName=" + noCarac(noAcento(cFile))
	
	Aadd(aHeader, "Content-Type: application/json")   

	//cBody := '{'
	//cBody += 'tipoDoc: "NFSE",'
	//cBody += 'origin: "API",'
	//cBody += 'arquivos: ['

//	For nX := 1 to Len(aFiles)

//		cFile := aFiles[nX,1]

//		IncProc( "Processando arquivo: " + cFile )
//		oRestClient := FWRest():New( cUrl )

//		oRestClient:SetPath( cPath )


//		cBody += '"'+cFile+Iif(nX<Len(aFiles),'",','"]')

//	Next
	
//	cBody += '}'

//	oRestClient:SetPostParams(cBody)

	oRestClient := FWRest():New( cUrl )
	oRestClient:nTimeout := 20
	oRestClient:SetPath( cPath )

	If oRestClient:Get(aHeader)

		If !FWJsonDeserialize(oRestClient:GetResult(), @oObjJson)
			MsgStop("Ocorreu erro no processamento do Json")
			Return Nil
		EndIf

		For nX := 1 to Len(oObjJson)	
			If ValType(oObjJson[nX]:ID) == "C"
				IF .Not. Empty(ValType(oObjJson[nX]:CONTENT)) 
					GravaXml( oObjJson[nX]:FILENAME,oObjJson[nX]:CONTENT )
					lAtualiza := .T.
					fErase( cPathx + "pdf\" + cCnpj + "\Aguardando\" + oObjJson[nX]:ID )
				EndIf
			EndIf		
		Next

		if lAtualiza

			//Atualiza status no metodo get para concluido
			AtualizaStatus( oObjJson )

		endif

	Else

		Conout("Falha no momento de conectar a API: " + oRestClient:GetLastError() + "HFPOSTFILE")
		
	Endif

//EndIf
// primeiro limpa a propriedade
oRestClient := NIL
	  
// agora sim limpa o objeto ou , limpa a instancia usando freeobj()
FreeObj(oRestClient)  //FWFreeVar(@oFile)

Conout("Fim da rotina de conversao de pdf - GETFILE " + TIME() )

Return


/////////////////////////////////////////////////////////////////////////////////
//  Funcao: GravaXml 			                           Data: 05/09/2019    //
//  Autor: RogÈrio Rafael Lino			            	   Cliente: HF         //                                     
//  DescriÁ„o: Grava o conteudo do arquivo baixado atravÈs do metodo get.      //
/////////////////////////////////////////////////////////////////////////////////  
Static Function GravaXml(cFile,cConteudo)

//Local cArq := cFile
Local cVal := cConteudo
Local cError   := ""
Local cWarning := ""
Local cDir := cPathx + "imagens\" + cCnpj + "\xml\"

Private oXml := XmlParser( cConteudo, "_", @cError, @cWarning )

if Existdir( cDir )

	SAVE oXml XMLSTRING cVal
			
	GraZbzNfs( oXml, cVal ) //if !MemoWrite( cDir + cArq , cVal )
	
	//	Conout( "ERROR: " + FError() )
	
else

	MakeDir( cDir )
	
	SAVE oXml XMLSTRING cVal
	
	GraZbzNfs( oXml, cVal ) //if !MemoWrite( cDir + cArq , cVal )
	
	//	Conout( "ERROR: " + FError() )
	
endif

Return


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ GraZbzNfs∫Autor  ≥ Eneo               ∫ Data ≥ 20/04/2016  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Gravar na Tabela ZBZ o arquivo como se fosse um XML.       ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Importa XML                                                ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function GraZbzNfs( oXml, cVal )

Local cChaveXml := ""
//Local nI        := 1
Local lAppend   := .T.
//Local cNomFil   := ""
Local cCodEmit  := ""
Local cLojaEmit := ""
Local cRazao    := ""
Local cNota     := ""
Local cDtEmi    := ""
Local dDtEmi	:= stod("")
Local cUf       := ""
Local cVlServ   := ""
Local nVlServ   := 0
Local cCNPJ     := ""
Local cCNPJD    := ""

Private nFormNfe := Val(GetNewPar("XM_FORMNFE","9"))
Private cFilNova := xFilial()
Private xZBZ  	 := GetNewPar("XM_TABXML","ZBZ")
Private xZBZ_ 	 := iif(Substr(xZBZ,1,1)=="S", Substr(xZBZ,2,2), Substr(xZBZ,1,3)) + "_"

cFilXMLAtu := cFilAnt

If oXml <> NIL

	DbSelectArea( xZBZ )
	dbSetORder(3)

	//Verifica se a tag do nota veio preenchida
	cTagAux := "OXML:_NFSETXT:_INFPROC:_NNOTA:TEXT"   //Nota

	If Type( cTagAux ) <> "U"

		cNota := &cTagAux

	Endif

	//Verifica se a tag do Data Emissao veio preenchida
	cTagAux := "OXML:_NFSETXT:_INFPROC:_DEMI:TEXT"         //Emiss„o

	If Type( cTagAux ) <> "U"
		
		cDtEmi := &cTagAux
		dDtEmi := stod(substr(cDtEmi,7,4)+substr(cDtEmi,4,2)+substr(cDtEmi,1,2))
		
	Endif

	//Verifica se a tag do cnpj veio preenchida
	cTagAux := "OXML:_NFSETXT:_INFPROC:_CNPJPREST:TEXT"         //CNPJ Prestador

	If Type( cTagAux ) <> "U"

		cCNPJ := &cTagAux
		cCNPJ := strTran(cCNPJ,".","")
		cCNPJ := strTran(cCNPJ,"/","")
		cCNPJ := strTran(cCNPJ,"-","")

	Endif

	//Chave
	cChaveXml := dtos(dDtEmi)+cCNPJ+StrZero(Val(cNota),nFormNfe)
	cChaveXml := cChaveXml + Replicate("0",44-len(cChaveXml))

	lAppend := .NOT. dbSeek(cChaveXml)

	If lAppend                              
			
		//Grava ZBZ cabeÁalho
		Reclock(xZBZ,lAppend)
		
		(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CHAVE"), cChaveXml))  //Colocado no Ìnicio para evitar a Fadiga
		(xZBZ)->(FieldPut(FieldPos(xZBZ_+"FILIAL"), cFilAnt))
					
		(xZBZ)->(FieldPut(FieldPos(xZBZ_+"MODELO"), "RP" ))
		(xZBZ)->(FieldPut(FieldPos(xZBZ_+"STATUS"), "1"))
		(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PRENF"), "B" ))
		
		//Verifica se a tag do nota veio preenchida
		cTagAux := "OXML:_NFSETXT:_INFPROC:_NNOTA:TEXT"   //Nota

		If Type( cTagAux ) <> "U"
	
			cNota := &cTagAux
			
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"NOTA"), U_NumNota(cNota,nFormNfe) ))
	
		Endif
							
		//Verifica se a tag do Data Emissao veio preenchida
		cTagAux := "OXML:_NFSETXT:_INFPROC:_DEMI:TEXT"         //Emiss„o

		If Type( cTagAux ) <> "U"
		
			cDtEmi := &cTagAux
			dDtEmi := stod(substr(cDtEmi,7,4)+substr(cDtEmi,4,2)+substr(cDtEmi,1,2))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"DTNFE"), dDtEmi ))
		
		Endif
	
		(xZBZ)->(FieldPut(FieldPos(xZBZ_+"SERORI"), "" ))
		(xZBZ)->(FieldPut(FieldPos(xZBZ_+"SERIE"), U_vSerie( "", cFilAnt, .F. ) ))
				
		//Verifica se a tag do UF veio preenchida
		cTagAux := "OXML:_NFSETXT:_INFPROC:_UFPREST:TEXT"         //UF

		If Type( cTagAux ) <> "U"
	
			cUF := &cTagAux
			
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"UF"), cUF ))
	
		Endif
		
		//Verifica se a tag do Valor do ServiÁo veio preenchida
		cTagAux := "OXML:_NFSETXT:_INFPROC:_VRSERV:TEXT"         //Valor

		If Type( cTagAux ) <> "U"
	
			cVlServ := &cTagAux
			cVlServ := StrTran(cVlServ,"R$","")
			cVlServ := StrTran(cVlServ,".","")
			cVlServ := StrTran(cVlServ,",",".")		
			nVlServ := round(Val(alltrim(cVlServ)),2)

			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"VLBRUT"),nVlServ ))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"VLLIQ"), nVlServ ))
	
		Endif
				
		(xZBZ)->(FieldPut(FieldPos(xZBZ_+"DTRECB"), dDataBase))
		(xZBZ)->(FieldPut(FieldPos(xZBZ_+"XML"), cVal))
		
		//Verifica se a tag do cnpj veio preenchida
		cTagAux := "OXML:_NFSETXT:_INFPROC:_CNPJPREST:TEXT"         //CNPJ Prestador

		If Type( cTagAux ) <> "U"
	
			cCNPJ := &cTagAux
			cCNPJ := strTran(cCNPJ,".","")
			cCNPJ := strTran(cCNPJ,"/","")
			cCNPJ := strTran(cCNPJ,"-","")

			VerFor(cCNPJ,@cCodEmit,@cLojaEmit,@cRazao)
				
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CNPJ"), cCNPJ))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"FORNEC"), cRazao))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CODFOR"), cCodEmit))		
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"LOJFOR"), cLojaEmit))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPDOC"), "N" ))
	
		Endif

		//Verifica se a tag do cnpj veio preenchida
		cTagAux := "OXML:_NFSETXT:_INFPROC:_CNPJTOMA:TEXT"         //CNPJ

		If Type( cTagAux ) <> "U"
	
			cCNPJD := &cTagAux
			cCNPJD := strTran(cCNPJD,".","")
			cCNPJD := strTran(cCNPJD,"/","")
			cCNPJD := strTran(cCNPJD,"-","")	

			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CNPJD"), cCNPJD))
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CLIENT"), Alltrim( FwFilialName() )))
	
		Endif
		
		If (xZBZ)->(FieldPos(xZBZ_+"FORPAG"))>0    //GETESB
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"FORPAG"), "1" ))
		EndIF
		
 		If (xZBZ)->(FieldPos(xZBZ_+"MAIL"))>0
	   		(xZBZ)->(FieldPut(FieldPos(xZBZ_+"MAIL"), "0"))
//		   		(xZBZ)->(FieldPut(FieldPos(xZBZ_+"DTMAIL"), cInfoErro))	   		
		EndIf
		
		if (xZBZ)->(FieldPos(xZBZ_+"PDF"))>0 
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PDF"), "S"))
		endif

		(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CHAVE"), cChaveXml))

		DbSelectArea(xZBZ)
		MsUnLock()

		//FR - 27/11/2020
		//===================//
		// Grava ZBT:        //
		//===================//
		cModelo   := "RP"			
		cCnpjEmi  := cCnpj		//CNPJ do Emitente	
		U_fGravaZBT(cVal,cModelo,cChaveXml,cNota,"" /*cSeriNF*/ ,cCnpjEmi) //NF ServiÁo n„o tem sÈrie (?)			
		//FR - 27/11/2020
		
		Conout("PDF convertido baixado com sucesso")
			
	EndIf
	
	cKeyXml := cChaveXml
	cFilAnt := cFilXMLAtu
	
endif

Return( NIL )


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥  VerFor  ∫Autor  ≥ Eneo               ∫ Data ≥ 02/05/2016  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Verificar cÛdigo do fornecedor.                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Importa XML                                                ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function VerFor(cCnpjEmi,cCodEmit,cLojaEmit,cRazao)

Local aArea     := GetArea()

DbSelectArea("SA2")
DbSetOrder(3)
If DbSeek( xFilial("SA2") + cCnpjEmi )

	cCodEmit  := SA2->A2_COD
	cLojaEmit := SA2->A2_LOJA
	cRazao    := SA2->A2_NOME
	
	Do While .not. SA2->( eof() ) .and. SA2->A2_FILIAL == xFilial("SA2") .and.;
	               SA2->A2_CGC == cCnpjEmi
	               
		if SA2->A2_MSBLQL != "1"
		
			cCodEmit  := SA2->A2_COD
			cLojaEmit := SA2->A2_LOJA
		    cRazao    := SA2->A2_NOME
		    
			exit
			
		endif
			
		SA2->( dbSkip() )
			
	EndDo
		
Else
	
	cCodEmit  := ""
	cLojaEmit := ""
	cRazao    := ""		    	
		
EndIf

RestArea( aArea )

Return( .T. )


/////////////////////////////////////////////////////////////////////////////////
//  Funcao: HFPDF002  			                           Data: 05/09/2019    //
//  Autor: RogÈrio Rafael Lino			            	   Cliente: HF         //                                     
//  DescriÁ„o: Chama a rotina para enviar pdf para o servidor da HF            //
/////////////////////////////////////////////////////////////////////////////////  
User Function HFPDF002(lAuto,lEnd,oProcess,cLogProc,nCount)
 
Processa( {|| POSTFILE(lAuto,lEnd,oProcess,cLogProc,nCount) }, "Aguarde...", "Processamento...",.F.)

Return


//Chama a rotina para enviar pdf para o servidor da HF
Static Function POSTFILE(lAuto,lEnd,oProcess,cLogProc,nCount)	

Local aFilesAll	:= {}
Local aFilesNfse:= {}
Local aFilesNfsc:= {}
Local nTotLen   := 0
Local cExtensao := "pdf"
Local cPathx    := AllTrim(GetNewPar("MV_X_PATHX",""))  //Diretorio xml
Local cGravaPdf := AllTrim(GetNewPar("XM_GRVNFSE","N"))
Local cDir    := cPathx + "PDF\" 

Private cCnpj   := Alltrim(FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , { "M0_CGC" } )[1][2])

Conout("Inicio da rotina de conversao de pdf - HFPOSTFILE " + TIME() )

cDirNfse	:= cDir + "NFSE" + "\"  
cDirNfsc	:= cDir + "NFSC" + "\"
//Verifica se tem a pasta criada dentro do xmlsource
if Existdir( cDir )

 	Conout( "Diretorio ja criado - HFPOSTFILE" )
	
else

	MakeDir( cDir )
	
	Conout( "Diretorio criado com sucesso - HFPOSTFILE" )
	
endif

if Existdir( cDir + "Enviados\")

 	Conout( "Diretorio ja criado - HFPOSTFILE" )
	
elseif cGravaPdf == "S"

	MakeDir( cDir + "Enviados\" )
	
	Conout( "Diretorio criado com sucesso - HFPOSTFILE" )
	
endif

//Verifica se tem a pasta criada dentro do xmlsource NFSC
if Existdir( cDirNfse )

 	Conout( "Diretorio ja criado - HFPOSTFILE" )
	
elseif cGravaPdf == "S"

	MakeDir( cDirNfse )
	
	Conout( "Diretorio criado com sucesso - HFPOSTFILE" )
	
endif

//Verifica se tem a pasta criada dentro do xmlsource NFSC
if Existdir( cDirNfsc )

 	Conout( "Diretorio ja criado - HFPOSTFILE" )
	
elseif cGravaPdf == "S"

	MakeDir( cDirNfsc )
	
	Conout( "Diretorio criado com sucesso - HFPOSTFILE" )
	
endif

aFilesAll	:= Directory(cDir+"*."+cExtensao,"D")
aFilesNfse	:= Directory(cDirNfse+"*."+cExtensao,"D")
aFilesNfsc	:= Directory(cDirNfsc+"*."+cExtensao,"D")

aSort( aFilesAll,,,{|x,y| x[1] < y[1] } )
aSort( aFilesNfse,,,{|x,y| x[1] < y[1] } )
aSort( aFilesNfsc,,,{|x,y| x[1] < y[1] } )

nTotLen := Len(aFilesAll) + Len(aFilesNfse) + Len(aFilesNfsc)

ProcRegua(nTotLen)

HFPDF001( aFilesAll	, "0" , cDir		)
HFPDF001( aFilesNfse, "1" , cDirNfse	)
HFPDF001( aFilesNfsc, "2" , cDirNfsc	)

Return


/////////////////////////////////////////////////////////////////////////////////
//  Funcao: HFPDF001  			                           Data: 05/09/2019    //
//  Autor: RogÈrio Rafael Lino			            	   Cliente: HF         //                                     
//  DescriÁ„o: Rotina que envia o pdf para o servidor da HF                    //
/////////////////////////////////////////////////////////////////////////////////  
Static Function HFPDF001(aFiles,cTipo,cDir)

Local cUrl 			:= ""
Local cPath 		:= ""
//Local cPathx  		:= AllTrim(GetNewPar("MV_X_PATHX",""))  //Diretorio xml
Local aRet			:= {}
Local oObjJson		:= Nil
//Local nH			:= Nil
Local nX			:= 0
Local cBody			:= ""
Local oRestClient 	:= Nil
Local aHeader 		:= {}
Local cGravaPdf     := AllTrim(GetNewPar("XM_GRVNFSE","N"))
Local aSaves        := {}
Local nQuantPdf     := GetNewPar("XM_QTDNFSE",25)
Local cMeioNfse		:= AllTrim(GetNewPar("XM_MEINFS","2"))
Local lEnviou		:= .F.

Private xZBD  	:= GetNewPar("XM_TABIMC" ,"ZBD")
Private xZBD_ 	:= iif(Substr(xZBD,1,1)=="S", Substr(xZBD,2,2), Substr(xZBD,1,3)) + "_"

dbSelectArea(xZBD)
(xZBD)->(dbSetOrder(1))
(xZBD)->(dbGoTop())

Aadd(aHeader, "Content-Type: application/json")   

If len(aFiles) > 0

	cUrl  := "https://api.imageconverter.com.br"
	//cUrl  := "https://devapi.imageconverter.com.br:443"
	cPath := "/api/arquivo/?id=" + cCnpj

	If cMeioNfse == "2"
		cPath += +"&token=KSDbs25622345455"
	EndIf	
	
	oRestClient := FWRest():New( cUrl )
	oRestClient:SetPath( cPath )
	cBody := '{'
	Do Case
		Case cTipo == "1" 
			cBody += '"tipoDoc": "NFSE",'
		Case cTipo == "2"
			cBody += '"tipoDoc": "NFSEC",'
		OtherWise
			cBody += '"tipoDoc": "ALL",'
	EndCase
	cBody += '"origin": "API",'
	cBody += '"arquivos" :['

	If len(aFiles) <= 0
		cBody := ']'
	Else

		If len(aFiles) <= nQuantPdf
			nQuantPdf := len(aFiles)
		EndIf	
		
		For nX := 1 to nQuantPdf

			cFilePDF := noCarac(noAcento(alltrim(aFiles[nX,1]))) 

			fRename(cDir + aFiles[nX,1], cDir + cFilePDF)
			IncProc( "Processando arquivo: " + cFilePDF )
		
			(xZBD)->(dbgoTop())
			While !(xZBD)->(EOF())
				If cFilePDF == alltrim((xZBD)->(FieldGet(FieldPos(xZBD_+"ARQUIV")))); 
					.AND. alltrim((xZBD)->(FieldGet(FieldPos(xZBD_+"TAM")))) == cValtoChar(aFiles[nX,2])
					lEnviou := .T.
				EndIf
				(xZBD)->(dbSkip())
			End	

			If !lEnviou
				If cMeioNfse == "1"
					aRet := AtuFtp(cDir , cFilePDF, cCnpj)
				Else
					aRet := {.T.,"Upload API"}
				EndIf

				If aRet[1]
					RecLock(xZBD,.T.)
						(xZBD)->(FieldPut(FieldPos(xZBD_+"FILIAL")	, /*xFilial(xZBD)*/ " " ))
						(xZBD)->(FieldPut(FieldPos(xZBD_+"ARQUIV")	, cFilePDF ))
						(xZBD)->(FieldPut(FieldPos(xZBD_+"STATUS")	, "UPLOAD" ))
						(xZBD)->(FieldPut(FieldPos(xZBD_+"LOG")		, aRet[2] ))
						(xZBD)->(FieldPut(FieldPos(xZBD_+"TAM")		, cValtoChar(aFiles[nX,2]) ))
					(xZBD)->(MsUnlock())

					If cMeioNfse == "1"
						cBody += '"'+cFilePDF+Iif(nX<nQuantPdf,'",','"]')
					Else
						cBody += '{"name":'+'"'+cFilePDF+'",'
						//cBody += '"content":'+'"'+encode64(,cDir + cFilePDF,.F.,.F.)+'"}'
						cBody += '"content":'+'"'+cValToChar(encode64(,cDir + cFilePDF,.F.,.F.))+'"}' //LUCAS SAN -> 15/03/2023 CorreÁ„o envio PDF para o Image
						cBody += Iif(nX<nQuantPdf,',',']')					
					EndIf

					If cGravaPdf == "S"
						fRename(cDir + cFilePDF,cDir + "Enviados\" + cFilePDF)
						aAdd(aSaves,{cFilePDF,""})
					Else
						fErase( cDir + cFilePDF)
					EndIf

				EndIf
			Else
				cBody += Iif(nX==nQuantPdf,']',"")
				RecLock(xZBD,.T.)
					(xZBD)->(FieldPut(FieldPos(xZBD_+"FILIAL")	, /*xFilial(xZBD)*/ " " ))
					(xZBD)->(FieldPut(FieldPos(xZBD_+"ARQUIV")	, cFilePDF ))
					(xZBD)->(FieldPut(FieldPos(xZBD_+"STATUS")	, "UPLOAD" ))
					(xZBD)->(FieldPut(FieldPos(xZBD_+"LOG")		, "Arquivo enviado anteriormente" ))
					(xZBD)->(FieldPut(FieldPos(xZBD_+"TAM")		, cValtoChar(aFiles[nX,2]) ))
				(xZBD)->(MsUnlock())

				If cGravaPdf == "S"
					fRename(cDir + cFilePDF,cDir + "Enviados\" + cFilePDF)
					aAdd(aSaves,{cFilePDF,""})
				Else
					fErase( cDir + cFilePDF)
				EndIf

			EndIf

			lEnviou := .F.
		Next
	
	EndIf
	
	cBody += '}'

	oRestClient:SetPostParams(cBody)

	If oRestClient:Post( aHeader )

		If !FWJsonDeserialize(oRestClient:GetResult(), @oObjJson)
			MsgStop("Ocorreu erro no processamento do Json")
			Return Nil
		EndIf

		if Type("oObjJson") <> "U"

			For nX := 1 to Len(oObjJson)

				nPosFile := aScan(aSaves,{|x| x[1] == oObjJson[nX]:FILENAME})
				
				If nPosFile > 0
					aSaves[nPosFile,2] := oObjJson[nX]:ID
				EndIf
				If ValType(oObjJson[nX]:ID) == "C"

					If !dbSeek(xFilial(xZBD)+padr(oObjJson[nX]:ID,TamSX3(xZBD_+"ID")[1]))

						RecLock(xZBD,.T.)
							(xZBD)->(FieldPut(FieldPos(xZBD_+"FILIAL")	, /*xFilial(xZBD)*/ " " 									))
							(xZBD)->(FieldPut(FieldPos(xZBD_+"ID")		, oObjJson[nX]:ID 											))
							(xZBD)->(FieldPut(FieldPos(xZBD_+"ARQUIV")	, oObjJson[nX]:FILENAME 									))
							(xZBD)->(FieldPut(FieldPos(xZBD_+"STATUS")	, oObjJson[nX]:STATUS 										))
							(xZBD)->(FieldPut(FieldPos(xZBD_+"LOG")		, DecodeUtf8(oObjJson[nX]:LOG) 								))
							(xZBD)->(FieldPut(FieldPos(xZBD_+"DATADO")	, oObjJson[nX]:DATADOWNLOAD									))
							(xZBD)->(FieldPut(FieldPos(xZBD_+"DATAIN")	, oObjJson[nX]:DATACONVERSAO								))
							(xZBD)->(FieldPut(FieldPos(xZBD_+"DATAUP")	, oObjJson[nX]:DATAUPLOAD									))
							(xZBD)->(FieldPut(FieldPos(xZBD_+"PDFON")	, oObjJson[nX]:STATUSPDF									))		
						(xZBD)->(MsUnlock())

					EndIf
					
					/*
					if Existdir( cPathx + "pdf\" + cCnpj +"\aguardando")
						nH := fCreate( cPathx + "pdf\" + cCnpj +"\aguardando\"+oObjJson[nX]:ID)
						fClose(nH)
					else
						MakeDir( GetSrvProfString ("ROOTPATH","") + cPathx + "pdf\" + cCnpj +"\aguardando")
						nH := fCreate( cPathx + "pdf\" + cCnpj +"\aguardando\"+oObjJson[nX]:ID)
						fClose(nH)			
					endIf
					*/	
				EndIf		

			Next nX

		endif 

		For nX := 1 to Len(aSaves)
			fRename(cDir + "Enviados\" + aSaves[nX,1],cDir + "Enviados\" + aSaves[nX,2]+".pdf")
		Next

	Else

 		Conout("DiretÛrio vazio "+ "HFPOSTFILE")	

	Endif

EndIf

// primeiro limpa a propriedade
oRestClient := NIL
	
// agora sim limpa o objeto ou , limpa a instancia usando freeobj()
FreeObj(oRestClient)  //FWFreeVar(@oFile)

Conout("Fim da rotina de conversao de pdf - HFPOSTFILE " + TIME() )

Return nil


Static Function VerEspacos( cPdf )

Local cRet := cPdf

cRet := StrTran( cRet, "   ", "")
cRet := StrTran( cRet, "  ", "")
cRet := StrTran( cRet, " ", "")

If cRet <> cPdf .And. File(cDir+cPdf)
	__CopyFile( cDir+cPdf, cDir+cRet ) //Copia o Pdf para o smartclient
	FErase(cDir+cPdf)
EndIf

Return( cRet )


Static Function ShowResult(cValue)

if IsBlind()

	Conout(cValue)
	
else

	MsgInfo(cValue)
	
endif

Return nil



User Function HFXML14()

    Local aPergs   := {}
    Local cArquivo := padr("",150)
    Local aRet	   := {}
    Local cDrive, cDir, cNome, cExt
    Local cCnpj    := SM0->M0_CGC
    Local cPathx   := AllTrim(GetNewPar("MV_X_PATHX",""))  //Diretorio xml

    aAdd( aPergs ,{6,"Buscar arquivo",cArquivo,"",,"", 90 ,.T.,"Arquivos .PDF |*.PDF",'C:\',GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE})

    If ParamBox(aPergs ,"Informe o parametro",aRet)
    
    	SplitPath( Alltrim( aRet[1] ), @cDrive, @cDir, @cNome, @cExt )
    	
    	if Existdir( cPathx + "PDF\" + cCnpj  )
        
	        CpyT2S( Alltrim( aRet[1] ), cPathx + "PDF\" + cCnpj )	       
	        
	     else
	     
	     	MakeDir( cPathx + "PDF\" + cCnpj  )
	     	
	     	CpyT2S( Alltrim( aRet[1] ), cPathx + "PDF\" + cCnpj )	 
	     
	     endif
	     
	     Msginfo("Arquivo enviado ao diretÛrio com sucesso")
        
    Else
    
        Aviso("Processo cancelado")
        
    EndIf
    
Return .T.


/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥HFXMLFIS  ∫ Autor ≥ Rogerio Lino ∫ Data ≥  31/01/20   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Chamada para importaÁ„o de informaÁıes Fiscais de arquivo  ∫±±
±±∫          ≥ XML de Fornecedores.                                       ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ IMPORTA XML                                                ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/

User Function GRAVAXML()

Local oProcess := nil

oProcess := MsNewProcess():New({|lEnd| EXCPROC(@oProcess) },"Aguarde...","Analizando Arquivos XML",.T.)
oProcess:Activate()

Return


Static Function EXCPROC( oProcess )

//Local nRec     := 0
Local cError   := ""
Local cWarning := ""
Local aFiles   := {} 
Local oXml   
Local nX		:= 0

aFiles := Directory( GetSrvProfString ("ROOTPATH","") + "\xmlsource\importados\nferes\*.*", "D" )

nTotLen := Len( aFiles )

oProcess:SetRegua2( nTotLen )

For nX := 1 to nTotLen
	
	oProcess:IncRegua2( "Arquivo xml: " + aFiles[nX,1] )
		
	oXml := XmlParserFile( aFiles[nX,1], "_", @cError, @cWarning )
	
	If (oXml == NIL )
	
		MsgStop("Falha ao gerar Objeto XML : "+cError+" / "+cWarning)
		Return
		
	Endif
	
	Alert("Entrei no looping de notas")

Next Nx

Return()


WSRESTFUL WEB_PDF DESCRIPTION "Envio de PDF" FORMAT APPLICATION_JSON

WSDATA empresa AS INTEGER OPTIONAL
WSDATA anexo AS CHARACTER OPTIONAL

WSMETHOD POST POSTANEXO DESCRIPTION "Envio de PDF" WSSYNTAX "/WEB_PDF || /WEB_PDF/{id}"

END WSRESTFUL

WSMETHOD POST POSTANEXO WSRECEIVE empresa, anexo WSSERVICE WEB_PDF

   //Local _arecno 		:= Self:arecno
   Local _empresa		:= Self:empresa
   Local _anexo		    := Self:anexo
//   Local aArea    		:= GetArea()
   Local cJson   		:= Nil
   Local nPosRec		:= 0
//   Local nPosBarra		:= 0
   Local _subanexo		:= ""
//   Local cRetorno 	    := JsonObject():new()
   Local cFile          := ""
   Local oFile          := ""
   Local cBody 		    := ::GetContent()
   
   FWJsonDeserialize(cBody, @cJson)
   
   //para acessar os dados
   _empresa := cJson:var1
   _anexo	:= cJson:var2
    
	::SetContentType("application/json")
	
	RESET ENVIRONMENT
	
	RPCSetType(3)
	
	PREPARE ENVIRONMENT EMPRESA _empresa FILIAL "01"
	
	oFile := FwFileReader():New(_anexo)
	
	If (oFile:Open())
	
		cFile := oFile:FullRead() // EFETUA A LEITURA DO ARQUIVO
		nPosRec := RAT("\", _anexo)
		_subanexo := substr(_anexo,nPosRec+1, len(_anexo)-nPosRec)
		::SetHeader("Content-Disposition", "attachment; filename="+_subanexo)
		::SetResponse(cFile)
		lSuccess := .T. // CONTROLE DE SUCESSO DA REQUISI«√O
		
	Else
	
		SetRestFault(002, "can't load file") // GERA MENSAGEM DE ERRO CUSTOMIZADA
		lSuccess := .F. // CONTROLE DE SUCESSO DA REQUISI«√O
		
	EndIf
	
Return(.T.)
 
  
User Function xPostfile()  //U_POSTFILE()

    Local cUrl      := "http://converter.hfconsulting.com.br/api/dados/post/"
    Local nTimeOut  := 120
    Local aHeadOut  := {}
    Local cHeadRet  := ""
    Local sPostRet  := ""
    //Local nTamArq   := LeArquivo(GetSrvProfString ("ROOTPATH","") + "\NF_222_MVP.pdf")
    
    aadd(aHeadOut,'User-Agent: Mozilla/4.0 (compatible; Protheus ' + GetBuild() + ')')  
    aadd(aHeadOut,'Cache-Control:private, max-age=0, must-revalidate')
    aadd(aHeadOut,'Connection:keep-alive')
    aadd(aHeadOut,'Content-Type: multipart/form-data')
    aadd(aHeadOut,'Content-Disposition: form-data; filename="NF_222_MVP.pdf"')
    aadd(aHeadOut,'Content-Encoding: application/zip')
    cPostParms := 'Content-Disposition: form-data; name="NF_222_MVP.pdf"; filename="\NF_222_MVP.pdf" ' + CRLF     //Envio de Arquivo especificando o Content-Type
    cPostParms += 'Content-Type: application/pdf' + CRLF
    
    cUrl += "?filename=NF_222_MVP.pdf"                                                                     //Conte√∫do do Parametro
       
    sPostRet := HttpPost(cUrl,"",cPostParms,nTimeOut,aHeadOut,@cHeadRet)

    if !Empty(sPostRet)
    	conout("HttpPost Ok ")
        varinfo("WebPage", sPostRet)
    else
        conout("HttpPost Failed.")
        varinfo("Header", cHeadRet)
    endif
    
Return()


Static Function LeArquivo(cFile)

Local oFile
Local nBytes

oFile := FWFileReader():New(cFile)

nBytes := oFile:getFileSize()

Return(nBytes)


User Function tstCpost()

  Local cUrl      := "http://converter.hfconsulting.com.br/api/dados/post/"
  Local cPostPar  := ""
  Local nTimeOut  := 2 //Segundos
  Local aHeaderStr:= {}
  Local cHeaderRet:= ""
  Local cResponse := ""
  Local cErro     := ""
  
  cPostPar := 'Content-Disposition: form-data; name="NF_222_MVP"; filename="\NF_222_MVP.pdf" ' + CRLF     //Envio de Arquivo especificando o Content-Type
  cPostPar += 'Content-Type: application/pdf;' + CRLF

  aAdd(aHeaderStr,"Content-Type| application/pdf")
  aAdd(aHeaderStr,"Content-Length| " + Alltrim(Str(Len(cPostPar))) )
  
  cUrl += "?filename=NF_222_MVP.pdf"     
  
  cResponse := HttpCPost( cUrl , cPostPar , nTimeOut , aHeaderStr , @cHeaderRet )
  
  VarInfo("Header:", cHeaderRet )
  VarInfo("Retorno:", cResponse )
  VarInfo("Erro:", HTTPGetStatus(cErro) )
  VarInfo("Erro:", cErro )
  
Return


////////////////////
// Envia para FTP //
////////////////////

Static Function AtuFtp(cCaminho,cArquivo,cCnpj)

Local cServer 	:= "159.89.89.91"	//GetMV("MV_XFTPSER")
Local nPorta  	:= 21 					//GetMV("MV_XFTPPOR")
Local cUser	  	:= "hfbr"				//GetMV("MV_XFTPUSR")
Local cPass		:= "axtWcq@D69"			//GetMV("MV_XFTPPSW")
Local cMensagem	:= ""
Local lRet		:= .F.
Local cDir		:= "/ImageConvert/arquivos/"+cCnpj
Local nStatCon	:= 0
Local nStatDir	:= 0
Local nHandle   := 0

oFtp := TFtpClient():New()

nStatCon := oFtp:FTPConnect( cServer, nPorta, cUser, cPass )

//Usa metodo novo para criaÁ„o de pasta
If !(nStatCon <> 0)

	cMensagem += 'FTP Conectado!'+CHR(13)+CHR(10)   

	nStatDir := oFtp:MkDir(cDir)

	If !(nStatDir <> 0) 	
		cMensagem += 'Pasta criada Ok '+cDir+CHR(13)+CHR(10)
	else
		cMensagem += 'Falha ao criar pasta '+ cValToChar(nStatDir) + " - " + oFtp:GetLastResponse() + cDir+CHR(13)+CHR(10)		
	EndIf
	
	oFtp:Close()

Else

	cMensagem := 'Falha de conexao com FTP '+cValToChar(nStatCon)+ " - " + oFtp:GetLastResponse() + CHR(13)+CHR(10)
	cMensagem += 'FTP: '+cServer+CHR(13)+CHR(10) 	
	cMensagem += 'Porta: '+cValToChar(nPorta)+CHR(13)+CHR(10)
	cMensagem += 'Usuario: '+cUser+CHR(13)+CHR(10)
	cMensagem += 'Senha: '+cPass+CHR(13)+CHR(10)

EndIf                         

FTPDisconnect() 
//Usa metodo antigo para envio
If FTPConnect( cServer, nPorta, cUser, cPass )

	cMensagem += 'FTP Conectado!'+CHR(13)+CHR(10)   

	nHandle := fOpen( cCaminho+cArquivo )

	if nHandle <> -1

		fClose( nHandle )
	               
		If FTPUpLoad( cCaminho+cArquivo, cDir+"/"+cArquivo)
			cMensagem += 'UpLoad Ok '+cCaminho+cArquivo+" para "+cDir+"/"+cArquivo+CHR(13)+CHR(10)
			lRet := .T.
		Else	                
			cMensagem += 'Falha UpLoad '+cCaminho+cArquivo+" para "+cDir+"/"+cArquivo+CHR(13)+CHR(10)
		EndIf       

		FTPDisconnect()

	else

		Conout('Arquivo em aberto: '+cArquivo+' : FERROR ' + Str(fError(), 4))

		fClose( nHandle )

	endif

Else

	cMensagem := 'Falha de conexao com FTP'+CHR(13)+CHR(10)
	cMensagem += 'FTP: '+cServer+CHR(13)+CHR(10) 		
	cMensagem += 'Porta: '+cValToChar(nPorta)+CHR(13)+CHR(10)
	cMensagem += 'Usuario: '+cUser+CHR(13)+CHR(10)
	cMensagem += 'Senha: '+cPass+CHR(13)+CHR(10)

EndIf                         

Return ({lRet,cMensagem})


Static Function noCarac(cArquivo)

Local cRetorno := cArquivo

cRetorno := strTran(cRetorno,"!","")
cRetorno := strTran(cRetorno,"@","")
cRetorno := strTran(cRetorno,"#","")
cRetorno := strTran(cRetorno,"$","")
cRetorno := strTran(cRetorno,"%","")
cRetorno := strTran(cRetorno,"®","")
cRetorno := strTran(cRetorno,"&","")
cRetorno := strTran(cRetorno,"~","")
cRetorno := strTran(cRetorno,";","")
cRetorno := strTran(cRetorno,":","")
cRetorno := strTran(cRetorno,"¥","")
cRetorno := strTran(cRetorno,"`","")
cRetorno := strTran(cRetorno,"'","")
cRetorno := strTran(cRetorno,")","")
cRetorno := strTran(cRetorno,"(","")
cRetorno := strTran(cRetorno,",","")
cRetorno := strTran(cRetorno,"^","")
cRetorno := strTran(cRetorno,"/","")
cRetorno := strTran(cRetorno,"|","")
cRetorno := strTran(cRetorno,"\","")
cRetorno := strTran(cRetorno,"*","")
cRetorno := strTran(cRetorno,"-","")
cRetorno := strTran(cRetorno,"+","")
cRetorno := strTran(cRetorno,"=","")
cRetorno := strTran(cRetorno,"}","")
cRetorno := strTran(cRetorno,"{","")
cRetorno := strTran(cRetorno,"]","")
cRetorno := strTran(cRetorno,"[","")
cRetorno := strTran(cRetorno,"™","")
cRetorno := strTran(cRetorno,"∫","")
cRetorno := strTran(cRetorno,"?","")
cRetorno := strTran(cRetorno,"?","")
cRetorno := strTran(cRetorno,"∞","")
cRetorno := strTran(cRetorno,"	","")
cRetorno := strTran(cRetorno,"¨","")
cRetorno := strTran(cRetorno,"¢","")
cRetorno := strTran(cRetorno,"£","")
cRetorno := strTran(cRetorno,"≥","")
cRetorno := strTran(cRetorno,"≤","")
cRetorno := strTran(cRetorno,"π","")

cRetorno := lower(cRetorno)

Return cRetorno


/////////////////////////////////////////////////////////////////////////////////
//  Funcao: HFPDF005  			                           Data: 05/09/2019    //
//  Autor: RogÈrio Rafael Lino			            	   Cliente: HF         //                                     
//  DescriÁ„o: FunÁ„o que sincroniza dados com a API                           //
/////////////////////////////////////////////////////////////////////////////////  
User Function HFPDF005()

Local cUrl as char
Local cPath as char
//Local oFile as object
//Local cPathx  := AllTrim(GetNewPar("MV_X_PATHX",""))  //Diretorio xml
//Local aRet	:= {}
Local oObjJson	:= Nil
//Local nH		:= Nil
Local nX		:= 0
//Local aArea 	:= {}
//Local cFiltro	:= ""
//Local dUltData		:= Stod(AllTrim(SuperGetMv("XM_DATAIMC")))
Local lAppend		:= .F.
Local aVerificar	:= {}
Local cQtdDias		:= alltrim(GetNewPar("XM_QTDIMC" ,"90"))

Private xZBZ  	:= GetNewPar("XM_TABXML" ,"ZBZ")
Private xZBM  	:= GetNewPar("XM_TABMUN" ,"ZBM")
Private xZBN  	:= GetNewPar("XM_TABMUN2" ,"ZBN")
Private xZBD  	:= GetNewPar("XM_TABIMC" ,"ZBD")

Private xZBZ_ 	:= iif(Substr(xZBZ,1,1)=="S", Substr(xZBZ,2,2), Substr(xZBZ,1,3)) + "_"
Private xZBM_ 	:= iif(Substr(xZBM,1,1)=="S", Substr(xZBM,2,2), Substr(xZBM,1,3)) + "_"
Private xZBN_ 	:= iif(Substr(xZBN,1,1)=="S", Substr(xZBN,2,2), Substr(xZBN,1,3)) + "_"
Private xZBD_ 	:= iif(Substr(xZBD,1,1)=="S", Substr(xZBD,2,2), Substr(xZBD,1,3)) + "_"
Private oBrowse
Private cCnpj   := Alltrim(FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , { "M0_CGC" } )[1][2])

Private oRestClient as object
Private aHeader as array

//If dUltData < dDataBase

	dbSelectArea(xZBD)

/*
	If !PutMv("XM_DATAIMC", dtos(dDataBase) ) 

		RecLock("SX6",.T.)
			SX6->X6_FIL     := xFilial("SX6")
			SX6->X6_VAR     := "XM_DATAIMC"
			SX6->X6_TIPO    := "C"
			SX6->X6_DESCRIC := "Data da Ultima Verificacao do image converter"
		MsUnLock()
		PutMv("XM_DATAIMC", dtos(dDataBase) ) 
	EndIf
*/

	cUrl  := "https://api.imageconverter.com.br"
	//cUrl  := "https://devapi.imageconverter.com.br:443"
	cPath := "/api/sincronizar/?tipodoc=" + cCnpj + "&qtdDias=" + cQtdDias
 	aHeader := {}

	oRestClient := FWRest():New( cUrl )

	oRestClient:SetPath( cPath )
	//oRestClient:SetPostParams( cFile )

	//oFile:Close()

	if oRestClient:Get()

		Conout("Codigo de retorno da api: " + oRestClient:GetResult() + " - OK ")

		If !FWJsonDeserialize(oRestClient:GetResult(), @oObjJson)
			MsgStop("Ocorreu erro no processamento do Json")
			Return Nil
		EndIf	

		If ValType(oObjJson) == "A"
		
			For nX := 1 to Len(oObjJson)
				If ValType(oObjJson[nX]:ID) == "C"
					aAdd(aVerificar,{oObjJson[nX]:ID}) 
				EndIf
			Next

			(xZBD)->(dbGoTop())
			
			/*While !(xZBD)->(EOF())
				nS := aScan(aVerificar,alltrim((xZBD)->(FieldGet(FieldPos(xZBD_+"ID")))))
				If nS <= 0 
					U_POSTREEN(alltrim((xZBD)->(FieldGet(FieldPos(xZBD_+"ARQUIV")))))
				EndIf
				(xZBD)->(dbSkip())
			End*/


			For nX := 1 to Len(oObjJson)

				If ValType(oObjJson[nX]:ID) == "C"

					if AT( 'exclu', lower(oObjJson[nX]:STATUS) ) <= 0
				
						lAppend := !dbSeek(xFilial(xZBD)+padr(oObjJson[nX]:ID,TamSX3(xZBD_+"ID")[1]))

						RecLock(xZBD,lAppend)
							(xZBD)->(FieldPut(FieldPos(xZBD_+"FILIAL")	, /*xFilial(xZBD)*/ " " 												))
							(xZBD)->(FieldPut(FieldPos(xZBD_+"ID")		, oObjJson[nX]:ID 														))
							(xZBD)->(FieldPut(FieldPos(xZBD_+"ARQUIV")	, oObjJson[nX]:FILENAME 												))
							(xZBD)->(FieldPut(FieldPos(xZBD_+"STATUS")	, oObjJson[nX]:STATUS 													))
							(xZBD)->(FieldPut(FieldPos(xZBD_+"LOG")		, DecodeUtf8(oObjJson[nX]:LOG)											))
							(xZBD)->(FieldPut(FieldPos(xZBD_+"DATADO")	, oObjJson[nX]:DATADOWNLOAD			))
							(xZBD)->(FieldPut(FieldPos(xZBD_+"DATAIN")	, oObjJson[nX]:DATACONVERSAO		))
							(xZBD)->(FieldPut(FieldPos(xZBD_+"DATAUP")	, oObjJson[nX]:DATAUPLOAD			))
							(xZBD)->(FieldPut(FieldPos(xZBD_+"PDFON")	, oObjJson[nX]:STATUSPDF												))
						(xZBD)->(MsUnlock())

					endif

				EndIf

			Next nX

		Else
			Conout("Nenhuma nota encontrada no servidor")
		EndIf
	
	Else

		Conout("Falha no momento de conectar a API: " + oRestClient:GetLastError() + "HFPOSTFILE")
		
	Endif
//EndIf

Return

User Function POSTBRW()

	Local aCabBrw := {"ID","Arquivo","Status","Log"}   
	Local aDados	       
	Local oPanel01                     
	Local oDlgEst    
	Local aSize := MsAdvSize()             

	Private xZBZ  	:= GetNewPar("XM_TABXML" ,"ZBZ")
	Private xZBM  	:= GetNewPar("XM_TABMUN" ,"ZBM")
	Private xZBN  	:= GetNewPar("XM_TABMUN2" ,"ZBN")
	Private xZBZ_ 	:= iif(Substr(xZBZ,1,1)=="S", Substr(xZBZ,2,2), Substr(xZBZ,1,3)) + "_"
	Private xZBM_ 	:= iif(Substr(xZBM,1,1)=="S", Substr(xZBM,2,2), Substr(xZBM,1,3)) + "_"
	Private xZBN_ 	:= iif(Substr(xZBN,1,1)=="S", Substr(xZBN,2,2), Substr(xZBN,1,3)) + "_"

 	MsgRun(OemToAnsi('Montando Tela.... Aguarde....'),'',{|| CursorWait(), aDados  := RetDados(),CursorArrow()})  
	                                                 
	DEFINE MSDIALOG oDlgEst TITLE "Arquivos no Image Converter" FROM 000,000 TO aSize[6]-80, aSize[5]-30 Pixel of oMainWnd PIXEL
			                            		
		oTwBrw:= TwBrowse():New(0,0,0,0,,aCabBrw,{100,100,100,100},oDlgEst,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
		oTwBrw:Align := CONTROL_ALIGN_ALLCLIENT
		oTwBrw:SetArray(aDados)             
				
		oTwBrw:bLine := {||{ aDados[oTwBrw:nAt,1],;
  								aDados[oTwBrw:nAt,2],;
								aDados[oTwBrw:nAt,3],;
								aDados[oTwBrw:nAt,4] } }     
                             
	ACTIVATE MSDIALOG oDlgEst ON INIT EnchoiceBar(oDlgEst,{|| oDlgEst:End()},{|| oDlgEst:End()}) CENTERED  
	
Return

Static Function RetDados()

//	Local cQry
	Local aDados 	:= {}
	Local aTmp		:= 0
	Local cAliasZBN := GetNextAlias()

	cQuery := ""
	cQuery += " Select R_E_C_N_O_ as REG "
	cQuery += " FROM "+RetSqlName(xZBN)+" ZBN "
	cQuery += " Where D_E_L_E_T_ = ' ' "
	cQuery += " And "+xZBN_+"COD = 'IMAGE' "
	cQuery += " And "+xZBN_+"FILIAL = '"+xFilial(xZBN)+"' "
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasZBN)

	DbSelectARea( cAliasZBN )
	(cAliasZBN)->( dbGoTop() )
	
	Do While .NOT. (cAliasZBN)->( Eof() )

		DbSelectArea( xZBN )
		(xZBN)->( dbGoto( (cAliasZBN)->REG) )

		aTmp := Separa(Alltrim((xZBN)->(FieldGet(FieldPos(xZBN_+"MSG")))),";")

		aAdd(aDados,aTmp)

		(cAliasZBN)->( dbSkip() )
	EndDo

	(cAliasZBN)->(dbCloseArea())                           
	
	If len(aDados) == 0
		aAdd(aDados,{"","","",""})
	EndIf
	
Return aDados 
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa   HF069BRW   ≥ Cadastro Municipios		                                      ∫±±
±±∫           ≥          ≥                                                                ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Par‚metros ≥Nil.                                                                       ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Retorno    ≥Nil                                                                        ∫±±
±±«ƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ∂±±
±±∫Autor      ≥ 01/09/20 ≥Heverton Marcondes dos Santos                                   ∫±±
±±«ƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ∂±±
±±∫Descricao  ≥ ManutenÁ„o no cadastro de Municipios                                      ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

User Function POSTBRW2()

Local aArea 	:= {}
Local cFiltro	:= ""

Private xZBD  	:= GetNewPar("XM_TABIMC" ,"ZBD")
Private xZBD_ 	:= iif(Substr(xZBD,1,1)=="S", Substr(xZBD,2,2), Substr(xZBD,1,3)) + "_"
Private oBrowse

aArea := (xZBD)->(GetArea())
cFiltro	:= "alltrim("+xZBD+"->"+xZBD_+"STATUS) <> 'Finalizado' "

aRotina := MenuDef()

oBrowse := FWMBrowse():New()
oBrowse:SetAlias(xZBD)
oBrowse:SetDescription("Image Converter")
oBrowse:DisableDetails()

oBrowse:AddLegend( "alltrim("+xZBD+"->"+xZBD_+"STATUS) == 'Recebido' "		, 'BR_PRETO'   		, OemToAnsi("Recebido") )
oBrowse:AddLegend( "alltrim("+xZBD+"->"+xZBD_+"STATUS) == 'Processando' "	, 'BR_MARROM'  		, OemToAnsi("Processando") )
oBrowse:AddLegend( "alltrim("+xZBD+"->"+xZBD_+"STATUS) == 'Inconcistente' "	, 'BR_AZUL'   		, OemToAnsi("Inconcistente") )
oBrowse:AddLegend( "alltrim("+xZBD+"->"+xZBD_+"STATUS) == 'Aguardando' "	, 'BR_AMARELO'   	, OemToAnsi("Aguardando") )
oBrowse:AddLegend( "alltrim("+xZBD+"->"+xZBD_+"STATUS) == 'Concluido' "		, 'BR_VERDE' 		, OemToAnsi("Concluido") )
oBrowse:AddLegend( "alltrim("+xZBD+"->"+xZBD_+"STATUS) == 'Finalizado' "	, 'BR_VERDE_ESCURO' , OemToAnsi("Finalizado") )
oBrowse:AddLegend( "alltrim("+xZBD+"->"+xZBD_+"STATUS) == 'Error' "			, 'BR_VERMELHO'   	, OemToAnsi("Error") )
oBrowse:AddLegend( "alltrim("+xZBD+"->"+xZBD_+"STATUS) == 'Excluido' "		, 'BR_BRANCO'   	, OemToAnsi("Excluido") )
oBrowse:AddLegend( "alltrim("+xZBD+"->"+xZBD_+"STATUS) == 'Inv·lido' "		, 'BR_CINZA'   		, OemToAnsi("Inv·lido") )
oBrowse:AddLegend( "alltrim("+xZBD+"->"+xZBD_+"STATUS) == 'ValidaÁ„o' "		, 'BR_PINK'   		, OemToAnsi("ValidaÁ„o") )

If Aviso( "Filtrar/Todos", "Deseja filtrar apenas as pendentes", { "Filtrar", "Todos" } ) == 1
	oBrowse:SetFilterDefault(cFiltro)
EndIf	

oBrowse:Activate()

RestArea(aArea)

Return

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫FunáÑo    ≥MenuDef   ∫ Autor ≥ Heverton Marcondes ∫ Data ≥ 09/11/2017  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫DescriáÑo ≥ Menudef                                                    ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/

Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE "Pesquisar"  			ACTION "PesqBrw" 			OPERATION 1 ACCESS 0
//ADD OPTION aRotina TITLE "Reenvio" 				ACTION "U_POSTREEN" 		OPERATION 4 ACCESS 0

//Lembrar de tirar
ADD OPTION aRotina TITLE "Atualiza"				ACTION "U_HFPDF005" 		OPERATION 3 ACCESS 0

ADD OPTION aRotina TITLE "Visualizar Registro" 	ACTION "VIEWDEF.HFPOSTFILE"	OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Visualizar PDF" 		ACTION "U_POSTPDF" 			OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Excluir em Lote" 		ACTION "U_POSTEXC" 			OPERATION 5 ACCESS 0
ADD OPTION aRotina TITLE "Teste de Conexao"		ACTION "U_POSTTST" 			OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Imprimir" 			ACTION "VIEWDEF.HFPOSTFILE" OPERATION 8 ACCESS 0
ADD OPTION aRotina TITLE "Legenda"          	ACTION "U_POSTLEG"  		OPERATION 3 ACCESS 0

Return aRotina

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫FunáÑo    ≥ModelDef  ∫ Autor ≥ Heverton Marcondes ∫ Data ≥ 01/09/2020  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫DescriáÑo ≥ Modeldef                                                   ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/

Static Function ModelDef()

Local oStruZBD := FWFormStruct( 1, xZBD)
Local oModel

oModel := MPFormModel():New( 'MHFPOSTFILE')

oModel:AddFields( xZBD, /*cOwner*/, oStruZBD )
oModel:SetPrimaryKey({xZBD_+"FILIAL",xZBD_+"ID"})

oModel:SetDescription( 'Image Converter' )

oModel:GetModel( xZBD ):SetDescription( 'Image Converter' )

Return oModel

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫FunáÑo    ≥ViewDef   ∫ Autor ≥ Heverton Marcondes ∫ Data ≥ 01/09/2020  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫DescriáÑo ≥ ViewDef                                                    ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/

Static Function ViewDef()

Local oModel := ModelDef()

Local oStruZBD	:= FWFormStruct( 2, xZBD )

Local oView

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField( 'VIEW_ZBD', oStruZBD, xZBD)

Return oView

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫FunáÑo    HF069LEG   ∫ Autor ≥ Heverton Marcondes ∫ Data ≥ 01/09/2020  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫DescriáÑo ≥ HF069LEG                                                   ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/

USer Function POSTLEG()

Local aLegenda := {}

AADD(aLegenda,{"BR_PRETO" 			,"Recebido" })
AADD(aLegenda,{"BR_MARROM"			,"Processando" })
AADD(aLegenda,{"BR_AZUL" 			,"Inconcistente" })
AADD(aLegenda,{"BR_AMARELO"			,"Aguardando" })
AADD(aLegenda,{"BR_VERDE" 			,"Concluido" })
AADD(aLegenda,{"BR_VERDE_ESCURO"	,"Finalizado" })
AADD(aLegenda,{"BR_VERMELHO" 		,"Error" })
AADD(aLegenda,{"BR_BRANCO" 			,"Excluido" })


BrwLegenda("Image Converter", "Legenda", aLegenda)

Return Nil

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫FunáÑo    HF069LEG   ∫ Autor ≥ Heverton Marcondes ∫ Data ≥ 01/09/2020  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫DescriáÑo ≥ HF069LEG                                                   ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/

User Function POSTPDF()

Local oDlg
Local aSize 	:= MsAdvSize(.F.,.F.,400)
Local cID		:= alltrim((xZBD)->(FieldGet(FieldPos(xZBD_+"ID"))))
Local cGravaPdf	:= AllTrim(GetNewPar("XM_GRVNFSE","N"))
Local cPathx    := AllTrim(GetNewPar("MV_X_PATHX",""))  //Diretorio xml
Local cDir      := cPathx + "PDF\" 

If (xZBD)->(FieldGet(FieldPos(xZBD_+"PDFON"))) == "1"
	If IsSrvUnix()
		shellExecute( "Browser", "/usr/bin/firefox", 'http://web.imageconverter.com.br/public/Arquivos/pdf/'+cID+'.pdf', "/", 1 )
	Else	
		ShellExecute( "open", 'http://web.imageconverter.com.br/public/Arquivos/pdf/'+cID+'.pdf', "", "", 1 )
	EndIf	
Else
	If File(cDir + "Enviados\"+cID+".pdf")
		If IsSrvUnix()
			If !Existdir( "/tmp/")
				MakeDir( "/tmp/" )
			EndIf

			CpyS2T(cDir + "Enviados\"+cID+".pdf","/tmp/"+cID+".pdf")
			shellExecute( "Browser", "/usr/bin/firefox", '/tmp/'+cID+'.pdf', "/", 1 )
		Else	
			If !Existdir( "C:/Temp/")
				MakeDir( "C:/Temp/" )
			EndIf

			CpyS2T(cDir + "Enviados\"+cID+".pdf","C:/Temp/"+cID+".pdf")
			ShellExecute( "open", 'C:/Temp/'+cID+'.pdf', "", "", 1 )
		EndIf	
	Else
		msgInfo("Arquivo n„o encontrado online e nem localmente","ImpossÌvel apresentar")
	EndIf
EndIf

Return NIL  

User Function POSTREEN(cFile)

Local cUrl 			:= ""
Local cPath 		:= ""
//Local cPathx  		:= AllTrim(GetNewPar("MV_X_PATHX",""))  //Diretorio xml
//Local aRet			:= {}
Local oObjJson		:= Nil
//Local nH			:= Nil
Local nX			:= 0
Local cBody			:= ""
Local oRestClient 	:= Nil
Local aHeader 		:= {}
Local lAppend		:= .T.

dbSelectArea(xZBD)
(xZBD)->(dbSetOrder(2))

If ValType(cFile) == "C"
	cFilePDF 	:= cFile
Else
	cFilePDF 	:= alltrim((xZBD)->(FieldGet(FieldPos(xZBD_+"ARQUIV"))))
EndIf

If !Empty(cFilePDF)

	cCnpj   	:= Alltrim(FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , { "M0_CGC" } )[1][2])

	Aadd(aHeader, "Content-Type: application/json")   

	cUrl  := "https://api.imageconverter.com.br"
	//cUrl  := "https://devapi.imageconverter.com.br:443"
	cPath := "/api/arquivo/?id=" + cCnpj 

	cBody := '{'
	cBody += '"tipoDoc": "NFSE",'
	cBody += '"origin": "API",'
	cBody += '"arquivos" :["'+alltrim(cFilePDF)+'.pdf"]'
	cBody += '}'

	oRestClient := FWRest():New( cUrl )
	oRestClient:SetPath( cPath )
	oRestClient:SetPostParams(cBody)

	If oRestClient:Post( aHeader )

		If !FWJsonDeserialize(oRestClient:GetResult(), @oObjJson)
			MsgStop("Ocorreu erro no processamento do Json")
			Return Nil
		EndIf

		For nX := 1 to Len(oObjJson)
			If ValType(oObjJson[nX]:FILENAME) == "C"	

				If !Empty(oObjJson[nX]:FILENAME)
					lAppend := !dbSeek(xFilial(xZBD)+padr(oObjJson[nX]:FILENAME,TamSX3(xZBD_+"ARQUIV")[1]))

					RecLock(xZBD,lAppend)
						(xZBD)->(FieldPut(FieldPos(xZBD_+"FILIAL")	, /*xFilial(xZBD)*/ " " ))
						(xZBD)->(FieldPut(FieldPos(xZBD_+"ID")		, IIF(ValType(oObjJson[nX]:ID) == "C",oObjJson[nX]:ID,"NAO ENCONTRADO") 						))
						(xZBD)->(FieldPut(FieldPos(xZBD_+"ARQUIV")	, IIF(ValType(oObjJson[nX]:FILENAME) == "C",oObjJson[nX]:FILENAME,"NAO ENCONTRADO") 			))
						(xZBD)->(FieldPut(FieldPos(xZBD_+"STATUS")	, IIF(ValType(oObjJson[nX]:STATUS) == "C",oObjJson[nX]:STATUS,"NAO ENCONTRADO") 				))
						(xZBD)->(FieldPut(FieldPos(xZBD_+"LOG")		, IIF(ValType(oObjJson[nX]:LOG) == "C",DecodeUtf8(oObjJson[nX]:LOG),"NAO ENCONTRADO")			))
						(xZBD)->(FieldPut(FieldPos(xZBD_+"DATADO")	, oObjJson[nX]:DATADOWNLOAD																		))
						(xZBD)->(FieldPut(FieldPos(xZBD_+"DATAIN")	, oObjJson[nX]:DATACONVERSAO																	))
						(xZBD)->(FieldPut(FieldPos(xZBD_+"DATAUP")	, oObjJson[nX]:DATAUPLOAD																		))
						(xZBD)->(FieldPut(FieldPos(xZBD_+"PDFON")	, oObjJson[nX]:STATUSPDF																		))
					(xZBD)->(MsUnlock())

				EndIf

			Else
				msgAlert("Falha no retorno da API: " + oRestClient:GetLastError() + " HFPOSTFILE")	
			EndIf		
		Next

	Else
		msgAlert("Falha no momento de conectar a API: " + oRestClient:GetLastError() + " HFPOSTFILE")	
	Endif

	// primeiro limpa a propriedade
	oRestClient := NIL
		
	// agora sim limpa o objeto ou , limpa a instancia usando freeobj()
	FreeObj(oRestClient)  //FWFreeVar(@oFile)

EndIf
Conout("Fim da rotina de conversao de pdf - HFPOSTFILE " + TIME() )

Return nil


User Function POSTEXC()

//	Local aParBox 	:= {}
//	Local aRetArea	:= GetArea()
//	Local cQuery	:= ""

	Private cMarca,lInverte
	Private oProcess, lEnd, aRotina, aIndexZBD:={}

	dbSelectArea(xZBD)
	dbSetOrder(1)
	dbGoTop()

	If (xZBD)->(EOF()) 
		msgAlert("N„o h· dados")
		Return
	Else
		POSTSEL()
	EndIf	



Return

Static Function POSTSEL()

	Local cFilZBD		:= ""
	Local cQryZBD		:= ""
	Local aCores		:= {}
	Local bFiltraBrw	:= Nil
	Local cFlag			:= Nil
	local lVemMarc		:= .F.

	Private  aRotina	:= {}
	Private cCadastro	:= ""

	aRotina := {{"Pesquisar" ,"AxPesqui", 0 , 1},;
	{"Deletar"   ,"U_POSTDEL()", 0 , 4, 20 }}

	dbselectArea(xZBD)
	cCadastro	:= "Exclus„o em lote" 

	bFiltraBrw	:= {|x|If(x==Nil,FilBrowse(xZBD,@aIndexZBD,@cFilZBD),{cFilZBD,cQryZBD,"","",aIndexZBD})}

	Eval(bFiltraBrw)

	cFlag:='' // Aqui pode-se mencionar um campo do arquivo, que se preenchido permite a marcaÁ„o,
	// ou ainda uma funÁ„o que retorna lÛgico quanto ‡ possibilidade de marcar o registro

	cMarca := GetMark(,xZBD,xZBD_+"OK")

	lInverte := lVemMarc

	MarkBrow(xZBD,xZBD_+"OK",cFlag,,@lInverte,@cMarca,"U_POSTINV(1)") //,,,,,,,,aCores)

	dbSelectArea(xZBD)
	RetIndex(xZBD)
	dbClearFilter()
	aEval(aIndexZBD,{|x| Ferase(x[1]+OrdBagExt())})

Return

User Function POSTDEL()

	Local cCnpj   := Alltrim(FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , { "M0_CGC" } )[1][2])
	Local cUrl 		:= ""
	Local cPath 	:= ""
	Local oRestDel 	:= Nil
	Local aHeader 	:= {}
//	Local aRegs 	:= {} 
	Local nX		:= 0
	Local cBody		:= ""
	Local lEntrou	:= .F.
	Local oObjJson	:= Nil
	Local cMsg		:= ""

	Aadd(aHeader, "Content-Type: application/json")   

	cUrl  := "https://api.imageconverter.com.br"
	//cUrl  := "https://devapi.imageconverter.com.br:443"
	cPath := "/api/arquivo/"

	cBody += "{" 
	cBody += '"doc":"'+cCnpj+'",' 
    cBody += '"tipoDoc": "NFSE",'
    cBody += '"origin": "API",' 
    cBody += '"arquivos":[' 

	(xZBD)->(dbgotop())

	While (xZBD)->(!eof())
		IF (xZBD)->(FieldGet(FieldPos(xZBD_+"OK"))) == cMarca
			RecLock(xZBD,.F.)
				(xZBD)->(dbDelete())
				lEntrou := .T.
				cBody += '"'+alltrim((xZBD)->(FieldGet(FieldPos(xZBD_+"ID"))))+'",' 
			(xZBD)->(msUnlock())
		EndIf
		(xZBD)->(dbskip())
	End

	cBody := substr(cBody,1,len(cBody)-1)
	cBody += ']}'

	If lEntrou
		oRestDel := FWRest():New( cUrl )
		oRestDel:SetPath( cPath )

		If oRestDel:Delete( aHeader , cBody )
			If !FWJsonDeserialize(oRestDel:GetResult(), @oObjJson)
				MsgStop("Ocorreu erro no processamento do Json")
				Return Nil
			EndIf

			For nX := 1 to Len(oObjJson)	
				If ValType(oObjJson[nX]:ID) == "C"
					cMsg +=  oObjJson[nX]:ID + " - " + decodeUtf8(oObjJson[nX]:LOG) + CHR(13)+CHR(10)
				EndIf		
			Next

			msgInfo("Delete realizado com sucesso" + CHR(13)+CHR(10) + cMsg)
		Else
			msgAlert("Erro ao excluir do servidor")
		EndIf
	EndIf

Return

User Function POSTINV(nOpc)

	If nOpc == 1 // Marcar todos
		(xZBD)->(dbGoTop())
		While !EOF()
			RecLock(xZBD,.F.)
				(xZBD)->(FieldPut(FieldPos(xZBD_+"LOG") , Iif((xZBD)->(FieldGet(FieldPos(xZBD_+"OK")))==cMarca,"",cMarca) ))
			(xZBD)->(MsUnLock())
			(xZBD)->(dbSkip())
		End
		dbGoTop()
	Elseif nOpc == 2  // Marcar somente o registro posicionado
		RecLock(xZBD,.F.)   //RecLock("SE3",.F.)
		(xZBD)->(FieldPut(FieldPos(xZBD_+"LOG") , Iif((xZBD)->(FieldGet(FieldPos(xZBD_+"OK")))==cMarca,"",cMarca) ))
		(xZBD)->(MsUnLock())
	Endif

Return	


User Function POSTTST()

Local cUrl 			:= ""
Local cPath 		:= ""
Local oObjJson		:= Nil
Local oRestClient 	:= Nil
Local aHeader 		:= {}

Aadd(aHeader, "Content-Type: application/json")   

cUrl  := "https://api.imageconverter.com.br"
//cUrl  := "https://devapi.imageconverter.com.br:443"
cPath := "/api/arquivo/

oRestClient := FWRest():New( cUrl )
oRestClient:SetPath( cPath )

If oRestClient:Post( aHeader )

	If !FWJsonDeserialize(oRestClient:GetResult(), @oObjJson)
		MsgStop("Ocorreu erro no processamento do Json")
		Return Nil
	EndIf

	msgInfo("Conex„o efetuada com sucesso")	
Else
	msgAlert("Falha no momento de conectar a API: " + oRestClient:GetLastError() + " HFPOSTFILE")	
Endif

// primeiro limpa a propriedade
oRestClient := NIL
	
// agora sim limpa o objeto ou , limpa a instancia usando freeobj()
FreeObj(oRestClient)  //FWFreeVar(@oFile)

Conout("Fim da rotina de teste de conex„o - HFPOSTFILE " + TIME() )

Return nil


//Cria registro na ZBT para modelo NFSE = RP
User Function AjustZBT()

Local cQuery := ""
Local cAlias := GetNextAlias()
Local lFeito := .F.
Local xZBZ   := GetNewPar("XM_TABXML","ZBZ")
Local xZBZ_  := iif(Substr(xZBZ,1,1)=="S", Substr(xZBZ,2,2), Substr(xZBZ,1,3)) + "_"
Local xZBT   := GetNewPar("XM_TABITEM","ZBT") 
Local xZBT_  := iif(Substr(xZBT,1,1)=="S", Substr(xZBT,2,2), Substr(xZBT,1,3)) + "_"

cQuery := " SELECT "+xZBZ_+"CHAVE, "+xZBZ_+"NOTA, "+xZBZ_+"SERIE, "+xZBZ_+"MODELO, "+xZBZ_+"DTNFE, "+xZBZ_+"CNPJ, "+xZBZ_+"XML FROM " + RetSqlName("ZBZ") + " ZBZ "
cQuery += " WHERE ZBZ.D_E_L_E_T_ = '' and "+xZBZ_+"MODELO = 'RP' AND "
cQuery += " NOT EXISTS ( SELECT "+xZBT_+"CHAVE from " + RetSqlName("ZBT") + " ZBT WHERE ZBT.D_E_L_E_T_ = '' and ZBZ."+xZBZ_+"CHAVE = ZBT."+xZBT_+"CHAVE ) "
Tcquery cQuery new Alias &cAlias

While !(cAlias->( Eof() ))

	//FR - 27/11/2020
	//===================//
	// Grava ZBT:        //
	//===================//
	cVal      := (cAlias)->&(xZBZ_+"XML")
	cModelo   := "RP"			
	cChaveXml := (cAlias)->&(xZBZ_+"CHAVE")
	cNota     := (cAlias)->&(xZBZ_+"NOTA")
	cCnpjEmi  := (cAlias)->&(xZBZ_+"CNPJ")		//CNPJ do Emitente	

	if !Empty(cNota) .and. !Empty(cCnpjEmi)

		U_fGravaZBT(cVal,cModelo,cChaveXml,cNota,"" /*cSeriNF*/ ,cCnpjEmi) //NF ServiÁo n„o tem sÈrie (?)	

		lFeito := .T.

	endif

	(cAlias)->( DbSkip() )

End

if lFeito

	Msginfo("Tabela ZBT atualizado com sucesso")

Else

	MsgStop("N„o foi possivel atualizar tabela ZBT")

endif

Return()


//Atualiza o status no retorno do metodo get
Static Function AtualizaStatus( oObjJson )

Local xZBD  := GetNewPar("XM_TABIMC" ,"ZBD")
Local xZBD_ := iif(Substr(xZBD,1,1)=="S", Substr(xZBD,2,2), Substr(xZBD,1,3)) + "_"
Local nX    := 0

For nX := 1 to Len(oObjJson)

	If ValType(oObjJson[nX]:ID) == "C"

		If DbSeek(xFilial(xZBD)+padr(oObjJson[nX]:ID,TamSX3(xZBD_+"ID")[1]))

			RecLock(xZBD,.F.)

				(xZBD)->(FieldPut(FieldPos(xZBD_+"FILIAL")	, /*xFilial(xZBD)*/ ' ' ))
				(xZBD)->(FieldPut(FieldPos(xZBD_+"ID")		, oObjJson[nX]:ID ))
				(xZBD)->(FieldPut(FieldPos(xZBD_+"ARQUIV")	, oObjJson[nX]:FILENAME ))
				(xZBD)->(FieldPut(FieldPos(xZBD_+"STATUS")	, oObjJson[nX]:STATUS ))
				(xZBD)->(FieldPut(FieldPos(xZBD_+"LOG")		, DecodeUtf8(oObjJson[nX]:LOG) ))
				(xZBD)->(FieldPut(FieldPos(xZBD_+"DATADO")	, oObjJson[nX]:DATADOWNLOAD									))
				(xZBD)->(FieldPut(FieldPos(xZBD_+"DATAIN")	, oObjJson[nX]:DATACONVERSAO								))
				(xZBD)->(FieldPut(FieldPos(xZBD_+"DATAUP")	, oObjJson[nX]:DATAUPLOAD									))
				(xZBD)->(FieldPut(FieldPos(xZBD_+"PDFON")	, "S"))				
				
			(xZBD)->(MsUnlock())

		else

			RecLock(xZBD,.T.)

				(xZBD)->(FieldPut(FieldPos(xZBD_+"FILIAL")	, /*xFilial(xZBD)*/ ' ' ))
				(xZBD)->(FieldPut(FieldPos(xZBD_+"ID")		, oObjJson[nX]:ID ))
				(xZBD)->(FieldPut(FieldPos(xZBD_+"ARQUIV")	, oObjJson[nX]:FILENAME ))
				(xZBD)->(FieldPut(FieldPos(xZBD_+"STATUS")	, oObjJson[nX]:STATUS ))
				(xZBD)->(FieldPut(FieldPos(xZBD_+"LOG")		, DecodeUtf8(oObjJson[nX]:LOG) ))
				(xZBD)->(FieldPut(FieldPos(xZBD_+"DATADO")	, oObjJson[nX]:DATADOWNLOAD									))
				(xZBD)->(FieldPut(FieldPos(xZBD_+"DATAIN")	, oObjJson[nX]:DATACONVERSAO								))
				(xZBD)->(FieldPut(FieldPos(xZBD_+"DATAUP")	, oObjJson[nX]:DATAUPLOAD									))
				(xZBD)->(FieldPut(FieldPos(xZBD_+"PDFON")	, "S"))				
				
			(xZBD)->(MsUnlock())

		EndIf
		
		/*
		if Existdir( cPathx + "pdf\" + cCnpj +"\aguardando")
			nH := fCreate( cPathx + "pdf\" + cCnpj +"\aguardando\"+oObjJson[nX]:ID)
			fClose(nH)
		else
			MakeDir( GetSrvProfString ("ROOTPATH","") + cPathx + "pdf\" + cCnpj +"\aguardando")
			nH := fCreate( cPathx + "pdf\" + cCnpj +"\aguardando\"+oObjJson[nX]:ID)
			fClose(nH)			
		endIf
		*/	
	EndIf		

Next nX


Return()
