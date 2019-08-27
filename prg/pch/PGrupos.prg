#include "FiveWin.ch"
#include "Report.ch"
#include "xBrowse.ch"
#include "vmenu.ch"

STATIC oReport

FUNCTION Grupos()

   LOCAL oBar, oCol, oCont
   LOCAL aBrowse
   LOCAL cState := GetPvProfString( "Browse", "GrState", "", oApp():cInifile )
   LOCAL nOrder := Max( Val( GetPvProfString( "Browse", "GrOrder", "1", oApp():cInifile ) ), 1 )
   LOCAL nRecno := Val( GetPvProfString( "Browse", "GrRecno", "1", oApp():cInifile ) )
   LOCAL nSplit := Val( GetPvProfString( "Browse", "GrSplit", "102", oApp():cInifile ) )
   LOCAL i

   IF oApp():oDlg != nil
      IF oApp():nEdit > 0
         // MsgStop('Por favor, finalice la edición del registro actual.')
         RETU NIL
      ELSE
         oApp():oDlg:End()
         SysRefresh()
      ENDIF
   ENDIF

   IF ! Db_OpenAll()
      RETU NIL
   ENDIF

   SELECT GR
   oApp():oDlg := TFsdi():New( oApp():oWndMain )
   oApp():oDlg:cTitle := i18n( 'Gestión de familias de ingredientes' )
   oApp():oWndMain:oClient := oApp():oDlg
   oApp():oDlg:NewGrid( nSplit )

   Ut_BrwRowConfig( oApp():oGrid )
   oApp():oGrid:cAlias := "GR"

   oCol := oApp():oGrid:AddCol()
   oCol:Cargo    := 1
   oCol:AddResource( "16_SORT_A" )
   oCol:nHeadBmpNo    := 1
   oCol:nHeadBmpAlign := AL_RIGHT
   oCol:bStrData :=  {|| GR->GrTipo }
   oCol:cHeader  := "Grupo de ingredientes"
   oCol:nWidth   := 150

   ADD oCol TO oApp():oGrid DATA GR->GrAliment ;
      HEADER "Alimentos" PICTURE "@E 999,999" ;
      TOTAL 0 WIDTH 90

   FOR i := 1 TO Len( oApp():oGrid:aCols )
      oCol := oApp():oGrid:aCols[ i ]
      oCol:bLDClickData  := {|| GrEdita( oApp():oGrid, 2, oCont, oApp():oDlg ) }
   NEXT

   oApp():oGrid:SetRDD()
   oApp():oGrid:CreateFromCode()
   oApp():oGrid:bChange  := {|| RefreshCont( oCont, "GR" ), oApp():oGrid:Maketotals() }
   oApp():oGrid:bKeyDown := {| nKey| GrTecla( nKey, oApp():oGrid, oCont, oApp():oDlg ) }
   oApp():oGrid:nRowHeight  := 21
   oApp():oGrid:RestoreState( cState )
   oApp():oGrid:lFooter := .T.
   oApp():oGrid:bClrFooter := {|| { CLR_HRED, GetSysColor( 15 ) } }
   oApp():oGrid:MakeTotals()

   GR->( dbSetOrder( nOrder ) )
   IF nRecNo < GR->( LastRec() ) .AND. nRecno != 0
      GR->( dbGoto( nRecno ) )
   ELSE
      GR->( dbGoTop() )
   ENDIF

   @ 02, 05 VMENU oCont SIZE nSplit - 10, 18 OF oApp():oDlg  ;
      COLOR CLR_BLACK, GetSysColor( 15 )       ;
      FILLED   ;  // BORDER
   COLORSELECT 0, CLR_WHITE ;
      HEIGHT ITEM 22

   DEFINE TITLE OF oCont ;
      CAPTION tran( GR->( ordKeyNo() ), '@E 999,999' ) + " / " + tran( GR->( ordKeyCount() ), '@E 999,999' ) ;// strZero( RE->( ordKeyCount() ), 6 ) ;
   HEIGHT 25 ;
      COLOR GetSysColor( 9 ), oApp():nClrBar ;
      IMAGE "BB_GRUPOS"

   @ 24, 05 VMENU oBar SIZE nSplit - 10, 180 OF oApp():oDlg  ;
      COLOR CLR_BLACK, GetSysColor( 15 )       ;
      HEIGHT ITEM 22 XBOX
   oBar:nClrBox := Min( GetSysColor( 13 ), GetSysColor( 14 ) )

   DEFINE TITLE OF oBar ;
      CAPTION i18n( "Familias de ingredientes" ) ;
      HEIGHT 24 ;
      COLOR GetSysColor( 9 ), oApp():nClrBar ;
      OPENCLOSE

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Nuevo"              ;
      IMAGE "16_NUEVO"             ;
      ACTION GrEdita( oApp():oGrid, 1, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Modificar"          ;
      IMAGE "16_MODIF"             ;
      ACTION GrEdita( oApp():oGrid, 2, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Duplicar"           ;
      IMAGE "16_DUPLICA"           ;
      ACTION GrEdita( oApp():oGrid, 3, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Borrar"             ;
      IMAGE "16_BORRAR"            ;
      ACTION GrBorra( oApp():oGrid, oCont );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Buscar"             ;
      IMAGE "16_BUSCA"             ;
      ACTION GrBusca( oApp():oGrid,, oCont, oApp():oDlg )  ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Imprimir"           ;
      IMAGE "16_IMPRIMIR"          ;
      ACTION GrImprime( oApp():oGrid, oApp():oDlg )         ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Ver Ingredientes"   ;
      IMAGE "16_ALIMENTO"          ;
      ACTION GrEjemplares( oApp():oGrid, oApp():oDlg ) ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Excel"              ;
      IMAGE "16_EXCEL"             ;
      ACTION ( CursorWait(), Ut_ExportXLS( oApp():oGrid, "Grupos de alimentos" ), CursorArrow() );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Configurar rejilla" ;
      IMAGE "16_GRID"              ;
      ACTION Ut_BrwColConfig( oApp():oGrid, "GrState" ) ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Salir"              ;
      IMAGE "16_SALIR"             ;
      ACTION oApp():oDlg:End()              ;
      LEFT 10

   @ oApp():oDlg:nGridBottom, nSplit + 2 TABS oApp():oTab ;
      OPTION nOrder SIZE oApp():oWndMain:nWidth() -80, 12 PIXEL OF oApp():oDlg ;
      ITEMS ' Grupos '

   oApp():oDlg:NewSplitter( nSplit, oCont, oBar )

   ACTIVATE DIALOG oApp():oDlg NOWAIT ;
      ON INIT ( ResizeWndMain(), oApp():oGrid:SetFocus() ) ;
      VALID ( oApp():oGrid:nLen := 0,;
      WritePProString( "Browse", "GrState", oApp():oGrid:SaveState(), oApp():cInifile ),;
      WritePProString( "Browse", "GrOrder", LTrim( Str( GR->( ordNumber() ) ) ), oApp():cInifile ),;
      WritePProString( "Browse", "GrRecno", LTrim( Str( GR->( RecNo() ) ) ), oApp():cInifile ),;
      WritePProString( "Browse", "GrSplit", LTrim( Str( oApp():oSplit:nleft / 2 ) ), oApp():cInifile ),;
      oBar:End(), dbCloseAll(), oApp():oDlg := NIL, oApp():oGrid := NIL, oApp():oTab := NIL, .T. )

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION GrEdita( oGrid, nMode, oCont, oParent, cGrupo )

   LOCAL oDlg, oFld, oBmp
   LOCAL aTitle := { i18n( "Añadir grupo" ),;
      i18n( "Modificar grupo" ),;
      i18n( "Duplicar grupo" ) }
   LOCAL aGet[ 1 ]
   LOCAL cGrtipo

   LOCAL nRecPtr := GR->( RecNo() )
   LOCAL nOrden  := GR->( ordNumber() )
   LOCAL nRecAdd
   LOCAL lDuplicado
   LOCAL lreturn := .F.

   IF GR->( Eof() ) .AND. nMode != 1
      RETURN NIL
   ENDIF

   oApp():nEdit ++

   IF nMode == 1
      GR->( dbAppend() )
      nRecAdd := GR->( RecNo() )
   ENDIF

   cGrTipo  := iif( nMode == 1 .AND. cGrupo != nil, cGrupo, GR->GrTipo )

   IF nMode == 3
      GR->( dbAppend() )
      nRecAdd := GR->( RecNo() )
   ENDIF

   DEFINE DIALOG oDlg RESOURCE "GR_EDIT_" + oApp():cLanguage OF oParent   ;
      TITLE aTitle[ nMode ]
   oDlg:SetFont( oApp():oFont )

   REDEFINE GET aGet[ 1 ] VAR cGrTipo    ;
      ID 12 OF oDlg UPDATE             ;
      VALID GrClave( cGrTipo, aGet[ 1 ], nMode )

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
      /* ___ actualizo el nombre del proveedor en los ingredientes_____________*/
      IF nMode == 2
         IF RTrim( cGrtipo ) != RTrim( GR->GrTipo )
            SELECT AL
            AL->( dbGoTop() )
            REPLACE AL->AlTipo      ;
               WITH cGrTipo         ;
               FOR Upper( RTrim( AL->AlTipo ) ) == Upper( RTrim( GR->GrTipo ) )
         ENDIF
         SELECT GR
      ENDIF

      /* ___ guardo el registro _______________________________________________*/
      IF nMode == 2
         GR->( dbGoto( nRecPtr ) )
      ELSE
         GR->( dbGoto( nRecAdd ) )
      ENDIF
      REPLACE GR->GrTipo     WITH cGrTipo
      IF cGrupo != nil
         cGrupo := GR->GrTipo
      ENDIF
      GR->( dbCommit() )
   ELSE

      IF nMode == 1 .OR. nMode == 3

         GR->( dbGoto( nRecAdd ) )
         GR->( dbDelete() )
         GR->( DbPack() )
         GR->( dbGoto( nRecPtr ) )

      ENDIF

   ENDIF

   SELECT GR

   IF oCont != nil
      RefreshCont( oCont, "GR" )
   ENDIF
   IF oGrid != nil
      oGrid:Refresh()
      oGrid:SetFocus( .T. )
   ENDIF
   oApp():nEdit --

   RETURN lreturn
/*_____________________________________________________________________________*/

FUNCTION GrBorra( oGrid, oCont )

   LOCAL nRecord := GR->( RecNo() )
   LOCAL nNext

   oApp():nEdit ++

   IF msgYesNo( i18n( "¿ Está seguro de querer borrar este grupo ?" ) + CRLF + ;
         ( Trim( GR->GrTipo ) ), 'Seleccione una opción' )
      // dejo en blanco el grupo en los ingredientes
      SELECT AL
      AL->( dbGoTop() )
      REPLACE AL->AlTipo      ;
         WITH Space( 20 )       ;
         FOR Upper( RTrim( AL->AlTipo ) ) == Upper( RTrim( GR->GrTipo ) )

      // borro el grupo
      GR->( dbSkip() )
      nNext := GR->( RecNo() )
      GR->( dbGoto( nRecord ) )

      GR->( dbDelete() )
      GR->( DbPack() )
      GR->( dbGoto( nNext ) )
      IF GR->( Eof() ) .OR. nNext == nRecord
         GR->( dbGoBottom() )
      ENDIF
   ENDIF

   IF oCont != nil
      RefreshCont( oCont, "GR" )
   ENDIF

   oGrid:Refresh( .T. )
   oGrid:SetFocus( .T. )
   oApp():nEdit --

   RETURN NIL
/*_____________________________________________________________________________*/
FUNCTION GrTecla( nKey, oGrid, oCont, oDlg )

   DO CASE
   CASE nKey == VK_RETURN
      GrEdita( oGrid, 2, oCont, oDlg )
   CASE nKey == VK_INSERT
      GrEdita( oGrid, 1, oCont, oDlg )
   CASE nKey == VK_DELETE
      GrBorra( oGrid, oCont )
   CASE nKey == VK_ESCAPE
      oDlg:End()
   OTHERWISE
      IF nKey >= 96 .AND. nKey <= 105
         GrBusca( oGrid, Str( nKey - 96, 1 ), oCont, oDlg )
      ELSEIF HB_ISSTRING( Chr( nKey ) )
         GrBusca( oGrid, Chr( nKey ), oCont, oDlg )
      ENDIF
   ENDCASE

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION GrSeleccion( cGrupo, oControl, oParent, oVItem )

   LOCAL oDlg, oBrowse, oCol, oBtnAceptar, oBtnCancel, oBNew, oBMod, oBDel
   LOCAL lOk    := .F.
   LOCAL nRecno := GR->( RecNo() )
   LOCAL nOrder := GR->( ordNumber() )
   LOCAL nArea  := Select()
   LOCAL aPoint := iif( oControl != NIL, AdjustWnd( oControl, 271 * 2, 150 * 2 ), { 1.3 * oVItem:nTop(), oApp():oGrid:nLeft } )

   DEFINE DIALOG oDlg RESOURCE 'UT_AJENA1_' + oApp():cLanguage OF oParent;
      TITLE i18n( "Selección de familias de ingredientes" )
   oDlg:SetFont( oApp():oFont )

   // siempre tengo ordenado por nombre

   SELECT GR
   GR->( dbSetOrder( 1 ) )
   GR->( dbGoTop() )

   IF ! GR->( dbSeek( cGrupo ) )
      GR->( dbGoTop() )
   ENDIF

   oBrowse := TXBrowse():New( oDlg )
   Ut_BrwRowConfig( oBrowse )
   oBrowse:cAlias := "GR"

   oCol := oBrowse:AddCol()
   oCol:bStrData := {|| GR->GrTipo }
   oCol:cHeader  := "Familia de ingredientes"
   oCol:nWidth   := 160
   oCol:bLDClickData  := {|| ( lOk := .T., oDlg:End() )   }
   oBrowse:SetRDD()
   oBrowse:CreateFromResource( 110 )
   oBrowse:bKeyDown := {| nKey| GrSeTecla( nKey, oBrowse, oDlg, oBtnAceptar ) }

   REDEFINE BUTTON oBNew   ;
      ID 410 OF oDlg       ;
      ACTION GrEdita( oBrowse, 1,, oDlg )

   REDEFINE BUTTON oBMod   ;
      ID 411 OF oDlg       ;
      ACTION GrEdita( oBrowse, 2,, oDlg )

   REDEFINE BUTTON oBDel   ;
      ID 412 OF oDlg       ;
      ACTION GrBorra( oBrowse, )

   REDEFINE BUTTON oBtnAceptar   ;
      ID IDOK OF oDlg            ;
      ACTION ( lOk := .T., oDlg:End() )

   REDEFINE BUTTON oBtnCancel    ;
      ID IDCANCEL OF oDlg        ;
      ACTION ( lOk := .F., oDlg:End() )

   ACTIVATE DIALOG oDlg CENTERED       ;
      ON PAINT oDlg:Move( aPoint[ 1 ], aPoint[ 2 ],,, .T. )

   IF lOK
      cGrupo := GR->GrTipo
      IF oControl != NIL
         oControl:cText := GR->GrTipo
      ENDIF
   ENDIF

   GR->( dbSetOrder( nOrder ) )
   GR->( dbGoto( nRecno ) )

   SELECT ( nArea )

   RETURN NIL
/*_____________________________________________________________________________*/
FUNCTION GrSeTecla( nKey, oGrid, oDlg, oBtn )

   DO CASE
   CASE nKey == VK_RETURN
      oBtn:Click()
   CASE nKey == VK_ESCAPE
      oDlg:End()
   OTHERWISE
      IF nKey >= 96 .AND. nKey <= 105
         GrBusca( oGrid, Str( nKey - 96, 1 ),, oDlg )
      ELSEIF HB_ISSTRING( Chr( nKey ) )
         GrBusca( oGrid, Chr( nKey ),, oDlg )
      ENDIF
   ENDCASE

   RETURN NIL
/*_____________________________________________________________________________*/
FUNCTION GrBusca( oGrid, cChr, oCont, oParent )

   LOCAL nOrder   := GR->( ordNumber() )
   LOCAL nRecno   := GR->( RecNo() )
   LOCAL oDlg, oGet, cGet, cPicture
   LOCAL aSay1    := { "Introduzca el nombre del grupo"     }
   LOCAL aSay2    := { "Ingrediente:"  }
   LOCAL aGet     := { Space( 25 ) }
   LOCAL lSeek    := .F.
   LOCAL lFecha   := .F.
   LOCAL aBrowse  := {}

   oApp():nEdit ++

   DEFINE DIALOG oDlg RESOURCE 'UT_BUSCA_' + oApp():cLanguage OF oParent  ;
      TITLE i18n( "Búsqueda de ingredientes" )
   oDlg:SetFont( oApp():oFont )

   REDEFINE SAY PROMPT aSay1[ nOrder ] ID 20 OF oDlg
   REDEFINE SAY PROMPT aSay2[ nOrder ] ID 21 OF Odlg

   cGet  := aGet[ nOrder ]

   IF cChr != nil
      IF ! lFecha
         cGet := cChr + SubStr( cGet, 1, Len( cGet ) -1 )
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
         {|| GrWildSeek( nOrder, cGet, aBrowse ) } )
      IF Len( aBrowse ) == 0
         MsgStop( "No se ha encontrado ningun grupo." )
      ELSE
         GrEncontrados( aBrowse, oApp():oDlg )
      ENDIF
   ENDIF
   IF oCont != NIL
      RefreshCont( oCont, "GR" )
   ENDIF
	
   oApp():nEdit --
   oGrid:Refresh()
   oGrid:SetFocus( .T. )

   RETURN NIL
/*_____________________________________________________________________________*/
FUNCTION GrWildSeek( nOrder, cGet, aBrowse )

   LOCAL nRecno   := DI->( RecNo() )
	
   GR->( dbGoTop() )
   DO WHILE ! GR->( Eof() )
      IF cGet $ Upper( GR->GrTipo )
         AAdd( aBrowse, { GR->GrTipo, GR->GrAliment, GR->( RecNo() ) } )
      ENDIF
      GR->( dbSkip() )
   ENDDO
   GR->( dbGoto( nRecno ) )
   // ordeno la tabla por el 1 elemento
   ASort( aBrowse,,, {|aAut1, aAut2| Upper( aAut1[ 1 ] ) < Upper( aAut2[ 1 ] ) } )

   RETURN NIL
/*_____________________________________________________________________________*/
	
FUNCTION GrEncontrados( aBrowse, oParent )

   LOCAL oDlg, oBrowse, oBtnOk, oBtnCancel, lOk
   LOCAL nRecno := GR->( RecNo() )
	
   DEFINE DIALOG oDlg RESOURCE "DLG_ENCONTRADOS" ;
      TITLE i18n( "Resultado de la búsqueda" ) ;
      OF oParent
   oDlg:SetFont( oApp():oFont )
	
   oBrowse := TXBrowse():New( oDlg )
   Ut_BrwRowConfig( oBrowse )

   oBrowse:SetArray( aBrowse, .F. )
   oBrowse:aCols[ 1 ]:cHeader := "Familias"
   oBrowse:aCols[ 2 ]:cHeader := "Ingredientes"
   oBrowse:aCols[ 1 ]:nWidth  := 340
   oBrowse:aCols[ 2 ]:nWidth  := 100
   oBrowse:aCols[ 3 ]:Hide()
   oBrowse:aCols[ 1 ]:nHeadStrAlign := 0
   oBrowse:aCols[ 1 ]:nDataStrAlign := 0
   oBrowse:aCols[ 2 ]:nHeadStrAlign := 0
   oBrowse:aCols[ 2 ]:nDataStrAlign := 0
	
   oBrowse:CreateFromResource( 110 )
	
   GR->( dbGoto( aBrowse[ oBrowse:nArrayAt, 3 ] ) )
   AEval( oBrowse:aCols, {|oCol| oCol:bLDClickData := {|| GR->( dbGoto( aBrowse[ oBrowse:nArrayAt, 3 ] ) ), ;
      GrEdita( , 2,, oApp():oDlg ) } } )
   oBrowse:bKeyDown  := {| nKey| iif( nKey == VK_RETURN, ( GR->( dbGoto( aBrowse[ oBrowse:nArrayAt, 3 ] ) ), ;
      GrEdita( , 2,, oApp():oDlg ) ), ) }
   oBrowse:bChange   := {|| GR->( dbGoto( aBrowse[ oBrowse:nArrayAt, 3 ] ) ) }
   oBrowse:lHScroll  := .F.
   oDlg:oClient      := oBrowse
   oBrowse:nRowHeight := 20
	
   REDEFINE BUTTON oBtnOk ;
      ID IDOK OF oDlg     ;
      ACTION oDlg:End()
	
   REDEFINE BUTTON oBtnCancel ;
      ID IDCANCEL OF oDlg ;
      ACTION ( GR->( dbGoto( nRecno ) ), oDlg:End() )
	
   ACTIVATE DIALOG oDlg ;
      ON INIT DlgCenter( oDlg, oApp():oWndMain )
	
   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION GrClave( cGrupo, oGet, nMode )

   // nMode    1 nuevo registro
   // 2 modificación de registro
   // 3 duplicación de registro
   // 4 clave ajena
   LOCAL lreturn  := .F.
   LOCAL nRecno   := GR->( RecNo() )
   LOCAL nOrder   := GR->( ordNumber() )
   LOCAL nArea    := Select()

   IF Empty( cGrupo )
      IF nMode == 4
         RETURN .T.
      ELSE
         MsgStop( "Es obligatorio rellenar este campo." )
         RETURN .F.
      ENDIF
   ENDIF

   SELECT GR
   GR->( dbSetOrder( 1 ) )
   GR->( dbGoTop() )

   IF GR->( dbSeek( Upper( cGrupo ) ) )
      DO CASE
      CASE nMode == 1 .OR. nMode == 3
         lreturn := .F.
         MsgStop( "Grupo de ingredientes existente." )
      CASE nMode == 2
         IF GR->( RecNo() ) == nRecno
            lreturn := .T.
         ELSE
            lreturn := .F.
            MsgStop( "Grupo de ingredientes existente." )
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
         IF MsgYesNo( "Grupo de ingredientes inexistente. ¿ Desea darlo de alta ahora? ", 'Seleccione una opción' )
            lreturn := GrEdita( , 1, , , @cGrupo )
         ELSE
            lreturn := .F.
         ENDIF
      ENDIF
   ENDIF

   IF lreturn == .F.
      oGet:cText( Space( 20 ) )
   ENDIF

   GR->( dbSetOrder( nOrder ) )
   GR->( dbGoto( nRecno ) )

   SELECT ( nArea )

   RETURN lreturn
/*_____________________________________________________________________________*/

FUNCTION GrImprime( oGrid, oParent )

   LOCAL nRecno   := GR->( RecNo() )
   LOCAL nOrder   := GR->( ordSetFocus() )
   LOCAL aCampos  := { "GRTIPO" }
   LOCAL aTitulos := { "Familia" }
   LOCAL aWidth   := { 50 }
   LOCAL aShow    := { .T. }
   LOCAL aPicture := { "NO" }
   LOCAL aTotal   := { .F. }
   LOCAL nLen     := 1  // nº de campos a mostrar
   LOCAL oInforme

   oApp():nEdit ++

   oInforme := TInforme():New( aCampos, aTitulos, aWidth, aShow, aPicture, aTotal, "GR" )
   oInforme:Dialog()

   REDEFINE RADIO oInforme:oRadio VAR oInforme:nRadio ID 300 OF oInforme:oFld:aDialogs[ 1 ] ;
      ON CHANGE oInforme:Change()

   oInforme:Folders()

   IF oInforme:Activate()
      SELECT GR
      GR->( dbGoTop() )
      oInforme:Report()
      ACTIVATE REPORT oInforme:oReport ;
         ON END ( oInforme:oReport:StartLine(), oInforme:oReport:EndLine(), oInforme:oReport:StartLine(), ;
         oInforme:oReport:Say( 1, 'Total familias: ' + Tran( oInforme:oReport:nCounter, '@E 999,999' ), 1 ), ;
         oInforme:oReport:EndLine() )
      oInforme:End( .T. )
      GR->( ordSetFocus( nOrder ) )
      GR->( dbGoto( nRecno ) )
   ENDIF

   oApp():nEdit --

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION GrEjemplares( oGrid, oParent )

   LOCAL oDlg, oBrowse, oCol
   LOCAL cFamilia := GR->GrTipo
   LOCAL i
   LOCAL cTitle := 'Ingredientes de la familia: ' + cFamilia

   oApp():nEdit ++
   AL->( dbSetOrder( 2 ) )
   AL->( dbSetFilter( {|| Upper( RTrim( AL->AlTipo ) ) == Upper( RTrim( cFamilia ) ) } ) )
   AL->( dbGoTop() )

   DEFINE DIALOG oDlg RESOURCE 'UT_EJEMPLARES'  ;
      TITLE cTitle OF oParent
   oDlg:SetFont( oApp():oFont )

   oBrowse := TXBrowse():New( oDlg )
   Ut_BrwRowConfig( oBrowse )
   oBrowse:cAlias := "AL"

   oCol := oBrowse:AddCol()
   oCol:bStrData := {|| AL->AlAlimento }
   oCol:cHeader  := "Ingrediente"
   oCol:nWidth   := 200

   oCol := oBrowse:AddCol()
   oCol:bStrData := {|| AL->AlCodigo }
   oCol:cHeader  := "Código"
   oCol:nWidth   := 70

   oCol := oBrowse:AddCol()
   oCol:bStrData := {|| AL->AlUnidad }
   oCol:cHeader  := "Unidad"
   oCol:nWidth   := 70

   oCol := oBrowse:AddCol()
   oCol:bStrData := {|| TRAN( AL->AlPrecio, "@E 999,999.99" ) }
   oCol:cHeader  := "Precio"
   oCol:nWidth   := 70
   oCol:nDataStrAlign := 1
   oCol:nHeadStrAlign := 1

   oCol := oBrowse:AddCol()
   oCol:bStrData := {|| DToC( AL->AlUltCom )  }
   oCol:cHeader  := "Ult. compra"
   oCol:nWidth   := 70

   FOR i := 1 TO Len( oBrowse:aCols )
      oCol := oBrowse:aCols[ i ]
      oCol:bLDClickData  := {|| AlEdita( oBrowse, 2,, oDlg ) }
      oCol:bClrSelFocus  := {|| { CLR_BLACK, oApp():nClrHL } }
   NEXT

   oBrowse:SetRDD()
   oBrowse:CreateFromResource( 110 )

   REDEFINE SAY ID 4001 PROMPT "* haga doble click para editar el ingrediente seleccionado." OF oDlg

   REDEFINE BUTTON ID IDOK OF oDlg ;
      PROMPT i18n( "&Aceptar" )   ;
      ACTION oDlg:End()

   ACTIVATE DIALOG oDlg ;
      ON INIT DlgCenter( oDlg, oApp():oWndMain )

   AL->( dbClearFilter() )

   SELECT GR
   oGrid:Refresh()
   oGrid:SetFocus( .T. )
   oApp():nEdit --

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION GrList( aList, cData, oSelf )

   LOCAL aNewList := {}

   GR->( dbSetOrder( 1 ) )
   GR->( dbGoTop() )
   WHILE ! GR->( Eof() )
      IF At( Upper( cdata ), Upper( GR->GrTipo ) ) != 0 // UPPER( SubStr( oApp():amaterias[i,1], 1, Len( cData ) ) ) == UPPER( cData )
         AAdd( aNewList, { GR->Grtipo } )
      ENDIF
      GR->( dbSkip() )
   ENDDO

   RETURN aNewlist
