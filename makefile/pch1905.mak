#FWH Borland make, (c) FiveTech Software 2005-2011

HBDIR=c:\fivetech\hb32_bcc7_1905
BCDIR=c:\bcc\bcc7
FWDIR=c:\fivetech\fwh1905

#change these paths as needed
.path.OBJ = .\obj
.path.PRG = .\prg\pch;.\prg\alanit;.\prg\fwh
.path.CH  = $(FWDIR)\include;$(HBDIR)\include
.path.C   = .\
.path.rc  = .\res

#important: Use Uppercase for filenames extensions!

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
		RPREVIEW.PRG	\
		RTFFILE.PRG		\
		TABS.PRG 		\
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
		UT_OVERRIDE.PRG \
		ZIPBACKUP.PRG	

OBJ = $(PRG:.PRG=.OBJ)
OBJS = $(OBJ:.\=.\obj)
PROJECT    : PUCHERO.EXE

PUCHERO.EXE : $(PRG:.PRG=.OBJ) $(C:.C=.OBJ) PUCHERO.RES

  $(BCDIR)\bin\ilink32 -Gn -aa -Tpe -s @.\makefile\pch1905.bc

.PRG.OBJ:
  $(HBDIR)\bin\harbour $< /N /W1 /ES2 /Oobj\ /I$(FWDIR)\include;$(HBDIR)\include;.\ch 
  $(BCDIR)\bin\bcc32 -c -tWM -I$(HBDIR)\include;$(BCDIR)\include -oobj\$& obj\$&.c

.C.OBJ:
  echo -c -tWM -D__HARBOUR__ > tmp
  echo -I$(HBDIR)\include;$(FWDIR)\include >> tmp
  $(BCDIR)\bin\bcc32 -oobj\$& @tmp $&.c
  del tmp
