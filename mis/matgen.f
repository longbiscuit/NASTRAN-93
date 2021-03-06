      SUBROUTINE MATGEN        
C        
C     THE PURPOSE OF THIS MODULE IS TO GENERATE CERTAIN KINDS OF        
C     MATRICES ACCORDING TO ONE OF SEVERAL SIMPLE USER SELECTED OPTIONS 
C        
C     MATGEN      TAB/OUT/P1/P2/P3/P4/P5/P6/P7/P8/P9/P10/P11  $        
C        
C     TAB - INPUT TABLE - (OPTIONAL) FOR USE IN GENERATING THE MATIRX   
C                 (THIS DATA MAY BE ASSUMED TO BE INPUT VIA DTI CARDS.) 
C             = EQEXIN TABLE  FOR P1 =  9        
C             = USET   TABLE  FOR P1 = 11        
C             = ANY GINO FILE FOR P1 = 10        
C        
C     OUT - OUTPUT MATRIX - IF PURGED AND P1 IS NOT 10, P1 WILL BE SET  
C               TO -1 AND RETURN        
C        
C     P1      - INPUT - INTEGER, OPTION SELECTION. (DEFULAT P1 = 3)     
C             = 1, GENERATE A RSP IDENTITY MATRIX OF ORDER P2.        
C             = 2, GENERATE AN IDENTITY MATRIX OF ORDER P2, FORM 8      
C             = 3, GENERATE A DIAGONAL MATRIX FORM INPUT FILE T        
C             = 4, GENERATE A PARTERN MATRIX        
C             = 5, GENERATE A MATRIX OF PSEUDO-RANDOM NUMBERS.        
C             = 6, GENERATE PARTITION VECTOR OF ORDER P2, WITH P3 ZERO'S
C                  CLOOWED BY P4 ONE'S FOLLOWED BY P5 ZERO'S ETC.       
C                  REMAINER IS ALWAYS AERO. TOO MANY DEFINITIONS IS AN  
C                  ERROR.        
C             = 7, GENERATE A NULL MATRIX        
C             = 8, GENERATE A MATRIX FROM EQUATIONS BASED ON ITS INDICES
C             = 9, GENERATE A TRANSFORMATION BETWEEN EXTERNAL AND       
C                  INTERANL MATRICES, OF G-SET SIZE.        
C                  P2 = 0, OUTPUTS INT-EXT (DEFAULT)        
C                  P2 = 1, OUTPUTS TRANSPOSE EXT-INT        
C                  P3 = NO. OF TERMS IN G-SET (REQUIRED). USE LUSET IN  
C                       MOST SOLUTION SEQUENCES.        
C             =10, ALLOW USER TO ALTER DATA BLOCK TRAILER.        
C             =11, GENERATE A RECTANGULAR MATRIX, DRIVEN BY USET TABLE  
C        
C     P2 - P11 -   OPTION PARAMETERS - INTEGER - INPUT AND OUTPUT       
C                  INPUT  AS OPTION VALUE (1 THRU NP)        
C                  OUTPUT AS -1 IF AND ONLY IF OUTPUT DATA BLOCK IS PRE-
C                  PURGED        
C                  DEFAULT VALUES FOR P2 THRU P11 ARE ZEROS        
C        
C        
      IMPLICIT INTEGER (A-Z)        
      EXTERNAL         LSHIFT        
      INTEGER          MCB(7),NAM(2),P(11),CODE(2),IX(12)        
      REAL             VAL,RX(7),TMP(7)        
      DOUBLE PRECISION D(2)        
      CHARACTER        UFM*23,UWM*25,UIM*29,SFM*25        
      COMMON /XMSSG /  UFM,UWM,UIM,SFM        
      COMMON /BLANK /  P1,P2,P3,P4,P5,P6,P7,P8,P9,P10,P11        
      COMMON /SYSTEM/  SYSBUF,NOUT,DUM37(37),NBPW,DUM14(14),IPREC       
      COMMON /MACHIN/  MACHX        
      COMMON /ZBLPKX/  VAL(4),ROW        
      COMMON /PACKX /  ITA,ITB,I2,J2,INCR2        
CZZ   COMMON /ZZMGEN/  X(1)        
      COMMON /ZZZZZZ/  X(1)        
      EQUIVALENCE      (VAL(1),D(1)),(X(1),IX(1),RX(1)),(P(1),P1)        
      DATA    NAM   /  4HMATG,4HEN  /,  NP /  11   /        
      DATA    EQE   ,  XIN / 4HEQEX, 4HIN  /, CODE / 6,1 /        
      DATA    OUT   ,  SC1,SC2,SC3, T      /        
     1        201   ,  301,302,303, 101    /        
C        
C     IF OUTPUT DATA BLOCK IS PRE-PURGED, SET P1 = -1 AND RETURN        
C        
      IF (P1 .EQ. 10) GO TO 30        
      MCB(1) = OUT        
      CALL RDTRL (MCB)        
      IF (MCB(1) .LE. 0) GO TO 1580        
C        
C     CHECK INPUT FILE REQUIREMENT        
C        
   30 IX(1) = T        
      CALL RDTRL (IX(1))        
      IF (P1 .EQ. 10) GO TO 1000        
      IF (P1.EQ.3 .OR. P1.EQ.9 .OR. P1.EQ.10 .OR. P1.EQ.11) GO TO 50    
      IF (IX(1) .EQ. 0) GO TO 50        
      CALL FNAME (IX(1),RX(2))        
      WRITE  (NOUT,40) UWM,RX(2),RX(3),P1        
   40 FORMAT (A25,' FROM MODULE MATGEN. INPUT DATA BLOCK ',2A4,' IS ',  
     1       'NOT NEEDED FOR OPTION',I3)        
C        
C     CHECK OPEN CORE AND OPEN OUTPUT DATA BLOCK        
C        
   50 LCOR = KORSZ(IX(1))        
      IF (P1 .EQ. 2) GO TO 200        
      IF (LCOR .LT. SYSBUF) GO TO 1500        
      IBUF1 = LCOR  - SYSBUF - 1        
      IBUF2 = IBUF1 - SYSBUF        
      CALL GOPEN (OUT,IX(IBUF1),1)        
      LCOR = LCOR - SYSBUF        
C        
C     TEST FOR VALID OPTION AND BRANCH ON OPTION.        
C        
      IF (P1 .EQ. 0) P1 = 3        
      IF (P1.LT.0 .OR. P1.GT.NP) GO TO 1510        
      GO TO (100,200,300,400,500,600,700,800,900,1000,1100), P1        
C        
C     OPTION 1 - GENERATE A RSP IDENTITY MATRIX OF ORDER P2, AND TRAILER
C     ========   P2 = ORDER OF MATRIX        
C                P3 = SKEW FLAG, IF NONZERO, GENERATE A SKEW-DIAGONAL   
C                     MATRIX        
C                P4 = PRECISION (1 OR 2). IF ZERO, USE MACHINE PRECISION
C        
  100 IF (P2 .GT. 0) GO TO 110        
      IPX = 2        
      PX  = P2        
      GO TO 1530        
  110 ITA = 1        
      ITB = P4        
      IF (P4 .EQ. 0) ITB = IPREC        
      INCR2 = 1        
      CALL MAKMCB (MCB,OUT,P2,6,ITB)        
      DO 150 I = 1,P2        
      RX(I) = 1.0        
      I2 = I        
      J2 = I        
      CALL PACK (IX,OUT,MCB)        
  150 CONTINUE        
      GO TO 210        
C        
C     OPTION 2 - GENERATE AN IDENTITY TRAILER (FORM = 8)        
C     ========   P2 = ORDER OF MATRIX        
C        
C                ** CAUTION ** FORM = 8 MATRICES DO NOT REALLY EXIST    
C                ONLY CERTAIN  ROUTINES CAN PROCESS THEM        
C                e.g. FBS, MPYAD, CEAD etc.        
C        
  200 MCB(1) = OUT        
      MCB(2) = P2        
      MCB(3) = P2        
      MCB(4) = 8        
      MCB(5) = 1        
      MCB(6) = 1        
C     MCB(7) = LSHIFT(1,NBPW-2) + P2        
      MCB(7) = LSHIFT(1,NBPW-2 - (NBPW-32)) + P2        
C        
C     ADD (NBPW-32) TO MCB(7) SO THAT CRAY, WITH 48-BIT INTEGER WILL    
C     NOT GET INTO TROUBLE. (SEE SDCOMP AND WRTTRL)        
C        
  210 CALL WRTTRL (MCB)        
      GO TO 1700        
C        
C     OPTION 3 - GENERATE A DIAGONAL MATRIX FROM INPUT TABLE T        
C     ========   P2 = DATA TYPE OF T        
C                P3 = 0, FORM 6 MATRIX IS GENERATED        
C                   = 1, FORM 3 MATRIX IS GENERATED        
C        
C     THIS OPTION IS THE ORIGINAL MATGEN IN COSMIC MATGEN        
C     SKIP HEADER RECORD, AND BEGINNING RECORD ON T        
C     PICKUP DATA IN ARRAY OF 7 WORDS. DIAGONAL VAULE ON THE 3RD        
C        
  300 LCOR = LCOR - SYSBUF        
      IF (LCOR .LT. SYSBUF) GO TO 1500        
      IF (P2 .EQ. 0) P2 = 1        
      CALL OPEN (*1550,T,IX(IBUF2),0)        
      CALL SKPREC (T,2)        
      ITA = P2        
      ITB = IPREC        
      INCR2 = 1        
      FORM = 6        
      IF (P3 .EQ. 1) FORM = 3        
      CALL MAKMCB (MCB,OUT,0,FORM,IPREC)        
      M  = 0        
  310 CALL READ (*1560,*330,T,TMP,7,0,0)        
      M  = M + 1        
      IF (P3 .EQ. 1) GO TO 320        
      I2 = M        
      J2 = M        
      CALL PACK (TMP(3),OUT,MCB)        
      GO TO 310        
  320 RX(M) = TMP(3)        
      GO TO 310        
  330 IF (P3 .EQ. 1) GO TO 340        
      MCB(3) = MCB(2)        
      GO TO 350        
  340 I2 = 1        
      J2 = M        
      CALL PACK (RX,OUT,MCB)        
      MCB(2) = 1        
      MCB(3) = M        
  350 CALL CLOSE (T,1)        
      GO TO 210        
C        
C     OPTION 4 - GENERATE A PATTERN MATRIX        
C     ========   P2 = NUNBER OF COLUMNS        
C                P3 = NUMBER OF ROWS        
C                P4 = PRECISION (1 OR 2). IF 0, USE MACHINE PRECISION   
C                P5 = NUMBER OF TERMS PER STRING. IF 0, USE 1        
C                P6 = INCREMENT BETWEEN STRINGS. IF 0, USE 1        
C                P7 = ROW NUMBER OF 1ST STRING IN COLUMN 1. IF 0, USE 1 
C                P8 = INCREMENT TO 1ST ROW FOR SUBSEQUENT COLUMNS.      
C                P9 = NUMBER OF COLS BEFORE RETURNING TO P7.        
C        
C                THE VALUE OF EACH NON-ZERO TERM IN THE MATRIX WILL BE  
C                THE COLUMN NUMBER        
C                e.g. TO GENERATE A 10x10 DIAGONAL MATRIX WITH THE COL. 
C                NUMBER IS EACH DIAGONAL POSITION, CODE        
C        
C                MATGEN   ,/DIAG/4/10/10/0/1/10/1/1/10  $        
C        
  400 P2 = MAX0(P2,1)        
      P3 = MAX0(P3,1)        
      IF (P4.NE.1 .AND. P4.NE.2) P4 = 0        
      IF (P4 .EQ. 0) P4 = IPREC        
      P5 = MAX0(P5,1)        
      P6 = MAX0(P6,1)        
      P7 = MAX0(P7,1)        
      P8 = MAX0(P8,0)        
      P9 = MAX0(P9,1)        
      IROW1 = P7        
      L = 1        
      CALL MAKMCB (MCB,OUT,P3,2,P4)        
C        
      DO 440 J = 1,P2        
      IF (P4 .EQ. 1) VAL(1) = J        
      IF (P4 .EQ. 2) D(  1) = J        
      ROW = IROW1        
      CALL BLDPK (P4,P4,OUT,0,0)        
  410 CONTINUE        
      DO 420 K = 1,P5        
      IF (ROW .GT. P3) GO TO 430        
      CALL ZBLPKI        
      ROW = ROW + 1        
  420 CONTINUE        
      ROW = ROW + P6 - 1        
      GO TO 410        
  430 CALL BLDPKN (OUT,0,MCB)        
      L = L + 1        
      IROW1 = IROW1 + P8        
      IF (L .LE. P9) GO TO 430        
      L = 1        
      IROW1 = P7        
  440 CONTINUE        
      GO TO 1400        
C        
C     OPTION 5 - GENERATE A MATRIX OF PSEUDO-RANDOM NUMBERS. THE NUMBERS
C     ========   SPAN THE RANGE 1. TO 1.0 WITH A NORMAL DISTRIBUTION    
C                P2 = NUMBER OF COLUMNS        
C                P3 = NUMBER OF ROWS        
C                P4 = PRECISION (1 OR 2).  IF 0, USED MACHINE PRECISION 
C                P5 = SEED FOR RANDOM NUMBER GENERATION.  IF P5.LE.0,   
C                     THE TIME OF DAY (SECONDS PAST MIDNIGHT) WILL BE   
C                     USED        
C        
C     OPTION 5 WAS WRITTEN BY G.CHAN/UNISYS 2/93        
C        
  500 ITA = 1        
      ITB = P4        
      IF (P4 .EQ. 0) ITB = IPREC        
      FORM = 2        
      IF (P2 .EQ. P3) FORM = 1        
      I2 = 1        
      J2 = P3        
      INCR2 = 1        
      CALL MAKMCB (MCB,OUT,P2,FORM,ITB)        
      K  = P5        
      IF (MACHX .EQ. 4) GO TO 560        
C                   CDC        
      IF (MACHX .EQ. 9) GO TO 530        
C                    HP        
C        
      DO 520 I = 1,P2        
      IF (P5 .EQ. 0) CALL CPUTIM (K,K,0)        
      K  = (K/2)*2 + 1        
      DO 510 J = 1,P3        
      RX(J) = RAN(K)        
  510 CONTINUE        
      CALL PACK (RX(1),OUT,MCB)        
  520 CONTINUE        
      GO TO 590        
C        
C     HP ONLY        
C     ACTIVATE SRAND AND RAND() BELOW, AND COMMENT OUT RAN(K) ABOVE     
C        
  530 CONTINUE        
      WRITE  (NOUT,535) SFM        
  535 FORMAT (A25,'. MATGEN NEEDS TO ACTIVATE SRAND AND RAND() FOR HP') 
      CALL MESAGE (-61,0,0)        
      DO 550 I = 1,P2        
      IF (P5 .EQ. 0) CALL CPUTIM (K,K,0)        
C     CALL SRAND (K)        
      DO 540 J = 1,P3        
C     RX(J) = RAND()        
  540 CONTINUE        
      CALL PACK (RX(1),OUT,MCB)        
  550 CONTINUE        
      GO TO 590        
C        
C     CDC ONLY        
C     ACTIVATE SRAND AND RAND() BELOW, AND COMMENT OUT RAN(K) ABOVE     
C        
  560 CONTINUE        
      WRITE  (NOUT,565) SFM        
  565 FORMAT (A25,'. MATGEN NEEDS TO ACTIVATE RANSET AND RANF() FOR CDC'
     1       )        
      CALL MESAGE (-61,0,0)        
      DO 580 I = 1,P2        
      IF (P5 .EQ. 0) CALL CPUTIM (K,K,0)        
C     CALL RANSET (K)        
      DO 570 J = 1,P3        
C     RX(J) = RANF()        
  570 CONTINUE        
      CALL PACK (RX(1),OUT,MCB)        
  580 CONTINUE        
C        
  590 CALL CLOSE  (OUT,1)        
      CALL WRTTRL (MCB(1))        
      GO TO 1700        
C        
C     OPTION 6 - GENERATE A PARTITIONING VECTOR FOR USE IN PARTN OR     
C     ========   MERGE        
C                P2 = NUMBER OF ROWS        
C                P3,P5,P7,P9  = NUMBER OF ROWS WITH ZERO COEFFICIENTS   
C                P4,P6,P8,P10 = NUMBER OF ROWS WITH UNIT COEFFICIENTS   
C        
C                IF SUM OF P3 THRU P10 IS .LT. P2, THE REMAINING TERMS  
C                CONTAIN ZEROS        
C                IF SUM OF P3 THRU P10 IS .GT. P2, THE TERMS ARE IGNORED
C                AFTER P2        
C                e.g. GENERATE A VECTOR OF 5 UNIT TERMS FOLLOWED BY 7   
C                ZEROS, FOLLOWED BY TWO UNIT TERMS        
C        
C                MATGEN,   ,/UPART/6/14/0/5/7/2   $        
C        
C     OPTION 6 WAS ORIGINALLY WRITTEN BY P.KIRCHMAN/SWALES 1/92        
C     RE-CODED BY G.CHAN/UNISYS FOR ALL COMPILERS,  2/93        
C        
  600 IPX = 2        
      PX  = P2        
      IF (P2 .LE. 0) GO TO 1530        
      INCR2 = 1        
      I2  = 1        
      J2  = P2        
      ITA = 1        
      ITB = 1        
      CALL MAKMCB (MCB,OUT,P2,2,ITB)        
      TOT = 0        
      DO 610 I = 3,11        
  610 TOT = TOT + P(I)        
      IF (TOT .GT. P2) WRITE (NOUT,620) UFM,P1,P2        
      IF (TOT .LT. P2) WRITE (NOUT,630) UWM,P1        
  620 FORMAT (A23,' FROM MATGEN, OPTION',I3,'. TOO MANY ENTRIES FOR ',  
     1       'SPECIFIED SIZE',I7)        
  630 FORMAT (A25,' FORM MATGEN, OPTION',I3,'. THE NUMBER OF ENTRIES ', 
     1       'SPECIFIED BY PARAMETERS IS LESS THAN THE TOTAL SIZE', /5X,
     2       'OF THE PARTITION. THE REMAINING RENTRIES ARE ZERO FILLED')
      K = 1        
      DO 660 I = 3,9,2        
      PI = P(I)        
      DO 640 J = 1,PI        
      IX(K) = 0        
  640 K = K + 1        
      PI = P(I+1)        
      DO 650 J = 1,PI        
      IX(K) = 1        
  650 K = K + 1        
  660 CONTINUE        
      IF (K .GE. P2) GO TO 680        
      DO 670 I = K,P2        
  670 IX(I) = 0        
  680 CALL PACK (IX,OUT,MCB)        
      CALL CLOSE (OUT,1)        
      CALL WRTTRL (MCB)        
      GO TO 1700        
C        
C     OPTION 7 - GENERATE A NULL MATRIX        
C     ========   P2 = NUMBER OF ROWS        
C                P3 = NUMBER OF COLUMNS        
C                P4 = FORM; IF P4 = 0, AND P2 = P3, FORM WILL BE 6      
C                     (SYMMETRIC). OTHERWISE P4 IS 2 (RECTANGULAR)      
C                P5 = TYPE: IF P5 = 0, TYPE IS MACHINE PRECISION        
C        
  700 D(1) = 0.0D0        
      D(2) = 0.0D0        
      ITA = 1        
      ITB = P5        
      IF (P5 .EQ. 0) ITB = IPREC        
      FORM = P4        
      IF (P4.EQ.0 .AND. P2.EQ.P3) FORM = 6        
      IF (P4.EQ.0 .AND. P2.NE.P3) FORM = 2        
      I2 = 1        
      J2 = 1        
      INCR2 = 1        
      CALL MAKMCB (MCB,OUT,P2,FORM,ITB)        
      DO 750 I = 1,P3        
      CALL PACK (VAL,OUT,MCB)        
  750 CONTINUE        
      CALL CLOSE  (OUT,1)        
      CALL WRTTRL (MCB(1))        
      GO TO 1700        
C        
C     OPTION 8 - GENERATE A MATRIX FROM EQUATIONS BASED ON IT INDICES   
C     ========   P2 =  0, GENERATE ALL TERMS        
C                  .NE.0, GENERATE ONLY DIAGONAL TERMS        
C                P3 =     NUMBER OF ROWS        
C                P4 =     NUMBER OF COLUMNS        
C                P5 =     NUMBER OF THE RECORD IN THE INPUT DTI TABLE   
C                         USED TO DEFINE REAL COEFFICIENTS        
C                  .LT.0, COEFFICIENT TAKEN FROM DTI TRAILER        
C                         COEFF(TRAILER1) = FLOAT(TRAILER2)   TRAILER   
C                         COEFF(TRAILER3) = FLOAT(TRAILER4)   ITEMS ARE 
C                         COEFF(TRAILER5) = FLOAT(TRAILER6)   INTEGERS  
C        
C                   = 0,  DATA PAIRS FROM RECORD 0 (DATA BLOCK HEADER   
C                         RECORD) ARE INTERPRETED AS DFINING        
C                         COEFF(V1) = V2     V1 IS INTEGER, V2 IS REAL  
C                  .GT.0, DATA PAIRS FROM RECORD P5 INTERPRETED AS ABOVE
C                P6 =     NUMBER OF THE RECORD IN THE INPUT DTI TABLE   
C                         USED TO DEFINE IMAGINARY DOEFFICIENTS D(I)    
C                  .LE.0, NO DOEFFICIENTS DEFINED        
C                  .GT.0, DATA PAIRS FROM RECORD P6 INTERPRETED AS ABOVE
C                         WHERE D(V1) = V2        
C                P7 =     FORM OF OUTPUT MATRIX        
C                  .LE.0, FORM = 1 OR 2, DEPENDING ON P3 AND P4        
C                  .GT.0, FORM SET TO P7        
C                P8 =     COEFFICIENT PRINT FLAG        
C                   = 0,  DO NOT PRINT COEFFICIENT LISTS        
C                  .NE.0, PRINT COEFFICIENTS LISTS C(L) AND D(L) FROM   
C                         DTI INPUT. (PRINT D(L) LIST ONLY IF P6.GT.0)  
C        
C                SEE USER MANUAL FOR THE EQUATION USED TO DETERMINE THE 
C                COEFFICIENT OF THE (I,J)TH TERM OF THE OUTPUT MATRIX   
C        
  800 WRITE (NOUT,1200) UWM,P1        
      GO TO 1700        
C        
C     OPTION 9 - GENERATE A TRANSFORMATION BETWEEN EXTERNAL AND INTERNAL
C     ========   MATRICES FOR G-SET SIZE MATRICES        
C                P2 = 0, OUTPUT NON-TRANSPOSED FACTOR, UEXT = MAT*UINT  
C                   = 1, OUTPUT TRANSPOSED FACTOR, UEXT = MAT*UINT      
C                P3 = NUMBER OF TERMS IN G-SET. THE PARAMETER LUSET     
C                     CONTAINS THIS NUMBER IN MOST SOLUTION SEQUENCES   
C        
C                EXAMPLES -        
C                1. TRANSFORM A g-SET SIZE VECTOR TO EXTERNAL SEQUENCE  
C                ALTER XX  $ AFTER SDR1, ALL SDR1 OUTPUTS ARE IN        
C                            INTERNAL SEQUENCE        
C                MATGEN  EQEXIN/INTEXT/9//LUSET $        
C                MPYAD   INTEXT,UGV,/UGVEXT/1 $        
C        
C                2. TRANSFORM AN a-SET SIZE MATRIX TO EXTERNAL SEQUENCE 
C                ALTER XX  $ AFTER KAA IS GENERATED, ALL MATRICES ARE IN
C                            INTERNAL SEQUENCE        
C                MATGET  EQEXIN/INTEXT/9/0/LUSET $        
C                SMPYAD  INTEXT,KAGG,INTEXT,,/KAAGEXT/3////1////6 $     
C                $ (KAAGEXT) = TRANSPOSE(INTEXT)*(KAAG)*(INTEXT)        
C                $ ITS FORM IS 6 (SYMMETRIC)        
C        
C     OPTION 9 WAS ORIGINALLY WRITTEN BY P.KIRCHMAN/SWALES 1/92        
C     RE-CODED BY G.CHAN/UNISYS FOR ALL COMPILERS,  2/93        
C        
  900 IPX = 3        
      PX  = P(3)        
      IF (PX .LE. 0) GO TO 1530        
      NUSET = PX        
      L     = 2        
      NVAL  = IX(L)        
      CALL FNAME (T,TMP(1))        
      IF (TMP(1).NE.EQE .OR. TMP(2).NE.XIN) GO TO 1600        
      CALL OPEN (*1550,T,IX(IBUF2),0)        
      CALL FWDREC (*1560,T)        
      CALL FWDREC (*1560,T)        
      CALL READ (*1560,*910,T,IX(1),IBUF2-1,1,L)        
  910 CALL CLOSE (T,1)        
      IF (L .NE. NVAL*2) GO TO 1620        
      ITA = IPREC        
      ITB = ITA        
      CALL MAKMCB (MCB,OUT,NUSET,2,ITB)        
      INCR2 = 1        
      VAL(1)= 1.0        
      IF (ITA .EQ. 2) D(1) = 1.0D+0        
      TOT   = 0        
      IF (P2 .GT. 0) GO TO 930        
C        
C     NO TRANSPOSE        
C        
      DO 920 I = 1,NVAL        
      IS2 = I*2        
      A = IX(IS2)/10        
      B = MOD(IX(IS2),10)        
      C = CODE(B)        
      DO 920 J = 1,C        
      I2 = A        
      J2 = A        
      CALL PACK (VAL,OUT,MCB)        
  920 A = A + 1        
      TOT = TOT + C        
      GO TO 980        
C        
C     TRANSPOSE        
C        
  930 NVAL2 = NVAL*2        
      POS = 1        
      DO 940 I = 1,NVAL        
      IS2 = I*2        
      A = IX(IS2)/10        
      B = MOD(IX(IS2),10)        
      IX(IS2-1) = POS        
  940 POS = POS + CODE(B)        
      DO 970 I = 4,NVAL2,2        
      J = NVAL2        
      FLAG = 0        
  950 IF (IX(J) .GE. IX(J-2)) GO TO 960        
      FLAG = 1        
      K = IX(J  )        
      L = IX(J-1)        
      IX(J  ) = IX(J-2)        
      IX(J-1) = IX(J-3)        
      IX(J-2) = K        
      IX(J-3) = L        
  960 J = J - 2        
      IF (J .GE. I) GO TO 950        
      IF (FLAG .EQ. 0) GO TO 980        
  970 CONTINUE        
C        
  980 DO 990 I = 1,NVAL        
      IS2 = I*2        
      A = IX(IS2)/10        
      B = MOD(IX(IS2),10)        
      A = IX(IS2-1)        
      C = CODE(B)        
      DO 990 J = 1,C        
      I2 = A        
      J2 = A        
      CALL PACK (VAL,OUT,MCB)        
  990 A  = A + 1        
      TOT = NVAL*C        
      IF (NUSET .NE. TOT) GO TO 1640        
      CALL WRTTRL (MCB)        
      CALL CLOSE  (OUT,1)        
      GO TO 1700        
C        
C     OPTION 10 - ALLOW USER TO ALTER DATA BLOCK TRAILER        
C     =========        
C     IF PI IS NEGATIVE, THE CORRESPONDING TRAILER WORD (I) IS SET TO   
C     ZERO        
C        
 1000 IF (IX(1) .EQ. 0) GO TO 1050        
      CALL FNAME (IX(1),IX(11))        
      WRITE  (NOUT,1010) UIM,IX(11),IX(12),(IX(I),I=2,7)        
 1010 FORMAT (A29,' FROM MATGEN MODULE, OPTION 10. TRAILER OF ',2A4,2H -
     1,      /5X,'OLD - ',6I7)        
      DO 1020 I = 2,7        
      IF (P(I) .NE. 0) IX(I) = P(I)        
      IF (P(I) .LT. 0) IX(I) = 0        
 1020 CONTINUE        
      WRITE  (NOUT,1030) (IX(I),I=2,7)        
 1030 FORMAT (5X,'NEW - ',6I7)        
      IF (IX(2).EQ.IX(3) .AND. IX(4).EQ.2 .AND. IX(7).NE.0)        
     1   WRITE (NOUT,1040) UIM        
 1040 FORMAT (A29,'. SINCE ROW = COLUMN, RECTANGULAR FORM 2 WILL BE ',  
     1       'CHANGED TO SQUARE FORM 1 AUTOMATICALLY')        
      IX(1) = 199        
      CALL WRTTRL (IX(1))        
      GO TO 1700        
C        
 1050 WRITE  (NOUT,1060) UWM        
 1060 FORMAT (A25,' FROM MATGEN, OPTION 10. INPUT FILE MISSING')        
      GO TO 1700        
C        
C     OPTION 11 - GENERATE A RECTANGULAR MATRIX, DRIVEN BY USET TABLE   
C     =========   P2 = 1, GENERATE A NULL MATRIX        
C                  .NE.1, GENERATE A NULL MATRIX WITH AN IDENTITY MATRIX
C                         STORED IN IT        
C                 P3 = NUMBER OF COLUMNS OF OUTPUT MATRIX, IF P2 = 1    
C                    = BIT POSITION OF SET THAT DEFINES NUMBER OF ROW,  
C                      IF P2.NE.1. SEE SECTION 1.4.10 FOR BIT POSITION  
C                      LIST. DEFAULT IS A-SET SIZE.        
C                 P4 = NOT USED IF P2 = 1. THE OUTPUT MATRIX WILL BE    
C                      NULL AND HAVE P3 COLUMNS AND A-SET SIZE ROWS     
C                    = BIT POSITION OF SET THAT DEFINES NUMB OF COLUMNS 
C                      IF P2.NE.1. DEFAULT IS L-SET SIZE        
C        
C                 IF P2.NE.1, AND ONE OR BOTH OF THE SETS REQUESTED IN  
C                 P3 AND P4 DOES NOT EXIST, THEN MAT IS RETURNED PURGED,
C                 AND P5 IS RETURNED WITH THE VALUE OF -1. IF MAT DOES  
C                 EXISTS, P5 IS RETURNED WITH THE VALUE 0        
C        
 1100 WRITE  (NOUT,1200) UWM,P1        
 1200 FORMAT (A25,' FROM MATGEN MODULE, OPTION',I3,' IS NOT AVAILABLE') 
      GO TO 1700        
C        
C     WRAP-UP AND RETURN TO EXECUTIVE SYSTEM        
C        
 1400 CALL CLOSE  (OUT,1)        
      CALL WRTTRL (MCB)        
      GO TO 1700        
C        
C     ERROR MESSAGES        
C        
 1500 CONTINUE        
      LCOR = SYSBUF - LCOR        
      CALL MESAGE (-8,LCOR,NAM)        
      GO TO 1700        
C        
 1510 WRITE  (NOUT,1520) UFM,P1        
 1520 FORMAT (A23,' IN MATGEN, ILLEGAL VALUE FOR OPTION PARAMETER =',I5)
      GO TO 1690        
C        
 1530 WRITE  (NOUT,1540) UFM,IPX,PX        
 1540 FORMAT (A23,' IN MATGEN, ILLEGAL VALUE FOR PARAMETER ',I1,3H = ,  
     1        I5)        
C        
 1550 J = -1        
      GO TO 1570        
 1560 J = -2        
 1570 CALL MESAGE (J,T,NAM)        
C        
 1580 WRITE  (NOUT,1590) UFM,P1        
 1590 FORMAT (A23,'. OPTION',I3,' OUTPUT DATA BLOCK IS MISSING')        
      P1 = -1        
      GO TO  1700        
 1600 WRITE  (NOUT,1610) UFM,TMP(1),TMP(2)        
 1610 FORMAT (A23,'. OPTION 9. INPUT FILE IS ',2A4,', NOT EQEXIN')      
      GO TO  1690        
 1620 WRITE  (NOUT,1630) UFM,L,NVAL        
 1630 FORMAT (A23,'. EQEXIN RECORD LENGTH NOT MATCH TWICE TRAIL(2)',2I9)
      GO TO  1690        
 1640 WRITE  (NOUT,1650) UFM,NUSET,TOT        
 1650 FORMAT (A23,'. OPTION 9, LUSET OF',I9,' DOES NOT AGREE WITH SIZE',
     1       ' OF EQEXIN',I9)        
 1690 CALL MESAGE (-61,0,NAM)        
 1700 RETURN        
      END        
