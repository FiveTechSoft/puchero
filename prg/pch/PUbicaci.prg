#include "FiveWin.ch"
#include "Report.ch"
#include "xBrowse.ch"
#include "vmenu.ch"

STATIC oReport

FUNCTION Ubicaciones()

   LOCAL oBar, oCol, oCont
   LOCAL aBrowse
   LOCAL cState := GetPvProfString( "Browse", "UbState", "", oApp():cInifile )
   LOCAL nOrder := Max( Val( GetPvProfString( "Browse", "UbOrder", "1", oApp():cInifile ) ), 1 )
   LOCAL nRecno := Val( GetPvProfString( "Browse", "UbRecno", "1", oApp():cInifile ) )
   LOCAL nSplit := Val( GetPvProfString( "Browse", "UbSplit", "102", oApp():cInifile ) )
   LOCAL i

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

   SELECT UB
   oApp():oDlg := TFsdi():New( oApp():oWndMain )
   oApp():oDlg:cTitle := i18n( 'Gestión de ubicaciones de alimentos' )
   oApp():oWndMain:oClient := oApp():oDlg
   oApp():oDlg:NewGrid( nSplit )

   Ut_BrwRowConfig( oApp():oGrid )
   oApp():oGrid:cAlias := "UB"

   oCol := oApp():oGrid:AddCol()
   oCol:Cargo    := 1
   oCol:AddResource( "16_SORT_A" )
   oCol:nHeadBmpNo    := 1
   oCol:nHeadBmpAlign := AL_RIGHT
   oCol:bStrData :=  {|| UB->UbUbicaci }
   oCol:cHeader  := "Ubicación"
   oCol:nWidth   := 150

   ADD oCol TO oApp():oGrid DATA UB->UbAliment ;
      HEADER "Alimentos" PICTURE "@E 999,999" ;
      TOTAL 0 WIDTH 90

   FOR i := 1 TO Len( oApp():oGrid:aCols )
      oCol := oApp():oGrid:aCols[ i ]
      oCol:bLDClickData  := {|| UbEdita( oApp():oGrid, 2, oCont, oApp():oDlg ) }
   NEXT

   oApp():oGrid:SetRDD()
   oApp():oGrid:CreateFromCode()
   oApp():oGrid:bChange  := {|| RefreshCont( oCont, "UB" ), oApp():oGrid:MakeTotals() }
   oApp():oGrid:bKeyDown := {| nKey| UbTecla( nKey, oApp():oGrid, oCont, oApp():oDlg ) }
   oApp():oGrid:nRowHeight  := 21
   oApp():oGrid:RestoreState( cState )
   oApp():oGrid:lFooter := .T.
   oApp():oGrid:bClrFooter := {|| { CLR_HRED, GetSysColor( 15 ) } }
   oApp():oGrid:MakeTotals()

   UB->( dbSetOrder( nOrder ) )
   IF nRecNo < UB->( LastRec() ) .AND. nRecno != 0
      UB->( dbGoto( nRecno ) )
   ELSE
      UB->( dbGoTop() )
   ENDIF

   @ 02, 05 VMENU oCont SIZE nSplit - 10, 18 OF oApp():oDlg  ;
      COLOR CLR_BLACK, GetSysColor( 15 )       ;
      FILLED   ;  // BORDER
   COLORSELECT 0, CLR_WHITE ;
      HEIGHT ITEM 22

   DEFINE TITLE OF oCont ;
      CAPTION tran( UB->( ordKeyNo() ), '@E 999,999' ) + " / " + tran( UB->( ordKeyCount() ), '@E 999,999' ) ;
      HEIGHT 25 ;
      COLOR GetSysColor( 9 ), oApp():nClrBar ;
      IMAGE "BB_UBICACI"

   @ 24, 05 VMENU oBar SIZE nSplit - 10, 160 OF oApp():oDlg  ;
      COLOR CLR_BLACK, GetSysColor( 15 )       ;
      HEIGHT ITEM 22 XBOX
   oBar:nClrBox := Min( GetSysColor( 13 ), GetSysColor( 14 ) )

   DEFINE TITLE OF oBar ;
      CAPTION i18n( "Ubicaciones de ingredientes" ) ;
      HEIGHT 24 ;
      COLOR GetSysColor( 9 ), oApp():nClrBar ;
      OPENCLOSE

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Nuevo"              ;
      IMAGE "16_NUEVO"             ;
      ACTION UbEdita( oApp():oGrid, 1, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Modificar"          ;
      IMAGE "16_MODIF"             ;
      ACTION UbEdita( oApp():oGrid, 2, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Duplicar"           ;
      IMAGE "16_DUPLICA"           ;
      ACTION UbEdita( oApp():oGrid, 3, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Borrar"             ;
      IMAGE "16_BORRAR"            ;
      ACTION UbBorra( oApp():oGrid, oCont );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Buscar"             ;
      IMAGE "16_BUSCA"             ;
      ACTION UbBusca( oApp():oGrid,, oCont, oApp():oDlg )  ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Imprimir"           ;
      IMAGE "16_IMPRIMIR"          ;
      ACTION UbImprime( oApp():oGrid, oApp():oDlg )         ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Ver ingredientes"   ;
      IMAGE "16_ALIMENTO"        ;
      ACTION UbEjemplares( oApp():oGrid, oApp():oDlg ) ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Excel"              ;
      IMAGE "16_EXCEL"             ;
      ACTION ( CursorWait(), Ut_ExportXLS( oApp():oGrid, "Ubicaciones" ), CursorArrow() );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Configurar rejilla" ;
      IMAGE "16_GRID"              ;
      ACTION Ut_BrwColConfig( oApp():oGrid, "UbState" ) ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Salir"              ;
      IMAGE "16_SALIR"             ;
      ACTION oApp():oDlg:End()              ;
      LEFT 10

   @ oApp():oDlg:nGridBottom, nSplit + 2 TABS oApp():oTab ;
      OPTION nOrder SIZE oApp():oWndMain:nWidth() -80, 12 PIXEL OF oApp():oDlg ;
      ITEMS ' Ubicaciones '

   oApp():oDlg:NewSplitter( nSplit, oCont, oBar )

   ACTIVATE DIALOG oApp():oDlg NOWAIT ;
      ON INIT ( ResizeWndMain(), oApp():oGrid:SetFocus() ) ;
      VALID ( oApp():oGrid:nLen := 0,;
      WritePProString( "Browse", "UbState", oApp():oGrid:SaveState(), oApp():cInifile ),;
      WritePProString( "Browse", "UbOrder", LTrim( Str( UB->( ordNumber() ) ) ), oApp():cInifile ),;
      WritePProString( "Browse", "UbRecno", LTrim( Str( UB->( RecNo() ) ) ), oApp():cInifile ),;
      WritePProString( "Browse", "UbSplit", LTrim( Str( oApp():oSplit:nleft / 2 ) ), oApp():cInifile ),;
      oBar:End(), dbCloseAll(), oApp():oDlg := NIL, oApp():oGrid := NIL, oApp():oTab := NIL, .T. )

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION UbEdita( oGrid, nMode, oCont, oParent, cUbicaci )

   LOCAL oDlg, oFld, oBmp
   LOCAL aTitle := { i18n( "Añadir ubicación" ),;
      i18n( "Modificar ubicación" ),;
      i18n( "Duplicar ubicación" ) }
   LOCAL aGet[ 1 ]
   LOCAL cUbUbicaci

   LOCAL nRecPtr := UB->( RecNo() )
   LOCAL nOrden  := UB->( ordNumber() )
   LOCAL nRecAdd
   LOCAL lDuplicado
   LOCAL lreturn := .F.

   IF UB->( Eof() ) .AND. nMode != 1
      RETU NIL
   ENDIF

   oApp():nEdit ++

   IF nMode == 1
      UB->( dbAppend() )
      nRecAdd := UB->( RecNo() )
   ENDIF

   cUbUbicaci := iif( nMode == 1 .AND. cUbicaci != nil, cUbicaci, UB->UbUbicaci )

   IF nMode == 3
      UB->( dbAppend() )
      nRecAdd := UB->( RecNo() )
   ENDIF

   DEFINE DIALOG oDlg RESOURCE "UB_EDIT_" + oApp():cLanguage OF oParent   ;
      TITLE aTitle[ nMode ]
   oDlg:SetFont( oApp():oFont )

   REDEFINE GET aGet[ 1 ] VAR cUbUbicaci ;
      ID 12 OF oDlg UPDATE             ;
      VALID UbClave( cUbUbicaci, aGet[ 1 ], nMode )

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
      lreturn := .T.
      /* ___ actualizo la dieta en la receta_____________*/
      IF nMode == 2
         IF RTrim( cUbUbicaci ) != RTrim( UB->UbUbicaci )
            SELECT AL
            AL->( dbGoTop() )
            REPLACE AL->AlUbicaci   ;
               WITH cUbUbicaci      ;
               FOR Upper( RTrim( AL->AlUbicaci ) ) == Upper( RTrim( UB->UbUbicaci ) )
         ENDIF
         SELECT UB
      ENDIF

      /* ___ guardo el registro _______________________________________________*/
      IF nMode == 2
         UB->( dbGoto( nRecPtr ) )
      ELSE
         UB->( dbGoto( nRecAdd ) )
      ENDIF
      REPLACE UB->UbUbicaci WITH cUbUbicaci
      UB->( dbCommit() )
   ELSE
      IF nMode == 1 .OR. nMode == 3
         UB->( dbGoto( nRecAdd ) )
         UB->( dbDelete() )
         UB->( DbPack() )
         UB->( dbGoto( nRecPtr ) )
      ENDIF
   ENDIF

   SELECT UB
   IF oCont != nil
      RefreshCont( oCont, "UB" )
   ENDIF
   IF oGrid != nil
      oGrid:Refresh()
      oGrid:SetFocus( .T. )
   ENDIF
   oApp():nEdit --

   RETURN lreturn
/*_____________________________________________________________________________*/

FUNCTION UbBorra( oGrid, oCont )

   LOCAL nRecord := UB->( RecNo() )
   LOCAL cUbicaci := RTrim( UB->UbUbicaci )
   LOCAL nNext

   oApp():nEdit ++

   IF msgYesNo( i18n( "¿ Está seguro de querer borrar esta ubicación ?" ) + CRLF + cUbicaci, 'Seleccione una opción' )
      // quito la dieta de las recetas en que aparezca
      SELECT RE
      RE->( dbGoTop() )
      REPLACE AL->AlUbicaci WITH "";
         FOR RTrim( AL->AlUbicaci ) == cUbicaci
      // borro la dieta
      UB->( dbSkip() )
      nNext := UB->( RecNo() )
      UB->( dbGoto( nRecord ) )

      UB->( dbDelete() )
      UB->( DbPack() )
      UB->( dbGoto( nNext ) )
      IF UB->( Eof() ) .OR. nNext == nRecord
         UB->( dbGoBottom() )
      ENDIF
   ENDIF

   IF oCont != nil
      RefreshCont( oCont, "UB" )
   ENDIF

   oGrid:Refresh( .T. )
   oGrid:SetFocus( .T. )
   oApp():nEdit --

   RETURN NIL
/*_____________________________________________________________________________*/
FUNCTION UBTecla( nKey, oGrid, oCont, oDlg )

   DO CASE
   CASE nKey == VK_RETURN
      UbEdita( oGrid, 2, oCont, oDlg )
   CASE nKey == VK_INSERT
      UbEdita( oGrid, 1, oCont, oDlg )
   CASE nKey == VK_DELETE
      UbBorra( oGrid, oCont )
   CASE nKey == VK_ESCAPE
      oDlg:End()
   OTHERWISE
      IF nKey >= 96 .AND. nKey <= 105
         UbBusca( oGrid, Str( nKey - 96, 1 ), oCont, oDlg )
      ELSEIF HB_ISSTRING( Chr( nKey ) )
         UbBusca( oGrid, Chr( nKey ), oCont, oDlg )
      ENDIF
   ENDCASE

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION UbSeleccion( cUbicaci, oControl, oParent, oVItem )

   LOCAL oDlg, oBrowse, oCol, oBtnAceptar, oBtnCancel, oBNew, oBMod, oBDel
   LOCAL lOk    := .F.
   LOCAL nRecno := UB->( RecNo() )
   LOCAL nOrder := UB->( ordNumber() )
   LOCAL nArea  := Select()
   LOCAL aPoint := iif( oControl != NIL, AdjustWnd( oControl, 271 * 2, 150 * 2 ), { 1.3 * oVItem:nTop(), oApp():oGrid:nLeft } )

   DEFINE DIALOG oDlg RESOURCE 'UT_AJENA1_' + oApp():cLanguage OF oParent;
      TITLE i18n( "Selección de ubicaciones" )
   oDlg:SetFont( oApp():oFont )

   // siempre tengo ordenado por nombre

   SELECT UB
   UB->( dbSetOrder( 1 ) )
   UB->( dbGoTop() )

   oBrowse := TXBrowse():New( oDlg )
   Ut_BrwRowConfig( oBrowse )
   oBrowse:cAlias := "UB"

   oCol := oBrowse:AddCol()
   oCol:bStrData := {|| UB->UbUbicaci }
   oCol:cHeader  := "Ubicación"
   oCol:nWidth   := 160
   oCol:bLDClickData  := {|| ( lOk := .T., oDlg:End() )   }
   oBrowse:SetRDD()
   oBrowse:CreateFromResource( 110 )
   // oBrowse:bKeyDown := {|nKey| UbSeTecla(nKey,oBrowse,oDlg,oBtnAceptar) }

   REDEFINE BUTTON oBNew   ;
      ID 410 OF oDlg       ;
      ACTION UbEdita( oBrowse, 1,, oDlg )

   REDEFINE BUTTON oBMod   ;
      ID 411 OF oDlg       ;
      ACTION UbEdita( oBrowse, 2,, oDlg )

   REDEFINE BUTTON oBDel   ;
      ID 412 OF oDlg       ;
      ACTION UbBorra( oBrowse, )

   REDEFINE BUTTON oBtnAceptar   ;
      ID IDOK OF oDlg            ;
      ACTION ( lOk := .T., oDlg:End() )

   REDEFINE BUTTON oBtnCancel    ;
      ID IDCANCEL OF oDlg        ;
      ACTION ( lOk := .F., oDlg:End() )

   ACTIVATE DIALOG oDlg CENTERED       ;
      ON PAINT oDlg:Move( aPoint[ 1 ], aPoint[ 2 ],,, .T. )

   IF lOK
      cUbicaci := UB->UbUbicaci
      IF oControl != NIL
         oControl:cText := UB->UbUbicaci
      ENDIF
   ENDIF

   UB->( dbSetOrder( nOrder ) )
   UB->( dbGoto( nRecno ) )

   SELECT ( nArea )

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION UbBusca( oGrid, cChr, oCont, oParent )

   LOCAL nOrder   := UB->( ordNumber() )
   LOCAL nRecno   := UB->( RecNo() )
   LOCAL oDlg, oGet, cGet, cPicture
   LOCAL aSay1    := { "Introduzca el nombre de la ubicación" }
   LOCAL aSay2    := { "Ubicación:" }
   LOCAL aGet     := { Space( 40 ) }
   LOCAL lSeek    := .F.
   LOCAL lFecha   := .F.
   LOCAL aBrowse := {}

   oApp():nEdit ++

   DEFINE DIALOG oDlg RESOURCE 'UT_BUSCA_' + oApp():cLanguage OF oParent  ;
      TITLE i18n( "Búsqueda de ubicaciones" )
   oDlg:SetFont( oApp():oFont )

   REDEFINE SAY PROMPT aSay1[ nOrder ] ID 20 OF oDlg
   REDEFINE SAY PROMPT aSay2[ nOrder ] ID 21 OF Odlg

   cGet  := aGet[ nOrder ]

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
      ENDIF
      MsgRun( 'Realizando la búsqueda...', oApp():cAppName + oApp():cVersion, ;
         {|| UbWildSeek( nOrder, cGet, aBrowse ) } )
      IF Len( aBrowse ) == 0
         MsgStop( "No se ha encontrado ninguna ubicación." )
      ELSE
         UbEncontrados( aBrowse, oApp():oDlg )
      ENDIF
   ENDIF
   IF oCont != NIL
      RefreshCont( oCont, "UB" )
   ENDIF
	
   oApp():nEdit --
   oGrid:Refresh()
   oGrid:SetFocus( .T. )

   RETURN NIL
/*_____________________________________________________________________________*/
FUNCTION UbWildSeek( nOrder, cGet, aBrowse )

   LOCAL nRecno   := UB->( RecNo() )
	
   UB->( dbGoTop() )
   DO WHILE ! UB->( Eof() )
      IF cGet $ Upper( UB->UbUbicaci )
         AAdd( aBrowse, { UB->UbUbicaci, UB->UbAliment, UB->( RecNo() ) } )
      ENDIF
      UB->( dbSkip() )
   ENDDO
   UB->( dbGoto( nRecno ) )
   // ordeno la tabla por el 1 elemento
   ASort( aBrowse,,, {|aAut1, aAut2| Upper( aAut1[ 1 ] ) < Upper( aAut2[ 1 ] ) } )

   RETURN NIL
/*_____________________________________________________________________________*/
	
FUNCTION UbEncontrados( aBrowse, oParent )

   LOCAL oDlg, oBrowse, oBtnOk, oBtnCancel, lOk
   LOCAL nRecno := UB->( RecNo() )
	
   DEFINE DIALOG oDlg RESOURCE "DLG_ENCONTRADOS" ;
      TITLE i18n( "Resultado de la búsqueda" ) ;
      OF oParent
   oDlg:SetFont( oApp():oFont )
	
   oBrowse := TXBrowse():New( oDlg )
   Ut_BrwRowConfig( oBrowse )

   oBrowse:SetArray( aBrowse, .F. )
   oBrowse:aCols[ 1 ]:cHeader := "Ubicación"
   oBrowse:aCols[ 2 ]:cHeader := "Ingredientes"
   oBrowse:aCols[ 1 ]:nWidth  := 340
   oBrowse:aCols[ 2 ]:nWidth  := 100
   oBrowse:aCols[ 3 ]:Hide()
   oBrowse:aCols[ 1 ]:nHeadStrAlign := 0
   oBrowse:aCols[ 1 ]:nDataStrAlign := 0
   oBrowse:aCols[ 2 ]:nHeadStrAlign := 0
   oBrowse:aCols[ 2 ]:nDataStrAlign := 0
	
   oBrowse:CreateFromResource( 110 )
	
   UB->( dbGoto( aBrowse[ oBrowse:nArrayAt, 3 ] ) )
   AEval( oBrowse:aCols, {|oCol| oCol:bLDClickData := {|| UB->( dbGoto( aBrowse[ oBrowse:nArrayAt, 3 ] ) ), ;
      UbEdita( , 2,, oApp():oDlg ) } } )
   oBrowse:bKeyDown  := {| nKey| iif( nKey == VK_RETURN, ( UB->( dbGoto( aBrowse[ oBrowse:nArrayAt, 3 ] ) ), ;
      UbEdita( , 2,, oApp():oDlg ) ), ) }
   oBrowse:bChange   := {|| UB->( dbGoto( aBrowse[ oBrowse:nArrayAt, 3 ] ) ) }
   oBrowse:lHScroll  := .F.
   oDlg:oClient      := oBrowse
   oBrowse:nRowHeight := 20
	
   REDEFINE BUTTON oBtnOk ;
      ID IDOK OF oDlg     ;
      ACTION oDlg:End()
	
   REDEFINE BUTTON oBtnCancel ;
      ID IDCANCEL OF oDlg ;
      ACTION ( UB->( dbGoto( nRecno ) ), oDlg:End() )
	
   ACTIVATE DIALOG oDlg ;
      ON INIT DlgCenter( oDlg, oApp():oWndMain )
	
   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION UbClave( cUbicaci, oGet, nMode )

   // nMode    1 nuevo registro
   // 2 modificación de registro
   // 3 duplicación de registro
   // 4 clave ajena
   LOCAL lreturn  := .F.
   LOCAL nRecno   := UB->( RecNo() )
   LOCAL nOrder   := UB->( ordNumber() )
   LOCAL nArea    := Select()

   IF Empty( cUbicaci )
      IF nMode == 4
         RETURN .T.
      ELSE
         MsgStop( "Es obligatorio rellenar este campo." )
         RETURN .F.
      ENDIF
   ENDIF

   SELECT UB
   UB->( dbSetOrder( 1 ) )
   UB->( dbGoTop() )

   IF UB->( dbSeek( Upper( cUbicaci ) ) )
      DO CASE
      CASE nMode == 1 .OR. nMode == 3
         lreturn := .F.
         MsgStop( "Ubicación existente." )
      CASE nMode == 2
         IF UB->( RecNo() ) == nRecno
            lreturn := .T.
         ELSE
            lreturn := .F.
            MsgStop( "Ubicación existente." )
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
         IF MsgYesNo( "Ubicación inexistente. ¿ Desea darla de alta ahora? ", 'Seleccione una opción' )
            lreturn := UbEdita( , 1, , , @cUbicaci )
         ELSE
            lreturn := .F.
         ENDIF
      ENDIF
   ENDIF

   IF lreturn == .F.
      oGet:cText( Space( 40 ) )
   ENDIF

   UB->( dbSetOrder( nOrder ) )
   UB->( dbGoto( nRecno ) )

   SELECT ( nArea )

   RETURN lreturn
/*_____________________________________________________________________________*/

FUNCTION UbEjemplares( oGrid, oParent )

   LOCAL oDlg, oBrowse, oCol
   LOCAL cUbicaci := RTrim( UB->UbUbicaci )
   LOCAL aBrowse  := {}
   LOCAL i
   LOCAL cTitle

   oApp():nEdit ++

   DEFINE DIALOG oDlg RESOURCE 'UT_EJEMPLARES'  ;
      TITLE 'Alimentos en: ' + UB->UbUbicaci OF oParent
   oDlg:SetFont( oApp():oFont )

   SELECT AL
   AL->( dbSetOrder( 1 ) )
   AL->( dbSetFilter( {|| RTrim( AL->AlUbicaci ) == cUbicaci } ) )
   AL->( dbGoTop() )

   oBrowse := TXBrowse():New( oDlg )
   Ut_BrwRowConfig( oBrowse )
   oBrowse:cAlias := "AL"

   oCol := oBrowse:AddCol()
   oCol:bStrData := {|| AL->AlAlimento }
   oCol:cHeader  := "Ingrediente"
   oCol:nWidth   := 220

   oCol := oBrowse:AddCol()
   oCol:bStrData := {|| AL->AlTipo }
   oCol:cHeader  := "Familia"
   oCol:nWidth   := 150

   oCol := oBrowse:AddCol()
   oCol:bStrData := {|| AL->AlUnidad }
   oCol:cHeader  := "Unidad"
   oCol:nWidth   := 110

   FOR i := 1 TO Len( oBrowse:aCols )
      oCol := oBrowse:aCols[ i ]
      oCol:bLDClickData  := {|| AlEdita( oBrowse, 2,, oDlg ) }
      oCol:bClrSelFocus  := {|| { CLR_BLACK, oApp():nClrHL } }
   NEXT

   oBrowse:SetRDD()
   oBrowse:CreateFromResource( 110 )

   REDEFINE BUTTON ID IDOK OF oDlg ;
      PROMPT i18n( "&Aceptar" )   ;
      ACTION oDlg:End()

   ACTIVATE DIALOG oDlg ;
      ON INIT DlgCenter( oDlg, oApp():oWndMain )

   AL->( dbClearFilter() )

   SELECT UB
   oGrid:Refresh()
   oGrid:SetFocus( .T. )
   oApp():nEdit --

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION UbImprime( oGrid, oParent )

   LOCAL nRecno   := UB->( RecNo() )
   LOCAL nOrder   := UB->( ordSetFocus() )
   LOCAL aCampos  := { "UbUbicaci", "UbAliment" }
   LOCAL aTitulos := { "Ubicación", "Alimentos" }
   LOCAL aWidth   := { 50, 50 }
   LOCAL aShow    := { .T., .T. }
   LOCAL aPicture := { "NO", "@E 99,999" }
   LOCAL aTotal   := { .F., .F. }
   LOCAL nLen     := 2  // nº de campos a mostrar
   LOCAL oInforme

   oApp():nEdit ++

   oInforme := TInforme():New( aCampos, aTitulos, aWidth, aShow, aPicture, aTotal, "UB" )
   oInforme:Dialog()

   REDEFINE RADIO oInforme:oRadio VAR oInforme:nRadio ID 300 OF oInforme:oFld:aDialogs[ 1 ] ;
      ON CHANGE oInforme:Change()

   oInforme:Folders()

   IF oInforme:Activate()
      SELECT UB
      UB->( dbGoTop() )
      oInforme:Report()
      ACTIVATE REPORT oInforme:oReport ;
         ON END ( oInforme:oReport:StartLine(), oInforme:oReport:EndLine(), oInforme:oReport:StartLine(), ;
         oInforme:oReport:Say( 1, 'Total ubicaciones: ' + Tran( oInforme:oReport:nCounter, '@E 999,999' ), 1 ), ;
         oInforme:oReport:EndLine() )
      oInforme:End( .T. )
      UB->( ordSetFocus( nOrder ) )
      UB->( dbGoto( nRecno ) )
   ENDIF

   oApp():nEdit --

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION UbList( aList, cData, oSelf )

   LOCAL aNewList := {}

   UB->( dbSetOrder( 1 ) )
   UB->( dbGoTop() )
   WHILE ! UB->( Eof() )
      IF At( Upper( cdata ), Upper( UB->UbUbicaci ) ) != 0 // UPPER( SubStr( oApp():amaterias[i,1], 1, Len( cData ) ) ) == UPPER( cData )
         AAdd( aNewList, { UB->UbUbicaci } )
      ENDIF
      UB->( dbSkip() )
   ENDDO

   RETURN aNewlist
