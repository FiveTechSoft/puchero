#include "FiveWin.ch"
#include "Report.ch"
#include "xBrowse.ch"
#include "vmenu.ch"

STATIC oReport

FUNCTION Publicaciones()

   LOCAL oBar, oCol, oCont
   LOCAL aBrowse
   LOCAL cState := GetPvProfString( "Browse", "PuState", "", oApp():cIniFile )
   LOCAL nOrder := Max( Val( GetPvProfString( "Browse", "PuOrder", "1", oApp():cIniFile ) ), 1 )
   LOCAL nRecno := Val( GetPvProfString( "Browse", "PuRecno", "1", oApp():cIniFile ) )
   LOCAL nSplit := Val( GetPvProfString( "Browse", "PuSplit", "102", oApp():cIniFile ) )
   LOCAL i

   IF oApp():oDlg != NIL
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

   SELECT PU
   oApp():oDlg := TFsdi():New( oApp():oWndMain )
   oApp():oDlg:cTitle := i18n( 'Gestión de publicaciones de cocina' )
   oApp():oWndMain:oClient := oApp():oDlg
   oApp():oDlg:NewGrid( nSplit )

   Ut_BrwRowConfig( oApp():oGrid )

   oApp():oGrid:cAlias := "PU"
	
   oCol := oApp():oGrid:AddCol()
   oCol:bLClickHeader := {|| PuSort( 1, oCont ) }
   oCol:Cargo := 1
   oCol:AddResource( "16_SORT_A" )
   oCol:AddResource( "16_SORT_B" )
   oCol:nHeadBmpNo    := iif( nOrder == 1, 1, 2 )
   oCol:nHeadBmpAlign := AL_RIGHT
   oCol:bStrData := {|| PU->PuNombre }
   oCol:cHeader  := i18n( "Nombre" )
   oCol:nWidth   := 190
	
   oCol := oApp():oGrid:AddCol()
   oCol:bLClickHeader := {|| PuSort( 2, oCont ) }
   oCol:Cargo := 2
   oCol:AddResource( "16_SORT_A" )
   oCol:AddResource( "16_SORT_B" )
   oCol:nHeadBmpNo    := iif( nOrder == 2, 1, 2 )
   oCol:nHeadBmpAlign := AL_RIGHT
   oCol:bStrData := {|| PU->PuNombre }
   oCol:cHeader  := i18n( "País" )
   oCol:nWidth   := 120

   oCol := oApp():oGrid:AddCol()
   oCol:bLClickHeader := {|| PuSort( 3, oCont ) }
   oCol:Cargo := 3
   oCol:AddResource( "16_SORT_A" )
   oCol:AddResource( "16_SORT_B" )
   oCol:nHeadBmpNo    := iif( nOrder == 3, 1, 2 )
   oCol:nHeadBmpAlign := AL_RIGHT
   oCol:bStrData := {|| PU->PuPeriod }
   oCol:cHeader  := i18n( "Periodicidad" )
   oCol:nWidth   := 90
	
   oCol := oApp():oGrid:AddCol()
   oCol:bLClickHeader := {|| PuSort( 4, oCont ) }
   oCol:Cargo := 4
   oCol:AddResource( "16_SORT_A" )
   oCol:AddResource( "16_SORT_B" )
   oCol:nHeadBmpNo    := iif( nOrder == 4, 1, 2 )
   oCol:nHeadBmpAlign := AL_RIGHT
   oCol:bStrData := {|| PU->PuFchCad }
   oCol:cHeader  := i18n( "Fch. Expiración" )
   oCol:nWidth   := 190
	
   ADD oCol TO oApp():oGrid DATA PU->PuRecetas ;
      HEADER "Recetas" PICTURE "@E 999,999" ;
      TOTAL 0 WIDTH 90

   ADD oCol TO oApp():oGrid DATA PU->PuPrecio ;
      HEADER "Precio" PICTURE "@E 999,999.99" ;
      TOTAL 0 WIDTH 90

   aBrowse   := { { {|| PU->PuEditor }, i18n( "Editor" ), 150, 0 }, ;
      { {|| PU->PuDirecc }, i18n( "Dirección" ), 120, 0 }, ;
      { {|| PU->PuLocali }, i18n( "Localidad" ), 120, 0 }, ;
      { {|| PU->PuTelefono }, i18n( "Telefono" ), 120, 0 }, ;
      { {|| PU->PuFax }, i18n( "Fax" ), 120, 0 }, ;
      { {|| PU->PuEmail }, i18n( "E-mail" ), 150, 0 }, ;
      { {|| PU->PuURL }, i18n( "Sitio web" ), 150, 0 }, ;
      { {|| DToC( PU->PuFchPago ) }, i18n( "Fch. Pago" ), 120, 0 } }

   FOR i := 1 TO Len( aBrowse )
      oCol := oApp():oGrid:AddCol()
      oCol:bStrData := aBrowse[ i, 1 ]
      oCol:cHeader  := aBrowse[ i, 2 ]
      oCol:nWidth   := aBrowse[ i, 3 ]
      oCol:nDataStrAlign := aBrowse[ i, 4 ]
      oCol:nHeadStrAlign := aBrowse[ i, 4 ]
   NEXT

   // añado columnas con bitmaps

   oCol := oApp():oGrid:AddCol()
   oCol:AddResource( "BR_SUSC1" )
   oCol:AddResource( "BR_SUSC2" )
   oCol:cHeader       := i18n( "Suscrito" )
   oCol:bBmpData      := {|| iif( PU->PuSuscrip, 1, 2 ) } // { || IIF(EMPTY(CL->ClInternet),2,1) }
   oCol:nWidth        := 23
   oCol:nDataBmpAlign := 2

   FOR i := 1 TO Len( oApp():oGrid:aCols )
      oCol := oApp():oGrid:aCols[ i ]
      oCol:bLDClickData  := {|| PuEdita( oApp():oGrid, 2, oCont, oApp():oDlg ) }
   NEXT

   oApp():oGrid:SetRDD()
   oApp():oGrid:CreateFromCode()
   oApp():oGrid:bChange  := {|| RefreshCont( oCont, "PU" ), oApp():ogrid:Maketotals() }
   oApp():oGrid:bKeyDown := {| nKey| PuTecla( nKey, oApp():oGrid, oCont, oApp():oDlg ) }
   oApp():oGrid:nRowHeight  := 21
   oApp():oGrid:RestoreState( cState )
   oApp():oGrid:lFooter := .T.
   oApp():oGrid:bClrFooter := {|| { CLR_HRED, GetSysColor( 15 ) } }
   oApp():oGrid:MakeTotals()

   PU->( dbSetOrder( nOrder ) )
   IF nRecNo < PU->( LastRec() ) .AND. nRecno != 0
      PU->( dbGoto( nRecno ) )
   ELSE
      PU->( dbGoTop() )
   ENDIF

   @ 02, 05 VMENU oCont SIZE nSplit - 10, 18 OF oApp():oDlg  ;
      COLOR CLR_BLACK, GetSysColor( 15 )       ;
      FILLED   ;  // BORDER
   COLORSELECT 0, CLR_WHITE ;
      HEIGHT ITEM 22

   DEFINE TITLE OF oCont ;
      CAPTION tran( PU->( ordKeyNo() ), '@E 999,999' ) + " / " + tran( PU->( ordKeyCount() ), '@E 999,999' ) ;// strZero( RE->( ordKeyCount() ), 6 ) ;
   HEIGHT 25 ;
      COLOR GetSysColor( 9 ), oApp():nClrBar ;
      IMAGE "BB_PUBLI"

   @ 24, 05 VMENU oBar SIZE nSplit - 10, 180 OF oApp():oDlg  ;
      COLOR CLR_BLACK, GetSysColor( 15 )       ;
      HEIGHT ITEM 22 XBOX
   oBar:nClrBox := Min( GetSysColor( 13 ), GetSysColor( 14 ) )

   DEFINE TITLE OF oBar ;
      CAPTION "Publicaciones" ;
      HEIGHT 24 ;
      COLOR GetSysColor( 9 ), oApp():nClrBar ;
      OPENCLOSE

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Nuevo"              ;
      IMAGE "16_NUEVO"             ;
      ACTION PuEdita( oApp():oGrid, 1, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Modificar"          ;
      IMAGE "16_MODIF"             ;
      ACTION PuEdita( oApp():oGrid, 2, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Duplicar"           ;
      IMAGE "16_DUPLICA"           ;
      ACTION PuEdita( oApp():oGrid, 3, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Borrar"             ;
      IMAGE "16_BORRAR"            ;
      ACTION PuBorra( oApp():oGrid, oCont );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Agrupar publicaciones"  ;
      IMAGE "16_AGRUPA"            ;
      ACTION PuAgrupa( oApp():oGrid, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Buscar"             ;
      IMAGE "16_BUSCA"             ;
      ACTION PuBusca( oApp():oGrid,, oCont, oApp():oDlg )  ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Imprimir"           ;
      IMAGE "16_IMPRIMIR"          ;
      ACTION PuImprime( oApp():oGrid, oApp():oDlg )         ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Ver recetas"        ;
      IMAGE "16_RECETAS"        ;
      ACTION PuEjemplares( oApp():oGrid, oApp():oDlg ) ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Visitar sitio web"  ;
      IMAGE "16_INTERNET"          ;
      ACTION GoWeb( PU->PuUrl )      ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Enviar e-mail"      ;
      IMAGE "16_EMAIL"             ;
      ACTION GoMail( PU->PuEmail )   ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Enviar a Excel"     ;
      IMAGE "16_EXCEL"             ;
      ACTION ( CursorWait(), Ut_ExportXLS( oApp():oGrid, "Publicaciones" ), CursorArrow() );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Configurar rejilla" ;
      IMAGE "16_GRID"              ;
      ACTION Ut_BrwColConfig( oApp():oGrid, "PuState" ) ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Salir"              ;
      IMAGE "16_SALIR"             ;
      ACTION oApp():oDlg:End()              ;
      LEFT 10

   @ oApp():oDlg:nGridBottom, nSplit + 2 TABS oApp():oTab ;
      OPTION nOrder SIZE oApp():oWndMain:nWidth() -80, 12 PIXEL OF oApp():oDlg ;
      ITEMS ' Publicación ', ' Pais ', ' Periodicidad ', ' Fecha expiración suscripción ';
      ACTION PuSort( oApp():otab:noption, oCont )

   oApp():oDlg:NewSplitter( nSplit, oCont, oBar )

   ACTIVATE DIALOG oApp():oDlg NOWAIT ;
      ON INIT ( ResizeWndMain(), oApp():oGrid:SetFocus() ) ;
      VALID ( oApp():oGrid:nLen := 0,;
      WritePProString( "Browse", "PuState", oApp():oGrid:SaveState(), oApp():cIniFile ),;
      WritePProString( "Browse", "PuOrder", LTrim( Str( PU->( ordNumber() ) ) ), oApp():cIniFile ),;
      WritePProString( "Browse", "PuRecno", LTrim( Str( PU->( RecNo() ) ) ), oApp():cIniFile ),;
      WritePProString( "Browse", "PuSplit", LTrim( Str( oApp():oSplit:nleft / 2 ) ), oApp():cIniFile ),;
      oBar:End(), dbCloseAll(), oApp():oDlg := NIL, oApp():oGrid := NIL, oApp():oTab := NIL, .T. )

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION PuEdita( oGrid, nMode, oCont, oParent, cPublica )

   LOCAL oDlg, oFld, oBmp
   LOCAL aTitle := { i18n( "Añadir publicación" ),;
      i18n( "Modificar publicación" ),;
      i18n( "Duplicar publicación" ) }
   LOCAL aGet[ 20 ]
   LOCAL aSay[ 12 ]
   LOCAL cPunombre,;
      cPuperiod,;
      nPuprecio,;
      cPueditor,;
      cPudirecc,;
      cPuLocali,;
      cPuPais,;
      cPutelefono, ;
      cPufax,;
      cPuemail,;
      cPuurl,;
      cPunotas,;
      lPususcrip, ;
      nPupresus,;
      dPufchpago, ;
      dPufchcad

   LOCAL nRecPtr := PU->( RecNo() )
   LOCAL nOrden  := PU->( ordNumber() )
   LOCAL nRecAdd
   LOCAL lDuplicado
   LOCAL lReturn := .F.

   IF PU->( Eof() ) .AND. nMode != 1
      RETURN NIL
   ENDIF

   oApp():nEdit ++

   IF nMode == 1
      PU->( dbAppend() )
      nRecAdd := PU->( RecNo() )
   ENDIF

   cPunombre  := iif( nMode == 1 .AND. cPublica != NIL, cPublica, Pu->Punombre )
   cPuperiod  := Pu->Puperiod
   nPuprecio  := Pu->Puprecio
   cPueditor  := Pu->Pueditor
   cPudirecc  := Pu->Pudirecc
   cPuLOCALi  := Pu->PuLOCALi
   cPuPais    := Pu->PuPais
   cPutelefono := Pu->Putelefono
   cPufax     := Pu->Pufax
   cPuemail   := Pu->Puemail
   cPuurl     := Pu->Puurl + Space( 80 -Len( Pu->Puurl ) )
   cPunotas   := Pu->Punotas
   lPususcrip := Pu->Pususcrip
   nPupresus  := Pu->Pupresus
   dPufchpago := Pu->Pufchpago
   dPufchcad  := Pu->Pufchcad

   IF nMode == 3
      PU->( dbAppend() )
      nRecAdd := PU->( RecNo() )
   ENDIF

   DEFINE DIALOG oDlg RESOURCE "PU_EDIT_" + oApp():cLanguage OF oParent   ;
      TITLE aTitle[ nMode ]
   oDlg:SetFont( oApp():oFont )

   REDEFINE GET aGet[ 1 ] VAR cPuNombre        ;
      ID 101 OF oDlg UPDATE                  ;
      VALID PuClave( cPuNombre, aGet[ 1 ], nMode )

   REDEFINE GET aGet[ 2 ] VAR cPuPeriod        ;
      ID 102 OF oDlg UPDATE

   REDEFINE GET aGet[ 3 ] VAR nPuPrecio        ;
      ID 103 OF oDlg UPDATE                  ;
      PICTURE "@E 99,999.99"

   REDEFINE FOLDER oFld                      ;
      ID 110 OF oDlg                         ;
      ITEMS ' &Editor ', ' &Suscripción ', ' &Internet ',  ' &Notas ' ;
      DIALOGS "PU_EDIT_A_" + oApp():cLanguage, "PU_EDIT_D_" + oApp():cLanguage, ;
      "PU_EDIT_B_" + oApp():cLanguage, "PU_EDIT_C_" + oApp():cLanguage ;
      OPTION 1

   REDEFINE SAY aSay[ 01 ] ID 211 OF oFld:aDialogs[ 1 ]
   REDEFINE SAY aSay[ 02 ] ID 212 OF oFld:aDialogs[ 1 ]
   REDEFINE SAY aSay[ 03 ] ID 213 OF oFld:aDialogs[ 1 ]
   REDEFINE SAY aSay[ 04 ] ID 214 OF oFld:aDialogs[ 1 ]
   REDEFINE SAY aSay[ 05 ] ID 215 OF oFld:aDialogs[ 1 ]
   REDEFINE SAY aSay[ 12 ] ID 216 OF oFld:aDialogs[ 1 ]
   REDEFINE SAY aSay[ 06 ] ID 221 OF oFld:aDialogs[ 2 ]
   REDEFINE SAY aSay[ 07 ] ID 222 OF oFld:aDialogs[ 2 ]
   REDEFINE SAY aSay[ 08 ] ID 223 OF oFld:aDialogs[ 2 ]
   REDEFINE SAY aSay[ 09 ] ID 231 OF oFld:aDialogs[ 3 ]
   REDEFINE SAY aSay[ 10 ] ID 232 OF oFld:aDialogs[ 3 ]
   REDEFINE SAY aSay[ 11 ] ID 241 OF oFld:aDialogs[ 4 ]

   REDEFINE GET aGet[ 4 ] VAR cPuEditor        ;
      ID 111 OF oFld:aDialogs[ 1 ] UPDATE

   REDEFINE GET aGet[ 5 ] VAR cPuTelefono      ;
      ID 112 OF oFld:aDialogs[ 1 ] UPDATE

   REDEFINE GET aGet[ 6 ] VAR cPuFax           ;
      ID 113 OF oFld:aDialogs[ 1 ] UPDATE

   REDEFINE GET aGet[ 7 ] VAR cPuDirecc        ;
      ID 114 OF oFld:aDialogs[ 1 ] UPDATE

   REDEFINE GET aGet[ 8 ] VAR cPuLOCALi        ;
      ID 115 OF oFld:aDialogs[ 1 ] UPDATE

   REDEFINE GET aGet[ 16 ] VAR cPuPais         ;
      ID 116 OF oFld:aDialogs[ 1 ] UPDATE

   REDEFINE CHECKBOX aGet[ 9 ] VAR lPuSuscrip  ;
      ID 120 OF oFld:aDialogs[ 2 ] UPDATE

   REDEFINE GET aGet[ 10 ] VAR dPuFchPago      ;
      ID 121 OF oFld:aDialogs[ 2 ] UPDATE

   REDEFINE BUTTON aGet[ 17 ]                  ;
      ID 124 OF oFld:aDialogs[ 2 ]             ;
      ACTION SelecFecha( dPuFchPago, aGet[ 10 ] )
   aGet[ 17 ]:cTooltip := i18n( "seleccionar fecha" )

   REDEFINE GET aGet[ 11 ] VAR dPuFchCad       ;
      ID 122 OF oFld:aDialogs[ 2 ] UPDATE

   REDEFINE BUTTON aGet[ 18 ]                  ;
      ID 125 OF oFld:aDialogs[ 2 ]             ;
      ACTION SelecFecha( dPuFchCad, aGet[ 11 ] )
   aGet[ 18 ]:cTooltip := i18n( "seleccionar fecha" )

   REDEFINE GET aGet[ 12 ] VAR nPuPreSus       ;
      ID 123 OF oFld:aDialogs[ 2 ] UPDATE      ;
      PICTURE "@E 99,999.99"

   REDEFINE GET aGet[ 13 ] VAR cPuEmail        ;
      ID 131 OF oFld:aDialogs[ 3 ] UPDATE

   REDEFINE BUTTON aGet[ 19 ]                  ;
      ID 133 OF oFld:aDialogs[ 3 ]             ;
      ACTION GoMail( cPuEmail )
   aGet[ 19 ]:cTooltip := i18n( "enviar e-mail" )

   REDEFINE GET aGet[ 14 ] VAR cPuUrl          ;
      ID 132 OF oFld:aDialogs[ 3 ] UPDATE

   REDEFINE BUTTON aGet[ 20 ]                  ;
      ID 134 OF oFld:aDialogs[ 3 ]             ;
      ACTION GoWeb( cPuUrl )
   aGet[ 20 ]:cTooltip := i18n( "visitar sitio web" )

   REDEFINE GET aGet[ 15 ] VAR cPuNotas        ;
      ID 141 OF oFld:aDialogs[ 4 ] MULTILINE UPDATE

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
      lReturn := .T.
      /* ___ actualizo el nombre de la publicación en las recetas _____________*/
      IF nMode == 2
         IF RTrim( cPuNombre ) != RTrim( PU->PuNombre )
            SELECT RE
            RE->( dbGoTop() )
            REPLACE RE->RePublica   ;
               WITH cPuNombre       ;
               FOR Upper( RTrim( RE->RePublica ) ) == Upper( RTrim( PU->PuNombre ) )
         ENDIF
      ENDIF

      /* ___ guardo el registro _______________________________________________*/
      IF nMode == 2
         PU->( dbGoto( nRecPtr ) )
      ELSE
         PU->( dbGoto( nRecAdd ) )
      ENDIF

      REPLACE Pu->punombre      WITH  cPunombre
      REPLACE Pu->Puperiod      WITH  cPuperiod
      REPLACE Pu->Puprecio      WITH  nPuprecio
      REPLACE Pu->Pueditor      WITH  cPueditor
      REPLACE Pu->Pudirecc      WITH  cPudirecc
      REPLACE Pu->PuLOCALi      WITH  cPuLOCALi
      REPLACE Pu->Pupais        WITH  cPuPais
      REPLACE Pu->Putelefono    WITH  cPutelefono
      REPLACE Pu->PuFax         WITH  cPuFax
      REPLACE Pu->Puemail       WITH  cPuemail
      REPLACE Pu->Puurl         WITH  cPuurl
      REPLACE Pu->Punotas       WITH  cPunotas
      REPLACE Pu->Pususcrip     WITH  lPususcrip
      REPLACE Pu->Pupresus      WITH  nPupresus
      REPLACE Pu->Pufchpago     WITH  dPufchpago
      REPLACE Pu->Pufchcad      WITH  dPufchcad
      PU->( dbCommit() )
      IF cPublica != NIL
         cPublica := PU->PuNombre
      ENDIF
   ELSE

      IF nMode == 1 .OR. nMode == 3

         PU->( dbGoto( nRecAdd ) )
         PU->( dbDelete() )
         PU->( DbPack() )
         PU->( dbGoto( nRecPtr ) )

      ENDIF

   ENDIF

   SELECT PU

   IF oCont != NIL
      RefreshCont( oCont, "PU" )
   ENDIF
   IF oGrid != NIL
      oGrid:Maketotals()
      oGrid:Refresh()
      oGrid:SetFocus( .T. )
   ENDIF
   oApp():nEdit --

   RETURN lReturn
/*_____________________________________________________________________________*/

FUNCTION PuBorra( oGrid, oCont )

   LOCAL nRecord := PU->( RecNo() )
   LOCAL nNext

   oApp():nEdit ++
   IF msgYesNo( i18n( "¿ Está seguro de querer borrar esta publicación ?" ) + CRLF + ;
         ( Trim( PU->PuNombre ) ), 'Seleccione una opción' )
      // dejo en blanco las recetas de la publicación
      SELECT RE
      RE->( dbGoTop() )
      REPLACE RE->RePublica   ;
         WITH Space( 50 )       ;
         FOR Upper( RTrim( RE->RePublica ) ) == Upper( RTrim( PU->PuNombre ) )

      // borro la publicación
      PU->( dbSkip() )
      nNext := PU->( RecNo() )
      PU->( dbGoto( nRecord ) )

      PU->( dbDelete() )
      PU->( DbPack() )
      PU->( dbGoto( nNext ) )
      IF PU->( Eof() ) .OR. nNext == nRecord
         PU->( dbGoBottom() )
      ENDIF
   ENDIF

   IF oCont != NIL
      RefreshCont( oCont, "PU" )
   ENDIF

   oApp():nEdit --
   oGrid:Maketotals()
   oGrid:Refresh( .T. )
   oGrid:SetFocus( .T. )

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION PuTecla( nKey, oGrid, oCont, oDlg )

   DO CASE
   CASE nKey == VK_RETURN
      PuEdita( oGrid, 2, oCont, oDlg )
   CASE nKey == VK_INSERT
      PuEdita( oGrid, 1, oCont, oDlg )
   CASE nKey == VK_DELETE
      PuBorra( oGrid, oCont )
   CASE nKey == VK_ESCAPE
      oDlg:End()
   OTHERWISE
      IF nKey >= 96 .AND. nKey <= 105
         PuBusca( oGrid, Str( nKey - 96, 1 ), oCont, oDlg )
      ELSEIF HB_ISSTRING( Chr( nKey ) )
         PuBusca( oGrid, Chr( nKey ), oCont, oDlg )
      ENDIF
   ENDCASE

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION PuAgrupa( oGrid, oParent )

   LOCAL oDlg, oCombo
   LOCAL cTitle := i18n( "Agrupar publicacione" )
   LOCAL aSay[ 4 ]

   LOCAL nRecno      := PU->( RecNo() )
   LOCAL nOrden      := PU->( ordNumber() )
   LOCAL nReRecno    := RE->( RecNo() )
   LOCAL nReOrden    := RE->( ordNumber() )

   LOCAL cPublica    := PU->PuNombre
   LOCAL nPuRecetas  := PU->PuRecetas

   LOCAL nRecAdd
   LOCAL lDuplicado
   LOCAL aPublica    := {}
   LOCAL cNewPublica

   oApp():nEdit ++

   PU->( dbGoTop() )
   DO WHILE ! PU->( Eof() )
      AAdd( aPublica, PU->PuNombre )
      PU->( dbSkip() )
   ENDDO
   cNewPublica := aPublica[ 1 ]

   DEFINE DIALOG oDlg RESOURCE "UT_AGRUPA" TITLE cTitle OF oParent
   oDlg:SetFont( oApp():oFont )

   REDEFINE SAY aSay[ 1 ]          ;
      PROMPT "La agrupación de publicaciones permite asignar a recetas existentes una nueva publicación ya existente." ;
      ID 10 OF oDlg COLOR CLR_BLACK, CLR_WHITE

   REDEFINE SAY aSay[ 2 ]          ;
      PROMPT "Publicación vieja:";
      ID 11 OF oDlg

   REDEFINE SAY aSay[ 3 ]          ;
      PROMPT cPublica            ;
      COLOR CLR_HBLUE, GetSysColor( 15 ) ;
      ID 12 OF oDlg

   REDEFINE SAY aSay[ 4 ]          ;
      PROMPT "Nueva publicación:";
      ID 13 OF oDlg

   REDEFINE COMBOBOX oCombo      ;
      VAR cNewPublica            ;
      ITEMS aPublica             ;
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
      /* ___ actualizo la publicación de autor en la receta___________________________*/
      SELECT RE
      RE->( dbSetOrder( 0 ) )
      RE->( dbGoTop() )
      REPLACE RE->RePublica   ;
         WITH cNewPublica     ;
         FOR Upper( RTrim( RE->RePublica ) ) == Upper( RTrim( cPublica ) )
      /* ___ borro la publicación y acumulo el número de recetas ______________________*/
      SELECT PU
      PU->( dbSetOrder( 1 ) )
      PU->( dbGoto( nRecno ) )
      PU->( dbDelete() )
      PU->( DbPack() )
      PU->( dbGoTop() )
      PU->( dbSeek( Upper( cNewPublica ) ) )
      REPLACE PU->PuRecetas  WITH PU->PuRecetas + nPuRecetas
      PU->( dbCommit() )
      // recargo el autocompletado de publicaciones
   ELSE
      PU->( dbGoto( nRecno ) )
   ENDIF

   SELECT PU

   oGrid:Maketotals()
   oGrid:Refresh( .T. )
   oGrid:SetFocus( .T. )
   oApp():nEdit --

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION PuSeleccion( cPublica, oControl, oParent, oVItem )

   LOCAL oDlg, oBrowse, oCol, oBtnAceptar, oBtnCancel, oBNew, oBMod, oBDel, oBBus
   LOCAL lOk    := .F.
   LOCAL nRecno := PU->( RecNo() )
   LOCAL nOrder := PU->( ordNumber() )
   LOCAL nArea  := Select()
   LOCAL aPoint := iif( oControl != NIL, AdjustWnd( oControl, 271 * 2, 150 * 2 ), { 1.3 * oVItem:nTop(), oApp():oGrid:nLeft } )

   DEFINE DIALOG oDlg RESOURCE 'UT_AJENA1_' + oApp():cLanguage OF oParent;
      TITLE i18n( "Selección de publicaciones" )
   oDlg:SetFont( oApp():oFont )

   // siempre tengo ordenado por nombre

   SELECT PU
   PU->( dbSetOrder( 1 ) )
   PU->( dbGoTop() )

   IF ! PU->( dbSeek( cPublica ) )
      PU->( dbGoTop() )
   ENDIF

   oBrowse := TXBrowse():New( oDlg )
   Ut_BrwRowConfig( oBrowse )
   oBrowse:cAlias := "PU"

   oCol := oBrowse:AddCol()
   oCol:bStrData := {|| PU->PuNombre }
   oCol:cHeader  := "Publicación"
   oCol:nWidth   := 160
   oCol:bLDClickData  := {|| ( lOk := .T., oDlg:End() )   }
   oBrowse:SetRDD()
   oBrowse:CreateFromResource( 110 )
   oBrowse:bKeyDown := {| nKey| PuSeTecla( nKey, oBrowse, oDlg, oBtnAceptar ) }

   REDEFINE BUTTON oBNew   ;
      ID 410 OF oDlg       ;
      ACTION PuEdita( oBrowse, 1, , oDlg )

   REDEFINE BUTTON oBMod   ;
      ID 411 OF oDlg       ;
      ACTION PuEdita( oBrowse, 2, , oDlg )

   REDEFINE BUTTON oBDel   ;
      ID 412 OF oDlg       ;
      ACTION PuBorra( oBrowse, )

   REDEFINE BUTTON oBBus   ;
      ID 413 OF oDlg       ;
      ACTION PuBusca( oBrowse, , , oDlg )

   REDEFINE BUTTON oBtnAceptar   ;
      ID IDOK OF oDlg            ;
      ACTION ( lOk := .T., oDlg:End() )

   REDEFINE BUTTON oBtnCancel    ;
      ID IDCANCEL OF oDlg        ;
      ACTION ( lOk := .F., oDlg:End() )

   ACTIVATE DIALOG oDlg CENTERED       ;
      ON PAINT oDlg:Move( aPoint[ 1 ], aPoint[ 2 ],,, .T. )

   IF lOK
      cPublica := PU->PuNombre
      IF oControl != NIL
         oControl:cText := PU->PuNombre
      ENDIF
   ENDIF

   PU->( dbSetOrder( nOrder ) )
   PU->( dbGoto( nRecno ) )

   SELECT ( nArea )

   RETURN NIL
/*_____________________________________________________________________________*/
FUNCTION PuSeTecla( nKey, oGrid, oDlg, oBtn )

   DO CASE
   CASE nKey == VK_RETURN
      oBtn:Click()
   CASE nKey == VK_ESCAPE
      oDlg:End()
   OTHERWISE
      IF nKey >= 96 .AND. nKey <= 105
         PuBusca( oGrid, Str( nKey - 96, 1 ),, oDlg )
      ELSEIF HB_ISSTRING( Chr( nKey ) )
         PuBusca( oGrid, Chr( nKey ),, oDlg )
      ENDIF
   ENDCASE

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION PuBusca( oGrid, cChr, oCont, oParent )

   LOCAL nOrder    := PU->( ordNumber() )
   LOCAL nRecno    := PU->( RecNo() )
   LOCAL oDlg, oGet, cGet, cPicture
   LOCAL aSay1    := { i18n( "Introduzca el nombre de la publicación" ),;
      i18n( "Introduzca el país del editor" ),;
      i18n( "Introduzca la periodicidad" ),;
      i18n( "Introduzca la fecha de expiración de la suscripción" )  }
   LOCAL aSay2    := { i18n( "Publicación:" ),;
      i18n( "Pais:" ),;
      i18n( "Periodicidad:" ),;
      i18n( "Fecha:" )        }
   LOCAL aGet     := { Space( 50 ),;
      Space( 20 ),;
      Space( 10 ),;
      CToD( "" )  }

   LOCAL cNombre   := Space( 50 )
   LOCAL cPeriodo  := Space( 10 )
   LOCAL dFecha    := CToD( '' )
   LOCAL lSeek     := .F.
   LOCAL lFecha    := .F.
   LOCAL aBrowse  := {}

   oApp():nEdit ++

   DEFINE DIALOG oDlg RESOURCE 'UT_BUSCA_' + oApp():cLanguage OF oParent  ;
      TITLE i18n( "Búsqueda de publicaciones" )
   oDlg:SetFont( oApp():oFont )

   REDEFINE SAY PROMPT aSay1[ nOrder ] ID 20 OF oDlg
   REDEFINE SAY PROMPT aSay2[ nOrder ] ID 21 OF Odlg

   cGet  := aGet[ nOrder ]

   IF nOrder == 4
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
         // cGet := DtoS(cGet)
      ENDIF
      MsgRun( 'Realizando la búsqueda...', oApp():cAppName + oApp():cVersion, ;
         {|| PuWildSeek( nOrder, cGet, aBrowse ) } )
      IF Len( aBrowse ) == 0
         MsgStop( "No se ha encontrado ninguna publicación.", 'Atención' )
      ELSE
         PuEncontrados( aBrowse, oApp():oDlg )
      ENDIF
   ENDIF
		
   IF oCont != NIL
      RefreshCont( oCont, "PU" )
   ENDIF
   oGrid:Refresh()
   oGrid:SetFocus( .T. )
   RefreshReBarImage()
   oApp():nEdit --
		
   RETURN NIL
		
/*_____________________________________________________________________________*/
FUNCTION PuWildSeek( nOrder, cGet, aBrowse )

   LOCAL nRecno   := PU->( RecNo() )

   DO CASE
   CASE nOrder == 1
      PU->( dbGoTop() )
      DO WHILE ! PU->( Eof() )
         IF cGet $ Upper( PU->PuNombre )
            AAdd( aBrowse, { PU->PuNombre, PU->PuPais, PU->PuPeriod, PU->PuFchCad, PU->( RecNo() ) } )
         ENDIF
         PU->( dbSkip() )
      ENDDO
   CASE nOrder == 2
      PU->( dbGoTop() )
      DO WHILE ! PU->( Eof() )
         IF cGet $ Upper( PU->PuPais )
            AAdd( aBrowse, { PU->PuNombre, PU->PuPais, PU->PuPeriod, PU->PuFchCad, PU->( RecNo() ) } )
         ENDIF
         PU->( dbSkip() )
      ENDDO
   CASE nOrder == 3
      PU->( dbGoTop() )
      DO WHILE ! PU->( Eof() )
         IF cGet $ Upper( PU->PuPeriod )
            AAdd( aBrowse, { PU->PuNombre, PU->PuPais, PU->PuPeriod, PU->PuFchCad, PU->( RecNo() ) } )
         ENDIF
         PU->( dbSkip() )
      ENDDO
   CASE nOrder == 4
      PU->( dbGoTop() )
      DO WHILE ! PU->( Eof() )
         IF DToS( cGet ) == DToS( PU->PuFchCad )
            AAdd( aBrowse, { PU->PuNombre, PU->PuPais, PU->PuPeriod, PU->PuFchCad, PU->( RecNo() ) } )
         ENDIF
         PU->( dbSkip() )
      ENDDO
   END CASE
   PU->( dbGoto( nRecno ) )
   // ordeno la tabla por el 1 elemento
   ASort( aBrowse,,, {|aAut1, aAut2| Upper( aAut1[ 1 ] ) < Upper( aAut2[ 1 ] ) } )

   RETURN NIL
/*_____________________________________________________________________________*/
		
FUNCTION PuEncontrados( aBrowse, oParent )

   LOCAL oDlg, oBrowse, oBtnOk, oBtnCancel, lOk
   LOCAL nRecno := RE->( RecNo() )
		
   DEFINE DIALOG oDlg RESOURCE "DLG_ENCONTRADOS" ;
      TITLE i18n( "Resultado de la búsqueda" ) ;
      OF oParent
   oDlg:SetFont( oApp():oFont )
		
   oBrowse := TXBrowse():New( oDlg )
   Ut_BrwRowConfig( oBrowse )

   oBrowse:SetArray( aBrowse, .F. )
   oBrowse:aCols[ 1 ]:cHeader := "Publicación"
   oBrowse:aCols[ 2 ]:cHeader := "País"
   oBrowse:aCols[ 3 ]:cHeader := "Periodicidad"
   oBrowse:aCols[ 4 ]:cHeader := "Fch. Suscripción"
   oBrowse:aCols[ 1 ]:nWidth  := 240
   oBrowse:aCols[ 2 ]:nWidth  := 100
   oBrowse:aCols[ 3 ]:nWidth  := 100
   oBrowse:aCols[ 4 ]:nWidth  := 100
   oBrowse:aCols[ 5 ]:Hide()
   oBrowse:aCols[ 1 ]:nHeadStrAlign := 0
   oBrowse:aCols[ 1 ]:nDataStrAlign := 0
   oBrowse:aCols[ 2 ]:nHeadStrAlign := 0
   oBrowse:aCols[ 2 ]:nDataStrAlign := 0
   oBrowse:aCols[ 3 ]:nHeadStrAlign := 0
   oBrowse:aCols[ 3 ]:nDataStrAlign := 0
   oBrowse:aCols[ 4 ]:nHeadStrAlign := 0
   oBrowse:aCols[ 4 ]:nDataStrAlign := 0
		
   oBrowse:CreateFromResource( 110 )
		
   PU->( dbGoto( aBrowse[ oBrowse:nArrayAt, 5 ] ) )
   AEval( oBrowse:aCols, {|oCol| oCol:bLDClickData := {|| PU->( dbGoto( aBrowse[ oBrowse:nArrayAt, 5 ] ) ), ;
      PuEdita( , 2,, oApp():oDlg ) } } )
   oBrowse:bKeyDown  := {| nKey| iif( nKey == VK_RETURN, ( PU->( dbGoto( aBrowse[ oBrowse:nArrayAt, 5 ] ) ), ;
      PuEdita( , 2,, oApp():oDlg ) ), ) }
   oBrowse:bChange    := {|| PU->( dbGoto( aBrowse[ oBrowse:nArrayAt, 5 ] ) ) }
   oBrowse:lHScroll  := .F.
   oDlg:oClient      := oBrowse
   oBrowse:nRowHeight := 20
		
   REDEFINE BUTTON oBtnOk ;
      ID IDOK OF oDlg     ;
      ACTION oDlg:End()
		
   REDEFINE BUTTON oBtnCancel ;
      ID IDCANCEL OF oDlg ;
      ACTION ( PU->( dbGoto( nRecno ) ), oDlg:End() )
		
   ACTIVATE DIALOG oDlg ;
      ON INIT DlgCenter( oDlg, oApp():oWndMain )
		
   RETURN NIL
		
/*_____________________________________________________________________________*/

FUNCTION PuClave( cPublica, oGet, nMode )

   // nMode    1 nuevo registro
   // 2 modificación de registro
   // 3 duplicación de registro
   // 4 clave ajena
   LOCAL lReturn  := .F.
   LOCAL nRecno   := PU->( RecNo() )
   LOCAL nOrder   := PU->( ordNumber() )
   LOCAL nArea    := Select()

   IF Empty( cPublica )
      IF nMode == 4
         RETURN .T.
      ELSE
         MsgStop( i18n( "Es obligatorio rellenar este campo." ) )
         RETURN .F.
      ENDIF
   ENDIF

   SELECT PU
   PU->( dbSetOrder( 1 ) )
   PU->( dbGoTop() )

   IF PU->( dbSeek( Upper( cPublica ) ) )
      DO CASE
      CASE nMode == 1 .OR. nMode == 3
         lReturn := .F.
         MsgStop( i18n( "Publicación existente." ) )
      CASE nMode == 2
         IF PU->( RecNo() ) == nRecno
            lReturn := .T.
         ELSE
            lReturn := .F.
            MsgStop( i18n( "Publicación existente." ) )
         ENDIF
      CASE nMode == 4
         lReturn := .T.
         IF ! oApp():thefull
            Registrame()
         ENDIF
      END CASE
   ELSE
      IF nMode < 4
         lReturn := .T.
      ELSE
         IF MsgYesNo( "Publicación inexistente. ¿ Desea darla de alta ahora? ", 'Seleccione una opción' )
            lReturn := PuEdita( , 1, , , @cPublica )
         ELSE
            lReturn := .F.
         ENDIF
      ENDIF
   ENDIF

   IF lReturn == .F.
      oGet:cText( Space( 50 ) )
   ENDIF

   PU->( dbSetOrder( nOrder ) )
   PU->( dbGoto( nRecno ) )

   SELECT ( nArea )

   RETURN lReturn

/*_____________________________________________________________________________*/
FUNCTION PuEjemplares( oGrid, oParent )

   LOCAL oDlg, oBrowse, oCol
   LOCAL cPublica := PU->PuNombre
   LOCAL aEpoca   := { '0000', '0001', '0010', '0011', '0100', '0101', '0110', '0111', ;
      '1000', '1001', '1010', '1011', '1100', '1101', '1110', '1111' }
   LOCAL i
   LOCAL cTitle

   oApp():nEdit ++

   DEFINE DIALOG oDlg RESOURCE 'UT_EJEMPLARES'  ;
      TITLE 'Recetas de: ' + cPublica OF oParent
   oDlg:SetFont( oApp():oFont )

   SELECT RE
   RE->( dbSetOrder( 8 ) )
   RE->( dbSetFilter( {|| Trim( RE->RePublica ) == Trim( cPublica ) } ) )
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

   SELECT PU
   oGrid:Refresh()
   oGrid:SetFocus( .T. )
   oApp():nEdit --

   RETURN NIL

/*_____________________________________________________________________________*/

FUNCTION PuImprime( oGrid, oParent )

   LOCAL nRecno   := PU->( RecNo() )
   LOCAL nOrder   := PU->( ordSetFocus() )
   LOCAL aCampos  := { "PUNOMBRE", "PUPERIOD", "PUPRECIO", "PUEDITOR", "PUDIRECC", ;
      "PULOCALI", "PUPAIS", "PUTELEFONO", "PUFAX", "PUEMAIL", ;
      "PUURL", "PUNOTAS", "PUSUSCRIP", "PUPRESUS", "PUFCHPAGO", ;
      "PUFCHCAD", "PURECETAS" }
   LOCAL aTitulos := { "Publicación", "Periodicidad", "Precio", "Editor", "Dirección", ;
      "Localidad", "Pais", "Teléfono", "Fax", "e-mail", ;
      "Sitio web", "Notas", "Suscripción", "Precio Susc.", "Fch.Pago", ;
      "Fch.Expirac.", "Recetas" }
   LOCAL aWidth   := { 50, 10, 8, 50, 50, 50, 20, 30, 30, 50, 50, 255, 8, 8, 8, 8, 12 }
   LOCAL aShow    := { .T., .T., .T., .T., .T., .T., .T., .T., ;
      .T., .T., .T., .T., .T., .T., .T., .T., .T. }
   LOCAL aPicture := { "NO", "NO", "@E 999,999.99", "NO", "NO", ;
      "NO", "NO", "NO", "NO", "NO", ;
      "NO", "NO", "NO", "@E 999,999.99", "NO", "NO", "@E 99,999" }
   LOCAL aTotal   := { .F., .F., .T., .F., .F., .F., .F., .F., ;
      .F., .F., .F., .F., .F., .T., .F., .F., .T. }
   LOCAL oInforme

   oApp():nEdit ++

   oInforme := TInforme():New( aCampos, aTitulos, aWidth, aShow, aPicture, aTotal, "PU" )
   oInforme:Dialog()

   REDEFINE RADIO oInforme:oRadio VAR oInforme:nRadio ID 300, 301, 302 OF oInforme:oFld:aDialogs[ 1 ] ;
      ON CHANGE oInforme:Change()

   oInforme:Folders()

   IF oInforme:Activate()
      SELECT PU
      IF oInforme:nRadio == 2
         PU->( ordSetFocus( 2 ) )
      ENDIF
      PU->( dbGoTop() )
      oInforme:Report()
      IF oInforme:nRadio != 3
         ACTIVATE REPORT oInforme:oReport ;
            ON END ( oInforme:oReport:StartLine(), oInforme:oReport:EndLine(), oInforme:oReport:StartLine(), ;
            oInforme:oReport:Say( 1, 'Total Publicaciones: ' + Tran( oInforme:oReport:nCounter, '@E 999,999' ), 1 ), ;
            oInforme:oReport:EndLine() )
      ELSE
         ACTIVATE REPORT oInforme:oReport FOR Pu->PuSuscrip ;
            ON END ( oInforme:oReport:StartLine(), oInforme:oReport:EndLine(), oInforme:oReport:StartLine(), ;
            oInforme:oReport:Say( 1, 'Total Publicaciones: ' + Tran( oInforme:oReport:nCounter, '@E 999,999' ), 1 ), ;
            oInforme:oReport:EndLine() )
      ENDIF
      oInforme:End( .T. )
      PU->( ordSetFocus( nOrder ) )
      PU->( dbGoto( nRecno ) )
   ENDIF
   oApp():nEdit --
   oGrid:Refresh()
   oGrid:SetFocus( .T. )

   RETURN NIL
/*_____________________________________________________________________________*/


FUNCTION PuSort( nOrden, oCont )

   LOCAL nRecno := PU->( RecNo() )
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
   PU->( dbSetOrder( norden ) )
   PU->( dbGoto( nRecno ) )
   Refreshcont( ocont, "PU" )
   oApp():oGrid:Refresh( .T. )
   oApp():oGrid:SetFocus( .T. )

   RETURN NIL

FUNCTION PuList( aList, cData, oSelf )

   LOCAL aNewList := {}

   PU->( dbSetOrder( 1 ) )
   PU->( dbGoTop() )
   WHILE ! PU->( Eof() )
      IF At( Upper( cdata ), Upper( PU->PuNombre ) ) != 0 // UPPER( SubStr( oApp():amaterias[i,1], 1, Len( cData ) ) ) == UPPER( cData )
         AAdd( aNewList, { PU->PuNombre } )
      ENDIF
      PU->( dbSkip() )
   ENDDO

   RETURN aNewlist
