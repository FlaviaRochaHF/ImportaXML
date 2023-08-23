#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "Ap5Mail.ch"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "mata140.ch"
#Include "RwMake.Ch"


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetVerIX  �Autor  �Roberto Souza       � Data �  01/03/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � Verifica a vers�o e compila��o.                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Geral                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function GetverIX()

Local aRet := {}
Local oWs
Local cVerImpTss := "" 
Local cURL    := AllTrim(GetNewPar("XM_URL",""))
Local cCloud  := GetNewPar("XM_CLOUD" ,"0")         //aCombo (0=Desbilitado 1=Habilitado)
Local aDatePrw:= {} // Array para apresentar o dia que o fonte HFXML01(Principal) foi compilado no rpo.

if GetNewPar("XM_DFE","0") $ "0,1"

	if cCloud <> "1"

		cURL   := PadR(GetNewPar("XM_URL",""),250)

		If Empty(cURL)

			cURL := PadR(GetNewPar("MV_SPEDURL","http://"),250)

		EndIf

		oWs := WSHFXMLMANIFESTO():New()
		oWs:cCCURL := cURL

		if oWs:HFTSSVERSAO()
			cVerImpTss := oWs:cHFTSSVERSAORESULT
		endif

	else

		cUrl := ""
		
	endif

else
	
	cUrl := ""
	
endif

aDatePrw := GetAPOInfo("HFXML01.prw")  // Erick Gon�alves 06/03/2023 - Recebe as informa��es do rpo sobre o fonte.

Aadd(aRet,{"Vers�o"     ,"6.02"       })
Aadd(aRet,{"Compila��o" ,"20230710"   })
//Aadd(aRet,{"Compila��o" ,aDatePrw[4] })
Aadd(aRet,{"Data"       ,"10/07/2023" })
Aadd(aRet,{"FTP"        ,"ftp://"     })
Aadd(aRet,{"TSSIMPXML"  ,cVerImpTss   })

Return(aRet)
