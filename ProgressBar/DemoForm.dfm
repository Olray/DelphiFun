object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 277
  ClientWidth = 871
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object Button1: TButton
    Left = 240
    Top = 24
    Width = 185
    Height = 25
    Caption = 'Run in TForm'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 448
    Top = 24
    Width = 185
    Height = 25
    Caption = 'Run in Window'
    TabOrder = 1
    OnClick = Button2Click
  end
  inline ProgressFrame1: TProgressFrame
    Left = 127
    Top = 96
    Width = 640
    Height = 145
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Roboto Lt'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    ExplicitLeft = 127
    ExplicitTop = 96
    inherited lblProgressTitle: TLabel
      StyleElements = [seFont, seClient, seBorder]
    end
    inherited lblPercentageString: TLabel
      StyleElements = [seFont, seClient, seBorder]
    end
    inherited lblCompletedString: TLabel
      StyleElements = [seFont, seClient, seBorder]
    end
    inherited lblActionString: TLabel
      StyleElements = [seFont, seClient, seBorder]
    end
  end
end
