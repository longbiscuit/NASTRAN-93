      SUBROUTINE SMA1A        
C        
C     THIS SUBROUTINE FORMERLY GENERATED THE KGG AND K4GG MATRICES FOR  
C     THE SMA1 MODULE.  THESE OPERATIONS ARE NOW PERFORMED IN THE EMG   
C     AND EMA MODULES AND SMA1A IS RETAINED IN SKELETAL FORM TO PROVIDE 
C     A VEHICLE FOR USER-PROVIDED ELEMENTS.        
C        
      LOGICAL          DODET,NOGO,HEAT,NOHEAT        
      INTEGER          IZ(1),EOR,CLSRW,CLSNRW,FROWIC,SYSPRT,TNROWS,     
     1                 OUTRW,OPTION        
      DOUBLE PRECISION DZ,DPWORD        
      DIMENSION        INPVT(2),DZ(1),NAME(2)        
      CHARACTER        UFM*23,UWM*25,UIM*29,SFM*25,SWM*27        
      COMMON /XMSSG /  UFM,UWM,UIM,SFM,SWM        
      COMMON /BLANK /  NOGENL,NOK4GG,OPTION(2)        
      COMMON /SYSTEM/  KSYSTM(65)        
      COMMON /SMA1HT/  HEAT        
      COMMON /SMA1IO/  IFCSTM,IFMPT,IFDIT,IDUM1,IFECPT,IGECPT,IFGPCT,   
     1                 IGGPCT,IFGEI,IGGEI,IFKGG,IGKGG,IF4GG,IG4GG,      
     2                 IFGPST,IGGPST,INRW,OUTRW,CLSNRW,CLSRW,NEOR,EOR,  
     3                 MCBKGG(7),MCB4GG(7)        
CZZ   COMMON /ZZSMA1/  Z(1)        
      COMMON /ZZZZZZ/  Z(1)        
      COMMON /SMA1BK/  ICSTM,NCSTM,IGPCT,NGPCT,IPOINT,NPOINT,I6X6K,     
     1                 N6X6K,I6X64,N6X64        
      COMMON /SMA1CL/  IOPT4,K4GGSW,NPVT,LLEFT,FROWIC,LROWIC,NROWSC,    
     1                 TNROWS,JMAX,NLINKS,LINK(10),IDETCK,DODET,NOGOO   
      COMMON /GPTA1 /  NELEMS,LAST,INCR,NE(1)        
      COMMON /SMA1ET/  ECPT(200)        
      COMMON /ZBLPKX/  DPWORD,DUM(2),INDEX        
      EQUIVALENCE      (KSYSTM(2),SYSPRT),(KSYSTM(3),NOGO),        
     1                 (KSYSTM(55),IPREC),(Z(1),IZ(1),DZ(1))        
      DATA    NAME  /  4HSMA1, 4HA   /        
C        
C     FLAG FOR ERROR CHECK IF A NON-HEAT ELEMENT IS REFERENCED        
C     IN A -HEAT- FORMULATION.        
C        
      NOHEAT = .FALSE.        
      IPR = IPREC        
C        
C     READ THE FIRST TWO WORDS OF NEXT GPCT RECORD INTO INPVT(1).       
C     INPVT(1) IS THE PIVOT POINT.  INPVT(1) .GT. 0 IMPLIES THE PIVOT   
C     POINT IS A GRID POINT.  INPVT(1) .LT. 0 IMPLIES THE PIVOT POINT IS
C     A SCALAR POINT.  INPVT(2) IS THE NUMBER OF WORDS IN THE REMAINDER 
C     OF THIS RECORD OF THE GPCT.        
C        
      IF (NOGO) WRITE (SYSPRT,5) SWM        
    5 FORMAT (A27,' 2055, NOGO FLAG IS ON AT ENTRY TO SMA1A AND IS ',   
     1       'BEING TURNED OFF.')        
      NOGO   = .FALSE.        
   10 IDETCK = 0        
      CALL READ (*1000,*700,IFGPCT,INPVT(1),2,NEOR,IFLAG)        
      NGPCT = INPVT(2)        
      CALL READ (*1000,*3000,IFGPCT,IZ(IGPCT+1),NGPCT,EOR,IFLAG)        
C        
C     FROWIC IS THE FIRST ROW IN CORE. (1 .LE. FROWIC .LE. 6)        
C        
      FROWIC = 1        
C        
C     DECREMENT THE AMOUNT OF CORE REMAINING.        
C        
      LEFT = LLEFT - 2*NGPCT        
      IF (LEFT .LE. 0) GO TO 3003        
      IPOINT = IGPCT + NGPCT        
      NPOINT = NGPCT        
      I6X6K  = IPOINT + NPOINT        
      I6X6K  = (I6X6K-1)/2 + 2        
C        
C     CONSTRUCT THE POINTER TABLE, WHICH WILL ENABLE SUBROUTINE SMA1B   
C     TO ADD THE ELEMENT STRUCTURAL AND/OR DAMPING MATRICES TO KGG AND  
C     K4GG.        
C        
      IZ(IPOINT+1) = 1        
      I1  = 1        
      I   = IGPCT        
      J   = IPOINT + 1        
   30 I1  = I1 + 1        
      IF (I1 .GT. NGPCT) GO TO 40        
      I   = I + 1        
      J   = J + 1        
      INC = 6        
      IF (IZ(I) .LT. 0) INC = 1        
      IZ(J) = IZ(J-1) + INC        
      GO TO 30        
C        
C     JMAX = THE NUMBER OF COLUMNS OF KGG THAT WILL BE GENERATED WITH   
C     THE CURRENT GRID POINT.        
C        
   40 INC   = 5        
      ILAST = IGPCT  + NGPCT        
      JLAST = IPOINT + NPOINT        
      IF (IZ(ILAST) .LT. 0) INC = 0        
      JMAX  = IZ(JLAST) + INC        
C        
C     TNROWS = THE TOTAL NUMBER OF ROWS OF THE MATRIX TO BE GENERATED   
C              FOR THE CURRENT PIVOT POINT.        
C     TNROWS = 6 IF THE CURRENT PIVOT POINT IS A GRID POINT.        
C     TNROWS = 1 IF THE CURRENT PIVOT POINT IS A SCALAR POINT.        
C        
      TNROWS = 6        
      IF (INPVT(1) .LT. 0) TNROWS = 1        
C        
C     IF 2*TNROWS*JMAX .LT. LEFT THERE ARE NO SPILL LOGIC PROBLEMS FOR  
C     THE KGG SINCE THE WHOLE DOUBLE PRECISION SUBMATRIX OF ORDER TNROWS
C     X JMAX CAN FIT IN CORE.        
C        
      ITEMP = TNROWS*JMAX        
      IF (2*ITEMP .LT. LEFT) GO TO 80        
      NAME(2) = INPVT(1)        
      CALL MESAGE (30,85,NAME)        
C        
C     THE WHOLE MATRIX CANNOT FIT IN CORE, DETERMINE HOW MANY ROWS CAN  
C     FIT. IF TNROWS = 1, WE CAN DO NOTHING FURTHER.        
C        
      IF (TNROWS .EQ. 1) GO TO 3003        
      NROWSC = 3        
   70 IF (2*NROWSC*JMAX .LT. LEFT) GO TO 90        
      NROWSC = NROWSC - 1        
      IF (NROWSC .EQ. 0) CALL MESAGE (-8,0,NAME)        
      GO TO 70        
   80 NROWSC = TNROWS        
   90 FROWIC = 1        
C        
C     LROWIC IS THE LAST ROW IN CORE. (1 .LE. LROWIC .LE. 6)        
C        
      LROWIC = FROWIC + NROWSC - 1        
C        
C     ZERO OUT THE KGG SUBMATRIX IN CORE        
C        
  100 LOW = I6X6K + 1        
      LIM = I6X6K + JMAX*NROWSC        
      DO 115 I = LOW,LIM        
  115 DZ(I) = 0.0D0        
C        
C     CHECK TO SEE IF THE K4GG MATRIX IS DESIRED.        
C        
      IF (IOPT4 .EQ. 0) GO TO 137        
C        
C     SINCE THE K4GG MATRIX IS TO BE COMPUTED, DETERMINE IF IT TOO CAN  
C     FIT INTO CORE        
C        
      IF (NROWSC .NE. TNROWS) GO TO 120        
      IF (4*TNROWS*JMAX .LT. LEFT)  GO TO 130        
C        
C     OPEN A SCRATCH FILE FOR K4GG.        
C        
  120 CALL MESAGE (-8,0,NAME)        
C        
C     THIS CODE TO BE FILLED IN LATER        
C     ===============================        
C        
  130 I6X64 = I6X6K + JMAX*TNROWS        
      LOW   = I6X64 + 1        
      LIM   = I6X64 + JMAX*TNROWS        
      DO 135 I = LOW,LIM        
  135 DZ(I) = 0.0D0        
C        
C     INITIALIZE THE LINK VECTOR TO -1.        
C        
  137 DO 140 I = 1,NLINKS        
  140 LINK(I) = -1        
C        
C     TURN FIRST PASS INDICATOR ON.        
C        
  150 IFIRST = 1        
C        
C     READ THE 1ST WORD OF THE ECPT RECORD, THE PIVOT POINT, INTO NPVT. 
C        
      CALL FREAD (IFECPT,NPVT,1,0)        
C        
C     READ THE NEXT ELEMENT TYPE INTO THE CELL ITYPE.        
C        
  160 CALL READ (*3025,*500,IFECPT,ITYPE,1,NEOR,IFLAG)        
      IF (ITYPE.GE.53 .OR. ITYPE.LE.61) GO TO 165        
      CALL PAGE2 (-3)        
      WRITE  (SYSPRT,161) UFM,ITYPE        
  161 FORMAT (A23,' 2201, ELEMENT TYPE',I4,' NO LONGER SUPPORTED BY ',  
     1       'SMA1 MODULE.', /5X,        
     2       'USE EMG AND EMA MODULES FOR ELEMENT MATRIX GENERATION')   
      NOGO = .TRUE.        
      GO TO 1000        
  165 CONTINUE        
C        
C     READ THE ECPT ENTRY FOR THE CURRENT TYPE INTO THE ECPT ARRAY. THE 
C     NUMBER OF WORDS TO BE READ WILL BE NWORDS(ITYPE).        
C        
      IDX = (ITYPE-1)*INCR        
      CALL FREAD (IFECPT,ECPT,NE(IDX+12),0)        
      ITEMP = NE(IDX+22)        
C        
C     IF THIS IS THE 1ST ELEMENT READ ON THE CURRENT PASS OF THE ECPT   
C     CHECK TO SEE IF THIS ELEMENT IS IN A LINK THAT HAS ALREADY BEEN   
C     PROCESSED.        
C        
      IF (IFIRST .EQ. 1) GO TO 170        
C        
C     THIS IS NOT THE FIRST PASS.  IF ITYPE(TH) ELEMENT ROUTINE IS IN   
C     CORE, PROCESS IT.        
C        
      IF (ITEMP .EQ. LINCOR) GO TO 180        
C        
C     THE ITYPE(TH) ELEMENT ROUTINE IS NOT IN CORE.  IF THIS ELEMENT    
C     ROUTINE IS IN A LINK THAT ALREADY HAS BEEN PROCESSED READ THE NEXT
C     ELEMENT.        
C        
      IF (LINK(ITEMP) .EQ. 1) GO TO 160        
C        
C     SET A TO BE PROCESSED LATER FLAG FOR THE LINK IN WHICH THE ELEMENT
C     RESIDES        
C        
      LINK(ITEMP) = 0        
      GO TO 160        
C        
C     SINCE THIS IS THE FIRST ELEMENT TYPE TO BE PROCESSED ON THIS PASS 
C     OF THE ECPT RECORD, A CHECK MUST BE MADE TO SEE IF THIS ELEMENT   
C     IS IN A LINK THAT HAS ALREADY BEEN PROCESSED.  IF IT IS SUCH AN   
C     ELEMENT, WE KEEP IFIRST = 1 AND READ THE NEXT ELEMENT.        
C        
  170 IF (LINK(ITEMP) .EQ. 1) GO TO 160        
C        
C     SET THE CURRENT LINK IN CORE = ITEMP AND IFIRST = 0        
C        
      LINCOR = ITEMP        
      IFIRST = 0        
      ITYPX  = ITYPE - 52        
C        
C     CALL THE PROPER ELEMENT ROUTINE.        
C        
  180 GO TO (        
C                                  CDUM1   CDUM2   CDUM3   CDUM4        
C                                    53      54      55      56        
     7                              467,    468,    469,    470,        
C          CDUM5   CDUM6   CDUM7   CDUM8   CDUM9        
C            57      58      59      60      61        
     8     471,    472,    473,    474,    475  ) , ITYPX        
C        
C        
  467 CALL KDUM1        
      GO TO 160        
  468 CALL KDUM2        
      GO TO 160        
  469 CALL KDUM3        
      GO TO 160        
  470 CALL KDUM4        
      GO TO 160        
  471 CALL KDUM5        
      GO TO 160        
  472 CALL KDUM6        
      GO TO 160        
  473 CALL KDUM7        
      GO TO 160        
  474 CALL KDUM8        
      GO TO 160        
  475 CALL KDUM9        
      GO TO 160        
C        
C     AT STATEMENT NO. 500 WE HAVE HIT AN EOR ON THE ECPT FILE.  SEARCH 
C     THE LINK VECTOR TO DETERMINE IF THERE ARE LINKS TO BE PROCESSED.  
C        
  500 LINK(LINCOR) = 1        
      DO  510 I = 1,NLINKS        
      IF (LINK(I) .EQ. 0) GO TO 520        
  510 CONTINUE        
      GO TO 525        
C        
C     SINCE AT LEAST ONE LINK HAS NOT BEEN PROCESSED THE ECPT FILE MUST 
C     BE BACKSPACED.        
C        
  520 CALL BCKREC (IFECPT)        
      GO TO 150        
C        
C    CHECK NOGOO FLAG. IF 1 SKIP BKDPK AND PROCESS ANOTHER GRID POINT   
C    FROM GPCT        
C        
  525 IF (NOGOO .EQ. 1) GO TO 10        
C        
C     IF NO GENERAL ELEMENTS EXIST, CHECK FOR GRID POINT SINGULARITIES. 
C        
      IF (DODET) CALL DETCK (0)        
C        
C     AT THIS POINT BLDPK THE NUMBER OF ROWS IN CORE UNTO THE KGG FILE. 
C        
      ASSIGN 580 TO IRETRN        
      IFILE= IFKGG        
      IMCB = 1        
  530 I1   = 0        
  540 I2   = 0        
      IBEG = I6X6K + I1*JMAX        
      CALL BLDPK (2,IPR,IFILE,0,0)        
  550 I2  = I2 + 1        
      IF (I2 .GT. NGPCT) GO TO 570        
      JJ  = IGPCT + I2        
      INDEX = IABS(IZ(JJ)) - 1        
      LIM = 6        
      IF (IZ(JJ) .LT. 0) LIM = 1        
      JJJ = IPOINT + I2        
      KKK = IBEG + IZ(JJJ) - 1        
      I3  = 0        
  560 I3  = I3 + 1        
      IF (I3 .GT. LIM) GO TO 550        
      INDEX = INDEX + 1        
      KKK = KKK + 1        
      DPWORD = DZ(KKK)        
      IF (DPWORD .NE. 0.0D0) CALL ZBLPKI        
      GO TO 560        
  570 CALL BLDPKN (IFILE,0,MCBKGG(IMCB))        
      I1 = I1 + 1        
      IF (I1 .LT. NROWSC) GO TO 540        
      GO TO IRETRN, (580,600)        
C        
C     IF THE K4GG IS CALLED FOR, BLDPK IT.        
C        
  580 IF (IOPT4 .EQ.  0) GO TO 600        
      IF (IOPT4 .EQ. -1) GO TO 590        
C        
C     THE K4GG MATRIX IS IN CORE.        
C        
      ASSIGN 600 TO IRETRN        
      I6X6K = I6X64        
      IFILE = IF4GG        
      IMCB  = 8        
      GO TO 530        
C        
C     HERE WE NEED LOGIC TO READ K4GG FROM A SCRATCH FILE AND INSERT.   
C        
  590 CONTINUE        
C        
C     TEST TO SEE IF THE LAST ROW IN CORE, LROWIC, = THE TOTAL NO. OF   
C     ROWS TO BE COMPUTED, TNROWS.  IF IT IS, WE ARE DONE.  IF NOT, THE 
C     ECPT MUST BE BACKSPACED.        
C        
  600 IF (LROWIC .EQ. TNROWS) GO TO 10        
      CALL BCKREC (IFECPT)        
      FROWIC = FROWIC + NROWSC        
      LROWIC = LROWIC + NROWSC        
      GO TO 100        
C        
C     CHECK NOGOO = 1 SKIP BLDPK AND PROCESS ANOTHER RECORD        
C        
  700 IF (NOGOO .EQ. 1) GO TO 10        
C        
C     HERE WE HAVE A PIVOT POINT WITH NO ELEMENTS CONNECTED, SO THAT    
C     NULL COLUMNS MUST BE OUTPUT ON THE KGG AND K4GG FILES.  IF DODET  
C     IS TRUE, CALL THE DETERMINANT CHECK ROUTINE TO WRITE SINGULARITY  
C     INFORMATION.        
C        
      NPVT = IABS(INPVT(1))        
      IF (INPVT(1) .GT. 0) GO TO 703        
      LIM  = 1        
      IXX  = -1        
      GO TO 706        
  703 LIM  = 6        
      IXX  = 1        
  706 IF (DODET) CALL DETCK (IXX)        
      DO 710 I = 1,LIM        
      CALL BLDPK (2,IPR,IFKGG,0,0)        
      CALL BLDPKN (IFKGG,0,MCBKGG)        
      IF (IOPT4 .NE. 1) GO TO 710        
      CALL BLDPK (2,IPR,IF4GG,0,0)        
      CALL BLDPKN (IF4GG,0,MCB4GG)        
  710 CONTINUE        
      CALL SKPREC (IFECPT,1)        
      GO TO 10        
C        
C     RETURN SINCE AN EOF HAS BEEN HIT ON THE GPCT FILE        
C        
 1000 IF (.NOT.NOGO .AND. NOGOO.EQ.0) RETURN        
      IPARM = -61        
      GO TO 4010        
C        
C     ERROR RETURNS        
C        
 3000 IFILE = IFGPCT        
      GO TO 4003        
 3003 IPARM = -8        
      GO TO 4010        
 3025 IFILE = IFECPT        
      IPARM = -2        
      GO TO 4010        
 4003 IPARM = -3        
 4010 CALL MESAGE (IPARM,IFILE,NAME)        
      CALL MESAGE (-30,87,ITYPE)        
      RETURN        
      END        
