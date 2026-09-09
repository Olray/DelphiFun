unit Resolver.Single;

interface

uses
  DCTypes;

type
  Resolver_Single = class(TInterfacedObject, IResolver)
  private
    FKey, FValue: string;
  public
    constructor Create(const key, value : string);
    function Resolve(const key: string): TResolveResponse;
  end;

implementation

{ Resolver_Single }

constructor Resolver_Single.Create(const key, value: string);
begin
  FKey := key;
  FValue := value;
end;

function Resolver_Single.Resolve(const key: string): TResolveResponse;
begin
  Result := nil;
  if(key = FKey) then
    Result := FValue;
end;

end.
