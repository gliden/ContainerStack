unit TestFrm2;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Controls.Presentation, FMX.StdCtrls, ContainerStackLib, FMX.Objects;

type
  TTestDlg2 = class(TForm)
    Container: TLayout;
    Label1: TLabel;
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
  TestDlg2: TTestDlg2;

implementation

{$R *.fmx}

procedure TTestDlg2.Button1Click(Sender: TObject);
begin
  TContainerStack.Current.Back;
end;

procedure TTestDlg2.FormCreate(Sender: TObject);
begin
  TContainerStack.Current.RegisterForm(Self);
end;

end.
