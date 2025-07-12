unit GG.FileEnumerator;

interface
uses
  System.SysUtils,
  System.Generics.Collections;

type
  TFileEnumerator = class
  strict private
    FFileList: TList<string>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure FindFiles(FileMask: string);
    function GetEnumerator: TEnumerator<string>;
  end;

implementation
uses
  System.Types, // TStringDynArray
  System.IOUtils; // TDirectory

{ TFileEnumerator }

constructor TFileEnumerator.Create;
begin
  FFileList := TList<string>.Create;
end;

destructor TFileEnumerator.Destroy;
begin
  FFileList.Free;
  inherited;
end;

procedure TFileEnumerator.FindFiles(FileMask: string);
var
  Files: TStringDynArray;
begin
  Files := TDirectory.GetFiles('.', FileMask, TSearchOption.soAllDirectories);
  FFileList.AddRange(Files);
end;

function TFileEnumerator.GetEnumerator: TEnumerator<string>;
begin
  Result := FFileList.GetEnumerator;
end;

end.
