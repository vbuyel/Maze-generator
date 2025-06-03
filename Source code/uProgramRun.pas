{ Unit with settings }
Unit uProgramRun;

Interface

// Libraries
Uses
  System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.Actions, Vcl.ActnList,
  System.ImageList, Vcl.ImgList;

// Form's type
Type
  TFProgramRun = class(TForm)
    MSpeedTest: TMemo;
    LSpeedTest: TLabel;
    LWidth: TLabel;
    LSettings: TLabel;
    LHeight: TLabel;
    LStartFrom: TLabel;
    LBackgroundColor: TLabel;
    LWallColor: TLabel;
    LWayColor: TLabel;
    EMazeWidth: TEdit;
    EMazeHeight: TEdit;
    ODChooseMaze: TOpenDialog;
    CBBackgroundColor: TComboBox;
    CBWallsColor: TComboBox;
    CBStartFrom: TComboBox;
    CBEndIn: TComboBox;
    LEndIn: TLabel;
    ALSettings: TActionList;
    actFileOpen: TAction;
    ImageList1: TImageList;
    actGenerateMaze: TAction;
    BGenerate: TButton;
    BOpenFile: TButton;
    LBFS: TLabel;
    cbBFSColor: TComboBox;
    LAStar: TLabel;
    cbAStarColor: TComboBox;
    LDFS: TLabel;
    cbDFSColor: TComboBox;
    LWarning: TLabel;
    LWarningBC: TLabel;
    LWarningWC: TLabel;
    LWarningBFSColor: TLabel;
    LWarningAStarColor: TLabel;
    LWarningDFSColor: TLabel;
    Procedure BUploadMazeClick(Sender: TObject);
    Procedure BSolveMazeClick(Sender: TObject);
    Procedure EMazeWidthEnter(Sender: TObject);
    Procedure EMazeHeightEnter(Sender: TObject);
    Procedure EMazeWidthExit(Sender: TObject);
    Procedure EMazeHeightExit(Sender: TObject);
    Procedure EMazeParamChange(Sender: TObject);
    Procedure actFileOpenExecute(Sender: TObject);
    Procedure FormClose(Sender: TObject; var Action: TCloseAction);
    Procedure BGenMazeClick(Sender: TObject);
    Procedure CBColorChange(Sender: TObject);
    Procedure CanBeGenerated;
    Function CheckComBox: boolean;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

Var
  FProgramRun: TFProgramRun;

implementation

{$R *.dfm}

// Used units and libraries
Uses
  uMain, uShowMaze, ComObj, uMyProcedures, uSharedData, uPrim;

// Open file
Procedure TFProgramRun.actFileOpenExecute(Sender: TObject);
// Sender - activated object
Var
  i, j: byte;
  WithBorders, Errors: Boolean;
  MyExcel: Variant;
  SizeCoef: Integer;
  FileTXT: File of TSaveOpenArray;
  ImageTXT: TSaveOpenArray;
{
 i, j - index
 WithBorders - check
 Errors - found error
 MyExcel - excel's variable
 SizeCoef - coefficient
 FileTXT - typed file with data
 ImageTXT - this maze
}
begin
  // Initialization
  Errors := True;

  // Folder's direction
  ODChooseMaze.InitialDir := ExtractFileDir(Application.ExeName)+'\';
  ODChooseMaze.Execute;

  // If user wrote something
  If ODChooseMaze.FileName <> '' then
  Begin
    // Excel
    If (ODChooseMaze.FilterIndex = 2) and (FileExists(ODChooseMaze.FileName)) then
    Begin
      ODChooseMaze.DefaultExt := 'xlsx';
      MyExcel := CreateOleObject('Excel.Application');

      If FileExists(ODChooseMaze.FileName) then
      Begin
        MyExcel.Workbooks.Open(ODChooseMaze.FileName);
        Errors := LoadFromExcel(Map, Way, MyExcel, MapHeight, MapWidth);
      End
      Else
      Begin
        MyExcel := Unassigned;
        ShowMessage('Файл не найден');
        Errors := True;
      end;
    End
    // Txt
    Else
    Begin
      If FileExists(ODChooseMaze.FileName) then
      Begin
        AssignFile(FileTXT, ODChooseMaze.FileName);
        Reset(FileTXT);

        // Copy data into ImageTXT
        Read(FileTXT, ImageTXT);

        MapHeight := -1;
        MapWidth := -1;

        WithBorders := True;
        i := 0;

        // Is it with borders
        While WithBorders do
        Begin
          WithBorders := (LowerCase(ImageTXT[i, 0]) = 'x')
                        or (LowerCase(ImageTXT[i, 0]) = 's')
                        or (LowerCase(ImageTXT[i, 0]) = 'e');

          Inc(i);
          Inc(MapHeight);
        End;

        WithBorders := True;
        j := 0;

        // Is it with borders
        While WithBorders do
        Begin
          WithBorders := (LowerCase(ImageTXT[0, j]) = 'x')
                        or (LowerCase(ImageTXT[0, j]) = 's')
                        or (LowerCase(ImageTXT[0, j]) = 'e');

          Inc(j);
          Inc(MapWidth);
        End;

        Setlength(Map, MapHeight, MapWidth);

        // Map initialisation
        For i := 0 to MapHeight-1 do
          For j := 0 to MapWidth-1 do
            Map[i, j] := ImageTXT[i, j];

        CloseFile(FileTXT);

        Errors := False;
      End
      Else
      Begin
        ShowMessage('Файл не найден');
        Errors := True;
      End;
    End;
  End;

  // If no errors found
  If not Errors then
  Begin
    // Initialisation
    MazeStart.X := 0;
    MazeStart.Y := 0;
    MazeEnd.X := MapHeight-1;
    MazeEnd.Y := MapWidth-1;

    For i := 0 to MapHeight-1 do
      For j := 0 to MapWidth-1 do
        If LowerCase(Map[i][j]) = 's' then
        Begin
          MazeStart.X := i;
          MazeStart.Y := j;
        End
        Else
          If LowerCase(Map[i][j]) = 'e' then
          Begin
            MazeEnd.X := i;
            MazeEnd.Y := j;
          End;

    // Checking
    If (MazeStart.X = 0) and (MazeStart.Y = 0) then
      ShowMessage('Требуется символ "S" - start (начало) на карте');

    If (MazeEnd.X = MapHeight-1) and (MazeEnd.Y = MapWidth-1) then
      ShowMessage('Требуется символ "E" - end (конец) на карте');

    If (LowerCase(Map[MazeStart.X][MazeStart.Y]) = 'x')
      or (LowerCase(Map[MazeEnd.X][MazeEnd.Y]) = 'x') then
      ShowMessage('Убедитесь, что такой лабиринт можно решить');

    // Set form's size
    SizeCoef := (612*612) div (MapHeight*MapWidth);
    FShowMaze.ClientHeight := MapHeight * Trunc(Sqrt(SizeCoef));
    FShowMaze.ClientWidth := MapWidth * Trunc(Sqrt(SizeCoef));

    // Show result
    DrawGeneratedMaze(Map, Bitmap, MapHeight, MapWidth);
    FShowMaze.Show;
  End;
End;

// Check for showing button
Function TFProgramRun.CheckComBox: boolean;
begin
  Result := CBBackgroundColor.ItemIndex <> -1;
  Result := Result and (CBWallsColor.ItemIndex <> -1);
  Result := Result and (cbBFSColor.ItemIndex <> -1);
  Result := Result and (cbAStarColor.ItemIndex <> -1);
  Result := Result and (cbDFSColor.ItemIndex <> -1);
end;

// Is it can be generated
Procedure TFProgramRun.CanBeGenerated;
Var
  TempValue, Error, AllErrors: Integer;
  TempBool: Boolean;
{
 TempValue - time value
 Error, AllErrors - code error
 TempBool - time variable
}
Begin
  Val(EMazeWidth.Text, TempValue, Error);
  AllErrors := Error;
  Val(EMazeHeight.Text, TempValue, Error);
  AllErrors := AllErrors + Error;

  // Can user open the file
  TempBool := CheckComBox;

  ALSettings.Actions[0].Enabled := TempBool;
  BOpenFile.Enabled := TempBool;
  BOpenFile.ShowHint := not TempBool;

  // Check on errors
  If AllErrors > 0 then
    TempBool := False;

  // Can user generate the maze
  ALSettings.Actions[1].Enabled := TempBool;
  BGenerate.Enabled := TempBool;
End;

// Click on the generate maze button
Procedure TFProgramRun.BGenMazeClick(Sender: TObject);
// Sender - activated object
Begin
  // Procedure to generate the maze
  GenerateThisMaze(Map, Sender, MapHeight, MapWidth);
End;

// Click on the solve maze button
Procedure TFProgramRun.BSolveMazeClick(Sender: TObject);
Begin
  // Procedure to find the way
  FindWay(Map, FShowMaze.MWithMaze, MapHeight, MapWidth, MazeEnd.X, MazeEnd.Y);
End;

// Upload maze
Procedure TFProgramRun.BUploadMazeClick(Sender: TObject);
// Sender - activated object
Var
  i, j: Byte;
  CanBeShowed: Boolean;
{
 i, j - index
 CanBeShowed - check
}
Begin
  // Initialisation
  CanBeShowed := False;

  // Folder's direction
  ODChooseMaze.InitialDir := ExtractFileDir(Application.ExeName)+'\';
  ODChooseMaze.Execute;

  // If user wrote something
  If ODChooseMaze.FileName <> '' then
  Begin
    FShowMaze.MWithMaze.Lines.Clear;
    FShowMaze.MWithMaze.Lines.LoadFromFile(ODChooseMaze.FileName);

    // Checking
    CanBeShowed := LoadMap(Map, Way, MapHeight, MapWidth);
  End;

  // If it can be showed
  If CanBeShowed then
  Begin
    MazeStart.X := 0;
    MazeStart.Y := 0;
    MazeEnd.X := MapHeight-1;
    MazeEnd.Y := MapWidth-1;

    For i := 0 to MapHeight-1 do
      For j := 0 to MapWidth-1 do
        If LowerCase(Map[i][j]) = 's' then
        Begin
          MazeStart.X := i;
          MazeStart.Y := j;
        End
        Else
          If LowerCase(Map[i][j]) = 'e' then
          Begin
            MazeEnd.X := i;
            MazeEnd.Y := j;
          End;

    // Checking
    If (MazeStart.X = 0) and (MazeStart.Y = 0) then
      ShowMessage('Требуется символ "S" - start (начало) на карте');

    If (MazeEnd.X = MapHeight-1) and (MazeEnd.Y = MapWidth-1) then
      ShowMessage('Требуется символ "E" - end (конец) на карте');

    If (LowerCase(Map[MazeStart.X][MazeStart.Y]) = 'x')
      or (LowerCase(Map[MazeEnd.X][MazeEnd.Y]) = 'x') then
        ShowMessage('Убедитесь, что такой лабиринт можно решить');
  End;
End;

// Showing warnings
Procedure TFProgramRun.CBColorChange(Sender: TObject);
// Sender - activated object
Begin
  // For background color
  LWarningBC.Visible := (CBBackgroundColor.ItemIndex <> -1) and
                        ( (CBBackgroundColor.ItemIndex < 2)
                        or (CBBackgroundColor.ItemIndex = CBWallsColor.ItemIndex) );

  // For walls color
  LWarningWC.Visible := (CBWallsColor.ItemIndex <> -1) and
                        ( (CBWallsColor.ItemIndex < 2)
                        or (CBBackgroundColor.ItemIndex = CBWallsColor.ItemIndex) );

  // For BFS color
  LWarningBFSColor.Visible := (cbBFSColor.ItemIndex <> -1) and
                              ( (CBBackgroundColor.ItemIndex = cbBFSColor.ItemIndex)
                              or (cbAStarColor.ItemIndex = cbBFSColor.ItemIndex)
                              or (cbDFSColor.ItemIndex = cbBFSColor.ItemIndex) );

  // For A-Star color
  LWarningAStarColor.Visible := (cbAStarColor.ItemIndex <> -1) and
                              ( (CBBackgroundColor.ItemIndex = cbAStarColor.ItemIndex)
                              or (cbBFSColor.ItemIndex = cbAStarColor.ItemIndex)
                              or (cbDFSColor.ItemIndex = cbAStarColor.ItemIndex) );

  // For DFS color
  LWarningDFSColor.Visible := (cbDFSColor.ItemIndex <> -1) and
                              ( (CBBackgroundColor.ItemIndex = cbDFSColor.ItemIndex)
                              or (cbBFSColor.ItemIndex = cbDFSColor.ItemIndex)
                              or (cbAStarColor.ItemIndex = cbDFSColor.ItemIndex) );

  // Checking
  CanBeGenerated;
end;

// Hide maze size parameter (height)
procedure TFProgramRun.EMazeHeightEnter(Sender: TObject);
// Sender - activated object
begin
  ENameEnter(EMazeHeight, 'от 3 до 100');
end;

// Show maze size parameter (height)
Procedure TFProgramRun.EMazeHeightExit(Sender: TObject);
// Sender - activated object
Begin
  ENameExit(EMazeHeight, 'от 3 до 100');
End;

// On change maze size
Procedure TFProgramRun.EMazeParamChange(Sender: TObject);
// Sender - activated object
Var
  ParamW, ParamH: Integer;
  ErrorW, ErrorH: Integer;
{
 ParamW, ParamH - maze size
 ErrorW, ErrorH - code error
}
Begin
  // Initialisation
  EMazeWidth.Font.Color := clBlack;
  EMazeHeight.Font.Color := clBlack;

  // Checking
  Val(EMazeWidth.Text, ParamW, ErrorW);
  Val(EMazeHeight.Text, ParamH, ErrorH);
  LWarning.Visible := (ErrorW = 0) and (ErrorH = 0)
    and ((ParamW - ParamH > 57) or (ParamW - ParamH < -4));

  If ErrorW > 0 then
    EMazeWidth.Font.Color := clRed;

  If ErrorH > 0 then
    EMazeHeight.Font.Color := clRed;

  // If it can be generated
  CanBeGenerated;
End;

// Hide maze size parameter (width)
Procedure TFProgramRun.EMazeWidthEnter(Sender: TObject);
// Sender - activated object
Begin
  ENameEnter(EMazeWidth, 'от 3 до 100');
End;

// Show maze size parameter (width)
Procedure TFProgramRun.EMazeWidthExit(Sender: TObject);
// Sender - activated object
Begin
  ENameExit(EMazeWidth, 'от 3 до 100');
End;

// On close
Procedure TFProgramRun.FormClose(Sender: TObject; var Action: TCloseAction);
{
 Sender - activated object
 Action - action choosed
}
begin
  Hide;
  FMain.Show;
end;

end.
