{ Unit about the program }
Unit uProgramAbout;

Interface

// Libraries
Uses
  Vcl.Forms, Vcl.StdCtrls, System.Classes, Vcl.Controls;

// Form's type
Type
  TFProgramAbout = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

Var
  FProgramAbout: TFProgramAbout;

Implementation

{$R *.dfm}

// Used unit
Uses
  Main;

// On close
Procedure TFProgramAbout.FormClose(Sender: TObject; var Action: TCloseAction);
{
 Sender - activated object
 Action - choosed action
}
Begin
  Hide;
  FMain.Show;
End;

End.
