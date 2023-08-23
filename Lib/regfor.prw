#include 'protheus.ch'

user function RegFor()
	local aArea		:= GetArea() 
	local aAreaSA2	:= SA2->(GetArea())
	local lRetorno	:= .T.
	M->A2_CGC	:= (xZBZ)->(FieldGet(FieldPos(xZBZ_+"CNPJ")))  //(xZBZ)->ZBZ_CNPJ
	//If lRetorno .And. SuperGetMv('MV_MASHUPS',.F.,'.T.') .And. !_SetAutoMode()
		RFMashups(M->A2_CGC,{'M->A2_NOME','M->A2_NREDUZ','M->A2_END','M->A2_CEP','M->A2_BAIRRO','M->A2_MUN','M->A2_EST'})
	//EndIf
	RestArea(aAreaSA2)
	RestArea(aArea)
return(lRetorno)