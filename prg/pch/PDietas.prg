#include "FiveWin.ch"
#include "Report.ch"
#include "xBrowse.ch"
#include "vmenu.ch"

STATIC oReport

FUNCTION Dietas()

   LOCAL oBar, oCol, oCont
   LOCAL aBrowse
   LOCAL cState := GetPvProfString( "Browse", "DiState", "", oApp():cInifile )
   LOCAL nOrder := Max( Val( GetPvProfString( "Browse", "DiOrder", "1", oApp():cInifile ) ), 1 )
   LOCAL nRecno := Val( GetPvProfString( "Browse", "DiRecno", "1", oApp():cInifile ) )
   LOCAL nSplit := Val( GetPvProfString( "Browse", "DiSplit", "102", oApp():cInifile ) )
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

   SELECT DI
   oApp():oDlg := TFsdi():New( oApp():oWndMain )
   oApp():oDlg:cTitle := i18n( 'Gestión de dietas y tolerancias' )
   oApp():oWndMain:oClient := oApp():oDlg
   oApp():oDlg:NewGrid( nSplit )

   Ut_BrwRowConfig( oApp():oGrid )
   oApp():oGrid:cAlias := "DI"

   oCol := oApp():oGrid:AddCol()
   oCol:Cargo    := 1
   oCol:AddResource( "16_SORT_A" )
   oCol:nHeadBmpNo    := 1
   oCol:nHeadBmpAlign := AL_RIGHT
   oCol:bStrData :=  {|| DI->DiDieta }
   oCol:cHeader  := "Dieta / Tolerancia"
   oCol:nWidth   := 150

   ADD oCol TO oApp():oGrid DATA DI->DiRecetas ;
      HEADER "Recetas" PICTURE "@E 999,999" ;
      TOTAL 0 WIDTH 90

   FOR i := 1 TO Len( oApp():oGrid:aCols )
      oCol := oApp():oGrid:aCols[ i ]
      oCol:bLDClickData  := {|| DiEdita( oApp():oGrid, 2, oCont, oApp():oDlg ) }
   NEXT

   oApp():oGrid:SetRDD()
   oApp():oGrid:CreateFromCode()
   oApp():oGrid:bChange  := {|| RefreshCont( oCont, "DI" ), oApp():oGrid:Maketotals() }
   oApp():oGrid:bKeyDown := {| nKey| DiTecla( nKey, oApp():oGrid, oCont, oApp():oDlg ) }
   oApp():oGrid:nRowHeight  := 21
   oApp():oGrid:RestoreState( cState )
   oApp():oGrid:lFooter := .T.
   oApp():oGrid:bClrFooter := {|| { CLR_HRED, GetSysColor( 15 ) } }
   oApp():oGrid:MakeTotals()

   DI->( dbSetOrder( nOrder ) )
   IF nRecNo < DI->( LastRec() ) .AND. nRecno != 0
      DI->( dbGoto( nRecno ) )
   ELSE
      DI->( dbGoTop() )
   ENDIF

   @ 02, 05 VMENU oCont SIZE nSplit - 10, 18 OF oApp():oDlg  ;
      COLOR CLR_BLACK, GetSysColor( 15 )       ;
      FILLED   ;  // BORDER
   COLORSELECT 0, CLR_WHITE ;
      HEIGHT ITEM 22

   DEFINE TITLE OF oCont ;
      CAPTION tran( DI->( ordKeyNo() ), '@E 999,999' ) + " / " + tran( DI->( ordKeyCount() ), '@E 999,999' ) ;
      HEIGHT 25 ;
      COLOR GetSysColor( 9 ), oApp():nClrBar ;
      IMAGE "BB_DIETAS"

   @ 24, 05 VMENU oBar SIZE nSplit - 10, 160 OF oApp():oDlg  ;
      COLOR CLR_BLACK, GetSysColor( 15 )       ;
      HEIGHT ITEM 22 XBOX
   oBar:nClrBox := Min( GetSysColor( 13 ), GetSysColor( 14 ) )

   DEFINE TITLE OF oBar ;
      CAPTION i18n( "Dietas y tolerancias" ) ;
      HEIGHT 24 ;
      COLOR GetSysColor( 9 ), oApp():nClrBar ;
      OPENCLOSE

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Nuevo"              ;
      IMAGE "16_NUEVO"             ;
      ACTION DiEdita( oApp():oGrid, 1, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Modificar"          ;
      IMAGE "16_MODIF"             ;
      ACTION DiEdita( oApp():oGrid, 2, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Duplicar"           ;
      IMAGE "16_DUPLICA"           ;
      ACTION DiEdita( oApp():oGrid, 3, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Borrar"             ;
      IMAGE "16_BORRAR"            ;
      ACTION DiBorra( oApp():oGrid, oCont );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Buscar"             ;
      IMAGE "16_BUSCA"             ;
      ACTION DiBusca( oApp():oGrid,, oCont, oApp():oDlg )  ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Imprimir"           ;
      IMAGE "16_IMPRIMIR"          ;
      ACTION DiImprime( oApp():oGrid, oApp():oDlg )         ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Ver recetas"        ;
      IMAGE "16_RECETAS"        ;
      ACTION DiEjemplares( oApp():oGrid, oApp():oDlg ) ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Excel"              ;
      IMAGE "16_EXCEL"             ;
      ACTION ( CursorWait(), Ut_ExportXLS( oApp():oGrid, "Dietas" ), CursorArrow() );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Configurar rejilla" ;
      IMAGE "16_GRID"              ;
      ACTION Ut_BrwColConfig( oApp():oGrid, "DiState" ) ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Salir"              ;
      IMAGE "16_SALIR"             ;
      ACTION oApp():oDlg:End()              ;
      LEFT 10

   @ oApp():oDlg:nGridBottom, nSplit + 2 TABS oApp():oTab ;
      OPTION nOrder SIZE oApp():oWndMain:nWidth() -80, 12 PIXEL OF oApp():oDlg ;
      ITEMS ' Dietas / Tolerancias '

   oApp():oDlg:NewSplitter( nSplit, oCont, oBar )

   ACTIVATE DIALOG oApp():oDlg NOWAIT ;
      ON INIT ( ResizeWndMain(), oApp():oGrid:SetFocus() ) ;
      VALID ( oApp():oGrid:nLen := 0,;
      WritePProString( "Browse", "DiState", oApp():oGrid:SaveState(), oApp():cInifile ),;
      WritePProString( "Browse", "DiOrder", LTrim( Str( DI->( ordNumber() ) ) ), oApp():cInifile ),;
      WritePProString( "Browse", "DiRecno", LTrim( Str( DI->( RecNo() ) ) ), oApp():cInifile ),;
      WritePProString( "Browse", "DiSplit", LTrim( Str( oApp():oSplit:nleft / 2 ) ), oApp():cInifile ),;
      oBar:End(), dbCloseAll(), oApp():oDlg := NIL, oApp():oGrid := NIL, oApp():oTab := NIL, .T. )

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION DiEdita( oGrid, nMode, oCont, oParent, cDieta )

   LOCAL oDlg, oFld, oBmp
   LOCAL aTitle := { i18n( "Añadir dieta / intolerancia" ),;
      i18n( "Modificar dieta / intolerancia" ),;
      i18n( "Duplicar dieta / intolerancia" ) }
   LOCAL aGet[ 1 ]
   LOCAL cDiDieta
   LOCAL nRecPtr := DI->( RecNo() )
   LOCAL nOrden  := DI->( ordNumber() )
   LOCAL nRecAdd
   LOCAL lDuplicado
   LOCAL lreturn := .F.
   LOCAL nLen

   IF DI->( Eof() ) .AND. nMode != 1
      RETURN NIL
   ENDIF

   oApp():nEdit ++

   IF nMode == 1
      DI->( dbAppend() )
      nRecAdd := DI->( RecNo() )
   ENDIF

   cDiDieta := iif( nMode == 1 .AND. cDieta != nil, cDieta, DI->DiDieta )

   IF nMode == 3
      DI->( dbAppend() )
      nRecAdd := DI->( RecNo() )
   ENDIF

   DEFINE DIALOG oDlg RESOURCE "DI_EDIT_" + oApp():cLanguage OF oParent   ;
      TITLE aTitle[ nMode ]
   oDlg:SetFont( oApp():oFont )

   REDEFINE GET aGet[ 1 ] VAR cDiDieta   ;
      ID 12 OF oDlg UPDATE             ;
      VALID DiClave( cDiDieta, aGet[ 1 ], nMode )

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
         SELECT RE
         RE->( dbGoTop() )
         nLen := Len( DI->DiDieta ) + 1 // por el ;
         WHILE ! RE->( Eof() )
            IF At( cDiDieta, RE->ReDietas ) != 0
               REPLACE RE->ReDietas WITH Stuff( RE->ReDietas, At( cDieta, RE->ReDietas ), nLen, "" ) + RTrim( cDiDieta ) + ";"
            ENDIF
            RE->( dbSkip() )
         ENDDO
         SELECT DI
      ENDIF

      /* ___ guardo el registro _______________________________________________*/
      IF nMode == 2
         DI->( dbGoto( nRecPtr ) )
      ELSE
         DI->( dbGoto( nRecAdd ) )
      ENDIF
      REPLACE DI->DiDieta WITH cDiDieta
      DI->( dbCommit() )
   ELSE
      IF nMode == 1 .OR. nMode == 3
         DI->( dbGoto( nRecAdd ) )
         DI->( dbDelete() )
         DI->( DbPack() )
         DI->( dbGoto( nRecPtr ) )
      ENDIF
   ENDIF

   SELECT DI
   IF oCont != nil
      RefreshCont( oCont, "DI" )
   ENDIF
   IF oGrid != nil
      oGrid:Refresh()
      oGrid:SetFocus( .T. )
   ENDIF
   oApp():nEdit --

   RETURN lreturn
/*_____________________________________________________________________________*/

FUNCTION DiBorra( oGrid, oCont )

   LOCAL nRecord := DI->( RecNo() )
   LOCAL cDieta  := Trim( DI->DiDieta )
   LOCAL nLen   := Len( cDieta ) + 1 // por el ;
   LOCAL nNext

   oApp():nEdit ++

   IF msgYesNo( i18n( "¿ Está seguro de querer borrar esta dieta / tolerancia ?" ) + CRLF + cDieta, 'Seleccione una opción' )
      // quito la dieta de las recetas en que aparezca
      SELECT RE
      RE->( dbGoTop() )
      WHILE ! RE->( Eof() )
         IF At( cDieta, RE->ReDietas ) != 0
            REPLACE RE->ReDietas WITH Stuff( RE->ReDietas, At( cDieta, RE->ReDietas ), nLen, "" )
         ENDIF
         RE->( dbSkip() )
      ENDDO

      // borro la dieta
      DI->( dbSkip() )
      nNext := DI->( RecNo() )
      DI->( dbGoto( nRecord ) )

      DI->( dbDelete() )
      DI->( DbPack() )
      DI->( dbGoto( nNext ) )
      IF DI->( Eof() ) .OR. nNext == nRecord
         DI->( dbGoBottom() )
      ENDIF
   ENDIF

   IF oCont != nil
      RefreshCont( oCont, "DI" )
   ENDIF

   oGrid:Refresh( .T. )
   oGrid:SetFocus( .T. )
   oApp():nEdit --

   RETURN NIL
/*_____________________________________________________________________________*/
FUNCTION DiTecla( nKey, oGrid, oCont, oDlg )

   DO CASE
   CASE nKey == VK_RETURN
      DiEdita( oGrid, 2, oCont, oDlg )
   CASE nKey == VK_INSERT
      DiEdita( oGrid, 1, oCont, oDlg )
   CASE nKey == VK_DELETE
      DiBorra( oGrid, oCont )
   CASE nKey == VK_ESCAPE
      oDlg:End()
   OTHERWISE
      IF nKey >= 96 .AND. nKey <= 105
         DiBusca( oGrid, Str( nKey - 96, 1 ), oCont, oDlg )
      ELSEIF HB_ISSTRING( Chr( nKey ) )
         DiBusca( oGrid, Chr( nKey ), oCont, oDlg )
      ENDIF
   ENDCASE

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION DiSeleccion( aItems, oControl, oParent, cDieta, oVItem )

   LOCAL oDlg, oBrowse, oCol, oBtnAceptar, oBtnCancel, oBNew, oBMod, oBDel
   LOCAL lOk    := .F.
   LOCAL nRecno := DI->( RecNo() )
   LOCAL nOrder := DI->( ordNumber() )
   LOCAL nArea  := Select()
   LOCAL aPoint := iif( oControl != NIL, AdjustWnd( oControl, 271 * 2, 150 * 2 ), { 1.3 * oVItem:nTop(), oApp():oGrid:nLeft } )

   DEFINE DIALOG oDlg RESOURCE 'UT_AJENA1_' + oApp():cLanguage OF oParent;
      TITLE i18n( "Selección de dietas / tolerancias" )
   oDlg:SetFont( oApp():oFont )

   // siempre tengo ordenado por nombre

   SELECT DI
   DI->( dbSetOrder( 1 ) )
   DI->( dbGoTop() )

   oBrowse := TXBrowse():New( oDlg )
   Ut_BrwRowConfig( oBrowse )
   oBrowse:cAlias := "DI"

   oCol := oBrowse:AddCol()
   oCol:bStrData := {|| DI->DiDieta }
   oCol:cHeader  := "Dieta / tolerancia"
   oCol:nWidth   := 160
   oCol:bLDClickData  := {|| ( lOk := .T., oDlg:End() )   }
   oBrowse:SetRDD()
   oBrowse:CreateFromResource( 110 )
   oBrowse:bKeyDown := {| nKey| IpSeTecla( nKey, oBrowse, oDlg, oBtnAceptar ) }

   REDEFINE BUTTON oBNew   ;
      ID 410 OF oDlg       ;
      ACTION DiEdita( oBrowse, 1,, oDlg )

   REDEFINE BUTTON oBMod   ;
      ID 411 OF oDlg       ;
      ACTION DiEdita( oBrowse, 2,, oDlg )

   REDEFINE BUTTON oBDel   ;
      ID 412 OF oDlg       ;
      ACTION DiBorra( oBrowse, )

   REDEFINE BUTTON oBtnAceptar   ;
      ID IDOK OF oDlg            ;
      ACTION ( lOk := .T., oDlg:End() )

   REDEFINE BUTTON oBtnCancel    ;
      ID IDCANCEL OF oDlg        ;
      ACTION ( lOk := .F., oDlg:End() )

   ACTIVATE DIALOG oDlg CENTERED       ;
      ON PAINT oDlg:Move( aPoint[ 1 ], aPoint[ 2 ],,, .T. )

   IF lOK
      IF oControl == NIL
         cDieta := RTrim( DI->DiDieta )
      ELSE
         IF AScan( aItems, RTrim( DI->DiDieta ) ) == 0
            oControl:Additem( RTrim( DI->DiDieta ) )
            AAdd( aItems, RTrim( DI->DiDieta ) )
            oControl:Refresh()
         ELSE
            msgAlert( 'La dieta/tolerancia ya aparece en la receta.' )
         ENDIF
      ENDIF
   ENDIF

   IP->( dbSetOrder( nOrder ) )
   IP->( dbGoto( nRecno ) )

   SELECT ( nArea )

   RETURN NIL
/*_____________________________________________________________________________*/
FUNCTION DiSeTecla( nKey, oGrid, oDlg, oBtn )

   DO CASE
   CASE nKey == VK_RETURN
      oBtn:Click()
   CASE nKey == VK_ESCAPE
      oDlg:End()
   OTHERWISE
      IF nKey >= 96 .AND. nKey <= 105
         IpBusca( oGrid, Str( nKey - 96, 1 ),, oDlg )
      ELSEIF HB_ISSTRING( Chr( nKey ) )
         IpBusca( oGrid, Chr( nKey ),, oDlg )
      ENDIF
   ENDCASE

   RETURN NIL
/*_____________________________________________________________________________*/
FUNCTION DiBusca( oGrid, cChr, oCont, oParent )

   LOCAL nOrder   := DI->( ordNumber() )
   LOCAL nRecno   := DI->( RecNo() )
   LOCAL oDlg, oGet, cGet, cPicture
   LOCAL aSay1    := { "Introduzca el nombre de la dieta / tolerancia" }
   LOCAL aSay2    := { "Dieta / Tolerancia:" }
   LOCAL aGet     := { Space( 20 ) }
   LOCAL lSeek    := .F.
   LOCAL lFecha   := .F.
   LOCAL aBrowse := {}

   oApp():nEdit ++

   DEFINE DIALOG oDlg RESOURCE 'UT_BUSCA_' + oApp():cLanguage OF oParent  ;
      TITLE i18n( "Búsqueda de dietas / tolerancias" )
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
         {|| DiWildSeek( nOrder, cGet, aBrowse ) } )
      IF Len( aBrowse ) == 0
         MsgStop( "No se ha encontrado ninguna dieta." )
      ELSE
         DiEncontrados( aBrowse, oApp():oDlg )
      ENDIF
   ENDIF
   IF oCont != NIL
      RefreshCont( oCont, "DI" )
   ENDIF
	
   oApp():nEdit --
   oGrid:Refresh()
   oGrid:SetFocus( .T. )

   RETURN NIL
/*_____________________________________________________________________________*/
FUNCTION DiWildSeek( nOrder, cGet, aBrowse )

   LOCAL nRecno   := DI->( RecNo() )
	
   DI->( dbGoTop() )
   DO WHILE ! DI->( Eof() )
      IF cGet $ Upper( DI->DiDieta )
         AAdd( aBrowse, { DI->DiDieta, DI->DiRecetas, DI->( RecNo() ) } )
      ENDIF
      DI->( dbSkip() )
   ENDDO
   DI->( dbGoto( nRecno ) )
   // ordeno la tabla por el 1 elemento
   ASort( aBrowse,,, {|aAut1, aAut2| Upper( aAut1[ 1 ] ) < Upper( aAut2[ 1 ] ) } )

   RETURN NIL
/*_____________________________________________________________________________*/
	
FUNCTION DiEncontrados( aBrowse, oParent )

   LOCAL oDlg, oBrowse, oBtnOk, oBtnCancel, lOk
   LOCAL nRecno := DI->( RecNo() )
	
   DEFINE DIALOG oDlg RESOURCE "DLG_ENCONTRADOS" ;
      TITLE i18n( "Resultado de la búsqueda" ) ;
      OF oParent
   oDlg:SetFont( oApp():oFont )
	
   oBrowse := TXBrowse():New( oDlg )
   Ut_BrwRowConfig( oBrowse )

   oBrowse:SetArray( aBrowse, .F. )
   oBrowse:aCols[ 1 ]:cHeader := "Dietas"
   oBrowse:aCols[ 2 ]:cHeader := "Recetas"
   oBrowse:aCols[ 1 ]:nWidth  := 340
   oBrowse:aCols[ 2 ]:nWidth  := 100
   oBrowse:aCols[ 3 ]:Hide()
   oBrowse:aCols[ 1 ]:nHeadStrAlign := 0
   oBrowse:aCols[ 1 ]:nDataStrAlign := 0
   oBrowse:aCols[ 2 ]:nHeadStrAlign := 0
   oBrowse:aCols[ 2 ]:nDataStrAlign := 0
	
   oBrowse:CreateFromResource( 110 )
	
   DI->( dbGoto( aBrowse[ oBrowse:nArrayAt, 3 ] ) )
   AEval( oBrowse:aCols, {|oCol| oCol:bLDClickData := {|| DI->( dbGoto( aBrowse[ oBrowse:nArrayAt, 3 ] ) ), ;
      DiEdita( , 2,, oApp():oDlg ) } } )
   oBrowse:bKeyDown  := {| nKey| iif( nKey == VK_RETURN, ( DI->( dbGoto( aBrowse[ oBrowse:nArrayAt, 3 ] ) ), ;
      DiEdita( , 2,, oApp():oDlg ) ), ) }
   oBrowse:bChange    := {|| DI->( dbGoto( aBrowse[ oBrowse:nArrayAt, 3 ] ) ) }
   oBrowse:lHScroll  := .F.
   oDlg:oClient      := oBrowse
   oBrowse:nRowHeight := 20
	
   REDEFINE BUTTON oBtnOk ;
      ID IDOK OF oDlg     ;
      ACTION oDlg:End()
	
   REDEFINE BUTTON oBtnCancel ;
      ID IDCANCEL OF oDlg ;
      ACTION ( DI->( dbGoto( nRecno ) ), oDlg:End() )
	
   ACTIVATE DIALOG oDlg ;
      ON INIT DlgCenter( oDlg, oApp():oWndMain )
	
   RETURN NIL
/*_____________________________________________________________________________*/
FUNCTION DiClave( cDieta, oGet, nMode )

   // nMode    1 nuevo registro
   // 2 modificación de registro
   // 3 duplicación de registro
   // 4 clave ajena
   LOCAL lreturn  := .F.
   LOCAL nRecno   := DI->( RecNo() )
   LOCAL nOrder   := DI->( ordNumber() )
   LOCAL nArea    := Select()

   IF Empty( cDieta )
      IF nMode == 4
         RETURN .T.
      ELSE
         MsgStop( "Es obligatorio rellenar este campo." )
         RETURN .F.
      ENDIF
   ENDIF

   SELECT DI
   DI->( dbSetOrder( 1 ) )
   DI->( dbGoTop() )

   IF DI->( dbSeek( Upper( cDieta ) ) )
      DO CASE
      CASE nMode == 1 .OR. nMode == 3
         lreturn := .F.
         MsgStop( "Dieta existente." )
      CASE nMode == 2
         IF IP->( RecNo() ) == nRecno
            lreturn := .T.
         ELSE
            lreturn := .F.
            MsgStop( "Dieta existente." )
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
         IF MsgYesNo( "Dieta inexistente. ¿ Desea darla de alta ahora? ", 'Seleccione una opción' )
            lreturn := DiEdita( , 1, , , @cDieta )
         ELSE
            lreturn := .F.
         ENDIF
      ENDIF
   ENDIF

   IF lreturn == .F.
      oGet:cText( Space( 20 ) )
   ENDIF

   DI->( dbSetOrder( nOrder ) )
   DI->( dbGoto( nRecno ) )

   SELECT ( nArea )

   RETURN lreturn
/*_____________________________________________________________________________*/

FUNCTION DiEjemplares( oGrid, oParent )

   LOCAL oDlg, oBrowse, oCol
   LOCAL cDieta   := RTrim( DI->DiDieta )
   LOCAL aEpoca   := { '0000', '0001', '0010', '0011', '0100', '0101', '0110', '0111', ;
      '1000', '1001', '1010', '1011', '1100', '1101', '1110', '1111' }
   LOCAL i
   LOCAL cTitle

   oApp():nEdit ++

   DEFINE DIALOG oDlg RESOURCE 'UT_EJEMPLARES'  ;
      TITLE 'Recetas de: ' + DI->DiDieta OF oParent
   oDlg:SetFont( oApp():oFont )

   SELECT RE
   RE->( dbSetOrder( 1 ) )
   RE->( dbSetFilter( {|| At( cDieta, RE->ReDietas ) != 0 } ) )
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

   SELECT DI
   oGrid:Refresh()
   oGrid:SetFocus( .T. )
   oApp():nEdit --

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION DiImprime( oGrid, oParent )

   LOCAL nRecno   := DI->( RecNo() )
   LOCAL nOrder   := DI->( ordSetFocus() )
   LOCAL aCampos  := { "DIDIETA", "DIRECETAS" }
   LOCAL aTitulos := { "Dieta / Tolerancia", "Recetas" }
   LOCAL aWidth   := { 50, 50 }
   LOCAL aShow    := { .T., .T. }
   LOCAL aPicture := { "NO", "@E 99,999" }
   LOCAL aTotal   := { .F., .F. }
   LOCAL nLen     := 2  // nº de campos a mostrar
   LOCAL oInforme

   oApp():nEdit ++

   oInforme := TInforme():New( aCampos, aTitulos, aWidth, aShow, aPicture, aTotal, "DI" )
   oInforme:Dialog()

   REDEFINE RADIO oInforme:oRadio VAR oInforme:nRadio ID 300 OF oInforme:oFld:aDialogs[ 1 ] ;
      ON CHANGE oInforme:Change()

   oInforme:Folders()

   IF oInforme:Activate()
      SELECT DI
      DI->( dbGoTop() )
      oInforme:Report()
      ACTIVATE REPORT oInforme:oReport ;
         ON END ( oInforme:oReport:StartLine(), oInforme:oReport:EndLine(), oInforme:oReport:StartLine(), ;
         oInforme:oReport:Say( 1, 'Total dietas / tolerancias: ' + Tran( oInforme:oReport:nCounter, '@E 999,999' ), 1 ), ;
         oInforme:oReport:EndLine() )
      oInforme:End( .T. )
      DI->( ordSetFocus( nOrder ) )
      DI->( dbGoto( nRecno ) )
   ENDIF

   oApp():nEdit --

   RETURN NIL
/*_____________________________________________________________________________*/
