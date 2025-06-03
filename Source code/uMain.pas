{ Main unit }
Unit uMain;

Interface

// Libraries
Uses
  Vcl.Forms, Vcl.StdCtrls, Vcl.Controls, System.Classes;

// form's type
Type
  TFMain = class(TForm)
    LMenu: TLabel;
    BProgramStart: TButton;
    BProgramAbout: TButton;
    BAuthor: TButton;
    procedure BProgramExitClick(Sender: TObject);
    procedure BProgramAboutClick(Sender: TObject);
    procedure BProgramStartClick(Sender: TObject);
    procedure BProgramAuthorClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

// Form
Var
  FMain: TFMain;

Implementation

{$R *.dfm}

// Created units
Uses
  ProgramAbout, ProgramRun, uProgramAuthor, SharedData, MyProcedures;

// Open form about the program
Procedure TFMain.BProgramAboutClick(Sender: TObject);
Begin
  If not Assigned(FProgramAbout) then
    FProgramAbout := TFProgramAbout.Create(Application);
  FProgramAbout.Show;
End;

// Open form about the author
Procedure TFMain.BProgramAuthorClick(Sender: TObject);
Begin
  If not Assigned(FProgramAuthor) then
    FProgramAuthor := TFProgramAuthor.Create(Application);
  FProgramAuthor.Show;
End;

// Terminate the program
Procedure TFMain.BProgramExitClick(Sender: TObject);
Begin
  Application.Terminate;
End;

// Open settings
Procedure TFMain.BProgramStartClick(Sender: TObject);
Begin
  If not Assigned(FProgramRun) then
    FProgramRun := TFProgramRun.Create(Application);

  FProgramRun.Show;
  Hide;
End;

end.
