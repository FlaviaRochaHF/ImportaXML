#include 'protheus.ch'
#include 'totvs.ch'
#include 'colors.ch'
#include 'FWPrintSetup.ch'
#include 'RWMAKE.ch'
#include "RPTDEF.CH"
#include "restful.ch"

//-------------------------------------------------------------------------//
//04/11/2022: Erick Gonçalves, Lucas San, Rafael Tavares
//            Fonte: Contato com suporte via Protheus.
//-------------------------------------------------------------------------//

/*Projeto - Menu Suporte Gestão XML
Escopo: Ter um botão que abra uma pagina na Web que permita contato direto com Suporte.
Abrir canais de contato:

Whatsapp
Google Meet
Microsoft Teams
E-mail
Abertura de chamados SGS.


Caso seja renovação de licença, customização ou melhoria encaminhar diretamente ao analista comercial.
Permitindo com que o usuário escolha o analista comercial responsável.
Marcha nos projeto, fellas*/

User Function HFXMLSUP()

// Alinhamento do método addInLayout
#define LAYOUT_ALIGN_LEFT     1
#define LAYOUT_ALIGN_RIGHT    2
#define LAYOUT_ALIGN_HCENTER  4
#define LAYOUT_ALIGN_TOP      32
#define LAYOUT_ALIGN_BOTTOM   64
#define LAYOUT_ALIGN_VCENTER  128

// Alinhamento para preenchimento dos componentes no TLinearLayout
#define LAYOUT_LINEAR_L2R 0 // LEFT TO RIGHT
#define LAYOUT_LINEAR_R2L 1 // RIGHT TO LEFT
#define LAYOUT_LINEAR_T2B 2 // TOP TO BOTTOM
#define LAYOUT_LINEAR_B2T 3 // BOTTOM TO 

/***************************************************************************************************/
Local aLink := {"https://extranet.helpfacil.com.br/",;    // Portal SGS
                "https://helponline.importaxml.com.br/",; // Help Online
                "https://www.youtube.com/@Helpfacil",;    // Canal do Youtube: HF Consulting
                "https://www.hfbr.com.br/wp-content/uploads/2019/11/institutional_video.mp4"} // Video da HFBR
/***************************************************************************************************/
Local aLogos:= {"https://extranet.helpfacil.com.br/Image/logoCliente.png",; // Portal SGS
                "https://www.deviante.com.br/wp-content/uploads/2016/05/WhatsApp_face.jpg",; // Whatsapp
                "https://helponline.importaxml.com.br/wp-content/uploads/2021/08/imagem-rodape-Help-300x122.png",; // Help Online
                "https://play-lh.googleusercontent.com/vA4tG0v4aasE7oIvRIvTkOYTwom07DfqHdUPr6k7jmrDwy_qA_SonqZkw6KX0OXKAdk",; // Youtube
                "https://support.content.office.net/pt-br/media/90ef4f4e-4910-440d-a274-445b9c86f22c.png",; // Email
                "https://helponline.importaxml.com.br/wp-content/uploads/2021/08/banner.png"} // Gestão XML - Banner
/***************************************************************************************************/
Local aTemp := {GetTempPath() + "HF_PortalSGS.png",;
                GetTempPath() + "HF_Whatsapp.jpg",;
                GetTempPath() + "HF_HelpOnline.png",;
                GetTempPath() + "HF_Youtube.png",;
                GetTempPath() + "HF_Email.png",;
                GetTempPath() + "HF_GestaoXml.png"}
/***************************************************************************************************/
Local cStyle      := "QFrame{ border-radius: 15px; border-color:#FF0000; background-color:#0A728C }"
Local cStyle2     := "QFrame{ border-radius: 15px; border-color:#000000; background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #ffffff, stop: 1 #b4b4b4); } }"
Local cStyle3     := "QFrame{ border-radius: 15px; border-color:#000000; background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #0a728c, stop: 1 #04b6d8); } }"
Local aScreenRes  := getScreenRes()
Private cNomeUser := UsrFullName()
Private dDtAtual  := Date()
Private dDateDiffDay := (dVencLic,dDtAtual)
Private oPanel
Private oPanel1
Private oPanel2
Private oPanel3
Private oPanel4
Private aSizeAut  := {}
aSizeAut := MsAdvSize(,.F.,400)
Private aSize  	  := {{134,304,35,155,35,113,51,85},;  // Tamanho 1
				  	         {134,450,35,155,35,185,51} ,;     // Tamanho 2
					           {227,450,35,210,65,185,99}}       // Tamanho 3
Private oDlg      := Nil AS Object
Private oScr      := Nil AS Object
Private oGrp1     := Nil AS Object
Private oGet01    := Nil AS Object
Private oGet02    := Nil AS Object
Private oCombo01  := Nil AS Object
Private cCombo01  := 'S' AS character
Private cGet02    := "3"
Private oWebChannel := TWebChannel():New()

cNomeUser := substr(cUsuario,7,15)

// Erick Gonçalves - 27/12/2022
// Verifica se já existe um arquivo com o nome da logo, caso não tenha é criado automáticamente.
If !File(aTemp[1]) // Portal SGS
  MemoWrite(aTemp[1], HttpGet(aLogos[1]))
Endif

If !File(aTemp[2]) // Whatsapp
  MemoWrite(aTemp[2], HttpGet(aLogos[2]))
EndIf

If !File(aTemp[3]) // Help Online
  MemoWrite(aTemp[3], HttpGet(aLogos[3]))
EndIf

If !File(aTemp[4]) // Youtube
  MemoWrite(aTemp[4], HttpGet(aLogos[4]))
EndIf

If !File(aTemp[5]) // E-mail
  MemoWrite(aTemp[5], HttpGet(aLogos[5]))
EndIf

If !File(aTemp[6]) // Gestão XML
  MemoWrite(aTemp[6], HttpGet(aLogos[6]))
EndIf

#DEFINE DS_MODALFRAME 128
DEFINE MSDIALOG oDlg FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] TITLE "Gestão XML - Suporte HF" Of oMainWnd PIXEL //Style DS_MODALFRAME

  // Cria Fonte para visualização
  oTFont := TFont():New('Copperplate',,-16,.T.)

  //aScreen é um array que prepara a tela para diferentes tipos de resoluções de tela.
  If aScreenRes[1] == 1366 .And. aScreenRes[2] == 768

    // Banner do Gestão XML
    TBitmap():New( 03,140,538,150,,aTemp[6],.F.,oDlg,,,.F.,.T.,,"",.T.,,.T.,,.F. )

    // Marcação menu
    oPanel := TPanelCss():New(03,03,nil,oDlg,nil,nil,nil,nil,nil,132,290,nil,nil)
    oPanel:setCSS(cStyle3)

		oGrp1 := TGroup():New(155,140,290,677,"Feed de Notícias:",oDlg, CLR_HBLUE, CLR_WHITE, .T., .F.) // Borda principal

    oTButton01 := TButton():New( 10,8, "PORTAL" + CHR(13)+CHR(10) + "DE" + CHR(13)+CHR(10 ) + "CHAMADOS" ,oDlg,{|| ShellExecute("OPEN", aLink[1],"","",1)}, 121,030,,,.F.,.T.,.F.,,.F.,,,.F. )
    oTButton01:SetCSS( getCSS(cStyle))

    oTButton02 := TButton():New( 45, 8, 'WHATSAPP',oDlg, { || WPPTELA()  }, 121, 020, , , .F., .T., .F., , .F., , , .F. )
    //oTButton01:SetCSS( getCSS('TBUTTON_01'))
    //oTButton02:SetCss("QPushButton{ background-image: url(rpo:HF_Youtube.png);background-size: contain; width: 100%; height: 38em; background-repeat: none; border: 1px solid ; margin: 3px ;background-position: center} ")

    oTButton03 := TButton():New( 70, 8, "HELP ONLINE" ,oDlg,{|| ShellExecute("OPEN", aLink[2],"","",1)}, 121,020,,,.F.,.T.,.F.,,.F.,,,.F. )
    oTButton03:SetCSS( getCSS(cStyle))

    oTButton04 := TButton():New( 95, 8, "YOUTUBE" ,oDlg,{|| ShellExecute("OPEN", aLink[3],"","",1)}, 121,020,,,.F.,.T.,.F.,,.F.,,,.F. )
    oTButton04:SetCSS( getCSS(cStyle))

    oTButton05 := TButton():New( 122, 8, "E-MAIL" ,oDlg,{|| ShellExecute("open","mailto:gestaoxml@hfbr.com.br","","",3)}, 121,020,,,.F.,.T.,.F.,,.F.,,,.F. )
    oTButton05:SetCSS( getCSS(cStyle2))

    oTButton06 := TButton():New( 146, 8, "Visite o nosso Site!" ,oDlg,{|| HTMLGET() }, 121,020,,,.F.,.T.,.F.,,.F.,,,.F. )
    oTButton06:setCSS(cStyle)
    
    oTButton07 := TButton():New( 172, 145, "API" ,oDlg,{|| U_ApiAdvpl() }, 121,020,,,.F.,.T.,.F.,,.F.,,,.F. )
    oTButton07:setCSS(cStyle)

    oTButton08 := TButton():New( 200, 145, "Projeto API REST" ,oDlg,{|| U_CadSA1() }, 121,020,,,.F.,.T.,.F.,,.F.,,,.F. )
    oTButton08:setCSS(cStyle)

    oPanel2 := TPanelCss():New(169,7,nil,oDlg,nil,nil,nil,nil,nil,121,100,nil,nil)
    oPanel2:setCSS(cStyle2)

    oTSay := TSay():New( 172, 2,{||"Olá, " + AllTrim(cNomeUser)  + "!"},oDlg,,oTFont,.T.,.F.,.F.,.T.,0,,125,020,.F.,.T.,.F.,.F.,.F.,.F. )   
    oTSay := TSay():New( 179, 1,{||"  A licença expira em: " + cValToChar(dVencLic)},oDlg,,oTFont,.T.,.F.,.F.,.T.,0,,125,060,.F.,.T.,.F.,.F.,.F.,.F. )  
    oTSay := TSay():New( 229, 3,{||"Faltam " + cValtoChar( DateDiffDay( dVencLic, dDtAtual )) + " dias para expirar a licença do Gestão XML." },oDlg,,oTFont,.T.,.F.,.F.,.T.,0,,125,030,.F.,.T.,.F.,.F.,.F.,.F. )   

    oTButton07 := TButton():New( 271, 8, "Solicitar Licença do Gestão XML" ,oDlg,{|| EnvMail() }, 121,020,,,.F.,.T.,.F.,,.F.,,,.F. )
    oTButton07:setCSS(cStyle)

  Elseif aScreenRes[1] == 1920 .And. aScreenRes[2] == 1080 // <-- Televisão - Resolução maior que 1366x768 (Tamanho de monitor padrão).

    // Marcação menu
    oPanel := TPanelCss():New(03,03,nil,oDlg,nil,nil,nil,nil,nil,132,451,nil,nil)
    oPanel:setCSS(cStyle3)
    //New(ALTURA,ESQUERDA,FINAL,DIREITA)
		oGrp1 := TGroup():New(155,140,451,950,"Feed de Notícias",oDlg, CLR_HBLUE, CLR_WHITE, .T., .F.) // Borda principal

    oTSay := TSay():New(170, 120,{||"Feed de Notícias:"},oDlg,,oTFont,.T.,.F.,.F.,.T.,0,,190,20,.F.,.T.,.F.,.F.,.F.,.F. )

    oTButton02 := TButton():New( 10, 8, 'Whatsapp',oDlg, { || WPPTELA()  }, 121, 020, , , .F., .T., .F., , .F., , , .F. )
    oTButton02:SetCSS( getCSS(cStyle))
    
    // Banner do Gestão XML
    TBitmap():New( 1,140,810,150,,aTemp[6],.F.,oDlg,,,.F.,.T.,,"",.T.,,.T.,,.F. )

    oTButton07 := TButton():New( 172, 145, "API" ,oDlg,{|| U_ApiAdvpl() }, 121,020,,,.F.,.T.,.F.,,.F.,,,.F. )
    oTButton07:setCSS(cStyle)
    
  Else

    TBitmap():New( 04,105,400,125,,aTemp[6],.F.,oDlg,,,.F.,.T.,,"",.T.,,.T.,,.F. )

    oPanel := TPanelCss():New(03,03,nil,oDlg,nil,nil,nil,nil,nil,100,290,nil,nil)
    oPanel:setCSS(cStyle3)

		oGrp1 := TGroup():New(131,105,291,505,"Feed de Notícias:",oDlg, CLR_HBLUE, CLR_WHITE, .T., .F.) // Borda principal

  EndIf

oDlg:Activate(,,,.T.)

Return


Static Function WPPTELA() // LUCAS SAN 15/12/2022 -> Tela para selecionar o contato desejado.

Local aContatos         := {}
Local aLink := {"https://api.whatsapp.com/send?phone=5511989271152",; // Lucas Santana
                "https://api.whatsapp.com/send?phone=5511963248407",; // Erick Gonçalves
                "https://api.whatsapp.com/send?phone=5511960231467",; // Rafael Tavares
                "https://api.whatsapp.com/send?phone=5511989222212",; // Rogerio Lino
                "https://api.whatsapp.com/send?phone=5511975391132"}  // Heverton Marcondes} 
/***************************************************************************************************/
Local oDlg := Nil AS Object
Local oWPP := Nil AS Object
Local cWPP :=''
Local nOpc := ''

aAdd( aContatos, "1= Lucas Santana")
aAdd( aContatos, "2= Erick Gonçalves")
aAdd( aContatos, "3= Rafael Tavares")
aAdd( aContatos, "4= Rogério Lino")
aAdd( aContatos, "5= Heverton (NFSE)")

#DEFINE DS_MODALFRAME 128
DEFINE MSDIALOG oDlg TITLE "Contatos Suporte" Of oMainWnd FROM 0,0 TO 130,250 PIXEL Style DS_MODALFRAME // Altura e Largura

@ 010,010 Say "Selecione o Suporte desejado:"  PIXEL OF oDlg 
@ 020,010 COMBOBOX oWPP VAR cWPP ITEMS aContatos SIZE 100,10 PIXEL OF oDlg 
@ 040, 010 BUTTON oButton1 PROMPT "Confirmar" SIZE 037, 012 OF oDlg PIXEL ACTION ( nOpc := 1, oDlg:End() )  
@ 040, 060 BUTTON oButton1 PROMPT "Cancelar" SIZE 037, 012 OF oDlg PIXEL ACTION ( nOpc := 0, oDlg:End() ) 

oDlg:lEscClose := .F. // Impossibilita a saida pelo ESC.
oDlg:Activate(,,,.T.)

If nOpc==1
  cLink := aLink[Val(cWPP)]
  ShellExecute("OPEN", cLink,"","",1)
Elseif nOpc == 0
  return
Endif

Static Function getCSS( cClass )
  Local cCSS        := '' as character
  Default cClass    := ''

  If cClass == 'TBUTTON_01'
    cCSS   += "QPushButton { color: white }"
    cCSS   += "QPushButton { font-weight: bolder }"
    cCSS   += "QPushButton { border: none }"
    cCSS   += "QPushButton { background-color: blue }"
    cCSS   += "QPushButton { border-radius: 8px }"
    cCSS   += "QPushButton { outline: none; }"
    cCSS   += "QPushButton { box-shadow: 5px 5px 10px #5a5a5a, -5px -5px 10px #ffffff; }"
  
  elseif cClass == 'TGET_01'
    cCSS   += "QLineEdit { font-size: 15px }"
    cCSS   += "QLineEdit { border-radius: 8px }"
    cCSS   += "QLineEdit { border: none } "
    cCSS   += "QLineEdit { background-color: #fff } "
    cCSS   += "QLineEdit:disabled{ background-color: #CACFD2 }"

  elseif cClass == 'MENU_01'
      cCSS   += "QFrame { border-radius: 15px; }"
      cCSS   += "QFrame { border-color:#FF0000; }"
      cCSS   += "QFrame { background-color:#CACFD2; }"
  endif
Return( cCSS )

/*±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Lucas Santana - 15/12/2022 - º±±±±º Envio e Recebimento da Licença. º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±*/	
*****************************************************************************************************
Static Function EnvMail(cMailServer,cLogin,cMailConta,cMailSenha,lSMTPAuth,lSSL,cProtocolE,cPortEnv) 
*****************************************************************************************************

aSmtp       := U_XCfgMail(1,1,{})
	
  oMailServer := Nil
	oLogin      := Nil
	oMailConta  := Nil
	oMailSenha  := Nil
	oSMTPAuth   := Nil
	oSSL        := Nil
	oTLS        := Nil   //aquuiiiiiii
  
	cMailServer := aSmtp[1] //Padr(GetNewPar("XM_SMTP",Space(40)),40)
	cLogin      := aSmtp[2] //Padr(GetNewPar("XM_LOGIN",Space(40)),40)
	cMailConta  := aSmtp[3] //Padr(GetNewPar("XM_ACCOUNT",Space(40)),40)
	cMailSenha  := aSmtp[4] //Padr(Decode64(GetNewPar("XM_PASS",Space(25))),25)
	lSMTPAuth   := aSmtp[5] //GetNewPar("XM_AUT",Space(1))=="S"
	lSSL        := aSmtp[6] //GetNewPar("XM_SSL",Space(1))=="S"                                     
	cProtocolE  := aSmtp[7] //GetNewPar("XM_PROTENV","0")
	cPortEnv    := aSmtp[8] //GetNewPar("XM_ENVPORT","0")
	lTLS        := aSmtp[9] //GetNewPar("XM_TLS",Space(1))=="S"                 //aquuiiiiii
Local oDlg    := NIL
Local oMsg
Local nReq    := GetNewPar("XM_REQMAIL")
//Local nHora   := Time()

Private cTitulo  := "Solicitação de Licença"
Private cServer  := cMailServer
Private cEmail   := cMailConta
Private cPass    := cMailSenha

Private cDe      := cMailConta
Private cPara    := "nfe_teste@hfbr.com.br" // Space(200)
Private cCc      := "" //Space(200)
Private cAssunto := "Renovação de Licença" // Space(200)
Private cAnexo   := Space(200)
Private cMsg     := ""
//Private cEmp	   := (xSM0)->(FieldGet(FieldPos(xSM0_+"NOMECOM")))	//Lucas San 08/09/2022]
//Static nReq      := GetNewPar("XM_REQMAIL")     

If Date() <= dVencLic

 	nDaysLeft := (dVencLic -Date())
			
  If nDaysLeft >= 30
  Else 
    MsgStop("A data para solicitar a licença ainda não está disponível (30 dias).","Atenção")
    Return
  Endif

Endif

If nReq <= 2 // Erick Gonçalves / 29/12 -> Verifica se a quantidade de requisição do envio é menor que 2.

  cMsg := "Este e-mail é enviado pelo Gestão XML para renovação de licença."+CRLF
  //cMsg := "Empresa : "+SM0->NOMECOM+CRLF
  cMsg += "Data : "+Dtoc(dDataBase)+CRLF 
  cMsg += "Hora : "+Time()+CRLF      
  cMsg += "Usuario : "+Substr(cUsuario,7,15)+CRLF  
                                           
  DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO 350,570 OF oDlg PIXEL

    @  3,3 SAY "De"   SIZE 30,7 PIXEL OF oDlg
    @ 15,3 SAY "Para" SIZE 30,7 PIXEL OF oDlg
    @ 27,3 SAY "Cc"       SIZE 30,7 PIXEL OF oDlg
    @ 39,3 SAY "Assunto"  SIZE 30,7 PIXEL OF oDlg
    @ 51,3 SAY "Anexo"    SIZE 30,7 PIXEL OF oDlg
    @ 63,3 SAY "Mensagem" SIZE 30,7 PIXEL OF oDlg

    @  2, 35 MSGET cDe      PICTURE "@" When .F. SIZE 248, 7 PIXEL OF oDlg READONLY
    @ 14, 35 MSGET cPara    PICTURE "@" When .F. SIZE 248, 7 PIXEL OF oDlg 
    @ 26, 35 MSGET cCc      PICTURE "@" When .T. SIZE 248, 8 PIXEL OF oDlg
    @ 38, 35 MSGET cAssunto PICTURE "@" When .F. SIZE 248, 8 PIXEL OF oDlg
    @ 50, 35 MSGET cAnexo   PICTURE "@" When .F. SIZE 233, 8 PIXEL OF oDlg
    //@ 49,269 BUTTON "..." SIZE 13,11 PIXEL OF oDlg ACTION cAnexo:=AllTrim(cGetFile(cMask,"Inserir anexo"))
    @ 62, 35 GET oMsg VAR cMsg MEMO SIZE 248,93 PIXEL OF oDlg 

    @ 160,210 BUTTON "&Enviar"    SIZE 36,13 PIXEL ACTION (lOpc:=Validar(),Iif(lOpc,Eval({||SendMail(cDe,cPara,cCc,cAssunto,cMsg,cAnexo),oDlg:End()}),NIL),nReq += 1)
    @ 160,248 BUTTON "&Abandonar" SIZE 36,13 PIXEL ACTION oDlg:End()

  ACTIVATE MSDIALOG oDlg CENTERED

      // Atualizando o parâmetro com o saldo de requisições. - Erick Gonçalves - 27/12/2022
    If !PutMv("XM_REQMAIL", nReq ) 
		    RecLock("SX6",.T.)
		    SX6->X6_FIL     := xFilial("SX6")
		    SX6->X6_VAR     := "XM_REQMAIL"
		    SX6->X6_TIPO    := "N"
		    SX6->X6_DESCRIC := "Quantidade de Requisição máxima por E-mail"
		    MsUnLock()
		    PutMv("XM_REQMAIL", nReq ) 
	  EndIf

Elseif nReq >= 3

  MsgStop("O limite de requisição por dia foi atingido. Por favor, aguarde um dia para solicitar novamente.","Controle de Requisição",oTFont)

  Return

EndIf

//LUCAS SAN -> 15/12/2022 Executa função de E-mail para enviar mensagem por e-mail solicitando renovação de licença.
*************************************************************
Static Function SendMail(cDe,cPara,cCc,cAssunto,cMsg,cAnexo)
	*************************************************************
	Local nret   := 0
	Local cError := ""
//Local cRet   := ""

	aTo := Separa(cPara,";")
//    MsgRun("Testanto envio...","E-mail / SMTP",{|| nRet:= 	U_HX_MAIL(aTo,cAssunto,cMsg,@cError,cAnexo,cAnexo,cPara,cCc) })                              
	MsgRun("Enviando...","E-mail / SMTP",{|| nRet:= 	U_MAILSEND(aTo,cAssunto,cMsg,@cError,cAnexo,cAnexo,cPara,cCc) })

	If nRet == 0 .And. Empty(cError)
		U_MyAviso("Aviso","E-mail enviado com sucesso!",{"OK"})
	Else
		cError += U_MailErro(nRet)
		U_MyAviso("Aviso",cError,{"OK"},3)
	EndIf

Return(nret)

//*************************
Static Function Validar()
//*************************
	Local lRet := .T.
	If Empty(cDe)
		MsgInfo("Campo 'De' preenchimento obrigatório",cTitulo)
		lRet:=.F.
	Endif
	If Empty(cPara) .And. lRet
		MsgInfo("Campo 'Para' preenchimento obrigatório",cTitulo)
		lRet:=.F.
	Endif
	If Empty(cAssunto) .And. lRet
		MsgInfo("Campo 'Assunto' preenchimento obrigatório",cTitulo)
		lRet:=.F.
	Endif

	If lRet
		cDe      := AllTrim(cDe)
		cPara    := AllTrim(cPara)
		cCC      := AllTrim(cCC)
		cAssunto := AllTrim(cAssunto)
		cAnexo   := AllTrim(cAnexo)
	Endif

RETURN(lRet)
