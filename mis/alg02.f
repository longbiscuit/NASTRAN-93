      SUBROUTINE ALG02        
C        
      LOGICAL         DEBUG        
      REAL            LOSS,LAMI,LAMIP1,LAMIM1        
      DIMENSION       II(21,30),JJ(21,30),IDATA(24),RDATA(6),NAME(2)    
      COMMON /UD3PRT/ IPRTC        
      COMMON /UDSIGN/ NSIGN        
      COMMON /UPAGE / LIMIT,LQ        
      COMMON /UD300C/ NSTNS,NSTRMS,NMAX,NFORCE,NBL,NCASE,NSPLIT,NREAD,  
     1                NPUNCH,NPAGE,NSET1,NSET2,ISTAG,ICASE,IFAILO,IPASS,
     2                I,IVFAIL,IFFAIL,NMIX,NTRANS,NPLOT,ILOSS,LNCT,ITUB,
     3                IMID,IFAIL,ITER,LOG1,LOG2,LOG3,LOG4,LOG5,LOG6,    
     4                IPRINT,NMANY,NSTPLT,NEQN,NSPEC(30),NWORK(30),     
     5                NLOSS(30),NDATA(30),NTERP(30),NMACH(30),NL1(30),  
     6                NL2(30),NDIMEN(30),IS1(30),IS2(30),IS3(30),       
     7                NEVAL(30),NDIFF(4),NDEL(30),NLITER(30),NM(2),     
     8                NRAD(2),NCURVE(30),NWHICH(30),NOUT1(30),NOUT2(30),
     9                NOUT3(30),NBLADE(30),DM(11,5,2),WFRAC(11,5,2),    
     O                R(21,30),XL(21,30),X(21,30),H(21,30),S(21,30),    
     1                VM(21,30),VW(21,30),TBETA(21,30),DIFF(15,4),      
     2                FDHUB(15,4),FDMID(15,4),FDTIP(15,4),TERAD(5,2),   
     3                DATAC(100),DATA1(100),DATA2(100),DATA3(100),      
     4                DATA4(100),DATA5(100),DATA6(100),DATA7(100),      
     5                DATA8(100),DATA9(100),FLOW(10),SPEED(30),        
     6                SPDFAC(10),BBLOCK(30),BDIST(30),WBLOCK(30),       
     7                WWBL(30),XSTN(150),RSTN(150),DELF(30),DELC(100),  
     8                DELTA(100),TITLE(18),DRDM2(30),RIM1(30),XIM1(30)  
      COMMON /UD300C/ WORK(21),LOSS(21),TANEPS(21),XI(21),VV(21),       
     1                DELW(21),LAMI(21),LAMIM1(21),LAMIP1(21),PHI(21),  
     2                CR(21),GAMA(21),SPPG(21),CPPG(21),HKEEP(21),      
     3                SKEEP(21),VWKEEP(21),DELH(30),DELT(30),VISK,SHAPE,
     4                SCLFAC,EJ,G,TOLNCE,XSCALE,PSCALE,PLOW,RLOW,XMMAX, 
     5                RCONST,FM2,HMIN,C1,PI,CONTR,CONMX        
      EQUIVALENCE     (H(1,1),II(1,1)),(S(1,1),JJ(1,1))        
      DATA    NAME  / 4HALG0, 4H2     /        
C        
      DEBUG = .FALSE.        
      CALL SSWTCH (20,J)        
      IF (J .EQ. 1) DEBUG =.TRUE.        
      NEVAL(1) = 0        
      CALL FREAD (LOG1,TITLE,18,1)        
      IF (IPRTC .EQ. 1) WRITE (LOG2,110) TITLE        
 110  FORMAT (10X,10HINPUT DATA, /10X,10(1H*), //10X,5HTITLE,34X,2H= ,  
     1       18A4)        
      LNCT = LNCT + 4        
      CALL ALG1 (LNCT)        
      CALL FREAD (LOG1,IDATA,21,1)        
      IF (DEBUG) CALL BUG1 ('ALG02   ',111,IDATA,21)        
      NSTNS  = IDATA( 1)        
      NSTRMS = IDATA( 2)        
      NMAX   = IDATA( 3)        
      NFORCE = IDATA( 4)        
      NBL    = IDATA( 5)        
      NCASE  = IDATA( 6)        
      NSPLIT = IDATA( 7)        
      NSET1  = IDATA( 8)        
      NSET2  = IDATA( 9)        
      NREAD  = IDATA(10)        
      NPUNCH = IDATA(11)        
      NPLOT  = IDATA(12)        
      NPAGE  = IDATA(13)        
      NTRANS = IDATA(14)        
      NMIX   = IDATA(15)        
      NMANY  = IDATA(16)        
      NSTPLT = IDATA(17)        
      NEQN   = IDATA(18)        
      NLE    = IDATA(19)        
      NTE    = IDATA(20)        
      NSIGN  = IDATA(21)        
      IF (NSTRMS .EQ. 0) NSTRMS = 11        
      IF (NMAX   .EQ. 0) NMAX   = 40        
      IF (NFORCE .EQ. 0) NFORCE = 10        
      IF (NCASE  .EQ. 0) NCASE  = 1        
      IF (NPAGE  .EQ. 0) NPAGE  = 60        
      LQ    = LOG2        
      LIMIT = NPAGE        
      CALL ALG03 (LNCT,19)        
      IF (IPRTC .EQ. 1) WRITE (LOG2,130) NSTNS,NSTRMS,NMAX,NFORCE,NBL,  
     1       NCASE,NSPLIT,NSET1,NSET2,NREAD,NPUNCH,NPLOT,NPAGE,NTRANS,  
     2       NMIX,NMANY,NSTPLT,NEQN,NLE,NTE,NSIGN        
 130  FORMAT (//10X,'NUMBER OF STATIONS',21X,1H=,I3, /10X,'NUMBER OF ', 
     1       'STREAMLINES',18X,1H=,I3, /10X,20HMAX NUMBER OF PASSES,19X,
     2       1H=,I3, /10X,30HMAX NUMBER OF ARBITRARY PASSES,9X,1H=,I3,  
     3       /10X,29HBOUNDARY LAYER CALC INDICATOR,10X,1H=,I3, /10X,    
     4       24HNUMBER OF RUNNING POINTS,15X,1H=,I3, /10X,        
     5       33HSTREAMLINE DISTRIBUTION INDICATOR,6X,1H=,I3, /10X,      
     6       34HNUMBER OF LOSS/D-FACTOR CURVE SETS,5X,1H=,I3, /10X,     
     7       34HNUMBER OF LOSS/T.E.LOSS CURVE SETS,5X,1H=,I3, /10X,     
     8       26HSTREAMLINE INPUT INDICATOR,13X,1H=,I3, /10X,        
     9       27HSTREAMLINE OUTPUT INDICATOR,12X,1H=,I3, /10X,        
     O       24HPRECISION PLOT INDICATOR,15X,1H=,I3, /10X,        
     1       24HMAX NUMBER OF LINES/PAGE,15X,1H=,I3, /10X,        
     2       29HWAKE TRANSPORT CALC INDICATOR,10X,1H=,I3, /10X,        
     3       32HMAINSTREAM MIXING CALC INDICATOR,7X,1H=,I3, /10X,       
     4       33HNO OF STATIONS FROM ANALYTIC SECN,6X,1H=,I3, /10X,      
     5       27HLINE-PRINTER PLOT INDICATOR,12X,1H=,I3, /10X,        
     6       32HMOMENTUM EQUATION FORM INDICATOR,7X,1H=,I3, /10X,       
     7       30HSTATION NUMBER AT LEADING EDGE,9X,1H=,I3, /10X,        
     8       31HSTATION NUMBER AT TRAILING EDGE,8X,1H=,I3, /10X,        
     9       37HCOMPRESSOR DIR. OF ROTATION INDICATOR,2X,1H=,I3)        
      ITUB = NSTRMS - 1        
      IMID = NSTRMS/2 + 1        
      IF (NMANY .EQ. 0) GO TO 136        
      CALL FREAD (LOG1,NWHICH,NMANY,1)        
      IF (DEBUG) CALL BUG1 ('ALG02   ',132,NWHICH,NMANY)        
      CALL ALG03 (LNCT,2)        
      IF (IPRTC .EQ. 1) WRITE (LOG2,134) (NWHICH(I),I=1,NMANY)        
 134  FORMAT (//10X,'GEOMETRY COMES FROM ANALYTIC SECTION FOR STATIONS',
     1       23I3)        
 136  CALL ALG03 (LNCT,7)        
      CALL FREAD (LOG1,RDATA,6,1)        
      IF (DEBUG) CALL BUG1 ('ALG02   ',136,RDATA,6)        
      G      = RDATA(1)        
      EJ     = RDATA(2)        
      SCLFAC = RDATA(3)        
      TOLNCE = RDATA(4)        
      VISK   = RDATA(5)        
      SHAPE  = RDATA(6)        
      IF (G   .EQ.   0.0) G  = 32.174        
      IF (EJ  .EQ.   0.0) EJ = 778.16        
      IF (SCLFAC .EQ. 0.) SCLFAC = 12.0        
      IF (TOLNCE .EQ. 0.) TOLNCE = 0.001        
      IF (VISK .EQ.  0.0) VISK  = 0.00018        
      IF (SHAPE.EQ.  0.0) SHAPE = 0.7        
      IF (IPRTC .EQ. 1) WRITE (LOG2,150) G,EJ,SCLFAC,TOLNCE,VISK,SHAPE  
 150  FORMAT (//10X,22HGRAVITATIONAL CONSTANT,17X,1H=,F8.4, /10X,       
     1       17HJOULES EQUIVALENT,22X,1H=,F8.3, /10X,        
     2       29HLINEAR DIMENSION SCALE FACTOR,10X,1H=,F8.4, /10X,       
     3       15HBASIC TOLERANCE,24X,1H=,F8.5, /10X,        
     4       19HKINEMATIC VISCOSITY,20X,1H=,F8.5, /10X,        
     5       17HB.L. SHAPE FACTOR,22X,1H=,F8.5)        
      CALL ALG03 (LNCT,7)        
      CALL FREAD (LOG1,RDATA,6,1)        
      IF (DEBUG) CALL BUG1 ('ALG02   ',151,RDATA,6)        
      XSCALE = RDATA(1)        
      PSCALE = RDATA(2)        
      RLOW   = RDATA(3)        
      PLOW   = RDATA(4)        
      XMMAX  = RDATA(5)        
      RCONST = RDATA(6)        
      IF (XMMAX .EQ.0.0) XMMAX  = 0.6        
      IF (RCONST.EQ.0.0) RCONST = 6.0        
      IF (IPRTC .EQ. 1) WRITE (LOG2,160) XSCALE,PSCALE,RLOW,PLOW,XMMAX, 
     1       RCONST        
 160  FORMAT (//10X,29HPLOTTING SCALE FOR DIMENSIONS,10X,1H=,F7.3, /10X,
     1       28HPLOTTING SCALE FOR PRESSURES,11X,1H=,F7.3, /10X,        
     2       22HMINIMUM RADIUS ON PLOT,17X,1H=,F7.3, /10X,        
     3       24HMINIMUM PRESSURE ON PLOT,15X,1H=,F7.3, /10X,        
     4       40HMAXIMUM M-SQUARED IN RELAXATION FACTOR =,F8.4, /10X,    
     5       29HCONSTANT IN RELAXATION FACTOR,10X,1H=,F8.4)        
      CALL ALG03 (LNCT,3)        
      CALL FREAD (LOG1,RDATA,2,1)        
      IF (DEBUG) CALL BUG1 ('ALG02   ',162,RDATA,2)        
      CONTR = RDATA(1)        
      CONMX = RDATA(2)        
      IF (IPRTC .EQ. 1) WRITE (LOG2,164) CONTR,CONMX        
 164  FORMAT (//10X,22HWAKE TRANSFER CONSTANT,17X,1H=,F8.5, /10X,       
     1       25HTURBULENT MIXING CONSTANT,14X,1H=,F8.5)        
      CALL ALG03 (LNCT,5+NCASE)        
      DO 168 K = 1,NCASE        
      CALL FREAD (LOG1,FLOW(K),1,0)        
 168  CALL FREAD (LOG1,SPDFAC(K),1,1)        
      IF (DEBUG) CALL BUG1 ('ALG02   ',171,FLOW,NCASE)        
      IF (DEBUG) CALL BUG1 ('ALG02   ',172,SPDFAC,NCASE)        
      IF (IPRTC .EQ. 1) WRITE(LOG2,180) (K,FLOW(K),SPDFAC(K),K=1,NCASE) 
 180  FORMAT (//10X,21HPOINTS TO BE COMPUTED,  //10X,2HNO,6X,8HFLOWRATE,
     1       4X,12HSPEED FACTOR, //,(10X,I2,F13.3,F14.3))        
      CALL FREAD (LOG1,L1,1,1)        
      IF (DEBUG) CALL BUG1 ('ALG02   ',180,L1,1)        
      DO 185 K = 1,L1        
      CALL FREAD (LOG1,XSTN(K),1,0)        
 185  CALL FREAD (LOG1,RSTN(K),1,1)        
      IF (DEBUG) CALL BUG1 ('ALG02   ',191,XSTN,L1)        
      IF (DEBUG) CALL BUG1 ('ALG02   ',192,RSTN,L1)        
      ISTAG = 0        
      IF (RSTN(1) .EQ. 0.0) ISTAG = 1        
      NSPEC(1) = L1        
      CALL ALG03 (LNCT,7+L1)        
      IF (IPRTC .EQ. 1) WRITE (LOG2,200) L1,(XSTN(K),RSTN(K),K=1,L1)    
 200  FORMAT (//10X,'ANNULUS / COMPUTING STATION GEOMETRY', //10X,      
     1       24HSTATION  1  SPECIFIED BY,I3,7H POINTS, //17X,4HXSTN,8X, 
     2       4HRSTN,//,(F22.4,F12.4))        
      IS1(1) = 1        
      LAST   = L1        
      DO 220 I = 2,NSTNS        
      CALL FREAD (LOG1,L1,1,1)        
      IF (DEBUG) CALL BUG1 ('ALG02   ',210,L1,1)        
      NEXT = LAST + 1        
      LAST = LAST + L1        
      IF (LAST .GT. 150) GO TO 550        
      DO 215 K = NEXT,LAST        
      CALL FREAD (LOG1,XSTN(K),1,0)        
 215  CALL FREAD (LOG1,RSTN(K),1,1)        
      IF (DEBUG) CALL BUG1 ('ALG02   ',215,XSTN(NEXT),LAST-NEXT+1)      
      IF (DEBUG) CALL BUG1 ('ALG02   ',216,RSTN(NEXT),LAST-NEXT+1)      
      IF (RSTN(NEXT) .EQ. 0.0) ISTAG = I        
      CALL ALG03 (LNCT,5+L1)        
      IS1(I) = NEXT        
      NSPEC(I) = L1        
 220  IF (IPRTC .EQ. 1) WRITE (LOG2,230) I,L1,(XSTN(K),RSTN(K),        
     1       K=NEXT,LAST)        
 230  FORMAT (//10X,7HSTATION,I3,14H  SPECIFIED BY,I3,7H POINTS, //17X, 
     1       4HXSTN,8X,4HRSTN, //,(F22.4,F12.4))        
      SPEED(1)  = 0.0        
      CALL FREAD (LOG1,IDATA,4,1)        
      IF (DEBUG) CALL BUG1 ('ALG02   ',233,IDATA,4)        
      L1        = IDATA(1)        
      NTERP(1)  = IDATA(2)        
      NDIMEN(1) = IDATA(3)        
      NMACH(1)  = IDATA(4)        
      DO 335 K = 1,L1        
      CALL FREAD (LOG1,RDATA,4,1)        
      IF (DEBUG) CALL BUG1 ('ALG02   ',234,RDATA,4)        
      DATAC(K) = RDATA(1)        
      DATA1(K) = RDATA(2)        
      DATA2(K) = RDATA(3)        
 335  DATA3(K) = RDATA(4)        
      CALL ALG03 (LNCT,7+L1)        
      IS2(1)   = 1        
      NDATA(1) = L1        
      LAST = L1        
      IF (IPRTC .EQ. 1) WRITE (LOG2,250) L1,NTERP(1),NDIMEN(1),NMACH(1),
     1       (DATAC(K),DATA1(K),DATA2(K),DATA3(K),K=1,L1)        
 250  FORMAT (//10X,24HSTATION CALCULATION DATA,   //7X,        
     1       18HSTATION  1  NDATA=,I3,7H NTERP=,I2,8H NDIMEN=,I2,       
     2       7H NMACH=,I2, //11X,5HDATAC,6X,14HTOTAL PRESSURE,4X,       
     3       17HTOTAL TEMPERATURE,4X,11HWHIRL ANGLE, //,        
     4       (5X,F12.4,F15.4,F19.3,F18.3))        
      DO 252 K = 1,L1        
 252  DATA1(K) = DATA1(K)*SCLFAC**2        
      LASTD    = 0        
      NOUT1(1) = 0        
      NOUT2(1) = 0        
      DO 320 I = 2,NSTNS        
      LOGN = LOG1        
      IF (NMANY .EQ. 0) GO TO 258        
      DO 254 L1 = 1,NMANY        
      IF (NWHICH(L1) .EQ. I) GO TO 256        
 254  CONTINUE        
      GO TO 258        
 256  LOGN = LOG5        
 258  CALL FREAD (LOGN,IDATA,16,1)        
      IF (DEBUG .AND. LOGN.EQ.LOG1) CALL BUG1 ('ALG02   ',258,IDATA,16) 
      NDATA(I)  = IDATA(1)        
      NTERP(I)  = IDATA(2)        
      NDIMEN(I) = IDATA(3)        
      NMACH(I)  = IDATA(4)        
      NWORK(I)  = IDATA(5)        
      NLOSS(I)  = IDATA(6)        
      NL1(I)    = IDATA(7)        
      NL2(I)    = IDATA(8)        
      NEVAL(I)  = IDATA(9)        
      NCURVE(I) = IDATA(10)        
      NLITER(I) = IDATA(11)        
      NDEL(I)   = IDATA(12)        
      NOUT1(I)  = IDATA(13)        
      NOUT2(I)  = IDATA(14)        
      NOUT3(I)  = IDATA(15)        
      NBLADE(I) = IDATA(16)        
      L1 = 3        
      IF (NDATA(I) .NE. 0) L1 = L1 + 5 + NDATA(I)        
      IF (NDEL(I)  .NE. 0) L1 = L1 + 3 + NDEL(I)        
      CALL ALG03 (LNCT,L1)        
      IF (IPRTC .EQ. 1) WRITE (LOG2,270) I,NDATA(I),NTERP(I),NDIMEN(I), 
     1       NMACH(I),NWORK(I),NLOSS(I),NL1(I),NL2(I),NEVAL(I),NCURVE(I)
     2,      NLITER(I),NDEL(I),NOUT1(I),NOUT2(I),NOUT3(I),NBLADE(I)     
 270  FORMAT (//7X,7HSTATION,I3, 8H  NDATA=,I3,7H NTERP=,I2,8H NDIMEN=, 
     1       I2,7H NMACH=,I2,7H NWORK=,I2,7H NLOSS=,I2,5H NL1=,I3,      
     2       5H NL2=,I3,7H NEVAL=,I2,8H NCURVE=,I2,8H NLITER=,I3,       
     3       6H NDEL=,I3, /19X,6HNOUT1=,I2,7H NOUT2=,I2,7H NOUT3=,I2,   
     4       8H NBLADE=,I3)        
      SPEED(I) = 0.0        
      IF (NDATA(I) .EQ. 0) GO TO 320        
      NEXT   = LAST + 1        
      LAST   = LAST + NDATA(I)        
      IS2(I) = NEXT        
      IF (LAST .GT. 100) GO TO 550        
      CALL FREAD (LOGN,SPEED(I),1,1)        
      IF (DEBUG .AND.LOGN.EQ.LOG1) CALL BUG1 ('ALG02   ',271,SPEED(I),1)
      DO 275 K = NEXT,LAST        
      CALL FREAD (LOGN,RDATA,6,1)        
      IF (DEBUG .AND. LOGN.EQ.LOG1) CALL BUG1 ('ALG02   ',272,RDATA,6)  
      DATAC(K) = RDATA(1)        
      DATA1(K) = RDATA(2)        
      DATA2(K) = RDATA(3)        
      DATA3(K) = RDATA(4)        
      DATA4(K) = RDATA(5)        
      DATA5(K) = RDATA(6)        
      CALL FREAD (LOGN,RDATA,4,1)        
      IF (DEBUG .AND. LOGN.EQ.LOG1) CALL BUG1 ('ALG02   ',273,RDATA,4)  
      DATA6(K) = RDATA(1)        
      DATA7(K) = RDATA(2)        
      DATA8(K) = RDATA(3)        
 275  DATA9(K) = RDATA(4)        
      IF (IPRTC .EQ. 1) WRITE (LOG2,290) SPEED(I),(DATAC(K),DATA1(K),   
     1       DATA2(K),DATA3(K),DATA4(K),DATA5(K),DATA6(K),DATA7(K),     
     2       DATA8(K),DATA9(K),K=NEXT,LAST)        
 290  FORMAT (//10X,7HSPEED =,F9.2, //13X,5HDATAC,7X,5HDATA1,7X,5HDATA2,
     1       7X,5HDATA3,7X,5HDATA4,7X,5HDATA5,7X,5HDATA6,7X,5HDATA7,7X, 
     2       5HDATA8,7X,5HDATA9, //,        
     3       (10X,F9.4,F12.3,F13.6,F11.4,F12.5,F12.5,4F12.4))        
      IF (NWORK(I) .NE. 1) GO TO 296        
      DO 294 K = NEXT,LAST        
 294  DATA1(K) = DATA1(K)*SCLFAC**2        
 296  IF (NEVAL(I).GT.0 .AND. NSTRMS.GT.NDATA(I)) LAST = LAST + NSTRMS -
     1    NDATA(I)        
      IF (NDEL(I) .EQ. 0) GO TO 320        
      NEXT   = LASTD + 1        
      LASTD  = LASTD + NDEL(I)        
      IS3(I) = NEXT        
      IF (LASTD .GT. 100) GO TO 550        
      DO 298 K = NEXT,LASTD        
      CALL FREAD (LOG1,DELC(K), 1,0)        
 298  CALL FREAD (LOG1,DELTA(K),1,1)        
      IF (DEBUG) CALL BUG1 ('ALG02   ',298,DELC(NEXT),LASTD-NEXT+1)     
      IF (DEBUG) CALL BUG1 ('ALG02   ',299,DELTA(NEXT),LASTD-NEXT+1)    
      IF (IPRTC .EQ. 1) WRITE(LOG2,310)(DELC(K),DELTA(K),K=NEXT,LASTD)  
 310  FORMAT (//13X,4HDELC,8X,5HDELTA, //,(10X,F9.4,F12.4))        
 320  CONTINUE        
      CALL ALG03 (LNCT,5+NSTNS)        
      DO 325 I = 1,NSTNS        
      CALL FREAD (LOG1,RDATA,3,1)        
      IF (DEBUG) CALL BUG1 ('ALG02   ',323,RDATA,3)        
      WBLOCK(I) = RDATA(1)        
      BBLOCK(I) = RDATA(2)        
 325  BDIST(I)  = RDATA(3)        
      IF (IPRTC .EQ. 1) WRITE (LOG2,340) (I,WBLOCK(I),BBLOCK(I),        
     1       BDIST(I),I=1,NSTNS)        
 340  FORMAT (//10X,'BLOCKAGE FACTOR SPECIFICATIONS', //10X,'STATION  ',
     1      ' WALL BLOCKAGE   WAKE BLOCKAGE   WAKE DISTRIBUTION FACTOR',
     2       //,(10X,I4,F16.5,F16.5,F19.3))        
      IF (NSET1 .EQ. 0) GO TO 380        
      DO 370 K = 1,NSET1        
      CALL FREAD (LOG1,L1,1,1)        
      IF (DEBUG) CALL BUG1 ('ALG02   ',342,L1,1)        
      DO 345 J = 1,L1        
      CALL FREAD (LOG1,RDATA,4,1)        
      IF (DEBUG) CALL BUG1 ('ALG02   ',343,RDATA,4)        
      DIFF(J,K)  = RDATA(1)        
      FDHUB(J,K) = RDATA(2)        
      FDMID(J,K) = RDATA(3)        
 345  FDTIP(J,K) = RDATA(4)        
      CALL ALG03 (LNCT,6+L1)        
      IF (IPRTC .EQ. 1) WRITE (LOG2,360) K,L1,(DIFF(J,K),FDHUB(J,K),    
     1       FDMID(J,K),FDTIP(J,K),J=1,L1)        
 360  FORMAT (//10X,'LOSS PARAMETER / DIFFUSION FACTOR CURVES FOR BLADE'
     1,      ' TYPE',I2,I5,' D-FACTORS GIVEN', //15X,9HDIFFUSION,5X,    
     2       'L O S S   P A R A M E T E R S', /16X,7HFACTORS,8X,3HHUB,  
     3       9X,3HMID,8X,3HTIP,//,(15X,F8.3,F13.5,F12.5,F11.5))        
 370  NDIFF(K) = L1        
 380  IF (NSET2 .EQ. 0) GO TO 450        
      DO 440 K = 1,NSET2        
      CALL FREAD (LOG1,IDATA,2,1)        
      IF (DEBUG) CALL BUG1 ('ALG02   ',385,IDATA,2)        
      L1 = IDATA(1)        
      L2 = IDATA(2)        
      CALL ALG03 (LNCT,7+L1)        
      NM(K)   = L1        
      NRAD(K) = L2        
      CALL FREAD (LOG1,TERAD(1,K),1,1)        
      IF (DEBUG) CALL BUG1 ('ALG02   ',391,TERAD(1,K),1)        
      DO 398 J = 1,L1        
      CALL FREAD (LOG1,RDATA,2,1)        
      IF (DEBUG) CALL BUG1 ('ALG02   ',398,RDATA,2)        
      DM(J,1,K)    = RDATA(1)        
 398  WFRAC(J,1,K) = RDATA(2)        
      IF (IPRTC .EQ. 1) WRITE (LOG2,410) K,L1,L2,TERAD(1,K),(DM(J,1,K), 
     1       WFRAC(J,1,K),J=1,L1)        
 410  FORMAT (//10X,'FRACTIONAL LOSS DISTRIBUTION CURVES FOR BLADE ',   
     1       'CLASS',I2,I5,' POINTS GIVEN AT',I3,' RADIAL LOCATIONS', //
     2       10X,'FRACTION OF COMPUTING STATION LENGTH AT BLADE EXIT =',
     3       F7.4, //10X,'FRACTION OF MERIDIONAL CHORD',4X,        
     4       'LOSS/LOSS AT TRAILING EDGE', //,(15X,F11.4,20X,F11.4))    
      IF (L2 .EQ. 1) GO TO 440        
      DO 420 L = 2,L2        
      CALL ALG03 (LNCT,5+L1)        
      CALL FREAD (LOG1,TERAD(L,K),1,1)        
      IF (DEBUG) CALL BUG1 ('ALG02   ',411,TERAD(L,K),1)        
      DO 415 J = 1,L1        
      CALL FREAD (LOG1,RDATA,2,1)        
      IF (DEBUG) CALL BUG1 ('ALG02   ',412,RDATA,2)        
      DM(J,L,K)    = RDATA(1)        
 415  WFRAC(J,L,K) = RDATA(2)        
 420  IF (IPRTC .EQ. 1) WRITE (LOG2,430) TERAD(L,K),(DM(J,L,K),        
     1       WFRAC(J,L,K),J=1,L1)        
 430  FORMAT (//10X,'FRACTION OF COMPUTING STATION LENGTH AT BLADE ',   
     1       'EXIT =',F7.4, //10X,'FRACTION OF MERIDIONAL CHORD',4X,    
     2       'LOSS/LOSSAT TRAILING EDGE', //,(15X,F11.4,20X,F11.4))     
 440  CONTINUE        
 450  IF (NSPLIT.EQ.0 .AND. NREAD.EQ.0) GO TO 570        
      DO 455 J = 1,NSTRMS,6        
 455  CALL FREAD (LOG1,DELF(J),6,1)        
      IF (DEBUG) CALL BUG1 ('ALG02   ',455,DELF,NSTRMS)        
      L1 = 5        
      IF (NSTRMS .GE. 16) L1 = 8        
      CALL ALG03 (LNCT,L1)        
      IF (IPRTC .EQ. 1) WRITE (LOG2,470)        
      L1 = NSTRMS        
      IF (NSTRMS .GT. 15) L1 = 15        
      IF (IPRTC .EQ. 1) WRITE (LOG2,480) (J,J=1,L1)        
 480  FORMAT (//10X,'STREAMLINE',I5,14I7)        
 470  FORMAT (//10X,'PROPORTIONS OF TOTAL FLOW BETWEEN HUB AND EACH ',  
     1       'STREAMLINE ARE TO BE AS FOLLOWS')        
      IF (IPRTC .EQ. 1) WRITE(LOG2,490) (DELF(J),J=1,L1)        
 490  FORMAT (10X,4HFLOW,7X,15F7.4)        
      IF (NSTRMS .LE. 15) GO TO 500        
      L1 = L1 + 1        
      IF (IPRTC .EQ. 1) WRITE (LOG2,480) (J,J=L1,NSTRMS)        
      IF (IPRTC .EQ. 1) WRITE (LOG2,490) (DELF(J),J=L1,NSTRMS)        
 500  IF (NREAD .EQ. 0) GO TO 570        
      DO 505 I = 1,NSTNS        
      DO 505 J = 1,NSTRMS        
      CALL FREAD (LOG1,RDATA,3,0)        
      IF (DEBUG) CALL BUG1 ('ALG02   ',501,RDATA,3)        
      R(J,I)  = RDATA(1)        
      X(J,I)  = RDATA(2)        
      XL(J,I) = RDATA(3)        
      CALL FREAD (LOG1,IDATA,2,1)        
      IF (DEBUG) CALL BUG1 ('ALG02   ',502,IDATA,2)        
      II(J,I) = IDATA(1)        
 505  JJ(J,I) = IDATA(2)        
      CALL ALG03 (LNCT,5+NSTRMS)        
      IF (IPRTC .EQ. 1) WRITE (LOG2,520)        
 520  FORMAT (//10X,'ESTIMATED STREAMLINE COORDINATES')        
      DO 530 I = 1,NSTNS        
      IF (I .GT. 1) CALL ALG03 (LNCT,3+NSTRMS)        
 530  IF (IPRTC .EQ. 1) WRITE (LOG2,540) (I,J,R(J,I),X(J,I),XL(J,I),    
     1       II(J,I),JJ(J,I),J=1,NSTRMS)        
 540  FORMAT (//10X,'STATION  STREAMLINE   RADIUS  AXIAL COORDINATE  ', 
     1       'L -COORDINATE    CHECKS-  I    J', //,        
     2       (3X,2I11,F14.4,F12.4,F16.4,I17,I5))        
      GO TO 570        
 550  WRITE  (LOG2,560)        
 560  FORMAT (////10X,'JOB STOPPED - TOO MUCH INPUT DATA')        
      CALL MESAGE (-37,0,NAME)        
 570  RETURN        
      END        
