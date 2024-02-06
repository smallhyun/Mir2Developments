object FormMain: TFormMain
  Left = 749
  Top = 335
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'LoginGate'
  ClientHeight = 171
  ClientWidth = 297
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #23435#20307
  Font.Style = []
  Menu = MainMenu
  OldCreateOrder = False
  Position = poDefault
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 12
  object StatusBar: TStatusBar
    Left = 0
    Top = 149
    Width = 297
    Height = 22
    Panels = <
      item
        Alignment = taCenter
        Text = '????'
        Width = 50
      end
      item
        Alignment = taCenter
        Text = #21021#22987#21270
        Width = 80
      end
      item
        Alignment = taCenter
        Text = '????'
        Width = 85
      end
      item
        Alignment = taCenter
        Text = '????'
        Width = 70
      end>
  end
  object MemoLog: TMemo
    Left = 0
    Top = 0
    Width = 297
    Height = 149
    Align = alClient
    ReadOnly = True
    TabOrder = 0
    OnChange = MemoLogChange
  end
  object ClientSocket: TClientSocket
    Active = False
    ClientType = ctNonBlocking
    Port = 0
    OnConnect = ClientSocketConnect
    OnDisconnect = ClientSocketDisconnect
    OnRead = ClientSocketRead
    OnError = ClientSocketError
  end
  object ServerSocket: TServerSocket
    Active = False
    Port = 0
    ServerType = stNonBlocking
    OnClientConnect = ServerSocketClientConnect
    OnClientDisconnect = ServerSocketClientDisconnect
    OnClientRead = ServerSocketClientRead
    OnClientError = ServerSocketClientError
    Left = 32
  end
  object MainMenu: TMainMenu
    Left = 192
    object N1: TMenuItem
      Caption = #25511#21046'(&C)'
      object N_Start: TMenuItem
        Caption = #21551#21160#26381#21153'(&S)'
        OnClick = N_StartClick
      end
      object N_Stop: TMenuItem
        Caption = #20572#27490#26381#21153'(&T)'
        OnClick = N_StopClick
      end
      object N_ReConnect: TMenuItem
        Caption = #21047#26032#36830#25509'(&R)'
        OnClick = N_ReConnectClick
      end
      object N_ReLoadConfig: TMenuItem
        Caption = #37325#21152#36733#37197#32622'(&R)'
        OnClick = N_ReLoadConfigClick
      end
      object N_CleaeLog: TMenuItem
        Caption = #28165#38500#26085#24535'(&C)'
        OnClick = N_CleaeLogClick
      end
      object N_Exit: TMenuItem
        Caption = #36864#20986'(&E)'
        OnClick = N_ExitClick
      end
    end
    object O1: TMenuItem
      Caption = #36873#39033'(&O)'
      object N_General: TMenuItem
        Caption = #22522#26412#35774#32622'(&G)'
        OnClick = N_GeneralClick
      end
      object N_RegSet: TMenuItem
        Caption = #24080#21495#26381#21153#35774#32622'(&Z)'
        OnClick = N_RegSetClick
      end
    end
  end
  object StartTimer: TTimer
    Interval = 200
    OnTimer = StartTimerTimer
    Left = 64
  end
  object DecodeTimer: TTimer
    Interval = 1
    OnTimer = DecodeTimerTimer
    Left = 96
  end
  object SendTimer: TTimer
    Enabled = False
    Interval = 5000
    OnTimer = SendTimerTimer
    Left = 128
  end
  object Timer: TTimer
    OnTimer = TimerTimer
    Left = 160
  end
end
