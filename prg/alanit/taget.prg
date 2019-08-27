#include "FiveWin.ch"

class TAGet
	data aAut	// autor
	data lAut   // recargar el autor
	data aPub 	// publicación
	data lPub   // recargar cliente
	data aGru	// grupos de ingredientes
	data lGru	// recargar grupos
	data aPro	// proveedores
	data lPro	// recargar proveedores
	data aVal	// valoraciones
	data lVal	// recargar valoraciones
	data aFra	// clasificación francesa
	data lFra	// recargar francesa
	data lPla	// recargar tipos de platos
	data aPl1	// tipos de entradas
	data aPl2	// tipos de primeros platos
	data aPl3	// tipos de segundos platos
	data aPl4	// tipos de postres
	data aPl5	// tipos de dulces
	data aPl6	// tipos de cocinado
	data lIng	// ingredientes de escandallo
	data aIng	// recargar ingredientes
	data lIPr	// ingrediente principal
	data aIPr
	data lDie	// dietas
	data aDie
	data lUb
	data aUb
	data lAc
	data aAc

	method New() constructor
	method Load()
EndClass

method New() Class TAGet
	::aAut 	:= {}
	::lAut 	:= .t.
	::aPub 	:= {}
	::lPub 	:= .t.
	::aGru 	:= {}
	::lGru 	:= .t.
	::aPro	:= {}
	::lPro	:= .t.
	::aVal	:= {}
	::lVal	:= .t.
	::aFra	:= {}
	::lFra	:= .t.
	::aPl1	:= {}
	::aPl2	:= {}
	::aPl3	:= {}
	::aPl4	:= {}
	::aPl5	:= {}
	::aPl6	:= {}
	::lPla	:= .t.
	::aIng	:= {}
	::lIng	:= .t.
	::aIPr	:= {}
	::lIPr	:= .t.
	::aDie	:= {}
	::lDie	:= .t.
	::aUb    := {}
	::lUb  	:= .t.
	::aAc 	:= {}
	::lAc		:= .t.
return self

method Load()
	local aAuxArray := {}
	local nAuxOrder
	local nAuxRecno
	local nArea    := Select()

	if ::lAut
		// cargo las actividades
		aSize(aAuxArray, 0)
		Select AU
		nAuxOrder := AU->(OrdNumber())
		nAuxRecno := AU->(Recno())
		AU->( dbSetOrder( 1 ) )
		AU->( dbGoTop() )
		Do While ! AU->(Eof())
			Aadd(aAuxArray, AU->AuNombre)
			AU->(DbSkip())
		Enddo
		aSort(aAuxArray)
		aSize( oAGet():aAut, Len(aAuxArray))
		ACopy( aAuxArray, oAGet():aAut )
		AU->(DbSetOrder(nAuxOrder))
		AU->(DbGoTo(nAuxRecno))
		::lAut := .f.
	endif

	if ::lPub
		// cargo las publicaciones
		aSize(aAuxArray, 0)
		Select PU
		nAuxOrder := PU->(OrdNumber())
		nAuxRecno := PU->(Recno())
		PU->( dbSetOrder( 1 ) )
		PU->( dbGoTop() )
		Do While ! PU->(Eof())
			Aadd(aAuxArray, PU->PuNombre)
			PU->(DbSkip())
		Enddo
		aSort(aAuxArray)
		aSize( oAGet():aPub, Len(aAuxArray))
		ACopy( aAuxArray, oAGet():aPub )
		PU->(DbSetOrder(nAuxOrder))
		PU->(DbGoTo(nAuxRecno))
		::lPub := .f.
	endif
	if ::lGru
		// cargo los grupos de alimentos
		aSize(aAuxArray, 0)
		Select GR
		nAuxOrder := GR->(OrdNumber())
		nAuxRecno := GR->(Recno())
		GR->( dbSetOrder( 1 ) )
		GR->( dbGoTop() )
		Do While ! GR->(Eof())
			Aadd(aAuxArray, GR->GrTipo)
			GR->(DbSkip())
		Enddo
		aSort(aAuxArray)
		aSize( oAGet():aGru, Len(aAuxArray))
		ACopy( aAuxArray, oAGet():aGru )
		GR->(DbSetOrder(nAuxOrder))
		GR->(DbGoTo(nAuxRecno))
		::lGru := .f.
	endif
	if ::lPro
		// cargo los grupos de alimentos
		aSize(aAuxArray, 0)
		Select PR
		nAuxOrder := PR->(OrdNumber())
		nAuxRecno := PR->(Recno())
		PR->( dbSetOrder( 1 ) )
		PR->( dbGoTop() )
		Do While ! PR->(Eof())
			Aadd(aAuxArray, PR->PrNombre)
			PR->(DbSkip())
		Enddo
		aSort(aAuxArray)
		aSize( oAGet():aPro, Len(aAuxArray))
		ACopy( aAuxArray, oAGet():aPro )
		PR->(DbSetOrder(nAuxOrder))
		PR->(DbGoTo(nAuxRecno))
		::lPro := .f.
	endif
	if ::lVal
		// cargo las valoraciones
		aSize(aAuxArray, 0)
		Select VA
		nAuxOrder := VA->(OrdNumber())
		nAuxRecno := VA->(Recno())
		VA->( dbSetOrder( 1 ) )
		VA->( dbGoTop() )
		Do While ! VA->(Eof())
			Aadd(aAuxArray, VA->VaValorac)
			VA->(DbSkip())
		Enddo
		aSort(aAuxArray)
		aSize( oAGet():aVal, Len(aAuxArray))
		ACopy( aAuxArray, oAGet():aVal )
		VA->(DbSetOrder(nAuxOrder))
		VA->(DbGoTo(nAuxRecno))
		::lVal := .f.
	endif
	if ::lFra
		// cargo la clas. francesa
		aSize(aAuxArray, 0)
		Select FR
		nAuxOrder := FR->(OrdNumber())
		nAuxRecno := FR->(Recno())
		FR->( dbSetOrder( 1 ) )
		FR->( dbGoTop() )
		Do While ! FR->(Eof())
			Aadd(aAuxArray, FR->FrTipo)
			FR->(DbSkip())
		Enddo
		aSort(aAuxArray)
		aSize( oAGet():aFra, Len(aAuxArray))
		ACopy( aAuxArray, oAGet():aFra )
		FR->(DbSetOrder(nAuxOrder))
		FR->(DbGoTo(nAuxRecno))
		::lFra := .f.
	endif
	if ::lPla
		// cargo los tipos de entradas
		aSize(aAuxArray, 0)
		Select PL
		nAuxOrder := PL->(OrdNumber())
		nAuxRecno := PL->(Recno())
		PL->( dbSetOrder( 2 ) )
		PL->( dbGoTop() )
		Do While ! PL->(Eof())
			Aadd(aAuxArray, PL->PlTipo)
			PL->(DbSkip())
		Enddo
		aSort(aAuxArray)
		aSize( oAGet():aPl1, Len(aAuxArray))
		ACopy( aAuxArray, oAGet():aPl1 )
		PL->(DbSetOrder(nAuxOrder))
		PL->(DbGoTo(nAuxRecno))
		// cargo los tipos de primeros platos
		aSize(aAuxArray, 0)
		Select PL
		nAuxOrder := PL->(OrdNumber())
		nAuxRecno := PL->(Recno())
		PL->( dbSetOrder( 3 ) )
		PL->( dbGoTop() )
		Do While ! PL->(Eof())
			Aadd(aAuxArray, PL->PlTipo)
			PL->(DbSkip())
		Enddo
		aSort(aAuxArray)
		aSize( oAGet():aPl2, Len(aAuxArray))
		ACopy( aAuxArray, oAGet():aPl2 )
		PL->(DbSetOrder(nAuxOrder))
		PL->(DbGoTo(nAuxRecno))
		// cargo los tipos de segundos platos
		aSize(aAuxArray, 0)
		Select PL
		nAuxOrder := PL->(OrdNumber())
		nAuxRecno := PL->(Recno())
		PL->( dbSetOrder( 4 ) )
		PL->( dbGoTop() )
		Do While ! PL->(Eof())
			Aadd(aAuxArray, PL->PlTipo)
			PL->(DbSkip())
		Enddo
		aSort(aAuxArray)
		aSize( oAGet():aPl3, Len(aAuxArray))
		ACopy( aAuxArray, oAGet():aPl3 )
		PL->(DbSetOrder(nAuxOrder))
		PL->(DbGoTo(nAuxRecno))
		// cargo los tipos de postres
		aSize(aAuxArray, 0)
		Select PL
		nAuxOrder := PL->(OrdNumber())
		nAuxRecno := PL->(Recno())
		PL->( dbSetOrder( 5 ) )
		PL->( dbGoTop() )
		Do While ! PL->(Eof())
			Aadd(aAuxArray, PL->PlTipo)
			PL->(DbSkip())
		Enddo
		aSort(aAuxArray)
		aSize( oAGet():aPl4, Len(aAuxArray))
		ACopy( aAuxArray, oAGet():aPl4 )
		PL->(DbSetOrder(nAuxOrder))
		PL->(DbGoTo(nAuxRecno))
		// cargo los tipos de dulces
		aSize(aAuxArray, 0)
		Select PL
		nAuxOrder := PL->(OrdNumber())
		nAuxRecno := PL->(Recno())
		PL->( dbSetOrder( 6 ) )
		PL->( dbGoTop() )
		Do While ! PL->(Eof())
			Aadd(aAuxArray, PL->PlTipo)
			PL->(DbSkip())
		Enddo
		aSort(aAuxArray)
		aSize( oAGet():aPl5, Len(aAuxArray))
		ACopy( aAuxArray, oAGet():aPl5 )
		PL->(DbSetOrder(nAuxOrder))
		PL->(DbGoTo(nAuxRecno))
		// cargo los tipos de cocinado
		aSize(aAuxArray, 0)
		Select PL
		nAuxOrder := PL->(OrdNumber())
		nAuxRecno := PL->(Recno())
		PL->( dbSetOrder( 7 ) )
		PL->( dbGoTop() )
		Do While ! PL->(Eof())
			Aadd(aAuxArray, PL->PlTipo)
			PL->(DbSkip())
		Enddo
		aSort(aAuxArray)
		aSize( oAGet():aPl6, Len(aAuxArray))
		ACopy( aAuxArray, oAGet():aPl6 )
		PL->(DbSetOrder(nAuxOrder))
		PL->(DbGoTo(nAuxRecno))
		::lPla := .f.
	endif
	if ::lIng
		// cargo los ingredientes
		aSize(aAuxArray, 0)
		Select AL
		nAuxOrder := AL->(OrdNumber())
		nAuxRecno := AL->(Recno())
		AL->( dbSetOrder( 1 ) )
		AL->( dbGoTop() )
		Do While ! AL->(Eof())
			Aadd(aAuxArray, AL->AlCodigo)
			AL->(DbSkip())
		Enddo
		aSort(aAuxArray)
		aSize( oAGet():aIng, Len(aAuxArray))
		ACopy( aAuxArray, oAGet():aIng )
		AL->(DbSetOrder(nAuxOrder))
		AL->(DbGoTo(nAuxRecno))
		::lIng := .f.
	endif
	if ::lIPr
		// cargo los ingredientes principales
		aSize(aAuxArray, 0)
		Select IP
		nAuxOrder := IP->(OrdNumber())
		nAuxRecno := IP->(Recno())
		IP->( dbSetOrder( 1 ) )
		IP->( dbGoTop() )
		Do While ! IP->(Eof())
			Aadd(aAuxArray, IP->IpIngred)
			IP->(DbSkip())
		Enddo
		aSort(aAuxArray)
		aSize( oAGet():aIPr, Len(aAuxArray))
		ACopy( aAuxArray, oAGet():aIPr )
		IP->(DbSetOrder(nAuxOrder))
		IP->(DbGoTo(nAuxRecno))
		::lIPr := .f.
	endif
	if ::lDie
		// cargo las dietas
		aSize(aAuxArray, 0)
		Select DI
		nAuxOrder := DI->(OrdNumber())
		nAuxRecno := DI->(Recno())
		DI->( dbSetOrder( 1 ) )
		DI->( dbGoTop() )
		Do While ! DI->(Eof())
			Aadd(aAuxArray, DI->DiDieta)
			DI->(DbSkip())
		Enddo
		aSort(aAuxArray)
		aSize( oAGet():aDie, Len(aAuxArray))
		ACopy( aAuxArray, oAGet():aDie )
		DI->(DbSetOrder(nAuxOrder))
		DI->(DbGoTo(nAuxRecno))
		::lDie := .f.
	endif
	if ::lUb
		// cargo las ubicaciones
		aSize(aAuxArray, 0)
		Select UB
		nAuxOrder := UB->(OrdNumber())
		nAuxRecno := UB->(Recno())
		UB->( dbSetOrder( 1 ) )
		UB->( dbGoTop() )
		Do While ! UB->(Eof())
			Aadd(aAuxArray, UB->UbUbicaci)
			UB->(DbSkip())
		Enddo
		aSort(aAuxArray)
		aSize( oAGet():aUb, Len(aAuxArray))
		ACopy( aAuxArray, oAGet():aUb )
		UB->(DbSetOrder(nAuxOrder))
		UB->(DbGoTo(nAuxRecno))
		::lUb := .f.
	endif
	if ::lAc .and. oApp():lBcnKitchen
		// cargo las ubicaciones
		aSize(aAuxArray, 0)
		Select AC
		nAuxOrder := AC->(OrdNumber())
		nAuxRecno := AC->(Recno())
		AC->( dbSetOrder( 1 ) )
		AC->( dbGoTop() )
		Do While ! AC->(Eof())
			Aadd(aAuxArray, AC->AcAccion)
			AC->(DbSkip())
		Enddo
		aSort(aAuxArray)
		aSize( oAGet():aAc, Len(aAuxArray))
		ACopy( aAuxArray, oAGet():aAc )
		AC->(DbSetOrder(nAuxOrder))
		AC->(DbGoTo(nAuxRecno))
		::lAc := .f.
	endif
   Select (nArea)
return nil



