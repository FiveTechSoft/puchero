**
* PROYECTO ...: Cuaderno de Bitácora
* COPYRIGHT ..: (c) alanit software
* URL ........: www.alanit.com
**

#include "Fivewin.ch"

CLASS TZoomImage FROM TImage

	CLASSDATA lRegistered AS LOGICAL // dice Paco que hace falta

	METHOD Paint()

ENDCLASS

/*_____________________________________________________________________________*/

METHOD Paint() CLASS TZoomImage

	// jaime 17.10.04
	local nWBmp   := nBmpWidth( ::hBitmap )
	local nHBmp   := nBmpHeight( ::hBitmap )
	local aRect   := GetClientRect( ::hWnd )
	local nWidth  := aRect[4] - aRect[2]
	local nHeight := aRect[3] - aRect[1]
	// fin jaime

   if Empty( ::hBitmap ) .and. ! Empty( ::cBmpFile )
      ::LoadBmp( ::cBmpFile )
   endif

   if Empty( ::hBitmap )
      if ::bPainted != nil
         Eval( ::bPainted, ::hDC )
      endif
      return nil
   endif

	// __ jaime 17.10.04 ______________
   If ::lStretch
       PALBMPDraw( ::hDC, ::nX, ::nY, ::hBitmap, ::hPalette,;
                   nWidth, nHeight,, ::lTransparent, ::nClrPane ) // (nClrPane) Added by RRR 23/04/01 07:58
   else
       if ::nZoom > 0
       	if nHBmp > nHeight .OR. nWBmp > nWidth
	         // si es más alta que ancha (o son iguales)
       		if nHBmp >= nWBmp
       			nWBmp := ( nWBmp * nHeight ) / nHBmp
       			nHBmp := nHeight
       			// si el lado contrario ha quedado más grande, reajusto
       			if nWBmp > nWidth
       				nHBmp := ( nHBmp * nWidth ) / nWBmp
       				nWBmp := nWidth
       			endif
       			PALBMPDraw( ::hDC, ::nX, ::nY, ::hBitmap, ::hPalette,;
            	         	nWBmp, nHBmp,, ::lTransparent, ::nClrPane )        // (nClrPane) Added by RRR 23/04/01 07:58
	         // si es más ancha que alta
         	else
       			nHBmp := ( nHBmp * nWidth ) / nWBmp
       			nWBmp := nWidth
       			// si el lado contrario ha quedado más grande, reajusto
       			if nHBmp > nHeight
       				nWBmp := ( nWBmp * nHeight ) / nHBmp
       				nHBmp := nHeight
       			endif
       			PALBMPDraw( ::hDC, ::nX, ::nY, ::hBitmap, ::hPalette,;
            		         nWBmp, nHBmp,, ::lTransparent, ::nClrPane )        // (nClrPane) Added by RRR 23/04/01 07:58
            endif
         else
       		PALBMPDraw( ::hDC, ::nX, ::nY, ::hBitmap, ::hPalette,;
           	         	nWBmp, nHBmp,, ::lTransparent, ::nClrPane )        // (nClrPane) Added by RRR 23/04/01 07:58
         endif
       endif
   endif
/*
   If ::lStretch
       PALBMPDraw( ::hDC, ::nX, ::nY, ::hBitmap, ::hPalette,;
                   nWidth, nHeight,, ::lTransparent, ::nClrPane ) // (nClrPane) Added by RRR 23/04/01 07:58
   else
       if ::nZoom > 0
       	if nHBmp > nHeight
       		PALBMPDraw( ::hDC, ::nX, ::nY, ::hBitmap, ::hPalette,;
            	         ( nWBmp * nHeight ) / nHBmp, nHeight,, ::lTransparent, ::nClrPane )        // (nClrPane) Added by RRR 23/04/01 07:58
         elseif nWBmp > nWidth
       		PALBMPDraw( ::hDC, ::nX, ::nY, ::hBitmap, ::hPalette,;
            	         nWidth, ( nHBmp * nWidth ) / nWBmp,, ::lTransparent, ::nClrPane )        // (nClrPane) Added by RRR 23/04/01 07:58
         else
       		PALBMPDraw( ::hDC, ::nX, ::nY, ::hBitmap, ::hPalette,;
            	         nWBmp, nHBmp,, ::lTransparent, ::nClrPane )        // (nClrPane) Added by RRR 23/04/01 07:58
         endif
       endif
   endif
*/
	// __ fin jaime ___________________

/* // __ código original de fwh ______
   If ::lStretch
       PALBMPDraw( ::hDC, ::nX, ::nY, ::hBitmap, ::hPalette,;
                   Super:nWidth(), Super:nHeight(),, ::lTransparent, ::nClrPane ) // (nClrPane) Added by RRR 23/04/01 07:58
   else
       if ::nZoom > 0
          PALBMPDraw( ::hDC, ::nX, ::nY, ::hBitmap, ::hPalette,;
                      ::nWidth(), ::nHeight(),, ::lTransparent, ::nClrPane )        // (nClrPane) Added by RRR 23/04/01 07:58
       endif
   endif
*/

   if ::bPainted != nil
      Eval( ::bPainted, ::hDC )
   endif

return nil
