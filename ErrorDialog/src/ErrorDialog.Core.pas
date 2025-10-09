unit ErrorDialog.Core;

interface

uses
  System.SysUtils,
  Vcl.Dialogs,
  Vcl.Controls,
  ErrorDialog.Types,
  ErrorDialog.Builder,
  ErrorDialog.InfoProviders;

type
  // Static class for simple usage patterns
  TErrorDialog = class
  public
    // Simple MessageBox replacement methods
    class function Show(const AMessage: string): TModalResult; overload;
    class function Show(const AMessage, ATitle: string): TModalResult; overload;
    class function Show(const AMessage, ATitle: string; AIcon: TErrorIcon): TModalResult; overload;
    class function Show(const AMessage, ATitle: string; AButtons: TErrorButtons): TModalResult; overload;
    class function Show(const AMessage, ATitle: string; AIcon: TErrorIcon; AButtons: TErrorButtons): TModalResult; overload;
    
    // Builder pattern entry point
    class function New: IErrorDialog;
    
    // Quick access to common dialogs
    class function Error(const AMessage: string; const ATitle: string = 'Error'): TModalResult;
    class function Warning(const AMessage: string; const ATitle: string = 'Warning'): TModalResult;
    class function Information(const AMessage: string; const ATitle: string = 'Information'): TModalResult;
    class function Question(const AMessage: string; const ATitle: string = 'Question'): TModalResult;
    class function Confirmation(const AMessage: string; const ATitle: string = 'Confirmation'): TModalResult;
  end;

// Global convenience reference to InfoProviders factory
var
  InfoProviders: IInfoProviderFactory;

implementation

{ TErrorDialog }

class function TErrorDialog.Show(const AMessage: string): TModalResult;
begin
  Result := New
    .SetMessage(AMessage)
    .ShowModal;
end;

class function TErrorDialog.Show(const AMessage, ATitle: string): TModalResult;
begin
  Result := New
    .SetTitle(ATitle)
    .SetMessage(AMessage)
    .ShowModal;
end;

class function TErrorDialog.Show(const AMessage, ATitle: string; AIcon: TErrorIcon): TModalResult;
begin
  Result := New
    .SetTitle(ATitle)
    .SetMessage(AMessage)
    .SetIcon(AIcon)
    .ShowModal;
end;

class function TErrorDialog.Show(const AMessage, ATitle: string; AButtons: TErrorButtons): TModalResult;
begin
  Result := New
    .SetTitle(ATitle)
    .SetMessage(AMessage)
    .SetButtons(AButtons)
    .ShowModal;
end;

class function TErrorDialog.Show(const AMessage, ATitle: string; AIcon: TErrorIcon; AButtons: TErrorButtons): TModalResult;
begin
  Result := New
    .SetTitle(ATitle)
    .SetMessage(AMessage)
    .SetIcon(AIcon)
    .SetButtons(AButtons)
    .ShowModal;
end;

class function TErrorDialog.New: IErrorDialog;
begin
  Result := TErrorDialogBuilder.Create;
end;

class function TErrorDialog.Error(const AMessage: string; const ATitle: string): TModalResult;
begin
  Result := New
    .SetTitle(ATitle)
    .SetMessage(AMessage)
    .SetIcon(eiError)
    .SetButtons(ebOK)
    .ShowModal;
end;

class function TErrorDialog.Warning(const AMessage: string; const ATitle: string): TModalResult;
begin
  Result := New
    .SetTitle(ATitle)
    .SetMessage(AMessage)
    .SetIcon(eiWarning)
    .SetButtons(ebOK)
    .ShowModal;
end;

class function TErrorDialog.Information(const AMessage: string; const ATitle: string): TModalResult;
begin
  Result := New
    .SetTitle(ATitle)
    .SetMessage(AMessage)
    .SetIcon(eiInformation)
    .SetButtons(ebOK)
    .ShowModal;
end;

class function TErrorDialog.Question(const AMessage: string; const ATitle: string): TModalResult;
begin
  Result := New
    .SetTitle(ATitle)
    .SetMessage(AMessage)
    .SetIcon(eiQuestion)
    .SetButtons(ebYesNo)
    .ShowModal;
end;

class function TErrorDialog.Confirmation(const AMessage: string; const ATitle: string): TModalResult;
begin
  Result := New
    .SetTitle(ATitle)
    .SetMessage(AMessage)
    .SetIcon(eiQuestion)
    .SetButtons(ebYesNoCancel)
    .ShowModal;
end;

initialization
  // Initialize global InfoProviders factory
  InfoProviders := ErrorDialog.InfoProviders.InfoProviders;

end.