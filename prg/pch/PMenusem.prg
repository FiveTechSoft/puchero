#include "FiveWin.ch"
#include "Report.ch"
#include "Image.ch"
#include "zoomimage.ch"
#include "xBrowse.ch"
#include "splitter.ch"
#include "vmenu.ch"

#define  SELECCIONADA   "X"
#define  NOSELECCIONADA " "

STATIC oReport

FUNCTION MenuSemanal()

   LOCAL oBar, oBar1, oBar2
   LOCAL oCol
   LOCAL aBrowse
   LOCAL cState := GetPvProfString( "Browse", "MsState", "", oApp():cInifile )
   LOCAL nOrder := Max( Val( GetPvProfString( "Browse", "MsOrder", "1", oApp():cInifile ) ), 1 )
   LOCAL nRecno := Val( GetPvProfString( "Browse", "MsRecno", "1", oApp():cInifile ) )
   LOCAL nSplit := Val( GetPvProfString( "Browse", "MsSplit", "102", oApp():cInifile ) )
   LOCAL nRecTab
   LOCAL oCont
   LOCAL i
   LOCAL aClient
   LOCAL oMenuCompra

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

   oApp():oDlg := TFsdi():New( oApp():oWndMain )
   oApp():oDlg:cTitle := i18n( 'Gestión de menús semanales' )
   oApp():oWndMain:oClient := oApp():oDlg
   oApp():oDlg:NewGrid( nSplit )

   Ut_BrwRowConfig( oApp():oGrid )

   SELECT MS
   oApp():oGrid:cAlias := "MS"

   oCol := oApp():oGrid:AddCol()
   oCol:Cargo    := 1
   oCol:bLClickHeader := {|| MsSort( 1, oCont ) }
   oCol:AddResource( "16_SORT_A" )
   oCol:AddResource( "16_SORT_B" )
   oCol:nHeadBmpNo    := iif( nOrder == oCol:Cargo, 1, 2 )
   oCol:nHeadBmpAlign := AL_RIGHT
   oCol:bStrData :=  {|| MS->MsCodigo }
   oCol:cHeader  := i18n( "Código" )
   oCol:nWidth   := 50

   oCol := oApp():oGrid:AddCol()
   oCol:Cargo    := 2
   oCol:bLClickHeader := {|| MsSort( 2, oCont ) }
   oCol:AddResource( "16_SORT_A" )
   oCol:AddResource( "16_SORT_B" )
   oCol:nHeadBmpNo    := iif( nOrder == oCol:Cargo, 1, 2 )
   oCol:nHeadBmpAlign := AL_RIGHT
   oCol:bStrData :=  {|| MS->MsDescrip }
   oCol:cHeader  := i18n( "Descripción" )
   oCol:nWidth   := 150

   oCol := oApp():oGrid:AddCol()
   oCol:Cargo    := 3
   oCol:bLClickHeader := {|| MsSort( 3, oCont ) }
   oCol:AddResource( "16_SORT_A" )
   oCol:AddResource( "16_SORT_B" )
   oCol:nHeadBmpNo    := iif( nOrder == oCol:Cargo, 1, 2 )
   oCol:nHeadBmpAlign := AL_RIGHT
   oCol:bStrData :=  {|| DToC( MS->MsFchPrep ) }
   oCol:cHeader  := i18n( "Fch. preparación" )
   oCol:nWidth   := 120

   oCol := oApp():oGrid:AddCol()
   oCol:bStrData :=  {|| tran( MS->MsComens, "999" ) }
   oCol:cHeader  := i18n( "Comensales" )
   oCol:nWidth   := 120
	
   oCol := oApp():oGrid:AddCol()
   oCol:bStrData :=  {|| MsGetRecetas( MS->MsCodigo ) }
   oCol:cHeader  := i18n( "Recetas" )
   oCol:nWidth   := 120


   // añado columnas con bitmaps
   FOR i := 1 TO Len( oApp():oGrid:aCols )
      oCol := oApp():oGrid:aCols[ i ]
      oCol:bLDClickData  := {|| MsEdita( oApp():oGrid, 2, oCont, oApp():oDlg ) }
   NEXT

   oApp():oGrid:SetRDD()
   oApp():oGrid:CreateFromCode()
   oApp():oGrid:bChange     := {|| RefreshCont( oCont, "MS" ) }
   oApp():oGrid:bKeyDown    := {| nKey| MsTecla( nKey, oApp():oGrid, oCont, oApp():oDlg ) }

   oApp():oGrid:RestoreState( cState )

   MS->( dbSetOrder( nOrder ) )

   IF nRecNo < MS->( LastRec() ) .AND. nRecno != 0
      MS->( dbGoto( nRecno ) )
   ELSE
      MS->( dbGoTop() )
   ENDIF

   @ 02, 05 VMENU oCont SIZE nSplit - 10, 17.5 OF oApp():oDlg  ;
      COLOR CLR_BLACK, GetSysColor( 15 )       ;
      FILLED   ;
      COLORSELECT 0, CLR_WHITE ;
      HEIGHT ITEM 22

   DEFINE TITLE OF oCont ;
      CAPTION tran( MS->( ordKeyNo() ), '@E 999,999' ) + " / " + tran( MS->( ordKeyCount() ), '@E 999,999' ) ;
      HEIGHT 25         ;
      COLOR GetSysColor( 9 ), oApp():nClrBar ;
      IMAGE "BB_MENUSEM"

   @ 24, 05 VMENU oBar SIZE nSplit - 10, 196 OF oApp():oDlg  ;
      COLOR CLR_BLACK, GetSysColor( 15 ) ;
      HEIGHT ITEM 22 XBOX
   oBar:nClrBox := Min( GetSysColor( 13 ), GetSysColor( 14 ) )

   DEFINE TITLE OF oBar ;
      CAPTION "Menús semanales"   ;
      HEIGHT 25 ;
      COLOR GetSysColor( 9 ), oApp():nClrBar ;
      OPENCLOSE

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Nuevo"              ;
      IMAGE "16_NUEVO"             ;
      ACTION MsEdita( oApp():oGrid, 1, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Modificar"          ;
      IMAGE "16_MODIF"             ;
      ACTION MsEdita( oApp():oGrid, 2, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Duplicar"           ;
      IMAGE "16_DUPLICA"           ;
      ACTION MsEdita( oApp():oGrid, 3, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Borrar"             ;
      IMAGE "16_BORRAR"            ;
      ACTION MsBorra( oApp():oGrid, oCont );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Buscar"             ;
      IMAGE "16_BUSCA"             ;
      ACTION MsBusca( oApp():oGrid,, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Imprimir"           ;
      IMAGE "16_IMPRIMIR"          ;
      ACTION MsImprime( oApp():oGrid, oApp():oDlg )   ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 10

   IF oApp():lBcnKitchen
      MENU oMenuCompra POPUP 2007
      MENUITEM "Lista de la compra completa" ;
         ACTION MsCompra( oApp():oGrid, oApp():oDlg, .F. )
      SEPARATOR
      MENUITEM "Totalizado de ingredientes por proveedor" ;
         ACTION MsBcnKitchen1( oApp():oGrid, oApp():oDlg, .F. )
      MENUITEM "Totalizado de ingredientes por proveedor y día/hora" ;
         ACTION MsBcnKitchen2( oApp():oGrid, oApp():oDlg, .F. )
      MENUITEM "Totalizado de ingredientes por día/hora" ;
         ACTION MsBcnKitchen3( oApp():oGrid, oApp():oDlg, .F. )
      ENDMENU

      DEFINE VMENUITEM OF oBar        ;
         CAPTION "Lista de la compra" ;
         IMAGE "16_COMPRA"            ;
         MENU oMenuCompra       ;
         LEFT 10
      DEFINE VMENUITEM OF oBar        ;
         CAPTION "Anotar preparación" ;
         IMAGE "16_FECHA_OK"          ;
         ACTION MsPreparacion( oApp():oGrid, oApp():oDlg ) ;
         LEFT 10
   ELSE
      DEFINE VMENUITEM OF oBar        ;
         CAPTION "Lista de la compra" ;
         IMAGE "16_COMPRA"            ;
         ACTION MsCompra( oApp():oGrid, oApp():oDlg, .F. ) ;
         LEFT 10
			
      DEFINE VMENUITEM OF oBar        ;
         CAPTION "Anotar preparación" ;
         IMAGE "16_FECHA_OK"          ;
         ACTION MsPreparacion( oApp():oGrid, oApp():oDlg ) ;
         LEFT 10
   ENDIF
   DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Enviar a Excel"     ;
      IMAGE "16_EXCEL"             ;
      ACTION ( CursorWait(), Ut_ExportXLS( oApp():oGrid, "Menús semanales" ), CursorArrow() );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Configurar rejilla" ;
      IMAGE "16_GRID"              ;
      ACTION Ut_BrwColConfig( oApp():oGrid, "MsState" ) ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Salir"              ;
      IMAGE "16_SALIR"             ;
      ACTION oApp():oDlg:End()              ;
      LEFT 10

   @ oApp():oDlg:nGridBottom, nSplit + 2 TABS oApp():oTab ;
      OPTION nOrder SIZE oApp():oWndMain:nWidth() -80, 12 PIXEL OF oApp():oDlg ;
      ITEMS ' Código ', ' Descripción ', ' Fch. Preparación ';
      COLOR CLR_BLACK, GetSysColor( 15 ) -RGB( 30, 30, 30 ) ;
      ACTION MsSort( oApp():otab:noption, oCont )

   oApp():oDlg:NewSplitter( nSplit, oCont, oBar )

   // ResizeWndMain()
   ACTIVATE DIALOG oApp():oDlg NOWAIT ;
      ON INIT ( ResizeWndMain(), oApp():oGrid:SetFocus() ) ;
      VALID ( oApp():oGrid:nLen := 0,;
      WritePProString( "Browse", "MsState", oApp():oGrid:SaveState(), oApp():cInifile ),;
      WritePProString( "Browse", "MsOrder", LTrim( Str( MS->( ordNumber() ) ) ), oApp():cInifile ),;
      WritePProString( "Browse", "MsRecno", LTrim( Str( MS->( RecNo() ) ) ), oApp():cInifile ),;
      WritePProString( "Browse", "MsSplit", LTrim( Str( oApp():oSplit:nleft / 2 ) ), oApp():cInifile ),;
      oBar:End(), dbCloseAll(), oApp():oDlg := NIL, oApp():oGrid := NIL, oApp():oTab := NIL, oApp():oSplit := NIL, .T. )

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION MsSeleccion( cMsCodigo, oControl1, oParent, oControl2 )

   LOCAL oDlg, oBrowse, oCol, oBtnAceptar, oBtnCancel, oBNew, oBMod, oBDel
   LOCAL lOk    := .F.
   LOCAL nRecno := MS->( RecNo() )
   LOCAL nOrder := MS->( ordNumber() )
   LOCAL nArea  := Select()
   LOCAL aPoint := AdjustWnd( oControl1, 271 * 2, 150 * 2 )

   DEFINE DIALOG oDlg RESOURCE 'UT_AJENA1_' + oApp():cLanguage OF oParent;
      TITLE i18n( "Selección de menús semanales" )
   oDlg:SetFont( oApp():oFont )

   SELECT MS
   MS->( dbSetOrder( 1 ) )
   MS->( dbGoTop() )

   IF ! MS->( dbSeek( cMsCodigo ) )
      MS->( dbGoTop() )
   ENDIF

   oBrowse := TXBrowse():New( oDlg )
   Ut_BrwRowConfig( oBrowse )
   oBrowse:cAlias := "MS"

   oCol := oBrowse:AddCol()
   oCol:bStrData := {|| MS->MsCodigo }
   oCol:cHeader  := "Menú"
   oCol:nWidth   := 90
   oCol:bLDClickData  := {|| ( lOk := .T., oDlg:End() )   }
   oCol := oBrowse:AddCol()
   oCol:bStrData := {|| MS->MsDescrip }
   oCol:cHeader  := "Descripción"
   oCol:nWidth   := 190
   oCol:bLDClickData  := {|| ( lOk := .T., oDlg:End() )   }
   oBrowse:SetRDD()
   oBrowse:CreateFromResource( 110 )
   oBrowse:bKeyDown := {| nKey| MsTecla( nKey, oBrowse, oDlg, oBtnAceptar ) }

   REDEFINE BUTTON oBNew   ;
      ID 410 OF oDlg       ;
      ACTION MsEdita( oBrowse, 1,, oDlg )

   REDEFINE BUTTON oBMod   ;
      ID 411 OF oDlg       ;
      ACTION MsEdita( oBrowse, 2,, oDlg )

   REDEFINE BUTTON oBDel   ;
      ID 412 OF oDlg       ;
      ACTION MsBorra( oBrowse, )

   REDEFINE BUTTON oBtnAceptar   ;
      ID IDOK OF oDlg            ;
      ACTION ( lOk := .T., oDlg:End() )

   REDEFINE BUTTON oBtnCancel    ;
      ID IDCANCEL OF oDlg        ;
      ACTION ( lOk := .F., oDlg:End() )

   ACTIVATE DIALOG oDlg CENTERED       ;
      ON PAINT oDlg:Move( aPoint[ 1 ], aPoint[ 2 ],,, .T. )

   IF lOK
      oControl1:cText := MS->MsCodigo
      IF oControl2 != NIL
         oControl2:cText := MS->MsDescrip
      ENDIF
   ENDIF

   MS->( dbSetOrder( nOrder ) )
   MS->( dbGoto( nRecno ) )

   SELECT ( nArea )

   RETURN NIL
/*_____________________________________________________________________________*/
FUNCTION MsEdita( oGrid, nMode, oCont, oParent )

   LOCAL oDlg, oFld, oLbx, oCol
   LOCAL cState := GetPvProfString( "Browse", "ReMsState", "", oApp():cInifile )
   LOCAL aTitle := { i18n( "Añadir menú semanal" ),;
      i18n( "Modificar menú semanal" ),;
      i18n( "Duplicar menú semanal" ) }
   LOCAL aGet[ 5 ], aSay[ 4 ], aBtn[ 5 ]
   LOCAL cMsCodigo,;
      cMsDescrip,;
      dMsFchPrep,;
      nMsComens
   LOCAL cReMsCodigo, nReMsComens
   LOCAL aRe := {}
   LOCAL aTPlato   := { 'Entradas ', '1er Plato', '2o Plato ', 'Postre   ', 'Dulce    ', 'Otro     ' }
   LOCAL aDiasL     := { 'Lunes    ', 'Martes   ', 'Miercoles', 'Jueves   ', 'Viernes  ', 'Sábado   ', 'Domingo  ' }
   LOCAL aDiasC     := { ' L ', ' M ', ' X ', ' J ', ' V ', ' S ', ' D ' }
   LOCAL aComidasL  := { 'Desayuno    ', 'Media mañana', 'Almuerzo    ', 'Merienda    ', 'Cena        ' }
   LOCAL aComidasC  := { ' D ', ' Mm', ' A ', ' Md', ' C ' }
   LOCAL nBlank := 0
   LOCAL i
   LOCAL nRecPtr := MS->( RecNo() )
   LOCAL nOrden  := MS->( ordNumber() )
   LOCAL nRecAdd
   LOCAL lDuplicado

   IF MS->( Eof() ) .AND. nMode != 1
      RETURN NIL
   ENDIF
	
   oApp():nEdit ++

   IF nMode == 1
      MS->( dbAppend() )
      nRecAdd := MS->( RecNo() )
   ENDIF
   cMsCodigo := MS->MsCodigo
   cMsDescrip  := MS->MsDescrip
   dMsFchPrep := MS->MsFchPrep
   nMsComens := MS->MsComens
   cReMsCodigo := cMsCodigo
   nReMsComens := nMsComens
   IF nMode == 3
      MS->( dbAppend() )
      nRecAdd := MS->( RecNo() )
      cMsCodigo := Space( 10 )
   ENDIF

   DEFINE DIALOG oDlg RESOURCE "MS_EDIT" TITLE aTitle[ nMode ]
   oDlg:SetFont( oApp():oFont )

   REDEFINE GET aGet[ 1 ] VAR cMsCodigo  ;
      ID 101 OF oDlg UPDATE            ;
      VALID MsClave( cMsCodigo, aGet[ 1 ], nMode )

   REDEFINE GET aGet[ 2 ] VAR cMsDescrip  ;
      ID 102 OF oDlg UPDATE

   REDEFINE GET aGet[ 3 ] VAR dMsFchPrep  ;
      ID 103 OF oDlg UPDATE

   REDEFINE BUTTON ID 104 OF oDlg ;
      ACTION SelecFecha( @dMsFchPrep, aGet[ 3 ] )

   REDEFINE GET aGet[ 4 ] VAR nMsComens  ;
      ID 105 OF oDlg UPDATE

   // recetas del menu
   // ? MS->MsCodigo+' '+cReMsCodigo
   // ? MsGetRecetas(MS->MsCodigo)
   // ? MsGetRecetas(cReMsCodigo)
   SELECT RE
   RE->( ordSetFocus( 2 ) )
   SELECT RS
   RS->( dbGoTop() )
   DO WHILE ! RS->( Eof() ) .AND. ( nMode == 2 .OR. nMode == 3 )
      IF Upper( RS->RsMsCodigo ) == Upper( cReMsCodigo )
         RE->( dbGoTop() )
         IF ( RE->( dbSeek( RS->RsReCodigo ) ) )
            AAdd( aRe, { aDiasC[ Max( RS->RsDia, 1 ) ], ;
               aComidasC[ Max( RS->RsComida, 1 ) ], ;
               RE->ReCodigo,;
               RE->ReTitulo,;
               aTPlato[ Max( Val( RE->RePlato ), 1 ) ], ;
               RE->ReTipo,;
               RS->RsComensal, ;
               RS->RsFecha, ;
               RS->RsHora } )
            nBlank ++
         ELSE
            MsgStop( 'La receta ' + RS->RsReCodigo + ' no existe y se borra del menú.' )
         ENDIF
      ENDIF
      RS->( dbSkip() )
   ENDDO

   IF nBlank == 0
      AAdd( aRe, { '', '', '', '', '', '', '', '', '' } )
   ELSE
      ASort( aRe,,, {| x, y| x[ 8 ] < y[ 8 ] } )
   ENDIF

   oLbx := TXBrowse():New( oDlg )
   oLbx:SetArray( aRe, .F. )
   oLbx:aCols[ 1 ]:cHeader := "Día"
   oLbx:aCols[ 1 ]:nWidth  := 20
   oLbx:aCols[ 1 ]:nHeadStrAlign := 0
   oLbx:aCols[ 2 ]:cHeader := "Com."
   oLbx:aCols[ 2 ]:nWidth  := 20
   oLbx:aCols[ 2 ]:nHeadStrAlign := 0
   oLbx:aCols[ 3 ]:cHeader := "Código"
   oLbx:aCols[ 3 ]:nWidth  := 50
   oLbx:aCols[ 3 ]:nHeadStrAlign := 0
   oLbx:aCols[ 4 ]:cHeader := "Receta"
   oLbx:aCols[ 4 ]:nWidth  := 150
   oLbx:aCols[ 4 ]:nHeadStrAlign := 0
   oLbx:aCols[ 5 ]:cHeader := "Cat."
   oLbx:aCols[ 5 ]:nWidth  := 50
   oLbx:aCols[ 5 ]:nHeadStrAlign := 0
   oLbx:aCols[ 6 ]:cHeader := "Plato"
   oLbx:aCols[ 6 ]:nWidth  := 80
   oLbx:aCols[ 6 ]:nHeadStrAlign := 0
   oLbx:aCols[ 7 ]:cHeader := "Comens."
   oLbx:aCols[ 7 ]:nWidth  := 80
   oLbx:aCols[ 7 ]:nHeadStrAlign := 0
   oLbx:aCols[ 8 ]:cHeader := "Fecha"
   oLbx:aCols[ 8 ]:nWidth  := 80
   oLbx:aCols[ 8 ]:nHeadStrAlign := 0
   oLbx:aCols[ 9 ]:cHeader := "Hora"
   oLbx:aCols[ 9 ]:nWidth  := 80
   oLbx:aCols[ 9 ]:nHeadStrAlign := 0
   Ut_BrwRowConfig( oLbx )
   oLbx:CreateFromResource( 110 )
   oLbx:RestoreState( cState )
   FOR i := 1 TO Len( oLbx:aCols )
      oCol := oLbx:aCols[ i ]
      oCol:bLDClickData  := {|| RsEdita( oLbx, 2, aRe, @nBlank, aDiasC, aDiasL, aComidasC, aComidasL, nMsComens ) }
   NEXT

   REDEFINE BUTTON aBtn[ 1 ] ;
      ID 111     ;
      OF oDlg    ;
      ACTION  RsEdita( oLbx, 1, aRe, @nBlank, aDiasC, aDiasL, aComidasC, aComidasL, nMsComens )

   REDEFINE BUTTON aBtn[ 2 ] ;
      ID 112     ;
      OF oDlg    ;
      ACTION  RsEdita( oLbx, 2, aRe, @nBlank, aDiasC, aDiasL, aComidasC, aComidasL, nMsComens )

   REDEFINE BUTTON aBtn[ 3 ] ;
      ID 113     ;
      OF oDlg    ;
      ACTION  RsBorra( oLbx, aRe, @nBlank )

   REDEFINE BUTTON aBtn[ 4 ] ;
      ID 114 OF oDlg       ;
      ACTION  MsgInfo( 'pendiente' );
      WHEN .F.

   REDEFINE BUTTON aBtn[ 5 ] ;
      ID 115 OF oDlg       ;
      ACTION ( RE->( ordSetFocus( 2 ) ), ;
      RE->( dbSeek( aRe[ oLbx:nArrayAt, 3 ] ) ), ;
      iif( RE->ReExpres == .T., ReEditaExpres(, 2,, oDlg ), ReEdita(, 2,, oDlg ) ) )

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
      // ___ guardo las recetas del menu ____
      SELECT RS
      IF nMode == 2
         DELETE FOR RS->RsMsCodigo == MS->MsCodigo
         RS->( dbCommit() )
      ENDIF
      RS->( dbGoTop() )
      FOR i := 1 TO Len( aRe ) // nBlank
         IF ! Empty( aRe[ i, 3 ] )
            RS->( dbAppend() )
            REPLACE RS->RsMsCodigo  WITH cMsCodigo
            REPLACE RS->RsReCodigo  WITH aRe[ i, 3 ]
            REPLACE RS->RsComensal   WITH aRe[ i, 7 ]
            REPLACE RS->RsDia        WITH AScan( aDiasC, aRe[ i, 1 ] )
            REPLACE RS->RsComida     WITH AScan( aComidasC, aRe[ i, 2 ] )
            REPLACE RS->RsFecha      WITH aRe[ i, 8 ]
            REPLACE RS->RsHora       WITH aRe[ i, 9 ]
            RS->( dbCommit() )
         ENDIF
      NEXT
      // ___ guardo el menu _______________________________________________
      SELECT MS
      IF nMode == 2
         MS->( dbGoto( nRecPtr ) )
      ELSE
         MS->( dbGoto( nRecAdd ) )
      ENDIF
      REPLACE MS->MsCodigo  WITH cMsCodigo
      REPLACE MS->MsDescrip WITH cMsDescrip
      REPLACE MS->MsFchPrep WITH dMsFchPrep
      REPLACE MS->MsComens  WITH nMsComens
      MS->( dbCommit() )
   ELSE
      IF nMode == 1 .OR. nMode == 3
         MS->( dbGoto( nRecAdd ) )
         MS->( dbDelete() )
         MS->( DbPack() )
         MS->( dbGoto( nRecPtr ) )
      ENDIF
   ENDIF
   WritePProString( "Browse", "ReMsState", oLbx:SaveState(), oApp():cInifile )
   IF oCont != NIL
      oCont:Refresh()
   ENDIF
   IF oGrid != NIL
      oGrid:Refresh()
      oGrid:SetFocus( .T. )
   ENDIF
   oApp():nEdit --

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION  RsEdita( oLbx, nMode, aRe, nBlank, aDiasC, aDiasL, aComidasC, aComidasL, nMsComens )

   LOCAL oDlg
   LOCAL cRsCodigo, cRsReceta, cRsCategoria, cRsPlato, nRsComensal, cRsDia, cRsComida, dRsFecha, cRsHora
   LOCAL aGet[ 9 ], oBtn1, oBtn2

   IF nMode == 1
      cRsCodigo   := Space( 10 )
      cRsReceta   := Space( 60 )
      cRsCategoria := Space( 30 )
      cRsPlato   := Space( 30 )
      cRsDia   := aDiasL[ 1 ]
      cRsComida  := aComidasL[ 1 ]
      dRsFecha   := MS->MsFchPrep
      cRsHora   := "14:00"
      nRsComensal  := nMsComens
   ELSEIF nMode == 2
      IF nBlank == 0
         MsgStop( "No hay ninguna receta para modificar." )
         RETU NIL
      ENDIF
      cRsDia   := aDiasL[ Max( AScan( aDiasC, aRe[ oLbx:nArrayAt, 1 ] ), 1 ) ]
      cRsComida  := aComidasL[ Max( AScan( aComidasC, aRe[ oLbx:nArrayAt, 2 ] ), 1 ) ]
      cRsCodigo   := aRe[ oLbx:nArrayAt, 3 ]
      cRsReceta   := aRe[ oLbx:nArrayAt, 4 ]
      cRsCategoria := aRe[ oLbx:nArrayAt, 5 ]
      cRsPlato   := aRe[ oLbx:nArrayAt, 6 ]
      nRsComensal  := aRe[ oLbx:nArrayAt, 7 ]
      dRsFecha     := aRe[ oLbx:nArrayAt, 8 ]
      cRsHora   := aRe[ oLbx:nArrayAt, 9 ]
   ENDIF

   DEFINE DIALOG oDlg RESOURCE 'RS_EDIT_' + oApp():cLanguage ;
      TITLE iif( nMode == 1, i18n( "Nueva receta en el menú semanal" ), i18n( "Modificar receta en el menú semanal" ) )
   oDlg:SetFont( oApp():oFont )

   REDEFINE GET aGet[ 1 ] VAR cRsCodigo        ;
      ID 101 OF oDlg UPDATE                  ;
      PICTURE "@!"                           ;
      VALID ReClave( @cRsCodigo, aGet[ 1 ], 4, 2, aGet, oBtn1 )

   REDEFINE BUTTON oBtn1 ID 102 OF oDlg      ;
      ACTION ReSelAjena( @cRsCodigo, aGet[ 1 ], 4, 2, aGet )

   REDEFINE GET aGet[ 2 ] VAR cRsReceta        ;
      ID 103 OF oDlg UPDATE                  ;
      WHEN .F.

   REDEFINE GET aGet[ 3 ] VAR cRsCategoria     ;
      ID 104 OF oDlg UPDATE                  ;
      WHEN .F.

   REDEFINE GET aGet[ 4 ] VAR cRsPlato         ;
      ID 105 OF oDlg UPDATE                  ;
      WHEN .F.

   REDEFINE GET aGet[ 5 ] VAR nRsComensal      ;
      PICTURE "999" ID 106 OF oDlg UPDATE

   REDEFINE COMBOBOX aGet[ 6 ] VAR cRsDia    ITEMS aDiasL ID 107 OF oDlg

   REDEFINE GET aGet[ 8 ] VAR dRsFecha      ;
      ID 109 OF oDlg UPDATE

   REDEFINE BUTTON oBtn2                  ;
      ID 111 OF oDlg ACTION SelecFecha( dRsFecha, aGet[ 8 ] )
   oBtn1:cTooltip := i18n( "seleccionar fecha" )

   REDEFINE COMBOBOX aGet[ 7 ] VAR cRsComida ITEMS aComidasL ID 108 OF oDlg

   REDEFINE GET aGet[ 9 ] VAR cRsHora      ;
      PICT "99:99" ID 110 OF oDlg UPDATE


   REDEFINE BUTTON   ;
      ID    IDOK     ;
      OF    oDlg     ;
      ACTION   ( cRsReceta    := aGet[ 2 ]:cText, ;
      cRsCategoria := aGet[ 3 ]:cText, ;
      cRsPlato     := aGet[ 4 ]:cText, ;
      oDlg:end( IDOK ) )

   REDEFINE BUTTON   ;
      ID    IDCANCEL ;
      OF    oDlg     ;
      CANCEL         ;
      ACTION   ( oDlg:end( IDCANCEL ) )

   ACTIVATE DIALOG oDlg ;
      ON INIT DlgCenter( oDlg, oApp():oWndMain )

   IF oDlg:nresult == IDOK
      IF nMode == 1
         IF nBlank == 0
            aRe[ 1 ] := { aDiasC[ AScan( aDiasL, cRsDia ) ], aComidasC[ AScan( aComidasL, cRsComida ) ], cRsCodigo, cRsReceta, cRsCategoria, cRsPlato, nRsComensal, dRsFecha, cRsHora }
         ELSE
            AAdd( aRe, { aDiasC[ AScan( aDiasL, cRsDia ) ], aComidasC[ AScan( aComidasL, cRsComida ) ], cRsCodigo, cRsReceta, cRsCategoria, cRsPlato, nRsComensal, dRsFecha, cRsHora } )
            // ASort( aRe ,,, {|x,y| 10*AScan(aDiasL,x[1])+AScan(aComidasL,x[2]) < 10*AScan(aDiasL,y[1])+AScan(aComidasL,y[2])} )
            ASort( aRe,,, {| x, y| x[ 8 ] < y[ 8 ] } )
         ENDIF
         nBlank ++
      ELSE
         aRe[ oLbx:nArrayAt ] := { aDiasC[ AScan( aDiasL, cRsDia ) ], aComidasC[ AScan( aComidasL, cRsComida ) ], cRsCodigo, cRsReceta, cRsCategoria, cRsPlato, nRsComensal, dRsFecha, cRsHora }
         // ASort( aRe ,,, {|x,y| 10*AScan(aDiasL,x[1])+AScan(aComidasL,x[2]) < 10*AScan(aDiasL,y[1])+AScan(aComidasL,y[2])} )
         ASort( aRe,,, {| x, y| x[ 8 ] < y[ 8 ] } )
      ENDIF
   ENDIF
   oLbx:Refresh()
   oLbx:SetFocus( .T. )

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION  RsBorra( oLbx, aRe, nBlank )

   ADel( aRe, oLbx:nArrayAt, .T. )
   // ASize( aRe, len( aRe ) - 1 )
   // oLbx:aArrayData := aRe
   nBlank --
   IF nBlank == 0
      AAdd( aRe, { '', '', '', '', '', '', '', '', '' } )
   ENDIF
   oLbx:Refresh()
   oLbx:SetFocus()
   RETU NIL
   /*_____________________________________________________________________________*/

FUNCTION MsClave( cMsCodigo, oGet1, nMode, oGet2, oGet3 )

   // nMode    1 nuevo registro
   // 2 modificación de registro
   // 3 duplicación de registro
   // 4 clave ajena
   LOCAL lreturn  := .F.
   LOCAL nRecno   := MS->( RecNo() )
   LOCAL nOrder   := MS->( ordNumber() )
   LOCAL nArea    := Select()

   IF Empty( cMsCodigo )
      IF nMode == 4
         RETURN .T.
      ELSE
         MsgStop( "Es obligatorio rellenar este campo." )
         RETURN .F.
      ENDIF
   ENDIF

   SELECT MS
   MS->( dbSetOrder( 1 ) )
   MS->( dbGoTop() )

   IF MS->( dbSeek( Upper( cMsCodigo ) ) )
      DO CASE
      CASE nMode == 1 .OR. nMode == 3
         lreturn := .F.
         MsgStop( "Código de menú semanal existente." )
      CASE nMode == 2
         IF MS->( RecNo() ) == nRecno
            lreturn := .T.
         ELSE
            lreturn := .F.
            MsgStop( "Código de menú semanal existente." )
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
         IF MsgYesNo( "Menú inexistente. ¿ Desea darlo de alta ahora ? ", 'Seleccione una opción' )
            lreturn := MsEdita( , 1, , , @cMsCodigo )
         ELSE
            lreturn := .F.
         ENDIF
      ENDIF
   ENDIF

   IF lreturn == .F.
      oGet1:cText( Space( 10 ) )
   ELSE
      IF oGet2 != nil
         oGet2:cText( MS->MsDescrip )
      ENDIF
      IF oGet3 != nil
         oGet3:cText( MS->MsFchPrep )
      ENDIF
   ENDIF

   MS->( dbSetOrder( nOrder ) )
   MS->( dbGoto( nRecno ) )

   SELECT ( nArea )

   RETURN lreturn
/*_____________________________________________________________________________*/
FUNCTION MsBorra( oGrid, oCont )

   LOCAL nRecord := MS->( RecNo() )
   LOCAL nNext

   oApp():nEdit ++
   IF msgYesNo( i18n( "¿ Está seguro de borrar este menú semanal ?" ) + CRLF + ;
         ( Trim( MS->MsDescrip ) ), 'Seleccione una opción' )
      // ___ Borro las recetas del menú _______________________________________
      SELECT RS
      DELETE FOR RS->RsMsCodigo == MS->MsCodigo
      RS->( DbPack() )
      RS->( dbCommit() )
      // ___ borro el menu ____________________________________________________
      SELECT MS
      MS->( dbSkip() )
      nNext := MS->( RecNo() )
      MS->( dbGoto( nRecord ) )
      MS->( dbDelete() )
      MS->( DbPack() )
      MS->( dbGoto( nNext ) )
      IF MS->( Eof() ) .OR. nNext == nRecord
         MS->( dbGoBottom() )
      ENDIF
   ENDIF
   RefreshCont( oCont, "MS" )
   oGrid:Refresh( .T. )
   oGrid:SetFocus( .T. )
   oApp():nEdit --

   RETURN NIL
/*_____________________________________________________________________________*/
FUNCTION MsTecla( nKey, oGrid, oCont, oDlg )

   DO CASE
   CASE nKey == VK_RETURN
      MsEdita( oGrid, 2, oCont, oDlg )
   CASE nKey == VK_INSERT
      MsEdita( oGrid, 1, oCont, oDlg )
   CASE nKey == VK_DELETE
      MsBorra( oGrid, oCont )
   CASE nKey == VK_ESCAPE
      oDlg:End()
   OTHERWISE
      IF nKey >= 96 .AND. nKey <= 105 // número
         MsBusca( oGrid, Str( nKey - 96, 1 ), oCont, oDlg )
      ELSEIF HB_ISSTRING( Chr( nKey ) )
         MsBusca( oGrid, Chr( nKey ), oCont, oDlg )
      ENDIF
   ENDCASE

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION MsBusca( oGrid, cChr, oCont, oParent )

   LOCAL nOrder    := MS->( ordNumber() )
   LOCAL nRecno    := MS->( RecNo() )
   LOCAL oDlg, oGet, cGet, cPicture
   LOCAL aSay1    := { i18n( "Introduzca el código del menú semanal" ),;
      i18n( "Introduzca la descripción del menú semanal" ),;
      i18n( "Introduzca la fecha de preparación del menú semanal" )  }
   LOCAL aSay2    := { i18n( "Código:" ),;
      i18n( "Descripción:" ),;
      i18n( "Fecha:" )        }
   LOCAL aGet     := { Space( 10 ),;
      Space( 60 ),;
      CToD( "" )  }

   LOCAL cCodigo   := Space( 10 )
   LOCAL cDescrip  := Space( 60 )
   LOCAL dFecha    := CToD( '' )
   LOCAL lSeek     := .F.
   LOCAL lFecha    := .F.
   LOCAL aBrowse  := {}

   oApp():nEdit ++

   DEFINE DIALOG oDlg RESOURCE 'UT_BUSCA_' + oApp():cLanguage OF oParent  ;
      TITLE i18n( "Búsqueda de menús de eventos" )
   oDlg:SetFont( oApp():oFont )

   REDEFINE SAY PROMPT aSay1[ nOrder ] ID 20 OF oDlg
   REDEFINE SAY PROMPT aSay2[ nOrder ] ID 21 OF Odlg

   cGet  := aGet[ nOrder ]

   IF nOrder == 3
      lFecha := .T.
   ENDIF
   /*__ si he pasado un caracter lo meto en la cadena a buscar ________________*/

   IF cChr != NIL
      IF ! lFecha
         cGet := cChr + SubStr( cGet, 1, Len( cGet ) -1 )
      ELSE
         cGet := CToD( '  -  -    ' )
      ENDIF
   ENDIF

   IF ! lFecha
      REDEFINE GET oGet VAR cGet PICTURE "@!" ID 101 OF oDlg
   ELSE
      REDEFINE GET oGet VAR cGet ID 101 OF oDlg
      // oGet:cText := cChr+' -  -    '
   ENDIF

   IF cChr != NIL
      oGet:bGotFocus := {|| ( oGet:SetPos( 2 ) ) }
   ENDIF

   REDEFINE BUTTON ID IDOK OF oDlg ;
      PROMPT i18n( "&Aceptar" )   ;
      ACTION ( lSeek := .T., oDlg:End() )
   REDEFINE BUTTON ID IDCANCEL OF oDlg CANCEL ;
      PROMPT i18n( "&Cancelar" )  ;
      ACTION ( lSeek := .F., oDlg:End() )

   sysrefresh()
   ACTIVATE DIALOG oDlg ;
      ON INIT ( DlgCenter( oDlg, oApp():oWndMain ) )// , IIF(cChr!=NIL,oGet:SetPos(2),), oGet:Refresh() )

   IF lSeek
      IF ! lFecha
         cGet := RTrim( Upper( cGet ) )
      ENDIF
      MsgRun( 'Realizando la búsqueda...', oApp():cAppName + oApp():cVersion, ;
         {|| MsWildSeek( nOrder, cGet, aBrowse ) } )
      IF Len( aBrowse ) == 0
         MsgStop( "No se ha encontrado ningún menú." )
      ELSE
         MsEncontrados( aBrowse, oApp():oDlg )
      ENDIF
   ENDIF
   IF oCont != NIL
      RefreshCont( oCont, "MS" )
   ENDIF

   oApp():nEdit --
   oGrid:Refresh()
   oGrid:SetFocus( .T. )

   RETURN NIL
/*_____________________________________________________________________________*/
FUNCTION MsWildSeek( nOrder, cGet, aBrowse )

   LOCAL nRecno   := MS->( RecNo() )

   DO CASE
   CASE nOrder == 1
      MS->( dbGoTop() )
      DO WHILE ! MS->( Eof() )
         IF cGet $ Upper( MS->MsCodigo )
            AAdd( aBrowse, { MS->MsCodigo, MS->MsDescrip, MS->MsFchPrep, MS->( RecNo() ) } )
         ENDIF
         MS->( dbSkip() )
      ENDDO
   CASE nOrder == 2
      MS->( dbGoTop() )
      DO WHILE ! MS->( Eof() )
         IF cGet $ Upper( MS->MsDescrip )
            AAdd( aBrowse, { MS->MsCodigo, MS->MsDescrip, MS->MsFchPrep, MS->( RecNo() ) } )
         ENDIF
         MS->( dbSkip() )
      ENDDO
   CASE nOrder == 3
      MS->( dbGoTop() )
      DO WHILE ! MS->( Eof() )
         IF cGet == MS->MsFchPrep
            AAdd( aBrowse, { MS->MsCodigo, MS->MsDescrip, MS->MsFchPrep, MS->( RecNo() ) } )
         ENDIF
         MS->( dbSkip() )
      ENDDO
   END CASE
   MS->( dbGoto( nRecno ) )
   // ordeno la tabla por el 1 elemento
   ASort( aBrowse,,, {|aAut1, aAut2| Upper( aAut1[ 1 ] ) < Upper( aAut2[ 1 ] ) } )

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION MsEncontrados( aBrowse, oParent )

   LOCAL oDlg, oBrowse, oBtnOk, oBtnCancel, lOk
   LOCAL nRecno := MS->( RecNo() )

   DEFINE DIALOG oDlg RESOURCE "DLG_ENCONTRADOS" ;
      TITLE i18n( "Resultado de la búsqueda" ) ;
      OF oParent
   oDlg:SetFont( oApp():oFont )

   oBrowse := TXBrowse():New( oDlg )
   Ut_BrwRowConfig( oBrowse )

   oBrowse:SetArray( aBrowse, .F. )
   oBrowse:aCols[ 1 ]:cHeader := "Código"
   oBrowse:aCols[ 2 ]:cHeader := "Descripción"
   oBrowse:aCols[ 3 ]:cHeader := "Fch. Preparación"
   oBrowse:aCols[ 1 ]:nWidth  := 90
   oBrowse:aCols[ 2 ]:nWidth  := 340
   oBrowse:aCols[ 3 ]:nWidth  := 100
   oBrowse:aCols[ 4 ]:Hide()
   oBrowse:aCols[ 1 ]:nHeadStrAlign := 0
   oBrowse:aCols[ 1 ]:nDataStrAlign := 0
   oBrowse:aCols[ 2 ]:nHeadStrAlign := 0
   oBrowse:aCols[ 2 ]:nDataStrAlign := 0
   oBrowse:aCols[ 3 ]:nHeadStrAlign := 0
   oBrowse:aCols[ 3 ]:nDataStrAlign := 0

   oBrowse:CreateFromResource( 110 )

   MS->( dbGoto( aBrowse[ oBrowse:nArrayAt, 4 ] ) )
   AEval( oBrowse:aCols, {|oCol| oCol:bLDClickData := {|| MS->( dbGoto( aBrowse[ oBrowse:nArrayAt, 4 ] ) ), ;
      MsEdita( , 2,, oApp():oDlg ) } } )
   oBrowse:bKeyDown  := {| nKey| iif( nKey == VK_RETURN, ( MS->( dbGoto( aBrowse[ oBrowse:nArrayAt, 4 ] ) ), ;
      MsEdita( , 2,, oApp():oDlg ) ), ) }
   oBrowse:bChange    := {|| MS->( dbGoto( aBrowse[ oBrowse:nArrayAt, 4 ] ) ) }
   oBrowse:lHScroll  := .F.
   oDlg:oClient      := oBrowse
   oBrowse:nRowHeight := 20

   REDEFINE BUTTON oBtnOk ;
      ID IDOK OF oDlg     ;
      ACTION oDlg:End()

   REDEFINE BUTTON oBtnCancel ;
      ID IDCANCEL OF oDlg ;
      ACTION ( MS->( dbGoto( nRecno ) ), oDlg:End() )

   ACTIVATE DIALOG oDlg ;
      ON INIT DlgCenter( oDlg, oApp():oWndMain )

   RETURN NIL

/*_____________________________________________________________________________*/

FUNCTION MsCompra( oGrid, oParent, lReport )

   LOCAL cMsCodigo := MS->MsCodigo
   LOCAL cReCodigo, nReComensal
   LOCAL oDlg, oBrowse, oCol
   LOCAL nTotal := 0

   CursorWait()
   SELECT RE
   RE->( ordSetFocus( 2 ) )
   RE->( dbGoTop() )
   SELECT ES
   ES->( ordSetFocus( 1 ) ) // upper(EsReceta)
   ES->( dbGoTop() )
   SELECT TS
   TS->( DbPack() )
   TS->( Db_ZAP() )
   TS->( ordSetFocus( 2 ) ) // Upper(EsIngred)
   TS->( dbGoTop() )
   SELECT RS
   RS->( ordSetFocus( 1 ) ) // Upper(RsMsCodigo)
   RS->( dbGoTop() )
   RS->( dbSeek( Upper( cMsCodigo ) ) )
   WHILE Upper( RS->RsMsCodigo ) == Upper( cMsCodigo )
      cReCodigo  := RS->RsReCodigo
      SELECT RE
      RE->( dbSeek( cReCodigo ) )
      // nReComensal := RS->RsComensal
      SELECT ES
      ES->( dbSeek( cReCodigo ) )
      WHILE ES->EsReceta == cReCodigo
         SELECT TS
         IF TS->( dbSeek( ES->EsIngred ) )
            IF ES->EsCanFija == .T.
               REPLACE TS->EsCantidad WITH TS->EsCantidad + ES->EsCantidad
               REPLACE TS->EsPrecio   WITH TS->EsPrecio + ES->EsPrecio
            ELSE
               REPLACE TS->EsCantidad WITH TS->EsCantidad + ES->EsCantidad / RE->ReComEsc * RS->RsComensal
               REPLACE TS->EsPrecio   WITH TS->EsPrecio + ES->EsPrecio / RE->ReComEsc * RS->RsComensal
            ENDIF
         ELSE
            TS->( dbAppend() )
            REPLACE TS->EsIngred  WITH ES->EsIngred
            REPLACE TS->EsInDenomi  WITH ES->EsInDenomi
            REPLACE TS->EsUnidad  WITH ES->EsUnidad
            REPLACE TS->EsProveed   WITH ES->Esproveed
            IF ES->EsCanFija == .T.
               REPLACE TS->EsCantidad WITH ES->EsCantidad
               REPLACE TS->EsPrecio   WITH ES->EsPrecio
            ELSE
               REPLACE TS->EsCantidad WITH ES->EsCantidad / RE->ReComEsc * RS->RsComensal
               REPLACE TS->EsPrecio   WITH ES->EsPrecio / RE->ReComEsc * RS->RsComensal
            ENDIF
         ENDIF
         nTotal += ES->EsPrecio / RE->ReComEsc * RS->RsComensal
         TS->( dbCommit() )
         ES->( dbSkip() )
      ENDDO
      RS->( dbSkip() )
   ENDDO
   CursorArrow()
   IF lReport
      RETU NIL
   ENDIF

   DEFINE DIALOG oDlg RESOURCE 'ME_ESCAN'  ;
      TITLE 'Lista de la compra de: ' + MS->MsDescrip OF oParent
   oDlg:SetFont( oApp():oFont )

   SELECT TS
   TS->( dbGoTop() )

   oBrowse := TXBrowse():New( oDlg )
   Ut_BrwRowConfig( oBrowse )
   oBrowse:cAlias := "TS"
   oBrowse:lFooter := .T.

   oCol := oBrowse:AddCol()
   oCol:bStrData := {|| TS->EsIngred }
   oCol:cHeader  := "Código"
   oCol:nWidth   := 60

   oCol := oBrowse:AddCol()
   oCol:bStrData := {|| TS->EsInDenomi }
   oCol:cHeader  := "Ingrediente"
   oCol:nWidth   := 250

   oCol := oBrowse:AddCol()
   oCol:bStrData := {|| TS->EsUnidad }
   oCol:cHeader  := "Unidad"
   oCol:nWidth   := 60

   oCol := oBrowse:AddCol()
   oCol:bStrData := {|| Tran( TS->EsCantidad, "@E 999,999.999" ) }
   oCol:cHeader  := "Cantidad"
   oCol:nWidth   := 60
   // oCol:cEditPicture  := "@E999,999.999"
   oCol:nHeadStrAlign := AL_RIGHT
   oCol:nDataStrAlign := AL_RIGHT
   oCol:nFootStrAlign := AL_RIGHT

   ADD oCol TO oBrowse DATA TS->EsPrecio ;
      HEADER "Precio"   WIDTH 60 TOTAL 0 ;
      PICTURE "@E 999,999.99"

   // oCol := oBrowse:AddCol()
   // oCol:bStrData := { || Tran(TS->EsPrecio,"@E 999,999.99") }
   // oCol:cHeader  := "Precio"
   // oCol:nWidth   := 60
   // oCol:nTotal   := nTotal
   // oCol:lTotal   := .t.
   // oCol:nHeadStrAlign := AL_RIGHT
   // oCol:nDataStrAlign := AL_RIGHT
   // oCol:nFootStrAlign := AL_RIGHT

   oCol := oBrowse:AddCol()
   oCol:bStrData := {|| TS->EsProveed }
   oCol:cHeader  := "Proveedor"
   oCol:nWidth   := 60

   oBrowse:SetRDD()
   oBrowse:CreateFromResource( 110 )
   oBrowse:MakeTotals()

   REDEFINE BUTTON ID 200 OF oDlg ;
      PROMPT i18n( "&Imprimir" )   ;
      ACTION ( MsCompraInforme(), oDlg:End() )

   REDEFINE BUTTON ID 201 OF oDlg ;
      PROMPT i18n( "&Excel" )   ;
      ACTION ( CursorWait(), Ut_ExportXLS( oBrowse, "Lista de la compra" ), CursorArrow() );

      REDEFINE BUTTON   ;
      ID    IDCANCEL ;
      OF    oDlg     ;
      CANCEL         ;
      ACTION   ( oDlg:end( IDCANCEL ) )

   ACTIVATE DIALOG oDlg ;
      ON INIT DlgCenter( oDlg, oApp():oWndMain )

   SELECT ME
   oGrid:Refresh()
   oGrid:SetFocus( .T. )
   oApp():nEdit --

   RETURN NIL
// _____________________________________________________________________________//
FUNCTION MsPreparacion( oGrid, oParent, lReport )

   IF msgyesno( '¿ Desea anotar en las recetas del menú la fecha de preparación del menú ?' + CRLF + ;
         'Solo se cambiará la fecha si la del menú es posterior a la de la receta.' )
      RE->( ordSetFocus( 2 ) )
      RS->( dbGoTop() )
      DO WHILE ! RS->( Eof() )
         IF Upper( RS->RsMsCodigo ) == Upper( MS->MsCodigo )
            RE->( dbGoTop() )
            IF RE->( dbSeek( RS->RsReCodigo ) )
               IF RE->ReFchPrep < RS->RsFecha
                  SELECT RE
                  REPLACE RE->ReFchPrep WITH RS->RsFecha
                  RE->( dbCommit() )
               endif
            ELSE
               msgalert( 'La receta ' + RS->RsReCodigo + ' no existe.' )
            ENDIF
         ENDIF
         SELECT RS
         RS->( dbSkip() )
      ENDDO
      MsgInfo( 'La anotación de fechas se realizó correctamente.' )
   ENDIF

   RETURN NIL
// _____________________________________________________________________________//

FUNCTION MsBcnKitchen1( oGrid, oParent, lReport )

   LOCAL cMsCodigo := MS->MsCodigo
   LOCAL cReCodigo, nReComensal
   LOCAL oDlg, oBrowse, oCol, oInforme
   LOCAL nTotal := 0

   CursorWait()
   AL->( ordSetFocus( 1 ) )
   AL->( dbGoTop() )
   SELECT RE
   RE->( ordSetFocus( 2 ) )
   RE->( dbGoTop() )
   SELECT ES
   ES->( ordSetFocus( 1 ) ) // upper(EsReceta)
   ES->( dbGoTop() )
   SELECT TS
   TS->( DbPack() )
   TS->( Db_ZAP() )
   TS->( ordSetFocus( 2 ) ) // Upper(EsIngred)
   TS->( dbGoTop() )
   SELECT RS
   RS->( ordSetFocus( 1 ) ) // Upper(RsMsCodigo)
   RS->( dbGoTop() )
   RS->( dbSeek( Upper( cMsCodigo ) ) )
   WHILE Upper( RS->RsMsCodigo ) == Upper( cMsCodigo )
      cReCodigo  := RS->RsReCodigo
      SELECT RE
      RE->( dbSeek( cReCodigo ) )
      // nReComensal := RS->RsComensal
      SELECT ES
      ES->( dbSeek( cReCodigo ) )
      WHILE ES->EsReceta == cReCodigo
         SELECT TS
         IF TS->( dbSeek( ES->EsIngred ) )
            IF ES->EsCanFija == .T.
               REPLACE TS->EsCantidad WITH TS->EsCantidad + ES->EsCantidad
               REPLACE TS->EsPrecio   WITH TS->EsPrecio + ES->EsPrecio
            ELSE
               REPLACE TS->EsCantidad WITH TS->EsCantidad + ES->EsCantidad / RE->ReComEsc * RS->RsComensal
               REPLACE TS->EsPrecio   WITH TS->EsPrecio + ES->EsPrecio / RE->ReComEsc * RS->RsComensal
            ENDIF
         ELSE
            TS->( dbAppend() )
            REPLACE TS->EsIngred  WITH ES->EsIngred
            REPLACE TS->EsInDenomi  WITH ES->EsInDenomi
            REPLACE TS->EsUnidad  WITH ES->EsUnidad
            REPLACE TS->EsProveed   WITH ES->Esproveed
            IF ES->EsCanFija == .T.
               REPLACE TS->EsCantidad WITH ES->EsCantidad
               REPLACE TS->EsPrecio   WITH ES->EsPrecio
            ELSE
               REPLACE TS->EsCantidad WITH ES->EsCantidad / RE->ReComEsc * RS->RsComensal
               REPLACE TS->EsPrecio   WITH ES->EsPrecio / RE->ReComEsc * RS->RsComensal
            ENDIF
            // busco el ingrediente
            AL->( dbSeek( Upper( ES->EsInDenomi ) ) )
            REPLACE TS->EsStock  WITH AL->AlStock
            REPLACE TS->EsUbicaci WITH AL->AlUbicaci
            REPLACE TS->EsCodProv WITH AL->AlCodProv
         ENDIF
         nTotal += ES->EsPrecio / RE->ReComEsc * RS->RsComensal
         TS->( dbCommit() )
         ES->( dbSkip() )
      ENDDO
      RS->( dbSkip() )
   ENDDO
   CursorArrow()

   oInforme := TInforme():New( {}, {}, {}, {}, {}, {}, "MS" )
   oInforme:nRadio := 1
   SELECT TS
   TS->( ordSetFocus( 3 ) )
   TS->( dbGoTop() )
   oInforme:oFont1 := TFont():New( RTrim( oInforme:acFont[ 1 ] ), 0, Val( oInforme:acSizes[ 1 ] ),, ( i18n( "Negrita" ) $ oInforme:acEstilo[ 1 ] ),,,, ( i18n( "Cursiva" ) $ oInforme:acEstilo[ 1 ] ),,,,,,, )
   oInforme:oFont2 := TFont():New( RTrim( oInforme:acFont[ 2 ] ), 0, Val( oInforme:acSizes[ 2 ] ),, ( i18n( "Negrita" ) $ oInforme:acEstilo[ 2 ] ),,,, ( i18n( "Cursiva" ) $ oInforme:acEstilo[ 2 ] ),,,,,,, )
   oInforme:oFont3 := TFont():New( RTrim( oInforme:acFont[ 3 ] ), 0, Val( oInforme:acSizes[ 3 ] ),, ( i18n( "Negrita" ) $ oInforme:acEstilo[ 3 ] ),,,, ( i18n( "Cursiva" ) $ oInforme:acEstilo[ 3 ] ),,,,,,, )

   REPORT oInforme:oReport ;
      TITLE ' ', RTrim( MS->MsCodigo ) + ' * ' + RTrim( MS->MsDescrip ), 'Totalizado de ingredientes por proveedor', ' ', ' ', ' ' CENTERED;
      FONT  oInforme:oFont3, oInforme:oFont2, oInforme:oFont1 ;
      HEADER ' ', oApp():cAppName + oApp():cVersion, oApp():cUser   ;
      FOOTER ' ', "Fecha: " + DToC( Date() ) + "   Página.: " + Str( oInforme:oReport:nPage, 3 ) ;
      CAPTION oApp():cAppName + oApp():cVersion PREVIEW

   COLUMN TITLE "Codigo"    DATA TS->EsIngred   FONT 1 SIZE 8
   COLUMN TITLE "Ingrediente" DATA TS->EsInDenomi FONT 1 SIZE 30
   COLUMN TITLE "Cantidad"    DATA TS->EsCantidad FONT 1 PICTURE "@E 999,999.999" SIZE 10
   COLUMN TITLE "Unidad"    DATA TS->EsUnidad   FONT 1 SIZE 18
   COLUMN TITLE "Stock"    DATA Tran( TS->EsStock, "@E 9,999.99" ) FONT 1 SIZE 8
   COLUMN TITLE "Ubicación"  DATA TS->EsUbicaci FONT 1 SIZE 22
   COLUMN TITLE "Cod. Proveedor" DATA TS->EsCodProv FONT 1 SIZE 50
   GROUP ON TS->EsProveed ;
      FOOTER " " EJECT

   RptEnd()
   oInforme:oReport:Cargo := "Totalizado de ingredientes por proveedor.pdf"
   IF oInforme:oReport:lCreated
      oInforme:oReport:nTitleUpLine     := RPT_SINGLELINE
      oInforme:oReport:nTitleDnLine     := RPT_SINGLELINE
      oInforme:oReport:oTitle:aFont[ 2 ]  := {|| 3 }
      oInforme:oReport:nTopMargin       := 0.1
      oInforme:oReport:nDnMargin        := 0.1
      oInforme:oReport:nLeftMargin      := 0.1
      oInforme:oReport:nRightMargin     := 0.1
      oInforme:oReport:oDevice:lPrvModal := .T.
   ENDIF
   // oInforme:oReport:bSkip := {|| nAt++}
   ACTIVATE REPORT oInforme:oReport ;
      ON STARTPAGE ( oInforme:oReport:oTitle:aLine[ 5 ] := {|| 'Proveedor: ' + RTrim( TS->EsProveed ) },;
      oInforme:oReport:oTitle:aFont[ 5 ] := {|| 1 },;
      oInforme:oReport:oTitle:aPad[ 5 ] :=  RPT_LEFT )
   oInforme:End( .T. )

   RETURN NIL
/*_____________________________________________________________________________*/
FUNCTION MsBcnKitchen2( oGrid, oParent, lReport )

   LOCAL cMsCodigo := MS->MsCodigo
   LOCAL cReCodigo, nReComensal
   LOCAL oDlg, oBrowse, oCol, oInforme
   LOCAL nTotal := 0
   LOCAL aDias     := { 'Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo' }
   LOCAL aComidas  := { 'Desayuno', 'Media mañana', 'Almuerzo', 'Merienda', 'Cena' }

   CursorWait()
   SELECT RE
   RE->( ordSetFocus( 2 ) )
   RE->( dbGoTop() )
   SELECT ES
   ES->( ordSetFocus( 1 ) ) // upper(EsReceta)
   ES->( dbGoTop() )
   SELECT TS
   TS->( DbPack() )
   TS->( Db_ZAP() )
   TS->( ordSetFocus( 2 ) ) // Upper(EsIngred)
   TS->( dbGoTop() )
   SELECT RS
   RS->( ordSetFocus( 1 ) ) // Upper(RsMsCodigo)
   RS->( dbGoTop() )
   RS->( dbSeek( Upper( cMsCodigo ) ) )
   WHILE Upper( RS->RsMsCodigo ) == Upper( cMsCodigo )
      cReCodigo  := RS->RsReCodigo
      SELECT RE
      RE->( dbSeek( cReCodigo ) )
      // nReComensal := RS->RsComensal
      SELECT ES
      ES->( dbSeek( cReCodigo ) )
      WHILE ES->EsReceta == cReCodigo
         SELECT TS
         // en este informe no se suman por ingrediente
         TS->( dbAppend() )
         REPLACE TS->EsReceta  WITH ES->EsReceta
         REPLACE TS->EsIngred  WITH ES->EsIngred
         REPLACE TS->EsInDenomi  WITH ES->EsInDenomi
         REPLACE TS->EsUnidad  WITH ES->EsUnidad
         IF ES->EsCanFija == .T.
            REPLACE TS->EsCantidad  WITH ES->EsCantidad
            REPLACE TS->EsPrecio    WITH ES->EsPrecio
         ELSE
            REPLACE TS->EsCantidad  WITH ES->EsCantidad / RE->ReComEsc * RS->RsComensal
            REPLACE TS->EsPrecio    WITH ES->EsPrecio / RE->ReComEsc * RS->RsComensal
         ENDIF
         REPLACE TS->EsProveed   WITH ES->EsProveed
         REPLACE TS->EsDia       WITH RS->RsDia
         REPLACE TS->EsComida    WITH RS->RsComida
         REPLACE TS->EsFecha     WITH RS->RsFecha
         REPLACE TS->EsHora      WITH RS->RsHora
         nTotal += ES->EsPrecio / RE->ReComEsc * RS->RsComensal
         TS->( dbCommit() )
         ES->( dbSkip() )
      ENDDO
      RS->( dbSkip() )
   ENDDO
   CursorArrow()

   oInforme := TInforme():New( {}, {}, {}, {}, {}, {}, "MS" )
   oInforme:nRadio := 1
   SELECT TS
   TS->( ordSetFocus( 5 ) )
   TS->( dbGoTop() )
   oInforme:oFont1 := TFont():New( RTrim( oInforme:acFont[ 1 ] ), 0, Val( oInforme:acSizes[ 1 ] ),, ( i18n( "Negrita" ) $ oInforme:acEstilo[ 1 ] ),,,, ( i18n( "Cursiva" ) $ oInforme:acEstilo[ 1 ] ),,,,,,, )
   oInforme:oFont2 := TFont():New( RTrim( oInforme:acFont[ 2 ] ), 0, Val( oInforme:acSizes[ 2 ] ),, ( i18n( "Negrita" ) $ oInforme:acEstilo[ 2 ] ),,,, ( i18n( "Cursiva" ) $ oInforme:acEstilo[ 2 ] ),,,,,,, )
   oInforme:oFont3 := TFont():New( RTrim( oInforme:acFont[ 3 ] ), 0, Val( oInforme:acSizes[ 3 ] ),, ( i18n( "Negrita" ) $ oInforme:acEstilo[ 3 ] ),,,, ( i18n( "Cursiva" ) $ oInforme:acEstilo[ 3 ] ),,,,,,, )

   REPORT oInforme:oReport ;
      TITLE  ' ', RTrim( MS->MsCodigo ) + ' * ' + RTrim( MS->MsDescrip ), 'Totalizado de ingredientes por proveedor y día/hora', ' ', ' ', ' ', ' ', ' ' CENTERED;
      FONT   oInforme:oFont3, oInforme:oFont2, oInforme:oFont1 ;
      HEADER ' ', oApp():cAppName + oApp():cVersion, oApp():cUser   ;
      FOOTER ' ', "Fecha: " + DToC( Date() ) + "   Página.: " + Str( oInforme:oReport:nPage, 3 ) ;
      CAPTION oApp():cAppName + oApp():cVersion PREVIEW

   // COLUMN TITLE "Receta"    DATA TS->EsReceta   FONT 1 SIZE 8
   COLUMN TITLE "Codigo"    DATA TS->EsIngred   FONT 1 SIZE 8
   COLUMN TITLE "Ingrediente" DATA TS->EsInDenomi FONT 1 SIZE 30
   COLUMN TITLE "Cantidad"    DATA TS->EsCantidad FONT 1 PICTURE "@E 999,999.999" SIZE 10
   COLUMN TITLE "Unidad"    DATA TS->EsUnidad   FONT 1 SIZE 13
   // COLUMN TITLE "Proveedor"  DATA TS->EsProveed  FONT 1 SIZE 20
   COLUMN TITLE "Comentarios" DATA Space( 80 )      FONT 1 SIZE 80
   GROUP ON TS->EsProveed + DToS( TS->EsFecha ) + TS->EsHora + TS->EsReceta ;
      FOOTER " " EJECT

   RptEnd()
   oInforme:oReport:Cargo := "Totalizado de ingredientes por proveedor y dia-hora.pdf"
   IF oInforme:oReport:lCreated
      oInforme:oReport:nTitleUpLine     := RPT_SINGLELINE
      oInforme:oReport:nTitleDnLine     := RPT_SINGLELINE
      oInforme:oReport:oTitle:aFont[ 2 ]  := {|| 3 }
      oInforme:oReport:nTopMargin       := 0.1
      oInforme:oReport:nDnMargin        := 0.1
      oInforme:oReport:nLeftMargin      := 0.1
      oInforme:oReport:nRightMargin     := 0.1
      oInforme:oReport:oDevice:lPrvModal := .T.
   ENDIF
   ACTIVATE REPORT oInforme:oReport ;
      ON STARTPAGE ( RE->( dbSeek( TS->EsReceta ) ), RS->( dbSeek( Upper( MS->MsCodigo ) + Upper( TS->EsReceta ) ) ), ;
      oInforme:oReport:oTitle:aLine[ 5 ] := {|| 'Proveedor: ' + RTrim( TS->EsProveed ) },;
      oInforme:oReport:oTitle:aFont[ 5 ] := {|| 1 },;
      oInforme:oReport:oTitle:aPad[ 5 ] :=  RPT_LEFT,;
      oInforme:oReport:oTitle:aLine[ 6 ] := {|| 'Taller/Receta: ' + RTrim( TS->EsReceta ) + ' ' + RE->ReTitulo + '  Comensales: ' + Str( RS->RsComensal ) },;
      oInforme:oReport:oTitle:aFont[ 6 ] := {|| 1 },;
      oInforme:oReport:oTitle:aPad[ 6 ] :=  RPT_LEFT,;
      oInforme:oReport:oTitle:aLine[ 7 ] := {|| 'Día: ' + aDias[ Max( TS->EsDia, 1 ) ] + ' ' + DToC( TS->EsFecha ) + '     ' + 'Hora: ' + TS->EsHora + '     ' + 'Comensales: ' + Str( RS->RsComensal ) },;
      oInforme:oReport:oTitle:aFont[ 7 ] := {|| 1 },;
      oInforme:oReport:oTitle:aPad[ 7 ] :=  RPT_LEFT )
   oInforme:End( .T. )

   RETURN NIL
/*_____________________________________________________________________________*/
FUNCTION MsBcnKitchen3( oGrid, oParent, lReport )

   LOCAL cMsCodigo := MS->MsCodigo
   LOCAL cReCodigo, nReComensal
   LOCAL oDlg, oBrowse, oCol, oInforme
   LOCAL nTotal := 0
   LOCAL aDias     := { 'Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo' }
   LOCAL aComidas  := { 'Desayuno', 'Media mañana', 'Almuerzo', 'Merienda', 'Cena' }

   CursorWait()
   SELECT AL
   AL->( ordSetFocus( 1 ) )
   AL->( dbGoTop() )
   SELECT RE
   RE->( ordSetFocus( 2 ) )
   RE->( dbGoTop() )
   SELECT ES
   ES->( ordSetFocus( 1 ) ) // upper(EsReceta)
   ES->( dbGoTop() )
   SELECT TS
   TS->( DbPack() )
   TS->( Db_ZAP() )
   TS->( ordSetFocus( 2 ) ) // Upper(EsIngred)
   TS->( dbGoTop() )
   SELECT RS
   RS->( ordSetFocus( 1 ) ) // Upper(RsMsCodigo)
   RS->( dbGoTop() )
   RS->( dbSeek( Upper( cMsCodigo ) ) )
   WHILE Upper( RS->RsMsCodigo ) == Upper( cMsCodigo )
      cReCodigo  := RS->RsReCodigo
      SELECT RE
      RE->( dbSeek( cReCodigo ) )
      // nReComensal := RS->RsComensal
      SELECT ES
      ES->( dbSeek( cReCodigo ) )
      WHILE ES->EsReceta == cReCodigo
         SELECT TS
         // en este informe no se suman por ingrediente
         TS->( dbAppend() )
         REPLACE TS->EsReceta  WITH ES->EsReceta
         REPLACE TS->EsIngred  WITH ES->EsIngred
         REPLACE TS->EsInDenomi  WITH ES->EsInDenomi
         REPLACE TS->EsUnidad  WITH ES->EsUnidad
         IF ES->EsCanFija == .T.
            REPLACE TS->EsCantidad  WITH ES->EsCantidad
            REPLACE TS->EsPrecio    WITH ES->EsPrecio
         ELSE
            REPLACE TS->EsCantidad  WITH ES->EsCantidad / RE->ReComEsc * RS->RsComensal
            REPLACE TS->EsPrecio    WITH ES->EsPrecio / RE->ReComEsc * RS->RsComensal
         ENDIF
         REPLACE TS->EsProveed   WITH ES->EsProveed
         REPLACE TS->EsDia       WITH RS->RsDia
         REPLACE TS->EsComida    WITH RS->RsComida
         REPLACE TS->EsFecha     WITH RS->RsFecha
         REPLACE TS->EsHora      WITH RS->RsHora
         AL->( dbSeek( Upper( ES->EsInDenomi ) ) )
         REPLACE TS->EsStock  WITH AL->AlStock
         REPLACE TS->EsUbicaci WITH AL->AlUbicaci
         REPLACE TS->EsAccion  WITH AL->AlAccion
         // endif
         nTotal += ES->EsPrecio / RE->ReComEsc * RS->RsComensal
         TS->( dbCommit() )
         ES->( dbSkip() )
      ENDDO
      RS->( dbSkip() )
   ENDDO
   CursorArrow()

   oInforme := TInforme():New( {}, {}, {}, {}, {}, {}, "MS" )
   oInforme:nRadio := 1
   SELECT TS
   TS->( ordSetFocus( 4 ) )
   TS->( dbGoTop() )
   oInforme:oFont1 := TFont():New( RTrim( oInforme:acFont[ 1 ] ), 0, Val( oInforme:acSizes[ 1 ] ),, ( i18n( "Negrita" ) $ oInforme:acEstilo[ 1 ] ),,,, ( i18n( "Cursiva" ) $ oInforme:acEstilo[ 1 ] ),,,,,,, )
   oInforme:oFont2 := TFont():New( RTrim( oInforme:acFont[ 2 ] ), 0, Val( oInforme:acSizes[ 2 ] ),, ( i18n( "Negrita" ) $ oInforme:acEstilo[ 2 ] ),,,, ( i18n( "Cursiva" ) $ oInforme:acEstilo[ 2 ] ),,,,,,, )
   oInforme:oFont3 := TFont():New( RTrim( oInforme:acFont[ 3 ] ), 0, Val( oInforme:acSizes[ 3 ] ),, ( i18n( "Negrita" ) $ oInforme:acEstilo[ 3 ] ),,,, ( i18n( "Cursiva" ) $ oInforme:acEstilo[ 3 ] ),,,,,,, )

   REPORT oInforme:oReport ;
      TITLE  ' ', RTrim( MS->MsCodigo ) + ' * ' + RTrim( MS->MsDescrip ), 'Totalizado de ingredientes por día/hora', ' ', ' ', ' ', ' ' CENTERED;
      FONT   oInforme:oFont3, oInforme:oFont2, oInforme:oFont1 ;
      HEADER ' ', oApp():cAppName + oApp():cVersion, oApp():cUser   ;
      FOOTER ' ', "Fecha: " + DToC( Date() ) + "   Página.: " + Str( oInforme:oReport:nPage, 3 ) ;
      CAPTION oApp():cAppName + oApp():cVersion PREVIEW
   // 'Receta: '+Rtrim(TS->EsReceta)+' '+Rtrim(RE->ReTitulo),;
   // 'Día: '+aDias[Max(RS->RsDia,1)]+' '+DtoC(RS->RsFecha)+'     '+'Hora: '+RS->RsHora+'     '+'Comensales: '+Str(RS->RsComensal),' '

   COLUMN TITLE "Receta"    DATA TS->EsReceta   FONT 1 SIZE 8
   COLUMN TITLE "Codigo"    DATA TS->EsIngred   FONT 1 SIZE 8
   COLUMN TITLE "Ingrediente" DATA TS->EsInDenomi FONT 1 SIZE 30
   COLUMN TITLE "Cantidad"    DATA TS->EsCantidad FONT 1 PICTURE "@E 999,999.999" SIZE 10
   COLUMN TITLE "Unidad"    DATA TS->EsUnidad   FONT 1 SIZE 13
   COLUMN TITLE "Proveedor"  DATA TS->EsProveed  FONT 1 SIZE 20
   // COLUMN TITLE "Comentarios" DATA space(60)      FONT 1 SIZE 60
   COLUMN TITLE "Ubicación"  DATA TS->EsUbicaci FONT 1 SIZE 15
   COLUMN TITLE "Acción"    DATA TS->EsAccion  FONT 1 SIZE 10
   COLUMN TITLE "Stock"    DATA Tran( TS->EsStock, "@E 9,999.99" ) FONT 1 SIZE 8
   GROUP ON DToS( TS->EsFecha ) + TS->EsHora ;
      FOOTER " " EJECT

   RptEnd()
   oInforme:oReport:Cargo := "Totalizado de ingredientes por dia-hora.pdf"
   IF oInforme:oReport:lCreated
      oInforme:oReport:nTitleUpLine     := RPT_SINGLELINE
      oInforme:oReport:nTitleDnLine     := RPT_SINGLELINE
      oInforme:oReport:oTitle:aFont[ 2 ]  := {|| 3 }
      // oInforme:oReport:oTitle:aFont[5]  := {|| 2 }
      // oInforme:oReport:oTitle:aFont[6]  := {|| 2 }
      oInforme:oReport:nTopMargin       := 0.1
      oInforme:oReport:nDnMargin        := 0.1
      oInforme:oReport:nLeftMargin      := 0.1
      oInforme:oReport:nRightMargin     := 0.1
      oInforme:oReport:oDevice:lPrvModal := .T.
   ENDIF
   // oInforme:oReport:bSkip := {|| nAt++}
   ACTIVATE REPORT oInforme:oReport ;
      ON STARTPAGE ( RE->( dbSeek( TS->EsReceta ) ), RS->( dbSeek( Upper( MS->MsCodigo ) + Upper( TS->EsReceta ) ) ), ;
      oInforme:oReport:oTitle:aLine[ 5 ] := {|| 'Taller/Receta: ' + RTrim( TS->EsReceta ) + ' ' + RTrim( RE->ReTitulo ) },;
      oInforme:oReport:oTitle:aFont[ 5 ] := {|| 1 },;
      oInforme:oReport:oTitle:aPad[ 5 ] :=  RPT_LEFT,;
      oInforme:oReport:oTitle:aLine[ 6 ] := {|| 'Día: ' + aDias[ Max( TS->EsDia, 1 ) ] + ' ' + DToC( TS->EsFecha ) + '     ' + 'Hora: ' + TS->EsHora + '     ' + 'Comensales: ' + Str( RS->RsComensal ) },;
      oInforme:oReport:oTitle:aFont[ 6 ] := {|| 1 },;
      oInforme:oReport:oTitle:aPad[ 6 ] :=  RPT_LEFT )
   oInforme:End( .T. )

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION MsImprime( oGrid, oParent )

   LOCAL nRecno   := MS->( RecNo() )
   LOCAL nOrder   := MS->( ordSetFocus() )
   LOCAL aCampos  := { "MSCODIGO", "MSDESCRIP", "MSFCHPREP", "MSCOMENS"  }
   LOCAL aTitulos := { "Código", "Descripción", "Fecha Preparación", "Comensales" }
   LOCAL aWidth   := { 8, 60, 15, 10 }
   LOCAL aShow    := { .T., .T., .T., .T. }
   LOCAL aPicture := { "NO", "NO", "NO", "NO" }
   LOCAL aTotal   := { .F., .F., .F., .F. }
   LOCAL oInforme
   LOCAL aTPlato   := { 'Entradas', '1er Plato', '2o Plato', 'Postre', 'Dulce', 'Otro' }
   LOCAL aDias     := { 'Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo' }
   LOCAL aComidas  := { 'Desayuno', 'Media mañana', 'Almuerzo', 'Merienda', 'Cena' }
   LOCAL cReMsCodigo
   LOCAL aRe := {}
   LOCAL nAt := 1

   oApp():nEdit ++
   oInforme := TInforme():New( aCampos, aTitulos, aWidth, aShow, aPicture, aTotal, "MS" )
   oInforme:Dialog()

   REDEFINE RADIO oInforme:oRadio VAR oInforme:nRadio ID 300, 301, 302  OF oInforme:oFld:aDialogs[ 1 ]

   oInforme:Folders()

   IF oInforme:Activate()
      SELECT MS
      IF oInforme:nRadio == 1
         MS->( dbGoTop() )
         oInforme:Report()
         ACTIVATE REPORT oInforme:oReport ;
            ON END ( oInforme:oReport:StartLine(), oInforme:oReport:EndLine(), oInforme:oReport:StartLine(), ;
            oInforme:oReport:Say( 1, 'Total menús: ' + Tran( oInforme:oReport:nCounter, '@E 999,999' ), 1 ), ;
            oInforme:oReport:EndLine() )
         oInforme:End( .T. )
         MS->( dbGoto( nRecno ) )
      ELSEIF oInforme:nRadio == 2
         SELECT RS
         cReMsCodigo := MS->MsCodigo
         SELECT RE
         RE->( ordSetFocus( 2 ) )
         SELECT RS
         RS->( dbGoTop() )
         DO WHILE ! RS->( Eof() )
            IF Upper( RS->RsMsCodigo ) == Upper( cReMsCodigo )
               RE->( dbGoTop() )
               RE->( dbSeek( RS->RsReCodigo ) )
               AAdd( aRe, { aDias[ RS->RsDia ], ;
                  aComidas[ RS->RsComida ], ;
                  RE->ReCodigo,;
                  RE->ReTitulo,;
                  aTPlato[ Max( Val( RE->RePlato ), 1 ) ], ;
                  RE->ReTipo,;
                  RS->RsComensal } )
            ENDIF
            RS->( dbSkip() )
         ENDDO
         ASort( aRe,,, {| x, y| 10 * AScan( aDias, x[ 1 ] ) + AScan( aComidas, x[ 2 ] ) < 10 * AScan( aDias, y[ 1 ] ) + AScan( aComidas, y[ 2 ] ) } )

         oInforme:oFont1 := TFont():New( RTrim( oInforme:acFont[ 1 ] ), 0, Val( oInforme:acSizes[ 1 ] ),, ( i18n( "Negrita" ) $ oInforme:acEstilo[ 1 ] ),,,, ( i18n( "Cursiva" ) $ oInforme:acEstilo[ 1 ] ),,,,,,, )
         oInforme:oFont2 := TFont():New( RTrim( oInforme:acFont[ 2 ] ), 0, Val( oInforme:acSizes[ 2 ] ),, ( i18n( "Negrita" ) $ oInforme:acEstilo[ 2 ] ),,,, ( i18n( "Cursiva" ) $ oInforme:acEstilo[ 2 ] ),,,,,,, )
         oInforme:oFont3 := TFont():New( RTrim( oInforme:acFont[ 3 ] ), 0, Val( oInforme:acSizes[ 3 ] ),, ( i18n( "Negrita" ) $ oInforme:acEstilo[ 3 ] ),,,, ( i18n( "Cursiva" ) $ oInforme:acEstilo[ 3 ] ),,,,,,, )
         IF oInforme:nDevice == 1
            REPORT oInforme:oReport ;
               TITLE  ' ', MS->MsCodigo + ' ' + RTrim( MS->MsDescrip ), 'Relación de recetas del menú semanal' CENTERED;
               FONT   oInforme:oFont3, oInforme:oFont2, oInforme:oFont1 ;
               HEADER ' ', oApp():cAppName + oApp():cVersion, oApp():cUser   ;
               FOOTER ' ', "Fecha: " + DToC( Date() ) + "   Página.: " + Str( oInforme:oReport:nPage, 3 ) ;
               CAPTION oApp():cAppName + oApp():cVersion PREVIEW
         ELSE
            REPORT oInforme:oReport ;
               TITLE ' ', MS->MsCodigo + ' ' + RTrim( MS->MsDescrip ), 'Relación de recetas del menú semanal' CENTERED;
               FONT   oInforme:oFont3, oInforme:oFont2, oInforme:oFont1 ;
               HEADER ' ', oApp():cAppName + oApp():cVersion, oApp():cUser   ;
               FOOTER ' ', "Fecha: " + DToC( Date() ) + "   Página.: " + Str( oInforme:oReport:nPage, 3 ) ;
               CAPTION oApp():cAppName + oApp():cVersion
         ENDIF
         COLUMN TITLE "Día"     DATA aRe[ nAt, 1 ] FONT 1 SIZE 8
         COLUMN TITLE "Comida"  DATA aRe[ nAt, 2 ] FONT 1 SIZE 8
         COLUMN TITLE "Codigo"  DATA aRe[ nAt, 3 ] FONT 1 SIZE 8
         COLUMN TITLE "Receta"  DATA aRe[ nAt, 4 ] FONT 1 SIZE 30
         COLUMN TITLE "Categoría"  DATA aRe[ nAt, 5 ] FONT 1 SIZE 18
         COLUMN TITLE "Plato"      DATA aRe[ nAt, 6 ] FONT 1 SIZE 18
         COLUMN TITLE "Comensales" DATA aRe[ nAt, 7 ] FONT 1 SIZE 13
         RptEnd()
         oInforme:oReport:Cargo := "Recetas del menú semanal.pdf"
         IF oInforme:oReport:lCreated
            oInforme:oReport:nTitleUpLine     := RPT_SINGLELINE
            oInforme:oReport:nTitleDnLine     := RPT_SINGLELINE
            oInforme:oReport:oTitle:aFont[ 1 ]  := {|| 3 }
            oInforme:oReport:oTitle:aFont[ 2 ]  := {|| 2 }
            oInforme:oReport:nTopMargin       := 0.1
            oInforme:oReport:nDnMargin        := 0.1
            oInforme:oReport:nLeftMargin      := 0.1
            oInforme:oReport:nRightMargin     := 0.1
            oInforme:oReport:oDevice:lPrvModal := .T.
         ENDIF
         oInforme:oReport:bSkip := {|| nAt++ }
         ACTIVATE REPORT oInforme:oReport WHILE nAt <= Len( aRe )
         oInforme:End( .T. )
      ELSEIF oInforme:nRadio == 3
         MsCompra(,, .T. )
         MsCompraInforme( oInforme )
   /*
   Select TS
   TS->(DbGoTop())
   oInforme:oFont1 := TFont():New( Rtrim( oInforme:acFont[ 1 ] ), 0, Val( oInforme:acSizes[ 1 ] ),,( i18n("Negrita") $ oInforme:acEstilo[ 1 ] ),,,,( i18n("Cursiva") $ oInforme:acEstilo[ 1 ] ),,,,,,, )
   oInforme:oFont2 := TFont():New( Rtrim( oInforme:acFont[ 2 ] ), 0, Val( oInforme:acSizes[ 2 ] ),,( i18n("Negrita") $ oInforme:acEstilo[ 2 ] ),,,,( i18n("Cursiva") $ oInforme:acEstilo[ 2 ] ),,,,,,, )
   oInforme:oFont3 := TFont():New( Rtrim( oInforme:acFont[ 3 ] ), 0, Val( oInforme:acSizes[ 3 ] ),,( i18n("Negrita") $ oInforme:acEstilo[ 3 ] ),,,,( i18n("Cursiva") $ oInforme:acEstilo[ 3 ] ),,,,,,, )
   if oInforme:nDevice == 1
    REPORT oInforme:oReport ;
     TITLE  ' ',ME->MeCodigo+' '+Rtrim(ME->MeDescrip),'Lista de la compra',' ' CENTERED;
     FONT   oInforme:oFont3, oInforme:oFont2, oInforme:oFont1 ;
     HEADER ' ', oApp():cAppName+oApp():cVersion, oApp():cUser   ;
     FOOTER ' ', "Fecha: "+dtoc(date())+ "   Página.: "+str(oInforme:oReport:nPage,3) ;
     CAPTION oApp():cAppName+oApp():cVersion PREVIEW
   else
    REPORT oInforme:oReport ;
     TITLE  ' ',ME->MeCodigo+' '+Rtrim(ME->MeDescrip),'Lista de la compra',' ' CENTERED;
     FONT   oInforme:oFont3, oInforme:oFont2, oInforme:oFont1 ;
     HEADER ' ', oApp():cAppName+oApp():cVersion, oApp():cUser   ;
     FOOTER ' ', "Fecha: "+dtoc(date())+ "   Página.: "+str(oInforme:oReport:nPage,3) ;
     CAPTION oApp():cAppName+oApp():cVersion
   endif
   COLUMN TITLE "Codigo"    DATA TS->EsIngred   FONT 1 SIZE 8
   COLUMN TITLE "Ingrediente" DATA TS->EsInDenomi FONT 1 SIZE 30
   COLUMN TITLE "Unidad"    DATA TS->EsUnidad   FONT 1 SIZE 18
   COLUMN TITLE "Cantidad"    DATA TS->EsCantidad FONT 1 PICTURE "@E 999,999.999" SIZE 10
   COLUMN TITLE "Precio"   DATA TS->EsPrecio   FONT 1 PICTURE "@E 999,999.99" SIZE 10 TOTAL
   RptEnd()
   oInforme:oReport:Cargo := "Lista de la compra del menú.pdf"
     if oInforme:oReport:lCreated
        oInforme:oReport:nTitleUpLine     := RPT_SINGLELINE
        oInforme:oReport:nTitleDnLine     := RPT_SINGLELINE
        oInforme:oReport:oTitle:aFont[2]  := {|| 3 }
        oInforme:oReport:oTitle:aFont[3]  := {|| 2 }
        oInforme:oReport:nTopMargin       := 0.1
        oInforme:oReport:nDnMargin        := 0.1
        oInforme:oReport:nLeftMargin      := 0.1
        oInforme:oReport:nRightMargin     := 0.1
        oInforme:oReport:oDevice:lPrvModal:= .t.
     endif
   // oInforme:oReport:bSkip := {|| nAt++}
   ACTIVATE REPORT oInforme:oReport
   oInforme:End(.t.)
   */
      ENDIF
      SELECT ME
   ENDIF
   oApp():nEdit --
   oGrid:Refresh()
   oGrid:SetFocus( .T. )

   RETURN NIL
/*_____________________________________________________________________________*/
FUNCTION MsCompraInforme( oInforme )

   IF oInforme == NIL
      oInforme := TInforme():New( {}, {}, {}, {}, {}, {}, "MS" )
      oInforme:nRadio := 1
   ENDIF
   SELECT TS
   TS->( dbGoTop() )
   oInforme:oFont1 := TFont():New( RTrim( oInforme:acFont[ 1 ] ), 0, Val( oInforme:acSizes[ 1 ] ),, ( i18n( "Negrita" ) $ oInforme:acEstilo[ 1 ] ),,,, ( i18n( "Cursiva" ) $ oInforme:acEstilo[ 1 ] ),,,,,,, )
   oInforme:oFont2 := TFont():New( RTrim( oInforme:acFont[ 2 ] ), 0, Val( oInforme:acSizes[ 2 ] ),, ( i18n( "Negrita" ) $ oInforme:acEstilo[ 2 ] ),,,, ( i18n( "Cursiva" ) $ oInforme:acEstilo[ 2 ] ),,,,,,, )
   oInforme:oFont3 := TFont():New( RTrim( oInforme:acFont[ 3 ] ), 0, Val( oInforme:acSizes[ 3 ] ),, ( i18n( "Negrita" ) $ oInforme:acEstilo[ 3 ] ),,,, ( i18n( "Cursiva" ) $ oInforme:acEstilo[ 3 ] ),,,,,,, )

   REPORT oInforme:oReport ;
      TITLE  ' ', RTrim( MS->MsCodigo ) + ' * ' + RTrim( MS->MsDescrip ), 'Lista de la compra', ' ' CENTERED;
      FONT   oInforme:oFont3, oInforme:oFont2, oInforme:oFont1 ;
      HEADER ' ', oApp():cAppName + oApp():cVersion, oApp():cUser   ;
      FOOTER ' ', "Fecha: " + DToC( Date() ) + "   Página.: " + Str( oInforme:oReport:nPage, 3 ) ;
      CAPTION oApp():cAppName + oApp():cVersion PREVIEW

   COLUMN TITLE "Codigo"    DATA TS->EsIngred   FONT 1 SIZE 8
   COLUMN TITLE "Ingrediente" DATA TS->EsInDenomi FONT 1 SIZE 30
   COLUMN TITLE "Unidad"    DATA TS->EsUnidad   FONT 1 SIZE 10
   COLUMN TITLE "Cantidad"    DATA TS->EsCantidad FONT 1 PICTURE "@E 999,999.999" SIZE 10
   COLUMN TITLE "Precio"   DATA TS->EsPrecio   FONT 1 PICTURE "@E 999,999.99" SIZE 10 TOTAL
   COLUMN TITLE "Proveedor"   DATA TS->EsProveed  FONT 1 SIZE 20

   RptEnd()
   oInforme:oReport:Cargo := "Lista de la compra del menú.pdf"
   IF oInforme:oReport:lCreated
      oInforme:oReport:nTitleUpLine     := RPT_SINGLELINE
      oInforme:oReport:nTitleDnLine     := RPT_SINGLELINE
      oInforme:oReport:oTitle:aFont[ 2 ]  := {|| 3 }
      oInforme:oReport:oTitle:aFont[ 3 ]  := {|| 2 }
      oInforme:oReport:nTopMargin       := 0.1
      oInforme:oReport:nDnMargin        := 0.1
      oInforme:oReport:nLeftMargin      := 0.1
      oInforme:oReport:nRightMargin     := 0.1
      oInforme:oReport:oDevice:lPrvModal := .T.
   ENDIF
   // oInforme:oReport:bSkip := {|| nAt++}
   ACTIVATE REPORT oInforme:oReport
   oInforme:End( .T. )

   RETURN NIL

FUNCTION MsGetRecetas( cMsCodigo )

   LOCAL nReturn := 0

   SELECT RS
   RS->( dbGoTop() )
   COUNT TO nReturn FOR Upper( RS->RsMsCodigo ) == Upper( cMsCodigo ) .AND. ! Deleted()
   SELECT MS

   RETURN nReturn

FUNCTION MsSort( nOrden, oCont )

   LOCAL nRecno := MS->( RecNo() )
   LOCAL nLen   := Len( oApp():oGrid:aCols )
   LOCAL n

   FOR n := 1 TO nLen
      IF oApp():oGrid:aCols[ n ]:nHeadBmpNo != NIL .AND. oApp():oGrid:aCols[ n ]:nHeadBmpNo > 0
         IF oApp():oGrid:aCols[ n ]:Cargo == nOrden
            oApp():oGrid:aCols[ n ]:nHeadBmpNo := 1
         ELSE
            oApp():oGrid:aCols[ n ]:nHeadBmpNo := 2
         ENDIF
      ENDIF
   NEXT
   oApp():oTab:SetOption( nOrden )
   MS->( dbSetOrder( norden ) )
   iif( MS->( Eof() ), MS->( dbGoTop() ), )
   Refreshcont( ocont, "MS" )
   MS->( dbGoto( nRecno ) )
   oApp():oGrid:Refresh( .T. )
   oApp():oGrid:SetFocus( .T. )

   RETURN NIL
