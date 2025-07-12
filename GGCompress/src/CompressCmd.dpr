program CompressCmd;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.Generics.Collections,
  GG.FileCompressor in 'GG.FileCompressor.pas',
  GG.FileEnumerator in 'GG.FileEnumerator.pas',
  GG.MOCompressor in 'GG.MOCompressor.pas';

procedure CheckParameters;
begin
  if(ParamCount < 1) then
  begin
    WriteLn('Usage: CompressCmd <SourceDirectory>');
    Halt(1);
  end;
  if not DirectoryExists(ParamStr(1)) then
  begin
    WriteLn('Directory passed as first parameter does not exist');
    Halt(1);
  end;
end;

var
  Compressor: IMOCompressor;
  ThisDir: string;
begin
  try
    CheckParameters;
    GetDir(0, ThisDir);
    ChDir(ParamStr(1));
    try
      Compressor := GetCompressor;
      Compressor.AddDirectory('.', '*.mo');
      Compressor.Compress;
    finally
      ChDir(ThisDir);
    end;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
