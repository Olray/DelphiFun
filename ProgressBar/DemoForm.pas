unit DemoForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, ProgressBarFrame;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    ProgressFrame1: TProgressFrame;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    procedure DoProgress(Progress: IProgress);
  public
    { Public-Deklarationen }
  end;

var
  Form1: TForm1;

implementation
uses
  ProgressBarDlg;

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
  DoProgress(ProgressFrame1);
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  ProgressForm: TProgressForm;
  Progress: IProgress;
begin
  ProgressForm := TProgressForm.Create(Self);
  ProgressForm.Show;
  try
    Progress := ProgressForm.GetProgressInterface;
    DoProgress(Progress);
  finally
    ProgressForm.Free;
  end;
end;

procedure TForm1.DoProgress(Progress: IProgress);
begin
  Progress.StartProgress(
    procedure(Progress: IProgress)
    begin
      Button1.Enabled := False;
      Button2.Enabled := False;

      Progress.SetTitle('Title of the progress thing')
              .SetCompletedString('of all work done')
              .ClearActions
              .AddAction(0, 'just started...')
              .AddAction(33, 'one third is done...')
              .AddAction(50, 'we''re half way through the work...')
              .AddAction(66, 'well on our way...')
              .AddAction(90, 'almost done, yay!')
              .AddAction(100, 'work completed!');

      for var i := 1 to 100 do
      begin
        Sleep(50);
        Progress.SetPercentage(i);
      end;
    end,
    procedure(Progress: IProgress)
    begin
      Button1.Enabled := True;
      Button2.Enabled := True;
    end
  );
end;

end.
