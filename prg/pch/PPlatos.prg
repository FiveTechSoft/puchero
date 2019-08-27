#include "FiveWin.ch"
#include "Report.ch"
#include "xBrowse.ch"
#include "vmenu.ch"
#include "splitter.ch"

STATIC oReport

FUNCTION Platos()

   LOCAL oBar, oCol, oCont
   LOCAL aBrowse
   LOCAL cState := GetPvProfString( "Browse", "PlState", "", oApp():cIniFile )
   LOCAL nOrder := Max( 2, Val( GetPvProfString( "Browse", "PlOrder", "2", oApp():cIniFile ) ) )
   LOCAL nRecno := Val( GetPvProfString( "Browse", "PlRecno", "1", oApp():cIniFile ) )
   LOCAL nSplit := Val( GetPvProfString( "Browse", "PlSplit", "102", oApp():cIniFile ) )
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

   SELECT PL
   oApp():oDlg := TFsdi():New( oApp():oWndMain )
   oApp():oDlg:cTitle := i18n( 'Gestión de tipos de plato' )
   oApp():oWndMain:oClient := oApp():oDlg
   oApp():oDlg:NewGrid( nSplit )

   Ut_BrwRowConfig( oApp():oGrid )

   oApp():oGrid:cAlias := "PL"

   oCol := oApp():oGrid:AddCol()
   oCol:Cargo    := 1
   oCol:AddResource( "16_SORT_A" )
   oCol:nHeadBmpNo    := 1
   oCol:nHeadBmpAlign := AL_RIGHT
   oCol:bStrData :=  {|| PL->PlTipo }
   oCol:cHeader  := i18n( "Tipo de plato" )
   oCol:nWidth   := 150

   ADD oCol TO oApp():oGrid DATA PL->PlRecetas ;
      HEADER "Recetas" PICTURE "@E 999,999" ;
      TOTAL 0 WIDTH 90

   FOR i := 1 TO Len( oApp():oGrid:aCols )
      oCol := oApp():oGrid:aCols[ i ]
      oCol:bLDClickData  := {|| PlEdita( oApp():oGrid, 2, oCont, oApp():oDlg, ) }
      oCol:bClrSelFocus  := {|| { CLR_BLACK, oApp():nClrHL } }
   NEXT

   oApp():oGrid:SetRDD()
   oApp():oGrid:CreateFromCode()
   oApp():oGrid:bChange  := {|| RefreshCont( oCont, "PL" ), oApp():oGrid:Maketotals() }
   oApp():oGrid:bKeyDown := {| nKey| PlTecla( nKey, oApp():oGrid, oCont, oApp():oDlg, ) }
   oApp():oGrid:RestoreState( cState )
   oApp():oGrid:nRowHeight  := 21
   oApp():oGrid:lFooter := .T.
   oApp():oGrid:bClrFooter := {|| { CLR_HRED, GetSysColor( 15 ) } }
   oApp():oGrid:MakeTotals()


   PL->( dbSetOrder( nOrder-- ) )
   IF nRecNo < PL->( LastRec() ) .AND. nRecno != 0
      PL->( dbGoto( nRecno ) )
   ELSE
      PL->( dbGoTop() )
   ENDIF

   @ 02, 05 VMENU oCont SIZE nSplit - 10, 18 OF oApp():oDlg  ;
      COLOR CLR_BLACK, GetSysColor( 15 )       ;
      FILLED   ;
      COLORSELECT 0, CLR_WHITE ;
      HEIGHT ITEM 22

   DEFINE TITLE OF oCont ;
      CAPTION tran( PL->( ordKeyNo() ), '@E 999,999' ) + " / " + tran( PL->( ordKeyCount() ), '@E 999,999' ) ;// strZero( RE->( ordKeyCount() ), 6 ) ;
   HEIGHT 25 ;
      COLOR GetSysColor( 9 ), oApp():nClrBar ;
      IMAGE "BB_MATER1"

   @ 24, 05 VMENU oBar SIZE nSplit - 10, 170 OF oApp():oDlg  ;
      COLOR CLR_BLACK, GetSysColor( 15 )       ;
      HEIGHT ITEM 22 XBOX
   oBar:nClrBox := Min( GetSysColor( 13 ), GetSysColor( 14 ) )

   DEFINE TITLE OF oBar ;
      CAPTION "Platos y cocinados"  ;
      HEIGHT 25 ;
      COLOR GetSysColor( 9 ), oApp():nClrBar ;
   OPENCLOSE

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Nuevo"              ;
      IMAGE "16_NUEVO"             ;
      ACTION PlEdita( oApp():oGrid, 1, oCont, oApp():oDlg, );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Modificar"          ;
      IMAGE "16_MODIF"             ;
      ACTION PlEdita( oApp():oGrid, 2, oCont, oApp():oDlg, );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Duplicar"           ;
      IMAGE "16_DUPLICA"           ;
      ACTION PlEdita( oApp():oGrid, 3, oCont, oApp():oDlg, );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Borrar"             ;
      IMAGE "16_BORRAR"            ;
      ACTION PlBorra( oApp():oGrid, oCont );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Agrupar categorias" ;
      IMAGE "16_AGRUPA"            ;
      ACTION PlAgrupa( oApp():oGrid, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Buscar"             ;
      IMAGE "16_BUSCA"             ;
      ACTION PlBusca( oApp():oGrid,, oCont, oApp():oDlg )  ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Imprimir"           ;
      IMAGE "16_IMPRIMIR"          ;
      ACTION PlImprime( oApp():oGrid, oApp():oDlg )         ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Ver recetas"        ;
      IMAGE "16_RECETAS"        ;
      ACTION PlEjemplares( oApp():oGrid, oApp():oDlg ) ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Enviar a Excel"     ;
      IMAGE "16_EXCEL"             ;
      ACTION ( CursorWait(), Ut_ExportXLS( oApp():oGrid, "Tipos de platos" ), CursorArrow() );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Configurar rejilla" ;
      IMAGE "16_GRID"              ;
      ACTION Ut_BrwColConfig( oApp():oGrid, "PlState" ) ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Salir"              ;
      IMAGE "16_SALIR"             ;
      ACTION oApp():oDlg:End()     ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      SEPARADOR HEIGHT 18

   @ oApp():oDlg:nGridBottom, nSplit + 2 TABS oApp():oTab ;
      OPTION nOrder SIZE oApp():oWndMain:nWidth() -80, 12 PIXEL OF oApp():oDlg ;
      ITEMS ' Entrada ', ' Primer plato ', ' Segundo plato ',  ;
      ' Postre ', ' Dulce ', ' Tipo de cocinado ';
      ACTION ( nOrder := oApp():oTab:nOption + 1,;
      PL->( dbSetOrder( nOrder ) ), ;
      PL->( dbGoTop() ),;
      oApp():oGrid:MakeTotals(),;
      oApp():oGrid:Refresh( .T. ),;
      RefreshCont( oCont, "PL" ) )

   oApp():oDlg:NewSplitter( nSplit, oCont, oBar )

   ACTIVATE DIALOG oApp():oDlg NOWAIT ;
      ON INIT ( ResizeWndMain(), oApp():oGrid:SetFocus() ) ;
      VALID ( oApp():oGrid:nLen := 0,;
      WritePProString( "Browse", "PlState", oApp():oGrid:SaveState(), oApp():cIniFile ),;
      WritePProString( "Browse", "PlOrder", LTrim( Str( PL->( ordNumber() ) ) ), oApp():cIniFile ),;
      WritePProString( "Browse", "PlRecno", LTrim( Str( PL->( RecNo() ) ) ), oApp():cIniFile ),;
      WritePProString( "Browse", "PlSplit", LTrim( Str( oApp():oSplit:nleft / 2 ) ), oApp():cIniFile ),;
      oBar:End(), dbCloseAll(), oApp():oDlg := NIL, oApp():oGrid := NIL, oApp():oTab := NIL, .T. )

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION PlEdita( oGrid, nMode, oCont, oParent, cPlato )

   LOCAL oDlg, oFld, oBmp
   LOCAL aTitle := { i18n( "Añadir " ),;
      i18n( "Modificar " ),;
      i18n( "Duplicar " ) }
   LOCAL aGet[ 1 ]
   LOCAL cPlPlato,;
      cPltipo,;
      nPlRecetas

   LOCAL nRecPtr := PL->( RecNo() )
   LOCAL nOrden  := PL->( ordNumber() )
   LOCAL nRecAdd
   LOCAL lDuplicado
   LOCAL cSay2   := 'Recetas:'
   LOCAL cTitulo := ''
   LOCAL cSay1   := ''
   LOCAL lreturn := .F.

   IF PL->( Eof() ) .AND. nMode != 1
      RETU NIL
   ENDIF

   oApp():nEdit ++
   IF nOrden < 2
      nOrden := 2
   ENDIF

   DO CASE
      // ojo que nOrden == 1 existe
   CASE nOrden == 1
      cTitulo := ''
      cSay1   := ''
   CASE nOrden == 2
      cTitulo := 'tipo de entrada'
      cSay1  := 'Entrada'
   CASE nOrden == 3
      cTitulo := 'tipo de 1er plato'
      cSay1  := '1er Plato'
   CASE nOrden == 4
      cTitulo := 'tipo de 2o plato'
      cSay1  := '2o Plato'
   CASE nOrden == 5
      cTitulo := 'tipo de postre'
      cSay1  := 'Postre'
   CASE nOrden == 6
      cTitulo := 'tipo de dulce  '
      cSay1  := 'Dulce'
   CASE nOrden == 7
      cTitulo := 'tipo de cocinado '
      cSay1  := 'Cocinado'
   ENDCASE


   IF nMode == 1
      PL->( dbAppend() )
      PL->PlPlato := Str( nOrden - 1, 1 )
      nRecAdd := PL->( RecNo() )
   ENDIF

   cPlTipo     := iif( nMode == 1 .AND. cPlato != nil, cPlato, PL->PlTipo )
   cPlPlato    := PL->PlPlato
   nPlRecetas  := PL->PlRecetas

   IF nMode == 3
      PL->( dbAppend() )
      nRecAdd := PL->( RecNo() )
   ENDIF

   DEFINE DIALOG oDlg RESOURCE "PL_EDIT_ES"  ;
      TITLE aTitle[ nMode ] + cTitulo     ;
      OF oParent
   oDlg:SetFont( oApp():oFont )

   REDEFINE SAY VAR cSay1     ID 11 OF oDlg
   REDEFINE SAY VAR cSay2     ID 13 OF oDlg
   REDEFINE SAY VAR Trans( nPlRecetas, "@E 99,999" ) ID 14 OF oDlg

   REDEFINE GET aGet[ 1 ] VAR cPlTipo    ;
      ID 12 OF oDlg UPDATE             ;
      VALID PlClave( cPlTipo, aGet[ 1 ], nMode )

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
      /* ___ actualizo el tipo de plato en la receta___________________________*/
      IF nMode == 2
         IF cPlTipo != PL->Pltipo
            SELECT RE
            RE->( dbSetOrder( 0 ) )
            RE->( dbGoTop() )
            IF cPlPlato $ '12345'
               REPLACE RE->ReTipo      ;
                  WITH cPlTipo         ;
                  FOR Upper( RTrim( RE->ReTipo ) ) == Upper( RTrim( PL->Pltipo ) )
            ELSE
               REPLACE RE->ReTipoCoc   ;
                  WITH cPlTipo         ;
                  FOR Upper( RTrim( RE->ReTipoCoc ) ) == Upper( RTrim( PL->Pltipo ) )
            ENDIF
            SELECT PL
         ENDIF
      ENDIF
      /* ___ guardo el registro _______________________________________________*/
      IF nMode == 2
         PL->( dbGoto( nRecPtr ) )
      ELSE
         PL->( dbGoto( nRecAdd ) )
      ENDIF
      REPLACE PL->PlPlato    WITH cPlPlato
      REPLACE PL->PlTipo     WITH cPlTipo
      REPLACE PL->PlRecetas  WITH nPlRecetas
      PL->( dbCommit() )
      IF cPlato != nil
         cPlato := PL->PlTipo
      ENDIF
   ELSE
      IF nMode == 1 .OR. nMode == 3
         PL->( dbGoto( nRecAdd ) )
         PL->( dbDelete() )
         PL->( DbPack() )
         PL->( dbGoto( nRecPtr ) )
      ENDIF
   ENDIF
   SELECT PL
   IF oCont != nil
      RefreshCont( oCont, "PL" )
   ENDIF
   IF oGrid != nil
      oGrid:Refresh()
      oGrid:SetFocus( .T. )
   ENDIF
   oApp():nEdit --

   RETURN lreturn
/*_____________________________________________________________________________*/

FUNCTION PlBorra( oGrid, oCont )

   LOCAL nRecord := PL->( RecNo() )
   LOCAL cKeyNext

   oApp():nEdit ++

   IF msgYesNo( i18n( "¿ Está seguro de querer borrar este tipo de plato ?" ) + CRLF + ;
         ( Trim( PL->PlTipo ) ), 'Seleccione una opción' )
      SELECT RE
      RE->( dbSetOrder( 0 ) )
      RE->( dbGoTop() )
      IF PL->PlPlato $ '12345'
         REPLACE RE->ReTipo      ;
            WITH Space( 30 )          ;
            FOR Upper( RTrim( RE->ReTipo ) ) == Upper( RTrim( PL->Pltipo ) )
      ELSE
         REPLACE RE->ReTipoCoc   ;
            WITH Space( 30 )          ;
            FOR Upper( RTrim( RE->ReTipoCoc ) ) == Upper( RTrim( PL->Pltipo ) )
      ENDIF
      SELECT PL
      PL->( dbSkip() )
      cKeyNext := PL->( ordKeyVal() )
      PL->( dbGoto( nRecord ) )
      PL->( dbDelete() )
      PL->( DbPack() )
      IF cKeyNext != nil
         PL->( dbSeek( cKeyNext ) )
      ELSE
         PL->( dbGoBottom() )
      ENDIF
   ENDIF

   IF oCont != nil
      RefreshCont( oCont, "PL" )
   ENDIF

   oGrid:Refresh( .T. )
   oGrid:SetFocus( .T. )
   oApp():nEdit --

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION PlTecla( nKey, oGrid, oCont, oDlg )

   DO CASE
   CASE nKey == VK_RETURN
      PlEdita( oGrid, 2, oCont, oDlg, )
   CASE nKey == VK_INSERT
      PlEdita( oGrid, 1, oCont, oDlg, )
   CASE nKey == VK_DELETE
      PlBorra( oGrid, oCont )
   CASE nKey == VK_ESCAPE
      oDlg:End()
   OTHERWISE
      IF nKey >= 96 .AND. nKey <= 105
         PlBusca( oGrid, Str( nKey - 96, 1 ), oCont, oDlg )
      ELSEIF HB_ISSTRING( Chr( nKey ) )
         PlBusca( oGrid, Chr( nKey ), oCont, oDlg )
      ENDIF
   ENDCASE

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION PlAgrupa( oGrid, oParent )

   LOCAL oDlg, oCombo
   LOCAL cTitle := i18n( "Agrupar " )
   LOCAL aSay[ 4 ]

   LOCAL cPlPlato,;
      cPltipo,;
      nPlRecetas
   LOCAL cTitulo
   LOCAL nRecetas
   LOCAL nRecno  := PL->( RecNo() )
   LOCAL nOrden  := PL->( ordNumber() )
   LOCAL nRecAdd
   LOCAL lDuplicado
   LOCAL aPlatos := {}
   LOCAL cPlato

   oApp():nEdit ++

   DO CASE
   CASE nOrden == 1
      cTitulo := ''
   CASE nOrden == 2
      cTitulo := 'tipo de entrada'
   CASE nOrden == 3
      cTitulo := 'tipo de 1er plato'
   CASE nOrden == 4
      cTitulo := 'tipo de 2o plato'
   CASE nOrden == 5
      cTitulo := 'tipo de postre'
   CASE nOrden == 6
      cTitulo := 'tipo de dulce  '
   CASE nOrden == 7
      cTitulo := 'tipo de cocinado '
   ENDCASE

   cPlPlato    := PL->PlPlato
   cPlTipo     := PL->PlTipo
   nPlRecetas  := PL->PlRecetas

   PL->( dbGoTop() )
   DO WHILE ! PL->( Eof() )
      AAdd( aPlatos, PL->PlTipo )
      PL->( dbSkip() )
   ENDDO
   cPlato := aPlatos[ 1 ]

   DEFINE DIALOG oDlg RESOURCE "UT_AGRUPA" ;
      TITLE cTitle + cTitulo OF oParent
   oDlg:SetFont( oApp():oFont )

   REDEFINE SAY aSay[ 1 ]       ;
      ID 10 OF oDlg COLOR CLR_BLACK, CLR_WHITE

   REDEFINE SAY aSay[ 2 ]       ;
      ID 11 OF oDlg

   REDEFINE SAY aSay[ 3 ]       ;
      PROMPT cPlTipo          ;
      COLOR CLR_HBLUE, GetSysColor( 15 ) ;
      ID 12 OF oDlg

   REDEFINE SAY aSay[ 4 ]       ;
      ID 13 OF oDlg

   REDEFINE COMBOBOX oCombo   ;
      VAR cPlato              ;
      ITEMS aplatos           ;
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
      SELECT RE
      RE->( dbSetOrder( 0 ) )
      RE->( dbGoTop() )
      IF cPlPlato $ '12345'
         REPLACE RE->ReTipo      ;
            WITH cPlato          ;
            FOR Upper( RTrim( RE->ReTipo ) ) == Upper( RTrim( cPltipo ) )
      ELSE
         REPLACE RE->ReTipoCoc   ;
            WITH cPlato             ;
            FOR Upper( RTrim( RE->ReTipoCoc ) ) == Upper( RTrim( cPltipo ) )
      ENDIF
      /* ___ borro el tipo de plato y reposiciono el puntero___________________*/
      SELECT PL
      PL->( dbGoto( nRecno ) )
      nRecetas := PL->PlRecetas
      PL->( dbDelete() )
      PL->( dbSeek( cPlato ) )
      REPLACE PL->PlRecetas  WITH PL->PlRecetas + nRecetas
      PL->( dbCommit() )
   ELSE
      PL->( dbGoto( nRecno ) )
   ENDIF

   SELECT PL

   oGrid:Refresh( .T. )
   oGrid:SetFocus( .T. )
   oApp():nEdit --

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION PlSeleccion( cPlato, oControl, nPlOrder, oParent, oVItem )

   LOCAL oDlg, oBrowse, oCol, oBtnAceptar, oBtnCancel, oBNew, oBMod, oBDel, oBBus
   LOCAL lOk    := .F.
   LOCAL nRecno := PL->( RecNo() )
   LOCAL nOrder := PL->( ordNumber() )
   LOCAL nArea  := Select()
   LOCAL aPoint := iif( oControl != NIL, AdjustWnd( oControl, 271 * 2, 150 * 2 ), { 1.3 * oVItem:nTop(), oApp():oGrid:nLeft } )
   LOCAL cTitulo
   LOCAL aCateg := { 'Entr.', '1er. P', '2o. P', 'Postre', 'Dulce' }

   oApp():nEdit ++
   DO CASE
      // ojo que nOrden == 1 existe
   CASE nPlOrder == 1
      cTitulo := ''
   CASE nPlOrder == 2
      cTitulo := 'tipo de entrada'
   CASE nPlOrder == 3
      cTitulo := 'tipo de 1er plato'
   CASE nPlOrder == 4
      cTitulo := 'tipo de 2o plato'
   CASE nPlOrder == 5
      cTitulo := 'tipo de postre'
   CASE nPlOrder == 6
      cTitulo := 'tipo de dulce  '
   CASE nPlOrder == 7
      cTitulo := 'tipo de cocinado '
   CASE nPlOrder == 9
      cTitulo := 'tipo de plato '
   ENDCASE

   DEFINE DIALOG oDlg RESOURCE 'UT_AJENA1_' + oApp():cLanguage;
      TITLE "Selección de " + cTitulo OF oParent
   oDlg:SetFont( oApp():oFont )

   // siempre tengo ordenado por nombre
   SELECT PL
   PL->( dbSetOrder( nPlOrder ) )
   PL->( dbGoTop() )

   IF ! PL->( dbSeek( cPlato ) )
      PL->( dbGoTop() )
   ENDIF

   oBrowse := TXBrowse():New( oDlg )
   Ut_BrwRowConfig( oBrowse )
   oBrowse:cAlias := "PL"
   IF nPlOrder == 9
      oCol := oBrowse:AddCol()
      oCol:bStrData := {|| aCateg[ Val( PL->PlPlato ) ] }
      oCol:cHeader  := 'Categoría'
      oCol:bLDClickData  := {|| ( lOk := .T., oDlg:End() )   }
      oCol:bClrSelFocus  := {|| { CLR_BLACK, oApp():nClrHL } }
   ENDIF
	
   oCol := oBrowse:AddCol()
   oCol:bStrData := {|| PL->PlTipo }
   oCol:cHeader  := iif( nPlOrder < 7, "Tipo de plato", "Tipo de cocinado" )
   oCol:bLDClickData  := {|| ( lOk := .T., oDlg:End() )   }
   oCol:bClrSelFocus  := {|| { CLR_BLACK, oApp():nClrHL } }
   oBrowse:SetRDD()
   oBrowse:CreateFromResource( 110 )
   IF nPlOrder != 9
      oBrowse:bKeyDown := {| nKey| PlSeTecla( nKey, oBrowse, oDlg, oBtnAceptar ) }
   ENDIF

   REDEFINE BUTTON oBNew   ;
      ID 410 OF oDlg       ;
      ACTION PlEdita( oBrowse, 1,, oDlg, )

   REDEFINE BUTTON oBMod   ;
      ID 411 OF oDlg       ;
      ACTION PlEdita( oBrowse, 2,, oDlg, )

   REDEFINE BUTTON oBDel   ;
      ID 412 OF oDlg       ;
      ACTION PlBorra( oBrowse, )

   REDEFINE BUTTON oBBus   ;
      ID 413 OF oDlg       ;
      ACTION PlBusca( oBrowse,,, oDlg ) WHEN nPlOrder != 9

   REDEFINE BUTTON oBtnAceptar   ;
      ID IDOK OF oDlg            ;
      ACTION ( lOk := .T., oDlg:End() )

   REDEFINE BUTTON oBtnCancel    ;
      ID IDCANCEL OF oDlg        ;
      ACTION ( lOk := .F., oDlg:End() )

   ACTIVATE DIALOG oDlg CENTERED       ;
      ON PAINT oDlg:Move( aPoint[ 1 ], aPoint[ 2 ],,, .T. )

   IF lOK
      IF nPlOrder == 9
         cPlato := PL->PlPlato + PL->PlTipo
      ELSE
         cPlato := PL->PlTipo
      ENDIF
      IF oControl != NIL
         oControl:cText := PL->PlTipo
      ENDIF
   ENDIF

   PL->( dbSetOrder( nOrder ) )
   PL->( dbGoto( nRecno ) )
   oApp():nEdit --

   SELECT ( nArea )

   RETURN NIL
/*_____________________________________________________________________________*/
FUNCTION PlSeTecla( nKey, oGrid, oDlg, oBtn )

   DO CASE
   CASE nKey == VK_RETURN
      oBtn:Click()
   CASE nKey == VK_ESCAPE
      oDlg:End()
   OTHERWISE
      IF nKey >= 96 .AND. nKey <= 105
         PlBusca( oGrid, Str( nKey - 96, 1 ),, oDlg )
      ELSEIF HB_ISSTRING( Chr( nKey ) )
         PlBusca( oGrid, Chr( nKey ),, oDlg )
      ENDIF
   ENDCASE

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION PlBusca( oGrid, cChr, oCont, oParent )

   LOCAL nOrder   := PL->( ordNumber() ) - 1 // el primer TAG es sin tipo
   LOCAL nRecno   := PL->( RecNo() )
   LOCAL oDlg, oGet, cPicture
   LOCAL aSay1    := { " Introduzca el tipo de entrada a buscar",;
      " Introduzca el tipo de 1er plato a buscar",;
      " Introduzca el tipo de 2er plato a buscar",;
      " Introduzca el tipo de postre a buscar",;
      " Introduzca el tipo de dulce a buscar",;
      " Introduzca el tipo de cocinado a buscar" }
   LOCAL aSay2    := { "Ensalada:",;
      "1er plato:",;
      "2o plato:",;
      "Postre:",;
      "Dulce:",;
      "Cocinado:"     }
   LOCAL cGet     := Space( 30 )
   LOCAL lSeek    := .F.
   LOCAL lFecha   := .F.
   LOCAL aBrowse := {}

   oApp():nEdit ++

   DEFINE DIALOG oDlg RESOURCE 'UT_BUSCA_' + oApp():cLanguage   ;
      TITLE i18n( "Búsqueda de tipos de plato" ) OF oParent
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
         {|| PlWildSeek( nOrder, cGet, aBrowse ) } )
      IF Len( aBrowse ) == 0
         MsgStop( "No se ha encontrado ningún plato." )
      ELSE
         PlEncontrados( aBrowse, oApp():oDlg )
      ENDIF
   ENDIF
   IF oCont != NIL
      RefreshCont( oCont, "PL" )
   ENDIF

   oApp():nEdit --
   oGrid:Refresh()
   oGrid:SetFocus( .T. )

   RETURN NIL
/*_____________________________________________________________________________*/
FUNCTION PlWildSeek( nOrder, cGet, aBrowse )

   LOCAL nRecno   := Pl->( RecNo() )

   PL->( dbGoTop() )
   DO WHILE ! PL->( Eof() )
      IF cGet $ Upper( PL->Pltipo )
         AAdd( aBrowse, { PL->Pltipo, PL->PlRecetas, PL->( RecNo() ) } )
      ENDIF
      PL->( dbSkip() )
   ENDDO
   PL->( dbGoto( nRecno ) )
   // ordeno la tabla por el 1 elemento
   ASort( aBrowse,,, {|aAut1, aAut2| Upper( aAut1[ 1 ] ) < Upper( aAut2[ 1 ] ) } )

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION PlEncontrados( aBrowse, oParent )

   LOCAL oDlg, oBrowse, oBtnOk, oBtnCancel, lOk
   LOCAL nRecno := PL->( RecNo() )

   DEFINE DIALOG oDlg RESOURCE "DLG_ENCONTRADOS" ;
      TITLE i18n( "Resultado de la búsqueda" ) ;
      OF oParent
   oDlg:SetFont( oApp():oFont )

   oBrowse := TXBrowse():New( oDlg )
   Ut_BrwRowConfig( oBrowse )

   oBrowse:SetArray( aBrowse, .F. )
   oBrowse:aCols[ 1 ]:cHeader := "Plato"
   oBrowse:aCols[ 2 ]:cHeader := "Recetas"
   oBrowse:aCols[ 1 ]:nWidth  := 340
   oBrowse:aCols[ 2 ]:nWidth  := 100
   oBrowse:aCols[ 3 ]:Hide()
   oBrowse:aCols[ 1 ]:nHeadStrAlign := 0
   oBrowse:aCols[ 1 ]:nDataStrAlign := 0
   oBrowse:aCols[ 2 ]:nHeadStrAlign := 0
   oBrowse:aCols[ 2 ]:nDataStrAlign := 0

   oBrowse:CreateFromResource( 110 )

   PL->( dbGoto( aBrowse[ oBrowse:nArrayAt, 3 ] ) )
   AEval( oBrowse:aCols, {|oCol| oCol:bLDClickData := {|| PL->( dbGoto( aBrowse[ oBrowse:nArrayAt, 3 ] ) ), ;
      PlEdita( , 2,, oApp():oDlg ) } } )
   oBrowse:bKeyDown  := {| nKey| iif( nKey == VK_RETURN, ( PL->( dbGoto( aBrowse[ oBrowse:nArrayAt, 3 ] ) ), ;
      PlEdita( , 2,, oApp():oDlg ) ), ) }
   oBrowse:bChange    := {|| PL->( dbGoto( aBrowse[ oBrowse:nArrayAt, 3 ] ) ) }
   oBrowse:lHScroll  := .F.
   oDlg:oClient      := oBrowse
   oBrowse:nRowHeight := 20

   REDEFINE BUTTON oBtnOk ;
      ID IDOK OF oDlg     ;
      ACTION oDlg:End()

   REDEFINE BUTTON oBtnCancel ;
      ID IDCANCEL OF oDlg ;
      ACTION ( PL->( dbGoto( nRecno ) ), oDlg:End() )

   ACTIVATE DIALOG oDlg ;
      ON INIT DlgCenter( oDlg, oApp():oWndMain )

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION PlClave( cPlato, oGet, nMode, nPlOrder )

   // nMode    1 nuevo registro
   // 2 modificación de registro
   // 3 duplicación de registro
   // 4 clave ajena
   LOCAL lreturn  := .F.
   LOCAL nRecno   := PL->( RecNo() )
   LOCAL nOrder   := PL->( ordNumber() )
   LOCAL nArea    := Select()

   IF Empty( cPlato )
      IF nMode == 4
         RETURN .T.
      ELSE
         MsgStop( "Es obligatorio rellenar este campo." )
         RETURN .F.
      ENDIF
   ENDIF

   SELECT PL
   // No cambio el orden del índice sino hay nPlOrder
   IF nPlOrder != nil
      PL->( dbSetOrder( nPlOrder ) )
   ENDIF
   PL->( dbGoTop() )

   IF PL->( dbSeek( Upper( cPlato ) ) )
      DO CASE
      CASE nMode == 1 .OR. nMode == 3
         lreturn := .F.
         MsgStop( "Categoría de plato o cocinado existente." )
      CASE nMode == 2
         IF PL->( RecNo() ) == nRecno
            lreturn := .T.
         ELSE
            lreturn := .F.
            MsgStop( "Categoría de plato o cocinado existente." )
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
         IF MsgYesNo( "Tipo de plato o cinexistente. ¿ Desea darlo de alta ahora? ", 'Seleccione una opción' )
            lreturn := PlEdita(, 1,,, @cPlato )
         ELSE
            lreturn := .F.
         ENDIF
      ENDIF
   ENDIF

   IF lreturn == .F.
      oGet:cText( Space( 30 ) )
   ENDIF

   // PL->( DbSetOrder( nOrder ) )
   PL->( dbGoto( nRecno ) )

   SELECT ( nArea )

   RETURN lreturn
/*_____________________________________________________________________________*/

FUNCTION PlEjemplares( oGrid, oParent )

   LOCAL oDlg, oBrowse, oCol
   LOCAL cPlPlato := PL->PlPlato
   LOCAL cPlTipo  := PL->PlTipo
   LOCAL aEpoca    := { '0000', '0001', '0010', '0011', '0100', '0101', '0110', '0111', ;
      '1000', '1001', '1010', '1011', '1100', '1101', '1110', '1111' }
   LOCAL i
   LOCAL cTitle

   oApp():nEdit ++
   IF cPlPlato $ '12345'
      cTitle := "Recetas de tipo de plato: " + cPltipo
      RE->( dbSetOrder( 3 ) )
      RE->( dbSetFilter( {|| RE->RePlato + Trim( RE->ReTipo ) == cPlPlato + Trim( cPlTipo ) } ) )
      RE->( dbGoTop() )
   ELSE
      cTitle := "Recetas de tipo de cocinado: " + cPltipo
      RE->( dbSetOrder( 4 ) )
      RE->( dbSetFilter( {|| Trim( RE->ReTipoCoc ) == Trim( cPlTipo ) } ) )
      RE->( dbGoTop() )
   ENDIF

   DEFINE DIALOG oDlg RESOURCE 'UT_EJEMPLARES'  ;
      TITLE cTitle OF oParent
   oDlg:SetFont( oApp():oFont )

   oBrowse := TXBrowse():New( oDlg )
   Ut_BrwRowConfig( oBrowse )
   oBrowse:cAlias := "RE"

   oCol := oBrowse:AddCol()
   oCol:bStrData := {|| RE->ReTitulo }
   oCol:cHeader  := "Receta"
   oCol:nWidth   := 270

   oCol := oBrowse:AddCol()
   oCol:bStrData := {|| RE->ReCodigo }
   oCol:cHeader  := "Código"
   oCol:nWidth   := 70

   oCol := oBrowse:AddCol()
   oCol:bStrData := {|| RE->ReAutor }
   oCol:cHeader  := "Autor"
   oCol:nWidth   := 190

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
   oCol:nWidth        := 60
   oCol:nDataBmpAlign := 2

   oCol := oBrowse:AddCol()
   oCol:AddResource( "BR_Dif1" )
   oCol:AddResource( "BR_Dif2" )
   oCol:AddResource( "BR_Dif3" )
   oCol:cHeader       := i18n( "Dificultad" )
   oCol:bBmpData      := {|| Max( RE->ReDificu, 1 ) }
   oCol:nWidth        := 50
   oCol:nDataBmpAlign := 2

   oCol := oBrowse:AddCol()
   oCol:AddResource( "BR_CAL1C" )
   oCol:AddResource( "BR_CAL2C" )
   oCol:AddResource( "BR_CAL3C" )
   oCol:cHeader       := i18n( "Calorias" )
   oCol:bBmpData      := {|| Max( RE->ReCalori, 1 ) }
   oCol:nWidth        := 50
   oCol:nDataBmpAlign := 2

 /*
 oCol := oBrowse:AddCol()
   oCol:AddResource("BR_PROP1")
   oCol:AddResource("BR_PROP2")
   oCol:cHeader       := i18n("Incorp.")
   oCol:bBmpData      := { || RE->ReIncorp }
   oCol:nWidth        := 50
   oCol:nDataBmpAlign := 2
 */
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

   SELECT PL
   oGrid:Refresh()
   oGrid:SetFocus( .T. )
   oApp():nEdit --

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION PlImprime( oGrid, oParent )

   LOCAL nRecno   := PL->( RecNo() )
   LOCAL nOrder   := PL->( ordSetFocus() )
   LOCAL aCampos  := { "PLPLATO", "PLTIPO", "PLRECETAS" }
   LOCAL aTitulos := iif( PL->PlPlato != '6', ;
      { "Categoría", "Tipo de plato", "Recetas" }, ;
      { "Categoría", "Tipo de cocinado", "Recetas" } )
   LOCAL aWidth   := { 50, 50, 12 }
   LOCAL aShow    := { .T., .T., .T. }
   LOCAL aPicture := { "PL01", "NO", "@E 99,999" }
   LOCAL aTotal   := { .F., .F., .T. }
   LOCAL oInforme

   oApp():nEdit ++
   oInforme := TInforme():New( aCampos, aTitulos, aWidth, aShow, aPicture, aTotal, "PL" )
   oInforme:Dialog()

   REDEFINE RADIO oInforme:oRadio VAR oInforme:nRadio ID 300, 301 OF oInforme:oFld:aDialogs[ 1 ]

   oInforme:Folders()

   IF oInforme:Activate()
      PL->( dbGoTop() )
      oInforme:Report()
      IF oInforme:nRadio == 2
         PL->( dbSetOrder( 8 ) )
      ENDIF
      ACTIVATE REPORT oInforme:oReport ;
         ON END ( oInforme:oReport:StartLine(), oInforme:oReport:EndLine(), oInforme:oReport:StartLine(), ;
         oInforme:oReport:Say( 1, 'Total tipos de plato: ' + Tran( oInforme:oReport:nCounter, '@E 999,999' ), 1 ), ;
         oInforme:oReport:EndLine() )
      oInforme:End( .T. )
      PL->( dbGoto( nRecno ) )
   ENDIF

   oApp():nEdit --
   oGrid:Refresh()
   oGrid:SetFocus( .T. )

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION PlList( aList, cData, oSelf )

   LOCAL aNewList := {}

   // PL->( dbSetOrder(1) )
   PL->( dbGoTop() )
   WHILE ! PL->( Eof() )
      IF At( Upper( cdata ), Upper( PL->PlTipo ) ) != 0 // UPPER( SubStr( oApp():amaterias[i,1], 1, Len( cData ) ) ) == UPPER( cData )
         AAdd( aNewList, { PL->PlTipo } )
      ENDIF
      PL->( dbSkip() )
   ENDDO

   RETURN aNewlist

FUNCTION PlListC( aList, cData, oSelf )

   LOCAL aNewList := {}

   PL->( dbSetOrder( 7 ) )
   PL->( dbGoTop() )
   WHILE ! PL->( Eof() )
      IF At( Upper( cdata ), Upper( PL->PlTipo ) ) != 0 // UPPER( SubStr( oApp():amaterias[i,1], 1, Len( cData ) ) ) == UPPER( cData )
         AAdd( aNewList, { PL->PlTipo } )
      ENDIF
      PL->( dbSkip() )
   ENDDO

   RETURN aNewlist
