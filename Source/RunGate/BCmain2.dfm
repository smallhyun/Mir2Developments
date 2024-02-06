object FrmMain: TFrmMain
  Left = 861
  Top = 519
  Caption = 'RunGate (Max=1000)'
  ClientHeight = 226
  ClientWidth = 268
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = #23435#20307
  Font.Style = []
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 11
  object Memo: TMemo
    Left = 0
    Top = 0
    Width = 268
    Height = 118
    Align = alClient
    ImeName = #33540#24811#32482'('#33540#33218') (MS-IME95)'
    TabOrder = 0
    OnChange = MemoChange
    OnDblClick = MemoDblClick
  end
  object Panel1: TPanel
    Left = 0
    Top = 118
    Width = 268
    Height = 108
    Align = alBottom
    BevelOuter = bvNone
    Caption = ' '
    TabOrder = 1
    object Label1: TLabel
      Left = 5
      Top = 6
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
      Left = 126
      Top = 5
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
      Left = 109
      Top = 6
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
      Top = 57
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
      Left = 4
      Top = 36
      Width = 69
      Height = 17
      AutoSize = False
      Caption = '-----'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = #23435#20307
      Font.Style = []
      ParentFont = False
    end
    object Label3: TLabel
      Left = 68
      Top = 36
      Width = 69
      Height = 17
      AutoSize = False
      Caption = '-----'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = #23435#20307
      Font.Style = []
      ParentFont = False
    end
    object Label4: TLabel
      Left = 132
      Top = 36
      Width = 117
      Height = 17
      AutoSize = False
      Caption = '-----'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = #23435#20307
      Font.Style = []
      ParentFont = False
    end
    object Label5: TLabel
      Left = 212
      Top = 5
      Width = 36
      Height = 12
      Alignment = taRightJustify
      Caption = 'Label5'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = #23435#20307
      Font.Style = []
      ParentFont = False
      OnDblClick = Label5DblClick
    end
    object Label6: TLabel
      Left = 8
      Top = 77
      Width = 24
      Height = 12
      Caption = 'Port'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = #23435#20307
      Font.Style = []
      ParentFont = False
    end
    object LbPort: TLabel
      Left = 32
      Top = 77
      Width = 33
      Height = 16
      Caption = '1000'
      Color = clBtnFace
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentColor = False
      ParentFont = False
    end
    object Label7: TLabel
      Left = 212
      Top = 21
      Width = 36
      Height = 12
      Alignment = taRightJustify
      Caption = 'Label5'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = #23435#20307
      Font.Style = []
      ParentFont = False
      OnDblClick = Label5DblClick
    end
    object EdUserCount: TEdit
      Left = 72
      Top = 2
      Width = 29
      Height = 20
      Color = clWhite
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
      OnDblClick = EdUserCountDblClick
    end
    object BtnRun: TButton
      Left = 136
      Top = 52
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
      Top = 52
      Width = 121
      Height = 20
      Style = csDropDownList
      Color = clLime
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
    object CbDisplay: TCheckBox
      Left = 120
      Top = 76
      Width = 105
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
    object CbShowSocData: TCheckBox
      Left = 120
      Top = 92
      Width = 121
      Height = 17
      Caption = 'Show SocketRead'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = #23435#20307
      Font.Style = []
      ParentFont = False
      TabOrder = 4
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
    Left = 32
    Top = 40
  end
  object SendTimer: TTimer
    Enabled = False
    Interval = 5000
    OnTimer = SendTimerTimer
    Left = 64
    Top = 40
  end
  object ClientSocket: TClientSocket
    Active = False
    ClientType = ctNonBlocking
    Port = 0
    OnConnect = ClientSocketConnect
    OnDisconnect = ClientSocketDisconnect
    OnRead = ClientSocketRead
    OnError = ClientSocketError
    Top = 40
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 96
    Top = 40
  end
  object DecodeTimer: TTimer
    Interval = 1
    OnTimer = DecodeTimerTimer
    Left = 128
    Top = 40
  end
end
