   10 fnum=OPENIN("02.txt")
   20 IF fnum=0 THEN PRINT "No data": END
   30 DIM maxes(3): REM maximum seen value in the game for each color
   40 sum=0
   50 FOR l=1 TO 100 : REM we have 100 lines of input
   60   GOSUB 480:GOSUB 480
   70   PRINT"Processing game ",n: REM Processing Game 1...
   80   maxes(0)=0:maxes(1)=0:maxes(2)=0
   90   game=n
  100   possible=1
  110   GOSUB 480 : REM sets d, n, c$, x; first try n = number of cubes
  120   howmany=n
  130   GOSUB 480 : REM now c is color (string) of cubes
  140   color$=c$
  150   PRINT howmany," ",color$,"cubes"
  160   GOSUB 760 : REM check if howmany is the new max
  170   IF (color$="red" AND howmany>12)OR(color$="green"ANDhowmany>13)OR(color$="blue"ANDhowmany>14)THEN
  180     possible=0
  190   ENDIF
  200   IF d=ASC(",") THEN
  210     GOTO 110 : REM next word, same round, same game
  220   ENDIF
  230   IF d=ASC(";") THEN
  240     PRINT"Next round"
  250     GOTO 110
  260   ENDIF
  270   IF d=10 OR d=13 THEN
  280     REM newline
  290     IF possible=1 THEN
  300       PRINT"Game was possible"
  310       sum=sum+game
  320     ELSE
  330       PRINT "Game was not possible"
  340     ENDIF
  350     d=BGET#fnum : REM should read 10 (line feed)
  360     PRINT"game requires at least ",maxes(0),"red, ",maxes(1)," blue, ",maxes(2)," green cubes."
  370     REM calculate the power of the game - number of RGB multiplied together
  380     p=maxes(0)*maxes(1)*maxes(2)
  390     PRINT"Power of the game:",p
  400     psum=psum+p
  410   ENDIF
  420 NEXT l
  430 CLOSE#fnum
  440 PRINT"Sum of all possible games:",sum
  450 PRINT"Sum of powers of all games:",psum
  460 END
  470
  480 REM a procedure for adding to s$ until we encounter a non-digit and non-letter
  490 REM as a result n will contain a number or 0 if none,
  500 REM and s$ will contain a lowercase word or empty
  510 REM (sets d, c$, n, x)
  520 n=0:c$=""
  530 x=1 : REM x means exit
  540 d=BGET#fnum
  550 IF d>=&30 AND d<=&39  THEN
  560   x=0
  570   n=n*10+(d-&30)
  580 ENDIF
  590 IF d>=ASC("a") AND d<=ASC("z") THEN
  600   x=0
  610   c$=c$+CHR$(d)
  620 ENDIF
  630 IF d=>ASC("A") AND d<=ASC("Z") THEN
  640   x=0
  650   c$=c$+CHR$(d+32) : REM convert to lowercase
  660 ENDIF
  670 IF c$="" AND n=0 AND d=32 THEN
  680   c$=""
  690   GOTO 520
  700 ENDIF
  710 IF x=1 THEN
  720   RETURN
  730 ENDIF
  740 GOTO 530
  750
  760 REM for the current color in <color$>, if the current <howmany>
  770 REM is bigger than last remembered value for this color, update the maximum
  780 IF color$="red" THEN idx=0
  790 IF color$="blue" THEN idx=1
  800 IF color$="green" THEN idx=2
  810 IF howmany > maxes(idx) THEN maxes(idx)=howmany
  820 RETURN
