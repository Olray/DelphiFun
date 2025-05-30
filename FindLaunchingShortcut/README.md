# FindLaunchingShortcut

Find out if your app has been launched by a Shortcut file and retrieve the shortcut's filename.
Intention: If the shortcut's parameters are invalid you now have the opportunity to ask the user to delete it.

## Usage

```pascal
uses
  ShortcutFinder;
[...]
  var LShortcutFinder: IOriginatingShortcutFinder;
  begin
    LShortcutFinder := TShortcutFinder.Create;
    if ShortcutFinder.IsRunByShortcut then
    begin
      Memo1.Lines.Add('App was run by clicking a shortcut');
      Memo1.Lines.Add(Format('The shortcut is "%s"', [ShortcutFinder.GetShortcutFileName]));
    end;
  end;
```
