// Clase TWord
// Mira el documento TWord.doc para información
// 2003 Sebastián Almirón


/*

   5-Diciembre-2003
   Clase TWord
   Modificada por : Víctor Manuel Tomás Díaz [  Vikthor  ] vikthor@creswin.com

   He quitado todas las llamadas a las funciones OleGetProperty() , OleSetProperty() , OleInvoke().
   Ahora es usada la clase TOleAuto() y sus Metodos :Get , :Set , :Invoke

   ++ METHOD Sendmail( lAttach )
   ++ METHOD HeaderFooter( nOption )
   ++ METHOD OpenDataSource( cFile )
   ++ METHOD AddField( cField )
   ++ METHOD WebPagePreview()

   2004.12.02
   ++ Data oTables
   ++ METHOD AddTables()

   2004.12.03
   ** Modificación al Metodo New usando TRY y CATCH para recuperar una instacia abierta
      crearla o enviar un mensaje de error.
*/

#include "FiveWin.Ch"
#define  TAB   chr(9)
#define  ENTER chr(13)

#define  ALI_LEFT    0
#define  ALI_CENTER  1
#define  ALI_RIGHT   2
#define  ALI_JUSTIFY 3

#define  LOGPIXELSX  88
#define  LOGPIXELSY  90

// Registros y delimitadores de campos de la estructura GTF
#define SP_REG    Chr( 5 )
#define SP_FIELD  Chr( 7 )
#define TP_FONT  Chr( 15 )
#define TP_COLOR  Chr( 16 )
#define TP_ALIGN  Chr( 17 )

// Identificador y versión de las ficheros GTF
#define FORMAT_TEXT_TYPE       "GTF"
#define FORMAT_TEXT_VERSION      "1"

// LA CLASE TWORD

CLASS TWord
      DATA oWord
      DATA oDocs
      DATA oActiveDoc
      DATA oTexto
    DATA oSelection
      DATA cNombreDoc
      DATA nLinea,nCol, nPage
      DATA nYoffset, nXoffset
      DATA lstartpag
      DATA oLastSay
      DATA lOverflowing
      DATA nlastrow
      DATA cTextOverflow
      DATA lSetCm

      DATA oOptions           // Objeto Options
      DATA oMailMerge         // Combinar correspondencia
      DATA oDataSource        // Objeto MailMergeDataSource
      DATA oDataFields        // Objeto MailMergeDataFields
      DATA oFields            // Objeto MailMergeFields
      DATA oTables             // Objeto Tables
      DATA lWord

      METHOD AddImagen( nTop, nLeft, nBottom, nRight, cImagen, alinea, ntipo, nrotacion )
      METHOD addtabulador(npos, ocuadrotext)
      METHOD Box( nTop, nLeft, nBottom, nRight, afondo, alinea, ntipo, nrotation, lsimple )
      METHOD close()
      METHOD CmSay( nLin,nCol,cTexto,oFuente,nSizeHorz,nClrText,nBkMode,nPad, naltura, nColorIndex, lVertAdjust )
      METHOD CheckSpelling()
      METHOD End()
      METHOD EndPage()
      METHOD FillRect( aRect, oBrush )
      METHOD GetTextHeight( oFont )
      METHOD GetTextWidth(cText, oFont)
      METHOD GoBottom() INLINE ::oTexto:Invoke( 'EndKey', 6)
      METHOD GoTop() INLINE ::oTexto:Invoke( 'HomeKey', 6)
      METHOD JustificaDoc( nJustify, otext )
      METHOD Line( nTop, nLeft, nBottom, nRight, oPen, nColor, nStyle )
      METHOD New()
      METHOD NewDoc( cNombreDoc )
      METHOD nLogPixelX() INLINE 55.38
      METHOD nLogPixelY() INLINE 55.38
      METHOD OpenDoc( cNombreDoc )
      METHOD Preview()
      METHOD PrintDoc(lbackground, lappend, nRange, cOutputFile, nfrom, nto, nitem, ncopias, cpages)
      METHOD Protect(cpassword,nmodo)
      METHOD Replace( cOld, cNew )
      METHOD Save(cnombredoc)
      METHOD Say( nLin,nCol,cTexto,oFuente,nSizeHorz,nClrText,nBkMode,nPad, naltura, nColorIndex, lvertadjust )
      METHOD Say2( nLin,nCol,cTexto,oFuente, nSize, lBold, lShadow, nColor )
      METHOD SayGTF( nTop,nLeft, cTextFormat, nBottom,nRight )
      METHOD SetCm()
      METHOD SetHeader()
      METHOD SetLandScape()
      METHOD SetMainDoc()
      METHOD SetPortrait()
      METHOD SetUl()
      METHOD StartPage()
      METHOD TabClearAll(ocuadrotext)
      METHOD TabPredeterminado(ncada)
      METHOD TextBox( nTop, nLeft, nBottom, nRight, cTexto, oFuente, nclrtext, nClrBack, nJustify, afondo, alinea, lvertadjust, norientacion)
      METHOD UnProtect(cpassword)
      METHOD VistaCompleta()
      METHOD Visualizar INLINE ::oWord:Visible := .T.
      METHOD Write( cTexto, cFuente, cSize, lBold, lShadow, nColor )
      METHOD Sendmail( lAttach ) // Vikthor
      METHOD HeaderFooter( nOption )  // Vikthor
      METHOD OpenDataSource( cFile )  // Vikthor
      METHOD AddField( cField )  // Vikthor
      METHOD WebPagePreview() INLINE ::oActiveDoc:Get("WebPagePreview") // [ Vikthor ] Genera una vista en HTML del libro.
      METHOD AddTables(  aDatos ) // [ Vikthor ]
      METHOD Find( cText ) // [ Vikthor ]
      METHOD Hide()     INLINE ::oWord:Visible := .F.      // [ Vikthor ]
      METHOD IsVisible()     INLINE ::oWord:Visible        // [ Vikthor ]

ENDCLASS


METHOD AddImagen( nTop, nLeft, nBottom, nRight, cImagen, alinea, ntipo, nrotacion ) CLASS TWord

       ::Box(nTop, nLeft, nBottom, nRight, {,,,,,,,cImagen}, alinea, ntipo, nrotacion, .t.)

       return nil


METHOD addtabulador(npos, ocuadrotext) CLASS TWord
       local otabstop, oParagraphFormat
     DEFAULT ocuadrotext := ::oTexto
       if ::lsetcm
          npos := npos*28.35
       endif
       oParagraphFormat := oCuadroText:Get( 'ParagraphFormat')
       otabstop := oParagraphFormat:Get( 'TabStops')
       oTabstop:Invoke('Add',npos)
       release oParagraphFormat, otabstop
       return nil


METHOD Box( nTop, nLeft, nBottom, nRight, afondo, alinea, ntipo, nrotation, lPicTextured ) CLASS TWord
       LOCAL oShapes,oShapBox, oFill, oFillColor, olinea , n
       DEFAULT afondo := {}, alinea := {}, ntipo := 1, nrotation := 0, lPicTextured := .f.
       ::nLastRow := nBottom
       if ::lsetcm
          nTop := nTop*28.35
          nLeft := nLeft*28.35
          nBottom := nBottom*28.35
          nRight := nRight*28.35
       endif
       nRight := nRight - nLeft
       nBottom := nBottom - nTop
     oShapes     := ::oSelection:Get( "Shapes" )
       oShapBox    := oShapes:Invoke( "AddShape",ntipo,nLeft,nTop,nRight,nBottom )
       //oShapBox:Set('RelativeHorizontalPosition', 1 )            // No
       //oShapBox:Set('RelativeVerticalPosition', 1 )              // No
       oFill       := oShapBox:Get( "Fill" )
       oShapBox:Set('Rotation', nRotation )
       for n = 1 to len(afondo)
           do case
              case n = 1 .and. afondo[n] <> NIL
                   oFillColor  := oFill:Get("ForeColor")
                   oFillColor:Set( 'RGB', aFondo[1] )
              case n = 2 .and. afondo[n] <> NIL
                   oFillColor  := oFill:Get("BackColor")
                   oFillColor:Set( 'RGB', afondo[2] )
              case n = 3 .and. afondo[n] <> NIL
                   oFillColor:Set( 'Transparency', afondo[3])
              case n = 4 .and. afondo[n] <> NIL
                   oFill:Invoke( 'TwoColorGradient', afondo[4], afondo[5] )
              case n = 6 .and. afondo[n] <> NIL
                   oFill:Invoke( 'Patterned', afondo[6] )
              case n = 7 .and. afondo[n] <> NIL
                   oFill:Invoke( 'PresetTextured', afondo[7] )
              case n = 8 .and. afondo[n] <> NIL
                   if lPicTextured = .t.
                      oFill:Invoke( 'UserPicture', afondo[8] )
                   else
                      oFill:Invoke( 'UserTextured' , afondo[8] )
                   endif
           endcase
       next n
       oLinea      := oShapBox:Get( "Line" )
       for n = 1 to len(alinea)
           do case
              case n = 1
                   oLinea:Set( "Weight", alinea[1] )
              case n = 2
                   oLinea:Set( "ForeColor", alinea[2] )
              case n = 3
                   oLinea:Set( "BackColor", alinea[3] )
              case n = 4
                   oLinea:Set( "Transparency", alinea[4])
              case n = 5
                   oLinea:Set( "DashStyle", alinea[5] )
              case n = 5
                   oLinea:Set( "Style", alinea[6] )
           endcase
       next n
       release oShapes,oShapBox, oFill, oFillColor, olinea
       return nil

METHOD close(oDoc) CLASS TWord
       DEFAULT oDoc := ::oActiveDoc
       oDoc:Invoke('Close',0)
       return NIL


METHOD CmSay( nLin,nCol,cTexto,oFuente,nSizeHorz,nClrText,nBkMode,nPad, naltura, nColorIndex, lVertAdjust ) CLASS TWord
       local lsetcm := ::lsetcm
       ::lSetCm := .t.
       ::Say( nLin,nCol,cTexto,oFuente,nSizeHorz,nClrText,nBkMode,nPad, naltura, nColorIndex, lVertAdjust )
       ::lSetcm := lsetcm
       return Nil


METHOD CheckSpelling() CLASS TWord
       ::oActiveDoc:Invoke( 'CheckSpelling')
       return nil


METHOD End() CLASS TWord
       ::oDocs:Invoke('Close')
       ::oWord:Invoke( "Quit",0)
       ::oTexto     := NIL
       ::oActiveDoc := NIL
       ::oDocs      := NIL
       ::oWord      := NIL
       *OleUninitialize()
       return nil


METHOD EndPage() CLASS TWord
       return nil


METHOD FillRect( aRect, oBrush ) CLASS TWord
       LOCAL oShapes,oShapBox, oFill, oFillColor
       if ::lsetcm
          arect[1] := arect[1]*28.35
          arect[2] := arect[2]*28.35
          arect[3] := arect[3]*28.35
          arect[4] := arect[4]*28.35
       endif

       oShapes     := ::oSelection:Get( "Shapes" )
       oShapBox    := oShapes:Invoke(  "AddShape",1,arect[2],arect[1],arect[4]-arect[2],aRect[3]-arect[1] )
       oCuadro:Set( 'RelativeHorizontalPosition',1)
       oCuadro:Set( 'RelativeVerticalPosition',1)
       oFill       := oShapBox:Get( "Fill")
       oFillColor  := oFill:Get( "ForeColor")
       oFillColor:Set( "RGB",oBrush:nRGBColor )
       oBrush:End()

       release oFillColor,oFill,oShapBox,oShapes
       return nil


METHOD GetTextHeight( oFont ) CLASS TWord
       local sal
       if ::lsetcm
          sal := oFont:nHeight/28.35
       else
          sal := oFont:nHeight
       endif
       return sal


METHOD GetTextWidth(cText, oFont) CLASS TWord
       local nancho
       if oFont:nHeight > 0
          nancho := (oFont:nHeight/1.6)*len(ctext)
       else
          nancho :=((oFont:nHeight*-1)/1.6)*len(ctext)
       endif
       return nancho

METHOD JustificaDoc( nJustify, otext ) CLASS TWord
         LOCAL oParagraph
     DEFAULT oText := ::oTexto
       oParagraph   := oText:Get("ParagraphFormat")
       oParagraph:Set( "Alignment", nJustify )
       RELEASE oParagraph
       RETURN ( Nil )

METHOD Line( nTop, nLeft, nBottom, nRight, oPen, nColor, nStyle ) CLASS TWord
       local oShapes,oShapLinea, oLinea, oRGB
       if ::lsetcm
          nTop := nTop*28.35
          nLeft := nLeft*28.35
          nBottom := nBottom*28.35
          nRight := nRight*28.35
       endif
       if oPen = NIL
          DEFINE PEN oPen
          if nStyle = Nil
             nStyle := 1
          endif
          if nColor = Nil
             nColor := nRGB(0,0,0)
          endif
       else
          if nStyle = Nil
             do case
                case oPen:nStyle = 0
                     nStyle := 1
                case oPen:nStyle = 1
                     nStyle := 4
                case oPen:nStyle = 2
                     nstyle := 2
                case oPen:nStyle = 3
                     nstyle := 5
                case oPen:nStyle = 4
                     nstyle := 6
             endcase
          endif
          if nColor = Nil
             nColor := oPen:nColor
          endif
       endif

       oShapes     := ::oSelection:Get( "Shapes" )
       oShapLinea  := oShapes:Invoke( "AddLine", nLeft,nTop,nRight,nBottom )
       oShapLinea:Set( 'RelativeHorizontalPosition',1)
       oShapLinea:Set( 'RelativeVerticalPosition',1)
       oLinea      := oShapLinea:Get( "Line" )
*       oLinea:Set( "Weight", oPen:nWidth-2 ) // No anda OK
       oRGB := oLinea:Get( 'ForeColor')
       oRGB:Set('RGB', nColor )
       oLinea:Set( "DashStyle", nStyle)
        oPen:End()
       release oLinea,oShapLinea,oShapes, oRGB

       return nil


METHOD   NEW()  CLASS TWord
   ::oWord := TOleAuto():New("Word.Application")
   /*
      ::lWord  := .T.
      TRY
        ::oWord := GetActiveObject( "Word.Application" )
      CATCH
         TRY
            ::oWord := CreateObject( "Word.Application" )
         CATCH
            Alert( "ERROR! Word not avialable. [" + Ole2TxtError()+ "]" )
            ::lWord  := .T.
            RETURN( Self )
         END
      END
   */
RETURN( Self )


METHOD NewDoc( cNombreDoc )  CLASS TWord
       DEFAULT cNombreDoc := 'Documento1'
       ::oDocs       := ::oWord:Get( "Documents")
       ::oDocs:Invoke( "Add" )
     ::oActiveDoc    := ::oWord:Get("ActiveDocument")
       ::oTexto        := ::oWord:Get("Selection")
       ::oOptions      := ::oWord:Get("Options")              // Vikthor
       ::oTables        := ::oActiveDoc:Get( "Tables")              // Vikthor
       ::oMailMerge    := ::oActiveDoc:Get( "MailMerge")    // Vikthor
       ::cNombreDoc    := cNombreDoc
       ::nLinea        := 0
       ::nCol          := 0
       ::nPage         := 0
       ::nYoffset      := 0
       ::nXoffset      := 0
       ::lstartpag     := .t.
       ::oSelection    := ::oActiveDoc
       ::lSetcm        := .f.
       ::lOverflowing  := .f.
       ::nlastrow      := 0
       ::ctextoverflow := ''

       return nil


*METHOD nLogPixelX()
*       return 55.38

*METHOD nLogPixelY()
*       return 55.38

METHOD OpenDoc( cNombreDoc )  CLASS TWord
       local sal := .t.
       ::oDocs := ::oWord:Get( "Documents" )
       if file( cNombreDoc )
          ::oActiveDoc  := ::oDocs:Invoke( "Open",cNombreDoc )
          if valtype(::oActiveDoc) <> 'O'
             sal := .f.
          endif
       else
          sal := .f.
       endif
       ::oTexto        := ::oWord:Get( "Selection" )
       ::oOptions      := ::oWord:Get("Options")              // Vikthor
       ::oMailMerge    := ::oActiveDoc:Get( "MailMerge")    // Vikthor
       ::oTables       := ::oActiveDoc:Get( "Tables")              // Vikthor
       ::cNombreDoc    := cNombreDoc
       ::nLinea        := 0
       ::nCol          := 0
       ::nPage         := 0
       ::nYoffset      := 0
       ::nXoffset      := 0
       ::oSelection    := ::oActiveDoc
       ::lstartpag     := .t.
       ::lsetcm        := .f.
       ::lOverflowing  := .f.
       ::nlastrow      := 0
       ::ctextoverflow := ''

       return sal

METHOD Preview() CLASS TWord
       ::oWord:Set( "PrintPreview", .F.)
       ::oActiveDoc:Invoke(  "PrintPreview")
       ::Visualizar()
       return nil


METHOD PrintDoc(lbackground, lappend, nRange, cOutputFile, nfrom, nto, nitem, ncopias, cpages) CLASS TWord
       local csinpath, cpath
       DEFAULT lbackground := .f., lappend := .f., nRange := 0, cOutputFile := '',;
               nfrom := '', nto := '' ,;
               nitem := 0, ncopias := 1, cpages := ''
       if !empty(nFrom) .or. !empty(nTo)
          nRange := 3
          nFrom := alltrim(str(int(nFrom)))
          nTo   := alltrim(str(int(nTo)))
       endif
       if empty(cOutputFile)
          ::oActiveDoc:Invoke(  "PrintOut" , lbackground,lappend,int(nRange),'',nfrom, nto, nitem,ncopias, cpages )
       else
          cpath := cFilePath(cOutputFile)
          if !empty(cpath) .and. cpath <>'\'
             ::oWord:Invoke( 'ChangeFileOpenDirectory',cpath)
          endif
          csinpath := cFileNoPath(cOutputFile)
          ::oWord:Invoke( "PrintOut",lbackground,lappend,int(nRange),csinpath, nfrom, nto, nitem, ncopias, cpages )
       endif
       return nil


METHOD Protect(cpassword,nmodo) CLASS TWord
       DEFAULT nmodo := 1
       ::oActiveDoc:Invoke( "Protect", nmodo, .F., cpassword )
       return nil


METHOD Replace( cOld, cNew ) CLASS TWord
       LOCAL oTexto, oFind, oReplace

       //::oSelection    := ::oActiveDoc  // Vikthor

       oTexto := ::oSelection:Range()
       oFind  := oTexto:Get( "Find" )

       oFind:Set( "Text", cOld )
       oFind:Set( "Forward", .T. )
       oFind:Set( "Wrap", INT(1) )
       oFind:Set( "Format", .f.            )
       oFind:Set( "MatchCase", .f.         )
       oFind:Set( "MatchWholeWord", .f.    )
       oFind:Set( "MatchWildcards", .f.    )
       oFind:Set( "MatchSoundsLike", .f.   )
       oFind:Set( "MatchAllWordForms", .f. )

       oFind:Invoke( "Execute")

       DO WHILE oFind:Get( "Found" )
          oTexto:Set( "Text", cNew )
          oFind:Invoke( "Execute")
       Enddo
       Release oReplace,oFind,oTexto
       return nil


METHOD Save(cnombredoc) CLASS TWord
       DEFAULT cnombredoc := ::cNombreDoc
       ::oActiveDoc:Invoke( "SaveAs", cNombreDoc )
       return nil

METHOD Say( nLin,nCol,cTexto,oFuente,nSizeHorz,nClrText,nBkMode,nPad, naltura, nClrIndex, lvertadjust ) CLASS TWord
       if oFuente = Nil
       DEFINE FONT oFuente NAME 'Arial' SIZE 0, -12 OF Self
       endif

       DEFAULT nBkMode := 2
       DEFAULT nSizeHorz := ::GetTextWidth(ctexto,oFuente)
       DEFAULT naltura := if(::lsetcm, 1, 28.35)

       if ::lsetcm
          nSizeHorz := nSizeHorz/28.35
       endif

       if nBkMode = 2
          nBkMode = 0
       else
          nBkMode = 1
       endif

       do case
          case  npad = 1
                ncol := ncol - nSizeHorz
                npad := 2
          case npad = 2
                ncol = ncol - (nSizeHorz/2)
                npad := 1
       endcase


     ::TextBox(nLin, nCol, nLin+nAltura, nCol+nSizeHorz, ctexto, oFuente, nClrText, nClrIndex, npad,{,,nPad},{0},lVertAdjust)

       return Nil


METHOD Say2( nLin,nCol,cTexto,oFuente, nSize, lBold, lShadow, nColor ) CLASS TWord
       local cfuente := oFuente:cFaceName
       do whil ::nLinea < nLin
          ::oTexto:Invoke( "TypeText", chr(13) )
          ::nlinea := ::nlinea + 1
       enddo
       ::nCol  := 0
       do whil ::nCol < nCol
          ::oTexto:Invoke( "TypeText", chr(9) )
          ::nCol := ::nCol + 1
       enddo
       ::Write( cTexto, cFuente, nSize, lBold, lShadow, nColor )
       return nil


METHOD SayGTF( nTop,nLeft, cTextFormat, nBottom,nRight ) CLASS TWord
       local cText := "", nPos := 1, nLen := 0, nCrLf, cFormat, cVersion, cType
       local afuentes := {}, nColorText := 0
       local cFacename, cHeight, cWidth, lBold, lItalic, lUnderline, lStrikeout
       local nJustify, nFont
       local oShapes, oCuadro, oFill, oLine, oCuadrotext
       local oFont := ::oTexto:Get( "Font" )
       local aSal := {.f.,''}, lnocabe := .f.

       if ::lsetcm
          nTop := nTop*28.35
          nLeft := nLeft*28.35
          nBottom := nBottom*28.35
          nRight := nRight*28.35
       endif

       nLen := AT( SP_REG, SubStr( cTextFormat, nPos ) )
       cFormat := SubStr( cTextFormat, nPos, nLen - 1 )
       nPos += nLen
       nLen := At( SP_FIELD, SubStr( cTextFormat, nPos ) )
       cVersion := SubStr( cTextFormat, nPos, nLen - 1 )
       nPos += nLen

       if !( cFormat == FORMAT_TEXT_TYPE )
          asal[1] := .f.
          return asal
       endif

       do whil .t.

          if Substr( cTextFormat, npos, 1 ) == SP_FIELD
             nPos += 1
             exit
          endif

          cFacename := Substr( cTextFormat, npos, At( SP_REG, Substr( cTextFormat, nPos ) ) -1 )
          nLen := At( SP_REG, SubStr( cTextFormat, nPos ) )
          nPos += nLen
          cHeight := Substr( cTextFormat, npos, At( SP_REG, Substr( cTextFormat, nPos ) ) -1 )
          nLen := At( SP_REG, SubStr( cTextFormat, nPos ) )
          nPos += nLen

          cWidth := Substr( cTextFormat, npos, At( SP_REG, Substr( cTextFormat, nPos ) ) -1 )
          nLen := At( SP_REG, SubStr( cTextFormat, nPos ) )
          nPos += nLen

          lBold := if(val(Substr( cTextFormat, npos, At( SP_REG, Substr( cTextFormat, nPos ) ) -1 )) = 0, .f.,.t.)
          nLen := At( SP_REG, SubStr( cTextFormat, nPos ) )
          nPos += nLen

          lItalic := if(val(Substr( cTextFormat, npos, At( SP_REG, Substr( cTextFormat, nPos ) ) -1 )) = 0, .f.,.t.)
          nLen := At( SP_REG, SubStr( cTextFormat, nPos ) )
          nPos += nLen

          lUnderline := if(val(Substr( cTextFormat, npos, At( SP_REG, Substr( cTextFormat, nPos ) ) -1 )) = 0, .f.,.t.)
          nLen := At( SP_REG, SubStr( cTextFormat, nPos ) )
          nPos += nLen

          lStrikeOut := if(val(Substr( cTextFormat, npos, At( SP_REG, Substr( cTextFormat, nPos ) ) -1 )) = 0, .f.,.t.)
          nLen := At( SP_REG, SubStr( cTextFormat, nPos ) )
          nPos += nLen

          aadd( afuentes, {cFacename, cHeight, cWidth, lBold, lItalic, lUnderline, lStrikeOut})

       enddo

       oShapes     := ::oSelection:Get( "Shapes" )
       oCuadro     := oShapes:Invoke( "AddTextbox", 1,INT(nLeft),INT(nTop),INT(nRight-nLeft),INT(nBottom-nTop))
       oCuadro:Set( 'RelativeHorizontalPosition',1)
       oCuadro:Set( 'RelativeVerticalPosition',1)
       oFill       := oCuadro:Get( "Fill" )
       oFill:Set( "Transparency",0)
       oFill:Set( "Visible",0)
       oLine       := oCuadro:Get( "Line" )
       oLine:Set( "Transparency",0)
       oLine:Set( "Visible",0)
       oCuadroText := oCuadro:Get( "TextFrame" )
       oText       := oCuadroText:Get( "TextRange" )
       oCuadro:Invoke('Select')


       do while ( cType := SubStr( cTextFormat, nPos, 1 ) ) != SP_FIELD
          if cType == TP_ALIGN .or. cType == TP_FONT .or. cType == TP_COLOR
             if cType == TP_ALIGN
                njustify := Val(Substr( cTextFormat, npos +1, At( SP_REG, Substr( cTextFormat, nPos ) ) -1 ))
                ::Justificadoc(njustify)
             endif
             if cType == TP_FONT
                nfont := val(SubStr( cTextFormat, nPos + 1, nLen -1  ))
                oFont:Set( "Name", afuentes[nfont,1] )
                oFont:Set( "Size", if( val(afuentes[nfont,2]) < 0, val(afuentes[nfont,2])*-1, val(afuentes[nfont,2]) ) )
                oFont:Set( "Bold", afuentes[nfont,4] )
                oFont:Set( "Italic", afuentes[nfont,5] )
                oFont:Set( "Underline", afuentes[nfont,6] )
                oFont:Set( "StrikeThrough", afuentes[nfont,7] )
             endif
             if cType == TP_COLOR
                ncolortext := Val(Substr( cTextFormat, npos +1, At( SP_REG, Substr( cTextFormat, nPos ) ) -1 ))
                oFont:Set(  "Color", ncolortext )
             endif
             nLen := At( SP_REG, SubStr( cTextFormat, nPos ) )
             nPos += nLen
          else
             nLen := At( SP_REG, SubStr( cTextFormat, nPos ) )
             nCrLf := At( CRLF, SubStr( cTextFormat, nPos ) )
             if nLen == 0
                if nCrLf == 0
                   nLen := At( SP_FIELD, SubStr( cTextFormat, nPos ) ) - 1
                else
                   nLen := nCrLf + 1
                endif
             else
                if nCrLf == 0 .or. nCrLf > nLen
                   do while SubStr( ctextformat, nPos + --nLen - 1, 1 ) > Chr( 32 )
                   enddo
                   --nLen
                else
                   nLen := nCRLf + 1
                endif
             endif
             cText = SubStr( cTextFormat, nPos, nLen )

             ::oActiveDoc:Invoke( 'ComputeStatistics',2,.t.)
             lnocabe := oCuadroText:Get( 'Overflowing')
             if lnocabe
                asal[2] := substr( ctextformat,1, 4 )
                asal[2] := asal[2] + substr( ctextformat, 5, At( SP_FIELD, Substr( cTextformat, 5) ))
                asal[2] := asal[2] + substr( ctextformat, nPos + nLen)
                exit
             endif

             cText = SubStr( cTextFormat, nPos, nLen )
             ::oTexto:Invoke(  "Typetext", cText )

             nPos += nLen
          endif
       enddo


       oFont:Invoke( "Reset" )
       release oShapes, oCuadro, oFill, oLine, oCuadrotext, oFont
       return asal


METHOD SetCm() CLASS TWord
       ::lSetCm := .t.
       return


METHOD SetHeader() CLASS TWord
       local oWindow := ::oActiveDoc:Get( "ActiveWindow" )
       local oView   := oWindow:Get(  "View")
       oView:Set( "SeekView" , 10 )         // 9 Header 10 Footer
       ::oSelection := ::oTexto:Get( "HeaderFooter")
       release oWindow, oView
       return nil


METHOD SetLandScape() CLASS TWord
       local oPageSetup := ::oActiveDoc:Get( 'PageSetup')
       oPageSetup:Set( 'Orientation','1')
       release oPageSetup
       return nil

METHOD SetMainDoc() CLASS TWord
       local oWindow := ::oActiveDoc:Get( "ActiveWindow" )
       local oView   := oWindow:Get( "View")
       oView:Set( "SeekView" , 0 )
       ::oSelection := ::oActiveDoc
       release oWindow, oView
       return nil


METHOD SetPortrait() CLASS TWord
       local oPageSetup := ::oActiveDoc:Get( 'PageSetup')
       oPageSetup:Set( 'Orientation','0')
       release oPageSetup
       return nil


METHOD SetUl() CLASS TWord
       ::lSetCm := .f.
       return


METHOD StartPage() CLASS TWord
       if ::lstartpag = .t.
          ::lstartpag := .f.
       else
          ::oTexto:Invoke( "EndKey" , 6 , 0 )
          ::oTexto:Invoke( "InsertBreak" )
          ::oTexto:Invoke( "GotoNext" , 1 )
          ::nPage++
          ::nLinea:=0
          ::nCol  :=0
       endif
       ::Write(chr(31))  //Es necesario para ponder vincular los cuadros de texto a una pagina determinada.
       return nil


METHOD TabClearAll(ocuadrotext) CLASS TWord
       local oparagraphformat, otabstop
       DEFAULT ocuadrotext := ::oTexto
       oParagraphformat := oCuadroText:Get( 'ParagraphFormat')
       oTabstop := oParagraphformat:Get( 'TabStops')
       oTabstop:Invoke('ClearAll')
       release oparagraphformat, otabstop
       return nil


METHOD TabPredeterminado(ncada) CLASS TWord
       if ::lsetcm
          ncada := ncada*28.35
       endif
       ::oActiveDoc:Set( 'DefaultTabStop', ncada )
       return nil


METHOD TextBox( nTop, nLeft, nBottom, nRight, cTexto, oFuente, nclrtext, nClrBack, nJustify, afondo, alinea, lvertadjust, norientacion) CLASS TWord
       local oShapes,oCuadro,oFill,oLinea, oFontC, oText, oCuadroText
       local nPad := 0, n, oWrap, nheighttext,;
             lnocabe := .f.,  nheightbox:= 0

       DEFAULT nTop := 0, nLeft := 0, nBottom := 10, nRight := 10,;
               cTexto := ' ', oFuente := TFont():New(),;
               nClrText := nRGB(0,0,0), nJustify := 0,;
               afondo := {}, alinea := {}, lvertadjust := .f.,;
               norientacion := 1

       nheighttext := oFuente:nHeight

       if norientacion > 3
          norientacion := 1
       endif
       do case
          case nJustify = 1
               nPad := 2
          case nJustify = 2
               nPad := 1
          case nJustify = 6
               nPad := 0
       endcase
       if ::lsetcm
          nTop := nTop*28.35
          nLeft := nLeft*28.35
          nBottom := nBottom*28.35
          nRight := nRight*28.35
       endif

       oShapes     := ::oSelection:Get( "Shapes" )
       oCuadro     := oShapes:Invoke( "AddTextbox", norientacion,INT(nLeft),INT(nTop),INT(nRight-nLeft),INT(nBottom-nTop) )
       oFill       := oCuadro:Get( "Fill" )

       oCuadro:Set( 'RelativeHorizontalPosition',1)
       oCuadro:Set( 'RelativeVerticalPosition',1)

       //Fill
       for n = 1 to len(afondo)
           do case
              case n = 1 .and. afondo[n] <> NIL
                   oFillColor  := oFill:Get( "ForeColor")
                   oFillColor:Set( 'RGB', afondo[1] )
              case n = 2 .and. afondo[n] <> NIL
                   oFillColor  := oFill:Get( "BackColor")
                   oFillColor:Set( 'RGB', afondo[2] )
              case n = 3 .and. afondo[n] <> NIL
                   oFill:Set( 'Transparency', afondo[3])
              case n = 4 .and. afondo[n] <> NIL
                   oFill:Invoke( 'TwoColorGradient', afondo[4], afondo[5] )
              case n = 6 .and. afondo[n] <> NIL
                   oFill:Invoke( 'Patterned', afondo[6] )
              case n = 7 .and. afondo[n] <> NIL
                   oFill:Invoke(  'PresetTextured', afondo[7] )
              case n = 8 .and. afondo[n] <> NIL
                   oFill:Invoke(  'UserTextured' , afondo[8] )
           endcase
       next n

       //Linea de contorno
       oLinea      := oCuadro:Get(  "Line" )

       for n = 1 to len(alinea)
           do case
              case n = 1
                   oLinea:Set( "Weight", alinea[1] )
              case n = 2
                   oLinea:Set(  "ForeColor", alinea[2] )
              case n = 3
                   oLinea:Set(  "BackColor", alinea[3] )
              case n = 4
                   oLinea:Set(  "Transparency", alinea[4])
              case n = 5
                   oLinea:Set(  "DashStyle", alinea[5] )
              case n = 5
                   oLinea:Set(  "Style", alineas[6] )
           endcase
       next n


       oCuadroText := oCuadro:Get( "TextFrame" )
       oText       := oCuadroText:Get( "TextRange" )
       oFontC      := oText:Get( "Font")
       oFontC:Set( "Name"  , oFuente:cFaceName )
       oFontC:Set( "Size"  , INT(oFuente:nHeight)  )
       oFontC:Set( "Bold"  , oFuente:lBold     )
       oFontC:Set( "Color" , nclrtext )
       oText:Set(  'HighlightColorIndex', nClrBack )
       oText:Set(  "Text", cTexto )
       oParagraph  := oText:Get( "ParagraphFormat")
     oParagraph:Set( "Alignment", nPad )


       if lvertadjust
          nheightbox := 0
          oCuadro:Set( 'Height', nheightbox)
          ::oActiveDoc:Invoke( 'ComputeStatistics',2,.t.)
          lnocabe := oCuadroText:Get( 'Overflowing')
          nheightbox := nheightbox + nHeighttext //+ OleGetProperty(oParagraph,'SpaceBefore')
          do whil lnocabe = .t. .and. nheightbox <= nBottom - nTop
             oCuadro:Set( 'Height', nheightbox)
             oText:Set( "Text", cTexto )
             ::oActiveDoc:Invoke( 'ComputeStatistics',2,.t.)
             lnocabe := oCuadroText:Get( 'Overflowing')
             nheightbox := nheightbox + nHeighttext //+ OleGetProperty(oParagraph,'SpaceBefore')
          enddo

       else
          ::oActiveDoc:Invoke( 'ComputeStatistics',2,.t.)
          lnocabe := oCuadroText:Get( 'Overflowing')
          nheightbox := nBottom
       endif

       lcorta := lnocabe
       ctexto2 := ctexto
       do whil lcorta .and. !empty(ctexto2)
          ctexto2 := Dellastword(ctexto2)
          oText:Set( 'Text', ctexto2)
          ::oActiveDoc:Invoke('ComputeStatistics',2,.t.)
          lcorta := oCuadroText:Get( 'Overflowing')
       enddo

       ::ctextoverflow := strtran(ctexto, ctexto2, '')
       ::loverflowing := lnocabe
       ::oLastSay := otext

       release oParagraph, OLinea, oFillColor, oFill, oFontC, oText,oCuadroText, oCuadro

       if ::lsetcm
             ::nlastrow := nBottom/28.35
       else
             ::nlastrow := nBottom
       endif

       return Nil


METHOD UnProtect(cpassword) CLASS TWord
       ::oActiveDoc:Invoke( "UnProtect", cpassword )
       return nil


METHOD VistaCompleta() CLASS TWord
       LOCAL oWindow, oView

       oWindow := ::oActiveDoc:Get( "ActiveWindow" )
       oView   := oWindow:Get( "View" )
       oView:Set( "FullScreen", .T. )
       ::Visualizar()
       release oView
       return nil


METHOD Write( cTexto, cFuente, nSize, lBold, lShadow, nColor ) CLASS TWord

       LOCAL oFont := ::oTexto:Get("Font")
       oFont:Set( "Name", cFuente )
       oFont:Set( "Size", nSize )
       oFont:Set( "Bold", lBold )
       oFont:Set( "Emboss", lShadow )
       oFont:Set( "Color", nColor )

       ::oTexto:Invoke( "TypeText", cTexto )
       oFont:Invoke( "Reset" )

       RELEASE oFont

RETURN( Nil )

static function dellastword(ctexto)
sal := rtrim(ctexto)
do whil !empty(sal)
   sal := substr(sal,1, len(sal)-1)
   if substr(sal, len(sal), 1) = chr(32) .or. substr(sal, len(sal), 1) = chr(13)
      exit
   endif
enddo
return sal


METHOD SendMail( lAttach  ) CLASS TWord    // [ Vikthor ]
   DEFAULT lAttach := .T.
   ::oOptions:Set(   "SendMailAttach" , lAttach )
   ::oActiveDoc:Invoke( "SendMail" )

RETURN Self

METHOD HeaderFooter( nOption ) CLASS TWord     // Vikthor

   /*
     wdSeekCurrentPageFooter   10
   wdSeekCurrentPageHeader    9
   wdSeekEndnotes             8
   wdSeekEvenPagesFooter      6
   wdSeekEvenPagesHeader      3
   wdSeekFirstPageFooter      5
   wdSeekFirstPageHeader      2
   wdSeekFootnotes            7
   wdSeekMainDocument         0
   wdSeekPrimaryFooter        4
   wdSeekPrimaryHeader        1
   */
       LOCAL oWindow := ::oActiveDoc:Get( "ActiveWindow" )
       LOCAL oView   := oWindow:Get( "View" )
       DEFAULT nOption := 9
       oView:Set( "SeekView", nOption )
       IF( nOption == 0 , ;
           ::oSelection := ::oActiveDoc , ;                 // Graba los datos al Documento
          ::oSelection := ::oTexto:Get( "HeaderFooter") )  // Abre el metodo para escritura
       release oWindow, oView
RETURN( Nil )

METHOD OpenDataSource( cFile ) CLASS TWord     // Vikthor
       LOCAL oDField
       LOCAL cText, nItem , i , oRange
       DEFAULT cFile := "file.xls"
       ::oMailMerge:Invoke( 'OpenDataSource' , cFile , 0 , .F. )
       ::oDataSource := ::oMailMerge:Get("DataSource")   // Regresa el Objeto MailMergeDataSource
       ::oDataFields := ::oDataSource:Get("DataFields")  // Regresa el Objeto MailMergeDataFields
       ::oFields     := ::oMailMerge:Get("Fields")       // Regresa el Objeto MailMergeFields
/*
       cText := "Hay "
       nItem := ::oDataFields:Count()    // Devuelve cuantos campos hay
       cText += Ltrim(Str( nItem )) + " campos para combinar correspondecia "+ CRLF + CRLF
       FOR i := 1 TO nItem
           oDField := ::oDataFields:Item( i ) // Regresa el Objeto MailMergeDataField
           cText += Str( i ) + ".-"+ oDField:Name() + CRLF
       NEXT
       ::Write( chr(13)+chr(13)+ cText  )
*/
RETURN( Nil )

METHOD AddField( cField , cFuente, nSize, lBold, lShadow, nColor ) CLASS TWord     // Vikthor
       LOCAL oRange := ::oSelection:Range()
       LOCAL nEnd := oRange:Get("End")
       LOCAL oFont
       oRange:SetRange( nEnd , nEnd )

       oFont  := oRange:Get("Font")
       DEFAULT cFuente := "Tahoma" ,;
               nSize   := 10       ,;
               lBold   := .F.      ,;
               lShadow := .F.      ,;
               nColor  := 0

       oFont:Set( "Name", cFuente )
       oFont:Set( "Size", nSize )
       oFont:Set( "Bold", lBold )
       oFont:Set( "Emboss", lShadow )
       oFont:Set( "Color", nColor )

       ::oFields:Invoke("Add", oRange , cField )

       oFont:Invoke( "Reset" )
       RELEASE oFont , oRange

RETURN( Nil )

METHOD AddTables( aDatos , nEnd ) CLASS TWord     // Vikthor
      LOCAL oRange := ::oSelection:Range()
      // LOCAL nEnd := oRange:Get("End")
      LOCAL oTable , oCell , oCellRange , oCells
      LOCAL nRows , nCols
      LOCAL x , y
      nRows:=Len( aDatos )
      nCols:=Len( aDatos[1] )
      oRange:SetRange( nEnd , nEnd )
      oTable:= ::oTables:Invoke("Add", oRange ,  nRows , nCols )
      FOR x := 1 TO nRows
          FOR y := 1 TO nCols
              oCell := oTable:Cell( x , y)
              oCellRange := oCell:Range()
              oCellRange:Invoke( 'InsertAfter' , aDatos[x,y] )
              SysRefresh()
          NEXT
      NEXT
      oColumns:=oTable:Columns:Select()
      oSelection:= ::oWord:Get("Selection")
      oFont:=oSelection:Font()
      oFont:Name:='Tahoma'
      oFont:Size:=9
      oColumns:=oTable:Columns:AutoFit()

      oCol:=oTable:Columns:Item(3)
      oCol:Select()
      oSelection:= ::oWord:Get("Selection")
      oFont:=oSelection:Font()
      oFont:Name:='Tahoma'
      oFont:Size:=9
      FOR x := 1 TO nCols  // Len( aDatos )
          oCol:=oTable:Columns:Item(x)
          oCol:Select()
          oParagraph := oSelection:Get("ParagraphFormat")
          oParagraph:Set( "Alignment", 2 )
          SysRefresh()
      NEXT
      oTable:AutoFormat(1)
RETURN( Nil )

METHOD Find( cText ) CLASS TWord
       LOCAL oTexto, oFind, nEnd
       oTexto := ::oSelection:Range()
       oFind  := oTexto:Get( "Find" )
       oFind:Set( "Text", cText )
       oFind:Set( "Forward", .T. )
       oFind:Set( "Wrap", INT(1) )
       oFind:Set( "Format", .f.            )
       oFind:Set( "MatchCase", .f.         )
       oFind:Set( "MatchWholeWord", .f.    )
       oFind:Set( "MatchWildcards", .f.    )
       oFind:Set( "MatchSoundsLike", .f.   )
       oFind:Set( "MatchAllWordForms", .f. )
       oFind:Invoke( "Execute")
       DO WHILE oFind:Get( "Found" )
          oTexto:Set( "Text", "" )
          oFind:Invoke( "Execute")
       Enddo
       nEnd := oTexto:Get("End")
       Release oTexto , oFind
RETURN( nEnd )

