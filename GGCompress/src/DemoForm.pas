unit DemoForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  GnuGetText;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
  UseLanguage('de');
  RetranslateComponent(Self);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  UseLanguage('en');
  RetranslateComponent(Self);
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  UseLanguage('es');
  RetranslateComponent(Self);
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  UseLanguage('it');
  RetranslateComponent(Self);
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  UseLanguage('fr');
  RetranslateComponent(Self);
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
  UseLanguage('nl');
  RetranslateComponent(Self);
end;

procedure TForm1.Button7Click(Sender: TObject);
begin
  UseLanguage('pt');
  RetranslateComponent(Self);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  TranslateComponent(Self);
end;

end.
