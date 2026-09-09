unit DocumentCreator;

interface

Uses
  System.Classes, // TStringList
  System.Types, // TStringDynArray
  System.StrUtils, // PosEx
  System.SysUtils, // Trim
  System.Generics.Collections,
  DCTypes,
  DCUtilities;

const
  LeftPlaceholder = '{{';
  RightPlaceholder = '}}';

type
  TFilterFactory = reference to function: IFilter;
var
  FilterRegistry: TArray<TFilterFactory> = nil;

type
  TValueProviderType = (odt, html);


  TDocumentCreator = class(TInterfacedObject, IFilterRegistration)
  private
    FDocumentTemplate : String;
    FWorkingCopy : String;
    FResolverList: TArray<IResolver>;
    FUnresolved : TSet<string>;
    FFilters: TArray<IFilter>;

    function ExtractPlaceholders : TSet<string>;
    function Resolve(Placeholder : string) : string;
    function RemoveDelimiters(key : string) : string;
    procedure ApplyFilters(var Response : TResolveResponse; filterList: array of string);
    procedure AutoRegisterFilters;
  public
    Constructor Create; overload;
    Constructor Create(TemplateString : String); overload;
    Destructor Destroy; override;

    procedure AddResolver(AResolver: IResolver);
    procedure AddFilter(AFilter: IFilter);

    function asString : string;
    procedure ReportMissingPlaceholders;
    procedure WriteToFile(FileName : string);
    function Success : Boolean;
    function GetUnresolved: TArray<string>;
  end;

procedure ApplyProviderTo(Resolver: IResolver; objects : array of const);

procedure RegisterFilterFactory(const F: TFilterFactory);

implementation
uses
  System.Rtti,
  System.TypInfo,
  System.IOUtils,
  System.NetEncoding;

type
  UnresolvedException = class(Exception)
  end;

{ Utilities }

  // apply a resolver to multiple DocumentCreators
procedure ApplyProviderTo(Resolver : IResolver; objects : array of const);
var i : Integer;
var obj : TDocumentCreator;
begin
  try
    for i := Low(objects) to High(objects) do
    begin
      obj := objects[i].VObject as TDocumentCreator;
      obj.AddResolver(Resolver);
    end;
  except
    WriteLn('Error applying TValueProvider to multiple DocumentCreators');
    WriteLn('Press ENTER...');
    ReadLn;
    raise;
  end;
end;

{ TDocumentCreator }

constructor TDocumentCreator.Create;
begin
  FDocumentTemplate := '';
  FWorkingCopy := '';
  FUnresolved := TSet<string>.Create;
  SetLength(FResolverList, 0);
    // register filter(s)
  AutoRegisterFilters;
end;

constructor TDocumentCreator.Create(TemplateString: string);
begin
  Create;
  SetLength(FResolverList, 0);
  FDocumentTemplate := TemplateString;
end;

destructor TDocumentCreator.Destroy;
begin
  if Assigned(FUnresolved) then
    FUnresolved.Free;

  inherited;
end;

procedure TDocumentCreator.AddResolver(AResolver: IResolver);
begin
  SetLength(FResolverList, Length(FResolverList)+1);
  FResolverList[High(FResolverList)] := AResolver;
end;

function TDocumentCreator.ExtractPlaceholders : TSet<string>;
var
  StartPos, EndPos: Integer;
  Placeholder: string;
  Remaining : TSet<string>;
  s_len, e_len : Integer;
begin
  Remaining := TSet<string>.Create;
  if(FWorkingCopy = '') then
    exit(Remaining);

  s_len := Length(LeftPlaceholder);
  e_len := Length(RightPlaceholder);

  StartPos := 1;
  while True do
  begin
    StartPos := PosEx(LeftPlaceholder, FWorkingCopy, StartPos);
    if StartPos = 0 then
      Break;

    EndPos := PosEx(RightPlaceholder, FWorkingCopy, StartPos + s_len);
    if EndPos = 0 then
      Break;

    Placeholder := Trim(Copy(FWorkingCopy, StartPos, EndPos - StartPos + e_len));
    Remaining.add(Placeholder);

    StartPos := EndPos + e_len;
  end;

  Result := Remaining;
end;

procedure TDocumentCreator.ApplyFilters(var Response : TResolveResponse; filterList: array of string);

  function FindFilter(const name : string): IFilter;
  begin
    for var i := Low(FFilters) to High(FFilters) do
      if(FFilters[i].getName = name) then
        Exit(FFilters[i]);
    Result := nil;
  end;

var filter : IFilter;
begin
  if(Length(FFilters) > 0) and (Length(filterList) > 0) then
  begin
    for var i := Low(filterList) to High(filterList) do
    begin
      filter := FindFilter(filterList[i]);
      if(filter <> nil) then
        Response := filter.process(Response.value)
      else
        Response := Response.value + Format('|???%s???', [filterList[i]]);
    end;
  end;
end;

function TDocumentCreator.Resolve(Placeholder: String): String;
var i : Integer;
var Resolver : IResolver;
var Response : TResolveResponse;
var items: TArray<String>;
var filters: TArray<String>;
begin
    // find if any filters are added
  items := Placeholder.Split(['|']);
  if(Length(items) > 1) then
  begin
    SetLength(filters, Length(items)-1);
    for i := 1 to High(items) do
      filters[i-1] := items[i];
  end;
  Placeholder := items[0];
  Response := nil;

    // iterate Resolvers until the variable is replaced
  for i := High(FResolverList) downto Low(FResolverList) do
  begin
    Resolver := FResolverList[i];
    Response := Resolver.Resolve(Placeholder);

    if(Response <> nil) then
      break;
  end;

  if(Response = nil) then
  begin
    FUnresolved.add(Placeholder);
    Response := '???' + Placeholder + '???';
    filters := [];
  end;

  ApplyFilters(Response, filters);
  if Response = nil then
    Result := Placeholder
  else
    Result := Response.value;
end;

procedure TDocumentCreator.AddFilter(AFilter: IFilter);
begin
  SetLength(FFilters, Length(FFilters)+1);
  FFilters[High(FFilters)] := AFilter;
end;

function TDocumentCreator.RemoveDelimiters(key : String) : String;
begin
  Result := Copy(key, Length(LeftPlaceholder)+1, Length(key) - Length(LeftPlaceholder) - Length(RightPlaceholder));
end;

  // attempt to resolve all placeholders
function TDocumentCreator.asString : String;
VAR KeysToResolve : TSet<string>;
VAR placeholder : String;
var replace_s : String;
begin
  FWorkingCopy := FDocumentTemplate;
  FUnresolved.Clear;

  KeysToResolve := ExtractPlaceholders;

  for var item in KeysToResolve do
  begin
    placeholder := Trim(RemoveDelimiters(item));

    replace_s := Resolve(placeholder);

    FWorkingCopy := StringReplace(FWorkingCopy, item, replace_s, [rfReplaceAll]);
  end;

  KeysToResolve.Free;

  Result := FWorkingCopy;
end;

procedure TDocumentCreator.AutoRegisterFilters;
var
  func: TFilterFactory;
begin
  for func in FilterRegistry do
    AddFilter(func());
end;

procedure TDocumentCreator.WriteToFile(FileName: String);
begin
  TFile.WriteAllText(FileName, asString);
end;

function TDocumentCreator.Success: Boolean;
begin
  Result := FUnresolved.Count = 0;
end;

function TDocumentCreator.GetUnresolved: TArray<string>;
begin
  Result := FUnresolved.ToArray;
end;

procedure TDocumentCreator.ReportMissingPlaceholders;
begin
  if FUnresolved.Count > 0 then
  begin
    WriteLn;
    WriteLn('The following placeholders did not resolve to values:');
    WriteLn('=====================================================');
    WriteLn;
    for var item in FUnresolved do
      WriteLn('  ' + item);
    WriteLn;
    WriteLn('=====================================================');
    WriteLn('ENTER zum fortfahren...');
    ReadLn;
  end;
end;

{ Filter Autoregistration }

procedure RegisterFilterFactory(const F: TFilterFactory);
begin
  if FilterRegistry = nil then
    SetLength(FilterRegistry, 1)
  else
    SetLength(FilterRegistry, Length(FilterRegistry)+1);
  FilterRegistry[High(FilterRegistry)] := F;
end;


end.
