#include "FiveWin.ch"

/*_____________________________________________________________________________*/

function ut_Actualizar()

   local oDlgProgress, oSay01, oSay02, oBmp, oProgress
   local cDir := oApp():cDbfPath

   if oApp():oDlg != nil
      if oApp():nEdit > 0
         //MsgStop('Por favor, finalice la edición del registro actual.')
         return nil
      else
         oApp():oDlg:End()
         SysRefresh()
      endif
   endif

   DEFINE DIALOG oDlgProgress RESOURCE 'UT_INDEXAR_'+oApp():cLanguage OF oApp():oWndMain
 	oDlgProgress:SetFont(oApp():oFont)
   REDEFINE BITMAP oBmp ID 111 OF oDlgProgress RESOURCE 'BB_INDEX' TRANSPARENT
   REDEFINE SAY oSay01 PROMPT i18n("Actualizando ficheros de datos") ID 99  OF oDlgProgress
   REDEFINE SAY oSay02 PROMPT space(30) ID 10  OF oDlgProgress

   oProgress := TProgress():Redefine( 101, oDlgProgress )

   oDlgProgress:bStart := {|| SysRefresh(), Ut_CrearDbf(oDlgProgress, cDir, oSay02, oProgress), oDlgProgress:End() }
   ACTIVATE DIALOG oDlgProgress ;
      ON INIT DlgCenter(oDlgProgress,oApp():oWndMain)

return nil

function Ut_CrearDbf(oDlgProgress,cDir,oSay,oProgress)
   local lEpoca
	local nProgress
	local nS1
   FIELD ReEpoca

   CursorWait()
   oSay:SetText(i18n("Actualizando fichero de Ingredientes"))
	Db_OpenNoIndex("Alimento", "AL")
	oProgress:SetRange( 0, RecCount() )
	Ut_ResetMeter( oProgress, @nProgress )
	DbCloseAll()
   DbCreate(cDir+'al', {{'ALCODIGO'    , 'C',   9,   0} ,;
                        {'ALTIPO'      , 'C',  20,   0} ,;
                        {'ALALIMENTO'  , 'C',  40,   0} ,;
                        {'ALUNIDAD'    , 'C',  10,   0} ,;
                        {'ALPRECIO'    , 'N',   8,   2} ,;
                        {'ALULTCOM'    , 'D',   8,   0} ,;
                        {'ALKCAL'      , 'N',   9,   2} ,;
                        {'ALPROT'      , 'N',   9,   2} ,;
                        {'ALHC'        , 'N',   9,   2} ,;
                        {'ALGT'        , 'N',   9,   2} ,;
                        {'ALGS'        , 'N',   9,   2} ,;
                        {'ALGMI'       , 'N',   9,   2} ,;
                        {'ALGPI'       , 'N',   9,   2} ,;
                        {'ALCOL'       , 'N',   9,   2} ,;
                        {'ALFIB'       , 'N',   9,   2} ,;
                        {'ALNA'        , 'N',   9,   2} ,;
                        {'ALCA'        , 'N',   9,   2} ,;
                        {'ALPROVEED'   , 'C',  50,   0} ,;
			               {'ALCODPROV'   , 'C',  40,   0} ,;
			               {'ALUBICACI'   , 'C',  40,   0} ,;
								{'ALACCION'    , 'C',   8,   0} ,;
			               {'ALSTOCK'     , 'N',   6,   2} }, 'DBFCDX')
   close all
   use &(cDir+'al') alias al new
   select al
   if FILE(cDir+'ALIMENTO.DBF')
      delete file &(cdir+'alimento.cdx')
      append from &(cdir+'alimento') WHILE Ut_dbfmeter( oProgress, @nProgress )
      dbcommitall()
      close all
      delete file &(cdir+'alimento.dbf')
   endif
   close all
   rename &(cdir+'al.dbf') to &(cdir+'alimento.dbf')

   // autores
   oSay:SetText(i18n("Actualizando fichero de Autores"))
	Db_OpenNoIndex("AUTORES", "AU")
	oProgress:SetRange( 0, RecCount() )
	Ut_ResetMeter( oProgress, @nProgress )
	DbCloseAll()
   DbCreate(cDir+'au', {{'AUNOMBRE'    , 'C',  50,   0} ,;
                        {'AUNOTAS'     , 'C', 255,   0} ,;
                        {'AUDIRECC'    , 'C',  50,   0} ,;
                        {'AUTELEFONO'  , 'C',  30,   0} ,;
                        {'AUlocalI'    , 'C',  50,   0} ,;
                        {'AUPAIS'      , 'C',  30,   0} ,;
                        {'AUEMAIL'     , 'C',  50,   0} ,;
                        {'AUURL'       , 'C',  80,   0} ,;
                        {'AURECETAS'   , 'N',   5,   0}}, 'DBFCDX' )
   close all
   use &(cDir+'au') new
   select au
   if FILE(cDir+'AUTORES.DBF')
      delete file &(cdir+'autores.cdx')
      append from &(cdir+'autores') WHILE Ut_dbfmeter( oProgress, @nProgress )
      dbcommitall()
      close all
      delete file &(cdir+'autores.dbf')
   endif
   close all
   rename &(cdir+'au.dbf') to &(cdir+'autores.dbf')

   // escandallo
   oSay:SetText(i18n("Actualizando fichero de Escandallo"))
	Db_OpenNoIndex("ESCANDA", "ES")
	oProgress:SetRange( 0, RecCount() )
	Ut_ResetMeter( oProgress, @nProgress )
	DbCloseAll()
   DbCreate(cDir+'es', {{'ESRECETA'    , 'C',  10,   0} ,;
                        {'ESUSUARIO'   , 'C',   5,   0} ,;
                        {'ESINGRED'    , 'C',   9,   0} ,;
                        {'ESCANTIDAD'  , 'N',  12,   3} ,;
								{'ESCANFIJA'   , 'L',   1,   0} ,;
                        {'ESUNIDAD'    , 'C',  10,   0} ,;
                        {'ESPRECIO'    , 'N',  10,   2} ,;
                        {'ESKCAL'      , 'N',   8,   2} ,;
								{'ESINDENOMI'  , 'C',  30,   0} ,;
								{'ESPROVEED'   , 'C',  50,   0} ,;
                  		{'ESDIA'       , 'N',   1,   0} ,; // { l, m, x, j, v, s, d }
								{'ESCOMIDA'    , 'N',   1,   0} ,; // { d, x, c, m, c }
								{'ESFECHA'     , 'D',   8,   0} ,;
								{'ESHORA'      , 'C',   5,   0} }, 'DBFCDX')
   close all
   use &(cDir+'es') new
   select es
   if FILE(cDir+'ESCANDA.DBF')
      delete file &(cdir+'escanda.cdx')
      append from &(cdir+'escanda') WHILE Ut_dbfmeter( oProgress, @nProgress )
      dbcommitall()
      close all
      delete file &(cdir+'escanda.dbf')
   endif
   close all
   rename &(cdir+'es.dbf') to &(cdir+'escanda.dbf')

   // grupos de ingredientes
   oSay:SetText(i18n("Fichero de Grupos de ingredientes"))
	Db_OpenNoIndex("GRUPOS", "GR")
	oProgress:SetRange( 0, RecCount() )
	Ut_ResetMeter( oProgress, @nProgress )
	DbCloseAll()
   DbCreate(cDir+'gr', {{'GRTIPO'      , 'C',  20,   0},;
								{'GRALIMENT'   , 'N',   5,   0}}, 'DBFCDX' )
   close all
   use &(cDir+'gr') new
   select gr
   if FILE(cDir+'GRUPOS.DBF')
      delete file &(cdir+'grupos.cdx')
      append from &(cdir+'grupos') WHILE Ut_dbfmeter( oProgress, @nProgress )
      dbcommitall()
      close all
      delete file &(cdir+'grupos.dbf')
   endif
   close all
   rename &(cdir+'gr.dbf') to &(cdir+'grupos.dbf')

   // ingrediente principal
   oSay:SetText(i18n("Fichero de ingrediente principal"))
	Db_OpenNoIndex("INGREDIP", "IP")
	oProgress:SetRange( 0, RecCount() )
	Ut_ResetMeter( oProgress, @nProgress )
	DbCloseAll()
   DbCreate(cDir+'ig', {{'IPINGRED'      , 'C',  30,   0},;
 								{'IPRECETAS'     , 'N',   5,   0}}, 'DBFCDX')
   close all
   use &(cDir+'ig') new
   select ig
   if FILE(cDir+'INGREDIP.DBF')
      delete file &(cdir+'ingredip.cdx')
      append from &(cdir+'ingredip') WHILE Ut_dbfmeter( oProgress, @nProgress )
      dbcommitall()
      close all
      delete file &(cdir+'ingredip.dbf')
   endif
   close all
   rename &(cdir+'ig.dbf') to &(cdir+'ingredip.dbf')

   // temporal de escandallo
   oSay:SetText(i18n("Actualizando fichero de Escandallo"))
	Db_OpenNoIndex("TEMPESC", "TS")
	oProgress:SetRange( 0, RecCount() )
	Ut_ResetMeter( oProgress, @nProgress )
	DbCloseAll()
   DbCreate(cDir+'ts', {{'ESRECETA'    , 'C',  10,   0} ,;
                        {'ESUSUARIO'   , 'C',   5,   0} ,;
                        {'ESINGRED'    , 'C',   9,   0} ,;
                        {'ESCANTIDAD'  , 'N',  12,   3} ,;
								{'ESCANFIJA'   , 'L',   1,   0} ,;
                        {'ESUNIDAD'    , 'C',  10,   0} ,;
                        {'ESPRECIO'    , 'N',  10,   2} ,;
                        {'ESKCAL'      , 'N',   8,   2} ,;
                        {'ESINDENOMI'  , 'C',  30,   0} ,;
								{'ESPROVEED'   , 'C',  50,   0} ,;
                  		{'ESDIA'       , 'N',   1,   0} ,; // { l, m, x, j, v, s, d }
								{'ESCOMIDA'    , 'N',   1,   0} ,; // { d, x, c, m, c }
								{'ESFECHA'     , 'D',   8,   0} ,;
								{'ESHORA'      , 'C',   5,   0} ,;
								{'ESSTOCK'     , 'N',   6,   2} ,;
								{'ESCODPROV'   , 'C',  40,   0} ,;
								{'ESUBICACI'   , 'C',  40,   0} ,;
								{'ESACCION'    , 'C',   8,   0} }, 'DBFCDX')
   close all
   use &(cDir+'ts') new
   select ts
   if FILE(cDir+'TEMPESC.DBF')
      delete file &(cdir+'tempesc.cdx')
      append from &(cdir+'tempesc') WHILE Ut_dbfmeter( oProgress, @nProgress )
      dbcommitall()
      close all
      delete file &(cdir+'tempesc.dbf')
   endif
   close all
   rename &(cdir+'ts.dbf') to &(cdir+'tempesc.dbf')

   // intermedio
   oSay:SetText(i18n("Fichero Intermedio"))
   DbCreate(cDir+'in', {{'LINEA'       , 'C',  81,   0}}, 'DBFCDX')
   close all
   use &(cDir+'in') new
   select in
   if FILE(cDir+'INTERMED.DBF')
      delete file &(cdir+'intermed.cdx')
      append from &(cdir+'intermed')
      dbcommitall()
      close all
      delete file &(cdir+'intermed.dbf')
   endif
   close all
   rename &(cdir+'in.dbf') to &(cdir+'intermed.dbf')

   // platos
   oSay:SetText(i18n("Actualizando fichero de Tipos de Plato"))
	Db_OpenNoIndex("PLATOS", "PL")
	oProgress:SetRange( 0, RecCount() )
	Ut_ResetMeter( oProgress, @nProgress )
	DbCloseAll()
   DbCreate(cDir+'pl', {{'PLPLATO'     , 'C',   1,   0} ,;
                        {'PLTIPO'      , 'C',  30,   0} ,;
                        {'PLRECETAS'   , 'N',   5,   0}}, 'DBFCDX' )
   close all
   use &(cDir+'pl') new
   select pl
   if FILE(cDir+'PLATOS.DBF')
      delete file &(cdir+'platos.cdx')
      append from &(cdir+'platos') WHILE Ut_dbfmeter( oProgress, @nProgress )
      dbcommitall()
      close all
      delete file &(cdir+'platos.dbf')
   endif
   close all
   rename &(cdir+'pl.dbf') to &(cdir+'platos.dbf')

   // clasificación francesa
   oSay:SetText(i18n("Actualizando clasificación francesa"))
	Db_OpenNoIndex("FRANCESA", "FR")
	oProgress:SetRange( 0, RecCount() )
	Ut_ResetMeter( oProgress, @nProgress )
	DbCloseAll()
   DbCreate(cDir+'fr', {{'FRN1'        , 'N',   2,   0} ,;
                        {'FRN2'        , 'N',   2,   0} ,;
                        {'FRN3'        , 'N',   2,   0} ,;
                        {'FRN4'        , 'N',   2,   0} ,;
                        {'FRN5'        , 'N',   2,   0} ,;
                        {'FRTIPO'      , 'C',  30,   0} ,;
                        {'FRHOJA'      , 'L',   1,   0} ,;
                        {'FRRECETAS'   , 'N',   5,   0}}, 'DBFCDX' )
   close all
   use &(cDir+'fr') new
   select FR
   if FILE(cDir+'FRANCESA.DBF')
      delete file &(cdir+'francesa.cdx')
      append from &(cdir+'francesa') WHILE Ut_dbfmeter( oProgress, @nProgress )
      dbcommitall()
      close all
      delete file &(cdir+'francesa.dbf')
   endif
   close all
   rename &(cdir+'fr.dbf') to &(cdir+'francesa.dbf')

   // proveedores
   oSay:SetText(i18n("Actualizando fichero de Proveedores"))
	Db_OpenNoIndex("PROVEED", "PR")
	oProgress:SetRange( 0, RecCount() )
	Ut_ResetMeter( oProgress, @nProgress )
	DbCloseAll()
   DbCreate(cDir+'pr', {{'PRNOMBRE'    , 'C',  50,   0} ,;
                     	{'PRALIMENT'   , 'N',   5,   0} ,;
                        {'PRNOTAS'     , 'C', 255,   0} ,;
                        {'PRCif'       , 'C',  12,   0} ,;
                        {'PRDIRECC'    , 'C',  50,   0} ,;
                        {'PRTELEFONO'  , 'C',  30,   0} ,;
                        {'PRFAX'       , 'C',  30,   0} ,;
                        {'PRlocalI'    , 'C',  50,   0} ,;
                        {'PRPAIS'      , 'C',  30,   0} ,;
                        {'PREMAIL'     , 'C',  50,   0} ,;
                        {'PRURL'       , 'C',  80,   0}}, 'DBFCDX')

   close all
   use &(cDir+'pr') new
   select pr
   if FILE(cDir+'PROVEED.DBF')
      delete file &(cdir+'proveed.cdx')
      append from &(cdir+'proveed') WHILE Ut_dbfmeter( oProgress, @nProgress )
      dbcommitall()
      close all
      delete file &(cdir+'proveed.dbf')
   endif
   close all
   rename &(cdir+'pr.dbf') to &(cdir+'proveed.dbf')

   //publicaciones
	Db_OpenNoIndex("PUBLICA", "PU")
	oProgress:SetRange( 0, RecCount() )
	Ut_ResetMeter( oProgress, @nProgress )
	DbCloseAll()
   oSay:SetText(i18n("Actualizando fichero de Publicaciones"))
   DbCreate(cDir+'pu', {{'PUNOMBRE'    , 'C',  50,   0} ,;
                        {'PUPERIOD'    , 'C',  10,   0} ,;
                        {'PUPRECIO'    , 'N',   8,   2} ,;
                        {'PUTIPO'      , 'N',   1,   0} ,;
                        {'PUEDITOR'    , 'C',  50,   0} ,;
                        {'PUDIRECC'    , 'C',  50,   0} ,;
                        {'PUlocalI'    , 'C',  50,   0} ,;
                        {'PUPAIS'      , 'C',  20,   0} ,;
                        {'PUTELEFONO'  , 'C',  30,   0} ,;
                        {'PUFAX'       , 'C',  30,   0} ,;
                        {'PUEMAIL'     , 'C',  50,   0} ,;
                        {'PUURL'       , 'C',  50,   0} ,;
                        {'PUNOTAS'     , 'C', 255,   0} ,;
                        {'PUSUSCRIP'   , 'L',   1,   0} ,;
                        {'PUPRESUS'    , 'N',   8,   2} ,;
                        {'PUFCHPAGO'   , 'D',   8,   0} ,;
                        {'PUFCHCAD'    , 'D',   8,   0} ,;
                        {'PURECETAS'   , 'N',   5,   0}}, 'DBFCDX' )
   close all
   use &(cDir+'pu') new
   select pu
   if FILE(cDir+'PUBLICA.DBF')
      delete file &(cdir+'publica.cdx')
      append from &(cdir+'publica') WHILE Ut_dbfmeter( oProgress, @nProgress )
      dbcommitall()
      close all
      delete file &(cdir+'publica.dbf')
   endif
   close all
   rename &(cdir+'pu.dbf') to &(cdir+'publica.dbf')

   //recetas
   oSay:SetText(i18n("Actualizando fichero de Recetas"))
	Db_OpenNoIndex("RECETAS", "RE")
	oProgress:SetRange( 0, RecCount() )
	Ut_ResetMeter( oProgress, @nProgress )
	DbCloseAll()
   if FILE(cDir+'RECETAS.DBF')
      use &(cDir+'recetas') new
      if len(str(REEPOCA)) == 1
         lEpoca := .t.
      else
         lEpoca := .f.
      endif
      DbCloseAll()
   else
      lEpoca := .f.
   endif
	//nS1 := Seconds()
   DbCreate(cDir+'re', {{'RECODIGO'    , 'C',  10,   0} ,;
                        {'RETITULO'    , 'C',  60,   0} ,;
                        {'REPLATO'     , 'C',   1,   0} ,;
                        {'RETIPO'      , 'C',  30,   0} ,;
                        {'RETIPOCOC'   , 'C',  30,   0} ,;
                        {'REEPOCA'     , 'N',   4,   0} ,;
                  		{'REINGPRI'    , 'C',  20,   0} ,; // ingrediente principal
                        {'RECOMENS'    , 'N',   3,   0} ,;
                        {'REINGRED'    , 'M',  10,   0} ,;
                        {'REPREPAR'    , 'M',  10,   0} ,;
                        {'RETIEMPO'    , 'C',  10,   0} ,;
                        {'REDifICU'    , 'N',   1,   0} ,;
                        {'REPRECIO'    , 'N',   8,   2} ,;
                        {'REPPC'       , 'N',   8,   2} ,;
                        {'RECALORI'    , 'N',   1,   0} ,;
                        {'RETRUCOS'    , 'M',  10,   0} ,;
                        {'REVINO'      , 'M',  10,   0} ,;
                        {'REPUBLICA'   , 'C',  50,   0} ,;
                        {'REAUTOR'     , 'C',  50,   0} ,;
                        {'REFRCARGO'   , 'C',  10,   0} ,;
                        {'REFRTIPO'    , 'C',  30,   0} ,;
                        {'REEMAIL'     , 'C',  50,   0} ,;
                        {'REPAIS'      , 'C',  20,   0} ,;
                        {'RENUMERO'    , 'N',   4,   0} ,;
                        {'REPAGINA'    , 'N',   4,   0} ,;
                        {'RESELECC'    , 'C',   1,   0} ,;
                        {'REIMAGEN'    , 'C', 120,   0} ,;
                        {'REESCAN'     , 'N',   8,   2} ,; // precio escandallo
                        {'REMULTIP'    , 'N',   5,   2} ,; // multiplicador
                        {'REPFINAL'    , 'N',   8,   2} ,; // precio escandallo
                        {'REREFEREN'   , 'C',  20,   0} ,; // referencia ciclo formativo
                        {'REANOTACI'   , 'C',  60,   0} ,; // anotación del profesor
                        {'REFCHPREP'   , 'D',   8,   0} ,;
                        {'REVALORAC'   , 'C',  20,   0} ,; // valoración
                        {'REVAORDEN'   , 'N',   2,   0} ,; // orden de valoración
                        {'REUSUARIO'   , 'C',   5,   0} ,;
                        {'REINCORP'    , 'N',   1,   0} ,;
                        {'REFICHERO'   , 'C',  12,   0} ,;
                        {'REFCHINCO'   , 'D',   8,   0} ,;
                  		{'REEXPRES'    , 'L',   1,   0} ,; // receta express
            				{'REDIETAS'    , 'C', 200,   0} ,; // dietas
			               {'REURL'       , 'C',  90,   0} ,; // URL
                        {'RECOMESC'    , 'N',   3,   0} }, 'DBFCDX' ) // comensales para el escandallo
   close all
   use &(cDir+'re') new
   select re
   if FILE(cDir+'RECETAS.DBF')
      delete file &(cdir+'recetas.cdx')
      append from &(cdir+'recetas') WHILE Ut_dbfmeter( oProgress, @nProgress )
      dbcommitall()
      if lEpoca
         DbGoTop()
         REPLACE REEPOCA WITH 1111 FOR REEPOCA = 1
         DbGoTop()
         REPLACE REEPOCA WITH 0001 FOR REEPOCA = 2
         DbGoTop()
         REPLACE REEPOCA WITH 0100 FOR REEPOCA = 3
      endif
      close all
      delete file &(cdir+'recetas.dbf')
      delete file &(cdir+'recetas.fpt')
   endif
   close all
   rename &(cdir+'re.dbf') to &(cdir+'recetas.dbf')
   rename &(cDir+'re.fpt') to &(cDir+'recetas.fpt')
   close all
	// ? Seconds() - nS1
   //valoraciones
   oSay:SetText(i18n("Actualizando fichero de Valoraciones"))
	Db_OpenNoIndex("VALORAC", "VA")
	oProgress:SetRange( 0, RecCount() )
	Ut_ResetMeter( oProgress, @nProgress )
	DbCloseAll()
   DbCreate(cDir+'va', {{'VAORDEN'     , 'N',   2,   0},;
                        {'VAVALORAC'   , 'C',  20,   0},;
                        {'VARECETAS'   , 'N',   5,   0}}, 'DBFCDX' )
   close all
   use &(cDir+'va') new
   select va
   if FILE(cDir+'VALORAC.DBF')
      delete file &(cdir+'valorac.cdx')
      append from &(cdir+'valorac') WHILE Ut_dbfmeter( oProgress, @nProgress )
      dbcommitall()
      close all
      delete file &(cdir+'valorac.dbf')
   endif
   close all
   rename &(cdir+'va.dbf') to &(cdir+'valorac.dbf')
   close all

   //menus
   oSay:SetText(i18n("Actualizando fichero de Menús"))
	Db_OpenNoIndex("MENUS", "ME")
	oProgress:SetRange( 0, RecCount() )
	Ut_ResetMeter( oProgress, @nProgress )
	DbCloseAll()
   DbCreate(cDir+'me', {{'MECODIGO'    , 'C',  10,   0},;
                        {'MEDESCRIP'   , 'C',  60,   0},;
                        {'MEFCHPREP'   , 'D',   8,   0},;
								{'MECOMENS'    , 'N',   3,   0}}, 'DBFCDX' )
   close all
   use &(cDir+'me') new
   select me
   if FILE(cDir+'MENUS.DBF')
      delete file &(cdir+'menus.cdx')
      append from &(cdir+'menus') WHILE Ut_dbfmeter( oProgress, @nProgress )
      dbcommitall()
      close all
      delete file &(cdir+'menus.dbf')
   endif
   close all
   rename &(cdir+'me.dbf') to &(cdir+'menus.dbf')
   close all

	//recetas de los menus
   oSay:SetText(i18n("Actualizando fichero de recetas de menús"))
	Db_OpenNoIndex("RECEMENU", "RM")
	oProgress:SetRange( 0, RecCount() )
	Ut_ResetMeter( oProgress, @nProgress )
	DbCloseAll()
   DbCreate(cDir+'rm', {{'RMMECODIGO'    , 'C',  10,   0},;
                        {'RMRECODIGO'    , 'C',  10,   0},;
                        {'RMCOMENSAL'    , 'N',   3,   0}}, 'DBFCDX' )
   close all
   use &(cDir+'rm') new
   select rm
   if FILE(cDir+'RECEMENU.DBF')
      delete file &(cdir+'recemenu.cdx')
      append from &(cdir+'recemenu') WHILE Ut_dbfmeter( oProgress, @nProgress )
      dbcommitall()
      close all
      delete file &(cdir+'recemenu.dbf')
   endif
   close all
   rename &(cdir+'rm.dbf') to &(cdir+'recemenu.dbf')
   close all

	//menus semanales
   oSay:SetText(i18n("Actualizando fichero de Menús Semanales"))
	Db_OpenNoIndex("MENUSEM", "MS")
	oProgress:SetRange( 0, RecCount() )
	Ut_ResetMeter( oProgress, @nProgress )
	DbCloseAll()
   DbCreate(cDir+'ms', {{'MSCODIGO'    , 'C',  10,   0},;
                        {'MSDESCRIP'   , 'C',  60,   0},;
                        {'MSFCHPREP'   , 'D',   8,   0},;
			               {'MSCOMENS'    , 'N',   3,   0}}, 'DBFCDX' )
   close all
   use &(cDir+'ms') new
   select ms
   if FILE(cDir+'MENUSEM.DBF')
      delete file &(cdir+'menusem.cdx')
      append from &(cdir+'menusem') WHILE Ut_dbfmeter( oProgress, @nProgress )
      dbcommitall()
      close all
      delete file &(cdir+'menusem.dbf')
   endif
   close all
   rename &(cdir+'ms.dbf') to &(cdir+'menusem.dbf')
   close all

	//recetas de los menus
   oSay:SetText(i18n("Actualizando fichero de recetas de menús semanales"))
	Db_OpenNoIndex("REMESEM", "RS")
	oProgress:SetRange( 0, RecCount() )
	Ut_ResetMeter( oProgress, @nProgress )
	DbCloseAll()
   DbCreate(cDir+'rs', {{'RSMSCODIGO'    , 'C',  10,   0},; // Código del menú
                        {'RSRECODIGO'    , 'C',  10,   0},; // código de la receta
                  		{'RSDIA'         , 'N',   1,   0},; // { l, m, x, j, v, s, d }
								{'RSCOMIDA'      , 'N',   1,   0},; // { d, x, c, m, c }
								{'RSFECHA'       , 'D',   8,   0},;
								{'RSHORA'        , 'C',   5,   0},;
                        {'RSCOMENSAL'    , 'N',   3,   0}}, 'DBFCDX' )
   close all
   use &(cDir+'rs') new
   select rs
   if FILE(cDir+'REMESEM.DBF')
      delete file &(cdir+'remesem.cdx')
      append from &(cdir+'remesem') WHILE Ut_dbfmeter( oProgress, @nProgress )
      dbcommitall()
      close all
      delete file &(cdir+'remesem.dbf')
   endif
   close all
   rename &(cdir+'rs.dbf') to &(cdir+'remesem.dbf')
   close all

   //dietas
   oSay:SetText(i18n("Actualizando fichero de Dietas"))
	Db_OpenNoIndex("DIETAS", "DI")
	oProgress:SetRange( 0, RecCount() )
	Ut_ResetMeter( oProgress, @nProgress )
	DbCloseAll()
   DbCreate(cDir+'di', {{'DIDIETA'     , 'C',  20,   0},;
                        {'DIRECETAS'   , 'N',   5,   0}}, 'DBFCDX' )
   close all
   use &(cDir+'di') new
   select di
   if FILE(cDir+'DIETAS.DBF')
      delete file &(cdir+'dietas.cdx')
      append from &(cdir+'dietas') WHILE Ut_dbfmeter( oProgress, @nProgress )
      dbcommitall()
      close all
      delete file &(cdir+'dietas.dbf')
   endif
   close all
   rename &(cdir+'di.dbf') to &(cdir+'dietas.dbf')
   close all

	//ubicaciones
	oSay:SetText(i18n("Actualizando fichero de Ubicaciones"))
	Db_OpenNoIndex("UBICACI", "UB")
	oProgress:SetRange( 0, RecCount() )
	Ut_ResetMeter( oProgress, @nProgress )
	DbCloseAll()
	DbCreate(cDir+'ub', {{'UBUBICACI'   , 'C',  40,   0},;
								{'UBALIMENT'   , 'N',   5,   0}}, 'DBFCDX' )
	close all
	use &(cDir+'ub') new
	select ub
	if FILE(cDir+'UBICACI.DBF')
		delete file &(cdir+'ubicaci.cdx')
		append from &(cdir+'ubicaci') WHILE Ut_dbfmeter( oProgress, @nProgress )
		dbcommitall()
		close all
		delete file &(cdir+'ubicaci.dbf')
	endif
	close all
	rename &(cdir+'ub.dbf') to &(cdir+'ubicaci.dbf')
	close all

	//acciones para bcnkitchen
	oSay:SetText(i18n("Actualizando fichero de acciones"))
	Db_OpenNoIndex("ACCION", "AC")
	oProgress:SetRange( 0, RecCount() )
	Ut_ResetMeter( oProgress, @nProgress )
	DbCloseAll()
	DbCreate(cDir+'ac', {{'ACACCION'    , 'C',   8,   0},;
								{'ACALIMENT'   , 'N',   5,   0}}, 'DBFCDX' )
	close all
	use &(cDir+'ac') new
	select ac
	if FILE(cDir+'ACCION.DBF')
		delete file &(cdir+'accion.cdx')
		append from &(cdir+'accion') WHILE Ut_dbfmeter( oProgress, @nProgress )
		dbcommitall()
		close all
		delete file &(cdir+'accion.dbf')
	endif
	close all
	rename &(cdir+'ac.dbf') to &(cdir+'accion.dbf')
	close all
   CursorArrow()
   oDlgProgress:End()
return nil

/*_____________________________________________________________________________*/
Function Ut_dbfmeter( oProgress, nProgress )
	local lReturn
	nProgress++
	if mod(nProgress,100)==0
		oProgress:SetPos(nProgress)
	endif
	if nProgress <= oProgress:nMax
		lReturn := .t.
	else
		lReturn := .f.
	endif
return lReturn
/*_____________________________________________________________________________*/

function Ut_Indexar()
   local oDlgProgress, oSay01, oSay02, oBmp, oProgress
   local nVar   := 0

   if oApp():oDlg != nil
      if oApp():nEdit > 0
         return nil
      else
         oApp():oDlg:End()
         SysRefresh()
      endif
   endif

   DEFINE DIALOG oDlgProgress RESOURCE 'UT_INDEXAR_'+oApp():cLanguage OF oApp():oWndMain FONT oApp():oFont

   REDEFINE BITMAP oBmp ID 111 OF oDlgProgress RESOURCE 'BB_INDEX' TRANSPARENT
   REDEFINE SAY oSay01 ID 99  OF oDlgProgress
   REDEFINE SAY oSay02 PROMPT space(30) ID 10  OF oDlgProgress
   oProgress := TProgress():Redefine( 101, oDlgProgress )

   oDlgProgress:bStart := { || SysRefresh(), Ut_CrearCdx(oSay02, oProgress), oDlgProgress:End() }

   ACTIVATE DIALOG oDlgProgress ;
      ON INIT DlgCenter(oDlgProgress,oApp():oWndMain)

   MsgInfo( i18n( "La regeneración de índices se realizó correctamente." ) )

return nil
/*___________________________________________________________________________*/

function Ut_CrearCdx(oSay, oProgress, lMsg)
   local i := 0
   local nprogress   := 0
   local nIndices := '7'
   local cDir     := oApp():cDbfPath
   local cEsUnico
	local aDietas := {}
   FIELD AuNombre, AuPais, AuURL
	FIELD IpIngred
   FIELD AlAlimento, AlCodigo, AlUltCom, AlProveed, AlTipo, AlUbicaci, AlAccion
   FIELD GrTipo, PlPlato, PlTipo
   FIELD FrN1, FrN2, FrN3, FrN4, FrN5, FrTipo
   FIELD PrNombre, PrPais, Prlocali
   FIELD PuNombre, PuPais, PuPeriod, PuFchCad
   FIELD ReTitulo, ReCodigo, RePlato, ReTipo,ReTipoCoc, ReFrTipo, ReIngPri,;
 			ReAutor, RePublica, ReVaOrden, ReReferen, ReValorac, ReFchPrep, ReSelecc
   FIELD EsReceta, EsIngred, EsIndenomi, EsProveed, EsFecha, EsHora, VaOrden, VaValorac
	FIELD MeCodigo, MeDescrip, MeFchPrep
	FIELD RmMeCodigo
	FIELD MsCodigo, MsDescrip, MsFchPrep
	FIELD RsMsCodigo, RsReCodigo
	FIELD DiDieta
	FIELD UbUbicaci
	FIELD AcAccion


   // ___ Autores ___________________________________________________________

   CursorWait()

   if File(cDir+'AUTORES.CDX')
      delete file &(cDir+'autores.cdx')
   endif
   Db_OpenNoIndex('autores',)
   oSay:SetText(i18n("Fichero de autores"))
   DbPack()
   oProgress:SetRange( 0, RecCount() )
   Ut_ResetMeter( oProgress, @nProgress )
   INDEX ON UPPER(AuNombre) TAG nombre FOR ! Deleted() eval (oProgress:SetPos(nProgress++), Sysrefresh()) EVERY 1
   Ut_ResetMeter( oProgress, @nProgress )
   INDEX ON UPPER(AuPais)   TAG pais   FOR ! Deleted() EVAL (oProgress:SetPos(nProgress++), Sysrefresh()) EVERY 1
   Ut_ResetMeter( oProgress, @nProgress )
   INDEX ON UPPER(AuURL)    TAG url    FOR ! Deleted() EVAL (oProgress:SetPos(nProgress++), Sysrefresh()) EVERY 1

   // ___ Ingredientes para escandallo __________________________________________________
   if File(cDir+'ALIMENTO.CDX')
      delete file &(cDir+'alimento.cdx')
   endif
   Db_OpenNoIndex('alimento',)
   oSay:SetText(i18n("Fichero de ingredientes"))
   DbPack()
   oProgress:SetRange( 0, RecCount() )
   Ut_ResetMeter( oProgress, @nProgress )
   INDEX ON UPPER( AlAlimento )        TAG AL01 FOR ! Deleted() EVAL (oProgress:SetPos(nProgress++), Sysrefresh()) EVERY 1
   Ut_ResetMeter( oProgress, @nProgress )
   INDEX ON UPPER( AlTipo+AlAlimento ) TAG AL02 FOR ! Deleted() EVAL (oProgress:SetPos(nProgress++), Sysrefresh()) EVERY 1
   Ut_ResetMeter( oProgress, @nprogress )
   INDEX ON UPPER( AlCodigo )          TAG AL03 FOR ! Deleted() EVAL (oProgress:SetPos(nprogress++), Sysrefresh()) EVERY 1
   Ut_ResetMeter( oProgress, @nProgress )
   INDEX ON DtoS( AlUltCom )           TAG AL04 FOR ! Deleted() EVAL (oProgress:SetPos(nProgress++), Sysrefresh()) EVERY 1
   Ut_ResetMeter( oProgress, @nProgress )
   INDEX ON UPPER( AlProveed+AlAlimento ) TAG AL05 FOR ! Deleted() EVAL (oProgress:SetPos(nProgress++), Sysrefresh()) EVERY 1
   Ut_ResetMeter( oProgress, @nProgress )
   INDEX ON UPPER( AlUbicaci+AlAlimento ) TAG AL06 FOR ! Deleted() EVAL (oProgress:SetPos(nProgress++), Sysrefresh()) EVERY 1
	Ut_ResetMeter( oProgress, @nProgress )
   INDEX ON UPPER( AlAccion+AlAlimento ) TAG AL07 FOR ! Deleted() EVAL (oProgress:SetPos(nProgress++), Sysrefresh()) EVERY 1
   DbCloseAll()

   // ___ Grupos de Ingredientes ______________________________________________
   if File(cDir+'GRUPOS.CDX')
      delete file &(cDir+'grupos.cdx')
   endif
   Db_OpenNoIndex('Grupos',)
   oSay:SetText(i18n("Fichero de grupos de ingredientes"))
   DbPack()
   oProgress:SetRange( 0, RecCount() )
   Ut_ResetMeter( oProgress, @nProgress )
   INDEX ON UPPER( GrTipo )   TAG GR01 FOR ! Deleted() EVAL (oProgress:SetPos(nProgress++), Sysrefresh()) EVERY 1
   DbCloseAll()

   // ___ Ingrediente principal ______________________________________________
   if File(cDir+'INGREDIP.CDX')
      delete file &(cDir+'ingredip.cdx')
   endif
   Db_OpenNoIndex('Ingredip',)
   oSay:SetText(i18n("Fichero de ingrediente principal"))
   DbPack()
   oProgress:SetRange( 0, RecCount() )
   Ut_ResetMeter( oProgress, @nProgress )
   INDEX ON UPPER( IpIngred )   TAG IP01 FOR ! Deleted() EVAL (oProgress:SetPos(nProgress++), Sysrefresh()) EVERY 1
   DbCloseAll()

   // ___ fichero de tipo de plato y cocinado _________________________________
   if File(cDir+'PLATOS.CDX')
      delete file &(cDir+'platos.cdx')
   endif
   Db_OpenNoIndex('Platos',)
   oSay:SetText(i18n("Fichero de platos"))
   Platos->(DbGoTop())
   Delete for .NOT. (PlPlato $ '123456')
   DbPack()
   Platos->(DbGoTop())
   oProgress:SetRange( 0, RecCount() )
   Ut_ResetMeter( oProgress, @nProgress )
   INDEX ON UPPER(PlPlato+PlTipo) TAG PL0 FOR ! Deleted() EVAL (oProgress:SetPos(nProgress++), Sysrefresh()) EVERY 1
   Ut_ResetMeter( oProgress, @nProgress )
   INDEX ON UPPER(PlTipo) TAG PL1 FOR PlPlato=='1' .AND. ! Deleted() EVAL (oProgress:SetPos(nProgress++), Sysrefresh()) EVERY 1
   Ut_ResetMeter( oProgress, @nProgress )
   INDEX ON UPPER(PlTipo) TAG PL2 FOR PlPlato=='2' .AND. ! Deleted() EVAL (oProgress:SetPos(nProgress++), Sysrefresh()) EVERY 1
   Ut_ResetMeter( oProgress, @nProgress )
   INDEX ON UPPER(PlTipo) TAG PL3 FOR PlPlato=='3' .AND. ! Deleted() EVAL (oProgress:SetPos(nProgress++), Sysrefresh()) EVERY 1
   Ut_ResetMeter( oProgress, @nProgress )
   INDEX ON UPPER(PlTipo) TAG PL4 FOR PlPlato=='4' .AND. ! Deleted() EVAL (oProgress:SetPos(nProgress++), Sysrefresh()) EVERY 1
   Ut_ResetMeter( oProgress, @nProgress )
   INDEX ON UPPER(PlTipo) TAG PL5 FOR PlPlato=='5' .AND. ! Deleted() EVAL (oProgress:SetPos(nProgress++), Sysrefresh()) EVERY 1
   Ut_ResetMeter( oProgress, @nProgress )
   INDEX ON UPPER(PlTipo) TAG PL6 FOR PlPlato=='6' .AND. ! Deleted() EVAL (oProgress:SetPos(nProgress++), Sysrefresh()) EVERY 1
   Ut_ResetMeter( oProgress, @nProgress )
   INDEX ON UPPER(PlTipo) TAG PL7 FOR ! Deleted() EVAL (oProgress:SetPos(nProgress++), Sysrefresh()) EVERY 1
	Ut_ResetMeter( oProgress, @nProgress )
   INDEX ON UPPER(PlPlato+PlTipo) TAG PL8 FOR PlPlato != '6' .AND. ! Deleted() EVAL (oProgress:SetPos(nProgress++), Sysrefresh()) EVERY 1
   DbCloseAll()

   // ___ fichero de clasificación francesa ___________________________________
   if File(cDir+'FRANCESA.CDX')
      delete file &(cDir+'francesa.cdx')
   endif
   USE &(cDir+'francesa') NEW
   if NetErr()
      MsgStop('Ha sucedido un error al abrir un fichero.'+;
              CRLF+'Por favor reinicie el programa.')
      close all
      return nil
   endif
   oSay:SetText('Clasificación francesa')
   Francesa->(DbGoTop())
   nProgress := 0
   oProgress:SetRange( 0, RecCount() )
   oProgress:SetPos(nProgress)
   sysrefresh()
   INDEX ON Str(FRN1,2)+Str(FRN2,2)+Str(FRN3,2)+Str(FRN4,2)+Str(FRN5,2)+FrTipo TAG FR0 FOR ! Deleted() EVAL (oProgress:SetPos(nProgress++), Sysrefresh()) EVERY 1
   nProgress := 0
   oProgress:SetPos(nProgress)
   sysrefresh()
   INDEX ON UPPER(FrTipo) TAG FR1 FOR ! Deleted() EVAL (oProgress:SetPos(nProgress++), Sysrefresh()) EVERY 1
   DbCloseAll()

   // ___ Proveedores _________________________________________________________
   if File(cDir+'PROVEED.CDX')
      delete file &(cDir+'proveed.cdx')
   endif
   Db_OpenNoIndex('Proveed',)
   oSay:SetText(i18n("Fichero de proveedores"))
   DbPack()
   oProgress:SetRange( 0, RecCount() )
   Ut_ResetMeter( oProgress, @nProgress )
   INDEX ON UPPER(PrNombre) TAG nombre FOR ! Deleted() EVAL (oProgress:SetPos(nProgress++), Sysrefresh()) EVERY 1
   Ut_ResetMeter( oProgress, @nProgress )
   INDEX ON UPPER(PrPais)   TAG pais   FOR ! Deleted() EVAL (oProgress:SetPos(nProgress++), Sysrefresh()) EVERY 1
   Ut_ResetMeter( oProgress, @nProgress )
   INDEX ON UPPER(Prlocali) TAG locali FOR ! Deleted() EVAL (oProgress:SetPos(nProgress++), Sysrefresh()) EVERY 1
   DbCloseAll()


   // ___ Publicaciones _______________________________________________________
   if File(cDir+'PUBLICA.CDX')
      delete file &(cDir+'publica.cdx')
   endif
   Db_OpenNoIndex('publica',)
   oSay:SetText(i18n("Fichero de publicaciones"))
   DbPack()
   oProgress:SetRange( 0, RecCount() )
   Ut_ResetMeter( oProgress, @nProgress )
   INDEX ON UPPER(PuNombre) TAG PU1  FOR ! Deleted() EVAL (oProgress:SetPos(nProgress++), Sysrefresh()) EVERY 1
   Ut_ResetMeter( oProgress, @nProgress )
   INDEX ON UPPER(PuPais) TAG PU2  FOR ! Deleted() EVAL (oProgress:SetPos(nProgress++), Sysrefresh()) EVERY 1
   Ut_ResetMeter( oProgress, @nProgress )
   INDEX ON UPPER(PuPeriod) TAG PU3  FOR ! Deleted() EVAL (oProgress:SetPos(nProgress++), Sysrefresh()) EVERY 1
   Ut_ResetMeter( oProgress, @nProgress )
   INDEX ON DtoS(PuFchCad)  TAG PU4  FOR ! Deleted() EVAL (oProgress:SetPos(nProgress++), Sysrefresh()) EVERY 1
   DbCloseAll()

   // ___ Recetas _____________________________________________________________
   if File(cDir+'RECETAS.CDX')
      delete file &(cDir+'recetas.cdx')
   endif
   Db_OpenNoIndex('Recetas',)
   oSay:SetText(i18n("Depuración de recetas"))

   oSay:SetText(i18n("Fichero de recetas"))
   oProgress:SetRange( 0, RecCount()/50 )
   Ut_ResetMeter( oProgress, @nProgress )
   INDEX ON UPPER(ReTitulo) TAG RE01   FOR ! Deleted() EVAL (oProgress:SetPos(nProgress+=50), Sysrefresh()) EVERY 50
   Ut_ResetMeter( oProgress, @nProgress )
   INDEX ON UPPER(ReCodigo) TAG RE02   FOR ! Deleted() EVAL (oProgress:SetPos(nProgress+=50), Sysrefresh()) EVERY 50
   Ut_ResetMeter( oProgress, @nProgress )
   INDEX ON UPPER(RePlato+Retipo+ReTitulo) TAG RE03 FOR ! Deleted() EVAL (oProgress:SetPos(nProgress+=50), Sysrefresh()) EVERY 50
   Ut_ResetMeter( oProgress, @nProgress )
   INDEX ON UPPER(ReTipoCoc+ReTitulo) TAG RE04  FOR ! Deleted() EVAL (oProgress:SetPos(nProgress+=50), Sysrefresh()) EVERY 50
   Ut_ResetMeter( oProgress, @nProgress )
   INDEX ON UPPER(ReFrTipo+ReTitulo) TAG RE05   FOR ! Deleted() EVAL (oProgress:SetPos(nProgress+=50), Sysrefresh()) EVERY 50
   Ut_ResetMeter( oProgress, @nProgress )
   INDEX ON UPPER(ReIngPri+ReTitulo) TAG RE06   FOR ! Deleted() EVAL (oProgress:SetPos(nProgress+=50), Sysrefresh()) EVERY 50
   Ut_ResetMeter( oProgress, @nProgress )
   INDEX ON UPPER(ReAutor+ReTitulo) TAG RE07 FOR ! Deleted() EVAL (oProgress:SetPos(nProgress+=50), Sysrefresh()) EVERY 50
   Ut_ResetMeter( oProgress, @nProgress )
   INDEX ON UPPER(RePublica+ReTitulo) TAG RE08 FOR ! Deleted() EVAL (oProgress:SetPos(nProgress+=50), Sysrefresh()) EVERY 50
   Ut_ResetMeter( oProgress, @nProgress )
   INDEX ON StrZero(ReVaOrden,2)+ReTitulo  TAG RE09 FOR ! Deleted() EVAL (oProgress:SetPos(nProgress+=50), Sysrefresh()) EVERY 50
   Ut_ResetMeter( oProgress, @nProgress )
   INDEX ON UPPER(ReReferen) TAG RE10 FOR ! Deleted() EVAL (oProgress:SetPos(nProgress+=50), Sysrefresh()) EVERY 50
   Ut_ResetMeter( oProgress, @nProgress )
	INDEX ON DtoS(ReFchPrep) TAG RE11 FOR ! Deleted() EVAL (oProgress:SetPos(nProgress+=50), Sysrefresh()) EVERY 50
   Ut_ResetMeter( oProgress, @nProgress )
   INDEX ON UPPER(retitulo) TAG RE12 FOR ReSelecc == 'X' .AND. ! Deleted() EVAL (oProgress:SetPos(nProgress+=50), Sysrefresh()) EVERY 50
   Ut_ResetMeter( oProgress, @nProgress )
   INDEX ON UPPER(retipo+retitulo) TAG RE13 FOR ! Deleted() EVAL (oProgress:SetPos(nProgress+=50), Sysrefresh()) EVERY 50
   Ut_ResetMeter( oProgress, @nProgress )
   INDEX ON UPPER(revalorac+retitulo) TAG RE14  FOR ! Deleted() EVAL (oProgress:SetPos(nProgress+=50), Sysrefresh()) EVERY 50
   DbCloseAll()

   //___ fichero de escandallo ________________________________________________
   Close ALL
   if File(cDir+'ESCANDA.CDX')
      delete file escanda.cdx
   endif
   Db_OpenNoIndex('Escanda',)
   oSay:SetText('Fichero de escandallos')
   DbPack()
   oProgress:SetRange( 0, RecCount() )
   Ut_ResetMeter( oProgress, @nProgress )
   INDEX ON UPPER(EsReceta)     TAG receta  FOR ! Deleted() EVAL (oProgress:SetPos(nProgress++), Sysrefresh()) EVERY 1
   Ut_ResetMeter( oProgress, @nProgress )
   INDEX ON UPPER(EsIngred)     TAG ingred  FOR ! Deleted() EVAL (oProgress:SetPos(nProgress++), Sysrefresh()) EVERY 1
   Ut_ResetMeter( oProgress, @nProgress )
   INDEX ON UPPER(EsReceta+EsIngred) TAG duplica FOR ! Deleted() EVAL (oProgress:SetPos(nProgress++), Sysrefresh()) EVERY 1
   DbCloseAll()

	//___ fichero temporal de escandallo _______________________________________
   if File(cDir+'TEMPESC.CDX')
      delete file tempesc.cdx
   endif
   Db_OpenNoIndex('Tempesc',)
   oSay:SetText('Fichero de escandallos')
   DbPack()
   oProgress:SetRange( 0, RecCount() )
   Ut_ResetMeter( oProgress, @nProgress )
   INDEX ON UPPER(EsIndenomi)  TAG TS01  FOR ! Deleted() EVAL (oProgress:SetPos(nProgress++), Sysrefresh()) EVERY 1
   Ut_ResetMeter( oProgress, @nProgress )
   INDEX ON UPPER(EsIngred)    TAG TS02  FOR ! Deleted() EVAL (oProgress:SetPos(nProgress++), Sysrefresh()) EVERY 1
   Ut_ResetMeter( oProgress, @nProgress )
	INDEX ON UPPER(EsProveed)+Upper(EsIngred)  TAG TS03  FOR ! Deleted() EVAL (oProgress:SetPos(nProgress++), Sysrefresh()) EVERY 1
	Ut_ResetMeter( oProgress, @nProgress )
	// se usa en BcnKitchen3
	INDEX ON Dtos(EsFecha)+EsHora+UPPER(EsProveed)+Upper(EsIngred)  TAG TS04  FOR ! Deleted() EVAL (oProgress:SetPos(nProgress++), Sysrefresh()) EVERY 1
	Ut_ResetMeter( oProgress, @nProgress )
	// se usa en BcnKitchen2
	INDEX ON UPPER(EsProveed)+Dtos(EsFecha)+EsHora+Upper(EsReceta)+Upper(EsIngred)  TAG TS05  FOR ! Deleted() EVAL (oProgress:SetPos(nProgress++), Sysrefresh()) EVERY 1
   DbCloseAll()

   //___ fichero de valoraciones ______________________________________________
   if File(cDir+'VALORAC.CDX')
      delete file valorac.cdx
   endif
   Db_OpenNoIndex('valorac',)
   oSay:SetText('Fichero de valoraciones')
   DbPack()
   oProgress:SetRange( 0, RecCount() )
   Ut_ResetMeter( oProgress, @nProgress )
   INDEX ON Vaorden  TAG VA01  FOR ! Deleted() EVAL (oProgress:SetPos(nProgress++), Sysrefresh()) EVERY 1
   Ut_ResetMeter( oProgress, @nProgress )
   INDEX ON UPPER(VaValorac) TAG VA02  FOR ! Deleted() EVAL (oProgress:SetPos(nProgress++), Sysrefresh()) EVERY 1
   DbCloseAll()

	//___ fichero de menus _____________________________________________________
	if File(cDir+'MENUS.CDX')
      delete file menus.cdx
   endif
   Db_OpenNoIndex('menus',)
   oSay:SetText('Fichero de menús')
   DbPack()
   oProgress:SetRange( 0, RecCount() )
   Ut_ResetMeter( oProgress, @nProgress )
   INDEX ON Upper(MeCodigo)  TAG ME01  FOR ! Deleted() EVAL (oProgress:SetPos(nProgress++), Sysrefresh()) EVERY 1
   Ut_ResetMeter( oProgress, @nProgress )
   INDEX ON UPPER(MeDescrip) TAG ME02  FOR ! Deleted() EVAL (oProgress:SetPos(nProgress++), Sysrefresh()) EVERY 1
	Ut_ResetMeter( oProgress, @nProgress )
   INDEX ON DtoS(MeFchPrep)  TAG ME03  FOR ! Deleted() EVAL (oProgress:SetPos(nProgress++), Sysrefresh()) EVERY 1
   DbCloseAll()

	//___ fichero de recetas de menus __________________________________________
	if File(cDir+'RECEMENU.CDX')
      delete file recemenu.cdx
   endif
   Db_OpenNoIndex('recemenu',)
   oSay:SetText('Fichero de recetas de menús')
   DbPack()
   oProgress:SetRange( 0, RecCount() )
   Ut_ResetMeter( oProgress, @nProgress )
   INDEX ON Upper(RmMeCodigo) TAG RM01  FOR ! Deleted() EVAL (oProgress:SetPos(nProgress++), Sysrefresh()) EVERY 1
   DbCloseAll()

	//___ fichero de menus semanales _____________________________________________
	if File(cDir+'MENUSEM.CDX')
      delete file menusem.cdx
   endif
   Db_OpenNoIndex('menusem',)
   oSay:SetText('Fichero de menús semanales')
   DbPack()
   oProgress:SetRange( 0, RecCount() )
   Ut_ResetMeter( oProgress, @nProgress )
   INDEX ON Upper(MsCodigo)  TAG MS01  FOR ! Deleted() EVAL (oProgress:SetPos(nProgress++), Sysrefresh()) EVERY 1
   Ut_ResetMeter( oProgress, @nProgress )
   INDEX ON UPPER(MsDescrip) TAG MS02  FOR ! Deleted() EVAL (oProgress:SetPos(nProgress++), Sysrefresh()) EVERY 1
	Ut_ResetMeter( oProgress, @nProgress )
   INDEX ON DtoS(MsFchPrep)  TAG MS03  FOR ! Deleted() EVAL (oProgress:SetPos(nProgress++), Sysrefresh()) EVERY 1
   DbCloseAll()

	//___ fichero de recetas de menus semanales __________________________________
	if File(cDir+'REMESEM.CDX')
      delete file remesem.cdx
   endif
   Db_OpenNoIndex('remesem',)
   oSay:SetText('Fichero de recetas de menús semanales')
   DbPack()
   oProgress:SetRange( 0, RecCount() )
   Ut_ResetMeter( oProgress, @nProgress )
   INDEX ON Upper(RsMsCodigo)+Upper(RsReCodigo) TAG RS01  FOR ! Deleted() EVAL (oProgress:SetPos(nProgress++), Sysrefresh()) EVERY 1
   DbCloseAll()

	//___ fichero de dietas ______________________________________________________
	if File(cDir+'DIETAS.CDX')
      delete file dietas.cdx
   endif
   Db_OpenNoIndex('dietas',)
   oSay:SetText('Fichero de dietas y tolerancias')
   DbPack()
   oProgress:SetRange( 0, RecCount() )
   Ut_ResetMeter( oProgress, @nProgress )
   INDEX ON Upper(DiDieta) TAG DI01  FOR ! Deleted() EVAL (oProgress:SetPos(nProgress++), Sysrefresh()) EVERY 1
   DbCloseAll()

	//___ fichero de dietas ______________________________________________________
	if File(cDir+'UBICACI.CDX')
		delete file ubicaci.cdx
	endif
	Db_OpenNoIndex('ubicaci',)
	oSay:SetText('Fichero de ubicaciones de alimentos')
	DbPack()
	oProgress:SetRange( 0, RecCount() )
	Ut_ResetMeter( oProgress, @nProgress )
	INDEX ON Upper(UbUbicaci) TAG UB01  FOR ! Deleted() EVAL (oProgress:SetPos(nProgress++), Sysrefresh()) EVERY 1
	DbCloseAll()

	//___ fichero de acciones ____________________________________________________
	if File(cDir+'ACCION.CDX')
		delete file accion.cdx
	endif
	Db_OpenNoIndex('accion',)
	oSay:SetText('Fichero de acciones con alimentos')
	DbPack()
	oProgress:SetRange( 0, RecCount() )
	Ut_ResetMeter( oProgress, @nProgress )
	INDEX ON Upper(AcAccion) TAG AC01  FOR ! Deleted() EVAL (oProgress:SetPos(nProgress++), Sysrefresh()) EVERY 1
	DbCloseAll()
	
	// ____________ Incorporación de datos de andesfood
	//  andesfood()

   // __ comprobación de integridad de tipos de plato _________________________
   oSay:SetText('Comprobando integridad')

   if ! Db_Open('PLATOS','PL')
      return nil
   endif
   replace all PL->PlRecetas with 0
	PL->(DbSetOrder(1))
   PL->(DbGoTop())

   if ! Db_Open('VALORAC','VA')
      return nil
   endif
   replace all VA->VaRecetas with 0
   VA->(DbSetOrder(2))
   VA->(DbGoTop())

   if ! Db_Open('AUTORES','AU')
      return nil
   endif
   replace all AU->AuRecetas with 0
   AU->(DbSetOrder(1))
   AU->(DbGoTop())

   if ! Db_Open('INGREDIP','IP')
      return nil
   endif
   replace all IP->IpRecetas with 0
   IP->(DbSetOrder(1))
   IP->(DbGoTop())

   if ! Db_Open('PUBLICA','PU')
      return nil
   endif
   replace all PU->PuRecetas with 0
   PU->(DbSetOrder(1))
   PU->(DbGoTop())

	if ! Db_Open('DIETAS','DI')
      return nil
   endif
   replace all DI->DiRecetas with 0
   DI->(DbSetOrder(1))
   DI->(DbGoTop())

   if ! Db_Open('RECETAS','RE')
      return nil
   endif
   nProgress := 0
   oProgress:SetRange(0,RecCount())
   oProgress:SetPos(nProgress)
   sysrefresh()
   RE->(DbSetOrder(1))
	RE->(DbGoTop())
	Replace all RE->ReTipo WITH Upper(RE->ReTipo)
   RE->(DbGoTop())
   DO WHILE ! RE->(EOF())
      if .NOT. RE->RePlato $ '12345'
         replace RE->RePlato with '1'
         MsgInfo('Se ha modificado el campo Tipo de Plato de la receta '+Rtrim(RE->ReTitulo))
      endif
      if RE->ReEpoca == 0
         replace RE->ReEpoca with 1
         MsgInfo('Se ha modificado el campo EPOCA de la receta '+Rtrim(RE->ReTitulo))
      endif
      if RE->ReEpoca == 2
         replace RE->ReEpoca with 1
         MsgInfo('Se ha modificado el campo EPOCA de la receta '+Rtrim(RE->ReTitulo))
      endif
      if RE->ReEpoca == 3
         replace RE->ReEpoca with 0100
         MsgInfo('Se ha modificado el campo EPOCA de la receta '+Rtrim(RE->ReTitulo))
      endif
      if RE->ReDificu == 0
         replace RE->ReDificu with 1
         MsgInfo('Se ha modificado el campo Dificultad de la receta '+Rtrim(RE->ReTitulo))
      endif
      if RE->ReCalori == 0
         replace RE->ReCalori with 1
         MsgInfo('Se ha modificado el campo Calorias de la receta '+Rtrim(RE->ReTitulo))
      endif
      if RE->ReIncorp == 0
         replace RE->ReIncorp with 1
      endif
      if ! empty(Rtrim(RE->ReTipo))
         if PL->(DbSeek(UPPER(RE->RePlato+RE->ReTipo)))
            Replace PL->PlRecetas with PL->PlRecetas + 1
         else
            PL->(DbAppend())
            Replace PL->PlTipo    with RE->ReTipo
            Replace PL->PlPlato   with RE->RePlato
            Replace PL->PlRecetas with 1
            PL->(DbCommit())
         endif
      endif
      if ! empty(Rtrim(RE->ReTipoCoc))
         if PL->(DbSeek('6'+UPPER(RE->ReTipoCoc)))
            Replace PL->PlRecetas with PL->PlRecetas + 1
         else
            PL->(DbAppend())
            Replace PL->PlTipo    with RE->ReTipoCoc
            Replace PL->PlPlato   with '6'
            Replace PL->PlRecetas with 1
            PL->(DbCommit())
         endif
      endif
		if ! empty(Rtrim(RE->ReIngPri))
         if IP->(DbSeek(UPPER(RE->ReIngPri)))
            Replace IP->IpRecetas with IP->IpRecetas + 1
         else
            IP->(DbAppend())
				Replace IP->IpIngred  with RE->ReIngPri
            Replace IP->IpRecetas with 1
            IP->(DbCommit())
         endif
      endif
      if ! empty(Rtrim(RE->ReValorac))
         if VA->(DbSeek(UPPER(RE->ReValorac)))
            REPLACE RE->ReVaOrden WITH VA->VaOrden
            Replace VA->VaRecetas with VA->VaRecetas + 1
         else
            VA->(DbAppend())
            Replace VA->VaOrden   with VA->(recno())
            Replace VA->VaValorac with RE->ReValorac
            Replace VA->VaRecetas with 1
            VA->(DbCommit())
            REPLACE RE->ReVaOrden WITH VA->VaOrden
         endif
      endif
      if ! empty(Rtrim(RE->ReAutor))
         if AU->(DbSeek(UPPER(RE->ReAutor)))
            Replace AU->AuRecetas with AU->AuRecetas + 1
         else
            AU->(DbAppend())
            Replace AU->AuNombre  with RE->ReAutor
            Replace AU->AuPais    with RE->RePais
            Replace AU->AuRecetas with 1
            AU->(DbCommit())
         endif
      endif
      if ! empty(Rtrim(RE->RePublica))
         if PU->(DbSeek(UPPER(RE->RePublica)))
            Replace PU->PuRecetas with PU->PuRecetas + 1
         else
            PU->(DbAppend())
            Replace PU->PuNombre  with RE->RePublica
            Replace PU->PuRecetas with 1
            PU->(DbCommit())
         endif
      endif
		if ! empty(Rtrim(RE->ReDietas))
			aDietas     := iif(AT(';',RE->ReDietas)!=0, HB_ATokens( RE->ReDietas, ";"), {})
			if Len(aDietas) > 1
				aSize( aDietas, len(aDietas)-1)
				for i:=1 to len(aDietas)
					aDietas[i] := alltrim(aDietas[i])
				next
				aDietas := ASort(aDietas)
				for i:=1 to len(aDietas)
					if DI->(DbSeek(UPPER(aDietas[i])))
						Replace DI->DiRecetas with DI->DiRecetas + 1
					else
						DI->(DbAppend())
						Replace DI->DiDieta	 with aDietas[i]
						Replace DI->DiRecetas with 1
						DI->(DbCommit())
					endif
				next
			endif
		endif
      RE->(DbSkip())
      oProgress:SetPos(nProgress++)
      sysrefresh()
   ENDDO
   RE->(DbPack())
   // __ comprobación de integridad de escandallos ____________________________
   RE->(DbSetOrder(2))  // código
   RE->(DbGoTop())
   if ! Db_Open('ESCANDA','ES')
		MsgAlert("Error al comprobar la integridad de los escandallos.")
      return nil
   endif
   ES->(DbSetOrder(3))
   ES->(DbGoTop())
	if ! Db_Open('ALIMENTO','AL')
		MsgAlert("Error al comprobar la integridad de los escandallos.")
      return nil
   endif
   AL->(DbSetOrder(3))
   AL->(DbGoTop())
   cEsUnico := ES->EsReceta+ES->EsIngred
   ES->(DbSkip())
   DO WHILE ! ES->(EOF())
      if cEsUnico == ES->EsReceta+ES->EsIngred
         RE->(DbSeek(ES->EsReceta))
         if MsgYesNo('La receta '+Rtrim(Re->ReTitulo)+' tiene duplicado en el escandallo el ingrediente '+Rtrim(ES->EsInDenomi)+'.';
                    +CRLF+'¿Desea eliminar el ingrediente duplicado del escandallo?','Seleccione una opción')
            ES->(DbDelete())
         endif
      else
         if ! RE->(DbSeek(ES->EsReceta))
            // si la receta ha sido borrada borro sus ingredientes
            ES->(DbDelete())
         else
            cEsUnico := ES->EsReceta+ES->EsIngred
         endif
      endif
      ES->(DbSkip())
		if empty(rtrim(ES->EsProveed))
  			AL->(DbSeek(ES->EsIngred))
			replace ES->EsProveed with AL->AlProveed
			// ? ES->EsIngred+' '+AL->AlProveed
		endif
   ENDDO
   ES->(DbPack())
	DbCloseAll()
   SysRefresh()

	// reviso los ingredientes de los escandallos y los que no estén los meto en ingredientes
	if ! Db_Open('ESCANDA','ES')
		MsgAlert("Error al comprobar la integridad de los escandallos.")
		return nil
	endif
	ES->(DbSetOrder(1))
	ES->(DbGoTop())
	if ! Db_Open('ALIMENTO','AL')
		MsgAlert("Error al comprobar la integridad de los escandallos.")
		return nil
	endif
	AL->(DbSetOrder(3))
	While ! ES->(EoF())
		AL->(DbGoTop())
		If ! AL->(DbSeek(Upper(ES->EsIngred)))
			AL->(DbAppend())
			replace AL->AlCodigo   with ES->EsIngred
			replace AL->AlAlimento with ES->EsIndenomi
			replace AL->AlUnidad	  with ES->EsUnidad
			replace AL->AlPrecio   with (1/ES->EsCantidad)*ES->EsPrecio
			replace AL->AlKCal     with (1/ES->EsCantidad)*ES->EsKCal
			AL->(DbCommit())
		endif
		ES->(DbSkip())
	enddo
	DbCloseAll()
	// reviso los ingredientes de los escandallos y los ejemplares en grupos, proveedores y ubicaciones
	if ! Db_Open("ALIMENTO","AL")
		MsgAlert("Error al comprobar la integridad de los ingredientes de escandallos.")
		retu nil
	endif
	if ! Db_Open("PROVEED","PR")
		MsgAlert("Error al comprobar la integridad de los ingredientes de escandallos.")
		Dbcloseall()
		retu nil
	endif
	if ! Db_Open("UBICACI","UB")
		MsgAlert("Error al comprobar la integridad de los ingredientes de escandallos.")
		Dbcloseall()
		retu nil
	endif
	if ! Db_Open("GRUPOS","GR")
		MsgAlert("Error al comprobar la integridad de los ingredientes de escandallos.")
		Dbcloseall()
		retu nil
	endif
	if ! Db_Open("ACCION","AC")
		MsgAlert("Error al comprobar la integridad de los ingredientes de escandallos.")
		Dbcloseall()
		retu nil
	endif
	Select PR
	replace all PR->PrAliment with 0
	Select UB
	replace all UB->UbAliment with 0
	Select GR
	replace all GR->GrAliment with 0
	Select AC
	replace all AC->AcAliment with 0

	AL->(DbSetOrder(1))
	While ! AL->(EoF())
		PR->(DbGoTop())
		if PR->(DbSeek(Upper(AL->AlProveed)))
			replace PR->PrAliment with PR->PrAliment + 1
		else
			PR->(DbAppend())
			replace PR->PrNombre with AL->AlProveed
			replace PR->PrAliment with 1
		endif
		UB->(DbGoTop())
		if UB->(DbSeek(Upper(AL->AlUbicaci)))
			replace UB->UbAliment with UB->UbAliment + 1
		else
			UB->(DbAppend())
			replace UB->UbUbicaci with AL->AlUbicaci
			replace UB->UbAliment with 1
		endif
		GR->(DbGoTop())
		if GR->(DbSeek(Upper(AL->AlTipo)))
			replace GR->GrAliment with GR->GrAliment + 1
		else	
			GR->(DbAppend())
			replace GR->GrTipo with AL->AlTipo
			replace GR->GrAliment with 1
		endif	
		AC->(DbGoTop())
		AC->(DbSeek(Upper(AL->AlAccion)))
		replace AC->AcAliment with AC->AcAliment + 1
		AL->(DbSkip())
	enddo
   DbCloseAll()
   // oDlgProgress:End()
   CursorArrow()
return nil
/*_____________________________________________________________________________*/

function Ut_ActAnterior1()
   local oDlg, oText, oSay, oGet, oBtn
   local oDlgProgress, oSay01, oSay02, oBmp
   local cDir     := space(40)
   local cMessage := 'Para incorporar las recetas de versiones anteriores seleccione el directorio donde se encuentran dichas recetas.';
      +CRLF+'Estas recetas se incorporarán a la versión actual del programa sin borrar las que ya existen.'
   local oProgress
   if oApp():oDlg != nil
      if oApp():nEdit > 0
         //MsgStop('Por favor, finalice la edición del registro actual.')
         return nil
      else
         oApp():oDlg:End()
         SysRefresh()
      endif
   endif

   DEFINE DIALOG oDlg  NAME 'UT_UPDATEOLD' TITLE 'Incorporación de recetas'
	oDlg:SetFont(oApp():oFont)

   REDEFINE GET oText VAR cMessage  ;
      ID 102 OF oDlg                ;
      COLOR CLR_BLUE, CLR_WHITE MEMO READONLY

   REDEFINE SAY oSay ID 103 OF oDlg

   REDEFINE GET oGet VAR cDir       ;
      ID 104 OF oDlg UPDATE

   REDEFINE BUTTON oBtn             ;
      ID 105 OF oDlg                ;
      ACTION GetDir( oGet )
   oBtn:cTooltip := "seleccionar directorio"

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
      if Right(cDir,1) != '\'
         cDir := Rtrim(cDir)+'\'
      endif
      if ! File(cDir+'recetas.dbf')
         MsgStop('El directorio indicado no contiene datos de versiones anteriores de el Puchero.')
      else
         DEFINE DIALOG oDlgProgress RESOURCE 'UT_INDEXAR_'+oApp():cLanguage OF oApp():oWndMain
			oDlgProgress:SetFont(oApp():oFont)

         REDEFINE BITMAP oBmp ID 111 OF oDlgProgress RESOURCE 'BB_INDEX' TRANSPARENT
         REDEFINE SAY oSay01 PROMPT 'Incorporando datos ...' ID 99  OF oDlgProgress
         REDEFINE SAY oSay02 PROMPT space(30) ID 10  OF oDlgProgress
         oProgress := TProgress():Redefine( 101, oDlgProgress )

         oDlgProgress:bStart := { || SysRefresh(), Ut_ActAnterior2(oSay02, oProgress, cDir),;
                            oDlgProgress:End() }

         ACTIVATE DIALOG oDlgProgress ;
            ON INIT DlgCenter(oDlgProgress,oApp():oWndMain)

      endif
   endif
return nil

/*_____________________________________________________________________________*/

function Ut_ActAnterior2(oSay, oProgress, cDir)
   local nProgress   := 0
   local lZap        := .F.
   if msgYesNo('Al incorporar los datos de la versión anterior es posible que se produzcan duplicados de datos.';
         +CRLF+'¿ Desea borrar los datos existentes y dejar unicamente los incorporados ?','Seleccione una opción')
      lZap := .t.
   endif
   oProgress:SetRange(0,RecCount())
   oProgress:SetPos(nProgress)

   if ! Db_Open('ALIMENTO','AL')
      MsgAlert('Ha sucedido un error al incorporar los datos de la versión anterior.')
      return nil
   else
      if File(cDir+'alimento.dbf')
         if lZap
            DbZap()
         endif
         APPEND FROM &(cDir+'ALIMENTO')
      endif
      DbCloseAll()
      oProgress:SetPos(nProgress++)
      SysRefresh()
   endif

   if ! Db_Open('AUTORES','AU')
      MsgAlert('Ha sucedido un error al incorporar los datos de la versión anterior.')
      return nil
   else
      if File(cDir+'autores.dbf')
         if lZap
            DbZap()
         endif
         APPEND FROM &(cDir+'AUTORES')
      endif
      DbCloseAll()
      oProgress:SetPos(nProgress++)
      SysRefresh()
   endif

   if ! Db_Open('ESCANDA','ES')
      MsgAlert('Ha sucedido un error al incorporar los datos de la versión anterior.')
      return nil
   else
      if File(cDir+'escanda.dbf')
         if lZap
            DbZap()
         endif
         APPEND FROM &(cDir+'ESCANDA')
      endif
      DbCloseAll()
      oProgress:SetPos(nProgress++)
      SysRefresh()
   endif

   if ! Db_Open('FRANCESA','FR')
      MsgAlert('Ha sucedido un error al incorporar los datos de la versión anterior.')
      return nil
   else
      if File(cDir+'francesa.dbf')
         if lZap
            DbZap()
         endif
         APPEND FROM &(cDir+'FRANCESA')
      endif
      DbCloseAll()
      oProgress:SetPos(nProgress++)
      SysRefresh()
   endif

   if ! Db_Open('GRUPOS','GR')
      MsgAlert('Ha sucedido un error al incorporar los datos de la versión anterior.')
      return nil
   else
      if File(cDir+'grupos.dbf')
         if lZap
            DbZap()
         endif
         APPEND FROM &(cDir+'GRUPOS')
      endif
      DbCloseAll()
      oProgress:SetPos(nProgress++)
      SysRefresh()
   endif

   if ! Db_Open('PLATOS','PL')
      MsgAlert('Ha sucedido un error al incorporar los datos de la versión anterior.')
      return nil
   else
      if File(cDir+'platos.dbf')
         if lZap
            DbZap()
         endif
         APPEND FROM &(cDir+'PLATOS')
      endif
      DbCloseAll()
      oProgress:SetPos(nProgress++)
      SysRefresh()
   endif

   if ! Db_Open('PROVEED','PR')
      MsgAlert('Ha sucedido un error al incorporar los datos de la versión anterior.')
      return nil
   else
      if File(cDir+'proveed.dbf')
         if lZap
            DbZap()
         endif
         APPEND FROM &(cDir+'\PROVEED')
      endif
      DbCloseAll()
      oProgress:SetPos(nProgress++)
      SysRefresh()
   endif

   if ! Db_Open('PUBLICA','PU')
      MsgAlert('Ha sucedido un error al incorporar los datos de la versión anterior.')
      return nil
   else
      if File(cDir+'publica.dbf')
         if lZap
            DbZap()
         endif
         APPEND FROM &(cDir+'\PUBLICA')
      endif
      DbCloseAll()
      oProgress:SetPos(nProgress++)
      SysRefresh()
   endif

   if ! Db_Open('RECETAS','RE')
      MsgAlert('Ha sucedido un error al incorporar los datos de la versión anterior.')
      return nil
   else
      if File(cDir+'recetas.dbf')
         if lZap
            DbZap()
         endif
         APPEND FROM &(cDir+'\RECETAS')
      endif
      DbCloseAll()
      oProgress:SetPos(nProgress++)
      SysRefresh()
   endif

   if ! Db_Open('VALORAC','VA')
      MsgAlert('Ha sucedido un error al incorporar los datos de la versión anterior.')
      return nil
   else
      if File(cDir+'valorac.dbf')
         if lZap
            DbZap()
         endif
         APPEND FROM &(cDir+'\VALORAC')
      endif
      DbCloseAll()
      oProgress:SetPos(nProgress++)
      SysRefresh()
   endif

   MsgInfo('La incorporación de recetas se ha realizado con éxito. Una vez haya comprobado que las recetas se encuentran en la nueva versión es aconsejable que desinstale la versión antigua.')

   //if msgYesNo('Al incorporar los datos de la versión anterior es posible que se produzcan duplicados de datos.';
   //    +CRLF+'¿ Desea borrar los datos existentes y dejar unicamente los incorporados ?')
   // lZap := .t.
   //endif

return nil

/*_____________________________________________________________________________*/

function Ut_ResetMeter( oMeter, nMeter )

   nMeter := 0
   oMeter:setPos(nMeter)
   sysrefresh()

return nil

Function DbPack()
	Pack
return NIL

Function DbZap()
	Zap
return NIL

//_______________________________________________________________________________________//
Function AndesFood()
	local cFile, nHandle, nFLines, nProgress, Linea, nFHandle
	local aFields := {}
	local cMateria
	Db_OpenNoIndex("ALIMENTO", "AL")
	ZAP
	cFile := oApp():cDbfPath+"\ingredientes.csv"
   nFHandle := FOpen(cFile)
	nFLines  := FLineCount(cFile)
	nProgress := 0
	HB_FReadLine(nFHandle, @Linea)
	nProgress ++
	while nProgress < nFLines
		HB_FReadLine(nFHandle, @Linea)
		nProgress ++
		aFields := HB_ATokens(Linea,";",.f.,)
		if len(aFields[1]) == 3
			cMateria := aFields[2]
		else
			AL->(DbAppend())
			Fieldput(1, aFields[1])
			fieldput(2, cMateria)
			Fieldput(3, aFields[2]+' - '+aFields[3])
			Fieldput(4, aFields[5])
			Fieldput(5, val(aFields[6]))
		endif
		sysrefresh()
   enddo
   Dbcloseall()
return NIL