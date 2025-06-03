{ Unit with Prim algorithm }
Unit uPrim;

Interface

// Libraries
Uses
  uSharedData, StdCtrls;

Procedure PrimAlgorithm(var ThisMap: TMap; var ThisWay: TAlgorArray; MapH, MapW: Integer);

Implementation

// 0 - a way
// x - not a way

// Remove the pint
Procedure RemovePoint(var ThisArray: Array of PPoint; Ind: Integer);
{
 ThisArray - current array of points
 Ind - index
}
Begin
  while (length(ThisArray) > 1) and (Ind < length(ThisArray)-1) do
  begin
    ThisArray[Ind] := ThisArray[Ind+1];
    inc(Ind);
  end;
End;

// Finding point
Procedure FindAndRemovePoint(var ThisArray: Array of PPoint; x, y: LongInt);
{
 ThisArray - current array of points
 x, y - index
}
Var
  i: Integer;
// i - index
Begin
  i := 0;
  While (ThisArray[i].X <> x) or (ThisArray[i].Y <> y) do
    Inc(i);

  RemovePoint(ThisArray, i);
End;

// Main Prim algorithm
Procedure PrimAlgorithm(var ThisMap: TMap; var ThisWay: TAlgorArray; MapH, MapW: Integer);
{
 ThisMap - current map
 ThisWay - current way to the end
 MapH, MapW - map size
}
Var
  PointTemp: TPoint;
  PointsArray: Array of PPoint;
  MapPrim: Array of Array of Byte;
  IsVisited: Array of Array of Boolean;
  i, j: integer;
  TempWay: Integer;
{
 PointTemp - time point
 PointsArray - array of points
 MapPrim - local array of initialisation
 IsVisited - loacal array of visited points
 i, j - index
 TempWay - the way to the end
}
Begin
  // Initialisation
  Setlength(MapPrim, MapH + 2, MapW + 2);
  Setlength(ThisMap, MapH + 2, MapW + 2);
  Setlength(ThisWay, MapH + 2, MapW + 2);

  For i := 0 to MapH+1 do
    For j := 0 to MapW+1 do
    Begin
      ThisMap[i, j] := 'x';
      MapPrim[i, j] := 0;
    End;

  // Using random
  Randomize();

  Setlength(PointsArray, 1);
  New(PointsArray[0]);
  PointsArray[0].X := Random(MapH-1 - 1) + 1;    // Start X >= 1
  PointsArray[0].Y := Random(MapW-1 - 1) + 1;    // Start Y >= 1

  // while can add neighbour cell
  While length(PointsArray) > 0 do
  Begin
    // Choosed randomly
    TempWay := Random(length(PointsArray));

    PointTemp.X := PointsArray[TempWay].X;
    PointTemp.Y := PointsArray[TempWay].Y;
    Dispose(PointsArray[TempWay]);
    PointsArray[TempWay] := nil;

    // Remove this point
    RemovePoint(PointsArray, TempWay);
    Setlength(PointsArray, length(PointsArray)-1);

    // If it has only one neighbour
    If MapPrim[PointTemp.X, PointTemp.Y] <= 1 then
    Begin
      ThisMap[PointTemp.X, PointTemp.Y] := '0';
      MapPrim[PointTemp.X, PointTemp.Y] := 3;

      // Check each direction
      // <-
      If (PointTemp.Y > 1) and (MapPrim[PointTemp.X, PointTemp.Y-1] = 0) then
      Begin

        Inc(MapPrim[PointTemp.X, PointTemp.Y-1]);

        Setlength(PointsArray, length(PointsArray) + 1);
        New(PointsArray[length(PointsArray)-1]);
        PointsArray[length(PointsArray)-1].X := PointTemp.X;
        PointsArray[length(PointsArray)-1].Y := PointTemp.Y - 1;

      End
      Else
        If (PointTemp.Y > 1) and (MapPrim[PointTemp.X, PointTemp.Y-1] = 1) then
        Begin
          FindAndRemovePoint(PointsArray, PointTemp.X, PointTemp.Y-1);
          Setlength(PointsArray, length(PointsArray)-1);
          Inc(MapPrim[PointTemp.X, PointTemp.Y-1]);
        End;

      // ->
      If (PointTemp.Y+1 < MapW+1) and (MapPrim[PointTemp.X, PointTemp.Y+1] = 0) then
      Begin

        Inc(MapPrim[PointTemp.X, PointTemp.Y+1]);

        Setlength(PointsArray, length(PointsArray) + 1);
        New(PointsArray[length(PointsArray)-1]);
        PointsArray[length(PointsArray)-1].X := PointTemp.X;
        PointsArray[length(PointsArray)-1].Y := PointTemp.Y + 1;

      End
      Else
        If (PointTemp.Y+1 < MapW+1) and (MapPrim[PointTemp.X, PointTemp.Y+1] = 1) then
        Begin
          FindAndRemovePoint(PointsArray, PointTemp.X, PointTemp.Y+1);
          Setlength(PointsArray, length(PointsArray)-1);
          Inc(MapPrim[PointTemp.X, PointTemp.Y+1]);
        End;

      // /\
      If (PointTemp.X > 1) and (MapPrim[PointTemp.X-1, PointTemp.Y] = 0) then
      Begin

        Inc(MapPrim[PointTemp.X-1, PointTemp.Y]);

        Setlength(PointsArray, length(PointsArray) + 1);
        New(PointsArray[length(PointsArray)-1]);
        PointsArray[length(PointsArray)-1].X := PointTemp.X - 1;
        PointsArray[length(PointsArray)-1].Y := PointTemp.Y;

      End
      Else
        If (PointTemp.X > 1) and (MapPrim[PointTemp.X-1, PointTemp.Y] = 1) then
        Begin
          FindAndRemovePoint(PointsArray, PointTemp.X-1, PointTemp.Y);
          Setlength(PointsArray, length(PointsArray)-1);
          Inc(MapPrim[PointTemp.X-1, PointTemp.Y]);
        End;

      // \/
      If (PointTemp.X+1 < MapH+1) and ((MapPrim[PointTemp.X+1, PointTemp.Y] = 0)) then
      Begin

        Inc(MapPrim[PointTemp.X+1, PointTemp.Y]);

        Setlength(PointsArray, length(PointsArray) + 1);
        New(PointsArray[length(PointsArray)-1]);
        PointsArray[length(PointsArray)-1].X := PointTemp.X + 1;
        PointsArray[length(PointsArray)-1].Y := PointTemp.Y;

      End
      Else
        If (PointTemp.X+1 < MapH+1) and (MapPrim[PointTemp.X+1, PointTemp.Y] = 1) then
        Begin
          FindAndRemovePoint(PointsArray, PointTemp.X+1, PointTemp.Y);
          Setlength(PointsArray, length(PointsArray)-1);
          Inc(MapPrim[PointTemp.X+1, PointTemp.Y]);
        End;
    End;
  End;
End;

End.
