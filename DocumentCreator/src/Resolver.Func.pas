unit Resolver.Func;

interface
uses
  DCTypes;

type
  Resolver_Func = class(TInterfacedObject, IResolver)
  private
    FProviderFunc: TValueProvider;
  public
    constructor Create(CallbackFunction: TValueProvider);
    function Resolve(const key: string): TResolveResponse;
  end;

implementation

{ Resolver_Multiple }

constructor Resolver_Func.Create(CallbackFunction: TValueProvider);
begin
  FProviderFunc := CallbackFunction;
end;

function Resolver_Func.Resolve(const key: string): TResolveResponse;
begin
  Result := FProviderFunc(key);
end;

end.
