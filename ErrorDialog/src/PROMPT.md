# Delphi Error Dialog Library - Development Prompt

## Project Overview

You are developing a sophisticated Delphi library to replace the plain MessageBox() and MessageDlg() functions with a premium, feature-rich error dialog system. The library must be extremely easy to use while providing extensive customization capabilities.

## Core Requirements

### 1. **Ease of Use**
- Single unit import (`ErrorDialog.Core`)
- One-line usage capability (MessageBox replacement)
- Zero configuration required - works with sensible defaults
- Progressive enhancement (simple for basic needs, rich API for advanced scenarios)

### 2. **Visual Features**
- VCL-only GUI environment
- Unique and premium visual appearance
- Application icon extraction from executable (with Windows fallback icons)
- Support for standard Windows icons (ICON_EXCLAMATION, ICON_STOP, etc.)
- Configurable window title
- Modal dialog with proper return values

### 3. **Content Features**
- Markdown text formatting (**bold**, __italic__, line break with "\n")
- Multi-line message support
- Configurable button sets (OK, Cancel, Retry, Abort, Yes, No)
- Expandable extra information section

### 4. **Dynamic Information System**
- Modular `IInfoProvider` interfaces for runtime data calculation
- Support for arrays of info providers: `SetExtraInfo([Provider1, Provider2, ...])`
- Built-in providers: Version, Memory Usage, System Info, Timestamp, Exception Details
- Factory methods for memory-safe provider creation
- Custom provider extensibility
- Tabular display format: "Key: Value" pairs
- **Memory Management**: All providers are interfaced to prevent memory leaks

## Architecture Design

### **Design Patterns Used**
- **Builder Pattern**: Fluent API with method chaining
- **Strategy Pattern**: Pluggable renderers, themes, and icon providers
- **Factory Pattern**: Info provider combinations and defaults
- **Singleton Pattern**: Global configuration management

### **Core Interfaces**

```pascal
IErrorDialog = interface
  function SetTitle(const ATitle: string): IErrorDialog;
  function SetMessage(const AMessage: string): IErrorDialog;
  function SetIcon(AIcon: TErrorIcon): IErrorDialog;
  function SetButtons(AButtons: TErrorButtons): IErrorDialog;
  function SetExtraInfo(const AProviders: array of IInfoProvider): IErrorDialog;
  function ShowModal: TModalResult;
end;

IInfoProvider = interface
  function GetInfo: TPair<string, string>;
  function GetDisplayName: string;
  function IsAvailable: Boolean;
end;

// Factory interface for creating info providers
IInfoProviderFactory = interface
  function CreateVersionInfo: IInfoProvider;
  function CreateMemoryUsage: IInfoProvider;
  function CreateSystemInfo: IInfoProvider;
  function CreateTimestamp: IInfoProvider;
  function CreateExceptionInfo(AException: Exception): IInfoProvider;
end;
```

### **File Structure**
```
ErrorDialog/src/
├── ErrorDialog.Core.pas          // Main interface unit (single import)
├── ErrorDialog.Types.pas         // Types, enums, records
├── ErrorDialog.Builder.pas       // Fluent builder implementation
├── ErrorDialog.Form.pas          // Custom form implementation
├── ErrorDialog.Renderer.pas      // Markdown renderer interface
├── ErrorDialog.IconProvider.pas  // Icon extraction/management
├── ErrorDialog.InfoProviders.pas // Built-in info provider classes
├── ErrorDialog.Config.pas        // Global configuration
└── ErrorDialog.Utils.pas         // Utility functions
```

## Usage Examples

### **Simple One-Liner (MessageBox Replacement)**
```pascal
uses ErrorDialog.Core;

// Basic usage
ErrorDialog.Show('Database connection failed!');

// With return value
if ErrorDialog.Show('Save changes?', 'Confirmation', edYesNo) = mrYes then
  SaveDocument;
```

### **Advanced Fluent API**
```pascal
uses ErrorDialog.Core, ErrorDialog.InfoProviders;

ErrorDialog.New
  .SetTitle('Application Error')
  .SetMessage('**Critical Error:** Unable to connect to database.\n\nPlease check your __network connection__ and try again.')
  .SetIcon(eiError)
  .SetButtons(ebRetryCancel)
  .SetExtraInfo([
    InfoProviders.VersionInfo,
    InfoProviders.MemoryUsage,
    InfoProviders.SystemInfo
  ])
  .ShowModal;
```

### **Exception Handling Context**
```pascal
try
  // Risky operation
except
  on E: Exception do
    ErrorDialog.New
      .SetMessage('Operation failed: ' + E.Message)
      .SetExtraInfo([
        InfoProviders.ExceptionInfo(E),
        InfoProviders.VersionInfo,
        InfoProviders.MemoryUsage
      ])
      .ShowModal;
end;
```

## Key Type Definitions

```pascal
TErrorIcon = (eiNone, eiInformation, eiWarning, eiError, eiQuestion, eiApplication);
TErrorButtons = (ebOK, ebOKCancel, ebYesNo, ebYesNoCancel, ebRetryCancel, ebAbortRetryIgnore);

// Global factory instance for creating info providers
InfoProviders: IInfoProviderFactory;
```

## Built-in Info Providers (Factory Methods)

Accessed through the global `InfoProviders` factory instance:

1. **InfoProviders.VersionInfo** - Executable version information
2. **InfoProviders.MemoryUsage** - Current memory usage  
3. **InfoProviders.SystemInfo** - System information
4. **InfoProviders.Timestamp** - Current timestamp
5. **InfoProviders.ExceptionInfo(E)** - Exception details (class, message, stack trace)

### **Factory Implementation Structure**
```pascal
// Internal implementation classes (not exposed to users)
TVersionInfoProvider = class(TInterfacedObject, IInfoProvider)
TMemoryUsageInfoProvider = class(TInterfacedObject, IInfoProvider)
TSystemInfoProvider = class(TInterfacedObject, IInfoProvider)
TTimestampInfoProvider = class(TInterfacedObject, IInfoProvider)
TExceptionInfoProvider = class(TInterfacedObject, IInfoProvider)

// Factory implementation
TInfoProviderFactory = class(TInterfacedObject, IInfoProviderFactory)
  function CreateVersionInfo: IInfoProvider;
  function CreateMemoryUsage: IInfoProvider;
  function CreateSystemInfo: IInfoProvider;
  function CreateTimestamp: IInfoProvider;
  function CreateExceptionInfo(AException: Exception): IInfoProvider;
end;

// Convenience properties for easy access
property VersionInfo: IInfoProvider read CreateVersionInfo;
property MemoryUsage: IInfoProvider read CreateMemoryUsage;
property SystemInfo: IInfoProvider read CreateSystemInfo;
property Timestamp: IInfoProvider read CreateTimestamp;
function ExceptionInfo(AException: Exception): IInfoProvider;
```

## Development Guidelines

### **Code Quality**
- Use interfaces for extensibility and memory safety
- Implement proper memory management (no manual object cleanup required)
- Thread-safe design
- Comprehensive error handling
- Unit testable components

### **Memory Management**
- **Zero Memory Leaks**: Factory methods return interfaces that auto-manage lifetime
- **No Manual Cleanup**: Users never call `Create`/`Free` on info providers
- **Reference Counting**: Automatic cleanup when interfaces go out of scope
- **Safe Array Usage**: `SetExtraInfo([InfoProviders.A, InfoProviders.B])` is completely safe

### **Visual Design**
- Modern, professional appearance
- Consistent with Windows design guidelines
- Scalable for different DPI settings
- Accessible color schemes
- Smooth animations (optional)

### **Performance**
- Lazy initialization
- Icon caching
- Efficient markdown parsing
- Minimal resource usage
- Fast dialog display

## Implementation Phases

1. **Phase 1**: Core functionality and basic styling
2. **Phase 2**: Markdown rendering and icon extraction  
3. **Phase 3**: Info provider system and advanced features
4. **Phase 4**: Theme system and performance optimization

## Current Status

**✅ Architecture Designed** - Complete interface and class structure defined
**⏳ Implementation Pending** - Ready to begin coding core components

---

*Use this prompt to maintain context across development sessions. Focus on the builder pattern implementation, info provider system, and maintaining the "one-line usage" simplicity while providing advanced features through the fluent API.*