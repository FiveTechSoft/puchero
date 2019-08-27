#include "FiveWin.ch"

/*_____________________________________________________________________________*/

function Db_Open(cDbf,cAlias)
   if ! File(oApp():cDbfPath+cDbf+'.CDX')
      Ut_Actualizar()
      Ut_Indexar()
   endif
   if file( oApp():cDbfPath + cDbf + ".dbf" ) .AND. file( oApp():cDbfPath + cDbf + ".cdx" )
      USE &(oApp():cDbfPath+cDbf+".dbf")      ;
         INDEX &(oApp():cDbfPath+cDbf+".cdx") ;
         ALIAS &(cAlias) NEW
   else
      MsgStop( i18n( "No se ha encontrado un archivo de datos." ) + CRLF + ;
               i18N( "Por favor revise la configuración y reindexe los ficheros del programa." ) )
      return .f.
   END if

   if NetErr()
      msgStop( i18n( "Ha sucedido un error al abrir un fichero." ) + CRLF + ;
              i18n( "Por favor reinicie el programa." ) )
      dbCloseAll()
      return .f.
   endif

return .t.

function Db_OpenNoIndex(cDbf,cAlias)
   if file( oApp():cDbfPath + cDbf + ".dbf" )
      USE &(oApp():cDbfPath+cDbf+".dbf")      ;
         ALIAS &(cAlias) NEW
   else
      MsgStop( i18n( "No se ha encontrado un archivo de datos." ) + CRLF + ;
               i18N( "Por favor revise la configuración y reindexe los ficheros del programa." ) )
      return .f.
   END if
   if NetErr()
      msgStop('Ha sucedido un error al abrir un fichero.'+;
              CRLF+'Por favor reinicie el programa.')
      DbCloseAll()
      return .f.
   endif
return .t.

function Db_Pack()
   Pack
return nil

function Db_Zap()
   Zap
return nil

function Db_AppendSDF(cFile,cAlias)
   Select &cAlias
   Append from &cFile SDF
return nil

function Db_OpenAll()
	
	DbCloseAll()

   if ! Db_Open("AUTORES","AU")
      return .F.
   endif
   if ! Db_Open("PUBLICA","PU")
      return .F.
   endif
   if ! Db_Open("PLATOS","PL")
      return .F.
   endif
   if ! Db_Open("RECETAS","RE")
      return .F.
   endif
   if ! Db_Open("ESCANDA","ES")
      return .F.
   endif
   if ! Db_Open("GRUPOS","GR")
      return .F.
   endif
   if ! Db_Open("ALIMENTO","AL")
      return .F.
   endif
   if ! Db_Open("PROVEED","PR")
      return .F.
   endif
   if ! Db_Open("TEMPESC","TS")
      return .F.
   endif
   if ! Db_Open("VALORAC","VA")
      return .F.
   endif
   if ! Db_Open("FRANCESA","FR")
      return .F.
   endif
   if ! Db_Open("MENUS","ME")
      return .F.
   endif
   if ! Db_Open("RECEMENU","RM")
      return .F.
   endif
	if ! Db_Open("MENUSEM","MS")
      return .F.
   endif
   if ! Db_Open("REMESEM","RS")
      return .F.
   endif
	if ! Db_Open("INGREDIP","IP")
      return .F.
   endif
	if ! Db_Open("DIETAS","DI")
      return .F.
   endif
	if ! Db_Open("UBICACI","UB")
		return .F.
	endif
	if ! Db_Open("ACCION","AC")
		return .F.
	endif
return .t.

/*_____________________________________________________________________________*/

FUNCTION Db_Gather( aField, cAlias, lAppend )
   local i
   DEFAULT lAppend := .f.
	if lAppend == .t.
 		(cAlias)->(DbAppend())
	endif
   for i = 1 to Len( aField )
      (cAlias)->( FieldPut( i, aField[ i ] ) )
	next

   (cAlias)->( dbCommit() )
RETURN NIL
