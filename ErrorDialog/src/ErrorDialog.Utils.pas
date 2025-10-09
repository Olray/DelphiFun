unit ErrorDialog.Utils;

interface

uses
  System.SysUtils,
  System.Classes,
  Vcl.Controls,
  Winapi.Windows,
  ErrorDialog.Types;

type
  // Utility functions for the error dialog system
  TErrorDialogUtils = class
  public
    // Icon utilities
    class function GetSystemIcon(AIcon: TErrorIcon): HICON;
    class function ExtractApplicationIcon: HICON;
    class function IconToImageIndex(AIcon: TErrorIcon): Integer;
    
    // Text formatting utilities
    class function FormatMarkdownText(const AText: string): string;
    class function StripMarkdown(const AText: string): string;
    class function WordWrap(const AText: string; AMaxWidth: Integer): string;
    
    // System information utilities
    class function GetApplicationVersion: string;
    class function GetMemoryUsage: string;
    class function GetSystemInfo: string;
    class function GetCurrentTimestamp: string;
    class function FormatExceptionInfo(AException: Exception): string;
    
    // Dialog utilities
    class function ErrorIconToSystemIcon(AIcon: TErrorIcon): PChar;
    class function ErrorButtonsToFlags(AButtons: TErrorButtons): Integer;
    class function ModalResultToString(AResult: TModalResult): string;
  end;

implementation

uses
  System.IOUtils,
  System.StrUtils,
  Winapi.ShellAPI,
  Winapi.PsAPI;

{ TErrorDialogUtils }

class function TErrorDialogUtils.GetSystemIcon(AIcon: TErrorIcon): HICON;
const
  IconMap: array[TErrorIcon] of PChar = (
    nil,                    // eiNone
    IDI_INFORMATION,        // eiInformation
    IDI_WARNING,           // eiWarning
    IDI_ERROR,             // eiError
    IDI_QUESTION,          // eiQuestion
    IDI_APPLICATION        // eiApplication
  );
begin
  if AIcon = eiNone then
    Result := 0
  else if AIcon = eiApplication then
    Result := ExtractApplicationIcon
  else
    Result := LoadIcon(0, IconMap[AIcon]);
end;

class function TErrorDialogUtils.ExtractApplicationIcon: HICON;
var
  ExePath: string;
  IconCount: Integer;
begin
  Result := 0;
  ExePath := ParamStr(0);
  
  if FileExists(ExePath) then
  begin
    IconCount := ExtractIcon(HInstance, PChar(ExePath), UINT(-1));
    if IconCount > 0 then
      Result := ExtractIcon(HInstance, PChar(ExePath), 0);
  end;
  
  // Fallback to application icon
  if Result = 0 then
    Result := LoadIcon(0, IDI_APPLICATION);
end;

class function TErrorDialogUtils.IconToImageIndex(AIcon: TErrorIcon): Integer;
begin
  Result := Ord(AIcon);
end;

class function TErrorDialogUtils.FormatMarkdownText(const AText: string): string;
begin
  Result := AText;
  // Simple markdown processing
  Result := StringReplace(Result, '**', #1, [rfReplaceAll]); // Bold marker
  Result := StringReplace(Result, '__', #2, [rfReplaceAll]); // Italic marker
  Result := StringReplace(Result, '\n', sLineBreak, [rfReplaceAll]); // Line breaks
  // Note: Actual formatting will be handled by the form renderer
end;

class function TErrorDialogUtils.StripMarkdown(const AText: string): string;
begin
  Result := AText;
  Result := StringReplace(Result, '**', '', [rfReplaceAll]);
  Result := StringReplace(Result, '__', '', [rfReplaceAll]);
  Result := StringReplace(Result, '\n', sLineBreak, [rfReplaceAll]);
end;

class function TErrorDialogUtils.WordWrap(const AText: string; AMaxWidth: Integer): string;
begin
  // Simple word wrap implementation
  // TODO: Implement proper word wrapping based on character width
  Result := AText;
end;

class function TErrorDialogUtils.GetApplicationVersion: string;
var
  FileName: string;
  InfoSize: DWORD;
  VerInfo: Pointer;
  FileInfo: PVSFixedFileInfo;
  VerValue: UINT;
begin
  Result := 'Unknown';
  FileName := ParamStr(0);
  
  InfoSize := GetFileVersionInfoSize(PChar(FileName), InfoSize);
  if InfoSize <> 0 then
  begin
    GetMem(VerInfo, InfoSize);
    try
      if GetFileVersionInfo(PChar(FileName), 0, InfoSize, VerInfo) then
      begin
        if VerQueryValue(VerInfo, '\', Pointer(FileInfo), VerValue) then
        begin
          Result := Format('%d.%d.%d.%d', [
            FileInfo.dwFileVersionMS shr 16,
            FileInfo.dwFileVersionMS and $FFFF,
            FileInfo.dwFileVersionLS shr 16,
            FileInfo.dwFileVersionLS and $FFFF
          ]);
        end;
      end;
    finally
      FreeMem(VerInfo);
    end;
  end;
end;

class function TErrorDialogUtils.GetMemoryUsage: string;
var
  MemInfo: TProcessMemoryCounters;
begin
  if GetProcessMemoryInfo(GetCurrentProcess, @MemInfo, SizeOf(MemInfo)) then
    Result := Format('%.1f MB', [MemInfo.WorkingSetSize / (1024 * 1024)])
  else
    Result := 'Unknown';
end;

class function TErrorDialogUtils.GetSystemInfo: string;
var
  OSVersion: TOSVersion;
begin
  Result := Format('%s %s', [OSVersion.Name, OSVersion.ToString]);
end;

class function TErrorDialogUtils.GetCurrentTimestamp: string;
begin
  Result := FormatDateTime('yyyy-mm-dd hh:nn:ss', Now);
end;

class function TErrorDialogUtils.FormatExceptionInfo(AException: Exception): string;
begin
  if Assigned(AException) then
    Result := Format('%s: %s', [AException.ClassName, AException.Message])
  else
    Result := 'No exception information';
end;

class function TErrorDialogUtils.ErrorIconToSystemIcon(AIcon: TErrorIcon): PChar;
begin
  case AIcon of
    eiInformation: Result := IDI_INFORMATION;
    eiWarning: Result := IDI_WARNING;
    eiError: Result := IDI_ERROR;
    eiQuestion: Result := IDI_QUESTION;
    eiApplication: Result := IDI_APPLICATION;
  else
    Result := IDI_INFORMATION;
  end;
end;

class function TErrorDialogUtils.ErrorButtonsToFlags(AButtons: TErrorButtons): Integer;
begin
  case AButtons of
    ebOK: Result := MB_OK;
    ebOKCancel: Result := MB_OKCANCEL;
    ebYesNo: Result := MB_YESNO;
    ebYesNoCancel: Result := MB_YESNOCANCEL;
    ebRetryCancel: Result := MB_RETRYCANCEL;
    ebAbortRetryIgnore: Result := MB_ABORTRETRYIGNORE;
  else
    Result := MB_OK;
  end;
end;

class function TErrorDialogUtils.ModalResultToString(AResult: TModalResult): string;
begin
  case AResult of
    mrOk: Result := 'OK';
    mrCancel: Result := 'Cancel';
    mrAbort: Result := 'Abort';
    mrRetry: Result := 'Retry';
    mrIgnore: Result := 'Ignore';
    mrYes: Result := 'Yes';
    mrNo: Result := 'No';
  else
    Result := 'Unknown';
  end;
end;

end.