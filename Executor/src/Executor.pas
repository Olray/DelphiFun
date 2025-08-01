unit Executor;

interface
uses
  System.SysUtils, // ExtractFilePath, Exception
  System.Classes, // TThread
  Winapi.Windows, // TProcessInformation
  Executor.Interfaces;

type
  TWaitFunction = reference to function : Cardinal;
    // check if an application is digitally signed and accepted by Windows
  TSecurityAppSignChecker = reference to function(const ImageFileName : String) : Boolean;

  TExecutor = class(TInterfacedObject, IExecutor)
  strict private
    FWaitFunction: TWaitFunction;
    FLastWin32Error: Cardinal;
    FOnErrorMethod: TErrorCallbackMethod;
    FOnSuccessMethod: TSuccessCallbackMethod;
    FExitMonitorMethod: TExitMonitorMethod;
      // services
    FCreateProcess: ICreateProcess;
    FExitMonitor: IProcessExitWaiter;
      // should we wait in foreground or background?
    FWaitMethod : TWaitMethod;
    FBackgroundThread: TThread;
      // Waits for process to end in background. Main thread continues running
    function WaitInBackground : Cardinal;
    procedure WaitForProcessExitBackground;
      // Waits for process to end in foreground. Main thread is blocked and
      // a Peek/Translate/DispatchMessage loop is initiated
    function WaitInForeground : Cardinal;
      // runs the executable with CreateProcess()
    procedure StartProcess(ShowWindow : Boolean);
      // callback methods
    procedure PostExecute;
      // checks if an executable is digitally signed with *any* certificate
    function IsTrustedExecutableImage(const ImageFileName: string): Boolean;
  public
    constructor Create(
          const CreateProcess: ICreateProcess;
          const ExitMethod: IProcessExitWaiter);
    destructor Destroy; override;
    procedure Execute(
          const WaitMethod: TWaitMethod;
          const ShowWindow: Boolean;
          const OnSuccess: TSuccessCallbackMethod = nil;
          const OnError: TErrorCallbackMethod = nil;
          const AllowUnsafe: Boolean = True);
  end;

  TCreateProcess = class(TInterfacedObject, ICreateProcess)
  strict private
    FExecutable: string;
    FExecutableRootPath: string;
    FParameterString: string;
    FShowWindow: Boolean;
    FAllowUnsafe: Boolean;
    F_Pi: TProcessInformation;
  public
      // getters/setters
    procedure SetExecutable(const Value: string);
    function GetExecutable: string;
    procedure SetExecutableRootPath(const Value: string);
    function GetExecutableRootPath: string;
    procedure SetParameterString(const Value: string);
    function GetParameterString: string;
    procedure SetShowWindow(const Value: Boolean);
    function GetShowWindow: Boolean;
    procedure SetAllowUnsafe(const Value: Boolean);
    function GetAllowUnsafe: Boolean;
      // execution
    function CreateProcess: Cardinal;
    function Error: Boolean;
    function GetProcessId: Cardinal;
  end;

implementation

{ TExecutor }

constructor TExecutor.Create(
  const CreateProcess: ICreateProcess;
  const ExitMethod   : IProcessExitWaiter);
begin
  Assert(CreateProcess <> nil, 'CreateProcess cannot be nil');
  Assert(ExitMethod <> nil, 'ExitMethod cannot be nil');

  FCreateProcess := CreateProcess;
  FExitMonitor := ExitMethod;

  FLastWin32Error := ERROR_SUCCESS;
end;

destructor TExecutor.Destroy;
begin
  if Assigned(FBackgroundThread) then
    FBackgroundThread.Terminate;
  FreeAndNil(FBackgroundThread);
  inherited;
end;

procedure TExecutor.Execute(
    const WaitMethod: TWaitMethod;
    const ShowWindow: Boolean;
    const OnSuccess: TSuccessCallbackMethod = nil;
    const OnError: TErrorCallbackMethod = nil;
    const AllowUnsafe: Boolean = True);
begin
    // if AllowUnsafe is false, check if the executable in FExeFile is digitally
    // signed and trusted by Windows
  if not AllowUnsafe then
  begin
    if not IsTrustedExecutableImage(FCreateProcess.GetExecutable) then
      raise EDigitallyUnsigned.Create(FCreateProcess.GetExecutable);
  end;

  if(WaitMethod = wmWaitInBackground) then
    FWaitFunction := WaitInBackground
  else
    FWaitFunction := WaitInForeground;
  FWaitMethod := WaitMethod;

  if not Assigned(OnError) then
    FOnErrorMethod := procedure(const Win32Error: Cardinal) begin end
  else
    FOnErrorMethod := OnError;
  if not Assigned(OnSuccess) then
    FOnSuccessMethod := procedure begin end
  else
    FOnSuccessMethod := OnSuccess;

  StartProcess(ShowWindow);

    // only at this point we have the process id for FExitMonitorMethod = emByProcessId)
  case FExitMonitor.GetIdentifier of
    emByProcessId:   FExitMonitor.SetParameter(FCreateProcess.GetProcessId);
    emByProcessName: FExitMonitor.SetParameter(ExtractFileName(FCreateProcess.GetExecutable));
    emByProcessPath: FExitMonitor.SetParameter(FCreateProcess.GetExecutable);
  else
    raise Exception.Create('unknown FExitMonitorMethod: update case in TExecutor.Execute if you implement new wait methods');
  end;

    // failed CreateProcess()?
  if(FLastWin32Error <> ERROR_SUCCESS) then
  begin
    if Assigned(FOnErrorMethod) then
      FOnErrorMethod(FLastWin32Error)
  end
  else
  begin
    FWaitFunction;
      // when waiting in foreground we have to process success/error here,
      // otherwise this is done in PostExecute()
    if(FWaitMethod = wmWaitInForeground) then
      PostExecute;
  end;
end;

function TExecutor.IsTrustedExecutableImage(const ImageFileName: string): Boolean;
var
  WinTrustFileInfo: WINTRUST_FILE_INFO;
  WinTrustData: WINTRUST_DATA;
  WinTrustAction: TGUID;
  ResultStatus: LongInt;
begin
    // https://learn.microsoft.com/en-us/windows/win32/api/wintrust/ns-wintrust-wintrust_file_info
  ZeroMemory(@WinTrustFileInfo, SizeOf(WINTRUST_FILE_INFO));
  WinTrustFileInfo.cbStruct := SizeOf(WINTRUST_FILE_INFO);
  WinTrustFileInfo.pcwszFilePath := PWideChar(ImageFileName);
  WinTrustFileInfo.hFile := 0;
  WinTrustFileInfo.pgKnownSubject := nil;

    // https://learn.microsoft.com/de-de/windows/win32/api/wintrust/ns-wintrust-wintrust_data
  ZeroMemory(@WinTrustData, SizeOf(WINTRUST_DATA));
  WinTrustData.cbStruct := SizeOf(WINTRUST_DATA);
  WinTrustData.pPolicyCallbackData := nil;
  WinTrustData.pSIPClientData := nil;
  WinTrustData.dwUIChoice := WTD_UI_NONE;
  WinTrustData.fdwRevocationChecks := WTD_REVOKE_NONE;
  WinTrustData.dwUnionChoice := WTD_CHOICE_FILE;
  WinTrustData.pFile := @WinTrustFileInfo;
  WinTrustData.dwStateAction := WTD_STATEACTION_VERIFY;
  WinTrustData.hWVTStateData := 0;
  WinTrustData.pwszURLReference := nil;
  WinTrustData.dwProvFlags := WTD_SAFER_FLAG;
  WinTrustData.dwUIContext := 0;

    // GUID of the action to be performed
  WinTrustAction := WINTRUST_ACTION_GENERIC_VERIFY_V2;

    // Call WinVerifyTrust to verify the digital signature
  ResultStatus := WinVerifyTrust(INVALID_HANDLE_VALUE, WinTrustAction, @WinTrustData);

    // Check the result
  Result := ResultStatus = ERROR_SUCCESS;

    // Clean up
  WinTrustData.dwStateAction := WTD_STATEACTION_CLOSE;
  WinVerifyTrust(0, WinTrustAction, @WinTrustData);
end;

procedure TExecutor.StartProcess(ShowWindow : Boolean);
begin
  FCreateProcess.SetShowWindow(ShowWindow);
  FLastWin32Error := FCreateProcess.CreateProcess;
end;

function TExecutor.WaitInForeground: Cardinal;
var Msg     : tagMsg;
    retcode : Cardinal; // return code of application
    Pid     : Cardinal;
begin
  try
    Pid := FCreateProcess.GetProcessId;
      // wait for process to get up and running
    WaitForInputIdle (Pid, INFINITE);

    repeat
      repeat
          // artificial message loop to keep application updated
        while PeekMessage(Msg, 0, 0, 0, PM_REMOVE) do begin
          TranslateMessage (Msg);
          DispatchMessage (Msg);
        end;
      until not FExitMonitor.ProcessExists;
//      until MsgWaitForMultipleObjects(1, Pid, False, INFINITE, QS_ALLINPUT) <> WAIT_OBJECT_0+1;
      GetExitCodeProcess (Pid, retcode);
    until retcode <> STILL_ACTIVE;
  finally
    CloseHandle(Pid);
  End;
  Result := retcode;
  FLastWin32Error := retcode;
end;

function TExecutor.WaitInBackground : Cardinal;
var Pid: Cardinal;
begin
  Pid := FCreateProcess.GetProcessId;

    // wait for process to get up and running
  WaitForInputIdle (Pid, INFINITE);

    // background thread waiting for process to finish
  FBackgroundThread := TThread.CreateAnonymousThread(
    procedure
    begin
      WaitForProcessExitBackground;
    end
  );
  FBackgroundThread.FreeOnTerminate := False;
  FBackgroundThread.Start;

  Result := GetLastError;
  FLastWin32Error := Result;
end;

  // Warning: background thread
procedure TExecutor.WaitForProcessExitBackground;
var retcode: Cardinal;
var Pid: Cardinal;
begin
  Pid := FCreateProcess.GetProcessId;

  repeat
    Sleep(250);
  until not FExitMonitor.ProcessExists;

  if not GetExitCodeProcess (Pid, retcode) then
    retcode := GetLastError();
  FLastWin32Error := retcode;

    // Calling PostExecute directly, however we're running in a separate thread.
    // The user has to take appropriate measures to report success or failure
    // to a GUI app and should not update the GUI directly
  PostExecute;
end;

procedure TExecutor.PostExecute;
begin
    // in case of console application we might see a 0xC000013a error
    // (application is terminated by Ctrl-C)
    // this is not an error
  try
    if(FLastWin32Error = ERROR_SUCCESS) or (FLastWin32Error = STATUS_CONTROL_C_EXIT) then
    begin
      if Assigned(FOnSuccessMethod) then
        FOnSuccessMethod;
    end
    else
    begin
      if Assigned(FOnErrorMethod) then
        FOnErrorMethod(FLastWin32Error);
    end;
  except
    on E: Exception do
      OutputDebugString(PChar('Exception in PostExecute: ' + E.Message));
  end;
end;


{ TCreateProcess }

function TCreateProcess.Error: Boolean;
begin
  Result := F_Pi.hProcess = 0;
end;

function TCreateProcess.GetAllowUnsafe: Boolean;
begin
  Result := FAllowUnsafe;
end;

function TCreateProcess.GetExecutable: string;
begin
  Result := FExecutable;
end;

function TCreateProcess.GetExecutableRootPath: string;
begin
  Result := FExecutableRootPath;
end;

function TCreateProcess.GetParameterString: string;
begin
  Result := FParameterString;
end;

function TCreateProcess.GetProcessId: Cardinal;
begin
  Result := F_Pi.hProcess;
end;

function TCreateProcess.GetShowWindow: Boolean;
begin
  Result := FShowWindow;
end;

procedure TCreateProcess.SetAllowUnsafe(const Value: Boolean);
begin
  FAllowUnsafe := Value;
end;

procedure TCreateProcess.SetExecutable(const Value: string);
begin
  FExecutable := Value;
end;

procedure TCreateProcess.SetExecutableRootPath(const Value: string);
begin
  FExecutableRootPath := Value;
end;

procedure TCreateProcess.SetParameterString(const Value: string);
begin
  FParameterString := Value;
end;

procedure TCreateProcess.SetShowWindow(const Value: Boolean);
begin
  FShowWindow := Value;
end;

function TCreateProcess.CreateProcess: Cardinal;
var info : TStartupInfo;
var LCreationFlags: DWORD;
begin
  Result := ERROR_SUCCESS;
  LCreationFlags := 0;

    // Startup info struct
  ZeroMemory(@info, SizeOf(TStartupInfo));
  info.cb := SizeOf (info);
  if GetShowWindow then
    info.wShowWindow := SW_SHOWNORMAL
  else
    info.wShowWindow := 0;

    // Process info struct
  ZeroMemory(@F_pi, SizeOf(TProcessInformation));

    // applications expect it's own executable as first parameter in a
    // command line
  var CommandLine := '"' + FExecutable + '" ' + FParameterString;

    // create the process
  if not Winapi.Windows.CreateProcess (
                PWideChar(FExecutable),         // lpApplicationName
                PWideChar(CommandLine),         // lpCommandLine
                nil,                            // lpProcessAttributes
                nil,                            // lpThreadAttributes
                True,                           // bInheritHandles
                LCreationFlags,                 // dwCreationFlags
                nil,                            // lpEnvironment
                PWideChar(FExecutableRootPath), // lpCurrentDirectory
                info,                           // lpStartupInfo
                F_pi) Then                      // lpProcessInformation
  begin
    Result := GetLastError;
  end;
end;

end.

