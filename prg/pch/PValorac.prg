#include "FiveWin.ch"
#include "Report.ch"
#include "xBrowse.ch"
#include "vmenu.ch"
#include "splitter.ch"

STATIC oReport

FUNCTION Valoraciones()

   LOCAL oBar, oCol, oCont
   LOCAL aBrowse
   LOCAL cState := GetPvProfString( "Browse", "VaState", "", oApp():cInifile )
   LOCAL nOrder := Max( Val( GetPvProfString( "Browse", "VaOrder", "1", oApp():cInifile ) ), 1 )
   LOCAL nRecno := Val( GetPvProfString( "Browse", "VaRecno", "1", oApp():cInifile ) )
   LOCAL nSplit := Val( GetPvProfString( "Browse", "VaSplit", "102", oApp():cInifile ) )
   LOCAL i

   // ? i[5]
   IF oApp():oDlg != nil
      IF oApp():nEdit > 0
         RETURN NIL
      ELSE
         oApp():oDlg:End()
         SysRefresh()
      ENDIF
   ENDIF

   IF ! Db_OpenAll()
      RETURN NIL
   ENDIF

   SELECT VA
   oApp():oDlg := TFsdi():New( oApp():oWndMain )
   oApp():oDlg:cTitle := i18n( 'Gestión de valoraciones de recetas' )
   oApp():oWndMain:oClient := oApp():oDlg
   oApp():oDlg:NewGrid( nSplit )

   Ut_BrwRowConfig( oApp():oGrid )

   oApp():oGrid:cAlias := "VA"

   oCol := oApp():oGrid:AddCol()
   oCol:Cargo    := 1
   oCol:AddResource( "16_SORT_A" )
   oCol:nHeadBmpNo    := 1
   oCol:nHeadBmpAlign := AL_RIGHT
   oCol:bStrData :=  {|| VA->VaValorac }
   oCol:cHeader  := "Valoración"
   oCol:nWidth   := 150

   ADD oCol TO oApp():oGrid DATA VA->VaRecetas ;
      HEADER "Recetas" PICTURE "@E 999,999" ;
      TOTAL 0 WIDTH 90

   ADD oCol TO oApp():oGrid DATA VA->VaOrden ;
      HEADER "Orden" PICTURE "@E 999,999" WIDTH 90

   FOR i := 1 TO Len( oApp():oGrid:aCols )
      oCol := oApp():oGrid:aCols[ i ]
      oCol:bLDClickData  := {|| VaEdita( oApp():oGrid, 2, oCont, oApp():oDlg ) }
   NEXT

   oApp():oGrid:SetRDD()
   oApp():oGrid:CreateFromCode()
   oApp():oGrid:bChange  := {|| RefreshCont( oCont, "VA" ), oApp():oGrid:Maketotals() }
   oApp():oGrid:bKeyDown := {| nKey| VaTecla( nKey, oApp():oGrid, oCont, oApp():oDlg ) }
   oApp():oGrid:nRowHeight  := 21
   oApp():oGrid:RestoreState( cState )
   oApp():oGrid:lFooter := .T.
   oApp():oGrid:bClrFooter := {|| { CLR_HRED, GetSysColor( 15 ) } }
   oApp():oGrid:MakeTotals()


   VA->( dbSetOrder( nOrder ) )
   IF nRecNo < VA->( LastRec() ) .AND. nRecno != 0
      VA->( dbGoto( nRecno ) )
   ELSE
      VA->( dbGoTop() )
   ENDIF

   @ 02, 05 VMENU oCont SIZE nSplit - 10, 18 OF oApp():oDlg  ;
      COLOR CLR_BLACK, GetSysColor( 15 )       ;
      FILLED   ;
      COLORSELECT 0, CLR_WHITE ;
      HEIGHT ITEM 22

   DEFINE TITLE OF oCont ;
      CAPTION tran( VA->( ordKeyNo() ), '@E 999,999' ) + " / " + tran( VA->( ordKeyCount() ), '@E 999,999' ) ;// strZero( RE->( ordKeyCount() ), 6 ) ;
   HEIGHT 25 ;
      COLOR GetSysColor( 9 ), oApp():nClrBar ;
      IMAGE "BB_MATER3"

   @ 24, 05 VMENU oBar SIZE nSplit - 10, 170 OF oApp():oDlg  ;
      COLOR CLR_BLACK, GetSysColor( 15 )       ;
      HEIGHT ITEM 22 XBOX
   oBar:nClrBox := Min( GetSysColor( 13 ), GetSysColor( 14 ) )

   DEFINE TITLE OF oBar                      ;
      CAPTION "Valoraciones"                 ;
      HEIGHT 25                            ;
      COLOR GetSysColor( 9 ), oApp():nClrBar ;
      OPENCLOSE

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Nuevo"              ;
      IMAGE "16_NUEVO"             ;
      ACTION VaEdita( oApp():oGrid, 1, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Modificar"          ;
      IMAGE "16_MODIF"             ;
      ACTION VaEdita( oApp():oGrid, 2, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Duplicar"           ;
      IMAGE "16_DUPLICA"           ;
      ACTION VaEdita( oApp():oGrid, 3, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Borrar"             ;
      IMAGE "16_BORRAR"            ;
      ACTION VaBorra( oApp():oGrid, oCont );
      LEFT 10


   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Agrupar valoraciones" ;
      IMAGE "16_AGRUPA"            ;
      ACTION VaAgrupa( oApp():oGrid, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Buscar"             ;
      IMAGE "16_BUSCA"             ;
      ACTION VaBusca( oApp():oGrid,, oCont, oApp():oDlg )  ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Imprimir"           ;
      IMAGE "16_IMPRIMIR"          ;
      ACTION VaImprime( oApp():oGrid, oApp():oDlg )         ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Ver recetas"        ;
      IMAGE "16_RECETAS"        ;
      ACTION VaEjemplares( oApp():oGrid, oApp():oDlg ) ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Subir valoración"   ;
      IMAGE "16_ARRIBA"            ;
      ACTION VaArriba( oApp():oGrid, oCont );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Bajar valoración"   ;
      IMAGE "16_ABAJO"             ;
      ACTION VaAbajo( oApp():oGrid, oCont );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Enviar a Excel"     ;
      IMAGE "16_EXCEL"             ;
      ACTION ( CursorWait(), Ut_ExportXLS( oApp():oGrid, "Valoraciones" ), CursorArrow() );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Configurar rejilla" ;
      IMAGE "16_GRID"              ;
      ACTION Ut_BrwColConfig( oApp():oGrid, "VaState" ) ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Salir"              ;
      IMAGE "16_SALIR"             ;
      ACTION oApp():oDlg:End()              ;
      LEFT 10

   @ oApp():oDlg:nGridBottom, nSplit + 2 TABS oApp():oTab ;
      OPTION nOrder SIZE oApp():oWndMain:nWidth() -80, 12 PIXEL OF oApp():oDlg ;
      ITEMS ' Valoraciones '

   oApp():oDlg:NewSplitter( nSplit, oCont, oBar )

   ACTIVATE DIALOG oApp():oDlg NOWAIT;
      ON INIT ( ResizeWndMain(), oApp():oGrid:SetFocus() ) ;
      VALID ( oApp():oGrid:nLen := 0,;
      WritePProString( "Browse", "VaState", oApp():oGrid:SaveState(), oApp():cInifile ),;
      WritePProString( "Browse", "VaOrder", LTrim( Str( VA->( ordNumber() ) ) ), oApp():cInifile ),;
      WritePProString( "Browse", "VaRecno", LTrim( Str( VA->( RecNo() ) ) ), oApp():cInifile ),;
      WritePProString( "Browse", "VaSplit", LTrim( Str( oApp():oSplit:nleft / 2 ) ), oApp():cInifile ),;
      oBar:End(), dbCloseAll(), oApp():oDlg := NIL, oApp():oGrid := NIL, oApp():oTab := NIL, .T. )

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION VaEdita( oGrid, nMode, oCont, oParent, cValorac )

   LOCAL oDlg
   LOCAL aTitle := { i18n( "Añadir " ),;
      i18n( "Modificar " ),;
      i18n( "Duplicar " ) }
   LOCAL aGet[ 1 ]
   LOCAL cVaValorac,;
      nVaRecetas

   LOCAL nRecPtr     := VA->( RecNo() )
   LOCAL nOrden      := VA->( ordNumber() )
   LOCAL nReRecPtr   := RE->( RecNo() )
   LOCAL nReOrden    := RE->( ordNumber() )
   LOCAL nRecAdd
   LOCAL cSay1       := 'Valoración'
   LOCAL cSay2       := 'Recetas:'
   LOCAL nVaOrden
   LOCAL lreturn     := .F.

   IF VA->( Eof() ) .AND. nMode != 1
      RETURN NIL
   ENDIF

   oApp():nEdit ++

   IF nMode == 1
      VA->( dbAppend() )
      nRecAdd := VA->( RecNo() )
      REPLACE VA->VaOrden WITH nRecAdd
   ENDIF

   nVaOrden    := VA->VaOrden
   cVaValorac  := iif( nMode == 1 .AND. cValorac != nil, cValorac, VA->VaValorac )
   nVaRecetas  := VA->VaRecetas

   IF nMode == 3
      VA->( dbAppend() )
      nRecAdd := VA->( RecNo() )
      nVaOrden := nRecAdd
   ENDIF

   DEFINE DIALOG oDlg RESOURCE "PL_EDIT_ES" OF oParent;
      TITLE aTitle[ nMode ] + 'valoración'
   oDlg:SetFont( oApp():oFont )

   REDEFINE SAY VAR cSay1     ID 11 OF oDlg
   REDEFINE SAY VAR cSay2     ID 13 OF oDlg
   REDEFINE SAY VAR nVaRecetas   ;
      PICTURE "@E 99,999" ID 14 OF oDlg

   REDEFINE GET aGet[ 1 ] VAR cVaValorac ;
      ID 12 OF oDlg UPDATE             ;
      VALID VaClave( cVaValorac, aGet[ 1 ], nMode )

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
      /* ___ actualizo la valoración en la receta___________________________*/
      IF nMode == 2
         IF cVaValorac != VA->VaValorac
            SELECT RE
            RE->( dbSetOrder( 0 ) )
            RE->( dbGoTop() )
            REPLACE RE->ReValorac      ;
               WITH cVaValorac         ;
               FOR Upper( RTrim( RE->ReValorac ) ) == Upper( RTrim( VA->VaValorac ) )
            RE->( dbSetOrder( nReOrden ) )
            RE->( dbGoto( nReRecPtr ) )
            SELECT VA
         ENDIF
      ENDIF

      /* ___ guardo el registro _______________________________________________*/
      IF nMode == 2
         VA->( dbGoto( nRecPtr ) )
      ELSE
         VA->( dbGoto( nRecAdd ) )
      ENDIF

      REPLACE VA->VaOrden    WITH nVaOrden
      REPLACE VA->VaValorac  WITH cVaValorac
      REPLACE VA->VaRecetas  WITH nVaRecetas

      VA->( dbCommit() )
      IF cValorac != nil
         cValorac := VA->VaValorac
      ENDIF
   ELSE

      IF nMode == 1 .OR. nMode == 3

         VA->( dbGoto( nRecAdd ) )
         VA->( dbDelete() )
         VA->( DbPack() )
         VA->( dbGoto( nRecPtr ) )

      ENDIF

   ENDIF

   SELECT VA

   IF oCont != nil
      RefreshCont( oCont, "VA" )
   ENDIF
   IF oGrid != nil
      oGrid:Refresh()
      oGrid:SetFocus( .T. )
   ENDIF
   oApp():nEdit --

   RETURN lreturn
/*_____________________________________________________________________________*/

FUNCTION VABorra( oGrid, oCont )

   LOCAL nRecord := VA->( RecNo() )
   LOCAL nOrden  := VA->VaOrden
   LOCAL nReRecPtr   := RE->( RecNo() )
   LOCAL nReOrden    := RE->( ordNumber() )

   oApp():nEdit ++

   IF msgYesNo( i18n( "¿ Está seguro de querer borrar esta valoración ?" ) + CRLF + ;
         ( Trim( VA->VaValorac ) ), 'Seleccione una opción' )
      /*___ cambio el orden de las recetas ____________________________________*/
      SELECT RE
      RE->( dbSetOrder( 0 ) )
      RE->( dbGoTop() )
      REPLACE RE->ReValorac      ;
         WITH Space( 20 )          ;
         FOR RE->ReVaOrden == nOrden
      RE->( dbGoTop() )
      REPLACE RE->ReVaOrden      ;
         WITH 0                  ;
         FOR RE->ReVaOrden == nOrden
      RE->( dbGoTop() )
      REPLACE RE->ReVaOrden      ;
         WITH RE->ReVaOrden - 1  ;
         FOR RE->ReVaOrden > nOrden
      RE->( dbSetOrder( nReOrden ) )
      RE->( dbGoto( nReRecPtr ) )

      SELECT VA
      VA->( dbDelete() )
      VA->( DbPack() )
      VA->( dbGoTop() )
      REPLACE VA->VaOrden WITH ( VA->VaOrden - 1 ) ;
         FOR VA->VaOrden > nOrden

      IF ! VA->( dbSeek( nOrden ) )
         VA->( dbGoBottom() )
      ENDIF
   ENDIF

   IF oCont != nil
      RefreshCont( oCont, "VA" )
   ENDIF

   oGrid:Refresh( .T. )
   oGrid:SetFocus( .T. )
   oApp():nEdit --

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION VAArriba( oGrid, oCont )

   LOCAL nRecord     := VA->VaOrden
   LOCAL nReRecPtr   := RE->( RecNo() )
   LOCAL nReOrden    := RE->( ordNumber() )

   oApp():nEdit ++

   IF nRecord > 1
      SELECT RE
      RE->( dbSetOrder( 0 ) )
      RE->( dbGoTop() )
      REPLACE RE->ReVaOrden   ;
         WITH -1              ;
         FOR RE->ReVaOrden == nRecord
      RE->( dbGoTop() )
      REPLACE RE->ReVaOrden   ;
         WITH nRecord         ;
         FOR RE->ReVaOrden == nRecord - 1
      RE->( dbGoTop() )
      REPLACE RE->ReVaOrden   ;
         WITH nRecord - 1     ;
         FOR RE->ReVaOrden == -1
      RE->( dbSetOrder( nReOrden ) )
      RE->( dbGoto( nReRecPtr ) )

      SELECT VA
      REPLACE VA->VaOrden WITH 0
      VA->( dbSeek( nRecord - 1 ) )
      REPLACE VA->VaOrden WITH nRecord
      VA->( dbSeek( 0 ) )
      REPLACE VA->VaOrden WITH nRecord - 1
   ENDIF

   IF oCont != nil
      RefreshCont( oCont, "VA" )
   ENDIF

   oGrid:Refresh( .T. )
   oGrid:SetFocus( .T. )
   oApp():nEdit --

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION VaAbajo( oGrid, oCont )

   LOCAL nRecord := VA->VaOrden
   LOCAL nReRecPtr   := RE->( RecNo() )
   LOCAL nReOrden    := RE->( ordNumber() )

   oApp():nEdit ++

   IF nRecord < RE->( LastRec() )
      SELECT RE
      RE->( dbSetOrder( 0 ) )
      RE->( dbGoTop() )
      REPLACE RE->ReVaOrden   ;
         WITH -1              ;
         FOR RE->ReVaOrden == nRecord
      RE->( dbGoTop() )
      REPLACE RE->ReVaOrden   ;
         WITH nRecord         ;
         FOR RE->ReVaOrden == nRecord + 1
      RE->( dbGoTop() )
      REPLACE RE->ReVaOrden   ;
         WITH nRecord + 1     ;
         FOR RE->ReVaOrden == -1
      RE->( dbSetOrder( nReOrden ) )
      RE->( dbGoto( nReRecPtr ) )

      REPLACE VA->VaOrden WITH 0
      VA->( dbSeek( nRecord + 1 ) )
      REPLACE VA->VaOrden WITH nRecord
      VA->( dbSeek( 0 ) )
      REPLACE VA->VaOrden WITH nRecord + 1
   ENDIF

   IF oCont != nil
      RefreshCont( oCont, "VA" )
   ENDIF

   oGrid:Refresh( .T. )
   oGrid:SetFocus( .T. )
   oApp():nEdit --

   RETURN NIL

/*_____________________________________________________________________________*/

FUNCTION VATecla( nKey, oGrid, oCont, oDlg )

   DO CASE
   CASE nKey == VK_RETURN
      VaEdita( oGrid, 2, oCont, oDlg )
   CASE nKey == VK_INSERT
      VaEdita( oGrid, 1, oCont, oDlg )
   CASE nKey == VK_DELETE
      VaBorra( oGrid, oCont )
   CASE nKey == VK_ESCAPE
      oDlg:End()
   OTHERWISE
      IF nKey >= 96 .AND. nKey <= 105
         VaBusca( oGrid, Str( nKey - 96, 1 ), oCont, oDlg )
      ELSEIF HB_ISSTRING( Chr( nKey ) )
         VaBusca( oGrid, Chr( nKey ), oCont, oDlg )
      ENDIF
   ENDCASE

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION VaAgrupa( oGrid, oParent )

   LOCAL oDlg, oCombo
   LOCAL cTitle := i18n( "Agrupar valoraciones" )
   LOCAL aSay[ 4 ]

   LOCAL nRecno      := VA->( RecNo() )
   LOCAL nOrden      := VA->( ordNumber() )
   LOCAL nReRecno    := RE->( RecNo() )
   LOCAL nReOrden    := RE->( ordNumber() )

   LOCAL cVaValorac  := VA->VaValorac
   LOCAL nVaOrden    := VA->VaOrden
   LOCAL nVaRecetas  := VA->VaRecetas

   LOCAL nRecAdd
   LOCAL lDuplicado
   LOCAL aValorac := {}
   LOCAL cNewValorac
   LOCAL nNewOrden

   oApp():nEdit ++

   VA->( dbGoTop() )
   DO WHILE ! VA->( Eof() )
      AAdd( aValorac, VA->VaValorac )
      VA->( dbSkip() )
   ENDDO
   cNewValorac := aValorac[ 1 ]

   DEFINE DIALOG oDlg RESOURCE "UT_AGRUPA" TITLE cTitle OF oParent
   oDlg:SetFont( oApp():oFont )

   REDEFINE SAY aSay[ 1 ]          ;
      PROMPT "La agrupación de valoraciones permite asignar a recetas existentes una nueva valoración ya existente." ;
      ID 10 OF oDlg COLOR CLR_BLACK, CLR_WHITE

   REDEFINE SAY aSay[ 2 ]          ;
      PROMPT "Vieja valoración:" ;
      ID 11 OF oDlg

   REDEFINE SAY aSay[ 3 ]          ;
      PROMPT cVaValorac          ;
      COLOR CLR_HBLUE, GetSysColor( 15 ) ;
      ID 12 OF oDlg

   REDEFINE SAY aSay[ 4 ]          ;
      PROMPT "Nueva valoración:" ;
      ID 13 OF oDlg

   REDEFINE COMBOBOX oCombo      ;
      VAR cNewValorac            ;
      ITEMS aValorac             ;
      ID 14 OF oDlg

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
      /* ___ actualizo el tipo de plato en la receta___________________________*/
      VA->( dbSetOrder( 2 ) )
      VA->( dbSeek( Upper( cNewValorac ) ) )
      nNewOrden := VA->VaOrden

      SELECT RE
      RE->( dbSetOrder( 0 ) )
      RE->( dbGoTop() )
      REPLACE RE->ReValorac   ;
         WITH cNewValorac     ;
         FOR Upper( RTrim( RE->ReValorac ) ) == Upper( RTrim( cVaValorac ) )
      RE->( dbGoTop() )
      REPLACE RE->ReVaOrden   ;
         WITH nNewOrden       ;
         FOR RE->ReVaOrden == nVaOrden

      /* ___ borro la valoración y tiro de hacia arriba ___________________*/
      RE->( dbGoTop() )
      REPLACE RE->ReVaOrden      ;
         WITH RE->ReVaOrden - 1  ;
         FOR RE->ReVaOrden > nVaOrden
      RE->( dbSetOrder( nReOrden ) )
      RE->( dbGoto( nRecno ) )

      SELECT VA
      VA->( dbSetOrder( 1 ) )
      VA->( dbGoto( nRecno ) )
      VA->( dbDelete() )
      VA->( DbPack() )
      VA->( dbGoTop() )
      REPLACE VA->VaOrden WITH ( VA->VaOrden - 1 ) ;
         FOR VA->VaOrden > nVaOrden
      VA->( dbSetOrder( 2 ) )
      VA->( dbSeek( Upper( cNewValorac ) ) )
      VA->( dbSetOrder( 1 ) )
      REPLACE VA->VaRecetas  WITH VA->VaRecetas + nVaRecetas
      VA->( dbCommit() )
   ELSE
      VA->( dbGoto( nRecno ) )
   ENDIF

   SELECT VA

   oGrid:Refresh( .T. )
   oGrid:SetFocus( .T. )
   oApp():nEdit --

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION VaSeleccion( cValoracion, oControl, nOrden, oParent )

   LOCAL oDlg, oBrowse, oCol, oBtnAceptar, oBtnCancel, oBNew, oBMod, oBDel, oBBus
   LOCAL lOk    := .F.
   LOCAL nRecno := VA->( RecNo() )
   LOCAL nOrder := VA->( ordNumber() )
   LOCAL nArea  := Select()
   LOCAL aPoint := AdjustWnd( oControl, 271 * 2, 150 * 2 )

   DEFINE DIALOG oDlg RESOURCE 'UT_AJENA1_' + oApp():cLanguage OF oParent ;
      TITLE "Selección de valoraciones de recetas"
   oDlg:SetFont( oApp():oFont )

   // siempre tengo ordenado por nombre

   SELECT VA
   VA->( dbSetOrder( 1 ) )
   VA->( dbGoTop() )

   IF ! VA->( dbSeek( cValoracion ) )
      VA->( dbGoTop() )
   ENDIF

   oBrowse := TXBrowse():New( oDlg )
   Ut_BrwRowConfig( oBrowse )
   oBrowse:cAlias := "VA"

   oCol := oBrowse:AddCol()
   oCol:bStrData := {|| VA->VaValorac }
   oCol:cHeader  := "Valoración"
   oCol:bLDClickData  := {|| ( lOk := .T., oDlg:End() )   }
   oCol:bClrSelFocus  := {|| { CLR_BLACK, oApp():nClrHL } }
   oBrowse:SetRDD()
   oBrowse:CreateFromResource( 110 )
   oBrowse:bKeyDown := {| nKey| VaSeTecla( nKey, oBrowse, oDlg, oBtnAceptar ) }

   REDEFINE BUTTON oBNew   ;
      ID 410 OF oDlg       ;
      ACTION VaEdita( oBrowse, 1,, oParent )

   REDEFINE BUTTON oBMod   ;
      ID 411 OF oDlg       ;
      ACTION VaEdita( oBrowse, 2,, oParent )

   REDEFINE BUTTON oBDel   ;
      ID 412 OF oDlg       ;
      ACTION VaBorra( oBrowse, )

   REDEFINE BUTTON oBBus   ;
      ID 413 OF oDlg       ;
      ACTION VaBusca( oBrowse,,, oParent )

   REDEFINE BUTTON oBtnAceptar   ;
      ID IDOK OF oDlg            ;
      ACTION ( lOk := .T., oDlg:End() )

   REDEFINE BUTTON oBtnCancel    ;
      ID IDCANCEL OF oDlg        ;
      ACTION ( lOk := .F., oDlg:End() )

   ACTIVATE DIALOG oDlg CENTERED       ;
      ON PAINT oDlg:Move( aPoint[ 1 ], aPoint[ 2 ],,, .T. )

   IF lOK
      cValoracion    := VA->VaValorac
      nOrden         := VA->VaOrden
      oControl:cText := cValoracion
   ENDIF

   VA->( dbSetOrder( nOrder ) )
   VA->( dbGoto( nRecno ) )

   SELECT ( nArea )

   RETURN NIL
/*_____________________________________________________________________________*/
FUNCTION VaSeTecla( nKey, oGrid, oDlg, oBtn )

   DO CASE
   CASE nKey == VK_RETURN
      oBtn:Click()
   CASE nKey == VK_ESCAPE
      oDlg:End()
   OTHERWISE
      IF nKey >= 96 .AND. nKey <= 105
         VaBusca( oGrid, Str( nKey - 96, 1 ),, oDlg )
      ELSEIF HB_ISSTRING( Chr( nKey ) )
         VaBusca( oGrid, Chr( nKey ),, oDlg )
      ENDIF
   ENDCASE

   RETURN NIL
/*_____________________________________________________________________________*/
FUNCTION VaBusca( oGrid, cChr, oCont, oParent )

   LOCAL nOrder   := VA->( ordNumber() )
   LOCAL nRecno   := VA->( RecNo() )
   LOCAL oDlg, oGet, cPicture
   LOCAL aSay1    := { " Introduzca la valoración" }
   LOCAL aSay2    := { "Valoración:" }
   LOCAL cGet     := Space( 20 )
   LOCAL lSeek    := .F.
   LOCAL lFecha   := .F.
   LOCAL aBrowse := {}

   oApp():nEdit ++

   DEFINE DIALOG oDlg RESOURCE 'UT_BUSCA_' + oApp():cLanguage OF oParent  ;
      TITLE i18n( "Búsqueda de valoraciones" )
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
      ENDIF
      MsgRun( 'Realizando la búsqueda...', oApp():cAppName + oApp():cVersion, ;
         {|| VaWildSeek( nOrder, cGet, aBrowse ) } )
      IF Len( aBrowse ) == 0
         MsgStop( "No se ha encontrado ninguna valoración." )
      ELSE
         VaEncontrados( aBrowse, oApp():oDlg )
      ENDIF
   ENDIF
   IF oCont != NIL
      RefreshCont( oCont, "VA" )
   ENDIF
	
   oApp():nEdit --
   oGrid:Refresh()
   oGrid:SetFocus( .T. )

   RETURN NIL
/*_____________________________________________________________________________*/
FUNCTION VaWildSeek( nOrder, cGet, aBrowse )

   LOCAL nRecno   := VA->( RecNo() )
	
   VA->( dbGoTop() )
   DO WHILE ! VA->( Eof() )
      IF cGet $ Upper( VA->VaValorac )
         AAdd( aBrowse, { VA->VaValorac, VA->VaOrden, VA->VaRecetas, VA->( RecNo() ) } )
      ENDIF
      VA->( dbSkip() )
   ENDDO
   VA->( dbGoto( nRecno ) )
   // ordeno la tabla por el 1 elemento
   ASort( aBrowse,,, {|aAut1, aAut2| Upper( aAut1[ 1 ] ) < Upper( aAut2[ 1 ] ) } )

   RETURN NIL
/*_____________________________________________________________________________*/
	
FUNCTION VaEncontrados( aBrowse, oParent )

   LOCAL oDlg, oBrowse, oBtnOk, oBtnCancel, lOk
   LOCAL nRecno := VA->( RecNo() )
	
   DEFINE DIALOG oDlg RESOURCE "DLG_ENCONTRADOS" ;
      TITLE i18n( "Resultado de la búsqueda" ) ;
      OF oParent
   oDlg:SetFont( oApp():oFont )
	
   oBrowse := TXBrowse():New( oDlg )
   Ut_BrwRowConfig( oBrowse )

   oBrowse:SetArray( aBrowse, .F. )
   oBrowse:aCols[ 1 ]:cHeader := "Valoración"
   oBrowse:aCols[ 2 ]:cHeader := "Orden"
   oBrowse:aCols[ 3 ]:cHeader := "Recetas"
   oBrowse:aCols[ 1 ]:nWidth  := 340
   oBrowse:aCols[ 2 ]:nWidth  := 100
   oBrowse:aCols[ 3 ]:nWidth  := 100
   oBrowse:aCols[ 4 ]:Hide()
   oBrowse:aCols[ 1 ]:nHeadStrAlign := 0
   oBrowse:aCols[ 1 ]:nDataStrAlign := 0
   oBrowse:aCols[ 2 ]:nHeadStrAlign := 0
   oBrowse:aCols[ 2 ]:nDataStrAlign := 0
   oBrowse:aCols[ 3 ]:nHeadStrAlign := 0
   oBrowse:aCols[ 3 ]:nDataStrAlign := 0
	
   oBrowse:CreateFromResource( 110 )
	
   VA->( dbGoto( aBrowse[ oBrowse:nArrayAt, 4 ] ) )
   AEval( oBrowse:aCols, {|oCol| oCol:bLDClickData := {|| VA->( dbGoto( aBrowse[ oBrowse:nArrayAt, 4 ] ) ), ;
      VaEdita( , 2,, oApp():oDlg ) } } )
   oBrowse:bKeyDown  := {| nKey| iif( nKey == VK_RETURN, ( VA->( dbGoto( aBrowse[ oBrowse:nArrayAt, 4 ] ) ), ;
      VaEdita( , 2,, oApp():oDlg ) ), ) }
   oBrowse:bChange    := {|| VA->( dbGoto( aBrowse[ oBrowse:nArrayAt, 4 ] ) ) }
   oBrowse:lHScroll  := .F.
   oDlg:oClient      := oBrowse
   oBrowse:nRowHeight := 20
	
   REDEFINE BUTTON oBtnOk ;
      ID IDOK OF oDlg     ;
      ACTION oDlg:End()
	
   REDEFINE BUTTON oBtnCancel ;
      ID IDCANCEL OF oDlg ;
      ACTION ( VA->( dbGoto( nRecno ) ), oDlg:End() )
	
   ACTIVATE DIALOG oDlg ;
      ON INIT DlgCenter( oDlg, oApp():oWndMain )
	
   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION VAClave( cValorac, oGet, nMode, nVaOrden )

   // nMode    1 nuevo registro
   // 2 modificación de registro
   // 3 duplicación de registro
   // 4 clave ajena
   LOCAL lreturn  := .F.
   LOCAL nRecno   := VA->( RecNo() )
   LOCAL nOrder   := VA->( ordNumber() )
   LOCAL nArea    := Select()

   IF Empty( cValorac )
      IF nMode == 4
         nVaOrden := 0
         RETURN .T.
      ELSE
         MsgStop( "Es obligatorio rellenar este campo." )
         RETURN .F.
      ENDIF
   ENDIF

   SELECT VA
   // cambio el orden del índice al literal
   VA->( dbSetOrder( 2 ) )
   VA->( dbGoTop() )

   IF VA->( dbSeek( Upper( cValorac ) ) )
      DO CASE
      CASE nMode == 1 .OR. nMode == 3
         lreturn := .F.
         MsgStop( "Valoración de receta existente." )
      CASE nMode == 2
         IF VA->( RecNo() ) == nRecno
            lreturn := .T.
         ELSE
            lreturn := .F.
            MsgStop( "Valoración de receta existente." )
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
         IF MsgYesNo( "Tipo de valoración inexistente. ¿ Desea darlo de alta ahora? ", 'Seleccione una opción' )
            lreturn := VaEdita(, 1,,, @cValorac )
         ELSE
            lreturn := .F.
         ENDIF
      ENDIF
   ENDIF

   IF lreturn == .F.
      oGet:cText( Space( 20 ) )
   ELSE
      nVaOrden := VA->VaOrden
   ENDIF

   VA->( dbSetOrder( nOrder ) )
   VA->( dbGoto( nRecno ) )

   SELECT ( nArea )

   RETURN lreturn
/*_____________________________________________________________________________*/

FUNCTION VaEjemplares( oGrid, oParent )

   LOCAL oDlg, oBrowse, oCol
   LOCAL nVaOrden    := VA->VaOrden
   LOCAL cVaValorac  := VA->VaValorac
   LOCAL aEpoca    := { '0000', '0001', '0010', '0011', '0100', '0101', '0110', '0111', ;
      '1000', '1001', '1010', '1011', '1100', '1101', '1110', '1111' }
   LOCAL i

   oApp():nEdit ++

   DEFINE DIALOG oDlg RESOURCE 'UT_EJEMPLARES'  ;
      TITLE 'Recetas de valoración: ' + cVaValorac OF oParent
   oDlg:SetFont( oApp():oFont )

   SELECT RE
   RE->( dbSetOrder( 9 ) )
   RE->( dbSetFilter( {|| StrZero( RE->ReVaOrden, 2 ) == StrZero( nVaOrden, 2 ) } ) )
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

   REDEFINE BUTTON ID IDOK OF oDlg ;
      PROMPT i18n( "&Aceptar" )   ;
      ACTION oDlg:End()

   ACTIVATE DIALOG oDlg ;
      ON INIT DlgCenter( oDlg, oApp():oWndMain )

   RE->( dbClearFilter() )

   SELECT VA
   oGrid:Refresh()
   oGrid:SetFocus( .T. )
   oApp():nEdit --

   RETURN NIL
/*_____________________________________________________________________________*/
FUNCTION VaImprime( oGrid, oParent )

   LOCAL nRecno   := VA->( RecNo() )
   LOCAL nOrder   := VA->( ordSetFocus() )
   LOCAL aCampos  := { "VAORDEN", "VAVALORAC", "VARECETAS" }
   LOCAL aTitulos := { "Orden", "Valoración", "Recetas" }
   LOCAL aWidth   := { 50, 50, 12 }
   LOCAL aShow    := { .T., .T., .T. }
   LOCAL aPicture := { "NO", "NO", "@E 99,999" }
   LOCAL aTotal   := { .F., .F., .T. }
   LOCAL oInforme

   oApp():nEdit ++
   oInforme := TInforme():New( aCampos, aTitulos, aWidth, aShow, aPicture, aTotal, "VA" )
   oInforme:Dialog()

   REDEFINE RADIO oInforme:oRadio VAR oInforme:nRadio ID 300 OF oInforme:oFld:aDialogs[ 1 ] ;
      ON CHANGE oInforme:Change()

   oInforme:Folders()

   IF oInforme:Activate()
      VA->( dbGoTop() )
      oInforme:Report()
      ACTIVATE REPORT oInforme:oReport ;
         ON END ( oInforme:oReport:StartLine(), oInforme:oReport:EndLine(), oInforme:oReport:StartLine(), ;
         oInforme:oReport:Say( 1, 'Total valoraciones: ' + Tran( oInforme:oReport:nCounter, '@E 999,999' ), 1 ), ;
         oInforme:oReport:EndLine() )
      oInforme:End( .T. )
      VA->( dbGoto( nRecno ) )
   ENDIF
   oApp():nEdit --
   oGrid:Refresh()
   oGrid:SetFocus( .T. )

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION VaList( aList, cData, oSelf )

   LOCAL aNewList := {}

   VA->( dbSetOrder( 1 ) )
   VA->( dbGoTop() )
   WHILE ! VA->( Eof() )
      IF At( Upper( cdata ), Upper( VA->VaValorac ) ) != 0 // UPPER( SubStr( oApp():amaterias[i,1], 1, Len( cData ) ) ) == UPPER( cData )
         AAdd( aNewList, { VA->VaValorac } )
      ENDIF
      VA->( dbSkip() )
   ENDDO

   RETURN aNewlist
