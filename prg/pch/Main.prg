#include "FiveWin.ch"
#include "FiveWin.ch"
#include "SayRef.ch"

REQUEST DBFCDX
REQUEST DBFFPT

REQUEST HB_LANG_ES
REQUEST HB_CODEPAGE_ESWIN

memvar oApp

function Main()
   public oApp
   RddSetdefault('DBFCDX')

   HB_LANGSELECT( 'ES' )
   HB_SETCODEPAGE( 'ESWIN' )

   SetHandleCount(100)

   SET DATE FORMAT   'dd-mm-yyyy'
   SET DELETED ON
   SET CENTURY ON
   SET EPOCH         TO YEAR(DATE()) - 20
   SET MULTIPLE OFF
	
	ut_override()

   oApp  := TApplication():New()
   oApp:Activate()

return nil

//----------------------------------------------------------------------------//

CLASS TApplication

   DATA     oWndMain           // Main window of the application
   DATA     oFont
   DATA		oImgList, oRebar, oToolbar
   DATA     oExit
   DATA     oIcon
   DATA     oMsgItem1, oMsgItem2, oMsgItem3
   DATA     cAppName
   DATA     cVersion
   DATA     cEdicion
   DATA     cBuild
	DATA 		cCopyright
   DATA 		cUrl
   DATA 		cUrlDonativo
	DATA		cUrlCompra
   DATA 		cEmail
   DATA 		cMsgBar
   DATA     cInifile
   DATA		cExePath
   DATA     cDbfPath
   DATA     cPchPath
   DATA     cZipPath
   DATA     cDocPath
	DATA     cPdfPath
	DATA     cXlsPath
   DATA     cLanguage
   DATA     cAppVer
   DATA     cUser
   DATA     oDlg
   DATA     oGrid
	DATA		oTree
   DATA     oTab
   DATA     oSplit
   DATA     nEdit
	DATA     lBcnKitchen
	DATA     lExcel
	DATA		nClrHL
	DATA     nClrBar
	DATA		TheFull
	DATA		nSeconds

   METHOD   New() CONSTRUCTOR

   METHOD   Activate( cFileName )

   METHOD   BuildMenu()
   METHOD   BuildBtnBar()

   METHOD   Close()

   METHOD   End() // INLINE ( SetWinCoors( ::oWndMain, ::cInifile ), ::oWndMain:End() )

   METHOD   InitCheck()
   METHOD   CheckFiles()
   METHOD   Config( oParent )

ENDCLASS

//----------------------------------------------------------------------------//

METHOD New() CLASS TApplication

   local cAAAA, cBBBB, cCCCC, cDDDD, cEEEE, cGGGG1, cGGGG2, cHHHH
   local cFFFF := ""
   local cCfg

   ::cAppName  := i18n("el Puchero ")
   ::cVersion  := "6.61.b"
   ::cBuild    := "build 09.04.2019"
   ::cCopyright  := "© José Luis Sánchez Navarro 2019"
   ::cUrl        := "http://www.alanit.com"
   ::cUrlDonativo:= "http://www.alanit.com/donativos"
	::cUrlCompra  := "http://www.alanit.com/comprar"
   ::cEmail      := "correo@alanit.com"
   ::cMsgBar     := ::cCopyright + " * alanit software - 2018 "

   ::cInifile  := cFilePath( GetModuleFileName( GetInstance() ) ) + "puchero.ini"
   ::cExePath  := cFilePath( GetModuleFileName( GetInstance() ) )
   ::cDbfPath  := GetIni(::cIniFile, "Config", "Dbf",cFilePath(GetModuleFileName(GetInstance())) + "datos\")
   ::cPchPath  := GetIni(::cIniFile, "Config", "Pch",cFilePath(GetModuleFileName(GetInstance())) + "pch\")
   ::cZipPath  := GetIni(::cIniFile, "Config", "Zip",cFilePath(GetModuleFileName(GetInstance())) + "zip\")
   ::cDocPath  := GetIni(::cIniFile, "Config", "Doc",cFilePath(GetModuleFileName(GetInstance())) + "doc\")
	::cPdfPath  := GetIni(::cIniFile, "Config", "Pdf",cFilePath(GetModuleFileName(GetInstance())) + "pdf\")
	::cXlsPath  := GetIni(::cIniFile, "Config", "Xls",cFilePath(GetModuleFileName(GetInstance())) + "xls\")
	//::lExcel    := GetPvProfString("Config", "Excel",.f.,::cInifile)
	::lExcel    := GetIni(::cIniFile, "Config", "Excel", .f.)
   ::cLanguage := 'ES'
   ::oDlg      := nil
   ::nEdit     := 0
	::lBcnKitchen := .f.
	::nClrHL		  := RGB(204,232,255)
	::nClrbar	  := RGB(165,186,204)
	::nSeconds	  := Seconds()
   ::cUser := space(15)
	::thefull := .f.
	::cEdicion := " Edición gratuita"

   DEFINE FONT ::oFont NAME GetDefaultFontName() ;
   	SIZE 0, GetDefaultFontHeight()

   DEFINE ICON ::oIcon RESOURCE "ICON1"

   DEFINE WINDOW ::oWndMain ;
      TITLE ::cAppName+::cVersion+::cEdicion+iif(::lBcnKitchen,' · BcnKitchen ','')  ;
      MENU ::BuildMenu()    ;
      COLOR CLR_BLACK, GetSysColor(15)-RGB(30,30,30) ;
      ICON ::oIcon

	::oWndMain:SetFont(::oFont)
   ::oWndMain:bInit := { || ( ::InitCheck(), ::CheckFiles(), TipOfDay('.\tips.ini', .t.), AppAcercade( .t. ) ) }

	DEFINE MSGBAR OF ::oWndMain PROMPT ::cMsgBar CENTER NOINSET
	::oWndMain:oMsgBar:SetFont(::oFont)

	DEFINE MSGITEM ::oMsgItem2;
	   OF ::oWndMain:oMsgBar;
	   PROMPT iif(::cUser!=SPACE(15),::cUser,"acerca de el Puchero");
	   SIZE len(::cUser)*12;
	   BITMAPS "MSG_LOTUS", "MSG_LOTUS";
	   TOOLTIP " " + i18n("Acerca de...") + " "

	if ::thefull
		::oMsgItem2:bAction := { || AppAcercade( .f. ) }
	else
		::oMsgItem2:bAction := { || Registrame(1) }
	endif

   DEFINE MSGITEM ::oMsgItem3 OF ::oWndMain:oMsgBar ;
      SIZE 152 ;
      PROMPT "www.alanit.com" ;
      COLOR RGB(3,95,156), GetSysColor(15)    ;
		BITMAPS "MSG_ALANIT", "MSG_ALANIT";
      TOOLTIP i18n("visitar la web de alanit");
      ACTION WinExec('start '+'.\alanit.url', 0)

   ::oWndmain:oMsgBar:DateOn()
   ::BuildBtnBar()

	::cUser := "Edición no registrada"

return Self

//----------------------------------------------------------------------------//
METHOD Activate() CLASS TApplication
   local lActivar := oApp:cUser == "***"
   GetWinCoors(::oWndMain, ::cInifile)
   ::oWndMain:bResized := {|| ResizeWndMain() }
   ACTIVATE WINDOW ::oWndMain ;
      VALID SetWinCoors(::oWndMain, ::cInifile)

	Do While ::oFont:nCount > 0
		::oFont:End()
	Enddo

return nil

//----------------------------------------------------------------------------//
METHOD BuildMenu() CLASS TApplication
   local oMenu
   MENU oMenu
      MENUITEM i18n("&Archivo")
      MENU
         MENUITEM i18n("&1 Recetas") ;
            ACTION Recetas() ;
            MESSAGE i18n("Mantenimiento del fichero de Recetas.")
			MENUITEM i18n("&2 Menus semanales") ;
				ACTION MenuSemanal() ;
				MESSAGE i18n("Mantenimiento de menús semanales.")
			MENUITEM i18n("&3 Menus de eventos") ;
				ACTION Menus() ;
				MESSAGE i18n("Mantenimiento de menús de eventos.")
			SEPARATOR
         MENUITEM i18n("&4 Clasificación de Platos") ;
            ACTION Platos() ;
            MESSAGE i18n("Mantenimiento de la Clasificación de Platos.")
			MENUITEM i18n("&5 Ingrediente principal") ;
				ACTION IngredPrin() ;
				MESSAGE i18n("Mantenimiento de ingredientes principales.")
			MENUITEM i18n("&6 Calsificación francesa") ;
				ACTION Francesa() ;
				MESSAGE i18n("Mantenimiento de la clasificación francesa.")
         MENUITEM i18n("&7 Valoración de recetas") ;
            ACTION Valoraciones() ;
            MESSAGE i18n("Mantenimiento de la Valoración de recetas. ")
			MENUITEM i18n("&8 Dietas y tolerancias") ;
				ACTION Dietas() ;
				MESSAGE i18n("Mantenimiento de dietas y tolerancias.")
         SEPARATOR
         MENUITEM i18n("&9 Tabla de Ingredientes para escandallo") ;
            ACTION Alimentos() ;
            MESSAGE i18n("Mantenimiento de la tabla de ingredientes para escandallo. ")
         MENUITEM i18n("&A Tabla de Familias de Ingredientes para escandallo");
            ACTION Grupos() ;
            MESSAGE i18n("Mantenimiento de la tabla de grupos de ingredientes para escandallo.")
         MENUITEM i18n("&B Tabla de Proveedores");
            ACTION Proveedores() ;
            MESSAGE i18n("Mantenimiento de la tabla de proveedores.")
			MENUITEM i18n("&C Ubicaciones") ;
				ACTION Ubicaciones() ;
				MESSAGE i18n("Mantenimiento de ubicaciones de ingredientes.")
			SEPARATOR
         MENUITEM i18n("&D Tabla de Autores de Recetas");
            ACTION Autores() ;
            MESSAGE i18n("Mantenimiento de la tabla de autores de recetas.")
         MENUITEM i18n("&E Tabla de Publicaciones");
            ACTION Publicaciones() ;
            MESSAGE i18n("Mantenimiento de la tabla de publicaciones y sitios web sobre cocina.")
         SEPARATOR
         MENUITEM i18n("&F Especificar impresora") ACTION PrinterSetup() ;
            MESSAGE i18n(" Establecer la Configuración de su impresora.")
         SEPARATOR
         MENUITEM i18n("&G Salir") ACTION ::End() ;
            MESSAGE i18n("Terminar la ejecución del programa.")
      ENDMENU
      MENUITEM i18n("&Utilidades")
      MENU
         MENUITEM i18n("&1 Reindexar los ficheros de recetas")  ACTION (Ut_Actualizar(), Ut_Indexar()) ;
            MESSAGE i18n("Regenerar los indices de la aplicación.")
         MENUITEM i18n("&2 Configurar la aplicación")  ACTION ::Config( ::oWndMain ) ;
            MESSAGE i18n("Configurar la aplicación.")
         SEPARATOR
         MENUITEM i18n("&3 Incorporar datos de versiones anteriores")  ACTION Ut_ActAnterior1() ;
            MESSAGE " "
         SEPARATOR
         MENUITEM i18n("&4 Hacer copia de seguridad")  ACTION ZipBackup() ;
            MESSAGE " "
         MENUITEM i18n("&5 Restaurar copia de seguridad")  ACTION ZipRestore() ;
            MESSAGE " "
      ENDMENU
      MENUITEM i18n("A&yuda")
      MENU
         MENUITEM i18n("&1 Ayuda del programa") ;
            ACTION Iif(!IsWinNt(),;
               winExec("start "+rtrim(TakeOffExt(GetModuleFileName(GetInstance()))+".chm")),;
               ShellExecute(GetActiveWindow(),'Open',TakeOffExt(GetModuleFileName(GetInstance()))+".chm",,,4));
            MESSAGE i18n("Obtener ayuda de la aplicación.") // DISABLED
         MENUITEM i18n("&2 Truco del día") ;
            ACTION TipOfDay('.\tips.ini', .f.) ;
            MESSAGE i18n("Mostrar el truco del día.")
         SEPARATOR
         MENUITEM i18n("&3 Visitar web de alanit") ;
            ACTION GoWeb("http://www.alanit.com") ;
            MESSAGE i18n(" Visitar la web de alanit en internet.")
         MENUITEM i18n("&4 Visitar foro de soporte del programa") ;
            ACTION GoWeb("http://www.alanit.com/foros/foro_puchero.php") ;
            MESSAGE i18n(" Visitar el foro de soporte del programa.")
         MENUITEM i18n("&5 Visitar foro general de cocina");
            ACTION GoWeb("http://www.alanit.com/foros/foro_cocina.php") ;
            MESSAGE i18n(" Visitar el foro de cocina.")
         MENUITEM i18n("&6 Contactar por e-mail con el autor del programa")   ;
            ACTION IIF(!IsWinNt(),;
               winexec('start mailto:correo.alanit@gmail.com?subject=Consulta sobre Findemes',0),;
               Winexec('rundll32.exe url.dll,FileProtocolHandler mailto:correo.alanit@gmail.com?subject=Consulta sobre Findemes' )) ;
            MESSAGE i18n("&7 Enviar un e-mail al autor del programa.")
         MENUITEM i18n("&8 Comprar la edición registrada del programa")    ;
            ACTION GoWeb(oApp():cUrlCompra)  ;
            MESSAGE i18n("Comprar la edición registrada por 20 euros.")
         SEPARATOR
			if ::TheFull
         	MENUITEM i18n("&8 Acerca de el Puchero")  ACTION AppAcercade( .f. ) ;
            	MESSAGE i18n("Información sobre la aplicación.")
			else
				MENUITEM i18n("&8 Acerca de el Puchero")  ACTION Registrame() ;
					MESSAGE i18n("Información sobre la aplicación.")
			endif
      ENDMENU
   ENDMENU

return ( oMenu )

//----------------------------------------------------------------------------//
METHOD BuildBtnBar() CLASS TApplication
   ::oImgList := TImageList():New( 36, 36 ) // width and height of bitmaps
   ::oImgList:AddMasked( TBitmap():Define( "BB_RECETAS"   ,, ::oWndMain ), nRGB( 240, 240, 240 ) )
	::oImgList:AddMasked( TBitmap():Define( "BB_MENUSEM"   ,, ::oWndMain ), nRGB( 240, 240, 240 ) )
   ::oImgList:AddMasked( TBitmap():Define( "BB_MENU"      ,, ::oWndMain ), nRGB( 240, 240, 240 ) )
   ::oImgList:AddMasked( TBitmap():Define( "BB_MATER1"    ,, ::oWndMain ), nRGB( 240, 240, 240 ) )
	::oImgList:AddMasked( TBitmap():Define( "BB_INGRED"    ,, ::oWndMain ), nRGB( 240, 240, 240 ) )
   ::oImgList:AddMasked( TBitmap():Define( "BB_MATER2"    ,, ::oWndMain ), nRGB( 240, 240, 240 ) )
   ::oImgList:AddMasked( TBitmap():Define( "BB_MATER3"    ,, ::oWndMain ), nRGB( 240, 240, 240 ) )
	::oImgList:AddMasked( TBitmap():Define( "BB_DIETAS"    ,, ::oWndMain ), nRGB( 240, 240, 240 ) )
	::oImgList:AddMasked( TBitmap():Define( "BB_ALIMEN"    ,, ::oWndMain ), nRGB( 240, 240, 240 ) )
	::oImgList:AddMasked( TBitmap():Define( "BB_GRUPOS"    ,, ::oWndMain ), nRGB( 240, 240, 240 ) )
   ::oImgList:AddMasked( TBitmap():Define( "BB_PROVEE"    ,, ::oWndMain ), nRGB( 240, 240, 240 ) )
	::oImgList:AddMasked( TBitmap():Define( "BB_UBICACI"   ,, ::oWndMain ), nRGB( 240, 240, 240 ) )
	if ::lBcnKitchen
		::oImgList:AddMasked( TBitmap():Define( "BB_ACCION"   ,, ::oWndMain ), nRGB( 240, 240, 240 ) )
	endif
   ::oImgList:AddMasked( TBitmap():Define( "BB_AUTOR"     ,, ::oWndMain ), nRGB( 240, 240, 240 ) )
   ::oImgList:AddMasked( TBitmap():Define( "BB_PUBLI"     ,, ::oWndMain ), nRGB( 240, 240, 240 ) )
   ::oImgList:AddMasked( TBitmap():Define( "BB_INDEX"     ,, ::oWndMain ), nRGB( 240, 240, 240 ) )
   ::oImgList:AddMasked( TBitmap():Define( "BB_AYUDA"     ,, ::oWndMain ), nRGB( 240, 240, 240 ) )
	// ::oImgList:AddMasked( TBitmap():Define( "BB_UPDATE"    ,, ::oWndMain ), nRGB( 240, 240, 240 ) )
   ::oImgList:AddMasked( TBitmap():Define( "BB_SALIR"     ,, ::oWndMain ), nRGB( 240, 240, 240 ) )

   ::oReBar := TReBar():New( ::oWndMain )
   ::oToolBar := TToolBar():New( ::oReBar, 38, 40, ::oImgList, .t. )
   ::oReBar:InsertBand( ::oToolBar )

   DEFINE TBBUTTON OF ::oToolBar ;
      ACTION  Recetas() ;
      TOOLTIP i18n("recetas de cocina");
      MESSAGE i18n( "Gestión de recetas de cocina." )

   DEFINE TBBUTTON OF ::oToolBar ;
      ACTION  MenuSemanal() ;
      TOOLTIP i18n("menús semanales");
      MESSAGE i18n( "Gestión de menús semanales." )

   DEFINE TBBUTTON OF ::oToolBar ;
      ACTION  Menus() ;
      TOOLTIP i18n("menús de eventos");
      MESSAGE i18n( "Gestión de menús de eventos." )

  DEFINE TBBUTTON OF ::oToolBar ;
      ACTION   Platos() ;
      TOOLTIP  "Tipos de plato y cocinado" ;
      MESSAGE  "Clasificación de tipos de plato y cocinado"

   DEFINE TBBUTTON OF ::oToolBar ;
      ACTION   IngredPrin() ;
      TOOLTIP  "Ingrediente principal" ;
      MESSAGE  "Clasificación de ingrediente principal"

   DEFINE TBBUTTON OF ::oToolBar ;
      ACTION   Francesa() ;
      TOOLTIP  "Clasificación francesa" ;
      MESSAGE  "Clasificación francesa de tipos de plato"

   DEFINE TBBUTTON OF ::oToolBar ;
      ACTION   Valoraciones();
      TOOLTIP  "Valoraciones de recetas" ;
      MESSAGE  "Valoraciones de recetas"

   DEFINE TBBUTTON OF ::oToolBar ;
      ACTION   Dietas();
      TOOLTIP  "Dietas y tolerancias" ;
      MESSAGE  "Dietas y tolerancias"

   DEFINE TBSEPARATOR OF ::oToolbar

   DEFINE TBBUTTON OF ::oToolBar ;
      ACTION   Alimentos();
      TOOLTIP  "Ingredientes para escandallo" ;
      MESSAGE  "Gestión de ingredientes para escandallo"

	DEFINE TBBUTTON OF ::oToolBar ;
      ACTION   Grupos();
      TOOLTIP  "Familias de ingredientes" ;
      MESSAGE  "Gestión de familias de ingredientes para escandallo"

   DEFINE TBBUTTON OF ::oToolBar ;
      ACTION   Proveedores();
      TOOLTIP  "Proveedores" ;
      MESSAGE  "Gestión de proveedores de ingredientes"

	DEFINE TBBUTTON OF ::oToolBar ;
      ACTION   Ubicaciones();
      TOOLTIP  "Ubicaciones" ;
      MESSAGE  "Gestión de ubicaciones de ingredientes"

	if ::lBcnKitchen
		DEFINE TBBUTTON OF ::oToolBar ;
      	ACTION   Acciones();
      	TOOLTIP  "Acciones" ;
      	MESSAGE  "Gestión de acciones con ingredientes"
	endif

   DEFINE TBSEPARATOR OF ::oToolbar

   DEFINE TBBUTTON OF ::oToolBar ;
      ACTION   Autores();
      TOOLTIP  "Autores de recetas" ;
      MESSAGE  "Gestión de autores de recetas"

   DEFINE TBBUTTON OF ::oToolBar ;
      ACTION   Publicaciones();
      TOOLTIP  "Publicaciones" ;
      MESSAGE  "Gestión de publicaciones y sitios web"

   DEFINE TBSEPARATOR OF ::oToolbar

   DEFINE TBBUTTON OF ::oToolBar ;
      TOOLTIP  "Reindexar" ;
      ACTION   ( Ut_Actualizar(), Ut_Indexar() ) ;
      MESSAGE  "Regenerar los índices de los ficheros" ;

   DEFINE TBBUTTON OF ::oToolBar ;
      TOOLTIP  "Ayuda" ;
      ACTION Iif(!IsWinNt(),;
         winExec("start "+rtrim(TakeOffExt(GetModuleFileName(GetInstance()))+".chm")),;
         ShellExecute(GetActiveWindow(),'Open',TakeOffExt(GetModuleFileName(GetInstance()))+".chm",,,4));
      MESSAGE  "Ayuda de la aplicación" //WHEN .f.

	DEFINE TBSEPARATOR OF ::oToolbar

	/*
	DEFINE TBBUTTON OF ::oToolBar ;
		TOOLTIP  "Buscar actualización del programa" ;
		ACTION   BielChkUpdFtp() ;
		MESSAGE  "Buscar actualización del programa" ;

	DEFINE TBSEPARATOR OF ::oToolbar
	*/
	*/	
  	DEFINE TBBUTTON OF ::oToolBar ;
      TOOLTIP  "Finalizar el programa"   ;
      ACTION   ::End() ;
      MESSAGE  "Salida"

   //::oExit:nLeft := ::oBar:nWidth - 60
   //::oBar:bResized:={ || ::oExit:nLeft := ::oBar:nWidth - 60 }

return ( Self )

//----------------------------------------------------------------------------//

METHOD Close() CLASS TApplication

   // ResAllFree()

return nil

//----------------------------------------------------------------------------//

METHOD InitCheck() CLASS TApplication
	/*
   if ! lIsDir( "DATOS" )
      lMkDir( "DATOS" )
   end if

   if ! lIsDir( "ZIP" )
      lMkDir( "ZIP" )
   end if

   if ! lIsDir( "PCH" )
      lMkDir( "PCH" )
   end if

   if ! lIsDir( "DOC" )
      lMkDir( "DOC" )
   end if

   if ! lIsDir( "PDF" )
      lMkDir( "PDF" )
   end if

	if ! lIsDir( "XLS" )
		lMkDir( "XLS" )
	end if

   if ! lIsDir( "FOTOS" )
      lMkDir( "FOTOS" )
   end if
   */
return ( Self )

//----------------------------------------------------------------------------//

METHOD CheckFiles() CLASS tApplication

   local i      := 0
   local nLen   := 0
   local aFiles := { "alimento.dbf", "alimento.cdx",;
                     "autores.dbf" , "autores.cdx" ,;
                     "escanda.dbf" , "escanda.cdx" ,;
                     "francesa.dbf", "francesa.cdx",;
			            "ingredip.dbf", "ingredip.cdx",;
                     "grupos.dbf"  , "grupos.cdx"  ,;
                     "intermed.dbf"                ,;
                     "platos.dbf"  , "platos.cdx"  ,;
                     "proveed.dbf" , "proveed.cdx" ,;
                     "publica.dbf" , "publica.cdx" ,;
                     "recetas.dbf" , "recetas.cdx" , "recetas.fpt"  ,;
                     "tempesc.dbf" , "tempesc.cdx" ,;
                     "valorac.dbf" , "valorac.cdx"  }
	local cOldversion := (GetPvProfString("Config", "Version","", oApp():cIniFile))
	// compruebo la versión
	if cOldversion != ::cVersion
		MsgAlert("Se ha detectado un cambio de versión. A continuación se actualizarán los ficheros para soportar la nueva versión.", "Atención")
		Ut_Actualizar()
 		Ut_Indexar()
		if SubStr(cOldVersion,1,Len(cOldversion)-2) != SubStr(Alltrim(::cVersion),1,Len(Alltrim(::cVersion))-2)
			Msgalert( "El cambio de versión requiere que se borre la configuración de las columnas y los informes." )
			Delinisection( "Browse", ::cIniFile )
			Delinisection( "Report", ::cIniFile )
		endif
	endif
	WritePProString("Config","Version",Ltrim(::cVersion),oApp():cIniFile)
	// compruebo que están los ficheros
   nLen := len( aFiles )
   FOR i := 1 TO nLen
      if !file( ::cDbfPath + aFiles[i] )
         Ut_Actualizar()
         Ut_Indexar()
         EXIT
      endif
   NEXT
   if ! Db_OpenAll()
      retu NIL
   else
		Close All
   endif
return Self

//---------------------------------------------------------------------------//
METHOD Config( oParent ) CLASS TApplication
   local oDlg, oFld
   local aGet[14]
   local oSay[7]
   local nMultip := VAL(GetPvProfString("Config", "Multip","299",::cInifile))/100

   if ::oDlg != nil
      if ::nEdit > 0
         return nil
      else
         ::oDlg:End()
         SysRefresh()
      endif
   endif

   DEFINE DIALOG oDlg RESOURCE 'CONFIGAPP' OF oParent ;
      TITLE ::cAppName+::cVersion + " - Configuración de la aplicación"
 	oDlg:SetFont(oApp():oFont)

   REDEFINE FOLDER oFld ;
      ID 110 OF oDlg    ;
      ITEMS '  &Directorios ', ' &Valores por defecto ';
      DIALOGS "CONFIGAPPA", "CONFIGAPPB";
      OPTION 1

   REDEFINE SAY oSay[1] ID 100 OF oFld:aDialogs[1]
   REDEFINE SAY oSay[2] ID 102 OF oFld:aDialogs[1]
   REDEFINE SAY oSay[3] ID 104 OF oFld:aDialogs[1]
   REDEFINE SAY oSay[4] ID 106 OF oFld:aDialogs[1]
	REDEFINE SAY oSay[5] ID 108 OF oFld:aDialogs[1]
	REDEFINE SAY oSay[6] ID 120 OF oFld:aDialogs[1]

   REDEFINE GET aGet[1] VAR ::cDbfPath    ;
      ID 101 OF oFld:aDialogs[1] UPDATE   ;
      PICTURE '@!'
   REDEFINE BUTTON aGet[2]                ;
      ID 111 OF oFld:aDialogs[1] UPDATE   ;
      ACTION GetDir(aGet[1])
    aGet[2]:cTooltip := "seleccionar directorio"

   REDEFINE GET aGet[3] VAR ::cPchPath    ;
      ID 103 OF oFld:aDialogs[1] UPDATE   ;
      PICTURE '@!'
   REDEFINE BUTTON aGet[4]                ;
      ID 113 OF oFld:aDialogs[1] UPDATE   ;
      ACTION GetDir(aGet[3])
    aGet[4]:cTooltip := "seleccionar directorio"

   REDEFINE GET aGet[5] VAR ::cZipPath    ;
      ID 105 OF oFld:aDialogs[1] UPDATE   ;
      PICTURE '@!'
   REDEFINE BUTTON aGet[6]                ;
      ID 115 OF oFld:aDialogs[1] UPDATE   ;
      ACTION GetDir(aGet[5])
    aGet[6]:cTooltip := "seleccionar directorio"

   REDEFINE GET aGet[7] VAR ::cDocPath    ;
      ID 107 OF oFld:aDialogs[1] UPDATE   ;
      PICTURE '@!'
   REDEFINE BUTTON aGet[8]                ;
      ID 117 OF oFld:aDialogs[1] UPDATE   ;
      ACTION GetDir(aGet[7])
   aGet[8]:cTooltip := "seleccionar directorio"

	REDEFINE GET aGet[9] VAR ::cPdfPath    ;
		ID 109 OF oFld:aDialogs[1] UPDATE   ;
		PICTURE '@!'
	REDEFINE BUTTON aGet[10]                ;
		ID 119 OF oFld:aDialogs[1] UPDATE   ;
		ACTION GetDir(aGet[9])
	aGet[10]:cTooltip := "seleccionar directorio"
	
	REDEFINE GET aGet[11] VAR ::cXlsPath    ;
		ID 121 OF oFld:aDialogs[1] UPDATE   ;
		PICTURE '@!'
	REDEFINE BUTTON aGet[12]                ;
			ID 122 OF oFld:aDialogs[1] UPDATE   ;
			ACTION GetDir(aGet[11])
		aGet[12]:cTooltip := "seleccionar directorio"
		
	REDEFINE CHECKBOX aGet[13] VAR ::lExcel ID 123 OF oFld:aDialogs[1]

   REDEFINE SAY oSay[7] ID 100 OF oFld:aDialogs[2]

   REDEFINE GET aGet[14] VAR nMultip    ;
      ID 101 OF oFld:aDialogs[2] UPDATE   ;
      PICTURE '@E 99.99'
	
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
      SetIni(::cIniFile,"Config","Dbf",::cDbfPath)
      SetIni(::cIniFile,"Config","Pch",::cPchPath)
      SetIni(::cIniFile,"Config","Zip",::cZipPath)
      SetIni(::cIniFile,"Config","Doc",::cDocPath)
		SetIni(::cIniFile,"Config","Pdf",::cPdfPath)
		SetIni(::cIniFile,"Config","Xls",::cXlsPath)
		SetIni(::cIniFile, "Config", "Excel", ::lExcel )
      SetIni(::cIniFile,"Config","Multip",STR(100*nMultip))
		
   endif

return ( Self )
//---------------------------------------------------------------------------//

METHOD End() CLASS TApplication

   if ::oDlg != nil
      if ::nEdit > 0
         return nil
      elseif MsgYesNo(" ¿ Desea finalizar el programa ?", "Seleccione una opción")
         ::oDlg:End()
         ::oWndMain:End()
      endif
   else
      if MsgYesNo(" ¿ Desea finalizar el programa ?", "Seleccione una opción")
         ::oWndMain:End()
      endif
   endif

return ( Self )
//---------------------------------------------------------------------------//

function AppAcercade( lForced )
   local oDlg
   local oBmp
   local oSay
   local oTel
   local oURL1
   local oURL2
   local cCfg, cAAAA, cBBBB, cCCCC, CDDDD
   local lOtravez   := GetIni( , "Config", "Again", "SI" ) == "SI"

	//if F0F4(lForced) //.and. ! lForced
	//	retu nil
	//endif
	if lForced .and. lOtravez == .f.
      retu nil
   endif
	if oApp():thefull
		if ! file( oApp():cExePath + "user.nit" )
			MsgAlert("Fichero de registro no encontrado."+CRLF+CRLF+"Solicite su fichero de registro por correo electrónico a la dirección correo.alanit@gmail.com")
			retu nil
		endif
	   DEFINE DIALOG oDlg;
	      TITLE i18n("acerca de...");
	      FROM  0, 0 TO 242, 330 PIXEL;
	      COLOR CLR_BLACK, CLR_WHITE
		oDlg:SetFont(oApp():oFont)

   	@ 04,26 BITMAP oBmp RESOURCE 'acercade' ;
      	SIZE 110, 30 OF oDlg PIXEL NOBORDER

	   @ 32,13 SAY oSay;
	      PROMPT i18n("versión")+" "+oApp:cVersion+" "+oApp:cBuild;
	      SIZE 140,15 PIXEL;
	      OF oDlg;
	      COLOR CLR_GRAY, CLR_WHITE;
	      CENTERED

	   @ 40,13 SAY oTel;
	      PROMPT oApp:cCopyright;
	      SIZE 140,9 PIXEL;
	      OF oDlg;
	      COLOR CLR_GRAY, CLR_WHITE;
	      CENTERED

	   hb_UnZipFile( oApp():cExePath+"user.nit",NIL,.f.,"deomnirescibilietquibusdamaliis",oAPP():cExePath,"user.lic" )
	   cCfg  := cFilePath( GetModuleFileName( GetInstance() ) ) + "user.lic"
	   cAAAA := GetPvProfString( "Usuario", "AAAA", "", cCfg )
	   cBBBB := GetPvProfString( "Usuario", "BBBB", "", cCfg )
	   cCCCC := GetPvProfString( "Usuario", "CCCC", "", cCfg )
	   cDDDD := GetPvProfString( "Usuario", "DDDD", "", cCfg )
	   delete file (oApp():cExePath+"user.lic")

	   //@ 52, 10 TO 100, 156 PIXEL;
	   //   OF oDlg
	   @ 52 ,20 SAY oSay;
	      PROMPT " "+i18n("Programa registrado por")+" ";
	      SIZE 60,9 PIXEL;
	      OF oDlg;
	      COLOR CLR_GRAY, CLR_WHITE
	   @ 65,13 SAY oSay     ;
	      PROMPT cBBBB      ;
	      SIZE 140,9 PIXEL  ;
	      OF oDlg;
	      COLOR GetSysColor(2), CLR_WHITE;
	      CENTERED
	   @ 75,13 SAY oSay     ;
	      PROMPT cCCCC      ;
	      SIZE 140,9 PIXEL  ;
	      OF oDlg ;
	      COLOR GetSysColor(2), CLR_WHITE;
	      CENTERED
	   @ 85,13 SAY oSay     ;
	      PROMPT cDDDD      ;
	      SIZE 140,9 PIXEL  ;
	      OF oDlg;
	      COLOR GetSysColor(2), CLR_WHITE;
	      CENTERED
	   @ 106,13 CHECKBOX lOtravez;
	      PROMPT i18n("Mostrar la próxima vez que arranque el programa");
	      SIZE 150, 9 PIXEL;
	      OF oDlg;
	      COLOR GetSysColor(2), CLR_WHITE

	   ACTIVATE DIALOG oDlg ;
	      ON INIT ( DlgCenter( oDlg, oApp:oWndMain ) );
	      ON CLICK oDlg:End()

	   SetIni( , "Config", "Again", iif( lOtravez, "SI", "NO" ) )
	else
		Registrame()
	endif

return nil

function Donacion()
   local oDlg
   local oBmp01
   local oBmp02
   local oSay
   local oTel
   local lDonativo := .f.
   // local oFontBold := TFont():New( GetDefaultFontName(), 0, GetDefaultFontHeight(),,.t. )

   DEFINE DIALOG oDlg;
      TITLE i18n("Donación");
      FROM  0, 0 TO 296, 324 PIXEL;
      COLOR CLR_BLACK, CLR_WHITE
	oDlg:SetFont(oApp():oFont)

   @ 00,14 BITMAP oBmp01 OF oDlg;
      RESOURCE 'acercade2';
      SIZE 34, 54 PIXEL;
      NOBORDER

   @ 10,50 BITMAP oBmp02 OF oDlg;
      RESOURCE 'acercade1';
      SIZE 90, 20 PIXEL;
      NOBORDER

   @ 32,10 SAY oSay;
      PROMPT i18n("versión")+" "+oApp:cVersion+" "+oApp:cBuild;
      SIZE 140,15 PIXEL;
      OF oDlg;
      COLOR CLR_GRAY, CLR_WHITE;
      CENTERED

   @ 40,10 SAY oTel;
      PROMPT oApp():cCopyright ;
      SIZE 140,9 PIXEL;
      OF oDlg;
      COLOR CLR_GRAY, CLR_WHITE;
      CENTERED

   @ 50, 10 SAY oSay;
      PROMPT i18n("¡ Gracias por utilizar el Puchero !");
      SIZE 140, 9 PIXEL;
      OF oDlg;
      COLOR CLR_BLACK, CLR_WHITE;
      CENTERED

   @ 60, 12 SAY oSay;
      PROMPT i18n("He pasado muchas noches creando este programa. Si es útil para ti " + ;
                  "puedes contribuir a su desarrollo realizando un donativo. Eso me animará a seguir mejorándolo."+CRLF+CRLF+;
						"Al realizar el donativo recibirás una clave de donante que desactivará este mensaje y pondrá tu nombre en todos los listados del programa.");
      SIZE 140, 76 PIXEL;
      OF oDlg;
      COLOR CLR_BLACK, CLR_WHITE

   @ 134, 80 BUTTON i18n("Donativo") OF oDlg;
      SIZE 36,12 PIXEL;
      ACTION ( lDonativo := .t., oDlg:End() )

   @ 134, 120 BUTTON i18n("Ahora no") OF oDlg;
      SIZE 36,12 PIXEL;
      ACTION oDlg:End()

   ACTIVATE DIALOG oDlg ;
      ON INIT ( DlgCenter( oDlg, oApp:oWndMain ) )

   if lDonativo
      GoWeb( oApp():cUrlDonativo )
   endif
return nil
/*_____________________________________________________________________________*/
/*___ OZScript ________________________________________________________________*/

#define ST_NORMAL        0
#define ST_ICONIZED      1
#define ST_ZOOMED        2

STATIC function GetWinCoors(oWnd,cInifile)

   local oIni
   local nRow, nCol, nWidth, nHeight, nState

   // nRow    := oWnd:nTop
   // nCol    := oWnd:nLeft
   // nWidth  := oWnd:nRight-oWnd:nLeft
   // nHeight := oWnd:nBottom-oWnd:nTop

   nRow    := 128
   nCol    := 124
   nWidth  := 805
   nHeight := 586

   if IsIconic( oWnd:hWnd )
      nState := ST_ICONIZED
   elseif IsZoomed(oWnd:hWnd)
      nState := ST_ZOOMED
   else
      nState := ST_NORMAL
   endif

   INI oIni FILE cInifile

   GET nRow SECTION "config" ;
      ENTRY "nTop" default nRow OF oIni

   GET nCol SECTION "config" ;
      ENTRY "nLeft" default nCol OF oIni

   GET nWidth SECTION "config" ;
      ENTRY "nRight" default nWidth OF oIni

   GET nHeight SECTION "config" ;
      ENTRY "nBottom" default nHeight OF oIni

   GET nState SECTION "config" ;
      ENTRY "Mode" default nState OF oIni

   ENDINI
	if nRow == -32000 .or. nCol == -32000
		nRow := 0
		nCol := 0
	endif
   if nRow == 0 .AND. nCol == 0
      WndCenter(oWnd:hWnd)
   else
      oWnd:Move(nRow, nCol, nWidth, nHeight)
   endif

   if nState == ST_ICONIZED
      oWnd:Minimize()
   elseif nState == ST_ZOOMED
      oWnd:Maximize()
   endif
   UpdateWindow( oWnd:hWnd )
   oWnd:CoorsUpdate()
   SysRefresh()

return nil

//-------------------------------------------------------------------------//

STATIC function SetWinCoors(oWnd, cInifile)

   local oIni
   local nRow, nCol, nWidth, nHeight, nState

   oWnd:CoorsUpdate()

   nRow    := oWnd:nTop
   nCol    := oWnd:nLeft
   nWidth  := oWnd:nRight-oWnd:nLeft
   nHeight := oWnd:nBottom-oWnd:nTop

   if IsIconic( oWnd:hWnd )
      nState := ST_ICONIZED
   elseif IsZoomed(oWnd:hWnd)
      nState := ST_ZOOMED
   else
      nState := ST_NORMAL
   endif

   INI oIni FILE cInifile

   SET SECTION "config" ;
      ENTRY "nTop" TO nRow OF oIni

   SET SECTION "config" ;
      ENTRY "nLeft" TO nCol OF oIni

   SET SECTION "config" ;
      ENTRY "nRight" TO nWidth OF oIni

   SET SECTION "config" ;
      ENTRY "nBottom" TO nHeight OF oIni

   SET SECTION "config" ;
      ENTRY "Mode" TO nState OF oIni

   ENDINI

return .t.

STATIC function TakeOffExt(cFile)

   local nAt := At(".", cFile)

   if nAt > 0
      cFile := Left(cFile, nAt-1)
   endif

return cFile

function oApp()
return oApp

function ResizeWndMain()
   local aClient
   if oApp():oDlg != nil
      aClient := GetClientRect (oApp():oWndMain:hWnd )
      oApp():oDlg:SetSize( aClient[4], aClient[3] - oApp():oToolBar:nHeight - 4 - oApp():oWndMain:oMsgBar:nHeight )
      oApp():oDlg:Refresh()
      oApp():oSplit:SetSize( oApp():oSplit:nWidth, oApp():oDlg:nHeight)
      oApp():oSplit:Refresh()
      if oApp():oGrid != nil
         oApp():oGrid:SetSize( aClient[4]-oApp():oGrid:nLeft, oApp():oDlg:nHeight - 26 )
         oApp():oGrid:Refresh()
         oApp():oTab:nTop := oApp():oDlg:nHeight - 26
         oApp():oTab:Refresh()
      endif
		if oApp():oTree != nil
         oApp():oTree:SetSize( aClient[4]-oApp():oTree:nLeft, oApp():oDlg:nHeight - 26 )
         oApp():oTree:Refresh()
         oApp():oTab:nTop := oApp():oDlg:nHeight - 26
         oApp():oTab:Refresh()
      endif
      oApp():oWndMain:oMsgBar:Refresh()
   endif
	IF ! oApp():thefull
		Registrame()
	ENDIF
return nil

//___ manejo de fuentes © Paco García 2006 ____________________________________//

#pragma BEGINDUMP
#include "Windows.h"
#include "hbapi.h"

HB_FUNC( GETDEFAULTFONTNAME )
{
   LOGFONT lf;
   GetObject( ( HFONT ) GetStockObject( DEFAULT_GUI_FONT )  , sizeof( LOGFONT ), &lf );
   hb_retc( lf.lfFaceName );
}

HB_FUNC( GETDEFAULTFONTHEIGHT )
{
   LOGFONT lf;
   GetObject( ( HFONT ) GetStockObject( DEFAULT_GUI_FONT )  , sizeof( LOGFONT ), &lf );
   hb_retni( lf.lfHeight );
}

HB_FUNC( GETDEFAULTFONTWIDTH )
{
   LOGFONT lf;
   GetObject( ( HFONT ) GetStockObject( DEFAULT_GUI_FONT )  , sizeof( LOGFONT ), &lf );
   hb_retni( lf.lfWidth );
}

HB_FUNC( GETDEFAULTFONTITALIC )
{
   LOGFONT lf;
   GetObject( ( HFONT ) GetStockObject( DEFAULT_GUI_FONT )  , sizeof( LOGFONT ), &lf );
   hb_retl( (BOOL) lf.lfItalic );
}

HB_FUNC( GETDEFAULTFONTUNDERLINE )
{
   LOGFONT lf;
   GetObject( ( HFONT ) GetStockObject( DEFAULT_GUI_FONT )  , sizeof( LOGFONT ), &lf );
   hb_retl( (BOOL) lf.lfUnderline );
}

HB_FUNC( GETDEFAULTFONTBOLD )
{
   LOGFONT lf;
   GetObject( ( HFONT ) GetStockObject( DEFAULT_GUI_FONT )  , sizeof( LOGFONT ), &lf );
   hb_retl( (BOOL) ( lf.lfWeight == 700 ) );
}

HB_FUNC( GETDEFAULTFONTSTRIKEOUT )
{
      LOGFONT lf;
      GetObject( ( HFONT ) GetStockObject( DEFAULT_GUI_FONT )  , sizeof( LOGFONT ), &lf );
      hb_retl( (BOOL) lf.lfStrikeOut );
}

#pragma ENDDUMP


STATIC FUNCTION BielChkUpdFtp()
   LOCAL cIp      := 'ftp.alanit.com'
   LOCAL cFolder  := '/public_html/updates/'
   LOCAL oInternet, oFtp
   LOCAL cFtpVer
   LOCAL oDlgProgress, oSay1, oSay2, oProgress, oBmp

	IF ! oApp():thefull
		Registrame()
		RETU NIL
	ENDIF
	? 'BielChkUpdFtp'
   IF !Empty(cIP) .AND. !Empty(cFolder) .AND. File(oApp():cExePath+'ActVer.exe')
      if File(oApp():cExePath+'pch.ini')
         delete file &(oApp():cExePath+'pch.ini')
      endif
      MsgRun('Conectando con el servidor de alanit.com','Por favor, espera', {|| ConectaFtp(cIp, cFolder, @oInternet, @oFtp)})
      IF File(oApp():cExePath+'pch.ini')
         cFtpVer := AllTrim( ( Getpvprofstring( "Config", "Version", "", oApp():cExePath+'pch.ini' ) ) )
         IF cFtpVer != Alltrim(oApp():cVersion)
            IF MsgYesno('Existe una nueva versión del programa disponible.'+CRLF+' ¿ Desea actualizar ahora ?', FWString( "Select an option" ))
               // descargo pch.exe
               DEFINE DIALOG oDlgProgress RESOURCE 'UT_INDEXAR_'+oApp():cLanguage OF oApp():oWndMain
               oDlgProgress:SetFont(oApp():oFont)

               REDEFINE BITMAP oBmp ID 111 OF oDlgProgress RESOURCE 'BB_U_UPDATE' TRANSPARENT
               REDEFINE SAY oSay1 PROMPT "Descargando versión "+cFtpVer ID 99  OF oDlgProgress
               REDEFINE SAY oSay2 PROMPT space(30) ID 10  OF oDlgProgress
               oProgress := TProgress():Redefine( 101, oDlgProgress )
               oDlgProgress:bStart := { || SysRefresh(), FtpGetFile( oSay2, oProgress, oDlgProgress, oFtp ), oDlgProgress:End() }
               ACTIVATE DIALOG oDlgProgress ;
                  ON INIT DlgCenter(oDlgProgress,oApp():oWndMain)
               oFtp:End()
               oInternet:End()
               if File(oApp():cExePath+'pch.exe')
                  msgAlert('El programa se cerrará para permitir su actualización.')
                  WinExec( oApp():cExepath+'ActVer.exe '+'pch.exe'+'puchero.exe' )
                  PostQuitMessage(0)
                  QUIT
               endif
            ENDIF
         ELSE
            MsgInfo('La versión instalada es la última disponible.', FWString( "Information" ))
         ENDIF
         oFtp:End()
         oInternet:End()
      ELSE
         MsgStop('Ha sucedido un error al conectar con el servidor de alanilt.com.'+CRLF+'Por favor, inténtalo más tarde.')
         oFtp:End()
         oInternet:End()
      ENDIF
   ENDIF
RETURN NIL

//----------------------------------------------------------------------------------------
FUNCTION ConectaFtp(cIp, cFolder, oInternet, oFtp)
   LOCAL oFtpFile
   LOCAL hTarget
   LOCAL nBytes
   LOCAL nBufSize := 4096
   LOCAL cBuffer  := Space(nBufSize)
   oInternet := tInternet():New()
   oFtp      := tFtp():New(cIp,oInternet,'bkzyjjze','nafaqudi')
   IF ! Empty( oFtp:hFtp)
      CursorWait()
      FtpSetCurrentDirectory( oFTP:hFTP, cFolder )
      hTarget = FCreate( oApp():cExePath+'pch.ini')
      oFtpFile = Tftpfile():New( 'pch.ini', oFtp )
      oFtpFile:Openread()
      WHILE ( nBytes := Len( cBuffer := oFtpFile:Read( nBufSize ) ) ) > 0
         FWrite( hTarget, cBuffer, nBytes )
      ENDDO
      FClose( hTarget )
      oFtpFile:End()
   ENDIF
RETURN NIL

STATIC FUNCTION FtpGetFile( oSay, oMeter, oDlg, oFtp )
   LOCAL oFtpFile, hTarget, lValRet:=.F.
   LOCAL nBufSize,cBuffer,nBytes, nTotal:=0,nFile:=0
   LOCAL nSize := 5500000
   oMeter:SetRange( 0, 100 )
   nBufSize:=4096
   cBuffer := Space(nBufSize)
   if File(oApp():cExePath+'pch.exe')
      delete file &(oApp():cExePath+'pch.exe')
   endif
   hTarget = FCreate( oApp():cExePath+'pch.exe')
   oFtpFile = Tftpfile():New( 'puchero.exe', oFtp )
   oFtpFile:Openread()
   Sysrefresh()
   WHILE ( nBytes := Len( cBuffer := oFtpFile:Read( nBufSize ) ) ) > 0
      FWrite( hTarget, cBuffer, nBytes )
      oSay:SetText( "Bytes copiados: " + ;
                     AllTrim( Str( nTotal += nBytes ) ) )
      oMeter:SetPos( 100*nTotal/nSize )
      SysRefresh()
   ENDDO
   FClose( hTarget )
   oFtpFile:End()
RETURN NIL
