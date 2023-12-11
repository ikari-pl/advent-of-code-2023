   10 fnum=OPENIN("03.txt")
   20 IF fnum=0 THEN PRINT "No data": END
   30 REM work area - allocate string variables for 3+1 lines (not chronological)
   40 DIM line$(4) : REM (4th is to serve as a buffer kept empty at the end of file
   50 c=1 :          REM current: index of the currently processed line
   60 n=2 :          REM next: index of next line, loaded before processing current
   70 p=0 :          REM previous: index of line above current
   80 l$="" :        REM input line
   90 s=0 :          REM boolean: was there a symbol
  100 d=-1:          REM are we on a digit
  110 w=0 :          REM boolean: will add to sum
  120 q=0 :          REM current number
  130 x=0 :          REM boolean: exit after this line?
  140 REM data for part II: remembering positions of all (!) numbers and *s
  150 DIM num%(3,70):  REM we don't need to remember all data
  160 DIM xl%(3,70):   REM as it would use 40KB of memory
  170 DIM xr%(3,70):   REM so not entirely runnable on an 8-bit
  180 DIM nn%(3)
  190 DIM pos%(140):DIM ypos%(140):pidx=0
  200 GOTO 220
  210 left=0:right=0:num=0: RETURN
  220 GOSUB 210: REM reset left, right, num
  230 sum=0:gears=0
  240 FOR i=0 TO 3
  250   line$(i)=STRING$(140,"."): REM like empty
  260 NEXT i
  270 l$=GET$#fnum TO &0a
  280 line$(c)=l$
  290 REM load next line
  300 l$=GET$#fnum TO &0a
  310 IF LEN(l$)=0 THEN
  320   IF x=0 THEN
  330     l$=STRING$(140,"."):REM imagine last empty line
  340     x=1
  350   ELSE
  360     GOTO 1730:REM print sum and exit
  370   ENDIF
  380 ENDIF
  390 line$(n)=l$
  400 REM we have previous, current, and next line, process
  410 s=0:nidx=0:pidx=0
  420 cl$=line$(c):pl$=line$(p):nl$=line$(n)
  430 IF FALSE THEN
  440   REM debug preview of the lines we process
  450   PRINT"p ",pl$
  460   PRINT"c ",cl$
  470   PRINT"n ",nl$
  480   PRINT""
  490 ENDIF
  500 nn%(c)=0
  510 REM scan "current" line, add (to the sum) numbers that are adjacent to symbols
  520 FOR j=1 TO 140
  530   a$=MID$(pl$,j,1)
  540   GOSUB 1790 : REM set s=1 if previous line had a symbol at j
  550   a$=MID$(cl$,j,1)
  560   GOSUB 1790 : REM set s=1 if current line has a symbol at j
  570   GOSUB 1840 : REM check if it's * in current line
  580   GOSUB 1890 : REM check if this is a digit in current line
  590   a$=MID$(nl$,j,1)
  600   GOSUB 1790 : REM set s=1 if next line has a symbol at j
  610   IF s=1 THEN
  620     w=1 REM whether current line is on a digit or not, and there was a symbol, will add
  630   ENDIF
  640   IF w=1 AND (d=-1 OR j=140) AND q>0 THEN
  650     REM if will add and we exited a number, add it
  660     sum=sum+q
  670     q=0:GOSUB 210
  680   ENDIF
  690   IF s=0 AND d=-1 THEN
  700     w=0 REM if in this column there's no symbol and we're not on a digit,
  710     REM     then it's a space (.) at which we will NOT add the number
  720     q=0:left=0:right=0: REM so forget the number
  730   ENDIF
  740   s=0
  750 NEXT j
  760 REM pass 2 - this time remember all numbers in each p,c,n row
  770 DIM lines%(3)
  780 lines%(1)=p
  790 lines%(2)=c
  800 lines%(3)=n
  810 FOR lineidx=1 TO 3
  820   r=lines%(lineidx)
  830   nn%(r)=0
  840   cl$=line$(r)
  850   q=0:s=0:left=0:right=0:num=0:nidx=0
  860   FOR j=1 TO 140
  870     a$=MID$(cl$,j,1)
  880     GOSUB 1890: REM check if a$ is a digit, update left, right, num,q
  890     IF (d=-1 OR j=140) AND q>0 THEN
  900       REM if we exited a number, add it
  910       GOSUB 2000 : REM store q in xl,xr,num
  920       REM PRINT"there's a ";q;" in line ";r;" as ";nn%(r);"th"
  930       q=0:GOSUB 210
  940     ENDIF
  950   NEXT j
  960   currentline=r
  970   REM GOSUB 900 (debug)
  980 NEXT lineidx
  990
 1000 REM -- READING CURRENT LINE ENDS HERE --
 1010 GOTO 1120
 1020 REM debug :-)
 1030 z=nn%(currentline)
 1040 PRINT"Numbers in line ";currentline;": "
 1050 FOR b=1 TO z
 1060   xleft=xl%(currentline,b)
 1070   xright=xr%(currentline,b)
 1080   PRINT num%(currentline,b);" at ";xleft;",";xright";";
 1090 NEXT b
 1100 PRINT""
 1110 RETURN
 1120 REM now let's do phase 2 check
 1130 FOR a=1 TO pidx
 1140   REM a is index of asterisk, pos%(a) is its position (x coord) in current line
 1150   REM we will check line above, current, and next subsequently
 1160   DIM lines%(3)
 1170   lines%(1)=p
 1180   lines%(2)=c
 1190   lines%(3)=n
 1200   product=1
 1210   found=0
 1220   posa=pos%(a)
 1230   sym$=MID$(line$(c),posa,1)
 1240   REM PRINT"checking ";sym$;" at ";posa
 1250   IF sym$<>"*" THEN GOTO 1560 : REM sanity check, there's a bug somewhere
 1260   FOR lineidx=1 TO 3
 1270     currentline=lines%(lineidx)
 1280     REM GOSUB 900
 1290     z=nn%(currentline): REM how many numbers are in this row
 1300     FOR b=1 TO z
 1310       REM number is adjacent if either ends at pos%(a)-1, starts at pos%(a)+1,
 1320       REM or starts before that but ends after
 1330       numb=num%(currentline,b)
 1340       xleft=xl%(currentline,b)
 1350       xright=xr%(currentline,b)
 1360       IF xright=posa-1 OR xleft=posa+1 OR (xleft<=posa AND xright>=posa) THEN
 1370         REM check exit condition early (too many numbers)
 1380         IF found=2 THEN GOTO 1560
 1390         found=found+1
 1400         IF found=2 THEN
 1410           REM 618,370 is a pair it should not see
 1420           REM PRINT"using ";product;", ";numb
 1430         ENDIF
 1440         product=product*numb
 1450         REM PRINT"* at ";currentline;":";posa;" is adjacent to ";numb;" at (";xleft;",";xright;")"
 1460       ENDIF
 1470     NEXT b
 1480   NEXT lineidx
 1490   IF found=2 THEN
 1500     REM PRINT"adding ";product;" at ",posa
 1510     REM this is an asterisk adjacent to two numbers, add the product
 1520     gears=gears+product
 1530   ELSE
 1540     REM PRINT"not adding",posa
 1550   ENDIF
 1560 NEXT a
 1570
 1580 pidx=0 : REM reset asterisk index, data can stay, will be overwritten
 1590 REM prepare for next line - shift current, prev, next indexes
 1600 IF c=1 THEN
 1610   c=2:p=1:n=0
 1620   GOTO 290
 1630 ENDIF
 1640 IF c=2 THEN
 1650   c=0:p=2:n=1
 1660   GOTO 290
 1670 ENDIF
 1680 IF c=0 THEN
 1690   c=1:p=0:n=2
 1700   GOTO 290
 1710 ENDIF
 1720 IF
 1730 REM End of processing
 1740 PRINT"Done."
 1750 PRINT"sum of part numbers:",sum
 1760 PRINT"Sum of gears",gears
 1770 END
 1780
 1790 REM check if a$ is a symbol
 1800 IF a$<>"." AND (ASC(a$) < &30 OR ASC(a$) > &39) THEN
 1810   s=1 : REM return true :)
 1820 ENDIF
 1830 RETURN
 1840 IF a$="*" THEN
 1850   REM for part 2 of the task, remember position of the asterisk
 1860   pidx=pidx+1 : pos%(pidx)=j
 1870 ENDIF
 1880 RETURN
 1890 REM check if a$ is a digit (and build to q%)
 1900 d=-1
 1910 IF ASC(a$) >= &30 AND ASC(a$) <= &39 THEN
 1920   d=1
 1930   q=10*q+(ASC(a$)-&30)
 1940   REM mark left if not set, keep moving 'right' until done
 1950   right=j
 1960   IF left=0 THEN left=j
 1970   num=q
 1980 ENDIF
 1990 RETURN
 2000 REM procedure for adding current number to numbers seen in a row (for part 2)
 2010 REM r must be row index (from p, c, n)
 2020 nidx=nidx+1
 2030 xl%(r,nidx)=left
 2040 xr%(r,nidx)=right
 2050 REM increse counter of actually used numbers in row
 2060 temp=nn%(r)
 2070 nn%(r)=temp+1
 2080 REM and remember the number
 2090 num%(r,nidx)=q
 2100 RETURN
 2110
