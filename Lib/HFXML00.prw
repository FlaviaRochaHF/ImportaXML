#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "TBICONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHFXML00X  บAutor  ณRoberto Souza       บ Data ณ  01/01/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Interface/Dialog de Aviso.                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Geral                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
//--------------------------------------------------------------------------//
//FR - 11/06/2020 - Altera็๕es realizadas para adequar a valida็ใo da licen็a 
//                  quando for licen็a Demonstra็ใo (Demo)
//                  Implementado "flag" para sinalizar todo o sistema quando
//                  for licen็a Demo e assim, NรO permitir consultas
//                  no relat๓rio de pr้-auditoria de forma abrangente
//                  Demo = consulta ้ data de hoje - 30 apenas
//                  
//--------------------------------------------------------------------------//
User Function HFXML00X(cCodProd,cVersion,cCNPJ,dVencLic,lAv)
Local lRet      := .F.
Local cChave    := ""
Local cBaseCNPJ := ""
Local cFileKey  := ""
Local nEnviar   := 99
Local cMsg      := ""
Local cChaveAux := ""
Local cFlagDemo1:= ""		//FR - 11/06/2020 - tratativa para licen็a demonstra็ใo 
Local cFlagDemo2:= ""		//FR - 11/06/2020 - tratativa para licen็a demonstra็ใo 
Local cAux      := "" 
Local nTamDemo  := 0
Default lAv     := .T.
Public lDemo    := .F.   	//FR - 11/06/2020 - tratativa para licen็a demonstra็ใo

cBaseCNPJ := SUBSTR(cCNPJ,1,14) 							//a partir de 10 de abril chave exclusiva por filial
cFileKey  := cCodProd+cBaseCNPJ+".hfc"
                                                            //             10        20        30        40        50
If File(cFileKey)                                           //     1234567890123456789012345678901234567890123456789012345678
	cChave := memoRead(cCodProd+cBaseCNPJ+".hfc")   		//ex.: 43CECE44926D7E902D59D123F04C74D45A0E5E69MjAyMDA3MDExMDE=93  (chave)
	cKey := cCodProd+;
			cBaseCnpj+;
		 	'HF-CONSULTING-XML'
	                                                        //     1234567890123456789*                     pega posi็ใo 20  (key)          
	cKey       := Upper(Sha1(cKey))   						//ex.: 43CECE44926D7E902D59D123F04C74D45A0E5E69
	dDateVenc  := Stod( Substr(Decode64(Substr(cChave,41)),1,8) )
	dVencLic   := dDateVenc	  
	
	//-----------------------------------------------------//
	//FR - 11/06/2020 - tratativa para licen็a demonstra็ใo 
	                                                        //                                       *
	cChaveAux  := Substr(cChave,1,Len(cChave)-2)  			//43CECE44926D7E902D59D123F04C74D45A0E5E69MjAyMDA3MDExMDE=
	cFlagDemo1 := Substr(cKey,(Len(cKey)/2),1)  			//ex.:  9                         *
	cAux       := Substr(cChaveAux, Len(cKey)+1 , Len(cChaveAux) - Len(cKey) ) 	//ex.: MjAyMDA3MDExMDE=
	cFlagDemo2 := Substr(cAux,Len(cAux)/2,1) 			   	//ex.: 3   
	
	nTamDemo   := (Len(cKey) + Len(cAux) + 2)       		//ex.: n๚mero de caracteres da chave no arquivo de licen็a normal o tamanho ้ 56, demo ้ 58
	
	lDemo:= ( Len(cChave) == nTamDemo .and. Substr(cChave,Len(cChave)-1,2) == cFlagDemo1 + cFlagDemo2  )	
	//FR - 11/06/2020 - tratativa para licen็a demonstra็ใo 
	//-----------------------------------------------------//
	
	If Substr(cKey,1,40) == Substr(cChave,1,40)  .or. lDemo			
		If Date() <= dDateVenc
			lRet := .T.			 
			nDaysLeft := (dDateVenc -Date())
			If nDaysLeft < 30 
				If !lDemo
					cMsgAviso:="A licen็a em conting๊ncia irแ expirar em "+AllTrim(Str(nDaysLeft))+" dias!" +CHR(13)+CHR(10)+"Entre em contato com a HF - Consulting." +CHR(13)+CHR(10)+;
					"Tel: 11-5524-5124 ou Pelo E-mail comercial@hfbr.com.br."
				Else
					cMsgAviso:="Esta ้ Uma Licen็a de DEMONSTRAวรO e Irแ Expirar em "+AllTrim(Str(nDaysLeft))+" dias!" +CHR(13)+CHR(10)+"Entre em contato com a HF - Consulting." +CHR(13)+CHR(10)+;
					"Tel: 11-5524-5124 ou Pelo E-mail comercial@hfbr.com.br."
				Endif
				if lAv
	           		Aviso("Aviso", cMsgAviso,{"OK"},3)
	   			endif
	           	nEnviar := nDaysLeft
	           	if nEnviar == 0
			    	cMsg := "A licen็a de conting๊ncia do Gestใo Xml Protheus irแ expirar amanha!" +CHR(13)+CHR(10)
	           	else
			    	cMsg := "A licen็a de contingencia do Gestใo XML Protheus irแ expirar em "+AllTrim(Str(nEnviar))+" dias!" +CHR(13)+CHR(10)
			    endif
			EndIf
		Else
			cMsgAviso:="Licen็a em contingencia expirada!" +CHR(13)+CHR(10)+"Entre em contato com a HF - Consulting." +CHR(13)+CHR(10)+;
			"Tel: 11-5524-5124 ou Pelo E-mail comercial@hfbr.com.br."
			if lAv
           		Aviso("Aviso", cMsgAviso,{"OK"},3)
   			endif
           	nEnviar := -1 //aquiiiii
		    cMsg    := "Licen็a em contingencia do Gestใo XML Protheus expirada!" +CHR(13)+CHR(10)
		EndIf
	Else
		cMsgAviso:="Licen็a em contingencia invแlida!" +CHR(13)+CHR(10)+"Entre em contato com a HF - Consulting." +CHR(13)+CHR(10)+;
		"Tel: 11-5524-5124 ou Pelo E-mail comercial@hfbr.com.br." 

		if lAv
			Aviso("Aviso", cMsgAviso,{"OK"},3)
		endif
	EndIf

Else

	cMsgAviso:= "Licen็a em conting๊ncia nใo encontrada!" +CHR(13)+CHR(10)+"Entre em contato com a HF - Consulting." +CHR(13)+CHR(10)+;
	"Tel: 11-5524-5124 ou Pelo E-mail comercial@hfbr.com.br."

	if lAv .and. !FWIsInCallStack("U_HFXML02D")
		Aviso("Aviso", cMsgAviso,{"OK"},3)
	endif

EndIf

if lAv
	EmailCom(cCodProd,cCNPJ,cMsg,nEnviar)
endif

Return(lRet)



User Function HFXML00Y(cCodProd,cVersion,cCNPJ,dVencLic,lAv,cExt,cDes,nConMes)
Local lRet      := .F.
Local cChave    := ""
Local cBaseCNPJ := SUBSTR(cCNPJ,1,14) //a partir de 10 de abril chave exclusiva por filial
Local cFileKey  := cCodProd+cBaseCNPJ+"."+cExt
Local cDescPrd  := ""
Local nEnviar   := 99
Local cMsg      := ""
Local nCon      := 0
Default lAv  := .T.
Default cDes := ""
Default nConMes := 0

nConMes := 0  //comecar com zero, caso nใo tenha o retorno ้ zero, caso tenha retorna a quantidade de consultas no mes.                    

if Empty(cDes)
	if cCodProd = "HF000001"
		cDescPrd := 'HF-CONSULTING-XML'
	ElseIf cCodProd == "HF000002"
		cDescPrd := 'HF-CONSULTING-BLK'
	ElseIf cCodProd == "HFSTX001"
		cDescPrd := 'HF-CONSULTING-STX'
	Else
		cDescPrd := 'HF-CONSULTING-XML'
	Endif
Else
	cDescPrd := cDes
Endif

If File(cFileKey)
	cChave := memoRead(cCodProd+cBaseCNPJ+"."+cExt)
	cKey := cCodProd+;
			cBaseCnpj+;
		 	cDescPrd

	cKey := Upper(Sha1(cKey))
	dDateVenc := Stod( Substr(Decode64(Substr(cChave,41)),1,8) )
	nCon      := Val( Substr(Decode64(Substr(cChave,41)),12,6) )
	dVencLic  := dDateVenc
	If Substr(cKey,1,40) == Substr(cChave,1,40)
		If Date() <= dDateVenc
			nConMes := nCon  //S๓ alimenta a quantidade de consultas se a licen็a nใo estiver vencida, do contrario fica zero.
			lRet := .T.
			nDaysLeft := (dDateVenc -Date())
			If nDaysLeft < 30
				cMsgAviso:="A Licen็a irแ expirar em "+AllTrim(Str(nDaysLeft))+" dias!" +CHR(13)+CHR(10)+"Entre em contato com a HF - Consulting." +CHR(13)+CHR(10)+;
				"Tel: 11-5524-5124 ou Pelo E-mail comercial@hfbr.com.br."
				if lAv
	           		Aviso("Aviso", cMsgAviso,{"OK"},3)
	   			endif
	           	nEnviar := nDaysLeft
	           	if nEnviar == 0
			    	cMsg := "A Licen็a "+cDescPrd+" irแ expirar amanha!" +CHR(13)+CHR(10)
	           	else
			    	cMsg := "A Licen็a "+cDescPrd+" irแ expirar em "+AllTrim(Str(nEnviar))+" dias!" +CHR(13)+CHR(10)
			    endif
			EndIf
		Else
			cMsgAviso:="Licen็a expirada!" +CHR(13)+CHR(10)+"Entre em contato com a HF - Consulting." +CHR(13)+CHR(10)+;
			"Tel: 11-5524-5124 ou Pelo E-mail comercial@hfbr.com.br."
			if lAv
           		Aviso("Aviso", cMsgAviso,{"OK"},3)
   			endif
           	nEnviar := -1 //aquiiiii
		    cMsg    := "Licen็a do "+cDescPrd+" expirada!" +CHR(13)+CHR(10)
		EndIf
	Else
		cMsgAviso:="Licen็a invแlida!" +CHR(13)+CHR(10)+"Entre em contato com a HF - Consulting." +CHR(13)+CHR(10)+;
		"Tel: 11-5524-5124 ou Pelo E-mail comercial@hfbr.com.br." 

		if lAv
			Aviso("Aviso", cMsgAviso,{"OK"},3)
		endif
	EndIf

Else

	cMsgAviso:= "Licen็a nใo encontrada!" +CHR(13)+CHR(10)+"Entre em contato com a HF - Consulting." +CHR(13)+CHR(10)+;
	"Tel: 11-5524-5124 ou Pelo E-mail comercial@hfbr.com.br."

	if lAv
		Aviso("Aviso", cMsgAviso,{"OK"},3)
	endif

EndIf

if lAv
	EmailCom(cCodProd,cCNPJ,cMsg,nEnviar)
endif

Return(lRet)



Static Function EmailCom( cCodProd,cCNPJ,cMsg,nEnviar )
Local cBaseCNPJ := SUBSTR(cCNPJ,1,14)  // 8 para 14                 
Local cFileEma  := cCodProd+cBaseCNPJ+".hfe"
Local aTo       := {}
Local cAssunto  := ""
Local cEma      := ""
Local cError    := ""
Local nMsg      := 0
Local cMsgCfg   := ""

if file(cFileEma)
	if nEnviar == 99
		FErase(cFileEma)
	else
		cEma := MemoRead(cFileEma)
		if val(cEma) == -1 //Para enviar somente uma vez depois de expirado
		   nEnviar := 99
		else
			if (val(cEma) - nEnviar) < 10 //Para enviar de 10 em 10 dias
			   if (val(cEma) = nEnviar) .or. nEnviar > 0 //para nใo pular o ultimo dia e o expirado.
			   		nEnviar := 99
			   endif
			endif
		endif
	endif
endif
if nEnviar <> 99
    aTo  := Separa("comercial@hfbr.com.br",";")
    cAssunto := "Aviso de Vencimento de Licen็a "+alltrim(SM0->M0_NOMECOM)
    cMsg += "<br>CNPJ: ("+cCNPJ+") "+transform(cCNPJ, "@R 99.999.999/9999-99")
    cMsg += "<br>Empresa: "+ SM0->M0_NOMECOM
    
    cMsgCfg := ''
    cMsgCfg += '<html xmlns="http://www.w3.org/1999/xhtml">'
	cMsgCfg += '<body>'
	cMsgCfg += '<p>'
	cMsgCfg += cMsg
	cMsgCfg += '</p>'
	cMsgCfg += '</body>'
	cMsgCfg += '</html>'

	nMsg :=	U_MAILSEND(aTo,cAssunto,cMsgCfg,@cError,"","","comercial@hfbr.com.br","","")
	if nMsg == 0
		cEma := AllTrim(Str(nEnviar))
		MemoWrite(cFileEma,cEma)
	endif
endif

Return


Static Function __Dummy(lRecursa) //warning W0010 Static Function <?> never called
    lRecursa := .F.
    IF (lRecursa)
        __Dummy(.F.)
        U_HFXML00X()
        U_HFXML00Y()
	EndIF
Return(lRecursa)
