object ProgressForm: TProgressForm
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'ProgressForm'
  ClientHeight = 140
  ClientWidth = 640
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  TextHeight = 15
  inline ProgressFrame: TProgressFrame
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
