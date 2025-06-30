object ProgressFrame: TProgressFrame
  Left = 0
  Top = 0
  Width = 640
  Height = 145
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Roboto Lt'
  Font.Style = []
  ParentFont = False
  TabOrder = 0
  object lblProgressTitle: TLabel
    Left = 16
    Top = 16
    Width = 93
    Height = 18
    Caption = 'Your Progress'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Roboto Lt'
    Font.Style = []
    ParentFont = False
  end
  object lblPercentageString: TLabel
    Left = 16
    Top = 40
    Width = 69
    Height = 33
    Caption = '100%'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -27
    Font.Name = 'Roboto Lt'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lblCompletedString: TLabel
    Left = 91
    Top = 46
    Width = 110
    Height = 25
    Caption = 'Completed'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'Roboto Lt'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lblActionString: TLabel
    Left = 16
    Top = 111
    Width = 75
    Height = 18
    Caption = 'Initializing...'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Roboto Lt'
    Font.Style = []
    ParentFont = False
  end
  object pbProgress: TProgressBar
    Left = 16
    Top = 88
    Width = 601
    Height = 17
    Position = 100
    Smooth = True
    Step = 1
    TabOrder = 0
  end
end
