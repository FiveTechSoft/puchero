#include "FiveWin.ch"
/*
function Main()

   local oWnd, o
   local oFont
   local a := { "Aero"           ,;
                "blog"           ,;
                "boot"           ,;
                "Build"          ,;
                "code"           ,;
                "desktop"        ,;
                "developer"      ,;
                "engineering"    ,;
                "explorer"       ,;
                "feedback"       ,;
                "Hyper-V"        ,;
                "IE 10"          ,;
                "logon"          ,;
                "memory"         ,;
                "Metro"          ,;
                "performance "   ,;
                "security"       ,;
                "standards"      ,;
                "Start"          ,;
                "Task Manager"   ,;
                "team"           ,;
                "touch"          ,;
                "UI"             ,;
                "user experience" ,;
                "Windows Live"    }


   local n

   DEFINE FONT oFont NAME "Segoe UI" SIZE 0,-14
   DEFINE DIALOG oDlg RESOURCE "TagEver" TITLE "TagEver" ;
		FONT oFont

   o := TTagEver():Redefine( 100, oDlg, oFont, a )

   ACTIVATE DIALOG oDlg

return 0


function Main()

   local oWnd, o
   local oFont
   local a := { "Aero"           ,;
                "blog"           ,;
                "boot"           ,;
                "Build"          ,;
                "code"           ,;
                "desktop"        ,;
                "developer"      ,;
                "engineering"    ,;
                "explorer"       ,;
                "feedback"       ,;
                "Hyper-V"        ,;
                "IE 10"          ,;
                "logon"          ,;
                "memory"         ,;
                "Metro"          ,;
                "performance "   ,;
                "security"       ,;
                "standards"      ,;
                "Start"          ,;
                "Task Manager"   ,;
                "team"           ,;
                "touch"          ,;
                "UI"             ,;
                "user experience" ,;
                "Windows Live"    }


   local n

   DEFINE FONT oFont NAME "Segoe UI" SIZE 0,-14

   DEFINE WINDOW oWnd TITLE "Tag Cloud"

   o := TTagEver():New( 10, 10, 300, 100, oWnd, oFont,,, a,,,.t. )




   ACTIVATE WINDOW oWnd

return 0
*/

#include "FiveWin.ch"

CLASS TTagEver FROM TControl

    CLASSDATA lRegistered AS LOGICAL

    DATA aItems
    DATA aFonts
    DATA nClrTextOver
    DATA nClrPaneOver
    DATA nHLine AS NUMERIC INIT 25
    DATA aCoors
    DATA nMaxDescend
    DATA nOver
    DATA nClrBorder
    DATA nClrBackTag
    DATA bAction
    DATA lOverClose
    DATA nOption
    DATA nClrBorder
    DATA lBorder

    METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, oFont, nClrBorder, nClrBackTag, aItems, nClrPane, nClrPaneOver, lBorder ) CONSTRUCTOR
    METHOD Redefine( nId, oWnd, oFont, aItems, nClrBorder, nClrBackTag, nClrPane, nClrPaneOver, lBorder ) CONSTRUCTOR

    METHOD SetItems( aItems )
    METHOD AddItem( cText )

    METHOD Paint()
    METHOD Display() INLINE ::BeginPaint(),::Paint(),::EndPaint(), 0
    METHOD GetItems()
    METHOD Set( nItem, cText ) INLINE ::aItems[nItem,1] := cText
    METHOD Get( nItem )
    METHOD DelItem( nItem ) INLINE ( Adel( ::aItems, nItem ), asize( ::aItems, len(::aItems)-1) )

    METHOD LButtonDown( nRow, nCol, nFlags )
    METHOD MouseMove  ( nRow, nCol, nFlags )
    METHOD LButtonUp  ( nRow, nCol, nFlags )

    METHOD EraseBkGnd( hDC ) INLINE 1


ENDCLASS

************************************************************************************************************************************
  METHOD New( nTop, nLeft, nWidth, nHeight, oWnd, oFont, nClrBorder, nClrBackTag, aItems, nClrPane, nClrPaneOver,;
              lBorder ) CLASS TTagEver
************************************************************************************************************************************

   local nClrText       := rgb(0,102,227)
   local nClrTextOver   := 0 //rgb(255,102,  0)

   DEFAULT nClrPane     := rgb(0,102,227) // CLR_WHITE
   DEFAULT nClrPaneOver := rgb(235,245,226) //rgb(221,221,221)
   DEFAULT nTop         := 0
   DEFAULT nLeft        := 0
   DEFAULT nWidth       := 0
   DEFAULT nHeight      := 0
   DEFAULT nClrBorder   := RGB(122,122,122) // rgb(204,214,197)
   DEFAULT nClrBackTag  := rgb(235,245,226)
   DEFAULT lBorder      := .t.

   // ::nStyle    = nOR( WS_CHILD, WS_VISIBLE, WS_CLIPSIBLINGS, WS_CLIPCHILDREN, WS_TABSTOP, WS_VSCROLL, WS_BORDER )
   ::nStyle    := nOR( WS_CHILD, WS_VISIBLE, WS_BORDER )

   ::SetItems( aItems )

   ::aCoors       := {}

   ::oWnd         := oWnd
   ::nTop         := nTop
   ::nLeft        := nLeft
   ::nBottom      := nTop + nHeight
   ::nRight       := nLeft + nWidth
   ::nId          := ::GetNewId()
   ::lCaptured    := .f.
   ::nClrPane     := nClrPane
   ::nClrText     := nClrText
   ::nClrPaneOver := nClrPaneOver
   ::nClrTextOver := nClrTextOver
   ::SetFont(oApp():oFont) 
   // oFont        := oFont
   ::nOver        := -1
   ::nClrBorder   := nClrBorder
   ::nClrBackTag  := nClrBackTag
   ::lOverClose   := .f.
   ::nOption      := 1
   ::lBorder      := .t. // lBorder jsn

   ::SetColor( nClrText, nClrPane )

   ::lVisible    := .t.

   ::Register( nOR( CS_VREDRAW, CS_HREDRAW ) )
   ::Create()


return Self

************************************************************************************************************************************
  METHOD Redefine( nId, oWnd, oFont, aItems, nClrBorder, nClrBackTag, nClrPane, nClrPaneOver, lBorder ) CLASS TTagEver
************************************************************************************************************************************
	// en caso de no querer resaltar el item cambiar nClrTextOver y nClrPaneOver
   local nClrText       := rgb(  0,102,227)
   local nClrTextOver   := rgb(255,102,  0) // rgb(  0,102,227) para no resaltar
   DEFAULT nClrPane     := CLR_WHITE
   DEFAULT nClrPaneOver := rgb(221,221,221) // rgb(235,245,226) para no resaltar
   DEFAULT nClrBorder   := rgb(204,214,197)
   DEFAULT nClrBackTag  := rgb(235,245,226)
   DEFAULT lBorder      := .f.

   ::SetItems( aItems )

   ::aCoors       := {}

   ::oWnd         := oWnd
   ::nId          := nId
   ::nId          := nId
   ::lCaptured    := .f.
   ::nClrPane     := nClrPane
   ::nClrText     := nClrText
   ::nClrPaneOver := nClrPaneOver
   ::nClrTextOver := nClrTextOver
   ::SetFont(oApp():oFont) 
   // ::oFont        := oFont
   ::nOver        := -1
   ::nClrBorder   := nClrBorder
   ::nClrBackTag  := nClrBackTag
   ::lOverClose   := .f.
   ::nOption      := 1
   ::lBorder      := .t. //lBorder


   ::SetColor( nClrText, nClrPane )

   ::lVisible    := .t.

   ::Register()

   oWnd:DefControl( Self )


return Self


***************************************************************************************************************
    METHOD Get( nItem ) CLASS TTagEver
***************************************************************************************************************

return ::aItems[ nItem ]


***************************************************************************************************************
    METHOD GetItems() CLASS TTagEver
***************************************************************************************************************
local n
local nLen := len(::aItems)
local aItems := {}

for n := 1 to nLen
    if ::aItems[n,2]
       aadd(aItems, ::aItems[n,1] )
    endif
next

return aItems


***************************************************************************************************************
    METHOD SetItems( aItems ) CLASS TTagEver
***************************************************************************************************************

    local n
    local nLen := len(aItems)

    ::aItems := {}

    for n := 1 to nLen
        aadd(::aItems, {aItems[n], .f.,{0,0,0,0}} )
    next

return 0

***************************************************************************************************************
   METHOD AddItem( cText ) CLASS TTagEver
***************************************************************************************************************

   local oItem
   local nLen := len(::aItems)+1

   if ::aItems == nil
      ::aItems := {}
   endif

   AAdd( ::aItems, {cText,.f.,{0,0,0,0}} )

return oItem

***************************************************************************************************************
    METHOD Paint() CLASS TTagEver
***************************************************************************************************************
local aInfo := ::DispBegin()
local n
local nTop  := 3
local nT    := 0
local nL    := 0
local nLeft := 10 // 14
local nSep  := 11
local nH    := ::nHLine
local nLen
local nFont
local nW := 0
local hOldFont
local rc
local nMode := SetBkMode( ::hDC, 1 )
local nColor := SetTextColor(::hDC, ::nClrText )
local hBmp := 0
local nWBmp := 0
local nHBmp := 0
local nT0, nL0, nB0, nR0
local hPen, hOldPen
local hBrush, hOldBrush
local hBrush1, hOldBrush1
local lFirst := .t.

//local nBkColor := SetBkColor(::hDC, CLR_GREEN )

hBmp := LoadBitmap(GetResources(), "16_TAGEVER")

if hBmp != 0
   nWBmp := nBmpWidth( hBmp )
   nHBmp := nBmpHeight( hBmp )
endif

hPen      := CreatePen( PS_SOLID, 1, ::nClrBorder )
hOldPen   := SelectObject(::hDC, hPen )

hBrush    := CreateSolidBrush( ::nClrBackTag )

hBrush1    := CreateSolidBrush( ::nClrPaneOver )

nLen := len( ::aItems )

::aCoors := array(nLen)
for n := 1 to nLen
    ::aCoors[n] :={0,0,0,0}
next


FillSolidRect(::hDC, GetClientRect(::hWnd), ::nClrPane )

nL := nLeft

for n := 1 to nLen

    if ::aItems[n,2] // oculto
       loop
    endif

    //if n == ::nOver
    SetTextColor(::hDC, nColor )
    nColor := SetTextColor(::hDC, if( n == ::nOver .or. n == ::nOption, ::nClrTextOver, ::nClrText) )
    //endif

    if !lFirst
       nL := nL + nW + 10
    endif

    lFirst := .f.

    nW := 5 + GetTextWidth(::hDC, ::aItems[n,1], ::oFont:hFont ) + if( nWBmp != 0 .and. ( n == ::nOver .or. n == ::nOption), 5 + nWBmp + 5, 0)
	 // en caso de que no queramos mostrar la x cuando el item no está seleccionado quitar el +

    if nL + nW + 5 + nWBmp + 5 > ::nWidth
       nTop += ( ::nHLine  ) // +2
       nL := nLeft
    endif

    // nW := 5 + GetTextWidth(::hDC, ::aItems[n,1], ::oFont:hFont ) + if( nWBmp != 0 .and. ( n == ::nOver .or. n == ::nOption), 5 + nWBmp + 5, 0)
	 nW := GetTextWidth(::hDC, ::aItems[n,1], ::oFont:hFont ) + if( nWBmp != 0, 5 + nWBmp + 5, 0)

    nT := nTop

    rc := { nT, nL, nT + nH, nL + nW }

    ::aCoors[n,1] := rc[1]
    ::aCoors[n,2] := rc[2]
    ::aCoors[n,3] := rc[3]
    ::aCoors[n,4] := rc[4]
    //FillSolidRect(::hDC, {nTop+::nHLine-::nMaxDescend,0,nTop+::nHLine-::nMaxDescend+1,::nWidth}, CLR_HBLUE )
    //wqout( rc )

    hOldBrush := SelectObject( ::hDC, if( n == ::nOver .or. n == ::nOption, hBrush1, hBrush ) )

    RoundRect__( ::hDC, rc[2]-6, rc[1], rc[4], rc[3]-3, 6, 6 )

    hOldFont := SelectObject( ::hDC, ::oFont:hFont )

    DrawText(::hDC, ::aItems[n,1], {rc[1],rc[2],rc[3]-2,rc[4]}, 32+4 )

    SelectObject( ::hDC, hOldFont )

    if hBmp != 0 //.and. ( n == ::nOver .or. n == ::nOption) // jsn
       nT0 := rc[1]+((rc[3]-rc[1])/2)-nHBmp/2
       nL0 := rc[4]-5-nWBmp
       nB0 := nT0 + nHBmp
       nR0 := nL0 + nWBmp
       DrawMasked( ::hDC, hBmp, nT0, nL0 )
       ::aItems[n,3] := {nT0,nL0,nB0,nR0}
    else
       ::aItems[n,3] := {0,0,0,0}
    endif

    if n == ::nOver
       SetTextColor(::hDC, nColor )
       nColor := SetTextColor(::hDC, ::nClrText )
    endif

next n

SetBkMode( ::hDC, nMode )
SetTextColor(::hDC, nColor )

if hBmp != 0
   DeleteObject( hBmp )
endif

SelectObject( ::hDC, hOldPen )
SelectObject( ::hDC, hOldBrush )

DeleteObject( hPen )
DeleteObject( hBrush )
DeleteObject( hBrush1 )

if ::lBorder
   rc := GetClientRect(::hWnd)
   Box( ::hDC, {rc[1],rc[2],rc[3]-1,rc[4]-1}, ::nClrBorder )
endif



::DispEnd( aInfo )

return 0

***************************************************************************************************************
    METHOD LButtonDown( nRow, nCol, nFlags ) CLASS TTagEver
***************************************************************************************************************

return 0

***************************************************************************************************************
    METHOD MouseMove  ( nRow, nCol, nFlags ) CLASS TTagEver
***************************************************************************************************************
local nOver := ::nOver
local n
local nLen := len(::aCoors)
local lFind := .f.

for n := 1 to nLen
    if PtInRect( nRow, nCol, ::aCoors[n] )
       lFind := .t.
       ::nOver := n
       if nOver != n
          //::Refresh(.f.)
       endif
       exit
    endif
next

::lOverClose := ::nOver>0 .and. ::nOver<=len(::aItems) .and. PtInRect( nRow, nCol, ::aItems[::nOver,3] )

if lFind
   if ::lOverClose
      CursorHand()
   else
      CursorArrow()
   endif
   if ::oWnd:oMsgBar != nil
      if ::nOver > 0
         ::oWnd:oMsgBar:SetMsg( 'Nube de tags "' + ::aItems[::nOver,1] + '" ' + str(::aItems[::nOver,1]) )
      endif
   endif
else
   ::nOver := -1
   CursorArrow()
endif

if nOver != ::nOver
   ::Refresh(.f.)
endif


return 0

***************************************************************************************************************
    METHOD LButtonUp  ( nRow, nCol, nFlags ) CLASS TTagEver
***************************************************************************************************************

if ::nOver > 0
   if ::lOverClose
      //::aItems[::nOver,2] := .t.
      // ::DelItem(::nOver)
		Adel( ::aItems, ::nOver)
		asize( ::aItems, len(::aItems)-1)
   else
      ::nOption := ::nOver
      if ::bAction != nil
         eval(::bAction, ::nOption, ::aItems[::nOption,1])
      endif
   endif
   ::Refresh()
endif

return 0




#pragma BEGINDUMP
#include "windows.h"
#include "hbapi.h"


HB_FUNC( ROUNDRECT__ ) // hDC, nLeftRect, nTopRect, nRightRect, nBottomRect,
                            // nEllipseWidth, nEllipseHeight, hPen )
{
	 #ifndef _WIN64
	    HDC hDC      = ( HDC ) hb_parnl( 1 );
      HGDIOBJ hObj = ( HGDIOBJ ) hb_parnl( 8 );
   #else
	    HDC hDC      = ( HDC ) hb_parnll( 1 );
      HGDIOBJ hObj = ( HGDIOBJ ) hb_parnll( 8 );
   #endif

   HPEN hOldPen = ( HPEN ) ( hObj ? SelectObject( hDC, hObj ) : 0 );

   BOOL bResult = RoundRect( hDC, hb_parnl( 2 ), hb_parnl( 3 ), hb_parnl( 4 ),
                             hb_parnl( 5 ), hb_parnl( 6 ), hb_parnl( 7 ) );
   if( hOldPen )
      SelectObject( hDC, hOldPen );

   hb_retl( bResult );
}


#pragma ENDDUMP
