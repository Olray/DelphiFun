unit ProgressBarDlg;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ProgressBarFrame;

type
  TProgressForm = class(TForm)
    ProgressFrame: TProgressFrame;
  private
    { Private-Deklarationen }
  public
    function GetProgressInterface: IProgress;
  end;

implementation

{$R *.dfm}

{ TProgressForm }

function TProgressForm.GetProgressInterface: IProgress;
begin
  Result := ProgressFrame;
end;

end.
