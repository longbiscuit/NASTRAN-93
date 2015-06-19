      SUBROUTINE FBS3 (BLOCK,Y,YN,NWDS)        
C        
C     FBS3 EXECUTES THE FORWARD/BACKWARD PASS FOR FBS IN CSP        
C        
      INTEGER         BLOCK(8), DBL, BUF(2), SUBNAM, BEGN, END        
      REAL            Y(1), YN(1), LJJR, LJJI, L        
      CHARACTER       UFM*23, UWM*25, UIM*29, SFM*25        
      COMMON /XMSSG / UFM, UWM, UIM, SFM        
      COMMON /SYSTEM/ SYSBUF, NOUT        
CZZ   COMMON /XNSTRN/ L(1)        
      COMMON /ZZZZZZ/ L(1)        
      COMMON /FBSX  / DBL   , N        
      EQUIVALENCE     (SUMR,YJKR),  (SUMI,YJKI)        
      DATA    SUBNAM, BEGN  , END / 4HFBS3, 4HBEGN, 4HEND /        
C        
      BUF(1) = SUBNAM        
      BUF(2) = BEGN        
      CALL CONMSG (BUF,2,0)        
      NBRITM = NWDS        
      J    = (LOCFX(YN)-LOCFX(Y)+1)/NWDS        
      LAST = MAX0(J,1)*NBRITM        
      DO 35 J = 1,N        
      J1 = J - 1        
      DO 5 K = 1,LAST,NBRITM        
      YJKR = Y(2*J+K-2)        
      YJKI = Y(2*J+K-1)        
      IF (YJKR.NE.0.0 .OR. YJKI.NE.0.0) GO TO 7        
    5 CONTINUE        
      CALL SKPREC (BLOCK(1),1)        
      GO TO 35        
C        
C     MAKE 1ST CALL FOR COLUMN AND SAVE DIAGONAL ELEMENT        
C        
    7 BLOCK(8) = -1        
      CALL GETSTR (*80,BLOCK)        
      IF (BLOCK(4) .NE. J) GO TO 80        
      JSTR = BLOCK(5)        
      LJJR = L(JSTR  )        
      LJJI = L(JSTR+1)        
      IF (BLOCK(6) .EQ. 1) GO TO 20        
      NSTR = JSTR + 2*BLOCK(6) - 2        
      JSTR = JSTR + 2        
      BLOCK(4) = BLOCK(4) + 1        
C        
C     PROCESS CURRENT STRING IN TRIANGULAR FACTOR AGAINST EACH        
C     LOAD VECTOR IN CORE -- Y(I,K) = Y(I,K) + L(I,J)*Y(J,K)        
C        
   10 DO 15 K = 1,LAST,NBRITM        
      YJKR = Y(2*J+K-2)        
      YJKI = Y(2*J+K-1)        
      IF (YJKR.EQ.0.0 .AND. YJKI.EQ.0.0) GO TO 15        
      IK   = 2*BLOCK(4) + K - 2        
      DO 12 IJ = JSTR,NSTR,2        
      Y(IK  ) =  Y(IK  ) + L(IJ)*YJKR - L(IJ+1)*YJKI        
      Y(IK+1) =  Y(IK+1) + L(IJ)*YJKI + L(IJ+1)*YJKR        
   12 IK = IK + 2        
   15 CONTINUE        
C        
C     GET NEXT STRING IN TRIANGULAR FACTOR        
C        
   20 CALL ENDGET (BLOCK)        
      CALL GETSTR (*30,BLOCK)        
      JSTR = BLOCK(5)        
      NSTR = JSTR + 2*BLOCK(6) - 2        
      GO TO 10        
C        
C     END-OF-COLUMN ON TRIANGULAR FACTOR -- DIVIDE BY DIAGONAL        
C        
   30 SSQR = 1.0/(LJJR**2 + LJJI**2)        
      DO 32 K = 1,LAST,NBRITM        
      YJKR       = (Y(2*J+K-2)*LJJR + Y(2*J+K-1)*LJJI)*SSQR        
      Y(2*J+K-1) =-(Y(2*J+K-2)*LJJI - Y(2*J+K-1)*LJJR)*SSQR        
   32 Y(2*J+K-2) = YJKR        
C        
   35 CONTINUE        
C        
C     INITIALIZE FOR BACKWARD PASS BY SKIPPING THE NTH COLUMN        
C        
      IF (N .EQ. 1) GO TO 65        
      CALL BCKREC (BLOCK)        
      J = N - 1        
C        
C     GET A STRING IN CURRENT COLUMN.  IF STRING INCLUDES DIAGONAL,     
C     ADJUST STRING TO SKIP IT.        
C        
   40 J1 = J - 1        
      BLOCK(8) = -1        
   42 CALL GETSTB (*60,BLOCK)        
      IF (BLOCK(4)-BLOCK(6) .EQ. J1) BLOCK(6) = BLOCK(6) - 1        
      IF (BLOCK(6) .EQ. 0) GO TO 58        
      NTERMS = BLOCK(6)        
C        
C     PROCESS CURRENT STRING IN TRIANGULAR FACTOR AGAINST EACH        
C     LOAD VECTOR IN CORE -- Y(J,K) = Y(J,K) + L(J,I)*Y(I,K)        
C        
      DO 55 K = 1,LAST,NBRITM        
      JI = BLOCK(5) + 2        
      IK = BLOCK(4)*2 + K        
      JK = J1*2 + K        
      SUMR = 0.0        
      SUMI = 0.0        
      DO 53 II = 1,NTERMS        
      JI = JI - 2        
      IK = IK - 2        
      SUMR = SUMR + L(JI)*Y(IK  ) - L(JI+1)*Y(IK+1)        
      SUMI = SUMI + L(JI)*Y(IK+1) + L(JI+1)*Y(IK  )        
   53 CONTINUE        
      Y(JK  ) = Y(JK  ) + SUMR        
      Y(JK+1) = Y(JK+1) + SUMI        
   55 CONTINUE        
C        
C     TERMINATE CURRENT STRING AND GET NEXT STRING        
C        
   58 CALL ENDGTB (BLOCK)        
      GO TO 42        
C        
C     END-OF-COLUMN -- TEST FOR COMPLETION        
C        
   60 IF (J .NE. 1) GO TO 70        
   65 BUF(2) = END        
      CALL CONMSG (BUF,2,0)        
      RETURN        
C        
   70 J = J - 1        
      GO TO 40        
C        
C     FATAL ERROR MESSAGE        
C        
   80 WRITE  (NOUT,82) SFM,SUBNAM        
   82 FORMAT (A25,' 2149, SUBROUTINE ',A4,/5X,'FIRST ELEMENT OF A COLU',
     1      'MN OF LOWER TRIANGULAR MATRIX IS NOT THE DIAGONAL ELEMENT')
      CALL MESAGE (-61,0,0)        
      RETURN        
      END        