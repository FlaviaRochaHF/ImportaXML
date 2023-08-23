#Include 'Protheus.ch'
#Include 'TbiConn.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HF_WF_XML3   ºAutor  ³Erick Gonçalves  º Data ³  01/01/23   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Job exclusivo para requisição de Licença: Gestão XML.      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Importa Xml                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function WTJobReq

Local cEmp      := "99" // código da empresa - teste
Local cFil      := "01" // codigo da filial - teste

RPCSetType(3) // Não consome licença
RpcSetEnv(cEmp,cFil,,,,GetEnvServer(),{ }) // Abertura do ambiente no JOB -> PREPARE ENVIRONMENT.

Local nHora     := Time()
Local nReq      := GetNewPar("XM_REQMAIL")

ConOut( dtoc( Date() )+" "+Time()+" Iniciando o job do Gestão XML...." )
    While !KillApp()

        ConOut( dtoc( Date() )+" "+Time()+" Atualizando as requisicões de licenca" )

        nHora           := Val(SubStr(nHora, 1, At( ':' , nHora)-1)) // <-- Recebe o horário do smartclient da variável e desconsidera os minutos e segundos. Ex: 23:00 -> 23.

        If nHora == 0

            If nReq >= 3
                nReq            := 0
            EndIf

            // Atualizando o parâmetro com o saldo de requisições. - Erick Gonçalves - 27/12/2022
            If !PutMv("XM_REQMAIL", nReq )
		        RecLock("SX6",.T.)
		        SX6->X6_FIL     := xFilial("SX6")
		        SX6->X6_VAR     := "XM_REQMAIL"
		        SX6->X6_TIPO    := "N"
		        SX6->X6_DESCRIC := "Quantidade de Requisição máxima por E-mail"
		        MsUnLock()
		        PutMv("XM_REQMAIL", nReq )
	        EndIf

            MsgAlert("A quantidade de requisicoes foram resetadas com sucesso.")

        Else

            MsgAlert("A quantidade de requisicoes são resetadas a partir de meia noite."+ CRLF + "Por favor aguarde o reset e valide novamente em seguida.","Gestao XML")

        EndIf

        ConOut( dtoc( Date() )+" "+Time()+" Fim do Job" )

        KillApp(.T.)

    Enddo

RpcClearEnv() // Libera o Ambiente
Return
