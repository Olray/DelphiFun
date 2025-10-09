unit ErrorDialog.Form;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.Buttons,
  System.Generics.Collections,
  ErrorDialog.Types,
  ErrorDialog.Utils;

type
  // Custom panel for rendering markdown text
  TMarkdownPanel = class(TPanel)
  const
    MarginLeft = 8;
    MarginTop = 8;
    LineGap = 2;
  private
    FText: string;
    FParsedText: TArray<string>;
    FTextStyles: TArray<TFontStyles>;
    FTextColors: TArray<TColor>;
    FLineHeight: Integer;
    procedure ParseMarkdownText(const AText: string);
    function ProcessMarkdownLine(const ALine: string; AOutput: TStringList;
      AStyles: TList<TFontStyles>; AColors: TList<TColor>): string;
    function CalculateTextHeight: Integer;
    function ResolveColorName(const AColorName: string): TColor;
    function IsHexColor(const AColorName: string): Boolean;
    function HexToColor(const AHex: string): TColor;
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure SetMarkdownText(const AText: string);
    function GetRequiredHeight: Integer;
  end;

  TErrorDialogForm = class(TForm)
    PanelMain: TPanel;
    PanelIcon: TPanel;
    ImageIcon: TImage;
    PanelContent: TPanel;
    LabelTitle: TLabel;
    PanelButtons: TPanel;
    PanelExtra: TPanel;
    ButtonExtra: TButton;
    MemoExtraInfo: TMemo;
    
    procedure ButtonExtraClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FConfig: TErrorDialogConfig;
    FButtons: TList<TButton>;
    FExtraVisible: Boolean;
    FOriginalHeight: Integer;
    FMarkdownPanel: TMarkdownPanel;
    
    procedure SetupDialog;
    procedure CreateButtons;
    procedure SetupIcon;
    procedure SetupMessage;
    procedure SetupExtraInfo;
    procedure ApplyTheme;
    procedure OnButtonClick(Sender: TObject);
    procedure ToggleExtraInfo;
    procedure ResizeForm;
  public
    constructor Create(AOwner: TComponent; const AConfig: TErrorDialogConfig); reintroduce;
    
    class function ShowErrorDialog(const AConfig: TErrorDialogConfig): TModalResult;
  end;

implementation

uses
  System.Math,
  Vcl.Imaging.pngimage;

{$R *.dfm}

{ TErrorDialogForm }

constructor TErrorDialogForm.Create(AOwner: TComponent; const AConfig: TErrorDialogConfig);
begin
  inherited Create(AOwner);
  FConfig := AConfig;
  FButtons := TList<TButton>.Create;
  FExtraVisible := False;
  
  // Create custom markdown panel
  FMarkdownPanel := TMarkdownPanel.Create(Self);
  FMarkdownPanel.Parent := PanelContent;
  FMarkdownPanel.Left := 8;
  FMarkdownPanel.Top := 10;
  FMarkdownPanel.Width := PanelContent.Width - 16;
  FMarkdownPanel.Anchors := [akLeft, akTop, akRight];
  FMarkdownPanel.BevelOuter := bvNone;
  
  SetupDialog;
end;

procedure TErrorDialogForm.FormCreate(Sender: TObject);
begin
  // Set default properties
  BorderStyle := bsDialog;
  Position := poScreenCenter;
  Constraints.MinWidth := 350;
  Constraints.MinHeight := 150;
end;

procedure TErrorDialogForm.FormDestroy(Sender: TObject);
begin
  FButtons.Free;
end;

procedure TErrorDialogForm.SetupDialog;
begin
  // Set title
  if FConfig.Title <> '' then
    Caption := FConfig.Title
  else
    Caption := 'Error';
    
  SetupIcon;
  SetupMessage;
  CreateButtons;
  SetupExtraInfo;
  ApplyTheme;
  ResizeForm;
end;

procedure TErrorDialogForm.SetupIcon;
var
  Icon: HICON;
begin
  if FConfig.Icon <> eiNone then
  begin
    Icon := TErrorDialogUtils.GetSystemIcon(FConfig.Icon);
    if Icon <> 0 then
    begin
      ImageIcon.Picture.Icon.Handle := Icon;
      PanelIcon.Visible := True;
    end
    else
      PanelIcon.Visible := False;
  end
  else
    PanelIcon.Visible := False;
end;

procedure TErrorDialogForm.SetupMessage;
begin
  LabelTitle.Caption := FConfig.Title;
  
  // Set markdown text in custom panel
  FMarkdownPanel.SetMarkdownText(FConfig.Message);

  // Hide title label if same as caption
  if (FConfig.Title <> '') and (LabelTitle.Caption = Caption) then
    LabelTitle.Visible := False;
end;

procedure TErrorDialogForm.CreateButtons;
const
  ButtonSpacing = 8;
  ButtonWidth = 75;
  ButtonHeight = 25;
var
  ButtonTexts: TArray<string>;
  ButtonResults: TArray<TModalResult>;
  I: Integer;
  Button: TButton;
  TotalWidth: Integer;
  StartX: Integer;
begin
  // Define button configurations
  case FConfig.Buttons of
    ebOK:
    begin
      ButtonTexts := ['OK'];
      ButtonResults := [mrOk];
    end;
    ebOKCancel:
    begin
      ButtonTexts := ['OK', 'Cancel'];
      ButtonResults := [mrOk, mrCancel];
    end;
    ebYesNo:
    begin
      ButtonTexts := ['Yes', 'No'];
      ButtonResults := [mrYes, mrNo];
    end;
    ebYesNoCancel:
    begin
      ButtonTexts := ['Yes', 'No', 'Cancel'];
      ButtonResults := [mrYes, mrNo, mrCancel];
    end;
    ebRetryCancel:
    begin
      ButtonTexts := ['Retry', 'Cancel'];
      ButtonResults := [mrRetry, mrCancel];
    end;
    ebAbortRetryIgnore:
    begin
      ButtonTexts := ['Abort', 'Retry', 'Ignore'];
      ButtonResults := [mrAbort, mrRetry, mrIgnore];
    end;
  else
    ButtonTexts := ['OK'];
    ButtonResults := [mrOk];
  end;

  // Calculate positioning
  TotalWidth := Length(ButtonTexts) * ButtonWidth + (Length(ButtonTexts) - 1) * ButtonSpacing;
  StartX := (PanelButtons.Width - TotalWidth) div 2;

  // Create buttons
  for I := 0 to High(ButtonTexts) do
  begin
    Button := TButton.Create(Self);
    Button.Parent := PanelButtons;
    Button.Caption := ButtonTexts[I];
    Button.Width := ButtonWidth;
    Button.Height := ButtonHeight;
    Button.Left := StartX + I * (ButtonWidth + ButtonSpacing);
    Button.Top := (PanelButtons.Height - ButtonHeight) div 2;
    Button.ModalResult := ButtonResults[I];
    Button.OnClick := OnButtonClick;
    
    // Set default and cancel buttons
    if ButtonResults[I] = mrOk then
      Button.Default := True
    else if ButtonResults[I] = mrCancel then
      Button.Cancel := True;
      
    FButtons.Add(Button);
  end;
end;

procedure TErrorDialogForm.SetupExtraInfo;
var
  InfoText: TStringList;
  Provider: IInfoProvider;
  Info: TPair<string, string>;
begin
  InfoText := TStringList.Create;
  try
    for Provider in FConfig.InfoProviders do
    begin
      if Provider.IsAvailable then
      begin
        Info := Provider.GetInfo;
        InfoText.Add(Format('%s: %s', [Info.Key, Info.Value]));
      end;
    end;
    
    if InfoText.Count > 0 then
    begin
      MemoExtraInfo.Lines.Assign(InfoText);
      ButtonExtra.Visible := FConfig.ShowExtraButton or (InfoText.Count > 0);
      ButtonExtra.Caption := 'Details >>';
    end
    else
    begin
      ButtonExtra.Visible := False;
      PanelExtra.Visible := False;
    end;
  finally
    InfoText.Free;
  end;
end;

procedure TErrorDialogForm.ApplyTheme;
begin
  // Apply modern theme
  LabelTitle.Font.Style := [fsBold];
  LabelTitle.Font.Size := 10;

  // Style the extra info panel
  PanelExtra.Color := $F0F0F0;
  MemoExtraInfo.Color := $F8F8F8;
  MemoExtraInfo.ReadOnly := True;
  MemoExtraInfo.ScrollBars := ssVertical;
end;

procedure TErrorDialogForm.OnButtonClick(Sender: TObject);
begin
  if Sender is TButton then
    ModalResult := TButton(Sender).ModalResult;
end;

procedure TErrorDialogForm.ButtonExtraClick(Sender: TObject);
begin
  ToggleExtraInfo;
end;

procedure TErrorDialogForm.ToggleExtraInfo;
begin
  FExtraVisible := not FExtraVisible;

  if FExtraVisible then
  begin
    if FOriginalHeight = 0 then
      FOriginalHeight := Height;
    PanelExtra.Visible := True;
    Height := FOriginalHeight + PanelExtra.Height;
    ButtonExtra.Caption := 'Details <<';
  end
  else
  begin
    PanelExtra.Visible := False;
    if FOriginalHeight > 0 then
      Height := FOriginalHeight;
    ButtonExtra.Caption := 'Details >>';
  end;
end;

procedure TErrorDialogForm.ResizeForm;
var
  ContentHeight: Integer;
  MessageHeight: Integer;
begin
  // Calculate required height for markdown message
  MessageHeight := FMarkdownPanel.GetRequiredHeight;
  FMarkdownPanel.Height := MessageHeight;

  // Calculate total content height
  ContentHeight := LabelTitle.Height + MessageHeight + PanelButtons.Height + 40; // Margins

  if PanelIcon.Visible then
    ContentHeight := Max(ContentHeight, PanelIcon.Height + 40);

  Height := ContentHeight;
  FOriginalHeight := Height;
end;

class function TErrorDialogForm.ShowErrorDialog(const AConfig: TErrorDialogConfig): TModalResult;
var
  Form: TErrorDialogForm;
begin
  Form := TErrorDialogForm.Create(nil, AConfig);
  try
    Result := Form.ShowModal;
  finally
    Form.Free;
  end;
end;

{ TMarkdownPanel }

constructor TMarkdownPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FLineHeight := 0;
  BevelOuter := bvNone;
  Font.Name := 'Roboto Lt';
  Font.Size := 10;
end;

procedure TMarkdownPanel.SetMarkdownText(const AText: string);
begin
  FText := AText;
  ParseMarkdownText(AText);
  Invalidate; // Trigger repaint
end;

procedure TMarkdownPanel.ParseMarkdownText(const AText: string);
var
  Lines: TArray<string>;
  I: Integer;
  Line: string;
  ParsedLines: TStringList;
  Styles: TList<TFontStyles>;
  Colors: TList<TColor>;
  ProcessedText: string;
begin
  ParsedLines := TStringList.Create;
  Styles := TList<TFontStyles>.Create;
  Colors := TList<TColor>.Create;

  try
    // Split by \n first and process each line
    Lines := AText.Split(['\n']);

    for I := 0 to High(Lines) do
    begin
      Line := Lines[I];

      // Process markdown in this line
      ProcessedText := ProcessMarkdownLine(Line, ParsedLines, Styles, Colors);

      // Add line break if not last line
      if I < High(Lines) then
      begin
        ParsedLines.Add(sLineBreak);
        Styles.Add([]);
        Colors.Add(clWindowText);
      end;
    end;

    // Convert to arrays
    SetLength(FParsedText, ParsedLines.Count);
    SetLength(FTextStyles, ParsedLines.Count);
    SetLength(FTextColors, ParsedLines.Count);

    for I := 0 to ParsedLines.Count - 1 do
    begin
      FParsedText[I] := ParsedLines[I];
      FTextStyles[I] := Styles[I];
      FTextColors[I] := Colors[I];
    end;

  finally
    ParsedLines.Free;
    Styles.Free;
    Colors.Free;
  end;
end;

function TMarkdownPanel.ProcessMarkdownLine(const ALine: string;
  AOutput: TStringList; AStyles: TList<TFontStyles>; AColors: TList<TColor>): string;
var
  I: Integer;
  CurrentWord: string;
  InBold, InItalic: Boolean;
  CurrentColor: TColor;
  CurrentStyle: TFontStyles;
  ColorStack: TList<TColor>;
  
  procedure AddCurrentWord;
  begin
    if CurrentWord <> '' then
    begin
      AOutput.Add(CurrentWord);
      CurrentStyle := [];
      if InBold then CurrentStyle := CurrentStyle + [fsBold];
      if InItalic then CurrentStyle := CurrentStyle + [fsItalic];
      AStyles.Add(CurrentStyle);
      AColors.Add(CurrentColor);
      CurrentWord := '';
    end;
  end;
  
  function ParseColorTag(StartPos: Integer; out ColorName: string; out TagLength: Integer): Boolean;
  var
    BraceEnd: Integer;
  begin
    Result := False;
    ColorName := '';
    TagLength := 0;
    
    if (StartPos <= Length(ALine)) and (ALine[StartPos] = '{') then
    begin
      BraceEnd := StartPos + 1;
      while (BraceEnd <= Length(ALine)) and (ALine[BraceEnd] <> '}') do
        Inc(BraceEnd);
        
      if (BraceEnd <= Length(ALine)) and (ALine[BraceEnd] = '}') then
      begin
        ColorName := Copy(ALine, StartPos + 1, BraceEnd - StartPos - 1);
        TagLength := BraceEnd - StartPos + 1;
        Result := True;
      end;
    end;
  end;
  
  function ParseColorEndTag(StartPos: Integer; const ExpectedColor: string; out TagLength: Integer): Boolean;
  var
    EndTag: string;
  begin
    EndTag := '{/' + ExpectedColor + '}';
    TagLength := Length(EndTag);
    Result := (StartPos + TagLength - 1 <= Length(ALine)) and
              (Copy(ALine, StartPos, TagLength) = EndTag);
  end;

var
  ColorName: string;
  TagLength: Integer;
begin
  Result := '';
  CurrentWord := '';
  InBold := False;
  InItalic := False;
  CurrentColor := clWindowText;
  ColorStack := TList<TColor>.Create;
  
  try
    I := 1;
    
    while I <= Length(ALine) do
    begin
      // Check for bold marker (**)
      if (I <= Length(ALine) - 1) and (Copy(ALine, I, 2) = '**') then
      begin
        AddCurrentWord;
        InBold := not InBold;
        Inc(I, 2);
      end
      // Check for italic marker (__)
      else if (I <= Length(ALine) - 1) and (Copy(ALine, I, 2) = '__') then
      begin
        AddCurrentWord;
        InItalic := not InItalic;
        Inc(I, 2);
      end
      // Check for color start tag {colorname}
      else if ParseColorTag(I, ColorName, TagLength) then
      begin
        // Check if it's an end tag
        if (Length(ColorName) > 0) and (ColorName[1] = '/') then
        begin
          // End color tag {/colorname}
          AddCurrentWord;
          if ColorStack.Count > 0 then
          begin
            CurrentColor := ColorStack.Last;
            ColorStack.Delete(ColorStack.Count - 1);
          end
          else
            CurrentColor := clWindowText;
        end
        else
        begin
          // Start color tag {colorname}
          AddCurrentWord;
          ColorStack.Add(CurrentColor);
          CurrentColor := ResolveColorName(ColorName);
        end;
        Inc(I, TagLength);
      end
      // Check for space (word boundary)
      else if ALine[I] = ' ' then
      begin
        // Add current word with space
        if CurrentWord <> '' then
          CurrentWord := CurrentWord + ' '
        else
          CurrentWord := ' ';
          
        AddCurrentWord;
        Inc(I);
      end
      else
      begin
        CurrentWord := CurrentWord + ALine[I];
        Inc(I);
      end;
    end;
    
    // Add final word if any
    AddCurrentWord;
    
  finally
    ColorStack.Free;
  end;
end;procedure TMarkdownPanel.Paint;
var
  I: Integer;
  X, Y: Integer;
  LineHeight: Integer;
  CurrentStyle: TFontStyles;
  WordWidth: Integer;
begin
  inherited Paint;

  if Length(FParsedText) = 0 then
    Exit;

  Canvas.Font := Font;
  Canvas.Brush.Style := bsClear;

  LineHeight := Canvas.TextHeight('Wg') + LineGap;
  FLineHeight := LineHeight;

  X := MarginLeft;
  Y := MarginTop;

  for I := 0 to High(FParsedText) do
  begin
    if FParsedText[I] = sLineBreak then
    begin
      Inc(Y, LineHeight);
      X := MarginLeft;
    end
    else
    begin
      // Set font style for this word
      CurrentStyle := FTextStyles[I];
      Canvas.Font.Style := CurrentStyle;
      Canvas.Font.Color := FTextColors[I];

      // Check if word fits on current line
      WordWidth := Canvas.TextWidth(FParsedText[I]);
      if (X + WordWidth > Width - (2*MarginLeft)) and (X > MarginLeft) then
      begin
        // Word wrap to next line
        Inc(Y, LineHeight);
        X := MarginLeft;
      end;

      // Draw the word
      Canvas.TextOut(X, Y, FParsedText[I]);

      // Move X position
      Inc(X, WordWidth);
    end;
  end;
end;

function TMarkdownPanel.ResolveColorName(const AColorName: string): TColor;
var
  ColorName: string;
begin
  ColorName := LowerCase(Trim(AColorName));
  
  // Standard color names
  if ColorName = 'red' then Result := clRed
  else if ColorName = 'blue' then Result := clBlue
  else if ColorName = 'green' then Result := clGreen
  else if ColorName = 'yellow' then Result := clYellow
  else if ColorName = 'orange' then Result := $0080FF // Orange
  else if ColorName = 'purple' then Result := clPurple
  else if ColorName = 'pink' then Result := $FF80FF // Pink
  else if ColorName = 'brown' then Result := $8B4513 // Brown
  else if ColorName = 'gray' then Result := clGray
  else if ColorName = 'grey' then Result := clGray
  else if ColorName = 'black' then Result := clBlack
  else if ColorName = 'white' then Result := clWhite
  else if ColorName = 'darkred' then Result := clMaroon
  else if ColorName = 'darkblue' then Result := clNavy
  else if ColorName = 'darkgreen' then Result := $006400 // DarkGreen
  else if ColorName = 'lightgray' then Result := clSilver
  else if ColorName = 'lightgrey' then Result := clSilver
  else if ColorName = 'darkgray' then Result := $808080 // DarkGray
  else if ColorName = 'darkgrey' then Result := $808080 // DarkGray
  
  // System colors
  else if ColorName = 'windowtext' then Result := clWindowText
  else if ColorName = 'window' then Result := clWindow
  else if ColorName = 'highlight' then Result := clHighlight
  else if ColorName = 'highlighttext' then Result := clHighlightText
  else if ColorName = 'btnface' then Result := clBtnFace
  else if ColorName = 'btntext' then Result := clBtnText
  else if ColorName = 'activecaption' then Result := clActiveCaption
  else if ColorName = 'inactivecaption' then Result := clInactiveCaption
  else if ColorName = 'menu' then Result := clMenu
  else if ColorName = 'menutext' then Result := clMenuText
  
  // Extended color names
  else if ColorName = 'lime' then Result := clLime
  else if ColorName = 'aqua' then Result := clAqua
  else if ColorName = 'fuchsia' then Result := clFuchsia
  else if ColorName = 'olive' then Result := clOlive
  else if ColorName = 'teal' then Result := clTeal
  else if ColorName = 'navy' then Result := clNavy
  else if ColorName = 'maroon' then Result := clMaroon
  else if ColorName = 'silver' then Result := clSilver
  
  // Error/Warning semantic colors
  else if ColorName = 'error' then Result := clRed
  else if ColorName = 'warning' then Result := $0080FF // Orange
  else if ColorName = 'success' then Result := clGreen
  else if ColorName = 'info' then Result := clBlue
  
  // Hex color support (e.g., "ff0000" for red)
  else if (Length(ColorName) = 6) and IsHexColor(ColorName) then
    Result := HexToColor(ColorName)
  
  // Default fallback
  else
    Result := clWindowText;
end;

function TMarkdownPanel.IsHexColor(const AColorName: string): Boolean;
var
  I: Integer;
begin
  Result := True;
  for I := 1 to Length(AColorName) do
  begin
    if not CharInSet(AColorName[I], ['0'..'9', 'a'..'f', 'A'..'F']) then
    begin
      Result := False;
      Break;
    end;
  end;
end;

function TMarkdownPanel.HexToColor(const AHex: string): TColor;
var
  R, G, B: Byte;
begin
  try
    R := StrToInt('$' + Copy(AHex, 1, 2));
    G := StrToInt('$' + Copy(AHex, 3, 2));
    B := StrToInt('$' + Copy(AHex, 5, 2));
    Result := RGB(R, G, B);
  except
    Result := clWindowText; // Fallback on error
  end;
end;

function TMarkdownPanel.CalculateTextHeight: Integer;
var
  I: Integer;
  LineCount: Integer;
  LineHeight: Integer;
  X, WordWidth: Integer;
  TempCanvas: TCanvas;
begin
  if Length(FParsedText) = 0 then
  begin
    Result := 20;
    Exit;
  end;

  // Create temporary canvas for measurement
  TempCanvas := TCanvas.Create;
  try
    TempCanvas.Handle := GetDC(0);
    TempCanvas.Font := Font;
    LineHeight := TempCanvas.TextHeight('Wg') + LineGap;

    LineCount := 1;
    X := MarginLeft;

    for I := 0 to High(FParsedText) do
    begin
      if FParsedText[I] = sLineBreak then
      begin
        Inc(LineCount);
        X := MarginLeft;
      end
      else
      begin
        // Apply style for measurement
        TempCanvas.Font.Style := FTextStyles[I];
        WordWidth := TempCanvas.TextWidth(FParsedText[I]);

        // Check if word wrapping is needed
        if (X + WordWidth > Width - (2*MarginLeft)) and (X > MarginLeft) then
        begin
          Inc(LineCount);
          X := MarginLeft;
        end;

        Inc(X, WordWidth);
      end;
    end;

    Result := LineCount * LineHeight + (2*MarginTop); // padding top and bottom

  finally
    ReleaseDC(0, TempCanvas.Handle);
    TempCanvas.Free;
  end;
end;

function TMarkdownPanel.GetRequiredHeight: Integer;
begin
  Result := CalculateTextHeight;
end;

end.