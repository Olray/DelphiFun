unit App.MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TMainForm = class(TForm)
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  MainForm: TMainForm;

implementation
uses
  ShortcutFinder;

{$R *.dfm}

procedure TMainForm.FormCreate(Sender: TObject);
var
  ShortcutFinder: IOriginatingShortcutFinder;
begin
  ShortcutFinder := TOriginatingShortcutFinder.Create;
  if ShortcutFinder.IsRunByShortcut then
  begin
    Memo1.Lines.Add('App was run by clicking a shortcut');
    Memo1.Lines.Add(Format('The shortcut is "%s"', [ShortcutFinder.GetShortcutFileName]));
  end
  else
  begin
    Memo1.Lines.Add('App was not run by clicking a shortcut');
  end;
end;

end.
