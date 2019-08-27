
#include "FiveWin.ch"

//----------------------------------------------------------------------------//

CLASS TFsdi FROM TDialog
   DATA nGridBottom, nGridRight
   CLASSDATA lRegistered AS LOGICAL

   METHOD New( oWnd, lPixels ) CONSTRUCTOR
   METHOD NewGrid()
   METHOD AdjClient() // INLINE oApp():oWndMain:AdjClient()
	METHOD NewSplitter()
ENDCLASS

//----------------------------------------------------------------------------//

METHOD New( oWnd ) CLASS TFsdi
   local   aClient
   default oWnd    := oApp():oWndMain // GetWndDefault()
   aClient := GetClientRect (oWnd:hWnd )
   ::oWnd = oWnd

   ::nTop    := oApp():oToolBar:nHeight + 4
   ::nLeft   := 0
   ::nBottom := aClient[3] - 8 // oApp():oWndMain:oMsgBar:nHeight
   ::nRight  := aClient[4]
   ::nStyle  := nOR( WS_CHILD, 4 )
   ::SetFont(oApp():oFont)
   ::lHelpIcon    := .f.

   ::lTransparent := .f.
   ::nGridBottom  := (::nBottom / 2) - oApp():oToolBar:nHeight
   ::nGridRight   := (::nRight / 2 )
   ::aControls    := {}

   ::SetColor( CLR_WHITE, GetSysColor(15) ) 
   ::Register( nOr( CS_VREDRAW, CS_HREDRAW ) )

   SetWndDefault( Self )          //  Set Default DEFINEd Window

return Self

//----------------------------------------------------------------------------//

METHOD NewGrid( nSplit ) CLASS TFsdi

   oApp():oGrid := TXBrowse():New( oApp():oDlg )
   oApp():oGrid:nTop    := 00
   oApp():oGrid:nLeft   := nSplit+2
   oApp():oGrid:nBottom := oApp():oDlg:nGridBottom
   oApp():oGrid:nRight  := oApp():oDlg:nGridRight

   // Ut_BrwRowConfig( oApp():oGrid )

return nil

METHOD AdjClient() CLASS TFsdi
return nil
//_____________________________________________________________________________//

METHOD NewSplitter( nSplit, oCont, oBar )
   oApp():oSplit := TSplitter():New(00,nSplit,(.not..F.) .or. .T.,{oCont,oBar},.not..F.,;
                                    {oApp():oGrid,oApp():oTab},.not..F.,,,;
                                    oApp():oDlg,,1,oApp():oDlg:nGridBottom + oApp():oTab:nHeight,;
                                    .T.,.T.,,.F.,.T. )

RETURN NIL
