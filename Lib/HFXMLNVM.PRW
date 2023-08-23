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

//Static lInitSped := .F.


//
//User Function HFXMLNVM(lAuto,lEnd,oProcess,cLogProc,nCount)

//Return()



// Executa a funcao HFXMLNVMA com controle de Sem·foro para aguardar o termino da mesma
User Function HFXMLNVM(lAuto,lEnd,oProcess,cLogProc,nCount)
	// Inicia a rotina u_execInst como uma nova thread para execuÁ„o paralela
	/*
	StartJob("u_HFXPRONVM", GetEnvServer(), .F.,;
		(lAuto,lEnd,oProcess,cLogProc,nCount,Alltrim(UsrFullName(RetCodUsr()))); // parametro para u_execInst()
		)
	*/

	cLogUser := Alltrim(UsrFullName(RetCodUsr()))
	U_HFXPRONVM(@lAuto,@lEnd,@oProcess,@cLogProc,@nCount,@cLogUser)
	//	)

Return


/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Programa  ≥ HFXMLNVM ≥ Autor ≥ Heverton Marcondes    ≥ Data ≥19/04/2022≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Download dos XML da NUVEM					              ≥±±
±±≥                                                                       ≥±±
±±≥                                             			              ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/

User Function HFXPRONVM(lAuto,lEnd,oProcess,cLogProc,nCount,cLogUser)

	Local oRest 	:= Nil
	Local aHeader 	:= {}
	Local cData		:= ""
	Local dData30	:= dDataBase - Val(GetNewPar("XM_D_CANCEL","90"))

	Local cData30	:= ""
	Local dData		:= dDataBase
	Local cClToken  :=	alltrim(GetNewPar("XM_CLTOKEN",Space(256)))
	Local lBaxResu  :=	GetNewPar("XM_BXRESUM","N")
	Local cBaxCteT  :=	GetNewPar("XM_BXCTETM","N")  //Baixa apenas CTE Tomador ?
	Local nX		:= 0
	Local ix 		:= 0
	//Local dEmissao	:= stod("")
	//Local cCodEmit 	:= ""
	//Local cLojaEmit	:= ""
	//Local cRazao   	:= ""
	Local cErro := "", cWarning := ""
	Local cDir  :=  AllTrim(SuperGetMv("MV_X_PATHX"))
	Local cModal := "NFe"
	Local cNSUZero  := GetNewPar( "XM_NSUZERO", "N" )
	Local cVerPar := ""
	Local nUltNSU := 0
	Local lCteAtivo := .t.
	Local lNfeAtivo := .t.

	Local lNfeProc := .t.
	Local nLoteNfe := 0

	Local lCteProc := .t.
	Local nLoteCte := 0

	Local _MaiorNsu := 0
	Local _MaiorCTENsu := 0

	Local _NsuCtrl := ""
	Local cDayNSUzero := GetNewPar( "XM_DAYZERO", "S" )

	Local aValidCte := {}
	Local cTomaCnpj := ""
	Local cCdToma := ""

	Local lAppend := .f.
	//Local cCfopIt := ""
	//Local cCfopDoc := Space(15)

	//Local cFinalidad	:= ""
	//Local cTipoDoc      := "N"

	//Local _TpRot := ""

	//Local cVerXml    := ""
	//Local cTagVerXml := ""

	//Local cTagTpCte	:=	""
	//Local cTpCte := ""
	//Local xInfoCompl := ""
	Local cAutoSA2D   := GetNewPar("XM_SA2AUTD","N")   //FR - 21/12/2021 - habilita cadastro autom·tico do fornecedor no download do xml
	Local i           := 0
	//Local cFilBkp		:= ""
	Private aNotas := {}
	Private aEventos := {}
	Private aResum := {}

	Private cUf 		:= ""
	Private nUf			:= ""
	Private xZBZ  		:= GetNewPar("XM_TABXML" ,"ZBZ")
	Private xZBZ_ 		:= iif(Substr(xZBZ,1,1)=="S", Substr(xZBZ,2,2), Substr(xZBZ,1,3)) + "_"
	Private cUrl 		:= "https://cloud.importaxml.com.br"
	Private cCnpj		:= ""
	Private cIEXML      := ""
	Private cIE         := ""
	Private cReq		:= ""
	Private nFormNfe 	:= Val(GetNewPar("XM_FORMNFE","9"))
	Private cXmlRet		:= ""
	Private oXmlRet
	Private aUF			:= {}
	Private _cFil       := ""
	Private nCodNSU     := 0
	Private oObjJson    := Nil

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

	If !lAuto .Or. oProcess<>Nil

		oProcess:IncRegua1("Conectando com Conector Sefaz...")
		oProcess:IncRegua2("Aguarde...")

	EndIf

	ConOut("[IMPXMLNUVEM] " + "Iniciado Download GestaoXML - Conector Sefaz")

	lProcessa := .T.


	ConOut('Iniciada inst‚ncia [IMPXMLNUVEM] ' + cLogUser)
	// Ativar o semaforo
	If GlbLock()

		ConOut('Gerou semaforo da Inst‚ncia [IMPXMLNUVEM]  ' + cLogUser)

		If lProcessa

			//Verifica de o parametro NSU j· existe

			cVerPar := ( GetNewPar("XM_NSUNFE","NOVO",cFilAnt) )

			If ALLTRIM(cVerPar) == "NOVO"

				SX6->(RecLock("SX6",.T.))

				SX6->X6_FIL     := cFilAnt //xFilial( "SX6" )
				SX6->X6_VAR     := "XM_NSUNFE"
				SX6->X6_TIPO    := "C"
				SX6->X6_DESCRIC := "NSU download NFE por CNPJ via HF"

				SX6->(MsUnLock())

				PutMv("XM_NSUNFE","000000000000000")

			EndIf

			If Funname() == "RPC"

				if cNSUZero == "S"
					nUltNSU := 0
				else
					//Se parametro estiver ativado todo dia ao menos uma vez ir· realizar a checagem
					if cDayNSUzero == "S" .and. ( Time() >= "18:00:00" .and. Time() <= "20:00:00" )
						nUltNSU := 0
					else
						nUltNSU := val(( GetNewPar("XM_NSUNFE","000000000000000",cFilAnt) ))
					endif
				endif

			else
				if cNSUZero == "S"
					nUltNSU := 0
				else
					nUltNSU := val(( GetNewPar("XM_NSUNFE","000000000000000",cFilAnt) ))
				endif

			endif

			//Pega a data limite inicial
			cData30 := substr(dtos(dData30),7,2)+"-"
			cData30 += substr(dtos(dData30),5,2)+"-"
			cData30 += substr(dtos(dData30),1,4)

			//Pega a data limite final
			cData := substr(dtos(dData),7,2)+"-"
			cData += substr(dtos(dData),5,2)+"-"
			cData += substr(dtos(dData),1,4)

			If lProcessa

				Aadd(aHeader, "Content-Type: application/json")
				Aadd(aHeader, "Connection: keep-alive")

				//Verifica dados no SIGAMAT, inscriÁ„o municipal n„o obrigatÛria, monitorar pq jah deu problema passando inscriÁ„o HMS
				cCnpj 	:= Alltrim(FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , { "M0_CGC" } )[1][2])
				cIE     := Alltrim(FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , { "M0_INSC" } )[1][2])

				//-------------------------------------------------------------------------
				// Baixa NFE - Gest„o na Nuvem
				//-------------------------------------------------------------------------
				if lNfeAtivo

					lNfeProc := .t.
					nLoteNfe := 0
					_NsuCtrl := nUltNSU

					cApicnpj := ""
					xNotas   := {}	//FR - 05/10/2022 - DAIKIN
					While lNfeProc

						oObjJson  := Nil
						_MaiorNsu := 0
						nLoteNfe++

						If nLoteNfe > 1
							nUltNSU := _NsuCtrl
						EndIf

						ConOut("Consulta NFE-Conector Sefaz com NSU: "+cValToChar(nUltNSU))
						oRest 	:= FWRest():New(cUrl)

						//oRest:SetPath("/api/NFe?token="+cClToken+"&Inicio="+cData30+"&Fim="+cData)
						//cClToken := "YK4CT61V-P0123BXW-XX7YVORE"
						//cClToken := "UUP4FDWF-DNZH7DU5-9K7LSCJ0"
						oRest:SetPath("/api/DownloadPorNSU?Token="+cClToken+"&cnpj="+cCnpj+"&modalidade="+cModal+"&ultNSU="+alltrim(str(nUltNSU))+"&resumidas="+(iif(lBaxResu=="S","true","false")))
						//oRest:SetPath("/api/DownloadPorNSU?Token="+cClToken+"&modalidade="+cModal+"&ultNSU="+alltrim(str(nUltNSU))+"&cnpj="+cApicnpj+"&resumidas="+(iif(lBaxResu,"true","false")))
						//https://cloud.importaxml.com.br/api/DownloadPorNSU?Token=UUP4FDWF-DNZH7DU5-9K7LSCJ0&modalidade=NFe&ultNSU=0

						If oRest:Get(aHeader)

							If !FWJsonDeserialize(oRest:GetResult(), @oObjJson)
								MsgStop("Ocorreu erro no processamento do Json")
								Return Nil
							EndIf

						else

							msgStop(oRest:getLastError(), "Erro")

						EndIf

						If oObjJson <> Nil

							If Type( "oObjJson:NOTAS" ) <> "U"
								aNotas := oObjJson:NOTAS
							EndIf								
							
							If lBaxResu=="S"
								If Type( "oObjJson:RESUMIDAS" ) <> "U"
									aResum := oObjJson:RESUMIDAS
								EndIf	
							EndIf
							
							If Type( "oObjJson:EVENTOS" ) <> "U"
								aEventos := oObjJson:EVENTOS
							EndIf	

							// Controle para o While
							// Caso nao tenha mais informaÁıes nos Arrays para o LaÁo
							IF (Len(aNotas) + Len(aEventos)) == 0

								lNfeProc := .f.

							ENDIF

							If IsBlind()
								Conout( "Total Notas + Eventos: " + cValToChar(((Len(aNotas)+Len(aEventos)))) )
								Conout( "Total de Notas: " + cValtoChar(Len(aNotas))  )
							Else
								oProcess:SetRegua1( (Len(aNotas)+Len(aEventos)) ) //Alimenta a primeira barra de progresso
								oProcess:SetRegua2( Len(aNotas) )
							Endif

							//For nX := 1 to len(oObjJson)
							For nX := 1 to len(aNotas)  //oObjJson:NOTAS[1]:XML

								If IsBlind()
									Conout( "Consultando XMLs Nfe com Conector Sefaz("+cValtoChar(nLoteNfe)+")..." )
									Conout( "Baixando..." + cValtoChar(nX) +" de "+ cValToChar(Len(aNotas)))
								Else
									oProcess:IncRegua1("Consultando XMLs Nfe com Conector Sefaz("+cValtoChar(nLoteNfe)+")...")
									oProcess:IncRegua2("Baixando..." + cValtoChar(nX) +" de "+ cValToChar(Len(aNotas)))
								Endif

								nCodNSU  := aNotas[nX]:NSU
								cChaveXml := aNotas[nX]:CHAVE
								cXmlRet := aNotas[nX]:XML
								cStatus := aNotas[nX]:Status
								cModelo := ALLTRIM(aNotas[nX]:Modelo)
								cChaveArq := cDir + Substr(cChaveXml,1,44) + "-CloudNfe.xml"

								PutMv("XM_NSUNFE", StrZero( nCodNSU,15 ))
								_NsuCtrl := nCodNSU
								_MaiorNsu := nCodNSU

								DbSelectArea(xZBZ)
								( xZBZ )->( DbSetOrder( 3 ) )
								lAppend := !(xZBZ)->(DbSeek(alltrim(cChaveXml)))

								//Significa que j· foi realizado o Download e que n„o teve mudanÁa de Status - Nao precisa reimportar
								_tpDown := ""

								if !lAppend
									_tpDown := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOWL")))
									//-----------------------------------------------------------------------------------------------//
									//FR-29/12/2022 - BRASMOLDE - NOTIFICA«’E POR EMAIL
									//QDO O XML J¡ FOI GRAVADO, N√O PASSA NA FUN«√O ABAIXO HFXCTRGRV, POR CAUSA DO LOOP NO IF ABAIXO
									//POR ISSO, RETIREI O LOOP 
									//-----------------------------------------------------------------------------------------------//
									if  (empty(_tpDown) .and. !(cStatus == "1")) //(( _tpDown == "R" .and. cStatus == "1" ) .or. (empty(_tpDown) .and. !(cStatus == "1")))
										loop
									endif

								endif


								// O FONTE HFXCTRGRV - CONTROLE DE GRAVA«√O
								// RECEBER¡ TODAS AS REQUISI«’ES DE GRAVA«’ES DO XML E EVENTOS
								// INICIADO PELO NFE
								u_HFXCTRGRV(cXmlRet,cModelo,aNotas[nX]:CNPJ,aNotas[nX]:NOTA,cChaveXml,@_cFil,lAppend,cStatus,.f.)


								cLogProc += "[XML] "+cChaveXml+" gravado com sucesso."+CRLF

								//EndIf

							Next nX

							//Tratativa para GravaÁ„o de Notas Resumidas
							For nX := 1 to len(aResum)

								If IsBlind()
									Conout( "Consultando XMLs Nfe Resumidas com Conector Sefaz("+cValtoChar(nLoteNfe)+")..." )
									Conout( "Baixando Resumidas..." + cValtoChar(nX) +" de "+ cValToChar(Len(aResum)))
								Else
									oProcess:IncRegua1("Consultando XMLs Nfe Resumidas com Conector Sefaz("+cValtoChar(nLoteNfe)+")...")
									oProcess:IncRegua2("Baixando..." + cValtoChar(nX) +" de "+ cValToChar(Len(aResum)))
								Endif

								nCodNSU  := aResum[nX]:NSU
								cChaveXml := aResum[nX]:CHAVE
								cXmlRet := aResum[nX]:XML
								cStatus := aResum[nX]:Status
								cModelo := ALLTRIM(aResum[nX]:Modelo)
								cChaveArq := cDir + Substr(cChaveXml,1,44) + "-Resum_CloudNfe.xml"

								//PutMv("XM_NSUNFE", StrZero( nCodNSU,15 ))
								//_NsuCtrl := nCodNSU
								//_MaiorNsu := nCodNSU

								DbSelectArea(xZBZ)
								( xZBZ )->( DbSetOrder( 3 ) )
								lAppend := !(xZBZ)->(DbSeek(alltrim(cChaveXml)))

								//_tpDown := ""

								if !lAppend
									//_tpDown := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOWL")))

									//if (( _tpDown == "R" .and. cStatus == "1" ) .or. (_tpDown == ""))
										loop
									//endif
								endif

								// O FONTE HFXCTRGRV - CONTROLE DE GRAVA«√O
								// RECEBER¡ TODAS AS REQUISI«’ES DE GRAVA«’ES DO XML E EVENTOS
								// INICIADO PELO NFE
								u_HFXCTRGRV(cXmlRet,cModelo,aResum[nX]:CNPJ,"",cChaveXml,@_cFil,lAppend,cStatus,.T.)


								cLogProc += "[XMLRES] "+cChaveXml+" gravado com sucesso."+CRLF

								//EndIf

							Next nX

							//TRATATIVA DE GRAVA«√O DE EVENTOS
							nX := 1
							cDTTime := U_FRDTHora(1,dDatabase, Time(),"")

							If IsBlind()
								Conout("Total Eventos: " + cValtochar(Len(aEventos)))
							Else
								oProcess:SetRegua2( Len(aEventos) )
							Endif

							//For nX := 1 to len(oObjJson)
							For nX := 1 to len(aEventos)  //oObjJson:NOTAS[1]:XML

								If IsBlind()
									Conout("Consultando Eventos com Conector Sefaz...")
									Conout("Baixando..." + cValtoChar(nX) +" de "+ cValToChar(Len(aEventos)))
								Else
									oProcess:IncRegua1("Consultando Eventos com Conector Sefaz...")
									//oProcess:IncRegua2("Aguarde...")
									oProcess:IncRegua2("Baixando..." + cValtoChar(nX) +" de "+ cValToChar(Len(aEventos)))
								Endif

								cXml := aEventos[nX]:XML
								nCodNSU := aEventos[nX]:NSU
								cKey := aEventos[nX]:Chave
								cEve := aEventos[nX]:Tipo
								cPro := aEventos[nX]:Protocolo
								CDes := aEventos[nX]:Evento
								cSta := U_getSitConf(cEve)
								cXCorrecao := aEventos[nX]:xCorrecao
								xMotivo := aEventos[nX]:xMotivo

								IF !EMPTY(cXCorrecao)
									CDes := ALLTRIM(cXCorrecao)
								ELSE
									CDes := ALLTRIM(xMotivo) +" - " + ALLTRIM(CDes)
								ENDIF

								//VERIFICA SE EXISTE A NOTA BAIXADA PARA PODER AMARRAR O EVENTO
								DbSelectArea(xZBZ)
								( xZBZ )->( DbSetOrder( 3 ) )
								lAchou  := (xZBZ)->(DbSeek(alltrim(cKey)))

								if lAchou

									nI := 1

									aEvt    := {}
									cSeqEve := ""
									//aEvt    := U_HF20ZBE( nI, @cSeqEve, cXml )
									//cGrv    := U_HF2GrvEv( cKey, cEve, cSeqEve, aEvt, .T. )

									if Alltrim(cEve) == "110111" //aEventos[nX]:Evento == "Cancelamento"  //110111 se for cancelamento

										Reclock(xZBZ,.F.)

										(xZBZ)->(FieldPut(FieldPos(xZBZ_+"DTHCAN"), aEventos[nX]:DATASEFAZ))
										(xZBZ)->(FieldPut(FieldPos(xZBZ_+"XMLCAN"), cXml))
										(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PROTC"), cPro))
										(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PRENF"), "X"))

										(xZBZ)->(MsUnLock())

									endif

									cKey := PadR(cKey,TamSX3(xZBE_+"CHAVE")[1],Nil)
									cEve := PadR(cEve,TamSX3("B2_COD")[1],Nil)

									DbSelectArea(xZBE)
									DbSetOrder(1)
									if !DbSeek(_cFil+cKey+alltrim(cEve))

										oXmlRet := XmlParser( cXml ,"_",@cErro, @cWarning )

										if Empty( oXmlRet )

											cXml := u_HFAjuXML(cXml)

											oXmlRet := XmlParser( cXml ,"_",@cErro, @cWarning )

										endif

										If Type( "oXmlRet:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_NPROT:TEXT" ) <> "U"
											cProtC := oXmlRet:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_NPROT:TEXT
										EndIF

										If Type( "oXmlRet:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_NSEQEVENTO:TEXT" ) <> "U"
											cSeqEve := oXmlRet:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_NSEQEVENTO:TEXT
										else
											cSeqEve := "01"
										EndIf

										If len(cSeqEve)<=len( (xZBE)->(FieldGet(FieldPos(xZBE_+"SEQEVE"))) )
											cSeqEve := StrZero( Val(cSeqEve), len( (xZBE)->(FieldGet(FieldPos(xZBE_+"SEQEVE"))) ), 0 )
										Endif

										dDhAut  := ctod( "" )

										If Type( "oXmlRet:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_DHREGEVENTO:TEXT" ) <> "U"
											cDthRet := oXmlRet:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_DHREGEVENTO:TEXT
											dDhAut  := StoD(substr(cDthRet,1,4)+Substr(cDthRet,6,2)+Substr(cDthRet,9,2))
										EndIf

										Reclock(xZBE,.T.)

										(xZBE)->(FieldPut(FieldPos(xZBE_+"CHAVE") , cKey      )) //cKey+cEvento+cSeqEve
										(xZBE)->(FieldPut(FieldPos(xZBE_+"FILIAL"), _cFil  ))
										(xZBE)->(FieldPut(FieldPos(xZBE_+"XML") , cXml      )) //cKey+cEvento+cSeqEve
										(xZBE)->(FieldPut(FieldPos(xZBE_+"TPEVE") , cEve   ))
										(xZBE)->(FieldPut(FieldPos(xZBE_+"DESC") , CDes   ))
										(xZBE)->(FieldPut(FieldPos(xZBE_+"SEQEVE"), cSeqEve   ))
										(xZBE)->(FieldPut(FieldPos(xZBE_+"DTHRGR"), cDTTime   ))
										(xZBE)->(FieldPut(FieldPos(xZBE_+"PROT"), cPro   ))
										(xZBE)->(FieldPut(FieldPos(xZBE_+"STATUS"), cSta ))
										(xZBE)->(FieldPut(FieldPos(xZBE_+"DHAUT"), dDhAut ))
										(xZBE)->(FieldPut(FieldPos(xZBE_+"DTRECB"), ddatabase ))
										(xZBE)->(FieldPut(FieldPos(xZBE_+"EVENTO"), cXCorrecao ))

										(xZBE)->(MsUnLock())

									Endif

								EndIf

							Next nX

							//Caso tenha sido realizado carga completa
							//Muda o parametro para nao baixar tudo novamente na proxima chamada
							if cNSUZero == "S"
								PutMv("XM_NSUZERO","N")
							EndIf

							//CASO O EVENTO POSSUA NUMERO DE NSU MAIOR QUE O ULTIMO DO ARRAY
							// DA NFE, ENTAO ASSUME ESTE (SEMPRE CONSIDERAR O MAIOR)
							IF nCodNSU > _MaiorNsu
								PutMv("XM_NSUNFE", StrZero( nCodNSU,15 ))
								_NsuCtrl := nCodNSU
								_MaiorNsu := nCodNSU
							ENDIF

							//VerificaÁ„o necessaria para nao ficar em loop
							if nCodNsu = 0

								lNfeProc := .f.

							endif

							oRest := NIL
							FreeObj(oRest)
							aNotas := {}
							aEventos := {}

						else

							if !Empty( oRest:GetResult() )

								Telaoff("Falha no retorno da api",oRest:GetResult())

								oRest := NIL
								FreeObj(oRest)
								Return

							endif

						EndIf

						aNotas := {}
						aEventos := {}

					ENDDO

					//----------------------------------------------------------//
					//FR - 28/10/2021 - DAIKIN - CADASTRO AUTOM¡TICO FORNECEDOR 
					//----------------------------------------------------------//
					If cAutoSA2D == "S" //.and. cModelo == "55" //FR - 21/12/2021 - se cadastra autom·tico no download do xml
						cCNPJEmi := ""
						xRecZBZ  := 0
						xChaveZBZ:= ""
						xRecZBZ  := 0
						i        := 0

						For nX := 1 to len(xNotas)  //oObjJson:NOTAS[1]:XML								
																							
							For i := 1 to Len(xNotas[nX])
								cCNPJEmi := xNotas[nX,i]:CNPJ
								xChaveZBZ:= xNotas[nX,i]:CHAVE

								(xZBZ)->(OrdSetFocus(3))  //ZBZ_CHAVE
								If (xZBZ)->(DbSeek(alltrim(xChaveZBZ)))
									xRecZBZ := (xZBZ)->(Recno())
									If xRecZBZ > 0
										U_fCADSA2(cCNPJEmi,xRecZBZ)			//fCADSA2(cCNPJEmi,xRECZBZ) //aqui ainda n„o tem o Recno da ZBZ porque ainda n„o gravou
									Endif 
								Endif 
							Next i
							
						Next							 			
					Endif 
					//----------------------------------------------------------//
					//FR - 28/10/2021 - DAIKIN - CADASTRO AUTOM¡TICO FORNECEDOR 
					//----------------------------------------------------------//
				ENDIF

				//-------------------------------------------------------------------------
				// Baixa CTE - Gest„o na Nuvem
				//-------------------------------------------------------------------------
				if lCteAtivo

					cBkpFil := cFilAnt
					lCteProc := .t.
					nLoteCte := 0
					xNotas   := {}	//FR - 05/10/2022 - DAIKIN
					nCodNSU  := 0
					if cNSUZero == "S"
						nUltNSU := 0
					else
						nUltNSU := val(( GetNewPar("XM_NSUCTE","000000000000000",cFilAnt) ))
					endif
					_NsuCtrl := nUltNSU

					While lCteProc

						oObjJson  := Nil
						nLoteCte++
						_MaiorCTENsu := 0
						cModal := "Cte"
						cTAG   := "CTE"
						//nUltNSU := val(( GetNewPar("XM_NSUCTE","000000000000000",cFilAnt) )) //0
						oRest 	:= FWRest():New(cUrl)

						IF nLoteCte > 1
							nUltNSU := _NsuCtrl
						ENDIF

						ConOut("Consulta CTE - Conector Sefaz com NSU: "+cValToChar(nUltNSU))

						//oRest:SetPath("/api/NFe?token="+cClToken+"&Inicio="+cData30+"&Fim="+cData)
						//cClToken := "YK4CT61V-P0123BXW-XX7YVORE"
						//cClToken := "UUP4FDWF-DNZH7DU5-9K7LSCJ0"
						oRest:SetPath("/api/DownloadPorNSU?Token="+cClToken+"&cnpj="+cCnpj+"&modalidade="+cModal+"&ultNSU="+alltrim(str(nUltNSU)))

						If oRest:Get(aHeader)

							If !FWJsonDeserialize(oRest:GetResult(), @oObjJson)

								if !IsBlind()
									FwAlertInfo("Falha na recepÁ„o do arquivo com Conector Sefaz. Favor tentar em alguns minutos.","RecepÁ„o de Arquivo")
								else
									ConOut("Falha na recepÁ„o do arquivo com Conector Sefaz. Favor tentar em alguns minutos.")
									Return Nil
								EndIf

							EndIf

							If oObjJson <> Nil

								aNotas := oObjJson:NOTAS
								aEventos := oObjJson:EVENTOS

								If Len(aNotas) > 0
									Aadd(xNotas , aNotas)	//FR 05/10/2022 - DAIKIN
								Endif
								// Controle para o While
								// Caso nao tenha mais informaÁıes nos Arrays para o LaÁo
								IF (Len(aNotas) + Len(aEventos)) == 0

									lCteProc := .f.

								ENDIF

								If IsBlind()
									//Conout("Total de Notas + Eventos CTE " + CValToChar((Len(aNotas)+Len(aEventos))))
									Conout("Total de CTE¥s" + CValToChar(Len(aNotas)))
								Else
									oProcess:SetRegua1( (Len(aNotas)+Len(aEventos)) ) //Alimenta a primeira barra de progresso
									oProcess:SetRegua2( Len(aNotas) )
								Endif

								//For nX := 1 to len(oObjJson)
								For nX := 1 to len(aNotas)  //oObjJson:NOTAS[1]:XML

									If IsBlind()
										Conout("Baixando XML Cte com Conector Sefaz("+cValtoChar(nLoteCte)+")...")
										Conout("Baixando..." + cValtoChar(nX) +" de "+ cValtoChar(Len(aNotas)))
									Else
										oProcess:IncRegua1("Baixando XML Cte com Conector Sefaz("+cValtoChar(nLoteCte)+")...")
										//oProcess:IncRegua2("Aguarde...")
										oProcess:IncRegua2("Baixando..." + cValtoChar(nX) +" de "+ cValtoChar(Len(aNotas)))
									Endif

									lBaixaCte := .t.
									nCodNSU  := aNotas[nX]:NSU
									cChaveXml := aNotas[nX]:CHAVE
									cXmlRet := aNotas[nX]:XML
									cStatus := aNotas[nX]:Status
									cModelo := ALLTRIM(aNotas[nX]:Modelo)
									cChaveArq := cDir + Substr(cChaveXml,1,44) + "-CloudCte.xml"

									cFilant := cBkpFil
									PutMv("XM_NSUCTE", StrZero( nCodNSU,15 ))
									_NsuCtrl := nCodNSU
									_MaiorCTENsu := nCodNSU

									DbSelectArea(xZBZ)
									( xZBZ )->( DbSetOrder( 3 ) )
									lAppend := !(xZBZ)->(DbSeek(alltrim(cChaveXml)))

									if !lAppend .and. cStatus == "100" //Significa que j· foi realizado o Download e que n„o teve mudanÁa de Status - Nao precisa reimportar
										loop
									endif

									oXmlRet := XmlParser( cXmlRet ,"_",@cErro, @cWarning )

									if Empty( oXmlRet )

										cXmlRet := U_HFAjuXML(cXmlRet)

										oXmlRet := XmlParser( cXmlRet ,"_",@cErro, @cWarning )

									endif

									If ( oXmlRet == NIL )

										oXmlRet := NIL
										FreeObj(oXmlRet)
										aNotas := {}
										aEventos := {}
										Conout("Falha ao gerar Objeto XML : "+cError+" / "+cWarning)
										Return

									Endif

									/*
									If Type("oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_DEST:_CNPJ:TEXT") <> "U"
										cCnpjDest := "oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_DEST:_CNPJ:TEXT"
									else
										If Type("oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_DEST:_CPF:TEXT") <> "U"
											cCnpjDest := "oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_DEST:_CPF:TEXT"
										else
											cCnpjDest := ""
										endif

									endif

									If Type( "oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_DEST:_IE:TEXT" ) <> "U"
										cIEXML := &("oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_DEST:_IE:TEXT")
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
									*/
									If  !Empty( oXmlRet )  //&(cCnpjDest) = cCnpj  //oXmlRet:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ:TEXT = cCnpj

										//aNotas := oObjJson:NOTAS

										//If IsBlind()
										//	Conout("Total de CTE¥s " + cValtoChar(Len(aNotas)))
										//Else
										//	oProcess:SetRegua1( (Len(aNotas)) ) //Alimenta a primeira barra de progresso
										//	oProcess:SetRegua2( Len(aNotas) )
										//Endif

										aValidCte := HFValCTe(oXmlRet,cTAG,cChaveXml)
										_cFil := ALLTRIM(aValidCte[1][1])
										if empty(_cFil)
											_cFil := xFilial(xZBZ)
										endif
										//cFilBkp := cFilant
										cFilant := _cFil //ALLTRIM(aValidCte[1][1])
										cTomaCnpj := aValidCte[1][2]
										cCdToma := aValidCte[1][3]

										if cBaxCteT == "S" //Parametro para Verificar se o CNPJ do Tomador È do CLiente

											if !(CheckFil( cTomaCnpj ))
												lBaixaCte := .f.
											endif
										endif

										if lBaixaCte
											GeraZBZ(oXmlRet,cChaveXml,cModelo,lAppend,nX,@cLogProc,cStatus,cTomaCnpj,cCdToma)
										endif
										/*
										cTagUfDest 	:= 	"oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_CUF:TEXT"  //"oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_DEST:_ENDERDEST:_UF:TEXT"
										cTagTpCte	:=	"oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_TP"+cTAG+":TEXT" //Criando a Tag <tpCTE> obrigatorio Alexandro - 23/12/2016

										cTagDtEmit := "oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_DHEMI:TEXT"
										cTagTpPag  := "oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_FORPAG:TEXT"
										*/

										//cFilAnt		:= cFilBkp
										aValidCte := {}
										cTomaCnpj := ""
										cCdToma := ""

									EndIf

								Next nX

								//TRATATIVA DE GRAVA«√O DE EVENTOS
								nX := 1
								cDTTime := U_FRDTHora(1,dDatabase, Time(),"")

								If IsBlind()
									Conout("Total Eventos: " + cValtochar(Len(aEventos)))
								Else
									oProcess:SetRegua2( Len(aEventos) )
								Endif

								//For nX := 1 to len(oObjJson)
								For nX := 1 to len(aEventos)  //oObjJson:NOTAS[1]:XML

									If IsBlind()
										Conout("Consultando Eventos CTE com Conector Sefaz...")
										Conout("Baixando..." + cValtoChar(nX) +" de "+ cValToChar(Len(aEventos)))
									Else
										oProcess:IncRegua1("Consultando Eventos CTE com Conector Sefaz...")
										//oProcess:IncRegua2("Aguarde...")
										oProcess:IncRegua2("Baixando..." + cValtoChar(nX) +" de "+ cValToChar(Len(aEventos)))
									Endif

									cXml := aEventos[nX]:XML
									nCodNSU := aEventos[nX]:NSU
									cKey := aEventos[nX]:Chave
									cEve := aEventos[nX]:Tipo
									cPro := aEventos[nX]:Protocolo
									CDes := aEventos[nX]:Evento
									cSta := U_getSitConf(cEve)
									cXCorrecao := aEventos[nX]:xCorrecao
									xMotivo := aEventos[nX]:xMotivo

									IF !EMPTY(cXCorrecao)
										CDes := ALLTRIM(cXCorrecao)
									ELSE
										CDes := ALLTRIM(xMotivo) +" - " + ALLTRIM(CDes)
									ENDIF

									//VERIFICA SE EXISTE A NOTA BAIXADA PARA PODER AMARRAR O EVENTO
									DbSelectArea(xZBZ)
									( xZBZ )->( DbSetOrder( 3 ) )
									lAchou  := (xZBZ)->(DbSeek(alltrim(cKey)))

									if lAchou

										nI := 1

										aEvt    := {}
										cSeqEve := ""
										//aEvt    := U_HF20ZBE( nI, @cSeqEve, cXml )
										//cGrv    := U_HF2GrvEv( cKey, cEve, cSeqEve, aEvt, .T. )

										if Alltrim(cEve) == "110111" //aEventos[nX]:Evento == "Cancelamento"  //110111 se for cancelamento

											Reclock(xZBZ,.F.)

											(xZBZ)->(FieldPut(FieldPos(xZBZ_+"DTHCAN"), aEventos[nX]:DATASEFAZ))
											(xZBZ)->(FieldPut(FieldPos(xZBZ_+"XMLCAN"), cXml))
											(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PROTC"), cPro))
											(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PRENF"), "X"))

											(xZBZ)->(MsUnLock())

										endif

										cKey := PadR(cKey,TamSX3(xZBE_+"CHAVE")[1],Nil)
										cEve := PadR(cEve,TamSX3("B2_COD")[1],Nil)

										DbSelectArea(xZBE)
										DbSetOrder(1)
										if !DbSeek(_cFil+cKey+alltrim(cEve))

											oXmlRet := XmlParser( cXml ,"_",@cErro, @cWarning )

											if Empty( oXmlRet )

												cXml := U_HFAjuXML(cXml)

												oXmlRet := XmlParser( cXml ,"_",@cErro, @cWarning )

											endif

											If Type( "oXmlRet:_PROCEVENTOCTE:_RETEVENTOCTE:_INFEVENTO:_NPROT:TEXT" ) <> "U"
												cProtC := oXmlRet:_PROCEVENTOCTE:_RETEVENTOCTE:_INFEVENTO:_NPROT:TEXT
											EndIF

											If Type( "oXmlRet:_PROCEVENTOCTE:_RETEVENTOCTE:_INFEVENTO:_NSEQEVENTO:TEXT" ) <> "U"
												cSeqEve := oXmlRet:_PROCEVENTOCTE:_RETEVENTOCTE:_INFEVENTO:_NSEQEVENTO:TEXT
											else
												cSeqEve := "01"
											EndIf

											If len(cSeqEve)<=len( (xZBE)->(FieldGet(FieldPos(xZBE_+"SEQEVE"))) )
												cSeqEve := StrZero( Val(cSeqEve), len( (xZBE)->(FieldGet(FieldPos(xZBE_+"SEQEVE"))) ), 0 )
											Endif

											dDhAut  := ctod( "" )

											If Type( "oXmlRet:_PROCEVENTOCTE:_RETEVENTOCTE:_INFEVENTO:_DHREGEVENTO:TEXT" ) <> "U"
												cDthRet := oXmlRet:_PROCEVENTOCTE:_RETEVENTOCTE:_INFEVENTO:_DHREGEVENTO:TEXT
												dDhAut  := StoD(substr(cDthRet,1,4)+Substr(cDthRet,6,2)+Substr(cDthRet,9,2))
											EndIf

											Reclock(xZBE,.T.)

											(xZBE)->(FieldPut(FieldPos(xZBE_+"CHAVE") , cKey      )) //cKey+cEvento+cSeqEve
											(xZBE)->(FieldPut(FieldPos(xZBE_+"FILIAL"), _cFil  ))
											(xZBE)->(FieldPut(FieldPos(xZBE_+"XML") , cXml      )) //cKey+cEvento+cSeqEve
											(xZBE)->(FieldPut(FieldPos(xZBE_+"TPEVE") , cEve   ))
											(xZBE)->(FieldPut(FieldPos(xZBE_+"DESC") , CDes   ))
											(xZBE)->(FieldPut(FieldPos(xZBE_+"SEQEVE"), cSeqEve   ))
											(xZBE)->(FieldPut(FieldPos(xZBE_+"DTHRGR"), cDTTime   ))
											(xZBE)->(FieldPut(FieldPos(xZBE_+"PROT"), cPro   ))
											(xZBE)->(FieldPut(FieldPos(xZBE_+"STATUS"), cSta ))
											(xZBE)->(FieldPut(FieldPos(xZBE_+"DHAUT"), dDhAut ))
											(xZBE)->(FieldPut(FieldPos(xZBE_+"DTRECB"), ddatabase ))
											(xZBE)->(FieldPut(FieldPos(xZBE_+"EVENTO"), cXCorrecao ))

											(xZBE)->(MsUnLock())

										Endif

									EndIf

								Next nX

								//Caso tenha sido realizado carga completa
								//Muda o parametro para nao baixar tudo novamente na proxima chamada
								if cNSUZero == "S"
									PutMv("XM_NSUZERO","N")
								EndIf

								//CASO O EVENTO POSSUA NUMERO DE NSU MAIOR QUE O ULTIMO DO ARRAY
								// DA NFE, ENTAO ASSUME ESTE (SEMPRE CONSIDERAR O MAIOR)
								IF nCodNSU > _MaiorCTENsu
									cFilant := cBkpFil
									PutMv("XM_NSUCTE", StrZero( nCodNSU,15 ))
									_NsuCtrl := nCodNSU
									_MaiorCTENsu := nCodNSU
								ENDIF

								//VerificaÁ„o necessaria para nao ficar em loop
								if nCodNsu = 0

									lCfeProc := .f.

								endif

								oRest := NIL
								FreeObj(oRest)
								aNotas := {}
								aEventos := {}

							else

								if !Empty( oRest:GetResult() )

									Telaoff("Falha no retorno da api",oRest:GetResult())

									oRest := NIL
									FreeObj(oRest)
									aNotas := {}
									aEventos := {}
									Return

								endif

							Endif
							//--------------------------------------------------------------------------
							// FIM CTE
							//--------------------------------------------------------------------------
						ENDIF

						aNotas := {}
						aEventos := {}

					ENDDO

					//----------------------------------------------------------//
					//FR - 28/10/2021 - DAIKIN - CADASTRO AUTOM¡TICO FORNECEDOR 
					//----------------------------------------------------------//
					If cAutoSA2D == "S" //.and. cModelo == "55" //FR - 21/12/2021 - se cadastra autom·tico no download do xml
						cCNPJEmi := ""
						xRecZBZ  := 0
						xChaveZBZ:= ""
						xRecZBZ  := 0
						i        := 0

						For nX := 1 to len(xNotas)  //oObjJson:NOTAS[1]:XML								
																							
							For i := 1 to Len(xNotas[nX])
								cCNPJEmi := xNotas[nX,i]:CNPJ
								xChaveZBZ:= xNotas[nX,i]:CHAVE

								(xZBZ)->(OrdSetFocus(3))  //ZBZ_CHAVE
								If (xZBZ)->(DbSeek(alltrim(xChaveZBZ)))
									xRecZBZ := (xZBZ)->(Recno())
									If xRecZBZ > 0
										U_fCADSA2(cCNPJEmi,xRecZBZ)			//fCADSA2(cCNPJEmi,xRECZBZ) //aqui ainda n„o tem o Recno da ZBZ porque ainda n„o gravou
									Endif 
								Endif 
							Next i
								
						Next							 			
					Endif 
					//----------------------------------------------------------//
					//FR - 28/10/2021 - DAIKIN - CADASTRO AUTOM¡TICO FORNECEDOR 
					//----------------------------------------------------------//
				EndIf

			EndIf

			// Liberar o semaforo
			GlbUnlock()
			ConOut('Semaforo da inst‚ncia ' + cLogUser + ' liberado!')

		ENDIF

	ELSE

		ConOut( "Rotina em uso por outro usu·rio. Aguarde alguns minutos e tente novamente ")

		if !IsBlind()
			FwAlertInfo('Rotina em uso por outro usu·rio. Aguarde alguns minutos e tente novamente - ' + cLogUser, "Rotina em ExecuÁ„o")
		ENDIF

	ENDIF

Return

// Wrapper para FwLogMsg
//static function FwLogMsgW(cMens)
//	FwLogMsg('INFO', , 'LOCK', FunName(), '', '01', cMens, 0, 0, {})
//return

//----------------------------------------------------------------------------------------
// Grava Registros ZBZ  - Futura Rotina Central
// 05/10/2022 - Atualmente, sÛ È acionada na gravaÁ„o de CTE
//----------------------------------------------------------------------------------------
Static Function GeraZBZ(oXmlRet,cChaveXml,cModelo,lAppend,nX,cLogProc,cStatus,cTomaCnpj,cCdToma)

	Local cCodEmit 	:= ""
	Local cLojaEmit	:= ""
	Local cRazao   	:= ""
	Local cTAG      := "CTE"
	Local cCNPJEmi  := ""
	Local cSeriNF   := ""

	nBASCAL := 0
	nICMVAL := 0
	nICMDES := 0
	nSTBASE := 0
	nSTVALO := 0
	nIPIVAL := 0
	nIPIDEV := 0
	nPISVAL := 0
	nCOFVAL := 0
	nOUTVAL := 0

	//	If oXmlRet:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ:TEXT = cCnpj

	//SAVE oXmlRet XMLFILE cChaveArq
	HFGRVXML( @oXmlRet, cChaveXml, cModelo )

	nUf	:= aScan(aUF,{|x| x[2] == &("oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_CUF:TEXT") })
	cUf := aUF[nUf][1]

	Reclock(xZBZ,lAppend)

	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CHAVE"), cChaveXml))  //Colocado no Ìnicio como prioridade de gravaÁ„o
	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"FILIAL"), _cFil))

	MsUnLock()

	Reclock(xZBZ,.F.)

	VerFor(aNotas[nX]:CNPJ,@cCodEmit,@cLojaEmit,@cRazao)

	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CNPJ"), aNotas[nX]:CNPJ))
	cCNPJEmi := aNotas[nX]:CNPJ

	//FR - 22/12/2022 - TRATAMENTO PARA PEGAR A RAZ√O SOCIAL QUANDO A FUN«√O VERFOR N√O CONSEGUIU LOCALIZAR O CAD. FORNECEDOR
	If Empty(cRazao)
		If  Type( "oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_EMIT:_XNOME:TEXT" ) <> "U"
			cRazao := Alltrim( &("oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_EMIT:_XNOME:TEXT") )
		Endif 
	Endif 
	//FR - 22/12/2022 - TRATAMENTO PARA PEGAR A RAZ√O SOCIAL QUANDO A FUN«√O VERFOR N√O CONSEGUIU LOCALIZAR O CAD. FORNECEDOR

	If Type( "oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_DEST:_CNPJ:TEXT" ) <> "U"
		(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CNPJD"), &("oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_DEST:_CNPJ:TEXT")))
	else
		If Type( "oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_DEST:_CPF:TEXT" ) <> "U"
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CNPJD"), &("oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_DEST:_CPF:TEXT")))
		endif
	endif
	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CLIENT"), &("oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_DEST:_XNOME:TEXT")))
	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"SERIE"), &("oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_SERIE:TEXT") ))
	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"NOTA"), U_NumNota(aNotas[nX]:NOTA,nFormNfe)))
	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"FORNEC"), cRazao ))
	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"TOMA"), cCdToma ))
	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CNPJT"), cTomaCnpj ))
	
	//FR - 22/12/2022 - BRASMOLDE - NOTIFICA«’ES
	cSeriNF := &("oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_SERIE:TEXT")
	
	//Tratamento para CFOP
	cCfopDoc := &("oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_CFOP:TEXT")
	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CFOP"), &("oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_CFOP:TEXT")))

	//grava tipo da rotina: M-Manual ; J-Job aqui no caso È Manual
	_TpRot := ""

	If IsBlind()
		_TpRot := "J"
	else
		_TpRot := "M"
	ENDIF

	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPROT"), _TpRot ))		//GRAVAR COMO M-Manual, pois esta rotina È chamada manualmente pelo usu·rio


	//Tratativa de Vers„o
	cVerXml := ""
	cTagVerXml :=  "oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_VERSAO:TEXT"

	If Type(cTagVerXml) <> "U"

		cVerXml := &(cTagVerXml)
	ENDIF

	If (xZBZ)->(FieldPos(xZBZ_+"VERSAO")) > 0
		(xZBZ)->(FieldPut(FieldPos(xZBZ_+"VERSAO"), cVerXml))
	EndIf


	/* acrecentando tag <tpCTE>, pois no protheus o campo esta obrigatÛrio.  */
	cTpCte := ""
	cTagTpCte	:=	"oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_TP"+cTAG+":TEXT"

	if type(cTagTpCte) <> "U"
		cTpCte := &(cTagTpCte)
	endif

	If (xZBZ)->(FieldPos(xZBZ_+"TPCTE")) > 0

		If Type( cTagTpCte ) <> "U"

			Do Case
				Case cTpCte == "0"
					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPCTE"), "N"))
				Case cTpCte == "1"
					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPCTE"), "C"))
				Case cTpCte == "2"
					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPCTE"), "A"))
				Case cTpCte == "3"
					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPCTE"), "S"))
			EndCase
			//	else
			//		(xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPCTE"), "N" ))
		EndIf

	EndIf

	If cModelo == "57"

		nAliqCTE := 0
		nBASCAL := 0
		nICMVAL := 0


		//cTagDtEmit := "oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_DHEMI:TEXT"
		cTagDocDest:= "oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_REM:_CNPJ:TEXT"
		cTagAliq   := "oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IMP:_ICMS:_ICMS00:_PICMS:TEXT"
		//Incluindo a TAG ICMS20 pelo Analista Alexandro de Oliveira - 16/12/2014
		cTagAliq1  := "oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IMP:_ICMS:_ICMS20:_PICMS:TEXT"

		If Type(cTagAliq)<> "U"
			nAliqCTE   := Val(&(cTagAliq))
		ElseIf Type(cTagAliq1)<>"U"
			nAliqCTE  := Val(&(cTagAliq1))
		EndIf

		cTagBase   := "oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IMP:_ICMS:_ICMS00:_VBC:TEXT"
		//Incluindo a TAG ICMS20 pelo Analista Alexandro de Oliveira - 16/12/2014
		cTagBase1  := "oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IMP:_ICMS:_ICMS20:_VBC:TEXT"

		If Type(cTagBase)<> "U"
			nBASCAL   := Val(&(cTagBase))
		ElseIf Type(cTagBase1)<> "U"
			nBASCAL   := Val(&(cTagBase1))
		EndIf

		cTagAux := ("oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_TOTAL:_ICMSTOT:_VICMS:TEXT")
		If type( cTagAux ) <> "U"
			nICMVAL := val(&cTagAux)
		Endif

		//-------------------------------------------------------------------------------//
		//FR - 04/06/2020 - Projeto CCM - novo campo origem prestaÁ„o serviÁo ZBZ_ORIPRT
		//-------------------------------------------------------------------------------//
		xMunIni := ""
		cTagAux := "oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_XMUNINI:TEXT"

		if type(cTagAux) <> "U"
			xMunIni := &(cTagAux)
		endif

		xUFIni := ""
		cTagAux := "oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_UFINI:TEXT"

		if type(cTagAux) <> "U"
			xUFIni := &(cTagAux)
		endif

		If (xZBZ)->(FieldPos(xZBZ_+"ORIPRT")) > 0
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"ORIPRT"), (xMunIni + "-" + xUFIni) ))
		Endif


		//Valor de Carga
		//Melhoria da Belenzier pneu para incluir o campo de valor total da carga
		nVlCarga := 0
		cTagVCarga := "oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_INFCTENORM:_INFCARGA:_VCARGA:TEXT"

		if Type(cTagVCarga) <> "U"

			nVlCarga := noRound( Val( &(cTagVCarga) ), 2)

		endif
		if (xZBZ)->(FieldPos(xZBZ_+"VCARGA")) > 0
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"VCARGA"), nVlCarga ))
		endif

	ELSE

		nBASCAL := val(&("oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_TOTAL:_ICMSTOT:_VBC:TEXT"))
		nICMVAL := val(&("oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_TOTAL:_ICMSTOT:_VICMS:TEXT"))
		nICMDES := val(&("oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_TOTAL:_ICMSTOT:_VICMSDESON:TEXT"))
		nSTBASE := val(&("oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_TOTAL:_ICMSTOT:_VBCST:TEXT"))
		nSTVALO := val(&("oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_TOTAL:_ICMSTOT:_VST:TEXT"))
		nIPIVAL := val(&("oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_TOTAL:_ICMSTOT:_VIPI:TEXT"))
		nIPIDEV := val(&("oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_TOTAL:_ICMSTOT:_VIPIDEVOL:TEXT"))
		nPISVAL := val(&("oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_TOTAL:_ICMSTOT:_VPIS:TEXT"))
		nCOFVAL := val(&("oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_TOTAL:_ICMSTOT:_VCOFINS:TEXT"))
		nOUTVAL := val(&("oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_TOTAL:_ICMSTOT:_VOUTRO:TEXT"))

	ENDIF

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

	if Empty(  (xZBZ)->(FieldGet(FieldPos(xZBZ_+"DTRECB")))  )   //Gravar sÛ se Tiver Vazio
		(xZBZ)->(FieldPut(FieldPos(xZBZ_+"DTRECB"), dDataBase))
	endif

	dEmissao	:= stod(;
		substr(&("oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_DHEMI:TEXT"),1,4)+;
		substr(&("oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_DHEMI:TEXT"),6,2)+;
		substr(&("oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_DHEMI:TEXT"),9,2);
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

	//(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PRENF"), "B"))
	//(xZBZ)->(FieldPut(FieldPos(xZBZ_+"STATUS"), "1"))
	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"OBS"), ""))
	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"MODELO"), cModelo))
	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CODFOR"), cCodEmit))
	//(xZBZ)->(FieldPut(FieldPos(xZBZ_+"INDRUR"), cIndRur))
	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"LOJFOR"), cLojaEmit))
	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPDOC"), "N"))
	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"UF"), cUf ))
	//(xZBZ)->(FieldPut(FieldPos(xZBZ_+"SERORI"), cSerXMl))

	nVLLIQ  := 0
	cTagAux := "oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_TOTAL:_ICMSTOT:_vProd:TEXT"

	if type(cTagAux) <> "U"
		nVLLIQ := noRound( Val( &(cTagAux) ), 2)
	endif

	nVLDESC := 0
	cTagAux := "oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_TOTAL:_ICMSTOT:_vDesc:TEXT"

	if type(cTagAux) <> "U"
		nVLDESC := noRound( Val( &(cTagAux) ), 2)
	endif

	nVLIMP := 0
	cTagAux := "oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_TOTAL:_ICMSTOT:_vST:TEXT"
	if type(cTagAux) <> "U"
		nVLIMP += noRound( Val( &(cTagAux) ), 2 )
	endif

	cTagAux := "oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_TOTAL:_ICMSTOT:_vII:TEXT"
	if type(cTagAux) <> "U"
		nVLIMP += noRound( Val( &(cTagAux) ), 2 )
	endif

	cTagAux := "oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_TOTAL:_ICMSTOT:_vIPI:TEXT"
	if type(cTagAux) <> "U"
		nVLIMP += noRound( Val( &(cTagAux) ), 2 )
	endif

	nVLBRUT  := 0
	cTagAux := "oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_VPREST:_VTPREST:TEXT"
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

	NumSerie := &("oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_SERIE:TEXT")


	cTagAux:= "oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_TPEMIS:TEXT"

	If (xZBZ)->(FieldPos(xZBZ_+"TPEMIS"))>0 

		if Type( cTagAux ) <> "U" .And. !Empty(cTagAux)
			(xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPEMIS"), &(cTagAux) ))
		Endif

	EndIf

	//TRATATIVA PARA GRAVA«√O DA OBS

	//Motivo
	cMotivo := ""
	cTagAux   := "oXmlRet:_"+cTAG+"PROC:_PROT"+cTAG+":_INFPROT:_XMOTIVO:TEXT"

	if Type(cTagAux) <> "U"
		cMotivo := &(cTagAux)
	endif

	//DigVal
	cDigVal := ""
	cTagAux   := "oXmlRet:_"+cTAG+"PROC:_PROT"+cTAG+":_INFPROT:_DIGVAL:TEXT"

	if Type(cTagAux) <> "U"
		cDigVal := &(cTagAux)
	endif

	//DigVal
	//---------------------------------------------------------------------------
	cProtocolo := ""
	cTagAux   := "oXmlRet:_"+cTAG+"PROC:_PROT"+cTAG+":_INFPROT:_NPROT:TEXT"

	if Type(cTagAux) <> "U"
		cProtocolo := &(cTagAux)
	endif

	If (xZBZ)->(FieldPos(xZBZ_+"PROT")) > 0
		(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PROT"), cProtocolo))
	EndIf
	//---------------------------------------------------------------------------

	//Ambiente
	//---------------------------------------------------------------------------
	cTagTpAmb := ""
	cTagAux   := "oXmlRet:_"+cTAG+"PROC:_PROT"+cTAG+":_INFPROT:_TPAMB:TEXT"

	if Type(cTagAux) <> "U"
		cTagTpAmb := &(cTagAux)
	endif

	If (xZBZ)->(FieldPos(xZBZ_+"TPAMB")) > 0
		(xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPAMB"), cTagTpAmb ))
	EndIF

	//---------------------------------------------------------------------------

	cRet := "Chave: " + cChaveXml + CRLF
	cRet += "Modelo: " + cModelo + CRLF
	cRet += "Vers„o da mensagem: " + cVerXml + CRLF
	cRet += "Ambiente: " + iif(cTagTpAmb == "1","ProduÁ„o","HomologaÁ„o") + CRLF
	cRet += "Protocolo: " + cProtocolo +  CRLF
	cRet += "Status: "+ cStatus + CRLF
	cRet += "Motivo: " + cMotivo + CRLF
	cRet += "Num.Serie:" + NumSerie +CRLF
	cRet += "Digest Value: " + cDigVal + CRLF

	(xZBZ)->(FieldPut(FieldPos(xZBZ_+"OBS"), cRet))
	DbSelectArea(xZBZ)
	MsUnLock()


	U_fGravaZBT(cXmlRet,cModelo,cChaveXml,strZero(aNotas[nX]:NOTA,nFormNfe),NumSerie,aNotas[nX]:CNPJ)

	cLogProc += "[XML] "+cChaveXml+" gravado com sucesso."+CRLF

	//----------------------------------------------------------------------------------------------------//
    //FR - 22/12/2022 - PROJETO BRASMOLDE - NOTIFICA«’ES POR EMAIL QDO BAIXA XML
    //Depois de Gravar ZBZ e ZBT aciona rotina que dispara email caso esteja parametrizado para receber
    //----------------------------------------------------------------------------------------------------//
    If lAppend  //sÛ processa se for inclus„o (caso j· tenha sido gravado via rotina HFXML02, n„o entra aqui)
		cMail10 := GetNewPar("XM_MAIL10",Space(256))  //FR - 21/12/2022 - Fl·via Rocha - EMAIL AVISANDO SOBRE NOVO XML GRAVADO NA BASE	
		cCfBenef:= Padr(GetNewPar("XM_CFBENEF",Space(256)),256)	

		If !Empty(cMail10) //emails que receber„o notificaÁ„o qdo gravar xml na base
					
			cFornec  := ""
			cLojFor  := ""
			cNomeFor := ""	
			nFormNfe := Val(GetNewPar("XM_FORMNFE","9"))	

			//cAssunto := "Nota Fiscal N„o Importada Com Sucesso"
			cAssunto := "ImportaÁ„o NFe: " + StrZero(cNumNota,nFormNfe) + "/" + cSeriNF
			cTipo    := "1"  //download ok

			aMsg    := {}	

			If cCfopDoc $ cCfBenef  //se o CFOP do XML est· contido em CFOPs de beneficiamento, pega do cad. cliente:
				cFornec  := Posicione("SA1",3,xFilial("SA1")+ cCNPJEmi,"A1_COD")
				cLojFor  := Posicione("SA1",3,xFilial("SA1")+ cCNPJEmi,"A1_LOJA")
				cNomeFor := Posicione("SA1",1,xFilial("SA1")+ cFornec + cLojFor,"A1_NOME")
				cTpCliFor:= "Cliente"

			Elseif cCfopDoc $ cCfDevol  //se o CFOP do XML est· contido em CFOPs de devoluÁ„o, pega do cad. cliente:
				cFornec  := Posicione("SA1",3,xFilial("SA1")+ cCnpjEmi,"A1_COD")
				cLojFor  := Posicione("SA1",3,xFilial("SA1")+ cCnpjEmi,"A1_LOJA")
				cNomeFor := Posicione("SA1",1,xFilial("SA1")+ cFornec + cLojFor,"A1_NOME")			
				cTpCliFor:= "Cliente"
			Else 
				cFornec  := Posicione("SA2",3,xFilial("SA2")+ cCNPJEmi,"A2_COD")
				cLojFor  := Posicione("SA2",3,xFilial("SA2")+ cCNPJEmi,"A2_LOJA")
				cNomeFor := Posicione("SA2",1,xFilial("SA2")+ cFornec + cLojFor,"A2_NOME")
				cTpCliFor:= "Fornecedor"
			Endif

			
			cAssunto += "- Forn: " + cFornec + "/" + cLojFor + "-" + cNomeFor + " - PENDENTE"
					
			U_FNOTIFICA(cMail10,cTipo,cFornec, cLojfor, cNomeFor,cRazao,cNumNota,cSeriNF,nFormNfe,dEmissao,cMotivo,"CTE",cChaveXml,cTpCliFor)
					
			//MODELO
			//Assunto  - Nota Fiscal n„o importada com sucesso 
			//Conte˙do 
			//Fornecedor......: 000996 - TE CONNECTIVITY BRASIL IN
			//Nota Fiscal.....: 000196943/1 - Emiss„o: 19/04/2021
			//Chave da NFe....: 35210400907845001560550010001969431286545563
			//SituaÁ„o SEFAZ..: 100 - Autorizado o uso da NF-e
			
		Endif
	Endif  
    //FR - 22/12/2022 - PROJETO BRASMOLDE - NOTIFICA«’ES POR EMAIL QDO BAIXA XML

RETURN

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
	Local cFilSeek  := ""

	DbSelectArea("SA2")
	DbSetOrder(3)
	cFilSeek := xFilial("SA2")

	If DbSeek(cFilSeek+cCnpjEmi)
		cCodEmit  := SA2->A2_COD
		cLojaEmit := SA2->A2_LOJA
		cRazao    := SA2->A2_NOME
		Do While .not. SA2->( eof() ) .and. SA2->A2_FILIAL == cFilSeek .and.;
				SA2->A2_CGC == cCnpjEmi
			//if SA2->A2_MSBLQL != "1"
				cCodEmit  := SA2->A2_COD
				cLojaEmit := SA2->A2_LOJA
				cRazao    := SA2->A2_NOME
				exit
			//endif
			SA2->( dbSkip() )
		EndDo
	Else
		cCodEmit  := ""
		cLojaEmit := ""
		cRazao    := ""
	EndIf

	RestArea( aArea )

Return( .T. )

User Function TesteNVM(cToken)

	Local cUrl 			:= ""
	Local cPath 		:= ""
	Local oRestClient 	:= Nil
	Local aHeader 		:= {}
	Local cMensagem		:= ""
	Local lConectou		:= .F.
	Local cCnpj 		:= Alltrim(FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , { "M0_CGC" } )[1][2])
	Local oObjJson		:= Nil

	cToken  			:= alltrim(cToken)

	Aadd(aHeader, "Content-Type: application/json")
	Aadd(aHeader, "Accept-Charset: UTF-8")

	cUrl  := "https://cloud.importaxml.com.br"
	cPath := "/api/VerificaConexao"

	oRestClient := FWRest():New( cUrl )
	oRestClient:SetPath( cPath )

	If oRestClient:Get(aHeader)
		cMensagem := "Conex„o a API: "+DecodeUtf8(oRestClient:GetResult())
		lConectou := .T.
	Else
		cMensagem := "Conex„o a API: Falha na conex„o"
		lConectou := .F.
	Endif

	oRestClient := NIL
	FreeObj(oRestClient)

	If lConectou

		cPath := "/api/VerificaTokenEmpresa?token="+cToken+"&cnpj="+cCnpj
		cMensagem += CRLF

		oRestClient := FWRest():New( cUrl )
		oRestClient:SetPath( cPath )

		If oRestClient:Get(aHeader)

			If !FWJsonDeserialize(oRestClient:GetResult(), @oObjJson)
				MsgStop("Ocorreu erro no processamento do Json")
				Return Nil
			EndIf

			cMensagem += "ValidaÁ„o Token: "+DecodeUtf8(oObjJson:MENSAGEM)
		Else
			cMensagem += "ValidaÁ„o Token: Falha na validaÁ„o"
		Endif

	EndIf

	msgInfo(cMensagem)

	oRestClient := NIL
	FreeObj(oRestClient)

	Conout("Fim da rotina de teste de conex„o - HFXMLNVM " + TIME() )

Return .T.





////////////////////////////////////////////////////////////////
// FunÁ„o: ConsoleLog                                         //
// Autor: RogÈrio Rafael Lino                                 //
// DescriÁ„o: Trata o erro de integraÁ„o Nuvem.               //
// Data: 06/06/2022                                           //
////////////////////////////////////////////////////////////////
Static Function TelaOff( cTit, cMens )

	if !IsBlind()
		FWAlertInfo(cMens, cTit)
	else
		Conout(cTit + CRLF + cMens)
	endif

Return()


////////////////////////////////////////////////////////////////
// FunÁ„o: ConsoleLog                                         //
// Autor: RogÈrio Rafael Lino                                 //
// DescriÁ„o: Gera um log de eventos.                         //
// Data: 06/06/2022                                           //
////////////////////////////////////////////////////////////////

Static Function ConsoleLog(cTipo,cMsg)

	Local cArqTxt := GetTempPath() + "LogNuvem.txt"
	Local nHdl := fCreate(cArqtxt)

	if nHdl == -1
		MsgAlert("O arquivo de nome "+cArqtxt+" nao pode ser executado ! Verifique os parametros.","AtenÁ„o !")
		Return
	Endif

	cLin := cMsg + CRLF

	//Grava no arquivo texto
	if fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)

		if !MsgAlert("Ocorreu um erro na gravacao do arquivo." + "Continua !","Atencao !")

		endif

	endif

	//Fecha o arquivo texto
	fClose(nHdl)

Return(.T.)


////////////////////////////////////////////////////////////////
// FunÁ„o: ConsoleLog                                         //
// Autor: RogÈrio Rafael Lino                                 //
// DescriÁ„o: Gera um log de eventos.                         //
// Data: 06/06/2022                                           //
////////////////////////////////////////////////////////////////
Static Function ConsoleEvent(cTipo,cMsg)

	ConOut("")
	ConOut("----------------------------Mensagem LogNuvem-------------------------------")
	ConOut("Tipo: " + cTipo)
	ConOut("MSG : " + cMsg)
	ConOut("-------------------------------------------------------------------------------")
	ConOut("")

Return(.T.)



////////////////////////////////////////////////////////////////
// FunÁ„o: HFAjuXML                                           //
// Autor: Henrique Tofanelli                                  //
// DescriÁ„o: CentralizaÁ„o da FunÁ„o de Ajustes do XML parse //
// Data: 08/06/2022                                           //
////////////////////////////////////////////////////////////////

User Function HFAjuXML(cVarXML)

	Local cBkpXml := ""
	//Faz backup do xml sem retirar os caracteres especiais
	cBkpXml := cVarXML

	cVarXML := EncodeUTF8(cVarXML)
	cVarXML := FwNoAccent(cVarXML)

	//Executa rotina para retirar os caracteres especiais
	cVarXML := u_zCarEspec( cVarXML )

Return(cVarXML)
////////////////////////////////////////////////////////////////
// FunÁ„o: HFValCTe                                           //
// Autor: Henrique Tofanelli                                  //
// DescriÁ„o: CentralizaÁ„o da FunÁ„o de ValidaÁıes CTE       //
// Data: 24/06/2022                                           //
////////////////////////////////////////////////////////////////

Static Function HFValCTe(oXmlRet,cTAG,cChaveNf)

	Local aValCTe  := {}
	Local aInfCTE := {}
	Local cTagTom3 := "oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_TOMA3:_TOMA:TEXT" 	//PEGA O TIPO 
	Local _cTagTom3 := "oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_TOMA3:_CNPJ:TEXT"	//PEGA O CNPJ

	Local cTagTom4 := "oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_TOMA4:_CNPJ:TEXT"		//PEGA CNPJ
	Local xTagTom4 := "oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_TOMA4:_TOMA:TEXT"		//PEGA O TIPO

	Local cTagEmit := "oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_EMIT:_CNPJ:TEXT"
	Local cTagRem  := "oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_REM:_CNPJ:TEXT"
	Local cTagExp  := "oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_EXPED:_CNPJ:TEXT"
	Local cTagRec  := "oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_RECEB:_CNPJ:TEXT"
	Local cTagDest := "oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_DEST:_CNPJ:TEXT"
	Local cTagResp := "oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_INFRESPTEC:_CNPJ:TEXT"

	Local cTagIE := ""

	Local cTomador := ""
	Local cCnpEmit := ""
	Local cCnpRem := ""
	Local cCnpExp := ""
	Local cCnpRec := ""
	Local cCnpDest := ""
	Local cCnpResp := ""
	Local cIEtxt := ""
	Local cXFilial := ""
	Local cCnpjToma := ""
	Local cRetFil0 := ""
	Local cRetFil1 := ""
	Local cRetFil2 := ""
	Local cRetFil3 := ""
	Local cRetFil4 := ""
	Local cRetFil  := ""

	/*
	Tag do XML: toma3 -> toma
	Indicador do "papel" do tomador do serviÁo no CT-e.
	0-Remetente;
	1-Expedidor;
	2-Recebedor;
	3-Destinat·rio.
	*/

	Conout("[HFValCTe] Verificando CTe Chave: "+cChaveNf)


	//---------------------------------------------------------------------------------------
	//PAPEL DO TOMADOR
	//---------------------------------------------------------------------------------------
	/*
	Local cTagTom3 := "oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_TOMA3:_TOMA:TEXT" 	//PEGA O TIPO 
	Local _cTagTom3 := "oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_TOMA3:_CNPJ:TEXT"	//PEGA O CNPJ

	Local cTagTom4 := "oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_TOMA4:_CNPJ:TEXT"		//PEGA CNPJ
	Local xTagTom4 := "oXmlRet:_"+cTAG+"PROC:_"+cTAG+":_INF"+cTAG+":_IDE:_TOMA4:_TOMA:TEXT"		//PEGA O TIPO
	*/
	cTagIE := StrTran(cTagTom3, "_CNPJ", "_IE")
	cCnpjToma := ""
	If Type(cTagTom3) <> "U"
		cTomador := &(cTagTom3)  //PEGA O TIPO
		if type(_cTagTom3) <> "U"  //PEGA O CNPJ
			cCnpjToma := &(_cTagTom3)
		endif
		
	else
		//cTagTom3 := StrTran(cTagTom3, "_TOMA3", "_TOMA4")  //FR - 30/05/2023 - CIMENTOS ITAMB… - TOMADOR NA FILIAL ERRADA
		//verifica se tem a tag toma4
		//If Type(cTagTom3) <> "U"
		//	cTomador := &(cTagTom3)
		//	if type(cTagTom4) <> "U"
		//		cCnpjToma := &(cTagTom4)
		//	endif
		//Endif
		If Type(xTagTom4) <> "U"
			cTomador := &(xTagTom4)
			if type(cTagTom4) <> "U"
				cCnpjToma := &(cTagTom4)
			endif
		Endif

	Endif

	aadd(aValCTe,{"TOMADOR",{cTomador,cCnpjToma,""}})

	//---------------------------------------------------------------------------------------
	//CNPJ DESTINATARIO
	//---------------------------------------------------------------------------------------

	cTagIE := StrTran(cTagDest, "_CNPJ", "_IE")
	cIEtxt := ""
	cXFilial := ""

	If Type(cTagDest) <> "U"
		cCnpDest := &(cTagDest)
	else

		cTagDest := StrTran(cTagDest, "_CNPJ", "_CPF")

		If Type(cTagDest) <> "U"
			cCnpDest := &(cTagDest)
		Endif

	Endif

	IF Type(cTagIE) <> "U"
		cIEtxt := &(cTagIE)
	ELSE
		CONOUT("DESTINATARIO SEM IE")
	ENDIF

	IF !Empty(cCnpDest)
		cXFilial := HFRetFil(cCnpDest, cIEtxt)
	ENDIF

	aadd(aValCTe,{"DESTINATARIO",{cCnpDest,cIEtxt,cXFilial}})

	//Regra 1
	cRetFil3 := cXFilial

	//---------------------------------------------------------------------------------------
	//CNPJ RECEBEDOR
	//---------------------------------------------------------------------------------------
	cTagIE := StrTran(cTagRec, "_CNPJ", "_IE")
	cIEtxt := ""
	cXFilial := ""
	If Type(cTagRec) <> "U"
		cCnpRec := &(cTagRec)
	else
		cTagRec := StrTran(cTagRec, "_CNPJ", "_CPF")

		If Type(cTagRec) <> "U"
			cCnpRec := &(cTagRec)
		Endif

	Endif

	IF Type(cTagIE) <> "U"
		cIEtxt := &(cTagIE)
	ELSE
		CONOUT("RECEBEDOR SEM IE")
	ENDIF

	IF !Empty(cCnpDest)
		cXFilial := HFRetFil(cCnpRec, cIEtxt)
	ENDIF

	aadd(aValCTe,{"RECEBEDOR",{cCnpRec,cIEtxt,cXFilial}})

	//Regra 2
	cRetFil2 := cXFilial

/*
	//---------------------------------------------------------------------------------------
	//CNPJ EMITENTE
	//---------------------------------------------------------------------------------------
	cTagIE := StrTran(cTagEmit, "_CNPJ", "_IE")
	cIEtxt := ""
	cXFilial := ""
	If Type(cTagEmit) <> "U"
		cCnpEmit := &(cTagEmit)
	else
		cTagEmit := StrTran(cTagEmit, "_CNPJ", "_CPF")

		If Type(cTagEmit) <> "U"
			cCnpEmit := &(cTagEmit)
		Endif

	Endif

	IF Type(cTagIE) <> "U"
		cIEtxt := &(cTagIE)
	ELSE
		CONOUT("EMITENTE SEM IE")
	ENDIF

	IF !Empty(cCnpEmit)
		cXFilial := HFRetFil(cCnpEmit, cIEtxt)
	ENDIF

	aadd(aValCTe,{"EMITENTE",{cCnpEmit,cIEtxt,cXFilial}})

	//Regra 3
	if Empty(cRetFil)
		cRetFil := cXFilial
		IF !EMPTY(cXFilial)
			ConOut("ENCONTROU FILIAL NO EMITENTE: "+cCnpExp+"-"+cXFilial)
		ENDIF
	endif
*/

	//---------------------------------------------------------------------------------------
	//CNPJ REMETENTE
	//---------------------------------------------------------------------------------------
	cTagIE := StrTran(cTagRem, "_CNPJ", "_IE")
	cIEtxt := ""
	cXFilial := ""
	If Type(cTagRem) <> "U"
		cCnpRem := &(cTagRem)
	else
		cTagRem := StrTran(cTagRem, "_CNPJ", "_CPF")

		If Type(cTagRem) <> "U"
			cCnpRem := &(cTagRem)
		Endif

	Endif

	IF Type(cTagIE) <> "U"
		cIEtxt := &(cTagIE)
	ELSE
		CONOUT("REMETENTE SEM IE")
	ENDIF

	IF !Empty(cCnpRem)
		cXFilial := HFRetFil(cCnpRem, cIEtxt)
	ENDIF

	aadd(aValCTe,{"REMETENTE",{cCnpRem,cIEtxt,cXFilial}})

	//Regra 4
	cRetFil0 := cXFilial

	//---------------------------------------------------------------------------------------
	//CNPJ EXPEDIDOR
	//---------------------------------------------------------------------------------------
	cTagIE := StrTran(cTagExp, "_CNPJ", "_IE")
	cIEtxt := ""
	cXFilial := ""
	If Type(cTagExp) <> "U"
		cCnpExp := &(cTagExp)
	else
		cTagExp := StrTran(cTagExp, "_CNPJ", "_CPF")

		If Type(cTagExp) <> "U"
			cCnpExp := &(cTagExp)
		Endif

	Endif

	IF Type(cTagIE) <> "U"
		cIEtxt := &(cTagIE)
	ELSE
		CONOUT("EXPEDIDOR SEM IE")
	ENDIF

	IF !Empty(cCnpExp)
		cXFilial := HFRetFil(cCnpExp, cIEtxt)
	ENDIF

	aadd(aValCTe,{"EXPEDIDOR",{cCnpExp,cIEtxt,cXFilial}})

	//Regra 5
	cRetFil1 := cXFilial

	//---------------------------------------------------------------------------------------
	//CNPJ RES. TECNICO
	//---------------------------------------------------------------------------------------
	cTagIE := StrTran(cTagResp, "_CNPJ", "_IE")
	cIEtxt := ""
	cXFilial := ""
	If Type(cTagResp) <> "U"
		cCnpResp := &(cTagResp)
		//cIEtxt := &(cTagIE)
	else

		cTagResp := StrTran(cTagResp, "_CNPJ", "_CPF")

		If Type(cTagResp) <> "U"
			cCnpResp := &(cTagResp)
			//cIEtxt := &(cTagIE)
		Endif

	Endif

	//IF !Empty(cCnpRem)
	//	cXFilial := HFRetFil(cCnpResp, cIEtxt)
	//ENDIF

	//OBS: PATA TAG RESP. TECNICO N√O H¡ INSCR ESTADUAL E NAO TEM NECESSIDADE DE BUSCAR FILIAL
	aadd(aValCTe,{"RESPTECNICO",{cCnpResp,cIEtxt,cXFilial}})



	//---------------------------------------------------------------------------------------
	//PEGA O CNPJ DO TOMADOR PARA GRAVA«√O NA TABELA
	//---------------------------------------------------------------------------------------
	/*
	Tag do XML: toma3 -> toma
	Indicador do "papel" do tomador do serviÁo no CT-e.
	0-Remetente;
	1-Expedidor;
	2-Recebedor;
	3-Destinat·rio.
	*/

	Do Case

		Case cTomador	==	'0' //Remetente

			cCnpjToma 	:=  cCnpRem
			cRetFil		:= cRetFil0

		Case cTomador	==	'1' //Expedidor

			cCnpjToma 	:=  cCnpExp
			cRetFil		:= cRetFil1

		Case cTomador	==	'2' //Recebedor

			cCnpjToma 	:=  cCnpRec
			cRetFil		:= cRetFil2

		Case cTomador	==	'3' //Destinat·rio

			cCnpjToma 	:=  cCnpDest
			cRetFil		:= cRetFil3

		Case cTomador	==	'4' // Tag TOMA4 j· carregou o cnpj

			//Variavel cCnpjToma j· est· carregada

		OtherWise

			cCnpjToma :=  cCnpRem

	EndCase

	//Regra Geral
	//Se n„o encontrou afilial pelos CNPJs das TAGS
	//Pega a filial Logada
	if Empty(cRetFil)
		cRetFil := xFilial(xZBZ)
	endif

	aadd(aInfCTE,{cRetFil, cCnpjToma, cTomador })


Return(aInfCTE)


Static Function HFRetFil(_cCnpj, _cInscrE)

	Local _CodFil := ""
	Local aArea   := SM0->( GetArea() )

	dbSelectArea("SM0")
	SM0->(dbSetOrder(1))
	SM0->(DbGoTop())

	While SM0->(!EoF())

		If Alltrim(SM0->M0_CGC) == _cCnpj .and.  alltrim(SM0->M0_INSC) == _cInscrE .AND. cEmpAnt == SM0->M0_CODIGO   //Alltrim(SM0->M0_CODIGO) == cEmpProc .and. SM0->M0_CGC == cTomador

			_CodFil := SM0->M0_CODFIL
			Exit

		EndIf

		SM0->(DbSkip())
	END

	if Empty( xFilial(xZBZ) )

		_CodFil := xFilial(xZBZ)

	endif

	RestArea( aArea )

Return(_CodFil)


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

	//Aqui estava antes disso, direto no procxml. La ficou sÛ o FOR e aqui È um a um.
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

	//cChaveArq := cDir + Substr(cChaveXml,1,44) + "-CloudNfe.xml"
	cChaveArq := _cDirDest + Substr(cChaveXml,1,44) + "-CloudNfe.xml"
	SAVE oXmlRet XMLFILE cChaveArq

Return( .T. )


Static Function CheckFil( cTomador )

	Local _lRet := .f.
	Local aArea := Getarea()
	Local nReg  := SM0->(recno())
	Local cEmpProc:= AllTrim(SM0->M0_CODIGO)
	//Local cFilProc:= AllTrim(SM0->M0_CODFIL)

	SM0->( dbgotop() )

	Do While !SM0->( Eof() )

		If Alltrim(SM0->M0_CODIGO) == cEmpProc .and. alltrim(SM0->M0_CGC) == cTomador
			_lRet := .t.
			Exit

		EndIf

		SM0->( dbskip() )

	EndDo

	SM0->(dbgoto( nReg ))

	RestArea( aArea )

Return _lRet
