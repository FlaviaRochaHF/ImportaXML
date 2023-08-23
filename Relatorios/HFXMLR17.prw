#include "protheus.ch"
#include "rwmake.ch"
#include "font.ch"
#include "colors.ch"
#include "totvs.ch"
#Include "TOPCONN.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWPrintSetup.ch" 


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FISTRFNFEº Autor ³ Rogerio Lino       º Data ³  01/07/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Ponto de Entrada para impressao da CC-e.                   º±±
±±º          ³ Layout nosso enquanto aguarda padrao da SEFAZ              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

#DEFINE VBOX       080
#DEFINE HMARGEM    030

//User Function FISTRFNFE()

//aadd(aRotina,{'Imprime CC-e','U_CPRTCCE' , 0 , 3,0,NIL})

//Return Nil              

/////////////////////////////////////////////
User Function HFXMLR17()
/////////////////////////////////////////////

Local   iw1,iw2,nLin
Local   xBitMap  := FisxLogo("1")     ///Logotipo da empresa
Local   MMEMO1   := MMEMO2 := ""
Local   xCGC     := "" 
Local   aArea    := GetArea()
Local   cMVBanco := GetNewPar("MV_BANTSS","[TSS_25]")

Private cPerg   := "CPRNCCE   "
Private PixelX  := ""
Private PixelY  := ""
Private xZBZ	:= GetNewPar("XM_TABXML","ZBZ")
Private xZBZ_	:= iif(Substr(xZBZ,1,1)=="S", Substr(xZBZ,2,2), Substr(xZBZ,1,3)) + "_" 

ValidPerg()

lRsp := Pergunte(cPerg,.T.)

IF ( !lRsp )
	Return
ENDIF

dbSelectArea(xZBZ)
dbSetOrder(2)
dbSeek( xFilial(xZBZ) + Mv_Par02 + Mv_Par01 )

cChvNfe  := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE")))
dEmissao := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"DTNFE")))

IF ( EOF() .OR. EMPTY(cChvNfe) )
	MsgStop("Atenção! Nota Fiscal não existe ou Nota Fiscal Inutilizada.")
	RestArea(aArea)
	Return
ENDIF

DbSelectArea("SA2")
DbSetOrder(1)
DbSeek(xFilial("SA2")+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR")))+(xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR"))))

xDestinatario := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"FORNEC")))

IF ( !EMPTY(SA2->A2_CGC) )

	xCGC := IIF(LEN((xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ")))) > 11 , TRANSF((xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))),"@R 99.999.999/9999-99") , TRANSF((xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ"))),"@R 999.999.999-99") )

ENDIF	

/*
//////////////////////////////////////////////////////////////
Private _cTopAlias := "SOA_32"         //DEFINIÇAO DO SHEMA DE AMBIENTE ALIAS
Private _cTopDB    := "MSSQL"        //BANCO DE DADOS UTILIZADO
Private _cTopSrv   := "192.168.1.160:7801"    //= IP DO SERVIDOR
Private _cTopSrvN  := "192.168.1.160:7801"
Private cTopServer
Private cTopAlias

cTop         := GetPvProfString("SPED","TOPALIAS",_cTopAlias,GetAdv97())
cTopData     := GetPvProfString("SPED","TOPDATABASE",_cTopDB,GetAdv97())
cTopAlias    := cTopData + "/" + cTop              
cTopServer   := GetPvProfString("SPED","TOPSERVER",_cTopSrv,GetAdv97())

LjMsgRun("Conectando em " + cTopAlias + " " + cTopServer,,,)
TCConType("TCPIP")                                          
nCon := TCLINK(AllTrim(cTopAlias),AllTrim(cTopServer),7890)

If nCon < 0
     MsgStop("Erro conectando SPED: " + alltrim(Str(nCon)) + " - " + AllTrim(cTopAlias) + "-" + AllTrim(cTopServer))
     Return .f.
endif
//////////////////////////////////////////////////////////////
*/


///
///TOP 1 - para pegar sempre a ultima carta de correcao da nf-e
///
cQry := "SELECT TOP 1 ID_EVENTO,TPEVENTO,SEQEVENTO,AMBIENTE,DATE_EVEN,TIME_EVEN,VERSAO,VEREVENTO,VERTPEVEN,VERAPLIC,CORGAO,CSTATEVEN,CMOTEVEN,"
cQry += "PROTOCOLO,NFE_CHV,ISNULL(CONVERT(VARCHAR(2024),CONVERT(VARBINARY(2024),XML_ERP)),'') AS TMEMO1,"
cQry += "ISNULL(CONVERT(VARCHAR(2024),CONVERT(VARBINARY(2024),XML_RET)),'') AS TMEMO2 "
cQry += "FROM " + cMVBanco + "..SPED150 "
cQry += "WHERE D_E_L_E_T_ = ' ' " //AND STATUS = 6 "
cQry += "AND NFE_CHV = '"+cChvNfe+"' "
cQry += "ORDER BY LOTE DESC"

cQry := ChangeQuery(cQry)

dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQry), 'TMP', .T., .T.)

TcSetField("TMP","DATE_EVEN","D",08,0)

dbSelectArea("TMP")
dbGoTop()

IF ( EOF() )

	MsgStop("Atenção! Não existe Carta de Correção para a Nota Fiscal informada.")
	TMP->(dbCloseArea())
	RestArea(aArea)                                                    
	
	Return
	
ENDIF
	
MMEMO1     := TMP->TMEMO1     ///Relativo ao envio
MMEMO2     := TMP->TMEMO2     ///Retorno da SEFAZ
MNFE_CHV   := TMP->NFE_CHV
MID_EVENTO := TMP->ID_EVENTO
MTPEVENTO  := STR(TMP->TPEVENTO,6)
MSEQEVENTO := STR(TMP->SEQEVENTO,1)
MAMBIENTE  := STR(TMP->AMBIENTE,1)+IIF(TMP->AMBIENTE==1," - Produção", IIF(TMP->AMBIENTE==2," - Homologação" , ""))
MDATE_EVEN := DTOC(TMP->DATE_EVEN)
MTIME_EVEN := TMP->TIME_EVEN
MVERSAO    := STR(TMP->VERSAO,4,2)
MVEREVENTO := STR(TMP->VEREVENTO,4,2)
MVERTPEVEN := STR(TMP->VERTPEVEN,4,2)
MVERAPLIC  := TMP->VERAPLIC
MCORGAO    := STR(TMP->CORGAO,2)+IIF(TMP->CORGAO==13 , " - AMAZONAS",IIF(TMP->CORGAO==35 , " - SAO PAULO" , ""))
if Alltrim(STR(TMP->CSTATEVEN,3)) == "135"
	MCSTATEVEN := "Evento registrado e vinculado a NF-e"
elseif Alltrim(STR(TMP->CSTATEVEN,3)) == "136"
	MCSTATEVEN := "Evento registrado, mas não vinculado a NF-e"
else
	MCSTATEVEN := STR(TMP->CSTATEVEN,3)
endif

MCMOTEVEN  := TMP->CMOTEVEN
MPROTOCOLO := STR(TMP->PROTOCOLO,15)

TMP->(dbCloseArea())

RestArea(aArea)

xFone := RTRIM(SM0->M0_TEL)
xFone := STRTRAN(xFone,"(","")
xFone := STRTRAN(xFone,")","")
xFone := STRTRAN(xFone,"-","")
xFone := STRTRAN(xFone," ","")
*
xFax := RTRIM(SM0->M0_FAX)
xFax := STRTRAN(xFax,"(","")
xFax := STRTRAN(xFax,")","")
xFax := STRTRAN(xFax,"-","")
xFax := STRTRAN(xFax," ","")
	
xRazSoc := RTRIM(SM0->M0_NOMECOM) //"QUALITA IND. COM. PROD. PARA VEDACAO LTDA"
xEnder  := RTRIM(SM0->M0_ENDENT) + " - " + RTRIM(SM0->M0_BAIRENT) //+ " - " + RTRIM(SM0->M0_CIDENT) + "/" + SM0->M0_ESTENT // "AV. JUSTINO DE MAIO, 920 - CID. INDL. SATELITE"
xCidade := RTRIM(SM0->M0_CIDENT) + "/" + SM0->M0_ESTENT
xFone   := "Fone / Fax: " + TRANSF(xFone,"@R (99)9999-9999") + IIF(!EMPTY(SM0->M0_FAX) , " / " + TRANSF(xFax,"@R (99)9999-9999") , "" )
xCnpj   := TRANSF(SM0->M0_CGC,"@R 99.999.999/9999-99")
xIE     := SM0->M0_INSC

////
////Extrai dados do Memo
////
MDHEVENTO := ""
iw1 := AT("<dhRegEvento>" , MMEMO2 )
iw2 := AT("</dhRegEvento>" , MMEMO2 )
IF ( iw1 > 0 )
	iw3 := ( iw2 - iw1 )
	MDHEVENTO += SUBS(MMEMO2 , ( iw1+13 ) , ( iw2 - ( iw1 + 13 ) ) )
ENDIF

MDESCEVEN := ""
iw1 := AT("<xEvento>" , MMEMO2 )
iw2 := AT("</xEvento>" , MMEMO2 )
IF ( iw1 > 0 )
	iw3 := ( iw2 - iw1 )
	MDESCEVEN := MMEMO2 //SUBS(MMEMO2 , ( iw1+9 ) , ( iw2 - ( iw1 + 9 ) ) )
ENDIF

aCorrec   := {}
MCORRECAO := ""
iw1 := AT("<xCorrecao>" , MMEMO1 )
iw2 := AT("</xCorrecao>" , MMEMO1 )
IF ( iw1 > 0 )
	iw3 := ( iw2 - iw1 )
	MCORRECAO += SUBS(MMEMO1 , ( iw1+11 ) , ( iw2 - ( iw1 + 11 ) ) ) 
	MCORRECAO := MMEMO1 //SPACE(10)
	iw1 := 1
	DO WHILE !EMPTY(SUBS(MCORRECAO,iw1,10))
		AADD(aCorrec , SUBS(MCORRECAO,iw1,105) )
		iw1 += 105     ///Nro de caracteres da linha - fica a criterio
	ENDDO
ENDIF

aCondic   := {}
MCONDICAO := ""
iw1 := AT("<xCondUso>" , MMEMO1 )
iw2 := AT("</xCondUso>" , MMEMO1 )

AADD(aCondic , "A Carta de Correcao e disciplinada pelo paragrafo 1o-A do art. 7o do Convenio S/N, de 15 de dezembro de 1970 e pode ser utilizada para" )
AADD(aCondic , "regularizacao  de  erro ocorrido na  emissao de  documento  fiscal, desde que o erro nao esteja relacionado com:  I - as variaveis que" )
AADD(aCondic , "determinam o valor do imposto tais como: base de calculo, aliquota, diferenca de preco, quantidade, valor da operacao ou da prestacao;" )
AADD(aCondic , "II - a correcao de dados cadastrais que implique mudanca do remetente ou do destinatario; III - a data de emissao ou de saida.        " )

// Cria um novo objeto para impressao
oPrint := TMSPrinter():New("Impressão da Carta de Correção Eletronica - CC-e")

// Cria os objetos com as configuracoes das fontes
//                                              Negrito  Subl  Italico
oFont08  := TFont():New( "Times New Roman",,08,,.f.,,,,,.f.,.f. )
oFont08b := TFont():New( "Times New Roman",,08,,.t.,,,,,.f.,.f. )
oFont09  := TFont():New( "Times New Roman",,09,,.f.,,,,,.f.,.f. )
oFont09b := TFont():New( "Times New Roman",,09,,.t.,,,,,.f.,.f. )
oFont10  := TFont():New( "Times New Roman",,10,,.f.,,,,,.f.,.f. )
oFont10b := TFont():New( "Times New Roman",,10,,.t.,,,,,.f.,.f. )
oFont11  := TFont():New( "Times New Roman",,11,,.f.,,,,,.f.,.f. )
oFont11b := TFont():New( "Times New Roman",,11,,.t.,,,,,.f.,.f. )
oFont12  := TFont():New( "Times New Roman",,12,,.f.,,,,,.f.,.f. )
oFont12b := TFont():New( "Times New Roman",,12,,.t.,,,,,.f.,.f. )
oFont13b := TFont():New( "Times New Roman",,13,,.t.,,,,,.f.,.f. )
oFont14  := TFont():New( "Times New Roman",,14,,.f.,,,,,.f.,.f. )
oFont24b := TFont():New( "Times New Roman",,24,,.t.,,,,,.f.,.f. )

// Mostra a tela de Setup
oPrint:Setup()

oPrint:SetPortrait()
oPrint:SetPaperSize(9)       ///(DMPAPER_A4)

PixelX := oPrint:nLogPixelX()
PixelY := oPrint:nLogPixelY()
   
// Inicia uma nova pagina
oPrint:StartPage()

nHPage := oPrint:nHorzRes()
nHPage *= (300/PixelX)
nHPage -= HMARGEM  //2450   //2450.5   //2350   //2308
nVPage := oPrint:nVertRes()
nVPage *= (300/PixelY)
nVPage -= VBOX     //3428   //3428     //3327   //3327

//oPrint:SetFont(oFont24b)
//oPrint:SayBitMap(100,116,xBitMap,600,280)
oPrint:Box(100,100,530,1020)

oPrint:Say(120,300,"IDENTIFICAÇÃO DO EMITENTE",oFont08b,140)
oPrint:Say(190,110,xRazSoc,oFont10b ,140)
oPrint:Say(240,110,xEnder,oFont08b ,140)
oPrint:Say(290,110,xCidade,oFont08b ,140)
oPrint:Say(340,110,xFone,oFont09b ,140)
oPrint:Say(440,110,"INSCRIÇÃO ESTADUAL",oFont09b ,140)
oPrint:Say(480,110,xIE,oFont09b ,140)
oPrint:Line(424,600,530,600)
oPrint:Say(440,660,"CNPJ",oFont09b ,140)
oPrint:Say(480,660,xCnpj,oFont09b ,140)

oPrint:Box(100,1020,530,2400)

oPrint:Say(100,1600,"CC-e",oFont10b ,160)
oPrint:Say(142,1355,"CARTA DE CORREÇÃO ELETRÔNICA",oFont09b ,160)
oPrint:Line(184,1020,184,2400)
oPrint:Say(184,1400,"CHAVE DE ACESSO DA NF-e",oFont09b ,160)
oPrint:Say(214,1250,Alltrim(MNFE_CHV),oFont09b ,160)
oPrint:Line(254,1020,254,2400)

if PixelX == 300

	if nVPage == 3309 .and. nHPage == 2350
		MSBAR('CODE128',2.65,10.5,MNFE_CHV,oPrint,.F.,,.T.,0.0130,1.33,,,,.F.)
	elseif nVPage == 3327 .and. nHPage == 2350
		MSBAR('CODE128',2.62,10.5,MNFE_CHV,oPrint,.F.,,.T.,0.0130,1.33,,,,.F.)	
	elseif nVPage == 3327 .and. nHPage == 2308
		MSBAR('CODE128',2.79,10.5,MNFE_CHV,oPrint,.F.,,.T.,0.0130,1.33,,,,.F.)	
	else
		MSBAR('CODE128',2.2,10,MNFE_CHV,oPrint,.F.,,.T.,0.0130,1.33,,,,.F.)	
	endif

else

	MSBAR('CODE128',1.1,5,MNFE_CHV,oPrint,.F.,,.T.,0.0105,0.67,,,,.F.)	

endif

oPrint:Line(424,100,424,2400)

oPrint:Box(560,100,2000,2400)

oPrint:Say(440,1050,"MODELO",oFont09b ,160)
oPrint:Say(480,1100,(xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO"))),oFont09b ,160)
oPrint:Line(424,1250,530,1250)
oPrint:Say(440,1280,"SERIE",oFont09b ,100)
oPrint:Say(480,1300,mv_par01,oFont09b ,100)
oPrint:Line(424,1420,530,1420)
oPrint:Say(440,1460,"NUMERO DA NF-e",oFont09b ,100)
oPrint:Say(480,1510,mv_par02,oFont09b ,100)
oPrint:Line(424,1810,530,1810)
oPrint:Say(440,1860,"MÊS DA EMISSÃO",oFont09b ,100)
oPrint:Say(480,1920,Substr(AnoMes(dEmissao),5,2) +"/"+ Substr(AnoMes(dEmissao),1,4),oFont09b ,100)
oPrint:Line(424,2210,530,2210)
oPrint:Say(440,2245,"FOLHA",oFont09b ,100)
oPrint:Say(480,2275,"1/1",oFont09b ,100)

oPrint:Box(635,100,950,2400)

oPrint:Say(590,110,"DESTINATARIO / REMETENTE",oFont11b ,100)
oPrint:Say(640,110,"NOME / RAZAO SOCIAL",oFont11b ,100)
oPrint:Say(690,110,xDestinatario,oFont11 ,100)
oPrint:Line(635,1860,740,1860)
oPrint:Say(640,1890,"CNPJ / CPF",oFont11b ,100)
oPrint:Say(690,1890,xCGC,oFont11 ,100)
oPrint:Line(740,110,740,2400)
oPrint:Say(740,110,"ENDEREÇO",oFont11b ,100)
oPrint:Say(790,110,SA2->A2_END,oFont11 ,100)
oPrint:Say(740,850,"BAIRRO / DISTRITO",oFont11b ,140)
oPrint:Say(790,850,SA2->A2_BAIRRO,oFont11 ,140)
oPrint:Line(740,820,950,820)
oPrint:Line(740,1860,950,1860)
oPrint:Say(740,1890,"CEP",oFont11b ,140)
oPrint:Say(790,1890,SA2->A2_CEP,oFont11 ,140)
oPrint:Line(840,110,840,2400)
oPrint:Say(840,110,"MUNICIPIO",oFont11b ,140)
oPrint:Say(890,110,SA2->A2_MUN,oFont11 ,140)
oPrint:Say(840,850,"UF",oFont11b ,140)
oPrint:Say(890,850,SA2->A2_EST,oFont11 ,140)
oPrint:Line(845,980,950,980)
oPrint:Say(840,1000,"FONE / FAX",oFont11b ,140)
oPrint:Say(890,1000,"(" + Alltrim(SA2->A2_DDD) +") "+ TRANSF(SA2->A2_TEL,"@R 999999999"),oFont11 ,140)
oPrint:Say(840,1890,"INSCRIÇÃO ESTADUAL",oFont11b ,140)
oPrint:Say(890,1890,SA2->A2_INSCR,oFont11 ,140)

oPrint:Say(990,110,"CONDIÇÃO DE USO",oFont11b ,100)

oPrint:Box(1035,100,1250,2400)

nLin := 990
FOR iw2 := 1 TO LEN(aCondic)

	nLin += 50
	oPrint:Say(nLin,110,aCondic[iw2],oFont11 ,2000)

NEXT

oPrint:Say(1290,110,"EVENTO / CORREÇÃO",oFont11b ,100)

oPrint:Line(1460,100,1460,2400)

oPrint:Say(1400,110,"SEQ",oFont11 ,160)
oPrint:Say(1470,110,MSEQEVENTO,oFont11b ,160)
oPrint:Say(1400,240,"STATUS",oFont11,100)
oPrint:Say(1475,240,MCSTATEVEN,oFont09b ,100)
oPrint:Say(1400,935,"DATA DO REGISTRO",oFont11 ,100)
oPrint:Say(1470,955,MDATE_EVEN+" "+MTIME_EVEN,oFont11b ,100)
oPrint:Say(1400,1410,"NUMERO DO PROTOCOLO",oFont11 ,100)
oPrint:Say(1470,1410,MPROTOCOLO,oFont11b ,100)
oPrint:Say(1400,2000,"VIGENTE",oFont11 ,100)
oPrint:Say(1470,2040,"Sim",oFont11b ,100)

oPrint:Line(1530,100,1530,2400)

oPrint:Say(1560,110,"Texto da Carta de Correção",oFont11b ,300)
nLin := 1560

if Empty(aCorrec)

	nLin += 50
	oPrint:Say(nLin,110,MCMOTEVEN,oFont11 ,2000)

else

	FOR iw1:=1 TO LEN(aCorrec)

		nLin += 50
		oPrint:Say(nLin,110,aCorrec[iw1],oFont11 ,2000)

	NEXT

endif

oPrint:EndPage()

oPrint:Preview()

Return .F. 


/////////////////////////////////////////////////////////
Static Function ValidPerg()
/////////////////////////////////////////////////////////
_sAlias := Alias()
DbSelectArea("SX1")
DbSetOrder(1)
aRegs :={} //Grupo|Ordem| Pegunt                         | perspa | pereng | VariaVL  | tipo| Tamanho|Decimal| Presel| GSC | Valid         |   var01   | Def01          | DefSPA1 | DefEng1 | CNT01 | var02 | Def02           | DefSPA2 | DefEng2 | CNT02 | var03 | Def03    | DefSPA3 | DefEng3 | CNT03 | var04 | Def04 | DefSPA4 | DefEng4 | CNT04 | var05 | Def05 | DefSPA5 | DefEng5 | CNT05 | F3    | GRPSX5 |
aAdd(aRegs,{ cPerg,"01" , "Série                       ?",   ""   ,  ""    , "mv_ch1" , "C" ,   03   ,   0   ,   0   , "G" , "          "  , "mv_par01", "            " , "     " , "     " , "   " , "   " , "             " , "     " , "     " , "   " , "   " , "      " , "     " , "     " , "   " , "   " , "   " , "     " , "     " , "   " , "   " , "   " , "     " , "     " , "   " , "   " , "    " })
aAdd(aRegs,{ cPerg,"02" , "Nota Fiscal                 ?",   ""   ,  ""    , "mv_ch2" , "C" ,   09   ,   0   ,   0   , "G" , "          "  , "mv_par02", "            " , "     " , "     " , "   " , "   " , "             " , "     " , "     " , "   " , "   " , "      " , "     " , "     " , "   " , "   " , "   " , "     " , "     " , "   " , "   " , "   " , "     " , "     " , "   " , "   " , "    " })
For i:=1 to Len(aRegs)
	If !DbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next j
		MsUnlock()
	Endif
Next i

dbSelectArea(_sAlias)

Return
