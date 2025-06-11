object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'Signature Self-Check'
  ClientHeight = 220
  ClientWidth = 718
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 21
  object Label1: TLabel
    Left = 16
    Top = 16
    Width = 127
    Height = 21
    Caption = 'Application Name:'
  end
  object Label2: TLabel
    Left = 16
    Top = 56
    Width = 116
    Height = 21
    Caption = 'Signature Status:'
  end
  object Label3: TLabel
    Left = 16
    Top = 96
    Width = 124
    Height = 21
    Caption = 'Certificate Owner:'
  end
  object Label4: TLabel
    Left = 16
    Top = 136
    Width = 118
    Height = 21
    Caption = 'Certificate Issuer:'
  end
  object Label5: TLabel
    Left = 16
    Top = 176
    Width = 80
    Height = 21
    Caption = 'Fingerprint:'
  end
  object lblAppName: TLabel
    Left = 160
    Top = 16
    Width = 534
    Height = 21
    AutoSize = False
  end
  object lblCertStatus: TLabel
    Left = 160
    Top = 56
    Width = 534
    Height = 21
    AutoSize = False
  end
  object lblCertOwner: TLabel
    Left = 160
    Top = 96
    Width = 534
    Height = 21
    AutoSize = False
  end
  object lblCertIssuer: TLabel
    Left = 160
    Top = 136
    Width = 534
    Height = 21
    AutoSize = False
  end
  object lblFingerprint: TLabel
    Left = 160
    Top = 176
    Width = 534
    Height = 21
    AutoSize = False
  end
end
