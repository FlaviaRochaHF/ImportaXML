#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � XMLPEITE �Autor  �                    � Data �  26/07/13   ���
�������������������������������������������������������������������������͹��
���Desc.     � Deve devolver uma matriz com os campos da SD1 a Incluir no ���
���          � aItens.                                                    ���
���          � Recebe: paramixb onde:                                     ���
���          � 1 - C�digo do produto interno, ja convertido pelo DePara   ���
���          � 2 - oDet - Objeto de Itens do XML                          ���
���          � 3 - i    - indice do Objeto oDet do produto atual          ���
���          � Para checar existencia de TAGs utilizar a vari�vel oXml    ���
���          � Como Privare temos o aCabec, que podemos incluir algum     ���
���          � campo no cabe�alho da NF                                   ���
�������������������������������������������������������������������������͹��
��� Uso      �Exemplo de Ponto de Entrada Incluir campos no aItens do SD1.���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
USer Function XMLPEITE()
Local _aArea := GetArea()
Local _aRet  := {}                  //devolver esta matriz
Local _cProduto := paramixb[1]      //produto
//Local _oDet     := paramixb[2]      //Objeto do XML
//Local _i        := paramixb[3]      //Item corrente
//Local _cVal     := ""
//Local _nPos     := 0   
//Local _cDesc    := ""

if cModelo == "55" //cModelo Vem do Importa XML

	dbSelectArea("SB1")
	if SB1->( dbSeek( xFilial("SB1") + _cProduto ) )
		aadd(_aRet,{"D1_XDESCRI"	,SB1->B1_DESC     	,Nil})
	endif

Endif
 
RestArea( _aArea )
Return( _aRet )





/*Static Function _VerIcms( _aRet, _i )
Local _nBase    := 0
Local _nAliq    := 0
Local _nVIcm    := 0
Local _lSN      := .F.
Local _nCST     := 0
Local _aCST     := {"00","10","20","30","40","41","50","51","60","70","90"}
Local nLenOri   := 1

if Type("oOri") == "A"
	nLenOri   :=  Len(oOri)
Endif

Private cTagAux, nValAux := 0

//nBunit := Round( ( nBaseCTE / Len(oOri) ), 2 )
cTagAux   := "oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMSSN:_INDSN:TEXT"
if Type(cTagAux) <> "U"
	nValAux := 12  //Conforme Chamado
	If nValAux > 0
		_nAliq := nValAux
		_nBase := Round( ( nTotXml / nLenOri ), 2 )
		_nVIcm := (_nBase*(_nAliq/100))
		aadd(_aRet,{"D1_PICM"	,_nAliq             	,Nil})
		aadd(_aRet,{"D1_BASEICM",_nBase          		,Nil})
		aadd(_aRet,{"D1_VALICM"	,_nVIcm					,Nil})
		_lSN   := .T.
	EndIf
EndIF

If ! _lSN
	For _nCST := 1 To Len( _aCST )

		cTagAux   := "oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS"+_aCST[_nCST]+":_PICMS:TEXT"
		if Type(cTagAux) <> "U"
			nValAux := Val( &(cTagAux) )
			If nValAux > 0
				_nAliq := nValAux
				aadd(_aRet,{"D1_PICM"	,_nAliq             	,Nil})
			EndIf
		Endif
		cTagAux   := "oXml:_CTEPROC:_CTE:_INFCTE:_IMP:_ICMS:_ICMS"+_aCST[_nCST]+":_VBC:TEXT"
		if Type(cTagAux) <> "U"
			nValAux := Val( &(cTagAux) )
			If nValAux > 0
				_nBase := Round( ( nValAux / nLenOri ), 2 )
				_nVIcm := (_nBase*(_nAliq/100))
				aadd(_aRet,{"D1_BASEICM",_nBase          		,Nil})
				aadd(_aRet,{"D1_VALICM"	,_nVIcm					,Nil})
			EndIf
		EndIf
		if _nAliq > 0 .And. _nBase > 0
			Exit
		endif
	Next _nCST
EndIf

Return( _aRet )
*/