#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

User Function HFCADZBC


Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

Private xZBC      := GetNewPar("XM_TABCAC","ZBC")
Private xZBC_     := iif(Substr(xZBC,1,1)=="S", Substr(xZBC,2,2), Substr(xZBC,1,3)) + "_"

Private cString := xZBC

dbSelectArea(cString)
dbSetOrder(1)

AxCadastro(cString,"Cadastro Amarração Para Classificação Robótica",cVldExc,cVldAlt)

Return
