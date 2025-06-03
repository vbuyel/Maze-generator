{ Unit to show the maze }
Unit uShowMaze;

Interface

// Units and libraries
Uses
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Menus, System.Actions,
  Vcl.ActnList, System.ImageList, Vcl.ImgList, Vcl.StdCtrls,
  {Added ->} uSharedData;

// Form's type
Type
  TFShowMaze = class(TForm)
    PBMaze: TPaintBox;
    ILMaze: TImageList;
    ALMaze: TActionList;
    actFileNew: TAction;
    actSolveMaze: TAction;
    actGenerateMaze: TAction;
    MWithMaze: TMemo;
    MMMaze: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    actDeleteLine: TAction;
    N4: TMenuItem;
    SDImage: TSaveDialog;
    Procedure SolveMaze(Sender: TObject);
    Procedure GenerateMaze(Sender: TObject);
    Procedure PBMazePaint(Sender: TObject);
    Procedure FormClose(Sender: TObject; var Action: TCloseAction);
    Procedure actDeleteLineExecute(Sender: TObject);
    Procedure actFileNewExecute(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

Procedure WriteLine(var ThisArray: TAlgorArray; Value: ShortInt; StartX, StartY, EndX, EndY, MapH, MapW: Integer);
Procedure DrawGeneratedMaze(var ThisMap: TMap; var ThisBitmap: TBitmap; MapH, MapW: Integer);

Var
  FShowMaze: TFShowMaze;

implementation

{$R *.dfm}

// Used units and libraries
Uses
  uProgramRun, uMyProcedures, uPrim, PngImage, Jpeg, ComObj;

// Show way
Procedure WriteLine(var ThisArray: TAlgorArray; Value: ShortInt; StartX, StartY, EndX, EndY, MapH, MapW: Integer);
{
 ThisArray - array of current way
 Value - depend on each algorithm
 StartX - start position 'X'
 StartY - start position 'Y'
 EndX - end position 'X'
 EndY - end position 'Y'
 MapH, MapW - map size
}
Var
  RectH, RectW: Integer;
  LineH, LineW: Integer;
  i, j: Byte;
  Counter: Integer;
  LastCycle, IsFinish: Boolean;
{
 RectW, RectH - rectangle size
 LineH, LineW - line size
 i, j - index
 Counter - counter
 LastCycle - check on the last cycle
 IsFinish - end of the cycles
}
Begin
  // Rectangle size
  RectH := FShowMaze.PBMaze.Height div MapH;
  RectW := FShowMaze.PBMaze.Width div MapW;

  // Line size
  If RectW > RectH then
  Begin
    LineH := Round(RectH*0.2);
    LineW := Round((RectW+LineH) / 2);
  End
  Else
  Begin
    LineH := Round(RectW*0.2);
    LineW := Round((RectH+LineH) / 2);
  End;

  Case Value of
    -2: Bitmap.Canvas.Brush.Color := ArrColor[FProgramRun.cbBFSColor.ItemIndex];
    -3: Bitmap.Canvas.Brush.Color := ArrColor[FProgramRun.cbAStarColor.ItemIndex];
    -4: Bitmap.Canvas.Brush.Color := ArrColor[FProgramRun.cbDFSColor.ItemIndex];
  End;

  // Initialisation
  i := StartX;
  j := StartY;
  Counter := 1;
  LastCycle := False;
  IsFinish := False;

  // From start to the end
  While not IsFinish do
    If ThisArray[i][j] = Value then
    Begin
      ThisArray[i][j] := Counter;

      // Line (start direction)
      If (i > 0) and (ThisArray[i-1][j] = Counter-1) and (ThisArray[i-1][j] > 0) then          // |
        Bitmap.Canvas.FillRect(Rect(j*RectW + ((RectW-LineH) div 2), i*RectH,
                                    j*RectW + ((RectW-LineH) div 2) + LineH, i*RectH + LineW))
      Else
        If (j > 0) and (ThisArray[i][j-1] = Counter-1) and (ThisArray[i][j-1] > 0) then          // -
          Bitmap.Canvas.FillRect(Rect(j*RectW, i*RectH + ((RectH-LineH) div 2),
                                      j*RectW + LineW, i*RectH + ((RectH-LineH) div 2) + LineH))
        Else
          If (j < MapW-1) and (ThisArray[i][j+1] = Counter-1) and (ThisArray[i][j+1] > 0) then // -
            Bitmap.Canvas.FillRect(Rect((j+1)*RectW, i*RectH + ((RectH-LineH) div 2),
                                        (j+1)*RectW - LineW, i*RectH + ((RectH-LineH) div 2) + LineH))
          Else
            If (i < MapH-1) and (ThisArray[i+1][j] = Counter-1) and (ThisArray[i+1][j] > 0) then          // |
              Bitmap.Canvas.FillRect(Rect(j*RectW + ((RectW-LineH) div 2), (i+1)*RectH,
                                          j*RectW + ((RectW-LineH) div 2) + LineH, (i+1)*RectH - LineW));

      // Line (end direction)
      If (i > 0) and (ThisArray[i-1][j] = Value) then          // |
      Begin
        Bitmap.Canvas.FillRect(Rect(j*RectW + ((RectW-LineH) div 2), i*RectH,
                                    j*RectW + ((RectW-LineH) div 2) + LineH, i*RectH + LineW));
        Dec(i);
      End
      Else
        If (j > 0) and (ThisArray[i][j-1] = Value) then          // -
        Begin
          Bitmap.Canvas.FillRect(Rect(j*RectW, i*RectH + ((RectH-LineH) div 2),
                                      j*RectW + LineW, i*RectH + ((RectH-LineH) div 2) + LineH));
          Dec(j);
        End
        Else
          If (j < MapW-1) and (ThisArray[i][j+1] = Value) then // -
          Begin
            Bitmap.Canvas.FillRect(Rect((j+1)*RectW, i*RectH + ((RectH-LineH) div 2),
                                        (j+1)*RectW - LineW, i*RectH + ((RectH-LineH) div 2) + LineH));
            Inc(j);
          End
          Else
            If (i < MapH-1) and (ThisArray[i+1][j] = Value) then          // |
            Begin
              Bitmap.Canvas.FillRect(Rect(j*RectW + ((RectW-LineH) div 2), (i+1)*RectH,
                                          j*RectW + ((RectW-LineH) div 2) + LineH, (i+1)*RectH - LineW));
              Inc(i);
            End;

      Inc(Counter);

      If LastCycle then
        IsFinish := True;

      If (i = EndX) and (j = EndY) then
        LastCycle := True;
    End;

  // Draw this maze
  FShowMaze.PBMaze.Canvas.Draw(0, 0, Bitmap);
End;

// Draw maze (generated)
Procedure DrawGeneratedMaze(var ThisMap: TMap; var ThisBitmap: TBitmap; MapH, MapW: Integer);
{
 ThisMap - current map
 ThisBitmap - current bitmap
 MapH, MapW - map size
}
Var
  x, y: Byte;
  RectWidth, RectHeight: Word;
{
 x, y - index
 RectWidth, RectHeight - rectangle size
}
Begin
  If Assigned(ThisBitmap) then
  Begin
    ThisBitmap.Free;
    ThisBitmap := nil;
  End;

  // Initialisation
  RectWidth := FShowMaze.PBMaze.Width div MapW;
  RectHeight := FShowMaze.PBMaze.Height div MapH;

  // Create bitmap
  ThisBitmap := TBitmap.Create;
  ThisBitmap.SetSize(FShowMaze.PBMaze.Width, FShowMaze.PBMaze.Height);
  ThisBitmap.Canvas.Brush.Color := clWhite;
  ThisBitmap.Canvas.FillRect(Rect(0, 0, FShowMaze.PBMaze.Width, FShowMaze.PBMaze.Height));

  // Color the maze
  For x := 0 to MapH-1 do
    For y := 0 to MapW-1 do
    Begin
      Case ThisMap[x][y] of
        'X', 'x': ThisBitmap.Canvas.Brush.Color := ArrColor[FProgramRun.CBWallsColor.ItemIndex];
        'S', 's': ThisBitmap.Canvas.Brush.Color := ArrColor[0];
        'E', 'e': ThisBitmap.Canvas.Brush.Color := ArrColor[1];
        Else
          ThisBitmap.Canvas.Brush.Color := ArrColor[FProgramRun.CBBackgroundColor.ItemIndex];
      End;

      ThisBitmap.Canvas.FillRect(Rect(y*RectWidth, x*RectHeight, (y+1)*RectWidth, (x+1)*RectHeight));
    End;

  FShowMaze.ALMaze.Actions[3].Enabled := False;
  FShowMaze.MMMaze.Items[1].Enabled := False;
End;

// Paint this maze
Procedure TFShowMaze.PBMazePaint(Sender: TObject);
// Sender - activated object
Begin
  // Draw maze in bitmap
  DrawGeneratedMaze(Map, Bitmap, MapHeight, MapWidth);

  // Show this maze
  FShowMaze.PBMaze.Canvas.Draw(0, 0, Bitmap);
End;

// Delete line
Procedure TFShowMaze.actDeleteLineExecute(Sender: TObject);
// Sender - activated object
Begin
  FShowMaze.PBMaze.Invalidate;
  ALMaze.Actions[3].Enabled := False;
  MMMaze.Items[1].Enabled := False;
End;

// Save to the excel file
Procedure SaveToExcel(var ThisMap: TMap; MapH, MapW: Integer);
{
 ThisMap - current map
 MapH, MapW - map siize
}
Var
  i, j: integer;
  MyExcel: Variant;
{
 i, j - index
 MyExcel - excel variable
}
Begin
  // Initialisation
  Try
    MyExcel := CreateOleObject('Excel.Application');
  Except
    ShowMessage('Необходимо установить Excel');
  End;
  MyExcel.Workbooks.Add;

  // Filling
  For i := 0 to MapH-1 do
    For j := 0 to MapW-1 do
    Begin
      MyExcel.Cells[i+1, j+1].ColumnWidth := 2;
      MyExcel.Cells[i+1, j+1].Value := ThisMap[i, j];

      Case ThisMap[i, j] of
        'X', 'x':
          MyExcel.Cells[i+1, j+1].Font.Color := ArrColor[FProgramRun.CBWallsColor.ItemIndex];
        '0':
          MyExcel.Cells[i+1, j+1].Font.Color := ArrColor[FProgramRun.CBBackgroundColor.ItemIndex];
        'S', 's':
          MyExcel.Cells[i+1, j+1].Font.Color := clRed;
        'E', 'e':
          MyExcel.Cells[i+1, j+1].Font.Color := clBlue;
      End;
    End;

  // Exit
  MyExcel.ActiveWorkbook.SaveAs(FShowMaze.SDImage.FileName);
  MyExcel.ActiveWorkbook.Close;
  MyExcel.Quit;
End;

// Save to the txt file
Procedure SaveToTxt(var ThisMap: TMap; MapH, MapW: Integer);
{
 ThisMap - current map
 MapH, MapW - map size
}
Var
  i, j: integer;
  FileTXT: File of TSaveOpenArray;
  ArrSave: TSaveOpenArray;
{
 i, j - index
 FileTXT - typed file ti save data
 ArrSave - time data
}
Begin
  // Prepare
  For i := 0 to MapH-1 do
    For j := 0 to MapW-1 do
      ArrSave[i, j] := '-';

  // Initialisation
  For i := 0 to MapH-1 do
    For j := 0 to MapW-1 do
      ArrSave[i, j] := ThisMap[i, j];

  AssignFile(FileTXT, FShowMaze.SDImage.FileName);
  Rewrite(FileTXT);

  // Copy to the txt file
  Write(FileTXT, ArrSave);

  Close(FileTXT);
End;

// Save in the file
Procedure TFShowMaze.actFileNewExecute(Sender: TObject);
// Sender - activated object
Var
  Bitmap: TBitmap;
  PNG: TPNGImage;
  JPEG: TJPEGImage;
{
 Bitmap - bitmap
 PNG - save format
 JPEG - save format
}
Begin
  If SDImage.Execute then
  Begin
    Bitmap := TBitmap.Create;
    Bitmap.SetSize(FShowmaze.ClientWidth, FShowmaze.ClientHeight);
    Bitmap.Canvas.CopyRect(PBMaze.ClientRect, PBMaze.Canvas, PBMaze.ClientRect);

    // Save to the BMP file
    If SDImage.FilterIndex = 1 then
    Begin
      SDImage.DefaultExt := 'bmp';
      Bitmap.SaveToFile(SDImage.FileName);
    End;

    // Save to the PNG file
    If SDImage.FilterIndex = 2 then
    Begin
      SDImage.DefaultExt := 'png';
      PNG := TPNGImage.Create;
      PNG.Assign(Bitmap);
      PNG.SaveToFile(SDImage.FileName);
      PNG.Free;
    End;

    // Save to the JPEG file
    If SDImage.FilterIndex = 3 then
    Begin
      SDImage.DefaultExt := 'jpeg';
      JPEG := TJPEGImage.Create;
      JPEG.Assign(Bitmap);
      JPEG.SaveToFile(SDImage.FileName);
      JPEG.Free;
    End;

    Bitmap.Free;

    // Save to the XLSX file
    If SDImage.FilterIndex = 4 then
    Begin
      SDImage.DefaultExt := 'xlsx';
      SaveToExcel(Map, MapHeight, MapWidth);
    End;

    // Save data to the TXT file
    If SDImage.FilterIndex = 5 then
    Begin
      SDImage.DefaultExt := 'txt';
      SaveToTxt(Map, MapHeight, MapWidth);
    End;
  End;
End;

// On close
Procedure TFShowMaze.FormClose(Sender: TObject; var Action: TCloseAction);
{
 Sender - activated object
 Action - choosed action
}
Begin
  Hide;
  FProgramRun.BGenerate.Enabled := True;
  FProgramRun.CanBeGenerated;
End;

// Click on generate the maze
Procedure TFShowMaze.GenerateMaze(Sender: TObject);
Begin
  // Generate
  GenerateThisMaze(Map, Sender, MapHeight, MapWidth);
End;

// Click to solve the maze
Procedure TFShowMaze.SolveMaze(Sender: TObject);
Begin
  // Finding the way
  FindWay(Map, FShowMaze.MWithMaze, MapHeight, MapWidth, MazeEnd.X, MazeEnd.Y);

  ALMaze.Actions[3].Enabled := True;
  MMMaze.Items[1].Enabled := True;
End;

end.
