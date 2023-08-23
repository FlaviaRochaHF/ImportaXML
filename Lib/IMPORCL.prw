#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOPCONN.CH'

user function _HFXMLIMP()
       Local _cTitulo :='Importação do XML'
       Local _cTexto  :='Deseja realmete importar os xml para banco ORACLE?'
       Local _aBotoes :={"Importar", "Sair"}
       Local _opc     := 0
       
       _opc := AVISO(_cTitulo, _cTexto, _aBotoes, 1)
       
       If _opc == 1
       			Processa({|| U__IMPOCLE()},"Exportando para o Banco.....","Por favor aguarde o termino da operação.",.T.)
       EndIf		
return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³_IMPOCLE ³ Autor ³ Alexandro de Oliveira  ³ Data ³10.03.2015  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ (HF) Função aonde é importado os dados para banco ORACLE     ³±±
±±           ³ esta função rodara em um schedule (Via Job)                  ³±±
±±           ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function _IMPOCLE()
       Local cQuery 	:= ''
       Local cSql 		:= ''
       Local cString 	:= 'ZBZ'
       Local nCont	 	:= 0
       
       // Neste momento seleciona area eu adiciono a cQuery
       dbSelectArea(cString)

       cQuery :="SELECT"
       cQuery +=" * "  
       cQuery +=" FROM "+RetSqlName("ZBZ")+ " AS ZBZ " 
       cQuery +=" WHERE ZBZ.D_E_L_E_T_= '' " 
       cQuery +=" AND ZBZ.ZBZ_EXP = '' " 
       cQuery +=" ORDER BY ZBZ_NOTA "

       //Aqui a query é gerada e jogada nesta tabela temporaria de nome CONCLI
       TCQUERY cQuery New Alias("ZBZCOPY")
       
       
       //Abro a tabela temporaria CONCLI
       dbSelectArea("ZBZCOPY")
       dbGoTop()
       //Inclui uma regua aonde passo por parametro.
       ProcRegua(nCont)
       While !EOF()
       
             cSql := "INSERT INTO DADOSADV11.dbo.EXPORTACAO (ZBZ_FILIAL, ZBZ_MODELO,"
             cSql += " ZBZ_UF, ZBZ_SERIE, ZBZ_NOTA, ZBZ_DTNFE, ZBZ_PROT,"
             cSql += " ZBZ_PRENF, ZBZ_CNPJ, ZBZ_FORNEC, ZBZ_CNPJD, ZBZ_CLIENT, "
             cSql += " ZBZ_CHAVE)"
             cSql += " VALUES ('"+ZBZCOPY->ZBZ_FILIAL+"', '"+ZBZCOPY->ZBZ_MODELO+"', '"+ZBZCOPY->ZBZ_UF+"', "
             cSql += " '"+ZBZCOPY->ZBZ_SERIE+"', '"+ZBZCOPY->ZBZ_NOTA+"', '"+ZBZCOPY->ZBZ_DTNFE+"', "
             cSql += " '"+ZBZCOPY->ZBZ_PROT+"', '"+ZBZCOPY->ZBZ_PRENF+"', '"+ZBZCOPY->ZBZ_CNPJ+"', "
             cSql += " '"+ZBZCOPY->ZBZ_FORNEC+"', '"+ZBZCOPY->ZBZ_CNPJD+"', '"+ZBZCOPY->ZBZ_CLIENT+"', '"+ZBZCOPY->ZBZ_CHAVE+"') "
             //cSql += " '"+ZBZCOPY->ZBZ_XML+"', '"+ZBZCOPY->ZBZ_DTRECB+"', '"+ZBZCOPY->ZBZ_DTHRCS+"', '"+ZBZCOPY->ZBZ_DTHRUC+"', '"+ZBZCOPY->CODFOR+"')" 
   
             _nResult := TcSqlExec(cSql)
   
             dbSelectArea("ZBZ" )
             ZBZ->( dbGoTo( ZBZCOPY->R_E_C_N_O_ ) )
             RecLock( "ZBZ", .F. )
             	ZBZ->ZBZ_EXP := "S"
             ZBZ->( MSUNLOCK() ) 
             
             nCont++
             IncProc("Processando aguarde....")

             dbSelectArea("ZBZCOPY")
             dbSkip() // Avanca o ponteiro do registro no arquivo
       EndDo

Return
