unit SetupUnit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, RzButton, RzRadChk, jpeg, RzBckgnd, ImgButton;

type
  TForm1 = class(TForm)
    suiclose: TImgButton;
    RzRadioButton2: TRzRadioButton;
    RzRadioButton1: TRzRadioButton;
    suiImageButton1: TImgButton;
    suiImageButton2: TImgButton;
    RzBackground1: TRzBackground;
    procedure suicloseClick(Sender: TObject);
    procedure suiImageButton1Click(Sender: TObject);
    procedure suiImageButton2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  DoubleBuffered := True;
end;

procedure TForm1.suicloseClick(Sender: TObject);
begin
Close;
end;

procedure TForm1.suiImageButton1Click(Sender: TObject);
begin
Close;
end;

procedure TForm1.suiImageButton2Click(Sender: TObject);
begin
Close;
end;

end.
