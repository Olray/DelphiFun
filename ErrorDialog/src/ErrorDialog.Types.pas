unit ErrorDialog.Types;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  Vcl.Controls;

type
  // Icon types for error dialogs
  TErrorIcon = (
    eiNone,
    eiInformation,
    eiWarning,
    eiError,
    eiQuestion,
    eiApplication
  );

  // Button combinations for error dialogs
  TErrorButtons = (
    ebOK,
    ebOKCancel,
    ebYesNo,
    ebYesNoCancel,
    ebRetryCancel,
    ebAbortRetryIgnore
  );

  // Forward declarations
  IInfoProvider = interface;

  // Configuration record for error dialog
  TErrorDialogConfig = record
    Title: string;
    Message: string;
    Icon: TErrorIcon;
    Buttons: TErrorButtons;
    InfoProviders: TArray<IInfoProvider>;
    ShowExtraButton: Boolean;
    Theme: string;
  end;

  // Interface for providing dynamic information
  IInfoProvider = interface
    ['{B8E1A4F2-3C5D-4E7F-9A1B-2C3D4E5F6A7B}']
    function GetInfo: TPair<string, string>;
    function GetDisplayName: string;
    function IsAvailable: Boolean;
  end;

  // Factory interface for creating info providers
  IInfoProviderFactory = interface
    ['{C9F2B5E3-4D6E-5F8A-0B2C-3D4E5F6A7B8C}']
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
    
    property VersionInfo: IInfoProvider read GetVersionInfo;
    property MemoryUsage: IInfoProvider read GetMemoryUsage;
    property SystemInfo: IInfoProvider read GetSystemInfo;
    property Timestamp: IInfoProvider read GetTimestamp;
  end;

  // Main error dialog interface
  IErrorDialog = interface
    ['{A1D3E5F7-2B4C-6E8A-9F1B-3C5D7E9F1A3B}']
    function SetTitle(const ATitle: string): IErrorDialog;
    function SetMessage(const AMessage: string): IErrorDialog;
    function SetIcon(AIcon: TErrorIcon): IErrorDialog;
    function SetButtons(AButtons: TErrorButtons): IErrorDialog;
    function SetExtraInfo(const AProviders: array of IInfoProvider): IErrorDialog; overload;
    function SetExtraInfo(const AProvider: IInfoProvider): IErrorDialog; overload;
    function AddExtraInfo(const AProvider: IInfoProvider): IErrorDialog;
    function ClearExtraInfo: IErrorDialog;
    function DisableDefaultProviders: IErrorDialog;
    function ShowModal: TModalResult;
  end;

implementation

end.