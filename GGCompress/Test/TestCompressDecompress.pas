unit TestCompressDecompress;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TTestCompressDecompress = class
  private
    const
      FileNames: array[0..2] of string = ('testfile', 'testfile.compressed', 'testfile.uncompressed');
      TestStrings: array[0..1] of string = ('This is a test file with data', 'for compression and decompression');
    procedure CreateTestFile;
    procedure CleanupTestFiles;
  public
    [Test]
    procedure TestCompressDecompress;
    [Test]
    procedure TestCompressDecompressStream;
  end;

implementation
uses
  System.SysUtils,
  System.Classes,
  GG.FileCompressor;

{ TTestCompressDecompress }

procedure TTestCompressDecompress.CreateTestFile;
var
  FileWriter: TStreamWriter;
begin
  FileWriter := TStreamWriter.Create(FileNames[0]);
  FileWriter.WriteLine(TestStrings[0]);
  FileWriter.WriteLine(TestStrings[1]);
  FileWriter.Flush;
  FileWriter.Free;
end;

procedure TTestCompressDecompress.CleanupTestFiles;
begin
  for var i := 0 to 2 do
    if FileExists(FileNames[i]) then
      System.SysUtils.DeleteFile(FileNames[i]);
end;


procedure TTestCompressDecompress.TestCompressDecompress;
var
  FileReader: TStreamReader;
  BufS: string;
begin
  try
    CreateTestFile;
    FileCompressor.CompressFile(FileNames[0], FileNames[1]);
    FileCompressor.DecompressFile(FileNames[1], FileNames[2]);

    FileReader := TStreamReader.Create(FileNames[2]);
    BufS := FileReader.ReadLine;
    Assert.AreEqual(TestStrings[0], BufS);
    BufS := FileReader.ReadLine;
    Assert.AreEqual(TestStrings[1], BufS);
    FileReader.Free;

  finally
    CleanupTestFiles;
  end;
end;

procedure TTestCompressDecompress.TestCompressDecompressStream;
var
  FileReader: TStreamReader;
  BaseStream: TMemoryStream;
  FileStream: TFileStream;
  CompressedStream: TStream;
  UncompressedStream: TStream;
  BufS: string;
begin
  try
    CreateTestFile;
    FileStream := TFileStream.Create(FileNames[0], fmOpenRead or fmShareDenyNone);
    try
      var oSize := FileStream.Size;

      CompressedStream := FileCompressor.CompressStream(FileStream);
      try
        UncompressedStream := FileCompressor.DecompressStream(CompressedStream);
      finally
        CompressedStream.Free;
      end;
      var uSize := UncompressedStream.Size;
      Assert.AreEqual(oSize, uSize);

      FileReader := TStreamReader.Create(UncompressedStream);
      try
        BufS := FileReader.ReadLine;
        Assert.AreEqual(TestStrings[0], BufS);
        BufS := FileReader.ReadLine;
        Assert.AreEqual(TestStrings[1], BufS);
      finally
        FileReader.Free;
      end;
    finally
      FileStream.Free;
    end;

  finally
    UncompressedStream.Free;
    CleanupTestFiles;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestCompressDecompress);

end.
