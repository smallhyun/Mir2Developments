object FrmMain: TFrmMain
  Left = 674
  Top = 261
  Caption = 'FrmMain'
  ClientHeight = 390
  ClientWidth = 365
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = 0
    Top = 0
    Width = 365
    Height = 282
    Align = alClient
    ImeName = #33540#24811#32482'('#33540#33218') (MS-IME95)'
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object Panel1: TPanel
    Left = 0
    Top = 282
    Width = 365
    Height = 108
    Align = alBottom
    BevelOuter = bvNone
    Caption = ' '
    TabOrder = 1
    OnDblClick = Panel1DblClick
    object LbRunTime: TLabel
      Left = 160
      Top = 0
      Width = 55
      Height = 13
      Caption = 'LbRunTime'
    end
    object LbUserCount: TLabel
      Left = 319
      Top = 0
      Width = 28
      Height = 13
      Alignment = taRightJustify
      Caption = 'Count'
    end
    object Label1: TLabel
      Left = 0
      Top = 0
      Width = 32
      Height = 13
      Caption = 'Label1'
    end
    object Label2: TLabel
      Left = 0
      Top = 13
      Width = 32
      Height = 13
      Caption = 'Label2'
    end
    object Label3: TLabel
      Left = 0
      Top = 55
      Width = 365
      Height = 53
      Align = alBottom
      AutoSize = False
      Caption = 'Label3'
      Color = clBtnShadow
      ParentColor = False
      WordWrap = True
    end
    object Label4: TLabel
      Left = 0
      Top = 42
      Width = 200
      Height = 13
      Caption = '** B-Count/Remain SendBytes SendCount'
      Color = clBtnShadow
      ParentColor = False
    end
    object LbTimeCount: TLabel
      Left = 204
      Top = 42
      Width = 63
      Height = 13
      Caption = 'LbTimeCount'
    end
    object Label5: TLabel
      Left = 0
      Top = 26
      Width = 32
      Height = 13
      Caption = 'Label5'
    end
    object Panel2: TPanel
      Left = 298
      Top = 35
      Width = 49
      Height = 20
      BevelOuter = bvLowered
      Caption = 'Panel2'
      TabOrder = 0
      object SpeedButton1: TSpeedButton
        Left = 3
        Top = 2
        Width = 43
        Height = 16
        Caption = 'Initialize'
        OnClick = SpeedButton1Click
      end
    end
  end
  object GateSocket: TServerSocket
    Active = False
    Port = 5000
    ServerType = stNonBlocking
    OnClientConnect = GateSocketClientConnect
    OnClientDisconnect = GateSocketClientDisconnect
    OnClientRead = GateSocketClientRead
    OnClientError = GateSocketClientError
    Left = 21
    Top = 47
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 2000
    OnTimer = Timer1Timer
    Left = 57
    Top = 47
  end
  object RunTimer: TTimer
    Enabled = False
    Interval = 1
    OnTimer = RunTimerTimer
    Left = 93
    Top = 47
  end
  object DBSocket: TClientSocket
    Active = False
    ClientType = ctNonBlocking
    Port = 6000
    OnConnect = DBSocketConnect
    OnDisconnect = DBSocketDisconnect
    OnRead = DBSocketRead
    OnError = DBSocketError
    Left = 21
    Top = 83
  end
  object ConnectTimer: TTimer
    Enabled = False
    Interval = 30000
    OnTimer = ConnectTimerTimer
    Left = 57
    Top = 83
  end
  object StartTimer: TTimer
    Enabled = False
    Interval = 100
    OnTimer = StartTimerTimer
    Left = 129
    Top = 47
  end
  object SaveVariableTimer: TTimer
    Interval = 10000
    OnTimer = SaveVariableTimerTimer
    Left = 169
    Top = 47
  end
  object TCloseTimer: TTimer
    Enabled = False
    Interval = 100
    OnTimer = TCloseTimerTimer
    Left = 93
    Top = 83
  end
  object LogUDP: TIdUDPClient
    Port = 0
    Left = 129
    Top = 83
  end
  object MainMenu1: TMainMenu
    Left = 169
    Top = 83
    object N1: TMenuItem
      Caption = #25511#21046
      object N7: TMenuItem
        Caption = #21551#21160#26381#21153
      end
      object N8: TMenuItem
        Caption = #20572#27490#26381#21153
      end
      object N9: TMenuItem
        Caption = #28165#38500#26085#24535
      end
      object N10: TMenuItem
        Caption = #37325#26032#21152#36733
        object NPC1: TMenuItem
          Caption = #25152#26377'NPC'
        end
        object NPC2: TMenuItem
          Caption = #40664#35748'NPC'
        end
        object N11: TMenuItem
          Caption = #25216#33021#25968#25454#24211
        end
        object N12: TMenuItem
          Caption = #24618#29289#25968#25454#24211
        end
        object N13: TMenuItem
          Caption = #29289#21697#25968#25454#24211
        end
        object N15: TMenuItem
          Caption = #24618#29289#29190#29575#33050#26412
        end
        object N17: TMenuItem
          Caption = #25481#33853#25552#31034#33050#26412
        end
        object N16: TMenuItem
          Caption = #31649#29702#20154#21592#21517#21333
        end
        object N14: TMenuItem
          Caption = #27801#22478#37197#32622#25991#20214
        end
      end
    end
    object N2: TMenuItem
      Caption = #26597#30475
      object N18: TMenuItem
        Caption = #22312#32447#20154#29289
      end
    end
    object N3: TMenuItem
      Caption = #36873#39033
      object N19: TMenuItem
        Caption = #21442#25968#35774#32622
      end
      object N20: TMenuItem
        Caption = #21151#33021#35774#32622
      end
    end
    object N4: TMenuItem
      Caption = #31649#29702
      object N21: TMenuItem
        Caption = #22312#32447#28040#24687
      end
      object N22: TMenuItem
        Caption = #22478#22561#31649#29702
      end
    end
    object N5: TMenuItem
      Caption = #24037#20855
      object N23: TMenuItem
        Caption = #22320#21306#26597#35810
      end
    end
    object N6: TMenuItem
      Caption = #24110#21161
      object N24: TMenuItem
        Caption = #20851#20110
      end
    end
  end
end
