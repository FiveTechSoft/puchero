#include "FiveWin.ch"
#include "Report.ch"
#include "xBrowse.ch"
#include "vmenu.ch"
#include "AutoGet.ch"

STATIC oReport

FUNCTION Alimentos()

   LOCAL oBar, oCol, oCont
   LOCAL aBrowse
   LOCAL cState := GetPvProfString( "Browse", "AlState", "", oApp():cInifile )
   LOCAL nOrder := Max( Val( GetPvProfString( "Browse", "AlOrder", "1", oApp():cInifile ) ), 1 )
   LOCAL nRecno := Val( GetPvProfString( "Browse", "AlRecno", "1", oApp():cInifile ) )
   LOCAL nSplit := Val( GetPvProfString( "Browse", "AlSplit", "102", oApp():cInifile ) )
   LOCAL i, oAlMenu, oVMItem

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

   SELECT AL
   oApp():oDlg := TFsdi():New( oApp():oWndMain )
   oApp():oDlg:cTitle := i18n( 'Gestión de ingredientes de escandallos' )
   oApp():oWndMain:oClient := oApp():oDlg
   oApp():oDlg:NewGrid( nSplit )

   Ut_BrwRowConfig( oApp():oGrid )

   oApp():oGrid:cAlias := "AL"

   oCol := oApp():oGrid:AddCol()
   oCol:bLClickHeader := {|| ReSort( 1, oCont ) }
   oCol:Cargo := 1
   oCol:AddResource( "16_SORT_A" )
   oCol:AddResource( "16_SORT_B" )
   oCol:nHeadBmpNo    := iif( nOrder == 1, 1, 2 )
   oCol:nHeadBmpAlign := AL_RIGHT
   oCol:bStrData := {|| AL->AlAlimento }
   oCol:cHeader  := i18n( "Ingrediente" )
   oCol:nWidth   := 120

   oCol := oApp():oGrid:AddCol()
   oCol:bLClickHeader := {|| ReSort( 2, oCont ) }
   oCol:Cargo := 2
   oCol:AddResource( "16_SORT_A" )
   oCol:AddResource( "16_SORT_B" )
   oCol:nHeadBmpNo    := iif( nOrder == 2, 1, 2 )
   oCol:nHeadBmpAlign := AL_RIGHT
   oCol:bStrData := {|| AL->AlTipo }
   oCol:cHeader  := i18n( "Familia" )
   oCol:nWidth   := 120

   oCol := oApp():oGrid:AddCol()
   oCol:bLClickHeader := {|| ReSort( 3, oCont ) }
   oCol:Cargo := 3
   oCol:AddResource( "16_SORT_A" )
   oCol:AddResource( "16_SORT_B" )
   oCol:nHeadBmpNo    := iif( nOrder == 3, 1, 2 )
   oCol:nHeadBmpAlign := AL_RIGHT
   oCol:bStrData := {|| AL->AlCodigo }
   oCol:cHeader  := i18n( "Código" )
   oCol:nWidth   := 60

   oCol := oApp():oGrid:AddCol()
   oCol:bLClickHeader := {|| ReSort( 4, oCont ) }
   oCol:Cargo := 4
   oCol:AddResource( "16_SORT_A" )
   oCol:AddResource( "16_SORT_B" )
   oCol:nHeadBmpNo    := iif( nOrder == 4, 1, 2 )
   oCol:nHeadBmpAlign := AL_RIGHT
   oCol:bStrData := {|| AL->AlUltCom }
   oCol:cHeader  := i18n( "Ult. Compra" )
   oCol:nWidth   := 60

   oCol := oApp():oGrid:AddCol()
   oCol:bLClickHeader := {|| ReSort( 5, oCont ) }
   oCol:Cargo := 5
   oCol:AddResource( "16_SORT_A" )
   oCol:AddResource( "16_SORT_B" )
   oCol:nHeadBmpNo    := iif( nOrder == 5, 1, 2 )
   oCol:nHeadBmpAlign := AL_RIGHT
   oCol:bStrData := {|| AL->AlProveed }
   oCol:cHeader  := i18n( "Proveedor" )
   oCol:nWidth   := 150

   oCol := oApp():oGrid:AddCol()
   oCol:bLClickHeader := {|| ReSort( 6, oCont ) }
   oCol:Cargo := 6
   oCol:AddResource( "16_SORT_A" )
   oCol:AddResource( "16_SORT_B" )
   oCol:nHeadBmpNo    := iif( nOrder == 6, 1, 2 )
   oCol:nHeadBmpAlign := AL_RIGHT
   oCol:bStrData := {|| AL->AlUbicaci }
   oCol:cHeader  := i18n( "Ubicación" )
   oCol:nWidth   := 90

   oCol := oApp():oGrid:AddCol()
   oCol:bLClickHeader := {|| ReSort( 7, oCont ) }
   oCol:Cargo := 7
   oCol:AddResource( "16_SORT_A" )
   oCol:AddResource( "16_SORT_B" )
   oCol:nHeadBmpNo    := iif( nOrder == 7, 1, 2 )
   oCol:nHeadBmpAlign := AL_RIGHT
   oCol:bStrData := {|| AL->AlAccion }
   oCol:cHeader  := i18n( "Acción" )
   oCol:nWidth   := 90

   aBrowse   := { { {|| AL->AlUnidad }, i18n( "Unidad" ), 90, 0 }, ;
      { {|| TRAN( AL->AlPrecio, "@E 999,999.99" ) }, i18n( "Precio" ), 90, 1 }, ;
      { {|| AL->AlCodProv }, i18n( "Codigo Proveedor" ), 130, 0 }, ;
      { {|| TRAN( AL->AlStock, "@E9,999.99" ) }, i18n( "Stock" ), 90, 1 }, ;
      { {|| TRAN( AL->AlKCal, "@E9,999,999.99" ) }, i18n( "KCalorias" ), 90, 1 }, ;
      { {|| TRAN( AL->AlProt, "@E9,999,999.99" ) }, i18n( "Proteinas" ), 90, 1 }, ;
      { {|| TRAN( AL->AlHc, "@E9,999,999.99" ) }, i18n( "Hidratos" ), 90, 1 }, ;
      { {|| TRAN( AL->AlGt, "@E9,999,999.99" ) }, i18n( "Grasas totales" ), 90, 1 }, ;
      { {|| TRAN( AL->AlGs, "@E9,999,999.99" ) }, i18n( "Gr. Saturadas" ), 90, 1 }, ;
      { {|| TRAN( AL->AlGmi, "@E9,999,999.99" ) }, i18n( "Gr. Monoinsat." ), 90, 1 }, ;
      { {|| TRAN( AL->AlGpi, "@E9,999,999.99" ) }, i18n( "Gr. Poliinsat." ), 90, 1 }, ;
      { {|| TRAN( AL->AlCol, "@E9,999,999.99" ) }, i18n( "Colesterol" ), 90, 1 }, ;
      { {|| TRAN( AL->AlProt, "@E9,999,999.99" ) }, i18n( "Proteinas" ), 90, 1 }, ;
      { {|| TRAN( AL->AlFib, "@E9,999,999.99" ) }, i18n( "Fibras" ), 90, 1 }, ;
      { {|| TRAN( AL->AlNa, "@E9,999,999.99" ) }, i18n( "Sodio" ), 90, 1 }, ;
      { {|| TRAN( AL->AlCa, "@E9,999,999.99" ) }, i18n( "Calcio" ), 90, 1 } }

   FOR i := 1 TO Len( aBrowse )
      oCol := oApp():oGrid:AddCol()
      oCol:bStrData := aBrowse[ i, 1 ]
      oCol:cHeader  := aBrowse[ i, 2 ]
      oCol:nWidth   := aBrowse[ i, 3 ]
      oCol:nDataStrAlign := aBrowse[ i, 4 ]
      oCol:nHeadStrAlign := aBrowse[ i, 4 ]
   NEXT

   FOR i := 1 TO Len( oApp():oGrid:aCols )
      oCol := oApp():oGrid:aCols[ i ]
      oCol:bLDClickData  := {|| AlEdita( oApp():oGrid, 2, oCont, oApp():oDlg ) }
   NEXT

   oApp():oGrid:SetRDD()
   oApp():oGrid:CreateFromCode()
   oApp():oGrid:bChange  := {|| RefreshCont( oCont, "AL" ) }
   oApp():oGrid:bKeyDown := {| nKey| AlTecla( nKey, oApp():oGrid, oCont, oApp():oDlg ) }
   oApp():oGrid:nRowHeight  := 21

   oApp():oGrid:RestoreState( cState )

   AL->( dbSetOrder( nOrder ) )
   IF nRecNo < AL->( LastRec() ) .AND. nRecno != 0
      AL->( dbGoto( nRecno ) )
   ELSE
      AL->( dbGoTop() )
   ENDIF

   @ 02, 05 VMENU oCont SIZE nSplit - 10, 18 OF oApp():oDlg  ;
      COLOR CLR_BLACK, GetSysColor( 15 )       ;
      FILLED   ;  // BORDER
   COLORSELECT 0, CLR_WHITE ;
      HEIGHT ITEM 22

   DEFINE TITLE OF oCont ;
      CAPTION tran( AL->( ordKeyNo() ), '@E 999,999' ) + " / " + tran( AL->( ordKeyCount() ), '@E 999,999' ) ;// strZero( RE->( ordKeyCount() ), 6 ) ;
   HEIGHT 25 ;
      COLOR GetSysColor( 9 ), oApp():nClrBar ;
      IMAGE "BB_ALIMEN"

   @ 24, 05 VMENU oBar SIZE nSplit - 10, 180 OF oApp():oDlg  ;
      COLOR CLR_BLACK, GetSysColor( 15 )       ;
      HEIGHT ITEM 22 XBOX

   DEFINE TITLE OF oBar ;
      CAPTION "Ingredientes" ;
      HEIGHT 24 ;
      COLOR GetSysColor( 9 ), oApp():nClrBar ;
      OPENCLOSE


   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Nuevo"              ;
      IMAGE "16_NUEVO"             ;
      ACTION AlEdita( oApp():oGrid, 1, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Modificar"          ;
      IMAGE "16_MODIF"             ;
      ACTION AlEdita( oApp():oGrid, 2, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Duplicar"           ;
      IMAGE "16_DUPLICA"           ;
      ACTION AlEdita( oApp():oGrid, 3, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Borrar"             ;
      IMAGE "16_BORRAR"            ;
      ACTION AlBorra( oApp():oGrid, oCont );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Buscar"             ;
      IMAGE "16_BUSCA"             ;
      ACTION AlBusca( oApp():oGrid,, oCont, oApp():oDlg )  ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Imprimir"           ;
      IMAGE "16_IMPRIMIR"          ;
      ACTION AlImprime( oApp():oGrid, oApp():oDlg )  ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Ver recetas"        ;
      IMAGE "16_RECETAS"         ;
      ACTION AlRecetas( oApp():oGrid, oApp():oDlg )  ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Precio y Stock"     ;
      IMAGE "16_STOCK"          ;
      ACTION AlStock( oApp():oGrid, oApp():oDlg )  ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Incorporar CSV"     ;
      IMAGE "16_PROVEED"          ;
      ACTION AlCasaverdeCSV( oApp():oGrid, oApp():oDlg )  ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 10

   MENU oAlMenu POPUP // 2007
   MENUITEM "Sin filtro" ;
      ACTION AlFilter( 0, oCont, oAlMenu, oBar, oVMItem );
      CHECKED
   SEPARATOR
   MENUITEM "Filtrar por familia" ;
      ACTION AlFilter( 1, oCont, oAlMenu, oBar, oVMitem )
   MENUITEM "Filtrar por proveedor" ;
      ACTION AlFilter( 2, oCont, oAlMenu, oBar, oVMitem )
   MENUITEM "Filtrar por ubicación" ;
      ACTION AlFilter( 3, oCont, oAlMenu, oBar, oVMitem )
   ENDMENU

   DEFINE VMENUITEM oVMItem OF oBar  ;
      CAPTION "Filtrar alimentos"    ;
      IMAGE "16_FILTRO"              ;
      MENU oAlMenu        ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Enviar a Excel"     ;
      IMAGE "16_EXCEL"             ;
      ACTION ( CursorWait(), Ut_ExportXLS( oApp():oGrid, "Alimentos" ), CursorArrow() );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Configurar rejilla" ;
      IMAGE "16_GRID"              ;
      ACTION Ut_BrwColConfig( oApp():oGrid, "AlState" ) ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Salir"              ;
      IMAGE "16_SALIR"             ;
      ACTION oApp():oDlg:End()              ;
      LEFT 10

   @ oApp():oDlg:nGridBottom, nSplit + 2 TABS oApp():oTab ;
      OPTION nOrder SIZE oApp():oWndMain:nWidth() -80, 12 PIXEL OF oApp():oDlg ;
      ITEMS ' Ingrediente ', ' Familia ', ' Código ', ' Ultima compra ', ' Proveedor ', ' Ubicación ', ' Acción ' ;
      ACTION AlSort( oApp():otab:noption, oCont )

   oApp():oDlg:NewSplitter( nSplit, oCont, oBar )

   ACTIVATE DIALOG oApp():oDlg NOWAIT ;
      ON INIT ( ResizeWndMain(), oApp():oGrid:SetFocus() ) ;
      VALID ( oApp():oGrid:nLen := 0, ;
      WritePProString( "Browse", "AlState", oApp():oGrid:SaveState(), oApp():cInifile ), ;
      WritePProString( "Browse", "AlOrder", LTrim( Str( AL->( ordNumber() ) ) ), oApp():cInifile ), ;
      WritePProString( "Browse", "AlRecno", LTrim( Str( AL->( RecNo() ) ) ), oApp():cInifile ), ;
      WritePProString( "Browse", "AlSplit", LTrim( Str( oApp():oSplit:nleft / 2 ) ), oApp():cInifile ), ;
      oBar:End(), dbCloseAll(), oApp():oDlg := NIL, oApp():oGrid := NIL, oApp():oTab := NIL, .T. )

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION AlEdita( oGrid, nMode, oCont, oParent )

   LOCAL oDlg, oFld, oBmp
   LOCAL aTitle := { i18n( "Añadir ingrediente" ), ;
      i18n( "Modificar ingrediente" ), ;
      i18n( "Duplicar ingrediente" ) }
   LOCAL aGet[ 27 ]
   LOCAL cAlCodigo, ;
      cAlTipo, ;
      cAlAlimento, ;
      cAlUnidad, ;
      nAlPrecio, ;
      dAlUltCom, ;
      nAlKCal, ;
      nAlProt, ;
      nAlHc, ;
      nAlGt, ;
      nAlGs, ;
      nAlGmi, ;
      nAlGpi, ;
      nAlCol, ;
      nAlFib, ;
      nAlNa, ;
      nAlCa, ;
      cAlProveed, ;
      cAlCodProv, ;
      nAlStock, ;
      cAlUbicaci, ;
      cAlAccion

   LOCAL nRecPtr := AL->( RecNo() )
   LOCAL nOrden  := AL->( ordNumber() )
   LOCAL nRecAdd
   LOCAL lDuplicado
   LOCAL nTsRecno, nEsRecno, nEsOrder

   IF AL->( Eof() ) .AND. nMode != 1
      RETURN NIL
   ENDIF

   oApp():nEdit ++

   IF nMode == 1
      AL->( dbAppend() )
      nRecAdd := AL->( RecNo() )
   ENDIF
   cAlCodigo   := AL->AlCodigo
   cAlTipo     := AL->AlTipo
   cAlAlimento := AL->AlAlimento
   cAlUnidad   := AL->AlUnidad
   nAlPrecio   := AL->AlPrecio
   dAlUltCom   := AL->AlUltCom
   nAlKCal     := AL->AlKCal
   nAlProt     := AL->AlProt
   nAlHc       := AL->AlHc
   nAlGt       := AL->AlGt
   nAlGs       := AL->AlGs
   nAlGmi      := AL->AlGmi
   nAlGpi      := AL->AlGpi
   nAlCol      := AL->AlCol
   nAlFib      := AL->AlFib
   nAlNa       := AL->AlNa
   nAlCa       := AL->AlCa
   cAlProveed  := AL->AlProveed
   cAlCodProv  := AL->AlCodProv
   nAlStock    := AL->AlStock
   cAlUbicaci  := AL->AlUbicaci
   cAlAccion   := AL->AlAccion

   IF nMode == 3
      AL->( dbAppend() )
      nRecAdd := AL->( RecNo() )
   ENDIF

   DEFINE DIALOG oDlg RESOURCE "AL_EDIT_" + oApp():cLanguage OF oParent   ;
      TITLE aTitle[ nMode ]
   oDlg:SetFont( oApp():oFont )

   REDEFINE AUTOGET aGet[ 1 ] VAR cAlTipo;
      DATASOURCE {}      ;
      FILTER GrList( uDataSource, cData, Self );
      HEIGHTLIST 100 ;
      ID 101 OF oDlg UPDATE            ;
      VALID GrClave( @cAlTipo, aGet[ 1 ], 4 )

   REDEFINE BUTTON aGet[ 19 ]            ;
      ID 130 OF oDlg                   ;
      ACTION GrSeleccion( cAlTipo, aGet[ 1 ], oDlg )
   aGet[ 19 ]:cTooltip := i18n( "seleccionar familia" )

   REDEFINE GET aGet[ 2 ] VAR cAlAlimento;
      ID 102 OF oDlg UPDATE            ;
      VALID AlClave( cAlAlimento, aGet, nMode, 1, .F. )

   REDEFINE GET aGet[ 3 ] VAR cAlcodigo  ;
      ID 115 OF oDlg UPDATE            ;
      VALID AlClave( cAlAlimento, aGet, nMode, 3, .F. )

   REDEFINE GET aGet[ 4 ] VAR cAlUnidad  ;
      ID 116 OF oDlg UPDATE

   REDEFINE GET aGet[ 5 ] VAR nAlKcal    ;
      ID 103 OF oDlg UPDATE            ;
      PICTURE '@E 99,999.99'

   REDEFINE GET aGet[ 6 ] VAR nAlProt    ;
      ID 104 OF oDlg UPDATE            ;
      PICTURE '@E 99,999.99'

   REDEFINE GET aGet[ 7 ] VAR nAlHc      ;
      ID 105 OF oDlg UPDATE            ;
      PICTURE '@E 99,999.99'

   REDEFINE GET aGet[ 8 ] VAR nAlGt      ;
      ID 106 OF oDlg UPDATE            ;
      PICTURE '@E 99,999.99'

   REDEFINE GET aGet[ 9 ] VAR nAlGs      ;
      ID 107 OF oDlg UPDATE            ;
      PICTURE '@E 99,999.99'

   REDEFINE GET aGet[ 10 ] VAR nAlGmi    ;
      ID 108 OF oDlg UPDATE            ;
      PICTURE '@E 99,999.99'

   REDEFINE GET aGet[ 11 ] VAR nAlGpi    ;
      ID 109 OF oDlg UPDATE            ;
      PICTURE '@E 99,999.99'

   REDEFINE GET aGet[ 12 ] VAR nAlCol    ;
      ID 110 OF oDlg UPDATE            ;
      PICTURE '@E 99,999.99'

   REDEFINE GET aGet[ 13 ] VAR nAlfib    ;
      ID 111 OF oDlg UPDATE            ;
      PICTURE '@E 99,999.99'

   REDEFINE GET aGet[ 14 ] VAR nAlna     ;
      ID 112 OF oDlg UPDATE            ;
      PICTURE '@E 99,999.99'

   REDEFINE GET aGet[ 15 ] VAR nAlca     ;
      ID 113 OF oDlg UPDATE            ;
      PICTURE '@E 99,999.99'

   REDEFINE GET aGet[ 16 ] VAR nAlprecio ;
      ID 117 OF oDlg UPDATE            ;
      PICTURE '@E 9,999,999.99'

   REDEFINE GET aGet[ 17 ] VAR dAlUltCom  ;
      ID 118 OF oDlg UPDATE

   REDEFINE BUTTON aGet[ 20 ]            ;
      ID 131 OF oDlg                   ;
      ACTION SelecFecha( dAlUltCom, aGet[ 17 ] )
   aGet[ 20 ]:cTooltip := i18n( "seleccionar fecha" )

   REDEFINE AUTOGET aGet[ 18 ] VAR cAlProveed;
      DATASOURCE {}      ;
      FILTER PrList( uDataSource, cData, Self );
      HEIGHTLIST 100 ;
      ID 119 OF oDlg UPDATE            ;
      VALID PrClave( @cAlProveed, aGet[ 18 ], 4 )

   REDEFINE BUTTON aGet[ 21 ]            ;
      ID 132 OF oDlg                   ;
      ACTION PrSeleccion( cAlProveed, aGet[ 18 ], oDlg )
   aGet[ 21 ]:cTooltip := i18n( "seleccionar proveedor" )

   REDEFINE GET aGet[ 22 ] VAR cAlCodProv  ;
      ID 120 OF oDlg UPDATE

   REDEFINE GET aGet[ 23 ] VAR nAlStock  ;
      ID 121 OF oDlg UPDATE            ;
      PICTURE '@E 9,999.99'

   REDEFINE AUTOGET aGet[ 24 ] VAR cAlUbicaci;
      DATASOURCE {}      ;
      FILTER UbList( uDataSource, cData, Self );
      HEIGHTLIST 100 ;
      ID 122 OF oDlg UPDATE            ;
      VALID UbClave( @cAlUbicaci, aGet[ 24 ], 4 )

   REDEFINE BUTTON aGet[ 25 ]            ;
      ID 133 OF oDlg                   ;
      ACTION UbSeleccion( cAlUbicaci, aGet[ 24 ], oDlg )
   aGet[ 25 ]:cTooltip := i18n( "seleccionar ubicación" )

   REDEFINE AUTOGET aGet[ 26 ] VAR cAlAccion;
      DATASOURCE {}      ;
      FILTER AcList( uDataSource, cData, Self );
      HEIGHTLIST 100 ;
      ID 123 OF oDlg UPDATE            ;
      VALID AcClave( @cAlAccion, aGet[ 26 ], 4 ) ;
      WHEN oApp():lBcnKitchen

   REDEFINE BUTTON aGet[ 27 ]            ;
      ID 134 OF oDlg                   ;
      ACTION AcSeleccion( cAlAccion, aGet[ 26 ], oDlg ) ;
      WHEN oApp():lBcnKitchen
   aGet[ 19 ]:cTooltip := i18n( "seleccionar accion" )

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

      /* ___ actualizo el fichero de escandallo _______________________________*/
      IF nMode == 2
         IF SELECT( "TS" ) != 0
            SELECT TS
            nTsRecno := TS->( RecNo() )
            TS->( dbSetOrder( 0 ) )
            TS->( dbGoTop() )
            DO WHILE ! TS->( Eof() )
               IF TS->EsIngred == AL->AlCodigo
                  REPLACE TS->EsIngred    WITH cAlCodigo
                  REPLACE TS->EsInDenomi  WITH cAlAlimento
                  REPLACE TS->EsPrecio    WITH TS->EsCantidad * nAlPrecio
                  REPLACE TS->EsKCal      WITH TS->EsCantidad * nAlKCal
               ENDIF
               TS->( dbSkip() )
            ENDDO
            TS->( dbSetOrder( 1 ) )
            TS->( dbGoto( nTsRecno ) )
         ENDIF

         SELECT ES
         nEsRecno := ES->( RecNo() )
         nEsOrder := ES->( ordNumber() )
         ES->( dbSetOrder( 0 ) )
         ES->( dbGoTop() )
         DO WHILE ! ES->( Eof() )
            IF ES->EsIngred == AL->AlCodigo
               REPLACE ES->EsIngred    WITH cAlCodigo
               REPLACE ES->EsInDenomi  WITH cAlAlimento
               REPLACE ES->EsPrecio    WITH ES->EsCantidad * nAlPrecio
               REPLACE ES->EsKCal      WITH ES->EsCantidad * nAlKCal
            ENDIF
            ES->( dbSkip() )
         ENDDO
         ES->( dbSetOrder( nEsOrder ) )
         ES->( dbGoto( nEsRecno ) )
      ENDIF
      /* ___ computo el proveedor ____________________________________*/
      SELECT UB
      PR->( dbSetOrder( 1 ) )
      IF AL->AlUbicaci <> cAlUbicaci
         UB->( dbSeek( Upper( cAlUbicaci ) ) )
         REPLACE UB->UbAliment WITH UB->UbAliment + 1
         IF nMode == 2
            UB->( dbSeek( Upper( AL->AlUbicaci ) ) )
            REPLACE UB->UbAliment WITH UB->UbAliment - 1
         ENDIF
         UB->( dbCommit() )
      ENDIF
      /* ___ computo la ubicación ____________________________________*/
      SELECT UB
      UB->( dbSetOrder( 1 ) )
      IF AL->AlProveed <> cAlProveed
         PR->( dbSeek( Upper( cAlProveed ) ) )
         REPLACE PR->PrAliment WITH PR->PrAliment + 1
         IF nMode == 2
            PR->( dbSeek( Upper( AL->AlProveed ) ) )
            REPLACE PR->PrAliment WITH PR->PrAliment - 1
         ENDIF
         PR->( dbCommit() )
      ENDIF
      /* ___ computo la accion ____________________________________*/
      SELECT AC
      AC->( dbSetOrder( 1 ) )
      IF AL->AlAccion <> cAlAccion
         AC->( dbSeek( Upper( cAlAccion ) ) )
         REPLACE AC->AcAliment WITH AC->AcAliment + 1
         IF nMode == 2
            AC->( dbSeek( Upper( AL->AlUbicaci ) ) )
            REPLACE AC->AcAliment WITH AC->AcAliment - 1
         ENDIF
         AC->( dbCommit() )
      ENDIF
      /* ___ guardo el registro _______________________________________________*/
      IF nMode == 2
         AL->( dbGoto( nRecPtr ) )
      ELSE
         AL->( dbGoto( nRecAdd ) )
      ENDIF
      REPLACE AL->AlCodigo   WITH cAlCodigo
      REPLACE AL->AlTipo     WITH cAlTipo
      REPLACE AL->AlAlimento WITH cAlAlimento
      REPLACE AL->AlUnidad   WITH cAlUnidad
      REPLACE AL->AlPrecio   WITH nAlPrecio
      REPLACE AL->AlUltCom   WITH dAlUltCom
      REPLACE AL->AlKCal     WITH nAlKCal
      REPLACE AL->AlProt     WITH nAlProt
      REPLACE AL->AlHc       WITH nAlHc
      REPLACE AL->AlGt       WITH nAlGt
      REPLACE AL->AlGs       WITH nAlGs
      REPLACE AL->AlGmi      WITH nAlGmi
      REPLACE AL->AlGpi      WITH nAlGpi
      REPLACE AL->AlCol      WITH nAlCol
      REPLACE AL->AlFib      WITH nAlFib
      REPLACE AL->AlNa       WITH nAlNa
      REPLACE AL->AlCa       WITH nAlCa
      REPLACE AL->AlProveed  WITH cAlProveed
      REPLACE AL->AlCodProv  WITH cAlCodProv
      REPLACE AL->AlStock   WITH nAlStock
      REPLACE AL->AlUbicaci  WITH cAlUbicaci
      REPLACE AL->AlAccion   WITH cAlAccion
      AL->( dbCommit() )
      // recargo el autocompletado de ingredientes
   ELSE
      IF nMode == 1 .OR. nMode == 3
         AL->( dbGoto( nRecAdd ) )
         AL->( dbDelete() )
         AL->( DbPack() )
         AL->( dbGoto( nRecPtr ) )
      ENDIF
   ENDIF

   SELECT AL

   IF oCont != nil
      RefreshCont( oCont, "AL" )
   ENDIF
   oApp():nEdit --
   IF oGrid != NIL
      oGrid:Refresh()
      oGrid:SetFocus( .T. )
   ENDIF

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION AlBorra( oGrid, oCont )

   LOCAL nRecord := AL->( RecNo() )
   LOCAL nNext

   oApp():nEdit ++

   IF msgYesNo( i18n( "¿ Está seguro de querer borrar este ingrediente ?" ) + CRLF + ;
         ( Trim( AL->AlAlimento ) ), 'Seleccione una opción' )

      SELECT ES
      ES->( dbSetOrder( 2 ) )
      ES->( dbSeek( AL->AlCodigo ) )
      DO WHILE ES->EsIngred == AL->AlCodigo .AND. ! ES->( Eof() )
         ES->( dbDelete() )
         ES->( dbSkip() )
      ENDDO
      ES->( DbPack() )

      /* ___ computo la ubicación ____________________________________*/
      SELECT UB
      UB->( dbSetOrder( 1 ) )
      UB->( dbSeek( Upper( UB->UbUbicaci ) ) )
      REPLACE UB->UbAliment WITH UB->UbAliment - 1
      UB->( dbCommit() )

      SELECT AL
      AL->( dbSkip() )
      nNext := AL->( RecNo() )
      AL->( dbGoto( nRecord ) )

      AL->( dbDelete() )
      AL->( DbPack() )
      AL->( dbGoto( nNext ) )
      IF AL->( Eof() ) .OR. nNext == nRecord
         AL->( dbGoBottom() )
      ENDIF
   ENDIF

   IF oCont != nil
      RefreshCont( oCont, "AL" )
   ENDIF

   oGrid:Refresh( .T. )
   oGrid:SetFocus( .T. )

   oApp():nEdit --

   RETURN NIL
/*_____________________________________________________________________________*/
FUNCTION AlFilter( i, oCont, oMenu, oBar, oVItem )

   LOCAL cAlTipo    := Space( 20 )
   LOCAL cAlProveed := Space( 50 )
   LOCAL cAlUbicaci := Space( 40 )
   LOCAL j := 0
   LOCAL aFiltro := { "Familia", "Proveedor", "Ubicación" }
		
   IF i == 0
      AL->( dbClearFilter() )
      j := 0
   ELSEIF i == 1
      // familia
      GrSeleccion( @cAlTipo, , oApp():oDlg, oVItem )
      IF cAlTipo != Space( 20 )
         AL->( dbSetFilter( {|| Upper( RTrim( Al->AlTipo ) ) == Upper( RTrim( cAlTipo ) ) } ) )
         j := 3
      ELSE
         AL->( dbClearFilter() )
         j := 0
      ENDIF
   ELSEIF i == 2
      // proveedor
      PrSeleccion( @cAlProveed, , oApp():oDlg, oVItem )
      IF cAlProveed != Space( 50 )
         AL->( dbSetFilter( {|| Upper( RTrim( Al->Alproveed ) ) == Upper( RTrim( cAlProveed ) ) } ) )
         j := 4
      ELSE
         AL->( dbClearFilter() )
         j := 0
      ENDIF
   ELSEIF i == 3
      // ubicación
      UbSeleccion( @cAlUbicaci, , oApp():oDlg, oVItem )
      IF cAlUbicaci != Space( 40 )
         AL->( dbSetFilter( {|| Upper( RTrim( Al->AlUbicaci ) ) == Upper( RTrim( cAlUbicaci ) ) } ) )
         j := 5
      ELSE
         AL->( dbClearFilter() )
         j := 0
      ENDIF
   ENDIF

   AL->( dbGoTop() )
   RefreshCont( oCont, "AL" )
   oApp():oGrid:Refresh( .T. )
   FOR i := 1 TO Len( oMenu:aItems )
      oMenu:aItems[ i ]:SetCheck( .F. )
   NEXT
   IF j == 0
      oMenu:aItems[ 1 ]:SetCheck( .T. )
      oBar:cTitle := "Ingredientes"
      oVItem:SetColor( CLR_BLACK )
   ELSE
      oMenu:aItems[ j ]:SetCheck( .T. )
      oBar:cTitle := "Ingredientes [ ** " + RTrim( aFiltro[ j - 2 ] ) + " ** ]"
      oVItem:SetColor( CLR_HRED ) // oBar:nClrBox)
   ENDIF
   oBar:Refresh()

   RETURN NIL
// _____________________________________________________________________________//

FUNCTION AlTecla( nKey, oGrid, oCont, oDlg )

   DO CASE
   CASE nKey == VK_RETURN
      AlEdita( oGrid, 2, oCont, oDlg )
   CASE nKey == VK_INSERT
      AlEdita( oGrid, 1, oCont, oDlg )
   CASE nKey == VK_DELETE
      AlBorra( oGrid, oCont )
   CASE nKey == VK_ESCAPE
      oDlg:End()
   OTHERWISE
      IF nKey >= 96 .AND. nKey <= 105
         AlBusca( oGrid, Str( nKey - 96, 1 ), oCont, oDlg )
      ELSEIF HB_ISSTRING( Chr( nKey ) )
         AlBusca( oGrid, Chr( nKey ), oCont, oDlg )
      ENDIF
   ENDCASE

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION AlSeleccion( cPublica, aControl, oParent )

   LOCAL oDlg, oBrowse, oCol, oBtnAceptar, oBtnCancel, oBNew, oBMod, oBDel, oBBus
   LOCAL lOk    := .F.
   LOCAL nArea  := Select()
   LOCAL aPoint := AdjustWnd( aControl[ 1 ], 271 * 2, 150 * 2 )

   // siempre tengo ordenado por nombre
   SELECT AL
   AL->( dbSetOrder( 1 ) )
   AL->( dbGoTop() )

   DEFINE DIALOG oDlg RESOURCE 'UT_AJENA1_' + oApp():cLanguage OF oParent ;
      TITLE i18n( "Selección de Alimentos para escandallo" )
   oDlg:SetFont( oApp():oFont )

   oBrowse := TXBrowse():New( oDlg )
   Ut_BrwRowConfig( oBrowse )
   oBrowse:cAlias := "AL"

   oCol := oBrowse:AddCol()
   oCol:bStrData := {|| AL->AlAlimento }
   oCol:cHeader  := "Ingrediente"
   oCol:nWidth   := 120
   oCol:bLDClickData  := {|| ( lOk := .T., oDlg:End() )   }
   oCol:bClrSelFocus  := {|| { CLR_BLACK, oApp():nClrHL } }
   oCol := oBrowse:AddCol()
   oCol:bStrData := {|| AL->AlCodigo }
   oCol:cHeader  := "Código"
   oCol:nWidth   := 50
   oCol:bLDClickData  := {|| ( lOk := .T., oDlg:End() )   }
   oCol:bClrSelFocus  := {|| { CLR_BLACK, oApp():nClrHL } }
   oCol := oBrowse:AddCol()
   oCol:bStrData := {|| AL->AlUnidad }
   oCol:cHeader  := "Unidad"
   oCol:nWidth   := 50
   oCol:bLDClickData  := {|| ( lOk := .T., oDlg:End() )   }
   oCol:bClrSelFocus  := {|| { CLR_BLACK, oApp():nClrHL } }
   oCol := oBrowse:AddCol()
   oCol:bStrData := {|| AL->AlTipo }
   oCol:cHeader  := "Familia"
   oCol:nWidth   := 50
   oCol:bLDClickData  := {|| ( lOk := .T., oDlg:End() )   }
   oCol:bClrSelFocus  := {|| { CLR_BLACK, oApp():nClrHL } }
   oBrowse:SetRDD()
   oBrowse:CreateFromResource( 110 )
   oBrowse:bKeyDown := {| nKey| AlSeTecla( nKey, oBrowse, oDlg, oBtnAceptar ) }

   REDEFINE BUTTON oBNew   ;
      ID 410 OF oDlg       ;
      ACTION AlEdita( oBrowse, 1,, oDlg )

   REDEFINE BUTTON oBMod   ;
      ID 411 OF oDlg       ;
      ACTION AlEdita( oBrowse, 2,, oDlg )

   REDEFINE BUTTON oBDel   ;
      ID 412 OF oDlg       ;
      ACTION AlBorra( oBrowse, )

   REDEFINE BUTTON oBBus   ;
      ID 413 OF oDlg       ;
      ACTION AlBusca( oBrowse,,, oDlg )

   REDEFINE BUTTON oBtnAceptar   ;
      ID IDOK OF oDlg            ;
      ACTION ( lOk := .T., oDlg:End() )

   REDEFINE BUTTON oBtnCancel    ;
      ID IDCANCEL OF oDlg        ;
      ACTION ( lOk := .F., oDlg:End() )

   ACTIVATE DIALOG oDlg CENTERED       ;
      ON PAINT oDlg:Move( aPoint[ 1 ], aPoint[ 2 ],,, .T. )

   IF lOK
      aControl[ 1 ]:cText := AL->AlCodigo
      aControl[ 2 ]:cText := AL->AlAlimento
      aControl[ 3 ]:cText := AL->AlUnidad
      aControl[ 4 ]:cText := 1
      aControl[ 5 ]:cText := AL->AlPrecio
      aControl[ 6 ]:cText := AL->AlKCal
      aControl[ 8 ]:cText := AL->AlProveed
   ENDIF
   SELECT ( nArea )

   RETURN lOk
/*_____________________________________________________________________________*/
FUNCTION AlSeTecla( nKey, oGrid, oDlg, oBtn )

   DO CASE
   CASE nKey == VK_RETURN
      oBtn:Click()
   CASE nKey == VK_ESCAPE
      oDlg:End()
   OTHERWISE
      IF nKey >= 96 .AND. nKey <= 105
         AlBusca( oGrid, Str( nKey - 96, 1 ),, oDlg )
      ELSEIF HB_ISSTRING( Chr( nKey ) )
         AlBusca( oGrid, Chr( nKey ),, oDlg )
      ENDIF
   ENDCASE

   RETURN NIL
/*_____________________________________________________________________________*/
FUNCTION AlBusca( oGrid, cChr, oCont, oParent )

   LOCAL nOrder   := AL->( ordNumber() )
   LOCAL nRecno   := AL->( RecNo() )
   LOCAL oDlg, oGet, cGet, cPicture
   LOCAL aSay1    := { " Introduzca el nombre de ingrediente", ;
      " Introduzca la familia de ingrediente", ;
      " Introduzca el código de ingrediente", ;
      " Introduzca la fecha de última compra", ;
      " Introduzca el nombre del proveedor", ;
      " Introduzca la ubicación", ;
      " Introduzca la acción"   }
   LOCAL aSay2    := { "Ingrediente:", ;
      "Familia:", ;
      "Código:", ;
      "Fecha:", ;
      "Proveedor:", ;
      "Ubicación:", ;
      "Acción:"   }
   LOCAL aGet     := { Space( 25 ), ;
      Space( 20 ), ;
      Space( 6 ), ;
      CToD( "" ), ;
      Space( 50 ), ;
      Space( 40 ), ;
      Space( 8 ) }
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

   IF nOrder == 4
      lFecha := .T.
   ENDIF

   /*__ si he pasado un caracter lo meto en la cadena a buscar ________________*/

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
      ON INIT ( DlgCenter( oDlg, oApp():oWndMain ) )// , Iif(cChr!=nil,oGet:SetPos(2),), oGet:Refresh() )
	
   IF lSeek
      IF ! lFecha
         cGet := RTrim( Upper( cGet ) )
      ELSE
         // cGet := DtoS(cGet)
      ENDIF
      MsgRun( 'Realizando la búsqueda...', oApp():cAppName + oApp():cVersion, ;
         {|| AlWildSeek( nOrder, cGet, aBrowse ) } )
      IF Len( aBrowse ) == 0
         MsgStop( "No se ha encontrado ningun alimento.", 'Atención' )
      ELSE
         AlEncontrados( aBrowse, oApp():oDlg )
      ENDIF
   ENDIF
	
   IF oCont != NIL
      RefreshCont( oCont, "AL" )
   ENDIF
   oGrid:Refresh()
   oGrid:SetFocus( .T. )
   RefreshReBarImage()
   oApp():nEdit --
	
   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION AlRecetas( oGrid, oParent )

   LOCAL oDlg, oBrowse, oCol
   LOCAL cAlCodigo := AL->AlCodigo
   LOCAL aEpoca   := { '0000', '0001', '0010', '0011', '0100', '0101', '0110', '0111', ;
      '1000', '1001', '1010', '1011', '1100', '1101', '1110', '1111' }
   LOCAL i
   LOCAL cTitle
   LOCAL aRecetas := {}

   ES->( dbGoTop() )
   RE->( ordSetFocus( 2 ) )
   WHILE ! ES->( Eof() )
      IF ES->EsIngred == cAlCodigo
         RE->( dbGoTop() )
         IF RE->( dbSeek( Upper( ES->EsReceta ) ) )
            AAdd( aRecetas, { RE->ReTitulo, RE->ReCodigo, RE->ReAutor, RE->ReEpoca, RE->ReDificu, RE->ReFchPrep } )
         ENDIF
      ENDIF
      ES->( dbSkip() )
   END
   IF Len( aRecetas ) == 0
      MsgStop( 'El ingrediente no aparece en ninguna receta.' )
      RETU NIL
   ENDIF

   oApp():nEdit ++
   DEFINE DIALOG oDlg RESOURCE 'UT_EJEMPLARES'  ;
      TITLE 'Recetas con: ' + AL->AlCodigo + ' ' + AL->AlAlimento OF oParent
   oDlg:SetFont( oApp():oFont )

   oBrowse := TXBrowse():New( oDlg )
   Ut_BrwRowConfig( oBrowse )
   oBrowse:SetArray( aRecetas, .F. )
   oBrowse:cAlias := "RE"
	
   oBrowse:aCols[ 1 ]:cHeader  := "Receta"
   oBrowse:aCols[ 1 ]:nWidth   := 290

   oBrowse:aCols[ 2 ]:cHeader  := "Código"
   oBrowse:aCols[ 2 ]:nWidth   := 90
	
   oBrowse:aCols[ 3 ]:cHeader  := "Autor"
   oBrowse:aCols[ 3 ]:nWidth   := 110

   oBrowse:aCols[ 4 ]:AddResource( "BR_EPOCA0000" )
   oBrowse:aCols[ 4 ]:AddResource( "BR_EPOCA0001" )
   oBrowse:aCols[ 4 ]:AddResource( "BR_EPOCA0010" )
   oBrowse:aCols[ 4 ]:AddResource( "BR_EPOCA0011" )
   oBrowse:aCols[ 4 ]:AddResource( "BR_EPOCA0100" )
   oBrowse:aCols[ 4 ]:AddResource( "BR_EPOCA0101" )
   oBrowse:aCols[ 4 ]:AddResource( "BR_EPOCA0110" )
   oBrowse:aCols[ 4 ]:AddResource( "BR_EPOCA0111" )
   oBrowse:aCols[ 4 ]:AddResource( "BR_EPOCA1000" )
   oBrowse:aCols[ 4 ]:AddResource( "BR_EPOCA1001" )
   oBrowse:aCols[ 4 ]:AddResource( "BR_EPOCA1010" )
   oBrowse:aCols[ 4 ]:AddResource( "BR_EPOCA1011" )
   oBrowse:aCols[ 4 ]:AddResource( "BR_EPOCA1100" )
   oBrowse:aCols[ 4 ]:AddResource( "BR_EPOCA1101" )
   oBrowse:aCols[ 4 ]:AddResource( "BR_EPOCA1110" )
   oBrowse:aCols[ 4 ]:AddResource( "BR_EPOCA1111" )
   oBrowse:aCols[ 4 ]:cHeader  := i18n( "Epoca" )
   oBrowse:aCols[ 4 ]:bBmpData := {|| Max( AScan( aEpoca, StrTran( Str( aRecetas[ oBrowse:nArrayAt, 4 ], 4 ), ' ', '0' ) ), 1 ) }
   oBrowse:aCols[ 4 ]:nWidth        := 80
   oBrowse:aCols[ 4 ]:nDataBmpAlign := 2
   oBrowse:aCols[ 4 ]:bStrData := {|| '' }

   oBrowse:aCols[ 5 ]:AddResource( "BR_Dif1" )
   oBrowse:aCols[ 5 ]:AddResource( "BR_Dif2" )
   oBrowse:aCols[ 5 ]:AddResource( "BR_Dif3" )
   oBrowse:aCols[ 5 ]:cHeader       := i18n( "Dif." )
   oBrowse:aCols[ 5 ]:bBmpData      := {|| Max( aRecetas[ oBrowse:nArrayAt, 5 ], 1 ) }
   oBrowse:aCols[ 5 ]:nWidth        := 30
   oBrowse:aCols[ 5 ]:nDataBmpAlign := 2
   oBrowse:aCols[ 5 ]:bStrData := {|| '' }

   oBrowse:aCols[ 6 ]:cHeader       := "Fecha Prep."
   oBrowse:aCols[ 6 ]:nWidth        := 90

   RE->( dbSeek( aRecetas[ oBrowse:nArrayAt, 2 ] ) )
   // oBrowse:bKeyDown  := {|nKey| IIF(nKey==VK_RETURN,(AU->(DbGoTo(aBrowse[oBrowse:nArrayAt, 4])),;
   // AuEdita( , 2,, oApp():oDlg )),) }
   // oBrowse:bChange   := { || AU->(DbGoTo(aBrowse[oBrowse:nArrayAt, 4])) }
   FOR i := 1 TO Len( oBrowse:aCols )
      oCol := oBrowse:aCols[ i ]
      oCol:bLDClickData  := {|| ( RE->( dbSeek( aRecetas[ oBrowse:nArrayAt, 2 ] ) ), ReEdita( oBrowse, 2,, oDlg ) ) }
      oCol:bClrSelFocus  := {|| { CLR_BLACK, oApp():nClrHL } }
   NEXT

   oBrowse:CreateFromResource( 110 )

   REDEFINE BUTTON ID IDOK OF oDlg ;
      PROMPT i18n( "&Aceptar" )   ;
      ACTION oDlg:End()

   ACTIVATE DIALOG oDlg ;
      ON INIT DlgCenter( oDlg, oApp():oWndMain )

   SELECT AL
   oGrid:Refresh()
   oGrid:SetFocus( .T. )
   oApp():nEdit --

   RETURN NIL

/*_____________________________________________________________________________*/
	
FUNCTION AlWildSeek( nOrder, cGet, aBrowse )

   LOCAL nRecno   := RE->( RecNo() )

   DO CASE
   CASE nOrder == 1
      AL->( dbGoTop() )
      DO WHILE ! AL->( Eof() )
         IF cGet $ Upper( AL->AlAlimento )
            AAdd( aBrowse, { AL->AlCodigo, AL->AlAlimento, AL->AlTipo, AL->AlUnidad, AL->( RecNo() ) } )
         ENDIF
         AL->( dbSkip() )
      ENDDO
   CASE nOrder == 2
      AL->( dbGoTop() )
      DO WHILE ! AL->( Eof() )
         IF cGet $ Upper( AL->AlTipo )
            AAdd( aBrowse, { AL->AlCodigo, AL->AlAlimento, AL->AlTipo, AL->AlUnidad, AL->( RecNo() ) } )
         ENDIF
         AL->( dbSkip() )
      ENDDO
   CASE nOrder == 3
      AL->( dbGoTop() )
      DO WHILE ! AL->( Eof() )
         IF cGet $ Upper( AL->AlCodigo )
            AAdd( aBrowse, { AL->AlCodigo, AL->AlAlimento, AL->AlTipo, AL->AlUnidad, AL->( RecNo() ) } )
         ENDIF
         AL->( dbSkip() )
      ENDDO
   CASE nOrder == 4
      AL->( dbGoTop() )
      DO WHILE ! AL->( Eof() )
         IF DToS( cGet ) == DToS( AL->AlUltCom )
            AAdd( aBrowse, { AL->AlCodigo, AL->AlAlimento, AL->AlTipo, AL->AlUnidad, AL->( RecNo() ) } )
         ENDIF
         AL->( dbSkip() )
      ENDDO
   CASE nOrder == 5
      AL->( dbGoTop() )
      DO WHILE ! AL->( Eof() )
         IF cGet $ Upper( AL->AlProveed )
            AAdd( aBrowse, { AL->AlCodigo, AL->AlAlimento, AL->AlTipo, AL->AlUnidad, AL->( RecNo() ) } )
         ENDIF
         AL->( dbSkip() )
      ENDDO
   CASE nOrder == 6
      AL->( dbGoTop() )
      DO WHILE ! AL->( Eof() )
         IF cGet $ Upper( AL->AlUbicaci )
            AAdd( aBrowse, { AL->AlCodigo, AL->AlAlimento, AL->AlTipo, AL->AlUnidad, AL->( RecNo() ) } )
         ENDIF
         AL->( dbSkip() )
      ENDDO
   CASE nOrder == 7
      AL->( dbGoTop() )
      DO WHILE ! AL->( Eof() )
         IF cGet $ Upper( AL->AlAccion )
            AAdd( aBrowse, { AL->AlCodigo, AL->AlAlimento, AL->AlTipo, AL->AlUnidad, AL->( RecNo() ) } )
         ENDIF
         AL->( dbSkip() )
      ENDDO
   END CASE
   AL->( dbGoto( nRecno ) )
   // ordeno la tabla por el 1 elemento
   ASort( aBrowse,,, {| aAut1, aAut2| Upper( aAut1[ 1 ] ) < Upper( aAut2[ 1 ] ) } )

   RETURN NIL
/*_____________________________________________________________________________*/
	
FUNCTION AlEncontrados( aBrowse, oParent )

   LOCAL oDlg, oBrowse, oBtnOk, oBtnCancel, lOk
   LOCAL nRecno := RE->( RecNo() )
	
   DEFINE DIALOG oDlg RESOURCE "DLG_ENCONTRADOS" ;
      TITLE i18n( "Resultado de la búsqueda" ) ;
      OF oParent
   oDlg:SetFont( oApp():oFont )
	
   oBrowse := TXBrowse():New( oDlg )
   Ut_BrwRowConfig( oBrowse )

   oBrowse:SetArray( aBrowse, .F. )
   oBrowse:aCols[ 1 ]:cHeader := "Código"
   oBrowse:aCols[ 2 ]:cHeader := "Ingrediente"
   oBrowse:aCols[ 3 ]:cHeader := "Familia"
   oBrowse:aCols[ 4 ]:cHeader := "Unidad"
   oBrowse:aCols[ 1 ]:nWidth  := 90
   oBrowse:aCols[ 2 ]:nWidth  := 240
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
   // Ut_BrwRowConfig( oBrowse )
	
   oBrowse:CreateFromResource( 110 )
	
   AL->( dbGoto( aBrowse[ oBrowse:nArrayAt, 5 ] ) )
   AEval( oBrowse:aCols, {| oCol| oCol:bLDClickData := {|| AL->( dbGoto( aBrowse[ oBrowse:nArrayAt, 5 ] ) ), ;
      AlEdita( , 2,, oApp():oDlg ) } } )
   oBrowse:bKeyDown  := {| nKey| iif( nKey == VK_RETURN, ( AL->( dbGoto( aBrowse[ oBrowse:nArrayAt, 5 ] ) ), ;
      AlEdita( , 2,, oApp():oDlg ) ), ) }
   oBrowse:bChange    := {|| AL->( dbGoto( aBrowse[ oBrowse:nArrayAt, 5 ] ) ) }
   oBrowse:lHScroll  := .F.
   oDlg:oClient      := oBrowse
   oBrowse:nRowHeight := 20
	
   REDEFINE BUTTON oBtnOk ;
      ID IDOK OF oDlg     ;
      ACTION oDlg:End()
	
   REDEFINE BUTTON oBtnCancel ;
      ID IDCANCEL OF oDlg ;
      ACTION ( AL->( dbGoto( nRecno ) ), oDlg:End() )
	
   ACTIVATE DIALOG oDlg ;
      ON INIT DlgCenter( oDlg, oApp():oWndMain )
	
   RETURN NIL
	
/*_____________________________________________________________________________*/
FUNCTION AlClave( cIngred, aGet, nMode, nField, lAppend )

   // nMode    1 nuevo registro
   // 2 modificación de registro
   // 3 duplicación de registro
   // 4 clave ajena
   // nField   1 AlAlimento
   // 2 AlCodigo
   LOCAL lreturn  := .F.
   LOCAL nRecno   := AL->( RecNo() )
   LOCAL nOrder   := AL->( ordNumber() )
   LOCAL nArea    := Select()
   DEFAULT lAppend := .F.

   IF Empty( cIngred )
      IF nMode == 4
         RETURN .T.
      ELSE
         MsgStop( "Es obligatorio rellenar este campo." )
         RETURN .F.
      ENDIF
   ENDIF

   SELECT AL
   IF nField == 1
      AL->( dbSetOrder( 1 ) )
   ELSE
      AL->( dbSetOrder( 3 ) )
   ENDIF

   AL->( dbGoTop() )

   IF AL->( dbSeek( Upper( cIngred ) ) )
      DO CASE
      CASE nMode == 1 .OR. nMode == 3
         lreturn := .F.
         IF nField == 1
            MsgStop( "Ingrediente existente." )
         ELSE
            MsgStop( "Código de ingrediente existente." )
         ENDIF
      CASE nMode == 2
         IF AL->( RecNo() ) == nRecno
            lreturn := .T.
         ELSE
            lreturn := .F.
            IF nField == 1
               MsgStop( "Ingrediente existente." )
            ELSE
               MsgStop( "Código de ingrediente existente." )
            ENDIF
         ENDIF
      CASE nMode == 4
         IF lAppend
            aGet[ 1 ]:cText := AL->AlCodigo
            aGet[ 2 ]:cText := AL->AlAlimento
            aGet[ 3 ]:cText := AL->AlUnidad
            aGet[ 4 ]:cText := 1
            aGet[ 5 ]:cText := AL->AlPrecio
            aGet[ 6 ]:cText := AL->AlKCal
            aGet[ 8 ]:cText := AL->AlProveed
         ENDIF
         lreturn := .T.
         IF ! oApp():thefull
            Registrame()
         ENDIF
      END CASE
   ELSE
      IF nMode < 4
         lreturn := .T.
      ELSE
         lreturn := .F.
         IF nField == 1
            MsgStop( "Ingrediente inexistente." )
         ELSE
            IF MsgYesNo( "Código de ingrediente inexistente." + CRLF + "¿ Desea seleccionar uno ahora ?", 'Seleccione una opción' )
               AlSeleccion( cIngred, aGet, oApp():oDlg )
            ENDIF
         ENDIF
      ENDIF
   ENDIF

   IF lreturn == .F.
      IF nField == 1
         aGet[ 3 ]:cText( Space( 25 ) )
      ELSE
         aGet[ 2 ]:cText( Space( 6 ) )
      ENDIF
   ENDIF
   IF nMode != 4
      AL->( dbSetOrder( nOrder ) )
      AL->( dbGoto( nRecno ) )
   ENDIF

   SELECT ( nArea )

   RETURN lreturn
/*_____________________________________________________________________________*/

FUNCTION AlImprime( oGrid, oParent )

   LOCAL nRecno   := AL->( RecNo() )
   LOCAL nOrder   := AL->( ordSetFocus() )
   LOCAL aCampos  := { "ALCODIGO", "ALTIPO", "ALALIMENTO", "ALUNIDAD", "ALPRECIO", ;
      "ALULTCOM", "ALKCAL", "ALPROT", "ALHC", "ALGT", "ALGS", ;
      "ALGMI", "ALGPI", "ALCOL", "ALFIB", "ALNA", "ALCA", "ALPROVEED", "ALUBICACI", "ALACCION" }
   LOCAL aTitulos := { "Código", "Familia", "Ingrediente", "Unidad", "Precio", ;
      "Fch. compra", "KCalorias", "Proteinas", "Hidratos", "Grasas Tot.", ;
      "Gr. Saturadas", "Gr. Monoinsaturadas", "Gr. poliinsaturadas", ;
      "Colesterol", "Fibra", "Sodio", "Calcio", "Proveedor", "Ubicación", "Acción" }
   LOCAL aWidth   := { 12, 40, 50, 20, 16, 16, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 60, 20, 20 }
   LOCAL aShow    := { .T., .T., .T., .T., .T., .T., .T., .T., .T., ;
      .T., .T., .T., .T., .T., .T., .T., .T., .T., .T., .T. }
   LOCAL aPicture := { "NO", "NO", "NO", "NO", "@E 999,999.99", "NO", "@E 999,999.99", ;
      "@E 999,999.99", "@E 999,999.99", "@E 999,999.99", "@E 999,999.99", ;
      "@E 999,999.99", "@E 999,999.99", "@E 999,999.99", "@E 999,999.99", ;
      "@E 999,999.99", "@E 999,999.99", "NO", "NO", "NO" }
   LOCAL aTotal   := { .F., .F., .F., .F., .T., .F., .T., .T., .T., ;
      .T., .T., .T., .T., .T., .T., .T., .T., .T., .F., .F. }
   LOCAL oInforme
   LOCAL aGr      := {}
   LOCAL cGr
   LOCAL oComGr
   LOCAL nGrRec   := GR->( RecNo() )
   LOCAL nGrOrd   := GR->( ordNumber() )
   LOCAL aPr      := {}
   LOCAL cPr
   LOCAL oComPr
   LOCAL nPrRec   := PR->( RecNo() )
   LOCAL nPrOrd   := PR->( ordNumber() )
   LOCAL aUb      := {}
   LOCAL cUb
   LOCAL oComUb
   LOCAL nUbRec   := UB->( RecNo() )
   LOCAL nUbOrd   := UB->( ordNumber() )
   LOCAL aAc      := {}
   LOCAL cAc
   LOCAL oComAc
   LOCAL nAcRec   := AC->( RecNo() )
   LOCAL nAcOrd   := AC->( ordNumber() )
   LOCAL nDevice  := 0
   LOCAL dInicio  := CToD( '' )
   LOCAL dFinal   := Date()
   LOCAL aGet[ 2 ], aBtn[ 2 ]
   LOCAL i, cToken, aFont, nRec
   LOCAL oDlg, oFld, aRadio, oLbx, oGet, oCheck, oSay, oBtnUp, oBtnDown, oBtnShow, oBtnHide, oGet1

   oApp():nEdit ++

   SELECT GR
   GR->( dbSetOrder( 1 ) )
   GR->( dbGoTop() )
   DO WHILE ! GR->( Eof() )
      AAdd( aGr, GR->GrTipo )
      GR->( dbSkip() )
   ENDDO
   GR->( dbSetOrder( nGrOrd ) )
   GR->( dbGoto( nGrRec ) )
   cGr := iif( Len( aGr ) > 0, aGr[ 1 ], Space( 20 ) )
   SELECT PR
   PR->( dbSetOrder( 1 ) )
   PR->( dbGoTop() )
   DO WHILE ! PR->( Eof() )
      AAdd( aPR, PR->PRNombre )
      PR->( dbSkip() )
   ENDDO
   PR->( dbSetOrder( nPROrd ) )
   PR->( dbGoto( nPRRec ) )
   cPr := iif( Len( aPr ) > 0, aPr[ 1 ], Space( 20 ) )
   SELECT UB
   UB->( dbSetOrder( 1 ) )
   UB->( dbGoTop() )
   DO WHILE ! UB->( Eof() )
      AAdd( aUB, UB->UbUbicaci )
      UB->( dbSkip() )
   ENDDO
   UB->( dbSetOrder( nUbOrd ) )
   UB->( dbGoto( nUbRec ) )
   cUb := iif( Len( aUb ) > 0, aUb[ 1 ], Space( 40 ) )
   SELECT AC
   AC->( dbSetOrder( 1 ) )
   AC->( dbGoTop() )
   DO WHILE ! AC->( Eof() )
      AAdd( aAC, AC->AcAccion )
      AC->( dbSkip() )
   ENDDO
   AC->( dbSetOrder( nAcOrd ) )
   AC->( dbGoto( nAcRec ) )
   cAc := iif( Len( aAc ) > 0, aAc[ 1 ], Space( 8 ) )

   oInforme := TInforme():New( aCampos, aTitulos, aWidth, aShow, aPicture, aTotal, "AL" )
   oInforme:Dialog()

   REDEFINE RADIO oInforme:oRadio VAR oInforme:nRadio ID 300, 301, 302, 303, 304, 305 OF oInforme:oFld:aDialogs[ 1 ] ;
      ON CHANGE oInforme:Change()

   REDEFINE COMBOBOX oComGr VAR cGr ITEMS aGr  ;
      WHEN oInforme:nRadio == 2 ID 310 OF oInforme:oFld:aDialogs[ 1 ]
   REDEFINE COMBOBOX oComPr VAR cPr ITEMS aPr  ;
      WHEN oInforme:nRadio == 3 ID 311 OF oInforme:oFld:aDialogs[ 1 ]
   REDEFINE COMBOBOX oComUb VAR cUb ITEMS aUb  ;
      WHEN oInforme:nRadio == 4 ID 318 OF oInforme:oFld:aDialogs[ 1 ]
   REDEFINE COMBOBOX oComAc VAR cAc ITEMS aAc  ;
      WHEN oInforme:nRadio == 5 ID 319 OF oInforme:oFld:aDialogs[ 1 ]

   REDEFINE SAY ID 312 OF oInforme:oFld:aDialogs[ 1 ]
   REDEFINE SAY ID 314 OF oInforme:oFld:aDialogs[ 1 ]

   REDEFINE GET aGet[ 1 ] VAR dInicio       ;
      ID 313 OF oInforme:oFld:aDialogs[ 1 ] UPDATE   ;
      WHEN oInforme:nRadio == 6

   REDEFINE BUTTON aBtn[ 1 ]                ;
      ID 316 OF oInforme:oFld:aDialogs[ 1 ] UPDATE   ;
      ACTION SelecFecha( dInicio, aGet[ 1 ] ) ;
      WHEN oInforme:nRadio == 6
   aBtn[ 1 ]:cTooltip := i18n( "seleccionar fecha" )

   REDEFINE GET aGet[ 2 ] VAR dFinal        ;
      ID 315 OF oInforme:oFld:aDialogs[ 1 ] UPDATE   ;
      WHEN oInforme:nRadio == 6

   REDEFINE BUTTON aBtn[ 2 ]                ;
      ID 317 OF oInforme:oFld:aDialogs[ 1 ] UPDATE   ;
      ACTION SelecFecha( dFinal, aGet[ 2 ] ) ;
      WHEN oInforme:nRadio == 6
   aBtn[ 2 ]:cTooltip := i18n( "seleccionar fecha" )

   oInforme:Folders()

   IF oInforme:Activate()
      SELECT AL
      IF oInforme:nRadio == 3
         AL->( dbSetOrder( 5 ) )
      ENDIF
      AL->( dbGoTop() )
      oInforme:Report()
      IF oInforme:nRadio == 1
         ACTIVATE REPORT oInforme:oReport ;
            ON END ( oInforme:oReport:StartLine(), oInforme:oReport:EndLine(), oInforme:oReport:StartLine(), ;
            oInforme:oReport:Say( 1, 'Total ingredientes: ' + Tran( oInforme:oReport:nCounter, '@E 999,999' ), 1 ), ;
            oInforme:oReport:EndLine() )
      ELSEIF oInforme:nRadio == 2
         ACTIVATE REPORT oInforme:oReport FOR AL->AlTipo == cGr ;
            ON END ( oInforme:oReport:StartLine(), oInforme:oReport:EndLine(), oInforme:oReport:StartLine(), ;
            oInforme:oReport:Say( 1, 'Total ingredientes: ' + Tran( oInforme:oReport:nCounter, '@E 999,999' ), 1 ), ;
            oInforme:oReport:EndLine() )
      ELSEIF oInforme:nRadio == 3
         ACTIVATE REPORT oInforme:oReport FOR AL->AlProveed == cPr ;
            ON END ( oInforme:oReport:StartLine(), oInforme:oReport:EndLine(), oInforme:oReport:StartLine(), ;
            oInforme:oReport:Say( 1, 'Total ingredientes: ' + Tran( oInforme:oReport:nCounter, '@E 999,999' ), 1 ), ;
            oInforme:oReport:EndLine() )
      ELSEIF oInforme:nRadio == 4
         ACTIVATE REPORT oInforme:oReport FOR AL->AlUbicaci == cUb ;
            ON END ( oInforme:oReport:StartLine(), oInforme:oReport:EndLine(), oInforme:oReport:StartLine(), ;
            oInforme:oReport:Say( 1, 'Total ingredientes: ' + Tran( oInforme:oReport:nCounter, '@E 999,999' ), 1 ), ;
            oInforme:oReport:EndLine() )
      ELSEIF oInforme:nRadio == 5
         ACTIVATE REPORT oInforme:oReport FOR AL->AlAccion == cAc ;
            ON END ( oInforme:oReport:StartLine(), oInforme:oReport:EndLine(), oInforme:oReport:StartLine(), ;
            oInforme:oReport:Say( 1, 'Total ingredientes: ' + Tran( oInforme:oReport:nCounter, '@E 999,999' ), 1 ), ;
            oInforme:oReport:EndLine() )
      ELSEIF oInforme:nRadio == 6
         ACTIVATE REPORT oInforme:oReport FOR dInicio <= AL->AlUltCom .AND. AL->AlUltCom <= dFinal ;
            ON END ( oInforme:oReport:StartLine(), oInforme:oReport:EndLine(), oInforme:oReport:StartLine(), ;
            oInforme:oReport:Say( 1, 'Total ingredientes: ' + Tran( oInforme:oReport:nCounter, '@E 999,999' ), 1 ), ;
            oInforme:oReport:EndLine() )
      ENDIF
      oInforme:End( .T. )
      AL->( ordSetFocus( nOrder ) )
      AL->( dbGoto( nRecno ) )
   ENDIF
   oApp():nEdit --
   oGrid:Refresh()
   oGrid:SetFocus( .T. )

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION AlStock( oGrid, oParent )

   LOCAL oDlg, oBrowse, oBtnOk, oBtnCancel, lOk, i
   LOCAL nRecno  := AL->( RecNo() )
   LOCAL nOrder  := AL->( ordSetFocus() )
   LOCAL aBrowse := {}

   oApp():nEdit ++

   AL->( dbGoTop() )
   DO WHILE ! AL->( Eof() )
      AAdd( aBrowse, { AL->AlCodigo, AL->AlTipo, AL->AlAlimento, AL->AlPrecio, AL->AlStock } )
      AL->( dbSkip() )
   ENDDO

   DEFINE DIALOG oDlg RESOURCE "AL_STOCK" ;
      TITLE i18n( "Gestión de Precio y Stock de Ingredientes" ) ;
      OF oParent
   oDlg:SetFont( oApp():oFont )

   oBrowse := TXBrowse():New( oDlg )
   oBrowse:SetArray( aBrowse, .F. )
   oBrowse:aCols[ 1 ]:cHeader := "Código"
   oBrowse:aCols[ 1 ]:nWidth  := 60
   oBrowse:aCols[ 1 ]:nDataStrAlign := 0
   oBrowse:aCols[ 1 ]:nHeadStrAlign := 0
   oBrowse:aCols[ 1 ]:nHeadStrAlign := 0
   oBrowse:aCols[ 2 ]:cHeader := "Familia"
   oBrowse:aCols[ 2 ]:nWidth  := 100
   oBrowse:aCols[ 2 ]:nDataStrAlign := 0
   oBrowse:aCols[ 2 ]:nHeadStrAlign := 0
   oBrowse:aCols[ 3 ]:cHeader := "Ingrediente"
   oBrowse:aCols[ 3 ]:nWidth  := 200
   oBrowse:aCols[ 3 ]:nDataStrAlign := 0
   oBrowse:aCols[ 3 ]:nHeadStrAlign := 0
   oBrowse:aCols[ 4 ]:cHeader := "Precio"
   oBrowse:aCols[ 4 ]:nWidth  := 70
   oBrowse:aCols[ 4 ]:cEditPicture := "@E 999,999.99"
   oBrowse:aCols[ 4 ]:nEditType := EDIT_GET
   // oBrowse:aCols[4]:lFastEdit := .t.
   oBrowse:aCols[ 4 ]:nDataStrAlign := 1
   oBrowse:aCols[ 4 ]:nHeadStrAlign := 1
   // oCol:bOnPostEdit = { | oCol, xVal, nKey | If( RecCount() == 0, DbAppend(),), If( nKey == VK_RETURN, ( Customer->Last := xVal, DbAppend(), oBrw:Refresh() ),) }
   oBrowse:aCols[ 5 ]:cHeader := "Stock"
   oBrowse:aCols[ 5 ]:nWidth  := 70
   oBrowse:aCols[ 5 ]:cEditPicture := "@E 9,999.99"
   oBrowse:aCols[ 5 ]:nEditType := EDIT_GET
   // oBrowse:aCols[5]:lFastEdit := .t.
   oBrowse:aCols[ 5 ]:nDataStrAlign := 1
   oBrowse:aCols[ 5 ]:nHeadStrAlign := 1

   // Ut_BrwRowConfig( oBrowse )
   oBrowse:lFastEdit        := .T.
   oBrowse:l2007          := .F.
   oBrowse:lMultiselect        := .F.
   oBrowse:lTransparent    := .F.
   oBrowse:nMarqueeStyle       := 3
   oBrowse:nStretchCol     := -1 // STRETCHCOL_LAST
   oBrowse:bClrRowFocus        := {|| { CLR_BLACK, oApp():nClrHL } }
   oBrowse:bClrSelFocus     := {|| { CLR_BLACK, oApp():nClrHL } }
   oBrowse:lRecordSelector     := .T.
   oBrowse:nColDividerStyle    := LINESTYLE_LIGHTGRAY
   oBrowse:nRowDividerStyle    := LINESTYLE_LIGHTGRAY
   oBrowse:nHeaderHeight       := 24
   oBrowse:nRowHeight          := 20
   // oBrowse:nRowDividerStyle    := LINESTYLE_NOLINES

   oBrowse:CreateFromResource( 110 )
   oBrowse:lHScroll  := .F.
   oDlg:oClient      := oBrowse

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
      FOR i := 1 TO Len( aBrowse )
         AL->( dbSeek( aBrowse[ i, 3 ] ) )
         REPLACE AL->AlPrecio WITH aBrowse[ i, 4 ]
         REPLACE AL->AlStock  WITH aBrowse[ i, 5 ]
      NEXT
   ENDIF
   AL->( ordSetFocus( nOrder ) )
   AL->( dbGoto( nRecno ) )
   oApp():nEdit --
   oGrid:Refresh()

   RETURN NIL

FUNCTION AlSort( nOrden, oCont )

   LOCAL nRecno := AL->( RecNo() )
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
   AL->( dbSetOrder( norden ) )
   iif( AL->( Eof() ), AL->( dbGoTop() ), )
   Refreshcont( ocont, "AL" )
   AL->( dbGoto( nRecno ) )
   oApp():oGrid:Refresh( .T. )
   oApp():oGrid:SetFocus( .T. )

   RETURN NIL

FUNCTION AlCasaverdeCSV(oGrid, oParent)
   LOCAL nHandle, nFLines, nProgress, Linea, nFHandle
   LOCAL aFields  := {}
	LOCAL cAlCodigo
	LOCAL oDlg, aGet[4]
	LOCAL cFile    := oApp():cXLSPath + "\casaverde.csv"
   LOCAL cProveed := Space(50)
	LOCAL nAlOrder := AL->(OrdNumber())
	LOCAL nAlRecno := AL->(Recno())	

	DEFINE DIALOG oDlg OF oApp():oWndMain RESOURCE "AL_CSV_"+oApp():cLanguage  ;
      TITLE "Importar CSV de proveedor"
   oDlg:SetFont(oApp():oFont)

   REDEFINE SAY ID 11 OF oDlg
   REDEFINE GET aGet[ 1 ] VAR cFile ;
      ID 12 OF oDlg UPDATE PICTURE '@!'
   REDEFINE BUTTON aGet[ 2 ]             ;
      ID 13 OF oDlg UPDATE            ;
      ACTION (cFile := Lfn2sfn( cGetfile32( "*.CSV","Indica la ubicación del archivo CSV",,oApp():cXlsPath,, .T. ) ))
   aGet[ 2 ]:cTOOLTIP  := "seleccionar fichero CSV"

	REDEFINE SAY ID 14 OF oDlg
   REDEFINE AUTOGET aGet[ 3 ] VAR cProveed;
      DATASOURCE {}      ;
      FILTER PrList( uDataSource, cData, Self );
      HEIGHTLIST 100 ;
      ID 15 OF oDlg UPDATE            ;
      VALID PrClave( @cProveed, aGet[ 3 ], 4 )
   REDEFINE BUTTON aGet[ 4 ]            ;
      ID 16 OF oDlg                   ;
      ACTION PrSeleccion( cProveed, aGet[ 3 ], oDlg )
   aGet[ 4 ]:cTooltip := i18n( "seleccionar proveedor" )

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
		SELECT AL
		AL->(OrdSetFocus(3))
		//DELETE ALL FOR Upper(RTrim(AL->AlProveed)) == cProveed
		nFHandle := FOpen( cFile )
		nFLines  := FLineCount( cFile )
		nProgress := 0
		HB_FReadLine( nFHandle, @Linea )
		nProgress ++
		WHILE nProgress < 50 // nFLines
			HB_FReadLine( nFHandle, @Linea )
			nProgress ++
			aFields := hb_ATokens( Linea, ";", .F., )
			cAlCodigo := aFields[2]+Space(Len(AL->AlCodigo)-Len(aFields[2]))
			AL->(DBGoTop())	
			IF AL->(DBSeek(cAlCodigo))
				REPLACE AL->AlAlimento WITH aFields[3]
				REPLACE AL->AlUnidad   WITH aFields[4]
				REPLACE AL->AlPrecio   WITH Val(aFields[5])
			ELSE
				AL->(DBAppend())
				REPLACE AL->AlProveed  WITH aFields[1]
				REPLACE AL->AlCodigo   WITH aFields[2]
				REPLACE AL->AlAlimento WITH aFields[3]
				REPLACE AL->AlUnidad   WITH aFields[4]
				REPLACE AL->AlPrecio   WITH Val(aFields[5])
			ENDIF
			SELECT ES
			ES->(DBGoTop())
			WHILE ! ES->(Eof())
				IF ES->EsIngred == AL->AlCodigo
					REPLACE ES->EsPrecio WITH ES->EsCantidad * AL->AlPrecio
				ENDIF
				ES->(DBSkip())
			ENDDO
			SELECT AL
			sysrefresh()
		ENDDO
		MsgInfo("Incorporación realizada correctamente.")
	ENDIF
	AL->(OrdSetFocus(nAlOrder))
	AL->(DBGoTo(nAlRecno))
   oApp():oGrid:Refresh( .T. )
   oApp():oGrid:SetFocus( .T. )
   RETURN NIL
