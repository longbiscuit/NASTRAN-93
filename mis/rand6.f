      SUBROUTINE RAND6(XYCB,BUFFER,NPOINT,IZ,INPUT,LCORE)        
C        
C     ANALYSIS OF REQUESTS AND BUILDS LIST        
C        
      INTEGER XYCB,BUFFER(1),IZ(1),FILE,NAME(2),ILIST(6),PSDF,AUTO,        
     1  ITYPE(13,5)        
      DATA NAME,PSDF,AUTO/4HRAND,4H6   ,2,3/        
      DATA ITYPE /        
     1    13,4HDISP,1,4HVELO,2,4HACCE,3,4HDISP,8,4HVELO,9,4HACCE,10,        
     2     3,4HLOAD,5,           10*0,        
     3     3,4HSPCF,4,           10*0,        
     4     3,4HSTRE,6,           10*0,        
     5     3,4HELFO,7,           10*0 /        
C *****        
C     XYCB     XY OUTPUT REQUESTS        
C     BUFFER   SYSTEM BUFFER        
C     NPOINT   NUMBER OF POINTS REQUESTED FOR THIS FILE        
C     IZ       LIST OF REQUESTS        
C     INPUT    CURRENT FILE        
C     ILIST    LIST OF REQUEST FROM XYCB   6  WORDS PER        
C     SUBC,FILE,ID,COMP,OPER,DEST        
C     PSDF     KEY FOR POWER SPECTRAL DENSITY FUNCTION        
C     AUTO     KEY FOR AUTOCORRELATION FUNCTION        
C     ITYPE    LIST OF DATA TYPES ON EACH INPUT FILE        
C     IREQ     PSDF =1 , AUTO =2  BOTH = 3        
C     IP       POINTER INTO  IZ  FOR LAST POINT(SAME POINT MAY OCCUR        
C                MANY TIMES IN XYCB        
C        
C     LIST FORMAT        
C     FILE,ID,COMP,IREQ,DEST        
C        
C        
C        
C        
C        
C        
C     FIND  ACCEPTABLE MNEUMONICS        
C        
      K = INPUT -103        
      NTYPE =  ITYPE(1,K)        
      IP =-4        
      NPOINT = 0        
C        
C     OPEN XYCB        
C        
      FILE =XYCB        
      CALL OPEN(*90,XYCB,BUFFER(1),0)        
      CALL FWDREC(*910,XYCB)        
C        
C     SKIP PROSE RECORD        
C        
      CALL FWDREC(*40,XYCB)        
C        
C     READ DATA RECORD 6 WORDS AT A TIME        
C        
    5 CALL READ(*40,*40,XYCB,ILIST(1),6,0,I)        
C        
C     IS DATA BLOCK PROPER        
C        
      DO 10 I=2, NTYPE,2        
      IF(ILIST(2) .EQ. ITYPE(I+1,K)) GO TO 20        
   10 CONTINUE        
C        
C     GO TO NEXT REQUEST        
C        
      GO TO 5        
C        
C     CHECK FOR RANDOM REQUEST        
C        
   20 IF(ILIST(5) .EQ. PSDF) GO TO 25        
      IF(ILIST(5) .EQ. AUTO) GO TO 30        
      GO TO 5        
C     PSDF REQUEST        
C        
   25 IREQ =1        
      GO TO 31        
C        
C     AUTOCORRELATION REQUEST        
C        
   30 IREQ =2        
C        
C     STORE  IN LIST        
C        
   31 IF(NPOINT .EQ. 0) GO TO 35        
C        
C     IS THIS A NEW POINT        
C        
      IF(IZ(IP) .NE. ITYPE(I,K)) GO TO 35        
      IF(IZ(IP+1) .NE. ILIST(3) .OR. IZ(IP+2) .NE. ILIST(4)) GO TO 35        
C        
C     ANOTHER REQUEST FOR SAME POINT        
C        
      IF( IZ(IP+3) .EQ. 3 .OR. IZ(IP+3) .EQ. IREQ) GO TO 32        
      IZ(IP+3) = IZ(IP+3) + IREQ        
   32 IF(IZ(IP+4) .EQ.  3  .OR. IZ(IP+4).EQ. ILIST(6))GO TO 5        
      IZ(IP+4) = IZ(IP+4) + ILIST(6)        
      GO TO 5        
C        
C     ADD POINT TO LIST        
C        
   35 NPOINT = NPOINT +1        
      IP = IP +5        
      IF (IP+5 .GT. LCORE) GO TO 905        
      IZ(IP) = ITYPE(I,K)        
      IZ(IP+1) = ILIST(3)        
      IZ(IP+2) = ILIST(4)        
      IZ(IP+3) = IREQ        
      IZ(IP+4) = ILIST(6)        
      GO TO 5        
C        
C     GET OUT        
C        
   40 CALL CLOSE(XYCB,1)        
C        
C     SAVE ORIGINAL COMPONENT IN THE FIFTH LIST LORD        
C        
      IF(NPOINT .EQ. 0) GO TO 90        
      DO 45 I = 1,NPOINT        
      L = (I-1)*5+1        
      IZ(L+4) = IZ(L+2)        
      IF(K .LT. 4) IZ(L+2) = IZ(L+2) -2        
   45 CONTINUE        
   90 RETURN        
C        
C     FILE ERRORS        
C        
  905 NPOINT = NPOINT+9        
      GO TO 90        
  910 IP1= -2        
  911 CALL MESAGE(IP1,FILE,NAME(1))        
      GO TO 911        
      END        
