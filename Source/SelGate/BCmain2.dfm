object FrmMain: TFrmMain
  Left = 470
  Top = 290
  Caption = 'Sel Chr Gate'
  ClientHeight = 223
  ClientWidth = 312
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Memo: TMemo
    Left = 0
    Top = 0
    Width = 312
    Height = 142
    Align = alClient
    ImeName = #33540#24811#32482'('#33540#33218') (MS-IME95)'
    ScrollBars = ssVertical
    TabOrder = 0
    OnChange = MemoChange
    OnDblClick = MemoDblClick
  end
  object Panel1: TPanel
    Left = 0
    Top = 142
    Width = 312
    Height = 81
    Align = alBottom
    BevelOuter = bvNone
    Caption = ' '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = #23435#20307
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    object Label1: TLabel
      Left = 5
      Top = 9
      Width = 66
      Height = 12
      Caption = 'Connections'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = #23435#20307
      Font.Style = []
      ParentFont = False
    end
    object LbConStatue: TLabel
      Left = 130
      Top = 8
      Width = 6
      Height = 12
      Caption = ' '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = #23435#20307
      Font.Style = []
      ParentFont = False
    end
    object LbHold: TLabel
      Left = 98
      Top = 9
      Width = 6
      Height = 12
      Caption = ' '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = #23435#20307
      Font.Style = []
      ParentFont = False
    end
    object LbLack: TLabel
      Left = 180
      Top = 30
      Width = 18
      Height = 12
      Caption = '0/0'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = #23435#20307
      Font.Style = []
      ParentFont = False
    end
    object Label2: TLabel
      Left = 184
      Top = 10
      Width = 36
      Height = 12
      Caption = 'Label2'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = #23435#20307
      Font.Style = []
      ParentFont = False
    end
    object EdUserCount: TEdit
      Left = 77
      Top = 5
      Width = 28
      Height = 20
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = #23435#20307
      Font.Style = []
      ImeName = #33540#24811#32482'('#33540#33218') (MS-IME95)'
      ParentFont = False
      ReadOnly = True
      TabOrder = 0
      Text = ' '
    end
    object BtnRun: TButton
      Left = 136
      Top = 28
      Width = 35
      Height = 21
      Caption = 'Run'
      Default = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = #23435#20307
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      OnClick = BtnRunClick
    end
    object CbAddrs: TComboBox
      Left = 8
      Top = 28
      Width = 121
      Height = 20
      Style = csDropDownList
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = #23435#20307
      Font.Style = []
      ImeName = #33540#24811#32482'('#33540#33218') (MS-IME95)'
      ParentFont = False
      TabOrder = 2
      OnChange = CbAddrsChange
    end
    object CbShowMessages: TCheckBox
      Left = 8
      Top = 54
      Width = 97
      Height = 17
      Caption = 'Show Messages'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = #23435#20307
      Font.Style = []
      ParentFont = False
      TabOrder = 3
    end
  end
  object ServerSocket: TServerSocket
    Active = False
    Port = 0
    ServerType = stNonBlocking
    OnClientConnect = ServerSocketClientConnect
    OnClientDisconnect = ServerSocketClientDisconnect
    OnClientRead = ServerSocketClientRead
    OnClientError = ServerSocketClientError
    Left = 40
    Top = 16
  end
  object SendTimer: TTimer
    Enabled = False
    Interval = 3000
    OnTimer = SendTimerTimer
    Left = 72
    Top = 16
  end
  object ClientSocket: TClientSocket
    Active = False
    ClientType = ctNonBlocking
    Port = 0
    OnConnect = ClientSocketConnect
    OnDisconnect = ClientSocketDisconnect
    OnRead = ClientSocketRead
    OnError = ClientSocketError
    Left = 8
    Top = 16
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 104
    Top = 16
  end
  object DecodeTimer: TTimer
    Interval = 1
    OnTimer = DecodeTimerTimer
    Left = 144
    Top = 16
  end
end
