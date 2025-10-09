program Demo;

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {Form1},
  ErrorDialog.Core in 'ErrorDialog.Core.pas',
  ErrorDialog.Builder in 'ErrorDialog.Builder.pas',
  ErrorDialog.Form in 'ErrorDialog.Form.pas' {ErrorDialogForm},
  ErrorDialog.InfoProviders in 'ErrorDialog.InfoProviders.pas',
  ErrorDialog.Types in 'ErrorDialog.Types.pas',
  ErrorDialog.Utils in 'ErrorDialog.Utils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
