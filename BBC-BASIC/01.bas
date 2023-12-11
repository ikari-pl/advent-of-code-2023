   10 fnum=OPENIN("01.txt")
   20 IF fnum=0 THEN PRINT "No data": END
   30 sum=0
   40 FOR i=1 TO 1000
   50   INPUT #fnum,line$
   60   REM find first digit
   70   l=LEN(line$)
   80   sl=0
   90   d=0
  100   FOR j%=0 TO l
  110     GOSUB 320
  120     IF d<>-1 THEN
  130       GOTO 160
  140     ENDIF
  150   NEXT j%
  160   sl=d*10
  170   REM and the last one
  180   FOR j%=l TO 0 STEP -1
  190     GOSUB 320
  200     IF d<>-1 THEN
  210       GOTO 240
  220     ENDIF
  230   NEXT j%
  240   sl=sl+d
  250   sum=sum+sl
  260   PRINT line$+" => ";sl;", TOTAL: ",sum
  270 NEXT i
  280 CLOSE #fnum
  290 PRINT"SUM:",sum
  300 END
  310
  320 REM Is this a digit?
  330 DATA zero,0,one,1,two,2,three,3,four,4
  340 DATA five,5,six,6,seven,7,eight,8,nine,9
  350 d=-1
  360 c=ASC(MID$(line$,j%,1))
  370 IF c >= &30 AND c <= &39 THEN
  380   d=c-&30
  390   RETURN
  400 ENDIF
  410 REM is this a digit spelled out?
  420 RESTORE 330
  430 FOR k%=0 TO 9
  440   READ word$
  450   READ value%
  460   wl=LEN(word$)
  470   IF MID$(line$,j%,wl)=word$ THEN
  480     d=value%
  490     RETURN
  500   ENDIF
  510 NEXT k%
  520 RETURN : REM no digit found
