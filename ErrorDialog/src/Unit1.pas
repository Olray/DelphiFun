unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs;

type
  TForm1 = class(TForm)
    procedure FormCreate(Sender: TObject);
  end;

var
  Form1: TForm1;

implementation
uses
  ErrorDialog.Core,
  ErrorDialog.InfoProviders;

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
//  TErrorDialog.Warning('AI slop ahead!');
  TErrorDialog.New
    .SetTitle('Error Title')
    .SetMessage('This is a {red}demo error{/red} with **bold text** and __italic text__ and a word wrap function when the line gets too long.\n\n{blue}This is blue {green}with green inside{/green} back to blue{/blue}\nA line break is done with Slash-n (easier than +sLineBreak)\nThe error window height grows with every line.')
    .SetExtraInfo([InfoProviders.MemoryUsage, InfoProviders.SystemInfo])
    .ShowModal;
  Application.Terminate;
end;

end.
