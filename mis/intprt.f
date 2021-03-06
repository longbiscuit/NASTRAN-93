      SUBROUTINE INTPRT (A,CR,O,NAME)        
C        
      INTEGER         O,CR,COLNUM,CRFMT(3),CROPT(2,2)        
      REAL            A(1),NAME(2)        
      COMMON /SYSTEM/ SKIP,MO        
      DATA    CRFMT / 4H(60X , 4H,2A4 , 4H,I5) /        
      DATA    CROPT / 4HCOLU , 4HMN   , 4HROW  , 4H     /        
C        
C     CR   = 0  IF MATRIX BY COLUMNS.        
C          = 1  IF MATRIX BY ROWS.        
C     IF O = 0, THE MATRIX WILL NOT BE PRINTED.        
C     NAME = 8  CHARACTER BCD NAME OF THE MATRIX.        
C        
      IF (CR .NE. 0) GO TO 100        
      ICROPT = 1        
      GO TO 110        
  100 ICROPT = 2        
C        
  110 CALL MATPRT (*120,*130,A,-1,COLNUM)        
      GO TO 150        
  120 WRITE  (MO,125) NAME(1),NAME(2)        
  125 FORMAT (50X,24HINTERMEDIATE MATRIX ... ,2A4//)        
  130 WRITE  (MO,CRFMT) (CROPT(I,ICROPT),I=1,2),COLNUM        
      CALL PRTMAT (*120,*130,COLNUM)        
  150 RETURN        
C        
      END        
