object ErrorDialogForm: TErrorDialogForm
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Error'
  ClientHeight = 200
  ClientWidth = 400
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Roboto Lt'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 14
  object PanelMain: TPanel
    Left = 0
    Top = 0
    Width = 400
    Height = 200
    Align = alClient
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 0
    object PanelIcon: TPanel
      Left = 0
      Top = 0
      Width = 65
      Height = 83
      Align = alLeft
      BevelOuter = bvNone
      ParentBackground = False
      TabOrder = 0
      object ImageIcon: TImage
        Left = 16
        Top = 16
        Width = 32
        Height = 32
        Proportional = True
        Stretch = True
        Transparent = True
      end
    end
    object PanelContent: TPanel
      Left = 65
      Top = 0
      Width = 335
      Height = 83
      Align = alClient
      BevelOuter = bvNone
      ParentBackground = False
      TabOrder = 1
      object LabelTitle: TLabel
        Left = 16
        Top = 16
        Width = 303
        Height = 17
        AutoSize = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
    object PanelButtons: TPanel
      Left = 0
      Top = 83
      Width = 400
      Height = 45
      Align = alBottom
      BevelOuter = bvNone
      ParentBackground = False
      TabOrder = 2
      object ButtonExtra: TButton
        Left = 8
        Top = 10
        Width = 75
        Height = 25
        Caption = 'Details >>'
        TabOrder = 0
        OnClick = ButtonExtraClick
      end
    end
    object PanelExtra: TPanel
      Left = 0
      Top = 128
      Width = 400
      Height = 72
      Align = alBottom
      BevelOuter = bvLowered
      Color = 15790320
      ParentBackground = False
      TabOrder = 3
      Visible = False
      DesignSize = (
        400
        72)
      object MemoExtraInfo: TMemo
        Left = 8
        Top = 8
        Width = 384
        Height = 56
        Anchors = [akLeft, akTop, akRight, akBottom]
        Color = 16316664
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 0
      end
    end
  end
end
