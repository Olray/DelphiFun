# Obsolete

Starting with Delphi 13.0 the IfThen<t> class is obsolete and can be replaced with the ternary operator based on if..then...else syntax.

Before (Delphi <= 12.3):
```pascal
  WriteLn(IfThen<string>.Get(BooleanValue, 'Black', 'White'));
```

Now (Delphi >= 13.0):
```pascal
  WriteLn(if BooleanValue then 'Black' else 'White');
```

The new ternary operator has lazy evaluation and replaces the following construct:
```pascal
  if BooleanValue then
    Result := 'Black'
  else  
    Result := 'White';
```

# A look at IfThen

At some point in time every Delphi programmer writes some generic IfThen class like this:

```
type
  IfThen<T> = class
  public
    class function Get(Condition: Boolean; WhenTrue: T; WhenFalse: T): T;
  end;
```

This works well with constants but has a major drawback when using IfThen for time consuming operations, like selecting
rows from a database based on the condition.
The Delphi compiler executes the code to evaluate both expressions WhenTrue and WhenFalse, passes these values to the IfThen<T>
function and let's it select the appropriate result.
**Both WhenTrue and WhenFalse are calculated** no matter the boolean expression.

So, the IfThen class from UtilityFunctions.pas is my suggestion to solve the problem. See the Test for examples.