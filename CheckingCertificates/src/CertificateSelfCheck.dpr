program CertificateSelfCheck;

uses
  Vcl.Forms,
  Main in 'Main.pas' {MainForm},
  SignInfo in 'SignInfo.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
