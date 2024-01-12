{    Advent Of Code  2023 - day 04 solution    }
{ (c)2024 RetroFun.pl / Cezar "ikari" Pokorski }
{                                              }
{        This program compiles under under     }
{           Turbo Pascal v3.00 on CP/M         }
{  (tested with Amstrad CPC6128 with CP/M Plus }
{   and Turbo Pascal 3.00, and on CP/M for Mac }
{  with Turbo Pascal 3.01)                     }
Program day04;

Type
  TextFile = file Of char;
  TwoStrings = Array[0..1] of string[200];
  PTwoStrings = ^TwoStrings;
  PNumberList = ^NumberList;
  NumberList = Record
    num: integer;
   next: PNumberList;
  End;
  LongString = string[140];

Function listToStr(var l: PNumberList):LongString;
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

Procedure append(var list: PNumberList; item: integer);
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

Procedure disposeList(var list: PNumberList);
Begin
  If (list <> nil) and (list^.next <> nil) Then Begin
    disposeList(list^.next);
  End;
  {if list <> nil then
    Dispose(list);}
End;

Function contains(var list: PNumberList; itemToFind: integer): boolean;
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

Procedure simpleSplit(input: LongString; delimeter: char; var left: LongString; var right:LongString);
Var
  splitAt: integer;
Begin
  splitAt := Pos(delimeter, input);
  If splitAt = 0 Then
    Begin
      left := input;
      right := '';
      exit;
  End;
  If splitAt = 1 then
    left:=''
  Else
    left := copy(input, 1, splitAt-1);
  right := copy(input, splitAt+1,255);
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
 Helper for testing - will print a dot for a passing assertion
 (almost like in Python), and a FAIL (and exit the program)
 if an assertion fails.
}
Procedure assert(expected: boolean; actual: boolean);
Begin
  If expected = actual Then
      Write('.')
  Else
    Begin
      WriteLn('FAIL');
      halt;
    End;
End;


Function numbersInString(var str: LongString): PNumberList;
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
  While (l <> Nil) and (l^.next <> nil) Do
    Begin
      l := l^.next;
      len := len + 1;
    End;
  listLen := len;
End;


{ Reads one card from the file }
Function readDay04Line(Var F: Text): PCard;
Var
  line: string[116];
  left, right: LongString;
  numbersWeHaveStr: LongString;
  winningNumbersStr: LongString;
  cardNoStr: string[4];
  cardNoInt: integer;
  code: integer;

  cardNo: PNumberList;
  winningNumbers: PNumberList;
  haveNumbers: PNumberList;

  s: string[100];
  retVal: PCard;
Begin
  ReadLn(f, line);
  new(retVal);
  simpleSplit(line, '|', left, right);
  numbersWeHaveStr := right;

  s := left;
  simpleSplit(s, ':', left, right);
  cardNoStr := trim(Copy(left, 5, 10));
  winningNumbersStr := Copy(right, 1, 255);

  { use built-in integer parser for once }
  Val(cardNoStr, cardNoInt, code);
  if code <> 0 then
  begin
    { no input? Must have ran out of lines }
    retVal^.id := 0;
    retVal^.winning := nil;
    retVal^.have := nil;
  end;

  winningNumbers := numbersInString(winningNumbersStr);
  haveNumbers := numbersInString(numbersWeHaveStr);
  retVal^.id := cardNoInt;
  retVal^.winning := winningNumbers;
  retVal^.have := haveNumbers;
  readDay04Line := retVal;
End;

Procedure testStrings;
Var
  line: LongString;
  left, right: LongString;
Begin
  line := 'a|b';
  simpleSplit(line, '|', left, right);
  assert(true, left='a');
  assert(true, right='b');
  assert(true, trim(' a ') = 'a');
  assert(true, trim('a') = 'a');
  assert(true, trim(' bc') = 'bc');
  assert(true, trim('de ') = 'de');
  WriteLn('PASS');
End;

Function countMatches(c: Card): integer;
Var
  sum: integer;
  numWeHave: PNumberList;
  list: PNumberList;
Begin
  countMatches := 0;
  numWeHave := c.have;
  If numWeHave^.next = Nil Then Exit;

  sum := 0;
  Repeat
    numWeHave := numWeHave^.next;
    If contains(c.winning, numWeHave^.num) Then
        { For part 1 of the task, it would be also just enough }
        { If we started sum with 1, shift left by 1 bit here,  }
        { and shift it right by 1 bit at the end.              }
        sum := sum + 1;
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
      pts := 1 shl (matches-1);
  pointsOf := pts;
End;


Procedure testList;
Var
  testList: PNumberList;
Begin
  new(testList); { testList := new(PNumberList); }
  testList^.next := nil;
  append(testList, 1);
  append(testList, 20);
  append(testList, 300);
  assert(true, contains(testList, 20));
  assert(false, contains(testList, 5));
  WriteLn('PASS');
  DisposeList(testList);
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
  mem: ^integer;
label EOFLabel;
Begin
  ClrScr;
  testList;
  testStrings;
  WriteLn;
  WriteLn('*** Advent Of Code, Day 04, Turbo Pascal ***');
  Write('Available memory: ');
  WriteLn(MemAvail);
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
      Mark(mem);
      c := ReadDay04Line(inFile);
      If ListLen(c^.have) = 0 Then
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
      if p > 25 then begin
        WriteLn('ok, that''s too much');
        goto EOFLabel;
      end;
      For i := 1 To p Do
        Begin
          idx := (ctmIndex + i) Mod 25;
          cardsToMultiply[idx] := cardsToMultiply[idx] + copies;
          Write(i + c^.id, '(x', cardsToMultiply[idx]:8:0 ,'), ');
        End;
      WriteLn('', chr(13), chr(10));
      cardsToMultiply[ctmIndex] := 0;
      ctmIndex := (ctmIndex + 1) Mod 25;
      {DisposeList(c^.winning);
      DisposeList(c^.have);
      Dispose(c;}
      Release(mem);
    End;
EOFLabel:
  WriteLn('---');
  WriteLn('Part 1 solution:',total:10:0);
  WriteLn('Part 2 solution:',cards:10:0);
End.

