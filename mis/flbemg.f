      SUBROUTINE FLBEMG        
C        
C     GENERATES ELEMENT AREA FACTOR AND GRAVITIATIONAL STIFFNESS        
C     MATRICES        
C        
      INTEGER       GEOM2    ,ECT      ,BGPDT    ,SIL      ,MPT        
     1             ,GEOM3    ,CSTM     ,USET     ,EQEXIN   ,USETF       
     2             ,USETS    ,AF       ,DKGG     ,FBELM    ,FRELM       
     3             ,CONECT   ,AFMAT    ,AFDICT   ,KGMAT    ,KGDICT      
     4             ,Z        ,GRAV(2)  ,POS      ,FRREC(7) ,FBREC(12)   
     5             ,FILE     ,NAME(2)  ,DICT(2)        
C        
      LOGICAL       ERROR    ,NOCARD        
C        
      DOUBLE PRECISION        AFE(48)  ,KGE(144)        
C        
C     GINO FILES        
C        
      COMMON / FLBFIL /       GEOM2    ,ECT      ,BGPDT    ,SIL        
     1                       ,MPT      ,GEOM3    ,CSTM     ,USET        
     2                       ,EQEXIN   ,USETF    ,USETS    ,AF        
     3                       ,DKGG     ,FBELM    ,FRELM    ,CONECT      
     4                       ,AFMAT    ,AFDICT   ,KGMAT    ,KGDICT      
C        
C     OPEN CORE        
C        
CZZ   COMMON / ZZFLB1 /       Z(1)        
      COMMON / ZZZZZZ /       Z(1)        
C        
C     CORE POINTERS        
C        
      COMMON / FLBPTR /       ERROR    ,ICORE    ,LCORE    ,IBGPDT      
     1                       ,NBGPDT   ,ISIL     ,NSIL     ,IGRAV       
     2                       ,NGRAV    ,IGRID    ,NGRID    ,IBUF1       
     3                       ,IBUF2    ,IBUF3    ,IBUF4    ,IBUF5       
C        
C     MODULE PARAMETERS        
C        
      COMMON /BLANK/     NOGRAV   ,NOFREE   ,TILT(2)        
C        
      DATA NAME / 4HFLBE,4HMG   /        
      DATA GRAV / 4401 , 44 /        
C        
C***********************************************************************
C        
C     READ MATERIAL PROPERTY DATA INTO CORE        
C        
      IMAT = ICORE        
      NZ = IBUF5 - IMAT        
      CALL PREMAT(Z(IMAT),Z(IMAT),Z(IBUF1),NZ,NMAT,MPT,0)        
C        
C     READ CSTM DATA INTO CORE        
C        
      ICSTM = IMAT + NMAT        
      NCSTM = 0        
      NZ = IBUF5 - ICSTM        
      FILE = CSTM        
      CALL OPEN(*20,CSTM,Z(IBUF1),0)        
      CALL FWDREC(*1002,CSTM)        
      CALL READ(*1002,*10,CSTM,Z(ICSTM),NZ,0,NCSTM)        
      GO TO 1008        
   10 CALL CLOSE(CSTM,1)        
      CALL PRETRD(Z(ICSTM),NCSTM)        
C        
C     READ GRAV DATA INTO CORE        
C        
   20 IGRAV = ICSTM + NCSTM        
      NGRAV = 0        
      NZ = IBUF5 - IGRAV        
      NOGRAV = -1        
      NOCARD = .TRUE.        
      FILE = GEOM3        
      CALL PRELOC(*40,Z(IBUF1),GEOM3)        
      CALL LOCATE(*30,Z(IBUF1),GRAV,ID)        
      NOCARD = .FALSE.        
      CALL READ(*1002,*30,GEOM3,Z(IGRAV),NZ,0,NGRAV)        
      GO TO 1008        
C        
   30 CALL CLOSE(GEOM3,1)        
   40 CONTINUE        
C        
C     OPEN MATRIX AND DICTIONARY FILES        
C        
      CALL GOPEN(AFMAT,Z(IBUF2),1)        
      CALL GOPEN(AFDICT,Z(IBUF4),1)        
      IF(NOCARD) GO TO 60        
      CALL GOPEN(KGMAT,Z(IBUF3),1)        
      CALL GOPEN(KGDICT,Z(IBUF5),1)        
C        
C        
C     PASS THROUGH FBELM FILE AND PROCESS EACH ENTRY ON THE BOUNDARY.   
C     SUBROUTINE BOUND WILL GENERATE THE ELEMENT MATRICES FOR        
C     EACH ENTRY.        
C        
   60 FILE = FBELM        
      CALL GOPEN(FBELM,Z(IBUF1),0)        
   70 CALL READ(*1002,*120,FBELM,FBREC,12,0,N)        
C        
      CALL BOUND(FBREC,AFE,NAFE,KGE,NKGE)        
      IF(ERROR) GO TO 70        
C        
C     CONVERT GRID POINTS TO SILS        
C        
      DO 80 I=1,4        
      J = FBREC(I+2) - 1        
      IF(J .GE. 0) FBREC(I+2) = Z(ISIL+J)        
      J = FBREC(I+8) - 1        
      IF(J .GE. 0) FBREC(I+8) = Z(ISIL+J)        
   80 CONTINUE        
C        
C     WRITE AREA MATRICES AND DICTIONARY ENTRUES        
C        
      CALL WRITE(AFMAT,FBREC(3),4,0)        
      CALL WRITE(AFMAT,FBREC(9),4,0)        
      CALL WRITE(AFMAT,AFE,NAFE,1)        
      CALL SAVPOS(AFMAT,POS)        
      DICT(2) = POS        
      DO 90 I=1,4        
      DICT(1) = FBREC(I+8)        
      IF(DICT(1) .LT. 0) GO TO 90        
      CALL WRITE(AFDICT,DICT,2,0)        
   90 CONTINUE        
C        
C     WRITE GRAVITATIONAL STIFFNESS MATRICES IF THEY EXIST        
C        
      IF(NKGE .EQ. 0) GO TO 70        
      CALL WRITE(KGMAT,FBREC(3),4,0)        
      CALL WRITE(KGMAT,FBREC(3),4,0)        
      CALL WRITE(KGMAT,KGE,NKGE,1)        
      CALL SAVPOS(KGMAT,POS)        
      DICT(2) = POS        
      DO 110 I=1,4        
      JSIL = FBREC(I+2)        
      IF(JSIL .LT. 0) GO TO 110        
      DO 100 J=1,3        
      DICT(1) = JSIL        
      CALL WRITE(KGDICT,DICT,2,0)        
  100 JSIL = JSIL + 1        
  110 CONTINUE        
C        
      GO TO 70        
  120 CALL CLOSE(FBELM,1)        
C        
C        
C     PASS THROUGH FRELM FILE AND PROCESS EACH ENTRY ON THE FREE        
C     SURFACE.  SUBROUTINE FLFREE WILL CALCULATE THE AREA AND        
C     GRAVITATIONAL STIFFNESS MATRICES FOR EACH ENTRY        
C        
      IF(NOFREE .LT. 0) GO TO 180        
      FILE = FRELM        
      CALL GOPEN(FRELM,Z(IBUF1),0)        
  130 CALL READ(*1002,*170,FRELM,FRREC,7,0,N)        
C        
      CALL FLFREE(FRREC,AFE,NAFE,KGE,NKGE)        
      IF(ERROR) GO TO 130        
C        
C     CONVERT GRID POINTS TO SILS        
C        
      DO 140 I=1,4        
      J = FRREC(I+2) - 1        
      IF(J .GE. 0) FRREC(I+2) = Z(ISIL+J)        
  140 CONTINUE        
C        
C     WRITE AREA MATRICES AND DICTIONARY ENTRIES        
C        
      CALL WRITE(AFMAT,FRREC(3),4,0)        
      CALL WRITE(AFMAT,FRREC(3),4,0)        
      CALL WRITE(AFMAT,AFE,NAFE,1)        
      CALL SAVPOS(AFMAT,POS)        
      DICT(2) = POS        
      DO 150 I=1,4        
      DICT(1) = FRREC(I+2)        
      IF(DICT(1) .LT. 0) GO TO 150        
      CALL WRITE(AFDICT,DICT,2,0)        
  150 CONTINUE        
C        
C     WRITE GRAVITATIONAL STIFFNESS MATRICES IF THEY EXIST        
C        
      IF(NKGE .EQ. 0) GO TO 130        
      CALL WRITE(KGMAT,FRREC(3),4,0)        
      CALL WRITE(KGMAT,FRREC(3),4,0)        
      CALL WRITE(KGMAT,KGE,NKGE,1)        
      CALL SAVPOS(KGMAT,POS)        
      DICT(2) = POS        
      DO 160 I=1,4        
      DICT(1) = FRREC(I+2)        
      IF(DICT(1) .LT. 0) GO TO 160        
      CALL WRITE(KGDICT,DICT,2,0)        
  160 CONTINUE        
C        
      GO TO 130        
  170 CALL CLOSE(FRELM,1)        
C        
C     CLOSE FILES AND RETURN        
C        
  180 CALL CLOSE(AFMAT,1)        
      CALL CLOSE(AFDICT,1)        
      IF(NOCARD) GO TO 190        
      CALL CLOSE(KGMAT,1)        
      CALL CLOSE(KGDICT,1)        
C        
  190 CONTINUE        
      RETURN        
C        
C     ERROR CONDITIONS        
C        
 1002 N = -2        
      GO TO 1100        
 1008 N = -8        
 1100 CALL MESAGE(N,FILE,NAME)        
      RETURN        
      END        
