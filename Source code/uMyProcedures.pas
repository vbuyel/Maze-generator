{ Unit with useful procedures }
Unit uMyProcedures;

Interface

// Unit and library
Uses
  uSharedData, StdCtrls;

Procedure ENameEnter(EName: TEdit; Text: String);
Procedure ENameExit(EName: TEdit; Text: String);
Function LoadMap(var ThisMap: TMap; var ThisWay: TAlgorArray; var MapH, MapW: Integer): Boolean;
Function LoadFromExcel(var ThisMap: TMap; var ThisWay: TAlgorArray; ThisExcel: Variant; var MapH, MapW: Integer): boolean;
Procedure FindWay(var ThisMap: TMap; Memo: TMemo; MapH, MapW, EndPX, EndPY: Integer);
Procedure GenerateThisMaze(var ThisMap: TMap; Sender: TObject; var MapH, MapW: Integer);
Procedure BuildExit(var ThisMaze: TAlgorArray; StartX, StartY, ExitX, ExitY, Value: Integer; MapH, MapW: Integer);

Implementation

// Used units and libraries
Uses
  uProgramRun, Graphics, SysUtils, uShowMaze, Dialogs,
  Variants, Windows, uDFS, uBFS, uAStar, uPrim;

// Hide text
Procedure ENameEnter(EName: TEdit; Text: String);
Begin
  If EName.Text = Text then
  Begin
    EName.Text := '';
    EName.Font.Color := clBlack;
  End;
End;

// Show text
Procedure ENameExit(EName: TEdit; Text: String);
Begin
  If EName.Text = '' then
  Begin
    EName.Text := Text;
    EName.Font.Color := clGray;
  End;
End;

// Upload map from the txt file
Function LoadMap(var ThisMap: TMap; var ThisWay: TAlgorArray; var MapH, MapW: Integer): Boolean;
{
 ThisMap - current map
 ThisWay - the way to the end
 MapH, MapW - map size
}
Var
  i, j: Integer;
  S: String;
  WithBorders: Boolean;
{
 i, j - index
 S - for uploading each line
 WithBorders - check
}
Begin
  // Initialisation
  MapH := FShowMaze.MWithMaze.Lines.Count;
  MapW := Length(Trim(FShowMaze.MWithMaze.Lines[0]));
  Result := True;

  // Check on borders (first line)
  WithBorders := True;
  S := FShowMaze.MWithMaze.Lines[0];
  For i := 0 to MapW-1 do
    WithBorders := WithBorders and ( (LowerCase(S[i+1]) = 'x')
                                      or (LowerCase(S[i+1]) = 's')
                                      or (LowerCase(S[i+1]) = 'e') );

  MapH := MapH + 2*Ord(not WithBorders);
  MapW := MapW + 2*Ord(not WithBorders);

  SetLength(ThisMap, MapH, MapW);
  SetLength(ThisWay, MapH, MapW);

  // From txt to the map
  For i := 0 to MapH-1 do
  Begin
    S := FShowMaze.MWithMaze.Lines.Strings[i - Ord(not WithBorders)];
    S := LowerCase(S);
    For j := 0 to MapW-1 do
    Begin
      If WithBorders then
        ThisMap[i, j] := S[j+1]
      Else
        If (i = 0) or (j = 0) or (i = MapH-1) or (j = MapW-1) then
          ThisMap[i, j] := 'x'
        Else
          ThisMap[i, j] := S[j];
    End;
  End;

  // If map is too small
  If (MapH < 3) or (MapW < 3) then
  Begin
    ShowMessage('Øèðèíà è âûñîòà äîëæíà áûòü áîëüøå 2 ÿ÷ååê');
    Result := False;
  End;
End;

// Load map from the excel file
Function LoadFromExcel(var ThisMap: TMap; var ThisWay: TAlgorArray; ThisExcel: Variant; var MapH, MapW: Integer): boolean;
{
 ThisMap - current map
 ThisWay - the way to the end
 ThisExcel - the excel file
 MapH, MapW - map size
}
Var
  Counter, i, j: integer;
  WithBorders: boolean;
{
 Counter - counter
 i, j - index
 WithBorders - check
}
begin
  // Initialisation
  Counter := 1;
  Result := False;

  while (VarIsEmpty(ThisExcel.Cells[Counter, 1].Value)) and (Counter < 1000) do
    Inc(Counter);

  MapH := 1;
  MapW := 1;
  WithBorders := True;

  // Check if with borders
  while not VarIsEmpty(ThisExcel.Cells[Counter, MapW].Value) do
  begin
    WithBorders := WithBorders and ( (LowerCase(VarToStr(ThisExcel.Cells[Counter, 1].Value)[1]) = 'x')
                                      or (LowerCase(VarToStr(ThisExcel.Cells[Counter, 1].Value)[1]) = 's')
                                      or (LowerCase(VarToStr(ThisExcel.Cells[Counter, 1].Value)[1]) = 'e') );
    Inc(MapW);
  end;
  Dec(MapW);
  i := Counter;

  // Check if with borders
  while not VarIsEmpty(ThisExcel.Cells[i, 1].Value) do
  begin
    WithBorders := WithBorders and ( (LowerCase(VarToStr(ThisExcel.Cells[i, 1].Value)[1]) = 'x')
                                      or (LowerCase(VarToStr(ThisExcel.Cells[i, 1].Value)[1]) = 's')
                                      or (LowerCase(VarToStr(ThisExcel.Cells[i, 1].Value)[1]) = 'e') );
    Inc(i);
    Inc(MapH);
  end;
  Dec(MapH);

  MapH := MapH + 2*Ord(not WithBorders);
  MapW := MapW + 2*Ord(not WithBorders);

  SetLength(ThisMap, MapH, MapW);
  SetLength(ThisWay, MapH, MapW);

  // From excel to the map
  For i := 0 to MapH-1 do
    For j := 0 to MapW-1 do
      If VarIsEmpty(ThisExcel.Cells[i+1, 1].Value) then
        ThisMap[i, j] := 'x'
      Else
        If WithBorders then
          ThisMap[i, j] := VarToStr(ThisExcel.Cells[Counter + i, j+1].Value)[1]
        Else
          If (i = 0) or (j = 0) or (i = MapH-1) or (j = MapW-1) then
            ThisMap[i, j] := 'x'
          Else
            ThisMap[i, j] := VarToStr(ThisExcel.Cells[Counter + i, j].Value)[1];

  // If map is too small
  If (MapH < 3) or (MapW < 3) then
  Begin
    ShowMessage('Øèðèíà è âûñîòà äîëæíà áûòü áîëüøå 2 ÿ÷ååê');
    Result := True;
  End;

  // Map is not founded
  If Counter = 1000 then
  Begin
    ShowMessage('Ëàáèðèíò íå íàéäåí');
    Result := True;
  End;
end;

// Generate the maze
Procedure GenerateThisMaze(var ThisMap: TMap; Sender: TObject; var MapH, MapW: Integer);
{
 ThisMap - current map
 Sender - activated object
 MapH, MapW - map size
}
Var
  SFromEdge, EInEdge: Boolean;
  HError, WError: integer;
  SizeCoef: integer;
{
 SFromEdge, EInEdge - check where is start and end
 HError, WError - errors
 SizeCoef - coefficient
}
Begin
  // Initialization
  HError := 0;
  WError := 0;

  // Checking
  Val(FProgramRun.EMazeHeight.Text, MapH, HError);
  Val(FProgramRun.EMazeWidth.Text, MapW, WError);
  Inc(HError, Ord((MapH < 3) or (MapH > 100)));
  Inc(WError, Ord((MapW < 3) or (MapW > 100)));

  // If size is correct
  If (HError > 0) or (WError > 0) then
  Begin
    If WError > 0 then
      FProgramRun.EMazeWidth.Font.Color := clRed;
    If HError > 0 then
      FProgramRun.EMazeHeight.Font.Color := clRed;

    ShowMessage('Ââåäèòå (âûñîòó > 2) è (øèðèíó > 2) ëàáèðèíòà ïåðåä ãåíåðàöèåé');
  End
  Else
  Begin
    // Prim's algorithm
    PrimAlgorithm(Map, Way, MapH, MapW);

    MapH := MapH + 2;
    MapW := MapW + 2;

    // Form size
    SizeCoef := (612*612) div (MapH*MapW);
    FShowMaze.ClientHeight := MapH * Trunc(Sqrt(SizeCoef));
    FShowMaze.ClientWidth := MapW * Trunc(Sqrt(SizeCoef));

    FProgramRun.BGenerate.Enabled := False;
    FShowMaze.Show;

    // Check for start and end (location)
    SFromEdge := (FProgramRun.CBStartFrom.ItemIndex = 0);
    EInEdge := (FProgramRun.CBEndIn.ItemIndex = 0);

    // Choosing start point
    Repeat
      MazeStart.X := Random(MapH-2) + 1;
      MazeStart.Y := Random(MapW-2) + 1;

      // Start from (user)
      If SFromEdge then
      Begin
        Repeat
          MazeStart.X := Random(MapH);
          MazeStart.Y := Random(MapW);

          SFromEdge := ( (MazeStart.X = 0) or (MazeStart.X = MapH-1) );
          SFromEdge := SFromEdge or ( (MazeStart.Y = 0) or (MazeStart.Y = MapW-1) );
        Until SFromEdge;

        // Can be a start point
        If (MazeStart.X = 0) and (Map[MazeStart.X+1][MazeStart.Y] = '0') then
          Map[MazeStart.X, MazeStart.Y] := '0'
        Else
          If (MazeStart.X = MapH-1) and (Map[MazeStart.X-1][MazeStart.Y] = '0') then
            Map[MazeStart.X, MazeStart.Y] := '0';

        If (MazeStart.Y = 0) and (Map[MazeStart.X][MazeStart.Y+1] = '0') then
          Map[MazeStart.X, MazeStart.Y] := '0'
        Else
          If (MazeStart.Y = MapW-1) and (Map[MazeStart.X][MazeStart.Y-1] = '0') then
            Map[MazeStart.X, MazeStart.Y] := '0';
      End;

    Until (Map[MazeStart.X, MazeStart.Y] = '0');
    Map[MazeStart.X, MazeStart.Y] := 'S';

    // Choosing end point
    Repeat
      MazeEnd.X := Random(MapH-2) + 1;
      MazeEnd.Y := Random(MapW-2) + 1;

      // End in (user)
      If EInEdge then
      Begin
        Repeat
          MazeEnd.X := Random(MapH);
          MazeEnd.Y := Random(MapW);

          EInEdge := (MazeEnd.X = 0) or (MazeEnd.X = MapH-1);
          EInEdge := EInEdge or ( (MazeEnd.Y = 0) or (MazeEnd.Y = MapW-1) );
          EInEdge := EInEdge and ( (MazeStart.X <> MazeEnd.X) and (MazeStart.Y <> MazeEnd.Y) );

          If (Abs(MazeStart.X - MazeEnd.X) <= 1)
            and (Abs(MazeStart.Y - MazeEnd.Y) <= 1) then
            EInEdge := False;
        Until EInEdge;

        // Can be end point
        If (MazeEnd.X = 0) and (Map[MazeEnd.X+1][MazeEnd.Y] = '0') then
          Map[MazeEnd.X, MazeEnd.Y] := '0'
        Else
          If (MazeEnd.X = MapH-1) and (Map[MazeEnd.X-1][MazeEnd.Y] = '0') then
            Map[MazeEnd.X, MazeEnd.Y] := '0';

        If (MazeEnd.Y = 0) and (Map[MazeEnd.X][MazeEnd.Y+1] = '0') then
          Map[MazeEnd.X, MazeEnd.Y] := '0'
        Else
          If (MazeEnd.Y = MapW-1) and (Map[MazeEnd.X][MazeEnd.Y-1] = '0') then
            Map[MazeEnd.X, MazeEnd.Y] := '0';

      End;

    Until (Map[MazeEnd.X, MazeEnd.Y] = '0');
    Map[MazeEnd.X, MazeEnd.Y] := 'E';
  End;

  // Show the result maze
  FShowMaze.PBMazePaint(FShowMaze.PBMaze);
End;

// Finding the way
Procedure FindWay(var ThisMap: TMap; Memo: TMemo; MapH, MapW, EndPX, EndPY: Integer);
{
 ThisMap - current map
 Memo - where the result shows
 MapH, MapW - map size
 EndPX, EndPY - the end point location
}
Var
  CanBeSolved: Boolean;
  tmStart, tmEnd: Integer;
{
 CanBeSolved - check on exit
 tmStart - start time counter
 tmEnd - end time counter
}
Begin
  // BFS àëãîðèòì
  tmStart := GetTickCount;
  CanBeSolved := BFSAlgorithm(ThisMap, MazeStart.X, MazeStart.Y, MazeEnd.X, MazeEnd.Y, MapH, MapW);
  tmEnd := GetTickCount;

  If CanBeSolved then
  Begin
    FProgramRun.MSpeedTest.Clear;
    FProgramRun.MSpeedTest.Lines.Add('BFS: ' + IntToStr(tmEnd - tmStart) + ' ms');

    // A* àëãîðèòì
    tmStart := GetTickCount;
    AStarAlgorithm(ThisMap, MazeStart.X, MazeStart.Y, MazeEnd.X, MazeEnd.Y, MapH, MapW);
    tmEnd := GetTickCount;

    FProgramRun.MSpeedTest.Lines.Add('A*: ' + IntToStr(tmEnd - tmStart) + ' ms');

    // DFS àëãîðèòì
    tmStart := GetTickCount;
    DFSAlgorithm(ThisMap, MazeStart.X, MazeStart.Y, MazeEnd.X, MazeEnd.Y, MapH, MapW);
    tmEnd := GetTickCount;

    FProgramRun.MSpeedTest.Lines.Add('DFS: ' + IntToStr(tmEnd - tmStart) + ' ms');
  End;
End;

// Build exit line
Procedure BuildExit(var ThisMaze: TAlgorArray; StartX, StartY, ExitX, ExitY, Value: Integer; MapH, MapW: Integer);
{
 ThisMaze - current maze
 StartX, StartY - start position
 ExitX, ExitY - end position
 Value - depend on the algorithm
 MapH, MapW - map size
}
Var
  i, j: Byte;
  Up, Down, Left, Right: Boolean;
{
 i, j - index
 Up, Down, Left, Right - directions
}
Begin
  // Initialisation
  i := ExitX;
  j := ExitY;

  // From end to start
  While (i <> StartX) or (j <> StartY) do
  Begin
    // Choose direction
    Up := (i > 0)
      and (ThisMaze[i][j] > ThisMaze[i-1][j])
      and (ThisMaze[i-1][j] <> -1) and (ThisMaze[i-1][j] <> Value) and (ThisMaze[i-1][j] <> 0);
    Down := (i < MapH-1)
      and (ThisMaze[i][j] > ThisMaze[i+1][j])
      and (ThisMaze[i+1][j] <> -1) and (ThisMaze[i+1][j] <> Value) and (ThisMaze[i+1][j] <> 0);
    Left := (j > 0)
      and (ThisMaze[i][j] > ThisMaze[i][j-1])
      and (ThisMaze[i][j-1] <> -1) and (ThisMaze[i][j-1] <> Value) and (ThisMaze[i][j-1] <> 0);
    Right := (j < MapW-1)
      and (ThisMaze[i][j] > ThisMaze[i][j+1])
      and (ThisMaze[i][j+1] <> -1) and (ThisMaze[i][j+1] <> Value) and (ThisMaze[i][j+1] <> 0);

    ThisMaze[i][j] := Value;

    // Prepare for the next cycle
    If Up then Dec(i);
    If Down then Inc(i);
    If Left then Dec(j);
    If Right then Inc(j);
  End;

  // Initialisation of the start position
  ThisMaze[i][j] := Value;

  // Show this line of Value
  WriteLine(ThisMaze, Value, StartX, StartY, ExitX, ExitY, MapH, MapW);
End;

end.
