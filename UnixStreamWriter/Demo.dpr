program Demo;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  UnixStreamWriter in 'UnixStreamWriter.pas';

var
  Writer: TUnixStreamWriter;
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
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
