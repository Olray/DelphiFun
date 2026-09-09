unit MainTest;

interface

uses
  DUnitX.TestFramework,
  DocumentCreator,
  DCTypes;

type
  Filter_stars = class(TInterfacedObject, IFilter)
    class function NewInstance: IFilter; static;
    function getName: String;
    function process(AString: String) : String;
  end;

  Filter_manual = class(TInterfacedObject, IFilter)
    class function NewInstance: IFilter; static;
    function getName: String;
    function process(AString: String) : String;
  end;

  [TestFixture]
  TDocumentCreatorTest = class
  private
    function DemoResolverFunc(const key: string): TResolveResponse;
  public

    [Test]
    procedure TestSingleResolver;
    [Test]
    procedure TestMultipleResolver;
    [Test]
    procedure TestProcResolver;
    [Test]
    procedure TestMultipleReplacements;
    [Test]
    procedure TestInvalidKeyReplacement;
    [Test]
    procedure TestLastResolverWinning;
    [Test]
    procedure TestCustomFilter;
    [Test]
    procedure TestFilterManualRegistration;
    [Test]
    procedure TestNonExistingFilterError;
  end;

implementation
uses
  Resolver.Single,
  Resolver.Multiple,
  Resolver.Func;


function TDocumentCreatorTest.DemoResolverFunc(const key: string): TResolveResponse;
begin
  Result := nil;
  if(key = 'key1') then
    Result := 'value1'
  else if (key = 'key2') then
    Result := 'value2';
  { ... and so on ... }
end;

procedure TDocumentCreatorTest.TestSingleResolver;
var
  Document: TDocumentCreator;
begin
  Document := TDocumentCreator.Create('Test {{ value }} Test');
  try
    Document.AddResolver(
      Resolver_Single.Create('value', 'is working')
    );
    Assert.AreEqual('Test is working Test', Document.asString);
  finally
    Document.Free;
  end;
end;

procedure TDocumentCreatorTest.TestMultipleResolver;
var
  Document: TDocumentCreator;
begin
  Document := TDocumentCreator.Create('Test {{ value1}} {{ value2}} Test');
  try
    Document.AddResolver(
      Resolver_Multiple.Create([
        'value1', 'is',
        'value2', 'working'
    ]));
    Assert.AreEqual('Test is working Test', Document.asString);
  finally
    Document.Free;
  end;
end;

procedure TDocumentCreatorTest.TestProcResolver;
var
  Document: TDocumentCreator;
begin
  Document := TDocumentCreator.Create('Test {{ key1 }} {{ key2 }} Test');
  try
    Document.AddResolver(Resolver_Func.Create(Self.DemoResolverFunc));
    Assert.AreEqual('Test value1 value2 Test', Document.asString);
  finally
    Document.Free;
  end;
end;

procedure TDocumentCreatorTest.TestMultipleReplacements;
var
  Document: TDocumentCreator;
begin
  Document := TDocumentCreator.Create('Test {{ value }} {{ value }} Test');
  try
    Document.AddResolver(
      Resolver_Single.Create('value', 'is working')
    );
    Assert.AreEqual('Test is working is working Test', Document.asString);
  finally
    Document.Free;
  end;
end;

procedure TDocumentCreatorTest.TestInvalidKeyReplacement;
var
  Document: TDocumentCreator;
  UnresolvedKeys: TArray<string>;
begin
  Document := TDocumentCreator.Create('Test {{ nonexistingkey }} Test');
  try
    Assert.AreEqual('Test ???nonexistingkey??? Test', Document.asString);
    UnresolvedKeys := Document.GetUnresolved;
    Assert.AreEqual(1, Length(UnresolvedKeys));
    Assert.AreEqual('nonexistingkey', UnresolvedKeys[0]);
  finally
    Document.Free;
  end;
end;

procedure TDocumentCreatorTest.TestLastResolverWinning;
var
  Document: TDocumentCreator;
begin
  Document := TDocumentCreator.Create('Test {{ value }}');
  try
    Document.AddResolver(
      Resolver_Single.Create('value', 'is not working')
    );
    Document.AddResolver(
      Resolver_Single.Create('value', 'is working')
    );
    Assert.AreEqual('Test is working', Document.asString);
  finally
    Document.Free;
  end;
end;

procedure TDocumentCreatorTest.TestCustomFilter;
var
  Document: TDocumentCreator;
begin
  Document := TDocumentCreator.Create('Test {{ value|stars }}');
  try
    // filters are auto-registering in new instances of TDocumentCreator
    // you have to provide a factory method in the unit initialization part:
    // RegisterFilterFactory(Filter_stars.NewInstance);
    Document.AddResolver(
      Resolver_Single.Create('value', 'is working')
    );
    Assert.AreEqual('Test **is working**', Document.asString);
  finally
    Document.Free;
  end;
end;

procedure TDocumentCreatorTest.TestFilterManualRegistration;
var
  Document: TDocumentCreator;
begin
  Document := TDocumentCreator.Create('Test {{ value|manual }}');
  try
    Document.AddResolver(
      Resolver_Single.Create('value', 'is working')
    );
    // registering filter manually
    Document.AddFilter(Filter_manual.Create);
    Assert.AreEqual('Test %%is working%%', Document.asString);
  finally
    Document.Free;
  end;
end;

procedure TDocumentCreatorTest.TestNonExistingFilterError;
var
  Document: TDocumentCreator;
begin
  Document := TDocumentCreator.Create('Test {{ value|invalid }}');
  try
    Document.AddResolver(
      Resolver_Single.Create('value', 'is working')
    );
    // registering filter manually
    Document.AddFilter(Filter_manual.Create);
    Assert.AreEqual('Test is working|???invalid???', Document.asString);
  finally
    Document.Free;
  end;
end;

{ Demo filter Filter_stars }

function Filter_stars.getName: String;
begin
  Result := 'stars';
end;

class function Filter_stars.NewInstance: IFilter;
begin
  Result := Filter_stars.Create;
end;

function Filter_stars.process(AString: String): String;
begin
  Result := '**' + AString + '**';
end;

{ Demo filter Filter_manual }

function Filter_manual.getName: String;
begin
  Result := 'manual';
end;

class function Filter_manual.NewInstance: IFilter;
begin
  Result := Filter_manual.Create;
end;

function Filter_manual.process(AString: String): String;
begin
  Result := '%%' + AString + '%%';
end;

initialization
  TDUnitX.RegisterTestFixture(TDocumentCreatorTest);
  RegisterFilterFactory(Filter_stars.NewInstance);

end.
