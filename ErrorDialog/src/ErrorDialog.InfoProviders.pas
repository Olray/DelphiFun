unit ErrorDialog.InfoProviders;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  ErrorDialog.Types,
  ErrorDialog.Utils;

type
  // Base implementation for all info providers
  TInfoProviderBase = class(TInterfacedObject, IInfoProvider)
  protected
    FDisplayName: string;
  public
    constructor Create(const ADisplayName: string);
    function GetDisplayName: string; virtual;
    function IsAvailable: Boolean; virtual;
    function GetInfo: TPair<string, string>; virtual; abstract;
  end;

  // Version information provider
  TVersionInfoProvider = class(TInfoProviderBase)
  public
    constructor Create;
    function GetInfo: TPair<string, string>; override;
    function IsAvailable: Boolean; override;
  end;

  // Memory usage provider
  TMemoryUsageInfoProvider = class(TInfoProviderBase)
  public
    constructor Create;
    function GetInfo: TPair<string, string>; override;
  end;

  // System information provider
  TSystemInfoProvider = class(TInfoProviderBase)
  public
    constructor Create;
    function GetInfo: TPair<string, string>; override;
  end;

  // Timestamp provider
  TTimestampInfoProvider = class(TInfoProviderBase)
  public
    constructor Create;
    function GetInfo: TPair<string, string>; override;
  end;

  // Exception information provider
  TExceptionInfoProvider = class(TInfoProviderBase)
  private
    FException: Exception;
  public
    constructor Create(AException: Exception);
    function GetInfo: TPair<string, string>; override;
    function IsAvailable: Boolean; override;
  end;

  // Factory implementation for creating info providers
  TInfoProviderFactory = class(TInterfacedObject, IInfoProviderFactory)
  public
    // Factory methods
    function CreateVersionInfo: IInfoProvider;
    function CreateMemoryUsage: IInfoProvider;
    function CreateSystemInfo: IInfoProvider;
    function CreateTimestamp: IInfoProvider;
    function CreateExceptionInfo(AException: Exception): IInfoProvider;
    
    // Convenience properties
    function GetVersionInfo: IInfoProvider;
    function GetMemoryUsage: IInfoProvider;
    function GetSystemInfo: IInfoProvider;
    function GetTimestamp: IInfoProvider;
    
    // Helper method for exception info
    function ExceptionInfo(AException: Exception): IInfoProvider;
  end;

// Global factory instance
function InfoProviders: IInfoProviderFactory;

implementation

var
  GInfoProviderFactory: IInfoProviderFactory;

function InfoProviders: IInfoProviderFactory;
begin
  if not Assigned(GInfoProviderFactory) then
    GInfoProviderFactory := TInfoProviderFactory.Create;
  Result := GInfoProviderFactory;
end;

{ TInfoProviderBase }

constructor TInfoProviderBase.Create(const ADisplayName: string);
begin
  inherited Create;
  FDisplayName := ADisplayName;
end;

function TInfoProviderBase.GetDisplayName: string;
begin
  Result := FDisplayName;
end;

function TInfoProviderBase.IsAvailable: Boolean;
begin
  Result := True; // Most providers are always available
end;

{ TVersionInfoProvider }

constructor TVersionInfoProvider.Create;
begin
  inherited Create('Application Version');
end;

function TVersionInfoProvider.GetInfo: TPair<string, string>;
begin
  Result := TPair<string, string>.Create('Application Version', TErrorDialogUtils.GetApplicationVersion);
end;

function TVersionInfoProvider.IsAvailable: Boolean;
begin
  Result := ParamStr(0) <> '';
end;

{ TMemoryUsageInfoProvider }

constructor TMemoryUsageInfoProvider.Create;
begin
  inherited Create('Memory Usage');
end;

function TMemoryUsageInfoProvider.GetInfo: TPair<string, string>;
begin
  Result := TPair<string, string>.Create('Memory Usage', TErrorDialogUtils.GetMemoryUsage);
end;

{ TSystemInfoProvider }

constructor TSystemInfoProvider.Create;
begin
  inherited Create('System Information');
end;

function TSystemInfoProvider.GetInfo: TPair<string, string>;
begin
  Result := TPair<string, string>.Create('Operating System', TErrorDialogUtils.GetSystemInfo);
end;

{ TTimestampInfoProvider }

constructor TTimestampInfoProvider.Create;
begin
  inherited Create('Timestamp');
end;

function TTimestampInfoProvider.GetInfo: TPair<string, string>;
begin
  Result := TPair<string, string>.Create('Timestamp', TErrorDialogUtils.GetCurrentTimestamp);
end;

{ TExceptionInfoProvider }

constructor TExceptionInfoProvider.Create(AException: Exception);
begin
  inherited Create('Exception Details');
  FException := AException;
end;

function TExceptionInfoProvider.GetInfo: TPair<string, string>;
begin
  Result := TPair<string, string>.Create('Exception', TErrorDialogUtils.FormatExceptionInfo(FException));
end;

function TExceptionInfoProvider.IsAvailable: Boolean;
begin
  Result := Assigned(FException);
end;

{ TInfoProviderFactory }

function TInfoProviderFactory.CreateVersionInfo: IInfoProvider;
begin
  Result := TVersionInfoProvider.Create;
end;

function TInfoProviderFactory.CreateMemoryUsage: IInfoProvider;
begin
  Result := TMemoryUsageInfoProvider.Create;
end;

function TInfoProviderFactory.CreateSystemInfo: IInfoProvider;
begin
  Result := TSystemInfoProvider.Create;
end;

function TInfoProviderFactory.CreateTimestamp: IInfoProvider;
begin
  Result := TTimestampInfoProvider.Create;
end;

function TInfoProviderFactory.CreateExceptionInfo(AException: Exception): IInfoProvider;
begin
  Result := TExceptionInfoProvider.Create(AException);
end;

function TInfoProviderFactory.GetVersionInfo: IInfoProvider;
begin
  Result := CreateVersionInfo;
end;

function TInfoProviderFactory.GetMemoryUsage: IInfoProvider;
begin
  Result := CreateMemoryUsage;
end;

function TInfoProviderFactory.GetSystemInfo: IInfoProvider;
begin
  Result := CreateSystemInfo;
end;

function TInfoProviderFactory.GetTimestamp: IInfoProvider;
begin
  Result := CreateTimestamp;
end;

function TInfoProviderFactory.ExceptionInfo(AException: Exception): IInfoProvider;
begin
  Result := CreateExceptionInfo(AException);
end;

end.