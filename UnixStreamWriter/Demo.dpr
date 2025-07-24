program Demo;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.Classes,
  System.IniFiles,
  UnixStreamWriter in 'UnixStreamWriter.pas';

var
  Writer: TStreamWriter;
  IniFile: TMemIniFile;
begin
  try
      // TUnixStreamWriter modifies the line break from sLineBreak to #10
      // while TEncoding.UTF8NoBOM is an encoder with an empty BOM
    Writer := TUnixStreamWriter.Create(
        'testfile utf8 with unix line breaks and without BOM.txt',
        False,                                                     // do not append text
        TEncoding.UTF8NoBOM                                        // use encoder without BOM
    );
    Writer.WriteLine('This is a UTF8 text file');
    Writer.WriteLine('without BOM and');
    Writer.WriteLine('with Unix line breaks');
    Writer.Free;

      // from https://en.delphipraxis.net/topic/2476-skipping-the-utf-8-bom-with-tmeminifile-in-delphi-2007/
      // test if TMemIniFile can read BOM-less ini files

      // write some ini file (no BOM, windows line breaks, e.g. Visual Studio Code)
    Writer := TStreamWriter.Create(
        'test.ini',
        False,
        TEncoding.UTF8NoBOM);
    Writer.WriteLine('[Values]');
    Writer.WriteLine('Value=some German umlauts: öäüß');
    Writer.Free;

      // read into TIniFile
    IniFile := TMemIniFile.Create('test.ini', TEncoding.UTF8);
    var StringValue := IniFile.ReadString('Values', 'Value', '');
    if(StringValue <> 'some German umlauts: öäüß') then
      raise Exception.Create('TMemIniFile unexpectedly didn''t read the BOM-less file as utf8');
      // yes it can
    IniFile.Free;

  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
