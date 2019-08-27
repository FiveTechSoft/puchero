#Borland make sample, (c) FiveTech Software 2005-2009

HBDIR=c:\Fivetech\hb64
BCDIR=c:\bcc7264
FWDIR=C:\Fivetech\FWH170164

#change these paths as needed
.path.OBJ = .\obj
.path.PRG = .\prg
.path.CH  = $(FWDIR)\include;$(HBDIR)\include
.path.C   = .\
.path.rc  = .\

#important: Use Uppercase for filenames extensions, in the next rules!

PRG = \
		MAIN.PRG 	\
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

  $(BCDIR)\bin\ilink64 -Gn -aa -Tpe -s @pch170164.bc
 
.PRG.OBJ:
  $(HBDIR)\bin\harbour $< /L /N /W /Oobj\ /I$(FWDIR)\include;$(HBDIR)\include
  $(BCDIR)\bin\bcc64 -c -tWM -I$(HBDIR)\include -I$(BCDIR)\include\windows\sdk -I$(BCDIR)\include\windows\crtl -oobj\$&.obj obj\$&.c
  del tmp

.C.OBJ:
  echo -c -tWM -D__HARBOUR__ -DHB_API_MACROS > tmp
  echo -I$(HBDIR)\include;$(FWDIR)\include >> tmp
  $(BCDIR)\bin\bcc64 -I$(BCDIR)\include\windows\sdk -I$(BCDIR)\include\windows\crtl -oobj\$& @tmp $&.c
  del tmp

puchero.res : puchero.rc
  $(BCDIR)\bin\brc32.exe -r -D__64__ -I%bcdir%\include -I%bcdir%\include\windows\sdk puchero.rc
