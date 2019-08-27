#include "FiveWin.ch"
#include "Report.ch"
#include "xBrowse.ch"
#include "vmenu.ch"

STATIC oReport

FUNCTION Acciones()

   LOCAL oBar, oCol, oCont
   LOCAL aBrowse
   LOCAL cState := GetPvProfString( "Browse", "AcState", "", oApp():cInifile )
   LOCAL nOrder := Max( Val( GetPvProfString( "Browse", "AcOrder", "1", oApp():cInifile ) ), 1 )
   LOCAL nRecno := Val( GetPvProfString( "Browse", "AcRecno", "1", oApp():cInifile ) )
   LOCAL nSplit := Val( GetPvProfString( "Browse", "AcSplit", "102", oApp():cInifile ) )
   LOCAL i

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

   SELECT AC
   oApp():oDlg := TFsdi():New( oApp():oWndMain )
   oApp():oDlg:cTitle := i18n( 'Gestión de acciones' )
   oApp():oWndMain:oClient := oApp():oDlg
   oApp():oDlg:NewGrid( nSplit )

   Ut_BrwRowConfig( oApp():oGrid )
   oApp():oGrid:cAlias := "AC"

   aBrowse   := { { {|| AC->AcAccion }, i18n( "Acción" ), 150 },;
      { {|| TRAN( AC->AcAliment, "@E99,999" ) }, i18n( "Alimentos" ), 90 } }

   FOR i := 1 TO Len( aBrowse )
      oCol := oApp():oGrid:AddCol()
      oCol:bStrData := aBrowse[ i, 1 ]
      oCol:cHeader  := aBrowse[ i, 2 ]
      oCol:nWidth   := aBrowse[ i, 3 ]
   NEXT

   FOR i := 1 TO Len( oApp():oGrid:aCols )
      oCol := oApp():oGrid:aCols[ i ]
      oCol:bLDClickData  := {|| AcEdita( oApp():oGrid, 2, oCont, oApp():oDlg ) }
   NEXT

   oApp():oGrid:SetRDD()
   oApp():oGrid:CreateFromCode()
   oApp():oGrid:bChange  := {|| RefreshCont( oCont, "AC" ) }
   oApp():oGrid:bKeyDown := {| nKey| AcTecla( nKey, oApp():oGrid, oCont, oApp():oDlg ) }
   oApp():oGrid:nRowHeight  := 21

   oApp():oGrid:RestoreState( cState )

   AC->( dbSetOrder( nOrder ) )
   IF nRecNo < AC->( LastRec() ) .AND. nRecno != 0
      AC->( dbGoto( nRecno ) )
   ELSE
      AC->( dbGoTop() )
   ENDIF

   @ 02, 05 VMENU oCont SIZE nSplit - 10, 18 OF oApp():oDlg  ;
      COLOR CLR_BLACK, GetSysColor( 15 )       ;
      FILLED   ;  // BORDER
   COLORSELECT 0, CLR_WHITE ;
      HEIGHT ITEM 22

   DEFINE TITLE OF oCont ;
      CAPTION tran( AC->( ordKeyNo() ), '@E 999,999' ) + " / " + tran( AC->( ordKeyCount() ), '@E 999,999' ) ;
      HEIGHT 25 ;
      COLOR GetSysColor( 9 ), oApp():nClrBar ;
      IMAGE "BB_ACCION" ;
      RADIOBTN 15

   @ 24, 05 VMENU oBar SIZE nSplit - 10, 160 OF oApp():oDlg  ;
      COLOR CLR_BLACK, GetSysColor( 15 )       ;
      HEIGHT ITEM 22 XBOX

   DEFINE TITLE OF oBar ;
      CAPTION i18n( "Acciones con ingredientes" ) ;
      HEIGHT 24 ;
      COLOR GetSysColor( 9 ), oApp():nClrBar ;
   IMGBTN "TB_UP", "TB_DOWN" ;
      OPENCLOSE

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Nuevo"              ;
      IMAGE "16_NUEVO"             ;
      ACTION AcEdita( oApp():oGrid, 1, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Modificar"          ;
      IMAGE "16_MODIF"             ;
      ACTION AcEdita( oApp():oGrid, 2, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Duplicar"           ;
      IMAGE "16_DUPLICA"           ;
      ACTION AcEdita( oApp():oGrid, 3, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Borrar"             ;
      IMAGE "16_BORRAR"            ;
      ACTION AcBorra( oApp():oGrid, oCont );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Buscar"             ;
      IMAGE "16_BUSCA"             ;
      ACTION AcBusca( oApp():oGrid,, oCont, oApp():oDlg )  ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Imprimir"           ;
      IMAGE "16_IMPRIMIR"          ;
      ACTION AcImprime( oApp():oGrid, oApp():oDlg )         ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Ver ingredientes"   ;
      IMAGE "16_ALIMENTO"        ;
      ACTION AcEjemplares( oApp():oGrid, oApp():oDlg ) ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Excel"              ;
      IMAGE "16_EXCEL"             ;
      ACTION ( CursorWait(), Ut_ExportXLS( oApp():oGrid, "Acción" ), CursorArrow() );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Configurar rejilla" ;
      IMAGE "16_GRID"              ;
      ACTION Ut_BrwColConfig( oApp():oGrid, "AcState" ) ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Salir"              ;
      IMAGE "16_SALIR"             ;
      ACTION oApp():oDlg:End()              ;
      LEFT 10

   @ oApp():oDlg:nGridBottom, nSplit + 2 TABS oApp():oTab ;
      OPTION nOrder SIZE oApp():oWndMain:nWidth() -80, 12 PIXEL OF oApp():oDlg ;
      ITEMS ' Acciones '

   oApp():oDlg:NewSplitter( nSplit, oCont, oBar )

   ACTIVATE DIALOG oApp():oDlg NOWAIT ;
      ON INIT ( ResizeWndMain(), oApp():oGrid:SetFocus() ) ;
      VALID ( oApp():oGrid:nLen := 0,;
      WritePProString( "Browse", "AcState", oApp():oGrid:SaveState(), oApp():cInifile ),;
      WritePProString( "Browse", "AcOrder", LTrim( Str( AC->( ordNumber() ) ) ), oApp():cInifile ),;
      WritePProString( "Browse", "AcRecno", LTrim( Str( AC->( RecNo() ) ) ), oApp():cInifile ),;
      WritePProString( "Browse", "AcSplit", LTrim( Str( oApp():oSplit:nleft / 2 ) ), oApp():cInifile ),;
      oBar:End(), dbCloseAll(), oApp():oDlg := NIL, oApp():oGrid := NIL, oApp():oTab := NIL, .T. )

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION AcEdita( oGrid, nMode, oCont, oParent, cAccion )

   LOCAL oDlg, oFld, oBmp
   LOCAL aTitle := { i18n( "Añadir acción" ),;
      i18n( "Modificar acción" ),;
      i18n( "Duplicar acción" ) }
   LOCAL aGet[ 1 ]
   LOCAL cAcAccion

   LOCAL nRecPtr := AC->( RecNo() )
   LOCAL nOrden  := AC->( ordNumber() )
   LOCAL nRecAdd
   LOCAL lDuplicado
   LOCAL lreturn := .F.

   IF AC->( Eof() ) .AND. nMode != 1
      RETU NIL
   ENDIF

   oApp():nEdit ++

   IF nMode == 1
      AC->( dbAppend() )
      nRecAdd := AC->( RecNo() )
   ENDIF

   cAcAccion := iif( nMode == 1 .AND. cAccion != nil, cAccion, AC->AcAccion )

   IF nMode == 3
      AC->( dbAppend() )
      nRecAdd := UB->( RecNo() )
   ENDIF

   DEFINE DIALOG oDlg RESOURCE "AC_EDIT_" + oApp():cLanguage OF oParent   ;
      TITLE aTitle[ nMode ]
   oDlg:SetFont( oApp():oFont )

   REDEFINE GET aGet[ 1 ] VAR cAcAccion ;
      ID 12 OF oDlg UPDATE             ;
      VALID AcClave( cAcAccion, aGet[ 1 ], nMode )

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
      /* ___ actualizo la dieta en la receta____________
      if nMode == 2
   if Rtrim(cUbUbicaci) != rtrim(UB->UbUbicaci)
            Select AL
            AL->(DbGoTop())
            Replace AL->AlUbicaci   ;
               with cUbUbicaci      ;
               for Upper(Rtrim(AL->AlUbicaci)) == Upper(rtrim(UB->UbUbicaci))
         endif
         SELECT UB
      endif

      /* ___ guardo el registro _______________________________________________*/
      IF nMode == 2
         AC->( dbGoto( nRecPtr ) )
      ELSE
         AC->( dbGoto( nRecAdd ) )
      ENDIF
      REPLACE AC->AcAccion WITH cAcAccion
      AC->( dbCommit() )
   ELSE
      IF nMode == 1 .OR. nMode == 3
         AC->( dbGoto( nRecAdd ) )
         AC->( dbDelete() )
         AC->( DbPack() )
         AC->( dbGoto( nRecPtr ) )
      ENDIF
   ENDIF

   SELECT AC
   IF oCont != nil
      RefreshCont( oCont, "AC" )
   ENDIF
   IF oGrid != nil
      oGrid:Refresh()
      oGrid:SetFocus( .T. )
   ENDIF
   oApp():nEdit --

   RETURN lreturn
/*_____________________________________________________________________________*/

FUNCTION AcBorra( oGrid, oCont )

   LOCAL nRecord := AC->( RecNo() )
   LOCAL cAccion := RTrim( AC->AcAccion )
   LOCAL nNext

   oApp():nEdit ++

   IF msgYesNo( i18n( "¿ Está seguro de querer borrar esta acción ?" ) + CRLF + cAccion, 'Seleccione una opción' )
      // quito la dieta de las recetas en que aparezca
      SELECT AL
      AL->( dbGoTop() )
      REPLACE AL->AlAccion WITH "";
         FOR RTrim( AL->AlAccion ) == cAccion
      // borro la accion
      AC->( dbSkip() )
      nNext := AC->( RecNo() )
      AC->( dbGoto( nRecord ) )

      AC->( dbDelete() )
      AC->( DbPack() )
      AC->( dbGoto( nNext ) )
      IF AC->( Eof() ) .OR. nNext == nRecord
         AC->( dbGoBottom() )
      ENDIF
   ENDIF

   IF oCont != nil
      RefreshCont( oCont, "AC" )
   ENDIF

   oGrid:Refresh( .T. )
   oGrid:SetFocus( .T. )
   oApp():nEdit --

   RETURN NIL
/*_____________________________________________________________________________*/
FUNCTION AcTecla( nKey, oGrid, oCont, oDlg )

   DO CASE
   CASE nKey == VK_RETURN
      AcEdita( oGrid, 2, oCont, oDlg )
   CASE nKey == VK_INSERT
      AcEdita( oGrid, 1, oCont, oDlg )
   CASE nKey == VK_DELETE
      AcBorra( oGrid, oCont )
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

FUNCTION AcSeleccion( cUbicaci, oControl, oParent )

   LOCAL oDlg, oBrowse, oCol, oBtnAceptar, oBtnCancel, oBNew, oBMod, oBDel
   LOCAL lOk    := .F.
   LOCAL nRecno := AC->( RecNo() )
   LOCAL nOrder := AC->( ordNumber() )
   LOCAL nArea  := Select()
   LOCAL aPoint := AdjustWnd( oControl, 271 * 2, 150 * 2 )

   DEFINE DIALOG oDlg RESOURCE 'UT_AJENA1_' + oApp():cLanguage OF oParent;
      TITLE i18n( "Selección de acciones" )
   oDlg:SetFont( oApp():oFont )

   // siempre tengo ordenado por nombre

   SELECT AC
   AC->( dbSetOrder( 1 ) )
   AC->( dbGoTop() )

   oBrowse := TXBrowse():New( oDlg )
   Ut_BrwRowConfig( oBrowse )
   oBrowse:cAlias := "AC"

   oCol := oBrowse:AddCol()
   oCol:bStrData := {|| AC->AcAccion }
   oCol:cHeader  := "Acción"
   oCol:nWidth   := 160
   oCol:bLDClickData  := {|| ( lOk := .T., oDlg:End() )   }
   oBrowse:SetRDD()
   oBrowse:CreateFromResource( 110 )
   // oBrowse:bKeyDown := {|nKey| UbSeTecla(nKey,oBrowse,oDlg,oBtnAceptar) }

   REDEFINE BUTTON oBNew   ;
      ID 410 OF oDlg       ;
      ACTION AcEdita( oBrowse, 1,, oDlg )

   REDEFINE BUTTON oBMod   ;
      ID 411 OF oDlg       ;
      ACTION AcEdita( oBrowse, 2,, oDlg )

   REDEFINE BUTTON oBDel   ;
      ID 412 OF oDlg       ;
      ACTION AcBorra( oBrowse, )

   REDEFINE BUTTON oBtnAceptar   ;
      ID IDOK OF oDlg            ;
      ACTION ( lOk := .T., oDlg:End() )

   REDEFINE BUTTON oBtnCancel    ;
      ID IDCANCEL OF oDlg        ;
      ACTION ( lOk := .F., oDlg:End() )

   ACTIVATE DIALOG oDlg CENTERED       ;
      ON PAINT oDlg:Move( aPoint[ 1 ], aPoint[ 2 ],,, .T. )

   IF lOK
      oControl:cText := AC->AcAccion
   ENDIF

   AC->( dbSetOrder( nOrder ) )
   AC->( dbGoto( nRecno ) )

   SELECT ( nArea )

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION AcBusca( oGrid, cChr, oCont, oParent )

   LOCAL nOrder   := AC->( ordNumber() )
   LOCAL nRecno   := AC->( RecNo() )
   LOCAL oDlg, oGet, cGet, cPicture
   LOCAL aSay1    := { "Introduzca el nombre de la acción" }
   LOCAL aSay2    := { "Acción:" }
   LOCAL aGet     := { Space( 8 ) }
   LOCAL lSeek    := .F.
   LOCAL lFecha   := .F.

   oApp():nEdit ++

   DEFINE DIALOG oDlg RESOURCE 'UT_BUSCA_' + oApp():cLanguage OF oParent  ;
      TITLE i18n( "Búsqueda de acciones" )
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
      ON INIT ( DlgCenter( oDlg, oApp():oWndMain ) )// , Iif(cChr!=nil,oGet:SetPos(2),), oGet:Refresh() )

   IF lSeek
      IF ! lFecha
         cGet := RTrim( Upper( cGet ) )
      ELSE
         cGet := DToS( cGet )
      ENDIF
      IF ! AC->( dbSeek( cGet, .T. ) )
         msgAlert( i18n( "No encuentro esa ubicación." ) )
         AC->( dbGoto( nRecno ) )
      ENDIF
   ENDIF
   IF oCont != NIL
      RefreshCont( oCont, "AC" )
   ENDIF
   oGrid:Refresh()
   oGrid:SetFocus( .T. )
   oApp():nEdit --

   RETURN NIL

/*_____________________________________________________________________________*/

FUNCTION AcClave( cAccion, oGet, nMode )

   // nMode    1 nuevo registro
   // 2 modificación de registro
   // 3 duplicación de registro
   // 4 clave ajena
   LOCAL lreturn  := .F.
   LOCAL nRecno   := AC->( RecNo() )
   LOCAL nOrder   := AC->( ordNumber() )
   LOCAL nArea    := Select()

   IF Empty( cAccion )
      IF nMode == 4
         RETURN .T.
      ELSE
         MsgStop( "Es obligatorio rellenar este campo." )
         RETURN .F.
      ENDIF
   ENDIF

   SELECT AC
   AC->( dbSetOrder( 1 ) )
   AC->( dbGoTop() )

   IF AC->( dbSeek( Upper( cAccion ) ) )
      DO CASE
      CASE nMode == 1 .OR. nMode == 3
         lreturn := .F.
         MsgStop( "Acción existente." )
      CASE nMode == 2
         IF AC->( RecNo() ) == nRecno
            lreturn := .T.
         ELSE
            lreturn := .F.
            MsgStop( "Acción existente." )
         ENDIF
      CASE nMode == 4
         IF ! oApp():thefull
            Registrame()
         ENDIF
         lreturn := .T.
      END CASE
   ELSE
      IF nMode < 4
         lreturn := .T.
      ELSE
         IF MsgYesNo( "Acción inexistente. ¿ Desea darla de alta ahora? ", 'Seleccione una opción' )
            lreturn := AcEdita( , 1, , , @cAccion )
         ELSE
            lreturn := .F.
         ENDIF
      ENDIF
   ENDIF

   IF lreturn == .F.
      oGet:cText( Space( 8 ) )
   ENDIF

   AC->( dbSetOrder( nOrder ) )
   AC->( dbGoto( nRecno ) )

   SELECT ( nArea )

   RETURN lreturn
/*_____________________________________________________________________________*/

FUNCTION AcEjemplares( oGrid, oParent )

   LOCAL oDlg, oBrowse, oCol
   LOCAL cAccion := RTrim( AC->AcAccion )
   LOCAL aBrowse  := {}
   LOCAL i
   LOCAL cTitle

   oApp():nEdit ++

   DEFINE DIALOG oDlg RESOURCE 'UT_EJEMPLARES'  ;
      TITLE 'Alimentos de: ' + AC->AcAccion OF oParent
   oDlg:SetFont( oApp():oFont )

   SELECT AL
   AL->( dbSetOrder( 1 ) )
   AL->( dbSetFilter( {|| RTrim( AL->AlAccion ) == cAccion } ) )
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

   SELECT AC
   oGrid:Refresh()
   oGrid:SetFocus( .T. )
   oApp():nEdit --

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION AcImprime( oGrid, oParent )

   LOCAL nRecno   := AC->( RecNo() )
   LOCAL nOrder   := AC->( ordSetFocus() )
   LOCAL aCampos  := { "AcAccion", "AcAliment" }
   LOCAL aTitulos := { "Acción", "Alimentos" }
   LOCAL aWidth   := { 50, 50 }
   LOCAL aShow    := { .T., .T. }
   LOCAL aPicture := { "NO", "@E 99,999" }
   LOCAL aTotal   := { .F., .F. }
   LOCAL nLen     := 2  // nº de campos a mostrar
   LOCAL oInforme

   oApp():nEdit ++

   oInforme := TInforme():New( aCampos, aTitulos, aWidth, aShow, aPicture, aTotal, "AC" )
   oInforme:Dialog()

   REDEFINE RADIO oInforme:oRadio VAR oInforme:nRadio ID 300 OF oInforme:oFld:aDialogs[ 1 ] ;
      ON CHANGE oInforme:Change()

   oInforme:Folders()

   IF oInforme:Activate()
      SELECT AC
      AC->( dbGoTop() )
      oInforme:Report()
      ACTIVATE REPORT oInforme:oReport ;
         ON END ( oInforme:oReport:StartLine(), oInforme:oReport:EndLine(), oInforme:oReport:StartLine(), ;
         oInforme:oReport:Say( 1, 'Total acciones: ' + Tran( oInforme:oReport:nCounter, '@E 999,999' ), 1 ), ;
         oInforme:oReport:EndLine() )
      oInforme:End( .T. )
      AC->( ordSetFocus( nOrder ) )
      AC->( dbGoto( nRecno ) )
   ENDIF

   oApp():nEdit --

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION AcList( aList, cData, oSelf )

   LOCAL aNewList := {}

   AC->( dbSetOrder( 1 ) )
   AC->( dbGoTop() )
   WHILE ! AC->( Eof() )
      IF At( Upper( cdata ), Upper( AC->AcAccion ) ) != 0 // UPPER( SubStr( oApp():amaterias[i,1], 1, Len( cData ) ) ) == UPPER( cData )
         AAdd( aNewList, { AC->AcAccion } )
      ENDIF
      AC->( dbSkip() )
   ENDDO

   RETURN aNewlist
