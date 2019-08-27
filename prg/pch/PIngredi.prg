#include "FiveWin.ch"
#include "Report.ch"
#include "xBrowse.ch"
#include "vmenu.ch"

STATIC oReport

FUNCTION IngredPrin()

   LOCAL oBar, oCol, oCont
   LOCAL aBrowse
   LOCAL cState := GetPvProfString( "Browse", "IpState", "", oApp():cInifile )
   LOCAL nOrder := Max( Val( GetPvProfString( "Browse", "IpOrder", "1", oApp():cInifile ) ), 1 )
   LOCAL nRecno := Val( GetPvProfString( "Browse", "IpRecno", "1", oApp():cInifile ) )
   LOCAL nSplit := Val( GetPvProfString( "Browse", "IpSplit", "102", oApp():cInifile ) )
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

   SELECT IP
   oApp():oDlg := TFsdi():New( oApp():oWndMain )
   oApp():oDlg:cTitle := i18n( 'Gestión de ingredientes principales' )
   oApp():oWndMain:oClient := oApp():oDlg
   oApp():oDlg:NewGrid( nSplit )

   Ut_BrwRowConfig( oApp():oGrid )
   oApp():oGrid:cAlias := "IP"

   oCol := oApp():oGrid:AddCol()
   oCol:Cargo    := 1
   oCol:AddResource( "16_SORT_A" )
   oCol:nHeadBmpNo    := 1
   oCol:nHeadBmpAlign := AL_RIGHT
   oCol:bStrData :=  {|| IP->IpIngred }
   oCol:cHeader  := "Ingrediente principal"
   oCol:nWidth   := 150

   ADD oCol TO oApp():oGrid DATA IP->IpRecetas ;
      HEADER "Recetas" PICTURE "@E 999,999" ;
      TOTAL 0 WIDTH 90

   FOR i := 1 TO Len( oApp():oGrid:aCols )
      oCol := oApp():oGrid:aCols[ i ]
      oCol:bLDClickData  := {|| IpEdita( oApp():oGrid, 2, oCont, oApp():oDlg ) }
   NEXT

   oApp():oGrid:SetRDD()
   oApp():oGrid:CreateFromCode()
   oApp():oGrid:bChange  := {|| RefreshCont( oCont, "IP" ), oApp():oGrid:Maketotals() }
   oApp():oGrid:bKeyDown := {| nKey| IpTecla( nKey, oApp():oGrid, oCont, oApp():oDlg ) }
   oApp():oGrid:RestoreState( cState )
   oApp():oGrid:nRowHeight  := 21
   oApp():oGrid:lFooter := .T.
   oApp():oGrid:bClrFooter := {|| { CLR_HRED, GetSysColor( 15 ) } }
   oApp():oGrid:MakeTotals()


   IP->( dbSetOrder( nOrder ) )
   IF nRecNo < IP->( LastRec() ) .AND. nRecno != 0
      IP->( dbGoto( nRecno ) )
   ELSE
      IP->( dbGoTop() )
   ENDIF

   @ 02, 05 VMENU oCont SIZE nSplit - 10, 18 OF oApp():oDlg  ;
      COLOR CLR_BLACK, GetSysColor( 15 )       ;
      FILLED   ;  // BORDER
   COLORSELECT 0, CLR_WHITE ;
      HEIGHT ITEM 22

   DEFINE TITLE OF oCont ;
      CAPTION tran( IP->( ordKeyNo() ), '@E 999,999' ) + " / " + tran( IP->( ordKeyCount() ), '@E 999,999' ) ;
      HEIGHT 25 ;
      COLOR GetSysColor( 9 ), oApp():nClrBar ;
      IMAGE "BB_INGRED"

   @ 24, 05 VMENU oBar SIZE nSplit - 10, 160 OF oApp():oDlg  ;
      COLOR CLR_BLACK, GetSysColor( 15 )       ;
      HEIGHT ITEM 22 XBOX
   oBar:nClrBox := Min( GetSysColor( 13 ), GetSysColor( 14 ) )

   DEFINE TITLE OF oBar ;
      CAPTION i18n( "Ingredientes principales" ) ;
      HEIGHT 24 ;
      COLOR GetSysColor( 9 ), oApp():nClrBar ;
      OPENCLOSE

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Nuevo"              ;
      IMAGE "16_NUEVO"             ;
      ACTION IpEdita( oApp():oGrid, 1, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Modificar"          ;
      IMAGE "16_MODIF"             ;
      ACTION IpEdita( oApp():oGrid, 2, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Duplicar"           ;
      IMAGE "16_DUPLICA"           ;
      ACTION IpEdita( oApp():oGrid, 3, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Borrar"             ;
      IMAGE "16_BORRAR"            ;
      ACTION IpBorra( oApp():oGrid, oCont );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Buscar"             ;
      IMAGE "16_BUSCA"             ;
      ACTION IpBusca( oApp():oGrid,, oCont, oApp():oDlg )  ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Imprimir"           ;
      IMAGE "16_IMPRIMIR"          ;
      ACTION IpImprime( oApp():oGrid, oApp():oDlg )         ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Ver recetas"        ;
      IMAGE "16_RECETAS"        ;
      ACTION IpEjemplares( oApp():oGrid, oApp():oDlg ) ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Excel"              ;
      IMAGE "16_EXCEL"             ;
      ACTION ( CursorWait(), Ut_ExportXLS( oApp():oGrid, "Ingredientes principales" ), CursorArrow() );
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
      ITEMS ' Ingredientes principales '

   oApp():oDlg:NewSplitter( nSplit, oCont, oBar )

   ACTIVATE DIALOG oApp():oDlg NOWAIT ;
      ON INIT ( ResizeWndMain(), oApp():oGrid:SetFocus() ) ;
      VALID ( oApp():oGrid:nLen := 0,;
      WritePProString( "Browse", "IpState", oApp():oGrid:SaveState(), oApp():cInifile ),;
      WritePProString( "Browse", "IpOrder", LTrim( Str( IP->( ordNumber() ) ) ), oApp():cInifile ),;
      WritePProString( "Browse", "IpRecno", LTrim( Str( IP->( RecNo() ) ) ), oApp():cInifile ),;
      WritePProString( "Browse", "IpSplit", LTrim( Str( oApp():oSplit:nleft / 2 ) ), oApp():cInifile ),;
      oBar:End(), dbCloseAll(), oApp():oDlg := NIL, oApp():oGrid := NIL, oApp():oTab := NIL, .T. )

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION IPEdita( oGrid, nMode, oCont, oParent, cIngred )

   LOCAL oDlg, oFld, oBmp
   LOCAL aTitle := { i18n( "Añadir ingrediente principal" ),;
      i18n( "Modificar ingrediente principal" ),;
      i18n( "Duplicar ingrediente principal" ) }
   LOCAL aGet[ 1 ]
   LOCAL cIpIngred

   LOCAL nRecPtr := IP->( RecNo() )
   LOCAL nOrden  := IP->( ordNumber() )
   LOCAL nRecAdd
   LOCAL lDuplicado
   LOCAL lreturn := .F.

   IF IP->( Eof() ) .AND. nMode != 1
      RETURN NIL
   ENDIF

   oApp():nEdit ++

   IF nMode == 1
      IP->( dbAppend() )
      nRecAdd := IP->( RecNo() )
   ENDIF

   cIpIngred  := iif( nMode == 1 .AND. cIngred != nil, cIngred, IP->IpIngred )

   IF nMode == 3
      IP->( dbAppend() )
      nRecAdd := IP->( RecNo() )
   ENDIF

   DEFINE DIALOG oDlg RESOURCE "IP_EDIT_" + oApp():cLanguage OF oParent   ;
      TITLE aTitle[ nMode ]
   oDlg:SetFont( oApp():oFont )

   REDEFINE GET aGet[ 1 ] VAR cIpIngred  ;
      ID 12 OF oDlg UPDATE             ;
      VALID IpClave( cIpIngred, aGet[ 1 ], nMode )

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
      /* ___ actualizo el ingrediente principal en la receta_____________*/
      IF nMode == 2
         IF RTrim( cIpIngred ) != RTrim( IP->IpIngred )
            SELECT RE
            RE->( dbGoTop() )
            REPLACE RE->ReIngPri    ;
               WITH cIpIngred       ;
               FOR Upper( RTrim( RE->ReIngPri ) ) == Upper( RTrim( IP->IpIngred ) )
         ENDIF
         SELECT IP
      ENDIF

      /* ___ guardo el registro _______________________________________________*/
      IF nMode == 2
         IP->( dbGoto( nRecPtr ) )
      ELSE
         IP->( dbGoto( nRecAdd ) )
      ENDIF
      REPLACE IP->IpIngred     WITH cIpIngred
      IP->( dbCommit() )
   ELSE
      IF nMode == 1 .OR. nMode == 3
         IP->( dbGoto( nRecAdd ) )
         IP->( dbDelete() )
         IP->( DbPack() )
         IP->( dbGoto( nRecPtr ) )
      ENDIF
   ENDIF

   SELECT IP
   IF oCont != nil
      RefreshCont( oCont, "IP" )
   ENDIF
   IF oGrid != nil
      oGrid:Refresh()
      oGrid:SetFocus( .T. )
   ENDIF
   oApp():nEdit --

   RETURN lreturn
/*_____________________________________________________________________________*/

FUNCTION IpBorra( oGrid, oCont )

   LOCAL nRecord := IP->( RecNo() )
   LOCAL nNext

   oApp():nEdit ++

   IF msgYesNo( i18n( "¿ Está seguro de querer borrar este ingrediente principal ?" ) + CRLF + ;
         ( Trim( IP->IpIngred ) ), 'Seleccione una opción' )
      // dejo en blanco el ingrediente principal en la receta
      SELECT RE
      RE->( dbGoTop() )
      REPLACE RE->ReIngPri      ;
         WITH Space( 20 )       ;
         FOR Upper( RTrim( RE->ReIngPri ) ) == Upper( RTrim( IP->IpIngred ) )

      // borro el grupo
      IP->( dbSkip() )
      nNext := IP->( RecNo() )
      IP->( dbGoto( nRecord ) )

      IP->( dbDelete() )
      IP->( DbPack() )
      IP->( dbGoto( nNext ) )
      IF IP->( Eof() ) .OR. nNext == nRecord
         IP->( dbGoBottom() )
      ENDIF
   ENDIF

   IF oCont != nil
      RefreshCont( oCont, "IP" )
   ENDIF

   oGrid:Refresh( .T. )
   oGrid:SetFocus( .T. )
   oApp():nEdit --

   RETURN NIL
/*_____________________________________________________________________________*/
FUNCTION IpTecla( nKey, oGrid, oCont, oDlg )

   DO CASE
   CASE nKey == VK_RETURN
      IpEdita( oGrid, 2, oCont, oDlg )
   CASE nKey == VK_INSERT
      IpEdita( oGrid, 1, oCont, oDlg )
   CASE nKey == VK_DELETE
      IpBorra( oGrid, oCont )
   CASE nKey == VK_ESCAPE
      oDlg:End()
   OTHERWISE
      IF nKey >= 96 .AND. nKey <= 105
         IpBusca( oGrid, Str( nKey - 96, 1 ), oCont, oDlg )
      ELSEIF HB_ISSTRING( Chr( nKey ) )
         IpBusca( oGrid, Chr( nKey ), oCont, oDlg )
      ENDIF
   ENDCASE

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION IpSeleccion( cIngred, oControl, oParent, oVItem )

   LOCAL oDlg, oBrowse, oCol, oBtnAceptar, oBtnCancel, oBNew, oBMod, oBDel
   LOCAL lOk    := .F.
   LOCAL nRecno := IP->( RecNo() )
   LOCAL nOrder := IP->( ordNumber() )
   LOCAL nArea  := Select()
   LOCAL aPoint := iif( oControl != NIL, AdjustWnd( oControl, 271 * 2, 150 * 2 ), { 1.3 * oVItem:nTop(), oApp():oGrid:nLeft } )

   DEFINE DIALOG oDlg RESOURCE 'UT_AJENA1_' + oApp():cLanguage OF oParent;
      TITLE i18n( "Selección de ingrediente principal" )
   oDlg:SetFont( oApp():oFont )

   // siempre tengo ordenado por nombre

   SELECT IP
   IP->( dbSetOrder( 1 ) )
   IP->( dbGoTop() )

   IF ! IP->( dbSeek( cIngred ) )
      IP->( dbGoTop() )
   ENDIF

   oBrowse := TXBrowse():New( oDlg )
   Ut_BrwRowConfig( oBrowse )
   oBrowse:cAlias := "IP"

   oCol := oBrowse:AddCol()
   oCol:bStrData := {|| IP->IpIngred }
   oCol:cHeader  := "Ingrediente principal"
   oCol:nWidth   := 160
   oCol:bLDClickData  := {|| ( lOk := .T., oDlg:End() )   }
   oBrowse:SetRDD()
   oBrowse:CreateFromResource( 110 )
   oBrowse:bKeyDown := {| nKey| IpSeTecla( nKey, oBrowse, oDlg, oBtnAceptar ) }

   REDEFINE BUTTON oBNew   ;
      ID 410 OF oDlg       ;
      ACTION IpEdita( oBrowse, 1,, oDlg )

   REDEFINE BUTTON oBMod   ;
      ID 411 OF oDlg       ;
      ACTION IpEdita( oBrowse, 2,, oDlg )

   REDEFINE BUTTON oBDel   ;
      ID 412 OF oDlg       ;
      ACTION IpBorra( oBrowse, )

   REDEFINE BUTTON oBtnAceptar   ;
      ID IDOK OF oDlg            ;
      ACTION ( lOk := .T., oDlg:End() )

   REDEFINE BUTTON oBtnCancel    ;
      ID IDCANCEL OF oDlg        ;
      ACTION ( lOk := .F., oDlg:End() )

   ACTIVATE DIALOG oDlg CENTERED       ;
      ON PAINT oDlg:Move( aPoint[ 1 ], aPoint[ 2 ],,, .T. )

   IF lOK
      cIngred := IP->IpIngred
      IF oControl != NIL
         oControl:cText := IP->IpIngred
      ENDIF
   ENDIF

   IP->( dbSetOrder( nOrder ) )
   IP->( dbGoto( nRecno ) )

   SELECT ( nArea )

   RETURN NIL
/*_____________________________________________________________________________*/
FUNCTION IpSeTecla( nKey, oGrid, oDlg, oBtn )

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
FUNCTION IpBusca( oGrid, cChr, oCont, oParent )

   LOCAL nOrder   := IP->( ordNumber() )
   LOCAL nRecno   := IP->( RecNo() )
   LOCAL oDlg, oGet, cGet, cPicture
   LOCAL aSay1    := { "Introduzca el nombre del ingrediente principal" }
   LOCAL aSay2    := { "Ingrediente Principal:" }
   LOCAL aGet     := { Space( 20 ) }
   LOCAL lSeek    := .F.
   LOCAL lFecha   := .F.
   LOCAL aBrowse := {}

   oApp():nEdit ++

   DEFINE DIALOG oDlg RESOURCE 'UT_BUSCA_' + oApp():cLanguage OF oParent  ;
      TITLE i18n( "Búsqueda de ingrediente principal" )
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
         {|| IpWildSeek( nOrder, cGet, aBrowse ) } )
      IF Len( aBrowse ) == 0
         MsgStop( "No se ha encontrado ningún ingrediente principal." )
      ELSE
         IpEncontrados( aBrowse, oApp():oDlg )
      ENDIF
   ENDIF
   IF oCont != NIL
      RefreshCont( oCont, "IP" )
   ENDIF
	
   oApp():nEdit --
   oGrid:Refresh()
   oGrid:SetFocus( .T. )

   RETURN NIL
/*_____________________________________________________________________________*/
FUNCTION IPWildSeek( nOrder, cGet, aBrowse )

   LOCAL nRecno   := IP->( RecNo() )
	
   IP->( dbGoTop() )
   DO WHILE ! IP->( Eof() )
      IF cGet $ Upper( IP->IpIngred )
         AAdd( aBrowse, { IP->IpIngred, IP->IpRecetas, IP->( RecNo() ) } )
      ENDIF
      IP->( dbSkip() )
   ENDDO
   IP->( dbGoto( nRecno ) )
   // ordeno la tabla por el 1 elemento
   ASort( aBrowse,,, {|aAut1, aAut2| Upper( aAut1[ 1 ] ) < Upper( aAut2[ 1 ] ) } )

   RETURN NIL
/*_____________________________________________________________________________*/
	
FUNCTION IpEncontrados( aBrowse, oParent )

   LOCAL oDlg, oBrowse, oBtnOk, oBtnCancel, lOk
   LOCAL nRecno := IP->( RecNo() )
	
   DEFINE DIALOG oDlg RESOURCE "DLG_ENCONTRADOS" ;
      TITLE i18n( "Resultado de la búsqueda" ) ;
      OF oParent
   oDlg:SetFont( oApp():oFont )
	
   oBrowse := TXBrowse():New( oDlg )
   Ut_BrwRowConfig( oBrowse )

   oBrowse:SetArray( aBrowse, .F. )
   oBrowse:aCols[ 1 ]:cHeader := "Ingrediente"
   oBrowse:aCols[ 2 ]:cHeader := "Recetas"
   oBrowse:aCols[ 1 ]:nWidth  := 340
   oBrowse:aCols[ 2 ]:nWidth  := 100
   oBrowse:aCols[ 3 ]:Hide()
   oBrowse:aCols[ 1 ]:nHeadStrAlign := 0
   oBrowse:aCols[ 1 ]:nDataStrAlign := 0
   oBrowse:aCols[ 2 ]:nHeadStrAlign := 0
   oBrowse:aCols[ 2 ]:nDataStrAlign := 0
	
   oBrowse:CreateFromResource( 110 )
	
   IP->( dbGoto( aBrowse[ oBrowse:nArrayAt, 3 ] ) )
   AEval( oBrowse:aCols, {|oCol| oCol:bLDClickData := {|| IP->( dbGoto( aBrowse[ oBrowse:nArrayAt, 3 ] ) ), ;
      IpEdita( , 2,, oApp():oDlg ) } } )
   oBrowse:bKeyDown  := {| nKey| iif( nKey == VK_RETURN, ( IP->( dbGoto( aBrowse[ oBrowse:nArrayAt, 3 ] ) ), ;
      IpEdita( , 2,, oApp():oDlg ) ), ) }
   oBrowse:bChange    := {|| IP->( dbGoto( aBrowse[ oBrowse:nArrayAt, 3 ] ) ) }
   oBrowse:lHScroll  := .F.
   oDlg:oClient      := oBrowse
   oBrowse:nRowHeight := 20
	
   REDEFINE BUTTON oBtnOk ;
      ID IDOK OF oDlg     ;
      ACTION oDlg:End()
	
   REDEFINE BUTTON oBtnCancel ;
      ID IDCANCEL OF oDlg ;
      ACTION ( IP->( dbGoto( nRecno ) ), oDlg:End() )
	
   ACTIVATE DIALOG oDlg ;
      ON INIT DlgCenter( oDlg, oApp():oWndMain )
	
   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION IpClave( cIngred, oGet, nMode )

   // nMode    1 nuevo registro
   // 2 modificación de registro
   // 3 duplicación de registro
   // 4 clave ajena
   LOCAL lreturn  := .F.
   LOCAL nRecno   := IP->( RecNo() )
   LOCAL nOrder   := IP->( ordNumber() )
   LOCAL nArea    := Select()

   IF Empty( cIngred )
      IF nMode == 4
         RETURN .T.
      ELSE
         MsgStop( "Es obligatorio rellenar este campo." )
         RETURN .F.
      ENDIF
   ENDIF

   SELECT IP
   IP->( dbSetOrder( 1 ) )
   IP->( dbGoTop() )

   IF IP->( dbSeek( Upper( cIngred ) ) )
      DO CASE
      CASE nMode == 1 .OR. nMode == 3
         lreturn := .F.
         MsgStop( "Ingrediente principal existente." )
      CASE nMode == 2
         IF IP->( RecNo() ) == nRecno
            lreturn := .T.
         ELSE
            lreturn := .F.
            MsgStop( "Ingrediente principal existente." )
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
         IF MsgYesNo( "Ingrediente principal inexistente. ¿ Desea darlo de alta ahora? ", 'Seleccione una opción' )
            lreturn := IpEdita( , 1, , , @cIngred )
         ELSE
            lreturn := .F.
         ENDIF
      ENDIF
   ENDIF

   IF lreturn == .F.
      oGet:cText( Space( 20 ) )
   ENDIF

   IP->( dbSetOrder( nOrder ) )
   IP->( dbGoto( nRecno ) )

   SELECT ( nArea )

   RETURN lreturn
/*_____________________________________________________________________________*/

FUNCTION IpEjemplares( oGrid, oParent )

   LOCAL oDlg, oBrowse, oCol
   LOCAL cIngred  := IP->IpIngred
   LOCAL aEpoca   := { '0000', '0001', '0010', '0011', '0100', '0101', '0110', '0111', ;
      '1000', '1001', '1010', '1011', '1100', '1101', '1110', '1111' }
   LOCAL i
   LOCAL cTitle

   oApp():nEdit ++

   DEFINE DIALOG oDlg RESOURCE 'UT_EJEMPLARES'  ;
      TITLE 'Recetas de: ' + IP->IpIngred OF oParent
   oDlg:SetFont( oApp():oFont )

   SELECT RE
   RE->( dbSetOrder( 6 ) )
   RE->( dbSetFilter( {|| Trim( RE->ReIngPri ) == Trim( cIngred ) } ) )
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

   SELECT IP
   oGrid:Refresh()
   oGrid:SetFocus( .T. )
   oApp():nEdit --

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION IpImprime( oGrid, oParent )

   LOCAL nRecno   := IP->( RecNo() )
   LOCAL nOrder   := IP->( ordSetFocus() )
   LOCAL aCampos  := { "IPINGRED", "IPRECETAS" }
   LOCAL aTitulos := { "Ingrediente principal", "Recetas" }
   LOCAL aWidth   := { 50, 50 }
   LOCAL aShow    := { .T., .T. }
   LOCAL aPicture := { "NO", "@E 99,999" }
   LOCAL aTotal   := { .F., .F. }
   LOCAL nLen     := 2  // nº de campos a mostrar
   LOCAL oInforme

   oApp():nEdit ++

   oInforme := TInforme():New( aCampos, aTitulos, aWidth, aShow, aPicture, aTotal, "IP" )
   oInforme:Dialog()

   REDEFINE RADIO oInforme:oRadio VAR oInforme:nRadio ID 300 OF oInforme:oFld:aDialogs[ 1 ] ;
      ON CHANGE oInforme:Change()

   oInforme:Folders()

   IF oInforme:Activate()
      SELECT IP
      IP->( dbGoTop() )
      oInforme:Report()
      ACTIVATE REPORT oInforme:oReport ;
         ON END ( oInforme:oReport:StartLine(), oInforme:oReport:EndLine(), oInforme:oReport:StartLine(), ;
         oInforme:oReport:Say( 1, 'Total ingredientes principales: ' + Tran( oInforme:oReport:nCounter, '@E 999,999' ), 1 ), ;
         oInforme:oReport:EndLine() )
      oInforme:End( .T. )
      IP->( ordSetFocus( nOrder ) )
      IP->( dbGoto( nRecno ) )
   ENDIF

   oApp():nEdit --

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION IpList( aList, cData, oSelf )

   LOCAL aNewList := {}

   IP->( dbSetOrder( 1 ) )
   IP->( dbGoTop() )
   WHILE ! IP->( Eof() )
      IF At( Upper( cdata ), Upper( IP->IpIngred ) ) != 0 // UPPER( SubStr( oApp():amaterias[i,1], 1, Len( cData ) ) ) == UPPER( cData )
         AAdd( aNewList, { IP->IpIngred } )
      ENDIF
      IP->( dbSkip() )
   ENDDO

   RETURN aNewlist
