      SUBROUTINE MBPLOT (NW1,ND1,NWN,NC21,NC2N,NC1,NCN,NDN)        
C        
C     SUBROUTINE TO PRINT A REPRESENTATION OF PLANFORM BEING CONSIDERED 
C        
      REAL            MACH        
      DIMENSION       NW1(1),ND1(1),NWN(1),NC21(1),NC2N(1),NC1(1),      
     1                NCN(1),NDN(1),PL(50)        
      COMMON /SYSTEM/ SYS,N6        
      COMMON /MBOXC / NJJ,CRANK1,CRANK2,CNTRL1,CNTRL2,NBOX,NPTS0,NPTS1, 
     1                NPTS2,ASYM,GC,CR,MACH,BETA,EK,EKBAR,EKM,BOXL,BOXW,
     2                BOXA ,NCB,NSB,NSBD,NTOTE,KC,KC1,KC2,KCT,KC1T,KC2T 
      DATA    BLANK , DIA, WG , FP , TP , WK  /        
     1        1H    , 1H., 1HS, 1H1,1H2 , 1H, /        
C        
      NSBM  = MAX0(NSB,NSBD)        
      NCBMX = MAX0(NCB,5   )        
      WRITE  (N6,200) MACH,BOXW,BOXL        
 200  FORMAT (1H1,29X,'GRAPHIC DISPLAY OF REGIONS ON MAIN SEMISPAN',    
     1        /10X,11HMACH NUMBER ,F8.3,11X,9HBOX WIDTH ,F11.6 ,10X,    
     2        10HBOX LENGTH ,F11.6, //)        
      DO 3100 I = 1,NCBMX        
      DO 1900 J = 1,NSBM        
      PL(J) = BLANK        
      IF (J .GT. NSB   ) GO TO 1500        
      IF (I .GE. NW1(J)) GO TO 1100        
      IF (I .LT. ND1(J)) GO TO 1900        
      PL(J) = DIA        
      GO TO 1900        
 1100 IF (I .GT. NWN(J)) GO TO 1300        
      IF (I.GE.NC21(J) .AND. I.LE.NC2N(J)) GO TO 1150        
      IF (I.GE.NC1(J)  .AND. I.LE.NCN(J) ) GO TO 1200        
      PL(J) = WG        
      GO TO 1900        
 1150 PL(J) = TP        
      GO TO 1900        
 1200 PL(J) = FP        
      GO TO 1900        
 1300 IF (I .GT. NDN(J)) GO TO 1900        
      PL(J) = WK        
      GO TO 1900        
 1500 IF ((I.GE.ND1(J) .AND. I.LE.NDN(J)) .OR. (I.GE.NC1(J) .AND.       
     1     I.LE.NCN(J))) PL(J) = DIA        
      GO TO 1900        
 1900 CONTINUE        
C        
      WRITE  (N6,2000) (PL(J),J=1,NSBM)        
 2000 FORMAT (30X,50A1)        
C        
      IF (I .GT. 5) GO TO 3100        
      GO TO (2100,2300,2500,2700,2900), I        
 2100 WRITE  (N6,2200)        
 2200 FORMAT (1H+,84X,9HS    MAIN )        
      GO TO  3100        
 2300 WRITE  (N6,2400)        
 2400 FORMAT (1H+,84X,11H1    CNTRL1 )        
      GO TO  3100        
 2500 WRITE  (N6,2600)        
 2600 FORMAT (1H+,84X,11H2    CNTRL2 )        
      GO TO  3100        
 2700 WRITE  (N6,2800)        
 2800 FORMAT (1H+,84X,14H.    DIAPHRAGM )        
      GO TO  3100        
 2900 WRITE  (N6,3000)        
 3000 FORMAT (1H+,84X,9H,    WAKE )        
 3100 CONTINUE        
      RETURN        
      END        