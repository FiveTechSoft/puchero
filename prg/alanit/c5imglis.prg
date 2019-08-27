#include "fivewin.ch"

#define SRCCOPY 13369376

#define STRETCH_ANDSCANS        1
#define STRETCH_ORSCANS         2
#define STRETCH_DELETESCANS     3

CLASS TC5ImgList

   DATA aBmps
   DATA nColorMask

   DATA hBmpMem

   DATA nWSize, nHSize
   DATA lGrayScale

   METHOD New     ( lGrayScale, nColorMask )  CONSTRUCTOR
   METHOD FromFile( cFileName, nItems, lGrayScale, nColorMask ) CONSTRUCTOR
   METHOD Add     ( cBmp, lIcon )
   METHOD Draw    ( hDC, nImage, nTop, nLeft, lDisable )
   METHOD DrawAlign( hDC, nImage, aRect, lDisable, nAlign )
   METHOD GetCount()       INLINE Len( ::aBmps )
   METHOD END     ()       INLINE if( ::hBmpMem != nil, DeleteObject( ::hBmpMem ), ), ::hBmpMem := 0
   METHOD nWidth ( nItem ) INLINE ::aBmps[ nItem, 2 ]
   METHOD nHeight( nItem ) INLINE ::aBmps[ nItem, 3 ]
   METHOD GetBitmap( nItem, nWidth, nHeight )
   METHOD ToFile( nItem, cBmpFile, nWidth, nHeight )
   METHOD ImgList( nImage )

ENDCLASS

//---------------------------------------------------------------------------------------------------
METHOD New( lGrayScale, nColorMask ) CLASS TC5ImgList

   //---------------------------------------------------------------------------------------------------

   IF lGrayScale == nil; lGrayScale := .F. ; ENDIF
   IF nColorMask == nil; nColorMask := rgb( 255, 0, 255 ); ENDIF

   ::aBmps  := {}
   ::lGrayScale := lGrayScale
   ::nColorMask := nColorMask

RETURN self

//---------------------------------------------------------------------------------------------------
METHOD FromFile( cImage, nItems, lGrayScale, nColorMask ) CLASS TC5ImgList

   //---------------------------------------------------------------------------------------------------
   LOCAL nW, nH
   LOCAL hBmp
   LOCAL n

   IF nItems == nil; nItems := 1 ; ENDIF
   IF lGrayScale == nil; lGrayScale := .F. ; ENDIF
   IF nColorMask == nil; nColorMask := rgb( 255, 0, 255 ); ENDIF

   ::aBmps      := {}
   ::lGrayScale := lGrayScale
   ::nColorMask := nColorMask

   IF ValType( cImage ) == "N"
      ::hBmpMem  := LoadBitmap( GetResources(), cImage )
   ELSE
      IF "." $ cImage
         ::hBmpMem  := ReadBitmap( 0, cImage )
      ELSE
         ::hBmpMem  := LoadBitmap( GetResources(), cImage )
      ENDIF
   ENDIF

   if ::lGrayScale
      hBmp := BmpToGray( ::hBmpMem )
      DeleteObject( ::hBmpMem )
      ::hBmpMem := hBmp
   ENDIF

   nW := BmpWidth ( ::hBmpMem )
   nH := BmpHeight( ::hBmpMem )

   ::nWSize := nW / nItems
   ::nHSize := nH

   FOR n := 1 TO nItems
      AAdd( ::aBmps, { "", ::nWSize, ::nHSize } )
   NEXT

RETURN self


//---------------------------------------------------------------------------------------------------
METHOD Add( cImage, lIcon ) CLASS TC5ImgList

   //---------------------------------------------------------------------------------------------------

   LOCAL nEn := 0

   LOCAL hDC, hDCMem, hDCMem2
   LOCAL hBmp, hOldBmp, hOldBmp2
   LOCAL hBmpMemNew
   LOCAL hBmpMem
   LOCAL nW, nH
   LOCAL aRect
   LOCAL lCreando := .F.
   LOCAL hBmpConvert

   DEFAULT lIcon  := ".ICO" $ Upper( cImage )

   IF Empty( cImage )
      RETURN 0
   ENDIF

   IF Len( ::aBmps ) > 0
      nEn := AScan( ::aBmps, {| x| x[ 1 ] == cImage } )
   ENDIF


   IF nEn > 0
      RETURN nEn
   ENDIF

   IF lIcon
      IF "." $ cImage
         hBmp := ExtractIcon( cImage )
      ELSE
         hBmp := LoadIcon( GetResources(), cImage )
      ENDIF
      nH := 32
      nW := 32
   ELSE
      IF ValType( cImage ) == "N"
         hBmp  := LoadBitmap( GetResources(), cImage )
      ELSE
         IF "." $ cImage
            hBmp  := ReadBitmap( 0, cImage )
         ELSE
            hBmp  := LoadBitmap( GetResources(), cImage )
         ENDIF
      ENDIF
      nW := BmpWidth ( hBmp )
      nH := BmpHeight( hBmp )
   ENDIF

   IF Len( ::aBmps ) == 0
      ::nWSize := nW
      ::nHSize := nH
      DEFAULT ::nWSize := 32
      DEFAULT ::nHSize := 32
   ENDIF



   IF hBmp != 0

      AAdd( ::aBmps, { cImage, nW, nH } )

      hDC     := CreateDC( "DISPLAY", 0, 0, 0 )

#ifdef __HARBOUR__
      hDCMem  := CreateCompatibleDC( hDC )
      hDCMem2 := CreateCompatibleDC( hDC )
#else
#ifdef __C3__
      hDCMem  := CreateCompatibleDC( hDC )
      hDCMem2 := CreateCompatibleDC( hDC )
#else
      hDCMem  := CompatDC( hDC )
      hDCMem2 := CompatDC( hDC )
#endif
#endif

      aRect   := { 0, 0, ::nHSize, ::nWSize * Len( ::aBmps ) }

      if ::hBmpMem == nil

         lCreando := .T.

#ifdef __HARBOUR__
         ::hBmpMem := CreateCompatibleBitmap( hDC, ::nWSize, ::nHSize )
#else
#ifdef __C3__
         ::hBmpMem := CreateCompatibleBitmap( hDC, ::nWSize, ::nHSize )
#else
         ::hBmpMem := CompatBmp( hDC, ::nWSize, ::nHSize )
#endif
#endif

         hOldBmp   := SelectObject( hDCMem, ::hBmpMem )
#ifdef __HARBOUR__
         FillSolidRect( hDCMem, { 0, 0, ::nHSize, ::nWSize }, RGB( 255,0,255 ) ) // bug 08-07-2004 ,RGB( 255,0,255) )
#else
#ifdef __C3__
         FillSolidRect( hDCMem, { 0, 0, ::nHSize, ::nWSize }, RGB( 255,0,255 ) ) // bug 08-07-2004 ,RGB( 255,0,255) )
#else
         FillSoliRc( hDCMem, { 0, 0, ::nHSize, ::nWSize }, RGB( 255,0,255 ) ) // bug 08-07-2004 ,RGB( 255,0,255) )
#endif
#endif

         if ::lGrayScale
            IF lIcon
               hBmpConvert := IconToGray( hBmp )
            ELSE
               hBmpConvert := BmpToGray( hBmp )
            ENDIF
            DrawMasked( hDCMem, hBmpConvert, 0, 0 )
            DeleteObject( hBmpConvert )
         ELSE
            IF lIcon
               DrawIcon( hDCMem, 0, 0, hBmp )
            ELSE
               DrawMasked( hDCMem, hBmp, 0, 0 )
            ENDIF
         ENDIF

         SelectObject ( hDCMem, hOldBmp )

         DeleteDC     ( hDCMem  )
         DeleteDC     ( hDCMem2 )
         DeleteDC     ( hDC     )

      ELSE

#ifdef __HARBOUR__
         hBmpMemNew := CreateCompatibleBitmap( hDC, aRect[ 4 ], ::nHSize )
#else
#ifdef __C3__
         hBmpMemNew := CreateCompatibleBitmap( hDC, aRect[ 4 ], ::nHSize )
#else
         hBmpMemNew := CompatBmp( hDC, aRect[ 4 ], ::nHSize )
#endif
#endif

         hOldBmp    := SelectObject( hDCMem, hBmpMemNew )
#ifdef __HARBOUR__
         FillSolidRect( hDCMem, aRect, RGB( 255,0,255 ) )                   // bug 08-07-2004 ,RGB( 255,0,255) )
#else
#ifdef __C3__
         FillSolidRect( hDCMem, aRect, RGB( 255,0,255 ) )                   // bug 08-07-2004 ,RGB( 255,0,255) )
#else
         FillSoliRc( hDCMem, aRect, RGB( 255,0,255 ) )                   // bug 08-07-2004 ,RGB( 255,0,255) )
#endif
#endif

         hOldBmp2 := SelectObject( hDCMem2, ::hBmpMem )
         BitBlt( hDCMem, 0, 0, aRect[ 4 ] -::nWSize, ::nHSize, hDCMem2, 0, 0, SRCCOPY )

         SelectObject( hDCMem2, hOldBmp2 )
         DeleteObject( ::hBmpMem )

         if ::lGrayScale
            IF lIcon
               hBmpConvert := IconToGray( hBmp )
            ELSE
               hBmpConvert := BmpToGray( hBmp )
            ENDIF
            DrawMasked( hDCMem, hBmpConvert, 0, aRect[ 4 ] -::nWSize )
            DeleteObject( hBmpConvert )
         ELSE
            IF lIcon
               DrawIcon( hDCMem, 0, aRect[ 4 ] -::nWSize, hBmp )
            ELSE
               DrawMasked( hDCMem, hBmp, 0, aRect[ 4 ] -::nWSize )
            ENDIF
         ENDIF
         SelectObject( hDCMem,  hOldBmp  )

         ::hBmpMem := hBmpMemNew

         DeleteDC( hDCMem )
         DeleteDC( hDCMem2 )
         DeleteDC( hDC )

      ENDIF

      nEn := Len( ::aBmps )

      DeleteObject( hBmp )

   ELSE
      nEn := 0
   ENDIF

RETURN nEn


//---------------------------------------------------------------------------------------------------
METHOD DrawAlign( hDC, nImage, aRect, lDisable, nAlign ) CLASS TC5ImgList

   //---------------------------------------------------------------------------------------------------
   LOCAL nTop, nLeft, nWidth, nHeight

   nTop    := aRect[ 1 ]
   nLeft   := aRect[ 2 ]
   nWidth  := aRect[ 4 ] -aRect[ 2 ]
   nHeight := aRect[ 3 ] -aRect[ 1 ]

/*
 nAlign            1   2   3
                   4   5   6
                   7   8   9
*/

   DO CASE
   CASE nAlign == 1

   CASE nAlign == 2

      nLeft := nLeft + ( nWidth / 2 ) - ( ::nWidth( nImage ) / 2 )

   CASE nAlign == 3

      nLeft := nLeft + nWidth - ::nWidth( nImage )

   CASE nAlign == 4

      nTop := nTop + ( nHeight / 2 ) - ( ::nHeight( nImage ) / 2 )

   CASE nAlign == 5

      nTop := nTop +  ( nHeight / 2 ) - ( ::nHeight( nImage ) / 2 )
      nLeft := nLeft + nWidth - ::nWidth( nImage )

   CASE nAlign == 6

      nTop := nTop   + ( nHeight / 2 ) - ( ::nHeight( nImage ) / 2 )
      nLeft := nLeft + nWidth  - ::nWidth( nImage )

   CASE nAlign == 7

      nTop := nTop + nHeight - ::nHeight( nImage )

   CASE nAlign == 8

      nTop := nTop + nHeight - ::nHeight( nImage )
      nLeft := nLeft + ( nWidth / 2 ) - ( ::nWidth( nImage ) / 2 )

   CASE nAlign == 9

      nTop := nTop + nHeight - ::nHeight( nImage )
      nLeft := nLeft + nWidth - ::nWidth( nImage )

   ENDCASE

   ::Draw( hDC, nImage, nTop, nLeft, lDisable )

RETURN NIL


//---------------------------------------------------------------------------------------------------
METHOD Draw( hDC, nImage, nTop, nLeft, lDisable, nWidth, nHeight ) CLASS TC5ImgList

   //---------------------------------------------------------------------------------------------------

   LOCAL hDCMem, hOldBmp, hOldBmp2
   LOCAL hDC0     := CreateDC( "DISPLAY", 0, 0, 0 )
   LOCAL hBmp
   LOCAL hDCMem2
   LOCAL iOldMode

   DEFAULT lDisable := .F.
   DEFAULT nWidth   := ::aBmps[ nImage, 2 ]
   DEFAULT nHeight  := ::aBmps[ nImage, 3 ]


#ifdef __HARBOUR__
   hBmp     := CreateCompatibleBitmap( hDC0, nWidth, nHeight )
#else
#ifdef __C3__
   hBmp     := CreateCompatibleBitmap( hDC0, nWidth, nHeight )
#else
   hBmp     := CompatBmp( hDC0, nWidth, nHeight )
#endif
#endif

#ifdef __HARBOUR__
   hDCMem   := CreateCompatibleDC( hDC0 )
#else
#ifdef __C3__
   hDCMem   := CreateCompatibleDC( hDC0 )
#else
   hDCMem   := CompatDC( hDC0 )
#endif
#endif

   hOldBmp  := SelectObject( hDCMem, ::hBmpMem )

#ifdef __HARBOUR__
   hDCMem2  := CreateCompatibleDC( hDC0 )
#else
#ifdef __C3__
   hDCMem2  := CreateCompatibleDC( hDC0 )
#else
   hDCMem2  := CompatDC( hDC0 )
#endif
#endif

   hOldBmp2 := SelectObject( hDCMem2, hBmp )
   iOldMode = SetStretchBltMode( hDCMem2, STRETCH_DELETESCANS )

   StretchBlt( hDCMem2, 0, 0, nWidth, nHeight, hDCMem, ::nWSize * ( nImage - 1 ), 0, ::aBmps[ nImage, 2 ], ::aBmps[ nImage, 3 ], SRCCOPY )

   SetStretchBltMode( hDCMem2, iOldMode )

   SelectObject( hDCMem,  hOldBmp )
   SelectObject( hDCMem2, hOldBmp2 )

   DeleteDC( hDCMem  )
   DeleteDC( hDCMem2 )
   DeleteDC( hDC0    )


   IF lDisable
#ifdef __HARBOUR__
      DrawState( hDC, nil, hBmp, nLeft, nTop, nWidth, nHeight, nOr( 4, 32 ) )
#else
#ifdef __C3__
      DrawState( hDC, nil, hBmp, nLeft, nTop, nWidth, nHeight, nOr( 4, 32 ) )
#else
      DrawMasked( hDC, hBmp, nTop, nLeft )
      DisableRec( hDC, { nTop, nLeft, nTop + nWidth, nLeft + nHeight } )
#endif
#endif
   ELSE
      DrawMasked( hDC, hBmp, nTop, nLeft )
   ENDIF

   DeleteObject( hBmp )

RETURN NIL

//********************************************************************************
METHOD GetBitmap( nItem, nWidth, nHeight ) CLASS TC5ImgList

   //********************************************************************************
   LOCAL hDCMem, hOldBmp, hOldBmp2
   LOCAL hDC0     := CreateDC( "DISPLAY", 0, 0, 0 )
   LOCAL hBmp

   DEFAULT nWidth := ::nWidth( nItem ), nHeight := ::nHeight( nItem )

#ifdef __HARBOUR__
   hBmp     := CreateCompatibleBitmap( hDC0, nWidth, nHeight )
#else
#ifdef __C3__
   hBmp     := CreateCompatibleBitmap( hDC0, nWidth, nHeight )
#else
   hBmp     := CompatBmp( hDC0, nWidth, nHeight )
#endif
#endif

#ifdef __HARBOUR__
   hDCMem   := CreateCompatibleDC( hDC0 )
#else
#ifdef __C3__
   hDCMem   := CreateCompatibleDC( hDC0 )
#else
   hDCMem   := CompatDC( hDC0 )
#endif
#endif

   hOldBmp  := SelectObject( hDCMem, hBmp )

   FillSolidRect( hDCMem, { 0, 0, nWidth, nHeight }, ::nColorMask )

   ::Draw( hDCMem, nItem, 0, 0, .F., nWidth, nHeight )

   SelectObject( hDCMem,  hOldBmp )

   DeleteDC( hDCMem  )
   DeleteDC( hDC0    )

RETURN hBmp

//********************************************************************************
METHOD ToFile( nItem, cBmpFile, nWidth, nHeight ) CLASS TC5ImgList

   //********************************************************************************

   LOCAL hBitmap := ::GetBitmap( nItem, nWidth, nHeight )

   DibWrite( cBmpFile, DibFromBitmap( hBitmap ) )

   DeleteObject( hBitmap )

RETURN NIL

//********************************************************************************
METHOD ImgList( nImage ) CLASS TC5ImgList

   //********************************************************************************

   LOCAL hImageList
   LOCAL flags
   LOCAL hBitmap := ::GetBitmap( nImage )
   LOCAL nColores := Colores()

   IF nColores > 65536
      flags := 24
   ELSEIF nColores == 32768 .OR. nColores == 65536
      flags := 16
   ELSEIF nColores == 256
      flags := 8
   ELSE
      flags := 4
   ENDIF

   hImageList := ImageList_Create( ::nWSize, ::nHSize, nOr( flags,1 ), 1 )
   ImageList_Add( hImageList, hBitmap )
   ImageList_AddMasked( hImageList, hBitmap, ::nColorMask )

   DeleteObject( hBitmap )

RETURN hImageList
