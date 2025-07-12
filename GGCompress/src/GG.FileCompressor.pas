unit GG.FileCompressor;

interface
uses
  System.Classes; // TStream

type
  FileCompressor = class
    class procedure CompressFile(const FromFileName, ToFileName: string);
    class function CompressStream(FromStream: TStream): TStream;
    class procedure DecompressFile(const FromFileName, ToFileName: string);
    class function DecompressStream(FromStream: TStream): TStream;
  end;

implementation
uses
  System.SysUtils, // stream functions and constants
  System.ZLib; // compression/decompression streams

type
  IGGStream = interface
    ['{08F8584A-9DA7-4E33-819A-160F643C5FF1}']
    function OpenFileStream(const FileName: string): IGGStream;
    function SetExistingStream(AStream: TStream): IGGStream;
    function CompressStream: IGGStream;
    function DecompressStream: IGGStream;
    function SaveFileStream(const FileName: string): IGGStream;
    function DetachStream: TStream;
  end;

  TGGStream = class(TInterfacedObject, IGGStream)
  strict private
    FOriginalStreamPtr: Pointer;
    FOwnsStream: Boolean;
    FStream: TStream;
  public
    constructor Create;
    destructor Destroy; override;
      // IGGStream implementation
    function OpenFileStream(const FileName: string): IGGStream;
    function SetExistingStream(AStream: TStream): IGGStream;
    function CompressStream: IGGStream;
    function DecompressStream: IGGStream;
    function SaveFileStream(const FileName: string): IGGStream;
    function DetachStream: TStream;
  end;

function GGStreamFactory: IGGStream;
begin
  Result := TGGStream.Create;
end;

{ FileCompressor }

class procedure FileCompressor.CompressFile(const FromFileName, ToFileName: string);
begin
  GGStreamFactory
    .OpenFileStream(FromFileName)
    .CompressStream
    .SaveFileStream(ToFileName);
end;

class procedure FileCompressor.DecompressFile(const FromFileName, ToFileName: string);
begin
  GGStreamFactory
    .OpenFileStream(FromFileName)
    .DecompressStream
    .SaveFileStream(ToFileName);
end;

class function FileCompressor.CompressStream(FromStream: TStream): TStream;
begin
  Result := GGStreamFactory
    .SetExistingStream(FromStream)
    .CompressStream
    .DetachStream;
end;

class function FileCompressor.DecompressStream(FromStream: TStream): TStream;
begin
  Result := GGStreamFactory
    .SetExistingStream(FromStream)
    .DecompressStream
    .DetachStream;
end;

{ TGGStream }

constructor TGGStream.Create;
begin
  FOwnsStream := True;
end;

destructor TGGStream.Destroy;
begin
  if FOwnsStream and Assigned(FStream) then
    FreeAndNil(FStream);
  inherited;
end;

function TGGStream.OpenFileStream(const FileName: string): IGGStream;
begin
  if not FileExists(FileName) then
    raise EFileNotFoundException.CreateFmt('File %s not found', [FileName]);
  FStream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
  Result := Self;
end;

function TGGStream.SetExistingStream(AStream: TStream): IGGStream;
begin
  Assert(AStream <> nil);
  FOriginalStreamPtr := Pointer(AStream);
  if Assigned(FStream) then
    FStream.Free;
  FStream := AStream;
  FOwnsStream := False;
  Result := Self;
end;

function TGGStream.CompressStream: IGGStream;
var
  LOutput: TMemoryStream;
  LZip: TZCompressionStream;
begin
  LOutput := TMemoryStream.Create;
  LZip := TZCompressionStream.Create(clDefault, LOutput);
    // Compress data
  LZip.CopyFrom(FStream, FStream.Size);
  LZip.Free;
    // Replace FStream
  if FOwnsStream then
    if FOriginalStreamPtr <> Pointer(FStream) then
      FStream.Free;
  FStream := LOutput;

  Result := Self;
end;

function TGGStream.DecompressStream: IGGStream;
var
  LOutput: TMemoryStream;
  LUnZip: TZDecompressionStream;
begin
  LOutput := TMemoryStream.Create;
  LUnZip := TZDecompressionStream.Create(FStream);
    // Decompress data
  LOutput.CopyFrom(LUnZip, 0);
  LUnZip.Free;
    // Replace FStream
  if FOwnsStream then
    if FOriginalStreamPtr <> Pointer(FStream) then
      FStream.Free;
  FStream := LOutput;

  Result := Self;
end;

function TGGStream.SaveFileStream(const FileName: string): IGGStream;
var FileStream: TFileStream;
begin
  if FileExists(FileName) then
    System.SysUtils.DeleteFile(FileName);
  FileStream := TFileStream.Create(FileName, fmOpenWrite or fmCreate or fmShareExclusive);
  try
    FileStream.CopyFrom(FStream);
  finally
    FileStream.Free;
  end;
  Result := Self;
end;

function TGGStream.DetachStream: TStream;
begin
  FOwnsStream := False;
    // fast rewind
  FStream.Seek(0, soFromBeginning);
  Result := FStream;
end;


end.
