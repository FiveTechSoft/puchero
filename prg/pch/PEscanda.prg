#include "FiveWin.ch"
#include "Report.ch"
#include "Image.ch"
#include "xBrowse.ch"

STATIC oReport
/*_____________________________________________________________________________*/

FUNCTION TsEdita( oBrwEsc, lAppend, cReTitulo, cReCodigo, cReUsuario, ;
      aSayEsc, nReComEsc, nReEscan1, nReEscan2, nReKCal1, nReKCal2, ;
      nReMultip, nRePFinal, oGet25 )

   LOCAL oDlg
   LOCAL cEsReceta,;
      cEsIngred,;
      lEsCanFija,;
      nEsCantidad,;
      cEsUnidad,;
      nEsPrecio,;
      nEsKcal,;
      cEsDenomi,;
      cEsusuario,;
      cEsProveed
   LOCAL aGet[ 9 ]
   LOCAL aSay[ 8 ]

   // local nAntEscan := nReEscan

   LOCAL lSave := .F.
   LOCAL nRecPtr  := TS->( RecNo() )
   LOCAL nRecAdd
   LOCAL lDuplicado
   LOCAL nMode := iif( lAppend, 1, 2 )

   IF lAppend
      TS->( dbAppend() )
      REPLACE TS->EsReceta  WITH cReCodigo
      REPLACE TS->EsUsuario WITH cReUsuario
      TS->( dbCommit() )
      nRecAdd  := TS->( RecNo() )
   ELSE
      AL->( dbSetOrder( 3 ) )
      AL->( dbSeek( TS->EsIngred ) )
   ENDIF

   cEsReceta   := TS->EsReceta
   cEsIngred   := TS->EsIngred
   nEsCantidad := TS->EsCantidad
   lEsCanFija  := TS->EsCanFija
   cEsUnidad   := TS->EsUnidad
   nEsPrecio   := TS->EsPrecio
   nEsKcal     := TS->EsKcal
   cEsDenomi   := TS->EsInDenomi
   cEsUsuario  := TS->EsUsuario
   cEsProveed  := TS->EsProveed

   DEFINE DIALOG oDlg RESOURCE 'RE_ESCAN1_' + oApp():cLanguage ;
      TITLE iif( lAppend, i18n( "Nuevo ingrediente para escandallo" ), i18n( "Modificar ingrediente de escandallo" ) )
   oDlg:SetFont( oApp():oFont )

   // dialogo 1
   REDEFINE SAY aSay[ 1 ] PROMPT cReTitulo ID 200 OF oDlg COLOR CLR_HBLUE
   REDEFINE SAY aSay[ 2 ] ID 201 OF oDlg
   REDEFINE SAY aSay[ 3 ] ID 202 OF oDlg
   REDEFINE SAY aSay[ 4 ] ID 203 OF oDlg
   REDEFINE SAY aSay[ 5 ] ID 204 OF oDlg
   REDEFINE SAY aSay[ 6 ] ID 205 OF oDlg
   REDEFINE SAY aSay[ 7 ] ID 206 OF oDlg
   REDEFINE SAY aSay[ 8 ] ID 207 OF oDlg

   REDEFINE GET aGet[ 1 ] VAR cEsIngred ;
      ID 101 OF oDlg UPDATE               ;
      PICTURE '@!'                        ;
      VALID AlClave( cEsIngred, aGet, 4, 2, lAppend )    ;
      .AND. TsClave( @cEsIngred, aGet, nMode, oDlg )

   REDEFINE BUTTON aGet[ 7 ] ;
      ID 111 OF oDlg       ;
      ACTION AlSeleccion( cEsIngred, aGet, oDlg )
   aGet[ 7 ]:cTooltip := i18n( "seleccionar ingrediente" )

   REDEFINE GET aGet[ 2 ] VAR cEsDenomi     ;
      ID 103 OF oDlg PICTURE '@!'
   REDEFINE GET aGet[ 3 ] VAR cEsUnidad     ;
      ID 104 OF oDlg PICTURE '@!'
   REDEFINE GET aGet[ 4 ] VAR nEsCantidad   ;
      ID 102 OF oDlg PICTURE '@E 99.999'  ;
      VALID ( aGet[ 5 ]:cText := nEsCantidad * AL->AlPrecio,;
      aGet[ 6 ]:cText := nEsCantidad * AL->AlKCal,;
      .T. )

   REDEFINE CHECKBOX aGet[ 9 ] VAR lEsCanFija ID 108 OF oDlg

   REDEFINE GET aGet[ 5 ] VAR nEsPrecio     ;
      ID 105 OF oDlg PICTURE '@E 99,999.99'
   REDEFINE GET aGet[ 6 ] VAR nEsKcal       ;
      ID 106 OF oDlg PICTURE '@E 99,999.99'
   REDEFINE GET aGet[ 8 ] VAR cEsProveed    ;
      ID 107 OF oDlg PICTURE '@!'

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
      ON INIT ( DlgCenter( oDlg, oApp():oWndMain ) )

   IF oDlg:nresult == IDOK
      nReEscan1 := nReEscan1 - TS->EsPrecio + nEsPrecio
      nReEscan2 := nReEscan1 / nReComEsc
      nReKCal1  := nReKCal1  - TS->EsKCal   + nEsKCal
      nReKCal2  := nReKCal1 / nReComEsc
      nRePFinal := nReEscan1 * nReMultip
      REPLACE TS->EsReceta    WITH  cEsReceta
      REPLACE TS->EsUsuario   WITH  cEsUsuario
      REPLACE TS->EsIngred    WITH  cEsIngred
      REPLACE TS->EsCantidad  WITH  nEsCantidad
      REPLACE TS->EsCanFija   WITH  lEsCanFija
      REPLACE TS->EsUnidad    WITH  cEsUnidad
      REPLACE TS->EsPrecio    WITH  nEsPrecio
      REPLACE TS->EsKCal      WITH  nEsKcal
      REPLACE TS->EsInDenomi  WITH  cEsDenomi
      REPLACE TS->EsProveed   WITH  cEsProveed
      TS->( dbCommit() )
      nRecPtr := TS->( RecNo() )
   ELSE
      IF lAppend
         TS->( dbGoto( nRecAdd ) )
         TS->( dbDelete() )
         TS->( DbPack() )
         TS->( dbGoto( nRecPtr ) )
      ENDIF
   ENDIF

   SELECT TS
   aSayEsc[ 2 ]:Refresh()
   aSayEsc[ 3 ]:Refresh()
   aSayEsc[ 4 ]:Refresh()
   aSayEsc[ 5 ]:Refresh()
   oGet25:Refresh()

   oBrwEsc:Refresh()
   oBrwEsc:SetFocus()

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION TsBorra( oBrwEsc, aSayEsc, nReComEsc, nReEscan1, nReEscan2, nReKCal1, nReKCal2, ;
      nReMultip, nRePFinal, oGet25 )

   LOCAL nRecord := TS->( RecNo() )
   LOCAL nNext

   IF msgYesNo( i18n( "¿ Está seguro de querer borrar este ingrediente del escandallo ?" ) + CRLF + ;
         ( Trim( TS->EsInDenomi ) ), 'Seleccione una opción' )

      SELECT TS
      TS->( dbSkip() )
      nNext := TS->( RecNo() )
      TS->( dbGoto( nRecord ) )

      nReEscan1 := nReEscan1 - TS->EsPrecio
      nReEscan2 := nReEscan1 / nReComEsc
      nReKCal1  := nReKCal1  - TS->EsKCal
      nReKCal2  := nReKCal1 / nReComEsc
      nRePFinal := nReEscan1 * nReMultip
      aSayEsc[ 2 ]:Refresh()
      aSayEsc[ 3 ]:Refresh()
      aSayEsc[ 4 ]:Refresh()
      aSayEsc[ 5 ]:Refresh()
      oGet25:Refresh()

      TS->( dbDelete() )
      TS->( DbPack() )
      TS->( dbGoto( nNext ) )
      IF TS->( Eof() ) .OR. nNext == nRecord
         TS->( dbGoBottom() )
      ENDIF
   ENDIF

   oBrwEsc:Refresh( .T. )
   oBrwEsc:SetFocus( .T. )

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION TsRecalc( oBrwEsc, aSayEsc, nReComEsc, nReEscan1, nReEscan2, ;
      nReKCal1, nReKCal2, nMode, nReMultip, nRePFinal, oGet25 )

   LOCAL nOldCom     := nReComEsc
   LOCAL nRadio      := iif( nReComEsc == 0, 2, 1 )
   LOCAL nRecno      := TS->( RecNo() )
   LOCAL oDlg, oGet1, oGet2, oRadio

   DEFINE DIALOG oDlg RESOURCE 'RE_ESCAN2_ES';
      TITLE "Cambio de nº de comensales del escandallo"
   oDlg:SetFont( oApp():oFont )

   REDEFINE SAY ID 10 OF oDlg COLOR CLR_BLACK, CLR_WHITE

   REDEFINE GET oGet1 VAR nOldCom  ;
      ID 12 OF oDlg PICTURE " 999 " WHEN .F.
   oGet1:lDisColors  := .F.
   oGet1:nClrTextDis := GetSysColor( 13 )

   REDEFINE GET oGet2 VAR nReComEsc ;
      ID 14 OF oDlg PICTURE " 999 "
   REDEFINE RADIO oRadio VAR nRadio ID 16, 17 OF oDlg

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
      ON INIT ( DlgCenter( oDlg, oApp():oWndMain ) )

   IF oDlg:nresult == IDOK
      IF nRadio == 1
         SELECT TS
         TS->( dbGoTop() )
         DO WHILE ! Eof()
            IF TS->EsCanFija == .F.
               REPLACE TS->EsCantidad  WITH TS->EsCantidad * nReComEsc / nOldCom
               REPLACE TS->EsKCal      WITH TS->EsKCal     * nReComEsc / nOldCom
               REPLACE TS->EsPrecio    WITH TS->EsPrecio   * nReComEsc / nOldCom
               TS->( dbCommit() )
            ENDIF
            TS->( dbSkip() )
         ENDDO
         TS->( dbGoTop() )
         nReEscan1 := 0
         dbEval( {|| nReEscan1 += TS->EsPrecio },,,,, .F. )
         nReEscan2 := nReEscan1 / nReComEsc
         nReKCal1 := 0
         dbEval( {|| nReKCal1 += TS->EsKCal },,,,, .F. )
         nReKCal2  := nReKCal1 / nReComEsc
         nRePFinal := nReEscan1 * nReMultip
         aSayEsc[ 2 ]:Refresh()
         aSayEsc[ 3 ]:Refresh()
         aSayEsc[ 4 ]:Refresh()
         aSayEsc[ 5 ]:Refresh()
         oGet25:Refresh()
      ENDIF
   ENDIF
   aSayEsc[ 1 ]:Refresh()
   TS->( dbGoTop() )
   oBrwEsc:Refresh()
   oBrwEsc:SetFocus( .T. )

   RETURN NIL
/*_____________________________________________________________________________*/

FUNCTION TsClave( cIngred, aGet, nMode, nField, oDlg )

   // nMode    1 nuevo registro
   // 2 modificación de registro
   // 3 duplicación de registro
   // 4 clave ajena
   // nField   1 AlAlimento
   // 2 AlCodigo
   LOCAL lreturn  := .F.
   LOCAL nRecno   := TS->( RecNo() )
   LOCAL nOrder   := TS->( ordNumber() )
   LOCAL nArea    := Select()

   IF Empty( cIngred )
      IF nMode == 4
         RETURN .T.
      ELSE
         IF AlSeleccion( @cIngred, aGet, oDlg )
            cIngred := aGet[ 1 ]:cText
         ELSE
            MsgStop( "Es obligatorio rellenar este campo." )
            RETURN .F.
         ENDIF
      ENDIF
   ENDIF

   SELECT TS
   TS->( dbSetOrder( 2 ) )
   TS->( dbGoTop() )

   IF TS->( dbSeek( Upper( cIngred ) ) )
      DO CASE
      CASE nMode == 1 .OR. nMode == 3
         lreturn := .F.
         IF ! Empty( cIngred )
            MsgStop( "Ingrediente duplicado en el escandallo." )
         ENDIF
      CASE nMode == 2
         IF TS->( RecNo() ) == nRecno
            lreturn := .T.
         ELSE
            lreturn := .F.
            MsgStop( "Ingrediente duplicado en el escandallo." )
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
         lreturn := .F.
         MsgStop( "Ingrediente duplicado en el escandallo." )
      ENDIF
   ENDIF

   IF lreturn == .F.
      aGet[ 1 ]:cText( Space( 6 ) )
   ENDIF

   TS->( dbSetOrder( nOrder ) )
   TS->( dbGoto( nRecno ) )

   SELECT ( nArea )

   RETURN lreturn
/*_____________________________________________________________________________*/

FUNCTION TsIngredientes( mIngred, oGet )

   LOCAL nRecno   := TS->( RecNo() )
   LOCAL nOrder   := TS->( ordNumber() )

   TS->( dbGoTop() )
   WHILE ! TS->( Eof() )
      mIngred := mIngred + CRLF + TS->EsIngred + ' ' + TS->EsInDenomi + ' ' + Str( TS->EsCantidad ) + ' ' + TS->EsUnidad
      TS->( dbSkip() )
   ENDDO
   oGet:Refresh()
   MsgInfo( 'El escandallo se ha copiado al campo ingredientes.', 'Información' )
   TS->( dbSetOrder( nOrder ) )
   TS->( dbGoto( nRecno ) )

   RETURN NIL
