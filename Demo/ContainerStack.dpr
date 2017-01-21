program ContainerStack;

uses
  System.StartUpCopy,
  FMX.Forms,
  ContainerStackFrm in 'ContainerStackFrm.pas' {ContainerStackDlg},
  TestFrm1 in 'TestFrm1.pas' {TestDlg1},
  TestFrm2 in 'TestFrm2.pas' {TestDlg2},
  ContainerStackLib in '..\src\ContainerStackLib.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TContainerStackDlg, ContainerStackDlg);
  Application.CreateForm(TTestDlg1, TestDlg1);
  Application.CreateForm(TTestDlg2, TestDlg2);
  Application.Run;
end.
