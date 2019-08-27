**
* PROYECTO ...: el Puchero
* COPYRIGHT ..: (c) alanit software
* URL ........: www.alanit.com
**

#include "Fivewin.ch"
#include "DbStruct.ch"
#include "xBrowse.ch"
#include "FileXLS.ch"

/*_____________________________________________________________________________*/

FUNCTION Ut_BrwColConfig( oBrowse, cIniEntry )

   LOCAL oDlg, oGet, oBtnShow, oBtnHide, oBtnUp, oBtnDown
   LOCAL nLen   := Len( oBrowse:aCols )
   LOCAL aHeader [ nLen ]
   LOCAL aShow   [ nlen ]
   LOCAL aSizes  [ nLen ]
	LOCAL aArray  [ nLen ]
   LOCAL hBmp   := LoadBitmap( 0, 32760 ) // MCS
   LOCAL oLbx
   LOCAL nShow  := 0
   LOCAL cState
   LOCAL n, i, oCol

   // Guardo posibles modificaciones manuales
   WritePProString("Browse",cIniEntry,oBrowse:SaveState(),oApp():cIniFile)
   cState := GetPvProfString("Browse", cIniEntry,"", oApp():cIniFile)

   FOR n := 1 TO nLen
      aHeader [ n ] := oBrowse:aCols[ n ]:cHeader
      aShow   [ n ] := ! oBrowse:aCols[ n ]:lHide
      aSizes  [ n ] := oBrowse:aCols[ n ]:nWidth
		aArray  [ n ] := {aShow[n],aHeader[n]}
   NEXT

   DEFINE DIALOG oDlg OF oApp():oWndMain RESOURCE "UT_BRWCONFIG_"+oApp():cLanguage
	oDlg:SetFont(oApp():oFont)

	oLbx := TXBrowse():New( oDlg )
	oLbx:SetArray(aArray)

	Ut_BrwRowConfig( oLbx )
   //oLbx:nMarqueeStyle       := MARQSTYLE_HIGHLROW
   //oLbx:nColDividerStyle    := LINESTYLE_LIGHTGRAY
   //oLbx:lColDividerComplete := .t.
   //oLbx:lRecordSelector     := .f.
	//oLbx:lHScroll				 := .f.
   //oLbx:nHeaderHeight       := 20
   //oLbx:nRowHeight          := 20
	//oLbx:lTransparent  	 	 := .T.
	//oLbx:l2007	 				 := .f.
   oLbx:nDataType 			 := 1 // array
	//oLbx:bChange				 := { || oGet:Refresh() }
	//oLbx:nStretchCol 			 := -1
	//oLbx:bClrStd   	   	 := {|| { CLR_BLACK, CLR_WHITE } }

   oLbx:aCols[1]:cHeader  := i18n("Ver")
   oLbx:aCols[1]:nWidth   := 24
  	oLbx:aCols[1]:AddResource("16_CHECK")
   oLbx:aCols[1]:AddResource(" ")
   oLbx:aCols[1]:bBmpData := { || if(aArray[oLbx:nArrayAt,1]==.t.,1,2)}
 	olbx:aCols[1]:bStrData := {|| NIL }

   oLbx:aCols[2]:cHeader  := i18n("Columna")
   oLbx:aCols[2]:nWidth   := 120

   FOR i := 1 TO LEN(oLbx:aCols)
      oCol := oLbx:aCols[ i ]
		oCol:bLDClickData  :=  { || IIF(aShow[ oLbx:nArrayAt ],oBtnHide:Click(),oBtnShow:Click()) }
      // oCol:bClrSelFocus  := { || { CLR_BLACK, oApp():nClrHL } }
      // oCol:bPaintText := { |oCol, hDC, cData, aRect | Ut_PaintColArray( oCol, hDC, cData, aRect ) }
    NEXT

	oLbx:CreateFromResource( 100 )

   REDEFINE GET oGet VAR aSizes[ oLbx:nArrayAt ] ;
      ID       101   ;
      SPINNER        ;
      MIN      1     ;
      MAX      999   ;
      PICTURE  "999" ;
      VALID    aSizes[ oLbx:nArrayAt ] > 0 ;
      OF       oDlg

   oGet:bLostFocus := { || ( oGet:SetColor( GetSysColor( 8 ), GetSysColor( 5 ) ) ,;
                             oBrowse:aCols[oLbx:nArrayAt]:nWidth := aSizes[ oLbx:nArrayAt ],;
                             oBrowse:Refresh( .t. ) ) }
   REDEFINE BUTTON ;
      ID       400 ;
      OF       oDlg ;
      ACTION   oDlg:end( IDOK )

   REDEFINE BUTTON ;
      ID       401 ;
      OF       oDlg ;
      ACTION   ( oBrowse:RestoreState( cState ), oDlg:end() )

   REDEFINE BUTTON oBtnShow ;
      ID       402          ;
      OF       oDlg         ;
      ACTION   ( aShow[ oLbx:nArrayAt ] := .t.,;
 					  oLbx:aArrayData[oLbx:nArrayAt,1] := .t., oLbx:Refresh(),;
                 oBrowse:aCols[ oLbx:nArrayAt ]:lHide := .f., oBrowse:Refresh( .t. ) )

   REDEFINE BUTTON oBtnHide ;
      ID       403          ;
      OF       oDlg         ;
      ACTION   IF(Len(oLbx:aArrayData)>1,;
                  ( aShow[ oLbx:nArrayAt ] := .f.,;
 						  oLbx:aArrayData[oLbx:nArrayAt,1] := .f., oLbx:Refresh(),;
                    oBrowse:aCols[ oLbx:nArrayAt ]:lHide := .t., oBrowse:Refresh( .t. ) ),;
                    msgAlert(i18n('No se puede ocultar la columna.'))   )

   REDEFINE BUTTON oBtnUp     ;
      ID       404            ;
      OF       oDlg           ;
      ACTION IIF( oLbx:nArrayAt > 1,;
                ( oBrowse:SwapCols( oBrowse:aCols[ oLbx:nArrayAt], oBrowse:aCols[ oLbx:nArrayAt - 1 ], .t. ),;
                  SwapUpArray( aHeader, oLbx:nArrayAt ) ,;
                  SwapUpArray( aShow  , oLbx:nArrayAt ) ,;
                  SwapUpArray( aSizes , oLbx:nArrayAt ) ,;
						SwapUpArray( aSizes , oLbx:nArrayAt ) ,;
                  SwapUpArray( oLbx:aArrayData, oLbx:nArrayAt ) ,;
						oLbx:nArrayAt --                      ,;
                  oLbx:Refresh()                   ),;
                MsgStop("No se puede desplazar la columna." ))

   REDEFINE BUTTON oBtnDown   ;
      ID       405            ;
      OF       oDlg           ;
      ACTION IIF( oLbx:nArrayAt < nLen,;
                ( oBrowse:SwapCols( oBrowse:aCols[ oLbx:nArrayAt], oBrowse:aCols[ oLbx:nArrayAt + 1 ], .t. ),;
                  SwapDwArray( aHeader, oLbx:nArrayAt ) ,;
                  SwapDwArray( aShow  , oLbx:nArrayAt ) ,;
                  SwapDwArray( aSizes , oLbx:nArrayAt ) ,;
                  SwapDwArray( oLbx:aArrayData, oLbx:nArrayAt ) ,;
                  oLbx:nArrayAt ++                      ,;
                  oLbx:Refresh()                   ),;
                MsgStop("No se puede desplazar la columna." ))

   ACTIVATE DIALOG oDlg ;
      ON INIT DlgCenter(oDlg,oApp():oWndMain)

return nil

/*_____________________________________________________________________________*/

function Ut_BrwRowConfig7( oBrw )

   oBrw:nRowSel      := 1
   oBrw:nColSel      := 1
   oBrw:nColOffset   := 1
   oBrw:nFreeze      := 0
   oBrw:nCaptured    := 0
   oBrw:nLastEditCol := 0

   oBrw:l2007          := .F.
   oBrw:lMultiselect        := .F.
   oBrw:lTransparent    := .F.
   oBrw:nMarqueeStyle       := MARQSTYLE_HIGHLWIN7
   oBrw:nStretchCol     := -1 // STRETCHCOL_LAST
   oBrw:bClrStd         := {|| { CLR_BLACK, CLR_WHITE } }
   oBrw:lColDividerComplete := .T.
   oBrw:lRecordSelector     := .T.
   oBrw:nColDividerStyle    := LINESTYLE_LIGHTGRAY
   oBrw:nHeaderHeight       := 24
   oBrw:nRowHeight          := 20
   oBrw:nMarqueeStyle       := MARQSTYLE_HIGHLWIN7  // MARQSTYLE_SOLIDCELL
   oBrw:nRowDividerStyle    := LINESTYLE_NOLINES

return nil

FUNCTION Ut_BrwRowConfig( oBrw )

oBrw:nRowSel      := 1
   oBrw:nColSel      := 1
   oBrw:nColOffset   := 1
   oBrw:nFreeze      := 0
   oBrw:nCaptured    := 0
   oBrw:nLastEditCol := 0
	oBrw:l2007	  	  			 := .f.
	oBrw:lMultiselect        := .f.
	oBrw:lTransparent 		 := .f.
	oBrw:nMarqueeStyle		 := MARQSTYLE_HIGHLROW
	// oBrw:nMarqueeStyle       := MARQSTYLE_HIGHLWIN7
	oBrw:nStretchCol 			 := 0 // -1 STRETCHCOL_LAST
   oBrw:bClrStd   	   	 := {|| { CLR_BLACK, CLR_WHITE } }
	oBrw:bClrRowFocus   	    := {|| { CLR_BLACK, oApp():nClrHL }} 
   oBrw:bClrSelFocus  		 := {|| { CLR_BLACK, oApp():nClrHL }} 
	oBrw:lColDividerComplete := .t.
   oBrw:lRecordSelector     := .t.
   oBrw:nColDividerStyle    := LINESTYLE_LIGHTGRAY
	oBrw:nRowDividerStyle    := LINESTYLE_LIGHTGRAY
	oBrw:nHeaderHeight       := 24
	oBrw:nRowHeight          := 22
   // oBrw:nRowDividerStyle    := LINESTYLE_NOLINES
	oBrw:lExcelCellWise		 := .f.

RETURN nil

/*_____________________________________________________________________________*/
function Ut_BrwRowConfig1( oBrw )
	oBrw:l2007	  	  			 := .f.
	oBrw:lMultiselect        := .f.
	oBrw:lTransparent 		 := .f.
	oBrw:nStretchCol 			 := -1 // STRETCHCOL_LAST
   oBrw:bClrStd   	   	 := {|| { CLR_BLACK, CLR_WHITE } }
   oBrw:lColDividerComplete := .t.
   oBrw:lRecordSelector     := .t.
   oBrw:nColDividerStyle    := LINESTYLE_LIGHTGRAY
	oBrw:nHeaderHeight       := 24
	oBrw:nRowHeight          := 20
   oBrw:nMarqueeStyle       := MARQSTYLE_HIGHLWIN7
   oBrw:nRowDividerStyle    := LINESTYLE_NOLINES
   oBrw:nRowDividerStyle	 := LINESTYLE_NOLINES
   oBrw:nColDividerStyle	 := LINESTYLE_LIGHTGRAY
	? 'Ut_BrwRowConfig'
return nil

/*_____________________________________________________________________________*/

function Ut_PaintCol( oCol, hDC, cData, aRect )

   if oCol:oBrw:VGetPos() == (oCol:oBrw:cAlias)->( OrdKeyNo() )
		if oCol:cDataType $ "CDN"
      	GradientFill( hDC, aRect[ 1 ] - 2, aRect[ 2 ] - 3, aRect[ 3 ] + 1, aRect[ 4 ] + 5,;
         	           { { 1, RGB( 220, 235, 252 ), RGB( 193, 219, 252 ) } }, .T. )
		endif
      RoundBox( hDC, 2, aRect[ 1 ] - 1, WndWidth( oCol:oBrw:hWnd ) - 22, aRect[ 3 ] + 1, 2, 2,;
                RGB( 235, 244, 253 ), 1 )
      RoundBox( hDC, 1, aRect[ 1 ] - 2, WndWidth( oCol:oBrw:hWnd ) - 21, aRect[ 3 ] + 2, 2, 2,;
                RGB( 125, 162, 206 ), 1 )
   endif
   SetTextColor( hDC, 0 )
	DrawTextEx( hDC, cData, aRect, oCol:nDataStyle )

return nil
/*_____________________________________________________________________________

function Ut_PaintColArray( oCol, hDC, cData, aRect )

   if oCol:oBrw:VGetPos() == (oCol:oBrw:nArrayAt)
      GradientFill( hDC, aRect[ 1 ] - 2, aRect[ 2 ] - 3, aRect[ 3 ] + 1, aRect[ 4 ] + 5,;
                    { { 1, RGB( 220, 235, 252 ), RGB( 193, 219, 252 ) } }, .T. )
      RoundBox( hDC, 2, aRect[ 1 ] - 1, WndWidth( oCol:oBrw:hWnd ) - 22, aRect[ 3 ] + 1, 2, 2,;
                RGB( 235, 244, 253 ), 1 )
      RoundBox( hDC, 1, aRect[ 1 ] - 2, WndWidth( oCol:oBrw:hWnd ) - 21, aRect[ 3 ] + 2, 2, 2,;
                RGB( 125, 162, 206 ), 1 )
   endif
   SetTextColor( hDC, 0 )
	DrawTextEx( hDC, cData, aRect, oCol:nDataStyle )

return nil
/*_____________________________________________________________________________

#pragma BEGINDUMP

#include <windows.h>
#include <hbapi.h>

HB_FUNC( ROUNDBOX )
{
   HDC hDC = ( HDC ) hb_parni( 1 );
   HBRUSH hBrush = ( HBRUSH ) GetStockObject( 5 );
   HBRUSH hOldBrush = ( HBRUSH ) SelectObject( hDC, hBrush );
   HPEN hPen, hOldPen ;

   if( hb_pcount() > 8 )
      hPen = CreatePen( PS_SOLID, hb_parnl( 9 ), ( COLORREF ) hb_parnl( 8 ) );
   else
      hPen = CreatePen( PS_SOLID, 1, ( COLORREF ) hb_parnl( 8 ) );

   hOldPen = ( HPEN ) SelectObject( hDC, hPen );
   hb_retl( RoundRect( hDC ,
                                 hb_parni( 2 ),
                                 hb_parni( 3 ),
                                 hb_parni( 4 ),
                                 hb_parni( 5 ),
                                 hb_parni( 6 ),
                                 hb_parni( 7 ) ) );

   SelectObject( hDC, hOldBrush );
   DeleteObject( hBrush );
   SelectObject( hDC, hOldPen );
   DeleteObject( hPen );
}

#pragma ENDDUMP

/*_____________________________________________________________________________*/

function Ut_ExportXLS( oBrw, cTitle )
   Local oXLS, nFormat1, nFormat2, nLen, nCol, nFila, x, cText, cValor
	local cAlias := oBrw:cAlias
	local cFile := oApp():cXlsPath+cTitle+".xls"
	local nRecno := (cAlias)->(Recno())

	if oApp():lExcel == .f.
   	XLS oXLS FILE &cFile AUTOEXEC
   	    DEFINE XLS FORMAT nFormat1 PICTURE '#.##0,00'
   	    DEFINE XLS FORMAT nFormat2 PICTURE '#0'

   	    // @ 1,1 XLS SAY oApp():oDlg:cTitle OF oXls
   	    // @ 1,8 XLS SAY "Fecha:" + DTOC( Date() ) OF oXls

   	    // CABECERAS
   	    nLen  := len( oBrw:aCols )
   	    nCol  := 1
   	    nFila := 1
   	    for x := 1 to nLen
   	        if !oBrw:aCols[x]:lHide  // Si la columna no es oculta
   	           cValor := oBrw:aCols[x]:cHeader
   	           XLS COL nCol WIDTH oBrw:aCols[x]:nDataLen OF oXLS
   	           @ nFila,nCol XLS SAY cValor OF oXls
   	           nCol++  // Las columnas solo las que estan visibles
   	        endif
   	    next

   	    nCol  := 1
   	    nFila++   // Una fila despues del Header

   	     // DATOS
   	     DbSelectArea( cAlias )
   	     (cAlias)->(DbGoTop())  // oDbf:GoTop()
   	     while ! (cAlias)->(EoF())  //oDbf:Eof()
   	           for x := 1 to nLen
   	               if !oBrw:aCols[x]:lHide  // Si la columna no es oculta
   	                   cText := oBrw:aCols[x]:Value()
   	                   if Valtype( cText ) = "N" // Si es numeric
   	                     if oBrw:aCols[x]:nDataDec = 0
   	                        @ nFila, nCol XLS SAY cText FORMAT nFormat2 OF oXls
   	                     else
   	                        @ nFila, nCol XLS SAY cText FORMAT nFormat1 OF oXls
   	                     endif
   	                   elseif Valtype( cText ) = "D"
   	                      @ nFila, nCol XLS SAY DtoC( cText )  OF oXls
   	                   elseif Valtype( cText ) = "L"
   	                      @ nFila, nCol XLS SAY cText OF oXls
   	                   elseif Valtype( cText ) == "U"
									 @ nFila, nCol XLS SAY oBrw:aCols[x]:Cargo OF oXls
   	                   else
   	                      @ nFila, nCol XLS SAY Rtrim(cText) OF oXls
   	                   endif
   	                   nCol++  // Las columnas solo las que estan visibles
   	               endif
   	           next
   	          nFila++
   	          nCol := 1
   	          (cAlias)->(DbSkip())// oDbf:Skip()
   	     end While
			  (cAlias)->(DbGoTo(nRecno))
   	ENDXLS oXLS
	else
		// oApp():oGrid:lExcelCellwise := .t.
 		// oApp():oGrid:ToExcel()
		oBrw:ToExcel()
	endif
return nil