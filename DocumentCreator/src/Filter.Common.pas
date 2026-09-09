unit Filter.Common;

interface
uses
  DCTypes;

type
  Filter_xmlString = class(TInterfacedObject, IFilter)
    class function NewInstance: IFilter; static;
    function getName: String;
    function process(AString: String) : String;
  end;

  Filter_sanitize = class(TInterfacedObject, IFilter)
    class function NewInstance: IFilter; static;
    function getName: String;
    function process(AString: String) : String;
  private
  end;

implementation
uses
  DocumentCreator,
  System.SysUtils, // StringReplace
  System.NetEncoding; // TNetEncoding

{ Filter_xmlString }

class function Filter_xmlString.NewInstance: IFilter;
begin
  Result := Filter_xmlString.Create;
end;

function Filter_xmlString.getName: String;
begin
  Result := 'xmlString';
end;

function Filter_xmlString.process(AString: String): String;
begin
  Result := TNetEncoding.HTML.Encode(AString);
end;

{ Filter_sanitize }

class function Filter_sanitize.NewInstance: IFilter;
begin
  Result := Filter_sanitize.Create;
end;

function Filter_sanitize.getName: String;
begin
  Result := 'sanitize';
end;

function Filter_sanitize.process(AString: String): String;
begin
  Result := StringReplace(AString, 'Þ', '"', [rfReplaceAll]);
  Result := StringReplace(Result, '…', '...', [rfReplaceAll]);
  Result := StringReplace(Result, ' ...', '...', [rfReplaceAll]);
  Result := StringReplace(Result, '"', '&quot;', [rfReplaceAll]);
end;


// autoregister filters
initialization

  RegisterFilterFactory(Filter_xmlString.NewInstance);
  RegisterFilterFactory(Filter_sanitize.NewInstance);

end.
