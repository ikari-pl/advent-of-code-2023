
Program day04;

Uses crt;

Type TextFile = file Of char;

Type TwoStrings = Array[0..1] Of string;

Type NumberList = Record
  num: integer;
  next: ^NumberList;
End;

Type PNumberList = ^NumberList;

Function listToStr(l: PNumberList): string;
Var 
  n: string;
  s: string;
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

Type Card = Record
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
Begin
  newItem := new(PNumberList);
  newItem^.num := item;
  last(list)^.next := newItem;
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

Function simpleSplit(input: String; delimeter: char): TwoStrings;
Var 
  splitAt: integer;
Begin
  splitAt := Pos(delimeter, input);
  If splitAt = 0 Then
    Begin
      simpleSplit[0] := input;
      simpleSplit[1] := '';
      exit;
    End;
  simpleSplit[0] := copy(input, 0, splitAt-1);
  simpleSplit[1] := copy(input, splitAt+1);
End;

Function trim(input: String): string;
Var 
  pFrom, pTo: integer;
  i: integer;
  c: char;
Begin
  pFrom := 0;
  pTo := Length(input);
  For i := 1 To pTo Do
    Begin
      c := input[i];
      If (ord(c)<>32) And (ord(c) <> 9) Then
        Begin
          pFrom := i;
          break;
        End;
    End;
  For i := pTo Downto 0 Do
    Begin
      c := input[i];
      If (ord(c)<>32) And (ord(c)<>9) Then
        Begin
          pTo := i;
          break;
        End;
    End;

  trim := copy(input, pFrom, pTo-pFrom+1);
End;

// Helper for tetsting - will print a dot for a passing assertion
// (almost like in Python), and a FAIL (and exit the program) if an assertion fails.
Procedure assert(expected: boolean; actual: boolean);
Begin
  If expected = actual Then
    Begin
      Write('.');
    End
  Else
    Begin
      WriteLn('FAIL');
      halt(1);
    End;
End;


Function numbersInString(str: String): PNumberList;
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
  retVal := new(PNumberList);
  haveNumber := false;
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


// Reads one card from the file
Function readDay04Line(Var F: Text): Card;
Var 
  line: string;
  parts: TwoStrings;
  numbersWeHaveStr: string;
  winningNumbersStr: string;
  cardNoStr: string;
  cardNoInt: integer;
  code: integer;

  cardNo: PNumberList;
  winningNumbers: PNumberList;
  haveNumbers: PNumberList;
Begin
  ReadLn(f, line);
  parts := simpleSplit(line, '|');
  numbersWeHaveStr := parts[1];

  parts := simpleSplit(parts[0], ':');
  cardNoStr := Copy(parts[0], 5);
  winningNumbersStr := parts[1];

  { use built-in integer parser for once }
  Val(cardNoStr, cardNoInt, code);
  winningNumbers := numbersInString(winningNumbersStr);
  haveNumbers := numbersInString(numbersWeHaveStr);

  readDay04Line.id := cardNoInt;
  readDay04Line.winning := winningNumbers;
  readDay04Line.have := haveNumbers;
End;

Procedure testStrings;
Var 
  line: string;
  twoLines: TwoStrings;
Begin
  line := 'a|b';
  twoLines := simpleSplit(line, '|');
  assert(true, twoLines[0]='a');
  assert(true, twoLines[1]='b');
  assert(true, trim(' a ') = 'a');
  assert(true, trim('a') = 'a');
  assert(true, trim(' bc') = 'bc');
  assert(true, trim('de ') = 'de');
End;

Function pointsOf(c: Card): integer;
Var 
  sum: integer;
  numWeHave: PNumberList;
Begin
  numWeHave := c.have;
  If c.have^.next = Nil Then Exit;

  sum := 1; { we'll ignore youngest bit later }
  Repeat
    numWeHave := numWeHave^.next;
    If contains(c.winning, numWeHave^.num) Then
      Begin
        sum := sum shl 1;
      End { contains winning }
  Until numWeHave^.next = Nil;

  pointsOf := sum shr 1;
End;


Procedure testList;
Var 
  testList: PNumberList;
Begin
  testList := new(PNumberList);
  append(testList, 1);
  append(testList, 20);
  append(testList, 300);
  assert(true, contains(testList, 20));
  assert(false, contains(testList, 5));
  WriteLn('PASS');
End;

Var 
  inFile: Text;
  c: Card;
  p: integer;
  total: real;
Begin
  ClrScr();
  testList;
  testStrings;
  WriteLn();
  WriteLn('*** Advent Of Code, Day 04, Turbo Pascal ***');
  Assign(inFile, '04.txt');
  Reset(inFile);
  total := 0;
  p := 0;

  { start looping through the file }
  While true Do
    Begin
      c := ReadDay04Line(inFile);
      If c.have^.next = Nil Then
        break;
      PrintCard(c);
      p := pointsOf(c);
      WriteLn(p,' points.',chr(13),chr(10));
      total := total + p;
    End;
  WriteLn('---');
  WriteLn('Total:');
  WriteLn(total:10:0);
End.
