unit NullableTest;

interface
uses
  DUnitX.TestFramework,
  UtilityFunctions;

type
  [TestFixture]
  TTestNullable = class
  public

    [Test]
    procedure TestCreateNullable;
    [Test]
    procedure TestCompareNullableOfString;
    [Test]
    procedure TestCompareNullableOfInteger;
    [Test]
    procedure TestGetValueOrDefault;
    [Test]
    procedure TestCannotAssignNonNilPointer;
    [Test]
    procedure TestEmptyString;
  end;

implementation

{ TTestNullable }

procedure TTestNullable.TestCreateNullable;
var LNullable: Nullable<string>;
    LString: string;
begin
    // init from pointer(nil)
  LNullable := nil;
  Assert.IsFalse(LNullable.HasValue, 'Nullable(nil) has a value');
  Assert.IsTrue(LNullable = nil, 'Nullable(nil) is not nil');

    // init from string constant
  LNullable := 'test';
  Assert.IsTrue(LNullable.HasValue, 'Nullable(test) has no value');
  Assert.IsFalse(LNullable = nil, 'Nullable(test) is nil');
  Assert.AreEqual('test', LNullable.Value);

   // init from string variable
  LString := 'another';
  LNullable := LString;
  Assert.IsTrue(LNullable.HasValue, 'Nullable(another) has no value');
  Assert.IsFalse(LNullable = nil, 'Nullable(anotehr) is nil');
  Assert.AreEqual('another', LNullable.Value);
end;

procedure TTestNullable.TestGetValueOrDefault;
var LNullableI: Nullable<Integer>;
var LNullableS: Nullable<string>;
begin
  LNullableI := 1234;
  Assert.AreEqual(1234, LNullableI.GetValueOrDefault(4321));
  LNullableI := nil;
  Assert.AreEqual(4321, LNullableI.GetValueOrDefault(4321));

  LNullableS := 'test';
  Assert.AreEqual('test', LNullableS.GetValueOrDefault('uftu'));
  LNullableS := nil;
  Assert.AreEqual('uftu', LNullableS.GetValueOrDefault('uftu'));
end;

procedure TTestNullable.TestCannotAssignNonNilPointer;
var LNullable: Nullable<Integer>;
var LInteger: Integer;
begin
  Assert.WillRaise(
    procedure
    begin
      LNullable := @LInteger;
    end,
    nil,
    'Assigning a non nil pointer should not be allowed'
  );
end;

procedure TTestNullable.TestCompareNullableOfInteger;
var LNullable: Nullable<Integer>;
    LInteger: Integer;
begin
  LNullable := 1234;
  Assert.IsTrue(4321 <> LNullable);
  Assert.IsTrue(1234 = LNullable);
  Assert.IsTrue(LNullable <> nil);
  Assert.IsFalse(LNullable = nil);
  Assert.AreEqual(1234, LNullable.Value);

  LInteger := LNullable.Value;
  Assert.AreEqual(1234, LInteger);

  LNullable := nil;
  Assert.IsFalse(LNullable.HasValue);
  Assert.IsFalse(LNullable <> nil);
  Assert.IsTrue(LNullable = nil);
end;

procedure TTestNullable.TestCompareNullableOfString;
var LNullable: Nullable<string>;
begin
  LNullable := 'test';
  Assert.IsTrue('uftu' <> LNullable);
  Assert.IsTrue('test' = LNullable);
  Assert.IsTrue(LNullable <> nil);
  Assert.IsFalse(LNullable = nil);

  LNullable := nil;
  Assert.IsFalse(LNullable.HasValue);
  Assert.IsFalse(LNullable <> nil);
  Assert.IsTrue(LNullable = nil);
end;

procedure TTestNullable.TestEmptyString;
var LNullable: Nullable<string>;
begin
  LNullable := nil;
  Assert.IsFalse(LNullable.HasValue);
  LNullable := '';
  Assert.IsTrue(LNullable.HasValue);
  Assert.IsTrue(LNullable = '');
end;

initialization
  TDUnitX.RegisterTestFixture(TTestNullable);

end.
