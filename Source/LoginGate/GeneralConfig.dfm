object frmGeneralConfig: TfrmGeneralConfig
  Left = 452
  Top = 340
  ActiveControl = EditMaxConnect
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #22522#26412#35774#32622
  ClientHeight = 318
  ClientWidth = 370
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #23435#20307
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 12
  object GroupBoxNet: TGroupBox
    Left = 8
    Top = 8
    Width = 185
    Height = 113
    Caption = #32593#32476#35774#32622
    TabOrder = 0
    object LabelGateIPaddr: TLabel
      Left = 8
      Top = 20
      Width = 54
      Height = 12
      Caption = #32593#20851#22320#22336':'
    end
    object LabelGatePort: TLabel
      Left = 8
      Top = 44
      Width = 54
      Height = 12
      Caption = #32593#20851#31471#21475':'
    end
    object LabelServerPort: TLabel
      Left = 8
      Top = 92
      Width = 66
      Height = 12
      Caption = #26381#21153#22120#31471#21475':'
    end
    object LabelServerIPaddr: TLabel
      Left = 8
      Top = 68
      Width = 66
      Height = 12
      Caption = #26381#21153#22120#22320#22336':'
    end
    object EditGateIPaddr: TEdit
      Left = 80
      Top = 16
      Width = 97
      Height = 20
      TabOrder = 0
      Text = '127.0.0.1'
    end
    object EditGatePort: TEdit
      Left = 80
      Top = 40
      Width = 41
      Height = 20
      TabOrder = 1
      Text = '7200'
    end
    object EditServerPort: TEdit
      Left = 80
      Top = 88
      Width = 41
      Height = 20
      TabOrder = 2
      Text = '5000'
    end
    object EditServerIPaddr: TEdit
      Left = 80
      Top = 64
      Width = 97
      Height = 20
      TabOrder = 3
      Text = '127.0.0.1'
    end
  end
  object GroupBoxInfo: TGroupBox
    Left = 200
    Top = 8
    Width = 161
    Height = 113
    Caption = #22522#26412#21442#25968
    TabOrder = 1
    object Label1: TLabel
      Left = 8
      Top = 20
      Width = 30
      Height = 12
      Caption = #26631#39064':'
    end
    object LabelShowLogLevel: TLabel
      Left = 8
      Top = 44
      Width = 78
      Height = 12
      Caption = #26174#31034#26085#24535#31561#32423':'
    end
    object Label7: TLabel
      Left = 11
      Top = 91
      Width = 54
      Height = 12
      Caption = #20250#35805#36229#26102':'
    end
    object Label8: TLabel
      Left = 126
      Top = 91
      Width = 12
      Height = 12
      Caption = #31186
    end
    object EditTitle: TEdit
      Left = 40
      Top = 16
      Width = 105
      Height = 20
      TabOrder = 0
      Text = #20919#38632#20256#22855
    end
    object TrackBarLogLevel: TTrackBar
      Left = 8
      Top = 56
      Width = 145
      Height = 25
      TabOrder = 1
    end
    object EditSessionTimeOutTime: TEdit
      Left = 70
      Top = 87
      Width = 51
      Height = 20
      Hint = #23458#25143#31471#26080#25805#20316#36229#36807#35813#26102#38388#13#10#23558#34987#33258#21160#26029#24320#36830#25509#37322#25918#36164#28304
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
      Text = '300'
    end
  end
  object ButtonOK: TButton
    Left = 292
    Top = 284
    Width = 65
    Height = 25
    Caption = #30830#23450'(&O)'
    TabOrder = 2
    OnClick = ButtonOKClick
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 128
    Width = 353
    Height = 81
    Caption = #31471#21475#20445#25252
    TabOrder = 3
    object Label3: TLabel
      Left = 119
      Top = 23
      Width = 42
      Height = 12
      Caption = #36830#25509'/IP'
    end
    object Label2: TLabel
      Left = 8
      Top = 23
      Width = 54
      Height = 12
      Caption = #36830#25509#38480#21046':'
    end
    object Label4: TLabel
      Left = 177
      Top = 23
      Width = 78
      Height = 12
      Caption = #27599'IP'#38388#38548#26102#38388':'
    end
    object Label5: TLabel
      Left = 317
      Top = 23
      Width = 24
      Height = 12
      Caption = #27627#31186
    end
    object Label6: TLabel
      Left = 8
      Top = 52
      Width = 66
      Height = 12
      Caption = #25915#20987'IP'#23558#34987':'
    end
    object EditMaxConnect: TSpinEdit
      Left = 64
      Top = 19
      Width = 49
      Height = 21
      Hint = #21333#20010'IP'#22320#22336','#26368#22810#21487#20197#24314#31435#36830#25509#25968#13#10#36229#36807#25351#23450#36830#25509#25968#23558#25353#25915#20987'IP'#22788#29702
      EditorEnabled = False
      MaxValue = 1000
      MinValue = 0
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      Value = 20
    end
    object RadioAddTempList: TRadioButton
      Left = 150
      Top = 51
      Width = 68
      Height = 17
      Hint = #26029#24320#35813'IP'#30340#25152#26377#36830#25509#13#10#24182#19988#36807#28388#26469#33258#35813'IP'#30340#25152#26377#36830#25509#13#10#32593#20851#37325#36215#21518#36807#28388#33258#21160#21462#28040
      Caption = #20020#26102#36807#28388
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
    end
    object RadioAddBlockList: TRadioButton
      Left = 225
      Top = 51
      Width = 121
      Height = 17
      Hint = 
        #26029#24320#35813'IP'#30340#25152#26377#36830#25509#13#10#24182#19988#36807#28388#26469#33258#35813'IP'#30340#25152#26377#36830#25509#13#10#27492'IP'#23558#34987#21152#20837#21040#27704#20037#36807#28388#25991#20214#13#10'BlockIPList.txt'#20013','#20197#21518#23558 +
        #27704#20037#36807#28388#27492'IP'
      Caption = #21152#20837#27704#20037#36807#34385#25991#20214
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
    end
    object RadioDisConnect: TRadioButton
      Left = 76
      Top = 51
      Width = 71
      Height = 17
      Hint = #21482#26159#26029#24320#24403#21069#30340#36830#25509
      Caption = #26029#24320#36830#25509
      Checked = True
      ParentShowHint = False
      ShowHint = True
      TabOrder = 3
      TabStop = True
    end
    object EditConnSpaceOfIPaddr: TEdit
      Left = 262
      Top = 18
      Width = 49
      Height = 20
      Hint = #21333#20010'IP'#22320#22336#20004#27425#36830#25509#30340#38388#38548#26102#38388#13#10#38388#38548#26102#38388#36807#30701'('#36830#25509#36895#24230#36807#24555')'#23558#25353#25915#20987'IP'#22788#29702
      ParentShowHint = False
      ShowHint = True
      TabOrder = 4
      Text = '500'
    end
  end
  object GroupBox2: TGroupBox
    Left = 8
    Top = 217
    Width = 353
    Height = 57
    Caption = #31192#38053#25991#20214#36335#24452#35774#32622
    TabOrder = 4
    object EditEncKeyFile: TEdit
      Left = 20
      Top = 20
      Width = 313
      Height = 20
      TabOrder = 0
      Text = 'EncKey.txt'
    end
  end
end
