{ Unit about the author }
Unit uProgramAuthor;

Interface

// Libraries
Uses
  Vcl.Forms, Vcl.StdCtrls, System.Classes, Vcl.Controls;

// Form's type
Type
  TFProgramAuthor = class(TForm)
    LTitle: TLabel;
    LInfo: TLabel;
    Procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

Var
  FProgramAuthor: TFProgramAuthor;

Implementation

{$R *.dfm}

// Used unit
Uses uMain;

// On close
Procedure TFProgramAuthor.FormClose(Sender: TObject; var Action: TCloseAction);
{
 Sender - activated object
 Action - choosed action
}
Begin
  Hide;
  FMain.Show;
End;

End.
