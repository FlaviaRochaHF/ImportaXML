#INCLUDE "rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HFXML15   � Autor � Heverton Marcondes � Data �  12/12/22   ���
�������������������������������������������������������������������������͹��
���Descricao � Codigo gerado pelo AP6 IDE.                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP6 IDE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function HFXML15()

Local aArea 

Private oBrowse
Private xZBH  	  := GetNewPar("XM_TABTPO","ZBH")      
Private xZBH_ 	  := iif(Substr(xZBH,1,1)=="S", Substr(xZBH,2,2), Substr(xZBH,1,3)) + "_"

aArea := (xZBH)->(GetArea())
aRotina := MenuDef()

oBrowse := FWMBrowse():New()
oBrowse:SetAlias(xZBH)
oBrowse:SetDescription('Tipo de Ocorrencias XML')
oBrowse:DisableDetails()

oBrowse:AddLegend( xZBH_+"ATIVO <> '2'", "GREEN", "Ocorrencia Ativa" )
oBrowse:AddLegend( xZBH_+"ATIVO == '2'", "RED" , "Ocorrencia Inativa" )

oBrowse:Activate()

RestArea(aArea)

Return


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    �MenuDef   � Autor � Heverton Marcondes � Data � 07/01/2016  ���
�������������������������������������������������������������������������͹��
���Descri��o � Menudef                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function MenuDef()

Local aRotina := {}

aadd(aRotina, {"Pesquisar"  ,"PesqBrw"  			,0,1,0,Nil} )
aadd(aRotina, {"Pesquisar"  ,"VIEWDEF.HFXML15"		,0,2,0,Nil} )
aadd(aRotina, {"Incluir"	,"VIEWDEF.HFXML15"		,0,3,0,Nil} )
aadd(aRotina, {"Alterar"    ,"VIEWDEF.HFXML15"		,0,4,0,Nil} )
aadd(aRotina, {"Excluir"    ,"VIEWDEF.HFXML15"		,0,5,0,Nil} )
aadd(aRotina, {"Imprimir"   ,"VIEWDEF.HFXML15"		,0,8,0,Nil} )
aadd(aRotina, {"Pesquisar"  ,"U_LEGXML15()"  		,0,8,0,Nil} )

Return aRotina

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    �ModelDef  � Autor � Heverton Marcondes � Data � 07/01/2016  ���
�������������������������������������������������������������������������͹��
���Descri��o � Modeldef                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function ModelDef()

Local oStruZBH := FWFormStruct( 1,xZBH)
Local oModel

oModel := MPFormModel():New( 'MHFXML15' )

oModel:AddFields( xZBH, /*cOwner*/, oStruZBH )

oModel:SetPrimaryKey({xZBH_+"FILIAL",xZBH_+"COD"})

oModel:SetDescription( 'Tipo de Ocorrencias XML' )

oModel:GetModel( xZBH ):SetDescription( 'Tipo de Ocorrencias XML' )

Return oModel

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    �ViewDef   � Autor � Heverton Marcondes � Data � 07/01/2016  ���
�������������������������������������������������������������������������͹��
���Descri��o � ViewDef                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function ViewDef()

Local oModel := ModelDef()

Local oStruZBH	:= FWFormStruct( 2, xZBH )

Local oView

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField( 'VIEW_ZBH', oStruZBH, xZBH )

Return oView

//////////////////////////
//Legendas				//
//////////////////////////

User Function LEGXML15()
	
Local aLegenda := {}

aAdd(aLegenda,{"BR_VERDE","Ocorrencia Ativa"})
aAdd(aLegenda,{"BR_VERMELHO","Ocorrencia Inativa"})

BrwLegenda("Tipos de Ocorrencias de XML","Legendas",aLegenda)

Return
