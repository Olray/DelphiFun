unit Resolver.Multiple;

interface

uses
  System.Generics.Collections, // TPair generic
  DCTypes;

type
  Resolver_Multiple = class(TInterfacedObject, IResolver)
  private
    FValues: array of TPair<string, string>;
  public
    constructor Create(pairs: array of const);
    function Resolve(const key: string): TResolveResponse;
  end;

implementation

{ Resolver_Single }

constructor Resolver_Multiple.Create(pairs: array of const);
var Count: Integer;
    i : Integer;
    key, value : String;
begin
  Assert(Length(pairs) MOD 2 = 0, 'Ungerade Anzahl von key-value Werten!');
  // reserve space for pairs
  Count := Length(pairs) DIV 2;
  SetLength(FValues, Count);
  // use Count for index to FValues
  Count := 0;

  i := Low(pairs);
  while(i < High(pairs)) do
  begin
    key := pairs[i].VPWideChar;
    value := pairs[i+1].VPWideChar;
    FValues[Count] := TPair<string, string>.Create(key, value);
    Inc(i,2);
    Inc(Count);
  end;
end;

function Resolver_Multiple.Resolve(const key: string): TResolveResponse;
begin
  Result := nil;
  for var i := Low(FValues) to High(FValues) do
  begin
    if(key = FValues[i].Key) then
    begin
      Result := FValues[i].Value;
      Exit;
    end;
  end;
end;

end.
