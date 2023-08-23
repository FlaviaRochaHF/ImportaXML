#include 'Protheus.ch'
#include 'TopConn.ch'


User Function HFXML066()

    Local oScroll
    Local nGrafico := BARCOMPCHART

    Private xZBZ    := GetNewPar("XM_TABXML","ZBZ")
    
    Static oMonitor
    DEFINE MSDIALOG oMonitor TITLE "Grafico" FROM 0,0  TO 600,900 COLORS 0, 16777215 PIXEL 
    oScroll := TScrollArea():New(oMonitor,01,01,500,800)
    oScroll:Align := CONTROL_ALIGN_ALLCLIENT    
    
    Grafico(oScroll,nGrafico)
    
    oMenu := TBar():New( oMonitor, 48, 48, .T., , ,"CONTEUDO_BODY-FUNDO", .T. )
    DEFINE BUTTON RESOURCE "FW_PIECHART_1"        OF oMenu  ACTION Grafico(oScroll,PIECHART)     PROMPT " "   TOOLTIP "Pizza"            
    DEFINE BUTTON RESOURCE "FW_LINECHART_1"       OF oMenu  ACTION Grafico(oScroll,LINECHART)    PROMPT " "   TOOLTIP "Linha"            
    DEFINE BUTTON RESOURCE "FW_BARCHART_1"        OF oMenu  ACTION Grafico(oScroll,BARCHART)     PROMPT " "   TOOLTIP "Barra"            
    DEFINE BUTTON RESOURCE "FW_BARCOMPCHART_2"    OF oMenu  ACTION Grafico(oScroll,BARCOMPCHART) PROMPT " "   TOOLTIP "Barra"            
    
    ACTIVATE MSDIALOG oMonitor CENTERED

Return


Static Function Grafico(oScroll,nGrafico)

    Local oChart
    Local cQuery:= ""
    
    If Valtype(oChart) == "O"

        FreeObj(@oChart) //Usando a função FreeObj liberamos o objeto para ser recriado novamente, gerando um novo gráfico

    Endif
    
    oChart := FWChartFactory():New()
    oChart := oChart:getInstance( nGrafico ) 
    oChart:init( oScroll )
    oChart:SetTitle("Quant. XML por tipos", CONTROL_ALIGN_CENTER)
    //oChart:SetMask( "R$ *@*")
    //oChart:SetPicture("@E 999,999,999.99")
    oChart:setColor("Random") //Deixamos o protheus definir as cores do gráfico

    If nGrafico == PIECHART //se o gráfico tipo pizza, deixamos a legenda no rodapé
        oChart:SetLegend( CONTROL_ALIGN_BOTTOM )
    Endif   

    oChart:nTAlign := CONTROL_ALIGN_ALLCLIENT

    //Uma consulta bem Simples
    cQuery := " select DISTINCT ZBZ_MODELO, Count(ZBZ_MODELO) AS QUANT FROM " + RETSQLNAME(xZBZ) + " ZBZ "
    cQuery += " WHERE "+xZBZ+".D_E_L_E_T_ = '' AND "+xZBZ+"_MODELO <> '' "
    cQuery += " GROUP BY ZBZ_MODELO "

    If ( SELECT("TRBACD") ) > 0
        dbSelectArea("TRBACD")
        TRBACD->(dbCloseArea())
    EndIf

    TcQuery cQuery Alias "TRBACD" New

    TRBACD->(dbGoTop())

    //Se a série for unica o tipo de variável deve ser NUMÉRICO Ex.: (cTitle, 10)
    //Se for multi série o tipo de variável deve ser Array de numéricos Ex.: (cTitle, {10,20,30} )
    If TRBACD->( !EOF() )

        While TRBACD->( !EOF() )

            if nGrafico == LINECHART .OR. nGrafico == BARCOMPCHART 
                //Neste dois tipos de graficos temos:
                //(Titulo, {{ Descrição, Valor }})
                Do Case 
                    Case TRBACD->ZBZ_MODELO == "55"
                        oChart:addSerie( "NFE" , {{ "NFE" , TRBACD->QUANT }} )
                    Case TRBACD->ZBZ_MODELO == "57"
                        oChart:addSerie( "CTE" , {{ "CTE" , TRBACD->QUANT }}  )
                    Case TRBACD->ZBZ_MODELO == "65"
                        oChart:addSerie( "NFCE" , {{ "NFCE" , TRBACD->QUANT }}  )
                    Case TRBACD->ZBZ_MODELO == "RP"
                        oChart:addSerie( "NFSE" , {{ "NFSE" , TRBACD->QUANT }} )
                    Case TRBACD->ZBZ_MODELO == "67"
                        oChart:addSerie( "CTEOS" , {{ "CTEOS" , TRBACD->QUANT }} )
                EndCase
                
            Else
                //Aqui temos:
                //(Titulo, Valor)
                 Do Case 
                    Case TRBACD->ZBZ_MODELO == "55"
                        oChart:addSerie( "NFE" , TRBACD->QUANT )
                    Case TRBACD->ZBZ_MODELO == "57"
                        oChart:addSerie( "CTE" ,  TRBACD->QUANT )
                    Case TRBACD->ZBZ_MODELO == "65"
                        oChart:addSerie( "NFCE" , TRBACD->QUANT )
                    Case TRBACD->ZBZ_MODELO == "RP"
                        oChart:addSerie( "NFSE" , TRBACD->QUANT )
                    Case TRBACD->ZBZ_MODELO == "67"
                        oChart:addSerie( "CTEOS" , TRBACD->QUANT )
                EndCase

            Endif

            TRBACD->(dbSkip())

        End

        oChart:build()

    Endif
    
Return
