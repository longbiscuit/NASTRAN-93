      SUBROUTINE XFLSZD (FILE,IBLOCK,FILNAM)        
C        
C     XFLSZD (EXECUTIVE FILE SIZE DETERMINATOR) ACCUMULATES THE        
C     NUMBER OF BLOCKS USED FOR A FILE (FILE LT 0) IN THE FIAT OR       
C     FOR A FILE (FILE GT 0) IN THE DATA POOL FILE.        
C     IF FILE GT 0 IT IS THE INDEX OF THE FILE ON THE DATA POOL FILE    
C     IF FILE = 0 THE NUMBER OF WORDS PER BLOCK IS RETURNED IN IBLOCK   
C        
      IMPLICIT INTEGER (A-Z)        
      EXTERNAL         RSHIFT,ANDF        
      COMMON / MACHIN/ MACH        
      COMMON / XFIAT / FIAT(1)        
      COMMON / XFIST / NFIST,LFIST,IFIST(1)        
      COMMON / GINOX / DUM1(11),DUM2(150),BLKSIZ        
      COMMON / XDPL  / POOL(1)        
      COMMON / SYSTEM/ KYSTEM        
C        
      DATA     MASK  / 32767 /        
C        
      IF (FILE) 10,150,100        
C        
C     FILE IS IN THE FIAT        
C        
C     COMMENTS FROM G.CHAN/UNIVAC 8/90        
C     VAX AND VAX-DERIVED MACHINES DO NOT SAVE ANY INFORMATION OF BLOCKS
C     USED IN FIAT 7TH AND 8TH WORDS. THEREFORE, IBLOCK IS ALWAYS ZERO. 
C        
   10 IF (MACH .GE. 5) GO TO 50        
C        
      LIM = 2*LFIST        
      DO 30 I = 1,LIM,2        
      IF (FILNAM .NE. IFIST(I)) GO TO 30        
      IF (IFIST(I+1)  .LE.   0) GO TO 50        
      INDX   = IFIST(I+1)        
      IBLOCK = RSHIFT(FIAT(INDX+7),16) + ANDF(MASK,FIAT(INDX+8)) +      
     1         RSHIFT(FIAT(INDX+8),16)        
C            = BLOCK COUNT ON PRIMARY, SECONDARY AND TERTIARY FILES ??  
C        
      GO TO 200        
   30 CONTINUE        
   50 IBLOCK = 0        
      GO TO 200        
C        
C     FILE IS ON THE DATA POOL FILE        
C        
  100 INDX   = FILE*3 + 3        
      IBLOCK = RSHIFT(POOL(INDX),16)        
      GO TO 200        
C        
C     USER WANTS THE NUMBER OF WORDS PER BLOCK        
C        
  150 IBLOCK = BLKSIZ        
      IF (MACH.EQ.2 .OR. MACH.GE.5) IBLOCK = KYSTEM - 4        
  200 RETURN        
      END        
