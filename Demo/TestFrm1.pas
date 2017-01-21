unit TestFrm1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  ContainerStackLib, FMX.Layouts, FMX.Controls.Presentation, FMX.StdCtrls,
  FMX.Objects, TestFrm2;

type
  TTestDlg1 = class(TForm)
    Container: TLayout;
    Label1: TLabel;
    Panel1: TPanel;
    Rectangle1: TRectangle;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  TestDlg1: TTestDlg1;

implementation

{$R *.fmx}

procedure TTestDlg1.Button1Click(Sender: TObject);
begin
  TContainerStack.Current.ShowForm(TestDlg2, TAnimationStyle.OverlayFromBottom, 0.8);
end;

procedure TTestDlg1.FormCreate(Sender: TObject);
begin
  TContainerStack.Current.RegisterForm(Self);
  TContainerStack.Current.ShowFormNoAnimation(Self);
end;

end.
