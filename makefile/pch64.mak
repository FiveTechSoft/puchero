#Borland make 64 bits (c) FiveTech Software 2016

HBDIR=c:\fivetech\hb64
BCDIR=c:\bcc\bcc7264
FWDIR=c:\fivetech\fwh170164

#change these paths as needed
.path.obj = .\obj
.path.prg = .\prg
.path.ch  = $(FWDIR)\include;$(HBDIR)\include
.path.c   = .\
.path.rc  = .\res

PRG = MAIN.PRG 	\
		PACCION.PRG		\
		PALIMENT.PRG 	\
		PAUTOR.PRG 		\
		PDIETAS.PRG		\
		PESCANDA.PRG 	\
		PFRANCES.PRG 	\
		PGRUPOS.PRG 	\
		PINGREDI.PRG 	\
		PMENUS.PRG 	 	\
		PMENUSEM.PRG 	\
		PPLATOS.PRG 	\
		PPROVEED.PRG 	\
		PPUBLICA.PRG 	\
		PRECETAS.PRG 	\
		PUBICACI.PRG	\
		PVALORAC.PRG	\
		C5BMP.PRG	  	\
		C5IMGLIS.PRG  	\
		C5TIP.PRG 	  	\
		C5VITEM.PRG	  	\
		C5VMENU.PRG	  	\
		ERRSYSW.PRG	  	\
		REPORT1406.PRG 	\
		RPREVIEW1406.PRG\
		RTFFILE.PRG		\
		TABS.PRG 		\
		TAGET.PRG		\
		TAGEVER2.PRG	\
		TAUTOGET.PRG	\
		TFSDI.PRG 		\
		TINFORME.PRG	\
		TIPS.PRG 		\
		TSAYREF.PRG 	\
		TZOOMIMAGE.PRG  \
		UT_BRW.PRG		\
		UT_CALEND.PRG	\
		UT_COMMON.PRG	\
		UT_DBF.PRG		\
		UT_INDEX.PRG 	\
		ZIPBACKUP.PRG	

PROJECT    : puchero.exe

puchero.exe  : $(PRG:.prg=.obj) $(C:.c=.obj) puchero.res
   echo off
   echo $(BCDIR)\lib\c0w64.o + > b64.bc
  	echo .\OBJ\MAIN.OBJ 	+ > b64.bc 
	echo .\OBJ\PACCION.OBJ	+ > b64.bc
	echo .\OBJ\PALIMENT.OBJ+ > b64.bc
	echo .\OBJ\PAUTOR.OBJ 	+ > b64.bc
	echo .\OBJ\PDIETAS.OBJ	+ > b64.bc
	echo .\OBJ\PESCANDA.OBJ+ > b64.bc
	echo .\OBJ\PFRANCES.OBJ+ > b64.bc
	echo .\OBJ\PGRUPOS.OBJ + > b64.bc
	echo .\OBJ\PINGREDI.OBJ+ > b64.bc
	echo .\OBJ\PMENUS.OBJ  + > b64.bc
	echo .\OBJ\PMENUSEM.OBJ+ > b64.bc
	echo .\OBJ\PPLATOS.OBJ + > b64.bc
	echo .\OBJ\PPROVEED.OBJ+ > b64.bc
	echo .\OBJ\PPUBLICA.OBJ+ > b64.bc
	echo .\OBJ\PRECETAS.OBJ+ > b64.bc
	echo .\OBJ\PUBICACI.OBJ+ > b64.bc
	echo .\OBJ\PVALORAC.OBJ+ > b64.bc
	echo .\OBJ\C5BMP.OBJ	  + > b64.bc
	echo .\OBJ\C5IMGLIS.OBJ+ > b64.bc
	echo .\OBJ\C5TIP.OBJ   + > b64.bc
	echo .\OBJ\C5VITEM.OBJ + > b64.bc
	echo .\OBJ\C5VMENU.OBJ + > b64.bc
	echo .\OBJ\ERRSYSW.OBJ + > b64.bc
	echo .\OBJ\REPORT1406.OBJ+  > b64.bc
	echo .\OBJ\RPREVIEW1406.OBJ+  > b64.bc
	echo .\OBJ\RTFFILE.OBJ + > b64.bc
	echo .\OBJ\TABS.OBJ 	  + > b64.bc
	echo .\OBJ\TAGET.OBJ	  + > b64.bc
	echo .\OBJ\TAGEVER2.OBJ+ > b64.bc
	echo .\OBJ\TAUTOGET.OBJ+ > b64.bc
	echo .\OBJ\TFSDI.OBJ   + > b64.bc
	echo .\OBJ\TINFORME.OBJ+ > b64.bc
	echo .\OBJ\TIPS.OBJ 	  + > b64.bc
	echo .\OBJ\TSAYREF.OBJ + > b64.bc
	echo .\OBJ\TZOOMIMAGE.OBJ+ > b64.bc
	echo .\OBJ\UT_BRW.OBJ  + > b64.bc
	echo .\OBJ\UT_CALEND.OBJ+ > b64.bc 
	echo .\OBJ\UT_COMMON.OBJ+ > b64.bc
	echo .\OBJ\UT_DBF.OBJ  + > b64.bc
	echo .\OBJ\UT_INDEX.OBJ+ > b64.bc
	echo .\OBJ\ZIPBACKUP.OBJ,+ > b64.bc	
   echo puchero.exe, +  >> b64.bc
   echo puchero.map, +  >> b64.bc
   echo $(FWDIR)\lib\Five64.a $(FWDIR)\lib\FiveC64.a + >> b64.bc
   echo $(HBDIR)\lib\hbrtl.a + >> b64.bc
   echo $(HBDIR)\lib\hbvm.a + >> b64.bc
   echo $(HBDIR)\lib\gtgui.a + >> b64.bc
   echo $(HBDIR)\lib\hblang.a + >> b64.bc
   echo $(HBDIR)\lib\hbmacro.a + >> b64.bc
   echo $(HBDIR)\lib\hbrdd.a + >> b64.bc
   echo $(HBDIR)\lib\rddntx.a + >> b64.bc
   echo $(HBDIR)\lib\rddcdx.a + >> b64.bc
   echo $(HBDIR)\lib\rddfpt.a + >> b64.bc
   echo $(HBDIR)\lib\hbsix.a + >> b64.bc
   echo $(HBDIR)\lib\hbdebug.a + >> b64.bc
   echo $(HBDIR)\lib\hbcommon.a + >> b64.bc
   echo $(HBDIR)\lib\hbpp.a + >> b64.bc
   echo $(HBDIR)\lib\hbwin.a + >> b64.bc
   echo $(HBDIR)\lib\hbcpage.a + >> b64.bc
   echo $(HBDIR)\lib\hbct.a + >> b64.bc
   echo $(HBDIR)\lib\hbcplr.a + >> b64.bc
   echo $(HBDIR)\lib\hbpcre.a + >> b64.bc
   echo $(HBDIR)\lib\xhb.a + >> b64.bc
   echo $(HBDIR)\lib\hbziparc.a + >> b64.bc
   echo $(HBDIR)\lib\hbmzip.a + >> b64.bc
   echo $(HBDIR)\lib\hbzlib.a + >> b64.bc
   echo $(HBDIR)\lib\minizip.a + >> b64.bc
   echo $(HBDIR)\lib\png.a + >> b64.bc
   echo $(HBDIR)\lib\hbusrrdd.a + >> b64.bc
   echo $(HBDIR)\lib\hbtip.a + >> b64.bc

   echo $(BCDIR)\lib\cw64.a + >> b64.bc
   echo $(BCDIR)\lib\psdk\kernel32.a + >> b64.bc
   echo $(BCDIR)\lib\psdk\user32.a + >> b64.bc
   echo $(BCDIR)\lib\psdk\iphlpapi.a + >> b64bc
   echo $(BCDIR)\lib\import64.a, >> b64.bc

   IF EXIST puchero.res echo puchero.res >> b64.bc
   $(BCDIR)\bin\ilink64 -Gn -aa -Tpe -s @b64.bc
   if ERRORLEVEL 0 puchero .exe
   del b64.bc

.PRG.OBJ:
  $(HBDIR)\bin\harbour $< /L /N /W /Oobj\ /I$(FWDIR)\include;$(HBDIR)\include
  $(BCDIR)\bin\bcc64 -c -tWM -I$(HBDIR)\include -I$(BCDIR)\include\windows\sdk -I$(BCDIR)\include\windows\crtl -oobj\$&.obj obj\$&.c

.C.OBJ:
  echo -c -tWM -D__HARBOUR__ -DHB_API_MACROS > tmp
  echo -I$(HBDIR)\include;$(FWDIR)\include >> tmp
  $(BCDIR)\bin\bcc64 -I$(BCDIR)\include\windows\sdk -I$(BCDIR)\include\windows\crtl -oobj\$& @tmp $&.c
  del tmp

puchero.res : puchero.rc
  $(BCDIR)\bin\brc32.exe -r -D__64__ -I%bcdir%\include -I%bcdir%\include\windows\sdk puchero.rc
 