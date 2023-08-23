//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

 
/*/{Protheus.doc} zMVCMd3
Função para cadastro de Grupo de Produtos (SBM) e Produtos (SB1), exemplo de Modelo 3 em MVC
@author Atilio
@since 17/08/2015
@version 1.0
    @return Nil, Função não tem retorno
    @example
    u_zMVCMd3()
    @obs Não se pode executar função MVC dentro do fórmulas
/*/
 
/*User Function HFXML067()

    Local aArea   := GetArea()
    Local oBrowse
     
    //Instânciando FWMBrowse - Somente com dicionário de dados
    oBrowse := FWMBrowse():New()
     
    //Setando a tabela de cadastro de Autor/Interprete
    oBrowse:SetAlias("ZBZ")
 
    //Setando a descrição da rotina
    oBrowse:SetDescription(cTitulo)
     
    //Ativa a Browse
    oBrowse:Activate()
     
    RestArea(aArea)

Return Nil*/
 
/*---------------------------------------------------------------------*
 | Func:  MenuDef                                                      |
 | Autor: Daniel Atilio                                                |
 | Data:  17/08/2015                                                   |
 | Desc:  Criação do menu MVC                                          |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
 
/*Static Function MenuDef()

    Local aRot := {}
     
    //Adicionando opções
    ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.HFXML067' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    //ADD OPTION aRot TITLE 'Legenda'    ACTION 'u_zMVC01Leg'     OPERATION 6                      ACCESS 0 //OPERATION X
    //ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.zMVCMd3' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    //ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.zMVCMd3' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    //ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.zMVCMd3' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
 
Return aRot*/
 
Static Function ModelDef()

    Local oModel   := Nil
    Local oStPai   := FWFormStruct(1, 'ZBZ', )
    Local oStFilho := FWFormStruct(1, 'ZBT', )
    Local aZBZRel  := {}
    Local bLoad := {|oGridModel, lCopy| loadGrid(oGridModel, lCopy)}
     
    //Criando o modelo e os relacionamentos
    oModel := MPFormModel():New('HFXML067M')
    oModel:AddFields('ZBZMASTER',/*cOwner*/,oStPai)
    oModel:AddGrid('ZBTDETAIL','ZBZMASTER',oStFilho,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,bLoad)  //cOwner é para quem pertence
     
    //Fazendo o relacionamento entre o Pai e Filho
    //aAdd(aZBZRel, {'ZBZ_FILIAL',  'ZBT_FILIAL'})
    aAdd(aZBZRel, {'ZBZ_CHAVE',   'ZBT_CHAVE'}) 
     
    oModel:SetRelation('ZBTDETAIL', aZBZRel, ZBT->(IndexKey(1))) //IndexKey -> quero a ordenação e depois filtrado
    //oModel:GetModel('ZBTDETAIL'):SetUniqueLine({"R_E_C_N_O_"})    //Não repetir informações ou combinações {"CAMPO1","CAMPO2","CAMPOX"}
    oModel:SetPrimaryKey({})

    //Chave Primaria
	//oModel:SetPrimaryKey({"ZBT_CHAVE"})
     
    //Setando as descrições
    oModel:SetDescription("XML x Itens - Mod. 3")
    oModel:GetModel('ZBZMASTER'):SetDescription('XML')
    oModel:GetModel('ZBTDETAIL'):SetDescription('Itens')

    // É necessário que haja alguma alteração na estrutura Field
    oModel:Activate( .T. )

Return oModel
 
/*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Autor: Daniel Atilio                                                |
 | Data:  17/08/2015                                                   |
 | Desc:  Criação da visão MVC                                         |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
 
Static Function ViewDef()

    Local oView    := Nil
    Local oModel   := FWLoadModel('HFXML067')
    Local oStPai   := FWFormStruct(2, 'ZBZ', )
    Local oStFilho := FWFormStruct(2, 'ZBT', )
     
    //Criando a View
    oView := FWFormView():New()
    oView:SetModel(oModel)
     
    //Adicionando os campos do cabeçalho e o grid dos filhos
    oView:AddField('VIEW_ZBZ',oStPai,'ZBZMASTER')
    oView:AddGrid('VIEW_ZBT',oStFilho,'ZBTDETAIL')
     
    //Setando o dimensionamento de tamanho
    oView:CreateHorizontalBox('CABEC',70)
    oView:CreateHorizontalBox('GRID',30)
     
    //Amarrando a view com as box
    oView:SetOwnerView('VIEW_ZBZ','CABEC')
    oView:SetOwnerView('VIEW_ZBT','GRID')
     
    //Habilitando título
    oView:EnableTitleView('VIEW_ZBZ','XML')
    oView:EnableTitleView('VIEW_ZBT','Itens')

    oView:SetDescription( "Tela" )

    //Força o fechamento da janela na confirmação
    oView:SetCloseOnOk({||.T.})

Return oView


Static Function loadGrid(oGridModel, lCopy)

Local aLoad := {}
Local aAcho := {}

For nX := 1 To (xZBZ)->(FCount())
			
    aAcho[1,nx] := (xZBZ)->( FieldName( nX ) ) 

Next  

   aAdd(aLoad,{0, aAcho } ) //dados
      
Return aLoad
