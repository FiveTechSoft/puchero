#include "FiveWin.ch"
#include "Report.ch"
#include "vmenu.ch"
#include "treeview.ch"
#include "splitter.ch"

STATIC oReport

FUNCTION Francesa()

   LOCAL oBar, oSay, oCont, oLink, xPrompt
   LOCAL aBrowse, oImageList
   LOCAL nOrder := Max( Val( GetPvProfString( "Browse", "FrOrder", "1", oApp():cInifile ) ), 1 )
   LOCAL nSplit := Val( GetPvProfString( "Browse", "FrSplit", "102", oApp():cInifile ) )
   LOCAL nRecTab
   IF oApp():oDlg != nil
      IF oApp():nEdit > 0
         // MsgStop('Por favor, finalice la edición del registro actual.')
         RETURN NIL
      ELSE
         oApp():oDlg:End()
         SysRefresh()
      ENDIF
   ENDIF

   IF ! Db_OpenAll()
      RETURN NIL
   ENDIF
   SELECT FR
   oApp():oDlg := TFsdi():New( oApp():oWndMain )
   oApp():oDlg:cTitle := i18n( 'Clasificación francesa' )
   oApp():oWndMain:oClient := oApp():oDlg

   oImageList := TImageList():New()
   oImageList:Add( TBitmap():Define( "16_RAMA",, oApp():oDlg ), TBitmap():Define( "16_RAMA",, oApp():oDlg ) )
   oImageList:Add( TBitmap():Define( "16_HOJA",, oApp():oDlg ), TBitmap():Define( "16_HOJA",, oApp():oDlg ) )

   oApp():oTree := TTreeView():New( 0, nSplit + 2, oApp():oDlg,,, .T. )// ,oApp():oDlg:nWidth()/2,(oApp():oDlg:nHeight()-22)/2)
   oApp():oTree:SetColor( CLR_BLACK, CLR_WHITE )
   oApp():oTree:bChanged := {|| ( xPrompt := oApp():oTree:GetSelected():Cargo, ;
      FR->( dbSeek( Upper( xPrompt ) ) ),;
      RefreshCont( oCont, "FR" ) ) }
   oApp():oTree:bKeyDown := {| nKey| FrTecla( nKey, oApp():oTree, oCont, oApp():oDlg ) }
   // oApp():oTree:SetImageList( oImageList )

   @ 02, 05 VMENU oCont SIZE nSplit - 10, 18 OF oApp():oDlg  ;
      COLOR CLR_BLACK, GetSysColor( 15 )       ;
      FILLED   ;
      COLORSELECT 0, CLR_WHITE ;
      HEIGHT ITEM 22

   FR->( dbGoTop() )
   DEFINE TITLE OF oCont ;
      CAPTION tran( FR->( ordKeyNo() ), '@E 999,999' ) + " / " + tran( FR->( ordKeyCount() ), '@E 999,999' ) ;// strZero( RE->( ordKeyCount() ), 6 ) ;
   HEIGHT 25 ;
      COLOR GetSysColor( 9 ), oApp():nClrBar ;
      IMAGE "BB_MATER2"

   @ 24, 05 VMENU oBar SIZE nSplit - 10, 125 OF oApp():oDlg  ;
      COLOR CLR_BLACK, GetSysColor( 15 )       ;
      HEIGHT ITEM 22 XBOX
   oBar:nClrBox := Min( GetSysColor( 13 ), GetSysColor( 14 ) )

   DEFINE TITLE OF oBar                      ;
      CAPTION "Clasificación francesa"       ;
      HEIGHT 24                              ;
      COLOR GetSysColor( 9 ), oApp():nClrBar ;
      OPENCLOSE

   DEFINE VMENUITEM OF oBar         ;
      CAPTION "Nueva rama"          ;
      IMAGE "16_RAMA"               ;
      ACTION FrEdita( oApp():oTree, 1, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar         ;
      CAPTION "Nueva hoja"          ;
      IMAGE "16_HOJA"               ;
      ACTION FrEdita( oApp():oTree, 2, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar         ;
      CAPTION "Modificar"           ;
      IMAGE "16_MODIF"              ;
      ACTION FrEdita( oApp():oTree, 3, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar         ;
      CAPTION "Borrar"              ;
      IMAGE "16_BORRAR"             ;
      ACTION FrBorra( oApp():oTree, oCont );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Buscar"             ;
      IMAGE "16_BUSCA"             ;
      ACTION FrBusca( oApp():oTree,, oApp():oDlg,, )   ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Imprimir"           ;
      IMAGE "16_IMPRIMIR"          ;
      ACTION FrImprime( oApp():oDlg, oApp():oTree )     ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Ver recetas"        ;
      IMAGE "16_RECETAS"        ;
      ACTION FrEjemplares( oApp():oTree, oApp():oDlg ) ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Salir"              ;
      IMAGE "16_SALIR"             ;
      ACTION oApp():oDlg:End()              ;
      LEFT 10

   @ oApp():oDlg:nGridBottom, nSplit + 2 TABS oApp():oTab ;
      OPTION nOrder SIZE oApp():oWndMain:nWidth() -80, 12 PIXEL OF oApp():oDlg ;
      ITEMS ' Clasificación '

   oApp():oDlg:NewSplitter( nSplit, oCont, oBar )

   ACTIVATE DIALOG oApp():oDlg NOWAIT ;
      ON INIT ( FrTreeLoad( oApp():oTree ), oApp():oTree:SetImageList( oImageList ), oApp():oTree:ExpandAll(), ;
      ResizeWndMain(), oApp():oTree:SetFocus() ) ;
      VALID ( WritePProString( "Browse", "FrOrder", LTrim( Str( FR->( ordNumber() ) ) ), oApp():cInifile ), ;
      WritePProString( "Browse", "FrSplit", LTrim( Str( oApp():oSplit:nleft / 2 ) ), oApp():cInifile ),;
      oBar:End(), dbCloseAll(), oApp():oDlg := NIL, oApp():oTree := NIL, oApp():oTab := NIL, oImageList:End(), .T. )

   RETURN NIL

/*_____________________________________________________________________________*/
FUNCTION FrTreeLoad( oTree )

   LOCAL oLink1, oLink2, oLink3, oLink4, oLink5
   LOCAL xPrompt

   SELECT FR
   FR->( ordSetFocus( 1 ) )
   FR->( dbGoTop() )
   DO WHILE ! FR->( Eof() )
      xPrompt := Str( FR->Frn1, 2 ) + Str( FR->Frn2, 2 ) + Str( FR->Frn3, 2 ) + Str( FR->Frn4, 2 ) + Str( FR->Frn5, 2 )
      IF FR->FrN2 == 0
         oLink1 := oTree:Add( FR->FrTipo, iif( FR->FrHoja, 1, 0 ) )
         oLink1:Cargo := xPrompt
      ELSEIF FR->FrN3 == 0
         oLink2 := oLink1:Add( FR->FrTipo, iif( FR->FrHoja, 1, 0 ) )
         oLink2:Cargo := Str( FR->Frn1, 2 ) + Str( FR->Frn2, 2 ) + Str( FR->Frn3, 2 ) + Str( FR->Frn4, 2 ) + Str( FR->Frn5, 2 )
      ELSEIF FR->FrN4 == 0
         oLink3 := oLink2:Add( FR->FrTipo, iif( FR->FrHoja, 1, 0 ) )
         oLink3:Cargo := Str( FR->Frn1, 2 ) + Str( FR->Frn2, 2 ) + Str( FR->Frn3, 2 ) + Str( FR->Frn4, 2 ) + Str( FR->Frn5, 2 )
      ELSEIF FR->FrN5 == 0
         oLink4 := oLink3:Add( FR->FrTipo, iif( FR->FrHoja, 1, 0 ) )
         oLink4:Cargo := Str( FR->Frn1, 2 ) + Str( FR->Frn2, 2 ) + Str( FR->Frn3, 2 ) + Str( FR->Frn4, 2 ) + Str( FR->Frn5, 2 )
      ELSE
         oLink5 := oLink4:Add( FR->FrTipo, iif( FR->FrHoja, 1, 0 ) )
         oLink5:Cargo := Str( FR->Frn1, 2 ) + Str( FR->Frn2, 2 ) + Str( FR->Frn3, 2 ) + Str( FR->Frn4, 2 ) + Str( FR->Frn5, 2 )
      ENDIF
      FR->( dbSkip() )
   ENDDO

   RETURN NIL

/*_____________________________________________________________________________*/

FUNCTION FrClickTree( oTree )

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION FrEdita( oTree, nMode, oCont, oDlgParent )

   // nMode 1 añadir rama, 2 añadir hoja, 3 modificar
   LOCAL oDlg
   LOCAL aTitle   := { i18n( "Añadir rama " ),;
      i18n( "Añadir hoja " ),;
      i18n( "Modificar denominación" ) }
   LOCAL aGet[ 1 ]
   LOCAL cFaTipo
   LOCAL oLink       := oTree:GetSelected()
   LOCAL cPrompt     := oLink:cPrompt
   LOCAL oParent
   LOCAL cCargo      := oLink:Cargo
   LOCAL nLevel      := Int( At( " 0", cCargo ) / 2 )
   LOCAL lFrHoja
   LOCAL cResto      // := SubStr(" 0 0 0 0 0",1,2*(5-nLevel-1))
   LOCAL cNewCargo

   oApp():nEdit ++

   FR->( dbSeek( cCargo ) )
   lFrHoja := FR->FrHoja

   IF nMode == 3
      cFaTipo  := cPrompt
      FR->( dbSeek( cCargo ) )
   ENDIF

   DEFINE DIALOG oDlg RESOURCE "PL_EDIT_ES" ;
      TITLE aTitle[ nMode ] OF oDlgParent
   oDlg:SetFont( oApp():oFont )

   REDEFINE SAY PROMPT "Denominación:" ID 11 OF oDlg
   REDEFINE SAY ID 13 OF oDlg
   REDEFINE SAY ID 14 OF oDlg

   REDEFINE GET aGet[ 1 ] VAR cFaTipo ;
      ID 12 OF oDlg UPDATE          ;
      VALID FrClave( cFaTipo, aGet[ 1 ], nMode )

   REDEFINE BUTTON   ;
      ID    IDOK     ;
      OF    oDlg     ;
      ACTION   ( oDlg:end( IDOK ) )

   REDEFINE BUTTON   ;
      ID    IDCANCEL ;
      OF    oDlg     ;
      CANCEL         ;
      ACTION   ( oDlg:end( IDCANCEL ) )

   ACTIVATE DIALOG oDlg ;
      ON INIT DlgCenter( oDlg, oApp():oWndMain )

   IF oDlg:nresult == IDOK
      /* ___ actualizo la clas. francesa en la receta___________________________*/
      IF nMode == 1
         cResto  := SubStr( " 0 0 0 0 0", 1, 2 * ( 5 -nLevel - 1 ) )
         cNewCargo := SubStr( cCargo, 1, 2 * nlevel ) + Str( Len( oLink:aItems ) + 1, 2 ) + cResto
         // cNewCargo := Str(oLink:Cargo+1,2)+" 0 0 0 0"
         FR->( dbAppend() )
         REPLACE Frn1      WITH Val( SubStr( cNewCargo, 1, 2 ) )
         REPLACE Frn2      WITH Val( SubStr( cNewCargo, 3, 2 ) )
         REPLACE Frn3      WITH Val( SubStr( cNewCargo, 5, 2 ) )
         REPLACE Frn4      WITH Val( SubStr( cNewCargo, 7, 2 ) )
         REPLACE Frn5      WITH Val( SubStr( cNewCargo, 9, 2 ) )
         REPLACE FrHoja    WITH .F.
         REPLACE FrTipo    WITH cFaTipo
         FR->( dbCommit() )
         oParent := oLink
         oLink := oParent:Add( cFaTipo, iif( FR->FrHoja, 1, 0 ) )
         oLink:Cargo := cNewCargo
         // oTree:Cargo ++
      ELSEIF nMode == 2
         // al añadir una hoja es rama
         REPLACE FrHoja    WITH .F.
         // añado la hoja
         cResto  := SubStr( " 0 0 0 0 0", 1, 2 * ( 5 -nLevel - 1 ) )
         cNewCargo := SubStr( cCargo, 1, 2 * nlevel ) + Str( Len( oLink:aItems ) + 1, 2 ) + cResto
         FR->( dbAppend() )
         REPLACE Frn1      WITH Val( SubStr( cNewCargo, 1, 2 ) )
         REPLACE Frn2      WITH Val( SubStr( cNewCargo, 3, 2 ) )
         REPLACE Frn3      WITH Val( SubStr( cNewCargo, 5, 2 ) )
         REPLACE Frn4      WITH Val( SubStr( cNewCargo, 7, 2 ) )
         REPLACE Frn5      WITH Val( SubStr( cNewCargo, 9, 2 ) )
         REPLACE FrHoja    WITH .T.
         REPLACE FrTipo    WITH cFaTipo
         FR->( dbCommit() )
         oParent := oLink
         oLink := oParent:Add( cFaTipo, iif( FR->FrHoja, 1, 0 ) )
         oLink:Cargo := cNewCargo
         oTree:ExpandBranch( oParent )
      ELSEIF nMode == 3
         SELECT RE
         RE->( dbGoTop() )
         REPLACE RE->ReFrTipo    ;
            WITH cFaTipo         ;
            FOR Upper( RTrim( RE->ReFrTipo ) ) == Upper( RTrim( FR->FrTipo ) )
         SELECT FR
         REPLACE FrTipo    WITH cFaTipo
         oLink:SetText( cFaTipo )
         oLink:cPrompt := cFaTipo
      ENDIF
   ELSE
   ENDIF
   oTree:Refresh()
   IF oCont != nil
      RefreshCont( oCont, "FR" )
   ENDIF
   SELECT FR

   oApp():nEdit --
   // FrTreeLoad(oTree)

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION FrBorra( oTree, oCont )

   LOCAL oLink       := oTree:GetSelected()
   LOCAL cPrompt     := oLink:cPrompt
   LOCAL cCargo      := oLink:Cargo
   LOCAL nRecno
	
   IF FR->( ordKeyCount() ) == 1
      MsgStop('No se puede borrar el nodo raiz de la clasificación')
      RETU NIL
   ENDIF
	
   oApp():nEdit ++

   FR->( dbSeek( cCargo ) )
   IF Len( oLink:aItems ) > 0 // ! FR->FrHoja
      MsgStop( "No se puede borrar una rama." + CRLF + "Debe borrar primero sus hojas." )
      oApp():nEdit --
      RETURN NIL
   ENDIF

   IF msgYesNo( i18n( "¿ Está seguro de querer borrar esta denominación ?" ) + CRLF + ;
         cPrompt, 'Seleccione una opción' )
      // borro las clasificación en las recetas
      SELECT RE
      RE->( dbGoTop() )
      REPLACE RE->ReFrTipo    ;
         WITH Space( 30 )       ;
         FOR Upper( RTrim( RE->ReFrTipo ) ) == Upper( RTrim( FR->FrTipo ) )
      // ahora borro el nodo
      // falta actualiziar el padre, si es rama pasar a hoja
      FR->( dbDelete() )
      FR->( dbCommit() )
      FR->( DbPack() )
      oLink:End()
      nRecno := FR->( RecNo() )
   ENDIF

   IF oCont != nil
      RefreshCont( oCont, "FR" )
   ENDIF
   oApp():nEdit --

   RETURN NIL
/*_____________________________________________________________________________*/
FUNCTION FrTecla( nKey, oTree, oCont, oDlg )

   DO CASE
   CASE nKey == VK_RETURN
      FrEdita( oTree, 3, oCont, oDlg )
   CASE nKey == VK_DELETE
      FrBorra( oTree, oCont )
   CASE nKey == VK_ESCAPE
      oDlg:End()
   OTHERWISE
      IF nKey >= 96 .AND. nKey <= 105
         FrBusca( oTree, Str( nKey - 96, 1 ), oCont, oDlg )
      ELSEIF HB_ISSTRING( Chr( nKey ) )
         FrBusca( oTree, Chr( nKey ), oCont, oDlg )
      ENDIF
   ENDCASE

   RETURN NIL
/*_____________________________________________________________________________*/


FUNCTION FrSeleccion( oControl, cFrCargo, cFrTipo, oParent, oVItem )

   LOCAL oDlg, oTree, oBtnAceptar, oBtnCancel, oB1, oB2, oB3, oB4, oB5
   LOCAL lOk    := .F.
   LOCAL nRecno := FR->( RecNo() )
   LOCAL nOrder := FR->( ordNumber() )
   LOCAL nArea  := Select()

   // local aPoint := AdjustWnd( oControl, 271*2, 150*2 )
   LOCAL aPoint := iif( oControl != NIL, AdjustWnd( oControl, 271 * 2, 150 * 2 ), { 1.3 * oVItem:nTop(), oApp():oGrid:nLeft } )
   LOCAL xFrCargo, xFrTipo, xPrompt

   DEFINE DIALOG oDlg RESOURCE 'UT_AJENA2_ES';
      TITLE "Selección de Clasificación Francesa" OF oParent
   oDlg:SetFont( oApp():oFont )

   SELECT FR
   FR->( dbSetOrder( 1 ) )
   FR->( dbGoTop() )
   oTree := TTreeView():Redefine( 110, oDlg )// ,oApp():oDlg:nWidth()/2,(oApp():oDlg:nHeight()-22)/2)
   oTree:SetColor( CLR_BLACK, CLR_WHITE )
   oTree:SetFont( oApp():oFont )
   oTree:bChanged := {|| ( xPrompt := oTree:GetSelected():cPrompt, ;
      FR->( dbSetOrder( 2 ) ),;
      FR->( dbSeek( Upper( xPrompt ) ) ),;
      FR->( dbSetOrder( 1 ) ) ) }

   REDEFINE BUTTON oB1     ;
      ID 410 OF oDlg       ;
      ACTION FrEdita( oTree, 1,, oDlg )

   REDEFINE BUTTON oB2     ;
      ID 411 OF oDlg       ;
      ACTION FrEdita( oTree, 2,, oDlg )

   REDEFINE BUTTON oB3     ;
      ID 412 OF oDlg       ;
      ACTION FrEdita( oTree, 3,, oDlg )

   REDEFINE BUTTON oB4     ;
      ID 413 OF oDlg       ;
      ACTION FrBorra( oTree )

   REDEFINE BUTTON oB5     ;
      ID 414 OF oDlg       ;
      ACTION FrBusca( oTree,, oDlg, @xFrCargo, @xFrTipo )

   REDEFINE BUTTON oBtnAceptar   ;
      ID IDOK OF oDlg            ;
      ACTION ( lOk := .T., oDlg:End() )

   REDEFINE BUTTON oBtnCancel    ;
      ID IDCANCEL OF oDlg        ;
      ACTION ( lOk := .F., oDlg:End() )

   ACTIVATE DIALOG oDlg CENTERED ;
      ON INIT ( FrTreeLoad( oTree ), oTree:ExpandAll(),  oTree:SetFocus() )  ;
      ON PAINT oDlg:Move( aPoint[ 1 ], aPoint[ 2 ],,, .T. )

   IF lOK
      cFrTipo  := xPrompt
      IF oControl != NIL
         oControl:cText := cFrTipo
      endif
   ENDIF

   FR->( dbSetOrder( nOrder ) )
   FR->( dbGoto( nRecno ) )

   SELECT ( nArea )

   RETURN NIL
/*_____________________________________________________________________________*/
FUNCTION FrSeTecla( nKey, oGrid, oDlg, oBtn )

   DO CASE
   CASE nKey == VK_ESCAPE
      oDlg:End()
   OTHERWISE
      IF nKey >= 96 .AND. nKey <= 105
         FrBusca( oGrid, Str( nKey - 96, 1 ),, oDlg )
      ELSEIF HB_ISSTRING( Chr( nKey ) )
         FrBusca( oGrid, Chr( nKey ),, oDlg )
      ENDIF
   ENDCASE

   RETURN NIL
/*_____________________________________________________________________________*/
FUNCTION FrBusca( oTree, cChr, oParent, xFrCargo, xFrTipo )

   LOCAL nOrder   := FR->( ordNumber() )
   LOCAL nRecno   := FR->( RecNo() )
   LOCAL nIndex
   LOCAL oDlg, oGet, cPicture, oLink
   LOCAL aSay1    := { "Introduzca la denominación"   }
   LOCAL aSay2    := { "Denominación:" }
   LOCAL cGet     := Space( 30 )
   LOCAL lSeek    := .F.
   LOCAL lFecha   := .F.

   oApp():nEdit ++

   DEFINE DIALOG oDlg RESOURCE 'UT_BUSCA_' + oApp():cLanguage   ;
      TITLE i18n( "Búsqueda de denominaciones" ) OF oParent
   oDlg:SetFont( oApp():oFont )

   REDEFINE SAY PROMPT aSay1[ nOrder ] ID 20 OF oDlg
   REDEFINE SAY PROMPT aSay2[ nOrder ] ID 21 OF Odlg

   /*__ si he pasado un caracter lo meto en la cadena a buscar ________________*/

   IF cChr != nil
      IF ! lFecha
         cGet := cChr + SubStr( cGet, 1, Len( cGet ) -1 )
      ELSE
         cGet := CToD( cChr + ' -  -    ' )
      ENDIF
   ENDIF

   IF ! lFecha
      REDEFINE GET oGet VAR cGet PICTURE "@!" ID 101 OF oDlg
   ELSE
      REDEFINE GET oGet VAR cGet ID 101 OF oDlg
   ENDIF

   IF cChr != nil
      oGet:bGotFocus := {|| oGet:SetPos( 2 ) }
   ENDIF

   REDEFINE BUTTON ID IDOK OF oDlg ;
      PROMPT i18n( "&Aceptar" )   ;
      ACTION ( lSeek := .T., oDlg:End() )
   REDEFINE BUTTON ID IDCANCEL OF oDlg CANCEL ;
      PROMPT i18n( "&Cancelar" )  ;
      ACTION ( lSeek := .F., oDlg:End() )

   sysrefresh()

   ACTIVATE DIALOG oDlg ;
      ON INIT DlgCenter( oDlg, oApp():oWndMain ) // , Iif(cChr!=nil,oGet:SetPos(2),), oGet:Refresh() )

   IF lSeek
      IF ! lFecha
         cGet := RTrim( Upper( cGet ) )
      ELSE
         cGet := DToS( cGet )
      ENDIF
      FR->( dbSetOrder( 2 ) )
      FR->( dbGoTop() )
      IF ! FR->( dbSeek( cGet, .T. ) )
         msgAlert( i18n( "No encuentro esa denominación." ) )
         FR->( dbGoto( nRecno ) )
      ELSE
         FrSearchItem( oTree, oTree:aItems, cGet )
      ENDIF
      FR->( dbSetOrder( 1 ) )
   ENDIF
   oApp():nEdit --

   RETURN NIL

FUNCTION FrSearchItem( oTree, aItems, cPrompt )

   LOCAL n, r

   FOR n = 1 TO Len( aItems )
      // ? aItems[n]:cPrompt
      IF RTrim( Upper( aItems[ n ]:cPrompt ) ) == cPrompt
         oTree:Select( aItems[ n ] )
         oTree:SetFocus()
         // ? 'Encontrado'
         RETU 1
      ELSE
         IF ! Empty( aItems[ n ]:aItems )
            r := FrSearchItem( oTree, aItems[ n ]:aItems, cPrompt )
            IF r == 1
               RETU 1
            ENDIF
         ENDIF
      ENDIF
   NEXT

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION FrClave( cFrTipo, oGet, nMode )

   // nMode    1 nuevo registro
   // 2 modificación de registro
   // 3 duplicación de registro
   // 4 clave ajena
   LOCAL lreturn  := .F.
   LOCAL nRecno   := FR->( RecNo() )
   LOCAL nOrder   := FR->( ordNumber() )
   LOCAL nArea    := Select()

   IF Empty( cFrTipo )
      IF nMode == 4
         RETURN .T.
      ELSE
         MsgStop( "Es obligatorio rellenar este campo." )
         RETURN .F.
      ENDIF
   ENDIF

   SELECT FR
   // cambio el orden del índice al literal
   FR->( dbSetOrder( 2 ) )
   FR->( dbGoTop() )

   IF FR->( dbSeek( Upper( cFrTipo ) ) )
      DO CASE
      CASE nMode == 1 .OR. nMode == 3
         lreturn := .F.
         MsgStop( "Denominación francesa existente." )
      CASE nMode == 2
         IF FR->( RecNo() ) == nRecno
            lreturn := .T.
         ELSE
            lreturn := .F.
            MsgStop( "Denominación francesa existente." )
         ENDIF
      CASE nMode == 4
         lreturn := .T.
         IF ! oApp():thefull
            Registrame()
         ENDIF
      END CASE
   ELSE
      IF nMode < 4
         lreturn := .T.
      ELSE
         lreturn := .F.
         MsgStop( "Denominación francesa inexistente." )
      ENDIF
   ENDIF

   IF lreturn == .F.
      oGet:cText( Space( 30 ) )
   ENDIF

   FR->( dbSetOrder( nOrder ) )
   FR->( dbGoto( nRecno ) )

   SELECT ( nArea )

   RETURN lreturn
/*_____________________________________________________________________________*/

FUNCTION FrEjemplares( oTree, oParent )

   LOCAL oDlg, oBrowse, oCol
   LOCAL oLink       := oTree:GetSelected()
   LOCAL cPrompt     := oLink:cPrompt
   LOCAL aEpoca    := { '0000', '0001', '0010', '0011', '0100', '0101', '0110', '0111', ;
      '1000', '1001', '1010', '1011', '1100', '1101', '1110', '1111' }
   LOCAL i

   oApp():nEdit ++

   DEFINE DIALOG oDlg RESOURCE 'UT_EJEMPLARES'  ;
      TITLE 'Recetas de: ' + cPrompt OF oParent
   oDlg:SetFont( oApp():oFont )

   RE->( dbSetOrder( 5 ) )
   RE->( dbSetFilter( {|| Trim( RE->ReFrTipo ) == Trim( cPrompt ) } ) )
   RE->( dbGoTop() )

   oBrowse := TXBrowse():New( oDlg )
   Ut_BrwRowConfig( oBrowse )
   oBrowse:cAlias := "RE"

   oCol := oBrowse:AddCol()
   oCol:bStrData := {|| RE->ReTitulo }
   oCol:cHeader  := "Receta"
   oCol:nWidth   := 320

   oCol := oBrowse:AddCol()
   oCol:bStrData := {|| RE->ReCodigo }
   oCol:cHeader  := "Código"
   oCol:nWidth   := 90

   oCol := oBrowse:AddCol()
   oCol:bStrData := {|| RE->ReAutor }
   oCol:cHeader  := "Autor"
   oCol:nWidth   := 130

   oCol := oBrowse:AddCol()
   oCol:AddResource( "BR_EPOCA0000" )
   oCol:AddResource( "BR_EPOCA0001" )
   oCol:AddResource( "BR_EPOCA0010" )
   oCol:AddResource( "BR_EPOCA0011" )
   oCol:AddResource( "BR_EPOCA0100" )
   oCol:AddResource( "BR_EPOCA0101" )
   oCol:AddResource( "BR_EPOCA0110" )
   oCol:AddResource( "BR_EPOCA0111" )
   oCol:AddResource( "BR_EPOCA1000" )
   oCol:AddResource( "BR_EPOCA1001" )
   oCol:AddResource( "BR_EPOCA1010" )
   oCol:AddResource( "BR_EPOCA1011" )
   oCol:AddResource( "BR_EPOCA1100" )
   oCol:AddResource( "BR_EPOCA1101" )
   oCol:AddResource( "BR_EPOCA1110" )
   oCol:AddResource( "BR_EPOCA1111" )
   oCol:cHeader       := i18n( "Epoca" )
   oCol:bBmpData      := {|| Max( AScan( aEpoca, StrTran( Str( RE->ReEpoca, 4 ), ' ', '0' ) ), 1 ) }
   oCol:nWidth        := 80
   oCol:nDataBmpAlign := 2

   oCol := oBrowse:AddCol()
   oCol:AddResource( "BR_Dif1" )
   oCol:AddResource( "BR_Dif2" )
   oCol:AddResource( "BR_Dif3" )
   oCol:cHeader       := i18n( "Dif." )
   oCol:bBmpData      := {|| Max( RE->ReDificu, 1 ) }
   oCol:nWidth        := 40
   oCol:nDataBmpAlign := 2

   oCol := oBrowse:AddCol()
   oCol:AddResource( "BR_CAL1C" )
   oCol:AddResource( "BR_CAL2C" )
   oCol:AddResource( "BR_CAL3C" )
   oCol:cHeader       := i18n( "Cal." )
   oCol:bBmpData      := {|| Max( RE->ReCalori, 1 ) }
   oCol:nWidth        := 40
   oCol:nDataBmpAlign := 2

   oCol := oBrowse:AddCol()
   oCol:AddResource( "BR_PROP1" )
   oCol:AddResource( "BR_PROP2" )
   oCol:cHeader       := i18n( "Inc." )
   oCol:bBmpData      := {|| RE->ReIncorp }
   oCol:nWidth        := 40
   oCol:nDataBmpAlign := 2

   FOR i := 1 TO Len( oBrowse:aCols )
      oCol := oBrowse:aCols[ i ]
      oCol:bLDClickData  := {|| ReEdita( oBrowse, 2,, oDlg ) }
      oCol:bClrSelFocus  := {|| { CLR_BLACK, oApp():nClrHL } }
   NEXT

   oBrowse:SetRDD()
   oBrowse:CreateFromResource( 110 )
   // oBrowse:bKeyDown := {|nKey| FrTecla(nKey,oApp():oGrid,oCont,oApp():oDlg) }

   REDEFINE BUTTON ID IDOK OF oDlg ;
      PROMPT i18n( "&Aceptar" )   ;
      ACTION oDlg:End()

   ACTIVATE DIALOG oDlg ;
      ON INIT DlgCenter( oDlg, oApp():oWndMain )

   RE->( dbClearFilter() )

   SELECT FR
   oTree:Refresh()
   oTree:SetFocus( .T. )
   oApp():nEdit --

   RETURN NIL

/*_____________________________________________________________________________*/
FUNCTION FrImprime( oParent, oGrid )

   LOCAL nRecno   := FR->( RecNo() )
   LOCAL nOrder   := FR->( ordSetFocus() )
   LOCAL aCampos  := { "FRTIPO" }
   LOCAL aTitulos := { "Denominación" }
   LOCAL aWidth   := { 80 }
   LOCAL aShow    := { .T. }
   LOCAL aPicture := { "FR01" }
   LOCAL aTotal   := { .F. }
   LOCAL oInforme

   oApp():nEdit ++
   oInforme := TInforme():New( aCampos, aTitulos, aWidth, aShow, aPicture, aTotal, "FR" )
   oInforme:Dialog()

   REDEFINE RADIO oInforme:oRadio VAR oInforme:nRadio ID 300 OF oInforme:oFld:aDialogs[ 1 ]

   oInforme:Folders()

   IF oInforme:Activate()
      FR->( dbGoTop() )
      oInforme:Report()
      ACTIVATE REPORT oInforme:oReport ;
         ON END ( oInforme:oReport:StartLine(), oInforme:oReport:EndLine(), oInforme:oReport:StartLine(), ;
         oInforme:oReport:Say( 1, 'Total denominaciones: ' + Tran( oInforme:oReport:nCounter, '@E 999,999' ), 1 ), ;
         oInforme:oReport:EndLine() )
      oInforme:End( .T. )
      FR->( dbGoto( nRecno ) )
   ENDIF
   oApp():nEdit --
   oGrid:Refresh()
   oGrid:SetFocus( .T. )

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION FrList( aList, cData, oSelf )

   LOCAL aNewList := {}

   FR->( dbSetOrder( 1 ) )
   FR->( dbGoTop() )
   WHILE ! FR->( Eof() )
      IF At( Upper( cdata ), Upper( FR->FrTipo ) ) != 0 // UPPER( SubStr( oApp():amaterias[i,1], 1, Len( cData ) ) ) == UPPER( cData )
         AAdd( aNewList, { FR->FrTipo } )
      ENDIF
      FR->( dbSkip() )
   ENDDO

   RETURN aNewlist
