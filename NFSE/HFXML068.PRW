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
//#INCLUDE "HTTPCLASS.CH"
#INCLUDE "FWMVCDEF.CH"

//Static lInitSped := .F.
//Static lUnix  := IsSrvUnix()
//Static cBarra := Iif(lUnix,"/","\")

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณ HFXML068 ณ Autor ณ Heverton Marcondes    ณ Data ณ24/08/2018ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Download dos XML NFSE 						              ณฑฑ
ฑฑณA rotina varre a ZBM para gerar consulta na ZBN, essas consultas sใo   ณฑฑ
ฑฑณmonitoradas e quando estiver ok, grava na ZBZ			              ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
//--------------------------------------------------------------------------//
//FR - 24/11/2020 - Solicitado por Rafael - corrigir reclock na tabela ZBN
//--------------------------------------------------------------------------//
//FR - 27/11/2020 - Solicitado por Rafael - incluir rotina para gravar ZBT
//                  (Item da ZBZ) 
//--------------------------------------------------------------------------//

User Function HFXML068(lAuto,lEnd,oProcess,cLogProc,nCount)

    Local oRest 	:= Nil 
    Local oObjJson  := Nil
	Local cBody		:= ""
	Local cData		:= ""
	Local cLink		:= ""
	Local dData30	:= dDataBase-31
	Local cData30	:= ""
	Local dData		:= dDataBase-1
	Local cAliasSA2 := GetNextAlias()
	Local cAliasZBN := GetNextAlias()
	Local cQuery   	:= " "
	Local cStatus	:= " "
	//Local nQuant	:= 0
	Local dDataIni	:= dDataBase
	Local cDataIni	:= ""
	Local nN		:= 0
	Local nV		:= 0
	Local aVezes1	:= {"13"}
	Local aVezes2	:= {"10","13"}
	Local aVezes3	:= {"10","13","16"}
	Local aVezes4	:= {"09","12","15","18"}
	Local cDataVez  := GetNewPar("XM_DATAVEZ")
	
	Private aVezes		:= {}
	Private cVezDia 	:= GetNewPar("XM_VEZDIA" ,"0")
	Private aUF     	:= {}
	Private cUf 		:= ""
	Private nUf			:= ""	
	Private xZBZ  		:= GetNewPar("XM_TABXML" ,"ZBZ")
	Private xZBM  		:= GetNewPar("XM_TABMUN" ,"ZBM")
	Private xZBN  		:= GetNewPar("XM_TABMUN2" ,"ZBN")
	Private xZBZ_ 		:= iif(Substr(xZBZ,1,1)=="S", Substr(xZBZ,2,2), Substr(xZBZ,1,3)) + "_"
	Private xZBM_ 		:= iif(Substr(xZBM,1,1)=="S", Substr(xZBM,2,2), Substr(xZBM,1,3)) + "_"
	Private xZBN_ 		:= iif(Substr(xZBN,1,1)=="S", Substr(xZBN,2,2), Substr(xZBN,1,3)) + "_"
    Private cUrl 		:= "api.nfse.tecnospeed.com.br" 
	Private cProtocol1	:= "https://"
	Private cProtocol2	:= "http://"
	Private cCnpj		:= ""
	Private cInscr		:= ""
	Private cReq		:= ""
    Private aHeader 	:= {} 

	Do Case 
		Case cVezDia == "0"
			aVezes := {}
		Case cVezDia == "1"
			aVezes := aClone(aVezes1)		
		Case cVezDia == "2"
			aVezes := aClone(aVezes2)		
		Case cVezDia == "3"
			aVezes := aClone(aVezes3)		
		Case cVezDia == "4"
			aVezes := aClone(aVezes4)			
		OtherWise
			aVezes := {}		
	EndCase		 
	If !lAuto .Or. oProcess<>Nil      

		oProcess:IncRegua1("Consultando municํpios...")
		oProcess:IncRegua2("Aguarde...")      

	EndIf

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

	lProcessa := .T.

	If lProcessa

		//Verifica dados no SIGAMAT, inscri็ใo municipal nใo obrigat๓ria, monitorar pq jah deu problema passando inscri็ใo HMS
		cCnpj 	:= Alltrim(FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , { "M0_CGC" } )[1][2])
		cInscr	:= Alltrim(FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , { "M0_INSCM" } )[1][2])
		//cInscr	:= ""

		Aadd(aHeader, "Content-Type: application/json")                      
		Aadd(aHeader, "token_sh: 8362a6f9f284692afa0d191b34a0cbdd")                      
		Aadd(aHeader, "cpfCnpjSoftwareHouse: 07084316000158")                      
		Aadd(aHeader, "cpfCnpjTomador: "+cCnpj)   
		Aadd(aHeader, "Connection: keep-alive")   

		//Pega a data limite inicial
		cData30 := substr(dtos(dData30),1,4)+"-"
		cData30 += substr(dtos(dData30),5,2)+"-"
		cData30 += substr(dtos(dData30),7,2)

		//Pega a data limite final
		cData := substr(dtos(dData),1,4)+"-"
		cData += substr(dtos(dData),5,2)+"-"
		cData += substr(dtos(dData),7,2)

		dbSelectArea(xZBM)
		(xZBM)->(dbSetOrder(1))
		(xZBM)->(dbGoTop())

		While !(xZBM)->(EOF())
			If (xZBM)->(FieldGet(FieldPos(xZBM_+"FILIAL"))) == xFilial(xZBM) .And. dData > (xZBM)->(FieldGet(FieldPos(xZBM_+"DATA"))) .AND. (xZBM)->(FieldGet(FieldPos(xZBM_+"ATIVO"))) == "1" .AND. (lAuto .Or. (xZBM)->(FieldGet(FieldPos(xZBM_+"JOB"))) <> "1") 
				//Faz as buscas e grava na ZBN

				//Se a data for vazia, o limite ้ 30 dias atras, do contrario pega a ultima vez q rodou
				If Empty((xZBM)->(FieldGet(FieldPos(xZBM_+"DATA"))))

					cDataIni := cData30

				Else

					dDataIni := (xZBM)->(FieldGet(FieldPos(xZBM_+"DATA"))) + 1

					//Verifica se a data ini ้ inferior a 30 dias e ajusta.
					if dDataini < dData30

						dDataini := dData30

					endif

					cDataIni := substr(dtos(dDataIni),1,4)+"-"
					cDataIni += substr(dtos(dDataIni),5,2)+"-"
					cDataIni += substr(dtos(dDataIni),7,2)
										
				EndIf	

				cLogProc += "Municํpio "+ alltrim((xZBM)->(FieldGet(FieldPos(xZBM_+"MUNIC")))) + " consultando de " + cDataIni + " ate " + cData + chr(13)+chr(10)							

				If (xZBM)->(FieldGet(FieldPos(xZBM_+"PREST"))) == "1" //Se necessita de prestador, varre a SA2 para fazer uma consulta pra cada CNPJ prestador

					nUf	:= aScan(aUF,{|x| x[2] == substr((xZBM)->(FieldGet(FieldPos(xZBM_+"COD"))),1,2)})
					cUf := aUF[nUf][1]

					cQuery := ""
					cQuery += " Select A2_COD, A2_LOJA, A2_CGC, A2_INSCRM FROM "+RetSqlName("SA2")+" "
					cQuery += " Where A2_FILIAL = '"+xFilial( "SA2" )+"' "
					cQuery += " And A2_EST = '"+cUf+"' "
					cQuery += " And A2_COD_MUN = '"+substr((xZBM)->(FieldGet(FieldPos(xZBM_+"COD"))),3,5)+"' "
					cQuery += " And A2_XHFPRES <> '2' "
					cQuery += " And D_E_L_E_T_ = ' ' "

					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSA2)

					DbSelectArea( cAliasSA2 )
					(cAliasSA2)->( dbGoTop() )
					
					If (cAliasSA2)->( Eof() )

						RecLock(xZBN,.T.)
							(xZBN)->(FieldPut(FieldPos(xZBN_+"FILIAL"), xFilial(xZBN) ))
							(xZBN)->(FieldPut(FieldPos(xZBN_+"COD"), (xZBM)->(FieldGet(FieldPos(xZBM_+"COD"))) ))
							//(xZBM)->(FieldPut(FieldPos(xZBM_+"DATA"), dData ))
							(xZBN)->(FieldPut(FieldPos(xZBN_+"DATA"), dData ))		//FR - 24/11/2020
							(xZBN)->(FieldPut(FieldPos(xZBN_+"STATUS"), "ERRO" ))
							(xZBN)->(FieldPut(FieldPos(xZBN_+"MSG"), "Nใo existe nenhum fornecedor cadastrado para esse municํpio " + Time() ))
						(xZBN)->(MsUnlock())
					
					EndIf

					Do While .NOT. (cAliasSA2)->( Eof() )

						If !lAuto .Or. oProcess<>Nil      
							oProcess:IncRegua2(alltrim((xZBM)->(FieldGet(FieldPos(xZBM_+"MUNIC"))))+ " Fornecedor " + (cAliasSA2)->A2_CGC)      
						EndIf

						oRest 	:= FWRest():New(cProtocol1+cUrl) //Tenta HTTP

						oRest:SetPath("/v1/tomadas")  
						
						cBody := 	'{' + CRLF
						cBody += 		'"codigoCidade": "'+ alltrim((xZBM)->(FieldGet(FieldPos(xZBM_+"COD")))) + '", ' + CRLF
						cBody +=		'"prestador": {' + CRLF
						cBody +=   			'"cpfCnpj": "'+alltrim((cAliasSA2)->A2_CGC)+'",' + CRLF
						cBody +=    		'"inscricaoMunicipal": "'+alltrim((cAliasSA2)->A2_INSCRM)+'"' + CRLF
						cBody +=  		'},' + CRLF						
						cBody += 		'"destinatario": {' + CRLF
						cBody += 			'"cpfCnpj": "'+ alltrim(cCNPJ) + '",' + CRLF
						cBody += 			'"inscricaoMunicipal": "'+ alltrim(cInscr) + '",' + CRLF
						cBody +=   			'"autenticacao":{' + CRLF
						cBody +=				'"login":"'+alltrim((xZBM)->(FieldGet(FieldPos(xZBM_+"USER"))))+'",' + CRLF
						cBody +=				'"senha":"'+alltrim((xZBM)->(FieldGet(FieldPos(xZBM_+"PSW"))))+'"' + CRLF
						cBody +=			'}' + CRLF
						cBody +=		'},' + CRLF
						cBody += 		'"periodo": {' + CRLF		
						
						cBody += 			'"inicial": "'+ cDataIni + '", ' + CRLF

						cBody += 			'"final": "'+ cData + '" ' + CRLF
						cBody +=		'}' + CRLF	
						cBody +=	'}' + CRLF

						oRest:SetPostParams(cBody)

						If oRest:Post(aHeader) 
							If !FWJsonDeserialize(oRest:GetResult(), @oObjJson)
								MsgStop("Ocorreu erro no processamento do Json")
								Return Nil
							EndIf			 

							cLink := "/v1/tomadas/"+ oObjJson:RESPOSTA:PROTOCOLO 

							RecLock(xZBM,.F.)
								(xZBM)->(FieldPut(FieldPos(xZBM_+"STATUS"), "PROCESSANDO" ))
								(xZBM)->(FieldPut(FieldPos(xZBM_+"DATA"), dData ))
							(xZBM)->(MsUnlock())

							RecLock(xZBN,.T.)
								(xZBN)->(FieldPut(FieldPos(xZBN_+"FILIAL"), xFilial(xZBN) ))
								(xZBN)->(FieldPut(FieldPos(xZBN_+"COD"), (xZBM)->(FieldGet(FieldPos(xZBM_+"COD"))) ))
								(xZBN)->(FieldPut(FieldPos(xZBN_+"DATA"), dData ))
								(xZBN)->(FieldPut(FieldPos(xZBN_+"FORNEC"), (cAliasSA2)->A2_COD ))
								(xZBN)->(FieldPut(FieldPos(xZBN_+"LOJFOR"), (cAliasSA2)->A2_LOJA ))
								(xZBN)->(FieldPut(FieldPos(xZBN_+"STATUS"), "PROCESSANDO" ))
								(xZBN)->(FieldPut(FieldPos(xZBN_+"LINK"), cLink ))
								cReq := cProtocol1+cUrl+CRLF
								cReq += CRLF

								cReq += "HEADER" + CRLF
								cReq += CRLF

								For nN := 1 to Len(aHeader)
									cReq += aHeader[nN] + CRLF
								Next nN

								cReq += CRLF + CRLF
								cReq += "BODY" + CRLF
								cReq += CRLF
								cReq += cBody
								
								(xZBN)->(FieldPut(FieldPos(xZBN_+"REQ"), cReq ))
							(xZBN)->(MsUnlock())

						Else

							oRest := NIL								
							FreeObj(oRest)

							oRest 	:= FWRest():New(cProtocol2+cUrl) //Tenta HTTPS

							oRest:SetPath("/v1/tomadas")  
							
							cBody := 	'{' + CRLF
							cBody += 		'"codigoCidade": "'+ alltrim((xZBM)->(FieldGet(FieldPos(xZBM_+"COD")))) + '", ' + CRLF
							cBody +=		'"prestador": {' + CRLF
							cBody +=   			'"cpfCnpj": "'+alltrim((cAliasSA2)->A2_CGC)+'",' + CRLF
							cBody +=    		'"inscricaoMunicipal": "'+alltrim((cAliasSA2)->A2_INSCRM)+'"'	 + CRLF
							cBody +=  		'},'						 + CRLF
							cBody += 		'"destinatario": {' + CRLF
							cBody += 			'"cpfCnpj": "'+ alltrim(cCNPJ) + '",' + CRLF
							cBody += 			'"inscricaoMunicipal": "'+ alltrim(cInscr) + '",' + CRLF
							cBody +=   			'"autenticacao":{' + CRLF
							cBody +=				'"login":"'+alltrim((xZBM)->(FieldGet(FieldPos(xZBM_+"USER"))))+'",' + CRLF
							cBody +=				'"senha":"'+alltrim((xZBM)->(FieldGet(FieldPos(xZBM_+"PSW"))))+'"' + CRLF
							cBody +=			'}' + CRLF
							cBody +=		'},' + CRLF
							cBody += 		'"periodo": {'		 + CRLF
							cBody += 			'"inicial": "'+ cDataIni + '", ' + CRLF
							cBody += 			'"final": "'+ cData + '" ' + CRLF
							cBody +=		'}'	 + CRLF
							cBody +=	'}' + CRLF

							oRest:SetPostParams(cBody)

							If oRest:Post(aHeader) 
								If !FWJsonDeserialize(oRest:GetResult(), @oObjJson)
									MsgStop("Ocorreu erro no processamento do Json")
									Return Nil
								EndIf			 

								cLink := "/v1/tomadas/"+ oObjJson:RESPOSTA:PROTOCOLO 

								RecLock(xZBM,.F.)
									(xZBM)->(FieldPut(FieldPos(xZBM_+"STATUS"), "PROCESSANDO" ))
									(xZBM)->(FieldPut(FieldPos(xZBM_+"DATA"), dData ))
								(xZBM)->(MsUnlock())

								RecLock(xZBN,.T.)
									(xZBN)->(FieldPut(FieldPos(xZBN_+"FILIAL"), xFilial(xZBN) ))
									(xZBN)->(FieldPut(FieldPos(xZBN_+"COD"), (xZBM)->(FieldGet(FieldPos(xZBM_+"COD"))) ))
									(xZBN)->(FieldPut(FieldPos(xZBN_+"FORNEC"), (cAliasSA2)->A2_COD ))
									(xZBN)->(FieldPut(FieldPos(xZBN_+"LOJFOR"), (cAliasSA2)->A2_LOJA ))
									(xZBN)->(FieldPut(FieldPos(xZBN_+"STATUS"), "PROCESSANDO" ))
									(xZBN)->(FieldPut(FieldPos(xZBN_+"LINK"), cLink ))
									cReq := cProtocol2+cUrl+CRLF
									cReq += CRLF

									cReq += "HEADER" + CRLF
									cReq += CRLF

									For nN := 1 to Len(aHeader)
										cReq += aHeader[nN] + CRLF
									Next nN

									cReq += CRLF + CRLF
									cReq += "BODY" + CRLF
									cReq += CRLF
									cReq += cBody
									
									(xZBN)->(FieldPut(FieldPos(xZBN_+"REQ"), cReq ))
								(xZBN)->(MsUnlock())

							Else

								RecLock(xZBM,.F.)
									(xZBM)->(FieldPut(FieldPos(xZBM_+"STATUS"), "ERRO" ))
									(xZBM)->(FieldPut(FieldPos(xZBM_+"DATA"), dData ))
								(xZBM)->(MsUnlock())

								RecLock(xZBN,.T.)
									(xZBN)->(FieldPut(FieldPos(xZBN_+"FILIAL"), xFilial(xZBN) ))
									(xZBN)->(FieldPut(FieldPos(xZBN_+"COD"), (xZBM)->(FieldGet(FieldPos(xZBM_+"COD"))) ))
									(xZBN)->(FieldPut(FieldPos(xZBN_+"DATA"), dData ))
									(xZBN)->(FieldPut(FieldPos(xZBN_+"STATUS"), "ERRO" ))
									If ( ValType( "oRest:CRESULT" ) <> 'U' )
										(xZBN)->(FieldPut(FieldPos(xZBN_+"MSG"), DecodeUtf8(oRest:CRESULT) + Time() ))
									Else 
										(xZBN)->(FieldPut(FieldPos(xZBN_+"MSG"), DecodeUtf8(oRest:CINTERNALERROR) + Time() ))
									EndIF
									cReq := cProtocol2+cUrl+CRLF
									cReq += CRLF

									cReq += "HEADER" + CRLF
									cReq += CRLF

									For nN := 1 to Len(aHeader)
										cReq += aHeader[nN] + CRLF
									Next nN

									cReq += CRLF + CRLF
									cReq += "BODY" + CRLF
									cReq += CRLF
									cReq += cBody
									
									(xZBN)->(FieldPut(FieldPos(xZBN_+"REQ"), cReq ))
								(xZBN)->(MsUnlock())
								cLogProc += "Municํpio "+ alltrim((xZBM)->(FieldGet(FieldPos(xZBM_+"MUNIC")))) + " com ERRO verifique monitor" + chr(13)+chr(10)						

							EndIf
						EndIf  

						(cAliasSA2)->( dbSkip() )

					EndDo

					(cAliasSA2)->(dbCloseArea())

				Else //Se nใo necessita prestador, faz uma consulta s๓
					
					If !lAuto .Or. oProcess<>Nil      
						oProcess:IncRegua2(alltrim((xZBM)->(FieldGet(FieldPos(xZBM_+"MUNIC")))))      
					EndIf

					oRest 	:= FWRest():New(cProtocol1+cUrl) //Tenta HTTP
					oRest:SetPath("/v1/tomadas")        
					
					cBody := 	'{' + CRLF
					cBody += 		'"codigoCidade": "'+ alltrim((xZBM)->(FieldGet(FieldPos(xZBM_+"COD")))) + '", ' + CRLF
					cBody += 		'"destinatario": {' + CRLF
					cBody += 			'"cpfCnpj": "'+ alltrim(cCNPJ) + '",' + CRLF
					cBody += 			'"inscricaoMunicipal": "'+ IIF((xZBM)->(FieldGet(FieldPos(xZBM_+"COD"))) <> "3550308",alltrim(cInscr),"") + '",' + CRLF //Erro tecnospeed - tratado no c๓digo por enquanto
					cBody +=   			'"autenticacao":{' + CRLF
					cBody +=				'"login":"'+alltrim( (xZBM)->(FieldGet(FieldPos(xZBM_+"USER"))) )+'",' + CRLF
					cBody +=				'"senha":"'+alltrim( (xZBM)->(FieldGet(FieldPos(xZBM_+"PSW"))) )+'"' + CRLF
					cBody +=			'}' + CRLF
					cBody +=		'},' + CRLF
					cBody += 		'"periodo": {'		 + CRLF
					cBody += 			'"inicial": "'+ cDataIni + '", ' + CRLF
					cBody += 			'"final": "'+ cData + '" ' + CRLF
					cBody +=		'}'	 + CRLF
					cBody +=	'}' + CRLF

					oRest:SetPostParams(cBody)

					If oRest:Post(aHeader) 
						If !FWJsonDeserialize(oRest:GetResult(), @oObjJson)
							MsgStop("Ocorreu erro no processamento do Json")
							Return Nil
						EndIf			 

						cLink := "/v1/tomadas/"+ oObjJson:RESPOSTA:PROTOCOLO 

						RecLock(xZBM,.F.)
							(xZBM)->(FieldPut(FieldPos(xZBM_+"STATUS"), "PROCESSANDO" ))
							(xZBM)->(FieldPut(FieldPos(xZBM_+"DATA"), dData ))
						(xZBM)->(MsUnlock())

						RecLock(xZBN,.T.)
							(xZBN)->(FieldPut(FieldPos(xZBN_+"FILIAL"), xFilial(xZBN) ))
							(xZBN)->(FieldPut(FieldPos(xZBN_+"COD"), (xZBM)->(FieldGet(FieldPos(xZBM_+"COD"))) ))
							(xZBN)->(FieldPut(FieldPos(xZBN_+"DATA"), dData ))
							(xZBN)->(FieldPut(FieldPos(xZBN_+"STATUS"), "PROCESSANDO" ))
							(xZBN)->(FieldPut(FieldPos(xZBN_+"LINK"), cLink ))
							cReq := cProtocol1+cUrl+CRLF
							cReq += CRLF

							cReq += "HEADER" + CRLF
							cReq += CRLF

							For nN := 1 to Len(aHeader)
								cReq += aHeader[nN] + CRLF
							Next nN

							cReq += CRLF + CRLF
							cReq += "BODY" + CRLF
							cReq += CRLF
							cReq += cBody
							
							(xZBN)->(FieldPut(FieldPos(xZBN_+"REQ"), cReq ))
						(xZBN)->(MsUnlock())


					Else
						oRest := NIL								
						FreeObj(oRest)

						oRest 	:= FWRest():New(cProtocol2+cUrl) //Tenta HTTPS

						oRest:SetPath("/v1/tomadas")        
						
						cBody := 	'{'  + CRLF
						cBody += 		'"codigoCidade": "'+ alltrim((xZBM)->(FieldGet(FieldPos(xZBM_+"COD")))) + '", ' + CRLF
						cBody += 		'"destinatario": {' + CRLF
						cBody += 			'"cpfCnpj": "'+ alltrim(cCNPJ) + '",' + CRLF
						cBody += 			'"inscricaoMunicipal": "'+ IIF((xZBM)->(FieldGet(FieldPos(xZBM_+"COD"))) <> "3550308",alltrim(cInscr),"") + '",' + CRLF
						cBody +=   			'"autenticacao":{' + CRLF
						cBody +=				'"login":"'+alltrim( (xZBM)->(FieldGet(FieldPos(xZBM_+"USER"))) )+'",' + CRLF
						cBody +=				'"senha":"'+alltrim( (xZBM)->(FieldGet(FieldPos(xZBM_+"PSW"))) )+'"' + CRLF
						cBody +=			'}' + CRLF
						cBody +=		'},' + CRLF
						cBody += 		'"periodo": {'		 + CRLF
						cBody += 			'"inicial": "'+ cDataIni + '", ' + CRLF
						cBody += 			'"final": "'+ cData + '" ' + CRLF
						cBody +=		'}'	 + CRLF
						cBody +=	'}' + CRLF

						oRest:SetPostParams(cBody)

						If oRest:Post(aHeader) 
							If !FWJsonDeserialize(oRest:GetResult(), @oObjJson)
								MsgStop("Ocorreu erro no processamento do Json")
								Return Nil
							EndIf			 

							cLink := "/v1/tomadas/"+ oObjJson:RESPOSTA:PROTOCOLO 

							RecLock(xZBM,.F.)
								(xZBM)->(FieldPut(FieldPos(xZBM_+"STATUS"), "PROCESSANDO" ))
								(xZBM)->(FieldPut(FieldPos(xZBM_+"DATA"), dData ))
							(xZBM)->(MsUnlock())

							RecLock(xZBN,.T.)
								(xZBN)->(FieldPut(FieldPos(xZBN_+"FILIAL"), xFilial(xZBN) ))
								(xZBN)->(FieldPut(FieldPos(xZBN_+"COD"), (xZBM)->(FieldGet(FieldPos(xZBM_+"COD"))) ))
								(xZBN)->(FieldPut(FieldPos(xZBN_+"DATA"), dData ))
								(xZBN)->(FieldPut(FieldPos(xZBN_+"STATUS"), "PROCESSANDO" ))
								(xZBN)->(FieldPut(FieldPos(xZBN_+"LINK"), cLink ))
								cReq := cProtocol2+cUrl+CRLF
								cReq += CRLF

								cReq += "HEADER" + CRLF
								cReq += CRLF

								For nN := 1 to Len(aHeader)
									cReq += aHeader[nN] + CRLF
								Next nN

								cReq += CRLF + CRLF
								cReq += "BODY" + CRLF
								cReq += CRLF
								cReq += cBody
								
								(xZBN)->(FieldPut(FieldPos(xZBN_+"REQ"), cReq ))
							(xZBN)->(MsUnlock())

						Else

							RecLock(xZBM,.F.)
								(xZBM)->(FieldPut(FieldPos(xZBM_+"STATUS"), "ERRO" ))
								//(xZBM)->(FieldPut(FieldPos(xZBM_+"DATA"), dData ))
							(xZBM)->(MsUnlock())

							RecLock(xZBN,.T.)
								(xZBN)->(FieldPut(FieldPos(xZBN_+"FILIAL"), xFilial(xZBN) ))
								(xZBN)->(FieldPut(FieldPos(xZBN_+"COD"), (xZBM)->(FieldGet(FieldPos(xZBM_+"COD"))) ))
								(xZBN)->(FieldPut(FieldPos(xZBN_+"DATA"), dData ))
								(xZBN)->(FieldPut(FieldPos(xZBN_+"STATUS"), "ERRO" ))
								If ( ValType( "oRest:CRESULT" ) <> 'U' )
									(xZBN)->(FieldPut(FieldPos(xZBN_+"MSG"), DecodeUtf8(oRest:CRESULT) + Time()))
								Else 
									(xZBN)->(FieldPut(FieldPos(xZBN_+"MSG"), DecodeUtf8(oRest:CINTERNALERROR) + Time() ))
								EndIF
								cReq := cProtocol2+cUrl+CRLF
								cReq += CRLF

								cReq += "HEADER" + CRLF
								cReq += CRLF

								For nN := 1 to Len(aHeader)
									cReq += aHeader[nN] + CRLF
								Next nN

								cReq += CRLF + CRLF
								cReq += "BODY" + CRLF
								cReq += CRLF
								cReq += cBody
								
								(xZBN)->(FieldPut(FieldPos(xZBN_+"REQ"), cReq ))
							(xZBN)->(MsUnlock())
							cLogProc += "Municํpio "+ alltrim((xZBM)->(FieldGet(FieldPos(xZBM_+"MUNIC")))) + " com ERRO verifique monitor" + chr(13)+chr(10)						

						EndIf  
					EndIf 
				EndIf
			EndIf
		
			If (xZBM)->(FieldGet(FieldPos(xZBM_+"FILIAL"))) == xFilial(xZBM) .AND. (xZBM)->(FieldGet(FieldPos(xZBM_+"ATIVO"))) == "1" .AND. (lAuto .Or. (xZBM)->(FieldGet(FieldPos(xZBM_+"JOB"))) <> "1") 
				For nV := 1 to Len(aVezes)
					//202150300 < 2023150301
					If cDataVez < dtos(dDataBase) + strzero(nV,2) 
						If aVezes[nV] >= subStr(Time(),1,2)
							U_HF068DIA(lAuto,lEnd,oProcess,@cLogProc,nCount)

							If nV == len(aVezes)
								PutMv("XM_DATAMUN", dtos(dDataBase+1)+"00")
							Else
								PutMv("XM_DATAMUN", dtos(dDataBase)+strzero(nV,2) )
							EndIf

						EndIf	
					EndIf
				Next nV

			EndIf
				
			IF (xZBM)->(FieldGet(FieldPos(xZBM_+"FILIAL"))) == xFilial(xZBM) .And. dData == (xZBM)->(FieldGet(FieldPos(xZBM_+"DATA"))) .AND. (xZBM)->(FieldGet(FieldPos(xZBM_+"ATIVO"))) == "1"
				//Verifica se as ZBN estใo ok	

				oRest := NIL								
				FreeObj(oRest)

				cQuery := ""
				cQuery += " Select R_E_C_N_O_ as REG "
				cQuery += " FROM "+RetSqlName(xZBN)+" ZBN "
				cQuery += " Where D_E_L_E_T_ = ' ' "
				cQuery += " And "+xZBN_+"COD = '"+(xZBM)->(FieldGet(FieldPos(xZBM_+"COD")))+"' "
				cQuery += " And "+xZBN_+"DATA = '"+dtos(dData)+"' "		
				cQuery += " And "+xZBN_+"FILIAL = '"+xFilial(xZBN)+"' "

				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasZBN)

				DbSelectARea( cAliasZBN )
				(cAliasZBN)->( dbGoTop() )
				
				Do While .NOT. (cAliasZBN)->( Eof() )

					DbSelectArea( xZBN )
					(xZBN)->( dbGoto( (cAliasZBN)->REG) )

					Do Case 
						Case Alltrim((xZBN)->(FieldGet(FieldPos(xZBN_+"STATUS")))) == "PROCESSANDO"
							oRest 	:= FWRest():New(cProtocol1+cUrl) 		
							oRest:SetPath((xZBN)->(FieldGet(FieldPos(xZBN_+"LINK"))))        

							If oRest:Get(aHeader) 
								If !FWJsonDeserialize(oRest:GetResult(), @oObjJson)
									MsgStop("Ocorreu erro no processamento do Json")
									Return Nil
								EndIf	

								If oObjJson:RESPOSTA:SITUACAO == "CONCLUIDO"
									RecLock(xZBN,.F.)
										(xZBN)->(FieldPut(FieldPos(xZBN_+"STATUS"), "LINK OBTIDO" ))
										(xZBN)->(FieldPut(FieldPos(xZBN_+"QUANT"), oObjJson:RESPOSTA:TOTALDENOTAS ))
									(xZBM)->(MsUnlock())						
								
									RecLock(xZBM,.F.)
										(xZBM)->(FieldPut(FieldPos(xZBM_+"QUANT"), oObjJson:RESPOSTA:TOTALDENOTAS + (xZBM)->(FieldGet(FieldPos(xZBM_+"QUANT"))) ))
									(xZBM)->(MsUnlock())	

									cLogProc += "Municํpio "+ alltrim((xZBM)->(FieldGet(FieldPos(xZBM_+"MUNIC")))) + " " + cValtoChar(oObjJson:RESPOSTA:TOTALDENOTAS) + " notas lidas"+ chr(13)+chr(10)							
								
								ElseIf oObjJson:RESPOSTA:SITUACAO == "ERRO"
									If ( ValType( "oRest:CRESULT" ) <> 'U' )
										If oRest:CRESULT $ " foram encontradas notas nos "
											//Retorno de ERRO mas ้ somente que nใo encontrou notas
											RecLock(xZBN,.F.)
												(xZBN)->(FieldPut(FieldPos(xZBN_+"DATA"), dData ))
												(xZBN)->(FieldPut(FieldPos(xZBN_+"STATUS"), "NENHUMA NOTA" ))
												(xZBN)->(FieldPut(FieldPos(xZBN_+"MSG"), "Nใo hแ nenhuma nota neste dia" + Time() ))
											(xZBN)->(MsUnlock())					
											cLogProc += "Municํpio "+ alltrim((xZBM)->(FieldGet(FieldPos(xZBM_+"MUNIC")))) + " 0 notas lidas" + chr(13)+chr(10)						
										Else
											RecLock(xZBN,.F.)
												(xZBN)->(FieldPut(FieldPos(xZBN_+"DATA"), dData ))
												(xZBN)->(FieldPut(FieldPos(xZBN_+"STATUS"), "ERRO" ))
												(xZBN)->(FieldPut(FieldPos(xZBN_+"MSG"), DecodeUtf8(oRest:CRESULT) + Time() ))	
											(xZBN)->(MsUnlock())
											cLogProc += "Municํpio "+ alltrim((xZBM)->(FieldGet(FieldPos(xZBM_+"MUNIC")))) + " com ERRO verifique monitor" + chr(13)+chr(10)						
					
										EndIf	
									Else
										RecLock(xZBN,.F.)
											(xZBN)->(FieldPut(FieldPos(xZBN_+"DATA"), dData ))
											(xZBN)->(FieldPut(FieldPos(xZBN_+"STATUS"), "ERRO" ))
											(xZBN)->(FieldPut(FieldPos(xZBN_+"MSG"), DecodeUtf8(oRest:CINTERNALERROR)  + Time() ))
										(xZBN)->(MsUnlock())					
										cLogProc += "Municํpio "+ alltrim((xZBM)->(FieldGet(FieldPos(xZBM_+"MUNIC")))) + " com ERRO verifique monitor" + chr(13)+chr(10)						

									EndIf
								ElseIf oObjJson:RESPOSTA:SITUACAO == "PROCESSANDO"
									cLogProc += "Municํpio "+ alltrim((xZBM)->(FieldGet(FieldPos(xZBM_+"MUNIC")))) + " retornou ainda em processamento rota " + (xZBN)->(FieldGet(FieldPos(xZBN_+"LINK"))) + chr(13)+chr(10)															
								EndIf				

							Else 

								oRest := NIL								
								FreeObj(oRest)

								oRest 	:= FWRest():New(cProtocol2+cUrl) 
						
								oRest:SetPath((xZBN)->(FieldGet(FieldPos(xZBN_+"LINK"))))        

								If oRest:Get(aHeader) 
									If !FWJsonDeserialize(oRest:GetResult(), @oObjJson)
										MsgStop("Ocorreu erro no processamento do Json")
										Return Nil
									EndIf	

									If oObjJson:RESPOSTA:SITUACAO == "CONCLUIDO"
										RecLock(xZBN,.F.)
											(xZBN)->(FieldPut(FieldPos(xZBN_+"STATUS"), "LINK OBTIDO" ))
											(xZBN)->(FieldPut(FieldPos(xZBN_+"QUANT"), oObjJson:RESPOSTA:TOTALDENOTAS ))
										(xZBM)->(MsUnlock())						
								
										RecLock(xZBM,.F.)
										(xZBM)->(FieldPut(FieldPos(xZBM_+"QUANT"), oObjJson:RESPOSTA:TOTALDENOTAS + (xZBM)->(FieldGet(FieldPos(xZBM_+"QUANT"))) ))
										(xZBM)->(MsUnlock())	

										cLogProc += "Municํpio "+ alltrim((xZBM)->(FieldGet(FieldPos(xZBM_+"MUNIC")))) + " " + cValtoChar(oObjJson:RESPOSTA:TOTALDENOTAS) + " notas lidas"+ chr(13)+chr(10)							
								
									ElseIf oObjJson:RESPOSTA:SITUACAO == "ERRO"
										If ( ValType( "oRest:CRESULT" ) <> 'U' )
											If oRest:CRESULT $ " foram encontradas notas nos "
												//Retorno de ERRO mas ้ somente que nใo encontrou notas
												RecLock(xZBN,.F.)
													(xZBN)->(FieldPut(FieldPos(xZBN_+"DATA"), dData ))
													(xZBN)->(FieldPut(FieldPos(xZBN_+"STATUS"), "NENHUMA NOTA" ))
													(xZBN)->(FieldPut(FieldPos(xZBN_+"MSG"), "Nใo hแ nenhuma nota neste dia" + Time() ))
												(xZBN)->(MsUnlock())
												cLogProc += "Municํpio "+ alltrim((xZBM)->(FieldGet(FieldPos(xZBM_+"MUNIC")))) + " 0 notas lidas" + chr(13)+chr(10)										
											Else
												RecLock(xZBN,.F.)
													(xZBN)->(FieldPut(FieldPos(xZBN_+"DATA"), dData ))
													(xZBN)->(FieldPut(FieldPos(xZBN_+"STATUS"), "ERRO" ))
													(xZBN)->(FieldPut(FieldPos(xZBN_+"MSG"), DecodeUtf8(oRest:CRESULT) + Time() ))	
												(xZBN)->(MsUnlock())					
											EndIf	
										Else
											RecLock(xZBN,.F.)
												(xZBN)->(FieldPut(FieldPos(xZBN_+"DATA"), dData ))
												(xZBN)->(FieldPut(FieldPos(xZBN_+"STATUS"), "ERRO" ))
												(xZBN)->(FieldPut(FieldPos(xZBN_+"MSG"), DecodeUtf8(oRest:CINTERNALERROR)  + Time() ))
											(xZBN)->(MsUnlock())					

										EndIf
									EndIf
								Else

									RecLock(xZBM,.F.)
										(xZBM)->(FieldPut(FieldPos(xZBM_+"STATUS"), "ERRO" ))
										(xZBM)->(FieldPut(FieldPos(xZBM_+"DATA"), dData ))
									(xZBM)->(MsUnlock())

									RecLock(xZBN,.F.)
										(xZBN)->(FieldPut(FieldPos(xZBN_+"DATA"), dData ))
										(xZBN)->(FieldPut(FieldPos(xZBN_+"STATUS"), "ERRO" ))
										If ( ValType( "oRest:CRESULT" ) <> 'U' )
											(xZBN)->(FieldPut(FieldPos(xZBN_+"MSG"), DecodeUtf8(oRest:CRESULT) + Time() ))
										Else 
											(xZBN)->(FieldPut(FieldPos(xZBN_+"MSG"), DecodeUtf8(oRest:CINTERNALERROR) + Time() ))
										EndIF
										(xZBN)->(FieldPut(FieldPos(xZBN_+"QUANT"), 0 ))
									(xZBN)->(MsUnlock())

									cLogProc += "Municํpio "+ alltrim((xZBM)->(FieldGet(FieldPos(xZBM_+"MUNIC")))) + " 0 notas lidas" + chr(13)+chr(10)						

								EndIf  
							EndIf	

						Case Alltrim((xZBN)->(FieldGet(FieldPos(xZBN_+"STATUS")))) == "LINK OBTIDO"

							cLink := alltrim((xZBN)->(FieldGet(FieldPos(xZBN_+"LINK"))))
					
							DownNFSE(cLink)

							RecLock(xZBN,.F.)
								(xZBN)->(FieldPut(FieldPos(xZBN_+"DATA"), dData ))
								(xZBN)->(FieldPut(FieldPos(xZBN_+"STATUS"), "DOWNLOAD EFETUADO" ))
							(xZBN)->(MsUnlock())

						OtherWise

					EndCase

					(cAliasZBN)->( dbSkip() )

				EndDo

				(cAliasZBN)->( dbCloseArea() )

			EndIf		

			cStatus	:= U_AtuZBM()

			RecLock(xZBM,.F.)
				(xZBM)->(FieldPut(FieldPos(xZBM_+"STATUS"), cStatus ))
			(xZBM)->(MsUnlock())
			
			(xZBM)->(dbSkip())
		End

		//Verifica ZBN pendente de dias anteriores
		cQuery := ""
		cQuery += " Select R_E_C_N_O_ as REG "
		cQuery += " FROM "+RetSqlName(xZBN)+" ZBN "
		cQuery += " Where D_E_L_E_T_ = ' ' "
		cQuery += " And "+xZBN_+"FILIAL = '"+xFilial(xZBN)+"' "		
		cQuery += " And "+xZBN_+"STATUS <> 'DOWNLOAD EFETUADO' "
		cQuery += " And "+xZBN_+"DATA >= '"+dtos(dDataBase-30)+"' "

		If !lAuto .Or. oProcess<>Nil      

			oProcess:IncRegua1("Consultando municํpios pendentes...")
			oProcess:IncRegua2("Aguarde...")      

		EndIf

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasZBN)

		DbSelectARea( cAliasZBN )
		(cAliasZBN)->( dbGoTop() )
		
		Do While .NOT. (cAliasZBN)->( Eof() )

			DbSelectArea( xZBN )
			(xZBN)->( dbGoto( (cAliasZBN)->REG) )

			Do Case 
				Case Alltrim((xZBN)->(FieldGet(FieldPos(xZBN_+"STATUS")))) == "PROCESSANDO"

					oRest := NIL								
					FreeObj(oRest)				
					
					oRest 	:= FWRest():New(cProtocol1+cUrl) 
					oRest:SetPath((xZBN)->(FieldGet(FieldPos(xZBN_+"LINK"))))        

					If oRest:Get(aHeader) 
						If !FWJsonDeserialize(oRest:GetResult(), @oObjJson)
							MsgStop("Ocorreu erro no processamento do Json")
							Return Nil
						EndIf	

						If oObjJson:RESPOSTA:SITUACAO == "CONCLUIDO"
							RecLock(xZBN,.F.)
								(xZBN)->(FieldPut(FieldPos(xZBN_+"STATUS"), "LINK OBTIDO" ))
								(xZBN)->(FieldPut(FieldPos(xZBN_+"QUANT"), oObjJson:RESPOSTA:TOTALDENOTAS ))
							(xZBM)->(MsUnlock())						
						
							(xZBM)->(dbSeek(xFilial(xZBM) + (xZBN)->(FieldGet(FieldPos(xZBN_+"COD"))) ))

							RecLock(xZBM,.F.)
								(xZBM)->(FieldPut(FieldPos(xZBM_+"QUANT"), oObjJson:RESPOSTA:TOTALDENOTAS + (xZBM)->(FieldGet(FieldPos(xZBM_+"QUANT"))) ))
							(xZBM)->(MsUnlock())	

							cLogProc += "Municํpio "+ alltrim((xZBM)->(FieldGet(FieldPos(xZBM_+"MUNIC")))) + " " + cValtoChar(oObjJson:RESPOSTA:TOTALDENOTAS) + " notas lidas"+ chr(13)+chr(10)							
						
						ElseIf oObjJson:RESPOSTA:SITUACAO == "ERRO"
							RecLock(xZBN,.F.)
								(xZBN)->(FieldPut(FieldPos(xZBN_+"DATA"), dData ))
								(xZBN)->(FieldPut(FieldPos(xZBN_+"STATUS"), "DOWNLOAD EFETUADO" ))
								If ( ValType( "oRest:CRESULT" ) <> 'U' )
									(xZBN)->(FieldPut(FieldPos(xZBN_+"MSG"), DecodeUtf8(oRest:CRESULT) + Time() ))
								Else 
									(xZBN)->(FieldPut(FieldPos(xZBN_+"MSG"), DecodeUtf8(oRest:CINTERNALERROR) + Time() ))
								EndIF
								(xZBN)->(MsUnlock())					
						EndIf				

					Else 

						oRest := NIL								
						FreeObj(oRest)				
						
						oRest 	:= FWRest():New(cProtocol2+cUrl) 
						oRest:SetPath((xZBN)->(FieldGet(FieldPos(xZBN_+"LINK"))))        

						If oRest:Get(aHeader) 
							If !FWJsonDeserialize(oRest:GetResult(), @oObjJson)
								MsgStop("Ocorreu erro no processamento do Json")
								Return Nil
							EndIf	

							If oObjJson:RESPOSTA:SITUACAO == "CONCLUIDO"
								RecLock(xZBN,.F.)
									(xZBN)->(FieldPut(FieldPos(xZBN_+"STATUS"), "LINK OBTIDO" ))
									(xZBN)->(FieldPut(FieldPos(xZBN_+"QUANT"), oObjJson:RESPOSTA:TOTALDENOTAS ))
								(xZBM)->(MsUnlock())						
							
								(xZBM)->(dbSeek(xFilial(xZBM) + (xZBN)->(FieldGet(FieldPos(xZBN_+"COD"))) ))

								RecLock(xZBM,.F.)
									(xZBM)->(FieldPut(FieldPos(xZBM_+"QUANT"), oObjJson:RESPOSTA:TOTALDENOTAS + (xZBM)->(FieldGet(FieldPos(xZBM_+"QUANT"))) ))
								(xZBM)->(MsUnlock())	

								cLogProc += "Municํpio "+ alltrim((xZBM)->(FieldGet(FieldPos(xZBM_+"MUNIC")))) + " " + cValtoChar(oObjJson:RESPOSTA:TOTALDENOTAS) + " notas lidas"+ chr(13)+chr(10)							
							
							ElseIf oObjJson:RESPOSTA:SITUACAO == "ERRO"
								RecLock(xZBN,.F.)
									(xZBN)->(FieldPut(FieldPos(xZBN_+"DATA"), dData ))
									(xZBN)->(FieldPut(FieldPos(xZBN_+"STATUS"), "DOWNLOAD EFETUADO" ))
									If ( ValType( "oRest:CRESULT" ) <> 'U' )
										(xZBN)->(FieldPut(FieldPos(xZBN_+"MSG"), DecodeUtf8(oRest:CRESULT) + Time() ))
									Else 
										(xZBN)->(FieldPut(FieldPos(xZBN_+"MSG"), DecodeUtf8(oRest:CINTERNALERROR) + Time() ))
									EndIF
									(xZBN)->(MsUnlock())					
							EndIf				

						Else

							RecLock(xZBN,.F.)
								(xZBN)->(FieldPut(FieldPos(xZBN_+"DATA"), dData ))
								(xZBN)->(FieldPut(FieldPos(xZBN_+"STATUS"), "ERRO" ))
								If ( ValType( "oRest:CRESULT" ) <> 'U' )
									(xZBN)->(FieldPut(FieldPos(xZBN_+"MSG"), DecodeUtf8(oRest:CRESULT) + Time() ))
								Else 
									(xZBN)->(FieldPut(FieldPos(xZBN_+"MSG"), DecodeUtf8(oRest:CINTERNALERROR) + Time() ))
								EndIF
								(xZBN)->(FieldPut(FieldPos(xZBN_+"QUANT"), 0 ))
							(xZBN)->(MsUnlock())

							cLogProc += "Municํpio "+ (xZBM)->(FieldGet(FieldPos(xZBM_+"MUNIC"))) + " 0 notas lidas" + chr(13)+chr(10)						
						EndIf	
					EndIf  

				Case Alltrim((xZBN)->(FieldGet(FieldPos(xZBN_+"STATUS")))) == "LINK OBTIDO"

					cLink := alltrim((xZBN)->(FieldGet(FieldPos(xZBN_+"LINK"))))
					
					DownNFSE(cLink)

					RecLock(xZBN,.F.)
						(xZBN)->(FieldPut(FieldPos(xZBN_+"DATA"), dData ))
						(xZBN)->(FieldPut(FieldPos(xZBN_+"STATUS"), "DOWNLOAD EFETUADO" ))
					(xZBN)->(MsUnlock())

				OtherWise

			EndCase

			(cAliasZBN)->( dbSkip() )

		EndDo

		(cAliasZBN)->( dbCloseArea() )

	EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    DownNFSE   บ Autor ณ Heverton Marcondes บ Data ณ 01/09/2020  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ DownNFSE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function DownNFSE(cLink)

    Local cCnpj 		:= ""
	Local cChave		:= ""
	Local cXml			:= ""
	Local cPath			:= alltrim(cLink)
	Local oRestClient 	:= Nil  
    Local aHeader 		:= {} 
    Local oObjJson  	:= Nil
    Local nX			:= 0
	Local cNota			:= ""
	Local dEmissao		:= stod("")
	Local cCodEmit  	:= ""
	Local cLojaEmit 	:= ""
	Local cRazao    	:= ""
	Local nAuxVar		:= ""

	Private nFormNfe := Val(GetNewPar("XM_FORMNFE","9"))

	cCnpj 	:= Alltrim(FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , { "M0_CGC" } )[1][2])
	cInscr	:= Alltrim(FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , { "M0_INSCM" } )[1][2])
	//cInscr	:= ""
    
	Aadd(aHeader, "Content-Type: application/json")                      
    Aadd(aHeader, "token_sh: 8362a6f9f284692afa0d191b34a0cbdd")                      
    Aadd(aHeader, "cpfCnpjSoftwareHouse: 07084316000158")                      
    Aadd(aHeader, "cpfCnpjTomador: "+cCnpj)                      

	cPath += "/notas"
	oRestClient := FWRest():New(cProtocol1+cUrl)
	oRestClient:SetPath(cPath)        

	If oRestClient:Get(aHeader) 
		If !FWJsonDeserialize(oRestClient:GetResult(), @oObjJson)
			MsgStop("Ocorreu erro no processamento do Json")
			Return Nil
		EndIf			 
	Else 
		oRest := NIL								
		FreeObj(oRest)

		oRestClient := FWRest():New(cProtocol2+cUrl)
		oRestClient:SetPath(cPath)

		If oRestClient:Get(aHeader) 
			If !FWJsonDeserialize(oRestClient:GetResult(), @oObjJson)
				MsgStop("Ocorreu erro no processamento do Json")
				Return Nil
			EndIf
		Else
			Conout("GET - ERRO" + oRestClient:GetLastError()) 
		EndIf	
	EndIf  

	if oObjJson <> Nil 
	
		if AT("acoes",oRestClient:GetResult()) > 0
    
			For nX := 1 to len(oObjJson:RESPOSTA:NOTAS)

				If oObjJson:RESPOSTA:NOTAS[nX]:TOMADOR:CPFCNPJ == cCnpj

					DbSelectArea( xZBZ )
					dbSetORder(3)

					//Numero da Nota
					cNota	:= strZero(Val(right(oObjJson:RESPOSTA:NOTAS[nX]:SERVICOS[1]:NFSE:NUMERO,nFormNfe)),nFormNfe)

					//Emissใo
					//cTagAux := "oObjJson:RESPOSTA:NOTAS["+cValtoChar(nX)+"]:SERVICOS[1]:NFSE:DATAAUTORIZACAO"

					//If Type(cTagAux) <> "U"

					dEmissao := stod(;
						substr(oObjJson:RESPOSTA:NOTAS[nX]:SERVICOS[1]:NFSE:DATAAUTORIZACAO,1,4)+;
						substr(oObjJson:RESPOSTA:NOTAS[nX]:SERVICOS[1]:NFSE:DATAAUTORIZACAO,6,2)+;
						substr(oObjJson:RESPOSTA:NOTAS[nX]:SERVICOS[1]:NFSE:DATAAUTORIZACAO,9,2);
					)	
					//Else

					//	dEmissao := dDataBase-1	

					//EndIf
					
					//Chave
					cChave := (;
					dtos(dEmissao)+;
					oObjJson:RESPOSTA:NOTAS[nX]:PRESTADOR:CPFCNPJ+;
					cNota;           
					)
					cChave := cChave + Replicate("0",44-len(cChave))

					//UF
					If !Empty(substr(oObjJson:RESPOSTA:NOTAS[nX]:PRESTADOR:ENDERECO:CODIGOCIDADE,1,2))
						nUf	:= aScan(aUF,{|x| x[2] == substr(oObjJson:RESPOSTA:NOTAS[nX]:PRESTADOR:ENDERECO:CODIGOCIDADE,1,2)})
						cUf := aUF[nUf][1]
					Else
						cUf := Posicione("SA2",3,xFilial("SA2")+oObjJson:RESPOSTA:NOTAS[nX]:PRESTADOR:CPFCNPJ,"A2_EST")
					EndIf	

					//Fornecedor
					VerFor(oObjJson:RESPOSTA:NOTAS[nX]:PRESTADOR:CPFCNPJ,@cCodEmit,@cLojaEmit,@cRazao)
					
					//FR - 27/11/2020
					//===================//
					// Grava ZBZ:        //
					//===================//      
					(xZBZ)->(OrdSetFocus(3))	//FR - 27/11/2020      
					//If !dbSeek(xFilial(xZBZ)+cChave)	
					If !(xZBZ)->(dbSeek(cChave))

						cDescServ := HfCaracterEspecial(Noacento2(Alltrim(oObjJson:RESPOSTA:NOTAS[nX]:SERVICOS[1]:DISCRIMINACAOSERVICO)))

						Reclock(xZBZ,.T.)
							(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CHAVE"), cChave))
							(xZBZ)->(FieldPut(FieldPos(xZBZ_+"FILIAL"), xFilial(xZBZ) ))
						(xZBZ)->(MsUnLock())

						cXml:= '<?xml version="1.0" encoding="UTF-8"?>'
						cXml+= '<NfseTxt versao="1.00">'
						cXml+= '<InfProc>'
						cXml+= '<Cnpj>'+oObjJson:RESPOSTA:NOTAS[nX]:PRESTADOR:CPFCNPJ+'</Cnpj>'
						cXml+= '<VrServ>'+AllTrim(Str(oObjJson:RESPOSTA:NOTAS[nX]:VALORSERVICOS ,20,2))+'</VrServ>'
						cXml+= '<VrDedz>'+AllTrim(Str(oObjJson:RESPOSTA:NOTAS[nX]:SERVICOS[1]:ISS:RETIDO,20,2))+'</VrDedz>'

						//ISS
						nAuxVar := oObjJson:RESPOSTA:NOTAS[nX]:SERVICOS[1]:ISS:ALIQUOTA

						If ValType(nAuxVar) <> "N"
							cXml+= '<Aliq>'+'0.0000'+'</Aliq>'
						Else
							cXml+= '<Aliq>'+AllTrim(Str(oObjJson:RESPOSTA:NOTAS[nX]:SERVICOS[1]:ISS:ALIQUOTA,20,4))+'</Aliq>'
						EndIf

						nAuxVar := oObjJson:RESPOSTA:NOTAS[nX]:SERVICOS[1]:ISS:VALOR

						If ValType(nAuxVar) <> "N"
							cXml+= '<VRISS>'+'0.0000'+'</VRISS>'
						Else
							cXml+= '<VRISS>'+AllTrim(Str(oObjJson:RESPOSTA:NOTAS[nX]:SERVICOS[1]:ISS:ALIQUOTA,20,4))+'</VRISS>'
						EndIf

						//INSS
						nAuxVar := oObjJson:RESPOSTA:NOTAS[nX]:RETENCAO:INSS
						If ValType(nAuxVar) <> "N"
							cXml+= '<AliqINSS>'+'0.0000'+'</AliqINSS>'
						Else
							cXml+= '<AliqINSS>'+AllTrim(Str(oObjJson:RESPOSTA:NOTAS[nX]:RETENCAO:INSS,20,4))+'</AliqINSS>'
						EndIf

						//PIS
						nAuxVar := oObjJson:RESPOSTA:NOTAS[nX]:RETENCAO:PIS
						If ValType(nAuxVar) <> "N"
							cXml+= '<AliqPIS>'+'0.0000'+'</AliqPIS>'
						Else
							cXml+= '<AliqPIS>'+AllTrim(Str(oObjJson:RESPOSTA:NOTAS[nX]:RETENCAO:PIS,20,4))+'</AliqPIS>'
						EndIf
						
						//COFINS
						nAuxVar := oObjJson:RESPOSTA:NOTAS[nX]:RETENCAO:COFINS
						If ValType(nAuxVar) <> "N"
							cXml+= '<AliqCOFINS>'+'0.0000'+'</AliqCOFINS>'
						Else
							cXml+= '<AliqCOFINS>'+AllTrim(Str(oObjJson:RESPOSTA:NOTAS[nX]:RETENCAO:COFINS,20,4))+'</AliqCOFINS>'
						EndIf

						//CSLL
						nAuxVar := oObjJson:RESPOSTA:NOTAS[nX]:RETENCAO:CSLL
						If ValType(nAuxVar) <> "N"
							cXml+= '<AliqCSLL>'+'0.0000'+'</AliqCSLL>'
						Else
							cXml+= '<AliqCSLL>'+AllTrim(Str(oObjJson:RESPOSTA:NOTAS[nX]:RETENCAO:CSLL,20,4))+'</AliqCSLL>'
						EndIf

						//IRRF
						nAuxVar := oObjJson:RESPOSTA:NOTAS[nX]:RETENCAO:IR
						If ValType(nAuxVar) <> "N"
							cXml+= '<AliqIR>'+'0.0000'+'</AliqIR>'
						Else
							cXml+= '<AliqIR>'+AllTrim(Str(oObjJson:RESPOSTA:NOTAS[nX]:RETENCAO:IR,20,4))+'</AliqIR>'
						EndIf
						cXml+= '<DesSrv>'+cDescServ+'</DesSrv>'
						cXml+= '<ProdSrv>'+oObjJson:RESPOSTA:NOTAS[nX]:SERVICOS[1]:ITEMLISTASERVICO+'</ProdSrv>'
						cXml+= '</InfProc>'
						cXml+= '</NfseTxt>'

						cXml := NoAcento(cXml)
						cXml := EncodeUTF8(cXml)

						Reclock(xZBZ,.F.)
							(xZBZ)->(FieldPut(FieldPos(xZBZ_+"UF"), cUf ))
							(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CNPJ"), oObjJson:RESPOSTA:NOTAS[nX]:PRESTADOR:CPFCNPJ ))
							(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CNPJD"), oObjJson:RESPOSTA:NOTAS[nX]:TOMADOR:CPFCNPJ ))
							(xZBZ)->(FieldPut(FieldPos(xZBZ_+"NOTA"), U_NumNota(cNota,nFormNfe)  ))
							(xZBZ)->(FieldPut(FieldPos(xZBZ_+"DTRECB"), dDataBase))
							(xZBZ)->(FieldPut(FieldPos(xZBZ_+"DTNFE"), dEmissao ))
							(xZBZ)->(FieldPut(FieldPos(xZBZ_+"MODELO"), "RP" )) 
							If oObjJson:RESPOSTA:NOTAS[nX]:SERVICOS[1]:SITUACAO == "CANCELADA"
								(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PRENF"), "X"  ))
								(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PROTC"), "CANC" ))
							Else
								(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PRENF"), "B"  ))
							EndIf
							(xZBZ)->(FieldPut(FieldPos(xZBZ_+"STATUS"), "1"))
							(xZBZ)->(FieldPut(FieldPos(xZBZ_+"TPDOC"), "N"))
							(xZBZ)->(FieldPut(FieldPos(xZBZ_+"FORPAG"), "1"))
							(xZBZ)->(FieldPut(FieldPos(xZBZ_+"FORNEC"), cRazao))
							(xZBZ)->(FieldPut(FieldPos(xZBZ_+"CODFOR"), cCodEmit))		
							(xZBZ)->(FieldPut(FieldPos(xZBZ_+"LOJFOR"), cLojaEmit))			
							(xZBZ)->(FieldPut(FieldPos(xZBZ_+"VLBRUT"), oObjJson:RESPOSTA:NOTAS[nX]:VALORSERVICOS ))
							(xZBZ)->(FieldPut(FieldPos(xZBZ_+"OBS"), oObjJson:RESPOSTA:NOTAS[nX]:SERVICOS[1]:DISCRIMINACAOSERVICO ))
							(xZBZ)->(FieldPut(FieldPos(xZBZ_+"XML"), cXml))

						(xZBZ)->(MsUnLock())  

						//FR - 27/11/2020
						//===================//
						// Grava ZBT:        //
						//===================//
						cModelo   := "RP"			
						cCnpjEmi  := oObjJson:RESPOSTA:NOTAS[nX]:PRESTADOR:CPFCNPJ		//CNPJ do Emitente	
						
						U_fGrvZBTR(cXml,cChave,cNota,cCnpjEmi)
						
						//U_fGravaZBT(cXml,cModelo,cChave,cNota,"" /*cSeriNF*/ ,cCnpjEmi) //NF Servi็o nใo tem s้rie (?) //A forma de gravar a ZBT para notas de servi็o ้ diferente devido ao xml ser diferente
						//FR - 27/11/2020

					Else
						If oObjJson:RESPOSTA:NOTAS[nX]:SERVICOS[1]:SITUACAO == "CANCELADA"
							Reclock(xZBZ,.F.)
								(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PRENF"), "X"  ))
								(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PROTC"), "CANC" ))
							(xZBZ)->(MsUnLock()) 
						EndIf							
					EndIf

				EndIf

			Next nX

		endif

	endif 

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ  VerFor  บAutor  ณ Eneo               บ Data ณ 02/05/2016  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verificar c๓digo do fornecedor.                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Importa XML                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
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

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออัออออออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบPrograma   HF068BRW   ณ Cadastro Municipios		                                      บฑฑ
ฑฑบ           ณ          ณ                                                                บฑฑ
ฑฑฬอออออออออออุออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParโmetros ณNil.                                                                       บฑฑ
ฑฑฬอออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno    ณNil                                                                        บฑฑ
ฑฑวฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤถฑฑ
ฑฑบAutor      ณ 01/09/20 ณHeverton Marcondes dos Santos                                   บฑฑ
ฑฑวฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤถฑฑ
ฑฑบDescricao  ณ Manuten็ใo no cadastro de Municipios                                      บฑฑ
ฑฑศอออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function HF068BRW()

Local aArea 	:= {}
Local cFiltro	:= ""
//Local aCoors  	:= FWGetDialogSize( oMainWnd )

Private xZBZ  	:= GetNewPar("XM_TABXML" ,"ZBZ")
Private xZBM  	:= GetNewPar("XM_TABMUN" ,"ZBM")
Private xZBN  	:= GetNewPar("XM_TABMUN2" ,"ZBN")
Private xZBZ_ 	:= iif(Substr(xZBZ,1,1)=="S", Substr(xZBZ,2,2), Substr(xZBZ,1,3)) + "_"
Private xZBM_ 	:= iif(Substr(xZBM,1,1)=="S", Substr(xZBM,2,2), Substr(xZBM,1,3)) + "_"
Private xZBN_ 	:= iif(Substr(xZBN,1,1)=="S", Substr(xZBN,2,2), Substr(xZBN,1,3)) + "_"
Private oBrowse

aArea := (xZBM)->(GetArea())
cFiltro	:= xZBM_+'ATIVO == "1"'

aRotina := MenuDef()

oBrowse := FWMBrowse():New()
oBrowse:SetAlias(xZBM)
oBrowse:SetDescription("Municipios")
oBrowse:DisableDetails()

oBrowse:AddLegend( xZBM+"->"+xZBM_+"ATIVO == '1' "	, 'GREEN'   , OemToAnsi("Ativo") )
oBrowse:AddLegend( xZBM+"->"+xZBM_+"ATIVO == '2' "	, 'RED'		, OemToAnsi("Nใo Processa") ) 
	
If Aviso( "Filtrar/Todos", "Deseja filtrar apenas os municipios ativos", { "Filtrar", "Todos" } ) == 1
	oBrowse:SetFilterDefault(cFiltro)
EndIf	

oBrowse:Activate()

RestArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณMenuDef   บ Autor ณ Heverton Marcondes บ Data ณ 09/11/2017  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Menudef                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE "Pesquisar"  			ACTION "PesqBrw" 			OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE "Visualizar" 			ACTION "VIEWDEF.HFXML068" 	OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Certificado"    		ACTION "U_HF068CER" 		OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Atualiza Municipios"  ACTION "U_HF068MUA" 		OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Nova Consulta"  		ACTION "U_HF068NVC" 		OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Consulta Log"  		ACTION "U_HF074BRW" 		OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Fornecedores"  		ACTION "U_HF068FOR" 		OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Alterar"  	  		ACTION "VIEWDEF.HFXML068" 	OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Excluir" 	   			ACTION "VIEWDEF.HFXML068"	OPERATION 5 ACCESS 0
ADD OPTION aRotina TITLE "Imprimir" 			ACTION "VIEWDEF.HFXML068" 	OPERATION 8 ACCESS 0
ADD OPTION aRotina TITLE "Legenda"          	ACTION "U_HF068LEG"  		OPERATION 2 ACCESS 0

Return aRotina

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณModelDef  บ Autor ณ Heverton Marcondes บ Data ณ 01/09/2020  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Modeldef                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function ModelDef()

Local oStruZBM := FWFormStruct( 1, xZBM)
//Local oStruZBN := FWFormStruct( 1, xZBN)
Local oModel

oModel := MPFormModel():New( 'MHF068BRW')

oModel:AddFields( xZBM, /*cOwner*/, oStruZBM )
//oModel:AddGrid( xZBN, xZBM, oStruZBN )
oModel:SetPrimaryKey({xZBM_+"FILIAL",xZBM_+"COD"})

oModel:SetDescription( 'Municipios' )

oModel:GetModel( xZBM ):SetDescription( 'Municipios' )
//oModel:SetRelation( xZBN, { { xZBN_+'FILIAL', 'xFilial( "'+xZBN+'" )' },{ xZBN_+'COD', xZBM_+'COD' }  }, (xZBN)->( IndexKey( 1 ) ) )
//oModel:GetModel( xZBN ):SetOptional( .T. )

Return oModel

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณViewDef   บ Autor ณ Heverton Marcondes บ Data ณ 01/09/2020  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ ViewDef                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function ViewDef()

Local oModel := ModelDef()

Local oStruZBM	:= FWFormStruct( 2, xZBM )
//Local oStruZBN	:= FWFormStruct( 2, xZBN )

Local oView

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField( 'VIEW_ZBM', oStruZBM, xZBM)
//oView:AddGrid( 'VIEW_ZBN', oStruZBN, xZBN )

oView:CreateHorizontalBox( 'PRIMEIRA', 100 )
//oView:CreateHorizontalBox( 'SEGUNDA', 70 )

oView:SetOwnerView( 'VIEW_ZBM', 'PRIMEIRA' )
//oView:SetOwnerView( 'VIEW_ZBN', 'SEGUNDA' )

Return oView

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    HF068LEG   บ Autor ณ Heverton Marcondes บ Data ณ 01/09/2020  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ HF068LEG                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

USer Function HF068LEG()

Local aLegenda := {}

AADD(aLegenda,{"BR_VERDE" 	,"Ativo" })
AADD(aLegenda,{"BR_VERMELHO","Nใo Processa" })

BrwLegenda("Municipios", "Legenda", aLegenda)

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    AtuZBM   บ Autor ณ Heverton Marcondes บ Data ณ 01/09/2020  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ AtuZBM                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function AtuZBM()

Local cStatus 	:= " "
Local cQuery  	:= " "
Local cAliasZBN	:= GetNextAlias() 

cQuery := ""
cQuery += " Select R_E_C_N_O_ as REG "
cQuery += " FROM "+RetSqlName(xZBN)+" ZBN "
cQuery += " Where D_E_L_E_T_ = ' ' "
cQuery += " And "+xZBN_+"COD = '"+(xZBM)->(FieldGet(FieldPos(xZBM_+"COD")))+"' "
cQuery += " And "+xZBN_+"DATA = '"+dtos(dDataBase-1)+"' "
cQuery += " And "+xZBN_+"STATUS <> 'DOWNLOAD EFETUADO' "
cQuery += " And "+xZBN_+"FILIAL = '"+xFilial(xZBN)+"' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasZBN)

DbSelectArea( cAliasZBN )
(cAliasZBN)->( dbGoTop() )

If !(cAliasZBN)->(Eof())
	cStatus := "PROCESSANDO"
EndIf	

(cAliasZBN)->(dbCloseArea())

Return cStatus

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    HF068CER   บ Autor ณ Heverton Marcondes บ Data ณ 01/09/2020  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ HF068CER                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function HF068CER()

Local cGet1		:= Space(250) //"c:\totvs\tss\certs\coferly2020.pfx" //Arquivo
Local cGet2		:= Space(20) //"coferly2020" //Senha
Local oDlg		:= Nil			
Local oGet1		:= Nil
Local oGet2		:= Nil
Local oButton1	:= Nil
Local oButton2	:= Nil
Local oButton3	:= Nil

DEFINE DIALOG oDlg TITLE "Informe o certificado e a senha" FROM 180,180 TO 350,450 PIXEL

oGet1		:= TGet():New( 001,01,{ | u | If( PCount() == 0, cGet1, cGet1 := u ) },oDlg,100,010,,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,'cGet1',,,, )
oGet2		:= TGet():New( 020,01,{ | u | If( PCount() == 0, cGet2, cGet2 := u ) },oDlg,100,010,,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.T.,,'cGet2',,,, )

oButton1	:= TButton():New( 01, 110, "Buscar",oDlg,{|| cGet1 := cGetFile( "PFX|*.PFX", "Escolha o certificado a ser enviado", 0, "/certs", .T.,0,.T.),oGet1:Refresh()}, 30,10,,,.F.,.T.,.F.,,.F.,,,.F. )   

oButton2	:= TButton():New( 040, 010, "Enviar",oDlg,{|| U_HF068UP(cGet1,cGet2), oDlg:End() }, 30,20,,,.F.,.T.,.F.,,.F.,,,.F. )   
oButton3	:= TButton():New( 040, 050, "Cancelar",oDlg,{|| oDlg:End() }, 30,20,,,.F.,.T.,.F.,,.F.,,,.F. )

ACTIVATE DIALOG oDlg CENTERED

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    HF068UP   บ Autor ณ Heverton Marcondes บ Data ณ 01/09/2020  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ HF068UP                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function HF068UP(cArquivo,cPsw)

	Local cUrl  		:= "api.nfse.tecnospeed.com.br/v1/certificados"
	Local aHeader		:= {}
	Local cPostParams	:= ""
	Local cCnpj			:= Alltrim(FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , { "M0_CGC" } )[1][2])
	Local cResult		:= ""
	Local oObjJson		:= ""
	Local cProtocol1	:= "https://"
	Local cProtocol2	:= "http://"

	Aadd(aHeader, "token_sh: 8362a6f9f284692afa0d191b34a0cbdd")                      
	Aadd(aHeader, "cpfCnpjSoftwareHouse: 07084316000158")                      
	Aadd(aHeader, "cpfCnpjTomador: "+cCnpj) 
	aadd(aHeader,'Content-Type: multipart/form-data ; boundary=----WebKitFormBoundaryFbmu0bODj7UvfQEV')
	
	cPostParams := ""
	cPostParams += CRLF
	cPostParams += 'Content-Disposition: form-data; name="senha"'
	cPostParams += CRLF
	cPostParams += CRLF
	cPostParams += alltrim(cPsw)
	cPostParams += CRLF
	cPostParams += 'Content-Disposition: form-data; name="arquivo"; filename="'+cArquivo+'"' + CRLF      //Envio de Arquivo sem espeficar o Content-Type
 	cRetWs  := HttpPost(cProtocol1+cUrl,"",cPostParams,60,aHeader,@cResult)

	If !Empty(cRetWs) 

		If !FWJsonDeserialize(cRetWs, @oObjJson)
			MsgStop("Ocorreu erro no processamento do Json")
			Return Nil
		Else
			if AT('erro', cRetWs ) > 0
				msgInfo( oObjJson:ERRO:MENSAGEM )
			else
				msgInfo( oObjJson:RESPOSTA:MENSAGEM + ", vencimento em " + oObjJson:RESPOSTA:VENCIMENTO )
			endif
		EndIf	

	Else

		cRetWs  := HttpPost(cProtocol2+cUrl,"",cPostParams,60,aHeader,@cResult)

		If !Empty(cRetWs) 

			If !FWJsonDeserialize(cRetWs, @oObjJson)
				MsgStop("Ocorreu erro no processamento do Json")
				Return Nil
			Else
				if AT('erro', cRetWs ) > 0
					msgInfo( oObjJson:ERRO:MENSAGEM )
				else
					msgInfo( oObjJson:RESPOSTA:MENSAGEM + ", vencimento em " + oObjJson:RESPOSTA:VENCIMENTO )
				endif
			EndIf	

		else

			msgAlert("Problema na integra็ใo ao WebService")

		Endif

	EndIf	

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    HF068MUN   บ Autor ณ Heverton Marcondes บ Data ณ 01/09/2020  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ HF068MUA                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function HF068MUA()

	Local lAuto 	:= .F.
	Local lEnd		:= .F.
	Local cLogProc	:= ""
	Local nCount	:= 0
	
	Private oProcess

	oProcess := MsNewProcess():New( {|lEnd| U_HF068MUN(lAuto,@lEnd,oProcess,@cLogProc,@nCount)} ,"Processando...","Processando Rotinas...",.T.)	//###
	oProcess:Activate()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    HF068MUN   บ Autor ณ Heverton Marcondes บ Data ณ 01/09/2020  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ HF068MUN                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function HF068MUN(lAuto,lEnd,oProcess,cLogProc,nCount)

	Local cUrl 			:= "api.nfse.tecnospeed.com.br" 
	Local cProtocol1	:= "https://"
	Local cProtocol2	:= "http://"
	Local aHeader		:= {} 
	Local oRest	
	Local cCnpj			:= Alltrim(FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , { "M0_CGC" } )[1][2])
	//Local cParms		:= ""
	Local cPath 		:= "/v1/cidades" 
	Local oObjJson
	Local dUltData		:= Stod(AllTrim(SuperGetMv("XM_DATAMUN")))

	Default oProcess 	:= nil
	Default lAuto 	 	:= .F.

	If dUltData < dDataBase .Or. lAuto
		If !lAuto .Or. oProcess<>Nil      

			oProcess:IncRegua1("Atualizando municํpios...")
			oProcess:IncRegua2("Aguarde...")      

		EndIf

		Aadd(aHeader, "Content-Type: application/json")                     
		Aadd(aHeader, "token_sh: 8362a6f9f284692afa0d191b34a0cbdd")                      
		Aadd(aHeader, "cpfCnpjSoftwareHouse: 07084316000158")                      
		Aadd(aHeader, "cpfCnpjTomador: "+cCnpj) 
			
		oRest := FWRest():New(cProtocol1+cUrl) 
		oRest:SetPath(cPath)        	

		If oRest:Get(aHeader) 
			If !FWJsonDeserialize(oRest:GetResult(), @oObjJson)
				MsgStop("Ocorreu erro no processamento do Json")
				Return Nil
			Else
				U_HFATUMUN(lAuto,lEnd,oProcess,cLogProc,nCount,oObjJson)
			EndIf			 
			
		Else
			oRest := NIL								
			FreeObj(oRest)

			oRest := FWRest():New(cProtocol2+cUrl) 
			oRest:SetPath(cPath)        

			If oRest:Get(aHeader) 
				If !FWJsonDeserialize(oRest:GetResult(), @oObjJson)
					MsgStop("Ocorreu erro no processamento do Json")
					Return Nil
				Else
					U_HFATUMUN(lAuto,lEnd,oProcess,cLogProc,nCount,oObjJson)
				EndIf		 
			Else
				Conout("Ocorreu um erro ao atualizar cidades")
			EndIf	
		EndIf	

		If !PutMv("XM_DATAMUN", dtos(dDataBase) ) 

			RecLock("SX6",.T.)
				SX6->X6_FIL     := xFilial("SX6")
				SX6->X6_VAR     := "XM_DATAMUN"
				SX6->X6_TIPO    := "C"
				SX6->X6_DESCRIC := "Data da Ultima Verificacao de atualizacao de municipio"
			MsUnLock()
			PutMv("XM_DATAMUN", dtos(dDataBase) ) 
		EndIf
	
	EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    HFATUMUN   บ Autor ณ Heverton Marcondes บ Data ณ 01/09/2020  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ HFATUMUN                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function HFATUMUN(lAuto,lEnd,oProcess,cLogProc,nCount,oJson)

Local nX 		:= 0
Local nQtd 		:= 0
Local nAtu		:= 0
Local cNovosMun	:= ""
Local cNomeMun	:= ""
Local cCfg		:= ""
//Local xZBZ  	:= GetNewPar("XM_TABXML" ,"ZBZ")
Local xZBM  	:= GetNewPar("XM_TABMUN" ,"ZBM")
//Local xZBN  	:= GetNewPar("XM_TABMUN2" ,"ZBN")
//Local xZBZ_ 	:= iif(Substr(xZBZ,1,1)=="S", Substr(xZBZ,2,2), Substr(xZBZ,1,3)) + "_"
Local xZBM_ 	:= iif(Substr(xZBM,1,1)=="S", Substr(xZBM,2,2), Substr(xZBM,1,3)) + "_"
//Local xZBN_ 	:= iif(Substr(xZBN,1,1)=="S", Substr(xZBN,2,2), Substr(xZBN,1,3)) + "_"
Local lObrTmInsc:= .F.
Local lObrTmCgc	:= .F.
Local lObrPrInsc:= .F.
Local lObrPrCgc	:= .F.

Private oXjson  := oJson

nQtd := len(oXjson:RESPOSTA)

Default oProcess := Nil

If !lAuto .Or. oProcess<>Nil      

	oProcess:SetRegua2(nQtd)

EndIf

DbSelectArea(xZBM)
DbSetOrder(1)

For nX := 1 to nQtd

	If oXjson:RESPOSTA[nX]:CONSULTARNOTASTOMADA

		cNomeMun 	:= Alltrim(Posicione("CC2",1,xFilial("CC2") + Right(oXjson:RESPOSTA[nX]:NOME,2) + Right(oXjson:RESPOSTA[nX]:CODIGOIBGE,5),"CC2_MUN"))

		cCfg		:= "Padrao: "+oXjson:RESPOSTA[nX]:PADRAO + CRLF
		cCfg		+= "Cominicacao: "+oXjson:RESPOSTA[nX]:TIPOCOMUNICACAO + CRLF
		cCfg		+= "Multiservicos: "+IIF(oXjson:RESPOSTA[nX]:MULTISERVICOS,"SIM","NAO") + CRLF
		cCfg		+= "Exige Certificado: "+IIF(oXjson:RESPOSTA[nX]:CERTIFICADO,"SIM","NAO") + CRLF
		cCfg		+= "Exige Login: "+IIF(oXjson:RESPOSTA[nX]:LOGIN,"SIM","NAO") + CRLF
		cCfg		+= "Exige Senha: "+IIF(oXjson:RESPOSTA[nX]:SENHA,"SIM","NAO") + CRLF

		if Type("oXjson:RESPOSTA["+cValtochar(nX)+"]:OBSERVACOESNOTASTOMADAS:DADOSOBRIGATORIOSTOMADOR") <> "U"

			xAux := oXjson:RESPOSTA[nX]:OBSERVACOESNOTASTOMADAS:DADOSOBRIGATORIOSTOMADOR

		else

			xAux := ""
			
		endif

		If !Empty( xAux )

			lObrTmInsc	:= "InscricaoMunicipal" $ oXjson:RESPOSTA[nX]:OBSERVACOESNOTASTOMADAS:DADOSOBRIGATORIOSTOMADOR 
			lObrTmCgc	:= "CpfCnpj" $ oXjson:RESPOSTA[nX]:OBSERVACOESNOTASTOMADAS:DADOSOBRIGATORIOSTOMADOR

		Else

			lObrTmInsc	:= .F.
			lObrTmCgc	:= .F.

		EndIf		

		if Type("oXjson:RESPOSTA["+cValtochar(nX)+"]:OBSERVACOESNOTASTOMADAS:DADOSOBRIGATORIOSPRESTADOR") <> "U"

			xAux := oXjson:RESPOSTA[nX]:OBSERVACOESNOTASTOMADAS:DADOSOBRIGATORIOSPRESTADOR

		else

			xAux := ""
			
		endif

		IF !Empty( xAux )

			lObrPrInsc	:= "InscricaoMunicipal" $ oXjson:RESPOSTA[nX]:OBSERVACOESNOTASTOMADAS:DADOSOBRIGATORIOSPRESTADOR 
			lObrPrCgc	:= "CpfCnpj" $ oXjson:RESPOSTA[nX]:OBSERVACOESNOTASTOMADAS:DADOSOBRIGATORIOSPRESTADOR

		Else

			lObrPrInsc	:= .F.
			lObrPrCgc	:= .F.

		EndIF

		If !lAuto .Or. oProcess<>Nil 
			oProcess:IncRegua2(cNomeMun)
		EndIf

		If !dbSeek(xFilial(xZBM)+oXjson:RESPOSTA[nX]:CODIGOIBGE)

			nAtu++

			RecLock(xZBM,.T.)
				(xZBM)->(FieldPut(FieldPos(xZBM_+"FILIAL"), xFilial(xZBM) ))
				(xZBM)->(FieldPut(FieldPos(xZBM_+"COD"), oXjson:RESPOSTA[nX]:CODIGOIBGE ))
				(xZBM)->(FieldPut(FieldPos(xZBM_+"MUNIC"), cNomeMun ))
				(xZBM)->(FieldPut(FieldPos(xZBM_+"ATIVO"), "2" ))
				(xZBM)->(FieldPut(FieldPos(xZBM_+"PREST"), IIF(oXjson:RESPOSTA[nX]:PRESTADOROBRIGATORIOTOMADAS,"1","2") ))
				(xZBM)->(FieldPut(FieldPos(xZBM_+"EST"), Right(oXjson:RESPOSTA[nX]:NOME,2) ))
				(xZBM)->(FieldPut(FieldPos(xZBM_+"CFG"), cCfg ))
				(xZBM)->(FieldPut(FieldPos(xZBM_+"JOB"), "2" ))
				(xZBM)->(FieldPut(FieldPos(xZBM_+"OBRTMI"), IIF(lObrTmInsc,"1","2") ))
				(xZBM)->(FieldPut(FieldPos(xZBM_+"OBRTMC"), IIF(lObrTmCgc,"1","2") ))
				(xZBM)->(FieldPut(FieldPos(xZBM_+"OBRPRI"), IIF(lObrPrInsc,"1","2") ))
				(xZBM)->(FieldPut(FieldPos(xZBM_+"OBRPRC"), IIF(lObrPrCgc,"1","2") ))

				cNovosMun += oXjson:RESPOSTA[nX]:CODIGOIBGE + " / " + Right(oXjson:RESPOSTA[nX]:NOME,2) + " / " + cNomeMun + CRLF
			msUnlock()		

		Else

			RecLock(xZBM,.F.)
				(xZBM)->(FieldPut(FieldPos(xZBM_+"FILIAL"), xFilial(xZBM) ))
				(xZBM)->(FieldPut(FieldPos(xZBM_+"COD"), oXjson:RESPOSTA[nX]:CODIGOIBGE ))
				(xZBM)->(FieldPut(FieldPos(xZBM_+"MUNIC"), cNomeMun ))
				(xZBM)->(FieldPut(FieldPos(xZBM_+"PREST"), IIF(oXjson:RESPOSTA[nX]:PRESTADOROBRIGATORIOTOMADAS,"1","2") ))
				(xZBM)->(FieldPut(FieldPos(xZBM_+"EST"), Right(oXjson:RESPOSTA[nX]:NOME,2) ))
				(xZBM)->(FieldPut(FieldPos(xZBM_+"CFG"), cCfg ))
				(xZBM)->(FieldPut(FieldPos(xZBM_+"OBRTMI"), IIF(lObrTmInsc,"1","2") ))
				(xZBM)->(FieldPut(FieldPos(xZBM_+"OBRTMC"), IIF(lObrTmCgc,"1","2") ))
				(xZBM)->(FieldPut(FieldPos(xZBM_+"OBRPRI"), IIF(lObrPrInsc,"1","2") ))
				(xZBM)->(FieldPut(FieldPos(xZBM_+"OBRPRC"), IIF(lObrPrCgc,"1","2") ))				
			msUnlock()		

		EndIf

	EndIf

Next nX

Conout("Total de Municipios homologados "+cValtoChar(nQtd) + CRLF;
		+"Municํpios incluํdos "+cValtoChar(nAtu) + CRLF;
		+"Novos Municํpios " + CRLF;
		+cNovosMun;
		)

Return


Static Function HfCaracterEspecial( cString )

Local cConteudo := cString

if !Empty(cConteudo)

	cConteudo := StrTran(cConteudo, CHAR(1), "")
	cConteudo := StrTran(cConteudo, CHAR(2), "")
	cConteudo := StrTran(cConteudo, CHAR(3), "")
	cConteudo := StrTran(cConteudo, CHAR(4), "")
	cConteudo := StrTran(cConteudo, CHAR(5), "")
	cConteudo := StrTran(cConteudo, CHAR(6), "")
	cConteudo := StrTran(cConteudo, CHAR(7), "")
	cConteudo := StrTran(cConteudo, CHAR(8), "")
	cConteudo := StrTran(cConteudo, CHAR(9), "")
	cConteudo := StrTran(cConteudo, CHAR(10), "")
	cConteudo := StrTran(cConteudo, CHAR(11), "")
	cConteudo := StrTran(cConteudo, CHAR(12), "")
	cConteudo := StrTran(cConteudo, CHAR(13), "")
	cConteudo := StrTran(cConteudo, CHAR(14), "")
	cConteudo := StrTran(cConteudo, CHAR(15), "")
	cConteudo := StrTran(cConteudo, CHAR(16), "")
	cConteudo := StrTran(cConteudo, CHAR(17), "")
	cConteudo := StrTran(cConteudo, CHAR(18), "")
	cConteudo := StrTran(cConteudo, CHAR(19), "")
	cConteudo := StrTran(cConteudo, CHAR(20), "")
	cConteudo := StrTran(cConteudo, CHAR(21), "")
	cConteudo := StrTran(cConteudo, CHAR(22), "")
	cConteudo := StrTran(cConteudo, CHAR(23), "")
	cConteudo := StrTran(cConteudo, CHAR(24), "")
	cConteudo := StrTran(cConteudo, CHAR(25), "")
	cConteudo := StrTran(cConteudo, CHAR(26), "")
	cConteudo := StrTran(cConteudo, CHAR(27), "")
	cConteudo := StrTran(cConteudo, CHAR(28), "")
	cConteudo := StrTran(cConteudo, CHAR(29), "")
	cConteudo := StrTran(cConteudo, CHAR(30), "")
	cConteudo := StrTran(cConteudo, CHAR(31), "")
	cConteudo := StrTran(cConteudo, CHAR(127), "")

endif

Return( cConteudo )


Static Function NoAcento2(cString)

Local cChar  := ""
Local nX     := 0 
Local nY     := 0
Local cVogal := "aeiouAEIOU"
Local cAgudo := "แ้ํ๓๚"+"มษอำฺ"
Local cCircu := "โ๊๎๔๛"+"ยสฮิÛ"
Local cTrema := "ไ๋๏๖ü"+"ฤหฯึÜ"
Local cCrase := "เ่์๒๙"+"ภศฬาู" 
Local cTio   := "ใ๕"
Local cCecid := "็ว"

For nX:= 1 To Len(cString)
	cChar:=SubStr(cString, nX, 1)
	IF cChar$cAgudo+cCircu+cTrema+cCecid+cTio+cCrase
		nY:= At(cChar,cAgudo)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cCircu)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cTrema)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cCrase)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf		
		nY:= At(cChar,cTio)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("ao",nY,1))
		EndIf		
		nY:= At(cChar,cCecid)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("cC",nY,1))
		EndIf
	Endif
Next

For nX:=1 To Len(cString)
	cChar:=SubStr(cString, nX, 1)
	If Asc(cChar) < 32 .Or. Asc(cChar) > 123
		cString:=StrTran(cString,cChar,".")
	Endif
Next nX

cString := _NoTags(cString)

Return cString

//Rotina para gravar os itens do importa xml
**********************************************************************
User Function fGrvZBTR(cXml,cChaveXml,cNF,cCnpjEmi)
**********************************************************************

Local aArea    := GetArea()
Local lInclui  := .T.

Private xZBZ  	  := GetNewPar("XM_TABXML","ZBZ")
Private xZBZ_ 	  := iif(Substr(xZBZ,1,1)=="S", Substr(xZBZ,2,2), Substr(xZBZ,1,3)) + "_"
Private xZB5  	  := GetNewPar("XM_TABAMAR","ZB5")
Private xZB5_ 	  := iif(Substr(xZB5,1,1)=="S", Substr(xZB5,2,2), Substr(xZB5,1,3)) + "_"
Private xZBS  	  := GetNewPar("XM_TABSINC","ZBS")
Private xZBS_ 	  := iif(Substr(xZBS,1,1)=="S", Substr(xZBS,2,2), Substr(xZBS,1,3)) + "_"
Private xZBE      := GetNewPar("XM_TABEVEN","ZBE")
Private xZBE_     := iif(Substr(xZBE,1,1)=="S", Substr(xZBE,2,2), Substr(xZBE,1,3)) + "_"
Private xZBT      := GetNewPar("XM_TABITEM","ZBT") 
Private xZBT_ 	  := iif(Substr(xZBT,1,1)=="S", Substr(xZBT,2,2), Substr(xZBT,1,3)) + "_"
Private xZBA  	  := GetNewPar("XM_TABAMA2","ZBA")
Private xZBA_ 	  := iif(Substr(xZBA,1,1)=="S", Substr(xZBA,2,2), Substr(xZBA,1,3)) + "_"
Private xZBC      := GetNewPar("XM_TABCAC","ZBC")
Private xZBC_     := iif(Substr(xZBC,1,1)=="S", Substr(xZBC,2,2), Substr(xZBC,1,3)) + "_"
Private xZBO      := GetNewPar("XM_TABOCOR","ZBO"), xRetSEF := ""
Private xZBO_     := iif(Substr(xZBO,1,1)=="S", Substr(xZBO,2,2), Substr(xZBO,1,3)) + "_"
Private xZBI      := GetNewPar("XM_TABIEXT","ZBI")
Private xZBI_     := iif(Substr(xZBI,1,1)=="S", Substr(xZBI,2,2), Substr(xZBI,1,3)) + "_"

Private cError		:= ""
Private cWarning	:= ""

DbSelectArea(xZBI)
Aadd(aArea, (xZBI)->(GetArea()) )

DbSelectArea(xZBO)
Aadd(aArea, (xZBO)->(GetArea()) )

DbSelectArea(xZBZ)
Aadd(aArea, (xZBZ)->(GetArea()) )

DbSelectArea(xZBT)
Aadd(aArea, (xZBT)->(GetArea()) )

DbSelectArea(xZB5)
Aadd(aArea, (xZB5)->(GetArea()) )

DbSelectArea(xZBE)
Aadd(aArea, (xZBE)->(GetArea()) )

DbSelectArea(xZBS)
Aadd(aArea, (xZBS)->(GetArea()) ) 
 
DbSelectArea(xZBA)
Aadd(aArea, (xZBA)->(GetArea()) ) 

DbSelectArea(xZBC)
Aadd(aArea, (xZBC)->(GetArea()) )

DbSelectArea( xZBT )
(xZBT)->( dbSetOrder(2) )		
If !(xZBT)->( dbSeek( cChaveXml ) )
	lInclui	:= .T.
Else
	lInclui := .F.
EndIf
	
oXml := XmlParser(cXml, "_", @cError, @cWarning )

If !lInclui

	DbSelectArea( xZBT )
	(xZBT)->(dbSetOrder(2))		
	(xZBT)->(dbSeek(cChaveXml))

	While (xZBT)->(!Eof()) .AND. AllTrim(&(xZBT_+"CHAVE")) == AllTrim(cChaveXml)

		If &(xZBT_+"ITEM") == "0001"
			lAchou := .T.
			Exit
		EndIf

		(xZBT)->(dbSkip())

	EndDo

	If !lAchou
		lInclui := .T.
	EndIf
EndIf

nValTot := val(oXml:_NFSETXT:_INFPROC:_VRSERV:TEXT)


If ( Type( "oXml:_NFSETXT:_INFPROC:_ALIQ:TEXT" ) <> 'U' )
	nAlqIss		:= val(oXml:_NFSETXT:_INFPROC:_ALIQ:TEXT) * 100
Else 
	nAlqIss		:= 0
EndIF

nValIss		:= nValTot * (nAlqIss/100)

If ( Type( "oXml:_NFSETXT:_INFPROC:_ALIQINSS:TEXT" ) <> 'U' )
	nValInss		:= val(oXml:_NFSETXT:_INFPROC:_ALIQINSS:TEXT) * 100
Else 
	nValInss		:= 0
EndIF


If ( Type( "oXml:_NFSETXT:_INFPROC:_ALIQPIS:TEXT" ) <> 'U' )
	nValPis		:= val(oXml:_NFSETXT:_INFPROC:_ALIQPIS:TEXT) * 100
Else 
	nValPis		:= 0
EndIF

If ( Type( "oXml:_NFSETXT:_INFPROC:_ALIQCOFINS:TEXT" ) <> 'U' )
	nValCof		:= val(oXml:_NFSETXT:_INFPROC:_ALIQCOFINS:TEXT) * 100
Else
	nValCof		:= 0
EndIF

If ( Type( "oXml:_NFSETXT:_INFPROC:_ALIQCSLL:TEXT" ) <> 'U' )
	nValCsll		:= val(oXml:_NFSETXT:_INFPROC:_ALIQCSLL:TEXT) * 100
Else 
	nValCsll		:= 0
EndIF

If ( Type( "oXml:_NFSETXT:_INFPROC:_ALIQIR:TEXT" ) <> 'U' )
	nValIrrf		:= val(oXml:_NFSETXT:_INFPROC:_ALIQIR:TEXT) * 100
Else 
	nValIrrf		:= 0
EndIF

Reclock(xZBT,lInclui)
	(xZBT)->(FieldPut(FieldPos(xZBT_+"CHAVE")  , cChaveXml	))
	(xZBT)->(FieldPut(FieldPos(xZBT_+"FILIAL") , cFilAnt 	))
	(xZBT)->(FieldPut(FieldPos(xZBT_+"ITEM")   , "0001"  	))
	(xZBT)->(FieldPut(FieldPos(xZBT_+"PRODUT") , oXml:_NFSETXT:_INFPROC:_PRODSRV:TEXT	))
	(xZBT)->(FieldPut(FieldPos(xZBT_+"DESCRI") , oXml:_NFSETXT:_INFPROC:_DESSRV:TEXT	))
	(xZBT)->(FieldPut(FieldPos(xZBT_+"QUANT")  , 1			))  
	(xZBT)->(FieldPut(FieldPos(xZBT_+"VUNIT")  , nValTot 	))	
	(xZBT)->(FieldPut(FieldPos(xZBT_+"TOTAL")  , nValTot 	))	
	(xZBT)->(FieldPut(FieldPos(xZBT_+"NOTA")   , cNF    	))
	//ISS
	(xZBT)->(FieldPut(FieldPos(xZBT_+"ISSALQ") , nAlqIss   	))
	(xZBT)->(FieldPut(FieldPos(xZBT_+"ISSVAL") , nValIss    ))
	//INSS
	//(xZBT)->(FieldPut(FieldPos(xZBT_+"INSALQ") , nAlqInss    ))
	(xZBT)->(FieldPut(FieldPos(xZBT_+"INSSVAL"), nValInss    ))
	//PIS
	//(xZBT)->(FieldPut(FieldPos(xZBT_+"PISALQ") , nAlqPis	))
	(xZBT)->(FieldPut(FieldPos(xZBT_+"PISVAL") , nValPis    ))
	//COFINS
	//(xZBT)->(FieldPut(FieldPos(xZBT_+"COFALQ") , nAlqCof	))
	(xZBT)->(FieldPut(FieldPos(xZBT_+"COFVAL") , nValCof    ))
	//CSLL
	//(xZBT)->(FieldPut(FieldPos(xZBT_+"CSLALQ") , nAlqCsll	))
	(xZBT)->(FieldPut(FieldPos(xZBT_+"CSLVAL") , nValCsll   ))
	//IRRF
	//(xZBT)->(FieldPut(FieldPos(xZBT_+"IRRALQ") , nAlqIrrf	))
	(xZBT)->(FieldPut(FieldPos(xZBT_+"IRRVAL") , nValIrrf   ))
DbSelectArea(xZBT)
MsUnLock()

//fim grava ZBT

Restarea( aArea )

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    HF068FOR   บ Autor ณ Heverton Marcondes บ Data ณ 10/05/2022  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ HF068FOR                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function HF068FOR()

Local aSize 	:= MsAdvSize()
Local aCabBrw 	:= {"","Cnpj Tomador","Inscri็ใo Tomador","Codigo","Loja","Nome","Cgc Prestador","Inscri็ใo Prestador"}
Local aDados 	:= Nil
Local oDlg
Local oTwBrw
Local nLinBot	:= 0
Local nTamBot	:= 0
Local nSpcBot	:= 0

Private aRotina 	:= {}

If ValType(_cFiltro) == "U"
	Static _cFiltro	:= ""
EndIf	

AADD(aRotina,{ "Pesquisa","AxPesqui" ,0,1})
AADD(aRotina,{ "Visual" ,"ManDados" ,0,2})
AADD(aRotina,{ "Inclui" ,"ManDados" ,0,3})
AADD(aRotina,{ "Altera" ,"ManDados" ,0,4})
AADD(aRotina,{ "Exclui" ,"ManDados" ,0,5})
           
aDados := RetNFSe()

If ValType(aDados) <> "U" 

	DEFINE MSDIALOG oDlg FROM 0,0 TO aSize[6],aSize[5] PIXEL TITLE "Fornecedores NFS-e"
			
		nLinBot := aSize[4]-20    
		nTamBot	:= (aSize[3]-45)/5     

		oTwBrw:= TWBrowse():New(0,0,aSize[3],aSize[4]-30,,aCabBrw,{30,80,80,50,50,150,80,80},oDlg, ,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
		oTwBrw:SetArray(aDados)             
			
		TButton():New(nLinBot,nSpcBot+=5,'Altera'						,oDlg,{|| oDlg:End(),ManDados(aDados[oTwBrw:nAt,4],aDados[oTwBrw:nAt,5],aDados[oTwBrw:nAt,6],aDados[oTwBrw:nAt,7],aDados[oTwBrw:nAt,8]),U_HF068FOR()},nTamBot,20,,,,.T.)
		TButton():New(nLinBot,nSpcBot+=nTamBot+5,'Considerar/Descons.'	,oDlg,{|| oDlg:End(),InfPrest(aDados[oTwBrw:nAt,4],aDados[oTwBrw:nAt,5]),U_HF068FOR()	},nTamBot,20,,,,.T.)
		TButton():New(nLinBot,nSpcBot+=nTamBot+5,'Filtrar'				,oDlg,{|| oDlg:End(),Filtra(),U_HF068FOR()												},nTamBot,20,,,,.T.)
		TButton():New(nLinBot,nSpcBot+=nTamBot+5,'Legenda'				,oDlg,{|| LegNFSe()																		},nTamBot,20,,,,.T.)
		TButton():New(nLinBot,nSpcBot+=nTamBot+5,'Sair'					,oDlg,{|| oDlg:End()																	},nTamBot,20,,,,.T.)
			
		oTwBrw:bLine := {||{ aDados[oTwBrw:nAt,1],;
			aDados[oTwBrw:nAt,2],;
			aDados[oTwBrw:nAt,3],;
			aDados[oTwBrw:nAt,4],;
			aDados[oTwBrw:nAt,5],;
			aDados[oTwBrw:nAt,6],;
			aDados[oTwBrw:nAt,7],;
			aDados[oTwBrw:nAt,8];
		}}             
						
	ACTIVATE MSDIALOG oDlg CENTERED  

EndIF

Return                                                       

//////////////////////////
//Monta Array para tela //
//////////////////////////

Static Function RetNFSe()
	
Local aDados := {}
Local oVerd 	:= LoadBitmap(GetResources(),'br_verde')
Local oVerm 	:= LoadBitmap(GetResources(),'br_vermelho')      
Local oAzul 	:= LoadBitmap(GetResources(),'br_azul')             
Local oLeg		
Local cCodIbge 	:= ""
Local nUf		:= 0
Local cUf		:= ""
Local cQuery	:= ""
Local cAliasSA2 := GetNextAlias()
Local lObrTmInsc:= .F.
Local lObrTmCgc	:= .F.
Local lObrPrInsc:= .F.
Local lObrPrCgc	:= .F.
Local aUF     	:= {}

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

cCodIbge	:= (xZBM)->(FieldGet(FieldPos(xZBM_+"COD")))
cCnpj		:= Alltrim(FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , { "M0_CGC" } )[1][2])
cInscr		:= Alltrim(FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , { "M0_INSCM" } )[1][2])

lObrTmInsc	:= (xZBM)->(FieldGet(FieldPos(xZBM_+"OBRTMI"))) == "1"
lObrTmCgc	:= (xZBM)->(FieldGet(FieldPos(xZBM_+"OBRTMC"))) == "1"
lObrPrInsc	:= (xZBM)->(FieldGet(FieldPos(xZBM_+"OBRPRI"))) == "1"
lObrPrCgc	:= (xZBM)->(FieldGet(FieldPos(xZBM_+"OBRPRC"))) == "1"

nUf	:= aScan(aUF,{|x| x[2] == substr(cCodIbge,1,2)})
cUf := aUF[nUf][1]

cQuery := ""
cQuery += " Select A2_COD, A2_LOJA, A2_NOME, A2_CGC, A2_INSCRM, A2_XHFPRES FROM "+RetSqlName("SA2")+" "
cQuery += " Where A2_FILIAL = '"+xFilial( "SA2" )+"' "
cQuery += " And A2_EST = '"+cUf+"' "
cQuery += " And A2_COD_MUN = '"+substr(cCodIbge,3,5)+"' "
cQuery += " And D_E_L_E_T_ = ' ' "
cQuery += _cFiltro

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSA2)

DbSelectArea( cAliasSA2 )
(cAliasSA2)->( dbGoTop() )

If (cAliasSA2)->( Eof() )
	Return({{"","","","","","","",""}})
EndIf

Do While .NOT. (cAliasSA2)->( Eof() )

	Do Case 
		Case (cAliasSA2)->A2_XHFPRES == "2"
			oLeg := oAzul
		Case lObrTmInsc .And. Empty(cInscr)
			oLeg := oVerm      
		Case lObrTmCgc .And. Empty(cCnpj)
			oLeg := oVerm  
		Case lObrPrInsc .And. Empty((cAliasSA2)->A2_CGC)
			oLeg := oVerm  
		Case lObrPrCgc .And. Empty((cAliasSA2)->A2_INSCRM)
			oLeg := oVerm
		OtherWise
			oLeg := oVerd 
	EndCase

   	aAdd(aDados,{oLeg,cCnpj,cInscr,(cAliasSA2)->A2_COD,(cAliasSA2)->A2_LOJA,(cAliasSA2)->A2_NOME,(cAliasSA2)->A2_CGC,(cAliasSA2)->A2_INSCRM})

	(cAliasSA2)->( dbSkip() )

EndDo
	
Return aDados 

///////////////////////////
// Manipula็ใo dos dados //
///////////////////////////

Static Function ManDados(cCod,cLoja,cNome,cCnpj,cIncricao)

	Local aArea := GetArea()
	Local nRet	:= 0
	
	Private cInscr	:= cIncricao

    DEFINE DIALOG oDlg TITLE "Altera็ใo Fornecedor" FROM 0,0 TO 250,640 PIXEL

  		oFont := TFont():New('Courier new',,-18,.T.)
  
  		oSCod	:= TSay():New(002,005,{||'C๓digo'}				,oDlg,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,050,10)
		oSLoja	:= TSay():New(002,080,{||'Loja'}				,oDlg,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,030,10)
		oSNome	:= TSay():New(002,150,{||'Nome'}				,oDlg,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,150,10)
		oSCnpj	:= TSay():New(030,005,{||'CNPJ'}				,oDlg,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,050,10)
		oSInscr	:= TSay():New(030,080,{||'Incri็ใo Municipal'}	,oDlg,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,050,10)

		oCod 	:= TGet():New( 014,005,{||cCod								},oDlg,050,010, "@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,"cCod"	,,,, )
		oLoja 	:= TGet():New( 014,080,{||cLoja								},oDlg,030,010, "@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,"cLoja"	,,,, )
		oNome 	:= TGet():New( 014,150,{||cNome								},oDlg,150,010, "@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,"cNome"	,,,, )
		oCnpj 	:= TGet():New( 042,005,{||cCnpj								},oDlg,050,010, "@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,"cCnpj"	,,,, )
		oInscr 	:= TGet():New( 042,080,{|u| if(PCount()>0,cInscr:=u,cInscr)	},oDlg,050,010, "@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"cInscr"	,,,, )				
	 	
		oButOk:=tButton():New(080,080,'Salvar'	,oDlg,{||oDlg:End(),nRet := 1},050,20,,,,.T.) 
 		oButCa:=tButton():New(080,150,'Cancelar',oDlg,{||oDlg:End(),nRet := 0},050,20,,,,.T.) 
    
	ACTIVATE DIALOG oDlg CENTERED

	If nRet == 1
		dbSelectArea("SA2")
		SA2->(dbSetOrder(1))
		SA2->(dbGoTop())

		If SA2->(dbSeek(xFilial("SA2")+cCod+cLoja))
			RecLock("SA2",.F.)
				SA2->A2_INSCRM := cInscr
			SA2->(msUnlock())
		EndIf
	Else
		msgInfo("Cancelado pelo operador")
	EndIf

	RestArea(aArea)

Return

Static Function InfPrest(cCod,cLoja)

	Local aArea := GetArea()
	Local cInf	:= ""
	
	dbSelectArea("SA2")
	SA2->(dbSetOrder(1))
	SA2->(dbGoTop())

	If SA2->(dbSeek(xFilial("SA2")+cCod+cLoja))
		If Empty(SA2->A2_XHFPREST) .Or. SA2->A2_XHFPREST == "1"
			cInf := "2"
		Else
			cInf := "1"
		EndIf		 

		RecLock("SA2",.F.)
			SA2->A2_XHFPREST := cInf
		SA2->(msUnlock())
	EndIf

	RestArea(aArea)

Return

Static Function Filtra()

	Local aArea := GetArea()
	Local nRet	:= 0
	
	Local cCod	:= Space(TamSx3("A2_COD")[1])
	Local cLoja	:= Space(TamSx3("A2_LOJA")[1])
	Local cNome	:= Space(TamSx3("A2_NOME")[1])
	Local cCnpj	:= Space(TamSx3("A2_CGC")[1])
	Local cInscr:= Space(TamSx3("A2_INSCRM")[1])

    DEFINE DIALOG oDlg TITLE "Filtrar Fornecedores" FROM 0,0 TO 250,640 PIXEL

  		oFont := TFont():New('Courier new',,-18,.T.)
  
  		oSCod	:= TSay():New(002,005,{||'C๓digo'}				,oDlg,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,050,10)
		oSLoja	:= TSay():New(002,080,{||'Loja'}				,oDlg,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,030,10)
		oSNome	:= TSay():New(002,150,{||'Nome'}				,oDlg,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,150,10)
		oSCnpj	:= TSay():New(030,005,{||'CNPJ'}				,oDlg,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,050,10)
		oSInscr	:= TSay():New(030,080,{||'Incri็ใo Municipal'}	,oDlg,,oFont,,,,.T.,CLR_BLACK,CLR_WHITE,050,10)

		oCod 	:= TGet():New( 014,005,{|u| if(PCount()>0,cCod:=u,cCod)		},oDlg,050,010, "@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"cCod"	,,,, )
		oLoja 	:= TGet():New( 014,080,{|u| if(PCount()>0,cLoja:=u,cLoja)	},oDlg,030,010, "@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"cLoja"	,,,, )
		oNome 	:= TGet():New( 014,150,{|u| if(PCount()>0,cNome:=u,cNome)	},oDlg,150,010, "@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"cNome"	,,,, )
		oCnpj 	:= TGet():New( 042,005,{|u| if(PCount()>0,cCnpj:=u,cCnpj)	},oDlg,050,010, "@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"cCnpj"	,,,, )
		oInscr 	:= TGet():New( 042,080,{|u| if(PCount()>0,cInscr:=u,cInscr)	},oDlg,050,010, "@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"cInscr"	,,,, )				
	 	
		oButOk:=tButton():New(080,080,'Filtrar'	,oDlg,{||oDlg:End(),nRet := 1},050,20,,,,.T.) 
 		oButCa:=tButton():New(080,150,'Cancelar',oDlg,{||oDlg:End(),nRet := 0},050,20,,,,.T.) 
    
	ACTIVATE DIALOG oDlg CENTERED

	_cFiltro := ""

	If nRet == 1
		If !Empty(cCod)
			_cFiltro += " And A2_COD LIKE '%"+alltrim(cCod)+"%'" 
		EndIf
		If !Empty(cLoja)
			_cFiltro += " And A2_LOJA LIKE '%"+alltrim(cLoja)+"%'" 
		EndIf
		If !Empty(cNome)
			_cFiltro += " And A2_NOME LIKE '%"+alltrim(cNome)+"%'" 
		EndIf
		If !Empty(cCnpj)
			_cFiltro += " And A2_CGC LIKE '%"+alltrim(cCnpj)+"%'" 
		EndIf
		If !Empty(cInscr)
			_cFiltro += " And A2_INSCRM LIKE '%"+alltrim(cInscr)+"%'" 
		EndIf						
	Else
		_cFiltro := ""
	EndIf

	RestArea(aArea)

Return

//////////////////////////
//Legendas				//
//////////////////////////

Static Function LegNFSe()
	
Local aLegenda := {}

aAdd(aLegenda,{"BR_VERDE","Ok"})
aAdd(aLegenda,{"BR_VERMELHO","Falta Informa็ใo"})
aAdd(aLegenda,{"BR_AZUL","Desconsiderados"})

BrwLegenda("Nfs-e","Legendas",aLegenda)

Return               
//////////////////////////
//Notas do dia atual	//
//////////////////////////

User Function HF068DIA(lAuto,lEnd,oProcess,cLogProc,nCount)

    Local oRest 	:= Nil 
    Local aHeader 	:= {} 
    Local oObjJson  := Nil
	Local cBody		:= ""
	Local cData		:= ""
	Local cLink		:= ""
	Local dData30	:= dDataBase-31
	Local cData30	:= ""
	Local dData		:= dDataBase-1
	Local cAliasSA2 := GetNextAlias()
	Local cQuery   	:= " "
	Local cDataIni	:= ""
	Local nN		:= 0

	//Verifica dados no SIGAMAT, inscri็ใo municipal nใo obrigat๓ria, monitorar pq jah deu problema passando inscri็ใo HMS
	cCnpj 	:= Alltrim(FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , { "M0_CGC" } )[1][2])
	cInscr	:= Alltrim(FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , { "M0_INSCM" } )[1][2])
	//cInscr	:= ""

	Aadd(aHeader, "Content-Type: application/json")                      
	Aadd(aHeader, "token_sh: 8362a6f9f284692afa0d191b34a0cbdd")                      
	Aadd(aHeader, "cpfCnpjSoftwareHouse: 07084316000158")                      
	Aadd(aHeader, "cpfCnpjTomador: "+cCnpj)   
	Aadd(aHeader, "Connection: keep-alive")   

	//Pega a data limite inicial
	cData30 := substr(dtos(dDataBase),1,4)+"-"
	cData30 += substr(dtos(dDataBase),5,2)+"-"
	cData30 += substr(dtos(dDataBase),7,2)

	//Pega a data limite final
	cData := substr(dtos(dDataBase),1,4)+"-"
	cData += substr(dtos(dDataBase),5,2)+"-"
	cData += substr(dtos(dDataBase),7,2)
							
	cLogProc += "Municํpio "+ alltrim((xZBM)->(FieldGet(FieldPos(xZBM_+"MUNIC")))) + " consultando do dia " + cData + chr(13)+chr(10)							

	If (xZBM)->(FieldGet(FieldPos(xZBM_+"PREST"))) == "1" //Se necessita de prestador, varre a SA2 para fazer uma consulta pra cada CNPJ prestador

		nUf	:= aScan(aUF,{|x| x[2] == substr((xZBM)->(FieldGet(FieldPos(xZBM_+"COD"))),1,2)})
		cUf := aUF[nUf][1]

		cQuery := ""
		cQuery += " Select A2_COD, A2_LOJA, A2_CGC, A2_INSCRM FROM "+RetSqlName("SA2")+" "
		cQuery += " Where A2_FILIAL = '"+xFilial( "SA2" )+"' "
		cQuery += " And A2_EST = '"+cUf+"' "
		cQuery += " And A2_COD_MUN = '"+substr((xZBM)->(FieldGet(FieldPos(xZBM_+"COD"))),3,5)+"' "
		cQuery += " And A2_XHFPRES <> '2' "
		cQuery += " And D_E_L_E_T_ = ' ' "

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSA2)

		DbSelectArea( cAliasSA2 )
		(cAliasSA2)->( dbGoTop() )
		
		If (cAliasSA2)->( Eof() )

			RecLock(xZBN,.T.)
				(xZBN)->(FieldPut(FieldPos(xZBN_+"FILIAL"), xFilial(xZBN) ))
				(xZBN)->(FieldPut(FieldPos(xZBN_+"COD"), (xZBM)->(FieldGet(FieldPos(xZBM_+"COD"))) ))
				//(xZBM)->(FieldPut(FieldPos(xZBM_+"DATA"), dData ))
				(xZBN)->(FieldPut(FieldPos(xZBN_+"DATA"), dData ))		//FR - 24/11/2020
				(xZBN)->(FieldPut(FieldPos(xZBN_+"STATUS"), "ERRO" ))
				(xZBN)->(FieldPut(FieldPos(xZBN_+"MSG"), "Nใo existe nenhum fornecedor cadastrado para esse municํpio " + Time() ))
			(xZBN)->(MsUnlock())
		
		EndIf

		Do While .NOT. (cAliasSA2)->( Eof() )

			If !lAuto .Or. oProcess<>Nil      
				oProcess:IncRegua2(alltrim((xZBM)->(FieldGet(FieldPos(xZBM_+"MUNIC"))))+ " Fornecedor " + (cAliasSA2)->A2_CGC)      
			EndIf

			oRest 	:= FWRest():New(cProtocol1+cUrl) //Tenta HTTP

			oRest:SetPath("/v1/tomadas")  
			
			cBody := 	'{' + CRLF
			cBody += 		'"codigoCidade": "'+ alltrim((xZBM)->(FieldGet(FieldPos(xZBM_+"COD")))) + '", ' + CRLF
			cBody +=		'"prestador": {' + CRLF
			cBody +=   			'"cpfCnpj": "'+alltrim((cAliasSA2)->A2_CGC)+'",' + CRLF
			cBody +=    		'"inscricaoMunicipal": "'+alltrim((cAliasSA2)->A2_INSCRM)+'"' + CRLF
			cBody +=  		'},' + CRLF						
			cBody += 		'"destinatario": {' + CRLF
			cBody += 			'"cpfCnpj": "'+ alltrim(cCNPJ) + '",' + CRLF
			cBody += 			'"inscricaoMunicipal": "'+ alltrim(cInscr) + '",' + CRLF
			cBody +=   			'"autenticacao":{' + CRLF
			cBody +=				'"login":"'+alltrim((xZBM)->(FieldGet(FieldPos(xZBM_+"USER"))))+'",' + CRLF
			cBody +=				'"senha":"'+alltrim((xZBM)->(FieldGet(FieldPos(xZBM_+"PSW"))))+'"' + CRLF
			cBody +=			'}' + CRLF
			cBody +=		'},' + CRLF
			cBody += 		'"periodo": {' + CRLF		
			
			cBody += 			'"inicial": "'+ cDataIni + '", ' + CRLF

			cBody += 			'"final": "'+ cDataIni + '" ' + CRLF
			cBody +=		'}' + CRLF	
			cBody +=	'}' + CRLF

			oRest:SetPostParams(cBody)

			If oRest:Post(aHeader) 
				If !FWJsonDeserialize(oRest:GetResult(), @oObjJson)
					MsgStop("Ocorreu erro no processamento do Json")
					Return Nil
				EndIf			 

				cLink := "/v1/tomadas/"+ oObjJson:RESPOSTA:PROTOCOLO 

				RecLock(xZBM,.F.)
					(xZBM)->(FieldPut(FieldPos(xZBM_+"STATUS"), "PROCESSANDO" ))
				(xZBM)->(MsUnlock())

				RecLock(xZBN,.T.)
					(xZBN)->(FieldPut(FieldPos(xZBN_+"FILIAL"), xFilial(xZBN) ))
					(xZBN)->(FieldPut(FieldPos(xZBN_+"COD"), (xZBM)->(FieldGet(FieldPos(xZBM_+"COD"))) ))
					(xZBN)->(FieldPut(FieldPos(xZBN_+"DATA"), dData ))
					(xZBN)->(FieldPut(FieldPos(xZBN_+"FORNEC"), (cAliasSA2)->A2_COD ))
					(xZBN)->(FieldPut(FieldPos(xZBN_+"LOJFOR"), (cAliasSA2)->A2_LOJA ))
					(xZBN)->(FieldPut(FieldPos(xZBN_+"STATUS"), "PROCESSANDO" ))
					(xZBN)->(FieldPut(FieldPos(xZBN_+"LINK"), cLink ))
					cReq := cProtocol1+cUrl+CRLF
					cReq += CRLF

					cReq += "HEADER" + CRLF
					cReq += CRLF

					For nN := 1 to Len(aHeader)
						cReq += aHeader[nN] + CRLF
					Next nN

					cReq += CRLF + CRLF
					cReq += "BODY" + CRLF
					cReq += CRLF
					cReq += cBody
					
					(xZBN)->(FieldPut(FieldPos(xZBN_+"REQ"), cReq ))
				(xZBN)->(MsUnlock())

			Else

				oRest := NIL								
				FreeObj(oRest)

				oRest 	:= FWRest():New(cProtocol2+cUrl) //Tenta HTTPS

				oRest:SetPath("/v1/tomadas")  
				
				cBody := 	'{' + CRLF
				cBody += 		'"codigoCidade": "'+ alltrim((xZBM)->(FieldGet(FieldPos(xZBM_+"COD")))) + '", ' + CRLF
				cBody +=		'"prestador": {' + CRLF
				cBody +=   			'"cpfCnpj": "'+alltrim((cAliasSA2)->A2_CGC)+'",' + CRLF
				cBody +=    		'"inscricaoMunicipal": "'+alltrim((cAliasSA2)->A2_INSCRM)+'"'	 + CRLF
				cBody +=  		'},'						 + CRLF
				cBody += 		'"destinatario": {' + CRLF
				cBody += 			'"cpfCnpj": "'+ alltrim(cCNPJ) + '",' + CRLF
				cBody += 			'"inscricaoMunicipal": "'+ alltrim(cInscr) + '",' + CRLF
				cBody +=   			'"autenticacao":{' + CRLF
				cBody +=				'"login":"'+alltrim((xZBM)->(FieldGet(FieldPos(xZBM_+"USER"))))+'",' + CRLF
				cBody +=				'"senha":"'+alltrim((xZBM)->(FieldGet(FieldPos(xZBM_+"PSW"))))+'"' + CRLF
				cBody +=			'}' + CRLF
				cBody +=		'},' + CRLF
				cBody += 		'"periodo": {'		 + CRLF
				cBody += 			'"inicial": "'+ cDataIni + '", ' + CRLF
				cBody += 			'"final": "'+ cDataIni + '" ' + CRLF
				cBody +=		'}'	 + CRLF
				cBody +=	'}' + CRLF

				oRest:SetPostParams(cBody)

				If oRest:Post(aHeader) 
					If !FWJsonDeserialize(oRest:GetResult(), @oObjJson)
						MsgStop("Ocorreu erro no processamento do Json")
						Return Nil
					EndIf			 

					cLink := "/v1/tomadas/"+ oObjJson:RESPOSTA:PROTOCOLO 

					RecLock(xZBM,.F.)
						(xZBM)->(FieldPut(FieldPos(xZBM_+"STATUS"), "PROCESSANDO" ))
					(xZBM)->(MsUnlock())

					RecLock(xZBN,.T.)
						(xZBN)->(FieldPut(FieldPos(xZBN_+"FILIAL"), xFilial(xZBN) ))
						(xZBN)->(FieldPut(FieldPos(xZBN_+"COD"), (xZBM)->(FieldGet(FieldPos(xZBM_+"COD"))) ))
						(xZBN)->(FieldPut(FieldPos(xZBN_+"FORNEC"), (cAliasSA2)->A2_COD ))
						(xZBN)->(FieldPut(FieldPos(xZBN_+"LOJFOR"), (cAliasSA2)->A2_LOJA ))
						(xZBN)->(FieldPut(FieldPos(xZBN_+"STATUS"), "PROCESSANDO" ))
						(xZBN)->(FieldPut(FieldPos(xZBN_+"LINK"), cLink ))
						cReq := cProtocol2+cUrl+CRLF
						cReq += CRLF

						cReq += "HEADER" + CRLF
						cReq += CRLF

						For nN := 1 to Len(aHeader)
							cReq += aHeader[nN] + CRLF
						Next nN

						cReq += CRLF + CRLF
						cReq += "BODY" + CRLF
						cReq += CRLF
						cReq += cBody
						
						(xZBN)->(FieldPut(FieldPos(xZBN_+"REQ"), cReq ))
					(xZBN)->(MsUnlock())

				Else

					RecLock(xZBM,.F.)
						(xZBM)->(FieldPut(FieldPos(xZBM_+"STATUS"), "ERRO" ))
					(xZBM)->(MsUnlock())

					RecLock(xZBN,.T.)
						(xZBN)->(FieldPut(FieldPos(xZBN_+"FILIAL"), xFilial(xZBN) ))
						(xZBN)->(FieldPut(FieldPos(xZBN_+"COD"), (xZBM)->(FieldGet(FieldPos(xZBM_+"COD"))) ))
						(xZBN)->(FieldPut(FieldPos(xZBN_+"DATA"), dData ))
						(xZBN)->(FieldPut(FieldPos(xZBN_+"STATUS"), "ERRO" ))
						If ( ValType( "oRest:CRESULT" ) <> 'U' )
							(xZBN)->(FieldPut(FieldPos(xZBN_+"MSG"), DecodeUtf8(oRest:CRESULT) + Time() ))
						Else 
							(xZBN)->(FieldPut(FieldPos(xZBN_+"MSG"), DecodeUtf8(oRest:CINTERNALERROR) + Time() ))
						EndIF
						cReq := cProtocol2+cUrl+CRLF
						cReq += CRLF

						cReq += "HEADER" + CRLF
						cReq += CRLF

						For nN := 1 to Len(aHeader)
							cReq += aHeader[nN] + CRLF
						Next nN

						cReq += CRLF + CRLF
						cReq += "BODY" + CRLF
						cReq += CRLF
						cReq += cBody
						
						(xZBN)->(FieldPut(FieldPos(xZBN_+"REQ"), cReq ))
					(xZBN)->(MsUnlock())
					cLogProc += "Municํpio "+ alltrim((xZBM)->(FieldGet(FieldPos(xZBM_+"MUNIC")))) + " com ERRO verifique monitor" + chr(13)+chr(10)						

				EndIf
			EndIf  

			(cAliasSA2)->( dbSkip() )

		EndDo

		(cAliasSA2)->(dbCloseArea())

	Else //Se nใo necessita prestador, faz uma consulta s๓
		
		If !lAuto .Or. oProcess<>Nil      
			oProcess:IncRegua2(alltrim((xZBM)->(FieldGet(FieldPos(xZBM_+"MUNIC")))))      
		EndIf

		oRest 	:= FWRest():New(cProtocol1+cUrl) //Tenta HTTP
		oRest:SetPath("/v1/tomadas")        
		
		cBody := 	'{' + CRLF
		cBody += 		'"codigoCidade": "'+ alltrim((xZBM)->(FieldGet(FieldPos(xZBM_+"COD")))) + '", ' + CRLF
		cBody += 		'"destinatario": {' + CRLF
		cBody += 			'"cpfCnpj": "'+ alltrim(cCNPJ) + '",' + CRLF
		cBody += 			'"inscricaoMunicipal": "'+ IIF((xZBM)->(FieldGet(FieldPos(xZBM_+"COD"))) <> "3550308",alltrim(cInscr),"") + '",' + CRLF //Erro tecnospeed - tratado no c๓digo por enquanto
		cBody +=   			'"autenticacao":{' + CRLF
		cBody +=				'"login":"'+alltrim( (xZBM)->(FieldGet(FieldPos(xZBM_+"USER"))) )+'",' + CRLF
		cBody +=				'"senha":"'+alltrim( (xZBM)->(FieldGet(FieldPos(xZBM_+"PSW"))) )+'"' + CRLF
		cBody +=			'}' + CRLF
		cBody +=		'},' + CRLF
		cBody += 		'"periodo": {'		 + CRLF
		cBody += 			'"inicial": "'+ cDataIni + '", ' + CRLF
		cBody += 			'"final": "'+ cDataIni + '" ' + CRLF
		cBody +=		'}'	 + CRLF
		cBody +=	'}' + CRLF

		oRest:SetPostParams(cBody)

		If oRest:Post(aHeader) 
			If !FWJsonDeserialize(oRest:GetResult(), @oObjJson)
				MsgStop("Ocorreu erro no processamento do Json")
				Return Nil
			EndIf			 

			cLink := "/v1/tomadas/"+ oObjJson:RESPOSTA:PROTOCOLO 

			RecLock(xZBM,.F.)
				(xZBM)->(FieldPut(FieldPos(xZBM_+"STATUS"), "PROCESSANDO" ))
			(xZBM)->(MsUnlock())

			RecLock(xZBN,.T.)
				(xZBN)->(FieldPut(FieldPos(xZBN_+"FILIAL"), xFilial(xZBN) ))
				(xZBN)->(FieldPut(FieldPos(xZBN_+"COD"), (xZBM)->(FieldGet(FieldPos(xZBM_+"COD"))) ))
				(xZBN)->(FieldPut(FieldPos(xZBN_+"DATA"), dData ))
				(xZBN)->(FieldPut(FieldPos(xZBN_+"STATUS"), "PROCESSANDO" ))
				(xZBN)->(FieldPut(FieldPos(xZBN_+"LINK"), cLink ))
				cReq := cProtocol1+cUrl+CRLF
				cReq += CRLF

				cReq += "HEADER" + CRLF
				cReq += CRLF

				For nN := 1 to Len(aHeader)
					cReq += aHeader[nN] + CRLF
				Next nN

				cReq += CRLF + CRLF
				cReq += "BODY" + CRLF
				cReq += CRLF
				cReq += cBody
				
				(xZBN)->(FieldPut(FieldPos(xZBN_+"REQ"), cReq ))
			(xZBN)->(MsUnlock())


		Else
			oRest := NIL								
			FreeObj(oRest)

			oRest 	:= FWRest():New(cProtocol2+cUrl) //Tenta HTTPS

			oRest:SetPath("/v1/tomadas")        
			
			cBody := 	'{'  + CRLF
			cBody += 		'"codigoCidade": "'+ alltrim((xZBM)->(FieldGet(FieldPos(xZBM_+"COD")))) + '", ' + CRLF
			cBody += 		'"destinatario": {' + CRLF
			cBody += 			'"cpfCnpj": "'+ alltrim(cCNPJ) + '",' + CRLF
			cBody += 			'"inscricaoMunicipal": "'+ IIF((xZBM)->(FieldGet(FieldPos(xZBM_+"COD"))) <> "3550308",alltrim(cInscr),"") + '",' + CRLF
			cBody +=   			'"autenticacao":{' + CRLF
			cBody +=				'"login":"'+alltrim( (xZBM)->(FieldGet(FieldPos(xZBM_+"USER"))) )+'",' + CRLF
			cBody +=				'"senha":"'+alltrim( (xZBM)->(FieldGet(FieldPos(xZBM_+"PSW"))) )+'"' + CRLF
			cBody +=			'}' + CRLF
			cBody +=		'},' + CRLF
			cBody += 		'"periodo": {'		 + CRLF
			cBody += 			'"inicial": "'+ cDataIni + '", ' + CRLF
			cBody += 			'"final": "'+ cDataIni + '" ' + CRLF
			cBody +=		'}'	 + CRLF
			cBody +=	'}' + CRLF

			oRest:SetPostParams(cBody)

			If oRest:Post(aHeader) 
				If !FWJsonDeserialize(oRest:GetResult(), @oObjJson)
					MsgStop("Ocorreu erro no processamento do Json")
					Return Nil
				EndIf			 

				cLink := "/v1/tomadas/"+ oObjJson:RESPOSTA:PROTOCOLO 

				RecLock(xZBM,.F.)
					(xZBM)->(FieldPut(FieldPos(xZBM_+"STATUS"), "PROCESSANDO" ))
				(xZBM)->(MsUnlock())

				RecLock(xZBN,.T.)
					(xZBN)->(FieldPut(FieldPos(xZBN_+"FILIAL"), xFilial(xZBN) ))
					(xZBN)->(FieldPut(FieldPos(xZBN_+"COD"), (xZBM)->(FieldGet(FieldPos(xZBM_+"COD"))) ))
					(xZBN)->(FieldPut(FieldPos(xZBN_+"DATA"), dData ))
					(xZBN)->(FieldPut(FieldPos(xZBN_+"STATUS"), "PROCESSANDO" ))
					(xZBN)->(FieldPut(FieldPos(xZBN_+"LINK"), cLink ))
					cReq := cProtocol2+cUrl+CRLF
					cReq += CRLF

					cReq += "HEADER" + CRLF
					cReq += CRLF

					For nN := 1 to Len(aHeader)
						cReq += aHeader[nN] + CRLF
					Next nN

					cReq += CRLF + CRLF
					cReq += "BODY" + CRLF
					cReq += CRLF
					cReq += cBody
					
					(xZBN)->(FieldPut(FieldPos(xZBN_+"REQ"), cReq ))
				(xZBN)->(MsUnlock())

			Else

				RecLock(xZBM,.F.)
					(xZBM)->(FieldPut(FieldPos(xZBM_+"STATUS"), "ERRO" ))
					//(xZBM)->(FieldPut(FieldPos(xZBM_+"DATA"), dData ))
				(xZBM)->(MsUnlock())

				RecLock(xZBN,.T.)
					(xZBN)->(FieldPut(FieldPos(xZBN_+"FILIAL"), xFilial(xZBN) ))
					(xZBN)->(FieldPut(FieldPos(xZBN_+"COD"), (xZBM)->(FieldGet(FieldPos(xZBM_+"COD"))) ))
					(xZBN)->(FieldPut(FieldPos(xZBN_+"DATA"), dData ))
					(xZBN)->(FieldPut(FieldPos(xZBN_+"STATUS"), "ERRO" ))
					If ( ValType( "oRest:CRESULT" ) <> 'U' )
						(xZBN)->(FieldPut(FieldPos(xZBN_+"MSG"), DecodeUtf8(oRest:CRESULT) + Time()))
					Else 
						(xZBN)->(FieldPut(FieldPos(xZBN_+"MSG"), DecodeUtf8(oRest:CINTERNALERROR) + Time() ))
					EndIF
					cReq := cProtocol2+cUrl+CRLF
					cReq += CRLF

					cReq += "HEADER" + CRLF
					cReq += CRLF

					For nN := 1 to Len(aHeader)
						cReq += aHeader[nN] + CRLF
					Next nN

					cReq += CRLF + CRLF
					cReq += "BODY" + CRLF
					cReq += CRLF
					cReq += cBody
					
					(xZBN)->(FieldPut(FieldPos(xZBN_+"REQ"), cReq ))
				(xZBN)->(MsUnlock())
				cLogProc += "Municํpio "+ alltrim((xZBM)->(FieldGet(FieldPos(xZBM_+"MUNIC")))) + " com ERRO verifique monitor" + chr(13)+chr(10)						

			EndIf  
		EndIf 
	EndIf

Return

//////////////////////////
//Notas do dia atual	//
//////////////////////////

User Function HF068NVC()

Local aParamBox := {}
Local oRest		:= Nil
Local cDataIni	:= dDataBase
Local cDataFim	:= dDataBase
Local cDataIni	:= ""
Local cDataFim	:= ""
Local nN		:= 0
Local oObjJson	

Local aListBox 	:= {}
Local aSize		:= MsAdvSize()
Local aObjects	:= {}
Local aInfo		:= {}
Local aPosObj	:= {}
Local oDlg
Local oListBox
Local oBtn1
Local oBtn2
Local oBtn3

Private cCnpj 		:= Alltrim(FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , { "M0_CGC" } )[1][2])
Private	cInscr		:= Alltrim(FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , { "M0_INSCM" } )[1][2])
Private aHeader 	:= {} 
Private cUrl		:= "api.nfse.tecnospeed.com.br"
Private cProtocol1	:= "https://"
Private cProtocol2	:= "http://"

Private aUF     	:= {}
Private cUf 		:= ""
Private nUf			:= ""	

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

Aadd(aHeader, "Content-Type: application/json")                      
Aadd(aHeader, "token_sh: 8362a6f9f284692afa0d191b34a0cbdd")                      
Aadd(aHeader, "cpfCnpjSoftwareHouse: 07084316000158")                      
Aadd(aHeader, "cpfCnpjTomador: "+cCnpj)   
Aadd(aHeader, "Connection: keep-alive")   

/*01*/AAdd( aParamBox, { 1, "Data de"					,CTOD(dtoc(dDataBase-30))				,	""			,	"MV_PAR01>=dDataBase-30.And.MV_PAR01<=dDatabase"		,	""				,	"",		50,	.T.})
/*02*/AAdd( aParamBox, { 1, "Data ate"					,CTOD(dtoc(dDataBase))					,	""			,	"MV_PAR02<=dDatabase"									,	""				,	"",		50,	.T.})

If (xZBM)->(FieldGet(FieldPos(xZBM_+"PREST"))) == '1'
	/*03*/AAdd( aParamBox, { 1, "Fornecedor"				,SPACE(TamSX3('A2_COD')[1]) 		,	""			,	""														, "SA2"				,	"",		50,	.T.}) 
	/*04*/AAdd( aParamBox, { 1, "Loja"						,SPACE(TamSX3('A2_LOJA')[1])		,	""			,	""														,	""				,	"",		30,	.T.})
EndIf

If ParamBox(aParamBox, "Parametros de consulta manual de municํpio -> "+(xZBM)->(FieldGet(FieldPos(xZBM_+"MUNIC"))))

	dDataIni := MV_PAR01

	cDataIni := substr(dtos(dDataIni),1,4)+"-"
	cDataIni += substr(dtos(dDataIni),5,2)+"-"
	cDataIni += substr(dtos(dDataIni),7,2)

	dDataFim := MV_PAR02

	cDataFim := substr(dtos(dDataFim),1,4)+"-"
	cDataFim += substr(dtos(dDataFim),5,2)+"-"
	cDataFim += substr(dtos(dDataFim),7,2)

	oRest 	:= FWRest():New(cProtocol1+cUrl) //Tenta HTTPS

	oRest:SetPath("/v1/tomadas")        
	
	cBody := 	'{'  + CRLF
	cBody += 		'"codigoCidade": "'+ alltrim((xZBM)->(FieldGet(FieldPos(xZBM_+"COD")))) + '", ' + CRLF
	If (xZBM)->(FieldGet(FieldPos(xZBM_+"PREST"))) == '1'
		cBody +=		'"prestador": {' + CRLF
		cBody +=   			'"cpfCnpj": "'+Posicione("SA2",1,xFilial("SA2")+MV_PAR01+MV_PAR02,"A2_CGC")+'",' + CRLF
		cBody +=    		'"inscricaoMunicipal": "'+Posicione("SA2",1,xFilial("SA2")+MV_PAR01+MV_PAR02,"A2_INSCRM")+'"'	 + CRLF
		cBody +=  		'},'						 + CRLF
	EndIf
	cBody += 		'"destinatario": {' + CRLF
	cBody += 			'"cpfCnpj": "'+ alltrim(cCNPJ) + '",' + CRLF
	cBody += 			'"inscricaoMunicipal": "'+ IIF((xZBM)->(FieldGet(FieldPos(xZBM_+"COD"))) <> "3550308",alltrim(cInscr),"") + '",' + CRLF
	cBody +=   			'"autenticacao":{' + CRLF
	cBody +=				'"login":"'+alltrim( (xZBM)->(FieldGet(FieldPos(xZBM_+"USER"))) )+'",' + CRLF
	cBody +=				'"senha":"'+alltrim( (xZBM)->(FieldGet(FieldPos(xZBM_+"PSW"))) )+'"' + CRLF
	cBody +=			'}' + CRLF
	cBody +=		'},' + CRLF
	cBody += 		'"periodo": {'		 + CRLF
	cBody += 			'"inicial": "'+ cDataIni + '", ' + CRLF
	cBody += 			'"final": "'+ cDataFim + '" ' + CRLF
	cBody +=		'}'	 + CRLF
	cBody +=	'}' + CRLF

	oRest:SetPostParams(cBody)

	If oRest:Post(aHeader) 
		If !FWJsonDeserialize(oRest:GetResult(), @oObjJson)
			MsgStop("Ocorreu erro no processamento do Json")
			Return Nil
		EndIf			 

		cLink := "/v1/tomadas/"+ oObjJson:RESPOSTA:PROTOCOLO 

		RecLock(xZBN,.T.)
			(xZBN)->(FieldPut(FieldPos(xZBN_+"FILIAL"), xFilial(xZBN) ))
			(xZBN)->(FieldPut(FieldPos(xZBN_+"COD"), (xZBM)->(FieldGet(FieldPos(xZBM_+"COD"))) ))
			(xZBN)->(FieldPut(FieldPos(xZBN_+"DATA"), dDataBase ))
			(xZBN)->(FieldPut(FieldPos(xZBN_+"STATUS"), "PROCESSANDO" ))
			(xZBN)->(FieldPut(FieldPos(xZBN_+"LINK"), cLink ))
			cReq := cProtocol1+cUrl+CRLF
			cReq += CRLF

			cReq += "HEADER" + CRLF
			cReq += CRLF

			For nN := 1 to Len(aHeader)
				cReq += aHeader[nN] + CRLF
			Next nN

			cReq += CRLF + CRLF
			cReq += "BODY" + CRLF
			cReq += CRLF
			cReq += cBody
			
			(xZBN)->(FieldPut(FieldPos(xZBN_+"REQ"), cReq ))
		(xZBN)->(MsUnlock())

	Else

		RecLock(xZBN,.T.)
			(xZBN)->(FieldPut(FieldPos(xZBN_+"FILIAL"), xFilial(xZBN) ))
			(xZBN)->(FieldPut(FieldPos(xZBN_+"COD"), (xZBM)->(FieldGet(FieldPos(xZBM_+"COD"))) ))
			(xZBN)->(FieldPut(FieldPos(xZBN_+"DATA"), dDataBase ))
			(xZBN)->(FieldPut(FieldPos(xZBN_+"STATUS"), "ERRO" ))
			If ( ValType( "oRest:CRESULT" ) <> 'U' )
				(xZBN)->(FieldPut(FieldPos(xZBN_+"MSG"), DecodeUtf8(oRest:CRESULT) + Time()))
			Else 
				(xZBN)->(FieldPut(FieldPos(xZBN_+"MSG"), DecodeUtf8(oRest:CINTERNALERROR) + Time() ))
			EndIF
			cReq := cProtocol1+cUrl+CRLF
			cReq += CRLF

			cReq += "HEADER" + CRLF
			cReq += CRLF

			For nN := 1 to Len(aHeader)
				cReq += aHeader[nN] + CRLF
			Next nN

			cReq += CRLF + CRLF
			cReq += "BODY" + CRLF
			cReq += CRLF
			cReq += cBody
			
			(xZBN)->(FieldPut(FieldPos(xZBN_+"REQ"), cReq ))
		(xZBN)->(MsUnlock())

	EndIf  

	AAdd( aObjects, { 100, 100, .t., .t. } )
	AAdd( aObjects, { 100, 015, .t., .f. } )
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects )

	aListBox := U_HF068REF(@aListBox)

	DEFINE FONT oBold BOLD	
	DEFINE MSDIALOG oDlg TITLE "Monitoramento da Requisi็ใo" From aSize[7],0 to aSize[6],aSize[5] OF oMainWnd PIXEL
																								//607,365
	@aPosObj[1,1],aPosObj[1,2] LISTBOX oListBox 	FIELDS HEADER "","Status","Qtd Notas" ; 
		SIZE aPosObj[1,4]-aPosObj[1,2],aPosObj[1,3]-aPosObj[1,1] PIXEL	
			oListBox:SetArray(aListBox)
			oListBox:bLine:={||	{	aListBox[oListBox:nAt][01],;
									Alltrim(aListBox[oListBox:nAt][02]),;
									Alltrim(aListBox[oListBox:nAt][03])}}

	@ aPosObj[2,1],aPosObj[2,4]-150 BUTTON oBtn1 PROMPT "Refresh"			ACTION (aListBox := {}, aListBox := U_HF068REF(@aListBox),oListBox:nAt := 1,oListBox:Refresh()) OF oDlg PIXEL SIZE 040,011 //"Refresh"
	@ aPosObj[2,1],aPosObj[2,4]-100 BUTTON oBtn2 PROMPT "Visualiza Notas"	ACTION (U_HF068VIS()) OF oDlg PIXEL SIZE 040,011 //"Visualiza"	
	@ aPosObj[2,1],aPosObj[2,4]-050 BUTTON oBtn3 PROMPT "Sair"				ACTION oDlg:End() OF oDlg PIXEL SIZE 040,011 //Sair

	ACTIVATE MSDIALOG oDLg CENTERED

Else
	msgInfo("Cancelado pelo operador")
EndIf

Return


User Function HF068REF(aListBox)

	Local oNo       := LoadBitMap(GetResources(), "DISABLE")
	Local oOk       := LoadBitMap(GetResources(), "ENABLE")
	Local oRest		:= FWRest():New(cProtocol1+cUrl)
	Local oObjJson	

	oRest:SetPath((xZBN)->(FieldGet(FieldPos(xZBN_+"LINK"))))        

	If oRest:Get(aHeader) 
		If !FWJsonDeserialize(oRest:GetResult(), @oObjJson)
			MsgStop("Ocorreu erro no processamento do Json")
			Return Nil
		EndIf	
	
		If oObjJson:RESPOSTA:SITUACAO == "CONCLUIDO"

			AADD( aListBox, {;
					oOk,;
					"Download Efetuado",;
					alltrim(str(oObjJson:RESPOSTA:TOTALDENOTAS));
			})

			If (xZBN)->(FieldGet(FieldPos(xZBN_+"STATUS"))) <> "DOWNLOAD EFETUADO"
				
				RecLock(xZBN,.F.)
					(xZBN)->(FieldPut(FieldPos(xZBN_+"DATA"), dDataBase ))
					(xZBN)->(FieldPut(FieldPos(xZBN_+"STATUS"), "DOWNLOAD EFETUADO" ))
					(xZBN)->(FieldPut(FieldPos(xZBN_+"QUANT"), oObjJson:RESPOSTA:TOTALDENOTAS ))
				(xZBN)->(MsUnlock())

				DownNFSE((xZBN)->(FieldGet(FieldPos(xZBN_+"LINK"))))

			EndIf

		ElseIf oObjJson:RESPOSTA:SITUACAO == "ERRO"
		
			If DecodeUtf8(oRest:CRESULT) $ "nใo retornou nota" //Retorno de ERRO mas ้ somente que nใo encontrou notas

				AADD( aListBox, {;
						oOk,;
						DecodeUtf8(oRest:CRESULT),;
						"0";
				})	

				RecLock(xZBN,.F.)
					(xZBN)->(FieldPut(FieldPos(xZBN_+"DATA"), dDataBase ))
					(xZBN)->(FieldPut(FieldPos(xZBN_+"STATUS"), "NENHUMA NOTA" ))
					(xZBN)->(FieldPut(FieldPos(xZBN_+"MSG"), "Nใo hแ nenhuma nota neste dia" + Time() ))
				(xZBN)->(MsUnlock())					
			Else

				AADD( aListBox, {;
						oNo,;
						DecodeUtf8(oRest:CRESULT),;
						"0";
				})	

				RecLock(xZBN,.F.)
					(xZBN)->(FieldPut(FieldPos(xZBN_+"DATA"), dDataBase ))
					(xZBN)->(FieldPut(FieldPos(xZBN_+"STATUS"), "ERRO" ))
					(xZBN)->(FieldPut(FieldPos(xZBN_+"MSG"), DecodeUtf8(oRest:CRESULT) + Time() ))	
				(xZBN)->(MsUnlock())


			EndIf

		ElseIf oObjJson:RESPOSTA:SITUACAO == "PROCESSANDO"

			AADD( aListBox, {;
					oNo,;
					"Aguarde processamento",;
					"0";
			})	

		EndIf

	Else

		AADD( aListBox, {;
				oNo,;
				"Problema de comunica็ใo",;
				"0";
		})	

		RecLock(xZBN,.F.)
			(xZBN)->(FieldPut(FieldPos(xZBN_+"DATA"), dDataBase ))
			(xZBN)->(FieldPut(FieldPos(xZBN_+"STATUS"), "ERRO" ))
			(xZBN)->(FieldPut(FieldPos(xZBN_+"MSG"), "Problema de comunica็ใo " + Time() ))	
		(xZBN)->(MsUnlock())

	EndIf	


Return aListBox


User Function HF068VIS()

	Local oRestVis
	Local oObjVis	
	Local oListVis
	Local aListVis		:= {}
	Local aSizeVis		:= MsAdvSize()
	Local aObjVis		:= {}
	Local aInfoVis		:= {}
	Local aPosVis		:= {}
	Local oDlgVis
	Local oBtnVis
	Local nX			:= 0
	Local cPathVis 		:= alltrim((xZBN)->(FieldGet(FieldPos(xZBN_+"LINK"))))+"/notas"

	Private cUrl 			:= "api.nfse.tecnospeed.com.br" 
	Private cCnpj			:= ""
	Private aHeader		:= {}

	Private cProtocol1	:= "https://"
	Private cProtocol2	:= "http://"

	Private aUF     	:= {}
	Private cUf 		:= ""
	Private nUf			:= ""	

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

	cCnpj 	:= Alltrim(FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , { "M0_CGC" } )[1][2])

	Aadd(aHeader, "Content-Type: application/json")                      
	Aadd(aHeader, "token_sh: 8362a6f9f284692afa0d191b34a0cbdd")                      
	Aadd(aHeader, "cpfCnpjSoftwareHouse: 07084316000158")                      
	Aadd(aHeader, "cpfCnpjTomador: "+cCnpj)   
	Aadd(aHeader, "Connection: keep-alive")   

	AAdd( aObjVis, { 100, 100, .t., .t. } )
	AAdd( aObjVis, { 100, 015, .t., .f. } )
	aInfoVis := { aSizeVis[ 1 ], aSizeVis[ 2 ], aSizeVis[ 3 ], aSizeVis[ 4 ], 3, 3 }
	aPosVis := MsObjSize( aInfoVis, aObjVis )

	oRestVis := FWRest():New(cProtocol1+cUrl)
	oRestVis:SetPath(cPathVis)  
    
	If oRestVis:Get(aHeader) 
		If !FWJsonDeserialize(oRestVis:GetResult(), @oObjVis)
			MsgStop("Ocorreu erro no processamento do Json")
			Return Nil
		EndIf	
	
		If oObjVis:RESPOSTA:SITUACAO == "CONCLUIDO"

			For nX := 1 to len(oObjVis:RESPOSTA:NOTAS)

				aAdd(aListVis,{;
					oObjVis:RESPOSTA:NOTAS[nX]:SERVICOS[1]:NFSE:NUMERO,;
					oObjVis:RESPOSTA:NOTAS[nX]:PRESTADOR:CPFCNPJ,;
					stod(;
						substr(oObjVis:RESPOSTA:NOTAS[nX]:SERVICOS[1]:NFSE:DATAAUTORIZACAO,1,4)+;
						substr(oObjVis:RESPOSTA:NOTAS[nX]:SERVICOS[1]:NFSE:DATAAUTORIZACAO,6,2)+;
						substr(oObjVis:RESPOSTA:NOTAS[nX]:SERVICOS[1]:NFSE:DATAAUTORIZACAO,9,2);
					),;
					AllTrim(Str(oObjVis:RESPOSTA:NOTAS[nX]:VALORSERVICOS ,20,2)),;
					AllTrim(Str(oObjVis:RESPOSTA:NOTAS[nX]:SERVICOS[1]:ISS:RETIDO,20,2));					
				})

			Next

			If (xZBN)->(FieldGet(FieldPos(xZBN_+"STATUS"))) <> "DOWNLOAD EFETUADO"

				RecLock(xZBN,.F.)
					(xZBN)->(FieldPut(FieldPos(xZBN_+"DATA"), dDataBase ))
					(xZBN)->(FieldPut(FieldPos(xZBN_+"STATUS"), "DOWNLOAD EFETUADO" ))
					(xZBN)->(FieldPut(FieldPos(xZBN_+"QUANT"), oObjVis:RESPOSTA:TOTALDENOTAS ))
				(xZBN)->(MsUnlock())

				DownNFSE((xZBN)->(FieldGet(FieldPos(xZBN_+"LINK"))))

			EndIf

			DEFINE FONT oBold BOLD	
			DEFINE MSDIALOG oDlgVis TITLE "Visualiza NFS-e" From aSizeVis[7],0 to aSizeVis[6],aSizeVis[5] OF oMainWnd PIXEL
																										//607,365
			@aPosVis[1,1],aPosVis[1,2] LISTBOX oListVis 	FIELDS HEADER "N๚mero","Prestador","Emissใo","Valor","ISS" ; 
				SIZE aPosVis[1,4]-aPosVis[1,2],aPosVis[1,3]-aPosVis[1,1] PIXEL	
					oListVis:SetArray(aListVis)
					oListVis:bLine:={||	{	aListVis[oListVis:nAt][01],;
											aListVis[oListVis:nAt][02],;
											aListVis[oListVis:nAt][03],;
											aListVis[oListVis:nAt][04],;
											aListVis[oListVis:nAt][05];
										}}

			@ aPosVis[2,1],aPosVis[2,4]-040 BUTTON oBtnVis PROMPT "Sair"				ACTION oDlgVis:End() OF oDlgVis PIXEL SIZE 035,011 //Sair

			ACTIVATE MSDIALOG oDlgVis CENTERED
		Else
			msgInfo("Favor aguardar o processamento para visualizar as notas")
		EndIf		

	Else

		msgAlert("Falha de comunica็ใo")

	EndIf

Return
