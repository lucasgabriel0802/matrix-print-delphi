unit MatrixPrint.Reg;

interface

uses
  System.Classes;

procedure Register;

implementation

uses
  MatrixPrint;

procedure Register;
begin
  RegisterComponents('MatrixPrint', [TMatrixPrint]);
end;

end.
