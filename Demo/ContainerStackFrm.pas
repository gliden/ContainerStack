unit ContainerStackFrm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  ContainerStackLib, FMX.StdCtrls, FMX.Controls.Presentation;

type
  TContainerStackDlg = class(TForm)
    procedure FormCreate(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  ContainerStackDlg: TContainerStackDlg;

implementation

{$R *.fmx}

procedure TContainerStackDlg.FormCreate(Sender: TObject);
begin
  TContainerStack.Current.Initialize(Self);
end;

end.
