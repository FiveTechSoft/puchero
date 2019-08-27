#include "FiveWin.ch"
#include "Report.ch"
#include "xBrowse.ch"
#include "vmenu.ch"
#include "splitter.ch"

STATIC oReport

FUNCTION Autores()

   LOCAL oBar, oCol, oCont
   LOCAL aBrowse
   LOCAL cState := GetPvProfString( "Browse", "AuState", "", oApp():cInifile )
   LOCAL nOrder := Max( Val( GetPvProfString( "Browse", "AuOrder", "1", oApp():cInifile ) ), 1 )
   LOCAL nRecno := Val( GetPvProfString( "Browse", "AuRecno", "1", oApp():cInifile ) )
   LOCAL nSplit := Val( GetPvProfString( "Browse", "AuSplit", "102", oApp():cInifile ) )
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

   SELECT AU
   oApp():oDlg := TFsdi():New( oApp():oWndMain )
   oApp():oDlg:cTitle := i18n( 'Gestión de autores de recetas' )
   oApp():oWndMain:oClient := oApp():oDlg
   oApp():oDlg:NewGrid( nSplit )

   Ut_BrwRowConfig( oApp():oGrid )

   oApp():oGrid:cAlias := "AU"

   oCol := oApp():oGrid:AddCol()
   oCol:bLClickHeader := {|| AuSort( 1, oCont ) }
   oCol:Cargo := 1
   oCol:AddResource( "16_SORT_A" )
   oCol:AddResource( "16_SORT_B" )
   oCol:nHeadBmpNo    := iif( nOrder == 1, 1, 2 )
   oCol:nHeadBmpAlign := AL_RIGHT
   oCol:bStrData := {|| AU->AuNombre }
   oCol:cHeader  := i18n( "Nombre" )
   oCol:nWidth   := 190
	
   oCol := oApp():oGrid:AddCol()
   oCol:bLClickHeader := {|| PrSort( 2, oCont ) }
   oCol:Cargo := 2
   oCol:AddResource( "16_SORT_A" )
   oCol:AddResource( "16_SORT_B" )
   oCol:nHeadBmpNo    := iif( nOrder == 2, 1, 2 )
   oCol:nHeadBmpAlign := AL_RIGHT
   oCol:bStrData := {|| AU->AuPais }
   oCol:cHeader  := i18n( "País" )
   oCol:nWidth   := 120

   oCol := oApp():oGrid:AddCol()
   oCol:bLClickHeader := {|| PrSort( 3, oCont ) }
   oCol:Cargo := 3
   oCol:AddResource( "16_SORT_A" )
   oCol:AddResource( "16_SORT_B" )
   oCol:nHeadBmpNo    := iif( nOrder == 3, 1, 2 )
   oCol:nHeadBmpAlign := AL_RIGHT
   oCol:bStrData := {|| AU->AuURL }
   oCol:cHeader  := i18n( "Sitio web" )
   oCol:nWidth   := 190

   ADD oCol TO oApp():oGrid DATA AU->AuRecetas ;
      HEADER "Recetas" PICTURE "@E 999,999" ;
      TOTAL 0 WIDTH 90


   aBrowse   := { { {|| AU->AuDirecc }, i18n( "Dirección" ), 120 }, ;
      { {|| AU->Aulocali }, i18n( "localidad" ), 120 }, ;
      { {|| AU->AuTelefono }, i18n( "Telefono" ), 120 }, ;
      { {|| AU->AuEmail }, i18n( "E-mail" ), 150 } }

   FOR i := 1 TO Len( aBrowse )
      oCol := oApp():oGrid:AddCol()
      oCol:bStrData := aBrowse[ i, 1 ]
      oCol:cHeader  := aBrowse[ i, 2 ]
      oCol:nWidth   := aBrowse[ i, 3 ]
   NEXT

   FOR i := 1 TO Len( oApp():oGrid:aCols )
      oCol := oApp():oGrid:aCols[ i ]
      oCol:bLDClickData  := {|| AuEdita( oApp():oGrid, 2, oCont, oApp():oDlg ) }
   NEXT

   oApp():oGrid:SetRDD()
   oApp():oGrid:CreateFromCode()
   oApp():oGrid:bChange  := {|| RefreshCont( oCont, "AU" ), oApp():ogrid:Maketotals() }
   oApp():oGrid:bKeyDown := {| nKey| AuTecla( nKey, oApp():oGrid, oCont, oApp():oDlg ) }
   oApp():oGrid:nRowHeight  := 21
   oApp():oGrid:RestoreState( cState )
   oApp():oGrid:lFooter := .T.
   oApp():oGrid:bClrFooter := {|| { CLR_HRED, GetSysColor( 15 ) } }
   oApp():oGrid:MakeTotals()

   AU->( dbSetOrder( nOrder ) )
   IF nRecNo < AU->( LastRec() ) .AND. nRecno != 0
      AU->( dbGoto( nRecno ) )
   ELSE
      AU->( dbGoTop() )
   ENDIF

   @ 02, 05 VMENU oCont SIZE nSplit - 10, 18 OF oApp():oDlg  ;
      COLOR CLR_BLACK, GetSysColor( 15 )       ;
      FILLED  ;  // BORDER
   COLORSELECT 0, CLR_WHITE ;
      HEIGHT ITEM 22

   DEFINE TITLE OF oCont ;
      CAPTION tran( AU->( ordKeyNo() ), '@E 999,999' ) + " / " + tran( AU->( ordKeyCount() ), '@E 999,999' ) ;// strZero( RE->( ordKeyCount() ), 6 ) ;
   HEIGHT 25 ;
      COLOR GetSysColor( 9 ), oApp():nClrBar ;
      IMAGE "BB_AUTOR"

   @ 24, 05 VMENU oBar SIZE nSplit - 10, 180 OF oApp():oDlg  ;
      COLOR CLR_BLACK, GetSysColor( 15 )       ;
      HEIGHT ITEM 22 XBOX
   oBar:nClrBox := Min( GetSysColor( 13 ), GetSysColor( 14 ) )

   DEFINE TITLE OF oBar ;
      CAPTION "Autores" ;
      HEIGHT 24 ;
      COLOR GetSysColor( 9 ), oApp():nClrBar ;
      OPENCLOSE

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Nuevo"              ;
      IMAGE "16_NUEVO"             ;
      ACTION AuEdita( oApp():oGrid, 1, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Modificar"          ;
      IMAGE "16_MODIF"             ;
      ACTION AuEdita( oApp():oGrid, 2, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Duplicar"           ;
      IMAGE "16_DUPLICA"           ;
      ACTION AuEdita( oApp():oGrid, 3, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Borrar"             ;
      IMAGE "16_BORRAR"            ;
      ACTION AuBorra( oApp():oGrid, oCont );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Agrupar autores"    ;
      IMAGE "16_AGRUPA"            ;
      ACTION AuAgrupa( oApp():oGrid, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Buscar"             ;
      IMAGE "16_BUSCA"             ;
      ACTION AuBusca( oApp():oGrid,, oCont, oApp():oDlg )  ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Imprimir"           ;
      IMAGE "16_IMPRIMIR"          ;
      ACTION AuImprime( oApp():oGrid, oApp():oDlg )   ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Ver recetas"        ;
      IMAGE "16_RECETAS"        ;
      ACTION AuEjemplares( oApp():oGrid, oApp():oDlg ) ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Visitar sitio web"  ;
      IMAGE "16_INTERNET"          ;
      ACTION GoWeb( AU->AuUrl )      ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Enviar e-mail"      ;
      IMAGE "16_EMAIL"             ;
      ACTION GoMail( AU->AuEmail )   ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Enviar a Excel"     ;
      IMAGE "16_EXCEL"             ;
      ACTION ( CursorWait(),  Ut_ExportXLS( oApp():oGrid, "Autores" ), CursorArrow() );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Configurar rejilla" ;
      IMAGE "16_GRID"              ;
      ACTION Ut_BrwColConfig( oApp():oGrid, "AuState" ) ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Salir"              ;
      IMAGE "16_SALIR"             ;
      ACTION oApp():oDlg:End()              ;
      LEFT 10

   @ oApp():oDlg:nGridBottom, nSplit + 2 TABS oApp():oTab ;
      OPTION nOrder SIZE oApp():oWndMain:nWidth() -80, 12 PIXEL OF oApp():oDlg ;
      ITEMS ' Autor ', ' Pais ', ' Sitio web ';
      ACTION AuSort( oApp():otab:noption, oCont )


   oApp():oDlg:NewSplitter( nSplit, oCont, oBar )

   ACTIVATE DIALOG oApp():oDlg NOWAIT ;
      ON INIT ( ResizeWndMain(), oApp():oGrid:SetFocus() );
      VALID ( oApp():oGrid:nLen := 0, ;
      WritePProString( "Browse", "AuState", oApp():oGrid:SaveState(), oApp():cInifile ), ;
      WritePProString( "Browse", "AuOrder", LTrim( Str( AU->( ordNumber() ) ) ), oApp():cInifile ), ;
      WritePProString( "Browse", "AuRecno", LTrim( Str( AU->( RecNo() ) ) ), oApp():cInifile ), ;
      WritePProString( "Browse", "AuSplit", LTrim( Str( oApp():oSplit:nleft / 2 ) ), oApp():cInifile ), ;
      oBar:End(), dbCloseAll(), oApp():oDlg := NIL, oApp():oGrid := NIL, oApp():oTab := NIL, .T. )

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION AuEdita( oGrid, nMode, oCont, oParent, cAutor )

   LOCAL oDlg, oFld, oBmp
   LOCAL aTitle := { i18n( "Añadir autor" ), ;
      i18n( "Modificar autor" ), ;
      i18n( "Duplicar autor" ) }
   LOCAL aGet[ 10 ]
   LOCAL cAunombre, ;
      cAuNotas, ;
      cAudirecc, ;
      cAulocali, ;
      cAutelefono, ;
      cAuPais, ;
      cAuemail, ;
      cAuurl

   LOCAL nRecPtr := AU->( RecNo() )
   LOCAL nOrden  := AU->( ordNumber() )
   LOCAL nRecAdd
   LOCAL lDuplicado
   LOCAL lreturn := .F.

   IF AU->( Eof() ) .AND. nMode != 1
      RETURN NIL
   ENDIF

   oApp():nEdit ++

   IF nMode == 1
      AU->( dbAppend() )
      nRecAdd := AU->( RecNo() )
   ENDIF

   cAunombre  := iif( nMode == 1 .AND. cAutor != nil, cAutor, Au->Aunombre )
   cAudirecc  := Au->Audirecc
   cAulocali  := Au->Aulocali
   cAutelefono := Au->Autelefono
   cAuPais    := Au->AuPais
   cAuemail   := Au->Auemail
   cAuurl     := Au->Auurl + Space( 80 -Len( Au->Auurl ) )
   cAunotas   := Au->Aunotas

   IF nMode == 3
      AU->( dbAppend() )
      nRecAdd := AU->( RecNo() )
   ENDIF

   DEFINE DIALOG oDlg RESOURCE "AU_EDIT_" + oApp():cLanguage OF oParent;
      TITLE aTitle[ nMode ]
   oDlg:SetFont( oApp():oFont )

   REDEFINE GET aGet[ 1 ] VAR cAuNombre  ;
      ID 101 OF oDlg UPDATE            ;
      VALID AuClave( cAuNombre, aGet[ 1 ], nMode )

   REDEFINE GET aGet[ 2 ] VAR cAuDirecc  ;
      ID 102 OF oDlg UPDATE

   REDEFINE GET aGet[ 3 ] VAR cAulocali  ;
      ID 103 OF oDlg UPDATE

   REDEFINE GET aGet[ 4 ] VAR cAupais    ;
      ID 104 OF oDlg UPDATE

   REDEFINE GET aGet[ 5 ] VAR cAuTelefono;
      ID 105 OF oDlg UPDATE

   REDEFINE GET aGet[ 06 ] VAR cAuemail ;
      ID 106 OF oDlg

   REDEFINE BUTTON aGet[ 09 ]   ;
      ID 111 OF oDlg          ;
      ACTION GoMail( cAuEmail )
   aGet[ 09 ]:cTooltip := i18n( "enviar e-mail" )

   REDEFINE GET aGet[ 7 ] VAR cAuURL    ;
      ID 107 OF oDlg

   REDEFINE BUTTON aGet[ 10 ]   ;
      ID 112 OF oDlg          ;
      ACTION GoWeb( cAuUrl )
   aGet[ 10 ]:cTooltip := i18n( "visitar sitio web" )

   REDEFINE GET aGet[ 8 ] VAR cAuNotas   ;
      MULTILINE ID 108 OF oDlg UPDATE

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
      /* ___ actualizo el nombre del autor en las recetas _____________________*/
      IF nMode == 2
         IF RTrim( cAuNombre ) != RTrim( AU->AuNombre )
            SELECT RE
            RE->( dbGoTop() )
            REPLACE RE->ReAutor     ;
               WITH cAuNombre       ;
               FOR Upper( RTrim( RE->ReAutor ) ) == Upper( RTrim( AU->AuNombre ) )
         ENDIF
         IF RTrim( cAuEmail ) != RTrim( AU->AuEmail )
            SELECT RE
            RE->( dbGoTop() )
            REPLACE RE->ReEmail     ;
               WITH cAuEmail        ;
               FOR Upper( RTrim( RE->ReAutor ) ) == Upper( RTrim( cAuNombre ) )
         ENDIF
         IF RTrim( cAuPais ) != RTrim( AU->AuPais )
            SELECT RE
            RE->( dbGoTop() )
            REPLACE RE->RePais      ;
               WITH cAuPais         ;
               FOR Upper( RTrim( RE->ReAutor ) ) == Upper( RTrim( cAuNombre ) )
         ENDIF
      ENDIF

      /* ___ guardo el registro _______________________________________________*/
      IF nMode == 2
         AU->( dbGoto( nRecPtr ) )
      ELSE
         AU->( dbGoto( nRecAdd ) )
      ENDIF
      REPLACE Au->Aunombre   WITH cAunombre
      REPLACE Au->Audirecc   WITH cAudirecc
      REPLACE Au->Aulocali   WITH cAulocali
      REPLACE Au->Autelefono WITH cAutelefono
      REPLACE Au->Aupais     WITH cAupais
      REPLACE Au->Auemail    WITH cAuemail
      REPLACE Au->Auurl      WITH cAuurl
      REPLACE Au->Aunotas    WITH cAunotas
      AU->( dbCommit() )
      IF cAutor != nil
         cAutor := AU->AuNombre
      ENDIF
   ELSE

      IF nMode == 1 .OR. nMode == 3

         AU->( dbGoto( nRecAdd ) )
         AU->( dbDelete() )
         AU->( DbPack() )
         AU->( dbGoto( nRecPtr ) )

      ENDIF

   ENDIF

   SELECT AU

   IF oCont != nil
      RefreshCont( oCont, "AU" )
   ENDIF
   IF oGrid != nil
      oGrid:Refresh()
      oGrid:SetFocus( .T. )
   ENDIF
   oApp():nEdit --

   RETURN lreturn
/*_____________________________________________________________________________*/

FUNCTION AuBorra( oGrid, oCont )

   LOCAL nRecord := AU->( RecNo() )
   LOCAL nNext

   oApp():nEdit ++

   IF msgYesNo( i18n( "¿ Está seguro de querer borrar este autor ?" ) + CRLF + ;
         ( Trim( AU->AuNombre ) ), 'Seleccione una opción' )
      AU->( dbSkip() )
      nNext := AU->( RecNo() )
      AU->( dbGoto( nRecord ) )

      AU->( dbDelete() )
      AU->( DbPack() )
      AU->( dbGoto( nNext ) )
      IF AU->( Eof() ) .OR. nNext == nRecord
         AU->( dbGoBottom() )
      ENDIF
   ENDIF

   IF oCont != nil
      RefreshCont( oCont, "AU" )
   ENDIF

   oApp():nEdit --
   oGrid:Refresh( .T. )
   oGrid:SetFocus( .T. )

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION AuTecla( nKey, oGrid, oCont, oDlg )

   DO CASE
   CASE nKey == VK_RETURN
      AuEdita( oGrid, 2, oCont, oDlg )
   CASE nKey == VK_INSERT
      AuEdita( oGrid, 1, oCont, oDlg )
   CASE nKey == VK_DELETE
      AuBorra( oGrid, oCont )
   CASE nKey == VK_ESCAPE
      oDlg:End()
   OTHERWISE
      IF nKey >= 96 .AND. nKey <= 105
         AuBusca( oGrid, Str( nKey - 96, 1 ), oCont, oDlg )
      ELSEIF HB_ISSTRING( Chr( nKey ) )
         AuBusca( oGrid, Chr( nKey ), oCont, oDlg )
      ENDIF
   ENDCASE

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION AuAgrupa( oGrid, oParent )

   LOCAL oDlg, oCombo
   LOCAL cTitle := i18n( "Agrupar autores" )
   LOCAL aSay[ 4 ]

   LOCAL nRecno      := AU->( RecNo() )
   LOCAL nOrden      := AU->( ordNumber() )
   LOCAL nReRecno    := RE->( RecNo() )
   LOCAL nReOrden    := RE->( ordNumber() )

   LOCAL cAutor      := AU->AuNombre
   LOCAL cAuEmail, cAuPais
   LOCAL nAuRecetas  := AU->AuRecetas

   LOCAL nRecAdd
   LOCAL lDuplicado
   LOCAL aAutores    := {}
   LOCAL cNewAutor

   oApp():nEdit ++

   AU->( dbGoTop() )
   DO WHILE ! AU->( Eof() )
      AAdd( aAutores, AU->AuNombre )
      AU->( dbSkip() )
   ENDDO
   cNewAutor := aAutores[ 1 ]

   DEFINE DIALOG oDlg RESOURCE "UT_AGRUPA" TITLE cTitle OF oParent
   oDlg:SetFont( oApp():oFont )

   REDEFINE SAY aSay[ 1 ]          ;
      PROMPT "La agrupación de autores permite asignar a recetas existentes un nuevo autor ya existente." ;
      ID 10 OF oDlg COLOR CLR_BLACK, CLR_WHITE

   REDEFINE SAY aSay[ 2 ]          ;
      PROMPT "Autor viejo:"      ;
      ID 11 OF oDlg

   REDEFINE SAY aSay[ 3 ]          ;
      PROMPT cAutor              ;
      COLOR CLR_HBLUE, GetSysColor( 15 ) ;
      ID 12 OF oDlg

   REDEFINE SAY aSay[ 4 ]          ;
      PROMPT "Nuevo autor:"      ;
      ID 13 OF oDlg

   REDEFINE COMBOBOX oCombo      ;
      VAR cNewAutor              ;
      ITEMS aAutores             ;
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
      /* ___ actualizo el tipo de autor en la receta___________________________*/
      AU->( dbSetOrder( 1 ) )
      AU->( dbSeek( Upper( cNewAutor ) ) )
      cAuPais  := AU->AuPais
      cAuEmail := AU->AuEmail
      SELECT RE
      RE->( dbSetOrder( 0 ) )
      RE->( dbGoTop() )
      REPLACE RE->ReAutor     ;
         WITH cNewAutor       ;
         FOR Upper( RTrim( RE->ReAutor ) ) == Upper( RTrim( cAutor ) )
      RE->( dbGoTop() )
      REPLACE RE->RePais      ;
         WITH cAuPais         ;
         FOR Upper( RTrim( RE->ReAutor ) ) == Upper( RTrim( cNewAutor ) )
      RE->( dbGoTop() )
      REPLACE RE->ReEmail     ;
         WITH cAuEmail        ;
         FOR Upper( RTrim( RE->ReAutor ) ) == Upper( RTrim( cNewAutor ) )
      /* ___ borro el autor y acumulo el número de recetas ___________________*/
      SELECT AU
      AU->( dbSetOrder( 1 ) )
      AU->( dbGoto( nRecno ) )
      AU->( dbDelete() )
      AU->( DbPack() )
      AU->( dbGoTop() )
      AU->( dbSeek( Upper( cNewAutor ) ) )
      REPLACE AU->AuRecetas  WITH AU->AuRecetas + nAuRecetas
      AU->( dbCommit() )
   ELSE
      AU->( dbGoto( nRecno ) )
   ENDIF

   SELECT AU
   oGrid:Refresh( .T. )
   oGrid:SetFocus( .T. )
   oApp():nEdit --

   RETURN NIL

/*_____________________________________________________________________________*/

FUNCTION AuSeleccion( cAutor, oControl1, oControl2, oControl3, oParent, oVItem )

   LOCAL oDlg, oBrowse, oCol, oBtnAceptar, oBtnCancel, oBNew, oBMod, oBDel, oBBus
   LOCAL lOk    := .F.
   LOCAL nRecno := AU->( RecNo() )
   LOCAL nOrder := AU->( ordNumber() )
   LOCAL nArea  := Select()
   LOCAL aPoint := iif( oControl1 != NIL, AdjustWnd( oControl1, 271 * 2, 150 * 2 ), { 1.3 * oVItem:nTop(), oApp():oGrid:nLeft } )

   DEFINE DIALOG oDlg RESOURCE 'UT_AJENA1_' + oApp():cLanguage OF oParent;
      TITLE "Selección de autores"
   oDlg:SetFont( oApp():oFont )

   // siempre tengo ordenado por nombre

   SELECT AU
   AU->( dbSetOrder( 1 ) )
   AU->( dbGoTop() )

   IF ! AU->( dbSeek( cAutor ) )
      AU->( dbGoTop() )
   ENDIF

   oBrowse := TXBrowse():New( oDlg )
   Ut_BrwRowConfig( oBrowse )
   oBrowse:cAlias := "AU"

   oCol := oBrowse:AddCol()
   oCol:bStrData := {|| AU->AuNombre }
   oCol:cHeader  := "Autor"
   oCol:nWidth   := 160
   oCol:bLDClickData  := {|| ( lOk := .T., oDlg:End() )   }
   oBrowse:SetRDD()
   oBrowse:CreateFromResource( 110 )
   oBrowse:bKeyDown := {| nKey| AuSeTecla( nKey, oBrowse, oDlg, oBtnAceptar ) }

   REDEFINE BUTTON oBNew   ;
      ID 410 OF oDlg       ;
      ACTION AuEdita( oBrowse, 1,, oDlg )

   REDEFINE BUTTON oBMod   ;
      ID 411 OF oDlg       ;
      ACTION AuEdita( oBrowse, 2,, oDlg )

   REDEFINE BUTTON oBDel   ;
      ID 412 OF oDlg       ;
      ACTION AuBorra( oBrowse, )

   REDEFINE BUTTON oBBus   ;
      ID 413 OF oDlg       ;
      ACTION AuBusca( oBrowse, ,, oDlg )

   REDEFINE BUTTON oBtnAceptar   ;
      ID IDOK OF oDlg            ;
      ACTION ( lOk := .T., oDlg:End() )

   REDEFINE BUTTON oBtnCancel    ;
      ID IDCANCEL OF oDlg        ;
      ACTION ( lOk := .F., oDlg:End() )

   ACTIVATE DIALOG oDlg CENTERED       ;
      ON PAINT oDlg:Move( aPoint[ 1 ], aPoint[ 2 ],,, .T. )

   IF lOK
      cAutor := AU->AuNombre
      IF oControl1 != NIL
         oControl1:cText := AU->AuNombre
         IF oControl2 != NIL
            oControl2:cText := AU->AuEmail
         ENDIF
         IF oControl3 != NIL
            oControl3:cText := AU->AuPais
         ENDIF
      ENDIF
   ENDIF

   AU->( dbSetOrder( nOrder ) )
   AU->( dbGoto( nRecno ) )

   SELECT ( nArea )

   RETURN NIL
/*_____________________________________________________________________________*/
FUNCTION AuSeTecla( nKey, oGrid, oDlg, oBtn )

   DO CASE
   CASE nKey == VK_RETURN
      oBtn:Click()
   CASE nKey == VK_ESCAPE
      oDlg:End()
   OTHERWISE
      IF nKey >= 96 .AND. nKey <= 105
         AuBusca( oGrid, Str( nKey - 96, 1 ),, oDlg )
      ELSEIF HB_ISSTRING( Chr( nKey ) )
         AuBusca( oGrid, Chr( nKey ),, oDlg )
      ENDIF
   ENDCASE

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION AuBusca( oGrid, cChr, oCont, oParent )

   LOCAL nOrder   := AU->( ordNumber() )
   LOCAL nRecno   := AU->( RecNo() )
   LOCAL oDlg, oGet, cGet, cPicture
   LOCAL cNombre  := Space( 50 )
   LOCAL cPais    := Space( 30 )
   LOCAL cUrl     := Space( 50 )
   LOCAL lSeek    := .F.
   LOCAL lFecha   := .F.
   LOCAL aBrowse := {}

   oApp():nEdit ++

   DEFINE DIALOG oDlg RESOURCE 'UT_BUSCA_' + oApp():cLanguage OF oParent  ;
      TITLE i18n( "Búsqueda de autores de recetas" )
   oDlg:SetFont( oApp():oFont )

   IF nOrder == 1
      REDEFINE SAY PROMPT i18n( "Introduzca el nombre del autor" ) ID 20 OF oDlg
      REDEFINE SAY PROMPT i18n( "Nombre" ) + ":" ID 21 OF Odlg
      cGet     := cNombre
   ELSEIF nOrder == 2
      REDEFINE SAY PROMPT i18n( "Introduzca el pais del autor" ) ID 20 OF oDlg
      REDEFINE SAY PROMPT i18n( "Pais" ) + ":" ID 21 OF Odlg
      cGet     := cPais
   ELSEIF nOrder == 3
      REDEFINE SAY PROMPT i18n( "Introduzca el sitio web del autor" ) ID 20 OF oDlg
      REDEFINE SAY PROMPT i18n( "Sitio web" ) + ":" ID 21 OF Odlg
      cGet     := cURL
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
         {|| AuWildSeek( nOrder, cGet, aBrowse ) } )
      IF Len( aBrowse ) == 0
         MsgStop( "No se ha encontrado ningún autor." )
      ELSE
         AuEncontrados( aBrowse, oApp():oDlg )
      ENDIF
   ENDIF
   IF oCont != NIL
      RefreshCont( oCont, "Au" )
   ENDIF
	
   oApp():nEdit --
   oGrid:Refresh()
   oGrid:SetFocus( .T. )

   RETURN NIL
/*_____________________________________________________________________________*/
FUNCTION AuWildSeek( nOrder, cGet, aBrowse )

   LOCAL nRecno   := AU->( RecNo() )
	
   AU->( dbGoTop() )
   DO WHILE ! AU->( Eof() )
      DO CASE
      CASE nOrder == 1
         IF cGet $ Upper( AU->AuNombre )
            AAdd( aBrowse, { AU->AuNombre, AU->AuPais, AU->AuRecetas, AU->( RecNo() ) } )
         ENDIF
         AU->( dbSkip() )
      CASE nOrder == 2
         IF cGet $ Upper( AU->AuPais )
            AAdd( aBrowse, { AU->AuNombre, AU->AuPais, AU->AuRecetas, AU->( RecNo() ) } )
         ENDIF
         AU->( dbSkip() )
      CASE nOrder == 3
         IF cGet $ Upper( AU->AuURL )
            AAdd( aBrowse, { AU->AuNombre, AU->AuPais, AU->AuRecetas, AU->( RecNo() ) } )
         ENDIF
         AU->( dbSkip() )
      ENDCASE

   ENDDO
   AU->( dbGoto( nRecno ) )
   // ordeno la tabla por el 1 elemento
   ASort( aBrowse,,, {| aAut1, aAut2| Upper( aAut1[ 1 ] ) < Upper( aAut2[ 1 ] ) } )

   RETURN NIL
/*_____________________________________________________________________________*/
	
FUNCTION AuEncontrados( aBrowse, oParent )

   LOCAL oDlg, oBrowse, oBtnOk, oBtnCancel, lOk
   LOCAL nRecno := AU->( RecNo() )
	
   DEFINE DIALOG oDlg RESOURCE "DLG_ENCONTRADOS" ;
      TITLE i18n( "Resultado de la búsqueda" ) ;
      OF oParent
   oDlg:SetFont( oApp():oFont )
	
   oBrowse := TXBrowse():New( oDlg )
   Ut_BrwRowConfig( oBrowse )

   oBrowse:SetArray( aBrowse, .F. )
   oBrowse:aCols[ 1 ]:cHeader := "Autor"
   oBrowse:aCols[ 2 ]:cHeader := "País"
   oBrowse:aCols[ 3 ]:cHeader := "Recetas"
   oBrowse:aCols[ 1 ]:nWidth  := 340
   oBrowse:aCols[ 2 ]:nWidth  := 100
   oBrowse:aCols[ 3 ]:nWidth  := 100
   oBrowse:aCols[ 4 ]:Hide()
   oBrowse:aCols[ 1 ]:nHeadStrAlign := 0
   oBrowse:aCols[ 1 ]:nDataStrAlign := 0
   oBrowse:aCols[ 2 ]:nHeadStrAlign := 0
   oBrowse:aCols[ 2 ]:nDataStrAlign := 0
	
   oBrowse:CreateFromResource( 110 )
	
   AU->( dbGoto( aBrowse[ oBrowse:nArrayAt, 4 ] ) )
   AEval( oBrowse:aCols, {| oCol| oCol:bLDClickData := {|| AU->( dbGoto( aBrowse[ oBrowse:nArrayAt, 4 ] ) ), ;
      AuEdita( , 2,, oApp():oDlg ) } } )
   oBrowse:bKeyDown  := {| nKey| iif( nKey == VK_RETURN, ( AU->( dbGoto( aBrowse[ oBrowse:nArrayAt, 4 ] ) ), ;
      AuEdita( , 2,, oApp():oDlg ) ), ) }
   oBrowse:bChange   := {|| AU->( dbGoto( aBrowse[ oBrowse:nArrayAt, 4 ] ) ) }
   oBrowse:lHScroll  := .F.
   oDlg:oClient      := oBrowse
   oBrowse:nRowHeight := 20
	
   REDEFINE BUTTON oBtnOk ;
      ID IDOK OF oDlg     ;
      ACTION oDlg:End()
	
   REDEFINE BUTTON oBtnCancel ;
      ID IDCANCEL OF oDlg ;
      ACTION ( AU->( dbGoto( nRecno ) ), oDlg:End() )
	
   ACTIVATE DIALOG oDlg ;
      ON INIT DlgCenter( oDlg, oApp():oWndMain )
	
   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION AuClave( cAutor, oGet1, nMode, oGet2, oGet3 )

   // nMode    1 nuevo registro
   // 2 modificación de registro
   // 3 duplicación de registro
   // 4 clave ajena
   LOCAL lreturn  := .F.
   LOCAL nRecno   := AU->( RecNo() )
   LOCAL nOrder   := AU->( ordNumber() )
   LOCAL nArea    := Select()

   IF Empty( cAutor )
      IF nMode == 4
         RETURN .T.
      ELSE
         MsgStop( "Es obligatorio rellenar este campo." )
         RETURN .F.
      ENDIF
   ENDIF

   SELECT AU
   AU->( dbSetOrder( 1 ) )
   AU->( dbGoTop() )

   IF AU->( dbSeek( Upper( cAutor ) ) )
      DO CASE
      CASE nMode == 1 .OR. nMode == 3
         lreturn := .F.
         MsgStop( "Autor existente." )
      CASE nMode == 2
         IF AU->( RecNo() ) == nRecno
            lreturn := .T.
         ELSE
            lreturn := .F.
            MsgStop( "Autor existente." )
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
         IF MsgYesNo( "Autor de recetas inexistente. ¿ Desea darlo de alta ahora? ", 'Seleccione una opción' )
            lreturn := AuEdita( , 1, , , @cAutor )
         ELSE
            lreturn := .F.
         ENDIF
      ENDIF
   ENDIF

   IF lreturn == .F.
      oGet1:cText( Space( 50 ) )
   ELSE
      IF oGet2 != nil
         oGet2:cText( AU->AuEmail )
      ENDIF
      IF oGet3 != nil
         oGet3:cText( AU->AuPais )
      ENDIF
   ENDIF

   AU->( dbSetOrder( nOrder ) )
   AU->( dbGoto( nRecno ) )

   SELECT ( nArea )

   RETURN lreturn

/*_____________________________________________________________________________*/

FUNCTION AuEjemplares( oGrid, oParent )

   LOCAL oDlg, oBrowse, oCol
   LOCAL cAutor   := AU->AuNombre
   LOCAL aEpoca   := { '0000', '0001', '0010', '0011', '0100', '0101', '0110', '0111', ;
      '1000', '1001', '1010', '1011', '1100', '1101', '1110', '1111' }
   LOCAL i
   LOCAL cTitle

   oApp():nEdit ++

   DEFINE DIALOG oDlg RESOURCE 'UT_EJEMPLARES'  ;
      TITLE 'Recetas de: ' + AU->AuNombre OF oParent
   oDlg:SetFont( oApp():oFont )

   SELECT RE
   RE->( dbSetOrder( 7 ) )
   RE->( dbSetFilter( {|| Trim( RE->ReAutor ) == Trim( cAutor ) } ) )
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
   oCol:cHeader       := i18n( "Dificultad" )
   oCol:bBmpData      := {|| Max( RE->ReDificu, 1 ) }
   oCol:nWidth        := 40
   oCol:nDataBmpAlign := 2

   oCol := oBrowse:AddCol()
   oCol:AddResource( "BR_CAL1C" )
   oCol:AddResource( "BR_CAL2C" )
   oCol:AddResource( "BR_CAL3C" )
   oCol:cHeader       := i18n( "Calorias" )
   oCol:bBmpData      := {|| Max( RE->ReCalori, 1 ) }
   oCol:nWidth        := 40
   oCol:nDataBmpAlign := 2

   oCol := oBrowse:AddCol()
   oCol:AddResource( "BR_PROP1" )
   oCol:AddResource( "BR_PROP2" )
   oCol:cHeader       := i18n( "Incorp." )
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

   SELECT AU
   oGrid:Refresh()
   oGrid:SetFocus( .T. )
   oApp():nEdit --

   RETURN NIL

/*_____________________________________________________________________________*/

FUNCTION AuImprime( oGrid, oParent )

   LOCAL nRecno   := AU->( RecNo() )
   LOCAL nOrder   := AU->( ordSetFocus() )
   LOCAL aCampos  := { "AUNOMBRE", "AUNOTAS", "AUDIRECC", "AUTELEFONO", ;
      "AUlocalI", "AUPAIS", "AUEMAIL", "AUURL", "AURECETAS" }
   LOCAL aTitulos := { "Autor", "Notas", "Dirección", "Teléfono", ;
      "localidad", "Pais", "e-mail", "Sitio web ", "Recetas" }
   LOCAL aWidth   := { 30, 50, 50, 50, 30, 20, 20, 20, 12 }
   LOCAL aShow    := { .T., .T., .T., .T., .T., .T., .T., .T., .T. }
   LOCAL aPicture := { "NO", "NO", "NO", "NO", "NO", "NO", "NO", "NO", "@E 99,999" }
   LOCAL aTotal   := { .F., .F., .F., .F., .F., .F., .F., .F., .T. }
   LOCAL oInforme

   oApp():nEdit ++

   oInforme := TInforme():New( aCampos, aTitulos, aWidth, aShow, aPicture, aTotal, "AU" )
   oInforme:Dialog()

   REDEFINE RADIO oInforme:oRadio VAR oInforme:nRadio ID 300, 301 OF oInforme:oFld:aDialogs[ 1 ] ;
      ON CHANGE oInforme:Change()

   oInforme:Folders()

   IF oInforme:Activate()
      SELECT AU
      IF oInforme:nRadio == 2
         AU->( ordSetFocus( 2 ) )
      ENDIF
      AU->( dbGoTop() )
      oInforme:Report()
      IF oInforme:nRadio == 1
         ACTIVATE REPORT oInforme:oReport ;
            ON END ( oInforme:oReport:StartLine(), oInforme:oReport:EndLine(), oInforme:oReport:StartLine(), ;
            oInforme:oReport:Say( 1, 'Total autores: ' + Tran( oInforme:oReport:nCounter, '@E 999,999' ), 1 ), ;
            oInforme:oReport:EndLine() )
      ELSEIF oInforme:nRadio == 2
         ACTIVATE REPORT oInforme:oReport ;
            ON END ( oInforme:oReport:StartLine(), oInforme:oReport:EndLine(), oInforme:oReport:StartLine(), ;
            oInforme:oReport:Say( 1, 'Total autores: ' + Tran( oInforme:oReport:nCounter, '@E 999,999' ), 1 ), ;
            oInforme:oReport:EndLine() )
      ENDIF
      oInforme:End( .T. )
      AU->( ordSetFocus( nOrder ) )
      AU->( dbGoto( nRecno ) )
   ENDIF
   oApp():nEdit --
   oGrid:Refresh()
   oGrid:SetFocus( .T. )

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION AuSort( nOrden, oCont )

   LOCAL nRecno := AU->( RecNo() )
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
   AU->( dbSetOrder( norden ) )
   AU->( dbGoto( nRecno ) )
   Refreshcont( ocont, "AU" )
   oApp():oGrid:Refresh( .T. )
   oApp():oGrid:SetFocus( .T. )

   RETURN NIL


FUNCTION AuList( aList, cData, oSelf )

   LOCAL aNewList := {}

   AU->( dbSetOrder( 1 ) )
   AU->( dbGoTop() )
   WHILE ! AU->( Eof() )
      IF At( Upper( cdata ), Upper( AU->AuNombre ) ) != 0 // UPPER( SubStr( oApp():amaterias[i,1], 1, Len( cData ) ) ) == UPPER( cData )
         AAdd( aNewList, { AU->AuNombre } )
      ENDIF
      AU->( dbSkip() )
   ENDDO

   RETURN aNewlist
