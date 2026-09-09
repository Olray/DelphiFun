unit Resolver.DMap;

interface

uses
  DCTypes,
  DeCAL;

type
  Resolver_DMap = class(TInterfacedObject, IResolver)
  private
    FValueMap: DMap;
  public
    constructor Create(const Values: DMap);
    function Resolve(const key: string): TResolveResponse;
  end;

implementation

{ Resolver_DMap }

constructor Resolver_DMap.Create(const Values: DMap);
begin
  FValueMap := Values;
end;

function Resolver_DMap.Resolve(const key: string): TResolveResponse;
var
  iter: DIterator;
begin
  Result := nil;
  iter := FValueMap.locate([key]);
  if not atEnd(iter) then
  begin
    SetToValue(iter);
    Result := getString(iter);
  end;
end;

end.
