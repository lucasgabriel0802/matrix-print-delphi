unit MatrixPrint.Setup;

{******************************************************************************}
{                                                                              }
{  MatrixPrint - Modern Open-Source Dot-Matrix & Text Reporting for Delphi     }
{                                                                              }
{  Copyright (c) 2026 Lucas Gabriel / Equipe Delphi                            }
{  Licensed under the MIT License                                              }
{                                                                              }
{******************************************************************************}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  System.UITypes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons,
  Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Printers,
  MatrixPrint.Types;

type
  TFormMatrixSetup = class(TForm)
    PanelTop: TPanel;
    lblHeaderTitle: TLabel;
    lblHeaderSub: TLabel;
    gbPrinter: TGroupBox;
    lblPrinter: TLabel;
    cbPrinters: TComboBox;
    lblDriver: TLabel;
    cbDriver: TComboBox;
    gbRange: TGroupBox;
    rbAllPages: TRadioButton;
    rbPagesInterval: TRadioButton;
    lblFrom: TLabel;
    edFromPage: TEdit;
    lblTo: TLabel;
    edToPage: TEdit;
    gbCopies: TGroupBox;
    lblCopies: TLabel;
    edCopies: TEdit;
    udCopies: TUpDown;
    chkCollate: TCheckBox;
    PanelButtons: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    procedure FormCreate(Sender: TObject);
    procedure rbRangeClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
  private
    FSettings: TMatrixPrintSettings;
    FTotalPages: Integer;
    procedure LoadPrinters;
    procedure UpdateControlsState;
  public
    class function Execute(var ASettings: TMatrixPrintSettings; ATotalPages: Integer): Boolean;
  end;

implementation

{$R *.dfm}

{ TFormMatrixSetup }

class function TFormMatrixSetup.Execute(var ASettings: TMatrixPrintSettings; ATotalPages: Integer): Boolean;
var
  Form: TFormMatrixSetup;
begin
  Form := TFormMatrixSetup.Create(Application);
  try
    Form.FSettings := ASettings;
    Form.FTotalPages := ATotalPages;

    // Inicializar controles
    if Form.cbPrinters.Items.IndexOf(ASettings.PrinterName) >= 0 then
      Form.cbPrinters.ItemIndex := Form.cbPrinters.Items.IndexOf(ASettings.PrinterName)
    else if Form.cbPrinters.Items.Count > 0 then
      Form.cbPrinters.ItemIndex := 0;

    Form.cbDriver.ItemIndex := Integer(ASettings.Driver);
    Form.udCopies.Position := ASettings.Copies;
    Form.chkCollate.Checked := ASettings.Collate;

    Form.rbAllPages.Checked := ASettings.PrintRangeAll;
    Form.rbPagesInterval.Checked := not ASettings.PrintRangeAll;
    Form.edFromPage.Text := IntToStr(ASettings.FromPage);
    Form.edToPage.Text := IntToStr(ASettings.ToPage);

    Form.UpdateControlsState;

    Result := Form.ShowModal = mrOk;
    if Result then
    begin
      ASettings := Form.FSettings;
    end;
  finally
    Form.Free;
  end;
end;

procedure TFormMatrixSetup.FormCreate(Sender: TObject);
begin
  LoadPrinters;
  cbDriver.Items.Clear;
  cbDriver.Items.Add('Epson ESC/P (Matricial 9/24 pinos)');
  cbDriver.Items.Add('HP PCL (Laser / Jato de Tinta)');
  cbDriver.Items.Add('Texto Puro Genérico (RAW)');
  cbDriver.Items.Add('Windows Gráfico GDI (Universal / PDF)');
  cbDriver.ItemIndex := 0;
end;

procedure TFormMatrixSetup.LoadPrinters;
begin
  cbPrinters.Items.Assign(Printer.Printers);
  if (cbPrinters.Items.Count > 0) and (Printer.PrinterIndex >= 0) then
    cbPrinters.ItemIndex := Printer.PrinterIndex;
end;

procedure TFormMatrixSetup.rbRangeClick(Sender: TObject);
begin
  UpdateControlsState;
end;

procedure TFormMatrixSetup.UpdateControlsState;
begin
  edFromPage.Enabled := rbPagesInterval.Checked;
  edToPage.Enabled   := rbPagesInterval.Checked;
  lblFrom.Enabled    := rbPagesInterval.Checked;
  lblTo.Enabled      := rbPagesInterval.Checked;
end;

procedure TFormMatrixSetup.btnOKClick(Sender: TObject);
var
  FromP, ToP: Integer;
begin
  if cbPrinters.ItemIndex < 0 then
  begin
    MessageDlg('Por favor, selecione uma impressora.', mtWarning, [mbOK], 0);
    ModalResult := mrNone;
    Exit;
  end;

  FSettings.PrinterIndex := cbPrinters.ItemIndex;
  FSettings.PrinterName  := cbPrinters.Text;
  FSettings.Driver       := TMatrixDriver(cbDriver.ItemIndex);
  FSettings.Copies       := udCopies.Position;
  FSettings.Collate      := chkCollate.Checked;
  FSettings.PrintRangeAll:= rbAllPages.Checked;

  if rbPagesInterval.Checked then
  begin
    FromP := StrToIntDef(edFromPage.Text, 1);
    ToP   := StrToIntDef(edToPage.Text, FTotalPages);
    if FromP < 1 then FromP := 1;
    if (ToP < FromP) or (ToP > FTotalPages) then ToP := FTotalPages;
    FSettings.FromPage := FromP;
    FSettings.ToPage   := ToP;
  end
  else
  begin
    FSettings.FromPage := 1;
    FSettings.ToPage   := FTotalPages;
  end;

  FSettings.UseDirectRaw := (FSettings.Driver <> mdWindowsGDI);
  ModalResult := mrOk;
end;

end.
