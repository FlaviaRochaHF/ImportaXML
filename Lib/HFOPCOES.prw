#Include "Protheus.ch"
 
/*/{Protheus.doc} zOpcoes
Fun��o para retornar uma lista de op��es em um campo combo
@author Rog�rio Lino
@since 08/05/2020
@version 12.25
@type function
/*/
 
User Function zOpcoes()

Local aArea   := GetArea()
Local cOpcoes := ""
 
//Montando as op��es de retorno
cOpcoes += "B=Importado;"
cOpcoes += "A=Aviso Recbto Carga;"
cOpcoes += "S=Pre-Nota a Classificar;"
cOpcoes += "N=Pre-Nota Classificada;"
cOpcoes += "F=Falha de Importacao;"
cOpcoes += "X=Xml Cancelado;"
cOpcoes += "Z=Xml Rejeitado;"
cOpcoes += "D=Denegada;"
 
RestArea(aArea)

Return cOpcoes