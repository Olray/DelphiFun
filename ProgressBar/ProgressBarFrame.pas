unit ProgressBarFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls;

type
  IProgress = interface
    ['{05290683-7AC6-452A-BD8C-184319239B75}']
      // Initialization
    function SetTitle(const ATitleString: string): IProgress;
    function GetTitle: string;
    function SetAction(const AActionString: string): IProgress;
    function SetCompletedString(const AString: string): IProgress;
      // progress
    procedure StartProgress(Worker: TProc<IProgress>; Finalizer: TProc<IProgress>);
    procedure SetPercentage(const Percentage: Integer);
    procedure Finalize;
  end;


  TProgressFrame = class(TFrame, IProgress)
    lblProgressTitle: TLabel;
    lblPercentageString: TLabel;
    lblCompletedString: TLabel;
    pbProgress: TProgressBar;
    lblActionString: TLabel;
  private
    FPercentage: Integer;
  public
    constructor Create(Owner: TComponent);
    function GetProgressInterface: IProgress;
      // Initialization
    function SetTitle(const ATitleString: string): IProgress;
    function GetTitle: string;
    function SetAction(const AActionString: string): IProgress;
    function SetCompletedString(const AString: string): IProgress;
      // progress
    procedure StartProgress(Worker: TProc<IProgress>; Finalizer: TProc<IProgress>);
    procedure SetPercentage(const Percentage: Integer);
    procedure Finalize;
  end;

implementation

{$R *.dfm}

procedure MessageLoop;
var
  Msg: TMsg;
begin
  while PeekMessage(Msg, 0, 0, 0, PM_REMOVE) do
  begin
    TranslateMessage(Msg);
    DispatchMessage(Msg);
  end;
end;

{ TProgressFrame }

constructor TProgressFrame.Create(Owner: TComponent);
begin
  inherited;
  SetPercentage(0);
end;

function TProgressFrame.GetProgressInterface: IProgress;
begin
  Result := Self;
end;

function TProgressFrame.GetTitle: string;
begin
  Result := lblProgressTitle.Caption;
  MessageLoop;
end;

function TProgressFrame.SetTitle(const ATitleString: string): IProgress;
begin
  lblProgressTitle.Caption := ATitleString;
  MessageLoop;
  Result := Self;
end;

function TProgressFrame.SetAction(const AActionString: string): IProgress;
begin
  lblActionString.Caption := AActionString;
  MessageLoop;
  Result := Self;
end;

function TProgressFrame.SetCompletedString(const AString: string): IProgress;
begin
  lblCompletedString.Caption := AString;
  MessageLoop;
  Result := Self;
end;

procedure TProgressFrame.SetPercentage(const Percentage: Integer);
var
  NewPercentage: Integer;
begin
  if(Percentage < 0) then NewPercentage := 0
    else if(Percentage > 100) then NewPercentage := 100
    else NewPercentage := Percentage;

  if NewPercentage <> FPercentage then
  begin
    pbProgress.Position := Percentage;
    lblPercentageString.Caption := IntToStr(Percentage)+'%';
    FPercentage := NewPercentage;
  end;
  MessageLoop;
end;

procedure TProgressFrame.Finalize;
begin
  // do nothing in frame. It's destroyed from the owners destructor
end;

procedure TProgressFrame.StartProgress(Worker, Finalizer: TProc<IProgress>);
begin
  if Assigned(Worker) then
    Worker(Self);
  if Assigned(Finalizer) then
    Finalizer(Self);
end;

end.
