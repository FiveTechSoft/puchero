#include "FiveWin.ch"
#include "Report.ch"
#include "Image.ch"
#include "zoomimage.ch"
#include "xBrowse.ch"
#include "splitter.ch"
#include "vmenu.ch"
#include "AutoGet.ch"
#include "FileIo.ch"
#include "RichEdit.ch"

#define  SELECCIONADA   "X"
#define  NOSELECCIONADA " "

STATIC oReport
STATIC oBarImg

FUNCTION Recetas()

   LOCAL oBar1, oBar2, oBar3, oBar4
   LOCAL oCol
   LOCAL aBrowse
   LOCAL cState := GetPvProfString( "Browse", "ReState", "", oApp():cInifile )
   LOCAL nOrder := Max( Val( GetPvProfString("Browse", "ReOrder","1", oApp():cInifile ) ), 1 )
   LOCAL nRecno := Val( GetPvProfString( "Browse", "ReRecno","1", oApp():cInifile ) )
   LOCAL nSplit := Val( GetPvProfString( "Browse", "ReSplit","102", oApp():cInifile ) )
   LOCAL lSplit := Val( GetPvProfString( "Browse", "ReSplit","102", oApp():cInifile ) )
   LOCAL lOpen1 := iif( GetPvProfString( "Browse", "ReBar1","1", oApp():cInifile ) == '1', .T., .F. )
   LOCAL lOpen2 := iif( GetPvProfString( "Browse", "ReBar2","1", oApp():cInifile ) == '1', .T., .F. )
   LOCAL lOpen3 := iif( GetPvProfString( "Browse", "ReBar3","1", oApp():cInifile ) == '1', .T., .F. )
   LOCAL lOpen4 := iif( GetPvProfString( "Browse", "ReBar4","1", oApp():cInifile ) == '1', .T., .F. )
   LOCAL nRecTab
   LOCAL aTPlato   := { 'Entradas', '1er Plato', '2o Plato', 'Postre', 'Dulce', 'Otro' }
   LOCAL aEpoca    := { '0000', '0001', '0010', '0011', '0100', '0101', '0110', '0111', ;
      '1000', '1001', '1010', '1011', '1100', '1101', '1110', '1111' }
   LOCAL oCont
   LOCAL i
   LOCAL aClient
   LOCAL oReMenu, oVMItem, oMItem

   IF oApp():oDlg != nil
      IF oApp():nEdit > 0
         //MsgStop('Por favor, finalice la edición del registro actual.')
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
   oApp():oDlg:cTitle := i18n( 'Gestión de recetas de cocina' )
   oApp():oWndMain:oClient := oApp():oDlg
   oApp():oDlg:NewGrid( nSplit )

   Ut_BrwRowConfig( oApp():oGrid )
   SELECT RE
   oApp():oGrid:cAlias := "RE"
 /*
   oCol := oApp():oGrid:AddCol()
   oCol:nEditType       := TYPE_IMAGE
   oCol:lBmpStretch     := .t.
   oCol:lBmpTransparent := .t.
   oCol:bStrImage       := {|oCol| Rtrim(RE->ReImagen) }
   oCol:nDataBmpAlign   := AL_CENTER
 */
   oCol := oApp():oGrid:AddCol()
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
   oCol:bBmpData      := {|| Max( AScan( aEpoca,StrTran(Str(RE->ReEpoca,4 ),' ','0' ) ), 1 ) }
   oCol:nWidth        := 35
   oCol:nDataBmpAlign := 2

   oCol := oApp():oGrid:AddCol()
   oCol:AddResource( "BR_Dif1" )
   oCol:AddResource( "BR_Dif2" )
   oCol:AddResource( "BR_Dif3" )
   oCol:cHeader       := i18n( "Dificultad" )
   oCol:bBmpData      := {|| Max( RE->ReDificu, 1 ) }
   oCol:nWidth        := 35
   oCol:nDataBmpAlign := 2

   oCol := oApp():oGrid:AddCol()
   oCol:AddResource( "BR_CAL1C" )
   oCol:AddResource( "BR_CAL2C" )
   oCol:AddResource( "BR_CAL3C" )
   oCol:cHeader       := i18n( "Calorias" )
   oCol:bBmpData      := {|| Max( RE->ReCalori, 1 ) }
   oCol:nWidth        := 35
   oCol:nDataBmpAlign := 2


   oCol := oApp():oGrid:AddCol()
   oCol:AddResource( "BR_SEL1" )
   oCol:AddResource( "BR_SEL2" )
   oCol:cHeader       := i18n( "Selecc." )
   oCol:bBmpData      := {|| iif( RE->ReSelecc == SELECCIONADA, 1, 2 ) }
   oCol:nWidth        := 35
   oCol:nDataBmpAlign := 2

   oCol := oApp():oGrid:AddCol()
   oCol:AddResource( "BR_PROP1" )
   oCol:AddResource( "BR_PROP2" )
   oCol:cHeader       := i18n( "Incorp." )
   oCol:bBmpData      := {|| RE->ReIncorp }
   oCol:nWidth        := 35
   oCol:nDataBmpAlign := 2

   oCol := oApp():oGrid:AddCol()
   oCol:AddResource( "BR_IMG1" )
   oCol:AddResource( "BR_IMG2" )
   oCol:cHeader       := i18n( "Imagen" )
   oCol:bBmpData      := {|| iif( Empty( RE->ReImagen ), 2, 1 ) }
   oCol:nWidth        := 35
   oCol:nDataBmpAlign := 2

   oCol := oApp():oGrid:AddCol()
   oCol:AddResource( "BR_EXP1" )
   oCol:AddResource( "BR_EXP2" )
   oCol:cHeader       := i18n( "Express" )
   oCol:bBmpData      := {|| iif( RE->ReExpres, 1, 2 ) }
   oCol:nWidth        := 35
   oCol:nDataBmpAlign := 2

   oCol := oApp():oGrid:AddCol()
   oCol:bLClickHeader := {|| ReSort( 2, oCont ) }
   oCol:Cargo := 2
   oCol:AddResource( "16_SORT_A" )
   oCol:AddResource( "16_SORT_B" )
   oCol:nHeadBmpNo    := iif( nOrder == 2, 1, 2 )
   oCol:nHeadBmpAlign := AL_RIGHT
   oCol:bStrData := {|| RE->ReCodigo }
   oCol:cHeader  := i18n( "Código" )
   oCol:nWidth   := 50

   oCol := oApp():oGrid:AddCol()
   oCol:bLClickHeader := {|| ReSort( 1, oCont ) }
   oCol:Cargo := 1
   oCol:AddResource( "16_SORT_A" )
   oCol:AddResource( "16_SORT_B" )
   oCol:nHeadBmpNo    := iif( nOrder == 1, 1, 2 )
   oCol:nHeadBmpAlign := AL_RIGHT
   oCol:bStrData := {|| RE->ReTitulo }
   oCol:cHeader  := i18n( "Receta" )
   oCol:nWidth   := 255

   oCol := oApp():oGrid:AddCol()
   oCol:bLClickHeader := {|| ReSort( 3, oCont ) }
   oCol:Cargo := 3
   oCol:AddResource( "16_SORT_A" )
   oCol:AddResource( "16_SORT_B" )
   oCol:nHeadBmpNo    := iif( nOrder == 3, 1, 2 )
   oCol:nHeadBmpAlign := AL_RIGHT
   oCol:bStrData := {|| aTPlato[ Max( Val( RE->RePlato ), 1 ) ] }
   oCol:cHeader  := i18n( "Categoría" )
   oCol:nWidth   := 90

   oCol := oApp():oGrid:AddCol()
   oCol:bLClickHeader := {|| ReSort( 3, oCont ) }
   oCol:Cargo := 3
   oCol:AddResource( "16_SORT_A" )
   oCol:AddResource( "16_SORT_B" )
   oCol:nHeadBmpNo    := iif( nOrder == 3, 1, 2 )
   oCol:nHeadBmpAlign := AL_RIGHT
   oCol:bStrData :=  {|| RE->ReTipo }
   oCol:cHeader  := i18n( "Tipo de plato" )
   oCol:nWidth   := 150

   oCol := oApp():oGrid:AddCol()
   oCol:bLClickHeader := {|| ReSort( 4, oCont ) }
   oCol:Cargo := 4
   oCol:AddResource( "16_SORT_A" )
   oCol:AddResource( "16_SORT_B" )
   oCol:nHeadBmpNo    := iif( nOrder == 4, 1, 2 )
   oCol:nHeadBmpAlign := AL_RIGHT
   oCol:bStrData :=  {|| RE->ReTipoCoc }
   oCol:cHeader  := i18n( "Tipo de cocinado" )
   oCol:nWidth   := 150

   oCol := oApp():oGrid:AddCol()
   oCol:bLClickHeader := {|| ReSort( 5, oCont ) }
   oCol:Cargo := 5
   oCol:AddResource( "16_SORT_A" )
   oCol:AddResource( "16_SORT_B" )
   oCol:nHeadBmpNo    := iif( nOrder == 5, 1, 2 )
   oCol:nHeadBmpAlign := AL_RIGHT
   oCol:bStrData :=  {|| RE->ReFrTipo }
   oCol:cHeader  := i18n( "C. Francesa" )
   oCol:nWidth   := 150

   oCol := oApp():oGrid:AddCol()
   oCol:bLClickHeader := {|| ReSort( 6, oCont ) }
   oCol:Cargo := 6
   oCol:AddResource( "16_SORT_A" )
   oCol:AddResource( "16_SORT_B" )
   oCol:nHeadBmpNo    := iif( nOrder == 6, 1, 2 )
   oCol:nHeadBmpAlign := AL_RIGHT
   oCol:bStrData :=  {|| RE->ReIngPri }
   oCol:cHeader  := i18n( "Ing. Principal" )
   oCol:nWidth   := 150

   oCol := oApp():oGrid:AddCol()
   oCol:bStrData :=  {|| RE->ReDietas }
   oCol:cHeader  := i18n( "Dietas / Tolerancias" )
   oCol:nWidth   := 150

   oCol := oApp():oGrid:AddCol()
   oCol:bStrData :=  {|| TRAN( RE->ReComens, " 99" ) }
   oCol:cHeader  := i18n( "Comensales" )
   oCol:nWidth   := 50

   oCol := oApp():oGrid:AddCol()
   oCol:bStrData :=  {|| RE->ReTiempo }
   oCol:cHeader  := i18n( "Tiempo prep." )
   oCol:nWidth   := 150

   oCol := oApp():oGrid:AddCol()
   oCol:bStrData :=  {|| TRAN( RE->RePrecio, "@E 999,999.99" ) }
   oCol:cHeader  := i18n( "Precio estimado" )
   oCol:nWidth   := 90

   oCol := oApp():oGrid:AddCol()
   oCol:bStrData :=  {|| TRAN( RE->RePPC, "@E 999,999.99" ) }
   oCol:cHeader  := i18n( "Precio comensal" )
   oCol:nWidth   := 90

   oCol := oApp():oGrid:AddCol()
   oCol:bLClickHeader := {|| ReSort( 7, oCont ) }
   oCol:Cargo := 7
   oCol:AddResource( "16_SORT_A" )
   oCol:AddResource( "16_SORT_B" )
   oCol:nHeadBmpNo    := iif( nOrder == 7, 1, 2 )
   oCol:nHeadBmpAlign := AL_RIGHT
   oCol:bStrData :=  {|| RE->ReAutor }
   oCol:cHeader  := i18n( "Autor" )
   oCol:nWidth   := 150

   oCol := oApp():oGrid:AddCol()
   oCol:bStrData :=  {|| RE->ReEmail }
   oCol:cHeader  := i18n( "E-mail" )
   oCol:nWidth   := 150

   oCol := oApp():oGrid:AddCol()
   oCol:bStrData :=  {|| RE->RePais }
   oCol:cHeader  := i18n( "País" )
   oCol:nWidth   := 150

   oCol := oApp():oGrid:AddCol()
   oCol:bStrData :=  {|| RE->ReReferen }
   oCol:cHeader  := i18n( "Referencia" )
   oCol:nWidth   := 150

   oCol := oApp():oGrid:AddCol()
   oCol:bStrData :=  {|| RE->ReAnotaci }
   oCol:cHeader  := i18n( "Anotación" )
   oCol:nWidth   := 150

   oCol := oApp():oGrid:AddCol()
   oCol:bLClickHeader := {|| ReSort( 8, oCont ) }
   oCol:Cargo := 8
   oCol:AddResource( "16_SORT_A" )
   oCol:AddResource( "16_SORT_B" )
   oCol:nHeadBmpNo    := iif( nOrder == 8, 1, 2 )
   oCol:nHeadBmpAlign := AL_RIGHT
   oCol:bStrData :=  {|| RE->RePublica }
   oCol:cHeader  := i18n( "Publicación" )
   oCol:nWidth   := 150

   oCol := oApp():oGrid:AddCol()
   oCol:bStrData :=  {|| TRAN( RE->ReNumero, "@E 9,999" ) }
   oCol:cHeader  := i18n( "Número" )
   oCol:nWidth   := 90

   oCol := oApp():oGrid:AddCol()
   oCol:bStrData :=  {|| TRAN( RE->RePagina, "@E 9,999" ) }
   oCol:cHeader  := i18n( "Página" )
   oCol:nWidth   := 90

   oCol := oApp():oGrid:AddCol()
   oCol:bStrData :=  {|| TRAN( RE->ReEscan, "@E 999,999.99" ) }
   oCol:cHeader  := i18n( "Precio escandallo" )
   oCol:nWidth   := 90

   oCol := oApp():oGrid:AddCol()
   oCol:bStrData :=  {|| TRAN( RE->ReMultip, "@E 99.99" ) }
   oCol:cHeader  := i18n( "Multiplicador" )
   oCol:nWidth   := 90

   oCol := oApp():oGrid:AddCol()
   oCol:bStrData :=  {|| TRAN( RE->RePFinal, "@E 999,999.99" ) }
   oCol:cHeader  := i18n( "Precio final" )
   oCol:nWidth   := 90

   oCol := oApp():oGrid:AddCol()
   oCol:bStrData :=  {|| TRAN( RE->ReComEsc, "@E 99" ) }
   oCol:cHeader  := i18n( "Comensales esc." )
   oCol:nWidth   := 90

   oCol := oApp():oGrid:AddCol()
   oCol:bLClickHeader := {|| ReSort( 11, oCont ) }
   oCol:Cargo := 11
   oCol:AddResource( "16_SORT_A" )
   oCol:AddResource( "16_SORT_B" )
   oCol:nHeadBmpNo    := iif( nOrder == 11, 1, 2 )
   oCol:nHeadBmpAlign := AL_RIGHT
   oCol:bStrData :=  {|| DToC( RE->ReFchPrep ) }
   oCol:cHeader  := i18n( "Fch. preparación" )
   oCol:nWidth   := 120

   oCol := oApp():oGrid:AddCol()
   oCol:bLClickHeader := {|| ReSort( 9, oCont ) }
   oCol:Cargo := 9
   oCol:AddResource( "16_SORT_A" )
   oCol:AddResource( "16_SORT_B" )
   oCol:nHeadBmpNo    := iif( nOrder == 9, 1, 2 )
   oCol:nHeadBmpAlign := AL_RIGHT
   oCol:bStrData :=  {|| RE->ReValorac }
   oCol:cHeader  := i18n( "Valoración" )
   oCol:nWidth   := 120

   oCol := oApp():oGrid:AddCol()
   oCol:bLClickHeader := {|| ReSort( 9, oCont ) }
   oCol:Cargo := 9
   oCol:AddResource( "16_SORT_A" )
   oCol:AddResource( "16_SORT_B" )
   oCol:nHeadBmpNo    := iif( nOrder == 9, 1, 2 )
   oCol:nHeadBmpAlign := AL_RIGHT
   oCol:bStrData :=  {|| TRAN( RE->ReVaOrden, " 99" ) }
   oCol:cHeader  := i18n( "Orden val." )
   oCol:nWidth   := 90

   oCol := oApp():oGrid:AddCol()
   oCol:bStrData :=  {|| RE->ReFichero }
   oCol:cHeader  := i18n( "Fichero inc." )
   oCol:nWidth   := 90

   oCol := oApp():oGrid:AddCol()
   oCol:bStrData :=  {|| DToC( RE->ReFchInco ) }
   oCol:cHeader  := i18n( "Fecha inc." )
   oCol:nWidth   := 90

   // añado columnas con bitmaps

   FOR i := 1 TO Len( oApp():oGrid:aCols )
      oCol := oApp():oGrid:aCols[ i ]
      oCol:bLDClickData  := {|| iif( RE->ReExpres == .T., ReEditaExpres( oApp():oGrid, 2, oCont, oApp():oDlg ), ReEdita( oApp():oGrid, 2, oCont, oApp():oDlg ) ) }
      oCol:bPopUp        := {| o | ReBrwMenu( o, oApp():oGrid, oCont, oApp():oDlg ) }
   NEXT

   oApp():oGrid:SetRDD()
   oApp():oGrid:CreateFromCode()
   oApp():oGrid:bChange     := {|| ( RefreshCont( oCont, "RE" ), RefreshReBarImage() ) }
   oApp():oGrid:bKeyDown    := {| nKey| ReTecla( nKey, oApp():oGrid, oCont, oApp():oDlg ) }
   oApp():oGrid:RestoreState( cState )

   RE->( dbSetOrder( nOrder ) )

   IF RE->( ordKeyNo() ) == 0 .AND. RE->( ordKeyCount() ) == 0
      nOrder := 1
      RE->( dbSetOrder( nOrder ) )
      RE->( dbGoTop() )
   ELSEIF nRecNo <= RE->( LastRec() ) .AND. nRecno != 0
      RE->( dbGoto( nRecno ) )
   ELSE
      RE->( dbGoTop() )
   ENDIF

   @ 02, 05 VMENU oCont SIZE nSplit - 10, 17.5 OF oApp():oDlg  ;
      COLOR CLR_BLACK, GetSysColor( 15 )       ;
      FILLED   ;  // BORDER
   COLORSELECT 0, CLR_WHITE ;
      HEIGHT ITEM 22

   DEFINE TITLE OF oCont ;
      CAPTION tran( RE->( ordKeyNo() ), '@E 999,999' ) + " / " + tran( RE->( ordKeyCount() ), '@E 999,999' ) ;
      HEIGHT 25 ;
      COLOR GetSysColor( 9 ), oApp():nClrBar ;
      IMAGE "BB_RECETAS"   ;
      RADIOBTN 15

   @ 24, 05 VMENU oBar1 SIZE nSplit - 10, 199 OF oApp():oDlg  ;
      COLOR CLR_BLACK, GetSysColor( 15 ) ;
      HEIGHT ITEM 22 XBOX

   DEFINE TITLE OF oBar1 ;
      CAPTION "Recetas" ;
      HEIGHT 25 ;
      COLOR GetSysColor( 9 ), oApp():nClrBar ; // IMGBTN "TB_UP", "TB_DOWN" ;
   OPENCLOSE

   DEFINE VMENUITEM OF oBar1        ;
      CAPTION "Nueva"              ;
      IMAGE "16_NUEVO"             ;
      ACTION ReEdita( oApp():oGrid, 1, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar1        ;
      CAPTION "Nueva Expres"       ;
      IMAGE "16_EXPRES"            ;
      ACTION ReEditaExpres( oApp():oGrid, 1, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar1        ;
      CAPTION "Modificar"          ;
      IMAGE "16_MODIF"             ;
      ACTION iif( RE->ReExpres == .T., ReEditaExpres( oApp():oGrid, 2, oCont, oApp():oDlg ), ReEdita( oApp():oGrid, 2, oCont, oApp():oDlg ) );
      LEFT 10

   DEFINE VMENUITEM OF oBar1        ;
      CAPTION "Duplicar"           ;
      IMAGE "16_DUPLICA"           ;
      ACTION ReEdita( oApp():oGrid, 3, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar1        ;
      CAPTION "Borrar"             ;
      IMAGE "16_BORRAR"            ;
      ACTION ReBorra( oApp():oGrid, oCont );
      LEFT 10

   DEFINE VMENUITEM OF oBar1        ;
      CAPTION "Buscar"             ;
      IMAGE "16_BUSCA"             ;
      ACTION ReBusca( oApp():oGrid,, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar1        ;
      CAPTION "Imprimir"           ;
      IMAGE "16_IMPRIMIR"          ;
      ACTION ReImprime( oApp():oGrid, oApp():oDlg )   ;
      LEFT 10

   DEFINE VMENUITEM OF oBar1        ;
      INSET HEIGHT 10

   DEFINE VMENUITEM OF oBar1        ;
      CAPTION "E-mail al autor"    ;
      IMAGE "16_EMAIL"             ;
      ACTION GoMail( RE->ReEmail )   ;
      LEFT 10

   DEFINE VMENUITEM OF oBar1        ;
      CAPTION "Ver imagen"         ;
      IMAGE "16_IMAGEN"             ;
      ACTION ReZoomImagen( RE->ReImagen, RE->ReTitulo, oApp():oDlg )  ;
      LEFT 10

   DEFINE VMENUITEM OF oBar1        ;
      INSET HEIGHT 10

   //MENUITEM "Añadir a menú semanal" RESNAME "16_MENUSEM" ACTION ReRsEdit()
   //MENUITEM "Añadir a menú de evento" RESNAME "16_MENUEVEN" ACTION ReRmEdit()

   DEFINE VMENUITEM OF oBar1        ;
      CAPTION "Añadir a menú semanal"    ;
      IMAGE "16_MENUSEM"             ;
      ACTION ReRsEdit()   ;
      LEFT 10

   DEFINE VMENUITEM OF oBar1        ;
      CAPTION "Añadir a menú de evento"         ;
      IMAGE "16_MENUEVEN"             ;
      ACTION ReRmEdit()  ;
      LEFT 10

   DEFINE VMENUITEM OF oBar1        ;
      INSET HEIGHT 10

   MENU oReMenu POPUP // 2007
   MENUITEM "Sin filtro" ;
      ACTION ReFilter( 0, oCont, oReMenu, oBar1, oVMItem, oMItem );
      CHECKED
   SEPARATOR
   MENUITEM oMItem PROMPT "Filtrar por categoría de plato"
   MENU
   MENUITEM "Filtrar por Entradas" ;
      ACTION ReFilter( 10, oCont, oReMenu, oBar1, oVMitem, oMItem )
   MENUITEM "Filtrar por 1er plato" ;
      ACTION ReFilter( 11, oCont, oReMenu, oBar1, oVMitem, oMItem )
   MENUITEM "Filtrar por 2o plato" ;
      ACTION ReFilter( 12, oCont, oReMenu, oBar1, oVMitem, oMItem )
   MENUITEM "Filtrar por Postre" ;
      ACTION ReFilter( 13, oCont, oReMenu, oBar1, oVMitem, oMItem )
   MENUITEM "Filtrar por Dulce" ;
      ACTION ReFilter( 14, oCont, oReMenu, oBar1, oVMitem, oMItem )
   ENDMENU
   MENUITEM "Filtrar por tipo de plato" ;
      ACTION ReFilter( 2, oCont, oReMenu, oBar1, oVMitem, oMItem )
   MENUITEM "Filtrar por tipo de cocinado" ;
      ACTION ReFilter( 3, oCont, oReMenu, oBar1, oVMitem, oMItem )
   MENUITEM "Filtrar por clasificación francesa" ;
      ACTION ReFilter( 4, oCont, oReMenu, oBar1, oVMitem, oMItem )
   MENUITEM "Filtrar por ingrediente principal" ;
      ACTION ReFilter( 5, oCont, oReMenu, oBar1, oVMitem, oMItem )
   MENUITEM "Filtrar por dieta / tolerancia" ;
      ACTION ReFilter( 6, oCont, oReMenu, oBar1, oVMitem, oMItem )
   MENUITEM "Filtrar por autor" ;
      ACTION ReFilter( 7, oCont, oReMenu, oBar1, oVMitem, oMItem )
   MENUITEM "Filtrar por publicación" ;
      ACTION ReFilter( 8, oCont, oReMenu, oBar1, oVMitem, oMItem )
   SEPARATOR
   MENUITEM "Filtrar recetas seleccionadas" ;
      ACTION ReFilter( 9, oCont, oReMenu, oBar1, oVMitem, oMItem )
   ENDMENU

   DEFINE VMENUITEM oVMItem OF oBar1 ;
      CAPTION "Filtrar recetas"    ;
      IMAGE "16_FILTRO"              ;
      MENU oReMenu        ;
      LEFT 10

   DEFINE VMENUITEM OF oBar1        ;
      INSET HEIGHT 10

   DEFINE VMENUITEM OF oBar1        ;
      CAPTION "Enviar a Excel"     ;
      IMAGE "16_EXCEL"             ;
      ACTION ( CursorWait(), Ut_ExportXLS( oApp():oGrid, "Recetas" ), CursorArrow() ) ;
      LEFT 10

   DEFINE VMENUITEM OF oBar1        ;
      CAPTION "Configurar rejilla" ;
      IMAGE "16_GRID"              ;
      ACTION Ut_BrwColConfig( oApp():oGrid, "ReState" ) ;
      LEFT 10

   DEFINE VMENUITEM OF oBar1        ;
      CAPTION "Salir"              ;
      IMAGE "16_SALIR"             ;
      ACTION oApp():oDlg:End()              ;
      LEFT 10

   @ 228, 05 VMENU oBar2 SIZE nSplit - 10, 68 OF oApp():oDlg  ;
      COLOR CLR_BLACK, GetSysColor( 15 )       ;
      HEIGHT ITEM 22 XBOX ATTACH TO oBar1
   oBar2:nClrBox := Min( GetSysColor( 13 ), GetSysColor( 14 ) )

   DEFINE TITLE OF oBar2 ;
      CAPTION "Importar y exportar" ;
      HEIGHT 25 ;
      COLOR GetSysColor( 9 ), oApp():nClrBar ;// IMGBTN "TB_UP", "TB_DOWN" ;
   OPENCLOSE

   DEFINE VMENUITEM OF oBar2       ;
      CAPTION "Copiar al portapapeles" ;
      IMAGE "16_COPIAR"            ;
      ACTION ReXCopiar( oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar2       ;
      CAPTION "Pegar desde el portapapeles" ;
      IMAGE "16_PEGAR"             ;
      ACTION ReXPegar( oApp():oGrid, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar2       ;
      CAPTION "Exportar a archivo PCX" ;
      IMAGE "16_EXPORT"            ;
      ACTION RePcxExport( oApp():oGrid, oApp():oDlg );
      LEFT 10
   //DEFINE VMENUITEM OF oBar2       ;
   //   CAPTION "Exportar a archivo PCH" ;
   //   IMAGE "16_EXPORT"            ;
   //   ACTION ReExport(oApp():oGrid, oApp():oDlg);
   //   LEFT 10

   DEFINE VMENUITEM OF oBar2       ;
      CAPTION "Importar desde archivo PCX" ;
      IMAGE "16_IMPORT"            ;
      ACTION RePcxImport( oApp():oGrid, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar2     ;
      CAPTION "Exportar a fichero RTF" ;
      IMAGE "16_RTF"            ;
      ACTION ReRTF( oApp():oGrid, oCont, oApp():oDlg );
      LEFT 10

   @ 301, 05 VMENU oBar3 SIZE nSplit - 10, 80 OF oApp():oDlg  ;
      COLOR CLR_BLACK, GetSysColor( 15 )       ;
      HEIGHT ITEM 22 XBOX ATTACH TO oBar2
   oBar3:nClrBox := Min( GetSysColor( 13 ), GetSysColor( 14 ) )

   DEFINE TITLE OF oBar3 ;
      CAPTION "Selección de recetas" ;
      HEIGHT 25 ;
      COLOR GetSysColor( 9 ), oApp():nClrBar ; // IMGBTN "TB_UP", "TB_DOWN" ;
   OPENCLOSE

   DEFINE VMENUITEM OF oBar3       ;
      CAPTION "Seleccionar receta" ;
      IMAGE "16_SELECC"             ;
      ACTION ReSelecc1( oApp():oGrid, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar3       ;
      CAPTION "Seleccionar duplicadas" ;
      IMAGE "16_SELEC_DUP"            ;
      ACTION ReSelDuplic( oApp():oGrid, oCont, oApp():oDlg );
      LEFT 10

   /*
 DEFINE VMENUITEM OF oBar3       ;
      CAPTION "Asistente de selección 1" ;
      IMAGE "16_ASISTENTE"             ;
      ACTION ReSelecc2(oApp():oGrid,oCont,oApp():oDlg); // ReSelecc2 - ReAsisSelecc
      LEFT 10
 */

   DEFINE VMENUITEM OF oBar3       ;
      CAPTION "Asistente de selección" ;
      IMAGE "16_ASISTENTE"             ;
      ACTION ReAsisSelecc( oApp():oGrid, oCont, oApp():oDlg, oReMenu, oBar1, oVMitem, oMItem )

   DEFINE VMENUITEM OF oBar3       ;
      CAPTION "Deseleccionar una receta" ;
      IMAGE "16_DESEL1"            ;
      ACTION ReDeSel1( oApp():oGrid );
      LEFT 10

   DEFINE VMENUITEM OF oBar3       ;
      CAPTION "Deseleccionar todas" ;
      IMAGE "16_DESEL2"             ;
      ACTION ReDeSelAll( oApp():oGrid, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar3       ;
      CAPTION "Borrar recetas seleccionadas" ;
      IMAGE "16_DESEL3"             ;
      ACTION ReBorraSel( oApp():oGrid, oCont, oApp():oDlg );
      LEFT 10

   @ 386, 05 VMENU oBar4 SIZE nSplit - 10, 2 * nSplit OF oApp():oDlg  ;
      COLOR CLR_BLACK, GetSysColor( 15 )       ;
      HEIGHT ITEM 22 XBOX ATTACH TO oBar3
   oBar4:nClrBox := Min( GetSysColor( 13 ), GetSysColor( 14 ) )

   DEFINE TITLE OF oBar4 ;
      CAPTION "Imagen de la receta" ;
      HEIGHT 25 ;
      COLOR GetSysColor( 9 ), oApp():nClrBar ; // IMGBTN "TB_UP", "TB_DOWN" ;
   OPENCLOSE

   @ oApp():oDlg:nGridBottom, nSplit + 2 TABS oApp():oTab ;
      OPTION nOrder SIZE oApp():oWndMain:nWidth() -80, 12 PIXEL OF oApp():oDlg ;
      ITEMS ' Receta ', ' Código ', ' Tipo de plato ', ' Cocinado ', ' C.Francesa ', 'I.Principal ', ;
      ' Autor ', ' Publicación ', ' Valoración ', ' Referencia ', 'Fch. preparación '; //,' R.Seleccionadas ';
   COLOR CLR_BLACK, GetSysColor( 15 ) -RGB( 30, 30, 30 ) ;// 13362404
   ACTION ReSort( Oapp():otab:noption, oCont )

   @ 00, nSplit SPLITTER oApp():oSplit VERTICAL ;
      PREVIOUS CONTROLS oCont, oBar1, oBar2, oBar3, oBar4, oBarImg ;
      HINDS CONTROLS oApp():oGrid, oApp():oTab ;
      SIZE 1, oApp():oDlg:nGridBottom + oApp():oTab:nHeight PIXEL ;
      OF oApp():oDlg _3DLOOK ;
      UPDATE

   // ResizeWndMain()
   ACTIVATE DIALOG oApp():oDlg NOWAIT ;
      ON INIT ( ResizeWndMain(), ReBarImage( oBar4, nSplit ), oApp():oGrid:SetFocus(), ;
      iif( ! lOpen1, oBar1:Switch(), ), iif( ! lOpen2, oBar2:Switch(), ), iif( ! lOpen3, oBar3:Switch(), ) ) ;
      VALID ( oApp():oGrid:nLen := 0,;
      WritePProString( "Browse", "ReBar1", iif( oBar1:lOpened,'1','0' ), oApp():cInifile ),;
      WritePProString( "Browse", "ReBar2", iif( oBar2:lOpened,'1','0' ), oApp():cInifile ),;
      WritePProString( "Browse", "ReBar3", iif( oBar3:lOpened,'1','0' ), oApp():cInifile ),;
      WritePProString( "Browse", "ReBar4", iif( oBar4:lOpened,'1','0' ), oApp():cInifile ),;
      WritePProString( "Browse", "ReState", oApp():oGrid:SaveState(), oApp():cInifile ),;
      WritePProString( "Browse", "ReOrder", LTrim( Str(RE->(ordNumber() ) ) ), oApp():cInifile ),;
      WritePProString( "Browse", "ReRecno", LTrim( Str(RE->(RecNo() ) ) ), oApp():cInifile ),;
      WritePProString( "Browse", "ReSplit", LTrim( Str(oApp():oSplit:nleft / 2 ) ), oApp():cInifile ),;
      oBar1:End(), oBar2:End(), oBar3:End(), obar4:End(), ;
      dbCloseAll(), oApp():oDlg := NIL, oApp():oGrid := NIL, oApp():oTab := NIL, oApp():oSplit := NIL, .T. )

RETURN NIL
/*_____________________________________________________________________________*/
FUNCTION ReBarImage( oBar, nSplit )

   oBarImg := TZoomImage():New( 35, 10, ( 2 * nSplit ) -40, ( 2 * nSplit ) -40,,, .T., oBar,,,, .T.,,,,, .T.,, )
   //[ <oBmp> := ] TImage():New( <nRow>, <nCol>, <nWidth>, <nHeight>,;
   //     <cResName>, <cBmpFile>, <.NoBorder.>, <oWnd>,;
   //     [\{ |nRow,nCol,nKeyFlags| <uLClick> \} ],;
   //     [\{ |nRow,nCol,nKeyFlags| <uRClick> \} ], <.scroll.>,;
   //     <.adjust.>, <oCursor>, <cMsg>, <.update.>,;
   //     <{uWhen}>, <.pixel.>, <{uValid}>, <.lDesign.> )
   oBarImg:SetColor( GetSysColor( 15 ), GetSysColor( 15 ) )
   IF File( lfn2sfn( RTrim(RE->ReImagen ) ) )
      oBarImg:LoadBmp( lfn2sfn( RTrim(RE->ReImagen ) ) )
   ENDIF
   oBarImg:Refresh()

RETURN NIL

FUNCTION RefreshReBarImage()

   IF oBarImg == NIL
      RETU NIL
   ENDIF
   IF File( lfn2sfn( RTrim(RE->ReImagen ) ) )
      oBarImg:LoadBmp( lfn2sfn( RTrim(RE->ReImagen ) ) )
      oBarImg:Show()
   ELSE
      oBarImg:Hide()
   ENDIF
   oBarImg:Refresh()

RETURN NIL
/*_____________________________________________________________________________*/
FUNCTION ReEdita( oGrid, nMode, oCont, oParent )

   LOCAL oDlg, oFld, oBmp, oImage, oBtnImg, oBrwEsc, oColEsc
   LOCAL aGet[ 34 ]
   LOCAL aRad[ 5 ]
   LOCAL aBmp[ 4 ]
   LOCAL aSay[ 40 ]
   LOCAL aBtn[ 17 ]
   LOCAL aSayEsc[ 5 ]
   LOCAL oCh01, oCh02, oCh03, oCh04

   LOCAL aTitle := { i18n( "Añadir receta" ),;
      i18n( "Modificar receta" ),;
      i18n( "Duplicar receta" ) }

   LOCAL cReCodigo,;
      cReTitulo,;
      cRePlato,;
      cReTipo,;
      cReTipoCoc,;
      cReFrCargo,;
      cReFrTipo,;
      cReIngPri,;
      nReEpoca,;
      nReComens,;
      mReIngred,;
      mRePrepar,;
      cReTiempo,;
      nReDificu,;
      nRePrecio,;
      nRePPC,;
      nReCalori,;
      mReTrucos,;
      mReVino,;
      cRePublica,;
      cReAutor,;
      cReEmail,;
      cRePais,;
      nReNumero,;
      nRePagina,;
      cReReferen,;
      cReAnotaci,;
      cReImagen,;
      nReEscan1,;
      nReEscan2,;
      nReMultip,;
      nRePFinal,;
      dReFchPrep,;
      cReValorac,;
      nReVaOrden,;
      cReUsuario,;
      nReIncorp,;
      dReFchInco,;
      nReComEsc,;
      nRePlato,;
      cRefichero,;
      cReEpoca,;
      lReExpres,;
      cReUrl,;
      cReDietas
   LOCAL nReKCal1, nReKcal2
   LOCAL lRePri, lReVer, lReOto, lReInv
   LOCAL nRecPtr := RE->( RecNo() )
   LOCAL nOrden  := RE->( ordNumber() )
   LOCAL nRecAdd
   LOCAL nRecMa := 0
   LOCAL aBEpoca := { "BR_EPOCA0000", "BR_EPOCA0001", "BR_EPOCA0010", "BR_EPOCA0011", ;
      "BR_EPOCA0100", "BR_EPOCA0101", "BR_EPOCA0110", "BR_EPOCA0111", ;
      "BR_EPOCA1000", "BR_EPOCA1001", "BR_EPOCA1010", "BR_EPOCA1011", ;
      "BR_EPOCA1100", "BR_EPOCA1101", "BR_EPOCA1110", "BR_EPOCA1111",   }
   LOCAL aEpoca    := { '0000', '0001', '0010', '0011', '0100', '0101', '0110', '0111', ;
      '1000', '1001', '1010', '1011', '1100', '1101', '1110', '1111' }
   LOCAL aBDificu := { "BR_Dif1", "BR_Dif2", "BR_Dif3"  }
   LOCAL aBCalori := { "BR_CAL1C", "BR_CAL2C", "BR_CAL3C"  }
   LOCAL aBIncorp := { "BR_PROP1", "BR_PROP2"  }
   LOCAL i
   LOCAL cEsState := GetPvProfString( "Browse", "EsState", "", oApp():cInifile )
   LOCAL lBtnExpres := .F.

   //local aPlItems := { oAGet():aPl1, oAGet():aPl2, oAGet():aPl3, oAGet():aPl4, oAGet():aPl5 }
   LOCAL aDietas  := {}
   LOCAL aDietasB := {}
   LOCAL cReDupCodigo

   IF RE->( Eof() ) .AND. nMode != 1
      RETURN NIL
   ENDIF

   // oApp():oDlg:lModal := .t.

   oApp():nEdit++

   IF nMode == 1
      RE->( dbAppend() )
      REPLACE RE->RePlato     WITH "1"
      REPLACE RE->ReEpoca     WITH 0
      REPLACE RE->ReDificu    WITH 1
      REPLACE RE->ReIncorp    WITH 1
      RE->( dbCommit() )
      nRecAdd := RE->( RecNo() )
   ENDIF

   cReCodigo   := RE->ReCodigo
   cReDupCodigo := RE->ReCodigo
   cReTitulo   := RE->ReTitulo
   nRePlato    := iif( nMode == 1, 1, Val( RE->RePlato ) )
   cReTipo     := RE->ReTipo
   cReTipoCoc  := RE->ReTipoCoc
   cReFrCargo  := RE->ReFrCargo
   cReFrTipo   := RE->ReFrTipo
   cReIngPri := RE->ReIngPri
   nReepoca    := iif( nMode == 1, 1, Re->Reepoca )
   nReComens   := iif( nMode == 1, 1, RE->ReComens )
   mReIngred   := RE->ReIngred
   mRePrepar   := RE->RePrepar
   cReTiempo   := RE->ReTiempo
   nRedificu   := iif( nMode == 1, 1, Re->Redificu )
   nRePrecio   := RE->RePrecio
   nRePPC      := RE->RePPC
   nReCalori   := iif( nMode == 1, 1, RE->ReCalori )
   mReTrucos   := RE->ReTrucos
   mReVino     := RE->ReVino
   cRePublica  := RE->RePublica
   cReAutor    := RE->ReAutor
   cReEmail    := RE->ReEmail
   cRePais     := RE->RePais
   nReNumero   := RE->ReNumero
   nRePagina   := RE->RePagina
   cReFichero  := RE->ReFichero
   cReReferen  := RE->ReReferen
   cReAnotaci  := RE->ReAnotaci
   cReImagen   := RE->ReImagen
   nReEscan1   := RE->ReEscan
   nReMultip   := iif( nMode == 1, Val( GetPvProfString("Config", "Multip","2,99", oApp():cInifile ) ) / 100, RE->ReMultip )
   nRePFinal   := RE->RePFinal
   dReFchPrep  := RE->ReFchPrep
   cReValorac  := RE->ReValorac
   nReVaOrden  := RE->ReVaOrden
   cReUsuario  := RE->ReUsuario
   nReIncorp   := iif( nMode == 1, 1, RE->ReIncorp )
   dReFchInco  := iif( nMode == 1, Date(), RE->ReFchInco )
   nReComEsc   := RE->ReComEsc
   lReExpres := .F.
   cReUrl  := RE->ReUrl
   cReDietas := RTrim( RE->ReDietas )
   aDietas     := iif( At( ';',cReDietas ) != 0, hb_ATokens( cReDietas, ";" ), {} )
   IF Len( aDietas ) > 1
      ASize( aDietas, Len( aDietas ) -1 )
      FOR i := 1 TO Len( aDietas )
         aDietas[ i ] := AllTrim( aDietas[ i ] )
         AAdd( aDietasB, aDietas[ i ] )
      NEXT
      aDietas  := ASort( aDietas )
   ENDIF

   IF nMode == 3
      RE->( dbAppend() )
      REPLACE RE->RePlato     WITH "1"
      REPLACE RE->ReEpoca     WITH 0
      REPLACE RE->ReDificu    WITH 1
      REPLACE RE->ReIncorp    WITH 1
      RE->( dbCommit() )
      nRecAdd := RE->( RecNo() )
      cReCodigo  := Space( 10 )
   ENDIF

   DEFINE DIALOG oDlg RESOURCE "RE_EDIT_" + oApp():cLanguage TITLE aTitle[ nMode ] OF oParent
   oDlg:SetFont( oApp():oFont )

   REDEFINE GET aGet[ 1 ] VAR cReTitulo   ;
      ID 101 OF oDlg UPDATE

   REDEFINE GET aGet[ 2 ] VAR cReCodigo   ;
      ID 102 OF oDlg UPDATE             ;
      PICTURE "@!"                      ;
      VALID ReClave( cReCodigo, aGet[ 2 ], nMode, 2 )

   REDEFINE FOLDER oFld ;
      ID 110 OF oDlg    ;
      ITEMS i18n( " Receta " ), i18n( " Ingredientes " ), i18n( " Preparación " ), ;
      i18n( " Trucos " ), i18n( " Procedencia " ), i18n( " Escandallo " ), i18n( " Imagen " );
      DIALOGS "RE_EDIT_A_" + oApp():cLanguage, "RE_EDIT_B_" + oApp():cLanguage, "RE_EDIT_C_" + oApp():cLanguage, ;
      "RE_EDIT_D_" + oApp():cLanguage, "RE_EDIT_E_" + oApp():cLanguage, "RE_EDIT_F_" + oApp():cLanguage, ;
      "RE_EDIT_G_" + oApp():cLanguage ;
      OPTION 1

   REDEFINE SAY aSay[ 01 ] ID 201 OF oFld:aDialogs[ 1 ]
   REDEFINE SAY aSay[ 02 ] ID 202 OF oFld:aDialogs[ 1 ]
   REDEFINE SAY aSay[ 03 ] ID 203 OF oFld:aDialogs[ 1 ]
   REDEFINE SAY aSay[ 04 ] ID 204 OF oFld:aDialogs[ 1 ]
   REDEFINE SAY aSay[ 05 ] ID 205 OF oFld:aDialogs[ 1 ]
   REDEFINE SAY aSay[ 06 ] ID 206 OF oFld:aDialogs[ 1 ]
   REDEFINE SAY aSay[ 07 ] ID 207 OF oFld:aDialogs[ 1 ]
   REDEFINE SAY aSay[ 08 ] ID 208 OF oFld:aDialogs[ 1 ]
   REDEFINE SAY aSay[ 09 ] ID 209 OF oFld:aDialogs[ 1 ]
   REDEFINE SAY aSay[ 10 ] ID 210 OF oFld:aDialogs[ 1 ]
   REDEFINE SAY aSay[ 11 ] ID 211 OF oFld:aDialogs[ 1 ]
   REDEFINE SAY aSay[ 39 ] ID 214 OF oFld:aDialogs[ 1 ]
   REDEFINE SAY aSay[ 40 ] ID 215 OF oFld:aDialogs[ 1 ]
   REDEFINE SAY aSay[ 12 ] ID 201 OF oFld:aDialogs[ 2 ]
   REDEFINE SAY aSay[ 13 ] ID 201 OF oFld:aDialogs[ 3 ]
   REDEFINE SAY aSay[ 14 ] ID 212 OF oFld:aDialogs[ 1 ]
   REDEFINE SAY aSay[ 15 ] ID 213 OF oFld:aDialogs[ 1 ]
   REDEFINE SAY aSay[ 16 ] ID 201 OF oFld:aDialogs[ 4 ]
   REDEFINE SAY aSay[ 17 ] ID 202 OF oFld:aDialogs[ 4 ]
   REDEFINE SAY aSay[ 18 ] ID 201 OF oFld:aDialogs[ 5 ]
   REDEFINE SAY aSay[ 19 ] ID 202 OF oFld:aDialogs[ 5 ]
   REDEFINE SAY aSay[ 20 ] ID 203 OF oFld:aDialogs[ 5 ]
   REDEFINE SAY aSay[ 21 ] ID 204 OF oFld:aDialogs[ 5 ]
   REDEFINE SAY aSay[ 22 ] ID 205 OF oFld:aDialogs[ 5 ]
   REDEFINE SAY aSay[ 23 ] ID 206 OF oFld:aDialogs[ 5 ]
   REDEFINE SAY aSay[ 24 ] ID 207 OF oFld:aDialogs[ 5 ]
   REDEFINE SAY aSay[ 25 ] ID 208 OF oFld:aDialogs[ 5 ]
   REDEFINE SAY aSay[ 26 ] ID 209 OF oFld:aDialogs[ 5 ]
   REDEFINE SAY aSay[ 27 ] ID 210 OF oFld:aDialogs[ 5 ]
   REDEFINE SAY aSay[ 28 ] ID 211 OF oFld:aDialogs[ 5 ]
   REDEFINE SAY aSay[ 38 ] ID 212 OF oFld:aDialogs[ 5 ]
   REDEFINE SAY aSay[ 29 ] ID 201 OF oFld:aDialogs[ 6 ]
   REDEFINE SAY aSay[ 30 ] ID 202 OF oFld:aDialogs[ 6 ]
   REDEFINE SAY aSay[ 31 ] ID 203 OF oFld:aDialogs[ 6 ]
   REDEFINE SAY aSay[ 32 ] ID 204 OF oFld:aDialogs[ 6 ]
   REDEFINE SAY aSay[ 33 ] ID 205 OF oFld:aDialogs[ 6 ]
   REDEFINE SAY aSay[ 34 ] ID 206 OF oFld:aDialogs[ 6 ]
   REDEFINE SAY aSay[ 35 ] ID 207 OF oFld:aDialogs[ 6 ]
   REDEFINE SAY aSay[ 36 ] ID 208 OF oFld:aDialogs[ 6 ]
   REDEFINE SAY aSay[ 37 ] ID 201 OF oFld:aDialogs[ 7 ]

   // receta

   REDEFINE RADIO aRad[ 1 ] VAR nRePlato ;
      ID 101, 102, 103, 104, 105 OF oFld:aDialogs[ 1 ] UPDATE ;
      ON CHANGE PL->( ordSetFocus( nRePlato + 1 ) )

   REDEFINE AUTOGET aGet[ 3 ] VAR cReTipo      ;
      DATASOURCE {}      ;
      FILTER PlList( uDataSource, cData, Self );
      HEIGHTLIST 100 ;
      ID 106 OF oFld:aDialogs[ 1 ] UPDATE      ;
      VALID PlClave( @cReTipo, aGet[ 3 ], 4, nRePlato + 1 )

   REDEFINE BUTTON aBtn[ 1 ]                   ;
      ID 130 OF oFld:aDialogs[ 1 ] UPDATE      ;
      ACTION PlSeleccion( cReTipo, aGet[ 3 ], nRePlato + 1, oDlg )
   aBtn[ 1 ]:cTooltip := i18n( "seleccionar tipo de plato" )

   REDEFINE AUTOGET aGet[ 4 ] VAR cReTipoCoc   ;
      DATASOURCE {}      ;
      FILTER PlListC( uDataSource, cData, Self );
      HEIGHTLIST 100 ;
      ID 107 OF oFld:aDialogs[ 1 ] UPDATE      ;
      VALID PlClave( cReTipoCoc, aGet[ 4 ], 4, 7 )

   REDEFINE BUTTON aBtn[ 2 ]                   ;
      ID 131 OF oFld:aDialogs[ 1 ] UPDATE      ;
      ACTION PlSeleccion( cReTipoCoc, aGet[ 4 ], 7, oDlg )
   aBtn[ 2 ]:cTooltip := i18n( "seleccionar tipo de cocinado" )

   REDEFINE AUTOGET aGet[ 31 ] VAR cReFrTipo   ;
      DATASOURCE {}      ;
      FILTER FrList( uDataSource, cData, Self );
      HEIGHTLIST 100 ;
      ID 108 OF oFld:aDialogs[ 1 ] UPDATE      ;
      VALID FrClave( @cReFrTipo, aGet[ 31 ], 4 )

   REDEFINE BUTTON aBtn[ 3 ]                   ;
      ID 132 OF oFld:aDialogs[ 1 ] UPDATE      ;
      ACTION FrSeleccion( aGet[ 31 ], @cReFrCargo, @cReFrTipo, oDlg )
   aBtn[ 3 ]:cTooltip := i18n( "seleccionar denominación francesa" )

   REDEFINE AUTOGET aGet[ 33 ] VAR cReIngPri   ;
      DATASOURCE {}      ;
      FILTER IpList( uDataSource, cData, Self );
      HEIGHTLIST 100 ;
      ID 109 OF oFld:aDialogs[ 1 ] UPDATE      ;
      VALID IpClave( @cReIngPri, aGet[ 33 ], 4 )

   REDEFINE BUTTON aBtn[ 16 ]                   ;
      ID 133 OF oFld:aDialogs[ 1 ] UPDATE      ;
      ACTION IpSeleccion( @cReIngPri, aGet[ 33 ], oDlg )
   aBtn[ 16 ]:cTooltip := i18n( "seleccionar ingrediente principal" )

   aGet[ 34 ] := TTagEver():Redefine( 146, oFld:aDialogs[ 1 ], , aDietas )

   REDEFINE BUTTON aBtn[ 17 ]                   ;
      ID 134 OF oFld:aDialogs[ 1 ] UPDATE      ;
      ACTION DiSeleccion( @aDietas, aGet[ 34 ], oDlg )
   aBtn[ 17 ]:cTooltip := i18n( "seleccionar dieta / tolerancia" )

   cReEpoca := StrTran( Str( nReEpoca,4 ), ' ', '0' )
   lRePri   := ( SubStr( cReEpoca,1,1 ) == '1' )
   lReVer   := ( SubStr( cReEpoca,2,1 ) == '1' )
   lReOto   := ( SubStr( cReEpoca,3,1 ) == '1' )
   lReInv   := ( SubStr( cReEpoca,4,1 ) == '1' )

   REDEFINE CHECKBOX oCh01 VAR lRePri ID 126 OF oFld:aDialogs[ 1 ]
   oCh01:bChange := {|| ( cReEpoca := iif( lRePri,'1','0' ) + SubStr( cReEpoca,2,3 ),;
      aBmp[ 1 ]:SetBmp( aBEpoca[ AScan( aEpoca,cReEpoca ) ] ),;
      aBmp[ 1 ]:refresh() ) }
   REDEFINE CHECKBOX oCh02 VAR lReVer ID 127 OF oFld:aDialogs[ 1 ]
   oCh02:bChange := {|| ( cReEpoca := SubStr( cReEpoca,1,1 ) + iif( lReVer,'1','0' ) + SubStr( cReEpoca,3,2 ),;
      aBmp[ 1 ]:SetBmp( aBEpoca[ AScan( aEpoca,cReEpoca ) ] ),;
      aBmp[ 1 ]:refresh() ) }
   REDEFINE CHECKBOX oCh03 VAR lReOto ID 128 OF oFld:aDialogs[ 1 ]
   oCh03:bChange := {|| ( cReEpoca := SubStr( cReEpoca,1,2 ) + iif( lReOto,'1','0' ) + SubStr( cReEpoca,4,1 ),;
      aBmp[ 1 ]:SetBmp( aBEpoca[ AScan( aEpoca,cReEpoca ) ] ),;
      aBmp[ 1 ]:refresh() ) }
   REDEFINE CHECKBOX oCh04 VAR lReInv ID 129 OF oFld:aDialogs[ 1 ]
   oCh04:bChange := {|| ( cReEpoca := SubStr( cReEpoca,1,3 ) + iif( lReInv,'1','0' ),;
      aBmp[ 1 ]:SetBmp( aBEpoca[ AScan( aEpoca,cReEpoca ) ] ),;
      aBmp[ 1 ]:refresh() ) }

   REDEFINE BITMAP aBmp[ 1 ] ID 122 OF oFld:aDialogs[ 1 ] ;
      RESOURCE aBEpoca[ AScan( aEpoca, cReEpoca ) ] TRANSPARENT UPDATE

   REDEFINE RADIO aRad[ 3 ] VAR nReDificu;
      ID 112, 113, 114 OF oFld:aDialogs[ 1 ] UPDATE
   aRad[ 3 ]:bChange := {|| ( aBmp[ 2 ]:SetBmp( aBDificu[ nReDificu ] ), ;
      aBmp[ 2 ]:refresh() ) }

   REDEFINE BITMAP aBmp[ 2 ] ID 123 OF oFld:aDialogs[ 1 ] ;
      RESOURCE aBDificu[ nReDificu ] TRANSPARENT UPDATE

   REDEFINE RADIO aRad[ 4 ] VAR nReCalori;
      ID 115, 116, 117 OF oFld:aDialogs[ 1 ] UPDATE
   aRad[ 4 ]:bChange := {|| ( aBmp[ 3 ]:SetBmp( aBCalori[ nReCalori ] ), ;
      aBmp[ 3 ]:refresh() ) }

   REDEFINE BITMAP aBmp[ 3 ] ID 124 OF oFld:aDialogs[ 1 ] ;
      RESOURCE aBCalori[ nReCalori ] TRANSPARENT UPDATE

   REDEFINE GET aGet[ 5 ] VAR nReComens ;
      ID 118 OF oFld:aDialogs[ 1 ] PICTURE ' 99' UPDATE
   aGet[ 5 ]:bValid  := {|| ( nRePPC := nRePrecio / nReComens, aGet[ 8 ]:Refresh(), .T. ) }

   REDEFINE GET aGet[ 6 ] VAR cReTiempo ;
      ID 119 OF oFld:aDialogs[ 1 ] UPDATE

   REDEFINE GET aGet[ 7 ] VAR nRePrecio ;
      ID 120 OF oFld:aDialogs[ 1 ] PICTURE '@E 999,999.99' UPDATE
   aGet[ 7 ]:bValid  := {|| ( nRePPC := nRePrecio / nReComens, aGet[ 8 ]:Refresh(), .T. ) }

   REDEFINE GET aGet[ 8 ] VAR nRePPC    ;
      ID 121 OF oFld:aDialogs[ 1 ] PICTURE '@E 999,999.99' UPDATE

   REDEFINE GET aGet[ 11 ] VAR dReFchPrep ;
      ID 141 OF oFld:aDialogs[ 1 ] UPDATE

   REDEFINE BUTTON aBtn[ 4 ]             ;
      ID 142 OF oFld:aDialogs[ 1 ] UPDATE;
      ACTION SelecFecha( dReFchPrep, aGet[ 11 ] )
   aBtn[ 4 ]:cTooltip := i18n( "seleccionar fecha" )

   REDEFINE AUTOGET aGet[ 12 ] VAR cReValorac ;
      DATASOURCE {}      ;
      FILTER VaList( uDataSource, cData, Self );
      HEIGHTLIST 100 ;
      ID 143 OF oFld:aDialogs[ 1 ] UPDATE;
      VALID VaClave( @cReValorac, aGet[ 12 ], 4, @nReVaOrden )

   REDEFINE BUTTON aBtn[ 5 ]             ;
      ID 144 OF oFld:aDialogs[ 1 ] UPDATE;
      ACTION VaSeleccion( @cReValorac, aGet[ 12 ], @nReVaOrden, oDlg )
   aBtn[ 5 ]:cTooltip := i18n( "seleccionar valoración" )

   // ingredientes

   REDEFINE GET aGet[ 9 ] VAR mReIngred ;
      ID 101 OF oFld:aDialogs[ 2 ] MEMO UPDATE

   // preparación

   REDEFINE GET aGet[ 10 ] VAR mRePrepar ;
      ID 101 OF oFld:aDialogs[ 3 ] MEMO UPDATE

   // trucos

   REDEFINE GET aGet[ 13 ] VAR mReTrucos     ;
      ID 101 OF oFld:aDialogs[ 4 ] MEMO UPDATE

   REDEFINE GET aGet[ 14 ] VAR mReVino       ;
      ID 102 OF oFld:aDialogs[ 4 ] MEMO UPDATE

   // procedencia
   REDEFINE AUTOGET aGet[ 15 ] VAR cReAutor   ;
      DATASOURCE {}      ;
      FILTER AuList( uDataSource, cData, Self );
      HEIGHTLIST 100 ;
      ID 101 OF oFld:aDialogs[ 5 ] UPDATE   ;
      VALID AuClave( cReAutor, aGet[ 15 ], 4, aGet[ 16 ], aGet[ 17 ] )

   REDEFINE BUTTON aBtn[ 10 ]               ;
      ID 130 OF oFld:aDialogs[ 5 ]          ;
      ACTION AuSeleccion( cReAutor, aGet[ 15 ], aGet[ 16 ], aGet[ 17 ], oDlg )
   aBtn[ 10 ]:cTooltip := i18n( "seleccionar autor" )

   REDEFINE GET aGet[ 16 ] VAR cReEmail     ;
      ID 102 OF oFld:aDialogs[ 5 ] UPDATE

   REDEFINE BUTTON aBtn[ 11 ]               ;
      ID 131 OF oFld:aDialogs[ 5 ]          ;
      ACTION      GoMail( cReemail )
   aBtn[ 11 ]:cTooltip := i18n( "enviar e-mail" )

   REDEFINE GET aGet[ 17 ] VAR cRePais      ;
      ID 103 OF oFld:aDialogs[ 5 ] UPDATE

   REDEFINE AUTOGET aGet[ 18 ] VAR cRePublica   ;
      DATASOURCE {}      ;
      FILTER PuList( uDataSource, cData, Self );
      HEIGHTLIST 100 ;
      ID 104 OF oFld:aDialogs[ 5 ] UPDATE   ;
      VALID PuClave( cRePublica, aGet[ 18 ], 4 )

   REDEFINE BUTTON aBtn[ 12 ]               ;
      ID 132 OF oFld:aDialogs[ 5 ]          ;
      ACTION PuSeleccion( cRePublica, aGet[ 18 ], oDlg )
   aBtn[ 12 ]:cTooltip := i18n( "seleccionar publicación" )

   REDEFINE GET aGet[ 19 ] VAR nReNumero     ;
      ID 105 OF oFld:aDialogs[ 5 ] UPDATE

   REDEFINE GET aGet[ 20 ] VAR nRePagina     ;
      ID 106 OF oFld:aDialogs[ 5 ] UPDATE

   REDEFINE GET aGet[ 32 ] VAR cReURL        ;
      ID 114 OF oFld:aDialogs[ 5 ] UPDATE

   REDEFINE BUTTON aBtn[ 15 ]               ;
      ID 134 OF oFld:aDialogs[ 5 ]          ;
      ACTION      GoWeb( cReURL )
   aBtn[ 15 ]:cTooltip := i18n( "visitar enlace permanente" )

   REDEFINE RADIO aRad[ 5 ] VAR nReIncorp          ;
      ID 107, 108 OF oFld:aDialogs[ 5 ] UPDATE
   aRad[ 5 ]:bChange := {|| ( aBmp[ 4 ]:SetBmp( aBIncorp[ nReIncorp ] ), ;
      aBmp[ 4 ]:refresh() ) }

   REDEFINE BITMAP aBmp[ 4 ] ID 111 OF oFld:aDialogs[ 5 ] ;
      RESOURCE aBIncorp[ nReIncorp ] TRANSPARENT UPDATE

   REDEFINE GET aGet[ 21 ] VAR cReFichero     ;
      ID 109 OF oFld:aDialogs[ 5 ] UPDATE     ;
      WHEN nReincorp == 2

   REDEFINE GET aGet[ 22 ] VAR dReFchInco   ;
      ID 110 OF oFld:aDialogs[ 5 ] UPDATE

   REDEFINE BUTTON aBtn[ 13 ]               ;
      ID 133 OF oFld:aDialogs[ 5 ]          ;
      ACTION      SelecFecha( dReFchInco, aGet[ 22 ] )
   aBtn[ 13 ]:cTooltip := i18n( "seleccionar fecha" )

   REDEFINE GET aGet[ 29 ] VAR cReReferen     ;
      ID 112 OF oFld:aDialogs[ 5 ] UPDATE

   REDEFINE GET aGet[ 30 ] VAR cReAnotaci     ;
      ID 113 OF oFld:aDialogs[ 5 ] UPDATE

   // escandallo
   SELECT ES
   ES->( dbSetOrder( 1 ) )
   IF nMode != 3
      ordScope( 0, {|| Upper( cReCodigo ) } )
      ordScope( 1, {|| Upper( cReCodigo ) } )
   ELSE
      ordScope( 0, {|| Upper( cReDupCodigo ) } )
      ordScope( 1, {|| Upper( cReDupCodigo ) } )
   ENDIF
   ES->( dbGoTop() )
   SELECT TS
   TS->( DbPack() )
   TS->( Db_ZAP() )
   DO WHILE ! ES->( Eof() )
      TS->( dbAppend() )
      FOR i = 1 TO ES->( FCount() )
         TS->( FieldPut( i, ES->( FieldGet( i ) ) ) )
      NEXT
      ES->( dbSkip() )
   ENDDO

   SELECT TS
   TS->( ordSetFocus( 1 ) )
   TS->( dbGoTop() )
   nReEscan1 := 0
   dbEval( {|| nReEscan1 += TS->EsPrecio },,,,, .F. )
   nReEscan2 := nReEscan1 / nReComEsc
   nReKCal1  := 0
   dbEval( {|| nReKCal1 += TS->EsKCal },,,,, .F. )
   nReKCal2  := nReKCal1 / nReComEsc

   REDEFINE GET aSayEsc[ 1 ] VAR nReComEsc PICTURE " 999 " ;
      ID 11 OF oFld:aDialogs[ 6 ] WHEN .F.
   aSayEsc[ 1 ]:lDisColors  := .F.
   aSayEsc[ 1 ]:nClrTextDis := GetSysColor( 13 )

   oFld:aDialogs[ 6 ]:Update()

   REDEFINE BUTTON   ;
      ID       104   ;
      OF       oFld:aDialogs[ 6 ] ;
      ACTION   ( TsRecalc( oBrwEsc,aSayEsc,@nReComEsc,@nReEscan1,@nReEscan2,@nReKCal1,@nReKCal2,nMode,nReMultip,@nRePFinal,aGet[ 25 ] ) ) ;
      WHEN     ! Empty( cReCodigo )

   REDEFINE GET aSayEsc[ 2 ] VAR nReEscan1 PICTURE "@E 999,999.99" ;
      ID 13 OF oFld:aDialogs[ 6 ] WHEN .F.
   aSayEsc[ 2 ]:lDisColors  := .F.
   aSayEsc[ 2 ]:nClrTextDis := GetSysColor( 13 )
   REDEFINE GET aSayEsc[ 3 ] VAR nReEscan2 PICTURE "@E 999,999.99" ;
      ID 15 OF oFld:aDialogs[ 6 ] WHEN .F.
   aSayEsc[ 3 ]:lDisColors  := .F.
   aSayEsc[ 3 ]:nClrTextDis := GetSysColor( 13 )
   REDEFINE GET aSayEsc[ 4 ] VAR nReKCal1 PICTURE "@E 999,999.99" ;
      ID 17 OF oFld:aDialogs[ 6 ] WHEN .F.
   aSayEsc[ 4 ]:lDisColors  := .F.
   aSayEsc[ 4 ]:nClrTextDis := GetSysColor( 13 )
   REDEFINE GET aSayEsc[ 5 ] VAR nReKCal2 PICTURE "@E 999,999.99" ;
      ID 19 OF oFld:aDialogs[ 6 ] WHEN .F.
   aSayEsc[ 5 ]:lDisColors  := .F.
   aSayEsc[ 5 ]:nClrTextDis := GetSysColor( 13 )

   REDEFINE GET aGet[ 24 ] VAR nReMultip    ;
      PICTURE "@E 99.99"                  ;
      ID 21 OF oFld:aDialogs[ 6 ] UPDATE    ;
      VALID ( nRePFinal := nReEscan1 * nReMultip, ;
      aGet[ 25 ]:Refresh(), .T. )

   REDEFINE GET aGet[ 25 ] VAR nRePFinal    ;
      PICTURE "@E 999,999.99"             ;
      ID 23 OF oFld:aDialogs[ 6 ] UPDATE    ;
      VALID ( nReMultip := nRePFinal / nReEscan1, ;
      aGet[ 24 ]:Refresh(), .T. )

   TS->( dbGoTop() )

   oBrwEsc := TXBrowse():New( oFld:aDialogs[ 6 ] )
   Ut_BrwRowConfig( oBrwEsc )
   oBrwEsc:cAlias := "TS"

   oColEsc := oBrwEsc:AddCol()
   oColEsc:bStrData := {|| TS->EsIngred }
   oColEsc:cHeader  := "Código"
   oColEsc:nWidth   := 46
   oColEsc := oBrwEsc:AddCol()
   oColEsc:bStrData := {|| TS->EsInDenomi }
   oColEsc:cHeader  := "Ingrediente"
   oColEsc:nWidth   := 120
   oColEsc := oBrwEsc:AddCol()
   oColEsc:bStrData := {|| TS->EsUnidad }
   oColEsc:cHeader  := "Unidad"
   oColEsc:nWidth   := 48
   oColEsc := oBrwEsc:AddCol()
   oColEsc:bStrData := {|| tran( TS->EsCantidad, "@E 99.999" ) }
   oColEsc:cHeader  := "Cantid."
   oColEsc:nWidth   := 40
   oColEsc:nHeadStrAlign := 1
   oColEsc:nDataStrAlign := 1
   oColEsc := oBrwEsc:AddCol()
   oColEsc:bStrData := {|| tran( TS->EsPrecio, "@E 999,999.99" ) }
   oColEsc:cHeader  := "Precio"
   oColEsc:nWidth   := 40
   oColEsc:nHeadStrAlign := 1
   oColEsc:nDataStrAlign := 1
   oColEsc := oBrwEsc:AddCol()
   oColEsc:bStrData := {|| tran( TS->EsKCal, "@E 999,999.99" ) }
   oColEsc:cHeader  := "KCal."
   oColEsc:nWidth   := 40
   oColEsc:nHeadStrAlign := 1
   oColEsc:nDataStrAlign := 1
   oColEsc := oBrwEsc:AddCol()
   oColEsc:bStrData := {|| TS->EsProveed }
   oColEsc:cHeader  := "Proveedor"
   oColEsc:nWidth   := 60

   // oCol:bLDClickData  := {|| ( lOk := .t., oDlg:End() )   }
   oBrwEsc:SetRDD()
   oBrwEsc:CreateFromResource( 110 )
   oBrwEsc:RestoreState( cEsState )

   REDEFINE BUTTON   ;
      ID       101   ;
      OF       oFld:aDialogs[ 6 ] ;
      ACTION  iif( !Empty( cReCodigo ), ;
      iif( nReComEsc != 0, ;
      TsEdita( oBrwEsc, .T., cReTitulo, cReCodigo, cReUsuario, aSayEsc, nReComEsc, @nReEscan1, @nReEscan2, @nReKCal1, nReKCal2, nReMultip, @nRePFinal, aGet[ 25 ] ), ;
      MsgAlert( 'No se puede crear escandallos para 0 comensales. Modifique el número de comensales antes de continuar.', 'Atención' ) ), ;
      MsgAlert( 'Debe introducir código a la receta para realizar el escandallo.', 'Atención' ) )

   REDEFINE BUTTON   ;
      ID       102   ;
      OF       oFld:aDialogs[ 6 ] ;
      WHEN ( TS->( ordKeyVal() ) != nil ) ;
      ACTION   TsEdita( oBrwEsc, .F., cReTitulo, cReCodigo, cReUsuario, aSayEsc, nReComEsc, @nReEscan1, @nReEscan2, @nReKCal1, nReKCal2, nReMultip, @nRePFinal, aGet[ 25 ] )

   REDEFINE BUTTON   ;
      ID       103   ;
      OF       oFld:aDialogs[ 6 ] ;
      WHEN ( TS->( ordKeyVal() ) != nil ) ;
      ACTION   TsBorra( oBrwEsc, aSayEsc, nReComEsc, @nReEscan1, @nReEscan2, @nReKCal1, @nReKCal2, nReMultip, @nRePFinal, aGet[ 25 ] )

   REDEFINE BUTTON   ;
      ID       105   ;
      OF       oFld:aDialogs[ 6 ] ;
      WHEN ( TS->( ordKeyVal() ) != nil ) ;
      ACTION   ( CursorWait(), Ut_ExportXLS( oBrwEsc, "Escandallo" ), CursorArrow() ) ;

      REDEFINE BUTTON   ;
      ID       106   ;
      OF       oFld:aDialogs[ 6 ] ;
      WHEN ( TS->( ordKeyVal() ) != nil ) ;
      ACTION   TsIngredientes( @mReIngred, aGet[ 9 ] )

   // imagen

   REDEFINE GET aGet[ 23 ] VAR cReImagen    ;
      ID 101 OF oFld:aDialogs[ 7 ]

   REDEFINE BUTTON aBtn[ 14 ]               ;
      ID 104 OF oFld:aDialogs[ 7 ]          ;
      ACTION  ReGetImage( oImage, aGet[ 23 ], oBtnImg );
      VALID ( oImage:loadImage( , cReImagen ), oImage:refresh(), .T. )
   aBtn[ 14 ]:cTooltip := i18n( "seleccionar imagen" )

   REDEFINE ZOOMIMAGE oImage  ;
      FILE ''                 ;
      ID 102 OF oFld:aDialogs[ 7 ] // SCROLL

   // oImage:Progress( .t. )
   oImage:SetColor( CLR_RED, CLR_WHITE )

   IF File( lfn2sfn( RTrim(cReImagen ) ) )
      oImage:LoadBmp( lfn2sfn( RTrim(cReImagen ) ) )
   ENDIF

   REDEFINE BUTTON oBtnImg;
      ID       103 ;
      OF       oFld:aDialogs[ 7 ] ;
      ACTION   ReZoomImagen( cReImagen, cReTitulo, oDlg )

   REDEFINE BUTTON  ;
      ID       401  ;
      OF       oDlg ;
      ACTION   ( lBtnExpres := .T., oDlg:end( IDOK ) )

   REDEFINE BUTTON  ;
      ID       IDOK ;
      OF       oDlg ;
      ACTION   ( aDietas := aGet[ 34 ]:aItems, oDlg:end( IDOK ) )

   REDEFINE BUTTON ;
      ID       IDCANCEL ;
      OF       oDlg ;
      CANCEL ;
      ACTION   ( oDlg:end( IDCANCEL ) )

   ACTIVATE DIALOG oDlg ;
      ON INIT DlgCenter( oDlg, oApp():oWndMain )

   // guardo el estado del browse del escandallo
   WritePProString( "Browse", "EsState", oBrwEsc:SaveState(), oApp():cIniFile )
   IF oDlg:nresult == IDOK
      /* ___ computo el tipo de plato y cocinado ______________________________*/
      SELECT PL
      PL->( dbSetOrder( 1 ) )
      IF RE->RePlato + RE->ReTipo <> Str( nRePlato, 1 ) + cReTipo
         PL->( dbSeek( Str(nRePlato,1 ) + cReTipo ) )
         REPLACE PL->PlRecetas WITH PL->PlRecetas + 1
         IF nMode == 2
            PL->( dbSeek( RE->RePlato + RE->ReTipo ) )
            REPLACE PL->PlRecetas WITH PL->PlRecetas - 1
         ENDIF
         PL->( dbCommit() )
      ENDIF
      IF RE->ReTipoCoc <> cReTipoCoc
         PL->( dbSeek( '6' + cReTipoCoc ) )
         REPLACE PL->PlRecetas WITH PL->PlRecetas + 1
         IF nMode == 2
            PL->( dbSeek( '6' + RE->ReTipoCoc ) )
            REPLACE PL->PlRecetas WITH PL->PlRecetas - 1
         ENDIF
         PL->( dbCommit() )
      ENDIF

      /* ___ computo el ingrediente principal ____________________________________*/
      SELECT IP
      IP->( dbSetOrder( 1 ) )
      IF RE->ReIngPri <> cReIngPri
         IP->( dbSeek( Upper(cReIngPri ) ) )
         REPLACE IP->IpRecetas WITH IP->IpRecetas + 1
         IF nMode == 2
            IP->( dbSeek( Upper(RE->ReIngPri ) ) )
            REPLACE IP->IpRecetas WITH IP->IpRecetas - 1
         ENDIF
         IP->( dbCommit() )
      ENDIF

      /* ___ computo la valoración ____________________________________________*/
      SELECT VA
      VA->( dbSetOrder( 1 ) )
      IF RE->ReVaOrden <> nReVaOrden
         VA->( dbSeek( nReVaOrden ) )
         REPLACE VA->VaRecetas WITH VA->VaRecetas + 1
         IF nMode == 2
            VA->( dbSeek( RE->ReVaOrden ) )
            REPLACE VA->VaRecetas WITH VA->VaRecetas - 1
         ENDIF
         VA->( dbCommit() )
      ENDIF

      /* ___ computo el autor _______________________________________________*/
      SELECT AU
      AU->( dbSetOrder( 1 ) )
      IF RE->ReAutor <> cReAutor
         AU->( dbSeek( Upper(cReAutor ) ) )
         REPLACE AU->AuRecetas WITH AU->AuRecetas + 1
         IF nMode == 2
            AU->( dbSeek( Upper(RE->ReAutor ) ) )
            REPLACE AU->AuRecetas WITH AU->AuRecetas - 1
         ENDIF
         AU->( dbCommit() )
      ENDIF

      /* ___ computo la publicación __________________________________________*/
      SELECT PU
      PU->( dbSetOrder( 1 ) )
      IF RE->RePublica <> cRePublica
         PU->( dbSeek( Upper(cRePublica ) ) )
         REPLACE PU->PuRecetas WITH PU->PuRecetas + 1
         IF nMode == 2
            PU->( dbSeek( Upper(RE->RePublica ) ) )
            REPLACE PU->PuRecetas WITH PU->PuRecetas - 1
         ENDIF
         PU->( dbCommit() )
      ENDIF
      /* ___ computo las dietas _______________________________________________*/
      SELECT DI
      DI->( dbSetOrder( 1 ) )
      IF Len( aDietas ) > 0
         FOR i := 1 TO Len( aDietas )
            // TTagEver transforma aDietas en un array multidimensional
            IF ValType( aDietas[ i ] ) == 'A'
               aDietas[ i ] := aDietas[ i, 1 ]
            ENDIF
            DI->( dbSeek( Upper(RTrim(aDietas[ i ] ) ) ) )
            REPLACE DI->DiRecetas WITH DI->DiRecetas + 1
         NEXT
         DI->( dbCommit() )
         IF nMode == 2
            FOR i := 1 TO Len( aDietasB )
               DI->( dbSeek( Upper(RTrim(aDietasB[ i ] ) ) ) )
               REPLACE DI->DiRecetas WITH DI->DiRecetas -1
            NEXT
         ENDIF
      ENDIF

      /* ___ guardo el registro _______________________________________________*/
      SELECT RE
      IF nMode == 2
         RE->( dbGoto( nRecPtr ) )
      ELSE
         RE->( dbGoto( nRecAdd ) )
      ENDIF
      IF nMode == 2 .AND. RE->ReCodigo != cReCodigo
         // cambio el código en los menús de eventos
         SELECT RM
         RM->( dbGoTop() )
         REPLACE RM->RmReCodigo WITH cReCodigo FOR RM->RmReCodigo == RE->ReCodigo
         // cambio el código en los menús de semanales
         SELECT RS
         RS->( dbGoTop() )
         REPLACE RS->RsReCodigo WITH cReCodigo FOR RS->RsReCodigo == RE->ReCodigo
         SELECT RE
      ENDIF
      REPLACE Re->Retitulo    WITH cReTitulo
      REPLACE Re->ReCodigo    WITH cReCodigo
      REPLACE Re->Replato     WITH Str( nReplato, 1 )
      REPLACE Re->Retipo      WITH cRetipo
      REPLACE Re->RetipoCoc   WITH cRetipoCoc
      REPLACE Re->ReFrCargo   WITH cReFrCargo
      REPLACE Re->ReFrTipo    WITH cReFrTipo
      REPLACE Re->ReIngPri    WITH cReIngPri
      REPLACE Re->Reepoca     WITH Val( cReepoca )
      REPLACE Re->Recomens    WITH nReComens
      REPLACE Re->Reingred    WITH mReingred
      REPLACE Re->Reprepar    WITH mReprepar
      REPLACE Re->Retiempo    WITH cRetiempo
      REPLACE Re->Redificu    WITH nRedificu
      REPLACE Re->Reprecio    WITH nReprecio
      REPLACE Re->RePPC       WITH nRePPC
      REPLACE Re->Recalori    WITH nRecalori
      REPLACE Re->Retrucos    WITH mRetrucos
      REPLACE Re->Revino      WITH mRevino
      REPLACE Re->Republica   WITH cRepublica
      REPLACE Re->Reautor     WITH cReautor
      REPLACE Re->Reemail     WITH cReemail
      REPLACE Re->RePais      WITH cRepais
      REPLACE Re->Renumero    WITH nRenumero
      REPLACE Re->Repagina    WITH nRepagina
      REPLACE Re->ReIncorp    WITH nReIncorp
      REPLACE Re->ReFichero   WITH cReFichero
      REPLACE Re->ReFchInco   WITH dReFchInco
      REPLACE RE->ReReferen   WITH cReReferen
      REPLACE RE->ReAnotaci   WITH cReAnotaci
      REPLACE Re->ReEscan     WITH nReEscan1
      REPLACE Re->ReMultip    WITH nReMultip
      REPLACE Re->RePFinal    WITH nRePFinal
      REPLACE Re->ReImagen    WITH cReImagen
      REPLACE Re->ReFchPrep   WITH dReFchPrep
      REPLACE Re->ReValorac   WITH cReValorac
      REPLACE Re->ReVaOrden   WITH nReVaOrden
      REPLACE Re->Reusuario   WITH cReusuario
      REPLACE Re->ReComEsc    WITH nReComEsc
      REPLACE Re->ReExpres    WITH lReExpres
      REPLACE Re->ReURL       WITH cReUrl
      cReDietas := ''
      IF Len( aDietas ) > 0
         FOR i := 1 TO Len( aDietas )
            cReDietas := cReDietas + aDietas[ i ] + '; '
         NEXT
      ENDIF
      REPLACE Re->ReDietas    WITH cReDietas

      RE->( dbCommit() )
      // guardo el escandallo
      IF nMode != 3
         SELECT ES
         ES->( dbGoTop() )
         DO WHILE ! ES->( Eof() )
            ES->( dbDelete() )
            ES->( dbSkip() )
         ENDDO
         ordScope( 0, )
         ordScope( 1, )
         ES->( DbPack() )
      ENDIF

      SELECT TS
      TS->( dbGoTop() )
      DO WHILE ! TS->( Eof() )
         ES->( dbAppend() )
         ES->( FieldPut( 1, cReCodigo ) )
         FOR i = 2 TO ES->( FCount() )
            ES->( FieldPut( i, TS->( FieldGet( i ) ) ) )
         NEXT
         TS->( dbSkip() )
      ENDDO

   ELSE
      IF nMode == 1 .OR. nMode == 3
         RE->( dbGoto( nRecAdd ) )
         RE->( dbDelete() )
         RE->( DbPack() )
         RE->( dbGoto( nRecPtr ) )
      ENDIF
   ENDIF

   SELECT RE
   IF oCont != nil
      RefreshCont( oCont, "RE" )
   ENDIF
   IF oGrid != NIL
      oGrid:Refresh()
      oGrid:SetFocus( .T. )
   ENDIF
   IF oCont != NIL
      RefreshReBarImage()
   ENDIF
   oApp():nEdit--
   IF lBtnExpres == .T.
      ReEditaExpres( oApp():oGrid, 2, oCont, oApp():oDlg )
   ENDIF

RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION ReEditaExpres( oGrid, nMode, oCont, oParent )

   LOCAL oDlg
   LOCAL aGet[ 10 ]
   LOCAL aRad[ 2 ]
   LOCAL aSay[ 12 ]
   LOCAL aBtn[ 4 ]
   LOCAL aBmp[ 1 ]
   LOCAL oCh01, oCh02, oCh03, oCh04

   LOCAL aTitle := { i18n( "Añadir receta expres" ),;
      i18n( "Modificar receta expres" ),;
      i18n( "Duplicar receta" ) }

   LOCAL cReCodigo,;
      cReTitulo,;
      nRePlato,;
      cReTipo,;
      cReTipoCoc,;
      nReComens,;
      mReIngred,;
      mRePrepar,;
      cReTiempo,;
      nReDificu,;
      nReCalori,;
      lReExpres,;
      cReAutor,;
      cRePublica,;
      cReUrl,;
      nReIncorp,;
      dReFchInco
   LOCAL nReKCal1, nReKcal2
   LOCAL lRePri, lReVer, lReOto, lReInv
   LOCAL nRecPtr := RE->( RecNo() )
   LOCAL nOrden  := RE->( ordNumber() )
   LOCAL nRecAdd
   LOCAL nRecMa := 0
   LOCAL i
   LOCAL lBtnCompleta := .F.
   LOCAL aBIncorp := { "BR_PROP1", "BR_PROP2" }

   IF RE->( Eof() ) .AND. nMode != 1
      RETURN NIL
   ENDIF

   // oApp():oDlg:lModal := .t.

   oApp():nEdit++

   IF nMode == 1
      RE->( dbAppend() )
      REPLACE RE->RePlato     WITH "1"
      REPLACE RE->ReEpoca     WITH 0
      REPLACE RE->ReDificu    WITH 1
      REPLACE RE->ReIncorp    WITH 1
      RE->( dbCommit() )
      nRecAdd := RE->( RecNo() )
   ENDIF

   cReCodigo   := RE->ReCodigo
   cReTitulo   := RE->ReTitulo
   nRePlato    := iif( nMode == 1, 1, Val( RE->RePlato ) )
   cReTipo     := RE->ReTipo
   cReTipoCoc  := RE->ReTipoCoc
   //nReepoca    := Iif(nMode==1,1,Re->Reepoca)
   nReComens   := iif( nMode == 1, 1, RE->ReComens )
   mReIngred   := RE->ReIngred
   mRePrepar   := RE->RePrepar
   cReTiempo   := RE->ReTiempo
   cReAutor  := RE->ReAutor
   cRePublica := RE->RePublica
   nRedificu   := iif( nMode == 1, 1, Re->Redificu )
   nReCalori   := iif( nMode == 1, 1, RE->ReCalori )
   nReIncorp := RE->ReIncorp
   dReFchInco := RE->ReFchInco
   lReExpres := .T.
   cReUrl  := RE->ReUrl

   IF nMode == 3
      RE->( dbAppend() )
      REPLACE RE->RePlato     WITH "1"
      REPLACE RE->ReEpoca     WITH 0
      REPLACE RE->ReDificu    WITH 1
      REPLACE RE->ReIncorp    WITH 1
      RE->( dbCommit() )
      nRecAdd := RE->( RecNo() )
      cReCodigo := Space( 10 )
   ENDIF

   DEFINE DIALOG oDlg RESOURCE "RE_EDIT_EXPRES_" + oApp():cLanguage TITLE aTitle[ nMode ] OF oParent
   oDlg:SetFont( oApp():oFont )

   REDEFINE SAY aSay[ 01 ] ID 201 OF oDlg
   REDEFINE SAY aSay[ 02 ] ID 202 OF oDlg
   REDEFINE SAY aSay[ 03 ] ID 203 OF oDlg
   REDEFINE SAY aSay[ 04 ] ID 204 OF oDlg
   REDEFINE SAY aSay[ 05 ] ID 205 OF oDlg
   REDEFINE SAY aSay[ 06 ] ID 206 OF oDlg
   REDEFINE SAY aSay[ 07 ] ID 207 OF oDlg
   REDEFINE SAY aSay[ 08 ] ID 208 OF oDlg
   REDEFINE SAY aSay[ 09 ] ID 209 OF oDlg
   REDEFINE SAY aSay[ 10 ] ID 210 OF oDlg
   REDEFINE SAY aSay[ 11 ] ID 211 OF oDlg
   REDEFINE SAY aSay[ 12 ] ID 212 OF oDlg

   REDEFINE GET aGet[ 1 ] VAR cReTitulo   ;
      ID 101 OF oDlg UPDATE

   REDEFINE GET aGet[ 2 ] VAR cReCodigo   ;
      ID 102 OF oDlg UPDATE             ;
      PICTURE "@!"                      ;
      VALID ReClave( cReCodigo, aGet[ 2 ], nMode, 2 )

   REDEFINE RADIO aRad[ 1 ] VAR nRePlato ;
      ID 103, 104, 105, 106, 107 OF oDlg UPDATE

   REDEFINE GET aGet[ 3 ] VAR nReComens ;
      ID 108 OF oDlg PICTURE ' 99' UPDATE

   REDEFINE GET aGet[ 4 ] VAR cReTiempo ;
      ID 109 OF oDlg UPDATE

   // ingredientes

   REDEFINE GET aGet[ 5 ] VAR mReIngred ;
      ID 110 OF oDlg MEMO UPDATE

   // preparación

   REDEFINE GET aGet[ 6 ] VAR mRePrepar ;
      ID 111 OF oDlg MEMO UPDATE

   // trucos

   REDEFINE AUTOGET aGet[ 7 ] VAR cReAutor ;
      DATASOURCE {}      ;
      FILTER AuList( uDataSource, cData, Self );
      HEIGHTLIST 100 ;
      ID 112 OF oDlg ;
      VALID AuClave( cReAutor, aGet[ 7 ], 4, , )

   REDEFINE BUTTON aBtn[ 1 ]    ;
      ID 402 OF oDlg          ;
      ACTION AuSeleccion( cReAutor, aGet[ 7 ], , , oDlg )
   aBtn[ 1 ]:cTooltip := i18n( "seleccionar autor" )

   REDEFINE AUTOGET aGet[ 8 ] VAR cRePublica   ;
      DATASOURCE {}      ;
      FILTER PuList( uDataSource, cData, Self );
      HEIGHTLIST 100 ;
      ID 113 OF oDlg      ;
      VALID PuClave( cRePublica, aGet[ 8 ], 4 )

   REDEFINE BUTTON aBtn[ 2 ]    ;
      ID 403 OF oDlg          ;
      ACTION PuSeleccion( cRePublica, aGet[ 8 ], oDlg )
   aBtn[ 2 ]:cTooltip := i18n( "seleccionar publicación" )

   REDEFINE GET aGet[ 9 ] VAR cReUrl    ;
      ID 114 OF oDlg UPDATE
   REDEFINE BUTTON aBtn[ 3 ]            ;
      ID 404 OF oDlg                  ;
      ACTION GoWeb( cReURL )
   aBtn[ 3 ]:cTooltip := i18n( "visitar enlace permanente" )

   REDEFINE RADIO aRad[ 2 ] VAR nReIncorp          ;
      ID 115, 116 OF oDlg
   aRad[ 2 ]:bChange := {|| ( aBmp[ 1 ]:SetBmp( aBIncorp[ nReIncorp ] ), ;
      aBmp[ 1 ]:refresh() ) }
   REDEFINE BITMAP aBmp[ 1 ] ID 118 OF oDlg ;
      RESOURCE aBIncorp[ nReIncorp ] TRANSPARENT UPDATE

   REDEFINE GET aGet[ 10 ] VAR dReFchInco ;
      ID 117 OF oDlg UPDATE
   REDEFINE BUTTON aBtn[ 4 ]              ;
      ID 405 OF oDlg                    ;
      ACTION      SelecFecha( dReFchInco, aGet[ 10 ] )
   aBtn[ 4 ]:cTooltip := i18n( "seleccionar fecha" )

   REDEFINE BUTTON  ;
      ID       401  ;
      OF       oDlg ;
      ACTION   ( lBtnCompleta := .T., oDlg:end( IDOK ) )

   REDEFINE BUTTON  ;
      ID       IDOK ;
      OF       oDlg ;
      ACTION   ( oDlg:end( IDOK ) )

   REDEFINE BUTTON ;
      ID       IDCANCEL ;
      OF       oDlg ;
      CANCEL ;
      ACTION   ( oDlg:end( IDCANCEL ) )


   ACTIVATE DIALOG oDlg ;
      ON INIT DlgCenter( oDlg, oApp():oWndMain )

   IF oDlg:nresult == IDOK
      /* ___ computo el tipo de plato y cocinado ______________________________*/
      SELECT PL
      PL->( dbSetOrder( 1 ) )
      IF RE->RePlato + RE->ReTipo <> Str( nRePlato, 1 ) + cReTipo
         PL->( dbSeek( Str(nRePlato,1 ) + cReTipo ) )
         REPLACE PL->PlRecetas WITH PL->PlRecetas + 1
         IF nMode == 2
            PL->( dbSeek( RE->RePlato + RE->ReTipo ) )
            REPLACE PL->PlRecetas WITH PL->PlRecetas - 1
         ENDIF
         PL->( dbCommit() )
      ENDIF
      IF RE->ReTipoCoc <> cReTipoCoc
         PL->( dbSeek( '6' + cReTipoCoc ) )
         REPLACE PL->PlRecetas WITH PL->PlRecetas + 1
         IF nMode == 2
            PL->( dbSeek( '6' + RE->ReTipoCoc ) )
            REPLACE PL->PlRecetas WITH PL->PlRecetas - 1
         ENDIF
         PL->( dbCommit() )
      ENDIF

      /* ___ guardo el registro _______________________________________________*/
      SELECT RE
      IF nMode == 2
         RE->( dbGoto( nRecPtr ) )
      ELSE
         RE->( dbGoto( nRecAdd ) )
      ENDIF
      IF nMode == 2 .AND. RE->ReCodigo != cReCodigo
         SELECT RM
         RM->( dbGoTop() )
         REPLACE RM->RmReCodigo WITH cReCodigo FOR RM->RmReCodigo == RE->ReCodigo
         SELECT RE
      ENDIF
      REPLACE Re->Retitulo    WITH cReTitulo
      REPLACE Re->ReCodigo    WITH cReCodigo
      REPLACE Re->Replato     WITH Str( nReplato, 1 )
      REPLACE Re->Retipo      WITH cRetipo
      REPLACE Re->Recomens    WITH nReComens
      REPLACE Re->Reingred    WITH mReingred
      REPLACE Re->Reprepar    WITH mReprepar
      REPLACE Re->Retiempo    WITH cRetiempo
      REPLACE Re->ReExpres    WITH lReExpres
      REPLACE Re->ReURL       WITH cReUrl
      REPLACE Re->ReAutor     WITH cReAutor
      REPLACE Re->RePublica   WITH cRePublica
      REPLACE Re->ReIncorp    WITH nReIncorp
      REPLACE Re->ReFchInco   WITH dReFchInco
      RE->( dbCommit() )
   ELSE
      IF nMode == 1 .OR. nMode == 3
         RE->( dbGoto( nRecAdd ) )
         RE->( dbDelete() )
         RE->( DbPack() )
         RE->( dbGoto( nRecPtr ) )
      ENDIF
   ENDIF

   SELECT RE
   IF oCont != nil
      RefreshCont( oCont, "RE" )
   ENDIF
   oGrid:Refresh()
   oGrid:SetFocus( .T. )
   // oApp():oDlg:lModal := .f.
   oApp():nEdit--

   IF lBtnCompleta == .T.
      ReEdita( oApp():oGrid, 2, oCont, oApp():oDlg )
   ENDIF

RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION ReBorra( oGrid, oCont )

   LOCAL nRecord := RE->( RecNo() )
   LOCAL nNext

   oApp():nEdit++
   IF msgYesNo( i18n( "¿ Está seguro de borrar esta receta ?",'Seleccione una opción' ) + CRLF + ;
         ( Trim( RE->ReTitulo ) ), 'Seleccione una opción' )
      /* ___ Borro el escandallo ______________________________________________*/
      SELECT ES
      ES->( dbSetOrder( 1 ) )
      ES->( dbSeek( RE->ReCodigo ) )
      DO WHILE ES->EsReceta == RE->ReCodigo .AND. ! ES->( Eof() )
         ES->( dbDelete() )
         ES->( dbSkip() )
      ENDDO
      ES->( DbPack() )

      /* ___ Quito 1 al tipo de plato _________________________________________*/
      SELECT PL
      PL->( dbSetOrder( 1 ) )
      PL->( dbSeek( RE->RePlato + RE->ReTipo ) )
      REPLACE PL->PlRecetas WITH PL->PlRecetas - 1
      PL->( dbCommit() )
      PL->( dbSeek( '6' + RE->ReTipoCoc ) )
      REPLACE PL->PlRecetas WITH PL->PlRecetas - 1
      PL->( dbCommit() )
      /* ___ computo el ingrediente principal ____________________________________*/
      SELECT IP
      IP->( dbSetOrder( 1 ) )
      IP->( dbSeek( Upper(RE->ReIngPri ) ) )
      REPLACE IP->IpRecetas WITH IP->IpRecetas - 1
      IP->( dbCommit() )

      /* ___ computo la valoración ____________________________________________*/
      SELECT VA
      VA->( dbSetOrder( 1 ) )
      VA->( dbSeek( RE->ReVaOrden ) )
      REPLACE VA->VaRecetas WITH VA->VaRecetas - 1
      VA->( dbCommit() )

      /* ___ computo el autor _______________________________________________*/
      SELECT AU
      AU->( dbSetOrder( 1 ) )
      AU->( dbSeek( Upper(RE->ReAutor ) ) )
      REPLACE AU->AuRecetas WITH AU->AuRecetas - 1
      AU->( dbCommit() )

      /* ___ computo la publicación __________________________________________*/
      SELECT PU
      PU->( dbSetOrder( 1 ) )
      PU->( dbSeek( Upper(RE->RePublica ) ) )
      REPLACE PU->PuRecetas WITH PU->PuRecetas - 1
      PU->( dbCommit() )

      /* ___ borro la receta de menus semanales _______________________________*/
      SELECT RS
      DELETE ALL FOR RS->RsReCodigo == RE->ReCodigo

      /* ___ borro la receta de menus de eventos ______________________________*/
      SELECT RM
      DELETE ALL FOR RM->RmReCodigo == RE->ReCodigo

      /* ___ borro la receta __________________________________________________*/
      SELECT RE
      RE->( dbSkip() )
      nNext := RE->( RecNo() )
      RE->( dbGoto( nRecord ) )

      RE->( dbDelete() )
      RE->( DbPack() )
      RE->( dbGoto( nNext ) )
      IF RE->( Eof() ) .OR. nNext == nRecord
         RE->( dbGoBottom() )
      ENDIF
   ENDIF
   RefreshCont( oCont, "RE" )
   oGrid:Refresh( .T. )
   oGrid:SetFocus( .T. )
   RefreshReBarImage()
   oApp():nEdit--

RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION ReTecla( nKey, oGrid, oCont, oDlg )

   DO CASE
   CASE nKey == VK_RETURN
      ReEdita( oGrid, 2, oCont, oDlg )
   CASE nKey == VK_INSERT
      ReEdita( oGrid, 1, oCont, oDlg )
   CASE nKey == VK_DELETE
      ReBorra( oGrid, oCont )
   CASE nKey == VK_ESCAPE
      oDlg:End()
   OTHERWISE
      IF nKey >= 96 .AND. nKey <= 105 // número
         ReBusca( oGrid, Str( nKey - 96,1 ), oCont, oDlg )
      ELSEIF HB_ISSTRING( Chr( nKey ) )
         ReBusca( oGrid, Chr( nKey ), oCont, oDlg )
      ENDIF
   /* - según Jaime
      otherwise
          // paso de minúsculas a mayúsculas (letras equivalentes)
         if nKey >= 97 .AND. nKey <= 122
            nKey := nKey - 32
         endif
         // comprobación de la tecla pulsada
         if ( nKey >= 65 .AND. nKey <=  90 ) .OR. ; // si es letra
             ( nKey >= 48 .AND. nKey <=  57 ) .OR. ; // si es número
             ( nKey >= 96 .AND. nKey <= 105 )        // si es numpad
             LiSeek( oBrw, oCont, nTabOpc, chr( nKey ) )
         endif
   */
   ENDCASE

RETURN NIL
/*_____________________________________________________________________________*/
FUNCTION ReFilter( i, oCont, oMenu, oBar, oVItem, oMItem )

   LOCAL cReTipo   := Space( 30 )
   LOCAL cReCate
   LOCAL cReFrTipo := Space( 30 )
   LOCAL cReIngPri := Space( 20 )
   LOCAL cReDieta  := Space( 20 )
   LOCAL cReAP   := Space( 50 )
   LOCAL j
   LOCAL aFiltro := { "", "Categoría", "Categoría", "Plato", "Cocinado", "C. Francesa", "Ingrediente Prin.", "Dieta / Tolerancia", "Autor", "Publicación", "", "Seleccionadas" }

   IF i == 0
      RE->( dbClearFilter() )
      j := 0
   ELSEIF i == 10
      RE->( dbSetFilter( {|| RE->RePlato == '1' } ) )
      j := 2
   ELSEIF i == 11
      RE->( dbSetFilter( {|| RE->RePlato == '2' } ) )
      j := 3
   ELSEIF i == 12
      RE->( dbSetFilter( {|| RE->RePlato == '3' } ) )
      j := 3
   ELSEIF i == 13
      RE->( dbSetFilter( {|| RE->RePlato == '4' } ) )
      j := 3
   ELSEIF i == 14
      RE->( dbSetFilter( {|| RE->RePlato == '5' } ) )
      j := 3
   ELSEIF i == 2
      // tipo de plato
      PlSeleccion( @cReTipo, , 9, oApp():oDlg, oVItem )
      IF cReTipo != Space( 30 )
         cReCate := Left( cReTipo, 1 )
         cRetipo := Right( cReTipo, Len( cRetipo ) -1 )
         RE->( dbSetFilter( {|| RE->RePlato == cReCate .AND. Upper(RTrim(RE->ReTipo ) ) == Upper(RTrim(cReTipo ) ) } ) )
         j := 4
      ELSE
         RE->( dbClearFilter() )
         j := 0
      ENDIF
   ELSEIF i == 3
      // tipo de cocinado
      PlSeleccion( @cReTipo, , 7, oApp():oDlg, oVItem )
      IF cReTipo != Space( 30 )
         RE->( dbSetFilter( {|| Upper(RTrim(RE->ReTipoCoc ) ) == Upper(RTrim(cReTipo ) ) } ) )
         j := 5
      ELSE
         RE->( dbClearFilter() )
         j := 0
      ENDIF
   ELSEIF i == 4
      // clasificación francesa
      FrSeleccion( , , @cReFrTipo, oApp():oDlg, oVItem )
      IF cReFrTipo != Space( 30 )
         RE->( dbSetFilter( {|| Upper(RTrim(RE->ReFrTipo ) ) == Upper(RTrim(cReFrTipo ) ) } ) )
         j := 6
      ELSE
         RE->( dbClearFilter() )
         j := 0
      ENDIF
   ELSEIF i == 5
      // ingrediente principal
      IpSeleccion( @cReIngPri, , oApp():oDlg, oVItem )
      IF cReIngPri != Space( 20 )
         RE->( dbSetFilter( {|| Upper(RTrim(RE->ReIngPri ) ) == Upper(RTrim(cReIngPri ) ) } ) )
         j := 7
      ELSE
         RE->( dbClearFilter() )
         j := 0
      ENDIF
   ELSEIF i == 6
      // dieta / tolerancia
      DiSeleccion( , , oApp():oDlg, @cReDieta, oVItem )
      IF cReDieta != Space( 20 )
         RE->( dbSetFilter( {|| At(cReDieta, RE->ReDietas ) != 0 } ) )
         j := 8
      ELSE
         RE->( dbClearFilter() )
         j := 0
      ENDIF
   ELSEIF i == 7
      // autor
      AuSeleccion( @cReAP, , , , oApp():oDlg, oVItem )
      IF cReAp != Space( 50 )
         RE->( dbSetFilter( {|| Upper(RTrim(RE->ReAutor ) ) == Upper(RTrim(cReAP ) ) } ) )
         j := 9
      ELSE
         RE->( dbClearFilter() )
         j := 0
      ENDIF
   ELSEIF i == 8
      // publicación
      PuSeleccion( @cReAP, , oApp():oDlg, oVItem )
      IF cReAp != Space( 50 )
         RE->( dbSetFilter( {|| Upper(RTrim(RE->RePublica ) ) == Upper(RTrim(cReAP ) ) } ) )
         j := 10
      ELSE
         RE->( dbClearFilter() )
         j := 0
      ENDIF
   ELSEIF i == 9
      // recetas seleccionadas
      RE->( dbSetFilter( {|| RE->ReSelecc == SELECCIONADA } ) )
      j := 12
   ENDIF

   RE->( dbGoTop() )
   RefreshCont( oCont, "RE" )
   oApp():oGrid:Refresh( .T. )
   FOR i := 1 TO Len( oMenu:aItems )
      oMenu:aItems[ i ]:SetCheck( .F. )
   NEXT
   IF j == 0
      oMenu:aItems[ 1 ]:SetCheck( .T. )
      oBar:cTitle := "recetas"
      oVItem:SetColor( CLR_BLACK )
   ELSE
      IF j == 2
         oMItem:SetCheck( .T. )
      ELSE
         oMenu:aItems[ j ]:SetCheck( .T. )
      ENDIF
      oBar:cTitle := "recetas [ ** " + RTrim( aFiltro[ j ] ) + " ** ]"
      oVItem:SetColor( CLR_HRED ) //oApp():nClrBar)
   ENDIF
   oBar:Refresh()

RETURN NIL
//_____________________________________________________________________________//

FUNCTION ReBusca( oGrid, cChr, oCont, oParent )

   LOCAL nOrder    := RE->( ordNumber() )
   LOCAL nRecno    := RE->( RecNo() )
   LOCAL oDlg, oGet, cGet, cPicture
   LOCAL aSay1    := { " Introduzca el nombre de la receta",;
      " Introduzca el código de la receta",;
      " Introduzca el tipo de plato", ;
      " Introduzca el tipo de cocinado", ;
      " Introduzca la clasificación francesa", ;
      " Introduzca el ingrediente principal", ;
      " Introduzca el autor de la receta", ;
      " Introduzca la publicación de la receta", ;
      " Introduzca la valoración de la receta", ;
      " Introduzca la referencia de la receta", ;
      " Introduzca la fecha de preparación de la receta", ;
      " Introduzca el nombre de la receta" }
   LOCAL aSay2    := { "Receta:",;
      "Código:",;
      "Tipo de plato:",;
      "Tipo de cocinado:",;
      "C. Francesa:",;
      "Ingrediente principal:",;
      "Autor de la receta:",;
      "Publicación:",;
      "Valoración:",;
      "Referencia:",;
      "Fecha de preparación:", ;
      "Receta:"             }
   LOCAL aGet     := { Space( 60 ),;
      Space( 10 ),;
      Space( 30 ),;
      Space( 30 ),;
      Space( 30 ),;
      Space( 20 ),;
      Space( 50 ),;
      Space( 50 ),;
      Space( 20 ),;
      Space( 20 ),;
      CToD( '  -  -  ' ), ;
      Space( 60 ) }
   LOCAL lSeek    := .F.
   LOCAL lFecha   := .F.
   LOCAL aBrowse  := {}

   oApp():nEdit++

   DEFINE DIALOG oDlg RESOURCE 'UT_BUSCA_' + oApp():cLanguage ;
      TITLE i18n( "Búsqueda de recetas" ) OF oParent
   oDlg:SetFont( oApp():oFont )

   REDEFINE SAY PROMPT aSay1[ nOrder ] ID 20 OF oDlg
   REDEFINE SAY PROMPT aSay2[ nOrder ] ID 21 OF Odlg

   cGet  := aGet[ nOrder ]
   IF nOrder == 3
      RE->( dbSetOrder( 13 ) )
   ELSEIF nOrder == 9
      RE->( dbSetOrder( 14 ) )
   ELSEIF nOrder == 11
      lFecha := .T.
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
      ON INIT ( DlgCenter( oDlg,oApp():oWndMain ) )// , Iif(cChr!=nil,oGet:SetPos(2),), oGet:Refresh() )

   IF lSeek
      IF ! lFecha
         cGet := RTrim( Upper( cGet ) )
      ELSE
         cGet := DToS( cGet )
      ENDIF
      MsgRun( 'Realizando la búsqueda...', oApp():cAppName + oApp():cVersion, ;
         {|| ReWildSeek( nOrder, RTrim( Upper(cGet ) ), aBrowse ) } )
      IF Len( aBrowse ) == 0
         MsgStop( "No se ha encontrado ninguna receta.", 'Atención' )
      ELSE
         ReEncontrados( aBrowse, oApp():oDlg )
      ENDIF
   ENDIF

   IF nOrder == 3
      RE->( dbSetOrder( 3 ) )
   ELSEIF nOrder == 8
      RE->( dbSetOrder( 8 ) )
   ENDIF
   IF oCont != NIL
      RefreshCont( oCont, "RE" )
   ENDIF
   oGrid:Refresh()
   oGrid:SetFocus( .T. )
   RefreshReBarImage()
   oApp():nEdit--

RETURN NIL

/*_____________________________________________________________________________*/
FUNCTION ReWildSeek( nOrder, cGet, aBrowse )

   LOCAL nRecno   := RE->( RecNo() )
   LOCAL aTPlato  := { 'Entradas', '1er Plato', '2o Plato', 'Postre', 'Dulce', 'Otro' }

   DO CASE
   CASE nOrder == 1
      RE->( dbGoTop() )
      DO WHILE ! RE->( Eof() )
         IF cGet $ Upper( RE->ReTitulo )
            AAdd( aBrowse, { RE->ReTitulo, RE->ReCodigo, aTPlato[ Max( Val(RE->RePlato ),1 ) ], RE->ReTipo, RE->( RecNo() ) } )
         ENDIF
         RE->( dbSkip() )
      ENDDO
   CASE nOrder == 2
      RE->( dbGoTop() )
      DO WHILE ! RE->( Eof() )
         IF cGet $ Upper( RE->ReCodigo )
            AAdd( aBrowse, { RE->ReTitulo, RE->ReCodigo, aTPlato[ Max( Val(RE->RePlato ),1 ) ], RE->ReTipo, RE->( RecNo() ) } )
         ENDIF
         RE->( dbSkip() )
      ENDDO
   CASE nOrder == 3
      RE->( dbGoTop() )
      DO WHILE ! RE->( Eof() )
         IF cGet $ Upper( RE->ReTipo )
            AAdd( aBrowse, { RE->ReTitulo, RE->ReCodigo, aTPlato[ Max( Val(RE->RePlato ),1 ) ], RE->ReTipo, RE->( RecNo() ) } )
         ENDIF
         RE->( dbSkip() )
      ENDDO
   CASE nOrder == 4
      RE->( dbGoTop() )
      DO WHILE ! RE->( Eof() )
         IF cGet $ Upper( RE->ReTipoCoc )
            AAdd( aBrowse, { RE->ReTitulo, RE->ReCodigo, aTPlato[ Max( Val(RE->RePlato ),1 ) ], RE->ReTipo, RE->( RecNo() ) } )
         ENDIF
         RE->( dbSkip() )
      ENDDO
   CASE nOrder == 5
      RE->( dbGoTop() )
      DO WHILE ! RE->( Eof() )
         IF cGet $ Upper( RE->ReFrTipo )
            AAdd( aBrowse, { RE->ReTitulo, RE->ReCodigo, aTPlato[ Max( Val(RE->RePlato ),1 ) ], RE->ReTipo, RE->( RecNo() ) } )
         ENDIF
         RE->( dbSkip() )
      ENDDO
   CASE nOrder == 6
      RE->( dbGoTop() )
      DO WHILE ! RE->( Eof() )
         IF cGet $ Upper( RE->ReIngPri )
            AAdd( aBrowse, { RE->ReTitulo, RE->ReCodigo, aTPlato[ Max( Val(RE->RePlato ),1 ) ], RE->ReTipo, RE->( RecNo() ) } )
         ENDIF
         RE->( dbSkip() )
      ENDDO
   CASE nOrder == 7
      RE->( dbGoTop() )
      DO WHILE ! RE->( Eof() )
         IF cGet $ Upper( RE->ReAutor )
            AAdd( aBrowse, { RE->ReTitulo, RE->ReCodigo, aTPlato[ Max( Val(RE->RePlato ),1 ) ], RE->ReTipo, RE->( RecNo() ) } )
         ENDIF
         RE->( dbSkip() )
      ENDDO
   CASE nOrder == 8
      RE->( dbGoTop() )
      DO WHILE ! RE->( Eof() )
         IF cGet $ Upper( RE->RePublica )
            AAdd( aBrowse, { RE->ReTitulo, RE->ReCodigo, aTPlato[ Max( Val(RE->RePlato ),1 ) ], RE->ReTipo, RE->( RecNo() ) } )
         ENDIF
         RE->( dbSkip() )
      ENDDO
   CASE nOrder == 9
      RE->( dbGoTop() )
      DO WHILE ! RE->( Eof() )
         IF cGet $ Upper( RE->ReValorac )
            AAdd( aBrowse, { RE->ReTitulo, RE->ReCodigo, aTPlato[ Max( Val(RE->RePlato ),1 ) ], RE->ReTipo, RE->( RecNo() ) } )
         ENDIF
         RE->( dbSkip() )
      ENDDO
   CASE nOrder == 10
      RE->( dbGoTop() )
      DO WHILE ! RE->( Eof() )
         IF cGet $ Upper( RE->ReReferen )
            AAdd( aBrowse, { RE->ReTitulo, RE->ReCodigo, aTPlato[ Max( Val(RE->RePlato ),1 ) ], RE->ReTipo, RE->( RecNo() ) } )
         ENDIF
         RE->( dbSkip() )
      ENDDO
   CASE nOrder == 11
      RE->( dbGoTop() )
      DO WHILE ! RE->( Eof() )
         IF cGet ==  DToS( RE->ReFchPrep )
            AAdd( aBrowse, { RE->ReTitulo, RE->ReCodigo, aTPlato[ Max( Val(RE->RePlato ),1 ) ], RE->ReTipo, RE->( RecNo() ) } )
         ENDIF
         RE->( dbSkip() )
      ENDDO
   CASE nOrder == 12
      RE->( dbGoTop() )
      DO WHILE ! RE->( Eof() )
         IF cGet $ Upper( RE->ReTitulo )
            AAdd( aBrowse, { RE->ReTitulo, RE->ReCodigo, aTPlato[ Max( Val(RE->RePlato ),1 ) ], RE->ReTipo, RE->( RecNo() ) } )
         ENDIF
         RE->( dbSkip() )
      ENDDO
   END CASE
   RE->( dbGoto( nRecno ) )
   // ordeno la tabla por el 1 elemento
   ASort( aBrowse,,, {|aAut1, aAut2| Upper( aAut1[ 1 ] ) < Upper( aAut2[ 1 ] ) } )

RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION ReEncontrados( aBrowse, oParent )

   LOCAL oDlg, oBrowse, oBtnOk, oBtnCancel, lOk
   LOCAL nRecno := RE->( RecNo() )

   DEFINE DIALOG oDlg RESOURCE "DLG_ENCONTRADOS" ;
      TITLE i18n( "Resultado de la búsqueda" ) ;
      OF oParent
   oDlg:SetFont( oApp():oFont )

   oBrowse := TXBrowse():New( oDlg )
   Ut_BrwRowConfig( oBrowse )

   oBrowse:SetArray( aBrowse, .F. )
   oBrowse:aCols[ 1 ]:cHeader := "Receta"
   oBrowse:aCols[ 2 ]:cHeader := "Código"
   oBrowse:aCols[ 3 ]:cHeader := "Categoria"
   oBrowse:aCols[ 4 ]:cHeader := "Tipo plato"
   oBrowse:aCols[ 1 ]:nWidth  := 240
   oBrowse:aCols[ 2 ]:nWidth  := 90
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

   RE->( dbGoto( aBrowse[ oBrowse:nArrayAt, 5 ] ) )
   AEval( oBrowse:aCols, {|oCol| oCol:bLDClickData := {|| RE->( dbGoto(aBrowse[ oBrowse:nArrayAt, 5 ] ) ), ;
      ReEdita( , 2,, oApp():oDlg ) } } )
   oBrowse:bKeyDown  := {| nKey| iif( nKey == VK_RETURN, ( RE->(dbGoto(aBrowse[ oBrowse:nArrayAt, 5 ] ) ),;
      ReEdita( , 2,, oApp():oDlg ) ), ) }
   oBrowse:bChange    := {|| RE->( dbGoto( aBrowse[ oBrowse:nArrayAt, 5 ] ) ) }
   oBrowse:lHScroll  := .F.
   oDlg:oClient      := oBrowse
   oBrowse:nRowHeight := 20

   REDEFINE BUTTON oBtnOk ;
      ID IDOK OF oDlg     ;
      ACTION oDlg:End()

   REDEFINE BUTTON oBtnCancel ;
      ID IDCANCEL OF oDlg ;
      ACTION ( RE->( dbGoto(nRecno ) ), oDlg:End() )

   ACTIVATE DIALOG oDlg ;
      ON INIT DlgCenter( oDlg, oApp():oWndMain )

RETURN NIL

/*_____________________________________________________________________________*/

FUNCTION ReSelecc1( oGrid )

   IF RE->ReSelecc == SELECCIONADA
      MsgStop( 'La receta ya está seleccionada.', 'Atención' )
   ELSE
      REPLACE RE->ReSelecc WITH SELECCIONADA
      RE->( dbCommit() )
      // MsgInfo('Receta seleccionada.')
   ENDIF

   oGrid:Refresh()
   oGrid:SetFocus( .T. )

RETURN NIL
/*_____________________________________________________________________________
/*_____________________________________________________________________________*/

FUNCTION ReAsisSelecc( oGrid, oCont, oParent, oReMenu, oBar1, oVMitem, oMItem )

   LOCAL oDlg, aGet[ 40 ]
   LOCAL nReRecno    := RE->( RecNo() )
   LOCAL nReOrder    := RE->( ordNumber() )
   LOCAL cBusca := Space( 80 )
   LOCAL nTipoB := 3
   LOCAL lTitulo := .F.
   LOCAL lIngred := .F.
   LOCAL lPrepar := .F.
   LOCAL lEscand := .F.
   LOCAL lCPlato := .T.
   LOCAL aCPlato := { 'Entradas', '1er Plato', '2o Plato', 'Postre', 'Dulce' }
   LOCAL cCPlato := ''
   LOCAL lTPlato := .T.
   LOCAL aTPlato := {}
   LOCAL cTPlato := ''
   LOCAL lTCocin := .T.
   LOCAL aTCocin := {}
   LOCAL cTCocin := ''
   LOCAL aDietas := {}
   LOCAL lAutor  := .T.
   LOCAL aAutor  := {}
   LOCAL cAutor  := ''
   LOCAL lPublic := .T.
   LOCAL aPublic := {}
   LOCAL cPublic := ''
   LOCAL dInicio := CToD( '' )
   LOCAL dFinal  := CToD( '' )
   LOCAL nRTodas := 1
   LOCAL oDlgProgress, oBmp, oSay01, oSay02, oProgress
   LOCAL nProgress   := 0
   LOCAL nSelecc := 0

   oApp():nEdit++
   // cargo los tipos de plato para entradas
   SELECT PL
   PL->( dbSetOrder( 2 ) )
   PL->( dbGoTop() )
   WHILE ! PL->( Eof() )
      AAdd( aTPlato, PL->PlTipo )
      PL->( dbSkip() )
   ENDDO
   cTPlato := iif( Len( aTPlato ) > 0, aTPlato[ 1 ], ' ' )
   // cargo los tipos de cocinado
   SELECT PL
   PL->( dbSetOrder( 7 ) )
   PL->( dbGoTop() )
   WHILE ! PL->( Eof() )
      AAdd( aTCocin, PL->PlTipo )
      PL->( dbSkip() )
   ENDDO
   cTCocin := iif( Len( aTCocin ) > 0, aTCocin[ 1 ], ' ' )
   // cargo cocineros
   SELECT AU
   AU->( ordSetFocus( 1 ) )
   AU->( dbGoTop() )
   WHILE ! AU->( Eof() )
      AAdd( aAutor, AU->AuNombre )
      AU->( dbSkip() )
   END
   cAutor := iif( Len( aAutor ) > 0, aAutor[ 1 ], ' ' )
   // publicaciones de recetas
   SELECT PU
   PU->( ordSetFocus( 1 ) )
   PU->( dbGoTop() )
   WHILE ! PU->( Eof() )
      AAdd( aPublic, PU->PuNombre )
      PU->( dbSkip() )
   END
   cPublic := iif( Len( aPublic ) > 0, aPublic[ 1 ], ' ' )

   DEFINE DIALOG oDlg RESOURCE 'RE_ASIS_SELECC_' + oApp():cLanguage ;
      TITLE "Selección de recetas" OF oParent
   oDlg:SetFont( oApp():oFont )

   REDEFINE GET   aGet[ 1 ] VAR cBusca ID 101 OF oDlg PICTURE '@!'
   REDEFINE RADIO aGet[ 2 ] VAR nTipoB ID 102, 103, 104 OF oDlg ;
      ON CHANGE ReAsisChgTipoB( @cBusca, nTipoB, aGet )

   REDEFINE CHECKBOX aGet[ 3 ] VAR lTitulo ID 105 OF oDlg
   REDEFINE CHECKBOX aGet[ 4 ] VAR lIngred ID 106 OF oDlg
   REDEFINE CHECKBOX aGet[ 5 ] VAR lPrepar ID 107 OF oDlg
   REDEFINE CHECKBOX aGet[ 6 ] VAR lEscand ID 108 OF oDlg

   // categorias
   REDEFINE CHECKBOX aGet[ 7 ] VAR lCPlato ID 201 OF oDlg
   cCPlato := aCPlato[ 1 ]
   REDEFINE COMBOBOX aGet[ 8 ] VAR cCPlato ITEMS aCPlato ID 202 OF oDlg ;
      WHEN ! lCPlato
   aGet[ 8 ]:bChange := {|| ReAsisLoadaTPlato( aTPlato, cTPlato, cCPlato, aGet[ 10 ] ) }
   // tipos de plato
   REDEFINE CHECKBOX aGet[ 9 ]  VAR lTPlato ID 203 OF oDlg WHEN lCPlato == .F.
   REDEFINE COMBOBOX aGet[ 10 ] VAR cTPlato ITEMS aTPlato ID 204 OF oDlg ;
      WHEN ! lTPlato
   // tipos de cocinado
   REDEFINE CHECKBOX aGet[ 11 ] VAR lTCocin ID 205 OF oDlg
   REDEFINE COMBOBOX aGet[ 12 ] VAR cTCocin ITEMS aTCocin ID 206 OF oDlg ;
      WHEN ! lTCocin

   aGet[ 13 ] := TTagEver():Redefine( 207, oDlg, oApp():oFont, aDietas )
   REDEFINE BUTTON aGet[ 14 ] ID 208 OF oDlg UPDATE      ;
      ACTION DiSeleccion( @aDietas, aGet[ 13 ], oDlg )
   aGet[ 14 ]:cTooltip := i18n( "seleccionar dieta / tolerancia" )

   // autores de recetas
   REDEFINE CHECKBOX aGet[ 15 ] VAR lAutor ID 301 OF oDlg
   REDEFINE COMBOBOX aGet[ 16 ] VAR cAutor ITEMS aAutor ID 302 OF oDlg ;
      WHEN ! lAutor

   // publicaciones de recetas
   REDEFINE CHECKBOX aGet[ 17 ] VAR lPublic ID 303 OF oDlg
   REDEFINE COMBOBOX aGet[ 18 ] VAR cPublic ITEMS aPublic ID 304 OF oDlg ;
      WHEN ! lPublic

   // fecha de publicación
   REDEFINE GET aGet[ 19 ] VAR dInicio ID 305 OF oDlg UPDATE
   REDEFINE BUTTON aGet[ 20 ] ID 306 OF oDlg UPDATE;
      ACTION SelecFecha( dInicio, aGet[ 19 ] )
   aGet[ 20 ]:cTooltip := i18n( "seleccionar fecha" )

   REDEFINE GET aGet[ 21 ] VAR dFinal ID 307 OF oDlg UPDATE
   REDEFINE BUTTON aGet[ 22 ] ID 308 OF oDlg UPDATE;
      ACTION SelecFecha( dFinal, aGet[ 21 ] )
   aGet[ 22 ]:cTooltip := i18n( "seleccionar fecha" )

   REDEFINE RADIO aGet[ 23 ] VAR nRTodas ID 310, 311, 312 OF oDlg

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
      IF MsgYesNo( "¿ Desea deseleccionar las recetas que tiene actualmente seleccionadas ?", 'Seleccione una opción' )
         ReDeSelAll( oGrid, oDlg )
      ENDIF

      DEFINE DIALOG oDlgProgress RESOURCE 'UT_INDEXAR_' + oApp():cLanguage OF oParent
      oDlg:SetFont( oApp():oFont )

      REDEFINE BITMAP oBmp ID 111 OF oDlgProgress RESOURCE 'BB_RECETAS' TRANSPARENT
      REDEFINE SAY oSay01 PROMPT "Revisando recetas..." ID 99  OF oDlgProgress
      REDEFINE SAY oSay02 PROMPT Space( 30 ) ID 10  OF oDlgProgress
      oProgress := TProgress():Redefine( 101, oDlgProgress )

      oDlgProgress:bStart := {|| SysRefresh(),;
         ReAsisMeter( oProgress, nProgress, cBusca, nTipoB, ;
         lTitulo, lIngred, lPrepar, lEscand, ;
         lCPlato, cCPlato, lTPlato, cTPlato, lTCocin, cTCocin, ;
         aDietas, lAutor, cAutor, lPublic, cPublic, ;
         dInicio, dFinal, nRTodas, oSay02, @nSelecc ),;
         oDlgProgress:End() }
      ACTIVATE DIALOG oDlgProgress ;
         ON INIT DlgCenter( oDlgProgress, oApp():oWndMain )

      IF MsgYesNo( "Se han seleccionado " + TRAN( nSelecc,"@E999,999" ) + " recetas." + CRLF + ;
            "¿ Desea filtrar las recetas seleccionadas ?", 'Atención !' )
         ReFilter( 9, oCont, oReMenu, oBar1, oVMitem, oMItem )
      ELSE
         SELECT RE
         RE->( dbSetOrder( nReOrder ) )
         RE->( dbGoto( nReRecno ) )
      ENDIF
   ENDIF
   RefreshCont( oCont, "RE" )
   oGrid:Refresh( .T. )
   oGrid:SetFocus( .T. )
   RefreshReBarImage()
   oApp():nEdit--

RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION ReAsisChgTipoB( cBusca, nTipoB, aGet )

   cBusca := StrTran( cBusca, "<", "" )
   cBusca := StrTran( cBusca, ">", "" )
   cBusca := StrTran( cBusca, "+", "" )
   DO WHILE At( '  ', cBusca ) != 0
      cBusca := StrTran( cBusca, "  ", " " )
   ENDDO
   DO CASE
   CASE nTipoB == 1
      cBusca := "<" + RTrim( cBusca ) + ">" + Space( 20 )
   CASE nTipoB == 2
      cBusca := '+' + RTrim( cBusca )
      cBusca := StrTran( cBusca, ' ', ' +' ) + Space( 20 )
   CASE nTipoB == 3
      // no hago nada xq he limpiado la cadena
   ENDCASE
   aGet[ 1 ]:Refresh()
   // aGet[1]:SetFocus()

RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION ReAsisLoadaTPlato( aTPlato, cTPlato, cCPlato, oCombo )

   LOCAL nPlOrder := AScan( { 'Entradas', '1er Plato', '2o Plato', 'Postre', 'Dulce' }, cCPlato )

   SELECT PL
   PL->( dbSetOrder( nPlOrder + 1 ) )
   PL->( dbGoTop() )
   ASize( aTPlato, 0 )
   WHILE ! PL->( Eof() )
      AAdd( aTPlato, PL->PlTipo )
      PL->( dbSkip() )
   ENDDO
   oCombo:SetItems( aTPlato, .T. )
   oCombo:Select( 1 )
   oCombo:Refresh()

RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION ReAsisMeter( oProgress, nProgress, cBusca, nTipoB, lTitulo, lIngred, lPrepar, lEscand, ;
      lCPlato, cCPlato, lTPlato, cTPlato, lTCocin, cTCocin, aDietas, lAutor, cAutor, ;
      lPublic, cPublic, dInicio, dFinal, nRTodas, oSay02, nSelecc )

   LOCAL aItems    := {}
   LOCAL nItems, i, nRat, nInicio, nCaract, cTira
   LOCAL lSelected := .F.
   LOCAL cxBusca   := StrTran( Upper( RTrim(cBusca ) ), Space( 2 ), Space( 1 ) )
   LOCAL aCPlato   := { 'Entradas', '1er Plato', '2o Plato', 'Postre', 'Dulce' }
   LOCAL nSDietas  := 0

   CursorWait()
   IF nTipoB == 3
      IF SubStr( cxBusca, 1, 1 ) == '<' // .and. nTipoB == 3
         nTipoB := 1
      ELSEIF SubStr( cxBusca, 1, 1 ) == '+'
         nTipoB := 2
      ENDIF
   ENDIF
   DO CASE
   CASE nTipoB == 1
      // como literal. 1! item
      AAdd( aItems, RTrim( Upper(StrTran(StrTran(cxBusca,">","" ),"<","" ) ) ) )
   CASE nTipoB == 2
      // conjunción. tantos items como +
      nItems := FT_NOOCCUR( '+', cxBusca, .T. )
      FOR i := 1 TO nItems
         AAdd( aItems, RTrim( Right(cxBusca,Len(cxBusca ) -RAt('+',cxBusca ) ) ) )
         IF i < nItems
            nRAT := RAt( '+', cxBusca )
            cxBusca := SubStr( cxBusca, 1, nRAT - 1 )
         ENDIF
      NEXT
   CASE nTipoB == 3
      // varios items y tengo que buscar al menos uno de ellos
      cxBusca := RTrim( Upper( cxBusca ) ) + ' '
      nItems := FT_NOOCCUR( ' ', cxBusca, .T. )
      FOR i := 1 TO nItems
         AAdd( aItems, RTrim( SubStr(cxBusca,1,At(' ',cxBusca ) ) ) )
         IF i < nItems
            nInicio := At( ' ', cxBusca ) + 1
            nCaract := Len( cxBusca ) -nInicio + 1
            cxBusca := SubStr( cxBusca, nInicio, nCaract )
         ENDIF
      NEXT
   ENDCASE

   SELECT RE
   RE->( dbSetOrder( 1 ) )
   oProgress:SetRange( 0, RE->( LastRec() ) )
   RE->( dbGoTop() )
   DO WHILE ! RE->( Eof() )
      oSay02:SetText( Upper( RE->ReTitulo ) )
      lSelected := ( RE->ReSelecc == SELECCIONADA )
      REPLACE RE->ReSelecc WITH NOSELECCIONADA
      IF ! Empty( cBusca )
         DO CASE
         CASE nTipoB == 1 .OR. nTipoB == 3
            IF lTitulo
               cTira := ' ' + Upper( RE->ReTitulo )
               FOR i := 1 TO Len( aItems )
                  IF At( aItems[ i ], cTira ) != 0
                     REPLACE RE->ReSelecc WITH SELECCIONADA
                     RE->( dbCommit() )
                  ENDIF
               NEXT
            ENDIF
            IF lIngred
               cTira := ' ' + Upper( RE->REIngred )
               FOR i := 1 TO Len( aItems )
                  IF At( aItems[ i ], cTira ) != 0
                     REPLACE RE->ReSelecc WITH SELECCIONADA
                     RE->( dbCommit() )
                  ENDIF
               NEXT
            ENDIF
            IF lPrepar
               cTira := ' ' + Upper( RE->REPrepar )
               FOR i := 1 TO Len( aItems )
                  IF At( aItems[ i ], cTira ) != 0
                     REPLACE RE->ReSelecc WITH SELECCIONADA
                     RE->( dbCommit() )
                  ENDIF
               NEXT
            ENDIF
            IF lEscand
               FOR i := 1 TO Len( aItems )
                  IF ES->( dbSeek( RE->ReCodigo ) )
                     DO WHILE RE->ReCodigo == ES->EsReceta .AND. ! ES->( Eof() )
                        IF At( aItems[ i ], ES->EsInDenomi ) != 0
                           REPLACE RE->ReSelecc WITH SELECCIONADA
                           RE->( dbCommit() )
                        ENDIF
                        ES->( dbSkip() )
                     ENDDO
                  ENDIF
               NEXT
            ENDIF
         CASE nTipoB == 2
            REPLACE RE->ReSelecc WITH SELECCIONADA
            cTira := ''
            IF lTitulo
               cTira := cTira + ' ' + Upper( RE->ReTitulo )
            ENDIF
            IF lIngred
               cTira := cTira + ' ' + Upper( RE->ReIngred )
            ENDIF
            IF lPrepar
               cTira := cTira + ' ' + Upper( RE->RePrepar )
            ENDIF
            IF lEscand
               IF ES->( dbSeek( RE->ReCodigo ) )
                  DO WHILE RE->ReCodigo == ES->EsReceta .AND. ! ES->( Eof() )
                     cTira := cTira + ' ' + ES->EsInDenomi
                     ES->( dbSkip() )
                  ENDDO
               ENDIF
            ENDIF
            FOR i := 1 TO Len( aItems )
               IF At( aItems[ i ], cTira ) == 0
                  REPLACE RE->ReSelecc WITH NOSELECCIONADA
                  RE->( dbCommit() )
               ENDIF
            NEXT
         ENDCASE
      ELSE
         REPLACE RE->ReSelecc WITH SELECCIONADA
      ENDIF

      IF ! lCPlato
         IF Val( RE->RePlato ) == AScan( aCPlato, cCPlato )
            // Replace AR->ARSelect with SELECCIONADA
         ELSE
            REPLACE RE->ReSelecc WITH NOSELECCIONADA
         ENDIF
      ENDIF
      IF ! lTPlato
         IF Upper( RTrim( RE->ReTipo ) ) == Upper( RTrim( cTPlato ) )
            // Replace AR->ARSelect with SELECCIONADA
         ELSE
            REPLACE RE->ReSelecc WITH NOSELECCIONADA
         ENDIF
      ENDIF
      IF ! lTCocin
         IF Upper( RTrim( cTCocin ) ) == Upper( RTrim( RE->ReTipoCoc ) )
            // Replace AR->ARSelect with SELECCIONADA
         ELSE
            REPLACE RE->ReSelecc WITH NOSELECCIONADA
         ENDIF
      ENDIF
      IF Len( aDietas ) > 0
         nSDietas := 0
         FOR i := 1 TO Len( aDietas )
            IF At( Upper( RTrim(aDietas[ i ] ) ), Upper( RTrim(RE->ReDietas ) ) ) != 0
               nSDietas := nSDietas + 1
            ENDIF
         NEXT
         IF nSDietas != Len( aDietas )
            REPLACE RE->ReSelecc WITH NOSELECCIONADA
         ENDIF
      ENDIF
      IF ! lAutor
         IF Upper( RTrim( cAutor ) ) == Upper( RTrim( RE->ReAutor ) )
            // Replace AR->ARSelect with SELECCIONADA
         ELSE
            REPLACE RE->ReSelecc WITH NOSELECCIONADA
         ENDIF
      ENDIF
      IF ! lPublic
         IF Upper( RTrim( cPublic ) ) == Upper( RTrim( RE->RePublica ) )
            // Replace AR->ARSelect with SELECCIONADA
         ELSE
            REPLACE RE->ReSelecc WITH NOSELECCIONADA
         ENDIF
      ENDIF
      IF nRTodas == 2
         IF RE->ReIncorp != 1
            REPLACE RE->ReSelecc WITH NOSELECCIONADA
         ENDIF
      ELSEIF nRTodas == 3
         IF RE->ReIncorp != 2
            REPLACE RE->ReSelecc WITH NOSELECCIONADA
         ENDIF
      ENDIF
      IF dInicio != CToD( '' ) // tengo fechas de incorporación
         IF ! ( dInicio < RE->ReFchInco .AND. RE->ReFchInco < dFinal )
            REPLACE RE->ReSelecc WITH NOSELECCIONADA
         ENDIF
      ENDIF
      IF RE->ReSelecc == SELECCIONADA
         nSelecc++
      ENDIF
      IF lSelected
         REPLACE RE->ReSelecc WITH SELECCIONADA
      ENDIF
      oProgress:SetPos( nProgress++ )
      RE->( dbSkip() )
   ENDDO
   CursorArrow()
   RefreshReBarImage()

RETURN NIL
/*_____________________________________________________________________________

function ReSelecc3( oProgress, nProgress, cBusca, nTBusca,  cPlato, cAutor, cPublic, cTipoCoc,  ;
                    lCheck01, lCheck02, lCheck03, lCheck04, dInicio, dFinal, nRadio, oSay02 )

   local aItems      := {}
   local nItems, i, nRat, nInicio, nCaract, cTira
   local lSelected   := .f.
   local cxBusca     := STRTRAN(UPPER(Rtrim(cBusca)),SPACE(2),SPACE(1))
   local nSelecc     := 0
 local aTiPlatos   := {'En','1P','2P','Po','Du','Co'}

   CursorWait()
   if nTBusca == 3
      if Substr(cxBusca,1,1) == '<' // .and. nTBusca == 3
         nTBusca := 1
      elseif SubStr(cxBusca,1,1) == '+'
         nTBusca := 2
      endif
   endif
   DO CASE
      CASE nTBusca == 1
         // como literal. 1! item
         AADD(aItems, Rtrim(UPPER(strtran(strtran(cxBusca,">",""),"<",""))))
      CASE nTBusca == 2
         // conjunción. tantos items como +
         nItems := FT_NOOCCUR('+',cxBusca,.t.)
         FOR i := 1 TO nItems
            AADD(aItems, Rtrim(Right(cxBusca,LEN(cxBusca)-RAT('+',cxBusca))))
            if i < nItems
               nRAT := RAT('+',cxBusca)
               cxBusca := SubStr(cxBusca,1,nRAT-1)
            endif
         NEXT
      CASE nTBusca == 3
         // varios items y tengo que buscar al menos uno de ellos
         cxBusca := Rtrim(UPPER(cxBusca)) + ' '
         nItems := FT_NOOCCUR(' ',cxBusca,.t.)
         FOR i := 1 TO nItems
            AADD(aItems,Rtrim(SubStr(cxBusca,1,AT(' ',cxBusca))))
            if i < nItems
               nInicio := AT(' ',cxBusca)+1
               nCaract := LEN(cxBusca)-nInicio+1
               cxBusca := SubStr(cxBusca,nInicio,nCaract)
            endif
         NEXT
   ENDCASE


   SELECT RE
   RE->(DbSetOrder(1))
   oProgress:SetRange(0,RE->(LastRec()))

   RE->(DbGoTop())
   Do While ! RE->(EoF())
      // oSay02:SetText(RE->ReTitulo)
      oSay02:SetText(UPPER(RE->ReTitulo))
      lSelected := ( RE->ReSelecc == SELECCIONADA )
      REPLACE RE->ReSelecc WITH NOSELECCIONADA
      if ! empty(cBusca)
         DO CASE
            CASE nTBusca == 1 .OR. nTBusca == 3
               if lCheck01
                  cTira := ' '+UPPER(RE->ReTitulo)
                  FOR i := 1 to LEN(aItems)
                     if AT(aItems[i],cTira) != 0
                        Replace RE->ReSelecc with SELECCIONADA
                        RE->(DbCommit())
                     endif
                  NEXT
               endif
               if lCheck02
                  cTira := ' '+UPPER(RE->REIngred)
                  FOR i := 1 to LEN(aItems)
                     if AT(aItems[i],cTira) != 0
                        Replace RE->ReSelecc with SELECCIONADA
                        RE->(DbCommit())
                     endif
                  NEXT
               endif
               if lCheck03
                  cTira := ' '+UPPER(RE->REPrepar)
                  FOR i := 1 to LEN(aItems)
                     if AT(aItems[i],cTira) != 0
                        Replace RE->ReSelecc with SELECCIONADA
                        RE->(DbCommit())
                     endif
                  NEXT
               endif
               if lCheck04
                  FOR i := 1 to LEN(aItems)
                     if ES->(DbSeek(RE->ReCodigo))
                        DO WHILE RE->ReCodigo == ES->EsReceta .AND. ! ES->(EOF())
                           if AT(aItems[i],ES->EsInDenomi) != 0
                              Replace RE->ReSelecc with SELECCIONADA
                              RE->(DbCommit())
                           endif
                           ES->(DbSkip())
                        ENDDO
                     endif
                  NEXT
               endif
            CASE nTBusca == 2
               Replace RE->ReSelecc with SELECCIONADA
               cTira := ''
               if lCheck01
                  cTira := cTira+' '+UPPER(RE->ReTitulo)
               endif
               if lCheck02
                  cTira := cTira+' '+UPPER(RE->ReIngred)
               endif
               if lCheck03
                  cTira := cTira+' '+UPPER(RE->RePrepar)
               endif
               if lCheck04
                  if ES->(DbSeek(RE->ReCodigo))
                     DO WHILE RE->ReCodigo == ES->EsReceta .AND. ! ES->(EOF())
                        cTira := cTira+' '+ES->EsInDenomi
                        ES->(DbSkip())
                     ENDDO
                  endif
               endif
               // MsgInfo(cTira)
               FOR i := 1 to LEN(aItems)
                  if AT(aItems[i],cTira)== 0
                     Replace RE->ReSelecc with NOSELECCIONADA
                     RE->(DbCommit())
                  endif
               NEXT
         ENDCASE
      else
         Replace RE->ReSelecc with SELECCIONADA
      endif

      if Rtrim(cPlato) != ' TODOS LOS PLATOS'
         if Rtrim(RE->ReTipo) == Rtrim(SubStr(cPlato,4)) .and. aTiPlatos[Val(RE->RePlato)] == SubStr(cPlato,1,2)
            // Replace AR->ARSelect with SELECCIONADA
         else
            Replace RE->ReSelecc with NOSELECCIONADA
         endif
      endif

      if Rtrim(cTipoCoc) != ' TODOS LOS COCINADOS'
         if Rtrim(RE->ReTipoCoc) == Rtrim(cTipoCoc)
            // Replace AR->ARSelect with SELECCIONADA
         else
            Replace RE->ReSelecc with NOSELECCIONADA
         endif
      endif

      if Rtrim(cAutor) != ' TODOS LOS AUTORES'
         if UPPER(Rtrim(RE->ReAutor)) == UPPER(Rtrim(cAutor))
            // Replace AR->ARSelect with SELECCIONADA
         else
            Replace RE->ReSelecc with NOSELECCIONADA
         endif
      endif
      if Rtrim(cPublic) != ' TODAS LAS PUBLICACIONES'
         if UPPER(Rtrim(RE->RePublica)) == UPPER(Rtrim(cPublic))
            // Replace AR->ARSelect with SELECCIONADA
         else
            Replace RE->ReSelecc with NOSELECCIONADA
         endif
      endif
      if nRadio == 2
         if RE->ReIncorp != 1
               Replace RE->ReSelecc with NOSELECCIONADA
         endif
      elseif nRadio == 3
         if RE->ReIncorp != 2
               Replace RE->ReSelecc with NOSELECCIONADA
         endif
      endif
      if dInicio != ctod('') // tengo fechas de incorporación
         if .NOT. ( dInicio < RE->ReFchInco .AND. RE->ReFchInco < dFinal )
            Replace RE->ReSelecc with NOSELECCIONADA
         endif
      endif
      if RE->ReSelecc == SELECCIONADA
         nSelecc ++
      endif
      if lSelected
         Replace RE->ReSelecc with SELECCIONADA
      endif
      oProgress:SetPos(nProgress++)
      RE->(DbSkip())
   Enddo
   CursorArrow()
 RefreshReBarImage()
   MsgInfo("Se han seleccionado "+TRAN(nSelecc,"@E999,999")+" recetas.")
return nil
_____________________________________________________________________________

function ReSelAsist( oControl, cBusca, nTipo, oParent )
   local oDlg, oGet, cGet, oRadio
   cBusca := cBusca + Space(30-LEN(cBusca))

   DEFINE DIALOG oDlg RESOURCE 'RE_SEL_2_'+oApp():cLanguage ;
      TITLE "Asistente de selección de recetas" OF oParent
 oDlg:SetFont(oApp():oFont)

   REDEFINE GET cBusca ID 101 ;
      PICTURE "@!" OF oDlg
   REDEFINE RADIO oRadio VAR nTipo ID 102, 103, 104 OF oDlg

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
      ON INIT DlgCenter(oDlg,oApp():oWndMain)

   if oDlg:nresult == IDOK
      // limpio la cadena
      cBusca := strtran(cBusca,"<","")
      cBusca := strtran(cBusca,">","")
      cBusca := strtran(cBusca,"+","")
      DO WHILE AT('  ',cBusca) != 0
         cBusca := StrTran(cBusca,"  "," ")
      ENDDO
      DO CASE
         CASE nTipo == 1
            cBusca := "<"+Rtrim(cBusca)+">"+Space(20)
         CASE nTipo == 2
            cBusca := '+'+Rtrim(cBusca)
            cBusca := strtran(cBusca,' ',' +')+Space(20)
         CASE nTipo == 3
      ENDCASE
   endif
   oControl:Refresh()
   oControl:SetFocus()
return nil

/*_____________________________________________________________________________*/
FUNCTION ReSelDuplic( oGrid, oCont, oParent )

   LOCAL oDlgProgress, oBmp, oSay01, oSay02, oProgress
   LOCAL nReRecno    := RE->( RecNo() )
   LOCAL nReOrder    := RE->( ordNumber() )

   oApp():nEdit++
   IF MsgYesNo( "¿ Desea deseleccionar las recetas que tiene actualmente seleccionadas ?", 'Seleccione una opción' )
      ReDeSelAll( oGrid, oParent )
   ENDIF

   DEFINE DIALOG oDlgProgress RESOURCE 'UT_INDEXAR_' + oApp():cLanguage OF oParent
   oDlgProgress:SetFont( oApp():oFont )

   REDEFINE BITMAP oBmp ID 111 OF oDlgProgress RESOURCE 'BB_RECETAS' TRANSPARENT
   REDEFINE SAY oSay01 PROMPT "Revisando recetas..." ID 99  OF oDlgProgress
   REDEFINE SAY oSay02 PROMPT Space( 30 ) ID 10  OF oDlgProgress
   oProgress := TProgress():Redefine( 101, oDlgProgress )

   oDlgProgress:bStart := {|| SysRefresh(),;
      ReSelDupMeter( oProgress, oSay02 ),;
      oDlgProgress:End() }

   ACTIVATE DIALOG oDlgProgress ;
      ON INIT DlgCenter( oDlgProgress, oApp():oWndMain )

   SELECT RE
   RE->( dbSetOrder( nReOrder ) )
   RE->( dbGoto( nReRecno ) )

   RefreshCont( oCont, "RE" )
   RefreshReBarImage()
   oGrid:Refresh( .T. )
   oGrid:SetFocus( .T. )
   oApp():nEdit--

RETURN NIL

FUNCTION ReSelDupMeter( oProgress, oSay02 )

   LOCAL xReCodigo
   LOCAL xReTitulo
   LOCAL nProgress := 1
   LOCAL nSelecc   := 0

   CursorWait()
   SELECT RE
   RE->( dbSetOrder( 1 ) )
   oProgress:SetRange( 0, RE->( LastRec() ) )
   RE->( dbGoTop() )
   xReCodigo := RE->ReCodigo
   xReTitulo := RE->ReTitulo
   RE->( dbSkip() )
   DO WHILE ! RE->( Eof() )
      oSay02:SetText( RE->ReTitulo )
      IF Upper( RTrim( xReCodigo ) ) == Upper( RTrim( RE->ReCodigo ) ) ;
            .AND. Upper( RTrim( xReTitulo ) ) == Upper( RTrim( RE->ReTitulo ) )
         REPLACE RE->ReSelecc WITH SELECCIONADA
         RE->( dbCommit() )
         nSelecc++
      ELSE
         xReCodigo := RE->ReCodigo
         xReTitulo := RE->ReTitulo
      ENDIF
      oProgress:SetPos( nProgress++ )
      RE->( dbSkip() )
   ENDDO
   CursorArrow()
   RefreshReBarImage()
   MsgInfo( "Se han seleccionado " + TRAN( nSelecc,"@E999,999" ) + " recetas duplicadas.", 'Información' )

RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION ReDeSel1( oGrid )

   LOCAL nNext
   LOCAL nRecord  := RE->( RecNo() )

   oApp():nEdit++

   IF RE->ReSelecc == NOSELECCIONADA
      MsgStop( 'La receta no está seleccionada.', 'Atención' )
   ELSE
      RE->( dbSkip() )
      nNext := RE->( RecNo() )
      RE->( dbGoto( nRecord ) )

      REPLACE RE->ReSelecc WITH NOSELECCIONADA
      RE->( dbCommit() )
      // MsgInfo('Receta deseleccionada.')

      RE->( dbGoto( nNext ) )
      IF RE->( Eof() ) .OR. nNext == nRecord
         RE->( dbGoBottom() )
      ENDIF
   ENDIF

   oGrid:Refresh()
   oGrid:SetFocus( .T. )
   RefreshReBarImage()
   oApp():nEdit--

RETURN NIL
/*_____________________________________________________________________________*/
FUNCTION ReDeSelAll( oGrid, oParent )

   LOCAL oDlgProgress, oBmp, oSay01, oSay02, oProgress
   LOCAL nProgress   := 0
   LOCAL nOrder      := RE->( ordNumber() )
   LOCAL nRecno      := RE->( RecNo() )

   oApp():nEdit++
   SELECT RE
   RE->( dbSetOrder( 0 ) )
   RE->( dbGoTop() )
   REPLACE ALL RE->ReSelecc WITH NOSELECCIONADA
   RE->( dbCommitAll() )
   RE->( dbSetOrder( nOrder ) )
   RE->( dbGoto( nRecno ) )
   RefreshReBarImage()
   oGrid:Refresh()
   oGrid:SetFocus( .T. )
   oApp():nEdit--

RETURN NIL

/*_____________________________________________________________________________*/

FUNCTION ReBorraSel( oGrid, oParent )

   LOCAL oDlgProgress, oBmp, oSay01, oSay02, oProgress
   LOCAL nProgress   := 0
   LOCAL nOrder   := RE->( ordNumber() )
   LOCAL nRecno   := RE->( RecNo() )

   IF ! msgYesNo( i18n( "¿ Está seguro de borrar las recetas seleccionadas ?",'Seleccione una opción' ) )
      oGrid:Refresh()
      oGrid:SetFocus( .T. )
      RETURN NIL
   ENDIF

   oApp():nEdit++

   DEFINE DIALOG oDlgProgress RESOURCE 'UT_INDEXAR_' + oApp():cLanguage OF oParent
   oDlgProgress:SetFont( oApp():oFont )

   REDEFINE BITMAP oBmp ID 111 OF oDlgProgress RESOURCE 'BB_RECETAS' TRANSPARENT
   REDEFINE SAY oSay01 PROMPT "Borrando recetas seleccionadas" ID 99  OF oDlgProgress
   REDEFINE SAY oSay02 PROMPT Space( 30 ) ID 10  OF oDlgProgress
   oProgress := TProgress():Redefine( 101, oDlgProgress )

   oDlgProgress:bStart := {|| SysRefresh(),;
      ReBorraSel3( oProgress, nProgress, oSay02 ), ;
      oDlgProgress:End() }

   ACTIVATE DIALOG oDlgProgress ;
      ON INIT DlgCenter( oDlgProgress, oApp():oWndMain )

   RE->( dbCommitAll() )
   RE->( dbSetOrder( nOrder ) )
   RE->( dbGoto( nRecno ) )
   RefreshReBarImage()
   oGrid:Refresh()
   oGrid:SetFocus( .T. )

   oApp():nEdit--

RETURN NIL

FUNCTION ReBorraSel3( oProgress, nProgress, oSay )

   CursorWait()
   SELECT RE
   RE->( dbSetOrder( 0 ) )
   RE->( dbGoTop() )
   oProgress:SetRange( 0, RE->( LastRec() ) )
   oProgress:SetPos( nProgress )
   ES->( dbSetOrder( 1 ) )
   PL->( dbSetOrder( 1 ) )
   VA->( dbSetOrder( 1 ) )

   DO WHILE ! RE->( Eof() )
      IF RE->ReSelecc == SELECCIONADA
         oSay:SetText( RE->ReTitulo )
         /* ___ Borro el escandallo ______________________________________________*/
         SELECT ES
         ES->( dbSeek( RE->ReCodigo ) )
         DO WHILE ES->EsReceta == RE->ReCodigo .AND. ! ES->( Eof() )
            ES->( dbDelete() )
            ES->( dbSkip() )
         ENDDO
         /* ___ Quito 1 al tipo de plato _________________________________________*/
         SELECT PL
         PL->( dbSeek( RE->RePlato + RE->ReTipo ) )
         REPLACE PL->PlRecetas WITH PL->PlRecetas - 1
         PL->( dbSeek( '6' + RE->ReTipoCoc ) )
         REPLACE PL->PlRecetas WITH PL->PlRecetas - 1

         /* ___ computo la valoración ____________________________________________*/
         SELECT VA
         VA->( dbSeek( RE->ReVaOrden ) )
         REPLACE VA->VaRecetas WITH VA->VaRecetas - 1

         SELECT RE
         RE->( dbDelete() )
         REPLACE RE->ReSelecc WITH NOSELECCIONADA
      ENDIF
      oProgress:SetPos( nProgress++ )
      RE->( dbSkip() )
   ENDDO
   ES->( dbCommitAll() )
   ES->( Db_Pack() )
   PL->( dbCommitAll() )
   VA->( dbCommitAll() )
   RE->( dbCommitAll() )
   RE->( DbPack() )
   CursorArrow()

RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION ReExport( oGrid, oParent )

   LOCAL oDlg, oSay0, oSay1, oSay2, oSay3
   LOCAL oGetDes, oGetArc
   LOCAL cDescri  := Space( 40 )
   LOCAL cArchiv  := Space( 40 )
   LOCAL oDlg2, oBmp, oSay01, oSay02, oProgress
   LOCAL nProgress := 1
   LOCAL nOrder   := RE->( ordNumber() )
   LOCAL nRecno   := RE->( RecNo() )

   IF ! Db_OpenNoIndex( "INTERMED", "MD" )
      RETURN NIL
   ENDIF

   oApp():nEdit++

   SELECT RE
   DEFINE DIALOG oDlg RESOURCE 'RE_SEL_3_' + oApp():cLanguage TITLE "Exportar recetas de cocina" OF oParent
   oDlg:SetFont( oApp():oFont )

   REDEFINE SAY oSay0 ;
      PROMPT "Indique un nombre de fichero de sin extensión para almacenar las recetas seleccionadas." + CRLF + ;
      "El fichero se creará en la carpeta de archivos PCH definido en la configuración del programa y tendrá extensión .PCH" ;
      ID 100 OF oDlg COLOR CLR_BLACK, CLR_WHITE
   REDEFINE SAY oSay1 ID 101 OF oDlg
   REDEFINE SAY oSay2 ID 102 OF oDlg
   REDEFINE SAY oSay3 ID 103 OF oDlg
   REDEFINE GET oGetDes VAR cDescri ID 201 OF ODlg
   REDEFINE GET oGetArc VAR cArchiv ID 202 OF ODlg ;
      VALID iif( Empty( RTrim(cArchiv ) ), MsgStop( 'Es obligatorio introducir un nombre para el archivo.','Atención' ), .T. )

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
      DEFINE DIALOG oDlg2 RESOURCE 'UT_PROGRESS' ;
         TITLE i18n( "Un momento por favor ..." ) OF oParent
      oDlg:SetFont( oApp():oFont )
      REDEFINE BITMAP oBmp ID 111 OF oDlg2 RESOURCE 'bb_recetas' TRANSPARENT
      REDEFINE SAY oSay01 PROMPT 'Exportando recetas' ID 99  OF oDlg2
      REDEFINE SAY oSay02 PROMPT '    ' ID 100  OF oDlg2
      oProgress := TProgress():Redefine( 101, oDlg2 )

      oDlg2:bStart := {|| SysRefresh(), ReExport2( oProgress, cDescri, cArchiv, oSay02 ), oDlg2:End() }
      ACTIVATE DIALOG oDlg2 CENTERED
      MsgInfo( 'La exportación se realizó correctamente.' + CRLF + ;
         'El fichero generado es ' + oApp():cPchPath + RTrim( cArchiv ) + '.PCH', 'Información', 'Atención' )
   ENDIF
   CLOSE MD

   RE->( dbSetOrder( nOrder ) )
   RE->( dbGoto( nRecno ) )

   oGrid:Refresh()
   oGrid:SetFocus( .T. )

   oApp():nEdit--

RETURN NIL
//-----------------------------------------------------------------------------//
FUNCTION ReExport2( oProgress, cDescri, cArchiv, oSay02 )

   LOCAL nProgress := 0
   LOCAL cMemo

   CursorWait()
   oProgress:SetRange( 0, RE->( LastRec() ) )
   oProgress:SetPos( nProgress )
   // sysrefresh()
   SELECT MD
   ZAP
   MD->( dbAppend() )
   REPLACE MD->Linea WITH '[00]' + RTrim( cDescri )
   MD->( dbCommit() )
   RE->( dbGoTop() )
   AL->( dbSetOrder( 3 ) )
   DO WHILE ! RE->( Eof() )
      IF RE->ReSelecc == SELECCIONADA
         MD->( dbAppend() )
         REPLACE MD->Linea WITH '[01]' + RE->ReCodigo
         MD->( dbAppend() )
         REPLACE MD->Linea WITH '[02]' + RE->ReTitulo
         MD->( dbAppend() )
         REPLACE MD->Linea WITH '[03]' + RE->RePlato
         MD->( dbAppend() )
         REPLACE MD->Linea WITH '[04]' + RE->ReTipo
         MD->( dbAppend() )
         REPLACE MD->Linea WITH '[05]' + RE->ReTipoCoc
         MD->( dbAppend() )
         REPLACE MD->Linea WITH '[06]' + Str( RE->ReEpoca, 4 )
         MD->( dbAppend() )
         REPLACE MD->Linea WITH '[07]' + Str( RE->ReComens, 2 )
         cMemo := StrTran( RE->ReIngred, CRLF, '_p_c_h_' )
         DO WHILE Len( cMemo ) > 75
            MD->( dbAppend() )
            REPLACE MD->Linea WITH '[08]' + SubStr( cMemo, 1, 75 )
            cMemo := SubStr( cMemo, 76 )
         ENDDO
         MD->( dbAppend() )
         REPLACE MD->Linea WITH '[08]' + cMemo
         cMemo := StrTran( RE->RePrepar, CRLF, '_p_c_h_' )
         DO WHILE Len( cMemo ) > 75
            MD->( dbAppend() )
            REPLACE MD->Linea WITH '[09]' + SubStr( cMemo, 1, 75 )
            cMemo := SubStr( cMemo, 76 )
         ENDDO
         MD->( dbAppend() )
         REPLACE MD->Linea WITH '[09]' + cMemo
         MD->( dbAppend() )
         REPLACE MD->Linea WITH '[10]' + RE->ReTiempo
         MD->( dbAppend() )
         REPLACE MD->Linea WITH '[11]' + Str( RE->ReDificu, 1 )
         MD->( dbAppend() )
         REPLACE MD->Linea WITH '[12]' + Str( RE->RePrecio, 6 )
         MD->( dbAppend() )
         REPLACE MD->Linea WITH '[13]' + Str( RE->RePPC, 6 )
         MD->( dbAppend() )
         REPLACE MD->Linea WITH '[14]' + Str( RE->ReCalori, 1 )
         cMemo := StrTran( RE->ReTrucos, CRLF, '_p_c_h_' )
         // cMemo := RE->ReTrucos
         DO WHILE Len( cMemo ) > 75
            MD->( dbAppend() )
            REPLACE MD->Linea WITH '[15]' + SubStr( cMemo, 1, 75 )
            cMemo := SubStr( cMemo, 76 )
         ENDDO
         MD->( dbAppend() )
         REPLACE MD->Linea WITH '[15]' + cMemo
         cMemo := StrTran( RE->ReVino, CRLF, '_p_c_h_' )
         //cMemo := Rtrim(RE->ReVino)
         DO WHILE Len( cMemo ) > 75
            MD->( dbAppend() )
            REPLACE MD->Linea WITH '[16]' + SubStr( cMemo, 1, 75 )
            cMemo := SubStr( cMemo, 76 )
         ENDDO
         MD->( dbAppend() )
         REPLACE MD->Linea WITH '[16]' + cMemo
         MD->( dbAppend() )
         REPLACE MD->Linea WITH '[17]' + RE->RePublica
         MD->( dbAppend() )
         REPLACE MD->Linea WITH '[18]' + RE->ReAutor
         MD->( dbAppend() )
         REPLACE MD->Linea WITH '[19]' + RE->ReEmail
         MD->( dbAppend() )
         REPLACE MD->Linea WITH '[20]' + RE->RePais
         MD->( dbAppend() )
         REPLACE MD->Linea WITH '[21]' + Str( RE->ReNumero, 4 )
         MD->( dbAppend() )
         REPLACE MD->Linea WITH '[22]' + Str( RE->RePagina, 4 )
         MD->( dbAppend() )
         REPLACE MD->Linea WITH '[25]' + Str( RE->ReEscan, 6 )
         MD->( dbAppend() )
         REPLACE MD->Linea WITH '[26]' + DToC( RE->ReFchPrep )
         MD->( dbAppend() )
         REPLACE MD->Linea WITH '[27]' + RE->ReValorac
         MD->( dbAppend() )
         REPLACE MD->Linea WITH '[28]' + RE->ReUsuario
         MD->( dbAppend() )
         REPLACE MD->Linea WITH '[29]' + Str( RE->ReComEsc, 4 )
         // ahora meto el escandallo
         SELECT ES
         ES->( dbSetOrder( 1 ) )
         ordScope( 0, {|| Upper( RE->ReCodigo ) } )
         ordScope( 1, {|| Upper( RE->ReCodigo ) } )
         ES->( dbGoTop() )
         DO WHILE ! Eof()
            MD->( dbAppend() )
            REPLACE MD->Linea WITH '[30]' + ES->EsReceta
            MD->( dbAppend() )
            REPLACE MD->Linea WITH '[31]' + ES->EsUsuario
            MD->( dbAppend() )
            REPLACE MD->Linea WITH '[32]' + ES->EsIngred
            MD->( dbAppend() )
            REPLACE MD->Linea WITH '[33]' + Str( ES->EsCantidad, 6, 3 )
            MD->( dbAppend() )
            REPLACE MD->Linea WITH '[34]' + ES->EsUnidad
            MD->( dbAppend() )
            REPLACE MD->Linea WITH '[35]' + Str( ES->EsPrecio, 8, 2 )
            MD->( dbAppend() )
            REPLACE MD->Linea WITH '[36]' + ES->EsInDenomi
            MD->( dbAppend() )
            REPLACE MD->Linea WITH '[37]' + Str( ES->EsKCal, 8, 2 )

            // Ahora meto el ingrediente
            IF AL->( dbSeek( ES->EsIngred ) )
               MD->( dbAppend() )
               REPLACE MD->Linea WITH '[40]' + AL->AlCodigo
               MD->( dbAppend() )
               REPLACE MD->Linea WITH '[41]' + AL->AlTipo
               MD->( dbAppend() )
               REPLACE MD->Linea WITH '[42]' + AL->AlAlimento
               MD->( dbAppend() )
               REPLACE MD->Linea WITH '[43]' + AL->AlUnidad
               MD->( dbAppend() )
               REPLACE MD->Linea WITH '[44]' + Str( AL->AlPrecio, 8, 2 )
               MD->( dbAppend() )
               REPLACE MD->Linea WITH '[45]' + DToC( AL->AlUltCom )
               MD->( dbAppend() )
               REPLACE MD->Linea WITH '[46]' + Str( AL->AlKCal, 9, 2 )
               MD->( dbAppend() )
               REPLACE MD->Linea WITH '[47]' + Str( AL->AlProt, 9, 2 )
               MD->( dbAppend() )
               REPLACE MD->Linea WITH '[48]' + Str( AL->AlHC, 9, 2 )
               MD->( dbAppend() )
               REPLACE MD->Linea WITH '[49]' + Str( AL->AlGT, 9, 2 )
               MD->( dbAppend() )
               REPLACE MD->Linea WITH '[50]' + Str( AL->AlGS, 9, 2 )
               MD->( dbAppend() )
               REPLACE MD->Linea WITH '[51]' + Str( AL->AlGMI, 9, 2 )
               MD->( dbAppend() )
               REPLACE MD->Linea WITH '[52]' + Str( AL->AlGPI, 9, 2 )
               MD->( dbAppend() )
               REPLACE MD->Linea WITH '[53]' + Str( AL->AlCol, 9, 2 )
               MD->( dbAppend() )
               REPLACE MD->Linea WITH '[54]' + Str( AL->AlFib, 9, 2 )
               MD->( dbAppend() )
               REPLACE MD->Linea WITH '[55]' + Str( AL->AlNa, 9, 2 )
               MD->( dbAppend() )
               REPLACE MD->Linea WITH '[56]' + Str( AL->AlCa, 9, 2 )
            ENDIF
            ES->( dbSkip() )
         ENDDO
         MD->( dbAppend() )
         REPLACE MD->Linea WITH '[60]' + RE->ReImagen
         MD->( dbAppend() )
         REPLACE MD->Linea WITH '[61]' + Str( RE->ReMultip, 5, 2 )
         MD->( dbAppend() )
         REPLACE MD->Linea WITH '[62]' + Str( RE->RePFinal, 8, 2 )
         MD->( dbAppend() )
         REPLACE MD->Linea WITH '[63]' + RE->ReReferen
         MD->( dbAppend() )
         REPLACE MD->Linea WITH '[64]' + RE->ReAnotaci
         MD->( dbAppend() )
         REPLACE MD->Linea WITH '[65]' + Str( RE->ReVaOrden, 2 )
         MD->( dbAppend() )
         REPLACE MD->Linea WITH '[66]' + RE->ReFrTipo
         MD->( dbAppend() )
         REPLACE MD->Linea WITH '[67]' + RE->ReFrCargo
      ENDIF
      RE->( dbSkip() )
      oProgress:SetPos( nProgress++ )
      Sysrefresh()
   ENDDO
   AL->( dbSetOrder( 1 ) )
   // quito los scopes
   SELECT ES
   ordScope( 0 )
   ordScope( 1 )
   // oProgress:SetRange(oProgress:nMax)
   sysrefresh()
   Inkey( 0.1 )
   SELECT MD
   COPY TO (oApp():cPchPath + RTrim( cArchiv ) + '.pch') SDF
   ZAP
   CursorArrow()

RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION RePcxExport( oGrid, oParent )

   LOCAL oDlg, oSay0, oSay1, oSay2, oSay3
   LOCAL oGetDes, oGetArc
   LOCAL cDescri  := Space( 40 )
   LOCAL cArchiv  := Space( 40 )
   LOCAL oDlg2, oBmp, oSay01, oSay02, oProgress
   LOCAL nProgress := 1
   LOCAL nOrder   := RE->( ordNumber() )
   LOCAL nRecno   := RE->( RecNo() )

   IF ! Db_OpenNoIndex( "INTERMED", "MD" )
      RETURN NIL
   ENDIF

   oApp():nEdit++

   SELECT RE
   DEFINE DIALOG oDlg RESOURCE 'RE_SEL_3_' + oApp():cLanguage TITLE "Exportar recetas de cocina" OF oParent
   oDlg:SetFont( oApp():oFont )

   REDEFINE SAY oSay0 ;
      PROMPT "Indique un nombre de fichero sin extensión para almacenar las recetas seleccionadas." + CRLF + ;
      "El fichero se creará en la carpeta de archivos PCH definido en la configuración del programa y tendrá extensión .PCX" ;
      ID 100 OF oDlg COLOR CLR_BLACK, CLR_WHITE
   REDEFINE SAY oSay1 ID 101 OF oDlg
   REDEFINE SAY oSay2 ID 102 OF oDlg
   REDEFINE SAY oSay3 ID 103 OF oDlg
   REDEFINE GET oGetDes VAR cDescri ID 201 OF ODlg
   REDEFINE GET oGetArc VAR cArchiv ID 202 OF ODlg ;
      VALID iif( Empty( RTrim(cArchiv ) ), MsgStop( 'Es obligatorio introducir un nombre para el archivo.','Atención' ), .T. )

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
      DEFINE DIALOG oDlg2 RESOURCE 'UT_PROGRESS' ;
         TITLE i18n( "Un momento por favor ..." ) OF oParent
      oDlg:SetFont( oApp():oFont )
      REDEFINE BITMAP oBmp ID 111 OF oDlg2 RESOURCE 'bb_recetas' TRANSPARENT
      REDEFINE SAY oSay01 PROMPT 'Exportando recetas' ID 99  OF oDlg2
      REDEFINE SAY oSay02 PROMPT '    ' ID 100  OF oDlg2
      oProgress := TProgress():Redefine( 101, oDlg2 )
      oDlg2:bStart := {|| SysRefresh(), RePcxExport2( oProgress, cDescri, cArchiv, oSay02 ), oDlg2:End() }
      ACTIVATE DIALOG oDlg2 CENTERED
      MsgInfo( 'La exportación se realizó correctamente.' + CRLF + ;
         'El fichero generado es ' + oApp():cPchPath + RTrim( cArchiv ) + '.PCH', 'Información' )
   ENDIF
   CLOSE MD

   RE->( dbSetOrder( nOrder ) )
   RE->( dbGoto( nRecno ) )

   oGrid:Refresh()
   oGrid:SetFocus( .T. )

   oApp():nEdit--

RETURN NIL
//-----------------------------------------------------------------------------//
FUNCTION RePcxExport2( oProgress, cDescri, cArchiv, oSay02 )

   LOCAL aFields
   LOCAL cBuffer
   LOCAL cDbfFile
   LOCAL cXmlFile
   LOCAL cValue
   LOCAL cTable
   LOCAL nHandle
   LOCAL nFields
   LOCAL nField
   LOCAL nPos
   LOCAL aCTipo := { "C", "N", "L", "M", "D" }
   LOCAL aDTipo := { "Character", "Numeric", "Logical", "Memo", "Date" }
   LOCAL aFiles := {}
   LOCAL aDir   := {}
   LOCAL i
   LOCAL nRecno := RE->( RecNo() )

   cArchiv  := RTrim( cArchiv )
   cXMLFile := oApp():cPchPath + cArchiv + ".pcx"
   nHandle  := FCreate( cXmlFile, FC_NORMAL )

   //------------------
   // Writes XML header
   //------------------
   FWrite( nHandle, [ < ?xml version = "1.0" encoding = "ISO-8859-1" ? > ] + CRLF )
   FWrite( nHandle, Space( 0 ) + '<ROOT PCX="'  + cArchiv + '" DESCRIPCION="'  + RTrim( cDescri ) + '">' + CRLF )

   // fichero de recetas
   SELECT RE
   nFields := FCount()
   aFields := dbStruct()
   FWrite( nHandle, Space( 3 * 0 ) + "<Recetas>"  + CRLF )
   FWrite( nHandle, Space( 3 * 1 ) + "<Structure>"  + CRLF )
   FOR nField := 1 TO Len( aFields )
      FWrite( nHandle, Space( 3 * 2 ) + "<Field>"  + CRLF )
      cBuffer := Space( 3 * 3 ) + "<Field_name>" + aFields[ nField, 1 ] + "</Field_name>" + CRLF
      FWrite( nHandle, cBuffer )
      cBuffer := Space( 3 * 3 ) + "<Field_type>" + aDTipo[ AScan( aCTipo, aFields[ nField, 2 ] ) ] + "</Field_type>" + CRLF
      FWrite( nHandle, cBuffer )
      IF aFields[ nField, 2 ] $ "CN"
         cBuffer := Space( 3 * 3 ) + "<Field_length>" + RTrim( Str( aFields[ nField,3 ] ) ) + "</Field_length>" + CRLF
         FWrite( nHandle, cBuffer )
         cBuffer := Space( 3 * 3 ) + "<Field_decimals>" + RTrim( Str( aFields[ nField,4 ] ) ) + "</Field_decimals>" + CRLF
         FWrite( nHandle, cBuffer )
      ENDIF
      FWrite( nHandle, Space( 3 * 2 ) + "</Field>"  + CRLF )
   NEXT
   FWrite( nHandle, Space( 3 * 1 ) + "</Structure>"  + CRLF )
   FWrite( nHandle, Space( 3 * 1 ) + "<Data>"  + CRLF )
   RE->( dbGoTop() )
   DO WHILE ! Eof()
      IF RE->ReSelecc == SELECCIONADA
         cBuffer := Space( 3 * 2 ) + "<Record>"  + CRLF
         FWrite( nHandle, cBuffer )
         FOR nField := 1 TO nFields
            //-------------------
            // Beginning Record Tag
            //-------------------
            cBuffer := Space( 3 * 3 ) + "<" + FieldName( nField ) + ">"
            DO CASE
            CASE aFields[ nField, 2 ] == "D"
               cValue := DToS( FieldGet( nField ) )
            CASE aFields[ nField, 2 ] == "N"
               cValue := Str( FieldGet( nField ) )
            CASE aFields[ nField, 2 ] == "L"
               cValue := If( FieldGet( nField ), "True", "False" )
            OTHERWISE
               cValue := FieldGet( nField )
            ENDCASE
            //--- Convert special characters
            cValue := StrTran( cValue, "&", "&amp;" )
            cValue := StrTran( cValue, "<", "&lt;" )
            cValue := StrTran( cValue, ">", "&gt;" )
            cValue := StrTran( cValue, "'", "&apos;" )
            // cValue:= strTran(cValue,["],[&quot;])
            cBuffer := cBuffer             + ;
               AllTrim( cValue )   + ;
               "</"                + ;
               FieldName( nField ) + ;
               ">"                 + ;
               CRLF
            FWrite( nHandle, cBuffer )
         NEXT nField
      ENDIF

      //------------------
      // Ending Record Tag
      //------------------
      FWrite( nHandle, Space( 3 * 2 ) + "</Record>"  + CRLF )
      SKIP
   ENDDO
   RE->( dbGoto( nRecno ) )
   FWrite( nHandle, Space( 3 * 1 ) + "</Data>" + CRLF )
   FWrite( nHandle, Space( 3 * 0 ) + "</Recetas>" + CRLF )

   // fichero de escandallos
   SELECT ES
   nFields := FCount()
   aFields := dbStruct()
   FWrite( nHandle, Space( 3 * 0 ) + "<Escandallo>"  + CRLF )
   FWrite( nHandle, Space( 3 * 1 ) + "<Structure>"  + CRLF )
   FOR nField := 1 TO Len( aFields )
      FWrite( nHandle, Space( 3 * 2 ) + "<Field>"  + CRLF )
      cBuffer := Space( 3 * 3 ) + "<Field_name>" + aFields[ nField, 1 ] + "</Field_name>" + CRLF
      FWrite( nHandle, cBuffer )
      cBuffer := Space( 3 * 3 ) + "<Field_type>" + aDTipo[ AScan( aCTipo, aFields[ nField, 2 ] ) ] + "</Field_type>" + CRLF
      FWrite( nHandle, cBuffer )
      IF aFields[ nField, 2 ] $ "CN"
         cBuffer := Space( 3 * 3 ) + "<Field_length>" + RTrim( Str( aFields[ nField,3 ] ) ) + "</Field_length>" + CRLF
         FWrite( nHandle, cBuffer )
         cBuffer := Space( 3 * 3 ) + "<Field_decimals>" + RTrim( Str( aFields[ nField,4 ] ) ) + "</Field_decimals>" + CRLF
         FWrite( nHandle, cBuffer )
      ENDIF
      FWrite( nHandle, Space( 3 * 2 ) + "</Field>"  + CRLF )
   NEXT
   FWrite( nHandle, Space( 3 * 1 ) + "</Structure>"  + CRLF )
   FWrite( nHandle, Space( 3 * 1 ) + "<Data>"  + CRLF )
   RE->( ordSetFocus( 2 ) )
   ES->( dbGoTop() )
   DO WHILE ! Eof()
      RE->( dbGoTop() )
      RE->( dbSeek( ES->EsReceta ) )
      IF RE->ReSelecc == SELECCIONADA
         cBuffer := Space( 3 * 2 ) + "<Record>"  + CRLF
         FWrite( nHandle, cBuffer )
         FOR nField := 1 TO nFields
            //-------------------
            // Beginning Record Tag
            //-------------------
            cBuffer := Space( 3 * 3 ) + "<" + FieldName( nField ) + ">"
            DO CASE
            CASE aFields[ nField, 2 ] == "D"
               cValue := DToS( FieldGet( nField ) )
            CASE aFields[ nField, 2 ] == "N"
               cValue := Str( FieldGet( nField ) )
            CASE aFields[ nField, 2 ] == "L"
               cValue := If( FieldGet( nField ), "True", "False" )
            OTHERWISE
               cValue := FieldGet( nField )
            ENDCASE
            //--- Convert special characters
            cValue := StrTran( cValue, "&", "&amp;" )
            cValue := StrTran( cValue, "<", "&lt;" )
            cValue := StrTran( cValue, ">", "&gt;" )
            cValue := StrTran( cValue, "'", "&apos;" )
            // cValue:= strTran(cValue,["],[&quot;])
            cBuffer := cBuffer             + ;
               AllTrim( cValue )   + ;
               "</"                + ;
               FieldName( nField ) + ;
               ">"                 + ;
               CRLF
            FWrite( nHandle, cBuffer )
         NEXT nField
      ENDIF

      //------------------
      // Ending Record Tag
      //------------------
      FWrite( nHandle, Space( 3 * 2 ) + "</Record>"  + CRLF )
      SKIP
   ENDDO
   RE->( dbGoto( nRecno ) )
   FWrite( nHandle, Space( 3 * 1 ) + "</Data>" + CRLF )
   FWrite( nHandle, Space( 3 * 0 ) + "</Escandallo>" + CRLF )

   FWrite( nHandle, Space( 3 * 0 ) + "</ROOT>" + CRLF )
   FClose( nHandle )
   CursorArrow()

RETURN NIL
//________________________________________________________________________________

FUNCTION ReImport( oGrid, oCont, oParent )

   LOCAL cArchivo
   LOCAL cDescri
   LOCAL nVar := 1
   LOCAL oDlgProgress, oBmp, oSay01, oSay02, oProgress

   cArchivo := Lfn2sfn( cGetfile32( "*.pch","Indica la ubicación del archivo de recetas",,oApp():cPchPath,, .T. ) )
   IF Empty( cArchivo )
      MsgAlert( 'Debe especificar un archivo de recetas válido.', 'Atención' )
      RETURN NIL
   ENDIF

   IF ! Db_OpenNoIndex( "INTERMED", "MD" )
      RETURN NIL
   ENDIF

   oApp():nEdit++

   SELECT MD
   Db_ZAP()
   MsgRun( 'Preparando la incorporación de recetas. Espere un momento...', 'el Puchero', ;
      {|| Db_AppendSDF( cArchivo, Select() ) } )

   MD->( dbGoTop() )
   cDescri := RTrim( SubStr( MD->Linea,5 ) )
   MD->( dbSkip() )
   IF ! MsgYesNo( '¿ Desea incorporar estas recetas ?' + CRLF + cDescri, 'Seleccione una opción' )
      SELECT MD
      Db_ZAP()
      CLOSE MD
      oApp():nEdit--
      RETURN NIL
   ENDIF

   DEFINE DIALOG oDlgProgress RESOURCE 'UT_PROGRESS' ;
      TITLE i18n( "Un momento por favor ..." ) OF oParent
   oDlgProgress:SetFont( oApp():oFont )

   REDEFINE BITMAP oBmp ID 111 OF oDlgProgress RESOURCE 'BB_RECETAS' TRANSPARENT
   REDEFINE SAY oSay01 PROMPT 'Importando recetas' ID 99  OF oDlgProgress
   REDEFINE SAY oSay02 PROMPT '    ' ID 100  OF oDlgProgress
   oProgress := TProgress():Redefine( 101, oDlgProgress )
   oDlgProgress:bStart := {|| SysRefresh(), ReImport2( oProgress, oSay02, RTrim( cArchivo ) ), oDlgProgress:End() }
   ACTIVATE DIALOG oDlgProgress CENTERED

   CLOSE MD
   // depuAlimentos()
   MsgAlert( 'Es aconsejable que reindexe los ficheros de la aplicación', 'Atención' )

   SELECT RE
   RefreshCont( oCont, "RE" )
   oGrid:Refresh()
   oGrid:SetFocus( .T. )

   oApp():nEdit--

RETURN NIL

FUNCTION ReImport2( oProgress, oSay02, cArchivo )

   LOCAL lAlAppend := .F.
   LOCAL nProgress := 0
   LOCAL nInicio, lBarra, lAppend
   LOCAL cTitulo, nRecno, cMemo
   LOCAL oFont1, oFont2, oFont3

   CursorWait()
   oProgress:SetRange( 0, MD->( LastRec() ) )
   oProgress:SetPos( nProgress )
   sysrefresh()
   nInicio := Len( cArchivo )
   lBarra  := .F.
   DO WHILE nInicio > 0 .AND. ! lBarra
      IF SubStr( cArchivo, nInicio, 1 ) == '\'
         lbarra := .T.
      ELSE
         nInicio--
      ENDIF
   ENDDO
   IF lBarra
      cArchivo := SubStr( cArchivo, nInicio + 1 )
   ELSE
      cArchivo := SubStr( cArchivo, Len( cArchivo ) -12 )
   ENDIF
   MD->( dbGoTop() )
   SELECT RE
   lAppend := .T.
   DO WHILE ! MD->( Eof() )
      DO CASE
      CASE SubStr( MD->Linea, 1, 4 ) == '[01]'
         RE->( dbAppend() )
         // RE->(DbCommit())
         REPLACE RE->ReCodigo    WITH  RTrim( SubStr( MD->Linea,5 ) )
         REPLACE Re->ReIncorp    WITH 2
         REPLACE RE->ReFichero   WITH cArchivo
         REPLACE RE->ReFchInco   WITH Date()
         lAppend := .T.
      CASE SubStr( MD->Linea, 1, 4 ) == '[02]'
         cTitulo := Upper( RTrim( SubStr(MD->Linea,5 ) ) )
         nRecNo  := RE->( RecNo() )
         IF RE->( dbSeek( cTitulo ) ) .AND. RTrim( RE->ReFichero ) == RTrim( cArchivo )
            IF ! msgYesNo( "La receta " + cTitulo + " ya existe." + CRLF + "¿ Desea incorporarla de nuevo ?", 'Seleccione una opción' )
               RE->( dbGoto( nRecNo ) )
               RE->( dbDelete() )
               lAppend := .F.
            ELSE
               RE->( dbGoto( nRecNo ) )
               lAppend := .T.
            ENDIF
         ELSE
            RE->( dbGoto( nRecNo ) )
            lAppend := .T.
         ENDIF
         IF lAppend
            REPLACE RE->ReTitulo    WITH  RTrim( SubStr( MD->Linea,5 ) )
            oSay02:SetText( RE->ReTitulo )
         ENDIF
      CASE SubStr( MD->Linea, 1, 4 ) == '[03]' .AND. lAppend
         REPLACE RE->RePlato     WITH  RTrim( SubStr( MD->Linea,5 ) )
      CASE SubStr( MD->Linea, 1, 4 ) == '[04]' .AND. lAppend
         REPLACE RE->ReTipo      WITH  RTrim( SubStr( MD->Linea,5 ) )
      CASE SubStr( MD->Linea, 1, 4 ) == '[05]' .AND. lAppend
         REPLACE RE->ReTipoCoc   WITH  RTrim( SubStr( MD->Linea,5 ) )
      CASE SubStr( MD->Linea, 1, 4 ) == '[06]' .AND. lAppend
         REPLACE RE->ReEpoca     WITH  Val( RTrim( SubStr(MD->Linea,5 ) ) )
      CASE SubStr( MD->Linea, 1, 4 ) == '[07]' .AND. lAppend
         REPLACE RE->ReComens    WITH  Val( RTrim( SubStr(MD->Linea,5 ) ) )
      CASE SubStr( MD->Linea, 1, 4 ) == '[08]' .AND. lAppend
         cMemo := ' '
         DO WHILE SubStr( MD->Linea, 1, 4 ) == '[08]' .AND. ! MD->( Eof() )
            cMemo := cMemo + RTrim( SubStr( MD->Linea,5 ) )
            MD->( dbSkip() )
            oProgress:SetPos( nProgress++ )
            Sysrefresh()
         ENDDO
         REPLACE RE->ReIngred WITH StrTran( cMemo, '_p_c_h_', CRLF )
         MD->( dbSkip( -1 ) )
      CASE SubStr( MD->Linea, 1, 4 ) == '[09]' .AND. lAppend
         cMemo := ' '
         DO WHILE SubStr( MD->Linea, 1, 4 ) == '[09]' .AND. ! MD->( Eof() )
            cMemo := cMemo + RTrim( SubStr( MD->Linea,5 ) )
            MD->( dbSkip() )
            oProgress:SetPos( nProgress++ )
            Sysrefresh()
         ENDDO
         REPLACE RE->RePrepar WITH StrTran( cMemo, '_p_c_h_', CRLF )
         MD->( dbSkip( -1 ) )
      CASE SubStr( MD->Linea, 1, 4 ) == '[10]' .AND. lAppend
         REPLACE RE->ReTiempo WITH  RTrim( SubStr( MD->Linea,5 ) )
      CASE SubStr( MD->Linea, 1, 4 ) == '[11]' .AND. lAppend
         REPLACE RE->ReDificu WITH  Val( RTrim( SubStr(MD->Linea,5 ) ) )
      CASE SubStr( MD->Linea, 1, 4 ) == '[12]' .AND. lAppend
         REPLACE RE->RePrecio WITH  Val( RTrim( SubStr(MD->Linea,5 ) ) )
      CASE SubStr( MD->Linea, 1, 4 ) == '[13]' .AND. lAppend
         REPLACE RE->RePPC    WITH  Val( RTrim( SubStr(MD->Linea,5 ) ) )
      CASE SubStr( MD->Linea, 1, 4 ) == '[14]' .AND. lAppend
         REPLACE RE->ReCalori WITH  Val( RTrim( SubStr(MD->Linea,5 ) ) )
      CASE SubStr( MD->Linea, 1, 4 ) == '[15]' .AND. lAppend
         cMemo := ' '
         DO WHILE SubStr( MD->Linea, 1, 4 ) == '[15]' .AND. ! MD->( Eof() )
            cMemo := cMemo + RTrim( SubStr( MD->Linea,5 ) )
            MD->( dbSkip() )
            oProgress:SetPos( nProgress++ )
            Sysrefresh()
         ENDDO
         REPLACE RE->ReTrucos WITH StrTran( cMemo, '_p_c_h_', CRLF )
         MD->( dbSkip( -1 ) )
      CASE SubStr( MD->Linea, 1, 4 ) == '[16]' .AND. lAppend
         cMemo := ' '
         DO WHILE SubStr( MD->Linea, 1, 4 ) == '[16]' .AND. ! MD->( Eof() )
            cMemo := cMemo + RTrim( SubStr( MD->Linea,5 ) )
            MD->( dbSkip() )
            oProgress:SetPos( nProgress++ )
            Sysrefresh()
         ENDDO
         REPLACE RE->ReVino WITH StrTran( cMemo, '_p_c_h_', CRLF )
         MD->( dbSkip( -1 ) )
      CASE SubStr( MD->Linea, 1, 4 ) == '[17]' .AND. lAppend
         REPLACE RE->RePublica  WITH  RTrim( SubStr( MD->Linea,5 ) )
      CASE SubStr( MD->Linea, 1, 4 ) == '[18]' .AND. lAppend
         REPLACE RE->ReAutor    WITH  RTrim( SubStr( MD->Linea,5 ) )
      CASE SubStr( MD->Linea, 1, 4 ) == '[19]' .AND. lAppend
         REPLACE RE->ReEmail    WITH  RTrim( SubStr( MD->Linea,5 ) )
      CASE SubStr( MD->Linea, 1, 4 ) == '[20]' .AND. lAppend
         REPLACE RE->RePais     WITH  RTrim( SubStr( MD->Linea,5 ) )
      CASE SubStr( MD->Linea, 1, 4 ) == '[21]' .AND. lAppend
         REPLACE RE->ReNumero   WITH  Val( RTrim( SubStr(MD->Linea,5 ) ) )
      CASE SubStr( MD->Linea, 1, 4 ) == '[22]' .AND. lAppend
         REPLACE RE->RePagina   WITH  Val( RTrim( SubStr(MD->Linea,5 ) ) )
      CASE SubStr( MD->Linea, 1, 4 ) == '[25]' .AND. lAppend
         REPLACE RE->ReEscan    WITH  Val( RTrim( SubStr(MD->Linea,5 ) ) )
      CASE SubStr( MD->Linea, 1, 4 ) == '[26]' .AND. lAppend
         REPLACE RE->ReFchPrep  WITH  CToD( RTrim( SubStr(MD->Linea,5 ) ) )
      CASE SubStr( MD->Linea, 1, 4 ) == '[27]' .AND. lAppend
         REPLACE RE->ReValorac  WITH  RTrim( SubStr( MD->Linea,5 ) )
      CASE SubStr( MD->Linea, 1, 4 ) == '[28]' .AND. lAppend
         REPLACE RE->ReUsuario  WITH  RTrim( SubStr( MD->Linea,5 ) )
      CASE SubStr( MD->Linea, 1, 4 ) == '[29]' .AND. lAppend
         REPLACE RE->ReComEsc   WITH  Val( RTrim( SubStr(MD->Linea,5 ) ) )
      CASE SubStr( MD->Linea, 1, 4 ) == '[30]' .AND. lAppend
         DO WHILE Val( SubStr( MD->Linea,2,2 ) ) > 29 .AND. Val( SubStr( MD->Linea,2,2 ) ) < 60
            DO CASE
            CASE SubStr( MD->Linea, 1, 4 ) == '[30]'
               SELECT ES
               ES->( dbAppend() )
               REPLACE ES->EsReceta   WITH  RTrim( SubStr( MD->Linea,5 ) )
            CASE SubStr( MD->Linea, 1, 4 ) == '[31]'
               REPLACE ES->EsUsuario  WITH  RTrim( SubStr( MD->Linea,5 ) )
            CASE SubStr( MD->Linea, 1, 4 ) == '[32]'
               REPLACE ES->EsIngred   WITH  RTrim( SubStr( MD->Linea,5 ) )
            CASE SubStr( MD->Linea, 1, 4 ) == '[33]'
               REPLACE ES->EsCantidad WITH  Val( RTrim( SubStr(MD->Linea,5 ) ) )
            CASE SubStr( MD->Linea, 1, 4 ) == '[34]'
               REPLACE ES->EsUnidad WITH  SubStr( MD->Linea, 5 )
            CASE SubStr( MD->Linea, 1, 4 ) == '[35]'
               REPLACE ES->EsPrecio WITH  Val( RTrim( SubStr(MD->Linea,5 ) ) )
            CASE SubStr( MD->Linea, 1, 4 ) == '[36]'
               REPLACE ES->EsIndenomi WITH  SubStr( MD->Linea, 5 )
            CASE SubStr( MD->Linea, 1, 4 ) == '[37]'
               REPLACE ES->EsKCal WITH  Val( RTrim( SubStr(MD->Linea,5 ) ) )
            CASE SubStr( MD->Linea, 1, 4 ) == '[40]'
               SELECT AL
               AL->( dbSetOrder( 3 ) )
               AL->( dbGoTop() )
               IF ! AL->( dbSeek( RTrim(SubStr(MD->Linea,5 ) ) ) )
                  AL->( dbAppend() )
                  REPLACE AL->AlCodigo WITH  RTrim( SubStr( MD->Linea,5 ) )
                  lAlAppend := .T.
               ELSE
                  lAlAppend := .F.
               ENDIF
            CASE SubStr( MD->Linea, 1, 4 ) == '[41]' .AND. lAlAppend
               REPLACE AL->AlTipo   WITH  RTrim( SubStr( MD->Linea,5 ) )
            CASE SubStr( MD->Linea, 1, 4 ) == '[42]'
               REPLACE AL->AlAlimento WITH  RTrim( SubStr( MD->Linea,5 ) )
            CASE SubStr( MD->Linea, 1, 4 ) == '[43]' .AND. lAlAppend
               REPLACE AL->AlUnidad WITH  RTrim( SubStr( MD->Linea,5 ) )
            CASE SubStr( MD->Linea, 1, 4 ) == '[44]' .AND. lAlAppend
               REPLACE AL->AlPrecio WITH  Val( RTrim( SubStr(MD->Linea,6 ) ) )
            CASE SubStr( MD->Linea, 1, 4 ) == '[45]' .AND. lAlAppend
               REPLACE AL->AlUltCom WITH CToD( RTrim( SubStr(MD->Linea,6 ) ) )
            CASE SubStr( MD->Linea, 1, 4 ) == '[46]' .AND. lAlAppend
               REPLACE AL->AlKCal   WITH  Val( RTrim( SubStr(MD->Linea,6 ) ) )
            CASE SubStr( MD->Linea, 1, 4 ) == '[47]' .AND. lAlAppend
               REPLACE AL->AlProt   WITH  Val( RTrim( SubStr(MD->Linea,6 ) ) )
            CASE SubStr( MD->Linea, 1, 4 ) == '[48]' .AND. lAlAppend
               REPLACE AL->AlHC     WITH  Val( RTrim( SubStr(MD->Linea,6 ) ) )
            CASE SubStr( MD->Linea, 1, 4 ) == '[49]' .AND. lAlAppend
               REPLACE AL->AlGT     WITH  Val( RTrim( SubStr(MD->Linea,6 ) ) )
            CASE SubStr( MD->Linea, 1, 4 ) == '[50]' .AND. lAlAppend
               REPLACE AL->AlGS     WITH  Val( RTrim( SubStr(MD->Linea,6 ) ) )
            CASE SubStr( MD->Linea, 1, 4 ) == '[51]' .AND. lAlAppend
               REPLACE AL->AlGMI    WITH  Val( RTrim( SubStr(MD->Linea,6 ) ) )
            CASE SubStr( MD->Linea, 1, 4 ) == '[52]' .AND. lAlAppend
               REPLACE AL->AlGPI    WITH  Val( RTrim( SubStr(MD->Linea,6 ) ) )
            CASE SubStr( MD->Linea, 1, 4 ) == '[53]' .AND. lAlAppend
               REPLACE AL->AlCol    WITH  Val( RTrim( SubStr(MD->Linea,6 ) ) )
            CASE SubStr( MD->Linea, 1, 4 ) == '[54]' .AND. lAlAppend
               REPLACE AL->AlFib    WITH  Val( RTrim( SubStr(MD->Linea,6 ) ) )
            CASE SubStr( MD->Linea, 1, 4 ) == '[55]' .AND. lAlAppend
               REPLACE AL->AlNa     WITH  Val( RTrim( SubStr(MD->Linea,6 ) ) )
            CASE SubStr( MD->Linea, 1, 4 ) == '[56]' .AND. lAlAppend
               REPLACE AL->AlCa     WITH  Val( RTrim( SubStr(MD->Linea,6 ) ) )
            ENDCASE
            MD->( dbSkip() )
         ENDDO
         // ES->(DbCommit())
         // AL->(DbCommit())
         MD->( dbSkip( -1 ) )
         SELECT RE
         LOOP
      CASE SubStr( MD->Linea, 1, 4 ) == '[60]' .AND. lAppend
         REPLACE RE->ReImagen  WITH RTrim( SubStr( MD->Linea,5 ) )
      CASE SubStr( MD->Linea, 1, 4 ) == '[61]' .AND. lAppend
         REPLACE RE->ReMultip  WITH Val( RTrim( SubStr(MD->Linea,5 ) ) )
      CASE SubStr( MD->Linea, 1, 4 ) == '[62]' .AND. lAppend
         REPLACE RE->RePFinal  WITH Val( RTrim( SubStr(MD->Linea,5 ) ) )
      CASE SubStr( MD->Linea, 1, 4 ) == '[63]' .AND. lAppend
         REPLACE RE->ReReferen WITH RTrim( SubStr( MD->Linea,5 ) )
      CASE SubStr( MD->Linea, 1, 4 ) == '[64]' .AND. lAppend
         REPLACE RE->ReAnotaci WITH RTrim( SubStr( MD->Linea,5 ) )
      CASE SubStr( MD->Linea, 1, 4 ) == '[65]' .AND. lAppend
         REPLACE RE->ReVaOrden WITH Val( RTrim( SubStr(MD->Linea,5 ) ) )
      CASE SubStr( MD->Linea, 1, 4 ) == '[66]' .AND. lAppend
         REPLACE RE->ReFrTipo  WITH RTrim( SubStr( MD->Linea,5 ) )
      CASE SubStr( MD->Linea, 1, 4 ) == '[67]' .AND. lAppend
         REPLACE RE->ReFrCargo WITH RTrim( SubStr( MD->Linea,5 ) )
      ENDCASE
      // RE->(DbCommit())
      MD->( dbSkip() )
      oProgress:SetPos( nProgress++ )
      Sysrefresh()
   ENDDO
   CursorArrow()
   dbCommitAll()
   MsgInfo( 'La importación se realizó correctamente.', 'Atención' )
   IF MsgYesNo( '¿ Desea realizar un listado de las recetas incorporadas ?', 'Seleccione una opción' )
      SELECT MD
      MD->( dbGoTop() )
      DEFINE FONT oFont1 NAME "Arial" SIZE 0, -9
      DEFINE FONT oFont2 NAME "Arial" SIZE 0, -22
      DEFINE FONT oFont3 NAME "Arial" SIZE 0, -9 BOLD
      REPORT oReport ;
         TITLE  " ", " ", i18n( "Recetas incorporadas" ), " ", " " CENTERED;
         FONT   oFont1, oFont2, oFont3 ;
         HEADER " ", oApp():cAppName + oApp():cVersion, "Fecha: " + DToC( Date() ) + "   Página.: " + Str( oReport:nPage, 3 ) ;
         CAPTION "LISTADO DE RECETAS" PREVIEW

      COLUMN TITLE "Receta"   DATA SubStr( MD->Linea, 5 ) SIZE 75 FONT 1
      RptEnd()

      IF oReport:lCreated
         oReport:nTitleUpLine := RPT_SINGLELINE
         oReport:nTitleDnLine := RPT_SINGLELINE
         oReport:oTitle:aFont[ 3 ] := {|| 2 }
         oReport:nTopMargin   := 0.1
         oReport:nDnMargin    := 0.1
         oReport:nLeftMargin  := 0.1
         oReport:nRightMargin := 0.1
         //oReport:oDevice:lPrvModal := .T.
      ENDIF

      ACTIVATE REPORT oReport FOR SubStr( MD->Linea, 1, 4 ) == '[02]'

      RELEASE FONT oFont1
      RELEASE FONT oFont2
      RELEASE FONT oFont3
   ENDIF
   SELECT MD
   ZAP

RETURN NIL


/*_____________________________________________________________________________*/
FUNCTION RePcxImport( oGrid, oCont, oParent )

   LOCAL cArchivo
   LOCAL cDescri
   LOCAL nVar := 1
   LOCAL oDlgProgress, oBmp, oSay01, oSay02, oProgress
   LOCAL nFHandle, nFLines, Linea
   LOCAL nRecno  := RE->( RecNo() )
   LOCAL nOrder  := RE->( ordNumber() )

   cArchivo := Lfn2sfn( cGetfile32( "*.pcx","Indica la ubicación del archivo de recetas",,oApp():cPchPath,, .T. ) )
   IF Empty( cArchivo )
      MsgAlert( 'Debe especificar un archivo de recetas válido.', 'Atención' )
      RETURN NIL
   ENDIF

   oApp():nEdit++

   nFHandle := FOpen( cArchivo )
   nFLines  := FLineCount( cArchivo )
   // leo dos lineas para sacar la descripción
   HB_FReadLine( nFHandle, @Linea )
   HB_FReadLine( nFHandle, @Linea )
   cDescri := SubStr( Linea, At( 'DESCRIPCION',Linea ) + 13 )
   cDescri := SubStr( cDescri, 1, Len( cDescri ) -2 )
   FClose( cArchivo )
   IF ! MsgYesNo( '¿ Desea incorporar estas recetas ?' + CRLF + cDescri, 'Seleccione una opción' )
      oApp():nEdit--
      RETU NIL
   ENDIF

   DEFINE DIALOG oDlgProgress RESOURCE 'UT_PROGRESS' ;
      TITLE i18n( "Un momento por favor ..." ) OF oParent
   oDlgProgress:SetFont( oApp():oFont )

   REDEFINE BITMAP oBmp ID 111 OF oDlgProgress RESOURCE 'BB_RECETAS' TRANSPARENT
   REDEFINE SAY oSay01 PROMPT 'Importando recetas' ID 99  OF oDlgProgress
   REDEFINE SAY oSay02 PROMPT '    ' ID 100  OF oDlgProgress
   oProgress := TProgress():Redefine( 101, oDlgProgress )
   oDlgProgress:bStart := {|| SysRefresh(), RePcxImport2( oProgress, oSay02, RTrim( cArchivo ) ), oDlgProgress:End() }
   ACTIVATE DIALOG oDlgProgress CENTERED

   MsgAlert( 'Es aconsejable que reindexe los ficheros de la aplicación', 'Atención' )

   SELECT RE
   RE->( dbSetOrder( nOrder ) )
   RE->( dbGoto( nRecno ) )
   RefreshCont( oCont, "RE" )
   oGrid:Refresh()
   oGrid:SetFocus( .T. )

   oApp():nEdit--

RETURN NIL

FUNCTION RePcxImport2( oProgress, oSay02, cArchivo )

   LOCAL hFile    := FOpen( cArchivo )
   LOCAL nFLines, Linea, i, cField, nField, cData
   LOCAL lReceta     := .F.
   LOCAL lEscandallo := .F.
   LOCAL lRecord     := .F.
   LOCAL aReFields   := Array( RE->( FCount() ) )
   LOCAL aEsFields   := Array( ES->( FCount() ) )

   RE->( ordSetFocus( 2 ) )
   ES->( ordSetFocus( 3 ) )
   nFLines  := FLineCount( cArchivo )
   oProgress:SetRange( 0, nFLines )
   i := 1
   DO WHILE i <= nFLines
      HB_FReadLine( hFile, @Linea )
      Linea := LTrim( Linea )
      IF Linea == "<Data>"
         IF lReceta == .F.
            lreceta := .T.
         ELSEIF lEscandallo == .F.
            lReceta := .F.
            lEscandallo := .T.
         ENDIF
      ELSEIF Linea == "<Record>"
         lRecord := .T.
         IF lReceta == .T.
            SELECT RE
         ELSE
            SELECT ES
         ENDIF
      ELSEIF Linea == "</Record>"
         // aqui añado
         IF lReceta == .T.
            RE->( dbGoTop() )
            IF ! RE->( dbSeek( Upper(aReFields[ 1 ] ) ) )
               Db_Gather( aReFields, 'RE', .T. )
            ELSE
               MsgInfo( 'La receta ' + aReFields[ 1 ] + ' ' + aReFields[ 2 ] + ' ya existe.', 'Información' )
            ENDIF
         ELSEIF lEscandallo
            ES->( dbGoTop() )
            IF ! ES->( dbSeek( Upper(aEsFields[ 1 ] + aEsFields[ 3 ] ) ) )
               Db_Gather( aEsFields, 'ES', .T. )
            ELSE
               MsgInfo( 'El Ingrediente ' + aEsFields[ 1 ] + ' ' + aEsFields[ 3 ] + ' ya existe.', 'Información' )
            ENDIF
         ENDIF
         lRecord := .F.
      ELSEIF lRecord == .T.
         cField := hb_AtX( "<[^>]*>", Linea, .F. )
         cField := SubStr( cField, 2, Len( cField ) -2 )
         IF cField == 'REINGRED'
            cData := ''
            Linea := StrTran( Linea, '<REINGRED>', '' )
            DO WHILE At( "</REINGRED>", Linea ) == 0
               cData := cData + Linea
               i++
               HB_FReadLine( hFile, @Linea )
            ENDDO
            Linea := StrTran( Linea, '</REINGRED>', '' )
            cData := cData + Linea
         ELSEIF cField == 'REPREPAR'
            cData := ''
            Linea := StrTran( Linea, '<REPREPAR>', '' )
            DO WHILE At( "</REPREPAR>", Linea ) == 0
               cData := cData + Linea
               i++
               HB_FReadLine( hFile, @Linea )
            ENDDO
            Linea := StrTran( Linea, '</REPREPAR>', '' )
            cData := cData + Linea
         ELSEIF cField == 'RETRUCOS'
            cData := ''
            Linea := StrTran( Linea, '<RETRUCOS>', '' )
            DO WHILE At( "</RETRUCOS>", Linea ) == 0
               cData := cData + Linea
               i++
               HB_FReadLine( hFile, @Linea )
            ENDDO
            Linea := StrTran( Linea, '</RETRUCOS>', '' )
            cData := cData + Linea
         ELSEIF cField == 'REVINO'
            cData := ''
            Linea := StrTran( Linea, '<REVINO>', '' )
            DO WHILE At( "</REVINO>", Linea ) == 0
               cData := cData + Linea
               i++
               HB_FReadLine( hFile, @Linea )
            ENDDO
            Linea := StrTran( Linea, '</REVINO>', '' )
            cData := cData + Linea
         ELSE
            cData  := hb_AtX( ">[^<]*<", Linea, .F. )
            cData := SubStr( cData, 2, Len( cData ) -2 )
         ENDIF
         nField := FieldPos( cField )
         IF lReceta == .T.
            IF FieldType( nField ) == 'D'
               aReFields[ nField ] := CToD( cData )
            ELSEIF FieldType( nField ) == 'N'
               aReFields[ nField ] := Val( cData )
            ELSEIF FieldType( nField ) == 'L'
               aReFields[ nField ] :=  iif( cData == "True", .T., .F. )
            ELSE
               aReFields[ nField ] := cData
            ENDIF
         ELSE
            IF FieldType( nField ) == 'D'
               aEsFields[ nField ] := CToD( cData )
            ELSEIF FieldType( nField ) == 'N'
               aEsFields[ nField ] := Val( cData )
            ELSEIF FieldType( nField ) == 'L'
               aEsFields[ nField ] :=  iif( cData == "True", .T., .F. )
            ELSE
               aEsFields[ nField ] := cData
            ENDIF
         ENDIF
      ENDIF
      oProgress:SetPos( i++ )
      sysrefresh()
   ENDDO
   FClose( hFile )

RETURN NIL


/*_____________________________________________________________________________*/

STATIC FUNCTION ReGetImage( oImage, oGet, oBtn )

   LOCAL cImageFile
   /*
   cImageFile := cGetfile32("Bitmap (*.bmp)| *.bmp|" +;
                            "JPEG   (*.jpg)| *.jpg|" +;
                            "Gif    (*.gif)| *.gif|" +;
                            "DIB    (*.dib)| *.dib|" +;
                            "PCX    (*.pcx)| *.pcx|" +;
                            "TARGA  (*.tga)| *.tga|" +;
                            "RLE    (*.rle)| *.rle|" ,;
                            "Indica la ubicación de la imagen",,,,.t.)
   */

   cImageFile := cGetfile32( "Archivos de imagen (bmp,jpg,gif,png,dig,pcx,tga,rle) | *.bmp;*.jpg;*.gif;*.png;*.dig;*.pcx;*.tga;*.rle |", ;
      "Indica la ubicación de la imagen",,,, .T. )
   IF ! Empty( cImageFile ) .AND. File( lfn2sfn( RTrim(cImageFile ) ) )
      oImage:LoadBmp( lfn2sfn( RTrim(cImageFile ) ) )
      oGet:cText := cImageFile
      oBtn:Refresh()
   ENDIF

RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION ReZoomImagen( cReImagen, cRetitulo, oParent )

   LOCAL oDlg, oImage

   IF Empty( RTrim( cReImagen ) )
      MsgInfo( "La receta no tiene asociada ninguna imagen.", 'Información' )
      RETURN NIL
   ENDIF
   IF ! File( lfn2sfn( RTrim(cReImagen ) ) )
      MsgInfo( "No existe el fichero de imagen asociado a la receta." + ;
         "Por favor revise la ruta y el nombre del fichero.", 'Información' )
      RETURN NIL
   ENDIF

   oApp():nEdit++

   DEFINE DIALOG oDlg RESOURCE "RE_ZOOM_" + oApp():cLanguage TITLE cReTitulo OF oParent
   oDlg:SetFont( oApp():oFont )

   REDEFINE ZOOMIMAGE oImage        ;
      FILE lfn2sfn( RTrim( cReImagen ) );
      ID 102 OF oDlg // SCROLL

   // oImage:Progress( .t. )
   oImage:SetColor( CLR_RED, CLR_WHITE )

   REDEFINE BUTTON  ;
      ID       IDOK ;
      OF       oDlg ;
      ACTION   oDlg:End()

   ACTIVATE DIALOG oDlg CENTER ;
      ON INIT DlgCenter( oDlg, oApp():oWndMain )

   oApp():nEdit--

RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION ReCopiar( oParent )

   LOCAL mReceta := ''
   LOCAL Separa  := '***' + CRLF
   LOCAL oDlg, oClp, oMemo, oBtn

   oApp():nEdit++

   mReceta += RE->ReTitulo

   mReceta += Separa + '[01]' + RE->ReCodigo
   mReceta += Separa + '[02]' + RE->ReTitulo
   mReceta += Separa + '[03]' + RE->RePlato
   mReceta += Separa + '[04]' + RE->ReTipo
   mReceta += Separa + '[05]' + RE->ReTipoCoc
   mReceta += Separa + '[06]' + Str( RE->ReEpoca, 4 )
   mReceta += Separa + '[07]' + Str( RE->ReComens, 2 )
   mReceta += Separa + '[08]' + RTrim( RE->ReIngred )
   mReceta += Separa + '[09]' + RTrim( RE->RePrepar )
   mReceta += Separa + '[10]' + RE->ReTiempo
   mReceta += Separa + '[11]' + Str( RE->ReDificu, 1 )
   mReceta += Separa + '[12]' + Str( RE->RePrecio, 6 )
   mReceta += Separa + '[13]' + Str( RE->RePPC, 6 )
   mReceta += Separa + '[14]' + Str( RE->ReCalori, 1 )
   mReceta += Separa + '[15]' + RTrim( RE->ReTrucos )
   mReceta += Separa + '[16]' + RTrim( RE->ReVino )
   mReceta += Separa + '[17]' + RE->RePublica
   mReceta += Separa + '[18]' + RE->ReAutor
   mReceta += Separa + '[19]' + RE->ReEmail
   mReceta += Separa + '[20]' + RE->RePais
   mReceta += Separa + '[21]' + Str( RE->ReNumero, 4 )
   mReceta += Separa + '[22]' + Str( RE->RePagina, 4 )
   mReceta += Separa + '[25]' + Str( RE->ReEscan, 6 )
   mReceta += Separa + '[26]' + DToC( RE->ReFchPrep )
   mReceta += Separa + '[27]' + RE->ReValorac
   mReceta += Separa + '[28]' + RE->ReUsuario
   mReceta += Separa + '[29]' + Str( RE->ReComEsc, 4 )

   // ahora meto el escandallo
   SELECT ES
   ordScope( 0, {|| Upper( RE->ReCodigo ) } )
   ordScope( 1, {|| Upper( RE->ReCodigo ) } )
   ES->( dbGoTop() )
   DO WHILE ! Eof()
      mReceta += Separa + '[30]' + ES->EsReceta
      mReceta += Separa + '[31]' + ES->EsUsuario
      mReceta += Separa + '[32]' + ES->EsIngred
      mReceta += Separa + '[33]' + Str( ES->EsCantidad, 6, 3 )
      mReceta += Separa + '[34]' + ES->EsUnidad
      mReceta += Separa + '[35]' + Str( ES->EsPrecio, 8, 2 )
      mReceta += Separa + '[36]' + ES->EsInDenomi
      mReceta += Separa + '[37]' + Str( ES->EsKCal, 8, 2 )
      // Ahora meto el ingrediente
      AL->( dbSetOrder( 3 ) )
      IF AL->( dbSeek( ES->EsIngred ) )
         mReceta += Separa + '[40]' + AL->AlCodigo
         mReceta += Separa + '[41]' + AL->AlTipo
         mReceta += Separa + '[42]' + AL->AlAlimento
         mReceta += Separa + '[43]' + AL->AlUnidad
         mReceta += Separa + '[44]' + Str( AL->AlPrecio, 8, 2 )
         mReceta += Separa + '[45]' + DToC( AL->AlUltCom )
         mReceta += Separa + '[46]' + Str( AL->AlKCal, 9, 2 )
         mReceta += Separa + '[47]' + Str( AL->AlProt, 9, 2 )
         mReceta += Separa + '[48]' + Str( AL->AlHC, 9, 2 )
         mReceta += Separa + '[49]' + Str( AL->AlGT, 9, 2 )
         mReceta += Separa + '[50]' + Str( AL->AlGS, 9, 2 )
         mReceta += Separa + '[51]' + Str( AL->AlGMI, 9, 2 )
         mReceta += Separa + '[52]' + Str( AL->AlGPI, 9, 2 )
         mReceta += Separa + '[53]' + Str( AL->AlCol, 9, 2 )
         mReceta += Separa + '[54]' + Str( AL->AlFib, 9, 2 )
         mReceta += Separa + '[55]' + Str( AL->AlNa, 9, 2 )
         mReceta += Separa + '[56]' + Str( AL->AlCa, 9, 2 )
      ENDIF
      ES->( dbSkip() )
   ENDDO
   mReceta += Separa + '[60]' + RE->ReImagen
   mReceta += Separa + '[61]' + Str( RE->ReMultip, 5, 2 )
   mReceta += Separa + '[62]' + Str( RE->RePFinal, 8, 2 )
   mReceta += Separa + '[63]' + RE->ReReferen
   mReceta += Separa + '[64]' + RE->ReAnotaci
   mReceta += Separa + '[65]' + Str( RE->ReVaOrden, 2 )
   mReceta += Separa + '[66]' + RE->ReFrTipo
   mReceta += Separa + '[67]' + RE->ReFrCargo
   mReceta += Separa
   mReceta += Separa
   AL->( dbSetOrder( 1 ) )
   SELECT ES
   ordScope( 0, )
   ordScope( 1, )

   DEFINE DIALOG oDlg RESOURCE 'RE_CLIPB1_' + oApp():cLanguage OF oParent
   oDlg:SetFont( oApp():oFont )

   REDEFINE GET oMemo VAR mReceta  ID 101 MEMO OF oDlg COLOR CLR_BLACK, CLR_WHITE
   oMemo:bGotFocus := {|| oBtn:SetFocus() }

   REDEFINE BUTTON oBtn           ;
      ID IDOK OF oDlg             ;
      ACTION oDlg:End()

   DEFINE CLIPBOARD oClp OF oDlg
   oClp:Clear()
   oClp:SetText( mReceta )

   ACTIVATE DIALOG oDlg ON INIT DlgCenter( oDlg, oApp():oWndMain )

   oClp:Close()

   oApp():nEdit--

RETURN NIL
/*_____________________________________________________________________________*/
FUNCTION ReXCopiar( oParent )

   LOCAL mReceta := ''
   LOCAL oDlg, oClp, oMemo, oBtn
   LOCAL nFields, aFields, cBuffer, cValue, i

   oApp():nEdit++

   nFields := RE->( FCount() )
   aFields := RE->( dbStruct() )
   cBuffer := Space( 3 * 0 ) + "<Receta>"
   mReceta += cBuffer + CRLF
   FOR i := 1 TO nFields
      cBuffer := Space( 3 * 1 ) + "<" + FieldName( i ) + ">"
      DO CASE
      CASE aFields[ i, 2 ] == "D"
         cValue := DToS( FieldGet( i ) )
      CASE aFields[ i, 2 ] == "N"
         cValue := Str( FieldGet( i ) )
      CASE aFields[ i, 2 ] == "L"
         cValue := If( FieldGet( i ), "True", "False" )
      OTHERWISE
         cValue := FieldGet( i )
      ENDCASE
      //--- Convert special characters
      cValue := StrTran( cValue, "&", "&amp;" )
      cValue := StrTran( cValue, "<", "&lt;" )
      cValue := StrTran( cValue, ">", "&gt;" )
      cValue := StrTran( cValue, "'", "&apos;" )
      // cValue:= strTran(cValue,["],[&quot;])
      cBuffer := cBuffer             + ;
         AllTrim( cValue )   + ;
         "</"                + ;
         FieldName( i ) + ;
         ">"
      mReceta += cBuffer + CRLF
   NEXT i
   cBuffer := Space( 3 * 0 ) + "</Receta>"
   mReceta += cBuffer + CRLF
   // ahora meto el escandallo
   SELECT ES
   ordScope( 0, {|| Upper( RE->ReCodigo ) } )
   ordScope( 1, {|| Upper( RE->ReCodigo ) } )
   ES->( dbGoTop() )
   nFields := ES->( FCount() )
   aFields := ES->( dbStruct() )
   cBuffer := Space( 3 * 0 ) + "<Escandallo>"
   mReceta += cBuffer + CRLF
   DO WHILE ! Eof()
      cBuffer := Space( 3 * 1 ) + "<Ingrediente>"
      mReceta += cBuffer + CRLF
      FOR i := 1 TO nFields
         cBuffer := Space( 3 * 2 ) + "<" + FieldName( i ) + ">"
         DO CASE
         CASE aFields[ i, 2 ] == "D"
            cValue := DToS( FieldGet( i ) )
         CASE aFields[ i, 2 ] == "N"
            cValue := Str( FieldGet( i ) )
         CASE aFields[ i, 2 ] == "L"
            cValue := If( FieldGet( i ), "True", "False" )
         OTHERWISE
            cValue := FieldGet( i )
         ENDCASE
         //--- Convert special characters
         cValue := StrTran( cValue, "&", "&amp;" )
         cValue := StrTran( cValue, "<", "&lt;" )
         cValue := StrTran( cValue, ">", "&gt;" )
         cValue := StrTran( cValue, "'", "&apos;" )
         // cValue:= strTran(cValue,["],[&quot;])
         cBuffer := cBuffer             + ;
            AllTrim( cValue )   + ;
            "</"                + ;
            FieldName( i ) + ;
            ">"
         mReceta += cBuffer + CRLF
      NEXT i
      cBuffer := Space( 3 * 1 ) + "</Ingrediente>"
      mReceta += cBuffer + CRLF
      ES->( dbSkip() )
   ENDDO
   cBuffer := Space( 3 * 0 ) + "</Escandallo>"
   mReceta += cBuffer + CRLF
   SELECT ES
   ordScope( 0, )
   ordScope( 1, )

   DEFINE DIALOG oDlg RESOURCE 'RE_CLIPB1_' + oApp():cLanguage OF oParent
   oDlg:SetFont( oApp():oFont )

   REDEFINE GET oMemo VAR mReceta  ID 101 MEMO OF oDlg COLOR CLR_BLACK, CLR_WHITE
   oMemo:bGotFocus := {|| oBtn:SetFocus() }

   REDEFINE BUTTON oBtn           ;
      ID IDOK OF oDlg             ;
      ACTION oDlg:End()

   DEFINE CLIPBOARD oClp OF oDlg
   oClp:Clear()
   oClp:SetText( mReceta )

   ACTIVATE DIALOG oDlg ON INIT DlgCenter( oDlg, oApp():oWndMain )

   oClp:Close()

   oApp():nEdit--

RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION RePegar( oGrid, oCont, oParent )

   LOCAL mReceta   := ''
   LOCAL cLinea    := ''
   LOCAL cSepara   := '***' + CRLF
   LOCAL lOk       := .F.
   LOCAL lAlAppend := .F.
   LOCAL oDlg, oClp, oMemo, oBtnOk, oBtnCancel

   oApp():nEdit++

   DEFINE DIALOG oDlg RESOURCE 'RE_CLIPB2_' + oApp():cLanguage OF oParent
   oDlg:SetFont( oApp():oFont )

   DEFINE CLIPBOARD oClp OF oDlg
   mReceta := oClp:GetText()

   REDEFINE GET oMemo VAR mReceta  ID 101 MEMO OF oDlg COLOR CLR_BLACK, CLR_WHITE
   oMemo:bGotFocus := {|| oBtnOk:SetFocus() }

   REDEFINE BUTTON oBtnOk         ;
      ID IDOK OF oDlg             ;
      ACTION ( lOk := .T., oDlg:End() )

   REDEFINE BUTTON oBtnCancel     ;
      ID IDCANCEL OF oDlg         ;
      ACTION oDlg:End()

   ACTIVATE DIALOG oDlg ON INIT DlgCenter( oDlg, oApp():oWndMain )

   IF lOk
      DO WHILE Len( mReceta ) > 0
         DO CASE
         CASE SubStr( mReceta, 1, 4 ) == '[01]'
            RE->( dbAppend() )
            RE->ReCodigo  :=  RTrim( SubStr( mReceta,5,At(cSepara,mReceta ) -5 ) )
            RE->ReIncorp  := 2
            RE->ReFichero := ''
            RE->ReFchInco := Date()
            RE->RePlato   := '1'
            RE->ReEpoca   := 0
            RE->ReDificu  := 1
            RE->ReCalori  := 1
         CASE SubStr( mReceta, 1, 4 ) == '[02]'
            RE->ReTitulo  := RTrim( SubStr( mReceta,5,At(cSepara,mReceta ) -5 ) )
         CASE SubStr( mReceta, 1, 4 ) == '[03]'
            RE->RePlato   := RTrim( SubStr( mReceta,5,At(cSepara,mReceta ) -5 ) )
         CASE SubStr( mReceta, 1, 4 ) == '[04]'
            RE->ReTipo    := RTrim( SubStr( mReceta,5,At(cSepara,mReceta ) -5 ) )
         CASE SubStr( mReceta, 1, 4 ) == '[05]'
            RE->ReTipoCoc := RTrim( SubStr( mReceta,5,At(cSepara,mReceta ) -5 ) )
         CASE SubStr( mReceta, 1, 4 ) == '[06]'
            RE->ReEpoca   := Val( RTrim( SubStr(mReceta,5,At(cSepara,mReceta ) -5 ) ) )
         CASE SubStr( mReceta, 1, 4 ) == '[07]'
            RE->ReComens    := Val( RTrim( SubStr(mReceta,5,At(cSepara,mReceta ) -5 ) ) )
         CASE SubStr( mReceta, 1, 4 ) == '[08]'
            RE->ReIngred    := SubStr( mReceta, 5, At( cSepara,mReceta ) -5 )
         CASE SubStr( mReceta, 1, 4 ) == '[09]'
            RE->RePrepar    := SubStr( mReceta, 5, At( cSepara,mReceta ) -5 )
         CASE SubStr( mReceta, 1, 4 ) == '[10]'
            RE->ReTiempo :=  RTrim( SubStr( mReceta,5,At(cSepara,mReceta ) -5 ) )
         CASE SubStr( mReceta, 1, 4 ) == '[11]'
            RE->ReDificu :=  Val( RTrim( SubStr(mReceta,5,At(cSepara,mReceta ) -5 ) ) )
         CASE SubStr( mReceta, 1, 4 ) == '[12]'
            RE->RePrecio :=  Val( RTrim( SubStr(mReceta,5,At(cSepara,mReceta ) -5 ) ) )
         CASE SubStr( mReceta, 1, 4 ) == '[13]'
            RE->RePPC    :=  Val( RTrim( SubStr(mReceta,5,At(cSepara,mReceta ) -5 ) ) )
         CASE SubStr( mReceta, 1, 4 ) == '[14]'
            RE->ReCalori :=  Val( RTrim( SubStr(mReceta,5,At(cSepara,mReceta ) -5 ) ) )
         CASE SubStr( mReceta, 1, 4 ) == '[15]'
            RE->ReTrucos := SubStr( mReceta, 5, At( cSepara,mReceta ) -5 )
         CASE SubStr( mReceta, 1, 4 ) == '[16]'
            RE->ReVino   := SubStr( mReceta, 5, At( cSepara,mReceta ) -5 )
         CASE SubStr( mReceta, 1, 4 ) == '[17]'
            RE->RePublica  :=  RTrim( SubStr( mReceta,5,At(cSepara,mReceta ) -5 ) )
         CASE SubStr( mReceta, 1, 4 ) == '[18]'
            RE->ReAutor    :=  RTrim( SubStr( mReceta,5,At(cSepara,mReceta ) -5 ) )
         CASE SubStr( mReceta, 1, 4 ) == '[19]'
            RE->ReEmail    :=  RTrim( SubStr( mReceta,5,At(cSepara,mReceta ) -5 ) )
         CASE SubStr( mReceta, 1, 4 ) == '[20]'
            RE->RePais     :=  RTrim( SubStr( mReceta,5,At(cSepara,mReceta ) -5 ) )
         CASE SubStr( mReceta, 1, 4 ) == '[21]'
            RE->ReNumero   :=  Val( RTrim( SubStr(mReceta,5,At(cSepara,mReceta ) -5 ) ) )
         CASE SubStr( mReceta, 1, 4 ) == '[22]'
            RE->RePagina   :=  Val( RTrim( SubStr(mReceta,5,At(cSepara,mReceta ) -5 ) ) )
         CASE SubStr( mReceta, 1, 4 ) == '[25]'
            RE->ReEscan    :=  Val( RTrim( SubStr(mReceta,5,At(cSepara,mReceta ) -5 ) ) )
         CASE SubStr( mReceta, 1, 4 ) == '[26]'
            RE->ReFchPrep  :=  CToD( RTrim( SubStr(mReceta,5,At(cSepara,mReceta ) -5 ) ) )
         CASE SubStr( mReceta, 1, 4 ) == '[27]'
            RE->ReValorac  :=  RTrim( SubStr( mReceta,5,At(cSepara,mReceta ) -5 ) )
         CASE SubStr( mReceta, 1, 4 ) == '[28]'
            RE->ReUsuario  :=  RTrim( SubStr( mReceta,5,At(cSepara,mReceta ) -5 ) )
         CASE SubStr( mReceta, 1, 4 ) == '[29]'
            RE->ReComEsc   :=  Val( RTrim( SubStr(mReceta,5,At(cSepara,mReceta ) -5 ) ) )
         CASE SubStr( mReceta, 1, 4 ) == '[30]'
            DO WHILE Val( SubStr( mReceta,2,2 ) ) > 29 .AND. Val( SubStr( mReceta,2,2 ) ) < 60
               DO CASE
               CASE SubStr( mReceta, 1, 4 ) == '[30]'
                  SELECT ES
                  ES->( dbAppend() )
                  REPLACE ES->EsReceta   WITH  RTrim( SubStr( mReceta,5,At(cSepara,mReceta ) -5 ) )
               CASE SubStr( mReceta, 1, 4 ) == '[31]'
                  REPLACE ES->EsUsuario  WITH  RTrim( SubStr( mReceta,5,At(cSepara,mReceta ) -5 ) )
               CASE SubStr( mReceta, 1, 4 ) == '[32]'
                  REPLACE ES->EsIngred   WITH  RTrim( SubStr( mReceta,5,At(cSepara,mReceta ) -5 ) )
               CASE SubStr( mReceta, 1, 4 ) == '[33]'
                  REPLACE ES->EsCantidad WITH  Val( RTrim( SubStr(mReceta,5,At(cSepara,mReceta ) -5 ) ) )
               CASE SubStr( mReceta, 1, 4 ) == '[34]'
                  REPLACE ES->EsUnidad   WITH  SubStr( mReceta, 5, At( cSepara,mReceta ) -5 )
               CASE SubStr( mReceta, 1, 4 ) == '[35]'
                  REPLACE ES->EsPrecio   WITH  Val( RTrim( SubStr(mReceta,5,At(cSepara,mReceta ) -5 ) ) )
               CASE SubStr( mReceta, 1, 4 ) == '[36]'
                  REPLACE ES->EsIndenomi WITH  SubStr( mReceta, 5, At( cSepara,mReceta ) -5 )
               CASE SubStr( mReceta, 1, 4 ) == '[37]'
                  REPLACE ES->EsKCal     WITH  Val( SubStr( mReceta,5,At(cSepara,mReceta ) -5 ) )
               CASE SubStr( mReceta, 1, 4 ) == '[40]'
                  SELECT AL
                  AL->( dbSetOrder( 3 ) )
                  AL->( dbGoTop() )
                  IF ! AL->( dbSeek( RTrim(SubStr(mReceta,5,At(cSepara,mReceta ) -5 ) ) ) )
                     AL->( dbAppend() )
                     REPLACE AL->AlCodigo WITH  RTrim( SubStr( mReceta,5,At(cSepara,mReceta ) -5 ) )
                     lAlAppend := .T.
                  ELSE
                     lAlAppend := .F.
                  ENDIF
               CASE SubStr( mReceta, 1, 4 ) == '[41]' .AND. lAlAppend
                  REPLACE AL->AlTipo   WITH  RTrim( SubStr( mReceta,5,At(cSepara,mReceta ) -5 ) )
               CASE SubStr( mReceta, 1, 4 ) == '[42]' .AND. lAlAppend
                  REPLACE AL->AlAlimento WITH  RTrim( SubStr( mReceta,5,At(cSepara,mReceta ) -5 ) )
               CASE SubStr( mReceta, 1, 4 ) == '[43]' .AND. lAlAppend
                  REPLACE AL->AlUnidad WITH  RTrim( SubStr( mReceta,5,At(cSepara,mReceta ) -5 ) )
               CASE SubStr( mReceta, 1, 4 ) == '[44]' .AND. lAlAppend
                  REPLACE AL->AlPrecio WITH  Val( RTrim( SubStr(mReceta,5,At(cSepara,mReceta ) -5 ) ) )
               CASE SubStr( mReceta, 1, 4 ) == '[45]' .AND. lAlAppend
                  REPLACE AL->AlUltCom WITH CToD( RTrim( SubStr(mReceta,5,At(cSepara,mReceta ) -5 ) ) )
               CASE SubStr( mReceta, 1, 4 ) == '[46]' .AND. lAlAppend
                  REPLACE AL->AlKCal   WITH  Val( RTrim( SubStr(mReceta,5,At(cSepara,mReceta ) -5 ) ) )
               CASE SubStr( mReceta, 1, 4 ) == '[47]' .AND. lAlAppend
                  REPLACE AL->AlProt   WITH  Val( RTrim( SubStr(mReceta,5,At(cSepara,mReceta ) -5 ) ) )
               CASE SubStr( mReceta, 1, 4 ) == '[48]' .AND. lAlAppend
                  REPLACE AL->AlHC     WITH  Val( RTrim( SubStr(mReceta,5,At(cSepara,mReceta ) -5 ) ) )
               CASE SubStr( mReceta, 1, 4 ) == '[49]' .AND. lAlAppend
                  REPLACE AL->AlGT     WITH  Val( RTrim( SubStr(mReceta,5,At(cSepara,mReceta ) -5 ) ) )
               CASE SubStr( mReceta, 1, 4 ) == '[50]' .AND. lAlAppend
                  REPLACE AL->AlGS     WITH  Val( RTrim( SubStr(mReceta,5,At(cSepara,mReceta ) -5 ) ) )
               CASE SubStr( mReceta, 1, 4 ) == '[51]' .AND. lAlAppend
                  REPLACE AL->AlGMI    WITH  Val( RTrim( SubStr(mReceta,5,At(cSepara,mReceta ) -5 ) ) )
               CASE SubStr( mReceta, 1, 4 ) == '[52]' .AND. lAlAppend
                  REPLACE AL->AlGPI    WITH  Val( RTrim( SubStr(mReceta,5,At(cSepara,mReceta ) -5 ) ) )
               CASE SubStr( mReceta, 1, 4 ) == '[53]' .AND. lAlAppend
                  REPLACE AL->AlCol    WITH  Val( RTrim( SubStr(mReceta,5,At(cSepara,mReceta ) -5 ) ) )
               CASE SubStr( mReceta, 1, 4 ) == '[54]' .AND. lAlAppend
                  REPLACE AL->AlFib    WITH  Val( RTrim( SubStr(mReceta,5,At(cSepara,mReceta ) -5 ) ) )
               CASE SubStr( mReceta, 1, 4 ) == '[55]' .AND. lAlAppend
                  REPLACE AL->AlNa     WITH  Val( RTrim( SubStr(mReceta,5,At(cSepara,mReceta ) -5 ) ) )
               CASE SubStr( mReceta, 1, 4 ) == '[56]' .AND. lAlAppend
                  REPLACE AL->AlCa     WITH  Val( RTrim( SubStr(mReceta,5,At(cSepara,mReceta ) -5 ) ) )
               ENDCASE
               IF At( cSepara, mReceta ) != 0
                  mReceta := SubStr( mReceta, At( cSepara,mReceta ) + 5, Len( mReceta ) -At( cSepara,mReceta ) -4 )
               ELSE
                  mReceta := ''
               ENDIF
            ENDDO
            LOOP  // Para que me coja la imagen
         CASE SubStr( mReceta, 1, 4 ) == '[60]'
            REPLACE RE->ReImagen  WITH  RTrim( SubStr( mReceta,5,At(cSepara,mReceta ) -5 ) )
         CASE SubStr( mReceta, 1, 4 ) == '[61]'
            REPLACE RE->ReMultip  WITH  Val( RTrim( SubStr(mReceta,5,At(cSepara,mReceta ) -5 ) ) )
         CASE SubStr( mReceta, 1, 4 ) == '[62]'
            REPLACE RE->RePFinal  WITH  Val( RTrim( SubStr(mReceta,5,At(cSepara,mReceta ) -5 ) ) )
         CASE SubStr( mReceta, 1, 4 ) == '[63]'
            REPLACE RE->ReReferen WITH  RTrim( SubStr( mReceta,5,At(cSepara,mReceta ) -5 ) )
         CASE SubStr( mReceta, 1, 4 ) == '[64]'
            REPLACE RE->ReAnotaci WITH  RTrim( SubStr( mReceta,5,At(cSepara,mReceta ) -5 ) )
         CASE SubStr( mReceta, 1, 4 ) == '[65]'
            REPLACE RE->ReVaOrden WITH  Val( RTrim( SubStr(mReceta,5,At(cSepara,mReceta ) -5 ) ) )
         CASE SubStr( mReceta, 1, 4 ) == '[66]'
            REPLACE RE->ReFrTipo WITH  RTrim( SubStr( mReceta,5,At(cSepara,mReceta ) -5 ) )
         CASE SubStr( mReceta, 1, 4 ) == '[67]'
            REPLACE RE->ReFrCargo WITH  RTrim( SubStr( mReceta,5,At(cSepara,mReceta ) -5 ) )
         ENDCASE
         // RE->(DbCommit())
         IF At( cSepara, mReceta ) != 0
            mReceta := SubStr( mReceta, At( cSepara,mReceta ) + 5, Len( mReceta ) -At( cSepara,mReceta ) -4 )
         ELSE
            mReceta := ''
         ENDIF
         mReceta := LTrim( mReceta )
      ENDDO
      SELECT RE
      RE->( dbCommit() )
      ReEdita( oGrid, 2, oCont, oDlg )

   ENDIF

   oApp():nEdit--

RETURN NIL
//_____________________________________________________________________________//

FUNCTION ReXPegar( oGrid, oCont, oParent )

   LOCAL mReceta   := ''
   LOCAL cLinea    := ''
   LOCAL lOk       := .F.
   LOCAL lAlAppend := .F.
   LOCAL oDlg, oClp, oMemo, oBtnOk, oBtnCancel
   LOCAL nLines, Linea, i, cField, nField, cData
   LOCAL lReceta     := .F.
   LOCAL lEscandallo := .F.
   LOCAL lRecord     := .F.
   LOCAL aReFields   := Array( RE->( FCount() ) )
   LOCAL aEsFields   := Array( ES->( FCount() ) )

   oApp():nEdit++

   DEFINE DIALOG oDlg RESOURCE 'RE_CLIPB2_' + oApp():cLanguage OF oParent
   oDlg:SetFont( oApp():oFont )

   DEFINE CLIPBOARD oClp OF oDlg
   mReceta := oClp:GetText()

   REDEFINE GET oMemo VAR mReceta  ID 101 MEMO OF oDlg COLOR CLR_BLACK, CLR_WHITE
   oMemo:bGotFocus := {|| oBtnOk:SetFocus() }

   REDEFINE BUTTON oBtnOk         ;
      ID IDOK OF oDlg             ;
      ACTION ( lOk := .T., oDlg:End() )

   REDEFINE BUTTON oBtnCancel     ;
      ID IDCANCEL OF oDlg         ;
      ACTION oDlg:End()

   ACTIVATE DIALOG oDlg ON INIT DlgCenter( oDlg, oApp():oWndMain )

   IF lOk
      RE->( ordSetFocus( 2 ) )
      ES->( ordSetFocus( 3 ) )
      nLines := MLCount( mReceta )
      i := 0
      WHILE i < nLines
         i++
         Linea := AllTrim( MemoLine( mReceta,,i, ) )
         IF Linea == "<Receta>"
            SELECT RE
            lReceta := .T.
            lRecord := .T.
         ELSEIF Linea == "<Ingrediente>"
            SELECT ES
            lReceta := .F.
            lRecord := .T.
         ELSEIF Linea == "</Receta>"
            RE->( ordSetFocus( 2 ) )
            RE->( dbGoTop() )
            IF ! RE->( dbSeek( Upper(aReFields[ 1 ] ) ) )
               Db_Gather( aReFields, 'RE', .T. )
            ELSE
               MsgInfo( 'La receta ' + aReFields[ 1 ] + ' ' + aReFields[ 2 ] + ' ya existe.', 'Información' )
               oApp():nEdit--
               RETU NIL
            ENDIF
            lRecord := .F.
         ELSEIF Linea == "</Ingrediente>"
            SELECT ES
            ES->( ordSetFocus( 3 ) )
            ES->( dbGoTop() )
            IF ! ES->( dbSeek( Upper(aEsFields[ 1 ] + Space(10 -Len(aEsFields[ 1 ] ) ) + aEsFields[ 3 ] + Space(6 -Len(aEsFields[ 1 ] ) ) ) ) )
               Db_Gather( aEsFields, 'ES', .T. )
            ELSE
               MsgInfo( 'El Ingrediente ' + aEsFields[ 1 ] + ' ' + aEsFields[ 3 ] + ' ya existe.', 'Información' )
               // retu nil
            ENDIF
            lRecord := .F.
         ELSEIF lRecord == .T.
            cField := hb_AtX( "<[^>]*>", Linea, .F. )
            cField := SubStr( cField, 2, Len( cField ) -2 )
            IF cField == 'REINGRED'
               cData := ''
               Linea := StrTran( Linea, '<REINGRED>', '' )
               DO WHILE At( "</REINGRED>", Linea ) == 0
                  cData := cData + Linea
                  i++
                  Linea := AllTrim( MemoLine( mReceta,,i, ) )
               ENDDO
               Linea := StrTran( Linea, '</REINGRED>', '' )
               cData := cData + Linea
            ELSEIF cField == 'REPREPAR'
               cData := ''
               Linea := StrTran( Linea, '<REPREPAR>', '' )
               DO WHILE At( "</REPREPAR>", Linea ) == 0
                  cData := cData + Linea
                  i++
                  Linea := AllTrim( MemoLine( mReceta,,i, ) )
               ENDDO
               Linea := StrTran( Linea, '</REPREPAR>', '' )
               cData := cData + Linea
            ELSEIF cField == 'RETRUCOS'
               cData := ''
               Linea := StrTran( Linea, '<RETRUCOS>', '' )
               DO WHILE At( "</RETRUCOS>", Linea ) == 0
                  cData := cData + Linea
                  i++
                  Linea := AllTrim( MemoLine( mReceta,,i, ) )
               ENDDO
               Linea := StrTran( Linea, '</RETRUCOS>', '' )
               cData := cData + Linea
            ELSEIF cField == 'REVINO'
               cData := ''
               Linea := StrTran( Linea, '<REVINO>', '' )
               DO WHILE At( "</REVINO>", Linea ) == 0
                  cData := cData + Linea
                  i++
                  Linea := AllTrim( MemoLine( mReceta,,i, ) )
               ENDDO
               Linea := StrTran( Linea, '</REVINO>', '' )
               cData := cData + Linea
            ELSE
               cData  := hb_AtX( ">[^<]*<", Linea, .F. )
               cData := SubStr( cData, 2, Len( cData ) -2 )
            ENDIF
            nField := FieldPos( cField )
            IF lReceta == .T.
               IF FieldType( nField ) == 'D'
                  aReFields[ nField ] := CToD( cData )
               ELSEIF FieldType( nField ) == 'N'
                  aReFields[ nField ] := Val( cData )
               ELSEIF FieldType( nField ) == 'L'
                  aReFields[ nField ] :=  iif( cData == "True", .T., .F. )
               ELSE
                  aReFields[ nField ] := cData
               ENDIF
            ELSE
               IF FieldType( nField ) == 'D'
                  aEsFields[ nField ] := CToD( cData )
               ELSEIF FieldType( nField ) == 'N'
                  aEsFields[ nField ] := Val( cData )
               ELSEIF FieldType( nField ) == 'L'
                  aEsFields[ nField ] :=  iif( cData == "True", .T., .F. )
               ELSE
                  aEsFields[ nField ] := cData
               ENDIF
            ENDIF
         ENDIF
      ENDDO
      SELECT RE
      RE->( dbCommit() )
      ReEdita( oGrid, 2, oCont, oDlg )
   ENDIF

   oApp():nEdit--

RETURN NIL
//_____________________________________________________________________________//

FUNCTION ReClave( cReceta, oGet, nMode, nField, aGet )

   // nMode    1 nuevo registro
   //          2 modificación de registro
   //          3 duplicación de registro
   //          4 clave ajena
   // nField   1 ReTitulo
   //          2 ReCodigo
   LOCAL lreturn  := .F.
   LOCAL nRecno   := RE->( RecNo() )
   LOCAL nOrder   := RE->( ordNumber() )
   LOCAL nArea    := Select()
   LOCAL aTPlato   := { 'Entradas', '1er Plato', '2o Plato', 'Postre', 'Dulce', 'Otro' }

   IF Empty( cReceta )
      IF nMode == 4
         // MsgStop("Es obligatorio rellenar este campo.")
         lReturn := ReSelAjena( @cReceta, oGet, 4, 2, aGet )
         RETURN lReturn
      ENDIF
   ENDIF

   SELECT RE
   IF nField == 1
      RE->( dbSetOrder( 1 ) )
   ELSE
      RE->( dbSetOrder( 2 ) )
   ENDIF

   RE->( dbGoTop() )

   IF RE->( dbSeek( Upper( cReceta ) ) )
      DO CASE
      CASE nMode == 1 .OR. nMode == 3
         lreturn := .F.
         IF nField == 1
            MsgStop( "Receta existente.", 'Atención' )
         ELSE
            MsgStop( "Código de receta existente.", 'Atención' )
         ENDIF
      CASE nMode == 2
         IF RE->( RecNo() ) == nRecno
            lreturn := .T.
         ELSE
            lreturn := .F.
            IF nField == 1
               MsgStop( "Receta existente.", 'Atención' )
            ELSE
               MsgStop( "Código de receta existente.", 'Atención' )
            ENDIF
         ENDIF
      CASE nMode == 4
         lreturn := .T.
         IF aGet != Nil
            aGet[ 2 ]:ctext := RE->ReTitulo
            aGet[ 3 ]:cText := aTPlato[ Max( Val( RE->RePlato ), 1 ) ]
            aGet[ 4 ]:cText := RE->ReTipo
         ENDIF
         IF ! oApp():thefull
            Registrame()
         ENDIF
      END CASE
   ELSE
      IF nMode < 4
         lreturn := .T.
         // cambio el código en el escandallo

      ELSE
         IF nField == 1
            MsgStop( "Receta inexistente.", 'Atención' )
         ELSE
            MsgStop( "Código de receta inexistente.", 'Atención' )
         ENDIF
         lReturn := ReSelAjena( @cReceta, oGet, 4, 2, aGet )
      ENDIF
   ENDIF

   IF lreturn == .F.
      IF nField == 1
         oGet:cText( Space( 60 ) )
      ELSE
         oGet:cText( Space( 10 ) )
      ENDIF
   ENDIF

   RE->( dbSetOrder( nOrder ) )
   RE->( dbGoto( nRecno ) )

   SELECT ( nArea )

RETURN lreturn
/*_____________________________________________________________________________*/

FUNCTION ReImprime( oGrid, oParent )

   LOCAL nLen     := 29 // nº de campos a mostrar
   LOCAL aTitulos := { "Código", "Receta", "Categoría", "Tipo de plato", "Tipo de cocinado", "C. Francesa", ;
      "Ing. Principal", "Epoca", "Dificultad", "Calorias", "Comensales", "Tiempo prep.", ;
      "Precio Estimado", "Precio Est./ Comensal", "Publicación", "Número", "Página", ;
      "Autor", "Pais", "E-mail", "Referencia", "Anotación", ;
      "Precio Escandallo", "Multiplicador", "Precio Final", "Com. escandallo", "Fch.Preparación", ;
      "Valoración", "Fichero inc.", "Usuario inc.", "Fecha inc."  }
   LOCAL aCampos  := { "RECODIGO", "RETITULO", "REPLATO", "RETIPO", "RETIPOCOC", "REFRTIPO", ;
      "REINGPRI", "REEPOCA", "REDifICU", "RECALORI", "RECOMENS", "RETIEMPO", ;
      "REPRECIO", "REPPC", "REPUBLICA", "RENUMERO", "REPAGINA", ;
      "REAUTOR", "REPAIS", "REEMAIL", "REREFEREN", "REANOTACI", ;
      "REESCAN", "REMULTIP", "REPFINAL", "RECOMESC", "REFCHPREP", ;
      "REVALORAC", "REFICHERO", "REUSUARIO", "REFCHINCO" }
   LOCAL aWidth   := { 10, 40, 10, 20, 20, 20, 10, 10, 10, 10, 10, 10, ;
      10, 10, 10, 10, 10, 20, 10, 10, 10, 10, ;
      10, 10, 10, 10, 10, 10, 10, 10, 10  }
   LOCAL aShow    := { .T., .T., .T., .T., .T., .T., .T., .T., .T., .T., .T., .T., ;
      .T., .T., .T., .T., .T., .T., .T., .T., .T., .T., ;
      .T., .T., .T., .T., .T., .T., .T., .T., .T. }
   LOCAL aPicture := { "NO", "NO", "RE01", "NO", "NO", "NO", "NO", "RE02", "RE03", "RE04", "@E 99", "NO", ;
      "@E 999,999.99", "@E 999,999.99", "NO", "@E 9,999", "@E 9,999", "NO", "NO", "NO", "NO", "NO", ;
      "@E 999,999.99", "@E 99.99", "@E 999,999.99", "@E 99", "NO", "NO", "NO", "NO", "NO" }
   LOCAL aTotal   := { .F., .F., .F., .F., .F., .F., .F., .F., .F., .F., .F., .F., ;
      .T., .T., .F., .F., .F., .F., .F., .F., .F., .F., ;
      .T., .F., .T., .T., .T., .F., .F., .F., .F. }
   LOCAL oInforme
   LOCAL nReOrder := RE->( ordNumber() )
   LOCAL nReRecno := RE->( RecNo() )
   LOCAL nPlOrder := PL->( ordNumber() )
   LOCAL nPlRecno := PL->( RecNo() )
   LOCAL aTiPlatos := { 'En ', '1P ', '2P ', 'Po ', 'Du ', 'Co ' }
   LOCAL aTPlatos := {}
   LOCAL cTPlatos
   LOCAL aTCocina := {}
   LOCAL cTCocina
   LOCAL nFrOrder := FR->( ordNumber() )
   LOCAL nFrRecno := FR->( RecNo() )
   LOCAL aFrances := {}
   LOCAL cFrances
   LOCAL nIpOrder := IP->( ordNumber() )
   LOCAL nIpRecno := IP->( RecNo() )
   LOCAL aIngPri  := {}
   LOCAL cIngPri
   LOCAL nVaOrder := VA->( ordNumber() )
   LOCAL nVaRecno := VA->( RecNo() )
   LOCAL aValorac := {}
   LOCAL cValorac
   LOCAL nAuOrder := AU->( ordNumber() )
   LOCAL nAuRecno := AU->( RecNo() )
   LOCAL aAutor   := {}
   LOCAL cAutor
   LOCAL nPuOrder := PU->( ordNumber() )
   LOCAL nPuRecno := PU->( RecNo() )
   LOCAL aPublica := {}
   LOCAL cPublica
   LOCAL aGet[ 2 ]
   LOCAL dInicio  := CToD( '' )
   LOCAL dFinal   := Date()
   LOCAL lImagen  := .F.
   LOCAL oComPl, oComCo, oComIp, oComFr, oComVa, oComAu, oComPu
   LOCAL oBtn1, oBtn2, oCheck

   oApp():nEdit++

   // cargo los tipos de plato
   PL->( dbSetOrder( 1 ) )
   PL->( dbGoTop() )
   DO WHILE ! PL->( Eof() )
      IF PL->PlPlato $ "12345"
         AAdd( aTPlatos, aTiPlatos[ Val( PL->PlPlato ) ] + PL->PlTipo )
      ELSE
         AAdd( aTCocina, PL->PlTipo )
      ENDIF
      PL->( dbSkip() )
   ENDDO
   PL->( dbSetOrder( nPlOrder ) )
   PL->( dbGoto( nPlRecno ) )

   cTPlatos := iif( Len( aTPlatos ) > 0, aTPlatos[ 1 ], ' ' )
   cTCocina := iif( Len( aTCocina ) > 0, aTCocina[ 1 ], ' ' )

   // cargo el ingrediente principal
   IP->( dbSetOrder( 1 ) )
   IP->( dbGoTop() )
   DO WHILE ! IP->( Eof() )
      AAdd( aIngPri, IP->IpIngred )
      IP->( dbSkip() )
   ENDDO
   IP->( dbSetOrder( nIpOrder ) )
   IP->( dbGoto( nFrRecno ) )
   cIngPri := iif( Len( aIngPri ) > 0, aIngPri[ 1 ], ' ' )

   // cargo la clasificación francesa
   FR->( dbSetOrder( 1 ) )
   FR->( dbGoTop() )
   DO WHILE ! FR->( Eof() )
      AAdd( aFrances, FR->FrTipo )
      FR->( dbSkip() )
   ENDDO
   FR->( dbSetOrder( nFrOrder ) )
   FR->( dbGoto( nFrRecno ) )
   cFrances := iif( Len( aFrances ) > 0, aFrances[ 1 ], ' ' )

   // cargo la valoración de recetas
   VA->( dbSetOrder( 1 ) )
   VA->( dbGoTop() )
   DO WHILE ! VA->( Eof() )
      AAdd( aValorac, VA->VaValorac )
      VA->( dbSkip() )
   ENDDO
   VA->( dbSetOrder( nVaOrder ) )
   VA->( dbGoto( nVaRecno ) )
   cValorac := iif( Len( aValorac ) > 0, aValorac[ 1 ], ' ' )

   // cargo los autores de recetas
   AU->( dbSetOrder( 1 ) )
   AU->( dbGoTop() )
   DO WHILE ! AU->( Eof() )
      AAdd( aAutor, AU->AuNombre )
      AU->( dbSkip() )
   ENDDO
   AU->( dbSetOrder( nAuOrder ) )
   AU->( dbGoto( nAuRecno ) )
   cAutor   := iif( Len( aAutor ) > 0, aAutor[ 1 ], ' ' )

   // cargo las publicaciones de recetas
   PU->( dbSetOrder( 1 ) )
   PU->( dbGoTop() )
   DO WHILE ! PU->( Eof() )
      AAdd( aPublica, PU->PuNombre )
      PU->( dbSkip() )
   ENDDO
   PU->( dbSetOrder( nPuOrder ) )
   PU->( dbGoto( nPuRecno ) )
   cPublica := iif( Len( aPublica ) > 0, aPublica[ 1 ], ' ' )

   // comienza el informe
   oInforme := TInforme():New( aCampos, aTitulos, aWidth, aShow, aPicture, aTotal, "RE" )
   oInforme:Dialog()

   REDEFINE RADIO oInforme:oRadio VAR oInforme:nRadio ;
      ID 300, 301, 302, 325, 303, 304, 305, 306, 307, 308, 309, 310 OF oInforme:oFld:aDialogs[ 1 ]

   REDEFINE COMBOBOX oComPl VAR cTPlatos ITEMS aTPlatos ;
      WHEN oInforme:nRadio == 2 ID 311 OF oInforme:oFld:aDialogs[ 1 ]

   REDEFINE COMBOBOX oComCo VAR cTCocina ITEMS aTCocina ;
      WHEN oInforme:nRadio == 3 ID 312 OF oInforme:oFld:aDialogs[ 1 ]

   REDEFINE COMBOBOX oComIp VAR cIngPri ITEMS aIngPri ;
      WHEN oInforme:nRadio == 4 ID 324 OF oInforme:oFld:aDialogs[ 1 ]

   REDEFINE COMBOBOX oComFr VAR cFrances ITEMS aFrances ;
      WHEN oInforme:nRadio == 5 ID 313 OF oInforme:oFld:aDialogs[ 1 ]

   REDEFINE COMBOBOX oComVa VAR cValorac ITEMS aValorac ;
      WHEN oInforme:nRadio == 6 ID 314 OF oInforme:oFld:aDialogs[ 1 ]

   REDEFINE COMBOBOX oComAu VAR cAutor ITEMS aAutor ;
      WHEN oInforme:nRadio == 7 ID 315 OF oInforme:oFld:aDialogs[ 1 ]

   REDEFINE COMBOBOX oComPu VAR cPublica ITEMS aPublica ;
      WHEN oInforme:nRadio == 8 ID 316 OF oInforme:oFld:aDialogs[ 1 ]

   REDEFINE SAY ID 317 OF oInforme:oFld:aDialogs[ 1 ]
   REDEFINE SAY ID 319 OF oInforme:oFld:aDialogs[ 1 ]

   REDEFINE GET aGet[ 1 ] VAR dInicio       ;
      ID 318 OF oInforme:oFld:aDialogs[ 1 ] UPDATE   ;
      WHEN oInforme:nRadio == 9

   REDEFINE BUTTON oBtn1                  ;
      ID 322 OF oInforme:oFld:aDialogs[ 1 ]          ;
      ACTION SelecFecha( dInicio, aGet[ 1 ] ) ;
      WHEN oInforme:nRadio == 9
   oBtn1:cTooltip := i18n( "seleccionar fecha" )

   REDEFINE GET aGet[ 2 ] VAR dFinal        ;
      ID 320 OF oInforme:oFld:aDialogs[ 1 ] UPDATE   ;
      WHEN oInforme:nRadio == 9

   REDEFINE BUTTON oBtn2                  ;
      ID 323 OF oInforme:oFld:aDialogs[ 1 ]          ;
      ACTION SelecFecha( dFinal, aGet[ 2 ] ) ;
      WHEN oInforme:nRadio == 9
   oBtn2:cTooltip := i18n( "seleccionar fecha" )

   REDEFINE CHECKBOX oCheck VAR lImagen   ;
      ID 321 OF oInforme:oFld:aDialogs[ 1 ] WHEN oInforme:nRadio == 11

   oInforme:Folders()

   IF oInforme:Activate()
      SELECT RE
      RE->( ordSetFocus( 1 ) )
      IF oInforme:nRadio < 11
         RE->( dbGoTop() )
      ENDIF
      IF oInforme:nRadio != 11 .AND. oInforme:nRadio != 12
         oInforme:Report()
      ELSE
         oInforme:oFont1 := TFont():New( RTrim( oInforme:acFont[ 1 ] ), 0, Val( oInforme:acSizes[ 1 ] ),, ( i18n("Negrita" ) $ oInforme:acEstilo[ 1 ] ),,,, ( i18n("Cursiva" ) $ oInforme:acEstilo[ 1 ] ),,,,,,, )
         oInforme:oFont2 := TFont():New( RTrim( oInforme:acFont[ 2 ] ), 0, Val( oInforme:acSizes[ 2 ] ),, ( i18n("Negrita" ) $ oInforme:acEstilo[ 2 ] ),,,, ( i18n("Cursiva" ) $ oInforme:acEstilo[ 2 ] ),,,,,,, )
         oInforme:oFont3 := TFont():New( RTrim( oInforme:acFont[ 3 ] ), 0, Val( oInforme:acSizes[ 3 ] ),, ( i18n("Negrita" ) $ oInforme:acEstilo[ 3 ] ),,,, ( i18n("Cursiva" ) $ oInforme:acEstilo[ 3 ] ),,,,,,, )
         IF oInforme:nDevice == 1
            REPORT oInforme:oReport ;
               TITLE  ' ', RE->ReCodigo + ' ' + RTrim( RE->ReTitulo ), ' ' CENTERED;
               FONT   oInforme:oFont3, oInforme:oFont2, oInforme:oFont1 ;
               HEADER ' ', oApp():cAppName + oApp():cVersion, oApp():cUser   ;
               FOOTER ' ', "Fecha: " + DToC( Date() ) + "   Página.: " + Str( oInforme:oReport:nPage, 3 ) ;
               CAPTION oApp():cAppName + oApp():cVersion PREVIEW
         ELSE
            REPORT oInforme:oReport ;
               TITLE  ' ', RE->ReCodigo + ' ' + RTrim( RE->ReTitulo ), ' ' CENTERED;
               FONT   oInforme:oFont3, oInforme:oFont2, oInforme:oFont1 ;
               HEADER ' ', oApp():cAppName + oApp():cVersion, oApp():cUser   ;
               FOOTER ' ', "Fecha: " + DToC( Date() ) + "   Página.: " + Str( oInforme:oReport:nPage, 3 ) ;
               CAPTION oApp():cAppName + oApp():cVersion
         ENDIF
         COLUMN TITLE " "  DATA Space( 1 ) FONT 1 SIZE 10
         COLUMN TITLE " "  DATA Space( 1 ) FONT 1 SIZE 10
         COLUMN TITLE " "  DATA Space( 1 ) FONT 1 SIZE 10
         COLUMN TITLE " "  DATA Space( 1 ) FONT 1 SIZE 10
         COLUMN TITLE " "  DATA Space( 1 ) FONT 1 SIZE 10
         COLUMN TITLE " "  DATA Space( 1 ) FONT 1 SIZE 10
         COLUMN TITLE " "  DATA Space( 1 ) FONT 1 SIZE 10
         COLUMN TITLE " "  DATA Space( 1 ) FONT 1 SIZE 10
         RptEnd()
         oInforme:oReport:Cargo := AllTrim( RE->ReTitulo ) + ".pdf"
         IF oInforme:oReport:lCreated
            oInforme:oReport:nTitleUpLine := RPT_NOLINE
            oInforme:oReport:nTitleDnLine := RPT_NOLINE
         ENDIF
         oInforme:oReport:oTitle:aFont[ 2 ] := {|| 3 }
         oInforme:oReport:oTitle:aFont[ 3 ] := {|| 2 }
         oInforme:oReport:nTopMargin   := 0.1
         oInforme:oReport:nDnMargin    := 0.1
         oInforme:oReport:oDevice:lPrvModal := .T.
         oInforme:oReport:nLeftMargin  := 0.4
         oInforme:oReport:nRightMargin := 0.4
      ENDIF

      DO CASE
      CASE oInforme:nRadio == 1
         ACTIVATE REPORT oInforme:oReport ; // FOR PL->PlPlato == cPlPlato;
         ON END ( oInforme:oReport:StartLine(), oInforme:oReport:EndLine(), oInforme:oReport:StartLine(), ;
            oInforme:oReport:Say( 1, 'Recetas: ' + Tran( oInforme:oReport:nCounter, '@E 999,999' ), 1 ), ;
            oInforme:oReport:EndLine() )
      CASE oInforme:nRadio == 2
         ACTIVATE REPORT oInforme:oReport FOR aTiPlatos[ Val( RE->RePlato ) ] == SubStr( cTPlatos, 1, 3 ) ;
            .AND. Upper( RTrim( RE->ReTipo ) ) == Upper( RTrim( SubStr(cTPlatos,4 ) ) );
            ON END ( oInforme:oReport:StartLine(), oInforme:oReport:EndLine(), oInforme:oReport:StartLine(), ;
            oInforme:oReport:Say( 1, 'Recetas: ' + Tran( oInforme:oReport:nCounter, '@E 999,999' ), 1 ), ;
            oInforme:oReport:EndLine() )
      CASE oInforme:nRadio == 3
         ACTIVATE REPORT oInforme:oReport FOR Upper( RTrim( RE->ReTipoCoc ) ) == Upper( RTrim( cTCocina ) )   ;
            ON END ( oInforme:oReport:StartLine(), oInforme:oReport:EndLine(), oInforme:oReport:StartLine(), ;
            oInforme:oReport:Say( 1, 'Recetas: ' + Tran( oInforme:oReport:nCounter, '@E 999,999' ), 1 ), ;
            oInforme:oReport:EndLine() )
      CASE oInforme:nRadio == 4
         ACTIVATE REPORT oInforme:oReport FOR Upper( RTrim( RE->ReIngPri ) ) == Upper( RTrim( cIngPri ) ) ;
            ON END ( oInforme:oReport:StartLine(), oInforme:oReport:EndLine(), oInforme:oReport:StartLine(), ;
            oInforme:oReport:Say( 1, 'Recetas: ' + Tran( oInforme:oReport:nCounter, '@E 999,999' ), 1 ), ;
            oInforme:oReport:EndLine() )
      CASE oInforme:nRadio == 5
         ACTIVATE REPORT oInforme:oReport FOR Upper( RTrim( RE->ReFrTipo ) ) == Upper( RTrim( cFrances ) ) ;
            ON END ( oInforme:oReport:StartLine(), oInforme:oReport:EndLine(), oInforme:oReport:StartLine(), ;
            oInforme:oReport:Say( 1, 'Recetas: ' + Tran( oInforme:oReport:nCounter, '@E 999,999' ), 1 ), ;
            oInforme:oReport:EndLine() )
      CASE oInforme:nRadio == 6
         ACTIVATE REPORT oInforme:oReport FOR Upper( RTrim( RE->ReValorac ) ) == Upper( RTrim( cValorac ) )   ;
            ON END ( oInforme:oReport:StartLine(), oInforme:oReport:EndLine(), oInforme:oReport:StartLine(), ;
            oInforme:oReport:Say( 1, 'Recetas: ' + Tran( oInforme:oReport:nCounter, '@E 999,999' ), 1 ), ;
            oInforme:oReport:EndLine() )
      CASE oInforme:nRadio == 7
         ACTIVATE REPORT oInforme:oReport FOR Upper( RTrim( RE->ReAutor ) ) == Upper( RTrim( cAutor ) ) ;
            ON END ( oInforme:oReport:StartLine(), oInforme:oReport:EndLine(), oInforme:oReport:StartLine(), ;
            oInforme:oReport:Say( 1, 'Recetas: ' + Tran( oInforme:oReport:nCounter, '@E 999,999' ), 1 ), ;
            oInforme:oReport:EndLine() )
      CASE oInforme:nRadio == 8
         ACTIVATE REPORT oInforme:oReport FOR Upper( RTrim( RE->RePublica ) ) == Upper( RTrim( cPublica ) ) ;
            ON END ( oInforme:oReport:StartLine(), oInforme:oReport:EndLine(), oInforme:oReport:StartLine(), ;
            oInforme:oReport:Say( 1, 'Recetas: ' + Tran( oInforme:oReport:nCounter, '@E 999,999' ), 1 ), ;
            oInforme:oReport:EndLine() )
      CASE oInforme:nRadio == 9
         ACTIVATE REPORT oInforme:oReport FOR dInicio < RE->ReFchPrep .AND. RE->ReFchPrep < dFinal ;
            ON END ( oInforme:oReport:StartLine(), oInforme:oReport:EndLine(), oInforme:oReport:StartLine(), ;
            oInforme:oReport:Say( 1, 'Recetas: ' + Tran( oInforme:oReport:nCounter, '@E 999,999' ), 1 ), ;
            oInforme:oReport:EndLine() )
      CASE oInforme:nRadio == 10
         ACTIVATE REPORT oInforme:oReport FOR RE->ReSelecc == 'X' ;
            ON END ( oInforme:oReport:StartLine(), oInforme:oReport:EndLine(), oInforme:oReport:StartLine(), ;
            oInforme:oReport:Say( 1, 'Recetas: ' + Tran( oInforme:oReport:nCounter, '@E 999,999' ), 1 ), ;
            oInforme:oReport:EndLine() )
      CASE oInforme:nRadio == 11
         RE->( dbGoto( nReRecno ) )
         ACTIVATE REPORT oInforme:oReport FOR RE->( RecNo() ) == nReRecno ;
            ON INIT ReImpReceta( RE->ReTitulo, oInforme:oReport, lImagen )
      CASE oInforme:nRadio == 12
         RE->( dbGoto( nReRecno ) )
         ACTIVATE REPORT oInforme:oReport FOR RE->( RecNo() ) == nReRecno ;
            ON INIT ReImpRecetaExpres( RE->ReTitulo, oInforme:oReport, lImagen )
      ENDCASE
      oInforme:End( .T. )
      RE->( dbSetOrder( nReOrder ) )
      RE->( dbGoto( nReRecno ) )
   ENDIF
   oApp():nEdit--
   oGrid:Refresh()
   oGrid:SetFocus( .T. )

RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION ReImpReceta( cReceta, oReport, lImagen )

   LOCAL aPlatos  := { 'Ensaladas', '1er Plato', '2o Plato', 'Postres', 'Dulce' }
   LOCAL aEpoca   := { '0000', '0001', '0010', '0011', '0100', '0101', '0110', '0111', ;
      '1000', '1001', '1010', '1011', '1100', '1101', '1110', '1111' }
   LOCAL aLEpoca  := { "   /   /   /   ", "   /   /   /Inv", "   /   /Oto/   ", "   /   /Oto/Inv", ;
      "   /Ver/   /   ", "   /Ver/   /Inv", "   /Ver/Oto/   ", "   /Ver/Oto/Inv", ;
      "Pri/   /   /   ", "Pri/   /   /Inv", "Pri/   /Oto/   ", "Pri/   /Oto/Inv", ;
      "Pri/Ver/   /   ", "Pri/Ver/   /Inv", "Pri/Ver/Oto/   ", "Pri/Ver/Oto/Inv" }
   LOCAL aDifi    := { 'Sencillo', 'Medio', 'Dificil' }
   LOCAL aCalori  := { 'Bajo', 'Medio', 'Alto' }
   LOCAL nSepara2 := Space( 06 )
   LOCAL nSepara4 := Space( 10 )
   LOCAL nSepara5 := Space( 18 )
   LOCAL oRbmp, nFilaBMP, nVert, nHorz, nSalto, i
   LOCAL oRImage, nFila, nFor, nLines, nReScan, nReKCal, nSize, nLine, nIni, cText, nReEscan, nLen

   IF ! Empty( RE->ReImagen ) .AND. lImagen
      IF Upper( Right( RTrim(RE->ReImagen ),3 ) ) == 'BMP'
         oRBmp := TBitmap():Define(, lfn2sfn( RTrim(RE->ReImagen ) ), )
         oReport:StartLine()
         oReport:Say( 1, 'Imagen', 2 )
         nFilaBmp := oReport:nRow / oReport:nStdLineHeight
         nHorz  := ( oRBmp:nWidth / oReport:nLogPixX ) * 3
         nVert  := ( oRBmp:nHeight / oReport:nLogPixY ) * 3
         nSalto := ( oRBmp:nHeight / oReport:nStdLineHeight ) * 3
         DO WHILE nHorz > 6
            nVert  := nVert  * 0.90
            nHorz  := nHorz  * 0.90
            nSalto := nSalto * 0.90
         ENDDO
         oReport:SayBitmap( ( nFilaBMP / 6 ) -0.1, 1.35, lfn2sfn( RTrim(RE->ReImagen ) ), nHorz, nVert, 1 )
         oRBmp:Destroy()
         oReport:EndLine()
         FOR i := 1 TO nSalto + 1
            oReport:StartLine()
            oReport:EndLine()
         NEXT
      ELSE
         oRImage := TImage():Define(, lfn2sfn( RTrim(RE->ReImagen ) ), )
         oReport:StartLine()
         oReport:Say( 1, 'Imagen', 2 )
         nFila  := oReport:nRow / oReport:nStdLineHeight
         nHorz  := ( oRImage:nWidth / oReport:nLogPixX ) * 3
         nVert  := ( oRImage:nHeight / oReport:nLogPixY ) * 3
         nSalto := ( oRImage:nHeight / oReport:nStdLineHeight ) * 3
         DO WHILE nHorz > 6
            nVert  := nVert  * 0.90
            nHorz  := nHorz  * 0.90
            nSalto := nSalto * 0.90
         ENDDO
         oReport:SayBitmap( ( nFila / 6 ) -0.1, 1.35, oRImage, nHorz, nVert, 1 )
         oRImage:Destroy()
         oReport:EndLine()
         FOR i := 1 TO nSalto + 1
            oReport:StartLine()
            oReport:EndLine()
         NEXT
      ENDIF
      oReport:EndLine()
      oReport:StartLine()
      oReport:Say( 2, RE->ReImagen, 1 )
   ENDIF
   oReport:EndLine()
   oReport:StartLine()
   oReport:EndLine()
   oReport:StartLine()
   oReport:Say( 1, 'Código:', 2 )
   oReport:Say( 2, nSepara2 + RE->ReCodigo, 1 )
   oReport:Say( 4, nSepara4 + 'Receta:', 2 )
   oReport:Say( 5, nSepara5 + RE->ReTitulo, 1 )
   oReport:EndLine()
   oReport:StartLine()
   oReport:Say( 1, 'Tipo de Plato:', 2 )
   oReport:Say( 2, nSepara2 + aPlatos[ Val( RE->RePlato ) ] + ' / ' + RTrim( RE->ReTipo ), 1 )
   oReport:Say( 4, nSepara4 + 'Tipo Cocinado:', 2 )
   oReport:Say( 5, nSepara5 + RE->ReTipoCoc, 1 )
   oReport:EndLine()
   oReport:StartLine()
   oReport:Say( 1, 'C. Francesa:', 2 )
   oReport:Say( 2, nSepara2 + RE->ReFrTipo, 1 )
   oReport:EndLine()
   oReport:StartLine()
   oReport:Say( 1, 'Dieta/Toleranc.:', 2 )
   oReport:Say( 2, nSepara2 + RE->ReDietas, 1 )
   oReport:EndLine()
   oReport:StartLine()
   oReport:Say( 4, nSepara4 + 'Epoca:', 2 )
   oReport:Say( 5, nSepara5 + aLEpoca[ AScan( aEpoca,StrTran(Str(RE->ReEpoca,4 ),' ','0' ) ) ], 1 )
   oReport:EndLine()
   oReport:StartLine()
   oReport:Say( 1, 'Tiempo:', 2 )
   oReport:Say( 2, nSepara2 + RE->ReTiempo, 1 )

   oReport:Say( 4, nSepara4 + 'Dificultad:', 2 )
   oReport:Say( 5, nSepara5 + aDifi[ RE->REDificu ], 1 )
   oReport:EndLine()
   oReport:StartLine()
   oReport:Say( 1, 'Precio Estim.:', 2 )
   oReport:Say( 2, nSepara2 + TRAN( RE->RePrecio,"@E 999,999.99" ), 1 )
   oReport:Say( 4, nSepara4 + 'Calorias:', 2 )
   oReport:Say( 5, nSepara5 + aCalori[ RE->ReCalori ], 1 )
   oReport:EndLine()
   oReport:StartLine()
   oReport:Say( 1, 'Valoración:', 2 )
   oReport:Say( 2, nSepara2 + RE->ReValorac, 1 )
   oReport:Say( 4, nSepara4 + 'Fch. Preparac.', 2 )
   oReport:Say( 5, nSepara5 + DToC( RE->ReFchprep ), 1 )
   oReport:EndLine()
   oReport:StartLine()

   IF ! Empty( RE->ReIngred )
      oReport:StartLine()
      oReport:Say( 1, Space( 520 ), 4, 2 )
      oReport:EndLine()
      oReport:StartLine()
      oReport:EndLine()
      oReport:StartLine()
      oReport:Say( 1, 'Comensales', 2 )
      oReport:Say( 2, nSepara2 + TRAN( RE->ReComens,"@E 999" ), 1 )
      oReport:EndLine()
      oReport:StartLine()
      oReport:EndLine()
      oReport:StartLine()
      oReport:Say( 1, 'Ingredientes', 2 )
      oReport:EndLine()
      nLines := MLCount( RE->ReIngred, 90 )
      FOR nFor := 1 TO nLines
         oReport:StartLine()
         oReport:Say( 2, MemoLine( RE->ReIngred, 90, nFor ), 1 )
         oReport:EndLine()
      NEXT
      oReport:StartLine()
      oReport:EndLine()
   ENDIF
   IF ! Empty( RE->RePrepar )
      oReport:StartLine()
      oReport:Say( 1, Space( 520 ), 4, 2 )
      oReport:EndLine()
      oReport:StartLine()
      oReport:EndLine()
      oReport:StartLine()
      oReport:Say( 1, 'Preparación', 2 )
      oReport:EndLine()
      nLines := MLCount( RE->RePrepar, 90 )
      FOR nFor := 1 TO nLines
         oReport:StartLine()
         oReport:Say( 2, MemoLine( RE->RePrepar, 90, nFor ), 1 )
         oReport:EndLine()
      NEXT
      oReport:StartLine()
      oReport:EndLine()
   ENDIF
   // escandallo
   IF ES->( dbSeek( Re->ReCodigo ) )
      oReport:StartLine()
      oReport:Say( 1, Space( 520 ), 4, 2 )
      oReport:EndLine()
      oReport:StartLine()
      oReport:EndLine()
      oReport:StartLine()
      oReport:Say( 1, 'Escandallo (' + Str( RE->ReComEsc,2 ) + ' comensales)', 2 )
      oReport:EndLine()
      oReport:StartLine()
      oReport:Say( 1, 'Código', 2 )
      oReport:Say( 2, 'Ingrediente', 2 )
      oReport:Say( 4, 'Unidad', 2 )
      // oReport:Say(5, space(4)+'Precio', 2,2)
      oReport:Say( 6, 'Cantidad', 2, 2 ) //+space(4)
      oReport:Say( 7, 'Precio', 2, 2 ) //+space(5)
      oReport:Say( 8, '   Calorias', 2, 2 ) //+space(4)
      oReport:EndLine()
      nReEscan := 0
      nReKCal  := 0
      DO WHILE ES->EsReceta == RE->ReCodigo
         oReport:StartLine()
         oReport:Say( 1, ES->EsIngred, 1 )
         oReport:Say( 2, '', 1 )
         oReport:Say( 4, ES->EsUnidad, 1 )
         AL->( dbSetOrder( 3 ) )
         AL->( dbSeek( ES->EsIngred ) )
         // oReport:Say(5, space(4)+Transform(AL->AlPrecio,'@E 999,999.99 '), 1,2)
         oReport:Say( 6, Transform( ES->EsCantidad,'@E 99.999 ' ), 1, 2 ) // +space(4)
         oReport:Say( 7, Transform( ES->EsPrecio,'@E 999,999.99 ' ), 1, 2 ) // +space(4)
         oReport:Say( 8, Transform( ES->EsKCal,'@E 999,999.99 ' ), 1, 2 ) // +space(4)
         nReEscan += ES->EsPrecio
         nReKCal  += ES->EsKCal
         oReport:EndLine()
         // ahora imprimo el ingrediente
         oReport:BackLine( 1 )
         nSize := 18
         nIni  := 1
         nLine := 0
         DO WHILE nIni < Len( RTrim( ES->EsInDenomi ) )
            cText := SubStr( ES->EsInDenomi, nIni, nSize )
            nLen  := Len( cText )
            DO WHILE SubStr( cText, nLen, 1 ) != ' ' .AND. ( nLen + nIni ) < Len( RTrim( ES->EsInDenomi ) )
               nLen--
            ENDDO
            nIni := nIni + nLen
            nLine++
            oReport:StartLine()
            oReport:Say( 2, iif( nLine == 1,'',Space(5 ) ) + SubStr( cText,1,nLen ) )
            oReport:EndLine()
         ENDDO
         ES->( dbSkip() )
      ENDDO
      oReport:StartLine()
      oReport:Say( 6, 'Total Escandallo ...', 2, 2 )
      oReport:Say( 7, Transform( nReEscan,'@E 999,999.99 ' ), 2, 2 ) //+space(4)
      oReport:Say( 8, Transform( nReKCal,'@E 999,999.99 ' ), 2, 2 ) //+space(4)
      oReport:EndLine()
      oReport:StartLine()
      oReport:Say( 6, 'Valor por comensal...', 2, 2 )
      oReport:Say( 7, Transform( nReEscan / RE->ReComEsc,'@E 999,999.99 ' ), 2, 2 ) //+space(4)
      oReport:Say( 8, Transform( nReKCal / RE->ReComEsc,'@E 999,999.99 ' ), 2, 2 ) //+space(4)
      oReport:EndLine()
      oReport:StartLine()
      oReport:EndLine()
   ENDIF
   IF ! Empty( RE->ReTrucos ) .OR. ! Empty( RE->ReVino )
      oReport:StartLine()
      oReport:Say( 1, Space( 520 ), 4, 2 )
      oReport:EndLine()
      oReport:StartLine()
      oReport:EndLine()
      oReport:StartLine()
      oReport:Say( 1, 'Trucos', 2 )
      oReport:EndLine()
      nLines := MLCount( RE->Retrucos, 90 )
      FOR nFor := 1 TO nLines
         oReport:StartLine()
         oReport:Say( 2, MemoLine( RE->ReTrucos, 90, nFor ), 1 )
         oReport:EndLine()
      NEXT
      oReport:EndLine()
      oReport:StartLine()
      oReport:Say( 1, 'Vino', 2 )
      oReport:EndLine()
      nLines := MLCount( RE->ReVino, 90 )
      FOR nFor := 1 TO nLines
         oReport:StartLine()
         oReport:Say( 2, MemoLine( RE->ReVino, 90, nFor ), 1 )
         oReport:EndLine()
      NEXT
      oReport:StartLine()
      oReport:EndLine()
   ENDIF
   IF ! Empty( RE->RePublica ) .OR. ! Empty( RE->ReAutor )
      oReport:StartLine()
      oReport:Say( 1, Space( 520 ), 4, 2 )
      oReport:EndLine()
      oReport:StartLine()
      oReport:EndLine()
      oReport:StartLine()
      oReport:Say( 1, 'Publicación', 2 )
      oReport:Say( 2, RE->RePublica, 1 )
      oReport:Say( 5, 'Número', 2 )
      oReport:Say( 6, Str( RE->ReNumero ), 1 )
      oReport:Say( 7, 'Página', 2 )
      oReport:Say( 8, Str( RE->RePagina ), 1 )
      oReport:EndLine()
      oReport:StartLine()
      oReport:Say( 1, 'Autor', 2 )
      oReport:Say( 2, RE->ReAutor, 1 )
      oReport:Say( 5, 'E-mail', 2 )
      oReport:Say( 6, RE->ReEmail, 1 )
      oReport:EndLine()
      oReport:StartLine()
      oReport:Say( 1, 'Pais', 2 )
      oReport:Say( 2, RE->Repais, 1 )
      oReport:EndLine()
      oReport:StartLine()
      oReport:EndLine()
   ENDIF
   oReport:StartLine()
   oReport:Say( 1, 'Fecha Incorp.', 2 )
   oReport:Say( 2, nSepara2 + DToC( RE->ReFchInco ), 1 )
   IF RE->ReIncorp == 2
      oReport:Say( 4, nSepara4 + 'Fichero', 2 )
      oReport:Say( 5, nSepara5 + RE->ReFichero, 1 )
   ENDIF
   oReport:EndLine()
   oReport:StartLine()
   oReport:EndLine()
   oReport:StartLine()
   oReport:Say( 1, Space( 520 ), 4, 2 )
   oReport:EndLine()
   oReport:StartLine()
   oReport:EndLine()

RETURN NIL

/*_____________________________________________________________________________*/
FUNCTION ReImpRecetaExpres( cReceta, oReport )

   LOCAL aPlatos  := { 'Ensaladas', '1er Plato', '2o Plato', 'Postres', 'Dulce' }
   LOCAL aEpoca   := { '0000', '0001', '0010', '0011', '0100', '0101', '0110', '0111', ;
      '1000', '1001', '1010', '1011', '1100', '1101', '1110', '1111' }
   LOCAL aLEpoca  := { "   /   /   /   ", "   /   /   /Inv", "   /   /Oto/   ", "   /   /Oto/Inv", ;
      "   /Ver/   /   ", "   /Ver/   /Inv", "   /Ver/Oto/   ", "   /Ver/Oto/Inv", ;
      "Pri/   /   /   ", "Pri/   /   /Inv", "Pri/   /Oto/   ", "Pri/   /Oto/Inv", ;
      "Pri/Ver/   /   ", "Pri/Ver/   /Inv", "Pri/Ver/Oto/   ", "Pri/Ver/Oto/Inv" }
   LOCAL aDifi    := { 'Sencillo', 'Medio', 'Dificil' }
   LOCAL aCalori  := { 'Bajo', 'Medio', 'Alto' }
   LOCAL nSepara2 := Space( 06 )
   LOCAL nSepara4 := Space( 10 )
   LOCAL nSepara5 := Space( 18 )
   LOCAL oRbmp, nFilaBMP, nVert, nHorz, nSalto, i
   LOCAL oRImage, nFila, nFor, nLines, nReScan, nReKCal, nSize, nLine, nIni, cText, nReEscan, nLen

   oReport:EndLine()
   oReport:StartLine()
   oReport:EndLine()
   oReport:StartLine()
   oReport:Say( 1, 'Código:', 2 )
   oReport:Say( 2, nSepara2 + RE->ReCodigo, 1 )
   oReport:Say( 4, nSepara4 + 'Receta:', 2 )
   oReport:Say( 5, nSepara5 + RE->ReTitulo, 1 )
   oReport:EndLine()
   oReport:StartLine()
   oReport:Say( 1, 'Tipo de Plato:', 2 )
   oReport:Say( 2, nSepara2 + aPlatos[ Val( RE->RePlato ) ] )
   oReport:Say( 4, 'Tiempo prep.:', 2 )
   oReport:Say( 5, nSepara2 + RE->ReTiempo, 1 )

   oReport:EndLine()
   oReport:StartLine()

   IF ! Empty( RE->ReIngred )
      oReport:StartLine()
      oReport:Say( 1, Space( 520 ), 4, 2 )
      oReport:EndLine()
      oReport:StartLine()
      oReport:EndLine()
      oReport:StartLine()
      oReport:Say( 1, 'Comensales', 2 )
      oReport:Say( 2, nSepara2 + TRAN( RE->ReComens,"@E 999" ), 1 )
      oReport:EndLine()
      oReport:StartLine()
      oReport:EndLine()
      oReport:StartLine()
      oReport:Say( 1, 'Ingredientes', 2 )
      oReport:EndLine()
      nLines := MLCount( RE->ReIngred, 90 )
      FOR nFor := 1 TO nLines
         oReport:StartLine()
         oReport:Say( 2, MemoLine( RE->ReIngred, 90, nFor ), 1 )
         oReport:EndLine()
      NEXT
      oReport:StartLine()
      oReport:EndLine()
   ENDIF
   IF ! Empty( RE->RePrepar )
      oReport:StartLine()
      oReport:Say( 1, Space( 520 ), 4, 2 )
      oReport:EndLine()
      oReport:StartLine()
      oReport:EndLine()
      oReport:StartLine()
      oReport:Say( 1, 'Preparación', 2 )
      oReport:EndLine()
      nLines := MLCount( RE->RePrepar, 90 )
      FOR nFor := 1 TO nLines
         oReport:StartLine()
         oReport:Say( 2, MemoLine( RE->RePrepar, 90, nFor ), 1 )
         oReport:EndLine()
      NEXT
      oReport:StartLine()
      oReport:EndLine()
   ENDIF

   oReport:StartLine()
   oReport:EndLine()
   oReport:Say( 1, 'Enlace permanente:', 2 )
   oReport:Say( 2, nSepara2 + RE->ReURL, 1 )
   oReport:StartLine()
   oReport:Say( 1, Space( 520 ), 4, 2 )
   oReport:EndLine()
   oReport:StartLine()
   oReport:EndLine()

RETURN NIL

/*_____________________________________________________________________________

function ReImpReceta(cReceta, oReport, lImagen)
   local aPlatos := {'Ensaladas','1er Plato','2o Plato','Postres','Dulce'}
   local aEpoca   := { '0000','0001','0010','0011','0100','0101','0110','0111',;
                       '1000','1001','1010','1011','1100','1101','1110','1111' }
   local aLEpoca  := { "   /   /   /   ", "   /   /   /Inv", "   /   /Oto/   ", "   /   /Oto/Inv",;
                       "   /Ver/   /   ", "   /Ver/   /Inv", "   /Ver/Oto/   ", "   /Ver/Oto/Inv",;
                       "Pri/   /   /   ", "Pri/   /   /Inv", "Pri/   /Oto/   ", "Pri/   /Oto/Inv",;
                       "Pri/Ver/   /   ", "Pri/Ver/   /Inv", "Pri/Ver/Oto/   ", "Pri/Ver/Oto/Inv" }
   local aDifi   := {'Sencillo','Medio','Dificil'}
   local aCalori := {'Bajo','Medio','Alto'}

   if ! Empty(RE->ReImagen) .AND. lImagen
      if UPPER(Right(Rtrim(RE->ReImagen),3)) == 'BMP'
         oRBmp := TBitmap():Define(,lfn2sfn(Rtrim(RE->ReImagen)),)
         oReport:StartLine()
         oReport:Say(1,'Imagen',2)
         nFilaBmp := oReport:nRow/oReport:nStdLineHeight
         nHorz  := (oRBmp:nWidth/oReport:nLogPixX)*3
         nVert  := (oRBmp:nHeight/oReport:nLogPixY)*3
         nSalto := (oRBmp:nHeight/oReport:nStdLineHeight) * 3
         Do WHILE nHorz > 6
            nVert  := nVert  * 0.90
            nHorz  := nHorz  * 0.90
            nSalto := nSalto * 0.90
         Enddo
         oReport:SayBitmap((nFilaBMP/6)-0.1,1.35,lfn2sfn(Rtrim(RE->ReImagen)),nHorz,nVert,1)
         oRBmp:Destroy()
         oReport:EndLine()
         For i:= 1 to nSalto + 1
            oReport:StartLine()
            oReport:EndLine()
         Next
      else
         oRImage := TImage():Define(,lfn2sfn(Rtrim(RE->ReImagen)),)
         oReport:StartLine()
         oReport:Say(1,'Imagen',2)
         nFila  := oReport:nRow/oReport:nStdLineHeight
         nHorz  := (oRImage:nWidth/oReport:nLogPixX)*3
         nVert  := (oRImage:nHeight/oReport:nLogPixY)*3
         nSalto := (oRImage:nHeight/oReport:nStdLineHeight) * 3
         Do WHILE nHorz > 6
            nVert  := nVert  * 0.90
            nHorz  := nHorz  * 0.90
            nSalto := nSalto * 0.90
         Enddo
         oReport:SayImage((nFila/6)-0.1,1.35,oRImage,nHorz,nVert,1)
         oRImage:Destroy()
         oReport:EndLine()
         For i:= 1 to nSalto + 1
            oReport:StartLine()
            oReport:EndLine()
         Next
      endif
      oReport:EndLine()
      oReport:StartLine()
      oReport:Say(2,RE->ReImagen,1)
   endif
   oReport:EndLine()
   oReport:StartLine()
   oReport:EndLine()
   oReport:StartLine()
   oReport:Say(1,'Código:',2)
   oReport:Say(2,RE->ReCodigo,1)
   oReport:Say(4,nSepara+'Receta:',2)
   oReport:Say(5,nSepara+RE->ReTitulo,1)
   oReport:EndLine()
   oReport:StartLine()
   oReport:Say(1,'Tipo de Plato:',2)
   oReport:Say(2,aPlatos[VAL(RE->RePlato)]+' / '+rTrim(RE->ReTipo),1)
   oReport:Say(4,nSepara+'Tipo Cocinado:',2)
   oReport:Say(5,nSepara+RE->ReTipoCoc,1)
   oReport:EndLine()
   oReport:StartLine()
   oReport:Say(1,'C. Francesa:',2)
   oReport:Say(2,RE->ReFrTipo,1)

   oReport:Say(4,nSepara+'Epoca:',2)
   oReport:Say(5,nSepara+aLEpoca[ASCAN(aEpoca,STRTRAN(STR(RE->ReEpoca,4),' ','0'))],1)
   oReport:EndLine()
   oReport:StartLine()
   oReport:Say(1,'Tiempo:',2)
   oReport:Say(2,RE->ReTiempo,1)

   oReport:Say(4,nSepara+'Dificultad:',2)
   oReport:Say(5,nSepara+aDifi[RE->REDificu],1)
   oReport:EndLine()
   oReport:StartLine()
   oReport:Say(1,'Precio Estim.:',2)
   oReport:Say(2,RE->RePrecio,1)
   oReport:Say(4,nSepara+'Calorias:',2)
   oReport:Say(5,nSepara+aCalori[RE->ReCalori],1)
   oReport:EndLine()
   oReport:StartLine()
   oReport:Say(1,'Valoración:',2)
   oReport:Say(2,RE->ReValorac,1)
   oReport:Say(4,nSepara+'Fch. Preparac.',2)
   oReport:Say(5,nSepara+DtoC(RE->ReFchprep),1)
   oReport:EndLine()
   oReport:StartLine()

   if ! Empty(RE->ReIngred)
      oReport:StartLine()
      oReport:Say(1,space(520),4,2)
      oReport:EndLine()
      oReport:StartLine()
      oReport:EndLine()
      oReport:StartLine()
      oReport:Say(1,'Comensales',2)
      oReport:Say(2,RE->ReComens,1)
      oReport:EndLine()
      oReport:StartLine()
      oReport:EndLine()
      oReport:StartLine()
      oReport:Say(1,'Ingredientes',2)
      oReport:EndLine()
      nLines := MlCount(RE->ReIngred,90)
      FOR nFor := 1 TO nLines
         oReport:StartLine()
         oReport:Say(2, MemoLine(RE->ReIngred, 90, nFor), 1)
         oReport:EndLine()
      NEXT
      oReport:StartLine()
      oReport:EndLine()
   endif
   if ! Empty(RE->RePrepar)
      oReport:StartLine()
      oReport:Say(1,space(520),4,2)
      oReport:EndLine()
      oReport:StartLine()
      oReport:EndLine()
      oReport:StartLine()
      oReport:Say(1,'Preparación',2)
      oReport:EndLine()
      nLines := MlCount(RE->RePrepar,90)
      FOR nFor := 1 TO nLines
         oReport:StartLine()
         oReport:Say(2, MemoLine(RE->RePrepar, 90, nFor), 1)
         oReport:EndLine()
      NEXT
      oReport:StartLine()
      oReport:EndLine()
   endif
   // escandallo
   if ES->(DbSeek(Re->ReCodigo))
      oReport:StartLine()
      oReport:Say(1,space(520),4,2)
      oReport:EndLine()
      oReport:StartLine()
      oReport:EndLine()
      oReport:StartLine()
      oReport:Say(1,'Escandallo ('+Str(RE->ReComEsc,2)+' comensales)',2)
      oReport:EndLine()
      oReport:StartLine()
      oReport:Say(1, 'Código', 2)
      oReport:Say(2, 'Ingrediente', 2)
      oReport:Say(4, 'Unidad', 2)
      oReport:Say(5, space(4)+'Precio', 2,2)
      oReport:Say(6, 'Cantidad'+space(4), 2, 2)
      oReport:Say(7, 'Precio'+space(5), 2, 2)
      oReport:Say(8, '   Calorias'+space(4), 2, 2)
      oReport:EndLine()
      nReEscan := 0
      nReKCal  := 0
      DO While ES->EsReceta == RE->ReCodigo
         oReport:StartLine()
         oReport:Say(1, ES->EsIngred, 1)
         oReport:Say(2, '', 1)
         oReport:Say(4, ES->EsUnidad, 1)
         AL->(DbSetOrder(3))
         AL->(DbSeek(ES->EsIngred))
         oReport:Say(5, space(4)+Transform(AL->AlPrecio,'@E 999,999.99 '), 1,2)
         oReport:Say(6, Transform(ES->EsCantidad,'@E 99.999 ' )+space(4), 1, 2)
         oReport:Say(7, Transform(ES->EsPrecio,'@E 999,999.99 ' )+space(4), 1, 2)
         oReport:Say(8, Transform(ES->EsKCal,'@E 999,999.99 ' )+space(4), 1, 2)
         nReEscan += ES->EsPrecio
         nReKCal  += ES->EsKCal
         oReport:EndLine()
         // ahora imprimo el ingrediente
         oReport:BackLine(1)
         nSize := 18
         nIni  := 1
         nLine := 0
         Do While nIni < Len(Rtrim(ES->EsInDenomi))
            cText := SubStr(ES->EsInDenomi,nIni,nSize)
            nLen  := Len(cText)
               Do while SubStr(cText,nLen,1) != ' ' .AND. (nLen+nIni)<Len(Rtrim(ES->EsInDenomi))
                  nLen --
               Enddo
            nIni := nIni + nLen
            nLine ++
            oReport:StartLine()
            oReport:Say(2,Iif(nLine==1,'',Space(5))+SubStr(cText,1,nLen))
            oReport:EndLine()
         Enddo
         ES->(DbSkip())
      ENDDO
      oReport:StartLine()
      oReport:Say(6, 'Total Escandallo ...', 2, 2)
      oReport:Say(7, Transform(nReEscan,'@E 999,999.99 '+SPACE(4)), 2, 2)
      oReport:Say(8, Transform(nReKCal ,'@E 999,999.99 '+SPACE(4)), 2, 2)
      oReport:EndLine()
      oReport:StartLine()
      oReport:Say(6, 'Valor por comensal...', 2, 2)
      oReport:Say(7, Transform(nReEscan/RE->ReComEsc,'@E 999,999.99 '+SPACE(4)), 2, 2)
      oReport:Say(8, Transform(nReKCal /RE->ReComEsc,'@E 999,999.99 '+SPACE(4)), 2, 2)
      oReport:EndLine()
      oReport:StartLine()
      oReport:EndLine()
   endif
   if ! Empty(RE->ReTrucos) .OR. ! Empty(RE->ReVino)
      oReport:StartLine()
      oReport:Say(1,space(520),4,2)
      oReport:EndLine()
      oReport:StartLine()
      oReport:EndLine()
      oReport:StartLine()
      oReport:Say(1,'Trucos',2)
      oReport:EndLine()
      nLines := MlCount(RE->Retrucos,90)
      FOR nFor := 1 TO nLines
         oReport:StartLine()
         oReport:Say(2, MemoLine(RE->ReTrucos, 90, nFor), 1)
         oReport:EndLine()
      NEXT
      oReport:EndLine()
      oReport:StartLine()
      oReport:Say(1,'Vino',2)
      oReport:EndLine()
      nLines := MlCount(RE->ReVino,90)
      FOR nFor := 1 TO nLines
         oReport:StartLine()
         oReport:Say(2, MemoLine(RE->ReVino, 90, nFor), 1)
         oReport:EndLine()
      NEXT
      oReport:StartLine()
      oReport:EndLine()
   endif
   if ! Empty(RE->RePublica) .OR. ! Empty(RE->ReAutor)
      oReport:StartLine()
      oReport:Say(1,space(520),4,2)
      oReport:EndLine()
      oReport:StartLine()
      oReport:EndLine()
      oReport:StartLine()
      oReport:Say(1,'Publicación',2)
      oReport:Say(2,RE->RePublica,1)
      oReport:Say(5,'Número',2)
      oReport:Say(6,Str(RE->ReNumero),1)
      oReport:Say(7,'Página',2)
      oReport:Say(8,Str(RE->RePagina),1)
      oReport:EndLine()
      oReport:StartLine()
      oReport:Say(1,'Autor',2)
      oReport:Say(2,RE->ReAutor,1)
      oReport:Say(5,'E-mail',2)
      oReport:Say(6,RE->ReEmail,1)
      oReport:EndLine()
      oReport:StartLine()
      oReport:Say(1,'Pais',2)
      oReport:Say(2,RE->Repais,1)
      oReport:EndLine()
      oReport:StartLine()
      oReport:EndLine()
   endif
   oReport:StartLine()
   oReport:Say(1,'Fecha Incorp.',2)
   oReport:Say(2,RE->ReFchInco,1)
   if RE->ReIncorp == 2
      oReport:Say(4,Space(16)+'Fichero',2)
      oReport:Say(5,RE->ReFichero,1)
   endif
   oReport:EndLine()
   oReport:StartLine()
   oReport:EndLine()
   oReport:StartLine()
   oReport:Say(1,space(520),4,2)
   oReport:EndLine()
   oReport:StartLine()
   oReport:EndLine()
return nil

_______________________________________________________________________________*/
FUNCTION ReWord( oGrid, oCont )

   LOCAL oWord, oText
   LOCAL aPlatos  := { 'Ensaladas', '1er Plato', '2o Plato', 'Postres', 'Dulce' }
   LOCAL aEpoca   := { '0000', '0001', '0010', '0011', '0100', '0101', '0110', '0111', ;
      '1000', '1001', '1010', '1011', '1100', '1101', '1110', '1111' }
   LOCAL aLEpoca  := { "   /   /   /   ", "   /   /   /Inv", "   /   /Oto/   ", "   /   /Oto/Inv", ;
      "   /Ver/   /   ", "   /Ver/   /Inv", "   /Ver/Oto/   ", "   /Ver/Oto/Inv", ;
      "Pri/   /   /   ", "Pri/   /   /Inv", "Pri/   /Oto/   ", "Pri/   /Oto/Inv", ;
      "Pri/Ver/   /   ", "Pri/Ver/   /Inv", "Pri/Ver/Oto/   ", "Pri/Ver/Oto/Inv" }
   LOCAL aDifi    := { 'Sencillo', 'Medio', 'Dificil' }
   LOCAL aCalori  := { 'Bajo', 'Medio', 'Alto' }

   try
      oWord := CREATEOBJECT( "Word.Application" )
      catch
      MsgStop( "El programa no encuentra la aplicación Microsoft Word en su equipo. " + ;
         "Para exportar una receta a formato de Microsoft Word es necesario que dicha aplicación esté instalada.", 'Atención' )
      RETU NIL
   END try
   oWord:Documents:Add()
   oText := oWord:Selection()
   oText:Font:Size := 18
   oText:Typetext( RE->ReTitulo + CRLF )

   oText:Font:Size := 10

   oText:Font:Bold := .T.
   oText:Typetext( "Codigo: " )
   oText:Font:Bold := .F.
   oText:Typetext( RE->ReCodigo )
   oText:Font:Bold := .T.
   oText:Typetext( Chr( 9 ) + Chr( 9 ) + "Tipo de plato: " )
   oText:Font:Bold := .F.
   oText:Typetext( aPlatos[ Val( RE->RePlato ) ] + ' / ' + RTrim( RE->ReTipo ) + CRLF )

   oText:Font:Bold := .T.
   oText:Typetext( "Tipo de cocinado: " )
   oText:Font:Bold := .F.
   oText:Typetext( RTrim( RE->ReTipoCoc ) )
   oText:Font:Bold := .T.
   oText:Typetext( Chr( 9 ) + Chr( 9 ) + "C. Francesa: " )
   oText:Font:Bold := .F.
   oText:Typetext( RE->ReFrTipo + CRLF )

   oText:Font:Bold := .T.
   oText:Typetext( "Época: " )
   oText:Font:Bold := .F.
   oText:Typetext( aLEpoca[ AScan( aEpoca,StrTran(Str(RE->ReEpoca,4 ),' ','0' ) ) ] )
   oText:Font:Bold := .T.
   oText:Typetext( Chr( 9 ) + Chr( 9 ) + "Tiempo: " )
   oText:Font:Bold := .F.
   oText:Typetext( RE->ReTiempo + CRLF )

   oText:Font:Bold := .T.
   oText:Typetext( "Dificultad: " )
   oText:Font:Bold := .F.
   oText:Typetext( aDifi[ RE->REDificu ] )
   oText:Font:Bold := .T.
   oText:Typetext( Chr( 9 ) + Chr( 9 ) + "Precio estimado: " )
   oText:Font:Bold := .F.
   oText:Typetext( tran( RE->RePrecio, "@E 99,999.99" ) + CRLF )

   oText:Font:Bold := .T.
   oText:Typetext( "Calorias: " )
   oText:Font:Bold := .F.
   oText:Typetext( aCalori[ RE->ReCalori ] )
   oText:Font:Bold := .T.
   oText:Typetext( Chr( 9 ) + Chr( 9 ) + "Valoración: " )
   oText:Font:Bold := .F.
   oText:Typetext( RE->ReValorac + CRLF )

   oText:Font:Bold := .T.
   oText:Typetext( "F. Preparación: " )
   oText:Font:Bold := .F.
   oText:Typetext( DToC( RE->ReFchPrep ) )
   oText:Font:Bold := .T.
   oText:Typetext( Chr( 9 ) + Chr( 9 ) + "Comensales: " )
   oText:Font:Bold := .F.
   oText:Typetext( tran( RE->ReComens,"@E 999" ) + CRLF )

   oText:Font:Bold := .T.
   oText:Typetext( "Autor: " )
   oText:Font:Bold := .F.
   oText:Typetext( RE->ReAutor + CRLF )

   oText:Font:Bold := .T.
   oText:Typetext( "Publicación: " )
   oText:Font:Bold := .F.
   oText:Typetext( RE->RePublica + CRLF )

   oText:Font:Bold := .T.
   oText:Typetext( "Enlace perm.: " )
   oText:Font:Bold := .F.
   oText:Typetext( RE->ReURL + CRLF )

   oText:Font:Bold := .T.
   oText:Typetext( "Ingredientes: " + CRLF )
   oText:Font:Bold := .F.
   oText:Typetext( RE->ReIngred + CRLF )

   oText:Font:Bold := .T.
   oText:Typetext( "Preparación: " + CRLF )
   oText:Font:Bold := .F.
   oText:Typetext( RE->RePrepar + CRLF )

   oText:Font:Bold := .T.
   oText:Typetext( "Trucos: " + CRLF )
   oText:Font:Bold := .F.
   oText:Typetext( RE->ReTrucos + CRLF )
   try
      oWord:ActiveDocument:SaveAs( oApp():cDocPath + RTrim( RE->ReCodigo ) + '.doc' )
      catch
      MsgStop( "Word no puede guardar el archivo en la ruta " + oApp():cDocPath + RTrim( RE->ReCodigo ) + '.doc' + CRLF + ;
         "Por favor guarde el documento de manera manual.", 'Atención' )
   END try
   oWord:Visible := .T.

RETURN NIL
//_____________________________________________________________________________

FUNCTION ReRtf( oGrid, oCont )

   LOCAL aPlatos  := { 'Ensaladas', '1er Plato', '2o Plato', 'Postres', 'Dulce' }
   LOCAL aEpoca   := { '0000', '0001', '0010', '0011', '0100', '0101', '0110', '0111', ;
      '1000', '1001', '1010', '1011', '1100', '1101', '1110', '1111' }
   LOCAL aLEpoca  := { "   /   /   /   ", "   /   /   /Inv", "   /   /Oto/   ", "   /   /Oto/Inv", ;
      "   /Ver/   /   ", "   /Ver/   /Inv", "   /Ver/Oto/   ", "   /Ver/Oto/Inv", ;
      "Pri/   /   /   ", "Pri/   /   /Inv", "Pri/   /Oto/   ", "Pri/   /Oto/Inv", ;
      "Pri/Ver/   /   ", "Pri/Ver/   /Inv", "Pri/Ver/Oto/   ", "Pri/Ver/Oto/Inv" }
   LOCAL aDifi    := { 'Sencillo', 'Medio', 'Dificil' }
   LOCAL aCalori  := { 'Bajo', 'Medio', 'Alto' }
   LOCAL mReceta  := ''
   LOCAL oRtf, nHandle
   LOCAL cFile  := oApp():cDocPath + RTrim( RE->ReCodigo ) + '.rtf'
   LOCAL nReEscan, nReKCal

   CursorWait()
   mReceta += 'Código: ' + RE->ReCodigo + CRLF
   mReceta += 'Receta: ' + RE->ReTitulo + CRLF
   mReceta += 'Tipo de plato: ' + aPlatos[ Val( RE->RePlato ) ] + ' / ' + RTrim( RE->ReTipo ) + CRLF
   mReceta += 'Tipo de cocinado: ' + RE->ReTipoCoc + CRLF
   mReceta += 'C. Francesa: ' + RE->ReFrTipo + CRLF
   mReceta += 'Ing. Principal: ' + RE->ReIngPri + CRLF
   mReceta += 'Dieta / Tolerancia: ' + RE->ReDietas + CRLF
   mReceta += 'Época: ' + aLEpoca[ AScan( aEpoca, StrTran( Str(RE->ReEpoca,4 ),' ','0' ) ) ] + CRLF
   mReceta += 'Tiempo: ' + RE->ReTiempo + CRLF
   mReceta += 'Dificultad: ' + aDifi[ RE->REDificu ] + CRLF
   mReceta += 'Calorías: ' + aCalori[ RE->ReCalori ] + CRLF
   mReceta += 'Comensales: ' + TRAN( RE->ReComens, "@E 999" ) + CRLF
   mReceta += 'Tiempo preparación: ' + RE->ReTiempo + CRLF
   mReceta += 'Precio estimado: ' + TRAN( RE->RePrecio, "@E 999,999.99" ) + CRLF
   mReceta += 'Precio estimado por comensal: ' + TRAN( RE->RePPC, "@E 999,999.99" ) + CRLF
   mReceta += 'Fecha prepación: ' + DToC( RE->ReFchPrep ) + CRLF
   mReceta += 'Valoración: ' + RE->ReValorac + CRLF


   mReceta += 'Ingredientes: ' + RE->ReIngred + CRLF
   mReceta += 'Preparación: ' + RE->RePrepar + CRLF
   IF ! Empty( RE->ReTrucos )
      mReceta += 'Trucos: ' + RE->ReTrucos + CRLF
   ENDIF
   IF ! Empty( RE->ReVino )
      mReceta += 'Vino: ' + RE->ReVino + CRLF
   ENDIF

   mReceta += 'Publicación: ' + RE->RePublica + CRLF
   mReceta += 'Número/Pagina: ' + Str( RE->ReNumero ) + "/" + Str( RE->RePagina ) + CRLF
   mReceta += 'Enlace permanente: ' + RE->ReURL + CRLF
   mReceta += 'Autor: ' + RE->ReAutor + CRLF
   mReceta += 'País: ' + RE->RePais + CRLF


   // escandallo

   IF ES->( dbSeek( Re->ReCodigo ) )
      mReceta += CRLF
      mReceta += 'Escandallo para ' + Str( RE->ReComEsc, 2 ) + ' comensales' + CRLF
      mReceta += "Código" + Chr( 9 ) + Chr( 9 ) + "Ingrediente" + Chr( 9 ) + Chr( 9 ) + "Unidad" + Chr( 9 ) + "Cantidad" + Chr( 9 ) + "Precio" + Chr( 9 ) + "Calorias" + CRLF
      nReEscan := 0
      nReKCal  := 0
      DO WHILE ES->EsReceta == RE->ReCodigo .AND. ! ES->( Eof() )
         AL->( dbSetOrder( 3 ) )
         AL->( dbSeek( ES->EsIngred ) )
         mReceta += RTrim( ES->EsIngred ) + Chr( 9 ) + Chr( 9 ) + RTrim( ES->EsInDenomi ) + Chr( 9 ) + RTrim( ES->EsUnidad ) + Chr( 9 ) + TRAN( ES->EsCantidad, "@E 99.999" ) + ;
            Chr( 9 ) + TRAN( ES->EsPrecio, "@E 999,999.99" ) + Chr( 9 ) + TRAN( ES->EsKCal, "@E 999,999.99" ) + CRLF
         nReEscan += ES->EsPrecio
         nReKCal  += ES->EsKCal
         ES->( dbSkip() )
      ENDDO
      mReceta += CRLF + Chr( 9 ) + Chr( 9 ) + "Total precio ..." + TRAN( nReEscan, "@E 999,999.99" )
      mReceta += CRLF + Chr( 9 ) + Chr( 9 ) + "Total calorias.." + TRAN( nReKCal, "@E 999,999.99" )

   ENDIF

   oRtf := tRtfFile():New( cFile )
   oRtf:WriteLong( mReceta )
   ? 'imagen'
   IF RE->ReImagen != NIL
      ortf:WriteBMP( RE->ReImagen )
   ENDIF
   oRtf:End()
   CursorArrow()
   IF MsgYesNo( 'El fichero RTF se encuentra en ' + oApp():cDocPath + RTrim( RE->ReCodigo ) + '.rtf' + CRLF + '¿ Desea visualizarlo ?', 'Seleccione una opción' )
      WinExec( "rundll32.exe url.dll,FileProtocolHandler " + oApp():cDocPath + RTrim( RE->ReCodigo ) + '.rtf' )
   ENDIF
   oGrid:Refresh()
   oGrid:SetFocus( .T. )

RETURN NIL
//_____________________________________________________________________________//
FUNCTION ReHtml( oGrid, oCont )

   LOCAL aPlatos  := { 'Ensaladas', '1er Plato', '2o Plato', 'Postres', 'Dulce' }
   LOCAL aEpoca   := { '0000', '0001', '0010', '0011', '0100', '0101', '0110', '0111', ;
      '1000', '1001', '1010', '1011', '1100', '1101', '1110', '1111' }
   LOCAL aLEpoca  := { "   /   /   /   ", "   /   /   /Inv", "   /   /Oto/   ", "   /   /Oto/Inv", ;
      "   /Ver/   /   ", "   /Ver/   /Inv", "   /Ver/Oto/   ", "   /Ver/Oto/Inv", ;
      "Pri/   /   /   ", "Pri/   /   /Inv", "Pri/   /Oto/   ", "Pri/   /Oto/Inv", ;
      "Pri/Ver/   /   ", "Pri/Ver/   /Inv", "Pri/Ver/Oto/   ", "Pri/Ver/Oto/Inv" }
   LOCAL aDifi    := { 'Sencillo', 'Medio', 'Dificil' }
   LOCAL aCalori  := { 'Bajo', 'Medio', 'Alto' }
   LOCAL mReceta  := ''
   LOCAL nHandle
   LOCAL cFile  := oApp():cDocPath + RTrim( RE->ReCodigo ) + '.html'

   CursorWait()
   mReceta += '<html><head></head><body>'
   mReceta += 'Código: ' + RE->ReCodigo + CRLF
   mReceta += 'Receta: ' + RE->ReTitulo + CRLF
   mReceta += 'Tipo de plato: ' + aPlatos[ Val( RE->RePlato ) ] + ' / ' + RTrim( RE->ReTipo ) + CRLF
   mReceta += 'Tipo de cocinado: ' + RE->ReTipoCoc + CRLF
   mReceta += 'C. Francesa: ' + RE->ReFrTipo + CRLF
   mReceta += 'Ing. Principal: ' + RE->ReIngPri + CRLF
   mReceta += 'Dieta / Tolerancia: ' + RE->ReDietas + CRLF
   mReceta += 'Época: ' + aLEpoca[ AScan( aEpoca, StrTran( Str(RE->ReEpoca,4 ),' ','0' ) ) ] + CRLF
   mReceta += 'Tiempo: ' + RE->ReTiempo + CRLF
   mReceta += '</body></html>'
/*


oWord:Write( chr(13)+ "Tiempo: " , acFont[2], VAL(acSizes[2]), AT("Negrita",acEstilo[2])!=0, .f. , 0 )
oWord:Write( chr(9)+RE->ReTiempo , acFont[3], VAL(acSizes[3]), AT("Negrita",acEstilo[3])!=0, .f. , 0 )
oWord:Write( chr(9)+chr(9)+"Dificultad: ", acFont[2], VAL(acSizes[2]), AT("Negrita",acEstilo[2])!=0, .f. , 0 )
oWord:Write( chr(9)+aDifi[RE->REDificu], acFont[3], VAL(acSizes[3]), AT("Negrita",acEstilo[3])!=0, .f. , 0 )

oWord:Write( chr(13)+ "Precio estimado: " , acFont[2], VAL(acSizes[2]), AT("Negrita",acEstilo[2])!=0, .f. , 0 )
oWord:Write( chr(9)+TRAN(RE->RePrecio,"@E 999,999.99"), acFont[3], VAL(acSizes[3]), AT("Negrita",acEstilo[3])!=0, .f. , 0 )
oWord:Write( chr(9)+chr(9)+"Calorias: ", acFont[2], VAL(acSizes[2]), AT("Negrita",acEstilo[2])!=0, .f. , 0 )
oWord:Write( chr(9)+aCalori[RE->ReCalori], acFont[3], VAL(acSizes[3]), AT("Negrita",acEstilo[3])!=0, .f. , 0 )

oWord:Write( chr(13)+ "Valoración: " , acFont[2], VAL(acSizes[2]), AT("Negrita",acEstilo[2])!=0, .f. , 0 )
oWord:Write( chr(9)+RE->ReValorac, acFont[3], VAL(acSizes[3]), AT("Negrita",acEstilo[3])!=0, .f. , 0 )
oWord:Write( chr(9)+chr(9)+"Fch. Preparac.: ", acFont[2], VAL(acSizes[2]), AT("Negrita",acEstilo[2])!=0, .f. , 0 )
oWord:Write( chr(9)+DtoC(RE->ReFchPrep), acFont[3], VAL(acSizes[3]), AT("Negrita",acEstilo[3])!=0, .f. , 0 )

oWord:Write( chr(13)+chr(13)+ "Comensales: " , acFont[2], VAL(acSizes[2]), AT("Negrita",acEstilo[2])!=0, .f. , 0 )
oWord:Write( chr(9)+TRAN(RE->ReComens,"@E 999"), acFont[3], VAL(acSizes[3]), AT("Negrita",acEstilo[3])!=0, .f. , 0 )

oWord:Write( chr(13)+chr(13)+ "Ingredientes: " , acFont[2], VAL(acSizes[2]), AT("Negrita",acEstilo[2])!=0, .f. , 0 )
oWord:Write( chr(9)+RE->ReIngred, acFont[3], VAL(acSizes[3]), AT("Negrita",acEstilo[3])!=0, .f. , 0 )

oWord:Write( chr(13)+chr(13)+ "Preparación: " , acFont[2], VAL(acSizes[2]), AT("Negrita",acEstilo[2])!=0, .f. , 0 )
oWord:Write( chr(9)+RE->RePrepar, acFont[3], VAL(acSizes[3]), AT("Negrita",acEstilo[3])!=0, .f. , 0 )

oWord:Write( chr(13)+chr(13)+ "Trucos: " , acFont[2], VAL(acSizes[2]), AT("Negrita",acEstilo[2])!=0, .f. , 0 )
oWord:Write( chr(9)+RE->ReTrucos, acFont[3], VAL(acSizes[3]), AT("Negrita",acEstilo[3])!=0, .f. , 0 )

oWord:Write( chr(13)+chr(13)+ "Vino: " , acFont[2], VAL(acSizes[2]), AT("Negrita",acEstilo[2])!=0, .f. , 0 )
oWord:Write( chr(9)+RE->ReVino, acFont[3], VAL(acSizes[3]), AT("Negrita",acEstilo[3])!=0, .f. , 0 )

oWord:Write( chr(13)+chr(13)+ "Publicación: " , acFont[2], VAL(acSizes[2]), AT("Negrita",acEstilo[2])!=0, .f. , 0 )
oWord:Write( chr(9)+RE->RePublica, acFont[3], VAL(acSizes[3]), AT("Negrita",acEstilo[3])!=0, .f. , 0 )
oWord:Write( chr(9)+chr(9)+ "Número/Página: " , acFont[2], VAL(acSizes[2]), AT("Negrita",acEstilo[2])!=0, .f. , 0 )
oWord:Write( chr(9)+Str(RE->ReNumero)+"/"+Str(RE->RePagina), acFont[3], VAL(acSizes[3]), AT("Negrita",acEstilo[3])!=0, .f. , 0 )

oWord:Write( chr(13)+chr(13)+ "Autor: " , acFont[2], VAL(acSizes[2]), AT("Negrita",acEstilo[2])!=0, .f. , 0 )
oWord:Write( chr(9)+Rtrim(RE->ReAutor), acFont[3], VAL(acSizes[3]), AT("Negrita",acEstilo[3])!=0, .f. , 0 )
oWord:Write( chr(9)+chr(9)+ "Pais: " , acFont[2], VAL(acSizes[2]), AT("Negrita",acEstilo[2])!=0, .f. , 0 )
oWord:Write( chr(9)+RE->RePais, acFont[3], VAL(acSizes[3]), AT("Negrita",acEstilo[3])!=0, .f. , 0 )

// escandallo

if ES->(DbSeek(Re->ReCodigo))
   oWord:Write( chr(13)+chr(13)+ "Escandallo para " , acFont[2], VAL(acSizes[2]), AT("Negrita",acEstilo[2])!=0, .f. , 0 )
   oWord:Write( chr(9)+STR(RE->ReComEsc,2)+' comensales', acFont[3], VAL(acSizes[3]), AT("Negrita",acEstilo[3])!=0, .f. , 0 )
   oWord:Write( chr(13)+"Código"+chr(9)+"Ingrediente"+chr(9)+chr(9)+"Unidad"+chr(9)+"Cantidad"+chr(9)+"Precio"+chr(9)+"Calorias" , acFont[2], VAL(acSizes[2]), AT("Negrita",acEstilo[2])!=0, .f. , 0 )
   nReEscan := 0
   nReKCal  := 0
   DO While ES->EsReceta == RE->ReCodigo .AND. ! ES->( EOF() )
      AL->(DbSetOrder(3))
      AL->(DbSeek(ES->EsIngred))
      oWord:Write( chr(13)+ ES->EsIngred , acFont[3], VAL(acSizes[2]), AT("Negrita",acEstilo[2])!=0, .f. , 0 )
      oWord:Write( chr(9)+ ES->EsInDenomi, acFont[3], VAL(acSizes[2]), AT("Negrita",acEstilo[2])!=0, .f. , 0 )
      oWord:Write( chr(9)+ ES->EsUnidad , acFont[3], VAL(acSizes[2]), AT("Negrita",acEstilo[2])!=0, .f. , 0 )
      // oWord:Write( chr(9)+ TRAN(AL->AlPrecio,"@E 999,999.99"), acFont[3], VAL(acSizes[2]), AT("Negrita",acEstilo[2])!=0, .f. , 0 )
      oWord:Write( chr(9)+ TRAN(ES->EsCantidad,"@E 99.999"), acFont[3], VAL(acSizes[2]), AT("Negrita",acEstilo[2])!=0, .f. , 0 )
      oWord:Write( chr(9)+ TRAN(ES->EsPrecio,"@E 999,999.99"), acFont[3], VAL(acSizes[2]), AT("Negrita",acEstilo[2])!=0, .f. , 0 )
      oWord:Write( chr(9)+ TRAN(ES->EsKCal,"@E 999,999.99"), acFont[3], VAL(acSizes[2]), AT("Negrita",acEstilo[2])!=0, .f. , 0 )
      nReEscan += ES->EsPrecio
      nReKCal  += ES->EsKCal
      ES->(DbSkip())
   ENDDO
   oWord:Write( chr(13)+chr(13)+Chr(9)+chr(9)+"Total escandallo ...", acFont[2], VAL(acSizes[2]), AT("Negrita",acEstilo[2])!=0, .f. , 0 )
   oWord:Write( chr(9)+ TRAN(nReEscan,"@E 999,999.99"), acFont[3], VAL(acSizes[2]), AT("Negrita",acEstilo[2])!=0, .f. , 0 )
   oWord:Write( chr(9)+ TRAN(nReKCal,"@E 999,999.99"), acFont[3], VAL(acSizes[2]), AT("Negrita",acEstilo[2])!=0, .f. , 0 )
   oWord:Write( chr(13)+Chr(9)+chr(9)+"Valor por comensal ...", acFont[2], VAL(acSizes[2]), AT("Negrita",acEstilo[2])!=0, .f. , 0 )
   oWord:Write( chr(9)+ TRAN(nReEscan/RE->ReComEsc,"@E 999,999.99"), acFont[3], VAL(acSizes[2]), AT("Negrita",acEstilo[2])!=0, .f. , 0 )
   oWord:Write( chr(9)+ TRAN(nReKCal/RE->ReComEsc,"@E 999,999.99"), acFont[3], VAL(acSizes[2]), AT("Negrita",acEstilo[2])!=0, .f. , 0 )
endif

oWord:Save()
oWord:End()
*/
   nHandle  := FCreate( cFile, FC_NORMAL )
   FWrite( nHandle, mReceta )
   FClose( nHandle )
   CursorArrow()
   IF MsgYesNo( 'El fichero RTF se encuentra en ' + cFile + CRLF + '¿ Desea visualizarlo ?', 'Seleccione una opción' )
      //oWord := TWord():New()
      //oWord:OpenDoc('c:\'+RTRIM(RE->ReCodigo)+'.doc')
      //oWord:Visualizar()
      //oWord:End()
      WinExec( "rundll32.exe url.dll,FileProtocolHandler " + cFile )
   ENDIF
   oGrid:Refresh()
   oGrid:SetFocus( .T. )

RETURN NIL
//_____________________________________________________________________________//

FUNCTION ReSelAjena( cRmCodigo, oGet, nMode, nField, aGet )

   LOCAL oDlg, oBrowse, oCol, oBtnAceptar, oBtnCancel, oBNew, oBMod, oBDel, oBBus
   LOCAL lOk    := .F.
   LOCAL nRecno := RE->( RecNo() )
   LOCAL nOrder := RE->( ordNumber() )
   LOCAL aTPlato := { 'Entradas', '1er Plato', '2o Plato', 'Postre', 'Dulce', 'Otro' }
   LOCAL nArea  := Select()
   LOCAL aPoint := AdjustWnd( oGet, 271 * 2, 150 * 2 )

   DEFINE DIALOG oDlg RESOURCE 'UT_AJENA1_' + oApp():cLanguage ;
      TITLE "Selección de recetas"
   oDlg:SetFont( oApp():oFont )

   // siempre tengo ordenado por nombre

   SELECT RE
   RE->( dbSetOrder( 1 ) )
   RE->( dbGoTop() )

   oBrowse := TXBrowse():New( oDlg )
   Ut_BrwRowConfig( oBrowse )
   oBrowse:cAlias := "RE"

   oCol := oBrowse:AddCol()
   oCol:bStrData := {|| RE->ReCodigo }
   oCol:cHeader  := i18n( "Código" )
   oCol:nWidth   := 66
   oCol:bLDClickData  := {|| ( lOk := .T., oDlg:End() )   }

   oCol := oBrowse:AddCol()
   oCol:bStrData := {|| RE->ReTitulo }
   oCol:cHeader  := i18n( "Receta" )
   oCol:nWidth   := 200
   oCol:bLDClickData  := {|| ( lOk := .T., oDlg:End() )   }

   oCol := oBrowse:AddCol()
   oCol:bStrData := {|| aTPlato[ Max( Val( RE->RePlato ), 1 ) ] }
   oCol:cHeader  := i18n( "Categoría" )
   oCol:nWidth   := 90
   oCol:bLDClickData  := {|| ( lOk := .T., oDlg:End() )   }

   oCol := oBrowse:AddCol()
   oCol:bStrData :=  {|| RE->ReTipo }
   oCol:cHeader  := i18n( "Tipo de plato" )
   oCol:nWidth   := 150
   oCol:bLDClickData  := {|| ( lOk := .T., oDlg:End() )   }

   oBrowse:SetRDD()
   oBrowse:CreateFromResource( 110 )
   oBrowse:bKeyDown := {| nKey| ReSeTecla( nKey, oBrowse, oDlg, oBtnAceptar ) }

   REDEFINE BUTTON oBNew   ;
      ID 410 OF oDlg       ;
      ACTION ReEdita( oBrowse, 1,, oDlg )

   REDEFINE BUTTON oBMod   ;
      ID 411 OF oDlg       ;
      ACTION ReEdita( oBrowse, 2,, oDlg )

   REDEFINE BUTTON oBDel   ;
      ID 412 OF oDlg       ;
      ACTION ReBorra( oBrowse, )

   REDEFINE BUTTON oBBus   ;
      ID 413 OF oDlg       ;
      ACTION ReBusca( oBrowse, ,, oDlg )

   REDEFINE BUTTON oBtnAceptar   ;
      ID IDOK OF oDlg            ;
      ACTION ( lOk := .T., oDlg:End() )

   REDEFINE BUTTON oBtnCancel    ;
      ID IDCANCEL OF oDlg        ;
      ACTION ( lOk := .F., oDlg:End() )

   ACTIVATE DIALOG oDlg CENTERED       ;
      ON PAINT oDlg:Move( aPoint[ 1 ], aPoint[ 2 ],,, .T. )

   IF lOK
      cRmCodigo := RE->ReCodigo
      oGet:cText := cRmCodigo
      IF aGet != Nil
         aGet[ 2 ]:ctext := RE->ReTitulo
         aGet[ 3 ]:cText := aTPlato[ Max( Val( RE->RePlato ), 1 ) ]
         aGet[ 4 ]:cText := RE->ReTipo
      ENDIF
   ENDIF

   RE->( dbSetOrder( nOrder ) )
   RE->( dbGoto( nRecno ) )

   SELECT ( nArea )

RETURN lOk
/*_____________________________________________________________________________*/
FUNCTION ReSeTecla( nKey, oGrid, oDlg, oBtn )

   DO CASE
   CASE nKey == VK_RETURN
      oBtn:Click()
   CASE nKey == VK_ESCAPE
      oDlg:End()
   OTHERWISE
      IF nKey >= 96 .AND. nKey <= 105
         ReBusca( oGrid, Str( nKey - 96,1 ),, oDlg )
      ELSEIF HB_ISSTRING( Chr( nKey ) )
         ReBusca( oGrid, Chr( nKey ),, oDlg )
      ENDIF
   ENDCASE

RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION ReBrwMenu( oCol, oGrid, oCont, oDlg )

   LOCAL oPop

   MENU oPop POPUP 2007
   MENUITEM "Nueva receta" RESNAME "16_NUEVO" ;
      ACTION ReEdita( oGrid, 1, oCont, oDlg )
   MENUITEM "Nueva Express" RESNAME "16_EXPRES" ;
      ACTION ReEditaExpres( oGrid, 1, oCont, oDlg )
   MENUITEM "Modificar" RESNAME "16_MODIF" ;
      ACTION iif( RE->ReExpres == .T., ReEditaExpres( oGrid, 2, oCont, oDlg ), ReEdita( oGrid, 2, oCont, oDlg ) )
   MENUITEM "Duplicar" RESNAME "16_DUPLICA" ;
      ACTION ReEdita( oGrid, 3, oCont, oDlg )
   MENUITEM "Borrar" RESNAME "16_BORRAR" ;
      ACTION ReBorra( oGrid, oCont )
   MENUITEM "Ver imagen" RESNAME "16_IMAGEN" ;
      ACTION ReZoomImagen( RE->ReImagen, RE->ReTitulo, oDlg )
   SEPARATOR
   MENUITEM "Añadir a menú semanal" RESNAME "16_MENUSEM" ;
      ACTION ReRsEdit()
   MENUITEM "Añadir a menú de evento" RESNAME "16_MENUEVEN" ;
      ACTION ReRmEdit()
   SEPARATOR
   MENUITEM "Copiar al portapapeles" RESNAME "16_COPIAR" ;
      ACTION ReXCopiar( oDlg )
   MENUITEM "Pegar desde el portapapeles" RESNAME "16_PEGAR" ;
      ACTION ReXPegar( oGrid, oCont, oDlg )
   MENUITEM "Exportar a fichero Word" RESNAME "16_WORD"   ;
      ACTION ReWord( oGrid, oCont, oDlg )
   SEPARATOR
   MENUITEM "Seleccionar receta" RESNAME "16_SELECC"         ;
      ACTION ReSelecc1( oGrid, oDlg )
   MENUITEM "Deseleccionar una receta" RESNAME "16_DESEL1"   ;
      ACTION ReDeSel1( oGrid )
   ENDMENU

RETURN oPop

FUNCTION ReRmEdit()

   LOCAL oDlg, aGet[ 9 ], oBtn
   LOCAL aTPlato   := { 'Entradas', '1er Plato', '2o Plato', 'Postre', 'Dulce', 'Otro' }
   LOCAL cMeCodigo := Space( 10 )
   LOCAL cMeDescrip := Space( 60 )
   LOCAL dMeFecha  := CToD( '  -  -  ' )
   LOCAL nMeComens := 0

   DEFINE DIALOG oDlg RESOURCE 'RE_ME_EDIT_' + oApp():cLanguage ;
      TITLE i18n( "Añadir receta a menú de eventos" )
   oDlg:SetFont( oApp():oFont )

   REDEFINE GET aGet[ 1 ] VAR RE->ReCodigo     ;
      ID 101 OF oDlg UPDATE                  ;
      PICTURE "@!"                           ;
      WHEN .F.

   //REDEFINE BUTTON oBtn ID 102 OF oDlg            ;
   //   ACTION ReSelAjena( @cRmCodigo, aGet[1], 4, 2, aGet )

   REDEFINE GET aGet[ 2 ] VAR RE->ReTitulo     ;
      ID 103 OF oDlg UPDATE                  ;
      WHEN .F.

   REDEFINE GET aGet[ 3 ] VAR  aTPlato[ Max( Val( RE->RePlato ), 1 ) ]  ;
      ID 104 OF oDlg UPDATE                  ;
      WHEN .F.

   REDEFINE GET aGet[ 4 ] VAR RE->Retipo       ;
      ID 105 OF oDlg UPDATE                  ;
      WHEN .F.

   REDEFINE GET aGet[ 5 ] VAR cMeCodigo        ;
      ID 106 OF oDlg UPDATE                  ;
      PICTURE "@!"                           ;
      VALID MeClave( @cMeCodigo, aGet[ 5 ], 4, aGet[ 6 ], aGet[ 8 ] )

   REDEFINE BUTTON oBtn ID 107 OF oDlg            ;
      ACTION MeSeleccion( cMeCodigo, aGet[ 5 ], oDlg, aGet[ 6 ], aGet[ 8 ] )

   REDEFINE GET aGet[ 6 ] VAR cMeDescrip       ;
      ID 108 OF oDlg UPDATE                  ;
      WHEN .F.

   REDEFINE GET aGet[ 8 ] VAR dMeFecha         ;
      ID 110 OF oDlg UPDATE                  ;
      WHEN .F.

   REDEFINE GET aGet[ 7 ] VAR nMeComens        ;
      ID 109 OF oDlg UPDATE

   //REDEFINE GET aGet[5] VAR nRmComensal      ;
   // PICTURE "999" ID 106 OF oDlg UPDATE

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
      RM->( dbAppend() )
      REPLACE RM->RmMeCodigo  WITH cMeCodigo
      REPLACE RM->RmReCodigo  WITH RE->ReCodigo
      REPLACE RM->RmComensal   WITH nMeComens
      MsgInfo( 'La receta se ha añadido al menú.' )
      IF dMeFecha > RE->ReFchPrep
         IF MsgYesNo( '¿ Desea modificar la fecha de preparación de la receta ?' )
            SELECT RE
            REPLACE RE->ReFchPrep WITH dMeFecha
         ENDIF
      ENDIF
   ENDIF
   //oLbx:Refresh()
   //oLbx:SetFocus( .t. )

RETURN NIL

FUNCTION ReRsEdit()

   LOCAL oDlg, aGet[ 14 ], aBtn[ 2 ]
   LOCAL aTPlato   := { 'Entradas', '1er Plato', '2o Plato', 'Postre', 'Dulce', 'Otro' }

   // local cRsCodigo, cRsReceta, cRsCategoria, cRsPlato, nRsComensal, cRsDia, cRsComida, dRsFecha, cRsHora local
   LOCAL aDiasL     := { 'Lunes    ', 'Martes   ', 'Miercoles', 'Jueves   ', 'Viernes  ', 'Sábado   ', 'Domingo  ' }
   LOCAL aDiasC     := { ' L ', ' M ', ' X ', ' J ', ' V ', ' S ', ' D ' }
   LOCAL aComidasL  := { 'Desayuno    ', 'Media mañana', 'Almuerzo    ', 'Merienda    ', 'Cena        ' }
   LOCAL aComidasC  := { ' D ', ' Mm', ' A ', ' Md', ' C ' }
   LOCAL cRsCodigo   := Space( 10 )
   LOCAL cRsDescrip   := Space( 60 )
   LOCAL cRsReceta   := Space( 60 )
   LOCAL cRsCategoria := Space( 30 )
   LOCAL cRsPlato   := Space( 30 )
   LOCAL cRsDia   := aDiasL[ 1 ]
   LOCAL cRsComida  := aComidasL[ 1 ]
   LOCAL dRsFecha   := Date()
   LOCAL cRsHora   := "14:00"
   LOCAL nRsComensal  := 0

   DEFINE DIALOG oDlg RESOURCE 'RE_MS_EDIT_' + oApp():cLanguage ;
      TITLE i18n( "Añadir receta a menú semanal" )
   oDlg:SetFont( oApp():oFont )

   REDEFINE GET aGet[ 1 ] VAR RE->ReCodigo     ;
      ID 101 OF oDlg UPDATE                  ;
      PICTURE "@!"                           ;
      WHEN .F.

   //REDEFINE BUTTON oBtn ID 102 OF oDlg            ;
   //   ACTION ReSelAjena( @cRmCodigo, aGet[1], 4, 2, aGet )

   REDEFINE GET aGet[ 2 ] VAR RE->ReTitulo     ;
      ID 103 OF oDlg UPDATE                  ;
      WHEN .F.

   REDEFINE GET aGet[ 3 ] VAR  aTPlato[ Max( Val( RE->RePlato ), 1 ) ]  ;
      ID 104 OF oDlg UPDATE                  ;
      WHEN .F.

   REDEFINE GET aGet[ 4 ] VAR RE->Retipo       ;
      ID 105 OF oDlg UPDATE                  ;
      WHEN .F.

   REDEFINE GET aGet[ 5 ] VAR cRsCodigo        ;
      ID 106 OF oDlg UPDATE                  ;
      PICTURE "@!"                           ;
      VALID MsClave( @cRsCodigo, aGet[ 5 ], 4, aGet[ 6 ] )

   REDEFINE BUTTON aBtn[ 1 ] ID 107 OF oDlg            ;
      ACTION MsSeleccion( cRsCodigo, aGet[ 5 ], oDlg, aGet[ 6 ] )

   REDEFINE GET aGet[ 6 ] VAR cRsDescrip       ;
      ID 108 OF oDlg UPDATE                  ;
      WHEN .F.

   REDEFINE GET aGet[ 7 ] VAR nRsComensal      ;
      ID 109 OF oDlg UPDATE

   REDEFINE COMBOBOX aGet[ 8 ] VAR cRsDia    ITEMS aDiasL ID 110 OF oDlg

   REDEFINE GET aGet[ 9 ] VAR dRsFecha      ;
      ID 111 OF oDlg UPDATE

   REDEFINE BUTTON aBtn[ 2 ]                  ;
      ID 112 OF oDlg ACTION SelecFecha( dRsFecha, aGet[ 9 ] )
   aBtn[ 2 ]:cTooltip := i18n( "seleccionar fecha" )

   REDEFINE COMBOBOX aGet[ 10 ] VAR cRsComida ITEMS aComidasL ID 113 OF oDlg

   REDEFINE GET aGet[ 11 ] VAR cRsHora      ;
      PICT "99:99" ID 114 OF oDlg UPDATE

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
      RS->( dbAppend() )
      REPLACE RS->RsMsCodigo  WITH cRsCodigo
      REPLACE RS->RsReCodigo  WITH RE->ReCodigo
      REPLACE RS->RsComensal   WITH nRsComensal
      REPLACE RS->RsDia        WITH AScan( aDiasC, cRsDia )
      REPLACE RS->RsComida     WITH AScan( aComidasC, cRsComida )
      REPLACE RS->RsFecha      WITH dRsFecha
      REPLACE RS->RsHora       WITH cRsHora
      RS->( dbCommit() )
      MsgInfo( 'La receta se ha añadido al menú semanal.' )
      IF dRsFecha > RE->ReFchPrep
         IF MsgYesNo( '¿ Desea modificar la fecha de preparación de la receta ?' )
            SELECT RE
            REPLACE RE->ReFchPrep WITH dRsFecha
         ENDIF
      ENDIF
   ENDIF
   //oLbx:Refresh()
   //oLbx:SetFocus( .t. )

RETURN NIL

FUNCTION ReSort( nOrden, oCont )

   LOCAL nRecno := RE->( RecNo() )
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
   RE->( dbSetOrder( norden ) )
   iif( norden == 12, re->( dbGoTop() ), iif( re->(Eof() ),re->(dbGoTop() ), ) )
   Refreshrebarimage()
   Refreshcont( ocont, "RE" )
   RE->( dbGoto( nRecno ) )
   oApp():oGrid:Refresh( .T. )
   oApp():oGrid:SetFocus( .T. )

RETURN NIL
