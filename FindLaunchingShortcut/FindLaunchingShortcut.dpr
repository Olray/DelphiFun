program FindLaunchingShortcut;

uses
  Vcl.Forms,
  App.MainForm in 'App.MainForm.pas' {MainForm},
  ShortcutFinder in 'ShortcutFinder.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
