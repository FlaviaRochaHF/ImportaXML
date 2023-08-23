#INCLUDE "TOTVS.CH"

Static lUnix  := IsSrvUnix()
Static cBarra := Iif(lUnix,"/","\")


User Function HFXML024()

Local cModelo := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"MODELO")))
Local lRet    := .T.
Local cMsgHelp:= ""

if cModelo == "57" .OR. cModelo == "67"

	EnvDes()

else

	cMsgHelp := "Evento de desacordo apenas para conhecimentos de frete."
	Help( " ", 1, "A103DESACORDO",,cMsgHelp,1,0) 
	lRet := .F.

endif

Return lRet


Static Function EnvDes()

Local cMsgHelp	:= ""
Local cMsgNoYes	:= ""
Local lRet      := .T.
Local nOpca    	:= 0
Local cString   := ""
Local oDlgObs
Local oGetObs
Local cClToken :=	alltrim(GetNewPar("XM_CLTOKEN",Space(256)))
Local cCloud   :=	alltrim(GetNewPar("XM_CLOUD" ,"0"))         //aCombo (0=Desbilitado 1=Habilitado) 
Local cCnpj    := ""
Local cXmlRet  := ""
Local oXmlRet
Local cError   := ""
Local cWarning := ""
Local cChave   := ""
Local oRest   
Local cBody		:= ""

Private aHeader:= {}
Private cUrl   := ""

cMsgNoYes := "Você deseja enviar o desacordo do CTE: " + CRLF + ; //"Você deseja enviar o desacordo do CTE: "
			 "Documento: " + AllTrim((xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA")))) + CRLF + ; //"Documento: "
			 "Serie: " + AllTrim((xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE")))) + CRLF + ; //"Serie: "
			 "Fornecedor: " + AllTrim((xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR")))) + CRLF + ; //"Fornecedor: "
			 "Loja: " + AllTrim((xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR")))) + CRLF + ; //"Loja: "
			 "Chave: " + AllTrim((xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE")))) + CRLF + ; //"Chave: "
			 " ?" + CRLF + CRLF + "Ao confirmar o envio, não será possível desfazer a ação." //"Ao confirmar o envio, não será possível desfazer a ação."

If Empty((xZBZ)->(FieldGet(FieldPos(xZBZ_+"IDDES")))) .Or. (xZBZ)->(FieldGet(FieldPos(xZBZ_+"IDDES"))) $ '0/1/5' //C 1,0 Id Desacordo

	cString := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"OBSDES"))) //M  Obs Desacordo
	
	DEFINE MSDIALOG oDlgObs TITLE "Observação - Evendo Desacordo" FROM 15,20 TO 24,60 //"Observação - Evendo Desacordo"
	
	DEFINE SBUTTON FROM 52, 101.8 TYPE 1 ENABLE OF oDlgObs ACTION ( nOpca := 1,oDlgObs:End() )
	DEFINE SBUTTON FROM 52, 128.9 TYPE 2 ENABLE OF oDlgObs ACTION ( nOpca := 2,oDlgObs:End() )

	@ 0.5,0.7  GET oGetObs VAR cString OF oDlgObs MEMO size 150,40
	
	ACTIVATE MSDIALOG oDlgObs	
	
	If nOpca == 1
		
		If !Empty(cString) .And. Len(AllTrim(cString)) >= 15 .And. Len(AllTrim(cString)) <= 255
			
			If MsgNoYes(cMsgNoYes)
			
				If RecLock(xZBZ,.F.)
				
					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"OBSDES")   , AllTrim(cString) ))
					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"IDDES")    , "1" ))
					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"STMNCT")   , "D" ))
					//ZBZ->ZBZ_OBSDES	:= AllTrim(cString)
					//ZBZ->ZBZ_IDDES	:= "1" //1=Aguardando retorno SEFAZ
					//ZBZ->ZBZ_STMNCT	:= "D" //D=Aguardando retorno SEFAZ evento desacordo
					(xZBZ)->(MsUnLock())

				Endif
				
				cIDEvento := ""  //IDENVDES()
				
				If Empty(cIDEvento)

					//Faz a Manifestação pelo Gestão da Nuvem - Rogério Lino dia 20/05/2022
					If cCloud == "1" //.and. cModelo == "55"

						oRest := NIL								
						FreeObj(oRest)

						cUrl 	:= "https://cloud.importaxml.com.br"
						cCnpj 	:= Alltrim(FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , { "M0_CGC" } )[1][2])
						cChave  := AllTrim((xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))))

						Aadd(aHeader, "Content-Type: application/json; charset=utf-8")                      
						Aadd(aHeader, "Connection: keep-alive")  

						oRest 	:= FWRest():New(cUrl)

						oRest:SetPath("/api/CTeEventoDesacordo")  		

						cString := U_fNoAcento(cString)

						cBody := 	'{' + CRLF
						cBody += 		'"Token": "'+ cClToken + '", ' + CRLF
						cBody +=		'"Chave": "'+ cChave + '", ' + CRLF
						cBody +=		'"descricao": "'+ cString + '" ' + CRLF
						cBody +=	'}' + CRLF

						oRest:SetPostParams(cBody)

						oRest:Post(aHeader) 

						If oRest:GetResult() <> Nil 
	
							cXmlRet := oRest:GetResult()

							cXmlRet := strTran(cXmlRet,'<retEventoCTe xmlns=\"http://www.portalfiscal.inf.br/cte\" versao=\"3.00\">','<retEventoCTe>')
							cXmlRet := strTran(cXmlRet,'<retEventoCTe versao=\"3.00\" xmlns=\"http://www.portalfiscal.inf.br/cte\">','<retEventoCTe>')
							cXmlRet := strTran(cXmlRet,'"','')

							oXmlRet := XmlParser( cXmlRet ,"_",@cError, @cWarning )

							If ( oXmlRet == NIL )

								oRest := NIL								
								FreeObj(oRest)
								Conout("Falha ao gerar Objeto XML : "+cError+" / "+cWarning)
								Return

							Endif
							
							cChave  := &(xZBZ+"_CHAVE")
							cEve    := "610110"

							//VERIFICA SE EXISTE A NOTA BAIXADA PARA PODER AMARRAR O EVENTO
							DbSelectArea(xZBZ)
							( xZBZ )->( DbSetOrder( 3 ) )
							lAchou  := (xZBZ)->(DbSeek(alltrim(cChave)))

							if lAchou

								cChave := PadR(cChave,TamSX3(xZBE_+"CHAVE")[1],Nil)
								cEve := PadR(cEve,TamSX3("B2_COD")[1],Nil)

								DbSelectArea(xZBE)
								DbSetOrder(1)
								//if !DbSeek(xFilial(xZBE)+cChave+alltrim(cEve))
													
									//cVersao := oXmlRet:_RETCONSSITNFE:_VERSAO:TEXT
									//cStatus := U_getSitConf(cEve)  //oXmlRet:_RETENVEVENTO:_RETEVENTO:_INFEVENTO:_CSTAT:TEXT
									cTpAmb  := oXmlRet:_RETEVENTOCTE:_INFEVENTO:_TPAMB:TEXT
									cDes    := ""//oXmlRet:_RETEVENTOCTE:_INFEVENTO:_XEVENTO:TEXT
									cxMotivo:= oXmlRet:_RETEVENTOCTE:_INFEVENTO:_XMOTIVO:TEXT

									Aviso("Evento Desacordo CTE",cxMotivo,{"OK"},3)

									cDes := ALLTRIM(cxMotivo) +" - " + ALLTRIM(CDes)

									cDTTime := U_FRDTHora(1,dDatabase, Time(),"")

									If Type( "oXmlRet:_RETEVENTOCTE:_INFEVENTO:_NPROT:TEXT" ) <> "U"
										cProtC := oXmlRet:_RETEVENTOCTE:_INFEVENTO:_NPROT:TEXT
									else
										cProtc := ""
									EndIF

									If Type( "oXmlRet:_RETEVENTOCTE:_INFEVENTO:_NSEQEVENTO:TEXT" ) <> "U"
										cSeqEve := oXmlRet:_RETEVENTOCTE:_INFEVENTO:_NSEQEVENTO:TEXT
									else
										cSeqEve := "01"
									EndIf

									If len(cSeqEve)<=len( (xZBE)->(FieldGet(FieldPos(xZBE_+"SEQEVE"))) )
										cSeqEve := StrZero( Val(cSeqEve), len( (xZBE)->(FieldGet(FieldPos(xZBE_+"SEQEVE"))) ), 0 )
									Endif

									dDhAut  := ctod( "" )

									If Type( "oXmlRet:_RETEVENTOCTE:_INFEVENTO:_DHREGEVENTO:TEXT" ) <> "U"
										cDthRet := oXmlRet:_RETEVENTOCTE:_INFEVENTO:_DHREGEVENTO:TEXT
										dDhAut  := StoD(substr(cDthRet,1,4)+Substr(cDthRet,6,2)+Substr(cDthRet,9,2))
									EndIf

									Reclock(xZBE,.T.)

									(xZBE)->(FieldPut(FieldPos(xZBE_+"CHAVE") , cChave     )) //cKey+cEvento+cSeqEve
									(xZBE)->(FieldPut(FieldPos(xZBE_+"FILIAL"), xFilial(xZBE)   ))
									(xZBE)->(FieldPut(FieldPos(xZBE_+"XML") , cXmlRet     )) //cKey+cEvento+cSeqEve
									(xZBE)->(FieldPut(FieldPos(xZBE_+"TPEVE") , "610110"   ))
									(xZBE)->(FieldPut(FieldPos(xZBE_+"DESC") , CDes   ))
									(xZBE)->(FieldPut(FieldPos(xZBE_+"SEQEVE"), cSeqEve   ))
									(xZBE)->(FieldPut(FieldPos(xZBE_+"DTHRGR"), cDTTime   ))
									(xZBE)->(FieldPut(FieldPos(xZBE_+"PROT"), ""  ))
									(xZBE)->(FieldPut(FieldPos(xZBE_+"STATUS"), "2" ))
									(xZBE)->(FieldPut(FieldPos(xZBE_+"DHAUT"), dDhAut ))
									(xZBE)->(FieldPut(FieldPos(xZBE_+"DTRECB"), ddatabase ))
									(xZBE)->(FieldPut(FieldPos(xZBE_+"EVENTO"), cXMotivo ))

									(xZBE)->(MsUnLock())

								//endif

							endif

						Endif 

						oRest := NIL								
						FreeObj(oRest)

					else

						SpedDesMnt(xZBZ)

					endif
					
				EndIf
				
			Endif 
			
		Else
		
			cMsgHelp := "Verificar o tamanho do campo Observacao. Deve ser  maior que 15 e menor que 255 posições." //"Verificar o tamanho do campo Observacao. Deve ser  maior que 15 e menor que 255 posições."
			Help( " ", 1, "A103OBSDES",,cMsgHelp,1,0)
			lRet := .F.
			
		EndIf	
			
	EndIf
	
EndIf 

Return()


Static Function IDENVDES()

Local cXml		:= ""
Local cURL		:= PadR(GetNewPar("XM_URL",""),250)
Local cIdEnt	:= ""
Local cRet		:= ""
Local lUsaColab	:= .F.
Local oWs
Local aEvt      := {}
Local cSeqEve   := "01"


If Empty(cURL)
	cURL  := PadR(GetNewPar("MV_SPEDURL","http://"),250)
EndIf

cXml :='<envEvento>'
cXml +=	'<eventos>'
cXml +=		'<detEvento>'
cXml +=			'<tpEvento>610110</tpEvento>'
cXml +=			'<chNFe>' + AllTrim((xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE")))) + '</chNFe>'
cXml +=			'<indDesacordoOper>1</indDesacordoOper>'
cXml +=			'<xObs>' + AllTrim((xZBZ)->(FieldGet(FieldPos(xZBZ_+"OBSDES")))) + '</xObs>
cXml +=		'</detEvento>'
cXml +=	'</eventos>'
cXml +='</envEvento>'
	
If CTIsReady(,,,lUsaColab)

	// Obtem o codigo da entidade
	cIdEnt := u_GetIdEnt()	
	
	oWs:= WsNFeSBra():New()
	oWs:cUserToken	:= "TOTVS" 
	oWs:cID_ENT		:= cIdEnt
	oWs:cXML_LOTE	:= cXml
	oWS:_URL		:= AllTrim(cURL) + "/NFeSBRA.apw"
	
	If oWs:RemessaEvento()	
	
		aRetorno := { oWS:oWsRemessaEventoResult:cString }
		//aRetorno := { { AllTrim((xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE")))), "610110" } }
		//aRetorno := {{"",""}}
		
		If !Empty(aRetorno[1][1])
		
			cRet := aRetorno[1][1]  //"35180800650831000290570030003965481013788991"  
			
		EndIf
		DbSelectArea( xZBE )
		aEvt    := {}     //ZBEMANO
        cSeqEve := "01"   //ZBEMANO
		if len(cSeqEve)<=len( (xZBE)->(FieldGet(FieldPos(xZBE_+"SEQEVE"))) )
			cSeqEve := StrZero( Val(cSeqEve), len( (xZBE)->(FieldGet(FieldPos(xZBE_+"SEQEVE"))) ), 0 )
		endif
		aEvt := {}
		aadd( aEvt, {xZBE_+"DHAUT" 	, dDataBase         } )
		aadd( aEvt, {xZBE_+"DTRECB"	, dDataBase         } )
		aadd( aEvt, {xZBE_+"PROT"  	, ""      } )
		aadd( aEvt, {xZBE_+"XML"   	, cXml              } )
		aadd( aEvt, {xZBE_+"DESC"  	, "Desacordo do CTe"} )
		aadd( aEvt, {xZBE_+"EVENTO"	, AllTrim((xZBZ)->(FieldGet(FieldPos(xZBZ_+"OBSDES")))) } )
		aadd( aEvt, {xZBE_+"STATUS"	, "2"  } )
		cGrv    := U_HF2GrvEv( AllTrim((xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE")))), "610110", cSeqEve, aEvt, .T. )
		DbSelectArea( xZBZ )
		
	EndIf
	
EndIf

Return cRet


////////////////////////////////////////////////////////////
//                                                        //
//                  Monitoramento                         //
//                                                        //
////////////////////////////////////////////////////////////

/*/{Protheus.doc} SpedDesMnt
Função que monitora os eventos do Evento de Desacordo

@author Felipe Barbieri
@since 23.03.2017
@version 1.00

@param	Null

/*/
//-----------------------------------------------------------------------
Static Function SpedDesMnt(cAliasDes)

Local cIdEnt	:= ""
Local aListBox	:= {}
Local cIdEvento	:= '610110'
Local cEstDoc	:= ""
Local lUsaColab	:= .F.
Local dEmissao	:= CtoD("//")
Local cDoc		:= ""
Local cSerie	:= ""
Local cURL		:= PadR(GetNewPar("XM_URL",""),250)
Local oWS
Local oDlg
Local oListBox
Local oBtn1
Local oBtn2
Local oBtn3
Local oBtn4

Default cAliasDes := ""

If Empty(cURL)
	cURL  := PadR(GetNewPar("MV_SPEDURL","http://"),250)
EndIf

If Empty(cAliasDes)

	cAliasDes := "ZBZ"

Endif

cEstDoc	 := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"IDDES"))) //ZBZ->ZBZ_IDDES
dEmissao := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"DTNFE"))) //ZBZ->ZBZ_DTNFE
cDoc	 := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA"))) //ZBZ->ZBZ_NOTA
cSerie	 := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE"))) //ZBZ->ZBZ_SERIE

lUsaColab := UsaColaboracao("2")

DEFINE FONT oBold BOLD

	aListBox := SpedWsDes(cAliasDes)

	If !Empty(aListBox)

			DEFINE MSDIALOG oDlg TITLE "Monitor - Evento Desacordo" From 10,10 TO 450,1012 OF oMainWnd PIXEL

			@015,010 SAY	"Numero"		PIXEL OF oDlg FONT oBold	//Numero
			@015,036 SAY	cDoc			PIXEL OF oDlg
			@015,074 SAY	"Série"			PIXEL OF oDlg FONT oBold	//Série
			@015,093 SAY	cSerie			PIXEL OF oDlg

			@030,010 LISTBOX oListBox FIELDS HEADER "Protocolo","ID Evento","Ambiente","Status do Evento","Retorno da Transmissao","Retorno Processamento do Evento" SIZE 480,150 PIXEL OF oDlg	//"Protocolo ID Evento Ambiente Status do Evento Retorno da Transmissao Retorno Processamento do Evento"

			oListBox:SetArray(aListBox)
			oListBox:bLine:={||	{	aListBox[oListBox:nAt][01],;
									aListBox[oListBox:nAt][02],;
									aListBox[oListBox:nAt][03],;
									aListBox[oListBox:nAt][04],;
									aListBox[oListBox:nAt][05],;
									aListBox[oListBox:nAt][06]}}

			@ 200,400 BUTTON oBtn1 PROMPT "Refresh"	ACTION (aListBox := SpedWsDes(cAliasDes),oListBox:nAt := 1,IIF(Empty(aListBox),oDlg:End(),oListBox:Refresh())) OF oDlg PIXEL SIZE 035,011 //"Refresh"
			@ 200,455 BUTTON oBtn2 PROMPT "OK"	ACTION (SpedHlpDes(cAliasDes), oDlg:End()) OF oDlg PIXEL SIZE 035,011 //"OK"

			ACTIVATE MSDIALOG oDLg CENTERED
			
		EndIf
		
Return


//-----------------------------------------------------------------------
/*/{Protheus.doc} SpedWsDes
Função que monitora os eventos do Evento de Desacordo

@author Felipe Barbieri
@since 23.03.2017
@version 1.00

@param	Null

/*/
//-----------------------------------------------------------------------
Static Function SpedWsDes(cAliasDes)

Local cIdEnt	:= ""
Local aListBox	:= {}
Local cIdEvento	:= '610110'
Local cEstDoc	:= ""
Local lUsaColab	:= .F.
Local dEmissao	:= CtoD("//")
Local cURL		:= PadR(GetNewPar("XM_URL",""),250)
Local oWS
Local oListBox
Local lOk 		:= .F.
Local aStatus	:= {{1,"1-Evento recebido"},;
					{2,"2-Evento assinado"},;
					{3,"3-Evento com falha no schema XML"},;
					{4,"4-Evento transmitido"},;
					{5,"5-Evento com problemas"},;
					{6,"6-Evento vinculado"	} }
Local nStatPos	:= 0
Local cStatus	:= ""
Local cStatRetEven	:= ""
Local cStatRet		:= ""
Local cStatRetEnv	:= ""
Local cProtocolo    := ""
Local cChvCte		:= ""
Local oOk			:= LoadBitMap(GetResources(), "ENABLE")
Local oNo			:= LoadBitMap(GetResources(), "DISABLE")
Local aEvt    := {}
Local cGrv    := ""
Local cSeqEve := ""

cEstDoc	 := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"IDDES")))
dEmissao := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"DTNFE"))) //ZBZ->ZBZ_DTNFE
cChvCte	 := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))) //ZBZ->ZBZ_CHAVE

lUsaColab := UsaColaboracao("2")

If Empty(cURL)
	cURL  := PadR(GetNewPar("MV_SPEDURL","http://"),250)
EndIf

DEFINE FONT oBold BOLD

// Verifica se a entidade foi configurada
If CTIsReady(,,,lUsaColab)

	cIdEnt := u_GetIdEnt()	
	
	If !Empty(cIdEnt)

		// Executa o metodo NfeRetornaEvento()
		oWS:= WSNFeSBRA():New()
		oWS:cUSERTOKEN	:= "TOTVS"
		oWS:cID_ENT		:= cIdEnt
		oWS:_URL		:= AllTrim(cURL)+"/NFeSBRA.apw"
		oWS:cEVENTO		:= "610110"
		oWS:cCHVINICIAL	:= alltrim(cChvCte)
		oWS:cCHVFINAL	:= alltrim(cChvCte)
		
		lOk := oWS:NFEMONITORLOTEEVENTO()

		If lOk
		
			// Tratamento do retorno do evento
			If ValType(oWS:oWsNfemonitorLoteEventoResult:OWSNfeMonitorEvento) <> "U" .And. ValType(oWS:oWsNfeRetornaEventoResult:oWsNfeRetornaEvento) <> "U"

				if Len( oWS:oWsNfemonitorLoteEventoResult:OWSNfeMonitorEvento ) == 0
				
					Conout( "Array: oWS:oWsNfemonitorLoteEventoResult:OWSNfeMonitorEvento está vazio - SPEDWSDES" )
				
					Return( aListBox )
				
				endif
				
				if Empty( oWS:oWsNfemonitorLoteEventoResult:OWSNfeMonitorEvento )
				
					Conout( "Array: oWS:oWsNfemonitorLoteEventoResult:OWSNfeMonitorEvento está vazio - SPEDWSDES" )
				
					Return( aListBox )
				
				endif

				oDados := oWS:oWsNfemonitorLoteEventoResult:OWSNfeMonitorEvento[1]

				If ( nStatPos := aScan(aStatus,{ |x| x[1] == oDados:nStatus}) ) > 0
					cStatus := aStatus[nStatPos][2]
				Endif
				
				cIDEvenRet	:= oDados:cId_Evento
				nLote 		:= oDados:nLote
				cAmbiente	:= Alltrim(Str(oDados:nAmbiente))		//1-Producao ### 2-Homologacao

				If oDados:nStatus > 2

					// Retorno da transmissao
					cStatRetEnv := cValToChar(oDados:nCSTATENV) + " - " + Alltrim(oDados:cCMOTENV)

					// Retorno do processamento do evento
					If oDados:nCStatEven > 0
					
						cStatRetEven := cValToChar(oDados:nCStatEven)+" - "+Alltrim(oDados:cCMotEven)

						// Evento registrado e vinculado a NF-e
						If oDados:nCStatEven == 135
						
							cProtocolo := StrZero(oDados:nProtocolo,15)
							
							If cEstDoc <> '6'
							
								If RecLock(xZBZ,.F.)
								
									(xZBZ)->(FieldPut(FieldPos(xZBZ_+"IDDES")    , AllTrim(Str(oDados:nStatus)) )) //ZBZ->ZBZ_IDDES  := AllTrim(Str(oDados:nStatus))

									If AllTrim(Str(oDados:nStatus)) == "6"
										(xZBZ)->(FieldPut(FieldPos(xZBZ_+"STMNCT")    , "E" )) //ZBZ->ZBZ_STMNCT := "E" // Evento desacordo vinculado
										(xZBZ)->(FieldPut(FieldPos(xZBZ_+"MANIF")     , "5" )) //Manifestação de CTe, Só pra PÁ.
									Elseif AllTrim(Str(oDados:nStatus)) == "5" .Or. AllTrim(Str(oDados:nStatus)) == "3"
										(xZBZ)->(FieldPut(FieldPos(xZBZ_+"STMNCT")    , "F" )) //ZBZ->ZBZ_STMNCT := "F" // Evento desacordo rejeição
									Endif

									(xZBZ)->(MsUnLock())
									If AllTrim(Str(oDados:nStatus)) == "6"
										DbSelectArea( xZBE )
										aEvt    := {}     //ZBEMANO
								        cSeqEve := "01"   //ZBEMANO
										if len(cSeqEve)<=len( (xZBE)->(FieldGet(FieldPos(xZBE_+"SEQEVE"))) )
											cSeqEve := StrZero( Val(cSeqEve), len( (xZBE)->(FieldGet(FieldPos(xZBE_+"SEQEVE"))) ), 0 )
										endif
										aEvt := {}
										aadd( aEvt, {xZBE_+"DHAUT" 	, dDataBase       } )
										aadd( aEvt, {xZBE_+"PROT"  	, cProtocolo      } )
										aadd( aEvt, {xZBE_+"STATUS"	, "1"  } )
										cGrv    := U_HF2GrvEv( AllTrim((xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE")))), "610110", cSeqEve, aEvt, .T. )
										DbSelectArea( xZBZ )
									Endif
								Endif
																	
							EndIf
							
						ElseIf oDados:nCStatEven >= 201 //Rejeição
						
							If cEstDoc <> '6'
															
								If RecLock(xZBZ,.F.)
								
									(xZBZ)->(FieldPut(FieldPos(xZBZ_+"IDDES")    , AllTrim(Str(oDados:nStatus)) )) //ZBZ->ZBZ_IDDES  := AllTrim(Str(oDados:nStatus))

									If AllTrim(Str(oDados:nStatus)) == "6"
										(xZBZ)->(FieldPut(FieldPos(xZBZ_+"STMNCT")    , "E" )) //  //ZBZ->ZBZ_STMNCT := "E" // Evento desacordo vinculado
										(xZBZ)->(FieldPut(FieldPos(xZBZ_+"MANIF")     , "5" )) //Manifestação de CTe, Só pra PÁ.
									Elseif AllTrim(Str(oDados:nStatus)) == "5" .Or. AllTrim(Str(oDados:nStatus)) == "3"
										(xZBZ)->(FieldPut(FieldPos(xZBZ_+"STMNCT")    , "F" )) //  //ZBZ->ZBZ_STMNCT := "F" // Evento desacordo rejeição
									Endif

									(xZBZ)->(MsUnLock())
									If AllTrim(Str(oDados:nStatus)) == "6"
										DbSelectArea( xZBE )
										aEvt    := {}     //ZBEMANO
								        cSeqEve := "01"   //ZBEMANO
										if len(cSeqEve)<=len( (xZBE)->(FieldGet(FieldPos(xZBE_+"SEQEVE"))) )
											cSeqEve := StrZero( Val(cSeqEve), len( (xZBE)->(FieldGet(FieldPos(xZBE_+"SEQEVE"))) ), 0 )
										endif
										aEvt := {}
										aadd( aEvt, {xZBE_+"DHAUT" 	, dDataBase       } )
										aadd( aEvt, {xZBE_+"STATUS"	, "1"  } )
										cGrv    := U_HF2GrvEv( AllTrim((xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE")))), "610110", cSeqEve, aEvt, .T. )
										DbSelectArea( xZBZ )
									Endif
									
								Endif																	
								
							EndIf
							
						Endif
						
					Endif

				Else
					cXmlRet := ""
				Endif

				cAmbiente := IIf(cAmbiente == "1","1-Produção","2-Homologação")

				If Empty(cStatRetEven)
					cStatRet := cStatRetEnv
				Else
					cStatRet := cStatRetEven
				Endif

				AADD( aListBox, {	IIf(Empty(cProtocolo),oNo,oOk),;
								cProtocolo,;
								cIDEvenRet,;
								cAmbiente,;		//[04] 1-Producao ### 2-Homologacao
								cStatus,;		//[05] Status do evento
								cStatRet})		//[06] Status retorno da transmissao
			EndIf
			
		EndIf
		
	EndIf
	
Else
	Aviso("SPED","Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!",{"Serviço"},3)	//"Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
EndIf

Return aListBox


/*/{Protheus.doc} SpedHlpDes
Informativo para o usuario excluir CTE após evento
de desacordo for vinculado.

@author Rodrigo M Pontes
@since 23.03.2017
@version 1.00

@param	Null
/*/

Static Function SpedHlpDes(cAliasDes)

If cAliasDes == xZBZ
	Help(,,'EVDESACORDO',,"É recomendavel que exclua o CTE após a confirmação do evento. O CTE continuara com todas seus lançamentos ativos até que seja excluido.", 1, 0) //"É recomendavel que exclua o CTE após a confirmação do evento. O CTE continuara com todas seus lançamentos ativos até que seja excluido."
Endif

Return .T.
