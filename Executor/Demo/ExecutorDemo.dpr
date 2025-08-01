program ExecutorDemo;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  Executor in '..\src\Executor.pas',
  Executor.Interfaces in '..\src\Executor.Interfaces.pas',
  Executor.Monitor.ByProcessId in '..\src\Executor.Monitor.ByProcessId.pas',
  Executor.Monitor.ByProcessName in '..\src\Executor.Monitor.ByProcessName.pas',
  Executor.Monitor.ByProcessPath in '..\src\Executor.Monitor.ByProcessPath.pas';

procedure Main;
var LCreateProcess: ICreateProcess;
    LExitWaiter: IProcessExitWaiter;
    LExecutor: IExecutor;
begin
    // the CreateProcess identifies the image file to run
  LCreateProcess := TCreateProcess.Create;
  LCreateProcess.SetExecutable('C:\Windows\notepad.exe');
  LCreateProcess.SetExecutableRootPath('C:\Windows');
  LCreateProcess.SetParameterString('');

    // the ProcessExitWaiter is the mechanism to check for the app to end
  LExitWaiter := TProcessExitByName.Create;

  LExecutor := TExecutor.Create(LCreateProcess, LExitWaiter);

  { Running in foreground means that Execute() will not return until the app
    is considered closed by the ExitWaiter }

  WriteLn('Executing Notepad in foreground. Executor will return when Notepad is closed.');
  LExecutor.Execute(
    wmWaitInForeground, // Executor waits for Notepad to end
    True,  // show the app window
    procedure // callback for success
    begin
      WriteLn('Execution ended successfully.');
    end,
    procedure(const Win32Error: Cardinal) // callback for error
    begin
      WriteLn(Format('Execution ended with error %x', [Win32Error]));
    end,
    True); // Should we allow unsigned apps? For some reason Notepad.exe is unsigned

  WriteLn('Notepad has ended while we were waiting.');
  WriteLn('Now we fire a Notepad without waiting.');

  { Running in background means that Execute() will return immediately.
    Please note that the callback methods are running in a separate thread
    and you have to take appriopriate actions to report your success or
    failure to your app.
    If you have a GUI app you can use something like that for your success
    handler:

    procedure
    begin
      TThread.Queue(nil,
        procedure
        begin
          PostExecute;
        end);
    end;

    Only GUI apps have a message loop which TThread.Queue() relies on.
    Console apps do not have a message loop!
  }
  LExecutor.Execute(
    wmWaitInBackground,
    True,
    procedure // callback for success
    begin
      WriteLn('Execution in background ended successfully. You still have to press Return');
    end,
    procedure(const Win32Error: Cardinal) // callback for error
    begin
      WriteLn(Format('Execution ended with error %x', [Win32Error]));
    end,
    True); // Should we allow unsigned apps?

  WriteLn('Notepad is now running but the app continues. When you close Notepad the callback will be executed.');
  WriteLn('Press Return after closing Notepad');
  ReadLn;
end;

begin
  try
    Main;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
