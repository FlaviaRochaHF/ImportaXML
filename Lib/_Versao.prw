#INCLUDE 'PROTHEUS.CH'

User Function _Versao()

	Local cTitle
	Local cRpoVersion
	Local nVarNameLen
	
	//Local lExecute		:= Empty( ProcName(1) )

	BEGIN SEQUENCE

 /*		IF !( lExecute )
			MsgAlert( "Invalid Function Call: " + ProcName() , "Bye Bye" )
			BREAK
 		EndIF  */

		cTitle		:= "Titulo"
		cRpoVersion	:= GetSrvProfString("RpoVersion","")
		nVarNameLen	:= SetVarNameLen( 50 )			//Redefino para poder usar Nomes Longos


		//PTInternal(1,cTitle)
		Conout(cTitle)

		IF ( cRpoVersion == "110" )
			MsgInfo("110")	//TOTVS 11
		ElseIF ( cRpoVersion == "120" )
			MsgInfo("120")	//TOTVS 12
		EndIF	
	
		SetVarNameLen( nVarNameLen )						//Restauro o Padrao

		__Quit()

	END SEQUENCE

Return( .T. )
