unit HGEGUI;

interface

uses

  System.Classes, System.SysUtils, System.StrUtils, System.Math,
  Winapi.Windows, Winapi.Messages, Winapi.Imm, Winapi.DirectShow9, Winapi.ActiveX, Winapi.Direct3D9,
  Vcl.Graphics, Vcl.StdCtrls, Vcl.Controls, Vcl.Forms, Vcl.ComCtrls, Vcl.Grids, Vcl.Clipbrd,
  HGE, HGEBase, HGECanvas, HGETextures, HGEUtils,
  Vectors2px, WIL;

const
//  AllowedChars = [#$0020..#$007F, #$0080..#$00FE, #$4E00..#$9FA5];  //所有
//  AllowedIntegerChars = [#$0030..#$0039];  //数值
//  AllowedEnglishChars = [#$0021..#$007E];  //英文
//  AllowedStandard = [#$0030..#$0039, #$0041..#$005A, #$0061..#$007A, #$4E00..#$9FA5];  //标准中文
//  AllowedCDKey = [#$0030..#$0039, #$0041..#$005A, #$005F, #$0061..#$007A]; //密钥

  LineSpace = 2;
  LineSpace2 = 8;
  DECALW = 6;
  DECALH = 4;

  WINLEFT = 60;
  WINTOP = 60;

type
  TLibFile = (nill, Prguse_Pak, Prguse_16_Pak, Prguse, Prguse2, Prguse3, ui1, ui3, ui_common, ui_n, ChrSel, nselect);

  TDEditClass = (deNone, deInteger, deMonoCase, deChinese, deStandard, deEnglishAndInt, deCDKey);
  TDBtnState = (tnor, tdown, tmove, tdisable);

  TMouseEntry = (msIn, msOut);
  TDControlStyle = (dsNone, dsTop, dsBottom);
  TClickSound = (csNone, csStone, csGlass, csNorm);

  TDrawDirection = (dbdLeft, dbdRight, dbdTop, dbdBottom);
  TDrawBarMode = (dbmNone, dbmLeft, dbmRight);
  TClipBarType = (ctNone, ctHp, ctMP, ctExp, ctWeight, ctVigour, ctHeroEnergy, ctDynamicValue); // 裁剪类型

  TMouseWheel = (mw_Down, mw_Up);

  TCustomDXPropertites = class;
  TDControl = class;

  TOnDirectPaint = procedure(Sender: TObject; dsurface: TDXTexture) of object;

  TOnKeyPress = procedure(Sender: TObject; var Key: Char) of object;

  TOnKeyDown = procedure(Sender: TObject; var Key: Word; Shift: TShiftState) of object;

  TOnKeyUp = procedure(Sender: TObject; var Key: word; Shift: TShiftState) of object;

  TOnMouseMove = procedure(Sender: TObject; Shift: TShiftState; X, Y: Integer) of object;

  TOnMouseDown = procedure(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer) of object;

  TOnMouseUp = procedure(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer) of object;

  TOnClick = procedure(Sender: TObject) of object;

  TOnVisible = procedure(Sender: TObject; boVisible: Boolean) of object;

  TOnClickEx = procedure(Sender: TObject; X, Y: Integer) of object;

  TOnInRealArea = procedure(Sender: TObject; X, Y: Integer; var IsRealArea: Boolean) of object;

  TOnGridSelect = procedure(Sender: TObject; ACol, ARow: Integer; Shift: TShiftState) of object;

  TOnGridPaint = procedure(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState; dsurface: TDXTexture) of object;

  TOnClickSound = procedure(Sender: TObject; Clicksound: TClickSound) of object;

  TOnMouseEntry = procedure(Sender: TObject; MouseEntry: TMouseEntry) of object;

  TOnCheckItem = procedure(Sender: TObject; ItemIndex: Integer; var ItemName: string) of object;

  TOnDrawEditImage = procedure(Sender: TObject; ImageSurface: TDXTexture; Rect: TRect; ImageIndex: Integer) of object;

  TOnTextChanged = procedure(Sender: TObject; sText: string) of object;

  TOnChangeSelect = procedure(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer) of object;

  TOnMouseMoveSelect = procedure(Sender: TObject; Shift: TShiftState; X, Y: Integer) of object;

  TOnAniDirectPaint = procedure(Sender: TObject) of object;

  TOnGetClipValue = procedure(clType: TClipBarType; var MinValue, MaxValue: Int64);

  //自定义UI相关
  TUITraceProc = procedure(Sender: TDControl);
  TOnControlPostionChange = procedure(Sender: TDControl) of object;

  //属性变量相关
  TOnGetTextVar = procedure(var Text: string);


  //全局组件的标题信息
  TDXCaption = class(TPersistent)
  private
    FOwner: TCustomDXPropertites;
    function getCaption(): string;
    procedure setCaption(const s: string);
    function GetColor(Index: Integer): TColor;
    procedure SetColor(Index: Integer; Value: TColor);
    function GetDrawVisable(): Boolean;
    procedure SetDrawVisable(Value: Boolean);
    function getText: string;
    procedure setText(const Value: string);
  public
    constructor Create(Propertites: TCustomDXPropertites); {virtual; }
    property DefaultColor: TColor index 1 read GetColor write SetColor;
    property MoveColor: TColor index 2 read GetColor write SetColor;
    property DownColor: TColor index 3 read GetColor write SetColor;
    property EnabledColor: TColor index 4 read GetColor write SetColor;
    property BackColor: TColor index 5 read GetColor write SetColor;
    property Visable: Boolean read GetDrawVisable write SetDrawVisable;
    property Text: string read getText write setText;
  published
    property Title: string read getCaption write setCaption; //标题只读取不更改
  end;

  //TDButton按钮的标题信息
  TDXButtonCaption = class(TDXCaption)
  published
    property DefaultColor;
    property MoveColor;
    property DownColor;
    property EnabledColor;
    property BackColor;
    property Text;
    property Visable;
  end;

  //TDLabel的标题信息
  TDXLabelCaption = class(TDXCaption)
  published
    property DefaultColor;
    property BackColor;
    property Text;
  end;

  // 组件的位置信息
  TDXPosition = class(TPersistent)
  private
    FOwner: TCustomDXPropertites;
    procedure SetPosition(index: integer; Size: integer);
    function GetPostion(Index: integer): integer;
    function GetAnchor(index: Integer): Single;
    procedure SetAnchor(index: Integer; Value: Single);
    function GetAnchorPostion(): Boolean;
    procedure SetAnchorPoint(Value: Boolean);
  published
    property Left: integer index 1 read GetPostion write SetPosition;
    property Top: integer index 2 read GetPostion write SetPosition;
    property Width: integer index 3 read GetPostion write SetPosition;
    property Height: integer index 4 read GetPostion write SetPosition;
    property AnchorX: Single index 1 read GetAnchor write SetAnchor;
    property AnchorY: Single index 2 read GetAnchor write SetAnchor;
    property AnchorPx: Single Index 3 read GetAnchor write SetAnchor;
    property AnchorPy: Single index 4 read GetAnchor write SetAnchor;
    property AnchorPosition: Boolean read GetAnchorPostion write SetAnchorPoint;

  end;

  // Lib 图库文件
  TDXImageProperty = class(TPersistent)
  private
    FOwner: TCustomDXPropertites;

    function GetProperty(Index: integer): integer;
    procedure SetProperty(Index: integer; Value: integer);
    procedure SetLib(const Value: TLibFile);
    function GetLib(): TLibFile;
    procedure SetAniLoop(const Value: Boolean);
    function GetAniLoop(): Boolean;
    function GetDrawDirection: TDrawDirection;
    function GetDrawMode: TDrawMode;
    procedure SetDrawDirection(const Value: TDrawDirection);
    procedure SetDrawMode(const Value: TDrawMode);
    function GetClipBarType: TClipBarType;
    procedure SetClipBarType(const Value: TClipBarType);
    function GetOffsetX: Integer;
    function GetOffsetY: Integer;
    procedure SetOffsetX(const Value: Integer);
    procedure SetOffsetY(const Value: Integer);
  public
    constructor Create(Propertites: TCustomDXPropertites);
    property ImageIndex: integer index 1 read GetProperty write SetProperty;
    property DownedIndex: integer index 2 read GetProperty write SetProperty;
    property MoveIndex: integer index 3 read GetProperty write SetProperty;
    property DisabledIndex: integer index 4 read GetProperty write SetProperty;
    property CheckedIndex: integer index 5 read GetProperty write SetProperty;

    property OffsetX: Integer read GetOffsetX write SetOffsetX;
    property OffsetY: Integer read GetOffsetY write SetOffsetY;
    //动态图片按钮
    property AniCount: integer index 6 read GetProperty write SetProperty;
    property AniInterval: integer index 7 read GetProperty write SetProperty;
    property AniLoop: Boolean read GetAniLoop write SetAniLoop;


    //图片绘制模式
    property DrawMode: TDrawMode read GetDrawMode write SetDrawMode;

    property DrawDirection: TDrawDirection read GetDrawDirection write SetDrawDirection;
    property ClipType: TClipBarType read GetClipBarType write SetClipBarType;
  published
    property LibFile: TLibFile read GetLib write SetLib default nill;
  end;

  //TWindow图库文件
  TDXWindowImageProperty = class(TDXImageProperty)
  published
    property ImageIndex;
    property DrawMode;
  end;

  //TButton图库文件
  TDXButtonImageProperty = class(TDXImageProperty)
  published
    property ImageIndex;
    property MoveIndex;
    property DownedIndex;
    property DisabledIndex;
    property DrawMode;
  end;

  //TDLabel图库文件
  TDXLabelImageProperty = class(TDXImageProperty)
  published
    property ImageIndex;
    property DrawMode;
  end;


  //进度条文件
  TDXWindowImageBarProperty = class(TDXImageProperty)
  published
    property ImageIndex;
    property OffsetX;
    property OffsetY;
    property AniCount;
    property AniInterval;
    property DrawMode;
    property ClipType;
    property DrawDirection;
  end;

  //动画图库文件
  TDXAniButtonImageProperty = class(TDXImageProperty)
  published
    property ImageIndex;
    property OffsetX;
    property OffsetY;
    property AniCount;
    property AniInterval;
    property AniLoop;
    property DrawMode;
  end;

  // TDCheckBox组件
  TDXCheckBoxImageProperty = class(TDXImageProperty)
  published
    property ImageIndex;
    property CheckedIndex;
    property DrawMode;
  end;

  //TDImageEdit图库文件
  TDXImageEditProperty = class(TDXImageProperty)
  published
    property ImageIndex;
    property DrawMode;
  end;

  //TDEdit图库文件
  TDXEditProperty = class(TDXImageProperty)
  published
    property ImageIndex;
    property DrawMode;
  end;

  //TDUpDownButton图库文件
  TDXUpDownButtonProperty = class(TDXImageProperty)
  published
    property ImageIndex;
    property DrawMode;
  end;

  //TDUpDown图库文件
  TDXUpDownProperty = class(TDXImageProperty)
  published
    property ImageIndex;
    property DrawMode;
  end;


  //自定义全局属性结构
  TCustomDXPropertites = class(TPersistent)
  private
    FCaption: TDXCaption;
    FBtnCaption: TDXButtonCaption;
    FLabelCaption: TDXLabelCaption;
    FControlPosition: TDXPosition;
    FLeft: integer;
    FTop: integer;
    FWidth: integer;
    FHeight: integer;
    FSound: TClickSound;
    //FAniLoop: Boolean; // 动画是否循环
    procedure SetPosition(index: integer; Size: integer);
    procedure SetImageIndex(Index: integer; const Value: integer);
    function GetPostion(Index: integer): integer;
    function GetImageIndex(Index: integer): integer;
    function GetDXImage(): TDXImageProperty;
    function GetVisable(): Boolean;
    procedure SetVisable(Value: Boolean);
    function GetFloating(): Boolean;
    procedure SetFloating(Value: Boolean);
    function GetEscExit(): Boolean;
    procedure SetEscExit(Value: Boolean);
    function GetMouseThrough(): Boolean;
    procedure SetMouseThrough(Value: Boolean);
    function GetAniLoop(): Boolean;
    procedure SetAniLoop(Value: Boolean);
    function GetDrawMode: TDrawMode;
    procedure SetDrawMode(const Value: TDrawMode);
    function GetDrawBarMode: TDrawBarMode;
    function GetDrawDirection: TDrawDirection;
    procedure SetDrawBarMode(const Value: TDrawBarMode);
    procedure SetDrawDirection(const Value: TDrawDirection);
    function GetClipBarType: TClipBarType;
    procedure SetClipBarType(const Value: TClipBarType);
    function GetOffsetX: Integer;
    function GetOffsetY: Integer;
    procedure SetOffsetX(const Value: Integer);
    procedure SetOffsetY(const Value: Integer);
    function GetLib: TLibFile;
    procedure SetLib(const Value: TLibFile);
  protected
    FControl: TDControl;
  public
    constructor Create(AControl: TDControl); virtual;  //构造
    destructor Destroy(); override; //析构
    property Caption: TDXCaption read FCaption write FCaption;
    property CaptionBtn: TDXButtonCaption read FBtnCaption write FBtnCaption;
    property LabelCaption: TDXLabelCaption read FLabelCaption write FLabelCaption;
    property Position: TDXPosition read FControlPosition;
    property ImageProperty: TDXImageProperty read GetDXImage;

    property Left: integer index 1 read GetPostion write SetPosition;
    property Top: integer index 2 read GetPostion write SetPosition;
    property Width: integer index 3 read GetPostion write SetPosition;
    property Height: integer index 4 read GetPostion write SetPosition;
    property MouseThrough: Boolean read GetMouseThrough write SetMouseThrough;
    property AniLoop: Boolean read GetAniLoop write SetAniLoop;

    property DrawDirection: TDrawDirection read GetDrawDirection write SetDrawDirection;
    property DrawBarMode: TDrawBarMode read GetDrawBarMode write SetDrawBarMode;

    //这部分等待重构
    property Sound: TClickSound read FSound write FSound;    //音效
    property Visible: Boolean read GetVisable write SetVisable stored false;  //这个会导致UI编辑器无法修改是否可视 但是如果不这样 在运行期修改的界面在载入UI也会被修改。
    property Floating: Boolean read GetFloating write SetFloating;  //窗口浮动  只有TDWINDOS支持
    property EscExit: Boolean read GetEscExit write SetEscExit;   //是否Esc关闭窗口  只有TDWINDOS支持


  end;


  TColors = class(TGraphicsObject)
  private
    FDisabled: TColor;
    FBkgrnd: TColor;
    FSelected: TColor;
    FBorder: TColor;
    FFont: TColor;
    FHot: TColor;
    FDown: TColor;
    FLine: TColor;
    FUp: TColor;
  public
    constructor Create();
  published
    property Disabled: TColor read FDisabled write FDisabled;
    property Background: TColor read FBkgrnd write FBkgrnd;
    property Selected: TColor read FSelected write FSelected;
    property Border: TColor read FBorder write FBorder;
    property Font: TColor read FFont write FFont;
    property Up: TColor read FUp write FUp;
    property Hot: TColor read FHot write FHot;
    property Down: TColor read FDown write FDown;
    property Line: TColor read FLine write FLine;
  end;


  TDXButtonPropertites = class(TCustomDXPropertites)
  published
    property CaptionBtn;
    property Position;
    property ImageProperty;
    property MouseThrough;
    property Sound;
//    property Hint;
//    property ShowHint;

//    property EnableFocus;
//    property DAnchors;
//    property OwnerScene;
//    property IntoSceneShow;
//    property OutSceneHide;
//    property Right;
//    property Bottom;
//    property BorderColor;
    property Visible;
  end;

    //进度条文件
  TDXWindowImageBarPropertites = class(TCustomDXPropertites)
  published
    property CaptionBtn;
    property Position;
    property ImageProperty;
    property MouseThrough;
    property DrawBarMode;
    property Visible;
  end;

  //迷你Map
  TDXWindowMiniMapPropertites = class(TCustomDXPropertites)
  private
    function GetRound: Boolean;
    procedure SetRound(const Value: Boolean);
  published
    property Caption;
    property Position;
    property ImageProperty;
    property Round: Boolean read GetRound write SetRound;
    property Visible;
  end;

  TDXAniButtonPropertites = class(TCustomDXPropertites)
  published
    property Caption;
    property Position;
    property ImageProperty;
    property MouseThrough;
    property Sound;
//    property Hint;
//    property ShowHint;

//    property EnableFocus;
//    property DAnchors;
//    property OwnerScene;
//    property IntoSceneShow;
//    property OutSceneHide;
//    property Right;
//    property Bottom;
//    property BorderColor;
    property Visible;
  end;

  TDXLabelPropertites = class(TCustomDXPropertites)
  published
    property LabelCaption;
    property Position;
    property ImageProperty;
    property MouseThrough;
//    property Sound;
//    property Hint;
//    property ShowHint;

//    property EnableFocus;
//    property DAnchors;
//    property OwnerScene;
//    property IntoSceneShow;
//    property OutSceneHide;
//    property Right;
//    property Bottom;
//    property BorderColor;
    property Visible;
  end;

  //游戏窗口
  TDXWindowPropertites = class(TCustomDXPropertites)
  published
    property Caption;
    property Position;
    property ImageProperty;
    property MouseThrough;
    property EscExit;
    property Floating;
    property Visible;
  end;

  //9宫格
  TDXWindowImageGridPropertites = class(TCustomDXPropertites)
  private
    function GetRelative(const Index: Integer): Integer;
    function GetStretch: Boolean;
    procedure SetRelative(const Index, Value: Integer);
    procedure SetStretch(const Value: Boolean);
  published
    property Caption;
    property Position;
    property ImageProperty;

    property Stretch: Boolean read GetStretch write SetStretch;
    property RelativeLeft: Integer index 1 read GetRelative write SetRelative;
    property RelativeTop: Integer index 2 read GetRelative write SetRelative;
    property RelativeRight: Integer index 3 read GetRelative write SetRelative;
    property RelativeBottom: Integer index 4 read GetRelative write SetRelative;

    property MouseThrough;
    property EscExit;
    property Floating;
    property Visible;
  end;

  //Edit
  TDXEditPropertites = class(TCustomDXPropertites)
  private
    function GetFrameColor(const Index: Integer): TColor;
    function GetTransparent: Boolean;
    procedure SetFrameColor(const Index: Integer; Value: TColor);
    procedure SetTransparent(const Value: Boolean);
  published
    property CaptionBtn;
    property Position;
    property ImageProperty;

    property FrameColor: TColor index 1 read GetFrameColor write SetFrameColor;
    property FrameBackColor: TColor index 2 read GetFrameColor write SetFrameColor;
    property Transparent: Boolean read GetTransparent write SetTransparent;

    property MouseThrough;
    property Visible;
  end;

  //动画Edit
  TDXImageEditPropertites = class(TCustomDXPropertites)
  private
    function GetFrameColor(const Index: Integer): TColor;
    function GetTransparent: Boolean;
    procedure SetFrameColor(const Index: Integer; Value: TColor);
    procedure SetTransparent(const Value: Boolean);
  published
    property CaptionBtn;
    property Position;
    property ImageProperty;

    property FrameColor: TColor index 1 read GetFrameColor write SetFrameColor;
    property FrameBackColor: TColor index 2 read GetFrameColor write SetFrameColor;
    property Transparent: Boolean read GetTransparent write SetTransparent;

    property MouseThrough;
    property Sound;
    property Visible;
  end;

  //滚动条按钮
  TDXUpDownButtonPropertites = class(TCustomDXPropertites)
  private

  published
    property Caption;
    property ImageProperty;
    property Sound;
  end;

  //滚动条
  TDXUpDownPropertites = class(TCustomDXPropertites)
  private
    function GetProperty(const Index: Integer): Integer;
    procedure SetProperty(const Index, Value: Integer);
  published
    property Caption;
    property Position;
    property ImageProperty;

    property ImageUpIndex: Integer index 1 read GetProperty write SetProperty;
    property ImageDownIndex: Integer index 2 read GetProperty write SetProperty;
    property ImageMoveIndex: Integer index 3 read GetProperty write SetProperty;
    property Offset: Integer index 4 read GetProperty write SetProperty;

    property Sound;
    property Visible;
  end;

  TDControl = class(TCustomControl)
  protected
    FPageActive: Boolean;
    FCaption: string;
    FText: string;                          //加入Text  不再用Caption作为显示文字
    FReadOnly: Boolean;                     //只读
    FDParent: TDControl;
    FMouseFocus: Boolean;                   //是否能获得鼠标焦点
    FKeyFocus: Boolean;                     //输入焦点
    FOnDirectPaint: TOnDirectPaint;
    FOnEndDirectPaint: TOnDirectPaint;      //窗口绘制结束触发事件
    FOnKeyPress: TOnKeyPress;
    FOnKeyDown: TOnKeyDown;
    FOnKeyUp: TOnKeyUp;

    FWheelDControl: TDControl;


    FOnMouseMove: TOnMouseMove;
    FOnMouseDown: TOnMouseDown;
    FOnMouseUp: TOnMouseUp;
    FOnDblClick: TNotifyEvent;
    FOnClick: TOnClickEx;
    FOnInRealArea: TOnInRealArea;
    FOnBackgroundClick: TOnClick;
    FOnEnter: TOnClick;
    FOnLeave: TOnClick;
    FOnVisible: TOnVisible;

    FMouseEntry: TMouseEntry;

    FAppendData: Pointer;

    // ========字体部分============
    FDefColor: TColor;
    FMoveColor: TColor;
    FEnabledColor: TColor;
    FDownColor: TColor;
    FBackColor: TColor;

    // ========图库部分============
    FLib: TLibFile;
    FImages: TWMImages;
    FImageIndex: integer;                     //正常
    FMoveIndex: integer;                      //经过
    FDownedIndex: integer;                    //按下
    FDisabledIndex: integer;                  //禁用
    FCheckedIndex: integer;                   //选择
    FDrawMode: TDrawMode;                     //绘制模式
    FPropertites: TCustomDXPropertites;
    FDXImageLib: TDXImageProperty;

    // ========窗口位置锚点============
    FAnchorX, FAnchorY: Single; //锚点布局 X Y
    FAnchorPostion: Boolean;//是否使用锚点坐标
    FAnchorPx, FAnchorPy: Single; //锚点位置对于本身的位置。
    FInSetAnchorX, FInSetAnchorY: Boolean;


    FMouseThrough: Boolean; //鼠标穿透。如果UI内部有透明的将不会被认为是在InRange

    FSurface: TDXTexture;
    procedure SetCaption(Str: string);
    procedure SetVisible(const Value: Boolean);

    function GetLeft: integer;
    procedure SetLeft(const Value: integer);
    function GetTop: integer;
    procedure SetTop(const Value: integer);
    function GetWidth: integer;
    function GetHeight: integer;
    procedure SetWidth(const Value: integer);
    procedure SetHeight(const Value: integer);
    procedure WidthChanged(Width: Integer);  //宽度改变了
    procedure HeightChanged(Height: Integer); //高度改变了
    procedure SaveDragStart(Control: TDControl; X, Y: Integer); // 记录拖放的起始 X Y
    procedure ResetXY(X, Y: Integer); // 为了UI拖放

    function GetAnchor(index: Integer): Single;
    procedure SetAnchor(index: Integer; Value: Single);
    procedure LayoutAnchorPoint();
    procedure SetAnchorPoint(const Value: Boolean);

    procedure InitImageLib();
  public
    TreeNode: TTreeNode;
    FEnabled: Boolean;  //禁用
    FVisible: Boolean;
    FIsHide: Boolean;

    Background: Boolean;
    DControls: TList;
    ULib: TUIBImages;
    FaceName: string;
    WantReturn: Boolean;
    AppendTick: LongWord;
    procedure CreatePropertites(); reintroduce; virtual;
    constructor Create(aowner: TComponent); override;
    destructor Destroy; override;
    procedure Paint; override;
    procedure Loaded; override;
    procedure PositionChanged;
    function SurfaceX(X: Integer): Integer;
    function SurfaceY(Y: Integer): Integer;
    function LocalX(X: Integer): Integer;
    function LocalY(Y: Integer): Integer;
    procedure AddChild(dcon: TDControl);
    procedure ChangeChildOrder(dcon: TDControl);
    function InRange(X, Y: Integer; Shift: TShiftState): Boolean; reintroduce; dynamic;
    function KeyPress(var Key: Char): Boolean; reintroduce; dynamic;
    function KeyDown(var Key: Word; Shift: TShiftState): Boolean; reintroduce; dynamic;
    function KeyUp(var Key: Word; Shift: TShiftState): Boolean; reintroduce; dynamic;
    function MouseWheel(Shift: TShiftState; Wheel: TMouseWheel; X, Y: Integer): Boolean; reintroduce; dynamic;
    function MouseMove(Shift: TShiftState; X, Y: Integer): Boolean; reintroduce; dynamic;
    function MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean; reintroduce; dynamic;
    function MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean; reintroduce; dynamic;
    function EscClose: Boolean; dynamic;
    function DblClick(X, Y: Integer): Boolean; reintroduce; dynamic;
    procedure IsVisible(flag: Boolean); dynamic;

    function Click(X, Y: Integer): Boolean; reintroduce; dynamic;
    function CanFocusMsg: Boolean;
    procedure Leave(); dynamic;
    procedure Enter(); dynamic;
    procedure SetFocus(); reintroduce; dynamic;
    function Selected(): Boolean; dynamic;
    procedure AdjustPos(X, Y: Integer); overload;
    procedure AdjustPos(X, Y, W, H: Integer); overload;
    procedure SetImgIndex(Lib: TWMImages; Index: Integer); overload;
    procedure SetImgIndex(Lib: TWMImages; Index, X, Y: Integer); overload;
    procedure SetImgGridIndex(Lib: TWMImages; Index: Integer);    //九宫格控件专用
    procedure SetImgName(Lib: TUIBImages; F: string);
    procedure CreateSurface(Lib: TWMImages; boActive: Boolean = True; index: integer = 0); overload;
    procedure CreateSurface(w, h: Integer; boActive: Boolean = True); overload;
    procedure DirectPaint(dsurface: TDXTexture); dynamic;

    property MouseEntry: TMouseEntry read FMouseEntry;
    property PageActive: Boolean read FPageActive write FPageActive;

    property IsHide: Boolean read FIsHide;

    property AppendData: Pointer read FAppendData write FAppendData;
    property Surface: TDXTexture read FSurface;

    property WLib: TWMImages read FImages write FImages;
    property FaceIndex: Integer read FImageIndex write FImageIndex;

    property AnchorX : Single index 1 read GetAnchor write SetAnchor;
    property AnchorY : Single index 2 read GetAnchor write SetAnchor;
    property AnchorPx :Single Index 3 read  GetAnchor write SetAnchor;
    property AnchorPy : Single index 4 read GetAnchor write SetAnchor;
    property AnchorPosition: Boolean read FAnchorPostion write SetAnchorPoint;

    //字体
    property DefColor: TColor read FDefColor write FDefColor;
    property MoveColor: TColor read FMoveColor write FMoveColor;
    property DownColor: TColor read FDownColor write FDownColor;
    property EnabledColor: TColor read FEnabledColor write FEnabledColor;
    property BackColor: TColor read FBackColor write FBackColor;
  published
    property Left: integer read GetLeft write SetLeft;
    property Top: integer read GetTop write SetTop;
    property Width: integer read GetWidth write SetWidth;
    property Height: integer read GetHeight write SetHeight;

    property Propertites: TCustomDXPropertites read FPropertites write FPropertites;

    property OnDirectPaint: TOnDirectPaint read FOnDirectPaint write FOnDirectPaint;
    property OnEndDirectPain: TOnDirectPaint read FOnEndDirectPaint write FOnEndDirectPaint;
    property OnKeyPress: TOnKeyPress read FOnKeyPress write FOnKeyPress;
    property OnKeyDown: TOnKeyDown read FOnKeyDown write FOnKeyDown;
    property OnMouseMove: TOnMouseMove read FOnMouseMove write FOnMouseMove;
    property OnMouseDown: TOnMouseDown read FOnMouseDown write FOnMouseDown;
    property OnMouseUp: TOnMouseUp read FOnMouseUp write FOnMouseUp;
    property OnDblClick: TNotifyEvent read FOnDblClick write FOnDblClick;
    property OnClick: TOnClickEx read FOnClick write FOnClick;
    property OnInRealArea: TOnInRealArea read FOnInRealArea write FOnInRealArea;
    property OnBackgroundClick: TOnClick read FOnBackgroundClick write FOnBackgroundClick;
    //property OnMouseWheel: TMouseWheelEvent read FOnMouseWheel write FOnMouseWheel;

    property OnEnter: TOnClick read FOnEnter write FOnEnter;
    property OnLeave: TOnClick read FOnLeave write FOnLeave;
    property OnVisible: TOnVisible read FOnVisible write FOnVisible;


    property WheelDControl: TDControl read FWheelDControl write FWheelDControl;

    property Caption: string read FCaption write SetCaption;
    property Text: string read FText write FText;
    property ReadOnly: Boolean read FReadOnly write FReadOnly default False;
    property DParent: TDControl read FDParent write FDParent;
    property Visible: Boolean read FVisible write SetVisible;
    property MouseFocus: Boolean read FMouseFocus write FMouseFocus;
    property KeyFocus: Boolean read FKeyFocus write FKeyFocus;
    Property MouseThrough: Boolean read FMouseThrough write FMouseThrough;
    property DrawMode: TDrawMode read FDrawMode write FDrawMode;
    property Color;
    property Font;
    property Hint;
    property ShowHint;
    property Align;
  end;

  TDLabel = class(TDControl)
  private
    FAlignment: TAlignment;         //显示位置
    FClickSound: TClickSound;
    FOnClick: TOnClickEx;
    FOnClickSound: TOnClickSound;
    procedure SetAlignment(Value: TAlignment);
  public
    Downed: Boolean;
    procedure CreatePropertites(); override;
    constructor Create(AOwner: TComponent); override;
    function MouseMove(Shift: TShiftState; X, Y: Integer): Boolean; override;
    function MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean; override;
    function MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean; override;
    procedure DirectPaint(dsurface: TDXTexture); override;
  published
    property Alignment: TAlignment read FAlignment write SetAlignment;
    property ClickCount: TClickSound read FClickSound write FClickSound;
    property OnClick: TOnClickEx read FOnClick write FOnClick;
    property OnClickSound: TOnClickSound read FOnClickSound write FOnClickSound;
  end;


  TDButton = class(TDControl)
  private
    FClickSound: TClickSound;
    FOnClick: TOnClickEx;
    FOnClickSound: TOnClickSound;
    FShowText: Boolean;
  public
    FFloating: Boolean;
    btnState: TDBtnState;
    Downed: Boolean;
    Arrived: Boolean;
    SpotX, SpotY: Integer;
    Clicked: Boolean;
    ClickInv: LongWord; //点击间隔
    procedure CreatePropertites(); override;
    constructor Create(aowner: TComponent); override;
    function MouseMove(Shift: TShiftState; X, Y: Integer): Boolean; override;
    function MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean; override;
    function MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean; override;
    procedure DirectPaint(dsurface: TDXTexture); override;
  published
    property ClickCount: TClickSound read FClickSound write FClickSound;
    property OnClick: TOnClickEx read FOnClick write FOnClick;
    property OnClickSound: TOnClickSound read FOnClickSound write FOnClickSound;
    property ShowText: Boolean read FShowText write FShowText default False;
  end;


  //游戏窗口
  TDWindow = class(TDButton)
  private
    FFloating: Boolean;      //窗口是否可拖动
    FEscClose: Boolean;       //ESC按键是否关闭
    FControlStyle: TDControlStyle;
    SpotX, SpotY: Integer;
    procedure SetVisible(Value: Boolean);
  public
    DialogResult: TModalResult;
    procedure CreatePropertites(); override;
    constructor Create(aowner: TComponent); override;
    function MouseMove(Shift: TShiftState; X, Y: Integer): Boolean; override;
    function MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean; override;
    function MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean; override;
    procedure DirectPaint(dsurface: TDXTexture); override;
    function EscClose: Boolean; override;
    procedure Show;
    function ShowModal: Integer;
    procedure TopShow();
  published
    property Visible: Boolean read FVisible write SetVisible;
    property Floating: Boolean read FFloating write FFloating;
    property EscExit: Boolean read FEscClose write FEscClose;
    property ControlStyle: TDControlStyle read FControlStyle write FControlStyle;
  end;

  //绘制九宫格窗口
  TDImageGrid = class(TDWindow)
  private
    FStretch: Boolean;           //窗口拉伸
    FRelativeLeft: Integer;      //相对主窗口左边
    FRelativeTop: Integer;       //相对主窗口顶部
    FRelativeRight: Integer;     //相对主窗口右边
    FRelativeBottom: Integer;    //相对主窗口右边
  public
    procedure CreatePropertites(); override;
    constructor Create(aowner: TComponent); override;
    procedure DirectPaint(DSurface: TDXTexture); override;
  published
    property Stretch: Boolean read FStretch write FStretch;
    property RelativeLeft: Integer read FRelativeLeft write FRelativeLeft;
    property RelativeTop: Integer read FRelativeTop write FRelativeTop;
    property RelativeRight: Integer read FRelativeRight write FRelativeRight;
    property RelativeBottom: Integer read FRelativeBottom write FRelativeBottom;
  end;

  //进度条图片
  TDImageBar = class(TDWindow)
  private
    FAniCount: Word;                          //播放图片数量
    FAniInterval: Cardinal;                   //播放图片间隔
    FOffsetX, FOffsetY: Integer;              //偏移坐标X Y
    FChangeFrameTime: Cardinal;

    FDrawBarMode: TDrawBarMode;               //Bar绘制模式.
    FDrawDirection: TDrawDirection;           //剪切方向
    FClipType: TClipBarType;                  // 裁剪类型
  public
    procedure CreatePropertites(); override;
    constructor Create(aowner: TComponent); override;
    procedure DirectPaint(DSurface: TDXTexture); override;
  published
    property AniCount: Word read FAniCount write FAniCount;
    property AniInterval: Cardinal read FAniInterval write FAniInterval;
    property OffsetX: Integer read FOffsetX write FOffsetX;
    property OffsetY: Integer read FOffsetY write FOffsetY;
    property DrawBarMode: TDrawBarMode read FDrawBarMode write FDrawBarMode;
    property DrawDirection: TDrawDirection read FDrawDirection write FDrawDirection;
    property ClipType: TClipBarType read FClipType write FClipType;
  end;

  //迷你Map专用
  TDWindowMiniMap = class(TDWindow)
  private
    FRound: Boolean;           //是否是圆形
  public
    procedure CreatePropertites(); override;
    constructor Create(aowner: TComponent); override;
  published
    property Round: Boolean read FRound write FRound;
  end;

  // 动画按钮
  TDAniButton = class(TDButton)
  private
    FAniCount: Word;                          //播放图片数量
    FAniInterval: Cardinal;                   //播放图片间隔
    FAniLoop: Boolean;                        //是否循环 {循环不会触发结束事件}
    FOffsetX, FOffsetY: Integer;              //偏移坐标X Y
    FStart: Boolean;                          //控制是否开始绘制
    FFrameIndex: Integer;                     //帧索引当前绘制在第几帧
    FOnAniDirectPaintBegin: TOnAniDirectPaint;//动画开始绘制触发事件()
    FOnAniDirectPaintReset: TOnAniDirectPaint;//动画重置绘制触发事件()
    FOnAniDirectPaintEnd: TOnAniDirectPaint;  //动画结束绘制触发事件()
    FChangeFrameTime: Cardinal;
  public
    procedure CreatePropertites(); override;
    constructor Create(aowner: TComponent); override;
    procedure DirectPaint(DSurface: TDXTexture); override;
    procedure Start();                        //绘制开始 唤醒
    procedure Reset();                        //绘制重置
    procedure Over();                         //绘制结束 结束
  published
    property AniCount: Word read FAniCount write FAniCount;
    property AniInterval: Cardinal read FAniInterval write FAniInterval;
    property AniLoop: Boolean read FAniLoop write FAniLoop;
    property OffsetX: Integer read FOffsetX write FOffsetX;
    property OffsetY: Integer read FOffsetY write FOffsetY;
    property OnAniDirectPaintBegin: TOnAniDirectPaint read FOnAniDirectPaintBegin write FOnAniDirectPaintBegin;
    property OnAniDirectPaintReset: TOnAniDirectPaint read FOnAniDirectPaintReset write FOnAniDirectPaintReset;
    property OnAniDirectPaintEnd: TOnAniDirectPaint read FOnAniDirectPaintEnd write FOnAniDirectPaintEnd;
  end;

  TDCheckBox = class(TDControl)
  private
    FArrived: Boolean;
    FChecked: Boolean;
    FClickSound: TClickSound;
    FOnClick: TOnClickEx;
    FOnClickSound: TOnClickSound;
  public
    Downed: Boolean;
    constructor Create(aowner: TComponent); override;
    function MouseMove(Shift: TShiftState; X, Y: Integer): Boolean; override;
    function MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean; override;
    function MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean; override;
    property Checked: Boolean read FChecked write FChecked;
    property Arrived: Boolean read FArrived write FArrived;
  published
    property ClickCount: TClickSound read FClickSound write FClickSound;
    property OnClick: TOnClickEx read FOnClick write FOnClick;
    property OnClickSound: TOnClickSound read FOnClickSound write FOnClickSound;
  end;

  TDCustomControl = class(TDControl)
  protected
    FEnabled: Boolean;
    FTransparent: Boolean;
    FClickSound: TClickSound;
    FOnClick: TOnClickEx;
    FOnClickSound: TOnClickSound;
    FFrameVisible: Boolean;
    FFrameHot: Boolean;
    FFrameSize: byte;
    FFrameColor: TColor;
    FFrameHotColor: TColor;
    procedure SetTransparent(Value: Boolean);
    procedure SetEnabled(Value: Boolean); reintroduce;
    procedure SetFrameVisible(Value: Boolean);
    procedure SetFrameHot(Value: Boolean);
    procedure SetFrameSize(Value: byte);
    procedure SetFrameColor(Value: TColor);
    procedure SetFrameHotColor(Value: TColor);
  protected
    property Enabled: Boolean read FEnabled write SetEnabled default True;
    property Transparent: Boolean read FTransparent write SetTransparent default True;
    property FrameVisible: Boolean read FFrameVisible write SetFrameVisible default True;
    property FrameHot: Boolean read FFrameHot write SetFrameHot default False;
    property FrameSize: byte read FFrameSize write SetFrameSize default 1;
    property FrameColor: TColor read FFrameColor write SetFrameColor default $00406F77;
    property FrameHotColor: TColor read FFrameHotColor write SetFrameHotColor default $00599AA8;
  public
    Downed: Boolean;
    //OnEnterKey: procedure of object;
    //OntTabKey: procedure of object;
    procedure OnDefaultEnterKey;
    procedure OnDefaultTabKey;
    constructor Create(aowner: TComponent); override;
    function MouseMove(Shift: TShiftState; X, Y: Integer): Boolean; override;
    function MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean; override;
    function MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean; override;
  published
    property ClickCount: TClickSound read FClickSound write FClickSound;
    property OnClick: TOnClickEx read FOnClick write FOnClick;
    property OnClickSound: TOnClickSound read FOnClickSound write FOnClickSound;
  end;

  TDxScrollBarBar = class(TDCustomControl)
  protected
    StartPosY, TotH, hAuteur, dify: Integer;
    Selected: Boolean;
    TmpList: TStrings;
  public
    ModPos: Integer;
    constructor Create(aowner: TComponent; nTmpList: TStrings); reintroduce;

    procedure AJust_H;
    function GetPos: Integer;
    procedure MoveBar(nposy: Integer);
    procedure MoveModPos(nMove: Integer);
    procedure DirectPaint(dsurface: TDXTexture); override;
    function MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean; override;
    function MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean; override;
    function MouseMove(Shift: TShiftState; X, Y: Integer): Boolean; override;
  end;

  TDxScrollBarUp = class(TDCustomControl)
  protected
    Selected: Boolean;
  public
    function MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean; override;
    function MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean; override;
    procedure DirectPaint(dsurface: TDXTexture); override;
  end;

  TDxScrollBarDown = class(TDxScrollBarUp)
  public
    procedure DirectPaint(dsurface: TDXTexture); override;
  end;

  TDxScrollBar = class(TDCustomControl)
  protected
    TotH: Integer;
    BUp: TDxScrollBarUp;
    BDown: TDxScrollBarDown;
    Bar: TDxScrollBarBar;
  public
    constructor Create(aowner: TComponent; nTmpList: TStrings); reintroduce;
    function GetPos: Integer;
    procedure MoveModPos(nMove: Integer);
    function MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean; override;
  end;

  TDxHint = class(TDCustomControl)
  private
    FItems: TStrings;
    FBackColor: TColor;
    FSelectionColor: TColor;
    FParentControl: TDControl;
    function GetItemSelected: Integer;
    procedure SetItems(Value: TStrings);
    procedure SetBackColor(Value: TColor);
    procedure SetSelectionColor(Value: TColor);
    procedure SetItemSelected(Value: Integer);
  public
    FSelected: Integer;
    FOnChangeSelect: TOnChangeSelect;
    FOnMouseMoveSelect: TOnMouseMoveSelect;
    property Items: TStrings read FItems write SetItems;
    property BackColor: TColor read FBackColor write SetBackColor default clWhite;
    property SelectionColor: TColor read FSelectionColor write SetSelectionColor default clSilver;
    property ItemSelected: Integer read GetItemSelected write SetItemSelected;
    property ParentControl: TDControl read FParentControl write FParentControl;
    function MouseMove(Shift: TShiftState; X, Y: Integer): Boolean; override;
    function MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean; override;
    function MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean; override;
    function KeyDown(var Key: Word; Shift: TShiftState): Boolean; override;
    constructor Create(aowner: TComponent); override;
    destructor Destroy; override;
    procedure DirectPaint(dsurface: TDXTexture); override;
  end;

  

  TDGrid = class(TDControl)
  private
    FColCount, FRowCount: Integer;
    FColWidth, FRowHeight: Integer;
    FViewTopLine: Integer;
    SelectCell: TPoint;
    DownPos: TPoint;
    FOnGridSelect: TOnGridSelect;
    FOnGridMouseMove: TOnGridSelect;
    FOnGridPaint: TOnGridPaint;
    function GetColRow(X, Y: Integer; var ACol, ARow: Integer): Boolean;
  public
    tButton: TMouseButton;
    cx, cy: Integer;
    Col, Row: Integer;
    constructor Create(aowner: TComponent); override;
    function MouseMove(Shift: TShiftState; X, Y: Integer): Boolean; override;
    function MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean; override;
    function MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean; override;
    function Click(X, Y: Integer): Boolean; override;
    procedure DirectPaint(dsurface: TDXTexture); override;
  published
    property ColCount: Integer read FColCount write FColCount;
    property RowCount: Integer read FRowCount write FRowCount;
    property ColWidth: Integer read FColWidth write FColWidth;
    property RowHeight: Integer read FRowHeight write FRowHeight;
    property ViewTopLine: Integer read FViewTopLine write FViewTopLine;
    property OnGridSelect: TOnGridSelect read FOnGridSelect write FOnGridSelect;
    property OnGridMouseMove: TOnGridSelect read FOnGridMouseMove write FOnGridMouseMove;
    property OnGridPaint: TOnGridPaint read FOnGridPaint write FOnGridPaint;
  end;

  TDWinManager = class(TComponent)
  private
  public
    DWinList: TList;
    LibClientList: TList;   //客户端使用文件列表 需要初始化.
    constructor Create(aowner: TComponent); override;
    destructor Destroy; override;
    procedure AddDControl(dcon: TDControl; Visible: Boolean);
    procedure DelDControl(dcon: TDControl);
    procedure ClearAll;
    function KeyPress(var Key: Char): Boolean;
    function KeyDown(var Key: Word; Shift: TShiftState): Boolean;
    function KeyUp(var Key: Word; Shift: TShiftState): Boolean;
    function MouseWheel(Shift: TShiftState; Wheel: TMouseWheel; X, Y: Integer): Boolean;
    function MouseMove(Shift: TShiftState; X, Y: Integer): Boolean;
    function MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean;
    function MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean;
    function DblClick(X, Y: Integer): Boolean;
    function Click(X, Y: Integer): Boolean;
    procedure DirectPaint(dsurface: TDXTexture);
    procedure SetLibClientList;
    function EscClose(): Boolean;
  end;

  TDMoveButton = class(TDButton)  //滚动条
  private
    FFloating: Boolean;
    SpotX, SpotY: Integer;
  protected
    procedure SetVisible(flag: Boolean);
  public
    DialogResult: TModalResult;
    FOnClick: TOnClickEx;
    SlotLen: Integer;
    RLeft: Integer;
    RTop: Integer;
    Position: Integer;
    outHeight: Integer;
    Max: Integer;
    Reverse: Boolean;
    LeftToRight: Boolean;
    constructor Create(aowner: TComponent); override;
    function MouseMove(Shift: TShiftState; X, Y: Integer): Boolean; override;
    function MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean; override;
    function MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean; override;
    procedure Show;
    function ShowModal: Integer;
    procedure UpdatePos(pos: Integer; force: Boolean = False);
  published
    property Visible: Boolean read FVisible write SetVisible;
    property Floating: Boolean read FFloating write FFloating;
    property OnClick: TOnClickEx read FOnClick write FOnClick;
    property FBoxMoveTop: Integer read SlotLen write SlotLen;
    property TypeRLeft: Integer read RLeft write RLeft;
    property TypeRTop: Integer read RTop write RTop;
    property TReverse: Boolean read Reverse write Reverse;
  end;

{==============TDPopupMenu创建===============}
  TDPopupMenu = class;

  TMenuStyle = (sXP, sVista);

  TImageIndex = type Integer;

  TDMenuItem = class(TObject)
  private
    FVisible: Boolean;
    FEnabled: Boolean;
    FCaption: string;
    FMenu: TDPopupMenu;
    FChecked: Boolean;
  public
    constructor Create();
    destructor Destroy; override;
    property Visible: Boolean read FVisible write FVisible;
    property Enabled: Boolean read FEnabled write FEnabled;
    property Caption: string read FCaption write FCaption;
    property Checked: Boolean read FChecked write FChecked;
    property Menu: TDPopupMenu read FMenu write FMenu;
  end;

  TDPopupMenu = class(TDControl)
  private
    FItems: TStrings;
    FColors: TColors;
    FMoveItemIndex: Integer;
    FItemSize: Integer;
    FMouseMove: Boolean;
    FOwnerMenu: TDPopupMenu;
    FItemIndex: Integer;
    FOwnerItemIndex: TImageIndex;
    FActiveMenu: TDPopupMenu;
    FDControl: TDControl;
    FStyle: TMenuStyle;
    function GetMenu(Index: Integer): TDPopupMenu;
    procedure SetMenu(Index: Integer; Value: TDPopupMenu);
    function GetItem(Index: Integer): TDMenuItem;
    function GetCount: Integer;
    procedure SetOwnerItemIndex(Value: TImageIndex);
    procedure SetOwnerMenu(Value: TDPopupMenu);
    procedure SetItems(Value: TStrings);
    function GetItems: TStrings;
    procedure SetColors(Value: TColors);
    procedure SetItemIndex(Value: Integer);
  protected
    procedure CreateWnd; override;
  public
    Downed: Boolean;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Paint; override;
   // procedure Process; override;
    function InRange(X, Y: Integer; Shift: TShiftState): Boolean; override;
    procedure DirectPaint(dsurface: TDXTexture); override;
    function KeyPress(var Key: Char): Boolean; override;
    function KeyDown(var Key: Word; Shift: TShiftState): Boolean; override;
    function MouseMove(Shift: TShiftState; X, Y: Integer): Boolean; override;
    function MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean; override;
    function MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean; override;
    function Click(X, Y: Integer): Boolean; override;
    procedure Show; overload;
    procedure Show(d: TDControl); overload;
    procedure Hide;
    procedure Insert(Index: Integer; ACaption: string; Item: TDPopupMenu);
    procedure Delete(Index: Integer);
    procedure Clear;
    function Find(ACaption: string): TDPopupMenu;
    function IndexOf(Item: TDPopupMenu): Integer;
    procedure Add(ACaption: string; Item: TDPopupMenu);
    procedure Remove(Item: TDPopupMenu);
    property Count: Integer read GetCount;
    property Menus[Index: Integer]: TDPopupMenu read GetMenu write SetMenu;
    property Items[Index: Integer]: TDMenuItem read GetItem;
    property DControl: TDControl read FDControl write FDControl;
  published
    property OwnerMenu: TDPopupMenu read FOwnerMenu write SetOwnerMenu;
    property OwnerItemIndex: TImageIndex read FOwnerItemIndex write SetOwnerItemIndex default -1;
    property MenuItems: TStrings read GetItems write SetItems;
    property Colors: TColors read FColors write SetColors;
    property ItemIndex: Integer read FItemIndex write SetItemIndex default -1;
    property Style: TMenuStyle read FStyle write FStyle;
  end;
{==============TDPopupMenu结束===============}


{===========================EDIT创建===================}

  TDComboBox = class;

  TDxListBoxCustom = class(TDCustomControl)
  private
    FItems: TStrings;
    FBackColor: TColor;
    FSelectionColor: TColor;
    FParentComboBox: TDComboBox;
    function GetItemSelected: Integer;
    procedure SetItems(Value: TStrings);
    procedure SetBackColor(Value: TColor);
    procedure SetSelectionColor(Value: TColor);
    procedure SetItemSelected(Value: Integer);
  public
    ChangingHero: Boolean;
    FSelected: Integer;
    FOnChangeSelect: TOnChangeSelect;
    FOnMouseMoveSelect: TOnMouseMoveSelect;
    property Items: TStrings read FItems write SetItems;
    property BackColor: TColor read FBackColor write SetBackColor default clWhite;
    property SelectionColor: TColor read FSelectionColor write SetSelectionColor default clSilver;
    property ItemSelected: Integer read GetItemSelected write SetItemSelected;
    property ParentComboBox: TDComboBox read FParentComboBox write FParentComboBox;

    //procedure ChangeSelect(ChangeSelect: Integer);
    function MouseMove(Shift: TShiftState; X, Y: Integer): Boolean; override;
    function MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean; override;
    function MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean; override;
    function KeyDown(var Key: Word; Shift: TShiftState): Boolean; override;
    constructor Create(aowner: TComponent); override;
    destructor Destroy; override;
    procedure DirectPaint(dsurface: TDXTexture); override;
  end;

  TDListBox = class(TDxListBoxCustom)
  published
    property Enabled;
    property Transparent;
    property BackColor;
    property SelectionColor;
    property FrameVisible;
    property FrameHot;
    property FrameSize;
    property FrameColor;
    property FrameHotColor;
    property ParentComboBox;
    property ClickCount: TClickSound read FClickSound write FClickSound;
    property OnClick: TOnClickEx read FOnClick write FOnClick;
    property OnClickSound: TOnClickSound read FOnClickSound write FOnClickSound;
  end;

  //TAlignment = (taCenter, taLeftJustify , taRightJustify);

  TDxCustomEdit = class(TDCustomControl)
  private
    FAtom: Word;
    FHotKey: Cardinal;
    FIsHotKey: Boolean;
    FAlignment: TAlignment;
    FClick: Boolean;
    FSelClickStart: Boolean;
    FSelClickEnd: Boolean;
    FCurPos: Integer;
    FClickX: Integer;
    FSelStart: Integer;
    FSelEnd: Integer;
    FStartTextX: Integer;
    FSelTextStart: Integer;
    FSelTextEnd: Integer;
    FMaxLength: Integer;
    FShowCaretTick: LongWord;
    FShowCaret: Boolean;
    FNomberOnly: Boolean;
    FSecondChineseChar: Boolean;
    FPasswordChar: Char;
    FOnTextChanged: TOnTextChanged;
    procedure SetSelStart(Value: Integer);
    procedure SetSelEnd(Value: Integer);
    procedure SetMaxLength(Value: Integer);
    procedure SetPasswordChar(Value: Char);
    procedure SetNomberOnly(Value: Boolean);
    procedure SetAlignment(Value: TAlignment);
    procedure SetIsHotKey(Value: Boolean);
    procedure SetHotKey(Value: Cardinal);
    procedure SetAtom(Value: Word);
    procedure SetSelLength(Value: Integer);
    function ReadSelLength(): Integer;
  protected
    property Alignment: TAlignment read FAlignment write SetAlignment default taLeftJustify;
    property NomberOnly: Boolean read FNomberOnly write SetNomberOnly default False;
    property IsHotKey: Boolean read FIsHotKey write SetIsHotKey default False;
    property Atom: Word read FAtom write SetAtom default 0;
    property HotKey: Cardinal read FHotKey write SetHotKey default 0;
    property MaxLength: Integer read FMaxLength write SetMaxLength default 0;
    property PasswordChar: Char read FPasswordChar write SetPasswordChar default #0;
  public
    DxHint: TDxHint;
    m_InputHint: string;
    FMiniCaret: byte;
    FCaretColor: TColor;
    procedure ShowCaret();
    procedure SetFocus(); override;
    procedure ChangeCurPos(nPos: Integer; boLast: Boolean = False);
    constructor Create(aowner: TComponent); override;
    function MouseMove(Shift: TShiftState; X, Y: Integer): Boolean; override;
    function MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean; override;
    function MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean; override;
    procedure DirectPaint(dsurface: TDXTexture); override;
    function KeyPress(var Key: Char): Boolean; override;
    function KeyPressEx(var Key: Char): Boolean;
    function KeyDown(var Key: Word; Shift: TShiftState): Boolean; override;
    function SetOfHotKey(HotKey: Cardinal): Word;
    property Text: string read FCaption write SetCaption;
    property SelStart: Integer read FSelStart write SetSelStart;
    property SelEnd: Integer read FSelEnd write SetSelEnd;
    property SelLength: Integer read ReadSelLength write SetSelLength;
    property OnTextChanged: TOnTextChanged read FOnTextChanged write FOnTextChanged;
    ///
  end;

  TDxEdit = class(TDxCustomEdit)
  published
    property Alignment;
    property IsHotKey;
    property HotKey;
    property Enabled;
    property MaxLength;
    property NomberOnly;
    property Transparent;
    property PasswordChar;
    property FrameVisible;
    property FrameHot;
    property FrameSize;
    property FrameColor;
    property FrameHotColor;
    property ClickCount: TClickSound read FClickSound write FClickSound;
    property OnClick: TOnClickEx read FOnClick write FOnClick;
    property OnClickSound: TOnClickSound read FOnClickSound write FOnClickSound;
  end;

  TDComboBox = class(TDxCustomEdit)
  private
    FDropDownList: TDListBox;
  protected
    //
  public
    constructor Create(aowner: TComponent); override;
    function MouseMove(Shift: TShiftState; X, Y: Integer): Boolean; override;
    function MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean; override;
    //function MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean; override;
  published
    property Enabled;
    property MaxLength;
    property NomberOnly;
    property Transparent;
    property PasswordChar;
    property FrameVisible;
    property FrameHot;
    property FrameSize;
    property FrameColor;
    property FrameHotColor;
    property DropDownList: TDListBox read FDropDownList write FDropDownList;
    property ClickCount: TClickSound read FClickSound write FClickSound;
    property OnClick: TOnClickEx read FOnClick write FOnClick;
    property OnClickSound: TOnClickSound read FOnClickSound write FOnClickSound;
  end;
{==========================EDIT结束=========================================================}

  TCursor = (deLeft, deRight);

  TDCustomEdit = class(TDControl)
  private
    FEditClass: TDEditClass;
    FPasswordChar: Char;
  public
    constructor Create(AOwner: TComponent); override;

    procedure Enter(); override;
    procedure Leave(); override;
    procedure IsVisible(flag: Boolean); override;
  published
    property EditClass: TDEditClass read FEditClass write FEditClass;
    property PasswordChar: Char read FPasswordChar write FPasswordChar default #0;
  end;

  TDEdit = class(TDCustomEdit)
  private
    FEditString: string;
    FFrameColor: TColor;
    FCaretShowTime: LongWord;
    FCaretShow: Boolean;
    FMaxLength: Integer;
    FInputStr: string;
    bDoubleByte: Boolean;
    KeyByteCount: Integer;
    FCursor: TCursor;
    FStartX: Integer;
    FStopX: Integer;
    FCaretStart: Integer;
    FCaretStop: Integer;
    FCaretPos: Integer;
    FOnChange: TOnClick;
    FIndent: Integer;
    FCloseSpace: Boolean;
    FTransparent: Boolean;
    procedure SetCursorPos(cCursor: TCursor);
    procedure SetCursorPosEx(nLen: Integer);
    procedure SetText(Value: string);
    function GetText(): string;
    procedure MoveCaret(X, Y: Integer);
    function ClearKey(): Boolean;

    function GetPasswordstr(str: string): string;
    function GetCopy(): string;
    function GetValue: Integer;
    procedure SetValue(const Value: Integer);
  public
    Downed: Boolean;
    KeyDowned: Boolean;
    procedure CreatePropertites(); override;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function KeyPress(var Key: Char): Boolean; override;
    function KeyDown(var Key: Word; Shift: TShiftState): Boolean; override;
    function KeyUp(var Key: Word; Shift: TShiftState): Boolean; override;
    procedure DirectPaint(dsurface: TDXTexture); override;
    function MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean; override;
    function MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean; override;
    function MouseMove(Shift: TShiftState; X, Y: Integer): Boolean; override;
    procedure Enter(); override;
    procedure Leave(); override;
    procedure SetFocus(); override;
    function Selected(): Boolean; override;
    procedure TextChange();
    property Value: Integer read GetValue write SetValue;
  published
    property OnChange: TOnClick read FOnChange write FOnChange;
    property Text: string read GetText write SetText;
    property FrameColor: TColor read FFrameColor write FFrameColor;
    property MaxLength: Integer read FMaxLength write FMaxLength default 0;
    property CloseSpace: Boolean read FCloseSpace write FCloseSpace default False;
    property Transparent: Boolean read FTransparent write FTransparent;
  end;

  TDImageEdit = class(TDCustomEdit)
  private
    FMaxLength: Integer;
    FOnChange: TOnClick;
    FOnCheckItem: TOnCheckItem;
    FOnDrawEditImage: TOnDrawEditImage;
    FStartX: Integer;
    FStopX: Integer;
    FStartLine: Integer;
    FStopLine: Integer;
    FInputStr: string;
    FEditString: string;
    bDoubleByte: Boolean;
    KeyByteCount: Integer;
    FEditTextList: TStringList;
    FEditImageList: TStringList;
    FEditItemList: TStringList;
    FCaretPos: Word;
    FStartoffset: Byte;
    FImageWidth: Byte;
    FShowPos: Word;
    FShowLine: Integer;
    FShowLeft: Boolean;
    FCaretShowTime: LongWord;
    FCaretShow: Boolean;
    FOppShowPos: Integer;
    FBeginChar: Char;
    FEndChar: Char;
    FImageChar: Char;
    FItemCount: Integer;
    FImageCount: Integer;
    FTransparent: Boolean;
    FFrameColor: TColor;
    procedure AddStrToList(str: string);
    procedure MoveCaret(X, Y: Integer);
    function GetText: string;
    procedure SetText(const Value: string);
    function ClearKey(): Boolean;
    function GetCopy(): string;
    procedure SetBearing(boLeft: Boolean);
    function GetItemName(str: string; boName: Boolean): string;
    procedure FormatEditStr(str: string);
  public
    Downed: Boolean;
    KeyDowned: Boolean;
    procedure CreatePropertites(); override;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function KeyPress(var Key: Char): Boolean; override;
    function KeyDown(var Key: Word; Shift: TShiftState): Boolean; override;
    function KeyUp(var Key: Word; Shift: TShiftState): Boolean; override;
    function MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean; override;
    function MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean; override;
    function MouseMove(Shift: TShiftState; X, Y: Integer): Boolean; override;
    procedure DirectPaint(dsurface: TDXTexture); override;
    procedure Enter(); override;
    procedure Leave(); override;
    procedure SetFocus(); override;
    procedure TextChange();
    procedure RefEditSurfce(boRef: Boolean = True);
    procedure RefEditText();
    Function Selected(): Boolean; override;
    Function AddItemToList(ItemName, ItemIndex: string): Byte;
    Function AddImageToList(ImageIndex: string): Byte;
  published
    property OnChange: TOnClick read FOnChange write FOnChange;
    property OnCheckItem: TOnCheckItem read FOnCheckItem write FOnCheckItem;
    property OnDrawEditImage: TOnDrawEditImage read FOnDrawEditImage write FOnDrawEditImage;
    property Text: string read GetText write SetText;
    property MaxLength: Integer read FMaxLength write FMaxLength default 0;
    property BeginChar: Char read FBeginChar write FBeginChar;
    property EndChar: Char read FEndChar write FEndChar;
    property ImageChar: Char read FImageChar write FImageChar;
    property ItemCount: Integer read FItemCount write FItemCount;
    property ImageCount: Integer read FImageCount write FImageCount;
    property Transparent: Boolean read FTransparent write FTransparent;
    property FrameColor: TColor read FFrameColor write FFrameColor;
  end;

  //UPDown专用按钮
  TDUpDownButton = class(TDButton)
  public
    procedure CreatePropertites(); override;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

  //滚动条
  TDUpDown = class(TDButton)
  private
    FUpButton: TDUpDownButton;
    FDownButton: TDUpDownButton;
    FMoveButton: TDUpDownButton;
    FPosition: Integer;
    FMaxPosition: Integer;
    FOnPositionChange: TOnClick;
    FTop: Integer;
    FAddTop: Integer;
    FMaxLength: Integer;
    FOffset: Integer;
    FBoMoveShow: Boolean;
    FboMoveFlicker: Boolean;
    FboNormal: Boolean;
    StopY: Integer;
    FStopY: Integer;
    FClickTime: LongWord;
    FMovePosition: Integer;
    procedure SetButton(Button: TDUpDownButton);
    procedure SetPosition(value: Integer);
    procedure SetMaxPosition(const Value: Integer);
  public
    procedure CreatePropertites(); override;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function MouseWheel(Shift: TShiftState; Wheel: TMouseWheel; X, Y: Integer): Boolean; override;
    procedure DirectPaint(dsurface: TDXTexture); override;
    procedure ButtonMouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
    procedure ButtonMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ButtonMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    property UpButton: TDUpDownButton read FUpButton write FUpButton;
    property DownButton: TDUpDownButton read FDownButton write FDownButton;
    property MoveButton: TDUpDownButton read FMoveButton write FMoveButton;
  published
    property Position: Integer read FPosition write SetPosition;
    property Offset: Integer read FOffset write FOffset;
    property Normal: Boolean read FboNormal write FboNormal;
    property MovePosition: Integer read FMovePosition write FMovePosition;
    property MoveShow: Boolean read FBoMoveShow write FBoMoveShow;
    property MaxPosition: Integer read FMaxPosition write SetMaxPosition;
    property MoveFlicker: Boolean read FboMoveFlicker write FboMoveFlicker; //闪烁
    property OnPositionChange: TOnClick read FOnPositionChange write FOnPositionChange;
  end;

  TDMemo = class(TDCustomEdit)
  private
    FLines: TStrings;
    FOnChange: TOnClick;
    FFrameColor: TColor;
    FCaretShowTime: LongWord;
    FCaretShow: Boolean;
    FTopIndex: Integer;
    FCaretX: Integer;
    FCaretY: Integer;
    FSCaretX: Integer;
    FSCaretY: Integer;
    FUpDown: TDUpDown;
    FMoveTick: LongWord;
    FInputStr: string;
    bDoubleByte: Boolean;
    KeyByteCount: Integer;
    FTransparent: Boolean;
    FMaxLength: integer;

    procedure DownCaret(X, Y: Integer);
    procedure MoveCaret(X, Y: Integer);
    procedure KeyCaret(Key: Word);
    procedure SetUpDown(const Value: TDUpDown);
    procedure SetCaret(boBottom: Boolean);
    function ClearKey(): Boolean;
    function GetKey(): string;
    procedure SetCaretY(const Value: Integer);
  public
    Downed: Boolean;
    KeyDowned: Boolean;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure DirectPaint(dsurface: TDXTexture); override;
    procedure IsVisible(flag: Boolean); override;
    function KeyPress(var Key: Char): Boolean; override;
    function KeyDown(var Key: Word; Shift: TShiftState): Boolean; override;
    function KeyUp(var Key: Word; Shift: TShiftState): Boolean; override;

    function MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean; override;
    function MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean; override;
    function MouseMove(Shift: TShiftState; X, Y: Integer): Boolean; override;

    procedure Enter(); override;
    procedure Leave(); override;
    procedure SetFocus(); override;
    function GetText(): string;
    function Selected(): Boolean; override;
    procedure PositionChange(Sender: TObject);
    procedure TextChange();

    property Lines: TStrings read FLines;
    property ItemIndex: Integer read FCaretY write SetCaretY;

    procedure RefListWidth(ItemIndex: Integer; nCaret: Integer);
  published
    property OnChange: TOnClick read FOnChange write FOnChange;
    property FrameColor: TColor read FFrameColor write FFrameColor;

    property UpDown: TDUpDown read FUpDown write SetUpDown;
    property boTransparent: Boolean read FTransparent write FTransparent;
    property MaxLength: Integer read FMaxLength write FMaxLength default 0;
  end;

  TDMemoStringList = class(TStringList)
    DMemo: TDMemo;
  private
    procedure Put(Index: Integer; const Value: string); reintroduce;
    function SelfGet(Index: Integer): string;
  published
  public
    function Add(const S: string): Integer; override;
    function AddObject(const S: string; AObject: TObject): Integer; override;
    procedure InsertObject(Index: Integer; const S: string; AObject: TObject); override;
    function Get(Index: Integer): string; override;

    function GetText: PChar; override;
    procedure LoadFromFile(const FileName: string); override;
    procedure SaveToFile(const FileName: string); override;

    property Str[Index: Integer]: string read SelfGet write Put; default;
    procedure Assign(Source: TPersistent); override;
    procedure Clear; override;
  end;



procedure Register;

procedure SetDFocus(dcon: TDControl);
procedure ReleaseDFocus;

procedure SetDCapture(dcon: TDControl);
procedure ReleaseDCapture;

procedure SetSelectedControl(dcon: TDControl); //选择
procedure ReleaseSelectedControl();

procedure SetDKocus(dcon: TDControl);
procedure ReleaseDKocus;

//检查是否是双字节
function IsMBCSChar(const Ch: Char): Boolean;
//所有字符
function IsAllChars(const Key: Char): Boolean;
//数字
function IsIntegerChars(const Key: Char): Boolean;
//英文
function IsEnglishChars(const Key: Char): Boolean;
//标准中文
function IsStandardChars(const Key: Char): Boolean;
//密钥字符
function IsCDKeyChars(const Key: Char): Boolean;

var
  KeyControl: TDControl;

  MouseCaptureControl: TDControl; //mouse message
  FocusedControl: TDControl; //Key message

  MouseEntryControl: TDControl = nil;
  KeyDownControl: TDControl = nil;

  ActiveMenu: TDPopupMenu; //TDPopupMenu定义
  //lDEditMenu: TDEditMenu;
  MainWinHandle: Integer;
  ModalDWindow: TDControl;
  g_MainHWnd: HWnd;
  DisplaySize: TPoint2px;
  LastMenuControl: TDxEdit = nil;  //Edit定义
  HotKeyProc: function(HotKey: Cardinal): Boolean of object; //Edit定义

  GUIFScreenWidth: Integer = 800;
  GUIFScreenHeight: Integer = 600;

  g_LibClientList: TList;  //支持文件列表
  g_AutoUITrace: Boolean = False; //UI自动追踪
  g_TranFrame: Boolean = False; //控制是否显示边框
  g_DragMode: Boolean = False;   //设计模式
  SeletedControl: TDControl; // 为 UI 设计

  UITraceProc: TUITraceProc;
  MouseControl: TDControl; // 本次鼠标指向的组件
  LastMouseControl: TDControl;
  MovedControl: TDControl;  // 移动拖拽的组件
  DragStartX: Integer;      // 组件拖动的起始 XY
  DragStartY: Integer;
  DragControlX: Integer;
  DragControlY: Integer;
  UIControlPostionChange: TOnControlPostionChange;

  //Imagebar 绘制触发
  GetClipValueProc: TOnGetClipValue;

  //按钮标题TXT
  GetTextVar: TOnGetTextVar;

  FrmShowIME: Boolean = False;
  FrmIMEX: Integer = 0;
  FrmIMEY: Integer = 0;
  HklKeyboardLayout: LongWord = 0;

implementation


//uses
//  ClMain, FState;

procedure Register;
begin
  RegisterComponents('HGEGUI', [TDWinManager, TDPopupMenu, TDLabel, TDEdit, TDImageEdit,
    TDButton, TDCheckBox, TDGrid, TDWindow, TDWindowMiniMap,
    TDMoveButton, TDxEdit, TDComboBox, TDListBox, TDxHint, TDAniButton, TDImageGrid,
    TDImageBar, TDUpDown, TDMemo]);
end;

function IsMBCSChar(const Ch: Char): Boolean;
begin
  Result := (ByteType(Ch, 1) <> mbSingleByte);
end;

function IsAllChars(const Key: Char): Boolean;
begin
  Result := False;
  if ((Key >= #$0020) and (Key <= #$00FE)) or
   ((Key >= #$4E00) and (Key <= #$9FA5)) then
    Result := True;
end;

function IsIntegerChars(const Key: Char): Boolean;
begin
  Result := False;
  if (Key >= #$0030) and (Key <= #$0039) then
    Result := True;
end;

function IsEnglishChars(const Key: Char): Boolean;
begin
  Result := False;
  if (Key >= #$0021) and (Key <= #$007E) then
    Result := True;
end;

function IsStandardChars(const Key: Char): Boolean;
begin
  Result := False;
  if ((Key >= #$0030) and (Key <= #$0039)) or
   ((Key >= #$0041) and (Key <= #$005A)) or
   ((Key >= #$0061) and (Key <= #$007A)) or
   ((Key >= #$4E00) and (Key <= #$9FA5)) then
    Result := True;
end;

function IsCDKeyChars(const Key: Char): Boolean;
begin
  Result := False;
  if ((Key >= #$0030) and (Key <= #$0039)) or
   ((Key >= #$0041) and (Key <= #$005A)) or
   ((Key >= #$0061) and (Key <= #$007A)) or
   (Key = #$005F)  then
    Result := True;
end;

procedure SetDKocus(dcon: TDControl);
begin
  if KeyControl <> dcon then begin
    if (KeyControl <> nil) then
      KeyControl.Leave;
    dcon.Enter;
  end;
  KeyControl := dcon;
end;

procedure ReleaseDKocus;
begin
  if (KeyControl <> nil) then begin
    KeyControl.Leave;
  end;
  KeyControl := nil;
end;

procedure SetDFocus(dcon: TDControl);
begin
  FocusedControl := dcon;
  if dcon.FKeyFocus then
    SetDKocus(dcon);
end;

procedure ReleaseDFocus;
begin
  FocusedControl := nil;
end;

procedure SetDCapture(dcon: TDControl);
begin
  MouseCaptureControl := dcon;
end;

procedure ReleaseDCapture;
begin
  MouseCaptureControl := nil;
end;

procedure SetSelectedControl(dcon: TDControl);
var
  boCheck: Boolean;
begin
  boCheck := SeletedControl <> dcon;   //在本窗口不触发
  SeletedControl := dcon;
  if Assigned(UITraceProc) and boCheck then
    UITraceProc(dcon);
end;

procedure ReleaseSelectedControl();
begin
  SeletedControl := nil;
end;

{================================Edit函数============================}
function IsKeyPressed(Key: Byte): Boolean;
var
  keyvalue: TKeyBoardState;
begin
  Result := False;
  FillChar(keyvalue, SizeOf(TKeyBoardState), #0);
  if GetKeyboardState(keyvalue) then
    if (keyvalue[Key] and $80) <> 0 then
      Result := True;
end;

const
  // Windows 2000/XP multimedia keys (adapted from winuser.h and renamed to avoid potential conflicts)
  // See also: http://msdn.microsoft.com/library/default.asp?url=/library/en-us/winui/winui/WindowsUserInterface/UserInput/VirtualKeyCodes.asp
  _VK_BROWSER_BACK = $A6; // Browser Back key
  _VK_BROWSER_FORWARD = $A7; // Browser Forward key
  _VK_BROWSER_REFRESH = $A8; // Browser Refresh key
  _VK_BROWSER_STOP = $A9; // Browser Stop key
  _VK_BROWSER_SEARCH = $AA; // Browser Search key
  _VK_BROWSER_FAVORITES = $AB; // Browser Favorites key
  _VK_BROWSER_HOME = $AC; // Browser Start and Home key
  _VK_VOLUME_MUTE = $AD; // Volume Mute key
  _VK_VOLUME_DOWN = $AE; // Volume Down key
  _VK_VOLUME_UP = $AF; // Volume Up key
  _VK_MEDIA_NEXT_TRACK = $B0; // Next Track key
  _VK_MEDIA_PREV_TRACK = $B1; // Previous Track key
  _VK_MEDIA_STOP = $B2; // Stop Media key
  _VK_MEDIA_PLAY_PAUSE = $B3; // Play/Pause Media key
  _VK_LAUNCH_MAIL = $B4; // Start Mail key
  _VK_LAUNCH_MEDIA_SELECT = $B5; // Select Media key
  _VK_LAUNCH_APP1 = $B6; // Start Application 1 key
  _VK_LAUNCH_APP2 = $B7; // Start Application 2 key
  // Self-invented names for the extended keys
  NAME_VK_BROWSER_BACK = 'Browser Back';
  NAME_VK_BROWSER_FORWARD = 'Browser Forward';
  NAME_VK_BROWSER_REFRESH = 'Browser Refresh';
  NAME_VK_BROWSER_STOP = 'Browser Stop';
  NAME_VK_BROWSER_SEARCH = 'Browser Search';
  NAME_VK_BROWSER_FAVORITES = 'Browser Favorites';
  NAME_VK_BROWSER_HOME = 'Browser Start/Home';
  NAME_VK_VOLUME_MUTE = 'Volume Mute';
  NAME_VK_VOLUME_DOWN = 'Volume Down';
  NAME_VK_VOLUME_UP = 'Volume Up';
  NAME_VK_MEDIA_NEXT_TRACK = 'Next Track';
  NAME_VK_MEDIA_PREV_TRACK = 'Previous Track';
  NAME_VK_MEDIA_STOP = 'Stop Media';
  NAME_VK_MEDIA_PLAY_PAUSE = 'Play/Pause Media';
  NAME_VK_LAUNCH_MAIL = 'Start Mail';
  NAME_VK_LAUNCH_MEDIA_SELECT = 'Select Media';
  NAME_VK_LAUNCH_APP1 = 'Start Application 1';
  NAME_VK_LAUNCH_APP2 = 'Start Application 2';

const
  mmsyst = 'winmm.dll';
  kernel32 = 'kernel32.dll';
  HotKeyAtomPrefix = 'HotKeyManagerHotKey';
  ModName_Shift = 'Shift';
  ModName_Ctrl = 'Ctrl';
  ModName_Alt = 'Alt';
  ModName_Win = 'Win';
  VK2_SHIFT = 32;
  VK2_CONTROL = 64;
  VK2_ALT = 128;
  VK2_WIN = 256;

var
  EnglishKeyboardLayout: HKL;
  ShouldUnloadEnglishKeyboardLayout: Boolean;
  LocalModName_Shift: string = ModName_Shift;
  LocalModName_Ctrl: string = ModName_Ctrl;
  LocalModName_Alt: string = ModName_Alt;
  LocalModName_Win: string = ModName_Win;

function IsExtendedKey(Key: Word): Boolean;
begin
  Result := ((Key >= _VK_BROWSER_BACK) and (Key <= _VK_LAUNCH_APP2));
end;

function GetHotKey(Modifiers, Key: Word): Cardinal;
var
  HK: Cardinal;
begin
  HK := 0;
  if (Modifiers and MOD_ALT) <> 0 then
    Inc(HK, VK2_ALT);
  if (Modifiers and MOD_CONTROL) <> 0 then
    Inc(HK, VK2_CONTROL);
  if (Modifiers and MOD_SHIFT) <> 0 then
    Inc(HK, VK2_SHIFT);
  if (Modifiers and MOD_WIN) <> 0 then
    Inc(HK, VK2_WIN);
  HK := HK shl 8;
  Inc(HK, Key);
  Result := HK;
end;

procedure SeparateHotKey(HotKey: Cardinal; var Modifiers, Key: Word);
var
  Virtuals: Integer;
  v: Word;
  X: Word;
begin
  Key := Byte(HotKey);
  X := HotKey shr 8;
  Virtuals := X;
  v := 0;
  if (Virtuals and VK2_WIN) <> 0 then
    Inc(v, MOD_WIN);
  if (Virtuals and VK2_ALT) <> 0 then
    Inc(v, MOD_ALT);
  if (Virtuals and VK2_CONTROL) <> 0 then
    Inc(v, MOD_CONTROL);
  if (Virtuals and VK2_SHIFT) <> 0 then
    Inc(v, MOD_SHIFT);
  Modifiers := v;
end;

function HotKeyToText(HotKey: Cardinal; Localized: Boolean): string;

  function GetExtendedVKName(Key: Word): string;
  begin
    case Key of
      _VK_BROWSER_BACK:
        Result := NAME_VK_BROWSER_BACK;
      _VK_BROWSER_FORWARD:
        Result := NAME_VK_BROWSER_FORWARD;
      _VK_BROWSER_REFRESH:
        Result := NAME_VK_BROWSER_REFRESH;
      _VK_BROWSER_STOP:
        Result := NAME_VK_BROWSER_STOP;
      _VK_BROWSER_SEARCH:
        Result := NAME_VK_BROWSER_SEARCH;
      _VK_BROWSER_FAVORITES:
        Result := NAME_VK_BROWSER_FAVORITES;
      _VK_BROWSER_HOME:
        Result := NAME_VK_BROWSER_HOME;
      _VK_VOLUME_MUTE:
        Result := NAME_VK_VOLUME_MUTE;
      _VK_VOLUME_DOWN:
        Result := NAME_VK_VOLUME_DOWN;
      _VK_VOLUME_UP:
        Result := NAME_VK_VOLUME_UP;
      _VK_MEDIA_NEXT_TRACK:
        Result := NAME_VK_MEDIA_NEXT_TRACK;
      _VK_MEDIA_PREV_TRACK:
        Result := NAME_VK_MEDIA_PREV_TRACK;
      _VK_MEDIA_STOP:
        Result := NAME_VK_MEDIA_STOP;
      _VK_MEDIA_PLAY_PAUSE:
        Result := NAME_VK_MEDIA_PLAY_PAUSE;
      _VK_LAUNCH_MAIL:
        Result := NAME_VK_LAUNCH_MAIL;
      _VK_LAUNCH_MEDIA_SELECT:
        Result := NAME_VK_LAUNCH_MEDIA_SELECT;
      _VK_LAUNCH_APP1:
        Result := NAME_VK_LAUNCH_APP1;
      _VK_LAUNCH_APP2:
        Result := NAME_VK_LAUNCH_APP2;
    else
      Result := '';
    end;
  end;

  function GetModifierNames: string;
  var
    s: string;
  begin
    s := '';
    if Localized then
    begin
      if (HotKey and $4000) <> 0 then // scCtrl
        s := s + LocalModName_Ctrl + '+';
      if (HotKey and $2000) <> 0 then // scShift
        s := s + LocalModName_Shift + '+';
      if (HotKey and $8000) <> 0 then // scAlt
        s := s + LocalModName_Alt + '+';
      if (HotKey and $10000) <> 0 then
        s := s + LocalModName_Win + '+';
    end
    else
    begin
      if (HotKey and $4000) <> 0 then // scCtrl
        s := s + ModName_Ctrl + '+';
      if (HotKey and $2000) <> 0 then // scShift
        s := s + ModName_Shift + '+';
      if (HotKey and $8000) <> 0 then // scAlt
        s := s + ModName_Alt + '+';
      if (HotKey and $10000) <> 0 then
        s := s + ModName_Win + '+';
    end;
    Result := s;
  end;

  function GetVKName(Special: Boolean): string;
  var
    scanCode: Cardinal;
    KeyName: array[0..255] of Char;
    oldkl: HKL;
    Modifiers, Key: Word;
  begin
    Result := '';
    if Localized then {// Local language key names}
    begin
      if Special then
        scanCode := (MapVirtualKey(Byte(HotKey), 0) shl 16) or (1 shl 24)
      else
        scanCode := (MapVirtualKey(Byte(HotKey), 0) shl 16);
      if scanCode <> 0 then
      begin
        GetKeyNameText(scanCode, KeyName, SizeOf(KeyName));
        Result := KeyName;
      end;
    end
    else {// English key names}
    begin
      if Special then
        scanCode := (MapVirtualKeyEx(Byte(HotKey), 0, EnglishKeyboardLayout) shl 16) or (1 shl 24)
      else
        scanCode := (MapVirtualKeyEx(Byte(HotKey), 0, EnglishKeyboardLayout) shl 16);
      if scanCode <> 0 then
      begin
        oldkl := GetKeyboardLayout(0);
        if oldkl <> EnglishKeyboardLayout then
          ActivateKeyboardLayout(EnglishKeyboardLayout, 0); // Set English kbd. layout
        GetKeyNameText(scanCode, KeyName, SizeOf(KeyName));
        Result := KeyName;
        if oldkl <> EnglishKeyboardLayout then
        begin
          if ShouldUnloadEnglishKeyboardLayout then
            UnloadKeyboardLayout(EnglishKeyboardLayout); // Restore prev. kbd. layout
          ActivateKeyboardLayout(oldkl, 0);
        end;
      end;
    end;

    if Length(Result) <= 1 then
    begin
      // Try the internally defined names
      SeparateHotKey(HotKey, Modifiers, Key);
      if IsExtendedKey(Key) then
        Result := GetExtendedVKName(Key);
    end;
  end;

var
  KeyName: string;
begin
  case Byte(HotKey) of
    // PgUp, PgDn, End, Home, Left, Up, Right, Down, Ins, Del
    $21..$28, $2D, $2E:
      KeyName := GetVKName(True);
  else
    KeyName := GetVKName(False);
  end;
  Result := GetModifierNames + KeyName;
end;
{===============================Edit函数结束================================================}


{ TColors }

constructor TColors.Create;
begin
  inherited Create;
  FDisabled := clBtnFace;
  FSelected := clWhite;
  FBkgrnd := clWhite;
  FBorder := $007F7F7F;
  FFont := clBlack;
  FUp := $00F1EFAB;
  FHot := clNavy;
  FDown := $00F1EFAB;
  FLine := clBtnFace;
end;
{----------------------------- TDControl -------------------------------}

constructor TDControl.Create(aowner: TComponent);
begin
  CreatePropertites;
  inherited Create(aowner);
  DParent := nil;
  inherited Visible := False;
  FMouseFocus := True;
  Background := False;
  FKeyFocus := False;
  FOnDirectPaint := nil;
  FOnEndDirectPaint := nil;
  FOnKeyPress := nil;
  FOnKeyDown := nil;
  FOnMouseMove := nil;
  FOnMouseDown := nil;
  FOnMouseUp := nil;
  FOnInRealArea := nil;
  DControls := TList.Create;
  FDParent := nil;

  Width := 80;
  Height := 24;
  FCaption := '';
  FVisible := True;
  FIsHide := True;

  FMouseEntry := msOut;

  WLib := nil;
  ULib := nil;

  FaceIndex := 0;
  FaceName := '';
  PageActive := False;

  FAppendData := nil;
  AppendTick := GetTickCount;

  FDefColor := clWhite;
  FMoveColor := clWhite;
  FDownColor := clWhite;
  FEnabledColor := clGray;
  FBackColor := clBlack;

  FImages := nil;
  FImageIndex := -1;
  FMoveIndex := -1;
  FDownedIndex := -1;
  FDisabledIndex := -1;
  FCheckedIndex := -1;

  FAnchorX := 0;
  FAnchorY := 0;
  FAnchorPostion := False;
  FAnchorPx := 0;
  FAnchorPy := 0;
  FInSetAnchorX := False;
  FInSetAnchorY := False;
  FMouseThrough := False;
  FDrawMode := dmDefault;

  FOnEnter := nil;
  FOnLeave := nil;
  FOnVisible := nil;
  FReadOnly := False;

  FWheelDControl := nil;
  FText := '';

end;

procedure TDControl.CreatePropertites;
begin
  FPropertites := TDXButtonPropertites.Create(Self);
  FDXImageLib := TDXButtonImageProperty.Create(FPropertites);
end;

procedure TDControl.CreateSurface(w, h: Integer; boActive: Boolean);
begin
  if FSurface <> nil then
    FSurface.Free;
  FSurface := nil;

  if w < Width then
    w := Width;

  if h < Height then
    h := Height;

  FSurface := TDXImageTexture.Create(g_DXCanvas);
  FSurface.Size := Point(w, h);
  FSurface.PatternSize := Point(w, h);
  FSurface.Format := D3DFMT_A4R4G4B4;
  FSurface.Active := boActive;
end;

procedure TDControl.CreateSurface(Lib: TWMImages; boActive: Boolean; index: integer);
var
  d: TDXTexture;
begin
  if FSurface <> nil then
    FSurface.Free;
  FSurface := nil;
  if Lib <> nil then begin
    d := Lib.Images[index];
    if d <> nil then begin
      FSurface := TDXImageTexture.Create(g_DXCanvas);
      FSurface.Size := d.Size;
      FSurface.PatternSize := d.Size;
      FSurface.Format := d.Format;
      FSurface.Active := boActive;
    end;
  end else begin
    FSurface := TDXImageTexture.Create(g_DXCanvas);
    FSurface.Size := Point(Width, Height);
    FSurface.PatternSize := Point(Width, Height);
    FSurface.Format := D3DFMT_A4R4G4B4;
    FSurface.Active := boActive;
  end;
end;

destructor TDControl.Destroy;
begin
  DControls.Free;
  if FSurface <> nil then
    FSurface.Free;
  FSurface := nil;
  inherited Destroy;
end;

procedure TDControl.SaveDragStart(Control: TDControl; X, Y: Integer);
begin
  MovedControl := Control;
  // 传递进来的位置是 父窗口的位置
  if g_DragMode then
  begin
    DragStartX := Control.SurfaceX(X);
    DragStartY := Control.SurfaceY(Y);

    DragControlX := Control.Left;
    DragControlY := Control.Top;
  end;
end;

procedure TDControl.ResetXY(X, Y: Integer);
var
  nRealX, nRealY: Integer;
  ControlX, ControlY: Integer;
  SurfaceX, SurfaceY: Integer;
begin
  // 计算两次相差了多少 像素
  SurfaceX := X;
  SurfaceY := Y;

  nRealX := DragStartX - SurfaceX;
  nRealY := DragStartY - SurfaceY;

  ControlX := DragControlX - nRealX;
  ControlY := DragControlY - nRealY;

  //改变位置
//  Left := ControlX;
//  Top := ControlY;
  FPropertites.SetPosition(1, ControlX);
  FPropertites.SetPosition(2, ControlY);
end;

procedure TDControl.SetAnchorPoint(const Value: Boolean);
begin
  if Value <> FAnchorPostion then
  begin
    FAnchorPostion := Value;
    if Value then begin
      LayoutAnchorPoint;
    end;
  end;
end;

function TDControl.Selected: Boolean;
begin
  Result := False;
end;

procedure TDControl.SetAnchor(index: Integer; Value: Single);
begin
  case index  of
    //X
    1:begin
      FAnchorX := Value;
      FInSetAnchorX := True;
    end;      //Y
    2:Begin
      FAnchorY := Value;
      FInSetAnchorY := True;
    End;
    3:begin
      FAnchorPx := Trunc(Value);
    end;
    4:Begin
      FAnchorPy := Trunc(Value);
    End;
  end;
  LayoutAnchorPoint();
end;

procedure TDControl.LayoutAnchorPoint;
var
  nValue : Integer;
begin
  if not (csDesigning in ComponentState) then begin
    if (DParent <> nil) and (FAnchorPostion) then
    begin
      nValue := Trunc((DParent.Width - Width) * FAnchorX);
      Left := nValue + Trunc(FAnchorPx);

      nValue := Trunc((DParent.Height - Height) * FAnchorY);
      Top := nValue + Trunc(FAnchorPy);
    end;
  end
end;

procedure TDControl.Leave;
begin
  if Assigned(FOnLeave) then
    FOnLeave(Self);
end;

procedure TDControl.SetCaption(Str: string);
begin
  FCaption := Str;
  if csDesigning in ComponentState then
  begin
    Refresh;
  end;
end;

procedure TDControl.SetFocus;
begin
  SetDFocus(Self);
end;

procedure TDControl.AdjustPos(X, Y: Integer);
begin
  Top := Y;
  Left := X;
end;

procedure TDControl.AdjustPos(X, Y, W, H: Integer);
begin
  Left := X;
  Top := Y;
  Width := W;
  Height := H;
end;

procedure TDControl.Paint;
begin
  if csDesigning in ComponentState then
  begin
    if self is TDWindow then
    begin
      with Canvas do
      begin
        Pen.Color := clBlack;
        MoveTo(0, 0);
        LineTo(Width - 1, 0);
        LineTo(Width - 1, Height - 1);
        LineTo(0, Height - 1);
        LineTo(0, 0);
        LineTo(Width - 1, Height - 1);
        MoveTo(Width - 1, 0);
        LineTo(0, Height - 1);
        TextOut((Width - TextWidth(Caption)) div 2, (Height - TextHeight(Caption)) div 2, Caption);
      end;
    end else begin
      with Canvas do
      begin
        Pen.Color := clBlack;
        MoveTo(0, 0);
        LineTo(Width - 1, 0);
        LineTo(Width - 1, Height - 1);
        LineTo(0, Height - 1);
        LineTo(0, 0);
        SetBkMode(Handle, TRANSPARENT);
        Font.Color := Self.Font.Color;
        TextOut((Width - TextWidth(Caption)) div 2, (Height - TextHeight(Caption)) div 2, Caption);
      end;
    end;
  end;
end;

procedure TDControl.PositionChanged;
var
  I: integer;
begin
  //FPositionChanged := True;
  for I := 0 to DControls.Count - 1 do
    TDControl(DControls[I]).PositionChanged;
end;

procedure TDControl.Loaded;
var
  i: Integer;
  dcon: TDControl;
begin
  if not (csDesigning in ComponentState) then
  begin
    if Parent <> nil then
    begin
      for i := 0 to TControl(Parent).ComponentCount - 1 do
      begin
        if TControl(Parent).Components[i] is TDControl then
        begin
          dcon := TDControl(TControl(Parent).Components[i]);
          if dcon.DParent = self then
          begin
            AddChild(dcon);
          end;
        end;
      end;
    end;
  end;
end;

function TDControl.SurfaceX(X: Integer): Integer;
var
  d: TDControl;
begin
  d := self;
  while True do
  begin
    if d.DParent = nil then
      Break;
    X := X + d.DParent.Left;
    d := d.DParent;
  end;
  Result := X;
end;

function TDControl.SurfaceY(Y: Integer): Integer;
var
  d: TDControl;
begin
  d := self;
  while True do
  begin
    if d.DParent = nil then
      Break;
    Y := Y + d.DParent.Top;
    d := d.DParent;
  end;
  Result := Y;
end;

//宽度高度改变。
procedure TDControl.WidthChanged(Width: Integer);
//var
//  I: integer;
begin
//  for I := 0 to DControls.Count - 1 do
//    DControls[I].ParentWidthChanged(width);
end;

procedure TDControl.HeightChanged(Height: Integer);
//var
//  I:Integer;
begin
//  for I := 0 to DControls.Count - 1 do
//    DControls[I].ParentHeightChanged(Height);
end;

function TDControl.LocalX(X: Integer): Integer;
var
  d: TDControl;
begin
  d := Self;
  while True do
  begin
    if d.DParent = nil then
      Break;
    X := X - d.DParent.Left;
    d := d.DParent;
  end;
  Result := X;
end;

function TDControl.LocalY(Y: Integer): Integer;
var
  d: TDControl;
begin
  d := Self;
  while True do
  begin
    if d.DParent = nil then
      Break;
    Y := Y - d.DParent.Top;
    d := d.DParent;
  end;
  Result := Y;
end;

procedure TDControl.AddChild(dcon: TDControl);
begin
  DControls.Add(Pointer(dcon));
end;

procedure TDControl.ChangeChildOrder(dcon: TDControl);
var
  i: integer;
  DWindow: TDWindow;
begin
  if not (dcon is TDWindow) then
    Exit;
  DWindow := TDWindow(dcon);
  if DWindow.FControlStyle = dsBottom then exit;
  for i := 0 to DControls.Count - 1 do begin
    if dcon = DControls[i] then begin
      DControls.Delete(i);
      Break;
    end;
  end;
  if DWindow.FControlStyle = dsTop then begin
    DControls.Add(dcon);
    Exit;
  end
  else if DWindow.FControlStyle = dsNone then begin
    for i := DControls.Count - 1 downto 0 do begin
      if TDControl(DControls[i]) is TDWindow then begin
        DWindow := TDWindow(DControls[i]);
        if (DWindow.FControlStyle <> dsTop) then begin
          if i = (DControls.Count - 1) then
            DControls.Add(dcon)
          else begin
            DControls.Insert(i + 1, dcon);
          end;
          Exit;
        end;
      end;
    end;
  end;
  DControls.Add(dcon);
end;

procedure TDControl.InitImageLib;
var
  nWLib: Integer;
  i: Integer;
  ClientLib: TWMImages;
begin
  if not(csDesigning in ComponentState) then
  begin
    nWLib := -1;
    case FLib of
      Prguse_Pak:     nWLib := 0;
      Prguse_16_Pak:  nWLib := 1;
      Prguse:         nWLib := 42;
      Prguse2:        nWLib := 43;
      Prguse3:        nWLib := 44;
      ui1:            nWLib := 47;
      ui3:            nWLib := 49;
      ui_common:      nWLib := 51;
      ui_n:           nWLib := 52;
      ChrSel:         nWLib := 54;
      nselect:        nWLib := 55;
    end;

    if FLib = nill then begin
      FImages := nil;
      Exit;
    end;

    if (nWLib > -1) and (g_LibClientList.Count > 0) then begin
      for I := 0 to g_LibClientList.Count - 1 do begin
        ClientLib := TWMImages(g_LibClientList.Items[i]);
        if (ClientLib <> nil) and (i = nWLib) then begin
          FImages := ClientLib;
          SetImgIndex(FImages, FaceIndex);
          Exit;
        end;
      end;
    end;
  end;
end;

function TDControl.InRange(X, Y: Integer; Shift: TShiftState): Boolean;
var
  boInRange: Boolean;
  d: TDXTexture;
begin
  if (X >= Left) and (X < (Left + Width)) and (Y >= Top) and (Y < (Top + Height)) and
   (((ssRight in Shift)) or not (ssRight in Shift)) then
  begin
    boInRange := True;
    if Assigned(FOnInRealArea) then begin
      FOnInRealArea(self, X - Left, Y - Top, boInRange);
    end else
    if (WLib <> nil) and (not (Self is TDImageGrid){TDImageGrid}) then begin
      d := WLib.Images[FaceIndex];
      if d <> nil then begin
        if (d.Pixels[X - Left, Y - Top] <= 0) or (d.Pixels[X - Left, Y - Top] = 16777215) then
          boInRange := False;
      end;
    end else
    if (ULib <> nil) and (not (Self is TDImageGrid){TDImageGrid}) then begin
      d := ULib.Images[FaceName];
      if d <> nil then begin
        if (d.Pixels[X - Left, Y - Top] <= 0) or (d.Pixels[X - Left, Y - Top] = 16777215) then
          boInRange := False;
      end;
    end;

    //穿透区域
    if FMouseThrough then
      boInRange := False;


    //自定义UI应该返回True方便选中控件
    if g_DragMode or g_AutoUITrace then
      boInRange := True;

    Result := boInRange;
  end else begin
    Result := False;
  end;
end;

procedure TDControl.IsVisible(flag: Boolean);
var
  I: Integer;
begin
  for i := 0 to DControls.Count - 1 do
    TDControl(DControls[i]).IsVisible(flag);
  FIsHide := not flag;
  if not (csReading in ComponentState) then begin
    if Assigned(FOnVisible) then
      FOnVisible(Self, flag);
  end;
end;

function TDControl.KeyPress(var Key: Char): Boolean;
var
  i: Integer;
begin
  Result := False;
  if Background then
    Exit;

//  for i := DControls.count - 1 downto 0 do
//  begin
//    if TDControl(DControls[i]).Visible then
//    begin
//      if TDControl(DControls[i]).KeyPress(Key) then
//      begin
//        Result := True;
//        Exit;
//      end;
//    end;
//  end;

  if (KeyControl = Self) then
  begin
    if Assigned(FOnKeyPress) then
      FOnKeyPress(self, Key);
    Result := True;
  end;
end;

function TDControl.KeyUp(var Key: Word; Shift: TShiftState): Boolean;
begin
  Result := False;

  if (KeyControl = self) then begin
    if Assigned(FOnKeyUp) then
      FOnKeyUp(self, Key, Shift);
    Result := TRUE;
  end;
end;

function TDControl.KeyDown(var Key: Word; Shift: TShiftState): Boolean;
var
  i: Integer;
begin
  Result := False;
  if Background then
    Exit;

  if (KeyControl = Self) then
  begin
    KeyDownControl := Self;
    if Assigned(FOnKeyDown) then
      FOnKeyDown(self, Key, Shift);
    Result := True;
  end;
end;

function TDControl.CanFocusMsg: Boolean;
begin
  if (MouseCaptureControl = nil) or ((MouseCaptureControl <> nil) and ((MouseCaptureControl = Self) or (MouseCaptureControl = DParent))) then
    Result := True
  else
    Result := False;
end;

function TDControl.MouseMove(Shift: TShiftState; X, Y: Integer): Boolean;
var
  i: Integer;
  dc: TDControl;
begin
  Result := False;

  for i := DControls.count - 1 downto 0 do
  begin
    dc := TDControl(DControls[i]);
    if dc.Visible then
    begin
      if dc.MouseMove(Shift, X - Left, Y - Top) then
      begin
        Result := True;
        Exit;
      end;
    end;
  end;

  if (MouseCaptureControl <> nil) then
  begin
    if (MouseCaptureControl = Self) then
    begin
      if Assigned(FOnMouseMove) then
        FOnMouseMove(Self, Shift, X, Y);
      Result := True;
    end;
    Exit;
  end;

  if Background then
  begin
    if (MouseEntryControl <> nil) and (MouseEntryControl <> self) then begin
      MouseEntryControl.FMouseEntry := msOut;
//      if Assigned(MouseEntryControl.FOnMouseEntry) then
//        MouseEntryControl.FOnMouseEntry(MouseEntryControl,
//          MouseEntryControl.FMouseEntry);
      MouseEntryControl := nil;
    end;
    if (MouseEntryControl = nil) then begin
      MouseEntryControl := Self;
      FMouseEntry := msIn;
//      if Assigned(FOnMouseEntry) then
//        FOnMouseEntry(Self, FMouseEntry);
    end;
    Exit;
  end;

  if InRange(X, Y, Shift) then
  begin
    if (MouseEntryControl <> nil) and (MouseEntryControl <> Self) then begin
      MouseEntryControl.FMouseEntry := msOut;
//      if Assigned(MouseEntryControl.FOnMouseEntry) then
//        MouseEntryControl.FOnMouseEntry(MouseEntryControl,
//          MouseEntryControl.FMouseEntry);
      MouseEntryControl := nil;
    end;
    if (MouseEntryControl = nil) then begin
      MouseEntryControl := Self;
      FMouseEntry := msIn;
//      if Assigned(FOnMouseEntry) then
//        FOnMouseEntry(MouseEntryControl, FMouseEntry);
    end;

    if g_AutoUITrace then begin //选中控件
      SetSelectedControl(Self);
    end;

    if Assigned(FOnMouseMove) then
      FOnMouseMove(Self, Shift, X, Y);

    MouseControl := Self;
    Result := True;
  end;
end;

function TDControl.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean;
var
  i: Integer;
  dc: TDControl;
begin
  Result := False;

  for i := DControls.count - 1 downto 0 do
  begin
    dc := TDControl(DControls[i]);
    if dc.Visible then
    begin
      if dc.MouseDown(Button, Shift, X - Left, Y - Top) then
      begin
        Result := True;
        Exit;
      end;
    end;
  end;

  if Background then
  begin
    if Assigned(FOnBackgroundClick) then
    begin
      WantReturn := False;
      FOnBackgroundClick(self);
      if WantReturn then
        Result := True;
    end;
    ReleaseDFocus;
    Exit;
  end;

  if CanFocusMsg then begin
    if InRange(X, Y, Shift) or (MouseCaptureControl = self) then begin
      if g_DragMode then begin
        SaveDragStart(Self, X, Y);
      end;

      SetSelectedControl(Self);
      if Assigned(FOnMouseDown) then
        FOnMouseDown(self, Button, Shift, X, Y);
      if FMouseFocus  then
        SetDFocus(self);
      Result := TRUE;
    end;
  end;


//  if CanFocusMsg then
//  begin
//    if InRange(X, Y, Shift) or (MouseCaptureControl = self) then
//    begin
//      if g_DragMode then begin
//        SaveDragStart(Self, X, Y);
//      end;
//
//      SetSelectedControl(Self);
//
//
//      //MouseMoveControl := nil;
//
//      if Assigned(FOnMouseDown) then
//        FOnMouseDown(self, Button, Shift, X, Y);
//
//      if FMouseFocus then
//      begin
//        if (self is TDxHint) and (TDxHint(self).ParentControl <> nil) then
//        begin
//          SetDFocus(TDxHint(self).ParentControl);
//        end
//        else
//          SetDFocus(self);
//      end;
//      Result := True;
//    end;
//  end;
end;

function TDControl.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean;
var
  i: Integer;
  dc: TDControl;
begin
  Result := False;
  for i := DControls.count - 1 downto 0 do
  begin
    dc := TDControl(DControls[i]);
    if dc.Visible then
    begin
      if (dc is TDxHint) then
        dc.Visible := False;
      if dc.MouseUp(Button, Shift, X - Left, Y - Top) then
      begin
        Result := True;
        Exit;
      end;
    end;
  end;

  if (MouseCaptureControl <> nil) then
  begin
    if (MouseCaptureControl = self) then
    begin
      if Assigned(FOnMouseUp) then
        FOnMouseUp(self, Button, Shift, X, Y);
      Result := True;
    end;
    Exit;
  end;

  if Background then
    Exit;

  if InRange(X, Y, Shift) then
  begin
    if Assigned(FOnMouseUp) then
      FOnMouseUp(self, Button, Shift, X, Y);
    Result := True;
  end;
end;

function TDControl.MouseWheel(Shift: TShiftState; Wheel: TMouseWheel; X, Y: Integer): Boolean;
var
  i: integer;
begin
  Result := False;
  for i := DControls.Count - 1 downto 0 do begin
    if TDControl(DControls[i]).Visible then begin
      if TDControl(DControls[i]).MouseWheel(Shift, Wheel, X - Left, Y - Top) then begin
        Result := TRUE;
        Exit;
      end;
    end;
  end;

  if FWheelDControl <> nil then begin
    FWheelDControl.MouseWheel(Shift, Wheel, X - Left, Y - Top);
    Result := True;
  end;
end;

function TDControl.DblClick(X, Y: Integer): Boolean;
var
  i: Integer;
begin
  Result := False;
  if (MouseCaptureControl <> nil) then
  begin
    if (MouseCaptureControl = Self) then
    begin
      if Assigned(FOnDblClick) then
        FOnDblClick(Self);
      Result := True;
    end;
    Exit;
  end;

  for i := DControls.count - 1 downto 0 do
  begin
    if TDControl(DControls[i]).Visible then
    begin
      if TDControl(DControls[i]).DblClick(X - Left, Y - Top) then
      begin
        Result := True;
        Exit;
      end;
    end;
  end;

  if Background then
    Exit;
  if InRange(X, Y, [ssDouble]) then
  begin
    if Assigned(FOnDblClick) then
      FOnDblClick(Self);
    Result := True;
  end;
end;

function TDControl.Click(X, Y: Integer): Boolean;
var
  i: Integer;
begin
  Result := False;

  if g_AutoUITrace then //选中控件
    Exit;

  if (MouseCaptureControl <> nil) then
  begin
    if (MouseCaptureControl = self) then
    begin
      if Assigned(FOnClick) then
      begin
        FOnClick(self, X, Y);
      end;
      Result := True;
    end;
    Exit;
  end;
  for i := DControls.count - 1 downto 0 do
  begin
    if TDControl(DControls[i]).Visible then
    begin
      if TDControl(DControls[i]).Click(X - Left, Y - Top) then
      begin
        Result := True;
        Exit;
      end;
    end;
  end;

  if Background then
    Exit;

  if InRange(X, Y, [ssDouble]) then
  begin
    if Assigned(FOnClick) then
    begin
      FOnClick(self, X, Y);
    end;
    Result := True;
  end;
end;

procedure TDControl.SetImgIndex(Lib: TWMImages; Index: Integer);
var
  d: TDXTexture;
begin
  FImages := Lib;
  FaceIndex := Index;
  if FImages <> nil then
  begin
    d := FImages.Images[FaceIndex];
    if d <> nil then
    begin
      Width := d.Width;
      Height := d.Height;
    end;
  end;
end;

procedure TDControl.SetImgIndex(Lib: TWMImages; Index, X, Y: Integer);
var
  d: TDXTexture;
begin
  FImages := Lib;
  FaceIndex := Index;
  Self.Left := X;
  Self.Top := Y;
  if FImages <> nil then
  begin
    d := FImages.Images[FaceIndex];
    if d <> nil then
    begin
      Width := d.Width;
      Height := d.Height;
    end;
  end;
end;

procedure TDControl.SetImgGridIndex(Lib: TWMImages; Index: Integer);
begin
  FImages := Lib;
  FaceIndex := Index;
  if Self is TDImageGrid then
  begin
    if TDImageGrid(Self).Stretch then
    begin
      if DParent <> nil then
      begin
        Left := TDImageGrid(Self).RelativeLeft;
        Top := TDImageGrid(Self).RelativeTop;
        Width := DParent.Width - TDImageGrid(Self).RelativeLeft - TDImageGrid(Self).RelativeRight;
        Height := DParent.Height - TDImageGrid(Self).RelativeTop - TDImageGrid(Self).RelativeBottom;
      end;
    end;
  end;
end;

procedure TDControl.SetImgName(Lib: TUIBImages; F: string);
var
  d: TDXTexture;
begin
  try
    ULib := Lib;
    FaceName := F;
    if Lib <> nil then
    begin
      d := Lib.Images[F];
      if d <> nil then
      begin
        Width := d.Width;
        Height := d.Height;
      end
      else if not Background then   //123456
        ;                               //ReloadTex := True;
    end;
  except
    on E: Exception do
    begin
    //  debugOutStr('TDControl.SetImgName ' + E.Message);
    end;
  end;
end;

procedure TDControl.DirectPaint(dsurface: TDXTexture);
var
  i: Integer;
  d: TDXTexture;
begin
  if Assigned(FOnDirectPaint) then
  begin
    FOnDirectPaint(self, dsurface);
  end
  else if WLib <> nil then
  begin
    d := WLib.Images[FaceIndex];
    if d <> nil then
      dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, FDrawMode);
    if not Background and (WLib <> nil) and (FaceIndex > 0) then
    begin
      SetImgIndex(WLib, FaceIndex);
    end;
  end
  else if ULib <> nil then
  begin
    d := ULib.Images[FaceName];
    if d <> nil then
      dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, FDrawMode);
    if not Background and (ULib <> nil) and (FaceName <> '') then
    begin
      SetImgName(ULib, FaceName);
    end;
  end;

  for i := 0 to DControls.count - 1 do begin
    if TDControl(DControls[i]).Visible then
      TDControl(DControls[i]).DirectPaint(dsurface);
  end;

  if Assigned(FOnEndDirectPaint) then
    FOnEndDirectPaint(self, dsurface);

  if g_TranFrame then
    g_DXCanvas.RoundRect(SurfaceX(Left), SurfaceY(Top), SurfaceX(Left + Width), SurfaceY(Top + Height), clLime);

  if g_DragMode and (SeletedControl = Self) then
    g_DXCanvas.RoundRect(SurfaceX(Left), SurfaceY(Top), SurfaceX(Left + Width), SurfaceY(Top + Height), clRed);
end;

procedure TDControl.Enter;
begin
  if Assigned(FOnEnter) then
    FOnEnter(Self)
end;

function TDControl.EscClose: Boolean;
var
  i: integer;
begin
  Result := FALSE;
  for i := DControls.Count - 1 downto 0 do begin
    if TDControl(DControls[i]).Visible then begin
      if TDControl(DControls[i]).EscClose then begin
        Result := TRUE;
        Exit;
      end;
    end;
  end;
end;

function TDControl.GetAnchor(index: Integer): Single;
begin
  result := 0;
  case Index of
    1:
      result := FAnchorX;
    2:
      result := FAnchorY;
    3:
      result := Trunc(FAnchorPx);
    4:
      result := Trunc(FAnchorPy);
  end;
end;

function TDControl.GetLeft: integer;
begin
  if csDesigning in ComponentState then
    result := inherited Left
  else
  begin
    result := FPropertites.FLeft;
  end;
end;

procedure TDControl.SetLeft(const Value: integer);
begin
  if csDesigning in ComponentState then
    inherited Left := Value
  else
  begin
    FPropertites.FLeft := Value;
    if DParent <> nil then  begin
      if (not FInSetAnchorX) or (not FAnchorPostion) then begin
        if (DParent.Width <> 0) and ((DParent.Width - Width) <> 0) then
          FAnchorX := Self.Left / (DParent.Width - Width)
        else
          FAnchorX := 0;
      end;
    end;
  end;
  PositionChanged;
end;

function TDControl.GetTop: integer;
begin
  if csDesigning in ComponentState then
    result := inherited Top
  else
    result := FPropertites.FTop;
end;

procedure TDControl.SetTop(const Value: integer);
begin
  if csDesigning in ComponentState then
    inherited Top := Value
  else
  begin
    FPropertites.FTop := Value;
    if DParent <> nil then begin
      if  (not FInSetAnchorX) or (not FAnchorPostion) then begin
        if (DParent.Height <> 0) and ((DParent.Height - Height) <> 0) then
          FAnchorY := Self.Top / (DParent.Height - Height)
        else
          FAnchorY := 0;
      end;
    end;
  end;
  PositionChanged;
end;

procedure TDControl.SetVisible(const Value: Boolean);
begin
  if FVisible <> Value then
    IsVisible(Value);
  FVisible := Value;
end;

function TDControl.GetWidth: integer;
begin
  if csDesigning in ComponentState then
    result := inherited Width
  else
    result := FPropertites.FWidth;
end;

procedure TDControl.SetWidth(const Value: integer);
var
  ChangeWidth:Integer;
begin
  if csDesigning in ComponentState then
    inherited Width := Value
  else
  begin
    ChangeWidth := Value - Width;
    inherited Width := Value;
    FPropertites.FWidth := Value;

    if ChangeWidth <> 0 then
      WidthChanged(ChangeWidth);
  end;
  PositionChanged;
end;

function TDControl.GetHeight: integer;
begin
  if csDesigning in ComponentState then
    result := inherited Height
  else
    result := FPropertites.FHeight;
end;

procedure TDControl.SetHeight(const Value: integer);
var
  ChangeHeight : Integer;
begin
  if csDesigning in ComponentState then
    inherited Height := Value
  else
  begin
    ChangeHeight := Value - Height;
    inherited Height := Value;
    FPropertites.FHeight := Value;

    if ChangeHeight <> 0 then
      HeightChanged(ChangeHeight);
  end;
  PositionChanged;
end;

{--------------------- TDButton --------------------------}

constructor TDButton.Create(aowner: TComponent);
begin
  inherited Create(aowner);
  Downed := False;
  Arrived := False;
  FFloating := False;
  FOnClick := nil;
  FClickSound := csNone;
  btnState := tnor;
  ClickInv := 0;
  Clicked := True;
  ShowText := False;
  FEnabled := True;
end;

function TDButton.MouseMove(Shift: TShiftState; X, Y: Integer): Boolean;
var
  al, at: Integer;
begin
  Result := False;
  if btnState = tdisable then
    Exit;
  btnState := tnor;

  Result := inherited MouseMove(Shift, X, Y);
  Arrived := Result;
  if (not Background) and (not Result) then
  begin
    //Result := inherited MouseMove(Shift, X, Y);
    if MouseCaptureControl = Self then  begin
      if InRange(X, Y, Shift) then
      begin
        Downed := True;
      end else begin
        Downed := False;
      end;
    end;
  end;

  if Result and FFloating and (MouseCaptureControl = Self) then
  begin
    if (SpotX <> X) or (SpotY <> Y) then
    begin
      al := Left + (X - SpotX);
      at := Top + (Y - SpotY);
      Left := al;
      Top := at;
      SpotX := X;
      SpotY := Y;
      //DScreen.AddChatBoardString(format(' - %d %d %d', [tag, Left, Top]), clWhite, clRed);
    end;
  end;
end;

procedure TDButton.CreatePropertites;
begin
  FPropertites := TDXButtonPropertites.Create(Self);
  FDXImageLib := TDXButtonImageProperty.Create(FPropertites);
end;

procedure TDButton.DirectPaint(dsurface: TDXTexture);
var
  d: TDXTexture;
  FColor: TColor;
  i, px, py: integer;
  sText: string;
begin
  if Assigned(FOnDirectPaint) then
    FOnDirectPaint(self, dsurface)
  else if FImages <> nil then begin
    px := 0;
    py := 0;
    if (not FEnabled) and (FDisabledIndex >= 0) then begin            //禁用
      d := FImages.Images[FDisabledIndex];
      if d <> nil then
        dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, FDrawMode);

      FColor := FEnabledColor;
    end
    else if Downed and (FDownedIndex >= 0) then begin                 //按下
      d := FImages.Images[FDownedIndex];
      if d <> nil then
        dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, FDrawMode);

      FColor := FDownColor;

      Inc(px);
      Inc(py);
    end
    else if (MouseEntry = msIn) and (FMoveIndex >= 0) then begin      //经过
      d := FImages.Images[FMoveIndex];
      if d <> nil then
        dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, FDrawMode);

      FColor := FMoveColor;
    end
    else begin
      d := FImages.Images[FaceIndex];            //默认
      if d <> nil then
        dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, FDrawMode);
        
      FColor := FDefColor;
    end;

    with g_DXCanvas do begin
      sText := FText;
      if ShowText and (sText <> '') then begin
        if Assigned(GetTextVar) then begin
          GetTextVar(sText);
        end;

        TextOut(SurfaceX(Left) + (Width - TextWidth(sText)) div 2 + px,
          SurfaceY(Top) + (Height - TextHeight(sText)) div 2 + py, sText, FColor, FBackColor);
      end;
    end;
  end;

  for i := 0 to DControls.Count - 1 do begin
    if TDControl(DControls[i]).Visible then
      TDControl(DControls[i]).DirectPaint(dsurface);
  end;
  
  if Assigned(FOnEndDirectPaint) then
    FOnEndDirectPaint(self, dsurface);

  if g_TranFrame then
    g_DXCanvas.RoundRect(SurfaceX(Left), SurfaceY(Top), SurfaceX(Left + Width), SurfaceY(Top + Height), clLime);

  if g_DragMode and (SeletedControl = Self) then
    g_DXCanvas.RoundRect(SurfaceX(Left), SurfaceY(Top), SurfaceX(Left + Width), SurfaceY(Top + Height), clRed);
end;

function TDButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean;
begin
  Result := False;
  if btnState = tdisable then
    Exit;

  if inherited MouseDown(Button, Shift, X, Y) then
  begin
    if GetTickCount - ClickInv <= 150 then
    begin
      //SetDCapture(self);
      Result := True;
      Exit;
    end;

    if (not Background) and (MouseCaptureControl = nil) then begin
      if g_DragMode then begin
        if MovedControl = nil then begin
          Downed := True;
          SetDCapture(Self);
        end;
      end else begin
        Downed := True;
        SetDCapture(self);
      end;
    end;
    Result := True;

    if Result then
    begin
      if Floating then
      begin
        if DParent <> nil then
          DParent.ChangeChildOrder(self);
      end;
      SpotX := X;
      SpotY := Y;
    end;
  end;
end;

function TDButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean;
begin
  Result := False;
  if btnState = tdisable then
    Exit;

  if inherited MouseUp(Button, Shift, X, Y) then
  begin
    if not Downed then
    begin
      Result := True;
      ClickInv := 0;
      Exit;
    end;
    ReleaseDCapture;
    if not Background then
    begin
      if InRange(X, Y, Shift) then
      begin

        if GetTickCount - ClickInv <= 150 then
        begin
          //Result := True;
          Downed := False;
          Exit;
        end;
        ClickInv := GetTickCount;

        if Assigned(FOnClickSound) then
          FOnClickSound(self, FClickSound);
        if Assigned(FOnClick) then
          FOnClick(self, X, Y);
      end;
    end;

    Downed := False;
    Result := True;
    Exit;
  end
  else
  begin
    ReleaseDCapture;
    Downed := False;
  end;
end;

{--------------------- TDCheckBox --------------------------}

constructor TDCheckBox.Create(aowner: TComponent);
begin
  inherited Create(aowner);
  FArrived := False;
  Checked := False;
  Downed := False;
  FOnClick := nil;
  FClickSound := csNone;
end;

function TDCheckBox.MouseMove(Shift: TShiftState; X, Y: Integer): Boolean;
begin
  Result := inherited MouseMove(Shift, X, Y);
  FArrived := Result;
  if (not Background) and (not Result) then
  begin
    //Result := inherited MouseMove(Shift, X, Y);
    if MouseCaptureControl = self then
      if InRange(X, Y, Shift) then
        Downed := True
      else
        Downed := False;
  end;
end;

function TDCheckBox.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean;
begin
  Result := False;
  if inherited MouseDown(Button, Shift, X, Y) then
  begin
    if (not Background) and (MouseCaptureControl = nil) then
    begin
      Downed := True;
      SetDCapture(self);
    end;
    Result := True;
  end;
end;

function TDCheckBox.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean;
begin
  Result := False;
  if inherited MouseUp(Button, Shift, X, Y) then
  begin
    ReleaseDCapture;
    if not Background then
    begin
      if InRange(X, Y, Shift) then
      begin
        Checked := not Checked;
        if Assigned(FOnClickSound) then
          FOnClickSound(self, FClickSound);
        if Assigned(FOnClick) then
          FOnClick(self, X, Y);
      end;
    end;
    Downed := False;
    Result := True;
    Exit;
  end
  else
  begin
    ReleaseDCapture;
    Downed := False;
  end;
end;

{--------------------- TDLabel --------------------------}

constructor TDLabel.Create(AOwner: TComponent);
begin
  CreatePropertites;
  inherited Create(AOwner);
  Downed := False;
  FOnClick := nil;

  FText := '';
  FClickSound := csNone;
  FAlignment := taLeftJustify;
end;

function TDLabel.MouseMove(Shift: TShiftState; X, Y: Integer): Boolean;
begin
  Result := inherited MouseMove(Shift, X, Y);
  if (not Background) and (not Result) then begin
    if MouseCaptureControl = Self then begin
      if InRange(X, Y, Shift) then
        Downed := True
      else
        Downed := False;
    end;
  end;
end;

procedure TDLabel.CreatePropertites;
begin
  FPropertites := TDXLabelPropertites.Create(Self);
  FDXImageLib := TDXLabelImageProperty.Create(FPropertites);
end;

procedure TDLabel.DirectPaint(dsurface: TDXTexture);
var
  i: integer;
  sText: string;
begin
  sText := FText;
  if sText <> '' then begin
    with g_DXCanvas do begin
      if Assigned(GetTextVar) then begin
        GetTextVar(sText);
      end;
      case FAlignment of //字符串位置
        taLeftJustify: TextOut(SurfaceX(Left), SurfaceY(Top) + (Height - TextHeight(sText)) div 2, sText, FDefColor, FBackColor);
        taCenter: TextOut(SurfaceX(Left) + (Width - TextWidth(sText)) div 2, SurfaceY(Top) + (Height - TextHeight(sText)) div 2, sText, FDefColor, FBackColor);
        taRightJustify: TextOut(SurfaceX(Left) + (Width - TextWidth(sText)), SurfaceY(Top) + (Height - TextHeight(sText)) div 2, sText, FDefColor, FBackColor);
      end;
    end;
  end;

  if g_TranFrame then
    g_DXCanvas.RoundRect(SurfaceX(Left), SurfaceY(Top), SurfaceX(Left + Width), SurfaceY(Top + Height), clLime);

  if g_DragMode and (SeletedControl = Self) then
    g_DXCanvas.RoundRect(SurfaceX(Left), SurfaceY(Top), SurfaceX(Left + Width), SurfaceY(Top + Height), clRed);
end;

function TDLabel.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean;
begin
  Result := False;
  if inherited MouseDown(Button, Shift, X, Y) then begin
    if (not Background) and (MouseCaptureControl = nil) then begin
      Downed := True;
      SetDCapture(Self);
    end;
    Result := True;
  end;
end;

function TDLabel.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y:
  Integer): Boolean;
begin
  Result := FALSE;
  if inherited MouseUp(Button, Shift, X, Y) then begin
    ReleaseDCapture;
    if not Background then begin
      if Downed and InRange(X, Y, Shift) then begin
        if Assigned(FOnClickSound) then
          FOnClickSound(self, FClickSound);
        if Assigned(FOnClick) then
          FOnClick(self, X, Y);
      end;
    end;
    Downed := FALSE;
    Result := TRUE;
    Exit;
  end
  else begin
    ReleaseDCapture;
    Downed := FALSE;
  end;
end;

procedure TDLabel.SetAlignment(Value: TAlignment);
begin
  if FAlignment <> Value then begin
    FAlignment := Value;
  end;
end;

{--------------------- TDCustomControl --------------------------}

constructor TDCustomControl.Create(aowner: TComponent);
begin
  inherited Create(aowner);
  Downed := False;
  FOnClick := nil;
  FClickSound := csNone;
  FTransparent := True;
  FEnabled := True;
  FFrameVisible := True;
  FFrameHot := False;
  FFrameSize := 1;
  FFrameColor := $00406F77;
  FFrameHotColor := $00599AA8;
end;

procedure TDCustomControl.SetTransparent(Value: Boolean);
begin
  if FTransparent <> Value then
    FTransparent := Value;
end;

procedure TDCustomControl.SetEnabled(Value: Boolean);
begin
  if FEnabled <> Value then
    FEnabled := Value;
end;

procedure TDCustomControl.SetFrameVisible(Value: Boolean);
begin
  if FFrameVisible <> Value then
    FFrameVisible := Value;
end;

procedure TDCustomControl.SetFrameHot(Value: Boolean);
begin
  if FFrameHot <> Value then
    FFrameHot := Value;
end;

procedure TDCustomControl.SetFrameSize(Value: byte);
begin
  if FFrameSize <> Value then
    FFrameSize := Value;
end;

procedure TDCustomControl.SetFrameColor(Value: TColor);
begin
  if FFrameColor <> Value then
  begin
    FFrameColor := Value;
    Perform(CM_COLORCHANGED, 0, 0);
  end;
end;

procedure TDCustomControl.SetFrameHotColor(Value: TColor);
begin
  if FFrameHotColor <> Value then
  begin
    FFrameHotColor := Value;
    Perform(CM_COLORCHANGED, 0, 0);
  end;
end;

procedure TDCustomControl.OnDefaultEnterKey;
begin
  //
end;

procedure TDCustomControl.OnDefaultTabKey;
begin
  //
end;

function TDCustomControl.MouseMove(Shift: TShiftState; X, Y: Integer): Boolean;
begin
  Result := inherited MouseMove(Shift, X, Y);
  if FEnabled and not Background then
  begin
    if Result then
      SetFrameHot(True)
    else if FocusedControl <> self then
      SetFrameHot(False);
  end;
end;

function TDCustomControl.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean;
begin
  Result := False;
  if inherited MouseDown(Button, Shift, X, Y) then
  begin
    if FEnabled then
    begin
      if (not Background) and (MouseCaptureControl = nil) then
      begin
        Downed := True;
        SetDCapture(self);
      end;
    end;
    Result := True;
  end;
end;

function TDCustomControl.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean;
begin
  Result := False;
  if inherited MouseUp(Button, Shift, X, Y) then
  begin
    ReleaseDCapture;
    if FEnabled and not Background then
    begin
      if InRange(X, Y, Shift) then
      begin
        if Assigned(FOnClickSound) then
          FOnClickSound(self, FClickSound);
        if Assigned(FOnClick) then
          FOnClick(self, X, Y);
      end;
    end;
    Downed := False;
    Result := True;
    Exit;
  end
  else
  begin
    ReleaseDCapture;
    Downed := False;
  end;
end;

//procedure TDEdit.Paint;
//begin
//  if csDesigning in ComponentState then
//  begin
//    with Canvas do
//    begin
//      Brush.Color := clWhite;
//      FillRect(ClipRect);
//      Pen.Color := cl3DDkShadow;
//      MoveTo(0, 0);
//      LineTo(Width - 1, 0);
//      LineTo(Width - 1, Height - 1);
//      LineTo(0, Height - 1);
//      LineTo(0, 0);
//      TextOut((Width - TextWidth(Text)) div 2, (Height - TextHeight(Text)) div 2 - 1, Text);
//    end;
//  end;
//end;

{--------------------- TDxScrollBarBar --------------------------}

constructor TDxScrollBarBar.Create(aowner: TComponent; nTmpList: TStrings);
begin
  inherited Create(aowner);
  Selected := False;
  dify := 0;
  ModPos := 0;
  TmpList := nTmpList;
  hAuteur := Height;
  TotH := DParent.Height;
  StartPosY := Top;
  AJust_H;
end;

procedure TDxScrollBarBar.AJust_H;
//var
//  tmph: Single;
begin
//  tmph := TmpList.count * Font.Height;
//  if ((tmph > TotH) and (hAuteur <> 0) and (tmph <> 0) and (TotH <> 0)) then begin
//    Height := Trunc(hAuteur / (tmph / TotH));
//  end else
//    Height := hAuteur;
//  if (Height < Width) then
//    Height := Width;
end;

function TDxScrollBarBar.GetPos: Integer;
begin
  Result := ModPos;
end;

procedure TDxScrollBarBar.DirectPaint(dsurface: TDXTexture);
begin
  AJust_H;
//  with dsurface.Canvas do begin
//    Brush.Style := bsSolid;
//    if Selected then
//      Brush.Color := clGray
//    else
//      Brush.Color := clLtGray;
//    Rectangle(SurfaceX(Left), SurfaceY(StartPosY), SurfaceX(Left + Width), SurfaceY(StartPosY + hAuteur));
//    if Selected then
//      Brush.Color := clLtGray
//    else
//      Brush.Color := clGray;
//    RoundRect(SurfaceX(Left + 1), SurfaceY(Top + 1), SurfaceX(Left + Width - 1), SurfaceY(Top + Height - 1), Width div 2, Width div 2);
//    Release;
//  end;
  //inherited DirectPaint(dsurface);
end;

function TDxScrollBarBar.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean;
var
  ret: Boolean;
begin
  ret := inherited MouseDown(Button, Shift, X, Y);
  if ret then
  begin
    Selected := True;
    dify := Top - SurfaceY(Y);
    ret := True;
  end;
  Result := ret;
end;

function TDxScrollBarBar.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean;
var
  ret: Boolean;
begin
  ret := inherited MouseUp(Button, Shift, X, Y);
  if (Selected) then
  begin
    MoveBar(SurfaceY(Y) + dify);
    Selected := False;
    ret := True;
  end;
  Result := ret;
end;

function TDxScrollBarBar.MouseMove(Shift: TShiftState; X, Y: Integer): Boolean;
var
  ret: Boolean;
begin
  ret := inherited MouseMove(Shift, X, Y);
  if ret then
  begin                     //InRange
    if Selected then
    begin
      MoveBar(SurfaceY(Y) + dify);
      ret := True;
    end;
  end;
  Result := ret;
end;

procedure TDxScrollBarBar.MoveBar(nposy: Integer);
//var
//  tmph: Integer;
begin
//  Top := nposy;
//  if Top < StartPosY then
//    Top := StartPosY;
//  if Top > hAuteur - Height + StartPosY then
//    Top := hAuteur - Height + StartPosY;
//  if ((hAuteur - Height) = 0) then
//    ModPos := 0
//  else begin
//    tmph := TmpList.count * Font.Height;
//    ModPos := (Top - StartPosY) * (TotH - tmph) div (hAuteur - Height);
//  end;
end;

procedure TDxScrollBarBar.MoveModPos(nMove: Integer);
begin
//  ModPos := (ModPos + nMove) div Font.Height * Font.Height;
//  if ((TotH - (TmpList.count * Font.Height)) = 0) then
//    Top := 0
//  else
//    Top := StartPosY + ModPos * (hAuteur - Height) div (TotH - (TmpList.count * Font.Height));
//  if Top < StartPosY then
//    MoveBar(StartPosY);
//  if Top > hAuteur - Height + StartPosY then
//    MoveBar(hAuteur - Height + StartPosY);
end;

{------------------------- TDxScrollBarUp --------------------------}

function TDxScrollBarUp.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean;
var
  ret: Boolean;
begin
  ret := inherited MouseDown(Button, Shift, X, Y);
  if ret {and (check_click_in(X, Y)))} then
  begin
    Selected := True;
    ret := True;
  end;
  Result := ret;
end;

function TDxScrollBarUp.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean;
var
  ret: Boolean;
begin
  ret := inherited MouseUp(Button, Shift, X, Y);
  if Selected then
  begin
    Selected := False;
    //if ((not ret) and (check_click_in(X, Y))) then
    //  ret := True;
  end;
  Result := ret;
end;

procedure TDxScrollBarUp.DirectPaint(dsurface: TDXTexture);
const
  DECAL = 3;
begin
//  with dsurface.Canvas do begin
//    Brush.Style := bsSolid;
//    if Selected then
//      Brush.Color := clGray
//    else
//      Brush.Color := clLtGray;
//    Rectangle(Left, Top + 1, Left + Width, Top + Width + 1);
//    if Selected then
//      Brush.Color := clLtGray
//    else
//      Brush.Color := clGray;
//    Polygon([Point(Left + DECAL, Top + 1 + Width - DECAL),
//      Point(Left + Width - 10, Top + 1 + DECAL),
//        Point(Left + Width - DECAL, Top + 1 + Width - DECAL)]);
//    Release;
//  end;
  //inherited DirectPaint(dsurface);
end;

{------------------------- TDxScrollBarDown --------------------------}

procedure TDxScrollBarDown.DirectPaint(dsurface: TDXTexture);
const
  DECAL = 3;
begin
//  with dsurface.Canvas do begin
//    Brush.Style := bsSolid;
//    if (Selected) then
//      Brush.Color := clGray
//    else
//      Brush.Color := clLtGray;
//    Rectangle(Left, Top + 1, Left + Width, Top + Width + 1);
//    if (Selected) then
//      Brush.Color := clLtGray
//    else
//      Brush.Color := clGray;
//    Polygon([Point(Left + DECAL, Top + 1 + DECAL),
//      Point(Left + Width - 10, Top + 1 + Width - DECAL),
//        Point(Left + Width - DECAL, Top + 1 + DECAL)]);
//    Release;
//  end;
  //inherited show(x1,y1,x2,y2,dxdraw);
end;

{------------------------- TDxScrollBar --------------------------}

constructor TDxScrollBar.Create(aowner: TComponent; nTmpList: TStrings);
begin
  inherited Create(aowner);
  Bar := TDxScrollBarBar.Create(aowner, nTmpList);
  BUp := TDxScrollBarUp.Create(aowner);
  BDown := TDxScrollBarDown.Create(aowner);
  TotH := DParent.Height - 2;
  AddChild(Bar);
  AddChild(BUp);
  AddChild(BDown);
end;

function TDxScrollBar.GetPos: Integer;  //retourne la position du debut
begin
  Result := Bar.GetPos;
end;

function TDxScrollBar.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean;
//var
//  ret: Boolean;
begin
  Result := False;
//  ret := BUp.MouseUp(Button, Shift, X - Left, Y - Top);
//  if ret then
//    MoveModPos(Font.Height);
//  if not ret then begin
//    ret := BDown.MouseUp(Button, Shift, X - Left, Y - Top);
//    if ret then
//      MoveModPos(-Font.Height);
//  end;
//  if not ret then
//    ret := Bar.MouseUp(Button, Shift, X - Left, Y - Top);
//  //ret := inherited MouseUp(Button, Shift, X, Y);
//  if ret then begin
//    if Y > Bar.Top then
//      MoveModPos(-TotH)
//    else
//      MoveModPos(TotH);
//    ret := True;
//  end;
//  Result := ret;
end;

procedure TDxScrollBar.MoveModPos(nMove: Integer);
begin
  Bar.MoveModPos(nMove);
end;
{-------------------------TDxHint--------------------------}

constructor TDxHint.Create(aowner: TComponent);
begin
  inherited Create(aowner);
  FSelected := -1;
  FItems := TStringList.Create;
  FBackColor := clWhite;
  FSelectionColor := clSilver;
  FOnChangeSelect := nil;
  FOnMouseMoveSelect := nil;
  FParentControl := nil;
end;

destructor TDxHint.Destroy;
begin
  FItems.Free;
  inherited;
end;

function TDxHint.GetItemSelected: Integer;
begin
  if (FSelected > FItems.count - 1) or (FSelected < 0) then
    Result := -1
  else
    Result := FSelected;
end;

procedure TDxHint.SetItemSelected(Value: Integer);
begin
  if (Value > FItems.count - 1) or (Value < 0) then
    FSelected := -1
  else
    FSelected := Value;
end;

procedure TDxHint.SetBackColor(Value: TColor);
begin
  if FBackColor <> Value then
  begin
    FBackColor := Value;
    Perform(CM_COLORCHANGED, 0, 0);
  end;
end;

procedure TDxHint.SetSelectionColor(Value: TColor);
begin
  if FSelectionColor <> Value then
  begin
    FSelectionColor := Value;
    Perform(CM_COLORCHANGED, 0, 0);
  end;
end;

function TDxHint.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean;
begin
  Result := inherited MouseDown(Button, Shift, X, Y);
end;

function TDxHint.MouseMove(Shift: TShiftState; X, Y: Integer): Boolean;
begin
  FSelected := -1;
  Result := inherited MouseMove(Shift, X, Y);
  if Result and FEnabled and not Background then
  begin
    if (FItems.count = 0) then
      FSelected := -1
    else
      FSelected := (-Top + Y - LineSpace2 + 2) div (-Font.Height + LineSpace2);
    if FSelected > FItems.count - 1 then
      FSelected := -1;
    if Assigned(FOnMouseMoveSelect) then
      FOnMouseMoveSelect(self, Shift, X, Y);
  end;
end;

function TDxHint.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean;
var
  c: Char;
  ret: Boolean;
begin
  ret := inherited MouseUp(Button, Shift, X, Y);
  if ret then
  begin
    if (FItems.count = 0) then
      FSelected := -1
    else
      FSelected := (-Top + Y - LineSpace2 + 2) div (-Font.Height + LineSpace2);

    if FSelected > FItems.count - 1 then
      FSelected := -1;

    if (FSelected > -1) and (FSelected < FItems.count) and (FParentControl <> nil) and (FParentControl is TDxCustomEdit) then
    begin
      if (FItems.Objects[FSelected] <> nil) then
      begin
        Result := True;
        Exit;
      end;
      if tag = 0 then
      begin
        c := #0;
        case FSelected of
          0:
            c := #24;                  //剪切
          1:
            c := #3;                   //复制
          2:
            c := #22;                  //粘贴
          3:
            c := #8;                   //删除
          4:
            begin                      //全选
              TDxCustomEdit(FParentControl).SelStart := 0;
              TDxCustomEdit(FParentControl).SelEnd := Length(TDxCustomEdit(FParentControl).Caption);
              TDxCustomEdit(FParentControl).ChangeCurPos(TDxCustomEdit(FParentControl).SelEnd, True);
            end;
        end;
        if (c <> #0) then
        begin
          TDxCustomEdit(FParentControl).KeyPressEx(c);
        end;
      end
      else if tag = 1 then
      begin

      end;
    end;

    if Assigned(FOnChangeSelect) then
      FOnChangeSelect(self, Button, Shift, X, Y);

    Visible := False;
    ret := True;
  end;
  Result := ret;
end;

function TDxHint.KeyDown(var Key: Word; Shift: TShiftState): Boolean;
var
  ret: Boolean;
begin
  ret := inherited KeyDown(Key, Shift);
  if ret then
  begin
    case Key of
      VK_PRIOR:
        begin
          ItemSelected := ItemSelected - Height div  - Font.Height;
          if (ItemSelected = -1) then
            ItemSelected := 0;
        end;
      VK_NEXT:
        begin
          ItemSelected := ItemSelected + Height div  - Font.Height;
          if ItemSelected = -1 then
            ItemSelected := FItems.count - 1;
        end;
      VK_UP:
        if ItemSelected - 1 > -1 then
          ItemSelected := ItemSelected - 1;
      VK_DOWN:
        if ItemSelected + 1 < FItems.count then
          ItemSelected := ItemSelected + 1;
    end;
  end;
  Result := ret;
end;

procedure TDxHint.SetItems(Value: TStrings);
begin
  FItems.Assign(Value);
end;

procedure TDxHint.DirectPaint(dsurface: TDXTexture);
var
  fy, nY, L, T, i, oSize: Integer;
  OldColor, BrushColor, FontColor: Cardinal;
  FontStyle: TFontStyles;
begin
  if Assigned(FOnDirectPaint) then
  begin
    FOnDirectPaint(self, dsurface);
    Exit;
  end;

  L := SurfaceX(Left);
  T := SurfaceY(Top);

  if tag = 0 then
  begin
    try

      //BrushColor := clWebOliveDrab; //框架背景颜色设置 Development 2018-12-31
      g_DXCanvas.FillRect(Rect(L, T + 1, L + Width, T + Height - 1), clWebOlive, 150);

      if (FSelected > -1) and (FSelected < FItems.count) then
      begin
        if (FItems.Objects[FSelected] = nil) then
        begin

          nY := T + (-g_DXCanvas.TextHeight('0') + LineSpace2) * FSelected;
          fy := nY + (-g_DXCanvas.TextHeight('0') + LineSpace2);
          if (nY < T + Height - 1) and (fy > T + 1) then
          begin
            if (fy > T + Height - 1) then
              fy := T + Height - 1;
            if (nY < T + 1) then
              nY := T + 1;
            g_DXCanvas.FillRectAlpha(Rect(L + 2, nY + 2, L + Width - 2, fy + 5), clBlue, 255);
          end;
        end;
      end;

      for i := 0 to FItems.count - 1 do
      begin
        if (FSelected = i) and (FItems.Objects[i] = nil) then
        begin
          FontColor := clWhite
        end
        else if (FItems.Objects[i] <> nil) then
          FontColor := clSilver
        else
        begin
          FontColor := clWebLime; //打开EDIT复制粘贴时显示的文字颜色 Development 2019-01-09
        end;
        g_DXCanvas.TextOut(L + LineSpace2, LineSpace2 + T + (-g_DXCanvas.TextHeight('0') + LineSpace2) * i, FItems.Strings[i], FontColor);
      end;
    finally

    end;
    Exit;
  end;

  try
    //BrushColor := clWebOliveDrab; //框架背景颜色设置 Development 2018-12-31
    g_DXCanvas.FillRectAlpha(Rect(L, T + 1, L + Width, T + Height - 1), clWebOlive, 150);

    BrushColor := clWebBlue; //鼠标指针选择时的背景颜色设置 Development 2018-12-31
    if (FSelected > -1) and (FSelected < FItems.count) then
    begin
      if (FItems.Objects[FSelected] = nil) then
      begin

        nY := T + (-g_DXCanvas.TextHeight('0') + LineSpace2) * FSelected;
        fy := nY + (-g_DXCanvas.TextHeight('0') + LineSpace2);
        if (nY < T + Height - 1) and (fy > T + 1) then
        begin
          if (fy > T + Height - 1) then
            fy := T + Height - 1;
          if (nY < T + 1) then
            nY := T + 1;
          g_DXCanvas.FillRectAlpha(Rect(L, nY + 2, L + Width, fy + 5), BrushColor, 255);
        end;
      end;
    end;

    for i := 0 to FItems.count - 1 do
    begin
      if (FSelected = i) and (FItems.Objects[i] = nil) then
      begin
        FontColor := clWhite
      end
      else if (FItems.Objects[i] <> nil) then
        FontColor := clSilver
      else
      begin
        FontColor := clWhite;
      end;
      g_DXCanvas.TextOut(L + LineSpace2, LineSpace2 + T + (-g_DXCanvas.TextHeight('0') + LineSpace2) * i, FItems.Strings[i], FontColor);
    end;
  finally

  end;


end;

{------------------------- TDGrid --------------------------}

constructor TDGrid.Create(aowner: TComponent);
begin
  inherited Create(aowner);
  FColCount := 8;
  FRowCount := 5;
  FColWidth := 36;
  FRowHeight := 32;
  FOnGridSelect := nil;
  FOnGridMouseMove := nil;
  FOnGridPaint := nil;
  tButton := mbLeft;
end;

function TDGrid.GetColRow(X, Y: Integer; var ACol, ARow: Integer): Boolean;
begin
  Result := False;
  //DScreen.AddChatBoardString('TDGrid.GetColRow ...', clWhite, clRed);
  if InRange(X, Y, [ssDouble]) then
  begin
    ACol := (X - Left) div FColWidth;
    ARow := (Y - Top) div FRowHeight;
    Result := True;
  end;
end;

function TDGrid.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean;
var
  ACol, ARow: Integer;
begin
  Result := False;
  if Button in [mbLeft, mbRight] then
  begin
    if GetColRow(X, Y, ACol, ARow) then
    begin
      SelectCell.X := ACol;
      SelectCell.Y := ARow;
      DownPos.X := X;
      DownPos.Y := Y;
      SetDCapture(self);
      Result := True;

      if g_DragMode then begin
        SaveDragStart(Self, X, Y);
      end;
      SetSelectedControl(Self);
    end;
  end;
end;

function TDGrid.MouseMove(Shift: TShiftState; X, Y: Integer): Boolean;
var
  ACol, ARow: Integer;
begin
  Result := False;
  if InRange(X, Y, Shift) then
  begin
    if g_AutoUITrace then begin //自动追踪
      SetSelectedControl(Self);
    end;
    
    if GetColRow(X, Y, ACol, ARow) then
    begin
      if Assigned(FOnGridMouseMove) then
        FOnGridMouseMove(self, ACol, ARow, Shift);
    end;
    Result := True;
  end;
end;

function TDGrid.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean;
var
  ACol, ARow: Integer;
begin
  Result := False;

  //DScreen.AddChatBoardString('TDGrid.MouseUp ...', clWhite, clRed);

  if Button in [mbLeft, mbRight] then
  begin
    if GetColRow(X, Y, ACol, ARow) then
    begin
      if (SelectCell.X = ACol) and (SelectCell.Y = ARow) then
      begin
        Col := ACol;
        Row := ARow;
        if Assigned(FOnGridSelect) then
        begin
          self.tButton := Button;
          FOnGridSelect(self, ACol, ARow, Shift);
        end;
      end;
      Result := True;
    end;
    ReleaseDCapture;
  end;
end;

function TDGrid.Click(X, Y: Integer): Boolean;
//var
//  ACol, ARow: Integer;
begin
  Result := False;
  {if GetColRow(X, Y, ACol, ARow) then begin
    if Assigned(FOnGridSelect) then
      FOnGridSelect(Self, ACol, ARow, []);
    Result := True;
  end;}
end;

procedure TDGrid.DirectPaint(dsurface: TDXTexture);
var
  i, j: Integer;
  rc: TRect;
begin
  if Assigned(FOnGridPaint) then
  begin
    for i := 0 to FRowCount - 1 do
    begin
      for j := 0 to FColCount - 1 do
      begin
        rc := Rect(Left + j * FColWidth, Top + i * FRowHeight, Left + j * (FColWidth + 1) - 1, Top + i * (FRowHeight + 1) - 1);
        if (SelectCell.Y = i) and (SelectCell.X = j) then
          FOnGridPaint(self, j, i, rc, [gdSelected], dsurface)
        else
          FOnGridPaint(self, j, i, rc, [], dsurface);
      end;
    end;
  end;

  if g_TranFrame then
    g_DXCanvas.RoundRect(SurfaceX(Left), SurfaceY(Top), SurfaceX(Left + Width), SurfaceY(Top + Height), clLime);

  if g_DragMode and (SeletedControl = Self) then
    g_DXCanvas.RoundRect(SurfaceX(Left), SurfaceY(Top), SurfaceX(Left + Width), SurfaceY(Top + Height), clRed);
end;

{--------------------- TDWindown --------------------------}

constructor TDWindow.Create(aowner: TComponent);
begin
  inherited Create(aowner);
  FFloating := False;
  Width := 120;
  Height := 120;
  FControlStyle := dsNone;
end;

procedure TDWindow.SetVisible(Value: Boolean);
begin
  if FVisible <> Value then begin
    IsVisible(Value);
    if Value and FMouseFocus then begin
      SetDFocus(Self);
    end else
    if FocusedControl = Self then begin
      ReleaseDFocus;
    end;
  end;
  FVisible := Value;

  if DParent <> nil then
    DParent.ChangeChildOrder(Self);
end;

function TDWindow.MouseMove(Shift: TShiftState; X, Y: Integer): Boolean;
var
  al, at: integer;
begin
  Result := inherited MouseMove(Shift, X, Y);
  if Result and FFloating and (MouseCaptureControl = Self) and (ssLeft in Shift) then begin
    if (SpotX <> X) or (SpotY <> Y) then begin
      al := Left + (X - SpotX);
      at := Top + (Y - SpotY);
      if al + Width < WINLEFT then
        al := WINLEFT - Width;
      if al > (GUIFScreenWidth - 60) then
        al := (GUIFScreenWidth - 60);
      if at + Height < WINTOP then
        at := WINTOP - Height;
      if at > (GUIFScreenHeight - 60) then
        at := (GUIFScreenHeight - 60);
      Left := al;
      Top := at;
      SpotX := X;
      SpotY := Y;
    end;
  end;
end;

procedure TDWindow.CreatePropertites;
begin
  FPropertites := TDXWindowPropertites.Create(Self);
  FDXImageLib := TDXWindowImageProperty.Create(FPropertites);
end;

procedure TDWindow.DirectPaint(dsurface: TDXTexture);
var
  i: integer;
  d: TDXTexture;
begin
  if Assigned(FOnDirectPaint) then
    FOnDirectPaint(Self, dsurface)
  else if FImages<> nil then begin //判断为空
    d := FImages.Images[FImageIndex];
    if d <> nil then
      dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, FDrawMode);
  end;

  for i := 0 to DControls.Count - 1 do begin
    if TDControl(DControls[i]).Visible then
      TDControl(DControls[i]).DirectPaint(dsurface);
  end;

  if Assigned(FOnEndDirectPaint) then
    FOnEndDirectPaint(Self, dsurface);

  if g_TranFrame then
    g_DXCanvas.RoundRect(SurfaceX(Left), SurfaceY(Top), SurfaceX(Left + Width), SurfaceY(Top + Height), clLime);

  if g_DragMode and (SeletedControl = Self) then
    g_DXCanvas.RoundRect(SurfaceX(Left), SurfaceY(Top), SurfaceX(Left + Width), SurfaceY(Top + Height), clRed);
end;

function TDWindow.EscClose: Boolean;
begin
  Result := inherited EscClose;
  if (not Result) and FEscClose then begin
    Visible := False;
    Result := True;
  end;
end;

function TDWindow.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean;
begin
  Result := inherited MouseDown(Button, Shift, X, Y);
  if Result then
  begin
    if Floating then
    begin
      if DParent <> nil then
        DParent.ChangeChildOrder(self);
    end;
    SpotX := X;
    SpotY := Y;
  end;
end;

function TDWindow.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean;
begin
  Result := inherited MouseUp(Button, Shift, X, Y);
end;

procedure TDWindow.Show;
begin
  Visible := True;
  if DParent <> nil then
    DParent.ChangeChildOrder(self);

  if FMouseFocus then
    SetDFocus(self);
end;

function TDWindow.ShowModal: Integer;
begin
  Result := 0;
  Visible := True;
  //ModalDWindow := Self;
  if FMouseFocus then
    SetDFocus(Self);
end;

procedure TDWindow.TopShow;
begin
  Show;
  //TopDWindow := Self;
end;

{--------------------- TDWinManager --------------------------}

constructor TDWinManager.Create(aowner: TComponent);
begin
  inherited Create(aowner);
  DWinList := TList.Create;
  LibClientList := TList.Create;
  MouseCaptureControl := nil;
  FocusedControl := nil;
  KeyControl := nil;
  MouseEntryControl := nil;
  ModalDWindow := nil;
end;

destructor TDWinManager.Destroy;
begin
  LibClientList.Clear;
  LibClientList.Free;
  DWinList.Clear;
  DWinList.Free;
  inherited Destroy;
end;

procedure TDWinManager.ClearAll;
begin
  DWinList.Clear;
end;

//procedure TDWinManager.Process;
//var
//  I: Integer;
//begin
//  for I := 0 to DWinList.Count - 1 do begin
//    if TDControl(DWinList[I]).Visible then begin
//      TDControl(DWinList[I]).Process;
//    end;
//  end;
//  if ModalDWindow <> nil then begin
//    if ModalDWindow.Visible then
//      with ModalDWindow do
//        Process;
//  end;
////  if ActiveMenu <> nil then begin
////    if ActiveMenu.Visible then
////      with ActiveMenu do begin
////        Process;
////      end;
////  end;
//end;

procedure TDWinManager.AddDControl(dcon: TDControl; Visible: Boolean);
begin
  dcon.Visible := Visible;
  DWinList.Add(dcon);
end;

procedure TDWinManager.DelDControl(dcon: TDControl);
var
  i: Integer;
begin
  for i := 0 to DWinList.count - 1 do
    if DWinList[i] = dcon then
    begin
      DWinList.Delete(i);
      Break;
    end;
end;

function TDWinManager.KeyPress(var Key: Char): Boolean;
begin
  Result := False;


  if ModalDWindow <> nil then
  begin
    if ModalDWindow.Visible then
    begin
      with ModalDWindow do
        Result := KeyPress(Key);
      Exit;
    end
    else
      ModalDWindow := nil;
    Key := #0;
  end;

//  if FocusedControl <> nil then
//  begin
//    if FocusedControl.Visible then
//    begin
//      Result := FocusedControl.KeyPress(Key);
//    end
//    else
//      ReleaseDFocus;
//  end;

  if Key = #9 then begin
    if KeyControl <> nil then begin
      if KeyControl.Visible and KeyControl.Enabled and (not KeyControl.IsHide) then begin
//        if KeyControl.CheckTab then begin
//
//        end;
      end
      else
        ReleaseDKocus;
    end;
  end;
  if KeyDownControl <> nil then begin
    if KeyDownControl.Visible and KeyDownControl.Enabled and (not KeyDownControl.IsHide) then
      KeyDownControl.KeyPress(Key);
    Result := True;
  end else
  if KeyControl <> nil then begin
    if KeyControl.Visible and KeyControl.Enabled and (not KeyControl.IsHide) then
      Result := KeyControl.KeyPress(Key)
    else
      ReleaseDKocus;
  end;
end;

function TDWinManager.KeyUp(var Key: Word; Shift: TShiftState): Boolean;
begin
  Result := False;
  if KeyDownControl <> nil then begin
    if KeyDownControl.Visible and KeyDownControl.Enabled and (not KeyDownControl.IsHide) then
      KeyDownControl.KeyUp(Key, Shift);
    Result := True;
  end else
  if KeyControl <> nil then begin
    if KeyControl.Visible and KeyControl.Enabled and (not KeyControl.IsHide) then
      Result := KeyControl.KeyUp(Key, Shift)
    else
      ReleaseDKocus;
  end;
  KeyDownControl := nil;
end;

function TDWinManager.KeyDown(var Key: Word; Shift: TShiftState): Boolean;
begin
  Result := False;
  if ModalDWindow <> nil then
  begin
    if ModalDWindow.Visible then
    begin
      with ModalDWindow do
        Result := KeyDown(Key, Shift);
      Exit;
    end
    else
      ModalDWindow := nil;
  end;
//  if FocusedControl <> nil then
//  begin
//    if FocusedControl.Visible then
//      Result := FocusedControl.KeyDown(Key, Shift)
//    else
//      ReleaseDFocus;
//  end;
  if KeyControl <> nil then begin
    if KeyControl.Visible and KeyControl.Enabled and (not KeyControl.IsHide) then
      Result := KeyControl.KeyDown(Key, Shift)
    else
      ReleaseDKocus;
  end else
  if Key = 27 then begin
    Result := EscClose;
  end;
end;

function TDWinManager.MouseMove(Shift: TShiftState; X, Y: Integer): Boolean;
var
  i: Integer;
begin
  if g_DragMode and (MovedControl <> nil) then
  begin
    MovedControl.ResetXY(X, Y);
    Result := True;
    Exit;
  end;

  Result := False;
  if ModalDWindow <> nil then
  begin
    if ModalDWindow.Visible then
    begin
      with ModalDWindow do
        MouseMove(Shift, LocalX(X), LocalY(Y));
      Result := True;
      Exit;
    end
    else
      ModalDWindow := nil;
  end;
  if MouseCaptureControl <> nil then
  begin
    with MouseCaptureControl do
      Result := MouseMove(Shift, LocalX(X), LocalY(Y));
  end else begin
    for i := 0 to DWinList.count - 1 do
    begin
      if TDControl(DWinList[i]).Visible then
      begin
        if TDControl(DWinList[i]).MouseMove(Shift, X, Y) then
        begin
          Result := True;
          Break;
        end;
      end;
    end;
  end;
end;

function TDWinManager.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean;
var
  i: Integer;
begin
  Result := False;
  if ModalDWindow <> nil then
  begin
    if ModalDWindow.Visible then
    begin
      with ModalDWindow do
        MouseDown(Button, Shift, LocalX(X), LocalY(Y));
      Result := True;
      Exit;
    end
    else
      ModalDWindow := nil;
  end;

  if MouseCaptureControl <> nil then
  begin
    with MouseCaptureControl do
      Result := MouseDown(Button, Shift, LocalX(X), LocalY(Y));
  end else begin
    for i := 0 to DWinList.count - 1 do
    begin
      if TDControl(DWinList[i]).Visible then
      begin
        if TDControl(DWinList[i]).MouseDown(Button, Shift, X, Y) then
        begin
          Result := True;
          Break;
        end;
      end;
    end;
  end;
end;

function TDWinManager.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean;
var
  i: Integer;
begin
  if g_DragMode then begin
    ReleaseDFocus;
    ReleaseDCapture;
    if Assigned(UIControlPostionChange) then
      UIControlPostionChange(MovedControl);
    MovedControl := nil;
    Result := True;
    Exit;
  end;

  Result := True;
  if ModalDWindow <> nil then
  begin
    if ModalDWindow.Visible then
    begin
      with ModalDWindow do
        Result := MouseUp(Button, Shift, LocalX(X), LocalY(Y));
      Exit;
    end
    else
      ModalDWindow := nil;
  end;

  if MouseCaptureControl <> nil then
  begin
    with MouseCaptureControl do
      Result := MouseUp(Button, Shift, LocalX(X), LocalY(Y));
  end else begin
    for i := 0 to DWinList.count - 1 do
    begin
      if TDControl(DWinList[i]).Visible then
      begin
        if TDControl(DWinList[i]).MouseUp(Button, Shift, X, Y) then
        begin
          Result := True;
          Break;
        end;
      end;
    end;
  end;
end;

function TDWinManager.MouseWheel(Shift: TShiftState; Wheel: TMouseWheel; X, Y: Integer): Boolean;
var
  i: integer;
//  MDWindow: TDModalWindow;
begin
  Result := FALSE;

//  if PopUpDWindow <> nil then begin
//    if PopUpDWindow.Visible then begin
//      with PopUpDWindow do
//        Result := MouseWheel(Shift, Wheel, LocalX(X), LocalY(Y));
//    end
//    else
//      PopUpDWindow := nil;
//    if Result then
//      Exit;
//  end;
//
//  if ModalDWindowList.Count > 0 then begin
//    for I := ModalDWindowList.Count - 1 downto 0 do begin
//      MDWindow := TDModalWindow(ModalDWindowList[i]);
//      if MDWindow.Visible then begin
//        with MDWindow do
//          MouseWheel(Shift, Wheel, LocalX(X), LocalY(Y));
//        Result := TRUE;
//        exit;
//      end else ModalDWindowList.delete(i);
//    end;
//  end;

  if ModalDWindow <> nil then
  begin
    if ModalDWindow.Visible then
    begin
      with ModalDWindow do
        MouseWheel(Shift, Wheel, LocalX(X), LocalY(Y));
      Result := TRUE;
      Exit;
    end
    else
      ModalDWindow := nil;
  end;

  if MouseCaptureControl <> nil then
  begin
    with MouseCaptureControl do
      Result := MouseWheel(Shift, Wheel, LocalX(X), LocalY(Y));
  end else
  if FocusedControl <> nil then
  begin
    with FocusedControl do
      Result := MouseWheel(Shift, Wheel, LocalX(X), LocalY(Y));
  end;
end;

procedure TDWinManager.SetLibClientList;
var
  i: Integer;
  ClientLib: TWMImages;
begin
  if LibClientList.Count > 0 then begin
    for i := 0 to LibClientList.Count - 1 do
    begin
      ClientLib := TWMImages(LibClientList.Items[i]);
      g_LibClientList.Add(ClientLib);
    end;
  end;
end;

function TDWinManager.DblClick(X, Y: Integer): Boolean;
var
  i: Integer;
begin
  Result := True;
  if ModalDWindow <> nil then begin
    if ModalDWindow.Visible then begin
      with ModalDWindow do
        Result := DblClick(LocalX(X), LocalY(Y));
      Exit;
    end else begin
      ModalDWindow := nil;
    end;
  end;

  if MouseCaptureControl <> nil then begin
    with MouseCaptureControl do
      Result := DblClick(LocalX(X), LocalY(Y));
  end else begin
    for i := 0 to DWinList.count - 1 do begin
      if TDControl(DWinList[i]).Visible then begin
        if TDControl(DWinList[i]).DblClick(X, Y) then begin
          Result := True;
          Break;
        end;
      end;
    end;
  end;
end;

function TDWinManager.Click(X, Y: Integer): Boolean;
var
  i: Integer;
begin
  Result := True;
  if ModalDWindow <> nil then begin
    if ModalDWindow.Visible then begin
      with ModalDWindow do
        Result := Click(LocalX(X), LocalY(Y));
      Exit;
    end else begin
      ModalDWindow := nil;
    end;
  end;

  if MouseCaptureControl <> nil then begin
    with MouseCaptureControl do
      Result := Click(LocalX(X), LocalY(Y));
  end else begin
    for i := 0 to DWinList.count - 1 do
    begin
      if TDControl(DWinList[i]).Visible then
      begin
        if TDControl(DWinList[i]).Click(X, Y) then
        begin
          Result := True;
          Break;
        end;
      end;
    end;
  end;
end;

procedure TDWinManager.DirectPaint(dsurface: TDXTexture);
var
  i: Integer;
begin
  for i := 0 to DWinList.count - 1 do
  begin
    if TDControl(DWinList[i]).Visible then
    begin
      try
        TDControl(DWinList[i]).DirectPaint(dsurface);
      except
        //修复在异常导致部分界面不显示
      end;
    end;
  end;
  try
    if ModalDWindow <> nil then
    begin
      if ModalDWindow.Visible then begin
        with ModalDWindow do
          DirectPaint(dsurface);
      end;
    end;
  except
    //修复在异常导致部分界面不显示
  end;
end;


function TDWinManager.EscClose: Boolean;
var
  i: integer;
  //MDWindow: TDModalWindow;
begin
  Result := FALSE;

//  if PopUpDWindow <> nil then begin
//    if PopUpDWindow.Visible then begin
//      PopUpDWindow.Visible := False;
//      PopUpDWindow := nil;
//      Result := True;
//      exit;
//    end
//    else
//      PopUpDWindow := nil;
//  end;
//
//  if ModalDWindowList.Count > 0 then begin
//    for I := ModalDWindowList.Count - 1 downto 0 do begin
//      MDWindow := TDModalWindow(ModalDWindowList[i]);
//      if MDWindow.Visible then begin
//        MDWindow.Visible := False;
//        ModalDWindowList.delete(i);
//        Result := TRUE;
//        exit;
//      end else ModalDWindowList.delete(i);
//    end;
//  end;

  if ModalDWindow <> nil then begin
    if ModalDWindow.Visible then begin
      ModalDWindow.Visible := False;
      ModalDWindow := nil;
      Result := TRUE;
      exit;
    end
    else
      ModalDWindow := nil;
  end;

//  if TopDWindow <> nil then begin
//    if TopDWindow.Visible then begin
//      TopDWindow.Visible := False;
//      TopDWindow := nil;
//      Result := True;
//      exit;
//    end else TopDWindow := nil;
//  end;

  if MouseCaptureControl <> nil then begin
    with MouseCaptureControl do
      Result := MouseCaptureControl.EscClose;
  end else begin
    for i := 0 to DWinList.Count - 1 do begin
      if TDControl(DWinList[i]).Visible then begin
        if TDControl(DWinList[i]).EscClose then begin
          Result := TRUE;
          break;
        end;
      end;
    end;
  end;
end;

{--------------------- TDmoveButton --------------------------}

constructor TDMoveButton.Create(aowner: TComponent);
begin
  inherited Create(aowner);
  FFloating := True;
  FMouseFocus := False;
  Width := 30;
  Height := 30;
  LeftToRight := True;
  //bMouseMove := True;
end;

procedure TDMoveButton.SetVisible(flag: Boolean);
begin
  FVisible := flag;
  if Floating then
  begin
    if DParent <> nil then
      DParent.ChangeChildOrder(self);
  end;
end;

function TDMoveButton.MouseMove(Shift: TShiftState; X, Y: Integer): Boolean;
var
  n, al, at, ot: Integer;
begin
  Result := inherited MouseMove(Shift, X, Y);
  if Max <= 0 then
    Exit;
  if ssLeft in Shift then
  begin
    if Result and FFloating and (MouseCaptureControl = self) then
    begin
      n := Position;
      try
        if Max <= 0 then
          Exit;
        if (SpotX <> X) or (SpotY <> Y) then
        begin
          if LeftToRight then
          begin
            if not Reverse then
            begin
              ot := SlotLen - Width;
              al := RTop;               //RLeft;
              at := Left + (X - SpotX);
              if at < RLeft then
                at := RLeft;
              if at + Width > RLeft + SlotLen then
                at := RLeft + SlotLen - Width;
              Position := Round((at - RLeft) / (ot / Max));
              if Position < 0 then
                Position := 0;
              if Position > Max then
                Position := Max;
              Left := at;
              Top := al;
              SpotX := X;
              SpotY := Y;
            end
            else
            begin
              al := RTop;               //RLeft;
              at := Left + (X - SpotX);
              if at < RLeft - SlotLen then
                at := RLeft - SlotLen;
              if at > RLeft then
                at := RLeft;
              Position := Round((at - RLeft) / (SlotLen / Max));
              if Position < 0 then
                Position := 0;
              if Position > Max then
                Position := Max;
              Left := at;
              Top := al;
              SpotX := X;
              SpotY := Y;
            end;
          end
          else
          begin
            if not Reverse then
            begin
              ot := SlotLen - Height;
              al := RLeft;
              at := Top + (Y - SpotY);
              if at < RTop then
                at := RTop;
              if at + Height > RTop + SlotLen then
                at := RTop + SlotLen - Height;
              Position := Round((at - RTop) / (ot / Max));
              if Position < 0 then
                Position := 0;
              if Position > Max then
                Position := Max;
              Left := al;
              Top := at;
              SpotX := X;
              SpotY := Y;
            end
            else
            begin
              al := RLeft;
              at := Top + (Y - SpotY);
              if at < RTop - SlotLen then
                at := RTop - SlotLen;
              if at > RTop then
                at := RTop;
              Position := Round((at - RTop) / (SlotLen / Max));
              if Position < 0 then
                Position := 0;
              if Position > Max then
                Position := Max;
              Left := al;
              Top := at;
              SpotX := X;
              SpotY := Y;
            end;
          end;

        end;
      finally
        if (n <> Position) and Assigned(FOnMouseMove) then
          FOnMouseMove(self, Shift, X, Y);
      end;
    end;
  end;
end;

procedure TDMoveButton.UpdatePos(pos: Integer; force: Boolean);
begin
  if Max <= 0 then
    Exit;
  //if not force and (Position = pos) then Exit;
  //if (pos < 0) or (pos > Max) then Exit;
  Position := pos;
  if Position < 0 then
    Position := 0;
  if Position > Max then
    Position := Max;
  if LeftToRight then
  begin
    Left := RLeft + Round((SlotLen - Width) / Max * Position);
    if Left < RLeft then
      Left := RLeft;
    if Left > RLeft + SlotLen - Width then
      Left := RLeft + SlotLen - Width;
  end
  else
  begin
    Top := RTop + Round((SlotLen - Height) / Max * Position);
    if Top < RTop then
      Top := RTop;
    if Top > RTop + SlotLen - Height then
      Top := RTop + SlotLen - Height;
  end;
end;

function TDMoveButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean;
begin
  Result := inherited MouseDown(Button, Shift, X, Y);
  if Result then
  begin
    if Floating then
    begin
      if DParent <> nil then
        DParent.ChangeChildOrder(self);
    end;
    SpotX := X;
    SpotY := Y;
  end;
end;

function TDMoveButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean;
begin
  Result := inherited MouseUp(Button, Shift, X, Y);
end;

procedure TDMoveButton.Show;
begin
  Visible := True;
  if Floating then
  begin
    if DParent <> nil then
      DParent.ChangeChildOrder(self);
  end;
  if FMouseFocus then
    SetDFocus(self);
end;

function TDMoveButton.ShowModal: Integer;
begin
  Result := 0;
  Visible := True;
  //ModalDWindow := self;
  if FMouseFocus then
    SetDFocus(self);
end;



{==========================TDPopupMenu创建过程================================}

{ TDMenuItem }

constructor TDMenuItem.Create();
begin
  inherited;
  FVisible := True;
  FEnabled := True;
  FChecked := False;
  FCaption := '';
  FMenu := nil;
end;

destructor TDMenuItem.Destroy;
begin
  //if FMenu <> nil then FMenu.Free;
  inherited;
end;
{ TDPopupMenu }

constructor TDPopupMenu.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FItems := TStringList.Create();
  FColors := TColors.Create;
  FActiveMenu := nil;
  FOwnerMenu := nil;
  FOwnerItemIndex := 0;
  FMoveItemIndex := -1;
  FItemIndex := -1;
  Width := 150;
  Height := 100;
  FStyle := sXP;
  Add('Item1', nil);
  Add('Item2', nil);
  Add('Item3', nil);
  Add('Item4', nil);
end;

destructor TDPopupMenu.Destroy;
begin
  while Count > 0 do
  begin
    Items[0].Free;
    Delete(0);
  end;
  FItems.Free;
  FColors.Free;
  inherited Destroy;
end;

procedure TDPopupMenu.Paint;
var
  I: Integer;
begin
  if csDesigning in ComponentState then
  begin
    with Canvas do
    begin
      Brush.Color := clMenu;
      FillRect(ClipRect);
      Pen.Color := clInactiveBorder;

      for I := 0 to Count - 1 do
      begin
        MoveTo(5, Height div Count * I);
        LineTo(Width - 5, Height div Count * I);
        TextOut((Width - TextWidth(FItems[I])) div 2, Height div Count * I + (Height div Count - TextHeight(FItems[I])) div 2, FItems[I]);
      end;

      MoveTo(0, 0);
      LineTo(Width - 1, 0);
      LineTo(Width - 1, Height - 1);
      LineTo(0, Height - 1);
      LineTo(0, 0);
    end;
  end;
end;

procedure TDPopupMenu.CreateWnd;
begin
  inherited;
  if FItems = nil then
    FItems := TStringList.Create();
end;

procedure TDPopupMenu.SetOwnerMenu(Value: TDPopupMenu);
var
  Index: Integer;
begin
  if FOwnerMenu <> Value then
  begin
    if (FOwnerMenu <> nil) then
    begin
      Index := FOwnerMenu.IndexOf(Self);
      if Index >= 0 then
      begin
        FOwnerMenu.Menus[Index] := nil;
      end;
    end;
    FOwnerMenu := Value;
  end;
end;

procedure TDPopupMenu.SetOwnerItemIndex(Value: TImageIndex);
var
  Index: Integer;
begin
  if FOwnerMenu <> nil then
  begin
    if (FOwnerItemIndex >= 0) and (FOwnerItemIndex < FOwnerMenu.Count) then
      FOwnerMenu.Menus[FOwnerItemIndex] := nil;
    if (Value >= 0) and (Value < FOwnerMenu.Count) then
    begin
      for Index := Value to FOwnerMenu.Count - 1 do
      begin
        if FOwnerMenu.Menus[Index] = nil then
        begin
          FOwnerMenu.Menus[Index] := Self;
          FOwnerItemIndex := Index;
          Break;
        end;
      end;
    end
    else
      FOwnerItemIndex := -1;
  end
  else
    FOwnerItemIndex := -1;
end;

function TDPopupMenu.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TDPopupMenu.GetItems: TStrings;
begin
  if csDesigning in ComponentState then
    Refresh;
  Result := FItems;
end;

procedure TDPopupMenu.SetColors(Value: TColors);
begin
  FColors.Assign(Value);
end;

procedure TDPopupMenu.SetItems(Value: TStrings);
var
  I: Integer;
begin
  Clear;
  FItems.Assign(Value);
  for I := 0 to FItems.Count - 1 do
  begin
    FItems.Objects[I] := nil;
    FItems.Objects[I] := TDMenuItem.Create;
  end;
end;

procedure TDPopupMenu.SetItemIndex(Value: Integer);
begin
  FItemIndex := Value;
  if FItemIndex >= FItems.Count then
    FItemIndex := -1;
  {if FItemIndex <> Value then begin

  end;}
end;

function TDPopupMenu.GetItem(Index: Integer): TDMenuItem;
begin
  if (Index >= 0) and (Index < FItems.Count) then
  begin
    if FItems.Objects[Index] = nil then
    begin
      FItems.Objects[Index] := TDMenuItem.Create;
    end;
    Result := TDMenuItem(FItems.Objects[Index]);
  end
  else
    Result := nil;
end;

function TDPopupMenu.GetMenu(Index: Integer): TDPopupMenu;
begin
  if (Index >= 0) and (Index < FItems.Count) then
  begin
    if FItems.Objects[Index] = nil then
    begin
      FItems.Objects[Index] := TDMenuItem.Create;
    end;
    Result := TDPopupMenu(TDMenuItem(FItems.Objects[Index]).Menu);
  end
  else
    Result := nil;
end;

procedure TDPopupMenu.SetMenu(Index: Integer; Value: TDPopupMenu);
begin
  if FItems.Objects[Index] = nil then
  begin
    FItems.Objects[Index] := TDMenuItem.Create;
  end;
  TDMenuItem(FItems.Objects[Index]).Menu := Value;
end;

procedure TDPopupMenu.Insert(Index: Integer; ACaption: string; Item: TDPopupMenu);
var
  MenuItem: TDMenuItem;
begin
  MenuItem := TDMenuItem.Create();
  MenuItem.Menu := Item;
  FItems.InsertObject(Index, ACaption, MenuItem);
  //if csDesigning in ComponentState then Refresh;
end;

function TDPopupMenu.IndexOf(Item: TDPopupMenu): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to FItems.Count - 1 do
  begin
    if FItems.Objects[I] = nil then
    begin
      FItems.Objects[I] := TDMenuItem.Create();
    end;
    if TDMenuItem(FItems.Objects[I]).Menu = Item then
    begin
      Result := I;
      Exit;
    end;
  end;
end;

procedure TDPopupMenu.Add(ACaption: string; Item: TDPopupMenu);
begin
  Insert(GetCount, ACaption, Item);
end;

procedure TDPopupMenu.Remove(Item: TDPopupMenu);
var
  I: Integer;
begin
  I := IndexOf(Item);
  if I >= 0 then
    Delete(I);
end;

procedure TDPopupMenu.Delete(Index: Integer);
begin
  FItems.Delete(Index);
end;

procedure TDPopupMenu.Clear;
begin
  FItemIndex := -1;
  while Count > 0 do
  begin
    Items[0].Free;
    Delete(0);
  end;
end;

function TDPopupMenu.Find(ACaption: string): TDPopupMenu;
begin
  Result := nil;
//  ACaption := StripHotkey(ACaption);
//  for I := 0 to Count - 1 do
//    if AnsiSameText(ACaption, StripHotkey(Items[I].Caption)) then
//    begin
//      Result := Menus[I];
//      System.Break;
//    end;
end;

procedure TDPopupMenu.Show;
begin
  FMoveItemIndex := -1;
  Visible := True;
  {if Floating then begin
    if DParent <> nil then
      DParent.ChangeChildOrder(Self);
  end;
  if EnableFocus then SetDFocus(Self); }
  ActiveMenu := Self;
end;

procedure TDPopupMenu.Show(d: TDControl);
begin
  //if Count = 0 then Exit;
  FMoveItemIndex := -1;
  Visible := True;
  DControl := d;
 { if Floating then begin
    if DParent <> nil then
      DParent.ChangeChildOrder(Self);
  end;  }
  //if EnableFocus then SetDFocus(Self);
  ActiveMenu := Self;
end;

procedure TDPopupMenu.Hide;
var
  I: Integer;
begin
  //inherited;
  Visible := False;

  if ActiveMenu = Self then
    ActiveMenu := nil;
  if OwnerMenu <> nil then
    ActiveMenu := OwnerMenu;
  for I := 0 to Count - 1 do
  begin
    if (Menus[I] <> nil) { and (not Items[I].Visible)} then
    begin
      Menus[I].Hide;
    end;
  end;
end;

function TDPopupMenu.InRange(X, Y: Integer; Shift: TShiftState): Boolean;
var
  boInrange: Boolean;
begin
  if (X >= Left) and (X < Left + Width) and (Y >= Top) and (Y < Top + Height) then
  begin
    boInrange := True;
    if Assigned(OnInRealArea) then
      OnInRealArea(Self, X - Left, Y - Top, boInrange);
    Result := boInrange;
  end
  else
    Result := False;

  //自定义UI应该返回True方便选中控件
  if g_DragMode or g_AutoUITrace then
    boInRange := True;
end;

//procedure TDPopupMenu.Process;
//var
//  I, n1C, n2C: Integer;
//  OldSize: Integer;
//begin
//  //if Assigned(OnProcess) then OnProcess(Self);
//  if not Assigned(MainForm) then Exit;
//  OldSize := MainForm.Canvas.Font.Size;
//
//  MainForm.Canvas.Font.Size := 9;
//
//  FItemSize := Round(MainForm.Canvas.TextHeight('0') * 1.5);
//
//  n1C := 0;
//
//  if FStyle = sVista then begin
//    for I := 0 to FItems.Count - 1 do begin
//      if n1C < MainForm.Canvas.TextWidth(FItems.Strings[I]) then
//        n1C := MainForm.Canvas.TextWidth(FItems.Strings[I]);
//    end;
//
//    n1C := n1C + MainForm.Canvas.TextHeight('0') * 4;
//    if n1C <> Width then Width := n1C;
//  end;
//
//  if FStyle = sVista then begin
//    n2C := FItemSize * FItems.Count + MainForm.Canvas.TextHeight('0') * 2;
//    if n2C <> Height then Height := n2C;
//  end else begin
//    n2C := FItemSize * FItems.Count + MainForm.Canvas.TextHeight('0') div 2;
//    if n2C <> Height then Height := n2C;
//  end;
//
//  MainForm.Canvas.Font.Size := OldSize;
//
//  for I := 0 to DControls.Count - 1 do
//    if TDControl(DControls[I]).Visible then
//      TDControl(DControls[I]).Process;
//end;

procedure TDPopupMenu.DirectPaint(dsurface: TDXTexture);
var
  d: TDXTexture;
  I, nIndex: Integer;
  rc: TRect;
  nX, nY: Integer;

  CColor: TColor;
begin
  if Assigned(OnDirectPaint) then
    OnDirectPaint(Self, dsurface)
  else if WLib <> nil then
  begin
    d := WLib.Images[FaceIndex];
    if d <> nil then
    begin
      dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, FDrawMode);
    end;
  end;

{------------------------------------------------------------------------------}
  g_DXCanvas.FillRect(ClientRect, FColors.Background);
  g_DXCanvas.FrameRect(ClientRect, FColors.Border);
{------------------------------------------------------------------------------}
  if FItems.Count > 0 then
  begin
{------------------------------------------------------------------------------}
    nIndex := 0;
    nX := 3;
    nY := 3;
{------------------------------------------------------------------------------}
    for I := 0 to FItems.Count - 1 do
    begin
      if FMoveItemIndex = I then
      begin
        if Items[I].Enabled then
          CColor := FColors.Selected
        else
          CColor := FColors.Disabled;
      end
      else
      begin
        if Items[I].Enabled then
          CColor := FColors.Font
        else
          CColor := FColors.Disabled;
      end;
      if Items[I].Visible then
      begin

        rc := ClientRect;
        rc.Left := rc.Left + nX;
        rc.Top := rc.Top + nY + nIndex * FItemSize;
        rc.Right := rc.Left + Width - nX * 2;
        rc.Bottom := rc.Top + FItemSize;

        if FItems[I] = '-' then
        begin
          nY := (I * FItemSize) + FItemSize div 2;
          rc.Top := SurfaceY(Top) + nY;
          rc.Bottom := rc.Top + 1;
          g_DXCanvas.FrameRect(rc, FColors.Line);
        end
        else
        begin
          if FMoveItemIndex = nIndex then
          begin
            g_DXCanvas.FillRect(rc, FColors.Hot);
            g_DXCanvas.TextOut(rc.Left, rc.Top + (FItemSize - g_DXCanvas.TextHeight('0')) div 2, FItems[I], CColor);
          end
          else
          begin
            g_DXCanvas.TextOut(rc.Left, rc.Top + (FItemSize - g_DXCanvas.TextHeight('0')) div 2, FItems[I], CColor);
          end;
        end;
        Inc(nIndex);
      end;
    end;
  end;

  for I := 0 to DControls.Count - 1 do
    if TDControl(DControls[I]).Visible then
      TDControl(DControls[I]).DirectPaint(dsurface);
end;

function TDPopupMenu.KeyPress(var Key: Char): Boolean;
begin
  Result := False;
end;

function TDPopupMenu.KeyDown(var Key: Word; Shift: TShiftState): Boolean;
begin
  Result := False;
end;

function TDPopupMenu.MouseMove(Shift: TShiftState; X, Y: Integer): Boolean;
begin
  Result := inherited MouseMove(Shift, X, Y);
  if (not Background) and (not Result) then
  begin
    Result := inherited MouseMove(Shift, X, Y);
    if MouseCaptureControl = Self then
      if InRange(X, Y, Shift) then
        Downed := True
      else
        Downed := False;
  end;
  FMouseMove := Result;
  if (FItemSize <> 0) and FMouseMove and (Count > 0) then
  begin
    FMoveItemIndex := (Y - Top - 3) div FItemSize;
    if (FMoveItemIndex >= 0) and (FMoveItemIndex < FItems.Count) then
    begin
      if Menus[FMoveItemIndex] <> FActiveMenu then
      begin
        if FActiveMenu <> nil then
          FActiveMenu.Hide;
        FActiveMenu := nil;
        if Items[FMoveItemIndex].Enabled then
        begin
          FActiveMenu := Menus[FMoveItemIndex];
          if (FActiveMenu <> nil) and (not FActiveMenu.Visible) then
            FActiveMenu.Show(Self);
        end;
      end;
    end
    else
    begin
      if FActiveMenu <> nil then
        FActiveMenu.Hide;
      FActiveMenu := nil;
      FMoveItemIndex := -1;
    end;
  end
  else
    FMoveItemIndex := -1;
end;

function TDPopupMenu.Click(X, Y: Integer): Boolean;
var
  I: Integer;
begin
  Result := False;
 { if (ActiveMenu <> nil) then begin
    if (ActiveMenu = Self) then begin

      if Assigned(FOnClick) then
        FOnClick(Self, X, Y);

      Result := True;
    end;
    Exit;
  end; }
  for I := DControls.Count - 1 downto 0 do
    if TDControl(DControls[I]).Visible then
      if TDControl(DControls[I]).Click(X - Left, Y - Top) then
      begin
        Result := True;
        Exit;
      end;
  if InRange(X, Y, [ssDouble]) then
  begin
    if Assigned(OnClick) then
      OnClick(Self, X, Y);
    Result := True;
  end;
end;

function TDPopupMenu.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean;
begin
  Result := False;
  if inherited MouseDown(Button, Shift, X, Y) then
  begin
    //if (not Background) and (MouseCaptureControl = nil) then begin
    //Downed := True;
      //SetDCapture(Self);
   // end;
    Result := True;
  end;
  //FMouseDown := Result;
  if (FItemSize <> 0) {and FMouseDown}  and (Count > 0) then
  begin
    FItemIndex := (Y  - Top - 3) div FItemSize;
  end;
end;

function TDPopupMenu.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean;
begin
  Result := False;
  if inherited MouseUp(Button, Shift, X, Y) then
  begin
    Result := True;
    Downed := False;
    //FMouseDown := not Result;
    if InRange(X, Y, Shift) then
    begin
      if Button = mbLeft then
      begin
        FMouseMove := Result;
        if (FItemIndex >= 0) and (FItemIndex < Count) and Items[FItemIndex].Enabled then
        begin
          if (FActiveMenu <> nil) then
          begin
            if (not FActiveMenu.Visible) then
              FActiveMenu.Show(Self);
          end
          else
            Hide;
        end
        else if (Count <= 0) then
          Hide;
      end;
    end;
  end
  else
  begin
    ReleaseCapture;
    Downed := False;
  end;
end;

{==========================TDPopupMenu结束过程================================}


{==========================Edit过程开始========================================}
{--------------------- TDxCustomEdit --------------------------}

constructor TDxCustomEdit.Create(aowner: TComponent);
begin
  inherited Create(aowner);
  Downed := False;
  FMiniCaret := 0;
  m_InputHint := '';
  DxHint := nil;
  FCaretColor := clWhite;
  FOnClick := nil;
  FClick := False;
  FSelClickStart := False;
  FSelClickEnd := False;
  FClickX := 0;
  FSelStart := -1;
  FSelEnd := -1;
  FStartTextX := 0;
  FSelTextStart := 0;
  FSelTextEnd := 0;
  FCurPos := 0;
  FClickSound := csNone;
  FShowCaret := True;
  FNomberOnly := False;
  FIsHotKey := False;
  FHotKey := 0;
  FTransparent := True;
  FEnabled := True;
  FSecondChineseChar := False;
  FShowCaretTick := GetTickCount;
  FFrameVisible := True;
  FFrameHot := False;
  FFrameSize := 1;
  FFrameColor := $00406F77;
  FFrameHotColor := $00599AA8;
  FAlignment := taLeftJustify;
  FKeyFocus := True;
end;

procedure TDxCustomEdit.SetSelLength(Value: Integer);
begin
  SetSelStart(Value - 1);
  SetSelEnd(Value - 1);
end;

function TDxCustomEdit.ReadSelLength(): Integer;
begin
  Result := abs(FSelStart - FSelEnd);
end;

procedure TDxCustomEdit.SetSelStart(Value: Integer);
begin
  if FSelStart <> Value then
    FSelStart := Value;
end;

procedure TDxCustomEdit.SetSelEnd(Value: Integer);
begin
  if FSelEnd <> Value then
    FSelEnd := Value;
end;

procedure TDxCustomEdit.SetMaxLength(Value: Integer);
begin
  if FMaxLength <> Value then
    FMaxLength := Value;
end;

procedure TDxCustomEdit.SetPasswordChar(Value: Char);
begin
  if FPasswordChar <> Value then
    FPasswordChar := Value;
end;

procedure TDxCustomEdit.SetNomberOnly(Value: Boolean);
begin
  if FNomberOnly <> Value then
    FNomberOnly := Value;
end;

procedure TDxCustomEdit.SetIsHotKey(Value: Boolean);
begin
  if FIsHotKey <> Value then
    FIsHotKey := Value;
end;

procedure TDxCustomEdit.SetHotKey(Value: Cardinal);
begin
  if FHotKey <> Value then
    FHotKey := Value;
end;

procedure TDxCustomEdit.SetAtom(Value: Word);
begin
  if FAtom <> Value then
    FAtom := Value;
end;

procedure TDxCustomEdit.SetAlignment(Value: TAlignment);
begin
  if FAlignment <> Value then
    FAlignment := Value;
end;

procedure TDxCustomEdit.ShowCaret();
begin
  FShowCaret := True;
  FShowCaretTick := GetTickCount;
end;

procedure TDxCustomEdit.SetFocus();
begin
  SetDFocus(self);
end;

procedure TDxCustomEdit.ChangeCurPos(nPos: Integer; boLast: Boolean = False);
begin
  if Caption = '' then
    Exit;

  if boLast then
  begin
    FCurPos := Length(Caption);
    Exit;
  end;

  if nPos = 1 then
  begin                //Right ->
    case ByteType(Caption, FCurPos + 1) of
      mbSingleByte:
        nPos := 1;
      mbLeadByte:
        nPos := 2;            //汉字的第一个字节
      mbTrailByte:
        nPos := 2;           //汉字的第二个字节
    end;
  end
  else
  begin                        //Left <-
    case ByteType(Caption, FCurPos) of
      mbSingleByte:
        nPos := -1;
      mbLeadByte:
        nPos := -2;
      mbTrailByte:
        nPos := -2;
    end;
  end;

  if ((FCurPos + nPos) <= Length(Caption)) then
  begin
    if ((FCurPos + nPos) >= 0) then
      FCurPos := FCurPos + nPos;
  end;

  {if nPos = 1 then begin
    if ((FCurPos + 1) <= Length(Caption)) and (Caption[FCurPos + 1] > #$80) then
      nPos := 2
  end else begin
    if ((FCurPos + 0) <= Length(Caption)) and (Caption[FCurPos + 0] > #$80) then
      nPos := -2;
  end;

  if ((FCurPos + nPos) <= Length(Caption)) then begin
    if ((FCurPos + nPos) >= 0) then
      FCurPos := FCurPos + nPos;
  end;}

  if FSelClickStart then
  begin
    FSelClickStart := False;
    FSelStart := FCurPos;
  end;
  if FSelClickEnd then
  begin
    FSelClickEnd := False;
    FSelEnd := FCurPos;
  end;
end;

function TDxCustomEdit.KeyPress(var Key: Char): Boolean;
var
  s, cStr: string;
  i, nlen, cpLen: Integer;
  pStart: Integer;
  pEnd: Integer;
begin
  Result := False;
  pStart := 0;
  pEnd := 0;
  if not FEnabled or FIsHotKey then
    Exit;
  if not self.Visible then
    Exit;
  if (self.DParent = nil) or (not self.DParent.Visible) then
    Exit;
  s := Caption;
  try
    if (Ord(Key) in [VK_RETURN, VK_ESCAPE]) then
    begin
      Result := inherited KeyPress(Key);
      Exit;
    end;
    if not FNomberOnly and IsKeyPressed(VK_CONTROL) and (Ord(Key) in [1..27]) then
    begin
      //MessageBox(0, PChar(IntToStr(Ord(Key))), '', mb_ok);
      if (Ord(Key) = 22) then
      begin     //CTRL + V
        if (FSelStart > -1) and (FSelEnd > -1) and (FSelStart <> FSelEnd) then
        begin
          if FSelStart > FSelEnd then
          begin
            pStart := FSelEnd;
            pEnd := FSelStart;
          end;
          if FSelStart < FSelEnd then
          begin
            pStart := FSelStart;
            pEnd := FSelEnd;
          end;
          cStr := Clipboard.AsText;
          if cStr <> '' then
          begin
            cpLen := FMaxLength - Length(Caption) + abs(FSelStart - FSelEnd);
            FSelStart := -1;
            FSelEnd := -1;
            Caption := Copy(Caption, 1, pStart) + Copy(Caption, pEnd + 1, Length(Caption));
            FCurPos := pStart;

            nlen := Length(cStr);
            if nlen < cpLen then
              cpLen := nlen;
            Caption := Copy(Caption, 1, FCurPos) + Copy(cStr, 1, cpLen) + Copy(Caption, FCurPos + 1, Length(Caption));
            Inc(FCurPos, cpLen);

          end;
        end
        else
        begin
          cpLen := FMaxLength - Length(Caption);
          if cpLen > 0 then
          begin
            cStr := Clipboard.AsText;
            if cStr <> '' then
            begin
              nlen := Length(cStr);
              if nlen < cpLen then
                cpLen := nlen;
              Caption := Copy(Caption, 1, FCurPos) + Copy(cStr, 1, cpLen) + Copy(Caption, FCurPos + 1, Length(Caption));
              Inc(FCurPos, cpLen);
            end;
          end
          else
            System.SysUtils.Beep;
        end;
      end;

      if (Ord(Key) = 3) and (FPasswordChar = #0) and (Caption <> '') then
      begin //CTRL + C
        if (FSelStart > -1) and (FSelEnd > -1) and (FSelStart <> FSelEnd) then
        begin
          if FSelStart > FSelEnd then
          begin
            pStart := FSelEnd;
            pEnd := FSelStart;
          end;
          if FSelStart < FSelEnd then
          begin
            pStart := FSelStart;
            pEnd := FSelEnd;
          end;
          cStr := Copy(Caption, pStart + 1, abs(FSelStart - FSelEnd));
          if cStr <> '' then
          begin
            Clipboard.AsText := cStr;
          end;
        end;
      end;

      if (Ord(Key) = 24) and (FPasswordChar = #0) and (Caption <> '') then
      begin //CTRL + X
        if (FSelStart > -1) and (FSelEnd > -1) and (FSelStart <> FSelEnd) then
        begin
          if FSelStart > FSelEnd then
          begin
            pStart := FSelEnd;
            pEnd := FSelStart;
          end;
          if FSelStart < FSelEnd then
          begin
            pStart := FSelStart;
            pEnd := FSelEnd;
          end;
          cStr := Copy(Caption, pStart + 1, abs(FSelStart - FSelEnd));
          if cStr <> '' then
          begin
            Clipboard.AsText := cStr;
          end;
          FSelStart := -1;
          FSelEnd := -1;
          Caption := Copy(Caption, 1, pStart) + Copy(Caption, pEnd + 1, Length(Caption));
          FCurPos := pStart;
        end;
      end;

      if (Ord(Key) = 1) and not FIsHotKey and (Caption <> '') then
      begin //CTRL + A
        FSelStart := 0;
        FSelEnd := Length(Caption);
        FCurPos := FSelEnd;
      end;

      Result := inherited KeyPress(Key);
      Exit;
    end;

    Result := inherited KeyPress(Key);
    if Result then
    begin
      ShowCaret();
      case Ord(Key) of
        VK_BACK:
          begin
            if (FSelStart > -1) and (FSelEnd > -1) and (FSelStart <> FSelEnd) then
            begin
              if FSelStart > FSelEnd then
              begin
                pStart := FSelEnd;
                pEnd := FSelStart;
              end;
              if FSelStart < FSelEnd then
              begin
                pStart := FSelStart;
                pEnd := FSelEnd;
              end;
              FSelStart := -1;
              FSelEnd := -1;
              Caption := Copy(Caption, 1, pStart) + Copy(Caption, pEnd + 1, Length(Caption));
              FCurPos := pStart;
            end
            else
            begin
              if (FCurPos > 0) then
              begin
                nlen := 1;
                case ByteType(Caption, FCurPos) of
                  mbSingleByte:
                    nlen := 1;
                  mbLeadByte:
                    nlen := 2;
                  mbTrailByte:
                    nlen := 2;
                end;
                Caption := Copy(Caption, 1, FCurPos - nlen) + Copy(Caption, FCurPos + 1, Length(Caption));
                Dec(FCurPos, nlen);

                {if (FCurPos >= 2) and (Caption[FCurPos] > #$80) and (Caption[FCurPos - 1] > #$80) then begin
                  Caption := Copy(Caption, 1, FCurPos - 2) + Copy(Caption, FCurPos + 1, Length(Caption));
                  Dec(FCurPos, 2);
                end else begin
                  Caption := Copy(Caption, 1, FCurPos - 1) + Copy(Caption, FCurPos + 1, Length(Caption));
                  Dec(FCurPos);
                end;}
              end;
            end;
          end;
      else
        begin
          if (FMaxLength <= 0) or (FMaxLength > MaxChar) then
            FMaxLength := MaxChar;
          if (FSelStart > -1) and (FSelEnd > -1) and (FSelStart <> FSelEnd) then
          begin
            if FSelStart > FSelEnd then
            begin
              pStart := FSelEnd;
              pEnd := FSelStart;
            end;
            if FSelStart < FSelEnd then
            begin
              pStart := FSelStart;
              pEnd := FSelEnd;
            end;
            if FNomberOnly then
            begin
              if (Key >= #$30) and (Key <= #$39) then
              begin
                FSelStart := -1;
                FSelEnd := -1;
                Caption := Copy(Caption, 1, pStart) + Copy(Caption, pEnd + 1, Length(Caption));
                FCurPos := pStart;
                FSecondChineseChar := False;
                if Length(Caption) < FMaxLength then
                begin
                  Caption := Copy(Caption, 1, FCurPos) + Key + Copy(Caption, FCurPos + 1, Length(Caption));
                  Inc(FCurPos);
                end
                else
                  System.SysUtils.Beep;
              end
              else
                System.SysUtils.Beep;
            end
            else
            begin
              FSelStart := -1;
              FSelEnd := -1;
              Caption := Copy(Caption, 1, pStart) + Copy(Caption, pEnd + 1, Length(Caption));
              FCurPos := pStart;
              if Key > #$80 then
              begin
                if FSecondChineseChar then
                begin
                  FSecondChineseChar := False;
                  if Length(Caption) < FMaxLength then
                  begin
                    Caption := Copy(Caption, 1, FCurPos) + Key + Copy(Caption, FCurPos + 1, Length(Caption));
                    Inc(FCurPos);
                  end
                  else
                    System.SysUtils.Beep;
                end
                else
                begin
                  if Length(Caption) + 1 < FMaxLength then
                  begin
                    FSecondChineseChar := True;
                    Caption := Copy(Caption, 1, FCurPos) + Key + Copy(Caption, FCurPos + 1, Length(Caption));
                    Inc(FCurPos);
                  end
                  else
                    System.SysUtils.Beep;
                end;
              end
              else
              begin
                FSecondChineseChar := False;
                if Length(Caption) < FMaxLength then
                begin
                  Caption := Copy(Caption, 1, FCurPos) + Key + Copy(Caption, FCurPos + 1, Length(Caption));
                  Inc(FCurPos);
                end
                else
                  System.SysUtils.Beep;
              end;
            end;
          end
          else
          begin
            if FNomberOnly then
            begin
              if (Key >= #$30) and (Key <= #$39) then
              begin
                FSelStart := -1;
                FSelEnd := -1;
                FSecondChineseChar := False;
                if Length(Caption) < FMaxLength then
                begin
                  Caption := Copy(Caption, 1, FCurPos) + Key + Copy(Caption, FCurPos + 1, Length(Caption));
                  Inc(FCurPos);
                end;
              end
              else
                System.SysUtils.Beep;
            end
            else
            begin
              FSelStart := -1;
              FSelEnd := -1;
              if Key > #$80 then
              begin
                if FSecondChineseChar then
                begin
                  FSecondChineseChar := False;
                  if Length(Caption) < FMaxLength then
                  begin
                    Caption := Copy(Caption, 1, FCurPos) + Key + Copy(Caption, FCurPos + 1, Length(Caption));
                    Inc(FCurPos);
                    FSelStart := FCurPos;
                  end
                  else
                    System.SysUtils.Beep;
                end
                else
                begin
                  if Length(Caption) + 1 < FMaxLength then
                  begin
                    FSecondChineseChar := True;
                    Caption := Copy(Caption, 1, FCurPos) + Key + Copy(Caption, FCurPos + 1, Length(Caption));
                    Inc(FCurPos);
                    FSelStart := FCurPos;
                  end
                  else
                    System.SysUtils.Beep;
                end;
              end
              else
              begin
                FSecondChineseChar := False;
                if Length(Caption) < FMaxLength then
                begin
                  Caption := Copy(Caption, 1, FCurPos) + Key + Copy(Caption, FCurPos + 1, Length(Caption));
                  Inc(FCurPos);
                  FSelStart := FCurPos;
                end
                else
                  System.SysUtils.Beep;
              end;
            end;
          end;
        end;
      end;
    end;
  finally
    if s <> Caption then
    begin
      if Assigned(FOnTextChanged) then
        FOnTextChanged(self, Caption);
    end;
  end;
end;

function TDxCustomEdit.KeyPressEx(var Key: Char): Boolean;
var
  s, cStr: string;
  nlen, cpLen: Integer;
  pStart: Integer;
  pEnd: Integer;
begin
  Result := False;
  pStart := 0;
  pEnd := 0;

  if not FEnabled or FIsHotKey then
    Exit;
  if not self.Visible then
    Exit;
  if (self.DParent = nil) or (not self.DParent.Visible) then
    Exit;

  s := Caption;
  try
    if not FNomberOnly and (Ord(Key) in [1..27]) then
    begin
      if (Ord(Key) = 22) then
      begin     //CTRL + V
        if (FSelStart > -1) and (FSelEnd > -1) and (FSelStart <> FSelEnd) then
        begin
          if FSelStart > FSelEnd then
          begin
            pStart := FSelEnd;
            pEnd := FSelStart;
          end;
          if FSelStart < FSelEnd then
          begin
            pStart := FSelStart;
            pEnd := FSelEnd;
          end;
          cStr := Clipboard.AsText;
          if cStr <> '' then
          begin
            cpLen := FMaxLength - Length(Caption) + abs(FSelStart - FSelEnd);
            FSelStart := -1;
            FSelEnd := -1;
            Caption := Copy(Caption, 1, pStart) + Copy(Caption, pEnd + 1, Length(Caption));
            FCurPos := pStart;

            nlen := Length(cStr);
            if nlen < cpLen then
              cpLen := nlen;
            Caption := Copy(Caption, 1, FCurPos) + Copy(cStr, 1, cpLen) + Copy(Caption, FCurPos + 1, Length(Caption));
            Inc(FCurPos, cpLen);
          end;
        end
        else
        begin
          cpLen := FMaxLength - Length(Caption);
          if cpLen > 0 then
          begin
            cStr := Clipboard.AsText;
            if cStr <> '' then
            begin
              nlen := Length(cStr);
              if nlen < cpLen then
                cpLen := nlen;
              Caption := Copy(Caption, 1, FCurPos) + Copy(cStr, 1, cpLen) + Copy(Caption, FCurPos + 1, Length(Caption));
              Inc(FCurPos, cpLen);
            end;
          end
          else
            System.SysUtils.Beep;
        end;
      end;

      if (Ord(Key) = 3) and (FPasswordChar = #0) and (Caption <> '') then
      begin //CTRL + C
        if (FSelStart > -1) and (FSelEnd > -1) and (FSelStart <> FSelEnd) then
        begin
          if FSelStart > FSelEnd then
          begin
            pStart := FSelEnd;
            pEnd := FSelStart;
          end;
          if FSelStart < FSelEnd then
          begin
            pStart := FSelStart;
            pEnd := FSelEnd;
          end;
          cStr := Copy(Caption, pStart + 1, abs(FSelStart - FSelEnd));
          if cStr <> '' then
          begin
            Clipboard.AsText := cStr;
          end;
        end;
      end;

      if (Ord(Key) = 24) and (FPasswordChar = #0) and (Caption <> '') then
      begin //CTRL + X
        if (FSelStart > -1) and (FSelEnd > -1) and (FSelStart <> FSelEnd) then
        begin
          if FSelStart > FSelEnd then
          begin
            pStart := FSelEnd;
            pEnd := FSelStart;
          end;
          if FSelStart < FSelEnd then
          begin
            pStart := FSelStart;
            pEnd := FSelEnd;
          end;
          cStr := Copy(Caption, pStart + 1, abs(FSelStart - FSelEnd));
          if cStr <> '' then
          begin
            Clipboard.AsText := cStr;
          end;
          FSelStart := -1;
          FSelEnd := -1;
          Caption := Copy(Caption, 1, pStart) + Copy(Caption, pEnd + 1, Length(Caption));
          FCurPos := pStart;
        end;
      end;

      if (Ord(Key) = 1) and not FIsHotKey and (Caption <> '') then
      begin //CTRL + A
        FSelStart := 0;
        FSelEnd := Length(Caption);
        FCurPos := FSelEnd;
      end;

      if (Ord(Key) = VK_BACK) and not FIsHotKey and (Caption <> '') then
      begin //CTRL + A
        if (FSelStart > -1) and (FSelEnd > -1) and (FSelStart <> FSelEnd) then
        begin
          if FSelStart > FSelEnd then
          begin
            pStart := FSelEnd;
            pEnd := FSelStart;
          end;
          if FSelStart < FSelEnd then
          begin
            pStart := FSelStart;
            pEnd := FSelEnd;
          end;
          FSelStart := -1;
          FSelEnd := -1;
          Caption := Copy(Caption, 1, pStart) + Copy(Caption, pEnd + 1, Length(Caption));
          FCurPos := pStart;
        end;
      end;
    end;
  finally
    if s <> Caption then
    begin
      if Assigned(FOnTextChanged) then
        FOnTextChanged(self, Caption);
    end;
  end;
end;

function TDxCustomEdit.SetOfHotKey(HotKey: Cardinal): Word;
begin
  Result := 0;
  if (HotKey <> 0) then
  begin
    if FAtom <> 0 then
    begin
      UnregisterHotKey(g_MainHWnd, FAtom);
      GlobalDeleteAtom(FAtom);
    end;
    Result := 0;
    FHotKey := HotKey;
    Caption := HotKeyToText(HotKey, True);
  end;
end;

function TDxCustomEdit.KeyDown(var Key: Word; Shift: TShiftState): Boolean;
var
  pStart, pEnd: Integer;
  M: Word;
  HK: Cardinal;
  ret: Boolean;
  s: string;
begin
  Result := False;
  pStart := 0;
  pEnd := 0;

  if not FEnabled then
    Exit;
  s := Caption;
  try
    ret := inherited KeyDown(Key, Shift);
    if ret then
    begin
      if FIsHotKey then
      begin
        if Key in [VK_BACK, VK_DELETE] then
        begin
          if (FHotKey <> 0) then
          begin
            FHotKey := 0;
            FAtom := 0;
          end;
          Caption := '';
          Exit;
        end;
        if (Key = VK_TAB) or (Char(Key) in ['A'..'Z', 'a'..'z']) then
        begin
          M := 0;
          if ssCtrl in Shift then
            M := M or MOD_CONTROL;
          if ssAlt in Shift then
            M := M or MOD_ALT;
          if ssShift in Shift then
            M := M or MOD_SHIFT;
          HK := GetHotKey(M, Key);
          if (HK <> 0) and (FHotKey <> 0) then
          begin
            FAtom := 0;
            FHotKey := 0;
            Caption := '';
          end;
          if (HK <> 0) then
            SetOfHotKey(HK);
        end;
      end
      else
      begin

        if (Char(Key) in ['0'..'9', 'A'..'Z', 'a'..'z']) then
          ShowCaret();

        if ssShift in Shift then
        begin
          case Key of
            VK_RIGHT:
              begin
                FSelClickEnd := True;
                ChangeCurPos(1);
              end;
            VK_LEFT:
              begin
                FSelClickEnd := True;
                ChangeCurPos(-1);
              end;
            VK_HOME:
              begin
                FSelEnd := FCurPos;
                FSelStart := 0;
              end;
            VK_END:
              begin
                FSelStart := FCurPos;
                FSelEnd := Length(Text);
              end;
          end;
        end
        else
        begin
          case Key of
            VK_LEFT:
              begin
                FSelStart := -1;
                FSelEnd := -1;
                FSelClickStart := True;
                ChangeCurPos(-1);
              end;
            VK_RIGHT:
              begin
                FSelStart := -1;
                FSelEnd := -1;
                FSelClickStart := True;
                ChangeCurPos(1);
              end;
            VK_HOME:
              begin
                FSelStart := -1;
                FSelEnd := -1;
                FCurPos := 0;
                FSelClickStart := True;
              end;
            VK_END:
              begin
                FSelStart := -1;
                FSelEnd := -1;
                FCurPos := Length(Text);
                FSelClickStart := True;
              end;
            VK_DELETE:
              begin
                if (FSelStart > -1) and (FSelEnd > -1) and (FSelStart <> FSelEnd) then
                begin
                  if FSelStart > FSelEnd then
                  begin
                    pStart := FSelEnd;
                    pEnd := FSelStart;
                  end;
                  if FSelStart < FSelEnd then
                  begin
                    pStart := FSelStart;
                    pEnd := FSelEnd;
                  end;
                  FSelStart := -1;
                  FSelEnd := -1;
                  Caption := Copy(Caption, 1, pStart) + Copy(Caption, pEnd + 1, Length(Caption));
                  FCurPos := pStart;
                end
                else
                begin
                  if FCurPos < Length(Caption) then
                  begin
                    pEnd := 1;
                    case ByteType(Caption, FCurPos + 1) of
                      mbSingleByte:
                        pEnd := 1;
                      mbLeadByte:
                        pEnd := 2; //汉字的第一个字节
                      mbTrailByte:
                        pEnd := 2; //汉字的第二个字节
                    end;
                    Caption := Copy(Caption, 1, FCurPos) + Copy(Caption, FCurPos + pEnd + 1, Length(Caption));

                    {if (FCurPos < Length(Caption) - 1) and (Caption[FCurPos + 1] > #$80) then
                      Caption := Copy(Caption, 1, FCurPos) + Copy(Caption, FCurPos + 3, Length(Caption))
                    else
                      Caption := Copy(Caption, 1, FCurPos) + Copy(Caption, FCurPos + 2, Length(Caption));}
                  end;
                end;
              end;
          end;
        end;
      end;
    end;
    Result := ret;
  finally
    if s <> Caption then
    begin
      if Assigned(FOnTextChanged) then
        FOnTextChanged(self, Caption);
    end;
  end;
end;

procedure TDxCustomEdit.DirectPaint(dsurface: TDXTexture);
var
  bFocused: Boolean;
  i, WidthX, nl, nt: Integer;
  tmpword: string[255];
  tmpColor: TColor;
  FontColor, BrushColor: TColor;
  ss, se, cPos: Integer;
begin
  if not Visible then
    Exit;
  nl := SurfaceX(Left);
  nt := SurfaceY(Top);

  if (FocusedControl <> self) and (DxHint <> nil) then
    DxHint.Visible := False;

  if FEnabled and not FIsHotKey then
  begin
    if GetTickCount - FShowCaretTick >= 400 then
    begin
      FShowCaretTick := GetTickCount;
      FShowCaret := not FShowCaret;
    end;
    if (FCurPos > Length(Caption)) then
      FCurPos := Length(Caption);
  end;

  if (FPasswordChar <> #0) and not FIsHotKey then
  begin
    tmpword := '';
    for i := 1 to Length(Caption) do
      if Caption[i] <> FPasswordChar then
        tmpword := tmpword + FPasswordChar;
  end
  else
    tmpword := Caption;

  with g_DXCanvas do
  begin
    if FEnabled or (self is TDComboBox) then
    begin
      FontColor := self.Font.Color;
      //BrushColor := self.Color;
    end
    else
    begin
      FontColor := self.Font.Color;
      //BrushColor := clGray;
    end;

    if not FIsHotKey and FEnabled and FClick then
    begin
      FClick := False;

      if (FClickX < 0) then
        FClickX := 0;
      se := TextWidth(tmpword);
      if FClickX > se then
        FClickX := se;

      cPos := FClickX div 6;
      case ByteType(tmpword, cPos + 1) of
        mbSingleByte:
          FCurPos := cPos;
        mbLeadByte:
          begin               //双字节字符的首字符
            FCurPos := cPos;
          end;
        mbTrailByte:
          begin              //多字节字符首字节之后的字符
            if cPos mod 2 = 0 then
            begin
              if FClickX mod 6 in [3..5] then
                FCurPos := cPos + 1
              else
                FCurPos := cPos - 1;
            end
            else
            begin
              if FClickX mod 12 in [6..11] then
                FCurPos := cPos + 1
              else
                FCurPos := cPos - 1;
            end;
          end;
      end;

      if FSelClickStart then
      begin
        FSelClickStart := False;
        FSelStart := FCurPos;
      end;
      if FSelClickEnd then
      begin
        FSelClickEnd := False;
        FSelEnd := FCurPos;
      end;

    end;

    WidthX := TextWidth(Copy(tmpword, 1, FCurPos));
    if WidthX + 3 - FStartTextX > Width then
      FStartTextX := WidthX + 3 - Width;

    if ((WidthX - FStartTextX) < 0) then
      FStartTextX := FStartTextX + (WidthX - FStartTextX);

    if FTransparent then
    begin
      if FEnabled then
      begin
        FontColor := self.Font.Color;
        case FAlignment of
          taCenter:
            begin
              TextOut((nl - FStartTextX) + ((Width - TextWidth(tmpword)) div 2 - 2), nt, tmpword, FontColor);
            end;
          taLeftJustify:
            begin
              //等待替换
              TextOut(nl, nt, tmpword, FontColor);
              //TextRect(Rect(nl, nt - 3 - Integer(FMiniCaret), nl + Width - 3, nt + Height), string(tmpword), FontColor);
            end;
        end;
        //复制文字以及背景
        if (FSelStart > -1) and (FSelEnd > -1) and (FSelStart <> FSelEnd) and (FocusedControl = self) then
        begin
          ss := TextWidth(Copy(tmpword, 1, FSelStart));
          se := TextWidth(Copy(tmpword, 1, FSelEnd));

          BrushColor := clSkyBlue; //clBlue;        //GetRGB(4); //背景色 账号和密码
          //增加选取复制文字背景
          //FillRectAlpha(Rect(  _MAX(nl - 1, nl + ss - 1 - FStartTextX), nt - 1 - Integer(FMiniCaret), _MIN(nl + self.Width + 1, nl + se + 1 - FStartTextX), nt + TextHeight('c') + 1 - Integer(FMiniCaret)),BrushColor,255);
          FontColor := clWhite;
          if FSelStart < FSelEnd then
          begin   //复制文字显示
            FillRectAlpha(Rect(nl + ss - 1, nt - 3 - Integer(FMiniCaret), nl + ss + TextWidth(Copy(tmpword, FSelStart + 1, FSelEnd - FSelStart)) + 1, nt + TextHeight('c') + 2 - Integer(FMiniCaret) * 1), BrushColor, 255);

            //等待替换
            //TextRect(Rect(nl + ss - 1, nt - 3 - Integer(FMiniCaret), nl + ss + DrawFont.TextWidth(Copy(tmpword, FSelStart + 1, FSelEnd - FSelStart)) + 1, nt + DrawFont.TextHeight('c') + 2 - Integer(FMiniCaret) * 1), Copy(tmpword, FSelStart + 1, FSelEnd - FSelStart), FontColor);
          end
          else
          begin
            FillRectAlpha(Rect(nl + se - 1, nt - 3 - Integer(FMiniCaret), nl + se + TextWidth(Copy(tmpword, FSelEnd + 1, FSelStart - FSelEnd)) + 1, nt + TextHeight('c') + 2 - Integer(FMiniCaret)), BrushColor, 255);
            //等待替换
            //TextRect(Rect(nl + se - 1, nt - 3 - Integer(FMiniCaret), nl + se + DrawFont.TextWidth(Copy(tmpword, FSelEnd + 1, FSelStart - FSelEnd)) + 1, nt + DrawFont.TextHeight('c') + 2 - Integer(FMiniCaret)), Copy(tmpword, FSelEnd + 1, FSelStart - FSelEnd), FontColor);
          end;
        end;
      end;
    end
    else
    begin
      if FFrameVisible then
      begin
        if FEnabled or (self is TDComboBox) then
        begin
          if FFrameHot then
            tmpColor := FFrameHotColor
          else
            tmpColor := FFrameColor;
        end
        else
          tmpColor := clGray;

        BrushColor := tmpColor; //TDxEdit 矩形边框颜色
        FillRectAlpha(Rect(nl - 3, nt - 4, nl + Width - 1, nt + Height), BrushColor, 255)
      end;

      if FIsHotKey then
      begin //是否热键
        bFocused := FocusedControl = self;
        if FEnabled then
        begin //可用
          BrushColor := clBlack; //TDxEdit 填充颜色 可用
          FillRectAlpha(Rect(nl + FFrameSize - 3 + Integer(bFocused), nt + FFrameSize - 3 + Integer(bFocused), nl + Width - FFrameSize - 1 - Integer(bFocused), nt + Height - FFrameSize - 1 - Integer(bFocused)), BrushColor, 255);

          if bFocused then
            FontColor := clLime //选中颜色
          else
            FontColor := self.Font.Color; //正常显示颜色
        end
        else
        begin
          BrushColor := self.Color; //TDxEdit 填充颜色 不可用
          FillRectAlpha(Rect(nl + FFrameSize - 3, nt + FFrameSize - 3, nl + Width - FFrameSize - 1, nt + Height - FFrameSize - 1), BrushColor, 255);

          FontColor := clGray;
        end;
        case FAlignment of
          taCenter:
            TextOut((nl - FStartTextX) + ((Width - TextWidth(tmpword)) div 2 - 2), nt, tmpword, FontColor);
          taLeftJustify:
            begin
              TextOut(nl - FStartTextX, nt, tmpword, FontColor);
            end;
        end;
      end
      else
      begin
        BrushColor := self.Color; //TDxEdit+TDComboBox 背景填充颜色
        FillRectAlpha(Rect(nl - 3 + FFrameSize, nt - 4 + FFrameSize, nl + Width - 1 - FFrameSize, nt + Height - FFrameSize), BrushColor, 255);
        if FEnabled then
        begin

          case FAlignment of
            taCenter:
              TextOut((nl - FStartTextX) + ((Width - TextWidth(tmpword)) div 2 - 2), nt - Integer(FMiniCaret) * 1, tmpword, FontColor);
            taLeftJustify:
              begin
                //等待替换
                //TextRect(Rect(nl, nt - Integer(FMiniCaret) - 3, nl + Width - 1, nt + Height), tmpword, FontColor);
              end;
          end;

          if (FSelStart > -1) and (FSelEnd > -1) and (FSelStart <> FSelEnd) and (FocusedControl = self) then
          begin
            ss := TextWidth(Copy(tmpword, 1, FSelStart));
            se := TextWidth(Copy(tmpword, 1, FSelEnd));
            BrushColor := clSkyBlue; //clBlue;      //GetRGB(4); 文字选中颜色

            FontColor := clWhite;
            if FSelStart < FSelEnd then
            begin
              FillRectAlpha(Rect(nl + ss - 1, nt - 3 - Integer(FMiniCaret), nl + ss + TextWidth(Copy(tmpword, FSelStart + 1, FSelEnd - FSelStart)) + 1, nt + TextHeight('c') + 2 - Integer(FMiniCaret) * 1), BrushColor, 255);
              //等待替换
              //TextRect(Rect(nl + ss - 1, nt - 3 - Integer(FMiniCaret), nl + ss + DrawFont.TextWidth(Copy(tmpword, FSelStart + 1, FSelEnd - FSelStart)) + 1, nt + DrawFont.TextHeight('c') + 2 - Integer(FMiniCaret) * 1), Copy(tmpword, FSelStart + 1, FSelEnd - FSelStart), FontColor);
            end
            else
            begin
              FillRectAlpha(Rect(nl + se - 1, nt - 3 - Integer(FMiniCaret), nl + se + TextWidth(Copy(tmpword, FSelEnd + 1, FSelStart - FSelEnd)) + 1, nt + TextHeight('c') + 2 - Integer(FMiniCaret)), BrushColor, 255);
              //等待替换
              //TextRect(Rect(nl + se - 1, nt - 3 - Integer(FMiniCaret), nl + se + DrawFont.TextWidth(Copy(tmpword, FSelEnd + 1, FSelStart - FSelEnd)) + 1, nt + DrawFont.TextHeight('c') + 2 - Integer(FMiniCaret)), Copy(tmpword, FSelEnd + 1, FSelStart - FSelEnd), FontColor);
            end;

          end;
        end
        else
        begin
          FontColor := clYellow;

          case FAlignment of
            taCenter:
              TextOut((nl - FStartTextX) + ((Width - TextWidth(tmpword)) div 2 - 2), nt - Integer(FMiniCaret) * 1, tmpword, FontColor);
            taLeftJustify:
              begin
                //等待替换
                //TextRect(Rect(nl, nt - 4 - Integer(FMiniCaret), nl + Width - 1, nt + Height + 1), tmpword, FontColor);
              end;
          end;
        end;
      end;
      if self is TDComboBox then
      begin
        FontColor := clWhite;
//        BrushColor := tmpColor;
        Polygon([Point(nl + Width - DECALW * 2 + Integer(Downed), nt + (Height - DECALH) div 2 - 2 + Integer(Downed)), Point(nl + Width - DECALW + Integer(Downed), nt + (Height - DECALH) div 2 - 2 + Integer(Downed)), Point(nl + Width - DECALW - DECALW div 2 + Integer(Downed), nt + (Height - DECALH) div 2 + DECALH - 2 + Integer(Downed))], FontColor, True);
      end;
    end;
    if FEnabled then
    begin //闪动光标
      if (FocusedControl = self) then
      begin
        begin
          SetFrameHot(True);
          if (Length(tmpword) >= FCurPos) and (FShowCaret and not FIsHotKey) then
          begin
            case FAlignment of
              taCenter:
                begin
                  FillRectAlpha(Rect(nl + WidthX - FStartTextX + ((Width - TextWidth(tmpword)) div 2 - 2), nt - Integer(FMiniCaret <> 0) * 1, nl + WidthX + 2 - Integer(FMiniCaret <> 0) - FStartTextX + ((Width - TextWidth(tmpword)) div 2 - 2), nt - Integer(FMiniCaret <> 0) * 1 + TextHeight('c')), FCaretColor, 255)
                end;
              taLeftJustify:
                begin
                  FillRectAlpha(Rect(nl + WidthX - FStartTextX, nt - Integer(FMiniCaret) * 1 - Integer(FMiniCaret = 0), nl + WidthX + 2 - FStartTextX - Integer(FMiniCaret <> 0), nt - Integer(FMiniCaret) * 1 + TextHeight('c') + Integer(FMiniCaret = 0)), FCaretColor, 255);
                end;
            end;

          end;
        end;
      end;
    end;
{$IF NEWUUI}
    if (Text = '') and (g_SendSayList.count > 0) and (m_InputHint <> '') then
    begin
      FontColor := clSilver;
      g_DXCanvas.TextOut(nl + self.Width - g_DXCanvas.TextWidth(m_InputHint) - 4, nt - Integer(FMiniCaret), FontColor, m_InputHint);
    end;
{$ELSE}
    if (Text = '') and (m_InputHint <> '') then
    begin
      FontColor := clGray;
      g_DXCanvas.TextOut(nl + self.Width - g_DXCanvas.TextWidth(m_InputHint) - 4, nt - Integer(FMiniCaret), m_InputHint, FontColor);
    end;
{$ENDIF NEWUUI}
  end;

  for i := 0 to DControls.count - 1 do
    if TDControl(DControls[i]).Visible then
      TDControl(DControls[i]).DirectPaint(dsurface);

  if g_TranFrame then
    g_DXCanvas.RoundRect(SurfaceX(Left), SurfaceY(Top), SurfaceX(Left + Width), SurfaceY(Top + Height), clLime);

  if g_DragMode and (SeletedControl = Self) then
    g_DXCanvas.RoundRect(SurfaceX(Left), SurfaceY(Top), SurfaceX(Left + Width), SurfaceY(Top + Height), clRed);
end;

function TDxCustomEdit.MouseMove(Shift: TShiftState; X, Y: Integer): Boolean;
begin
  Result := False;
  FSelClickEnd := False;
  if inherited MouseMove(Shift, X, Y) then
  begin
    if [ssLeft] = Shift then
    begin
      if FEnabled and not FIsHotKey and (MouseCaptureControl = self) and (Caption <> '') then
      begin
        FClick := True;
        FSelClickEnd := True;
        FClickX := X - Left + FStartTextX;
      end;
    end
    else
    begin
      //if DxHint <> nil then
      //  DxHint.Visible := False;
    end;
    Result := True;
  end;
end;

function TDxCustomEdit.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean;
begin
  Result := False;
  FSelClickStart := False;
  if inherited MouseDown(Button, Shift, X, Y) then
  begin
    if FEnabled and not FIsHotKey and (MouseCaptureControl = self) then
    begin
      if Button = mbLeft then
      begin
        FSelEnd := -1;
        FSelStart := -1;
        FClick := True;
        FSelClickStart := True;
        FClickX := X - Left + FStartTextX;
      end;
    end
    else
    begin
      //if DxHint <> nil then
      //  DxHint.Visible := False;
    end;
    Result := True;
  end;
end;

function TDxCustomEdit.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean;
begin
  Result := False;
  FSelClickEnd := False;
  if inherited MouseUp(Button, Shift, X, Y) then
  begin
    if FEnabled and not FIsHotKey and (MouseCaptureControl = self) then
    begin
      if Button = mbLeft then
      begin
        FSelEnd := -1;
        FClick := True;
        FSelClickEnd := True;
        FClickX := X - Left + FStartTextX;
      end;
    end
    else
    begin
      //if DxHint <> nil then
      //  DxHint.Visible := False;
    end;
    Result := True;
  end;
end;

{--------------------- TDComboBox --------------------------}

constructor TDComboBox.Create(aowner: TComponent);
begin
  inherited Create(aowner);
  DropDownList := nil;
  FShowCaret := False;
  FTransparent := False;
  FEnabled := False;
  FDropDownList := nil;
end;

function TDComboBox.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean;
begin
  Result := False;
  if inherited MouseDown(Button, Shift, X, Y) then
  begin
    if (not Background) and (MouseCaptureControl = nil) then
    begin
      Downed := True;
      SetDCapture(self);
    end;
    if (FDropDownList <> nil) and not FDropDownList.ChangingHero then
    begin
      FDropDownList.Visible := not FDropDownList.Visible;
    end;
    Result := True;
  end
  else if FDropDownList <> nil then
  begin
    if FDropDownList.Visible then
      FDropDownList.Visible := False;
  end;
end;

function TDComboBox.MouseMove(Shift: TShiftState; X, Y: Integer): Boolean;
begin
  Result := inherited MouseMove(Shift, X, Y);
  if not Background then
  begin
    if Result then
      SetFrameHot(True)
    else if FocusedControl <> self then
      SetFrameHot(False);
  end;
end;

{------------------------- TDxCustomListBox --------------------------}

constructor TDxListBoxCustom.Create(aowner: TComponent);
begin
  inherited Create(aowner);
  FSelected := -1;
  ChangingHero := False;
  FItems := TStringList.Create;
  FBackColor := clWhite;
  FSelectionColor := clSilver;
  FOnChangeSelect := nil;               //ChangeSelect;
  FOnMouseMoveSelect := nil;
  ParentComboBox := nil;
  FParentComboBox := nil;
  //DxScroll := TDxScrollBar.Create(w - 20, 0, 20, h - 2, Self, FItems, Font, h - 2);
  //add_fenetre(DxScroll);
end;

destructor TDxListBoxCustom.Destroy;
begin
  FItems.Free;
  inherited;
end;

function TDxListBoxCustom.GetItemSelected: Integer;
begin
  if (FSelected > FItems.count - 1) or (FSelected < 0) then
    Result := -1
  else
    Result := FSelected;
  //if Assigned(FOnChangeSelect) then begin
  // FOnChangeSelect(Self, FSelected);
  //end;
end;

procedure TDxListBoxCustom.SetItemSelected(Value: Integer);
begin
  if (Value > FItems.count - 1) or (Value < 0) then
    FSelected := -1
  else
    FSelected := Value;
  {if Assigned(FOnChangeSelect) then begin
    FOnChangeSelect(Self, FSelected);
  end;}
end;

procedure TDxListBoxCustom.SetBackColor(Value: TColor);
begin
  if FBackColor <> Value then
  begin
    FBackColor := Value;
    Perform(CM_COLORCHANGED, 0, 0);
  end;
end;

procedure TDxListBoxCustom.SetSelectionColor(Value: TColor);
begin
  if FSelectionColor <> Value then
  begin
    FSelectionColor := Value;
    Perform(CM_COLORCHANGED, 0, 0);
  end;
end;

function TDxListBoxCustom.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean;
begin
  //DScreen.AddChatBoardString('MouseDown', clWhite, clRed);
  Result := inherited MouseDown(Button, Shift, X, Y);
end;

function TDxListBoxCustom.MouseMove(Shift: TShiftState; X, Y: Integer): Boolean;
begin
  FSelected := -1;
  Result := inherited MouseMove(Shift, X, Y);
  if Result and FEnabled and not Background then
  begin
    if (FItems.count = 0) then
      FSelected := -1
    else
      FSelected := (-Top + Y) div (-g_DXCanvas.TextHeight('0') + LineSpace);
    if FSelected > FItems.count - 1 then
      FSelected := -1;
    if Assigned(FOnMouseMoveSelect) then
      FOnMouseMoveSelect(self, Shift, X, Y);
  end;
end;

function TDxListBoxCustom.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean;
var
  ret: Boolean;
begin
  ret := inherited MouseUp(Button, Shift, X, Y);
  if ret then
  begin
    if (FItems.count = 0) then
      FSelected := -1
    else
      FSelected := (-Top + Y) div (-g_DXCanvas.TextHeight('0') + LineSpace);

    if FSelected > FItems.count - 1 then
      FSelected := -1;

    if FSelected <> -1 then
    begin
      if ParentComboBox <> nil then
      begin
        if ParentComboBox.Caption <> FItems[FSelected] then
        begin
          if Caption = 'SelectHeroList' then
          begin
//            ChangingHero := True;
//            frmDlg.QueryChangeHero(FItems[FSelected]);
          end
          else
            ParentComboBox.Caption := FItems[FSelected];
        end;
      end;
      if Integer(FItems.Objects[FSelected]) > 0 then
        ParentComboBox.tag := Integer(FItems.Objects[FSelected]);
    end;
    if Assigned(FOnChangeSelect) then
      FOnChangeSelect(self, Button, Shift, X, Y);
    Visible := False;
    ret := True;
  end;
  Result := ret;
end;

function TDxListBoxCustom.KeyDown(var Key: Word; Shift: TShiftState): Boolean;
var
  ret: Boolean;
begin
  ret := inherited KeyDown(Key, Shift);
  if ret then
  begin
    case Key of
      VK_PRIOR:
        begin
          ItemSelected := ItemSelected - Height div  - g_DXCanvas.TextHeight('0');
          if (ItemSelected = -1) then
            ItemSelected := 0;
        end;
      VK_NEXT:
        begin
          ItemSelected := ItemSelected + Height div  - g_DXCanvas.TextHeight('0');
          if ItemSelected = -1 then
            ItemSelected := FItems.count - 1;
        end;
      VK_UP:
        if ItemSelected - 1 > -1 then
          ItemSelected := ItemSelected - 1;
      VK_DOWN:
        if ItemSelected + 1 < FItems.count then
          ItemSelected := ItemSelected + 1;
    end;
    {case Key of
      VK_PRIOR, VK_NEXT, VK_UP, VK_DOWN: if (ItemSelected <> -1) then begin
          while (((-DxScroll.GetPos + Height) div -Font.Height) <= ItemSelected) do
            DxScroll.MoveModPos(Font.Height);
          while (((-DxScroll.GetPos) div -Font.Height) > ItemSelected) do
            DxScroll.MoveModPos(-Font.Height);
        end;
    end;}
  end;
  Result := ret;
end;

{procedure TDxCustomListBox.ChangeSelect(ChangeSelect: Integer);
begin
  //
end;}

procedure TDxListBoxCustom.SetItems(Value: TStrings);
begin
  FItems.Assign(Value);
end;

procedure TDxListBoxCustom.DirectPaint(dsurface: TDXTexture);
var
  fy, nY, L, T, i, oSize: Integer;
  OldColor, {BrushColor,}FontColor: TColor;
begin
  if Assigned(FOnDirectPaint) then
  begin
    FOnDirectPaint(self, dsurface);
    Exit;
  end;
  L := SurfaceX(Left);
  T := SurfaceY(Top);
  with g_DXCanvas do
  begin
    try
      FillRectAlpha(Rect(L, T, L + Width, T + Height), clGray, 200); //TDListBox 背景颜色

      if FSelected <> -1 then
      begin
        nY := T + (-g_DXCanvas.TextHeight('0') + LineSpace) * FSelected;
        fy := nY + (-g_DXCanvas.TextHeight('0') + LineSpace);
        if (nY < T + Height - 1) and (fy > T + 1) then
        begin
          if (fy > T + Height - 1) then
            fy := T + Height - 1;
          if (nY < T + 1) then
            nY := T + 1;
          FillRectAlpha(Rect(L + 1, nY, L + Width - 1, fy + 2), SelectionColor, 255);
        end;
      end;                                             
      //MainForm.Canvas.Brush.Style := bsClear;
      for i := 0 to FItems.count - 1 do
      begin
        if FSelected = i then
        begin
          FontColor := OldColor;
          //g_DXCanvas.BoldTextOut(L + 2, 2 + T + (-MainForm.Canvas.Font.Height + LineSpace) * i, FontColor, FItems.Strings[i]);
        end
        else
        begin
          FontColor := clWhite;
          //g_DXCanvas.BoldTextOut(L + 2, 2 + T + (-MainForm.Canvas.Font.Height + LineSpace) * i, FontColor, FItems.Strings[i]);
        end;
      end;
    finally
    end;
  end;
end;
{==============================================Edit过程结束==================================}


{ TDXCaption }

constructor TDXCaption.Create(Propertites: TCustomDXPropertites);
begin
  FOwner := Propertites;
end;

procedure TDXCaption.setCaption(const s: string);
begin
//  if s <> FControl.FCaption then
//  begin
//    FControl.FCaption := s;
//  end;
end;

function TDXCaption.getCaption: string;
begin
  Result := FOwner.FControl.FCaption;
end;

function TDXCaption.GetColor(Index: Integer): TColor;
begin
  result := clWhite;
  case Index of
    1: result := FOwner.FControl.DefColor;
    2: result := FOwner.FControl.MoveColor;
    3: result := FOwner.FControl.DownColor;
    4: result := FOwner.FControl.EnabledColor;
    5: result := FOwner.FControl.BackColor;
  end;
end;

function TDXCaption.GetDrawVisable(): Boolean;
begin
  result := false;
  if FOwner.FControl is TDButton then
    result := TDButton(FOwner.FControl).ShowText;
end;

function TDXCaption.getText: string;
begin
  Result := FOwner.FControl.FText;
end;

procedure TDXCaption.SetColor(Index: Integer; Value: TColor);
begin
  case index of
    1: FOwner.FControl.DefColor := Value;
    2: FOwner.FControl.MoveColor := Value;
    3: FOwner.FControl.DownColor := Value;
    4: FOwner.FControl.EnabledColor := Value;
    5: FOwner.FControl.BackColor := Value;
  end;
end;

procedure TDXCaption.SetDrawVisable(Value: Boolean);
begin
  if (FOwner.FControl is TDButton) then
    TDButton(FOwner.FControl).ShowText := Value;
end;

procedure TDXCaption.setText(const Value: string);
begin
  if Value <> FOwner.FControl.FText then
  begin
    FOwner.FControl.FText := Value;
  end;
end;

{ TDXPosition }

procedure TDXPosition.SetAnchor(index: Integer; Value: Single);
begin
  FOwner.FControl.SetAnchor(index, Value);
end;

procedure TDXPosition.SetAnchorPoint(Value: Boolean);
begin
  FOwner.FControl.SetAnchorPoint(Value);
end;

procedure TDXPosition.SetPosition(index, Size: integer);
begin
  case index of
    1:
      FOwner.FControl.Left := Size;
    2:
      FOwner.FControl.Top := Size;
    3:
      FOwner.FControl.Width := Size;
    4:
      FOwner.FControl.Height := Size;
  end;
  FOwner.FControl.PositionChanged();
end;

function TDXPosition.GetAnchor(index: Integer): Single;
begin
  result := FOwner.FControl.GetAnchor(index);
end;

function TDXPosition.GetAnchorPostion: Boolean;
begin
  result := FOwner.FControl.FAnchorPostion;
end;

function TDXPosition.GetPostion(Index: integer): integer;
begin
  result := 0;
  case index of
    1:
      result := FOwner.FControl.Left;
    2:
      result := FOwner.FControl.Top;
    3:
      result := FOwner.FControl.Width;
    4:
      result := FOwner.FControl.Height;
  end;
end;

{ TDXImageProperty }

constructor TDXImageProperty.Create(Propertites: TCustomDXPropertites);
begin
  FOwner := Propertites;
end;

function TDXImageProperty.GetAniLoop: Boolean;
begin
  result := FOwner.GetAniLoop;
end;


function TDXImageProperty.GetClipBarType: TClipBarType;
begin
  result := FOwner.GetClipBarType;
end;

function TDXImageProperty.GetDrawDirection: TDrawDirection;
begin
  result := FOwner.GetDrawDirection;
end;

function TDXImageProperty.GetDrawMode: TDrawMode;
begin
  result := FOwner.GetDrawMode;
end;

function TDXImageProperty.GetProperty(Index: integer): integer;
begin
  result := FOwner.GetImageIndex(Index);
end;

procedure TDXImageProperty.SetProperty(Index, Value: integer);
begin
  FOwner.SetImageIndex(Index, Value);
end;

function TDXImageProperty.GetLib: TLibFile;
begin
  Result := FOwner.GetLib;
end;

function TDXImageProperty.GetOffsetX: Integer;
begin
  Result := FOwner.GetOffsetX;
end;

function TDXImageProperty.GetOffsetY: Integer;
begin
  Result := FOwner.GetOffsetY;
end;

procedure TDXImageProperty.SetLib(const Value: TLibFile);
begin
  FOwner.SetLib(Value);
end;

procedure TDXImageProperty.SetAniLoop(const Value: Boolean);
begin
  FOwner.SetAniLoop(Value);
end;

procedure TDXImageProperty.SetClipBarType(const Value: TClipBarType);
begin
  FOwner.SetClipBarType(Value);
end;

procedure TDXImageProperty.SetDrawDirection(const Value: TDrawDirection);
begin
  FOwner.SetDrawDirection(Value);
end;

procedure TDXImageProperty.SetDrawMode(const Value: TDrawMode);
begin
  FOwner.SetDrawMode(Value);
end;

procedure TDXImageProperty.SetOffsetX(const Value: Integer);
begin
  FOwner.SetOffsetX(Value);
end;

procedure TDXImageProperty.SetOffsetY(const Value: Integer);
begin
  FOwner.SetOffsetY(Value);
end;

{ TCustomDXPropertites }

constructor TCustomDXPropertites.Create(AControl: TDControl);
begin
  FControl := AControl;

  FControlPosition := TDXPosition.Create;
  FControlPosition.FOwner := Self;

  FCaption := TDXCaption.Create(Self);
  FBtnCaption := TDXButtonCaption.Create(Self);
  FLabelCaption := TDXLabelCaption.Create(Self);
end;

destructor TCustomDXPropertites.Destroy;
begin
  FLabelCaption.Free;
  FBtnCaption.Free;
  FCaption.Free;
  FControlPosition.Free;
  inherited;
end;

function TCustomDXPropertites.GetPostion(Index: integer): integer;
begin
  result := 0;
  if csDesigning in FControl.ComponentState then begin
    case Index of
      1: Result := FLeft;
      2: Result := FTop;
      3: result := FWidth;
      4: result := FHeight;
    end;
  end else begin
    case Index of
      1: result := FControl.Left;
      2: result := FControl.Top;
      3: result := FControl.Width;
      4: result := FControl.Height;
    end;
  end;
end;

procedure TCustomDXPropertites.SetPosition(index, Size: integer);
begin
  if csDesigning in FControl.ComponentState then begin
    case index of
      1: FLeft := Size;
      2: FTop := Size;
      3: FWidth := Size;
      4: FHeight := Size;
    end;
  end else begin
    case index of
      1: FControl.Left := Size;
      2: FControl.Top := Size;
      3: FControl.Width := Size;
      4: FControl.Height := Size;
    end;
    FControl.PositionChanged();
  end;
end;

procedure TCustomDXPropertites.SetAniLoop(Value: Boolean);
begin
  if FControl is TDAniButton then begin
    TDAniButton(FControl).FAniLoop := Value;
    if Value then
      TDAniButton(FControl).Reset; //重新开始
  end;
end;

procedure TCustomDXPropertites.SetClipBarType(const Value: TClipBarType);
begin
  if FControl is TDImageBar then begin
    TDImageBar(FControl).FClipType := Value;
  end;
end;

procedure TCustomDXPropertites.SetDrawBarMode(const Value: TDrawBarMode);
begin
  if FControl is TDImageBar then begin
    TDImageBar(FControl).FDrawBarMode := Value;
  end;
end;


procedure TCustomDXPropertites.SetDrawDirection(const Value: TDrawDirection);
begin
  if FControl is TDImageBar then begin
    TDImageBar(FControl).DrawDirection := Value;
  end;
end;

procedure TCustomDXPropertites.SetDrawMode(const Value: TDrawMode);
begin
  FControl.DrawMode := Value;
end;

procedure TCustomDXPropertites.SetEscExit(Value: Boolean);
begin
  if FControl is TDWindow then
    TDWindow(FControl).FEscClose := Value;
end;

procedure TCustomDXPropertites.SetFloating(Value: Boolean);
begin
  if FControl is TDWindow then
    TDWindow(FControl).Floating := Value;
end;

procedure TCustomDXPropertites.SetOffsetX(const Value: Integer);
begin
  if FControl is TDAniButton then begin
    TDAniButton(FControl).FOffsetX := Value;
  end else
  if FControl is TDImageBar then begin
    TDImageBar(FControl).FOffsetX := Value;
  end;
end;

procedure TCustomDXPropertites.SetOffsetY(const Value: Integer);
begin
  if FControl is TDAniButton then begin
    TDAniButton(FControl).FOffsetY := Value;
  end else
  if FControl is TDImageBar then begin
    TDImageBar(FControl).FOffsetY := Value;
  end;
end;

procedure TCustomDXPropertites.SetImageIndex(index: integer; const Value: integer);
begin
  case index of
    1:
      begin
        if Value <> FControl.FImageIndex then
        begin
          FControl.FImageIndex := Value;
          FControl.InitImageLib;
        end;
      end;
    2:
      FControl.FDownedIndex := Value;
    3:
      FControl.FMoveIndex := Value;
    4:
      FControl.FDisabledIndex := Value;
    5:
      FControl.FCheckedIndex := Value;
    6:
    begin
      if FControl is TDAniButton then begin
        TDAniButton(FControl).FAniCount := Max(1, Value);
      end else
      if FControl is TDImageBar then begin
        TDImageBar(FControl).FAniCount := Max(1, Value);
      end;
    end;
    7: begin
      if FControl is TDAniButton then begin
        TDAniButton(FControl).FAniInterval := Max(10, Value);
      end else
      if FControl is TDImageBar then begin
        TDImageBar(FControl).FAniInterval := Max(10, Value);
      end;
    end;
  end;
end;

procedure TCustomDXPropertites.SetLib(const Value: TLibFile);
begin
  FControl.FLib := Value;
  if not (csDesigning in FControl.ComponentState) then
    FControl.InitImageLib();
end;

procedure TCustomDXPropertites.SetMouseThrough(Value: Boolean);
begin
  if Value <> FControl.FMouseThrough then
    FControl.FMouseThrough := Value;
end;

function TCustomDXPropertites.GetImageIndex(Index: integer): integer;
begin
  result := -1;
  case Index of
    1:
      result := FControl.FImageIndex;
    2:
      result := FControl.FDownedIndex;
    3:
      result := FControl.FMoveIndex;
    4:
      result := FControl.FDisabledIndex;
    5:
      result := FControl.FCheckedIndex;
    6: begin
      result := 0;
      if FControl is TDAniButton then begin
        result := TDAniButton(FControl).FAniCount;
      end else
      if FControl is TDImageBar then begin
        result := TDImageBar(FControl).FAniCount;
      end;
    end;
    7: begin
      result := 10;
      if FControl is TDAniButton then begin
        result := TDAniButton(FControl).FAniInterval;
      end else
      if FControl is TDImageBar then begin
        result := TDImageBar(FControl).FAniInterval;
      end;
    end;
  end;
end;

function TCustomDXPropertites.GetLib: TLibFile;
var
  i: Integer;
  ClientLib: TWMImages;
  Flielib: TLibFile;
begin
  Result := nill;
  if csDesigning in FControl.ComponentState then begin
    Result := FControl.FLib;
  end else begin
    Flielib := nill;
    if not(csDesigning in FControl.ComponentState) then begin
      if FControl.FImages <> nil then begin
        if g_LibClientList.Count > 0 then begin
          for I := 0 to g_LibClientList.Count - 1 do begin
            ClientLib := TWMImages(g_LibClientList.Items[i]);
            if ClientLib = FControl.FImages then begin
              case i of
                0: Flielib := Prguse_Pak;
                1: Flielib := Prguse_16_Pak;
                42: Flielib := Prguse;
                43: Flielib := Prguse2;
                44: Flielib := Prguse3;
                47: Flielib := ui1;
                49: Flielib := ui3;
                51: Flielib := ui_common;
                52: Flielib := ui_n;
                54: Flielib := ChrSel;
                55: Flielib := nselect;
              end;
              Break;
            end;
          end;
        end;
      end;
      Result := Flielib;
    end;
  end;
end;

function TCustomDXPropertites.GetMouseThrough: Boolean;
begin
  result := FControl.MouseThrough;
end;

function TCustomDXPropertites.GetOffsetX: Integer;
begin
  Result := 0;
  if FControl is TDAniButton then begin
    Result := TDAniButton(FControl).FOffsetX;
  end else
  if FControl is TDImageBar then begin
    Result := TDImageBar(FControl).FOffsetX;
  end;
end;

function TCustomDXPropertites.GetOffsetY: Integer;
begin
  Result := 0;
  if FControl is TDAniButton then begin
    Result := TDAniButton(FControl).FOffsetY;
  end else
  if FControl is TDImageBar then begin
    Result := TDImageBar(FControl).FOffsetY;
  end;
end;

function TCustomDXPropertites.GetAniLoop: Boolean;
begin
  Result := false;
  if FControl is TDAniButton then
    Result := TDAniButton(FControl).FAniLoop;
end;

function TCustomDXPropertites.GetClipBarType: TClipBarType;
begin
  result := ctNone;
  if FControl is TDImageBar then begin
    result := TDImageBar(FControl).FClipType;
  end;
end;

function TCustomDXPropertites.GetDrawBarMode: TDrawBarMode;
begin
  result := dbmNone;
  if FControl is TDImageBar then begin
    result := TDImageBar(FControl).DrawBarMode;
  end;
end;

function TCustomDXPropertites.GetDrawDirection: TDrawDirection;
begin
  result := dbdLeft;
  if FControl is TDImageBar then begin
    result := TDImageBar(FControl).DrawDirection;
  end;
end;

function TCustomDXPropertites.GetDrawMode: TDrawMode;
begin
  result := FControl.FDrawMode;
end;

function TCustomDXPropertites.GetDXImage: TDXImageProperty;
begin
  result := FControl.FDXImageLib;
end;

function TCustomDXPropertites.GetEscExit: Boolean;
begin
  result := false;
  if FControl is TDWindow then
    result := TDWindow(FControl).FEscClose;
end;

function TCustomDXPropertites.GetFloating: Boolean;
begin
  result := false;
  if FControl is TDWindow then
    result := TDWindow(FControl).FFloating;
end;

function TCustomDXPropertites.GetVisable: Boolean;
begin
  result := FControl.Visible;
end;

procedure TCustomDXPropertites.SetVisable(Value: Boolean);
begin
//  if UILoading and (FControl.IsCustomUI) then
//    Bo := false;

  FControl.Visible := Value;
end;

{ TDAniButton }

constructor TDAniButton.Create(aowner: TComponent);
begin
  CreatePropertites;
  inherited Create(aowner);
  FAniCount := 1;            //播放图片数量
  FAniInterval := 100;       //绘制间隔
  FAniLoop := False;          //是否循环
  FOffsetX := 0;
  FOffsetY := 0;
  FDrawMode := dmDefault;    //绘制模式
  FStart := False;           //是否开始绘制
  FFrameIndex := 0;
  FChangeFrameTime := GetTickCount;
  FMouseThrough := True;
end;

procedure TDAniButton.CreatePropertites;
begin
  FPropertites := TDXAniButtonPropertites.Create(Self);
  FDXImageLib := TDXAniButtonImageProperty.Create(FPropertites);
end;

procedure TDAniButton.DirectPaint(DSurface: TDXTexture);
var
  d: TDXTexture;
  nIndex, nPx, nPy : Integer;

begin
  if Assigned(FImages) then begin
    if (FImageIndex >= 0) and (FAniCount > 0) and FStart then begin
      FAniInterval := Max(10, FAniInterval);
      FAniCount := Max(1, FAniCount);

      //图片IDX
      nIndex := (GetTickCount - FChangeFrameTime) div FAniInterval mod FAniCount;

      //记录当前帧
      FFrameIndex := nIndex;

      d := FImages.GetCachedImage(FImageIndex + nIndex, nPx, nPy);
      nPx := nPx + FOffsetX;
      nPy := nPy + FOffsetY;

      if d <> nil then begin
        dSurface.Draw(SurfaceX(Left) + nPx, SurfaceY(Top) + nPy, d.ClientRect, d, FDrawMode);
      end;
      //触发绘制结束事件
      if ((FFrameIndex + 1) >= FAniCount) and (not FAniLoop) then begin
        Over();
      end;
    end;
  end;

  if g_TranFrame then
    g_DXCanvas.RoundRect(SurfaceX(Left), SurfaceY(Top), SurfaceX(Left + Width), SurfaceY(Top + Height), clLime);

  if g_DragMode and (SeletedControl = Self) then
    g_DXCanvas.RoundRect(SurfaceX(Left), SurfaceY(Top), SurfaceX(Left + Width), SurfaceY(Top + Height), clRed);
end;

procedure TDAniButton.Start;
begin
  FVisible := True;
  FFrameIndex := 0;
  FStart := True;
  FChangeFrameTime := GetTickCount();

  //触发开始绘制事件
  if Assigned(OnAniDirectPaintBegin) and (not FAniLoop) then
    OnAniDirectPaintBegin(Self);
end;

procedure TDAniButton.Reset;
begin
  FVisible := True;
  FFrameIndex := 0;
  FStart := True;
  FChangeFrameTime := GetTickCount();

  //重置开始绘制事件
  if Assigned(OnAniDirectPaintReset) and (not FAniLoop) then
    OnAniDirectPaintReset(Self);
end;

procedure TDAniButton.Over();
begin
  FVisible := False;
  FFrameIndex := 0;
  FStart := False;
  FChangeFrameTime := GetTickCount();
  //绘制结束事件
  if Assigned(OnAniDirectPaintEnd) and (not FAniLoop) then
    OnAniDirectPaintEnd(Self);
end;

{ TDImageBar }

constructor TDImageBar.Create(aowner: TComponent);
begin
  CreatePropertites;
  inherited Create(aowner);
  FDrawMode := dmDefault;
  FDrawBarMode := dbmNone;
  FClipType := ctNone;
  FDrawDirection := dbdLeft;

  FAniCount := 1;            //播放图片数量
  FAniInterval := 100;       //绘制间隔
  FOffsetX := 0;
  FOffsetY := 0;
  FChangeFrameTime := GetTickCount;
  FMouseThrough := True;
end;

procedure TDImageBar.CreatePropertites;
begin
  FPropertites := TDXWindowImageBarPropertites.Create(Self);
  FDXImageLib := TDXWindowImageBarProperty.Create(FPropertites);
end;

procedure TDImageBar.DirectPaint(DSurface: TDXTexture);
var
  ax, ay, nPx, nPy: Integer;
  d: TDXTexture;
  rc: TRect;
  nMinValue, nMaxValue: Int64;
begin
  nMinValue := 0;
  nMaxValue := 0;

  if FClipType <> ctDynamicValue then
  begin
    if Assigned(GetClipValueProc) then
      GetClipValueProc(FClipType, nMinValue, nMaxValue);
  end else begin
    //自定义动态剪切
    //nMaxValue := 100;
    //nMinValue := Min(Trunc(100 * FPropertites.DynamicClipValue), 100);
  end;

  //绘制图片剪切开始
  if Assigned(FImages) then begin
    ax := SurfaceX(Left);
    ay := SurfaceY(Top);

    FAniInterval := Max(10, FAniInterval);
    FAniCount := Max(1, FAniCount);

    d := FImages.GetCachedImage(FImageIndex + Integer((GetTickCount - FChangeFrameTime) div FAniInterval mod FAniCount), nPx, nPy);
    nPx := nPx + FOffsetX;
    nPy := nPy + FOffsetY;


    if d <> nil then begin
      if FClipType = ctNone then begin
        DSurface.Draw(ax + nPx, ay + nPy, d.ClientRect, d, FDrawMode);
      end else begin
        if (nMinValue > 0) and (nMaxValue > 0) then begin
          case FDrawDirection of
            dbdLeft: begin   //左向右剪切
              rc := d.ClientRect;
              case FDrawBarMode of
                dbmNone: begin //全部绘制
                  rc.Left := Max(0, Round(rc.Right / nMaxValue * (nMaxValue - nMinValue)));
                end;
                dbmLeft: begin //左半
                  rc.Right := d.ClientRect.Right div 2;
                  rc.Left := Max(0, Round(rc.Right / nMaxValue * (nMaxValue - nMinValue)));
                end;
                dbmRight: begin //右半
                  rc.Left := Max(rc.Right div 2, (d.Width div 2) + Round((rc.Right div 2) / nMaxValue * (nMaxValue - nMinValue)));
                end;
              end;
              dsurface.Draw(ax + nPx + rc.Left, ay + nPy, rc, d, FDrawMode);
            end;
            dbdRight: begin  //右向左剪切
              rc := d.ClientRect;
              case FDrawBarMode of
                dbmNone: begin //全部绘制
                  rc.Right := Min(d.Width - Round(rc.Right / nMaxValue * (nMaxValue - nMinValue)), rc.Right);
                  dsurface.Draw(ax + nPx, ay + nPy, rc, d, FDrawMode);
                end;
                dbmLeft: begin //左半
                  rc.Right := Min((d.Width div 2) - Round((rc.Right div 2) / nMaxValue * (nMaxValue - nMinValue)), rc.Right div 2);
                  dsurface.Draw(ax + nPx, ay + nPy, rc, d, FDrawMode);
                end;
                dbmRight: begin //右半
                  rc.Left := d.ClientRect.Right div 2;
                  rc.Right := Min(d.Width - Round((rc.Right div 2) / nMaxValue * (nMaxValue - nMinValue)), rc.Right);
                  dsurface.Draw(ax + nPx + rc.Left, ay + nPy, rc, d, FDrawMode);
                end;
              end;
            end;
            dbdTop: begin    //上向下剪切
              rc := d.ClientRect;
              case FDrawBarMode of
                dbmNone: begin //全部绘制
                  rc.Top := Round(rc.Bottom / nMaxValue * (nMaxValue - nMinValue));
                  dsurface.Draw(ax + nPx, ay + nPy + rc.Top, rc, d, FDrawMode);
                end;
                dbmLeft: begin //左半
                  rc.Right := d.ClientRect.Right div 2;
                  rc.Top := Round(rc.Bottom / nMaxValue * (nMaxValue - nMinValue));
                  dsurface.Draw(ax + nPx, ay + nPy + rc.Top, rc, d, FDrawMode);
                end;
                dbmRight: begin //右半
                  rc.Left := d.ClientRect.Right div 2;
                  rc.Right := d.ClientRect.Right;
                  rc.Top := Round(rc.Bottom / nMaxValue * (nMaxValue - nMinValue));
                  dsurface.Draw(ax + nPx + rc.Left, ay + nPy + rc.Top, rc, d, FDrawMode);
                end;
              end;
            end;
            dbdBottom: begin //下向上剪切
              rc := d.ClientRect;
              case FDrawBarMode of
                dbmNone: begin //全部绘制
                  rc.Bottom := Min(d.Height - Round(rc.Bottom / nMaxValue * (nMaxValue - nMinValue)), rc.Bottom);
                  dsurface.Draw(ax + nPx, ay + nPy, rc, d, FDrawMode);
                end;
                dbmLeft: begin //左半
                  rc.Right := d.ClientRect.Right div 2;
                  rc.Bottom := Min(d.Height - Round(rc.Bottom / nMaxValue * (nMaxValue - nMinValue)), rc.Bottom);
                  dsurface.Draw(ax + nPx, ay + nPy, rc, d, FDrawMode);
                end;
                dbmRight: begin //右半
                  rc.Left := d.ClientRect.Right div 2;
                  rc.Right := d.ClientRect.Right;
                  rc.Bottom := Min(d.Height - Round(rc.Bottom / nMaxValue * (nMaxValue - nMinValue)), rc.Bottom);
                  dsurface.Draw(ax + nPx + rc.Left, ay + nPy, rc, d, FDrawMode);
                end;
              end;
            end;
          end;
        end;
      end;
    end;
  end;

  if g_TranFrame then
    g_DXCanvas.RoundRect(SurfaceX(Left), SurfaceY(Top), SurfaceX(Left + Width), SurfaceY(Top + Height), clLime);

  if g_DragMode and (SeletedControl = Self) then
    g_DXCanvas.RoundRect(SurfaceX(Left), SurfaceY(Top), SurfaceX(Left + Width), SurfaceY(Top + Height), clRed);
end;

{ TDCustomEdit }

constructor TDCustomEdit.Create(AOwner: TComponent);
begin
  inherited;
  FEditClass := deNone;
  FPasswordChar := #0;
end;

procedure TDCustomEdit.Enter;
begin
  inherited;
  if (FPasswordChar <> #0) or (FEditClass = deInteger) or (FEditClass = deMonoCase) then begin
    if ImmIsIME(GetKeyboardLayout(0)) then begin
      FrmShowIME := True;
      ImmSimulateHotKey(MainWinHandle, IME_CHotKey_IME_NonIME_Toggle);
    end;
    FrmShowIME := False;
  end else begin
    FrmShowIME := True;
    if HklKeyboardLayout <> 0 then
      ActivateKeyboardLayout(HklKeyboardLayout, KLF_ACTIVATE);
    FrmIMEX := Left + 20;
    FrmIMEY := Top;
  end;
end;

procedure TDCustomEdit.IsVisible(flag: Boolean);
begin
  inherited;
  if (not flag) and (KeyControl = Self) then begin
    KeyControl.Leave;
    KeyControl := nil;
  end;
end;

procedure TDCustomEdit.Leave;
begin
  inherited;
  if not ((FPasswordChar <> #0) or (FEditClass = deInteger) or (FEditClass = deMonoCase)) then begin
    HklKeyboardLayout := GetKeyboardLayout(0);
  end;
  if ImmIsIME(GetKeyboardLayout(0)) then begin
    FrmShowIME := True;
    ImmSimulateHotKey(MainWinHandle, IME_CHotKey_IME_NonIME_Toggle);
  end;
  FrmShowIME := False;
end;


{ TDEdit }

function TDEdit.ClearKey: Boolean;
begin
  Result := False;
  if (FStartX > -1) and (FStopX > -1) and (FStartX <> FStopX) then begin
    if FStartX > FStopX then begin
      Delete(FEditString, FStopX, FStartX - FStopX);
      FCaretPos := FStopX;
    end
    else begin
      Delete(FEditString, FStartX, FStopX - FStartX);
      FCaretPos := FStartX;
    end;
    if FCaretPos < FCaretStart then
      FCaretStart := FCaretPos;
    FStartX := -1;
    FStopX := -1;
    FCursor := deLeft;
    Result := True;
  end;
  FStartX := -1;
  FStopX := -1;
end;

constructor TDEdit.Create(AOwner: TComponent);
begin
  CreatePropertites;
  inherited Create(aowner);
  FOnChange := nil;

  FKeyFocus := True;
  FCaretShowTime := GetTickCount;
  FrameColor := clSilver;
  FMaxLength := 0;
  FInputStr := '';
  bDoubleByte := False;
  KeyByteCount := 0;
  FCaretPos := 1;
  FCaretStart := 1;
  FCaretStop := 1;
  FCursor := deLeft;
  FStartX := -1;
  FStopX := -1;
  FIndent := 2;
  FTransparent := True;
  FCloseSpace := False;
  Color := clBlack;

  FDefColor := clWhite;
end;

procedure TDEdit.CreatePropertites;
begin
  FPropertites := TDXEditPropertites.Create(Self);
  FDXImageLib := TDXEditProperty.Create(FPropertites);
end;

destructor TDEdit.Destroy;
begin
  inherited;
end;

procedure TDEdit.DirectPaint(dsurface: TDXTexture);
var
  dc, fDc: TRect;
  nLeft: integer;

  ShowStr: string;
  StopX, StartX, CaretIdx: Integer;
  boLeft: byte;
begin
  dc.Left := SurfaceX(Left);
  dc.Top := SurfaceY(Top);
  dc.Right := SurfaceX(left + Width);
  dc.Bottom := SurfaceY(top + Height);

  //不是透明色绘制背景
  if not FTransparent then begin
    g_DXCanvas.FillRect(dc.Left, dc.Top, Width, Height, $FF000000 or LongWord(Color));
    g_DXCanvas.RoundRect(dc.Left, dc.Top, dc.Right, dc.Bottom, FrameColor);
  end;

  //光标闪烁速度
  if (GetTickCount - FCaretShowTime) > 500 then begin
    FCaretShowTime := GetTickCount;
    FCaretShow := not FCaretShow;
  end;
  nLeft := 0;
  boLeft := 0;
  with g_DXCanvas do begin
    if FEditString <> '' then begin
      if (FStartX <> FStopX) and (FStopX >= 0) and (FStartX >= 0) then begin
        StopX := FStopX;
        StartX := FStartX;
        CaretIdx := FCaretStart;

        if Height < 14 then begin
          dc.Top := SurfaceY(Top);
          dc.Bottom := SurfaceY(top + Height);
        end
        else begin
          dc.Top := SurfaceY(Top + (Height - 14) div 2);
          dc.Bottom := SurfaceY(top + Height - (Height - 14) div 2);
        end;
        if StartX > StopX then begin
          StartX := FStopX;
          StopX := FStartX;
          boLeft := 1;
        end;
        if StartX < CaretIdx then begin
          dc.Left := SurfaceX(Left + FIndent);
          ShowStr := Copy(FEditString, CaretIdx, StopX - CaretIdx);
          dc.Right := dc.Left + TextWidth(ShowStr);
          boLeft := 2;
        end
        else begin
          if FCaretStart > 0 then begin
            ShowStr := Copy(FEditString, CaretIdx, StartX - CaretIdx);
            dc.Left := SurfaceX(Left + FIndent) + TextWidth(ShowStr);
          end
          else begin
            ShowStr := Copy(FEditString, CaretIdx, StartX - CaretIdx);
            dc.Left := SurfaceX(Left + FIndent) + TextWidth(ShowStr);
          end;
          ShowStr := Copy(FEditString, StartX, StopX - StartX);
          dc.Right := dc.Left + TextWidth(ShowStr);
        end;
        dc.Right := Min(dc.Right, SurfaceX(Left + Width - FIndent * 2));
        FillRect(dc, cColor4($C9C66931), fxBlend);
        fDc := dc;
      end;

      dc.Left := SurfaceX(Left + FIndent);
      dc.Top := SurfaceY(Top);
      dc.Right := SurfaceX(left + Width - FIndent * 2);
      dc.Bottom := SurfaceY(top + Height);
      if FCursor = deLeft then begin
        ShowStr := Copy(FEditString, FCaretStart, Length(FEditString));
        ShowStr := GetPasswordstr(ShowStr);

        TextRect(dc, ShowStr, FDefColor, [tfSingleLine, tfleft, tfVerticalCenter]);
        nLeft := Min(TextWidth(Copy(FEditString, FCaretStart, FCaretPos - FCaretStart)), Width - FIndent * 2);
        if FDefColor <> clWhite then begin
          ShowStr := GetPasswordstr(GetCopy);
          if ShowStr <> '' then begin
            if boLeft = 1 then
              TextRect(Fdc, ShowStr, FDefColor, [tfSingleLine, tfleft, tfVerticalCenter])
            else
              TextRect(Fdc, ShowStr, FDefColor, [tfSingleLine, tfleft, tfVerticalCenter]);
          end;
        end;
      end
      else begin
        ShowStr := copy(FEditString, 1, FCaretStop - 1);
        ShowStr := GetPasswordstr(ShowStr);
        TextRect(dc, ShowStr, FDefColor, [tfSingleLine, tfleft, tfVerticalCenter]);
        ShowStr := Copy(FEditString, FCaretPos, FCaretStop - FCaretPos);
        nLeft := Min(Width - FIndent * 3 - TextWidth(ShowStr), Width - FIndent * 3);
        if FDefColor <> clWhite then begin
          ShowStr := GetPasswordstr(GetCopy);
          if ShowStr <> '' then begin
            TextRect(Fdc, ShowStr, FDefColor, [tfSingleLine, tfleft, tfVerticalCenter]);
          end;
        end;
      end;
    end;

    if FCaretShow and (KeyControl = Self) then begin
      FrmIMEX := SurfaceX(nLeft + FIndent + left);
      if Height < 16 then begin
        RoundRect(SurfaceX(nLeft + FIndent + left), SurfaceY(Top),
          SurfaceX(left + FIndent + 1 + nLeft), SurfaceY(top + Height), clWhite);
        FrmIMEY := SurfaceY(Top);
      end
      else begin
        RoundRect(SurfaceX(nLeft + FIndent + left), SurfaceY(Top + 1),
          SurfaceX(left + FIndent + 1 + nLeft), SurfaceY(top + (Height - 2)), clWhite);
        FrmIMEY := SurfaceY(Top + 1);
      end;
    end;
  end;

  if g_TranFrame then
    g_DXCanvas.RoundRect(SurfaceX(Left), SurfaceY(Top), SurfaceX(Left + Width), SurfaceY(Top + Height), clLime);

  if g_DragMode and (SeletedControl = Self) then
    g_DXCanvas.RoundRect(SurfaceX(Left), SurfaceY(Top), SurfaceX(Left + Width), SurfaceY(Top + Height), clRed);
end;

procedure TDEdit.Enter;
begin

  inherited;
end;

function TDEdit.GetCopy: string;
begin
  Result := '';
  if FStartX > FStopX then begin
    Result := Copy(FEditString, FStopX, FStartX - FStopX);
  end
  else begin
    Result := Copy(FEditString, FStartX, FStopX - FStartX);
  end;
end;

function TDEdit.GetPasswordstr(str: string): string;
var
  i: Integer;
begin
  Result := str;
  if str = '' then
    Exit;
  if PasswordChar <> #0 then begin
    Result := '';
    for I := 1 to Length(str) do
      Result := Result + PasswordChar;
  end;
end;

function TDEdit.GetText: string;
begin
  Result := string(FEditString);
end;

function TDEdit.GetValue: Integer;
begin
  Result := StrToIntDef(string(FEditString), 0);
end;

function TDEdit.KeyDown(var Key: Word; Shift: TShiftState): Boolean;
var
  i: integer;
  Clipboard: TClipboard;
  AddTx: string;
  nKey: Char;
  boChange: Boolean;
begin
  Result := FALSE;

  if (KeyControl = self) then begin
    KeyDownControl := Self;
    if Assigned(FOnKeyDown) then
      FOnKeyDown(self, Key, Shift);
    if Key = 0 then
      exit;

    if (ssCtrl in Shift) and (not Downed) and (Key = Word('X')) then begin
      if (FPasswordChar = #0) then begin
        if (FStartX > -1) and (FStopX > -1) and (FStartX <> FStopX) then begin
          Clipboard := TClipboard.Create;

          Clipboard.AsText := GetCopy;
          Clipboard.Free;
          ClearKey();
          TextChange();
        end;
      end;
      Key := 0;
      Result := True;
      Exit;
    end
    else if (ssCtrl in Shift) and (not Downed) and (Key = Word('C')) then begin
      if (FPasswordChar = #0) then begin
        if (FStartX > -1) and (FStopX > -1) and (FStartX <> FStopX) then begin
          Clipboard := TClipboard.Create;
          Clipboard.AsText := GetCopy;
          Clipboard.Free;
        end;
      end;
      Key := 0;
      Result := True;
      Exit;
    end
    else if (ssCtrl in Shift) and (not Downed) and (Key = Word('V')) then begin
      if (FPasswordChar = #0) then begin
        ClearKey();
        Clipboard := TClipboard.Create;
        AddTx := Clipboard.AsText;
        for I := 1 to Length(AddTx) do begin
          nKey := AddTx[i];
          if (nKey = #13) or (nKey = #10) then
            Continue;
          KeyPress(nKey);
        end;

        Clipboard.Free;
      end;
      Key := 0;
      Result := True;
      Exit;
    end
    else if (ssCtrl in Shift) and (not Downed) and (Key = Word('A')) then begin
      SetFocus;
      Key := 0;
      Result := True;
      Exit;
    end
    else if (ssShift in Shift) and (not Downed) then begin
      KeyDowned := True;

      if FStartX < 0 then
        FStartX := FCaretPos;
    end
    else
      KeyDowned := False;
    case Key of
      VK_RIGHT: begin
          if not Downed then
            SetCursorPos(deRight);
          if (ssShift in Shift) then begin
            FCursor := deLeft;
            FStopX := FCaretPos
          end
          else begin
            FStartX := -1;
            FStopX := -1;
            KeyDowned := False;
          end;
          Key := 0;
          Result := TRUE;
        end;
      VK_LEFT: begin
          if not Downed then
            SetCursorPos(deLeft);
          if (ssShift in Shift) then begin
            FCursor := deLeft;
            FStopX := FCaretPos
          end
          else begin
            FStartX := -1;
            FStopX := -1;
            KeyDowned := False;
          end;
          Key := 0;
          Result := TRUE;
        end;
      VK_DELETE: begin
          boChange := ClearKey;
          if (not FReadOnly) and (not Downed) and (not KeyDowned) and (not
            boChange) then begin
            Delete(FEditString, FCaretPos, 1);
            FCaretPos := Min(FCaretPos, Length(FEditString) + 1);
            FCursor := deLeft;
            TextChange();
          end
          else if boChange then
            TextChange();
          Key := 0;
          Result := TRUE;
        end;
    end;

  end;
end;

function TDEdit.KeyPress(var Key: Char): Boolean;
var
  boChange: Boolean;
begin
  Result := False;
  if (KeyControl = Self) then begin
    Result := True;
    if (not Downed) and (not FReadOnly) then begin
      if Assigned(FOnKeyPress) then
        FOnKeyPress(self, Key);
      if Key = #0 then
        Exit;
      case Key of
        Char(VK_BACK): begin
            boChange := ClearKey;
            if (FEditString <> '') and (not boChange) then begin
              FCursor := deleft;
              Delete(FEditString, FCaretPos - 1, 1);
              SetCursorPos(deLeft);
              TextChange();
            end
            else if boChange then
              TextChange();
          end;
      else
        begin
          if (FEditClass = deInteger) and (not IsIntegerChars(Key)) then begin
            Key := #0;
            Exit;
          end
          else if ((FEditClass = deMonoCase) or (FPasswordChar <> #0)) and (not IsEnglishChars(Key)) then begin
            Key := #0;
            Exit;
          end;
          if (FEditClass = deEnglishAndInt) and (not IsStandardChars(Key)) then begin
            key := #0;
            Exit;
          end;
          if (FEditClass = deCDKey) and (not IsCDKeyChars(Key)) then begin
            key := #0;
            Exit;
          end;

          //UniCode范围限制
          if IsAllChars(Key) then
          begin
            if IsMBCSChar(Key){IsDBCSLeadByte(Ord(Key))} or bDoubleByte then
            begin
              bDoubleByte := True; //双字节
              Inc(KeyByteCount);
              FInputStr := FInputStr + key;
            end;

            if not bDoubleByte then
            begin //单字节
              if FCloseSpace and (Key = #$0020) then begin
                Key := #0;
                exit;
              end;
              if (FEditClass = deStandard) and (not IsStandardChars(Key)) then
              begin
                Key := #0;
                exit;
              end;

              ClearKey;
              if (MaxLength > 0) and (Length(FEditString) >= MaxLength) then
              begin
                Key := #0;
                exit;
              end;
              if FCaretPos <= Length(FEditString) then
              begin
                Insert(Key, FEditString, FCaretPos);
                SetCursorPosEx(1);
              end
              else begin
                FEditString := FEditString + Key;
                SetCursorPos(deRight);
              end;
              Key := #0;
              TextChange();
            end
            else if KeyByteCount >= 2 then begin
              if length(FInputStr) <> 2 then
              begin
                bDoubleByte := false;
                KeyByteCount := 0;
                FInputStr := '';
                Key := #0;
                Exit;
              end;
              if (FEditClass = deStandard) and (FInputStr = '') then
              begin
                bDoubleByte := false;
                KeyByteCount := 0;
                FInputStr := '';
                Key := #0;
                Exit;
              end;
              if (FEditClass = deChinese) and (FInputStr = '') then
              begin
                bDoubleByte := false;
                KeyByteCount := 0;
                FInputStr := '';
                Key := #0;
                Exit;
              end;
              ClearKey;
              if (MaxLength > 0) and (Length(FEditString) >= (MaxLength - 1)) then
              begin
                bDoubleByte := false;
                KeyByteCount := 0;
                FInputStr := '';
                Key := #0;
                Exit;
              end;
              if FCaretPos <= Length(FEditString) then
              begin
                Insert(FInputStr, FEditString, FCaretPos);
                SetCursorPosEx(1);
              end
              else begin
                FEditString := FEditString + FInputStr;
                SetCursorPos(deRight);
              end;
              TextChange();
              bDoubleByte := false;
              KeyByteCount := 0;
              FInputStr := '';
              Key := #0;
            end;
          end;
        end;
      end;
    end;
    Key := #0;
  end;
end;

function TDEdit.KeyUp(var Key: Word; Shift: TShiftState): Boolean;
begin
  Result := FALSE;
  if (KeyControl = self) then begin
    if (Key = VK_SHIFT) then begin
      KeyDowned := False;
      if FStopX = -1 then
        FStartX := -1;
    end;
    if Assigned(FOnKeyUp) then
      FOnKeyUp(self, Key, Shift);
    Key := 0;
    Result := TRUE;
  end;
end;

procedure TDEdit.Leave;
begin
  FStartX := -1;
  FStopX := -1;
  inherited;
end;

function TDEdit.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean;
begin
  Result := False;
  if inherited MouseDown(Button, Shift, X, Y) then begin
    if (not Background) and (MouseCaptureControl = nil) then begin
      KeyDowned := False;
      if mbLeft = Button then begin
        FStartX := -1;
        FStopX := -1;
        if (FocusedControl = self) then begin
          MoveCaret(X - left, Y - top);
        end;
        Downed := True;
      end;
      SetDCapture(self);
      SetSelectedControl(Self);
    end;
    Result := True;
  end;
end;

function TDEdit.MouseMove(Shift: TShiftState; X, Y: Integer): Boolean;
begin
  Result := inherited MouseMove(Shift, X, Y);
  if Result and (MouseCaptureControl = self) then begin
    if Downed and (not KeyDowned) then
      MoveCaret(X - left, Y - top);
  end;
end;

function TDEdit.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer): Boolean;
begin
  Result := FALSE;
  Downed := False;

  if inherited MouseUp(Button, Shift, X, Y) then begin
    ReleaseDCapture;
    if not Background then begin
      if InRange(X, Y, Shift) then begin
        if Assigned(FOnClick) then
          FOnClick(self, X, Y);
      end;
    end;
    Result := TRUE;
    exit;
  end
  else begin
    ReleaseDCapture;
  end;
end;

procedure TDEdit.MoveCaret(X, Y: Integer);
var
  i: Integer;
  temstr: string;
begin
  FCursor := deLeft;
  if Length(FEditString) > 0 then begin
    if (X <= g_DXCanvas.TextWidth('A')) and (FCaretStart > 1) then
      Dec(FCaretStart);
    for i := FCaretStart to Length(FEditString) do begin
      temstr := Copy(FEditString, FCaretStart, I - FCaretStart + 1);

      if g_DXCanvas.TextWidth(temstr) > X then begin
        while I <> FCaretPos do begin
          if I > FCaretPos then begin
            SetCursorPos(deRight)
          end
          else begin
            SetCursorPos(deLeft);
          end;
        end;
        if Downed or KeyDowned then
          FStopX := FCaretPos
        else
          FStartX := FCaretPos;
        exit;
      end;
    end;
    while (Length(FEditString) + 1) <> FCaretPos do begin
      if (Length(FEditString) + 1) > FCaretPos then begin
        SetCursorPos(deRight)
      end
      else begin
        SetCursorPos(deLeft);
      end;
    end;
    if Downed or KeyDowned then
      FStopX := FCaretPos
    else
      FStartX := FCaretPos;
  end;
end;

function TDEdit.Selected: Boolean;
begin
  Result := False;
  if (FStartX > -1) and (FStopX > -1) and (FStartX <> FStopX) then
    Result := True;

end;

procedure TDEdit.SetCursorPos(cCursor: TCursor);
var
  tempstr: WideString;
begin
  if cCursor = deRight then begin
    Inc(FCaretPos);
    if FCaretPos > (Length(FEditString) + 1) then
      FCaretPos := (Length(FEditString) + 1);
    while True do begin
      tempstr := Copy(FEditString, FCaretStart, FCaretPos - FCaretStart);
      if (FCaretStart < FCaretPos) and (g_DXCanvas.TextWidth(tempstr) > (Width - FIndent * 2)) then begin
        FCursor := deRight;
        Inc(FCaretStart);
        FCaretStop := FCaretPos;
      end
      else if FCaretPos > FCaretStop then begin
        FCaretStop := FCaretPos;
      end
      else
        Break;
    end;
  end
  else begin
    if FCaretPos > 1 then
      Dec(FCaretPos);
    if (FCaretPos <= FCaretStart) and (FCaretStart > 1) then begin
      FCursor := deleft;
      Dec(FCaretStart);
      FCaretStop := FCaretPos;
    end;
  end;
end;

procedure TDEdit.SetCursorPosEx(nLen: Integer);
var
  tempstr: WideString;
begin
  FCursor := deLeft;
  Inc(FCaretPos, nLen);
  if FCaretPos > (Length(FEditString) + 1) then
    FCaretPos := (Length(FEditString) + 1);
  while True do begin
    tempstr := Copy(FEditString, FCaretStart, FCaretPos - FCaretStart);
    if (FCaretStart < FCaretPos) and (g_DXCanvas.TextWidth(tempstr) > (Width - FIndent * 2)) then begin
      FCursor := deRight;
      Inc(FCaretStart);
      FCaretStop := FCaretPos;
    end
    else if FCaretPos > FCaretStop then begin
      FCaretStop := FCaretPos;
    end
    else
      Break;
  end;
end;

procedure TDEdit.SetFocus;
begin
  inherited;
  if FEditString <> '' then begin
    FStartX := 1;
    FStopX := Length(FEditString) + 1;
  end;
end;

procedure TDEdit.SetText(Value: string);
var
  i: Integer;
  nKey: Char;
  OldKeyControl: TDControl;
  OldFOnChange: TOnClick;
  OldReadOnly: Boolean;
begin
  FEditString := '';
  FCursor := deLeft;
  FCaretStart := 1;
  FCaretStop := 1;
  FCaretPos := 1;
  FStartX := -1;
  OldKeyControl := KeyControl;
  KeyControl := Self;
  OldFOnChange := FOnChange;
  FOnChange := nil;
  OldReadOnly := ReadOnly;
  ReadOnly := False;
  try
    for I := 1 to Length(Value) do begin
      nKey := Value[i];
      KeyPress(nKey);
    end;
  finally
    KeyControl := OldKeyControl;
    FOnChange := OldFOnChange;
    ReadOnly := OldReadOnly;
  end;
end;

procedure TDEdit.SetValue(const Value: Integer);
begin
  SetText(IntToStr(Value));
end;

procedure TDEdit.TextChange;
begin
  if Assigned(FOnChange) then
    FOnChange(self);
end;

{ TDMemo }

function TDMemo.ClearKey: Boolean;
var
  nStartY, nStopY: Integer;
  nStartX, nStopX: Integer;
  TempStr: WideString;
  i: Integer;
begin
  Result := False;
  if FLines.Count > 0 then begin
    if (FCaretX <> FSCaretX) or (FSCaretY <> FCaretY) then begin

      if FSCaretY < 0 then
        FSCaretY := 0;
      if FSCaretY >= FLines.Count then
        FSCaretY := FLines.Count - 1;

      if FCaretY < 0 then
        FCaretY := 0;
      if FCaretY >= FLines.Count then
        FCaretY := FLines.Count - 1;

      if FSCaretY = FCaretY then begin
        if FSCaretX > FCaretX then begin
          nStartX := FCaretX;
          nStopX := FSCaretX;
        end
        else begin
          nStartX := FSCaretX;
          nStopX := FCaretX;
        end;

        TempStr := TDMemoStringList(FLines).Str[FCaretY];
        Delete(TempStr, nStartX + 1, nStopX - nStartX);
        TDMemoStringList(FLines).Str[FCaretY] := TempStr;
        RefListWidth(FCaretY, 0);
        FCaretX := nStartX;
        SetCaret(True);
        Result := True;
      end
      else begin
        if FSCaretY > FCaretY then begin
          nStartY := FCaretY;
          nStopY := FSCaretY;
          nStartX := FCaretX;
          nStopX := FSCaretX;
        end
        else begin
          nStartY := FSCaretY;
          nStopY := FCaretY;
          nStartX := FSCaretX;
          nStopX := FCaretX;
        end;
        TempStr := TDMemoStringList(FLines).Str[nStartY];
        Delete(TempStr, nStartX + 1, 255);
        TDMemoStringList(FLines).Str[nStartY] := TempStr;

        TempStr := TDMemoStringList(FLines).Str[nStopY];
        Delete(TempStr, 1, nStopX);
        TDMemoStringList(FLines).Str[nStartY] :=
          TDMemoStringList(FLines).Str[nStartY] + TempStr;
        FLines.Objects[nStartY] := FLines.Objects[nStopY];
        FLines.Delete(nStopY);
        if (nStopY - nStartY) > 1 then
          for i := nStopY - 1 downto nStartY + 1 do
            FLines.Delete(i);
        RefListWidth(nStartY, nStartX);
        SetCaret(True);
        Result := True;
      end;
    end;
  end;
end;

constructor TDMemo.Create(AOwner: TComponent);
begin
  inherited;
  FKeyFocus := True;
  FCaretShowTime := GetTickCount;

  Downed := False;
  KeyDowned := False;

  FUpDown := nil;

  FTopIndex := 0;
  FCaretY := 0;
  FCaretX := 0;

  FSCaretX := 0;
  FSCaretY := 0;

  FInputStr := '';
  bDoubleByte := False;
  KeyByteCount := 0;

  FTransparent := False;

  FMaxLength := 0;

  FOnChange := nil;
  FReadOnly := False;
  FFrameColor := clBlack;
  Color := clBlack;

  FLines := TDMemoStringList.Create;
  TDMemoStringList(FLines).DMemo := Self;

  FMoveTick := GetTickCount;
end;

destructor TDMemo.Destroy;
begin
  FLines.Free;
  inherited;
end;

//私聊框文字支持繁体函数
procedure TDMemo.DirectPaint(dsurface: TDXTexture);
var
  dc: TRect;
  nShowCount, i: Integer;
  ax, ay: Integer;
  TempStr: string;
  nStartY, nStopY: Integer;
  nStartX, nStopX: Integer;
  addax: Integer;
begin
  dc.Left := SurfaceX(Left);
  dc.Top := SurfaceY(Top);
  dc.Right := SurfaceX(left + Width);
  dc.Bottom := SurfaceY(top + Height);

  if not FTransparent then begin
    g_DXCanvas.FillRect(dc, cColor4(LongWord(Color) or $FF000000), fxBlend);
    g_DXCanvas.RoundRect(dc.Left, dc.Top, dc.Right, dc.Bottom, FrameColor);

  end;
  if (GetTickCount - FCaretShowTime) > 500 then begin
    FCaretShowTime := GetTickCount;
    FCaretShow := not FCaretShow;
  end;

  nShowCount := (Height - 1) div 14;
  if (FTopIndex + nShowCount - 1) > Lines.Count then begin
    FTopIndex := Max(Lines.Count - nShowCount + 1, 0);
  end;
  if (FCaretY >= Lines.Count) then
    FCaretY := Max(Lines.Count - 1, 0);
  if FCaretY < 0 then begin
    FTopIndex := 0;
    FCaretY := 0;
  end;

  if Lines.Count > nShowCount then begin
    if FUpDown <> nil then begin
      if not FUpDown.Visible then
        FUpDown.Visible := True;
      FUpDown.MaxPosition := Lines.Count - nShowCount;
      FUpDown.Position := FTopIndex;
    end;
  end
  else begin
    if FUpDown <> nil then begin
      if FUpDown.Visible then
        FUpDown.Visible := False;
      FTopIndex := 0;
    end;
  end;

  if FSCaretY > FCaretY then begin
    nStartY := FCaretY;
    nStopY := FSCaretY;
    nStartX := FCaretX;
    nStopX := FSCaretX;
  end
  else begin
    nStartY := FSCaretY;
    nStopY := FCaretY;
    nStartX := FSCaretX;
    nStopX := FCaretX;
  end;
  if FSCaretY = FCaretY then begin
    if FSCaretX > FCaretX then begin
      nStartX := FCaretX;
      nStopX := FSCaretX;
    end
    else if FSCaretX < FCaretX then begin
      nStartX := FSCaretX;
      nStopX := FCaretX;
    end
    else begin
      nStartX := -1;
    end;
  end;
  ax := SurfaceX(Left) + 2;
  ay := SurfaceY(Top) + 2;
  with g_DXCanvas do begin

    for i := FTopIndex to (FTopIndex + nShowCount - 1) do begin
      if i >= Lines.Count then
        Break;
      if nStartY <> nStopY then begin
        if i = nStartY then begin
          TempStr := Copy(WideString(Lines[i]), 1, nStartX);
          TextOut(ax, ay + (i - FTopIndex) * 14, TempStr, FDefColor);
          addax := TextWidth(TempStr);

          TempStr := Copy(WideString(Lines[i]), nStartX + 1, 255);

          FillRect(ax + addax, ay + (i - FTopIndex) * 14 - 1, TextWidth(TempStr), 16, $C9C66931);
          TextOut(ax + addax, ay + (i - FTopIndex) * 14, TempStr, FDefColor);

        end
        else if i = nStopY then begin

          TempStr := Copy(WideString(Lines[i]), 1, nStopX);
          addax := TextWidth(TempStr);

          FillRect(ax, ay + (i - FTopIndex) * 14 - 1, addax, 16, $C9C66931);
          TextOut(ax, ay + (i - FTopIndex) * 14, TempStr, FDefColor);

          TempStr := Copy(WideString(Lines[i]), nStopX + 1, 255);
          TextOut(ax + addax, ay + (i - FTopIndex) * 14, TempStr, FDefColor);
        end
        else if (i > nStartY) and (i < nStopY) then begin

          FillRect(ax, ay + (i - FTopIndex) * 14 - 1, TextWidth(Lines[i]), 16, $C9C66931);
          TextOut(ax, ay + (i - FTopIndex) * 14, Lines[i], FDefColor);

        end
        else
          TextOut(ax, ay + (i - FTopIndex) * 14, Lines[i], FDefColor);
      end
      else begin
        if (nStartX <> -1) and (i = FSCaretY) then begin
          TempStr := Copy(WideString(Lines[i]), 1, nStartX);
          TextOut(ax, ay + (i - FTopIndex) * 14, TempStr, FDefColor);
          addax := TextWidth(TempStr);

          TempStr := Copy(WideString(Lines[i]), nStartX + 1, nStopX - nStartX);

          FillRect(ax + addax, ay + (i - FTopIndex) * 14 - 1, TextWidth(TempStr), 16, $C9C66931);
          TextOut(ax + addax, ay + (i - FTopIndex) * 14, TempStr, FDefColor);
          addax := addax + TextWidth(TempStr);

          TempStr := Copy(WideString(Lines[i]), nStopX + 1, 255);
          TextOut(ax + addax, ay + (i - FTopIndex) * 14, TempStr, FDefColor);
        end
        else
          TextOut(ax, ay + (i - FTopIndex) * 14, Lines[i], FDefColor);
      end;
    end;
    if (FCaretY >= FTopIndex) and (FCaretY < (FTopIndex + nShowCount)) then begin
      ay := ay + (Max(FCaretY - FTopIndex, 0)) * 14;
      if FCaretY < Lines.Count then begin
        TempStr := LeftStr(WideString(Lines[FCaretY]), FCaretX);
        ax := ax + TextWidth(TempStr);
      end;
      if FCaretShow and (KeyControl = Self) then begin

        FrmIMEX := ax;
        FrmIMEY := ay;
        RoundRect(ax, ay, ax + 1, ay + 12, clWhite);
      end;
    end;

  end;
  for i := 0 to DControls.Count - 1 do begin
    if TDControl(DControls[i]).Visible then
      TDControl(DControls[i]).DirectPaint(dsurface);
  end;

  if g_TranFrame then
    g_DXCanvas.RoundRect(SurfaceX(Left), SurfaceY(Top), SurfaceX(Left + Width), SurfaceY(Top + Height), clLime);

  if g_DragMode and (SeletedControl = Self) then
    g_DXCanvas.RoundRect(SurfaceX(Left), SurfaceY(Top), SurfaceX(Left + Width), SurfaceY(Top + Height), clRed);
end;

procedure TDMemo.Enter;
begin
  inherited;
end;

function TDMemo.GetKey: string;
var
  nStartY, nStopY: Integer;
  nStartX, nStopX: Integer;
  TempStr: WideString;
  i: Integer;
begin
  Result := '';
  if FLines.Count > 0 then begin
    if (FCaretX <> FSCaretX) or (FSCaretY <> FCaretY) then begin

      if FSCaretY < 0 then
        FSCaretY := 0;
      if FSCaretY >= FLines.Count then
        FSCaretY := FLines.Count - 1;

      if FCaretY < 0 then
        FCaretY := 0;
      if FCaretY >= FLines.Count then
        FCaretY := FLines.Count - 1;

      if FSCaretY = FCaretY then begin
        if FSCaretX > FCaretX then begin
          nStartX := FCaretX;
          nStopX := FSCaretX;
        end
        else begin
          nStartX := FSCaretX;
          nStopX := FCaretX;
        end;
        TempStr := FLines[FCaretY];
        Result := Copy(TempStr, nStartX + 1, nStopX - nStartX);
      end
      else begin
        if FSCaretY > FCaretY then begin
          nStartY := FCaretY;
          nStopY := FSCaretY;
          nStartX := FCaretX;
          nStopX := FSCaretX;
        end
        else begin
          nStartY := FSCaretY;
          nStopY := FCaretY;
          nStartX := FSCaretX;
          nStopX := FCaretX;
        end;
        TempStr := FLines[nStartY];
        Result := Copy(TempStr, nStartX + 1, 255);
        if Integer(FLines.Objects[nStartY]) = 13 then
          Result := Result + #13#10;
        if (nStopY - nStartY) > 1 then
          for i := nStartY + 1 to nStopY - 1 do begin
            Result := Result + FLines[i];
            if Integer(FLines.Objects[i]) = 13 then
              Result := Result + #13#10;
          end;
        TempStr := FLines[nStopY];
        Result := Result + Copy(TempStr, 1, nStopX);
        if Integer(FLines.Objects[nStopY]) = 13 then
          Result := Result + #13#10;
      end;
    end;
  end;
end;

function TDMemo.GetText: string;
var
  P: PChar;
begin
  P := FLines.GetText;
  Result := P;
  StrDispose(P);
end;

procedure TDMemo.IsVisible(flag: Boolean);
begin
  inherited;
  if FUpDown <> nil then begin
    FUpDown.Visible := flag;
  end;
end;

procedure TDMemo.KeyCaret(Key: Word);
var
  TempStr: WideString;
  nShowCount: Integer;
begin
  if FLines.Count > 0 then begin
    if FCaretY < 0 then
      FCaretY := 0;
    if FCaretY >= FLines.Count then
      FCaretY := FLines.Count - 1;
    TempStr := TDMemoStringList(FLines).Str[FCaretY];
    case Key of
      VK_UP: begin
          if FCaretY > 0 then
            Dec(FCaretY);
        end;
      VK_DOWN: begin
          if FCaretY < (FLines.Count - 1) then
            Inc(FCaretY);
        end;
      VK_RIGHT: begin
          if FCaretX < Length(TempStr) then
            Inc(FCaretX)
          else begin
            if FCaretY < (FLines.Count - 1) then begin
              Inc(FCaretY);
              FCaretX := 0;
            end;
          end;
        end;
      VK_LEFT: begin
          if FCaretX > 0 then
            Dec(FCaretX)
          else begin
            if FCaretY > 0 then begin
              Dec(FCaretY);
              FCaretX :=
                Length(WideString(TDMemoStringList(FLines).Str[FCaretY]));
            end;
          end;
        end;
    end;
    nShowCount := (Height - 1) div 14;
    if FCaretY < FTopIndex then
      FTopIndex := FCaretY
    else begin
      if (FCaretY - FTopIndex) >= nShowCount then begin
        FTopIndex := Max(FCaretY - nShowCount + 1, 0);
      end;
    end;

    if not KeyDowned then
      SetCaret(False);
  end;
end;

function TDMemo.KeyDown(var Key: Word; Shift: TShiftState): Boolean;
var
  Clipboard: TClipboard;
  AddTx, Data: string;
  boAdd: Boolean;
  TempStr: WideString;
  nKey: Char;
  I: Integer;
begin
  Result := FALSE;

  if (KeyControl = self) then begin
    if not FReadOnly then
      KeyDownControl := Self;
    if Assigned(FOnKeyDown) then
      FOnKeyDown(self, Key, Shift);
    if Key = 0 then
      exit;
    if (ssCtrl in Shift) and (not Downed) and (Key = Word('A')) then begin
      if FLines.Count > 0 then begin
        FCaretY := FLines.Count - 1;
        FCaretX := Length(WideString(TDMemoStringList(FLines).Str[FCaretY]));
        SetCaret(True);
        FSCaretX := 0;
        FSCaretY := 0;
      end;
      Key := 0;
      Result := True;
      Exit;
    end
    else if (ssCtrl in Shift) and (not Downed) and (Key = Word('X')) then begin
      if not FReadOnly then begin
        AddTx := GetKey;
        if AddTx <> '' then begin
          Clipboard := TClipboard.Create;
          Clipboard.AsText := AddTx;
          Clipboard.Free;
          ClearKey();
          TextChange();
        end;
        Key := 0;
      end;
      Result := True;
      Exit;
    end
    else if (ssCtrl in Shift) and (not Downed) and (Key = Word('C')) then begin
      AddTx := GetKey;
      if AddTx <> '' then begin
        Clipboard := TClipboard.Create;
        Clipboard.AsText := AddTx;
        Clipboard.Free;
      end;
      Key := 0;
      Result := True;
      Exit;
    end
    else if (ssCtrl in Shift) and (not Downed) and (Key = Word('V')) then begin
      if not FReadOnly then begin
        ClearKey();

        Clipboard := TClipboard.Create;
        AddTx := Clipboard.AsText;
        boAdd := False;
        while True do begin
          if AddTx = '' then break;
          AddTx := GetValidStr3(AddTx, data, [#13]);
          if Data <> '' then begin
            data := AnsiReplaceText(data, #10, '');
            if (MaxLength > 0) and ((Length(GetText) + Length(data)) >= MaxLength) then begin
              for I := 1 to Length(data) do begin
                nKey := data[i];
                if (nKey = #13) or (nKey = #10) then Continue;
                KeyPress(nKey);
              end;
              break;
            end;

            if Data = '' then Data := #9;
            if FLines.Count <= 0 then begin
              FLines.AddObject(Data, TObject(13));
              FCaretY := 0;
              RefListWidth(FCaretY, -1);
            end
            else if boAdd then begin
              Inc(FCaretY);
              FLines.InsertObject(FCaretY, Data, TObject(13));
              FCaretX := 0;
              RefListWidth(FCaretY, -1);
            end
            else begin
              TempStr := TDMemoStringList(FLines).Str[FCaretY];
              Insert(Data, TempStr, FCaretX + 1);
              TDMemoStringList(FLines).Str[FCaretY] := TempStr;
              Inc(FCaretX, Length(WideString(Data)));
              FLines.Objects[FCaretY] := TObject(13);
              RefListWidth(FCaretY, FCaretX);
            end;

            boAdd := True;
          end;
        end;
        if boAdd then TextChange();
        Clipboard.Free;
      end;
      Key := 0;
      Result := True;
      Exit;
    end
    else if (ssShift in Shift) and (not Downed) then begin
      KeyDowned := True;
    end
    else
      KeyDowned := False;
    if FLines.Count <= 0 then
      exit;
    case Key of
      VK_UP,
        VK_DOWN,
        VK_RIGHT,
        VK_LEFT: begin
          KeyCaret(Key);
          Key := 0;
          Result := TRUE;
        end;
      VK_BACK: begin
          if (not FReadOnly) then begin
            if not ClearKey then begin
              while True do begin
                TempStr := TDMemoStringList(FLines).Str[FCaretY];
                if FCaretX > 0 then begin
                  Delete(TempStr, FCaretX, 1);
                  if TempStr = '' then begin
                    FLines.Delete(FCaretY);
                    if FCaretY > 0 then begin
                      Dec(FCaretY);
                      FCaretX :=
                        Length(WideString(TDMemoStringList(FLines).Str[FCaretY]));
                      SetCaret(True);
                    end
                    else begin
                      FCaretY := 0;
                      FCaretX := 0;
                      SetCaret(False);
                    end;
                    Exit;
                  end
                  else begin
                    TDMemoStringList(FLines).Str[FCaretY] := TempStr;
                    Dec(FCaretX);
                  end;
                  break;
                end
                else if FCaretX = 0 then begin
                  if FCaretY > 0 then begin
                    if Integer(FLines.Objects[FCaretY - 1]) = 13 then begin
                      FLines.Objects[FCaretY - 1] := nil;
                      Break;
                    end
                    else begin
                      FLines.Objects[FCaretY - 1] := FLines.Objects[FCaretY];
                      FCaretX :=
                        Length(WideString(TDMemoStringList(FLines).Str[FCaretY -
                        1]));
                      TDMemoStringList(FLines).Str[FCaretY - 1] :=
                        TDMemoStringList(FLines).Str[FCaretY - 1] +
                        TDMemoStringList(FLines).Str[FCaretY];
                      FLines.Delete(FCaretY);
                      Dec(FCaretY);
                    end;
                  end
                  else
                    Break;
                end
                else
                  Break;
              end;
              RefListWidth(FCaretY, FCaretX);
              SetCaret(True);
            end;
            TextChange();
          end;
          Key := 0;
          Result := TRUE;
        end;
      VK_DELETE: begin
          if (not FReadOnly) then begin
            if not ClearKey then begin
              while True do begin
                TempStr := TDMemoStringList(FLines).Str[FCaretY];
                if Length(TempStr) > FCaretX then begin
                  Delete(TempStr, FCaretX + 1, 1);
                  if TempStr = '' then begin
                    FLines.Delete(FCaretY);
                    if FCaretY > 0 then begin
                      Dec(FCaretY);
                      FCaretX :=
                        Length(WideString(TDMemoStringList(FLines).Str[FCaretY]));
                      SetCaret(True);
                    end
                    else begin
                      FCaretY := 0;
                      FCaretX := 0;
                      SetCaret(False);
                    end;
                    Exit;
                  end
                  else
                    TDMemoStringList(FLines).Str[FCaretY] := TempStr;
                  break;
                end
                else if Integer(FLines.Objects[FCaretY]) = 13 then begin
                  FLines.Objects[FCaretY] := nil;
                  break;
                end
                else begin
                  if (FCaretY + 1) < FLines.Count then begin
                    TDMemoStringList(FLines).Str[FCaretY] :=
                      TDMemoStringList(FLines).Str[FCaretY] +
                      TDMemoStringList(FLines).Str[FCaretY + 1];
                    FLines.Objects[FCaretY] := FLines.Objects[FCaretY + 1];
                    FLines.Delete(FCaretY + 1);
                  end
                  else
                    Break;
                end;
              end;
              RefListWidth(FCaretY, FCaretX);
              SetCaret(True);
            end;
            TextChange();
          end;
          Key := 0;
          Result := TRUE;
        end;
    end;

  end;
end;

function TDMemo.KeyPress(var Key: Char): Boolean;
var

  TempStr, Temp: WideString;
  OldObject: Integer;
begin
  Result := False;
  if (KeyControl = Self) then begin
    if (not Downed) and (not FReadOnly) then begin
      Result := True;
      if Assigned(FOnKeyPress) then
        FOnKeyPress(self, Key);
      if Key = #0 then
        Exit;

      if (FCaretY >= Lines.Count) then
        FCaretY := Max(Lines.Count - 1, 0);
      if FCaretY < 0 then begin
        FTopIndex := 0;
        FCaretY := 0;
      end;
      if Key = #13 then begin
        if (MaxLength > 0) and (Length(GetText) >= MaxLength) then begin
          Key := #0;
          exit;
        end;
        if FLines.Count <= 0 then begin
          FLines.AddObject('', TObject(13));
          FLines.AddObject('', TObject(13));
          FCaretX := 0;
          FCaretY := 1;
          SetCaret(True);
        end
        else begin
          Temp := TDMemoStringList(FLines).Str[FCaretY];
          OldObject := Integer(FLines.Objects[FCaretY]);

          TempStr := Copy(Temp, 1, FCaretX);
          TDMemoStringList(FLines).Str[FCaretY] := TempStr;
          FLines.Objects[FCaretY] := TObject(13);

          TempStr := Copy(Temp, FCaretX + 1, 255);
          if TempStr <> '' then begin
            FLines.InsertObject(FCaretY + 1, TempStr, TObject(OldObject));
          end
          else begin
            FLines.InsertObject(FCaretY + 1, '', TObject(OldObject));
          end;
          RefListWidth(FCaretY + 1, 0);
          FCaretY := FCaretY + 1;
          FCaretX := 0;
          SetCaret(True);
        end;
        exit;
      end;

      if (FEditClass = deInteger) and (not IsIntegerChars(Key)) then begin
        Key := #0;
        exit;
      end
      else if (FEditClass = deMonoCase) and (not IsEnglishChars(Key)) then begin
        Key := #0;
        exit;
      end;
      if (FEditClass = deEnglishAndInt) and (not IsStandardChars(Key)) then begin
        key := #0;
        exit;
      end;
      if (FEditClass = deCDKey) and (not IsCDKeyChars(Key)) then begin
        key := #0;
        exit;
      end;

      //ASCII范围限制
      if IsAllChars(Key) then begin
        if IsDBCSLeadByte(Ord(Key)) or bDoubleByte then begin
          bDoubleByte := true;
          Inc(KeyByteCount);
          FInputStr := FInputStr + key;
        end;
        if not bDoubleByte then begin
          if (FEditClass = deStandard) and (not IsStandardChars(Key)) then begin
            Key := #0;
            exit;
          end;
          ClearKey;
          if (MaxLength > 0) and (Length(GetText) >= MaxLength) then begin
            Key := #0;
            exit;
          end;
          if FLines.Count <= 0 then begin
            FLines.AddObject(Key, nil);
            FCaretX := 1;
            FCaretY := 0;
          end
          else begin
            TempStr := TDMemoStringList(FLines).Str[FCaretY];
            Insert(Key, TempStr, FCaretX + 1);
            TDMemoStringList(FLines).Str[FCaretY] := TempStr;
            Inc(FCaretX);
            RefListWidth(FCaretY, FCaretX);
          end;
          SetCaret(True);
          Key := #0;
          TextChange();
        end
        else if KeyByteCount >= 2 then begin
          if length(FInputStr) <> 2 then begin
            bDoubleByte := false;
            KeyByteCount := 0;
            FInputStr := '';
            Key := #0;
            exit;
          end;
          if (FEditClass = deStandard) and (FInputStr = '') then begin
            bDoubleByte := false;
            KeyByteCount := 0;
            FInputStr := '';
            Key := #0;
            exit;
          end;
          if (FEditClass = deChinese) and (FInputStr = '') then begin
            bDoubleByte := false;
            KeyByteCount := 0;
            FInputStr := '';
            Key := #0;
            exit;
          end;
          ClearKey;
          if (MaxLength > 0) and (Length(string(GetText)) >= (MaxLength - 1)) then begin
            bDoubleByte := false;
            KeyByteCount := 0;
            FInputStr := '';
            Key := #0;
            exit;
          end;
          if FLines.Count <= 0 then begin
            FLines.AddObject(FInputStr, nil);
            FCaretX := 1;
            FCaretY := 0;
          end
          else begin
            TempStr := TDMemoStringList(FLines).Str[FCaretY];
            Insert(FInputStr, TempStr, FCaretX + 1);
            TDMemoStringList(FLines).Str[FCaretY] := TempStr;
            Inc(FCaretX);
            RefListWidth(FCaretY, FCaretX);
          end;
          SetCaret(True);
          bDoubleByte := false;
          KeyByteCount := 0;
          FInputStr := '';
          Key := #0;
          TextChange();
        end;
      end;
      Key := #0;
    end else begin
      Result := False;
    end;
  end;
end;

function TDMemo.KeyUp(var Key: Word; Shift: TShiftState): Boolean;
begin
  Result := FALSE;

  if (KeyControl = self) then begin
    if (ssShift in Shift) then begin
      KeyDowned := False;
    end;
    if Assigned(FOnKeyUp) then
      FOnKeyUp(self, Key, Shift);
    Key := 0;
    Result := TRUE;
  end;
end;

procedure TDMemo.Leave;
begin
  inherited;
end;

function TDMemo.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer): Boolean;
begin
  Result := FALSE;
  if inherited MouseDown(Button, Shift, X, Y) then begin
    if (not Background) and (MouseCaptureControl = nil) then begin
      KeyDowned := False;
      if mbLeft = Button then begin
        if (FocusedControl = self) then begin
          DownCaret(X - left, Y - top);
        end;
        SetCaret(False);
        Downed := True;
      end;
      SetDCapture(self);
    end;
    Result := TRUE;
  end;
end;

function TDMemo.MouseMove(Shift: TShiftState; X, Y: Integer): Boolean;
begin
  Result := inherited MouseMove(Shift, X, Y);
  if Result and (MouseCaptureControl = self) then begin
    if Downed and (not KeyDowned) then
      MoveCaret(X - left, Y - top);
  end;
end;

function TDMemo.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer): Boolean;
begin
  Result := FALSE;
  Downed := False;
  if inherited MouseUp(Button, Shift, X, Y) then begin
    ReleaseDCapture;
    if not Background then begin
      if InRange(X, Y, Shift) then begin
        if Assigned(FOnClick) then
          FOnClick(self, X, Y);
      end;
    end;
    Result := TRUE;
    exit;
  end
  else begin
    ReleaseDCapture;
  end;
end;

procedure TDMemo.MoveCaret(X, Y: Integer);
var
  tempstrw: WideString;
  nShowCount, i: Integer;
  tempstr: string;
begin
  nShowCount := (Height - 1) div 14;
  if Y < 0 then begin
    if (GetTickCount - FMoveTick) < 50 then
      Exit;
    if FTopIndex > 0 then
      Dec(FTopIndex);
    FCaretY := FTopIndex;
  end
  else if Y > Height then begin
    if (GetTickCount - FMoveTick) < 50 then
      Exit;
    Inc(FCaretY);
    if FCaretY >= FLines.Count then
      FCaretY := Max(FLines.Count - 1, 0);
    FTopIndex := Max(FCaretY - nShowCount + 1, 0);
  end
  else
    FCaretY := (y - 1) div 14 + FTopIndex;
  FMoveTick := GetTickCount;

  if FCaretY >= FLines.Count then
    FCaretY := Max(FLines.Count - 1, 0);
  FCaretX := 0;
  if FCaretY < FLines.Count then begin
    tempstrw := TDMemoStringList(FLines).Str[FCaretY];
    if tempstrw <> '' then begin
      for i := 1 to Length(tempstrw) do begin
        tempstr := Copy(tempstrw, 1, i);
        if (g_DXCanvas.TextWidth(tempstr)) > (X) then
          exit;
        FCaretX := i;
      end;
    end;
  end;
end;

procedure TDMemo.PositionChange(Sender: TObject);
begin
  FTopIndex := FUpDown.Position;
end;

procedure TDMemo.RefListWidth(ItemIndex: Integer; nCaret: Integer);
var
  i, Fi, nIndex, nY: Integer;
  TempStr, AddStr: WideString;
begin
  TempStr := '';
  nIndex := 0;
  while True do begin
    if ItemIndex >= FLines.Count then
      Break;
    TempStr := TempStr + TDMemoStringList(FLines).Str[ItemIndex];
    nIndex := Integer(Lines.Objects[ItemIndex]);
    FLines.Delete(ItemIndex);
    if nIndex = 13 then
      Break;
  end;
  if TempStr <> '' then begin
    AddStr := '';
    Fi := 1;
    nY := ItemIndex;
    for i := 1 to Length(TempStr) + 1 do begin
      AddStr := Copy(TempStr, Fi, i - Fi + 1);
      if g_DXCanvas.TextWidth(AddStr) > (Width - 20) then begin
        AddStr := Copy(TempStr, Fi, i - Fi);
        Fi := i;
        FLines.InsertObject(ItemIndex, AddStr, nil);
        nIndex := ItemIndex;
        Inc(ItemIndex);
        nY := ItemIndex;
        AddStr := '';
      end;
      if i = nCaret then begin
        FCaretX := i - Fi + 1;
        FCaretY := nY;
        SetCaret(True);
      end;
    end;
    if AddStr <> '' then begin
      FLines.InsertObject(ItemIndex, AddStr, TObject(13));
      nIndex := ItemIndex;
    end
    else begin
      FLines.Objects[nIndex] := TObject(13);
    end;
    if nCaret = -1 then begin
      FCaretY := nIndex;
      FCaretX := Length(WideString(TDMemoStringList(FLines).Str[nIndex]));
      SetCaret(True);
    end;

  end;
  if FCaretY >= FLines.Count then begin
    FCaretY := Max(FLines.Count - 1, 0);
    SetCaret(True);
  end;
end;

procedure TDMemo.DownCaret(X, Y: Integer);
var
  tempstrw: WideString;
  i: Integer;
  tempstr: string;
begin
  FCaretY := (y - 1) div 14 + FTopIndex;
  if FCaretY >= FLines.Count then
    FCaretY := Max(FLines.Count - 1, 0);
  FCaretX := 0;
  if FCaretY < FLines.Count then begin
    tempstrw := TDMemoStringList(FLines).Str[FCaretY];
    if tempstrw <> '' then begin
      for i := 1 to Length(tempstrw) do begin
        tempstr := Copy(tempstrw, 1, i);
        if (g_DXCanvas.TextWidth(tempstr)) > (X) then
          exit;
        FCaretX := i;
      end;
    end;
  end;
end;

function TDMemo.Selected: Boolean;
begin
  Result := False;
  if FLines.Count > 0 then begin
    if (FCaretX <> FSCaretX) or (FSCaretY <> FCaretY) then begin
      Result := True;
    end;
  end;
end;

procedure TDMemo.SetCaret(boBottom: Boolean);
var
  nShowCount: Integer;
begin
  FSCaretX := FCaretX;
  FSCaretY := FCaretY;
  if boBottom then begin
    nShowCount := (Height - 1) div 14;
    if FCaretY < FTopIndex then
      FTopIndex := FCaretY
    else begin
      if (FCaretY - FTopIndex) >= nShowCount then begin
        FTopIndex := Max(FCaretY - nShowCount + 1, 0);
      end;
    end;
  end;
end;

procedure TDMemo.SetCaretY(const Value: Integer);
begin
  FCaretY := Value;
  if FCaretY >= FLines.Count then
    FCaretY := Max(FLines.Count - 1, 0);
  if FCaretY < 0 then
    FCaretY := 0;
  SetCaret(True);
end;

procedure TDMemo.SetFocus;
begin
  inherited;
end;

procedure TDMemo.SetUpDown(const Value: TDUpDown);
begin
  FUpDown := Value;
  FWheelDControl := Value;
  if FUpDown <> nil then begin
    FUpDown.OnPositionChange := PositionChange;
    FUpDown.Visible := False;
    FUpDown.MaxPosition := 0;
    FUpDown.Position := 0;
  end;
end;

procedure TDMemo.TextChange;
begin
  if Assigned(FOnChange) then
    FOnChange(self);
end;

{ TDMemoStringList }

function TDMemoStringList.Add(const S: string): Integer;
begin
  Result := AddObject(S, TObject(13));
  DMemo.RefListWidth(Result, -1);
end;

function TDMemoStringList.AddObject(const S: string; AObject: TObject): Integer;
var
  AddStr: string;
begin
  AddStr := AnsiReplaceText(S, #13, '');
  AddStr := AnsiReplaceText(AddStr, #10, '');
  if AddStr = '' then begin
    Result := inherited AddObject(#9, AObject);
  end
  else
    Result := inherited AddObject(AddStr, AObject);
end;

procedure TDMemoStringList.Assign(Source: TPersistent);
begin
  inherited Assign(Source);
  DMemo.FCaretY := 0;
  DMemo.FCaretX := 0;
  DMemo.SetCaret(False);
end;

procedure TDMemoStringList.Clear;
begin
  inherited;
  DMemo.FCaretY := 0;
  DMemo.FCaretX := 0;
  DMemo.SetCaret(False);
end;

function TDMemoStringList.Get(Index: Integer): string;
begin
  Result := inherited Get(Index);
  Result := AnsiReplaceText(Result, #9, '');
end;

procedure TDMemoStringList.InsertObject(Index: Integer; const S: string;
  AObject: TObject);
var
  AddStr: string;
begin
  AddStr := AnsiReplaceText(S, #13, '');
  AddStr := AnsiReplaceText(AddStr, #10, '');
  if AddStr = '' then begin
    inherited InsertObject(Index, #9, AObject);
  end
  else
    inherited InsertObject(Index, AddStr, AObject);
end;

function TDMemoStringList.GetText: PChar;
var
  i: Integer;
  AddStr: string;
begin
  AddStr := '';
  for i := 0 to Count - 1 do begin
    AddStr := AddStr + Get(i);
    if Char(Objects[i]) = #13 then begin
      AddStr := AddStr + #13;
    end;
  end;
  Result := StrNew(PChar(AddStr));
end;

procedure TDMemoStringList.SaveToFile(const FileName: string);
var
  TempString: TStringList;
  i: Integer;
  AddStr: string;
begin
  TempString := TStringList.Create;
  try
    AddStr := '';
    for i := 0 to Count - 1 do begin
      AddStr := AddStr + Get(i);
      if Char(Objects[i]) = #13 then begin
        TempString.Add(AddStr);
        AddStr := '';
      end;
    end;
    if AddStr <> '' then
      TempString.Add(AddStr);

    TempString.SaveToFile(FileName);
  finally
    TempString.Free;
  end;
end;

procedure TDMemoStringList.LoadFromFile(const FileName: string);
var
  TempString: TStringList;
  i: Integer;
begin
  Clear;
  TempString := TStringList.Create;
  try
    if FileExists(Filename) then begin
      TempString.LoadFromFile(FileName);
      for i := 0 to TempString.Count - 1 do begin
        Add(TempString[i]);
      end;
    end;
  finally
    TempString.Free;
  end;
end;

procedure TDMemoStringList.Put(Index: Integer; const Value: string);
var
  AddStr: string;
begin
  if Value <> '' then begin
    AddStr := AnsiReplaceText(Value, #13, '');
    AddStr := AnsiReplaceText(AddStr, #10, '');
  end
  else
    AddStr := #9;
  inherited Put(Index, AddStr);
end;

function TDMemoStringList.SelfGet(Index: Integer): string;
begin
  Result := inherited Get(Index);
end;

{ TDUpDown }

procedure TDUpDown.ButtonMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FClickTime := GetTickCount;
  if Sender = FUpButton then begin
    if FPosition >= FMovePosition then
      Dec(FPosition, FMovePosition)
    else
      FPosition := 0;
    FAddTop := Round(FMaxLength / FMaxPosition * FPosition);
    if Assigned(FOnPositionChange) then
      FOnPositionChange(Self);
  end
  else if Sender = FDownButton then begin
    if (FPosition + FMovePosition) <= FMaxPosition then
      Inc(FPosition, FMovePosition)
    else
      FPosition := FMaxPosition;
    FAddTop := Round(FMaxLength / FMaxPosition * FPosition);
    if Assigned(FOnPositionChange) then
      FOnPositionChange(Self);
  end
  else if Sender = FMoveButton then begin
    StopY := Y;
    FStopY := FAddTop;
  end;
  if Assigned(FOnMouseDown) then
    FOnMouseDown(self, Button, Shift, X, Y);
end;

procedure TDUpDown.ButtonMouseMove(Sender: TObject; Shift: TShiftState; X, Y:
  Integer);
var
  nIdx: Integer;
  OldPosition: Integer;
  nY: Integer;
  DButton: TDButton;
begin
  if Sender = FUpButton then begin
    DButton := TDButton(Sender);
    if (DButton.Downed) and ((GetTickCount - FClickTime) > 100) then
      ButtonMouseDown(Sender, mbLeft, Shift, X, Y);
  end
  else if Sender = FDownButton then begin
    DButton := TDButton(Sender);
    if (DButton.Downed) and ((GetTickCount - FClickTime) > 100) then
      ButtonMouseDown(Sender, mbLeft, Shift, X, Y);
  end
  else if Sender = FMoveButton then begin
    if (StopY < 0) or (StopY = y) then begin
      if Assigned(FOnMouseMove) then
        FOnMouseMove(self, Shift, X, Y);
      Exit;
    end;

    nY := Y - StopY;
    FAddTop := FStopY + nY;
    if FAddTop < 0 then
      FAddTop := 0;
    if FAddTop > FMaxLength then
      FAddTop := FMaxLength;

    OldPosition := FPosition;
    nIdx := Round(FAddTop / (FMaxLength / FMaxPosition));
    if nIdx <= 0 then
      FPosition := 0
    else if nIdx >= FMaxPosition then
      FPosition := FMaxPosition
    else
      FPosition := nIdx;
    if OldPosition <> FPosition then
      if Assigned(FOnPositionChange) then
        FOnPositionChange(Self);
  end;
  if Assigned(FOnMouseMove) then
    FOnMouseMove(self, Shift, X, Y);
end;

procedure TDUpDown.ButtonMouseUp(Sender: TObject; Button: TMouseButton; Shift:
  TShiftState; X, Y: Integer);
begin
  StopY := -1;
  if Assigned(FOnMouseUp) then
    FOnMouseUp(self, Button, Shift, X, Y);
end;

constructor TDUpDown.Create(AOwner: TComponent);
begin
  CreatePropertites;
  inherited Create(aowner);
  FUpButton := TDUpDownButton.Create(nil);
  FDownButton := TDUpDownButton.Create(nil);
  FMoveButton := TDUpDownButton.Create(nil);

  FUpButton.Caption := '上';
  FDownButton.Caption := '下';
  FMoveButton.Caption := '滚动';

  SetButton(UpButton);
  SetButton(DownButton);
  SetButton(MoveButton);

  FOffset := 0;
  FBoMoveShow := False;
  FboMoveFlicker := False;
  FboNormal := False;

  FMovePosition := 1;
  FPosition := 0;
  FMaxPosition := 0;
  FMaxLength := 0;
  FTop := 0;
  FAddTop := 0;
  StopY := -1;
  FWheelDControl := Self;
end;

procedure TDUpDown.CreatePropertites;
begin
  FPropertites := TDXUpDownPropertites.Create(Self);
  FDXImageLib := TDXUpDownProperty.Create(FPropertites);
end;

destructor TDUpDown.Destroy;
begin
  FUpButton.Free;
  FDownButton.Free;
  FMoveButton.Free;
  inherited;
end;

procedure TDUpDown.DirectPaint(dsurface: TDXTexture);
var
  d: TDXTexture;
  dc, rc: TRect;
begin
  if FImages <> nil then begin //判断为空
    d := FImages.Images[FaceIndex];
    if d <> nil then begin
      dc.Left := SurfaceX(Left);
      dc.Top := SurfaceY(Top) + 2;
      dc.Right := SurfaceX(left + Width);
      dc.Bottom := SurfaceY(top + Height) - 2;
      rc.Left := 0;
      rc.Top := 0;
      rc.Right := d.ClientRect.Right;
      rc.Bottom := d.ClientRect.Bottom;
      dsurface.StretchDraw(dc, rc, d, True);
    end;
    if FUpButton <> nil then begin
      with FUpButton do begin
        if FboNormal then begin
          Left := FOffset;
          Top := 0;
        end else begin
          Left := FOffset;
          Top := FOffset;
        end;
        if Downed then begin
          d := FImages.Images[FaceIndex + 1 + Integer(FBoMoveShow)];
        end
        else if MouseEntry = msIn then begin
          d := FImages.Images[FaceIndex + Integer(FBoMoveShow)];
        end
        else begin
          d := FImages.Images[FaceIndex];
        end;
        if d <> nil then begin
          FTop := d.Height + Top;
          dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, True);
        end;
      end;
    end;
    if FDownButton <> nil then begin
      with FDownButton do begin
        if FboNormal then begin
          Left := FOffset;
          Top := Self.Height - d.Height;
        end else begin
          Left := FOffset;
          if FBoMoveShow then
            Top := Self.Height - d.Height + 1
          else
            Top := Self.Height - d.Height - 1;
        end;

        if Downed then begin
          d := FImages.Images[FaceIndex + 1 + Integer(FBoMoveShow)];
        end
        else if MouseEntry = msIn then begin
          d := FImages.Images[FaceIndex + Integer(FBoMoveShow)];
        end
        else begin
          d := FImages.Images[FaceIndex];
        end;
        if d <> nil then begin
          FMaxLength := Top - FTop;
          dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, True);
        end;
      end;
    end;
    if FMoveButton <> nil then begin
      with FMoveButton do begin
        Left := FOffset;
        if FBoMoveShow then begin
          if Downed then begin
            d := FImages.Images[FaceIndex + 2];
          end
          else if MouseEntry = msIn then begin
            d := FImages.Images[FaceIndex + 1];
          end
          else begin
            if FboMoveFlicker and ((GetTickCount - AppendTick) mod 400 < 200) then begin
              d := FImages.Images[FaceIndex + 1];
            end else
              d := FImages.Images[FaceIndex];
          end;
          if (d <> nil) then begin
            Dec(FMaxLength, d.Height);
            Top := FTop + FAddTop;
            if FMaxPosition > 0 then
              dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, True);
          end;
        end
        else begin
          d := FImages.Images[FaceIndex];
          if d <> nil then begin
            Dec(FMaxLength, d.Height);
            Top := FTop + FAddTop;
            dsurface.Draw(SurfaceX(Left), SurfaceY(Top), d.ClientRect, d, True);
          end;
        end;
      end;
    end;
  end;
  if Assigned(FOnEndDirectPaint) then
    FOnEndDirectPaint(self, dsurface);

  if g_TranFrame then
    g_DXCanvas.RoundRect(SurfaceX(Left), SurfaceY(Top), SurfaceX(Left + Width), SurfaceY(Top + Height), clLime);

  if g_DragMode and (SeletedControl = Self) then
    g_DXCanvas.RoundRect(SurfaceX(Left), SurfaceY(Top), SurfaceX(Left + Width), SurfaceY(Top + Height), clRed);
end;

function TDUpDown.MouseWheel(Shift: TShiftState; Wheel: TMouseWheel; X, Y: Integer): Boolean;
begin
  Result := True;
  if Wheel = mw_Up then
    ButtonMouseDown(FUpButton, mbLeft, Shift, X, Y)
  else if Wheel = mw_Down then
    ButtonMouseDown(FDownButton, mbLeft, Shift, X, Y);
end;

procedure TDUpDown.SetButton(Button: TDUpDownButton);
begin
  Button.DParent := Self;
  Button.OnMouseMove := ButtonMouseMove;
  Button.FWheelDControl := Self;
  Button.OnMouseDown := ButtonMouseDown;
  Button.OnMouseUp := ButtonMouseUp;
  AddChild(Button);
end;

procedure TDUpDown.SetMaxPosition(const Value: Integer);
var
  OldPosition: integer;
begin
  OldPosition := FMaxPosition;
  FMaxPosition := Max(Value, 0);
  if OldPosition <> FMaxPosition then begin
    if FPosition > FMaxPosition then
      FPosition := FMaxPosition;
    if FMaxPosition > 0 then
      FAddTop := Round(FMaxLength / FMaxPosition * FPosition);
  end;
end;

procedure TDUpDown.SetPosition(value: Integer);
var
  OldPosition: integer;
begin
  OldPosition := FPosition;
  FPosition := Max(Value, 0);
  if FPosition > FMaxPosition then
    FPosition := FMaxPosition;
  if OldPosition <> FPosition then begin
    if FMaxPosition > 0 then
      FAddTop := Round(FMaxLength / FMaxPosition * FPosition);
  end;
end;

{ TDImageGrid }

constructor TDImageGrid.Create(aowner: TComponent);
begin
  CreatePropertites;
  inherited Create(aowner);
  FStretch := True;
  FRelativeLeft := 0;
  FRelativeTop := 0;
  FRelativeRight := 0;
  FRelativeBottom := 0;
end;

procedure TDImageGrid.CreatePropertites;
begin
  FPropertites := TDXWindowImageGridPropertites.Create(Self);
  FDXImageLib := TDXWindowImageProperty.Create(FPropertites);
end;

procedure TDImageGrid.DirectPaint(DSurface: TDXTexture);
var
  d: TDXTexture;
  i, ax, ay: integer;
  rc: TRect;
begin
  if Assigned(FOnDirectPaint) then
    FOnDirectPaint(Self, dsurface);

  if Assigned(FImages) then
  begin
    ax := SurfaceX(Left);
    ay := SurfaceY(Top);

    d := FImages.Images[FImageIndex + 3];   //左竖
    if d <> nil then begin
      rc := d.ClientRect;
      rc.Bottom := Height - 20;
      dsurface.Draw(ax, ay + 10, rc, d, DrawMode);
    end;

    d := FImages.Images[FImageIndex + 4];  //右竖
    if d <> nil then begin
      rc := d.ClientRect;      //重绘
      rc.Bottom := Height - 20;
      dsurface.Draw(ax + (Width - d.Width) + 2, ay + 10 , rc, d, DrawMode);
    end;

    d := FImages.Images[FImageIndex + 1];   //上杠
    if d <> nil then begin
      rc := d.ClientRect;
      rc.Right := Width - 20;
      dsurface.Draw(ax + 10, ay + 1, rc, d, DrawMode);
    end;

    d := FImages.Images[FImageIndex + 6];   //下杠
    if d <> nil then begin
      rc := d.ClientRect;
      rc.Right := Width - 20;
      dsurface.Draw(ax + 10, ay + (Height - d.Height), rc, d, DrawMode);
    end;

    d := FImages.Images[FImageIndex];   //左上角
    if d <> nil then begin
      dsurface.Draw(ax, ay + 1, d.ClientRect, d, DrawMode);
    end;

    d := FImages.Images[FImageIndex + 2];   //右上角
    if d <> nil then begin
      dsurface.Draw(ax + (Width - d.Width) + 2, ay + 1, d.ClientRect, d, DrawMode);
    end;

    d := FImages.Images[FImageIndex + 5];   //左下角
    if d <> nil then begin
      dsurface.Draw(ax, ay + (Height - d.Height), d.ClientRect, d, DrawMode);

    end;

    d := FImages.Images[FImageIndex + 7];   //右下角
    if d <> nil then begin
      dsurface.Draw(ax + (Width - d.Width) + 2, ay + (Height - d.Height), d.ClientRect, d, DrawMode);
    end;

//    d := g_WMyMain.Images[1617];   //中间
//    if d <> nil then begin
//      rc := d.ClientRect;
//      rc.Right := Width - 30;
//      dsurface.Draw(ax + 8, ay + 31, rc, d, True);
//    end;

    //画背景
    g_DXCanvas.FillRect(ax + 16, ay + 38, Width - 38, Height - 70, $FFFFFFFF);
  end;

  for i := 0 to DControls.Count - 1 do begin
    if TDControl(DControls[i]).Visible then
      TDControl(DControls[i]).DirectPaint(dsurface);
  end;

  if Assigned(FOnEndDirectPaint) then
    FOnEndDirectPaint(Self, dsurface);

  if g_TranFrame then
    g_DXCanvas.RoundRect(SurfaceX(Left), SurfaceY(Top), SurfaceX(Left + Width), SurfaceY(Top + Height), clLime);

  if g_DragMode and (SeletedControl = Self) then
    g_DXCanvas.RoundRect(SurfaceX(Left), SurfaceY(Top), SurfaceX(Left + Width), SurfaceY(Top + Height), clRed);
end;

{ TDXWindowImageGridPropertites }

function TDXWindowImageGridPropertites.GetRelative(const Index: Integer): Integer;
begin
  Result := 0;
  if FControl is TDImageGrid then
  begin
    case Index of
      1: Result := TDImageGrid(FControl).RelativeLeft;
      2: Result := TDImageGrid(FControl).RelativeTop;
      3: Result := TDImageGrid(FControl).RelativeRight;
      4: Result := TDImageGrid(FControl).RelativeBottom;
    end;
  end;
end;

function TDXWindowImageGridPropertites.GetStretch: Boolean;
begin
  Result := False;
  if FControl is TDImageGrid then
  begin
    Result := TDImageGrid(FControl).Stretch;
  end;
end;

procedure TDXWindowImageGridPropertites.SetRelative(const Index, Value: Integer);
var
  DParent: TDControl;
begin
  if FControl is TDImageGrid then
  begin
    case Index of
      1: TDImageGrid(FControl).RelativeLeft := Value;
      2: TDImageGrid(FControl).RelativeTop := Value;
      3: TDImageGrid(FControl).RelativeRight := Value;
      4: TDImageGrid(FControl).RelativeBottom := Value;
    end;
    //拉伸
    if TDImageGrid(FControl).Stretch then
    begin
      DParent := TDImageGrid(FControl).DParent;
      if DParent <> nil then
      begin
        Left := TDImageGrid(FControl).RelativeLeft;
        Top := TDImageGrid(FControl).RelativeTop;
        Width := DParent.Width - TDImageGrid(FControl).RelativeLeft - TDImageGrid(FControl).RelativeRight;
        Height := DParent.Height - TDImageGrid(FControl).RelativeTop - TDImageGrid(FControl).RelativeBottom;
      end;
    end;
  end;
end;

procedure TDXWindowImageGridPropertites.SetStretch(const Value: Boolean);
var
  DParent: TDControl;
begin
  if FControl is TDImageGrid then
  begin
    TDImageGrid(FControl).Stretch := Value;
    if Value then
    begin
      //拉伸
      DParent := TDImageGrid(FControl).DParent;
      if DParent <> nil then
      begin
        Left := TDImageGrid(FControl).RelativeLeft;
        Top := TDImageGrid(FControl).RelativeTop;
        Width := DParent.Width - TDImageGrid(FControl).RelativeLeft - TDImageGrid(FControl).RelativeRight;
        Height := DParent.Height - TDImageGrid(FControl).RelativeTop - TDImageGrid(FControl).RelativeBottom;
      end;
    end;
  end;
end;

{ TDImageEdit }

procedure TDImageEdit.RefEditText();
var
  i: integer;
  nLen, TextLen: integer;
  sstr: string;
begin
  nLen := FStartoffset;
  FEditString := '';
  for I := 0 to FEditTextList.Count - 1 do begin
    sstr := FEditTextList[i];
    if sstr <> '' then begin
      if sstr[1] = #13 then begin
        Inc(nLen, FImageWidth);
        FEditString := FEditString + FImageChar + Trim(sstr) + FImageChar;
      end
      else if sstr[1] = #10 then begin
        FEditString := FEditString + GetItemName(sstr, False);
        TextLen := g_DXCanvas.TextWidth(GetItemName(sstr, True));
        Inc(nLen, TextLen);
      end
      else begin
        FEditString := FEditString + sstr;
        TextLen := g_DXCanvas.TextWidth(sstr);
        Inc(nLen, TextLen);
      end;
      FEditTextList.Objects[i] := TObject(nLen);
    end;
  end;
end;

Function TDImageEdit.AddImageToList(ImageIndex: string): Byte;
var
  LenStr: string;
  i: integer;
  str: string;
  nCount: Integer;
begin
  Result := 1;
  if (ImageIndex = '') then exit;
  Result := 2;
  LenStr := FImageChar + Trim(ImageIndex) + FImageChar;
  nCount := 0;
  if (MaxLength = 0) or (Length(FEditString + LenStr) <= MaxLength) then begin
    for I := 0 to FEditTextList.Count - 1 do begin
      str := FEditTextList[i];
      if (str <> '') and (str[1] = #13) then Inc(nCount);
    end;
    if nCount >= FImageCount then begin
      Result := 4;
      exit;
    end;
    Result := 0;
    ClearKey;
    if FCaretPos > FEditTextList.Count then
      FCaretPos := FEditTextList.Count;
    FEditTextList.Insert(FCaretPos, #13 + Trim(ImageIndex));
    Inc(FCaretPos);
    RefEditText();
    RefEditSurfce();
    TextChange;
  end;
end;

Function  TDImageEdit.AddItemToList(ItemName, ItemIndex: string): Byte;
var
  LenStr: string;
  AddStr, str: string;
  i: integer;
  nCount: Integer;
begin
  Result := 1;
  if (ItemName = '') or (ItemIndex = '') then exit;
  LenStr := FBeginChar + Trim(ItemIndex) + FEndChar;
  Result := 2;
  nCount := 0;
  if (MaxLength = 0) or (Length(FEditString + LenStr) <= MaxLength) then begin
    AddStr := #10 + ItemName + '/' + ItemIndex;
    for I := 0 to FEditTextList.Count - 1 do begin
      str := FEditTextList[i];
      if AddStr = str then begin
        Result := 3;
        exit;
      end else
      if (str <> '') and (str[1] = #10) then Inc(nCount);
    end;
    if nCount >= FItemCount then begin
      Result := 4;
      exit;
    end;
    Result := 0;
    ClearKey;
    if FCaretPos > FEditTextList.Count then
      FCaretPos := FEditTextList.Count;
    FEditTextList.Insert(FCaretPos, AddStr);
    Inc(FCaretPos);
    RefEditText();
    RefEditSurfce();
    TextChange;
  end;
end;

procedure TDImageEdit.AddStrToList(str: string);
begin
  if str = '' then
    exit;
  if FCaretPos > FEditTextList.Count then
    FCaretPos := FEditTextList.Count;
  FEditTextList.Insert(FCaretPos, str);
  Inc(FCaretPos);
  RefEditText();
  RefEditSurfce();
end;

procedure TDImageEdit.MoveCaret(X, Y: Integer);
var
  i: integer;
  nLen: Integer;
  OldLen: Integer;
begin
  if FEditTextList.Count <= 0 then
    exit;
  if FCaretPos > FEditTextList.Count then
    FCaretPos := FEditTextList.Count;
  if FShowPos >= FEditTextList.Count then
    FShowPos := FEditTextList.Count - 1;

  if (X < FStartoffset) and (FCaretPos > 0) then begin
    Dec(FCaretPos);
    RefEditSurfce;
  end
  else if (x > (Width - FStartoffset)) and (FCaretPos < FEditTextList.Count) then begin
    Inc(FCaretPos);
    RefEditSurfce;
  end;
  if FShowLeft then begin
    if FShowPos > 0 then
      OldLen := Integer(FEditTextList.Objects[FShowPos - 1])
    else
      OldLen := FStartoffset;
    for i := FShowPos to FEditTextList.Count - 1 do begin
      nLen := Integer(FEditTextList.Objects[i]) - OldLen;
      if nLen >= X then begin
        FCaretPos := i;
        if Downed or KeyDowned then
          FStopX := FCaretPos
        else
          FStartX := FCaretPos;
        RefEditSurfce;
        exit;
      end;
    end;
    FCaretPos := FEditTextList.Count;
    if Downed or KeyDowned then
      FStopX := FCaretPos
    else
      FStartX := FCaretPos;
    RefEditSurfce;
    exit;
  end
  else begin
    OldLen := Integer(FEditTextList.Objects[FShowPos]);
    for i := FShowPos downto 0 do begin
      nLen := Width - (OldLen - Integer(FEditTextList.Objects[i])) - FStartoffset - 2;
      if nLen <= X then begin
        FCaretPos := i + 1;
        if Downed or KeyDowned then
          FStopX := FCaretPos
        else
          FStartX := FCaretPos;
        RefEditSurfce;
        exit;
      end;
    end;
  end;
end;

procedure TDImageEdit.RefEditSurfce(boRef: Boolean);
var
  i: integer;
  nRight, nLeft: Integer;
  nLen, nTextLen: Integer;
  nStart, nStop: Integer;
  boAdd: Boolean;
  ShowStr, ShowStr2: string;
  ShowStrList: TStringList;
begin
  FEditItemList.Clear;
  FEditImageList.Clear;
  if FSurface = nil then
    exit;
  FSurface.Clear;
  FShowLine := FStartoffset;
  if FEditTextList.Count <= 0 then
    exit;
  if FCaretPos > FEditTextList.Count then
    FCaretPos := FEditTextList.Count;
  if FShowPos >= FEditTextList.Count then
    FShowPos := FEditTextList.Count - 1;

  if (FCaretPos > FShowPos) then begin
    nRight := Integer(FEditTextList.Objects[FCaretPos - 1]) + FStartoffset;
    if FShowPos > 0 then
      nLeft := Max(0, Integer(FEditTextList.Objects[FShowPos]) - FStartoffset)
    else
      nLeft := 0;
    if FShowLeft then begin
      if (nRight - nLeft) >= Width then begin
        FShowLeft := False;
        FShowPos := Max(0, FCaretPos - 1);
      end;
    end
    else begin
      FShowPos := Max(0, FCaretPos - 1);
    end;
  end
  else if (FCaretPos <= FShowPos) then begin
    nRight := Integer(FEditTextList.Objects[FShowPos]) + FStartoffset;
    if FCaretPos > 0 then
      nLeft := Max(0, Integer(FEditTextList.Objects[FCaretPos - 1]) - FStartoffset)
    else
      nLeft := 0;
    if FShowLeft then begin
      FShowPos := Max(0, FCaretPos - 1);
    end
    else begin
      if (nRight - nLeft) >= Width then begin
        FShowLeft := True;
        FShowPos := Max(0, FCaretPos - 1);
      end;
    end;
  end;
  nStart := -1;
  nStop := -1;
  if (FStartX > -1) and (FStopX > -1) and (FStartX <> FStopX) then begin
    if FStartX < FStopX then begin
      nStart := FStartX;
      nStop := FStopX;
    end
    else begin
      nStart := FStopX;
      nStop := FStartX;
    end;
    if nStart = nStop then begin
      FStartX := -1;
      FStopX := -1;
      nStart := -1;
    end;
  end;
  if nStart > FEditTextList.Count then
    nStart := FEditTextList.Count;
  if nStop > FEditTextList.Count then
    nStop := FEditTextList.Count;

  FStartLine := 0;
  FStopLine := 0;
  FOppShowPos := 0;
  boAdd := False;

  with FSurface do begin
    if FShowLeft then begin
      nLen := FStartoffset;
      FStartLine := nLen;

      for i := FShowPos to FEditTextList.Count - 1 do begin
        if i = nStart then
          FStartLine := nLen;
        ShowStr := FEditTextList[i];
        if ShowStr <> '' then begin
          if ShowStr[1] = #13 then begin
            FEditImageList.AddObject(Trim(ShowStr), TObject(nLen));
            nTextLen := FImageWidth;
          end
          else if ShowStr[1] = #10 then begin
            ShowStr := GetItemName(ShowStr, True);
            TextOutTexture(nLen, (Height - 12) div 2, ShowStr, FDefColor, FBackColor);
            nTextLen := g_DXCanvas.TextWidth(ShowStr);
            FEditItemList.AddObject(ShowStr, TObject(MakeLong(Word(nLen), Word(nLen + nTextLen))));
          end
          else begin
            TextOutTexture(nLen, (Height - 12) div 2, ShowStr, FDefColor, FBackColor);
            nTextLen := g_DXCanvas.TextWidth(ShowStr);
          end;
          Inc(nLen, nTextLen);
        end;
        if i = (nStop - 1) then
          FStopLine := nLen;
        if i = (FCaretPos - 1) then
          FShowLine := nLen;
        if (not boAdd) and (nLen > (Width - FStartoffset)) then begin
          boAdd := True;
          FOppShowPos := i - 1;
        end;
      end;
    end
    else begin
      nLen := Width - FStartoffset;
      FStopLine := nLen;
      FStartLine := nLen;
      ShowStr2 := '';
      ShowStrList := TStringList.Create;
      for i := FShowPos downto 0 do begin
        if i = (nStop - 1) then
          FStopLine := nLen;
        if i = (FCaretPos - 1) then
          FShowLine := nLen;
        ShowStr := FEditTextList[i];
        if ShowStr <> '' then begin
          if ShowStr[1] = #13 then begin
            if ShowStr2 <> '' then
              ShowStrList.AddObject(ShowStr2, TObject(nLen));
            Dec(nLen, FImageWidth);
            FEditImageList.AddObject(Trim(ShowStr), TObject(nLen));
            ShowStr2 := '';
          end
          else if ShowStr[1] = #10 then begin
            ShowStr := GetItemName(ShowStr, True);
            nTextLen := g_DXCanvas.TextWidth(ShowStr);
            ShowStr2 := ShowStr + ShowStr2;
            //TextOut(nLen, (Height - 12) div 2, ShowStr, $FFFFFFFF);
            Dec(nLen, nTextLen);
            FEditItemList.AddObject(ShowStr, TObject(MakeLong(Word(nLen), Word(nLen + nTextLen))));
          end
          else begin
            nTextLen := g_DXCanvas.TextWidth(ShowStr);
            ShowStr2 := ShowStr + ShowStr2;
            Dec(nLen, nTextLen);
            //TextOut(nLen, (Height - 12) div 2, ShowStr, $FFFFFFFF);
          end;
        end;
        if i = nStart then
          FStartLine := nLen;
        if (not boAdd) and (nLen < FStartoffset) then begin
          boAdd := True;
          FOppShowPos := i + 1;
        end;
      end;
      for I := ShowStrList.Count - 1 downto 0 do begin
        TextOutTexture(Integer(ShowStrList.Objects[i]), (Height - 12) div 2, ShowStrList[I], FDefColor, FBackColor);
      end;
      ShowStrList.Free;
      if ShowStr2 <> '' then
        TextOutTexture(nLen, (Height - 12) div 2, ShowStr2, FDefColor, FBackColor);

      if (nLen > FStartoffset) and (boRef) then begin
        FShowLeft := True;
        FShowPos := 0;
        RefEditSurfce(False);
        exit;
      end;
    end;
  end;
  if FStartLine < FStartoffset then
    FStartLine := FStartoffset;
  if FStopLine > (Width - FStartoffset) then
    FStopLine := Width - FStartoffset;
  if FStopLine < FStartoffset then
    FStopLine := FStartoffset;
  if FStartLine > (Width - FStartoffset) then
    FStartLine := Width - FStartoffset;
end;

function TDImageEdit.GetCopy: string;
var
  i: integer;
  nStart, nStop: Integer;
  sstr: string;
begin
  Result := '';
  if (FStartX > -1) and (FStopX > -1) and (FStartX <> FStopX) then begin
    if FStartX < FStopX then begin
      nStart := FStartX;
      nStop := FStopX;
    end
    else begin
      nStart := FStopX;
      nStop := FStartX;
    end;
    for I := nStart to nStop - 1 do begin
      if i < 0 then
        break;
      if i >= FEditTextList.Count then
        break;
      sstr := FEditTextList[i];
      if sstr <> '' then begin
        if sstr[1] = #13 then begin
          Result := Result + FImageChar + Trim(sstr) + FImageChar;
        end
        else if sstr[1] = #10 then begin
          Result := Result + GetItemName(sstr, False);
        end
        else begin
          Result := Result + sstr;
        end;
      end;
    end;
  end;
end;

function TDImageEdit.GetItemName(str: string; boName: Boolean): string;
var
  sname, sitemindex: string;
begin
  str := GetValidStr3(str, sname, ['/']);
  str := GetValidStr3(str, sitemindex, ['/']);
  if boName then
    Result := '<' + Trim(sname) + '>'
  else
    Result := FBeginChar + Trim(sitemindex) + FEndChar;
end;

function TDImageEdit.ClearKey: Boolean;
var
  i: integer;
  nStart, nStop: Integer;
begin
  Result := False;
  if (FStartX > -1) and (FStopX > -1) and (FStartX <> FStopX) then begin
    if FStartX < FStopX then begin
      nStart := FStartX;
      nStop := FStopX;
    end
    else begin
      nStart := FStopX;
      nStop := FStartX;
    end;
    Result := True;
    for I := (nStop - 1) downto nStart do begin
      if i < 0 then
        break;
      if i >= FEditTextList.Count then
        break;

      FEditTextList.Delete(i);

    end;
    FStartX := -1;
    FStopX := -1;
    FCaretPos := nStart;
    SetBearing(True);
    RefEditText;
    RefEditSurfce;
  end;
end;

constructor TDImageEdit.Create(AOwner: TComponent);
begin
  CreatePropertites;
  inherited Create(aowner);
  FOnChange := nil;
  FKeyFocus := True;
  FMaxLength := 0;

  Color := clBlack;

  FStartX := -1;
  FStopX := -1;
  FInputStr := '';
  bDoubleByte := False;
  KeyByteCount := 0;
  FTransparent := True;

  FEditTextList := TStringList.Create;
  FEditImageList := TStringList.Create;
  FEditItemList := TStringList.Create;
  FCaretPos := 0;
  FEditString := '';
  FStartoffset := 3;
  FShowLeft := True;
  FShowPos := 0;
  FImageWidth := 20;
  FShowLine := FStartoffset;
  FCaretShowTime := GetTickCount;
  FBeginChar := '{';
  FEndChar := '}';
  FImageChar := '#';
  FrameColor := clSilver;
  FDefColor := clWhite;
  FEnabledColor := clYellow;
  FOnCheckItem := nil;
  FOnDrawEditImage := nil;
  FItemCount := 5;
  FImageCount := 5;
end;

procedure TDImageEdit.CreatePropertites;
begin
  FPropertites := TDXImageEditPropertites.Create(Self);
  FDXImageLib := TDXImageEditProperty.Create(FPropertites);
end;

destructor TDImageEdit.Destroy;
begin
  FEditTextList.Free;
  FEditItemList.Free;
  inherited;
end;

procedure TDImageEdit.DirectPaint(dsurface: TDXTexture);
var
  dc, Rect: TRect;
  i: Integer;
  nLeft: Integer;
  ax, ay: integer;
begin
  if FSurface = nil then exit;

  dc.Left := SurfaceX(Left);
  dc.Top := SurfaceY(Top);
  dc.Right := SurfaceX(left + Width);
  dc.Bottom := SurfaceY(top + Height);

  with g_DXCanvas do begin
    //是否显示背景
    if not FTransparent then begin
      FillRect(dc.Left, dc.Top, Width, Height, $FF000000 or LongWord(Color));
      RoundRect(dc.Left, dc.Top, dc.Right, dc.Bottom, FrameColor);
    end;

    //选择文字背景
    if (FStartX > -1) and (FStopX > -1) then begin
      dc.Left := SurfaceX(Left + FStartLine);
      dc.Right := SurfaceX(left + FStopLine);
      if Height > 16 then begin
        dc.Top := SurfaceY(Top + 2);
        dc.Bottom := SurfaceY(top + Height - 2);
      end else begin
        dc.Top := SurfaceY(Top);
        dc.Bottom := SurfaceY(top + Height);
      end;
      FillRect(dc, cColor4($C9C66931), fxBlend);
    end;

    ax := SurfaceX(Left);
    ay := SurfaceY(Top);
    dc := FSurface.ClientRect;
    dc.Left := FStartoffset - 1;
    dc.Right := (Width - (FStartoffset - 1));
    dsurface.Draw(ax + (FStartoffset - 1), ay, dc, FSurface, True);

    if FEditImageList.Count > 0 then begin
      for I := 0 to FEditImageList.Count - 1 do begin
        nLeft := Integer(FEditImageList.Objects[i]);
        Rect.Left := ax + nLeft;
        Rect.Right := Rect.Left + FImageWidth;
        Rect.Top := ay;
        Rect.Bottom := ay + Height;
        if (Rect.Right >= FStartoffset) and (Rect.Left <= (ax + Width - FStartoffset)) and (Rect.Left >= ax) then
          if Assigned(FOnDrawEditImage) then
            FOnDrawEditImage(Self, FSurface, Rect, StrToIntDef(FEditImageList[i], -1));
      end;
    end;

    if (GetTickCount - FCaretShowTime) > 500 then begin
      FCaretShowTime := GetTickCount;
      FCaretShow := not FCaretShow;
    end;
    if FCaretShow and (KeyControl = Self) then begin
      FrmIMEX := SurfaceX(FShowLine + left);
      if Height < 16 then begin
        RoundRect(SurfaceX(FShowLine + left), SurfaceY(Top),
          SurfaceX(left + FShowLine + 1), SurfaceY(top + Height), clWhite);
        FrmIMEY := SurfaceY(Top);
      end
      else begin
        RoundRect(SurfaceX(FShowLine + left), SurfaceY(Top + 2),
          SurfaceX(left + FShowLine + 1), SurfaceY(top + Height - 2), clWhite);
        FrmIMEY := SurfaceY(Top + 2);
      end;
    end;
  end;

  if g_TranFrame then
    g_DXCanvas.RoundRect(SurfaceX(Left), SurfaceY(Top), SurfaceX(Left + Width), SurfaceY(Top + Height), clLime);

  if g_DragMode and (SeletedControl = Self) then
    g_DXCanvas.RoundRect(SurfaceX(Left), SurfaceY(Top), SurfaceX(Left + Width), SurfaceY(Top + Height), clRed);
end;

procedure TDImageEdit.Enter;
begin
  inherited;
end;

procedure TDImageEdit.FormatEditStr(str: string);
var
  Key: Char;
  boImage, boItem: Boolean;
  TempStr, ItemName: string;
  i: integer;
begin
  boImage := False;
  boItem := False;
  if str <> '' then begin
    for I := 1 to length(str) do begin
      Key := str[i];
      if (Key = #13) or (Key = #10) then
        Continue;
      if boImage then begin
        if Key = FImageChar then begin
          boImage := False;
          AddImageToList(TempStr);
        end
        else
          TempStr := TempStr + Key;
      end
      else if boItem then begin
        if Key = FEndChar then begin
          boItem := False;
          ItemName := '';
          if Assigned(FOnCheckItem) then
            FOnCheckItem(self, StrToIntDef(TempStr, 0), ItemName);
          if ItemName <> '' then
            AddItemToList(ItemName, TempStr);
        end
        else
          TempStr := TempStr + Key;
      end
      else if Key = FImageChar then begin
        boImage := True;
        TempStr := '';
      end
      else if Key = FBeginChar then begin
        boItem := True;
        TempStr := '';
      end
      else
        KeyPress(Key);
    end;
  end;
end;

function TDImageEdit.GetText: string;
begin
  Result := FEditString;
end;

function TDImageEdit.KeyDown(var Key: Word; Shift: TShiftState): Boolean;
var
  Clipboard: TClipboard;
  boChange: Boolean;
  OldOnChange: TOnClick;
  str: string;
begin
  Result := FALSE;
  if (KeyControl = self) then begin
    KeyDownControl := Self;
    if Assigned(FOnKeyDown) then
      FOnKeyDown(self, Key, Shift);
    if Key = 0 then
      exit;

    if (ssCtrl in Shift) and (not Downed) and (Key = Word('X')) then begin
      if (FStartX > -1) and (FStopX > -1) and (FStartX <> FStopX) then begin
        Clipboard := TClipboard.Create;
        Clipboard.AsText := GetCopy;
        Clipboard.Free;
        ClearKey();
        TextChange();
      end;
      Key := 0;
      Result := True;
      Exit;
    end
    else if (ssCtrl in Shift) and (not Downed) and (Key = Word('C')) then begin

      if (FStartX > -1) and (FStopX > -1) and (FStartX <> FStopX) then begin
        Clipboard := TClipboard.Create;
        Clipboard.AsText := GetCopy;
        Clipboard.Free;
      end;
      Key := 0;
      Result := True;
      Exit;
    end
    else if (ssCtrl in Shift) and (not Downed) and (Key = Word('V')) then begin

      ClearKey();
      Clipboard := TClipboard.Create;
      str := Clipboard.AsText;
      OldOnChange := FOnChange;
      try
        FormatEditStr(str);
      finally
        FOnChange := OldOnChange;
        Clipboard.Free;
        TextChange;
      end;
      Key := 0;
      Result := True;
      Exit;
    end
    else if (ssCtrl in Shift) and (not Downed) and (Key = Word('A')) then begin
      SetFocus;
      Key := 0;
      Result := True;
      Exit;
    end
    else if (ssShift in Shift) and (not Downed) then begin
      KeyDowned := True;
      if FStartX < 0 then
        FStartX := FCaretPos;
    end
    else begin
      KeyDowned := False;
    end;
    case Key of
      VK_RIGHT: begin
          if FCaretPos < FEditTextList.Count then begin
            Inc(FCaretPos);
            if (ssShift in Shift) then begin
              FStopX := FCaretPos;
            end
            else begin
              FStartX := -1;
              FStopX := -1;
              KeyDowned := False;
            end;
            RefEditSurfce();
          end
          else begin
            if (ssShift in Shift) then begin
              FStopX := FCaretPos;
            end
            else begin
              FStartX := -1;
              FStopX := -1;
              KeyDowned := False;
            end;
            RefEditSurfce();
          end;
          Key := 0;
          Result := TRUE;
        end;
      VK_LEFT: begin
          if FCaretPos > 0 then begin
            Dec(FCaretPos);
            if (ssShift in Shift) then begin
              FStopX := FCaretPos;
            end
            else begin
              FStartX := -1;
              FStopX := -1;
              KeyDowned := False;
            end;
            RefEditSurfce();
          end
          else begin
            if (ssShift in Shift) then begin
              FStopX := FCaretPos;
            end
            else begin
              FStartX := -1;
              FStopX := -1;
              KeyDowned := False;
            end;
            RefEditSurfce();
          end;
          Key := 0;
          Result := TRUE;
        end;
      VK_DELETE: begin
          boChange := ClearKey;
          if (not boChange) and (FEditTextList.Count > 0) then begin
            if FCaretPos < FEditTextList.Count then
              FEditTextList.Delete(FCaretPos);
            SetBearing(True);
            RefEditText;
            RefEditSurfce;
            TextChange();
          end
          else if boChange then
            TextChange();
          Key := 0;
          Result := TRUE;
        end;
    end;
  end;
end;

function TDImageEdit.KeyPress(var Key: Char): Boolean;
var
  boChange: Boolean;
begin
  Result := False;
  if KeyControl = Self then
  begin
    Result := True;
    if (not Downed) then
    begin
      if Assigned(FOnKeyPress) then
        FOnKeyPress(self, Key);
      if Key = #0 then
        Exit;
      case Key of
        Char(VK_BACK): begin
            boChange := ClearKey;
            if (not boChange) and (FEditTextList.Count > 0) and (FCaretPos > 0) then
            begin
              if FCaretPos > FEditTextList.Count then
                FCaretPos := FEditTextList.Count;
              FEditTextList.Delete(FCaretPos - 1);
              Dec(FCaretPos);
              SetBearing(True);
              RefEditText;
              RefEditSurfce;
              TextChange();
            end else
            if boChange then
              TextChange();
          end;
      else
        begin
          if IsAllChars(Key) then
          begin
            if IsMBCSChar(Key){IsDBCSLeadByte(Ord(Key))} or bDoubleByte then
            begin
              bDoubleByte := true;
              Inc(KeyByteCount);
              FInputStr := FInputStr + key;
            end;
            if not bDoubleByte then begin
              if (Key = FBeginChar) or (Key = FEndChar) or (Key = FImageChar) then
              begin
                Key := #0;
                Exit;
              end;

              ClearKey;
              if (MaxLength > 0) and (Length(FEditString) >= MaxLength) then
              begin
                Key := #0;
                exit;
              end;
              AddStrToList(Key);
              Key := #0;
              TextChange();
            end else
            if KeyByteCount >= 2 then
            begin
              if length(FInputStr) <> 2 then
              begin
                bDoubleByte := false;
                KeyByteCount := 0;
                FInputStr := '';
                Key := #0;
                exit;
              end;

              ClearKey;
              if (MaxLength > 0) and (Length(FEditString) >= (MaxLength - 1)) then
              begin
                bDoubleByte := false;
                KeyByteCount := 0;
                FInputStr := '';
                Key := #0;
                exit;
              end;
              AddStrToList(FInputStr);
              TextChange();
              bDoubleByte := false;
              KeyByteCount := 0;
              FInputStr := '';
              Key := #0;
            end;
          end;
        end;
      end;
    end;
    Key := #0;
  end;
end;

function TDImageEdit.KeyUp(var Key: Word; Shift: TShiftState): Boolean;
begin
  Result := FALSE;
  if (KeyControl = self) then begin
    if (Key = VK_SHIFT) then begin
      KeyDowned := False;
      if FStopX = -1 then
        FStartX := -1;
    end;
    if Assigned(FOnKeyUp) then
      FOnKeyUp(self, Key, Shift);
    Key := 0;
    Result := TRUE;
  end;
end;

procedure TDImageEdit.Leave;
begin
  FStartX := -1;
  FStopX := -1;
  RefEditSurfce();
  inherited;
end;

function TDImageEdit.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean;
begin
  Result := FALSE;
  if inherited MouseDown(Button, Shift, X, Y) then begin
    if (not Background) and (MouseCaptureControl = nil) then begin
      KeyDowned := False;
      if mbLeft = Button then begin
        FStartX := -1;
        FStopX := -1;
        if (FocusedControl = self) then begin
          MoveCaret(X - left, Y - top);
        end;
        Downed := True;
      end;
      SetDCapture(self);
    end;
    Result := TRUE;
  end;
end;

function TDImageEdit.MouseMove(Shift: TShiftState; X, Y: Integer): Boolean;
begin
  Result := inherited MouseMove(Shift, X, Y);
  if Result and (MouseCaptureControl = self) then begin
    if Downed and (not KeyDowned) then
      MoveCaret(X - left, Y - top);
  end;
end;

function TDImageEdit.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer): Boolean;
begin
  Result := FALSE;
  Downed := False;
  if inherited MouseUp(Button, Shift, X, Y) then begin
    ReleaseDCapture;
    if not Background then begin
      if InRange(X, Y, Shift) then begin
        if Assigned(FOnClick) then
          FOnClick(self, X, Y);
      end;
    end;
    Result := TRUE;
    exit;
  end
  else begin
    ReleaseDCapture;
  end;
end;

function TDImageEdit.Selected: Boolean;
begin
  Result := False;
  if (FStartX > -1) and (FStopX > -1) and (FStartX <> FStopX) then
    Result := True;
end;

procedure TDImageEdit.SetBearing(boLeft: Boolean);
begin

  if not FShowLeft then begin
    FShowLeft := True;
    FShowPos := FOppShowPos;
  end;

end;

procedure TDImageEdit.SetFocus;
begin
  inherited;
  if FEditTextList.Count > 0 then begin
    FStartX := 0;
    FStopX := FEditTextList.Count;
    FCaretPos := FEditTextList.Count;
    FShowPos := FEditTextList.Count - 1;
    FShowLeft := False;
    RefEditSurfce();
  end;
end;

procedure TDImageEdit.SetText(const Value: string);
var
  OldOnChange: TOnClick;
  OldKeyControl: TDControl;
begin
  OldOnChange := FOnChange;
  OldKeyControl := KeyControl;
  KeyControl := Self;
  FOnChange := nil;
  FEditTextList.Clear;
  try
    FormatEditStr(Value);
  finally
    FOnChange := OldOnChange;
    KeyControl := OldKeyControl;
  end;
  RefEditText;
  RefEditSurfce();
  TextChange;
  SetFocus;
  FStartX := -1;
  FStopX := -1;
end;

procedure TDImageEdit.TextChange;
begin
  if Assigned(FOnChange) then
    FOnChange(self);
end;


{ TDXWindowImageEditPropertites }

function TDXImageEditPropertites.GetFrameColor(const Index: Integer): TColor;
begin
  Result := clSilver;
  if FControl is TDImageEdit then
  begin
    case Index of
      1: Result := TDImageEdit(FControl).FrameColor;
      2: Result := TDImageEdit(FControl).Color;
    end;
  end;
end;

function TDXImageEditPropertites.GetTransparent: Boolean;
begin
  Result := False;
  if FControl is TDImageEdit then
    Result := TDImageEdit(FControl).Transparent;
end;

procedure TDXImageEditPropertites.SetFrameColor(const Index: Integer; Value: TColor);
begin
  if FControl is TDImageEdit then
  begin
    case Index of
      1: TDImageEdit(FControl).FrameColor := Value;
      2: TDImageEdit(FControl).Color := Value;
    end;
  end;
end;

procedure TDXImageEditPropertites.SetTransparent(const Value: Boolean);
begin
  if FControl is TDImageEdit then
    TDImageEdit(FControl).Transparent := Value;
end;

{ TDXWindowEditPropertites }

function TDXEditPropertites.GetFrameColor(const Index: Integer): TColor;
begin
  Result := clSilver;
  if FControl is TDEdit then
  begin
    case Index of
      1: Result := TDEdit(FControl).FrameColor;
      2: Result := TDEdit(FControl).Color;
    end;
  end;
end;

function TDXEditPropertites.GetTransparent: Boolean;
begin
  Result := False;
  if FControl is TDEdit then
    Result := TDEdit(FControl).Transparent;
end;

procedure TDXEditPropertites.SetFrameColor(const Index: Integer; Value: TColor);
begin
  if FControl is TDEdit then
  begin
    case Index of
      1: TDEdit(FControl).FrameColor := Value;
      2: TDEdit(FControl).Color := Value;
    end;
  end;
end;

procedure TDXEditPropertites.SetTransparent(const Value: Boolean);
begin
  if FControl is TDEdit then
    TDEdit(FControl).Transparent := Value;
end;

{ TDWindowMiniMap }

procedure TDWindowMiniMap.CreatePropertites;
begin
  FPropertites := TDXWindowMiniMapPropertites.Create(Self);
  FDXImageLib := TDXWindowImageProperty.Create(FPropertites);
end;

constructor TDWindowMiniMap.Create(aowner: TComponent);
begin
  CreatePropertites;
  inherited Create(aowner);
  FRound :=  False;
end;

{ TDXWindowMiniMapPropertites }

function TDXWindowMiniMapPropertites.GetRound: Boolean;
begin
  Result := False;
  if FControl is TDWindowMiniMap then
    Result := TDWindowMiniMap(FControl).Round;
end;

procedure TDXWindowMiniMapPropertites.SetRound(const Value: Boolean);
begin
  if FControl is TDWindowMiniMap then
    TDWindowMiniMap(FControl).Round := Value;
end;

{ TDXUpDownPropertites }

function TDXUpDownPropertites.GetProperty(const Index: Integer): Integer;
begin
  Result := -1;
  if FControl is TDUpDown then
  begin
    case Index of
      1: begin
        if TDUpDown(FControl).UpButton <> nil then
           Result := TDUpDown(FControl).UpButton.FaceIndex;
      end;
      2: begin
        if TDUpDown(FControl).DownButton <> nil then
          Result := TDUpDown(FControl).DownButton.FaceIndex;
      end;
      3: begin
        if TDUpDown(FControl).FMoveButton <> nil then
          Result := TDUpDown(FControl).MoveButton.FaceIndex;
      end;
      4: Result := TDUpDown(FControl).Offset;
    end;
  end;
end;

procedure TDXUpDownPropertites.SetProperty(const Index, Value: Integer);
begin
  if FControl is TDUpDown then
  begin
    case Index of
      1: begin
        if TDUpDown(FControl).FUpButton <> nil then
           TDUpDown(FControl).FUpButton.FaceIndex := Value;
      end;
      2: begin
        if TDUpDown(FControl).FDownButton <> nil then
          TDUpDown(FControl).FDownButton.FaceIndex := Value;
      end;
      3: begin
        if TDUpDown(FControl).FMoveButton <> nil then
          TDUpDown(FControl).FMoveButton.FaceIndex := Value;
      end;
      4: TDUpDown(FControl).Offset := Value;
    end;
  end;
end;

{ TDUpDownButton }

constructor TDUpDownButton.Create(AOwner: TComponent);
begin
  CreatePropertites;
  inherited Create(aowner);
end;

procedure TDUpDownButton.CreatePropertites;
begin
  FPropertites := TDXUpDownButtonPropertites.Create(Self);
  FDXImageLib := TDXUpDownButtonProperty.Create(FPropertites);
end;

destructor TDUpDownButton.Destroy;
begin

  inherited;
end;

initialization
begin
  g_LibClientList := TList.Create;
end;

finalization
begin
  g_LibClientList.Free;
end;


end.

