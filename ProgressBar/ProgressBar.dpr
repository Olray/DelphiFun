program ProgressBar;

uses
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,
  Vcl.Forms,
  DemoForm in 'DemoForm.pas' {Form1},
  ProgressBarFrame in 'ProgressBarFrame.pas' {ProgressFrame: TFrame},
  ProgressBarDlg in 'ProgressBarDlg.pas' {ProgressForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
