unit ErrorDialog.Builder;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  Vcl.Dialogs,
  Vcl.Controls,
  ErrorDialog.Types,
  ErrorDialog.Form,
  ErrorDialog.InfoProviders;

type
  // Builder implementation for fluent API
  TErrorDialogBuilder = class(TInterfacedObject, IErrorDialog)
  private
    FConfig: TErrorDialogConfig;
    FInfoProvidersList: TList<IInfoProvider>;
    FUseDefaultProviders: Boolean;
    
    procedure InitializeDefaults;
    function GetDefaultInfoProviders: TArray<IInfoProvider>;
    function CombineProviders: TArray<IInfoProvider>;
  public
    constructor Create;
    destructor Destroy; override;
    
    // IErrorDialog implementation
    function SetTitle(const ATitle: string): IErrorDialog;
    function SetMessage(const AMessage: string): IErrorDialog;
    function SetIcon(AIcon: TErrorIcon): IErrorDialog;
    function SetButtons(AButtons: TErrorButtons): IErrorDialog;
    function SetExtraInfo(const AProviders: array of IInfoProvider): IErrorDialog; overload;
    function SetExtraInfo(const AProvider: IInfoProvider): IErrorDialog; overload;
    function AddExtraInfo(const AProvider: IInfoProvider): IErrorDialog;
    function ClearExtraInfo: IErrorDialog;
    function DisableDefaultProviders: IErrorDialog; // New method to disable defaults
    function ShowModal: TModalResult;
  end;

implementation

{ TErrorDialogBuilder }

constructor TErrorDialogBuilder.Create;
begin
  inherited Create;
  FInfoProvidersList := TList<IInfoProvider>.Create;
  FUseDefaultProviders := True; // Enable default providers by default
  InitializeDefaults;
end;

destructor TErrorDialogBuilder.Destroy;
begin
  FInfoProvidersList.Free;
  inherited Destroy;
end;

procedure TErrorDialogBuilder.InitializeDefaults;
begin
  FConfig.Title := 'Error';
  FConfig.Message := '';
  FConfig.Icon := eiError;
  FConfig.Buttons := ebOK;
  FConfig.ShowExtraButton := False;
  FConfig.Theme := 'Default';
  SetLength(FConfig.InfoProviders, 0);
end;

function TErrorDialogBuilder.SetTitle(const ATitle: string): IErrorDialog;
begin
  FConfig.Title := ATitle;
  Result := Self;
end;

function TErrorDialogBuilder.SetMessage(const AMessage: string): IErrorDialog;
begin
  FConfig.Message := AMessage;
  Result := Self;
end;

function TErrorDialogBuilder.SetIcon(AIcon: TErrorIcon): IErrorDialog;
begin
  FConfig.Icon := AIcon;
  Result := Self;
end;

function TErrorDialogBuilder.SetButtons(AButtons: TErrorButtons): IErrorDialog;
begin
  FConfig.Buttons := AButtons;
  Result := Self;
end;

function TErrorDialogBuilder.SetExtraInfo(const AProviders: array of IInfoProvider): IErrorDialog;
var
  I: Integer;
begin
  FInfoProvidersList.Clear;
  for I := 0 to High(AProviders) do
    FInfoProvidersList.Add(AProviders[I]);
    
  // Always show extra button when we have custom providers OR default providers
  FConfig.ShowExtraButton := (FInfoProvidersList.Count > 0) or FUseDefaultProviders;
  Result := Self;
end;

function TErrorDialogBuilder.SetExtraInfo(const AProvider: IInfoProvider): IErrorDialog;
begin
  FInfoProvidersList.Clear;
  if Assigned(AProvider) then
  begin
    FInfoProvidersList.Add(AProvider);
    FConfig.ShowExtraButton := True;
  end
  else
    FConfig.ShowExtraButton := FUseDefaultProviders; // Show if defaults are enabled
    
  Result := Self;
end;

function TErrorDialogBuilder.AddExtraInfo(const AProvider: IInfoProvider): IErrorDialog;
begin
  if Assigned(AProvider) then
  begin
    FInfoProvidersList.Add(AProvider);
    FConfig.ShowExtraButton := True;
  end;
  Result := Self;
end;

function TErrorDialogBuilder.ClearExtraInfo: IErrorDialog;
begin
  FInfoProvidersList.Clear;
  FConfig.ShowExtraButton := FUseDefaultProviders; // Show if defaults are enabled
  Result := Self;
end;

function TErrorDialogBuilder.DisableDefaultProviders: IErrorDialog;
begin
  FUseDefaultProviders := False;
  FConfig.ShowExtraButton := FInfoProvidersList.Count > 0; // Only show if custom providers exist
  Result := Self;
end;

function TErrorDialogBuilder.ShowModal: TModalResult;
var
  CombinedProviders: TArray<IInfoProvider>;
begin
  // Combine custom providers (priority) with default providers
  CombinedProviders := CombineProviders;
  FConfig.InfoProviders := CombinedProviders;
    
  // Show the dialog
  Result := TErrorDialogForm.ShowErrorDialog(FConfig);
end;

function TErrorDialogBuilder.GetDefaultInfoProviders: TArray<IInfoProvider>;
begin
  // Define sensible default providers
  Result := [
    InfoProviders.VersionInfo
  ];
end;

function TErrorDialogBuilder.CombineProviders: TArray<IInfoProvider>;
var
  DefaultProviders: TArray<IInfoProvider>;
  TotalCount: Integer;
  I, Index: Integer;
begin
  if not FUseDefaultProviders then
  begin
    // Only custom providers
    SetLength(Result, FInfoProvidersList.Count);
    for I := 0 to FInfoProvidersList.Count - 1 do
      Result[I] := FInfoProvidersList[I];
  end
  else
  begin
    // Combine custom (first) + defaults (after)
    DefaultProviders := GetDefaultInfoProviders;
    TotalCount := FInfoProvidersList.Count + Length(DefaultProviders);
    SetLength(Result, TotalCount);
    
    // Add custom providers first (highest priority)
    Index := 0;
    for I := 0 to FInfoProvidersList.Count - 1 do
    begin
      Result[Index] := FInfoProvidersList[I];
      Inc(Index);
    end;
    
    // Add default providers after
    for I := 0 to High(DefaultProviders) do
    begin
      Result[Index] := DefaultProviders[I];
      Inc(Index);
    end;
  end;
end;

end.