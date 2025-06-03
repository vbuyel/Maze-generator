{ Unit with DFS algoritm }
Unit uDFS;

Interface

// Libraries and unit
Uses
  uSharedData, StdCtrls, System.SysUtils;

Procedure DFSAlgorithm(var ThisMap: TMap; StartX, StartY, EndX, EndY: ShortInt; MapH, MapW: Integer);

Implementation

// Used unit
Uses
  uMyProcedures;

// DFS
Procedure DFSAlgorithm(var ThisMap: TMap; StartX, StartY, EndX, EndY: ShortInt; MapH, MapW: Integer);
{
 ThisMap - current map
 StartX - start positon 'X'
 StartY - start position 'Y'
 EndX - end position 'X'
 EndY - end position 'Y'
 MapH, MapW - map size
}
Var
  Queue: PQueue;
  MapDFS: TAlgorArray;
  PointTemp: PPoint;
  i, j: integer;
{
 Queue - queue
 MapDFS - map with local initialisation
 PointTemp - time point
 i, j - index
}
Begin
  // Initialisation
  SetLength(MapDFS, MapH, MapW);

  // Inicialization map for BFS
  For i := 0 to MapH-1 do
    For j := 0 to MapW-1 do
      Case ThisMap[i, j] of
        'x': MapDFS[i, j] := -1;
        '0', 'S', 'E': MapDFS[i, j] := 0;
      End;

  New(Queue);
  Queue^.Prev := nil;
  Queue^.Next := nil;
  New(PointTemp);
  Queue.X := StartX;
  Queue.Y := StartY;
  MapDFS[StartX, StartY] := 1;     // Start in '1'

  // Finding the end
  While (Queue <> nil) and ((Queue.X <> EndX) or (Queue.Y <> EndY)) do
  Begin
    // Get one point
    PointTemp.X := Queue.X;
    PointTemp.Y := Queue.Y;

    if Queue <> nil then
      Queue := Queue^.Next;

    if Queue <> nil then
    begin
      Dispose(Queue^.Prev);
      Queue^.Prev := nil;
    end;

    // Check each direction
    // <-
    If (PointTemp.Y > 0) and (MapDFS[PointTemp.X, PointTemp.Y-1] = 0) then
    Begin
      MapDFS[PointTemp.X, PointTemp.Y-1] := MapDFS[PointTemp.X, PointTemp.Y] + 1;

      If Queue = nil then
      begin
        New(Queue);
        Queue^.Prev := nil;
        Queue^.Next := nil;
      end
      Else
      Begin
        New(Queue^.Prev);
        Queue.Prev^.Next := Queue;
        Queue.Prev^.Prev := nil;
        Queue := Queue^.Prev;
      End;

      Queue.X := PointTemp.X;
      Queue.Y := PointTemp.Y - 1;
    End;

    // ->
    If (PointTemp.Y+1 < MapW) and (MapDFS[PointTemp.X, PointTemp.Y+1] = 0) then
    Begin
      MapDFS[PointTemp.X, PointTemp.Y+1] := MapDFS[PointTemp.X, PointTemp.Y] + 1;

      If Queue = nil then
      begin
        New(Queue);
        Queue^.Prev := nil;
        Queue^.Next := nil;
      end
      Else
      Begin
        New(Queue^.Prev);
        Queue.Prev^.Next := Queue;
        Queue.Prev^.Prev := nil;
        Queue := Queue^.Prev;
      End;

      Queue.X := PointTemp.X;
      Queue.Y := PointTemp.Y + 1;
    End;

    // /\
    If (PointTemp.X > 0) and (MapDFS[PointTemp.X-1, PointTemp.Y] = 0) then
    Begin
      MapDFS[PointTemp.X-1, PointTemp.Y] := MapDFS[PointTemp.X, PointTemp.Y] + 1;

      If Queue = nil then
      begin
        New(Queue);
        Queue^.Prev := nil;
        Queue^.Next := nil;
      end
      Else
      Begin
        New(Queue^.Prev);
        Queue.Prev^.Next := Queue;
        Queue.Prev^.Prev := nil;
        Queue := Queue^.Prev;
      End;

      Queue.X := PointTemp.X - 1;
      Queue.Y := PointTemp.Y;
    End;

    // \/
    If (PointTemp.X+1 < MapH) and (MapDFS[PointTemp.X+1, PointTemp.Y] = 0) then
    Begin
      MapDFS[PointTemp.X+1, PointTemp.Y] := MapDFS[PointTemp.X, PointTemp.Y] + 1;

      If Queue = nil then
      begin
        New(Queue);
        Queue^.Prev := nil;
        Queue^.Next := nil;
      end
      Else
      Begin
        New(Queue^.Prev);
        Queue.Prev^.Next := Queue;
        Queue.Prev^.Prev := nil;
        Queue := Queue^.Prev;
      End;

      Queue.X := PointTemp.X + 1;
      Queue.Y := PointTemp.Y;
    End;
  End;

  // Build lines
  BuildExit(MapDFS, StartX, StartY, EndX, EndY, -4, MapH, MapW);
End;

End.
