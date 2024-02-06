object frmIDSrvConfig: TfrmIDSrvConfig
  Left = 364
  Top = 232
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #36134#21495#26381#21153#35774#32622
  ClientHeight = 274
  ClientWidth = 254
  Color = clBtnFace
  Font.Charset = GB2312_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #23435#20307
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 12
  object GroupBox1: TGroupBox
    Left = 13
    Top = 32
    Width = 228
    Height = 65
    Caption = ' '#20801#35768#20351#29992#30340#26381#21153' '
    TabOrder = 0
    object C_EnRegUser: TCheckBox
      Left = 16
      Top = 21
      Width = 113
      Height = 17
      Caption = #20801#35768#27880#20876#26032#29992#25143
      TabOrder = 0
    end
    object C_EnModPass: TCheckBox
      Left = 16
      Top = 41
      Width = 97
      Height = 17
      Caption = #20801#35768#20462#25913#23494#30721
      TabOrder = 1
    end
  end
  object GroupBox2: TGroupBox
    Left = 13
    Top = 104
    Width = 228
    Height = 129
    Caption = ' '#25968#25454#24211#37197#32622' '
    TabOrder = 1
    object Label1: TLabel
      Left = 17
      Top = 28
      Width = 48
      Height = 12
      Caption = #26381#21153#22120#65306
    end
    object Label2: TLabel
      Left = 17
      Top = 52
      Width = 48
      Height = 12
      Caption = #25968#25454#24211#65306
    end
    object Label3: TLabel
      Left = 17
      Top = 76
      Width = 48
      Height = 12
      Caption = #29992#25143#21517#65306
    end
    object Label4: TLabel
      Left = 17
      Top = 100
      Width = 48
      Height = 12
      Caption = #23494'  '#30721#65306
    end
    object E_ACCOUNTServer: TEdit
      Left = 73
      Top = 23
      Width = 136
      Height = 20
      TabOrder = 0
    end
    object E_ACCOUNTDB: TEdit
      Left = 73
      Top = 47
      Width = 136
      Height = 20
      TabOrder = 1
    end
    object E_ACCOUNTID: TEdit
      Left = 73
      Top = 71
      Width = 136
      Height = 20
      TabOrder = 2
    end
    object E_ACCOUNTPWS: TEdit
      Left = 73
      Top = 95
      Width = 136
      Height = 20
      PasswordChar = '*'
      TabOrder = 3
    end
  end
  object Button1: TButton
    Left = 170
    Top = 240
    Width = 67
    Height = 25
    Caption = #30830#23450
    TabOrder = 2
    OnClick = Button1Click
  end
  object C_EnableIDSrv: TCheckBox
    Left = 13
    Top = 10
    Width = 121
    Height = 17
    Caption = #21551#29992#36134#21495#26381#21153#31995#32479
    TabOrder = 3
    OnClick = C_EnableIDSrvClick
  end
  object CBNoThisSQL: TCheckBox
    Left = 135
    Top = 10
    Width = 106
    Height = 17
    Caption = #25968#25454#24211#19981#22312#26412#26426
    TabOrder = 4
  end
end
