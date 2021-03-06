      SUBROUTINE OFSPLT (*,ESYM,ELID,G,OFFSET,X,DEFORM,GPLST)        
C        
C     CALLED ONLY BY LINEL TO PRCESS ELEMENT OFFSET PLOT        
C     THIS ROUTINE DRAW THE CBAR, CTRIA3, AND CQUAD4, WITH OFFSET IN    
C     PLACE.        
C        
C     INPUT:        
C         ESYM   = BCD, SHOULD BE 'BR', 'T3', OR 'Q4'                BCD
C         ELID   = ELEMENT ID                                         I 
C         G      = SIL LIST                                           I 
C         OFFSET = 6 COORDINATES (GLOBAL) FOR CBAR,                   I 
C                = 1 OFFSET, NORMAL TO PLATE, FOR CTRIA3 OR CQUAD4      
C         X      = GRID POINT COORDINATE, ALREADY CONVERTED TO SCREEN   
C                  (X-Y) COORDINATES                                  R 
C         DEFORM = 0, FOR UNDEFORM PLOT,  .NE.0 FOR DEFORMED OR BOTH  I 
C                  THIS ROUTINE WILL NOT PROCESS DEFORMED-OFFSET PLOT   
C         OFFSCL = OFFSET MULTIPLICATION FACTOR                       I 
C         PEDGE  = OFFSET PLOT FLAG                                   I 
C                = 3, PLOT OFFSET ELEMENTS ONLY, SKIP OTHER ELEMNETS    
C            NOT = 3, PLOT OFFSET ELEMENTS, RETURN TO PLOT OTHERS       
C         PLABEL = FLAG FOR ELEM ID LABEL                             I 
C         PEN    = PEN SELECTION, 1-31.  32-62 FOR COLOR FILL         I 
C         OFFLAG = HEADING CONTROL                                    I 
C         ELSET  = ECT DATA BLOCK. THIS DATA BLOCK WAS MODIFIED IN    I 
C                  COMECT TO INCLUDE OFFSET DATA FOR BAR,TRIA3,QUAD4    
C         GPLST  = A SUBSET OF GRID POINTS PERTAININGS TO THOSE GRID  I 
C                  POINTS USED ONLY IN THIS PLOT        
C     LOCAL:        
C         SCALE  = REAL NUMBER OF OFFSCL        
C         OFF    = OFFSET VALUES FROM ELEMENT DATA IN ELSET DATA BLOCK  
C         PN1    = PEN COLOR FOR OFFSET LEG.        
C                  IF PEN.GT.1, PN1 = PEN-1. IF PEN.LE.1, PN1 = PEN+1   
C         NL     = NO. OF LINES TO BE DRAWN PER ELEMENT        
C         DELX   = SMALL OFFSET FROM MIDDLE OF LINE FOR ELEM ID PRINTING
C         0.707  = AN ABITRARY FACTOR TO PUT OFFSET 45 DEGREE OFF GRID  
C                  POINT        
C        
C     TWO METHODS        
C     (1) PEDGE .NE. 3        
C         AN OFFSET PLOT WITHOUT CONSIDERING ITS TRUE DIRECTION, OFFSET 
C         VALUE(S) MAGNIFIED 20 TIMES        
C     (2) PEDGE .EQ. 3        
C         PLOT WITH TRUE OFFSET DIRECTIONS, AND PLOT, WITH COLOR OPTION,
C         GRID(A)-OFFSET(A)-OFFSET(B)-GRID(B)        
C         OFFSET CAN BE SCALE UP BY USER VIA PLOT OFFSET COMMAND,       
C         DEFAULT IS NO SCALE UP. (NEW 93)        
C        
C     A SYMBOL * IS ADDED AT THE TIP OF EACH OFFSET        
C     CURRENTLY THE SYMBOLS KBAR,KT3 AND KQ4 ARE NOT USED        
C        
C     CURRENTLY ONLY CBAR (OFFSET=6), CTRIA3 AND CQUAD4 (OFFSET=1 BOTH) 
C     HAVE OFFSET CAPABILITY        
C        
C     WRITTEN BY G.CHAN/UNISYS   10/1990        
C        
C     COMMENTS FORM G.C.  3/93        
C     THE LOGIC IN COMPUTING THE TRUE OFFSET INVOLVING COORDINATE       
C     TRANSFORMATION AT EACH POINT POINT SEEMS SHAKY. MAKE SURE THAT    
C     AXIS AND SIGN DATA (FROM PROCES) ARE TRUELY AVAILBLE. ARE THE     
C     GIRD POINT XYZ COORDINATES AT HAND IN GLOBAL ALREADY?        
C     THE OFFSET PLOT IS QUESTIONABLE.        
C        
      IMPLICIT INTEGER (A-Z)        
      INTEGER         G(3),OFFHDG(5),SYM(2),GPLST(1)        
      REAL            X(3,1),OFF(3,2),V(3),CSTM,SIGN,X1,X2,X3,Y1,Y2,Y3, 
     1                XMAX,YMAX,YMAX1,CNTX,CNTY,CNTY4,SCALE,DELX,       
     2                OFV(3,2)        
      COMMON /BLANK / SKP1(12),ELSET        
      COMMON /SYSTEM/ SKP2,NOUT        
      COMMON /RSTXXX/ CSTM(3,3),SKP3(12),AXIS(3),SIGN(3)        
      COMMON /XXPARM/ SKP4(235),OFFSCL        
      COMMON /DRWDAT/ SKP5,PLABEL,SKP6,PEN,SKP7(11),PEDGE,OFFLAG        
      COMMON /PLTDAT/ SKP8(6),XMAX,YMAX,SKP9(15),CNTX,CNTY        
      DATA    KBAR  , KT3,KQ4 / 2HBR,2HT3,2HQ4 /, SYM / 2,0 /        
      DATA    OFFHDG/ 4H OFF,4HSET ,4HSCAL,4HE = ,4H   X    /        
C        
      CALL FREAD (ELSET,OFF,OFFSET,0)        
C        
      IF (DEFORM.NE.0 .OR. OFFSCL.LT.0) GO TO 200        
      IF (PEDGE.NE.3 .OR. OFFLAG.EQ.1) GO TO 20        
      OFFLAG= 1        
      CNTY4 = 4.*CNTY        
      YMAX1 = YMAX - CNTY        
      SCALE = 1.0        
      IF (PEDGE .NE. 3) SCALE = 20.0        
      IF (PEDGE .EQ. 3) SCALE = FLOAT(OFFSCL)        
      MPEN  = MOD(PEN,31)        
      IF (MPEN .GT. 1) PN1  = MPEN - 1        
      IF (MPEN .LE. 1) PN1  = MPEN + 1        
C        
C     ADD OFFSET HEADER LINE        
C        
      CALL PRINT  (30.*CNTX,YMAX,1,OFFHDG,5,0)        
      X1 = 48.        
      IF (OFFSCL .GE. 100) X1 = 47.        
      CALL TYPINT (X1*CNTX,YMAX,1,OFFSCL,1,0)        
C        
   20 X1 = 0.0        
      DO 30 I = 1,OFFSET        
      X1 = X1 + ABS(OFF(I,1))        
      OFV(I,1) = OFF(I,1)        
   30 CONTINUE        
      IF (ABS(X1) .LT. 1.0E-7) GO TO 200        
C        
      NL = 1        
      IF (ESYM .EQ. KT3) NL = 3        
      IF (ESYM .EQ. KQ4) NL = 4        
      IF (PEDGE  .NE. 3) GO TO 150        
C        
      J    = ALOG10(FLOAT(ELID)) + 1.0        
      DELX = (J+.03)*CNTX        
C        
C     COMPUTE THE TRUE OFFSET DIRECTION IF PEDGE = 3,        
C     OTHERWISE, JUST PLOT OFFSET AT 45 DEGREE        
C        
      IF (OFFSET .EQ. 1) GO TO 90        
C        
C     CBAR, OFFSET = 6        
C     CONVERT OFFSET FROM GLOBAL TO PLOT COORDINATES        
C        
C     AXIS AND SIGN DATA FROM SUBROUTINE PROCES        
C        
      DO 80 K = 1,2        
      DO 50 I = 1,3        
      J    = AXIS(I)        
      V(J) = SIGN(I)*OFV(J,K)        
   50 CONTINUE        
      DO 70 J = 1,3        
                                L = AXIS(J)        
      X1 = 0.0        
      DO 60 I = 1,3        
C     X1 = X1 + CSTM(J,I)*V(I)        
                                X1 = X1 + CSTM(L,I)*V(I)        
   60 CONTINUE        
      OFF(J,K) = X1*SCALE        
   70 CONTINUE        
   80 CONTINUE        
      GO TO 110        
C        
C     CTRIA3 AND CQUAD4, OFFSET = 1        
C     COMPUTE UNIT NORMAL TO THE PLATE BY CROSS PRODUCT, THEN        
C     THE MAGNITUDE OF OFFSET        
C        
   90 I = G(1)        
      J = G(2)        
      K = G(3)        
      I = GPLST(I)        
      J = GPLST(J)        
      K = GPLST(K)        
      V(1) = (X(2,J)-X(2,I))*(X(3,K)-X(3,I))        
     1     - (X(3,J)-X(3,I))*(X(2,K)-X(2,I))        
      V(2) = (X(3,J)-X(3,I))*(X(1,K)-X(1,I))        
     1     - (X(1,J)-X(1,I))*(X(3,K)-X(3,I))        
      V(3) = (X(1,J)-X(1,I))*(X(2,K)-X(2,I))        
     1     - (X(2,J)-X(2,I))*(X(1,K)-X(1,I))        
      X1   = 0.5*SQRT(V(1)*V(1) + V(2)*V(2) + V(3)*V(3))        
      V(2) = V(2)/X1        
      V(3) = V(3)/X1        
      OFF(2,1) = OFV(1,1)*V(2)*SCALE        
      OFF(3,1) = OFV(1,1)*V(3)*SCALE        
      OFF(2,2) = OFF(2,1)        
      OFF(3,2) = OFF(3,1)        
C        
C     DRAW THE ELEMENT LINES AND ELEMENT ID        
C     IF COLOR FILL IS REQUESTED, SET PEN TO ZERO ON THE LAST CLOSING-IN
C     EDGE (2- OR 3-DIMESIONAL ELEMENTS ONLY)        
C        
  110 DO 130 L = 1,NL        
      I  = G(L  )        
      J  = G(L+1)        
      I  = GPLST(I)        
      J  = GPLST(J)        
      X1 = X(2,I)        
      Y1 = X(3,I)        
      X2 = X(2,I) + OFF(2,1)        
      Y2 = X(3,I) + OFF(3,1)        
      IF (X2 .LT.   0.1) X2 = 0.1        
      IF (X2 .GT.  XMAX) X2 = XMAX        
      IF (Y2 .LT. CNTY4) Y2 = CNTY4        
      IF (Y2 .GT. YMAX1) Y2 = YMAX1        
      CALL LINE (X1,Y1,X2,Y2,PN1,0)        
      CALL SYMBOL (X2,Y2,SYM,0)        
      X3 = X(2,J) + OFF(2,2)        
      Y3 = X(3,J) + OFF(3,2)        
      IF (X3 .LT.   0.1) X3 = 0.1        
      IF (X3 .GT.  XMAX) X3 = XMAX        
      IF (Y3 .LT. CNTY4) Y3 = CNTY4        
      IF (Y3 .GT. YMAX1) Y3 = YMAX1        
      IPEN = PEN        
      IF (PEN.GT.31 .AND. NL.GE.3 .AND. L.EQ.NL) IPEN = 0        
      CALL LINE (X2,Y2,X3,Y3,IPEN,0)        
C        
      IF (L .GT. 1) GO TO 130        
      IF (PLABEL.NE.3 .AND. PLABEL.NE.6) GO TO 120        
      IF (X2 .GE. X1) DELX = -DELX        
      X1 = 0.5*(X3 + X2) + DELX        
      Y1 = 0.5*(Y3 + Y2)        
      CALL TYPINT (X1,Y1,1,ELID,1,0)        
  120 IF (NL .GT. 1) GO TO 130        
      CALL SYMBOL (X3,Y3,SYM,0)        
      X2 = X(2,J)        
      Y2 = X(3,J)        
      CALL LINE (X3,Y3,X2,Y2,PEN,0)        
  130 CONTINUE        
      GO TO 210        
C        
C     PLOT OFFSET WITHOUT CONSIDERING ITS TRUE OFFSET DIRECTION IN      
C     GENERAL PLOT. (SEE 130 LOOP FOR ELEMENTS WITH COLOR FILL)        
C        
  150 IF (OFFSET .EQ. 1) GO TO 160        
      V(1) = OFF(1,1)*OFF(1,1) + OFF(2,1)*OFF(2,1) + OFF(3,1)*OFF(3,1)  
      V(2) = OFF(1,2)*OFF(1,2) + OFF(2,2)*OFF(2,2) + OFF(3,2)*OFF(3,2)  
      V(1) = 0.707*SQRT(V(1))        
      V(2) = 0.707*SQRT(V(2))        
      GO TO 170        
C        
  160 V(1) = 0.707*OFF(1,1)        
      V(2) = V(1)        
C        
  170       V(1) = V(1)*SCALE        
            V(2) = V(2)*SCALE        
            DO 180 L = 1,NL        
C 170 DO 180 L = 1,NL        
      I  = G(L  )        
      J  = G(L+1)        
      I  = GPLST(I)        
      J  = GPLST(J)        
      X1 = X(2,I) + V(1)        
      Y1 = X(3,I) + V(1)        
      X2 = X(2,J) + V(2)        
      Y2 = X(3,J) + V(2)        
      IPEN = PEN        
      IF (PEN.GT.31 .AND. NL.GE.3 .AND. L.EQ.NL) IPEN = 0        
      CALL LINE (X1,Y1,X2,Y2,IPEN,0)        
      CALL SYMBOL (X1,Y1,SYM,0)        
      IF (NL .EQ. 1) CALL SYMBOL (X2,Y2,SYM,0)        
  180 CONTINUE        
      GO TO 210        
C        
  200 IF (PEDGE.NE.3 .OR. OFFSCL.LT.0) RETURN        
  210 RETURN 1        
      END        
