{ Unit of shared data between other units }
Unit uSharedData;

Interface

// Library
Uses
  Graphics;

// Form's type
Type
  TSaveOpenArray = Array[0..99] of Array[0..99] of Char;
  TAlgorArray = Array of Array of Integer;
  TMap = Array of Array of Char;
  PPoint = ^TPoint;
  PWay = ^TWay;
  PQueue = ^TQueue;
  PCheck = ^TCheck;

  TCheck = record
    X: Integer;
    Y: Integer;
    Value: Integer;
  end;

  TQueue = record
    Prev: PQueue;
    X: LongInt;
    Y: LongInt;
    Next: PQueue;
  end;

  TPoint = packed record
    X: LongInt;
    Y: LongInt;
  end;

  TWay = packed record
    StepPrev: PWay;
    Step: PPoint;
    Value: Integer;
    StepNext: PWay;
  end;

// Constant value
Const
  ArrColor: Array[0..7] of Integer = ($0000FF, $FF0000, $008000, $000000, $00FFFF, $00A5FF, $800080, $FFFFFF);
  {
   Red
   Blue
   Green
   Black
   Yellow
   Orange
   Purple
   White
  }

Var
  Map: TMap;
  Bitmap: TBitmap;
  Way: TAlgorArray;
  MapWidth, MapHeight: Integer;
  MazeStart, MazeEnd: TPoint;
 {
  Map - current map
  Bitmap - bitmap
  Way - the way to the end
  MapWidth, MapHeight - map size
  MazeStart, MazeEnd - map start/end points
 }

Implementation

End.
