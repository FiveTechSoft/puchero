#include "FiveWin.ch"
#include "Report.ch"
#include "xBrowse.ch"
#include "vmenu.ch"
#include "splitter.ch"

STATIC oReport

FUNCTION Proveedores()

   LOCAL oBar, oCol, oCont
   LOCAL aBrowse
   LOCAL cState := GetPvProfString( "Browse", "PrState", "", oApp():cInifile )
   LOCAL nOrder := Max( Val( GetPvProfString( "Browse", "PrOrder", "1", oApp():cInifile ) ), 1 )
   LOCAL nRecno := Val( GetPvProfString( "Browse", "PrRecno", "1", oApp():cInifile ) )
   LOCAL nSplit := Val( GetPvProfString( "Browse", "PrSplit", "102", oApp():cInifile ) )
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

   SELECT PR
   oApp():oDlg := TFsdi():New( oApp():oWndMain )
   oApp():oDlg:cTitle := i18n( 'Gestión de proveedores de ingredientes' )
   oApp():oWndMain:oClient := oApp():oDlg
   oApp():oDlg:NewGrid( nSplit )

   Ut_BrwRowConfig( oApp():oGrid )
   oApp():oGrid:cAlias := "PR"

   oCol := oApp():oGrid:AddCol()
   oCol:bLClickHeader := {|| PrSort( 1, oCont ) }
   oCol:Cargo := 1
   oCol:AddResource( "16_SORT_A" )
   oCol:AddResource( "16_SORT_B" )
   oCol:nHeadBmpNo    := iif( nOrder == 1, 1, 2 )
   oCol:nHeadBmpAlign := AL_RIGHT
   oCol:bStrData := {|| PR->PrNombre }
   oCol:cHeader  := i18n( "Nombre" )
   oCol:nWidth   := 190

   oCol := oApp():oGrid:AddCol()
   oCol:bLClickHeader := {|| PrSort( 2, oCont ) }
   oCol:Cargo := 2
   oCol:AddResource( "16_SORT_A" )
   oCol:AddResource( "16_SORT_B" )
   oCol:nHeadBmpNo    := iif( nOrder == 2, 1, 2 )
   oCol:nHeadBmpAlign := AL_RIGHT
   oCol:bStrData := {|| PR->PrPais }
   oCol:cHeader  := i18n( "País" )
   oCol:nWidth   := 120

   oCol := oApp():oGrid:AddCol()
   oCol:bLClickHeader := {|| PrSort( 3, oCont ) }
   oCol:Cargo := 3
   oCol:AddResource( "16_SORT_A" )
   oCol:AddResource( "16_SORT_B" )
   oCol:nHeadBmpNo    := iif( nOrder == 3, 1, 2 )
   oCol:nHeadBmpAlign := AL_RIGHT
   oCol:bStrData := {|| PR->PrLocali }
   oCol:cHeader  := i18n( "Localidad" )
   oCol:nWidth   := 190

   ADD oCol TO oApp():oGrid DATA PR->PrAliment ;
      HEADER "Alimentos" PICTURE "@E 999,999" ;
      TOTAL 0 WIDTH 90

   aBrowse   := { { {|| PR->PrCif }, i18n( "C.I.F." ), 90 }, ;
      { {|| PR->PrDirecc }, i18n( "Dirección" ), 120 }, ;
      { {|| PR->PrTelefono }, i18n( "Telefono" ), 120 }, ;
      { {|| PR->PrFax }, i18n( "Fax" ), 120 }, ;
      { {|| PR->PrEmail }, i18n( "E-mail" ), 150 }, ;
      { {|| PR->PrURL }, i18n( "Sitio web" ), 150 } }


   FOR i := 1 TO Len( aBrowse )
      oCol := oApp():oGrid:AddCol()
      oCol:bStrData := aBrowse[ i, 1 ]
      oCol:cHeader  := aBrowse[ i, 2 ]
      oCol:nWidth   := aBrowse[ i, 3 ]
   NEXT

   FOR i := 1 TO Len( oApp():oGrid:aCols )
      oCol := oApp():oGrid:aCols[ i ]
      oCol:bLDClickData  := {|| PrEdita( oApp():oGrid, 2, oCont, oApp():oDlg ) }
   NEXT

   oApp():oGrid:SetRDD()
   oApp():oGrid:CreateFromCode()
   oApp():oGrid:bChange  := {|| RefreshCont( oCont, "PR" ), oApp():ogrid:Maketotals() }
   oApp():oGrid:bKeyDown := {| nKey| PrTecla( nKey, oApp():oGrid, oCont, oApp():oDlg ) }
   oApp():oGrid:nRowHeight  := 21
   oApp():oGrid:RestoreState( cState )
   oApp():oGrid:lFooter := .T.
   oApp():oGrid:bClrFooter := {|| { CLR_HRED, GetSysColor( 15 ) } }
   oApp():oGrid:MakeTotals()

   Pr->( dbSetOrder( nOrder ) )
   IF nRecNo < PR->( LastRec() ) .AND. nRecno != 0
      PR->( dbGoto( nRecno ) )
   ELSE
      PR->( dbGoTop() )
   ENDIF

   @ 02, 05 VMENU oCont SIZE nSplit - 10, 18 OF oApp():oDlg  ;
      COLOR CLR_BLACK, GetSysColor( 15 )       ;
      FILLED   ;  // BORDER
   COLORSELECT 0, CLR_WHITE ;
      HEIGHT ITEM 22

   DEFINE TITLE OF oCont ;
      CAPTION tran( PR->( ordKeyNo() ), '@E 999,999' ) + " / " + tran( PR->( ordKeyCount() ), '@E 999,999' ) ;// strZero( RE->( ordKeyCount() ), 6 ) ;
   HEIGHT 25 ;
      COLOR GetSysColor( 9 ), oApp():nClrBar ;
      IMAGE "BB_PROVEE"

   @ 24, 05 VMENU oBar SIZE nSplit - 10, 165 OF oApp():oDlg  ;
      COLOR CLR_BLACK, GetSysColor( 15 )       ;
      HEIGHT ITEM 22 XBOX
   oBar:nClrBox := Min( GetSysColor( 13 ), GetSysColor( 14 ) )

   DEFINE TITLE OF oBar ;
      CAPTION "Proveedores" ;
      HEIGHT 24 ;
      COLOR GetSysColor( 9 ), oApp():nClrBar ;
      OPENCLOSE

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Nuevo"              ;
      IMAGE "16_NUEVO"             ;
      ACTION PrEdita( oApp():oGrid, 1, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Modificar"          ;
      IMAGE "16_MODIF"             ;
      ACTION PrEdita( oApp():oGrid, 2, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Duplicar"           ;
      IMAGE "16_DUPLICA"           ;
      ACTION PrEdita( oApp():oGrid, 3, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Borrar"             ;
      IMAGE "16_BORRAR"            ;
      ACTION PrBorra( oApp():oGrid, oCont );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Buscar"             ;
      IMAGE "16_BUSCA"             ;
      ACTION PrBusca( oApp():oGrid,, oCont, oApp():oDlg )  ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Imprimir"           ;
      IMAGE "16_IMPRIMIR"          ;
      ACTION PrImprime( oApp():oGrid, oApp():oDlg )         ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Ver Ingredientes"   ;
      IMAGE "16_ALIMENTO"          ;
      ACTION PrEjemplares( oApp():oGrid, oApp():oDlg ) ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Visitar sitio web"  ;
      IMAGE "16_INTERNET"          ;
      ACTION GoWeb( PR->PrUrl )      ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Enviar e-mail"      ;
      IMAGE "16_EMAIL"             ;
      ACTION GoMail( PR->PrEmail )   ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Enviar a Excel"     ;
      IMAGE "16_EXCEL"             ;
      ACTION ( CursorWait(), Ut_ExportXLS( oApp():oGrid, "Proveedores" ), CursorArrow() );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Configurar rejilla" ;
      IMAGE "16_GRID"              ;
      ACTION Ut_BrwColConfig( oApp():oGrid, "PrState" ) ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Salir"              ;
      IMAGE "16_SALIR"             ;
      ACTION oApp():oDlg:End()              ;
      LEFT 10

   @ oApp():oDlg:nGridBottom, nSplit + 2 TABS oApp():oTab ;
      OPTION nOrder SIZE oApp():oWndMain:nWidth() -80, 12 PIXEL OF oApp():oDlg ;
      ITEMS ' Proveedor ', ' Pais ', ' Localidad ';
      ACTION PrSort( oApp():otab:noption, oCont )

   oApp():oDlg:NewSplitter( nSplit, oCont, oBar )

   ACTIVATE DIALOG oApp():oDlg NOWAIT ;
      ON INIT ( ResizeWndMain(), oApp():oGrid:SetFocus() ) ;
      VALID ( oApp():oGrid:nLen := 0,;
      WritePProString( "Browse", "PrState", oApp():oGrid:SaveState(), oApp():cInifile ), ;
      WritePProString( "Browse", "PrOrder", LTrim( Str( Pr->( ordNumber() ) ) ), oApp():cInifile ),;
      WritePProString( "Browse", "PrRecno", LTrim( Str( Pr->( RecNo() ) ) ), oApp():cInifile ), ;
      WritePProString( "Browse", "PrSplit", LTrim( Str( oApp():oSplit:nleft / 2 ) ), oApp():cInifile ), ;
      oBar:End(), dbCloseAll(), oApp():oDlg := NIL, oApp():oGrid := NIL, oApp():oTab := NIL, .T. )

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION PrEdita( oGrid, nMode, oCont, oParent, cProveed )

   LOCAL oDlg, oFld, oBmp
   LOCAL aTitle := { i18n( "Añadir proveedor" ),;
      i18n( "Modificar proveedor" ),;
      i18n( "Duplicar proveedor" ) }
   LOCAL aGet[ 12 ]
   LOCAL cPrnombre,;
      cPrCif,;
      cPrNotas,;
      cPrdirecc,;
      cPrlocali,;
      cPrtelefono, ;
      cPrFax,;
      cPrPais,;
      cPremail,;
      cPrurl

   LOCAL nRecPtr := PR->( RecNo() )
   LOCAL nOrden  := PR->( ordNumber() )
   LOCAL nRecAdd
   LOCAL lDuplicado
   LOCAL lreturn := .F.

   IF PR->( Eof() ) .AND. nMode != 1
      RETURN NIL
   ENDIF

   oApp():nEdit ++

   IF nMode == 1
      PR->( dbAppend() )
      nRecAdd := PR->( RecNo() )
   ENDIF

   cPrnombre  := iif( nMode == 1 .AND. cProveed != nil, cProveed, PR->Prnombre )
   cPrCif     := PR->PrCif
   cPrdirecc  := PR->Prdirecc
   cPrlocali  := PR->Prlocali
   cPrtelefono := PR->Prtelefono
   cPrFax     := PR->PrFax
   cPrPais    := PR->PrPais
   cPremail   := PR->Premail
   cPrurl     := PR->Prurl
   cPrnotas   := PR->Prnotas

   IF nMode == 3
      Pr->( dbAppend() )
      nRecAdd := Pr->( RecNo() )
   ENDIF

   DEFINE DIALOG oDlg RESOURCE "PR_EDIT_" + oApp():cLanguage OF oParent;
      TITLE aTitle[ nMode ]
   oDlg:SetFont( oApp():oFont )

   REDEFINE GET aGet[ 1 ] VAR cPrNombre        ;
      ID 101 OF oDlg UPDATE                  ;
      VALID    PrClave( cPrNombre, aGet[ 1 ], nMode )

   REDEFINE GET aGet[ 2 ] VAR cPrCif     ;
      ID 102 OF oDlg UPDATE

   REDEFINE GET aGet[ 3 ] VAR cPrDirecc  ;
      ID 103 OF oDlg UPDATE

   REDEFINE GET aGet[ 4 ] VAR cPrlocali  ;
      ID 104 OF oDlg UPDATE

   REDEFINE GET aGet[ 5 ] VAR cPrPais    ;
      ID 105 OF oDlg UPDATE

   REDEFINE GET aGet[ 6 ] VAR cPrTelefono;
      ID 106 OF oDlg UPDATE

   REDEFINE GET aGet[ 7 ] VAR cPrFax     ;
      ID 107 OF oDlg UPDATE

   REDEFINE GET aGet[ 8 ] VAR cpremail ;
      ID 108 OF oDlg

   REDEFINE BUTTON aGet[ 11 ]   ;
      ID 111 OF oDlg          ;
      ACTION GoMail( cPrEmail )
   aGet[ 11 ]:cTooltip := i18n( "enviar e-mail" )

   REDEFINE GET aGet[ 9 ] VAR cprURL     ;
      ID 109 OF oDlg

   REDEFINE BUTTON aGet[ 12 ]   ;
      ID 112 OF oDlg          ;
      ACTION GoWeb( cPrUrl )
   aGet[ 12 ]:cTooltip := i18n( "visitar sitio web" )

   REDEFINE GET aGet[ 10 ] VAR cprNotas   ;
      MULTILINE ID 110 OF oDlg UPDATE

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
         IF RTrim( cPrNombre ) != RTrim( PR->PrNombre )
            SELECT AL
            AL->( dbGoTop() )
            REPLACE AL->AlProveed   ;
               WITH cPrNombre       ;
               FOR Upper( RTrim( AL->AlProveed ) ) == Upper( RTrim( PR->PrNombre ) )
            SELECT ES
            ES->( dbGoTop() )
            REPLACE ES->EsProveed   ;
               WITH cPrNombre       ;
               FOR Upper( RTrim( ES->EsProveed ) ) == Upper( RTrim( PR->PrNombre ) )
            SELECT PR
         ENDIF
      ENDIF

      /* ___ guardo el registro _______________________________________________*/
      IF nMode == 2
         PR->( dbGoto( nRecPtr ) )
      ELSE
         PR->( dbGoto( nRecAdd ) )
      ENDIF
      REPLACE PR->Prnombre   WITH cPrnombre
      REPLACE PR->PrCif      WITH cPrCif
      REPLACE PR->Prdirecc   WITH cPrdirecc
      REPLACE PR->Prlocali   WITH cPrlocali
      REPLACE PR->Prtelefono WITH cPrtelefono
      REPLACE PR->Prfax      WITH cPrfax
      REPLACE PR->Prpais     WITH cPrpais
      REPLACE PR->Premail    WITH cPremail
      REPLACE PR->Prurl      WITH cPrurl
      REPLACE PR->Prnotas    WITH cPrnotas
      PR->( dbCommit() )
      IF cProveed != nil
         cProveed := PR->PrNombre
      ENDIF
   ELSE

      IF nMode == 1 .OR. nMode == 3
         PR->( dbGoto( nRecAdd ) )
         PR->( dbDelete() )
         PR->( DbPack() )
         PR->( dbGoto( nRecPtr ) )
      ENDIF

   ENDIF

   SELECT PR

   IF oCont != nil
      RefreshCont( oCont, "PR" )
   ENDIF
   IF oGrid != nil
      oGrid:Refresh()
      oGrid:SetFocus( .T. )
   ENDIF
   oApp():nEdit --

   RETURN lreturn
/*_____________________________________________________________________________*/

FUNCTION PrBorra( oGrid, oCont )

   LOCAL nRecord := PR->( RecNo() )
   LOCAL nNext

   oApp():nEdit ++

   IF msgYesNo( i18n( "¿ Está seguro de querer borrar este proveedor ?" ) + CRLF + ;
         ( Trim( PR->PrNombre ) ), 'Seleccione una opción' )
      // dejo en blanco el proveedor en alimentos
      SELECT AL
      AL->( dbGoTop() )
      REPLACE AL->AlProveed   ;
         WITH Space( 50 )       ;
         FOR Upper( RTrim( AL->AlProveed ) ) == Upper( RTrim( PR->PrNombre ) )

      // borro el proveedor
      SELECT PR
      PR->( dbSkip() )
      nNext := PR->( RecNo() )
      PR->( dbGoto( nRecord ) )

      PR->( dbDelete() )
      PR->( DbPack() )
      PR->( dbGoto( nNext ) )
      IF PR->( Eof() ) .OR. nNext == nRecord
         PR->( dbGoBottom() )
      ENDIF
   ENDIF

   IF oCont != nil
      RefreshCont( oCont, "PR" )
   ENDIF

   oGrid:Refresh( .T. )
   oGrid:SetFocus( .T. )
   oApp():nEdit --

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION PrTecla( nKey, oGrid, oCont, oDlg )

   DO CASE
   CASE nKey == VK_RETURN
      PrEdita( oGrid, 2, oCont, oDlg )
   CASE nKey == VK_INSERT
      PrEdita( oGrid, 1, oCont, oDlg )
   CASE nKey == VK_DELETE
      PrBorra( oGrid, oCont )
   CASE nKey == VK_ESCAPE
      oDlg:End()
   OTHERWISE
      IF nKey >= 96 .AND. nKey <= 105
         PrBusca( oGrid, Str( nKey - 96, 1 ), oCont, oDlg )
      ELSEIF HB_ISSTRING( Chr( nKey ) )
         PrBusca( oGrid, Chr( nKey ), oCont, oDlg )
      ENDIF
   ENDCASE

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION PrSeleccion( cProveed, oControl, oParent, oVitem )

   LOCAL oDlg, oBrowse, oCol, oBtnAceptar, oBtnCancel, oBNew, oBMod, oBDel, oBBus
   LOCAL lOk    := .F.
   LOCAL nRecno := PR->( RecNo() )
   LOCAL nOrder := PR->( ordNumber() )
   LOCAL nArea  := Select()
   LOCAL aPoint := iif( oControl != NIL, AdjustWnd( oControl, 271 * 2, 150 * 2 ), { 1.3 * oVItem:nTop(), oApp():oGrid:nLeft } )

   DEFINE DIALOG oDlg RESOURCE 'UT_AJENA1_' + oApp():cLanguage OF oParent;
      TITLE "Selección de proveedores"
   oDlg:SetFont( oApp():oFont )

   // siempre tengo ordenado por nombre

   SELECT PR
   PR->( dbSetOrder( 1 ) )
   PR->( dbGoTop() )

   IF ! PR->( dbSeek( cProveed ) )
      PR->( dbGoTop() )
   ENDIF

   oBrowse := TXBrowse():New( oDlg )
   Ut_BrwRowConfig( oBrowse )
   oBrowse:cAlias := "PR"

   oCol := oBrowse:AddCol()
   oCol:bStrData := {|| PR->PrNombre }
   oCol:cHeader  := "Proveedor"
   oCol:nWidth   := 120
   oCol:bLDClickData  := {|| ( lOk := .T., oDlg:End() )   }
   oBrowse:SetRDD()
   oBrowse:CreateFromResource( 110 )
   oBrowse:bKeyDown := {| nKey| PrSeTecla( nKey, oBrowse, oDlg, oBtnAceptar ) }

   REDEFINE BUTTON oBNew   ;
      ID 410 OF oDlg       ;
      ACTION PrEdita( oBrowse, 1,, oDlg )

   REDEFINE BUTTON oBMod   ;
      ID 411 OF oDlg       ;
      ACTION PrEdita( oBrowse, 2,, oDlg )

   REDEFINE BUTTON oBDel   ;
      ID 412 OF oDlg       ;
      ACTION PrBorra( oBrowse, )

   REDEFINE BUTTON oBBus   ;
      ID 413 OF oDlg       ;
      ACTION PrBusca( oBrowse, ,, oDlg )

   REDEFINE BUTTON oBtnAceptar   ;
      ID IDOK OF oDlg            ;
      ACTION ( lOk := .T., oDlg:End() )

   REDEFINE BUTTON oBtnCancel    ;
      ID IDCANCEL OF oDlg        ;
      ACTION ( lOk := .F., oDlg:End() )

   ACTIVATE DIALOG oDlg CENTERED       ;
      ON PAINT oDlg:Move( aPoint[ 1 ], aPoint[ 2 ],,, .T. )

   IF lOK
      cProveed := PR->PrNombre
      IF oControl != NIL
         oControl:cText := PR->PrNombre
      ENDIF
   ENDIF

   PR->( dbSetOrder( nOrder ) )
   PR->( dbGoto( nRecno ) )

   SELECT ( nArea )

   RETURN NIL
/*_____________________________________________________________________________*/
FUNCTION PrSeTecla( nKey, oGrid, oDlg, oBtn )

   DO CASE
   CASE nKey == VK_RETURN
      oBtn:Click()
   CASE nKey == VK_ESCAPE
      oDlg:End()
   OTHERWISE
      IF nKey >= 96 .AND. nKey <= 105
         PrBusca( oGrid, Str( nKey - 96, 1 ),, oDlg )
      ELSEIF HB_ISSTRING( Chr( nKey ) )
         PrBusca( oGrid, Chr( nKey ),, oDlg )
      ENDIF
   ENDCASE

   RETURN NIL
/*_____________________________________________________________________________*/
FUNCTION PrBusca( oGrid, cChr, oCont, oParent )

   LOCAL nOrder   := PR->( ordNumber() )
   LOCAL nRecno   := PR->( RecNo() )
   LOCAL oDlg, oGet, cGet, cPicture
   LOCAL cNombre  := Space( 50 )
   LOCAL cPais    := Space( 30 )
   LOCAL clocali  := Space( 50 )
   LOCAL lSeek    := .F.
   LOCAL lFecha   := .F.
   LOCAL aBrowse := {}

   oApp():nEdit ++

   DEFINE DIALOG oDlg RESOURCE 'UT_BUSCA_' + oApp():cLanguage OF oParent  ;
      TITLE i18n( "Búsqueda de proveedores de ingredientes" )
   oDlg:SetFont( oApp():oFont )

   IF nOrder == 1
      REDEFINE SAY PROMPT i18n( "Introduzca el nombre del proveedor" ) ID 20 OF oDlg
      REDEFINE SAY PROMPT i18n( "Nombre" ) + ":" ID 21 OF Odlg
      cGet     := cNombre
   ELSEIF nOrder == 2
      REDEFINE SAY PROMPT i18n( "Introduzca el pais del proveedor" ) ID 20 OF oDlg
      REDEFINE SAY PROMPT i18n( "Pais" ) + ":" ID 21 OF Odlg
      cGet     := cPais
   ELSEIF nOrder == 3
      REDEFINE SAY PROMPT i18n( "Introduzca la localidad del proveedor" ) ID 20 OF oDlg
      REDEFINE SAY PROMPT i18n( "localidad" ) + ":" ID 21 OF Odlg
      cGet     := clocali
   ENDIF

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
         {|| PrWildSeek( nOrder, cGet, aBrowse ) } )
      IF Len( aBrowse ) == 0
         MsgStop( "No se ha encontrado ningun proveedor." )
      ELSE
         PrEncontrados( aBrowse, oApp():oDlg )
      ENDIF
   ENDIF
   IF oCont != NIL
      RefreshCont( oCont, "PR" )
   ENDIF
	
   oApp():nEdit --
   oGrid:Refresh()
   oGrid:SetFocus( .T. )

   RETURN NIL
/*_____________________________________________________________________________*/
FUNCTION PrWildSeek( nOrder, cGet, aBrowse )

   LOCAL nRecno   := PR->( RecNo() )
	
   PR->( dbGoTop() )
   DO WHILE ! PR->( Eof() )
      DO CASE
      CASE nOrder == 1
         IF cGet $ Upper( PR->PrNombre )
            AAdd( aBrowse, { PR->PrNombre, PR->Prlocali, PR->PrAliment, PR->( RecNo() ) } )
         ENDIF
         PR->( dbSkip() )
      CASE nOrder == 2
         IF cGet $ Upper( PR->PrPais )
            AAdd( aBrowse, { PR->PrNombre, PR->Prlocali, PR->PrAliment, PR->( RecNo() ) } )
         ENDIF
         PR->( dbSkip() )
      CASE nOrder == 3
         IF cGet $ Upper( PR->Prlocali )
            AAdd( aBrowse, { PR->PrNombre, PR->Prlocali, PR->PrAliment, PR->( RecNo() ) } )
         ENDIF
         PR->( dbSkip() )
      ENDCASE

   ENDDO
   PR->( dbGoto( nRecno ) )
   // ordeno la tabla por el 1 elemento
   ASort( aBrowse,,, {|aAut1, aAut2| Upper( aAut1[ 1 ] ) < Upper( aAut2[ 1 ] ) } )

   RETURN NIL
/*_____________________________________________________________________________*/
	
FUNCTION PrEncontrados( aBrowse, oParent )

   LOCAL oDlg, oBrowse, oBtnOk, oBtnCancel, lOk
   LOCAL nRecno := PR->( RecNo() )
	
   DEFINE DIALOG oDlg RESOURCE "DLG_ENCONTRADOS" ;
      TITLE i18n( "Resultado de la búsqueda" ) ;
      OF oParent
   oDlg:SetFont( oApp():oFont )
	
   oBrowse := TXBrowse():New( oDlg )
   Ut_BrwRowConfig( oBrowse )

   oBrowse:SetArray( aBrowse, .F. )
   oBrowse:aCols[ 1 ]:cHeader := "Proveedor"
   oBrowse:aCols[ 2 ]:cHeader := "Localidad"
   oBrowse:aCols[ 3 ]:cHeader := "Ingredientes"
   oBrowse:aCols[ 1 ]:nWidth  := 340
   oBrowse:aCols[ 2 ]:nWidth  := 100
   oBrowse:aCols[ 3 ]:nWidth  := 100
   oBrowse:aCols[ 4 ]:Hide()
   oBrowse:aCols[ 1 ]:nHeadStrAlign := 0
   oBrowse:aCols[ 1 ]:nDataStrAlign := 0
   oBrowse:aCols[ 2 ]:nHeadStrAlign := 0
   oBrowse:aCols[ 2 ]:nDataStrAlign := 0
	
   oBrowse:CreateFromResource( 110 )
	
   PR->( dbGoto( aBrowse[ oBrowse:nArrayAt, 4 ] ) )
   AEval( oBrowse:aCols, {|oCol| oCol:bLDClickData := {|| PR->( dbGoto( aBrowse[ oBrowse:nArrayAt, 4 ] ) ), ;
      PrEdita( , 2,, oApp():oDlg ) } } )
   oBrowse:bKeyDown  := {| nKey| iif( nKey == VK_RETURN, ( PR->( dbGoto( aBrowse[ oBrowse:nArrayAt, 4 ] ) ), ;
      PrEdita( , 2,, oApp():oDlg ) ), ) }
   oBrowse:bChange   := {|| PR->( dbGoto( aBrowse[ oBrowse:nArrayAt, 4 ] ) ) }
   oBrowse:lHScroll  := .F.
   oDlg:oClient      := oBrowse
   oBrowse:nRowHeight := 20
	
   REDEFINE BUTTON oBtnOk ;
      ID IDOK OF oDlg     ;
      ACTION oDlg:End()
	
   REDEFINE BUTTON oBtnCancel ;
      ID IDCANCEL OF oDlg ;
      ACTION ( PR->( dbGoto( nRecno ) ), oDlg:End() )
	
   ACTIVATE DIALOG oDlg ;
      ON INIT DlgCenter( oDlg, oApp():oWndMain )
	
   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION PrClave( cProveed, oGet, nMode )

   // nMode    1 nuevo registro
   // 2 modificación de registro
   // 3 duplicación de registro
   // 4 clave ajena
   LOCAL lreturn  := .F.
   LOCAL nRecno   := PR->( RecNo() )
   LOCAL nOrder   := PR->( ordNumber() )
   LOCAL nArea    := Select()

   IF Empty( cProveed )
      IF nMode == 4
         RETURN .T.
      ELSE
         MsgStop( "Es obligatorio rellenar este campo." )
         RETURN .F.
      ENDIF
   ENDIF

   SELECT PR
   PR->( dbSetOrder( 1 ) )
   PR->( dbGoTop() )

   IF PR->( dbSeek( Upper( cProveed ) ) )
      DO CASE
      CASE nMode == 1 .OR. nMode == 3
         lreturn := .F.
         MsgStop( "Proveedor existente." )
      CASE nMode == 2
         IF PR->( RecNo() ) == nRecno
            lreturn := .T.
         ELSE
            lreturn := .F.
            MsgStop( "Proveedor existente." )
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
         IF MsgYesNo( "Proveedor inexistente. ¿ Desea darlo de alta ahora? ", 'Seleccione una opción' )
            lreturn := PrEdita( , 1, , , @cProveed )
         ELSE
            lreturn := .F.
         ENDIF
      ENDIF
   ENDIF

   IF lreturn == .F.
      oGet:cText( Space( 50 ) )
   ENDIF

   PR->( dbSetOrder( nOrder ) )
   PR->( dbGoto( nRecno ) )

   SELECT ( nArea )

   RETURN lreturn
/*_____________________________________________________________________________*/

FUNCTION PrImprime( oGrid, oParent )

   LOCAL nRecno   := PR->( RecNo() )
   LOCAL nOrder   := PR->( ordSetFocus() )
   LOCAL aCampos  := { "PRNOMBRE", "PRNOTAS", "PRCif", "PRDIRECC", "PRTELEFONO", ;
      "PRFAX", "PRlocalI", "PRPAIS", "PREMAIL", "PRURL" }
   LOCAL aTitulos := { "Nombre", "Notas", "Cif", "Dirección", "Teléfono", ;
      "Fax", "localidad", "Pais", "Email", "URL" }
   LOCAL aWidth   := { 50, 99, 24, 50, 40, 40, 40, 40, 40, 40 }
   LOCAL aShow    := { .T., .T., .T., .T., .T., .T., .T., .T., .T., .T. }
   LOCAL aPicture := { "NO", "NO", "NO", "NO", "NO", "NO", "NO", "NO", "NO", "NO" }
   LOCAL aTotal   := { .F., .F., .F., .F., .F., .F., .F., .F., .F., .F. }
   LOCAL hBmp     := LoadBitmap( 0, 32760 )
   LOCAL nLen     := 10 // nº de campos a mostrar
   LOCAL oInforme

   oApp():nEdit ++
   oInforme := TInforme():New( aCampos, aTitulos, aWidth, aShow, aPicture, aTotal, "PR" )
   oInforme:Dialog()

   REDEFINE RADIO oInforme:oRadio VAR oInforme:nRadio ID 300 OF oInforme:oFld:aDialogs[ 1 ] ;
      ON CHANGE oInforme:Change()

   oInforme:Folders()

   IF oInforme:Activate()
      SELECT PR
      PR->( dbGoTop() )
      oInforme:Report()
      ACTIVATE REPORT oInforme:oReport ;
         ON END ( oInforme:oReport:StartLine(), oInforme:oReport:EndLine(), oInforme:oReport:StartLine(), ;
         oInforme:oReport:Say( 1, 'Total proveedores: ' + Tran( oInforme:oReport:nCounter, '@E 999,999' ), 1 ), ;
         oInforme:oReport:EndLine() )
      oInforme:End( .T. )
      PR->( ordSetFocus( nOrder ) )
      PR->( dbGoto( nRecno ) )
   ENDIF
   oApp():nEdit --
   oGrid:Refresh()
   oGrid:SetFocus( .T. )

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION PrEjemplares( oGrid, oParent )

   LOCAL oDlg, oBrowse, oCol
   LOCAL cProveed := PR->PrNombre
   LOCAL i
   LOCAL cTitle := 'Ingredientes del proveedor: ' + cProveed

   oApp():nEdit ++
   AL->( dbSetOrder( 5 ) )
   AL->( dbSetFilter( {|| Upper( RTrim( AL->AlProveed ) ) == Upper( RTrim( cProveed ) ) } ) )
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

   SELECT PR
   oGrid:Refresh()
   oGrid:SetFocus( .T. )
   oApp():nEdit --

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION PrSort( nOrden, oCont )

   LOCAL nRecno := PR->( RecNo() )
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
   PR->( dbSetOrder( norden ) )
   iif( PR->( Eof() ), PR->( dbGoTop() ), )
   Refreshcont( ocont, "PR" )
   PR->( dbGoto( nRecno ) )
   oApp():oGrid:Refresh( .T. )
   oApp():oGrid:SetFocus( .T. )

   RETURN NIL

FUNCTION PrList( aList, cData, oSelf )

   LOCAL aNewList := {}

   PR->( dbSetOrder( 1 ) )
   PR->( dbGoTop() )
   WHILE ! PR->( Eof() )
      IF At( Upper( cdata ), Upper( PR->PrNombre ) ) != 0 // UPPER( SubStr( oApp():amaterias[i,1], 1, Len( cData ) ) ) == UPPER( cData )
         AAdd( aNewList, { PR->PrNombre } )
      ENDIF
      PR->( dbSkip() )
   ENDDO

   RETURN aNewlist
