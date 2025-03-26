unit UtilityFunctions;

interface
uses
  System.Generics.Defaults; // IEqualityComparer, _LookupVtableInfo

type
  Nullable<T> = packed record
  class var FComparer: Pointer; // IEqualityComparer<T>;
  strict private
    FValue: T;
    FPValue: ^T;
    function GetHasValue: Boolean;
    function GetValue: T;
    class procedure CreateComparer; static;
    class function GetComparer: IEqualityComparer<T>; static;
    class function IsEqual(const Left, Right: T): Boolean; static;
  public
    constructor Create(const value: T); overload;
    constructor Create(const value: Pointer); overload;

    function GetValueOrDefault(const defaultValue: T): T; overload;
    function TryGetValue(out value: T): Boolean; inline;
    property HasValue: Boolean read GetHasValue;
    property Value: T read GetValue;
    class operator Implicit(const value: Pointer): Nullable<T>;
    class operator Implicit(const value: T): Nullable<T>;
    class operator Explicit(const value: Nullable<T>): T;
    class operator Equal(const left, right: Nullable<T>): Boolean;
    class operator Equal(const left: Nullable<T>; const right: Pointer): Boolean;
    class operator NotEqual(const left, right: Nullable<T>): Boolean;
    class operator NotEqual(const left: Nullable<T>; const right: Pointer): Boolean;
  end;

implementation
uses
  SysUtils; // Exception

class procedure Nullable<T>.CreateComparer;
begin
  if not Assigned(FComparer) then
    Nullable<T>.FComparer := _LookupVtableInfo(giEqualityComparer, TypeInfo(T), SizeOf(T));
end;

constructor Nullable<T>.Create(const value: T);
begin
  CreateComparer;
  FValue := value;
  FPValue := @FValue;
end;

constructor Nullable<T>.Create(const value: Pointer);
begin
  Assert(value = nil);
  CreateComparer;
  FPValue := nil;
end;

class function Nullable<T>.IsEqual(const Left: T; const Right: T): Boolean;
begin
  Result := (Left = Right);
end;

class function Nullable<T>.GetComparer: IEqualityComparer<T>;
begin
  Result := IEqualityComparer<T>(FComparer);
end;

function Nullable<T>.GetHasValue: Boolean;
begin
  Result := FPValue <> nil;
end;

function Nullable<T>.GetValue: T;
begin
  if HasValue then
    Result := FValue
  else
    raise Exception.Create('Cannot call GetValue on Nullable(nil)');
end;

function Nullable<T>.GetValueOrDefault(const defaultValue: T): T;
begin
  if not HasValue then
    Result := defaultValue
  else
    Result := Value;
end;

function Nullable<T>.TryGetValue(out value: T): Boolean;
begin
  if FPValue <> nil then
    value := FValue;
  Result := FPValue <> nil;
end;

class operator Nullable<T>.Implicit(const value: Pointer): Nullable<T>;
begin
  Assert(value = nil);
  Result := Nullable<T>.Create(nil);
end;

class operator Nullable<T>.Implicit(const value: T): Nullable<T>;
begin
  Result := Nullable<T>.Create(value);
end;

class operator Nullable<T>.Explicit(const value: Nullable<T>): T;
begin
  inherited;
  Result := value.GetValue;
end;

class operator Nullable<T>.NotEqual(const left, right: Nullable<T>): Boolean;
begin
  Result := not (left = right);
end;

class operator Nullable<T>.NotEqual(const left: Nullable<T>;
  const right: Pointer): Boolean;
begin
  Assert(right = nil);
  Result := left.HasValue;
end;

class operator Nullable<T>.Equal(const left: Nullable<T>;
  const right: Pointer): Boolean;
begin
  Assert(right = nil);
  Result := left.FPValue = nil;
end;

class operator Nullable<T>.Equal(const left, right: Nullable<T>): Boolean;
var LLeft, LRight: T;
begin
    // only one of them is nil = false
  if left.HasValue xor right.HasValue then
    Exit(False);
    // both are nil = true
  if not left.HasValue and not right.HasValue then
    Exit(True);
    // compare both non-nil values
  LLeft := left.GetValue;
  LRight := right.GetValue;
  Result := GetComparer.Equals(LLeft, LRight);
end;


end.
