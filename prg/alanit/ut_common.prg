// *
// PROYECTO ...: Hemerot
// COPYRIGHT ..: (c) alanit software
// URL ........: www.alanit.com
// *

#include "Fivewin.ch"
#include "Report.ch"
#include "DbStruct.ch"
#include "sayref.ch"

/*_____________________________________________________________________________*/

FUNCTION SetIni( cIni, cSection, cEntry, xVar )

   LOCAL oIni

   DEFAULT cIni := oApp():cInifile

   INI oIni FILE cIni
   SET SECTION cSection ;
      ENTRY cEntry      ;
      TO xVar           ;
      OF oIni
   ENDINI

   RETURN NIL

/*_____________________________________________________________________________*/

FUNCTION GetIni( cIni, cSection, cEntry, xdefault )

   LOCAL oIni
   LOCAL xVar := xdefault

   DEFAULT cIni := oApp():cInifile

   INI oIni FILE cIni
   GET xVar            ;
      SECTION cSection ;
      ENTRY cEntry     ;
      DEFAULT xdefault ;
      OF oIni
   ENDINI

   RETURN xVar

/*_____________________________________________________________________________*/

FUNCTION GoWeb( cUrl )

   cUrl := AllTrim( cUrl )
   IF cURL == ""
      MsgStop( "La dirección web está vacia." )
      RETURN NIL
   ENDIF

   IF ! IsWinNt()
      WinExec( "start urlto:" + cURL, 0 )
   ELSE
      WinExec( "rundll32.exe url.dll,FileProtocolHandler " + cURL )
   ENDIF

   RETURN NIL

/*_____________________________________________________________________________*/

FUNCTION GoMail( cMail )

   cMail := AllTrim( cMail )
   IF cMail == ""
      MsgStop( "La dirección de e-mail está vacia." )
      RETURN NIL
   ENDIF

   IF ! IsWinNt()
      WinExec( "start mailto: " + cMail, 0 )
   ELSE
      WinExec( "rundll32.exe url.dll,FileProtocolHandler mailto:" + cMail )
   ENDIF

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION GoFile( cFile )

   cFile := AllTrim( cFile )
   IF cFile == ""
      MsgStop( "La ruta del fichero está vacia." )
      RETURN NIL
   ENDIF

   WinExec( "rundll32.exe url.dll,FileProtocolHandler " + cFile )
   // if ! IsWinNt()
   // WinExec( "start mailto: " + cMail, 0 )
   // else
   // WinExec( "rundll32.exe url.dll,FileProtocolHandler mailto:" + cMail )
   // endif

   RETURN NIL

/*_____________________________________________________________________________*/

FUNCTION ValEmpty( cDato, oGet )

   IF Empty( cDato )
      MsgStop( i18n( "Es obligatorio rellenar este campo." ) )
      oGet:setFocus()
      RETURN .F.
   END IF

   RETURN .T.

/*_____________________________________________________________________________*/
/*
function JustifPaintLines( oReport )

   local nLDcha := 19

   // 1ª linea horizontal
   oReport:Line(4.5                ,;     // nTop
                1.5                ,;     // nLeft
                4.5                ,;     // nBottom
                nLDcha             ,;     // nRight
                1                  ,;     // first pen created
                RPT_CMETERS)

   // 2ª linea horizontal
   oReport:Line(8.8                ,;     // nTop
                1.5                ,;     // nLeft
                8.8                ,;     // nBottom
                nLDcha             ,;     // nRight
                1                  ,;     // first pen created
                RPT_CMETERS)

   // 3ª linea horizontal
   oReport:Line(25.8               ,;     // nTop
                1.5                ,;     // nLeft
                25.8               ,;     // nBottom
                nLDcha             ,;     // nRight
                1                  ,;     // first pen created
                RPT_CMETERS)

   // linea vertical izquierda
   oReport:Line(4.5                ,;     // nTop
                1.5                ,;     // nLeft
                25.8               ,;     // nBottom
                1.5                ,;     // nRight
                1                  ,;     // first pen created
                RPT_CMETERS)

   // linea vertical derecha
   oReport:Line(4.5                ,;     // nTop
                nLDcha             ,;     // nRight
                25.8               ,;     // nBottom
                nLDcha             ,;     // nRight
                1                  ,;     // first pen created
                RPT_CMETERS)

return nil
*/
/*_____________________________________________________________________________*/

FUNCTION DlgCoors( oWnd )

   LOCAL aCoor[ 7 ]

   aCoor[ 1 ] := 2 * GetSysMetrics( 4 ) + ;  // SM_CYCAPTION
   GetSysMetrics( 15 )  + ;  // SM_CYMENU
   2 * GetSysMetrics( 6 ) + ;  // SM_CYBORDER
   oWnd:oBar:nHeight  + ;
      oWnd:oMsgBar:nHeight ;
      + 10                    // factor de corrección puesto a ojo

   aCoor[ 2 ] := 2 * GetSysMetrics( 5 )   ;  // SM_CXBORDER
   + 12                    // igual que antes

   aCoor[ 3 ] := GetSysMetrics( 4 )  + ;   // SM_CYCAPTION
   GetSysMetrics( 15 ) + ;   // SM_CYMENU
   2 * GetSysMetrics( 6 ) + ;   // SM_CYBORDER
   oWnd:oBar:nHeight

   aCoor[ 4 ] := 0
   aCoor[ 5 ] := 0
   aCoor[ 6 ] := oWnd:nHeight() - aCoor[ 1 ]
   aCoor[ 7 ] := oWnd:nWidth()  - aCoor[ 2 ]

   RETURN aCoor

/*_____________________________________________________________________________*/

FUNCTION O2A( cCadena ) ; RETURN OemToAnsi( cCadena )

/*_____________________________________________________________________________*/

FUNCTION DlgCenter( oDlg, oWnd )

   oDlg:Center( oWnd )

   RETURN NIL

/*_____________________________________________________________________________*/

FUNCTION SwapUpArray( aArray, nPos )

   LOCAL uTmp

   DEFAULT nPos   := Len( aArray )

   IF nPos <= Len( aArray ) .AND. nPos > 1
      uTmp              := aArray[ nPos ]
      aArray[ nPos ]      := aArray[ nPos - 1 ]
      aArray[ nPos - 1 ] := uTmp
   END IF

   RETURN NIL

/*_____________________________________________________________________________*/

FUNCTION SwapDwArray( aArray, nPos )

   LOCAL uTmp

   DEFAULT nPos   := Len( aArray )

   IF nPos < Len( aArray ) .AND. nPos > 0
      uTmp              := aArray[ nPos ]
      aArray[ nPos ]      := aArray[ nPos + 1 ]
      aArray[ nPos + 1 ] := uTmp
   END IF

   RETURN NIL

/*_____________________________________________________________________________*/

FUNCTION FindRec( cAlias, cData, cOrder )

   LOCAL nOrder := ( cAlias )->( ordNumber() )
   LOCAL nRecno := ( cAlias )->( RecNo()     )
   LOCAL lFind  := .F.

   ( cAlias )->( ordSetFocus( cOrder ) )

   IF ( cAlias )->( dbSeek( Upper( cData ) ) )
      lFind := .T.
   END IF

   ( cAlias )->( dbSetOrder( nOrder ) )
   ( cAlias )->( dbGoto( nRecno )     )

   RETURN lFind

/*_____________________________________________________________________________*/

FUNCTION bTitulo( aTitulos, nFor )
   RETURN {|| aTitulos[ nFor ] }

FUNCTION bCampo( aCampos, nFor )
   RETURN ( FieldWBlock( aCampos[ nFor ], Select() ) )

FUNCTION bPicture( aPicture, nFor )
   RETURN aPicture[ nFor ]

FUNCTION bArray( aArray, aCampos, nFor )

   LOCAL nIndex

   nIndex := Eval( bCampo( aCampos, nFor ) )

   RETURN aArray[ Val( nIndex ) ]

/*_____________________________________________________________________________*/

FUNCTION aGetFont( oWnd )

   LOCAL aFont    := {}
   LOCAL hDC      := GetDC( oWnd:hWnd )
   LOCAL nCounter := 0

   IF hDC != 0

      WHILE ( Empty( aFont := GetFontNames( hDC ) ) ) .AND. ( ++nCounter ) < 5
      END WHILE

      IF Empty( aFont )
         msgAlert( i18n( "Error al obtener las fuentes." ) + CRLF + ;
            i18n( "Sólo podrá usar las fuentes predefinidas." ) )
      ELSE
         ASort( aFont,,, {|x, y| Upper( x ) < Upper( y ) } )
      ENDIF

   ELSE

      msgAlert( i18n( "Error al procesar el manejador de la ventana." ) + CRLF + ;
         i18n( "Sólo podrá usar las fuentes predefinidas." ) )

   ENDIF

   ReleaseDC( oWnd:hWnd, hDC )

   RETURN aFont

/*
function aGetFont( oWnd )

   local aFont := {}
   local hDC := oWnd:GetDC() // GetDC( oWnd:hWnd ) // 0 //oWnd:GetDC() // GetDC( oWnd:hWnd ) //

   if hDC > 0
      aFont := GetFontNames( hDC )
      if Empty( aFont )
         MsgAlert( "Error al obtener las fuentes."+CRLF+"Sólo podrá usar las fuentes predefinidas." )
      else
         aSort( aFont,,, { |x, y| upper( x ) < upper( y ) } )
      endif
   else
      MsgAlert( "Error al procesar el manejador de la ventana."+CRLF+"Sólo podrá usar las fuentes predefinidas." )
   end if
   ReleaseDC( 0, hDC ) // oWnd:ReleaseDC()

return ( aFont )
*/
/*_____________________________________________________________________________*/

FUNCTION FillCmb( cAlias, cTag, aCmb, cField, nOrd, nRec, cVar )

   DEFAULT nOrd := ( cAlias )->( ordNumber() ), ;
      nRec := ( cAlias )->( RecNo() )

   ( cAlias )->( ordSetFocus( cTag ) )
   ( cAlias )->( dbGoTop() )
   DO WHILE ! ( cAlias )->( Eof() )
      AAdd( aCmb, ( cAlias )->&cField )
      ( cAlias )->( dbSkip() )
   END WHILE
   ( cAlias )->( dbSetOrder( nOrd ) )
   ( cAlias )->( dbGoto( nRec ) )
   cVar := iif( Len( aCmb ) > 0, aCmb[ 1 ], "" )

   RETURN NIL

/*_____________________________________________________________________________*/

FUNCTION GetFieldWidth( cAlias, cField )

   LOCAL aDbf := ( cAlias )->( dbStruct() )
   LOCAL i    := 0
   LOCAL nLen := Len( aDbf )
   LOCAL nPos := 0

   // encuentro la posición del campo a partir del nombre
   FOR i := 1 TO nLen
      IF aDbf[ i, 1 ] == cField
         nPos := i
         EXIT
      ENDIF
   NEXT

   // devuelvo el ancho del campo

   RETURN ( cAlias )->( dbFieldInfo( DBS_LEN, nPos ) )

/*_____________________________________________________________________________*/

FUNCTION GetDir( oGet )

   LOCAL cFile

   cFile := cGetDir(, oApp():cExePath )

   IF ! Empty( cFile )
      oGet:cText := cFile + "\"
   ENDIF

   RETURN NIL

/*_____________________________________________________________________________*/

FUNCTION RefreshCont( oCont, cAlias )

   oCont:cTitle :=  tran( ( cAlias )->( ordKeyNo() ), '@E 999,999' ) + " / " + tran( ( cAlias )->( ordKeyCount() ), '@E 999,999' )
   oCont:refresh()

   RETURN NIL

/*_____________________________________________________________________________*/

FUNCTION aScanN( aArray, xExpr )

   LOCAL nFound := 0
   LOCAL i      := 0
   LOCAL nLen   := Len( aArray )

   IF nLen > 0
      FOR i := 1 TO nLen
         IF aArray[ i ] == xExpr
            nFound++
         ENDIF
      NEXT
   ENDIF

   RETURN nFound

/*_____________________________________________________________________________*/

FUNCTION GetNewCod( lFromBtn, cAlias, cField, cGet )

   LOCAL nOrd      := ( cAlias )->( ordNumber() )
   LOCAL nRec      := ( cAlias )->( RecNo() )
   LOCAL nCod      := 0
   LOCAL cMsgAlert := ""

   ( cAlias )->( ordSetFocus( "codigo" ) )
   ( cAlias )->( dbGoBottom() )

   IF Val( ( cAlias )->&cField ) != 0
      // su último registro es numérico (y distinto de cero)
      nCod := Val( ( cAlias )->&cField ) + 1
      cGet := StrZero( nCod, 10 )
   ELSE
      IF ( cAlias )->&cField == "0000000000" .OR. Empty( ( cAlias )->&cField )
         // su último registro vale 0 o está en blanco porque estás añadiendo el 1º registro de la tabla [estás viendo el dbAppend()]
         cGet := "0000000001"
      ELSE
         // su último registro contiene letras
         cMsgAlert := i18n( "Es imposible incrementar automáticamente el código porque no está siguiendo un patrón numérico." )
         IF !lFromBtn
            cMsgAlert += i18n( " Si no desea que el programa lo intente generar, desactive la opción desde el panel de configuración." )
         ENDIF
         msgAlert( cMsgAlert )
      ENDIF
   ENDIF

   ( cAlias )->( ordSetFocus( nOrd ) )
   ( cAlias )->( dbGoto( nRec ) )

   RETURN NIL

/*_____________________________________________________________________________*/

FUNCTION GetFreeSystemResources() ; RETURN 0

FUNCTION nPtrWord() ; RETURN 0

/*_____________________________________________________________________________*/
/*
function ChangeFolder( oFld )

   local i         := 0
   local nOption   := oFld:nLastOption // data añadida en Folder.prg
   local nCtrls    := len( oFld:aDialogs[nOption]:aControls )
   local oCtrl
   local bOldValid := { || nil }

   FOR i := 1 TO nCtrls
      oCtrl := oFld:aDialogs[nOption]:aControls[i]
      if oCtrl:ClassName() == "TBMPGET" .OR. oCtrl:ClassName() == "TGET"
         if oCtrl:bValid != nil
            if ! eval( oCtrl:bValid )
               bOldValid    := oCtrl:bValid
               oCtrl:bValid := nil
               oFld:setOption( nOption )
               oCtrl:bValid := bOldValid
               sysrefresh()
               oCtrl:setFocus()
               EXIT
            endif
         endif
      endif
   NEXT

return nil
*/

/*_____________________________________________________________________________*/

FUNCTION CheckGets( aGet, oFld )

   LOCAL i       := 0
   LOCAL nGets   := Len( aGet )
   LOCAL oCtrl
   LOCAL oDlg
   LOCAL lreturn := .T.
   LOCAL nFldOpt := 0

   /* La DATA Cargo de los BMPGETs contiene el nº de diálogo del folder que lo contiene,
      y es asignada desde el método ::setNumFolder() añadido a TFolder */

   FOR i := 1 TO nGets
      oCtrl := aGet[ i ]
      IF oCtrl:ClassName() == "TBMPGET"
         IF oCtrl:bValid != nil
            IF !Eval( oCtrl:bValid )
               IF oCtrl:oWnd:oWnd == oFld
                  oDlg := oCtrl:oWnd
                  oFld:setOption( oCtrl:Cargo )
               ENDIF
               oCtrl:setFocus()
               lreturn := .F.
               EXIT
            ENDIF
         ENDIF
      ENDIF
   NEXT

   RETURN lreturn

/*_____________________________________________________________________________*/

#define IS_NOT_LOGICAL(x)            (VALTYPE(x) != "L")
#define MAKE_UPPER(x)                (x := UPPER(x))

FUNCTION FT_NOOCCUR( cCheckFor, cCheckIn, lIgnoreCase )

   // Is Case Important??
   IF ( IS_NOT_LOGICAL( lIgnoreCase ) .OR. lIgnoreCase )

      MAKE_UPPER( cCheckFor )             // No, Force Everything to Uppercase
      MAKE_UPPER( cCheckIn )

   ENDIF                                // IS_NOT_LOGICAL(lIgnoreCase) or ;
   // lIgnoreCase

   RETURN ( if( Len( cCheckFor ) == 0 .OR. Len( cCheckIn ) == 0, ;
      0, ;
      Int( ( Len( cCheckIn ) - Len( StrTran( cCheckIn, cCheckFor ) ) ) / ;
      Len( cCheckFor ) ) ) )

/*_____________________________________________________________________________*/

FUNCTION AdjustWnd( oBtn, nWidth, nHeight )

   LOCAL nMaxWidth, nMaxHeight
   LOCAL aPoint

   aPoint := { oBtn:nTop + oBtn:nHeight(), oBtn:nLeft }
   clientToScreen( oBtn:oWnd:hWnd, @aPoint )

   nMaxWidth  := GetSysMetrics( 0 )
   nMaxHeight := GetSysMetrics( 1 )

   IF  aPoint[ 2 ] + nWidth > nMaxWidth
      aPoint[ 2 ] := nMaxWidth -  nWidth
   ENDIF

   IF  aPoint[ 1 ] + nHeight > nMaxHeight
      aPoint[ 1 ] := nMaxHeight - nHeight
   ENDIF

   RETURN aPoint


FUNCTION Registrame(lDirect) // CLASS TApplication

   LOCAL oDlg, oBmp, oTmr, oSay, oTel, oURL1, oURL2, cCfg, oBtn
   LOCAL lNext := .T.
   LOCAL nPaso := 11 // (-1)*GetDefaultFontHeight()-1

   IF Seconds() - oApp():nSeconds < 120 .AND. lDirect == NIL
      //? Seconds() - oApp():nSeconds
      RETU NIL
   ELSE
      oApp():nSeconds := Seconds()
   ENDIF

   define dialog oDlg title oApp():cAppName + oApp():cEdicion ; // OF oParent ;
   FROM  0, 0 TO 35 * nPaso, 390 PIXEL  ;
      COLOR CLR_BLACK, CLR_WHITE
   oDlg:SetFont( oApp():oFont )
   // oDlg:nStyle := nOr( WS_THICKFRAME, WS_POPUP )

   // oDLG:NSTYLE := nOR( DS_MODALFRAME,  ;
   // WS_MINIMIZEBOX        ,  ;
   // WS_VISIBLE, WS_CAPTION,  ;
   // WS_SYSMENU, WS_THICKFRAME, WS_MAXIMIZEBOX )

   @ 04, 36 BITMAP oBmp RESOURCE 'acercade' ;
      SIZE 110, 30 OF oDlg PIXEL NOBORDER // TRANSPAREN

   @ 40, 10 SAY oSay PROMPT "version " + oApp():cVersion + " " + oApp():cBuild + " " + oApp():cEdicion ;
      SIZE 174, 15 CENTERED PIXEL OF oDlg ;
      COLOR CLR_GRAY, CLR_WHITE

   @ 40 + nPaso - 2, 10 SAY oTel PROMPT ' © José Luis Sánchez Navarro 1996-2018 ' ;
      SIZE 174, 9 PIXEL CENTERED OF oDlg ;
      COLOR CLR_GRAY, CLR_WHITE

   @ 40 + 2 * nPaso, 10 SAY oSay PROMPT 'Está utilizando la edición gratuita del programa. Esta edición es completamente funcional por tiempo ilimitado, pero existe una edición registrada que incorpora las siguientes funcionalidades:';
      SIZE 174, 76 PIXEL OF oDlg ;
      CENTERED COLOR CLR_BLACK, CLR_WHITE

   @ 40 + 5.5 * nPaso, 10 SAY oSay PROMPT "* No aparece este recordatorio de registrar el programa" ;
      SIZE 174, 10 PIXEL CENTERED OF oDlg COLOR RGB( 204, 0, 0 ), CLR_WHITE // FONT oMs10Under
   @ 40 + 6.5 * nPaso, 10 SAY oSay PROMPT "* Nombre del usuario en todos los listados" ;
      SIZE 174, 10 PIXEL CENTERED OF oDlg  COLOR RGB( 204, 0, 0 ), CLR_WHITE // FONT oMs10Under
   @ 40 + 7.5 * nPaso, 10 SAY oSay PROMPT "* Soporte técnico preferente" ;
      SIZE 174, 18 PIXEL CENTERED OF oDlg COLOR  RGB( 204, 0, 0 ), CLR_WHITE // FONT oMs10Under

   @ 40 + 9 * nPaso, 10 SAY oSay PROMPT 'Si desea comprar la edición registrada del programa por sólo 20 € pulse sobre el siguiente enlace:';
      SIZE 174, 46 PIXEL CENTERED OF oDlg ;
      COLOR CLR_BLACK, CLR_WHITE

   @ 40 + 11 * nPaso, 10 SAYREF oURL2 PROMPT "http://www.alanit.com/comprar" ;
      SIZE 174, 14 PIXEL CENTERED OF oDlg     ;
      HREF "http://www.alanit.com/comprar"   ;
      COLOR RGB( 3, 95, 156 ), CLR_WHITE

   oUrl2:cTooltip  := 'registrar el programa por sólo 20 €'
   oUrl2:oFont  := oDlg:oFont

   // @ 40+13*nPaso,146 BUTTON oBtn PROMPT "Salir";
   // ACTION oDlg:End()             ;
   // SIZE 36,12 PIXEL OF oDlg WHEN .f.

   activate dialog oDlg ;
      ON INIT DlgCenter( oDlg, oApp():oWndMain ) ;
      ON PAINT ( SysWait( 9 ), oDlg:End() )
   // oMs10Under:End()

   RETURN NIL
