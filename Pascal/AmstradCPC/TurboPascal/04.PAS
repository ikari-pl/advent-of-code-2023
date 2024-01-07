Program day04;

{Uses crt;}

Type
  TextFile = file Of char;
  TwoStrings = Array[0..1] of string[200];
  PTwoStrings = ^TwoStrings;
  PNumberList = ^NumberList;
  NumberList = Record
    num: integer;
   next: PNumberList;
  End;
  LongString = string[200];

Function listToStr(l: PNumberList):LongString;
Var
  n: string[10];
  s: string[200];
Begin
  s := '';
  listToStr := s;
  If l = Nil Then
    exit;
  While l^.next <> Nil Do
    Begin
      l := l^.next;
      Str(l^.num, n);
      s := Concat(s, n);
      s := Concat(s, ' ');
    End;
  listToStr := s;
End;

Type PCard = ^Card;
Card = Record
  id: integer;
  winning: PNumberList;
  have: PNumberList;
End;

Procedure printCard(c: Card);
Begin
  WriteLn('Card ', c.id);
  WriteLn('Winning numbers: ', listToStr(c.winning));
  WriteLn('Have numbers :   ', listToStr(c.have));
End;

Function last(list: PNumberList): PNumberList;
Begin;
  If Nil=list^.next Then
    Begin
      last := list;
      exit;
    End;
  last := last(list^.next);
End;

Procedure append(list: PNumberList; item: integer);
Var
  newItem: PNumberList;
  lastItem: PNumberList;
Begin
  new(newItem);
  newItem^.next := nil;
  newItem^.num := item;
  lastItem := last(list);
  lastItem^.next := newItem;
End;

Procedure disposeList(list: PNumberList);
Begin
  If list <> nil Then Begin
    disposeList(list^.next);
  End;
  Dispose(list);
End;

Function contains(list: PNumberList; itemToFind: integer): boolean;
Var
  item: PNumberList;
Begin
  contains := false;
  item := list; { first one is not used }
  While item^.next <> Nil Do
    Begin
      item := item^.next;
      If item^.num = itemToFind Then
        Begin
          contains := true;
          exit;
        End;
    End;
End;

Function simpleSplit(input: LongString; delimeter: char): PTwoStrings;
Var
  splitAt: integer;
  retVal: PTwoStrings;
Begin
  new(retVal);
  splitAt := Pos(delimeter, input);
  If splitAt = 0 Then
    Begin
      retVal^[0] := input;
      retVal^[1] := '';
      exit;
  End;
  If splitAt = 1 then
    retVal^[0]:=''
  Else
    retVal^[0] := copy(input, 1, splitAt-1);
  retVal^[1] := copy(input, splitAt+1,255);
  simpleSplit:=retVal;
End;

Function trim(input: LongString): LongString;
Var
  pFrom, pTo: integer;
  i: integer;
  c: char;
  label fromFound, toFound;
Begin
  pFrom := 0;
  pTo := Length(input);
  For i := 1 To pTo Do
    Begin
      c := input[i];
      If (ord(c)<>32) And (ord(c) <> 9) Then
        Begin
          pFrom := i;
          goto fromFound;
        End;
    End;
fromFound:
  For i := pTo Downto 0 Do
    Begin
      c := input[i];
      If (ord(c)<>32) And (ord(c)<>9) Then
        Begin
          pTo := i;
          goto toFound;
        End;
    End;
toFound:

If pFrom = 0 then
  trim := ''
Else
  trim := copy(input, pFrom, pTo-pFrom+1);
End;

{
 Helper for tetsting - will print a dot for a passing assertion
 (almost like in Python), and a FAIL (and exit the program)
 if an assertion fails.
}
Procedure assert(expected: boolean; actual: boolean);
Begin
  If expected = actual Then
    Begin
      Write('.');
    End
  Else
    Begin
      WriteLn('FAIL');
      halt;
    End;
End;


Function numbersInString(str: LongString): PNumberList;
Var
  pos: integer;
  l, i: integer;
  val: integer;
  digit: integer;
  haveNumber: boolean;
  retVal: PNumberList;
Begin
  val := 0;
  l := Length(str);
  new(retVal); { retVal := new(PNumberList); }
  haveNumber := false;
  retVal^.next := nil;
  For i := 1 To l Do
    Begin
    { if we have reached a space or elsewhere exited a number }
      If (str[i] < '0') Or (str[i] > '9') Then
        Begin
          If haveNumber = true Then
            Begin
              append(retVal, val);
              haveNumber := false;
              val := 0;
            End; { if had a number }
        End { if not digit }
      Else
        Begin
          haveNumber := true;
          digit := ord(str[i]) - ord('0');
      { shift left (decimal) and add digit }
          val := val*10 + digit;
        End;
    End;
  If haveNumber Then
    append(retVal, val);
  numbersInString := retVal;
End;

Function listLen(l: PNumberList): integer;
Var
  len: integer;
Begin
  len := 0;
  While l <> Nil Do
    Begin
      l := l^.next;
      len := len + 1;
    End;
  listLen := len;
End;


{ Reads one card from the file }
Function readDay04Line(Var F: Text): PCard;
Var
  line: LongString;
  parts: PTwoStrings;
  numbersWeHaveStr: LongString;
  winningNumbersStr: LongString;
  cardNoStr: string[4];
  cardNoInt: integer;
  code: integer;

  cardNo: PNumberList;
  winningNumbers: PNumberList;
  haveNumbers: PNumberList;

  retVal: PCard;
Begin
  new(retVal);
  readDay04Line := retVal;
  ReadLn(f, line);
  parts := simpleSplit(line, '|');
  numbersWeHaveStr := parts^[1];

  parts := simpleSplit(parts^[0], ':');
  cardNoStr := trim(Copy(parts^[0], 5, 10));
  winningNumbersStr := parts^[1];
  Dispose(parts);

  { use built-in integer parser for once }
  Val(cardNoStr, cardNoInt, code);
  if code <> 0 then
  begin
    WriteLn('cardNoStr: "',cardNoStr,'", cardNoInt: ',cardNoInt,', code: ',code);
    halt;
  end;
  winningNumbers := numbersInString(winningNumbersStr);
  haveNumbers := numbersInString(numbersWeHaveStr);

  retVal^.id := cardNoInt;
  retVal^.winning := winningNumbers;
  retVal^.have := haveNumbers;
End;

Procedure testStrings;
Var
  line: LongString;
  twoLines: PTwoStrings;
Begin
  line := 'a|b';
  twoLines := simpleSplit(line, '|');
  assert(true, twoLines^[0]='a');
  assert(true, twoLines^[1]='b');
  assert(true, trim(' a ') = 'a');
  assert(true, trim('a') = 'a');
  assert(true, trim(' bc') = 'bc');
  assert(true, trim('de ') = 'de');
  Dispose(twoLines);
End;

Function countMatches(c: Card): integer;
Var
  sum: integer;
  numWeHave: PNumberList;
  list: PNumberList;
Begin
  numWeHave := c.have;
  If numWeHave^.next = Nil Then Exit;

  sum := 0;
  Repeat
    numWeHave := numWeHave^.next;
    list := c.winning;
    If contains(list, numWeHave^.num) Then
      Begin
        { For part 1 of the task, it would be also just enough }
        { If we started sum with 1, shift left by 1 bit here,  }
        { and shift it right by 1 bit at the end.              }
        sum := sum + 1;
      End { contains winning }
  Until numWeHave^.next = Nil;
  countMatches := sum;
End;

Function pointsOf(c: Card): integer;
Var
  matches: integer;
  pts: integer;
  i: integer;
Begin
  matches := countMatches(c);
  pts := 0;
  If matches > 0 Then
    Begin
      pts := 1 shl (matches-1);
    End;
  pointsOf := pts;
End;


Procedure testList;
Var
  testList: PNumberList;
Begin
  new(testList); { testList := new(PNumberList); }
  append(testList, 1);
  append(testList, 20);
  append(testList, 300);
  assert(true, contains(testList, 20));
  assert(false, contains(testList, 5));
  WriteLn('PASS');
  DisposeList(testList);
  WriteLn('cleaned up');
End;

type CircularBuffer = Array[0..24] of Real;
Var
  inFile: Text;
  c: PCard;
  p: integer;
  total: real;
  { part 2 vars }
  cards: real;
  copies: real;
  cardsToMultiply: CircularBuffer;
  ctmIndex: byte;
  i: byte;
  idx: byte;
label EOFLabel;
Begin
  ClrScr;
  testList;
  testStrings;
  WriteLn;
  WriteLn('*** Advent Of Code, Day 04, Turbo Pascal ***');
  Assign(inFile, '04.txt');
  Reset(inFile);
  total := 0;
  cards := 0;
  p := 0;
  ctmIndex := 0;
  For i := 0 To 24 Do
    Begin
      If cardsToMultiply[i] <> 0 Then
        Begin
          WriteLn('Need to initialize arrays');
          cardsToMultiply[i] := 0;
        End;
    End;

  { start looping through the file }
  While true Do
    Begin
      c := ReadDay04Line(inFile);
      If c^.have^.next = Nil Then
        GoTo EOFLabel;
      { Preview the card }
      PrintCard(c^);

      { Calc part 1 points }
      p := pointsOf(c^);
      WriteLn(p,' points.');
      total := total + p;

      { Part 2: get raw match number, count doubled cards }
      p := countMatches(c^);
      WriteLn(p, ' matching numbers.');
      { We have an array (no generic list implemented in TP, so...)  }
      { of the next cards to double/triple, and by how much.         }
      { To avoid the cost of shifting the entire array (we could use }
      { a cyclic buffer, but that's more hops along the pointers and }
      { we're doing plenty already), we have a index within the      }
      { array pointing to "current" entry.                           }
      cards := cards + 1; { count current card }
      copies := cardsToMultiply[ctmIndex];
      WriteLn('We also got it in ',copies:8:0,' extra copies');
      cards := cards + copies; { and copies }
      { update the number of copies for subsequent cards: }
      { we will reuse 'copies' var here; it now means number of copies }
      { that this card will *cause* in the subsequent cards            }
      { (which is number of points times how many copies of it we got) }
      copies := (copies+1);
      WriteLn('It will win copies of ',p,' cards: ');
      For i := 1 To p Do
        Begin
          idx := (ctmIndex + i) Mod 25;
          cardsToMultiply[idx] := cardsToMultiply[idx] + copies;
          Write(i + c^.id, '(x', cardsToMultiply[idx]:8:0 ,'), ');
        End;
      WriteLn('', chr(13), chr(10));
      cardsToMultiply[ctmIndex] := 0;
      ctmIndex := (ctmIndex + 1) Mod 25;
      DisposeList(c^.winning);
      DisposeList(c^.have);
      Dispose(c);
    End;
EOFLabel:
  WriteLn('---');
  WriteLn('Part 1 solution:',total:10:0);
  WriteLn('Part 2 solution:',cards:10:0);
End.
