unit ProgressBarFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls;

type
  TProgressAction = record
    StartPercentage: Integer;
    Message: string;
  end;
  TProgressActionList = TArray<TProgressAction>;

  IProgress = interface
    ['{05290683-7AC6-452A-BD8C-184319239B75}']
      // Initialization
    function SetTitle(const ATitleString: string): IProgress;
    function GetTitle: string;
    function ClearActions: IProgress;
    function SetAction(const AActionString: string): IProgress;
    function AddAction(const StartPercentage: Integer; const AActionString: string): IProgress; overload;
    function SetCompletedString(const AString: string): IProgress;
      // progress
    procedure StartProgress(Worker: TProc<IProgress>; Finalizer: TProc<IProgress>);
    procedure SetPercentage(const Percentage: Integer);
  end;

  TProgressActionContainer = class
  private
    FProgressList: TProgressActionList;
  public
    function SetAction(const AActionString: string): TProgressActionContainer;
    function AddAction(const StartPercentage: Integer; const AMessage: string): TProgressActionContainer; overload;
    function GetActionStringByPercentage(const Percentage: Integer): string;
    function Clear: TProgressActionContainer;
  end;

  TProgressFrame = class(TFrame, IProgress)
    lblProgressTitle: TLabel;
    lblPercentageString: TLabel;
    lblCompletedString: TLabel;
    pbProgress: TProgressBar;
    lblActionString: TLabel;
  private
    FPercentage: Integer;
    FProgressActionList: TProgressActionContainer;
    procedure UpdateActionLabel;
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
  public
    function GetProgressInterface: IProgress;
      // Initialization
    function SetTitle(const ATitleString: string): IProgress;
    function GetTitle: string;
    function SetCompletedString(const AString: string): IProgress;
      // Actions
    function ClearActions: IProgress;
    function SetAction(const AActionString: string): IProgress;
    function AddAction(const StartPercentage: Integer; const AActionString: string): IProgress; overload;
      // progress
    procedure StartProgress(Worker: TProc<IProgress>; Finalizer: TProc<IProgress>);
    procedure SetPercentage(const Percentage: Integer);
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

function TProgressFrame.AddAction(const StartPercentage: Integer; const AActionString: string): IProgress;
begin
  FProgressActionList.AddAction(StartPercentage, AActionString);
  UpdateActionLabel;
  Result := Self;
end;

procedure TProgressFrame.AfterConstruction;
begin
  inherited;
  FProgressActionList := TProgressActionContainer.Create;
end;

procedure TProgressFrame.BeforeDestruction;
begin
  FProgressActionList.Free;
  inherited;
end;

function TProgressFrame.ClearActions: IProgress;
begin
  FProgressActionList.Clear;
  UpdateActionLabel;
  Result := Self;
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
  FProgressActionList
    .Clear
    .AddAction(0, AActionString);

  UpdateActionLabel;
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
    UpdateActionLabel;
  end;
  MessageLoop;
end;

procedure TProgressFrame.StartProgress(Worker, Finalizer: TProc<IProgress>);
begin
  try
    if Assigned(Worker) then
      Worker(Self);
  finally
    if Assigned(Finalizer) then
      Finalizer(Self);
  end;
end;

procedure TProgressFrame.UpdateActionLabel;
var
  AMessage: string;
begin
  AMessage := FProgressActionList.GetActionStringByPercentage(FPercentage);
  lblActionString.Caption := AMessage;
  MessageLoop;
end;

{ TProgressActionContainer }

function TProgressActionContainer.GetActionStringByPercentage(const Percentage: Integer): string;
begin
  Result := '';
  if Length(FProgressList) = 0 then
    Exit;
  if Length(FProgressList) = 1 then
    Exit(FProgressList[0].Message);

  for var i := 1 to High(FProgressList) do
  begin
    if (Percentage >= FProgressList[i-1].StartPercentage) and (Percentage < FProgressList[i].StartPercentage) then
      Exit(FProgressList[i-1].Message);
  end;

  Result := FProgressList[Pred(Length(FProgressList))].Message;
end;

function TProgressActionContainer.Clear: TProgressActionContainer;
begin
  SetLength(FProgressList, 0);
  Result := Self;
end;

function TProgressActionContainer.AddAction(const StartPercentage: Integer;
  const AMessage: string): TProgressActionContainer;

  function MaxStartPercentageFromList: Integer;
  var
    TempAction: TProgressAction;
  begin
    Result := 0;
    for TempAction in FProgressList do
    begin
      if TempAction.StartPercentage > Result then
        Result := TempAction.StartPercentage;
    end;
  end;

var
  NewAction: TProgressAction;
begin
  NewAction.StartPercentage := StartPercentage;
  NewAction.Message := AMessage;

  var TempMaxPercentage := MaxStartPercentageFromList;
  if StartPercentage < TempMaxPercentage then
  begin
    NewAction.StartPercentage := TempMaxPercentage;
  end;

  SetLength(FProgressList, Succ(Length(FProgressList)));
  FProgressList[Pred(Length(FProgressList))] := NewAction;
  Result := Self;
end;

function TProgressActionContainer.SetAction(const AActionString: string): TProgressActionContainer;
begin
  Clear.AddAction(0, AActionString);
end;

end.
