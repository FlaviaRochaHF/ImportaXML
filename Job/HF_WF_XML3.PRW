#Include 'Protheus.ch'
#Include 'TbiConn.ch'
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HF_WF_XML3   �Autor  �Erick Gon�alves  � Data �  01/01/23   ���
�������������������������������������������������������������������������͹��
���Desc.     � Job exclusivo para requisi��o de Licen�a: Gest�o XML.      ���
�������������������������������������������������������������������������͹��
���Uso       � Importa Xml                                                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function WTJobReq

Local cEmp      := "99" // c�digo da empresa - teste
Local cFil      := "01" // codigo da filial - teste

RPCSetType(3) // N�o consome licen�a
RpcSetEnv(cEmp,cFil,,,,GetEnvServer(),{ }) // Abertura do ambiente no JOB -> PREPARE ENVIRONMENT.

Local nHora     := Time()
Local nReq      := GetNewPar("XM_REQMAIL")

ConOut( dtoc( Date() )+" "+Time()+" Iniciando o job do Gest�o XML...." )
    While !KillApp()

        ConOut( dtoc( Date() )+" "+Time()+" Atualizando as requisic�es de licenca" )

        nHora           := Val(SubStr(nHora, 1, At( ':' , nHora)-1)) // <-- Recebe o hor�rio do smartclient da vari�vel e desconsidera os minutos e segundos. Ex: 23:00 -> 23.

        If nHora == 0

            If nReq >= 3
                nReq            := 0
            EndIf

            // Atualizando o par�metro com o saldo de requisi��es. - Erick Gon�alves - 27/12/2022
            If !PutMv("XM_REQMAIL", nReq )
		        RecLock("SX6",.T.)
		        SX6->X6_FIL     := xFilial("SX6")
		        SX6->X6_VAR     := "XM_REQMAIL"
		        SX6->X6_TIPO    := "N"
		        SX6->X6_DESCRIC := "Quantidade de Requisi��o m�xima por E-mail"
		        MsUnLock()
		        PutMv("XM_REQMAIL", nReq )
	        EndIf

            MsgAlert("A quantidade de requisicoes foram resetadas com sucesso.")

        Else

            MsgAlert("A quantidade de requisicoes s�o resetadas a partir de meia noite."+ CRLF + "Por favor aguarde o reset e valide novamente em seguida.","Gestao XML")

        EndIf

        ConOut( dtoc( Date() )+" "+Time()+" Fim do Job" )

        KillApp(.T.)

    Enddo

RpcClearEnv() // Libera o Ambiente
Return
