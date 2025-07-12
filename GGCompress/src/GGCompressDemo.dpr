program GGCompressDemo;

{$R *.dres}

uses
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,
  Vcl.Forms,
  DemoForm in 'DemoForm.pas' {Form1},
  gginitializer in 'gginitializer.pas',
  GnuGetText in 'GnuGetText.pas',
  GG.FileCompressor in 'GG.FileCompressor.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
