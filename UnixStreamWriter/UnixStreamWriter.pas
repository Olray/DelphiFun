unit UnixStreamWriter;

interface
uses
  System.SysUtils,
  System.Classes;

type
  TUnixEncoding = class helper for TEncoding
  strict private
    class var
      FUTF8NoBOMEncoding: TEncoding;
    class function GetUTF8NoBOM: TEncoding; static;
  public
    class property UTF8NoBOM: TEncoding read GetUTF8NoBOM;
  end;

  TUnixStreamWriter = class(TStreamWriter)
  public
    constructor Create(Stream: TStream; Encoding: TEncoding; BufferSize: Integer = 4096); overload;
    constructor Create(const FileName: string; Append: Boolean; Encoding: TEncoding; BufferSize: Integer = 4096); overload;
  end;

implementation

type
  TUTF8EncodingNoBOM = class(TUTF8Encoding)
  public
    function GetPreamble: TBytes; override;
  end;

{
  UTF8 encoder without BOM (Byte Order Mark)
}

  // adapted from System.SysUtils.TEncoding
class function TUnixEncoding.GetUTF8NoBOM: TEncoding;
var
  LEncoding: TEncoding;
begin
  if FUTF8NoBOMEncoding = nil then
  begin
    LEncoding := TUTF8EncodingNoBOM.Create;
    if AtomicCmpExchange(Pointer(FUTF8NoBOMEncoding), Pointer(LEncoding), nil) <> nil then
      LEncoding.Free
{$IFDEF AUTOREFCOUNT}
    else
      FUTF8Encoding.__ObjAddRef
{$ENDIF AUTOREFCOUNT};
  end;
  Result := FUTF8NoBOMEncoding;
end;


{ TUnixStreamWriter
  ---
  change NewLine to #10
  - do not instantiiate with any other constructor
}

constructor TUnixStreamWriter.Create(Stream: TStream; Encoding: TEncoding;
  BufferSize: Integer);
begin
  inherited Create(Stream, Encoding, BufferSize);
  NewLine := #10;
end;

constructor TUnixStreamWriter.Create(const Filename: string; Append: Boolean;
  Encoding: TEncoding; BufferSize: Integer);
begin
  inherited Create(FileName, Append, Encoding, BufferSize);
  NewLine := #10;
end;

{ TUTF8EncodingNoBOM }

function TUTF8EncodingNoBOM.GetPreamble: TBytes;
begin
  Result := nil;
end;

end.
