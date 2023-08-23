#include "tbiconn.ch"
#include "Protheus.ch"   
#include "Topconn.ch"                  

#DEFINE STATUS_S 'S'
#DEFINE STATUS_N 'N'

User Function HFXML12C()  //U_ClNfisca()

	local xSerie	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE")))
	local xNfiscal	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"NOTA")))
	//local xSerie	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"SERIE")))
	local xCFornec	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CODFOR")))
	local xLFornec	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"LOJFOR")))
	local xTPNota	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"TPDOC")))
	local xStatus	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"PRENF")))
	local xCnpj     := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ")))
	local xChave	:= alltrim((xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))))
	local xlSeek	:=	.F.
	local xMsg		:= ''
	local aCab      := {}
	local aItem     := {}
	local aItens    := {}
	local aDocOri   := {"1",; // (Gestão XML)     -> Erick Silva - 16/02/2023
						"2"}  // (Protheus Padrão)
	local cCondPag  := ""
	local cTes      := ""
	local aArea     := GetArea()
	Local cUlTES    := ""
	Local cManPre   := GetNewPar("XM_MANPRE","N")
	Local cManif    := ""
	Local cOri      := ""

	if xStatus == STATUS_S	
	
		// F1_DOC + F1_SERIE + F1_FORNEC + F1_LOJA + F1_TIPO

		dbSelectArea('SF1')
		dbSetOrder(1)
		if dbSeek(FWxFilial('SF1')+xNfiscal+xSerie+xCFornec+xLFornec+xTPNota)
		
			xlSeek	:= .T.
			
		else

			dbSetOrder(8)
			if dbSeek(FWxFilial('SF1')+xChave)
			
				xlSeek := .T.
			
			endif
		endIf
		
		If xlSeek

			if  (empty(SF1->F1_STATUS) .or. (SF1->F1_STATUS == 'B' .and. SuperGetMV('MV_RESTCLA',.F.,'2')=='2')) 

				if GetNewPar("XM_TESDEV", "N") == "S"  //Verifica cliente usará TES de devolução do campo F4_TESDV

					//Cabeçalho
					aadd(aCab,{"F1_TIPO" ,SF1->F1_TIPO,NIL})
					aadd(aCab,{"F1_FORMUL" ,SF1->F1_FORMUL,NIL})
					aadd(aCab,{"F1_DOC" ,SF1->F1_DOC ,NIL})
					aadd(aCab,{"F1_SERIE" ,SF1->F1_SERIE ,NIL})
					aadd(aCab,{"F1_EMISSAO" ,SF1->F1_EMISSAO ,NIL})
					aadd(aCab,{"F1_DTDIGIT" ,SF1->F1_DTDIGIT ,NIL})
					aadd(aCab,{"F1_FORNECE" ,SF1->F1_FORNECE ,NIL})
					aadd(aCab,{"F1_LOJA" ,SF1->F1_LOJA ,NIL})
					aadd(aCab,{"F1_ESPECIE" ,SF1->F1_ESPECIE,NIL})

					DbSelectArea("SA2")
					DbSetOrder(1)
					DbSeek( xFilial("SA2") + xCFornec + xLFornec )

					cCondPag := SA2->A2_COND

					if !Empty( cCondPag )

						aAdd(aCab, {"F1_COND" , cCondPag,  nil}) 

					endif

					//Busca ultima tes e cond. Pagto nas notas
					cQuery := ""
					cQuery := " SELECT TOP 1 D1_TES, F1_COND FROM " + RetSqlName("SD1") + " SD1 "
					cQuery += " INNER JOIN " + RetSqlName("SF1") + " SF1 ON F1_FILIAL = D1_FILIAL AND F1_DOC = D1_DOC AND F1_SERIE = D1_SERIE AND F1_FORNECE = D1_FORNECE AND F1_LOJA = D1_LOJA AND F1_TIPO = D1_TIPO AND F1_COND <> '' AND SF1.D_E_L_E_T_ = '' "
					cQuery += " WHERE "
					cQuery += " D1_EMISSAO = ( SELECT MAX(D1_EMISSAO) FROM " + RetSqlName("SD1") + " SD1A where SD1A.D_E_L_E_T_ = '' AND SD1A.D1_TES <> '' ) "
					cQuery += " AND SD1.D_E_L_E_T_ = '' "
					cQuery += " ORDER BY 1 "

					TCQUERY (cQuery) ALIAS "QRY" NEW

					While QRY->( !Eof() )

						if !Empty( QRY->D1_TES )

							cUlTES   := QRY->D1_TES 

							if Empty( cCondPag )
						
								cCondPag := QRY->F1_COND

								aAdd(aCab, {"F1_COND" , cCondPag,  nil}) 

							endif

						endif

						QRY->( DbSkip() )

					End

					QRY->( DbCloseArea() )

					//Itens
					DbSelectArea("SD1")
					DbSetOrder(1)
					DbSeek(xFilial("SD1") + xNfiscal + xSerie + xCFornec + xLFornec)

					While SD1->( !Eof() ) .and. xNfiscal + xSerie + xCFornec + xLFornec == SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA

						aItem := {}
						
						aadd(aItem,{"D1_ITEM" ,SD1->D1_ITEM ,NIL})
						aadd(aItem,{"D1_COD" ,SD1->D1_COD ,NIL})
						aadd(aItem,{"D1_UM" ,SD1->D1_UM ,NIL})
						aadd(aItem,{"D1_LOCAL" ,SD1->D1_LOCAL,NIL})
						aadd(aItem,{"D1_QUANT" ,SD1->D1_QUANT ,NIL})
						aadd(aItem,{"D1_VUNIT" ,SD1->D1_VUNIT ,NIL})
						aadd(aItem,{"D1_TOTAL" ,SD1->D1_TOTAL ,NIL})

						DbSelectArea("SB1")
						DbSetOrder(1)
						DbSeek( xFilial("SB1") + SD1->D1_COD )

						if !Empty( cUlTES )

							cTes := cUlTES

						else

							cTes := SB1->B1_TE

						endif

						if SF1->F1_TIPO == "D"

							//Cliente
							DbSelectArea("SA1")
							DbSetOrder(3)
							DbSeek( xFilial("SA1") + xCnpj )

							//Nota de saida
							DbSelectArea("SD2")
							DbSetOrder(3)
							if DbSeek( xFilial("SD2") + SD1->D1_NFORI + SD1->D1_SERIORI + SA1->A1_COD + SA1->A1_LOJA + SD1->D1_COD + SD1->D1_ITEMORI )

								cTes := SD2->D2_TES

							endif
				
							DbSelectArea("SF4")
							DbSetOrder(1)
							DbSeek( xFilial("SF4") + cTes )

							if !Empty(SF4->F4_TESDV) .and. SF4->F4_TIPO == "S"

								cTes := SF4->F4_TESDV

							else

								if !Empty(cUlTES)

									cTes := cUlTES

								elseif !Empty(SB1->B1_TE)

									cTes := SB1->B1_TE

								else

									cTes := u_HFRETSF4()  //Chama a rotina que retorna tes de entrada

								endif
						
							endif

						endif

						aadd(aItem,{"D1_TES" ,cTes ,NIL})

						aAdd(aItem, {"LINPOS" , "D1_ITEM",  SD1->D1_ITEM}) //ou SD1->D1_ITEM  se estiver posicionado.

						aadd(aItens,aItem)

						SD1->( DbSkip() )

					End

					if Len(aItens) > 0 

						lMsErroAuto := .F.

						MSExecAuto({|x,y,z,k| mata103(x,y,z,k)},aCab,aItens,4,.T.)  //Mata103(, , 4 , )

						If !lMsErroAuto
							ConOut(" Inclusao realizada com sucesso")
						Else
							MostraErro()
							ConOut("Erro na inclusao!")
						EndIf	

					endif

				else

					Mata103(, , 4 , )			

				endif

			endif

			//  atualizar ZBZ			
			//Ao cancelar a classificação o status continua o mesmo 'S' na ZBZ
			If Empty(SF1->F1_STATUS)

				Reclock(xZBZ,.F.)
				//(xZBZ)->ZBZ_PRENF := STATUS_N
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PRENF"), STATUS_S ))
				(xZBZ)->(MsUnlock())
				//(xZBZ)->(dbSkip())

            Else

				Reclock(xZBZ,.F.)
				//(xZBZ)->ZBZ_PRENF := STATUS_N
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"PRENF"), STATUS_N ))
				(xZBZ)->(FieldPut(FieldPos(xZBZ_+"ORIGEM"), aDocOri[1] ))
				(xZBZ)->(MsUnlock())
				//(xZBZ)->(dbSkip())

				//Manifesta e Verifica se o parametro esta habilitado para manifestar na classificação
				if FieldPos(xZBZ_+"MANIF") > 0 .and. cManPre == "3"

					cOri := "1"

					if FieldPos(xZBZ_+"IMPORT") > 0
						if !Empty( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"IMPORT"))) )
							cOri := (xZBZ)->(FieldGet(FieldPos(xZBZ_+"IMPORT")))
						Endif
					Endif

					cManif := U_MANIFXML( AllTrim( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))) ), .T., cOri ) 

					DbSelectArea(xZBZ)
					DbSetOrder(3)
					DbSeek( (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CHAVE"))) )
					Reclock(xZBZ,.F.)                        

					(xZBZ)->(FieldPut(FieldPos(xZBZ_+"MANIF"), cManif ))

					(xZBZ)->( MsUnlock() )  

				endif

				//----------------------------------------------------------------------------------------------------//
				//FR - 22/12/2022 - PROJETO BRASMOLDE - NOTIFICAÇÕES POR EMAIL QDO BAIXA XML
				//Depois de Classificar a nota aciona rotina que dispara email caso esteja parametrizado para receber
				//----------------------------------------------------------------------------------------------------//
				cMail12 := GetNewPar("XM_MAIL12",Space(256))  //FR - 21/12/2022 - Flávia Rocha - EMAIL AVISANDO SOBRE NOVO XML GRAVADO NA BASE	
				If !Empty(cMail12) //emails que receberão notificação qdo gravar xml na base
									
					cFornec  := ""
					cLojFor  := ""
					cNomeFor := ""
					cRazao   := ""
					cCNPJ    := ""
					nFormNfe := Val(GetNewPar("XM_FORMNFE","9"))

					//cAssunto := "Nota Fiscal Classificada Com Sucesso"
					cAssunto := "Classificação NFe: " + SF1->F1_DOC + "/" + SF1->F1_SERIE 
					cTipo    := "2"  //classificação ok
					aMsg     := {}			
					cFornec  := SF1->F1_FORNECE 
					cLojFor  := SF1->F1_LOJA

					//se a nota for de beneficiamento ou devolução, pega do cad. cliente:
					If SF1->F1_TIPO $ "B/D"
						cNomeFor := Posicione("SA1",1,xFilial("SA1")+ cFornec + cLojFor,"A1_NOME")					
						cCNPJ    := Posicione("SA1",1,xFilial("SA1")+ cFornec + cLojFor,"A1_CGC")
						cTpCliFor:= "Cliente"
					Else 
						cNomeFor := Posicione("SA2",1,xFilial("SA2")+ cFornec + cLojFor,"A2_NOME")					
						cCNPJ    := Posicione("SA2",1,xFilial("SA2")+ cFornec + cLojFor,"A2_CGC")
						cTpCliFor:= "Fornecedor"
					Endif 

					cRazao   := cNomeFor
					cMotivo  := ""
					cTAG     := ""
					cAssunto += "- Forn: " + cFornec + "/" + cLojFor + "-" + cNomeFor + " - SUCESSO"

					U_FNOTIFICA(cMail12, cTipo, cFornec, cLojfor, cNomeFor, cRazao, cCNPJ, Val(SF1->F1_DOC), SF1->F1_SERIE, nFormNfe,SF1->F1_EMISSAO,cMotivo,cTAG,SF1->F1_CHVNFE,cTpCliFor)
									
					
					//MODELO
					//Assunto  - Nota Fiscal não importada com sucesso 
					//Conteúdo 
					//Fornecedor......: 000996 - TE CONNECTIVITY BRASIL IN
					//Nota Fiscal.....: 000196943/1 - Emissão: 19/04/2021
					//Chave da NFe....: 35210400907845001560550010001969431286545563
					//Situação SEFAZ..: 100 - Autorizado o uso da NF-e
					 
				Endif 
				
				//FR - 22/12/2022 - PROJETO BRASMOLDE - NOTIFICAÇÕES POR EMAIL QDO CLASSIFICA A NF
				
			EndIf

		else
		
			alert('documento nao localizado')	
		
		endif	

	else
	
		xMsg := alert('documento nao pode ser classificado')
	
	endif	

	RestArea( aArea )
		
Return()


/*/Se Nota Fiscal Entrada do Tipo: Normal, Devolucao ou Beneficiamento ...
If AllTrim(SF1->F1_TIPO) $ "N/D/B"
   
   //Encontra Numero Verdadeiro Opcao Excluir no Menu Principal / Botao ‘Acoes Relacionadas‘ ...
   nOpcSF1 := AScan( aRotina, { |x| UPPER(x[1]) == "EXCLUIR" } )   
   
   //Chama Funcao Padrao Estorno Classificacao ...   
   A103NFiscal("SF1",SF1->(RecNo()),nOpcSF1,.F.,.T.)
   Else
      Help("",1,"A140NCLASS")
EndIf*/
