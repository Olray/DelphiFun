unit GG.MOCompressor;

interface

type
  IMOCompressor = interface
    procedure AddDirectory(const Directory, FileMask: string);
    procedure Compress;
  end;

function GetCompressor: IMOCompressor;

implementation
uses
  System.SysUtils,
  GG.FileEnumerator,
  GG.FileCompressor;

type
  TMOCompressor = class(TInterfacedObject, IMOCompressor)
  strict private
    FileList: TFileEnumerator;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddDirectory(const Directory, FileMask: string);
    procedure Compress;
  end;

function GetCompressor: IMOCompressor;
begin
  Result := TMOCompressor.Create;
end;

{ TMOCompressor }

constructor TMOCompressor.Create;
begin
  FileList := TFileEnumerator.Create;
end;

destructor TMOCompressor.Destroy;
begin
  FileList.Free;
  inherited;
end;

procedure TMOCompressor.AddDirectory(const Directory, FileMask: string);
begin
  FileList.FindFiles(FileMask);
end;

procedure TMOCompressor.Compress;
var
  FileName: string;
begin
  for FileName in FileList do
  begin
    var NewFileName := FileName + '.compressed';
    FileCompressor.CompressFile(FileName, NewFileName);
    WriteLn(Format('Compressed %s to %s', [FileName, NewFileName]));
  end;
end;

end.
