{ Unit with algorithm A-Star }
Unit uAStar;

Interface

Uses
  uSharedData;

Procedure AStarAlgorithm(var ThisMap: TMap; StartX, StartY, EndX, EndY: ShortInt; MapH, MapW: Integer);

Implementation

// Used units
Uses
  uProgramRun, uMyProcedures, StdCtrls;

// Res = (x - x0)^2 + (y - y0)^2
Function Pifagor(x, y, MazeEndX, MazeEndY: Integer): Integer;
{
 x - current position on 'X'
 y - current position on 'Y'
 MazeEndX - end coordinate 'X'
 MazeEndY - end coordinate 'Y'
}
Begin
  Pifagor := Sqr(x - MazeEndX) + Sqr(y - MazeEndY);
End;

// Compare cells around the current position
Function CompareF(var FindF, ThisG: TAlgorArray; x, y: Integer; var ThisWay: PWay; MapH, MapW, ThisEndX, ThisEndY: Integer): Integer;
{
 FindF, FindG - the maze in the array
 x, y - current position
 ThisWay - way to the end
 MapH, MapW - size
 ThisEndX, ThisEndY - end position
}
Var
  Up, Down, Left, Right: Boolean;
  Check: Array of PCheck;
  Temp: PCheck;
  i, k: 0..4;
{
 Up, Down, Left, Right - directions
 Check - array of checked positions
 Temp - time variable
 i, k - array index
}
Begin
  // Initialisation
  Up := True;
  Down := True;
  Left := True;
  Right := True;

   // Checking directions
  If (y = 0) or (FindF[x, y-1] = -1) then Left := False;
  If (y = MapW-1) or (FindF[x, y+1] = -1) then Right := False;
  If (x = 0) or (FindF[x-1, y] = -1) then Up := False;
  If (x = MapH-1) or (FindF[x+1, y] = -1) then Down := False;

  SetLength(Check, Ord(Up) + Ord(Down) + Ord(Left) + Ord(Right));
  i := 0;

  // Adding directions
  If Up then
  Begin
    New(Check[i]);
    Check[i].X := x-1;
    Check[i].Y := y;
    If FindF[x-1, y] = 0 then FindF[x-1, y] := (ThisG[x, y] + 1) + Pifagor(x-1, y, ThisEndX, ThisEndY);
    Check[i].Value := FindF[x-1, y];
    Inc(i);
  End;
  If Down then
  Begin
    New(Check[i]);
    Check[i].X := x+1;
    Check[i].Y := y;
    If FindF[x+1, y] = 0 then FindF[x+1, y] := (ThisG[x, y] + 1) + Pifagor(x+1, y, ThisEndX, ThisEndY);
    Check[i].Value := FindF[x+1, y];
    Inc(i);
  End;
  If Left then
  Begin
    New(Check[i]);
    Check[i].X := x;
    Check[i].Y := y-1;
    If FindF[x, y-1] = 0 then FindF[x, y-1] := (ThisG[x, y] + 1) + Pifagor(x, y-1, ThisEndX, ThisEndY);
    Check[i].Value := FindF[x, y-1];
    Inc(i);
  End;
  If Right then
  Begin
    New(Check[i]);
    Check[i].X := x;
    Check[i].Y := y+1;
    If FindF[x, y+1] = 0 then FindF[x, y+1] := (ThisG[x, y] + 1) + Pifagor(x, y+1, ThisEndX, ThisEndY);
    Check[i].Value := FindF[x, y+1];
  End;

  // Sort (..>..>..)
  If length(Check) > 1 then
  Begin
    For i := 0 to length(Check)-2 do
      For k := i+1 to length(Check)-1 do
        If Check[i].Value > Check[k].Value then
        Begin
          // Swap
          Temp := Check[i];
          Check[i] := Check[k];
          Check[k] := Temp;
        End;
  End;

  // Checking result of sort
  If (ThisWay^.StepPrev <> nil) and (Check[0].Value = ThisWay.StepPrev.Value) then
  Begin
    FindF[x, y] := FindF[ThisWay.Step.X, ThisWay.Step.Y] + 100;

    If (ThisWay <> nil) and (ThisWay^.StepPrev <> nil) then
    Begin
      ThisWay^.Step := nil;
      Dispose(ThisWay^.Step);
      ThisWay := ThisWay^.StepPrev;
      ThisWay^.StepNext^.StepPrev := nil;
      ThisWay^.StepNext := nil;
      Dispose(ThisWay^.StepNext);
    End;

  End
  Else
    Result := Check[0].Value;
End;

// Main A-Star algorithm
Procedure AStarAlgorithm(var ThisMap: TMap; StartX, StartY, EndX, EndY: ShortInt; MapH, MapW: Integer);
{
 ThisMap - current map
 StartX - start position 'X'
 StartY - start position 'Y'
 EndX - end position 'X'
 EndY - end position 'Y'
 MapH, Map - map size
}
Var
  i, j, BestValue: Integer;
  FoundWay: PWay;
  F, G: TAlgorArray;
  H: Integer;
{
 i, j - index
 BestValue - the best neighbour value
 F, G - maze
 H - pifagor
}
Begin
  // Initialisation
  SetLength(G, MapH, MapW);
  SetLength(F, MapH, MapW);

  For i := 0 to MapH-1 do
    For j := 0 to MapW-1 do
    Begin
      Case ThisMap[i, j] of
        'x':
        begin
          F[i, j] := -1;
          G[i, j] := -1;
        end;
        '0', 'S', 'E':
        begin
          F[i, j] := 0;
          G[i, j] := 0;
        end;
      End;
    End;

  // F = G + H
  i := StartX;
  J := StartY;

  FoundWay := nil;
  New(FoundWay);
  New(FoundWay^.Step);
  FoundWay^.StepPrev := nil;
  FoundWay^.StepNext := nil;

  FoundWay.Step.Y := i;
  FoundWay.Step.X := j;

  H := Pifagor(i, j, EndX, EndY);
  G[i, j] := 1;
  F[i, j] := G[i, j] + H;
  FoundWay.Value := F[i, j];

  // Finding way to the end
  While H <> 0 do
  Begin
    // <-
    If (j > 0) and (F[i, j-1] = 0) then
    Begin
      H := Pifagor(i, j-1, EndX, EndY);
      F[i, j-1] := (G[i, j] + 1) + H;
    End;
    // ->
    If (j+1 < MapW) and (F[i, j+1] = 0) then
    Begin
      H := Pifagor(i, j+1, EndX, EndY);
      F[i, j+1] := (G[i, j] + 1) + H;
    End;
    // /\
    If (i > 0) and (F[i-1, j] = 0) then
    Begin
      H := Pifagor(i-1, j, EndX, EndY);
      F[i-1, j] := (G[i, j] + 1) + H;
    End;
    // \/
    If (i+1 < MapH) and (F[i+1, j] = 0) then
    Begin
      H := Pifagor(i+1, j, EndX, EndY);
      F[i+1, j] := (G[i, j] + 1) + H;
    End;

    // Finding the best value
    BestValue := CompareF(F, G, i, j, FoundWay, MapH, MapW,EndX, EndY);

    // Initialisation of the best value
    If (j > 0) and (F[i, j-1] = BestValue) then
    Begin
      If G[i, j-1] = 0 then
      Begin
        New(FoundWay^.StepNext);
        New(FoundWay^.StepNext^.Step);
        FoundWay^.StepNext^.StepNext := nil;
        FoundWay^.StepNext^.StepPrev := FoundWay;
        FoundWay := FoundWay^.StepNext;
        FoundWay.Step.Y := j;
        FoundWay.Step.X := i;
        G[i, j-1] := G[i, j] + 1;
        FoundWay.Value := G[i, j-1] + Pifagor(i, j-1, EndX, EndY);
      End
      Else
        F[i, j] := F[i, j-1] + 100;
      j := j - 1;
    End
    Else If (j+1 < MapW) and (F[i, j+1] = BestValue) then
    Begin
      If G[i, j+1] = 0 then
      Begin
        New(FoundWay^.StepNext);
        New(FoundWay^.StepNext^.Step);
        FoundWay^.StepNext^.StepNext := nil;
        FoundWay^.StepNext^.StepPrev := FoundWay;
        FoundWay := FoundWay^.StepNext;
        FoundWay.Step.Y := j;
        FoundWay.Step.X := i;
        G[i, j+1] := G[i, j] + 1;
        FoundWay.Value := G[i, j+1] + Pifagor(i, j+1, EndX, EndY);
      End
      Else
        F[i, j] := F[i, j+1] + 100;
      j := j + 1;
    End
    Else If (i > 0) and (F[i-1, j] = BestValue) then
    Begin
      If G[i-1, j] = 0 then
      Begin
        New(FoundWay^.StepNext);
        New(FoundWay^.StepNext^.Step);
        FoundWay^.StepNext^.StepNext := nil;
        FoundWay^.StepNext^.StepPrev := FoundWay;
        FoundWay := FoundWay^.StepNext;
        FoundWay.Step.Y := j;
        FoundWay.Step.X := i;
        G[i-1, j] := G[i, j] + 1;
        FoundWay.Value := G[i-1, j] + Pifagor(i-1, j, EndX, EndY);
      End
      Else
        F[i, j] := F[i-1, j] + 100;
      i := i - 1;
    End
    Else If (i+1 < MapH) and (F[i+1, j] = BestValue) then
    Begin
      If G[i+1, j] = 0 then
      Begin
        New(FoundWay^.StepNext);
        New(FoundWay^.StepNext^.Step);
        FoundWay^.StepNext^.StepNext := nil;
        FoundWay^.StepNext^.StepPrev := FoundWay;
        FoundWay := FoundWay^.StepNext;
        FoundWay.Step.Y := j;
        FoundWay.Step.X := i;
        G[i+1, j] := G[i, j] + 1;
        FoundWay.Value := G[i+1, j] + Pifagor(i+1, j, EndX, EndY);
      End
      Else
        F[i, j] := F[i+1, j] + 100;

      Inc(i);
    End;

    // Calculating the shortest way
    H := Pifagor(i, j, EndX, EndY);
  End;

  // Visualization
  BuildExit(G, StartX, StartY, EndX, EndY, -3, MapH, MapW);
End;

end.
