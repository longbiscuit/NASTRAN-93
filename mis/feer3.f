      SUBROUTINE FEER3        
C                                                               T       
C     FEER3 OBTAINS THE REDUCED TRIDIAGONAL MATRIX   (LI)*M*(LI)        
C     WHERE M IS A SYMETRIC MATRIX AND L IS LOWER TRIANGULAR, AND (LI)  
C     IS INVERSE OF L        
C        
C     THE TRANSFORMATION IS ALPHA = VT(L**(-1)M (L**-(1))TV        
C     WHERE V IS A RECTANGULAR TRANSFORMATION.        
C        
C     LAST REVISED 11/91 BY G.CHAN/UNISYS, MAKE ROOM FOR NEW FBS METHOD 
C        
      INTEGER            SYSBUF    ,CNDFLG   ,MCBSCL(7),SR5FLE   ,      
     1                   SR6FLE    ,SR7FLE   ,SR8FLE   ,SR9FLE   ,      
     2                   SR10FL    ,SRXFLE   ,IZ(1)    ,NAME(2)  ,      
     3                   DASHQ     ,OPTN2        
      DOUBLE PRECISION   LAMBDA    ,LMBDA    ,DZ(1)    ,DSQ        
      COMMON   /FEERCX/  IFKAA(7)  ,IFMAA(7) ,IFLELM(7),IFLVEC(7),      
     1                   SR1FLE    ,SR2FLE   ,SR3FLE   ,SR4FLE   ,      
     2                   SR5FLE    ,SR6FLE   ,SR7FLE   ,SR8FLE   ,      
     3                   DMPFLE    ,NORD     ,XLMBDA   ,NEIG     ,      
     4                   MORD      ,IBK      ,CRITF    ,NORTHO   ,      
     5                   IFLRVA    ,IFLRVC        
      COMMON   /FEERXX/  LAMBDA    ,CNDFLG   ,ITER     ,TIMED    ,      
     1                   L16       ,IOPTF    ,EPX      ,NOCHNG   ,      
     2                   IND       ,LMBDA    ,IFSET    ,NZERO    ,      
     3                   NONUL     ,IDIAG    ,MRANK    ,ISTART   ,      
     4                   NZV5        
      COMMON   /REIGKR/  OPTION    ,OPTN2        
      COMMON   /TYPE  /  RC(2)     ,IWORDS(4)        
CZZ   COMMON   /ZZFER3/  Z(1)        
      COMMON   /ZZZZZZ/  Z(1)        
      COMMON   /SYSTEM/  SYSBUF    ,IO       ,SYSTM(52),IPREC    ,      
     1                   SKIP36(38),KSYS94        
      COMMON   /OPINV /  MCBLT(7)  ,MCBSMA(7),MCBVEC(7),MCBRM(7)        
      COMMON   /UNPAKX/  IPRC      ,II       ,NN       ,INCR        
      COMMON   /PACKX /  ITP1      ,ITP2     ,IIP      ,NNP      ,      
     1                   INCRP        
      COMMON   /NAMES /  RD        ,RDREW    ,WRT      ,WRTREW   ,      
     1                   REW       ,NOREW    ,EOFNRW        
      EQUIVALENCE        (IZ(1),Z(1),DZ(1))        
      DATA      NAME  /  4HFEER,4H3   /      ,DASHQ    / 4H-Q    /      
C        
C     SR5FLE CONTAINS THE TRIDIAGONAL ELEMENTS        
C     SR6FLE CONTAINS THE G VECTORS        
C     SR7FLE CONTAINS THE ORTHOGONAL VECTORS        
C     SR8FLE CONTAINS THE CONDITIONED MAA OR KAAD MATRIX        
C     SR9FLE CONTAINS MCBSMA DATA IN UNPACKED FORM = 309        
C     SR10FL CONTAINS MCBLT  DATA IN UNPACKED FORM = 310        
C                                              (OR = 308 IF IT IS FREE) 
C     IFLVEC CONTAINS THE L OR C MATRIX FROM SDCOMP        
C     IFLELM CONTAINS     KAA+ALPHA*MAA        
C     IFLRVC CONTAINS THE RESTART AND/OR RIGID BODY VECTORS        
C        
      SR9FLE = 309        
      SR10FL = 308        
      IPRC   = MCBLT(5)        
      NWDS   = IWORDS(IPRC)        
      NZ     = KORSZ(Z)        
      CALL MAKMCB (MCBVEC(1),SR7FLE,NORD,2,IPRC)        
      MCBVEC(2) = 0        
      MCBVEC(6) = 0        
      CALL MAKMCB (MCBRM(1) ,SR6FLE,MORD,2,IPRC)        
      MCBRM(2)  = 0        
      MCBRM(6)  = 0        
      MCBSCL(1) = IFLRVC        
      CALL RDTRL (MCBSCL(1))        
C        
C     INITIALIZE ALLOCATIONS        
C        
      IBUF1 = NZ    - SYSBUF        
      IBUF2 = IBUF1 - SYSBUF        
      IBUF3 = IBUF2 - SYSBUF        
      IBUF4 = IBUF3 - SYSBUF        
      IV1   = 1        
      IV2   = IV1 + NORD        
      IV3   = IV2 + NORD        
      IV4   = IV3 + NORD        
      IV5   = IV4 + NORD        
      NZV5  = IBUF4 - IV5*NWDS - 2        
      IX2   = IV2 - 1        
      IEND  = NWDS*(5*NORD + 1) + 2        
      ICRQ  = IEND - IBUF4        
      IF (ICRQ .GT. 0) CALL MESAGE (-8,ICRQ,NAME)        
      IFL   = MCBLT(1)        
      SRXFLE= SR8FLE        
C        
C     CALL UNPSCR TO MOVE MCBSMA DATA INTO SR9FLE, AND MCBLT INTO SR10FL
C     (ORIGINAL MCBSMA AND MCBLT TRAILER WORDS 4,5,6,7 WILL BE CHANGED) 
C     NZV5 IS THE AVAILABE SIZE OF THE WORKING SPACE FOR NEW FBS METHOD 
C     USED IN FRSW/2, FRBK/2, FRMLT/D, AND FRMLTX/A ROUTINES        
C        
C     IF KSYS94 IS 10000 OR DIAG 41 IS ON, NEW FBS METHODS AND UNPSCR   
C     ARE NOT USED        
C        
      IF (MOD(KSYS94,100000)/10000 .EQ. 1) GO TO 10        
      CALL SSWTCH (41,I)        
      IF (I .EQ. 1) GO TO 10        
      SRXFLE = SR9FLE        
      CALL UNPSCR (MCBSMA,SRXFLE,Z,IBUF2,IBUF1,NZV5,0,1)        
      J = 2        
      IF (IOPTF .EQ. 1) J = 3        
      CALL UNPSCR (MCBLT,SR10FL,Z,IBUF2,IBUF1,NZV5,0,J)        
      NZV5 = NZV5 + 1        
      IFL  = SR10FL        
C        
   10 CALL GOPEN (IFL,Z(IBUF3),RDREW)        
      CALL GOPEN (SR7FLE,Z(IBUF1),WRTREW)        
      IF (NORTHO .EQ. 0) GO TO 130        
C        
C     LOAD RESTART AND/OR RIGID BODY VECTORS        
C        
      CALL GOPEN (IFLRVC,Z(IBUF2),RDREW)        
      INCR  = 1        
      INCRP = 1        
      ITP1  = IPRC        
      ITP2  = IPRC        
C        
      DO 110 J = 1,NORTHO        
      II  = 1        
      NN  = NORD        
      CALL UNPACK (*110,IFLRVC,DZ(1))        
      IIP = II        
      NNP = NN        
      IF (IPRC  .EQ. 1) GO TO 60        
      IF (IOPTF .EQ. 0) GO TO 40        
      DSQ = 0.D0        
      CALL FRMLTX (MCBLT(1),DZ(IV1),DZ(IV2),DZ(IV3))        
      DO 20 IJ = 1,NORD        
   20 DSQ = DSQ + DZ(IX2+IJ)**2        
      DSQ = 1.D0/DSQRT(DSQ)        
      DO 30 IJ = 1,NORD        
   30 DZ(IJ) = DSQ*DZ(IX2+IJ)        
   40 IF (L16 .EQ. 0) GO TO 100        
      CALL PAGE2 (2)        
      WRITE (IO,50) IIP,NNP,(DZ(I),I=1,NORD)        
   50 FORMAT (10H ORTH VCT ,2I5,  /(1X,8E16.8))        
      GO TO 100        
   60 IF (IOPTF .EQ. 0) GO TO 90        
      SQ = 0.0        
      CALL FRMLTA (MCBLT(1),Z(IV1),Z(IV2),Z(IV3))        
      DO 70 IJ = 1,NORD        
   70 SQ = SQ + Z(IX2+IJ)**2        
      SQ = 1.0/SQRT(SQ)        
      DO 80 IJ = 1,NORD        
   80 Z(IJ) = SQ*Z(IX2+IJ)        
   90 IF (L16 .EQ. 0) GO TO 100        
      CALL PAGE2 (2)        
      WRITE (IO,50) IIP,NNP,(Z(I),I=1,NORD)        
  100 CALL PACK (DZ(1),SR7FLE,MCBVEC(1))        
  110 CONTINUE        
C        
      CALL CLOSE (IFLRVC,NOREW)        
      IF (L16 .EQ. 0) GO TO 130        
      CALL PAGE2 (1)        
      WRITE  (IO,120) NORTHO,MCBVEC        
  120 FORMAT (5X,I5,16H ORTH VECTORS ON,I5,5H FILE,5I5,I14)        
  130 K = NORTHO        
      CALL CLOSE (SR7FLE,NOREW)        
      J = K        
      NONUL = 0        
      ITER  = 0        
      CALL GOPEN (SR6FLE,Z(IBUF4),WRTREW)        
      CALL CLOSE (SR6FLE,NOREW)        
      CALL GOPEN (SRXFLE,Z(IBUF2),RDREW)        
      CALL GOPEN (SR5FLE,Z(IBUF4),WRTREW)        
C        
C     GENERATE SEED VECTOR        
C        
  140 K = K + 1        
      J = K        
      IFN = 0        
C        
C     GENERATE SEED VECTOR FOR LANCZOS        
C        
      SS = 1.0        
      IF (IPRC .EQ. 1) GO TO 160        
      DO 150 I = 1,NORD        
      SS =-SS        
      J  = J + 1        
      DSQ = FLOAT(MOD(J,3)+1)/(3.0*FLOAT((MOD(J,13)+1)*(1+5*I/NORD)))   
  150 DZ(IX2+I) = DSQ*SS        
      IF (OPTN2 .NE. DASHQ) CALL FNXTVC (DZ(IV1),DZ(IV2),DZ(IV3),       
     1                                   DZ(IV4),DZ(IV5),Z(IBUF1),IFN)  
      IF (OPTN2 .EQ. DASHQ) CALL FNXTVQ (DZ(IV1),DZ(IV2),DZ(IV3),       
     1                                   DZ(IV4),DZ(IV5),Z(IBUF1),IFN)  
      GO TO 180        
C        
  160 DO 170 I = 1,NORD        
      SS =-SS        
      J  = J + 1        
      SQ = FLOAT(MOD(J,3)+1)/(3.0*FLOAT((MOD(J,13)+1)*(1+5*I/NORD)))    
  170 Z(IX2+I) = SQ*SS        
      IF (OPTN2 .NE. DASHQ) CALL FNXTV  (Z(IV1),Z(IV2),Z(IV3),Z(IV4),   
     1                                   Z(IV5),Z(IBUF1),IFN)        
      IF (OPTN2 .EQ. DASHQ) CALL FNXTVD (Z(IV1),Z(IV2),Z(IV3),Z(IV4),   
     1                                   Z(IV5),Z(IBUF1),IFN)        
C        
  180 IF (ITER .LE. MORD) GO TO 190        
      MORD = NORTHO - NZERO        
      CNDFLG = 3        
      GO TO 200        
C        
  190 IF (IFN .LT. MORD) GO TO 140        
  200 CALL CLOSE (SR5FLE,NOREW)        
      CALL CLOSE (SRXFLE,REW)        
      CALL CLOSE (IFL,REW)        
C        
C     IF NEW FBS METHOD IS USED, SR9FLE AND SR10FL FILES COULD BE VERY  
C     BIG. MAKE SURE THEY ARE PHYSICALLY REDUCED TO ZERO SIZE. THIS IS  
C     IMPORTANT FOR A COMPUTER SYSTEM WITH LIMITED DISC SPACE        
C        
      IF (IFL .NE. SR10FL) GO TO 210        
      CALL GOPEN (SR9FLE,Z(IBUF2),WRTREW)        
      CALL GOPEN (SR10FL,Z(IBUF3),WRTREW)        
      CALL CLOSE (SR9FLE,REW)        
      CALL CLOSE (SR10FL,REW)        
C        
  210 IF (L16 .EQ. 0) RETURN        
      CALL PAGE2 (1)        
      I = IBUF4 - NORTHO*NORD*NWDS - 2        
      IF (I .LT.  0) I = IBUF4 - IEND        
      WRITE  (IO,220) I,NAME        
  220 FORMAT (19H OPEN CORE NOT USED,I10,2X,2A4)        
C        
      RETURN        
      END        
