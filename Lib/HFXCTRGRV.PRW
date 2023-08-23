#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "Ap5Mail.ch"
#INCLUDE "FILEIO.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE 'APWEBSRV.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE "PRTOPDEF.CH"
#INCLUDE "HTTPCLASS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "parmtype.ch"
#INCLUDE "PRCONST.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  HFXCTRGRV  บ Autor ณ Henrique Tofanelli   บ Data ณ  21/07/22 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ CONTROLE CENTRALIZADO DE GRAVAวรO NAS TABELAS ENVOLVIDAS   บฑฑ
ฑฑบ          ณ NA IMPORTAวรO DOS XMLดS BAIXADOS                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ IMPORTA XML                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

/*
								nCodNSU  := aNotas[nX]:NSU
								cChaveXml := aNotas[nX]:CHAVE
								cXmlRet := aNotas[nX]:XML
								cStatus := aNotas[nX]:Status
								cModelo := ALLTRIM(aNotas[nX]:Modelo)
								cChaveArq := cDir + Substr(cChaveXml,1,44) + "-CloudNfe.xml"
*/
User Function HFXCTRGRV(cXmlRet,cModelo,cCnpjEnt,cNumNota,cChaveXml,_cFil,lAppend,cStatus,lResum)

    Local cErro := "", cWarning := ""
    Local cCodEmit 	:= ""
    Local cLojaEmit	:= ""
    Local cRazao   	:= ""
    Local cCfopDoc := Space(15)
    Local cOrigem := "2" //Download Sefaz
    Local cMail10 := GetNewPar("XM_MAIL10",Space(256))  //FR - 21/12/2022 - Flแvia Rocha - EMAIL AVISANDO SOBRE NOVO XML GRAVADO NA BASE
	//Local cMail11 := GetNewPar("XM_MAIL11",Space(256))  //FR - 21/12/2022 - Flแvia Rocha - EMAIL AVISANDO SOBRE NOVA PRE-NOTA

    Private cUf 		:= ""
    Private nUf			:= ""
    Private xZBZ  		:= GetNewPar("XM_TABXML" ,"ZBZ")
    Private xZBZ_ 		:= iif(Substr(xZBZ,1,1)=="S", Substr(xZBZ,2,2), Substr(xZBZ,1,3)) + "_"
    //Private cCnpj		:= ""
    Private cIEXML      := ""
    Private cIE         := ""
    Private cReq		:= ""
    Private nFormNfe 	:= Val(GetNewPar("XM_FORMNFE","9"))
    //Private cXmlRet		:= ""
    Private oXmlRet
    Private aUF			:= {}
    //Private _cFil       := ""
    Private nCodNSU     := 0

    Private cTagProt   := ""
    Private cTagMoti   := ""
    Private cTagAux    := ""
    Private cTagVerXml := ""
    Private cCnpj		:= ""
    //Private cIE         := ""

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


    IF lResum
    //========================================================================
        // CONDIวรO GERAL PARA NFE RESUMIDA
    //========================================================================

        _cFil := xFilial(xZBZ)


        oXmlRet := XmlParser( cXmlRet ,"_",@cErro, @cWarning )

        if Empty( oXmlRet )

            cXmlRet := U_HFAjuXML(cXmlRet)

            oXmlRet := XmlParser( cXmlRet ,"_",@cErro, @cWarning )

        endif

        If ( oXmlRet == NIL )

            oXmlRet := NIL
            FreeObj(oXmlRet)
            MsgStop("Falha ao gerar Objeto XML : "+cErro+" / "+cWarning)
            Return

        Endif

        nUf	:= aScan(aUF,{|x| x[2] == Substr(cChaveXml,1,2) })
        cUf := aUF[nUf][1]

        lTransf  := .F.  //Incluso melhoria ECOURBIS - Analista Alexandro / Eneo

        cSeriNF := verSerie( Substr(cChaveXml,23,3), cFilAnt, lTransf )

        Reclock(xZBZ,lAppend)

        (xZBZ)->(FieldPut(FieldPos(xZBZ_+"CHAVE"), cChaveXml))  //Colocado no ํnicio como prioridade de grava็ใo

        (xZBZ)->(FieldPut(FieldPos(xZBZ_+"FILIAL"), _cFil))

        cNumNota := Substr(cChaveXml,26,9)

        //Gambiarra executada para contornar bug do STRZERO
        //STRZERO(31492,0) Retornava "0000031492"
        (xZBZ)->(FieldPut(FieldPos(xZBZ_+"NOTA"), U_NUMNOTA(cNumNota,nFormNfe) ))

        (xZBZ)->(FieldPut(FieldPos(xZBZ_+"SERIE"), cSeriNF))

        (xZBZ)->(FieldPut(FieldPos(xZBZ_+"UF"), cUf))

        (xZBZ)->(FieldPut(FieldPos(xZBZ_+"CNPJ"), cCnpjEnt))

        (xZBZ)->(FieldPut(FieldPos(xZBZ_+"CNPJD"), cCnpj))

        (xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPDOWL"), "R" ))
        (xZBZ)->(FieldPut(FieldPos(xZBZ_+"PRENF"), 'B' ))

        //        (xZBZ)->(FieldPut(FieldPos(xZBZ_+"PRENF"), VerStat( cFilAnt, (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNF"))), U_vSerie( cSerXMl, cFilAnt, .F. ), cCodEmit+cLojaEmit, "N", cNewKey )  ))
        (xZBZ)->(FieldPut(FieldPos(xZBZ_+"STATUS"), "1"))
        (xZBZ)->(FieldPut(FieldPos(xZBZ_+"XMLRES"), cXmlRet ))
        (xZBZ)->(FieldPut(FieldPos(xZBZ_+"VERSAO"), "4.00"))
        //        cLogProc += "[XML] Resumido "+cNewKey+" importado com sucesso."+CRLF

        If Type("oXmlRet:_RESNFE:_DHEMI:TEXT") <> "U"
            (xZBZ)->(FieldPut(FieldPos(xZBZ_+"DTNFE"), VerData(oXmlRet:_RESNFE:_DHEMI:TEXT) ))
        Endif

        If Type("oXmlRet:_RESNFE:_VNF:TEXT") <> "U"
            ( xZBZ )->(FieldPut(FieldPos(xZBZ_+"VLLIQ"), Val(oXmlRet:_RESNFE:_VNF:TEXT) ))
        Endif

        //If Type("oXmlRet:_RESNFE:_XNOME:TEXT") <> "U"
        //    ( xZBZ )->(FieldPut(FieldPos(xZBZ_+"XNOME"), oXmlRet:_RESNFE:_XNOME:TEXT ))
        //Endif

        //If Type("oXmlRet:_RESNFE:_IE:TEXT") <> "U"
         //   ( xZBZ )->(FieldPut(FieldPos(xZBZ_+"IE"),  oXmlRet:_RESNFE:_IE:TEXT ))
        //Endif

        cDigVal := ""
        If Type("oXmlRet:_RESNFE:_DIGVAL:TEXT") <> "U"
            cDigVal := oXmlRet:_RESNFE:_DIGVAL:TEXT
        EndIf

        cProtocolo := ""
        If Type("oXmlRet:_RESNFE:_NPROT:TEXT") <> "U"
            cProtocolo := oXmlRet:_RESNFE:_NPROT:TEXT
            (xZBZ)->(FieldPut(FieldPos(xZBZ_+"PROT"), cProtocolo))
        EndIf


        If Type("oXmlRet:_RESNFE:_DHRECBTO:TEXT") <> "U"
            ( xZBZ )->(FieldPut(FieldPos(xZBZ_+"DHRECB"), VerData(oXmlRet:_RESNFE:_DHRECBTO:TEXT) ))
        Endif


        (xZBZ)->(FieldPut(FieldPos(xZBZ_+"MODELO"), cModelo))

        (xZBZ)->(FieldPut(FieldPos(xZBZ_+"DTRECB"), dDataBase))


        cMotivo := "Baixa de NFe Resumida"
        //TRATATIVA PARA GRAVAวรO DA OBS

        cRet := "Chave: " + cChaveXml + CRLF
        cRet += "Modelo: " + cModelo + CRLF
        cRet += "Versใo da mensagem: " + "" + CRLF
        //    cRet += "Ambiente: " + iif(cTagTpAmb == "1","Produ็ใo","Homologa็ใo") + CRLF
        cRet += "Protocolo: " + cProtocolo +  CRLF
        cRet += "Status: "+ cStatus + CRLF
        cRet += "Motivo: " + cMotivo + CRLF
        cRet += "Digest Value: " + cDigVal + CRLF


        (xZBZ)->(FieldPut(FieldPos(xZBZ_+"OBS"), cRet))

        MsUnLock()        

        oXmlRet := NIL
        FreeObj(oXmlRet)

    ELSE

    //========================================================================
    // CONDIวรO GERAL PARA NFE
    //========================================================================

        IF cModelo == '55'

            cTGP := "NFE"
            cTAG := "NFE"

            //Verifica dados no SIGAMAT, inscri็ใo municipal nใo obrigat๓ria, monitorar pq jah deu problema passando inscri็ใo HMS
            cCnpj 	:= Alltrim(FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , { "M0_CGC" } )[1][2])
            cIE     := Alltrim(FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , { "M0_INSC" } )[1][2])


            oXmlRet := XmlParser( cXmlRet ,"_",@cErro, @cWarning )

            if Empty( oXmlRet )

                cXmlRet := U_HFAjuXML(cXmlRet)

                oXmlRet := XmlParser( cXmlRet ,"_",@cErro, @cWarning )

            endif

            If ( oXmlRet == NIL )

                oXmlRet := NIL
                FreeObj(oXmlRet)
                MsgStop("Falha ao gerar Objeto XML : "+cErro+" / "+cWarning)
                Return

            Endif

        If Type( "oXmlRet:_NFEPROC:_NFE:_INFNFE:_DEST:_IE:TEXT" ) <> "U"
            cIEXML := oXmlRet:_NFEPROC:_NFE:_INFNFE:_DEST:_IE:TEXT
        EndIF

        if !Empty( cIEXML )

            _cFil := u_Gravafil( cCnpj, cIEXML )

            if Empty( xFilial(xZBZ) )
                _cFil := xFilial(xZBZ)
            endif

        else
            _cFil := xFilial(xZBZ)
        endif

        cFilant := _cFil

        If !Empty( oXmlRet )   //oXmlRet:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ:TEXT = cCnpj

            //SAVE oXmlRet XMLFILE cChaveArq
            HFGRVXML( @oXmlRet, cChaveXml, cModelo )

            nUf	:= aScan(aUF,{|x| x[2] == oXmlRet:_NFEPROC:_NFE:_INFNFE:_IDE:_CUF:TEXT })
            cUf := aUF[nUf][1]

            Reclock(xZBZ,lAppend)

            (xZBZ)->(FieldPut(FieldPos(xZBZ_+"CHAVE"), cChaveXml))  //Colocado no ํnicio como prioridade de grava็ใo
            (xZBZ)->(FieldPut(FieldPos(xZBZ_+"FILIAL"), _cFil))

            MsUnLock()

            //TRATATIVA SERIE
            cTagSerXml := "oXmlRet:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_IDE:_SERIE:TEXT"
            if !Empty(cTagSerXml)
                cSerXml := &(cTagSerXml)
            else
                cSerXml := ""
            endif

            //Altera็ใo para ITAMBษ 15/10/2014 - Alexandro de Oliveira
            if ( GetNewPar("XM_SERXML","N") == "S" )

                if alltrim( cSerXml ) == '0' .or. alltrim( cSerXml ) == '00' .or. alltrim( cSerXml ) == '000'
                    cSerXml := '   '
                EndIf

            elseIf ( GetNewPar("XM_SERXML","N") == "Z" )

                If Empty(cSerXml)
                    cSerXml := '0'
                Endif

            endif

            Reclock(xZBZ,.F.)



            cFinalidad :=  oXmlRet:_NFEPROC:_NFE:_INFNFE:_IDE:_FINNFE:TEXT


            lTransf  := .F.  //Incluso melhoria ECOURBIS - Analista Alexandro / Eneo
            //cTipoDoc := RetTpNf(cModelo, oXml, @lTransf, cFinalidad, @cCfopDoc) //Incluso melhoria ECOURBIS - Analista Alexandro / Eneo
            cTipoDoc := U_RetTpNf(cModelo,oXmlRet,@lTransf,cFinalidad,@cCfopDoc)
            BuscaEntidade(cCnpjEnt,@cCodEmit,@cLojaEmit,@cRazao)

            cSerXMl := oXmlRet:_NFEPROC:_NFE:_INFNFE:_IDE:_SERIE:TEXT
            cSeriNF := verSerie( cSerXMl, cFilAnt, lTransf )

            //FR - 22/12/2022 - TRATAMENTO PARA PEGAR A RAZรO SOCIAL QUANDO A FUNวรO BUSCAENTIDADE NรO CONSEGUIU LOCALIZAR O CAD. FORNECEDOR
            If Empty(cRazao)
                If  Type( "oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_EMIT:_XNOME:TEXT" ) <> "U"
                    cRazao := Alltrim( &("oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_EMIT:_XNOME:TEXT") )
                Endif 
            Endif 
            //FR - 22/12/2022 - TRATAMENTO PARA PEGAR A RAZรO SOCIAL QUANDO A FUNวรO BUSCAENTIDADE NรO CONSEGUIU LOCALIZAR O CAD. FORNECEDOR


            If Type("oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_DEST:_CNPJ:TEXT") <> "U"
                cCnpjDest := oXmlRet:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ:TEXT
            else
                If Type("oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_DEST:_CPF:TEXT") <> "U"
                    cCnpjDest := oXmlRet:_NFEPROC:_NFE:_INFNFE:_DEST:_CPF:TEXT
                else
                    cCnpjDest := ""
                endif

            endif

            (xZBZ)->(FieldPut(FieldPos(xZBZ_+"CNPJ"), cCnpjEnt))
            //(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CNPJD"), oXmlRet:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ:TEXT))
            (xZBZ)->(FieldPut(FieldPos(xZBZ_+"CNPJD"), cCnpjDest))
            (xZBZ)->(FieldPut(FieldPos(xZBZ_+"CLIENT"), oXmlRet:_NFEPROC:_NFE:_INFNFE:_DEST:_XNOME:TEXT))
            //(xZBZ)->(FieldPut(FieldPos(xZBZ_+"SERIE"), oXmlRet:_NFEPROC:_NFE:_INFNFE:_IDE:_SERIE:TEXT ))
            (xZBZ)->(FieldPut(FieldPos(xZBZ_+"SERIE"), cSeriNF ))
            (xZBZ)->(FieldPut(FieldPos(xZBZ_+"NOTA"), U_NumNota(cNumNota,nFormNfe) ))
            (xZBZ)->(FieldPut(FieldPos(xZBZ_+"FORNEC"), cRazao ))
            (xZBZ)->(FieldPut(FieldPos(xZBZ_+"CFOP"), cCfopDoc ))
            (xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPDOC"), cTipoDoc))
            (xZBZ)->(FieldPut(FieldPos(xZBZ_+"MODELO"), cModelo))
            (xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPDOWL"), "" ))

            //grava tipo da rotina: M-Manual ; J-Job aqui no caso ้ Manual
            _TpRot := ""

            If IsBlind()
                _TpRot := "J"
            else
                _TpRot := "M"
            ENDIF

            (xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPROT"), _TpRot ))		//GRAVAR COMO M-Manual, pois esta rotina ้ chamada manualmente pelo usuแrio

            //Tratativa de Versใo
            cVerXml := ""
            cTagVerXml :=  "oXmlRet:_NFEPROC:_NFE:_INFNFE:_VERSAO:TEXT" //"oXmlRet:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_VERSAO:TEXT"

            If Type(cTagVerXml) <> "U"

                cVerXml := &(cTagVerXml)
            ENDIF

            If (xZBZ)->(FieldPos(xZBZ_+"VERSAO")) > 0
                (xZBZ)->(FieldPut(FieldPos(xZBZ_+"VERSAO"), cVerXml))
            EndIf

            nBASCAL := val(oXmlRet:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VBC:TEXT)
            nICMVAL := val(oXmlRet:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VICMS:TEXT)
            nICMDES := val(oXmlRet:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VICMSDESON:TEXT)
            nSTBASE := val(oXmlRet:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VBCST:TEXT)
            nSTVALO := val(oXmlRet:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VST:TEXT)
            nIPIVAL := val(oXmlRet:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VIPI:TEXT)
            nIPIDEV := val(oXmlRet:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VIPIDEVOL:TEXT)
            nPISVAL := val(oXmlRet:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VPIS:TEXT)
            nCOFVAL := val(oXmlRet:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VCOFINS:TEXT)
            nOUTVAL := val(oXmlRet:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VOUTRO:TEXT)

            //TRATAMENTO IMPOSTOS - AUDITORIA
            (xZBZ)->(FieldPut(FieldPos(xZBZ_+"BASCAL"), nBASCAL))
            (xZBZ)->(FieldPut(FieldPos(xZBZ_+"ICMVAL"), nICMVAL))
            (xZBZ)->(FieldPut(FieldPos(xZBZ_+"ICMDES"), nICMDES))
            (xZBZ)->(FieldPut(FieldPos(xZBZ_+"STBASE"), nSTBASE))
            (xZBZ)->(FieldPut(FieldPos(xZBZ_+"STVALO"), nSTVALO))
            (xZBZ)->(FieldPut(FieldPos(xZBZ_+"IPIVAL"), nIPIVAL))
            (xZBZ)->(FieldPut(FieldPos(xZBZ_+"IPIDEV"), nIPIDEV))
            (xZBZ)->(FieldPut(FieldPos(xZBZ_+"PISVAL"), nPISVAL))
            (xZBZ)->(FieldPut(FieldPos(xZBZ_+"COFVAL"), nCOFVAL))
            (xZBZ)->(FieldPut(FieldPos(xZBZ_+"OUTVAL"), nOUTVAL))


            //CAMPO OBSERVAวรO
            /*
            if Type("oXmlRet:_RETCONSSITNFE:_PROTNFE:_INFPROT:_CHNFE:TEXT") <> "U"

                lRet := .T.

                cChave  := oXmlRet:_RETCONSSITNFE:_PROTNFE:_INFPROT:_CHNFE:TEXT
                cVersao := oXmlRet:_RETCONSSITNFE:_VERSAO:TEXT
                cStatus := oXmlRet:_RETCONSSITNFE:_PROTNFE:_INFPROT:_CSTAT:TEXT
                cTpAmb  := oXmlRet:_RETCONSSITNFE:_PROTNFE:_INFPROT:_TPAMB:TEXT
                cMotivo := oXmlRet:_RETCONSSITNFE:_PROTNFE:_INFPROT:_XMOTIVO:TEXT
                cProt   := oXmlRet:_RETCONSSITNFE:_PROTNFE:_INFPROT:_NPROT:TEXT
                cDigVal := oXmlRet:_RETCONSSITNFE:_PROTNFE:_INFPROT:_DIGVAL:TEXT

                cCodRet := cStatus

                cNewRet := "Protocolo: " + cProt + CRLF
                cNewRet += "Digito: " + cDigVal + CRLF

                cModelo := "55"

                cRet := "Chave: " + cChave + CRLF
                cRet += "Versใo da mensagem: " + cVersao + CRLF
                cRet += "Ambiente: " + iif(cTpAmb == "1","Produ็ใo","Homologa็ใo") + CRLF
                cRet += "Cod. Ret. " + cModelo + ": " + cStatus + CRLF
                cRet += "Msg. Ret. " + cModelo + ": " + cMotivo + CRLF
                cRet += cNewRet


                (xZBZ)->(FieldPut(FieldPos(xZBZ_+"OBS"), cRet))

                //if lShowMsg

                //	u_MyAviso("u_XConsXml - Consulta",cRet,{"OK"},3)

                //endif

            Endif
            */

            //FR - 28/04/2021 - NOVA TELA GESTรOXML - GRAVAR NOVO CAMPO ZBZ_ICOMPL - informa็๕es complementares
            xInfoCompl := ""
            //xModelo    := Substr(cNewKey,21,2)
            xInfoCompl := U_fInfoCompl(cModelo,cXmlRet)
            If xInfoCompl <> Nil
                (xZBZ)->(FieldPut(FieldPos(xZBZ_+"ICOMPL"), xInfoCompl ))
            ENDIF


            if Empty(  (xZBZ)->(FieldGet(FieldPos(xZBZ_+"DTRECB")))  )   //Gravar s๓ se Tiver Vazio
                (xZBZ)->(FieldPut(FieldPos(xZBZ_+"DTRECB"), dDataBase))
            endif

            dEmissao	:= stod(;
                substr(oXmlRet:_NFEPROC:_NFE:_INFNFE:_IDE:_DHEMI:TEXT,1,4)+;
                substr(oXmlRet:_NFEPROC:_NFE:_INFNFE:_IDE:_DHEMI:TEXT,6,2)+;
                substr(oXmlRet:_NFEPROC:_NFE:_INFNFE:_IDE:_DHEMI:TEXT,9,2);
                )

            (xZBZ)->(FieldPut(FieldPos(xZBZ_+"DTNFE"), dEmissao ))
            (xZBZ)->(FieldPut(FieldPos(xZBZ_+"XML"), cXmlRet))

            if cStatus <> "101"  //se for diferente de cancelado

                if lAppend

                    (xZBZ)->(FieldPut(FieldPos(xZBZ_+"PRENF"), "B"))
                    (xZBZ)->(FieldPut(FieldPos(xZBZ_+"STATUS"), "1"))

                endif

            else

                (xZBZ)->(FieldPut(FieldPos(xZBZ_+"PRENF"), "X"))
                (xZBZ)->(FieldPut(FieldPos(xZBZ_+"STATUS"), "2"))

            ENDIF

            if (xZBZ)->(FieldPos(xZBZ_+"MANIF")) > 0   // .And. ! Empty(xManif) //GETESB2
                cRet := U_HFMANZBS( AllTrim( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))) ), "", cOrigem )
              
                if !Empty( cRet )

                    (xZBZ)->(FieldPut(FieldPos(xZBZ_+"MANIF"), cRet ))

                endif
            endif

            //(xZBZ)->(FieldPut(FieldPos(xZBZ_+"OBS"), ""))
            //(xZBZ)->(FieldPut(FieldPos(cTipoDoc), cModelo))
            (xZBZ)->(FieldPut(FieldPos(xZBZ_+"CODFOR"), cCodEmit))
            //(xZBZ)->(FieldPut(FieldPos(xZBZ_+"INDRUR"), cIndRur))
            (xZBZ)->(FieldPut(FieldPos(xZBZ_+"LOJFOR"), cLojaEmit))
            (xZBZ)->(FieldPut(FieldPos(xZBZ_+"UF"), cUf ))
            (xZBZ)->(FieldPut(FieldPos(xZBZ_+"SERORI"), cSerXMl))


            If (xZBZ)->(FieldPos(xZBZ_+"FORPAG"))>0    //GETESB

                cTagTpPag  := "oXmlRet:_NFEPROC:_NFE:_INFNFE:_IDE:_FORPAG:TEXT"

                if Type( cTagTpPag ) <> "U"
                    (xZBZ)->(FieldPut(FieldPos(xZBZ_+"FORPAG"), &(cTagTpPag) ))
                else
                    (xZBZ)->(FieldPut(FieldPos(xZBZ_+"FORPAG"), "1" ))
                endif

            Endif


            If (xZBZ)->(FieldPos(xZBZ_+"CONDPG"))>0    //GETESB
                (xZBZ)->(FieldPut(FieldPos(xZBZ_+"CONDPG"), U_HF02CPG() ))
            EndIf


            cTagTpEmiss:= "oXmlRet:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_IDE:_TPEMIS:TEXT"
            cTagTpAmb  := "oXmlRet:_"+cTGP+"PROC:_"+cTGP+":_INF"+cTAG+":_IDE:_TPAMB:TEXT"

            If (xZBZ)->(FieldPos(xZBZ_+"TPEMIS"))>0 .And. (xZBZ)->(FieldPos(xZBZ_+"TPAMB")) > 0

                if Type( cTagTpEmiss ) <> "U" .And. !Empty(cTagTpEmiss)
                    (xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPEMIS"), &(cTagTpEmiss) ))
                Endif

                if Type( cTagTpAmb ) <> "U" .And. !Empty(cTagTpAmb)
                    (xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPAMB"), &(cTagTpAmb) ))
                EndIF

            EndIf

            cTagProt   := "oXmlRet:_"+cTGP+"PROC:_PROT"+cTAG+":_INFPROT:_NPROT:TEXT"

            if Type(cTagProt) <> "U"

                cProtocolo := &(cTagProt)

            endif

            If (xZBZ)->(FieldPos(xZBZ_+"PROT")) > 0
                (xZBZ)->(FieldPut(FieldPos(xZBZ_+"PROT"), cProtocolo))
            EndIf

            /*
        If (xZBZ)->(FieldPos(xZBZ_+"TOMA")) > 0 .And. (xZBZ)->(FieldPos(xZBZ_+"DTHRCS")) > 0

            (xZBZ)->(FieldPut(FieldPos(xZBZ_+"TOMA"), cTipoToma))
            (xZBZ)->(FieldPut(FieldPos(xZBZ_+"DTHRCS"), cDtHrCOns))

        EndIf
            */
            nVLLIQ  := 0
            cTagAux := "oXmlRet:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_vProd:TEXT"

            if type(cTagAux) <> "U"
                nVLLIQ := noRound( Val( &(cTagAux) ), 2)
            endif

            nVLDESC := 0
            cTagAux := "oXmlRet:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_vDesc:TEXT"

            if type(cTagAux) <> "U"
                nVLDESC := noRound( Val( &(cTagAux) ), 2)
            endif

            nVLIMP := 0
            cTagAux := "oXmlRet:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_vST:TEXT"
            if type(cTagAux) <> "U"
                nVLIMP += noRound( Val( &(cTagAux) ), 2 )
            endif

            cTagAux := "oXmlRet:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_vII:TEXT"
            if type(cTagAux) <> "U"
                nVLIMP += noRound( Val( &(cTagAux) ), 2 )
            endif

            cTagAux := "oXmlRet:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_vIPI:TEXT"
            if type(cTagAux) <> "U"
                nVLIMP += noRound( Val( &(cTagAux) ), 2 )
            endif

            nVLBRUT  := 0
            cTagAux := "oXmlRet:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VNF:TEXT"
            if type(cTagAux) <> "U"
                nVLBRUT := noRound( Val( &(cTagAux) ), 2)
            endif

            if (xZBZ)->(FieldPos(xZBZ_+"VLLIQ")) > 0
                (xZBZ)->(FieldPut(FieldPos(xZBZ_+"VLLIQ"), nVLLIQ ))
            endif

            if (xZBZ)->(FieldPos(xZBZ_+"VLDESC")) > 0
                (xZBZ)->(FieldPut(FieldPos(xZBZ_+"VLDESC"), nVLDESC ))
            endif

            if (xZBZ)->(FieldPos(xZBZ_+"VLIMP")) > 0
                (xZBZ)->(FieldPut(FieldPos(xZBZ_+"VLIMP"), nVLIMP ))
            endif

            if (xZBZ)->(FieldPos(xZBZ_+"VLBRUT")) > 0
                (xZBZ)->(FieldPut(FieldPos(xZBZ_+"VLBRUT"), nVLBRUT ))
            endif

            //Motivo
            cMotivo := ""
            cTagMoti   := "oXmlRet:_"+cTGP+"PROC:_PROT"+cTAG+":_INFPROT:_XMOTIVO:TEXT"

            if Type(cTagMoti) <> "U"
                cMotivo := &(cTagMoti)
            endif

            //DigVal
            cDigVal := ""
            cTagMoti   := "oXmlRet:_"+cTGP+"PROC:_PROT"+cTAG+":_INFPROT:_DIGVAL:TEXT"

            if Type(cTagMoti) <> "U"
                cDigVal := &(cTagMoti)
            endif


            //TRATATIVA PARA GRAVAวรO DA OBS

            cRet := "Chave: " + cChaveXml + CRLF
            cRet += "Modelo: " + cModelo + CRLF
            cRet += "Versใo da mensagem: " + cVerXml + CRLF
            cRet += "Ambiente: " + iif(cTagTpAmb == "1","Produ็ใo","Homologa็ใo") + CRLF
            cRet += "Protocolo: " + cProtocolo +  CRLF
            cRet += "Status: "+ cStatus + CRLF
            cRet += "Motivo: " + cMotivo + CRLF
            cRet += "Digest Value: " + cDigVal + CRLF


            (xZBZ)->(FieldPut(FieldPos(xZBZ_+"OBS"), cRet))
            DbSelectArea(xZBZ)
            MsUnLock()

            U_fGravaZBT(cXmlRet,cModelo,cChaveXml,strZero(cNumNota,nFormNfe),cSeriNF,cCnpjEnt)
  
            //----------------------------------------------------------------------------------------------------//
            //FR - 22/12/2022 - PROJETO BRASMOLDE - NOTIFICAวีES POR EMAIL QDO BAIXA XML
            //Depois de Gravar ZBZ e ZBT aciona rotina que dispara email caso esteja parametrizado para receber
            //----------------------------------------------------------------------------------------------------//
            If lAppend  //s๓ processa se for inclusใo (caso jแ tenha sido gravado via rotina HFXML02, nใo entra aqui)
                cMail10 := GetNewPar("XM_MAIL10",Space(256))  //FR - 21/12/2022 - Flแvia Rocha - EMAIL AVISANDO SOBRE NOVO XML GRAVADO NA BASE	
                cCfBenef:= Padr(GetNewPar("XM_CFBENEF",Space(256)),256)	
                cCfDevol:= Padr(GetNewPar("XM_CFDEVOL",Space(256)),256)

                If !Empty(cMail10) //emails que receberใo notifica็ใo qdo gravar xml na base
                    
                    cFornec  := ""
                    cLojFor  := ""
                    cNomeFor := ""
                    nFormNfe := Val(GetNewPar("XM_FORMNFE","9"))

                    //cAssunto := "Nota Fiscal Nใo Importada Com Sucesso"
                    cAssunto := "Importa็ใo NFe: " + StrZero(cNumNota,nFormNfe) + "/" + cSeriNF
                    cTipo    := "1"  //download ok

                    aMsg     := {}			
                    cFornec  := cCodEmit //Posicione("SA2",3,xFilial("SA2")+ cCnpjEnt,"A2_COD")
                    cLojFor  := cLojaEmit //Posicione("SA2",3,xFilial("SA2")+ cCnpjEnt,"A2_LOJA")
                    
                    If cCfopDoc $ cCfBenef  //se o CFOP do XML estแ contido em CFOPs de beneficiamento, pega do cad. cliente:
                        cNomeFor := Posicione("SA1",1,xFilial("SA1")+ cFornec + cLojFor,"A1_NOME")
                        cTpCliFor:= "Cliente"

                    Elseif cCfopDoc $ cCfDevol  //se o CFOP do XML estแ contido em CFOPs de devolu็ใo, pega do cad. cliente:
                        cNomeFor := Posicione("SA1",1,xFilial("SA1")+ cFornec + cLojFor,"A1_NOME")
                        cTpCliFor:= "Cliente"
                    Else
                        cNomeFor := Posicione("SA2",1,xFilial("SA2")+ cFornec + cLojFor,"A2_NOME")
                        cTpCliFor:= "Fornecedor"
                    Endif
                    cAssunto += " - Forn: " + cFornec + "/" + cLojFor + "-" + cNomeFor + " - PENDENTE"
                    
                    U_FNOTIFICA(cMail10,cTipo,cFornec, cLojfor, cNomeFor,cRazao,cCnpjEnt,cNumNota,cSeriNF,nFormNfe,dEmissao,cMotivo,cTAG,cChaveXml,cTpCliFor)
                    
                    /*
                    //MODELO
                    Assunto  - Nota Fiscal nใo importada com sucesso 
                    Conte๚do 
                    Fornecedor......: 000996 - TE CONNECTIVITY BRASIL IN
                    Nota Fiscal.....: 000196943/1 - Emissใo: 19/04/2021
                    Chave da NFe....: 35210400907845001560550010001969431286545563
                    Situa็ใo SEFAZ..: 100 - Autorizado o uso da NF-e
                    */ 
                Endif 
            Endif 
            //FR - 22/12/2022 - PROJETO BRASMOLDE - NOTIFICAวีES POR EMAIL QDO BAIXA XML

        EndIf

    ENDIF

    ENDIF
Return




//**********************************************************************************************************
Static Function HFGRVXML( oXmlRet, cChaveXml, cModelo )
    //**********************************************************************************************************

    Local cDir     := "\"+AllTrim(GetNewPar("MV_X_PATHX",""))+"\"
    Local lDirCnpj := AllTrim(GetNewPar("XM_DIRCNPJ","N")) == "S"
    Local lDirFil  := AllTrim(GetNewPar("XM_DIRFIL" ,"N")) == "S"
    Local lDirMod  := AllTrim(GetNewPar("XM_DIRMOD" ,"N")) == "S"
    Local cDirDest := AllTrim(cDir+"Importados\")
    Local cDirRej  := AllTrim(cDir+"Rejeitados\")
    Local cDirCfg  := AllTrim(cDir+"Cfg\")

    Local cFilXml  := _cFil   //cFilAnt
    Local cChaveArq := ""

    Local cKeyXml  := cChaveXml
    Local cPref    := "XXX"

    Static lUnix  := IsSrvUnix()
    Static cBarra := Iif(lUnix,"/","\")

    //Aqui estava antes disso, direto no procxml. La ficou s๓ o FOR e aqui ้ um a um.
    DbSelectArea("SM0")
    nRecFil := Recno()

    //Private aFilsEmp := U_XGetFilS(SM0->M0_CGC,@aFilsLic)

    if empty(cFilXml)
        cFilXml := "XX"
    endif

    lCCe      := .F.
    lXmlsLic  := .F.


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


    If cModelo $ "55,65"

        cPref := iif( cModelo == "55", "NFE", "NFCE" )


    ElseIf cModelo $ "57,67"

        cPref := iif( cModelo == "57", "CTE", "CTEOS" )

    EndIf


    If lDirMod

        _cDirRej := _cDirRej + cPref + iif(lCCe,"CCe","") +cBarra
        _cDirDest:= _cDirDest + cPref + iif(lCCe,"CCe","") +cBarra

        If !ExistDir(_cDirDest)
            Makedir(_cDirDest)
        EndIf

        If !ExistDir(_cDirRej)
            Makedir(_cDirRej)
        EndIf

    EndIf

    If lDirFil

        _cDirRej := _cDirRej + cFilXml+cBarra
        _cDirDest:= _cDirDest + cFilXml+cBarra

        If !ExistDir(_cDirDest)
            Makedir(_cDirDest)
        EndIf

        If !ExistDir(_cDirRej)
            Makedir(_cDirRej)
        EndIf

    EndIf

    If lDirCnpj

        cCnpjEmit := Substr(cKeyXml,7,14)
        _cDirRej := _cDirRej + cCnpjEmit+cBarra
        _cDirDest:= _cDirDest + cCnpjEmit+cBarra

        If !ExistDir(_cDirDest)
            Makedir(_cDirDest)
        EndIf

        If !ExistDir(_cDirRej)
            Makedir(_cDirRej)
        EndIf

    EndIf


    cChaveArq := _cDirDest + Substr(cChaveXml,1,44) + "-CloudNfe.xml"
    //raiz    cChaveArq := cDir + Substr(cChaveXml,1,44) + "-CloudNfe.xml"
    SAVE oXmlRet XMLFILE cChaveArq

Return( .T. )



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ              บ Autor ณ Eneovaldo Roveri Jrบ Data ณ             บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Retorna o S้rie de acordo com a GRABER.                        บฑฑ
ฑฑบ          ณ                                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Importa XML                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function verSerie( cSerXMl, cFilAnt, lTransf )

    Local cRet := cSerXMl
    Local cSrr := AllTrim(GetNewPar("XM_SEREMP",""))
    Local aSrr := Separa(cSrr,";")
    Local nI   := 0
    Local cAux := ""
    Local cContem	:= SuperGetMv("XM_FORMSER",.T.,"0")    // Incluido dia 17/05/2016

    If .Not. empty( cSrr )

        if ";" $ cSrr .or. "," $ cSrr

            For nI := 1 To len( aSrr )

                if cFilAnt $ aSrr[nI]

                    cAux := Substr( aSrr[nI], 1, AT("=",aSrr[nI] )-1 )
                    cAux := AllTRim( cAux )

                    if len( cAux ) >= 1 .and. len( cAux ) <= 3
                        cRet := cAux
                        Exit
                    endif

                endif

            Next nI

        Else

            cRet := cSrr

        Endif

    Else

        If lTransf .or. cContem <> "0"  //Incluso melhoria ECOURBIS - Analista Alexandro / Eneo

            If AllTrim(cContem)=="0"//(Val(SuperGetMV('XM_FORMSER','0'))==0), Alterado

                cRet 	:= cSerXML

            ElseIf AllTrim(cContem)=="2"//(Val(SuperGetMV('XM_FORMSER','0'))==2), Alterado

                If len( Alltrim(cSerXML) ) <= 2
                    cRet	:= cValToChar(StrZero( Val(cSerXML),2))
                EndIf

            ElseIf AllTrim(cContem)=="3"//(Val(SuperGetMV('XM_FORMSER','0'))==3), Alterado

                If len( Alltrim(cSerXML) ) <= 3
                    cRet	:= cValToChar(StrZero(Val( cSerXML ),3))
                EndIf

            EndIf

        EndIf

    EndIf

Return( cRet )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ  BuscaEntidade  บAutor  ณ HF          บ Data ณ 02/05/2022  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verificar c๓digo do fornecedor.                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Importa XML                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function BuscaEntidade(cCnpjEmi,cCodEmit,cLojaEmit,cRazao)

    Local aArea     := GetArea()
    Local cFilSeek  := ""
    /*
    DbSelectArea("SA2")
    DbSetOrder(3)
    cFilSeek := xFilial("SA2")

    If DbSeek(cFilSeek+cCnpjEmi)
        cCodEmit  := SA2->A2_COD
        cLojaEmit := SA2->A2_LOJA
        cRazao    := SA2->A2_NOME
        Do While .not. SA2->( eof() ) .and. SA2->A2_FILIAL == cFilSeek .and.;
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
    */

    If cTipoDoc $ "D|B"

        DbSelectArea("SA1")
        DbSetOrder(3)

        cFilSeek := xFilial("SA1") //Iif(lSharedA1,xFilial("SA1"),cFilNova)

        If .Not. Empty(cCnpjEmi) .And. DbSeek(cFilSeek+cCnpjEmi)

            cCodEmit  := SA1->A1_COD
            cLojaEmit := SA1->A1_LOJA
            cRazao    := SA1->A1_NOME
            cIndRur   := ""

            Do While .not. SA1->( eof() ) .and. SA1->A1_FILIAL == cFilSeek .and.;
                    SA1->A1_CGC == cCnpjEmi

                if SA1->A1_MSBLQL != "1"
                    cCodEmit  := SA1->A1_COD
                    cLojaEmit := SA1->A1_LOJA
                    cRazao    := SA1->A1_NOME
                    exit
                endif

                SA1->( dbSkip() )

            EndDo

        Else

            cCodEmit  := ""
            cLojaEmit := ""
            cRazao    := ""
            cIndRur   := ""

        EndIf

    Else

        DbSelectArea("SA2")
        DbSetOrder(3)
        cFilSeek := xFilial("SA2") //Iif(lSharedA2,xFilial("SA2"),cFilNova)

        If .Not. Empty(cCnpjEmi) .And. DbSeek(cFilSeek+cCnpjEmi)

            if !Empty(SA2->A2_CGC)

                cCodEmit  := SA2->A2_COD
                cLojaEmit := SA2->A2_LOJA
                cRazao    := SA2->A2_NOME
                cIndRur   := SA2->A2_INDRUR

            endif

            Do While .not. SA2->( eof() ) .and. SA2->A2_FILIAL == cFilSeek .and.;
                    SA2->A2_CGC == cCnpjEmi

                if SA2->A2_MSBLQL != "1" .And. !Empty(SA2->A2_CGC)

                    cCodEmit  := SA2->A2_COD
                    cLojaEmit := SA2->A2_LOJA
                    cRazao    := SA2->A2_NOME
                    cIndRur   := SA2->A2_INDRUR
                    exit

                endif

                SA2->( dbSkip() )

            EndDo

        Else

            cCodEmit  := ""
            cLojaEmit := ""
            cRazao    := ""
            cIndRur   := ""
        ENDIF

    ENDIF

    RestArea( aArea )

Return( .T. )
//Rotina para converter a data
Static Function VerData( cDatRec )

	Local dDat := ctod( "" )
	Local cDat := ""

	cDat := Substr( cDatRec,9,2 ) + "/" + Substr( cDatRec,6,2 ) + "/" + Substr( cDatRec,1,4 )

	dDat := ctod( cDat )

Return(dDat)


//-----------------------------------------------------------------------------------------------//
//Fun็ใo : FNOTIFICA 
//Autoria: Flแvia Rocha  - Data: 22/12/2022
//Prepara os dados para envio da notifica็ใo (NOTIFICAวรO DE DOWNLOAD OU CLASSIFICAวรO DE PRษ-NOTA)
//-----------------------------------------------------------------------------------------------//
USER FUNCTION FNOTIFICA(cMail10,cTipo,cFornec,cLojfor,cNomeFor,cRazao,cCnpjEnt,cNumNota,cSeriNF,nFormNfe,dEmissao,cMotivo,xModelo,xChave,cTpCliFor)

Local cStatus := ""                
 /*
 //MODELO
 Assunto  - Nota Fiscal nใo importada com sucesso 
 Conte๚do 
 Fornecedor......: 000996 - TE CONNECTIVITY BRASIL IN
 Nota Fiscal.....: 000196943/1 - Emissใo: 19/04/2021
 Chave da NFe....: 35210400907845001560550010001969431286545563
 Situa็ใo SEFAZ..: 100 - Autorizado o uso da NF-e
 */
If cMotivo == "100"
    cStatus := cMotivo + " - Autorizado o uso da " + xModelo 
Else 
    cStatus := cMotivo                  
Endif 

If cTipo == "1"  //download ok
    If !Empty(cFornec)
        //Aadd(aMsg , {"Fornecedor" 	, cFornec + "/" + cLojFor + " - " + cNomeFor ,;
        Aadd(aMsg, { cTpCliFor      , cFornec + "/" + cLojFor + " - " + cNomeFor ,;     //mostra string "Fornecedor" ou "Cliente"
                    "Nota Fiscal"	, StrZero(cNumNota,nFormNfe) + "/" + cSeriNF + " - Emissใo: " + Dtoc(dEmissao),;
                    "Chave da NFe"	, xChave,;
                    "Situa็ใo SEFAZ", cStatus ,;
                    "CNPJ"          , cCnpjEnt;
                    })
                    
    Else    
        //Aadd(aMsg , { "Fornecedor"	    , cRazao,;
        Aadd(aMsg, { cTpCliFor        , cRazao,;     //mostra string "Fornecedor" ou "Cliente"
                    "Nota Fiscal"	  , StrZero(cNumNota,nFormNfe) + "/" + cSeriNF + " - Emissใo: " + Dtoc(dEmissao),;
                    "Chave da NFe"    , xChave,;
                    "Situa็ใo SEFAZ"  ,cStatus,;
                    "CNPJ"            , cCnpjEnt;
                    })
    Endif 

Else

    If !Empty(cFornec)
        //Aadd(aMsg , {"Fornecedor" 	, cFornec + "/" + cLojFor + " - " + cNomeFor ,;
        Aadd(aMsg, { cTpCliFor      , cFornec + "/" + cLojFor + " - " + cNomeFor ,;     //mostra string "Fornecedor" ou "Cliente"
                    "Nota Fiscal"	, StrZero(cNumNota,nFormNfe) + "/" + cSeriNF + " - Emissใo: " + Dtoc(dEmissao),;
                    "Chave da NFe"	, xChave;                    
                    })
                    
    Else    
        //Aadd(aMsg , { "Fornecedor"	    , cRazao,;
        Aadd(aMsg, { cTpCliFor        , cRazao,;     //mostra string "Fornecedor" ou "Cliente"
                    "Nota Fiscal"	  , StrZero(cNumNota,nFormNfe) + "/" + cSeriNF + " - Emissใo: " + Dtoc(dEmissao),;
                    "Chave da NFe"    , xChave;                    
                    })
    Endif 
    

Endif 
            
 //monta o html e chama a fun็ใo de envio por email
 U_FMONTAHTML(cMail10, cAssunto, aMsg, cTipo)

 Return


//-----------------------------------------------------------------------------------------------//
//Fun็ใo : FMONTAHTML 
//Autoria: Flแvia Rocha  - Data: 22/12/2022
//MONTA O HTML PARA ENVIO POR EMAIL DA NOTIFICAวรO DE DOWNLOAD OU CLASSIFICAวรO DE PRษ-NOTA
//-----------------------------------------------------------------------------------------------//
User Function FMONTAHTML(cMail10,cAssunto,_aMsg,cTipo,cMsg)

Local cCopia := ""
Local cAnexo := ""
Local _nLin  := 0
Local nTentativas:= GetNewPar("XM_TENTSEND", 5 )   //FR - 02/05/2023 - NฺMEROS DE TENTATIVAS PARA ACIONAR ROTINA DE DOWNLOAD OU ENVIO DE EMAIL
Local lEnviou:= .F. //FR - 02/05/2023 - FLAG QUE INDICA SE A FUNวรO DE ENVIO DE EMAIL RETORNOU .T. OU .F. (.T. = EMAIL ENVIADO OK)
Local nTenta := 0
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Definicao do cabecalho do email                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cMsg := ""
cMsg += '<html>'
cMsg += '<head>'
cMsg += '<title><font color = "red"><b> Assunto - ' + cAssunto + '</font></b></title>' //+ " - "+SM0->M0_NOME+"/"+SM0->M0_FILIAL+'</title>'
cMsg += '</head>'
cMsg += '<body>'
cMsg += '<HR Width=85% Size=3 Align=LEFT Color=Red> <P>'
cMsg += '<Table Border=1 Align=Center BorderColor=#000000 CELLPADDING=4 CELLSPACING=0 Width=60%>'
//cMsg += '<Caption> <FONT COLOR=#000000 FACE= "ARIAL" SIZE=5>' + cAssunto +" - "+SM0->M0_NOME+"/"+SM0->M0_FILIAL+ '</FONT> </Caption>'
cMsg += '<Caption> <FONT COLOR= "red" FACE= "Courier New" SIZE=5><b>' + cAssunto  + '</b></FONT> </Caption>'
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Definicao do texto/detalhe do email                                         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For _nLin := 1 to Len(_aMsg)	
    
    cMsg += '<TR BgColor=#B0E2FF>'
    //coluna tํtulo
    cMsg += '<TD><B><Font Color=#000000 Size="2" Face="Courier New" font color = "black">' + _aMsg[_nLin,1] + '</Font></B></TD>'  //fornecedor
	//coluna conte๚do
    cMsg += '<TD BGCOLOR=#FFFFFF><B><Font Color=#000000 Size="2" Face="Courier New" font color = "black">' + _aMsg[_nLin,2] + '</Font></B></TD>'
    cMsg += '</tr>'

	//cMsg += '<TR BgColor=#FFFFFF>'
    cMsg += '<TR BgColor=#B0E2FF>'
    //coluna tํtulo
    cMsg += '<TD><B><Font Color=#000000 Size="2" Face="Courier New" font color = "black">' + _aMsg[_nLin,3] + '</Font></B></TD>' //nota fiscal
	//coluna conte๚do
    cMsg += '<TD BGCOLOR=#FFFFFF><B><Font Color=#000000 Size="2" Face="Courier New" font color = "black">' + _aMsg[_nLin,4] + '</Font></B></TD>'
	cMsg += '</tr>'

    cMsg += '<TR BgColor=#B0E2FF>'
    //coluna tํtulo
    cMsg += '<TD><B><Font Color=#000000 Size="2" Face="Courier New" font color = "black">' + _aMsg[_nLin,5] + '</Font></B></TD>' //chave
    //coluna conte๚do
    cMsg += '<TD BGCOLOR=#FFFFFF><B><Font Color=#000000 Size="2" Face="Courier New" font color = "black">' + _aMsg[_nLin,6] + '</Font></B></TD>'
    cMsg += '</tr>'

    If Len(_aMsg[1]) > 6
        cMsg += '<TR BgColor=#B0E2FF>'
        //coluna tํtulo
        cMsg += '<TD><B><Font Color=#000000 Size="2" Face="Courier New" font color = "black">' + _aMsg[_nLin,7] + '</Font></B></TD>' //situa็ใo sefaz
        //coluna conte๚do
        cMsg += '<TD BGCOLOR=#FFFFFF><B><Font Color=#000000 Size="2" Face="Courier New" font color = "black">' + _aMsg[_nLin,8] + '</Font></B></TD>'
        cMsg += '</tr>'

        cMsg += '<TR BgColor=#B0E2FF>'
        //coluna tํtulo
        cMsg += '<TD><B><Font Color=#000000 Size="2" Face="Courier New" font color = "black">' + _aMsg[_nLin,9] + '</Font></B></TD>' //CNPJ
        //coluna conte๚do
        If Len(Alltrim(_aMsg[_nLin,10])) >= 14
            cMsg += '<TD BGCOLOR=#FFFFFF><B><Font Color=#000000 Size="2" Face="Courier New" font color = "black">' + Transform(_aMsg[_nLin,10], "@R 99.999.999/9999-99") + '</Font></B></TD>'
        Else 
            cMsg += '<TD BGCOLOR=#FFFFFF><B><Font Color=#000000 Size="2" Face="Courier New" font color = "black">' + Transform(_aMsg[_nLin,10], "@R 999.999.999-99") + '</Font></B></TD>'
        Endif 
    Endif 
    cMsg += '</tr>'
Next

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Definicao do rodape do email                                                ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cMsg += '</Table>'
cMsg += '<P>'
cMsg += '<Table align="center">'
cMsg += '<tr>'
cMsg += '<td colspan="10" align="center"><font color="red" size="3">E-mail gerado em: '+ Dtoc(date())+'-'+ Time()+'  - <font color="red" size="1">( HFMAIL )</td>'
cMsg += '</tr>'
cMsg += '</Table>'
cMsg += '<HR Width=85% Size=3 Align=Centered Color=Red> <P>'
cMsg += '</body>'
cMsg += '</html>'

While !lEnviou .and. nTenta <= nTentativas
    lEnviou := U_HFSendMail(cMail10, cCopia, cAssunto, cMsg, cAnexo )
    nTenta++
Enddo

Return


/*==========================================================================
|Funcao    | SendMail          | Flแvia Rocha           | Data | 22/12/2022|
============================================================================
|Descricao | Envia um email                              				   | 
|                                   	  						           |
============================================================================
|Observa็๕es: Gen้rico      											   |
==========================================================================*/
User Function HFSendMail(cMailTo, cCopia, cAssun, cCorpo, cAnexo )

//Local cEmailCc  := cCopia
Local lResult   := .F. 
Local lEnviado  := .F.
Local cError    := ""
/*
Local cAccount	:= "nfe_teste@hfbr.com.br" 	//GetMV( "MV_RELACNT" )    //nfe_teste@hfbr.com.br
Local cPassword := "hfbr2030" 				//GetMV( "MV_RELPSW"  )    //hfbr2030
Local cServer	:= "smtp.hfbr.com.br:587"	//GetMV( "MV_RELSERV" )
Local cFrom		:= "nfe_teste@hfbr.com.br" //GetMV( "MV_RELACNT" )   //relatorio@premierpescados.com.br  
*/

Local cAccount	:= GetMV( "MV_RELACNT" )    
Local cPassword := GetMV( "MV_RELPSW"  )    
Local cServer	:= GetMV( "MV_RELSERV" )
Local cFrom		:= GetMV( "MV_RELACNT" )                                        
                                  

CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lResult

if lResult
	
	//MailAuth( GetMV( "MV_RELACNT" ), GetMV( "MV_RELPSW"  ) ) //realiza a autenticacao no servidor de e-mail.
	MailAuth( cAccount, cPassword ) //realiza a autenticacao no servidor de e-mail.

	SEND MAIL FROM cFrom;
	TO cMailTo;
	CC cCopia;
	SUBJECT cAssun;
	BODY cCorpo;
	ATTACHMENT cAnexo RESULT lEnviado
	
	if !lEnviado
		//Erro no envio do email
		GET MAIL ERROR cError
		If !IsBlind()
            Help(" ",1,"ATENCAO",,cError + " - Falha Ao Enviar E-mail...",4,5)
		    //Msgbox("E-mail nใo enviado...")	
        Endif 
	else
		//MsgInfo("E-mail Enviado com Sucesso!")
	endIf
	
	DISCONNECT SMTP SERVER
	
else
	//Erro na conexao com o SMTP Server
	GET MAIL ERROR cError
	Help(" ",1,"ATENCAO",,cError + " -> Erro ao conectar em servidor / conta: " + cServer + " / " + cAccount ,4,5)
endif

Return(lResult .And. lEnviado )

