      SUBROUTINE MXCID (*,Z,MSET,MSZE,NWDS,USET,GPL,SIL,BUF1)        
C        
C     THIS SUBROUTINE CREATES AN ARRAY AT Z(1) OF LENGTH MSZE*NWDS      
C     WHICH CONTAINS THE EXTERNAL ID*10 + COMPONENT AT Z(1,M) FOR       
C     EACH DEGREE OF FREEDOM BELONGING TO SET -MSET-.        
C        
C     OPEN CORE IS Z(1) TO Z(BUF1-1).   TWO  BUFFERS NEEDED.        
C        
C     NONSTANDARD RETURN IF TASK NOT COMPLETED.        
C        
C     IF THIS IS A SUBSTRUCTURING PROBLEM, MXCIDS SHOULD BE CALLED      
C     INSTEAD        
C        
      IMPLICIT INTEGER (A-Z)        
      EXTERNAL        LSHIFT,ANDF,ORF        
      INTEGER         FNAM(2),NAME(2),X(7),Z(1)        
      CHARACTER       UFM*23,UWM*25,UIM*29,SFM*25,SWM*27        
      COMMON /XMSSG / UFM,UWM,UIM,SFM,SWM        
      COMMON /SYSTEM/ NBUFSZ,KOUTP        
      COMMON /NAMES / KRD,KRDRW,KWR,KWRRW, KCLRW,KCL,KWEOF        
      COMMON /BITPOS/ MASK2(32),HSET(32)        
      COMMON /TWO   / ITWO(32)        
      DATA    NSET  / 20   /        
      DATA    NAME  , NONE / 4HMXCI,4HD   , 4H (NO  /        
C        
C     ALLOCATE CORE - CHECK DATA FILE AVAILABILITY        
C        
      BUF2 = BUF1 + NBUFSZ        
      IF (NWDS .LE. 0) NWDS = 1        
      LGP  = MSZE*NWDS + 1        
      X(1) = SIL        
      CALL FNAME (SIL,FNAM)        
      IF (FNAM(1) .EQ. NONE) GO TO 220        
      CALL RDTRL (X)        
      NGP = X(2)        
      LSIL= LGP + NGP        
C        
C     SEVEN WORDS NEEDED IF SIL AND USET OUT OF CORE        
C        
      IF (LSIL .GT. BUF1-7) GO TO 260        
C        
C     DETERMINE IF SIL (AND USET) FIT IN CORE        
C        
      LUSET = LSIL + NGP        
      X(1)  = USET        
      CALL FNAME (USET,FNAM)        
      IF (FNAM(1) .EQ. NONE) GO TO 220        
      CALL RDTRL (X)        
      NDOF = X(3)        
      L = ORF(LSHIFT(X(4),16),X(5))        
C        
      IF (LUSET+NDOF .GT. BUF1) LUSET = 0        
      IF (LUSET .GT. BUF1) LSIL = 0        
C        
C     CHECK SET REQUEST        
C        
      DO 10 ISET = 1,NSET        
      IF (HSET(ISET) .EQ. MSET) GO TO 20        
   10 CONTINUE        
       GO TO 240        
   20 CONTINUE        
      ISET = MASK2(ISET)        
      ISET = ITWO(ISET)        
      IF (ANDF(L,ISET) .EQ. 0) GO TO 240        
C        
C     LOAD GPL INTO CORE        
C        
      X(1) = GPL        
      CALL OPEN (*220,GPL,Z(BUF2),KRDRW)        
      CALL FREAD (GPL,0,0,1)        
      CALL FREAD (GPL,Z(LGP),NGP,0)        
      CALL CLOSE (GPL,KCL)        
      X(1) = SIL        
      CALL GOPEN (SIL,Z(BUF1),KRDRW)        
      CALL GOPEN (USET,Z(BUF2),KRDRW)        
C        
C     LOAD SIL AND USET IF POSSIBLE        
C        
      IF (LSIL .EQ. 0) GO TO 30        
      CALL FREAD (SIL,Z(LSIL),NGP,0)        
      CALL CLOSE (SIL,KCL)        
      SIL1 = Z(LSIL)        
      PSIL = LSIL + 1        
      I = NGP - 1        
      GO TO 40        
   30 CALL FREAD (SIL,SIL1,1,0)        
      I = 1        
      PSIL = LGP + NGP        
   40 IF (LUSET .EQ. 0) GO TO 50        
      CALL FREAD (USET,Z(LUSET),NDOF,0)        
      CALL CLOSE (USET,KCL)        
      PUSET = LUSET        
   50 IF (LUSET .EQ. 0) PUSET = PSIL + I        
C        
C     PSIL POINTS SECOND SIL ENTRY IF SIL IN CORE, ELSE LOCATION TO USE 
C     PUSET POINTS TO FIRST WORD USET, ELSE LOCATION IN Z TO USE        
C     LSIL, LUSET ARE ZERO IF FILES NOT IN CORE.        
C     LOOP ON NUMBER GRID POINTS - EXIT WHEN MSIZE ACHIEVED.        
C        
      MCOUNT = 1        
C        
      DO  130 LLL = 1,NGP        
      IF (LLL .EQ. NGP) GO TO 60        
      IF (LSIL.NE.   0) GO TO 70        
      CALL FREAD (SIL,Z(PSIL),1,0)        
      GO TO 70        
   60 SIL2 = NDOF + 1        
      GO TO 80        
   70 SIL2 = Z(PSIL)        
      IF (LSIL .NE. 0) PSIL = PSIL + 1        
   80 NDF = SIL2 - SIL1        
      IF (NDF.LT.1 .OR. NDF.GT.6) GO TO 240        
C        
C     GET NDF WORDS FROM USET        
C        
      IF (LUSET .EQ. 0) CALL FREAD (USET,Z(PUSET),NDF,0)        
C        
C     DETERMINE IF IN THE SET        
C        
      J = PUSET        
      K = J + NDF - 1        
  100 CONTINUE        
      DO 110 I = J,K        
      IF (ANDF(Z(I),ISET) .NE. 0) GO TO 120        
  110 CONTINUE        
       GO TO 125        
C        
C     LOCATED A POINT IN THE SET        
C        
  120 CONTINUE        
      LL = I - PUSET + 1        
      L  = LGP + LLL - 1        
      IF (NDF .EQ. 1) LL = 0        
      Z(MCOUNT) = Z(L)*10 + LL        
      MCOUNT = MCOUNT + NWDS        
      IF (MCOUNT .GE. LGP) GO TO 310        
      IF (I .EQ. K) GO TO 125        
      J = I + 1        
       GO TO 100        
  125 IF (LUSET .NE. 0) PUSET = PUSET + NDF        
      SIL1 = SIL2        
  130 CONTINUE        
C        
C     END OF ALL GRIDS AND MATRIX NOT FILLED - NEED IMMEDIATE MESSAGE.  
C        
      CALL PAGE2 (2)        
      WRITE  (KOUTP,210) SWM,NAME        
  210 FORMAT (A27,' 3016, MATRIX IS NOT IN PROPER FORM IN SUBROUTINE ', 
     1        2A4)        
      GO TO 300        
C        
C     PURGED FILES        
C        
  220 CALL PAGE2 (2)        
      WRITE  (KOUTP,230) SWM,X(1),NAME        
  230 FORMAT (A27,' 3001, ATTEMPT TO OPEN DATA SET',I4,' IN SUBROUTINE',
     1        1X,2A4,' WHICH WAS NOT DEFINED IN FIST')        
      GO TO 300        
C        
C     ILLEGAL INPUT        
C        
  240 CALL PAGE2 (2)        
      WRITE  (KOUTP,250) SWM,NAME        
  250 FORMAT (A27,' 3007, ILLEGAL INPUT TO SUBROUTINE ',2A4)        
      GO TO 300        
C        
C     INSUFFICIENT CORE        
C        
  260 CALL PAGE2 (2)        
      WRITE  (KOUTP,270) SWM,NAME        
  270 FORMAT (A27,' 3008, INSUFFICIENT CORE AVAILABLE FOR SUBROUTINE ', 
     1        2A4, 1H.)        
C        
  300 CONTINUE        
      CALL CLOSE (SIL ,KCL)        
      CALL CLOSE (USET,KCL)        
      RETURN 1        
  310 CONTINUE        
      CALL CLOSE (SIL ,KCL)        
      CALL CLOSE (USET,KCL)        
      RETURN        
      END        