#include "FiveWin.ch"
#include "Report.ch"
#include "Image.ch"
#include "zoomimage.ch"
#include "xBrowse.ch"
#include "splitter.ch"
#include "vmenu.ch"

#DEFINE  SELECCIONADA   "X"
#DEFINE  NOSELECCIONADA " "

STATIC oReport

function Menus()
   local oBar, oBar1, oBar2
   local oCol
   local aBrowse
   local cState := GetPvProfString("Browse", "MeState","", oApp():cInifile)
   local nOrder := MAX(VAL(GetPvProfString("Browse", "MeOrder","1", oApp():cInifile)),1)
   local nRecno := VAL(GetPvProfString("Browse", "MeRecno","1", oApp():cInifile))
   local nSplit := VAL(GetPvProfString("Browse", "MeSplit","102", oApp():cInifile))
   local nRecTab
   local oCont
   local i
   local aClient

   if oApp():oDlg != nil
      if oApp():nEdit > 0
         //MsgStop('Por favor, finalice la edición del registro actual.')
         retu nil
      else
         oApp():oDlg:End()
         SysRefresh()
      endif
   endif

   if ! Db_OpenAll()
      return nil
   endif

   oApp():oDlg := TFsdi():New(oApp():oWndMain)
   oApp():oDlg:cTitle := i18n('Gestión de menús')
   oApp():oWndMain:oClient := oApp():oDlg
   oApp():oDlg:NewGrid( nSplit )

   Ut_BrwRowConfig( oApp():oGrid )

   SELECT ME
   oApp():oGrid:cAlias := "ME"

   oCol := oApp():oGrid:AddCol()
	oCol:Cargo    := 1
	oCol:bLClickHeader := {|| MeSort(1, oCont) }
	oCol:AddResource("16_SORT_A")
	oCol:AddResource("16_SORT_B")
	oCol:nHeadBmpNo    := IIF(nOrder==oCol:Cargo,1,2)
	oCol:nHeadBmpAlign := AL_RIGHT
   oCol:bStrData :=  { || ME->MeCodigo }
   oCol:cHeader  := i18n("Código")
   oCol:nWidth   := 50

   oCol := oApp():oGrid:AddCol()
	oCol:Cargo    := 2
	oCol:bLClickHeader := {|| MeSort(2, oCont) }
	oCol:AddResource("16_SORT_A")
	oCol:AddResource("16_SORT_B")
	oCol:nHeadBmpNo    := IIF(nOrder==oCol:Cargo,1,2)
	oCol:nHeadBmpAlign := AL_RIGHT
   oCol:bStrData :=  { || ME->MeDescrip }
   oCol:cHeader  := i18n("Descripción")
   oCol:nWidth   := 150

   oCol := oApp():oGrid:AddCol()
	oCol:Cargo    := 3
	oCol:bLClickHeader := {|| MeSort(3, oCont) }
	oCol:AddResource("16_SORT_A")
	oCol:AddResource("16_SORT_B")
	oCol:nHeadBmpNo    := IIF(nOrder==oCol:Cargo,1,2)
	oCol:nHeadBmpAlign := AL_RIGHT
   oCol:bStrData :=  { || DtoC(ME->MeFchPrep) }
   oCol:cHeader  := i18n("Fch. preparación")
   oCol:nWidth   := 120

	oCol := oApp():oGrid:AddCol()
	oCol:bStrData :=  { || MeGetRecetas(ME->MeCodigo) }
	oCol:cHeader  := i18n("Recetas")
	oCol:nWidth   := 120

   // añado columnas con bitmaps
   for i := 1 TO LEN(oApp():oGrid:aCols)
      oCol := oApp():oGrid:aCols[ i ]
      oCol:bLDClickData  := {|| MeEdita(oApp():oGrid,2,oCont,oApp():oDlg) }
   next

   oApp():oGrid:SetRDD()
   oApp():oGrid:CreateFromCode()
   oApp():oGrid:bChange     := {|| RefreshCont( oCont, "ME" ) }
   oApp():oGrid:bKeyDown    := {|nKey| MeTecla(nKey,oApp():oGrid,oCont,oApp():oDlg) }

	oApp():oGrid:RestoreState( cState )

   ME->(DbSetOrder(nOrder))

   if nRecNo < ME->(LastRec()) .AND. nRecno != 0
      ME->(DbGoTo(nRecno))
   else
      ME->(DbGoTop())
   endif

   @ 02, 05 VMENU oCont SIZE nSplit-10, 17.5 OF oApp():oDlg  ;
      COLOR CLR_BLACK, GetSysColor(15)       ;
      FILLED   ;
      COLORSELECT 0, CLR_WHITE ;
      HEIGHT ITEM 22

   DEFINE TITLE OF oCont ;
      CAPTION tran(ME->(OrdKeyNo()),'@E 999,999')+" / "+tran(ME->(OrdKeyCount()),'@E 999,999') ;
      HEIGHT 25         ;
		COLOR GetSysColor(9), oApp():nClrBar ;
      IMAGE "BB_MENU"   

   @ 24, 05 VMENU oBar SIZE nSplit-10, 146 OF oApp():oDlg  ;
		COLOR CLR_BLACK, GetSysColor(15) ;
		HEIGHT ITEM 22 XBOX
	oBar:nClrBox := MIN(GetSysColor(13), GetSysColor(14))

   DEFINE TITLE OF oBar ;
      CAPTION "Menús de eventos"   ;
      HEIGHT 25 ;
		COLOR GetSysColor(9), oApp():nClrBar ;
      OPENCLOSE

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Nuevo"              ;
      IMAGE "16_NUEVO"             ;
      ACTION MeEdita( oApp():oGrid, 1, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Modificar"          ;
      IMAGE "16_MODIF"             ;
      ACTION MeEdita( oApp():oGrid, 2, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Duplicar"           ;
      IMAGE "16_DUPLICA"           ;
      ACTION MeEdita( oApp():oGrid, 3, oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Borrar"             ;
      IMAGE "16_BORRAR"            ;
      ACTION MeBorra( oApp():oGrid, oCont );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Buscar"             ;
      IMAGE "16_BUSCA"             ;
      ACTION MeBusca(oApp():oGrid,,oCont, oApp():oDlg );
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Imprimir"           ;
      IMAGE "16_IMPRIMIR"          ;
      ACTION MeImprime( oApp():oGrid, oApp():oDlg )   ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Lista de la compra" ;
      IMAGE "16_COMPRA"            ;
      ACTION MeCompra( oApp():oGrid, oApp():oDlg, .f. ) ;
      LEFT 10

	DEFINE VMENUITEM OF oBar        ;
		CAPTION "Anotar preparación" ;
		IMAGE "16_FECHA_OK"          ;
		ACTION MePreparacion( oApp():oGrid, oApp():oDlg ) ;
		LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      INSET HEIGHT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Enviar a Excel"     ;
      IMAGE "16_EXCEL"             ;
      ACTION (CursorWait(), Ut_ExportXLS( oApp():oGrid, "Menús" ), CursorArrow());
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Configurar rejilla" ;
      IMAGE "16_GRID"              ;
      ACTION Ut_BrwColConfig( oApp():oGrid, "MeState" ) ;
      LEFT 10

   DEFINE VMENUITEM OF oBar        ;
      CAPTION "Salir"              ;
      IMAGE "16_SALIR"             ;
      ACTION oApp():oDlg:End()              ;
      LEFT 10

   @ oApp():oDlg:nGridBottom, nSplit+2 TABS oApp():oTab ;
     OPTION nOrder SIZE oApp():oWndMain:nWidth()-80, 12 PIXEL OF oApp():oDlg ;
     ITEMS ' Código ', ' Descripción ', ' Fch. Preparación ';
     COLOR CLR_BLACK, GetSysColor(15)-RGB(30,30,30) ;// 13362404
	  ACTION MeSort( oApp():otab:noption, oCont )

   oApp():oDlg:NewSplitter( nSplit, oCont, oBar )

	// ResizeWndMain()
   ACTIVATE DIALOG oApp():oDlg NOWAIT ;
      ON INIT ( ResizeWndMain(), oApp():oGrid:SetFocus() ) ;
      VALID ( oApp():oGrid:nLen := 0 ,;
              WritePProString("Browse","MeState",oApp():oGrid:SaveState(),oApp():cInifile) ,;
              WritePProString("Browse","MeOrder",Ltrim(Str(ME->(OrdNumber()))),oApp():cInifile) ,;
              WritePProString("Browse","MeRecno",Ltrim(Str(ME->(Recno()))),oApp():cInifile)  ,;
              WritePProString("Browse","MeSplit",Ltrim(Str(oApp():oSplit:nleft/2)),oApp():cInifile) ,;
              oBar:End(), DbCloseAll(), oApp():oDlg := NIL, oApp():oGrid := NIL, oApp():oTab := NIL, oApp():oSplit := NIL, .t. )
return nil
/*_____________________________________________________________________________*/

function MeEdita(oGrid,nMode,oCont,oParent)
   local oDlg, oFld, oLbx, oCol
	local cState := GetPvProfString("Browse", "ReMeState","", oApp():cInifile)
   local aTitle := { i18n( "Añadir menú de evento" )   ,;
                     i18n( "Modificar menú de evento") ,;
                     i18n( "Duplicar menú de evento") }
   local aGet[4], aSay[3], aBtn[5]
   local cMeCodigo   ,;
         cMeDescrip  ,;
         dMeFchPrep  ,;
			nMeComens
	local cReMeCodigo
	local aRe := {}
	local aTPlato   := { 'Entradas ', '1er Plato', '2o Plato ', 'Postre   ', 'Dulce    ', 'Otro     ' }
	local lBlank, i
   local nRecPtr := ME->(RecNo())
   local nOrden  := ME->(OrdNumber())
   local nRecAdd
   local lDuplicado

   if ME->(EOF()) .AND. nMode != 1
      return nil
   endif

   oApp():nEdit ++

   if nMode == 1
      ME->(DbAppend())
      nRecAdd := ME->(RecNo())
   endif
   cMeCodigo	:= ME->MeCodigo
	cMeDescrip  := ME->MeDescrip
	dMeFchPrep	:= ME->MeFchPrep
	nMeComens	:= ME->MeComens
	cReMeCodigo := cMeCodigo
	if nMode == 3
      ME->(DbAppend())
      nRecAdd := ME->(RecNo())
		cMeCodigo := space(10)
	endif

   DEFINE DIALOG oDlg RESOURCE "MS_EDIT" TITLE aTitle[ nMode ]
   oDlg:SetFont(oApp():oFont)

   REDEFINE GET aGet[1] VAR cMeCodigo  ;
      ID 101 OF oDlg UPDATE            ;
      VALID MeClave( cMeCodigo, aGet[1], nMode )

   REDEFINE GET aGet[2] VAR cMeDescrip  ;
      ID 102 OF oDlg UPDATE

   REDEFINE GET aGet[3] VAR dMeFchPrep  ;
      ID 103 OF oDlg UPDATE

   REDEFINE BUTTON ID 104 OF oDlg ;
      ACTION SelecFecha(@dMeFchPrep,aGet[3])

   REDEFINE GET aGet[4] VAR nMeComens  ;
      ID 105 OF oDlg UPDATE

   // recetas del menu
	Select RE
	RE->(OrdSetFocus(2))
	Select RM
	RM->(DbGoTop())
   do while ! RM->(EoF()) .and. ( nMode == 2 .or. nMode == 3)
      if Upper(RM->RmMeCodigo) == Upper(cReMeCodigo)
			RE->(DbGoTop())
			if RE->(DbSeek(RM->RmReCodigo))
	         AADD(aRe,{RE->ReCodigo ,;
	 						 RE->ReTitulo ,;
							 aTPlato[MAX(VAL(RE->RePlato),1)],;
							 RE->ReTipo   ,;
							 RM->RmComensal })
			//else
			//	if MsgYesNo('La receta '+RM->RmReCodigo+' ya no existe en la tabla de recetas.'+CRLF+'¿ Desea borrarla del menú ?','Seleccione una opción')
			//		RM->(DbDelete())
			//	endif
			endif
      endif
      RM->(DbSkip())
   enddo

   if len(aRe) == 0
      AADD(aRe,{ '','','','','' })
      lBlank := .t.
   else
      lBlank := .f.
   endif

   oLbx := TXBrowse():New( oDlg )
	Ut_BrwRowConfig( oLbx )
   oLbx:SetArray( aRe, .f. )
   oLbx:aCols[1]:cHeader := "Código"
   oLbx:aCols[1]:nWidth  := 50
	oLbx:aCols[1]:nHeadStrAlign := 0
	oLbx:aCols[2]:cHeader := "Receta"
   oLbx:aCols[2]:nWidth  := 150
	oLbx:aCols[2]:nHeadStrAlign := 0
   oLbx:aCols[3]:cHeader := "Cat."
   oLbx:aCols[3]:nWidth  := 50
	oLbx:aCols[3]:nHeadStrAlign := 0
   oLbx:aCols[4]:cHeader := "Plato"
   oLbx:aCols[4]:nWidth  := 80
	oLbx:aCols[4]:nHeadStrAlign := 0
   oLbx:aCols[5]:cHeader := "Comens."
   oLbx:aCols[5]:nWidth  := 80
	oLbx:aCols[5]:nHeadStrAlign := 0
	// oCol:nDataStrAlign := 1
	// oCol:nHeadStrAlign := 1

   oLbx:CreateFromResource( 110 )
	oLbx:RestoreState( cState )

   for i := 1 TO len(oLbx:aCols)
      oCol := oLbx:aCols[i]
      oCol:bLDClickData  := {|| RmEdita(oLbx,2,aRe,@lBlank) }
   next

   REDEFINE BUTTON aBtn[1] ;
      ID 111     ;
      OF oDlg    ;
      ACTION  RmEdita(oLbx,1,aRe,@lBlank,nMeComens)

   REDEFINE BUTTON aBtn[2] ;
      ID 112     ;
      OF oDlg    ;
      ACTION  RmEdita(oLbx,2,aRe,@lBlank,nMeComens)

   REDEFINE BUTTON aBtn[3] ;
      ID 113     ;
      OF oDlg    ;
      ACTION  RmBorra(oLbx,aRe,@lBlank)

	REDEFINE BUTTON aBtn[4] ;
      ID 114 OF oDlg       ;
      ACTION  MsgInfo( 'pendiente' );
		WHEN .f.

	REDEFINE BUTTON aBtn[5] ;
      ID 115 OF oDlg       ;
      ACTION ( RE->(OrdSetFocus(2)),;
					RE->(DbSeek(aRe[oLbx:nArrayAt,1])),;
					iif(RE->ReExpres==.t.,ReEditaExpres(,2,,oDlg),ReEdita(,2,,oDlg)))

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

   IF oDlg:nresult == IDOK
		// ___ guardo las recetas del menu ____
		Select RM
		if nMode == 2
			Delete for RM->RmMeCodigo == ME->MeCodigo
			RM->(DbCommit())
		endif
		if ! lBlank
			for i := 1 to Len(aRe)
				if ! empty(aRe[i,1])
					RM->(DbAppend())
					Replace RM->RmMeCodigo	 with cMeCodigo
					Replace RM->RmReCodigo	 with aRe[i,1]
					Replace RM->RmComensal   with aRe[i,5]
					RM->(DbCommit())
				endif
			next
		endif
      // ___ guardo el menu _______________________________________________
      Select ME
		if nMode == 2
         ME->(DbGoTo(nRecPtr))
      else
         ME->(DbGoTo(nRecAdd))
      endif
		Replace ME->MeCodigo		with cMeCodigo
		Replace ME->MeDescrip	with cMeDescrip
		Replace ME->MeFchPrep	with dMeFchPrep
		Replace ME->MeComens		with nMeComens
		ME->(DbCommit())
	else
		if nMode == 1 .OR. nMode == 3
			ME->(DbGoTo(nRecAdd))
			ME->(DbDelete())
			ME->(DbPack())
			ME->(DbGoTo(nRecPtr))
		endif
	endif
	WritePProString("Browse","ReMeState",oLbx:SaveState(),oApp():cInifile)
   if oCont != NIL
      oCont:Refresh()
   endif
   if oGrid != NIL
      oGrid:Refresh()
      oGrid:SetFocus( .t. )
   endif
   oApp():nEdit --
return nil
/*_____________________________________________________________________________*/

function  RmEdita(oLbx,nMode,aRe,lBlank,nMeComens)
   local oDlg
   local cRmCodigo, cRmReceta, cRmCategoria, cRmPlato, nRmComensal
   local aGet[6], oBtn

	if nMode == 1
		cRmCodigo 	 := space(10)
		cRmReceta 	 := space(60)
		cRmCategoria := space(30)
		cRmPlato 	 := space(30)
		nRmComensal  := nMeComens
	elseif nMode == 2
		if lBlank
			MsgStop("No hay ninguna receta para modificar.")
			retu nil
		endif
		cRmCodigo 	 := aRe[oLbx:nArrayAt,1]
		cRmReceta 	 := aRe[oLbx:nArrayAt,2]
		cRmCategoria := aRe[oLbx:nArrayAt,3]
		cRmPlato 	 := aRe[oLbx:nArrayAt,4]
		nRmComensal  := aRe[oLbx:nArrayAt,5]
	endif

   DEFINE DIALOG oDlg RESOURCE 'RM_EDIT_'+oApp():cLanguage ;
      TITLE iif(nMode==1,i18n("Nueva receta en el menú"),i18n("Modificar receta en el menú"))
	oDlg:SetFont(oApp():oFont)

	REDEFINE GET aGet[1] VAR cRmCodigo        ;
      ID 101 OF oDlg UPDATE                  ;
      PICTURE "@!"                           ;
      VALID ReClave( @cRmCodigo, aGet[1], 4, 2, aGet, oBtn )

   REDEFINE BUTTON oBtn ID 102 OF oDlg            ;
      ACTION ReSelAjena( @cRmCodigo, aGet[1], 4, 2, aGet )

	REDEFINE GET aGet[2] VAR cRmReceta        ;
      ID 103 OF oDlg UPDATE                  ;
      WHEN .f.

	REDEFINE GET aGet[3] VAR cRmCategoria     ;
      ID 104 OF oDlg UPDATE                  ;
      WHEN .f.

	REDEFINE GET aGet[4] VAR cRmPlato         ;
      ID 105 OF oDlg UPDATE                  ;
      WHEN .f.

	REDEFINE GET aGet[5] VAR nRmComensal      ;
		PICTURE "999" ID 106 OF oDlg UPDATE

   REDEFINE BUTTON   ;
      ID    IDOK     ;
      OF    oDlg     ;
      ACTION   ( cRmReceta    := aGet[2]:cText,;
					  cRmCategoria := aGet[3]:cText,;
					  cRmPlato     := aGet[4]:cText,;
					  oDlg:end( IDOK ) )

   REDEFINE BUTTON   ;
      ID    IDCANCEL ;
      OF    oDlg     ;
      CANCEL         ;
      ACTION   ( oDlg:end( IDCANCEL ) )

   ACTIVATE DIALOG oDlg ;
      ON INIT DlgCenter(oDlg,oApp():oWndMain)

   if oDlg:nresult == IDOK
      if nMode == 1
         if lBlank
            aRe[1] := { cRmCodigo, cRmReceta, cRmCategoria, cRmPlato, nRmComensal }
            lBlank := .f.
         else
            aadd( aRe, { cRmCodigo, cRmReceta, cRmCategoria, cRmPlato, nRmComensal } )
         endif
      else
         aRe[oLbx:nArrayAt] := { cRmCodigo, cRmReceta, cRmCategoria, cRmPlato, nRmComensal }
      endif
   endif
   oLbx:Refresh()
   oLbx:SetFocus( .t. )
return nil
/*_____________________________________________________________________________*/

function  RmBorra(oLbx,aRe,lBlank)
	aRe := ADel(aRe,oLbx:nArrayAt,.t.)
   if len(aRe) == 0
      AADD(aRe,{ '','','','','' })
      lBlank := .t.
	endif
	oLbx:Refresh()
	oLbx:SetFocus()
retu nil
/*_____________________________________________________________________________*/

function MeClave( cMeCodigo, oGet1, nMode, oGet2, oGet3 )
   // nMode    1 nuevo registro
   //          2 modificación de registro
   //          3 duplicación de registro
   //          4 clave ajena
   local lreturn  := .f.
   local nRecno   := ME->( RecNo() )
   local nOrder   := ME->( OrdNumber() )
   local nArea    := Select()

   if Empty( cMeCodigo )
      if nMode == 4
         return .t.
      else
         MsgStop("Es obligatorio rellenar este campo.")
         return .f.
      endif
   endif

   SELECT ME
   ME->( DbSetOrder( 1 ) )
   ME->( DbGoTop() )

   if ME->( DbSeek( Upper( cMeCodigo ) ) )
      DO CASE
         Case nMode == 1 .OR. nMode == 3
            lreturn := .f.
            MsgStop("Código de menú existente.")
         Case nMode == 2
            if ME->( Recno() ) == nRecno
               lreturn := .t.
            else
               lreturn := .f.
               MsgStop("Código de menú existente.")
            endif
         Case nMode == 4
            lreturn := .t.
				IF ! oApp():thefull
					Registrame()
				ENDIF
      END CASE
   else
      if nMode < 4
         lreturn := .t.
      else
         if MsgYesNo("Menú inexistente. ¿ Desea darlo de alta ahora? ",'Seleccione una opción')
            lreturn := MeEdita( , 1, , , @cMeCodigo )
         else
            lreturn := .f.
         endif
      endif
   endif

   if lreturn == .f.
      oGet1:cText( space(6) )
   else
      if oGet2 != nil
         oGet2:cText( ME->MeDescrip )
      endif
      if oGet3 != nil
         oGet3:cText( ME->MeFchPrep )
      endif
   endif

   ME->( DbSetOrder( nOrder ) )
   ME->( DbGoTo( nRecno ) )

   Select (nArea)

return lreturn
/*_____________________________________________________________________________*/

function MeSeleccion( cMeCodigo, oControl1, oParent, oControl2, oControl3 )
   local oDlg, oBrowse, oCol, oBtnAceptar, oBtnCancel, oBNew, oBMod, oBDel
   local lOk    := .f.
   local nRecno := ME->( RecNo() )
   local nOrder := ME->( OrdNumber() )
   local nArea  := Select()
   local aPoint := AdjustWnd( oControl1, 271*2, 150*2 )

   DEFINE DIALOG oDlg RESOURCE 'UT_AJENA1_'+oApp():cLanguage OF oParent;
      TITLE i18n("Selección de menús de eventos")
	oDlg:SetFont(oApp():oFont)

   SELECT ME
   ME->(DbSetOrder(1))
   ME->(DbGoTop())

   if ! ME->(DbSeek( cMeCodigo ) )
      ME->( DbGoTop() )
   endif

   oBrowse := TXBrowse():New( oDlg )
   Ut_BrwRowConfig( oBrowse )
   oBrowse:cAlias := "ME"

   oCol := oBrowse:AddCol()
   oCol:bStrData := { || ME->MeCodigo }
   oCol:cHeader  := "Menú"
	oCol:nWidth   := 90
   oCol:bLDClickData  := {|| ( lOk := .t., oDlg:End() )   }
	oCol := oBrowse:AddCol()
   oCol:bStrData := { || ME->MeDescrip }
   oCol:cHeader  := "Descripción"
	oCol:nWidth   := 190
   oCol:bLDClickData  := {|| ( lOk := .t., oDlg:End() )   }
   oBrowse:SetRDD()
   oBrowse:CreateFromResource( 110 )
	oBrowse:bKeyDown := {|nKey| MeTecla(nKey,oBrowse,oDlg,oBtnAceptar) }

   REDEFINE BUTTON oBNew   ;
      ID 410 OF oDlg       ;
      ACTION MeEdita( oBrowse, 1,,oDlg )

   REDEFINE BUTTON oBMod   ;
      ID 411 OF oDlg       ;
      ACTION MeEdita( oBrowse, 2,,oDlg )

   REDEFINE BUTTON oBDel   ;
      ID 412 OF oDlg       ;
      ACTION MeBorra( oBrowse, )

   REDEFINE BUTTON oBtnAceptar   ;
      ID IDOK OF oDlg            ;
      ACTION (lOk := .t., oDlg:End())

   REDEFINE BUTTON oBtnCancel    ;
      ID IDCANCEL OF oDlg        ;
      ACTION (lOk := .f., oDlg:End())

   ACTIVATE DIALOG oDlg CENTERED       ;
      ON PAINT oDlg:Move(aPoint[1], aPoint[2],,,.t.)

   if lOK
      oControl1:cText := ME->MeCodigo
		if oControl2 != NIL
			oControl2:cText := ME->MeDescrip
		endif
		if oControl3 != nil
         oControl3:cText( ME->MeFchPrep )
      endif
   endif

   ME->( DbSetOrder( nOrder ) )
   ME->( DbGoTo( nRecno ) )

   Select (nArea)

return nil
/*_____________________________________________________________________________*/
function MeBorra(oGrid,oCont)
   local nRecord := ME->(Recno())
   local nNext

   oApp():nEdit ++
   if msgYesNo( i18n("¿ Está seguro de borrar este menú de evento ?") + CRLF + ;
                (trim(ME->MeDescrip)),'Seleccione una opción')
      /* ___ Borro las recetas del menú _______________________________________*/
      SELECT RM
		delete for RM->RmMeCodigo == ME->MeCodigo
      RM->(DbPack())
		RM->(DbCommit())
      /* ___ borro el menu ____________________________________________________*/
      SELECT ME
      ME->(DbSkip())
      nNext := ME->(Recno())
      ME->(DbGoto(nRecord))
      ME->(DbDelete())
      ME->(DbPack())
      ME->(DbGoto(nNext))
      if ME->(EOF()) .or. nNext == nRecord
         ME->(DbGoBottom())
      endif
   endif
   RefreshCont(oCont,"ME")
   oGrid:Refresh(.t.)
   oGrid:SetFocus(.t.)
   oApp():nEdit --

return nil
/*_____________________________________________________________________________*/
function MeTecla(nKey,oGrid,oCont,oDlg)
	do case
	   case nKey==VK_RETURN
	      MeEdita(oGrid,2,oCont,oDlg)
	   case nKey==VK_INSERT
	      MeEdita(oGrid,1,oCont,oDlg)
	   case nKey==VK_DELETE
	      MeBorra(oGrid,oCont)
	   case nKey==VK_ESCAPE
	      oDlg:End()
	   otherwise
	      if nKey >= 96 .AND. nKey <= 105 // número
	         MeBusca(oGrid,STR(nKey-96,1),oCont,oDlg)
	      elseif HB_ISSTRING(CHR(nKey))
	         MeBusca(oGrid,CHR(nKey),oCont,oDlg)
	      endif
	endcase
return nil
/*_____________________________________________________________________________*/

function MeBusca(oGrid, cChr, oCont, oParent)
   local nOrder    := ME->(OrdNumber())
   local nRecno    := ME->(Recno())
   local oDlg, oGet, cGet, cPicture
   local aSay1    := { i18n("Introduzca el código del menú de evento")   ,;
                       i18n("Introduzca la descripción del menú de evento")   ,;
                       i18n("Introduzca la fecha de preparación del menú")  }
   local aSay2    := { i18n("Código:")  ,;
                       i18n("Descripción:") ,;
                       i18n("Fecha:")        }
   local aGet     := { space(10) ,;
                       space(60) ,;
                       CtoD("")  }

   local cCodigo   := space(10)
   local cDescrip  := space(60)
   local dFecha    := CtoD('')
   local lSeek     := .f.
   local lFecha    := .f.
	local aBrowse   := {}

   oApp():nEdit ++

   DEFINE DIALOG oDlg RESOURCE 'UT_BUSCA_'+oApp():cLanguage OF oParent  ;
      TITLE i18n("Búsqueda de menús de eventos")
	oDlg:SetFont(oApp():oFont)

   REDEFINE SAY PROMPT aSay1[nOrder] ID 20 OF oDlg
   REDEFINE SAY PROMPT aSay2[nOrder] ID 21 OF Odlg

   cGet  := aGet[nOrder]

   IF nOrder == 3
      lFecha := .t.
   ENDIF
   /*__ si he pasado un caracter lo meto en la cadena a buscar ________________*/

   IF cChr != NIL
      IF .NOT. lFecha
         cGet := cChr+SubStr(cGet,1,len(cGet)-1)
      ELSE
         cGet := CtoD('  -  -    ')
      ENDIF
   ENDIF

   IF ! lFecha
      REDEFINE GET oGet VAR cGet PICTURE "@!" ID 101 OF oDlg
   ELSE
      REDEFINE GET oGet VAR cGet ID 101 OF oDlg
      // oGet:cText := cChr+' -  -    '
   ENDIF

   IF cChr != NIL
      oGet:bGotFocus := { || oGet:SetPos(2) }
   ENDIF

   REDEFINE BUTTON ID IDOK OF oDlg ;
      PROMPT i18n( "&Aceptar" )   ;
      ACTION (lSeek := .t., oDlg:End())
   REDEFINE BUTTON ID IDCANCEL OF oDlg CANCEL ;
      PROMPT i18n( "&Cancelar" )  ;
      ACTION (lSeek := .f., oDlg:End())

   sysrefresh()
   ACTIVATE DIALOG oDlg ;
      ON INIT ( DlgCenter(oDlg,oApp():oWndMain) )// , IIF(cChr!=NIL,oGet:SetPos(2),), oGet:Refresh() )

   IF lSeek
      if ! lFecha
         cGet := rtrim(Upper(cGet))
		endif
		MsgRun('Realizando la búsqueda...', oApp():cAppName+oApp():cVersion, ;
         { || MeWildSeek(nOrder, cGet, aBrowse ) } )
      if len(aBrowse) == 0
         MsgStop("No se ha encontrado ningún menú.")
      else
         MeEncontrados(aBrowse, oApp():oDlg)
      endif
   ENDIF
   IF oCont != NIL
      RefreshCont(oCont,"ME")
   ENDIF

   oApp():nEdit --
   oGrid:Refresh()
   oGrid:SetFocus( .t. )
return nil
/*_____________________________________________________________________________*/
function MeWildSeek(nOrder, cGet, aBrowse)
   local nRecno   := ME->(Recno())
   do case
      case nOrder == 1
         ME->(DbGoTop())
         do while ! ME->(eof())
            if cGet $ upper(ME->MeCodigo)
               aadd(aBrowse, {ME->MeCodigo, ME->MeDescrip, ME->MeFchPrep, ME->(Recno()) })
            endif
            ME->(DbSkip())
         enddo
      case nOrder == 2
         ME->(DbGoTop())
         do while ! ME->(eof())
            if cGet $ upper(ME->MeDescrip)
               aadd(aBrowse, {ME->MeCodigo, ME->MeDescrip, ME->MeFchPrep, ME->(Recno()) })
            endif
            ME->(DbSkip())
         enddo
      case nOrder == 3
         ME->(DbGoTop())
         do while ! ME->(eof())
            if cGet == ME->MeFchPrep
               aadd(aBrowse, {ME->MeCodigo, ME->MeDescrip, ME->MeFchPrep, ME->(Recno()) })
            endif
            ME->(DbSkip())
         enddo
   end case
   ME->(DbGoTo(nRecno))
   // ordeno la tabla por el 1 elemento
   ASort( aBrowse,,, { |aAut1, aAut2| upper(aAut1[1]) < upper(aAut2[1]) } )
return nil
/*_____________________________________________________________________________*/

function MeEncontrados(aBrowse, oParent)
   local oDlg, oBrowse, oBtnOk, oBtnCancel, lOk
   local nRecno := ME->(Recno())

   DEFINE DIALOG oDlg RESOURCE "DLG_ENCONTRADOS" ;
      TITLE i18n( "Resultado de la búsqueda" ) ;
      OF oParent
   oDlg:SetFont(oApp():oFont)

   oBrowse := TXBrowse():New( oDlg )
	Ut_BrwRowConfig( oBrowse )

   oBrowse:SetArray(aBrowse, .f.)
   oBrowse:aCols[1]:cHeader := "Código"
   oBrowse:aCols[2]:cHeader := "Descripción"
   oBrowse:aCols[3]:cHeader := "Fch. Preparación"
   oBrowse:aCols[1]:nWidth  := 90
   oBrowse:aCols[2]:nWidth  := 340
   oBrowse:aCols[3]:nWidth  := 100
	oBrowse:aCols[4]:Hide()
	oBrowse:aCols[1]:nHeadStrAlign := 0
	oBrowse:aCols[1]:nDataStrAlign := 0
	oBrowse:aCols[2]:nHeadStrAlign := 0
	oBrowse:aCols[2]:nDataStrAlign := 0
	oBrowse:aCols[3]:nHeadStrAlign := 0
	oBrowse:aCols[3]:nDataStrAlign := 0

   oBrowse:CreateFromResource( 110 )

   ME->(DbGoTo(aBrowse[oBrowse:nArrayAt, 4]))
   aEval( oBrowse:aCols, { |oCol| oCol:bLDClickData := { ||ME->(DbGoTo(aBrowse[oBrowse:nArrayAt, 4])),;
                                                           MsEdita( , 2,, oApp():oDlg ) }} )
   oBrowse:bKeyDown  := {|nKey| IIF(nKey==VK_RETURN,(ME->(DbGoTo(aBrowse[oBrowse:nArrayAt, 4])),;
                                                     MsEdita( , 2,, oApp():oDlg )),) }
   oBrowse:bChange    := { || ME->(DbGoTo(aBrowse[oBrowse:nArrayAt, 4])) }
   oBrowse:lHScroll  := .f.
   oDlg:oClient      := oBrowse
   oBrowse:nRowHeight:= 20

   REDEFINE BUTTON oBtnOk ;
      ID IDOK OF oDlg     ;
      ACTION oDlg:End()

   REDEFINE BUTTON oBtnCancel ;
      ID IDCANCEL OF oDlg ;
      ACTION (ME->(DbGoTo(nRecno)), oDlg:End())

   ACTIVATE DIALOG oDlg ;
      ON INIT DlgCenter(oDlg,oApp():oWndMain)

return nil

/*_____________________________________________________________________________*/

function MeCompra(oGrid, oParent,lReport)
	local cMeCodigo := ME->MeCodigo
	local cReCodigo, nReComensal
	local oDlg, oBrowse, oCol
	local nTotal := 0
	CursorWait()
	Select RE
	RE->(OrdSetFocus(2))
	RE->(DbGoTop())
	Select ES
	ES->(OrdSetFocus(1))	// upper(EsReceta)
	ES->(DbGoTop())
   Select TS
   TS->(DbPack())
   TS->(Db_ZAP())
	TS->(OrdSetFocus(2)) // Upper(EsIngred)
	TS->(DbGoTop())
	Select RM
	RM->(OrdSetFocus(1)) // Upper(RmMeCodigo)
	RM->(DbGoTop())
	RM->(DbSeek(Upper(cMeCodigo)))
	while Upper(RM->RmMeCodigo) == Upper(cMeCodigo)
		cReCodigo 	:= RM->RmReCodigo
		Select RE
		RE->(DbSeek(cReCodigo))
		// nReComensal := RM->RmComensal
		Select ES
		ES->(DbSeek(cReCodigo))
		While ES->EsReceta == cReCodigo
			Select TS
			if TS->(DbSeek(ES->EsIngred))
				if ES->EsCanFija == .t.
					Replace TS->EsCantidad with TS->EsCantidad + ES->EsCantidad
					Replace TS->EsPrecio   with TS->EsPrecio + ES->EsPrecio
				else
					Replace TS->EsCantidad with TS->EsCantidad + ES->EsCantidad / RE->ReComEsc * RM->RmComensal
					Replace TS->EsPrecio   with TS->EsPrecio + ES->EsPrecio / RE->ReComEsc * RM->RmComensal
				endif
			else
				TS->(DbAppend())
				Replace TS->EsIngred 	with ES->EsIngred
				Replace TS->EsInDenomi  with ES->EsInDenomi
				Replace TS->EsUnidad		with ES->EsUnidad
				Replace TS->EsProveed   with ES->Esproveed
				if ES->EsCanFija == .t.
					Replace TS->EsCantidad with ES->EsCantidad
					Replace TS->EsPrecio   with ES->EsPrecio
				else
					Replace TS->EsCantidad with ES->EsCantidad / RE->ReComEsc * RM->RmComensal
					Replace TS->EsPrecio   with ES->EsPrecio / RE->ReComEsc * RM->RmComensal
				endif
			endif
			nTotal += ES->EsPrecio / RE->ReComEsc * RM->RmComensal
			TS->(DbCommit())
			ES->(DbSkip())
		enddo
		RM->(DbSkip())
	enddo
	CursorArrow()
	if lReport
		retu nil
	endif

   DEFINE DIALOG oDlg RESOURCE 'ME_ESCAN'  ;
      TITLE 'Lista de la compra de: '+ME->MeDescrip OF oParent
	oDlg:SetFont(oApp():oFont)

   Select TS
   TS->(DbGoTop())

   oBrowse := TXBrowse():New( oDlg )
   Ut_BrwRowConfig( oBrowse )
   oBrowse:cAlias := "TS"
	oBrowse:lFooter:= .t.

   oCol := oBrowse:AddCol()
   oCol:bStrData := { || TS->EsIngred }
   oCol:cHeader  := "Código"
   oCol:nWidth   := 60

	oCol := oBrowse:AddCol()
	oCol:bStrData := { || TS->EsInDenomi }
	oCol:cHeader  := "Ingrediente"
	oCol:nWidth   := 250

	oCol := oBrowse:AddCol()
	oCol:bStrData := { || TS->EsUnidad }
	oCol:cHeader  := "Unidad"
	oCol:nWidth   := 60

	oCol := oBrowse:AddCol()
	oCol:bStrData := { || Tran(TS->EsCantidad, "@E 999,999.999") }
	oCol:cHeader  := "Cantidad"
	oCol:nWidth   := 60
   // oCol:cEditPicture  := "@E999,999.999"
   oCol:nHeadStrAlign := AL_RIGHT
	oCol:nDataStrAlign := AL_RIGHT
	oCol:nFootStrAlign := AL_RIGHT

	ADD oCol TO oBrowse DATA TS->EsPrecio ;
		HEADER "Precio"   WIDTH 60 TOTAL 0 ;
      PICTURE "@E 999,999.99" 

	//oCol := oBrowse:AddCol()
	//oCol:bStrData := { || Tran(TS->EsPrecio,"@E 999,999.99") }
	//oCol:cHeader  := "Precio"
	//oCol:nWidth   := 60
	//oCol:nTotal   := nTotal
	//oCol:lTotal   := .t.
   //oCol:nHeadStrAlign := AL_RIGHT
	//oCol:nDataStrAlign := AL_RIGHT
	//oCol:nFootStrAlign := AL_RIGHT

   oBrowse:SetRDD()
   oBrowse:CreateFromResource( 110 )
	oBrowse:maketotals()

   REDEFINE BUTTON ID 200 OF oDlg ;
      PROMPT i18n( "&Imprimir" )   ;
      ACTION (MeCompraInforme(), oDlg:End())

   REDEFINE BUTTON ID 201 OF oDlg ;
      PROMPT i18n( "&Excel" )   ;
      ACTION (CursorWait(), Ut_ExportXLS( oBrowse, "Lista de la compra" ), CursorArrow());

   REDEFINE BUTTON   ;
      ID    IDCANCEL ;
      OF    oDlg     ;
      CANCEL         ;
      ACTION   ( oDlg:end( IDCANCEL ) )

   ACTIVATE DIALOG oDlg ;
      ON INIT DlgCenter(oDlg,oApp():oWndMain)

   SELECT ME
   oGrid:Refresh()
   oGrid:SetFocus(.t.)
   oApp():nEdit --
return nil
//_____________________________________________________________________________//

function MePreparacion(oGrid, oParent,lReport)
	if msgyesno('¿ Desea anotar en las recetas del menú la fecha de preparación del menú ?'+CRLF+;
					'Solo se cambiará la fecha si la del menú es posterior a la de la receta.')
		RE->(OrdSetFocus(2))
		RM->(DbGoTop())
		do while ! RM->(EoF()) 
			if Upper(RM->RmMeCodigo) == Upper(ME->MeCodigo)
				RE->(DbGoTop())
				if RE->(DbSeek(RM->RmReCodigo))
					if RE->ReFchPrep < ME->MeFchPrep
						Select RE
						replace RE->ReFchPrep with ME->MeFchPrep
						RE->(DbCommit())
					endif	
				else 
					msgalert('La receta '+RM->RmReCodigo+' no existe.')
				endif
			endif
			Select RM
			RM->(DbSkip())
		enddo
		MsgInfo('La anotación de fechas se realizó correctamente.')
	endif
return NIL
//_____________________________________________________________________________// 

function MeImprime(oGrid, oParent)
	local nRecno   := ME->(Recno())
   local nOrder   := ME->(OrdSetFocus())
   local aCampos  := { "MECODIGO","MEDESCRIP","MEFCHPREP" }
   local aTitulos := { "Código","Descripción","Fecha Preparación" }
   local aWidth   := { 8,60,15 }
   local aShow    := { .t.,.t., .t. }
   local aPicture := { "NO","NO","NO" }
   local aTotal   := { .f.,.f., .t. }
   local oInforme
	local aTPlato   := { 'Entradas', '1er Plato', '2o Plato', 'Postre', 'Dulce', 'Otro' }
	local cReMeCodigo
	local aRe := {}
	local nAt := 1

   oApp():nEdit ++
   oInforme := TInforme():New( aCampos, aTitulos, aWidth, aShow, aPicture, aTotal, "ME" )
   oInforme:Dialog()

   REDEFINE RADIO oInforme:oRadio VAR oInforme:nRadio ID 300,301,302  OF oInforme:oFld:aDialogs[1]

   oInforme:Folders()

   if oInforme:Activate()
		if oInforme:nRadio == 1
	      ME->(DbGoTop())
	      oInforme:Report()
	      ACTIVATE REPORT oInforme:oReport ;
	         ON END ( oInforme:oReport:StartLine(), oInforme:oReport:EndLine(), oInforme:oReport:StartLine(), ;
	                  oInforme:oReport:Say(1, 'Total menús: '+Tran(oInforme:oReport:nCounter, '@E 999,999'), 1),;
	                  oInforme:oReport:EndLine() )
	      oInforme:End(.t.)
	      ME->(DbGoTo(nRecno))
		elseif oInforme:nRadio == 2
			Select RM
			cReMeCodigo := ME->MeCodigo
			Select RE
			RE->(OrdSetFocus(2))
			Select RM
			RM->(DbGoTop())
		   do while ! RM->(EoF())
		      if Upper(RM->RmMeCodigo) == Upper(cReMeCodigo)
					RE->(DbGoTop())
					RE->(DbSeek(RM->RmReCodigo))
		         AADD(aRe,{RE->ReCodigo ,;
		 						 RE->ReTitulo ,;
								 aTPlato[MAX(VAL(RE->RePlato),1)],;
								 RE->ReTipo   ,;
								 RM->RmComensal })
		      endif
		      RM->(DbSkip())
		   enddo
			oInforme:oFont1 := TFont():New( Rtrim( oInforme:acFont[ 1 ] ), 0, Val( oInforme:acSizes[ 1 ] ),,( i18n("Negrita") $ oInforme:acEstilo[ 1 ] ),,,,( i18n("Cursiva") $ oInforme:acEstilo[ 1 ] ),,,,,,, )
			oInforme:oFont2 := TFont():New( Rtrim( oInforme:acFont[ 2 ] ), 0, Val( oInforme:acSizes[ 2 ] ),,( i18n("Negrita") $ oInforme:acEstilo[ 2 ] ),,,,( i18n("Cursiva") $ oInforme:acEstilo[ 2 ] ),,,,,,, )
			oInforme:oFont3 := TFont():New( Rtrim( oInforme:acFont[ 3 ] ), 0, Val( oInforme:acSizes[ 3 ] ),,( i18n("Negrita") $ oInforme:acEstilo[ 3 ] ),,,,( i18n("Cursiva") $ oInforme:acEstilo[ 3 ] ),,,,,,, )
			if oInforme:nDevice == 1
				REPORT oInforme:oReport ;
					TITLE  ' ', ME->MeCodigo+' '+Rtrim(ME->MeDescrip),'Relación de recetas del menú' CENTERED;
					FONT   oInforme:oFont3, oInforme:oFont2, oInforme:oFont1 ;
					HEADER ' ', oApp():cAppName+oApp():cVersion, oApp():cUser   ;
					FOOTER ' ', "Fecha: "+dtoc(date())+ "   Página.: "+str(oInforme:oReport:nPage,3) ;
					CAPTION oApp():cAppName+oApp():cVersion PREVIEW
			else
				REPORT oInforme:oReport ;
					TITLE ' ', ME->MeCodigo+' '+Rtrim(ME->MeDescrip),'Relación de recetas del menú' CENTERED;
					FONT   oInforme:oFont3, oInforme:oFont2, oInforme:oFont1 ;
					HEADER ' ', oApp():cAppName+oApp():cVersion, oApp():cUser   ;
					FOOTER ' ', "Fecha: "+dtoc(date())+ "   Página.: "+str(oInforme:oReport:nPage,3) ;
					CAPTION oApp():cAppName+oApp():cVersion
			endif
			COLUMN TITLE "Codigo"  DATA aRe[nAt, 1] FONT 1 SIZE 8
			COLUMN TITLE "Receta"  DATA aRe[nAt, 2] FONT 1 SIZE 30
			COLUMN TITLE "Categoría"  DATA aRe[nAt, 3] FONT 1 SIZE 18
			COLUMN TITLE "Plato"      DATA aRe[nAt, 4] FONT 1 SIZE 18
			COLUMN TITLE "Comensales" DATA aRe[nAt, 5] FONT 1 SIZE 13
			END REPORT
			oInforme:oReport:Cargo := "Recetas del menú.pdf"
		   if oInforme:oReport:lCreated
		      oInforme:oReport:nTitleUpLine     := RPT_SINGLELINE
		      oInforme:oReport:nTitleDnLine     := RPT_SINGLELINE
		      oInforme:oReport:oTitle:aFont[1]  := {|| 3 }
		      oInforme:oReport:oTitle:aFont[2]  := {|| 2 }
		      oInforme:oReport:nTopMargin       := 0.1
		      oInforme:oReport:nDnMargin        := 0.1
		      oInforme:oReport:nLeftMargin      := 0.1
		      oInforme:oReport:nRightMargin     := 0.1
		      oInforme:oReport:oDevice:lPrvModal:= .t.
		   endif
			oInforme:oReport:bSkip := {|| nAt++}
			ACTIVATE REPORT oInforme:oReport WHILE nAt <= len(aRe)
			oInforme:End(.t.)
		elseif oInforme:nRadio == 3
			MeCompra(,,.t.)
			MeCompraInforme(oInforme)
		endif
		Select ME
   endif
   oApp():nEdit --
   oGrid:Refresh()
   oGrid:SetFocus( .t. )
return nil
/*_____________________________________________________________________________*/
Function MeCompraInforme(oInforme)
	local aCampos  := { "MECODIGO","MEDESCRIP","MEFCHPREP" }
   local aTitulos := { "Código","Descripción","Fecha Preparación" }
   local aWidth   := { 8,60,15 }
   local aShow    := { .t.,.t., .t. }
   local aPicture := { "NO","NO","NO" }
   local aTotal   := { .f.,.f., .t. }

	if oInforme == NIL
		oInforme := TInforme():New( aCampos, aTitulos, aWidth, aShow, aPicture, aTotal, "ME" )
	endif
	Select TS
	TS->(DbGoTop())
	oInforme:oFont1 := TFont():New( Rtrim( oInforme:acFont[ 1 ] ), 0, Val( oInforme:acSizes[ 1 ] ),,( i18n("Negrita") $ oInforme:acEstilo[ 1 ] ),,,,( i18n("Cursiva") $ oInforme:acEstilo[ 1 ] ),,,,,,, )
	oInforme:oFont2 := TFont():New( Rtrim( oInforme:acFont[ 2 ] ), 0, Val( oInforme:acSizes[ 2 ] ),,( i18n("Negrita") $ oInforme:acEstilo[ 2 ] ),,,,( i18n("Cursiva") $ oInforme:acEstilo[ 2 ] ),,,,,,, )
	oInforme:oFont3 := TFont():New( Rtrim( oInforme:acFont[ 3 ] ), 0, Val( oInforme:acSizes[ 3 ] ),,( i18n("Negrita") $ oInforme:acEstilo[ 3 ] ),,,,( i18n("Cursiva") $ oInforme:acEstilo[ 3 ] ),,,,,,, )

	REPORT oInforme:oReport ;
		TITLE  ' ',ME->MeCodigo+' '+Rtrim(ME->MeDescrip),'Lista de la compra',' ' CENTERED;
		FONT   oInforme:oFont3, oInforme:oFont2, oInforme:oFont1 ;
		HEADER ' ', oApp():cAppName+oApp():cVersion, oApp():cUser   ;
		FOOTER ' ', "Fecha: "+dtoc(date())+ "   Página.: "+str(oInforme:oReport:nPage,3) ;
		CAPTION oApp():cAppName+oApp():cVersion PREVIEW

	COLUMN TITLE "Codigo"  		DATA TS->EsIngred   FONT 1 SIZE 8
	COLUMN TITLE "Ingrediente" DATA TS->EsInDenomi FONT 1 SIZE 30
	COLUMN TITLE "Unidad"  		DATA TS->EsUnidad   FONT 1 SIZE 18
	COLUMN TITLE "Cantidad"    DATA TS->EsCantidad FONT 1 PICTURE "@E 999,999.999" SIZE 10
	COLUMN TITLE "Precio" 		DATA TS->EsPrecio   FONT 1 PICTURE "@E 999,999.99" SIZE 10 TOTAL
	END REPORT
	oInforme:oReport:Cargo := "Lista de la compra del menú.pdf"
	if oInforme:oReport:lCreated
		oInforme:oReport:nTitleUpLine     := RPT_SINGLELINE
		oInforme:oReport:nTitleDnLine     := RPT_SINGLELINE
		oInforme:oReport:oTitle:aFont[2]  := {|| 3 }
		oInforme:oReport:oTitle:aFont[3]  := {|| 2 }
		oInforme:oReport:nTopMargin       := 0.1
		oInforme:oReport:nDnMargin        := 0.1
		oInforme:oReport:nLeftMargin      := 0.1
		oInforme:oReport:nRightMargin     := 0.1
		oInforme:oReport:oDevice:lPrvModal:= .t.
	endif
	// oInforme:oReport:bSkip := {|| nAt++}
	ACTIVATE REPORT oInforme:oReport
	oInforme:End(.t.)
return NIL

Function MeGetRecetas(cMeCodigo)
	local nReturn := 0
	select RM
	RM->(DbGoTop())
	count to nReturn for Upper(RM->RmMeCodigo) == Upper(cMeCodigo) .and. ! Deleted()
	select ME
return nReturn

Function MeSort(nOrden, oCont)
   LOCAL nRecno := ME->(Recno())
   LOCAL nLen   := Len(oApp():oGrid:aCols)
	local n
   FOR n := 1 TO nLen
		IF oApp():oGrid:aCols[ n ]:nHeadBmpNo != NIL .and. oApp():oGrid:aCols[ n ]:nHeadBmpNo > 0
         IF oApp():oGrid:aCols[ n ]:Cargo == nOrden
            oApp():oGrid:aCols[ n ]:nHeadBmpNo := 1
         ELSE
            oApp():oGrid:aCols[ n ]:nHeadBmpNo := 2
         ENDIF
      ENDIF
   NEXT
	oApp():oTab:SetOption(nOrden)
	ME->(dbsetorder(norden))      	
 	iif(ME->(eof()),ME->(dbgotop()),)      
   Refreshcont(ocont,"ME")
   ME->(DbGoTo(nRecno))
   oApp():oGrid:Refresh(.t.)
   oApp():oGrid:SetFocus(.t.)
return NIL


