#include "FiveWin.ch"
#include "xBrowse.ch"

FUNCTION ZipBackup()

   LOCAL cPath    := oApp():cDbfPath
   LOCAL aDir     := Directory( cPath + "*.*" )
   LOCAL aFiles   := {}
   LOCAL aToZip   := {}
   LOCAL aFooter  := { 0, 0, "" }
   LOCAL cZipFile := oApp():cZipPath + DToS( Date() ) + ".ZIP" + Space( 20 )
   LOCAL aGet[ 3 ]
   LOCAL i
   LOCAL oDlg, oLbx, oCol
   LOCAL oDlgPro, oSay01, oSay02, oProgress, oBmp

   IF oApp():oDlg != nil
      IF oApp():nEdit > 0
         msgStop( i18n( "No puede hacer copias de seguridad hasta que no cierre las ventanas abiertas sobre el mantenimiento que está manejando." ) )
         RETURN NIL
      ELSE
         oApp():oDlg:End()
         SysRefresh()
      ENDIF
   ENDIF

   FOR i := 1 TO Len( aDir )
      AAdd( aFiles, { aDir[ i, 1 ], aDir[ i, 2 ], aDir[ i, 3 ] } )
      AAdd( aToZip, cPath + aDir[ i, 1 ] )
      aFooter[ 1 ] := aFooter[ 1 ] + 1
      aFooter[ 2 ] := aFooter[ 2 ] + aDir[ i, 2 ]
   NEXT
   aFiles   := ASort( aFiles,,, {| x, y| Upper( x[ 1 ] ) < Upper( y[ 1 ] ) } )

   DEFINE DIALOG oDlg OF oApp():oWndMain RESOURCE "ZipBackup_" + oApp():cLanguage  ;
      TITLE oApp():cAppName + oApp():cVersion + " - hacer copia de seguridad"
   oDlg:SetFont( oApp():oFont )

   REDEFINE SAY ID 100 OF oDlg

   REDEFINE GET aGet[ 1 ] VAR cPath   ;
      ID 101 OF oDlg                ;
      COLOR CLR_BLACK, CLR_WHITE    ;
      WHEN .F.

   oLbx := TXBrowse():New( oDlg )
   oLbx:SetArray( aFiles )
   Ut_BrwRowConfig( oLbx )
   //oLbx:nMarqueeStyle       := MARQSTYLE_HIGHLROW
   //oLbx:nColDividerStyle    := LINESTYLE_LIGHTGRAY
   //oLbx:lColDividerComplete := .t.
   //oLbx:lRecordSelector     := .f.
   //oLbx:lHScroll     := .f.
   //oLbx:nHeaderHeight       := 20
   //oLbx:nRowHeight          := 20
   //oLbx:lTransparent      := .T.
   //oLbx:l2007       := .f.
   oLbx:nDataType     := 1 // array
   //oLbx:nStretchCol     := -1

   oLbx:aCols[ 1 ]:cHeader  := i18n( "Fichero" )
   oLbx:aCols[ 1 ]:nWidth   := 100

   oLbx:aCols[ 2 ]:cHeader  := i18n( "Tamaño" )
   oLbx:aCols[ 2 ]:nWidth   := 100
   oLbx:aCols[ 2 ]:nDataStrAlign := 1
   oLbx:aCols[ 2 ]:nHeadStrAlign := 1
   //oLbx:aCols[2]:bStrData := {|| TRAN(aFiles[ oLbx:nAt,2 ]/1000,"@E 999,999,999 ")+" KB" }

   oLbx:aCols[ 3 ]:cHeader  := i18n( "Fecha modificación" )
   oLbx:aCols[ 3 ]:nWidth   := 100
   oLbx:aCols[ 3 ]:nDataStrAlign := 1
   oLbx:aCols[ 3 ]:nHeadStrAlign := 1
   //oLbx:aCols[3]:bStrData := {|| DtoC(aFiles[ oLbx:nAt,3 ]) }

   oLbx:CreateFromResource( 102 )

   REDEFINE SAY ID 103 OF oDlg

   REDEFINE GET aGet[ 2 ] VAR cZipFile   ;
      ID 104 OF oDlg UPDATE            ;
      PICTURE '@!'

   REDEFINE BUTTON aGet[ 3 ]             ;
      ID 105 OF oDlg UPDATE            ;
      ACTION SetFileZip( aGet[ 2 ] )
   aGet[ 3 ]:cTOOLTIP  := "seleccionar fichero de destino"

   REDEFINE BUTTON   ;
      ID    IDOK     ;
      OF    oDlg     ;
      ACTION   ( if( File( cZipFile ),;
      if( msgYesNo( i18n( "El fichero de destino especificado ya exite." ) + CRLF + CRLF + ;
      i18n( "¿Desea reemplazarlo?" ), 'Seleccione una opción' ), oDlg:end( IDOK ), aGet[ 2 ]:setFocus() ), ;
      oDlg:end( IDOK ) ) )

   REDEFINE BUTTON   ;
      ID    IDCANCEL ;
      OF    oDlg     ;
      CANCEL         ;
      ACTION   ( oDlg:end( IDCANCEL ) )

   ACTIVATE DIALOG oDlg ;
      ON INIT oDlg:Center( oApp():oWndMain )

   IF oDlg:nresult == IDOK

      DEFINE DIALOG oDlgPro RESOURCE 'UT_PROGRESS'
      oDlgPro:SetFont( oApp():oFont )
      REDEFINE BITMAP oBmp ID 111 OF oDlgPro RESOURCE "APP" TRANSPARENT
      REDEFINE SAY oSay01 PROMPT "Realizando copia de seguridad..." ID 99  OF oDlgPro
      REDEFINE SAY oSay02 PROMPT Space( 30 ) ID 100  OF oDlgPro
      oProgress := TProgress():Redefine( 101, oDlgPro )
      oDlgPro:bStart := {|| SysRefresh(), DoMakeZip( oProgress, cZipFile, aToZip, aFooter, oSay02 ), oDlgPro:End() }
      ACTIVATE DIALOG oDlgPro ;
         ON INIT oDlgPro:Center( oApp():oWndMain )

   ENDIF

RETURN NIL

FUNCTION SetFileZip( oGet )

   LOCAL cFile

   /*solicita el nombre con la unidad destino incluido*/
   cFile := cGetFile( "ZipFile | *.zip", "Nombre de archivo de copia de seguridad en Disco Duro", 1, oApp():cZipPath, .T., .T. )
   cFile := RTrim( cFile )

   /*agrega la extencion ZIP de ser necesario*/
   IF Empty( cFileExt( cFile ) )
      cFile += ".zip"
   ENDIF
   oGet:cText := cFile

RETURN NIL

PROCEDURE DoMakeZip( oProgress, cZipFile, aToZip, aFooter, oSay )

   LOCAL lOkZip      := .F.
   LOCAL bOnZipFile  := {|cFile, nFile| ( oProgress:SetPos( nFile ), ;
      oSay:SetText( SubStr( cFile,RAt("\",cFile ) + 1 ) ), ;
      SysRefresh() ) }
   LOCAL nPos     := 0

   /*establece limites de valores de control meter*/
   oProgress:SetRange( 0, aFooter[ 1 ] )
   oProgress:SetPos( 0 )
   /*realiza la compresion de los ficheros*/
   hb_SetDiskZip( {|| NIL } )
   lOkZip := hb_ZipFile( cZipFile,;
      aToZip,;
      9,;
      bOnZipFile,;
      NIL,;
      NIL,;
      NIL        )

   /*verifica proceso e informa al usuario*/
   IF lOkZip
      MsgInfo( "La creación del fichero de copia de seguridad se realizó correctamente." )
   ELSE
      MsgStop( "La creación del fichero de copia de seguridad falló." )
   ENDIF

   hb_gcAll()

RETURN

/*_____________________________________________________________________________*/

FUNCTION ZipRestore()

   LOCAL cPath    := Upper( oApp():cDbfPath )
   LOCAL aDir     := {}
   LOCAL aFiles   := Array( 1, 3 )
   LOCAL aToUnZip := {}
   LOCAL aFooter  := { 0, 0, "" }
   LOCAL cZipFile := ""
   LOCAL aGet[ 4 ]
   LOCAL i
   LOCAL oDlg, oLbx, oCol
   LOCAL oDlgPro, oSay01, oSay02, oProgress, oBmp

   IF oApp():oDlg != nil
      IF oApp():nEdit > 0
         msgStop( i18n( "No puede restaurar copias de seguridad hasta que no cierre las ventanas abiertas sobre el mantenimiento que está manejando." ) )
         RETURN NIL
      ELSE
         oApp():oDlg:End()
         SysRefresh()
      ENDIF
   ENDIF

   IF Left( cPath, 1 ) == '.'
      cPath := cFilePath( GetModuleFileName( GetInstance() ) ) + SubStr( cPath, 2 )
   ENDIF
   FOR i := 1 TO Len( aDir )
      AAdd( aFiles, { aDir[ i, 1 ], aDir[ i, 2 ], aDir[ i, 3 ] } )
      AAdd( aToUnZip, cPath + aDir[ i, 1 ] )
      aFooter[ 1 ] := aFooter[ 1 ] + 1
      aFooter[ 2 ] := aFooter[ 2 ] + aDir[ i, 2 ]
   NEXT
   aFiles   := ASort( aFiles,,, {| x, y| Upper( x[ 1 ] ) < Upper( y[ 1 ] ) } )

   DEFINE DIALOG oDlg OF oApp():oWndMain RESOURCE "ZipRestore_" + oApp():cLanguage;
      TITLE oApp():cAppName + oApp():cVersion + " - restaurar copia de seguridad"
   oDlg:SetFont( oApp():oFont )

   REDEFINE SAY ID 100 OF oDlg

   REDEFINE GET aGet[ 1 ] VAR cZipFile;
      ID 101 OF oDlg UPDATE         ;
      PICTURE '@!'
   REDEFINE BUTTON aGet[ 4 ]             ;
      ID 105 OF oDlg UPDATE            ;
      ACTION GetFileToUnzip( aGet[ 1 ], aFiles, aToUnZip, aFooter, oLbx )
   aGet[ 4 ]:cTOOLTIP  := "seleccionar fichero con la copia de seguridad"

   oLbx := TXBrowse():New( oDlg )
   oLbx:SetArray( aFiles )
   Ut_BrwRowConfig( oLbx )

   //oLbx:nMarqueeStyle       := MARQSTYLE_HIGHLROW
   //oLbx:nColDividerStyle    := LINESTYLE_LIGHTGRAY
   //oLbx:lColDividerComplete := .t.
   //oLbx:lRecordSelector     := .f.
   //oLbx:lHScroll     := .f.
   //oLbx:nHeaderHeight       := 20
   //oLbx:nRowHeight          := 20
   //oLbx:lTransparent      := .T.
   //oLbx:l2007       := .f.
   oLbx:nDataType     := 1 // array
   //oLbx:nStretchCol     := -1

   oLbx:aCols[ 1 ]:cHeader  := i18n( "Fichero" )
   oLbx:aCols[ 1 ]:nWidth   := 100

   oLbx:aCols[ 2 ]:cHeader  := i18n( "Tamaño" )
   oLbx:aCols[ 2 ]:nWidth   := 100
   oLbx:aCols[ 2 ]:nDataStrAlign := 1
   oLbx:aCols[ 2 ]:nHeadStrAlign := 1
   //oLbx:aCols[2]:bStrData := {|| TRAN(aFiles[ oLbx:nAt,2 ]/1000,"@E 999,999,999 ")+" KB" }

   oLbx:aCols[ 3 ]:cHeader  := i18n( "Fecha modificación" )
   oLbx:aCols[ 3 ]:nWidth   := 100
   oLbx:aCols[ 3 ]:nDataStrAlign := 1
   oLbx:aCols[ 3 ]:nHeadStrAlign := 1
   //oLbx:aCols[3]:bStrData := {|| DtoC(aFiles[ oLbx:nAt,3 ]) }


   FOR i := 1 TO Len( oLbx:aCols )
      oCol := oLbx:aCols[ i ]
      // oCol:bLDClickData  :=  { || IIF(aShow[ oLbx:nArrayAt ],oBtnHide:Click(),oBtnShow:Click()) }
      // oCol:bClrSelFocus  := { || { CLR_BLACK, oApp():nClrHL } }
      // oCol:bPaintText := { |oCol, hDC, cData, aRect | Ut_PaintColArray( oCol, hDC, cData, aRect ) }
   NEXT
   oLbx:CreateFromResource( 102 )

   REDEFINE SAY ID 103 OF oDlg

   REDEFINE GET aGet[ 2 ] VAR cPath   ;
      ID 104 OF oDlg                ;
      COLOR CLR_BLACK, CLR_WHITE    ;
      WHEN .F.

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
      ON INIT oDlg:Center( oApp():oWndMain )

   IF oDlg:nresult == IDOK

      DEFINE DIALOG oDlgPro RESOURCE 'UT_PROGRESS'
      oDlgPro:SetFont( oApp():oFont )
      REDEFINE BITMAP oBmp ID 111 OF oDlgPro RESOURCE "APP" TRANSPARENT
      REDEFINE SAY oSay01 PROMPT "Restaurando copia de seguridad..." ID 99  OF oDlgPro
      REDEFINE SAY oSay02 PROMPT Space( 30 ) ID 100  OF oDlgPro
      oProgress := TProgress():Redefine( 101, oDlgPro )
      oDlgPro:bStart := {|| SysRefresh(), DoMakeUnZip( oProgress, cZipFile, cPath, aFooter, oSay02 ), oDlgPro:End() }
      ACTIVATE DIALOG oDlgPro ;
         ON INIT oDlgPro:Center( oApp():oWndMain )

   ENDIF

RETURN NIL

PROCEDURE GetFileToUnZip( oGet, aFiles, aToUnZip, aFooter, oLbx )

   LOCAL cFile
   LOCAL aDir
   LOCAL i

   /*pide al usuario que seleccione el fichero de respaldo*/
   cFile := cGetFile( "ZipFile   | *.zip", "Nombre de archivo de copia de seguridad a restaurar", 1, oApp():cZipPath, .F., .T. )

   /*verifica si realmente se paso el fichero*/
   IF ! Empty( cFile )

      /*muestra el nombre del fichero en el dialogo*/
      oGet:cText := cFile

      aDir := hb_GetFilesInZip( cFile, .T. )

      /*vereficia el valor retornado por la funcion, si es arreglo y si tiene elementos*/
      IF ValType( aDir ) = "A" .AND. Len( aDir ) > 0
         aFiles   := {}
         aToUnZip := {}
         aFooter  := { 0, 0, "" }
         FOR i := 1 TO Len( aDir )
            AAdd( aFiles, { aDir[ i, 1 ], aDir[ i, 2 ], aDir[ i, 6 ] } )
            AAdd( aToUnZip, cFilePath( cFile ) + aDir[ i, 1 ] )
            aFooter[ 1 ] := aFooter[ 1 ] + 1
            aFooter[ 2 ] := aFooter[ 2 ] + aDir[ i, 2 ]
         NEXT

         aFiles   := ASort( aFiles,,, {| x, y| Upper( x[ 1 ] ) < Upper( y[ 1 ] ) } )

         /*pasa el arreglo al browse*/

         oLbx:bLine  := {|| { " " + cFileName( aFiles[ oLbx:nAt,1 ] ),;
            TRAN( aFiles[ oLbx:nAt, 2 ] / 1000, "@E 999,999,999 " ) + " KB", ;
            " " + DToC( aFiles[ oLbx:nAt, 3 ] ) } }
         //oLbx:aFooters  := { TRAN(aFooter[1],"@E 999 ")+" ficheros",TRAN(aFooter[2]/1000,"@E 999,999,999 ")+" KB", }
         oLbx:SetArray( aFiles )
         oLbx:refresh( .T. )
         hb_gcAll()
      ELSE
         MsgStop( i18n( "El fichero no es un fichero ZIP válido o parece estar dañado." ) )
         RETURN
      ENDIF
   ENDIF

RETURN

PROCEDURE DoMakeUnZip( oProgress, cZipFile, cPath, aFooter, oSay )

   LOCAL lOkUnZip    := .F.
   LOCAL bOnZipFile  := {|cFile, nFile| ( oProgress:SetPos( nFile ), ;
      oSay:SetText( SubStr( cFile,RAt("\",cFile ) + 1 ) ), ;
      SysRefresh() ) }
   LOCAL nPos     := 0
   LOCAL aFiles   := hb_GetFilesInZip( cZipFile )

   /*establece limites de valores de control meter*/
   oProgress:SetRange( 0, aFooter[ 1 ] )
   oProgress:SetPos( 0 )
   /*realiza la compresion de los ficheros*/
   hb_SetDiskZip( {|| NIL } )

   lOkUnZip := hb_UnZipFile( cZipFile,;
      bOnZipFile,;
      .F.,;
      NIL,;
      cPath,;
      aFiles  )

   /*verifica proceso e informa al usuario*/
   IF lOkUnZip
      MsgInfo( "La restauración del fichero de copia de seguridad se realizó correctamente." )
      WritePProString( "Browse", "ReOrder", "1", oApp():cIniFile )
      WritePProString( "Browse", "ReRecno", "0", oApp():cIniFile )
      WritePProString( "Browse", "PlOrder", "1", oApp():cIniFile )
      WritePProString( "Browse", "PlRecno", "0", oApp():cIniFile )
      WritePProString( "Browse", "VaOrder", "1", oApp():cIniFile )
      WritePProString( "Browse", "VaRecno", "0", oApp():cIniFile )
      WritePProString( "Browse", "AlOrder", "1", oApp():cIniFile )
      WritePProString( "Browse", "AlRecno", "0", oApp():cIniFile )
      WritePProString( "Browse", "PrOrder", "1", oApp():cIniFile )
      WritePProString( "Browse", "PrRecno", "0", oApp():cIniFile )
      WritePProString( "Browse", "GrOrder", "1", oApp():cIniFile )
      WritePProString( "Browse", "GrRecno", "0", oApp():cIniFile )
      WritePProString( "Browse", "AuOrder", "1", oApp():cIniFile )
      WritePProString( "Browse", "AuRecno", "0", oApp():cIniFile )
      WritePProString( "Browse", "PuOrder", "1", oApp():cIniFile )
      WritePProString( "Browse", "PuRecno", "0", oApp():cIniFile )
      Ut_Actualizar()
      Ut_Indexar()
   ELSE
      MsgStop( "La restauración del fichero de copia de seguridad ha fallado." )
   ENDIF

   hb_gcAll()

RETURN

/*_____________________________________________________________________________*/
