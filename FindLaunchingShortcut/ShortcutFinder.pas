unit ShortcutFinder;

interface
uses
  Winapi.Windows;

type
  IOriginatingShortcutFinder = interface
    ['{040DF9DE-55AD-4C52-BA96-46FAD8701C2B}']
    function IsRunByShortcut: Boolean;
    function GetShortcutFileName: string;
  end;

  TOriginatingShortcutFinder = class(TInterfacedObject, IOriginatingShortcutFinder)
  const
      // https://learn.microsoft.com/en-us/windows/win32/api/processthreadsapi/ns-processthreadsapi-startupinfow
    STARTF_TITLEISLINKNAME = $00000800;
  strict private
    FStartupInfo: TStartupInfo;
    function GetTitleString: string;
  public
    constructor Create;
    function IsRunByShortcut: Boolean;
    function GetShortcutFileName: string;
  end;

implementation

constructor TOriginatingShortcutFinder.Create;
begin
  FillChar(FStartupInfo, SizeOf(TStartupInfo), 0);
  FStartupInfo.cb := SizeOf(TStartupInfo);
  GetStartupInfo(FStartupInfo);
end;

function TOriginatingShortcutFinder.GetShortcutFileName: string;
begin
  Result := '';
  if IsRunByShortcut then
    Result := GetTitleString;
end;

function TOriginatingShortcutFinder.GetTitleString: string;
begin
  SetString(Result, FStartupInfo.lpTitle, Length(FStartupInfo.lpTitle));
end;

function TOriginatingShortcutFinder.IsRunByShortcut: Boolean;
begin
  Result := (FStartupInfo.dwFlags and STARTF_TITLEISLINKNAME) <> 0;
end;

end.
