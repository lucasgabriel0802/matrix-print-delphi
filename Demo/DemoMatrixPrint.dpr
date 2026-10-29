program DemoMatrixPrint;

uses
  Vcl.Forms,
  U_DemoMain in 'U_DemoMain.pas' {FormDemoMain},
  MatrixPrint.Types in '..\Source\MatrixPrint.Types.pas',
  MatrixPrint.Engine in '..\Source\MatrixPrint.Engine.pas',
  MatrixPrint.Setup in '..\Source\MatrixPrint.Setup.pas' {MatrixPrintSetupForm},
  MatrixPrint.Preview in '..\Source\MatrixPrint.Preview.pas' {MatrixPrintPreviewForm},
  MatrixPrint in '..\Source\MatrixPrint.pas';

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Demo MatrixPrint';
  Application.CreateForm(TFormDemoMain, FormDemoMain);
  Application.Run;
end.
