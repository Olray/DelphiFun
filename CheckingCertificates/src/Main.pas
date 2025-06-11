unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TMainForm = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    lblAppName: TLabel;
    lblCertStatus: TLabel;
    lblCertOwner: TLabel;
    lblCertIssuer: TLabel;
    lblFingerprint: TLabel;
    procedure FormCreate(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  MainForm: TMainForm;

implementation
uses SignInfo;

resourcestring
  sNoValue = '<not applicable>';

{$R *.dfm}


procedure TMainForm.FormCreate(Sender: TObject);
var
  Tester: ISignInfo;
  ExePath: string;
begin
    // do not rely on ParamStr(0)
  ExePath := GetCurrentExecutablePath;

  Tester := TSignInfo.Create(ExePath);

  lblAppName.Caption := ExtractFileName(ExePath);
  if IsTrustedExecutableImage(ExePath) then
    lblCertStatus.Caption := 'this app is digitally signed'
  else
    if Tester.IsSigned then
      lblCertStatus.Caption := 'this app is digitally signed but untrusted'
    else
      lblCertStatus.Caption := 'this app is unsigned';

  if Tester.IsSigned then
  begin
    lblCertOwner.Caption   := Tester.GetCertOwnerString;
    lblCertIssuer.Caption  := Tester.GetCertIssuerString;
    lblFingerprint.Caption := Tester.GetCertFingerprintString;
  end
  else
  begin
    lblCertOwner.Caption   := sNoValue;
    lblCertIssuer.Caption  := sNoValue;
    lblFingerprint.Caption := sNoValue;
  end;
end;

end.
