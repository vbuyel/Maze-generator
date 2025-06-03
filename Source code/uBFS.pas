{ Unit with BFS algoritm }
Unit uBFS;

Interface

// Unit and libraries
Uses
  uSharedData, StdCtrls, System.SysUtils;

Function BFSAlgorithm(var ThisMap: TMap; StartX, StartY, EndX, EndY: ShortInt; MapH, MapW: Integer): Boolean;

Implementation

// Used unit and library
Uses
  Dialogs, uMyProcedures;

// BFS
Function BFSAlgorithm(var ThisMap: TMap; StartX, StartY, EndX, EndY: ShortInt; MapH, MapW: Integer): Boolean;
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
  MapBFS: TAlgorArray;
  PointTemp: PPoint;
  i, j: integer;
{
 Queue - queue
 MapBFS - map with local initialisation
 PointTemp - time point
 i, j - index
}
Begin
  // Initialisation
  Result := True;
  SetLength(MapBFS, MapH, MapW);

  // Inicialization map for BFS
  For i := 0 to MapH-1 do
    For j := 0 to MapW-1 do
      Case ThisMap[i, j] of
        'x': MapBFS[i, j] := -1;
        '0', 'S', 'E': MapBFS[i, j] := 0;
      End;

  New(Queue);
  Queue^.Prev := nil;
  Queue^.Next := nil;
  New(PointTemp);
  Queue.X := StartX;
  Queue.Y := StartY;
  MapBFS[StartX, StartY] := 1;     // Start in '1'

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

    While (Queue <> nil) and (Queue^.Next <> nil) do
      Queue := Queue^.Next;

    // Check each direction
    // <-
    If (PointTemp.Y > 0) and (MapBFS[PointTemp.X, PointTemp.Y-1] = 0) then
    Begin
      MapBFS[PointTemp.X, PointTemp.Y-1] := MapBFS[PointTemp.X, PointTemp.Y] + 1;

      If Queue = nil then
      begin
        New(Queue);
        Queue^.Prev := nil;
        Queue^.Next := nil;
      end
      Else
      Begin
        New(Queue^.Next);
        Queue.Next^.Next := nil;
        Queue.Next^.Prev := Queue;
        Queue := Queue^.Next;
      End;

      Queue.X := PointTemp.X;
      Queue.Y := PointTemp.Y - 1;
    End;

    // ->
    If (PointTemp.Y+1 < MapW) and (MapBFS[PointTemp.X, PointTemp.Y+1] = 0) then
    Begin
      MapBFS[PointTemp.X, PointTemp.Y+1] := MapBFS[PointTemp.X, PointTemp.Y] + 1;

      If Queue = nil then
      begin
        New(Queue);
        Queue^.Prev := nil;
        Queue^.Next := nil;
      end
      Else
      Begin
        New(Queue^.Next);
        Queue.Next^.Next := nil;
        Queue.Next^.Prev := Queue;
        Queue := Queue^.Next;
      End;

      Queue.X := PointTemp.X;
      Queue.Y := PointTemp.Y + 1;
    End;

    // /\
    If (PointTemp.X > 0) and (MapBFS[PointTemp.X-1, PointTemp.Y] = 0) then
    Begin
      MapBFS[PointTemp.X-1, PointTemp.Y] := MapBFS[PointTemp.X, PointTemp.Y] + 1;

      If Queue = nil then
      begin
        New(Queue);
        Queue^.Prev := nil;
        Queue^.Next := nil;
      end
      Else
      Begin
        New(Queue^.Next);
        Queue.Next^.Next := nil;
        Queue.Next^.Prev := Queue;
        Queue := Queue^.Next;
      End;

      Queue.X := PointTemp.X - 1;
      Queue.Y := PointTemp.Y;
    End;

    // \/
    If (PointTemp.X+1 < MapH) and (MapBFS[PointTemp.X+1, PointTemp.Y] = 0) then
    Begin
      MapBFS[PointTemp.X+1, PointTemp.Y] := MapBFS[PointTemp.X, PointTemp.Y] + 1;

      If Queue = nil then
      begin
        New(Queue);
        Queue^.Prev := nil;
        Queue^.Next := nil;
      end
      Else
      Begin
        New(Queue^.Next);
        Queue.Next^.Next := nil;
        Queue.Next^.Prev := Queue;
        Queue := Queue^.Next;
      End;

      Queue.X := PointTemp.X + 1;
      Queue.Y := PointTemp.Y;
    End;

    While (Queue <> nil) and (Queue^.Prev <> nil) do
      Queue := Queue^.Prev;
  End;

  // Check on exit
  If MapBFS[EndX][EndY] = 0 then
  Begin
    Result := False;
    ShowMessage('Выхода нет');
  End
  // Build lines
  Else
    BuildExit(MapBFS, StartX, StartY, EndX, EndY, -2, MapH, MapW);
End;

End.
